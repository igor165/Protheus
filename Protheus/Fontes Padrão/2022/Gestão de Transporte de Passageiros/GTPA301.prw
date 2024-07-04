#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH' 
#Include 'GTPA301.CH'
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cadastro de Grupo de Escala 
@sample		GTPA301
@return		Nil
@author		Gestão de Transporte de Passageiros
@since			24/09/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Function GTPA301()
Local oBrowse	:= FWMBrowse():New()

oBrowse:SetAlias('GZA')
oBrowse:SetDescription(STR0001) //'Cadastro de Grupo de Escala'

oBrowse:SetMenuDef('GTPA301')

oBrowse:Activate()

Return Nil

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu da rotina
@sample		MenuDef()
@return		aRotina - Array com opções do menu
@author		Gestão de Transporte de Passageiros
@since			24/09/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}
 
ADD OPTION aRotina Title STR0002 	Action 'VIEWDEF.GTPA301' 	OPERATION 2 ACCESS 0 //'Visualizar' 
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.GTPA301' 	OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.GTPA301' 	OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 	Action 'VIEWDEF.GTPA301' 	OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0019 	Action 'GTPR302B()' 		OPERATION 8 ACCESS 0 //"Imp Escalas"
Return aRotina

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel - Objeto do Model
@author		Serviços - Inovação
@since			06/03/2014
@version		P12
/*/ 
//--------------------------------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel		:= MPFormModel():New('GTPA301')
Local oStruGrEsc 	:= FWFormStruct( 1, 'GZA')
Local oStruColab 	:= FWFormStruct( 1, 'GYI')
Local oStruEscal 	:= FWFormStruct( 1, 'GZB')
Local xAux		


xAux := FwStruTrigger( 'GZA_SETOR', 'GZA_SETOR', 'TRIG301("GZAMASTER")' , .F. )
oStruGrEsc:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		 			
xAux := FwStruTrigger( 'GZB_ESCALA', 'GZB_ESCALA', 'TRIG301("GZBESCAL")' , .F. )
oStruEscal:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])



oStruColab:SetProperty( 'GYI_COLCOD',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue| Ga300Vld(oMdl,cField,cNewValue,cOldValue) } )
oStruEscal:SetProperty( 'GZB_ESCALA',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue| Ga300Vld(oMdl,cField,cNewValue,cOldValue) } )


oModel:AddFields(	'GZAMASTER'	, /*cOwner*/ , oStruGrEsc )
oModel:AddGrid(	'GYICOLAB'		, 'GZAMASTER', oStruColab, /*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/ )
oModel:AddGrid(	'GZBESCAL'		, 'GZAMASTER', oStruEscal, /*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/ )

oModel:SetRelation( 'GYICOLAB', { { 'GYI_FILIAL', 'xFilial( "GYI" )' }, { 'GYI_GRPCOD', 'GZA_CODIGO' } }, GYI->( IndexKey( 1 ) ) )
oModel:SetRelation( 'GZBESCAL', { { 'GZB_FILIAL', 'xFilial( "GZB" )' }, { 'GZB_GRPCOD', 'GZA_CODIGO' } }, GZB->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey({'GZA_FILIAL','GZA_CODIGO'})

oModel:SetDescription( STR0007 ) //'Grupos de escala'

oModel:GetModel('GYICOLAB'):SetDescription( STR0009 ) //'Colaboradores da Escala'
oModel:GetModel('GZBESCAL'):SetDescription( STR0020 ) //'Escalas do grupo'

//Preenchimento grid colaboradores opcional
oModel:GetModel('GYICOLAB'):SetOptional(.T.)

//Linha duplicada
oModel:GetModel('GYICOLAB'):SetUniqueLine({"GYI_COLCOD"})
oModel:GetModel('GZBESCAL'):SetUniqueLine({"GZB_ESCALA"})

oModel:SetVldActivate( { |oModel| GTP301APre( oModel ) } ) // Faz a validacao antes de abrir a tela.

Return oModel 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel - Objeto do Model
@author		Gestão de Transporte de Passageiros
@since			29/09/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function ViewDef()

Local oModel := FWLoadModel( 'GTPA301' )
Local oStruGrEsc := FWFormStruct( 2, 'GZA')
Local oStruColab := FWFormStruct( 2, 'GYI', { |cCampo| ! Alltrim(cCampo) $ "GYI_GRPCOD" }  )
Local oStruEscal := FWFormStruct( 2, 'GZB', { |cCampo| ! Alltrim(cCampo) $ "GZB_GRPCOD" }  )
Local oView
	 
oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField(	'VIEW_PAI'		, oStruGrEsc, 'GZAMASTER' )
oView:AddGrid(	'VIEW_COLAB'	, oStruColab, 'GYICOLAB',/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
oView:AddGrid(	'VIEW_ESCALA'	, oStruEscal, 'GZBESCAL',/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)

oView:AddIncrementField('VIEW_COLAB','GYI_ITEM')
oView:AddIncrementField('VIEW_ESCALA','GZB_ITEM')

oView:CreateHorizontalBox( 'SUPERIOR'		, 20 )
oView:CreateHorizontalBox( 'COLABORADOR'	, 40 )
oView:CreateHorizontalBox( 'ESCALA'		, 40 )

oView:SetOwnerView( 'VIEW_PAI'		, 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_COLAB'	, 'COLABORADOR' )
oView:SetOwnerView( 'VIEW_ESCALA'	, 'ESCALA' )

oView:EnableTitleView('VIEW_COLAB',STR0011 ) //"Colaboradores"
oView:EnableTitleView('VIEW_ESCALA',STR0014 ) //'Escalas'	
Return oView 

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ga300Vld
Executa a verificação da edição da linha no grid dos Colaboradores

@sample		Ga300Vld(oMdl,cField,cNewValue,cOldValue)

@param 			oMdl 		- Objeto, modelo em validação
				cField		- String, Campo que iniciou a validação
				cNewValue	- ,Novo valor informado
				cOldValue	- ,Valor que estava informado   

@return		Boolean
@author		Jacomo Lisa
@since			06/05/17
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Function Ga300Vld(oMdl,cField,cNewValue,cOldValue)
Local lRet 	:= .T.
Local aArea	:= GetArea()
Local cErro	:= ""
Local cSolucao:= ""

If !Empty(cNewValue)
	Do Case
		Case cField == 'GYI_COLCOD'
			//Valida se o código de Colaborador existe
			GYG->(DbSetOrder(1))//GYG_FILIAL+GYG_CODIGO   
			If GYG->(DbSeek(xFilial('GYG')+cNewValue))
				
				//Verifica se o Colaborador já foi informado em outro grupo
				GYI->(DbSetOrder(2)) //GYI_FILIAL+GYI_COLCOD+GYI_GRPCOD
				If GYI->(dbSeek(xFilial("GYI")+cNewValue)) .and. GYI->GYI_GRPCOD <> FwFldGet('GZA_CODIGO')
					cErro := I18n(STR0012, { cNewValue, GYI->GYI_GRPCOD } ) //"O colaborador #1 já pertence ao Grupo de Escala #2. "
					lRet := .F.
				Endif
				
				//Verifica se o Colaborador foi informado se encontra no setor informado
				GY2->(DbSetOrder(2)) //GY2_FILIAL+GY2_CODCOL+GY2_SETOR
				If lRet 
					If GY2->(DbSeek(xFilial('GY2')+cNewValue)) 
						If GY2->GY2_SETOR <> FWFldGet("GZA_SETOR")
							cErro := I18n(STR0015, { cNewValue } ) //"O colaborador #1 não pertence ao setor de Escala selecionado "
							lRet := .F.
						Endif
					Else
						cErro := I18n(STR0016, { cNewValue } ) //"O colaborador #1 não pertence a nenhum setor de Escala"
						lRet := .F.
					Endif
				Endif
			Else
				cErro	:=  STR0017 //"Não existe registro relacionado ao Código informado"
				lRet	:= .F.
			Endif
			
		Case cField == 'GZB_ESCALA'
			//Valida se a Escala existe
			GYO->(DbSetOrder(1))//GYO_FILIAL+GYO_CODIGO   
			If GYO->(DbSeek(xFilial('GYO')+cNewValue ))
				//Verifica se essa escala é do mesmo setor
				If GYO->GYO_SETOR <> FWFldGet("GZA_SETOR")
					cErro := I18n(STR0018, { cNewValue, GYO->GYO_SETOR } ) //"A Escala #1 pertence a outro Setor: #2"
					lRet := .F.
				Endif
				
			Else
				cErro	:=  STR0017//"Não existe registro relacionado ao Código informado"
				lRet	:= .F. 
			Endif 
		
	EndCase 
Endif

If !lRet
	oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"Ga300Vld",cErro,cSolucao,cNewValue,cOldValue)
Endif

RestArea( aArea )

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP301APre
Executa a verificação da edição da linha no grid dos Colaboradores

@sample		GTP301APre( oModel )

@param 			oModel	- Objeto, objeto do model

@return		Boolean
@author		Cristiane Nishizaka
@since			18/02/2015
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Function GTP301APre(oModel)

Local aArea		:= GetArea()
Local aAreaGYH	:= GYH->( GetArea() )
Local lRet 	:= .T.
Local cCodUsr	:= AllTrim(RetCodUsr())
Local cSetor	:= ""

If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. cCodUsr <> "000000"	

	cSetor := GZA->GZA_SETOR
	
	DbSelectArea("GYH")
	DbSetOrder(1) //GYH_FILIAL+GYH_CODIGO+GYH_USRCOD
	
	//Se o usuário não pertencer ao grupo de escala a ser alterado
	If !GYH->(DbSeek(xFilial("GYH")+PadR(cSetor,TamSX3("GYH_CODIGO")[1])+PadR(cCodUsr,TamSX3("GYH_USRCOD")[1])))
		Help(" ",1,"GTP301APRE", , STR0013, 3, 1 ) //"Usuario nao pertence ao Grupo de Escala."
		lRet := .F.
	EndIf
	
EndIf

RestArea( aAreaGYH )
RestArea( aArea )

Return (lRet)


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TRIG301
Executa a trigger

@sample		TRIG301( cOri, cDest )


@return		cRet
@author		Fernando Amorim(Cafu)
@since			18/02/2015
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Function TRIG301(cDom)

Local cRet			:= ''
Local oModel		:= FwModelActive()	


If Alltrim(UPPER(cDom)) == 'GZAMASTER'
	GYT->(DbSetOrder(1))
	GI1->(DbSetOrder(1))
	If GYT->(DbSeek(xFilial("GYT")+oModel:GetModel(cDom):getvalue("GZA_SETOR")))
		If GI1->(DbSeek(xFilial("GI1")+GYT->GYT_LOCALI))
			oModel:GetModel(cDom):LoadValue("GZA_DSCSET"	,GI1->GI1_DESCRI)		
		Endif	
	Endif	
	cRet :=  &(ReadVar())
ElseIf Alltrim(UPPER(cDom)) == 'GZBESCAL'
	oModel:GetModel(cDom):LoadValue("GZB_NESCAL"	,posicione("GYO",1,xFilial("GYO")+oModel:GetModel(cDom):getvalue("GZB_ESCALA"),'GYO_DESCRI'))
	cRet :=  &(ReadVar())
Endif

Return cRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA301INI
Executa o inicializador

@sample		GTPA301INI()


@return		cRet
@author		jacomo.fernandes
@since			05/10/17
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------

Function GTPA301INI(cField)
Local cCodLoc := ""
Local cDesc	:= "" 
Local cCampo	:= ""
Default cField := 'GZA->GZA_SETOR'
cCampo := &(cField)
cCodLoc	:= POSICIONE("GYT",1,XFILIAL("GYT")+cCampo,"GYT_LOCALI")
cDesc		:= POSICIONE("GI1",1,XFILIAL("GI1")+ cCodLoc  ,"GI1_DESCRI") 

Return cDesc

