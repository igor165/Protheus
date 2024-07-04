#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA600C.CH" 
//------------------------------------------------------------------------------
/*/	{Protheus.doc} FATA600c

Historico de revisões da Proposta Comercial.

@sample	FATA600C()

@param		Nenhum

@return	ExpL - Verdadeiro / Falso

@author	Renato Cunha
@since		05/04/2017
@version	12
/*/
//------------------------------------------------------------------------------
Function FATA600C(cFilter)
Local aArea		    := GetArea()
Local oMBrowse	    := Nil
Local aStatusClr    := {}
Local nX            := 0
Private cCadastro	:= STR0001 //"Histórico da Proposta Comercial"   
Private aRotina     := MenuDef() 	
Default cFilter		:= ""
aStatusClr := {	{'AGP->AGP_STATUS=="A"', 'BR_VERDE'		,STR0002    	},;	    //"Proposta em aberto"
		        {'AGP->AGP_STATUS=="B"', 'BR_VERMELHO'	,STR0003      	},;		//"Proposta fechada"
		        {'AGP->AGP_STATUS=="C"', 'BR_PRETO'		,STR0004    	},;		//"Proposta cancelada"
	    	    {'AGP->AGP_STATUS=="D"', 'BR_AMARELO'	,STR0005 		},;		//"Proposta não aprovada"
		        {'AGP->AGP_STATUS=="F"', 'BR_MARROM'	,STR0006	    } }		//"Proposta bloqueada"

//Browse Instance
oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("AGP") 
oMBrowse:SetMenuDef("FATA600C")
oMBrowse:SetDescription(STR0007) //"Histórico da Revisão de Proposta"

//Add Status 
For nX := 1 To Len(aStatusClr)
	oMBrowse:AddLegend(aStatusClr[nX][1],aStatusClr[nX][2],aStatusClr[nX][3])
Next nX

//Apply Browse Filters
If !Empty(cFilter)
	oMBrowse:SetFilterDefault(cFilter)
EndIf

oMBrowse:Activate()
	 
RestArea(aArea)

Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Modeldef

Modelo de dados da revisão da Proposta.

@sample	ModelDef() 

@param		Nenhum

@return	ExpO - Objeto MPFormModel

@author	Renato Cunha
@since		05/04/2017
@version	12
/*/ 
//------------------------------------------------------------------------------
Static Function Modeldef()
Local oModel 	 	:= Nil
Local oMdlCalc 		:= Nil
Local nTamTot		:= TamSX3('ADZ_TOTAL')[1]		
Local nDecTot		:= TamSX3('ADZ_TOTAL')[2]		

Local oStructAGP	:= FWFormStruct(1,"AGP")	
Local oStrADZPro    := FWFormStruct(1,"ADZ")
Local oStrADZAce    := FWFormStruct(1,"ADZ")

Local bLoadCro		:= {|oModel	|    F600cLChro( oModel )   }
Local bLoadProd	    := {|oMdlADZ|    F600cLdADZ(oMdlADZ) 	}	
Local bActive	    := {|oModel	|    Ft600MdlAct(oModel) 	}	

//Instance Model
oModel := MPFormModel():New("FATA600C")
oModel:SetDescription("Histórico da Proposta de Venda") 
//Instance Header
oModel:AddFields('AGPMASTER',/*cOwner*/,oStructAGP)

//Instance Gri01 Products
oModel:addGrid('ADZPRODUTO','AGPMASTER',oStrADZPro,{|oModel,nLine,cAction,cField| Ft600LinePre(oModel,nLine,cAction,cField,1)},/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,  bLoadProd  )

//Instance Grid02 Acessory
oModel:addGrid('ADZACESSOR','AGPMASTER',oStrADZAce,{|oModel,nLine,cAction,cField| Ft600LinePre(oModel,nLine,cAction,cField,2)},/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*bLoadFunc*/)

oModel:GetModel('AGPMASTER' ):SetDescription(STR0008)	//"Cabeçalho da Proposta"
oModel:GetModel('ADZPRODUTO'):SetDescription(STR0009)	//"Produto" 
oModel:GetModel('ADZACESSOR'):SetDescription(STR0010)	//'Acessorio'

oModel:GetModel( "ADZPRODUTO" ):SetUseOldGrid( .T. )
oModel:GetModel( "ADZACESSOR" ):SetUseOldGrid( .T. )
oModel:GetModel("ADZACESSOR"  ):SetOptional(.T.)

oModel:SetRelation('ADZPRODUTO',{{'ADZ_FILIAL','xFilial("ADZ")'},{"ADZ_PROPOS","AGP_PROPOS"},{"ADZ_REVISA","AGP_PREVIS"},{"ADZ_FOLDER","'1'"}},ADZ->( IndexKey(3)))
oModel:SetRelation('ADZACESSOR',{{'ADZ_FILIAL','xFilial("ADZ")'},{"ADZ_PROPOS","AGP_PROPOS"},{"ADZ_REVISA","AGP_PREVIS"},{"ADZ_FOLDER","'2'"}},ADZ->( IndexKey(3)))

// Total
//-- Products
oModel:AddCalc( 'CALC', 'AGPMASTER', 'ADZPRODUTO', 'ADZ_TOTAL', 'ADZ__TOTPRD', 'SUM', {||.T.}, /*bInitValue*/,STR0011 , /*bFormula*/) // 'Total Geral de Produto'  
//-- Acessory
oModel:AddCalc( 'CALC', 'AGPMASTER', 'ADZACESSOR', 'ADZ_TOTAL', 'ADZ__TOTACE', 'SUM', {||.T.}, /*bInitValue*/,STR0012, /*bFormula*/) // 'Total Geral de Acessorio'
//-- Proposal
oModel:AddCalc('CALC','AGPMASTER',"ADZPRODUTO","ADZ_TOTAL","ADZ__TOTPRO","FORMULA",{|| .T. },/*bInitValue*/,STR0013,{|oModel| oModel:GetValue("CALC",'ADZ__TOTPRD')+oModel:GetValue("CALC",'ADZ__TOTACE') },nTamTot,nDecTot) // "( A+B )"#"Total Geral da Proposta"

Return( oModel )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Viewdef

Interface da revisão de Proposta Comercial.

@sample	ViewDef()

@param		Nenhum

@return	ExpO - Objeto FWFormView

@author	Renato Cunha
@since		05/04/2017
@version	12
/*/
//------------------------------------------------------------------------------
Static Function Viewdef()
Local oView         
Local oModel		:= FwLoadModel("FATA600C")
Local oStrAGP		:= FWFormStruct(2, 'AGP')
Local oStrADZPro	:= FWFormStruct(2, 'ADZ')
Local oStrADZAce	:= FWFormStruct(2, 'ADZ')
Local oStr4			:= FWCalcStruct( oModel:GetModel('CALC') )
Local aCOTot		:= {}
Local aCombos		:= F600cCombo() 
Local cConpad		:= F600CConpd()	

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('FORM1', oStrAGP     ,'AGPMASTER'    )
oView:AddField('FORM9', oStr4		,'CALC'			)

oView:AddGrid('Produt', oStrADZPro  ,'ADZPRODUTO'   )
oView:AddGrid('Acess' , oStrADZAce  ,'ADZACESSOR'   )

oView:CreateHorizontalBox( 'BOXFORM1'	, 50)
oView:CreateHorizontalBox( 'MIDDLE'		, 34)

oView:CreateFolder('ABAS','MIDDLE') 

oView:AddSheet( 'ABAS', 'ABA01', STR0014	)	
oView:AddSheet( 'ABAS', 'ABA02', STR0015	)	

oView:CreateHorizontalBox( 'ID_ABA01' 	, 100,,, 'ABAS', 'ABA01'	)
oView:CreateHorizontalBox( 'ID_ABA02' 	, 100,,, 'ABAS', 'ABA02'	)
oView:CreateHorizontalBox( 'BOXFORM9'	, 16						)

oView:SetOwnerView('FORM9'	,'BOXFORM9'		)
oView:SetOwnerView('FORM1'	,'BOXFORM1'		)
oView:SetOwnerView( 'Produt', 'ID_ABA01'	)
oView:SetOwnerView( 'Acess' , 'ID_ABA02'	)

oView:AddIncrementField('Acess' 	, 'ADZ_ITEM' 	)
oView:AddIncrementField('Produt'	, 'ADZ_ITEM' 	)

oStrAGP:SetProperty("AGP_ENTIDA", MVC_VIEW_COMBOBOX,aCombos 	)
oStrAGP:SetProperty("AGP_TABELA", MVC_VIEW_LOOKUP,"DA0" 		)
oStrAGP:SetProperty("AGP_CODIGO", MVC_VIEW_LOOKUP,cConpad 		)
oStrAGP:SetProperty("AGP_CLIENT", MVC_VIEW_LOOKUP,"SA1" 		)

Return( oView )

//------------------------------------------------------------------------------
/*/ {Protheus.doc} MenuDef

MenuDef do Historico da Proposta Comercial.

@sample	MenuDef()

@param		Nenhum

@return	ExpA - Rotinas CRUD / Acoes Relacionadas

@author	Renato Cunha
@since		05/043/2017 
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function MenuDef() 

Local aRotina := {} 		// Variavel a rotina.                      

ADD OPTION aRotina TITLE STR0016	ACTION "PesqBrw"			OPERATION 1 ACCESS 0  // "Pesquisar"
ADD OPTION aRotina TITLE STR0017	ACTION "VIEWDEF.FATA600C"	OPERATION 2 ACCESS 0  // "Visualizar"

Return( aRotina )

//------------------------------------------------------------------------------
/*/ {Protheus.doc} F600cLdADZ()

Faz a carga dos produtos da Revisão posicionada.

@sample	Ft600cLoad()

@param		Nenhum

@return	ExpA - Dados dos produtos da proposta na revisão posicionada.

@author	Renato Cunha
@since		05/04/2017 
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function F600cLdADZ( oMdlADZ )
Local oStructADZ := oMdlADZ:GetStruct()
Local aCampos    := oStructADZ:GetFields()
Local aLoadADZ   := {}
Local nY 		 := 0 
Local nRecnum	 := 0
Local cMacro     := ""
Local cPropos	 := AGP->AGP_PROPOS 
Local cRevisa	 := AGP->AGP_PREVIS

ADZ->(dbSetOrder(3))
If ADZ->(dbSeek(xFilial("ADZ")+cPropos+cRevisa))
	
	WHile ADZ->(!Eof()) .And. ADZ->(ADZ_FILIAL+ADZ_PROPOS+ADZ_REVISA) == xFilial("ADZ")+cPropos+cRevisa
	
		If ADZ->ADZ_FOLDER == '1'
			nRecNum := ADZ->(Recno())
			aAdd(aLoadADZ,{nRecNum ,{} })	
		
			For nY := 1 To Len(aCampos)	

				If !aCampos[nY][MODEL_FIELD_VIRTUAL]
					cMacro := "ADZ->"+ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
				Else
					cMacro := AllTrim(aCampos[nY][MODEL_FIELD_INIT])
				EndIf

				aAdd(aLoadADZ[Len(aLoadADZ),2] , &cMacro )

			Next nY
		EndIf
		
		ADZ->(dbSkip())
	EndDo	

EndIf
Return( aLoadADZ )

//------------------------------------------------------------------------------
/*/ {Protheus.doc} Ft600cLChr()

Carrega os dados do Cronograma Financeiro

@sample	Ft600cLChr()

@param		Nenhum

@return	ExpA - Dados da condição de pagamento.

@author	Renato Cunha
@since		06/04/2017 
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function F600cLChro( oModel )
Local aLoadChron	:= {}
Local nOpertation	:= 1

If !Empty( oModel )
	nOpertation := oModel:GetOperation()
	If nOpertation == MODEL_OPERATION_VIEW .OR. nOperation == MODEL_OPERATION_DELETE
		A600CroFinance(oModel,/*lLoad*/,@aLoadChron)
	EndIf
EndIf

Return( aLoadChron )

//------------------------------------------------------------------------------
/*/ {Protheus.doc} F600cCombo()

Carrega propriedades X3 de um campo

@sample	F600cCombo("ADY", "X3_CBOX")

@param		cField 		Campo para pesquisa
			cX3Field	Campo do SX3
@return	ExpA - Propriedade do SX3.

@author	Renato Cunha
@since		06/04/2017 
@version	12             
/*/
//------------------------------------------------------------------------------
Static Function F600cCombo(cField, cX3Field)
Local aCombo		:= {}
Local cCombo		:= ""
Default cField 		:= "ADY_ENTIDA"
Default cX3Field	:= "X3_CBOX"

cCombo 	:= GetSX3Cache(cField, cX3Field)

If !Empty(cCombo)
	aCombo := StrToArray(cCombo,";")
EndIf

Return( aCombo )

//------------------------------------------------------------------------------
/*/ {Protheus.doc} F600CConpd()

Retorna o tipo de consulta padrão conforme entidade

@sample	F600CConpd()

@param		Nil
@return	ExpC - Consulta padrão .

@author	Renato Cunha
@since		07/04/2017 
@version	12             
/*/
//------------------------------------------------------------------------------
 Static Function F600CConpd()
 Local cConpad	:= ''
 Local cEntity	:= AGP->AGP_ENTIDA

 If !Empty( cEntity )
 	Do Case
	 	Case cEntity == '1'
		 	cConpad := 'SA1'
		
		Case cEntity == '2'
			cConpad := 'SUS'

	EndCase
 EndIf

Return( cConpad )