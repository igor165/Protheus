#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA113.CH'

// Vari�veis e controle do vale correspodnente que ser� alterado
Static cCodNumVal := ""

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA113()
Prorroga��o de Vales
 
@sample	GTPA113()
 
@return	oBrowse  Retorna  a Rotina de Autoriza��o de Desconto
 
@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA113()
Local oBrowse	:= Nil		

Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("G96")
oBrowse:SetDescription(STR0001)	// Autoriza��o de Desconto
oBrowse:Activate()

Return ( oBrowse )

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

ADD OPTION aRotina TITLE STR0003   ACTION 'VIEWDEF.GTPA113' OPERATION 2 ACCESS 0 // #Visualizar
ADD OPTION aRotina TITLE STR0004   ACTION 'GA113Oper(3)'   OPERATION 3 ACCESS 0 // #Incluir
ADD OPTION aRotina TITLE STR0013   ACTION 'GTPR113A()'   OPERATION 4 ACCESS 0 // "Imp. Autoriza��o" 

Return ( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruG96 	:= FWFormStruct(1,'G96')
Local oStruGQP	:= FWFormStruct(1,'GQP')
Local bPosValid	:= {|oModel| GA113PosValid(oModel)}

Local oModel := MPFormModel():New('GTPA113',/*PreValidMdl*/,bPosValid,/*bCommit*/, /*bCancel*/ )

oModel:SetDescription(STR0001)

// Gatilho do N�mero do Vale               
oStruG96:AddTrigger('G96_NUMVAL'  , ;     // [01] Id do campo de origem
					'G96_NUMVAL'  , ;     // [02] Id do campo de destino
		 			{ || .T. }    , ; 	  // [03] Bloco de codigo de valida��o da execu��o do gatilho
		 			{ || GA113TriggerFields() } )    // [04] Bloco de codigo de execu��o do gatilho 

oModel:addFields('FIELDG96',,oStruG96)

oStruG96:SetProperty('G96_NUMVAL',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID , "GA113VldNumVal()"))

oStruGQP:SetProperty('GQP_CODIGO',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_VIGENC',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_EMISSA',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_ORIGEM',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_ORIGEM',MODEL_FIELD_VALUES,{})

oStruGQP:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

oModel:AddFields('FIELDGQP','FIELDG96',oStruGQP)

oModel:SetRelation('FIELDGQP', { { 'GQP_FILIAL', 'G96_FILIAL'},{'GQP_CODIGO', 'G96_NUMVAL' } }, GQP->(IndexKey(1)) )

oModel:SetPrimaryKey({ 'G96_FILIAL', 'G96_NUMVAL'})

oModel:GetModel('FIELDG96'):SetDescription(STR0001)		// Autoriza��o de Desconto
oModel:GetModel('FIELDGQP'):SetOnlyQuery(.T.)
oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
Carrega valores do vale posicionado quando a rotina � carregada por vales de funcion�rios.

@sample InitDados(oModel)
@param  oModel - Modelo de Dados utilizado para carregar o vale posicionado
@return NIL

@author	Renan Ribeiro Brando - Inova��o
@since		12/04/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function InitDados(oModel)

Local oModelGQP := oModel:GetModel("FIELDG96") 

// Verifica se a rotina foi aberta do menu de outras a��es do vale de funcion�rios (GTPA110)
// Opera��o deve ser insert, caso contr�rio os valores do vale na tabela GQP n�o ser�o atualizados
IF IsInCallStack("GTPA110") .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
	oModelGQP:SetValue("G96_CODFUN", GQP->GQP_CODFUN)
	oModelGQP:SetValue("G96_NUMVAL", GQP->GQP_CODIGO)
EndIF

Return Nil

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
Local oStruG96  := FWFormStruct(2, 'G96')
Local oStruGQP  := FWFormStruct(2, 'GQP')
 
oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEWG96' , oStruG96, 'FIELDG96') 
oView:AddField('VIEWGQP' , oStruGQP, 'FIELDGQP')

oStruGQP:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)

oStruGQP:RemoveField('GQP_CODFUN')
oStruGQP:RemoveField('GQP_CODIGO')

oView:CreateHorizontalBox('SUPERIOR', 24)
oView:SetOwnerView('VIEWG96','SUPERIOR')

oView:CreateHorizontalBox('MEIO', 50)
oView:SetOwnerView('VIEWGQP','MEIO')

oView:SetViewProperty('VIEWGQP' , 'ONLYVIEW')
oView:SetViewProperty('VIEWGQP' , 'DISABLELOOKUP')

oView:EnableTitleView('VIEWGQP' , STR0005) // Dados do Vale

oView:SetModel(ModelDef())	

Return oView

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA113TriggerFields
Rotina executada no gatilho do campo GQU_NUMVAL

@sample	GA113TriggerFields()
@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA113TriggerFields()

Local oModel    := FwModelActive()
Local oFieldGQP := oModel:GetModel('FIELDGQP')
Local oFieldG96 := oModel:GetModel('FIELDG96')

oFieldG96:SetValue("G96_CODFUN", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_CODFUN")) 
oFieldG96:SetValue("G96_SLDDEV", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_SLDDEV")) 

oFieldGQP:SetValue("GQP_DESFIN", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_DESFIN")) 
oFieldGQP:SetValue("GQP_VIGENC", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_VIGENC")) 
oFieldGQP:SetValue("GQP_EMISSA", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_EMISSA")) 
oFieldGQP:SetValue("GQP_TIPO"  , Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_TIPO"  )) 
oFieldGQP:SetValue("GQP_DESCTP", Posicione("G9A",1,xFilial("G9A")+FWFldGet("GQP_TIPO"  ),"G9A_DESCRI")) 
oFieldGQP:SetValue("GQP_ORIGEM", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_ORIGEM")) 
oFieldGQP:SetValue("GQP_CODAGE", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_CODAGE")) 
oFieldGQP:SetValue("GQP_DESCAG", Posicione("GI6",1,xFilial("GI6")+FWFldGet("GQP_CODAGE"),"GI6_DESCRI")) 
oFieldGQP:SetValue("GQP_DESCFU", Posicione("SRA",1,xFilial("SRA")+FWFldGet("G96_CODFUN"),"RA_NOME"   )) 
oFieldGQP:SetValue("GQP_DEPART", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_DEPART")) 
oFieldGQP:SetValue("GQP_DESCDP", Posicione("SQB",1,xFilial("SQB")+FWFldGet("GQP_DEPART"),"QB_DESCRIC")) 
oFieldGQP:SetValue("GQP_VALOR" , Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_VALOR" )) 
oFieldGQP:SetValue("GQP_SLDDEV", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_SLDDEV")) 
oFieldGQP:SetValue("GQP_STATUS", Posicione("GQP",1,xFilial("GQP")+FWFldGet("G96_NUMVAL"),"GQP_STATUS"))

Return

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA113VldNumVal
Valida o n�mero do vale escolhido pelo usu�rio.

@sample GA113VldNumVal()
@return  lRet

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA113VldNumVal()
Local oModel:=FWModelActive()
Local cAliasGQP := GetNextAlias() // Cria tabela tempor�ria
Local cNumVal := oModel:GetModel("FIELDG96"):GetValue("G96_NUMVAL")
Local cCodFun := oModel:GetModel("FIELDG96"):GetValue("G96_CODFUN")
Local lRet := .F.
If ExistCpo("G96", cNumVal)
	lRet := .F.
	MsgAlert(STR0008, STR0007) // "J� existe autoriza��o de pagamento na folha para este vale!", "Aten��o"		
ElseIf ExistCpo("GQP", cNumVal)
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


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA113PosValid(oModel)
P�s valida��o do commit MVC.
 
@sample	GA113PosValid(oModel)
@param oModel 
@return	lRet 
 
@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA113PosValid(oModel)

Local oMdlG96	:= oModel:GetModel('FIELDG96')
Local oMdlGQP	:= oModel:GetModel('FIELDGQP')
Local cStatus 	:= oMdlGQP:GetValue('GQP_STATUS')
Local lRet		:= .T.
cCodNumVal 		:= oMdlG96:GetValue('G96_NUMVAL')

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	// Verifica��o para chave duplicada, causada pela concorr�ncia de acessos no insert
	If (!ExistChav("G96", oMdlG96:GetValue("G96_NUMVAL")))
        lRet := .F.
    EndIf
	// Se o vale estiver baixado(2)
	If (cStatus == '2')
		lRet := .F.
		MsgAlert( STR0010, STR0009) // "Vale n�o est� j� baixado.", "Dados Inv�lidos"
	// Valida��o da tela para verificar aquele vale pertence ao mesmo funcion�rio escolhido
	ElseIf (!GA113VldNumVal())
			lRet := .F.
			MsgAlert( STR0011, STR0009) // "Vale Inv�lido.", "Dados Inv�lidos"
	Else
	// A autoriza��o de pagamento s� ser� feita se o usu�rio fizer a confirma��o
		If !MSGYESNO(STR0012, STR0007) // Aten��o....autoriza��o de pagamento, "Aten��o"
			lRet := .F.
		EndIF
	Endif
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA113Oper
// Rotina que executa as opera��es do sistema.

@sample GA113Oper(nOper)
@param nOper

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GA113Oper(nOper)

Local oModelG96
Local lRet       := .T. 
Local cFunProces := ""
Local cDIVCOMNEG := AllTrim(GTPGetRules("DIVCOMNEG"))
Local aPerAtual  := {}

If !FWExecView( STR0001,'VIEWDEF.GTPA113', nOper, , , , , )
	If (nOper == MODEL_OPERATION_INSERT)
		DbSelectArea("G96")
		G96->(DbSetOrder(1))
		If G96->(DbSeek(xFilial("G96") + cCodNumVal))
			oModelG96 := FwLoadModel('GTPA113')
			oModelG96:SetOperation(MODEL_OPERATION_UPDATE)
			oModelG96:GetModel('FIELDGQP'):SetOnlyQuery(.F.)
			oModelG96:Activate()
			// Baixa no vale se o saldo for zero na tabela GQP
			IF (oModelG96:GetModel("FIELDGQP"):GetValue("GQP_STATUS") == "1")
				oModelG96:GetModel("FIELDGQP"):SetValue("GQP_STATUS", "2")
				oModelG96:GetModel("FIELDGQP"):SetValue("GQP_SLDDEV", 0)
			EndIf
			SRA->(DbSetOrder(1))
			If (SRA->(DbSeek(xFilial("SRA") + oModelG96:GetModel("FIELDG96"):GetValue("G96_CODFUN"))))
				//Fun��o do RH que verifica se a folha de pagamento esta aberta no m�s (GPEXPER.PRX)
				// @aPerAtual[1,1] ano/m�s do per�odo da folha
				// @aPerAtual[1,11] data de pagamento da folha
				If fGetPerAtual( @aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, fGetRotOrdinar() )
					cFunProces := SRA->RA_PROCES
					RecLock('SRK',.T.)			
					SRK->RK_FILIAL	:= xFilial('SRK') 
					SRK->RK_MAT		:= oModelG96:GetModel("FIELDG96"):GetValue("G96_CODFUN") // Matricula do funcion�rio
					SRK->RK_PD  	:= cDIVCOMNEG // C�digo da verba da folha
					SRK->RK_VALORTO	:= oModelG96:GetModel("FIELDG96"):GetValue("G96_SLDDEV") // Valor total a ser descontado/pago
					SRK->RK_PARCELA := oModelG96:GetModel("FIELDG96"):GetValue("G96_PARCEL") // Quantidade de parcelas que ser�o descontadas
					SRK->RK_VALORPA	:= (oModelG96:GetModel("FIELDG96"):GetValue("G96_SLDDEV")) / (oModelG96:GetModel("FIELDG96"):GetValue("G96_PARCEL")) // Valor da parcela a ser descontada/paga
					SRK->RK_DOCUMEN	:= oModelG96:GetModel("FIELDG96"):GetValue("G96_CODRGB") // C�digo do documento (n�mero sequencial do lan�amento..n�o existe uma regra de preenchimento...pode ser 000001, 000002 e por a� vai)
					SRK->RK_DTVENC 	:= aPerAtual[1,11] //Data do pr�ximo vencimento
					SRK->RK_CC		:= POSICIONE("SRA",1,XFILIAL("SRA")+G96->G96_CODFUN,"RA_CC") // Centro de custo do funcion�rio
					SRK->RK_PERINI	:= aPerAtual[1,1]// Per�odo de in�cio do desconto (AAAAMM) (vari�vel aPerAtual[1,1])
					SRK->RK_NUMPAGO	:= '01' // N�mero de pagamento (01)
					SRK->RK_PROCES 	:= POSICIONE("SRA",1,XFILIAL("SRA")+G96->G96_CODFUN,"RA_PROCES")   // C�digo do processo do funcion�rio (campo RA_PROCES)
					SRK->( MsUnlock() )
				Else
					lRet := .F.
					MsgStop(STR0014, "GTPR113")
				EndIf	
				
				// Commit
				If lRet .AND. oModelG96:VldData()
					oModelG96:CommitData()
				EndIf
				oModelG96:DeActivate()
				oModelG96:Destroy()	
			EndIf	
		EndIf	
	EndIf
	cCodNumVal := ""
Endif

Return
