#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"

#define CRLF chr( 13 ) + chr( 10 )
#define GUIA_CONSULTA 	'01'
#define GUIA_SADT		'02'
#define GUIA_INTERNACAO	'05'
#define GUIA_HONORARIO 	'06'
#define GUIA_REC_GLOSA 	'10'

static cCodInt 		:= ''
static lPLSR506 	:= existBlock("PLSR506")
static cDirTmp 		:= PLSMUDSIS( "\plsptu\" )
static lPTUDEPARA 	:= existBlock("PTUDEPARA")
static cOpmeGen 	:= getNewPar("MV_PLOPMPT","99999943")
static lPLU5CNES	:= existBlock("PLU5CNES")
static cQuallog     := iif(findfunction('dwcallstack'), "dwcallstack(0,,.f.)", "PPilhaProc(0, '')")
static cPacGPTU     := getNewPar("MV_PLPACPT","99999998")
static cOpePEA      := GetNewPar("MV_PLOPPEA","0999")
static lIdUnico2	:= .f.
Static cTipPre 		as char
Static lCamReaTPJ   := .f.
Static lReapTPJ     := .f.
Static bkpFilter    := ""

static cBB8Name := retSqlName("BB8")
static cBTOName := retSqlName("BTO")
static cBDHName := retSqlName("BDH")
static cBD6Name := retSqlName("BD6")
static cBD7Name := retSqlName("BD7")
static cBD5Name := retSqlName("BD5")
static cBE4Name := retSqlName("BE4")
static cBX6Name := retSqlName("BX6")
static cBAUName := retSqlName("BAU")
static cBB0Name := retSqlName("BB0")
static cB43Name := retSqlName("B43")
static cBEAName := retSqlName("BEA")
static cBKFName := retSqlName("BKF")
static cBR8Name := retSqlName("BR8")
static cBTUName := retSqlName("BTU")
static cBCIName := retSqlName("BCI")

static cServ 	:= "PPM,HM,HMR,VMT,VMD,REA,VTX,VDI"
static cAux 	:= "AUX,AUR"
static cAnest 	:= "PAP,PA,PAR"
static cCusOpe 	:= "COR,COP,UCO"
static cFilm 	:= "FIL"

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA500
Classe referente a engine de exportação do PTU A500

@author    Lucas Nonato
@version   V12
@since     11/09/2019
/*/
class PTUA500

data cOpeDes 	as String 	// Codigo unimed destino
data cXml 		as String 	// String do Arquivo XML
data cCabXml	as String 	// String do Arquivo XML
data cEndXml	as String 	// String do Arquivo XML
data cNameSpace as String 	// NameSpace do arquivo
data cStrHash   as String 	// String que vai ser utilizada para calculo do hash
data cHashMD5   as String 	// Hash MD5 calculado 
data cFolder    as String 	// Pasta onde sera gravado o arquivo XML
data cFileName  as String 	// Nome do arquivo XML gerado 
data cGuiOpe   	as String 	// Chave da Guia
data cAvisoXML  as String 	// Mensagem de aviso na geracao arquivo XML
data cSchmFolde as String 	// Pasta com os schemas
data cSchema    as String 	// Arquivo de Schema
data cVersao    as String 	// Versao do Schema
data cVersaoXml as String   // Versão da transação
data lAuto      as Boolean  // Indica se a chamada da rotina e via automacao de testes
data lAviso     as Boolean  // Lote de aviso(PTU A520)
data aMsg  		as Array    // Array com mensagens 
data lVersAtual as Boolean 	// Indica se a versao do layout é a mais atual
data cAlias		as String 	// Alias da query com as guias
data nArqFull 	as numeric 	// Arquivo XML
data nArqHash 	as numeric	// Arquivo do hash
data nArqLog 	as numeric  // Arquivo de logs
data lBlcReap	as Boolean  // bloco de reapresentação
data cBlcReTpI	as String	// Tipo de reapresentação - I ou J
data lInt4Reap	as Boolean	// Se reaprsentação de "Internação" - tratamento diferente

method New() CONSTRUCTOR
method Consulta() 
method SADT() 
method Internacao() 
method Honorario() 
method Beneficiario() 
method profissionalExecutante()
method Solicitante() 
method contratadoExecutante() 
method procedimentos() 
method Executados() 
method dadosGuia()
method dadosOPME()
method equipeProfissional()
method dadosAutorizacao()
method MontaTag() 
method Inifile(cTag) 
method iniGuia() 
method fimGuia() 
method validaXML() 
method CalcHash() 
method addMsg() 
method SetVersao(cVersaoXml) 
method geraXML() 
method geraHash() 
method logErro() 
method PRecupTipGui(cTipPesq) 
method PBlocoReapre(cCodPeg, cDoc1Gl, cDoc2Gl, cNumOper)
method InternEsp(oObjPTU)
endclass


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA500X
Exportação do PTU A500 xml

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
function PLSUA500X(lAutoma)
local cCampos 	:= ""
Default lAutoma := .F.
private oMBrw 
 						
BD5->(dbsetorder(1))
BE4->(dbsetorder(1))
B43->(dbsetorder(1))
BX6->(dbsetorder(1))
BR8->(dbsetorder(1))

cCampos += iif(BD5->(fieldPos("BD5_TISVER")) <= 0, "BD5_TISVER,", "" ) 
cCampos += iif(BE4->(fieldPos("BE4_TISVER")) <= 0, "BE4_TISVER,", "" )
cCampos += iif(B43->(fieldPos("B43_IDUNIC")) <= 0, "B43_IDUNIC,", "" )
cCampos += iif(B43->(fieldPos("B43_SEQPTU")) <= 0, "B43_SEQPTU,", "" )
cCampos += iif(BX6->(fieldPos("BX6_IDUNIC")) <= 0, "BX6_IDUNIC,", "" )
cCampos += iif(BX6->(fieldPos("BX6_SEQPTU")) <= 0, "BX6_SEQPTU,", "" )
cCampos += iif(BR8->(fieldPos("BR8_TIPROL")) <= 0, "BR8_TIPROL,", "" )

lCamReaTPJ := BTO->(fieldPos("BTO_REAPRE")) > 0

if !empty(cCampos)
	If !lAutoma
		cCampos := substr(cCampos,1,len(cCampos)-1)
		aviso( "Atenção","Para a execução da rotina, é necessária a criação do(s) campo(s): " + cCampos ,{ "Ok" }, 2 )
		return
	Else
		cCampos := substr(cCampos,1,len(cCampos)-1)
		return .F.
	EndIf	
endIf

cCodInt := plsintpad()

if existBlock("PLS500UNM")
	aRet := execBlock("PLS500UNM",.F.,.F.,{cServ,cAux,cAnest,cCusOpe,cFilm})
	cServ 	:= aRet[1]
	cAux 	:= aRet[2]
	cAnest 	:= aRet[3]
	cCusOpe	:= aRet[4]
	cFilm 	:= aRet[5]
endif 

cCusOpe := strtran("'"+cCusOpe+"'",",","','")
cFilm 	:= strtran("'"+cFilm+"'",",","','")

cFilter := PTU500FIL(.f.,lAutoma)
setKey(VK_F2 ,{|| cFilter := PTU500FIL(.t.,lAutoma) })

oMBrw:= FWMarkBrowse():New()
oMBrw:SetAlias("BTO")
oMBrw:SetDescription("Exportação PTU A500" )
oMBrw:SetMenuDef("PLSUA500X")
oMBrw:AddLegend("BTO_ENV500 == '1'", "GREEN",	"Enviado" )
oMBrw:AddLegend("BTO_ENV500 <> '1'", "BLACK",	"Não Enviado" )

oMBrw:SetFieldMark( 'BTO_OK' )	
oMBrw:SetAllMark({ ||  A270Inverte(@oMBrw,"BTO") })
oMBrw:SetFilterDefault(cFilter)
oMBrw:SetWalkThru(.F.)
oMBrw:SetAmbiente(.F.)
oMBrw:ForceQuitButton()
If !lAutoma
	oMBrw:Activate()
EndIf
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU500FIL
Filtro

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PTU500FIL(lF2,lAuto)

local aPergs	:= {}
local aFilter	:= {}
local cFilter 	:= ""
local cCodOpe	:= space(4)
local cStatus	:= space(1)
local cReapre   := space(1)
local cGruOpe	:= space(2)
local lPerg		:= .t.

default lF2  	:= .f.
default lAuto	:= .f.
aAdd( aPergs,{ 1, "Filtrar Unimed" , 	cCodOpe		, "", "", "B39PLS"		, "", 50, .f.})
aadd( aPergs,{ 2, "Status:"		 	, 	cStatus		,{ "0=Todas","1=Não Enviados","2=Enviados"},100,/*'.T.'*/,.f. } )
aadd( aPergs,{ 1, "Filtrar Grupo Operadora"	,	cGruOpe		,"@!",'.T.','BA2PLS',/*'.T.'*/,40,.f. } )
aAdd( aPergs,{ 1, "A partir de:"	, 	dDataBase	, "", "", ""		, "", 50, .f.})
aadd( aPergs,{ 2, "Reapresentação:"		 	, 	cReapre		,{ "0=Não","1=Sim"},100,/*'.T.'*/,.f. } )

if !lAuto	
	lPerg := paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSUX500',/*lCanSave*/.T.,/*lUserSave*/.T. )
endif

if lPerg
	cFilter += "@BTO_FILIAL = '" + xfilial("BTO") + "'"	
	cFilter += " AND BTO_CODOPE = '" + cCodInt + "'"	
	
	cFilter += " AND BTO_STATUS = '1' "	

	if !lAuto
		if !empty(aFilter[1]) 
			cFilter += " AND BTO_OPEORI = '" + aFilter[1] + "'"	
		endif

		if aFilter[2] <> "0"
			if aFilter[2] == "1"
				cFilter += " AND BTO_ENV500 <> '1' "	
			else
				cFilter += " AND BTO_ENV500 = '1' "	
			endif
		endif

		if !empty(aFilter[3]) 
			cFilter += " AND BTO_GRPOPE = '" + aFilter[3] + "'"	
		endif

		if !empty(aFilter[4]) 
			cFilter += " AND BTO_DATGER >= '" + dtos(aFilter[4]) + "'"	
		endif

		if lCamReaTPJ 
			if aFilter[5]=='1' 
				cFilter += " AND BTO_REAPRE = '1' "	
			else 
				cFilter += " AND (BTO_REAPRE = '0' OR BTO_REAPRE = ' ') "	
			endif
		endif

	endif

	cFilter += " AND ( BTO_TPMOV = '2' OR (BTO_TPMOV = '3' AND BTO_TPCOB = '1')) "	

endif

if lF2
	oMBrw:SetFilterDefault(cFilter)
	oMBrw:Refresh()
endif

bkpFilter := cFilter

return cFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function MenuDef()
Local aRotina := {}
	
ADD OPTION aRotina Title 'Exportar XML'		Action 'PTU500EXP()'		OPERATION MODEL_OPERATION_VIEW ACCESS 0	
ADD OPTION aRotina Title "<F2> - Filtrar" 	Action 'PTU500FIL(.t.)'		OPERATION MODEL_OPERATION_VIEW ACCESS 0 
ADD OPTION aRotina Title 'Desmarcar Tudo'	Action 'PTU500DMA()'		OPERATION MODEL_OPERATION_VIEW ACCESS 0	
Add Option aRotina Title 'Visualizar'  		Action 'VIEWDEF.PLSP550EX' 	Operation MODEL_OPERATION_VIEW Access 0 // Visualizar
Add Option aRotina Title 'Reapresentar'  	Action 'PLTELREAP()' 	    Operation MODEL_OPERATION_VIEW Access 0 // Visualizar

return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU500EXP

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PTU500EXP(lAuto)
private oProcess 	:= nil
default lAuto 		:= .f.

if lAuto
	cCodInt := plsintpad()
	oProcess := P270fProc():New()
	PTU500BASE(lAuto)
else
	oProcess := msNewProcess():New( { || PTU500BASE() } , "Processando" , "Aguarde..." , .F. )
	oProcess:Activate()
endif

return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU500BASE

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PTU500BASE(lAuto)
local cSql 			as char
local cISql			as char
local cAliTmp		:= getNextAlias()
local cAliPrc		:= getNextAlias()
local cAliasBTO		:= getNextAlias()
local aParam        := {} 
local aMsg     		:= {} 
local lFoundFAT     := .f.
local nQtd     		:= 0
local nRecnoD2 		:= 0
local cDatabase		:= upper(TCGetDb())
private oTmpBase	:= nil
private oTmpProc	:= nil
default lAuto 		:= .f.

fCriaBase(cAliTmp,@oTmpBase) 
fCriaProc(cAliPrc,@oTmpProc) 

if !lAuto
	if !PLSU500PER(aParam)
		return
	endif
else
	aadd(aParam,1)
	aadd(aParam,cDirTmp  )//Futuramente trocar pelo esquema de caixa de entrada e caixa de saida na pasta PLSPTU.
endif

cSql := " SELECT COUNT(*) QTD FROM " + cBTOName + " BTO "
cSql += " WHERE BTO_OK = '" + oMBrw:cMark + "'" 
cSql += " AND BTO.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'QTDBTO',.F.,.T.)
nQtd := QTDBTO->QTD
QTDBTO->(dbclosearea())

cSql := " SELECT R_E_C_N_O_ RECNO FROM " + cBTOName + " BTO "
cSql += " WHERE BTO_OK = '" + oMBrw:cMark + "'" 
cSql += " AND BTO.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasBTO,.F.,.T.)

oProcess:SetRegua1( nQtd )
oProcess:SetRegua2( -1 )
CINI := time()
while (cAliasBTO)->(!eof())
	BTO->(dbgoto((cAliasBTO)->RECNO))
	nRecnoD2 := 0
	oProcess:IncRegua1( "Processando... Unimed: [" + BTO->BTO_OPEORI + "] Lote: [" + BTO->BTO_NUMERO + "]")		
	lReapTPJ := lCamReaTPJ .and.  BTO->BTO_REAPRE == '1'

	If lReapTPJ .and. empty(BTO->BTO_NUMTIT)
		CriTitReap()
	endif	
	
	if !SE1->(msseek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)))
		lFoundFAT := .F.
	else
		lFoundFAT := .T.
	endif				

	if !lFoundFAT	
		aadd(aMsg,{BTO->BTO_OPEORI, BTO->BTO_NUMERO, "Titulo não encontrado" + BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)})	
		(cAliasBTO)->(dbskip())
		loop
	endif

	PLSCOMMIT("DELETE FROM " + oTmpBase:getrealName())

	if !lReapTPJ
		cSql := " SELECT BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_TIPGUI, BD6_CODRDA, BD7_CODPAD, BD7_CODPRO, BD7_SEQUEN, BD7_CODUNM,"
		cSql += " BD7_NLANC, BD7_CDPFPR, BD7_SIGLA, BD7_REGPRE, BD7_ESTPRE, BD7_ESPEXE, BD7_CODTPA, BD7_CODESP, BD7_VLRTPF, BD7_VLRTAD, BD7_CODRDA "
		cSql += " FROM " + cBDHName + " BDH "
		cSql += " INNER JOIN " + cBD6Name + " BD6 "	
		cSql += " ON BD6_FILIAL = '"+xFilial("BD6")+"'  "	
		cSql += " AND BD6_OPEUSR = BDH_CODINT "
		cSql += " AND BD6_CODEMP = BDH_CODEMP "
		cSql += " AND BD6_MATRIC = BDH_MATRIC "
		cSql += " AND BD6_TIPREG = BDH_TIPREG "
		cSql += " AND BD6_SEQPF  = BDH_SEQPF   "
		cSql += " AND BD6_ANOPAG = BDH_ANOFT  "
		cSql += " AND BD6_MESPAG = BDH_MESFT  "	
		cSql += " AND BD6.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + cBD7Name + " BD7 "		
		cSql += " ON BD7_FILIAL = BD6_FILIAL  "
		cSql += " AND BD7_CODOPE = BD6_CODOPE  "
		cSql += " AND BD7_CODLDP = BD6_CODLDP  "
		cSql += " AND BD7_CODPEG = BD6_CODPEG  "
		cSql += " AND BD7_NUMERO = BD6_NUMERO  "
		cSql += " AND BD7_ORIMOV = BD6_ORIMOV  "
		cSql += " AND BD7_SEQUEN = BD6_SEQUEN  "	
		cSql += " AND BD7.D_E_L_E_T_ = ' '  "

		cSql += " WHERE BDH_FILIAL = '"+xFilial("BDH")+"' "		
		if BTO->BTO_TPMOV == '1' .or. (BTO->BTO_TPMOV == '3' .and. BTO->BTO_TPCOB  == '1')
			cSql += " AND BDH_PRENDC = '"+BTO->BTO_PREFIX+"'  "
			cSql += " AND BDH_NUMNDC = '"+BTO->BTO_NUMTIT+"'  "
			cSql += " AND BDH_PARNDC = '"+BTO->BTO_PARCEL+"' "
			cSql += " AND BDH_TIPNDC = '"+BTO->BTO_TIPTIT+"'  "
		elseif BTO->BTO_TPMOV == '2' .or. (BTO->BTO_TPMOV == '3' .and. BTO->BTO_TPCOB  == '2')   
			cSql += " AND BDH_PREFIX = '"+BTO->BTO_PREFIX+"'  "
			cSql += " AND BDH_NUMTIT = '"+BTO->BTO_NUMTIT+"'  "
			cSql += " AND BDH_PARCEL = '"+BTO->BTO_PARCEL+"'  "
			cSql += " AND BDH_TIPTIT = '"+BTO->BTO_TIPTIT+"'  "
		endif
		//cSql += " AND BDH_STATUS = '0' "
		cSql += " AND BD6_SITUAC = '1' "
		//cSql += " AND ( BD7_BLOPAG <> '1' OR BD6_MOTBPG IN ('066','067','068'))  " //Itens de NF precisam entrar no arquivo
		cSql += " AND BD6_TIPGUI IN ('01','02','05','06', '10') "
		cSql += " AND BDH.D_E_L_E_T_ = ' ' "
		cSql += " ORDER BY BD6_TIPGUI, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO"	
	else 	
			// QUERY APENAS PARA REAPRESENTAÇÃO
		cSql := " SELECT BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_TIPGUI, BD6_CODRDA, BD7_CODPAD, BD7_CODPRO, BD7_SEQUEN, BD7_CODUNM,"
		cSql += " BD7_NLANC, BD7_CDPFPR, BD7_SIGLA, BD7_REGPRE, BD7_ESTPRE, BD7_ESPEXE, BD7_CODTPA, BD7_CODESP, BD7_VLRTPF, BD7_VLRTAD, BD7_CODRDA "
		cSql += " FROM " + cBD6Name + " BD6 "
		cSql += " LEFT JOIN " + cBCIName + " BCI "
		cSql += " ON  BCI.BCI_FILIAL ='" + xFilial("BCI")+"' "
		cSql += " AND BCI.BCI_CODOPE = BD6.BD6_CODOPE "
		cSql += " AND BCI.BCI_CODLDP = BD6.BD6_CODLDP "
		cSql += " AND BCI.BCI_CODPEG = BD6.BD6_CODPEG "
		cSql += " AND BCI.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + cBD7Name + " BD7 "		
		cSql += " ON BD7_FILIAL = BD6_FILIAL  "
		cSql += " AND BD7_CODOPE = BD6_CODOPE  "
		cSql += " AND BD7_CODLDP = BD6_CODLDP  "
		cSql += " AND BD7_CODPEG = BD6_CODPEG  "
		cSql += " AND BD7_NUMERO = BD6_NUMERO  "
		cSql += " AND BD7_ORIMOV = BD6_ORIMOV  "
		cSql += " AND BD7_SEQUEN = BD6_SEQUEN  "	
		cSql += " AND BD7.D_E_L_E_T_ = ' '  "
		cSql += " WHERE BD6.BD6_FILIAL ='" + xFilial("BD6")+"' "
		cSql += " AND BCI.BCI_LOTEDI ='" + "BTO|"+ BTO->BTO_NUMERO + "' "
		cSql += " AND BD6.D_E_L_E_T_ = ' ' "
		cSql += " AND BD6_TIPGUI IN ('01','02','05','06', '10') "
		cSql += " AND BD6_FASE  = '3' "
	endif

		cISql := " Insert Into " +  oTmpBase:getrealName() + " (CODOPE,CODLDP,CODPEG,NUMERO,ORIMOV,TIPGUI,CODRDA,CODPAD,CODPRO,SEQUEN,"
		cISql += "CODUNM,NLANC,CDPFPR,SIGLA,REGPRE,ESTPRE,ESPEXE,CODTPA,CODESP,VLRTPF,VLRTAD,BD7_CODRDA) " + cSql 

	PLSCOMMIT(cISql)

	setProcedimentos(cDatabase)

	cSql := "SELECT COUNT(*) QTD FROM (SELECT CODPEG, NUMERO FROM " + oTmpBase:getrealName() + " GROUP BY CODPEG, NUMERO ) A
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbFim",.F.,.T.)
	nTotReg 	 := TrbFim->QTD	
	TrbFim->(dbCloseArea())	
	if nTotReg > 0
		processa(aParam,aMsg,@nRecnoD2,nTotReg,.f.,lAuto)
	else
		aadd(aMsg,{BTO->BTO_OPEORI, BTO->BTO_NUMERO, "Nenhuma guia encontrada."})	
	endif 
    
	BTO->(recLock("BTO",.f.))
	BTO->BTO_ENV500 = '1'
	BTO->(msUnLock())
	if nRecnoD2 > 0
		BTO->(dbgoto(nRecnoD2))
		BTO->(recLock("BTO",.f.))
		BTO->BTO_ENV500 = '1'
		BTO->(msUnLock())
	endif
	
	(cAliasBTO)->(dbskip())
enddo
cElapsed := ElapTime( CINI, TIME() ) 
if !lAuto .and. len(aMsg) > 0
	PLSCRIGEN(aMsg,{ {"Unimed","@C",6},{"Lote","@C",8},{"Mensagem","@C",250} }, "Log de Exportação",NIL,NIL,NIL,NIL, NIL,NIL,"G",220) 
endif 

(cAliasBTO)->(dbclosearea())
(cAliPrc)->(dbclosearea())
(cAliTmp)->(dbclosearea())

oTmpProc:Delete()
freeObj(oTmpProc)               
oTmpProc := nil

oTmpBase:Delete()
freeObj(oTmpBase)               
oTmpBase := nil

return

//-------------------------------------------------------------------
/*/{Protheus.doc} processa 
Processa e gera o XML do PTU A500

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
static function processa(aParam,aMsg,nRecnoD2,nTotReg,lAviso,lAuto)
local oPTU		:= PTUA500():New()
local cSql		:= ""
local cAlias 	:= getNextAlias()
local nValIR 	:= 0
local nRecnoB	:= 0
local nRecnoS	:= 0
local nQtd		:= 0
local nQtdX		:= 0
local nL		:= 1
local aNFE 		:= {}
Local lCmpTiss4 := BD5->(FieldPos("BD5_TMREGA")) > 0 .AND. BD5->(FieldPos("BD5_SAUOCU")) > 0 .AND. BD5->(FieldPos("BD5_COBESP")) > 0
local cGuiOrg	:= "A"
default lAuto 	:= .f.
default lAviso 	:= .f.

lIdUnico2 := BX6->(fieldPos("BX6_IDUNI2")) > 0

BZC->(dbSetOrder(1)) // Indicação Clinica
BR8->(dbSetOrder(1)) // Procedimentos
SE1->(dBSetOrder(1)) // Contas a Receber
B2S->(dbSetOrder(1)) // Cabecalho Envio Lote
B5S->(dbSetOrder(2)) // Cabeç. Guias Lote Aviso-Envio
B6S->(dbSetOrder(1)) // Itens Guias Lote Aviso-Envio
BGR->(dbSetOrder(1)) // Via de Acesso
BA8->(dbSetOrder(1)) // Procedimentos
BD4->(dbSetOrder(1)) // Unidade de Saude
SA2->(dbSetOrder(1)) // Fornecedor
SF1->(dbSetOrder(1)) // NFE
BI4->(dbSetOrder(1)) // Tipo de acomodação
BE4->(dbSetOrder(1)) // Internações

iif(!lAuto,oPTU:SetVersao(aParam[1]),oPTU:SetVersao("2"))
iif(oPTU:lVersAtual==.T.,oPTU:cVersao := "V2_0",oPTU:cVersao) //Seta versão do schema

oPTU:Inifile("ptuA500")
oPTU:cFolder    := alltrim(aParam[2])
oPTU:lAuto 		:= lAuto
oPTU:lAviso		:= lAviso

oPTU:MontaTag( 1,"cabecalho")
oPTU:MontaTag( 2,"nrVerTra_PTU",iif(oPTU:lVersAtual==.T.,"03","02") ) // Atualmente só tem essa versão, mas futuramente vai pegar a ultima ou a penultima, perguntado em tela //
oPTU:MontaTag( 2,"unimed")
oPTU:MontaTag( 3,"cd_Uni_Destino",iif(lAviso,B2S->B2S_OPEORI,BTO->BTO_OPEORI))
oPTU:MontaTag( 3,"cd_Uni_Origem",cCodInt)
oPTU:MontaTag( 2,"unimed",,.T.)

oPTU:MontaTag( 2,"dadosAvisoCobranca")
if !lAviso
	if lPLSR506
		aNFE := execBlock("PLSR506",.F.,.F.,{"1"})
		cNumTitBTO  := alltrim(  aNFE[3] )
	else
		cNumTitBTO  := alltrim(BTO->BTO_NUMTIT)
	endif

	if len(cNumTitBTO) > 7
		oPTU:cFileName 	:= "N" + substr(cNumTitBTO, len(cNumTitBTO)-6,7)
	elseif len(cNumTitBTO) < 7
		oPTU:cFileName     := "N" + Replicate("_",7-len(cNumTitBTO))+cNumTitBTO
	else
		oPTU:cFileName     := "N" + strzero(val(Iif(!empty(cNumTitBTO),cNumTitBTO,BTO->BTO_NUMTIT)),7)
	endIf
	if VerifIRRF(BTO->BTO_OPEORI)
		nValIR := noround(SE1->E1_IRRF,2)
	endif
	oPTU:MontaTag( 3,"Cobranca")
	oPTU:MontaTag( 4,"dt_Geracao",dtos(date()))
	oPTU:MontaTag( 4,"nr_Competencia",substr(BTO->BTO_ANOINI,3,2)+BTO->BTO_MESINI)
	oPTU:MontaTag( 4,"tp_Cobranca",BTO->BTO_TPMOV)
	oPTU:MontaTag( 4,"documento1")
	oPTU:MontaTag( 5,"tp_Documento",iif(lPLSR506,"3",tp_doc(BTO->BTO_TPMOV)))
	oPTU:MontaTag( 5,"nr_Documento",iif(lPLSR506,cNumTitBTO,BTO->BTO_PREFIX + BTO->BTO_NUMTIT))
	oPTU:MontaTag( 5,"dt_VencimentoDoc",dtos(SE1->E1_VENCTO))
	oPTU:MontaTag( 5,"dt_EmissaoDoc",dtos(SE1->E1_EMISSAO))
	oPTU:MontaTag( 5,"vl_TotalDoc",str(iif(BTO->BTO_TPMOV=='3',BTO->BTO_VLRTAX,BTO->BTO_CUSTOT)))
	oPTU:MontaTag( 5,"doc_Fiscal",iif(lPLSR506,cNumTitBTO,BTO->BTO_PREFIX + BTO->BTO_NUMTIT))

	if lPLSR506
		if !empty(aNFE[1])
			oPTU:MontaTag( 5,"NFE")
			oPTU:MontaTag( 6,"nr_NotaFiscalDoc",aNFE[1])
			oPTU:MontaTag( 6,"link_NFeDoc",aNFE[2])
			oPTU:MontaTag( 5,"NFE",,.T. )
		endif
	endif

	if nValIR > 0
		oPTU:MontaTag( 5,"VL_IR",str(nValIR))
	endif
	oPTU:MontaTag( 4,"documento1",,.T.)

	if BTO->BTO_TPMOV == '3'
		cKeyBTO := BTO->(BTO_FILIAL+BTO_CODOPE+BTO_NUMERO+BTO_OPEORI)
		nRecnoB	:= BTO->(recno())
		nRecnoS := SE1->(recno())
		BTO->(dbSkip())
		while cKeyBTO == xFilial("BTO")+BTO->(BTO_CODOPE+BTO_NUMERO+BTO_OPEORI) .and. !BTO->(eof())
			nRecnoD2 := BTO->(Recno())
			if !SE1->(msseek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)))
				lFoundFAT := .F.
			else
				lFoundFAT := .T.
			endif

			if !lFoundFAT
				aadd(aMsg,{BTO->BTO_OPEORI, BTO->BTO_NUMERO, "Titulo não encontrado" + BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)})
				BTO->(dbSkip())
				loop
			endif

			if lPLSR506
				aNFE := execBlock("PLSR506",.F.,.F.,{"2"})
			endif

			oPTU:MontaTag( 4,"documento2")
			oPTU:MontaTag( 5,"tp_Documento",iif(lPLSR506,"3",tp_doc(BTO->BTO_TPMOV)))
			oPTU:MontaTag( 5,"nr_Documento",iif(lPLSR506,aNFE[3],BTO->BTO_PREFIX + BTO->BTO_NUMTIT))
			oPTU:MontaTag( 5,"dt_VencimentoDoc",dtos(SE1->E1_VENCTO) )
			oPTU:MontaTag( 5,"dt_EmissaoDoc",dtos(SE1->E1_EMISSAO))
			oPTU:MontaTag( 5,"vl_TotalDoc",str(BTO->BTO_VLRCOP + BTO->BTO_VLRCP2) )
			oPTU:MontaTag( 5,"doc_Fiscal",iif(lPLSR506,aNFE[3],BTO->BTO_PREFIX + BTO->BTO_NUMTIT))
			if lPLSR506
				if !empty(aNFE[1])
					oPTU:MontaTag( 5,"NFE")
					oPTU:MontaTag( 6,"nr_NotaFiscalDoc",aNFE[1])
					oPTU:MontaTag( 6,"link_NFeDoc",aNFE[2])
					oPTU:MontaTag( 5,"NFE",,.T. )
				endif
			endif
			oPTU:MontaTag( 4,"documento2",,.T.)
			BTO->(dbSkip())
		enddo
		BTO->(dbgoto(nRecnoB))
		SE1->(dbgoto(nRecnoS))
	endif
	oPTU:MontaTag( 3,"Cobranca",,.T.)
else
	oPTU:cFileName := getNomArq()
	oPTU:MontaTag( 3,"Aviso")
	oPTU:MontaTag( 4,"dt_Geracao",dtos(date()))
	oPTU:MontaTag( 4,"nr_Competencia",substr(dtos(B2S->B2S_DATTRA),3,2)+substr(dtos(B2S->B2S_DATTRA),5,2))
	oPTU:MontaTag( 3,"Aviso",,.T.)
endif
oPTU:MontaTag( 2,"dadosAvisoCobranca",,.T.)

oPTU:MontaTag( 1,"cabecalho",,.T.)

oPTU:MontaTag( 1,"arquivoA500")
oPTU:MontaTag( 2,"Tipoguia")
oPTU:aMsg := aClone(aMsg)
oPTU:iniGuia()

for nL := 1 to 4
	if nL == 1 .or. nL == 3 .or. nL == 4
		cSql := " SELECT BD5_CODOPE CODOPE, BD5_CODLDP CODLDP, BD5_CODPEG CODPEG, BD5_NUMERO NUMERO, BD5_TIPGUI TIPGUI, BD5_CODRDA CODRDA, BD5_NUMIMP NUMIMP, "
		cSql += " BD5_DATPRO DATPRO, BD5_HORPRO HORPRO, BD5_GUIJUR GUIJUR, BD5_INDCLI INDCLI, BD5_INDCL2 INDCL2, BD5_ANOAUT ANOAUT, BD5_MESAUT MESAUT, "
		cSql += " BD5_GUIINT GUIINT, BD5_TISVER TISVER, BD5_ATERNA IDRN, BD5_TIPPAC TIPPAC, BD5_INDACI INDACI, BD5_NRAOPE NRAOPE, BD5_NOMRDA NOMRDA, "
		cSql += " BD5_CODLOC CODLOC, BD5_REGEXE REGEXE, BD5_CODESP CODESP, BD5_TIPCON TIPCON, BD5_DATSOL DATSOL, BD5_SENHA SENHA, BD5_TIPATE TIPATE,  "
		cSql += " BD5_NUMAUT NUMAUT, BD5_TIPADM TIPADM, BD5_GUIPRI GUIPRI, BD5_REGSOL REGSOL, BD5_TPGRV TPGRV, ' ' DTINIF, ' ' HRINIF, ' ' DTFIMF, "
		cSql += " ' ' HRFIMF, ' ' DTALTA, ' ' HRALTA, BD5_CID CID,  BD5_NRAEMP NRAEMP, BD5_NOMUSR NOMUSR, BD5_CDPFSO CDPFSO, BD5_NOMSOL NOMSOL, "
		cSql += " BD5_SIGLA SIGLA, BD5_ESTSOL ESTSOL, BD5_CNESED CNESED,BD5_MUNEDI MUNEDI, "
		if lCmpTiss4
			cSql += " BD5_TMREGA TMREGA, BD5_SAUOCU SAUOCU, BD5_COBESP COBESP, "
		endif
		cAliCab := 'BD5'
	else
		cSql := " SELECT BE4_CODOPE CODOPE, BE4_CODLDP CODLDP, BE4_CODPEG CODPEG, BE4_NUMERO NUMERO, BE4_TIPGUI TIPGUI, BE4_CODRDA CODRDA, BE4_SENHA SENHA, "
		cSql += " BE4_NUMIMP NUMIMP, BE4_DATPRO DATPRO, BE4_HORPRO HORPRO, BE4_GUIJUR GUIJUR, BE4_INDCLI INDCLI, BE4_INDCL2 INDCL2, BE4_ANOINT ANOINT, "
		cSql += " BE4_MESINT MESINT, BE4_NUMINT NUMINT, BE4_GUIINT GUIINT, BE4_TISVER TISVER, BE4_ATENRN IDRN, '1' TIPPAC, BE4_DATPRO DATSOL, '' TIPATE, "
		cSql += " BE4_NOMRDA NOMRDA, BE4_CODLOC CODLOC, BE4_REGEXE REGEXE, BE4_CODESP CODESP, BE4_TIPCON TIPCON, BE4_INDACI INDACI, BE4_NRAOPE NRAOPE, "
		cSql += " BE4_TIPADM TIPADM, BE4_GUIINT GUIPRI, BE4_REGSOL REGSOL, BE4_TPGRV TPGRV, BE4_DTINIF DTINIF, BE4_HRINIF HRINIF, BE4_DTFIMF DTFIMF,
		cSql += " BE4_HRFIMF HRFIMF, BE4_DTALTA DTALTA, BE4_HRALTA HRALTA, BE4_PADINT, BE4_REGINT, BE4_GRPINT, BE4_TIPALT, BE4_CIDOBT, BE4_NRDCOB, "
		cSql += " BE4_TIPFAT, BE4_NRDCNV, BE4_CID CID, BE4_NMAUDI, BE4_RMAUDI, BE4_NEAUDI, BE4_REAUDI, BE4_NRAEMP NRAEMP, BE4_NOMUSR NOMUSR, BE4_CDPFSO CDPFSO, "
		cSql += " BE4_SIGLA SIGLA, BE4_ESTSOL ESTSOL, BE4_NOMSOL NOMSOL,BE4_CNESED CNESED,BE4_MUNEDI MUNEDI, "
		cSql += iif(BE4->(fieldpos("BE4_UMAUDI")) > 0, "BE4_UMAUDI ", "' ' ")	+ " UMAUDI, "
		cSql += iif(BE4->(fieldpos("BE4_UEAUDI")) > 0, "BE4_UEAUDI ", "' ' ")	+ " UEAUDI, "
		cAliCab := 'BE4'
	endif
	cSql += " BX6_NOMFOR, BX6_CNPJFO, BX6_NNFFOR, BX6_DREANV, BX6_REGANV, BX6.R_E_C_N_O_ RecnoBx6, BX6_IDUNIC, BX6_SEQPTU," + iif(lIdUnico2,"BX6_IDUNI2,","")
	cSql += " BD6_CODPAD, BD6_CODPRO, BD6_VLRPF, BD6_QTDPRO, BD6_DESPRO, BD6_MATANT, BD6_PACOTE,BD6_CD_PAC, BD6_CPFRDA, BD6_DTDIGI, BD6_CODEMP, BD6_PERTAD, "
	cSql += " BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, BD6_ORIMOV, BD6_SEQUEN, BD6_HORFIM, BD6_HORPRO, BD6_VIA, BD6_PERHES, BX6_CODUNM, BD6_CODTAB, BD6_DATPRO, "
	cSql += " BD6_REFFED, BD6_NFE, BD6_PROCCI, BD6_VLRTAD, BD6_TECUTI, BD6_ESPSOL, BD6_ESPEXE, BD6_OPEUSR,BD6_CODRDA,BD6_CONEMP,BD6_VERCON,BD6_SUBCON,BD6_VERSUB,BD6_RDAEDI RDAEDI ,BD6_NOMEDI NOMEDI,BD6_CNPJED CNPJED ,BD6_TRDAED TRDAED,BD6_RPEDI RPEDI "
	cSql += " FROM (SELECT CODOPE, CODLDP, CODPEG, NUMERO, ORIMOV, TIPGUI, CODRDA, SEQUEN FROM " + oTmpBase:getrealName()
	cSql += " GROUP BY CODOPE, CODLDP, CODPEG, NUMERO, ORIMOV, TIPGUI, CODRDA, SEQUEN) A "
	cSql += " INNER JOIN " + cBD6Name + " BD6 "
	cSql += " ON BD6_FILIAL =  '" + xfilial("BD6") + "' "
	cSql += " AND BD6_CODOPE = CODOPE "
	cSql += " AND BD6_CODLDP = CODLDP "
	cSql += " AND BD6_CODPEG = CODPEG "
	cSql += " AND BD6_NUMERO = NUMERO "
	cSql += " AND BD6_ORIMOV = ORIMOV "
	cSql += " AND BD6_SEQUEN = SEQUEN "
	cSql += " AND BD6.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN "+ retSqlName(cAliCab) + " " + cAliCab
	cSql += " ON  "+cAliCab+"_FILIAL = BD6_FILIAL "
	cSql += " AND "+cAliCab+"_CODOPE = BD6_CODOPE "
	cSql += " AND "+cAliCab+"_CODLDP = BD6_CODLDP "
	cSql += " AND "+cAliCab+"_CODPEG = BD6_CODPEG "
	cSql += " AND "+cAliCab+"_NUMERO = BD6_NUMERO "
	cSql += " AND "+cAliCab+".D_E_L_E_T_ = ' ' "
	cSql += " LEFT JOIN " + cBX6Name + " BX6 "
	cSql += " ON  BX6_FILIAL = '" + xfilial("BX6") + "' "
	cSql += " AND BX6_CODOPE = BD6.BD6_CODOPE "
	cSql += " AND BX6_CODLDP = BD6.BD6_CODLDP "
	cSql += " AND BX6_CODPEG = BD6.BD6_CODPEG "
	cSql += " AND BX6_NUMERO = BD6.BD6_NUMERO "
	cSql += " AND BX6_ORIMOV = BD6.BD6_ORIMOV "
	cSql += " AND BX6_SEQUEN = BD6.BD6_SEQUEN "
	cSql += " AND BX6.D_E_L_E_T_ = ' ' "
	iif(!lAviso,  cSql += " WHERE BD6_SEQPF <> ' ' ",)
	if nL == 1 .or. nL == 3 .or. nL == 4
		iif(lAviso,  cSql += " WHERE BD5_TIPGUI",cSql += " AND BD5_TIPGUI")
		if nL == 1
			cSql += " IN ('01','02') "
		elseif nL == 3
			cSql += " = '06' "
		elseif nL == 4
			cSql += " = '10' "	
		endif
	endif
	cSql += " ORDER BY BD6_TIPGUI, CODLDP, CODPEG, NUMERO "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)
	oPTU:cAlias := cAlias

	while !(cAlias)->(eof())
		nQtd++
		nQtdX++
		oPTU:lBlcReap 	:= .f.
		oPTU:cBlcReTpI	:= ""
		oPTU:lInt4Reap	:= .f.

		if nTotReg <= 10
			oProcess:incRegua2( "[" + cvaltochar(nQtd) +  "] de [" + cvaltochar(nTotReg) + "]"  )
		elseif nQtdX == 5 .or. nQtd == nTotReg .or. nQtd == 1
			oProcess:incRegua2( "[" + cvaltochar(nQtd) +  "] de [" + cvaltochar(nTotReg) + "]"  )
			nQtdX := 0
		endif

		if (cAlias)->TIPGUI == GUIA_REC_GLOSA
			cGuiOrg := oPTU:PRecupTipGui("T")
			oPTU:lBlcReap 	:= .t.
			oPTU:cBlcReTpI 	:= "I"
			oPTU:lInt4Reap	:= iif(cGuiOrg == GUIA_INTERNACAO, .t., .f.)
		endif	

		If lReapTPJ
			oPTU:lBlcReap 	:= .t.
			oPTU:cBlcReTpI 	:= "J"
		endif

			if (cAlias)->TIPGUI == GUIA_CONSULTA .or. cGuiOrg == GUIA_CONSULTA 
			oPTU:Consulta()
		elseif (cAlias)->TIPGUI == GUIA_SADT .or. cGuiOrg == GUIA_SADT
			oPTU:SADT()
		elseif (cAlias)->TIPGUI == GUIA_INTERNACAO .or. cGuiOrg == GUIA_INTERNACAO
			oPTU:Internacao()
		elseif (cAlias)->TIPGUI == GUIA_HONORARIO .or. cGuiOrg == GUIA_HONORARIO
			oPTU:Honorario()
		endif

		oPTU:fimGuia()

		//(cAlias)->(dbskip())
	enddo
	(cAlias)->(dbclosearea())
next
oPTU:MontaTag( 2,"Tipoguia",,.T. )
oPTU:MontaTag( 1,"arquivoA500",,.T. )
oPTU:CalcHash()
oPTU:MontaTag( 1,"hash",oPTU:cHashMD5 )
oPTU:MontaTag( 0,"ptuA500",,.T. )
oPTU:geraXML(.t.)

aMsg := aClone(oPTU:aMsg)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method New() class PTUA500
::cOpeDes	:= ""
::cXml		:= ""
::cCabXml	:= ""
::cEndXml	:= ""
::cNameSpace:= "ptu"
::cStrHash	:= ""
::cHashMD5  := ""
::cFolder   := ""
::cFileName := ""
::cGuiOpe  	:= ""
::cAvisoXML := ""
::cSchmFolde:= ""
::cSchema   := "ptu_A500.xsd"
::cVersao   := "V1_1"
::lAuto     := .F. 
::lAviso    := .F. 
::aMsg 		:= {}
::lVersAtual:= .T.
::cAlias	:= ""
::nArqFull	:= 0
::nArqHash	:= 0
::nArqLog 	:= 0
::lBlcReap		:= .f.
::lInt4Reap		:= .f.
::cBlcReTpI		:= ""
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method Consulta() class PTUA500
local cAlias 	:= ::cAlias
local cCodPeg	:= (cAlias)->CODPEG
local cNumGui	:= (cAlias)->(CODLDP + CODPEG + NUMERO)

::MontaTag( 3,"guiaConsulta")

::Beneficiario()
::contratadoExecutante(GUIA_CONSULTA)
::profissionalExecutante()
::dadosGuia(GUIA_CONSULTA)
if ::lBlcReap
	::PBlocoReapre(cCodPeg,BTO->BTO_PREFIX + BTO->BTO_NUMTIT,,cNumGui)
endif
::MontaTag( 3,"guiaConsulta",,.T. )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} SADT

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method SADT() class PTUA500
local cAlias 	:= ::cAlias
local cTpAdm 	as char
local cCodPeg	:= (cAlias)->CODPEG
local cNumGui	:= (cAlias)->(CODLDP + CODPEG + NUMERO)

::MontaTag( 3,"guiaSADT")

::Beneficiario()
::Solicitante()
::contratadoExecutante(GUIA_SADT)

cTpAdm 	:=  PLSGETVINC("BTU_CDTERM", "BDR", .F., "23", (cAlias)->TIPADM, .F.)
::MontaTag( 4,"dadosAtendimento" )
::MontaTag( 5,"tp_Atendimento",ifPls((cAlias)->TIPATE,'05')) 
::MontaTag( 5,"tp_IndAcidente",iif(empty((cAlias)->INDACI),"9",(cAlias)->INDACI))
::MontaTag( 5,"tp_Consulta",iif((cAlias)->TIPCON == '5','2',(cAlias)->TIPCON))
::MontaTag( 5,"caraterAtendimento",cTpAdm)
if ::lVersAtual .and. (cAlias)->TISVER >= "4.00.00"
	if alltrim(cTipPre) == "08" .and. !empty((cAlias)->COBESP)
		::MontaTag( 5,"coberturaEspecial","02")
	else 
		::MontaTag( 5,"coberturaEspecial",ifPls((cAlias)->COBESP,""))
	endif 
	::MontaTag( 5,"saudeOcupacional" ,ifPls((cAlias)->SAUOCU,""))
	::MontaTag( 5,"coberturaEspecial",ifPls((cAlias)->COBESP,""))
endif
::MontaTag( 4,"dadosAtendimento",,.T. )
::dadosGuia(GUIA_SADT)
if ::lBlcReap
	::PBlocoReapre(cCodPeg,BTO->BTO_PREFIX + BTO->BTO_NUMTIT,,cNumGui)
endif
::MontaTag( 3,"guiaSADT",,.T. )
return

//-------------------------------------------------------------------
/*/{Protheus.doc} Internacao

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method Internacao() class PTUA500
local cAlias 	:= ::cAlias
local cTipAco	:= ""
local cTpFat	:= ""
local cFatmul   := "1.0"
local nX 		:= 1
local cCodPeg	:= (cAlias)->CODPEG
local cNumGui	:= (cAlias)->(CODLDP + CODPEG + NUMERO)
local cBkpAlias	:= cAlias
local lUEAUDI	:= BE4->(fieldpos("BE4_UEAUDI")) > 0
local lUMAUDI	:= BE4->(fieldpos("BE4_UMAUDI")) > 0
local lBE4GRIRP	:= .f.
local aAreaBE4	:= BE4->(getarea())

if ::lBlcReap .and. ::lInt4Reap //r7
	cNumGuiO := ::PRecupTipGui("N")
	BE4->(DbSetOrder(1))
	BE4->(DbSeek( xFilial("BE4") + cNumGuiO))
	cAlias := "BE4"
	lBE4GRIRP := .t.
endif

//Preenchendo as variáveis, que poedms er diferentes devido ao alis utilizado
cTipAdmI 	:= (cAlias)->&(iif(lBE4GRIRP, "BE4_TIPADM", "TIPADM"))
cIDRNI		:= (cAlias)->&(iif(lBE4GRIRP, "BE4_ATENRN", "IDRN"))
cINDACI		:= (cAlias)->&(iif(lBE4GRIRP, "BE4_INDACI", "INDACI"))
cCIDI		:= (cAlias)->&(iif(lBE4GRIRP, "BE4_CID", "CID"))
cUEAUDI		:= iif(lUEAUDI, (cAlias)->&(iif(lBE4GRIRP, "BE4_UEAUDI", "UEAUDI")), "")
cUMAUDI		:= iif(lUMAUDI, (cAlias)->&(iif(lBE4GRIRP, "BE4_UMAUDI", "UMAUDI")), "")

if !(cAlias)->BE4_REGINT == '3' .and. BI4->(MsSeek( xFilial("BI4")+(cAlias)->BE4_PADINT ))
	
	cFatmul := Strtran(Alltrim(Transform(BI4->BI4_FATMUL, "@E 99.99")),",",".")
	
	Do Case
		Case BI4->BI4_CODEDI == "1" // Apartamento(Individual)
			cTipAco := "B"
		Case BI4->BI4_CODEDI == "2" // Enfermaria(Coletiva) 
			cTipAco := "A"
		Case BI4->BI4_CODEDI $ "3/4"// Não se aplica 
			cTipAco := "C"
	endcase
endif

if empty((cAlias)->BE4_TIPFAT) .or.  (cAlias)->BE4_TIPFAT $ 'TP' 
	cTpFat := iif((cAlias)->BE4_TIPFAT=="P","2","1" )
else
	if (cAlias)->BE4_TIPFAT == "1"  // Parcial  é 2 no Layout
		cTpFat := "2"
	elseif (cAlias)->BE4_TIPFAT =="2" //Final é 3 no Layout
		cTpFat := "3"
	elseif	(cAlias)->BE4_TIPFAT =="3" //Complementar é 4 no Layout
		cTpFat := "4"
	elseif	(cAlias)->BE4_TIPFAT =="4" //Total é 1 no Layout	
		cTpFat := "1"
	Endif

endif

aNrDocNasc 	:= StrTokArr( alltrim((cAlias)->BE4_NRDCNV), "," )	

aRet := getInternacao(cBkpAlias)

::MontaTag( 3,"guiaInternacao")
::Beneficiario()
::Solicitante()
::contratadoExecutante(GUIA_INTERNACAO)
::MontaTag( 4,"dadosInternacao")
::MontaTag( 5,"tp_Acomodacao",cTipAco) 
::MontaTag( 5,"ft_Multiplicador_AMB",cFatmul)
::MontaTag( 5,"tp_Internacao",(cAlias)->(BE4_GRPINT))
::MontaTag( 5,"rg_Internacao",(cAlias)->(BE4_REGINT))
::MontaTag( 5,"caraterAtendimento",PLSGETVINC("BTU_CDTERM", "BDR", .F., "23", cTipAdmI, .F.))
::MontaTag( 5,"dadosFaturamento")
::MontaTag( 6,"tp_Faturamento",cTpFat )
::MontaTag( 6,"dt_IniFaturamento",aRet[1])
::MontaTag( 6,"dt_FimFaturamento",aRet[2])
::MontaTag( 5,"dadosFaturamento",,.T. )
if len(aNrDocNasc) > 0 .or. !empty((cAlias)->BE4_NRDCOB)
	while nX == 1 .or. len(aNrDocNasc) >= nX
		::MontaTag( 5,"dadosDeclaracoes")
		::MontaTag( 6,"declaracao_Nascido",iif(len(aNrDocNasc)>0,aNrDocNasc[nX],''))
		::MontaTag( 6,"CID_Obito",(cAlias)->BE4_CIDOBT)
		::MontaTag( 6,"declaracao_Obito",(cAlias)->BE4_NRDCOB)
		::MontaTag( 6,"indicadorDO_RN",PLSSorN(cIDRNI))
		::MontaTag( 5,"dadosDeclaracoes",,.T. )
		nX++
	enddo
endif
::MontaTag( 4,"dadosInternacao",,.t.)

::MontaTag( 4,"dadosSaidaInternacao")
::MontaTag( 5,"tp_IndAcidente",ifPls(cINDACI,"9")) 
::MontaTag( 5,"mv_Encerramento",PLSGETVINC("BTU_CDTERM", "BIY", .F., "39", (cAlias)->BE4_TIPALT)) 
::MontaTag( 5,"CID",cCIDI)
::MontaTag( 4,"dadosSaidaInternacao",,.T. )

if !empty((cAlias)->BE4_NMAUDI + (cAlias)->BE4_RMAUDI + cUMAUDI + (cAlias)->BE4_NEAUDI + (cAlias)->BE4_REAUDI + cUEAUDI) 
	::MontaTag( 4,"dadosAuditoria")
	::MontaTag( 5,"nm_MedicoAuditor",(cAlias)->BE4_NMAUDI) 
	::MontaTag( 5,"nr_CrmAuditor",(cAlias)->BE4_RMAUDI)
	::MontaTag( 5,"cd_UFCRM",PLSGETVINC("BTU_CDTERM", "   ", .F., "59", cUMAUDI))
	::MontaTag( 5,"nm_EnfAuditor",(cAlias)->BE4_NEAUDI)
	::MontaTag( 5,"nr_CorenAuditor",(cAlias)->BE4_REAUDI)
	::MontaTag( 5,"cd_UFCoren",PLSGETVINC("BTU_CDTERM", "   ", .F., "59", cUEAUDI)) 
	::MontaTag( 4,"dadosAuditoria",,.T. )
endif
::dadosGuia(GUIA_INTERNACAO)
if ::lBlcReap
	::PBlocoReapre(cCodPeg,BTO->BTO_PREFIX + BTO->BTO_NUMTIT,,cNumGui)
endif
::MontaTag( 3,"guiaInternacao",,.T. )
RestArea(aAreaBE4)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} Honorario

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method Honorario() class PTUA500
local cAlias 	:= ::cAlias
Local aArea		:= {}
local cCnesPE	:= ""
local cCodPeg	:= (cAlias)->CODPEG
local cNumGui	:= (cAlias)->(CODLDP + CODPEG + NUMERO)

aRet := getInternacao(cAlias)

//significa que ficou o BE4_CGCRDA está em brnaco ou com um CPF e que a RDA que solicitou é pessoa física
if empty(aRet[3])
	aArea := BAU->(getArea())
	BAU->(dbsetOrder(1))
	if BAU->( MsSeek( xFilial("BAU") + (cAlias)->CODRDA ) )
		aRet[3] := BAU->BAU_CPFCGC
		aRet[4] := BAU->BAU_NOME
	endif
	RestArea(aArea)
endif

if lPLU5CNES
	cCnesPE := execBlock("PLU5CNES", .f., .f. , {aRet[5], (cAlias)->CODRDA, (calias)})	
endif	
cCnesPE := iif( (lPLU5CNES .and. valtype(cCnesPE) == "C"), cCnesPE, aRet[5])

::MontaTag( 3,"guiaHonorarios")
::Beneficiario()
::MontaTag( 4,"dadosHospital")
::MontaTag( 5,"CNPJHospital",aRet[3])
::MontaTag( 5,"nm_Hospital",aRet[4])
::MontaTag( 5,"CNES", cCnesPE)
::MontaTag( 4,"dadosHospital",,.T. )
::contratadoExecutante(GUIA_HONORARIO)
::MontaTag( 4,"dataFaturamento")
::MontaTag( 5,"dt_IniFaturamento",aRet[1])
::MontaTag( 5,"dt_FimFaturamento",aRet[2])
::MontaTag( 4,"dataFaturamento",,.T. )
::dadosGuia(GUIA_HONORARIO)
if ::lBlcReap
	::PBlocoReapre(cCodPeg,BTO->BTO_PREFIX + BTO->BTO_NUMTIT,,cNumGui)
endif
::MontaTag( 3,"guiaHonorarios",,.T. )
return

//-------------------------------------------------------------------
/*/{Protheus.doc} Beneficiario

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method Beneficiario() class PTUA500
local cAlias 	:= ::cAlias
local cMatric	:= (cAlias)->BD6_MATANT

if empty(cMatric) .or. (BTO->BTO_OPEORI == cOpePEA ) //Se for PEA não deve exportar a (BD6_MATANT)
	BA1->(dbSetOrder(2))
	if BA1->(MsSeek(xFilial("BA1")+(cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG))) .and. !empty(BA1->BA1_MATEDI)
		cMatric	:= BA1->BA1_MATEDI
	else		
		cMatric	:= iif(::lAviso,B2S->B2S_OPEORI,BTO->BTO_OPEORI)  + "9999999999999"		
	endif
endif

::MontaTag( 4,"dadosBeneficiario")
::MontaTag( 5,"cd_Unimed",substr(cMatric,1,4)) 
::MontaTag( 5,"id_Benef",substr(cMatric,5,15))
::MontaTag( 5,"nm_Benef",substr((cAlias)->NOMUSR,1,25),,.t.)
::MontaTag( 5,"id_RN",PLSSorN((cAlias)->IDRN))
::MontaTag( 5,"tp_Paciente",(cAlias)->TIPPAC)
::MontaTag( 4,"dadosBeneficiario",,.T. )
return

//-------------------------------------------------------------------
/*/{Protheus.doc} contratadoExecutante

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method contratadoExecutante(cTipGui) class PTUA500
local cTag 		as char
local cSql 		as char
local cAlias 	:= ::cAlias
local cCnesPE	:= ""
local cUniPre   := ""
local cCodPre   := ""
local cNomRDAEx := ""
local cCPFCGCEx := ""
local cMuniEx   := ""
local cRecProEx := ""
local lPea 		:= BTO->BTO_OPEORI == cOpePEA 

//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
cSql := " SELECT BB8_CNES, BB8_CODMUN, BAU_TIPRED, BAU_TIPPRE, BAU_RECPRO, BAU_CPFCGC, BAU_CNES, BAU_CODOPE FROM " + cBAUName + " BAU "  
cSql += " INNER JOIN " + cBB8Name + " BB8 "  
cSql += " ON BB8_FILIAL 	= '" + xfilial("BB8") + "' " 
cSql += " AND BB8_CODIGO 	= BAU_CODIGO " 
cSql += " AND BB8_CODINT 	= '" + cCodInt + "' " 
cSql += " AND BB8_CODLOC 	= '" + (cAlias)->CODLOC + "' " 
cSql += " AND BB8.D_E_L_E_T_ = ' ' "
cSql += " WHERE BAU_FILIAL 	=  '" + xfilial("BB8") + "' " 
cSql += " AND BAU_CODIGO 	= '" + (cAlias)->CODRDA + "' " 
cSql += " AND BAU.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBAU",.F.,.T.)

if !TrbBAU->(eof())
	cTipPre := posicione("BAG",1,xfilial("BAG")+TrbBAU->BAU_TIPPRE,"BAG_CODPT")

	if cTipGui == GUIA_CONSULTA
		cTag := "contratadoExecutante"
	else
		cTag := "dadosExecutante"
	endif

	cCnes := ifPls(ifPls(TrbBAU->BB8_CNES,TrbBAU->BAU_CNES),"9999999")
	
	if lPLU5CNES
		cCnesPE := execBlock("PLU5CNES", .f., .f. , {cCnes, (cAlias)->CODRDA, (calias)})	
	endif
	cCnesPE := iif( (lPLU5CNES .and. valtype(cCnesPE) == "C"), cCnesPE, cCnes)


	
	cUniPre := iif(TrbBAU->BAU_TIPPRE == "OPE",TrbBAU->BAU_CODOPE,cCodInt) //Unimed do Prestador
	cCodPre := iif( empty((cAlias)->RDAEDI), (cAlias)->CODRDA,(cAlias)->RDAEDI) //Codigo do Prestador

	if lPea 
		cNomRDAEx := iif(!empty((cAlias)->NOMEDI),(cAlias)->NOMEDI,(cAlias)->NOMRDA)
		cCPFCGCEx := iif(!empty((cAlias)->CNPJED),(cAlias)->CNPJED,TrbBAU->BAU_CPFCGC)
		cCnesPE   := iif(!lPLU5CNES,iif(!empty((cAlias)->CNESED),(cAlias)->CNESED,cCnesPE),cCnesPE)
		cMuniEx   := iif(!empty((cAlias)->MUNEDI),(cAlias)->MUNEDI,TrbBAU->BB8_CODMUN)
		cTipPre   := iif(!empty((cAlias)->TRDAED),(cAlias)->TRDAED,cTipPre)
		cRecProEx := iif(!empty((cAlias)->RPEDI),(cAlias)->RPEDI,PLSSorN(TrbBAU->BAU_RECPRO))
	else 
	    cNomRDAEx := (cAlias)->NOMRDA
		cCPFCGCEx := TrbBAU->BAU_CPFCGC
		cMuniEx   := TrbBAU->BB8_CODMUN
		cRecProEx := PLSSorN(TrbBAU->BAU_RECPRO)
	endif

	::MontaTag( 4,cTag )
	::MontaTag( 5,"UnimedPrestador")
	::MontaTag( 6,"cd_Uni_Prest",cUniPre,,.t.)
	::MontaTag( 6,"cd_Prest",cCodPre,,.t.)
	::MontaTag( 5,"UnimedPrestador",,.T.)

	if !::lVersAtual
		::MontaTag( 7,"nome",cNomRDAEx,,.t.)
	endif

	if cTipGui <> GUIA_INTERNACAO
		::MontaTag( 7,"CPF_CNPJ")
		::MontaTag( 8,iif(len(alltrim(cCPFCGCEx)) == 11,'cd_cpf','cd_cnpj'),cCPFCGCEx)
		::MontaTag( 7,"CPF_CNPJ",,.T. )
	else
		::MontaTag( 7,'CNPJ',cCPFCGCEx)
	endif
	::MontaTag( 7,"CNES", cCnesPE)
	::MontaTag( 7,"prestador")
	::MontaTag( 8,"cd_MunicipioCont",cMuniEx)
	::MontaTag( 8,"tp_RedeMin",TrbBAU->BAU_TIPRED)
	::MontaTag( 8,"tp_Prestador",cTipPre)
	::MontaTag( 8,"id_RecProprio",cRecProEx)
	::MontaTag( 7,"prestador",,.T. )
	::MontaTag( 4,cTag,,.t. )

endif
TrbBAU->(dbclosearea())
return

//-------------------------------------------------------------------
/*/{Protheus.doc} profissionalExecutante

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method profissionalExecutante(oPTU) class PTUA500
local cSql 		as char
local cAlias 	:= ::cAlias
local cRegExe   := (cAlias)->REGEXE

if BTO->BTO_OPEORI == cOpePEA //PEA
	cSql := " SELECT REGPRE" 
	cSql += " FROM " + oTmpBase:getrealName() 
	cSql += " WHERE CODOPE = '" + (cAlias)->CODOPE + "' "
	cSql += " AND CODLDP = '" + (cAlias)->CODLDP + "' "
	cSql += " AND CODPEG = '" + (cAlias)->CODPEG + "' "
	cSql += " AND NUMERO = '" + (cAlias)->NUMERO + "' "
	cSql += " AND ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' "
	cSql += " AND SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"TrbBd7",.F.,.T.)

	if !TrbBd7->(eof()) //Todos os BD7 estarão com a informação, então só precisa do primeiro
		cRegExe:= alltrim(TrbBd7->REGPRE)
	endif
	TrbBd7->(dbclosearea())
endif	

if !empty(cRegExe)
	cSql := " SELECT BB0_CGC CGC, BB0_NOME NOME, BB0_CODSIG CODSIG, BB0_NUMCR NUMCR, BB0_ESTADO ESTADO "
	cSql += " FROM " + cBB0Name + " BB0 "  	
	cSql += " WHERE BB0_FILIAL 	=  '" + xfilial("BB0") + "' " 
	cSql += " AND BB0_NUMCR 	= '" + cRegExe + "' " 
	cSql += " AND BB0.D_E_L_E_T_ = ' ' "	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbEXE",.F.,.T.)
else	
	cSql := " SELECT BAU_NOME NOME, BAU_SIGLCR CODSIG, BAU_CONREG NUMCR, BAU_ESTCR ESTADO "
	cSql += " FROM " + cBAUName + " BAU "  
	cSql += " WHERE BAU_FILIAL 	=  '" + xfilial("BAU") + "' " 
	cSql += " AND BAU_CODIGO 	= '" + Alltrim((cAlias)->CODRDA) + "' " 
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbEXE",.F.,.T.)	
endif

if !TrbEXE->(eof())
	cCbos := BAQ->(posicione("BAQ",1,xFilial("BAQ")+cCodInt+alltrim((cAlias)->BD6_ESPEXE),"BAQ_CBOS"))
	if empty(cCbos)
		cCbos := BAQ->(posicione("BAQ",1,xFilial("BAQ")+cCodInt+alltrim((cAlias)->CODESP),"BAQ_CBOS"))
	endif
	::MontaTag( 4,"profissionalExecutante" )
	::MontaTag( 5,"nome",TrbEXE->NOME,,.t.)
	::MontaTag( 5,"dadosConselho")
	::MontaTag( 6,"sg_Conselho",TrbEXE->CODSIG)
	::MontaTag( 6,"nr_Conselho",TrbEXE->NUMCR)
	::MontaTag( 6,"UF",PLSGETVINC("BTU_CDTERM", "   ", .F., "59", TrbEXE->ESTADO) ) 
	::MontaTag( 5,"dadosConselho",,.T. )
	::MontaTag( 5,"CBO",PADL(cCbos,6,"0"))
	::MontaTag( 4,"profissionalExecutante",,.T. )
endif

TrbEXE->(dbclosearea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Solicitante

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method Solicitante() class PTUA500
local cAlias 		:= ::cAlias
local cSql 			as char
local cCbos 		as char
local cNome 		:= ""
local cCodSig		:= ""
local cNumCr 		:= ""
local cUF 			:= ""
local cCGCContra	:= (cAlias)->BD6_CPFRDA
local cNomeContra	:= (cAlias)->NOMRDA
local cSgCDir		:= ""

cNome 	:= (cAlias)->NOMSOL
cCodSig := (cAlias)->SIGLA
cNumCr 	:= (cAlias)->REGSOL
cUF 	:= (cAlias)->ESTSOL

if !empty((cAlias)->CDPFSO)
	cSql := " SELECT BB0_NOME NOME, BB0_CODSIG CODSIG, BB0_NUMCR NUMCR, BB0_ESTADO ESTADO, BB0_CGC "
	cSql += " FROM " + cBB0Name + " BB0 "  	
	cSql += " WHERE BB0_FILIAL 	=  '" + xfilial("BB0") + "' " 
	cSql += " AND BB0_CODIGO 	= '" + (cAlias)->CDPFSO + "' " 
	cSql += " AND BB0.D_E_L_E_T_ = ' ' "	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbSOL",.F.,.T.)

	if !TrbSOL->(eof()) 
		cCGCContra  := TrbSOL->BB0_CGC
		cNomeContra := TrbSOL->NOME
	endif

	cNome 	:= TrbSOL->NOME
	cCodSig := TrbSOL->CODSIG
	cNumCr 	:= TrbSOL->NUMCR
	cUF 	:= TrbSOL->ESTADO

	TrbSOL->(dbclosearea())
else
	cSql := " SELECT BAU_NOME, BAU_CPFCGC, BAU_SIGLCR, BAU_CONREG, BAU_ESTCR, BAU_SIGDIR, BAU_DIRREG, BAU_UFCDIR, BAU_TIPPE, BAU_DIRTEC"
	cSql += " FROM " + cBAUName + " BAU"
	cSql += " WHERE BAU_FILIAL = '" + xfilial("BAU") + "'"
	cSql += " AND BAU_CODIGO = '" + (cAlias)->CODRDA + "'"
	cSql += " AND BAU.D_E_L_E_T_ = ' '"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBAU",.F.,.T.)

	cSgCDir 	:= SigConsReg(TrbBAU->BAU_SIGDIR)
	cCGCContra	:= TrbBAU->BAU_CPFCGC
	cNomeContra	:= TrbBAU->BAU_NOME
	
	if TrbBAU->BAU_TIPPE == 'F'
		cNome		:= TrbBAU->BAU_NOME
		cCodSig		:= TrbBAU->BAU_SIGLCR
		cNumCr		:= TrbBAU->BAU_CONREG
		cUF			:= TrbBAU->BAU_ESTCR 
	else
		cNome		:= TrbBAU->BAU_DIRTEC
		cCodSig		:= cSgCDir
		cNumCr		:= TrbBAU->BAU_DIRREG
		cUF			:= TrbBAU->BAU_UFCDIR
	endif

	TrbBAU->(dbclosearea())

endif		

cCbos := BAQ->(posicione("BAQ",1,xFilial("BAQ")+cCodInt+alltrim((cAlias)->BD6_ESPSOL),"BAQ_CBOS"))
if empty(cCbos)
	cCbos := BAQ->(posicione("BAQ",1,xFilial("BAQ")+cCodInt+alltrim((cAlias)->CODESP),"BAQ_CBOS"))
endif

::MontaTag( 4,"dadosSolicitante")
::MontaTag( 5,"contratadoSolicitante")
if !empty(cCGCContra)
	::MontaTag( 6,"cpf_cnpj")
	::MontaTag( 7,iif(len(alltrim(cCGCContra)) == 11,'cd_cpf','cd_cnpj'),cCGCContra)
	::MontaTag( 6,"cpf_cnpj",,.T. )
endif
::MontaTag( 6,"nome",cNomeContra,,.T.)
::MontaTag( 5,"contratadoSolicitante",,.T. )
::MontaTag( 5,"profissional")
::MontaTag( 6,"nm_Profissional",cNome)
::MontaTag( 6,"dadosConselho")
::MontaTag( 7,"sg_Conselho",cCodSig)
::MontaTag( 7,"nr_Conselho",cNumCr)
::MontaTag( 7,"UF",PLSGETVINC("BTU_CDTERM", "   ", .F., "59", cUF) ) 
::MontaTag( 6,"dadosConselho",,.T. )
::MontaTag( 6,"CBO",PADL(cCbos,6,"0"))
::MontaTag( 5,"profissional",,.T. )
::MontaTag( 4,"dadosSolicitante",,.T. )
	
return

//-------------------------------------------------------------------
/*/{Protheus.doc} dadosGuia

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
method dadosGuia(cTipGui) class PTUA500
local cAlias 	:= ::cAlias
local cGuiPrest := ""
local cIdHab 	:= ""
local cNrOpe 	:= ""
local cCodExc 	:= ""
local cDtSol 	:= ""
local cTpAut 	:= ""
local cDtAut 	:= ""
local cIndCli 	:= ""
local cIndObs	:= ""
local cIndJus	:= ""
local cIndEsp	:= ""
local cDtHrPro	:= ""
local cVerTiss	:= ""
local cAviso 	:= "N"

cNrOpe 		:= ifPls((cAlias)->NRAOPE,(cAlias)->NRAEMP)

::cGuiOpe	:= (cAlias)->(CODLDP+CODPEG+NUMERO)

cGuiPrest	:= ifPls((cAlias)->NUMIMP,::cGuiOpe)
cIdHab		:= iif(PLS272VLD(iif(::lAviso,B2S->B2S_OPEORI,BTO->BTO_OPEORI), cCodInt, (cAlias)->(BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO), stod((cAlias)->DATPRO), cCodInt),'S','N' )

if !empty(cNrOpe)
	cCodExc := "L"
	cDtSol := (cAlias)->DATSOL
	cDtAut := (cAlias)->DATPRO
	cTpAut := iif((cAlias)->TPGRV=="1","1","2")
else
	cCodExc := "0"
endif

if ::lAviso
	cCodExc := "A"
endif

if ::lBlcReap .and. !empty(::cBlcReTpI)
	cCodExc := ::cBlcReTpI
endif

if B5S->(msseek(xFilial("B5S") + (cAlias)->(CODOPE+CODLDP+CODPEG+NUMERO))) 		
	if B2S->(MsSeek(xFilial("B2S")+B5S->B5S_NUMLOT)) 				 
		cAviso := "S"		
	endIf	
endif

cIndCli := alltrim((cAlias)->INDCLI) + ' ' + alltrim((cAlias)->INDCL2)

if BZC->(msseek(xFilial("BZC")+xFilial("BD5")+(cAlias)->(CODOPE+CODLDP+CODPEG+NUMERO))) .or. BZC->(msseek(xFilial("BZC")+xFilial("BD5")+(cAlias)->(GUIINT)))
	cIndObs := alltrim(BZC->BZC_OBSNO1)+' '+alltrim(BZC->BZC_OBSNO2)
	cIndJus := alltrim(BZC->BZC_JUSTE1)+' '+alltrim(BZC->BZC_JUSTE2)+' '+alltrim(BZC->BZC_JUSTE3)+' '+alltrim(BZC->BZC_JUSTE4)
	cIndEsp := alltrim(BZC->BZC_ESMAT1)+' '+alltrim(BZC->BZC_ESMAT2)+' '+alltrim(BZC->BZC_ESMAT3)+' '+alltrim(BZC->BZC_ESMAT4)
endif	

cGuiPri := iif(len((cAlias)->GUIPRI)>20,substr((cAlias)->GUIPRI,5,20),(cAlias)->GUIPRI)

//Quando reapresentação de GRI
if ::lBlcReap .and. ::lInt4Reap .and. !empty((cAlias)->GUIINT)
	cGuiPri := iif(len((cAlias)->GUIINT)>20, substr((cAlias)->GUIINT,5,20), (cAlias)->GUIINT)
endif

cDtHrPro 	:= 	setDate((cAlias)->DATPRO, (cAlias)->HORPRO)	
cVerTiss 	:= ifPls((cAlias)->TISVER,posicione("BAU",1,xfilial("BAU")+(cAlias)->CODRDA,"BAU_TISVER"))

::MontaTag( 4,"dadosGuia")
::MontaTag( 5,"nr_Ver_TISS",cVerTiss)

if cTipGui == GUIA_CONSULTA
	::MontaTag( 5,"tp_Consulta", iif((cAlias)->TIPCON == '5','2',(cAlias)->TIPCON))
endif
::MontaTag( 5,"nr_LotePrestador",(cAlias)->CODPEG)
::MontaTag( 5,"dt_Protocolo",   (cAlias)->BD6_DTDIGI)
::MontaTag( 5,"dt_Conhecimento",(cAlias)->BD6_DTDIGI)
::MontaTag( 5,"nr_Guias")
::MontaTag( 6,"nr_GuiaTissPrestador",PlRetPonto(cGuiPrest))
::MontaTag( 6,"nr_GuiaTissOperadora",PlRetPonto(::cGuiOpe))
if cTipGui <> GUIA_CONSULTA
	::MontaTag( 6,"nr_GuiaTissPrincipal",PlRetPonto(cGuiPri))
endif
::MontaTag( 5,"nr_Guias",,.T. )
if cTipGui == GUIA_CONSULTA
	::MontaTag( 5,"tp_IndAcidente",ifPls((cAlias)->INDACI,"9"))
	if ::lVersAtual .and. cVerTiss >= "4.00.00"
		if alltrim(cTipPre) == "08" .and. !empty((cAlias)->COBESP)
			::MontaTag( 5,"coberturaEspecial","02")
		else 
			::MontaTag( 5,"coberturaEspecial",ifPls((cAlias)->COBESP,""))
		endif 
		::MontaTag( 5,"regimeAtendimento",ifPls((cAlias)->TMREGA,""))
		::MontaTag( 5,"saudeOcupacional" ,ifPls((cAlias)->SAUOCU,""))
	endif
endif

::MontaTag( 5,"dt_Atendimento",cDtHrPro)
::MontaTag( 5,"id_Liminar",PLSSorN((cAlias)->GUIJUR))
::MontaTag( 5,"id_Continuado",cIdHab)
if !::lAviso
	::MontaTag( 5,"id_Avisado",cAviso)
endif
::MontaTag( 5,"cd_Excecao",cCodExc)
::MontaTag( 5,"id_GlosaTotal",'N')

if cTipGui == GUIA_CONSULTA
	cChave := (cAlias)->CODLDP + (cAlias)->CODPEG + (cAlias)->NUMERO
	while !(cAlias)->(eof()) .and. cChave == (cAlias)->CODLDP + (cAlias)->CODPEG + (cAlias)->NUMERO
		::procedimentos(cTipGui,cAviso=='S')
		(cAlias)->(dbskip())
	enddo
else
	::Executados(cTipGui,cAviso=='S')
endif

//Informações deste ponto pra baixo devem ser somente em variaveis pois o Alias vai estar em EOF
if cTipGui == GUIA_CONSULTA .and. !empty(cNrOpe)
	::MontaTag( 6,"dadosAutorizacao")
	::MontaTag( 7,"dt_Solicitacao",ifPls(ifPls(cDtSol,cDtAut),(cAlias)->BD6_DTDIGI))
	::MontaTag( 7,"nr_Autorizacao",substr(cNrOpe,1,10))
	::MontaTag( 7,"cd_UniAutorizadora",iif(::lAviso,B2S->B2S_OPEORI,BTO->BTO_OPEORI) )
	::MontaTag( 7,"dt_Autorizacao",ifPls(ifPls(cDtAut,cDtSol),(cAlias)->BD6_DTDIGI))
	::MontaTag( 7,"tp_Autorizacao",cTpAut)
	::MontaTag( 6,"dadosAutorizacao",,.T. )
endif


if !empty(cIndCli)
	cIndCli := PtuStTran(cIndCli)
	if !empty(cIndCli) 
		::MontaTag( 5,"complemento")
		::MontaTag( 6,"tp_RegCPL",'1')
		::MontaTag( 6,"nm_DescComplemento",cIndCli,,.t.)
		::MontaTag( 5,"complemento",,.T. )	
	endif
endif

if !empty(cIndObs)
	cIndObs := PtuStTran(cIndObs)
	if !empty(cIndObs)
		::MontaTag( 5,"complemento")
		::MontaTag( 6,"tp_RegCPL",'2')
		::MontaTag( 6,"nm_DescComplemento",cIndObs,,.t.)
		::MontaTag( 5,"complemento",,.T. )	
	endif
endif

if !empty(cIndJus)
	cIndJus := PtuStTran(cIndJus)
	if !empty(cIndJus)
		::MontaTag( 5,"complemento")
		::MontaTag( 6,"tp_RegCPL",'3')
		::MontaTag( 6,"nm_DescComplemento",cIndJus,,.t.)
		::MontaTag( 5,"complemento",,.T. )	
	endif
endif

if !empty(cIndEsp)
	cIndEsp := PtuStTran(cIndEsp)
	if !empty(cIndEsp)
		::MontaTag( 5,"complemento")
		::MontaTag( 6,"tp_RegCPL",'4')
		::MontaTag( 6,"nm_DescComplemento",cIndEsp,,.t.)
		::MontaTag( 5,"complemento",,.T. )	
	endif
endif
if cTipGui == GUIA_SADT
	::MontaTag( 5,"id_GuiaPrincipal",iif(!empty(cGuiPri),'N','S'))
endif
::MontaTag( 4,"dadosGuia",,.T. )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} procedimentos

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
method procedimentos(cTipGui, lAvisado, nX, aPacote, cTpProc, cCodPad, cCodPro,lGeraEquipe) class PTUA500
local cAlias 	:= ::cAlias
local cQtd		:= ""
local cCodAto	:= ""
local cAvisoIt	:= "N"
local aProced	:= {}
local lPacote	:= .f.
local lPea 		:= BTO->BTO_OPEORI == cOpePEA  
default lAvisado:= .f.
default nX 		:= 0 //Acrescimo para quando vier do procedimentosExecutados
default aPacote	:= {}
default cCodPad	:= ""
default cCodPro	:= ""
default lGeraEquipe := .T.

if len(aPacote) > 0
	cCodPad := Alltrim(aPacote[1])
	cCodPro := Alltrim(aPacote[2])
	lPacote := .t.
else
	cCodPad := Alltrim((cAlias)->BD6_CODPAD)
	cCodPro := Alltrim((cAlias)->BD6_CODPRO)
endif

cAvisoIt	:= "N"
aProced		:= dePara(cCodPad,cCodPro,(cAlias)->BD6_DATPRO,(cAlias)->BD6_CODRDA)
cCodPad 	:= aProced[1]
cCodPro 	:= alltrim(aProced[2])
cTpProc 	:= aProced[3]
lGeraEquipe	:= aproced[4]

//Quando for PEA deve exportar o pacote recebido da outra UNIMED
if lPea .and. cPacGPTU $  Alltrim((cAlias)->BD6_CODPRO) .AND. !Empty((cAlias)->BD6_CD_PAC) 
	cCodPad := "98"
	cCodPro := Alltrim((cAlias)->BD6_CD_PAC)
endif

if cTipGui == GUIA_CONSULTA .and. lAvisado
	if B6S->(msseek(xFilial("B6S") + B5S->B5S_NUMLOT + B5S->(B5S_CODOPE + B5S_CODLDP + B5S_CODPEG + B5S_NUMERO) + (cAlias)->(BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO)))
		cAvisoIt := "S"
	endif
endif

aSeq := getSeq(cAlias, aPacote, ::lAviso, lPea)

if cCodPad == "00"
	if cTpProc $ "3;4;7;8" //Diárias, taxas, gases medicinais e Alugueis
		cCodPro := "18" + cCodPro
	elseif cTpProc $ "1;5" // Materiais e OPME
		cCodPro := "19" + cCodPro
	elseif cTpProc == "2" // Medicamentos
		cCodPro := "20" + cCodPro
	else
		cCodPro := "22" + cCodPro
	endif
endif

::MontaTag( nX+5,"procedimentos")
::MontaTag( nX+6,"seq_item",aSeq[1])
::MontaTag( nX+6,"id_itemUnico",aSeq[2])
if cTipGui == GUIA_CONSULTA .and. !::lAviso
	::MontaTag( nX+6,"id_AvisadoItem",cAvisoIt)
endif
::MontaTag( nX+6,"tp_Tabela",cCodPad)
::MontaTag( nX+6,"cd_Servico",cCodPro)
if cTipGui == GUIA_CONSULTA
	::MontaTag( nX+6,"vl_ServCobrado",cvaltochar((cAlias)->BD6_VLRPF))
	if (cAlias)->BD6_VLRTAD > 0	
		::MontaTag( nX+6,"tx_AdmServico",cvaltochar((cAlias)->BD6_VLRTAD))	
	endif
	if posicione("BAU",1,xfilial("BAU")+(cAlias)->CODRDA,"BAU_TIPPRE") $ "MED,ANE"
		cCodAto := '1'
	else
		cCodAto := '2'
	endif
	::MontaTag( 6,"cd_Ato",cCodAto)
else
	if len(aPacote) < 11 //Caso > que 10 houve manipulação do PE PLSPACOTE e a quantidade já foi processada e armazenada na posição [11]		
		if lPacote .and.  (aPacote[5] # "BLY|BLE")  .and. len(aPacote)>=9
			cQtd := cValTochar(iif(aPacote[9] == 0,1, aPacote[9])) //Se o Alias não vier como BLY ou BLE pego a qtde do B43_QTDPRO
		else 
			cQtd := iif(lPacote,getQtdProc((cAlias)->CODRDA, (cAlias)->BD6_CODPRO,aPacote[2], aPacote[5],aPacote[1]) ,cvaltochar((cAlias)->BD6_QTDPRO))
		endif
	else
		cQtd := cvaltochar(aPacote[11])
	endif
	::MontaTag( nX+6,"ds_Servico",iif(lPacote,aPacote[3],(cAlias)->BD6_DESPRO),,.t.)
	::MontaTag( nX+6,"qt_Cobrada",cQtd)
endif
::MontaTag( nX+5,"procedimentos",,.T. )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Executados

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
method Executados(cTipGui, lAvisado) class PTUA500
local cAlias 	:= ::cAlias
local cViaAce	:= ""
local cFatSer	:= ""
local cTecUtil	:= ""
local cCodUnm	:= ""
local cAvisoIt	:= ""
local cCodAto	:= ""
local cPacTiss	:= ""
local cTpProc	:= ""
local nX		:= 1
local nVlrHM	:= 0
local nVlrCO	:= 0
local nVlrFIL	:= 0
local nVlrTxHM	:= 0
local nVlrTxCO	:= 0
local nVlrTxFIL	:= 0
local lPacote 	:= .f.
local aPacote 	:= {.f.}
local cb43tipo  := ""
local cCodPad	:= ""
local cCodPro	:= ""
local lPacAbert	:= .f.
local lPEExtPac	:= existBlock( "PLSPACOTE" ) //PE para envio de pacote aberto
local lGeraEquipe	:= .T.
local aAreaBA8 := {}

//Restaura os valores Defaults caso a string venha incorreta do PE: PLS500UNM e salva a pilha no log
IIF("''" $ cFilm, plslogfil(&(cQuallog ), "erro_520.log"),IIF("''" $ cCusOpe, plslogfil(&(cQuallog ), "erro_520.log"),""))
cFilm  := IIF("''" $ cFilm, "'FIL'", cFilm)
cCusOpe:= IIF("''" $ cCusOpe,"'COR','COP','UCO'", cCusOpe)



cChave := (cAlias)->CODLDP + (cAlias)->CODPEG + (cAlias)->NUMERO
while !(cAlias)->(eof()) .and. cChave == (cAlias)->CODLDP + (cAlias)->CODPEG + (cAlias)->NUMERO
	
	cViaAce 	:= ""
	cFatSer		:= ""
	cTecUtil	:= ""
	cPorteAne	:= ""
	cPacTiss	:= ""
	cAvisoIt	:= "N"
	lPacote 	:= .f.
	aPacote 	:= {.f.}
	lPacAbert	:= .f.

	if BGR->(msSeek(xFilial("BGR")+cCodInt+(cAlias)->BD6_VIA))
		if !empty(BGR->BGR_CODEDI)
			cViaAce := BGR->BGR_CODEDI
		else			
			cViaAce := BGR->BGR_CODVIA
		endif		
	endif

	if (cAlias)->BD6_PROCCI == '1'
		do case
			case (cAlias)->BD6_TECUTI == "C"
				cTecUtil := '1'
			case (cAlias)->BD6_TECUTI == "V"
				cTecUtil := '2'
			case (cAlias)->BD6_TECUTI == "R"
				cTecUtil := '3'	
			case !empty((cAlias)->BD6_TECUTI)	   
				cTecUtil := (cAlias)->BD6_TECUTI	
			case empty((cAlias)->BD6_TECUTI)	   
				cTecUtil := '1'	
		endcase	
	endif
	cFatSer := transform((cvaltochar((cAlias)->BD6_PERHES+100)), '@R 9.99')
	cSql := " SELECT " 
	cSql += " SUM(case WHEN CODUNM = "+cFilm+"                    	THEN VLRTPF else 0 END) FIL , "
	cSql += " SUM(case WHEN CODUNM IN ("+cCusOpe+")					THEN VLRTPF else 0 END) CO, "
	cSql += " SUM(case WHEN CODUNM NOT IN ("+cCusOpe+","+cFilm+")	THEN VLRTPF else 0 END) HM, "
	cSql += " SUM(case WHEN CODUNM = "+cFilm+"                    	THEN VLRTAD else 0 END) FILTX , "
	cSql += " SUM(case WHEN CODUNM IN ("+cCusOpe+")        			THEN VLRTAD else 0 END) COTX, "
	cSql += " SUM(case WHEN CODUNM NOT IN ("+cCusOpe+","+cFilm+")	THEN VLRTAD else 0 END) HMTX "
	cSql += " FROM " + oTmpBase:getrealName() 
	cSql += " WHERE CODOPE = '" + (cAlias)->CODOPE + "' "
	cSql += " AND CODLDP = '" + (cAlias)->CODLDP + "' "
	cSql += " AND CODPEG = '" + (cAlias)->CODPEG + "' "
	cSql += " AND NUMERO = '" + (cAlias)->NUMERO + "' "
	cSql += " AND ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' "
	cSql += " AND SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"TMPBD7",.F.,.T.)
	nVlrHM		:=	TMPBD7->HM - TMPBD7->HMTX
	nVlrCO		:=	TMPBD7->CO - TMPBD7->COTX
	nVlrFIL		:=	TMPBD7->FIL	- TMPBD7->FILTX
	nVlrTxHM	:=	TMPBD7->HMTX
	nVlrTxCO	:=	TMPBD7->COTX
	nVlrTxFIL	:=	TMPBD7->FILTX
	TMPBD7->(dbclosearea())

	cCodUnm := (cAlias)->BX6_CODUNM 
	if empty(cCodUnm)		
		if BA8->(msSeek(xFilial("BA8")+(cAlias)->(CODOPE+BD6_CODTAB+BD6_CODPAD+BD6_CODPRO)))
		  	cCodUnm  := BA8->BA8_UNMEDI
		endif
	endif
	if lAvisado .and. B6S->(msseek(xFilial("B6S") + B5S->B5S_NUMLOT + B5S->(B5S_CODOPE + B5S_CODLDP + B5S_CODPEG + B5S_NUMERO) + (cAlias)->(BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO)))
		cAvisoIt := "S"
	endif
	if BD4->(Msseek( xFilial("BD4")+cCodInt+(cAlias)->(BD6_CODTAB+BD6_CODPAD+BD6_CODPRO)+"PA" )) 
		cPorteAne := getBKF()
	endif					
	
	if posicione("BAU",1,xfilial("BAU")+(cAlias)->CODRDA,"BAU_TIPPRE") $ "MED,ANE"
		cCodAto := '1'
	else
		cCodAto := '2'
	endif
	if (cAlias)->BD6_PACOTE == '1'
		if lPEExtPac //PE para envio de pacote aberto
			aPacote := execBlock("PLSPACOTE",.F.,.F.,cAlias)
			lPacAbert := aPacote[1] == 2 //opção 2-Sem pacote principal PLSPACOTE
		else
			aPacote := getPacote(cAlias)
		endif
	endif

	for nX := 1 to len(aPacote)
		if lPacAbert.and. nX == 1 //Processo para funcionamento do PE PLSPACOTE não exportar o pacote principal 
			loop
		endif

		if nX > 1
			nVlrHM		:= 0
			nVlrCO		:= 0
			nVlrFIL		:= 0
			nVlrTxHM	:= 0
			nVlrTxCO	:= 0
			nVlrTxFIL	:= 0
			lPacote 	:= .t.

			if lPacAbert //Distribuição de valores conforme regra do PE PLSPACOTE
				nVlrHM		:= aPacote[nX][9][1]  
				nVlrCO		:= aPacote[nX][9][3] 
				nVlrFIL		:= aPacote[nX][9][2] 
				nVlrTxHM	:= aPacote[nX][10][1] 
				nVlrTxCO	:= aPacote[nX][10][3] 
				nVlrTxFIL	:= aPacote[nX][10][2] 
			endif

			if empty(cPacTiss)
				cPacTiss	:= dePara((cAlias)->BD6_CODPAD,(cAlias)->BD6_CODPRO,(cAlias)->BD6_DATPRO)[2]
			endif
		endif

		::MontaTag( 5,"procedimentosExecutados")
		::MontaTag( 6,"dt_Execucao",(cAlias)->BD6_DATPRO)
		if !empty((cAlias)->BD6_HORPRO)
			::MontaTag( 6,"hr_Inicial",formatHora((cAlias)->BD6_HORPRO))
		endif
		if !empty((cAlias)->BD6_HORFIM)
			::MontaTag( 6,"hr_Final",formatHora((cAlias)->BD6_HORFIM))
		endif
		::procedimentos(cTipGui, lAvisado, 1,iif(lPacote,aPacote[nX],{}),@cTpProc,@cCodPad,@cCodPro,@lGeraEquipe) //Z-0
		::MontaTag( 6,"via_Acesso",cViaAce)
		::MontaTag( 6,"tc_Utilizada",cTecUtil)
		::MontaTag( 6,"id_Acrescimo",iif(val(cFatSer)>1,'S','N'))
		if cTipGui == GUIA_HONORARIO
			::MontaTag( 6,"vl_ServCobrado",str(nVlrHM+nVlrFIL+nVlrCO))
			::MontaTag( 6,"tx_AdmServico",str(nVlrTxHM+nVlrTxFIL+nVlrTxCO))
		else
			::MontaTag( 6,"valores")
			if nVlrHM > 0 .or. (nVlrFIL+nVlrCO == 0)
				::MontaTag( 7,"vl_ServCobrado",str(nVlrHM))
			endif
			if nVlrFIL> 0
				::MontaTag( 7,"vl_FilmeCobrado",str(nVlrFIL))
			endif
			if nVlrCO > 0
				::MontaTag( 7,"vl_CO_Cobrado",str(nVlrCO))
			endif
			::MontaTag( 6,"valores",,.T. )
			if nVlrTxHM+nVlrTxCO+nVlrTxFIL > 0
				::MontaTag( 6,"taxas")
				if nVlrTxHM > 0 .or. (nVlrTxFIL+nVlrTxCO == 0)
					::MontaTag( 7,"tx_AdmServico",str(nVlrTxHM))
				endif
				if nVlrTxFIL > 0
					::MontaTag( 7,"tx_AdmFilme",str(nVlrTxFIL))
				endif
				if nVlrTxCO > 0
					::MontaTag( 7,"tx_AdmCO",str(nVlrTxCO))
				endif
				::MontaTag( 6,"taxas",,.T. )
			endif
		endif
		if cTipGui <> GUIA_HONORARIO
			if lPacote
				aAreaBA8 := BA8->(getArea())
				BA8->(dbsetOrder(3))
				if BA8->(msSeek(xFilial("BA8")+aPacote[nX][1]+aPacote[nX][2]))
					cCodUnm  := BA8->BA8_UNMEDI
				endif
				restarea(aAreaBA8)
			endif
			::MontaTag( 6,"un_Medida",cCodUnm)
		endif
		::MontaTag( 6,"ft_MultiplicadorServico",cFatSer)
		if !::lAviso
			::MontaTag( 6,"id_AvisadoItem",cAvisoIt)
		endif
		if cTipGui <> GUIA_HONORARIO
			if lPacAbert // Envio de pacote aberto (processo customizado)
				::MontaTag( 6,"id_Pacote",'N')
			else
				if cCodPad != "98" 
					::MontaTag( 6,"id_Pacote",iif(lPacote,'S','N'))
				endif
				::MontaTag( 6,"cd_Pacote",iif(lPacote,cPacTiss,''))
			endif
		endif
		::MontaTag( 6,"cd_PorteAnestesico",cPorteAne)
		if cTipGui <> GUIA_HONORARIO
			::dadosOPME(cTpProc,cCodPro)
		endif
		cb43tipo := if(len(aPacote) >1, aPacote[2][4], "")//==0 item de pacote do tipo honorario
		if lGeraEquipe .AND. ( (cAlias)->BD6_PACOTE <> '1' .and.  (cTipGui <> GUIA_CONSULTA .and. nVlrHM+nVlrFIL+nVlrCO > 0) .or. (nVlrHM==0 .and. lPacote .and. cb43tipo=="0") )
			::equipeProfissional(cTipGui,cTpProc,lGeraEquipe)
		endif
		::MontaTag( 6,"cd_Ato",cCodAto)
		::dadosAutorizacao()

		::MontaTag( 5,"procedimentosExecutados",,.T. )
	next
	lPacote 	:= .f.
	(cAlias)->(dbskip())
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} dadosOPME

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
method dadosOPME(cTpProc,cCodPro) class PTUA500
local cAlias 	:= ::cAlias
local cPagNomFor := ""
local cCnpjFor   := ""
local cNumNFForn := ""
local cDetRegAnv := ""
local cRegAnvis  := ""
local lOpmeGen	 := .f.

//BR8 posicionada no metodo procedimentos
if cTpProc == '5'  
	cPagNomFor 	:= BX6->BX6_NOMFOR
	cCnpjFor 	:= BX6->BX6_CNPJFO
	cNumNFForn 	:= BX6->BX6_NNFFOR
	cDetRegAnv	:= BX6->BX6_DREANV
	cRegAnvis	:= BX6->BX6_REGANV
	cCodRefFab 	:= (cAlias)->BD6_REFFED

	if (empty(cPagNomFor) .or. empty(cCnpjFor) .or. empty(cNumNFForn)) .and. !empty((cAlias)->BD6_NFE)
		if SF1->(msSeek(alltrim((cAlias)->BD6_NFE)))
			if empty(cNumNFForn)	
				cNumNFForn := Padr(SF1->F1_DOC,20)
			endif
		    if SA2->(msSeek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA)))
		    	if empty(cPagNomFor)
		    		cPagNomFor := SA2->A2_NOME 
		    	endif
		    	if empty(cCnpjFor) 
		    		cCnpjFor := SA2->A2_CGC
		    	endif	
		    endif
		endif
	endif
	if empty(cDetRegAnv) .or. empty(cRegAnvis) 
		if BA8->(msSeek(xfilial("BA8")+(cAlias)->(CODOPE+BD6_CODTAB+BD6_CODPAD+BD6_CODPRO)))
			cDetRegAnv	:= ifPls(cDetRegAnv,BA8->BA8_DETANV )
			cRegAnvis	:= ifPls(cRegAnvis ,BA8->BA8_RGANVI )		
		endif
	endif

	lOpmeGen := alltrim(cOpmeGen) == cCodPro .OR. "19"+alltrim(cOpmeGen) == cCodPro //19 codigo depara para OPME

	if !empty(cNumNFForn) .OR. lOpmeGen
		::MontaTag( 6,"dadosOPME")
		if !empty(cNumNFForn)
			::MontaTag( 7,"Pago_Fornecedor")
			::MontaTag( 8,"CNPJ_Fornecedor",ifPls(cCnpjFor,(cAlias)->BD6_CPFRDA))
			::MontaTag( 8,"nm_FornecedorMaterial",ifPls(cPagNomFor,(cAlias)->NOMRDA))
			::MontaTag( 8,"nr_NotaFiscalFornecedor",cNumNFForn)
			::MontaTag( 7,"Pago_Fornecedor",,.T. )
		endif
		if lOpmeGen
			::MontaTag( 7,"det_RegistroAnvisa",cDetRegAnv)
			::MontaTag( 7,"nr_RegistroAnvisa",cRegAnvis)
			::MontaTag( 7,"cd_ReferenciaMat_Fab",cCodRefFab)
		endif
		::MontaTag( 6,"dadosOPME",,.T. )
	endif
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} equipeProfissional

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
method equipeProfissional(cTipGui,cTpProc,lGeraEquipe) class PTUA500
local cAlias 		:= ::cAlias
local cSql	 		:= ""
local aEquip		:= {}
local nX 			:= 1
local nI			:= 0
local cSgCDir 		:= ""
local lReg			:= .f. //indica se o registro já está no array aEquip
local lIncEqpTag	:= .t.
Local lTemUmValido	:= .F.
default cTpProc 	:= ""
default lGeraEquipe := .f.

cSql += " SELECT CDPFPR, SIGLA, REGPRE, ESTPRE, ESPEXE, CODUNM, NLANC, CODTPA, CODESP "
cSql += " FROM " + oTmpBase:getrealName()
cSql += " WHERE CODOPE = '" + cCodInt + "' "
cSql += " AND CODLDP = '" + (cAlias)->CODLDP + "' "
cSql += " AND CODPEG = '" + (cAlias)->CODPEG + "' "
cSql += " AND NUMERO = '" + (cAlias)->NUMERO + "' "
cSql += " AND SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' "
cSql += " AND CDPFPR <> ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBD7",.F.,.T.)
while !TrbBD7->(eof())
	cSql := " SELECT BB0_NOME, BB0_CGC "
	cSql += " FROM " + cBB0Name + " BB0 "
	cSql += " WHERE BB0_FILIAL = '" + xfilial("BB0") + "' "
	cSql += " AND BB0_CODIGO = '" + TrbBD7->CDPFPR + "' "
	//cSql += " AND BB0_CGC <> ' ' "
	cSql += " AND BB0.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBB0",.F.,.T.)
	while !TrbBB0->(eof())
		aadd(aEquip,{TrbBD7->ESPEXE,TrbBD7->CODESP,TrbBD7->CODTPA,TrbBD7->CODUNM,TrbBB0->BB0_NOME,TrbBB0->BB0_CGC,TrbBD7->SIGLA,TrbBD7->REGPRE,TrbBD7->ESTPRE,TrbBD7->NLANC})
		if !(empty(aEquip[Len(aEquip)][3]))
			lTemUmValido := .T.
		endif
		TrbBB0->(dbskip())
	enddo
	TrbBB0->(dbclosearea())
	TrbBD7->(dbskip())
enddo
TrbBD7->(dbclosearea())

if (cTipGui != GUIA_HONORARIO) .AND. !lTemUmValido
	lIncEqpTag	:= .f.
endif

//tag obrigatória na guia de honorarios, se não achei mando o proprio RDA
if (cTipGui == GUIA_HONORARIO .or. cTpProc == "0")
	cSql := " SELECT BAU_NOME, BAU_CPFCGC, BAU_SIGLCR, BAU_CONREG, BAU_ESTCR, ESPEXE, CODUNM, CODTPA, CODESP, NLANC, BAU_SIGDIR, BAU_DIRREG, BAU_UFCDIR, BAU_TIPPE, BAU_DIRTEC "
	cSql += " FROM " + oTmpBase:getrealName() + " TMP "
	cSql += " INNER JOIN " + cBAUName + " BAU "
	cSql += " ON BAU_FILIAL 	=  '" + xfilial("BB8") + "' "
	cSql += " AND BAU_CODIGO 	= TMP.BD7_CODRDA "
	cSql += " AND BAU.D_E_L_E_T_ = ' ' "
	cSql += " WHERE CODOPE = '" + cCodInt + "' "
	cSql += " AND CODLDP = '" + (cAlias)->CODLDP + "' "
	cSql += " AND CODPEG = '" + (cAlias)->CODPEG + "' "
	cSql += " AND NUMERO = '" + (cAlias)->NUMERO + "' "
	cSql += " AND SEQUEN = '" + (cAlias)->BD6_SEQUEN + "' "
	cSql += " AND CODUNM NOT IN ("+cCusOpe+","+cFilm+") "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBD7",.F.,.T.)
	
	while !TrbBD7->(eof())

		lReg := .f. //reset da flag
		for nI := 1 to len(aEquip) //verifico se já existe um registro no array aEquip com os dados a serem imputados
			if aScan( aEquip[nI] , TrbBD7->CODUNM ) > 0 .and. aScan( aEquip[nI] , TrbBD7->NLANC )  > 0 
				lReg := .T.
				exit
			endif
		next
		if lReg //se achou, sai do for e skipa a linha sem duplicar o registro
			TrbBD7->(dbskip())
			loop
		endif

		cSgCDir := SigConsReg(TrbBD7->BAU_SIGDIR)
		if TrbBD7->BAU_TIPPE == 'F'
			aadd(aEquip,{TrbBD7->ESPEXE,TrbBD7->CODESP,TrbBD7->CODTPA,TrbBD7->CODUNM,TrbBD7->BAU_NOME,TrbBD7->BAU_CPFCGC,TrbBD7->BAU_SIGLCR,TrbBD7->BAU_CONREG,TrbBD7->BAU_ESTCR,TrbBD7->NLANC})
		else
			aadd(aEquip,{TrbBD7->ESPEXE,TrbBD7->CODESP,TrbBD7->CODTPA,TrbBD7->CODUNM,TrbBD7->BAU_DIRTEC,"",cSgCDir,TrbBD7->BAU_DIRREG,TrbBD7->BAU_UFCDIR,TrbBD7->NLANC})
		endif
		TrbBD7->(dbskip())
	enddo
	TrbBD7->(dbclosearea())
endif

for nX := 1 to len(aEquip)

	cCBOS := AllTrim( Posicione("BAQ",7,xfilial("BAQ")+aEquip[nX][1],"BAQ_CBOS") )
	if empty(cCBOS)
		cCBOS := AllTrim( Posicione("BAQ",7,xfilial("BAQ")+aEquip[nX][2],"BAQ_CBOS") )
	endIf
	if empty(cCBOS)
		cCBOS := "000000"
	endif

	cGrauPart := cGrauPa	:= ""
	if !empty(aEquip[nX][3])
		cGrauPart := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35", aEquip[nX][3])
	elseif cTipGui == GUIA_HONORARIO
		if aEquip[nX][4] == "AUX"
			cGrauPart	:=  aEquip[nX][10]
			if empty(cGrauPart) .or. !(cGrauPart $ '01;02;03;04')
				cGrauPart	:=  "01"
			endif
		elseif aEquip[nX][4] $ cAnest
			cGrauPart	:=  "06"
		else
			cGrauPa := PLSGrauUM((cAlias)->BD6_CODPAD,(cAlias)->BD6_CODPRO,aEquip[nX][4],stod((cAlias)->BD6_DATPRO),"2")[2]
			if empty(cGrauPa) .and. aEquip[nX][4] $ cServ
				cGrauPart := "00"
			else
				cGrauPart := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35", cGrauPa)
			endif
		endif
	endIf

	//Se participação inválida ou não informada o tipo de participação e número de conselho, não gera a tag de equipe
	if lGeraEquipe .or. (lIncEqpTag .and. (!Empty(cGrauPart) .and. !cGrauPart $ "0,O"))
		::MontaTag( 6,"equipe_Profissional")
		::MontaTag( 7,"tp_Participacao",cGrauPart)
		::MontaTag( 7,"nm_Profissional",aEquip[nX][5])
		::MontaTag( 7,"cd_cpf",aEquip[nX][6])
		::MontaTag( 7,"dadosConselho")
		::MontaTag( 8,"sg_Conselho",aEquip[nX][7])
		::MontaTag( 8,"nr_Conselho",aEquip[nX][8])
		::MontaTag( 8,"UF",PLSGETVINC("BTU_CDTERM", "   ", .F., "59", aEquip[nX][9]) )
		::MontaTag( 7,"dadosConselho",,.T. )
		::MontaTag( 7,"CBO",PADL(cCbos,6,"0"))
		::MontaTag( 6,"equipe_Profissional",,.T. )
	endif
next

return

//-------------------------------------------------------------------
/*/{Protheus.doc} dadosAutorizacao

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
method dadosAutorizacao() class PTUA500
local cAlias 	:= ::cAlias
local cNrAut 	:= val(substr(ifPls((cAlias)->NRAOPE,(cAlias)->NRAEMP),1,10))

if !empty(cNrAut)
	::MontaTag( 6,"dadosAutorizacao")
	::MontaTag( 7,"dt_Solicitacao",ifPls(ifPls((cAlias)->DATSOL,(cAlias)->DATPRO),(cAlias)->BD6_DTDIGI))
	::MontaTag( 7,"nr_Autorizacao",substr(ifPls((cAlias)->NRAOPE,(cAlias)->NRAEMP),1,10))
	::MontaTag( 7,"cd_UniAutorizadora",iif(!empty((cAlias)->NRAOPE),iif(::lAviso,B2S->B2S_OPEORI,BTO->BTO_OPEORI) ,""))
	::MontaTag( 7,"dt_Autorizacao",ifPls(ifPls((cAlias)->DATPRO,(cAlias)->DATSOL),(cAlias)->BD6_DTDIGI)) 
	::MontaTag( 7,"tp_Autorizacao", iif((cAlias)->TPGRV=="1","1","2"))
	::MontaTag( 6,"dadosAutorizacao",,.T.)
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTag
Formata a TAG XML a ser escrita no arquivo

@author  Lucas Nonato
@version P12
@since   11/10/2019
@param nSpc    = chaveamento
@param cTag    = nome tag
@param cVal    = valor campo
@param lFin    = fechamento da tag
@param lEncode = retira caracteres especiais
/*/
method MontaTag(nSpc,cTag,cVal,lFin,lEncode) CLASS PTUA500
local cRetTag   := ""
local cNameSpace:= ""
local lIni		:= .f.
default nSpc    := 0
default cTag    := ""
default lFin    := .F.
default lEncode := .F.

if cVal == nil
	cVal    := ""
	lIni := !lFin
endif

if !Empty(::cNameSpace)
    cNameSpace := ::cNameSpace+":"
endif

if !empty(cVal) .or. lIni
	cRetTag += '<' + cNameSpace+ cTag + '>'
	cVal 	:= alltrim(iif(lEncode,PtuStTran(cVal),cVal))
	cRetTag += cVal
endif
if !empty(cVal) .or. lFin 
	cRetTag += '</' + cNameSpace + cTag + '>'
endif

if !empty(cVal) .and. cTag <> 'hash'
	if cTag == "link_NFeDoc"
		cVal := Alltrim(StrTran(cVal,"<![CDATA[",""))
		cVal := Alltrim(StrTran(cVal,"]]>",""))
		::cStrHash += cVal
	else
		::cStrHash += cVal
	endif
endif
if !empty(cRetTag)
	::cXml  += Replicate( "	", nSpc ) + cRetTag + CRLF
endif
		
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} iniGuia
Quebro o cabeçalho e o final do XML para realizar o valid do schema a cada guia para facilitar analise do usuario final.

@author  Lucas Nonato
@version P12
@since   23/06/2020
/*/
method iniGuia() class PTUA500
::cCabXml := ::cXml

::geraXML()

::MontaTag( 2,"Tipoguia",,.T. )
::MontaTag( 1,"arquivoA500",,.T. )
::MontaTag( 1,"hash",'XXXX',.T. )
::MontaTag( 0,"ptuA500",,.T. ) 
::cEndXml := ::cXml

::cXml := ""

return

//-------------------------------------------------------------------
/*/{Protheus.doc} fimGuia
Antes de gravar a guia no XML faço a validação

@author  Lucas Nonato
@version P12
@since   23/06/2020
/*/
method fimGuia() class PTUA500

::validaXML()
::geraXML()
::geraHash()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU500BASE

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
method validaXML() class PTUA500
local cError	:= ""
local cWarning	:= ""
local lRet		:= .F.
local cPath     := iif(::lVersAtual ==.T.,"\plsptu\schemas\V2_0\","\plsptu\schemas\V1_1\")

//--< Valida um arquivo XML com o XSD >--
if xmlSVldSch( ::cCabXml+::cXML+::cEndXml,PLSMUDSIS(cPath)+::cSchema,@cError,@cWarning )
	lRet := .T.
endif

if( !lRet )
	::logErro( cError )
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} logErro

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
method logErro(cError,lEnd) class PTUA500
local cMsg 	:= ""
default lEnd := .f.
if ::nArqLog == 0
	::nArqLog := fCreate( cDirTmp + ::cFileName + ".log",FC_NORMAL,,.F.)
	::addMsg("Falha na estrutura. Verifique o arquivo: " + ::cFileName + ".log")
endif

cMsg 	:= "************ Divergencia Validação XML  ************" + CRLF
cMsg 	+= "Protocolo: "	+ substr(self:cGuiOpe,5,8) + CRLF
cMsg 	+= "Guia: " 		+ substr(self:cGuiOpe,13,8) + CRLF
cMsg += strtran(cError, "{http://ptu.unimed.coop.br/schemas/"+self:cVersao+"}","")
cMsg +=  "****************************************************" + CRLF

fWrite( ::nArqLog, cMsg )

return
//-------------------------------------------------------------------
/*/{Protheus.doc} Inifile 
Inicia o arquivo
Adaptado do fonte PLSXMLPTU

@author    Lucas Nonato
@version   1.xx
@since     21/10/2019
/*/
//-------------------------------------------------------------------
method Inifile(cTag) CLASS PTUA500
    
local cNameSpace := ""
    
if !Empty(::cNameSpace)
    cNameSpace := ::cNameSpace+":"
endif

::cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>' + CRLF
 
::cXml += 	'<'+cNameSpace+cTag+' xsi:schemaLocation="http://ptu.unimed.coop.br/schemas/'+self:cVersao+" "+ ;
			self:cSchema +'" xmlns:'+self:cNameSpace+'="http://ptu.unimed.coop.br/schemas/'+self:cVersao + ;
			'" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + ">" + CRLF
return

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcHash
Calcula o Hash MD5 do arquivo

@author    Lucas Nonato
@version   1.xx
@since     24/06/2020
/*/
//-------------------------------------------------------------------
method CalcHash() CLASS PTUA500

if ::nArqHash > 0
	fClose( ::nArqHash )
	::cHashMD5 := md5File(cDirTmp + ::cFileName + ".txt" )	
	fErase( cDirTmp + ::cFileName + ".txt" )
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} addMsg
Adiciona uma mensagem de processamento ao objeto

@author    Lucas Nonato
@version   1.xx
@since     21/10/2019
/*/
method addMsg(cMsg,cCodOpe,cNumero) CLASS PTUA500
default cCodOpe := iif(::lAviso,B2S->B2S_OPEORI,BTO->BTO_OPEORI) 
default cNumero := iif(::lAviso,B2S->B2S_NUMLOT,BTO->BTO_NUMERO) 

aadd(::aMsg,{cCodOpe, cNumero, cMsg})

return
//-------------------------------------------------------------------
/*/{Protheus.doc} SetVersao 

@author  Eduardo Bento
@version P12
@since   21/10/2019
/*/
method SetVersao(cVersaoXml) class PTUA500

if cValtoChar(cVersaoXml) == "1"      //1-Atual, 2-Antiga
	  ::lVersAtual   := .T.
else// 
      ::lVersAtual := .F.        
endif//

return 


//-------------------------------------------------------------------
/*/{Protheus.doc} geraXML
Escreve o arquivo XML

@author    lucas.nonato
@version   1.xx
@since     22/10/2019
/*/
//-------------------------------------------------------------------
method geraXML(lEnd) CLASS PTUA500

if ::nArqFull == 0
	::nArqFull := fCreate( cDirTmp + ::cFileName + "." + substr(cCodInt,2,3) ,FC_NORMAL,,.F.)
	::addMsg("Arquivo gerado: " + ::cFileName + "." + substr(cCodInt,2,3))
endif
 
fWrite( ::nArqFull,::cXml )
if lEnd
	fClose( ::nArqFull )
	If !::lAuto
		CpyS2T( cDirTmp + ::cFileName + "." + substr(cCodInt,2,3), ::cFolder,,.f. )
		fErase( cDirTmp + ::cFileName + "." + substr(cCodInt,2,3))
	EndIf
	if ::nArqLog > 0
		fClose( ::nArqLog )
		If !::lAuto
			CpyS2T( cDirTmp + ::cFileName + ".log", ::cFolder,,.f. )
			fErase( cDirTmp + ::cFileName + ".log" )
		EndIf
	endif
endif

::cXml := ""

return


//-------------------------------------------------------------------
/*/{Protheus.doc} geraHash
Escreve o arquivo do hash

@author    lucas.nonato
@version   1.xx
@since     21/07/2020
/*/
//-------------------------------------------------------------------
method geraHash(lEnd) CLASS PTUA500

if ::nArqHash == 0
	::nArqHash := fCreate( cDirTmp + ::cFileName + ".txt",FC_NORMAL,,.F.)
endif

fWrite( ::nArqHash,::cStrHash )

::cStrHash := ""

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSU500PER 
Parambox para resgatar o destino e a versão

@author  Eduardo Bento
@version P12
@since   11/09/2019
/*/

function PLSU500PER(aRet)
local aPergs    := {}
local lRet		:= .f.
local cStatus := space(1)

aadd( aPergs,{ 2 , "Versão PTU:" , cStatus , {"1=PTU 2.0","2=PTU 1.1"} , 50 , "" , .F. } )
aadd( aPergs,{ 6 , "Caminho do Destino:",Space(50),"","","",50,.t.,,,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY  )})
if( paramBox( aPergs,"Parâmetros - Exportação PTU500 XML",@aRet,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,300,/*oDlgWizard*/,/*cLoad*/,/*lCanSave*/.t.,/*lUserSave*/.t. ) )
	lRet := .t.
endif
return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSSorN

@author  Lucas Nonato
@version P12
@since   11/09/2019
/*/
function PLSSorN(cRet)

if cRet == '1'
	cRet := "S"
else
	cRet := "N"
endif

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VerifIRRF
Verifica o codigo da Operadora para saber se manda ou nao o IRRF no A500   Campo VL_IR 

@author  PLS TEAM
@version P12
@since   23/12/2014
/*/
//-------------------------------------------------------------------
Static Function VerifIRRF(cOutOP)  

Local   cTipUn   := ""
Local   cMinOp   := cCodInt
Local   cTipMUn  := ""
Local   lEnvIr   := .F.
Default cOutOP   := "" 

aAreaBA0 := BA0->(GetArea())
BA0->(dbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT 

if !Empty (cOutOP)
	if BA0->(msseek(xFilial("BA0")+cOutOP))          
        // verifico em qual range esta a operadora que estou gerando o Lote.   	
		Do case
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0600"
				cTipUn := "1"     //Singulares
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0601" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0650"
				cTipUn := "2"      //Seccionais
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0651" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0850"
				cTipUn := "3"      //Entidades Internacionais
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0851" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0949"
			    cTipUn := "4"      // Intrafederativas     
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0950" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0990"
			    cTipUn := "5"      // Interfederativas/Federação
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0991" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0998"
			    cTipUn := "6"      //Empresas do Complexo (Seguradora,UAS,etc.)
			case BA0->BA0_CODIDE+BA0->BA0_CODINT == "0999"
			    cTipUn := "7"      //Confederação Nacional
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "1001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "1600"
			    cTipUn := "8"      //Singulares Unicred
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "1950" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "1990"
			    cTipUn := "9"      //Centrais Unicred
			case BA0->BA0_CODIDE+BA0->BA0_CODINT == "1999"
			    cTipUn := "10"      //Confederação Unicred
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "2001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "2999"
			    cTipUn := "11"      //Usimeds					
			Otherwise
				cTipUn := "1"
			Endcase
			RestArea(aAreaBA0)
	endif
endif

if !Empty(cMinOp)
	if BA0->(msseek(xFilial("BA0")+cMinOp))          
        // verifico em qual range esta a minha operadora.   	
		Do case
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0600"
				cTipMUn := "1"     //Singulares
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0601" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0650"
				cTipMUn := "2"      //Seccionais
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0651" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0850"
				cTipMUn := "3"      //Entidades Internacionais
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0851" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0949"
			    cTipMUn := "4"      // Intrafederativas     
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0950" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0990"
			    cTipMUn := "5"      // Interfederativas/Federação
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0991" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0998"
			    cTipMUn := "6"      //Empresas do Complexo (Seguradora,UAS,etc.)
			case BA0->BA0_CODIDE+BA0->BA0_CODINT == "0999"
			    cTipMUn := "7"      //Confederação Nacional
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "1001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "1600"
			    cTipMUn := "8"      //Singulares Unicred
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "1950" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "1990"
			    cTipMUn := "9"      //Centrais Unicred
			case BA0->BA0_CODIDE+BA0->BA0_CODINT == "1999"
			    cTipMUn := "10"      //Confederação Unicred
			case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "2001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "2999"
			    cTipMUn := "11"      //Usimeds
					
			Otherwise
				cTipMUn := "1"
			Endcase
		RestArea(aAreaBA0)
	endif
endif

if !Empty (cTipMUn) .And. !Empty (cTipUn)
	if cTipMUn <> cTipUn
		lEnvIr := .T. 
	endif
endif

return (lEnvIr)


//-------------------------------------------------------------------
/*/{Protheus.doc} FormatHora
Retorna a hora no formato correto.

@author    Guilherme Carvalho
@version   1.xx
@since     04/06/2018
/*/
//-------------------------------------------------------------------
static function FormatHora( cHora )
local cRet := ""

If !Empty(cHora)
	
	cRet := AllTrim(TransForm(AllTrim(cHora),"@R !!:!!:!!"))
	
	If Len(cRet) == 5 //99:99
		cRet := cRet+":00"
	ElseIf Len(cRet) == 6 //99:99:
		cRet := cRet+"00"
	ElseIf Len(cRet) == 7 //99:99:9
		cRet := cRet+"0"
	EndIf 	

EndIf

Return(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} getBKF 
Retorna o código EDI da BKF

@author  Lucas Nonato
@version P12
@since   12/02/2020
/*/
static function getBKF()
local cRet := ""
local cSql as char

cCodPoA := alltrim(BD4->BD4_PORMED)					

Do case
	case cCodPoA == "3A"
		cRet := "1"
	case cCodPoA == "3C"
		cRet := "2"
	case cCodPoA == "4C"
		cRet := "3"
	case cCodPoA == "6B"
		cRet := "4"
	case cCodPoA == "7C"
		cRet := "5"
	case cCodPoA == "9B"
		cRet := "6"
	case cCodPoA == "10C"
		cRet := "7"
	case cCodPoA == "12A"
		cRet := "8"
endcase

if empty(cRet)
	cSql := " SELECT BKF_CODEDI FROM " + cBKFName
	cSql += " WHERE BKF_FILIAL = '" + xfilial("BKF") + "'"
	cSql += " AND BKF_CODINT = '" + substr(BD4->BD4_CODTAB,1,4) + "'"
	cSql += " AND BKF_CODTAB = '" + substr(BD4->BD4_CODTAB,5,3) + "'"
	cSql += " AND BKF_SEQPOR = " + cvaltochar(BD4->BD4_VALREF)
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBKF",.F.,.T.)

	if !TrbBKF->(eof())
		cRet := TrbBKF->BKF_CODEDI
	endif

	TrbBKF->(dbclosearea())
endif

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} getQtdProc
Pega uma data de vigencia que todos os procedimentos estão inclusos.
@author Lucas Nonato
@since 11/05/2016
@version P12
/*/
Static Function getQtdProc(cCodRda, cCodPro, cCodOpc, cAlias, cCodPad)
Local cSql := ""
Local cRet := ""
local cCampos := cAlias+"_QTDPAC Qtd "
cSql := " SELECT " + cCampos + " FROM " + RetSqlName(cAlias) 
cSQL += " WHERE "
cSql += cAlias+"_FILIAL = '" + xFilial(cAlias) + "' "
cSql += " AND "   + cAlias+"_CODINT = '" + cCodInt + "'" 
cSql += iif( cAlias == "BLY", " AND " + cAlias+"_CODRDA ='" + cCodRda + "' ", '')
cSQL += " AND "   + cAlias+"_CODPAD = '" + cCodPad + "' " 
cSQL += " AND "   + cAlias+"_CODPRO = '" + cCodPro + "' " 
cSQL += " AND "   + cAlias+"_CODOPC = '" + cCodOpc + "'" 
cSql += " AND ( '" + dtos(dDataBase) + "' >= " + cAlias+"_VIGDE OR  " + cAlias+"_VIGDE  = ' ' ) "
cSqL += " AND ( '" + dtos(dDataBase) + "' <= " + cAlias+"_VIGATE OR " + cAlias+"_VIGATE = ' ' ) "
cSQL += " AND D_E_L_E_T_ = ' ' " 

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBPROC",.F.,.T.)
cRet := cvaltochar(iif(TRBPROC->Qtd==0,1,TRBPROC->Qtd))
TRBPROC->(dbCloseArea())
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} dePara

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function dePara(cCodPadO,cCodProO,cDatPro,cCodRda)
local aProced	:= {}
local cSql 		:= ""
local cTpProc	:= ""
local lAchou  	:= .f.
Local lEquipe	:= BR8->(FieldPos("BR8_EQUIPE")) <> 0
Local lGeraEquipe := .T.
default cDatPro := ""
default cCodRda := ""

if lPTUDEPARA
	aRet 		:= execBlock("PTUDEPARA",.F.,.F.,{cCodPadO,cCodProO,cDatPro,cCodRda})
	lAchou 	  	:= aRet[1]
	cCodPad 	:= aRet[2]
	cCodPro 	:= aRet[3]
endif

cSql := " SELECT PADTISS,PROTISS,TPPROC  "
if lEquipe
	cSql += ",EQUIPE "
endif
cSql += " FROM "+ oTmpProc:getrealName() 
cSql += " WHERE CODPAD = '"+cCodPadO+"' "
cSql += " AND CODPRO = '"+cCodProO+"' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBR8",.F.,.T.)

if !TrbBR8->(eof())
	if !lAchou
		cCodPad	:= TrbBR8->PADTISS
		cCodPro	:= TrbBR8->PROTISS
	endif
	cTpProc	:= TrbBR8->TPPROC
	if lEquipe
		lGeraEquipe := TrbBR8->EQUIPE <> "0"
	endif
endif
TrbBR8->(dbCloseArea())

// Só entra aqui em caso de itens de pacote que não estão na tabela temporaria
if empty(cTpProc)
	cSql := " SELECT BR8_CODEDI, BR8_TPPROC  "
	if lEquipe
		cSql += ", BR8_EQUIPE"
	endif
	cSql += " FROM "+ cBR8Name+ " BR8 "
	cSql += " WHERE BR8_FILIAL = '"+xFilial("BR8")+"' "
	cSql += " AND BR8_CODPAD = '"+cCodPadO+"' "
	cSql += " AND BR8_CODPSA = '"+cCodProO+"' "
	cSql += " AND BR8.D_E_L_E_T_ = ' '
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBR8",.F.,.T.)

	if !lAchou
		aProced		:= PLGETPROC(cCodPadO,cCodProO)
		cCodPad 	:= aProced[2]
		cCodPro 	:= aProced[3]
	endif
	if !TrbBR8->(eof())
		cTpProc := TrbBR8->BR8_TPPROC
		if lEquipe
			lGeraEquipe := TrbBR8->BR8_EQUIPE <> "0"
		endif
		if !lAchou
			cCodPro := ifPls(TrbBR8->BR8_CODEDI,cCodPro)
		endif
	endif

	TrbBR8->(dbCloseArea()) 
endif

//Se não achou devolvo o original
cCodPad := ifPls(cCodPad,cCodPadO)
cCodPro := ifPls(cCodPro,cCodProO)

return {cCodPad,cCodPro,cTpProc,lGeraEquipe}


//-------------------------------------------------------------------
/*/{Protheus.doc} setDate

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function setDate(cData,cHora)
local cRet := 		substr(cData,1,4) + "/" +; 
					substr(cData,5,2) + "/" + ;
			   		substr(cData,7,2)       + ;
			    	strzero(val(substr(cHora,1,2)),2)+":"+ ;
			    	strzero(val(substr(cHora,3,2)),2)+":"+ ;
			    	strzero(val(substr(cHora,5,2)),2)+"-03"

return cRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} ifPls

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function ifPls(cValor, cDefault)
return iif(empty(cValor),cDefault,cValor)


//-------------------------------------------------------------------
/*/{Protheus.doc} getInternacao

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function getInternacao(cAlias)
local aRet := {"","","","",""}
local cDtIniFt := ''
local cHrIniFt := ''
local cDtFimFt := ''
local cHrFimFt := ''
Local cDtInternacao :=  ''
Local cDtAlta	:= ''
Local cHrInternacao := ''
Local cHralta	:= ''
local cDtIniFt2 := ''
local cHrIniFt2 := ''
local cDtFimFt2 := ''
local cHrFimFt2 := ''

if empty((cAlias)->GUIINT)
	return aRet
endif

cDtIniFt := (cAlias)->DTINIF
cHrIniFt := (cAlias)->HRINIF
cDtFimFt := (cAlias)->DTFIMF
cHrFimFt := (cAlias)->HRFIMF

cSql := " SELECT BE4_DTINIF, BE4_HRINIF, BE4_DTFIMF, BE4_HRFIMF, BE4_DTALTA, BE4_HRALTA, BE4_DATPRO, BE4_HORPRO, BB8_CNES, BE4_NOMRDA, BAU_CPFCGC, BE4_CGCRDA "
cSql += " FROM " + cBE4Name + " BE4 "  
cSql += " INNER JOIN " + cBAUName + " BAU "
cSql += " ON BAU_FILIAL = '" + xfilial("BAU") + "' " 
cSql += " AND BAU_CODIGO = BE4_CODRDA " 
cSql += " AND BAU.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + cBB8Name + " BB8 "  
cSql += " ON BB8_FILIAL  = '" + xfilial("BB8") + "' " 
cSql += " AND BB8_CODIGO = BAU_CODIGO " 
cSql += " AND BB8_CODINT = '" + cCodInt + "' " 
cSql += " AND BB8_CODLOC = BE4_CODLOC  " 
cSql += " AND BB8.D_E_L_E_T_ = ' ' "
cSql += " WHERE BE4_FILIAL = '" + xfilial("BE4") + "' " 
cSql += " AND BE4_CODOPE = '" + substr((cAlias)->GUIINT,01,4) + "' " 
cSql += " AND BE4_CODLDP = '" + substr((cAlias)->GUIINT,05,4) + "' " 
cSql += " AND BE4_CODPEG = '" + substr((cAlias)->GUIINT,09,8) + "' " 
cSql += " AND BE4_NUMERO = '" + substr((cAlias)->GUIINT,17,8) + "' " 
cSql += " AND BE4.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbHM",.F.,.T.)
if TrbHM->(!eof())

	If empty(cDtFimFt) .OR. empty(cDtIniFt)
		cDtIniFt := TrbHM->BE4_DTINIF
		cHrIniFt := TrbHM->BE4_HRINIF
		cDtFimFt := TrbHM->BE4_DTFIMF
		cHrFimFt := TrbHM->BE4_HRFIMF
	endif

	cDtInternacao := TrbHM->BE4_DATPRO
	cHrInternacao := TrbHM->BE4_HORPRO
	cDtAlta := TrbHM->BE4_DTALTA
	cHralta := TrbHM->BE4_HRALTA

	aRet[3]	:= IIF(empty(TrbHM->BE4_CGCRDA) .OR. Len(alltrim(TrbHM->BE4_CGCRDA)) <> 14, IIF(empty(TrbHM->BAU_CPFCGC) .OR. Len(alltrim(TrbHM->BAU_CPFCGC)) <> 14, "", TrbHM->BAU_CPFCGC), TrbHM->BE4_CGCRDA)
	aRet[4]	:= TrbHM->BE4_NOMRDA
	aRet[5]	:= TrbHM->BB8_CNES
endif

TrbHM->(dbclosearea())

//Se não achou a data de fim de faturamento, procuro em todas as guias que tem o mesmo vinculo a este
//Principal uso em guias de honorario
if empty(cDtFimFt) .OR. empty(cDtIniFt)

	cSql := " SELECT BE4_DTINIF, BE4_HRINIF, BE4_DTFIMF, BE4_HRFIMF, BE4_DTALTA, BE4_HRALTA, BE4_DATPRO, BE4_HORPRO, BB8_CNES, BE4_NOMRDA, BAU_CPFCGC, BE4_CGCRDA "
	cSql += " FROM " + cBE4Name + " BE4 "  
	cSql += " INNER JOIN " + cBAUName + " BAU "
	cSql += " ON BAU_FILIAL = '" + xfilial("BAU") + "' " 
	cSql += " AND BAU_CODIGO = BE4_CODRDA " 
	cSql += " AND BAU.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + cBB8Name + " BB8 "  
	cSql += " ON BB8_FILIAL  = '" + xfilial("BB8") + "' " 
	cSql += " AND BB8_CODIGO = BAU_CODIGO " 
	cSql += " AND BB8_CODINT = '" + cCodInt + "' " 
	cSql += " AND BB8_CODLOC = BE4_CODLOC  " 
	cSql += " AND BB8.D_E_L_E_T_ = ' ' "
	cSql += " WHERE BE4_FILIAL = '" + xfilial("BE4") + "' " 
	cSql += " AND BE4_GUIINT = '" + (cAlias)->GUIINT + "' " 
	cSql += " AND BE4_DTFIMF  >= '" + (cAlias)->DATPRO + "' " //Pra guia de honorário, pode ser maior que a internação, pra de resumo, vai ser a data de internação
//	cSql += " AND (BE4_DTFIMF  <> '    ' OR BE4_DTALTA  <> '    ' ) " 
	cSql += " AND BE4.D_E_L_E_T_ = ' ' "
	cSql += " Order By BE4_DTINIF "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbHM",.F.,.T.)
	While TrbHM->(!eof())
		
		cDtIniFt2 := TrbHM->BE4_DTINIF
		cHrIniFt2 := TrbHM->BE4_HRINIF
		cDtFimFt2 := TrbHM->BE4_DTFIMF
		cHrFimFt2 := TrbHM->BE4_HRFIMF
		
		if !(empty(TrbHM->BE4_DTALTA))
			cDtAlta := TrbHM->BE4_DTALTA
			cHralta := TrbHM->BE4_HRALTA
		endif

		if empty(cDtIniFt2) .OR. empty(cDtFimFt2)
			cDtIniFt2 := ''
			cHrIniFt2 := ''
			cDtFimFt2 := ''
			cHrFimFt2 := ''
		elseif (cAlias)->DATPRO >= cDtIniFt2
			cDtIniFt := cDtIniFt2
			cHrIniFt := cHrIniFt2
			cDtFimFt := cDtFimFt2
			cHrFimFt := cHrFimFt2
			exit
		endif

		TrbHM->(dbskip())
	endDo
	TrbHM->(dbclosearea())
endif

//Se não encontrou pelas datas de faturamento (que é o certo), usa as datas de internação e alta
cDtIniFt := ifPls(cDtIniFt,cDtInternacao)
cHrIniFt := ifPls(cHrIniFt,cHrInternacao)
cDtFimFt := ifPls(cDtFimFt,cDtAlta)
cHrFimFt := ifPls(cHrFimFt,cHralta)

//Se não achou nada, mas nada mesmo, usa as datas de internação e alta da query de fora dessa função pra tentar preencher a variável que faltar
cDtIniFt := ifPls(cDtIniFt,(cAlias)->DATPRO)
cHrIniFt := ifPls(cHrIniFt,(cAlias)->HORPRO)
cDtFimFt := ifPls(cDtFimFt,(cAlias)->DTALTA)
cHrFimFt := ifPls(cHrFimFt,(cAlias)->HRALTA)

aRet[1] := setDate(cDtIniFt,cHrIniFt)
aRet[2] := setDate(cDtFimFt,cHrFimFt)

return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} getPacote

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function getPacote(cAlias)
local aRet := {.f.}
local cSql := ""
Local lB43Qtd := B43->(FieldPos("B43_QTDPRO")) > 0

cSql += " SELECT B43_CODPAD, B43_CODPRO, B43_NIVPAC, B43_DESPRO, B43_TIPO, B43_IDUNIC, B43_SEQPTU, R_E_C_N_O_ Recno " + iif(lB43Qtd,",B43_QTDPRO ","")
cSql += " FROM " + cB43Name + " B43 "
cSql += " WHERE  B43_FILIAL = '" + xfilial("B43") + "' "
cSql += " AND B43_CODOPE = '" +  (cAlias)->CODOPE + "' "
cSql += " AND B43_CODLDP = '" +  (cAlias)->CODLDP + "' "
cSql += " AND B43_CODPEG = '" +  (cAlias)->CODPEG + "' "
cSql += " AND B43_NUMERO = '" +  (cAlias)->NUMERO + "' "
cSql += " AND B43_ORIMOV = '" +  (cAlias)->BD6_ORIMOV + "' "
cSql += " AND B43_SEQUEN = '" +  (cAlias)->BD6_SEQUEN + "' "
cSql += " AND B43_TIPO IN ('0','5') " //0=Procedimento;5=Ortese/Protese
cSql += " AND B43.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TMPB43',.F.,.T.)

while !TMPB43->(eof())
	if TMPB43->B43_TIPO == "0"
		BR8->(msseek(xFilial("BR8")+TMPB43->(B43_CODPAD+B43_CODPRO)))
		if BR8->BR8_TIPROL == "2"
			TMPB43->(dbskip())
			loop
		endif
	endif

	aadd(aRet,{TMPB43->B43_CODPAD, alltrim(TMPB43->B43_CODPRO), TMPB43->B43_DESPRO, TMPB43->B43_TIPO, TMPB43->B43_NIVPAC, TMPB43->B43_IDUNIC,;
			   TMPB43->B43_SEQPTU, TMPB43->Recno,iif(lB43Qtd,TMPB43->B43_QTDPRO,0)})
	
	TMPB43->(dbskip())
enddo

TMPB43->(dbclosearea())

return aRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} getSeq

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function getSeq(cAlias, aPacote, lAviso ,lPea)
local cRet as char
local cSql as char
local cId  := ""
local cSeq := ""
default lAviso := .f.

if empty((cAlias)->BX6_SEQPTU) .and. len(aPacote) == 0 .or.; //Condição 'or' para casos de PEA e preencher o Id Único 2
(lPea .and. lIdUnico2 .and. empty((cAlias)->BX6_IDUNI2) .and. !(empty((cAlias)->BX6_IDUNIC)) .and. substr((cAlias)->BX6_IDUNIC, 5, 4) <> plsintpad() )

	cSql := " SELECT MAX( BX6_SEQPTU ) QTD FROM " + cBX6Name + " BX6 "
	cSql += " WHERE BX6_FILIAL = '" + xFilial('BX6') + "' "
	cSql += " AND BX6_CODOPE = '" + (cAlias)->CODOPE + "' "
	cSql += " AND BX6_CODLDP = '" + (cAlias)->CODLDP + "' "
	cSql += " AND BX6_CODPEG = '" + (cAlias)->CODPEG + "' "
	cSql += " AND BX6_NUMERO = '" + (cAlias)->NUMERO + "' "
	cSql += " AND BX6_ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' "
	cSql += " AND BX6.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBX6",.F.,.T.)
	cSeq :=  strZero( iif( !empty(TMPBX6->QTD),val(TMPBX6->QTD), 0 ) + 1, 4 )
	TMPBX6->(dbCloseArea())

	if empty((cAlias)->RecnoBx6)
		BX6->(RecLock("BX6", .T.))
		BX6->BX6_FILIAL := xFilial("BX6")
		BX6->BX6_CODOPE := (cAlias)->CODOPE
		BX6->BX6_CODLDP := (cAlias)->CODLDP
		BX6->BX6_CODPEG := (cAlias)->CODPEG
		BX6->BX6_NUMERO := (cAlias)->NUMERO
		BX6->BX6_ORIMOV := (cAlias)->BD6_ORIMOV
		BX6->BX6_SEQUEN := (cAlias)->BD6_SEQUEN
		BX6->BX6_CODPAD := (cAlias)->BD6_CODPAD
		BX6->BX6_CODPRO := (cAlias)->BD6_CODPRO	
		BX6->BX6_SEQPTU := cSeq
		BX6->BX6_IDUNIC := getIdUnic(cAlias,lAviso)
		BX6->(MsUnLock())
	else
		BX6->(dbgoto((cAlias)->RecnoBx6))
		BX6->(RecLock("BX6", .F.))		
		BX6->BX6_SEQPTU := cSeq
		if !lPea .or. empty(BX6->BX6_IDUNIC) 
			BX6->BX6_IDUNIC := getIdUnic(cAlias,lAviso)
		elseif lIdUnico2 .and. empty(BX6->BX6_IDUNI2)
			BX6->BX6_IDUNI2:=getIdUnic(cAlias,lAviso)
		endif
		BX6->(MsUnLock())	
	endif
elseif len(aPacote) == 0
	BX6->(dbgoto((cAlias)->RecnoBx6))
endif
cRet	:= BX6->BX6_SEQPTU
cId 	:= iif( lIdUnico2 .and. !empty(BX6->BX6_IDUNI2) , BX6->BX6_IDUNI2 , BX6->BX6_IDUNIC )


if len(aPacote) > 0 
	
	cSql := " SELECT B43_IDUNIC, B43_SEQPTU FROM " + cB43Name + " B43 "
	cSql += " WHERE B43.R_E_C_N_O_ = " + cvaltochar(aPacote[8])
	cSql += " AND B43.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPB432",.F.,.T.)
	cId := TMPB432->B43_IDUNIC
	cRet := TMPB432->B43_SEQPTU
	TMPB432->(dbCloseArea())

	if empty(cId)
		cSql := " SELECT MAX( B43_SEQPTU ) QTD FROM " + cB43Name + " B43 "
		cSql += " WHERE B43_FILIAL = '" + xfilial('B43') + "' "
		cSql += " AND B43_CODOPE = '" + (cAlias)->CODOPE + "' "
		cSql += " AND B43_CODLDP = '" + (cAlias)->CODLDP + "' "
		cSql += " AND B43_CODPEG = '" + (cAlias)->CODPEG + "' "
		cSql += " AND B43_NUMERO = '" + (cAlias)->NUMERO + "' "
		cSql += " AND B43_ORIMOV = '" + (cAlias)->BD6_ORIMOV + "' "
		cSql += " AND B43.D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPB43",.F.,.T.)
		cSeq :=  "9" + Substr(strZero( iif( !empty(TMPB43->QTD),val(TMPB43->QTD), 0 ) + 1, 4 ),2,3)
		TMPB43->(dbCloseArea())
		B43->(dbgoto(aPacote[8]))
		B43->(RecLock("B43", .F.))		
		B43->B43_SEQPTU := cSeq
		B43->B43_IDUNIC := getIdUnic(cAlias,lAviso)
		B43->(MsUnLock())	
		cRet := cSeq
		cId	:= B43->B43_IDUNIC
	endif	
endif

return {cRet,cId}


//-------------------------------------------------------------------
/*/{Protheus.doc} PTU500DMA

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PTU500DMA()
local cMark := oMBrw:cMark 

cSql := "UPDATE " + cBTOName + " SET BTO_OK = ' ' " 
cSql += " WHERE BTO_OK = '" + cMark + "'"

PLSCOMMIT(cSql)

oMBrw:oBrowse:Refresh(.t.)

return .T.


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

aAdd( aColumns, { "CODOPE",	"C",	04,00 })
aAdd( aColumns, { "CODLDP",	"C",	04,00 })
aAdd( aColumns, { "CODPEG",	"C",	08,00 })
aAdd( aColumns, { "NUMERO",	"C",	08,00 })
aAdd( aColumns, { "ORIMOV",	"C",	01,00 })
aAdd( aColumns, { "TIPGUI",	"C",	02,00 })
aAdd( aColumns, { "CODRDA",	"C",	06,00 })
aAdd( aColumns, { "BD7_CODRDA",	"C",06,00 })
aAdd( aColumns, { 'CODPAD',	'C', 	02,00 })
aAdd( aColumns, { 'CODPRO',	'C', 	16,00 })
aAdd( aColumns, { 'SEQUEN',	'C', 	03,00 })
aAdd( aColumns, { 'CODUNM',	'C', 	03,00 })
aAdd( aColumns, { 'NLANC',	'C', 	02,00 })
aAdd( aColumns, { 'CDPFPR',	'C', 	06,00 })
aAdd( aColumns, { 'SIGLA' ,	'C', 	07,00 })
aAdd( aColumns, { 'REGPRE',	'C', 	15,00 })
aAdd( aColumns, { 'ESTPRE',	'C', 	02,00 })
aAdd( aColumns, { 'ESPEXE',	'C', 	03,00 })
aAdd( aColumns, { 'CODTPA',	'C', 	02,00 })
aAdd( aColumns, { 'CODESP',	'C', 	03,00 })
aAdd( aColumns, { 'VLRTPF',	'N', 	17,02 })
aAdd( aColumns, { 'VLRTAD',	'N', 	17,02 })
aAdd( aColumns, { 'BLOPAG',	'C', 	01,00 })
aAdd( aColumns, { 'MOTBPG',	'C', 	03,00 })
oTmpTable := FWTemporaryTable():New(cAlias)
oTmpTable:SetFields( aColumns )
oTmpTable:Create()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaBase
Cria tabela temporaria da base a ser processada.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
static function fCriaProc(cAlias,oTmpTable)
local aColumns	 := {}
local lEquipe := BR8->(fieldPos("BR8_EQUIPE")) <> 0
	
if Select(cAlias) > 0
	if oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	endif 	
endif 

aAdd( aColumns, { 'CODPAD',	'C', 	02,00 })
aAdd( aColumns, { 'CODPRO',	'C', 	16,00 })
aAdd( aColumns, { 'PADTISS','C', 	02,00 })
aAdd( aColumns, { 'PROTISS','C', 	16,00 })
aAdd( aColumns, { 'TPPROC',	'C', 	01,00 })

if lEquipe
	aAdd( aColumns, { 'EQUIPE',	'C', 	01,00 })
endif

oTmpTable := FWTemporaryTable():New(cAlias)
oTmpTable:SetFields( aColumns )
oTmpTable:Create()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} setProcedimentos

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function setProcedimentos(cDatabase)
local cConcat := iif(cDatabase == "ORACLE" .or. cDatabase == "POSTGRES","||","+")
local cNull	  := iif(cDatabase == "ORACLE","NVL",iif(cDatabase == "POSTGRES","COALESCE","ISNULL"))
local lEquipe := BR8->(FieldPos("BR8_EQUIPE")) <> 0
local ccampoIns := ""

// Insert procedimentos
cSql 	:= " SELECT CODPAD,CODPRO,"+cNull+"(BTU_CODTAB,' '),CASE BR8_CODEDI WHEN ' ' THEN "+cNull+"(BTU_CDTERM,' ') ELSE BR8_CODEDI END,BR8_TPPROC "
if lEquipe
	csql += " , BR8_EQUIPE "
endif
csql 	+= " FROM  ( "
cSql 	+= " 	SELECT CODPAD,CODPRO FROM  "
cSql 	+= " 		( SELECT CODPAD,CODPRO FROM " + oTmpBase:getrealName() + " GROUP BY CODPAD,CODPRO ) A "
cSql 	+= " 	WHERE CODPAD"+cConcat+"CODPRO NOT IN( SELECT CODPAD"+cConcat+"CODPRO FROM " + oTmpProc:getrealName() + " ) ) B "
cSql 	+= " INNER JOIN " + cBR8Name + " BR8 "
cSql 	+= " ON BR8_FILIAL = '" + xfilial("BR8") + "'"	
cSql 	+= " AND BR8_CODPAD = CODPAD "
cSql 	+= " AND BR8_CODPSA = CODPRO "
cSql 	+= " AND BR8.D_E_L_E_T_ = ' ' "
cSql 	+= " LEFT JOIN " + cBTUName + " BTU "
cSql 	+= " ON BTU_FILIAL = '" + xfilial("BTU") + "'"
cSql 	+= " AND BTU_ALIAS = 'BR8' "
cSql 	+= " AND BTU_VLRSIS = '" + xfilial("BR8") + "'"+cConcat+"CODPAD"+cConcat+"CODPRO "
cSql 	+= " AND BTU.D_E_L_E_T_ = ' ' "

ccampoIns := " (CODPAD,CODPRO,PADTISS,PROTISS,TPPROC"
if lEquipe
	ccampoIns += ",EQUIPE"
endif
ccampoIns += ") "

cISql 	:= " Insert Into " +  oTmpProc:getrealName() + ccampoIns + cSql
PLSCOMMIT(cISql)

return


//-------------------------------------------------------------------
/*/{Protheus.doc} getIdUnic

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function getIdUnic(cAlias,lAviso)
local cSeq := ""
local cSql := ""
local cAno := ""
local cMes := ""
default lAviso := .f.

if !lAviso
	cAno := BTO->BTO_ANOINI
	cMes := BTO->BTO_MESINI
else
	cAno := cvaltochar(year(B2S->B2S_DATTRA))
	cMes := strzero(month(B2S->B2S_DATTRA),2)
endif

lock("PLSUA500X")

cSql := " SELECT MAX(IDUNIC) IDUNIC FROM ( "
cSql += " SELECT MAX( BX6_IDUNIC ) IDUNIC FROM " + cBX6Name + " BX6 "
cSql += " WHERE BX6_FILIAL = '" + xFilial('BX6') + "' "
cSql += " AND BX6_CODOPE = '" + (cAlias)->CODOPE + "' "
cSql += " AND SUBSTRING(BX6_IDUNIC,1,8) = '" + substr(cAno,3,2)+cMes+(cAlias)->CODOPE + "' "
cSql += " AND BX6.D_E_L_E_T_ = ' ' "
cSql += " UNION ALL "
cSql += " SELECT MAX( B43_IDUNIC ) IDUNIC FROM " + cB43Name + " B43 "
cSql += " WHERE B43_FILIAL = '" + xFilial('B43') + "' "
cSql += " AND B43_CODOPE = '" + (cAlias)->CODOPE + "' "
cSql += " AND SUBSTRING(B43_IDUNIC,1,8) = '" + substr(cAno,3,2)+cMes+(cAlias)->CODOPE + "' "
cSql += iif(!lIdUnico2," AND B43.D_E_L_E_T_ = ' ' ) X ","")
if lIdUnico2
	cSql += " AND B43.D_E_L_E_T_ = ' ' "
	cSql += " UNION ALL "
	cSql += " SELECT MAX( BX6_IDUNI2 ) IDUNIC FROM " + cBX6Name + " BX6 "
	cSql += " WHERE BX6_FILIAL = '" + xFilial('BX6') + "' "
	cSql += " AND BX6_CODOPE = '" + (cAlias)->CODOPE + "' "
	cSql += " AND SUBSTRING(BX6_IDUNI2,1,8) = '" + substr(cAno,3,2)+cMes+(cAlias)->CODOPE + "' "
	cSql += " AND BX6.D_E_L_E_T_ = ' ' ) X "
endif

cSql := PLSConSQL(cSql)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPUNC",.F.,.T.)
cSeq :=  strZero( iif( !empty(TMPUNC->IDUNIC),val(substr(TMPUNC->IDUNIC,9,20))+1, 0 ), 20 )
TMPUNC->(dbCloseArea())

lock("PLSUA500X",.t.)

return substr(cAno,3,2)+cMes+(cAlias)->CODOPE+cSeq


//-------------------------------------------------------------------
/*/{Protheus.doc} lock
Controle de semaforo

@author    Lucas Nonato
@version   V12
@since     10/04/2019
/*/
static function lock(cName, lLibera )
local lOk as logical
default lLibera := .f.

lOk := .t.

if !lLibera
	while lOk 
		if LockByName(cName, .T., .T.)
			lOk := .f.
		endif
	enddo
else
	UnlockByName(cName, .T., .T.)
endif

return .t.


//-------------------------------------------------------------------
/*/{Protheus.doc} PTU520BASE

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PTU520BASE(lAuto)
local cSql 			as char
local cISql			as char
local cAliTmp		:= getNextAlias()
local cAliPrc		:= getNextAlias()
local cAliasB2S		:= getNextAlias()
local aParam        := {} 
local aMsg     		:= {} 
local nQtd     		:= 0
local nRecnoD2 		:= 0
local cDatabase		:= upper(TCGetDb())
private oTmpBase	:= nil
private oTmpProc	:= nil
default lAuto 		:= .f.

fCriaBase(cAliTmp,@oTmpBase) 
fCriaProc(cAliPrc,@oTmpProc) 

if !lAuto
	if !PLSU500PER(aParam)
		return
	endif
else
	aadd(aParam,1)
	aadd(aParam,cDirTmp  )//Futuramente trocar pelo esquema de caixa de entrada e caixa de saida na pasta PLSPTU.
endif

cSql := " SELECT COUNT(*) QTD FROM " + retsqlname("B2S") + " B2S "
cSql += " WHERE B2S_OK = '" + oMBrwB2S:cMark + "'" 
cSql += " AND B2S.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'QTDB2S',.F.,.T.)
nQtd := QTDB2S->QTD
QTDB2S->(dbclosearea())

cSql := " SELECT R_E_C_N_O_ RECNO FROM " + retsqlname("B2S") + " B2S "
cSql += " WHERE B2S_OK = '" + oMBrwB2S:cMark + "'" 
cSql += " AND B2S.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasB2S,.F.,.T.)

oProcess:SetRegua1( nQtd )
oProcess:SetRegua2( -1 )
CINI := time()
while (cAliasB2S)->(!eof())
	B2S->(dbgoto((cAliasB2S)->RECNO))
		
PLSCOMMIT("DELETE FROM " + oTmpBase:getrealName())

	cSql := " SELECT BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_TIPGUI, BD6_CODRDA, BD7_CODPAD, BD7_CODPRO, BD7_SEQUEN, BD7_CODUNM,"
	cSql += " BD7_NLANC, BD7_CDPFPR, BD7_SIGLA, BD7_REGPRE, BD7_ESTPRE, BD7_ESPEXE, BD7_CODTPA, BD7_CODESP, BD7_VLRTPF, BD7_VLRTAD,BD7_BLOPAG, coalesce(trim(BD6_MOTBPG),'   ') "
	cSql += " FROM " + retSqlName("BD7") + " BD7 " + " , " + retSqlName("BD6") + " BD6 "
	cSql += " WHERE BD7.D_E_L_E_T_ = ' ' " 
	cSql += " AND BD7.BD7_FILIAL = '"+xFilial("BD7")+"'  "
	cSql += " AND BD7.BD7_CODOPE = '"+B2S->B2S_OPEHAB +"' 
	cSql += " AND BD6.D_E_L_E_T_ = ' ' "
	cSql += " AND BD6.BD6_FILIAL = '"+xFilial("BD6")+"'  "
	cSql += " AND BD6.BD6_CODOPE = '"+B2S->B2S_OPEHAB +"' 
	cSql += " AND BD7_CODLDP = BD6_CODLDP  "
	cSql += " AND BD7_CODPEG = BD6_CODPEG  "
	cSql += " AND BD7_NUMERO = BD6_NUMERO  "
	cSql += " AND BD7_ORIMOV = BD6_ORIMOV  "
	cSql += " AND BD7_SEQUEN = BD6_SEQUEN  "
	cSql += " AND BD6_SITUAC = '1' "
	csql += " AND EXISTS (SELECT 1 " 
	csql += " FROM " + retSqlName("B5S") + " B5S "
	csql += " WHERE B5S_FILIAL = '"+xFilial("B5S")+"'  "	
	cSql += " AND B5S_NUMLOT = '"+B2S->B2S_NUMLOT+"' "
	cSql += " AND B5S.D_E_L_E_T_ = ' ' "
	cSql += " AND B5S_CODOPE =  '"+B2S->B2S_OPEHAB +"' 
	cSql += " AND B5S_CODPEG =  BD6_CODPEG "
	cSql += " AND B5S_NUMERO =  BD6_NUMERO "
	cSql += " AND B5S_CODLDP =  BD6_CODLDP ) "
	
	cISql := " Insert Into " +  oTmpBase:getrealName() + " (CODOPE,CODLDP,CODPEG,NUMERO,ORIMOV,TIPGUI,CODRDA,CODPAD,CODPRO,SEQUEN,"
	cISql += "CODUNM,NLANC,CDPFPR,SIGLA,REGPRE,ESTPRE,ESPEXE,CODTPA,CODESP,VLRTPF,VLRTAD,BLOPAG,MOTBPG) " + cSql 

	PLSCOMMIT(cISql)

	//Retirado das condições da consulta principal por questões de performance
	//PLSCOMMIT(" DELETE FROM " + oTmpBase:getrealName() +" WHERE (BLOPAG = '1' AND MOTBPG NOT IN ('066', '067', '068'))")

	setProcedimentos(cDatabase)

	cSql := "SELECT COUNT(*) QTD FROM (SELECT CODPEG, NUMERO FROM " + oTmpBase:getrealName() + " GROUP BY CODPEG, NUMERO ) A
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbFim",.F.,.T.)
	nTotReg 	 := TrbFim->QTD	
	TrbFim->(dbCloseArea())	
	if nTotReg > 0
		processa(aParam,aMsg,@nRecnoD2,nTotReg,.t.,lAuto)
	else
		aadd(aMsg,{B2S->B2S_OPEORI, B2S->B2S_NUMLOT, "Nenhuma guia encontrada."})
	endif 
    
	B2S->(recLock("B2S",.f.))
	B2S->B2S_STATUS = '2'
	B2S->(msUnLock())
	
	(cAliasB2S)->(dbskip())
enddo
cElapsed := ElapTime( CINI, TIME() ) 
if !lAuto .and. len(aMsg) > 0
	PLSCRIGEN(aMsg,{ {"Unimed","@C",6},{"Lote","@C",8},{"Mensagem","@C",250} }, "Log de Exportação",NIL,NIL,NIL,NIL, NIL,NIL,"G",220) 
endif 

(cAliPrc)->(dbclosearea())
(cAliTmp)->(dbclosearea())

oTmpProc:Delete()
freeObj(oTmpProc)               
oTmpProc := nil

oTmpBase:Delete()
freeObj(oTmpBase)               
oTmpBase := nil

return aMsg


//-------------------------------------------------------------------
/*/{Protheus.doc} getNomArq
retorna o nome do arquivo para envio de lotes de aviso(A520)

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
static function getNomArq()
local cNumSeq := ""
Local cRet := ""
Local cSqL := ""

if empty(B2S->B2S_DATENV) .OR. dDataBase <> B2S->B2S_DATENV
	cSql += " Select MAX(B2S_NUMSEQ) NUMSEQ From " + RetSqlName("B2S")
	cSql += " Where "
	cSql += " B2S_FILIAL = '" + xFilial("B2S") + "' AND "
	cSql += " B2S_DATENV = '" + DtoS(dDataBase) + "' AND "
	cSql += " D_E_L_E_T_ = ' ' "
	cSql := Changequery(cSql)	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TMPB2S',.F.,.T.)

	if TMPB2S->(EoF())
		cNumSeq := Strzero(1,TamSX3("B2S_NUMSEQ")[1])
	else
		cNumSeq := Strzero( Val(TMPB2S->NUMSEQ) + 1 ,TamSX3("B2S_NUMSEQ")[1])
	endif

	TMPB2S->(dbclosearea())

	B2S->(reclock("B2S",.f.))
		B2S->B2S_NUMSEQ := cNumSeq
		B2S->B2S_DATENV := dDataBase
	B2S->(msunlock())
endif

cNumSeq := CVALTOCHAR(Right(B2S->B2S_NUMSEQ,3))
cRet := "AV"+substr(dtos(B2S->B2S_DATENV),7,2)+substr(dtos(B2S->B2S_DATENV),5,2)+substr(dtos(B2S->B2S_DATENV),3,2)+cNumSeq

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA520X
Rotina de Aviso Lote Guias - Envio

@author  Lucas Nonato
@since   18/12/2020
@version P12
/*/
function PLSUA520X(lAuto,aMsg)
default lAuto 	:= .f.
default aMsg 	:= {}
cCodInt := plsintpad()

if existBlock("PLS500UNM")
	aRet := execBlock("PLS500UNM",.F.,.F.,{cServ,cAux,cAnest,cCusOpe,cFilm})
	cServ 	:= aRet[1]
	cAux 	:= aRet[2]
	cAnest 	:= aRet[3]
	cCusOpe	:= aRet[4]
	cFilm 	:= aRet[5]
endif 

cCusOpe := strtran("'"+cCusOpe+"'",",","','")
cFilm 	:= strtran("'"+cFilm+"'",",","','")

if !lAuto
	PLSU520BRW()
else
	aMsg := PTU520EXP(.t.)
endif

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PtuStTran
Remover Caracter especial e aplicar o encode

@author  Thiago
@since   18/12/2020
@version P12
/*/
Static Function PtuStTran(cConteudo)
default cConteudo := " "

cConteudo :=  PlRetPonto(cConteudo)

cConteudo := encodeUtf8(cConteudo,'ISO-8859-1')

return(cConteudo)


//-------------------------------------------------------------------
/*/{Protheus.doc} SigConsReg
Retorna a sigla do conselho regional
@author  Eduardo Bento
@since   23/02/2021
@version P12
/*/
Static Function SigConsReg(cNumSgCnRg)
Local cSigConReg := ""
	
Do Case
	Case Val(cNumSgCnRg) == 1
		cSigConReg := "CRESS"
	Case Val(cNumSgCnRg) == 2
		cSigConReg := "COREN"
	Case Val(cNumSgCnRg) == 3
		cSigConReg := "CRF"
	Case Val(cNumSgCnRg) == 4
		cSigConReg := "CREFONO"
	Case Val(cNumSgCnRg) == 5
		cSigConReg := "CREFITO"
	Case Val(cNumSgCnRg) == 6
		cSigConReg := "CRM"
	Case Val(cNumSgCnRg) == 7
		cSigConReg := "CRV"
	Case Val(cNumSgCnRg) == 8
		cSigConReg := "CRN"
	Case Val(cNumSgCnRg) == 9
		cSigConReg := "CRO"
	Case Val(cNumSgCnRg) == 10
		cSigConReg := "CRP"
	OtherWise
		cSigConReg := "OUT"
EndCase

Return cSigConReg


//-------------------------------------------------------------------
/*/{Protheus.doc} tp_doc
Converte o BTO_TPMOV pro esperado da tag tp_documento
@version   V12
@since     07/2022
/*/
//-------------------------------------------------------------------
static function tp_doc(cTipo)
Local cRet := ""
Default cTipo := ""

cRet := cTipo

if cTipo == "2"
	cRet := "1"
elseif cTipo == "1"
	cRet := "4"
endif

//como na reapresentação o BTO_TPMOV é copia do BTO original 
//é necessário forçar para NDC pois é o previsto no manual
if lReapTPJ
	cRet := '4'
endif

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PRecupTipGui
Recupera o tipo de guia original, que originou o recurso de glosa
cTipPesq: "T" - Tipo de Guia / "N" - Número Guia
@version   V12
@since     08/2022
/*/
//-------------------------------------------------------------------
method PRecupTipGui(cTipPesq) class PTUA500
local cAlias 		:= ::cAlias
local cAliasTmp		:= GetNextAlias()
local cTipGuiO		:= ""
default cTipPesq	:= "T"

BeginSql  Alias cAliasTmp
	SELECT B4D.B4D_TIPGUI, B4D.B4D_OPEMOV, B4D.B4D_CODLDP, B4D.B4D_CODPEG, B4D.B4D_NUMAUT, B4D.R_E_C_N_O_ 
		FROM %table:B4D% B4D
	WHERE
		B4D.B4D_FILIAL = %xFilial:B4D% AND
		B4D.B4D_DCDDLP = %Exp:(cAlias)->CODLDP% AND
		B4D.B4D_DCDPEG = %Exp:(cAlias)->CODPEG% AND
		B4D.B4D_DNUMER = %Exp:(cAlias)->NUMERO% AND
		B4D.%NotDel%
EndSql

if ( (cAliasTmp)->(!eof()) )
	cTipGuiO := iif( cTipPesq == "T", (cAliasTmp)->B4D_TIPGUI, (cAliasTmp)->(B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT) )
endif	
(cAliasTmp)->(DbCloseArea())

return cTipGuiO


//-------------------------------------------------------------------
/*/{Protheus.doc} PBlocoReapre
Monta Bloco de reapresentação da guia.
@version   V12
@since     08/2022
/*/
//-------------------------------------------------------------------
method PBlocoReapre(cCodPeg, cDoc1Gl, cDoc2Gl, cNumOper) class PTUA500
default cCodPeg 	:= padr(cCodPeg, 12, "")
default cDoc1Gl 	:= padr(cDoc1Gl, 20, "")
default cDoc2Gl 	:= iif(empty(cDoc2Gl), "", padr(cDoc2Gl, 20, ""))
default cNumOper 	:= padr(cNumOper, 20, "")

::MontaTag( 4,"reapresentacaoGlosado")
	::MontaTag( 5,"nr_DOC1Glosado", cDoc1Gl)
	::MontaTag( 5,"nr_DOC2Glosado", cDoc2Gl)

	::MontaTag( 5,"DadosLoteGuia")
		::MontaTag( 6,"XML")
			::MontaTag( 7,"nr_LotePrestador", cCodPeg)
			::MontaTag( 7,"nr_GuiaTissPrestador", cNumOper)
		::MontaTag( 6,"XML",,.t.)
	::MontaTag( 5,"DadosLoteGuia",,.T.)
::MontaTag( 4,"reapresentacaoGlosado",, .t.)

return

/*/{Protheus.doc} CriTitReap
	(Cria título na SE1 e grava os valores do lote)
	@type  Static Function
	@author Thiago Rodrigues
	@since 15/09/2022
	@see (links_or_references)
/*/
Static Function CriTitReap()
local cAliasBA0 := GetNextAlias()
local cAliasBD6 := GetNextAlias()
local cAliasBTO := GetNextAlias()
local cAliasBTF := GetNextAlias()
local cPrefixo  := GetNewPar("MV_PLPFE12",'"PLS"')// Lote de faturameto intercambio eventual.
local cNumero   := ""
local cTipTit   := getNewPar("MV_PLSTIP", "DP ")
local cLoteImp  := "BTO|" + BTO->BTO_NUMERO
local nVlrTot   := 0
local nTotTax   := 0
local nDiasVcto	:= GetNewPar("MV_PLVCTTC", 10)
local nRecBKP   := BTO->(Recno())
local lErro     := .f.
local aCampos   := {}

private lMsErroAuto := .f.

cPrefixo := Eval({|| &cPrefixo })
cNumero:= nxtSX5Nota(cPrefixo,.T.,"1",nil,"BK","PLS")

//Busca o Cliente a ser utilizado na criação do Título
BeginSql  Alias cAliasBA0
	SELECT 
		SA1.R_E_C_N_O_ Recno
	FROM %table:BA0% BA0
		INNER JOIN %table:SA1% SA1
		ON  SA1.A1_FILIAL = %xFilial:SA1%
		AND SA1.A1_COD    = BA0.BA0_CODCLI
		AND SA1.A1_LOJA   = BA0.BA0_LOJCLI
		AND SA1.%NotDel%
	WHERE 
		BA0.BA0_FILIAL = %xFilial:BA0% 
		AND BA0.BA0_CODIDE = %Exp:substr(BTO->BTO_OPEORI,1,1)% 
		AND BA0.BA0_CODINT = %Exp:substr(BTO->BTO_OPEORI,2,3)% 
		AND BA0.%NotDel%
EndSql

if (cAliasBA0)->(eof())
	MsgInfo("Cliente não localizado", "Atenção")
	return
endif

//Posiciona no cliente
SA1->(dbgoto((cAliasBA0)->Recno))
(cAliasBA0)->(dbclosearea())

//Busca os valores para criação do título e atualização do lote
BeginSql  Alias cAliasBD6
	SELECT 
		BD6_VLRTPF VLRTPF, BD6_VLRTAD VLRTAD
	FROM %table:BD6% BD6
		LEFT JOIN  %table:BCI% BCI
		ON  BCI.BCI_FILIAL = %xFilial:BCI%
		AND BCI.BCI_CODOPE = BD6.BD6_CODOPE
		AND BCI.BCI_CODLDP = BD6.BD6_CODLDP
		AND BCI.BCI_CODPEG = BD6.BD6_CODPEG
	WHERE 
		BD6.BD6_FILIAL = %xFilial:BD6% 
		AND BCI.BCI_LOTEDI = %Exp:cLoteImp%
		AND BCI.%NotDel%
		AND BD6.%NotDel%
EndSql

while !(cAliasBD6)->(eof())
	nVlrTot += (cAliasBD6)->VLRTPF
	nTotTax += (cAliasBD6)->VLRTAD
	(cAliasBD6)->(dbSkip())
enddo
(cAliasBD6)->(dbclosearea())

if nVlrTot > 0
	aAdd(aCampos, {"E1_FILIAL" , xfilial("SE1")			, Nil})
	aadd(aCampos, {"E1_PREFIXO", cPrefixo				, Nil})
	aadd(aCampos, {"E1_NUM"    , cNumero				, Nil})
	aadd(aCampos, {"E1_PARCELA", ' '					, Nil})
	aadd(aCampos, {"E1_TIPO"   , cTipTit				, Nil})
	aadd(aCampos, {"E1_NATUREZ", SA1->A1_NATUREZ		, Nil})
	aadd(aCampos, {"E1_CLIENTE", SA1->A1_COD			, Nil})
	aadd(aCampos, {"E1_LOJA"   , SA1->A1_LOJA			, Nil})
	aadd(aCampos, {"E1_NOMCLI" , SA1->A1_NOME			, Nil})
	aadd(aCampos, {"E1_EMISSAO", dDataBase				, Nil})
	aadd(aCampos, {"E1_VENCTO" , dDataBase+nDiasVcto	, Nil})
	aadd(aCampos, {"E1_VENCREA", dataValida(dDataBase+nDiasVcto,.T.), Nil})
	aadd(aCampos, {"E1_VALOR"  , nVlrTot          		, Nil})
	aadd(aCampos, {"E1_HIST"   , ''		                , Nil})
	aadd(aCampos, {"E1_ORIGEM" , "PLSUA500"		    	, Nil})
	aadd(aCampos, {"E1_CODINT" , cCodInt				, Nil})
	aadd(aCampos, {"E1_BASEIRF", 0				        , Nil})
	aadd(aCampos, {"E1_BASEPIS", 0	     				, Nil})
	aadd(aCampos, {"E1_BASECOF", 0						, Nil})
	aadd(aCampos, {"E1_BASECSL", 0		        		, Nil})
	aadd(aCampos, {"E1_BASEINS", 0	            		, Nil})
	aadd(aCampos, {"E1_BASEISS", 0		        		, Nil})
	aadd(aCampos, {"E1_IRRF"   , 0 		              	, Nil})
	aadd(aCampos, {"E1_MULTNAT", "2"             		, Nil})
	aadd(aCampos, {'E1_DECRESC', 0               		, Nil})
	aadd(aCampos, {'E1_SDDECRE', 0               		, Nil})
	aadd(aCampos, {'E1_ACRESC' , 0               		, Nil})
	aadd(aCampos, {'E1_SDACRES', 0               		, Nil})
	aadd(aCampos, {'E1_INSS'   , 0               		, Nil})
	aadd(aCampos, {'E1_COFINS' , 0               		, Nil})
	aadd(aCampos, {'E1_PIS'	   , 0               		, Nil})
	aadd(aCampos, {'E1_IRRF'   , 0  	             	, Nil})
	aadd(aCampos, {'E1_CSLL'   , 0	                	, Nil})
	aadd(aCampos, {'E1_ISS'    , 0				 		, Nil})
	aadd(aCampos, {'E1_VRETIRF', 0 						, Nil})

	msExecAuto({|x,y| Fina040(x,y)}, aCampos, 3) //Inclusao

	if lMsErroAuto
		lErro := .t.
		SE1->( rollBackSX8() )
		mostraerro()
	endif

else
	lErro := .t.
endif

//Atualiza os valores do Lote e adiciona o título
if !lErro
	//Busca o BTO
	BeginSql  Alias cAliasBTO
	SELECT 
		BTO.R_E_C_N_O_ RECNO
	FROM %table:BTO% BTO
	WHERE 
		BTO.BTO_FILIAL = %xFilial:BTO% 
		AND BTO.BTO_NUMERO = %Exp:Right(Alltrim(cLoteImp),8)%
		AND BTO.%NotDel%
	EndSql
	
	//Atualiza os valores e numero do título
	if !(cAliasBTO)->(eof())
		BTO->(DBGoTo((cAliasBTO)->RECNO))
		BTO->( RecLock("BTO",.f.) )
			BTO->BTO_VLRCOP := nVlrTot-nTotTax
			BTO->BTO_VLRTAX := nTotTax
			BTO->BTO_CUSTOT := nVlrTot
			BTO->BTO_PREFIX := SE1->E1_PREFIXO
			BTO->BTO_NUMTIT := SE1->E1_NUM
			BTO->BTO_PARCEL := SE1->E1_PARCELA
			BTO->BTO_TIPTIT := SE1->E1_TIPO
		BTO->(MsUnLock())
	endif
	(cAliasBTO)->(dbclosearea())
	BTO->(DBGoTo(nRecBKP)) //Devolve o BTO posicionado no browse

	//Busca BTF
	BeginSql  Alias cAliasBTF
	SELECT 
		BTF.R_E_C_N_O_ RECNO
	FROM %table:BTF% BTF
	WHERE 
		BTF.BTF_FILIAL = %xFilial:BTF% 
		AND BTF.BTF_NUMERO = %Exp:Right(Alltrim(cLoteImp),8)%
		AND BTF.%NotDel%
	EndSql

	//Atualiza os valores e numero do título
	if !(cAliasBTF)->(eof())
		BTF->(DBGoTo((cAliasBTF)->RECNO))
		BTF->( RecLock("BTF",.f.) )
			BTF->BTF_VLRCOP := nVlrTot-nTotTax
			BTF->BTF_VLRTAX := nTotTax
			BTO->BTO_CUSTOT := nVlrTot
		BTF->(MsUnLock())
	endif
	(cAliasBTF)->(dbclosearea())
endif	


Return 


/*/{Protheus.doc} PLTELREAP
	Necessário para atualizar o Browse,
    senão os novos registros de reapresentação ficam travados.
	@type  Function
	@author Thiago 
	@since 26/09/2022
	@version version
	@example
	(examples)
	@see (links_or_references)
	/*/
Function PLTELREAP()
PLSUA500R()
oMBrw:Refresh()

if !empty(bkpFilter)
	oMBrw:SetFilterDefault(cFilter)
endif
Return 
