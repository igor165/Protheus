#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE THREADSLOCK iif(GetNewPar("MV_PLJOBMN", 5) > 15, 15, GetNewPar("MV_PLJOBMN", 5))

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM270PRE

@author  Lucas Nonato
@since   26/02/2019
@version P12
/*/
function PLSM270PRE

local aPergs	:= {}
local aOrdCmp   := {}
local aStruc    := {}
local aFilter   := {}
local cComp		:= space(6)
local cSql      := ""
local oTempTable := nil

private aRotina := {{ "Selecionar"    ,'msgRun( "Abrindo janela de detalhes...","Carregando, por favor aguarde",{|| P270PREDET(TMPPRE->ALIAS) } )'  , 0, MODEL_OPERATION_VIEW , 0, Nil}}  

aAdd( aPergs,{ 1, "Competencia" , 	cComp	, "@R 9999/99", "", ""		, "", 50, .t.})

if( !paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSM270PRE',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	return
endIf

aadd(aStruc,{"CMPLOT"   ,"C",6,0})
aadd(aStruc,{"CODCMP"   ,"C",10,0})
aadd(aStruc,{"CODCRI"   ,"C",4,0})
aadd(aStruc,{"DESCRI"   ,"C",200,0})
aadd(aStruc,{"QTD"      ,"C",5,0})
aadd(aStruc,{"ALIAS"    ,"C",3,0})
aadd(aStruc,{"SUSEP"    ,"C",6,0})

oTempTable := FWTemporaryTable():New( "TMPPRE" )
oTemptable:SetFields( aStruc )
oTempTable:Create()

cSql += " SELECT B4P_CMPLOT, B4P_CDCMGU, B4P_CDCMER, B4P_DESERR, COUNT(*) QTD, ALIAS, SUSEP FROM ( "
cSql += "	SELECT B4N_FILIAL, B4N_CMPLOT, B4N_NUMLOT, B4N_NMGOPE, CASE WHEN B4N_TPEVAT = '3' THEN 'BE4' ELSE 'BD5' END as ALIAS, B4N_SUSEP SUSEP FROM " + RetSqlName("B4N") + " B4N "
cSql += "	WHERE B4N_FILIAL = '" + xFilial("B4N") + "' "
cSql += "	AND B4N_CMPLOT = '" + aFilter[1] + "' "
cSql += "	AND B4N_STATUS = '2' " 
cSql += "	AND (B4N_ORIERR = '1' OR B4N_ORIERR = ' ' )" 
cSql += "	AND B4N_LOTREP = ' ' "
cSql += "	AND B4N.D_E_L_E_T_ = ' ' ) TMP "
cSql += " INNER JOIN " + RetSqlName("B4P") + " B4P "
cSql += " ON B4P_FILIAL = B4N_FILIAL  "
cSql += " AND B4P_CMPLOT = B4N_CMPLOT  "
cSql += " AND B4P_NUMLOT = B4N_NUMLOT  "
cSql += " AND B4P_NMGOPE = B4N_NMGOPE "
cSql += " AND B4P.D_E_L_E_T_ = ' ' "
cSql += " GROUP BY B4P_CMPLOT, B4P_CDCMER, B4P_CDCMGU, B4P_DESERR, ALIAS, SUSEP ORDER BY COUNT(*) DESC "
cSql := changequery(cSql)

cSql := " Insert Into " +  oTempTable:getrealName() + " (CMPLOT, CODCMP, CODCRI, DESCRI, QTD, ALIAS, SUSEP) " + cSql 
PLSCOMMIT(cSql)

TMPPRE->(dbselectarea("TMPPRE"))

oBrwMaster := FWmBrowse():New()
oBrwMaster:SetAlias( 'TMPPRE' )
oBrwMaster:SetDescription( 'Conferencia Pré-Envio' ) 
oBrwMaster:SetMenuDef("PLSM270PRE")
oBrwMaster:DisableDetails()
oBrwMaster:SetWalkThru(.F.)

aadd(aOrdCmp,{"Competencia" ,"CMPLOT"})
aadd(aOrdCmp,{"Id campo guia","CODCMP"})
aadd(aOrdCmp,{"Codigo Erro" ,"CODCRI"})
aadd(aOrdCmp,{"Descrição do Erro"   ,"DESCRI"})
aadd(aOrdCmp,{"Quantidade"  ,"QTD"   })

oBrwMaster:setFields(aOrdCmp)

oBrwMaster:Activate()       
TMPPRE->(DbCloseArea())            
return


//-------------------------------------------------------------------
/*/{Protheus.doc} P270PREDET
Detalhe das criticas
@author  Lucas Nonato
@since   26/02/2019
@version P12
/*/
function P270PREDET(cAlias)
local cSql      	:= ""
local aRotinaAnt	:= {}
private oBrwSel		:= nil
private cFilMaster as char

cSql += " SELECT R_E_C_N_O_ Recno FROM " + RetSqlName(cAlias) + " " +  cAlias  
cSql += " INNER JOIN (
cSql += " 	SELECT B4N_FILIAL, B4N_CMPLOT, B4N_NUMLOT, B4N_NMGOPE, B4N_CODOPE, B4N_CODLDP, B4N_CODPEG, B4N_NUMERO, B4N_CODRDA, B4P_CODPAD, B4P_CODPRO, "
cSql += " 	B4P_CODGRU, B4P_CDCMGU, B4P_CDCMER, B4N_OREVAT, B4N_TPEVAT, B4N_TIPATE, CASE WHEN B4N_TPEVAT = '3' THEN 'BE4' ELSE 'BD5' END as ALIAS FROM " + RetSqlName("B4N") + " B4N "
cSql += " 	INNER JOIN " + RetSqlName("B4P") + " B4P " 
cSql += " 	  ON B4P_FILIAL = B4N_FILIAL  "
cSql += " 	  AND B4P_CMPLOT = B4N_CMPLOT  "
cSql += " 	  AND B4P_NUMLOT = B4N_NUMLOT  "
cSql += " 	  AND B4P_NMGOPE = B4N_NMGOPE  "
cSql += " 	  AND B4P.D_E_L_E_T_ = ' '  "
cSql += " 	WHERE B4N_CMPLOT = '" + TMPPRE->CMPLOT + "' "
cSql += " 	  AND B4N_FILIAL = '" + xFilial("B4N") + "' "
cSql += " 	  AND B4P_CDCMER = '" + TMPPRE->CODCRI + "' "
cSql += " 	  AND B4N_LOTREP = ' '  "
cSql += " 	  AND B4N.D_E_L_E_T_ = ' ' ) TMP1 "
cSql += " ON TMP1.B4N_FILIAL = '" + xFilial("B4N") + "' "
cSql += " AND TMP1.B4N_CODOPE = " + cAlias + "_CODOPE"
cSql += " AND TMP1.B4N_CODLDP = " + cAlias + "_CODLDP"
cSql += " AND TMP1.B4N_CODPEG = " + cAlias + "_CODPEG"
cSql += " AND TMP1.B4N_NUMERO = " + cAlias + "_NUMERO"
cSql += " AND "+cAlias+".D_E_L_E_T_ = ' ' "
cSql := changequery(cSql)

//setKey(VK_F2 ,{|| PLSM270PFI(TMPPRE->ALIAS) })

cFilMaster := "@R_E_C_N_O_ in (" + cSql + ") "

oBrwSel := FWmBrowse():New()
oBrwSel:SetAlias( cAlias )
oBrwSel:SetDescription( "Guias" ) 
oBrwSel:SetFilterDefault(cFilMaster)
oBrwSel:AddLegend(cAlias +"_TIPGUI == '01'", "RED",		"Guia de Consulta" )
oBrwSel:AddLegend(cAlias +"_TIPGUI == '02'", "BLUE",	"Guia de SP_SADT/Odonto" )
oBrwSel:AddLegend(cAlias +"_TIPGUI == '04'", "GRAY",	"Guia de Reembolso" )
oBrwSel:AddLegend(cAlias +"_TIPGUI == '05'", "YELLOW",	"Guia de Resumo de Internação" )
oBrwSel:AddLegend(cAlias +"_TIPGUI == '06'", "GREEN",	"Guia de Honorarios" )
						
oBrwSel:SetUseFilter(.t.)
oBrwSel:SetUseCaseFilter(.t.)
oBrwSel:DisableDetails()
oBrwSel:SetWalkThru(.F.)

aRotinaAnt := aclone(aRotina) 
aRotina := {{ 'Alterar' ,'ViewDef.PLSM270PRE', 0,  MODEL_OPERATION_UPDATE, 0 , Nil},;
			{ 'Reprocessar Lote' ,'P270PREREP', 0,  MODEL_OPERATION_UPDATE, 0 , Nil}}

oBrwSel:Activate()

aRotina := aclone(aRotinaAnt)

return


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author  Lucas Nonato
@since   14/02/2019
@version P12
/*/
static function ViewDef()
local cAlias    := TMPPRE->ALIAS
local oStruBD5  := FWFormStruct( 2, cAlias , { |cCampo| PLSM270ZFI(cCampo, cAlias) }) 
local oStruBD6  := FWFormStruct( 2, 'BD6' , { |cCampo| PLSM270ZFI(cCampo, 'BD6') })
local oModel    := FWLoadModel( 'PLSM270PRE' )
local oView      

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VIEW_BD5', oStruBD5, 	'BD5MASTER' )
oView:AddGrid( 'VIEW_BD6', 	oStruBD6, 	'BD6DETAIL' )

oView:EnableTitleView('VIEW_BD5',"Guias")  
oView:EnableTitleView('VIEW_BD6',"Eventos")  

oView:CreateHorizontalBox( 'Guias', 	50 )
oView:CreateHorizontalBox( 'Eventos', 	50 )  

oView:SetOwnerView( 'VIEW_BD5', 'Guias')   
oView:SetOwnerView( 'VIEW_BD6', 'Eventos')

oStruBD6:SetProperty( 'BD6_CODPAD', MVC_VIEW_CANCHANGE, .f.)
oStruBD6:SetProperty( 'BD6_CODPRO', MVC_VIEW_CANCHANGE, .f.)
oStruBD6:SetProperty( 'BD6_DESPRO', MVC_VIEW_CANCHANGE, .f.)
oStruBD6:SetProperty( 'BD6_QTDPRO', MVC_VIEW_CANCHANGE, .f.)
oStruBD6:SetProperty( 'BD6_VLRPAG', MVC_VIEW_CANCHANGE, .f.)
oStruBD6:SetProperty( 'BD6_VLRGLO', MVC_VIEW_CANCHANGE, .f.)
oStruBD6:SetProperty( 'BD6_VLRAPR', MVC_VIEW_CANCHANGE, .f.)
oStruBD6:SetProperty( 'BD6_VLTXPG', MVC_VIEW_CANCHANGE, .f.)
oStruBD6:SetProperty( 'BD6_CODESP', MVC_VIEW_CANCHANGE, .t.) 
oStruBD6:SetNoFolder()	

oStruBD5:SetProperty( cAlias+'_CODOPE', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_CODLDP', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_CODPEG', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_NUMERO', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_TIPGUI', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_CODRDA', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_NOMRDA', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_CODESP', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_DESESP', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_CODOPE', MVC_VIEW_CANCHANGE, .f.) 
oStruBD5:SetProperty( cAlias+'_INDACI', MVC_VIEW_CANCHANGE, .t.) 
oStruBD5:SetProperty( cAlias+'_TIPADM', MVC_VIEW_CANCHANGE, .t.) 
oStruBD5:SetProperty( cAlias+'_GUIINT', MVC_VIEW_CANCHANGE, .t.)

if cAlias == 'BD5'
	oStruBD5:SetProperty( 'BD5_LOCATE', MVC_VIEW_CANCHANGE, .f.) 
	oStruBD5:SetProperty( 'BD5_DESLOC', MVC_VIEW_CANCHANGE, .f.) 
    oStruBD5:SetProperty( 'BD5_TIPATE', MVC_VIEW_CANCHANGE, .t.) 
    oStruBD5:SetProperty( 'BD5_GUIPRI', MVC_VIEW_CANCHANGE, .t.)     
elseif cAlias == 'BE4'
    oStruBD5:SetProperty( 'BE4_GRPINT', MVC_VIEW_CANCHANGE, .t.)
    oStruBD5:SetProperty( 'BE4_REGINT', MVC_VIEW_CANCHANGE, .t.)
    oStruBD5:SetProperty( 'BE4_ATERNA', MVC_VIEW_CANCHANGE, .t.)
    oStruBD5:SetProperty( 'BE4_NRDCNV', MVC_VIEW_CANCHANGE, .t.)
    oStruBD5:SetProperty( 'BE4_NRDCOB', MVC_VIEW_CANCHANGE, .t.)
    oStruBD5:SetProperty( 'BE4_TIPFAT', MVC_VIEW_CANCHANGE, .t.)
endif

oStruBD5:SetNoFolder()	

return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define a model

@author  Lucas Nonato
@since   14/02/2019
@version P12
/*/
static function ModelDef()
local cAlias    := iif( select("TMPPRE") > 0, TMPPRE->ALIAS, "BD5" )
local oStruBD5 	:= FWFormStruct( 1, cAlias   , { |cCampo| PLSM270ZFI(cCampo, cAlias) }) 
local oStruBD6 	:= FWFormStruct( 1, 'BD6'    , { |cCampo| PLSM270ZFI(cCampo, 'BD6') })
local oModel

oModel := MPFormModel():New( 'P270PREMODEL',/*bPreValid*/,/*{|| PLUA520Val(oModel)}*/,{|| P270PRECMT(oModel)}, /*bCancel*/ )

// Monta a estrutura
oModel:AddFields(   'BD5MASTER', 	            , oStruBD5)           
oModel:AddGrid(     'BD6DETAIL', 	'BD5MASTER'	, oStruBD6) 

// Descrições
oModel:SetDescription( 'Digitação de Contas - Alteração' )
oModel:GetModel( 'BD5MASTER' ):SetDescription( 'Guias' )  
oModel:GetModel( 'BD6DETAIL' ):SetDescription( 'Eventos' ) 

oStruBD6:setProperty( '*', MODEL_FIELD_VALID, { || .T. } )
oStruBD6:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F.)
oStruBD5:setProperty( '*', MODEL_FIELD_VALID, { || .T. } )
oStruBD5:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F.)

oModel:GetModel( 'BD6DETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'BD6DETAIL' ):SetNoInsertLine( .T. )
								
oModel:SetRelation( 'BD6DETAIL', { 	{ 	'BD6_FILIAL', 'xFilial( "BD6" )'},;
									{ 	'BD6_CODOPE', cAlias+'_CODOPE' 	},;
									{ 	'BD6_CODLDP', cAlias+'_CODLDP' 	},;
									{ 	'BD6_CODPEG', cAlias+'_CODPEG' 	},;
									{ 	'BD6_NUMERO', cAlias+'_NUMERO'  }},;  
										'BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO')

oModel:SetPrimaryKey({cAlias+'_FILIAL',cAlias+'_CODOPE',cAlias+'_CODLDP',cAlias+'_NUMERO'})

return oModel


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270PFI
Filtro de tela

@author    Lucas Nonato
@version   V12
@since     14/02/2019
/*/
//------------------------------------------------------------------------------------------
function PLSM270PFI(cAlias)

oBrwSel:SetFilterDefault(cFilter)

cFilter := BuildExpr(cAlias,,,.t.)

oBrwSel:SetFilterDefault(cFilMaster + iif(!empty(cFilter), "AND " + cFilter, ""))
oBrwSel:Refresh()

return cFilter


//-------------------------------------------------------------------
/*/{Protheus.doc} P270PRECMT
Commit

@author  Lucas Nonato
@since   14/02/2019
@version P12
/*/
function P270PRECMT(oModel)
local oMaster	:= oModel:getModel("BD5MASTER")
local cFilter	:= ""
local cSql 		:= ""
local cCab		:= ""
local cUpd		:= ""
local cCabFull	:= "SELECT TMP1.* FROM " + RetSqlName(TMPPRE->ALIAS) + " " +  TMPPRE->ALIAS  
local lRet		:= .f.

cFilter := getFilter()
cCab += " SELECT " + TMPPRE->ALIAS + ".R_E_C_N_O_ FROM " + RetSqlName(TMPPRE->ALIAS) + " " +  TMPPRE->ALIAS  
cSql += " INNER JOIN ( "
cSql += " SELECT B4N_CODOPE CODOPE, B4N_CODLDP CODLDP, B4N_CODPEG CODPEG, B4N_CODRDA CODRDA, B4N_NUMERO NUMERO, '0' TIPO, "
cSql += " CASE B4N_TPEVAT WHEN '3' THEN '05' ELSE '02' END AS TIPGUI, B4N_DTPAGT DTPAGT, B4N_DTPRGU DTDIGI, B4N_CMPLOT CMPLOT, B4N_NUMLOT NUMLOT FROM " + RetSqlName("B4N") + " B4N "
cSql += " 	INNER JOIN " + RetSqlName("B4P") + " B4P " 
cSql += " 	  ON B4P_FILIAL = B4N_FILIAL  "
cSql += " 	  AND B4P_CMPLOT = B4N_CMPLOT  "
cSql += " 	  AND B4P_NUMLOT = B4N_NUMLOT  "
cSql += " 	  AND B4P_NMGOPE = B4N_NMGOPE  "
cSql += " 	  AND B4P.D_E_L_E_T_ = ' '  "
cSql += " 	WHERE B4N_CMPLOT = '" + TMPPRE->CMPLOT + "' "
cSql += " 	  AND B4N_FILIAL = '" + xFilial("B4N") + "' "
cSql += " 	  AND B4P_CDCMER = '" + TMPPRE->CODCRI + "' "
cSql += " 	  AND B4N_LOTREP = ' '  "
cSql += " 	  AND B4N.D_E_L_E_T_ = ' ' ) TMP1 "
cSql += " ON  " + TMPPRE->ALIAS + "_FILIAL = '" + xFilial("B4N") + "' "
cSql += " AND TMP1.CODOPE = " + TMPPRE->ALIAS + "_CODOPE"
cSql += " AND TMP1.CODLDP = " + TMPPRE->ALIAS + "_CODLDP"
cSql += " AND TMP1.CODPEG = " + TMPPRE->ALIAS + "_CODPEG"
cSql += " AND TMP1.NUMERO = " + TMPPRE->ALIAS + "_NUMERO"
cSql += " AND "+TMPPRE->ALIAS+".D_E_L_E_T_ = ' ' "
cSql +=  cFilter
cCabFull += cSql
cSql := ChangeQuery(cCab + cSql)
if TMPPRE->CODCRI == "5031"
	if oMaster:IsFieldUpdated(TMPPRE->ALIAS+"_TIPADM")
		cSql += " WHERE " + TMPPRE->ALIAS + "_TIPADM = '" + &(TMPPRE->ALIAS+"->"+TMPPRE->ALIAS+"_TIPADM") + "'"	
		lRet := plReplace(cCab + cSql)
	endif
endif

if lRet
	cUpd := " UPDATE " + RetSqlName(TMPPRE->ALIAS) + " SET " + TMPPRE->ALIAS + "_TIPADM = '" + oMaster:getvalue(TMPPRE->ALIAS + "_TIPADM") + "' WHERE R_E_C_N_O_ IN (" + cSql + ")"
	
	oProcess := msNewProcess():New( { | lEnd | reprocessa( 3, cCabFull, cUpd ) } , "Reprocessando" , "Aguarde..." , .F. )
	oProcess:Activate()
else
	reprocessa()
endif
fwformcommit(oModel)
return .t.


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} reprocessa
rocerocessa uma guia criticada pelo sistema

@author    Lucas Nonato
@version   1.xx
@since     25/04/2017

/*/
//------------------------------------------------------------------------------------------
static function reprocessa(nTpProc, cQuery, cUpd)
local aLote	    := {}
local aCampos	:= {}
local aLoteAnt	:= {}
local aAlias 	:= {"B4U","B4P","B4O","B4N"}
local cAlias	:= getNextAlias()
local cfim		
local cSql 		:= ""
local cSqlName 	:= ""
local cWhere	:= ""
local cFilter	:= ""
local nX		:= 1
local nLoop		:= 0
local nQtdAnt	:= 0
local nQtdFull	:= 0

private oTmpTable 	:= nil

default nTpProc		:= 1
default cQuery		:= ""
default cUpd		:= ""

P270CTMP(cAlias,@oTmpTable,.t.)

if nTpProc == 1
	oProcess := P270fProc():New()
	cSql += " SELECT B4N_CODOPE CODOPE, B4N_CODLDP CODLDP, B4N_CODPEG CODPEG, B4N_CODRDA CODRDA, B4N_NUMERO NUMERO, '0' TIPO, "
	cSql += " CASE B4N_TPEVAT WHEN '3' THEN '05' ELSE '02' END AS TIPGUI, B4N_DTPAGT DTPAGT, B4N_DTPRGU DTDIGI, B4N_CMPLOT CMPLOT, B4N_NUMLOT NUMLOT " 
	cSql += " FROM " + RetSqlName('B4N') + " B4N "
	cSql += " WHERE  B4N_FILIAL = '" + xFilial('B4N') + "' " 
	cSql += " AND B4N_SUSEP = '" + TMPPRE->SUSEP + "'  "
	cSql += " AND B4N_CMPLOT = '" + TMPPRE->CMPLOT + "'  " 
	cSql += " AND B4N_NMGOPE =  '" + (TMPPRE->ALIAS )->&(TMPPRE->ALIAS +'_CODLDP') + (TMPPRE->ALIAS )->&(TMPPRE->ALIAS +'_CODPEG') + (TMPPRE->ALIAS )->&(TMPPRE->ALIAS +'_NUMERO') + "' "
	cSql += " AND B4N_LOTREP = ' ' "
	cSql += " AND B4N.D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B4N_NUMLOT DESC "
elseif nTpProc == 2
	cFilter := getFilter()
	cSql += " SELECT TMP1.* FROM " + RetSqlName(TMPPRE->ALIAS) + " " +  TMPPRE->ALIAS  
	cSql += " INNER JOIN (
	cSql += " SELECT B4N_CODOPE CODOPE, B4N_CODLDP CODLDP, B4N_CODPEG CODPEG, B4N_CODRDA CODRDA, B4N_NUMERO NUMERO, '0' TIPO, "
	cSql += " CASE B4N_TPEVAT WHEN '3' THEN '05' ELSE '02' END AS TIPGUI, B4N_DTPAGT DTPAGT, B4N_DTPRGU DTDIGI, B4N_CMPLOT CMPLOT, B4N_NUMLOT NUMLOT FROM " + RetSqlName("B4N") + " B4N "
	cSql += " 	INNER JOIN " + RetSqlName("B4P") + " B4P " 
	cSql += " 	  ON B4P_FILIAL = B4N_FILIAL  "
	cSql += " 	  AND B4P_CMPLOT = B4N_CMPLOT  "
	cSql += " 	  AND B4P_NUMLOT = B4N_NUMLOT  "
	cSql += " 	  AND B4P_NMGOPE = B4N_NMGOPE  "
	cSql += " 	  AND B4P.D_E_L_E_T_ = ' '  "
	cSql += " 	WHERE B4N_CMPLOT = '" + TMPPRE->CMPLOT + "' "
	cSql += " 	  AND B4N_FILIAL = '" + xFilial("B4N") + "' "
	cSql += " 	  AND B4P_CDCMER = '" + TMPPRE->CODCRI + "' "
	cSql += " 	  AND B4N_LOTREP = ' '  "
	cSql += " 	  AND B4N.D_E_L_E_T_ = ' ' ) TMP1 "
	cSql += " ON  " + TMPPRE->ALIAS + "_FILIAL = '" + xFilial("B4N") + "' "
	cSql += " AND TMP1.CODOPE = " + TMPPRE->ALIAS + "_CODOPE"
	cSql += " AND TMP1.CODLDP = " + TMPPRE->ALIAS + "_CODLDP"
	cSql += " AND TMP1.CODPEG = " + TMPPRE->ALIAS + "_CODPEG"
	cSql += " AND TMP1.NUMERO = " + TMPPRE->ALIAS + "_NUMERO"
	cSql += " AND "+TMPPRE->ALIAS+".D_E_L_E_T_ = ' ' "
	cSql += cFilter 
else
	cSql := cQuery	
endif

cSql := ChangeQuery(cSql)

if Select("TrbRpG") > 0
	TrbR->(dbCloseArea())
endif

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbRpG",.F.,.T.)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTPAGT, DTDIGI, CMPLOT, NUMLOT) " + cSql

PLSCOMMIT(cSql)
P270hubguias(.t.)

if nTpProc == 3
	PLSCOMMIT(cUpd)
endif
//Vou ajustar o array de perguntas para o padrao da rotina
aAdd(/*01*/__aRet,plsintpad())	//Operadora
aAdd(/*02*/__aRet,SubStr(TrbRpG->CMPLOT,1,4))	//Ano Competência
aAdd(/*03*/__aRet,SubStr(TrbRpG->CMPLOT,5,2))	//Mês Competência
aAdd(/*04*/__aRet,"")//Lote De
aAdd(/*05*/__aRet,"")//Lote Ate		
aAdd(/*06*/__aRet,"")//Local de Digitação
aAdd(/*07*/__aRet,"")//Protocolo De
aAdd(/*08*/__aRet,"")//Protocolo Ate
aAdd(/*09*/__aRet,"2")//Considera Guias Estornadas -> 2-Nao
aAdd(/*10*/__aRet,"2")//Gerar como exclusao -> 2-Nao
aAdd(/*11*/__aRet,"2")//Somente Us.Inf.ANS -> 2-Nao
aAdd(/*12*/__aRet,"0")//Qtd. Dias Retroativo
aAdd(/*13*/__aRet,"1")//Cons Data de Process
aAdd(/*14*/__aRet,"1")//Tipo de envio
aAdd(/*15*/__aRet,"1")//Situacao da guia

B4M->(DbSetOrder(1))//B4M_FILIAL+B4M_SUSEP+B4M_CMPLOT+B4M_NUMLOT+B4M_NMAREN		
while !TrbRpG->(eof())	
	B4M->(MsSeek(xFilial("B4M") + TMPPRE->SUSEP + TrbRpG->CMPLOT + TrbRpG->NUMLOT))    
	aLote := {}
	aAdd(aLote, B4M->B4M_NUMLOT) 
	aAdd(aLote, B4M->B4M_CMPLOT)
	aAdd(aLote, B4M->B4M_SUSEP)

	oProcess:IncRegua1( "Reprocessando... Lote: [" + aLote[2] + "] " + aLote[1]  )
	cNumLote := TrbRpG->NUMLOT
	while !TrbRpG->(eof()) .and. cNumLote == B4M->B4M_NUMLOT
		aCampos	:= {}
		aAdd( aCampos,{ "B4M_QTDCRI"	,0 					} )	// quantidade de criticas
		aAdd( aCampos,{ "B4M_QTRGPR"	,B4M->B4M_QTRGPR - 1} )	// quantidade de registros
		gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )
		delClassInf()
		//Exclui guia
		PLSM270DEL(aAlias, B4M->B4M_SUSEP+B4M->B4M_CMPLOT+B4M->B4M_NUMLOT+TrbRpG->( CODLDP + CODPEG + NUMERO), .T.,TrbRpG->(CODLDP + CODPEG + NUMERO) ) 	
		TrbRpG->(dbSkip())
		if !empty(TrbRpG->NUMLOT)
			cNumLote := TrbRpG->NUMLOT
		endif
	enddo

	cSqlName 	:= "TEMPMONPRE"
	TcSqlEXEC("DROP TABLE TEMPMONPRE")
	if substr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" 
		TcSqlEXEC("DROP TABLE TEMPMONPRE")
	   	nRet := TcSqlEXEC(" CREATE TABLE TEMPMONPRE AS SELECT * FROM " + oTmpTable:getrealName() + " WHERE NUMLOT = '" + cNumLote + "'")
		  if nRet >= 0
			TcSqlEXEC("COMMIT") 
		endif
	else
		TcSqlEXEC("SELECT * INTO TEMPMONPRE FROM " + oTmpTable:getrealName() + " WHERE NUMLOT = '" + cNumLote + "'")
	endif
	
	aLoteAnt := aclone(aLote)
	if THREADSLOCK == 1
		PLPROCMONIT( "01", cEmpAnt, cFilAnt, __aRet, .f., cSqlName,aLote,THREADSLOCK,3) 
	else
		if substr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" 
			TcSqlEXEC("DROP TABLE TEMPMONITP")
	   		nRet := TcSqlEXEC(" CREATE TABLE TEMPMONITP AS SELECT * FROM " + cSqlName )
			if nRet >= 0
				TcSqlEXEC("COMMIT") 
			endif
			cSqlName := 'TEMPMONITP'		
		endif
		for nX := 1 to THREADSLOCK
		 	startJob("PLPROCMONIT",GetEnvServer(),.F.,strzero(nX,2), cEmpAnt, cFilAnt, __aRet, .f.,cSqlName,aLote,THREADSLOCK,3)
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

	If !P270excAlt(aLote)
		cWhere := " AND B4N_NMGOPE IN (" + changequery("SELECT CODLDP||CODPEG||NUMERO FROM TEMPMONPRE") + ") "
		PLVLDMON( aLote, cWhere )
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
enddo
TrbRpG->(dbCloseArea())

cfim := time()

return


//-------------------------------------------------------------------
/*/{Protheus.doc} P270PREREP

@author  Lucas Nonato
@since   26/02/2019
@version P12
/*/
function P270PREREP
local lEnd 		:= .F.
local cTitulo	:= "Reprocessa arquivo de envio - TISS"
local aOpcoes	:= { "Processar","Cancelar" }
local cTexto	:= 	CRLF + CRLF + "Esta é a opção que irá reprocessar todas as guias com a critica selecionada." + ;
 					CRLF + CRLF + "Utilize o filtro para selecionar apenas as guias que deseja realmente reprocessar." + ;
				 	CRLF + CRLF + "Após o reprocessamento será feita novamente a validação, caso a guia permaneça na tela ele continuou com a mesma critica."
local nTaman	:= 3
local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )


Private oProcess

if nOpc == 1
	oProcess := msNewProcess():New( { | lEnd | reprocessa( 2 ) } , "Reprocessando" , "Aguarde..." , .F. )
	oProcess:Activate()
endif

return

static function getFilter
local nY 		:= 2
local cFilter 	:= ""

for nY := 2 to len(oBrwSel:oFWFilter:oUIFilter:aCheckFil)
	if oBrwSel:oFWFilter:oUIFilter:aCheckFil[nY]
		if nY <= 6 // Filtro padrão não tem a opção em SQL preenchida somente os filtros criados.
			cFilter += " AND " + strtran(oBrwSel:oFWFilter:aFilter[nY][2],"==","=")
		else
			cFilter += " AND " + strtran(strtran(oBrwSel:oFWFilter:aFilter[nY][3],'"',"'"),"==","=")
		endif
	endif
next

return cFilter


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} plReplace
@version   1.xx
@since     25/04/2017
/*/
//------------------------------------------------------------------------------------------
static function plReplace(cSql)
local cAlias := getNextAlias()
local lRet	 := .f.
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

if !(cAlias)->(eof())
	if MsgYesNo('Foram encontradas guias com a mesma situação, deseja aplicar a mesma alteração para elas?','Atenção') 
		lRet := .t.
	endif
endif

(cAlias)->(dbclosearea())

return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P270fProc
@version   1.xx
@since     25/04/2017
/*/
//------------------------------------------------------------------------------------------
class P270fProc
method New() CONSTRUCTOR
method IncRegua1()
method IncRegua2()
method SetRegua1()
method SetRegua2()
endclass
method New() class P270fProc
return
method IncRegua1() class P270fProc
return
method IncRegua2() class P270fProc
return
method SetRegua1() class P270fProc
return
method SetRegua2() class P270fProc
return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
MenuDef fonte
@version   1.xx
@since     25/04/2017
/*/
//------------------------------------------------------------------------------------------
static function Menudef()
local aRotina := {}

aRotina := {{ "Selecionar"    ,'msgRun( "Abrindo janela de detalhes...","Carregando, por favor aguarde",{|| P270PREDET(TMPPRE->ALIAS) } )'  , 0, MODEL_OPERATION_VIEW , 0, Nil},;
			{ 'Alterar' ,'ViewDef.PLSM270PRE', 0,  MODEL_OPERATION_UPDATE, 0 , Nil},;
			{ 'Reprocessar Lote' ,'P270PREREP', 0,  MODEL_OPERATION_UPDATE, 0 , Nil}}

return aRotina
