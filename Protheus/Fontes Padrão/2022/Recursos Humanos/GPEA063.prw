#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "GPEA063.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Função    	³ GPEA063                                                                  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Descriçao 	³ Rotina de cadastro de plano de saúde para cálculo por agrupamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe   	³ GPEA063()                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Uso      	³ GPEA063()                                   	    	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL.               	    	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Programador  ³ Data     ³ FNC			³  Motivo da Alteracao           			    ³±±
±±³Flavio Correa³ 09/06/15 ³ PCDEF-38363	³ Alteração de linha unica     			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


/*/{Protheus.doc}GPEA063
Rotina de cadastro de plano de saúde para cálculo por agrupamento
@author Gabriel de Souza Almeida
@since 01/04/2015
@version P12
/*/
Function GPEA063()
	Local oMBrowse
	Local cFiltraRh

	// Tratamento de ambiente configurado com 2 Digitos no Ano da Data.
	// Se "on"  indica 4 digitos e __SetCentury( ) retorna .T.	- Neste caso, nao ha necessidade de alteracao na configuracao.
	// Se "off" indica 2 digitos e __SetCentury( ) retorna .F.	- Neste caso, sera efetuada a alteracao na configuracao.
	Private lSetCentury := __SetCentury( )	// Guarda Configuracao original do ambiente.

	If ! lSetCentury			// __SetCentury( ) retornou .F. - Neste caso, SERA efetuada a alteracao na configuracao.
		__SetCentury( "on" )	// Forca a utilizacao do Ano com 4 Digitos.
	EndIf


	oMBrowse := FWMBrowse():New()
	
	oMBrowse:SetAlias("SG0")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Definição de Planos Médico e Odontológico"
	
	oMBrowse:AddLegend("SG0->G0_STATUS=='2'", 'RED', OemToAnsi(STR0019))//Inativa
	oMBrowse:AddLegend("SG0->G0_STATUS=='1'", 'GREEN', OemToAnsi(STR0018))//Ativa
	
	oMBrowse:ForceQuitButton() //"Incluir botao de sair" 
	
	//Inicializa o filtro utilizando a funcao FilBrowse

	cFiltraRh := CHKRH("GPEA063","SG0","1")
	oMBrowse:SetFilterDefault( cFiltraRh )
	                           
	oMBrowse:DisableDetails()
	
	oMBrowse:Activate()
	
	If ! lSetCentury // __SetCentury( ) retornou .F., portanto foi efetuada a alteracao na configuracao e a configuração original deve retornar.
		__SetCentury( "off" )
	EndIf
Return


/*/{Protheus.doc}MenuDef
Criacao do Menu do Browse
@author Gabriel de Souza Almeida
@since 01/04/2015
@version P12
@return array, aRotina
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE OemToAnsi(STR0002)  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar' 
	ADD OPTION aRotina TITLE OemToAnsi(STR0003)  ACTION "VIEWDEF.GPEA063" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE OemToAnsi(STR0004)  ACTION "VIEWDEF.GPEA063" 		OPERATION 3 ACCESS 0				//'Incluir'
	ADD OPTION aRotina TITLE OemToAnsi(STR0005)  ACTION "VIEWDEF.GPEA063" 		OPERATION 4 ACCESS 0				//'Alterar'
	ADD OPTION aRotina TITLE OemToAnsi(STR0006)  ACTION "VIEWDEF.GPEA063" 		OPERATION 5 ACCESS 0			   	//'Excluir'
	
Return aRotina


/*/{Protheus.doc}ModelDef
Regras de modelagem da gravação
@author Gabriel de Souza Almeida
@since 01/04/2015
@version P12
@return objeto, oModel
/*/
Static Function ModelDef()

	Local oModel
	Local oStructSG0
	Local oStructSJX	// Funcionarios
	Local oStructSL0	// Dependentes 
	Local oStructSLE	// Agregados
	
	// Criacao do Objeto de Modelagem de dados
	oModel := MPFormModel():New("GPEA063",/*bPreValid*/,/*PosValid*/,/*bCommiM040*/,/*bCancel*/)
	oModel:SetDescription( OemToAnsi(STR0001) ) //"Controle dos Planos Médico e Odontológico Ativos"
    
	//Cabecalho de dados - SG0 (Funcionario)
	oStructSG0 := FWFormStruct(1, "SG0")
	oModel:AddFields("GPEA063_MSG0", NIL, oStructSG0)
	oModel:GetModel( "GPEA063_MSG0" ):SetDescription(OemToAnsi(STR0001)) //"Definição de Planos Médico e Odontológico"

	//Estrutura de campos do Model - SJX - Planos Ativos do Funcionario
	
	oStructSJX := FWFormStruct(1, "SJX")
	oStructSJX:SetProperty( "JX_TPFORN", MODEL_FIELD_WHEN,)
	oModel:AddGrid("GPEA063_MSJX", "GPEA063_MSG0", oStructSJX,{|oModel,nLine,cAcao,cCampo| fPreLine(oModel,nLine,cAcao,cCampo)},{|oModel| fLinhaOK(oModel,"SJX")})
	oModel:GetModel("GPEA063_MSJX"):SetDescription(OemToAnsi(STR0007)) //"Planos Ativos do Titular"
	oModel:GetModel("GPEA063_MSJX"):SetUniqueLine({'JX_TPFORN'})
	oModel:SetRelation( "GPEA063_MSJX", { { "JX_FILIAL", 'xFilial("SJX",SG0->G0_FILIAL)' }, { "JX_CODIGO", 'G0_CODIGO' }}, SJX->( IndexKey( 1 ) ) )
	
	//Estrutura de campos do Model (SL0)Planos Ativos Dependentes
	oStructSL0 := FWFormStruct(1,"SL0")
	oStructSL0:SetProperty( "L0_CODIGO", MODEL_FIELD_WHEN,)
	oModel:AddGrid("GPEA063_MSL0", "GPEA063_MSJX", oStructSL0,,{|oModel| fLinhaOK(oModel,"SL0")})
	oModel:GetModel("GPEA063_MSL0"):SetDescription(OemToAnsi(STR0008)) //"Planos Ativos dos Dependentes"
	oModel:GetModel("GPEA063_MSL0"):SetOptional(.T.)
	oModel:SetRelation("GPEA063_MSL0", {{"L0_FILIAL", 'xFilial( "SJX" )'}, {"L0_CODIGO", 'G0_CODIGO'}, {"L0_TPFORN", 'JX_TPFORN'}, {"L0_CODFORN", 'JX_CODFORN'}}, SL0->(IndexKey(1)))
		
	//Estrutura de campos do Model (SLE)Planos Ativos Agregados
	oStructSLE := FWFormStruct(1, "SLE")
	oStructSLE:SetProperty("LE_CODIGO", MODEL_FIELD_WHEN, {||.F.})
	oModel:AddGrid("GPEA063_MSLE", "GPEA063_MSJX", oStructSLE,,{|oModel| fLinhaOK(oModel,"SLE")})
	oModel:GetModel("GPEA063_MSLE"):SetDescription(OemToAnsi(STR0009))//"Planos Ativos dos Agregados"
	oModel:GetModel("GPEA063_MSLE"):SetOptional(.T.)
	oModel:SetRelation("GPEA063_MSLE", {{"LE_FILIAL", 'xFilial( "SJX" )'}, {"LE_CODIGO", 'G0_CODIGO'}, {"LE_TPFORN", 'JX_TPFORN'}, {"LE_CODFORN", 'JX_CODFORN'}}, SLE->(IndexKey(1)))

	oModel:SetActivate()
	
Return(oModel)

/*/{Protheus.doc}ViewDef
Regras de Interface
@author Gabriel de Souza Almeida
@since 01/04/2015
@version P12
@return objeto, oView
/*/
Static Function ViewDef()
	Local oView 
	Local oModel
	Local oStructSG0
	Local oStructSJX
	Local oStructSL0
	Local oStructSLE

	//Vincular o View ao Model
	oModel := FWLoadModel("GPEA063")

	//Criacao da Interface
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Criacao do Cabecalho - SG0 (Plano)
	oStructSG0 := FWFormStruct(2, "SG0",)
	oStructSG0:SetNoFolder()
	oView:AddField("GPEA063_VSG0", oStructSG0, "GPEA063_MSG0" )
	
	//Criacao do Cabecalho - SJX (Planos Ativos do Titular)
	oStructSJX := FWFormStruct(2, "SJX")
	oView:AddGrid("GPEA063_VSJX", oStructSJX, "GPEA063_MSJX" )
	oStructSJX:RemoveField("JX_CODIGO")

	//Criacao do Cabecalho - SL0 e SLE (Planos Ativos dos Dependentes e Agregados)
	oStructSL0 := FWFormStruct(2, "SL0")
	oView:AddGrid("GPEA063_VSL0", oStructSL0, "GPEA063_MSL0")
	oStructSL0:RemoveField("L0_CODIGO")
	oStructSL0:RemoveField("L0_TPFORN")
	oStructSL0:RemoveField("L0_CODFORN")
	
	oStructSLE := FWFormStruct(2, "SLE")
	oView:AddGrid("GPEA063_VSLE", oStructSLE, "GPEA063_MSLE")
	oStructSLE:RemoveField("LE_CODIGO")
	oStructSLE:RemoveField("LE_TPFORN")
	oStructSLE:RemoveField("LE_CODFORN")
    
	//Desenho da Tela
	oView:CreateHorizontalBox("SG0_HEAD", 12)
	oView:CreateHorizontalBox("SJX_PLFUNC", 25)
	oView:CreateHorizontalBox("PLDEPAGR", 63)

	oView:CreateVerticalBox('SL0_PLDEP', 50, 'PLDEPAGR')
	oView:CreateVerticalBox('SLE_PLAGR', 50, 'PLDEPAGR')
	
	oView:SetOwnerView("GPEA063_VSG0", "SG0_HEAD")
	oView:SetOwnerView("GPEA063_VSJX", "SJX_PLFUNC")
	oView:SetOwnerView("GPEA063_VSL0", "SL0_PLDEP")
	oView:SetOwnerView("GPEA063_VSLE", "SLE_PLAGR")
	
	oView:EnableTitleView( "GPEA063_VSJX", OemToAnsi(STR0007)) //"Planos Ativos do Titular"
	oView:EnableTitleView( "GPEA063_VSL0", OemToAnsi(STR0008)) //"Planos Ativos dos Dependentes"
	oView:EnableTitleView( "GPEA063_VSLE", OemToAnsi(STR0009)) //"Planos Ativos dos Agregados"
	oView:SetCloseOnOk({|| .T. })//Apos COMMIT gravacao fecha a tela
		
Return oView

/*/{Protheus.doc}fVldPlanoG
Validação do campo JX_PLANO
@author Gabriel de Souza Almeida
@since 07/04/2015
@version P12
@return Lógico, lRet
/*/
Function fVldPlanoG()

	Local cVar := Alltrim(ReadVar())
	Local cTpForn
	Local cCodFor
	Local cTpPlano
	Local cCodPlano
	
	Local lRet := .T.
	
	Local oModel
	Local oStructSJX
	Local oStructSLE
	Local oStructSL0
	
	oModel := FWModelActive()
	oStructSJX := oModel:GetModel("GPEA063_MSJX")
	
	Do Case
		Case cVar == "M->JX_PLANO"
			cTpPlano := oStructSJX:GetValue("JX_TPPLANO")
			cCodPlano := oStructSJX:GetValue("JX_PLANO")
		Case cVar == "M->LE_PLANO"
			oStructSLE := oModel:GetModel("GPEA063_MSLE")
			cTpPlano := oStructSLE:GetValue("LE_TPPLANO")
			cCodPlano := oStructSLE:GetValue("LE_PLANO")
		Case cVar == "M->L0_PLANO"
			oStructSL0 := oModel:GetModel("GPEA063_MSL0")
			cTpPlano := oStructSL0:GetValue("L0_TPPLANO")
			cCodPlano := oStructSL0:GetValue("L0_PLANO")
	EndCase
	
	cTpForn := oStructSJX:GetValue("JX_TPFORN")
	cCodFor := oStructSJX:GetValue("JX_CODFORN")
			
	lRet := fValidPlano(cTpForn, cCodFor, cTpPlano, cCodPlano)

Return(lRet)


/*/{Protheus.doc}fLinhaOK
Não permite quantidade de linhas maior que 1 no Grid
@author Gabriel de Souza Almeida
@since 08/04/2015
@version P12
@return Lógico, lRet
/*/
Static Function fLinhaOK(oModel,cTab)

	Local oGrid
	Local lRet := .T.
	Local nLinhas
	Local nI
	Local nCount := 0
	Local dDtIni
	Local dDtFim
	Local nLinha := oModel:GetLine()
	Local oModelAtv := FWModelActive()
	
	Local oStructSG0
	Local cCodSG0
	Local cStsSG0M
	
	Local oStructSJX
	Local cMTpFornJX
	Local cMCodForJX
	Local cMTpPlanJX
	Local cMPlanoJX
	Local cMPD
	Local cMPDDEP
	Local cMPerIniJX
	Local cMPerFimJX
	
	Local cMTpPlanL0
	Local cMPlanL0
	Local cMPerIniL0
	Local cMPerFimL0
	
	Local cMTpPlanLE
	Local cMPlanLE
	Local cMPerIniLE
	Local cMPerFimLE
	
	If cTab == "SL0"
		oGrid := oModelAtv:GetModel("GPEA063_MSL0")
		
		dDtIni	:= oGrid:GetValue("L0_PERINI")
		dDtFim	:= oGrid:GetValue("L0_PERFIM")
	ElseIf cTab == "SLE"
		oGrid := oModelAtv:GetModel("GPEA063_MSLE")
		
		dDtIni	:= oGrid:GetValue("LE_PERINI")
		dDtFim	:= oGrid:GetValue("LE_PERFIM")
	ElseIf cTab == "SJX"
		oGrid := oModelAtv:GetModel("GPEA063_MSJX")
		oGrid:GoLine(nLinha)
		
		cMPD := oGrid:GetValue("JX_PD")
		cMPDDEP := oGrid:GetValue("JX_PDDEP")
		
		dDtIni	:= oGrid:GetValue("JX_PERINI")
		dDtFim	:= oGrid:GetValue("JX_PERFIM")
		
		If cMPD == cMPDDEP
			Help( , , 'HELP', , OemToAnsi(STR0017), 1, 0)//"As Verbas do Titular e dos Dep./Agreg. não podem ser iguais!"
			lRet := .F.
		EndIf
	EndIf
	
	If cTab == "SL0" .OR. cTab == "SLE"
		nLinhas := oGrid:GetQtdLine()
		
		For nI := 1 To nLinhas
			oGrid:GoLine(nI)
			If !oGrid:IsDeleted()
				nCount++
			EndIf
		Next nI
		
		If nCount > 1
			Help(" ", 1, "Help",, OemToAnsi(STR0016), 1, 0)//"Numero máximo de linhas excedido"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
			lRet := .F.
		EndIf
	EndIf
	
	If !Empty(dDtFim)
		If dDtFim < dDtIni
			Help(,,'HELP',,OemToAnsi(STR0020),1,0)//"Data Final não pode ser menor que a inicial"
			lRet := .F.
		EndIf
	EndIf
	
	If (oModel:GetOperation() == 4 .AND. lRet)
		DbSelectArea("SLY")
		SLY->(DbSetOrder(3))//LY_FILIAL+LY_AGRUP+LY_TIPO+LY_CODIGO
		DbSelectArea("SG0")
		SG0->(DbSetOrder(1))//G0_FILIAL+G0_CODIGO
		DbSelectArea("SJX")
		SJX->(DbSetOrder(1))//JX_FILIAL+JX_CODIGO+JX_TPFORN+JX_CODFORN
		DbSelectArea("SL0")
		SL0->(DbSetOrder(1))//L0_FILIAL+L0_CODIGO+L0_TPFORN+L0_CODFORN
		DbSelectArea("SLE")
		SLE->(DbSetOrder(1))//LE_FILIAL+LE_CODIGO+LE_TPFORN+LE_CODFORN
		
		oStructSG0 := oModelAtv:GetModel("GPEA063_MSG0")
		cCodSG0 := oStructSG0:GetValue("G0_CODIGO")
		cStsSG0M := oStructSG0:GetValue("G0_STATUS")
		
		oStructSJX := oModelAtv:GetModel("GPEA063_MSJX")
		oStructSJX:GoLine(nLinha)
		
		cMTpFornJX := oStructSJX:GetValue("JX_TPFORN")
		cMCodForJX := oStructSJX:GetValue("JX_CODFORN")
		
		SG0->(MsSeek(xFilial("SG0")+cCodSG0))
		SJX->(MsSeek(xFilial("SJX")+cCodSG0+cMTpFornJX+cMCodForJX))
		SL0->(MsSeek(xFilial("SL0")+cCodSG0+cMTpFornJX+cMCodForJX))
		SLE->(MsSeek(xFilial("SLE")+cCodSG0+cMTpFornJX+cMCodForJX))
		
		oGrid:GoLine(nLinha)
		
		Do Case
			Case cTab == "SJX"
				cMTpFornJX := oGrid:GetValue("JX_TPFORN")
				cMCodForJX := oGrid:GetValue("JX_CODFORN")
				cMTpPlanJX := oGrid:GetValue("JX_TPPLANO")
				cMPlanoJX := oGrid:GetValue("JX_PLANO")
				cMPD := oGrid:GetValue("JX_PD")
				cMPDDEP := oGrid:GetValue("JX_PDDEP")
				cMPerIniJX := oGrid:GetValue("JX_PERINI")
				cMPerFimJX := oGrid:GetValue("JX_PERFIM")
				
				cMTpPlanL0 := SL0->L0_TPPLANO
				cMPlanL0 := SL0->L0_PLANO
				cMPerIniL0 := SL0->L0_PERINI
				cMPerFimL0 := SL0->L0_PERFIM
				
				cMTpPlanLE := SLE->LE_TPPLANO
				cMPlanLE := SLE->LE_PLANO
				cMPerIniLE := SLE->LE_PERINI
				cMPerFimLE := SLE->LE_PERFIM
			Case cTab == "SL0"
				cMTpFornJX := SJX->JX_TPFORN
				cMCodForJX := SJX->JX_CODFORN
				cMTpPlanJX := SJX->JX_TPPLANO
				cMPlanoJX := SJX->JX_PLANO
				cMPD := SJX->JX_PD
				cMPDDEP := SJX->JX_PDDEP
				cMPerIniJX := SJX->JX_PERINI
				cMPerFimJX := SJX->JX_PERFIM
				
				cMTpPlanL0 := oGrid:GetValue("L0_TPPLANO")
				cMPlanL0 := oGrid:GetValue("L0_PLANO")
				cMPerIniL0 := oGrid:GetValue("L0_PERINI")
				cMPerFimL0 := oGrid:GetValue("L0_PERFIM")
				
				cMTpPlanLE := SLE->LE_TPPLANO
				cMPlanLE := SLE->LE_PLANO
				cMPerIniLE := SLE->LE_PERINI
				cMPerFimLE := SLE->LE_PERFIM
			Case cTab == "SLE"
				cMTpFornJX := SJX->JX_TPFORN
				cMCodForJX := SJX->JX_CODFORN
				cMTpPlanJX := SJX->JX_TPPLANO
				cMPlanoJX := SJX->JX_PLANO
				cMPD := SJX->JX_PD
				cMPDDEP := SJX->JX_PDDEP
				cMPerIniJX := SJX->JX_PERINI
				cMPerFimJX := SJX->JX_PERFIM
				
				cMTpPlanL0 := SL0->L0_TPPLANO
				cMPlanL0 := SL0->L0_PLANO
				cMPerIniL0 := SL0->L0_PERINI
				cMPerFimL0 := SL0->L0_PERFIM
				
				cMTpPlanLE := oGrid:GetValue("LE_TPPLANO")
				cMPlanLE := oGrid:GetValue("LE_PLANO")
				cMPerIniLE := oGrid:GetValue("LE_PERINI")
				cMPerFimLE := oGrid:GetValue("LE_PERFIM")
		End Case
		
		If !(fRetCriter()=="") .AND. (SLY->(MsSeek(xFilial("SLY")+(fRetCriter())+"PS"+cCodSG0)))			
			If (SG0->G0_STATUS <> cStsSG0M .OR. SJX->JX_TPFORN <> cMTpFornJX .OR. SJX->JX_CODFORN <> cMCodForJX .OR. SJX->JX_TPPLANO <> cMTpPlanJX .OR.;
				SJX->JX_PLANO <> cMPlanoJX .OR. SJX->JX_PD <> cMPD .OR. SJX->JX_PDDEP <> cMPDDEP .OR. SJX->JX_PERINI <> cMPerIniJX .OR. SJX->JX_PERFIM <> cMPerFimJX .OR.;
				SL0->L0_TPPLANO <> cMTpPlanL0 .OR. SL0->L0_PLANO <> cMPlanL0 .OR. SL0->L0_PERINI <> cMPerIniL0 .OR. SL0->L0_PERFIM <> cMPerFimL0 .OR.;
				SLE->LE_TPPLANO <> cMTpPlanLE .OR. SLE->LE_PLANO <> cMPlanLE .OR. SLE->LE_PERINI <> cMPerIniLE .OR. SLE->LE_PERFIM <> cMPerFimLE)
				MsgAlert(OemToAnsi(STR0021))		
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc}fVldCodigo
Verifica a existência de índice duplicado
@author Gabriel de Souza Almeida
@since 08/04/2015
@version P12
@return Lógico, lRet
/*/
Function fVldCodigo(cCodigo)
	Local lRet := .T.
	
	DbSelectArea("SG0")
	DbSetOrder(1)
	
	If (SG0->(MsSeek(xFilial("SG0")+cCodigo)))
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc}fWhenCod
Desabilita o campo quando for alteração
@author Gabriel de Souza Almeida
@since 15/04/2015
@version P12
@return Lógico, lRet
/*/
Function fWhenCod()
	Local oModel := FWModelActive()
	Local lRet := !(oModel:GetOperation() == 4)
Return lRet

/*/{Protheus.doc}fPreLine
Dispara a deleção das linhas dos dep. e agreg. quando a linha do titular é deletada
@author Gabriel de Souza Almeida
@since 15/04/2015
@version P12
@param Objeto, oModel
@return Lógico, lRet
/*/
Static Function fPreLine(oStructSJX,nLine,cAcao,cCampo)
	Local lRet := .T.
	Local oModelAtv := FWModelActive()
	Local oStructSL0 := oModelAtv:GetModel("GPEA063_MSL0")
	Local oStructSLE := oModelAtv:GetModel("GPEA063_MSLE")
	
	If cAcao =='DELETE'
		If !(Empty(oStructSL0:GetValue("L0_TPPLANO"))) .OR. !(Empty(oStructSL0:GetValue("L0_PLANO")))
			oStructSL0:DeleteLine()
		EndIf
		If !(Empty(oStructSLE:GetValue("LE_TPPLANO"))) .OR. !(Empty(oStructSLE:GetValue("LE_PLANO")))
			oStructSLE:DeleteLine()
		EndIf
	ElseIf cAcao =='UNDELETE'
		If !(Empty(oStructSL0:GetValue("L0_TPPLANO"))) .OR. !(Empty(oStructSL0:GetValue("L0_PLANO")))
			oStructSL0:UnDeleteLine()
		EndIf
		If !(Empty(oStructSLE:GetValue("LE_TPPLANO"))) .OR. !(Empty(oStructSLE:GetValue("LE_PLANO")))
			oStructSLE:UnDeleteLine()
		EndIf
	EndIf
Return lRet