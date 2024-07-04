#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TRMA250.CH'

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: TRMA250.PRW 	Autor: PHILIPE.POMPEU	Data:25/08/2015         ***
***********************************************************************************
***Descrição..: Cadastro de Conjunto de Etapas						      	    ***
***********************************************************************************
***Uso........: SIGATRM(Treinamento)      										***
***********************************************************************************
***Parâmetros.:		${param}, ${param_type}, ${param_descr}	          		    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***					ALTERAÇÕES FEITAS DESDE A CONSTRUÇÃO INICIAL              	***
***********************************************************************************
***Chamado....:                                                                 ***
**********************************************************************************/

/*/{Protheus.doc} TRMA250
	Cadastro do Conjunto de Etapas
@author PHILIPE.POMPEU
@since 25/08/2015
@version P12
@return Nil, Valor Nulo
/*/
Function TRMA250()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('AP0')
	oBrowse:DisableDetails()
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()
	
Return (Nil)

/*/{Protheus.doc} MenuDef
	Função estática responsável em estabelecer o layout do menu
@author PHILIPE.POMPEU
@since 25/08/2015
@version P12
@return aRotina, vetor contendo a configuração do menu
/*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title STR0002 Action 'PesqBrw'         OPERATION 1 ACCESS 0 /*Pesquisar */
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.TRMA250' OPERATION 2 ACCESS 0 /*Visualizar*/
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.TRMA250' OPERATION 3 ACCESS 0 /*Incluir*/
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.TRMA250' OPERATION 4 ACCESS 0 /*Alterar*/
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.TRMA250' OPERATION 5 ACCESS 0 /*Excluir*/
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.TRMA250' OPERATION 8 ACCESS 0 /*Imprimir*/
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.TRMA250' OPERATION 9 ACCESS 0 /*Copiar*/

Return (aRotina)

/*/{Protheus.doc} ModelDef
	Função Estática responsável pelo instânciamento do
	modelo de dados da tabela A10(Conjunto de Etapas) 
@author PHILIPE.POMPEU
@since 25/08/2015
@version P12
@return oModel, instância de MPFormModel
/*/
Static Function ModelDef()
	Local oStructMst := FWFormStruct( 1, 'AP0' )
	Local oStructGrd := FWFormStruct( 1, 'A10', {|x| AllowedFlds(x)}, /*lViewUsado*/ )
	Local oModel := Nil	
	
	oModel := MPFormModel():New('TRMA250', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('A10MASTER', /*cOwner*/,oStructMst)
	//oStructGrd:SetProperty('A10_PRAZO',MODEL_FIELD_VALID ,{|oModel|ValidaPr(oModel)} )
	oStructGrd:SetProperty('A10_WKFLOW',MODEL_FIELD_VALID ,FWBuildFeature( STRUCT_FEATURE_VALID, 'ValidaWF()' ))
	oStructGrd:SetProperty('A10_ETAPA'	,MODEL_FIELD_INIT  ,{|oModel|GetNextSeq(oModel)})	
	oStructGrd:SetProperty('A10_ETDESC'	, MODEL_FIELD_OBRIGAT, .T.)	

	oModel:AddGrid('A10DETAIL', 'A10MASTER', oStructGrd, /*bLinePre*/, { |oGrid| ValidaPr(oGrid) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	
	oModel:SetRelation( 'A10DETAIL', { { 'A10_FILIAL', 'xFilial( "A10" )' }, { 'A10_CJETAP', 'AP0_CJETAP' }}, A10->(IndexKey(1)))
	oModel:SetPrimaryKey({'AP0_FILIAL', 'AP0_CJETAP'})
	
	oModel:GetModel( 'A10DETAIL' ):SetUniqueLine( { 'A10_ETAPA' } )	
	
	oModel:SetDescription(STR0001)
	oModel:GetModel( 'A10MASTER' ):SetDescription(STR0001)
	oModel:GetModel( 'A10DETAIL' ):SetDescription(STR0001)
	
	
	oModel:SetVldActivate( { |oModel| A250VldIni(oModel,oModel:GetOperation()) } )
	
Return (oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A250VldIniºAutor  ³Leandro Drumond     º Data ³  03/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao antes da ativacao do modelo de dados   			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A250VldIni(oModel,nOperacao)
Local aArea     := GetArea()
Local lRet 		:= .T.
Local cAliasQry	:= GetNextAlias()

If nOperacao == MODEL_OPERATION_DELETE .Or. nOperacao == MODEL_OPERATION_UPDATE
	dbSelectArea("RA1")
	RA1->(dbSetorder(5))//RA1_FILIAL+RA1_CJETAP                                                                                                                                           
	If RA1->(dbSeek(xFilial("RA1")+AP0->AP0_CJETAP))
    	lRet := .F.
    	Help(,,'HELP',, STR0012 +RA1->RA1_CURSO+STR0013,1,0 ) //Conjunto de etapa em usao pelo curso XXXXXX, não pode sofrer alteração
   	Else
   		BeginSql alias cAliasQry
			SELECT A11_CJETAP,A11_CURSO
			FROM %table:A11% A11
			WHERE A11.A11_FILIAL =%exp:xFilial("A11")%
			AND A11.A11_CJETAP=%exp:AP0->AP0_CJETAP%
			AND A11.%NotDel%
		EndSql
		
		If !(cAliasQry)->(Eof())
	    	lRet := .F.
	    	Help(,,'HELP',, STR0012 +(cAliasQry)->A11_CURSO+STR0013,1,0 ) //Conjunto de etapa em usao pelo curso XXXXXX, não pode sofrer alteração
		EndIf
		(cAliasQry)->(dbCloseArea())
   	
   	EndIf	
EndIf

RestArea( aArea )

Return lRet

/*/{Protheus.doc} ViewDef
	Função estática responsável pela chamada da interface gráfica
	do modelo de dados
@author PHILIPE.POMPEU
@since 25/08/2015
@version P12
@return oView, instância da classe FWFormView
/*/
Static Function ViewDef()	
	Local oStructMst := FWFormStruct( 2, 'AP0' )
	Local oStructGrd := FWFormStruct( 2, 'A10' ,{|x| AllowedFlds(x)})	
	Local oModel   := FWLoadModel( 'TRMA250' )
	Local oView := Nil
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField( 'VIEW_MASTER', oStructMst, 'A10MASTER' )
	oView:AddGrid(  'VIEW_GRID'	 , oStructGrd, 'A10DETAIL' )
	
	oView:CreateHorizontalBox( 'SUPERIOR', 25 )
	oView:CreateHorizontalBox( 'INFERIOR', 75 )
	oView:SetOwnerView( 'VIEW_MASTER', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_GRID', 'INFERIOR' )
Return (oView)

/*/{Protheus.doc} AllowedFlds
	Campos permitidos nas Estruturas
@author PHILIPE.POMPEU
@since 25/08/2015
@version P12
@param nType, numérico, 0=Master e 1=Grid
@param cField, caractere	, Campo permitido
@return lResult, verdadeiro se o campo deve ser inserido na estrutura
/*/
Static Function AllowedFlds(cField)
	Local lResult	:= .T.	
	cField := AllTrim(cField)
	lResult := (cField $ "A10_ETAPA|A10_ETDESC|A10_PRAZO|A10_WKFLOW")
Return (lResult)

/*/{Protheus.doc} ValidaWF
	Valida chave duplicada do campo de WorkFlow(A10_WKFLOW)
@author PHILIPE.POMPEU
@since 25/08/2015
@version P12
@param oGridModel, objeto, instância de FWFormGridModel 
@return lResult, Verdadeiro se não há valores duplicados
/*/
 Function ValidaWF()

	Local aArea	:= GetArea()
	Local oModel := FwModelActive()
	Local oGridModel := oModel:GetModel("A10DETAIL")
	Local lResult := .T.
	Local aSaveLines := FWSaveRows()
	Local nI := 1
	Local cWorkFlow:= ''
	Local aValores := {}
	
	For nI := 1 To oGridModel:Length()
		oGridModel:GoLine( nI )
		cWorkFlow := oGridModel:GetValue('A10_WKFLOW')		
		If(cWorkFlow <> '0')
			
			If(Len(aValores) > 0)
				If(aScan(aValores,cWorkFlow) > 0)
					Help(" ",1,"Help",,STR0009,1,0)
					lResult := .F.
					Exit
				Else
					aAdd(aValores,cWorkFlow)
				EndIf
			Else
				aAdd(aValores,cWorkFlow)
			EndIf
		EndIf
	Next nI
	
	FWRestRows(aSaveLines)
	RestArea(aArea)	
Return (lResult)


/*/{Protheus.doc} ValidaPr
	Valida chave duplicada do campo de WorkFlow(A10_WKFLOW)
@author PHILIPE.POMPEU
@since 25/08/2015
@version P12
@param oGridModel, objeto, instância de FWFormGridModel 
@return lResult, Verdadeiro se não há valores duplicados
/*/
Static Function ValidaPr(oGridModel)
Local aArea	:= GetArea()
Local lResult := .T.
Local nLinGrdPos := oGridModel:GetLine()

If oGridModel:GetValue('A10_PRAZO') <=0		
	Help(" ",1,"Help",,STR0014,1,0)//"Valor deve ser maior que zero(0)"
	lResult := .F.
EndIf

RestArea(aArea)	
Return (lResult)

/*/{Protheus.doc} GetNextSeq
	Obtem a próxima sequência no Grid somando-se de 100 em 100.
@author PHILIPE.POMPEU
@since 26/08/2015
@version P12
@param oGridModel, objeto,  instância de FWFormGridModel
@return cResult, próxima sequência
/*/
Static Function GetNextSeq(oGridModel)
	Local aArea	:= GetArea()
	Local nMaior	:= 1
	Local cResult := ''
	Local cValue	:= ''
	Local nValue	:= 0
	Local nI := 1
	Local aSaveLines:= FWSaveRows()
	Local nTamEtapa := TamSx3('A10_ETAPA')[1]
	
	For nI := 1 To oGridModel:Length()
		oGridModel:GoLine( nI )
		cValue := oGridModel:GetValue('A10_ETAPA')		
		if(cValue <> '')			
			nValue := Val(cValue)
		Else
			nValue := 1	
		endIf		
		if(nI == 1)
			nMaior := nValue	
		endIf
		
		if(nValue > nMaior)
			nMaior := nValue
		endIf
		
		/*Caso o último seja deletado ele apenas o substitui ao invés de incrementar*/
		if(nI == oGridModel:Length()) .And. oGridModel:IsDeleted() .And. nMaior > 1
			nMaior -= 100 
		endIf
		
	Next nI
	if(nMaior == 1) 
		nMaior *= 100
	Else
		nMaior += 100
	endIf
	
	cResult := StrZero(nMaior,nTamEtapa)
	FWRestRows(aSaveLines)
	RestArea(aArea)
Return (cResult)

/*/{Protheus.doc} VldCjEtp
	Validar o Conjunto de Etapas
@author PHILIPE.POMPEU
@since 31/08/2015
@version P12
@param cConjunto, caractere, Conjunto de Etapas a ser procurado
@return lResult, Verdadeiro se o registro existe na tabela A10
/*/
Function VldCjEtp(cConjunto)
	Local aArea	:= A10->(GetArea())
	Local lResult := .T.
	Default cConjunto := &(ReadVar()) 	
	
	if!(Empty(cConjunto))
		A10->(DbSetOrder(1))		
		lResult := A10->(dbSeek(FwXFilial('A10') + cConjunto))		
	endIf
	
	if(!lResult)
		Help(" ",1,"Help",,STR0010,1,0)		
	endIf
	
	RestArea(aArea)
Return (lResult)
