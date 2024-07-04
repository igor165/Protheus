#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TECA161A

@description Base Operacional - Modelo de Dados para integracao RH
@author Flavio Vicco
@since  15/06/2022
/*/
//--------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel    :=  Nil
Local oStruAA0  :=  FWFormStruct(1,'AA0')
Local oStruREI  :=  FWFormStruct(1,'REI')
Local aAux      :=  {}
Local aTam      :=  FWTamSX3('WY_DESC')

aAux := FwStruTrigger("AA0_LOCPAD","AA0_DESCLO","AT161LOCA()",.F.,Nil,Nil,Nil)
oStruAA0:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oStruREI:AddField( ;	           // Ord. Tipo Desc.
	TecTituDes('WY_DESC',.T.) , ;  // [01]  C   Titulo do campo "Descrição"  
	TecTituDes('WY_DESC',.F.) , ;  // [02]  C   ToolTip do campo "Descrição CCT"
	'REI_DESC' , ;                 // [03]  C   Id do Field
	aTam[3] , ;                    // [04]  C   Tipo do campo
	aTam[1] , ;                    // [05]  N   Tamanho do campo
	aTam[2] , ;                    // [06]  N   Decimal do campo
	NIL , ;                        // [07]  B   Code-block de validação do campo
	NIL , ;                        // [08]  B   Code-block de validação When do campo
	NIL , ;                        // [09]  A   Lista de valores permitido do campo
	NIL , ;                        // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature(STRUCT_FEATURE_INIPAD,'Posicione("SWY",1,REI->REI_FILCCT+REI->REI_CODCCT,"WY_DESC")'), ;  // [11]  B   Code-block de inicializacao do campo
	NIL , ;                        // [12]  L   Indica se trata-se de um campo chave
	.F. , ;                        // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T. )                          // [14]  L   Indica se o campo é virtual

oModel := MPFormModel():New('TECA161',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields('AA0MASTER',/*cOwner*/,oStruAA0,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/,/*bFieldAbp*/)

oModel:SetPrimaryKey({"AA0_FILIAL","AA0_CODIGO"})

oModel:AddGrid('REIDETAIL','AA0MASTER',oStruREI)
oModel:SetRelation('REIDETAIL',{{'REI_FILIAL','xFilial("REI")'},;
   	                            {'REI_FILAA0','AA0_FILIAL'},;
       	                        {'REI_CODAA0','AA0_CODIGO'}},;
           	                    REI->(IndexKey(1)))
oModel:GetModel("REIDETAIL"):SetOnlyView(.T.)
oModel:GetModel("REIDETAIL"):SetOptional(.T.)
oModel:GetModel("REIDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("REIDETAIL"):SetNoUpdateLine(.T.)
oModel:GetModel("REIDETAIL"):SetNoDeleteLine(.T.)

Return(oModel)


//--------------------------------------------------------------------------------
/*/{Protheus.doc} Viewdef

@description Viewdef
@author Flavio Vicco
@since  15/06/2022
/*/
//--------------------------------------------------------------------------------
Static Function ViewDef()

Local oView     := NIL
Local oModel    := ModelDef()
Local oStruAA0  := FWFormStruct(2,'AA0')
Local oStruREI  := Nil

oStruREI  := FWFormStruct(2,'REI',{|cCpo|AllTrim(cCpo)$'REI_FILCCT+REI_CODCCT'})
oStruREI:AddField('REI_DESC' , ;		// [01] C Nome do Campo
	'3' , ; 							// [02] C Ordem
	TecTituDes('WY_DESC',.T.) , ;		// [03] C Titulo do campo
	TecTituDes('WY_DESC',.F.) , ;		// [04] C Descrição do campo
	{ TecTituDes('WY_DESC',.F.) } , ;	// [05] A Array com Help
	'C' , ;								// [06] C Tipo do campo
	'@!', ;								// [07] C Picture
	NIL , ; 							// [08] B Bloco de Picture Var
	Nil , ; 							// [09] C Consulta F3
	.F. , ; 							// [10] L Indica se o campo é editável
	NIL , ; 							// [11] C Pasta do campo
	NIL , ; 							// [12] C Agrupamento do campo
	NIL , ; 							// [13] A Lista de valores permitido do campo (Combo)
	NIL , ; 							// [14] N Tamanho Máximo da maior opção do combo
	NIL , ; 							// [15] C Inicializador de Browse
	.T. , ; 							// [16] L Indica se o campo é virtual
	NIL ) 								// [17] C Picture Variável

oView:= FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruAA0,'AA0MASTER')
oView:AddGrid('VIEW_DET',oStruREI,'REIDETAIL')

oView:CreateHorizontalBox('TELA',30)
oView:CreateHorizontalBox('GRID',70)

oView:CreateFolder('ABAS','GRID')
oView:AddSheet('ABAS','ABA01',FwX2Nome('SWY'))
oView:CreateHorizontalBox('ID_ABA01',100,,,'ABAS','ABA01')

oView:SetOwnerView('VIEW_CAB','TELA')
oView:SetOwnerView('VIEW_DET','ID_ABA01')

Return(oView)
