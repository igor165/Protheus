#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA281.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA281
Rotina para manutenção tabela GYF - Parâmetros

@author MRW Solutions
@since 24/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA281()

Local oGA281Brow

oGA281Brow := FWMBrowse():New()

oGA281Brow:SetAlias("GYF")
oGA281Brow:SetDescription(STR0001)	//"Parâmetros do Módulo"
oGA281Brow:DisableDetails()
oGA281Brow:SetMenuDef("GTPA281")
oGA281Brow:Activate()

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Função para exibir o menu de opções da rotina.

@sample	MenuDef()
 
@return	aRotina - Array
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA281' OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina TITLE STR0003 ACTION 'GA281PRECD()' 	  OPERATION 4 ACCESS 0	//'Preenche Cont.'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA281' OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE "Reprocessa" ACTION 'GTP281REP()' OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA281' OPERATION 5 ACCESS 0	//'Excluir'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA281' OPERATION 8 ACCESS 0	//'Imprimir'

Return aRotina

/*/{Protheus.doc} GTP281REP
(long_description)
@type  Function
@author user
@since 14/06/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTP281REP()
	FwMsgRun( ,{||LoadParamRules()},,"Verificando parametros do Modulo...")
Return 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Função para exibir o modelo de dados.
 
@sample	ModelDef()
 
@return	oModel - objeto model.
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oModel 
Local oStruGYF := FWFormStruct( 1,'GYF')

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('GTPA281')

// habilita/desabilita inclusão / alteração nos campos
oStruGYF:SetProperty('GYF_PARAME' , MODEL_FIELD_WHEN, {|oSubMdl| oSubMdl:GetOperation() == MODEL_OPERATION_INSERT })
oStruGYF:SetProperty('GYF_TIPO'   , MODEL_FIELD_WHEN, {|oSubMdl| oSubMdl:GetOperation() == MODEL_OPERATION_INSERT })
oStruGYF:SetProperty('GYF_CPX3'   , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_INSERT .AND. FwFldGet('GYF_TIPO')=='1'})
oStruGYF:SetProperty('GYF_DESCRI' , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_INSERT})
oStruGYF:SetProperty('GYF_PICTUR' , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_INSERT .And. FwFldGet('GYF_TIPO')$'1.2'})
If !IsInCallStack('GTPA019') .And. !IsInCallStack('GTPA026')
	oStruGYF:SetProperty('GYF_CONTEU' , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_UPDATE})
EndIf
oStruGYF:SetProperty('GYF_GRUPO'  , MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_INSERT})

oStruGYF:SetProperty('GYF_PARAME' , MODEL_FIELD_VALID, {|oModel|GTPA281B(oModel)})
oStruGYF:SetProperty('GYF_CONTEU' , MODEL_FIELD_VALID, {|oModel|GTPA281C(oModel)})

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'GYFMASTER', /*cOwner*/, oStruGYF, { |oMdlFld,cAction,cCampo,cConteudo| GA281SXB(oMdlFld,cAction,cCampo,cConteudo)} )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0007 )	//'Parâmetros do Módulo'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'GYFMASTER' ):SetDescription( 'GYF' )

oModel:SetPrimaryKey( {} )

Return(oModel)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Função para exibir a view de dados.
 
@sample	ViewDef()
 
@return	oView - objeto view.
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := ModelDef()
Local oView := Nil
Local oStruGYF := FWFormStruct( 2, 'GYF' )
Local _aSXB := SeleF3()

// Seta proriedade ComboBox
oStruGYF:SetProperty("GYF_CPX3",MVC_VIEW_COMBOBOX,_aSXB)

oStruGYF:SetProperty("GYF_CONTEU", MVC_VIEW_ORDEM,'08')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_GYF', oStruGYF, 'GYFMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_GYF', 'TELA' )

Return(oView)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA281PRECD()
Função para execução da função de preenchimento da consuta padrão.

Programa de cancelamento de bilhetes.
 
@sample	GA281PRECD()

@return	lRet - lógico.
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GA281PRECD()
	Local lRet := .F.
	lRet := FwExecView("PREENCTD","GTPA281A",MODEL_OPERATION_UPDATE)
Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA281SXB()
Função para carregar o código da consulta padrão sem a descrição da mesma.
 
@sample	GA281SXB()

@return	lRet - lógico.
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA281SXB(oMdlFld,cAction,cCampo,cConteudo)

	If AllTrim(cCampo) == "GYF_CPX3" .And. Upper(cAction) == "SETVALUE" .and. !Empty(cConteudo)
		
		oMdlFld:LoadValue("GYF_CPX3",Left(cConteudo,6))
		
	EndIf

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA281B()
Função para verificar se o parâmetro jã não está cadastrado

@sample	GTPA281B()

@return	lRet - lógico.
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GTPA281B(oModel)

LOCAL lRet := .T.

Local nOperation := oModel:GetOperation()

// Valida se pode ou não apagar uma linha do Grid
If nOperation == MODEL_OPERATION_INSERT

	If GYF->(DbSeek(xFilial("GYF")+FwFldGet('GYF_PARAME')))
		Help( ,, 'Help',, STR0008, 1, 0 )	//"Parâmetro já cadastrado!"
		lRet := .F.
	EndIf  
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA281C()
Função para validar o dado tipo booleano

@sample	GTPA281C()

@return	lRet - lógico.
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GTPA281C(oModel)

LOCAL lRet := .T.

If oModel:GetValue('GYF_TIPO') == '3' // Boolean 

	If Len(Upper(AllTrim(oModel:GetValue('GYF_CONTEU')))) # 3
		Help( ,, 'Help',, STR0009, 1, 0 )	//"Valor inválido! Digite .T. ou .F. !"
		lRet := .F.
	ElseIf Upper(AllTrim(oModel:GetValue('GYF_CONTEU'))) <> ".T."
		If Upper(AllTrim(oModel:GetValue('GYF_CONTEU'))) <> ".F."
			Help( ,, 'Help',, STR0009, 1, 0 )	//"Valor inválido! Digite .T. ou .F. !"
			lRet := .F.
		EndIf
	EndIf
	
ElseIf oModel:GetValue('GYF_TIPO') == '2' // Caractere
	If Type(AllTrim(oModel:GetValue('GYF_CONTEU'))) <> "N" 
			Help( ,, 'Help',, STR0010, 1, 0 )	//"Valor inválido! Digite apenas valores numéricos."
			lRet := .F.
	EndIf
EndIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GPA281PAR()
Função para retornar o conteúdo de um parâmetro

@sample	GTPA281C()

@return	lRet - lógico.
 
@author	Marcos Dias -  Inovação
@since		16/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GPA281PAR(cParamGYF)

LOCAL cCont := ""

GYF->(dbSetOrder(1))
If GYF->( DbSeek( xFilial("GYF")+PadR( cParamGYF,TamSX3("GYF_PARAME")[1])))
	cCont := GYF->GYF_CONTEU
EndIf

Return(AllTrim(cCont))
