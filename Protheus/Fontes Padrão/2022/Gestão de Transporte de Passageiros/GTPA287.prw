#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA287.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA287()
Cadastro de Par�metros de Clientes 
@author  Renan Ribeiro Brando
@since   24/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA287()

Local oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GQV")
oBrowse:SetDescription(STR0001) // Par�metros de Clientes
oBrowse:DisableDetails()
oBrowse:Activate()

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu da Rotina
@author  Renan Ribeiro Brando
@since   25/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION "VIEWDEF.GTPA287" OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003	ACTION "VIEWDEF.GTPA287" OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.GTPA287" OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.GTPA287" OPERATION 5 ACCESS 0 // Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de Dados da Rotina
@author  Renan Ribeiro Brando
@since   25/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruGQV  := FWFormStruct(1,"GQV")
Local oStruGQX  := FWFormStruct(1,"GQX")
Local bPosValid := {|oModel| GA287TdOk(oModel)}
Local bLinePost := {|oModel| Ga287VldPos(oModel) }

oModel 	:= MPFormModel():New("GTPA287",/*bPreValidMdl*/, bPosValid, /*bCommit*/, /*bCancel*/ )

//Fun��o utilizada para ajustes na estrutura de campos
Ga287Struc('M',oStruGQV,oStruGQX)

oModel:SetDescription(STR0001) // Par�metros de Clientes
oModel:AddFields("FIELDGQV",,oStruGQV)
oModel:AddGrid("GRIDGQX", "FIELDGQV", oStruGQX, /*bLinePre*/, bLinePost, /*bPre*/, /*bLinePost */,/* bLoad */)

If GQV->(FieldPos('GQV_CODGQV')) > 0 .AND. GQX->(FieldPos('GQX_CODGQV')) > 0
	oModel:SetRelation( "GRIDGQX", { { "GQX_FILIAL", "xFilial('GQX')" } , { "GQX_CODIGO", "GQV_CODIGO" }, { "GQX_CODLOJ", "GQV_CODLOJ" }, { "GQX_CODGQV", "GQV_CODGQV" }  } )
Else
	oModel:SetRelation( "GRIDGQX", { { "GQX_FILIAL", "xFilial('GQX')" } , { "GQX_CODIGO", "GQV_CODIGO" }, { "GQX_CODLOJ", "GQV_CODLOJ" }  } , GQX->(IndexKey(1)) )
EndIf

oModel:GetModel('GRIDGQX'):SetOptional(.T.)
oModel:GetModel('GRIDGQX'):SetUniqueLine( { 'GQX_SEQ' } )

oModel:GetModel('FIELDGQV'):SetDescription(STR0001)	// Par�metros de Clientes
oModel:GetModel('GRIDGQX'):SetDescription(STR0014)	//"Descontos por Bilhete"

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View da Rotina
@author  Renan Ribeiro Brando
@since   25/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA287')
Local oView		:= FWFormView():New()
Local oStruGQV	:= FWFormStruct(2, "GQV")
Local oStruGQX	:= FWFormStruct(2, "GQX")

oStruGQV:RemoveField('GQV_COBPED')

If GQV->(FieldPos('GQV_CODGQV')) > 0 .AND. GQX->(FieldPos('GQX_CODGQV')) > 0
	oStruGQX:RemoveField('GQX_CODGQV')
	oStruGQV:RemoveField('GQV_CODGQV')
EndIf

oView:SetModel(oModel)
oView:SetDescription(STR0001)///'Par�metros do Cliente'

oView:AddField("VIEW_GQV", oStruGQV, "FIELDGQV")
oView:AddGrid("VIEW_GQX", oStruGQX, 'GRIDGQX') 

oView:CreateHorizontalBox( "SUPERIOR", 40)
oView:CreateHorizontalBox( "INFERIOR", 60)
oView:SetOwnerView("VIEW_GQV","SUPERIOR")
oView:SetOwnerView("VIEW_GQX","INFERIOR")

oView:AddIncrementField( 'VIEW_GQX', 'GQX_SEQ' )

oView:EnableTitleView('VIEW_GQV'	,STR0001)	//'Par�metros do Cliente'
oView:EnableTitleView('VIEW_GQX'	,STR0014)	//"Descontos por Bilhete"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GA287TdOk(oModel)
Pos Valida��o do modelo
@author  Renan Ribeiro Brando
@since   05/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA287TdOk(oModel)
Local lRet := .T.

IF (oModel:GetOperation() == MODEL_OPERATION_INSERT)
	// Verifica��o dupla da chave prim�ria devido ao problema de concorr�ncia de acessos apresentados na primeira entrega
	IF !GA287VldCli()
		lRet := .F.
	ENDIF
ENDIF

IF (oModel:GetOperation() == MODEL_OPERATION_UPDATE) .and. oModel:GetModel('GRIDGQX'):IsUpdated()
	// Avisa o usu�rio que os descontos n�o ser�o aplicados para requisi��es j� cadastradas
	FwAlertWarning(STR0007,STR0008)//"Os descontos N�O SER�O reaplicados para requisi��es j� cadastradas!!!"##"Aten��o!!"
	
ENDIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GA287VldCli()
Valida��o do dicionario parta cliente e loja 
@author  Renan Ribeiro Brando
@since   23/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA287VldCli()

Local lRet := .T.

IF !Empty(FWFldGet("GQV_CODLOJ")) .and. !ExistChav("GQV", FWFldGet("GQV_CODIGO") + FWFldGet("GQV_CODLOJ")) 
	lRet := .F.
Endif

If lRet .and. !ExistCpo("SA1", FWFldGet("GQV_CODIGO")+AllTrim(FWFldGet("GQV_CODLOJ")))
	lRet := .F.
ENDIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ga287Struc()
Altera��o da estrutura do modelo
@author  jacomo.fernandes
@since   23/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Function Ga287Struc(cTipo,oStruGQV,oStruGQX)
Local aTrigger	:= {}

IF cTipo = 'M'

	oStruGQX:SetProperty("GQX_DSCPER", MODEL_FIELD_WHEN, { || FwFldGet('GQX_TPVAL') == '1' .or. FwIsInCall('RUNTRIGGER')})
	oStruGQX:SetProperty("GQX_DSCFIX", MODEL_FIELD_WHEN, { || FwFldGet('GQX_TPVAL') == '2' .or. FwIsInCall('RUNTRIGGER')})

	oStruGQX:SetProperty("GQX_LINHA" , MODEL_FIELD_WHEN, { || FwFldGet('GQX_DSCTIP') == '2' .or. FwIsInCall('RUNTRIGGER')})
	oStruGQX:SetProperty("GQX_LOCORI", MODEL_FIELD_WHEN, { || FwFldGet('GQX_DSCTIP') <> '1' .or. FwIsInCall('RUNTRIGGER')})
	oStruGQX:SetProperty("GQX_LOCDES", MODEL_FIELD_WHEN, { || FwFldGet('GQX_DSCTIP') <> '1' .or. FwIsInCall('RUNTRIGGER')})

	oStruGQX:SetProperty('GQX_DTVINI', MODEL_FIELD_VALID, {||	(Empty(FwFldGet('GQX_DTVINI')) .OR. Empty(FwFldGet('GQX_DTVFIN')) ) .OR. FwFldGet('GQX_DTVFIN')>= FwFldGet('GQX_DTVINI') 	})
	oStruGQX:SetProperty('GQX_DTVFIN', MODEL_FIELD_VALID, {||	(Empty(FwFldGet('GQX_DTVINI')) .OR. Empty(FwFldGet('GQX_DTVFIN')) ) .OR. FwFldGet('GQX_DTVFIN')>= FwFldGet('GQX_DTVINI') 	})

	oStruGQX:SetProperty('GQX_LOCORI', MODEL_FIELD_VALID, {|oModel| Empty(oModel:GetValue(SubStr(ReadVar(),4))) .Or. oModel:GetValue('GQX_LOCORI') <> oModel:GetValue('GQX_LOCDES') })
	oStruGQX:SetProperty('GQX_LOCDES', MODEL_FIELD_VALID, {|oModel| Empty(oModel:GetValue(SubStr(ReadVar(),4))) .Or. oModel:GetValue('GQX_LOCORI') <> oModel:GetValue('GQX_LOCDES')})
	
	If GQV->(FieldPos('GQV_CODGQV')) > 0 .AND. GQX->(FieldPos('GQX_CODGQV')) > 0
		oStruGQX:SetProperty("GQX_CODGQV", MODEL_FIELD_INIT, {|| FwFldGet('GQV_CODGQV')})
	EndIf

	// GQV
	aTrigger := FwStruTrigger("GQV_CODLOJ","GQV_NOMCLI","Posicione('SA1',1,xFilial('SA1')+FwFldGet('GQV_CODIGO')+FwFldGet('GQV_CODLOJ'),'A1_NOME')" )	
	oStruGQV:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	// GQX
	aTrigger := FwStruTrigger("GQX_TPVAL","GQX_DSCFIX","0",,,,,"FwFldGet('GQX_TPVAL') == '1'" )	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_TPVAL","GQX_DSCPER","0",,,,,"FwFldGet('GQX_TPVAL') == '2'" )	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_DSCTIP","GQX_LINHA","''",,,,,"FwFldGet('GQX_DSCTIP') <> '2'" )	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_DSCTIP","GQX_NLINHA","''",,,,,"FwFldGet('GQX_DSCTIP') <> '2'" )	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_DSCTIP","GQX_LOCORI","''",,,,,"FwFldGet('GQX_DSCTIP') == '1'" )	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_DSCTIP","GQX_NLOCOR","''",,,,,"FwFldGet('GQX_DSCTIP') == '1'" )	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_DSCTIP","GQX_LOCDES","''",,,,,"FwFldGet('GQX_DSCTIP') == '1'" )	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_DSCTIP","GQX_NLOCDE","''",,,,,"FwFldGet('GQX_DSCTIP') == '1'" )	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_LINHA","GQX_NLINHA","TPNomeLinh(M->GQX_LINHA)")	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_LOCORI","GQX_NLOCOR","Posicione('GI1',1,xFilial('GI1')+M->GQX_LOCORI,'GI1_DESCRI')")	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	aTrigger := FwStruTrigger("GQX_LOCDES","GQX_NLOCDE","Posicione('GI1',1,xFilial('GI1')+M->GQX_LOCDES,'GI1_DESCRI')")	
	oStruGQX:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

Endif
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Ga287VldPos()
Pos valid do modelo
@author  jacomo.fernandes
@since   23/06/2017
@version P12
/*/
//-------------------------------------------------------------------

Static Function  Ga287VldPos(oModel)
Local lRet			:= .T.
Local oStruct		:= oModel:GetStruct()
Local cTitHelp		:= ""
Local cHelp			:= ""
Local aDAtaAux		:= aClone(oModel:GetData())
Local nPosSeq		:= oStruct:GetFieldPos('GQX_SEQ')
Local nPosDSCTIP	:= oStruct:GetFieldPos('GQX_DSCTIP')
Local nPosMSBLQL	:= oStruct:GetFieldPos('GQX_MSBLQL')
Local nPosDTVFIN	:= oStruct:GetFieldPos('GQX_DTVFIN')
Local nPosLinha		:= oStruct:GetFieldPos('GQX_LINHA')
Local nPosLOCORI	:= oStruct:GetFieldPos('GQX_LOCORI')
Local nPosLOCDES	:= oStruct:GetFieldPos('GQX_LOCDES')
Local bCondic		:= ""
//Valida se o Registro est� n�o esta deletado, se n�o � o mesmo e se n�o esta dentro da mesma data de vigencia e est� bloqueado
Local cCondic		:= "{|X| !X[3] .And. x[1,1,nPosSeq] <> oModel:GetValue('GQX_SEQ') .And. "+; //se o registro n�o est� deletado e o c�digo sequencia n�o � o mesmo e
						"x[1,1,nPosMSBLQL] == '2' .AND. "+; // se o registro est� ativo e
						"(Empty(x[1,1,nPosDTVFIN]) .or. x[1,1,nPosDTVFIN] >= oModel:GetValue('GQX_DTVINI'))" //se encontra possivel na vig�ncia

Do Case
	Case oModel:GetValue('GQX_DSCTIP') == '1' //Por Cliente
		
		bCondic := cCondic+" .AND. x[1,1,nPosDSCTIP] =='1' }" //Considera todas as condi��es pre definidas e se o tipo � por cliente
		
		If Ascan( aDataAux ,&(bCondic) )
			cTitHelp	:= "Ga287VldPos_PorCliente"
			cHelp		:= "J� existe um registro de desconto do mesmo tipo ativo"
			lRet := .F.
		Endif

	Case oModel:GetValue('GQX_DSCTIP') == '2' // Por Linha

		bCondic := cCondic+" .AND. x[1,1,nPosDSCTIP] =='2'" //Considera todas as condi��es pre definidas e se o tipo � por Linha
		bCondic += " .and. x[1,1,nPosLINHA] == oModel:GetValue('GQX_LINHA')" // e que forem da mesma linha
		
		If !Empty(FwFldGet('GQX_LOCORI'))
			bCondic += " .and. x[1,1,nPosLocOri] == oModel:GetValue('GQX_LOCORI')" // e que forem da mesma origem
		Else
			bCondic += " .and. x[1,1,nPosLocOri] =='' " // e que n�o tiverem origem preenchido
		Endif
		
		If !Empty(FwFldGet('GQX_LOCDES'))
			bCondic += " .and. x[1,1,nPosLocDes] == oModel:GetValue('GQX_LOCDES')" // e que forem do mesmo destino
		Else
			bCondic += " .and. x[1,1,nPosLocDes] =='' " // e que n�o tiverem destino preenchido
		Endif
		bCondic += "}" 

		If Ascan( aDataAux ,&(bCondic) )
			cTitHelp	:= "Ga287VldPos_PorLinha"
			cHelp		:= STR0009// "J� existe um registro de desconto do mesmo tipo ativo"
			lRet := .F.
		Endif

	Case oModel:GetValue('GQX_DSCTIP') == '3' //Por Trecho
		
		bCondic := cCondic+" .AND. x[1,1,nPosDSCTIP] =='3' " //Considera todas as condi��es pre definidas e se o tipo � por trecho
		bCondic += " .and. x[1,1,nPosLocOri] == oModel:GetValue('GQX_LOCORI')" // e que forem da mesma origem
		bCondic += " .and. x[1,1,nPosLocDes] == oModel:GetValue('GQX_LOCDES')" // e que forem do mesmo destino
		bCondic += "}" 
		If Ascan( aDataAux ,&(bCondic) )
			cTitHelp	:= "Ga287VldPos_PorTrecho"
			cHelp		:= STR0009//"J� existe um registro de desconto do mesmo tipo ativo"
			lRet := .F.
		Endif

		If lRet .And. (Empty(FwFldGet('GQX_LOCORI')) .OR. Empty(FwFldGet('GQX_LOCDES'))) 
			cTitHelp	:= "Ga287VldPos_Trecho"
			cHelp		:= STR0010//"� obrigado informar as localidades de origem e destino quando selecionado por trecho"
			lRet := .F.
		Endif
Endcase

If lRet .and. FwFldGet('GQX_TPVAL') == '1' .and. Empty(FwFldGet('GQX_DSCPER'))
	cTitHelp:= "Ga287VldPos_Valor"
	cHelp	:= STR0011//"N�o foi informado um valor para o tipo de desconto"
	lRet	:= .F.
Endif

IF lRet .and. FwFldGet('GQX_TPVAL') == '2' .and. Empty(FwFldGet('GQX_DSCFIX'))
	cTitHelp:= "Ga287VldPos_Valor"
	cHelp	:= STR0011//"N�o foi informado um valor para o tipo de desconto"
	lRet	:= .F.
ENDIF

If lRet .and.(!Empty(FwFldGet('GQX_LOCORI')) .OR. !Empty(FwFldGet('GQX_LOCDES')))  .And. (Empty(FwFldGet('GQX_LOCORI')) .OR. Empty(FwFldGet('GQX_LOCDES'))) 
	cTitHelp	:= "Ga287VldPos_Trecho"
	cHelp		:= STR0012//"� obrigado informar as localidades de origem e destino quando uma parte do trecho for informado"
	lRet := .F.
Endif

If !lRet
	Help(" ",1,cTitHelp,,cHelp,1,0) 
Endif

GtpDestroy(aDAtaAux)

Return lRet
