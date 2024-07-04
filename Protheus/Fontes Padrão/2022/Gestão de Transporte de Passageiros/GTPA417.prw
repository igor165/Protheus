#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#Include 'GTPA417.ch'
#INCLUDE 'PARMTYPE.CH'

Static nOpcao 
Static lHabilit		:= .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA417A()

Cadastro de Comissões de Contratos Fretamento Continuo.
@sample 	GTPA417A()

@author	Diego Faustino
@since		27/09/2021
@version 	P12
/*/
//-------------------------------------------------------------------
Function GTPA417A()

	nOpcao := 1

Return(GTPA417(nOpcao))

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA417()

Cadastro de Comissões de Contratos Viagens Especiais.
@sample 	GTPA417()

@author	Diego Faustino
@since		27/09/2021
@version 	P12
/*/
//-------------------------------------------------------------------
Function GTPA417B()

	nOpcao := 2

Return(GTPA417(nOpcao))

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA417()

Cadastro de Comissões de Contratos de Turismo.
@sample 	GTPA417()

@return 	oBrowse  

@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*/
//-------------------------------------------------------------------
Function GTPA417(nOpcao)
	
	Local oBrowse	:= Nil
	
	oBrowse := FWMBrowse():New()		
	oBrowse:SetAlias('GQS')
	oBrowse:SetMenuDef('GTPA417')  
	
	If GQS->(FieldPos('GQS_TPCOM')) > 0
		If nOpcao == 1
			oBrowse:SetDescription(STR0001) //Comissão de Fretamento Contínuo
			oBrowse:SetFilterDefault ( "GQS_TPCOM == '1'")
		Else
			oBrowse:SetDescription(STR0036) //Comissão de Viagens Especiais
			oBrowse:SetFilterDefault ( "GQS_TPCOM <> '1'")
		EndIf
	Else
		oBrowse:SetDescription(STR0037)//Comissão de Contratos de Turismo
	EndIf
	
	oBrowse:AddLegend("GQS_STATUS == '2' "	, "GREEN"	,STR0010)//"Ativo"
	oBrowse:AddLegend("GQS_STATUS <> '2' "	, "RED"		,STR0011)//"Inativo" 
	oBrowse:Activate()
	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef

@return 	aRotina  

@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef() 

	Local aRotina := {}
	
		ADD OPTION aRotina TITLE STR0002  	ACTION 'VIEWDEF.GTPA417' OPERATION 2 ACCESS 0 //Visualizar
		ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.GTPA417' OPERATION 3 ACCESS 0 //Incluir
		ADD OPTION aRotina TITLE STR0004 	ACTION 'VIEWDEF.GTPA417' OPERATION 4 ACCESS 0 //Alterar
		ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.GTPA417' OPERATION 5 ACCESS 0 //Excluir
		ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.GTPA417' OPERATION 8 ACCESS 0 //Imprimir
		ADD OPTION aRotina TITLE STR0007 	ACTION 'VIEWDEF.GTPA417' OPERATION 9 ACCESS 0 //Copiar
	
Return ( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de dados

@return 	oModel  

@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	
	Local oStruGQS	:= FWFormStruct( 1, 'GQS') // Recebe a Estrutura da Tabela Comissão de Contratos de Turismo;          
	Local oStruGQT	:= FWFormStruct( 1, 'GQT' )// Recebe a Estrutura da Tabela Processamento Comissão de Contratos de Turismo;
	Local bPosGQT	:= {|oModelGrid,nLine| VldComis(oModelGrid,nLine) } 
	Local bWhen     := {|oMdl, cField, uVal| GTP417WHEN(oMdl, cField, uVal)}
	Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
	Local bActive	:= {|oModel| VldAcess(oModel)}
	Local bPosValid := {|oModel| VldField(oModel)}
	
		oStruGQS:AddTrigger('GQS_TPPAG'	,'GQS_TPPAG',{||.T.}, bTrig)
		
		If GQS->(FieldPos('GQS_PROD')) > 0
			oStruGQS:AddTrigger('GQS_PROD','GQS_PROD'	,{||.T.}, bTrig)
		EndIf
		
		oStruGQS:SetProperty('GQS_CODIGO' 	, MODEL_FIELD_WHEN   	, {|| .F. })
		oStruGQS:SetProperty('GQS_AGENCI' 	, MODEL_FIELD_WHEN   	, {|| INCLUI })
		oStruGQS:SetProperty('GQS_VEND' 	, MODEL_FIELD_WHEN   	, {|| INCLUI })
		oStruGQS:SetProperty('GQS_CODIGO' 	, MODEL_FIELD_VALID   	, {|oModel| VldCdGQS(oModel) } )
		oStruGQS:SetProperty('GQS_AGENCI' 	, MODEL_FIELD_VALID   	, {|oModel| VldAgen(oModel) .AND. VldCtr(oModel) } )'
		oStruGQS:SetProperty('GQS_STATUS'	, MODEL_FIELD_INIT		, {|| '2'} )
		oStruGQS:SetProperty('GQS_STATUS' 	, MODEL_FIELD_WHEN   	, {|| !INCLUI})
		oStruGQS:SetProperty('GQS_STATUS' 	, MODEL_FIELD_VALID   	, {|oModel| VldCtr(oModel) } )
		oStruGQS:SetProperty('GQS_VEND' 	, MODEL_FIELD_VALID   	, {|oModel| VldVend(oModel) .AND. VldCtr(oModel) } )

		If GQS->(FieldPos('GQS_PROD')) > 0
			oStruGQS:SetProperty('GQS_PROD' , MODEL_FIELD_VALID   	, {|oModel| VldProd(oModel)})
		EndIf

		oStruGQS:SetProperty("GQS_DSR"		,MODEL_FIELD_OBRIGAT	, .T.)
		oStruGQS:SetProperty('GQS_COMSUP' 	, MODEL_FIELD_WHEN   	, {|| lHabilit})
		oStruGQS:SetProperty('GQS_DSR' 		, MODEL_FIELD_WHEN   	, {|| lHabilit})
		
		If GQS->(FieldPos('GQS_TPPAG')) > 0 .and. GQS->(FieldPos('GQS_TPCOM'))
			If nOpcao == 1
				oStruGQS:SetProperty("GQS_TPCOM"     , MODEL_FIELD_INIT	, {||'1'})
				oStruGQS:SetProperty("GQS_TPPAG"	 , MODEL_FIELD_INIT , {||'1'})
				oStruGQS:SetProperty("GQS_AGENCI"    , MODEL_FIELD_OBRIGAT	, .F.)
			Else
				oStruGQS:SetProperty("GQS_TPCOM"     , MODEL_FIELD_INIT	, {||'2'})
				oStruGQS:SetProperty("GQS_AGENCI"    , MODEL_FIELD_OBRIGAT	, .T.)
			EndIf

		EndIf
		
		If GQS->(FieldPos('GQS_VLRFIX')) > 0
			oStruGQS:SetProperty('GQS_VLRFIX', MODEL_FIELD_WHEN, bWhen)
		Endif

		If GQS->(FieldPos('GQS_PROD')) > 0
			oStruGQS:SetProperty('GQS_PROD', MODEL_FIELD_WHEN, bWhen)
		Endif

		oStruGQT:SetProperty("GQT_CVEND"	,MODEL_FIELD_OBRIGAT	, .F.)
		oStruGQT:SetProperty('GQT_PROD' 	, MODEL_FIELD_WHEN   	, {|| INCLUI .OR. Empty(FwFldGet('GQT_PROD')) })
		oStruGQT:SetProperty('*'			, MODEL_FIELD_WHEN 		, {|| lHabilit})
		
		oModel := MPFormModel():New("GTPA417",/*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )
		
		// ------------------------------------------+
		// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
		// ------------------------------------------+
		oModel:AddFields( 'GQSMASTER',/*cOwner*/, oStruGQS )
		
		oModel:AddGrid( 'GQTDETAIL', 'GQSMASTER', oStruGQT, /*bLinePre*/,/* bLinePost*/bPosGQT, /*bPre*/ , bPosGQT/*bPost*/, /*bLoad*/)
		
		// -------------------------------------------------+
		// FAZ RELACIONAMENTO ENTRE OS COMPONENTES DO MODEL |
		// -------------------------------------------------+
		oModel:SetRelation( 'GQTDETAIL',{{'GQT_FILIAL', 'xFilial( "GQT" )'},{ 'GQT_CODIGO','GQS_CODIGO'},{ 'GQT_CVEND','GQS_VEND'}} , GQT->( IndexKey( 1 ) )  )
		

		// ----------------------------------------+
		//  Não permite linhas duplicadas          |
		// ----------------------------------------+
		oModel:GetModel("GQTDETAIL"):SetUniqueLine( {'GQT_PROD','GQT_CVEND'} )
		
		// ----------------------------------------+
		//  Define a Chave Primaria do Modelo      |
		// ----------------------------------------+
		oModel:SetPrimaryKey( {"GQS_FILIAL","GQS_VEND","GQS_CODIGO","GQS_AGENCI"} )

		oModel:SetVldActivate(bActive)
		
		If nOpcao == 1
			oModel:SetDescription(STR0001) // "Comissão de Contratos de Turismo"
			oModel:GetModel("GQTDETAIL"):SetOptional(.T.)
		Else
			oModel:SetDescription(STR0036)
		EndIf

Return(oModel)
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição do Modelo de Visualização

@return 	oView  

@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*/
//-------------------------------------------------------------------    
Static Function ViewDef()

	Local oView     := FwFormView():New()       // Recebe o objeto da View
	Local oModel    := FwLoadModel( "GTPA417" )	// Objeto do Model 
	Local oStruGQS	:= FWFormStruct( 2, 'GQS' )	
	Local oStruGQT	:= FWFormStruct( 2, 'GQT' ) 
		
		oStruGQS:SetProperty("GQS_VEND",MVC_VIEW_LOOKUP,"SA3")
		If GQS->(FieldPos('GQS_PROD')) > 0	
			oStruGQS:SetProperty("GQS_PROD",MVC_VIEW_LOOKUP,"SB1")
		EndIf

		oStruGQT:SetProperty("GQT_PROD",MVC_VIEW_LOOKUP,"SB1")	
		
		If nOpcao == 1
			oStruGQS:RemoveField("GQS_AGENCI")
			oStruGQS:RemoveField("GQS_COMSUP")
		ElseIf nOpcao == 2
			oStruGQS:RemoveField("GQS_TPPAG")
			oStruGQS:RemoveField("GQS_VLRFIX")
			If GQS->(FieldPos('GQS_PROD')) > 0
				oStruGQS:RemoveField("GQS_PROD")
				oStruGQS:RemoveField("GQS_DPROD")
			EndIf
		Else
			If GQS->(FieldPos('GQS_PROD')) > 0
				oStruGQS:RemoveField("GQS_PROD")
				oStruGQS:RemoveField("GQS_DPROD")
			EndIf
		EndIf

		oStruGQS:RemoveField("GQS_TPCOM")
		oStruGQT:RemoveField("GQT_CVEND")
		oStruGQT:RemoveField("GQT_CODIGO")
		
		//-- Seta o Model para o modelo view
		oView:SetModel(oModel)
		
		//-------------------------------------------+
		// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
		//-------------------------------------------+
		oView:AddField( 'VIEW_GQSMASTER'	, oStruGQS	, 'GQSMASTER' )
		oView:AddGrid ( 'VIEW_GQTDETAIL'	, oStruGQT	, 'GQTDETAIL' )
				
		// Liga a identificacao do componente
		If nOpcao == 1
			oView:EnableTitleView ('VIEW_GQSMASTER'	,STR0001 )
		Else
			oView:EnableTitleView ('VIEW_GQSMASTER'	,STR0036 )		
		EndIf

		//-------------------------------------------+
		// DEFINE EM % A DIVISAO DA TELA, HORIZONTAL |
		//-------------------------------------------+
		oView:CreateHorizontalBox( 'SUPERIOR'	, 30 )
		oView:CreateHorizontalBox( 'INFERIOR'	, 70 )
		
		//-------------------------------------------+
		// DEFINE UM BOX PARA CADA COMPONENTE DO MVC |
		//-------------------------------------------+
		oView:SetOwnerView( 'VIEW_GQSMASTER' , 'SUPERIOR' )
		oView:SetOwnerView( 'VIEW_GQTDETAIL' , 'INFERIOR' )		
		
		oView:EnableTitleView ('VIEW_GQTDETAIL' ,STR0009 )// 'Comissão por Produto'

Return ( oView )
//-------------------------------------------------------------------  
/*/{Protheus.doc} VldCdGQS
Valida codigo do cadastro de comissão 
@type function
@author crisf
@since 30/10/2017
@version 1.0
@param oMldG5D, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------  
Function VldCdGQS(oMldG5S)

	Local cCodGQS	:= oMldGQS:GetValue("GQS_CODIGO")
	Local cVenGQS	:= oMldGQS:GetValue("GQS_VEND")
	Local aAreaGQS	:= GQS->(GetArea())
	Local lValido	:= .T.
	
		dbSelectArea("GQS")
		GQS->(dbSetOrder(1))//GQS_FILIAL, GQS_VEND, GQS_CODIGO
		if GQS->(dbSeek(xFilial("GQS")+cVenGQS+cCodGQS))
		
			While GQS->(dbSeek(xFilial("GQS")+cVenGQS+cCodGQS))
			
				ProxNum(@cCodGQS)
				
				lValido	:= oMldGQS:SetValue("GQS_CODIGO",cCodGQS)
					
			EndDo
			
		EndIf
				
		RestArea(aAreaGQS)
	
	
Return lValido
//-------------------------------------------------------------------
/*/{Protheus.doc} ProxNum
Busca o proximo numero disponivel
@type function
@author crisf
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function ProxNum(cNumProx)

	Local cTmpGQS	

		cTmpGQS	:= GetNextAlias()
		
		BeginSQL alias cTmpGQS
		
			  SELECT  MAX(GQS_CODIGO) CODIGOATUAL
			  FROM %Table:GQS% GQS
			  WHERE GQS.%NotDel%					  
 	
		EndSQL			
		
		cNumProx	:= SOMA1((cTmpGQS)->CODIGOATUAL)
		
		(cTmpGQS)->(dbCloseArea())
			
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} VldAgen
Valida agência
@type function
@author crisf
@since 17/11/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function VldAgen(oModel)

	Local aAreaGI6	:= GI6->(GetArea())
	Local oView		 := FwViewActive()  
	Local cCodAgen	:= oView:GetModel("GQSMASTER"):GetValue("GQS_AGENCI")
	Local lVldAgen	:= .T.
	
		//Verificado se o código da agência informado existente
		dbSelectArea("GI6")
		GI6->(dbSetORder(1))
		if !GI6->(dbSeek(xFilial("GI6")+cCodAgen))
			
			FWAlertHelp(STR0012+cCodAgen+STR0013,STR0014)//"Código da agência ("##") inexistente."##"Informar um código da agência existente." 
			lVldAgen	:= .F.
		
		Elseif FieldPos('GI6_MSBLQL')> 0 .AND. GI6->GI6_MSBLQL <> '2'
			
			FWAlertHelp(STR0012+cCodAgen+STR0015,STR0016)//"Código da agência ("## ##"Informar um código da agência ativo."
			lVldAgen	:= .F.	
				
		Elseif GI6->GI6_TIPO <> '1'
		
			FWAlertHelp(STR0031,STR0032)//"Somente agência do tipo própria poderá utilizar este cadastro."##"Revisar o cadastro da agência."	
			lVldAgen	:= .F.	
							
		EndIf
		
		RestArea(aAreaGI6)
		
Return 	lVldAgen	
//-------------------------------------------------------------------
/*/{Protheus.doc} VldVend
Valida o Vendedor
@type function
@author crisf
@since 17/11/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function VldVend(oModel)

	Local aAreaSA3	:= SA3->(GetArea())
	Local oView		 := FwViewActive()  
	Local cCodVend	:= oView:GetModel("GQSMASTER"):GetValue("GQS_VEND")
	Local lVldVen	:= .T.

		dbSelectArea("SA3")
		SA3->(dbSetORder(1))
		if !SA3->(dbSeek(xFilial("SA3")+cCodVend))	
		
			FWAlertHelp(STR0025,STR0026)//"Código não cadastrado"##"Informar um codigo existente. Clique na Lupa para pesquisar."
			lVldVen	:= .F.
		
		Elseif FieldPos('A3_MSBLQL')> 0 .AND. SA3->A3_MSBLQL <> '2'
			
			FWAlertHelp(STR0033+cCodVend+STR0034,STR0035)//"Código do vendedor "##" bloqueado/inativo." ##"Informar um código de vendedor ativo."
			lVldVen	:= .F.		
			
		EndIf

		RestArea(aAreaSA3)
			
Return lVldVen
//-------------------------------------------------------------------
/*/{Protheus.doc} VldCtr
Valida status de contrato
@type function
@author crisf
@since 26/10/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function VldCtr(oModel)

	Local oView		 := FwViewActive()  
	Local cCodAgen	:= oView:GetModel("GQSMASTER"):GetValue("GQS_AGENCI")
	Local cCodVend	:= oView:GetModel("GQSMASTER"):GetValue("GQS_VEND")
	Local cTMPGQS	:= GetNextAlias()
	Local lVldCtr	:= .T.
	Local cExpSQL	:= "%%"	 

	cCodAgen	:= StrTran(StrTran(cCodAgen,'"',' '),"'"," ")
	cCodVend	:= StrTran(StrTran(cCodVend,'"',' '),"'"," ")
	
	if oView:GetModel("GQSMASTER"):GetValue("GQS_STATUS") == '2'
		
		If ( nOpcao <> 1 )					
			cExpSQl := "% GQS.GQS_VEND = '" + cCodVend + "' AND GQS.GQS_AGENCI = '"+cCodAgen+"'%"				 	
		Else
			cExpSQl := "% GQS.GQS_VEND = '" + cCodVend + "' %"				 	
		EndIf	

		//Verifica se existe algum cadastro de Comissão de Contrato digitada que esteja ativo.
		BeginSQL alias cTMPGQS
		
				SELECT GQS_CODIGO
				FROM %Table:GQS% GQS
				WHERE GQS.%NotDel%	
				AND GQS.GQS_FILIAL = %xFilial:GQS%
				AND %Exp:cExpSQL%				
				AND GQS.GQS_STATUS = '2'
	
		EndSQL
		//GetlastQuery()[2] retorna a consulta 		
		
		if !(cTMPGQS)->(Eof())
		
			FWAlertHelp(STR0017+cCodAgen+STR0018+cCodVend+STR0019+(cTMPGQS)->GQS_CODIGO+STR0015,STR0020)
			//"Para este código de agência("##") e vendedor ("##") existe um cadastro ativo ("## "Alterar o código de cadastro ativo."
			lVldCtr	:= .F.	
			
		EndIf
	
	(cTMPGQS)->(dbCloseArea())
	
	EndIf

Return lVldCtr
//-------------------------------------------------------------------
/*/{Protheus.doc} VldAcess
valida acesso de manutenção do cadastro
@type function
@author crisf
@since 30/10/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function VldAcess(oModel)
	
	Local lVldAcess	:= .T.
	Local cTmpG94	:= ''
	
		if  oModel:GetOperation() == 4 .OR. oModel:GetOperation() == 5
			
			if GQS->GQS_STATUS == '1' 
		
				FWAlertHelp(STR0021,STR0022)//"Este cadastro esta inativo."## "Cadastros inativos não podem ser modificados."
				//"Este cadastro esta inativo."##"Cadastros inativos não podem ser modificados."
				lVldAcess	:= .F.
			
			Else
			
			//Verifico se o cadastro esta associado a algum calculo de comissão.
				cTmpG94	:= GetNextAlias()
				
				BeginSql Alias cTmpG94			
					SELECT 
						G94.G94_CODIGO, 
						G94.G94_VEND
					FROM 
						%Table:G94% G94
					WHERE 
						G94_FILIAL = %xFilial:G94%
					  	AND G94_SIMULA = ' '
					  	AND G94_CODGQS = %exp:GQS->GQS_CODIGO%
					  	AND G94.%NotDel%	  
				EndSql
				//GetlastQuery()[2]
				if !(cTmpG94)->(Eof())
				
					FWAlertHelp(STR0027+(cTmpG94)->G94_CODIGO+STR0028+(cTmpG94)->G94_VEND+STR0029,STR0030)
					//"Existe pelo menos um processamento de comissão ( Código"##" vendedor "
					//") calculada baseada neste cadastro, portanto, este cadastro não poderá ser excluído."
					//"Avaliar a possibilidade de excluir o calculo de comissão, caso a mesma não tenha sido exportada para a folha de pagamento."
					if oModel:GetOperation() == 5
						//Um cadastro vinculado não pode ser modificado mantendo assim o histórico de percentuais aplicados.
						lVldAcess	:= .F.
						
					Elseif oModel:GetOperation() == 4
						//Permite a visualização da grid e somente poderá inativar o cadastro.
						lHabilit	:= .F.
					
					EndIf
					
				EndIf
				
				(cTmpG94)->(dbCloseArea())
				
			EndIf
			
		EndIf
		
Return lVldAcess
//-------------------------------------------------------------------
/*/{Protheus.doc} VldComis
Valida preenchimento de percentuais
@type function
@author crisf
@since 30/10/2017
@version 1.0
@param oMdlGQT, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function VldComis(oMdlGQT,nLine)

	Local lVldCom	:= .T.
	Local oMldGQS	:=  oMdlGQT:GetModel()

		If oMldGQS:GetModel("GQSMASTER"):GetValue("GQS_TPPAG") == "2" .and. oMdlGQT:length() >= 1 .and. !oMdlGQT:IsDeleted(nLine)  

			FWAlertHelp(STR0023,STR0038)
			//"Preenchimento incorreto"## "Comissões com o Tipo de pagamento FIXO, não podem ter comissões por produto!"
			Return lVldCom	:= .F.
		
		EndIf		
		
		if !oMdlGQT:IsDeleted(nLine) .AND. oMdlGQT:GetValue("GQT_COMISS",nLine) <= 0.00 .OR. oMdlGQT:GetValue("GQT_COMISS",nLine) > 100.00 .and. lVldCom
		
			FWAlertHelp(STR0023,STR0024)
			//"Preenchimento incorreto"## "Preencher o campo %Comissão. Permitido percentuais maiores que 0.00% limitado a 100%"
			lVldCom	:= .F.
						
		EndIf		
	
	
Return lVldCom
//-------------------------------------------------------------------
/*/{Protheus.doc} GTP417WHEN
(long_description)
@type function
@author Diego Faustino
@since 24/09/2021
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function GTP417WHEN(oMdl, cField, uVal)
Local lRet := .T.

Do Case
    Case cField == "GQS_VLRFIX" .And. oMdl:GetValue('GQS_TPPAG') == "1"
        lRet := .F.
	Case cField == "GQS_PROD" .And. oMdl:GetValue('GQS_TPPAG') == "1"
		lRet := .F.
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
(long_description)
@type function
@author Diego Faustino
@since 19/10/2021
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)
Local oModel	:= oMdl:GetModel()
Local oMdlGQT	:= oModel:GetModel('GQTDETAIL')
Local nI		:= 0

Do Case
	Case cField == 'GQS_TPPAG'
		If oMdl:GetValue("GQS_TPPAG") == "2"
			oMdlGQT:SetNoUpdateLine(.T.)// Bloquea atualização da grid

			for nI := 1 To oMdlGQT:Length()
				oMdlGQT:Goline(nI)
				If !oMdlGQT:IsDeleted()
					oMdlGQT:DeleteLine()
				EndIf
			Next

		Else
			oMdl:LoadValue('GQS_VLRFIX', 0)

			If GQS->(FieldPos('GQS_PROD')) > 0
				oMdl:LoadValue('GQS_PROD', '')
				oMdl:LoadValue('GQS_DPROD', '')
			EndIf

			oMdlGQT:SetNoUpdateLine(.F.)// NÃO Bloquea atualização da grid

			For nI := 1 To oMdlGQT:Length()
				oMdlGQT:GoLine( nI )
				If oMdlGQT:IsDeleted()
					oMdlGQT:UnDeleteLine()
				EndIf
			Next
			
		EndIf
	Case cField == 'GQS_PROD'
		oMdl:SetValue('GQS_DPROD', POSICIONE('SB1',1,XFILIAL('SB1')+oMdl:GetValue('GQS_PROD'),'B1_DESC'))
EndCase

Return


/*/{Protheus.doc} VldField
(long_description)
@type  Static Function
@author user
@since 14/12/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function VldField(oMdl)
Local oModel  := oMdl:GetModel('GQSMASTER')
Local cTipPag := oModel:GetValue('GQS_TPPAG')
Local cValFix := oModel:GetValue('GQS_VLRFIX')
Local lRet    := .T.

If cTipPag == '2'
	If GQS->(FieldPos('GQS_PROD')) > 0
		If Empty(oModel:GetValue('GQS_PROD'))
			FWAlertHelp(STR0039, STR0040) //Campo Obrigatório //O campo produto não foi preenchido
			lRet := .F.
		ElseIf cValFix <= 0
			FWAlertHelp(STR0039, STR0041) //Campo Obrigatório //O campo valor fixo não foi preenchido
			lRet := .F.
		Endif
	Else
		FWAlertHelp(STR0044, STR0045) //O campo Produto (GQS_PROD) não existe //
		lRet := .F.
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} VldProd
(long_description)
@type  Static Function
@author user
@since 14/12/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function VldProd(oMdl)
Local cProd := oMdl:GetValue('GQS_PROD')
Local lRet  := .T.

IF !GTPExistCpo('SB1', cProd)
	FWAlertHelp(STR0042, STR0043) //Produto informado não existe ou se encontra inativo //Selecione um produto valido
	lRet := .F.
EndIf
	
Return lRet
