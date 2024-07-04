#INCLUDE "SFCA100.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'        
#INCLUDE 'FWADAPTEREAI.CH'

#DEFINE NEWLINE CHR(13)+CHR(10)

Static __lAutomacao := IsInCallStack("SFCA100_001")

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA100
Tela de cadastro de Ordem de Produção

@author Bruno Candido Volpato da Cunha
@since 12/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA100()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYQ')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Ordem de Produção'
oBrowse:AddLegend( 'CYQ->CYQ_TPST=="1"', 'BR_VERDE'   , STR0030 ) // 'Não Iniciada'
oBrowse:AddLegend( 'CYQ->CYQ_TPST=="3"', 'BR_LARANJA' , STR0031 ) // 'Iniciada'
oBrowse:AddLegend( 'CYQ->CYQ_TPST=="5"', 'BR_VERMELHO', STR0032 ) // 'Finalizada'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.SFCA100' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'SFCA100FIM()'    OPERATION 3 ACCESS 0  // 'Finalizar Ordem'       
If SFCIntegra() == 2
	ADD OPTION aRotina TITLE STR0025 ACTION 'SFCA100REA()' OPERATION 3 ACCESS 0 // 'Reabrir Ordem'
EndIf
ADD OPTION aRotina TITLE STR0041 ACTION 'VIEWDEF.SFCA100' OPERATION 4 ACCESS 0  // "Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA100' OPERATION 8 ACCESS 0  // 'Imprimir'
ADD OPTION aRotina TITLE STR0033 ACTION 'SFCA100LEG()'    OPERATION 6 ACCESS 0  // 'Legenda'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYQ := FWFormStruct( 1, 'CYQ', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStructCY9 := FWFormStruct( 1, 'CY9', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructCYD := FWFormStruct( 1, 'CYD', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructCYP := FWFormStruct( 1, 'CYP', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructCYY := FWFormStruct( 1, 'CYY', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructCYV := FWFormStruct( 1, 'CYV', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel,oModelCYQ,oModelCY9,oModelCYD,oModelCYP,oModelCYY,oModelCYV    
Local nI    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA100', /*bPreValidacao*/, { | oMdl | SFCA100POS ( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYQMASTER', /*cOwner*/, oStructCYQ, /*bPreValidacao*/, /*bPosValidacao*/ , /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CY9DETAIL', 'CYQMASTER', oStructCY9, /*bLinePre*/, { | oMdl | SFCA100aPS ( oMdl ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'CYPDETAIL', 'CYQMASTER', oStructCYP, /*bLinePre*/, { | oMdl | SFCA100bPS ( oMdl ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'CYDDETAIL', 'CYQMASTER', oStructCYD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'CYYDETAIL', 'CY9DETAIL', oStructCYY, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'CYVDETAIL', 'CYQMASTER', oStructCYV, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CY9DETAIL', { { 'CY9_FILIAL', 'xFilial( "CY9" )' }, { 'CY9_NRORPO', 'CYQ_NRORPO' } }, CY9->( IndexKey(1)) )
oModel:SetRelation( 'CYPDETAIL', { { 'CYP_FILIAL', 'xFilial( "CYP" )' }, { 'CYP_NRORPO', 'CYQ_NRORPO' } }, CYP->( IndexKey(1)) )
oModel:SetRelation( 'CYDDETAIL', { { 'CYD_FILIAL', 'xFilial( "CYD" )' }, { 'CYD_NRORPO', 'CYQ_NRORPO' } }, CYD->( IndexKey(1)))
oModel:SetRelation( 'CYYDETAIL', { { 'CYY_FILIAL', 'xFilial( "CYY" )' }, { 'CYY_NRORPO', 'CY9_NRORPO' }, { 'CYY_IDAT', 'CY9_IDAT' } }, CYY->( IndexKey(1)))
oModel:SetRelation( 'CYVDETAIL', { { 'CYV_FILIAL', 'xFilial( "CYV" )' }, { 'CYV_NRORPO', 'CYQ_NRORPO' } }, CYV->( IndexKey(1)))

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0007 )    //'Modelo de Dados da Ordem de Produção'

//Pega os Models
oModelCYQ := oModel:GetModel( 'CYQMASTER' )
oModelCY9 := oModel:GetModel( 'CY9DETAIL' )
oModelCYD := oModel:GetModel( 'CYDDETAIL' )
oModelCYP := oModel:GetModel( 'CYPDETAIL' )
oModelCYY := oModel:GetModel( 'CYYDETAIL' )
oModelCYV := oModel:GetModel( 'CYVDETAIL' )

// Liga o controle de nao repeticao de linha
oModelCY9:SetUniqueLine( { 'CY9_IDAT' } )

// Adiciona a descricao do Componente do Modelo de Dados
oModelCYQ:SetDescription( STR0008 )  //'Dados de Ordens'
oModelCY9:SetDescription( STR0009 )  //'Dados de Operações da Ordem '
oModelCYD:SetDescription( STR0010 )  //'Dados Pert da Ordem'
oModelCYP:SetDescription( STR0011 )  //'Dados das Reservas da Ordem'
oModelCYY:SetDescription( STR0023 )  //'Dados dos Split da Ordem'
oModelCYV:SetDescription( STR0034 ) // 'Apontamentos Realizados'

//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({"CYQ_FILIAL", "CYQ_NRORPO"})    

// Indica que é opcional ter dados informados na Grid
oModelCY9:SetOptional(.T.)  
oModelCYD:SetOptional(.T.)
oModelCYP:SetOptional(.T.)      
oModelCYY:SetOptional(.T.)      
oModelCYV:SetOptional(.T.) 

oModelCYV:SetNoInsertLine(.T.)

oStructCYV:SetProperty("CYV_HCRPBG", MODEL_FIELD_INIT, { || SFCXHRTOCEN(CYV->CYV_HRRPBG) } )     
oStructCYV:SetProperty("CYV_HCRPED", MODEL_FIELD_INIT, { || SFCXHRTOCEN(CYV->CYV_HRRPED) } )     
oStructCYV:SetProperty("CYV_HCBGSU", MODEL_FIELD_INIT, { || SFCXHRTOCEN(GETADVFVAL("CYX", "CYX_HRBGSP", XFILIAL("CYX")+CYV->CYV_NRSQRP, 4, "" )) } )
oStructCYV:SetProperty("CYV_HCEDSU", MODEL_FIELD_INIT, { || SFCXHRTOCEN(GETADVFVAL("CYX", "CYX_HREDSP", XFILIAL("CYX")+CYV->CYV_NRSQRP, 4, "" )) } )     
oStructCYV:SetProperty("CYV_HCRP"  , MODEL_FIELD_INIT, { || SFCXHRTOCEN(CYV->CYV_HRRP) } )     
oStructCYV:SetProperty("CYV_NMUSRP", MODEL_FIELD_INIT, { || USRRETNAME(CYV->CYV_CDUSRP) } )     
oStructCYV:SetProperty("CYV_NMUSOE", MODEL_FIELD_INIT, { || USRRETNAME(CYV->CYV_CDUSOE) } )

If IsInCallStack("SFCA100") .And. !IsInCallStack("SFCA100FIM")
	oModelCY9:SetNoInsertLine(.T.)
	oModelCYD:SetNoInsertLine(.T.)
	oModelCYP:SetNoInsertLine(.T.)
	oModelCYY:SetNoInsertLine(.T.)

	oModelCY9:SetNoDeletetLine(.T.)
	oModelCYD:SetNoDeletetLine(.T.)
	oModelCYP:SetNoDeletetLine(.T.)
	oModelCYY:SetNoDeletetLine(.T.)
	oModelCYV:SetNoDeletetLine(.T.)

	oModelCY9:SetNoUpdateLine(.T.)
	oModelCYD:SetNoUpdateLine(.T.)
	oModelCYP:SetNoUpdateLine(.T.)
	oModelCYY:SetNoUpdateLine(.T.)
	oModelCYV:SetNoUpdateLine(.T.)

	oModCYQStr := oModelCYQ:GetStruct()

	For nI := 1 To Len(oModCYQStr:aFields)
		If AllTrim(oModCYQStr:aFields[nI][3]) != "CYQ_TPRPOR"
			oModCYQStr:SetProperty(oModCYQStr:aFields[nI][3], MODEL_FIELD_WHEN, { || .F. } )
		EndIf
	Next

	oModel:SetVldActivate({ |oModel| AbreTela(oModel) })
EndIf

oModel:GetModel("CYPDETAIL"):SetUseOldGrid()     

Return oModel

//------------------------------------------------------------------
Static Function AbreTela(oModel)
	Local lRet := .T.
	
	If IsInCallStack("SFCA100") .And. oModel:GetOperation() == 4 .And. CYQ->CYQ_TPST != "1" .And. !IsInCallStack("SFCA100FIM")
		Help( ,, 'SFCA100', , STR0042, 1, 0)//"Somente ordens não iniciadas podem ser altedas."
		lRet := .F.
	EndIf                                                                                                                    
	
Return lRet
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA100' )
// Cria a estrutura a ser usada na View
Local oStructCYQ := FWFormStruct( 2, 'CYQ' )
Local oStructCY9 := FWFormStruct( 2, 'CY9' )
Local oStructCYD := FWFormStruct( 2, 'CYD' )
Local oStructCYP := FWFormStruct( 2, 'CYP' )
Local oStructCYY := FWFormStruct( 2, 'CYY', { |cCampo| !AllTrim( cCampo ) + "/" $ "CYY_HCDIRP/" } )
Local oStructCYV := FWFormStruct( 2, 'CYV' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYQ', oStructCYQ, 'CYQMASTER' )                

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CY9', oStructCY9, 'CY9DETAIL' )   
oView:AddGrid(  'VIEW_CYD', oStructCYD, 'CYDDETAIL' ) 
oView:AddGrid(  'VIEW_CYP', oStructCYP, 'CYPDETAIL' )
oView:AddGrid(  'VIEW_CYY', oStructCYY, 'CYYDETAIL' )
oView:AddGrid(  'VIEW_CYV', oStructCYV, 'CYVDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 50 )
oView:CreateHorizontalBox( 'INFERIOR', 50 )

// Cria Folder na view
oView:CreateFolder( 'PASTAS', 'INFERIOR' )  

// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', STR0012 )  // 'Operação'
oView:AddSheet( 'PASTAS', 'ABA02', STR0013 )  // 'Rede Pert'
oView:AddSheet( 'PASTAS', 'ABA03', STR0014 )  // 'Reserva'
oView:AddSheet( 'PASTAS', 'ABA05', STR0035 )  // 'Apontamentos'

oView:CreateHorizontalBox( "INFERIOROPERACAO",50,,,"PASTAS","ABA01" )
oView:CreateHorizontalBox( "INFERIORREDEPERT", 100,,,"PASTAS","ABA02" )
oView:CreateHorizontalBox( "INFERIORRESERVA", 100,,,"PASTAS","ABA03" )
oView:CreateHorizontalBox( "INFERIORSPLIT", 50,,,"PASTAS","ABA01" )
oView:CreateHorizontalBox( "INFERIORREP", 100,,,"PASTAS","ABA05" )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYQ', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CY9', 'INFERIOROPERACAO' )
oView:SetOwnerView( 'VIEW_CYD', 'INFERIORREDEPERT' )  
oView:SetOwnerView( 'VIEW_CYP', 'INFERIORRESERVA' )  
oView:SetOwnerView( 'VIEW_CYY', "INFERIORSPLIT" )  
oView:SetOwnerView( 'VIEW_CYV', "INFERIORREP" )  

oStructCYQ:AddGroup( 'Grupo01', STR0036, '', 2 ) // 'Ordem de Produção'
oStructCYQ:AddGroup( 'Grupo02', STR0037, '', 2 ) // 'Entregas'
oStructCYQ:AddGroup( 'Grupo03', STR0038, '', 2 ) // 'Produção'
oStructCYQ:AddGroup( 'Grupo04', STR0039, '', 2 ) // 'Custos'

oStructCYQ:SetProperty( 'CYQ_NRORPO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_CDAC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_DSAC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_QTOR'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_CDUN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_TPORPO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_TPSTOR', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_CDLIPO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_DSLI'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_CDRE'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_TPRPOR', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_TPAL'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_CDES'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_CDDP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_CDUSPL', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStructCYQ:SetProperty( 'CYQ_NMUSPL', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 

oStructCYQ:SetProperty( 'CYQ_DTBGAT', MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_DTEDAT', MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_NMSIFB', MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_CDGRFB', MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_CDPD'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_NRSQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_CDUNNG', MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_DTIMC' , MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_HRIMC' , MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_DTFMT' , MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_HRFMT' , MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_CDTBMT', MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 
oStructCYQ:SetProperty( 'CYQ_CDRT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 

oStructCYQ:SetProperty( 'CYQ_QTORRP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStructCYQ:SetProperty( 'CYQ_QTORAP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStructCYQ:SetProperty( 'CYQ_QTORRT', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 
oStructCYQ:SetProperty( 'CYQ_QTORRF', MVC_VIEW_GROUP_NUMBER, 'Grupo03' ) 

oStructCYQ:SetProperty( 'CYQ_TPGGF' , MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 
oStructCYQ:SetProperty( 'CYQ_TPMOD' , MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 

IF SFCIntegra() == 2
	oStructCYQ:SetProperty( 'CYQ_TPMPC' , MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 	
	oStructCYQ:SetProperty( 'CYQ_TPMBCS', MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 
	oStructCYQ:SetProperty( 'CYQ_TPMPCS', MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 
	oStructCYQ:SetProperty( 'CYQ_TPGFCS', MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 
	oStructCYQ:SetProperty( 'CYQ_TPMODC', MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 
	oStructCYQ:SetProperty( 'CYQ_TPGGFC', MVC_VIEW_GROUP_NUMBER, 'Grupo04' ) 	
Endif

//Remove o campo repetido em tela
oStructCY9:RemoveField("CY9_NRORPO")
oStructCYP:RemoveField("CYP_NRORPO")
oStructCYD:RemoveField("CYD_NRORPO") 
oStructCYY:RemoveField("CYY_NRORPO")
oStructCYY:RemoveField("CYY_IDAT")
oStructCYV:RemoveField("CYV_NRORPO")

oStructCYQ:RemoveField("CYQ_CDFA")
oStructCYQ:RemoveField("CYQ_CDGE")
oStructCYQ:RemoveField("CYQ_DSFA")
oStructCYQ:RemoveField("CYQ_DSGE")
oStructCYQ:RemoveField("CYQ_VLPSBR")
oStructCYQ:RemoveField("CYQ_VLPSLQ")

If GetMv('MV_SFCTPRE') == '2'
	oStructCYV:RemoveField("CYV_HRRPBG")
	oStructCYV:RemoveField("CYV_HRRPED")
	oStructCYV:RemoveField("CYV_HRBGSU")
	oStructCYV:RemoveField("CYV_HREDSU")
	oStructCYV:RemoveField("CYV_HRRP")
Else
	oStructCYV:RemoveField("CYV_HCRPBG")
	oStructCYV:RemoveField("CYV_HCRPED")
	oStructCYV:RemoveField("CYV_HCBGSU")
	oStructCYV:RemoveField("CYV_HCEDSU")
	oStructCYV:RemoveField("CYV_HCRP")
Endif    

IF SFCIntegra() == 1
	oStructCY9:RemoveField("CY9_CDACRF")
	oStructCY9:RemoveField("CY9_CDATAV")
	oStructCY9:RemoveField("CY9_CDATVF")
	oStructCY9:RemoveField("CY9_CDMOD")
	oStructCY9:RemoveField("CY9_DTFMT")
	oStructCY9:RemoveField("CY9_DTIMC")
	oStructCY9:RemoveField("CY9_HRFMT")
	oStructCY9:RemoveField("CY9_HRIMC")
	oStructCY9:RemoveField("CY9_QTLOMI")
	oStructCY9:RemoveField("CY9_QTLOMU")
	oStructCY9:RemoveField("CY9_QTLOPA")
	oStructCY9:RemoveField("CY9_QTTERC")
	oStructCY9:RemoveField("CY9_VLRFAC")
	
	oStructCYQ:RemoveField("CYQ_CDACRF")
	oStructCYQ:RemoveField("CYQ_CDACAX")
	oStructCYQ:RemoveField("CYQ_CDGRFB")
	oStructCYQ:RemoveField("CYQ_CDLIPO")
	oStructCYQ:RemoveField("CYQ_CDLO")
	oStructCYQ:RemoveField("CYQ_CDPD")
	oStructCYQ:RemoveField("CYQ_CDPDOR")
	oStructCYQ:RemoveField("CYQ_CDRT")
	oStructCYQ:RemoveField("CYQ_CDTBMT")
	oStructCYQ:RemoveField("CYQ_CDUNNG")
	oStructCYQ:RemoveField("CYQ_CDUSPL")
	oStructCYQ:RemoveField("CYQ_DTBGAT")
	oStructCYQ:RemoveField("CYQ_DTEDAT")
	oStructCYQ:RemoveField("CYQ_DTFMT")
	oStructCYQ:RemoveField("CYQ_DTIMC")
	oStructCYQ:RemoveField("CYQ_DTLBOR")
	oStructCYQ:RemoveField("CYQ_NMSIFB")
	oStructCYQ:RemoveField("CYQ_HRBGOR")
	oStructCYQ:RemoveField("CYQ_HREDOR")
	oStructCYQ:RemoveField("CYQ_HRFMT")
	oStructCYQ:RemoveField("CYQ_HRIMC")
	oStructCYQ:RemoveField("CYQ_LGACCP")
	oStructCYQ:RemoveField("CYQ_LGSTOR")
	oStructCYQ:RemoveField("CYQ_DSLI")
	oStructCYQ:RemoveField("CYQ_NMUSPL")
	oStructCYQ:RemoveField("CYQ_NRSQ")
	oStructCYQ:RemoveField("CYQ_NRULSQ")
	oStructCYQ:RemoveField("CYQ_QTORBG")
	oStructCYQ:RemoveField("CYQ_QTORED")
	oStructCYQ:RemoveField("CYQ_QTTELB")
	oStructCYQ:RemoveField("CYQ_CDRE")
	oStructCYQ:RemoveField("CYQ_TPAL")
	oStructCYQ:RemoveField("CYQ_TPGFCS")
	oStructCYQ:RemoveField("CYQ_TPGGFC")
	oStructCYQ:RemoveField("CYQ_TPMBCS")
	oStructCYQ:RemoveField("CYQ_TPMODC")
	oStructCYQ:RemoveField("CYQ_TPMPC")
	oStructCYQ:RemoveField("CYQ_TPMPCS")
	oStructCYQ:RemoveField("CYQ_TPORPO")
	oStructCYQ:RemoveField("CYQ_TPRF")
	oStructCYQ:RemoveField("CYQ_TPSTOR")
	oStructCYQ:RemoveField("CYQ_VLPSBR")
	oStructCYQ:RemoveField("CYQ_VLPSLQ")
	oStructCYQ:RemoveField("CYQ_VLRFAC")
	
	oStructCYP:RemoveField("CYP_CDLC")
	oStructCYP:RemoveField("CYP_CDLO")
	oStructCYP:RemoveField("CYP_CDRE")
	oStructCYP:RemoveField("CYP_CDTBMT")
	oStructCYP:RemoveField("CYP_NRSQMT")
Endif

oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_LGRPEO', MVC_VIEW_ORDEM, '01' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_NRSQRP', MVC_VIEW_ORDEM, '02' )

Return oView 

//-------------------------------------------------------------------
// Legenda
//-------------------------------------------------------------------
Function SFCA100LEG()

// Cria a legenda que identifica a estrutura
oLegend := FWLegend():New()

// Adiciona descrição para cada legenda
oLegend:Add( { || }, 'BR_VERDE'   , STR0030 ) // 'Não Iniciada'
oLegend:Add( { || }, 'BR_LARANJA' , STR0031 ) // 'Iniciada'
oLegend:Add( { || }, 'BR_VERMELHO', STR0032 ) // 'Finalizada'

// Ativa a Legenda
oLegend:Activate()

// Exibe a Tela de Legendas
oLegend:View()

Return Nil

//-------------------------------------------------------------------
// Validações de operações
//-------------------------------------------------------------------
Static Function SFCA100aPS (oModel)
	Local lRet		:= .T.
	Local nOpc		:= oModel:GetOperation()
	Local aArea		:= GetArea()
	Local aAreaCYI	:= CYI->(GetArea())
	Local nI		:= 0
	Local nIDAT		:= 0 
	Local aCloned	:= AClone(oModel:aDataModel)

	If nOpc == 3 .Or. nOpc == 4
		If Empty(oModel:GetValue('CY9_CDCETR'))
			SFCMsgErro(STR0019, "SFCA100") //"Centro de Trabalho deve ser informado na Operação "
		   	lRet := .F.
		EndIf

		If lRet	
			If Empty(oModel:GetValue('CY9_TPTE'))
				dbSelectArea("CYI")
				CYI->(dbSetOrder(1))	
				If CYI->(dbSeek(xFilial('CYI')+oModel:GetValue('CY9_CDCETR')))  
					oModel:SetValue('CY9_TPTE',CYI->CYI_TPTEAT)
				EndIf
			EndIf
		EndIf

		If Empty(oModel:GetValue('CY9_IDAT'))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ordena o acols para pegar o maior ID da reserva ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//Verifica em que posição do grid está a coluna CY9_IDAT
			For nI := 1 To Len(oModel:aHeader)
				If oModel:aHeader[nI][2] == "CY9_IDAT"
					nIDAT := nI
					Exit
				End
			Next

			aSort(aCloned,,,{|x,y| x[1][1][nIDAT] > y[1][1][nIDAT]})

			If Empty(aCloned[1][1][1][nIDAT])
				aCloned[1][1][1][nIDAT]:=PadL("1",TamSX3("CY9_IDAT")[1],"0")
			EndIf

			If Empty(oModel:GetValue('CY9_IDAT'))
				oModel:SetValue('CY9_IDAT',PadL(AllTrim(Str(Val(aCloned[1][1][1][nIDAT]) + 1)),TamSX3("CY9_IDAT")[1],"0"))
			EndIf

		EndIf
	Endif

	RestArea(aAreaCYI)
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
// Validações de reservas
//-------------------------------------------------------------------
Static Function SFCA100bPS (oModel)
	Local lRet		:= .T.
	Local nOpc		:= oModel:GetOperation()
	Local nI		:= 0        
	Local nIDMTOR	:= 0        	
	Local aCloned	:= {}

	If !__lAutomacao
		aCloned	:= AClone(oModel:aDataModel)
	EndIf

	If nOpc == 3 .Or. nOpc == 4

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ordena o acols para pegar o maior ID da reserva ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//Verifica em que posição do grid está a coluna CYP_IDMTOR
		If !__lAutomacao
			For nI := 1 To Len(oModel:aHeader)
				If oModel:aHeader[nI][2] == "CYP_IDMTOR"
					nIDMTOR := nI
					Exit
				End
			Next
		
			aSort(aCloned,,,{|x,y| x[1][1][nIDMTOR] > y[1][1][nIDMTOR]})
				
			If Empty(aCloned[1][1][1][nIDMTOR]) 
				aCloned[1][1][1][nIDMTOR]:="0000000001"
			EndIf
		
			If Empty(oModel:GetValue("CYP_IDMTOR"))
				oModel:SetValue("CYP_IDMTOR",Soma1(Alltrim(aCloned[1][1][1][nIDMTOR])))
			EndIf
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
// Validações
//-------------------------------------------------------------------
Static Function SFCA100POS (oModel)
Local lRet := .T.
Local nI   := 0 
Local nI1  := 0
Local nOpc := oModel:GetOperation()
Local oModelCYY, oModelCYV
Local oModelCYQ := oModel:GetModel('CYQMASTER')
Local oModelCY9 := oModel:GetModel('CY9DETAIL')
Local oModelCYD := oModel:GetModel('CYDDETAIL')
Local aArea     := GetArea()
Local aAreaCYQ  := CYQ->(GetArea())
Local aAreaCYY  := CYY->(GetArea())
Local aAreaCYV  := CYV->(GetArea())
Local aAreaCYI  := CYI->(GetArea())
Local aAreaCYS  := CYS->(GetArea())
Local aAreaCZ5  := CZ5->(GetArea())
Local lErroSFC 

if nOpc == 3            			
	dbSelectArea("CYQ")
	CYQ->(dbSetOrder(1))	
	if CYQ->(dbSeek(xFilial('CYQ')+oModel:GetValue('CYQMASTER','CYQ_NRORPO'))) 
		SFCMsgErro(STR0015, "SFCA100") //"Ordem de Produção já existe com a chave informada"
		lRet := .F.
	Endif

	If SFCIntegra() == 1
		oModel:SetValue('CYQMASTER','CYQ_CDES', xFilial('SC2') )
	EndIf
	
ElseIf nOpc == 4

	if !CYQ->(dbSeek(xFilial('CYQ')+oModel:GetValue('CYQMASTER','CYQ_NRORPO'))) 
		SFCMsgErro(STR0040, "SFCA100") //"A ordem de produção não existe no módulo chão de fábrica(SIGASFC) e portanto não poderá ser alterada."
		lRet := .F.
	Endif
    
	If lRet .And. !IsInCallStack("SFCA100") .And. SFCIntegra() == 1 .AND. oModel:GetValue('CYQMASTER','CYQ_TPSTOR') != '7'
		if (oModelCYD:GetQtdLine() > 1 .OR. (oModelCYD:GetQtdLine() == 1 .AND. oModelCYD:IsUpdated())) .AND. !oModelCYD:IsDeleted()
			For nI := 1 to oModelCYD:GetQtdLine()
				oModelCYD:GoLine(nI)
				
				if !oModelCYD:IsDeleted() .And. Empty(oModelCYD:GetValue('CYD_IDATPV'))
					
					For nI1 := 1 to oModelCY9:GetQtdLine()
						oModelCY9:GoLine(nI1)
						If !oModelCY9:IsDeleted()
							If oModelCY9:GetValue('CY9_CDAT') = oModelCYD:GetValue('CYD_CDAT')
								oModelCYD:SetValue('CYD_IDATNX',oModelCY9:GetValue('CY9_IDAT'))
								Exit
							EndIf
						EndIf				
					Next
					
					For nI1 := 1 to oModelCY9:GetQtdLine()
						oModelCY9:GoLine(nI1)
						If !oModelCY9:IsDeleted()
							If oModelCY9:GetValue('CY9_CDAT') = oModelCYD:GetValue('CYD_CDATPV')
								oModelCYD:SetValue('CYD_IDATPV',oModelCY9:GetValue('CY9_IDAT'))
								Exit
							EndIf
						EndIf				
					Next
				Endif
			Next
		Endif
		
		For nI := 1 to oModelCY9:GetQtdLine()
			oModelCY9:GoLine(nI)
			if !oModelCY9:IsDeleted()
				oModelCY9:SetValue('CY9_LGATBG',.T.)	
				exit
			Endif
		Next
		
		oModelCY9:GoLine(oModelCY9:GetQtdLine())
		if !oModelCY9:IsDeleted()
			oModelCY9:SetValue('CY9_LGATED',.T.)
		Endif
	Endif	
Endif

if nOpc == 3 .OR. nOpc == 4

	If oModel:GetValue('CYQMASTER','CYQ_TPRPOR') == "1"
	
		lErroSFC := Type("_nHndSFC") != "U" .And. Type("_lErrSFC") != "U"

		For nI := 1 to oModelCY9:GetQtdLine()
			oModelCY9:GoLine(nI)
			if !oModelCY9:IsDeleted() .And. oModelCY9:GetValue('CY9_TPAT') == '1' .And. oModelCY9:GetValue('CY9_LGATED') .And. !oModelCY9:GetValue('CY9_LGCERP')

				If IsInCallStack("SFCA100")
					SFCMsgErro(STR0044, "SFCA100") //"A ultima operação da ordem não é reportada. E portanto o apontamento por Ordem é inviável."
					lRet := .F.
				Else

					oModel:SetValue('CYQMASTER','CYQ_TPRPOR',"2")

					If lErroSFC
						FWrite(_nHndSFC, CYQ->CYQ_NRORPO+NEWLINE)
						_lErrSFC := .T.
					EndIf

				EndIf

			EndIf
		Next

	EndIf

	// Quando for liberada ordem no Protheus, deverá criar Splits
	if lRet .AND. ;
		SFCIntegra() == 1 .AND. ;
		oModel:GetValue('CYQMASTER','CYQ_TPSTOR') == '2' .And. ;
		(IsInCallStack('MATA650') .Or. ;
		 IsInCallStack('GeraOperac') .Or. ;
		 IsInCallStack('A650IntSFC') .Or. ;
		 IsInCallStack('OPSFCOper')) // GeraOperac - Alteração de operações no MATA632
		
		// Elimina Splits para recriar
		For nI := 1 to oModelCY9:GetQtdLine()
			oModelCY9:GoLine(nI)
			
			dbSelectArea('CYY')
			CYY->(dbSetOrder(1))
			If CYY->(dbSeek(xFilial('CYY')+oModel:GetValue('CYQMASTER','CYQ_NRORPO')+oModelCY9:GetValue('CY9_IDAT')))
				RecLock('CYY',.F.)
				CYY->(dbDelete())
				MsUnLock()
			Endif		
		Next
		
		For nI := 1 to oModelCY9:GetQtdLine()
			oModelCY9:GoLine(nI)
			
			if !oModelCY9:IsDeleted() .AND. oModelCY9:GetValue('CY9_TPAT') == '1'
			
				oModelCYY := FWLoadModel( 'SFCA315' )
				oModelCYY:SetOperation( 3 )
				oModelCYY:Activate()

				// Atualiza informações de Split diretamente no model do CYY
				SFCA315GER(.F.,oModel:GetValue('CYQMASTER','CYQ_NRORPO'), oModelCY9:GetValue('CY9_IDAT'), ,oModelCY9,,,oModelCYY)

				oModelCYY:VldData()
				oModelCYY:CommitData()
				oModelCYY:DeActivate()
				oModelCYY:Destroy()
			Endif
		Next		
	Endif
Else
	dbSelectArea('CYV')
	CYV->(dbSetOrder(2))
	IF CYV->(dbSeek(xFilial('CYV')+oModel:GetValue('CYQMASTER','CYQ_NRORPO')))
		While CYV->(!EOF()) .AND. CYV->CYV_NRORPO == oModel:GetValue('CYQMASTER','CYQ_NRORPO')
		
			if CYV->CYV_LGRPEO == .F.
				SFCMsgErro(STR0020, "SFCA100") //"Ordem de Produção não pode ser eliminada pois existem apontamentos de produção"
				lRet := .F.
				Exit
			End			
			CYV->(dbSkip())
		End
	Endif
	
	if lRet
		// Verificar se a ordem foi utilizada em cálculo de meta
		dbSelectArea('CZ5')
		CZ5->(dbSetOrder(8))
		IF CZ5->(dbSeek(xFilial('CZ5')+oModel:GetValue('CYQMASTER','CYQ_NRORPO')))
			SFCMsgErro(STR0021, "SFCA100") //"Ordem de Produção está sendo usada em Cálculo de Meta"
		Else
			// Verificar se a ordem foi utilizada em componente da meta
			dbSelectArea('CYS')
			CYS->(dbSetOrder(3))
			IF CYS->(dbSeek(xFilial('CYS')+oModel:GetValue('CYQMASTER','CYQ_NRORPO')))
				SFCMsgErro(STR0022, "SFCA100") //"Ordem de Produção está sendo usada em Meta de Produção"
			Endif
		Endif		
	Endif

	if lRet

		dbSelectArea('CYV')
		CYV->(dbSetOrder(2))
		IF CYV->(dbSeek(xFilial('CYV')+oModel:GetValue('CYQMASTER','CYQ_NRORPO')))
			While CYV->(!EOF()) .AND. CYV->CYV_NRORPO == oModel:GetValue('CYQMASTER','CYQ_NRORPO')
			
				oModelCYV := FWLoadModel('SFCA313')
				oModelCYV:SetOperation(5)
				oModelCYV:Activate()
				
				if oModelCYV:VldData()
					oModelCYV:CommitData()
				Else
					aErro := oModelCYV:GetErrorMessage()
					SFCMsgErro(aErro[6],"SFCA100")
					lRet := .F.
				Endif
				oModelCYV:DeActivate()
			
				CYV->(dbSkip())
			End
		Endif
	Endif
Endif

RestArea(aAreaCYY)
RestArea(aAreaCYV)
RestArea(aAreaCYQ)
RestArea(aAreaCYI)
RestArea(aAreaCYS)
RestArea(aAreaCZ5)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// Verifica se só existe uma Máquina para o Centro de Trabalho
//-------------------------------------------------------------------
Function SFCA100MAQ(cCDCETR)
Local cMaquina := Space(TamSX3('CYB_CDMQ')[1])
Local nCont    := 0

dbSelectArea('CYB')
CYB->(dbSetOrder(2))
CYB->(dbGoTop())
IF CYB->(dbSeek(xFilial('CYB')+cCDCETR))
	While CYB->(!EOF()) .AND. CYB->CYB_CDCETR == cCDCETR
		nCont++
		
		if nCont > 1
			Exit
		Endif

		CYB->(dbSkip())
	End
Endif

if nCont == 1
	CYB->(dbSeek(xFilial('CYB')+cCDCETR))
	
	cMaquina := CYB->CYB_CDMQ
Endif

Return cMaquina

//-------------------------------------------------------------------
// Finalizar ordem de produção
//-------------------------------------------------------------------
Function SFCA100FIM(lAuto)
Local lRet    := .T.
Local nI      := 0
Local nTipoHr := 0
Local oModelCYQ, oModelCYY
Local aArea    := GetArea()
Local aAreaCYY := CYY->(GetArea()) 
Local aAreaCYV := CYV->(GetArea())
Default lAuto := .F.

If SFCIntegra() == 1
	Pergunte("MTA680",.F.)
	nTipoHr := MV_PAR03 //-- 1-Normal ; 2-Centesimal
	
	If nTipoHr != 1 .AND. nTipoHr != 2
		SFCMsgErro(STR0028, "SFCA100") // "Hora centesimal está com valor inválido"
		lRet := .F.
	Endif
Endif 

IF lRet

	Begin Transaction

		oModelCYQ := FWLoadModel( 'SFCA100' )
		oModelCYQ:Activate()
		
		If oModelCYQ:GetModel('CYQMASTER'):GetValue('CYQ_TPSTOR') == '7'
			SFCMsgErro(STR0027, "SFCA314") // "Ordem de Produção já finalizada!"
			lRet := .F.
		EndIf

		if lRet .AND. (lAuto .Or. MSGYESNO(STR0016 + ALLTRIM(CYQ->CYQ_NRORPO) + '? ')) //'Deseja finalizar a ordem de produção '

			dbSelectArea('CYV')
			CYV->(dbSetOrder(2))
			CYV->(dbGoTop())
			IF CYV->(dbSeek(xFilial('CYV')+CYQ->CYQ_NRORPO))

				IF SFCIntegra() == 1
					lRet := AUTO681(CYQ->CYQ_NRORPO)
				Endif
				
				if lRet

					oModelCYQ := FWLoadModel( 'SFCA100' )
					oModelCYQ:SetOperation( 4 )	
					oModelCYQ:Activate()
					
					oModelCYQ:SetValue('CYQMASTER', 'CYQ_TPST', '5')
					oModelCYQ:SetValue('CYQMASTER', 'CYQ_TPSTOR', '7')
						
					For nI := 1 To oModelCYQ:GetModel('CY9DETAIL'):Length()
						oModelCYQ:GetModel('CY9DETAIL'):GoLine(nI)
						oModelCYQ:SetValue('CY9DETAIL','CY9_TPST','3')
					Next
					
					if oModelCYQ:VldData()
						oModelCYQ:CommitData()
					Else
						aErro := oModelCYQ:GetErrorMessage()
						SFCMsgErro(aErro[6], "SFCA314")
						lRet := .F.
					Endif
					oModelCYQ:DeActivate()
					
					if lRet

						dbSelectArea('CYY')
						CYY->(dbSetOrder(1))
						CYY->(dbGoTop())
						CYY->(dbSeek(xFilial('CYY')+CYQ->CYQ_NRORPO))
						
						While CYY->(!EOF()) .AND. CYY->CYY_NRORPO == CYQ->CYQ_NRORPO
							oModelCYY := FWLoadModel( 'SFCA315' )
							oModelCYY:SetOperation( 4 )
							oModelCYY:Activate()
							
							oModelCYY:SetValue('CYYMASTER','CYY_LGQOED',.T.) 
							oModelCYY:SetValue('CYYMASTER','CYY_TPSTAT','5')
							
							if oModelCYY:VldData()
								oModelCYY:CommitData()
							Else
								aErro := oModelCYY:GetErrorMessage()
								SFCMsgErro(aErro[6], "SFCA314")
								lRet := .F.
							Endif
							oModelCYY:DeActivate()
							
							CYY->(dbSkip())
						End
					Endif 
				Endif
			Else
				SFCMsgErro( STR0029 + CYQ->CYQ_NRORPO, "SFCA100")  //"Não foram encontrados registros de apontamento para a ordem de produção "
				lRet := .F.
			Endif
		Endif

		If !lRet
			DisarmTransaction()
		EndIf

	End Transaction
Endif

RestArea(aAreaCYY)
RestArea(aAreaCYV)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// Reabertura de ordem de produção
//-------------------------------------------------------------------
Function SFCA100REA()
Local lRet  := .T.
Local nI    := 0
Local aErro := {}
Local oModelCYQ

If !__lAutomacao
	if MSGYESNO(STR0026 + ALLTRIM(CYQ->CYQ_NRORPO) + '? ') //'Deseja reabrir a ordem de produção '

		oModelCYQ := FWLoadModel( 'SFCA100' )
		oModelCYQ:SetOperation( 4 )	
		oModelCYQ:Activate()
		
		oModelCYQ:SetValue('CYQMASTER', 'CYQ_TPST', '3')
		oModelCYQ:SetValue('CYQMASTER', 'CYQ_TPSTOR', '6')
			
		For nI := 1 To oModelCYQ:GetModel('CY9DETAIL'):Length()
			oModelCYQ:GetModel('CY9DETAIL'):GoLine(nI)
			oModelCYQ:SetValue('CY9DETAIL','CY9_TPST','2')
		Next
		
		if oModelCYQ:VldData()
			oModelCYQ:CommitData()
		Else
			aErro := oModelCYQ:GetErrorMessage()			
			SFCMsgErro(aErro[6], "SFCA314")
			lRet := .F.
		Endif
		oModelCYQ:DeActivate()
	Endif
EndIf

Return lRet

//-------------------------------------------------------------------
// Atualiza informação de data de início e fim da ordem de produção
// e empenhos
//-------------------------------------------------------------------
Function SFCA100DAT(cNRORPO, lAtuEmp, dInicio, dFim)
Local lRet     := .T.
Local aArea    := GetArea()

dbSelectArea('CYQ')
CYQ->(dbSetOrder(1))
IF CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

	RecLock('CYQ',.F.)
	CYQ->CYQ_DTBGOR := dInicio
	CYQ->CYQ_DTEDOR := dFim
	CYQ->(MsUnLock())
	
	if lAtuEmp
		dbSelectArea('CYP')
		CYP->(dbSetOrder(1))
		if CYP->(dbSeek(xFilial('CYP')+cNRORPO))
			RecLock('CYP',.F.)
			
			CYP->CYP_DTMT := dInicio
			
			CYP->(MsUnLock())
		Endif
	Endif
Else
	lRet := .F.
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// Atualiza informações de alocação na operação e split 
// durante a execução do carga máquina
//
// array: 1-Maquina, 
//        2-Data Ini, 
//        3-Hora Ini, 
//        4-Data Fim, 
//        5-Hora Fim, 
//        6-Quantidade, 
//        7-Setup
//
// * Não foram utilizados os models para não deixar o processo lento
//-------------------------------------------------------------------
Function SFCA100ALO(cNRORPO, cCDAT, aAloc)
Local lRet    := .T.
Local nJ      := 0
Local cIDAT   := ''
Local cIDATQO := ''
Local aArea   := GetArea()
Local nTempo  := 0

cNRORPO := PadR(cNRORPO,tamSX3('CY9_NRORPO')[1])
cIDAT   := Posicione('CY9',5,xFilial('CY9')+cNRORPO+cCDAT,'CY9_IDAT')

dbSelectArea('CYQ')
CYQ->(dbSetOrder(1))
If CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

	dbSelectArea('CY9')
	CY9->(dbSetOrder(1))
	IF CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT))

		// Apaga todos os splits da operação que foi alocada
		dbSelectArea('CYY')
		CYY->(dbSetOrder(1))
		if CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT))
			While CYY->(!EOF()) .AND. CYY->CYY_NRORPO == cNRORPO .AND. CYY->CYY_IDAT == cIDAT
				RecLock('CYY',.F.)
				CYY->(dbDelete())
				MsUnLock()
			
				CYY->(dbSkip())
			End
		Endif
	
		RecLock('CYY',.T.)
		
		dbSelectArea('CY9')
		CY9->(dbSetOrder(1))
		if CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT))
		
			dbSelectArea('CYI')
			CYI->(dbSetOrder(1))
			CYI->(dbSeek(xFilial('CYI')+CY9->CY9_CDCETR))
		
			CYY->CYY_FILIAL := xFilial('CYY')
			CYY->CYY_NRORPO := cNRORPO
			CYY->CYY_IDAT   := cIDAT
			CYY->CYY_IDATQO := ALLTRIM(SFCA315NR(xFilial('CYY'),cNRORPO,cIDAT))
			CYY->CYY_CDCETR := CY9->CY9_CDCETR
			CYY->CYY_CDAC   := CY9->CY9_CDAC
			CYY->CYY_TPSTAT := '3'
			CYY->CYY_QTAT   := CY9->CY9_QTAT
			CYY->CYY_DTBGPL := CYQ->CYQ_DTBGOR
			CYY->CYY_HRBGPL := '00:00:00'
			CYY->CYY_DTEDPL := CYQ->CYQ_DTEDOR
			CYY->CYY_HREDPL := '23:59:59'
			CYY->CYY_QTPASU := CY9->CY9_QTTESU * 3600
			CYY->CYY_QTPAAT := CY9->CY9_QTTEMQ * 3600
			CYY->CYY_QTPAMQ := CY9->CY9_QTTEMQ * 3600
			CYY->CYY_QTPAOE := CY9->CY9_QTTERC * 3600
			CYY->CYY_DTBGPL := CYQ->CYQ_DTBGOR
			CYY->CYY_HRBGPL := '00:00:00'
			CYY->CYY_DTEDPL := CYQ->CYQ_DTEDOR
			CYY->CYY_HREDPL := '23:59:59'
			CYY->CYY_CDMQ   := SFCA100MAQ(CYI->CYI_CDCETR)
			CYY->CYY_QTCG   := CYI->CYI_QTCG
		Endif
		
		MsUnLock()
		
		cIDATQO := CYY->CYY_IDATQO		
	
		// Mais de uma máquina alocada para uma operação
		IF Len(aAloc) > 1
			// Dividindo o split
			For nJ := 1 to Len(aAloc) - 1
				SFCA315D(cNRORPO, cIDAT, PadL(ALLTRIM(STR(nJ)),TamSX3("CYY_IDATQO")[1],"0"), .F., aAloc[nJ][6])
			Next
			
			For nJ := 1 to Len(aAloc)
			
				dbSelectArea('CYY')
				CYY->(dbSetOrder(1))
				if CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+PadL(ALLTRIM(STR(nJ)),TamSX3("CYY_IDATQO")[1],"0")))
					RecLock('CYY',.F.)
					
					CYY->CYY_CDMQ := aAloc[nJ][1]
					CYY->CYY_QTCG := Posicione('CYI',1,xFilial('CYI')+CYY->CYY_CDCETR,'CYI_QTCG')
					
					// Possui Setup
					if aAloc[nJ][7] > 0
						nTempo := SFCXHourToSeg(alltrim(Bit2Tempo(aAloc[nJ][7], .T.)))
						
						CYY->CYY_DTIMCS := aAloc[nJ][2]
						CYY->CYY_HRIMCS := aAloc[nJ][3] + ':00'
						CYY->CYY_DTIMTS := aAloc[nJ][2]
						CYY->CYY_HRIMTS := aAloc[nJ][3] + ':00'
					
						CYY->CYY_QTPASU := nTempo
						CYY->CYY_DTIMC  := aAloc[nJ][2]
						CYY->CYY_HRIMC  := SFCXSegToHour(SFCXHourToSeg(aAloc[nJ][3]) + nTempo)
						CYY->CYY_DTIMT  := aAloc[nJ][2]
						CYY->CYY_HRIMT  := SFCXSegToHour(SFCXHourToSeg(aAloc[nJ][3]) + nTempo)
						CYY->CYY_DTFMC  := aAloc[nJ][4]
						CYY->CYY_HRFMC  := aAloc[nJ][5] + ':00'
						CYY->CYY_DTFMT  := aAloc[nJ][4]
						CYY->CYY_HRFMT  := aAloc[nJ][5] + ':00'
					Else
						CYY->CYY_DTIMC  := aAloc[nJ][2]
						CYY->CYY_HRIMC  := aAloc[nJ][3] + ':00'
						CYY->CYY_DTIMT  := aAloc[nJ][2]
						CYY->CYY_HRIMT  := aAloc[nJ][3] + ':00'
						CYY->CYY_DTFMC  := aAloc[nJ][4]
						CYY->CYY_HRFMC  := aAloc[nJ][5] + ':00'
						CYY->CYY_DTFMT  := aAloc[nJ][4]
						CYY->CYY_HRFMT  := aAloc[nJ][5] + ':00'
					Endif
					
					CYY->CYY_LGCGMQ := .T.
					
					CYY->(MsUnLock())
				Endif
			Next
			
			dbSelectArea('SHY')
			SHY->(dbSetOrder(1))
			if SHY->(dbSeek(xFilial('SHY')+PadR(CY9->CY9_NRORPO,TamSX3('HY_OP')[1])+PadR(CY9->CY9_CDRT,TamSX3('HY_ROTEIRO')[1])+PadR(CY9->CY9_CDAT,TamSX3('HY_OPERAC')[1])))
			
				RecLock('SHY',.F.)
				
				cData := DTOS(aAloc[1][2])
				
				SHY->HY_DATAINI := Substr(cData,1,4) + '-' + Substr(cData, 5,2) + '-' + Substr(cData,7,2)
				SHY->HY_HORAINI := aAloc[1][3] + ':00'
				
				cData := DTOS(aAloc[nJ - 1][4])
				
				SHY->HY_DATAFIM := Substr(cData,1,4) + '-' + Substr(cData, 5,2) + '-' + Substr(cData,7,2)
				SHY->HY_HORAFIM := aAloc[nJ - 1][5] + ':00'
				
				SHY->(MsUnLock())
			Endif
										
			RecLock('CY9',.F.)
			
			CY9->CY9_DTIMC := aAloc[1][2]
			CY9->CY9_HRIMC := aAloc[1][3] + ':00'
			CY9->CY9_DTFMT := aAloc[nJ - 1][4]
			CY9->CY9_HRFMT := aAloc[nJ - 1][5] + ':00'
			
			CY9->(MsUnLock())
		Else // Somente uma máquina
			dbSelectArea('CYY')
			CYY->(dbSetOrder(1))
			If CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
							
				RecLock('CYY',.F.)
				
				CYY->CYY_CDMQ   := aAloc[1][1]
				CYY->CYY_QTCG   := Posicione('CYI',1,xFilial('CYI')+CYY->CYY_CDCETR,'CYI_QTCG')
				
				// Possui setup
				if aAloc[1][7] > 0
					nTempo := SFCXHourToSeg(alltrim(Bit2Tempo(aAloc[1][7], .T.)))
					
					CYY->CYY_DTIMCS := aAloc[1][2]
					CYY->CYY_HRIMCS := aAloc[1][3] + ':00'
					CYY->CYY_DTIMTS := aAloc[1][2]
					CYY->CYY_HRIMTS := aAloc[1][3] + ':00'
				
					CYY->CYY_QTPASU := nTempo
					CYY->CYY_DTIMC  := aAloc[1][2]
					CYY->CYY_HRIMC  := SFCXSegToHour(SFCXHourToSeg(aAloc[1][3]) + nTempo)
					CYY->CYY_DTIMT  := aAloc[1][2]
					CYY->CYY_HRIMT  := SFCXSegToHour(SFCXHourToSeg(aAloc[1][3]) + nTempo)
					CYY->CYY_DTFMC  := aAloc[1][4]
					CYY->CYY_HRFMC  := aAloc[1][5] + ':00'
					CYY->CYY_DTFMT  := aAloc[1][4]
					CYY->CYY_HRFMT  := aAloc[1][5] + ':00'
				Else
					CYY->CYY_DTIMC  := aAloc[1][2]
					CYY->CYY_HRIMC  := aAloc[1][3] + ':00'
					CYY->CYY_DTIMT  := aAloc[1][2]
					CYY->CYY_HRIMT  := aAloc[1][3] + ':00'
					CYY->CYY_DTFMC  := aAloc[1][4]
					CYY->CYY_HRFMC  := aAloc[1][5] + ':00'
					CYY->CYY_DTFMT  := aAloc[1][4]
					CYY->CYY_HRFMT  := aAloc[1][5] + ':00'
				Endif
				
				CYY->CYY_LGCGMQ := .T.
				
				MsUnLock()
			Endif
			
			dbSelectArea('SHY')
			SHY->(dbSetOrder(1))
			if SHY->(dbSeek(xFilial('SHY')+PadR(CY9->CY9_NRORPO,TamSX3('HY_OP')[1])+PadR(CY9->CY9_CDRT,TamSX3('HY_ROTEIRO')[1])+PadR(CY9->CY9_CDAT,TamSX3('HY_OPERAC')[1])))
			
				RecLock('SHY',.F.)
				
				cData := DTOS(aAloc[1][2])
				
				SHY->HY_DATAINI := Substr(cData,1,4) + '-' + Substr(cData, 5,2) + '-' + Substr(cData,7,2)
				SHY->HY_HORAINI := aAloc[1][3] + ':00'
				
				cData := DTOS(aAloc[1][4])
				
				SHY->HY_DATAFIM := Substr(cData,1,4) + '-' + Substr(cData, 5,2) + '-' + Substr(cData,7,2)
				SHY->HY_HORAFIM := aAloc[1][5] + ':00'
				SHY->HY_RECURSO := ''
				
				SHY->(MsUnLock())
			Endif
			
			RecLock('CY9',.F.)
			
			CY9->CY9_DTIMC := aAloc[1][2]
			CY9->CY9_HRIMC := aAloc[1][3] + ':00'
			CY9->CY9_DTFMT := aAloc[1][4]
			CY9->CY9_HRFMT := aAloc[1][5] + ':00'
			
			MsUnLock()
		Endif
	Endif	
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// Integração com protheus
//-------------------------------------------------------------------
Static Function AUTO681(cNRORPO)
Local aMata681  := {}
Local lRet      := .T.
Local cQuery, cTmp
Local aArea     := GetArea()  
Local aAreaCY9  := CY9->(GetArea())
Local aAreaSH6  := SH6->(GetArea())
Local lHelpDark := HelpInDark(.F.)
Local lHelp     := HelpLog(.T.)
Local cAliasCYV := GetNextAlias()  

Private lMsHelpAuto := .T. // Grava help no log
Private lMSErroAuto := .F.   

Pergunte('MTA680',.F.)

IF MV_PAR07 == 3 // Não valida rede-pert

	BeginSql Alias cAliasCYV

		SELECT * FROM %Table:CYV% CYV
			 WHERE CYV.CYV_NRORPO = %Exp:cNRORPO% AND
					CYV.CYV_LGGAAC = 'T' AND
					CYV.CYV_LGRPEO = 'F' AND
					CYV.%NotDel% 
					ORDER BY CYV.CYV_NRSQRP DESC

	EndSql
	
	// Se não acha registro, então pega o primeiro pro PCP tentar estornar (registros antigos)
	if (cAliasCYV)->(RecCount()) == 0
		(cAliasCYV)->(dbCloseArea())
		
		While !CY9->(Eof()) .And. CY9->CY9_NRORPO == cNRORPO
			If CY9->CY9_LGATED
				Exit
			EndIf
			
			CY9->(dbSkip())
		End
		 
		BeginSql Alias cAliasCYV

			SELECT * FROM %Table:CYV% CYV
				 WHERE CYV.CYV_NRORPO = %Exp:cNRORPO% AND
				 		CYV.CYV_IDAT   = %Exp:CY9->CY9_IDAT% AND
						CYV.CYV_LGRPEO = 'F' AND
						CYV.%NotDel% 
						ORDER BY CYV.CYV_NRSQRP DESC

		EndSql
	Endif
	
	dbSelectArea('CY9')
	CY9->(dbSetOrder(1))
	CY9->(dbSeek(xFilial('CY9')+cNRORPO+(cAliasCYV)->CYV_IDAT))
	
	(cAliasCYV)->(dbCloseArea())
	 		  	  		  	 
Else    

	dbSelectArea('CY9')
	CY9->(dbSetOrder(1))
	CY9->(dbSeek(xFilial('CY9')+cNRORPO))           
	
	While !CY9->(Eof()) .And. CY9->CY9_NRORPO == cNRORPO
		If CY9->CY9_LGATED
			Exit
		EndIf
		
		CY9->(dbSkip())
	End
	
Endif

SH6->(dbSetOrder(1))
SH6->(dbSeek(xFilial("SH6")+PadR(cNRORPO,TamSX3("H6_OP")[1])+PadR(CY9->CY9_CDAC,TamSX3("H6_PRODUTO")[1])+;
	  		 PadR(CY9->CY9_CDAT,TamSX3("H6_OPERAC")[1])+Space(TamSX3("H6_SEQ")[1])))
    
aAdd(aMata681,{"H6_OP"     ,SH6->H6_OP                , NIL})              
aAdd(aMata681,{"H6_PRODUTO",SH6->H6_PRODUTO           , NIL})             
aAdd(aMata681,{"H6_OPERAC" ,SH6->H6_OPERAC            , NIL})  
aAdd(aMata681,{"H6_SEQ"    ,Space(TamSX3("H6_SEQ")[1]), NIL})
aAdd(aMata681,{"H6_DATAINI",SH6->H6_DATAINI           , NIL})
aAdd(aMata681,{"H6_HORAINI",SH6->H6_HORAINI           , NIL}) 
aAdd(aMata681,{"H6_DATAFIN",SH6->H6_DATAFIN           , NIL})
aAdd(aMata681,{"H6_HORAFIN",SH6->H6_HORAFIN           , NIL})
aAdd(aMata681,{"INDEX"     ,1,NIL})  

msExecAuto({|x,y| MATA681(x,y)},aMata681,7)

If !__lAutomacao
	If lMSErroAuto //-- Tratativa de erro
		If !IsTelNet()
			MostraErro()
		Else
			ErroTelnet()
		EndIf
		lRet = .F.
	EndIf
EndIf

HelpInDark(lHelpDark)
HelpLog(lHelp)
RestArea(aArea)
RestArea(aAreaCY9)
RestArea(aAreaSH6)
	
Return lRet
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
/*Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent, oActivityContent, oPertOrderContent, oMaterialOrderContent, oQuotaActivityContent
Local oBusinessEvent
Local nOpc := 3
Local oModel, oModelCY9, oModelCYD, oModelCYP, oModelCYY
Local nI
Local aActivity := {}
Local aPertOrder := {}
Local aMaterialOrder := {}
Local aQuotaActivity := {}
Local aArea     := GetArea()
Local aAreaCYQ  := CYQ->(GetArea())

If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE    

	  ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA100: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))

	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA100 Recebendo Mensagem Business' )
            
			cError := ''
			cWarning := '' 
			
			// Cria um objeto XML a partir da estutura dos dados do Model
			oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning) 
			                                    
			lValid := .F.   
			
			If oXML != NIL
				If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
					oBusinessContent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
					oBusinessEvent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_EVENT:TEXT   
					
					lValid := .T.
				ElseIf XmlChildEx(oXML, '_BUSINESSCONTENT') != NIL
					oBusinessContent = oXML:_BusinessContent
					oBusinessEvent = EAI_EVENT_UPSERT   
					
					lValid := .T.
				EndIf
			EndIf
			
            If lValid == .F.
            	Return { lValid, 'Nao foi enviada uma mensagem valida' }	
            EndIf
			        
			// Instancia o modelo	
			oModel := FWLoadModel( 'SFCA100' )
			oModelCY9 := oModel:GetModel('CY9DETAIL')
			oModelCYD := oModel:GetModel('CYDDETAIL')
			oModelCYP := oModel:GetModel('CYPDETAIL')
			oModelCYY := oModel:GetModel('CYYDETAIL')
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYQ')
			CYQ->(dbSetOrder(1))
			lFound := CYQ->(dbSeek(xFilial('CYQ')+ oBusinessContent:_Number:TEXT))
			
			// Verifica se a mensagem é de Inclusão/Alteração
			If UPPER(oBusinessEvent) == EAI_EVENT_UPSERT
				// Se foi encontrado, envia como Alteração
				If lFound
					nOpc := 4
				Else 
					// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
					nOpc := 3						
				EndIf
			Else  
				// Apaga o registro  
				nOpc := 5						
			EndIf
            
			// Set a operação e Ativa o Model
			oModel:SetOperation(nOpc)
			oModel:Activate()
            
            // Se operação for diferente de exclusão
			If nOpc # 5
				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_NRORPO', oBusinessContent:_Number:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
                                                          
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDAC'   , oBusinessContent:_ItemCode:TEXT 							  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPORPO' , oBusinessContent:_Type:TEXT 								  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_LGACCP' , SFCXStoX( oBusinessContent:_IsItemCoproduct:TEXT 	  , 'L' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTOR'   , SFCXStoX( oBusinessContent:_Quantity:TEXT        	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				If XmlChildEx(oBusinessContent, "_MINIMUMQUANTITY") != NIL
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTORMI' , SFCXStoX( oBusinessContent:_MinimumQuantity:TEXT 	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, "_MAXIMUMQUANTITY") != NIL
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTORMX' , SFCXStoX( oBusinessContent:_MaximumQuantity:TEXT 	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTORRP' , SFCXStoX( oBusinessContent:_ReportQuantity:TEXT  	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTORAP' , SFCXStoX( oBusinessContent:_ApprovedQuantity:TEXT	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTORRT' , SFCXStoX( oBusinessContent:_ReworkQuantity:TEXT  	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTORRF' , SFCXStoX( oBusinessContent:_ScrapQuantity:TEXT   	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDACAX' , oBusinessContent:_AuxiliarItemCode:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_LGSTOR' , SFCXStoX( oBusinessContent:_IsStatusOrder:TEXT   	  , 'L' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDUN'   , oBusinessContent:_UnitOfMeasureCode:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDPDOR' , oBusinessContent:_RequestOrderCode:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				If XmlChildEx(oBusinessContent, "_ENDACTIVITYDATETIME")
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_DTEDAT' , SFCXStoX( oBusinessContent:_EndActivityDateTime:TEXT 	  , 'DTD' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPST'   , oBusinessContent:_StatusType:TEXT 							  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPSTOR' , oBusinessContent:_StatusOrderType:TEXT 						  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDLIPO' , oBusinessContent:_ProductionLineCode:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDRE'   , oBusinessContent:_ReferenceCode:TEXT 						  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPRPOR' , oBusinessContent:_ReportOrderType:TEXT 						  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPAL'   , oBusinessContent:_AllocationType:TEXT 	 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDES'   , oBusinessContent:_SiteCode:TEXT 		 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDDP'   , oBusinessContent:_WarehouseCode:TEXT 						  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				If XmlChildEx(oBusinessContent, "_STARTORDERCPDATE") != NIL
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_DTBGAT' , SFCXStoX(oBusinessContent:_StartOrderCPDate:TEXT 	  , 'D' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_DTEDAT' , SFCXStoX(oBusinessContent:_EndOrderCPDate:TEXT 	  , 'D' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, "_RELEASEORDERDATE") != NIL
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_DTLBOR' , SFCXStoX(oBusinessContent:_ReleaseOrderDate:TEXT	  , 'D' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTTELB' , SFCXStoX(oBusinessContent:_TimeReleaseQuantity:TEXT   , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTORBG' , SFCXStoX(oBusinessContent:_StartOrderQuantity:TEXT	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_QTORED' , SFCXStoX(oBusinessContent:_EndOrderQuantity:TEXT 	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_NMSIFB' , oBusinessContent:_AbbreviationProviderName:TEXT 			  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDGRFB' , oBusinessContent:_CustomerGroupCode:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_NRULSQ' , oBusinessContent:_LastPertNumber:TEXT 						  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_NRSQ'   , oBusinessContent:_PertRequestNumber:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDLO'   , oBusinessContent:_LotCode:TEXT 								  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDTBMT' , oBusinessContent:_MaterialListCode:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDRT'   , oBusinessContent:_ScriptCode:TEXT 							  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				
                If oBusinessContent:_MaterialCalculationType:TEXT <> '0'
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPMPC'  , oBusinessContent:_MaterialCalculationType:TEXT 				  )
					If !lAssign; Return SFCXMKERR(oModel); EndIf
				Else
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPMPC'  , '1' 				  )
					If !lAssign; Return SFCXMKERR(oModel); EndIf				
				EndIf
				
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPMOD'  , oBusinessContent:_LaborType:TEXT 							  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPMBCS' , oBusinessContent:_LaborCostType:TEXT 						  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPMPCS' , oBusinessContent:_MaterialCostType:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPGFCS' , oBusinessContent:_OverheadCostType:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPMODC' , oBusinessContent:_LaborCalculationType:TEXT 				  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPGGFC' , oBusinessContent:_OverheadCalculationType:TEXT 				  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_TPGGF'  , oBusinessContent:_OverheadType:TEXT 						  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				If XmlChildEx(oBusinessContent, "_SCRAPITEMCODE") != NIL
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDACRF' , oBusinessContent:_ScrapItemCode:TEXT 						  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, "_SCRAPITEMVALUE") != NIL				
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_VLRFAC' , SFCXStoX( oBusinessContent:_ScrapItemValue:TEXT 	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDUNNG' , oBusinessContent:_BusinessUnitCode:TEXT 					  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDGE'   , oBusinessContent:_StockGroupCode:TEXT 						  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYQMASTER', 'CYQ_CDFA'   , oBusinessContent:_FamilyCode:TEXT							  );If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				If XmlChildEx(oBusinessContent, "_NETWEIGHT") != NIL				
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_VLPSLQ' , SFCXStoX( oBusinessContent:_NetWeight:TEXT  		  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, "_GROSSWEIGHT") != NIL
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_VLPSBR' , SFCXStoX( oBusinessContent:_GrossWeight:TEXT 	  	  , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				 
				// Campos que nao estao presentes no xmlschema - Verificar
				//oModel:SetValue('CYQMASTER', 'CYQ_CDPD'   , oBusinessContent:_RequestCode:TEXT 							  )                        
				//oModel:SetValue('CYQMASTER', 'CYQ_CDUSPL' , oBusinessContent:_UserPlanCode:TEXT 						  	  )

				// DateTime - Verificar 
				If XmlChildEx(oBusinessContent, "_STARTORDERDATETIME") != NIL            
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_DTBGOR' , SFCXStoX(oBusinessContent:_StartOrderDateTime:TEXT, 'DTD' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_HRBGOR' , SFCXStoX(oBusinessContent:_StartOrderDateTime:TEXT, 'DTT' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, "_ENDORDERDATETIME") != NIL  
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_DTEDOR' , SFCXStoX(oBusinessContent:_EndOrderDateTime:TEXT, 'DTD' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_HREDOR' , SFCXStoX(oBusinessContent:_EndOrderDateTime:TEXT, 'DTT' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
					
    			If XmlChildEx(oBusinessContent, "_STARTEARLIERDATETIME") != NIL
	    			lAssign := oModel:SetValue('CYQMASTER', 'CYQ_DTIMC'  , SFCXStoX(oBusinessContent:_StartEarlierDateTime:TEXT, 'DTD' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_HRIMC'  , SFCXStoX(oBusinessContent:_StartEarlierDateTime:TEXT, 'DTT' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
			   	EndIf
			   	
			   	If XmlChildEx(oBusinessContent, "_ENDLATERDATETIME") != NIL
				   	lAssign := oModel:SetValue('CYQMASTER', 'CYQ_DTFMT'  , SFCXStoX(oBusinessContent:_EndLaterDateTime:TEXT, 'DTD' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYQMASTER', 'CYQ_HRFMT'  , SFCXStoX(oBusinessContent:_EndLaterDateTime:TEXT, 'DTT' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf
                
                // Operações da Ordem
				For nI := 1 To oModelCY9:Length()
					oModelCY9:GoLine( nI )
					If !oModelCY9:IsDeleted()
				       	oModelCY9:DeleteLine()
					Endif
				Next
	            
				If XmlChildEx(oBusinessContent, "_LISTOFACTIVITYORDERS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfActivityOrders) > 0
					aActivity := oBusinessContent:_ListOfActivityOrders:_ActivityOrder
					If valType(aActivity) == 'O'
						aActivity := { aActivity }
					EndIf
        			EndIf
				
				For nI := 1 To Len(aActivity) 
					oModelCY9:AddLine()
				    oActivityContent := aActivity[nI] 
				    
				    lAssign := oModelCY9:SetValue('CY9_NRORPO', oModel:GetValue('CYQMASTER', 'CYQ_NRORPO') 					  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_IDAT'  , oActivityContent:_ActivityID:TEXT 								  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_CDAT'  , oActivityContent:_ActivityCode:TEXT 							  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_DSAT'  , oActivityContent:_ActivityDescription:TEXT 					  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_CDAC'  , oActivityContent:_ItemCode:TEXT 								  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_TPAT'  , oActivityContent:_ActivityType:TEXT 							  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_CDCETR', oActivityContent:_WorkCenterCode:TEXT 							  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_DSCETR', oActivityContent:_WorkCenterDescription:TEXT 					  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_TPUNTE', oActivityContent:_UnitTimeType:TEXT 							  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTTERC', SFCXStoX( oActivityContent:_TimeResource:TEXT 			  	, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTTEMQ', SFCXStoX( oActivityContent:_TimeMachine:TEXT 			  	, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTTESU', SFCXStoX( oActivityContent:_TimeSetup:TEXT 			  	, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_CDRT'  , oActivityContent:_ScriptCode:TEXT 								  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				   	lAssign := oModelCY9:SetValue('CY9_CDATVF', SFCXStoX( oActivityContent:_ActivityControlCode:TEXT 		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTRC'  , SFCXStoX( oActivityContent:_ResourceQuantity:TEXT 	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_VLPNOV', SFCXStoX( oActivityContent:_PercentageOverlapValue:TEXT  	, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_VLPN'  , SFCXStoX( oActivityContent:_PercentageValue:TEXT  	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_CDMOD' , oActivityContent:_LaborCode:TEXT 								  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_NRUNAC', SFCXStoX( oActivityContent:_UnitItemNumber:TEXT 	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTPO'  , SFCXStoX( oActivityContent:_ProductionQuantity:TEXT 	  	, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_CDATAV', oActivityContent:_AlternativeActivityCode:TEXT 				  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_CDUNAT', oActivityContent:_UnitActivityCode:TEXT 						  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					
					If XmlChildEx(oActivityContent, "_SCRAPITEMCODE") != NIL
						lAssign := oModelCY9:SetValue('CY9_CDACRF', oActivityContent:_ScrapItemCode:TEXT 						 )		;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oActivityContent, "_SCRAPITEMVALUE") != NIL
						lAssign := oModelCY9:SetValue('CY9_VLRFAC', SFCXStoX( oActivityContent:_ScrapItemValue:TEXT  	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oActivityContent, "_PERCENTAGESCRAPVALUE") != NIL
						lAssign := oModelCY9:SetValue('CY9_VLPNRF', SFCXStoX( oActivityContent:_PercentageScrapValue:TEXT 	  	, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oActivityContent, "_TIMEPOSTPROCESSING") != NIL
						lAssign := oModelCY9:SetValue('CY9_QTTEPP', SFCXStoX( oActivityContent:_TimePostprocessing:TEXT		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					lAssign := oModelCY9:SetValue('CY9_QTVM'  , SFCXStoX( oActivityContent:_UsedCapacity:TEXT  	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTCG'  , SFCXStoX( oActivityContent:_LoadQuantity:TEXT 	 			, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_TPST'  , oActivityContent:_StatusType:TEXT 								  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_CDFE'  , oActivityContent:_ListOfActivityOrderTools:_ActivityOrderTool:_ToolCode:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
				 	lAssign := oModelCY9:SetValue('CY9_NRORRE', oActivityContent:_OrderReferenceNumber:TEXT 					  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_LGATBG', SFCXStoX( oActivityContent:_IsActivityStart:TEXT  	 		, 'L' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_LGATED', SFCXStoX( oActivityContent:_IsActivityEnd:TEXT 	 		, 'L' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTAP'  , SFCXStoX( oActivityContent:_ApprovedQuantity:TEXT 	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTRT'  , SFCXStoX( oActivityContent:_ReworkQuantity:TEXT 	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTRF'  , SFCXStoX( oActivityContent:_ScrapQuantity:TEXT 	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTRP'  , SFCXStoX( oActivityContent:_ReportQuantity:TEXT 	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_LGULRP', SFCXStoX( oActivityContent:_IsLastReport:TEXT 	  			, 'L' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_VLMTAC', SFCXStoX( oActivityContent:_MaterialItemValue:TEXT 	    , 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_TPTE'  , oActivityContent:_TreatmentTimeType:TEXT 						  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTLOPA', SFCXStoX( oActivityContent:_StandardLotQuantity:TEXT 		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTLOMU', SFCXStoX( oActivityContent:_MultipleLotQuantity:TEXT 		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTLOMI', SFCXStoX( oActivityContent:_MinimumLotQuantity:TEXT 	    , 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY9:SetValue('CY9_QTAT'  , SFCXStoX( oActivityContent:_ActivityQuantity:TEXT 	  		, 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
			
					If Empty( oModel:GetValue('CY9DETAIL','CY9_TPST') )  
						oModelCY9:SetValue('CY9_TPST', '1')
					EndIf
			
			
					// DateTime - Verificar 
					If XmlChildEx(oActivityContent, "_ENDLATERDATETIME") != NIL	
						lAssign := oModelCY9:SetValue('CY9_DTFMT' , SFCXStoX( oActivityContent:_EndLaterDateTime:TEXT 	  		, 'DTD' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCY9:SetValue('CY9_HRFMT' , SFCXStoX( oActivityContent:_EndLaterDateTime:TEXT 			, 'DTT' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oActivityContent, "_STARTREALDATETIME") != NIL					
						lAssign := oModelCY9:SetValue('CY9_DTBGRY', SFCXStoX( oActivityContent:_StartRealDateTime:TEXT		    , 'DTD' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCY9:SetValue('CY9_HRBGRY', SFCXStoX( oActivityContent:_StartRealDateTime:TEXT 		, 'DTT' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					                                                                                                        
					If XmlChildEx(oActivityContent, "_ENDREALDATETIME") != NIL
						lAssign := oModelCY9:SetValue('CY9_DTEDRY', SFCXStoX( oActivityContent:_EndRealDateTime:TEXT 	  		, 'DTD' ) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCY9:SetValue('CY9_HREDRY', SFCXStoX( oActivityContent:_EndRealDateTime:TEXT 			, 'DTT' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oActivityContent, "_STARTEARLIERDATETIME") != NIL
						lAssign := oModelCY9:SetValue('CY9_DTIMC' , SFCXStoX( oActivityContent:_StartEarlierDateTime:TEXT 		, 'DTD' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCY9:SetValue('CY9_HRIMC' , SFCXStoX( oActivityContent:_StartEarlierDateTime:TEXT 		, 'DTT' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
				Next                                  
				
				// Rede Pert da Ordem
				For nI := 1 To oModelCYD:Length()
					oModelCYD:GoLine( nI )
					If !oModelCYD:IsDeleted()
				       	oModelCYD:DeleteLine()
					Endif
				Next
	            
				
				If XmlChildEx(oBusinessContent, "_LISTOFPERTORDERS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfPertOrders) > 0
					aPertOrder := oBusinessContent:_ListOfPertOrders:_PertOrder
					If valType(aPertOrder) == 'O'
						aPertOrder := { aPertOrder }
					EndIf
				EndIf
				
        		For nI := 1 To Len(aPertOrder) 
					oModelCYD:AddLine()
				    oPertOrderContent := aPertOrder[nI]
				    
				    lAssign := oModelCYD:SetValue('CYD_NRORPO', oModel:GetValue('CYQMASTER', 'CYQ_NRORPO')     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_CDAC'  , oPertOrderContent:_ItemCode:TEXT            					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_IDATNX', oPertOrderContent:_NextActivityID:TEXT      					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_CDAT'  , oPertOrderContent:_ActivityCode:TEXT        					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_CDRT'  , oPertOrderContent:_ScriptCode:TEXT 		  				 	 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_CDACPV', oPertOrderContent:_PreviousItemCode:TEXT    					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_IDATPV', oPertOrderContent:_PreviousActivityID:TEXT  					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_CDATPV', oPertOrderContent:_PreviousActivityCode:TEXT					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_CDRTPV', oPertOrderContent:_PreviousScriptCode:TEXT   					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_VLPNOV', SFCXStoX( oPertOrderContent:_PercentageOverlapValue:TEXT, 'N' ) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYD:SetValue('CYD_QTTETS', SFCXStoX( oPertOrderContent:_TimeTransport:TEXT 		 , 'N' ) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				Next
				
				// Componente da Ordem
				For nI := 1 To oModelCYP:Length()
					oModelCYP:GoLine( nI )
					If !oModelCYP:IsDeleted()
				       	oModelCYP:DeleteLine()
					Endif
				Next
	            
				If XmlChildEx(oBusinessContent, "_LISTOFMATERIALORDERS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfMaterialOrders) > 0
					aMaterialOrder := oBusinessContent:_ListOfMaterialOrders:_MaterialOrder
					If ValType(aMaterialOrder) == 'O'
						aMaterialOrder := { aMaterialOrder }
					EndIf
        			
				
					For nI := 1 To Len(aMaterialOrder) 
						oModelCYP:AddLine()
					    oMaterialOrderContent := aMaterialOrder[nI]
					    
					    lAssign := oModelCYP:SetValue('CYP_NRORPO', oModel:GetValue('CYQMASTER', 'CYQ_NRORPO'))    				  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_IDMTOR', oMaterialOrderContent:_MaterialID:TEXT)        			  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_CDMT'  , oMaterialOrderContent:_MaterialCode:TEXT)            			  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    //lAssign := oModelCYP:SetValue('CYP_DSMT'  , oMaterialOrderContent:_MaterialDescription:TEXT)     			  ;If !lAssign; Return SFCXMKERR(oModel);  EndIf
					    
					    lAssign := oModelCYP:SetValue('CYP_CDACPI', oMaterialOrderContent:_FatherItemCode:TEXT)           		  	  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_CDRE'  , oMaterialOrderContent:_ReferenceCode:TEXT)           			  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_NRORRE', oMaterialOrderContent:_OrderReferenceNumber:TEXT)    			  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_CDRT'  , oMaterialOrderContent:_ScriptCode:TEXT)             			  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_CDAT'  , oMaterialOrderContent:_ActivityCode:TEXT)            			  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_CDLC'  , oMaterialOrderContent:_LocationCode:TEXT)            			  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_CDDP'  , oMaterialOrderContent:_WarehouseCode:TEXT)           			  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_CDLO'  , oMaterialOrderContent:_LotCode:TEXT)               			  	  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_QTMT'  , SFCXStoX( oMaterialOrderContentr:_MaterialQuantity:TEXT  , 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_QTRP'  , SFCXStoX( oMaterialOrderContent:_ReportQuantity:TEXT     , 'N' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_CDUN'  , oMaterialOrderContent:_UnitOfMeasureCode:TEXT)              	  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_DTMT'  , SFCXStoX( oMaterialOrderContent:_MaterialDate:TEXT       , 'D' )) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_TPST'  , oMaterialOrderContent:_StatusType:TEXT)             			  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    lAssign := oModelCYP:SetValue('CYP_CDTBMT', oMaterialOrderContent:_MaterialListCode:TEXT        			  ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    
					    If XmlChildEx(oMaterialOrderContent, "_PERTMATERIALNUMBER") != NIL
						    lAssign := oModelCYP:SetValue('CYP_NRSQMT', oMaterialOrderContent:_PertMaterialNumber:TEXT)           	      ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					    EndIf
					Next
				EndIf
				
				// Componente da Ordem
				For nI := 1 To oModelCYY:Length()
					oModelCYY:GoLine( nI )
					If !oModelCYY:IsDeleted()
				       	oModelCYY:DeleteLine()
					Endif
				Next
	            
				If XmlChildEx(oBusinessContent, "_LISTOFQUOTAACTIVITY") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfQuotaActivity) > 0
					aQuotaActivity := oBusinessContent:_ListOfQuotaActivity:_QuotaActivity
					If valType(aQuotaActivity) == 'O'
						aQuotaActivity := { aQuotaActivity }
					EndIf
     			EndIf
				
				cIdAtQo := AllTrim(SFCA315NR(xFilial('CY9'),oModel:GetValue('CYQMASTER','CYQ_NRORPO'),oModelCYY:GetValue('CYY_IDAT')))
				
				For nI := 1 To Len(aQuotaActivity) 
					oModelCYY:AddLine()
				    oQuotaActivityContent := aQuotaActivity[nI]
				    
				    lAssign := oModelCYY:SetValue('CYY_NRORPO', oModel:GetValue('CYQMASTER', 'CYQ_NRORPO'))  					 			;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_IDAT'  , oQuotaActivityContent:_ActivityID:TEXT										)  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_CDAC'  , oQuotaActivityContent:_ItemCode:TEXT										) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTATAP', SFCXStoX(oQuotaActivityContent:_ApprovedQuantity:TEXT		 	 	 , 'N')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTATRF', SFCXStoX(oQuotaActivityContent:_ScrapQuantity:TEXT		  			 , 'N') )   ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_CDMQ'  , oQuotaActivityContent:_MachineCode:TEXT									) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_DSMQ'  , oQuotaActivityContent:_MachineDescription:TEXT								);If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTAT'  , SFCXStoX(oQuotaActivityContent:_ActivityQuantity:TEXT   			 , 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTGRAC', SFCXStoX(oQuotaActivityContent:_TeamItemQuantity:TEXT				 , 'N') )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTPASU', SFCXStoX(oQuotaActivityContent:_StandardSetup:TEXT					 , 'N') ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTPAAT', SFCXStoX(oQuotaActivityContent:_StandardActivity:TEXT				 , 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTPAPP', SFCXStoX(oQuotaActivityContent:_StandardPostprocessing:TEXT 		 , 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTPAMQ', SFCXStoX(oQuotaActivityContent:_StandardMachine:TEXT				 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTPAOE', SFCXStoX(oQuotaActivityContent:_StandardOperator:TEXT		 		 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTVMAT', SFCXStoX(oQuotaActivityContent:_UsedCapacity:TEXT	  				 , 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_LGRPOR', SFCXStoX(oQuotaActivityContent:_IsReportOrder:TEXT					 , 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTTEAT', SFCXStoX(oQuotaActivityContent:_ActivityTimeQuantity:TEXT			 , 'N') )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTATRP', SFCXStoX(oQuotaActivityContent:_ReportQuantity:TEXT	   	    	 , 'N') )   ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTATRT', SFCXStoX(oQuotaActivityContent:_ReworkQuantity:TEXT	 	 		 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTTESU', SFCXStoX(oQuotaActivityContent:_TimeSetup:TEXT					 	 , 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTTEMQ', SFCXStoX(oQuotaActivityContent:_TimeMachine:TEXT					 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTTEOE', SFCXStoX(oQuotaActivityContent:_TimeOperator:TEXT			 		 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTTEPP', SFCXStoX(oQuotaActivityContent:_TimePostprocessing:TEXT			 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTTEEX', SFCXStoX(oQuotaActivityContent:_ExtraTime:TEXT			  			 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTCG'  , SFCXStoX(oQuotaActivityContent:_LoadQuantity:TEXT					 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_IDATQO', cIdAtQo)
					If !lAssign; Return SFCXMKERR(oModel); EndIf        
					
					cIdAtQo := SOMA1(cIdAtQo)
					
				 	lAssign := oModelCYY:SetValue('CYY_IDQOET', oQuotaActivityContent:_QuotaExternalID:TEXT							  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_CDCETR', oQuotaActivityContent:_WorkCenterCode:TEXT									)	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_VLPNRF', SFCXStoX(oQuotaActivityContent:_PercentageScrapValue:TEXT			 , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_VLPNRT', SFCXStoX(oQuotaActivityContent:_PercentageReworkValue:TEXT		 	 , 'N') )					;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_LGQORP', SFCXStoX(oQuotaActivityContent:_ReportedSplit:TEXT					 , 'L') )   ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_LGQO'  , SFCXStoX(oQuotaActivityContent:_CriticalSplit:TEXT					 , 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_LGQOED', SFCXStoX(oQuotaActivityContent:_DischargedSplit:TEXT				 , 'L') )    ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_TPSTAT', oQuotaActivityContent:_StatusActivityType:TEXT							  )	;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_CDFE'  , oQuotaActivityContent:_ListOfQuotaActivityTools:_QuotaActivityTool:_ToolCode:TEXT	) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYY:SetValue('CYY_QTFE'  , SFCXStoX(oQuotaActivityContent:_ListOfQuotaActivityTools:_QuotaActivityTool:_ToolQuantity:TEXT , 'N')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                    
					// DateTime sem termos Time - Verificar
					If XmlChildEx(oQuotaActivityContent, "_AVAILABLEPLANDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTDIPL', SFCXStoX(oQuotaActivityContent:_AvailablePlanDateTime:TEXT			 , 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
                 
					// DateTime - Verificar 	                                                                                                 
					If XmlChildEx(oQuotaActivityContent, "_STARTACTIVITYDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTBGAT', SFCXStoX(oQuotaActivityContent:_StartActivityDateTime:TEXT  		, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRBGAT', SFCXStoX(oQuotaActivityContent:_StartActivityDateTime:TEXT			, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_ENDACTIVITYDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTEDAT', SFCXStoX(oQuotaActivityContent:_EndActivityDateTime:TEXT    		, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HREDAT', SFCXStoX(oQuotaActivityContent:_EndActivityDateTime:TEXT			, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_STARTSETUPDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTBGSU', SFCXStoX(oQuotaActivityContent:_StartSetupDateTime:TEXT			, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRBGSU', SFCXStoX(oQuotaActivityContent:_StartSetupDateTime:TEXT			, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_ENDSETUPDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTEDSU', SFCXStoX(oQuotaActivityContent:_EndSetupDateTime:TEXT		 		, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HREDSU', SFCXStoX(oQuotaActivityContent:_EndSetupDateTime:TEXT				, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_STARTEARLIERDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTIMC' , SFCXStoX(oQuotaActivityContent:_StartEarlierDateTime:TEXT			, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRIMC' , SFCXStoX(oQuotaActivityContent:_StartEarlierDateTime:TEXT         	, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf                                                                                                          ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_ENDEARLIERDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTFMC' , SFCXStoX(oQuotaActivityContent:_EndEarlierDateTime:TEXT			, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRFMC' , SFCXStoX(oQuotaActivityContent:_EndEarlierDateTime:TEXT			, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_STARTLATERDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTIMT' , SFCXStoX(oQuotaActivityContent:_StartLaterDateTime:TEXT			, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRIMT' , SFCXStoX(oQuotaActivityContent:_StartLaterDateTime:TEXT			, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_ENDLATERDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTFMT' , SFCXStoX(oQuotaActivityContent:_EndLaterDateTime:TEXT				, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRFMT' , SFCXStoX(oQuotaActivityContent:_EndLaterDateTime:TEXT				, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_STARTEARLIERSETUPDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTIMCS', SFCXStoX(oQuotaActivityContent:_StartEarlierSetupDateTime:TEXT	 	, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRIMCS', SFCXStoX(oQuotaActivityContent:_StartEarlierSetupDateTime:TEXT		, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_STARTLATERSETUPDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTIMTS', SFCXStoX(oQuotaActivityContent:_StartLaterSetupDateTime:TEXT		, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRIMTS', SFCXStoX(oQuotaActivityContent:_StartLaterSetupDateTime:TEXT		, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_STARTPLANDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTBGPL', SFCXStoX(oQuotaActivityContent:_StartPlanDateTime:TEXT				, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRPLSU', SFCXStoX(oQuotaActivityContent:_StartPlanDateTime:TEXT				, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_ENDPLANDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTEDPL', SFCXStoX(oQuotaActivityContent:_EndPlanDateTime:TEXT				, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HREDPL', SFCXStoX(oQuotaActivityContent:_EndPlanDateTime:TEXT 				, 'DTT')); If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_PLANSETUPDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTPLSU', SFCXStoX(oQuotaActivityContent:_PlanSetupDateTime:TEXT				, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRPLSU', SFCXStoX(oQuotaActivityContent:_PlanSetupDateTime:TEXT				, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oQuotaActivityContent, "_AVAILABLEDATETIME") != NIL
						lAssign := oModelCYY:SetValue('CYY_DTDI'  , SFCXStoX(oQuotaActivityContent:_AvailableDateTime:TEXT				, 'DTD')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYY:SetValue('CYY_HRDI'  , SFCXStoX(oQuotaActivityContent:_AvailableDateTime:TEXT 			, 'DTT')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					

				 Next
             EndIf
            
            // Validação no Model    
			if oModel:VldData()  
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()
				
				// Retorna OK
				cXMLRet := 'Mensagem de ' + IF(nOpc == 3,'Criacao', IF(nOpc == 4, 'Alteracao', 'Delecao')) + ' recebida com sucesso.'
			Else
				// Cria TAG com o Erro ocorrido para retornar ao EAI
				aErro := oModel:GetErrorMessage()
				cXMLRet := SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'
				lRet := .F.
			EndIf

			// Desativa o Model
			oModel:DeActivate()

	  // Mensagem é de Response
      ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
            //conout( '+ IntegDef SFCA100 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_RECEIPT
            //conout( '+ IntegDef SFCA100 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
EndIf

RestArea(aAreaCYQ)
RestArea(aArea)
                        
ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)
*/

Return { lRet, cXMLRet }

Function INTDF_A100( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
