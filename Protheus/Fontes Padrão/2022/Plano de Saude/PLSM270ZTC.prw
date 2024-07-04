#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM270ZTC
Tela MVC com FWMarkBrowse no Monitoramento TISS 
@author Lucas Nonato
@since  14/09/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSM270ZTC() 
private oBrwPrinc 

setKey(VK_F2 ,{|| PLSZTCFIL() })

oBrwPrinc:= FWMarkBrowse():New()
oBrwPrinc:SetAlias("B4V")
oBrwPrinc:SetDescription("Monitoramento TISS - Conferencia" )
oBrwPrinc:SetMenuDef("PLSM270ZTC")
oBrwPrinc:AddLegend("B4V_STATUS == '1'", "BLUE",	"Importado" )
oBrwPrinc:AddLegend("B4V_STATUS == '2'", "YELLOW",	"Alterado" )
oBrwPrinc:AddLegend("B4V_STATUS == '3'", "GREEN",	"Processado" )
oBrwPrinc:AddLegend("B4V_STATUS == '4'", "RED",	    "Excluido" )
oBrwPrinc:SetFieldMark( 'B4V_OK' )	
oBrwPrinc:SetAllMark( { || AZTCInverte() } )
oBrwPrinc:SetWalkThru(.F.)
oBrwPrinc:SetAmbiente(.F.)
oBrwPrinc:ForceQuitButton()
oBrwPrinc:Activate()

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    Lucas Nonato
@version   1.xx
@since     14/02/2019
/*/
//------------------------------------------------------------------------------------------
static function MenuDef()
local aRotina := {}

ADD OPTION aRotina Title 'Importar Arquivo'		Action 'PLSIMPZTC'	        OPERATION MODEL_OPERATION_INSERT ACCESS 0
Add Option aRotina Title 'Alterar'              Action 'ViewDef.PLSM270ZTC' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
ADD OPTION aRotina Title "Enviar Alteração" 	Action 'PLS270ENVA'         OPERATION MODEL_OPERATION_INSERT ACCESS 0 
ADD OPTION aRotina Title "Enviar Exclusão" 		Action 'PLS270ENVE'         OPERATION MODEL_OPERATION_INSERT ACCESS 0 
ADD OPTION aRotina Title "<F2> - Filtrar" 		Action 'PLSZTCFIL'          OPERATION MODEL_OPERATION_INSERT ACCESS 0 
	
return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSIMPZTC
Perguntas de Importação

@author  Lucas Nonato
@since   14/02/2019
@version P12
/*/
function PLSIMPZTC
local aPergs	as array
local __aRet	as array
local nX        as numeric

local cTitulo	:= "Importação de Conferencia - TISS"
local cTexto	:= CRLF + CRLF + "Esta é a opção que irá importar as guias incorporadas na base da ANS." + CRLF + "A cada nova importação os registros já existentes serão excluidos." 
	
local aOpcoes	:= { "Processar","Cancelar" }
local nTaman	:= 3
local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )

aPergs	:= {}
__aRet	:= {}

//aadd(/*01*/ aPergs,{ 6,"Caminho CSV",space(100),"@!","","",90,.t.,,,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY  )})
aadd(/*01*/ aPergs,{6,"Caminho CSV",Space(100),"@!","","",90,.t.,"Arquivos .CSV |*.CSV"})
aadd(/*02*/ aPergs,{ 1,"Competencia",space(6),"@R 9999/99",'.t.',,/*'.t.'*/,7,.t. } )

if nOpc == 1
    if( paramBox( aPergs,"Parâmetros - Conferencia Monitoramento TISS",__aRet,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,/*cLoad*/'PLSCONFT',/*lCanSave*/.t.,/*lUserSave*/.t. ) )
    	cIni := time()
    	Processa( { || impZTC(__aRet[1],__aRet[2]) },'Aguarde','Importando arquivo',.F.)
    	cFim := time()
    	Aviso( "Resumo","Registros importados " + CRLF + 'Inicio: ' + cvaltochar( cIni ) + "  -  " + 'Fim: ' + cvaltochar( cFim ) ,{ "Ok" }, 2 )
    endif
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} impZTC
Importação e gravação do arquivo.

@author  Lucas Nonato
@since   14/02/2019
@version P12
/*/
static function impZTC(cArq, cComp)
local oFileRead as object
local cLine     as char
local nX        as numeric 
local aLines    as array
local cCodOpe   as char
cLine   := ""
nX      := 1
aLines  := {}
cCodOpe := plsintpad()

PLSB4VDEL()

oFileRead := FWFileReader():New( cArq )
if oFileRead:Open()
    cLine := oFileRead:GetLine()
    ProcRegua(-1)
    while !oFileRead:eof()        
        cLine   := oFileRead:GetLine()
        aLines  := StrTokArr( cLine, ";" )    
        IncProc("[" + cvaltochar(oFileRead:getBytesRead()) + "] de [" + cvaltochar(oFileRead:getFileSize()) + "]")    
        B4V->(dbAppend())
        B4V->(FieldPut(FieldPos("B4V_FILIAL") ,xfilial("B4V")))
        B4V->(FieldPut(FieldPos("B4V_SUSEP ") ,aLines[1]))
        B4V->(FieldPut(FieldPos("B4V_CNES"  ) ,aLines[2]))
        B4V->(FieldPut(FieldPos("B4V_CPFCNP") ,aLines[4]))
        B4V->(FieldPut(FieldPos("B4V_CDMNRS") ,aLines[5]))
        B4V->(FieldPut(FieldPos("B4V_RGOPIN") ,aLines[6]))
        B4V->(FieldPut(FieldPos("B4V_CODRDA") ,posicione("BAU",4,xfilial("BAU")+aLines[4],"BAU_CODIGO")))
        B4V->(FieldPut(FieldPos("B4V_NUMCNS") ,aLines[8]))
        if !empty(aLines[10]) 
            B4V->(FieldPut(FieldPos("B4V_DATNAS") ,stod(aLines[10])))
        endif
        B4V->(FieldPut(FieldPos("B4V_CDMNRS") ,aLines[11]))
        B4V->(FieldPut(FieldPos("B4V_SCPRPS") ,aLines[12]))
        B4V->(FieldPut(FieldPos("B4V_TPEVAT") ,aLines[13]))
        B4V->(FieldPut(FieldPos("B4V_OREVAT") ,aLines[14]))
        B4V->(FieldPut(FieldPos("B4V_NMGPRE") ,aLines[15]))
        B4V->(FieldPut(FieldPos("B4V_NMGOPE") ,aLines[16]))
        B4V->(FieldPut(FieldPos("B4V_IDEREE") ,aLines[17]))
        B4V->(FieldPut(FieldPos("B4V_SOLINT") ,aLines[18]))
        B4V->(FieldPut(FieldPos("B4V_NMGPRI") ,aLines[19]))
        if !empty(aLines[23])
            B4V->(FieldPut(FieldPos("B4V_DTPRGU") ,stod(aLines[23])))
        endif
        B4V->(FieldPut(FieldPos("B4V_CBOS"  ) ,aLines[24]))
        B4V->(FieldPut(FieldPos("B4V_TIPATE") ,aLines[29]))
        B4V->(FieldPut(FieldPos("B4V_TIPFAT") ,aLines[30]))
        B4V->(FieldPut(FieldPos("B4V_MOTSAI") ,aLines[31]))
        B4V->(FieldPut(FieldPos("B4V_VLTINF") ,val(aLines[32])))
        B4V->(FieldPut(FieldPos("B4V_VLTGLO") ,val(aLines[33])))
        B4V->(FieldPut(FieldPos("B4V_VLTGUI") ,val(aLines[34])))
        B4V->(FieldPut(FieldPos("B4V_VLTFOR") ,val(aLines[35])))
        B4V->(FieldPut(FieldPos("B4V_VLTTBP") ,val(aLines[36])))
        B4V->(FieldPut(FieldPos("B4V_CODOPE") ,cCodOpe))
        B4V->(FieldPut(FieldPos("B4V_CODLDP") ,substr(aLines[16],1,4)))
        B4V->(FieldPut(FieldPos("B4V_CODPEG") ,substr(aLines[16],5,8)))
        B4V->(FieldPut(FieldPos("B4V_NUMERO") ,substr(aLines[16],13,8)))
        B4V->(FieldPut(FieldPos("B4V_CMPLOT") ,cComp))
        B4V->(FieldPut(FieldPos("B4V_STATUS") ,'1'))
        B4V->(FieldPut(FieldPos("B4V_ALIAS" ) ,iif(aLines[13] == '3', 'BE4', 'BD5')))
        B4V->(FieldPut(FieldPos("B4V_VLTCOP") ,val(aLines[37])))
        B4V->(dbcommit())
		B4V->(msunlock())
        nX++
            
    enddo
endif

return nX

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSB4VDEL
Exclusao dos lotes da competencia

@author    Lucas Nonato
@version   12.1.17
@since     14/02/2019
/*/
//------------------------------------------------------------------------------------------
function PLSB4VDEL()

PLSCOMMIT("DELETE FROM " + RetSqlName("B4V") )

return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSZTCFIL
Filtro de tela

@author    Lucas Nonato
@version   V12
@since     14/02/2019
/*/
//------------------------------------------------------------------------------------------
function PLSZTCFIL()

local cFilter 	:= ""

cFilter := "@" + BuildExpr("B4V",oBrwPrinc,cFilter,.t.)

oBrwPrinc:SetFilterDefault(cFilter)
oBrwPrinc:Refresh()

return cFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSZTCFI
Tratamento para ajustar os campos a ser utilizados da tabela.
@author Lucas Nonato
@since 14/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSM270ZFI(cCampo, cAlias)
local lRet	:= .F.

if cAlias == 'BD5' .or. cAlias == 'BE4'
    if  cCampo == cAlias+'_CODOPE' .or. ; 
            cCampo == cAlias+'_CODLDP' .or. ;
            cCampo == cAlias+'_CODPEG' .or. ;
            cCampo == cAlias+'_NUMERO' .or. ;
            cCampo == cAlias+'_TIPGUI' .or. ;
            cCampo == cAlias+'_CODRDA' .or. ;
            cCampo == cAlias+'_NOMRDA' .or. ;            
            cCampo == cAlias+'_CODESP' .or. ;
            cCampo == cAlias+'_DESESP' .or. ;
            cCampo == cAlias+'_CODOPE' .or. ;
            cCampo == cAlias+'_INDACI' .or. ;
            cCampo == cAlias+'_TIPADM' .or. ;
            cCampo == cAlias+'_GUIINT'

        lRet := .T.
    endif
endif

if cAlias == "BD5"
     
    if cCampo == "BD5_TIPATE" .or. ;
            cCampo == "BD5_GUIPRI" .or. ;
            cCampo == 'BD5_LOCATE' .or. ;
            cCampo == 'BD5_DESLOC'  
        lRet := .T.
    endif

elseif cAlias == "BE4"
    if cCampo == "BE4_GRPINT" .or. ;
            cCampo == "BE4_REGINT" .or. ;
            cCampo == "BE4_ATERNA" .or. ;
            cCampo == "BE4_NRDCNV" .or. ;
            cCampo == "BE4_NRDCOB" .or. ;
            cCampo == "BE4_TIPFAT
        lRet := .T.
    endif

elseif cAlias == "BD6"
    if  cCampo == "BD6_CODPAD" .or. ;
            cCampo == "BD6_CODPRO" .or. ;
            cCampo == "BD6_DESPRO" .or. ;
            cCampo == "BD6_QTDPRO" .or. ;
            cCampo == "BD6_VLRPAG" .or. ;
            cCampo == "BD6_VLRGLO" .or. ;
            cCampo == "BD6_VLRAPR" .or. ;
            cCampo == "BD6_VLTXPG" .or. ;
            cCampo == "BD6_VLRPF" .or. ;
            cCampo == "BD6_CODESP"  
    	lRet := .T.
    endif
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author  Lucas Nonato
@since   14/02/2019
@version P12
/*/
static function ViewDef()
local cAlias    := B4V->B4V_ALIAS
local oStruBD5  := FWFormStruct( 2, cAlias , { |cCampo| PLSM270ZFI(cCampo, cAlias) }) 
local oStruBD6  := FWFormStruct( 2, 'BD6' , { |cCampo| PLSM270ZFI(cCampo, 'BD6') })
local oModel    := FWLoadModel( 'PLSM270ZTC' )
local oView      

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VIEW_BD5', oStruBD5, 	'BD5MASTER' )
oView:AddGrid( 'VIEW_BD6', 	oStruBD6, 	'BD6DETAIL' )

oView:EnableTitleView('VIEW_BD5',"Guias")  
oView:EnableTitleView('VIEW_BD6',"Eventos")  

// Divide a tela em para conteúdo e rodapé
//oView:CreateHorizontalBox( 'LOTE', 		15 )
//oView:CreateHorizontalBox( 'PESQUISAR',	10 )
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
//oView:AddOtherObject("OTHER_PANEL", {|oPanel| fPesquisa(oPanel)})

// Associa ao box que ira exibir os outros objetos
//oView:SetOwnerView("OTHER_PANEL",'PESQUISAR')

return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define a model

@author  Lucas Nonato
@since   14/02/2019
@version P12
/*/
static function ModelDef()
local cAlias    := B4V->B4V_ALIAS                              
local oStruBD5 := FWFormStruct( 1, cAlias   , { |cCampo| PLSM270ZFI(cCampo, cAlias) }) 
local oStruBD6 := FWFormStruct( 1, 'BD6'    , { |cCampo| PLSM270ZFI(cCampo, 'BD6') })
local oModel

oModel := MPFormModel():New( 'PLSMZTC0MODEL',/*bPreValid*/,/*{|| PLUA520Val(oModel)}*/,{|| PLSZTCCMT(oModel)}, /*bCancel*/ )

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

// Relacionamentos
oModel:SetRelation( 'BD5MASTER', { 	{ 	cAlias+'_FILIAL', 'xFilial( cAlias )' 	},;
									{ 	cAlias+'_CODOPE', 'B4V->B4V_CODOPE'   		},; 
                                    { 	cAlias+'_CODLDP', 'B4V->B4V_CODLDP'   		},; 
                                    { 	cAlias+'_CODPEG', 'B4V->B4V_CODPEG'   		},; 
                                    { 	cAlias+'_NUMERO', 'B4V->B4V_NUMERO'   		}},; 
										cAlias+'_FILIAL+'+cAlias+'_CODOPE+'+cAlias+'_CODLDP+'+cAlias+'_CODPEG+'+cAlias+'_NUMERO' )
										
oModel:SetRelation( 'BD6DETAIL', { 	{ 	'BD6_FILIAL', 'xFilial( "BD6" )'},;
									{ 	'BD6_CODOPE', cAlias+'_CODOPE' 	},;
									{ 	'BD6_CODLDP', cAlias+'_CODLDP' 	},;
									{ 	'BD6_CODPEG', cAlias+'_CODPEG' 	},;
									{ 	'BD6_NUMERO', cAlias+'_NUMERO'  }},;  
										'BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO')

oModel:SetPrimaryKey({cAlias+'_FILIAL',cAlias+'_CODOPE',cAlias+'_CODLDP',cAlias+'_NUMERO'})


//oStruBD5:SetNoFolder()													
return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSZTCCMT
Commit

@author  Lucas Nonato
@since   14/02/2019
@version P12
/*/
function PLSZTCCMT(oModel)
local cAlias as char
cAlias := B4V->B4V_ALIAS
FWFormCommit(oModel)

(cAlias)->(reclock(cAlias, .f.))
if cAlias == "BD5"
    BD5->BD5_DTANAL := date()
else
    BE4->BE4_DTANAL := date()
endif
(cAlias)->(msunlock())

B4V->(reclock('B4V', .f.))
B4V->B4V_STATUS := "2"
B4V->(msunlock())

return .t.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLS270ENVA
Reprocessa um lote criticado pelo sistema

@author    Lucas Nonato
@version   1.xx
@since     14/02/2019

/*/
//------------------------------------------------------------------------------------------
function PLS270ENVA()
local lEnd := .F.
local cTitulo	:= "Arquivo de Alteração de Guias - TISS"
local cTexto	:= CRLF + CRLF + "Esta é a opção que irá gerar o lote de alteração para envio das guias." + CRLF + "Somente serão enviadas as guias marcadas no Check-Box."
	
local aOpcoes	:= { "Processar","Cancelar" }
local nTaman	:= 3
local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )

private oProcess
private __aRet	:= {}

aadd(/*01*/__aRet,plsintpad())
aadd(/*02*/__aRet,substr(B4V->B4V_CMPLOT,1,4))
aadd(/*03*/__aRet,substr(B4V->B4V_CMPLOT,5,2))
aadd(/*04*/__aRet,"X")
aadd(/*05*/__aRet,"X")
aadd(/*06*/__aRet,"( 'X' )")
aadd(/*07*/__aRet,"X")
aadd(/*08*/__aRet,"X")
aadd(/*09*/__aRet,2)
aadd(/*10*/__aRet,2) // Gerar como exclusão, 1=Sim;2=Não.
aadd(/*11*/__aRet,"1")
aadd(/*12*/__aRet,"  ")
aadd(/*13*/__aRet,1)
aadd(/*14*/__aRet,1)
aadd(/*15*/__aRet,"2")

if nOpc == 1
	oProcess := msNewProcess():New( { | lEnd | PLSM270JOB( .f., 3 ) } , "Processando alteração" , "Aguarde..." , .F. )
	oProcess:Activate()

    PLSCOMMIT("UPDATE " + RetSqlName("B4V") + " SET B4V_STATUS = '3' WHERE B4V_FILIAL = '" + xFilial('B4V') + "' AND B4V_OK = '" + oBrwPrinc:cMark + "'" )
endif

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLS270ENVE
Reprocessa um lote criticado pelo sistema

@author    Lucas Nonato
@version   1.xx
@since     14/02/2019

/*/
//------------------------------------------------------------------------------------------
function PLS270ENVE()
local lEnd := .F.
local cTitulo	:= "Arquivo de Exclusão de Guias - TISS"
local cTexto	:= CRLF + CRLF + "Esta é a opção que irá gerar o lote de exclusão para envio das guias." + CRLF + "Somente serão enviadas as guias marcadas no Check-Box."
	
local aOpcoes	:= { "Processar","Cancelar" }
local nTaman	:= 3
local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )

private oProcess
private __aRet	:= {}

aadd(/*01*/__aRet,plsintpad())
aadd(/*02*/__aRet,substr(B4V->B4V_CMPLOT,1,4))
aadd(/*03*/__aRet,substr(B4V->B4V_CMPLOT,5,2))
aadd(/*04*/__aRet,"X")
aadd(/*05*/__aRet,"X")
aadd(/*06*/__aRet,"( 'X' )")
aadd(/*07*/__aRet,"X")
aadd(/*08*/__aRet,"X")
aadd(/*09*/__aRet,2)
aadd(/*10*/__aRet,1) // Gerar como exclusão, 1=Sim;2=Não.
aadd(/*11*/__aRet,"1")
aadd(/*12*/__aRet,"  ")
aadd(/*13*/__aRet,1)
aadd(/*14*/__aRet,1)
aadd(/*15*/__aRet,"2")

if nOpc == 1
	oProcess := msNewProcess():New( { | lEnd | PLSM270JOB( .f., 2 ) } , "Processando exclusão" , "Aguarde..." , .F. )
	oProcess:Activate()

    PLSCOMMIT("UPDATE " + RetSqlName("B4V") + " SET B4V_STATUS = '4' WHERE B4V_FILIAL = '" + xFilial('B4V') + "' AND B4V_OK = '" + oBrwPrinc:cMark + "'" )
endif

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AZTCInverte
Função para marcar e desmarcar todos os itens da MarkBrowse

@author    Lucas Nonato
@version   V12
@since     14/02/2019
/*/
//------------------------------------------------------------------------------------------
function AZTCInverte()
local cWhere := strtran(oBrwPrinc:GetFilterDefault(),"@","")
local cMark := oBrwPrinc:cMark

cSql := "UPDATE " + RetSqlName("B4V") + " SET B4V_OK = CASE " 
cSql += " WHEN B4V_OK = '" + cMark + "' THEN '  ' " 
cSql += " WHEN B4V_OK <> '" + cMark + "' THEN '" + cMark + "' END"
cSql += " WHERE B4V_FILIAL = '" + xFilial('B4V') + "' " 
cSql += " AND B4V_CMPLOT  =  '" + B4V->B4V_CMPLOT + "' "  + iif(empty(cWhere), "", "AND " + cWhere)

PLSCOMMIT(cSql)

oBrwPrinc:oBrowse:Refresh(.t.)

return .T.