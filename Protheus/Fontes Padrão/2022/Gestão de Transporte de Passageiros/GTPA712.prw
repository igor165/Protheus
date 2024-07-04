#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA712.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA712()
Cadastro de tags de correç?o CT-e OS
@sample	GTPA712() 
@return	oBrowse	Retorna o Cadastro de Tipos de Agência 
@author	GTP
@since		20/05/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA712()

Local oBrowse := NIL
Local cMsgErro	:= ''

If ValidaDic(@cMsgErro)
	FwMsgRun( ,{||GTPA712LOA()},,"Carregando tabela de tags CT-e OS...")
	
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias('G53')
	oBrowse:SetDescription(STR0001)	//Cadastro de tags de correç?o CT-e OS
	oBrowse:AddLegend('G53_PROPRI == "1"',"BLUE","Sistema", 'G53_PROPRI')
	oBrowse:AddLegend('G53_PROPRI == "2"',"GREEN" ,"Usuário", 'G53_PROPRI')

	oBrowse:SetMenuDef('GTPA712')

	oBrowse:Activate()
Else
    FwAlertHelp(cMsgErro, "Banco de dados desatualizado, não é possível iniciar a rotina")
EndIf

Return

/*/{Protheus.doc} ValidaDic
//TODO Descrição auto-gerada.
@author GTP
@since 28/12/2021
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/
Static Function ValidaDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'G53'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'G53_CODTAG','G53_MSBLQL','G53_PROPRI'}

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

if Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
	        Exit
	    Endif
	Next
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu 
@sample	MenuDef() 
@return	aRotina - Retorna as opções do Menu 
@author		GTP
@since		20/05/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.GTPA712' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.GTPA712' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.GTPA712' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.GTPA712' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados 
@sample	ModelDef() 
@return	oModel  Retorna o Modelo de Dados 
@author	GTP
@since		20/05/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	:= MPFormModel():New('GTPA712', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
Local oStruG53	:= FWFormStruct(1,'G53')
Local bPosValid := {|oModelIni|PosValid(oModelIni)}

oModel:AddFields('G53MASTER',/*cOwner*/,oStruG53,,bPosValid)
oModel:SetDescription(STR0001)						//Cadastro de tags de correç?o CT-e OS
oModel:GetModel('G53MASTER'):SetDescription(STR0002)	//Tags de correç?o CT-e OS


Return ( oModel )

/*/{Protheus.doc} PosValid(oModelIni)
Função responsável por validar se o registro já existe e não permitir que o
local de origem e destino sejam os mesmos.
@type function
@author gustavo.silva2
@since 05/01/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function PosValid(oModelIni)

Local oModel    := oModelIni:GetModel()
Local oModelG53	:= oModel:GetModel('G53MASTER')
Local lRet		:= .T.
Local aArea     := GetArea()
Local cGrupo 	:= oModelG53:GetValue('G53_GRUPO')
Local cCampo 	:= oModelG53:GetValue('G53_CAMPO')
Local cPropri   := ""
Local nOpc		:= oModel:GetOperation()

If nOpc == MODEL_OPERATION_INSERT	
	lRet := RecnoTag(cGrupo,cCampo)
	
	If !lRet
		oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GTPA712","Já existe um registro cadastrado com os mesmos dados.")
	Endif
Else
	If G53->(FieldPos("G53_PROPRI")) > 0
		cPropri := oModelG53:GetValue('G53_PROPRI')
		If cPropri == '1'
			lRet := MsgYesNo("Deseja modificar o registro criado pelo sistema? Este registro será recriado ao entrar no sistema.", "Confirmação")

			If !lRet
				oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GTPA712","Modificação do registro cancelado.")
			EndIf
		EndIf
	EndIf
EndIf
	
RestArea( aArea )

Return lRet

/*/{Protheus.doc} RecnoTag
//TODO Descrição auto-gerada.
@author GTP
@since 28/12/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function RecnoTag(cGrupo,cCampo)
Local lRet := .T.
Local cAliasTmp	:= GetNextAlias()

BeginSql Alias cAliasTmp

	Select G53.R_E_C_N_O_
	From %Table:G53% G53
	WHERE
		G53.G53_FILIAL = %xFilial:G53%
		AND G53.G53_GRUPO  = %Exp:cGrupo%
		AND G53.G53_CAMPO  = %Exp:cCampo%	
		AND G53.%NotDel%	
EndSql
 
If (cAliasTmp)->R_E_C_N_O_ > 0
	lRet := .F.
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface 
@sample	ViewDef() 
@return	oView  Retorna a View 
@author	GTP
@since		20/05/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA712') 
Local oView		:= FWFormView():New()
Local oStruG53	:= FWFormStruct(2, 'G53')

If G53->(FieldPos("G53_PROPRI")) > 0
	oStruG53:RemoveField("G53_PROPRI")
EndIf

oView:SetModel(oModel)
oView:AddField('VIEW_G53' ,oStruG53,'G53MASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_G53','TELA')

oView:SetDescription(STR0002)

Return ( oView )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA712LOA()
Carrega tabela para uso na carta de correç?o de CTE OS
@author	GTP
@since		20/05/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA712LOA()

Local lRet      := .T.
Local aArea     := GetArea()
Local oModel	:= FwLoadModel('GTPA712')
Local oMdlG53	:= oModel:GetModel('G53MASTER')
Local aDados	:= {}
Local nX		:= 0

//G53_GRUPO,G53_CAMPO,G53_DESCRI  
aAdd(aDados,{ 'ide','CFOP',				'Código Fiscal de Operaç?es e Prestaç?es'  })
aAdd(aDados,{ 'ide','natOP', 			'Natureza da Operaç?o'  })
aAdd(aDados,{ 'ide','cMunEnv',			'Código do Município de envio do CT-e'  })
aAdd(aDados,{ 'ide','xMunEnv',			'Nome do Município de envio do CT-e'  })
aAdd(aDados,{ 'ide','UFEnv',			'Sigla da UF de envio do CT-e' })
aAdd(aDados,{ 'ide','indIEToma',		'Indicador do papel do tomador na prestaç?o do serviço'   })
aAdd(aDados,{ 'ide','cMunIni',			'Código do Município de início da prestaç?o'  })
aAdd(aDados,{ 'ide','xMunIni',			'Nome do Município do início da prestaç?o'  })
aAdd(aDados,{ 'ide','UFIni',			'UF do início da prestaç?o' })
aAdd(aDados,{ 'ide','cMunFim',			'Código do Município de término daprestaç?o'  })
aAdd(aDados,{ 'ide','xMunFim',  		'Nome do Município do término da prestaç?o' })
aAdd(aDados,{ 'ide','UFFim', 			'UF do término da prestaç?o' })		
aAdd(aDados,{ 'infPercurso','UFPer',	'Sigla das Unidades da Federaç?o do percurso do veículo.'  })		
aAdd(aDados,{ 'compl','xObs', 			'Observaç?es Gerais'  })		
aAdd(aDados,{ 'emit','CNPJ', 			'CNPJ do emitente'  })	
aAdd(aDados,{ 'emit','IE', 				'Inscriç?o Estadual do Emitente'  })	
aAdd(aDados,{ 'emit','xNome',			'Raz?o social ou Nome do emitente'   })	
aAdd(aDados,{ 'emit','xFant', 			'Nome fantasia'  })	
aAdd(aDados,{ 'enderEmit','xLgr',	 	'Logradouro'  })	
aAdd(aDados,{ 'enderEmit','nro', 		'Número'  })	
aAdd(aDados,{ 'enderEmit','xBairro', 	'Bairro'  })	
aAdd(aDados,{ 'enderEmit','cMun', 		'Código do município'  })	
aAdd(aDados,{ 'enderEmit','CEP', 		'CEP'  })	
aAdd(aDados,{ 'enderEmit','UF', 		'Sigla da UF'  })	
aAdd(aDados,{ 'enderEmit','fone',  		'Telefone' })		
aAdd(aDados,{ 'toma','CPF',  			'Número do CPF' })		
aAdd(aDados,{ 'toma','xNome', 			'Raz?o social ou nome do tomador'  })
aAdd(aDados,{ 'toma','xFant', 			'Nome fantasia'  })
aAdd(aDados,{ 'toma','fone',  			'Telefone' })
aAdd(aDados,{ 'enderEmit','cPais', 		'Código do país'  })	
aAdd(aDados,{ 'enderEmit','xPais', 		'Nome do país'  })		
aAdd(aDados,{ 'enderToma','xLgr',		'Logradouro'   })
aAdd(aDados,{ 'enderToma','nro', 		'Número'  })
aAdd(aDados,{ 'enderToma','xBairro',	'Bairro'   })
aAdd(aDados,{ 'enderToma','cMun', 		'Código do município'  })
aAdd(aDados,{ 'enderToma','xMun',		'Nome do município'   })
aAdd(aDados,{ 'enderToma','CEP', 		'CEP'  })
aAdd(aDados,{ 'enderToma','UF', 		'Sigla da UF'  })
aAdd(aDados,{ 'enderToma','cPais', 		'Código do país'  })
aAdd(aDados,{ 'enderToma','xPais', 		'Nome do país'  })	
aAdd(aDados,{ 'infServico','xDescServ', 'Descriç?o do Serviço prestado'  })	
aAdd(aDados,{ 'rodoOS','NroRegEstadual','Número do Registro Estadual'  })		
aAdd(aDados,{ 'veic','placa', 			'Placa do veículo'  })	
aAdd(aDados,{ 'veic','UF', 				'UF'  })	
	


G53->(DbSetOrder(1))//G53_FILIAL+G53_CODIGO
For nX := 1 to Len(aDados)
	If !G53->( DbSeek(xFilial('G53')+PadR( aDados[nX][1], TamSX3("G53_GRUPO")[1] )+PadR( aDados[nX][2], TamSX3("G53_CAMPO")[1] )) )
		
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If oModel:Activate()		
			If G53->(FieldPos("G53_CODTAG")) > 0	
				oMdlG53:SetValue('G53_CODTAG'   ,GETSXENUM("G53","G53_CODTAG") )
			EndIf
			oMdlG53:SetValue('G53_GRUPO'	,aDados[nX][1])
			oMdlG53:SetValue('G53_CAMPO'	,aDados[nX][2])
			oMdlG53:SetValue('G53_DESCCP'	,aDados[nX][3])
			If G53->(FieldPos("G53_PROPRI")) > 0
				oMdlG53:SetValue('G53_PROPRI'   , '1' )
			EndIf

			If oModel:VldData() 
				oModel:CommitData()
			EndIf
		EndIf
		
		oModel:Deactivate()
	
	EndIf
Next
oModel:Destroy()
RestArea(aArea)
GtpDestroy(aDados)

Return lRet
