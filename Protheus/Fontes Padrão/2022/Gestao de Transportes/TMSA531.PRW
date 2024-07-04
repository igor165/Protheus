#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSA531.CH' 
#INCLUDE "FWMVCDEF.CH" 

//===========================================================================================================
/* Rotina de Composicao de Tipo de Veiculo
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		18/06/2013
@return	*/
//===========================================================================================================
Function TMSA531()

Local oMBrowse  := Nil

Private aRotina := MenuDef()             

oMBrowse:= FwMBrowse():New()
oMBrowse:SetAlias( "DUT" )
oMBrowse:SetDescription( STR0001 )

oMBrowse:SetFilterDefault( "DUT_CATVEI == '6' " )  //Categoria Composicao

oMBrowse:Activate()

Return 
          
//===========================================================================================================
/* Retorna o modelo de Dados 
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		18/06/2013
@return 	oModel - Modelo de Dados */                                                                                                         
//===========================================================================================================
Static Function ModelDef()

Local oModel    := Nil

Local oStruGDYO := FwFormStruct( 1, 'DYO' )

oModel := FwLoadModel("TMSA530")

oModel:SetDescription( STR0001 )   


//-- Apenas visualizacao para o cabecalho
oModel:GetModel("TMSA530_DUT"):SetOnlyView( .T. ) 

//-- Validação da exclusao do Model 
oModel:bPost := {|oModel|TMS531Vld(oModel)}

oModel:SetPrimaryKey( { 'DUT_FILIAL', 'DUT_TIPVEI' } )

oModel:AddGrid( 'MdGridDYO', 'TMSA530_DUT', oStruGDYO, { |oModel| PreVldDYO( oModel ) }, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, )

oModel:SetRelation('MdGridDYO',{{"DYO_FILIAL","xFilial( 'DYO' )"},{"DYO_CODCPO","DUT_TIPVEI"}},DYO->(IndexKey(1)) ) 

oModel:GetModel( 'TMSA530_DUT' ):SetOnlyQuery( .T. )  //Nao altera dados da tabela DUT

oModel:GetModel( 'MdGridDYO' ):SetOptional( .T. )  

Return( oModel ) 

//===========================================================================================================
/* Retorna a View (tela) 
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		18/06/2013
@return 	aRotina - Array com as opçoes de Menu */                                                                                                          
//===========================================================================================================
Static Function ViewDef()

Local oView 	:= Nil
Local oModel	:= FwLoadModel( 'TMSA531' )
Local oStruCDUT	:= FwFormStruct( 2,"DUT" ,{|cCampo|  AllTrim(cCampo) + "|" $ 'DUT_TIPVEI|DUT_DESCRI|' } )

Local oStruGDYO	:= FwFormStruct( 2, 'DYO', {|cCampo| AllTrim(cCampo)+"|" $ "DYO_ITEM|DYO_TIPVEI|DYO_DESTIP|"} )

oView := FwFormView():New()

oView:SetModel( oModel )

oView:CreateHorizontalBox( 'Field', 020 )
oView:CreateHorizontalBox( 'Grid', 080 )

oView:AddField( 'VwFieldDUT', oStruCDUT, 'TMSA530_DUT' )

oView:AddGrid( 'VwGridDYO', oStruGDYO, 'MdGridDYO' )

oView:SetOwnerView( 'VwFieldDUT', 'Field' )
oView:SetOwnerView( 'VwGridDYO' , 'Grid' )

oView:AddIncrementField('VwGridDYO','DYO_ITEM')

Return( oView )
                              
//===========================================================================================================
/* Retorna as operações disponiveis 
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		18/06/2013
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()

Local aRotina := {{ STR0001, "AxPesqui"        ,0 , 1,,.F. },;         //"Pesquisar"
                  { STR0002, "VIEWDEF.TMSA531" ,0 , 2 },;               //"Visualizar"
                  { STR0004, "VIEWDEF.TMSA531" ,0 , 4 },;               //"Composição"
                  { STR0005, "VIEWDEF.TMSA531" ,0 , 5 } }               //"Excluir"                

Return( aRotina )

//===========================================================================================================
/* Valida Formulario
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		18/06/2013
@return		lRet
//===========================================================================================================
*/
Function TMS531Vld(oModel)
Local nOperation := oModel:GetOperation()        
Local cAliasQry  := ""
Local lRet       := .T.

If nOperation == 5  //Exclusao
	cAliasQry := GetNextAlias()
	cQuery := "SELECT COUNT(*) NQTDE FROM "
	cQuery += RetSqlName("DYP")+" DYP "
	cQuery += " WHERE DYP.DYP_FILIAL = '"+xFilial('DYP')+"'"
	cQuery += "   AND DYP.DYP_TIPVEI = '"+DUT->DUT_TIPVEI+"'"
	cQuery += "   AND DYP.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If (cAliasQry)->NQTDE > 0
		//Help("",,"TMSA53102" ) 
		oModel:SetErrorMessage (,,,,,"Composição relacionada a uma Praça de Pedagio! Não é permitido a exclusão")
		lRet := .F.  
	EndIf
	(cAliasQry)->(dbCloseArea())
EndIf

Return( lRet )


//===========================================================================================================
/* Pre Valid 
@author  	Katia
@version 	P11 R11.8
@build		700120420A
@since 		18/06/2013
@return		lRet
//===========================================================================================================
*/
Static Function PreVldDYO( oModel )

Local nOperation := oModel:GetOperation()
Local lRet 		 := .T.
Local cTipVei    := oModel:GetValue("DYO_TIPVEI")
Local aAreaDUT   := DUT->(GetArea())                                          

If nOperation == 4 .And. !Empty(cTipVei)	
	DUT->( dbSetOrder(1) )
	If DUT->( dbSeek(xFilial("DUT") + cTipVei) )     
		If DUT->DUT_CATVEI == StrZero(6,(Len(DUT->DUT_CATVEI)))  //Composicao
			Help("",,"TMSA53101" ) 
			lRet:= .F.	                        
	   	EndIf
	EndIf	   	  	
EndIf
                          
RestArea(aAreaDUT)
Return lRet
