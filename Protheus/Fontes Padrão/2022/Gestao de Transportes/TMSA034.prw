#INCLUDE "TMSA034.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA034()
CheckList de Operacao
@author Katia
@since 09/04/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function TMSA034()

Local oMBrowse	:= Nil       

Private aRotina := MenuDef()

oMBrowse:= FwMBrowse():New()
oMBrowse:SetAlias( "DTQ" )
oMBrowse:SetDescription( STR0001 )
                                                            
oMBrowse:SetCacheView( .F. )
oMBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Katia
@since 09/04/2015
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel := Nil
Local oStruCDTQ := FwFormStruct( 1, 'DTQ', {|cCampo| AllTrim(cCampo) + "|" $ "DTQ_FILORI|DTQ_VIAGEM|"}) 
Local oStruGDJ9 := FwFormStruct( 1, 'DJ9', {|cCampo| AllTrim(cCampo) + "|" $ "DJ9_IDMARK|DJ9_IDCHK|DJ9_DESCHK|DJ9_DATCHK|DJ9_HORCHK|DJ9_CODUSR|DJ9_NOMUSR|"})
                                              
oModel := MpFormModel():New( 'TMSA034', /*bPreValidacao*/ , /*bPosValid*/,  { |oMdl| TMSA034Grv( oModel ) }  /*bCommit*/, /*bCancel*/ )
  
oModel:SetDescription( STR0001 )

oModel:AddFields( 'MdFieldDTQ', Nil, oStruCDTQ )

oModel:AddGrid( 'MdGridDJ9', 'MdFieldDTQ', oStruGDJ9, ,,  /*bPreVal*/,/*bPosValid*/,  /*BLoad*/   ) 

oModel:SetRelation( 'MdGridDJ9', { {'DJ9_FILIAL','xFilial("DTQ")'},{'DJ9_FILORI','DTQ_FILORI'},{'DJ9_VIAGEM','DTQ_VIAGEM' }},  DJ9->( IndexKey(1) ) )

oModel:SetPrimaryKey({"DJ9_FILIAL", "DJ9_FILORI", "DJ9_VIAGEM", "DJ9_IDCHK" }) 

oModel:GetModel( 'MdGridDJ9' ):SetUniqueLine( { 'DJ9_IDCHK' } )

oModel:GetModel('MdFieldDTQ'):SetOnlyView( .T. )
oModel:GetModel('MdFieldDTQ'):SetOnlyQuery ( .T. ) 

oModel:GetModel( 'MdGridDJ9' ):SetNoInsertLine( .T. )
oModel:GetModel( 'MdGridDJ9' ):SetNoDeleteLine( .T. )

 Return( oModel ) 

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Katia
@since 09/04/2015
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()

Local oView     := Nil
Local oModel    := FwLoadModel( 'TMSA034' )
Local oStruCDTQ := FwFormStruct( 2, 'DTQ', {|cCampo| AllTrim(cCampo) + "|" $ "DTQ_FILORI|DTQ_VIAGEM|"}) 
Local oStruGDJ9 := FwFormStruct( 2, 'DJ9', {|cCampo| AllTrim(cCampo) + "|" $ "DJ9_IDMARK|DJ9_IDCHK|DJ9_DESCHK|DJ9_DATCHK|DJ9_HORCHK|DJ9_CODUSR|DJ9_NOMUSR|"})
                     
oStruGDJ9:SetProperty( 'DJ9_IDMARK', MVC_VIEW_ORDEM, '01')
oStruGDJ9:SetProperty( 'DJ9_IDCHK' , MVC_VIEW_ORDEM, '02')
oStruGDJ9:SetProperty( 'DJ9_DESCHK', MVC_VIEW_ORDEM, '03')

oView := FwFormView():New()
oView:SetModel( oModel )

oView:CreateHorizontalBox( 'FieldDTQ', 020 )
oView:CreateHorizontalBox( 'GridDJ9' , 080 )

oView:AddField( 'VwFieldDTQ', oStruCDTQ, 'MdFieldDTQ' )
oView:AddGrid( 'VwGridDJ9', oStruGDJ9, 'MdGridDJ9' )

oView:SetOwnerView( 'VwFieldDTQ', 'FieldDTQ' )
oView:SetOwnerView( 'VwGridDJ9' , 'GridDJ9' )
                                                             
oView:EnableTitleView( 'VwFieldDTQ' , STR0007 )  
oView:EnableTitleView( 'VwGridDJ9'  , STR0008 )                

Return( oView )
                       

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Katia
@since 09/04/2015
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
                 
Local aRotina := {}

	ADD OPTION aRotina Title STR0002 ACTION 'VIEWDEF.TMSA034' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina Title STR0006 ACTION 'VIEWDEF.TMSA034' OPERATION 4 ACCESS 0 //'Conferencia'
		
Return( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA034Whn()
Valida a digitacao do campo 
@author Katia
@since 09/04/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function TMSA034Whn()
Local lRet:= .T.
Local cCampo := ReadVar()


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA034Grv()
Gravacao da Rotina 
@author Katia
@since 09/04/2015
@version 1.0
@return 
/*/
//-------------------------------------------------------------------
Function TMSA034Grv( oModel )
Local nOperation	:= oModel:GetOperation()              
Local oMdlGridDJ9	:= oModel:GetModel( "MdGridDJ9" )
Local nCount      := ""
Local aSaveLine   := FWSaveRows()
Local cData       := ""
Local cHora       := ""
Local cUsuario    := ""
Local lRet        := .F.

If nOperation == MODEL_OPERATION_UPDATE
	cData       := dDataBase
	cHora       := StrTran(Left(Time(),5),':','')
	cUsuario    := RetCodUsr() 
EndIf

If nOperation == MODEL_OPERATION_UPDATE  
	For nCount := 1 To oMdlGridDJ9:Length()              	                                              
		oMdlGridDJ9:GoLine( nCount )
		
		lMarca:= FwFldGet('DJ9_IDMARK')
		If lMarca 
			lMarca:= Empty(FwFldGet('DJ9_DATCHK'))
		EndIf

	 	oMdlGridDJ9:SetValue( 'DJ9_DATCHK', Iif(lMarca,cData,'') ) 
		oMdlGridDJ9:SetValue( 'DJ9_HORCHK', Iif(lMarca,cHora,'') )
		oMdlGridDJ9:SetValue( 'DJ9_CODUSR', Iif(lMarca,cUsuario,'') )

		 	
	Next nCount    
EndIf

lRet := FwFormCommit(oModel)
                                                                                                 
FwRestRows( aSaveLine )	
Return lRet
