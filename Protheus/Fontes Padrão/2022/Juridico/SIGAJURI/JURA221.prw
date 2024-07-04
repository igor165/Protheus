#INCLUDE "JURA221.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"      
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA221
Dados financeiros ao gerar levantamento automático

@author Andreia Lima
@since 16/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA221(cFilDes)
Local oMdlAtual   := FWModelActive()

Private aDadosFin  := {}
Private cTipo      := ''
Private cNatureza  := ''
Private cTpTitulo  := ''
Private cFornec    := ''
Private cLjFornec  := ''     
Private cGrpAprov  := ''
Private cBanco     := ''
Private cAgencia   := ''
Private cConta     := ''
Private cFilialDes := cFilDes

FWExecView(STR0001, "JURA221", 3,, { || .T. },,20 ) //Levantamento Automático	                 
FWModelActive(oMdlAtual)

RETURN aDadosFin
                       
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados 
@author Andreia Lima
@since 16/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStrDados := FWFormStruct(1, 'NT2',{|x| ALLTRIM(x) $ 'NT2_CAJURI, NT2_COD, NT2_MOVFIN, NT2_FILDES, NT2_CTPGAR, NT2_CNATUT, NT2_CTIPOT, NT2_CFORNT, NT2_LFORNT, NT2_NOMEFT, NT2_CGRUAP, NT2_CBANCO, NT2_CAGENC, NT2_CCONTA' } )
Local oModel    

oModel := MPFormModel():New('JURA221' , ,{ | oMdl | JURA221TOk(oMdl) } /*Pos-Validacao*/, { | oMdl | .T. },/*Cancel*/)     
oModel:AddFields('NT2MASTER', NIL, oStrDados)

oModel:SetDescription(STR0002) //Dados Financeiros
oModel:GetModel( 'NT2MASTER' ):SetDescription( STR0002 )

oStrDados:SetProperty('*', MODEL_FIELD_OBRIGAT,.F.) 
oStrDados:SetProperty( 'NT2_CAGENC', MODEL_FIELD_WHEN, {|| !Empty(M-> NT2_CBANCO) .AND. JurLAltera('NT2')} )
oStrDados:SetProperty( 'NT2_CCONTA', MODEL_FIELD_WHEN, {||	!Empty(M-> NT2_CAGENC) .AND.  JurLAltera('NT2')} )


oModel:SetPrimaryKey( {} )   
oModel:SetActivate( { |o| JURA221Mod(o) , .T.} )      

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados 
@author Andreia Lima
@since 16/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStrDados := FWFormStruct(2, 'NT2', { |x| ALLTRIM(x) $ 'NT2_CAJURI, NT2_COD, NT2_MOVFIN, NT2_FILDES, NT2_CTPGAR, NT2_CNATUT, NT2_CTIPOT, NT2_CFORNT, NT2_LFORNT, NT2_NOMEFT, NT2_CGRUAP, NT2_CBANCO, NT2_CAGENC, NT2_CCONTA' } )
Local oModel    := FWLoadModel( 'JURA221' )
Local oView 
Local aAux      := {}

oStrDados:SetNoFolder()

oView := FWFormView():New()
oView:SetModel( oModel )       
oView:AddField( 'VIEW_NT2' , oStrDados, 'NT2MASTER' )
oView:CreateHorizontalBox( "BOX1",  100 )
oView:SetOwnerView( 'VIEW_NT2' , "BOX1" )

If Empty(cFilialDes)
	oView:EnableTitleView('VIEW_NT2', STR0002)
Else	 
	oView:EnableTitleView('VIEW_NT2', STR0003 + cFilialDes) ////Dados Financeiros Filial
EndIf	

oStrDados:RemoveField( "NT2_CAJURI")
oStrDados:RemoveField( "NT2_COD")
oStrDados:RemoveField( "NT2_NOMEFT")
oStrDados:RemoveField( "NT2_MOVFIN")

oStrDados:setProperty("NT2_FILDES",  MVC_VIEW_CANCHANGE, .F.)
oStrDados:setProperty("NT2_LFORNT",  MVC_VIEW_CANCHANGE, .F.)

Return oView   

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA221TOk(oModel)
Valida informações 

@param 	oModel Model a ser verificado
@Return lRet	 .T./.F. As informações são válidas ou não
@author Andreia Lima
@since 16/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA221TOk(oModel)
Local lRet    := .T.
		      
aAdd(aDadosFin,{ FwFldGet("NT2_CTPGAR"),; 
		         FwFldGet("NT2_CNATUT"),;
		         FwFldGet("NT2_CTIPOT"),;
		         FwFldGet("NT2_CFORNT"),;
		         FwFldGet("NT2_LFORNT"),;
		         FwFldGet("NT2_CGRUAP"),;
		         FwFldGet("NT2_CBANCO"),;
		         FwFldGet("NT2_CAGENC"),;
		         FwFldGet("NT2_CCONTA") })
	
Return lRet
  
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA221Mod(oModel)
Função para setar valor no model para que tenha algum dado alterado.

@param 	oModel Model a ser verificado
@author Clóvis Eduardo Teixeira
@since 17/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA221Mod(oModel)

oModel:SetValue( 'NT2MASTER', 'NT2_MOVFIN', '2' )  
oModel:SetValue( 'NT2MASTER', 'NT2_FILDES', cFilialDes )

Return .T.