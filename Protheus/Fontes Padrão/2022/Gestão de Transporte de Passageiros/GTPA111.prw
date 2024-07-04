#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA111.CH'

// Vari�veis e controle do vale correspodnente que ser� alterado
Static cCodNumVal := ""
Static cNumValCur := ""
Static nValorCur  := 0
Static nSldDevCur := 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA111()
Presta��o de Contas de Vales
 
@sample	GTPA111()
 
@return	oBrowse  Retorna o Cadastro de Presta��o de Contas de Vales
 
@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA111()

Local oBrowse	:= Nil		

Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("GQQ")
oBrowse:SetDescription(STR0001)	// Presta��o de Contas
oBrowse:Activate()

Return (oBrowse)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Defini��o do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com op��es do menu
 
@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003   ACTION 'VIEWDEF.GTPA111' OPERATION 2 ACCESS 0 // #Visualizar
ADD OPTION aRotina TITLE STR0004   ACTION 'GA111Ope(3)' 	OPERATION 3 ACCESS 0 // #Incluir
ADD OPTION aRotina TITLE STR0011   ACTION 'GA111Ope(5)' 	OPERATION 5 ACCESS 0 // #Excluir
ADD OPTION aRotina TITLE STR0009   ACTION 'GTPR111()' 		OPERATION 2 ACCESS 0 // #Imprimir Recibo

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruGQP     := FWFormStruct(1,'GQP')
Local oStruGQQ     := FWFormStruct(1,'GQQ')
Local bPosValidMdl := {|oModel| GA111PosValidMdl(oModel)}
Local oModel	   := MPFormModel():New('GTPA111', /*bPreValidMdl*/, bPosValidMdl, /*bCommit*/, /*bCancel*/ )

// Gatilho do N�mero do Vale               
oStruGQQ:AddTrigger('GQQ_NUMVAL'  , ;     // [01] Id do campo de origem
					'GQQ_NUMVAL'  , ;     // [02] Id do campo de destino
		 			{ || .T. }    , ; 	  // [03] Bloco de codigo de valida��o da execu��o do gatilho
		 			{ || GA111TriggerFields() } )    // [04] Bloco de codigo de execu��o do gatilho
		 
// Gatilho Valor do Desconto			
oStruGQQ:AddTrigger('GQQ_VALOR'  , ;     // [01] Id do campo de origem
					'GQQ_VALOR'  , ;     // [02] Id do campo de destino
		 			{ || .T. }    , ; 	 // [03] Bloco de codigo de valida��o da execu��o do gatilho
		 			{ || GA111UpdtSld() } )   

oModel:SetDescription(STR0001) 	// Presta��o de Contas

oModel:AddFields('FIELDGQQ',,oStruGQQ)

oStruGQQ:SetProperty('GQQ_NUMVAL',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID , "GA111VldNumVal()"))
oStruGQQ:SetProperty('GQQ_VALOR' ,MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID , "GA111VldDescVal()"))

oStruGQP:SetProperty('GQP_CODIGO',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "")) // Inicializador padr�o do dicion�rio de daods
oStruGQP:SetProperty('GQP_VIGENC',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_EMISSA',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_ORIGEM',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_ORIGEM',MODEL_FIELD_VALUES,{}) // lista de valores permitidos no combo

oStruGQP:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

oModel:Addfields('FIELDGQP','FIELDGQQ',oStruGQP)

oModel:SetRelation('FIELDGQP', { { 'GQP_FILIAL', 'GQQ_FILIAL'}, {'GQP_CODIGO', 'GQQ_NUMVAL' } }, GQP->(IndexKey(1)) )

oModel:GetModel('FIELDGQQ'):SetDescription(STR0001)
oModel:GetModel('FIELDGQP'):SetOnlyQuery(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel    := ModelDef()
Local oStruGQP  := FWFormStruct(2,'GQP')
Local oStruGQQ  := FWFormStruct(2,'GQQ')

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEWGQP', oStruGQP , 'FIELDGQP')
oView:AddField('VIEWGQQ', oStruGQQ , 'FIELDGQQ')

oStruGQP:SetProperty('*' ,MVC_VIEW_CANCHANGE,.F.)

oStruGQP:RemoveField('GQP_CODFUN')
oStruGQP:RemoveField('GQP_CODIGO')

oView:CreateHorizontalBox('SUPERIOR', 20)
oView:SetOwnerView('VIEWGQQ','SUPERIOR')

oView:CreateHorizontalBox('MEIO',50)
oView:SetOwnerView('VIEWGQP','MEIO')

oView:SetViewProperty('VIEWGQP' , 'ONLYVIEW' )

oView:EnableTitleView('VIEWGQP' , STR0005 ) 

oView:SetDescription(STR0001)	// Presta��o de Contas

Return oView

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA111TriggerFields
Fun��o que preenche os dados do vale assim que o usu�rio define o n�mero do vale 

@sample	GA111TriggerFields()

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA111TriggerFields()

Local oModel    := FwModelActive()
Local oFieldGQP := oModel:GetModel('FIELDGQP')
Local oFieldGQQ := oModel:GetModel('FIELDGQQ')

oFieldGQQ:SetValue("GQQ_CODFUN", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_CODFUN")) 
oFieldGQQ:SetValue("GQQ_VALOR" , Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_SLDDEV")) 
oFieldGQQ:SetValue("GQQ_SLDDEV", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_SLDDEV"))
oFieldGQP:SetValue("GQP_DESFIN", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_DESFIN")) 
oFieldGQP:SetValue("GQP_VIGENC", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_VIGENC")) 
oFieldGQP:SetValue("GQP_EMISSA", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_EMISSA")) 
oFieldGQP:SetValue("GQP_TIPO"  , Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_TIPO"  )) 
oFieldGQP:SetValue("GQP_DESCTP", Posicione("G9A",1,xFilial("G9A")+FWFldGet("GQP_TIPO"  ),"G9A_DESCRI")) 
oFieldGQP:SetValue("GQP_ORIGEM", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_ORIGEM")) 
oFieldGQP:SetValue("GQP_CODAGE", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_CODAGE")) 
oFieldGQP:SetValue("GQP_DESCAG", Posicione("GI6",1,xFilial("GI6")+FWFldGet("GQP_CODAGE"),"GI6_DESCRI")) 
oFieldGQP:SetValue("GQP_DESCFU", Posicione("SRA",1,xFilial("SRA")+FWFldGet("GQQ_CODFUN"),"RA_NOME"   )) 
oFieldGQP:SetValue("GQP_DEPART", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_DEPART")) 
oFieldGQP:SetValue("GQP_DESCDP", Posicione("SQB",1,xFilial("SQB")+FWFldGet("GQP_DEPART"),"QB_DESCRIC")) 
oFieldGQP:SetValue("GQP_VALOR" , Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_VALOR" )) 
oFieldGQP:SetValue("GQP_SLDDEV", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_SLDDEV"))
oFieldGQP:SetValue("GQP_STATUS", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQQ_NUMVAL"),"GQP_STATUS"))  

Return

/*/{Protheus.doc} GA111UpdtSld
//Fun��o de gatilho para abater saldo em tempo de execu��o

@sample GA111UpdtSld()

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
Function GA111UpdtSld()
Local oModel    := FwModelActive()
Local oFieldGQP := oModel:GetModel('FIELDGQP')
Local oFieldGQQ := oModel:GetModel('FIELDGQQ')

// Quando for digitado o valor da presta��o pegar o valor devedor (GQP_SLDDEV) do vale e subtrair o valor prestado (GQQ_VALOR) na opera��o de insert
If oModel:GetOperation() == MODEL_OPERATION_INSERT
oFieldGQQ:SetValue("GQQ_SLDDEV", oFieldGQP:GetValue("GQP_SLDDEV") - oFieldGQQ:GetValue("GQQ_VALOR")) 
EndIf
// Quando for digitado o valor da presta��o pegar o valor deveder calculado no valid (GQQ_SLDDEV) e subtrair do novo valor digitado
If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	oFieldGQQ:SetValue("GQQ_SLDDEV", oFieldGQQ:GetValue("GQQ_SLDDEV") - oFieldGQQ:GetValue("GQQ_VALOR"))
EndIf

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA111PosValidMdl(oModel)
P�s valida��o do commit MVC.
 
@sample	GA111PosValidMdl(oModel)
 
@return	lRet 
 
@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA111PosValidMdl(oModel)

Local oMdlGQP	:= oModel:GetModel('FIELDGQP')
Local oMdlGQQ	:= oModel:GetModel('FIELDGQQ')
Local cStatus 	:= oMdlGQP:GetValue('GQP_STATUS')
Local dVigenc	:= oMdlGQP:GetValue('GQP_VIGENC')
Local nSld		:= oMdlGQP:GetValue('GQP_SLDDEV')
Local lRet		:= .T.

If (oModel:GetOperation() == MODEL_OPERATION_INSERT )
	// Verifica��o para chave duplicada, causada pela concorr�ncia de acessos no insert
	If (!ExistChav("GQQ", oMdlGQQ:GetValue("GQQ_NUMVAL") + oMdlGQQ:GetValue("GQQ_CODIGO")))
        lRet := .F.
    EndIf
	// Se vale estiver baixado ou com saldo zerado n�o poder� ter contas prestadas
	If (cStatus == '2' .OR. nSld == 0)
		lRet := .F.
		MsgAlert(STR0015, STR0014) // "N�o � poss�vel realizar presta��o de contas de um vale j� baixado!", "Aten��o"
	EndIf
	//Se o vale estiver baixado ou vencido n�o podera ter contas prestadas
	If (cStatus != '1' .OR. dVigenc < dDataBase )
		lRet := .F.
		MsgAlert(STR0012, STR0013) // "Vale vencido ou j� baixado.", "Dados Inv�lidos"
	EndIf
	If (!GA111VldNumVal())
		lRet := .F.
		MsgAlert(STR0016, STR0013) // "Vale inv�lido", "Dados Inv�lidos"
	EndIf
EndIf

If (oModel:GetOperation() == MODEL_OPERATION_DELETE)
	If (dVigenc <= dDataBase )
		lRet := .F.
		MsgAlert(STR0012, STR0013) // "Vale vencido ou j� baixado.", "Dados Inv�lidos"
	EndIf
EndIf

// Guarda os valores para atualizar a tabela GQP
cCodNumVal := oMdlGQQ:GetValue("GQQ_CODIGO")
cNumValCur := oMdlGQQ:GetValue("GQQ_NUMVAL")
nValorCur  := oMdlGQQ:GetValue("GQQ_VALOR")
nSldDevCur := oMdlGQP:GetValue("GQP_SLDDEV")

Return lRet

//--------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GA111VldNumVal
Valida o n�mero do vale escolhido pelo usu�rio.

@sample GA111VldNumVal()
@return lRet - vale achado

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
*/
//--------------------------------------------------------------------------------------------------------
Function GA111VldNumVal()

Local oModel:=FWModelActive()

// Cria tabela tempor�ria
Local cAliasGQP := GetNextAlias()
Local cNumVal := oModel:GetModel("FIELDGQQ"):GetValue("GQQ_NUMVAL")
Local cCodFun := oModel:GetModel("FIELDGQQ"):GetValue("GQQ_CODFUN")
Local lRet := .F.

If ExistCpo("GQP", cNumVal)
	
	lRet := .T.
	// Come�a consulta SQL na tabela tempor�ria criada
	BeginSQL Alias cAliasGQP
		SELECT 
			GQP.GQP_CODIGO 
		FROM 
			%table:GQP% GQP
		WHERE 
			GQP.GQP_FILIAL = %xFilial:GQP%
			AND GQP.GQP_CODIGO = %Exp:cNumVal% 
			AND GQP.GQP_CODFUN = %Exp:cCodFun% 
		    AND GQP.%NotDel%     
	EndSQL
	
	If Empty((cAliasGQP)->GQP_CODIGO)
		lRet := .F.
	EndIf

	(cAliasGQP)->(DbCloseArea())
	
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GA111VldDescVal
Valida valor digitado para desconto do vale.

@sample GA111VldDescVal()

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
*/
//--------------------------------------------------------------------------------------------------------
Function GA111VldDescVal

Local oModel := FWModelActive()

// Cria tabela tempor�ria
Local cAliasGQQ := GetNextAlias()
Local nValor := oModel:GetModel("FIELDGQQ"):GetValue("GQQ_VALOR")
Local nSld	 := oModel:GetModel("FIELDGQP"):GetValue("GQP_SLDDEV")
Local cCodPresVal := oModel:GetModel("FIELDGQQ"):GetValue("GQQ_CODIGO")
Local lRet   := .F.

// Valor n�o poder ser negativo
If (nValor > 0)
	// Valor prestado deve ser menor ou igual ao saldo devdor do vale (GQP_SLDDEV)
	If (nValor <= nSld)
		lRet := .T.
	EndIf

	If (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
		// Come�a consulta SQL na tabela tempor�ria criada
		BeginSQL Alias cAliasGQQ
			
			SELECT 
				GQQ.GQQ_VALOR, GQQ.GQQ_SLDDEV
			FROM 
				%table:GQQ% GQQ
			WHERE 
				GQQ.GQQ_FILIAL = %xFilial:GQQ%
				AND GQQ.GQQ_CODIGO = %Exp:cCodPresVal% 
				AND GQQ.%NotDel% 
					
			EndSQL
			
			If Empty((cAliasGQQ)->GQQ_VALOR)
				lRet := .F.
			Else
				// Se o valor a ser atualizado (GQQ_VALOR) for menor ou igual ou valor do saldo (GQP_SLDDEV)
				If oModel:GetValue("FIELDGQQ","GQQ_VALOR") <= oModel:GetValue("FIELDGQP","GQP_SLDDEV")
					oModel:GetModel("FIELDGQQ"):SetValue("GQQ_SLDDEV", ((cAliasGQQ)->GQQ_VALOR) + oModel:GetValue("FIELDGQP","GQP_SLDDEV"))
					If (nValor <= ((cAliasGQQ)->GQQ_VALOR + oModel:GetValue("FIELDGQP","GQP_SLDDEV")))
						lRet := .T.
					EndIf
				EndIf
			EndIf
		
		(cAliasGQQ)->(DbCloseArea())
		
	EndIf 

EndIf 

Return lRet

//--------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GA111Ope
ExecView utilizado para realizar mais de um tipo de opera��o no banco de dados simultaneamente

@sample GA111Ope(nOper)
@param nOper - n�mero da opera��o

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
*/
//--------------------------------------------------------------------------------------------------------
Function GA111Ope(nOper)
Local oModelGQP 
Local oModelGQQ 

If !FWExecView( STR0001,'VIEWDEF.GTPA111', nOper, , , , , )
		If ( nOper == MODEL_OPERATION_DELETE)
			DbSelectArea("GQP")
			GQP->(DbSetOrder(1))
			If GQP->(DbSeek(xFilial("GQP") + cNumValCur))
				oModelGQP := FwLoadModel('GTPA111')
				oModelGQP:SetOperation(MODEL_OPERATION_UPDATE)
				oModelGQP:GetModel('FIELDGQP'):SetOnlyQuery(.F.)
				oModelGQP:Activate()
				// Se o saldo do vale for maior que zero atualiza seu status para pendente 
				IF (nValorCur + nSldDevCur > 0 .AND. oModelGQP:GetModel("FIELDGQP"):GetValue("GQP_STATUS") == '2')
				    oModelGQP:GetModel("FIELDGQP"):SetValue("GQP_STATUS", "1")
				EndIf
				// Atualiza saldo na tabela GQP
				oModelGQP:GetModel("FIELDGQP"):SetValue("GQP_SLDDEV", nValorCur + nSldDevCur)
			EndIf
		    // Commit
			If lRet := oModelGQP:VldData()
			    oModelGQP:CommitData()
			EndIf
			oModelGQP:DeActivate()
			oModelGQP:Destroy()	
		ElseIf (nOper == MODEL_OPERATION_INSERT .OR. nOper == MODEL_OPERATION_UPDATE)
			DbSelectArea("GQQ")
			GQQ->(DbSetOrder(1))
			If GQQ->(DbSeek(xFilial("GQQ") + cNumValCur + cCodNumVal))
			oModelGQQ := FwLoadModel('GTPA111')
			oModelGQQ:SetOperation(MODEL_OPERATION_UPDATE)
			oModelGQQ:GetModel('FIELDGQP'):SetOnlyQuery(.F.)
			oModelGQQ:Activate()
				// Baixa no vale se o saldo for zero na tabela GQP
			    IF (oModelGQQ:GetModel("FIELDGQQ"):GetValue("GQQ_SLDDEV") == 0)
			    	oModelGQQ:GetModel("FIELDGQP"):SetValue("GQP_STATUS", "2")
			    ELSE
			    	oModelGQQ:GetModel("FIELDGQP"):SetValue("GQP_STATUS", "1")
				EndIf
				// Atualiza saldo na tabela GQP
				oModelGQQ:GetModel("FIELDGQP"):SetValue("GQP_SLDDEV", oModelGQQ:GetModel("FIELDGQQ"):GetValue("GQQ_SLDDEV"))
			    // Commit
			    If lRet := oModelGQQ:VldData()
			    	oModelGQQ:CommitData()
			    EndIf
			    oModelGQQ:DeActivate()
			    oModelGQQ:Destroy()	
			EndIf	
		EndIf
		cCodNumVal := ""
		cNumValCur := ""
		nValorCur  := 0
		nSldDevCur := 0	
Endif

Return
