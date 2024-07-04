#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA600.CH'

Static lHasNewFields	:= .F.
Static aNewFields		:= {}
Static aViagem			:= {} //interessa o conteúdo a partir da segunda linha

/*/{Protheus.doc} GTPA600
Orçamento de Viagem
@type function
@author jacomo.fernandes
@since 22/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA600()
Local oBrowse		:= Nil	

oBrowse := FWMBrowse():New()

oBrowse:SetAlias('G6R')
oBrowse:SetDescription("Orçamento de viagem")

oBrowse:AddLegend("G6R_STATUS == '1'", "WHITE", "Aberto" ) 
oBrowse:AddLegend("G6R_STATUS == '2'", "GREEN", "Ganho"  ) 
oBrowse:AddLegend("G6R_STATUS == '3'", "RED"	, "Perdido") 
oBrowse:AddLegend("G6R_STATUS == '4'", "BLUE"	, "Reaberto") 

oBrowse:Activate()

Return ( oBrowse )

/*/{Protheus.doc} MenuDef
Definição do Menu

@type function
@author jacomo.fernandes
@since 22/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}
		
ADD OPTION aRotina TITLE "Visualizar"	 ACTION 'VIEWDEF.GTPA600' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE "Incluir"		 ACTION 'VIEWDEF.GTPA600' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE "Alterar"		 ACTION 'VIEWDEF.GTPA600' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE "Copiar" 		 ACTION 'Ga600Cpy()'      OPERATION 9 ACCESS 0 // "Copiar"
ADD OPTION aRotina TITLE "Excluir"		 ACTION 'VIEWDEF.GTPA600' OPERATION 5 ACCESS 0 // Excluir
ADD OPTION aRotina TITLE "Imp. Contrato" ACTION 'GTPX600R'		  OPERATION 8 ACCESS 0 // Imprime contrato
//ADD OPTION aRotina TITLE "Alt Dt Viagem" ACTION 'GTPA600A'		  OPERATION 4 ACCESS 0 // "Alt Dt Viagem"	
ADD OPTION aRotina TITLE "Fechamento Contrato" ACTION 'GTPA600B()'  OPERATION 4 ACCESS 0 // ""	
ADD OPTION aRotina TITLE "Ajuste de KM Realizado" ACTION 'GA600AJKM()'  		OPERATION 4 ACCESS 0 // ""	
	
Return aRotina

/*/{Protheus.doc} ModelDef
(long_description)
@type function
@author jacomo.fernandes
@since 17/07/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()

	Local oModel	:= Nil	
	Local oStruCab	:= FWFormStruct(1, "G6R") 
	Local oStruG6S	:= FWFormStruct(1, "G6S")
	Local oStruG5C	:= FWFormStruct(1, "G5C")
	Local oStruG9C	:= FWFormStruct(1, "G9C")
	Local oStruG9CB	:= FWFormStruct(1, "G9C")
	
	Local bPosVld   := {|oMdl|Ga600PosVld(oMdl)}
	Local bCommit   := {|oMdl| Ga600Commit(oMdl)}
	Local bPreLin   := {|oModel, nLine, cAction, cField| GA600PRLIN(oModel,nLine,cAction,cField)}
	Local bVldAct   := {|oModel| GA600VldAct(oModel)}

	SetModelStruct(oStruCab,oStruG6S,oStruG5C,oStruG9C)

	oModel := MPFormModel():New("GTPA600",, bPosVld, /*bCommit*/)
	oModel:SetCommit(bCommit)

	oModel:AddFields("MASTER"  , /*cOwner*/, oStruCab)
	oModel:AddGrid("G6SDETAIL" , "MASTER"  , oStruG6S , bPreLin)
	oModel:AddGrid("G5CDETAIL" , "MASTER"  , oStruG5C , bPreLin)
	oModel:AddGrid("G9CDETAIL" , "MASTER"  , oStruG9C , bPreLin)
	oModel:AddGrid("G9CBDETAIL", "MASTER"  , oStruG9CB, bPreLin)

	oModel:SetRelation("G6SDETAIL",{{"G6S_FILIAL" , "xFilial('G6S')"}, {"G6S_CODIGO", "G6R_CODIGO"}},G6S->(IndexKey(1))) //G6S_FILIAL+G6S_CODIGO+G6S_ITEM
	oModel:SetRelation("G5CDETAIL",{{"G5C_FILIAL" , "xFilial('G5C')"}, {"G5C_CODIGO", "G6R_CODIGO"}},G5C->(IndexKey(1)))
	oModel:SetRelation("G9CDETAIL",{{"G9C_FILIAL" , "xFilial('G9C')"}, {"G9C_CODIGO", "G6R_CODIGO"}},G9C->(IndexKey(1)))
	oModel:SetRelation("G9CBDETAIL",{{"G9C_FILIAL", "xFilial('G9C')"}, {"G9C_CODIGO", "G6R_CODIGO"}},G9C->(IndexKey(1)))

	oModel:SetOptional("G6SDETAIL", .T. )
	oModel:SetOptional("G9CBDETAIL", .T. )

	oModel:GetModel('G9CDETAIL'):SetNoInsertLine( .T. )
	oModel:GetModel('G9CDETAIL'):SetNoDeleteLine( .T. )

	oModel:GetModel('G6SDETAIL'):SetUniqueLine( { "G6S_CUSTO"})

	oModel:GetModel('G9CDETAIL'):SetOnlyQuery(.t.)

	oModel:SetVldActivate(bVldAct)

Return oModel

/*/{Protheus.doc} SetModelStruct
(long_description)
@type function
@author jacomo.fernandes
@since 17/07/2018
@version 1.0
@param oStruCab, objeto, (Descrição do parâmetro)
@param oStruG6S, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetModelStruct(oStruCab,oStruG6S,oStruG5C,oStruG9C)
Local aArea		:= GetArea()
Local bTrig		:= {|oMdl,cField,xVal|GTPA600TRG(oMdl,cField,xVal)}
Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue|GTPA600Vld(oMdl,cField,cNewValue,cOldValue) }

IF ValType(oStruCab) == "O" 
	
	/*--------------------------------------------------------*\
	| Seção responsavel para setar os inicializadores padrões
	\*--------------------------------------------------------*/	
	oStruCab:SetProperty("G6R_CODIGO"	,MODEL_FIELD_INIT,{|| GTPXENUM("G6R","G6R_CODIGO")})
	oStruCab:SetProperty("G6R_TOTHR"	,MODEL_FIELD_INIT,{|| "0000"})
	oStruCab:SetProperty("G6R_HRIDA"	,MODEL_FIELD_INIT,{|| ""})
	oStruCab:SetProperty("G6R_HRVLTA"	,MODEL_FIELD_INIT,{|| ""})
	oStruCab:SetProperty("G6R_SA3COD"	,MODEL_FIELD_INIT,{||Ft300Vend(.T.)	}) //Retorna o vendedor conforme usuário logado
	oStruCab:SetProperty("G6R_SA3DES"	,MODEL_FIELD_INIT,{|oMdl| Posicione('SA3',1,xFilial('SA3')+If(!Empty(oMdl:GetValue('G6R_SA3COD')),oMdl:GetValue('G6R_SA3COD'),G6R->G6R_SA3COD ),"A3_NOME")  }) //Retorna o vendedor conforme usuário logado
	
	
	/*--------------------------------------------------------*\
	| Seção responsavel para setar as validações de When
	\*--------------------------------------------------------*/	
	
	oStruCab:SetProperty('G6R_LOCDES', MODEL_FIELD_WHEN,{|oMdl| FwIsInCallStack('RUNTRIGGER') .or. !Empty(oMdl:GetValue('G6R_LOCORI') ) })
	oStruCab:SetProperty('G6R_SA1COD', MODEL_FIELD_WHEN,{|oMdl|  Empty(oMdl:GetValue('G6R_NROPOR') ) })
	oStruCab:SetProperty('G6R_SA1LOJ', MODEL_FIELD_WHEN,{|oMdl|  Empty(oMdl:GetValue('G6R_NROPOR') ) })	
	oStruCab:SetProperty('G6R_SUSCOD', MODEL_FIELD_WHEN,{|oMdl|  Empty(oMdl:GetValue('G6R_NROPOR') ) })
	oStruCab:SetProperty('G6R_SUSLOJ', MODEL_FIELD_WHEN,{|oMdl|  Empty(oMdl:GetValue('G6R_NROPOR') ) })
	
	/*--------------------------------------------------------*\
	| Seção responsavel para setar as validações dos campos
	\*--------------------------------------------------------*/	
	oStruCab:SetProperty('G6R_PRODUT'	, MODEL_FIELD_VALID		,bFldVld)
	oStruCab:SetProperty('G6R_TOTHR'	, MODEL_FIELD_VALID		,bFldVld)
	oStruCab:SetProperty('G6R_DTIDA'	, MODEL_FIELD_VALID		,bFldVld)
	oStruCab:SetProperty('G6R_HRIDA'	, MODEL_FIELD_VALID		,bFldVld)
	oStruCab:SetProperty('G6R_DTVLTA'	, MODEL_FIELD_VALID		,bFldVld)
	oStruCab:SetProperty('G6R_HRVLTA'	, MODEL_FIELD_VALID		,bFldVld)
	oStruCab:SetProperty('G6R_VALACO'	, MODEL_FIELD_VALID		,bFldVld)
	oStruCab:SetProperty('G6R_SA3COD'	, MODEL_FIELD_VALID		,bFldVld)  
	oStruCab:SetProperty('G6R_SA1COD'	, MODEL_FIELD_VALID		,bFldVld)  
	oStruCab:SetProperty('G6R_SA1LOJ'	, MODEL_FIELD_VALID		,bFldVld)  
	oStruCab:SetProperty('G6R_SUSCOD'	, MODEL_FIELD_VALID		,bFldVld)  
	oStruCab:SetProperty('G6R_SUSLOJ'	, MODEL_FIELD_VALID		,bFldVld) 

	/*--------------------------------------------------------*\
	| Seção responsavel para setar os gatilhos dos campos
	\*--------------------------------------------------------*/	
	
	oStruCab:AddTrigger("G6R_PRODUT"	,"G6R_PRODUT"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_CODBEM"	,"G6R_CODBEM"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_PEDESC"	,"G6R_PEDESC"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_VLDESC"	,"G6R_VLDESC"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_LOCORI"	,"G6R_LOCORI"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_LOCDES"	,"G6R_LOCDES"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_VALTOT"	,"G6R_VALTOT"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_SA3COD"	,"G6R_SA3COD"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_SA1COD"	,"G6R_SA1COD"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_SA1LOJ"	,"G6R_SA1LOJ"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_SUSCOD"	,"G6R_SUSCOD"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_SUSLOJ"	,"G6R_SUSLOJ"			,{||.T.},bTrig)
	
	oStruCab:AddTrigger("G6R_DTIDA"		,"G6R_DTIDA"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_HRIDA"		,"G6R_HRIDA"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_DTVLTA"	,"G6R_DTVLTA"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_HRVLTA"	,"G6R_HRVLTA"			,{||.T.},bTrig)
	oStruCab:AddTrigger("G6R_TIPITI"	,"G6R_TIPITI"			,{||.T.},bTrig)
	If G6R->(FieldPos("G6R_EIXOS")) > 0
		oStruCab:AddTrigger("G6R_EIXOS"		,"G6R_EIXOS"			,{||.T.},bTrig)
	EndIf
	
Endif


IF ValType(oStruG6S) == "O" 

	oStruG6S:SetProperty('G6S_CUSUNI', MODEL_FIELD_WHEN,{|oMdl| FwIsInCallStack('GA600CALC') .or. (oMdl:GetValue('G6S_FORMUL') == '2' .AND. !Empty(oMdl:GetValue('G6S_CUSTO'))) })
	oStruG6S:SetProperty('G6S_UM'    , MODEL_FIELD_WHEN,{|oMdl| FwIsInCallStack('GA600CALC') .or. (oMdl:GetValue('G6S_FORMUL') == '2' .AND. !Empty(oMdl:GetValue('G6S_CUSTO'))) })
	oStruG6S:SetProperty('G6S_DESUM' , MODEL_FIELD_WHEN,{|oMdl| FwIsInCallStack('GA600CALC') .or. (oMdl:GetValue('G6S_FORMUL') == '2' .AND. !Empty(oMdl:GetValue('G6S_CUSTO'))) })
	oStruG6S:SetProperty('G6S_QUANT' , MODEL_FIELD_WHEN,{|oMdl| FwIsInCallStack('GA600CALC') .or. (oMdl:GetValue('G6S_FORMUL') == '2' .AND. !Empty(oMdl:GetValue('G6S_CUSTO'))) })
	
	oStruG6S:SetProperty('G6S_CUSTO', MODEL_FIELD_VALID,bFldVld)
	
	oStruG6S:AddTrigger("G6S_QUANT" , "G6S_QUANT" , {||.T.}, bTrig)
	oStruG6S:AddTrigger("G6S_VALTOT", "G6S_VALTOT", {||.T.}, bTrig)
	oStruG6S:AddTrigger("G6S_CUSUNI", "G6S_CUSUNI", {||.T.}, bTrig)
	oStruG6S:AddTrigger("G6S_UM"    , "G6S_UM"    , {||.T.}, bTrig)
	oStruG6S:AddTrigger("G6S_CUSTO" , "G6S_CUSTO" , {||.T.}, bTrig)

Endif

If ValType(oStruG5C) == "O"

	oStruG5C:AddField(	" ",'SOBE'	,"G5C_SOBE"		,"BT",15,0,Nil,Nil,Nil,.F.,{||"PARACIMA"},.F.,.F.,.T.)
	oStruG5C:AddField(	" ",'DESCE'	,"G5C_DESCE"	,"BT",15,0,Nil,Nil,Nil,.F.,{||"PARABAIXO"},.F.,.F.,.T.)
	
	oStruG5C:AddTrigger("G5C_CODORI" , "G5C_CODORI" , {||.T.}, bTrig)
	
	oStruG5C:SetProperty('G5C_CODORI' , MODEL_FIELD_WHEN,{|oMdl| FwIsInCallStack('RUNTRIGGER') .or. (oMdl:GetValue('G5C_TIPLOC') == '3' ) })
	
Endif

If ValType(oStruG9C) == "O"
	
	oStruG9C:SetProperty('G9C_DTORIG', MODEL_FIELD_VALID,bFldVld)
	oStruG9C:SetProperty('G9C_HRORIG', MODEL_FIELD_VALID,bFldVld)
	oStruG9C:SetProperty('G9C_DTDEST', MODEL_FIELD_VALID,bFldVld)
	oStruG9C:SetProperty('G9C_HRDEST', MODEL_FIELD_VALID,bFldVld)

	oStruG9C:AddTrigger("G9C_CODORI" , "G9C_CODORI" , {||.T.}, bTrig)
	oStruG9C:AddTrigger("G9C_CODDES" , "G9C_CODDES" , {||.T.}, bTrig)
	oStruG9C:AddTrigger("G9C_DTDEST" , "G9C_DTDEST" , {||.T.}, bTrig)
	oStruG9C:AddTrigger("G9C_HRDEST" , "G9C_HRDEST" , {||.T.}, bTrig)
	
	oStruG9C:SetProperty('G9C_DTORIG', MODEL_FIELD_WHEN,{|oMdl| FwIsInCallStack('RUNTRIGGER') .or. oMdl:GetLine() == 1 })
	oStruG9C:SetProperty('G9C_HRORIG', MODEL_FIELD_WHEN,{|oMdl| FwIsInCallStack('RUNTRIGGER') .or. oMdl:GetLine() == 1 })
	
Endif

RestArea(aArea)
GTPDestroy(aArea)

Return

/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author jacomo.fernandes
@since 17/07/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()

Local oView		:= nil
Local oModel	:= FwLoadModel('GTPA600')
Local oStruCab	:= FWFormStruct( 2, "G6R")//FWFormViewStruct():New()
Local oStruG6S	:= FWFormStruct( 2, "G6S")
Local oStruG5C	:= FWFormStruct( 2, "G5C")
Local oStruG9C	:= FWFormStruct( 2, "G9C")

SetViewStruct(oStruCab,oStruG6S,oStruG5C,oStruG9C)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_G6R"	, oStruCab, 'MASTER')
oView:AddGrid("VIEW_G6S"	, oStruG6S, 'G6SDETAIL')

oView:AddGrid("VIEW_G5C"	, oStruG5C, 'G5CDETAIL')
oView:AddGrid("VIEW_G9C"	, oStruG9C, 'G9CDETAIL')

// Divisào Horizontal
oView:CreateHorizontalBox("TOP",65)
oView:CreateHorizontalBox("BOTTOM",35)

oView:CreateFolder('PASTAS','BOTTOM')

oView:AddSheet('PASTAS','ABACUSTOS',"Custos")
oView:CreateHorizontalBox('VIEW_ABACUSTOS',100,,,'PASTAS', 'ABACUSTOS' )

oView:AddSheet('PASTAS','ABAPERCURSO',"Percurso")//Percurso
//oView:CreateHorizontalBox('VIEW_ABAPERCURSO',100,,,'PASTAS', 'ABAPERCURSO' )

oView:CreateVerticalBox( 'VIEW_BOX_G5C', 30, , , 'PASTAS', 'ABAPERCURSO')
oView:CreateVerticalBox( 'VIEW_BOX_G9C', 70, , , 'PASTAS', 'ABAPERCURSO')

oView:SetOwnerView("VIEW_G6R", "TOP")
oView:SetOwnerView("VIEW_G6S", "VIEW_ABACUSTOS")
oView:SetOwnerView("VIEW_G5C", "VIEW_BOX_G5C")
oView:SetOwnerView("VIEW_G9C", "VIEW_BOX_G9C")

oView:AddIncrementField("G6SDETAIL","G6S_ITEM")
oView:AddIncrementField("G5CDETAIL","G5C_SEQ" )
oView:AddIncrementField("G9CDETAIL","G9C_SEQ" )

oView:SetViewProperty("VIEW_G5C", "GRIDDOUBLECLICK", {{|oGrid,cField,nLineGrid,nLineModel| Ga600DbClk(oGrid,cField,nLineGrid,nLineModel)}})

//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView("MASTER")
//oView:EnableTitleView("G6SDETAIL")

oView:AddUserButton( "Calc Custo", "", {|| GA600Calc(oView)},,VK_F5 ) //"Executar Filtro" //"Calc Custo"

Return oView

/*/{Protheus.doc} SetViewStruct
(long_description)
@type function
@author jacomo.fernandes
@since 20/07/2018
@version 1.0
@param oStruCab, objeto, (Descrição do parâmetro)
@param oStruG6S, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStruCab,oStruG6S,oStruG5C,oStruG9C)

	Local aArea		:= GetArea()

	IF ValType(oStruCab) == "O" 
		
		oStruCab:RemoveField("G6R_CODIGO") 
		oStruCab:RemoveField("G6R_NROPOR")
		oStruCab:RemoveField("G6R_OPOREV") 
		oStruCab:RemoveField("G6R_PROPOS")
		oStruCab:RemoveField("G6R_PROREV") 
		oStruCab:RemoveField("G6R_STATUS")
		
		//Incluído por Fernando Radu Muscalu em 28/01/2022 - issue: DSERGTP-7341
		oStruCab:RemoveField("G6R_NROPOR")
		oStruCab:RemoveField("G6R_PROPOS")
		oStruCab:RemoveField("G6R_OPOREV")
		oStruCab:RemoveField("G6R_PROREV")
		oStruCab:RemoveField("G6R_PROCES")
		oStruCab:RemoveField("G6R_ESTAGI")
		oStruCab:RemoveField("G6R_SUSCOD")
		oStruCab:RemoveField("G6R_SUSLOJ")
		
		If ( G600ChkNFlds() )

			oStruCab:RemoveField("G6R_FCS") 
			oStruCab:RemoveField("G6R_DESFCS")
			oStruCab:RemoveField("G6R_FCI")
			oStruCab:RemoveField("G6R_DESFCI")
			oStruCab:RemoveField("G6R_STATUS")
			oStruCab:RemoveField("G6R_DTASSI")
			oStruCab:RemoveField("G6R_CNTPRO")
			oStruCab:RemoveField("G6R_NOMCNT")
			oStruCab:RemoveField("G6R_USRASS")
			oStruCab:RemoveField("G6R_DSCUSR")
			oStruCab:RemoveField("G6R_JUSTIF")
			oStruCab:RemoveField("G6R_PEDIDO")
		
		Endif

		oStruCab:SetProperty('G6R_TIPITI', MVC_VIEW_ORDEM, '37')
		
		//-------------------------------------------------------------------
		oStruCab:AddGroup('GRP001', ''						,'', 2)
		
		oStruCab:SetProperty( 'G6R_PRODUT'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
		oStruCab:SetProperty( 'G6R_DESPRO'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
		oStruCab:SetProperty( 'G6R_PEDESC'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
		oStruCab:SetProperty( 'G6R_VLDESC'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
		oStruCab:SetProperty( 'G6R_VALTOT'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
		oStruCab:SetProperty( 'G6R_VALACO'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
		
		//-------------------------------------------------------------------
		oStruCab:AddGroup('GRP002', 'Dados da Oportunidade'	,'', 2) 
		
		oStruCab:SetProperty( 'G6R_SA3COD'	, MVC_VIEW_GROUP_NUMBER, 'GRP002') 
		oStruCab:SetProperty( 'G6R_SA3DES'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
		oStruCab:SetProperty( 'G6R_DESCRI'	, MVC_VIEW_GROUP_NUMBER, 'GRP002') 
		oStruCab:SetProperty( 'G6R_DTINCL'	, MVC_VIEW_GROUP_NUMBER, 'GRP002') 
		
		oStruCab:SetProperty( 'G6R_TABELA'	, MVC_VIEW_GROUP_NUMBER, 'GRP002') 
		oStruCab:SetProperty( 'G6R_CONDPG'	, MVC_VIEW_GROUP_NUMBER, 'GRP002') 
		oStruCab:SetProperty( 'G6R_TES'		, MVC_VIEW_GROUP_NUMBER, 'GRP002') 
		
		//-------------------------------------------------------------------
		oStruCab:AddGroup('GRP003', 'Dados do Cliente'		,'', 2) 
		
		oStruCab:SetProperty( 'G6R_SA1COD'	, MVC_VIEW_GROUP_NUMBER, 'GRP003')
		oStruCab:SetProperty( 'G6R_SA1LOJ'	, MVC_VIEW_GROUP_NUMBER, 'GRP003')
		oStruCab:SetProperty( 'G6R_NMCLNT'	, MVC_VIEW_GROUP_NUMBER, 'GRP003')
		oStruCab:SetProperty( 'G6R_DDD'		, MVC_VIEW_GROUP_NUMBER, 'GRP003')
		oStruCab:SetProperty( 'G6R_TEL'		, MVC_VIEW_GROUP_NUMBER, 'GRP003')
		
			//-------------------------------------------------------------------
		oStruCab:AddGroup('GRP004', 'Itinerário'		,'', 2)
		
		oStruCab:SetProperty( 'G6R_TIPITI'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_DTIDA'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_HRIDA'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_LOCORI'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_DESORI'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_ENDEMB'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_DTVLTA'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_HRVLTA'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_LOCDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_DESDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')
		oStruCab:SetProperty( 'G6R_ENDDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP004')

		//-------------------------------------------------------------------
		oStruCab:AddGroup('GRP005', 'Dados do Veiculo'		,'', 2)
		
		oStruCab:SetProperty( 'G6R_CODBEM'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')
		oStruCab:SetProperty( 'G6R_NOMBEM'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')
		oStruCab:SetProperty( 'G6R_QUANT'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')
		oStruCab:SetProperty( 'G6R_KMCONT'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')
		oStruCab:SetProperty( 'G6R_KMEXCE'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')
		oStruCab:SetProperty( 'G6R_POLTR'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')
		If G6R->(FieldPos("G6R_EIXOS")) > 0
			oStruCab:SetProperty( 'G6R_EIXOS'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')
			oStruCab:SetProperty( 'G6R_EIXOS'	, MVC_VIEW_ORDEM , '35' )
		EndIf
		oStruCab:SetProperty( 'G6R_PDTOT'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')
		oStruCab:SetProperty( 'G6R_TOTHR'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')
		oStruCab:SetProperty( 'G6R_DISPVE'	, MVC_VIEW_GROUP_NUMBER, 'GRP005')

		
		//-------------------------------------------------------------------
		oStruCab:AddGroup('GRP006', 'Despesas Motorista'		,'', 2) 
		
		oStruCab:SetProperty( 'G6R_DESPPG'	, MVC_VIEW_GROUP_NUMBER, 'GRP006')
		oStruCab:SetProperty( 'G6R_REFEIC'	, MVC_VIEW_GROUP_NUMBER, 'GRP006')
		oStruCab:SetProperty( 'G6R_PERNOI'	, MVC_VIEW_GROUP_NUMBER, 'GRP006')
		oStruCab:SetProperty( 'G6R_ESTACI'	, MVC_VIEW_GROUP_NUMBER, 'GRP006')
		
	Endif

	IF ValType(oStruG6S) == "O"
		
		oStruG6S:RemoveField("G6S_PLAN")
		
	Endif

	If ValType(oStruG5C) == "O"
		oStruG5C:AddField("G5C_SOBE"	,"01"," ","SOBE",{"SOBE"},"GET","@BMP",NIL,"",.T.,NIL,"",NIL,NIL,NIL,.T.,NIL,.F.)	
		oStruG5C:AddField("G5C_DESCE"	,"01"," ","DESCE",{"DESCE"},"GET","@BMP",NIL,"",.T.,NIL,"",NIL,NIL,NIL,.T.,NIL,.F.)	
		
		
		oStruG5C:RemoveField("G5C_TIPLOC")
		
	Endif


	RestArea(aArea)
	GTPDestroy(aArea)

Return

/*/{Protheus.doc} GTPA600TRG
Função de Gatilhos
@type function
@author jacomo.fernandes
@since 19/07/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@exampl
(examples)
@see (links_or_references)
/*/
Static Function GTPA600TRG(oMdl,cField,xVal)
Local oModel	:= oMdl:GetModel()
Local oMdlCab	:= oModel:GetModel('MASTER')
Local oMdlG6S	:= oModel:GetModel('G6SDETAIL') 
Local oMdlG5C	:= oModel:GetModel('G5CDETAIL') 
Local oMdlG9C	:= oModel:GetModel('G9CDETAIL') 
	Local oView		:= FwViewActive()
Local n1		:= 0
Local nVal		:= 0
Local nTot      := 0
Local nLin      := 0
Local nValTot   := 0
Local nLine     := oMdlG6S:GetLine()
Local cCodOrig  := oMdlCab:GetValue('G6R_LOCORI')
Local cCodDes   := oMdlCab:GetValue('G6R_LOCDES')
Local nTotPed   := 0

Do Case
	/*-----------------------------*\
	|Gatilhos da tabela G6R			|
	\*-----------------------------*/
	Case cField == "G6R_PRODUT"
		If !oMdlG6S:IsEmpty()
			For n1 := 1 to oMdlG6S:Length()
				oMdlG6S:GoLine(n1)
				If !oMdlG6S:IsDeleted(n1)
					oMdlG6S:DeleteLine()
				EndIf
			Next
		EndIf

		TrigGIMPrd(oMdlG6S, xVal)

		For nLin := 1 to oMdlG6S:Length()
			oMdlG6S:GoLine(nLin)
			If !oMdlG6S:IsDeleted(nLin)
				nTot += oMdlG6S:GetValue('G6S_VALTOT', nLin) 
			Endif
		Next

		oMdlG6S:GoLine(1)
		oMdlCab:LoadValue('G6R_DESPRO', Alltrim(Posicione('SB1', 1, xFilial('SB1') + xVal, "B1_DESC")))
		oMdlCab:LoadValue('G6R_VALTOT', nTot)
		oMdlCab:LoadValue('G6R_VALACO', nTot)
		oMdlCab:LoadValue('G6R_PEDESC', 0)
		oMdlCab:LoadValue('G6R_VLDESC', 0)

	Case cField == "G6R_CODBEM"
		oMdlCab:LoadValue('G6R_NOMBEM',Alltrim(Posicione('ST9', 1, xFilial('ST9') + xVal, "T9_NOME")))
		oMdlCab:LoadValue('G6R_POLTR',GetQtdPolt(xVal))
		
		
	Case cField == "G6R_VALTOT"
		oMdlCab:SetValue('G6R_VALACO',xVal)
	
	Case cField == "G6R_PEDESC" 
		nValTot := oMdlCab:GetValue('G6R_VALTOT')

		oMdlG6S:RunTrigger('G6S_VALTOT')

		oMdlCab:LoadValue('G6R_VLDESC', oMdlCab:GetValue('G6R_VALTOT') * (xVal / 100))
		oMdlCab:LoadValue('G6R_VALACO', nValTot - oMdlCab:GetValue('G6R_VALTOT') * (xVal / 100)) 
				
	Case cField == "G6R_VLDESC"
		oMdlCab:SetValue('G6R_VALTOT',oMdlCab:GetValue('G6R_VALTOT') - xVal)
	
	Case cField == "G6R_LOCORI"
		oMdlCab:SetValue('G6R_DESORI',Alltrim(Posicione('GI1', 1, xFilial('GI1') + xVal, "GI1_DESCRI")))

		SetDesc(oMdlCab)
		SetPercurso(oModel, xVal, '1')
		SetTrecho(oModel)

		nTotPed := VlrPedagio(oMdlCab)

		oMdlCab:SetValue('G6R_PDTOT',nTotPed)
	
	Case cField == "G6R_LOCDES"
		oMdlCab:SetValue('G6R_DESDES',Alltrim(Posicione('GI1',1,xFilial('GI1')+xVal,"GI1_DESCRI")))

		SetDesc(oMdlCab)
		SetPercurso(oModel, xVal, '2')
		SetTrecho(oModel)

		nTotPed := VlrPedagio(oMdlCab)	

		oMdlCab:SetValue('G6R_PDTOT',nTotPed)

	Case cField == "G6R_EIXOS"	

		nTotPed := VlrPedagio(oMdlCab)		

		oMdlCab:SetValue('G6R_PDTOT',nTotPed)
	
	Case cField == "G6R_SA3COD"
		oMdlCab:SetValue('G6R_SA3DES',Alltrim(Posicione('SA3',1,xFilial('SA3')+xVal,"A3_NOME")))
	
	Case cField == "G6R_SA1COD"
		oMdlCab:LoadValue('G6R_SUSCOD','')
		oMdlCab:LoadValue('G6R_SUSLOJ','')
		oMdlCab:SetValue('G6R_SA1LOJ',Posicione('SA1',1,xFilial('SA1')+xVal,'A1_LOJA' ))
		
	Case cField == "G6R_SA1LOJ"
		oMdlCab:SetValue('G6R_NMCLNT'	,Posicione('SA1',1,xFilial('SA1')+oMdlCab:GetValue('G6R_SA1COD')+xVal,'A1_NOME' ) )
		oMdlCab:SetValue('G6R_DDD'		,Posicione('SA1',1,xFilial('SA1')+oMdlCab:GetValue('G6R_SA1COD')+xVal,'A1_DDD' ) )
		oMdlCab:SetValue('G6R_TEL'		,Posicione('SA1',1,xFilial('SA1')+oMdlCab:GetValue('G6R_SA1COD')+xVal,'A1_TEL' ) )
	
	Case cField == "G6R_SUSCOD"
		oMdlCab:LoadValue('G6R_SA1COD','')
		oMdlCab:LoadValue('G6R_SA1LOJ','')
		oMdlCab:SetValue('G6R_SUSLOJ',Posicione('SUS',1,xFilial('SUS')+xVal,'US_LOJA' ))
		
		
	Case cField == "G6R_SUSLOJ"
		oMdlCab:SetValue('G6R_NMCLNT'	,Posicione('SUS',1,xFilial('SUS')+oMdlCab:GetValue('G6R_SUSCOD')+xVal,'US_NOME' ) ) 
		oMdlCab:SetValue('G6R_DDD'		,Posicione('SUS',1,xFilial('SUS')+oMdlCab:GetValue('G6R_SUSCOD')+xVal,'US_DDD' ) )  
		oMdlCab:SetValue('G6R_TEL'		,Posicione('SUS',1,xFilial('SUS')+oMdlCab:GetValue('G6R_SUSCOD')+xVal,'US_TEL' ) )  
	
	Case cField == "G6R_DTIDA"	
		SetTrecho(oModel)
	Case cField == "G6R_HRIDA"	
		SetTrecho(oModel)
	Case cField == "G6R_DTVLTA"
		SetTrecho(oModel)
	Case cField == "G6R_HRVLTA"
		SetTrecho(oModel)
	
	Case cField == "G6R_TIPITI"
		ClearCp600()
		
	/*-----------------------------*\
	|Gatilhos da tabela G6S			|
	\*-----------------------------*/
		
	Case cField == "G6S_CUSTO"
		TrigGIMPrd(oMdlG6S, oMdlCab:GetValue('G6R_PRODUT'), xVal)
		
		For nLin := 1 to oMdlG6S:Length()
			oMdlG6S:GoLine(nLin)
			If !oMdlG6S:IsDeleted(nLin)
				nTot += oMdlG6S:GetValue('G6S_VALTOT', nLin) 
			Endif
		Next

		oMdlCab:LoadValue('G6R_VALTOT', nTot)
		oMdlCab:LoadValue('G6R_VLDESC', oMdlCab:GetValue('G6R_VALTOT') * (oMdlCab:GetValue('G6R_PEDESC') / 100))
		oMdlCab:LoadValue('G6R_VALACO', nTot - oMdlCab:GetValue('G6R_VLDESC'))

	Case cField == "G6S_UM"
		oMdlG6S:LoadValue('G6S_DESUM', Alltrim(POSICIONE("SAH", 1, XFILIAL("SAH") + xVal, "AH_UMRES")))
				
	Case cField == "G6S_VALTOT"
		For n1 := 1 to oMdlG6S:Length()
			oMdlG6S:GoLine(n1)
			If !oMdlG6S:IsDeleted(n1)
				nVal += oMdlG6S:GetValue('G6S_VALTOT', n1) 
			Endif
		Next

		oMdlCab:SetValue('G6R_VALTOT', nVal)
		oMdlG6S:GoLine(nLine)

	Case cField == "G6S_QUANT"
		oMdlG6S:GoLine(nLine)
		oMdlG6S:SetValue('G6S_VALTOT',oMdlG6S:GetValue('G6S_CUSUNI') * xVal)
	
	Case cField == "G6S_CUSUNI"
		oMdlG6S:GoLine(nLine)
		oMdlG6S:SetValue('G6S_VALTOT',oMdlG6S:GetValue('G6S_QUANT') * xVal)
	
	
	Case cField == "G5C_CODORI"
		oMdlG5C:SetValue('G5C_DESORI',Posicione('GI1',1,xFilial('GI1')+xVal,"GI1_DESCRI"))
		
		SetTrecho(oModel)
	
	Case cField == "G9C_CODORI"
		oMdlG9C:SetValue('G9C_DESORI',Posicione('GI1',1,xFilial('GI1')+xVal,"GI1_DESCRI"))
	
	Case cField == "G9C_CODDES"
		oMdlG9C:SetValue('G9C_DESDES',Posicione('GI1',1,xFilial('GI1')+xVal,"GI1_DESCRI"))
	
	Case cField == "G9C_DTDEST"
		
		If oMdlG9C:GetLine() < oMdlG9C:Length()
			nLine := oMdlG9C:GetLine()
			oMdlG9C:GoLine(nLine+1)
			oMdlG9C:SetValue('G9C_DTORIG',xVal)
			oMdlG9C:GoLine(nLine)
		Endif
		
	Case cField == "G9C_HRDEST"
	
		If oMdlG9C:GetLine() < oMdlG9C:Length()
			nLine := oMdlG9C:GetLine()
			oMdlG9C:GoLine(nLine+1)
			oMdlG9C:SetValue('G9C_HRORIG',xVal)
			oMdlG9C:GoLine(nLine)
		Endif
EndCase

If !IsBlind() .AND. ValType(oView) == 'O' .and. oView:IsActive()
	oView:Refresh()
EndIf

Return xVal


/*/{Protheus.doc} TrigGIMPrd
Preenche grid da GIM com as tabelas de custos conforme o produto informado
@type function
@author jacomo.fernandes
@since 19/07/2018
@version 1.0
@param oMdlG6S, objeto, (Descrição do parâmetro)
@param cProduto, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function TrigGIMPrd( oMdlG6S , cProduto, cCodigo )
Local cAliasTmp	:= GetNextAlias()
Local cWhere	:= ""
Local lTrgG6S	:= .F. //Se vier pelo gatilho do campo G6S_CUSTO, não permitir que inclua linha.
Default cCodigo	:= ""

If !Empty(cCodigo)
	cWhere	:= " AND GIM.GIM_COD = '"+cCodigo+"' "
	lTrgG6S := .T.
Endif

cWhere := "%"+cWhere+"%"

BeginSql Alias cAliasTmp
	SELECT 
		GIM.GIM_COD AS G6S_CUSTO,  
		GIM.GIM_DESCRI AS G6S_DCUSTO, 
		GIM.GIM_UM AS G6S_UM, 
		SAH.AH_UMRES AS G6S_DESUM,
		(CASE 
			WHEN GIM.GIM_TPCUST = '1' 
				THEN '2'
			ELSE '1' 
		END) AS G6S_FORMUL, 
		GIM.GIM_CBASE AS G6S_CUSUNI,
		(CASE 
			WHEN GIM.GIM_TPCUST = '1' 
				THEN GIM.GIM_CBASE 
			ELSE 0 
		END) AS G6S_VALTOT
	FROM %Table:GIM% GIM
		INNER JOIN %Table:SAH% SAH ON
			SAH.AH_FILIAL = %xFilial:SAH%
			AND SAH.AH_UNIMED = GIM.GIM_UM
			AND SAH.%NotDel%
		
	WHERE 
		GIM_FILIAL = %xFilial:GIM%
		AND GIM_PRODUT = %Exp: cProduto %
		AND GIM.%NotDel%
		
		%Exp: cWhere %
		
	Order By GIM.GIM_FILIAL, GIM.GIM_COD
EndSql

If (cAliasTmp)->(!EoF())
	While (cAliasTmp)->(!EoF())
		
		If !lTrgG6S .and. (!oMdlG6S:IsEmpty() .or. !Empty(oMdlG6S:GetValue('G6S_CUSTO')))
			oMdlG6S:AddLine()
		Endif
		
		oMdlG6S:LoadValue('G6S_CUSTO'	,(cAliasTmp)->G6S_CUSTO		)
		oMdlG6S:LoadValue('G6S_DCUSTO'	,(cAliasTmp)->G6S_DCUSTO	)
		oMdlG6S:LoadValue('G6S_UM'		,(cAliasTmp)->G6S_UM		)
		oMdlG6S:LoadValue('G6S_DESUM'	,(cAliasTmp)->G6S_DESUM		)
		oMdlG6S:LoadValue('G6S_FORMUL'	,(cAliasTmp)->G6S_FORMUL	)
		oMdlG6S:LoadValue('G6S_QUANT'	, 1							)
		oMdlG6S:LoadValue('G6S_CUSUNI'	,(cAliasTmp)->G6S_CUSUNI	)
		oMdlG6S:LoadValue('G6S_VALTOT'	,(cAliasTmp)->G6S_VALTOT	)
		oMdlG6S:LoadValue('G6S_PLAN'	,Posicione('GIM',1,xFilial('GIM')+(cAliasTmp)->G6S_CUSTO,'GIM_PLAN') )
		(cAliasTmp)->(DbSkip())
	End 
Endif

(cAliasTmp)->(DbCloseArea())


Return

/*/{Protheus.doc} GTPA600Vld
(long_description)
@type function
@author jacomo.fernandes
@since 20/07/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param cNewValue, character, (Descrição do parâmetro)
@param cOldValue, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTPA600Vld(oMdl,cField,cNewValue,cOldValue)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaAux	:= nil
Local oModel	:= oMdl:GetModel()
Local cMsgErro	:= ""
Local cMsgSolu	:= ""

Do Case
	Case Empty(cNewValue)
		lRet	:= .T.
	Case cField == "G6R_PRODUT"
		aAreaAux := SB1->(GetArea())
		SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD
		If !SB1->(DbSeek(xFilial('SB1')+cNewValue))
			lRet	:= .F.
			cMsgErro:= STR0006 //"Produto não encontrado"
			cMsgSolu:= STR0007 //"Selecione algum produto que exista"
			
		ElseIf !RegistroOk("SB1")
			lRet	:= .F.
			cMsgErro:= "Produto informado se encontra bloqueado" 
			cMsgSolu:= "Informe um produto valido"
			
		ElseIf SB1->B1_TIPO <> "SV"
			lRet	:= .F.
			cMsgErro:= "Tipo de Produto inválido."
			cMsgSolu:= "O tipo do produto de ser do tipo serviço 'SV'"
		
		Endif 
	Case cField	== "G6R_CODBEM"
		aAreaAux := ST9->(GetArea())
		ST9->(DbSetOrder(1))//T9_FILIAL+T9_CODBEM
		If !ST9->(DbSeek(xFilial('ST9')+cNewValue))
			lRet	:= .F.
			cMsgErro:= STR0008 //"Veiculo não encontrado"
			cMsgSolu:= STR0009 //"Selecione algum Veiculo que exista"
		Endif
	Case cField $ "G6R_QUANT|G6R_KMCONT|G6R_PDTOT|G6R_PEDESC|G6R_VLDESC|G6R_VALTOT|G6S_VALTOT|G6S_VALACO|"
		If cNewValue < 0
			lRet	:= .F.
			cMsgErro:= STR0010 //"Valor Informado não pode ser negativo"
			cMsgSolu:= STR0011 //"Informe um valor maior que zero"
		Endif 
	Case cField == "G6R_TOTHR" 	
		If !AtVldHora(cNewValue)
			lRet	:= .F.
			cMsgErro:= STR0012 //"Formato da hora invalido"
			cMsgSolu:= STR0013 //"Informe uma hora valida"
		Endif
	Case cField == "G6R_HRIDA" .OR. cField == "G6R_HRVLTA" .or. cField == "G6R_TOTHR" 
		lRet	:= AtVldHora(cNewValue)
		lRet	:= lRet .and. VldDtHrItne(oMdl,@cMsgErro,@cMsgSolu)
		
	Case cField == "G6R_DTIDA" .OR. cField == "G6R_DTVLTA" 
		lRet	:= VldDtHrItne(oMdl,@cMsgErro,@cMsgSolu)
		
	Case cField == "G6R_VALACO"
		If cNewValue < oModel:GetModel('MASTER'):GetValue('G6R_VALTOT')
			lRet := .F.
			cMsgErro := "Valor acordado é menor que o valor de custo"
			cMsgSolu := "Informe um valor maior que o custo orçado"
		Endif 
	//Case cField == "G6R_SA3COD"
			
	Case cField == "G6R_SA1COD"
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek(xFilial('SA1')+cNewValue))  
			lRet := .F.
			cMsgErro := "Cliente informado não encontrado" 
			cMsgSolu := "Informe um cliente valido"
		Endif
		
	Case cField == "G6R_SA1LOJ"
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek(xFilial('SA1')+oModel:GetModel('MASTER'):GetValue('G6R_SA1COD')+cNewValue))  
			lRet := .F.
			cMsgErro := "Cliente informado não encontrado" 
			cMsgSolu := "Informe um cliente valido"
		ElseIf !RegistroOk("SA1")
			lRet := .F.
			cMsgErro := "Cliente informado se encontra bloqueado" 
			cMsgSolu := "Informe um cliente ativo ou selecione um cliente valido"
		
		Endif
	Case cField == "G6R_SUSCOD"
		SUS->(DbSetOrder(1))
		If !SUS->(DbSeek(xFilial('SUS')+cNewValue))  
			lRet := .F.
			cMsgErro := "Prospect informado não encontrado" 
			cMsgSolu := "Informe um Prospect valido"
		Endif
	Case cField == "G6R_SUSLOJ"
		SUS->(DbSetOrder(1))
		If !SUS->(DbSeek(xFilial('SUS')+oModel:GetModel('MASTER'):GetValue('G6R_SUSCOD')+cNewValue))  
			lRet := .F.
			cMsgErro := "Prospect informado não encontrado" 
			cMsgSolu := "Informe um Prospect valido"
		ElseIf !RegistroOk("SUS")
			lRet := .F.
			cMsgErro := "Prospect informado se encontra bloqueado" 
			cMsgSolu := "Informe um Prospect ativo ou selecione um Prospect valido"
		
		Endif
	
	Case cField == "G6S_CUSTO" 
		aAreaAux := GIM->(GetArea())
		GIM->(DbSetOrder(1))//GIM_FILIAL+GIM_CUSTOS
		If !GIM->(DbSeek(xFilial('GIM')+cNewValue)) 
			lRet	:= .F.
			cMsgErro:= STR0014 //"Planilha de custos inexistente"
			cMsgSolu:= STR0015 //"Informe uma planilha existente"
		ElseIf GIM->GIM_PRODUT  <> oModel:GetModel('MASTER'):GetValue('G6R_PRODUT') 
			lRet	:= .F.
			cMsgErro:= STR0016 //"Planilha de custos não pertence ao mesmo produto informado."
			cMsgSolu:= STR0017 //"Selecione uma planilha que possua o mesmo produto."
		Endif
	
	Case cField == "G9C_HRORIG" .or. cField == "G9C_HRDEST" 
		If !AtVldHora(cNewValue) 
			lRet	:= .F.    
			cMsgErro:= 'Hora informada invalida'
			cMsgSolu:= "Infome uma hora entre 00:00 até 23:59"
		Endif
		
		If lRet .and. !VldHrTrecho(oMdl)
			lRet	:= .F.    
			cMsgErro:= 'Data/Hora chegada menor que Data/Hora de saída'
			cMsgSolu:= "Verifique os dados informados"
		Endif
	Case cField == "G9C_HRDEST" .or. cField == "G9C_DTDEST" 
		If !VldHrTrecho(oMdl)
			lRet	:= .F.    
			cMsgErro:= 'Data/Hora chegada menor que Data/Hora de saída'
			cMsgSolu:= "Verifique os dados informados"
		Endif
EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,'GTPA600Vld',cMsgErro,cMsgSolu)
Endif

If ValType(aAreaAux) == "A"
	RestArea(aAreaAux)
Endif

RestArea(aArea)

GTPDestroy(aArea)
GTPDestroy(aAreaAux)

Return lRet


/*/{Protheus.doc} GA600Calc
(long_description)
@type function
@author jacomo.fernandes
@since 20/07/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA600Calc(oView)
Local oModel			:= oView:GetModel()
Local oMdlCab			:= oModel:GetModel('MASTER')
Local oMdlG6S			:= oModel:GetModel('G6SDETAIL')
Local oStruCab			:= oMdlCab:GetStruct() 
Local oWorkSheet		:= FWUIWorkSheet():New(/*oWinPlanilha*/,.F. , /*WS_ROWS*/, /*WS_COLS*/)
Local nCell				:= 0
Local n1				:= 0
Local nValue			:= 0

Local lRet				:= .T.

oWorkSheet:lShow := .F.

For n1 := 1 to oMdlG6S:Length()
	If !oMdlG6S:IsDeleted(n1) .and. oMdlG6S:GetValue('G6S_FORMUL',n1) == '1'
		oMdlG6S:GoLine(n1)
		oWorkSheet:LoadXmlModel(oMdlG6S:GetValue('G6S_PLAN'))
		
		For nCell := 2 To oWorkSheet:NTOTALLINES			
			If oWorkSheet:CellExists("A"+ cValTochar(nCell))
				
				cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
				cCellValue	:= "G6R"+SubStr(cCellValue,4) 
				If oStruCab:HasField(cCellValue)
					lRet := oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlCab:GetValue( cCellValue  )  )
				Endif
			EndIf
		Next
		
		If oWorkSheet:CellExists("D2") 	
			nValue := oWorkSheet:GetCellValue("D2")
		EndIf
				
		oMdlG6S:SetValue('G6S_CUSUNI',nValue)
		
		oWorkSheet:Close()
		
	Endif
Next

GTPDestroy(oWorkSheet)

Return

/*/{Protheus.doc} GA600PRLIN
(long_description)
@type function
@author jacomo.fernandes
@since 20/07/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param cAction, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA600PRLIN(oMdl,nLine,cAction,cField)
Local lRet	  := .T.
Local oView	  := FwViewActive()
Local oModel  := oMdl:GetModel()
Local oMdlCab := oModel:GetModel('MASTER')
Local oMdlG6S := oModel:GetModel('G6SDETAIL')
Local oMdlG5C := oModel:GetModel('G5CDETAIL')
Local cMdlId  := oMdl:GetId()
Local cLocOri := ''
Local cLocDes := ''
Local cCodOri := ''
Local nValor  := 0
 
If cAction $ "DELETE|UNDELETE"
	If cMdlId == 'G6SDETAIL'
		oMdlG6S:RunTrigger('G6S_VALTOT')
		oMdlG6S:GoLine(nLine)

		If cAction == "DELETE"
			nValor	:= oMdlCab:GetValue('G6R_VALTOT')-oMdlG6S:GetValue('G6S_VALTOT')
		Else
			nValor	:= oMdlCab:GetValue('G6R_VALTOT')+oMdlG6S:GetValue('G6S_VALTOT')
		Endif

		oMdlCab:LoadValue('G6R_VALTOT', nValor)
		oMdlCab:LoadValue('G6R_VLDESC', nValor * (oMdlCab:GetValue('G6R_PEDESC')/100))
		oMdlCab:LoadValue('G6R_VALACO', nValor - oMdlCab:GetValue('G6R_VLDESC'))

		oMdlG6S:GoLine(nLine)
		oView:Refresh()

	ElseIf cMdlId == 'G5CDETAIL'
		cLocOri := oMdlCab:GetValue('G6R_LOCORI')
		cLocDes := oMdlCab:GetValue('G6R_LOCDES')
		cCodOri := oMdlG5C:GetValue('G5C_CODORI', nLine)
		
		If cAction == 'DELETE' .And. (cCodOri == cLocOri .Or. cCodOri == cLocDes)
			lRet := .F.
			oModel:SetErrorMessage(cMdlId,'',cMdlId,'','GA600PRLIN','Não é possivel deletar uma localidade de tipo Origem ou Destino')
		Else
			SetTrecho(oModel)
		EndIf
	Endif
Endif

Return lRet

/*/{Protheus.doc} VldDtHrItne
Valida a hora inicial e final do itinerário
@type function
@author jacomo.fernandes
@since 26/11/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cMsgErro, character, (Descrição do parâmetro)
@param cMsgSolu, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldDtHrItne(oMdl,cMsgErro,cMsgSolu)
Local lRet		:= .T.
Local cDtIda	:= DtoS(oMdl:GetValue('G6R_DTIDA'))
Local cHrIda	:= oMdl:GetValue('G6R_HRIDA')
Local cDtVolta	:= DtoS(oMdl:GetValue('G6R_DTVLTA'))
Local cHrVolta	:= oMdl:GetValue('G6R_HRVLTA')

If !Empty(cDtIda) .and. Empty(cDtVolta)  
	cDtVolta := cDtIda 
Endif 

If !Empty(cHrIda) .and. Empty(cHrVolta)
	cHrVolta := cHrIda 
Endif 

If !Empty(cDtIda) .and. !Empty(cHrIda) .and. !Empty(cDtVolta) .and. !Empty(cHrVolta)
	If cDtVolta+cHrVolta < cDtIda+cHrIda
		lRet		:= .F.
		cMsgErro	:= "Data/hora final é menor que a data/hora inicial"
		cMsgSolu	:= "Informe uma data valida"
	Endif 
Endif

Return lRet

/*/{Protheus.doc} SetDesc
Função responsavel para preecher o campo de descrição do orçamento
@type function
@author jacomo.fernandes
@since 22/11/2018
@version 1.0
@param oMdlCab, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetDesc(oMdlCab)

Local cCodOri	:= oMdlCab:GetValue('G6R_LOCORI')
Local cDesOri	:= SubStr(Posicione('GI1',1,xFilial('GI1')+cCodOri,"GI1_DESCRI"),1,13)

Local cCodDes	:= oMdlCab:GetValue('G6R_LOCDES')
Local cDesDes	:= SubStr(Posicione('GI1',1,xFilial('GI1')+cCodDes,"GI1_DESCRI"),1,13)

Local cDescri	:= Alltrim(cDesOri) + " x " + Alltrim(cDesDes)

oMdlCab:SetValue('G6R_DESCRI',cDescri)

Return

/*/{Protheus.doc} Ga600PosVld
(long_description)
@type function
@author jacomo.fernandes
@since 12/12/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga600PosVld(oModel)
Local lRet		:= .T.
Local oMdlG9C	:= oModel:GetModel('G9CDETAIL')
Local oMdlG9CB	:= oModel:GetModel('G9CBDETAIL')
Local n1		:= 0
Local n2		:= 0
Local aFldG9C	:= oMdlG9CB:GetStruct():GetFields() 

If oModel:GetOperation() <> MODEL_OPERATION_DELETE
	oMdlG9CB:DelAllLine()
	
	For n1 := 1 To oMdlG9C:Length()
		oMdlG9C:GoLine(n1)
		
		If !oMdlG9CB:IsEmpty() .and. !Empty(oMdlG9CB:GetValue('G9C_SEQ'))
			oMdlG9CB:AddLine()
		Endif
		
		
		For n2 := 1 to Len(aFldG9C)
			oMdlG9CB:SetValue(aFldG9C[n2][MODEL_FIELD_IDFIELD],oMdlG9C:GetValue(aFldG9C[n2][MODEL_FIELD_IDFIELD]))
		Next
	
	Next
ENDIF

Return lRet

/*/{Protheus.doc} Ga120Commit
Realiza cadastro na tabela G9T(Cadastro de Pedágio) quando uma combinação de Origem e
Destino cadastrado na tabela de Orçamento não existir na tabela G9T.
@type function
@author gustavo.silva2
@since 07/01/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga120Commit(cCodOrig,cCodDes,nTotPed,nEixos)
	
Local oModelG9T	:= FwLoadModel("GTPA120")
Local oMdlG9T	:= oModelG9T:GetModel("G9TMASTER")
Local lRet		:= .T.
Local nRecnoPeda:= RecnoPedag(cCodOrig,cCodDes,nEixos)
Local lEixos	:= G9T->(FieldPos("G9T_EIXOS")) > 0 .AND. G6R->(FieldPos("G6R_EIXOS")) > 0

DbSelectArea("G9T")
G9T->(dbSetOrder(2))

If nRecnoPeda == 0	
	oModelG9T:SetOperation(MODEL_OPERATION_INSERT)
	oModelG9T:Activate()
	oMdlG9T:LoadValue('G9T_CODORI', cCodOrig)
	oMdlG9T:LoadValue('G9T_CODDES', cCodDes)
	oMdlG9T:LoadValue('G9T_VALTOT', nTotPed)
Else
	G9T->(DbGoTo(nRecnoPeda))
	oModelG9T:SetOperation(MODEL_OPERATION_UPDATE)
	oModelG9T:Activate()
	oMdlG9T:LoadValue('G9T_VALTOT', nTotPed)
EndIf

If lEixos
	oMdlG9T:LoadValue('G9T_EIXOS', nEixos)
Endif

If 	oModelG9T:VldData()
	oModelG9T:CommitData()
Else
	lRet:= .F.
EndIf
oModelG9T:DeActivate()
oModelG9T:Destroy()
return lRet  

/*/{Protheus.doc} Ga600Commit
Função responsavel pela gravação do modelo
@type function
@author jacomo.fernandes
@since 23/11/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga600Commit(oModel)

	Local lRet		:= .T.
	Local oMdlG6R	:= oModel:GetModel('MASTER')
	Local aErro		:= Nil
	Local cCodOrig 	:= oMdlG6R:GetValue('G6R_LOCORI')
	Local cCodDes 	:= oMdlG6R:GetValue('G6R_LOCDES')
	Local nTotPed 	:= oMdlG6R:GetValue('G6R_PDTOT')
	Local lGrvPeda 	:= GTPGetRules("GRVPEDORC",,,.T.)
	Local nEixos	:= Iif(G6R->(FieldPos("G6R_EIXOS")) > 0,oMdlG6R:GetValue('G6R_EIXOS'),0)

	Begin Transaction

		If lGrvPeda .AND. !Ga120Commit(cCodOrig,cCodDes,nTotPed,nEixos)
			lRet := .F.
		Endif

		If !lRet
			DisarmTransaction()
		Endif 

	End Transaction

	If ValType(aErro) == "A"
		JurShowError(aErro)
		lRet := .F.
	Endif

	If lRet 
			
		Begin Transaction 

		If ( oModel:GetOperation() == MODEL_OPERATION_UPDATE )		

			If ( !Empty(oMdlG6R:GetValue("G6R_PEDIDO")) )			
				lRet := ExcPedVend(oModel)
			EndIf

			If ( lRet .And. Len(aViagem) > 1 )					
				lRet := ExcViagem()
			EndIf

			If ( lRet )
			
				lRet := oMdlG6R:LoadValue("G6R_FCS",	space(TamSx3("G6R_FCS")[1])) .And.;
					oMdlG6R:LoadValue("G6R_FCI",		space(TamSx3("G6R_FCI")[1])) .And.;					
					oMdlG6R:LoadValue("G6R_DTASSI",		SToD("")) .And.;
					oMdlG6R:LoadValue("G6R_CNTPRO",		space(TamSx3("G6R_CNTPRO")[1])) .And.;
					oMdlG6R:LoadValue("G6R_USRASS",		space(TamSx3("G6R_CNTPRO")[1])) .And.;
					oMdlG6R:LoadValue("G6R_PEDIDO",		space(TamSx3("G6R_PEDIDO")[1]))
				
				If ( lRet .And. G6R->G6R_STATUS != '1' )
					lRet := oMdlG6R:LoadValue("G6R_STATUS",	'4') 
				EndIf
				
			EndIf

		EndIf
		
		If ( lRet )
			lRet := FwFormCommit(oModel)
		EndIf

		If ( !lRet )
			DisarmTransaction()
		EndIf

		End Transaction 

	EndIf

Return lRet

/*/{Protheus.doc} GeraPedVend(oModel)	
	Função responsável pela persistência dos dados 
	no banco de dados dos pedidos de vendas.
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 31/01/2022
	@version version
	@param 
		oModel, objeto, instância da Classe FWFormModel()
	@return 
		lRet, lógico, .t. Persistência bem sucedida
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ExcPedVend(oModel)

	Local lRet 		:= .F.

	Local aCabec	:= {}
	Local aItens	:= {}
	
	Local oSubMdl	:= oModel:GetModel("MASTER")

	Private lMsErroAuto	:= .F.

	aAdd(aCabec,{"C5_NUM", oSubMdl:GetValue("G6R_PEDIDO"), Nil})
	//Se parametro MV_1DUPNAT indica que natureza a ser considerada está no campo C5_NATUREZ, ³	
	// obrigado preencher o campo no cabeçalho do pedido.			   								³
	
	FwMsgRun(Nil,{|| MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,5)},Nil,"Excluindo o pedido de venda...")
	
	lRet := !lMsErroAuto

	If ( lMsErroAuto )
		MostraErro()
	EndIf
	
	aCabec := {}
	aItens := {} 

	lMsErroAuto	:= .F.

Return(lRet)

Static Function ExcViagem()

	Local lRet 			:= .T.

	Local nI			:= 0

	Local oMdlViagem 	:= FwLoadModel("GTPA300")
	
	oMdlViagem:SetOperation(MODEL_OPERATION_DELETE)

	For nI := 2 to Len(aViagem)

		GYN->( DbGoTo(aViagem[nI][Len(aViagem[nI])]) )

		If ( (lRet := oMdlViagem:Activate()) )
				
			lRet := oMdlViagem:VldData()

			If ( lRet )		
				lRet := oMdlViagem:CommitData()				
			EndIf
			
		EndIf	

		If ( !lRet .And. oMdlViagem:HasErrorMessage() )
			JurShowErro(oMdlViagem:GetErrorMessage())
			Exit
		EndIf	

		oMdlViagem:DeActivate()

	Next nI

Return(lRet)

/*/{Protheus.doc} VldServExtr
(long_description)
@type function
@author jacomo.fernandes
@since 12/12/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function VldServExtr()
Local lRet 		:= .T.
Local aArea		:= GetArea()   
Local aAreaGYW	:= GYW->(GetArea())
Local cServic	:= SuperGetMv( "MV_GTPCSVE" ) 

If !Empty(cServic)

	DbSelectArea("GYW") // Tipo de Serviço Extraordinário.
	GYW->(DbSetOrder(1)) //GYW _FILIAL+ GYW_CODIGO	
	
	If !GYW->(DbSeek(xFilial("GYW")+PadR(cServic,TAMSX3("GYW_CODIGO")[1])))
		lRet := .F.
		Help(,,'VldServExtr',, I18n( "O Tipo de Serviço Extraordinário (#1) informado no parâmetro MV_GTPCSVE não existe.", { cServic } ), 1,0) //"O Tipo de Serviço Extraordinário (#1) informado no parâmetro MV_GTPCSVE não existe."
	EndIf
Else 
	lRet := .F.
	Help(,,'VldServExtr',, "Preencha o parâmetro MV_GTPCSVE para possibilitar a geração das Viagens Extraordinárias.", 1,0) //"Preencha o parâmetro MV_GTPCSVE para possibilitar a geração das Viagens Extraordinárias."
EndIf

RestArea(aArea)
RestArea(aAreaGYW)

Return lRet 

/*/{Protheus.doc} VldTrechos
(long_description)
@type function
@author jacomo.fernandes
@since 14/12/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function VldTrechos()
Local lRet		:= .T.
Local cAliasTmp	:= GetNextAlias()

BeginSql Alias cAliasTmp
	Select COUNT(G9C_CODIGO) AS QTD
	From %Table:G9C%
	WHERE
		G9C_FILIAL = %xFilial:G9C%
		AND G9C_CODIGO = %Exp:G6R->G6R_CODIGO%
		AND (
			G9C_DTORIG = ''
			OR G9C_HRORIG = ''
			OR G9C_DTDEST = ''
			OR G9C_HRORIG = ''
			)
		AND %NotDel%
		
EndSql
 
If (cAliasTmp)->QTD > 0
	lRet	:= .F.
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} GA600VldAct
Função responsavel pela validação da ativação do modelo 
@type function
@author jacomo.fernandes
@since 26/11/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA600VldAct(oModel)

	Local lRet	:= .T.

	Local nOpc	:= oModel:GetOperation()
	
	If ( nOpc == MODEL_OPERATION_UPDATE .or. nOpc == MODEL_OPERATION_DELETE )
		
		If ( nOpc == MODEL_OPERATION_DELETE .And. !(G6R->G6R_STATUS $ '1|4') )
			lRet := .F.
			oModel:SetErrorMessage(oModel:GetId(),'G6R_STATUS',oModel:GetId(), 'G6R_STATUS','GA600VLDACT',"Só é possivel excluir simulações abertas (ou reabertas)")
		Endif

		If ( lRet .And. G6R->G6R_STATUS == '2' )
			lRet := GetTrip(oModel)
		EndIf

	Endif

Return lRet

/*/{Protheus.doc} GetTrip(oModel)	
	Verifica se existem viagens e, caso exista carrga no 
	array estático aViagens
	
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 04/02/2022
	@version version
	@param 
		oModel, objeto, instância da Classe FWFormModel()
	@return 
		lRet, lógico, .t. Existe pelo menos uma viagem
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GetTrip(oModel)

	Local lRet 		:= .T.

	Local aSeek 	:= {}

	Local nPFinal	:= 0
	Local nPViagem	:= 0
	Local nI		:= 0

	Local cCodViag	:= ""

	If ( oModel:GetOperation() == MODEL_OPERATION_UPDATE )

		aAdd(aSeek,{"GYN_FILIAL",xFilial("GYN")})
		aAdd(aSeek,{"GYN_CODPED",G6R->G6R_PEDIDO})
		aAdd(aSeek,{"GYN_SRVEXT","ES"})
		aAdd(aSeek,{"GYN_CANCEL","1"})
		aAdd(aSeek,{"GYN_LOCORI",G6R->G6R_LOCORI})
		aAdd(aSeek,{"GYN_LOCDES",G6R->G6R_LOCDES})
		aAdd(aSeek,{"GYN_DTINI",G6R->G6R_DTIDA})
		aAdd(aSeek,{"GYN_DTFIM",G6R->G6R_DTVLTA})
		aAdd(aSeek,{"GYN_HRINI",G6R->G6R_HRIDA})
		aAdd(aSeek,{"GYN_HRFIM",G6R->G6R_HRVLTA})

		If ( GTPSeekTable("GYN",aSeek,aViagem,.T./*,cOrderBy,lOrderBy*/) )

			nPFinal		:= aScan(aViagem[1],"GYN_FINAL")
			nPViagem	:= aScan(aViagem[1],"GYN_CODIGO")
			
			If ( nPFinal > 0 )

				For nI := 2 to Len(aViagem)	
					
					lRet := aViagem[nI,nPFinal] != '1'
					
					If(!lRet)

						If ( nPViagem > 0 )
							cCodViag := space(1) + Alltrim(aViagem[nI,nPViagem]) + ","
						EndIf

						Exit
					
					EndIf

				Next nI	

			EndIf
			
			If ( !lRet )				
				oModel:SetErrorMessage(oModel:GetId(),'GYN_FINAL',oModel:GetId(), 'GYN_FINAL','GETTRIP',"A viagem" + cCodViag + " vinculada ao contrato já foi realizada. Este contrato não poderá ser alterado.")
			EndIf

		Else	
			oModel:SetErrorMessage(oModel:GetId(),'GYN_CODIGO',oModel:GetId(), 'GYN_CODIGO','GETTRIP',"A(s) viagem(ns) vinculada(s) ao contrato não foi(ram) localizada(s). Verifique o programa de cadastro de viagens.")				
		EndIf		

	Endif

Return(lRet)

/*/{Protheus.doc} Ga600Cpy
(long_description)
@type function
@author jacomo.fernandes
@since 28/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function Ga600Cpy()

	Local oModel	:= FwLoadModel('GTPA600')
	Local oMdlG6R	:= oModel:GetModel('MASTER')
	Local oMdlG6S	:= oModel:GetModel('G6SDETAIL')
	Local oMdlG5C	:= oModel:GetModel('G5CDETAIL')
	Local oMdlG9C	:= oModel:GetModel('G9CDETAIL')

	Local oStrG6R	:= oMdlG6R:GetStruct()
	Local oStrG6S	:= oMdlG6S:GetStruct()
	Local oStrG5C	:= oMdlG5C:GetStruct()
	Local oStrG9C	:= oMdlG9C:GetStruct()

	Local aStrG6R	:= G6R->(DbStruct())
	Local aStrG6S	:= G6S->(DbStruct())
	Local aStrG5C	:= G5C->(DbStruct())
	Local aStrG9C	:= G9C->(DbStruct())

	Local n1		:= 0
	Local n2		:= 0

	Local aNoFldG6R	:= NoCopyFields("G6R")
	Local aNoFldG6S	:= NoCopyFields("G6S")	//{'G6S_CODIGO','G6S_UM','G6S_QUANT','G6S_CUSUNI','G6S_VALTOT'}
	Local aNoFldG5C	:= NoCopyFields("G5C")	//{'G5C_CODIGO','G5C_CODORI'}
	Local aNoFldG9C	:= NoCopyFields("G9C")	//{'G9C_CODIGO','G9C_DTORIG','G9C_HRORIG'}

	Local aForceG6S	:= {'G6S_QUANT','G6S_CUSUNI','G6S_VALTOT'}
	Local aForceG5C	:= {'G5C_CODORI'}
	Local aForceG9C	:= {'G9C_DTORIG','G9C_HRORIG'}

	Local nRecG6R	:= G6R->(RECNO())


	oModel:SetOperation(MODEL_OPERATION_INSERT)
	If oModel:Activate()
		G6R->(DbGoTo(nRecG6R))
		For n1	:= 1 to Len(aStrG6R)
			If oStrG6R:HasField(aStrG6R[n1][1]) .and. (aScan(aNoFldG6R,aStrG6R[n1][1]) == 0)
				lRet	:= oMdlG6R:SetValue(aStrG6R[n1][1],G6R->&(aStrG6R[n1][1]))
			Endif
			If !lRet
				Exit
			Endif
		Next
		If lRet
			G6S->(DbSetOrder(1))//G6S_FILIAL, G6S_CODIGO, G6S_ITEM
			If G6S->(DbSeek(G6R->(G6R_FILIAL+G6R_CODIGO) ))
				While G6S->(!Eof()) .and. G6S->G6S_FILIAL == G6R->G6R_FILIAL .AND. G6S->G6S_CODIGO == G6R->G6R_CODIGO
					If !oMdlG6S:SeekLine({{'G6S_CUSTO',G6S->G6S_CUSTO}}) .AND. !oMdlG6S:IsEmpty() 
						oMdlG6S:AddLine()
					Endif
					For n2	:= 1 to Len(aStrG6S)
						If oStrG6S:HasField(aStrG6S[n2][1]) .and. (aScan(aNoFldG6S,aStrG6S[n2][1]) == 0)
							lRet	:= oMdlG6S:SetValue(aStrG6S[n2][1],G6S->&(aStrG6S[n2][1]))
						Elseif (aScan(aForceG6S,aStrG6S[n2][1]) ) > 0
							lRet	:= oMdlG6S:LoadValue(aStrG6S[n2][1],G6S->&(aStrG6S[n2][1]))
							oMdlG6S:RunTrigger(aStrG6S[n2][1],oMdlG6S:GetValue(aStrG6S[n2][1]) )
						Endif
						If !lRet
							Exit
						Endif
					Next
					If !lRet
						Exit
					Endif
					
					G6S->(DbSkip())
				EndDo
			
			Endif
		Endif
		
		If lRet
			G5C->(DbSetOrder(1))//G5C_FILIAL, G5C_CODIGO, G5C_SEQ
			If G5C->(DbSeek(G6R->(G6R_FILIAL+G6R_CODIGO) ))
				While G5C->(!Eof()) .and. G5C->G5C_FILIAL == G6R->G6R_FILIAL .AND. G5C->G5C_CODIGO == G6R->G6R_CODIGO
					If !oMdlG5C:SeekLine({{'G5C_SEQ',G5C->G5C_SEQ}}) .AND. !oMdlG5C:IsEmpty() 
						oMdlG5C:AddLine()
					Endif
					For n2	:= 1 to Len(aStrG5C)
						If oStrG5C:HasField(aStrG5C[n2][1]) .and. (aScan(aNoFldG5C,aStrG5C[n2][1]) == 0)
							lRet	:= oMdlG5C:SetValue(aStrG5C[n2][1],G5C->&(aStrG5C[n2][1]))
						Elseif (aScan(aForceG5C,aStrG5C[n2][1]) ) > 0
							lRet	:= oMdlG5C:LoadValue(aStrG5C[n2][1],G5C->&(aStrG5C[n2][1]))
							oMdlG5C:RunTrigger(aStrG5C[n2][1],oMdlG5C:GetValue(aStrG5C[n2][1]))
						Endif
						If !lRet
							Exit
						Endif
					Next
					If !lRet
						Exit
					Endif
					
					G5C->(DbSkip())
				EndDo
			
			Endif
		Endif
		
		If lRet
			G9C->(DbSetOrder(1))//G9C_FILIAL, G9C_CODIGO, G9C_SEQ
			If G9C->(DbSeek(G6R->(G6R_FILIAL+G6R_CODIGO) ))
				oModel:GetModel( 'G9CDETAIL' ):SetNoInsertLine( .F. )
				oModel:GetModel( 'G9CDETAIL' ):SetNoDeleteLine( .F. )
				
				While G9C->(!Eof()) .and. G9C->G9C_FILIAL == G6R->G6R_FILIAL .AND. G9C->G9C_CODIGO == G6R->G6R_CODIGO
					If !oMdlG9C:SeekLine({{'G9C_SEQ',G9C->G9C_SEQ}}) .AND. !oMdlG9C:IsEmpty() 
						oMdlG9C:AddLine()
					Endif
					For n2	:= 1 to Len(aStrG9C)
						If oStrG9C:HasField(aStrG9C[n2][1]) .and. (aScan(aNoFldG9C,aStrG9C[n2][1]) == 0)
							lRet	:= oMdlG9C:SetValue(aStrG9C[n2][1],G9C->&(aStrG9C[n2][1]))
						Elseif (aScan(aForceG9C,aStrG9C[n2][1]) ) > 0
							lRet	:= oMdlG9C:LoadValue(aStrG9C[n2][1],G9C->&(aStrG9C[n2][1]))
							oMdlG9C:RunTrigger(aStrG9C[n2][1],oMdlG9C:GetValue(aStrG9C[n2][1]))
						Endif
						If !lRet
							Exit
						Endif
					Next
					If !lRet
						Exit
					Endif
					
					G9C->(DbSkip())
				EndDo
				oModel:GetModel( 'G9CDETAIL' ):SetNoInsertLine( .T. )
				oModel:GetModel( 'G9CDETAIL' ):SetNoDeleteLine( .T. )
				
			Endif
		Endif
		
		
		If lRet
			FWExecView( "Incluir" , "GTPA600", MODEL_OPERATION_INSERT, /*oDlgKco*/, {|| .T. } , /*bOk*/ ,/*nPercReducao*/, /*aButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oModel )
		Else
			JurShowErro(oModel:GetErrorMessage())
		Endif
		oModel:DeActivate()
	Endif

	oModel:Destroy()


	GTPDestroy(aStrG6R)
	GTPDestroy(aStrG6S)
	GTPDestroy(aStrG5C)
	GTPDestroy(aStrG9C)

	GTPDestroy(aNoFldG6R)
	GTPDestroy(aNoFldG6S)
	GTPDestroy(aNoFldG5C)
	GTPDestroy(aNoFldG9C)
			
	GTPDestroy(aForceG6S)
	GTPDestroy(aForceG5C)

Return()

/*/{Protheus.doc} NoCopyFields(cAlias)	
	Quais os campos que não devem ter os valores copiados
	quando o usuário selecionar a opção de Cópia.	
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 04/02/2022
	@version version
	@param 
		cAlias, caractere, Alias da tabela que retornará os campos para não serem copiados
	@return 
		aNoFields, array, Campos que não podem ser copiados de acordo com o alias passado
		via parâmetro cAlias
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function NoCopyFields(cAlias)

	Local aNoFields := {}	
	
	Do Case 
	Case ( cAlias == "G6R" )
		
		aAdd(aNoFields,'G6R_CODIGO')
		aAdd(aNoFields,'G6R_NROPOR')
		aAdd(aNoFields,'G6R_PROPOS')
		aAdd(aNoFields,'G6R_DTINCL')
		aAdd(aNoFields,'G6R_STATUS')
		aAdd(aNoFields,'G6R_OPOREV')
		aAdd(aNoFields,'G6R_PROREV')
		
		If ( G600ChkNFlds() )

			aAdd(aNoFields,'G6R_JUSTIF')
			aAdd(aNoFields,'G6R_PEDIDO')
			aAdd(aNoFields,'G6R_USRASS')
			aAdd(aNoFields,'G6R_CNTPRO')
			aAdd(aNoFields,'G6R_DTASSI')
			aAdd(aNoFields,'G6R_FCI')
			aAdd(aNoFields,'G6R_FCS')

		EndIf
		
	Case ( cAlias == "G6S" ) 
		aNoFields	:= {'G6S_CODIGO','G6S_UM','G6S_QUANT','G6S_CUSUNI','G6S_VALTOT'}
	Case ( cAlias == "G5C" ) 
		aNoFields	:= {'G5C_CODIGO','G5C_CODORI'}
	Case ( cAlias == "G9C" ) 
		aNoFields	:= {'G9C_CODIGO','G9C_DTORIG','G9C_HRORIG'}
	End Case	

Return(aNoFields)	

/*/{Protheus.doc} GetQtdPolt
(long_description)
@type function
@author jacomo.fernandes
@since 28/11/2018
@version 1.0
@param cCodBem, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetQtdPolt(cCodBem)

	Local nRet			:= 0
	Local cTmpAlias		:= GetNextAlias()
	Local cCodCaract	:= GTPGetRules("IDPOLTRONA")
	
	BeginSql Alias cTmpAlias
		Select STB.TB_DETALHE
		From %Table:STB% STB 	
		Where
			STB.TB_FILIAL = %xFilial:STB%
			AND STB.TB_CODBEM = %Exp:cCodBem%
			And STB.TB_CARACTE = %Exp:cCodCaract%
			And STB.%NotDel%
	EndSql 
	
	If (cTmpAlias)->(!Eof())
		nRet := Val((cTmpAlias)->TB_DETALHE)
	Endif
	
	(cTmpAlias)->(DbCloseArea())

Return nRet


/*/{Protheus.doc} SetPercurso
(long_description)
@type function
@author jacomo.fernandes
@since 10/12/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cLocalidade, character, (Descrição do parâmetro)
@param cTipo, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetPercurso(oModel, cLocalidade, cTipo)
Local oMdlG5C := oModel:GetModel('G5CDETAIL')

If !oMdlG5C:SeekLine({{'G5C_TIPLOC', cTipo}})
	If !oMdlG5C:IsEmpty() .and. !Empty(oMdlG5C:GetValue('G5C_CODORI')) .And. (oMdlG5C:Length() < 2)
		oMdlG5C:AddLine()
	Endif
Endif

if !oMdlG5C:IsEmpty() .And. oMdlG5C:IsDeleted(Val(cTipo))
	oMdlG5C:GoLine(Val(cTipo))
	oMdlG5C:UnDeleteLine()
endif

If Empty(oMdlG5C:GetValue('G5C_SEQ'))
	oMdlG5C:SetValue('G5C_SEQ', StrZero(oMdlG5C:GetLine(), TamSx3('G5C_SEQ')[1]))
Endif

oMdlG5C:GoLine(Val(cTipo))
oMdlG5C:SetValue('G5C_CODORI', cLocalidade)
oMdlG5C:SetValue('G5C_TIPLOC', cTipo)

Return

 
/*/{Protheus.doc} Ga600DbClk
(long_description)
@type function
@author jacomo.fernandes
@since 10/12/2018
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param nLineGrid, numérico, (Descrição do parâmetro)
@param nLineModel, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga600DbClk(oGrid,cField,nLineGrid,nLineModel)
Local oModel	:= oGrid:GetModel()
Local oView		:= FWViewActive()
Local lRet		:= .T.
Local nLineAux	:= 0
Local cSeqOri	:= ""
Local cSeqDes	:= ""	

If (oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE )
	If cField == "G5C_SOBE" .or. cField == "G5C_DESCE"
		If cField == "G5C_SOBE" 
			If nLineGrid <> 1
				nLineAux := nLineGrid-1
			Else
				lRet := .F.
				FwAlertHelp('Não pode subir o primeiro registro')
			Endif
		Else
			If nLineGrid <> oModel:Length()
				nLineAux := nLineGrid+1
			Else
				lRet := .F.
				FwAlertHelp('Não pode descer o ultimo registro')
			Endif
			
		Endif
		
		// Se a linha a ser movimentada for origem ou destino, não pode inverter as ordem de origem x destino
		If oModel:GetValue('G5C_TIPLOC') <> '3' .and. oModel:GetValue('G5C_TIPLOC',nLineAux) <> '3' 
			lRet := .F.
			FwAlertHelp('A localidade de Origem não pode ser depois da localidade de Destino')
		Endif
		
		If lRet
			cSeqOri	:= oModel:GetValue('G5C_SEQ',nLineGrid)
			cSeqDes	:= oModel:GetValue('G5C_SEQ',nLineAux)
			
			oModel:SetValue('G5C_SEQ',cSeqDes)
			oModel:GoLine(nLineAux)
			oModel:SetValue('G5C_SEQ',cSeqOri)
			oModel:GoLine(nLineGrid)
			
			oModel:LineShift(nLineGrid,nLineAux)
			SetTrecho(oModel:GetModel())
			oView:Refresh()
		Endif
		
	Endif
EndIf

Return lRet


/*/{Protheus.doc} SetTrecho
(long_description)
@type function
@author jacomo.fernandes
@since 10/12/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetTrecho(oModel)
Local oMdlG6R	:= oModel:GetModel('MASTER')
Local oMdlG5C	:= oModel:GetModel('G5CDETAIL')
Local oMdlG9C	:= oModel:GetModel('G9CDETAIL')
Local nLine		:= oMdlG5C:GetLine()
Local n1		:= 0
Local n2		:= 0


//CRIAR O TRECHO SOMENTE QUANDO TIVER PELO MENOS A ORIGEM E O DESTINO DEFINIDO
If !Empty(oMdlG6R:GetValue('G6R_LOCORI')) .AND. !Empty(oMdlG6R:GetValue('G6R_LOCDES'))
	
	oModel:GetModel( 'G9CDETAIL' ):SetNoInsertLine( .F. )
	oModel:GetModel( 'G9CDETAIL' ):SetNoDeleteLine( .F. )
	
	oMdlG9C:LineShift(1,oMdlG9C:AddLine())
							
	For n1 := oMdlG9C:Length() To 1 step -1
		oMdlG9C:Goline(n1)
		oMdlG9C:DeleteLine(.T.,.T.)
	Next
	
	oMdlG9C:UnDeleteLine()
	
	For n1 := 1 to oMdlG5C:Length()-1
		If (!oMdlG5C:IsDeleted(n1) .and. !FwIsInCallStack('DELETELINE') .and. !FwIsInCallStack('UNDELETELINE') ) ; 
			.or. (!oMdlG5C:IsDeleted(n1) .and. n1 <> nLine .and.(FwIsInCallStack('DELETELINE') .or. FwIsInCallStack('UNDELETELINE'))  ) ; 
			.or. (FwIsInCallStack('DELETELINE') .and.  !oMdlG5C:IsDeleted(n1) .and. n1 <> nLine ) ; 
			.or. (FwIsInCallStack('UNDELETELINE') .and. oMdlG5C:IsDeleted(n1) .and. n1 == nLine )
		
			For n2 := n1+1 to oMdlG5C:Length()
				If (!oMdlG5C:IsDeleted(n2) .and. !FwIsInCallStack('DELETELINE') .and. !FwIsInCallStack('UNDELETELINE') ) ;
					.or. (!oMdlG5C:IsDeleted(n2) .and. n2 <> nLine .and.(FwIsInCallStack('DELETELINE') .or. FwIsInCallStack('UNDELETELINE'))  ) ;
					.or. (FwIsInCallStack('DELETELINE') .and.  !oMdlG5C:IsDeleted(n2) .and. n2 <> nLine ) ; 
					.or. (FwIsInCallStack('UNDELETELINE') .and. oMdlG5C:IsDeleted(n2) .and. n2 == nLine )
				
						
					If !oMdlG9C:IsEmpty() .and. !Empty(oMdlG9C:GetValue('G9C_CODORI'))
						oMdlG9C:AddLine()
					Endif

					If Empty(oMdlG9C:GetValue('G9C_SEQ'))
						oMdlG9C:SetValue('G9C_SEQ', StrZero(oMdlG9C:GetLine(),TamSx3('G9C_SEQ')[1]))
					Endif
					
					oMdlG9C:LoadValue('G9C_CODORI', oMdlG5C:GetValue('G5C_CODORI', n1))
					oMdlG9C:LoadValue('G9C_DESORI', oMdlG5C:GetValue('G5C_DESORI', n1))
					oMdlG9C:LoadValue('G9C_CODDES', oMdlG5C:GetValue('G5C_CODORI', n2))
					oMdlG9C:LoadValue('G9C_DESDES', oMdlG5C:GetValue('G5C_DESORI', n2))
					oMdlG9C:LoadValue('G9C_DTORIG', oMdlG6R:GetValue('G6R_DTIDA'))
					oMdlG9C:LoadValue('G9C_HRORIG', oMdlG6R:GetValue('G6R_HRIDA'))
					oMdlG9C:LoadValue('G9C_DTDEST', oMdlG6R:GetValue('G6R_DTVLTA'))
					oMdlG9C:LoadValue('G9C_HRDEST', oMdlG6R:GetValue('G6R_HRVLTA'))
					
					Exit
					
				Endif
			Next
			
		Endif
	Next 	
	
	oModel:GetModel( 'G9CDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'G9CDETAIL' ):SetNoDeleteLine( .T. )
	
	oMdlG9C:Goline(1)
Endif

Return


/*/{Protheus.doc} VldHrTrecho
(long_description)
@type function
@author jacomo.fernandes
@since 10/12/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldHrTrecho(oMdl,cDtIni,cHrIni,cDtFim,cHrFim)
Local lRet		:= .T.
Default cDtIni	:= DtoS(oMdl:GetValue('G9C_DTORIG'))
Default cHrIni	:= oMdl:GetValue('G9C_HRORIG')
Default cDtFim	:= Dtos(oMdl:GetValue('G9C_DTDEST'))
Default cHrFim	:= oMdl:GetValue('G9C_HRDEST')

If !Empty(cDtIni) .and. !Empty(cHrIni) .and. !Empty(cDtFim) .and. !Empty(cHrFim)
	lRet := cDtIni+cHrIni < cDtFim+cHrFim
Endif

Return lRet

/*/{Protheus.doc} ClearCp600
//TODO Descrição auto-gerada.
@author gustavo.silva2
@since 09/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function ClearCp600()
Local oModel    := FwModelActive()
Local oMdlG6R 	:= oModel:GetModel('MASTER')
Local cData		:= DTOS(oMdlG6R:GetValue('G6R_DTVLTA'))

cData := ''
cData := CTOD(cData)

	If oMdlG6R:GetValue('G6R_TIPITI') == '1' //1=Ida ; 2=Ida e Volta
		oMdlG6R:LoadValue('G6R_HRVLTA', '')
		oMdlG6R:LoadValue('G6R_DTVLTA',cData )
	EndIf

Return .T.

/*/{Protheus.doc} VlrPedagio
//TODO Descrição auto-gerada.
@author GTP
@since 28/12/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function VlrPedagio(oMdlCab)
Local nRet := 0
Local cCodOrig  := oMdlCab:GetValue('G6R_LOCORI')
Local cCodDes   := oMdlCab:GetValue('G6R_LOCDES')
Local cAliasTmp	:= GetNextAlias()
Local lEixos	:= G9T->(FieldPos("G9T_EIXOS")) > 0 .AND. G6R->(FieldPos("G6R_EIXOS")) > 0
Local cSeekG9T	:= Iif( lEixos, '% AND G9T_EIXOS = '+ALLTRIM(STR(oMdlCab:GetValue('G6R_EIXOS')))+'%', '%%' )

BeginSql Alias cAliasTmp

	Select G9T_VALTOT
	From %Table:G9T%
	WHERE
		G9T_FILIAL = %xFilial:G9T%
		AND G9T_CODORI = %Exp:cCodOrig%
		AND G9T_CODDES = %Exp:cCodDes%		
		AND %NotDel%
		%Exp:cSeekG9T%		
EndSql
 
If (cAliasTmp)->G9T_VALTOT > 0
	nRet	:= (cAliasTmp)->G9T_VALTOT
Endif

(cAliasTmp)->(DbCloseArea())

Return nRet


/*/{Protheus.doc} VlrPedagio
//TODO Descrição auto-gerada.
@author GTP
@since 28/12/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function RecnoPedag(cCodOrig,cCodDes,nEixos)
Local nRet := 0
Local cAliasTmp	:= GetNextAlias()
Local lEixos	:= G9T->(FieldPos("G9T_EIXOS")) > 0 .AND. G6R->(FieldPos("G6R_EIXOS")) > 0
Local cSeekG9T	:= Iif( lEixos, '% AND G9T_EIXOS = '+ALLTRIM(STR(nEixos))+'%', '%%' )

BeginSql Alias cAliasTmp

	Select R_E_C_N_O_
	From %Table:G9T%
	WHERE
		G9T_FILIAL = %xFilial:G9T%
		AND G9T_CODORI = %Exp:cCodOrig%
		AND G9T_CODDES = %Exp:cCodDes%		
		AND %NotDel%
		%Exp:cSeekG9T%		
EndSql
 
If (cAliasTmp)->R_E_C_N_O_ > 0
	nRet	:= (cAliasTmp)->R_E_C_N_O_
Endif

(cAliasTmp)->(DbCloseArea())

Return nRet

/*/{Protheus.doc} GA600AJKM()	
	
	@type  Function
	@author Totvs
	@since 04/02/2022
	@version version
	@param 		
	@return
	@example
	(examples)
	@see (links_or_references)
/*/
Function GA600AJKM()

GTPA600C()

Return

/*/{Protheus.doc} G600ChkNFlds(oStruct)	
	Função responsável por checar se existem os novos campos
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 31/01/2022
	@version version
	@param 		
		oStruct, objeto, instância da classe FwFormViewStruct ou 
			FwFormModelStruct
	@return 
	@example
	(examples)
	@see (links_or_references)
/*/
Function G600ChkNFlds(oStruct,aFields)

	Local nI			:= 0
	
	Local lRet			:= .T.

	Default oStruct := FWFormStruct(1,"G6R")
	Default aFields	:= {}

	If ( !lHasNewFields )

		If (Len(aNewFields) < 13)
			
			aNewFields := {}
			
			aAdd(aNewFields,'G6R_FCS')	
			aAdd(aNewFields,'G6R_DESFCS')
			aAdd(aNewFields,'G6R_FCI')
			aAdd(aNewFields,'G6R_DESFCI')
			aAdd(aNewFields,'G6R_STATUS')
			aAdd(aNewFields,'G6R_DTASSI')
			aAdd(aNewFields,'G6R_CNTPRO')
			aAdd(aNewFields,'G6R_NOMCNT')
			aAdd(aNewFields,'G6R_USRASS')
			aAdd(aNewFields,'G6R_DSCUSR')
			aAdd(aNewFields,'G6R_PEDIDO')
			aAdd(aNewFields,'G6R_JUSTIF')
		
		EndIf

		For nI := 1 to Len(aNewFields)
			
			If ( !(oStruct:HasField(aNewFields[nI])) )
				lRet := .f.
			EndIf

		Next nI

	EndIf
	
	aFields := aClone(aNewFields)
	
	lHasNewFields := lRet

Return(lRet)
