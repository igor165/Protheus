#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA006.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA006()
Cadastro de Agências - GI6
@sample 	GTPA006()
@return 	oBrowse  Retorna o Cadastro de Agências
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Function GTPA006()
Local oBrowse := Nil

	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias('GI6')
	oBrowse:SetDescription(STR0001)	//Agências
	oBrowse:AddLegend("GI6_MSBLQL == '1'"	, "RED"		, STR0023, "GI6_MSBLQL")//"Inativo" 
	oBrowse:AddLegend("GI6_MSBLQL <> '1'"	, "GREEN"	, STR0024, "GI6_MSBLQL")//"Ativo"

	If GI6->(FieldPos("GI6_BLOQUE")) > 0
		oBrowse:AddLegend("GI6_BLOQUE == '1'"	, "RED"		, "Bloqueada", "GI6_BLOQUE") 
		oBrowse:AddLegend("GI6_BLOQUE == '2'"	, "GREEN"	, "Desbloqueada", "GI6_BLOQUE")
		oBrowse:AddLegend("GI6_BLOQUE == ' '"	, "WHITE"	, "Não processada", "GI6_BLOQUE")	
	EndIf	
	oBrowse:Activate()

Return oBrowse
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
@sample MenuDef()
@return aRotina  Retorna uma array contendo o Menu

@author Hilton T. Brandão - Consultir
@since 27/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	
	Local aRotina := {}
	
		ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.GTPA006' OPERATION 2 ACCESS 0 //Visualizar
		ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.GTPA006' OPERATION 3 ACCESS 0 //Incluir
		ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.GTPA006' OPERATION 4 ACCESS 0 //Alterar
		ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.GTPA006' OPERATION 5 ACCESS 0 //Excluir
		ADD OPTION aRotina TITLE STR0011	ACTION 'GTPA006A' OPERATION 9 ACCESS 0 // Configura Importação Daruma 
		
Return ( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados

@sample 	ModelDef()

@return 	oModel  Retorna o Modelo de Dados

@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local bPosValid	:= {|oModel|TP006TdOK(oModel)}	
	Local oModel 	:= MPFormModel():New('GTPA006', /*bPreValid*/, bPosValid, /* bCommit */, /*bCancel*/ )
	Local oStruGI6	:= FWFormStruct(1,'GI6' )
	Local oStruG9X	:= FWFormStruct(1,'G9X' )
	Local lValidH67	:= AliasInDic('H67')
	Local oStruH67	:= nil

	If lValidH67
		oStruH67:= FWFormStruct(1,'H67' )
	Endif

	SetModelStruct(oStruGI6,oStruG9X,oStruH67)

	oModel:AddFields( 'GI6MASTER', /*cOwner*/, oStruGI6 )
	oModel:AddGrid('G9XDETAIL','GI6MASTER',oStruG9X,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
	oModel:SetRelation('G9XDETAIL',{{ 'G9X_FILIAL','xFilial( "GI6" )'},{'G9X_CODGI6','GI6_CODIGO' }},G9X->(IndexKey(1)))
	oModel:GetModel("G9XDETAIL"):SetOptional(.T.)
	oModel:GetModel("G9XDETAIL"):SetUniqueLine({'G9X_CODUSR'})	
	oModel:SetDescription(STR0001)//Agências

	If lValidH67
		oModel:AddGrid('H67DETAIL','GI6MASTER',oStruH67,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
		oModel:SetRelation('H67DETAIL',{{ 'H67_FILIAL','xFilial( "GI6" )'},{'H67_CODGI6','GI6_CODIGO' }},H67->(IndexKey(1)))	
		oModel:GetModel("H67DETAIL"):SetOptional(.T.)
		oModel:GetModel("H67DETAIL"):SetUniqueLine({'H67_CODGI6','H67_CODGZC'})
	EndIF
	
Return ( oModel )
//-------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
(long_description)
@type function
@author jacomo.fernandes
@since 20/05/2019
@version 1.0
@param oStruGI6, objeto, (Descrição do parâmetro)
@param oStruG9X, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function SetModelStruct(oStruGI6,oStruG9X,oStruH67)
Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue|GTPA006Vld(oMdl,cField,cNewValue,cOldValue) }
Local bTrig		:= {|oMdl,cField,xVal|GTPA006TRG(oMdl,cField,xVal)}
Local bWhen     := {|oMdl, cField, uVal| GTP006WHEN(oMdl, cField, uVal)}

If ValType(oStruGI6) == "O"
	oStruGI6:SetProperty( "GI6_FCHCAI"	, MODEL_FIELD_VALID , bFldVld)
	oStruGI6:SetProperty( "GI6_FORNEC"	, MODEL_FIELD_VALID , bFldVld)
	oStruGI6:SetProperty( "GI6_LOJA"	, MODEL_FIELD_VALID , bFldVld)
	
	If GI6->(FieldPos("GI6_FILRES")) > 0
		oStruGI6:SetProperty( "GI6_FILRES"	, MODEL_FIELD_VALID , bFldVld)
	EndIf
	If GI6->(FieldPos("GI6_ENCFIL")) > 0
		oStruGI6:SetProperty( "GI6_ENCFIL"	, MODEL_FIELD_VALID , bFldVld)
	EndIf
	If GI6->(FieldPos("GI6_ENCHRI")) > 0
		oStruGI6:SetProperty( "GI6_ENCHRI"	, MODEL_FIELD_VALID , bFldVld)
	EndIf
	If GI6->(FieldPos("GI6_ENCHRF")) > 0
		oStruGI6:SetProperty( "GI6_ENCHRF"	, MODEL_FIELD_VALID , bFldVld)
	EndIf	

	If GI6->(FieldPos("GI6_TIPO")) > 0
		oStruGI6:AddTrigger("GI6_TIPO"	,"GI6_TIPO"				,{||.T.},bTrig)
	EndIf
	If GI6->(FieldPos("GI6_FILRES")) > 0
		oStruGI6:AddTrigger("GI6_FILRES"	,"GI6_FILRES"		,{||.T.},bTrig)
	EndIf
	If GI6->(FieldPos("GI6_ENCFIL")) > 0
		oStruGI6:AddTrigger("GI6_ENCFIL"	,"GI6_ENCFIL"		,{||.T.},bTrig)
	EndIf
	If GI6->(FieldPos("GI6_TIPOAG")) > 0
		oStruGI6:AddTrigger("GI6_TIPOAG"	,"GI6_TIPOAG"		,{||.T.},bTrig)
    EndIf

	oStruGI6:SetProperty("GI6_TIPO"     , MODEL_FIELD_INIT	, {||'1' })
	If GI6->(FieldPos("GI6_FILRES")) > 0
		oStruGI6:SetProperty("GI6_NFILRE"	, MODEL_FIELD_INIT	, {|oMdl|IF(oMdl:GetOperation() != 3 .AND. !EMPTY(GI6->GI6_FILRES), FWFilialName(cEmpAnt,GI6->GI6_FILRES),"") })
	EndIf
	If GI6->(FieldPos("GI6_ENCFIL")) > 0
		oStruGI6:SetProperty("GI6_ENCNFI"	, MODEL_FIELD_INIT	, {|oMdl|IF(oMdl:GetOperation() != 3 .AND. !EMPTY(GI6->GI6_ENCFIL), FWFilialName(cEmpAnt,GI6->GI6_ENCFIL),"") })
	EndIf
	If GI6->(FieldPos("GI6_TIPOAG")) > 0
		oStruGI6:SetProperty("GI6_DSTPAG"	, MODEL_FIELD_INIT	, {|oMdl|IF(oMdl:GetOperation() != 3, Posicione('GI5',1,xFilial('GI5')+GI6->GI6_TIPOAG,"GI5_DESCRI" ),"" ) } )
	EndIf
	If GI6->(FieldPos("GI6_ENCEXP")) > 0
		oStruGI6:SetProperty("GI6_ENCEXP"   , MODEL_FIELD_INIT	, {||'2' })
	EndIf
	If GI6->(FieldPos("GI6_ENCTRA")) > 0
		oStruGI6:SetProperty("GI6_ENCTRA"   , MODEL_FIELD_INIT	, {||'2' })
	EndIf
	If GI6->(FieldPos('GI6_COMFCH')) > 0
		oStruGI6:SetProperty('GI6_COMFCH', MODEL_FIELD_WHEN, bWhen)
	Endif
	If GI6->(FieldPos('GI6_CODH63')) > 0
		oStruGI6:SetProperty('GI6_CODH63', MODEL_FIELD_WHEN, {|| .F.})
	Endif

Endif

If ValType(oStruG9X) == "O"
	oStruG9X:SetProperty( "G9X_CODUSR"	, MODEL_FIELD_VALID , bFldVld)
Endif

If ValType(oStruH67) == "O"
	oStruH67:SetProperty("H67_CODGI6"	, MODEL_FIELD_INIT	, {|| GI6->GI6_CODIGO })	//Inicializa todos os campos
	oStruH67:SetProperty("H67_CODGZC"	, MODEL_FIELD_VALID , bFldVld)					//
	oStruH67:AddTrigger("H67_CODGZC"	,"H67_CODGZC"		,{||.T.},bTrig)
Endif
				
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA006Vld
(long_description)
@type function
@author jacomo.fernandes
@since 20/05/2019
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
//-------------------------------------------------------------------
Static Function GTPA006Vld(oMdl,cField,cNewValue,cOldValue)
Local lRet			:= .T.
Local oModel		:= oMdl:GetModel()
Local cMdlId		:= oMdl:GetId()
Local cTitulo		:= "GTPA006Vld"
Local cMsgErro		:= ""
Local cMsgSol		:= ""
Local aVldPerfil	:= {}

Do Case
	Case Empty(cNewValue)
		lRet := .T.
		
	Case cField == "GI6_FORNEC" .or. cField ==  "GI6_LOJA"
		IF !GxVlCliFor("SA2",oMdl:GetValue("GI6_FORNEC"),oMdl:GetValue("GI6_LOJA"))
			lRet := .F.
			cMsgErro	:= STR0025//"Fornecedor selecionado não encontrado ou se encontra inativo"
			cMsgSol		:= STR0026//"Selecione um fornecedor valido"
		Endif
		
	Case cField == "GI6_FILRES"  
		If !FWFilExist ( cEmpAnt , cNewValue )
			lRet := .F.
			cMsgErro	:= STR0027//"Filial selecionada não encontrada"
			cMsgSol		:= STR0028//"Selecione uma filial cadastrada"
		Endif
		
	Case cField == "GI6_ENCHRI" .or. cField ==  "GI6_ENCHRF"
		If !GxVldHora(cNewValue,/*lVldOnlyMin*/,.F.)
			lRet := .F.
			cMsgErro	:= I18n(STR0029,{GetSx3Cache(cField, "X3_TITULO")}) // "#1 invalida"
			cMsgSol		:= STR0030//"Informe uma hora entre 00:00 até 23:59"
		Elseif (!Empty(oMdl:GetValue('GI6_ENCHRI')) .and. !Empty(oMdl:GetValue('GI6_ENCHRF')) );
				.and. (oMdl:GetValue('GI6_ENCHRI') > oMdl:GetValue('GI6_ENCHRF'))
			lRet	:= .F.
			cMsgErro:= STR0031//"Hora inicial não pode ser maior que hora final"
			cMsgSol	:= STR0032//"Informe uma hora inicial menor que a hora final"
		Endif
	Case cField == "GI6_ENCFIL"
		If !FWFilExist ( cEmpAnt , cNewValue )
			lRet := .F.
			cMsgErro	:= STR0027//"Filial selecionada não encontrada
			cMsgSol		:= STR0028//"Selecione uma filial cadastrada" 
		Endif
	Case cField == "G9X_CODUSR"
		If !UsrExist(cNewValue)
			lRet	:= .F.
			cMsgErro:= STR0015 // "Usuário inválido"
			cMsgSol	:= STR0017 // "Selecione um usuário cadastrado"
		Endif
	Case cField == "H67_CODGZC"
		If Posicione("GZC",1,XFILIAL("GZC")+cNewValue,"GZC_INCMAN") <> '1'
			lRet := .F.
			cMsgErro:= STR0044  // Este registro não pode ser utilizado
			cMsgSol	:= STR0045 //  Receitas/Despesas com Inclusão Manual diferente de 1, fazem parte de itens reservados do sistema e não podem ser utilizados.
		EndIf
		If lRet
			If !Empty(Alltrim(GI6->GI6_CODH63)) 
				aVldPerfil := G006VldPerfil(GI6->GI6_CODH63,cNewValue)
				If !Empty(aVldPerfil[1]) .OR. !Empty(aVldPerfil[2]) // Se o perfil existir
					If aVldPerfil[1]  // Se o perfil estiver bloqueado
						lRet	:= .F.
						cMsgErro:= STR0037 // O perfil desta Agência esta bloqueado
						cMsgSol	:= STR0038 // Não é possível a inserção de Exceções em perfis de agência bloqueadas
					ElseIf aVldPerfil[2] // Se o Tipo de Documento já existir no perfil
						lRet	:= .F.
						cMsgErro:= STR0039  // Esta Receita/Despesa já faz parte do perfil da Agência
						cMsgSol	:= STR0040 // Somente são aceitas Receitas/Despesas que não esteja associada ao perfil
					EndIf
				EndIf
			Else
				lRet	:= .F.
				cMsgErro:=  STR0041 // Esta Agência não possuí perfil vinculado
				cMsgSol	:=  STR0042 //Para utilização de Exceção de Receitas/Despesas a Agência deve ser vículada a um perfil e este perfil deve estar desbloqueado.  
			Endif
		Endif
EndCase

If !lRet
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,cTitulo,cMsgErro,cMsgSol,cNewValue,cOldValue)
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA006TRG
(long_description)
@type function
@author jacomo.fernandes
@since 20/05/2019
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
Static Function GTPA006TRG(oMdl,cField,xVal)
Local oView			:= FWViewActive()
Local cTipoH67 		:= ''
Local cDescH67 		:= ''
Do Case
	Case cField == "GI6_FILRES"
		oMdl:LoadValue('GI6_NFILRE', If(!Empty(xVal),FWFilialName(cEmpAnt,xVal),'') )
	Case cField == "GI6_ENCFIL"
		oMdl:LoadValue('GI6_ENCNFI', If(!Empty(xVal),FWFilialName(cEmpAnt,xVal),'') )
	Case cField == "GI6_FCHCAI"
		oMdl:LoadValue('GI6_DIASFC', 1 )
	Case cField == "GI6_TIPOAG"
		oMdl:LoadValue('GI6_DSTPAG'	, Posicione('GI5',1,xFilial('GI5')+xVal,"GI5_DESCRI" ) )
		oMdl:LoadValue('GI6_TIPO'	, Posicione('GI5',1,xFilial('GI5')+xVal,"GI5_TIPO" ) )
	Case cField == "GI6_TIPO" .And. xVal == "1" .And. GI6->(FieldPos('GI6_COMFCH')) > 0
		oMdl:LoadValue('GI6_COMFCH', '2')
	Case cField == "H67_CODGZC"
		cTipoH67 	:= RTRIM(POSICIONE("GZC",1,XFILIAL("GZC")+xVal,"GZC_TIPO"))
		cDescH67	:= RTRIM(POSICIONE("GZC",1,XFILIAL("GZC")+xVal,"GZC_DESCRI"))
		oMdl:SetValue('H67_TIPO'	, cTipoH67, .T.)
 		oMdl:SetValue('H67_DESGCZ'	, cDescH67, .T.)
		oMdl:SetValue('H67_DTINC'	, Date())
EndCase

If !IsBlind() .and. ValType(oView) == "O"
	oView:Refresh()
Endif

Return xVal

//-------------------------------------------------------------------
/*/{Protheus.doc} GTP006WHEN
(long_description)
@type function
@author flavio.martins
@since 08/09/2021
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
Static Function GTP006WHEN(oMdl, cField, uVal)
Local lRet		:= .T.

Do Case
    Case cField == "GI6_COMFCH" .And. oMdl:GetValue('GI6_TIPO') == "1"
        lRet := .F.
EndCase

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição do interface para visualizar os históricos
@sample 	ViewDef()
@return 	oView  Retorna a View
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel	:= FWLoadModel( 'GTPA006' )
	Local oView		:= FWFormView():New()
	Local oStruGI6	:= FWFormStruct(2,'GI6' )
	Local oStruG9X	:= FWFormStruct(2,'G9X', {|cCampo| AllTrim(cCampo) + '|' $ "G9X_CODUSR|G9X_NOMUSR|" })
	Local lValidH67	:= AliasInDic('H67')
	Local oStruH67  := Nil

	SetViewStruct(oStruGI6,oStruG9X, oStruH67)
	oView:SetModel( oModel )
	oView:SetDescription(STR0001)
	oView:AddField('VIEWGI6', oStruGI6, 'GI6MASTER' )
	oView:AddGrid('VIEWG9X'	, oStruG9X, 'G9XDETAIL' )
	oView:CreateHorizontalBox('UPPER',65)
	oView:CreateHorizontalBox('BOTTOM',35)
	oView:SetOwnerView('VIEWGI6','UPPER')
	oView:SetOwnerView('VIEWG9X','BOTTOM')	
	oView:EnableTitleView("VIEWG9X",STR0012) //-- Usuários

	If lValidH67
		oStruH67 := FWFormStruct(2,'H67', {|cCampo| AllTrim(cCampo) + '|' $ "H67_CODGZC|H67_TIPO|H67_DESGCZ|H67_DTINC|" })
		oView:AddGrid('VIEWH67'	, oStruH67, 'H67DETAIL' )	
		// Cria BOX na Tela
		oView:CreateFolder("FOLDER", "BOTTOM")
		oView:AddSheet("FOLDER", "ABA01", STR0012) // Usuários 
		oView:AddSheet("FOLDER", "ABA02", STR0043) // Exceção de Receitas e Despesas
		oView:CreateVerticalBox("USUARIO", 100, , , 'FOLDER', 'ABA01')
		oView:CreateVerticalBox("RECDESP",100 , , , 'FOLDER', 'ABA02')
		// Define cada Componente a um BOX	
		oView:SetOwnerView('VIEWG9X','USUARIO')	
		OView:SetOwnerView('VIEWH67','RECDESP')
		oView:EnableTitleView("VIEWG9X",'')
	EndIf	

Return ( oView )

/*/{Protheus.doc} SetViewStruct
(long_description)
@type function
@author jacomo.fernandes
@since 20/05/2019
@version 1.0
@param oStruGI6, objeto, (Descrição do parâmetro)
@param oStruG9X, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStruGI6,oStruG9X,oStruH67)
If ValType(oStruGI6) == "O"
	
	oStruGI6:AddGroup( "AGENCIA", STR0018, "" , 2 )//Agência
	oStruGI6:SetProperty("GI6_CODIGO" , MVC_VIEW_GROUP_NUMBER, "AGENCIA" )
	oStruGI6:SetProperty("GI6_DESCRI" , MVC_VIEW_GROUP_NUMBER, "AGENCIA" )
	
	oStruGI6:AddGroup( "TIPOAGENCIA"  , "", "" , 1)

	If GI6->(FieldPos("GI6_TIPOAG")) > 0
		oStruGI6:SetProperty("GI6_TIPOAG" , MVC_VIEW_GROUP_NUMBER, "TIPOAGENCIA" )
		oStruGI6:SetProperty("GI6_DSTPAG" , MVC_VIEW_GROUP_NUMBER, "TIPOAGENCIA" )
		oStruGI6:SetProperty("GI6_TIPO"   , MVC_VIEW_GROUP_NUMBER, "TIPOAGENCIA" )
	EndIf

	oStruGI6:AddGroup( "TIPOFECHAMENTO"  , "", "" , 1)
	oStruGI6:SetProperty("GI6_DEPOSI" , MVC_VIEW_GROUP_NUMBER, "TIPOFECHAMENTO" )

	If GI6->(FieldPos("GI6_TITPRO")) > 0
		oStruGI6:SetProperty("GI6_TITPRO", MVC_VIEW_GROUP_NUMBER,'TIPOFECHAMENTO')
	EndIf

	oStruGI6:SetProperty("GI6_FCHCAI" , MVC_VIEW_GROUP_NUMBER, "TIPOFECHAMENTO" )
	oStruGI6:SetProperty("GI6_DIASFC" , MVC_VIEW_GROUP_NUMBER, "TIPOFECHAMENTO" )
	
	oStruGI6:AddGroup( "INFOEXTRA"  , "", "" , 1)
	oStruGI6:SetProperty("GI6_LOCALI" , MVC_VIEW_GROUP_NUMBER, "INFOEXTRA" )
	oStruGI6:SetProperty("GI6_DESLOC" , MVC_VIEW_GROUP_NUMBER, "INFOEXTRA" )
	oStruGI6:SetProperty("GI6_MSBLQL" , MVC_VIEW_GROUP_NUMBER, "INFOEXTRA" )
	
	oStruGI6:AddGroup( "RESPONSAVEL"  , STR0019, "" , 2)
	oStruGI6:SetProperty("GI6_COLRSP" , MVC_VIEW_GROUP_NUMBER, "RESPONSAVEL" )
	oStruGI6:SetProperty("GI6_NOMCOL" , MVC_VIEW_GROUP_NUMBER, "RESPONSAVEL" )
	oStruGI6:SetProperty("GI6_RECCOM" , MVC_VIEW_GROUP_NUMBER, "RESPONSAVEL" )
	oStruGI6:SetProperty("GI6_DSR" 	  , MVC_VIEW_GROUP_NUMBER, "RESPONSAVEL" )
	
	If GI6->(FieldPos("GI6_COMFCH")) > 0
		oStruGI6:SetProperty("GI6_COMFCH", MVC_VIEW_GROUP_NUMBER,'RESPONSAVEL')
	EndIf

	oStruGI6:AddGroup( "FISCAL"  , STR0035, "" , 2)//"Dados Fiscais"
	If GI6->(FieldPos("GI6_FILRES")) > 0
		oStruGI6:SetProperty("GI6_FILRES"	, MVC_VIEW_GROUP_NUMBER, "FISCAL" )
		oStruGI6:SetProperty("GI6_NFILRE"	, MVC_VIEW_GROUP_NUMBER, "FISCAL" )
	EndIf
	oStruGI6:AddGroup( "BANCO"  , "", "" , 1)
	oStruGI6:SetProperty("GI6_BANCO"	, MVC_VIEW_GROUP_NUMBER, "BANCO" )
	oStruGI6:SetProperty("GI6_AGENCI"	, MVC_VIEW_GROUP_NUMBER, "BANCO" )
	oStruGI6:SetProperty("GI6_CONTA"	, MVC_VIEW_GROUP_NUMBER, "BANCO" )
	
	oStruGI6:AddGroup( "UNIDADENEGOCIO"  , "", "" , 1)
	oStruGI6:SetProperty("GI6_CODADK"	, MVC_VIEW_GROUP_NUMBER, "UNIDADENEGOCIO" )
	oStruGI6:SetProperty("GI6_DESADK"	, MVC_VIEW_GROUP_NUMBER, "UNIDADENEGOCIO" )
	
	oStruGI6:AddGroup( "CLIENTE"  , "", "" , 1)
	oStruGI6:SetProperty("GI6_CLIENT"	, MVC_VIEW_GROUP_NUMBER, "CLIENTE" )
	oStruGI6:SetProperty("GI6_LJCLI"	, MVC_VIEW_GROUP_NUMBER, "CLIENTE" )
	oStruGI6:SetProperty("GI6_NOMCLI"	, MVC_VIEW_GROUP_NUMBER, "CLIENTE" )
	
	oStruGI6:AddGroup( "FORNECEDOR"  , "", "" , 1)
	oStruGI6:SetProperty("GI6_FORNEC"	, MVC_VIEW_GROUP_NUMBER, "FORNECEDOR" )
	oStruGI6:SetProperty("GI6_LOJA"		, MVC_VIEW_GROUP_NUMBER, "FORNECEDOR" )
	oStruGI6:SetProperty("GI6_NOMFOR"	, MVC_VIEW_GROUP_NUMBER, "FORNECEDOR" )
	
	oStruGI6:AddGroup( "CLIBIL"  , "", "" , 1)
	oStruGI6:SetProperty("GI6_CLIBIL"	, MVC_VIEW_GROUP_NUMBER, "CLIBIL" )
	oStruGI6:SetProperty("GI6_LJBIL"	, MVC_VIEW_GROUP_NUMBER, "CLIBIL" )
	oStruGI6:SetProperty("GI6_NOMBIL"	, MVC_VIEW_GROUP_NUMBER, "CLIBIL" )
	
	oStruGI6:AddGroup( "ENCOMENDAS"  , STR0036, "" , 2)//"Encomendas"
	If GI6->(FieldPos("GI6_ENCEXP")) > 0
		oStruGI6:SetProperty("GI6_ENCEXP" , MVC_VIEW_GROUP_NUMBER, "ENCOMENDAS" )
	EndIf
	If GI6->(FieldPos("GI6_ENCFIL")) > 0
		oStruGI6:SetProperty("GI6_ENCFIL" , MVC_VIEW_GROUP_NUMBER, "ENCOMENDAS" )
	EndIf
	If GI6->(FieldPos("GI6_ENCNFI")) > 0
		oStruGI6:SetProperty("GI6_ENCNFI" , MVC_VIEW_GROUP_NUMBER, "ENCOMENDAS" )
	EndIf
	If GI6->(FieldPos("GI6_ENCTRA")) > 0
		oStruGI6:SetProperty("GI6_ENCTRA" , MVC_VIEW_GROUP_NUMBER, "ENCOMENDAS" )
	EndIf

	oStruGI6:AddGroup( "HORARIO"  , "", "" , 1)
	If GI6->(FieldPos("GI6_ENCHRI")) > 0
		oStruGI6:SetProperty("GI6_ENCHRI" , MVC_VIEW_GROUP_NUMBER, "HORARIO" )
	EndIf
	If GI6->(FieldPos("GI6_ENCHRF")) > 0
		oStruGI6:SetProperty("GI6_ENCHRF" , MVC_VIEW_GROUP_NUMBER, "HORARIO" )
	EndIf
	
	oStruGI6:SetProperty("GI6_CODIGO"	, MVC_VIEW_ORDEM,'01')
	oStruGI6:SetProperty("GI6_DESCRI"	, MVC_VIEW_ORDEM,'02')
	If GI6->(FieldPos("GI6_TIPOAG")) > 0
		oStruGI6:SetProperty("GI6_TIPOAG"	, MVC_VIEW_ORDEM,'03')
		oStruGI6:SetProperty("GI6_DSTPAG"	, MVC_VIEW_ORDEM,'04')
	EndIf

	oStruGI6:SetProperty("GI6_TIPO"  	, MVC_VIEW_ORDEM,'05')
	oStruGI6:SetProperty("GI6_DEPOSI"	, MVC_VIEW_ORDEM,'06')

	If GI6->(FieldPos("GI6_TITPRO")) > 0
		oStruGI6:SetProperty("GI6_TITPRO", MVC_VIEW_ORDEM,'07')
	EndIf

	oStruGI6:SetProperty("GI6_FCHCAI"	, MVC_VIEW_ORDEM,'08')
	oStruGI6:SetProperty("GI6_DIASFC"	, MVC_VIEW_ORDEM,'09')
	oStruGI6:SetProperty("GI6_LOCALI"	, MVC_VIEW_ORDEM,'10')
	oStruGI6:SetProperty("GI6_DESLOC"	, MVC_VIEW_ORDEM,'11')
	oStruGI6:SetProperty("GI6_MSBLQL"	, MVC_VIEW_ORDEM,'12')
	oStruGI6:SetProperty("GI6_COLRSP"	, MVC_VIEW_ORDEM,'13')
	oStruGI6:SetProperty("GI6_NOMCOL"	, MVC_VIEW_ORDEM,'14')
	oStruGI6:SetProperty("GI6_RECCOM"	, MVC_VIEW_ORDEM,'15')
	oStruGI6:SetProperty("GI6_DSR" 	 	, MVC_VIEW_ORDEM,'16')

	If GI6->(FieldPos("GI6_FILRES")) > 0
		oStruGI6:SetProperty("GI6_FILRES"	, MVC_VIEW_ORDEM,'17')
		oStruGI6:SetProperty("GI6_NFILRE"	, MVC_VIEW_ORDEM,'18')
	EndIf

	oStruGI6:SetProperty("GI6_BANCO"	, MVC_VIEW_ORDEM,'19')
	oStruGI6:SetProperty("GI6_AGENCI"	, MVC_VIEW_ORDEM,'20')
	oStruGI6:SetProperty("GI6_CONTA"	, MVC_VIEW_ORDEM,'21')
	oStruGI6:SetProperty("GI6_CODADK"	, MVC_VIEW_ORDEM,'22')
	oStruGI6:SetProperty("GI6_DESADK"	, MVC_VIEW_ORDEM,'23')
	oStruGI6:SetProperty("GI6_CLIENT"	, MVC_VIEW_ORDEM,'24')
	oStruGI6:SetProperty("GI6_LJCLI"	, MVC_VIEW_ORDEM,'25')
	oStruGI6:SetProperty("GI6_NOMCLI"	, MVC_VIEW_ORDEM,'26')
	oStruGI6:SetProperty("GI6_FORNEC"	, MVC_VIEW_ORDEM,'27')
	oStruGI6:SetProperty("GI6_LOJA"		, MVC_VIEW_ORDEM,'28')
	oStruGI6:SetProperty("GI6_NOMFOR"	, MVC_VIEW_ORDEM,'29')
	oStruGI6:SetProperty("GI6_CLIBIL"	, MVC_VIEW_ORDEM,'30')
	oStruGI6:SetProperty("GI6_LJBIL"	, MVC_VIEW_ORDEM,'31')
	oStruGI6:SetProperty("GI6_NOMBIL"	, MVC_VIEW_ORDEM,'32')

	If GI6->(FieldPos("GI6_ENCEXP")) > 0
		oStruGI6:SetProperty("GI6_ENCEXP"	, MVC_VIEW_ORDEM,'33')
	EndIf

	If GI6->(FieldPos("GI6_ENCFIL")) > 0
		oStruGI6:SetProperty("GI6_ENCFIL"	, MVC_VIEW_ORDEM,'34')
	EndIf

	If GI6->(FieldPos("GI6_ENCNFI")) > 0
		oStruGI6:SetProperty("GI6_ENCNFI"	, MVC_VIEW_ORDEM,'35')
	EndIf

	If GI6->(FieldPos("GI6_ENCTRA")) > 0
		oStruGI6:SetProperty("GI6_ENCTRA"	, MVC_VIEW_ORDEM,'36')
	EndIf

	If GI6->(FieldPos("GI6_ENCHRI")) > 0
		oStruGI6:SetProperty("GI6_ENCHRI"	, MVC_VIEW_ORDEM,'37')
	EndIf

	If GI6->(FieldPos("GI6_ENCHRF")) > 0
		oStruGI6:SetProperty("GI6_ENCHRF"	, MVC_VIEW_ORDEM,'38')
	EndIf

	If GI6->(FieldPos("GI6_BOLETO")) > 0
		oStruGI6:RemoveField("GI6_BOLETO")
	EndIf

	If GI6->(FieldPos("GI6_BLOQUE")) > 0
		oStruGI6:RemoveField("GI6_BLOQUE")
	EndIf

	If GI6->(FieldPos("GI6_ENCFIL")) > 0
		oStruGI6:RemoveField("GI6_ENCFIL")
		oStruGI6:RemoveField("GI6_ENCNFI")
	EndIf

Endif	
Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 
@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXml, nTypeTrans, cTypeMessage )

	Local aRet := {}

	aRet:= GTPI006( cXml, nTypeTrans, cTypeMessage )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TP006TdOK
Realiza validação se nao possui chave duplicada antes do commit
@param	oModel
@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP006TdOK(oModel)
Local lRet 	:= .T.
Local oMdlGI6	:= oModel:GetModel('GI6MASTER')
Local cMdlId	:= oModel:GetId()
Local cTitulo	:= "TP006TdOK"
Local cMsgErro	:= ""
Local cMsgSol	:= ""

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGI6:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGI6:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GI6", oMdlGI6:GetValue("GI6_CODIGO")))
        lRet        := .F.
        cMsgErro	:= STR0014
        cMsgSol     := "Informe outro código para a agencia"
    EndIf

	If oMdlGI6:GetValue('GI6_DEPOSI') == '3' .AND. (Empty(oMdlGI6:GetValue('GI6_BANCO')) .OR. Empty(oMdlGI6:GetValue('GI6_AGENCI')) .OR. Empty(oMdlGI6:GetValue('GI6_CONTA')))
		lRet        := .F.
        cMsgErro	:= 'Para o tipo de pagamento boleto, os campos Banco, Agencia e Conta são obrigatorios.'
        cMsgSol     := "Preencha os campos Banco, Agencia e Conta."
	EndIf

	If FwIsInCallStack('GTPA006')
		If GI6->(FieldPos("GI6_ENCEXP")) > 0
			If lRet .and. oMdlGI6:GetValue("GI6_ENCEXP") == "1"
				If Empty(oMdlGI6:GetValue("GI6_LOCALI"))
					lRet        := .F.
					cMsgErro	:= "Necessário informar a localidade quando a agencia for de encomenda"
					cMsgSol     := "Informe outro código da localidade ou informe que não é uma agencia de encomenda.
				// ElseIf Empty(oMdlGI6:GetValue("GI6_ENCFIL"))
				// 	lRet        := .F.
				// 	cMsgErro	:= "Necessário informar a Filial emitente de encomenda quando a agencia for de encomenda"
				// 	cMsgSol     := "Informe outro código da filial ou informe que não é uma agencia de encomenda"
				// ElseIf !VldUfFilLoc(oMdlGI6:GetValue("GI6_LOCALI"),oMdlGI6:GetValue("GI6_ENCFIL"))
				// 	lRet        := .F.
				// 	cMsgErro	:= "A Localidade da agencia tem que ser do mesmo estado que a Filial emitente de encomenda"
				// 	cMsgSol     := "Informe outro código da filial/localidade ou informe que não é uma agencia de encomenda"
				ElseIf Empty(oMdlGI6:GetValue("GI6_CEPENC")) .Or. Len(Alltrim(oMdlGI6:GetValue("GI6_CEPENC"))) < 8
					lRet        := .F.
					cMsgErro	:= "CEP inválido ou não informado para a agência"
					cMsgSol     := "O CEP é obrigatório para agências que enviam encomendas"
				Endif
			Endif
		EndIf
    Endif
EndIf

If !lRet
	oModel:SetErrorMessage(cMdlId,,cMdlId,,cTitulo,cMsgErro,cMsgSol)
Endif

Return (lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} VldUfFilLoc
(long_description)
@type function
@author jacomo.fernandes
@since 20/05/2019
@version 1.0
@param cLocEnc, character, (Descrição do parâmetro)
@param cFilEnc, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function VldUfFilLoc(cLocEnc,cFilEnc)
Local cUfLoc    := Posicione('GI1',1,xFilial('GI1')+cLocEnc,"GI1_UF")
Local cUfFil    := Posicione('SM0',1,cEmpAnt+cFilEnc,"M0_ESTENT")

Return cUfLoc == cUfFil

/*/{Protheus.doc} G006VldPerfil
    (Valida se o Perfil do Usuário tem acesso equivalente)
    @type  Static Function
    @author marcelo.adente
    @since 13/07/2022
    @version 1.0
    @param cAgencia, Caaracter, Agencia 
    @param cRecDesp, Caracter, Receita ou Despesa
    @return lRet, Boleano, Valida se a despesa não está cadastrada para o perfil da agência

/*/
Static Function G006VldPerfil(cAgPerfil, cRecDesp)
Local cSQL          := ''
Local CAlias        := GetNextAlias()
local aArea         := getArea()
Local cFilialH63    := xFilial("H63")
Local cFilialH64    := xFilial("H64")
Local cFilialGZC    := xFilial("GZC")
Local aVldPerfil	:= Array(2)
Local lVldDic		:= AliasInDic("H63") .And. AliasInDic("H64") 


If lVldDic
	cSQL += " SELECT "
	cSQL += "     H63.H63_MSBLQL, "
	cSQL += "     H63.H63_CODIGO, "
	cSQL += "     H64.H64_CODGZC, "
	cSQL += "     GZC.GZC_INCMAN "
	cSQL += " FROM "
	cSQL +=  RetSqlName("H63") + " H63 "
	cSQL += "     LEFT JOIN " + RetSqlName("H64") + "  H64 ON H64.H64_FILIAL = " + ValToSQL(cFilialH64)
	cSQL += "     AND H64.H64_CODH63 = H63.H63_CODIGO "
	cSQL += " 	AND H64.H64_CODGZC = " + ValToSQL(cRecDesp)
	cSQL += " 	AND H63.D_E_L_E_T_ = ' ' "
	cSQL += "     LEFT JOIN " + RetSqlName("GZC") + " GZC ON GZC.GZC_FILIAL = " + ValToSQL(cFilialGZC) 
	cSQL += "     AND GZC.GZC_CODIGO = " + ValToSQL(cRecDesp)
	cSQL += " 	AND GZC.D_E_L_E_T_ = ' ' "
	cSQL += " WHERE "
	cSQL += "     H63.H63_CODIGO = " + ValToSQL(cAgPerfil)
	cSQL += "     AND H63.H63_FILIAL = " + ValToSQL(cFilialH63)
	cSQL += "     AND H63.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL) 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAlias,.T.,.T.)

	If (cAlias)->(!EOF()) 

		If (cAlias)->(H63_MSBLQL) == '1' // Perfil Bloqueado
			aVldPerfil[1]:= .T.
		EndIf

		If !Empty(Alltrim((cAlias)->(H64_CODGZC))) // Existe Registro de Tipo de Documento na Tabela H64
			aVldPerfil[2]:= .T.
		EndIf
	EndIf

	cAlias:= Nil

Endif

RestArea(aArea)

Return aVldPerfil
