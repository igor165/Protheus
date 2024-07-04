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
Definição do modelo de Dados

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

oModel:GetModel( 'COVMASTER' ):SetDescription( STR0003 )//'Cabeçalho do Check-List'
oModel:GetModel( 'COXDETAIL' ):SetDescription( STR0004 )//'Item do Check-List'
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

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
oView:EnableTitleView('VIEW_COV',STR0005)//'Cabeçalho Check-List'
oView:SetOwnerView( 'VIEW_COX', 'INFERIORESQ' )
oView:EnableTitleView('VIEW_COX',STR0006)//'Itens Check-List'
oView:AddIncrementField( 'VIEW_COX', 'COX_ITEM' )
oView:AddIncrementField( 'VIEW_COX', 'COX_ORDEM' )

oView:AddOtherObject("OTHER_PANEL", {|oPanel| GCPGrdOrd( oPanel, oView, 'COXDETAIL', 'COX_ITEM' )})
oView:SetOwnerView("OTHER_PANEL",'INFERIORDIR')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

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
	Help(' ', 1,'A120lOK',,STR0011 ,1,0)//"Por motivos legais, não é permitido alterar uma linha de propriedade da TOTVS"
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
			Help(' ', 1,'A120lOK2',,STR0012 ,1,0)//"Código do Check-List já existente na base de dados"
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
			Help(' ', 1,'A120lOK',,STR0013 ,1,0)//"Por motivos legais, não é permitido excluir um check-list com linhas de propriedade da TOTVS"
			Exit
		Endif
	Next
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A120Import
Rotina de importação do checkList -  GCPA120
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
	// Check Lists para Elaboração do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ELA"},{"COV_DESC",STR0014}} }//"Elaboração do Edital"
	
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","001"},{"COX_DESC",STR0016},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0015},{"COX_ORDEM","001"},{"COX_DESCDE",STR0016}} )//"Lei nº 8.666/93, art. 38,caput."//STR0017//"Providenciar autorização da autoridade competente para realização da licitação."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","002"},{"COX_DESC",STR0018},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0020},{"COX_ORDEM","002"},{"COX_DESCDE",STR0018}} )//STR0019//"Designar comissão de licitação ou do responsável pelo convite."//"Lei nº 8.666/93, art. 38, III."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","003"},{"COX_DESC",STR0021},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0023},{"COX_ORDEM","003"},{"COX_DESCDE",STR0021}} )//STR0022//"Autuar, protocolar e numerar o processo administrativo."//"Lei nº 8.666/93, art. 38, caput."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","004"},{"COX_DESC",STR0025},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0026},{"COX_ORDEM","004"},{"COX_DESCDE",STR0024}} )//"Atentar-se o preâmbulo do edital define o número de ordem em série anual, o nome da repartição interessada e de seu setor, a modalidade, o regime de execução e o tipo da licitação, a menção de que será regida pela Lei nº 8.666/93, o local, dia e hora para recebimento da documentação e proposta, bem como para início da abertura dos envelopes."//"Atentar-se o preâmbulo do edital"//"Lei nº 8.666/93, art. 40, caput."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","005"},{"COX_DESC",STR0027},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0029},{"COX_ORDEM","005"},{"COX_DESCDE",STR0027}} )//STR0028//"Indicar no instrumento convocatório os recursos para a despesa e comprovar a existência de recursos orçamentários que assegurem o pagamento da obrigação."//"Lei nº 8.666/93, art. 38, caput."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","006"},{"COX_DESC",STR0030},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0032},{"COX_ORDEM","006"},{"COX_DESCDE",STR0030}} )//STR0031//"Anexar ao edital orçamento detalhado em planilhas com a composição dos custos unitários, inclusive com BDI estimado."//"Lei nº 8.666/93, art. 40, § 2º, II."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","007"},{"COX_DESC",STR0033},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0035},{"COX_ORDEM","007"},{"COX_DESCDE",STR0033}} )//STR0034//"Anexar ao edital os projetos, a minuta do contrato, as especificações técnicas complementares e as normas de execução pertinentes."//"Lei nº 8.666/93, art. 40, § 2º."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","008"},{"COX_DESC",STR0037},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0036},{"COX_ORDEM","008"},{"COX_DESCDE",STR0037}} )//"Lei nº 8.666/93, art. 23, §1º."//STR0038//"Observar se o objeto é dividido em parcelas, com vistas ao melhor aproveitamento dos recursos do mercado e à ampla competição, sem perda de economia de escala."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","009"},{"COX_DESC",STR0039},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0041},{"COX_ORDEM","009"},{"COX_DESCDE",STR0039}} )//STR0040//"Evidenciar no processo se o cronograma físico-financeiro do edital está compatível com o do projeto básico."//"Lei nº 8.666/93, art. 7º, §2º. E 8 º."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","010"},{"COX_DESC",STR0042},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0044},{"COX_ORDEM","010"},{"COX_DESCDE",STR0042}} )//STR0043//"Incluir no edital previsão do direito de preferência para a contratação das Microempresas e as Empresas de Pequeno Porte."//"Lei nº 8.666/93, art. 7º, §2º. E 8 º."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","011"},{"COX_DESC",STR0045},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0047},{"COX_ORDEM","011"},{"COX_DESCDE",STR0045}} )//STR0046//"Inserir no edital as condições de pagamento, o cronograma de desembolso, os critérios de atualização financeira dos valores a serem pagos, as compensações financeiras, as penalizações e exigência de seguros, quando for o caso."//"Lei nº 8.666/93, art. 40, XIV."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","012"},{"COX_DESC",STR0048},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0050},{"COX_ORDEM","012"},{"COX_DESCDE",STR0048}} )//STR0049//"Incluir no edital critério de aceitabilidade de preços unitário e global máximo."//"Lei nº 8.666/93, art. 40, X."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","013"},{"COX_DESC",STR0051},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0053},{"COX_ORDEM","013"},{"COX_DESCDE",STR0051}} )//STR0052//"Datar, rubricar e assinar o instrumento convocatório pela autoridade que o expediu."//"Lei nº 8.666/93, art. 40, § 1º."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","014"},{"COX_DESC",STR0055},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0054},{"COX_ORDEM","014"},{"COX_DESCDE",STR0055}} )//"Lei nº 8.666/93, art. 21 e parágrafos."//STR0056//"Proceder à análise da publicidade dos atos, dentro dos prazos, bem como verificar se há comprovantes desses."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","015"},{"COX_DESC",STR0059},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0057},{"COX_ORDEM","015"},{"COX_DESCDE",STR0058}} )//" Lei nº 8.666/93, art. 7º, § 2º, III."//" Observar se a previsão de recursos orçamentários assegura o pagamento das etapas a serem realizadas no exercício financeiro em curso."//"Observar se a previsão de recursos orçamentários assegura o pagamento das etapas a serem realizadas no exercício financeiro em curso."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","016"},{"COX_DESC",STR0060},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0062},{"COX_ORDEM","016"},{"COX_DESCDE",STR0060}} )//STR0061//"Caso o objeto envolva a prestação de serviços (inclusive obras), no preâmbulo edital consta o regime de execução escolhido?(empreitada por preço unitário, por preço global, integral ou tarefa)"//"Lei n.º 8.666/93, art. 40, caput"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","017"},{"COX_DESC",STR0063},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0065},{"COX_ORDEM","017"},{"COX_DESCDE",STR0063}} )//STR0064//"Ato declaratório do Presidente da República, mediante decretação de estado de sítio;"//"C.F., art. 84, inciso XIX, e art. 137, inciso II"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","018"},{"COX_DESC",STR0066},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0068},{"COX_ORDEM","018"},{"COX_DESCDE",STR0066}} )//STR0067//"Autorização prévia ou referendo posterior do Congresso Nacional;"//"C.F., art. 49, inciso II"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","019"},{"COX_DESC",STR0070},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0069},{"COX_ORDEM","019"},{"COX_DESCDE",STR0070}} )//"Decreto Federal nº 5.376/2005, art. 17, § 1º"//STR0071//"Edição, pelo Governador do estado, de decreto de homologação de estado de calamidade pública;"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","020"},{"COX_DESC",STR0072},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0074},{"COX_ORDEM","020"},{"COX_DESCDE",STR0072}} )//STR0073//"Existência de documentação probatória da ocorrência de situação emergencial que reclama solução imediata"//"Lei 8.666, Art. 24, inciso IV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","021"},{"COX_DESC",STR0075},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0077},{"COX_ORDEM","021"},{"COX_DESCDE",STR0075}} )//STR0076//"Justificativa formal que caracterize a situação emergencial ou calamitosa que evidencia a urgência"//"Lei Federal nº. 8.666/93 Art. 26, parágrafo único, inciso I"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","022"},{"COX_DESC",STR0078},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0080},{"COX_ORDEM","022"},{"COX_DESCDE",STR0078}} )//STR0079//"Conclusão da licitação anterior sem êxito"//"Lei Federal nº. 8.666/93 Art. 24, parágrafo único, inciso V"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","023"},{"COX_DESC",STR0082},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0081},{"COX_ORDEM","023"},{"COX_DESCDE",STR0082}} )//"Lei Federal nº. 8.666/93 Art. 24, parágrafo único, inciso V"//STR0083//"Licitação deserta - inexistência de adjudicação na licitação anterior, devido à ausência de interessados"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","024"},{"COX_DESC",STR0085},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0084},{"COX_ORDEM","024"},{"COX_DESCDE",STR0085}} )//"Lei Federal nº. 8.666/93 Art. 24, parágrafo único, inciso V"//STR0086//"Manutenção das condições ofertadas no ato convocatório anterior."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","025"},{"COX_DESC",STR0087},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0089},{"COX_ORDEM","025"},{"COX_DESCDE",STR0087}} )//STR0088//"Justificativa formal com indicação dos riscos de prejuízo, caracterizado ou demasiadamente aumentado pela demora decorrente de novo processo licitatório"//"Lei Federal nº. 8.666/93 Art. 26"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","026"},{"COX_DESC",STR0091},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0090},{"COX_ORDEM","026"},{"COX_DESCDE",STR0091}} )//"Lei Federal nº 8.666/1993, art. 24, inciso VII, art. 43, inciso IV;"//STR0092//"Licitação anterior frustrada, por terem sido apresentados por todos os ofertantes preços manifestamente superiores aos de mercado ou incompatíveis"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","027"},{"COX_DESC",STR0094},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0093},{"COX_ORDEM","027"},{"COX_DESCDE",STR0094}} )//"Lei Federal nº. 8.666/1993, art. 48, § 3º."//STR0095//"Novas propostas apresentadas pelos mesmos licitantes no prazo de oito dias (ou três dias, no caso de convite) contados da decisão de desclassificação das propostas originais;"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","028"},{"COX_DESC",STR0096},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0098},{"COX_ORDEM","028"},{"COX_DESCDE",STR0096}} )//STR0097//"Decisão de desclassificação das novas propostas por apresentarem preços manifestamente superiores aos de mercado ou incompatíveis com os preços fixados por órgãos oficiais;"//"Lei Federal nº 8.666/1993, art. 43, inciso IV, e art. 48, inciso II."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","029"},{"COX_DESC",STR0100},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0099},{"COX_ORDEM","029"},{"COX_DESCDE",STR0100}} )//"Lei Federal nº 8.666/1993, art. 43, inciso IV."//STR0101//"Preço do bem ou serviço contratado compatível com os praticados pelo mercado ou fixados por órgãos oficiais constantes dos registros de preços ou de serviços."
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","030"},{"COX_DESC",STR0102},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0104},{"COX_ORDEM","030"},{"COX_DESCDE",STR0102}} )//STR0103//"Compras de hortifrutigranjeiros, pão e outros gêneros perecíveis"//"Lei Federal nº 8.666/1993, art. 24, inciso XII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","031"},{"COX_DESC",STR0105},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0107},{"COX_ORDEM","031"},{"COX_DESCDE",STR0105}} )//STR0106//"Contratação de instituição brasileira incumbida regimental ou estatutariamente da pesquisa"//"Lei Federal nº 8.666/1993, art. 24, inciso XIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","032"},{"COX_DESC",STR0108},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0110},{"COX_ORDEM","032"},{"COX_DESCDE",STR0108}} )//STR0109//"Contratação de instituição brasileira do ensino ou do desenvolvimento institucional, ou de instituição dedicada à recuperação social do preso"//"Lei Federal nº 8.666/1993, art. 24, inciso XIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","033"},{"COX_DESC",STR0112},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0113},{"COX_ORDEM","033"},{"COX_DESCDE",STR0111}} )//"Aquisição de bens ou serviços nos termos de acordo internacional específico aprovado pelo Congresso Nacional, quando as condições ofertadas forem manifestamente vantajosas para o Poder Público "//"Aquisição de bens ou serviços nos termos de acordo internacional específico aprovado pelo Congresso Nacional, quando as condições ofertadas forem manifestamente vantajosas para o Poder Público"//"Lei Federal nº 8.666/1993, art. 24, inciso XIV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","034"},{"COX_DESC",STR0114},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0116},{"COX_ORDEM","034"},{"COX_DESCDE",STR0114}} )//STR0115//"Aquisição ou restauração de obras de arte e objetos históricos, de autenticidade certificada, desde que compatíveis ou inerentes às finalidades do órgão ou entidade."//"Lei Federal nº 8.666/1993, art. 24, inciso XV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","035"},{"COX_DESC",STR0117},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0119},{"COX_ORDEM","035"},{"COX_DESCDE",STR0118}} )//"Impressão dos diários oficiais, de formulários padronizados de uso da administração, e de edições técnicas oficiais"//"Impressão dos diários oficiais, de formulários padronizados de uso da administração, e de edições técnicas oficiais, bem como para prestação de serviços de informática a pessoa jurídica de direito público interno, por órgãos ou entidades que integrem a Administração Pública, criados para esse fim específico;"//"Lei Federal nº 8.666/1993, art. 24, inciso XVI"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","036"},{"COX_DESC",STR0120},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0122},{"COX_ORDEM","036"},{"COX_DESCDE",STR0120}} )//STR0121//"Aquisição de componentes ou peças de origem nacional ou estrangeira, necessários à manutenção de equipamentos durante o período de garantia técnica,"//"Lei Federal nº 8.666/1993, art. 24, inciso XVII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","037"},{"COX_DESC",STR0123},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0125},{"COX_ORDEM","037"},{"COX_DESCDE",STR0123}} )//STR0124//"Compras ou contratações de serviços para o abastecimento de navios, embarcações, unidades aéreas ou tropas e seus meios de deslocamento quando em estada eventual de curta duração em portos, aeroportos ou localidades diferentes de suas sedes"//"Lei Federal nº 8.666/1993, art. 24, inciso XVIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","038"},{"COX_DESC",STR0126},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0128},{"COX_ORDEM","038"},{"COX_DESCDE",STR0126}} )//STR0127//"Compras de material de uso pelas Forças Armadas mediante parecer de comissão instituída por decreto;"//"Lei Federal nº 8.666/1993, art. 24, inciso XIX"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","039"},{"COX_DESC",STR0130},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0131},{"COX_ORDEM","039"},{"COX_DESCDE",STR0129}} )//"Contratação de associação de portadores de deficiência física, sem fins lucrativos e de comprovada idoneidade "//"Contratação de associação de portadores de deficiência física, sem fins lucrativos e de comprovada idoneidade"//"Lei Federal nº 8.666/1993, art. 24, inciso XX"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","040"},{"COX_DESC",STR0132},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0134},{"COX_ORDEM","040"},{"COX_DESCDE",STR0132}} )//STR0133//"Aquisição de bens e insumos destinados exclusivamente à pesquisa científica e tecnológica com recursos concedidos pela Capes, pela Finep, pelo CNPq ou por outras instituições de fomento a pesquisa credenciadas pelo CNPq para esse fim específico"//"Lei Federal nº 8.666/1993, art. 24, inciso XXI"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","041"},{"COX_DESC",STR0135},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0137},{"COX_ORDEM","041"},{"COX_DESCDE",STR0135}} )//STR0136//"Contratação de fornecimento ou suprimento de energia elétrica e gás natural com concessionário, permissionário ou autorizado, segundo as normas da legislação específica;"//"Lei Federal nº 8.666/1993, art. 24, inciso XXII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","042"},{"COX_DESC",STR0138},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0140},{"COX_ORDEM","042"},{"COX_DESCDE",STR0138}} )//STR0139//"Contratação realizada por empresa pública ou sociedade de economia mista com suas subsidiárias e controladas, para a aquisição ou alienação de bens, prestação ou obtenção de serviços"//"Lei Federal nº 8.666/1993, art. 24, inciso XXIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","043"},{"COX_DESC",STR0141},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0143},{"COX_ORDEM","043"},{"COX_DESCDE",STR0141}} )//STR0142//"Celebração de contratos de prestação de serviços com as organizações sociais, qualificadas no âmbito das respectivas esferas de governo, para atividades contempladas no contrato de gestão"//"Lei Federal nº 8.666/1993, art. 24, inciso XXIV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","044"},{"COX_DESC",STR0144},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0146},{"COX_ORDEM","044"},{"COX_DESCDE",STR0144}} )//STR0145//"Contratação realizada por Instituição Científica e Tecnológica - ICT ou por agência de fomento para a transferência de tecnologia e para o licenciamento de direito de uso ou de exploração de criação protegida."//"Lei Federal nº 8.666/1993, art. 24, inciso XXV"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","045"},{"COX_DESC",STR0147},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0149},{"COX_ORDEM","045"},{"COX_DESCDE",STR0147}} )//STR0148//"Celebração de contrato de programa com ente da Federação ou com entidade de sua administração indireta, para a prestação de serviços públicos de forma associada ou em convênio de cooperação."//"Lei Federal nº 8.666/1993, art. 24, inciso XXVI"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","046"},{"COX_DESC",STR0150},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0152},{"COX_ORDEM","046"},{"COX_DESCDE",STR0150}} )//STR0151//"Contratação da coleta, processamento e comercialização de resíduos sólidos urbanos recicláveis ou reutilizáveis, em áreas com sistema de coleta seletiva de lixo"//"Lei Federal nº 8.666/1993, art. 24, inciso XXVII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","047"},{"COX_DESC",STR0153},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0155},{"COX_ORDEM","047"},{"COX_DESCDE",STR0153}} )//STR0154//"Fornecimento de bens e serviços, produzidos ou prestados no País, que envolvam, cumulativamente, alta complexidade tecnológica e defesa nacional, mediante parecer de comissão especialmente designada pela autoridade máxima do órgão."//"Lei Federal nº 8.666/1993, art. 24, inciso XXVIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","048"},{"COX_DESC",STR0157},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0158},{"COX_ORDEM","048"},{"COX_DESCDE",STR0156}} )//"Aquisição de bens e contratação de serviços para atender aos contingentes militares das Forças Singulares brasileiras empregadas em operações de paz no exterior, necessariamente justificadas quanto ao preço e à escolha do fornecedor ou executante e ratificadas pelo Comandante da Força."//"Aquisição de bens e contratação de serviços para atender aos contingentes militares"//"Lei Federal nº 8.666/1993, art. 24, inciso XXIX"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","049"},{"COX_DESC",STR0159},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0161},{"COX_ORDEM","049"},{"COX_DESCDE",STR0159}} )//STR0160//"Contratação de instituição ou organização para a prestação de serviços de assistência técnica e extensão rural no âmbito do Programa Nacional de Assistência Técnica e Extensão Rural na Agricultura Familiar e na Reforma Agrária"//"Lei Federal nº 8.666/1993, art. 24, inciso XXX"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","050"},{"COX_DESC",STR0162},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0164},{"COX_ORDEM","050"},{"COX_DESCDE",STR0162}} )//STR0163//"Contratações visando ao cumprimento do disposto nos arts. 3º, 4º, 5ª e 20º da Lei no 10.973, de 2 de dezembro de 2004, observados os princípios gerais de contratação dela constantes."//"Lei Federal nº 8.666/1993, art. 24, inciso XXXI"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","051"},{"COX_DESC",STR0165},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0167},{"COX_ORDEM","051"},{"COX_DESCDE",STR0165}} )//STR0166//"Contratação em que houver transferência de tecnologia de produtos estratégicos para o Sistema Único de Saúde - SUS"//"Lei Federal nº 8.666/1993, art. 24, inciso XXXII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","052"},{"COX_DESC",STR0168},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0170},{"COX_ORDEM","052"},{"COX_DESCDE",STR0168}} )//STR0169//"Contratação de entidades privadas sem fins lucrativos, para a implementação de cisternas ou outras tecnologias sociais de acesso à água para consumo humano e produção de alimentos"//"Lei Federal nº 8.666/1993, art. 24, inciso XXXIII"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","053"},{"COX_DESC",STR0171},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0173},{"COX_ORDEM","053"},{"COX_DESCDE",STR0171}} )//STR0172//"Aquisição de materiais, equipamentos, ou gêneros que só possam ser fornecidos por produtor, empresa ou representante comercial exclusivo"//"Lei Federal nº 8.666/1993, art. 25, inciso I"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","054"},{"COX_DESC",STR0174},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0176},{"COX_ORDEM","054"},{"COX_DESCDE",STR0174}} )//STR0175//"Contratação de serviços técnicos de natureza singular, com profissionais ou empresas de notória especialização, vedada a inexigibilidade para serviços de publicidade e divulgação"//"Lei Federal nº 8.666/1993, art. 25, inciso II"
	AADD(aGrid1,{{"COX_CODIGO","ELA"},{"COX_ITEM","055"},{"COX_DESC",STR0177},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0179},{"COX_ORDEM","055"},{"COX_DESCDE",STR0177}} )//STR0178//"Contratação de profissional de qualquer setor artístico, diretamente ou através de empresário exclusivo, desde que consagrado pela crítica especializada ou pela opinião pública"//"Lei Federal nº 8.666/1993, art. 25, inciso III"
	
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
	// Check Lists para Análise do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ANA"},{"COV_DESC",STR0180}} }//"Análise do Edital"
	
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","001"},{"COX_DESC",STR0182},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0181},{"COX_ORDEM","001"},{"COX_DESCDE",STR0182}} )//"Lei nº 8.666/93, art. 22 e seus parágrafos e art. 23 e seus parágrafos."//STR0183//"Observar se estão sendo adotados modalidades e regime de execução apropriado."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","002"},{"COX_DESC",STR0185},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0184},{"COX_ORDEM","002"},{"COX_DESCDE",STR0185}} )//"Lei nº 8.666/93, art. 40, I."//STR0186//"Verificar se há caracterização adequada do objeto licitado."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","003"},{"COX_DESC",STR0188},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0187},{"COX_ORDEM","003"},{"COX_DESCDE",STR0188}} )//"Lei nº 8.666/93, art. 23, § 5º."//STR0189//"Não fracionar despesas para alterar a modalidade de licitação."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","004"},{"COX_DESC",STR0191},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0190},{"COX_ORDEM","004"},{"COX_DESCDE",STR0192}} )//"Lei nº 8.666/93, art. 33."//"Verificar se é pertinente o uso do instituto do consórcio de empresas. "//"Verificar se é pertinente o uso do instituto do consórcio de empresas."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","005"},{"COX_DESC",STR0193},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0195},{"COX_ORDEM","005"},{"COX_DESCDE",STR0193}} )//STR0194//"Atentar-se há no edital aplicação de reajustamento com índices setoriais."//"Lei nº 8.666/93, art. 40, XI."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","006"},{"COX_DESC",STR0197},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0196},{"COX_ORDEM","006"},{"COX_DESCDE",STR0197}} )//"Lei nº 8.666/93, art. 38, VI, parágrafo único."//STR0198//"Verificar se o edital e a minuta do contrato estão aprovados previamente por parecer jurídico."
	AADD(aGrid1,{{"COX_CODIGO","ANA"},{"COX_ITEM","007"},{"COX_DESC",STR0199},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0201},{"COX_ORDEM","007"},{"COX_DESCDE",STR0199}} )//STR0200//"A licitação foi formalizada por meio de processo administrativo, devidamente autuado, protocolado e numerado?"//"Lei n.º 8.666/93, art. 38, caput"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"PUB")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Publicação do Edital
	//-----------------------------------------------
	
	aField := { {{"COV_CODIGO","PUB"},{"COV_DESC",STR0202}} }//"Publicação do Edital"
	
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","001"},{"COX_DESC",STR0204},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0203},{"COX_ORDEM","001"},{"COX_DESCDE","    "}})//"Art. 38 - II"//"Foi informado o comprovante das publicações do edital resumido, na forma do art. 21 desta Lei, ou da entrega do convite ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","002"},{"COX_DESC",STR0206},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0205},{"COX_ORDEM","002"},{"COX_DESCDE"," "}})//"Art. 38 - III"//"Foi informado o ato de designação da comissão de licitação, do leiloeiro administrativo ou oficial, ou do responsável pelo  convite ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","003"},{"COX_DESC",STR0208},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0207},{"COX_ORDEM","003"},{"COX_DESCDE"," "}})//"Art. 40"//"Foi informado o local, dia e hora para recebimento da documentação e proposta, bem como para início da abertura dos envelopes ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","004"},{"COX_DESC",STR0210},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0209},{"COX_ORDEM","004"},{"COX_DESCDE"," "}})//"Art. 40 - IV"//"Foi informado o local onde poderá ser examinado e adquirido o projeto básico ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","005"},{"COX_DESC",STR0212},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0211},{"COX_ORDEM","005"},{"COX_DESCDE"," "}})//"Art. 40 - V"//"Foi informado se há projeto executivo disponível na data da publicação do edital de licitação e o local onde possa ser examinado e adquirido ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","006"},{"COX_DESC",STR0214},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0213},{"COX_ORDEM","006"},{"COX_DESCDE"," "}})//"Art. 40 - VII"//"Foi informado o critério para julgamento, com disposições claras e parâmetros objetivos ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","007"},{"COX_DESC",STR0217},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0216},{"COX_ORDEM","007"},{"COX_DESCDE",STR0215}})//"Art. 40 - XI - critério de reajuste, que deverá retratar a variação efetiva do custo de produção, admitida a adoção de índices específicos ou setoriais, desde a data prevista para apresentação da proposta, ou do orçamento a que essa proposta se referir, até a data do adimplemento de cada parcela;"//"Art. 40 - XI"//"Foi informado o critério de reajuste ?"
	AADD(aGrid1,{{"COX_CODIGO","PUB"},{"COX_ITEM","008"},{"COX_DESC",STR0220},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0219},{"COX_ORDEM","008"},{"COX_DESCDE",STR0218+ CRLF +STR0221 + CRLF + STR0222 + CRLF + STR0223 + CRLF + STR0224 + CRLF + STR0225}})//"Art. 40 - XIV - condições de pagamento, prevendo:"//"Art. 40 - XIV"//"Foi informado condições de pagamento ?"//"a) prazo de pagamento não superior a trinta dias, contado a partir da data final do período de adimplemento de cada parcela;"//"b) cronograma de desembolso máximo por período, em conformidade com a disponibilidade de recursos financeiros;"//"c) critério de atualização financeira dos valores a serem pagos, desde a data final do período de adimplemento de cada parcela até a data do efetivo pagamento;"//"d) compensações financeiras e penalizações, por eventuais atrasos, e descontos, por eventuais antecipações de pagamentos;"//"e) exigência de seguros, quando for o caso;"
	
	AADD(aGrid,aGrid1)
		
	oImport:Import( aField , aGrid )
	oImport:Commit()
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"HAB")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Habilitação
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","HAB"},{"COV_DESC",STR0226}} }//"Habilitação"
	
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","001"},{"COX_DESC",STR0229},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0227},{"COX_ORDEM","001"},{"COX_DESCDE",STR0228}} )//"Lei nº 8.666/93, art. 3º, caput, e arts. 27 a 31."//"Não incluir no edital cláusula restritiva à ampla competição e incompatível com a obra que se pretende contratar.    "//"Não incluir no edital cláusula restritiva à ampla competição e incompatível com a obra que se pretende contratar."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","002"},{"COX_DESC",STR0231},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0232},{"COX_ORDEM","002"},{"COX_DESCDE",STR0230}} )//"Exigir no edital as comprovações das proponentes de qualificação jurídica, técnica, econômico-financeira, regularidade fiscal e cumprimento do disposto no inciso XXXIII do art. 7º da Constituição Federal. Constituição Federal, art. 7º, XXXIII e art. 37, XXI.    "//"Exigir no edital as comprovações das proponentes de qualificação jurídica, técnica, econômico-financeira, regularidade fiscal"//"Lei nº 8.666/93, art. 3º, caput, e arts. 27 a 31."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","003"},{"COX_DESC",STR0234},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0233},{"COX_ORDEM","003"},{"COX_DESCDE",STR0234}} )//"Lei nº 8.666/93, art. 9º."//STR0235//"Na fase de habilitação, observar se a proponente teve algum tipo de participação na elaboração dos projetos ou é servidor público do órgão contratante ou responsável pela licitação."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","004"},{"COX_DESC",STR0237},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0236},{"COX_ORDEM","004"},{"COX_DESCDE",STR0237}} )//"Lei nº 8.666/93, art. 43, I, e § 2º."//STR0238//"Na fase de habilitação, observar se constam as rubricas de participantes nos envelopes de habilitação e de proposta de preço."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","005"},{"COX_DESC",STR0240},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0239},{"COX_ORDEM","005"},{"COX_DESCDE",STR0240}} )//"Lei nº 8.666/93, art. 109."//STR0241//"Respeitar os prazos recursais."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","006"},{"COX_DESC",STR0243},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0242},{"COX_ORDEM","006"},{"COX_DESCDE",STR0243}} )//"Lei nº 8.666/93, art. 38, V e arts. 43, § 1º."//STR0244//"Providenciar, nos seus devidos tempos, as atas das fases de julgamento da habilitação e das propostas de preços."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","007"},{"COX_DESC",STR0245},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0247},{"COX_ORDEM","007"},{"COX_DESCDE",STR0245}} )//STR0246//"Foi solicitado o documento de identidade, no caso de pessoa física?"//"Lei n.º 8.666/93, art. 28, I"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","008"},{"COX_DESC",STR0248},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0250},{"COX_ORDEM","008"},{"COX_DESCDE",STR0248}} )//STR0249//"Foi solicitado o registro comercial, no caso de empresa individual?"//"Lei n.º 8.666/93, art. 28, II"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","009"},{"COX_DESC",STR0251},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0253},{"COX_ORDEM","009"},{"COX_DESCDE",STR0251}} )//STR0252//"Foi solicitado o ato constitutivo, estatuto ou contrato social em vigor, devidamente registrado, em se tratando de sociedades comerciais, e, no caso de sociedades por ações, acompanhado de documentos de eleição de seus administradores?"//"Lei n.º 8.666/93, art. 28, III"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","010"},{"COX_DESC",STR0254},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0256},{"COX_ORDEM","010"},{"COX_DESCDE",STR0254}} )//STR0255//"Foi solicitada a inscrição do ato constitutivo, no caso de sociedades civis, acompanhada de prova de diretoria em exercício?"//"Lei n.º 8.666/93, art. 28, IV"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","011"},{"COX_DESC",STR0257},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0259},{"COX_ORDEM","011"},{"COX_DESCDE",STR0257}} )//STR0258//"Foi solicitado o decreto de autorização, em se tratando de empresa ou sociedade estrangeira em funcionamento no País, e ato de registro ou autorização para funcionamento expedido pelo órgão competente, quando a atividade assim o exigir?"//"Lei n.º 8.666/93, art. 28, V"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","012"},{"COX_DESC",STR0260},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0262},{"COX_ORDEM","012"},{"COX_DESCDE",STR0260}} )//STR0261//"Foi solicitada a prova de inscrição no Cadastro de Pessoas Físicas (CPF) ou no Cadastro Nacional de Pessoas Jurídicas (CNPJ)?"//"Lei n.º 8.666/93, art. 29, I"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","013"},{"COX_DESC",STR0263},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0265},{"COX_ORDEM","013"},{"COX_DESCDE",STR0263}} )//STR0264//"Foi solicitada prova de inscrição no cadastro de contribuintes estadual ou municipal , se houver, relativo ao domicílio ou sede do licitante, pertinente ao seu ramo de atividade e compatível com o objeto contratual?"//"Lei n.º 8.666/93, art. 29, II"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","014"},{"COX_DESC",STR0267},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0268},{"COX_ORDEM","014"},{"COX_DESCDE",STR0266}} )//"Foi solicitada, conforme o caso, prova de regularidade para com a Fazenda Federal (Certidões Negativas – Dívida Ativa/PFN e Tributos Administrados pela Receita Federal), Estadual e Municipal do domicílio ou sede do licitante, ou outra equivalente, na forma da lei?"//"Foi solicitada, conforme o caso, prova de regularidade para com a Fazenda Federal (Certidões Negativas – Dívida Ativa/PFN e Tributos Administrados pela Receita Federal), Estadual e Municipal do domicílio ou sede do licitante..."//"Lei n.º 8.666/93, art. 29, III"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","015"},{"COX_DESC",STR0269},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0271},{"COX_ORDEM","015"},{"COX_DESCDE",STR0269}} )//STR0270//"Foi solicitada prova de regularidade relativa à Seguridade Social (INSS)"//"Lei n.º 8.666/93, art. 29, IV e CF, art. 195, § 2.º"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","016"},{"COX_DESC",STR0272},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0274},{"COX_ORDEM","016"},{"COX_DESCDE",STR0272}} )//STR0273//"Foi solicitada prova de regularidade relativa ao Fundo de Garantia por Tempo de Serviço (FGTS)"//"Lei n.º 8.666/93, art. 29, IV"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","017"},{"COX_DESC",STR0276},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0275},{"COX_ORDEM","017"},{"COX_DESCDE",STR0276}} )//"Lei n.º 8.666/93, art. 30, I, II, III e IV"//STR0277//"registro ou inscrição na entidade profissional competente"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","018"},{"COX_DESC",STR0280},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0278},{"COX_ORDEM","018"},{"COX_DESCDE",STR0279}} )//"Lei n.º 8.666/93, art. 30, I, II, III e IV"//"comprovação de aptidão para desempenho de atividade pertinente e compatível em características, quantidades e prazos com o objeto da licitação, e indicação das instalações e do aparelhamento e do pessoal técnico adequados e disponíveis para a realização do objeto da licitação, bem como da qualificação de cada um dos membros da equipe técnica que se responsabilizará pelos trabalhos"//"comprovação de aptidão para desempenho de atividade pertinente e compatível em características, quantidades e prazos com o objeto da licitação..."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","019"},{"COX_DESC",STR0283},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0281},{"COX_ORDEM","019"},{"COX_DESCDE",STR0282}} )//"Lei n.º 8.666/93, art. 30, I, II, III e IV"//"comprovação, fornecida pelo órgão licitante, de que recebeu os documentos, e, quando exigido, de que tomou conhecimento de todas as informações e das condições locais para o cumprimento das obrigações objeto da licitação"//"comprovação, fornecida pelo órgão licitante, de que recebeu os documentos, e, quando exigido, de que tomou conhecimento de todas as informações..."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","020"},{"COX_DESC",STR0285},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0284},{"COX_ORDEM","020"},{"COX_DESCDE",STR0285}} )//"Lei n.º 8.666/93, art. 30, I, II, III e IV"//STR0286//"prova de atendimento de requisitos previstos em lei especial, quando for o caso"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","021"},{"COX_DESC",STR0288},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0287},{"COX_ORDEM","021"},{"COX_DESCDE",STR0288}} )//"Lei n.º 8.666/93, art. 30, § 1.º, I"//STR0289//"Não houve a fixação de quantidades mínimas e prazos máximos para a capacitação técnico-profissional?"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","022"},{"COX_DESC",STR0291},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0290},{"COX_ORDEM","022"},{"COX_DESCDE",STR0291}} )//"Lei n.º 8.666/93, art. 30, § 1.º, I"//STR0292//"Não houve a exigência de itens irrelevantes e sem valor significativo em relação ao objeto em licitação para efeito de capacitação técnico-profissional?"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","023"},{"COX_DESC",STR0294},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0293},{"COX_ORDEM","023"},{"COX_DESCDE",STR0294}} )//"Lei n.º 8.666/93, art. 30, § 5.º"//STR0295//"Não houve a exigência de comprovação de atividade ou de aptidão com limitações de tempo ou de época ou ainda em locais específicos, ou quaisquer outras não previstas na legislação, que inibam a participação na licitação."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","024"},{"COX_DESC",STR0298},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0296},{"COX_ORDEM","024"},{"COX_DESCDE",STR0297}} )//"Lei n.º 8.666/93, art. 31, I, II e III, combinado com os §§ 2.º, 3.º, 4.º e 5.º do mesmo artigo"//"balanço patrimonial e demonstrações contábeis do último exercício social, já exigíveis e apresentados na forma da lei, que comprovem a boa situação financeira da empresa, vedada a sua substituição por balancetes ou balanços provisórios, podendo ser atualizados por índices oficiais quando encerrado há mais de 3 meses da data de apresentação da proposta"//"balanço patrimonial e demonstrações contábeis do último exercício social, já exigíveis e apresentados na forma da lei, que comprovem a boa situação financeira da empresa, vedada a sua substituição por balancetes ou balanços provisórios..."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","025"},{"COX_DESC",STR0300},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0299},{"COX_ORDEM","025"},{"COX_DESCDE",STR0300}} )//"Lei n.º 8.666/93, art. 31, I, II e III, combinado com os §§ 2.º, 3.º, 4.º e 5.º do mesmo artigo"//STR0301//"certidão negativa de falência ou concordata expedida pelo distribuidor da sede da pessoa jurídica, ou de execução patrimonial, expedida no domicílio da pessoa física"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","026"},{"COX_DESC",STR0303},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0302},{"COX_ORDEM","026"},{"COX_DESCDE",STR0303}} )//"Lei n.º 8.666/93, art. 31, I, II e III, combinado com os §§ 2.º, 3.º, 4.º e 5.º do mesmo artigo"//STR0304//"garantia limitada a 1% (um por cento) do valor estimado do objeto da contratação ou capital mínimo/valor do patrimônio líquido inferior a 10% (dez por cento) do valor estimado da contratação."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","027"},{"COX_DESC",STR0306},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0305},{"COX_ORDEM","027"},{"COX_DESCDE",STR0306}} )//"Lei n.º 8.666/93, art. 31, I, II e III, combinado com os §§ 2.º, 3.º, 4.º e 5.º do mesmo artigo"//STR0307//"relação dos compromissos assumidos pelo licitante que importem diminuição da capacidade operativa ou absorção de disponibilidade financeira, calculada esta em função do patrimônio líquido atualizado e sua capacidade de rotação"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","028"},{"COX_DESC",STR0309},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0308},{"COX_ORDEM","028"},{"COX_DESCDE",STR0309}} )//"Lei n.º 8.666/93, art. 31, I, II e III, combinado com os §§ 2.º, 3.º, 4.º e 5.º do mesmo artigo"//STR0310//"índices contábeis que comprovem a boa situação financeira do licitante."
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","029"},{"COX_DESC",STR0312},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0311},{"COX_ORDEM","029"},{"COX_DESCDE",STR0312}} )//"Lei n.º 8.666/93, art. 31, § 2.º"//STR0313//"Não houve a exigência cumulativa de garantia de proposta com valor de capital mínimo/patrimônio líquido (item c anterior)?"
	AADD(aGrid1,{{"COX_CODIGO","HAB"},{"COX_ITEM","030"},{"COX_DESC",STR0315},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0314},{"COX_ORDEM","030"},{"COX_DESCDE",STR0315}} )//"Lei n.º 8.666/93, art. 31, § 5.º"//STR0316//"Os índices contábeis e seus valores, se exigidos, são os usualmente adotados para correta avaliação de situação financeira suficiente ao cumprimento das obrigações decorrentes da licitação?"
	
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
	
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","001"},{"COX_DESC",STR0318},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0320},{"COX_ORDEM","001"},{"COX_DESCDE",STR0318}} )//STR0319//"Exigir no edital a apresentação da composição detalhada do BDI praticado pelos proponentes."//"Lei nº 8.666/93, art. 44, caput e §3º."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","002"},{"COX_DESC",STR0321},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0323},{"COX_ORDEM","002"},{"COX_DESCDE",STR0321}} )//STR0322//"Exigir a composição analítica dos preços unitários."//"Lei nº 8.666/93, art. 44, caput e §3º."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","003"},{"COX_DESC",STR0324},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0326},{"COX_ORDEM","003"},{"COX_DESCDE",STR0324}} )//STR0325//"Comprovar se a forma de participação e apresentação das propostas, bem como os critérios de julgamento estão previstos objetivamente no instrumento convocatório."//"Lei nº 8.666/93, art. 3º, art. 40, VI e VII, e art. 44."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","004"},{"COX_DESC",STR0328},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0327},{"COX_ORDEM","004"},{"COX_DESCDE",STR0328}} )//"Lei nº 8.666/93, art. 44 e art. 45, caput."//STR0329//"No ato de recebimento das propostas, atentar-se há compatibilidade entre as propostas de preços das licitantes e o orçamento básico."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","005"},{"COX_DESC",STR0331},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0330},{"COX_ORDEM","005"},{"COX_DESCDE",STR0331}} )//"Lei nº 8.666/93, art. 43, IV e art. 45, caput."//STR0332//"Verificar se há compatibilidade das propostas com as regras previstas no edital."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","006"},{"COX_DESC",STR0334},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0333},{"COX_ORDEM","006"},{"COX_DESCDE",STR0334}} )//"Lei nº 8.666/93, art. 44 § 3º e art. 48 II."//STR0335//"Verificar se há compatibilidade entre os custos orçados pelo órgão e licitantes com os praticados no mercado."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","007"},{"COX_DESC",STR0337},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0336},{"COX_ORDEM","007"},{"COX_DESCDE",STR0337}} )//"Lei nº 8.666/93, art. 44, § 3º e art. 48, II."//STR0338//"Verificar se há preços inexequíveis."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","008"},{"COX_DESC",STR0340},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0339},{"COX_ORDEM","008"},{"COX_DESCDE",STR0340}} )//"Lei nº 5.194/66, art. 13 e art. 14."//STR0341//"Verificar se as propostas apresentadas estão assinadas por profissional legalmente habilitado e identificado."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","009"},{"COX_DESC",STR0343},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0342},{"COX_ORDEM","009"},{"COX_DESCDE",STR0343}} )//"Lei nº 8.666/93, art. 109."//STR0344//"Respeitar os prazos recursais."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","010"},{"COX_DESC",STR0346},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0345},{"COX_ORDEM","010"},{"COX_DESCDE",STR0346}} )//"Lei nº 8.666/93, art. 38, V e arts. 43, § 1º."//STR0347//"Providenciar, nos seus devidos tempos, as atas das fases de julgamento da habilitação e das propostas de preços."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","011"},{"COX_DESC",STR0349},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0348},{"COX_ORDEM","011"},{"COX_DESCDE",STR0349}} )//"Lei nº 8.666/93, art. 38, IV."//STR0350//"Verificar se estão sendo juntados os originais das propostas e dos documentos no processo."
	AADD(aGrid1,{{"COX_CODIGO","JUL"},{"COX_ITEM","012"},{"COX_DESC",STR0352},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0351},{"COX_ORDEM","012"},{"COX_DESCDE",STR0352}} )//"Lei nº 8.666/93, art. 38, IX."//STR0353//"Se for o caso, atentar-se há decisão de anulação ou revogação devidamente fundamentada."
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"HOM")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Homologação
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","HOM"},{"COV_DESC",STR0354}} }//"Homologação"
	
	AADD(aGrid1, {{"COX_CODIGO","HOM"},{"COX_ITEM","001"},{"COX_DESC",STR0356},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0355},{"COX_ORDEM","001"},{"COX_DESCDE",STR0356}} )//" Lei nº 8.666/03, art. 38, VII."//STR0357//"Providenciar ato de homologação e adjudicação do objeto da licitação."
	AADD(aGrid1, {{"COX_CODIGO","HOM"},{"COX_ITEM","002"},{"COX_DESC",STR0359 },{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0358},{"COX_ORDEM","002"},{"COX_DESCDE",STR0359}} )//" Lei nº 8.666/93, art. 38, IX."//STR0360//"Se for o caso, atentar-se há decisão de anulação ou revogação devidamente fundamentada."
	
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {}
EndIf

If !COV->(MsSeek(xFilial('COV')+"ADJ")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Adjudicação
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ADJ"},{"COV_DESC",STR0361}} }//"Adjudicação"
	
	
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","001"},{"COX_DESC",STR0363},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0362},{"COX_ORDEM","001"},{"COX_DESCDE","    "}})//"Art. 55"//"O contrato contempla todas as cláusulas necessárias previstas no art. 55 da Lei Federal nº 8.666, de 1993?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","002"},{"COX_DESC",STR0365},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0364},{"COX_ORDEM","002"},{"COX_DESCDE",STR0366}})//"Art. 55, inciso I"//"O objeto do contrato apresenta elementos característicos de forma clara e está de acordo com o processo que deu origem ao contrato?"//"Para a contratação de obras e serviços pela administração pública estadual que envolva a aquisição direta e o emprego de produtos e subprodutos de madeira de origem nativa, deverão ser observados os dispostos no Decreto nº 44.903, de 24 de setembro de 2008. Há determinados contratos nos quais o objeto estará detalhado no anexo do contrato."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","003"},{"COX_DESC",STR0368},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0367},{"COX_ORDEM","003"},{"COX_DESCDE","    "}})//"Art. 55, inciso II"//"O regime de execução ou a forma de fornecimento contém elementos suficientes para a execução do contrato no prazo estabelecido?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","004"},{"COX_DESC",STR0371},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0369},{"COX_ORDEM","004"},{"COX_DESCDE",STR0370}})//"Art. 55, inciso III"//"As cláusulas econômico-financeiras e monetárias dos contratos administrativos não poderão ser alteradas sem prévia concordância do contratado, conforme disposto no art. 58, § 1º da Lei Federal nº 8.666/1993. Alguns contratos expressam o valor total estimado em outra cláusula e na do preço apenas o valor mensal (estimado ou não). Em outros, remetem aos anexos que pormenorizam cálculos mais complexos para demonstração da composição do preço do material ou serviço contratado."//"O preço está compatível com o valor estimado informado no processo que deu origem ao contrato?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","005"},{"COX_DESC",STR0373},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0372},{"COX_ORDEM","005"},{"COX_DESCDE",STR0374}})//"Art. 55, inciso III"//"As condições de pagamento estabelecem os requisitos necessários para o pagamento ao contratado?"//"São exemplos de requisitos necessários: a apresentação de documento fiscal do fornecimento de material ou execução de serviço, conferido e atestado pela Administração; apresentação de termo de medição no caso de acompanhamento de realização de obras; planilhas; recibo de aluguel: planilhas pormenorizadas de custos; demonstrações de cumprimento das obrigações com encargos sociais e trabalhistas com as devidas retenções tributárias dentre outras pertinentes ao tipo de contrato."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","006"},{"COX_DESC",STR0377},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0375},{"COX_ORDEM","006"},{"COX_DESCDE",STR0376}})//"Art. 55, inciso III"//"Está cláusula também pode ser denominada de cláusula de revisão ou repactuação e poderá prever as hipóteses contempladas no art. 65, inciso II, letra “d”, da Lei nº 8.666/93 e demais condições estabelecidas."//"Os critérios, a data-base e a periodicidade do reajustamento de preços são compatíveis com os padrões de mercado?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","007"},{"COX_DESC",STR0378},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0379},{"COX_ORDEM","007"},{"COX_DESCDE","    "}})//"A vigência do contrato é por tempo determinado?"//"Art. 57, § 3º"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","008"},{"COX_DESC",STR0381},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0380},{"COX_ORDEM","008"},{"COX_DESCDE","    "}})//"Art. 55, inciso IV"//"O contrato prevê os prazos de início das etapas de execução, de entrega, de conclusão, de observação (acompanhamento, fiscalização ou monitoramento) e de recebimento definitivo, conforme o caso?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","009"},{"COX_DESC",STR0382},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0383},{"COX_ORDEM","009"},{"COX_DESCDE",STR0384}})//"A cláusula que define o crédito pelo qual ocorrerá a despesa, com a indicação da classificação funcional programática e da categoria econômica está compatível com o processo que deu origem ao contrato...?"//"Art. 55, inciso V"//"Devem-se considerar as questões de apostilamento necessárias à manutenção do contrato."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","010"},{"COX_DESC",STR0385},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0386},{"COX_ORDEM","010"},{"COX_DESCDE","    "}})//"A cláusula que trata das garantias objetiva assegurar a plena execução do contrato, quando exigidas?"//"Art. 55, inciso VI"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","011"},{"COX_DESC",STR0388},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0387},{"COX_ORDEM","011"},;//"Art. 56, caput e § 1º"//"No caso de exigência de garantia, a critério da Administração, foi aplicada uma das seguintes modalidades de garantia prevista no contrato: caução, seguro-garantia ou fiança bancária?"
	{"COX_DESCDE",STR0389+STR0551}})//"Conforme Lei Federal nº 8.666/1993, art. 56, §§ 2º ao 5º: a) a garantia não excederá a cinco por cento (5%) do valor do contrato e terá seu valor atualizado nas mesmas condições daquele, ressalvado o previsto no item a seguir, quando for o caso; b) o limite de garantia poderá ser de até dez por cento (10%) do valor do contrato para obras, serviços e fornecimentos de grande vulto envolvendo alta complexidade técnica e riscos financeiros consideráveis, demonstrados através de parecer tecnicamente aprovado pela autoridade competente; c) a garantia será liberada ou restituída após a execução do contrato, atualizada monetariamente quando em dinheiro; d) a garantia deverá ser acrescida do valor correspondente aos bens entregues pela Administração por meio do contrato, quando o contratado for depositário."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","012"},{"COX_DESC",STR0390},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0391},{"COX_ORDEM","012"},{"COX_DESCDE","    "}})//"A cláusula dos direitos e das responsabilidades (ou das obrigações entre as partes) estabelece obrigações que condicionem a organização, direção, controle, execução e ou fiscalização do contrato?"//"Art. 55, inciso VII"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","013"},{"COX_DESC",STR0392},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG","    "},{"COX_ORDEM","013"},{"COX_DESCDE",STR0393+STR0552}})//"A cláusula de rescisão está de acordo com o art. 79 da Lei Federal nº 8.666, de 1993?"//"A rescisão do contrato poderá ser: a) determinada por ato unilateral e escrito da Administração, nos casos enumerados nos incisos I a XII e XVII do art. 78 da Lei Federal nº 8.666/1993; b) amigável, por acordo entre as partes, reduzida a termo no processo da licitação, desde que haja conveniência para a Administração; c) judicial, nos termos da legislação. A rescisão administrativa ou amigável deverá ser precedida de autorização escrita e fundamentada da autoridade competente."
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","014"},{"COX_DESC",STR0396},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0394},{"COX_ORDEM","014"},{"COX_DESCDE",STR0395}})//"Art. 55, inciso IX"//"Geralmente essa condição é mencionada na cláusula de penalidades. A inexecução total ou parcial do contrato enseja a sua rescisão, com as conseqüências contratuais e as previstas em lei ou regulamento, conforme disposto no art. 77 da Lei Federal nº 8.666/1993."//"Há no contrato elementos que indiquem o reconhecimento dos direitos da Administração, em caso de rescisão administrativa por inexecução total ou parcial do contrato?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","015"},{"COX_DESC",STR0398},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0397},{"COX_ORDEM","015"},{"COX_DESCDE","    "}})//"Art. 55, § 2º"//"Há no contrato indicação do foro na sede da Administração para dirimir questões contratuais, salvo nos casos dispostos no § 6º do art. 32 da Lei Federal nº 8.666/1993?"
	AADD(aGrid1,{{"COX_CODIGO","ADJ"},{"COX_ITEM","016"},{"COX_DESC",STR0400},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0399},{"COX_ORDEM","016"},{"COX_DESCDE","    "}})//"Art. 61, caput"//"O Contrato contempla: os nomes das partes e representantes, finalidade, o ato da lavratura, o número do processo da dispensa ou da inexigibilidade...?"
	
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
	
	AADD(aGrid1, {{"COX_CODIGO","ASA"},{"COX_ITEM","001"},{"COX_DESC",STR0544},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0543},{"COX_ORDEM","001"},{"COX_DESCDE","    "}} )//"Os fornecedores classificados assinaram a Ata de Registro de Preços, dentro do prazo e condições estabelecidos no instrumento convocatório?"//"Decreto nº 7.892/2013 Art. 13"
	AADD(aGrid1, {{"COX_CODIGO","ASA"},{"COX_ITEM","002"},{"COX_DESC",STR0546},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0545},{"COX_ORDEM","002"},{"COX_DESCDE","    "}} )//"Foi cumprido os requisitos de publicidade?"//"Decreto nº 7.892/2013 Art. 14"
	
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
	// Check Lists para Elaboração do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","EDS"},{"COV_DESC",STR0401}} }//"Elaboração RLC"
	
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","001"},{"COX_DESC",STR0402},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0404},{"COX_ORDEM","001"},{"COX_DESCDE",STR0402}} )//STR0403//"Designar comissão de licitação ou do responsável pelo convite."//"RLC Cap. II Art. 4 Inciso IV"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","002"},{"COX_DESC",STR0406},{"COX_PROPI","1"},{"COX_COND",""},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0407},{"COX_ORDEM","002"},{"COX_DESCDE",STR0405}} )//"Atentar-se o preâmbulo do edital define o número de ordem em série anual, o nome da repartição interessada e de seu setor, a modalidade, o regime de execução e o tipo da licitação, a menção de que será regida pela Lei nº 8.666/93, o local, dia e hora para recebimento da documentação e proposta, bem como para início da abertura dos envelopes."//"Atentar-se o preâmbulo do edital..."//"RLC Cap. VI Art. 14 Inciso I ao V"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","003"},{"COX_DESC",STR0408},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0410},{"COX_ORDEM","003"},{"COX_DESCDE",STR0408}} )//STR0409//"Indicar no instrumento convocatório os recursos para a despesa e comprovar a existência de recursos orçamentários que assegurem o pagamento da obrigação."//"RLC Cap. VI Art. 13"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","004"},{"COX_DESC",STR0411},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0413},{"COX_ORDEM","004"},{"COX_DESCDE",STR0411}} )//STR0412//"Anexar ao edital os projetos, a minuta do contrato, as especificações técnicas complementares e as normas de execução pertinentes."//"RLC Cap. VI Art. 14 Paragr. 2°"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","005"},{"COX_DESC",STR0414},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0416},{"COX_ORDEM","005"},{"COX_DESCDE",STR0414}} )//STR0415//"Observar se o objeto é dividido em parcelas, com vistas ao melhor aproveitamento dos recursos do mercado e à ampla competição, sem perda de economia de escala."//"RLC Cap. II Art. 4 Inciso III"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","006"},{"COX_DESC",STR0417},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0419},{"COX_ORDEM","006"},{"COX_DESCDE",STR0417}} )//STR0418//"Incluir no edital critério de aceitabilidade de preços unitário e global máximo."//"RLC Cap. VI Art. 20 Inciso XII"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","007"},{"COX_DESC",STR0420},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0422},{"COX_ORDEM","007"},{"COX_DESCDE",STR0420}} )//STR0421//"Datar, rubricar e assinar o instrumento convocatório pela autoridade que o expediu."//"RLC Cap. VII Art. 35"
	AADD(aGrid1,{{"COX_CODIGO","EDS"},{"COX_ITEM","008"},{"COX_DESC",STR0423},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0425},{"COX_ORDEM","008"},{"COX_DESCDE",STR0423}} )//STR0424//"Proceder à análise da publicidade dos atos, dentro dos prazos, bem como verificar se há comprovantes desses."//"RLC Cap. I Art. 2"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"ANS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Análise do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ANS"},{"COV_DESC",STR0426}} }//"Análise RLC"
	
	AADD(aGrid1,{{"COX_CODIGO","ANS"},{"COX_ITEM","001"},{"COX_DESC",STR0427},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0429},{"COX_ORDEM","001"},{"COX_DESCDE",STR0427}} )//STR0428//"Observar se estão sendo adotados modalidades e regime de execução apropriado."//"RLC Cap. III Art. 5 e seus incisos e parágrafos e Art. 6  e seus incisos"
	AADD(aGrid1,{{"COX_CODIGO","ANS"},{"COX_ITEM","002"},{"COX_DESC",STR0431},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0430},{"COX_ORDEM","002"},{"COX_DESCDE",STR0431}} )//"RLC Cap. I Art. 2"//STR0432//"Verificar se há caracterização adequada do objeto licitado."
	AADD(aGrid1,{{"COX_CODIGO","ANS"},{"COX_ITEM","003"},{"COX_DESC",STR0433},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0435},{"COX_ORDEM","003"},{"COX_DESCDE",STR0433}} )//STR0434//"Não fracionar despesas para alterar a modalidade de licitação."//"RLC Cap. III Art. 7"
	AADD(aGrid1,{{"COX_CODIGO","ANS"},{"COX_ITEM","004"},{"COX_DESC",STR0436},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0438},{"COX_ORDEM","004"},{"COX_DESCDE",STR0436}} )//STR0437//"A licitação foi formalizada por meio de processo administrativo, devidamente autuado, protocolado e numerado?"//"RLC Cap. VI Art. 14 e seus incisos"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"HAS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Habilitação do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","HAS"},{"COV_DESC",STR0439}} }//"Habilitação RLC"
	
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","001"},{"COX_DESC",STR0440},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0442},{"COX_ORDEM","001"},{"COX_DESCDE",STR0440}} )//STR0441//"Não incluir no edital cláusula restritiva à ampla competição e incompatível com a obra que se pretende contratar."//"RLC Cap. I Art. 2"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","002"},{"COX_DESC",STR0444},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0445},{"COX_ORDEM","002"},{"COX_DESCDE",STR0443}} )//"Exigir no edital as comprovações das proponentes de qualificação jurídica, técnica, econômico-financeira, regularidade fiscal e cumprimento do disposto no inciso XXXIII do art. 7º da Constituição Federal. Constituição Federal, art. 7º, XXXIII e art. 37, XXI."//"Exigir no edital as comprovações das proponentes de qualificação jurídica, técnica, econômico-financeira, regularidade fiscal..."//"RLC Cap. V Art. 12 e seus incisos e seu  parágrafo único."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","003"},{"COX_DESC",STR0447},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0448},{"COX_ORDEM","003"},{"COX_DESCDE",STR0446}} )//"Na fase de habilitação, observar se a proponente teve algum tipo de participação na elaboração dos projetos ou é servidor público do órgão contratante ou responsável pela licitação."//"Na fase de habilitação, observar se a proponente teve algum tipo de participação na elaboração dos projetos ou é servidor público..."//"RLC Cap. IX Art. 39"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","004"},{"COX_DESC",STR0450},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0449},{"COX_ORDEM","004"},{"COX_DESCDE",STR0450}} )//"RLC Cap. VI Art. 22 e seus parágrafos, Art. 23 e parágrafo único e Art. 24"//STR0451//"Respeitar os prazos recursais."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","005"},{"COX_DESC",STR0452},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0454},{"COX_ORDEM","005"},{"COX_DESCDE",STR0452}} )//STR0453//"Providenciar, nos seus devidos tempos, as atas das fases de julgamento da habilitação e das propostas de preços."//"RLC Cap. VI Art. 15"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","006"},{"COX_DESC",STR0455},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0457},{"COX_ORDEM","006"},{"COX_DESCDE",STR0455}} )//STR0456//"Foi solicitado o documento de identidade, no caso de pessoa física?"//"RLC Cap. V Art. 12 Inciso I, a"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","007"},{"COX_DESC",STR0458},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0460},{"COX_ORDEM","007"},{"COX_DESCDE",STR0458}} )//STR0459//"Foi solicitado o registro comercial, no caso de empresa individual?"//"RLC Cap. V Art. 12 Inciso I, b"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","008"},{"COX_DESC",STR0462},{"COX_PROPI","1"},{"COX_COND",""},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0463},{"COX_ORDEM","008"},{"COX_DESCDE",STR0461}} )//"Foi solicitado o ato constitutivo, estatuto ou contrato social em vigor, devidamente registrado, em se tratando de sociedades comerciais, e, no caso de sociedades por ações, acompanhado de documentos de eleição de seus administradores?"//"Foi solicitado o ato constitutivo, estatuto ou contrato social em vigor...?"//"RLC Cap. V Art. 12 Inciso I, c"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","009"},{"COX_DESC",STR0464},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0466},{"COX_ORDEM","009"},{"COX_DESCDE",STR0464}} )//STR0465//"Foi solicitada a inscrição do ato constitutivo, no caso de sociedades civis, acompanhada de prova de diretoria em exercício?"//"RLC Cap. V Art. 12 Inciso I, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","010"},{"COX_DESC",STR0468},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0469},{"COX_ORDEM","010"},{"COX_DESCDE",STR0467}} )//"Foi solicitado o decreto de autorização, em se tratando de empresa ou sociedade estrangeira em funcionamento no País, e ato de registro ou autorização para funcionamento expedido pelo órgão competente, quando a atividade assim o exigir?"//"Foi solicitado o decreto de autorização, em se tratando de empresa ou sociedade estrangeira em funcionamento no País...?"//"RLC Cap. V Art. 12 Inciso II, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","011"},{"COX_DESC",STR0470},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0472},{"COX_ORDEM","011"},{"COX_DESCDE",STR0470}} )//STR0471//"Foi solicitada a prova de inscrição no Cadastro de Pessoas Físicas (CPF) ou no Cadastro Nacional de Pessoas Jurídicas (CNPJ)?"//"RLC Cap. V Art. 12 Inciso IV, a"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","012"},{"COX_DESC",STR0474},{"COX_PROPI","1"},{"COX_COND",""},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0475},{"COX_ORDEM","012"},{"COX_DESCDE",STR0473}} )//"Foi solicitada prova de inscrição no cadastro de contribuintes estadual ou municipal , se houver, relativo ao domicílio ou sede do licitante, pertinente ao seu ramo de atividade e compatível com o objeto contratual?"//"Foi solicitada prova de inscrição no cadastro de contribuintes estadual ou municipal...?"//"RLC Cap. V Art. 12 Inciso IV, b"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","013"},{"COX_DESC",STR0477},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0478},{"COX_ORDEM","013"},{"COX_DESCDE",STR0476}} )//"Foi solicitada, conforme o caso, prova de regularidade para com a Fazenda Federal (Certidões Negativas – Dívida Ativa/PFN e Tributos Administrados pela Receita Federal), Estadual e Municipal do domicílio ou sede do licitante, ou outra equivalente, na forma da lei?"//"Foi solicitada, conforme o caso, prova de regularidade para com a Fazenda Federal...?"//"RLC Cap. V Art. 12 Inciso III, b"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","014"},{"COX_DESC",STR0479},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0481},{"COX_ORDEM","014"},{"COX_DESCDE",STR0479}} )//STR0480//"Foi solicitada prova de regularidade relativa à Seguridade Social (INSS)"//"RLC Cap. V Art. 12 Inciso IV, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","015"},{"COX_DESC",STR0482},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0484},{"COX_ORDEM","015"},{"COX_DESCDE",STR0483}} )//"Foi solicitada prova de regularidade relativa ao FGTS"//"Foi solicitada prova de regularidade relativa ao Fundo de Garantia por Tempo de Serviço (FGTS)"//"RLC Cap. V Art. 12 Inciso IV, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","016"},{"COX_DESC",STR0486},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0485},{"COX_ORDEM","016"},{"COX_DESCDE",STR0486}} )//"RLC Cap. V Art. 12 Inciso IV, a"//STR0487//"registro ou inscrição na entidade profissional competente"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","017"},{"COX_DESC",STR0490},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0488},{"COX_ORDEM","017"},{"COX_DESCDE",STR0489}} )//"RLC Cap. V Art. 12 Inciso II, b"//"comprovação de aptidão para desempenho de atividade pertinente e compatível em características, quantidades e prazos com o objeto da licitação, e indicação das instalações e do aparelhamento e do pessoal técnico adequados e disponíveis para a realização do objeto da licitação, bem como da qualificação de cada um dos membros da equipe técnica que se responsabilizará pelos trabalhos"//"comprovação de aptidão para desempenho de atividade pertinente e compatível em características, quantidades e prazos com o objeto da licitação..."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","018"},{"COX_DESC",STR0492},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0491},{"COX_ORDEM","018"},{"COX_DESCDE",STR0492}} )//"RLC Cap. V Art. 12 Inciso II, c"//STR0493//"comprovação, fornecida pelo órgão licitante, de que recebeu os documentos, e, quando exigido, de que tomou conhecimento de todas as informações e das condições locais para o cumprimento das obrigações objeto da licitação"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","019"},{"COX_DESC",STR0495},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0494},{"COX_ORDEM","019"},{"COX_DESCDE",STR0495}} )//"RLC Cap. V Art. 12 Inciso II, d"//STR0496//"prova de atendimento de requisitos previstos em lei especial, quando for o caso"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","020"},{"COX_DESC",STR0497},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0499},{"COX_ORDEM","020"},{"COX_DESCDE",STR0497}} )//STR0498//"Não houve a fixação de quantidades mínimas e prazos máximos para a capacitação técnico-profissional?"//"RLC Cap. V Art. 12 Inciso II, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","021"},{"COX_DESC",STR0501},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0502},{"COX_ORDEM","021"},{"COX_DESCDE",STR0500}} )//"Não houve a exigência de itens irrelevantes e sem valor significativo em relação ao objeto em licitação para efeito de capacitação técnico-profissional?"//"Não houve a exigência de itens irrelevantes...?"//"RLC Cap. V Art. 12 Inciso II, d"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","022"},{"COX_DESC",STR0505},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0503},{"COX_ORDEM","022"},{"COX_DESCDE",STR0504}} )//"RLC Cap. V Art. 12 Inciso III, a"//"balanço patrimonial e demonstrações contábeis do último exercício social, já exigíveis e apresentados na forma da lei, que comprovem a boa situação financeira da empresa, vedada a sua substituição por balancetes ou balanços provisórios, podendo ser atualizados por índices oficiais quando encerrado há mais de 3 meses da data de apresentação da proposta"//"balanço patrimonial e demonstrações contábeis do último exercício social, já exigíveis e apresentados na forma da lei, que comprovem a boa situação financeira da empresa, vedada a sua substituição por balancetes ou balanços provisórios..."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","023"},{"COX_DESC",STR0507},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0506},{"COX_ORDEM","023"},{"COX_DESCDE",STR0507}} )//"RLC Cap. V Art. 12 Inciso III, b"//STR0508//"certidão negativa de falência ou concordata expedida pelo distribuidor da sede da pessoa jurídica, ou de execução patrimonial, expedida no domicílio da pessoa física"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","024"},{"COX_DESC",STR0510},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0509},{"COX_ORDEM","024"},{"COX_DESCDE",STR0510}} )//"RLC Cap. V Art. 12 Inciso III, c"//STR0511//"garantia limitada a 1% (um por cento) do valor estimado do objeto da contratação ou capital mínimo/valor do patrimônio líquido inferior a 10% (dez por cento) do valor estimado da contratação."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","025"},{"COX_DESC",STR0513},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0512},{"COX_ORDEM","025"},{"COX_DESCDE",STR0513}} )//"RLC Cap. V Art. 12 Inciso III, a"//STR0514//"índices contábeis que comprovem a boa situação financeira do licitante."
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","026"},{"COX_DESC",STR0515},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0517},{"COX_ORDEM","026"},{"COX_DESCDE",STR0515}} )//STR0516//"Não houve a exigência cumulativa de garantia de proposta com valor de capital mínimo/patrimônio líquido (item c anterior)?"//"RLC Cap. V Art. 12 Inciso III, c"
	AADD(aGrid1,{{"COX_CODIGO","HAS"},{"COX_ITEM","027"},{"COX_DESC",STR0518},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0520},{"COX_ORDEM","027"},{"COX_DESCDE",STR0518}} )//STR0519//"Os índices contábeis e seus valores, se exigidos, são os usualmente adotados para correta avaliação de situação financeira suficiente ao cumprimento das obrigações decorrentes da licitação?"//"RLC Cap. V Art. 12 Inciso III, a"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"HOS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Homologação do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","HOS"},{"COV_DESC",STR0521}} }//"Homologação RLC"
	
	AADD(aGrid1,{{"COX_CODIGO","HOS"},{"COX_ITEM","001"},{"COX_DESC",STR0522},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0524},{"COX_ORDEM","001"},{"COX_DESCDE",STR0522}} )//STR0523//"Providenciar ato de homologação e adjudicação do objeto da licitação."//"RLC Cap. II, Art. 4, Inciso 5"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"ADS")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Adjudicação do Edital
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","ADS"},{"COV_DESC",STR0525}} }//"Adjudicao RLC"
		
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","001"},{"COX_DESC",STR0526},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0528},{"COX_ORDEM","001"},{"COX_DESCDE",STR0526}} )//STR0527//"Providenciar ato de homologação e adjudicação do objeto da licitação."//"RLC Cap. II, Art. 4, Inciso 6"
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","002"},{"COX_DESC",STR0529},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0531},{"COX_ORDEM","002"},{"COX_DESCDE",STR0529}} )//STR0530//"Convocar o interessado a assinar o contrato no prazo e condições estabelecidos, observando a ordem de classificação das licitantes."//"RLC Cap. VIII, Art. 35"
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","003"},{"COX_DESC",STR0532},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0534},{"COX_ORDEM","003"},{"COX_DESCDE",STR0532}} )//STR0533//"Observar se o contrato é claro e preciso quanto à identificação do objeto e seus elementos caracterizadores."//"RLC Cap. VII, Art. 26"
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","004"},{"COX_DESC",STR0535},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0537},{"COX_ORDEM","004"},{"COX_DESCDE",STR0535}} )//STR0536//"Atentar-se o contrato prevê com clareza e precisão as condições para a sua execução, definindo direitos, obrigações e responsabilidades das partes condizentes aos termos da licitação e proposta apresentada."//"RLC Cap. VII, Art. 26, Parágrafo Único"
	AADD(aGrid1,{{"COX_CODIGO","ADS"},{"COX_ITEM","005"},{"COX_DESC",STR0538},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","1"},{"COX_DPSLEG",STR0540},{"COX_ORDEM","005"},{"COX_DESCDE",STR0538}} )//STR0539//"Providenciar publicação resumida do extrato de contrato."//"RLC Cap. VII, Art. 27, Parágrafo Único"
	
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()
	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIf

If !COV->(MsSeek(xFilial('COV')+"RDE")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Elaboração do Edital RDC
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","RDE"},{"COV_DESC",STR0554}} }//"Elaboração RDC"
		
	AADD(aGrid1,{{"COX_CODIGO","RDE"},{"COX_ITEM","001"},{"COX_DESC",STR0548},{"COX_PROPRI","1"},{"COX_COND"," "},{"COX_OBRIGA","2"},{"COX_DPSLEG",STR0549},{"COX_ORDEM","001"},{"COX_DESCDE",STR0550}} )//STR0548//"Caso o Regime de Execução seja Empreitada por Preço Unitário ou Tarefa foi informada a Justificativa da escolha."//"LEI FEDERAL Nº 12.462/2011, ART 8, INCISOS I A V, § 1 E 2"
	AADD(aGrid,aGrid1)
	
	oImport:Import( aField , aGrid )
	oImport:Commit()
	
	aGrid := {}
	aGrid1 := {}
	aField := {} 
EndIF

If !COV->(MsSeek(xFilial('COV')+"RDH")) //-COV_FILIAL+COV_CODIGO
	//----------------------------------------------- 
	// Check Lists para Habilitação do Edital RDC
	//----------------------------------------------- 
	aField := { {{"COV_CODIGO","RDH"},{"COV_DESC",STR0555}} }//"Habilitação RDC"
		
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
	// Check Lists para Preparação
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","PRE"},{"COV_DESC",STR0557}} }//"Preparação Lei 13.303/2016"

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
	// Check Lists para Verificação da Efetividade dos Lances/Propostas
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","VER"},{"COV_DESC",STR0559}} }//"Verificação da Efetividade dos Lances/Propostas Lei 13.303/2016"

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
	// Check Lists para Negociação
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","NEG"},{"COV_DESC",STR0560}} }//"Negociação Lei 13.303/2016"

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
	// Check Lists para Habilitação
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","HBE"},{"COV_DESC",STR0561}} }//"Habilitação Lei 13.303/2016"

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
	// Check Lists para Interposição de recursos
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","REC"},{"COV_DESC",STR0562}} }//"Interposição de Recursos Lei 13.303/2016"

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
	// Check Lists para Adjudicação
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","ADE"},{"COV_DESC",STR0563}} }//"Adjudicação Lei 13.303/2016"

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
	// Check Lists para Homologação
	//-----------------------------------------------
	aField := { {{"COV_CODIGO","HOE"},{"COV_DESC",STR0564}} }//"Homologação Lei 13.303/2016"

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