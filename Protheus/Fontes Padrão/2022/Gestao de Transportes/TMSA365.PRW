#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "TMSA365.CH"

//-----------------------------------------------------------------------------------------------------------
/* Ocorrencias X Dest. e-mails
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSA365()

Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

If AMiIn(39,42,43) //-- Somente autorizado para OMS, WMS e TMS
	oMBrowse:= FWMBrowse():New()	
	oMBrowse:SetAlias( "DWU" )
	oMBrowse:SetDescription( STR0001 )
	
	oMBrowse:AddLegend( "DWU_ATIVO== '1'", "GREEN"	, STR0008 )  //E-Mail Ativo
	oMBrowse:AddLegend( "DWU_ATIVO== '2'", "RED"	, STR0009 )  //E-Mail Inativo

	oMBrowse:Activate()
EndIf

Return NIL

//-----------------------------------------------------------------------------------------------------------
/* ModelDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	:= NIL
Local oStruFDWU	:= Nil
Local oStruGDWU	:= Nil
Local cCpoField := "|DWU_TIPO|DWU_CODOCO|DWU_DESOCO|DWU_TIPOCO|DWU_DTPOCO|"
Local bPosValid := { || PosVldMdl() }

oStruFDWU := FwFormStruct( 1, "DWU", { |cCampo|  AllTrim( cCampo ) + "|" $ cCpoField } )
oStruGDWU := FwFormStruct( 1, "DWU", { |cCampo| !AllTrim( cCampo ) + "|" $ cCpoField } )

oModel := MPFormModel():New( "TMSA365",/*bPreValid*/, bPosValid, /*Commit*/, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDWU', Nil	, oStruFDWU, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:SetPrimaryKey( { "DWU_FILIAL","DWU_CODOCO", "DWU_TIPOCO", "DWU_ID" } )

oModel:AddGrid( "MdGridDWU", "MdFieldDWU", oStruGDWU )

oModel:SetRelation( "MdGridDWU", { { "DWU_FILIAL", "xFilial('DWU')" }, { "DWU_CODOCO", "DWU_CODOCO" } , { "DWU_TIPOCO", "DWU_TIPOCO" }  }, DWU->( IndexKey( 1 ) ) )

oModel:GetModel( "MdGridDWU" ):SetUniqueLine( { "DWU_CODUSR"} )

Return( oModel )

//-----------------------------------------------------------------------------------------------------------
/* ViewDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView 	:= NIL
Local oModel   	:= NIL 
Local oStruGDWU	:= Nil
Local cCpoField := "|DWU_TIPO|DWU_CODOCO|DWU_DESOCO|DWU_TIPOCO|DWU_DTPOCO|"

oStruFDWU := FwFormStruct( 2, "DWU", { |cCampo|  AllTrim( cCampo ) + "|" $ cCpoField } )
oStruGDWU := FwFormStruct( 2, "DWU", { |cCampo| !AllTrim( cCampo ) + "|" $ cCpoField } )

oModel   := FwLoadModel( "TMSA365" )

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDWU', oStruFDWU , 'MdFieldDWU' )

oView:AddGrid( "VwGridDWU", oStruGDWU, "MdGridDWU" )

oView:AddIncrementField( 'VwGridDWU', 'DWU_ID' )

oView:CreateHorizontalBox( 'FIELD'  , 40 )
oView:CreateHorizontalBox( 'GRID'   , 60 )

oView:SetOwnerView( 'VwFieldDWU' , 'FIELD')
oView:SetOwnerView( 'VwGridDWU'  , 'GRID' )

Return( oView )

//-----------------------------------------------------------------------------------------------------------
/* PosVldMdl 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function PosVldMdl()

Local oModel	:= FWModelActive()	// Recebe o model Ativo
Local lRet 	:= .T.					// Recebe o Retorno

If M->DWU_TIPO == '1' .And. Empty(M->DWU_CODOCO)
	Help(1," ","OBRIGAT",,Alltrim(FWX3Titulo('DWU_CODOCO')),3,0)   //Campo CODIGO DA OCORRENCIA"
	lRet := .F.
ElseIf M->DWU_TIPO == '2' .And. Empty(M->DWU_TIPOCO)
	Help(1," ","OBRIGAT",,Alltrim(FWX3Titulo('DWU_TIPOCO')),3,0)   //Campo TIPO DA OCORRENCIA
	lRet := .F.
EndIf

Return lRet

//===========================================================================================================
/* MenuDef
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		13/05/2020
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()

Local aArea		:= GetArea() 

Private	aRotina	:= {}

aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003, "VIEWDEF.TMSA365"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004, "VIEWDEF.TMSA365"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005, "VIEWDEF.TMSA365"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006, "VIEWDEF.TMSA365"  , 0, 5, 3, Nil } ) // Excluir	

If ExistBlock("TM365MNU")
	ExecBlock("TM365MNU",.F.,.F.)
EndIf

RestArea( aArea )							 

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS365VLD  ³Autor³Vitor Raspa            ³ Data ³18.Abr.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMS365VLD()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA365                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMS365VLD()
Local lRet 		:= .T.
Local cCampo   := ReadVar()
If cCampo == 'M->DWU_TIPO'
	If M->DWU_TIPO == '1'
		M->DWU_TIPOCO = CriaVar('DWU_TIPOCO',.F.)
		M->DWU_DTPOCO = CriaVar('DWU_DTPOCO',.F.)
	ElseIf M->DWU_TIPO == '2'
		M->DWU_CODOCO = CriaVar('DWU_CODOCO',.F.)
		M->DWU_DESOCO = CriaVar('DWU_DESOCO',.F.)
	EndIf
EndIf

Return( lRet )