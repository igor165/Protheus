#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA112.CH'

// Variáveis e controle do vale correspodnente que será alterado
Static cCodNumVal	:= ""
Static nProrNum		:= ""
Static dDataVigAnt  := ""

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA112()
Prorrogação de Vales
 
@sample	GTPA112()
 
@return	oBrowse  Retorna  a Rotina de Prorrogação de Vales
 
@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA112()

Local oBrowse	:= Nil		

Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("GQU")
oBrowse:SetDescription(STR0001)	// Prorrogação de Vales
oBrowse:Activate()

Return ( oBrowse )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do menu
 
@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003   ACTION 'VIEWDEF.GTPA112' OPERATION 2 ACCESS 0 // #Visualizar
ADD OPTION aRotina TITLE STR0004   ACTION 'GA112Oper(3)' 	OPERATION 3 ACCESS 0 // #Incluir
ADD OPTION aRotina TITLE STR0006   ACTION 'GA112Oper(5)'    OPERATION 5 ACCESS 0 // #Excluir

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruGQU 	:= FWFormStruct(1,'GQU')
Local oStruGQP	:= FWFormStruct(1,'GQP')
Local bPosValidMdl := {|oModel| GA112PosValidMdl(oModel)}

oModel := MPFormModel():New('GTPA112',/*PreValidMdl*/, bPosValidMdl, /*bCommit*/, /*bCancel*/ )

oModel:SetDescription(STR0001)

// Gatilho do Número do Vale               
oStruGQU:AddTrigger('GQU_NUMVAL'  , ;     // [01] Id do campo de origem
					'GQU_NUMVAL'  , ;     // [02] Id do campo de destino
		 			{ || .T. }    , ; 	  // [03] Bloco de codigo de validação da execução do gatilho
		 			{ || GA112TriggerFields() } )    // [04] Bloco de codigo de execução do gatilho 

oModel:addFields('FIELDGQU',,oStruGQU)

oStruGQU:SetProperty('GQU_DTNVVG',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID , "GA112VldVigenc()"))

oStruGQP:SetProperty('GQP_CODIGO',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_VIGENC',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_EMISSA',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_ORIGEM',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, ""))
oStruGQP:SetProperty('GQP_ORIGEM',MODEL_FIELD_VALUES,{})

oStruGQP:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

oModel:AddFields('FIELDGQP','FIELDGQU',oStruGQP)

oModel:SetRelation('FIELDGQP', { { 'GQP_FILIAL', 'GQU_FILIAL'},{'+GQP_CODIGO', 'GQU_NUMVAL' } }, GQP->(IndexKey(1)) )

oModel:GetModel('FIELDGQU'):SetDescription(STR0001)
oModel:GetModel('FIELDGQP'):SetOnlyQuery(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel    := ModelDef()
Local oStruGQU  := FWFormStruct(2, 'GQU')
Local oStruGQP  := FWFormStruct(2, 'GQP')
 
oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEWGQU' , oStruGQU, 'FIELDGQU') 
oView:AddField('VIEWGQP' , oStruGQP, 'FIELDGQP')

oStruGQP:SetProperty('GQP_DESFIN',MVC_VIEW_CANCHANGE,.F.)
oStruGQP:SetProperty('GQP_ORIGEM',MVC_VIEW_CANCHANGE,.F.)
oStruGQP:SetProperty('GQP_CODAGE',MVC_VIEW_CANCHANGE,.F.)
oStruGQP:SetProperty('GQP_VALOR' ,MVC_VIEW_CANCHANGE,.F.)

oStruGQP:RemoveField('GQP_CODFUN')
oStruGQP:RemoveField('GQP_CODIGO')

oStruGQU:SetProperty('GQU_USRPRO',MVC_VIEW_LOOKUP,'SRA')

oView:CreateHorizontalBox('SUPERIOR', 24)
oView:SetOwnerView('VIEWGQU','SUPERIOR')

oView:CreateHorizontalBox('MEIO', 50)
oView:SetOwnerView('VIEWGQP','MEIO')

oView:SetViewProperty('VIEWGQP' , 'ONLYVIEW')
oView:SetViewProperty('VIEWGQP' , 'DISABLELOOKUP')

oView:EnableTitleView('VIEWGQP' , STR0005) // Dados do Vale

oView:SetDescription(STR0001) // Prorrogação de Vales

oView:SetModel(ModelDef())	

Return oView

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA112VldVigenc
Valida data de vigência de acordo com o período de vigência do vale

@sample GA112VldVigenc()
@return  lRet

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA112VldVigenc()
Local oModel	  := FWModelActive()
Local lRet 	      := .T.
Local dVigAnte	  := oModel:GetValue("FIELDGQU", "GQU_DTANTV")
Local dVigAte	  := oModel:GetValue("FIELDGQU", "GQU_DTNVVG")
Local nPerVigenc  := Posicione("G9A", 1, xFilial("G9A") + oModel:GetValue("FIELDGQP", "GQP_TIPO"),"G9A_PERVIG")
Local cBloq		  := Posicione("G9A", 1, xFilial("G9A") + oModel:GetValue("FIELDGQP", "GQP_TIPO"),"G9A_BLOQ")
Local dDataVigenc := dDataBase + nPerVigenc

oModel:SetValue("FIELDGQP","GQP_VIGENC",dVigAte)

// Data de vigência não deve ser menor que a data atual
If (dVigAte <= dDataBase)
	lRet := .F.
	Help(,, STR0007,, STR0009, 1,0 ) // Dados Inválidos, Data da nova vigência não pode ser menor que a data atual!
EndIf
// A data de vigência não pode ser menor que a ultima prorrogação
If (dVigAte <= dVigAnte)
	Help(,, STR0010,, STR0013, 1,0 ) // A data de vigência do vale não pode ser inferior a data da última prorrogação!, Atenção
	lRet := .F.
EndIf
// A data de vigência do vale não pode ser maior que o período de vigência do tipo do vale quando o vale estiver bloqueado
If (dVigAte > dDataVigenc .AND. cBloq == "1")
	Help(,, STR0010,, STR0012, 1,0 ) // Dados Inválidos, Data da nova vigência não pode ser menor que a data atual!
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA112TriggerFields
Rotina executada no gatilho do campo GQU_NUMVAL

@sample	GA112TriggerFields()

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA112TriggerFields()

Local oModel    := FwModelActive()
Local oFieldGQP := oModel:GetModel('FIELDGQP')
Local oFieldGQU := oModel:GetModel('FIELDGQU')
Local cAliasGQU := GetNextAlias()
Local cNumVal   := oModel:GetModel("FIELDGQU"):GetValue("GQU_NUMVAL")
Local lBOracle	:= Trim(TcGetDb()) == 'ORACLE'
Local lBPost	:= Trim(TcGetDb()) == 'POSTGRES'
Local cSelect   := "%%"
Local cAnd      := "%%"
Local cLimit	:= "%%"

if lBOracle
	cSelect := "%GQU.GQU_NUMPRO%"
	cAnd    := "%AND ROWNUM = '1'%"
ElseIf lBPost
	cSelect:= "%GQU.GQU_NUMPRO%"
	cLimit:= "%LIMIT 1%"
Else
	cSelect := "%TOP 1 GQU.GQU_NUMPRO%"
	cAnd    := "%%"
Endif

// Começa consulta SQL na tabela temporária criada
BeginSQL Alias cAliasGQU
	SELECT 
		%exp:cSelect%
	FROM 
		%table:GQU% GQU %exp:cLimit%
	WHERE
	 	GQU.GQU_FILIAL = %xFilial:GQU%
		AND GQU.GQU_NUMVAL = %Exp:cNumVal% 
		AND GQU.%NotDel%  
		%exp:cAnd%
		ORDER BY GQU.GQU_NUMPRO DESC
EndSQL

If ((cAliasGQU)->GQU_NUMPRO < 1)
	oFieldGQU:SetValue("GQU_NUMPRO", 1)
Else
	oFieldGQU:SetValue("GQU_NUMPRO", (cAliasGQU)->GQU_NUMPRO + 1)
EndIf

(cAliasGQU)->(DbCloseArea())

oFieldGQU:SetValue("GQU_CODFUN", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_CODFUN")) 
oFieldGQU:SetValue("GQU_DTANTV", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_VIGENC")) 

oFieldGQP:SetValue("GQP_DESFIN", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_DESFIN")) 
oFieldGQP:SetValue("GQP_VIGENC", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_VIGENC")) 
oFieldGQP:SetValue("GQP_EMISSA", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_EMISSA")) 
oFieldGQP:SetValue("GQP_TIPO"  , Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_TIPO"	 )) 
oFieldGQP:SetValue("GQP_DESCTP", Posicione("G9A",1,xFilial("G9A")+FWFldGet("GQP_TIPO"  ),"G9A_DESCRI")) 
oFieldGQP:SetValue("GQP_ORIGEM", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_ORIGEM")) 
oFieldGQP:SetValue("GQP_CODAGE", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_CODAGE")) 
oFieldGQP:SetValue("GQP_DESCAG", Posicione("GI6",1,xFilial("GI6")+FWFldGet("GQP_CODAGE"),"GI6_DESCRI")) 
oFieldGQP:SetValue("GQP_DESCFU", Posicione("SRA",1,xFilial("SRA")+FWFldGet("GQU_CODFUN"),"RA_NOME"   )) 
oFieldGQP:SetValue("GQP_DEPART", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_DEPART")) 
oFieldGQP:SetValue("GQP_DESCDP", Posicione("SQB",1,xFilial("SQB")+FWFldGet("GQP_DEPART"),"QB_DESCRIC")) 
oFieldGQP:SetValue("GQP_VALOR" , Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_VALOR" )) 
oFieldGQP:SetValue("GQP_SLDDEV", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_SLDDEV")) 
oFieldGQP:SetValue("GQP_STATUS", Posicione("GQP",1,xFilial("GQP")+FWFldGet("GQU_NUMVAL"),"GQP_STATUS")) 

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA112PosValidMdl(oModel)
Pós validação do commit MVC.
 
@sample	GA112PosValidMdl(oModel)
 
@return	lRet 
 
@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA112PosValidMdl(oModel)

Local oModelGQP := oModel:GetModel("FIELDGQP")
Local oModelGQU	:= oModel:GetModel('FIELDGQU')
Local lRet      := .T.
Local cPendente := oModel:GetValue("FIELDGQP", "GQP_STATUS")
Local dDataVig  := oModel:GetValue("FIELDGQP", "GQP_VIGENC")
Local cBloqVal	:= Posicione("G9A",1,xFilial("G9A") + oModelGQP:GetValue("GQP_TIPO"),"G9A_BLOQ")
cCodNumVal		:= oModel:GetValue("FIELDGQU", "GQU_NUMVAL")
nProrNum		:= oModel:GetValue("FIELDGQU", "GQU_NUMPRO")
dDataVigAnt		:= oModel:GetValue("FIELDGQU", "GQU_DTANTV")

If (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
	// Verificação para chave duplicada, causada pela concorrência de acessos no insert
	If (!ExistChav("GQU", oModelGQU:GetValue("GQU_NUMVAL") + cValToChar(oModelGQU:GetValue("GQU_NUMPRO"))))
        lRet := .F.
    EndIf
EndIf

// Vales com o tipo bloqueado e vencidos não podem ser prorrogados
If (cBloqVal == "1" .AND. dDataBase > dDataVig)
	lRet := .F.
	MSGALERT( STR0011, STR0010) //#Vales com o tipo bloqueado e vencidos não podem ter sua vigência alterada! , #Atenção
Else
	// Se o vale estiver baixado ou vencido também não poderá ser prorrogado
	If (cPendente == '2' .OR. dDataBase > dDataVig  )
		lRet := .F.
		MSGALERT( STR0008, STR0007) //#Vale baixado ou vencido!, #Dados Inválidos
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GA112Oper
ExecView utilizado para realizar mais de um tipo de operação no banco de dados simultaneamente

@sample GA112Oper(nOper)
@param nOper - número da operação

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
*/
//--------------------------------------------------------------------------------------------------------
Function GA112Oper(nOper)
Local oModelGQP 
Local oModelGQU

If !FWExecView( STR0001,'VIEWDEF.GTPA112', nOper, , , , , )
		If (nOper == MODEL_OPERATION_INSERT)
			DbSelectArea("GQU")
			GQU->(DbSetOrder(1))
			If GQU->(DbSeek(xFilial("GQU") + cCodNumVal + cValToChar(nProrNum)))
			oModelGQU := FwLoadModel('GTPA112')
			oModelGQU:SetOperation(MODEL_OPERATION_UPDATE)
			oModelGQU:GetModel('FIELDGQP'):SetOnlyQuery(.F.)
			oModelGQU:Activate()
				// Prorroga o prazo do vale
			    oModelGQU:GetModel("FIELDGQP"):SetValue("GQP_VIGENC", oModelGQU:GetModel("FIELDGQU"):GetValue("GQU_DTNVVG"))
			    // Commit
			    If oModelGQU:VldData()
			    	oModelGQU:CommitData()
			    EndIf
			    oModelGQU:DeActivate()
			    oModelGQU:Destroy()	
			EndIf
		ElseIf (nOper == MODEL_OPERATION_DELETE)
			DbSelectArea("GQP")
			GQP->(DbSetOrder(1))
			If GQP->(DbSeek(xFilial("GQP") + cCodNumVal))
			oModelGQP := FwLoadModel('GTPA112')
			oModelGQP:SetOperation(MODEL_OPERATION_UPDATE)
			oModelGQP:GetModel('FIELDGQP'):SetOnlyQuery(.F.)
			oModelGQP:Activate()
				// Retorna a data anterior de vencimento do vale
			    oModelGQP:GetModel("FIELDGQP"):SetValue("GQP_VIGENC", dDataVigAnt)
			    // Commit
			    If oModelGQP:VldData()
			    	oModelGQP:CommitData()
			    EndIf
			    oModelGQP:DeActivate()
			    oModelGQP:Destroy()	
			EndIf	
		EndIf
		// Limpa variáveis de controle do vale que está sob operação
		cCodNumVal := ""
		nProrNum   := ""
		dDataVigAnt:= ""
Endif

Return
