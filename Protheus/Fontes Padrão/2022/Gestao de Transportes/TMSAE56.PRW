#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'TMSAE56.CH'

//-----------------------------------------------------------------------------------------------------------
/* EDI - Notas Fiscais Importadas
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	17/08/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSAE56( xRotAuto, nOpcAuto, xItem )

Local cCadastro		:= STR0001 //"LOTE EDI" 
Local lTME56Auto		:= ( ValType( xRotAuto ) == "A" )

Private aRotina		:= MenuDef()
Private aAutoCab		:= {}
Private aItem			:= {}

Default xRotAuto 		:= Nil
Default nOpcAuto 		:= 3
Default xItem			:= Nil
	
If !lTME56Auto
	oMBrowse:= FWMBrowse():New()	
	oMBrowse:SetAlias( "DET" )
	oMBrowse:SetDescription( cCadastro )
	oMBrowse:Activate()
Else
	aAutoCab := xRotAuto
	aItem	  := xItem
	FwMvcRotAuto( ModelDef(), "DET", nOpcAuto, { { "TMSE56CDET", aAutoCab }, { "TMSE56IDET", aItem } } )  //Chamada da rotina automatica através do MVC
EndIf

Return

//-----------------------------------------------------------------------------------------------------------
/* Modelo de Dados 
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	17/08/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 		:= Nil

Local oStruCDET 	:= FwFormStruct( 1, "DET", { |cCampo|  AllTrim( cCampo ) + "|" $ "DET_LOTEDI|DET_FILORI|DET_NUMCOT|" } )
Local oStruIDET 	:= FwFormStruct( 1, "DET", { |cCampo| !AllTrim( cCampo ) + "|" $ "DET_LOTEDI|DET_FILORI|DET_NUMCOT|" } )

oStruCDET:AddField( ;                      // Ord. Tipo Desc.
"DET_MVC"      	                , ;      // [01]  C   Titulo do campo
"MVC"			                   , ;      // [02]  C   ToolTip do campo
"DET_MVC"		                      , ;      // [03]  C   Id do Field
'C'                              , ;      // [04]  C   Tipo do campo
1                                , ;      // [05]  N   Tamanho do campo
0                                , ;      // [06]  N   Decimal do campo
NIL                              , ;      // [07]  B   Code-block de validação do campo
NIL                              , ;      // [08]  B   Code-block de validação When do campo
NIL                              , ;      // [09]  A   Lista de valores permitido do campo
NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
NIL                              , ;      // [11]  B   Code-block de inicializacao do campo
NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
NIL                              )        // [14]  L   Indica se o campo é virtual


oModel := MpFormModel():New( "TMSAE56", /*bPre*/, { |oModel| PosVldMdl( oModel ) }, /*bCommit*/, /*bCancel*/ )

oModel:AddFields( "TMSE56CDET", Nil, oStruCDET, /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/ )

oModel:SetPrimaryKey( { "DET_FILIAL","DET_LOTEDI","DET_CODPAS" } )

oModel:AddGrid( "TMSE56IDET", "TMSE56CDET", oStruIDET )

oModel:SetRelation( "TMSE56IDET", { { "DET_FILIAL", "xFilial('DET')" }, { "DET_LOTEDI", "DET_LOTEDI" } }, DET->( IndexKey( 1 ) ) )

oModel:GetModel( "TMSE56IDET" ):SetUniqueLine( { "DET_CODPAS" } )

oModel:GetModel( "TMSE56IDET" ):SetDelAllLine( .T. )

oModel:AddCalc( "TMSE56TOT", "TMSE56CDET", "TMSE56IDET", "DET_VALOR"   , STR0007, "SUM"   ) // "Total Valor"
oModel:AddCalc( "TMSE56TOT", "TMSE56CDET", "TMSE56IDET", "DET_VALCAL"  , STR0008, "SUM"   ) // "Total Vl. Calculado"

oModel:SetDescription( OemToAnsi( STR0001 ) ) // Lote EDI

Return( oModel )

//-----------------------------------------------------------------------------------------------------------
/* Retorna a View (tela) da rotina Cadastro de Endereço 
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	17/08/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FwLoadModel( "TMSAE56" )
Local oView		:= Nil
Local oStruCDET 	:= FwFormStruct( 2, "DET", { |cCampo|  AllTrim( cCampo ) + "|" $ "DET_LOTEDI|DET_FILORI|DET_NUMCOT|" } )
Local oStruIDET 	:= FwFormStruct( 2, "DET", { |cCampo| !AllTrim( cCampo ) + "|" $ "DET_LOTEDI|DET_FILORI|DET_NUMCOT|" } )
Local oCalc1   := Nil 

oStruCDET:RemoveField( "DET_MVC" )

oCalc1 := FWCalcStruct( oModel:GetModel( "TMSE56TOT" ) )

oView := FwFormView():New()
oView:SetModel( oModel )

oView:AddField( "VIEWCDET", oStruCDET, "TMSE56CDET" )
oView:AddGrid(  "VIEWIDET", oStruIDET, "TMSE56IDET" )
oView:AddField( "VIEWCALC", oCalc1   , "TMSE56TOT"  )

oView:CreateHorizontalBox( "FIELD"  , 20 )
oView:CreateHorizontalBox( "GRID"   , 70 )
oView:CreateHorizontalBox( "TOTAL"  , 10 )

oView:SetOwnerView( "VIEWCDET"  , "FIELD"   )
oView:SetOwnerView( "VIEWIDET"  , "GRID"	  )
oView:SetOwnerView( "VIEWCALC"  , "TOTAL"	  )

oView:AddIncrementField( "VIEWIDET", "DET_ITEM" )

Return( oView )

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Nota Fiscal EDI.
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	17/08/2012
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()

Local aArea	:= GetArea()
Local aRotina := {}

aAdd( aRotina, { STR0002	, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003	, "VIEWDEF.TMSAE56"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004	, "VIEWDEF.TMSAE56"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005	, "VIEWDEF.TMSAE56"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006	, "VIEWDEF.TMSAE56"  , 0, 5, 3, Nil } ) // Excluir

RestArea( aArea )

Return aRotina

Static Function PosVldMdl( oMdl )

Local lRet 	:= .T.
Local nOpcx	:= oMdl:GetOperation()
Local cFilOri	:= ""
Local cNumCot	:= ""

If nOpcx == MODEL_OPERATION_INSERT
		oMdl:SetValue( "TMSE56CDET", "DET_MVC", "1" )
Else
	cFilOri	:= oMdl:GetValue( "TMSE56CDET", "DET_FILORI" )
	cNumCot	:= oMdl:GetValue( "TMSE56CDET", "DET_NUMCOT" )
	
	If !Empty( cFilOri ) .And. !Empty( cNumCot )
		lRet := .F.
		Help( " ",1,"TMSAE5601",,Chr(13)+Chr(10)+"- "+ STR0009, 1, 0 ) // "Lote já calculado"
	EndIf
EndIf

Return( lRet )