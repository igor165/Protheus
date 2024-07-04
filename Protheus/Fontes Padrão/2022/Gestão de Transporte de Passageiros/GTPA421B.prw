#Include "GTPA421B.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static lLibDtIni	:= .F.
Static lAcerto		:= .F.

Function GTPA421B(lFchAcerto, lAuto, aAuto) 
Local cDescri	:= STR0001 //'Inclusão'
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0003 },{.T., STR0002},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}	//"Confirmar"###"Fechar" //'Fechar' //'Confirmar'
Default lAuto := .F.
Default aAuto := {}


lLibDtIni	:= .F.
lAcerto		:= .F.

If FwIsInCallStack("GTPJ010")
	lAuto := .T.
EndIf

If lFchAcerto
	lLibDtIni	:= .T.
	lAcerto		:= .T.
	cDescri		:= STR0004 //"Ficha de Acerto"
Endif

If !(lAuto)
	FWExecView( cDescri , "VIEWDEF.GTPA421B", 3,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , 75/*nPercReducao*/, aEnableButtons, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/ )
Else
	GA421BAuto(lAcerto, aAuto)
Endif

Return 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= MPFormModel():New('GTPA421B', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
Local oStruG6X	:= FWFormStruct(1,'G6X')

SetModelStruct(oStruG6X)

oModel:AddFields('G6XMASTER',/*cOwner*/,oStruG6X)
oModel:SetDescription(STR0005) //"Seleção de Agência"
oModel:GetModel('G6XMASTER'):SetDescription(STR0005)	//STR0005 //"Seleção de Agência"
oModel:SetPrimaryKey({"G6X_FILIAL","G6X_CODIGO"})


oModel:SetCommit({|oModel| Chama421(oModel)})

Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@param oStruG6x, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function SetModelStruct(oStruG6X)
Local bWhen		:= {|oMdl,cField,xVal| GTPA421BWHEN(oMdl,cField,xVal)}
Local bTrig		:= {|oMdl,cField,xVal|GTPA421BTRG(oMdl,cField,xVal)}
Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue|GTPA421BVld(oMdl,cField,cNewValue,cOldValue) }

//Remove a Obrigatoriedade de todos os campos
oStruG6X:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F.)

//Deixa somente desses campos
oStruG6X:SetProperty( 'G6X_AGENCI'	, MODEL_FIELD_OBRIGAT, .T.)
oStruG6X:SetProperty( 'G6X_DTINI'	, MODEL_FIELD_OBRIGAT, .T.)
oStruG6X:SetProperty( 'G6X_DTFIN'	, MODEL_FIELD_OBRIGAT, .T.)
oStruG6X:SetProperty( 'G6X_DTREME'	, MODEL_FIELD_OBRIGAT, .T.)
oStruG6X:SetProperty( 'G6X_NUMFCH'	, MODEL_FIELD_OBRIGAT, .T.)

oStruG6X:SetProperty("*"			, MODEL_FIELD_WHEN	, {|| .T.} )
oStruG6X:SetProperty("G6X_DTINI"	, MODEL_FIELD_WHEN	, bWhen )

//Remove os Gatilhos de dicionarios
oStruG6X:aTriggers:= {}
//Adiciona os atuais gatilhos
oStruG6X:AddTrigger("G6X_AGENCI"	,"G6X_AGENCI"	,{||.T.},bTrig)
oStruG6X:AddTrigger("G6X_DTINI"		,"G6X_DTINI"	,{||.T.},bTrig)
oStruG6X:AddTrigger("G6X_DTFIN"		,"G6X_DTFIN"	,{||.T.},bTrig)

oStruG6X:SetProperty("G6X_AGENCI"	, MODEL_FIELD_VALID	,bFldVld)
oStruG6X:SetProperty("G6X_DTINI"	, MODEL_FIELD_VALID	,bFldVld)
oStruG6X:SetProperty("G6X_DTFIN"	, MODEL_FIELD_VALID	,bFldVld)

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA421B') 
Local oView		:= FWFormView():New()
Local oStruG6X	:= FWFormStruct(2, 'G6X')

ViewStruct(oStruG6X)

oView:SetModel(oModel)
oView:SetDescription(STR0005)  //"Seleção de Agência"
oView:AddField('VIEW_G6X' ,oStruG6X,'G6XMASTER')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_G6X','TELA')

oView:lInsertMsg := .F.

//Alterar a Data Final do Movimento
oView:AddUserButton(STR0007,"GTPA421",{|oView| GA421AltDtMov( oView )},STR0006, , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})      //"Altera Data do Movimento" //"Alt Dt Movimento"
	
Return ( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewStruct
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@param oStruG6x, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ViewStruct(oStruG6X)
Local n1		:= 0
Local aFields	:= aClone(oStruG6X:GetFields()) 
For n1 := 1 To Len(aFields)
	If !(AllTrim(aFields[n1][1])+'|' $ 'G6X_AGENCI|G6X_DESCAG|G6X_DTINI|G6X_DTFIN|G6X_DTREME|G6X_NUMFCH|')
		oStruG6X:RemoveField( aFields[n1][1] )
	Endif
Next 
oStruG6X:SetProperty( '*'			, MVC_VIEW_CANCHANGE, .F.)
oStruG6X:SetProperty( 'G6X_AGENCI'	, MVC_VIEW_CANCHANGE, .T.)
oStruG6X:SetProperty( 'G6X_DTINI'	, MVC_VIEW_CANCHANGE, .T.)
oStruG6X:SetProperty( 'G6X_DTFIN'	, MVC_VIEW_CANCHANGE, .T.)

GTPDestroy(aFields)
Return


/*/{Protheus.doc} GA421AltDtMov
(long_description)
@type function
@author jacom
@since 05/04/2018
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA421AltDtMov( oView )
Local oModel	:= oView:GetModel()
Local oExecView	:= FWViewExec():New()
Local oViewAux	:= FWFormView():New(oView)
Local oStruG6X	:= FWFormStruct(2,'G6X',{|cCampo| AllTrim(cCampo) == 'G6X_DTFIN'})

Local aButtons	:= {	{.F., Nil}, {.F., Nil}    		, {.F., Nil}    	, {.F., Nil}, {.F., Nil}, ;
                    	{.F., Nil}, {.T., STR0003}	, {.T., STR0013}	, {.F., Nil}, {.F., Nil}, ;	// STR0003##STR0013
                    	{.F., Nil}, {.F., Nil}    		, {.F., Nil}    	, {.F., Nil}	}
	
oStruG6X:SetProperty("G6X_DTFIN", MVC_VIEW_CANCHANGE, .T.)
	
	oViewAux:SetModel(oModel)
	oViewAux:SetOperation(MODEL_OPERATION_UPDATE)
	
	
	oViewAux:AddField('VIEW_G6X_DTFIN' , oStruG6X,'G6XMASTER')
	oViewAux:CreateHorizontalBox( 'BOX', 100)
	oViewAux:SetOwnerView('VIEW_G6X_DTFIN','BOX')
	 
	oViewAux:EnableTitleView('VIEW_G6X_DTFIN' , STR0014 ) //'Altera Data do Movimento Final'
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
		oExecView:SetModel(oModel)
		oExecView:SetView(oViewAux)
		oExecView:SetTitle(STR0014) //'Altera Data do Movimento Final'
		oExecView:SetOperation(MODEL_OPERATION_UPDATE)
		oExecView:setReduction(85)
		oExecView:SetCloseOnOk({|| .t.})
		oExecView:SetButtons(aButtons)
		oExecView:openView(.F.)
		If oExecView:getButtonPress() == VIEW_BUTTON_OK
			lRet := .T.
		Endif
	Endif
	
oStruG6X:SetProperty("G6X_DTFIN", MVC_VIEW_CANCHANGE, .T.)
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA421bWhen
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GTPA421BVld(oMdl,cField,cNewValue,cOldValue)
Local lRet	:= .T.
Local oModel	:= oMdl:GetModel()
Local cAgencia	:= oMdl:GetValue('G6X_AGENCI')
Local dDtIni	:= oMdl:GetValue('G6X_DTINI')
Local dDtFinAux	:= CtoD('  /  /  ')
Local cMsgErro	:= "" 
Local cSolucao	:= ""

If !Empty(cNewValue)
	
	Do Case 
		Case cField == 'G6X_AGENCI'
			lRet 	:= ValidUserAg(oMdl,cField,cNewValue,cOldValue) .and. VldFchAberta(oMdl,cNewValue)
		Case cField == 'G6X_DTINI'
			dDtFinAux	:= GA421RetDtFin(dDtIni,cAgencia)
			lRet		:= G421bVldMovi(cNewValue,dDtFinAux,cAgencia)
			cMsgErro 	:= STR0015  //"Encontrada ficha de remessa no período informado"
			cSolucao 	:= STR0008 //"Informe outro período"
		Case cField == 'G6X_DTFIN'
			If cNewValue < dDtIni
			   lRet 	:= .F.
			   cMsgErro := STR0016 //"Data final menor que a data inicial"
			   cSolucao := STR0008 //"Informe outro período"
			EndIf
			If AnoMes(cNewValue) <> AnoMes(dDtIni)
			   lRet 	:= .F.
			   cMsgErro := STR0017 //"Data final deve pertencer ao mesmo mês e ano da data inicial"
			   cSolucao := STR0008 //"Informe outro período"
			EndIf
	EndCase
	
	If !lRet
		oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,STR0009,cMsgErro,cSolucao,cNewValue) //"GTPA421BVld"
	Endif
	
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA421bWhen
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GTPA421bWhen(oModel,cField,xVal)
Local lRet	:= .T.
Local lTrig	:= FwIsInCallStack('RUNTRIGGER')

If cField == "G6X_DTINI"
	lRet := lLibDtIni .Or. lTrig
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} HasFicha
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function HasFicha(cAgencia)
Local lRet			:= .F.
Local cAliasTemp	:= GetNextAlias()

	BeginSQL alias cAliasTemp    
	
		SELECT 
			Count(G6X_NUMFCH) AS TOTAL
		FROM 
			%Table:G6X% G6X	
		WHERE 
			G6X_FILIAL  = %xFilial:G6X%
			AND G6X_AGENCI = %Exp:cAgencia%
			AND G6X.%NotDel%
		
	EndSQL
			
	If (cAliasTemp)->TOTAL > 0
		lRet := .T.
	EndIf
	(cAliasTemp)->(DBCloseArea())
Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Chama421
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Function Chama421(oModel)
Local lRet		:= .T.
Local aFldInit	:= {}
Local cDescri	:= STR0001 //'Inclusão'
aAdd(aFldInit,{"G6X_AGENCI"	,oModel:GetModel('G6XMASTER'):GetValue("G6X_AGENCI"	) })
aAdd(aFldInit,{"G6X_DESCAG"	,oModel:GetModel('G6XMASTER'):GetValue("G6X_DESCAG"	) })
aAdd(aFldInit,{"G6X_DTINI"	,oModel:GetModel('G6XMASTER'):GetValue("G6X_DTINI"	) })
aAdd(aFldInit,{"G6X_DTFIN"	,oModel:GetModel('G6XMASTER'):GetValue("G6X_DTFIN"	) })
aAdd(aFldInit,{"G6X_DTREME"	,oModel:GetModel('G6XMASTER'):GetValue("G6X_DTREME"	) })
aAdd(aFldInit,{"G6X_NUMFCH"	,oModel:GetModel('G6XMASTER'):GetValue("G6X_NUMFCH"	) })

If G6X->(FieldPos('G6X_TITPRO')) > 0
	aAdd(aFldInit,{"G6X_TITPRO"	,POSICIONE("GI6",1,XFILIAL("GI6")+oModel:GetModel('G6XMASTER'):GetValue("G6X_AGENCI"),"GI6_TITPRO")})
Endif

If G6X->(FieldPos('G6X_DEPOSI')) > 0
	aAdd(aFldInit,{"G6X_DEPOSI"	,POSICIONE("GI6",1,XFILIAL("GI6")+oModel:GetModel('G6XMASTER'):GetValue("G6X_AGENCI"),"GI6_DEPOSI")})
Endif

GTPA421InitFld(aFldInit)
If lAcerto
	cDescri	:= STR0010 //"Acerto"
Endif

If !(IsBlind()) .And. !(FwIsInCallStack('GA421BAuto')) .AND. !(FwIsInCallStack('GTPJ010'))
	FWExecView( cDescri , "VIEWDEF.GTPA421", 3,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/ )
EndIf
Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA421BTRG
(long_description)
@type function
@author jacom
@since 31/03/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GTPA421BTRG(oMdl,cField,xVal)
Do Case
	Case cField == 'G6X_AGENCI'
		oMdl:SetValue('G6X_DESCAG',Posicione('GI6',1,xFilial('GI6')+xVal,'GI6_DESCRI'))
		lLibDtIni	:= .F.
		lLibDtIni	:= !HasFicha(xVal) .Or. lAcerto
		If !lLibDtIni
			oMdl:SetValue('G6X_DTINI',RetDtIniFch(xVal))
		Else
			oMdl:SetValue('G6X_DTINI',CtoD('  /  /  '))
		Endif
		
	Case cField == 'G6X_DTINI' 
		oMdl:SetValue('G6X_DTFIN',GA421RetDtFin(xVal, oMdl:GetValue('G6X_AGENCI')))
	
	Case cField == 'G6X_DTFIN'
		If !Empty(xVal)
			oMdl:SetValue('G6X_DTREME', xVal+1  )
		Else
			oMdl:SetValue('G6X_DTREME', CtoD('  /  /  ') )		
		Endif
		oMdl:SetValue('G6X_NUMFCH', DtoS(xVal) )
EndCase

Return xVal

//-------------------------------------------------------------------
/*/{Protheus.doc} RetDtIniFch(cAgencia)
Função que retorna a Data Inicial da próxima Ficha.

@author SIGAGTP | JACOMO FERNANDES

@since 07/12/2017

@type function
/*/
//-------------------------------------------------------------------

Static Function RetDtIniFch(cAgencia)

Local cAliasTemp	:= GetNextAlias()
Local dDataIni		:= CtoD("  /  /  ") 
	BeginSQL alias cAliasTemp    
	
		SELECT 
			G6X_DTFIN
		FROM 
			%Table:G6X% G6X	
		WHERE 
			G6X_FILIAL  = %xFilial:G6X%
			AND G6X_AGENCI = %Exp:cAgencia%
			AND G6X.%NotDel%
		ORDER BY G6X_DTFIN DESC	
		
	EndSQL
		
			
	If (cAliasTemp)->(!EOF())
		dDataIni := StoD((cAliasTemp)->(G6X_DTFIN))+1
	EndIf
	(cAliasTemp)->(DBCloseArea())
Return dDataIni



//-------------------------------------------------------------------
/*/{Protheus.doc} GA421RetDtFin(dDataIni, cAgencia)
Função responsável por calcular a data final da Ficha de Remessa

@author SIGAGTP | jacomo.fernandes
@since 14/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Function GA421RetDtFin(dDataIni, cAgencia)
Local dDataFin	:= CtoD('  /  /  ')

	If !Empty(dDataIni) 
		DbSelectArea('GI6')
		GI6->(DbSetOrder(1))
			If GI6->(DbSeek(xFilial('GI6')+cAgencia))
				If GI6->GI6_FCHCAI == '1'
					dDataFin := dDataIni
				Else
					dDataFin := TruncDate(GI6->GI6_DIASFC, dDataIni)
				EndIf
			EndIf
		EndIf
	
Return dDataFin

//-------------------------------------------------------------------
/*/{Protheus.doc} TruncDate(nPeriod, dIni)
Função responsável por calcular a data final da Ficha de Remessa

@author SIGAGTP | jacomo.fernandes
@since 14/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Static Function TruncDate(nPeriod, dIni)

// Subtrai 1 do período para contar o dia de inicio
Local dFin := DaySum(dIni, nPeriod - 1)

If (AnoMes(dIni) < AnoMes(dFin))
	Return LastDate(dIni)
EndIf

Return dFin

//-------------------------------------------------------------------
/*/{Protheus.doc} GA421RetDtFin(dDataIni, cAgencia)
Função responsável por calcular a data final da Ficha de Remessa

@author SIGAGTP | jacomo.fernandes
@since 14/07/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Function G421bVldMovi(dDtIni, dDtFim, cAgencia, cNumFch)
Local lRet		:= .T.
Local cTmpAlias	:= GetNextAlias()
Local cWhere	:= "%%"
Default dDtIni	:= CtoD('  /  /  ')
Default dDtFim	:= CtoD('  /  /  ')
Default cNumFch	:= ""

If !Empty(cNumFch)
	cWhere := "% AND G6X_NUMFCH <> '"+cNumFch+"' %"
Endif


	BeginSql alias cTmpAlias 
		SELECT G6X_DTINI,G6X_DTFIN 
		FROM %Table:G6X% G6X
		WHERE 
			G6X_FILIAL = %xFilial:G6X%
			AND G6X_AGENCI = %Exp:cAgencia%
			AND 
			((%Exp:DtoS(dDtIni)% BETWEEN G6X_DTINI AND G6X_DTFIN) OR
			(%Exp:DtoS(dDtFim)% BETWEEN G6X_DTINI AND G6X_DTFIN) OR
			(G6X_DTINI BETWEEN %Exp:DtoS(dDtIni)% AND %Exp:DtoS(dDtFim)%) OR
			(G6X_DTFIN BETWEEN %Exp:DtoS(dDtIni)% AND %Exp:DtoS(dDtFim)%))
			%Exp:cWhere%
			AND %NotDel%
	EndSql
	If (cTmpAlias)->(!EoF())
		lRet	:= .F.
		dDtIni	:= StoD((cTmpAlias)->G6X_DTINI)
		dDtFim	:= StoD((cTmpAlias)->G6X_DTFIN)
	Endif
	(cTmpAlias)->(DbCloseArea())

Return lRet	

/*/{Protheus.doc} ${function_method_class_name}
(long_description)
@type function
@author jacom
@since 05/04/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cAgencia, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldFchAberta(oMdl,cAgencia)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cAliasG6X	:= GetNextAlias()

	BeginSql Alias cAliasG6X
		SELECT
			Count(G6X_NUMFCH) AS TOTAL
		FROM
			%Table:G6X% G6X
		WHERE
			G6X.G6X_FILIAL = %xFilial:G6X%
			AND G6X_AGENCI = %Exp:cAgencia%
			AND G6X_STATUS IN ('1','5')	//RADU: Ajustado para ficha Reaberta - 25/11/21
			AND G6X.%NotDel%
	EndSql
	
	If (cAliasG6X)->TOTAL > 0
		lRet := .F.
		oModel:SetErrorMessage(oModel:GetId(),"G6X_AGENCI",oModel:GetId(),"G6X_AGENCI",'VLDFCHABERTA',STR0011,STR0012) //'A última Ficha de Remessa encontra-se com o status Aberto.'
	Endif
	(cAliasG6X)->(DbCloseArea())
	
Return lRet

/*/{Protheus.doc} GA421BAuto(lAcerto, aDados)
Função utilizada para automacao ADVPR	
@type function
@author flavio.martins
@since 12/03/2020
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA421BAuto(lAcerto, aDados)
Local oMdl421B := FwLoadModel('GTPA421B')
Local oMdl421  

oMdl421B:SetOperation(MODEL_OPERATION_INSERT)

oMdl421B:Activate()
 
oMdl421B:GetModel('G6XMASTER'):SetValue('G6X_AGENCI', aDados[1][1])

If lAcerto
	oMdl421B:GetModel('G6XMASTER'):SetValue('G6X_NUMFCH', aDados[1][2])
	oMdl421B:GetModel('G6XMASTER'):SetValue('G6X_DTINI',  STOD(aDados[1][3]))
	oMdl421B:GetModel('G6XMASTER'):SetValue('G6X_DTFIN',  STOD(aDados[1][4]))
	oMdl421B:GetModel('G6XMASTER'):SetValue('G6X_DTREME', STOD(aDados[1][5]))
Endif

If oMdl421B:VldData()
	oMdl421B:CommitData()
Endif

oMdl421  := FwLoadModel('GTPA421')

oMdl421:SetOperation(MODEL_OPERATION_INSERT)
oMdl421:Activate()
oMdl421:GetModel('G6XMASTER'):SetValue('G6X_AUSENC', .T.)
oMdl421:GetModel('G6XMASTER'):SetValue('G6X_AUSENC', .F.)


If oMdl421:VldData()
	oMdl421:CommitData()
Endif

Return

