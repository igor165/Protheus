#INCLUDE "TMSA013.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/-----------------------------------------------------------
{Protheus.doc} TMSA013()
Cadastro de Componentes de Frete por Destinatário

Uso: SIGATMS

@sample
//TMSA013()

@author Gabriela Kamimoto.
@since 06/08/2012
@version 1.0
-----------------------------------------------------------/*/
Function TMSA013()
Local oBrowse		:= Nil
Private aRotina 	:= MenuDef()


oBrowse := FWMBrowse():New()   
oBrowse:SetAlias("DYE")			    			// Alias da tabela utilizada
oBrowse:SetMenuDef("TMSA013")					// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)   				//"Componentes de Frete por Destinatário"
	
oBrowse:Activate()
	
Return Nil

//---------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSA013" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSA013" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.TMSA013" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0008  ACTION "VIEWDEF.TMSA013" OPERATION 5 ACCESS 0 // "Excluir"
	
Return aRotina

//---------------------------------------------------------

Static Function ModelDef()
Local oModel     	:= Nil
Local oStruDYE 	:= Nil 
Local oStruDYF	:= Nil

Local bPosValid := { |oMdl| PosVldMdl(oMdl) }
oStruDYE := FwFormStruct(1,"DYE",,)
oStruDYF := FwFormStruct(1,"DYF",,)

oStruDYE:SetProperty("*",MODEL_FIELD_WHEN,FWBuildFeature(STRUCT_FEATURE_WHEN,/*"TMSA013Pre()"*/) ) 
                                                             
oModel := MPFormModel():New( "TMSA013",/*bPre*/,bPosValid,/*bCommit*/, /*bCancel*/ )

oModel:AddFields("DYE_MASTER",,oStruDYE ,/*bPreValid*/, /*bPosValid*/,/*Carga*/)

oModel:AddGrid("DYF_DETAIL","DYE_MASTER", oStruDYF,/*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/,/*BLoad*/ ) 

oModel:SetRelation("DYF_DETAIL",{ {"DYF_FILIAL","xFilial('DYF')"},{"DYF_CODPAS","DYE_CODPAS"} }, "DYF_ITEM" ) 
oModel:GetModel("DYF_DETAIL"):SetUniqueLine( { "DYF_CLIDES", "DYF_LOJDES"} ) 
oModel:GetModel("DYF_DETAIL"):SetDescription(STR0002)
oModel:GetModel("DYF_DETAIL"):SetMaxLine(25000)

oModel:SetDescription(STR0001) 								//-- "Componentes de Frete por Destinatário" 
oModel:GetModel("DYE_MASTER"):SetDescription(STR0001)	   //-- "Componentes de Frete por Destinatário"
oModel:SetPrimaryKey({"DYE_FILIAL" , "DYE_CODPAS"})   

Return oModel   


//---------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel   := FwLoadModel("TMSA013")
Local oStruDYE := FwFormStruct(2,"DYE") 
Local oStruDYF := FwFormStruct(2,"DYF")

oStruDYF:RemoveField("DYF_CODPAS")

oView := FwFormView():New()
oView:SetModel(oModel)  

oView:AddField('VIEW_DYE', oStruDYE , 'DYE_MASTER') 
oView:AddGrid( 'VIEW_DYF', oStruDYF , 'DYF_DETAIL')

oView:CreateHorizontalBox('CABECALHO', 30)
oView:CreateHorizontalBox('GRID'	 , 70)

oView:SetOwnerView('VIEW_DYE','CABECALHO')
oView:SetOwnerView('VIEW_DYF','GRID'     )
                                                                     	
oView:AddUserButton( STR0003 , 'PIN', {|| TMSA013Cpo('DYE_DOCCOB')} ) 	//"Doc.Cobrança"                                                          

oView:AddIncrementField('VIEW_DYF','DYF_ITEM')
      
Return oView


/*/--------------------------------------------------------
{Protheus.doc} TMSA013Vld()

Validação do campo "DYF_CLIDES"  na GetDados. 
cCampo: DYF_CLIDES

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 08/08/2012
@version 1.0   
//---------------------------------------------------------
/*/

Function TMSA013Vld(cCampo)
Local aGetArea 	 := GetArea( )
Local lRet    	 := .F.

Default cCampo  := Alltrim( Readvar()) 

	If "DYF_CLIDES" $ cCampo 
	
		lRet := ExistCpo( "SA1", FwFldGet( "DYF_CLIDES" ), 1 )
		
	ElseIf "DYF_LOJDES" $ cCampo
	
	 	lRet := ExistCpo( "SA1", FwFldGet( "DYF_CLIDES" ) + FwFldGet( "DYF_LOJDES" ), 1 )
	
	EndIf
		     	                     
RestArea( aGetArea )

Return( lRet ) 


/*/--------------------------------------------------------
{Protheus.doc} TMSA013Whn()

Validação do campo DYF_LOJDES na GetDados.
cCampo: DYF_LOJDES

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 08/08/2012
@version 1.0   
//---------------------------------------------------------
/*/
                         
Function TMSA013Whn(cCampo)
Local aGetArea  := GetArea( )
Local lRet      := .T.

Default cCampo  := AllTrim( ReadVar() )

           
If "DYF_LOJDES" $ cCampo

	If Empty( FwFldGet( "DYF_CLIDES" ) )
		lRet := .F.
	EndIf
	
EndIf

RestArea( aGetArea )

Return ( lRet )      


/*/--------------------------------------------------------
{Protheus.doc} TMSA013Whn()

Validação dos campos DYF_DATDE e DYF_DATATE

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 15/08/2012
@version 1.0   
//---------------------------------------------------------
/*/

Function TMSA012Dat(cDatVld)
Local aGetArea := GetArea( ) 
Local lRet 	 := .T.

Default cDatVld  := AllTrim( ReadVar() )

If "DYF_DATDE" $ cDatVld .And. !Empty( FwfldGet( "DYF_DATATE" ) )
	If FwFldGet( "DYF_DATDE" ) >= FwFldGet( "DYF_DATATE" )
		lRet := .F.
	EndIf
ElseIf "DYF_DATATE" $ cDatVld .And. !Empty( FwFldGet( "DYF_DATDE" ) )
	If FwFldGet( "DYF_DATATE" ) <= FwFldGet( "DYF_DATDE" )
		lRet := .F.
	EndIf
EndIf 

RestArea( aGetArea )

Return lRet


/*/--------------------------------------------------------
{Protheus.doc} TMSA013Cpo()
 Valida o campo DYE_DOCCOB e gatilha o mesmo.

@sample
//TMSA012()

@author Gabriela Kamimoto.
@since 21/08/2012
@version 1.0   
//---------------------------------------------------------
/*/

Static Function TMSA013Cpo(cCampo)
Local oModel  := FWModelActive()
Local nOper   := oModel:GetOperation() 
Local cDocCob	:= ""


oModel := oModel:GetModel("DYE_MASTER")

M->&(cCampo) := oModel:GetValue(cCampo)
           
TmsA480SepDoc(cCampo)

cDocCob := M->&(cCampo)

If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE
	oModel:SetValue(cCampo, cDocCob )
EndIf	 

Return

/*/--------------------------------------------------------
{Protheus.doc} PosVldMdl()
 PosValid Model

@sample
//TMSA013()

@author Rafael Souza.
@since Novembro / 2016
@version 1.0   
//---------------------------------------------------------
/*/
Static Function PosVldMdl(oMdl)

Local cAliasCMP  := GetNextAlias()
Local cQuery     := ''
Local cCompDest  := ''
Local lRet       := .T.

If oMdl <> Nil .And. oMdl:GetOperation() == MODEL_OPERATION_DELETE

	cQuery :=  ""
	cQuery :=  " SELECT DYA_TABFRE, DYA_CLIDES " 
	cQuery +=  "   FROM "+RetSqlName('DYA')+" DYA "
	cQuery +=  "  WHERE DYA_FILIAL = '" + xFilial("DYA") + "'" 
	cQuery +=  "    AND DYA_CODPAS = '" + DT3->DT3_CODPAS + "'"  
	cQuery +=  "    AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasCMP,.T.,.T.)
	
	If (cAliasCMP)->(!Eof())
	
		aArea := (cAliasCMP)->(GetArea())
		While (cAliasCMP)->(!Eof())
			cCompDest += STR0009 + (cAliasCMP)->DYA_TABFRE + " / " + STR0010 + (cAliasCMP)->DYA_CLIDES + CHR(13)+CHR(10)     
		   (cAliasCMP)->(dbSkip())
		EndDo
		RestArea(aArea)
		
		Help(' ', 1, 'TMSA01301',,CHR(13)+CHR(10)+CHR(13)+CHR(10)+ cCompDest,4,1) 
		lRet := .F.		
	EndIf

Endif

Return lRet  

