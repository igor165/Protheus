#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "Protheus.ch"  
#INCLUDE "TMSA665.ch"  


//-----------------------------------------------------------------------------------------------------------
/* Feruiados Regionais  
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	04/10/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------

Function TMSA665( xRotAuto, nOpcAuto )

Local oMBrowse		:= Nil
Local cCadastro		:= OemToAnsi( STR0001 )
Local lTM665Auto		:= ( ValType( xRotAuto ) == "A" )

Private aRotina		:= MenuDef()
Private aAutoCab		:= {}

Default xRotAuto 		:= Nil
Default nOpcAuto 		:= 3

	
If !lTM665Auto
	oMBrowse:= FWMBrowse():New()	
	oMBrowse:SetAlias( "DWY" )
	oMBrowse:SetDescription( cCadastro )
	oMBrowse:Activate()
Else
	aAutoCab := xRotAuto
	FwMvcRotAuto( ModelDef(), "DWY", nOpcAuto, { { "TMSA665DWY", aAutoCab } } )  //Chamada da rotina automatica através do MVC
EndIf

Return Nil

//-----------------------------------------------------------------------------------------------------------
/* Modelo de Dados 
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	04/10/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 		:= Nil
Local oStruDWY 	:= FwFormStruct( 1, "DWY" )

oModel := MpFormModel( ):New( "TMSA665", /*bPre*/, { |oModel| PosVldMdl( oModel ) }, /*bCommit*/, /*bCancel*/ )

oModel:AddFields( "TMSA665DWY", Nil, oStruDWY, /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/ )

oModel:SetPrimaryKey( { "DWY_FILIAL", "DWY_DIAMES", "DWY_ANO", "DWY_CDRDES" } )

oModel:SetDescription( OemToAnsi( STR0001 ) )                                                                                                    

Return( oModel )

//-----------------------------------------------------------------------------------------------------------
/* Retorna a View (tela) da rotina Cadastro de Feriados regionais
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	04/10/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FwLoadModel( "TMSA665" )
Local oView		:= Nil
Local oStruDWY	:= FwFormStruct( 2, "DWY" )

oView := FwFormView():New()

oView:SetModel( oModel )
oView:CreateHorizontalBox( "Field", 100 )

oView:AddField( "FieldDWY", oStruDWY, "TMSA665DWY" )

oView:SetOwnerView( "FieldDWY", "Field" )

Return( oView )


//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Feriados Regionais.
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	04/10/2012
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()

Local aArea	:= GetArea()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003, "VIEWDEF.TMSA665"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004, "VIEWDEF.TMSA665"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005, "VIEWDEF.TMSA665"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006, "VIEWDEF.TMSA665"  , 0, 5, 3, Nil } ) // Excluir

Return( aRotina )

//===========================================================================================================
Static Function PosVldMdl( oMdl )

Local lRet     := .T.  
Local aArea    := GetArea()
Local aAreaDWY := DWY->(GetArea())
Local nOpcx	 := oMdl:GetOperation()
Local cDiaMes  := oMdl:GetValue('TMSA665DWY','DWY_DIAMES')
Local cAno     := oMdl:GetValue('TMSA665DWY','DWY_ANO')
Local cCdrDes  := oMdl:GetValue('TMSA665DWY','DWY_CDRDES')

	DWY->(dbSetOrder(1))
	If (nOpcx == MODEL_OPERATION_INSERT .Or. nOpcx == MODEL_OPERATION_UPDATE ) .And.;
	   DWY->(MsSeek(xFilial("DWY")+cDiaMes+cAno+cCdrDes)) 
	   lRet := .F. 
	   Help(" ",1,"JAGRAVADO") //"Ja existe registro com esta informacao"
		
	EndIf

RestArea(aAreaDWY)
RestArea(aArea)

Return lRet 

