#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TopConn.ch'
#INCLUDE "hat-actions.ch"
#INCLUDE "PLSPRONALT.CH"

#DEFINE CRLF chr( 13 ) + chr( 10 )
static cCamLtxt := ''
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPRONALT
Browse Procedimentos Autorizados.

@author  Thiago Rodrigues
@since   16/04/2018
@version P12
/*/
Function PLSPRONALT(cCodRDA, cCodInt, cCodLoc, cCodEsp, cCodSubEsp,cCamLEtxt)
Local aRotBkp	:= aclone(aRotina)

Local cFiltro := "@(BBN_FILIAL = '"+xFilial("BBN")+"' AND BBN_CODIGO = '"+cCodRDA+"' AND BBN_CODINT = '"+cCodInt+"' AND BBN_CODLOC = '"+cCodLoc+"' AND BBN_CODESP = '"+cCodEsp+"' AND BBN_CODSUB = '"+cCodSubEsp+"')"
private cPVLocBB8 := cCodLoc
private cPVEspBAX := cCodEsp
private cPVEspSBAX := cCodSubEsp
private cRdaBAU := cCodRDA
cCamLtxt := cCamLEtxt

oBroBBN := FWmBrowse():New()

oBroBBN:SetAlias( 'BBN' )
oBroBBN:SetDescription( STR0001 ) //Procedimentos não Autorizados
oBroBBN:SetFilterDefault(cFiltro)
oBroBBN:SetMenuDef("PLSPRONALT")
oBroBBN:setMainProc("PLSPRONALT")
aRotina := MenuDef()
oBroBBN:Activate()

aRotina	:= aclone(aRotBkp)

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define a model

@author  Thiago Rodrigues
@since   16/04/2018
@version P12
/*/
Static Function ModelDef()

Local oStruBBN := FWFormStruct( 1, 'BBN' )
local lAutoma :=  IIf(type('lAutBNNPN')=='U',.F.,lAutBNNPN) // Variavel declarada para fins de automação

Local oModel
Local aGatilho := {}
oModel := MPFormModel():New( 'PLSPRONALT',,,, )

//Gatilho
aGatilho := FwStruTrigger('BBN_CODPAD', 'BBN_CODPSA', '', .f., '', 0, '','!empty(FwFldGet("BBN_CODPAD"))')                                           
oStruBBN:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )

aGatilho := FwStruTrigger('BBN_CODPAD', 'BBN_DESPSA', '', .f., '', 0, '','!empty(FwFldGet("BBN_CODPAD"))')                                           
oStruBBN:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )

aGatilho := FwStruTrigger('BBN_CODPSA', 'BBN_DESPSA', 'BR8->BR8_DESCRI', .f., 'BR8', 1, 'xFilial("BR8") + FwFldGet("BBN_CODPAD") + FwFldGet("BBN_CODPSA")','!empty(FwFldGet("BBN_CODPSA"))') 
oStruBBN:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )

// Monta a estrutura
oModel:AddFields( 'BBNMASTER','',oStruBBN)  

//Inicializador padrão
if lAutoma // Para fim de automação, foi feito dessa forma pois ao chamar da automação as variaveis estao vazias
   oStruBBN:SetProperty( 'BBN_CODINT' , MODEL_FIELD_INIT, { || Plsintpad()} )
   oStruBBN:SetProperty( 'BBN_CODLOC' , MODEL_FIELD_INIT, { || '001'  })
   oStruBBN:SetProperty( 'BBN_CODESP' , MODEL_FIELD_INIT, { || "002"  })
   oStruBBN:SetProperty( 'BBN_CODSUB' , MODEL_FIELD_INIT, { || "" })
   oStruBBN:SetProperty( 'BBN_CODIGO' , MODEL_FIELD_INIT, { || "000004"} )
else 
   oStruBBN:SetProperty( 'BBN_CODINT' , MODEL_FIELD_INIT, { || Plsintpad()} )
   oStruBBN:SetProperty( 'BBN_CODLOC' , MODEL_FIELD_INIT, { || cPVLocBB8  })
   oStruBBN:SetProperty( 'BBN_CODESP' , MODEL_FIELD_INIT, { || cPVEspBAX  })
   oStruBBN:SetProperty( 'BBN_CODSUB' , MODEL_FIELD_INIT, { || cPVEspSBAX })
   oStruBBN:SetProperty( 'BBN_CODIGO' , MODEL_FIELD_INIT, { || cRdaBAU} )
endif

//Validações
oStruBBN:SetProperty( 'BBN_DESPSA' , MODEL_FIELD_TAMANHO, 300 )
oStruBBN:SetProperty( "BBN_CODPSA" , MODEL_FIELD_VALID , { ||CODPSAVLD(oModel) } )


// Descrições
oModel:SetDescription(STR0001) //'Procedimentos não Autorizados' 

																	
oModel:SetPrimaryKey( { "BBN_FILIAL","BBN_CODIGO","BBN_CODINT","BBN_CODLOC","BBN_CODESP","BBN_CODESP","BBN_CODPAD","BBN_CODOPC" } )
																	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author  Thiago Rodrigues
@since   16/04/2018
@version P12
/*/
Static Function MenuDef()

Local aRotina2 := {}

//ADD OPTION aRotina2 Title STR0001   Action 'PesqBrw'          	                              	OPERATION 1 ACCESS 0 //pesquisar
ADD OPTION aRotina2 Title STR0003   Action 'FWExecView("'+cCamLtxt+'","PLSPRONALT",1,,,,10)'		OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina2 Title STR0004   Action 'FWExecView("'+cCamLtxt+'","PLSPRONALT",3,,,,10)'    OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina2 Title STR0005  	Action 'FWExecView("'+cCamLtxt+'","PLSPRONALT",4,,,,10)'		OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina2 Title STR0006 	Action 'ViewDef.PLSPRONALT'		                           OPERATION 5 ACCESS 0 //Excluir

Return aRotina2   

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author  Thiago Rodrigues
@since   16/04/2018
@version P12
/*/
Static Function ViewDef()

Local oStruBBN := FWFormStruct( 2, 'BBN', { |cCampo| PLSCMPBBN(cCampo) })

Local oModel   := FWLoadModel( 'PLSPRONALT' )
Local oView      

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField('VIEW_BBN', 	oStruBBN, 	'BBNMASTER' )

oStruBBN:SetProperty( 'BBN_CODPAD' , MVC_VIEW_ORDEM, "02" )

oView:EnableTitleView('VIEW_BBN',STR0001) //Procedimentos não autorizados

// Divide a tela em para conteúdo e rodapé
oView:CreateHorizontalBox( 'SUPERIOR',	100 )


oView:SetOwnerView( 'VIEW_BBN', "SUPERIOR")

Return oView

/*/
@author Thiago Rodrigues
@since 30/07/20
Verifica se há duplicidade de registros
@version P12
/*/
STATIC FUNCTION CODPSAVLD(oModel)
local oBBN := oModel:getmodel("BBNMASTER")
local lRet  :=.T.
local cSql := ''

if ExistCpo("BR8",oBBN:getValue("BBN_CODPAD")+oBBN:getValue("BBN_CODPSA")) 

   cSql := " SELECT BBN_CODPSA FROM " + RetSqlName("BBN") 
   cSql += " WHERE BBN_FILIAL = '"    + xFilial("BBN") + "' "
   cSql += " AND BBN_CODIGO =  '"     + alltrim(oBBN:getvalue("BBN_CODIGO")) + "' " 
   cSql += " AND BBN_CODINT = '"      + alltrim(oBBN:getvalue("BBN_CODINT")) + "' "
   cSql += " AND BBN_CODLOC = '"      + alltrim(oBBN:getvalue("BBN_CODLOC")) + "' "
   cSql += " AND BBN_CODESP = '"      + alltrim(oBBN:getvalue("BBN_CODESP")) + "' "
   cSql += " AND BBN_CODPAD = '"      + alltrim(oBBN:getvalue("BBN_CODPAD")) + "' "
   cSql += " AND BBN_CODPSA = '"      + alltrim(oBBN:getvalue("BBN_CODPSA")) + "' "
   cSql += " AND D_E_L_E_T_ = ' ' "   

   dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)

   if ( !VerRep->(eof()) )
      lRet := .f.
      Help(nil, nil , STR0001 , nil,STR0008 , 1, 0, nil, nil, nil, nil, nil, {STR0009}) //Atenção / "Já existe este registro no banco de dados, informe outro código.
   Endif 

   if lret 
     PLSGATNIV(oBBN:getValue("BBN_CODPAD"),oBBN:getValue("BBN_CODPSA"),"BBN",.F.,,,"BBNMASTER")
   Endif     
VerRep->(dbclosearea())     
Endif 
    
Return(lRet)

/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBBN
Campos que não devem ser exibidos  no form BNN
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PLSCMPBBN(cCampo)
Local lRet := .F.

if alltrim(cCampo) $ ("BBN_CODPAD|BBN_CODPSA|BBN_DESPSA|BBN_NIVEL|BBN_CDNV01|BBN_CDNV02|BBN_CDNV03|BBN_CDNV40")
	lRet := .T.
endif

return lRet






