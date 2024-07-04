#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#INCLUDE 'GCPA120.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA120
Cadastro de Check-list

@author Flavio T. Lopes
@since 10/09/2013
@version P11
@return nil
/*/
//-------------------------------------------------------------------
Function GCPA120()
Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias('COV')
oBrowse:SetDescription(STR0001)//'Cadastro de Check-List'
oBrowse:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author Flavio T. Lopes
@since 10/09/2013
@version P11
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oStruCOV := FWFormStruct( 1, 'COV' )
Local oStruCOX := FWFormStruct( 1, 'COX' )
Local oModel

oModel := MPFormModel():New( 'GCPA120',,{|oModelGrid, nLine,cAction,  cField|A120VldT(oModelGrid, nLine, cAction, cField)})
oModel:AddFields( 'COVMASTER', /*cOwner*/, oStruCOV)
oModel:AddGrid( 'COXDETAIL', 'COVMASTER',oStruCOX,{|oModelGrid, nLine,cAction,  cField|A120VldGrd(oModelGrid, nLine, cAction, cField)})
oModel:SetRelation( 'COXDETAIL',	 {;
											{ 'COX_FILIAL', 'xFilial( "COX" )' },;
											{ 'COX_CODIGO', 'COV_CODIGO'		    } ;
										}, COX->( IndexKey( 1 ) ) )
oModel:SetDescription( STR0002 )//'Modelo de dados de Check-List'

oModel:GetModel( 'COVMASTER' ):SetDescription( STR0003 )//'Cabe�alho do Check-List'
oModel:GetModel( 'COXDETAIL' ):SetDescription( STR0004 )//'Item do Check-List'
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author Flavio T. Lopes
@since 10/09/2013
@version P11
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oPanel
Local oModel := FWLoadModel( 'GCPA120' )
Local oStruCOV := FWFormStruct( 2, 'COV' )
Local oStruCOX := FWFormStruct( 2, 'COX' )

oStruCOX:RemoveField('COX_CODIGO')

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_COV', oStruCOV, 'COVMASTER' )
oView:Addgrid( 'VIEW_COX', oStruCOX, 'COXDETAIL')
oView:CreateHorizontalBox( 'SUPERIOR', 15)
oView:CreateHorizontalBox( 'INFERIOR', 85)
oView:CreateVerticalBox( 'INFERIORESQ', 100, 'INFERIOR')
oView:CreateVerticalBox( 'INFERIORDIR', 150, 'INFERIOR',.T.)
oView:SetOwnerView( 'VIEW_COV', 'SUPERIOR' )
oView:EnableTitleView('VIEW_COV',STR0005)//'Cabe�alho Check-List'
oView:SetOwnerView( 'VIEW_COX', 'INFERIORESQ' )
oView:EnableTitleView('VIEW_COX',STR0006)//'Itens Check-List'
oView:AddIncrementField( 'VIEW_COX', 'COX_ITEM' )
oView:AddIncrementField( 'VIEW_COX', 'COX_ORDEM' )

oView:AddOtherObject("OTHER_PANEL", {|oPanel| GCPGrdOrd( oPanel, oView, 'COXDETAIL', 'COX_ITEM' )})
oView:SetOwnerView("OTHER_PANEL",'INFERIORDIR')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do menu

@author Flavio T. Lopes
@since 10/09/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0007		Action 'VIEWDEF.GCPA120' OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina Title STR0008		Action 'VIEWDEF.GCPA120' OPERATION 3 ACCESS 0//'Incluir'
ADD OPTION aRotina Title STR0541		Action 'VIEWDEF.GCPA120' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title STR0009		Action 'VIEWDEF.GCPA120' OPERATION 5 ACCESS 0//'Excluir'
ADD OPTION aRotina Title STR0010 		Action 'A120IMPORT()'	 OPERATION MODEL_OPERATION_INSERT	ACCESS 0//'Carrega Check-list'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} A084Prod
Valid do campo COX_PROPRI
@author Flavio T. Lopes
@since 10/09/2013
@version P11
@return lRet 
/*/
//-------------------------------------------------------------------
Function A120Prop()
Local oModel 		:= FWModelActive()
Local oModelCOX 	:= oModel:GetModel('COXDETAIL')
Local cVar			:= oModelCOX:GetValue('COX_PROPRI')
Local lRet			:= .T.

If cVar == '1' .And. !IsInCallStack("A120IMPORT")
	lRet:=.F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A120VldGrd
TudoOk
@author Flavio T. Lopes
@since 10/09/2013
@version P11
@return lRet
/*/
//-------------------------------------------------------------------

Static Function A120VldGrd(oModelGrid, nLinha, cAcao, cCampo)
Local lRet			:= .T.
Local cProp		:= oModelGrid:GetValue('COX_PROPRI')

If cAcao == 'DELETE' .AND. cProp == '1'
	Help(' ', 1,'A120lOK',,STR0011 ,1,0)//"Por motivos legais, n�o � permitido alterar uma linha de propriedade da TOTVS"
	lRet:=.F.
Endif

Return lRet

Static Function A120VldT( oModelGrid, nLinha, cAcao, cCampo )
Local lRet 		:= .T.
Local oModel 		:= oModelGrid:GetModel()
Local oModelCOX	:= oModel:GetModel('COXDETAIL')
Local oModelCOV	:= oModel:GetModel('COVMASTER')
Local nOperation 	:= oModel:GetOperation()
Local nX			:= 0
Local _aArea		:= GetArea()

If nOperation == 3
	dbSelectArea('COV')
	While COV->(!EOF())
		If AllTrim(COV->COV_CODIGO) == AllTrim(oModelCOV:GetValue('COV_CODIGO'))
			Help(' ', 1,'A120lOK2',,STR0012 ,1,0)//"C�digo do Check-List j� existente na base de dados"
			lRet:=.F.
			Exit
		Endif
	COV->(DbSkip())
	EndDo
	restArea(_aArea)

ElseIf nOperation == 5
	For nX:=1 To oModelCOX:Length()
		oModelCOX:GoLine(nX)
		If oModelCOX:getValue('COX_PROPRI') == '1'
			lRet:=.F.
			Help(' ', 1,'A120lOK',,STR0013 ,1,0)//"Por motivos legais, n�o � permitido excluir um check-list com linhas de propriedade da TOTVS"
			Exit
		Endif
	Next
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A120Import
Rotina de importa��o do checkList -  GCPA120
@author Raphael F. Augustos
@since 30/09/2013
@version P11
@return lRet
/*/
//-------------------------------------------------------------------
Function A120Import()
Local oImport 	:= GCPXImport():New( "GCPA120", 3 , "COVMASTER", {"COXDETAIL"})
Local aField 	:= {}
Local aGrid 	:= {}
Local aGrid1	:={}
Local lRet 	:= .T.

dbSelectArea("COV")
COV->(dbSetOrder(1))
dbSelectArea("COX")
COX->(dbSetOrder(1))

If !COV->(DbSeek(xFilial('COV')+"ELA")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Elabora��o do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ELA"},{"COV_DESC",STR0014}} }//"Elabora��o do Edital"
	
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","001"},{"COX_DESC",STR0016},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0015},{"COX_ORDEM","001"},{"COX_DESCDE",STR0016}} )//"Lei n� 8.666/93, art. 38,caput."//STR0017//"Providenciar autoriza��o da autoridade competente para realiza��o da licita��o."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","002"},{"COX_DESC",STR0018},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0020},{"COX_ORDEM","002"},{"COX_DESCDE",STR0018}} )//STR0019//"Designar comiss�o de licita��o ou do respons�vel pelo convite."//"Lei n� 8.666/93, art. 38, III."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","003"},{"COX_DESC",STR0021},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0023},{"COX_ORDEM","003"},{"COX_DESCDE",STR0021}} )//STR0022//"Autuar, protocolar e numerar o processo administrativo."//"Lei n� 8.666/93, art. 38, caput."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","004"},{"COX_DESC",STR0025},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0026},{"COX_ORDEM","004"},{"COX_DESCDE",STR0024}} )//"Atentar-se o pre�mbulo do edital define o n�mero de ordem em s�rie anual, o nome da reparti��o interessada e de seu setor, a modalidade, o regime de execu��o e o tipo da licita��o, a men��o de que ser� regida pela Lei n� 8.666/93, o local, dia e hora para recebimento da documenta��o e proposta, bem como para in�cio da abertura dos envelopes."//"Atentar-se o pre�mbulo do edital"//"Lei n� 8.666/93, art. 40, caput."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","005"},{"COX_DESC",STR0027},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0029},{"COX_ORDEM","005"},{"COX_DESCDE",STR0027}} )//STR0028//"Indicar no instrumento convocat�rio os recursos para a despesa e comprovar a exist�ncia de recursos or�ament�rios que assegurem o pagamento da obriga��o."//"Lei n� 8.666/93, art. 38, caput."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","006"},{"COX_DESC",STR0030},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0032},{"COX_ORDEM","006"},{"COX_DESCDE",STR0030}} )//STR0031//"Anexar ao edital or�amento detalhado em planilhas com a composi��o dos custos unit�rios, inclusive com BDI estimado."//"Lei n� 8.666/93, art. 40, � 2�, II."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","007"},{"COX_DESC",STR0033},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0035},{"COX_ORDEM","007"},{"COX_DESCDE",STR0033}} )//STR0034//"Anexar ao edital os projetos, a minuta do contrato, as especifica��es t�cnicas complementares e as normas de execu��o pertinentes."//"Lei n� 8.666/93, art. 40, � 2�."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","008"},{"COX_DESC",STR0037},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0036},{"COX_ORDEM","008"},{"COX_DESCDE",STR0037}} )//"Lei n� 8.666/93, art. 23, �1�."//STR0038//"Observar se o objeto � dividido em parcelas, com vistas ao melhor aproveitamento dos recursos do mercado e � ampla competi��o, sem perda de economia de escala."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","009"},{"COX_DESC",STR0039},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0041},{"COX_ORDEM","009"},{"COX_DESCDE",STR0039}} )//STR0040//"Evidenciar no processo se o cronograma f�sico-financeiro do edital est� compat�vel com o do projeto b�sico."//"Lei n� 8.666/93, art. 7�, �2�. E 8 �."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","010"},{"COX_DESC",STR0042},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0044},{"COX_ORDEM","010"},{"COX_DESCDE",STR0042}} )//STR0043//"Incluir no edital previs�o do direito de prefer�ncia para a contrata��o das Microempresas e as Empresas de Pequeno Porte."//"Lei n� 8.666/93, art. 7�, �2�. E 8 �."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","011"},{"COX_DESC",STR0045},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0047},{"COX_ORDEM","011"},{"COX_DESCDE",STR0045}} )//STR0046//"Inserir no edital as condi��es de pagamento, o cronograma de desembolso, os crit�rios de atualiza��o financeira dos valores a serem pagos, as compensa��es financeiras, as penaliza��es e exig�ncia de seguros, quando for o caso."//"Lei n� 8.666/93, art. 40, XIV."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","012"},{"COX_DESC",STR0048},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0050},{"COX_ORDEM","012"},{"COX_DESCDE",STR0048}} )//STR0049//"Incluir no edital crit�rio de aceitabilidade de pre�os unit�rio e global m�ximo."//"Lei n� 8.666/93, art. 40, X."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","013"},{"COX_DESC",STR0051},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0053},{"COX_ORDEM","013"},{"COX_DESCDE",STR0051}} )//STR0052//"Datar, rubricar e assinar o instrumento convocat�rio pela autoridade que o expediu."//"Lei n� 8.666/93, art. 40, � 1�."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","014"},{"COX_DESC",STR0055},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0054},{"COX_ORDEM","014"},{"COX_DESCDE",STR0055}} )//"Lei n� 8.666/93, art. 21 e par�grafos."//STR0056//"Proceder � an�lise da publicidade dos atos, dentro dos prazos, bem como verificar se h� comprovantes desses."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","015"},{"COX_DESC",STR0059},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0057},{"COX_ORDEM","015"},{"COX_DESCDE",STR0058}} )//" Lei n� 8.666/93, art. 7�, � 2�, III."//" Observar se a previs�o de recursos or�ament�rios assegura o pagamento das etapas a serem realizadas no exerc�cio financeiro em curso."//"Observar se a previs�o de recursos or�ament�rios assegura o pagamento das etapas a serem realizadas no exerc�cio financeiro em curso."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","016"},{"COX_DESC",STR0060},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0062},{"COX_ORDEM","016"},{"COX_DESCDE",STR0060}} )//STR0061//"Caso o objeto envolva a presta��o de servi�os (inclusive obras), no pre�mbulo edital consta o regime de execu��o escolhido?(empreitada por pre�o unit�rio, por pre�o global, integral ou tarefa)"//"Lei n.� 8.666/93, art. 40, caput"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","017"},{"COX_DESC",STR0063},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0065},{"COX_ORDEM","017"},{"COX_DESCDE",STR0063}} )//STR0064//"Ato declarat�rio do Presidente da Rep�blica, mediante decreta��o de estado de s�tio;"//"C.F., art. 84, inciso XIX, e art. 137, inciso II"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","018"},{"COX_DESC",STR0066},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0068},{"COX_ORDEM","018"},{"COX_DESCDE",STR0066}} )//STR0067//"Autoriza��o pr�via ou referendo posterior do Congresso Nacional;"//"C.F., art. 49, inciso II"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","019"},{"COX_DESC",STR0070},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0069},{"COX_ORDEM","019"},{"COX_DESCDE",STR0070}} )//"Decreto Federal n� 5.376/2005, art. 17, � 1�"//STR0071//"Edi��o, pelo Governador do estado, de decreto de homologa��o de estado de calamidade p�blica;"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","020"},{"COX_DESC",STR0072},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0074},{"COX_ORDEM","020"},{"COX_DESCDE",STR0072}} )//STR0073//"Exist�ncia de documenta��o probat�ria da ocorr�ncia de situa��o emergencial que reclama solu��o imediata"//"Lei 8.666, Art. 24, inciso IV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","021"},{"COX_DESC",STR0075},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0077},{"COX_ORDEM","021"},{"COX_DESCDE",STR0075}} )//STR0076//"Justificativa formal que caracterize a situa��o emergencial ou calamitosa que evidencia a urg�ncia"//"Lei Federal n�. 8.666/93 Art. 26, par�grafo �nico, inciso I"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","022"},{"COX_DESC",STR0078},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0080},{"COX_ORDEM","022"},{"COX_DESCDE",STR0078}} )//STR0079//"Conclus�o da licita��o anterior sem �xito"//"Lei Federal n�. 8.666/93 Art. 24, par�grafo �nico, inciso V"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","023"},{"COX_DESC",STR0082},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0081},{"COX_ORDEM","023"},{"COX_DESCDE",STR0082}} )//"Lei Federal n�. 8.666/93 Art. 24, par�grafo �nico, inciso V"//STR0083//"Licita��o deserta - inexist�ncia de adjudica��o na licita��o anterior, devido � aus�ncia de interessados"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","024"},{"COX_DESC",STR0085},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0084},{"COX_ORDEM","024"},{"COX_DESCDE",STR0085}} )//"Lei Federal n�. 8.666/93 Art. 24, par�grafo �nico, inciso V"//STR0086//"Manuten��o das condi��es ofertadas no ato convocat�rio anterior."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","025"},{"COX_DESC",STR0087},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0089},{"COX_ORDEM","025"},{"COX_DESCDE",STR0087}} )//STR0088//"Justificativa formal com indica��o dos riscos de preju�zo, caracterizado ou demasiadamente aumentado pela demora decorrente de novo processo licitat�rio"//"Lei Federal n�. 8.666/93 Art. 26"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","026"},{"COX_DESC",STR0091},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0090},{"COX_ORDEM","026"},{"COX_DESCDE",STR0091}} )//"Lei Federal n� 8.666/1993, art. 24, inciso VII, art. 43, inciso IV;"//STR0092//"Licita��o anterior frustrada, por terem sido apresentados por todos os ofertantes pre�os manifestamente superiores aos de mercado ou incompat�veis"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","027"},{"COX_DESC",STR0094},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0093},{"COX_ORDEM","027"},{"COX_DESCDE",STR0094}} )//"Lei Federal n�. 8.666/1993, art. 48, � 3�."//STR0095//"Novas propostas apresentadas pelos mesmos licitantes no prazo de oito dias (ou tr�s dias, no caso de convite) contados da decis�o de desclassifica��o das propostas originais;"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","028"},{"COX_DESC",STR0096},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0098},{"COX_ORDEM","028"},{"COX_DESCDE",STR0096}} )//STR0097//"Decis�o de desclassifica��o das novas propostas por apresentarem pre�os manifestamente superiores aos de mercado ou incompat�veis com os pre�os fixados por �rg�os oficiais;"//"Lei Federal n� 8.666/1993, art. 43, inciso IV, e art. 48, inciso II."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","029"},{"COX_DESC",STR0100},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0099},{"COX_ORDEM","029"},{"COX_DESCDE",STR0100}} )//"Lei Federal n� 8.666/1993, art. 43, inciso IV."//STR0101//"Pre�o do bem ou servi�o contratado compat�vel com os praticados pelo mercado ou fixados por �rg�os oficiais constantes dos registros de pre�os ou de servi�os."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","030"},{"COX_DESC",STR0102},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0104},{"COX_ORDEM","030"},{"COX_DESCDE",STR0102}} )//STR0103//"Compras de hortifrutigranjeiros, p�o e outros g�neros perec�veis"//"Lei Federal n� 8.666/1993, art. 24, inciso XII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","031"},{"COX_DESC",STR0105},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0107},{"COX_ORDEM","031"},{"COX_DESCDE",STR0105}} )//STR0106//"Contrata��o de institui��o brasileira incumbida regimental ou estatutariamente da pesquisa"//"Lei Federal n� 8.666/1993, art. 24, inciso XIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","032"},{"COX_DESC",STR0108},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0110},{"COX_ORDEM","032"},{"COX_DESCDE",STR0108}} )//STR0109//"Contrata��o de institui��o brasileira do ensino ou do desenvolvimento institucional, ou de institui��o dedicada � recupera��o social do preso"//"Lei Federal n� 8.666/1993, art. 24, inciso XIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","033"},{"COX_DESC",STR0112},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0113},{"COX_ORDEM","033"},{"COX_DESCDE",STR0111}} )//"Aquisi��o de bens ou servi�os nos termos de acordo internacional espec�fico aprovado pelo Congresso Nacional, quando as condi��es ofertadas forem manifestamente vantajosas para o Poder P�blico "//"Aquisi��o de bens ou servi�os nos termos de acordo internacional espec�fico aprovado pelo Congresso Nacional, quando as condi��es ofertadas forem manifestamente vantajosas para o Poder P�blico"//"Lei Federal n� 8.666/1993, art. 24, inciso XIV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","034"},{"COX_DESC",STR0114},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0116},{"COX_ORDEM","034"},{"COX_DESCDE",STR0114}} )//STR0115//"Aquisi��o ou restaura��o de obras de arte e objetos hist�ricos, de autenticidade certificada, desde que compat�veis ou inerentes �s finalidades do �rg�o ou entidade."//"Lei Federal n� 8.666/1993, art. 24, inciso XV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","035"},{"COX_DESC",STR0117},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0119},{"COX_ORDEM","035"},{"COX_DESCDE",STR0118}} )//"Impress�o dos di�rios oficiais, de formul�rios padronizados de uso da administra��o, e de edi��es t�cnicas oficiais"//"Impress�o dos di�rios oficiais, de formul�rios padronizados de uso da administra��o, e de edi��es t�cnicas oficiais, bem como para presta��o de servi�os de inform�tica a pessoa jur�dica de direito p�blico interno, por �rg�os ou entidades que integrem a Administra��o P�blica, criados para esse fim espec�fico;"//"Lei Federal n� 8.666/1993, art. 24, inciso XVI"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","036"},{"COX_DESC",STR0120},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0122},{"COX_ORDEM","036"},{"COX_DESCDE",STR0120}} )//STR0121//"Aquisi��o de componentes ou pe�as de origem nacional ou estrangeira, necess�rios � manuten��o de equipamentos durante o per�odo de garantia t�cnica,"//"Lei Federal n� 8.666/1993, art. 24, inciso XVII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","037"},{"COX_DESC",STR0123},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0125},{"COX_ORDEM","037"},{"COX_DESCDE",STR0123}} )//STR0124//"Compras ou contrata��es de servi�os para o abastecimento de navios, embarca��es, unidades a�reas ou tropas e seus meios de deslocamento quando em estada eventual de curta dura��o em portos, aeroportos ou localidades diferentes de suas sedes"//"Lei Federal n� 8.666/1993, art. 24, inciso XVIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","038"},{"COX_DESC",STR0126},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0128},{"COX_ORDEM","038"},{"COX_DESCDE",STR0126}} )//STR0127//"Compras de material de uso pelas For�as Armadas mediante parecer de comiss�o institu�da por decreto;"//"Lei Federal n� 8.666/1993, art. 24, inciso XIX"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","039"},{"COX_DESC",STR0130},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0131},{"COX_ORDEM","039"},{"COX_DESCDE",STR0129}} )//"Contrata��o de associa��o de portadores de defici�ncia f�sica, sem fins lucrativos e de comprovada idoneidade "//"Contrata��o de associa��o de portadores de defici�ncia f�sica, sem fins lucrativos e de comprovada idoneidade"//"Lei Federal n� 8.666/1993, art. 24, inciso XX"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","040"},{"COX_DESC",STR0132},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0134},{"COX_ORDEM","040"},{"COX_DESCDE",STR0132}} )//STR0133//"Aquisi��o de bens e insumos destinados exclusivamente � pesquisa cient�fica e tecnol�gica com recursos concedidos pela Capes, pela Finep, pelo CNPq ou por outras institui��es de fomento a pesquisa credenciadas pelo CNPq para esse fim espec�fico"//"Lei Federal n� 8.666/1993, art. 24, inciso XXI"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","041"},{"COX_DESC",STR0135},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0137},{"COX_ORDEM","041"},{"COX_DESCDE",STR0135}} )//STR0136//"Contrata��o de fornecimento ou suprimento de energia el�trica e g�s natural com concession�rio, permission�rio ou autorizado, segundo as normas da legisla��o espec�fica;"//"Lei Federal n� 8.666/1993, art. 24, inciso XXII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","042"},{"COX_DESC",STR0138},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0140},{"COX_ORDEM","042"},{"COX_DESCDE",STR0138}} )//STR0139//"Contrata��o realizada por empresa p�blica ou sociedade de economia mista com suas subsidi�rias e controladas, para a aquisi��o ou aliena��o de bens, presta��o ou obten��o de servi�os"//"Lei Federal n� 8.666/1993, art. 24, inciso XXIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","043"},{"COX_DESC",STR0141},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0143},{"COX_ORDEM","043"},{"COX_DESCDE",STR0141}} )//STR0142//"Celebra��o de contratos de presta��o de servi�os com as organiza��es sociais, qualificadas no �mbito das respectivas esferas de governo, para atividades contempladas no contrato de gest�o"//"Lei Federal n� 8.666/1993, art. 24, inciso XXIV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","044"},{"COX_DESC",STR0144},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0146},{"COX_ORDEM","044"},{"COX_DESCDE",STR0144}} )//STR0145//"Contrata��o realizada por Institui��o Cient�fica e Tecnol�gica - ICT ou por ag�ncia de fomento para a transfer�ncia de tecnologia e para o licenciamento de direito de uso ou de explora��o de cria��o protegida."//"Lei Federal n� 8.666/1993, art. 24, inciso XXV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","045"},{"COX_DESC",STR0147},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0149},{"COX_ORDEM","045"},{"COX_DESCDE",STR0147}} )//STR0148//"Celebra��o de contrato de programa com ente da Federa��o ou com entidade de sua administra��o indireta, para a presta��o de servi�os p�blicos de forma associada ou em conv�nio de coopera��o."//"Lei Federal n� 8.666/1993, art. 24, inciso XXVI"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","046"},{"COX_DESC",STR0150},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0152},{"COX_ORDEM","046"},{"COX_DESCDE",STR0150}} )//STR0151//"Contrata��o da coleta, processamento e comercializa��o de res�duos s�lidos urbanos recicl�veis ou reutiliz�veis, em �reas com sistema de coleta seletiva de lixo"//"Lei Federal n� 8.666/1993, art. 24, inciso XXVII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","047"},{"COX_DESC",STR0153},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0155},{"COX_ORDEM","047"},{"COX_DESCDE",STR0153}} )//STR0154//"Fornecimento de bens e servi�os, produzidos ou prestados no Pa�s, que envolvam, cumulativamente, alta complexidade tecnol�gica e defesa nacional, mediante parecer de comiss�o especialmente designada pela autoridade m�xima do �rg�o."//"Lei Federal n� 8.666/1993, art. 24, inciso XXVIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","048"},{"COX_DESC",STR0157},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0158},{"COX_ORDEM","048"},{"COX_DESCDE",STR0156}} )//"Aquisi��o de bens e contrata��o de servi�os para atender aos contingentes militares das For�as Singulares brasileiras empregadas em opera��es de paz no exterior, necessariamente justificadas quanto ao pre�o e � escolha do fornecedor ou executante e ratificadas pelo Comandante da For�a."//"Aquisi��o de bens e contrata��o de servi�os para atender aos contingentes militares"//"Lei Federal n� 8.666/1993, art. 24, inciso XXIX"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","049"},{"COX_DESC",STR0159},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0161},{"COX_ORDEM","049"},{"COX_DESCDE",STR0159}} )//STR0160//"Contrata��o de institui��o ou organiza��o para a presta��o de servi�os de assist�ncia t�cnica e extens�o rural no �mbito do Programa Nacional de Assist�ncia T�cnica e Extens�o Rural na Agricultura Familiar e na Reforma Agr�ria"//"Lei Federal n� 8.666/1993, art. 24, inciso XXX"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","050"},{"COX_DESC",STR0162},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0164},{"COX_ORDEM","050"},{"COX_DESCDE",STR0162}} )//STR0163//"Contrata��es visando ao cumprimento do disposto nos arts. 3�, 4�, 5��e 20� da Lei no�10.973, de 2 de dezembro de 2004, observados os princ�pios gerais de contrata��o dela constantes."//"Lei Federal n� 8.666/1993, art. 24, inciso XXXI"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","051"},{"COX_DESC",STR0165},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0167},{"COX_ORDEM","051"},{"COX_DESCDE",STR0165}} )//STR0166//"Contrata��o em que houver transfer�ncia de tecnologia de produtos estrat�gicos para o Sistema �nico de Sa�de - SUS"//"Lei Federal n� 8.666/1993, art. 24, inciso XXXII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","052"},{"COX_DESC",STR0168},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0170},{"COX_ORDEM","052"},{"COX_DESCDE",STR0168}} )//STR0169//"Contrata��o de entidades privadas sem fins lucrativos, para a implementa��o de cisternas ou outras tecnologias sociais de acesso � �gua para consumo humano e produ��o de alimentos"//"Lei Federal n� 8.666/1993, art. 24, inciso XXXIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","053"},{"COX_DESC",STR0171},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0173},{"COX_ORDEM","053"},{"COX_DESCDE",STR0171}} )//STR0172//"Aquisi��o de materiais, equipamentos, ou g�neros que s� possam ser fornecidos por produtor, empresa ou representante comercial exclusivo"//"Lei Federal n� 8.666/1993, art. 25, inciso I"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","054"},{"COX_DESC",STR0174},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0176},{"COX_ORDEM","054"},{"COX_DESCDE",STR0174}} )//STR0175//"Contrata��o de servi�os t�cnicos de natureza singular, com profissionais ou empresas de not�ria especializa��o, vedada a inexigibilidade para servi�os de publicidade e divulga��o"//"Lei Federal n� 8.666/1993, art. 25, inciso II"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","055"},{"COX_DESC",STR0177},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0179},{"COX_ORDEM","055"},{"COX_DESCDE",STR0177}} )//STR0178//"Contrata��o de profissional de qualquer setor art�stico, diretamente ou atrav�s de empres�rio exclusivo, desde que consagrado pela cr�tica especializada ou pela opini�o p�blica"//"Lei Federal n� 8.666/1993, art. 25, inciso III"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"DIS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Etapa Dispensa e Inegibilidade
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","DIS"},{"COV_DESC",STR0553}} }
	aGrid := {	{;
		{{"COX_CODIGO","DIS"},{"COX_ITEM","001"},{"COX_DESC",STR0547},{"COX_PROPI","1"},{"COX_COND",""},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0197},{"COX_ORDEM","001"},{"COX_DESCDE","    "}};
		}}	
	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
	 
	//----------------------------------------------- 
	// Check Lists para An�lise do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ANA"},{"COV_DESC",STR0180}} }//"An�lise do Edital"
	
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","001"},{"COX_DESC",STR0182},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0181},{"COX_ORDEM","001"},{"COX_DESCDE",STR0182}} )//"Lei n� 8.666/93, art. 22 e seus par�grafos e art. 23 e seus par�grafos."//STR0183//"Observar se est�o sendo adotados modalidades e regime de execu��o apropriado."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","002"},{"COX_DESC",STR0185},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0184},{"COX_ORDEM","002"},{"COX_DESCDE",STR0185}} )//"Lei n� 8.666/93, art. 40, I."//STR0186//"Verificar se h� caracteriza��o adequada do objeto licitado."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","003"},{"COX_DESC",STR0188},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0187},{"COX_ORDEM","003"},{"COX_DESCDE",STR0188}} )//"Lei n� 8.666/93, art. 23, � 5�."//STR0189//"N�o fracionar despesas para alterar a modalidade de licita��o."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","004"},{"COX_DESC",STR0191},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0190},{"COX_ORDEM","004"},{"COX_DESCDE",STR0192}} )//"Lei n� 8.666/93, art. 33."//"Verificar se � pertinente o uso do instituto do cons�rcio de empresas. "//"Verificar se � pertinente o uso do instituto do cons�rcio de empresas."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","005"},{"COX_DESC",STR0193},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0195},{"COX_ORDEM","005"},{"COX_DESCDE",STR0193}} )//STR0194//"Atentar-se h� no edital aplica��o de reajustamento com �ndices setoriais."//"Lei n� 8.666/93, art. 40, XI."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","006"},{"COX_DESC",STR0197},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0196},{"COX_ORDEM","006"},{"COX_DESCDE",STR0197}} )//"Lei n� 8.666/93, art. 38, VI, par�grafo �nico."//STR0198//"Verificar se o edital e a minuta do contrato est�o aprovados previamente por parecer jur�dico."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","007"},{"COX_DESC",STR0199},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0201},{"COX_ORDEM","007"},{"COX_DESCDE",STR0199}} )//STR0200//"A licita��o foi formalizada por meio de processo administrativo, devidamente autuado, protocolado e numerado?"//"Lei n.� 8.666/93, art. 38, caput"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"PUB")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Publica��o do Edital
	//-----------------------------------------------
	
	aField := { {{"COV_CODIGO","PUB"},{"COV_DESC",STR0202}} }//"Publica��o do Edital"
	
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","001"},{"COX_DESC",STR0204},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0203},{"COX_ORDEM","001"},{"COX_DESCDE","    "}})//"Art. 38 - II"//"Foi informado o comprovante das publica��es do edital resumido, na forma do art. 21 desta Lei, ou da entrega do convite ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","002"},{"COX_DESC",STR0206},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0205},{"COX_ORDEM","002"},{"COX_DESCDE"," "}})//"Art. 38 - III"//"Foi informado o ato de designa��o da comiss�o de licita��o, do leiloeiro administrativo ou oficial, ou do respons�vel pelo  convite ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","003"},{"COX_DESC",STR0208},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0207},{"COX_ORDEM","003"},{"COX_DESCDE"," "}})//"Art. 40"//"Foi informado o local, dia e hora para recebimento da documenta��o e proposta, bem como para in�cio da abertura dos envelopes ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","004"},{"COX_DESC",STR0210},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0209},{"COX_ORDEM","004"},{"COX_DESCDE"," "}})//"Art. 40 - IV"//"Foi informado o local onde poder� ser examinado e adquirido o projeto b�sico ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","005"},{"COX_DESC",STR0212},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0211},{"COX_ORDEM","005"},{"COX_DESCDE"," "}})//"Art. 40 - V"//"Foi informado se h� projeto executivo dispon�vel na data da publica��o do edital de licita��o e o local onde possa ser examinado e adquirido ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","006"},{"COX_DESC",STR0214},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0213},{"COX_ORDEM","006"},{"COX_DESCDE"," "}})//"Art. 40 - VII"//"Foi informado o crit�rio para julgamento, com disposi��es claras e par�metros objetivos ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","007"},{"COX_DESC",STR0217},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0216},{"COX_ORDEM","007"},{"COX_DESCDE",STR0215}})//"Art. 40 - XI - crit�rio de reajuste, que dever� retratar a varia��o efetiva do custo de produ��o, admitida a ado��o de �ndices espec�ficos ou setoriais, desde a data prevista para apresenta��o da proposta, ou do or�amento a que essa proposta se referir, at� a data do adimplemento de cada parcela;"//"Art. 40 - XI"//"Foi informado o crit�rio de reajuste ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","008"},{"COX_DESC",STR0220},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0219},{"COX_ORDEM","008"},{"COX_DESCDE",STR0218+ CRLF +STR0221 + CRLF + STR0222 + CRLF + STR0223 + CRLF + STR0224 + CRLF + STR0225}})//"Art. 40 - XIV - condi��es de pagamento, prevendo:"//"Art. 40 - XIV"//"Foi informado condi��es de pagamento ?"//"a) prazo de pagamento n�o superior a trinta dias, contado a partir da data final do per�odo de adimplemento de cada parcela;"//"b) cronograma de desembolso m�ximo por per�odo, em conformidade com a disponibilidade de recursos financeiros;"//"c) crit�rio de atualiza��o financeira dos valores a serem pagos, desde a data final do per�odo de adimplemento de cada parcela at� a data do efetivo pagamento;"//"d) compensa��es financeiras e penaliza��es, por eventuais atrasos, e descontos, por eventuais antecipa��es de pagamentos;"//"e) exig�ncia de seguros, quando for o caso;"
	
	AADD(aGrid,aGrid1)
		
	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"HAB")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Habilita��o
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","HAB"},{"COV_DESC",STR0226}} }//"Habilita��o"
	
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","001"},{"COX_DESC",STR0229},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0227},{"COX_ORDEM","001"},{"COX_DESCDE",STR0228}} )//"Lei n� 8.666/93, art. 3�, caput, e arts. 27 a 31."//"N�o incluir no edital cl�usula restritiva � ampla competi��o e incompat�vel com a obra que se pretende contratar.    "//"N�o incluir no edital cl�usula restritiva � ampla competi��o e incompat�vel com a obra que se pretende contratar."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","002"},{"COX_DESC",STR0231},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0232},{"COX_ORDEM","002"},{"COX_DESCDE",STR0230}} )//"Exigir no edital as comprova��es das proponentes de qualifica��o jur�dica, t�cnica, econ�mico-financeira, regularidade fiscal e cumprimento do disposto no inciso XXXIII do art. 7� da Constitui��o Federal. Constitui��o Federal, art. 7�, XXXIII e art. 37, XXI.    "//"Exigir no edital as comprova��es das proponentes de qualifica��o jur�dica, t�cnica, econ�mico-financeira, regularidade fiscal"//"Lei n� 8.666/93, art. 3�, caput, e arts. 27 a 31."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","003"},{"COX_DESC",STR0234},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0233},{"COX_ORDEM","003"},{"COX_DESCDE",STR0234}} )//"Lei n� 8.666/93, art. 9�."//STR0235//"Na fase de habilita��o, observar se a proponente teve algum tipo de participa��o na elabora��o dos projetos ou � servidor p�blico do �rg�o contratante ou respons�vel pela licita��o."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","004"},{"COX_DESC",STR0237},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0236},{"COX_ORDEM","004"},{"COX_DESCDE",STR0237}} )//"Lei n� 8.666/93, art. 43, I, e � 2�."//STR0238//"Na fase de habilita��o, observar se constam as rubricas de participantes nos envelopes de habilita��o e de proposta de pre�o."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","005"},{"COX_DESC",STR0240},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0239},{"COX_ORDEM","005"},{"COX_DESCDE",STR0240}} )//"Lei n� 8.666/93, art. 109."//STR0241//"Respeitar os prazos recursais."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","006"},{"COX_DESC",STR0243},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0242},{"COX_ORDEM","006"},{"COX_DESCDE",STR0243}} )//"Lei n� 8.666/93, art. 38, V e arts. 43, � 1�."//STR0244//"Providenciar, nos seus devidos tempos, as atas das fases de julgamento da habilita��o e das propostas de pre�os."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","007"},{"COX_DESC",STR0245},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0247},{"COX_ORDEM","007"},{"COX_DESCDE",STR0245}} )//STR0246//"Foi solicitado o documento de identidade, no caso de pessoa f�sica?"//"Lei n.� 8.666/93, art. 28, I"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","008"},{"COX_DESC",STR0248},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0250},{"COX_ORDEM","008"},{"COX_DESCDE",STR0248}} )//STR0249//"Foi solicitado o registro comercial, no caso de empresa individual?"//"Lei n.� 8.666/93, art. 28, II"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","009"},{"COX_DESC",STR0251},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0253},{"COX_ORDEM","009"},{"COX_DESCDE",STR0251}} )//STR0252//"Foi solicitado o ato constitutivo, estatuto ou contrato social em vigor, devidamente registrado, em se tratando de sociedades comerciais, e, no caso de sociedades por a��es, acompanhado de documentos de elei��o de seus administradores?"//"Lei n.� 8.666/93, art. 28, III"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","010"},{"COX_DESC",STR0254},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0256},{"COX_ORDEM","010"},{"COX_DESCDE",STR0254}} )//STR0255//"Foi solicitada a inscri��o do ato constitutivo, no caso de sociedades civis, acompanhada de prova de diretoria em exerc�cio?"//"Lei n.� 8.666/93, art. 28, IV"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","011"},{"COX_DESC",STR0257},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0259},{"COX_ORDEM","011"},{"COX_DESCDE",STR0257}} )//STR0258//"Foi solicitado o decreto de autoriza��o, em se tratando de empresa ou sociedade estrangeira em funcionamento no Pa�s, e ato de registro ou autoriza��o para funcionamento expedido pelo �rg�o competente, quando a atividade assim o exigir?"//"Lei n.� 8.666/93, art. 28, V"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","012"},{"COX_DESC",STR0260},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0262},{"COX_ORDEM","012"},{"COX_DESCDE",STR0260}} )//STR0261//"Foi solicitada a prova de inscri��o no Cadastro de Pessoas F�sicas (CPF) ou no Cadastro Nacional de Pessoas Jur�dicas (CNPJ)?"//"Lei n.� 8.666/93, art. 29, I"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","013"},{"COX_DESC",STR0263},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0265},{"COX_ORDEM","013"},{"COX_DESCDE",STR0263}} )//STR0264//"Foi solicitada prova de inscri��o no cadastro de contribuintes estadual ou municipal , se houver, relativo ao domic�lio ou sede do licitante, pertinente ao seu ramo de atividade e compat�vel com o objeto contratual?"//"Lei n.� 8.666/93, art. 29, II"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","014"},{"COX_DESC",STR0267},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0268},{"COX_ORDEM","014"},{"COX_DESCDE",STR0266}} )//"Foi solicitada, conforme o caso, prova de regularidade para com a Fazenda Federal (Certid�es Negativas � D�vida Ativa/PFN e Tributos Administrados pela Receita Federal), Estadual e Municipal do domic�lio ou sede do licitante, ou outra equivalente, na forma da lei?"//"Foi solicitada, conforme o caso, prova de regularidade para com a Fazenda Federal (Certid�es Negativas � D�vida Ativa/PFN e Tributos Administrados pela Receita Federal), Estadual e Municipal do domic�lio ou sede do licitante..."//"Lei n.� 8.666/93, art. 29, III"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","015"},{"COX_DESC",STR0269},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0271},{"COX_ORDEM","015"},{"COX_DESCDE",STR0269}} )//STR0270//"Foi solicitada prova de regularidade relativa � Seguridade Social (INSS)"//"Lei n.� 8.666/93, art. 29, IV e CF, art. 195, � 2.�"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","016"},{"COX_DESC",STR0272},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0274},{"COX_ORDEM","016"},{"COX_DESCDE",STR0272}} )//STR0273//"Foi solicitada prova de regularidade relativa ao Fundo de Garantia por Tempo de Servi�o (FGTS)"//"Lei n.� 8.666/93, art. 29, IV"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","017"},{"COX_DESC",STR0276},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0275},{"COX_ORDEM","017"},{"COX_DESCDE",STR0276}} )//"Lei n.� 8.666/93, art. 30, I, II, III e IV"//STR0277//"registro ou inscri��o na entidade profissional competente"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","018"},{"COX_DESC",STR0280},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0278},{"COX_ORDEM","018"},{"COX_DESCDE",STR0279}} )//"Lei n.� 8.666/93, art. 30, I, II, III e IV"//"comprova��o de aptid�o para desempenho de atividade pertinente e compat�vel em caracter�sticas, quantidades e prazos com o objeto da licita��o, e indica��o das instala��es e do aparelhamento e do pessoal t�cnico adequados e dispon�veis para a realiza��o do objeto da licita��o, bem como da qualifica��o de cada um dos membros da equipe t�cnica que se responsabilizar� pelos trabalhos"//"comprova��o de aptid�o para desempenho de atividade pertinente e compat�vel em caracter�sticas, quantidades e prazos com o objeto da licita��o..."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","019"},{"COX_DESC",STR0283},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0281},{"COX_ORDEM","019"},{"COX_DESCDE",STR0282}} )//"Lei n.� 8.666/93, art. 30, I, II, III e IV"//"comprova��o, fornecida pelo �rg�o licitante, de que recebeu os documentos, e, quando exigido, de que tomou conhecimento de todas as informa��es e das condi��es locais para o cumprimento das obriga��es objeto da licita��o"//"comprova��o, fornecida pelo �rg�o licitante, de que recebeu os documentos, e, quando exigido, de que tomou conhecimento de todas as informa��es..."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","020"},{"COX_DESC",STR0285},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0284},{"COX_ORDEM","020"},{"COX_DESCDE",STR0285}} )//"Lei n.� 8.666/93, art. 30, I, II, III e IV"//STR0286//"prova de atendimento de requisitos previstos em lei especial, quando for o caso"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","021"},{"COX_DESC",STR0288},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0287},{"COX_ORDEM","021"},{"COX_DESCDE",STR0288}} )//"Lei n.� 8.666/93, art. 30, � 1.�, I"//STR0289//"N�o houve a fixa��o de quantidades m�nimas e prazos m�ximos para a capacita��o t�cnico-profissional?"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","022"},{"COX_DESC",STR0291},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0290},{"COX_ORDEM","022"},{"COX_DESCDE",STR0291}} )//"Lei n.� 8.666/93, art. 30, � 1.�, I"//STR0292//"N�o houve a exig�ncia de itens irrelevantes e sem valor significativo em rela��o ao objeto em licita��o para efeito de capacita��o t�cnico-profissional?"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","023"},{"COX_DESC",STR0294},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0293},{"COX_ORDEM","023"},{"COX_DESCDE",STR0294}} )//"Lei n.� 8.666/93, art. 30, � 5.�"//STR0295//"N�o houve a exig�ncia de comprova��o de atividade ou de aptid�o com limita��es de tempo ou de �poca ou ainda em locais espec�ficos, ou quaisquer outras n�o previstas na legisla��o, que inibam a participa��o na licita��o."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","024"},{"COX_DESC",STR0298},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0296},{"COX_ORDEM","024"},{"COX_DESCDE",STR0297}} )//"Lei n.� 8.666/93, art. 31, I, II e III, combinado com os �� 2.�, 3.�, 4.� e 5.� do mesmo artigo"//"balan�o patrimonial e demonstra��es cont�beis do �ltimo exerc�cio social, j� exig�veis e apresentados na forma da lei, que comprovem a boa situa��o financeira da empresa, vedada a sua substitui��o por balancetes ou balan�os provis�rios, podendo ser atualizados por �ndices oficiais quando encerrado h� mais de 3 meses da data de apresenta��o da proposta"//"balan�o patrimonial e demonstra��es cont�beis do �ltimo exerc�cio social, j� exig�veis e apresentados na forma da lei, que comprovem a boa situa��o financeira da empresa, vedada a sua substitui��o por balancetes ou balan�os provis�rios..."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","025"},{"COX_DESC",STR0300},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0299},{"COX_ORDEM","025"},{"COX_DESCDE",STR0300}} )//"Lei n.� 8.666/93, art. 31, I, II e III, combinado com os �� 2.�, 3.�, 4.� e 5.� do mesmo artigo"//STR0301//"certid�o negativa de fal�ncia ou concordata expedida pelo distribuidor da sede da pessoa jur�dica, ou de execu��o patrimonial, expedida no domic�lio da pessoa f�sica"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","026"},{"COX_DESC",STR0303},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0302},{"COX_ORDEM","026"},{"COX_DESCDE",STR0303}} )//"Lei n.� 8.666/93, art. 31, I, II e III, combinado com os �� 2.�, 3.�, 4.� e 5.� do mesmo artigo"//STR0304//"garantia limitada a 1% (um por cento) do valor estimado do objeto da contrata��o ou capital m�nimo/valor do patrim�nio l�quido inferior a 10% (dez por cento) do valor estimado da contrata��o."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","027"},{"COX_DESC",STR0306},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0305},{"COX_ORDEM","027"},{"COX_DESCDE",STR0306}} )//"Lei n.� 8.666/93, art. 31, I, II e III, combinado com os �� 2.�, 3.�, 4.� e 5.� do mesmo artigo"//STR0307//"rela��o dos compromissos assumidos pelo licitante que importem diminui��o da capacidade operativa ou absor��o de disponibilidade financeira, calculada esta em fun��o do patrim�nio l�quido atualizado e sua capacidade de rota��o"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","028"},{"COX_DESC",STR0309},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0308},{"COX_ORDEM","028"},{"COX_DESCDE",STR0309}} )//"Lei n.� 8.666/93, art. 31, I, II e III, combinado com os �� 2.�, 3.�, 4.� e 5.� do mesmo artigo"//STR0310//"�ndices cont�beis que comprovem a boa situa��o financeira do licitante."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","029"},{"COX_DESC",STR0312},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0311},{"COX_ORDEM","029"},{"COX_DESCDE",STR0312}} )//"Lei n.� 8.666/93, art. 31, � 2.�"//STR0313//"N�o houve a exig�ncia cumulativa de garantia de proposta com valor de capital m�nimo/patrim�nio l�quido (item c anterior)?"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","030"},{"COX_DESC",STR0315},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0314},{"COX_ORDEM","030"},{"COX_DESCDE",STR0315}} )//"Lei n.� 8.666/93, art. 31, � 5.�"//STR0316//"Os �ndices cont�beis e seus valores, se exigidos, s�o os usualmente adotados para correta avalia��o de situa��o financeira suficiente ao cumprimento das obriga��es decorrentes da licita��o?"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"JUL")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Julgamento da Proposta
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","JUL"},{"COV_DESC",STR0317}} }//"Julgamento"
	
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","001"},{"COX_DESC",STR0318},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0320},{"COX_ORDEM","001"},{"COX_DESCDE",STR0318}} )//STR0319//"Exigir no edital a apresenta��o da composi��o detalhada do BDI praticado pelos proponentes."//"Lei n� 8.666/93, art. 44, caput e �3�."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","002"},{"COX_DESC",STR0321},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0323},{"COX_ORDEM","002"},{"COX_DESCDE",STR0321}} )//STR0322//"Exigir a composi��o anal�tica dos pre�os unit�rios."//"Lei n� 8.666/93, art. 44, caput e �3�."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","003"},{"COX_DESC",STR0324},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0326},{"COX_ORDEM","003"},{"COX_DESCDE",STR0324}} )//STR0325//"Comprovar se a forma de participa��o e apresenta��o das propostas, bem como os crit�rios de julgamento est�o previstos objetivamente no instrumento convocat�rio."//"Lei n� 8.666/93, art. 3�, art. 40, VI e VII, e art. 44."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","004"},{"COX_DESC",STR0328},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0327},{"COX_ORDEM","004"},{"COX_DESCDE",STR0328}} )//"Lei n� 8.666/93, art. 44 e art. 45, caput."//STR0329//"No ato de recebimento das propostas, atentar-se h� compatibilidade entre as propostas de pre�os das licitantes e o or�amento b�sico."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","005"},{"COX_DESC",STR0331},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0330},{"COX_ORDEM","005"},{"COX_DESCDE",STR0331}} )//"Lei n� 8.666/93, art. 43, IV e art. 45, caput."//STR0332//"Verificar se h� compatibilidade das propostas com as regras previstas no edital."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","006"},{"COX_DESC",STR0334},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0333},{"COX_ORDEM","006"},{"COX_DESCDE",STR0334}} )//"Lei n� 8.666/93, art. 44 � 3� e art. 48 II."//STR0335//"Verificar se h� compatibilidade entre os custos or�ados pelo �rg�o e licitantes com os praticados no mercado."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","007"},{"COX_DESC",STR0337},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0336},{"COX_ORDEM","007"},{"COX_DESCDE",STR0337}} )//"Lei n� 8.666/93, art. 44, � 3� e art. 48, II."//STR0338//"Verificar se h� pre�os inexequ�veis."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","008"},{"COX_DESC",STR0340},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0339},{"COX_ORDEM","008"},{"COX_DESCDE",STR0340}} )//"Lei n� 5.194/66, art. 13 e art. 14."//STR0341//"Verificar se as propostas apresentadas est�o assinadas por profissional legalmente habilitado e identificado."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","009"},{"COX_DESC",STR0343},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0342},{"COX_ORDEM","009"},{"COX_DESCDE",STR0343}} )//"Lei n� 8.666/93, art. 109."//STR0344//"Respeitar os prazos recursais."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","010"},{"COX_DESC",STR0346},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0345},{"COX_ORDEM","010"},{"COX_DESCDE",STR0346}} )//"Lei n� 8.666/93, art. 38, V e arts. 43, � 1�."//STR0347//"Providenciar, nos seus devidos tempos, as atas das fases de julgamento da habilita��o e das propostas de pre�os."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","011"},{"COX_DESC",STR0349},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0348},{"COX_ORDEM","011"},{"COX_DESCDE",STR0349}} )//"Lei n� 8.666/93, art. 38, IV."//STR0350//"Verificar se est�o sendo juntados os originais das propostas e dos documentos no processo."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","012"},{"COX_DESC",STR0352},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0351},{"COX_ORDEM","012"},{"COX_DESCDE",STR0352}} )//"Lei n� 8.666/93, art. 38, IX."//STR0353//"Se for o caso, atentar-se h� decis�o de anula��o ou revoga��o devidamente fundamentada."
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"HOM")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Homologa��o
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","HOM"},{"COV_DESC",STR0354}} }//"Homologa��o"
	
	AADD(aGrid1, {{"COX_CODIGO","HOM"},{"COX_ITEM","001"},{"COX_DESC",STR0356},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0355},{"COX_ORDEM","001"},{"COX_DESCDE",STR0356}} )//" Lei n� 8.666/03, art. 38, VII."//STR0357//"Providenciar ato de homologa��o e adjudica��o do objeto da licita��o."
	AADD(aGrid1, {{"COX_CODIGO","HOM"},{"COX_ITEM","002"},{"COX_DESC",STR0359 },{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0358},{"COX_ORDEM","002"},{"COX_DESCDE",STR0359}} )//" Lei n� 8.666/93, art. 38, IX."//STR0360//"Se for o caso, atentar-se h� decis�o de anula��o ou revoga��o devidamente fundamentada."
	
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"ADJ")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Adjudica��o
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ADJ"},{"COV_DESC",STR0361}} }//"Adjudica��o"
	
	
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","001"},{"COX_DESC",STR0363},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0362},{"COX_ORDEM","001"},{"COX_DESCDE","    "}})//"Art. 55"//"O contrato contempla todas as cl�usulas necess�rias previstas no art. 55 da Lei Federal n� 8.666, de 1993?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","002"},{"COX_DESC",STR0365},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0364},{"COX_ORDEM","002"},{"COX_DESCDE",STR0366}})//"Art. 55, inciso I"//"O objeto do contrato apresenta elementos caracter�sticos de forma clara e est� de acordo com o processo que deu origem ao contrato?"//"Para a contrata��o de obras e servi�os pela administra��o p�blica estadual que envolva a aquisi��o direta e o emprego de produtos e subprodutos de madeira de origem nativa, dever�o ser observados os dispostos no Decreto n� 44.903, de 24 de setembro de 2008. H� determinados contratos nos quais o objeto estar� detalhado no anexo do contrato."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","003"},{"COX_DESC",STR0368},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0367},{"COX_ORDEM","003"},{"COX_DESCDE","    "}})//"Art. 55, inciso II"//"O regime de execu��o ou a forma de fornecimento cont�m elementos suficientes para a execu��o do contrato no prazo estabelecido?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","004"},{"COX_DESC",STR0371},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0369},{"COX_ORDEM","004"},{"COX_DESCDE",STR0370}})//"Art. 55, inciso III"//"As cl�usulas econ�mico-financeiras e monet�rias dos contratos administrativos n�o poder�o ser alteradas sem pr�via concord�ncia do contratado, conforme disposto no art. 58, � 1� da Lei Federal n� 8.666/1993. Alguns contratos expressam o valor total estimado em outra cl�usula e na do pre�o apenas o valor mensal (estimado ou n�o). Em outros, remetem aos anexos que pormenorizam c�lculos mais complexos para demonstra��o da composi��o do pre�o do material ou servi�o contratado."//"O pre�o est� compat�vel com o valor estimado informado no processo que deu origem ao contrato?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","005"},{"COX_DESC",STR0373},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0372},{"COX_ORDEM","005"},{"COX_DESCDE",STR0374}})//"Art. 55, inciso III"//"As condi��es de pagamento estabelecem os requisitos necess�rios para o pagamento ao contratado?"//"S�o exemplos de requisitos necess�rios: a apresenta��o de documento fiscal do fornecimento de material ou execu��o de servi�o, conferido e atestado pela Administra��o; apresenta��o de termo de medi��o no caso de acompanhamento de realiza��o de obras; planilhas; recibo de aluguel: planilhas pormenorizadas de custos; demonstra��es de cumprimento das obriga��es com encargos sociais e trabalhistas com as devidas reten��es tribut�rias dentre outras pertinentes ao tipo de contrato."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","006"},{"COX_DESC",STR0377},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0375},{"COX_ORDEM","006"},{"COX_DESCDE",STR0376}})//"Art. 55, inciso III"//"Est� cl�usula tamb�m pode ser denominada de cl�usula de revis�o ou repactua��o e poder� prever as hip�teses contempladas no art. 65, inciso II, letra �d�, da Lei n� 8.666/93 e demais condi��es estabelecidas."//"Os crit�rios, a data-base e a periodicidade do reajustamento de pre�os s�o compat�veis com os padr�es de mercado?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","007"},{"COX_DESC",STR0378},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0379},{"COX_ORDEM","007"},{"COX_DESCDE","    "}})//"A vig�ncia do contrato � por tempo determinado?"//"Art. 57, � 3�"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","008"},{"COX_DESC",STR0381},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0380},{"COX_ORDEM","008"},{"COX_DESCDE","    "}})//"Art. 55, inciso IV"//"O contrato prev� os prazos de in�cio das etapas de execu��o, de entrega, de conclus�o, de observa��o (acompanhamento, fiscaliza��o ou monitoramento) e de recebimento definitivo, conforme o caso?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","009"},{"COX_DESC",STR0382},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0383},{"COX_ORDEM","009"},{"COX_DESCDE",STR0384}})//"A cl�usula que define o cr�dito pelo qual ocorrer� a despesa, com a indica��o da classifica��o funcional program�tica e da categoria econ�mica est� compat�vel com o processo que deu origem ao contrato...?"//"Art. 55, inciso V"//"Devem-se considerar as quest�es de apostilamento necess�rias � manuten��o do contrato."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","010"},{"COX_DESC",STR0385},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0386},{"COX_ORDEM","010"},{"COX_DESCDE","    "}})//"A cl�usula que trata das garantias objetiva assegurar a plena execu��o do contrato, quando exigidas?"//"Art. 55, inciso VI"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","011"},{"COX_DESC",STR0388},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0387},{"COX_ORDEM","011"},;//"Art. 56, caput e � 1�"//"No caso de exig�ncia de garantia, a crit�rio da Administra��o, foi aplicada uma das seguintes modalidades de garantia prevista no contrato: cau��o, seguro-garantia ou fian�a banc�ria?"
	{"COX_DESCDE",STR0389+STR0551}})//"Conforme Lei Federal n� 8.666/1993, art. 56, �� 2� ao 5�: a) a garantia n�o exceder� a cinco por cento (5%) do valor do contrato e ter� seu valor atualizado nas mesmas condi��es daquele, ressalvado o previsto no item a seguir, quando for o caso; b) o limite de garantia poder� ser de at� dez por cento (10%) do valor do contrato para obras, servi�os e fornecimentos de grande vulto envolvendo alta complexidade t�cnica e riscos financeiros consider�veis, demonstrados atrav�s de parecer tecnicamente aprovado pela autoridade competente; c) a garantia ser� liberada ou restitu�da ap�s a execu��o do contrato, atualizada monetariamente quando em dinheiro; d) a garantia dever� ser acrescida do valor correspondente aos bens entregues pela Administra��o por meio do contrato, quando o contratado for deposit�rio."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","012"},{"COX_DESC",STR0390},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0391},{"COX_ORDEM","012"},{"COX_DESCDE","    "}})//"A cl�usula dos direitos e das responsabilidades (ou das obriga��es entre as partes) estabelece obriga��es que condicionem a organiza��o, dire��o, controle, execu��o e ou fiscaliza��o do contrato?"//"Art. 55, inciso VII"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","013"},{"COX_DESC",STR0392},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG","    "},{"COX_ORDEM","013"},{"COX_DESCDE",STR0393+STR0552}})//"A cl�usula de rescis�o est� de acordo com o art. 79 da Lei Federal n� 8.666, de 1993?"//"A rescis�o do contrato poder� ser: a) determinada por ato unilateral e escrito da Administra��o, nos casos enumerados nos incisos I a XII e XVII do art. 78 da Lei Federal n� 8.666/1993; b) amig�vel, por acordo entre as partes, reduzida a termo no processo da licita��o, desde que haja conveni�ncia para a Administra��o; c) judicial, nos termos da legisla��o. A rescis�o administrativa ou amig�vel dever� ser precedida de autoriza��o escrita e fundamentada da autoridade competente."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","014"},{"COX_DESC",STR0396},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0394},{"COX_ORDEM","014"},{"COX_DESCDE",STR0395}})//"Art. 55, inciso IX"//"Geralmente essa condi��o � mencionada na cl�usula de penalidades. A inexecu��o total ou parcial do contrato enseja a sua rescis�o, com as conseq��ncias contratuais e as previstas em lei ou regulamento, conforme disposto no art. 77 da Lei Federal n� 8.666/1993."//"H� no contrato elementos que indiquem o reconhecimento dos direitos da Administra��o, em caso de rescis�o administrativa por inexecu��o total ou parcial do contrato?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","015"},{"COX_DESC",STR0398},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0397},{"COX_ORDEM","015"},{"COX_DESCDE","    "}})//"Art. 55, � 2�"//"H� no contrato indica��o do foro na sede da Administra��o para dirimir quest�es contratuais, salvo nos casos dispostos no � 6� do art. 32 da Lei Federal n� 8.666/1993?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","016"},{"COX_DESC",STR0400},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0399},{"COX_ORDEM","016"},{"COX_DESCDE","    "}})//"Art. 61, caput"//"O Contrato contempla: os nomes das partes e representantes, finalidade, o ato da lavratura, o n�mero do processo da dispensa ou da inexigibilidade...?"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"ASA")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Assinatura da Ata de Registro de Precos
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ASA"},{"COV_DESC",STR0542}} }//"Assinatura da Ata"
	
	AADD(aGrid1, {{"COX_CODIGO","ASA"},{"COX_ITEM","001"},{"COX_DESC",STR0544},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0543},{"COX_ORDEM","001"},{"COX_DESCDE","    "}} )//"Os fornecedores classificados assinaram a Ata de Registro de Pre�os, dentro do prazo e condi��es estabelecidos no instrumento convocat�rio?"//"Decreto n� 7.892/2013 Art. 13"
	AADD(aGrid1, {{"COX_CODIGO","ASA"},{"COX_ITEM","002"},{"COX_DESC",STR0546},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0545},{"COX_ORDEM","002"},{"COX_DESCDE","    "}} )//"Foi cumprido os requisitos de publicidade?"//"Decreto n� 7.892/2013 Art. 14"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

//-----------------------------------------------
// Check Lists para o Sistema S (RLC)
//-----------------------------------------------

If !COV->(MsSeek(xFilial('COV')+"EDS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Elabora��o do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","EDS"},{"COV_DESC",STR0401}} }//"Elabora��o RLC"
	
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","001"},{"COX_DESC",STR0402},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0404},{"COX_ORDEM","001"},{"COX_DESCDE",STR0402}} )//STR0403//"Designar comiss�o de licita��o ou do respons�vel pelo convite."//"RLC Cap. II Art. 4 Inciso IV"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","002"},{"COX_DESC",STR0406},{"COX_PROPI","1"},{"COX_COND",""},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0407},{"COX_ORDEM","002"},{"COX_DESCDE",STR0405}} )//"Atentar-se o pre�mbulo do edital define o n�mero de ordem em s�rie anual, o nome da reparti��o interessada e de seu setor, a modalidade, o regime de execu��o e o tipo da licita��o, a men��o de que ser� regida pela Lei n� 8.666/93, o local, dia e hora para recebimento da documenta��o e proposta, bem como para in�cio da abertura dos envelopes."//"Atentar-se o pre�mbulo do edital..."//"RLC Cap. VI Art. 14 Inciso I ao V"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","003"},{"COX_DESC",STR0408},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0410},{"COX_ORDEM","003"},{"COX_DESCDE",STR0408}} )//STR0409//"Indicar no instrumento convocat�rio os recursos para a despesa e comprovar a exist�ncia de recursos or�ament�rios que assegurem o pagamento da obriga��o."//"RLC Cap. VI Art. 13"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","004"},{"COX_DESC",STR0411},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0413},{"COX_ORDEM","004"},{"COX_DESCDE",STR0411}} )//STR0412//"Anexar ao edital os projetos, a minuta do contrato, as especifica��es t�cnicas complementares e as normas de execu��o pertinentes."//"RLC Cap. VI Art. 14 Paragr. 2�"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","005"},{"COX_DESC",STR0414},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0416},{"COX_ORDEM","005"},{"COX_DESCDE",STR0414}} )//STR0415//"Observar se o objeto � dividido em parcelas, com vistas ao melhor aproveitamento dos recursos do mercado e � ampla competi��o, sem perda de economia de escala."//"RLC Cap. II Art. 4 Inciso III"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","006"},{"COX_DESC",STR0417},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0419},{"COX_ORDEM","006"},{"COX_DESCDE",STR0417}} )//STR0418//"Incluir no edital crit�rio de aceitabilidade de pre�os unit�rio e global m�ximo."//"RLC Cap. VI Art. 20 Inciso XII"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","007"},{"COX_DESC",STR0420},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0422},{"COX_ORDEM","007"},{"COX_DESCDE",STR0420}} )//STR0421//"Datar, rubricar e assinar o instrumento convocat�rio pela autoridade que o expediu."//"RLC Cap. VII Art. 35"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","008"},{"COX_DESC",STR0423},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0425},{"COX_ORDEM","008"},{"COX_DESCDE",STR0423}} )//STR0424//"Proceder � an�lise da publicidade dos atos, dentro dos prazos, bem como verificar se h� comprovantes desses."//"RLC Cap. I Art. 2"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"ANS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para An�lise do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ANS"},{"COV_DESC",STR0426}} }//"An�lise RLC"
	
	AADD(aGrid1,{{"COX_CODIGO","ANS"},{"COX_ITEM","001"},{"COX_DESC",STR0427},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0429},{"COX_ORDEM","001"},{"COX_DESCDE",STR0427}} )//STR0428//"Observar se est�o sendo adotados modalidades e regime de execu��o apropriado."//"RLC Cap. III Art. 5 e seus incisos e par�grafos e Art. 6  e seus incisos"
	AADD(aGrid1,{{"COX_CODIGO","ANS"},{"COX_ITEM","002"},{"COX_DESC",STR0431},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0430},{"COX_ORDEM","002"},{"COX_DESCDE",STR0431}} )//"RLC Cap. I Art. 2"//STR0432//"Verificar se h� caracteriza��o adequada do objeto licitado."
	AADD(aGrid1,{{"COX_CODIGO","ANS"},{"COX_ITEM","003"},{"COX_DESC",STR0433},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0435},{"COX_ORDEM","003"},{"COX_DESCDE",STR0433}} )//STR0434//"N�o fracionar despesas para alterar a modalidade de licita��o."//"RLC Cap. III Art. 7"
	AADD(aGrid1,{{"COX_CODIGO","ANS"},{"COX_ITEM","004"},{"COX_DESC",STR0436},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0438},{"COX_ORDEM","004"},{"COX_DESCDE",STR0436}} )//STR0437//"A licita��o foi formalizada por meio de processo administrativo, devidamente autuado, protocolado e numerado?"//"RLC Cap. VI Art. 14 e seus incisos"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"HAS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Habilita��o do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","HAS"},{"COV_DESC",STR0439}} }//"Habilita��o RLC"
	
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","001"},{"COX_DESC",STR0440},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0442},{"COX_ORDEM","001"},{"COX_DESCDE",STR0440}} )//STR0441//"N�o incluir no edital cl�usula restritiva � ampla competi��o e incompat�vel com a obra que se pretende contratar."//"RLC Cap. I Art. 2"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","002"},{"COX_DESC",STR0444},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0445},{"COX_ORDEM","002"},{"COX_DESCDE",STR0443}} )//"Exigir no edital as comprova��es das proponentes de qualifica��o jur�dica, t�cnica, econ�mico-financeira, regularidade fiscal e cumprimento do disposto no inciso XXXIII do art. 7� da Constitui��o Federal. Constitui��o Federal, art. 7�, XXXIII e art. 37, XXI."//"Exigir no edital as comprova��es das proponentes de qualifica��o jur�dica, t�cnica, econ�mico-financeira, regularidade fiscal..."//"RLC Cap. V Art. 12 e seus incisos e seu  par�grafo �nico."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","003"},{"COX_DESC",STR0447},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0448},{"COX_ORDEM","003"},{"COX_DESCDE",STR0446}} )//"Na fase de habilita��o, observar se a proponente teve algum tipo de participa��o na elabora��o dos projetos ou � servidor p�blico do �rg�o contratante ou respons�vel pela licita��o."//"Na fase de habilita��o, observar se a proponente teve algum tipo de participa��o na elabora��o dos projetos ou � servidor p�blico..."//"RLC Cap. IX Art. 39"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","004"},{"COX_DESC",STR0450},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0449},{"COX_ORDEM","004"},{"COX_DESCDE",STR0450}} )//"RLC Cap. VI Art. 22 e seus par�grafos, Art. 23 e par�grafo �nico e Art. 24"//STR0451//"Respeitar os prazos recursais."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","005"},{"COX_DESC",STR0452},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0454},{"COX_ORDEM","005"},{"COX_DESCDE",STR0452}} )//STR0453//"Providenciar, nos seus devidos tempos, as atas das fases de julgamento da habilita��o e das propostas de pre�os."//"RLC Cap. VI Art. 15"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","006"},{"COX_DESC",STR0455},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0457},{"COX_ORDEM","006"},{"COX_DESCDE",STR0455}} )//STR0456//"Foi solicitado o documento de identidade, no caso de pessoa f�sica?"//"RLC Cap. V Art. 12 Inciso I, a"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","007"},{"COX_DESC",STR0458},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0460},{"COX_ORDEM","007"},{"COX_DESCDE",STR0458}} )//STR0459//"Foi solicitado o registro comercial, no caso de empresa individual?"//"RLC Cap. V Art. 12 Inciso I, b"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","008"},{"COX_DESC",STR0462},{"COX_PROPI","1"},{"COX_COND",""},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0463},{"COX_ORDEM","008"},{"COX_DESCDE",STR0461}} )//"Foi solicitado o ato constitutivo, estatuto ou contrato social em vigor, devidamente registrado, em se tratando de sociedades comerciais, e, no caso de sociedades por a��es, acompanhado de documentos de elei��o de seus administradores?"//"Foi solicitado o ato constitutivo, estatuto ou contrato social em vigor...?"//"RLC Cap. V Art. 12 Inciso I, c"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","009"},{"COX_DESC",STR0464},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0466},{"COX_ORDEM","009"},{"COX_DESCDE",STR0464}} )//STR0465//"Foi solicitada a inscri��o do ato constitutivo, no caso de sociedades civis, acompanhada de prova de diretoria em exerc�cio?"//"RLC Cap. V Art. 12 Inciso I, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","010"},{"COX_DESC",STR0468},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0469},{"COX_ORDEM","010"},{"COX_DESCDE",STR0467}} )//"Foi solicitado o decreto de autoriza��o, em se tratando de empresa ou sociedade estrangeira em funcionamento no Pa�s, e ato de registro ou autoriza��o para funcionamento expedido pelo �rg�o competente, quando a atividade assim o exigir?"//"Foi solicitado o decreto de autoriza��o, em se tratando de empresa ou sociedade estrangeira em funcionamento no Pa�s...?"//"RLC Cap. V Art. 12 Inciso II, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","011"},{"COX_DESC",STR0470},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0472},{"COX_ORDEM","011"},{"COX_DESCDE",STR0470}} )//STR0471//"Foi solicitada a prova de inscri��o no Cadastro de Pessoas F�sicas (CPF) ou no Cadastro Nacional de Pessoas Jur�dicas (CNPJ)?"//"RLC Cap. V Art. 12 Inciso IV, a"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","012"},{"COX_DESC",STR0474},{"COX_PROPI","1"},{"COX_COND",""},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0475},{"COX_ORDEM","012"},{"COX_DESCDE",STR0473}} )//"Foi solicitada prova de inscri��o no cadastro de contribuintes estadual ou municipal , se houver, relativo ao domic�lio ou sede do licitante, pertinente ao seu ramo de atividade e compat�vel com o objeto contratual?"//"Foi solicitada prova de inscri��o no cadastro de contribuintes estadual ou municipal...?"//"RLC Cap. V Art. 12 Inciso IV, b"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","013"},{"COX_DESC",STR0477},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0478},{"COX_ORDEM","013"},{"COX_DESCDE",STR0476}} )//"Foi solicitada, conforme o caso, prova de regularidade para com a Fazenda Federal (Certid�es Negativas � D�vida Ativa/PFN e Tributos Administrados pela Receita Federal), Estadual e Municipal do domic�lio ou sede do licitante, ou outra equivalente, na forma da lei?"//"Foi solicitada, conforme o caso, prova de regularidade para com a Fazenda Federal...?"//"RLC Cap. V Art. 12 Inciso III, b"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","014"},{"COX_DESC",STR0479},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0481},{"COX_ORDEM","014"},{"COX_DESCDE",STR0479}} )//STR0480//"Foi solicitada prova de regularidade relativa � Seguridade Social (INSS)"//"RLC Cap. V Art. 12 Inciso IV, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","015"},{"COX_DESC",STR0482},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0484},{"COX_ORDEM","015"},{"COX_DESCDE",STR0483}} )//"Foi solicitada prova de regularidade relativa ao FGTS"//"Foi solicitada prova de regularidade relativa ao Fundo de Garantia por Tempo de Servi�o (FGTS)"//"RLC Cap. V Art. 12 Inciso IV, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","016"},{"COX_DESC",STR0486},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0485},{"COX_ORDEM","016"},{"COX_DESCDE",STR0486}} )//"RLC Cap. V Art. 12 Inciso IV, a"//STR0487//"registro ou inscri��o na entidade profissional competente"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","017"},{"COX_DESC",STR0490},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0488},{"COX_ORDEM","017"},{"COX_DESCDE",STR0489}} )//"RLC Cap. V Art. 12 Inciso II, b"//"comprova��o de aptid�o para desempenho de atividade pertinente e compat�vel em caracter�sticas, quantidades e prazos com o objeto da licita��o, e indica��o das instala��es e do aparelhamento e do pessoal t�cnico adequados e dispon�veis para a realiza��o do objeto da licita��o, bem como da qualifica��o de cada um dos membros da equipe t�cnica que se responsabilizar� pelos trabalhos"//"comprova��o de aptid�o para desempenho de atividade pertinente e compat�vel em caracter�sticas, quantidades e prazos com o objeto da licita��o..."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","018"},{"COX_DESC",STR0492},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0491},{"COX_ORDEM","018"},{"COX_DESCDE",STR0492}} )//"RLC Cap. V Art. 12 Inciso II, c"//STR0493//"comprova��o, fornecida pelo �rg�o licitante, de que recebeu os documentos, e, quando exigido, de que tomou conhecimento de todas as informa��es e das condi��es locais para o cumprimento das obriga��es objeto da licita��o"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","019"},{"COX_DESC",STR0495},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0494},{"COX_ORDEM","019"},{"COX_DESCDE",STR0495}} )//"RLC Cap. V Art. 12 Inciso II, d"//STR0496//"prova de atendimento de requisitos previstos em lei especial, quando for o caso"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","020"},{"COX_DESC",STR0497},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0499},{"COX_ORDEM","020"},{"COX_DESCDE",STR0497}} )//STR0498//"N�o houve a fixa��o de quantidades m�nimas e prazos m�ximos para a capacita��o t�cnico-profissional?"//"RLC Cap. V Art. 12 Inciso II, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","021"},{"COX_DESC",STR0501},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0502},{"COX_ORDEM","021"},{"COX_DESCDE",STR0500}} )//"N�o houve a exig�ncia de itens irrelevantes e sem valor significativo em rela��o ao objeto em licita��o para efeito de capacita��o t�cnico-profissional?"//"N�o houve a exig�ncia de itens irrelevantes...?"//"RLC Cap. V Art. 12 Inciso II, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","022"},{"COX_DESC",STR0505},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0503},{"COX_ORDEM","022"},{"COX_DESCDE",STR0504}} )//"RLC Cap. V Art. 12 Inciso III, a"//"balan�o patrimonial e demonstra��es cont�beis do �ltimo exerc�cio social, j� exig�veis e apresentados na forma da lei, que comprovem a boa situa��o financeira da empresa, vedada a sua substitui��o por balancetes ou balan�os provis�rios, podendo ser atualizados por �ndices oficiais quando encerrado h� mais de 3 meses da data de apresenta��o da proposta"//"balan�o patrimonial e demonstra��es cont�beis do �ltimo exerc�cio social, j� exig�veis e apresentados na forma da lei, que comprovem a boa situa��o financeira da empresa, vedada a sua substitui��o por balancetes ou balan�os provis�rios..."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","023"},{"COX_DESC",STR0507},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0506},{"COX_ORDEM","023"},{"COX_DESCDE",STR0507}} )//"RLC Cap. V Art. 12 Inciso III, b"//STR0508//"certid�o negativa de fal�ncia ou concordata expedida pelo distribuidor da sede da pessoa jur�dica, ou de execu��o patrimonial, expedida no domic�lio da pessoa f�sica"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","024"},{"COX_DESC",STR0510},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0509},{"COX_ORDEM","024"},{"COX_DESCDE",STR0510}} )//"RLC Cap. V Art. 12 Inciso III, c"//STR0511//"garantia limitada a 1% (um por cento) do valor estimado do objeto da contrata��o ou capital m�nimo/valor do patrim�nio l�quido inferior a 10% (dez por cento) do valor estimado da contrata��o."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","025"},{"COX_DESC",STR0513},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0512},{"COX_ORDEM","025"},{"COX_DESCDE",STR0513}} )//"RLC Cap. V Art. 12 Inciso III, a"//STR0514//"�ndices cont�beis que comprovem a boa situa��o financeira do licitante."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","026"},{"COX_DESC",STR0515},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0517},{"COX_ORDEM","026"},{"COX_DESCDE",STR0515}} )//STR0516//"N�o houve a exig�ncia cumulativa de garantia de proposta com valor de capital m�nimo/patrim�nio l�quido (item c anterior)?"//"RLC Cap. V Art. 12 Inciso III, c"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","027"},{"COX_DESC",STR0518},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0520},{"COX_ORDEM","027"},{"COX_DESCDE",STR0518}} )//STR0519//"Os �ndices cont�beis e seus valores, se exigidos, s�o os usualmente adotados para correta avalia��o de situa��o financeira suficiente ao cumprimento das obriga��es decorrentes da licita��o?"//"RLC Cap. V Art. 12 Inciso III, a"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"HOS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Homologa��o do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","HOS"},{"COV_DESC",STR0521}} }//"Homologa��o RLC"
	
	AADD(aGrid1,{{"COX_CODIGO","HOS"},{"COX_ITEM","001"},{"COX_DESC",STR0522},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0524},{"COX_ORDEM","001"},{"COX_DESCDE",STR0522}} )//STR0523//"Providenciar ato de homologa��o e adjudica��o do objeto da licita��o."//"RLC Cap. II, Art. 4, Inciso 5"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"ADS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Adjudica��o do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ADS"},{"COV_DESC",STR0525}} }//"Adjudicao RLC"
		
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","001"},{"COX_DESC",STR0526},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0528},{"COX_ORDEM","001"},{"COX_DESCDE",STR0526}} )//STR0527//"Providenciar ato de homologa��o e adjudica��o do objeto da licita��o."//"RLC Cap. II, Art. 4, Inciso 6"
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","002"},{"COX_DESC",STR0529},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0531},{"COX_ORDEM","002"},{"COX_DESCDE",STR0529}} )//STR0530//"Convocar o interessado a assinar o contrato no prazo e condi��es estabelecidos, observando a ordem de classifica��o das licitantes."//"RLC Cap. VIII, Art. 35"
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","003"},{"COX_DESC",STR0532},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0534},{"COX_ORDEM","003"},{"COX_DESCDE",STR0532}} )//STR0533//"Observar se o contrato � claro e preciso quanto � identifica��o do objeto e seus elementos caracterizadores."//"RLC Cap. VII, Art. 26"
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","004"},{"COX_DESC",STR0535},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0537},{"COX_ORDEM","004"},{"COX_DESCDE",STR0535}} )//STR0536//"Atentar-se o contrato prev� com clareza e precis�o as condi��es para a sua execu��o, definindo direitos, obriga��es e responsabilidades das partes condizentes aos termos da licita��o e proposta apresentada."//"RLC Cap. VII, Art. 26, Par�grafo �nico"
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","005"},{"COX_DESC",STR0538},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0540},{"COX_ORDEM","005"},{"COX_DESCDE",STR0538}} )//STR0539//"Providenciar publica��o resumida do extrato de contrato."//"RLC Cap. VII, Art. 27, Par�grafo �nico"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()
	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"RDE")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Elabora��o do Edital RDC
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","RDE"},{"COV_DESC",STR0554}} }//"Elabora��o RDC"
		
	AADD(aGrid1,{{"COX_CODIGO","RDE"},{"COX_ITEM","001"},{"COX_DESC",STR0548},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0549},{"COX_ORDEM","001"},{"COX_DESCDE",STR0550}} )//STR0548//"Caso o Regime de Execu��o seja Empreitada por Pre�o Unit�rio ou Tarefa foi informada a Justificativa da escolha."//"LEI FEDERAL N� 12.462/2011, ART 8, INCISOS I A V, � 1 E 2"
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()
	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIF

If !COV->(MsSeek(xFilial('COV')+"RDH")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Habilita��o do Edital RDC
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","RDH"},{"COV_DESC",STR0555}} }//"Habilita��o RDC"
		
	AADD(aGrid1,{{"COX_CODIGO","RDH"},{"COX_ITEM","001"},{"COX_DESC",STR0565},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0566},{"COX_ORDEM","001"},{"COX_DESCDE",STR0567}} )
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()
	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"RDJ")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Julgamento do Edital RDC
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","RDJ"},{"COV_DESC",STR0556}} }//"Julgamento RDC"
		
	AADD(aGrid1,{{"COX_CODIGO","RDJ"},{"COX_ITEM","001"},{"COX_DESC",STR0568},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0569},{"COX_ORDEM","001"},{"COX_DESCDE",STR0570}} )
	AADD(aGrid1,{{"COX_CODIGO","RDJ"},{"COX_ITEM","002"},{"COX_DESC",STR0571},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0572},{"COX_ORDEM","002"},{"COX_DESCDE",STR0573}} )
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid  := {}
	aGrid1 := {}
	aField := {}
EndIf

//********** Lei 13.303/2016 **********
If !COV->(MsSeek(xFilial('COV')+"PRE")) //-COV_FILIAL+COV_CODIGO
	//-----------------------------------------------
	// Check Lists para Prepara��o
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","PRE"},{"COV_DESC",STR0557}} }//"Prepara��o Lei 13.303/2016"

	AADD(aGrid1,{{"COX_CODIGO","PRE"},{"COX_ITEM","001"},{"COX_DESC",STR0574},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0575},{"COX_ORDEM","001"},{"COX_DESCDE",STR0576}} )
	AADD(aGrid1,{{"COX_CODIGO","PRE"},{"COX_ITEM","002"},{"COX_DESC",STR0577},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0578},{"COX_ORDEM","002"},{"COX_DESCDE",STR0579}} )
	AADD(aGrid1,{{"COX_CODIGO","PRE"},{"COX_ITEM","003"},{"COX_DESC",STR0580},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0581},{"COX_ORDEM","003"},{"COX_DESCDE",STR0582}} )
	AADD(aGrid1,{{"COX_CODIGO","PRE"},{"COX_ITEM","004"},{"COX_DESC",STR0583},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0584},{"COX_ORDEM","004"},{"COX_DESCDE",STR0585}} )
	AADD(aGrid,aGrid1)

	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"JPE")) //-COV_FILIAL+COV_CODIGO
	//-----------------------------------------------
	// Check Lists para Julgamento
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","JPE"},{"COV_DESC",STR0558}} }//"Julgamento Lei 13.303/2016"

	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","001"},{"COX_DESC",STR0586},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0587},{"COX_ORDEM","001"},{"COX_DESCDE",STR0588}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","002"},{"COX_DESC",STR0589},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0590},{"COX_ORDEM","002"},{"COX_DESCDE",STR0591}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","003"},{"COX_DESC",STR0592},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0593},{"COX_ORDEM","003"},{"COX_DESCDE",STR0594}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","004"},{"COX_DESC",STR0595},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0596},{"COX_ORDEM","004"},{"COX_DESCDE",STR0597}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","005"},{"COX_DESC",STR0598},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0599},{"COX_ORDEM","005"},{"COX_DESCDE",STR0600}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","006"},{"COX_DESC",STR0601},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0602},{"COX_ORDEM","006"},{"COX_DESCDE",STR0603}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","007"},{"COX_DESC",STR0604},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0605},{"COX_ORDEM","007"},{"COX_DESCDE",STR0606}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","008"},{"COX_DESC",STR0607},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0608},{"COX_ORDEM","008"},{"COX_DESCDE",STR0609}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","009"},{"COX_DESC",STR0610},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0611},{"COX_ORDEM","009"},{"COX_DESCDE",STR0612}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","010"},{"COX_DESC",STR0613},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0614},{"COX_ORDEM","010"},{"COX_DESCDE",STR0615}} )
	AADD(aGrid1,{{"COX_CODIGO","JPE"},{"COX_ITEM","011"},{"COX_DESC",STR0616},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0617},{"COX_ORDEM","011"},{"COX_DESCDE",STR0618 + CRLF + STR0619 + CRLF + STR0620}} )
	AADD(aGrid,aGrid1)

	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"VER")) //-COV_FILIAL+COV_CODIGO
	//-----------------------------------------------
	// Check Lists para Verifica��o da Efetividade dos Lances/Propostas
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","VER"},{"COV_DESC",STR0559}} }//"Verifica��o da Efetividade dos Lances/Propostas Lei 13.303/2016"

	AADD(aGrid1,{{"COX_CODIGO","VER"},{"COX_ITEM","001"},{"COX_DESC",STR0621},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0622},{"COX_ORDEM","001"},{"COX_DESCDE",STR0623}} )
	AADD(aGrid1,{{"COX_CODIGO","VER"},{"COX_ITEM","002"},{"COX_DESC",STR0624},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0625},{"COX_ORDEM","002"},{"COX_DESCDE",STR0626}} )
	AADD(aGrid1,{{"COX_CODIGO","VER"},{"COX_ITEM","003"},{"COX_DESC",STR0627},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0628},{"COX_ORDEM","003"},{"COX_DESCDE",STR0629}} )
	AADD(aGrid1,{{"COX_CODIGO","VER"},{"COX_ITEM","004"},{"COX_DESC",STR0630},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0631},{"COX_ORDEM","004"},{"COX_DESCDE",STR0632}} )
	AADD(aGrid1,{{"COX_CODIGO","VER"},{"COX_ITEM","005"},{"COX_DESC",STR0633},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0634},{"COX_ORDEM","005"},{"COX_DESCDE",STR0635}} )
	AADD(aGrid1,{{"COX_CODIGO","VER"},{"COX_ITEM","006"},{"COX_DESC",STR0636},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0637},{"COX_ORDEM","006"},{"COX_DESCDE",STR0638}} )
	AADD(aGrid1,{{"COX_CODIGO","VER"},{"COX_ITEM","007"},{"COX_DESC",STR0639},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0640},{"COX_ORDEM","007"},{"COX_DESCDE",STR0641}} )
	AADD(aGrid1,{{"COX_CODIGO","VER"},{"COX_ITEM","008"},{"COX_DESC",STR0642},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0643},{"COX_ORDEM","008"},{"COX_DESCDE",STR0644}} )
	AADD(aGrid1,{{"COX_CODIGO","VER"},{"COX_ITEM","009"},{"COX_DESC",STR0645},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0646},{"COX_ORDEM","009"},{"COX_DESCDE",STR0647 + CRLF + STR0648 + CRLF + STR0649}} )
	AADD(aGrid,aGrid1)

	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"NEG")) //-COV_FILIAL+COV_CODIGO
	//-----------------------------------------------
	// Check Lists para Negocia��o
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","NEG"},{"COV_DESC",STR0560}} }//"Negocia��o Lei 13.303/2016"

	AADD(aGrid1,{{"COX_CODIGO","NEG"},{"COX_ITEM","001"},{"COX_DESC",STR0650},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0651},{"COX_ORDEM","001"},{"COX_DESCDE",STR0652}} )
	AADD(aGrid1,{{"COX_CODIGO","NEG"},{"COX_ITEM","002"},{"COX_DESC",STR0653},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0654},{"COX_ORDEM","002"},{"COX_DESCDE",STR0655}} )
	AADD(aGrid,aGrid1)

	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"HBE")) //-COV_FILIAL+COV_CODIGO
	//-----------------------------------------------
	// Check Lists para Habilita��o
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","HBE"},{"COV_DESC",STR0561}} }//"Habilita��o Lei 13.303/2016"

	AADD(aGrid1,{{"COX_CODIGO","HBE"},{"COX_ITEM","001"},{"COX_DESC",STR0656},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0657},{"COX_ORDEM","001"},{"COX_DESCDE",STR0658}} )
	AADD(aGrid1,{{"COX_CODIGO","HBE"},{"COX_ITEM","002"},{"COX_DESC",STR0659},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0660},{"COX_ORDEM","002"},{"COX_DESCDE",STR0661}} )
	AADD(aGrid1,{{"COX_CODIGO","HBE"},{"COX_ITEM","003"},{"COX_DESC",STR0662},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0663},{"COX_ORDEM","003"},{"COX_DESCDE",STR0664}} )
	AADD(aGrid1,{{"COX_CODIGO","HBE"},{"COX_ITEM","004"},{"COX_DESC",STR0665},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0666},{"COX_ORDEM","004"},{"COX_DESCDE",STR0667}} )
	AADD(aGrid1,{{"COX_CODIGO","HBE"},{"COX_ITEM","005"},{"COX_DESC",STR0668},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0669},{"COX_ORDEM","005"},{"COX_DESCDE",STR0673}} )
	AADD(aGrid1,{{"COX_CODIGO","HBE"},{"COX_ITEM","006"},{"COX_DESC",STR0670},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0671},{"COX_ORDEM","006"},{"COX_DESCDE",STR0672}} )
	AADD(aGrid,aGrid1)

	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"REC")) //-COV_FILIAL+COV_CODIGO
	//-----------------------------------------------
	// Check Lists para Interposi��o de recursos
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","REC"},{"COV_DESC",STR0562}} }//"Interposi��o de Recursos Lei 13.303/2016"

	AADD(aGrid1,{{"COX_CODIGO","REC"},{"COX_ITEM","001"},{"COX_DESC",STR0674},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0675},{"COX_ORDEM","001"},{"COX_DESCDE",STR0676}} )
	AADD(aGrid,aGrid1)

	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"ADE")) //-COV_FILIAL+COV_CODIGO
	//-----------------------------------------------
	// Check Lists para Adjudica��o
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","ADE"},{"COV_DESC",STR0563}} }//"Adjudica��o Lei 13.303/2016"

	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","001"},{"COX_DESC",STR0677},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0678},{"COX_ORDEM","001"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","002"},{"COX_DESC",STR0679},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0680},{"COX_ORDEM","002"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","003"},{"COX_DESC",STR0681},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0682},{"COX_ORDEM","003"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","004"},{"COX_DESC",STR0683},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0684},{"COX_ORDEM","004"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","005"},{"COX_DESC",STR0685},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0686},{"COX_ORDEM","005"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","006"},{"COX_DESC",STR0687},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0688},{"COX_ORDEM","006"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","007"},{"COX_DESC",STR0689},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0690},{"COX_ORDEM","007"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","008"},{"COX_DESC",STR0691},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0692},{"COX_ORDEM","008"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","009"},{"COX_DESC",STR0693},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0694},{"COX_ORDEM","009"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","010"},{"COX_DESC",STR0695},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0696},{"COX_ORDEM","010"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","011"},{"COX_DESC",STR0697},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0698},{"COX_ORDEM","011"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","012"},{"COX_DESC",STR0699},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0700},{"COX_ORDEM","012"},{"COX_DESCDE",""}} )
	AADD(aGrid1,{{"COX_CODIGO","ADE"},{"COX_ITEM","013"},{"COX_DESC",STR0701},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0702},{"COX_ORDEM","013"},{"COX_DESCDE",""}} )
	AADD(aGrid,aGrid1)

	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"HOE")) //-COV_FILIAL+COV_CODIGO
	//-----------------------------------------------
	// Check Lists para Homologa��o
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","HOE"},{"COV_DESC",STR0564}} }//"Homologa��o Lei 13.303/2016"

	AADD(aGrid1,{{"COX_CODIGO","HOE"},{"COX_ITEM","001"},{"COX_DESC",STR0703},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0704},{"COX_ORDEM","001"},{"COX_DESCDE",STR0705}} )
	AADD(aGrid,aGrid1)
	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

COV->(dbCloseArea())

COX->(dbCloseArea())

Return lRet