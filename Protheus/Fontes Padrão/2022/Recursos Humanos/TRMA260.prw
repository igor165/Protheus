#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TRMA260.CH"

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: TRMA260.PRW  Autor: PHILIPE.POMPEU      Data:01/09/2015         ***
***********************************************************************************
***Descrição..: Manutenção de CheckList(Tabela A11)                             ***
***********************************************************************************
***Uso........: Treinamento(SIGATRM)                                            ***
***********************************************************************************
***Parâmetros.: aCurso, Vetor, Vetor Contendo os Campos do Curso                ***
***********************************************************************************
***Retorno....: Nil, Valor Nulo                                                 ***
***********************************************************************************
***	            ALTERAÇÕES FEITAS DESDE A CONSTRUÇÃO INICIAL               	    ***
***********************************************************************************
***Chamado....:                                                                 ***
**********************************************************************************/
/*/{Protheus.doc} TRMA260
	Rotina de Cadastro de CheckList(A11)
@author PHILIPE.POMPEU
@since 01/09/2015
@version P12
@param aCurso, vetor, dados do curso(RA4)
@return Nil, valor nulo
/*/
Function TRMA260(aCurso)
	Local oBrowse
	Local aAreas	:= {}
	Local cMensagem := ''
	Local lShowView := .T.
	Local oMdl
	Local nOperation:= 4
	Default aCurso := {}
	
	if(Len(aCurso) <> 0)
		aAreas	:= {RA4->(GetArea()),RA1->(GetArea()),SRA->(GetArea()),GetArea()}
		
		/*	Posicionando-se na tabela de Funcionários(SRA),Conjunto de Etapas(A10),
		na de Cursos Internos(RA1) e na de Cursos de Funcionários(RA4)*/
		if(PrepareEnv(aCurso, @cMensagem))
			if!(Empty(RA4->RA4_VALIDA))
				
				if!(FindRecord())
					if!(GenChkLst(@cMensagem,@oMdl))
						Help(" ",1,"Help",,cMensagem,1,0)
						lShowView := .F.									
					endIf								
				endIf
				if(lShowView)		
					If Valtype(oMdl) == "O"
						oMdl:GetModel( 'A11DETAIL' ):SetNoInsertLine()
						oMdl:GetModel( 'A11DETAIL' ):SetNoDeleteLine()							
					EndIf
					FWExecView(STR0001, 'TRMA260', nOperation, /*oDlg*/, { || .T. }/*bCloseOnOk*/, /*bOk*/, 10, /*aEnableButtons*/, /*bCancel*/ ,/*[ cOperatId ]*/, /*[ cToolBar ]*/, oMdl/*[ oModelAct ]*/)				
				endIf			
			Else
				Help(" ",1,"Help",,STR0016,1,0)			
			endIf
		Else
			Help(" ",1,"Help",,cMensagem,1,0)		
		endIf
		aEval(aAreas,{|aArea|RestArea(aArea)})

	Else
		/*Nessa situação a rotina foi chamada do Menu*/	
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('A11')
		oBrowse:DisableDetails()
		oBrowse:SetDescription(STR0001)
		oBrowse:AddLegend("A11_SITUAC=='0'", "GREEN"	, STR0014 )
		oBrowse:AddLegend("A11_SITUAC=='1'", "RED"	, STR0015 )
		oBrowse:Activate()
	endIf	
Return (Nil)

/*/{Protheus.doc} MenuDef
	Retorna o Menu da Aplicação TRMA260
@author PHILIPE.POMPEU
@since 03/09/2015
@version P12
@return aRotina, Configuração do Menu
/*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title STR0002 Action 'PesqBrw'         OPERATION 1 ACCESS 0 /*Pesquisar */
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.TRMA260' OPERATION 2 ACCESS 0 /*Visualizar*/
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.TRMA260' OPERATION 3 ACCESS 0 /*Incluir*/
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.TRMA260' OPERATION 4 ACCESS 0 /*Alterar*/
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.TRMA260' OPERATION 5 ACCESS 0 /*Excluir*/
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.TRMA260' OPERATION 8 ACCESS 0 /*Imprimir*/
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.TRMA260' OPERATION 9 ACCESS 0 /*Copiar*/

Return (aRotina)

/*/{Protheus.doc} ModelDef
	Retorna o Modelo de Dados da Tabela de CheckList(A11)
@author PHILIPE.POMPEU
@since 03/09/2015
@version P12
@return oModel, instância de MPFormModel
/*/
Static Function ModelDef(lNewLines)
	Local oStructMst := FWFormStruct( 1, 'A11', {|x| AllowedFlds(0,x)}, /*lViewUsado*/ )
	Local oStructGrd := FWFormStruct( 1, 'A11', {|x| AllowedFlds(1,x)}, /*lViewUsado*/ )
	Local oModel := Nil
	Local aRelation:= {}
	Local bVldCheck  := FwBuildFeature(STRUCT_FEATURE_VALID,'StaticCall(TRMA260,VldCheck,a,b)')
	Local bVldEntreg := FwBuildFeature(STRUCT_FEATURE_VALID,'StaticCall(TRMA260,VldEntreg,a,b)')
	/*Local bCommonWhen:= FwBuildFeature(STRUCT_FEATURE_WHEN,'StaticCall(TRMA260,CommonWhen,a,b)')*/
	Default lNewLines := .F.
	
	oModel := MPFormModel():New('TRMA260', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('A11MASTER', /*cOwner*/,oStructMst)

	oStructGrd:SetProperty( 'A11_ETDESC' , MODEL_FIELD_INIT,{|oGrid| if(Inclui,"",Posicione("A10",1,xFilial("A10")+If(oGrid:Length()>0,oGrid:GetValue("A11_CJETAPA")+oGrid:GetValue("A11_ETAPA"),A11->A11_CJETAPA+substr(A11->A11_ETAPA,1,2)+"00"),"A10_ETDESC"))})

	oModel:AddGrid('A11DETAIL', 'A11MASTER', oStructGrd, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	aAdd(aRelation,{ 'A11_FILIAL', 'xFilial( "A11" )' })
	aAdd(aRelation,{ 'A11_MAT'   , 'A11_MAT' })
	aAdd(aRelation,{ 'A11_CURSO' , 'A11_CURSO' })
	aAdd(aRelation,{ 'A11_VALIDA', 'A11_VALIDA' })
	aAdd(aRelation,{ 'A11_CJETAP', 'A11_CJETAP' })
	aAdd(aRelation,{ 'A11_SITUAC', 'A11_SITUAC' })
	
	oModel:SetRelation( 'A11DETAIL', aRelation, A11->(IndexKey(RetOrder("A11", "A11_FILIAL+A11_MAT+A11_CURSO+DTOS(A11_VALIDA)+A11_CJETAP+A11_SITUAC"))))
	oModel:SetPrimaryKey({'A11_FILIAL', 'A11_MAT','A11_CURSO','A11_VALIDA','A11_CJETAP','A11_ETAPA'})
	
	oModel:GetModel( 'A11DETAIL' ):SetUniqueLine( { 'A11_ETAPA' } )	
	
	oModel:SetDescription(STR0001)
	oModel:GetModel( 'A11MASTER' ):SetDescription(STR0001)
	
	
	oModel:GetModel( 'A11DETAIL' ):SetDescription(STR0001)	
	
	if(!lNewLines) /*Via ExecAuto será possível alterar o comportamento!*/
		oModel:GetModel( 'A11DETAIL' ):SetNoInsertLine()
		oModel:GetModel( 'A11DETAIL' ):SetNoDeleteLine()	
	endIf	 
	 
	oStructGrd:SetProperty('A11_CHECK'	,MODEL_FIELD_VALID  ,bVldCheck)	
	oStructGrd:SetProperty('A11_ENTREG',MODEL_FIELD_VALID  ,bVldEntreg)		
	oStructGrd:SetProperty('*',MODEL_FIELD_WHEN  ,{|oGrid,cField|CommonWhen(oGrid,cField)})
Return (oModel)

/*/{Protheus.doc} ViewDef
	Retorna a View pro Modelo de Dados da tabela A11
@author PHILIPE.POMPEU
@since 03/09/2015
@version P12.1.7
@return oView, objeto da view
/*/
Static Function ViewDef()	
	Local oStructMst := FWFormStruct( 2, 'A11' ,{|x| AllowedFlds(0,x,.T.)})
	Local oStructGrd := FWFormStruct( 2, 'A11' ,{|x| AllowedFlds(1,x,.T.)})	
	Local oModel   := FWLoadModel( 'TRMA260' )
	Local oView := Nil
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField( 'VIEW_MASTER', oStructMst, 'A11MASTER' )
	oView:AddGrid(  'VIEW_GRID'	 , oStructGrd, 'A11DETAIL' )
	
	oView:CreateHorizontalBox( 'SUPERIOR', 35 )
	oView:CreateHorizontalBox( 'INFERIOR', 65 )
	oView:SetOwnerView( 'VIEW_MASTER', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_GRID', 'INFERIOR' )
	
	oView:SetCloseOnOk({ || .T. })
Return (oView)

/*/{Protheus.doc} AllowedFlds
	Campos permitidos na estrutura.
@author PHILIPE.POMPEU
@since 03/09/2015
@version P12.1.7
@param nType, numérico, Tipo(0:Master;1:Grid)
@param cField, caractere, Campo a ser avaliado (Ex. A11_CURSO)
@param lIsView, lógico, Se é View
@return lResult, lógico, verdadeiro se permitido.
/*/
Static Function AllowedFlds(nType,cField,lIsView)
	Local lResult	:= .T.	
	Local cHeader := ''
	Local cItems	:= ''
	Default lIsView := .F.
	
	cHeader:= "A11_FILIAL|A11_MAT|A11_NOME|A11_CURSO|A11_CDESC|A11_VALIDA|A11_DTAREC|A11_CJETAP|A11_CJDESC|A11_SITUAC"
	if(lIsView)		
		cItems	:= "A11_ETAPA|A11_ETDESC|A11_PRAZO|A11_ENTREG|A11_RESPON|A11_CHECK|A11_STATUS|A11_WKFLOW"
	Else		
		cItems	:= "A11_ETAPA|A11_ETDESC|A11_PRAZO|A11_ENTREG|A11_RESPON|A11_CHECK|A11_STATUS|A11_WKFLOW|A11_DTAETP"
	endIf
	
	
	cField := AllTrim(cField)
	Do Case
		Case (nType == 0) /*Master*/
			lResult := (cField $ cHeader)
		Case (nType == 1) /*Grid*/
			lResult := (cField $ cItems)
	EndCase	
Return (lResult)

/*/{Protheus.doc} GenChkLst
	Responsável por gerar o CheckList
@author PHILIPE.POMPEU
@since 01/09/2015
@version P12
@param cMensagem, caractere, retorna a mensagem de erro caso o retorno seja falso
@return lResult, lógico, verdadeiro se gerado com sucesso
/*/
Static Function GenChkLst(cMensagem,oMpFrmMod)	
	Local oFwFrmFld
	Local oFwFrmGrd
	Local nQtd := 0
	Local lResult := .T.
	Local aAreas := {SRA->(GetArea()),RA1->(GetArea()),RA4->(GetArea()),A10->(GetArea())}
	Default cMensagem := ''
	
	//fecha possivel checklist aberto
	FecChkList(SRA->RA_FILIAL,SRA->RA_MAT,RA1->RA1_CJETAP,RA1->RA1_CURSO)
	
	oMpFrmMod := ModelDef(.T.) /* Instância de MPFormModel */	
	oMpFrmMod:SetOperation(3)
	oMpFrmMod:Activate()
	oFwFrmFld	:= oMpFrmMod:GetModel("A11MASTER") /* Instância de FwFormField */
	oFwFrmGrd	:= oMpFrmMod:GetModel("A11DETAIL") /* Instância de FwFormGrid */
	
	/*Aparentemente durante a ativação do Modelo pode ocorrer que as tabelas
	 mudem de posicionamento. Creio que seja por causa dos "Posicione" dentro
	 dos Inicializadores Padrão dos campos.*/
	aEval(aAreas,{|x|RestArea(x)})
	
	oFwFrmFld:LoadValue('A11_FILIAL',FwXFilial('A11'))
	oFwFrmFld:LoadValue('A11_MAT'   ,SRA->RA_MAT)
	oFwFrmFld:LoadValue('A11_NOME'  ,SRA->RA_NOME)
	oFwFrmFld:LoadValue('A11_CURSO' ,RA1->RA1_CURSO)
	oFwFrmFld:LoadValue('A11_CDESC' ,RA1->RA1_DESC)
	oFwFrmFld:LoadValue('A11_VALIDA',RA4->RA4_VALIDA)
	oFwFrmFld:LoadValue('A11_CJETAP',RA1->RA1_CJETAP)
	oFwFrmFld:LoadValue('A11_CJDESC',Posicione("AP0",1,xFilial("AP0")+RA1->RA1_CJETAP,"AP0_CJDESC"))
	oFwFrmFld:LoadValue('A11_DTAREC',RA4->RA4_DATAIN)
	oFwFrmFld:LoadValue('A11_SITUAC','0')
	
	while ( A10->(!Eof()) .And. A10->A10_FILIAL == FwXFilial('A10') .And. A10->A10_CJETAP == RA1->RA1_CJETAP)		
		
		if(nQtd == 0)			
			oFwFrmGrd:LoadValue('A11_DTAETP', Date())
		Else																		
			oFwFrmGrd:AddLine()
		endIf		
				
		oFwFrmGrd:LoadValue('A11_ETAPA',A10->A10_ETAPA)
		oFwFrmGrd:LoadValue('A11_ETDESC',A10->A10_ETDESC)
		oFwFrmGrd:LoadValue('A11_PRAZO',A10->A10_PRAZO)		
		oFwFrmGrd:LoadValue('A11_STATUS','0')
		oFwFrmGrd:LoadValue('A11_WKFLOW',A10->A10_WKFLOW)		
		
		nQtd++
		A10->(dbSkip())
	End
	
Return (lResult)

/*/{Protheus.doc} PrepareEnv
	Baseado no vetor aCurso se posiciona em todas as tabelas corretamente.
@author PHILIPE.POMPEU
@since 10/09/2015
@version P12
@param aCurso, vetor, Deve conter os campos da tabela RA4 para o qual se quer posicionar.
@param cMensagem, caractere, variável deve ser passada por referência, retorna o erro.
@return lResult, Lógico, Verdadeiro se conseguir se posicionar em todas as tabelas
/*/
Static Function PrepareEnv(aCurso,cMensagem)
	Local lResult 	:= .T.
	Local nIndex 	:= 0
	Local cChave 	:= ''
	Local nRecno	:= 0
	cChave += FwxFilial('RA4')
	
	nIndex := aScan(aCurso,{|x|x[1] == 'RA4_REC_WT'})	
	if(nIndex == 0)
		cMensagem := STR0013
		Return (.F.)
	Else
		nRecno := aCurso[nIndex,2]
	endIf

	RA4->(dbGoTo(nRecno))
	RA1->(DbSetOrder(1))	
	if(RA1->(dbSeek(FwXFilial('RA1') + RA4->RA4_CURSO)))	
		A10->(DbSetOrder(1))			
		if!(Empty(RA1->RA1_CJETAP)) .And. A10->(DbSeek(FwXFilial('A10') + RA1->RA1_CJETAP))				
			SRA->(DbSetOrder(1))				
			lResult := (SRA->(DbSeek(FwXFilial('SRA') + RA4->RA4_MAT))) 		
			if!lResult					
				cMensagem := STR0009
			endIf
		Else				
			lResult := .F.
			cMensagem := STR0010 //Conjunto de Etapas não encontrado.
		endIf			
	Else
		lResult := .F.
		cMensagem := STR0011 //Curso Não Encontrado
	endIf
Return (lResult)


/*/{Protheus.doc} FindRecord
	Procura na tabela A11(CheckList) o registro baseado no posicionamento
	das tabelas.
@author PHILIPE.POMPEU
@since 10/09/2015
@version P12
@return lResult, lógico, verdadeiro caso já exista o curso
/*/
Static Function FindRecord()
	Local lResult := .F.
	
	A11->(DbSetOrder(1))
	lResult := A11->(DbSeek(FwxFilial('A11') + SRA->RA_MAT + RA1->RA1_CURSO + DToS(RA4->RA4_VALIDA) + A10->A10_CJETAP))	
	
Return (lResult)

/*/{Protheus.doc} VldCheck
	Quando o campo check(A11_CHECK) for preenchido a Data da Etapa (A11_DTAETP) será preenchido com 
	a data do sistema. Caso o campo A11_CHECK seja limpo durante alteração,limpar também o campo Data da Etapa.
@author PHILIPE.POMPEU
@since 09/09/2015
@version P12
@param oGrdModel, objeto, instância da classe FWFormGrid
@return lResult, lógico, sempre retorna .T.
/*/
Static Function VldCheck(oGrdModel,cField)
	Local aArea	:= GetArea()
	Local lResult := .T.
	Local aSaveLines := FWSaveRows()
	Local nGoLine := 0
	Local dValue	:= CtoD('')
	Local dDataLimite := CtoD('')
	
	If(oGrdModel:GetValue('A11_STATUS') == '3' .Or. oGrdModel:GetValue('A11_WKFLOW') <> '0' )
		lResult := AreUSure(STR0022)	//"Esta etapa é de realização automática. Caso preencha manualmente, o sistema não realizará a etapa. Deseja mesmo continuar?"			
		If(!lResult)
			Help(" ",1,"Help",,STR0023,1,0)//"Valor não será atribuido."
		Else
			oGrdModel:LoadValue('A11_ENTREG',dDataBase)
			oGrdModel:LoadValue('A11_RESPON',dDataBase)
		EndIf		
	EndIf
	
	If lResult
		nGoLine := oGrdModel:nLine + 1
		If(oGrdModel:GetValue('A11_CHECK'))		
			dValue := dDataBase
			/*Caso A11_CHECK seja preenchido, os campo: Data de Entrega e 
			Usuário Responsável devem estar preenchidos também*/
			If(Empty(oGrdModel:GetValue('A11_ENTREG')) .Or. Empty(oGrdModel:GetValue('A11_RESPON')))
				Help(" ",1,"Help",,STR0017,1,0)//"Os campo Data de Entrega e Usuário Responsável devem estar preenchidos."
				lResult := .F.	
			EndIf
			
			If(lResult)
				/*Data Limite = (A11_DTAETP + A11_PRAZO)*/
				dDataLimite := (oGrdModel:GetValue('A11_DTAETP') + oGrdModel:GetValue('A11_PRAZO'))				
				If(oGrdModel:GetValue('A11_ENTREG') <=  dDataLimite)
					/*1=EM DIA : receberá esse conteúdo quando a data de entrega da etapa for igual ou menor à data limite.*/
					oGrdModel:LoadValue('A11_STATUS','1') 
				Else
					/*2=ATRASADO : receberá esse conteúdo quando a data de entrega da etapa for maior à data limite.*/
					oGrdModel:LoadValue('A11_STATUS','2')
				EndIf
				
			EndIf	
		Else
			oGrdModel:LoadValue('A11_STATUS','0')
		EndIf
		If(nGoLine <= oGrdModel:GetQTDLine()) .And. lResult
	
			oGrdModel:GoLine(nGoLine)
			oGrdModel:SetValue('A11_DTAETP',dValue)
		EndIf
	EndIf
	
	FWRestRows(aSaveLines)
	aSize(aSaveLines,0)
	aSaveLines := Nil
	RestArea(aArea)
Return (lResult)

/*/{Protheus.doc} VldEntreg
 Responsável por validar o campo A11_ENTREG(Data de Entrega)
@author PHILIPE.POMPEU
@since 10/09/2015
@version P12
@param oGrdModel, objeto, instância da classe FWFormGrid
@return lResult, lógico, verdadeiro se o valor for válido
/*/
Static Function VldEntreg(oGrdModel,cField)
	Local aArea	:= GetArea()
	Local aSaveLines := FWSaveRows()
	Local lResult	:= .T.
	Local dValue
	Local nLinAnt	:= 0
	
	dValue := oGrdModel:GetValue('A11_ENTREG')
	nLinAnt:= oGrdModel:nLine	
	
	if!(Empty(dValue))
		/*Deverá ser igual ou maior que a data da etapa (A11_DTAETP)*/
		if (dValue < oGrdModel:GetValue('A11_DTAETP'))
			lResult := .F.
			Help(" ",1,"Help",,STR0018,1,0)
		endIf
		
		if(lResult .And. nLinAnt > 1)
			/*Deverá ser igual ou maior que a data de entrega da etapa anterior (A11_ENTREG)*/
			oGrdModel:GoLine(nLinAnt - 1)
			if !(dValue >= oGrdModel:GetValue('A11_ENTREG'))
				lResult := .F.
				Help(" ",1,"Help",,STR0019,1,0)
			endIf			
		endIf		
	endIf
	
	FWRestRows(aSaveLines)
	aSize(aSaveLines,0)
	aSaveLines := Nil
	RestArea(aArea)
Return (lResult)

/*/{Protheus.doc} CommonWhen
	Evento WHEN genérico, de todos os campos. A função recebe além do objeto
	do modelo o nome do Campo, possibilitando outras validações.
@author PHILIPE.POMPEU
@since 10/09/2015
@version P12
@param oGrdModel, objeto, instância da classe FWFormGrid
@param cField, caractere, nome do campo.
@return lResult, lógico, verdadeiro se o valor for válido
/*/
Static Function CommonWhen(oGrdModel,cField)	
	Local lResult	:= .T.
	
	if(oGrdModel:GetValue('A11_CHECK') .And. !oGrdModel:IsUpdated())//( cField != 'A11_CHECK')
		Help(" ",1,"Help",,STR0021,1,0)//"Etapas já preenchidas em alterações anteriores não podem ser alteradas."
		lResult := .F.
	endIf	
	if(lResult)
		if(oGrdModel:GetValue('A11_STATUS') == '3' .And. cField != 'A11_CHECK')	//Registros com status automático não podem ser alterados pelo usuário.				
			Help(" ",1,"Help",,STR0020,1,0)
			lResult := .F.			
		endIf
	endIf	
Return (lResult)

/*/{Protheus.doc} AreUSure
	Pergunta se deseja prosseguir.
@author PHILIPE.POMPEU
@since 11/09/2015
@version P12
@param cQuestion, caractere, Pergunta
@param lIfIsBlind, lógico, valor que deve ser retornado caso seja um ExecAuto/Job
@return Lógico, verdadeiro se deve prosseguir.
/*/
Function AreUSure(cQuestion,lIfIsBlind)
	Default cQuestion := ''
	Default lIfIsBlind := .T.
Return (IIF(IsBlind(),lIfIsBlind,ApMsgYesNo(cQuestion)))

/*/{Protheus.doc} GetChkList
	Verifica se o curos/Funcionario tem checklist para a etapa
@author Flavio Correa
@since 06/06/2016
@version P12
@param cFilMat,cMat,cEtp,cWF,cCurso
@return Recno da etapa
/*/
Function GetChkList(cFilMat,cMat,cEtp,cWF,cCurso)
Local aArea		:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local nRecno	:= 0
Local cWhere	:= "%%"

If cWF <> "1"
	cWhere := "%"
	cWhere += " AND A11.A11_CHECK = 'F'"
	cWhere += " AND A11.A11_ENTREG = ''"
	cWhere += "%"
EndIf

BeginSql alias cAliasQry

	SELECT A11.R_E_C_N_O_ AS RECNOA11 
	FROM %table:A11% A11
	WHERE A11.A11_FILIAL =%exp:cFilMat%
	AND A11.A11_MAT=%exp:cMat%
	AND A11.A11_CURSO=%exp:cCurso%
	AND A11.A11_SITUAC='0'
	AND A11.%NotDel%
	%exp:cWhere%
	AND A11.A11_WKFLOW=%exp:cWF%
	AND A11.A11_CJETAP=%exp:cEtp%
	ORDER BY A11_ETAPA DESC 
EndSql

If !(cAliasQry)->(Eof())
	nRecno := (cAliasQry)->RECNOA11
EndIf

(cAliasQry)->(dbCloseArea())
RestArea(aArea)
Return nRecno

/*/{Protheus.doc} UpdEtapa
	Atualiza a etapa que foi feita pelos Workflow's
@author Flavio Correa
@since 06/06/2016
@version P12
@param nRecno
@return .T.
/*/
Function UpdEtapa(nRecno,dDtRec,lNovaEtp)
Local aArea		:= GetArea()
Local cChave 	:= ""
Local lNovo		:= .F.
Local aOri		:= {}

DEFAULT dDtRec := Ctod("  /  /  ")
DEFAULT lNovaEtp := .F.

A11->(dbGoTo(nRecno))
cChave := A11->(A11_FILIAL+A11_MAT+A11_CURSO+dtos(A11_VALIDA)+A11_CJETAP)
If A11->A11_CHECK .And. lNovaEtp
	//se wf =1 e ja tem etapa executada cria nova etapa, pois o wf de curso a vencer pode ter recorrencia
	lNovo := .T.
	aadd(aOri,{	A11->A11_FILIAL ,;
				A11->A11_MAT,;
				A11->A11_CURSO,;
				A11->A11_VALIDA,;
				A11->A11_DTAREC,;
				A11->A11_CJETAP,;
				A11->A11_ETAPA	})
EndIf

RecLock("A11",lNovo)
	If lNovo
		A11->A11_FILIAL	:= aOri[1][1]
		A11->A11_MAT	:= aOri[1][2]
		A11->A11_CURSO	:= aOri[1][3]
		A11->A11_VALIDA	:= aOri[1][4]
		A11->A11_DTAREC	:= aOri[1][5]
		A11->A11_CJETAP	:= aOri[1][6]
		A11->A11_WKFLOW	:= "1"
		A11->A11_SITUAC := "0"
		A11->A11_ETAPA	:= strzero(Val(aOri[1][7]) + 1,tamsx3("A11_ETAPA")[1])
		A11->A11_DTAETP	:= date()
		A11->A11_PRAZO	:= 0
	EndIf
	A11->A11_RESPON := "SISTEMA"
	A11->A11_CHECK 	:= .T.
	A11->A11_STATUS := "3" //automatico
	A11->A11_ENTREG := date()
	If !Empty(dDtRec)
		A11->A11_DTAREC	:= dDtRec
	EndIf
A11->(msUnlock())

//preencher a data da proxima etapa
A11->(dbSkip())
If cChave == A11->(A11_FILIAL+A11_MAT+A11_CURSO+dtos(A11_VALIDA)+A11_CJETAP) .And. Empty(A11->A11_DTAETP)
RecLock("A11",.F.)
	A11->A11_DTAETP	:= date()
A11->(msUnlock())
EndIf
RestArea(aArea)
Return .T.

/*/{Protheus.doc} GetChkList
	Verifica se o curos/Funcionario tem checklist para a etapa
@author Flavio Correa
@since 06/06/2016
@version P12
@param cFilMat,cMat,cEtp,cWF,cCurso
@return Recno da etapa
/*/
Function FecChkList(cFilMat,cMat,cEtp,cCurso)
Local aArea		:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local nRecno	:= 0

BeginSql alias cAliasQry
	SELECT A11.R_E_C_N_O_ AS RECNOA11 
	FROM %table:A11% A11
	WHERE A11.A11_FILIAL =%exp:cFilMat%
	AND A11.A11_MAT=%exp:cMat%
	AND A11.A11_CURSO=%exp:cCurso%
	AND A11.A11_SITUAC='0'
	AND A11.%NotDel%
	AND A11.A11_CJETAP=%exp:cEtp%
EndSql

While !(cAliasQry)->(Eof())
	nRecno := (cAliasQry)->RECNOA11
	A11->(dbGoto(nRecno))
	RecLock("A11",.F.)
		A11->A11_SITUAC := "1"
	A11->(msUnlock())
	(cAliasQry)->(dbskip())
EndDo

(cAliasQry)->(dbCloseArea())
RestArea(aArea)
Return 
