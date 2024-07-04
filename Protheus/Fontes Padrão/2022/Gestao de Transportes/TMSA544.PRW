#INCLUDE "TMSA544.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------------------------------------------------------------------------
/* Browse da rotina de Atribuicao de Responsabilidades
@author  	Katia
@version 	P11 R11.8
@since 	    14/07/2014
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSA544()

Local oMBrowse := Nil

Private aRotina   := MenuDef()
Private cCadastro := STR0001

oMBrowse:= FWMBrowse():New()
oMBrowse:SetAlias("DUU")
oMBrowse:SetDescription( STR0001 ) // "Atribuicao de Responsabilidades"

//-------------------------------------------------------------------
// Adiciona legendas no Browse
//-------------------------------------------------------------------

ADD LEGEND DATA 'DUU->DUU_IDRSP<>" "' COLOR "RED"    TITLE STR0009 OF oMBrowse // "Com Analise
ADD LEGEND DATA 'DUU->DUU_IDRSP==" "' COLOR "GREEN"  TITLE STR0008 OF oMBrowse // "Sem Analise

oMBrowse:SetFilterDefault( "DUU_TIPPND <> '99' " )  //Bloqueio

oMBrowse:Activate()

Return

//===========================================================================================================
/* Retorna o modelo de Dados 
@author  	Katia
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	oModel - Modelo de Dados */                                                                                                         
//===========================================================================================================
Static Function ModelDef()

Local oModel 	:= Nil
Local oStruCDUU := FwFormStruct( 1, "DUU" , {|cCampo| AllTrim(cCampo)+"|" $ "DUU_FILPND|DUU_NUMPND|DUU_DATPND|DUU_HORPND|DUU_TIPPND|DUU_DESPND|DUU_FILDOC|DUU_DOC|DUU_SERIE|DUU_FILORI|DUU_VIAGEM|DUU_CODOCO|DUU_DESOCO|DUU_QTDOCO|DUU_QTDCON|DUU_IDRSP|DUU_CODRSP|DUU_DESRSP|DUU_DATRSP|"}) 
Local oStruGDIP := FwFormStruct( 1, "DIP" , {|cCampo| AllTrim(cCampo)+"|" $ "DIP_ITEM|DIP_FILRSP|DIP_NOMFIL|DIP_PERCEN|" } )

oModel := MpFormModel():New( "TMSA544",/*bPre*/, { |oMdl| TMSA544POS( oMdl ) } /*bPost*/, { |oMdl| TMSA544GRV( oMdl ) }/*bCommit*/, /*bCancel*/ )
                                                      
oModel:SetVldActivate( { |oModel| VldActMdl( oModel ) } )

oModel:SetDescription( STR0001 ) 
                                
oModel:AddFields( 'MdFieldDUU', Nil, oStruCDUU )  

oModel:AddGrid( 'MdGridDIP' , 'MdFieldDUU', oStruGDIP ) ///, /*bLinePre*/ , { |oMdlGrid| PosLinGrd(oModel) },/*bPreVal*/, /*bPosValid*/,  &("{ |oModel| LdGridDYZ( oModel, DYZ->DYZ_FILPND, DYZ->DYZ_NUMPND, DYZ->DYZ_TIPPND, DYZ->DYZ_NUMNFC, DYZ->DYZ_SERNFC )}") /*BLoad*/   )  
                                                          
oModel:SetRelation( "MdGridDIP",{{ "DIP_FILIAL" , "xFilial('DIP')" }, { "DIP_FILPND" , "DUU_FILPND" } , { "DIP_NUMPND" , "DUU_NUMPND" }} , DIP->( IndexKey(1) ))

oModel:SetPrimaryKey( { 'DIP_FILIAL', 'DIP_FILPND', 'DIP_NUMPND', 'DIP_ITEM' } )

oModel:GetModel( "MdGridDIP" ):SetUniqueLine( { "DIP_FILRSP" } )  

oModel:SetOptional("MdGridDIP", .T.)       

oModel:SetActivate( { |oModel| TMSA544ACT( oModel ) } )

Return oModel

//===========================================================================================================
/* Retorna a View (tela) da rotina 
@author  	Katia
@version 	P11 R11.8
@since 	    14/07/2014
@return 	oView -  */                                                                                                              
//===========================================================================================================
Static Function ViewDef()

Local oView 	:= Nil
Local oModel    := FwLoadModel( "TMSA544" )
Local oStruCDUU := FwFormStruct( 2, "DUU" , {|cCampo| AllTrim(cCampo)+"|" $ "DUU_FILPND|DUU_NUMPND|DUU_DATPND|DUU_HORPND|DUU_TIPPND|DUU_DESPND|DUU_FILDOC|DUU_DOC|DUU_SERIE|DUU_FILORI|DUU_VIAGEM|DUU_CODOCO|DUU_DESOCO|DUU_QTDOCO|DUU_QTDCON|DUU_IDRSP|DUU_CODRSP|DUU_DESRSP|DUU_DATRSP|"} )
Local oStruGDIP := FwFormStruct( 2, "DIP" , {|cCampo| AllTrim(cCampo)+"|" $ "DIP_ITEM|DIP_FILRSP|DIP_NOMFIL|DIP_PERCEN|" } )
Local oCalc1    := Nil 

oView := FwFormView():New()

oView:SetModel( oModel )

oView:AddField( "VwFieldDUU" , oStruCDUU, "MdFieldDUU" )
oView:AddGrid(  "VwGridDIP"  , oStruGDIP, "MdGridDIP"  )
                             
oView:CreateHorizontalBox( 'Field' , 45 )
oView:CreateHorizontalBox( 'Grid'  , 45 )

oView:SetOwnerView( "VwFieldDUU" , "Field" )
oView:SetOwnerView( "VwGridDIP"  , "Grid"  )

oView:AddIncrementField( "MdGridDIP", "DIP_ITEM" )

oView:SetCloseOnOk({|| .T. })

Return oView


//===========================================================================================================
/* Retorna as operações disponiveis para a Rotina
@author  	Katia
@version 	P11 R11.8
@since 	    14/07/2014
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()
             
Local aRotina:= {}

aAdd( aRotina, { STR0002, "PesqBrw"           , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003, "VIEWDEF.TMSA544"   , 0, 2, 0, NIL } ) // Visualizar
aAdd( aRotina, { STR0004, "VIEWDEF.TMSA544"   , 0, 4, 0, NIL } ) // Atribuir
aAdd( aRotina, { STR0006, "TMSA544EST()"      , 0, 5, 0, NIL } ) // Estornar
aAdd( aRotina, { STR0007, "TMSA544DOC()"      , 0, 6, 0, NIL } ) // Cons.Docto

Return aRotina

//===========================================================================================================
/* Gravacao do Formulario
@author  	Katia
@version 	P11 R11.8
@since 		15/07/2014
@return 	lRet -  */                                                                                                            
//===========================================================================================================
Static Function TMSA544GRV( oModel, lEstorno)

Local aGetArea	:= GetArea()
Local lRet			:= .T.
Local nCount 		:= 0
Local cChave		:= "" 

Default lEstorno	:= .F.

If lEstorno                      
	DIP->( DbSetOrder( 1 ) )
	DIP->( DbSeek( cChave:= xFilial( "DIP" ) + DUU->DUU_FILPND + DUU->DUU_NUMPND ) )
	Do While DIP->(!Eof()) .And. cChave ==  xFilial( "DIP" ) + DIP->DIP_FILPND + DIP->DIP_NUMPND
		RecLock( "DIP", .F. )	
		DIP->(DbDelete())
		MsUnLock()
		DIP->(DbSkip())
	EndDo
	
	RecLock( "DUU", .F. )	
	DUU->DUU_IDRSP := ""
	DUU->DUU_CODRSP:= ""	
	DUU->DUU_DATRSP:= CtoD("")
	MsUnLock()
Else
	FwFormCommit( oModel )
EndIf

RestArea( aGetArea )
Return( lRet )

//===========================================================================================================
/* Pós Validação
@author     Katia
@version 	P11 R11.8
@since 	    15/07/2014
@return 	lRet */                                                                                                             
//===========================================================================================================

Static Function TMSA544POS( oModel )

Local aGetArea	:= GetArea()
Local lRet 		:= .T.
Local nOperation:= oModel:GetOperation()     
Local oMdlStru  := oModel:GetModel("MdGridDIP")	
Local nLineDIP  := oMdlStru:GetLine()
Local nPerTot   := 0  
Local nCount    := 0

If nOperation == 4
	If Empty(M->DUU_IDRSP) 
		Help('',1,"OBRIGAT2",,RetTitle("DUU_IDRSP"),04,01) 
		lRet:= .F.
	ElseIf 	Empty(M->DUU_CODRSP) 
		Help('',1,"OBRIGAT2",,RetTitle("DUU_CODRSP"),04,01) 
		lRet:= .F.
	EndIf  
	                                   
	If lRet
		For nCount := 1 To oMdlStru:Length()		
			oMdlStru:GoLine( nCount )
			
			If !oMdlStru:IsDeleted()
				nPerTot+= oMdlStru:GetValue("DIP_PERCEN")
			EndIf
		Next nCount          
	
		oMdlStru:GoLine(nLineDIP)
	
		If nPerTot <> 100
			Help("",1,"TMSA54402")   
			lRet:= .F.
		EndIf
	EndIf	
EndIf

RestArea( aGetArea )
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA544Doc
Rotina para consultar o Documento
@author Katia
@since 03/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSA544DOC()
Local aArea:= GetArea()

DT6->(DbSetOrder(1))
If DT6->(dBSeek(xFilial("DT6")+DUU->(DUU_FILDOC+DUU_DOC+DUU_SERIE)))
	cCadastro := "Manutencao de Documentos - Visualizar"
	TMSA500Mnt("DT6",DT6->(Recno()),2)
EndIf

RestArea(aArea)
Return 


//===========================================================================================================
/* Validacao da Ativacao do Model
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return		lRet
//===========================================================================================================
*/
Static Function VldActMdl(oModel)
Local aGetArea	:= GetArea()
Local lRet 		:= .T.       
Local nOperation:= oModel:GetOperation()
 
If nOperation == MODEL_OPERATION_UPDATE   
	If !Empty(DUU->DUU_IDRSP )      
		Help(" ",,"TMSA54401") //-- Analise ja efetuada para esta pendencia
		lRet:= .F.
	EndIf	
EndIf	

RestArea( aGetArea )
Return( lRet )


//===========================================================================================================
/* Ativacao do Model
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		07/02/2013
@return		lRet
//===========================================================================================================
*/
Static Function TMSA544ACT(oModel)
Local aGetArea	:= GetArea()
Local lRet 		:= .T.       
Local nOperation:= oModel:GetOperation()
 
If nOperation == MODEL_OPERATION_UPDATE   
	oModel:SetValue('MdFieldDUU', "DUU_DATRSP" , dDataBase)		
	oModel:SetValue('MdFieldDUU', "DUU_DESRSP" , "")		
EndIf	

RestArea( aGetArea )
Return( lRet )


//===========================================================================================================
/* Estorno da Atribuicao
@author  	Katia
@version 	P12.1.7
@since 	01/09/2015
@return	lRet
//===========================================================================================================
*/
Function TMSA544EST()
Local aGetArea    := GetArea()
Local lRet        := .F.       

If !Empty(DUU->DUU_IDRSP )      
	If (lRet:=MsgYesNo(STR0010)) //-- Confirma o Estorno da Atribuicao de Responsabilidades ? // Sim   // Não
		TMSA544GRV(,.T.)
	EndIf
EndIf	

RestArea( aGetArea )
Return( lRet )
