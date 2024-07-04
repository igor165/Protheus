#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA070.CH"
#Include "FWMVCDEF.CH"

Static aSetKey    := {}
Static nOpcx      := 0
Static cTMSERP    := GetMv("MV_TMSERP",,"0") //| Integração Mensagem Única ligada? 0=PROTHEUS; 1=DATASUL 
Static lRestRepom := SuperGetMV('MV_VSREPOM',,"1") == "2.2"
Static cImpCTC    := SuperGetMv("MV_IMPCTC",,"0") //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).

/*/-----------------------------------------------------------
{Protheus.doc} TMSA070()
Movimento de Custo de Transporte

Uso: TMSA070

@sample
//TMSA070()

@author Patricia A. Salomao
@since 05/11/2001
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 07/12/2016


@version 2.0
-----------------------------------------------------------/*/
Function TMSA070()
	Local   oBrowse   := Nil           // Recebe o objeto do Browse      
	Private aRotina   := MenuDef()     // Recebe as rotinas do MenuDef
	Private lBaixa     := .F.	
	Private nCntParc   := 0
	Private nLinPai    := 0

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("SDG")
	oBrowse:SetDescription(STR0001) //"Movimento de Custo de Transporte"

	oBrowse:AddLegend( "DG_STATUS == '1'" , "GREEN", STR0008  ) //'Em Aberto'
	oBrowse:AddLegend( "DG_STATUS == '2'" , "RED"  , STR0009  ) //'Baixa Parcial'
	oBrowse:AddLegend( "DG_STATUS == '3'" , "BLUE" , STR0010  ) //'Baixa Total'
	oBrowse:SetCacheView(.F.) // Desabilita Cache da View, pois gera colunas dinamicamente
	oBrowse:Activate()

Return

/*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSA070

@sample
//MenuDef()

@author Patricia A. Salomao
@since 05/11/2001
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 07/12/2016

@version 2.0
-----------------------------------------------------------/*/
Static Function MenuDef()
	Private aRotina := {} 		// Recebe as Rotinas do Menu

	ADD OPTION aRotina Title STR0002    Action 'PesqBrw'         OPERATION 1 ACCESS 0   DISABLE MENU //"Pesquisar"							
	ADD OPTION aRotina Title STR0003    Action 'A070Vis()'       OPERATION 2 ACCESS 0   DISABLE MENU //"Visualizar"
	ADD OPTION aRotina Title STR0004    Action 'A070Inc()'       OPERATION 3 ACCESS 0                //"Incluir"
	ADD OPTION aRotina Title STR0011    Action 'A070BxDoc()'     OPERATION 4 ACCESS 0   DISABLE MENU //"Baixar Docto"
	ADD OPTION aRotina Title STR0013    Action 'A070BxItem()'    OPERATION 8 ACCESS 0   DISABLE MENU //"Baixar Item"
	ADD OPTION aRotina Title STR0005    Action 'A070Del()'       OPERATION 5 ACCESS 0   DISABLE MENU //"Excluir"
	ADD OPTION aRotina Title STR0012    Action 'A070Est()'       OPERATION 6 ACCESS 0   DISABLE MENU //"Estorna Baixa"								
	ADD OPTION aRotina Title STR0007    Action 'TMSA070Leg()'    OPERATION 7 ACCESS 0   DISABLE MENU //"Legenda"	
			
	If ExistBlock("TM070MNU")
		ExecBlock("TM070MNU",.F.,.F.)
	EndIf

Return(aRotina)

/*/-----------------------------------------------------------
{Protheus.doc} TMSA070Leg()
Exibe a Legenda do Agendamento 

Uso: TMSA070

@sample
//TMSA070Leg( cTxtLeg )

@author Patricia A. Salomao
@since 05/11/2001
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 07/12/2016

@version 2.0
-----------------------------------------------------------/*/
Function TMSA070Leg( cTxtLeg )
	Local cTitulo   := STR0001 // "Movimento de Custo de Transporte"
	Local aStatus   := {}
	Default cTxtLeg := STR0007

	Aadd( aStatus, {'BR_VERDE'   , STR0008 } ) // 'Em Aberto'
	Aadd( aStatus, {'BR_VERMELHO', STR0009 } ) // 'Baixa Parcial'
	Aadd( aStatus, {'BR_AZUL'    , STR0010 } ) // 'Baixa Total'

	BrwLegenda( cTitulo, cTxtLeg, aStatus ) //'Legenda'

Return

/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSA070

@sample
//ModelDef()

@author Paulo Henrique Corrêa Cardoso.
@since 07/12/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()
	Local oModel	 := Nil		// Objeto do Model
	Local oStrFSDG	 := Nil		// Recebe a Estrutura da tabela SDG - Field
	Local oStrGSDG	 := Nil		// Recebe a Estrutura da tabela SDG - Grid
	Local cYesFields := ""      // Recebe os campos que devem aparecer no cabecalho
	Local lIdent	:=  nModulo <> 43
	Local lForn     := SDG->(ColumnPos("DG_CODFOR") > 0 )
    Local lBaixaDoc := IsInCallStack("A070BxDoc") 
	Local lBaixaItm := IsInCallStack("A070BxItem")

	oModel := MpFormModel():New( "TMSA070" ,  /*bPreValid*/ ,{ |oModel| PosVldMdl(oModel) }  ,  { |oModel| CommitMdl(oModel) } ,/*bCancel*/ )

	cYesFields := A070YesFld()

	oStrFSDG := FWFormStruct( 1, "SDG", { |cCampo| (AllTrim(cCampo)+"|" $ cYesFields) } )
	oStrGSDG := FWFormStruct( 1, "SDG", { |cCampo| !(AllTrim(cCampo)+"|" $ "DG_DOC|") } )

	A070ModEdt(oStrFSDG,oStrGSDG)

	oModel:AddFields( 'MdFieldSDG',, oStrFSDG,,,/*Carga*/ )

	oModel:SetPrimaryKey({"DG_DOC"})
	
	oModel:AddGrid( 'MdGridSDG', 'MdFieldSDG', oStrGSDG,,, /*bPreVal*/, {|oModelGrid,nLine| PosVldSDG(oModelGrid,nLine)} /*bPosVal*/,/*BLoad*/  )
	
	oModel:SetRelation("MdGridSDG", { { "DG_FILIAL", "FWxFilial( 'SDG' )"},  { "DG_DOC", "DG_DOC" } }, SDG->( IndexKey(1) ) )
	
	// Define a Chave unica
	If lForn
		If lIdent
			oModel:GetModel("MdGridSDG"):SetUniqueLine( { 'DG_CODDES','DG_CODVEI','DG_IDENT',"DG_DATVENC","DG_CODFOR","DG_LOJFOR","DG_FILFRT","DG_DOCFRT","DG_SERFRT" } )
		Else
			oModel:GetModel("MdGridSDG"):SetUniqueLine( { 'DG_CODDES','DG_CODVEI','DG_FILORI','DG_VIAGEM',"DG_DATVENC","DG_FILFRT","DG_CODFOR","DG_LOJFOR","DG_DOCFRT","DG_SERFRT"  } )
		EndIf
	Else
		If lIdent
			oModel:GetModel("MdGridSDG"):SetUniqueLine( { 'DG_CODDES','DG_CODVEI','DG_IDENT',"DG_DATVENC" } )
		Else
			oModel:GetModel("MdGridSDG"):SetUniqueLine( { 'DG_CODDES','DG_CODVEI','DG_FILORI','DG_VIAGEM',"DG_DATVENC" } )
		EndIf
	EndIf
	
	// Desabilita a inclusão e exclusão de linhas
	If lBaixaDoc .OR. lBaixaItm
		oModel:GetModel("MdGridSDG"):SetNoInsertLine(.T.)
		oModel:GetModel("MdGridSDG"):SetNoDeleteLine(.T.)
	EndIf

	A070FilModel(@oModel)

Return oModel

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSA070

@sample
//ViewDef()

@author Paulo Henrique Corrêa Cardoso.
@since 07/12/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()
	Local oView         := NIL		// Recebe o objeto da View
	Local oModel        := NIL 		// Objeto do Model 
	Local oStrFSDG      := NIL 		// Recebe a Estrutura da tabela SDG - Field
	Local oStrGSDG      := NIL		// Recebe a Estrutura da tabela SDG - Grid
	Local cYesFields     := ""       // Recebe os campos que não poderão aparecer no Grid
	Local cNoFieldsG     := ""       // Recebe os campos que não poderão aparecer no Grid
	Local aSomaButtons   := {}
	Local nCntFor        := 0

	// Cria a variavel estatica nOpcx
	A70nOpcx()

	oView := FwFormView():New()

	oModel := FwLoadModel( "TMSA070" )

	oView:SetModel(oModel)
	cYesFields := A070YesFld()

	cNoFieldsG := A070NoFldG()

	oStrFSDG := FwFormStruct( 2,"SDG",{|cCampo| AllTrim(cCampo)+"|" $ cYesFields } )
	oStrGSDG := FWFormStruct( 2,"SDG",{|cCampo| !(AllTrim(cCampo)+"|" $ cNoFieldsG)} )

	oView:AddField( 'VwFieldSDG' , oStrFSDG , 'MdFieldSDG' )
	oView:AddGrid ( 'VwGridSDG'  , oStrGSDG , 'MdGridSDG' )

	oView:AddIncrementField( "VwGridSDG","DG_ITEM") 

	//-- Ponto de entrada para incluir botoes na enchoicebar
	If	ExistBlock('TM070BUT')
		aSomaButtons:=ExecBlock('TM070BUT',.F.,.F.,{nOpcx})
		If	ValType(aSomaButtons) == 'A'
			For nCntFor:=1 To Len(aSomaButtons)
				oView:addUserButton(aSomaButtons[nCntFor][3], aSomaButtons[nCntFor][1],aSomaButtons[nCntFor][2],aSomaButtons[nCntFor][3] ) 
			Next
		EndIf
	EndIf

	// Monta a estrutura da Tela
	oView:CreateHorizontalBox( 'CAB', 20)
	oView:CreateHorizontalBox( 'CORPO', 80)

	oView:EnableTitleView ('VwFieldSDG')
	oView:EnableTitleView ('VwGridSDG')

	oView:SetOwnerView('VwFieldSDG','CAB' )
	oView:SetOwnerView('VwGridSDG','CORPO' )
	oView:SetViewCanActivate({|oView| ViewCanAct(oView) })
	oView:SetAfterViewActivate({|oView| AfterVwAct(oView) })
	
	oView:SetFieldAction( 'DG_FILORI', { |oView,cIdForm,cIdCampo,cValue| A070Action(oView,cIdForm,cIdCampo,cValue) } )
	oView:SetFieldAction( 'DG_VIAGEM', { |oView,cIdForm,cIdCampo,cValue| A070Action(oView,cIdForm,cIdCampo,cValue) } )
	oView:SetFieldAction( 'DG_CODVEI', { |oView,cIdForm,cIdCampo,cValue| A070Action(oView,cIdForm,cIdCampo,cValue) } )
Return oView

/*/-----------------------------------------------------------
{Protheus.doc} A70nOpcx()
Preenche a variavel estatiaca nOpcx

Uso: TMSA070

@sample
//A70nOpcx()

@author Paulo Henrique Corrêa Cardoso.
@since 06/02/2017
@version 1.0
-----------------------------------------------------------/*/
Function A70nOpcx()

	DO CASE
		Case IsInCallStack('A070Inc')       
			nOpcx := 3 
		Case IsInCallStack('A070BxDoc')     
			nOpcx := 4 
		Case IsInCallStack('A070Vis')       
			nOpcx := 2 
		Case IsInCallStack('A070BxItem')    
			nOpcx := 8 
		Case IsInCallStack('A070Del')       
			nOpcx := 5 
		Case IsInCallStack('A070Est')       
			nOpcx := 6 
		Case IsInCallStack('TMSA070Leg')    
			nOpcx := 7 
		OTHERWISE
			nOpcx := 0
	ENDCASE

Return

/*/-----------------------------------------------------------
{Protheus.doc} A070NoFldG()
Retorna os campos que não devem ser adicionados no Grid

Uso: TMSA070

@sample
//A070NoFldG()

@author Paulo Henrique Corrêa Cardoso.
@since 07/12/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function A070NoFldG()
Local lTm070NCP     := ExistBlock('TM070NCP') // Verifica ponto de Entrado de campos ocultos
Local aAreaSX3      := {} 
Local aCampos       := {}
Local nCount        := 0
Local cNoFields     := "DG_DOC|DG_EMISSAO|DG_DESTIP|DG_TOTAL|DG_PERC|DG_TES|DG_TIPDES|"

If !IsInCallStack("A070Est")
	cNoFields += "DG_ESTDOC|"
EndIf

If IsInCallStack("A070Vis") .OR. IsInCallStack("A070Del") .OR. IsInCallStack("A070Est")   // Visualizacao, Exclusao ou Estorno da Baixa
	cNoFields += "DG_BAIXA|DG_COND|DG_NUMPARC|DG_PERVENC|DG_VALBAI|"
ElseIf IsInCallStack("A070Inc") // Inclusão
	cNoFields += "DG_BAIXA|DG_NUMSEQ|DG_SEQORI|DG_DATVENC|DG_CUSTO2|DG_CUSTO3|DG_CUSTO4|DG_CUSTO5|DG_VALBAI|DG_DATBAI|DG_MOTBAI|DG_HISTOR|DG_AGENCIA|DG_NUMCHEQ|DG_BANCO|DG_BANCO|DG_NUMCON|DG_NUMCON|DG_FILFRT|DG_DOCFRT|DG_SERFRT|"
ElseIf IsInCallStack("A070BxItem") .OR. IsInCallStack("A070BxDoc")
	cNoFields += "DG_CUSTO2|DG_CUSTO3|DG_CUSTO4|DG_CUSTO5|DG_COND|DG_NUMPARC|DG_PERVENC|DG_BANCO|DG_AGENCIA|DG_NUMCON|DG_NUMCHEQ|"
EndIf

//-- Ponto de Entrada para definir os campos que não aparecerão no grid
If	lTm070NCP
	aAreaSX3 := SX3->( GetArea() )
	SX3->( DbSetOrder(2) )
	aCampos := ExecBlock('TM070NCP',.F.,.F.,{nOpcx}) 
	If ValType(aCampos) == "A" .And. Len(aCampos) > 0
		For nCount := 1 To Len(aCampos)
			If ValType(aCampos[nCount]) == "C" .And. SX3->( MsSeek( aCampos[nCount] ) )
				cNoFields += aCampos[nCount] + "|"
			EndIf
		Next nCount
	EndIf
	RestArea( aAreaSX3)
EndIf

Return cNoFields

/*/-----------------------------------------------------------
{Protheus.doc} A070YesFld()
Retorna os campos que devem ser adicionados no Cabeçalho

Uso: TMSA070

@sample
//A070YesFld()

@author Paulo Henrique Corrêa Cardoso.
@since 07/12/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function A070YesFld()
Local lTm070ECP    := ExistBlock('TM070ECP')
Local aCampos       := {}
Local nCount        := 0
Local cYesFields    := "DG_DOC|DG_EMISSAO|DG_DESTIP|"

//-- Ponto de Entrada para exibir os campos na Enchoice
If	lTm070ECP
	aCampos := ExecBlock('TM070ECP',.F.,.F.,{nOpcx}) 
	If ValType(aCampos) == "A" .And. Len(aCampos) > 0
		For nCount := 1 To Len(aCampos)
			If ValType(aCampos[nCount]) == "C" 
				cYesFields +=  aCampos[nCount] +"|"
			EndIf
		Next nCount
	EndIf
EndIf

Return cYesFields

/*/-----------------------------------------------------------
{Protheus.doc} A070FilModel()
Filtra o carregemento do Grid

Uso: TMSA070

@sample
//A070FilModel(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 08/12/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function A070FilModel(oModel)

If IsInCallStack("A070Est")
	oModel:GetModel('MdGridSDG'):SetLoadFilter({{'DG_STATUS',"'" + StrZero(3,Len(SDG->DG_STATUS))+ "'" , MVC_LOADFILTER_EQUAL }})
ElseIf IsInCallStack("A070BxDoc")
	oModel:GetModel('MdGridSDG'):SetLoadFilter({{'DG_STATUS', "{'" + StrZero(1,Len(SDG->DG_STATUS)) + "','" + StrZero(2,Len(SDG->DG_STATUS)) + "'}", MVC_LOADFILTER_IS_CONTAINED } } )
ElseIf IsInCallStack("A070BxItem")
	oModel:GetModel('MdGridSDG'):SetLoadFilter({{'DG_NUMSEQ',"'" + SDG->DG_NUMSEQ + "'" , MVC_LOADFILTER_EQUAL }})
EndIf

Return 

/*/-----------------------------------------------------------
{Protheus.doc} ViewCanAct()
Valida a Ativação da View

Uso: TMSA070

@sample
//ViewCanAct(oView)

@author Paulo Henrique Corrêa Cardoso.
@since 07/12/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewCanAct(oView)
Local cCusMed    := GetMv("MV_CUSMED")

Local lTMSOPdg	 := AliasInDic('DEG') .AND. SuperGetMV('MV_TMSOPDG',,'0') == '2'

Local lGerador   := SDG->(ColumnPos("DG_GERADOR") > 0)

Private lF12       := .F.
If Type("lBaixa") <> "L"
	Private lBaixa := .F.
EndIf

lBaixa := .F.

Default oView := NIL

If cCusMed == 'O' .And. IsInCallStack("A070Inc")
	Aadd(aSetKey, { VK_F12 , { || Pergunte("TM070D",.T.), lF12 := .T. } } )
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)	
EndIf

If IsInCallStack("A070BxDoc") .Or. IsInCallStack("A070BxItem") //-- Baixa por Doc ou baixa por Item

	If IsInCallStack("A070BxItem") //-- Baixa por Item
		If  Empty(SDG->DG_CODDES) .OR. (SDG->DG_STATUS <> StrZero(1,Len(SDG->DG_STATUS)) .And. SDG->DG_STATUS <> StrZero(2,Len(SDG->DG_STATUS)))
				Help(" ",1,"TMSA07011") //-- Nao ha movimentos em aberto.
				Return .F.	   
		EndIf
	EndIf

	Aadd(aSetKey, { VK_F12 , { || Pergunte("TMA070",.T.), lF12 := .T. } } )
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
	lBaixa := .T.
EndIf

If IsInCallStack("A070Del") //-- Exclusao
	//-- Verifica a origem do movimento de custo
	If (SDG->DG_ORIGEM <> "SDG" .And. SDG->DG_ORIGEM <> "COM") .Or. Iif(lGerador,(!Empty(SDG->DG_GERADOR) .And. AllTrim(SDG->DG_GERADOR) != "TMSA070"),.F.)
		Help(" ",1, "TMSA07002") //O Estorno Nao sera efetuado, pois este Movimento de Custo de Transporte Nao foi gerado por esta Rotina.
		Return .F.
	EndIf			 
	//-- Verifica se existem movimentos baixados na exclusao.
	If !TMSA070VExc(SDG->DG_DOC)
		Return .F.
	EndIf
	//--- Verifica se o contrato ja foi quitado na Operadora de Frotas
	If lTMSOPdg 
		DES->(DbSetOrder(1))
		If DES->(MsSeek(xFilial('DES') + SDG->DG_FILORI + SDG->DG_VIAGEM))
			If DES->DES_STATUS == '2' //Quitado                         
				Help(" ",1, "TMSA07023") //O Estorno não será efetuado, pois o Contrato não está em aberto.         
				Return .F.		
			EndIf
		EndIf
	EndIf
	//-- Verifica se a viagem esta encerrada
	DTQ->(dbSetOrder(2))
	DTY->(dbSetOrder(2))
	If DTQ->( MsSeek( xFilial('DTQ') + SDG->DG_FILORI + SDG->DG_VIAGEM ))		
		If DTQ->DTQ_STATUS == StrZero(3,Len(DTQ->DTQ_STATUS)) .And. ;
		IIf(DA3->(DbSeek(xFilial("DA3")+DA3->DA3_COD)) .And. DA3->DA3_FROVEI != StrZero(1,Len(DA3->DA3_FROVEI)),.T.,.F.) .And. ;
		DTY->(DbSeek(xFilial("DTY")+SDG->DG_FILORI + SDG->DG_VIAGEM))
			//	Help(' ', 1, 'TMSA07024') //-- Viagem Encerrada
			Help(" ",1,"TMSA07014",,STR0018 + SDG->DG_FILORI + '/' + SDG->DG_VIAGEM + '. ' + STR0017 )//"Existe contrato para a viagem, a manutencao no movimento de custo nao podera ser realizada" ### "Viagem"
			Return .F.
		EndIf	
	EndIf
EndIf

If IsInCallStack("A070Est") //-- Estorno de Baixa

	//-- Verifica a origem do movimento de custo
	If SDG->DG_ORIGEM == "DTR" .Or. Iif(lGerador,(!Empty(SDG->DG_GERADOR) .And. AllTrim(SDG->DG_GERADOR) != "TMSA070"),.F.)
		Help(" ",1, "TMSA07002") //O Estorno Nao sera efetuado, pois este Movimento de Custo de Transporte Nao foi gerado por esta Rotina.
		Return .F.

	//-- Qdo a origem for diferente de "SDG" o veiculo e a viagem devera estar preenchida.
	ElseIf SDG->DG_ORIGEM <> "SDG"		
		If Empty(SDG->DG_CODVEI) .Or. ( SDG->DG_MOTBAI == StrZero(1,Len(SDG->DG_MOTBAI)) .And. ( Empty(SDG->DG_FILORI) .Or. Empty(SDG->DG_VIAGEM) ) )
			Help(" ",1, "TMSA07016") //-- Para o estorno da baixa de movimento de viagem que nao foi originado pelo cadastro de movimento de custo, os campos viagem e veiculo tem que estar preenchido.
			Return .F.
		EndIf
	EndIf
	
	//-- Verifica o Status do movimento de custo
	If SDG->DG_STATUS <> StrZero(3,Len(SDG->DG_STATUS)) //-- Baixa Total
		Help(" ",1, "TMSA07015") //-- Para estornar a baixa do movimento de custo, o mesmo devera estar com o status 'Baixa Total'.
		Return .F.
	EndIf	
						
If cCusMed == 'O' 
		Aadd(aSetKey, { VK_F12 , { || Pergunte("TM070D",.T.), lF12 := .T. } } )
		//-- Inicializa Teclas de Atalhos
		TmsKeyOn(aSetKey)	
	EndIf	
EndIf

Return .T.
/*/-----------------------------------------------------------
{Protheus.doc} A070Inc()
Inclusão de registro no Modelo

Uso: TMSA070

@sample
//A070Inc()

@author Paulo Henrique Corrêa Cardoso.
@since 08/12/2016
@version 1.0
-----------------------------------------------------------/*/
Function A070Inc()

FWExecView( STR0004 ,'TMSA070',MODEL_OPERATION_INSERT,, { || .T. },{ || .T. },,,{ || .T. })  //"Incluir"
TmsKeyOff(aSetKey)

Return
/*/-----------------------------------------------------------
{Protheus.doc} A070Est()
Estorno de Baixa

Uso: TMSA070

@sample
//A070Est()

@author Paulo Henrique Corrêa Cardoso.
@since 08/12/2016
@version 1.0
-----------------------------------------------------------/*/
Function A070Est()

	FWExecView( STR0012 ,'TMSA070',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T. },,,{ || .T. })  //"Estorna Baixa"
	TmsKeyOff(aSetKey)
	aSetKey := {}
Return
/*/-----------------------------------------------------------
{Protheus.doc} A070Del()
Exclusão de registro no Modelo

Uso: TMSA070

@sample
//A070Del()

@author Paulo Henrique Corrêa Cardoso.
@since 08/12/2016
@version 1.0
-----------------------------------------------------------/*/
Function A070Del()

	FWExecView( STR0005 ,'TMSA070',MODEL_OPERATION_DELETE,, { || .T. },{ || .T. },,,{ || .T. })  //"Excluir"
	TmsKeyOff(aSetKey)
	aSetKey := {}
Return

/*/-----------------------------------------------------------
{Protheus.doc} A070Vis()
Visualozação de registro no Modelo

Uso: TMSA070

@sample
//A070Vis()

@author Paulo Henrique Corrêa Cardoso.
@since 08/12/2016
@version 1.0
-----------------------------------------------------------/*/
Function A070Vis()

	FWExecView( STR0003 ,'TMSA070',MODEL_OPERATION_VIEW,, { || .T. },{ || .T. },,,{ || .T. })  //"Visualizar"
	TmsKeyOff(aSetKey)
	aSetKey := {}
Return

/*/-----------------------------------------------------------
{Protheus.doc} A070BxDoc()
Baixa de documento

Uso: TMSA070

@sample
//A070BxDoc()

@author Paulo Henrique Corrêa Cardoso.
@since 08/12/2016
@version 1.0
-----------------------------------------------------------/*/
Function A070BxDoc()

	FWExecView( STR0011 ,'TMSA070',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T. },,,{ || .T. })  //"Baixar Docto"
	TmsKeyOff(aSetKey)
	aSetKey := {}
Return

/*/-----------------------------------------------------------
{Protheus.doc} A070BxItem()
Baixa de Item

Uso: TMSA070

@sample
//A070BxItem()

@author Paulo Henrique Corrêa Cardoso.
@since 08/12/2016
@version 1.0
-----------------------------------------------------------/*/
Function A070BxItem()

	FWExecView( STR0013 ,'TMSA070',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T. },,,{ || .T. })  //"Baixar Item"
	TmsKeyOff(aSetKey)
	aSetKey := {}
Return

/*/-----------------------------------------------------------
{Protheus.doc} TMSA070Whn()
Valida se o campo podera ser alterado 

Uso: TMSA070

@sample
//TMSA070Whn()

@author Eduardo de Souza
@since 24/08/04
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 08/12/2016

@version 2.0
-----------------------------------------------------------/*/
Function TMSA070Whn()
	Local oModel     := FwModelActive()	// Recebe o Model Ativo
	Local oView      := NIL				// Recebe a View Ativa
	Local oModelGrid := NIL				// Recebe o Modelo do Grid 
	Local oModelFld  := NIL				// Recebe o Modelo do Field 
	Local lRet       := .T.
	Local cCampo     := ""
	Local aCurrntSel :={}
	Local aAreaSDG   := SDG->(GetArea())
	Local lView      := .F.
	Local lVgeMod3	 := FindFunction('TmsVgeMod3') .And. TmsVgeMod3()

	If ValType(oModel) != "O" .Or. !( oModel:cID $ "TMSA070|TMSAF60"  )
		Return A070WhnOld()
	EndIf
	
	oView  := FwViewActive()
	If lView :=  ValType(oView) == "O"
			
		aCurrntSel := oView:GetCurrentSelect()

		If aCurrntSel <> nIL .and. ValType(aCurrntSel[2])  == "C"
			cCampo := "M->" + aCurrntSel[2]
		Else	
			cCampo := ReadVar()
		EndiF
	Else
		cCampo := ReadVar()
	EndIf

	oModelFld  	:= oModel:GetModel( "MdFieldSDG" ) //Modelo do Fiels
	oModelGrid 	:= oModel:GetModel( "MdGridSDG" ) //grid do folder

	If Type("lBaixa") <> "L"
		Private lBaixa := .F.
	EndIf
	
	If lVgeMod3 .Or. Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
			Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
			Left(FunName(),7) == "TMSA144"

		//-- Nao Permite alterar nenhum campo se o custo ja tiver sido baixado (total)
		SDG->(dbSetOrder(3))
		If !Empty(FwFldGet("DG_NUMSEQ")) .And. SDG->(MsSeek(xFilial('SDG')+ FwFldGet("DG_NUMSEQ"))) .And. SDG->DG_STATUS == StrZero(3,Len(SDG->DG_STATUS)) //-- Baixa Total
			Return(.F.)
		EndIf	
		
		//-- Se a Despesa foi selecionada, so' permitir alterar o campo 'DG_VALBAI'
		If FwFldGet("DG_TIPDES") == "2"  
			lRet := ( cCampo == "M->DG_VALBAI" )                                        
		Else   
			If cCampo == "M->DG_TOTAL"
				//-- Somente permite alterar o campo qdo nao existir informacao no cadastro de despesas.
				lRet := Empty(Posicione("DT7",1,xFilial("DT7")+ FwFldGet("DG_CODDES") ,"DT7_CUSTO1"))
				
			ElseIf cCampo $ "M->DG_BANCO.M->DG_AGENCIA.M->DG_NUMCON.M->DG_NUMCHEQ"
				//-- Somente permite alterar os campos se a Despesa tiver movimento bancario
				lRet := ( Posicione("DT7",1,xFilial("DT7")+ FwFldGet("DG_CODDES") ,"DT7_MOVBCO") == "1" )
				
				If lRet 
					If lVgeMod3 .And. !Empty(FwFldGet("DM5_CODOPE"))
						lRet	:= .F. 
					ElseIf Type('M->DTR_CODOPE')<> 'U' .And. !Empty(M->DTR_CODOPE)
						lRet 	:= .F.
					EndIf
				EndIf
			ElseIf cCampo == "M->DG_VALBAI"
				lRet := .F.
			ElseIf cCampo $ "M->DG_CUSTO1.M->DG_DG_CUSTO2.M->DG_DG_CUSTO3.M->DG_DG_CUSTO4" 
				If lVgeMod3 
					lRet	:= .F. 
				EndIf
			EndIf
		EndIf

	ElseIf cCampo == "M->DG_CUSTO1"
		//-- Somente permite alterar o campo qdo nao existir informacao no cadastro de despesas.
		lRet := Empty(Posicione("DT7",1,xFilial("DT7")+ FwFldGet("DG_CODDES") ,"DT7_CUSTO1"))

	ElseIf cCampo == "M->DG_FILORI" .OR. cCampo == "M->DG_VIAGEM"
		
		lRet := FwFldGet("DG_NUMPARC") <= 1 .AND.  !Empty(FwFldGet("DG_CODVEI"))

		// permite digitar somente se não estiver com o valor gravado no banco 
		If  lRet .AND.( nOpcx == 4 .OR. nOpcx == 8 .OR. IsInCallStack("A070BxDoc") .OR. IsInCallStack("A070BxItem"))

			SDG->(dbSetOrder(1)) //DG_FILIAL+DG_DOC+DG_CODDES+DG_ITEM     
			If SDG->(dbSeek( FwxFilial("SDG") + oModelFld:GetValue("DG_DOC") + FwFldGet("DG_CODDES") + FwFldGet("DG_ITEM") ))
				lRet := Empty(SDG->DG_VIAGEM) .OR. Empty(SDG->DG_FILORI)
			EndIf
		EndIf

	ElseIf cCampo == "M->DG_CODVEI"

		// permite digitar somente se não estiver com o valor gravado no banco 
		If  nOpcx == 4 .OR. nOpcx == 8 .OR. IsInCallStack("A070BxDoc") .OR. IsInCallStack("A070BxItem")
				
			SDG->(dbSetOrder(1)) //DG_FILIAL+DG_DOC+DG_CODDES+DG_ITEM     
			If SDG->(dbSeek( FwxFilial("SDG") + oModelFld:GetValue("DG_DOC") + FwFldGet("DG_CODDES") + FwFldGet("DG_ITEM") ))
				lRet := Empty(SDG->DG_CODVEI)
			EndIf
		EndIf

	ElseIf cCampo == "M->DG_NUMPARC" .OR. cCampo == "M->DG_PERVENC"
		lRet := Empty( FwFldGet("DG_COND") )  

		If lRet
			If !Empty(FwFldGet("DG_FILORI")) .AND. !Empty(FwFldGet("DG_VIAGEM"))
				lRet := .F.
			EndIf
		EndIf                            
	ElseIf cCampo == "M->DG_VALCOB" .AND. (IsInCallStack("A070BxDoc") .OR. IsInCallStack("A070BxItem"))
			
			If Empty(oModelGrid:GetValue("DG_VALBAI"))
				oModelGrid:LoadValue("DG_VALBAI",oModelGrid:GetValue("DG_VALCOB"))
				oModelGrid:LoadValue("DG_SALDO",( oModelGrid:GetValue("DG_VALCOB") - oModelGrid:GetValue("DG_VALBAI") ))
			EndIf
			If lView
				oView:Refresh("VwGridSDG")
			EndIf
			
			lRet := .F.
	ElseIf cCampo == "M->DG_CODFOR" .OR. cCampo == "M->DG_LOJFOR"
		If !Empty(FwFldGet("DG_CODVEI"))
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaSDG)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} AfterVwAct
Ações apos a ativação da View e do Model antes de abrir a tela

Uso: TMSA070

@sample
//AfterVwAct(oView)

@author Paulo Henrique Corrêa Cardoso.
@since 08/12/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function AfterVwAct(oView)
	Local oModel 	   := Nil         	// Recebe o Model 
	Local oMdlGrd      := NIL
	
	Default oView   := FwViewActive()

	oModel  := oView:GetModel()
    oMdlGrd := oModel:GetModel("MdGridSDG")

	If IsInCallStack("A070Inc") .OR. oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModel:LoadValue("MdFieldSDG","DG_DOC",NextNumero("SDG",1,"DG_DOC",.T.))
	ElseIf  IsInCallStack("A070BxDoc") .OR.  IsInCallStack("A070BxItem")  .OR. nOpcx == 8 .OR.  nOpcx == 4  
		oMdlGrd:SetValue("DG_VIAGEM" ,oMdlGrd:GetValue("DG_VIAGEM"))
		oModel:lModify := .T.
		oView:lModify := .T.
	ElseIf  IsInCallStack("A070Est")  .OR. nOpcx == 6
		oMdlGrd:SetValue("DG_ESTDOC" ,oMdlGrd:GetValue("DG_ESTDOC"))
		oModel:lModify := .T.
		oView:lModify := .T.
	EndIf
	
	oView:Refresh("VwFieldSDG")
Return

/*/-----------------------------------------------------------
{Protheus.doc} A070ModEdt
Altera o modo de Edição dos campos dependendo da rotina chamada.

Uso: TMSA070

@sample
//A070ModEdt(oStructGrd)

@author Paulo Henrique Corrêa Cardoso.
@since 08/12/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function A070ModEdt(oStructFld,oStructGrd)
	Local lEstorno  := IsInCallStack("A070Est")
	Local lBaixaDoc := IsInCallStack("A070BxDoc") 
	Local lBaixaItm := IsInCallStack("A070BxItem")
	Local lIdent	:= SDG->(FieldPos("DG_IDENT")) > 0 .And. nModulo<>43

	If lEstorno .OR. lBaixaDoc .OR. lBaixaItm

		oStructFld:SetProperty("*", MODEL_FIELD_WHEN , {|| .F.  })
		oStructGrd:SetProperty("*", MODEL_FIELD_WHEN , {|| .F.  })

		If lEstorno
			oStructGrd:SetProperty("DG_ESTDOC", MODEL_FIELD_WHEN , {|| .T. })

		ElseIf lBaixaDoc .OR. lBaixaItm
			oStructGrd:SetProperty("DG_BAIXA" , MODEL_FIELD_WHEN ,  {|| &(Posicione("SX3",2,"DG_BAIXA","X3_WHEN"))  })
			oStructGrd:SetProperty("DG_FILORI", MODEL_FIELD_WHEN ,  {|| &(Posicione("SX3",2,"DG_FILORI","X3_WHEN"))  })
			oStructGrd:SetProperty("DG_VIAGEM", MODEL_FIELD_WHEN ,  {|| &(Posicione("SX3",2,"DG_VIAGEM","X3_WHEN"))  })
			oStructGrd:SetProperty("DG_MOTBAI", MODEL_FIELD_WHEN ,  {|| &(Posicione("SX3",2,"DG_MOTBAI","X3_WHEN"))  })
			oStructGrd:SetProperty("DG_VALBAI", MODEL_FIELD_WHEN ,  {|| &(Posicione("SX3",2,"DG_VALBAI","X3_WHEN"))  })
			oStructGrd:SetProperty("DG_VALCOB", MODEL_FIELD_WHEN ,  {|| &(Posicione("SX3",2,"DG_VALCOB","X3_WHEN"))  })
			oStructGrd:SetProperty("DG_DATBAI", MODEL_FIELD_WHEN ,  {|| &(Posicione("SX3",2,"DG_DATBAI","X3_WHEN"))  })
			oStructGrd:SetProperty("DG_CODVEI", MODEL_FIELD_WHEN ,  {|| &(Posicione("SX3",2,"DG_CODVEI","X3_WHEN"))  })
			oStructGrd:SetProperty("DG_DESVEI", MODEL_FIELD_WHEN ,  {|| .T. })
			oStructGrd:SetProperty("DG_HISTOR", MODEL_FIELD_WHEN ,  {|| .T.  })
			
			If lIdent
				oStructGrd:SetProperty("DG_IDENT", MODEL_FIELD_WHEN ,  {|| .T.    })
			EndIf
			
		EndIf

	EndIf

Return

/*/-----------------------------------------------------------
{Protheus.doc} TMSA070VExc()
Valida exclusao do movimento de custo  

Uso: TMSA070

@sample
//TMSA070VExc(cDoc)

@author Eduardo de Souza
@since 25/08/04
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 08/12/2016

@version 2.0
-----------------------------------------------------------/*/
Function TMSA070VExc(cDoc)
	Local lRet     := .T.
	Local aAreaSDG := SDG->(GetArea())
	Local aAreaSE2 := SE2->(GetArea())
	Local cPrefixo := TMA250GerPrf(cFilAnt)
	Local nCount   := 0
	Local aLegenda := {}
	Local cParcela := ""

	SDG->(DbSetOrder(1))
	If SDG->(MsSeek(xFilial("SDG")+cDoc))
		While SDG->(!Eof()) .And. SDG->DG_FILIAL + SDG->DG_DOC == xFilial("SDG") + cDoc
			If SDG->DG_STATUS <> StrZero(1,Len(SDG->DG_STATUS)) .And. SDG->DG_ORIGEM <> 'COM'  
				Help(" ", 1,"TMSA07010") //-- Existe movimento de custo baixado para documento, a exclusao nao sera permitida.
				lRet := .F.
				Exit
			EndIf
			
			cFornec := Posicione("DA3",1,xFilial("DA3")+SDG->DG_CODVEI,"DA3_CODFOR") 
			cLoja   := Posicione("DA3",1,xFilial("DA3")+SDG->DG_CODVEI,"DA3_LOJFOR")
			
			SE2->(DbSetOrder(1)) //-- E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			
			cParcela := IIf(SDG->(FieldPos("DG_PARC")) > 0 , SDG->DG_PARC , "01")
			
			If SE2->(DbSeek(xFilial("SE2")+cPrefixo+PadR(SDG->DG_VIAGEM,Len(SE2->E2_NUM))+cParcela+"NDF"+cFornec+cLoja))
				aLegenda := Fa040Legenda("SE2")
				For nCount := 1 To Len( aLegenda )
					If SE2->( &(aLegenda[nCount,1]) ) .And. aLegenda[nCount,2] != "BR_VERDE"
						Help('', 1, 'TMSA07025') //-- {"Não é possível excluir o movimento, pois o título não está em aberto"
						lRet := .F.
						Exit
					EndIf
				Next					
			EndIf
			
			SDG->(DbSkip())
		EndDo
	EndIf

	RestArea( aAreaSE2 )
	RestArea( aAreaSDG )

Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} PosVldSDG() --> Antigo TMSA070LinOK
Valida a linha Digitada        

Uso: TMSA070

@sample
//PosVldSDG(oModelGrd,nLine)

@author Patricia A. Salomao
@since 05/11/2001
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 14/12/2016

@version 2.0
-----------------------------------------------------------/*/
Static Function PosVldSDG(oModelGrd,nLine,cFilOri,cViagem,cCodVei )
	Local lRet     := .T.
	Local lGerTit  := GetMV('MV_GERTIT' ,,.T.)         // Verifica se devera gerar ou nao contas a pagar (SE2)
	Local nCnt     := 0
	Local nSaldo   := 0
	Local aCposBx  := {}
	Local cPrefixo := "" 
	Local cSeek    := ""
	Local cTipNDF  := Padr( "NDF", Len( SE2->E2_TIPO ) ) //-- Gera Titulo Tipo "NDF"
	Local cParcela := StrZero(1, Len(SE2->E2_PARCELA))
	//-- Operadoras de Frota/Vale-Pedagio
	Local lTMSOPdg := AliasInDic('DEG') .And. SuperGetMV('MV_TMSOPDG',,'0') == '2'
	Local lIdent	:= SDG->(FieldPos("DG_IDENT")) > 0.And. nModulo<>43
	Local cIdent	:= ""
    Local lUsaForn  := SDG->(ColumnPos("DG_CODFOR") > 0 )
	Local  lForn    := .F.
	Local lVgeMod3	 := FindFunction('TmsVgeMod3') .And. TmsVgeMod3()

	Default cFilOri		:= ""
	Default cViagem		:= ""
	Default cCodVei		:= ""

	If Type("lBaixa") <> "L"
		Private lBaixa := .F.
	EndIf  

	If Type("INCLUI") == "U"
		INCLUI	:= .T. 
	EndIf  

	If !oModelGrd:IsDeleted()
		If lBaixa
			//-- Valida preenchimento dos campos na baixa
			If oModelGrd:GetValue("DG_BAIXA",nLine) == "1"
				aCposBx := { "DG_VALBAI", "DG_DATBAI", "DG_MOTBAI" }
				For nCnt := 1 To Len(aCposBx)
					If Empty(oModelGrd:GetValue(aCposBx[nCnt],nLine))
						Help('',1,'OBRIGAT2',,RetTitle(aCposBx[nCnt]),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
						lRet := .F.
						Exit
					EndIf
				Next nCnt	

				//-- Qdo informado o motivo normal e o veiculo nao for proprio, o preenchimento do campo viagem sera obrigatorio.
				If lRet .And. oModelGrd:GetValue("DG_MOTBAI",nLine) == StrZero(1,Len(SDG->DG_MOTBAI)) //-- Normal
					DA3->(DbSetOrder(1))
					If DA3->(MsSeek(xFilial("DA3")+oModelGrd:GetValue("DG_CODVEI",nLine)))
						If DA3->DA3_FROVEI <> "1" //-- Proprio
							If lIdent
								If Empty(oModelGrd:GetValue("DG_IDENT",nLine))
									Help('',1,'OBRIGAT2',,RetTitle("DG_IDENT"),04,01) ////Um ou alguns campos obrigatorios nao foram preenchidos no Browse
									lRet := .F.
								EndIf
							Else
								If Empty(oModelGrd:GetValue("DG_FILORI",nLine)) .Or. Empty(oModelGrd:GetValue("DG_VIAGEM",nLine))
									Help('',1,'OBRIGAT2',,RetTitle("DG_FILORI")+" "+RetTitle("DG_VIAGEM"),04,01) ////Um ou alguns campos obrigatorios nao foram preenchidos no Browse
									lRet := .F.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		
		//-- Na inclusao devera ser informado o campo veiculo ou viagem.
		If lRet .And.(nOpcx == 3 .OR. IsInCallStack("A070Inc") .OR.  INCLUI)
			
			// Verifica o uso do campo Fornecedor e se o mesmo esta preenchido
			If lUsaForn
				If !Empty(oModelGrd:GetValue("DG_CODFOR",nLine)) .AND. !Empty(oModelGrd:GetValue("DG_LOJFOR",nLine))
					lForn := .T.
				EndIf
			Else
				lForn := .T.
			EndIf

			If lIdent
				cIdent := oModelGrd:GetValue("DG_IDENT",nLine)
				If (Empty(oModelGrd:GetValue("DG_IDENT",nLine)) .And. Empty(cIdent) .AND. !lForn )
					Help(" ",1,"TMSA07007")  //Devera ser informado o campo Veiculo ou a Viagem.
					lRet := .F.
				EndIf			
			Else	
				If Empty(cFilOri) .And. Empty(cViagem)
					cFilOri := oModelGrd:GetValue("DG_FILORI",nLine)
					cViagem := oModelGrd:GetValue("DG_VIAGEM",nLine)
				Endif
				
				If Empty(cCodVei)
					cCodVei	:= oModelGrd:GetValue("DG_CODVEI",nLine)
				EndIf 

				If (Empty( cCodvei ) .AND. !lForn ) .And. ( Empty(cFilOri) .Or. Empty(cViagem) )
					Help(" ",1,"TMSA07007")  //Devera ser informado o campo Veiculo ou a Viagem.
					lRet := .F.
				EndIf						
			EndIf
			DTY->(DbSetOrder(2))
			If !Empty(cFilOri) .And. !Empty(cViagem) .And. DTY->(MsSeek(cSeek:=xFilial("DTY")+cFilOri+cViagem ))
				If (!lTMSOPdg)
					Do While !DTY->(Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM) == cSeek
						If DTY->DTY_TIPCTC == '1' .Or.  DTY->DTY_TIPCTC == '2' //-- Contrato 'Por Viagem' ou 'Por Periodo'
							nSaldo := 0
							If lGerTit
								//-- Verifica o Prefixo do Titulo
								cPrefixo := TMA250GerPrf(cFilAnt)					    
								dbSelectArea("SE2")
								dbSetOrder(6)
								If lRet .And. MsSeek( xFilial("SE2")+DTY->DTY_CODFOR+DTY->DTY_LOJFOR+cPrefixo+DTY->DTY_NUMCTC ) 				
									//-- Verifica se o Valor da Despesa e maior que o saldo do titulo      
									nSaldo := SaldoTit(cPrefixo,DTY->DTY_NUMCTC,cParcela,cTipNDF,,"P",DTY->DTY_CODFOR,,,,DTY->DTY_LOJFOR) 
								EndIf	
							Else                          
								SDG->(dbSetOrder(5))
								SDG->(MsSeek(xFilial("SDG")+DTY->DTY_FILORI+DTY->DTY_VIAGEM))
								Do While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == xFilial("SDG")+DTY->DTY_FILORI+DTY->DTY_VIAGEM
									nSaldo += SDG->DG_VALCOB
									SDG->(dbSkip())
								EndDo
							EndIf		
							If nSaldo == 0
								Help('', 1, 'TMSA07022') //-- Titulo ja baixado ...
								lRet := .F.
							EndIf
							If lRet .And. oModelGrd:GetValue("DG_VALCOB",nLine) > nSaldo
								Help('', 1, 'TMSA07021') //-- Valor da Despesa nao pode ser maior que o Saldo do Titulo
								lRet := .F.
							EndIf			  
							Exit									
						EndIf	  
						DTY->(dbSkip())
					EndDo   		   
				EndIf
			EndIf

			If !lVgeMod3 .And. Empty(oModelGrd:GetValue("DG_COND",nLine)) .AND. Empty(oModelGrd:GetValue("DG_PERVENC",nLine)) .AND. oModelGrd:GetValue("DG_NUMPARC",nLine) > 1
				Help('', 1, 'TMSA07027') //-- 'Campo "Condição de Pagamento" ou "Período de Vencimento" deve ser preenchidos, caso o numero de parcelas seja maior que 1. '
				lRet := .F.
			EndIf

		EndIf

	EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl() --> Antigo ³TMSA070TOk
Função que realiza a validação do Modelo antes da Gravação       

Uso: TMSA070

@sample
//PosVldMdl(oModel)

@author Eduardo de Souza
@since 26/08/2004
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 14/12/2016

@version 2.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
	Local lRet        := .T.              // Recebe o Retorno
	Local lEstorno    := IsInCallStack("A070Est")
	Local oModelGrd   := NIL
	Local oModelFld   := NIL
	Local cFilOri     := ""
	Local cViagem     := ""
	Local cCodVei     := ""
    Local aViagens    := {}
	Local nPos        := 0
	Local lGerAdf     := GetMV("MV_GERADF",,.F.)  // Gera Titulo de Adiantamento de Frete com valor superior ao Valor do Frete+Pedagio
	Local lRetPE     := .F.
	Local lChangeDoc := .F.  
	Local cMay       := ''
    Local nCnt       := 0
	oModelFld := oModel:GetModel("MdFieldSDG")
	oModelGrd := oModel:GetModel("MdGridSDG")

	If Type("lBaixa") <> "L"
		Private lBaixa := .F.
	EndIf  

	//-- Valida baixa do movimento de custo
	If lBaixa
		
		For nCnt := 1 To oModelGrd:Length()
			oModelGrd:Goline(nCnt)
			
			//-- Verifica se o valor do adiantamento eh maior que o valor do frete.
			cFilOri := oModelGrd:GetValue("DG_FILORI",nCnt)
			cViagem := oModelGrd:GetValue("DG_VIAGEM",nCnt)
			cCodVei := oModelGrd:GetValue("DG_CODVEI",nCnt)	
		
			If !Empty(cFilOri) .And. !Empty(cViagem) .And. !Empty(cCodVei)
				If ( nPos:= Ascan( aViagens, { |x| x[1] + x[2] + x[3] == cFilOri + cViagem + cCodVei } ) ) == 0
					Aadd( aViagens, { cFilOri, cViagem, cCodVei, oModelGrd:GetValue("DG_VALBAI",nCnt) } )
				Else
					aViagens[nPos,4] += oModelGrd:GetValue("DG_VALBAI",nCnt)
				EndIf
			EndIf

		Next nCnt

		//-- Nao permite valor do adiantamento maior que o valor do frete.
		For nCnt := 1 To Len(aViagens)
			DTR->(DbSetOrder(3))
			If DTR->(MsSeek(xFilial("DTR")+aViagens[nCnt,1]+aViagens[nCnt,2]+aViagens[nCnt,3]))
				If !lGerAdf .And. DTR->DTR_VALFRE > 0 .And. ( DTR->DTR_ADIFRE + aViagens[nCnt,4] ) > DTR->DTR_VALFRE
					Help("",1,"TMSA07020") //-- O total dos adiantamentos nao podera ser maior que o valor do frete.
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nCnt


	//-- Nao permite Estornar ou Incluir Movto. Custo, para as viagens que ja tenham contrato de Carreteiro gerado
	ElseIf lEstorno .Or. nOpcx == 3 .OR. IsInCallStack("A070Inc") .OR.  INCLUI 
	
		For nCnt := 1 To oModelGrd:Length()
			oModelGrd:Goline(nCnt)

			If !oModelGrd:IsDeleted()                                 

				If oModelGrd:GetValue("DG_ESTDOC",nCnt) == '1' .Or. cTmsErp == '1' //--Se TMS estiver Integrado com Datasul, não permite apontar despesas para viagem com CTC gerado.
					//-- Verifica se existe contrato para a viagem				
					cFilOri := oModelGrd:GetValue("DG_FILORI",nCnt)
					cViagem := oModelGrd:GetValue("DG_VIAGEM",nCnt)
					If !Empty(cFilOri) .And. !Empty(cViagem)
						DTY->(DbSetOrder(2))
						If DTY->(MsSeek(xFilial("DTY")+cFilOri+cViagem))
							lRet:= .F.
						
							If lRestRepom
								lRet:= TMSA070REP(cFilOri,cViagem)
							EndIf 

							If !lRet
								Help(" ",1,"TMSA07014",,STR0018 + cFilOri + '/' + cViagem + '. ' + STR0017 + AllTrim(Str(nCnt)),4,01) //"Existe contrato para a viagem, a manutencao no movimento de custo nao podera ser realizada" ### "Viagem" ### "Linha"
								Exit
							EndIf	
						EndIf
					EndIf

				EndIf	

				If  nOpcx == 3 .OR. IsInCallStack("A070Inc") .OR. INCLUI
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se durante a digitacao n„o foi incluido um documento³
					//³ com o mesmo numero por outro usuario.                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SDG->(DbSetOrder(1))
					SDG->(MsSeek(xFilial("SDG")+ oModelFld:GetValue("DG_DOC") ) )
					cMay := "SDG"+Alltrim(xFilial("SDG"))+ oModelFld:GetValue("DG_DOC")
					While SDG->DG_FILIAL + SDG->DG_DOC == xFilial("SDG") +  oModelFld:GetValue("DG_DOC") .Or.!MayIUseCode(cMay)
						oModelFld:LoadValue("DG_DOC") := NextNumero("SDG",1,"DG_DOC",.T.)
						lChangeDoc := .T.
						cMay := "SDG"+Alltrim(xFilial("SDG"))+ oModelFld:GetValue("DG_DOC")
						SDG->(DbSkip())
					EndDo
					If lChangeDoc
						Help("",1,"A240DOC",,oModelFld:GetValue("DG_DOC"),4,30) //O documento digitado ja foi usado por outro usuario durante a digitacao deste movimento. O novo numero de documento e
					EndIf

				EndIf

			EndIf	
		Next nCnt

	EndIf

	// Executa o Ponto de Entr
	If	ExistBlock("TMA070TOK")
		lRetPE:=ExecBlock("TMA070TOK",.F.,.F.,{nOpcx}) 
		If	ValType(lRetPE)=="L"
			lRet := lRetPE
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CommitMdl
Gravacao dos dados do roteiro da viagem

@author Paulo Henrique Corrêa Cardoso

@since 08/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CommitMdl( oModel  )
	Local lRet       := .T.              // Recebe o Retorno
	Local aAreaAnt   := GetArea()
	Local aAreaDTQ   := DTQ->(GetArea())
	Local aAreaDTR   := DTR->(GetArea())
	Local cCusMed    := GetMv("MV_CUSMED")
	Local lCtbOnLine := .F.
	Local oModelGrd  := NIL
	Local oModelFld  := NIL
	Local nCntFor    := 0
	Local aMovtos    := {}
	Local lTMSOPdg   := AliasInDic('DEG') .And. SuperGetMV('MV_TMSOPDG',,'0') == '2'//-- Operadoras de Frota/Vale-Pedagio
	Local cOrigem    := ""
	Local lGerTit    := GetMV('MV_GERTIT' ,,.T.)         // Verifica se devera gerar ou nao contas a pagar (SE2)
	Local cParc      := ""
	Local cSeek      := ""
	Local cNatuDeb   := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) //-- Natureza do Titulo
	Local cTipNDF    := Padr( "NDF", Len( SE2->E2_TIPO ) ) //-- Gera Titulo Tipo "NDF"
    Local lBaixa     := .F.  
	Local lGerComp	 := .F.
	Local cFilOri    := ""
	Local cViagem    := ""
	Local cCodFor    := ""
	Local cLojFor    := ""
	Local cPrefixo   := ""
	Local aAreaSDG   := {}
	Local aNoFields  := {}
	Local oView      := FwViewActive()
	Local aParamFnc  := {}
	Local aParcelas  := {}
    Local nSobraTot  := 0
	Local nSobraParc := 0
	Local nParcela   := 0
	Local cParcela   := ""
	Local nPerVenc   := 0
	Local nDataVenc  := 0
	Local dDataVenc  := dDataBase
	Local nCnt       := 0
	Local nCntPai    := 0
	Local lIdent	 := SDG->(FieldPos("DG_IDENT")) > 0 .And. nModulo <> 43 
	Local cNumSeq    := ""
	Local dDataBai   := CtoD("  /  /  ")
	Local cMotBai    := ""
	Local nValBai    := 0
	Local cHistor    := ""
	Local cIdent     := ""
	Local cCodVei    := ""
	Local lEstDoc    := .F.
	Local lDigita    := .F.
	Local lAglutina  := .F.
	Local lPosEstDoc := oModel:HasField("MdGridSDG","DG_ESTDOC")
	Local lRetTra		:= .T.
	Local aRetSx5	:= {}
	Local nCountSX5 := 0
	Local aCabSDG	:= {} 

	Private nHdlPrv     :=  0    // Endereco do arquivo de contra prova dos lanctos cont.
	Private cLoteTMS    := ''    // Numero do lote para lancamentos do TMS    
	Private lCriaHeader := .T.   // Para criar o header do arquivo Contra Prova    
	Private nTotal      := 0 	 // Total dos lancamentos contabeis
	Private cArquivo    := ''    // Nome do arquivo contra prova	
	Private aRecnoSDG   := {}
	Private oDTClass    := Nil
	
	If Type("nLinPai") == "U"
		Private nLinPai := 0
	EndIf

	//| Valida se existe a classe de integração EAI Contas Pagar
	If Len(getSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
		oDTClass := TransportDocumentClass():New()
	EndIf 

	oModelGrd := oModel:GetModel("MdGridSDG")
	oModelFld := oModel:GetModel("MdFieldSDG")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o custo medio e' calculado On Line               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCusMed == "O"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona numero do Lote para Lancamentos do Estoque         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cLoteTMS := "TMS "
		aRetSx5 := FwGetSx5('09')		
		If Len(aRetSX5) > 0
			For nCountSX5:= 1 To Len(aRetSX5)
				If aRetSX5[nCountSX5][3] == "TMS"
					cLoteTMS := aRetSX5[nCountSX5][4]
					Exit
				EndIf
			Next nCountSX5
		EndIf
		
	EndIf

	Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o custo medio e' calculado On Line               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCusMed == 'O'  
			lCtbOnLine:= .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se necessario cria o cabecalho do arquivo de prova           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCriaHeader
				lCriaHeader := .F.
				nHdlPrv := HeadProva(cLoteTMS,"TMSA070",cUserName,@cArquivo)
				If nHdlPrv < 0
					Help(" ",1,"SEM_LANC") //Nao foi possível abrir o arquivo de Contra Prova
					lRetTra:= .F.
					Break 
				EndIf			
			EndIf

		EndIf

		If	IsInCallStack("A070Del")  .OR. oModel:GetOperation() == MODEL_OPERATION_DELETE // Exclui                            
			//-- Exclusao do Movimento do Custo de Transporte
			For nCntFor := 1 To oModelGrd:Length()
			
				//-- Verifica se o Movimento esta vinculado a Operadoras de Frota
				//-- Caso afirmativo, primeiro estorna o Movimento na Operadora de Frotas para depois
				//-- prosseguir com o estorno do movimento no Protheus

				oModelGrd:GoLine(nCntFor)

				DTR->(DbSetOrder(1))
				DTR->(MsSeek(xFilial('DTR')+SDG->(DG_FILORI + DG_VIAGEM))) 
				
				aMovtos:= {}
				If lTMSOPdg .And. !Empty(oModelGrd:GetValue('DG_FILORI')) .And. !Empty(oModelGrd:GetValue('DG_VIAGEM'))
					DEN->(DbSetOrder(1)) //-- DEN_FILIAL+DEN_FILORI+DEN_VIAGEM
					If DEN->(MsSeek(xFilial('DEN') + oModelGrd:GetValue('DG_FILORI') + oModelGrd:GetValue('DG_VIAGEM')))
						While DEN->(DEN_FILIAL+DEN_FILORI+DEN_VIAGEM) == xFilial('DEN') + oModelGrd:GetValue('DG_FILORI') + oModelGrd:GetValue('DG_VIAGEM')
							If Rtrim(DEN->DEN_IDREG) == xFilial('SDG') + SDG->DG_DOC + oModelGrd:GetValue('DG_CODDES') + oModelGrd:GetValue('DG_ITEM')
								AAdd(aMovtos, {	xFilial('SDG') + SDG->DG_DOC + oModelGrd:GetValue('DG_CODDES') + oModelGrd:GetValue('DG_ITEM'),;
												DEN->DEN_CODMOV,;
												oModelGrd:GetValue('DG_CUSTO1'),;
												DEN->DEN_ACAO,;
												'1'} )
							EndIf
							DEN->(DbSkip())
						EndDo
					EndIf	
				EndIf            
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Envia os Movimentos para a Operadora³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If !Empty(aMovtos)
					lRet:= TM70IncMov(DTR->DTR_CODOPE, DTR->DTR_FILORI, DTR->DTR_VIAGEM, aMovtos)	
				EndIf

				//Verifica se a viagem utiliza REPOM.
				If lTMSOPdg .And. !Empty(SDG->DG_FILORI) .And. !Empty(SDG->DG_VIAGEM)
					lGerComp:= TM70GerCmp(SDG->DG_FILORI,SDG->DG_VIAGEM)							
				EndIf							
				
				If lRet
					cFilOri  := oModelGrd:GetValue('DG_FILORI',nCntFor)
					cViagem  := oModelGrd:GetValue('DG_VIAGEM',nCntFor) 
					cCodFor	 := Posicione("DA3",1,xFilial("DA3")+oModelGrd:GetValue('DG_CODVEI',nCntFor),"DA3_CODFOR")
					cLojFor	 := Posicione("DA3",1,xFilial("DA3")+oModelGrd:GetValue('DG_CODVEI',nCntFor),"DA3_LOJFOR")
					cPrefixo := TMA250GerPrf(cFilAnt)                  			   
					DTY->(DbSetOrder(2))
					If !Empty(cFilOri) .And. !Empty(cViagem) .And. lGerTit
						If (!lTMSOPdg .Or. lGerComp)
							TMA250DelTit(cPrefixo, cViagem, ,cCodFor, cLojFor, "", "", IIf(SDG->(FieldPos("DG_PARC")) > 0 , SDG->DG_PARC , "01"))	
						EndIf
					EndIf
					SDG->(DbSetOrder(1))
					If SDG->(MsSeek(xFilial("SDG")+SDG->DG_DOC+oModelGrd:GetValue("DG_CODDES",nCntFor)+oModelGrd:GetValue("DG_ITEM",nCntFor)))
						aAreaSDG     := SDG->(GetArea())
						dbSelectArea('SDG')
						dbSetOrder(7)
						If MsSeek(xFilial("SDG")+SDG->DG_ORIGEM + SDG->DG_NUMSEQ)    
							Do While !Eof() .And. DG_FILIAL+DG_ORIGEM+DG_SEQMOV == xFilial('SDG')+SDG->DG_ORIGEM  + SDG->DG_NUMSEQ
								If lCtbOnLine .And. nHdlPrv <> 0 
									If !Empty(SDG->DG_DTLANC)
											nTotal += DetProva(nHdlPrv,"902",'TMSA070',cLoteTMS)
									EndIf	                                            
									If  !Empty(SDG->DG_DTLAEMI)
										nTotal += DetProva(nHdlPrv,"904",'TMSA070',cLoteTMS)
									EndIf			
								EndIf
								SDG->(DbSkip())
							EndDo	
						EndIf	
						RestArea(aAreaSDG)
					EndIf
				EndIf				
			Next
		ElseIf	IsInCallStack("A070Inc")  .OR. oModel:GetOperation() == MODEL_OPERATION_INSERT // inclusao

			AADD(aNoFields,"DG_ITEM")
			nParcela := 1
			nCntPai  := 0 

			For nCntFor := 1 To oModelGrd:Length()

				nCntPai := nCntFor + (nParcela -1)
				oModelGrd:GoLine(nCntPai)
				aParamFnc := {}
				
				If !oModelGrd:IsDeleted() 

					//-- Retorna a quantidade de parcelas
					aParcelas  := {}
					nSobraTot  := oModelGrd:GetValue("DG_CUSTO1",nCntPai)
					nSobraParc := oModelGrd:GetValue("DG_VALCOB",nCntPai)

					If !Empty(oModelGrd:GetValue("DG_COND",nCntPai))
						aParcelas:= Condicao(oModelGrd:GetValue("DG_VALCOB",nCntPai),oModelGrd:GetValue("DG_COND",nCntPai))
					Else
						nParcela  := oModelGrd:GetValue("DG_NUMPARC",nCntPai)
						nPerVenc  := oModelGrd:GetValue("DG_PERVENC",nCntPai)
						nParcela  := Iif(nParcela==0,1,nParcela) //-- Inicializa o numero de parcelas
						nDataVenc := dDataBase
						For nCnt := 1 To nParcela
							dDataVenc := dDataVenc + nPerVenc
							Aadd( aParcelas, { dDataVenc, oModelGrd:GetValue("DG_VALCOB",nCntPai) / nParcela } )
						Next nCnt
					EndIf


					If Len(aParcelas) > 1
						aParamFnc := {oModelGrd,nCntPai,aParcelas,@nSobraTot,@nSobraParc}
						TMSCopyLin(oView,oModelGrd,nCntPai,Len(aParcelas)-1,aNoFields,"VwGridSDG",.F.,"DG_ITEM","A70GrvParc",aParamFnc)
						
						oModelGrd:GoLine(nCntPai)
						A70GrvParc(oModelGrd,nCntPai,aParcelas,@aParamFnc[4],@aParamFnc[5])

						nCntPai += Len(aParcelas)-1
					Else
						A70GrvParc(oModelGrd,nCntPai,aParcelas,@nSobraTot,@nSobraParc)
					EndIf
				EndIf

			Next nCntFor	
			nCntParc := 0
			nLinPai  := 0
			
		EndIf

		If lRet 
			If FWFormCommit(oModel,,,,,,)
				
				If 	IsInCallStack("A070Inc")  .OR. oModel:GetOperation() == MODEL_OPERATION_INSERT // inclusao
					For nCntFor := 1 To oModelGrd:Length()
				
						dbSelectArea("SDG")
						SDG->(dbSetOrder(1))
						If SDG->(dbSeek( FwxFilial("SDG") + oModelFld:GetValue("DG_DOC") + oModelGrd:GetValue("DG_CODDES",nCntFor) + oModelGrd:GetValue("DG_ITEM",nCntFor) ))
						
							//-- Caso a viagem seja informada baixa o movimento de custo
							If lIdent .And. (!Empty( oModelGrd:GetValue("DG_FILORI",nCntFor)) .And. !Empty(oModelGrd:GetValue("DG_VIAGEM",nCntFor))) .Or.;
								(!Empty(oModelGrd:GetValue("DG_IDENT",nCntFor)))
								lBaixa := .T.
							Else
								//-- Caso a veiculo seja proprio baixa o movimento de custo
								DA3->(DbSetOrder(1))
								If DA3->(MsSeek(xFilial("DA3")+ oModelGrd:GetValue("DG_CODVEI",nCntFor)))
									If DA3->DA3_FROVEI == "1"
										lBaixa := .T.
									EndIf
								EndIf
							EndIf
						
							//-- Caso exista contrato de carreteiro gerado. 
							If (!Empty( oModelGrd:GetValue("DG_FILORI",nCntFor)) .And. !Empty( oModelGrd:GetValue("DG_VIAGEM",nCntFor)))
								DTY->(DbSetOrder(2))
								If DTY->(DbSeek(xFilial("DTY")+ oModelGrd:GetValue("DG_FILORI",nCntFor)+ oModelGrd:GetValue("DG_VIAGEM",nCntFor)))
									lBaixa := .T.
								EndIf
							EndIf					
							
							// Caso a inclusão seja realizada pelo GFE
							If SDG->DG_ORIGEM == "GW3"
								lBaixa := .T.
							EndIf

							If lBaixa
								If lIdent
									TMSA070Bx("1",SDG->DG_NUMSEQ,SDG->DG_FILORI,SDG->DG_VIAGEM,SDG->DG_CODVEI,,,SDG->DG_VALCOB,,SDG->DG_IDENT)
								Else 
									TMSA070Bx("1",SDG->DG_NUMSEQ,SDG->DG_FILORI,SDG->DG_VIAGEM,SDG->DG_CODVEI,,,SDG->DG_VALCOB,,"")					
								EndIf
							EndIf

							//Se for Contabilizacao On Line, considera os SDG's sem viagem informada
							
							//Verifica se a viagem utiliza REPOM.
							If lTMSOPdg .And. !Empty(SDG->DG_FILORI) .And. !Empty(SDG->DG_VIAGEM)
								lGerComp:= TM70GerCmp(SDG->DG_FILORI,SDG->DG_VIAGEM)							
							EndIf				
							
							If SDG->(FieldPos('DG_DTLAEMI')) > 0 .And. cCusMed == "O" 
								nTotal+=DetProva(nHdlPrv,"903","TMSA070",cLoteTMS)
								AAdd(aRecnoSDG, SDG->(Recno()) )                 			
							EndIf

							//-- Se a Viagem tiver Contrato de Carreteiro, gerar titulo NDF
							DTY->(DbSetOrder(2))						
							If !Empty(SDG->DG_FILORI) .And. !Empty(SDG->DG_VIAGEM) .And. DTY->(MsSeek(xFilial("DTY")+SDG->(DG_FILORI+DG_VIAGEM) )) .And.;
								(!lTMSOPdg .Or. lGerComp)

								cOrigem  := 'COM'  //-- Complemento
								cParcela := StrZero(1, Len(SE2->E2_PARCELA)) 							
								If lGerTit
									cPrefixo   := TMA250GerPrf(cFilAnt)                  
									cParc      := StrZero(1, Len(SE2->E2_PARCELA))						
									SE2->(dbSetOrder(6))
									If SE2->( MsSeek( cSeek := xFilial("SE2") + DTY->DTY_CODFOR + DTY->DTY_LOJFOR + cPrefixo + PadR(DTY->DTY_VIAGEM, Len(SE2->E2_NUM)) )  )
										If SDG->(FieldPos("DG_PARC")) > 0
											Do While !SE2->(Eof()) .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cSeek
												cParc:=Soma1(SE2->E2_PARCELA)
												SE2->(dbSkip())
											EndDo
										Else
											Aviso( STR0021 , STR0022 , { STR0024 } ) //"Atencao" ### "Foi encontrado na tabela SE2 um registro com a mesma chave primária, portanto não será possível efetuar a gravação." ### "OK"									
											Final( STR0023 ) // Execute o update UpdTMS32									
										EndIf
									EndIf	  
									//|
									//| Gera titulo do Contas à Pagar quando lTMSERPINT == .F.
									//| o contrário envia mensagem de Integração para a Marca cadastrada no Adapter EAI
									//|  
									If cTMSERP == "0"
										cParcela := cParc												
										A050ManSE2(,DTY->DTY_VIAGEM,cPrefixo,cTipNDF,cParcela,SDG->DG_VALCOB,0,DTY->DTY_CODFOR,DTY->DTY_LOJFOR,;
														cNatuDeb,1,Nil, "SIGATMS", Date(), , Date(), , cFilAnt, {})																		
									Endif											
								EndIf	
							EndIf	

							Aadd( aCabSDG , { "DG_PARC" , cParcela , Nil })
							If cOrigem  == 'COM'
								Aadd( aCabSDG , { "DG_ORIGEM" , cOrigem , Nil })
							EndIf

							TMSA070Aut( aCabSDG , 4 )
							
							//-- Viagem c/ Frota Propria: Caso o Fechamento da Viagem nao tenha sido realizado,
							//-- nao atualiza os movimentos na Operadora. O processo ira ocorrer no momento do 
							//-- Fechamento da Viagem					

							//-- Viagem c/ Frota Terceiros: Caso o Contrato ainda nao tenha sido emitido, nao 
							//-- atualiza os movimentos na Operadora. O processo ira ocorrer no momento da emissao
							//-- do Contrato de Carreteiro						
							If lTMSOPdg .And. !Empty(SDG->DG_FILORI) .And. !Empty(SDG->DG_VIAGEM)
								TM70Movtos(SDG->DG_FILORI,SDG->DG_VIAGEM,@aMovtos)								
							EndIf

						EndIf
					Next nCntFor

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Envia os Movimentos para a Operadora³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(aMovtos)
						lRet:= TM70IncMov(DTR->DTR_CODOPE, DTR->DTR_FILORI, DTR->DTR_VIAGEM, aMovtos)	
						
						If !lRet
							DisarmTransaction()
							lRetTra:= .F.
							Break
						EndIf
					EndIf

				ElseIf  IsInCallStack("A070BxDoc") .Or. IsInCallStack("A070BxItem") .OR. nOpcx == 4  .OR.  nOpcx == 8 // Baixa
					
					//-- Baixa movimento do custo de transporte
					For nCnt := 1 To oModelGrd:Length()
						If oModelGrd:GetValue("DG_BAIXA",nCnt) == "1" //-- Baixa
						    cNumSeq  := oModelGrd:GetValue("DG_NUMSEQ",nCnt)
							dDataBai := oModelGrd:GetValue("DG_DATBAI",nCnt)
							cMotBai  := oModelGrd:GetValue("DG_MOTBAI",nCnt)
							nValBai  := oModelGrd:GetValue("DG_VALBAI",nCnt)
							cHistor  := oModelGrd:GetValue("DG_HISTOR",nCnt)
							If lIdent
								cIdent	 := oModelGrd:GetValue("DG_IDENT",nCnt)
							Else
								cFilOri  := oModelGrd:GetValue("DG_FILORI",nCnt)
								cViagem  := oModelGrd:GetValue("DG_VIAGEM",nCnt)
							EndIf
							cCodVei  := oModelGrd:GetValue("DG_CODVEI",nCnt)
							TMSA070Bx("1",cNumSeq,cFilOri,cViagem,cCodVei,dDataBai,cMotBai,nValBai,cHistor,cIdent)
						EndIf
					Next nCnt
			
				ElseIf IsInCallStack("A070Est") .OR. nOpcx == 6 //-- Estorno da Baixa
					For nCnt := 1 To oModelGrd:Length()			    
						lEstDoc  := IIF( lPosEstDoc , oModelGrd:GetValue("DG_ESTDOC",nCnt) == '1', .T. )
						If lEstDoc  
							TMSA070Bx("2",oModelGrd:GetValue("DG_NUMSEQ",nCnt))
						EndIf	
					Next nCnt

				EndIf			
			EndIf
		EndIf

	End Transaction
	
	If !lRetTra
		Return .F.
	EndIf
	
	//-- Ponto de Entrada apos gravacao dos movimentos de Custo de Transporte
	If	ExistBlock('TM070GRV')
		ExecBlock('TM070GRV',.F.,.F.,{nOpcx})
	EndIf

	// Verifica se o custo medio é calculado On Line
	If cCusMed == "O" .And. nTotal > 0
		If  IsInCallStack("A070BxDoc")  .OR.  IsInCallStack("A070BxItem") .OR. nOpcx == 8 .OR. nOpcx == 4 //-- Baixa
			Pergunte("TMA070",.F.)
			lDigita   := Iif(mv_par05 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
			lAglutina := Iif(mv_par06 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
		ElseIf  IsInCallStack("A070Inc") .OR. IsInCallStack("A070Est") .OR. nOpcx == 3 .Or. nOpcx == 6 //-- Inclusao OU Estorno da Baixa
			Pergunte("TM070D",.F.)	
			lDigita   := Iif(mv_par01 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
			lAglutina := Iif(mv_par02 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?	
		EndIf	
		
		//Se ele criou o arquivo de prova ele deve gravar o rodape
		RodaProva(nHdlPrv,nTotal)

		//Envia para Lançamento Contábil
		cA100Incl(cArquivo,nHdlPrv,3,cLoteTMS,lDigita,lAglutina)
		
		//Grava Data da Contabilizacao no SDG
		For nCntFor := 1 To Len(aRecnoSDG)
			SDG->(dbGoTo(aRecnoSDG[nCntFor]))
			FwFreeArray(aCabSDG)
			aCabSDG	:= {} 			
			If (IsInCallStack("A070Inc") .OR. nOpcx == 3 ).And. SDG->(FieldPos('DG_DTLAEMI')) > 0 	
				Aadd( aCabSDG , { "DG_DTLAEMI" , dDataBase , Nil })  //-- Data de lancamento contabil a partir da Inclusao da Despesa
			EndIf				
			If IsInCallStack("A070Est") .OR. nOpcx == 6     				         
				Aadd( aCabSDG , { "DG_DTLANC" , Ctod("")  , Nil })     //-- Se estornar a baixa, limpa o campo 
			Else				 
				Aadd( aCabSDG , { "DG_DTLANC" , dDataBase , Nil })    //-- Data de lancamento contabil a partir da Baixa da Despesa
			EndIf	
			Tmsa070Aut( aCabSDG , 4 )
		Next
	EndIf

	RestArea(aAreaAnt)
	RestArea(aAreaDTQ)
	RestArea(aAreaDTR)

Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} A70GrvParc()
Manipulação da gravação da linha       

Uso: TMSA070

@sample
//A70GrvParc(oModelGrd,nCntFor,aParcelas,nSobraTot,nSobraParc)

@author Paulo Henrique Corrêa Cardoso
@since 27/01/2017

@version 1.0
-----------------------------------------------------------/*/
Function A70GrvParc(oModelGrd,nCntFor,aParcelas,nSobraTot,nSobraParc)
	Local nLine   := 0
	Local cNumSeq := ""
	Local aCotacao   := {1,RecMoeda(Date(),2),RecMoeda(Date(),3),RecMoeda(Date(),4),RecMoeda(Date(),5)}
	
	If Type("nLinPai") == "U"
		Private nLinPai := 0
	EndIf

	nLine := oModelGrd:GetLine()
	
	If nLinPai != nCntFor
		nLinPai   := nCntFor
		nCntParc  := 0
	EndIf

	If nLine > nLinPai
		If nCntParc == 0 .AND. Len(aParcelas) >1
			nCntParc := 1
			nSobraTot -= oModelGrd:GetValue("DG_CUSTO1",nCntFor) / Len(aParcelas)
			nSobraParc -= aParcelas[nCntParc,2]
		EndIf
	ElseIf nLine == nLinPai
		nCntParc := 0
	EndIf

	nCntParc += 1

	cNumSeq := ProxNum()
	
	oModelGrd:LoadValue("DG_NUMSEQ",cNumSeq)
	oModelGrd:LoadValue("DG_SEQORI",cNumSeq)
	oModelGrd:LoadValue("DG_SEQMOV",cNumSeq)

	oModelGrd:LoadValue("DG_TOTAL",oModelGrd:GetValue('DG_CUSTO1',nCntFor))
	
	If nCntParc == Len(aParcelas) //-- Ultima Parcela
		oModelGrd:LoadValue("DG_CUSTO1", Round(nSobraTot,TamSX3("DG_CUSTO1")[2] ))
	Else
		oModelGrd:LoadValue("DG_CUSTO1",Round(oModelGrd:GetValue("DG_CUSTO1",nCntFor) / Len(aParcelas),TamSX3("DG_CUSTO1")[2]))
		nSobraTot -= oModelGrd:GetValue("DG_CUSTO1",nLine) //-- Armazena a sobra total das parcelas
	EndIf
	
	oModelGrd:LoadValue("DG_CUSTO2",If(aCotacao[2]>0,oModelGrd:GetValue("DG_CUSTO1",nLine)/aCotacao[2],0))
	oModelGrd:LoadValue("DG_CUSTO3",If(aCotacao[3]>0,oModelGrd:GetValue("DG_CUSTO1",nLine)/aCotacao[3],0))
	oModelGrd:LoadValue("DG_CUSTO4",If(aCotacao[4]>0,oModelGrd:GetValue("DG_CUSTO1",nLine)/aCotacao[4],0))
	oModelGrd:LoadValue("DG_CUSTO5",If(aCotacao[5]>0,oModelGrd:GetValue("DG_CUSTO1",nLine)/aCotacao[5],0))
	
	If nCntParc == Len(aParcelas) //-- Ultima Parcela
		oModelGrd:LoadValue("DG_VALCOB", Round(nSobraParc,TamSX3("DG_VALCOB")[2] ))
		oModelGrd:LoadValue("DG_SALDO",Round(nSobraParc,TamSX3("DG_SALDO")[2] ))
	Else
		oModelGrd:LoadValue("DG_VALCOB",Round(aParcelas[nCntParc,2],TamSX3("DG_VALCOB")[2]))
		oModelGrd:LoadValue("DG_SALDO",Round(aParcelas[nCntParc,2],TamSX3("DG_SALDO")[2]))
		nSobraParc -= oModelGrd:GetValue("DG_VALCOB",nLine) //-- Armazena a sobra total das parcelas
	EndIf					
	
	oModelGrd:LoadValue("DG_DATVENC",aParcelas[nCntParc,1])
	oModelGrd:LoadValue("DG_TES","999")
	oModelGrd:LoadValue("DG_PERC",100)
	oModelGrd:LoadValue("DG_STATUS",StrZero(1,Len(oModelGrd:GetValue("DG_STATUS",nLine)))) //-- Em Aberto
 
Return

/*/-----------------------------------------------------------
{Protheus.doc} ³TMSA070Doc()
Valida o Documento Digitado        

Uso: TMSA070

@sample
//TMSA070Doc()

@author Patricia A. Salomao
@since 06/11/2001
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 09/12/2016

@version 2.0
-----------------------------------------------------------/*/
Function TMSA070Doc()

	Local lRet     := .T.
	Local aAreaSDG := {}
	Local cDoc     := &(ReadVar())
	Local aArea    := GetArea()

	If Empty(cDoc)
		Help(" ",1,"NVAZIO") //Este campo deve ser informado
		lRet:= .F.
	EndIf

	If lRet .And. !Empty(cDoc)
		cDoc := PadL(AllTrim(cDoc),Len(cDoc))
		aAreaSDG := SDG->(GetArea())
		SDG->(DbSetOrder(1))
		If SDG->(MsSeek(xFilial("SDG")+cDoc))
			While SDG->(!Eof()) .And. SDG->DG_FILIAL + SDG->DG_DOC == xFilial("SDG") + cDoc
				M->DG_DOC := NextNumero("SDG",1,"DG_DOC",.T.)
				SDG->(DbSkip())
			EndDo
		Else
			M->DG_DOC := cDoc		
		EndIf
		RestArea(aAreaSDG)
	EndIf

	RestArea(aArea)

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TmsA070Val()
Validacoes do sistema        

Uso: TMSA070

@sample
//TmsA070Val()

@author Patricia A. Salomao
@since 14/06/2002
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 09/12/2016

@version 2.0
-----------------------------------------------------------/*/
Function TmsA070Val()	
	Local oModel    := FwModelActive()     // Recebe o Model Ativo
	Local oModelGrd := NIL                 // Recebe o Modelo do Grid
	Local oModelFld := NIL                 // Recebe o Modelo do Field
	Local nLine     := 0                   // Recebe a Linha posicionada
	Local aAreaDTQ  := {}
	Local aAreaDTR  := {}
	Local aAreaDTY  := {}
	Local aAreaDA3  := {}
	Local cCampo    := ""
	Local lRet	    := .T.      
	Local cSeek     := ""       
	Local cCodVei   := ""       
	Local cFilOri   := ""       
	Local cViagem   := ""
	Local nSeek     := 0
	Local lAchou    := .F.

	If Type("lBaixa") <> "L"
		Private lBaixa := .F.
	EndIf  

	If ValType(oModel) != "O" .OR.  oModel:cId != "TMSA070"

		Return A070ValOld()
	EndIf

	aAreaDTQ  := DTQ->( GetArea() )
	aAreaDTR  := DTR->( GetArea() )
	aAreaDTY  := DTY->( GetArea() )
	aAreaDA3  := DA3->( GetArea() )
	cCampo    := ReadVar()

	oModelGrd 	:= oModel:GetModel( "MdGridSDG" ) //Recebe o modelo do Grid
	oModelFld 	:= oModel:GetModel( "MdFieldSDG" )
	nLine 		:= oModelGrd:GetLine()
  

	If ValType(oModelGrd) <> "O" //-- Os Rateios por Frota feitos no Mata103/Mata240/Mata241 nao possuem GetDados
		Return .T.
	EndIf
												
	cCodVei  := oModelGrd:GetValue("DG_CODVEI",nLine)
	cFilOri  := oModelGrd:GetValue("DG_FILORI",nLine)
	cViagem  := oModelGrd:GetValue("DG_VIAGEM",nLine) 

	If	cCampo == 'M->DG_FILORI' .Or. cCampo == 'M->DG_VIAGEM'
		If cCampo == 'M->DG_FILORI'
			If !Empty(M->DG_FILORI)
				cFilOri := M->DG_FILORI
				cSeek :=  M->DG_FILORI + oModelGrd:GetValue("DG_VIAGEM",nLine)  
				If Empty( oModelGrd:GetValue("DG_VIAGEM",nLine)   )
					Return .T.
				EndIf
			Else
				//-- Qdo limpar o conteudo da filial origem, limpa tb a viagem
				oModelGrd:LoadValue("DG_VIAGEM",CriaVar("DG_VIAGEM",.F.) )  
			EndIf
		ElseIf cCampo == 'M->DG_VIAGEM'
			If !Empty(M->DG_VIAGEM)
				cViagem := M->DG_VIAGEM
				cSeek :=  oModelGrd:GetValue("DG_FILORI",nLine) +  M->DG_VIAGEM
			Else
				//-- Qdo limpar o conteudo da viagem, limpa tb a filial origem
				oModelGrd:LoadValue("DG_FILORI",CriaVar("DG_FILORI",.F.) )  
				Return .T.                              
			EndIf
		EndIf

		//-- Verifica se a viagem informada existe.
		DTQ->(dbSetOrder(2))
		If !DTQ->( MsSeek( xFilial('DTQ') + cSeek ))
			Help(' ', 1, 'TMSXFUNA7') //-- Viagem nao encontrada (DTQ).
			lRet := .F.		
		EndIf

		//-- Verifica se a viagem esta cancelada		
		If DTQ->DTQ_STATUS == StrZero(9,Len(DTQ->DTQ_STATUS))
			Help(' ', 1, 'TMSA07004') //-- Viagem Cancelada
			lRet := .F.			
		EndIf	                    
		
		If DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))
			Help(' ', 1, 'TMSA07029') //--Viagem com pagamento no SIGAGFE.Informe uma viagem válida para pagamento no SIGATMS.  
			lRet := .F.	
		EndIf
		If lRet
			//-- Verifica se existe Contrato de Carreteiro para viagem e se veiculo eh de terceiro.
			DA3->(DbSetOrder(1))
			DA3->(DbSeek(xFilial("DA3")+cCodVei))
			
			If DA3->DA3_FROVEI != StrZero(1,Len(DA3->DA3_FROVEI)) //-- Veiculo nao e proprio
				DTY->(DbSetOrder(2))
				If DTY->(DbSeek(xFilial("DTY")+cFilOri+cViagem)) .And. !(DTY->DTY_STATUS $ '1;2') //-- Contrato não está em aberto ou aguardando liberação
					If !Left(FunName(),7) == 'MATA103'
						Help(" ",1,"TMSA07014",,STR0018 + cFilOri + '/' + cViagem + '. ' + STR0017 )//"Existe contrato para a viagem, a manutencao no movimento de custo nao podera ser realizada" ### "Viagem"
						lRet := .F.			
					EndIf				
				EndIf	
			EndIf			

			If lRet
				//-- Verifica se o veiculo informado esta no complemento de viagem.
				DTR->(DbSetOrder(3))
				If !Empty(cCodVei) .And. DTR->(!MsSeek(xFilial("DTR")+cSeek+cCodVei))
					Help(" ",1,"TMSA07013") //-- O veiculo nao existe no complemento da viagem.
					lRet := .F.
				EndIf
		
				If lBaixa
					//-- Valida data da baixa
					If lRet .And. !Empty( oModelGrd:GetValue("DG_DATBAI",nLine) ) .And. oModelGrd:GetValue("DG_DATBAI",nLine) < DTQ->DTQ_DATGER
						Help(" ", 1,"TMSA07009") //-- Data da baixa nao pode ser menor que a data da geracao da viagem.
						lRet := .F.
					EndIf
				EndIf
				
			//-- Se a funcao estiver sendo chamada pelos programas de Requisicao Interna, gatilhar 
			//-- o campo DG_TOTAL e DG_CODVEI.
			If lRet .And. Left(FunName(),7) == 'MATA240' .Or. Left(FunName(),7) == 'MATA241'                                     
					//-- Gatilha automaticamente o primeiro veiculo do complemento de viagem se o veículo não foi informado .
				If Empty(cCodVei) 
					If cCampo == 'M->DG_FILORI'
						cSeek :=  M->DG_FILORI + oModelGrd:GetValue("DG_VIAGEM",nLine)
					ElseIf cCampo == 'M->DG_VIAGEM'  	
						cSeek := oModelGrd:GetValue("DG_FILORI",nLine) +  M->DG_VIAGEM
					EndIf
					DTR->(DbSetOrder(3))
					If DTR->(MsSeek(xFilial("DTR")+cSeek))
						//Verifica se a frota eh diferente de própria.	   
						DA3->(DbSetOrder(1))
						If DA3->(MsSeek(xFilial("DA3")+DTR->DTR_CODVEI))
							If DA3->DA3_FROVEI <> "1"
								oModelGrd:LoadValue("DG_CODVEI",DTR->DTR_CODVEI) 
							EndIf
						EndIf		
					EndIf
				EndIf
				TMSA070Tot()                           
			EndIf
		EndIf
	EndIf
	If !lRet
		If cCampo == "M->DG_FILORI"
			//-- Qdo limpar o conteudo da filial de origem, limpa tb a viagem
			oModelGrd:LoadValue("DG_VIAGEM",CriaVar("DG_VIAGEM",.F.))
		Else
			//-- Qdo limpar o conteudo da viagem, limpa tb a filial origem
			oModelGrd:LoadValue("DG_FILORI",CriaVar("DG_FILORI",.F.)) 	
		EndIf

	EndIf
	ElseIf cCampo == "M->DG_CODDES"
		//-- Sugere os custos cadastrados para a despesa.
		If DT7->(MsSeek(xFilial("DT7")+M->DG_CODDES))		

			//-- Qdo a chamado for 'Internos', somente podera ser lancada despesa que controle estoque.
			If DT7->DT7_MOVBCO == "1" .Or. DT7->DT7_CONEST == "2"
				If Left(FunName(),7) == "MATA240" .Or. ; //-- Internos
				Left(FunName(),7) == "MATA241"
					Help(" ", 1, "TMSA07018") //-- A Despesa informada devera ter somente controle de estoque.
					lRet := .F.
				EndIf
			EndIf			       

			If lRet
				If DT7->DT7_CONEST == "2" .And. DT7->DT7_MOVBCO == "2"
					If Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
						Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
						Left(FunName(),7) == "TMSA144"
						oModelGrd:LoadValue("DG_TOTAL",DT7->DT7_CUSTO1) 	
						oModelGrd:LoadValue("DG_VALBAI",DT7->DT7_CUSTO1) 	
					Else
						oModelGrd:LoadValue("DG_CUSTO1",DT7->DT7_CUSTO1)
					EndIf
					oModelGrd:LoadValue("DG_VALCOB",DT7->DT7_CUSTO1)//-- Sugere o valor cobrado
					oModelGrd:LoadValue("DG_SALDO",DT7->DT7_CUSTO1)
				Else		
					If Left(FunName(),7) == "TMSA070" .Or. ; //-- Movimentos de Custo de Transporte
						Left(FunName(),7) == "MATA103" //-- Documento de Entrada
						Help(" ", 1, "TMSA07005") //-- A Despesa informada, movimenta banco ou existe controle de estoque, o lancamento nao podera ser efetuado nesta cadastro.
						lRet := .F.
					EndIf
				EndIf
			EndIf
															
			If lRet .And. Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
				Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
				Left(FunName(),7) == "TMSA144"
			If DT7->DT7_CONEST == "1" //-- Se a Depesa Controlar Estoque
					Help(" ", 1, "TMSA07017") //-- A Despesa informada, movimenta estoque, o lancamento nao podera ser efetuado neste cadastro.		   
					Return(.F.)
			EndIf
				If DT7->DT7_MOVBCO == "1" //-- Se a Despesa tiver Movimento bancario 
					//-- Procura se existe outra despesa no acols, com dados bancarios informados;
					//-- Se existir, copia os dados bancarios para a Despesa posicionada				
					If (Type('M->DTR_CODOPE')<> 'U' .And. !Empty(M->DTR_CODOPE))
						oModelGrd:LoadValue("DG_BANCO",Posicione('DEG',1,xFilial('DEG')+M->DTR_CODOPE,'DEG_BANCO'))
						oModelGrd:LoadValue("DG_AGENCIA", DEG->DEG_AGENCI)
						oModelGrd:LoadValue("DG_NUMCON",DEG->DEG_NUMCON)
					Else		
						lAchou := .F.
						For nSeek := 0  To oModelGrd:Length()
							oModelGrd:Goline(nSeek)
							If !oModelGrd:IsDeleted() .AND. !Empty(oModelGrd:GetValue("DG_BANCO",nSeek))
								lAchou := .T. 
								Exit
							EndIf
						Next nSeek
						oModelGrd:Goline(nLine)
						If lAchou 
							oModelGrd:LoadValue("DG_BANCO",oModelGrd:GetValue("DG_BANCO",nSeek))
							oModelGrd:LoadValue("DG_AGENCIA",oModelGrd:GetValue("DG_AGENCIA",nSeek))
							oModelGrd:LoadValue("DG_NUMCON",oModelGrd:GetValue("DG_NUMCON",nSeek))	
						EndIf						
					EndIf	
				Else
					oModelGrd:LoadValue("DG_BANCO",Space(Len(SDG->DG_BANCO)))
					oModelGrd:LoadValue("DG_AGENCIA",Space(Len(SDG->DG_AGENCIA)))
					oModelGrd:LoadValue("DG_NUMCON",Space(Len(SDG->DG_NUMCON)))
				EndIf
			EndIf
			
		EndIf

	ElseIf cCampo == "M->DG_CUSTO1"
		//-- Sugere o valor cobrado
		oModelGrd:LoadValue("DG_VALCOB",M->DG_CUSTO1) 
		oModelGrd:LoadValue("DG_SALDO",M->DG_CUSTO1)
		
	ElseIf cCampo == "M->DG_COND"
		//-- Zera os campos parcela e periodo de vencimento
		oModelGrd:LoadValue("DG_NUMPARC",CriaVar("DG_NUMPARC",.F.)) 
		oModelGrd:LoadValue("DG_PERVENC",CriaVar("DG_PERVENC",.F.)) 

	ElseIf cCampo == "M->DG_VALCOB"
		If Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
			Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
			Left(FunName(),7) == "TMSA144"

			oModelGrd:LoadValue("DG_VALBAI",M->DG_VALCOB) 
			
			//-- Se a Despesa foi selecionada
			If oModelGrd:GetValue("DG_TIPDES",nLine) == "2"  
				oModelGrd:LoadValue("DG_SALDO",M->DG_VALCOB) 
			Else
				If DT7->(MsSeek(xFilial("DT7")+ oModelGrd:GetValue("DG_CODDES",nLine) ) )
					//Despesa não movimenta banco
					If DT7->DT7_MOVBCO == "2"
						oModelGrd:LoadValue("DG_SALDO",M->DG_VALCOB) 
					EndIf 	  		 
				EndIf
			EndIf	  
		Else
			oModelGrd:LoadValue("DG_SALDO",M->DG_VALCOB) 
		EndIf		
		
	ElseIf cCampo == "M->DG_TOTAL"
		If Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
			Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
			Left(FunName(),7) == "TMSA144" .Or. Left(FunName(),7) == "TMSAF76"
			If DT7->(MsSeek(xFilial("DT7")+ oModelGrd:GetValue("DG_CODDES",nLine) ) )
				//Despesa não movimenta banco
				oModelGrd:LoadValue("DG_VALCOB",M->DG_TOTAL)  			
					
				If DT7->DT7_MOVBCO == "1"
					oModelGrd:LoadValue("DG_VALBAI",M->DG_TOTAL) 
				Else  			
					oModelGrd:LoadValue("DG_SALDO",M->DG_TOTAL) 
				EndIf 	  		 
			EndIf		   		
		EndIf		   
	ElseIf cCampo == "M->DG_VALBAI"
		If M->DG_VALBAI > oModelGrd:GetValue("DG_VALCOB",nLine) 
			Help(" ", 1, "TMSA07006") //-- O Valor da baixa nao podera ser maior que o valor cobrado.
			lRet := .F.
		Else
			oModelGrd:LoadValue("DG_SALDO",( oModelGrd:GetValue("DG_VALCOB",nLine) - M->DG_VALBAI )) 
		EndIf

	ElseIf cCampo == "M->DG_MOTBAI"
		If M->DG_MOTBAI == StrZero(2,Len(SDG->DG_MOTBAI)) //-- Valor Perdoado
			DA3->(DbSetOrder(1))
			If DA3->(MsSeek(xFilial("DA3")+  oModelGrd:GetValue("DG_CODVEI",nLine) ))
				If DA3->DA3_FROVEI == "1" //-- Proprio
					Help(" ", 1,"TMSA07008") //-- Valor perdoado permitido somente para veiculos de terceiro ou agregado.
					lRet := .F.
				EndIf
			EndIf
			If !Empty(M->DG_VIAGEM)
				Help(" ", 1,"TMSA07026") //-- Baixa por valor perdoado só será permitido para despesa não vinculada a viagem.
				lRet := .F.
			EndIf
		EndIf

	ElseIf cCampo == "M->DG_DATBAI"
		If !Empty( oModelGrd:GetValue("DG_FILORI",nLine)) .And. !Empty( oModelGrd:GetValue("DG_VIAGEM",nLine) )
			If M->DG_DATBAI < Posicione("DTQ",2,xFilial("DTQ")+oModelGrd:GetValue("DG_FILORI",nLine)+ oModelGrd:GetValue("DG_VIAGEM",nLine),"DTQ_DATGER")
				Help(" ", 1,"TMSA07009") //-- Data da baixa nao pode ser menor que a data da geracao da viagem.
				lRet := .F.
			EndIf
		EndIf

	ElseIf cCampo == "M->DG_CODVEI" 

		//-- Verifica se o veiculo informado esta no complemento de viagem.
		If !Empty(M->DG_CODVEI)
			DTR->(DbSetOrder(3))
			If !Empty(cFilOri) .And. !Empty(cViagem) .And. DTR->(!MsSeek(xFilial("DTR")+cFilOri+cViagem+M->DG_CODVEI))
				Help(" ",1,"TMSA07013") //-- O veiculo nao existe no complemento da viagem.
				lRet := .F.
			EndIf	
		EndIf

		//-- Se a funcao estiver sendo chamada pelos programas de Requisicao Interna, gatilhar 
		//-- o campo DG_TOTAL 
		If Left(FunName(),7) == 'MATA240' .Or. Left(FunName(),7) == 'MATA241'                                     
			TMSA070Tot()                              
		EndIf
	ElseIf cCampo == "M->DG_CODFOR"  .OR.  cCampo == "M->DG_LOJFOR"
		If !Empty(oModelGrd:GetValue("DG_CODFOR")) .AND. !Empty(oModelGrd:GetValue("DG_LOJFOR"))
			SA2->(dbSetOrder(1))
			lRet := SA2->( dbSeek( FwxFilial("SA2")+oModelGrd:GetValue("DG_CODFOR")+oModelGrd:GetValue("DG_LOJFOR") ) )   
		EndIf                                                                            
	EndIf

	RestArea(aAreaDTQ)
	RestArea(aAreaDTR)
	RestArea(aAreaDTY)
	RestArea(aAreaDA3)

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} ³TMSA070Tot()
Gatilha valor no campo DG_TOTAL       

Uso: TMSA070

@sample
//³TMSA070Tot()

@author Patricia A. Salomao
@since 13/09/2007
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 09/12/2016

@version 2.0
-----------------------------------------------------------/*/
Static Function TMSA070Tot()	   
				
	Local nPosCusto:= 0
	Local nPosQuant:= 0
	Local nQuant   := 0
	Local nValCusto:= 0
	Local oModel    := FwModelActive()     // Recebe o Model Ativo
	Local oModelGrd := NIL                 // Recebe o Modelo do Grid
	Local nLine     := 0                   // Recebe a Linha posicionada

	oModelGrd := oModel:GetModel( "MdGridSDG" ) //Recebe o modelo do Grid
	nLine := oModelGrd:GetLine()

	//-- OBS: As variaveis aSavHeader, aSavCols e nSavn estao declaradas na funcao a103RatVei(), no Programa MATA103

	If Left(FunName(),7) == 'MATA241'
		SF5->(dbSetOrder(1))
		SF5->(MsSeek(xFilial('SF5')+cTM )) //-- A Variavel cTM esta declarada como Private no programa MATA241
		nPosCusto := Ascan(aSavHeader, {|x| AllTrim(x[2]) == 'D3_CUSTO1' })
		nPosQuant := Ascan(aSavHeader, {|x| AllTrim(x[2]) == 'D3_QUANT'  })    
		nValCusto := aSavCols[nSavn][nPosCusto]  //-- Valor do Custo informado (D3_CUSTO1)
		nQuant    := aSavCols[nSavn][nPosQuant]  //-- Quantidade informada     (D3_QUANT)
	ElseIf Left(FunName(),7) == 'MATA240'
		SF5->(dbSetOrder(1))
		SF5->(MsSeek(xFilial('SF5')+M->D3_TM))
		nValCusto := M->D3_CUSTO1  //-- Valor do Custo informado (D3_CUSTO1) 	 
		nQuant    := M->D3_QUANT   //-- Quantidade informada     (D3_QUANT)
	EndIf

	//-- Se a Requisicao for valorizada, gatilhar no campo DG_TOTAL o valor informado no campo D3_CUSTO1
	//-- Se a Requisicao NAO for Valorizada, gatilhar no campo DG_TOTAL o custo informado na Despesa (DT7_CUSTO)
	//-- multiplicado pela Quantidade informada no movimento (D3_QUANT)
	If !SF5->(Eof()) 
		If SF5->F5_VAL == "S" //-- Se Requisicao Valorizada
			oModelGrd:LoadValue("DG_TOTAL",nValCusto) 
		Else 
			DT7->(dbSetOrder(1))
			If DT7->(MsSeek(xFilial('DT7')+ ModelGrd:GetValue("DG_CODDES") )) .And. !Empty(DT7->DT7_CUSTO1)
				nValCusto := DT7->DT7_CUSTO1 * nQuant 
				oModelGrd:LoadValue("DG_TOTAL",nValCusto)
			EndIf
		EndIf
	EndIf

Return .T.

/*/-----------------------------------------------------------
{Protheus.doc} ³TMSA070Viag³()
Visualiza os viagens       

Uso: TMSA070

@sample
//³TMSA070Viag³()

@author Eduardo de Souza 
@since 16/09/2004
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 13/12/2016

@version 2.0
-----------------------------------------------------------/*/
Function TMSA070Viag()

	Local aRotOld   := AClone(aRotina)
	Local aAreaDTR  := DTR->(GetArea())
	Local aAreaDTY  := DTY->(GetArea())
	Local cCodVei   := ""
	Local aCampos   := {}
	Local cQuery    := ""
	Local oModel    := FwModelActive()     // Recebe o Model Ativo
	Local oModelGrd := NIL                 // Recebe o Modelo do Grid
	Local nLine     := 0                   // Recebe a Linha posicionada
    Local cCodFor   := ""  
    Local cLojFor   := ""
	Local oTempTable

	Private nOpcSel    := 0
	Private cAliasTRB  := ""

	//Tratamento para quando a função é executada de outras rotinas ex: MATA103
	If ValType(oModel) == "O" .And. RTrim(oModel:cID) == "TMSA070"  	
		oModelGrd := oModel:GetModel( "MdGridSDG" ) //Recebe o modelo do Grid
		nLine := oModelGrd:GetLine()

		cCodVei   :=  oModelGrd:GetValue("DG_CODVEI",nLine)
		cCodFor   :=  oModelGrd:GetValue("DG_CODFOR",nLine)
		cLojFor   :=  oModelGrd:GetValue("DG_LOJFOR",nLine)
	Else
		cCodVei   := GDFieldGet("DG_CODVEI",n)		   
	EndIf

	If Type("lF12") == "U"
		lF12:= .F.
	EndIf

	cAliasTRB  := GetNextAlias()

	//-- Chama a tela de perguntas para o filtro da viagem
	If !lF12
		Pergunte("TMA070",.T.)
		lF12 := .T.
	EndIf
	
	Var_Ixb    := {}
	Aadd(aCampos, { "FILORI"    , "C", FWGETTAMFILIAL, 0 })
	Aadd(aCampos, { "VIAGEM"    , "C", TamSX3("DTQ_VIAGEM")[1], 0 })
	Aadd(aCampos, { "ROTA"      , "C", TamSX3("DTQ_ROTA"  )[1], 0 })
	oTempTable := FWTemporaryTable():New(cAliasTRB)
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("01", {"FILORI","VIAGEM","ROTA"} )
	oTempTable:Create()
	
	cQuery := " SELECT "
	cQuery += " DTQ.DTQ_FILORI FILORI, DTQ.DTQ_VIAGEM VIAGEM, MAX(DTQ.DTQ_ROTA) ROTA "
	cQuery += "   FROM " + RetSqlName("DTR") + " DTR "
	cQuery += "   JOIN " + RetSqlName("DTQ") + " DTQ "
	cQuery += "     ON  DTQ.DTQ_FILORI = DTR.DTR_FILORI "
	cQuery += "     AND DTQ.DTQ_VIAGEM = DTR.DTR_VIAGEM "
	cQuery += "   WHERE DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
	If !Empty(cCodVei)
		cQuery += "     AND DTR.DTR_CODVEI = '" + cCodVei + "' "
	EndIf	

	If !Empty(cCodFor) .AND. !Empty(cLojFor)
		cQuery += "     AND DTR.DTR_CODFOR = '" + cCodFor + "' "
		cQuery += "     AND DTR.DTR_LOJFOR = '" + cLojFor + "' "
	EndIf

	cQuery += "     AND ( DTR.DTR_VALFRE = 0 "
	cQuery += "        OR DTR.DTR_ADIFRE < DTR.DTR_VALFRE ) "
	cQuery += "     AND DTR.D_E_L_E_T_ = ' ' "
	cQuery += "     AND DTQ.DTQ_FILIAL = '" + xFilial("DTR") + "' "
	cQuery += "     AND DTQ.DTQ_SERTMS BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += "     AND DTQ.DTQ_STATUS BETWEEN '" + StrZero(mv_par03,Len(DTQ->DTQ_STATUS)) + "' AND '" + StrZero(mv_par04,Len(DTQ->DTQ_STATUS)) + "'"
	cQuery += "     AND DTQ.DTQ_STATUS <> '" + StrZero(9,Len(DTQ->DTQ_STATUS)) + "' "
	cQuery += "	  AND DTQ.DTQ_PAGGFE <> '" + StrZero(1,Len(DTQ->DTQ_PAGGFE)) + "' "
	cQuery += "     AND DTQ.D_E_L_E_T_ = ' ' "
	
	If !lRestRepom	.And. cImpCTC <> "0"
		cQuery += "     AND NOT EXISTS "
		cQuery += "       ( SELECT 1 "
		cQuery += "           FROM " + RetSqlName("DTY") + " DTY "
		cQuery += "           WHERE DTY.DTY_FILIAL = '" + xFilial("DTY") + "' "
		cQuery += "              AND DTY.DTY_FILORI = DTR.DTR_FILORI "
		cQuery += "              AND DTY.DTY_VIAGEM = DTR.DTR_VIAGEM "
		cQuery += "              AND DTY_STATUS IN ('1','2') "
		cQuery += "              AND DTY.D_E_L_E_T_ = ' ' ) "
	EndIf 
	cQuery += " GROUP BY DTQ_FILORI, DTQ_VIAGEM "
	cQuery += " ORDER BY DTQ_FILORI, DTQ_VIAGEM "
	cQuery := ChangeQuery(cQuery)
	Processa({||SqlToTrb(cQuery, aCampos, cAliasTRB)})
	
	aCampos := {}
	Aadd( aCampos, { "FILORI", PesqPict("DTQ","DTQ_FILORI"), RetTitle("DTQ_FILORI") , FWGETTAMFILIAL } )
	Aadd( aCampos, { "VIAGEM", PesqPict("DTQ","DTQ_VIAGEM"), RetTitle("DTQ_VIAGEM") , TamSX3("DTQ_VIAGEM")[1] } )
	Aadd( aCampos, { "ROTA"  , PesqPict("DTQ","DTQ_ROTA"  ), RetTitle("DTQ_ROTA"  ) , TamSX3("DTQ_ROTA"  )[1] } )
	
	aRotina	:= { { STR0003 , "TMSA070Vis", 0, 2},; 		//"Visualizar"
				{ STR0016 , "TMSConfSel",0,2,,,.T.} } 	//"Confirmar"
	
	(cAliasTRB)->(DbGotop())
	MaWndBrowse(0,0,300,600,STR0015,cAliasTRB,aCampos,aRotina,,,,.T.,,,,,.F.) //"Viagens"
	
	Aadd( Var_Ixb, (cAliasTRB)->FILORI )
	Aadd( Var_Ixb, (cAliasTRB)->VIAGEM )
	
	//-- Apaga os arquivos temporarios	
	oTempTable:Delete()

	//-- Restaura Area anteior
	aRotina := aClone(aRotOld)
	RestArea( aAreaDTR )
	RestArea( aAreaDTY )
	
Return( nOpcSel == 1 )

/*/-----------------------------------------------------------
{Protheus.doc} ³TMSA070Vis()
Visualizacao da viagem  

Uso: TMSA070

@sample
//³TMSA070Vis()

@author Eduardo de Souza 
@since 16/09/2004
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 13/12/2016

@version 2.0
-----------------------------------------------------------/*/
Function TMSA070Vis()

	Private cSerTms := ''
	Private cTipTra := ''

	DTQ->(DbSetOrder(2))
	If DTQ->(MsSeek(xFilial("DTQ")+(cAliasTRB)->FILORI+(cAliasTRB)->VIAGEM))
		cSerTms := DTQ->DTQ_SERTMS
		cTipTra := DTQ->DTQ_TIPTRA
		If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte
			TmsA140Mnt("DTQ",DTQ->(Recno()), 2)
		Else
			TmsA141Mnt("DTQ",DTQ->(Recno()), 2)
		EndIf
	EndIf

Return .T.

/*/-----------------------------------------------------------
{Protheus.doc} TMSA070Ite()
 Retorna o proximo item do movimento de custo   

Uso: TMSA070

@sample
//TMSA070Ite(cDoc,cItem)

@author Eduardo de Souza 
@since 25/08/2004
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 13/12/2016

@version 2.0
-----------------------------------------------------------/*/
Static Function TMSA070Ite(cDoc,cItem)

	Local aAreaSDG := SDG->(GetArea())

	SDG->(DbSetOrder(1))
	SDG->( MsSeek(xFilial("SDG")+cDoc+Replicate("Z",Len(SDG->DG_CODDES)),.T.) )
	DbSkip(-1)

	If SDG->DG_DOC == cDoc
		cItem := Soma1(SDG->DG_ITEM)
	EndIf

	RestArea( aAreaSDG )

Return cItem


/*/-----------------------------------------------------------
{Protheus.doc} TMSA070Bx()
 Baixa Movimento de Custo de Transporte     

Uso: TMSA070 / MATA103 / MATA240 / MATA241 / TMSA240   

@sample
//TMSA070Bx(cAcao,cNumSeq,cFilOri,cViagem,cCodVei,dDataBai,cMotBai,nValBai,cHistor,cIdent,cCodDes)

@author Eduardo de Souza 
@since 25/08/2004
@history 
//Conversão Para MVC - Paulo Henrique Corrêa Cardoso - 31/01/2017

@version 2.0
-----------------------------------------------------------/*/
Function TMSA070Bx(cAcao,cNumSeq,cFilOri,cViagem,cCodVei,dDataBai,cMotBai,nValBai,cHistor,cIdent,cCodDes)
	Local aAreaSDG   := SDG->(GetArea())
	Local aArea      := {}
	Local cStatus    := ""
	Local nSaldo     := 0
	Local aCampos    := {}                
	Local lDeleta    := .F.
	Local cNewSeq    := ""
	Local nSequen    := 0
	Local cSeqOri    := ""
	Local nCustoTot  := 0
	Local nCusto     := 0
	Local aCotacao   := {1,RecMoeda(Date(),2),RecMoeda(Date(),3),RecMoeda(Date(),4),RecMoeda(Date(),5)}
	Local cCusMed    := GetMv("MV_CUSMED")
	Local lIdent	 := SDG->(FieldPos("DG_IDENT")) > 0 .And. nModulo<>43
	Local cStaAtu	 := SDG->DG_STATUS //Utilizado para o contrato de carreteiro não duplique o valor no DTR_ADIFRE.   
	Local lRepom	 := SuperGetMV( 'MV_VSREPOM',, '1' ) $ '2|2.2' .And. SuperGetMV( 'MV_TMSOPDG',, '1' ) == '2'
	Local cDesAdf	 := SuperGetMV( 'MV_DESADF',, '' )     
	Local lBxRep	 := .F. 
	Local cSeekDTY   := ""
	Local lMovRep    := .F.
	Local aCabSDG	:= {} 
	Local lGerador   := SDG->(ColumnPos("DG_GERADOR") > 0)
	
	Default cAcao    := "1" //-- Baixar
	Default cFilOri  := CriaVar("DG_FILORI",.F.)
	Default cViagem  := CriaVar("DG_VIAGEM",.F.)
	Default cCodVei  := CriaVar("DG_CODVEI",.F.)
	Default dDataBai := dDataBase
	Default cMotBai  := StrZero(1,Len(SDG->DG_MOTBAI)) //-- Normal
	Default nValBai  := 0
	Default cHistor  := ""
	Default cIdent   := "" 
	Default cCodDes  := ""

	SDG->(DbSetOrder(3))
	If SDG->(MsSeek(xFilial("SDG")+cNumSeq))
		If cAcao == "1" //-- Baixa 
			If nValBai == SDG->DG_VALCOB
				nSaldo  := 0
				cStatus := StrZero(3,Len(SDG->DG_STATUS)) //-- Baixa Total   
				If lRepom .And. Alltrim(cDesAdf) == Alltrim(SDG->DG_CODDES) .And.  !Empty(cCodDes) //-- Com Repom ativo, casos de baixa total são registrados
					lBxRep := .T.
				EndIf
			ElseIf nValBai < SDG->DG_VALCOB
				nSaldo  := SDG->DG_VALCOB - nValBai
				cStatus := StrZero(2,Len(SDG->DG_STATUS)) //-- '2-Baixa Parcial' 
			EndIf
			
			Aadd( aCabSDG , { "DG_SALDO", nSaldo , Nil } )
			Aadd( aCabSDG , { "DG_STATUS", cStatus, Nil } )
			If nSaldo > 0 .Or. lBxRep
				nCustoTot      := SDG->DG_CUSTO1
				nCusto         := ( ( nSaldo * nCustoTot ) / SDG->DG_VALCOB ) //-- Custo proporcional
				If lIdent
					Aadd( aCabSDG , { "DG_IDENT", CriaVar("DG_IDENT",.F.) , Nil } )
				Else
					Aadd( aCabSDG , { "DG_FILORI", CriaVar("DG_FILORI",.F.) , Nil } )
					Aadd( aCabSDG , { "DG_VIAGEM", CriaVar("DG_VIAGEM",.F.) , Nil } )
				EndIf
				Aadd( aCabSDG , { "DG_VALCOB", nSaldo , Nil } )
				Aadd( aCabSDG , { "DG_CUSTO1", nCusto , Nil } )
				Aadd( aCabSDG , { "DG_CUSTO2", If(aCotacao[2]>0,nCusto/aCotacao[2],0) , Nil } )
				Aadd( aCabSDG , { "DG_CUSTO3", If(aCotacao[3]>0,nCusto/aCotacao[3],0) , Nil } )
				Aadd( aCabSDG , { "DG_CUSTO4", If(aCotacao[4]>0,nCusto/aCotacao[4],0) , Nil } )
				Aadd( aCabSDG , { "DG_CUSTO5", If(aCotacao[5]>0,nCusto/aCotacao[5],0) , Nil } )
				Aadd( aCabSDG , { "DG_DATBAI", CTOD("") , Nil } )
				Aadd( aCabSDG , { "DG_MOTBAI", Space(TamSx3("DG_MOTBAI")[1]) , Nil } )	
			Else
				If lIdent
					Aadd( aCabSDG , { "DG_IDENT", cIdent , Nil } )
				Else
					Aadd( aCabSDG , { "DG_FILORI", cFilOri , Nil } )
					Aadd( aCabSDG , { "DG_VIAGEM", cViagem , Nil } )
				EndIf
				Aadd( aCabSDG , { "DG_DATBAI", dDataBai , Nil } )
				Aadd( aCabSDG , { "DG_MOTBAI", cMotBai , Nil } )	
				Aadd( aCabSDG , { "DG_HISTOR", cHistor , Nil } )
			EndIf
			
			Tmsa070Aut( aCabSDG, 4)
			FwFreeArray(aCabSDG) 

			If nSaldo > 0 .Or. lBxRep
				Aadd( aCampos, { 'DG_ITEM'  , TMSA070Ite(SDG->DG_DOC,SDG->DG_ITEM) , .F. } )
				If lIdent
					Aadd( aCampos, { 'DG_IDENT', cIdent            , .F. } )
				Else
					Aadd( aCampos, { 'DG_FILORI', cFilOri            , .F. } )
					Aadd( aCampos, { 'DG_VIAGEM', cViagem            , .F. } )
				EndIf
				If !Empty(cCodDes)
					Aadd( aCampos, { 'DG_CODDES', cCodDes			 	 , .F. } )
				EndIf
				Aadd( aCampos, { 'DG_CUSTO1', nCustoTot - nCusto , .F. } )
				Aadd( aCampos, { 'DG_CUSTO2', If(aCotacao[2]>0,(nCustoTot-nCusto)/aCotacao[2],0) , .F. } )
				Aadd( aCampos, { 'DG_CUSTO3', If(aCotacao[3]>0,(nCustoTot-nCusto)/aCotacao[3],0) , .F. } )
				Aadd( aCampos, { 'DG_CUSTO4', If(aCotacao[4]>0,(nCustoTot-nCusto)/aCotacao[4],0) , .F. } )
				Aadd( aCampos, { 'DG_CUSTO5', If(aCotacao[5]>0,(nCustoTot-nCusto)/aCotacao[5],0) , .F. } )
				Aadd( aCampos, { 'DG_VALCOB', nValBai            , .F. } )
				Aadd( aCampos, { 'DG_SALDO' , 0                  , .F. } )
				Aadd( aCampos, { 'DG_NUMSEQ', ProxNum()          , .F. } )
				Aadd( aCampos, { 'DG_SEQORI', cNumSeq            , .F. } )
				Aadd( aCampos, { 'DG_SEQMOV', cNumSeq            , .F. } )
				Aadd( aCampos, { 'DG_DATBAI', dDataBai           , .F. } )
				Aadd( aCampos, { 'DG_MOTBAI', cMotBai            , .F. } )
				Aadd( aCampos, { 'DG_HISTOR', cHistor            , .F. } )
				Aadd( aCampos, { 'DG_STATUS', StrZero(3,Len(SDG->DG_STATUS)) , .F. } ) //-- Baixa Total
				TmsCopyReg( aCampos )
			EndIf
			//-- Acrescenta o valor da baixa no adiantamento de frete do complemento de viagem.
			If Left(FunName(),7) == "TMSA070" .And. SDG->DG_ORIGEM = 'DTR' 
				DTR->(DbSetOrder(3))
				If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem+cCodVei)) .And. (cStaAtu <> "3")
					RecLock("DTR",.F.)
					DTR->DTR_ADIFRE += nValBai
					MsUnLock()
					DTY->(dbSetOrder(2))
					DTY->(dbSeek(cSeekDTY := xFilial('DTY')+cFilOri+cViagem))
					While DTY->(!Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM) == cSeekDTY
						If DTY->DTY_CODVEI == cCodVei
							RecLock('DTY',.F.)
							DTY->DTY_ADIFRE := DTR->DTR_ADIFRE
							MsUnLock()
							Exit
						EndIf
						DTY->(dbSkip())
					EndDo												
				EndIf                 

				//-- Verifica se as variaveis de contabilizacao estao declaradas, pois existem programas (Ex.Mata103), 
				//-- que chamam esta funcao e por nao fazerem a contabilizacao, nao tem estas variaveis definidas
				If Type('nHdlPrv') <> "U" .And. Type('cLoteTMS') <> "U"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for Contabilizacao On Line, considera os SDG's sem viagem informada  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					   			
					If SDG->(FieldPos('DG_DTLANC')) > 0 .And. cCusMed == "O" .And. SDG->DG_STATUS == StrZero(3,Len(SDG->DG_STATUS)) .And. Empty(SDG->DG_DTLANC)
						nTotal+=DetProva(nHdlPrv,"901","TMSA070",cLoteTMS)
						AAdd(aRecnoSDG, SDG->(Recno()) )                 			
					EndIf													   			
				EndIf	
		EndIf
				
		//-- Estorno da Baixa
		ElseIf cAcao == "2"
																										
			//-- Verifica se as variaveis de contabilizacao estao declaradas, pois existem programas (Ex.Mata103), 
			//-- que chamam esta funcao e por nao fazerem a contabilizacao, nao tem estas variaveis definidas
			If Type('nHdlPrv') <> "U" .And. Type('cLoteTMS') <> "U"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for Contabilizacao On Line, considera os SDG's sem viagem informada  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					   
				If Left(FunName(),7) <> "TMSA240" .And. Left(FunName(),7) <> "TMSA140" .And. ;
					Left(FunName(),7) <> "TMSA141" .And. Left(FunName(),7) <> "TMSA190" .And. ;
					Left(FunName(),7) <> "TMSA144"
					If SDG->(FieldPos('DG_DTLANC')) > 0 .And. cCusMed == "O" .And. !Empty(SDG->DG_DTLANC)
						nTotal+=DetProva(nHdlPrv,"902","TMSA070",cLoteTMS)
						AAdd(aRecnoSDG, SDG->(Recno()) )                 						
					EndIf													   
				EndIf	
			EndIf
		
			If lIdent
				cIdent  := SDG->DG_IDENT
			Else
				cFilOri := SDG->DG_FILORI
				cViagem := SDG->DG_VIAGEM
			EndIf
			
			nValCob := SDG->DG_VALCOB
			nCusto  := SDG->DG_CUSTO1

			//-- Verifica se a baixa foi originada de baixa parcial.
			If SDG->DG_NUMSEQ <> SDG->DG_SEQORI
				cSeqOri := SDG->DG_SEQORI
				aArea   := SDG->(GetArea())
				//-- Retorna a quantidade de sequencias (baixa parcial) geradas a partir do movimento principal.
				SDG->(DbSetOrder(2))
				If SDG->(MsSeek(xFilial("SDG")+cSeqOri))
					While SDG->(!Eof()) .And. SDG->DG_FILIAL + SDG->DG_SEQORI == xFilial("SDG") + cSeqOri
						nSequen ++
						//-- Se encontrar tres sequencia geradas pela principal o status do movimento sera 'Baixa Parcial'.
						If nSequen == 3
							Exit
						EndIf
						SDG->(DbSkip())
					EndDo
				EndIf							
				SDG->(DbSetOrder(3))
				If SDG->(MsSeek(xFilial("SDG")+cSeqOri))
					//-- Atualiza a sequencia do movimento de custo baixado.
					If SDG->DG_STATUS == StrZero(3,Len(SDG->DG_STATUS)) //-- Baixa Total
						cNewSeq	:= ProxNum()
						cNumSeq := SDG->DG_NUMSEQ
						FwFreeArray(aCabSDG)
						aCabSDG		:= {} 
						Aadd( aCabSDG , { "DG_NUMSEQ",cNewSeq , Nil })
						Tmsa070Aut( aCabSDG , 4 )
					Else
						lDeleta := .T.
						FwFreeArray(aCabSDG)
						aCabSDG		:= {} 
						Aadd( aCabSDG , { "DG_VALCOB"	, SDG->DG_VALCOB + nValCob , Nil })
						Aadd( aCabSDG , { "DG_SALDO"	, SDG->DG_SALDO  + nValCob , Nil })
						Aadd( aCabSDG , { "DG_CUSTO1"	, SDG->DG_CUSTO1 + nCusto , Nil })
						Aadd( aCabSDG , { "DG_CUSTO2"	, If(aCotacao[2]>0,(SDG->DG_CUSTO1 + nCusto)/aCotacao[2],0) , Nil })
						Aadd( aCabSDG , { "DG_CUSTO3"	, If(aCotacao[3]>0,(SDG->DG_CUSTO1 + nCusto)/aCotacao[3],0) , Nil })
						Aadd( aCabSDG , { "DG_CUSTO4"	, If(aCotacao[4]>0,(SDG->DG_CUSTO1 + nCusto)/aCotacao[4],0) , Nil })
						Aadd( aCabSDG , { "DG_CUSTO5"	, If(aCotacao[5]>0,(SDG->DG_CUSTO1 + nCusto)/aCotacao[5],0) , Nil })
										
						//-- Verifica se existe mais que dois registro utilizando a sequencial origem (1=Principal,2=Atual,3=Outras Baixas)
						If nSequen > 2
							//-- Baixa Parcial
							Aadd( aCabSDG , { "DG_STATUS"	, StrZero(2,Len(SDG->DG_STATUS)) , Nil })
						Else
							//-- Em Aberto
							Aadd( aCabSDG , { "DG_STATUS"	, StrZero(1,Len(SDG->DG_STATUS)) , Nil })
						EndIf
						Tmsa070Aut( aCabSDG , 4 )					
					EndIf
				EndIf
				RestArea( aArea )
			EndIf
			
			lMovRep:= .F.
			If lRestRepom .And. Left(FunName(),7) == "TMSA070" .And. !lIdent .And. !lDeleta
				lMovRep:= TM70MovRep()
			EndIf

			If lDeleta .And. Iif(lGerador,((Empty(SDG->DG_GERADOR) .Or. AllTrim(SDG->DG_GERADOR) == "TMSA070") .And. SDG->DG_TIPGER == "1"),.T.)	//-- Manual
				//-- Exclusao do movimento de custo originado pela baixa parcial
				Tmsa070Aut(,5)
			Else	
				FwFreeArray( aCabSDG )
				aCabSDG	:= {} 		
				//-- Volta o status do movimento de custo 'Em Aberto'.
				If Left(FunName(),7) == "TMSA070"
					If lIdent
						Aadd( aCabSDG , { "DG_IDENT" , CriaVar("DG_IDENT",.F.) , Nil })
					Else
						If !lMovRep
							Aadd( aCabSDG , { "DG_FILORI" , CriaVar("DG_FILORI",.F.) , Nil })
							Aadd( aCabSDG , { "DG_VIAGEM" , CriaVar("DG_VIAGEM",.F.), Nil })
						EndIf
					EndIf
				ElseIf IsInCallStack('TMSA240Grv')
					Aadd( aCabSDG , { "DG_FILORI" , CriaVar("DG_FILORI",.F.) , Nil })
					Aadd( aCabSDG , { "DG_VIAGEM" , CriaVar("DG_VIAGEM",.F.), Nil })
				EndIf
				Aadd( aCabSDG , { "DG_FILORI" , CriaVar("DG_FILORI",.F.) , Nil })
				Aadd( aCabSDG , { "DG_VIAGEM" , CriaVar("DG_VIAGEM",.F.), Nil })
				Aadd( aCabSDG , { "DG_NUMSEQ" , cNumSeq, Nil })
				Aadd( aCabSDG , { "DG_DATBAI" , CriaVar("DG_DATBAI",.F.), Nil })
				Aadd( aCabSDG , { "DG_MOTBAI" , CriaVar("DG_MOTBAI",.F.), Nil })
				Aadd( aCabSDG , { "DG_HISTOR" , CriaVar("DG_HISTOR",.F.), Nil })
				Aadd( aCabSDG , { "DG_SALDO" , SDG->DG_VALCOB	, Nil })
				Aadd( aCabSDG , { "DG_STATUS" , StrZero(1,Len(SDG->DG_STATUS))  , Nil })

				Tmsa070Aut( aCabSDG ,4 )

			EndIf
							
			//-- Diminui o valor da baixa no adiantamento de frete do complemento de viagem.
			If (Left(FunName(),7) == "TMSA070" .And. SDG->DG_ORIGEM = 'DTR')
				DTR->(DbSetOrder(3))
				If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem+SDG->DG_CODVEI))
					RecLock("DTR",.F.)
					DTR->DTR_ADIFRE -= nValCob
					MsUnLock()
				EndIf
			EndIf	
			
		EndIf
	EndIf

	RestArea(aAreaSDG)
Return

/*/-----------------------------------------------------------
{Protheus.doc} A070Action()
 Ações dos campos    

Uso: TMSA070 
@sample
//A070Action(oView,cIdForm,cIdCampo,cValue)

@author Paulo Henrique Corrêa Cardoso
@since 02/02/2017

@version 1.0
-----------------------------------------------------------/*/
Function A070Action(oView,cIdForm,cIdCampo,cValue)
	Local oModel     := NIL
	Local oMdlGrid   := NIL
	Local oModelFld  := NIL
	Local lForn      := SDG->(ColumnPos("DG_CODFOR") > 0 )
	Local aAreaSDG   := SDG->(GetArea())
	Local aAreaDTR   := DTR->(GetArea())

	Default oView    := FwViewActive()
	Default cIdForm  := ""
	Default cIdCampo := ""
	Default cValue   := ""

	oModel := oView:GetModel()
	oMdlGrid := oModel:GetModel( "MdGridSDG" )
    oModelFld := oModel:GetModel( "MdFieldSDG" )
	
	If cIdCampo == "DG_FILORI" .OR. cIdCampo == "DG_VIAGEM"
		If nOpcx == 3 .OR. IsInCallStack("A070Inc")
			If !Empty(oMdlGrid:GetValue("DG_FILORI")) .AND. !Empty(oMdlGrid:GetValue("DG_VIAGEM"))
				oMdlGrid:LoadValue("DG_NUMPARC",1)
				oView:Refresh(cIdForm)
			EndIf
		ElseIf nOpcx == 4 .OR. nOpcx == 8 .OR. IsInCallStack("A070BxDoc") .OR. IsInCallStack("A070BxItem")
			dbSelectArea("SDG")
			SDG->(dbSetOrder(1))
			If lForn .AND. SDG->(dbSeek( FwxFilial("SDG") + oModelFld:GetValue("DG_DOC") + oMdlGrid:GetValue("DG_CODDES") + oMdlGrid:GetValue("DG_ITEM") ))
						
				If Empty(SDG->DG_CODFOR)
					dbSelectArea("DTR")
					DTR->(dbSetOrder(3))
					If DTR->(dbSeek(FwxFilial("DTR")+oMdlGrid:GetValue("DG_FILORI")+oMdlGrid:GetValue("DG_VIAGEM")+oMdlGrid:GetValue("DG_CODVEI")  ))
						oMdlGrid:LoadValue("DG_CODFOR",DTR->DTR_CODFOR)
						oMdlGrid:LoadValue("DG_LOJFOR",DTR->DTR_LOJFOR)
						oMdlGrid:LoadValue("DG_NOMFOR",Posicione("SA2",1,FwxFilial("SA2")+DTR->DTR_CODFOR+DTR->DTR_LOJFOR,"A2_NOME"))   
						oView:Refresh(cIdForm)
					EndIf
				EndIf

			EndIf
		EndIf
	ElseIf cIdCampo == "DG_CODVEI"
		If lForn  .AND. (nOpcx == 3 .OR. IsInCallStack("A070Inc"))
			If !Empty(oMdlGrid:GetValue("DG_CODVEI")) 
				dbSelectArea("DA3")
				DA3->(dbSetOrder(1))
				If DA3->(dbSeek(FwxFilial("DA3") + oMdlGrid:GetValue("DG_CODVEI")))
					oMdlGrid:SetValue("DG_CODFOR",DA3->DA3_CODFOR)
					oMdlGrid:SetValue("DG_LOJFOR",DA3->DA3_LOJFOR)
					oView:Refresh(cIdForm)
				EndIf
			Else
				oMdlGrid:SetValue("DG_CODFOR",CriaVar("DG_CODFOR",.F.))
				oMdlGrid:SetValue("DG_LOJFOR",CriaVar("DG_LOJFOR",.F.))
				oMdlGrid:SetValue("DG_FILORI",CriaVar("DG_FILORI",.F.))
				oMdlGrid:SetValue("DG_VIAGEM",CriaVar("DG_VIAGEM",.F.))
				oView:Refresh(cIdForm)
			EndIf
		EndIf
	EndIf	

	RestArea(aAreaSDG) 
	RestArea(aAreaDTR) 
Return

/*
 ================================================================================
/{Protheus.doc} IntegDef
  TODO Rotina de Integracao no formato Mensagem Unica para envio de Titulos ao
       financeiro Contas a Pagar.
  @author  tiago.dsantos
  @since   29/09/2016
  @version 1.000
  @param   cXml         , characters, XML contendo as informacoes da mensagem
  @param   nType        , numeric   , indica se e uma RESPOSTA=TRANS_RESPONSE ou envio=TRANS_SEND
  @param   cMessageType , characters, indica se a resposta é do tipo: EAI_MESSAGE_BUSINESS,EAI_MESSAGE_RESPONSE,EAI_MESSAGE_RECEIPT,EAI_MESSAGE_WHOIS
  @param   cVersion     , characters, versao da mensagem cadastrada.
  @type    function
 ================================================================================
/*/
Static Function IntegDef(cXml,nType,cMessageType,cVersion)
Local aRet := TMSI070ABP(cXml,nType,cMessageType,cVersion)
Return aRet

/*/-----------------------------------------------------------
{Protheus.doc} A070ValOld()
 Função de Validação para chamadas vindas de fontes não MVC   Antigo  TmsA070Val

Uso: TMSA070 
@sample
//A070ValOld()

@author Paulo Henrique Corrêa Cardoso
@since 14/02/2017

@version 1.0
-----------------------------------------------------------/*/
Function A070ValOld()
Local aAreaDTQ := DTQ->( GetArea() )
Local aAreaDTR := DTR->( GetArea() )
Local aAreaDTY := DTY->( GetArea() )
Local aAreaDA3 := DA3->( GetArea() )
Local cCampo   := ReadVar()
Local lRet	   := .T.      
Local cSeek    := ""       
Local cCodVei  := ""       
Local cFilOri  := ""       
Local cViagem  := ""
Local nSeek    := 0

If Type("lBaixa") <> "L"
	Private lBaixa := .F.
EndIf      

If Type('aHeader') <> "A" //-- Os Rateios por Frota feitos no Mata103/Mata240/Mata241 nao possuem GetDados
	Return .T.
EndIf
                                            
cCodVei  := GDFieldGet("DG_CODVEI",n)
cFilOri  := GDFieldGet("DG_FILORI",n)
cViagem  := GDFieldGet("DG_VIAGEM",n)

If	cCampo == 'M->DG_FILORI' .Or. cCampo == 'M->DG_VIAGEM'
	If cCampo == 'M->DG_FILORI'
		If !Empty(M->DG_FILORI)
			cFilOri := M->DG_FILORI
			cSeek :=  M->DG_FILORI +  GDFieldGet( 'DG_VIAGEM', n )
			If Empty( GDFieldGet( 'DG_VIAGEM', n ) )
			 	Return .T.
			EndIf
		Else
			//-- Qdo limpar o conteudo da filial origem, limpa tb a viagem
			GDFieldPut("DG_VIAGEM",CriaVar("DG_VIAGEM",.F.),n)
		EndIf
	ElseIf cCampo == 'M->DG_VIAGEM'
		If !Empty(M->DG_VIAGEM)
			cViagem := M->DG_VIAGEM
			cSeek :=  GDFieldGet( 'DG_FILORI', n )  +  M->DG_VIAGEM
		Else
			//-- Qdo limpar o conteudo da viagem, limpa tb a filial origem
			GDFieldPut("DG_FILORI",CriaVar("DG_FILORI",.F.),n)
			Return .T.                              
		EndIf
	EndIf

	//-- Verifica se a viagem informada existe.
   	DTQ->(dbSetOrder(2))
	If !DTQ->( MsSeek( xFilial('DTQ') + cSeek ))
		Help(' ', 1, 'TMSXFUNA7') //-- Viagem nao encontrada (DTQ).
		lRet := .F.		
	EndIf

	//-- Verifica se a viagem esta cancelada		
	If DTQ->DTQ_STATUS == StrZero(9,Len(DTQ->DTQ_STATUS))
		Help(' ', 1, 'TMSA07004') //-- Viagem Cancelada
		lRet := .F.			
	EndIf	                    
	
	If lRet
		//-- Verifica se existe Contrato de Carreteiro para viagem e se veiculo eh de terceiro.
		DA3->(DbSetOrder(1))
		DA3->(DbSeek(xFilial("DA3")+cCodVei))
		
		If DA3->DA3_FROVEI != StrZero(1,Len(DA3->DA3_FROVEI)) //-- Veiculo nao e proprio
			DTY->(DbSetOrder(2))
			If DTY->(DbSeek(xFilial("DTY")+cFilOri+cViagem)) .And. !(DTY->DTY_STATUS $ '1;2') //-- Contrato não está em aberto ou aguardando liberação
				If !Left(FunName(),7) == 'MATA103'
					Help(" ",1,"TMSA07014",,STR0018 + cFilOri + '/' + cViagem + '. ' + STR0017 )//"Existe contrato para a viagem, a manutencao no movimento de custo nao podera ser realizada" ### "Viagem"
					lRet := .F.			
				EndIf				
			EndIf	
		EndIf			

		If lRet
			//-- Verifica se o veiculo informado esta no complemento de viagem.
			DTR->(DbSetOrder(3))
			If !Empty(cCodVei) .And. DTR->(!MsSeek(xFilial("DTR")+cSeek+cCodVei))
				Help(" ",1,"TMSA07013") //-- O veiculo nao existe no complemento da viagem.
				lRet := .F.
			EndIf
	
			If lBaixa
				//-- Valida data da baixa
				If lRet .And. !Empty(GDFieldGet("DG_DATBAI",n)) .And. GDFieldGet("DG_DATBAI",n) < DTQ->DTQ_DATGER
					Help(" ", 1,"TMSA07009") //-- Data da baixa nao pode ser menor que a data da geracao da viagem.
					lRet := .F.
				EndIf
			EndIf
			
		   //-- Se a funcao estiver sendo chamada pelos programas de Requisicao Interna, gatilhar 
		   //-- o campo DG_TOTAL e DG_CODVEI.
		   If lRet .And. Left(FunName(),7) == 'MATA240' .Or. Left(FunName(),7) == 'MATA241'                                     
		  		//-- Gatilha automaticamente o primeiro veiculo do complemento de viagem se o veículo não foi informado .
		   	If Empty(cCodVei) 
			   	If cCampo == 'M->DG_FILORI'
			   	  	cSeek :=  M->DG_FILORI +  GDFieldGet( 'DG_VIAGEM', n )
			   	ElseIf cCampo == 'M->DG_VIAGEM'  	
				   	cSeek :=  GDFieldGet( 'DG_FILORI', n ) +  M->DG_VIAGEM
				   EndIf
				   DTR->(DbSetOrder(3))
					If DTR->(MsSeek(xFilial("DTR")+cSeek))
						//Verifica se a frota eh diferente de própria.	   
					   DA3->(DbSetOrder(1))
						If DA3->(MsSeek(xFilial("DA3")+DTR->DTR_CODVEI))
							If DA3->DA3_FROVEI <> "1"
								GdFieldPut("DG_CODVEI", DTR->DTR_CODVEI, n)
					  		EndIf
					  	EndIf		
					EndIf
				EndIf
			   TMSA070Tot()                              
			EndIf
		EndIf
   EndIf
   If !lRet
	   If cCampo == "M->DG_FILORI"
 			//-- Qdo limpar o conteudo da filial de origem, limpa tb a viagem
			GDFieldPut("DG_VIAGEM",CriaVar("DG_VIAGEM",.F.),n)
	   Else
 			//-- Qdo limpar o conteudo da viagem, limpa tb a filial origem
			GDFieldPut("DG_FILORI",CriaVar("DG_FILORI",.F.),n)	   	
	   EndIf

   EndIf
ElseIf cCampo == "M->DG_CODDES"
	//-- Sugere os custos cadastrados para a despesa.
	If DT7->(MsSeek(xFilial("DT7")+M->DG_CODDES))		

		//-- Qdo a chamado for 'Internos', somente podera ser lancada despesa que controle estoque.
		If DT7->DT7_MOVBCO == "1" .Or. DT7->DT7_CONEST == "2"
			If Left(FunName(),7) == "MATA240" .Or. ; //-- Internos
		      Left(FunName(),7) == "MATA241"
				Help(" ", 1, "TMSA07018") //-- A Despesa informada devera ter somente controle de estoque.
				lRet := .F.
			EndIf
		EndIf			       

		If lRet
			If DT7->DT7_CONEST == "2" .And. DT7->DT7_MOVBCO == "2"
				If Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
					Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
					Left(FunName(),7) == "TMSA144"
					GDFieldPut("DG_TOTAL" ,DT7->DT7_CUSTO1,n)
					GDFieldPut("DG_VALBAI",DT7->DT7_CUSTO1,n)
				Else
					GDFieldPut("DG_CUSTO1",DT7->DT7_CUSTO1,n)
				EndIf
				GDFieldPut("DG_VALCOB",DT7->DT7_CUSTO1,n) //-- Sugere o valor cobrado
				GDFieldPut("DG_SALDO" ,DT7->DT7_CUSTO1,n)
			Else		
				If Left(FunName(),7) == "TMSA070" .Or. ; //-- Movimentos de Custo de Transporte
					Left(FunName(),7) == "MATA103" //-- Documento de Entrada
					Help(" ", 1, "TMSA07005") //-- A Despesa informada, movimenta banco ou existe controle de estoque, o lancamento nao podera ser efetuado nesta cadastro.
					lRet := .F.
				EndIf
			EndIf
		EndIf
		                                                
		If lRet .And. Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
			Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
			Left(FunName(),7) == "TMSA144"
		   If DT7->DT7_CONEST == "1" //-- Se a Depesa Controlar Estoque
				Help(" ", 1, "TMSA07017") //-- A Despesa informada, movimenta estoque, o lancamento nao podera ser efetuado neste cadastro.		   
				Return(.F.)
		   EndIf
			If DT7->DT7_MOVBCO == "1" //-- Se a Despesa tiver Movimento bancario 
				//-- Procura se existe outra despesa no acols, com dados bancarios informados;
				//-- Se existir, copia os dados bancarios para a Despesa posicionada				
				If (Type('M->DTR_CODOPE')<> 'U' .And. !Empty(M->DTR_CODOPE))
					GdFieldPut("DG_BANCO"  , Posicione('DEG',1,xFilial('DEG')+M->DTR_CODOPE,'DEG_BANCO'), n)
					GdFieldPut("DG_AGENCIA", DEG->DEG_AGENCI, n)
					GdFieldPut("DG_NUMCON" , DEG->DEG_NUMCON, n)
				Else
					nSeek   := Ascan( aCols, {|x| !x[Len(x)] .And. !Empty(x[GdFieldPos('DG_BANCO')]) } )
					If nSeek > 0 
						GdFieldPut("DG_BANCO"  , GdFieldGet("DG_BANCO"   ,nSeek), n)
						GdFieldPut("DG_AGENCIA", GdFieldGet("DG_AGENCIA" ,nSeek), n)
						GdFieldPut("DG_NUMCON" , GdFieldGet("DG_NUMCON"  ,nSeek), n)
					EndIf						
				EndIf	
			Else
				GdFieldPut("DG_BANCO"  , Space(Len(SDG->DG_BANCO))  , n)
				GdFieldPut("DG_AGENCIA", Space(Len(SDG->DG_AGENCIA)), n)
				GdFieldPut("DG_NUMCON" , Space(Len(SDG->DG_NUMCON)) , n)
			EndIf
		EndIf
		
	EndIf

ElseIf cCampo == "M->DG_CUSTO1"
	
	//-- Sugere o valor cobrado
	GDFieldPut("DG_VALCOB",M->DG_CUSTO1,n)
	GDFieldPut("DG_SALDO" ,M->DG_CUSTO1,n)

ElseIf cCampo == "M->DG_COND"
	//-- Zera os campos parcela e periodo de vencimento
	GDFieldPut("DG_NUMPARC",CriaVar("DG_NUMPARC",.F.),n)
	GDFieldPut("DG_PERVENC",CriaVar("DG_PERVENC",.F.),n)

ElseIf cCampo == "M->DG_VALCOB"
	If Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
		Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
		Left(FunName(),7) == "TMSA144"
		GDFieldPut("DG_VALBAI",M->DG_VALCOB,n)
	   //-- Se a Despesa foi selecionada
     If GDFieldGet("DG_TIPDES",n) == "2"  
		  GDFieldPut("DG_SALDO",M->DG_VALCOB,n)  
	  Else
	  	If DT7->(MsSeek(xFilial("DT7")+GDFieldGet("DG_CODDES",n)))
			//Despesa não movimenta banco
			If DT7->DT7_MOVBCO == "2"
				GDFieldPut("DG_SALDO",M->DG_VALCOB,n)
			EndIf 	  		 
	  	EndIf
	  EndIf	  
	Else
	  GDFieldPut("DG_SALDO",M->DG_VALCOB,n)   
	EndIf		
	
ElseIf cCampo == "M->DG_TOTAL"
	If Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
		Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
		Left(FunName(),7) == "TMSA144" .Or. Left(FunName(),7) == "TMSAF76"
		If DT7->(MsSeek(xFilial("DT7")+GDFieldGet("DG_CODDES",n)))
			//Despesa não movimenta banco
			If DT7->DT7_MOVBCO == "1"
				GDFieldPut("DG_VALCOB",M->DG_TOTAL,n)   			
				GDFieldPut("DG_VALBAI",M->DG_TOTAL,n)
			Else
				GDFieldPut("DG_VALCOB",M->DG_TOTAL,n)   			
				GDFieldPut("DG_SALDO",M->DG_TOTAL,n)
			EndIf 	  		 
	  	EndIf
		
		   		
	EndIf		   
ElseIf cCampo == "M->DG_VALBAI"
	If M->DG_VALBAI > GDFieldGet("DG_VALCOB",n)
		Help(" ", 1, "TMSA07006") //-- O Valor da baixa nao podera ser maior que o valor cobrado.
		lRet := .F.
	Else
		GDFieldPut("DG_SALDO",( GDFieldGet("DG_VALCOB",n) - M->DG_VALBAI ),n)
	EndIf

ElseIf cCampo == "M->DG_MOTBAI"
	If M->DG_MOTBAI == StrZero(2,Len(SDG->DG_MOTBAI)) //-- Valor Perdoado
		DA3->(DbSetOrder(1))
		If DA3->(MsSeek(xFilial("DA3")+GDFieldGet("DG_CODVEI",n)))
			If DA3->DA3_FROVEI == "1" //-- Proprio
				Help(" ", 1,"TMSA07008") //-- Valor perdoado permitido somente para veiculos de terceiro ou agregado.
				lRet := .F.
			EndIf
		EndIf
		If !Empty(M->DG_VIAGEM)
			Help(" ", 1,"TMSA07026") //-- Baixa por valor perdoado só será permitido para despesa não vinculada a viagem.
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo == "M->DG_DATBAI"
	If !Empty(GDFieldGet("DG_FILORI",n)) .And. !Empty(GDFieldGet("DG_VIAGEM",n))
		If M->DG_DATBAI < Posicione("DTQ",2,xFilial("DTQ")+GDFieldGet("DG_FILORI",n)+GDFieldGet("DG_VIAGEM",n),"DTQ_DATGER")
			Help(" ", 1,"TMSA07009") //-- Data da baixa nao pode ser menor que a data da geracao da viagem.
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo == "M->DG_CODVEI" 

	//-- Verifica se o veiculo informado esta no complemento de viagem.
	If !Empty(M->DG_CODVEI)
		DTR->(DbSetOrder(3))
		If !Empty(cFilOri) .And. !Empty(cViagem) .And. DTR->(!MsSeek(xFilial("DTR")+cFilOri+cViagem+M->DG_CODVEI))
	  		Help(" ",1,"TMSA07013") //-- O veiculo nao existe no complemento da viagem.
	  		lRet := .F.
	  	EndIf	
	EndIf

   //-- Se a funcao estiver sendo chamada pelos programas de Requisicao Interna, gatilhar 
   //-- o campo DG_TOTAL 
   If Left(FunName(),7) == 'MATA240' .Or. Left(FunName(),7) == 'MATA241'                                     
	   TMSA070Tot()                              
	EndIf
EndIf

RestArea(aAreaDTQ)
RestArea(aAreaDTR)
RestArea(aAreaDTY)
RestArea(aAreaDA3)

Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} A070WhnOld()
 Função de When de campos para chamadas vindas de fontes não MVC   Antigo  TMSA070Whn

Uso: TMSA070 
@sample
//A070WhnOld()

@author Paulo Henrique Corrêa Cardoso
@since 14/02/2017

@version 1.0
-----------------------------------------------------------/*/
Function A070WhnOld()

Local lRet   := .T.
Local cCampo := ReadVar()

If Type("lBaixa") <> "L"
	Private lBaixa := .F.
EndIf

If cCampo $ "M->DG_NUMPARC|M->DG_PERVENC" 
	Return Empty(GDFieldGet("DG_COND",n))
EndIf

If cCampo == "M->DG_CUSTO1"
	//-- Somente permite alterar o campo qdo nao existir informacao no cadastro de despesas.
	lRet := Empty(Posicione("DT7",1,xFilial("DT7")+GDFieldGet("DG_CODDES",n),"DT7_CUSTO1"))
ElseIf Left(FunName(),7) == "TMSA240" .Or. Left(FunName(),7) == "TMSA140" .Or. ;
		Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA190" .Or. ;
		Left(FunName(),7) == "TMSA144"
   //-- Nao Permite alterar nenhum campo se o custo ja tiver sido baixado (total)
   SDG->(dbSetOrder(3))
   If SDG->(MsSeek(xFilial('SDG')+GDFieldGet("DG_NUMSEQ",n))) .And. SDG->DG_STATUS == StrZero(3,Len(SDG->DG_STATUS)) //-- Baixa Total
   	Return(.F.)
   EndIf	
   	   
   //-- Se a Despesa foi selecionada, so' permitir alterar o campo 'DG_VALBAI'
	If cCampo == "M->DG_TOTAL"
		//-- Somente permite alterar o campo qdo nao existir informacao no cadastro de despesas.
		lRet := Empty(Posicione("DT7",1,xFilial("DT7")+GDFieldGet("DG_CODDES",n),"DT7_CUSTO1"))
		
	ElseIf cCampo $ "M->DG_BANCO.M->DG_AGENCIA.M->DG_NUMCON.M->DG_NUMCHEQ"
		//-- Somente permite alterar os campos se a Despesa tiver movimento bancario
		lRet := ( Posicione("DT7",1,xFilial("DT7")+GDFieldGet("DG_CODDES",n),"DT7_MOVBCO") == "1" )
		If lRet .And. Type('M->DTR_CODOPE')<> 'U' .And. !Empty(M->DTR_CODOPE)
			lRet := .F.
		EndIf
	ElseIf cCampo == "M->DG_VALBAI"
		lRet := .F.
	EndIf	

EndIf

Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} A070Veic()
Consulta Especifica para buscar os Veiculos

Uso: TMSA070

@sample
// A070Veic()

@author Paulo Henrique Corrêa Cardoso.
@since 16/02/2017
@version 1.0
-----------------------------------------------------------/*/
Function A070Veic()
	Local aAreaBKP	:= GetArea()				// Recebe a Area Ativa
	Local aRotOld	:= AClone(aRotina)
	Local aAreaDTR	:= DTR->(GetArea())
	Local aAreaDTY	:= DTY->(GetArea())
	Local oDlg		:= Nil  					// Recebe o objeto da Dialog				
	Local oListBox	:= Nil					// Recebe o objeto do ListBox
	Local cQuery	:= ""  					// Recebe a Query
	Local aVeiculos	:= {}					// Recebe os Veiculos
	Local bQuery	:= NIL
	Local oModel	:= FwModelActive()      // Recebe o Model Ativo
	Local oModelGrd	:= NIL                  // Recebe o Modelo do Grid
	Local nLine		:= 0                    // Recebe a Linha posicionada
    Local cCodFor	:= ""  
    Local cLojFor	:= ""	
	Local cCodVei	:= ""
	Local lOld		:= .F.


	// Realiza tratamento para quando não for pelo MVC
	If ValType(oModel) != "O" .OR.  oModel:cId != "TMSA070"
		lOld := .T.
	Else
		oModelGrd := oModel:GetModel( "MdGridSDG" ) //Recebe o modelo do Grid
		nLine := oModelGrd:GetLine()

		cCodFor	:= oModelGrd:GetValue("DG_CODFOR", nLine )
		cLojFor	:= oModelGrd:GetValue("DG_LOJFOR", nLine )
		cCodVei	:= oModelGrd:GetValue("DG_CODVEI", nLine )
	EndIf
	
	// Caso seja baixa com o Fornecedor ja preenchido
	If !Empty(cCodFor) .AND. !Empty(cLojFor) .AND. !( nOpcx == 3 .OR. IsInCallStack("A070Inc") .Or. Inclui) .AND. !lOld 
		
		bQuery := {|| Iif(Select("TRB_ENT") > 0, TRB_ENT->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB_ENT",.F.,.T.) , dbSelectArea("TRB_ENT"),TRB_ENT->(dbGoTop())}

		cQuery := " SELECT "
		cQuery += " 	DA3_COD,DA3_PLACA "
		cQuery += "   FROM " + RetSqlName("DTR") + " DTR "
		cQuery += "   INNER JOIN " + RetSqlName("DA3") + " DA3 "
		cQuery += "     ON  DA3.DA3_FILIAL = '" + FwxFilial("DA3") + "'"
		cQuery += "     AND DA3.DA3_COD = DTR.DTR_CODVEI "
		cQuery += "   WHERE DTR.DTR_FILIAL = '" + FwxFilial("DTR") + "' "
		cQuery += "     AND DTR.DTR_CODFOR = '" + cCodFor + "' "
		cQuery += "     AND DTR.DTR_LOJFOR = '" + cLojFor + "' "
		cQuery += "     AND ( DTR.DTR_VALFRE = 0 "
		cQuery += "        OR DTR.DTR_ADIFRE < DTR.DTR_VALFRE ) "
		cQuery += "     AND DTR.D_E_L_E_T_ = ' ' "
		cQuery += "     AND NOT EXISTS "
		cQuery += "       ( SELECT 1 "
		cQuery += "           FROM " + RetSqlName("DTY") + " DTY "
		cQuery += "           WHERE DTY.DTY_FILIAL = '" + FwxFilial("DTY") + "' "
		cQuery += "              AND DTY.DTY_FILORI = DTR.DTR_FILORI "
		cQuery += "              AND DTY.DTY_VIAGEM = DTR.DTR_VIAGEM "
		cQuery += "              AND DTY_STATUS IN ('1','2') "
		cQuery += "              AND DTY.D_E_L_E_T_ = ' ' ) "
		cQuery += " GROUP BY DA3_COD,DA3_PLACA"
		cQuery += " ORDER BY DA3_COD,DA3_PLACA"
		
		cQuery := ChangeQuery(cQuery)

		LJMsgRun("Aguarde, buscando veiculos do Fornecedor...","Aguarde...",bQuery) //"Aguarde, buscando veiculos do Fornecedor..."##"Aguarde..."

		If TRB_ENT->(Eof())
			Help( " ", 1, "TMSA070XX",, "Atenção, nenhum veiculo foi localizado para o fornecedor", 1,0) //"Atenção, nenhum veiculo foi localizado para o fornecedor"
			Return ""
		EndIf

		While TRB_ENT->(!Eof())
			AAdd(aVeiculos,{	TRB_ENT->DA3_COD,;
								Posicione('DA3',1,FwxFilial("DA3")+TRB_ENT->DA3_COD,"DA3_DESC"),;
								Posicione('DA3',1,FwxFilial("DA3")+TRB_ENT->DA3_COD,"DA3_PLACA")})
			TRB_ENT->(dbSkip())
		EndDo

		Define MSDialog oDlg title "Veiculos do Fornecedor" From c( 180 ), c( 180 ) To c( 530 ), c( 910 ) Pixel //"Veiculos do Fornecedor"
		// Chamadas das Listbox do Sistema
		 
		@ c( 005 ), c( 005 ) ListBox oListBox Fields ;
		Header AllTrim(RetTitle("DTR_CODVEI")),AllTrim(RetTitle("DA3_DESC")),AllTrim(RetTitle("DA3_PLACA")); //"Código do veiculo"###"Descrição do Veiculo"
		Size c( 360 ), c( 150 ) Of oDlg Pixel 
		oListBox:SetArray( aVeiculos )
		oListBox:bLine := {|| {		aVeiculos[oListBox:nAt][1],;
									aVeiculos[oListBox:nAt][2],;
									aVeiculos[oListBox:nAt][3]}}
										
										 
		// Cria componentes padroes do sistema
		Define SButton From c( 160 ), c( 300 ) Type 1 Enable Of oDlg Action (lRet:=.T.,VAR_IXB := aVeiculos[oListBox:nAt][1], oDlg:End() )
		Define SButton From c( 160 ), c( 335 ) Type 2 Enable Of oDlg Action (lRet:=.F.,VAR_IXB := Space( TamSx3("DA3_COD")[1] ), oDlg:End() )
		
		 Activate MSDialog oDlg Centered
	
	Else
		If ConPad1( , , , "DA3", "VAR_IXB", , , "DG_CODVEI", , cCodVei )
			nOpcSel := 1
			VAR_IXB := DA3->DA3_COD
			lRet	:= .T.
		Else
			VAR_IXB := Space( TamSx3("DA3_COD")[1] )
			lRet	:= .F.
		EndIf
	EndIf
	
	aRotina := aClone(aRotOld)
	RestArea( aAreaDTR )
	RestArea( aAreaDTY )
	RestArea(aAreaBKP)
Return lRet

/*{Protheus.doc} TMSA070Vld
	Validação TMSA070
    @type Static Function
    @author Caio Murakami
    @since 23/07/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Function TMSA070Vld( oModelGrid , nLine , cFilOri , cViagem, cCodVei )
Local lRet	:= .T. 

Default oModelGrid	:= Nil
Default nLine		:= 1
Default cFilOri		:= FwFldGet("DTQ_FILORI")
Default cViagem		:= FwFldGet("DTQ_VIAGEM")
Default cCodVei		:= FwFldGet("DTR_CODVEI")

lRet	:= PosVldSDG(oModelGrid,nLine,cFilOri,cViagem,cCodVei)

Return lRet 

/*{Protheus.doc} TMSA070Con
	Validação DG_NUMCON 
    @type Function
    @author Caio Murakami
    @since 29/07/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Function TMSA070Con( cBanco, cAgencia, cConta )
Local lRet			:= .T. 

Default cBanco 		:= ""
Default cAgencia	:= ""
Default cConta		:= ""

IF !Empty(cBanco) .Or. !Empty(cAgencia) .Or. !Empty(cConta)
	SA6->(dbSetOrder(1))
	If SA6->(MsSeek(xFilial('SA6')+cBanco+cAgencia+cConta))
		lRet	:= .T. 
	Else	
		lRet	:= .F. 
		Help(" ",1,"BCONOEXIST") //"Verifique Codigo/Agencia/Conta do Banco,pois o mesmo nao se encontra cadastrado"	
	EndIf
Endif

Return lRet

/*{Protheus.doc} TMSA070Chq
	Validação DG_NUMCON 
    @type Function
    @author Caio Murakami
    @since 29/07/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Function TMSA070Chq( cBanco , cAgencia , cConta, cNumChq )
Local lRet		:= .T.

Default cBanco   	:= ""
Default cAgencia 	:= ""
Default cConta   	:= ""
Default cNumChq  	:= ""

lRet := ExistChav("SEF",cBanco+cAgencia+cConta+cNumChq,1,"JaTemCheq" )

Return lRet

/*{Protheus.doc} TMSA070Prc
	Processamento após gravação da SDG
    @type Function
    @author Caio Murakami
    @since 31/07/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Function TMSA070Prc( cFilOri, cViagem , cCodVei, nOpc , cCodDesp )
Local aArea		:= GetArea()
Local aAreaSDG	:= SDG->(GetArea())
Local cTipoDoc  := Padr( "PA", Len( SE5->E5_TIPODOC ) )
Local cPrefixo  := TMA250GerPrf(cFilAnt)
Local cParcela	:= ""
Local cSeek		:= ""
Local cCodFor	:= ""
Local cLojFor	:= ""
Local aCodLojFor:= {}
Local cTipVei	:= ""
Local lMovBcoChq:= .T. 
Local aDadosBco	:= {} 
Local cChaveSDG := ""
Local nSeek		:= 0 
Local lRet      := .T.

Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodVei		:= ""
Default nOpc		:= 3
Default cCodDesp	:= ""	

If nOpc <> 5 
	SDG->(dbSetOrder(5))
	cSeek := xFilial("SDG") + cFilOri + cViagem + cCodVei
	If SDG->( MsSeek( cSeek ))
		While SDG->( !Eof() ) .And. cSeek == SDG->( DG_FILIAL + DG_FILORI + DG_VIAGEM + DG_CODVEI )
			
			If SDG->DG_TITGER <> "1" .And. Empty(SDG->DG_ORITIT)
				cChaveSDG	:= SDG->(DG_DOC)

				If Empty(cParcela)
					cParcela	:= GetParcela( cTipoDoc, cPrefixo, cViagem )
				Endif

				aCodLojFor	:= GetCodFor(cCodVei)
				If Len(aCodLojFor) > 0 
					cCodFor		:= aCodLojFor[1]
					cLojFor		:= aCodLojFor[2]
				EndiF

				cTipVei		:= GetTipVeic(cCodVei)
				lMovBco		:= MovBanco(SDG->DG_CODDES)
				lMovBcoChq	:= MovBanco(SDG->DG_CODDES)

				//-- Se tiver sido informada uma nova Despesa que Movimenta Financeiro
				If !Empty(SDG->DG_BANCO) .Or. lMovBcoChq
				
					nSeek := Ascan(aDadosBco, {|x| x[1]+x[2]+x[3]+x[4] == SDG->(DG_BANCO+DG_AGENCIA+DG_NUMCON+DG_NUMCHEQ) })

					If nSeek == 0 

						If Len(aDadosBco) > 0 
							cParcela	:= Soma1(cParcela)
						EndIf

						aAdd(aDadosBco, {SDG->DG_BANCO, SDG->DG_AGENCIA, SDG->DG_NUMCON, SDG->DG_NUMCHEQ, SDG->DG_VALCOB, cParcela, lMovBcoChq, SDG->DG_TITGER, cChaveSDG })
					Else
						aDadosBco[nSeek][5] += SDG->DG_VALCOB
					Endif
				EndIf
			EndIf

			SDG->( dbSkip() )
		EndDo

		lRet := A070PreAdt( cFilOri , cViagem , cCodVei , cCodFor, cLojFor , aDadosBco, SDG->DG_CODDES )

	EndIf 
Else
	lRet := TMA070DelTit( cFilOri , cViagem, cCodVei , cCodDesp )
Endif

RestArea(aAreaSDG)
RestArea(aArea)
Return lRet

/*{Protheus.doc} GetHist2
	Obtém histórico 2
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetHist2(cCodDes)
Local cHistory2	:= ""
Local aAreaDT7	:= DT7->(GetArea())

Default cCodDes	:= ""

DT7->(dbSetOrder(1))
If DT7->(MsSeek(xFilial('DT7')+cCodDes))
	cHistory2	:= DT7->DT7_DESCRI
EndIf

RestArea(aAreaDT7)
Return cHistory2

/*{Protheus.doc} GetParcela
	Obtém número da parcela
    @type Function
    @author Caio Murakami
    @since 31/07/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetParcela( cTipoDoc, cPrefixo ,cViagem )
Local cParcela	:= StrZero(1, Len(SE2->E2_PARCELA))
Local aArea		:= GetArea()
Local aAreaSE5	:= SE5->(GetArea())
Local cSeek		:= ""

Default cTipoDoc	:= ""
Default cPrefixo	:= ""
Default cViagem		:= ""

SE5->(dbSetOrder(2))
If SE5->(MsSeek(cSeek:=xFilial('SE5')+ cTipoDoc + cPrefixo + cViagem))
	Do While !SE5->(Eof()) .And. RTrim(SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO)) == RTrim(cSeek)
		cParcela	:= Soma1(SE5->E5_PARCELA)
		SE5->(dbSkip())
	EndDo	
EndIf

RestArea(aAreaSE5)
RestArea(aArea)
Return cParcela

/*{Protheus.doc} GetCodFor
	Obtém código/loja do fornecedor
    @type Function
    @author Caio Murakami
    @since 31/07/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetCodFor( cCodVei )
Local aAreaDA3		:= DA3->(GetArea())
Local cCodFor		:= ""
Local cLojFor		:= ""

Default cCodVei		:= ""

DA3->(dbSetOrder(1))
If DA3->(MsSeek(xFilial('DA3')+cCodVei ))
	cCodFor		:= DA3->DA3_CODFOR
	cLojFor		:= DA3->DA3_LOJFOR
EndIf

RestArea(aAreaDA3)
Return {cCodFor,cLojFor}

/*{Protheus.doc} MovBanco
	Movimenta banco
    @type Function
    @author Caio Murakami
    @since 31/07/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Function MovBanco(cCodDes)
Local lRet		:= .F. 
Local aAreaDT7	:= DT7->(GetArea())

Default cCodDes		:= ""

DT7->(dbSetOrder(1))
If DT7->(MsSeek(xFilial('DT7')+ cCodDes )) .And. DT7->DT7_MOVBCO == "1"
	lRet	:= .T. 
EndIf

RestArea(aAreaDT7)
Return lRet

/*{Protheus.doc} TMSA070Adt
	Gera Adiantamento
    @type Function
    @author Caio Murakami
    @since 03/07/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Function TMSA070Adt( cFilOri,cViagem,cCodVei,aDadosBco,cCodOpe,cCodForn,cLojForn,cHistory,cHistory2,cOrigemTit, lPaMovBco, nValorPdg,nValFrete, lSeparaMsg, aSDGPDG, aRecDTR )
Local aArea			:= GetArea()
Local nCntFor 		:= 0
Local nTotAdiPA 	:= 0
Local cParcela  	:= StrZero(1, Len(SE2->E2_PARCELA))
Local lTM240BCO   	:= ExistBlock('TM240BCO'  ) 

Local lRet			:= .T.
Local cPrefixo   	:= TMA250GerPrf(cFilAnt)
Local cTipAdtoPA 	:= Padr( "PA", Len( SE2->E2_TIPO ) )    // Gera Titulo de Adiantamento do Tipo "PA"
Local cNatuDeb   	:= "" 
Local lMsBlQl		:= .F.
Local lContinua		:= .F. 

Default cFilOri		:= ''
Default cViagem		:= ''
Default cCodVei		:= ''
Default aDadosBco 	:= {}
Default cCodOpe		:= ''
Default cCodForn	:= ''
Default cLojForn	:= ''
Default cHistory	:= ''
Default cHistory2	:= ''
Default cOrigemTit	:= "TMSA240"
Default lPaMovBco	:= .T.
Default nValorPdg	:= 0
Default nValFrete   := 0
Default lSeparaMsg	:= .F. 	//-- Indica se será gerado uma mensagem para o fornecedor do adiantamento e uma mensagem para o fornecedor do pedágio (só ocorrerá quando os fornecedores forem diferentes. )
Default aSDGPDG		:= {} 	//-- Números das despesas criadas para o(s) pedágio(s) da viagem.
Default aRECDTR		:= {} 	//-- Recnos dos DTRS que devem ser atualizados.

cNatuDeb	:= GetNatuDeb()
cHistory	:= GetHistory( cFilOri , cViagem, cCodOpe )

If !Empty(cCodOpe)
	If cCodOpe == "02"
		lMsBlQl  := .T.
	EndIf	
EndIf	

For nCntFor := 1 To Len(aDadosBco)
	lContinua	:= .F. 
	nTotAdiPA 	:= aDadosBco[nCntFor][5]
	cParcela  	:= aDadosBco[nCntFor][6]
	
	If nTotAdiPa > 0 .Or. nValorPdg > 0
		lContinua	:= .T. 
	EndIf

	If lContinua
		If lTM240BCO
			aDadosBco[nCntFor][7] := Ret240BCO( aDadosBco[nCntFor][1] , aDadosBco[nCntFor][2] , aDadosBco[nCntFor][3] , aDadosBco[nCntFor][4] , aDadosBco[nCntFor][5] )
		EndIf

		// Verifico se o contrato do Fornecedor está confingurado para o Titulo de PA (SE2) não gerar Movimentação Bancaria (SE5)
		// altero o conteudo da posição 7 do array para que seja possivel a inclusão do titulo de PA no financeiro
		If !lPaMovBco
			If Len(aDadosBco[nCntFor]) >= 7
				aDadosBco[nCntFor][7] := lPaMovBco
			EndIf

			lPaMovBco := .T.
		EndIf

		lRet := A050ManSE2( , cViagem, cPrefixo, cTipAdtoPA, cParcela, nTotAdiPA, 0, cCodForn, cLojForn,;
							cNatuDeb, 1, , "SIGATMS", dDataBase, cHistory, dDataBase, , cFilAnt,;
							aDadosBco[nCntFor], .F., .F., , , , , , , lMsBlQl, cCodOpe, lPaMovBco )
		
		If lRet
			AtuSDG( aSDGPDG , aDadosBco[nCntFor,9] , cOrigemTit , cParcela, aDadosBco[nCntFor,1] , aDadosBco[nCntFor,2] , aDadosBco[nCntFor,3], aDadosBco[nCntFor,4]  )
			
			If !lSeparaMsg
				AtuDTR( cFilOri, cViagem, cCodVei, aRecDTR, nTotAdiPa , nValorPDG )
			EndIf
		Else
			Exit
		EndIf
	EndIf
	
Next nCntFor

RestArea(aArea)
Return lRet

/*{Protheus.doc} Ret240BCO
	Retorna conteudo ponto de entrada TM240BCO
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function Ret240BCO( cCodBco , cAgencia, cNumCon , cNumChq , nValor )
Local lMovBcoChq	:= .T. 

Default cCodBco		:= ""
Default cAgencia	:= ""
Default cNumCon		:= ""
Default cNumChq		:= ""
Default nValor		:= 0 

//---------------------------------
//-- aDadosBco[1] == Banco
//-- aDadosBco[2] == Agencia
//-- aDadosBco[3] == No.Conta
//-- aDadosBco[4] == No.Cheque
//-- aDadosBco[5] == Valor adiantamento
//-- aDadosBco[6] == Parcela
//-- aDadosBco[7] == Movto. bancario sem cheque
//-- aDadosBco[8] == Título já gerado???
//-- aDadosBco[9] == Chave SDG
//---------------------------------

lMovBcoChq := ExecBlock('TM240BCO',.F.,.F.,{ cCodBco ,cAgencia ,cNumCon , cNumChq , nValor })

If ValType(lMovBcoChq) <> "L"
	lMovBcoChq := .T.
EndIf

Return lMovBcoChq

/*{Protheus.doc} AtuSDG
	Atualiza SDG
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function AtuSDG( aSDGPDG , cDoc , cOrigemTit, cParcela , cBanco, cAgencia, cNumCon, cCheque )
Local aArea		:= GetArea()
Local aAreaSDG	:= SDG->(getArea())
Local aCabSDG	:= {} 

Local nQtdPdg	:= 1 

Default aSDGPDG		:= {} 
Default cDoc		:= ""
Default cOrigemTit	:= ""
Default cParcela	:= StrZero(1, Len(SE2->E2_PARCELA))
Default cBanco		:= ""
Default cAgencia	:= ""
Default cNumCon		:= ""
Default cCheque		:= ""

SDG->(dbSetOrder(1))

//--Atualiza os SDG's ref. ao pedágio gerado
For nQtdPdg := 1 To Len(aSDGPDG)
	If SDG->(MsSeek(FwxFilial('SDG')+aSDGPDG[nQtdPdg]))
		
		aCabSDG	:= {} 
		Aadd( aCabSDG , {"DG_TITGER",	"1"			, Nil })
		Aadd( aCabSDG , {"DG_ORITIT",	cOrigemTit	, Nil })
		
		Tmsa070Aut( aCabSDG , 4 )

		FwFreeArray(aCabSDG)
		
	EndIf
Next nQtdPdg

//--Atualiza o SDG ref. ao adiantamento da viagem
If SDG->(MsSeek(FwxFilial('SDG')+ cDoc ))
	While SDG->(!Eof()) .And. SDG->DG_DOC == cDoc
		If RTrim( SDG->(DG_BANCO + DG_AGENCIA + DG_NUMCON + DG_NUMCHEQ ) ) == RTrim( cBanco + cAgencia + cNumCon + cCheque )
		
			aCabSDG	:= {} 
			Aadd( aCabSDG , {"DG_TITGER",	"1"			, Nil })
			Aadd( aCabSDG , {"DG_ORITIT",	cOrigemTit	, Nil })
			Aadd( aCabSDG , {"DG_PARC"	,	cParcela	, Nil })
			Tmsa070Aut( aCabSDG , 4 )
			
			FwFreeArray(aCabSDG)		
		EndIf 
		SDG->(dbSkip())
	EndDo
EndIf			

RestArea(aAreaSDG)
RestArea(aArea)
Return 

/*{Protheus.doc} AtuDTR
	Atualiza DTR
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function AtuDTR( cFilOri, cViagem, cCodVei, aRecDTR, nTotAdiPa , nValorPDG )
Local aAreaDTR	:= DTR->( GetArea() )
Local nCntDTR	:= 0 

Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodVei		:= ""
Default aRecDTR		:= {}
Default nTotAdiPa	:= 0 
Default nValorPDG 	:= 0  

If Len(aRecDTR) > 0
	For nCntDTR := 1 To Len(aRecDTR)
		DTR->(DbGoTo(aRecDTR[nCntDTR]))
		RecLock('DTR',.F.)
		If nTotAdiPa > 0
			DTR->DTR_TITADI := '1' //--Atualiza DTR, informando que o título com o adiantamento já foi gerado.
		EndIf	
		If nVALORPDG > 0
			DTR->DTR_TITPDG := '1'
			DTR->DTR_ORIPDG := 'TMSA310'
		EndIf				
		MsUnLock()	
	Next
Else
	If DTR->(MsSeek(FwxFilial('DTR')+cFilOri+cViagem+cCodVei))
		RecLock('DTR',.F.)
		If nTotAdiPa > 0
			DTR->DTR_TITADI := '1' //--Atualiza DTR, informando que o título com o adiantamento já foi gerado.
		EndIf	
		If nVALORPDG > 0
			DTR->DTR_TITPDG := '1'
			DTR->DTR_ORIPDG := 'TMSA310'
		EndIf				
		MsUnLock()
	EndIf
EndIf

RestArea(aAreaDTR)
Return 

/*{Protheus.doc} GetHistory
	Obtem histórico
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetHistory( cFilOri , cViagem , cCodOpe )
Local cHistory		:= ""

Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodOpe		:= ""

Private xCodOpe		:= ""

cHistory 	:= RetTitle("DTQ_FILORI") + cFilOri + '/' + RetTitle("DTQ_VIAGEM") + cViagem//--Filial de Origem//--'Viagem: '
If !Empty(cCodOpe)
	xCodOpe  	:= cCodOpe	
	cHistory +=  ' / ' + RetTitle("DTR_NOMOPE") + TmsValField("xCodOpe",.F.,"DTR_NOMOPE") //--"Operadora de Frota:"
EndIf

Return cHistory

/*{Protheus.doc} GetNatuDeb
	Obtem natureza do débito

    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetNatuDeb()
Local cNatuDeb		:= ""
Local lTM250Par  	:= ExistBlock('TM250PAR')

If lTM250Par
	cNatuDeb := ExecBlock('TM250PAR',.F.,.F.,{3})
	If ValType(cNatuDeb) <> 'C'
		cNatuDeb := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
	EndIf
Else
	cNatuDeb := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
EndIf

Return cNatuDeb

/*{Protheus.doc} A070PreAdt
	Prepara chamada para Gerar Adiantamento
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function A070PreAdt( cFilOri , cViagem , cCodVei , cCodForn, cLojForn ,  aDadosBco, cCodDes )
Local lRet		:= .T. 
Local aCodForn	:= {} 
Local aContrat	:= {} 
Local cSerTms	:= ""
Local cTipTra	:= ""
Local cTipVei	:= ""
Local cTipOpVg	:= ""
Local cCodOpe	:= ""
Local cHistory	:= ""
Local cHistory2	:= ""
Local lPaMovBco	:= .F. 
Local lGeraAdi	:= .F. 
Local nValProvi	:= 0 

Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodVei		:= ""
Default cCodForn	:= ""
Default cLojForn	:= ""
Default aDadosBco	:= {} 
Default cCodDes		:= ""

If Len(aDadosBco) > 0

	lGeraAdi	:= .F. 
	lPaMovBco	:= .F. 
	cCodForn	:= ""
	cLojForn	:= ""

	aCodForn	:= GetCreFor( cFilOri , cViagem , cCodVei , cCodForn , cLojForn )
	If Len(aCodForn) > 0 
		cCodForn	:= aCodForn[1]
		cLojForn	:= aCodForn[2]
	EndIf 

	cTipVei		:= GetTipVeic(cCodVei)
	cSerTms		:= GetSerTms(cFilOri, cViagem)
	cTipTra		:= GetTipTra(cFilOri, cViagem)
	cTipOpVg	:= GetTpOpVg(cFilOri, cViagem)
	cCodOpe		:= GetCodOpe(cFilOri, cViagem, cCodVei )
	cHistory2	:= GetHist2(cCodDes)
	aContrat 	:= TMSContrFor(cCodForn, cLojForn, dDataBase, cSerTms, cTipTra, , cTipVei, cTipOpVg , .F. )

	If Len(aContrat) == 0 .Or. Empty(aContrat)
		aContrat 	:= TMSContrFor(cCodForn, cLojForn, dDataBase, cSerTms, cTipTra, , "" , cTipOpVg , .F. )
	EndIf 

	If Len(aContrat) > 0 .And. !Empty(aContrat) .And. Len(aContrat[1]) > 11 
		lPaMovBco 	:= aContrat[1,12] <> '2' //Despesa/Adiantamento Movimenta Banco?

		If Len(aContrat[1]) > 12 .And. ( Empty(aContrat[1][13]) .Or. aContrat[1][13] == '0' )
			lGeraAdi	:= .T. 
		EndIf  

	EndIf 

	If lGeraAdi
		lRet	:= TMSA070Adt(cFilOri,cViagem,cCodVei,aDadosBco,cCodOpe,cCodForn,cLojForn,cHistory,cHistory2,'TMSAF60', lPaMovBco, 0,nValProvi  )
	EndIf 
Endif

Return lRet 

/*{Protheus.doc} GetCodOpe
	Obtém código da operação
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetCodOpe( cFilOri , cViagem , cCodVei )
Local cCodOpe	:= ""
Local aAreaDTR	:= DTR->( GetArea() )

DTR->( dbSetOrder(3) )
If DTR->( MsSeek( xFilial("DTR") + cFilOri + cViagem + cCodVei ))
	cCodOpe		:= DTR->DTR_CODOPE
Endif

RestArea( aAreaDTR )
Return cCodOpe 

/*{Protheus.doc} GetTpOpVg
	Obtém tipo de operação da viagem
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetTpOpVg(cFilOri,cViagem)
Local cTipOpVg	:= ""
Local aArea		:= GetArea()

Default cFilOri		:= ""
Default cViagem		:= ""

DTQ->(dbSetOrder(2))
If DTQ->(MsSeek(xFilial("DTQ") + cFilOri + cViagem ))
	cTipOpVg	:= DTQ->DTQ_TPOPVG
EndIf 

RestArea(aArea)
Return cTipOpVg 

/*{Protheus.doc} GetSerTms
	Obtém serviço de transporte da viagem
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetSerTms(cFilOri,cViagem)
Local cSerTms	:= ""
Local aArea		:= GetArea()

Default cFilOri		:= ""
Default cViagem		:= ""

DTQ->(dbSetOrder(2))
If DTQ->(MsSeek(xFilial("DTQ") + cFilOri + cViagem ))
	cSerTms	:= DTQ->DTQ_SERTMS
EndIf 

RestArea(aArea)
Return cSerTms 

/*{Protheus.doc} GetTipTra
	Obtém tipo de transporte
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetTipTra(cFilOri,cViagem)
Local cTipTra	:= ""
Local aArea		:= GetArea()

Default cFilOri		:= ""
Default cViagem		:= ""

DTQ->(dbSetOrder(2))
If DTQ->(MsSeek(xFilial("DTQ") + cFilOri + cViagem ))
	cTipTra	:= DTQ->DTQ_TIPTRA
EndIf 

RestArea(aArea)
Return cTipTra 

/*{Protheus.doc} GetTipVeic
	Obtém tipo do veículo
    @type Static Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetTipVeic(cCodVei)
Local cTipVei	:= ""
Local aAreaDA3	:= DA3->(GetArea())
Local aArea		:= GetArea()

Default cCodVei		:= ""

DA3->(dbSetOrder(1))
If DA3->(MsSeek(xFilial("DA3") + cCodVei ))
	cTipVei		:= DA3->DA3_TIPVEI
Endif

RestArea(aAreaDA3)
RestArea(aArea)
Return cTipVei

/*{Protheus.doc} GetCreFor
	Obtém o código do forneceodr
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetCreFor( cFilOri , cViagem , cCodVei , cCodForn , cLojForn )
Local aArea			:= GetArea()
Local cCodAux		:= ""
Local cLojAux		:= ""
Local aAux			:= ""
Local aCodFav		:= {}

Default cCodForn	:= ""
Default cLojForn	:= ""

aAux	:= GetCreAdi( cFilOri , cViagem , cCodVei )

If Len(aAux) > 0
	cCodAux		:= aAux[1]
	cLojAux		:= aAux[2]

	If cCodAux + cLojAux <> cCodForn + cLojForn 
		cCodForn	:= cCodAux	
		cLojForn	:= cLojAux
	Else
		aCodFav := T250BscFav(cCodVei,cCodForn,cLojForn,cFilOri,cViagem)	// retorna o codigo do Favorecido
		If Len(aCodFav) > 0  .And. !Empty(aCodFav)
			cCodForn := aCodFav[1][1]
			cLojForn := aCodFav[1][2]
		EndIf	
	EndIf
EndIf

If Empty(cCodForn) .Or. Empty(cLojForn)
	aAux	:= GetPropri(cCodvei)
	If Len(aAux) > 0 
		cCodForn	:= aAux[1]
		cLojForn	:= aAux[2]
	EndIf
EndIf

RestArea(aArea)
Return { cCodForn , cLojForn }

/*{Protheus.doc} GetPropri
	Obtém o proprietario do veiculo
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetPropri( cCodVei )
Local cCodFor		:= ""
Local cLojFor		:= ""
Local aArea			:= GetArea()
Local aAreaDA3		:= DA3->(GetArea())

Default cCodVei		:= ""

DA3->( dbSetOrder(1))
If DA3->( MsSeek( xFilial("DA3") + cCodVei ))
	cCodFor		:= DA3->DA3_CODFOR
	cLojFor		:= DA3->DA3_LOJFOR
EndiF

RestArea(aAreaDA3)
RestArea(aArea)
Return { cCodFor , cLojFor }

/*{Protheus.doc} GetCreAdi
	Obtém o credor do adiantamento
    @type Function
    @author Caio Murakami
    @since 03/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function GetCreAdi( cFilOri , cViagem , cCodVei )
Local cCreAdi		:= ""
Local cLojCre		:= ""
Local aArea			:= GetArea()
Local aAreaDTR		:= DTR->(GetArea())

Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodVei		:= ""

DTR->( dbSetOrder(3))
If DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem + cCodVei ))
	cCreAdi		:= DTR->DTR_CREADI
	cLojCre		:= DTR->DTR_LOJCRE
EndiF

RestArea(aAreaDTR)
RestArea(aArea)
Return { cCreAdi , cLojCre }

/*{Protheus.doc} TMA070DelTit
	Deleção de títulos
    @type Function
    @author Caio Murakami
    @since 04/08/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Function TMA070DelTit( cFilOri , cViagem, cCodVei , cCodDesp )
Local aArea			:= GetArea()
Local cPrefixo 		:= TMA250GerPrf(cFilAnt)
Local cCodFav  		:= ''
Local cLojFav  		:= ''
Local cCodFor		:= ''
Local cLojFor		:= ''
Local cParcela 		:= ''
Local lRet     		:= .T.
Local cTypeMsg 		:= '1'
Local cSubTipMsg	:= '101'
Local cQuery		:= ""
Local cAliasQry		:= ""
Local cNum			:= ""

Default cFilOri  	:= ""
Default cViagem  	:= ""
Default cCodVei		:= ""
Default cCodDesp	:= ""

cAliasQry	:= GetNextAlias()

cQuery	:= " SELECT SE2.E2_NUM, SE2.E2_PREFIXO, SE2.E2_PARCELA, DA3.DA3_CODFOR, DA3.DA3_LOJFOR, DA3.DA3_CODFAV DA3CODFAV , DA3.DA3_LOJFAV DA3LOJFAV , SA2.A2_CODFAV SA2CODFAV , SA2.A2_LOJFAV SA2LOJFAV "
cQuery	+= " FROM " + RetSQLName("SDG") + " SDG "
cQuery	+= " INNER JOIN " + RetSQLName("DA3") + " DA3 "
cQuery	+= " 	ON DA3_FILIAL		= '" + xFilial("DA3") + "' "
cQuery	+= "	AND DA3_COD			= DG_CODVEI "
cQuery	+= "	AND DA3.D_E_L_E_T_ 	= '' "
cQuery	+= " INNER JOIN " + RetSqlName("SA2") + " SA2 "
cQuery	+= " 	ON A2_FILIAL		= '" + xFilial("SA2") + "' "
cQuery	+= "	AND A2_COD			= DA3_CODFOR "
cQuery	+= "	AND A2_LOJA			= DA3_LOJFOR "
cQuery	+= "	AND SA2.D_E_L_E_T_	= ''"
cQuery	+= " INNER JOIN " + RetSQLName("SE2") + " SE2 "
cQuery	+= " 	ON E2_FILIAL 		= '" + xFilial("SE2") + "' "
cQuery	+= " 	AND E2_NUM			= DG_VIAGEM " 
cQuery	+= " 	AND E2_PARCELA		= DG_PARC "
cQuery	+= " 	AND E2_PREFIXO		= '" + cPrefixo + "' "
cQuery	+= " 	AND SE2.D_E_L_E_T_ = '' "
cQuery	+= " WHERE DG_FILIAL 		= '" + xFilial("SDG") + "' "
cQuery	+= " 	AND DG_FILORI 		= '" + cFilOri + "' "
cQuery	+= " 	AND DG_VIAGEM		= '" + cViagem + "' "
If !Empty(cCodVei)
	cQuery	+= " AND DG_CODVEI		= '" + cCodVei + "' "
EndIf
If !Empty(cCodDesp)
	cQuery	+= " AND DG_CODDES		= '" + cCodDesp + "' "
EndIf
cQuery	+= " 	AND SDG.D_E_L_E_T_ 	= '' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->( !Eof() )

	cNum		:= (cAliasQry)->E2_NUM
	cPrefixo	:= (cAliasQry)->E2_PREFIXO
	cParcela	:= (cAliasQry)->E2_PARCELA
	cCodFor		:= (cAliasQry)->DA3_CODFOR
	cLojFor 	:= (cAliasQry)->DA3_LOJFOR
	
	If !Empty( (cAliasQry)->DA3CODFAV ) .And. !Empty( (cAliasQry)->DA3LOJFAV )
		cCodFav		:= (cAliasQry)->DA3CODFAV
		cLojFav		:= (cAliasQry)->DA3LOJFAV 
	ElseIf !Empty( (cAliasQry)->SA2CODFAV ) .And. !Empty( (cAliasQry)->SA2LOJFAV )
		cCodFav		:= (cAliasQry)->SA2CODFAV
		cLojFav		:= (cAliasQry)->SA2LOJFAV 
	Else
		cCodFav		:= ""
		cLojFav		:= ""
	EndIf 

	lRet := TMA250DelTit(cPrefixo, cNum , ,cCodFor , cLojFor , cCodFav, cLojFav, cParcela, ,cTypeMsg, cSubTipMsg)

	If !lRet
		Exit
	EndIf

	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

RestArea( aArea )
Return lRet


/*{Protheus.doc} TMSA070REP
	Valida se podera ser incluida a Despesa com Contrato Gerado
    @since 12/02/2021
    @version P12 
    @param cFilOri, cViagem
    @return lRet
*/
Function TMSA070REP(cFilOri,cViagem)
Local lRet      := .F.
Local lQuitEnc  := Iif(FindFunction("T250QuiEnc"),T250QuiEnc(),.F.)  //Quita Encerramento
Local lTMSOPdg	:= AliasInDic('DEG') .AND. SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local aAreaDTY  := DTY->(GetArea())
Local aAreaDTQ  := DTQ->(GetArea())

Default cFilOri := ""
Default cViagem := ""
Default cCodOpe := ""

If lRestRepom .And. lTMSOPdg .And. cImpCTC == "0" .And. lQuitEnc .And. cTmsErp == '0' 
	If !Empty(cFilOri) .And. !Empty(cViagem)
		DTR->(DbSetOrder(1))
		If DTR->(MsSeek(xFilial('DTR')+cFilOri+cViagem))  .And. DTR->DTR_CODOPE == '01'
			DTY->(DbSetOrder(2))
			If DTY->(MsSeek(xFilial("DTY")+cFilOri+cViagem))
				//-- Quando o Calculo dos Impostos é no Protheus, o contrato de carreteiro é gerado
				//-- antes do fechamento da viagem. Portanto, a despesa podera ser lançada apos o 
				//-- contrato de carreteiro com status em aberto.
				If DTY->DTY_STATUS == StrZero(1,Len(DTY->DTY_STATUS)) 
					lRet:= .T.
					//lRet:=  DTY->DTY_CODOPE == '01' .And. !Empty(DTY->DTY_IDOPE)  //Contrato gerado na Repom
					//If !lRet
					//	DTR->(DbSetOrder(3))   //Contrato não gerado na Repom
					//	If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem)) .And. DTR->DTR_CODOPE == '01' .And. Empty(DTR->DTR_PRCTRA)
					//		lRet:= .T.
					//	EndIf			
					//EndIf	
				EndIf
			EndIf	
		EndIf
	EndIf
EndIf

RestArea(aAreaDTQ)		
RestArea(aAreaDTY)	
Return lRet


/*{Protheus.doc} TM70Movtos
	Monta o array aMovtos para envio dos Movimentos a Repom
    @type Function
    @author Katia
    @since 17/02/2020
    @version P12 R12.1.20
    @param cFilOri, cViagem
    @return aMovtos
*/
Function TM70Movtos(cFilOri,cViagem,aMovtos)
Local cCodDes := ""

Default cFilOri:= ""
Default cViagem:= ""

//-- Viagem c/ Frota Propria: Caso o Fechamento da Viagem nao tenha sido realizado,
//-- nao atualiza os movimentos na Operadora. O processo ira ocorrer no momento do 
//-- Fechamento da Viagem					

//-- Viagem c/ Frota Terceiros: Caso o Contrato ainda nao tenha sido emitido, nao 
//-- atualiza os movimentos na Operadora. O processo ira ocorrer no momento da emissao
//-- do Contrato de Carreteiro (se ja estiver com o Contrato na Repom ou quando o Contrato
//-- nao estiver na Repom porem com o Contrato de Carreteiro gerado (MV_IMPCTC = 0, quitação
//-- no Encerramento e mv_vsrepom 2.2))

//-- Posiciona no DTR para verificar se o processo com a Operadora de Frotas ja foi iniciado
DTR->(DbSetOrder(1))
If DTR->(MsSeek(xFilial('DTR')+cFilOri+cViagem))  .And. DTR->DTR_CODOPE == '01'
	If !Empty(DTR->DTR_PRCTRA) //.Or. (TMSA070REP(DTR->DTR_FILORI,DTR->DTR_VIAGEM))
									
		//-- Posiciona no DTQ para verificar o Servico de Transporte e o Tipo de Transporte
		//-- para confrontar com a tabela de Acoes (DEM)
		DTQ->(DbSetOrder(2))
		DTQ->(MsSeek(xFilial('DTQ')+DTR->DTR_FILORI+DTR->DTR_VIAGEM))
												
		DEM->(DbSetOrder(1))
		If DEM->(MsSeek(xFilial('DEM') + DTR->DTR_CODOPE))
			While DEM->(DEM_FILIAL+DEM_CODOPE) == xFilial('DEM') + DTR->DTR_CODOPE
				If DEM->DEM_TIPMOV == 'E' .And.;
					DEM->DEM_SERTMS == DTQ->DTQ_SERTMS .And. DEM->DEM_TIPTRA == DTQ->DTQ_TIPTRA

					//-- Executa a Formula
					cCodDes := &(DEM->DEM_FORMUL)
					If ValType(cCodDes) == 'C' .And. AllTrim(cCodDes) == AllTrim(SDG->DG_CODDES)
						//-- Caso houver alteração na primeira posição verificar funçao RepIncMov()
						AAdd(aMovtos, {	SDG->(DG_FILIAL + DG_DOC + DG_CODDES + DG_ITEM),;
										DEM->DEM_CODMOV,;
										SDG->DG_CUSTO1,;
										DEM->DEM_ACAO,;
										'0'} )
					EndIf
				EndIf
				DEM->(DbSkip())
			EndDo
		EndIf
	EndIf					
EndIf

Return Nil


/*{Protheus.doc} TM70IncMov
	Inclui os Movimentos na Repom
    @type Function
    @author Katia
    @since 17/02/2020
    @version P12 R12.1.20
    @param cCodOpe,cFilOri,cViagem,aMovtos
    @return lRet
*/
Function TM70IncMov(cCodOpe,cFilOri,cViagem,aMovtos)
Local lRet:= .F.

Default cCodOpe:= ""
Default cFilOri:= ""
Default cViagem:= ""
Default aMovtos:= {}

FwMsgRun( ,{|| lRet := TMSIncMov( cCodOpe, cFilOri, cViagem, aMovtos)} ,STR0019 , STR0020 )

Return lRet

/*{Protheus.doc} TM70GerCmp
	Valida se a viagem Repom para geração do titulo
	** Função externalizada da rotina
    @type Function
    @author Katia
    @since 17/02/2020
    @version P12 R12.1.20
    @param cFilOri,cViagem
    @return lGerComp
*/
Static Function TM70GerCmp(cFilOri,cViagem)
Local lGerComp:= .F.

DTR->(DbSetOrder(1))
If DTR->(MsSeek(xFilial('DTR')+SDG->(DG_FILORI + DG_VIAGEM)))  
	If Empty(DTR->DTR_PRCTRA)					
		lGerComp := .T.
	Else
		lGerComp := TMSA070REP(SDG->DG_FILORI,SDG->DG_VIAGEM)
	EndIf
EndIf

Return lGerComp 

/*{Protheus.doc} TM70MovRep
	Valida se a despesa foi lançada após a geração do Contrato de Carreteiro e ou
	com integração REPOM.		
    @type Function
    @author Katia
    @since 17/02/2020
    @version P12 R12.1.20
    @return lMovRep
*/
Static Function TM70MovRep()
Local lMovRep:= .F.  
Local cIdReg := ""
						
//Movimento enviado para Repom, nao deve limpar a Viagem para que na exclusão seja estornado 
//o metodo na REPOM e exclusão do titulo.
If FindFunction("TMSVldDEN") .And. SDG->DG_ORIGEM == 'COM' .And. !Empty(SDG->DG_FILORI) .And. !Empty(SDG->DG_VIAGEM)
	cIdReg:= SDG->(DG_FILIAL + DG_DOC + DG_CODDES + DG_ITEM) //-- Formula do TMSA070 
	lMovRep:= TMSVldDEN(SDG->DG_FILORI,SDG->DG_VIAGEM,cIdReg)
	//-- Nao tem movimentos enviados para REPOM, caso a despesa foi lançada apos o contrato de carreteiro.
	If !lMovRep
		lMovRep:= TMSA070REP(SDG->DG_FILORI,SDG->DG_VIAGEM)
	EndIf
EndIf

Return lMovRep


/*{Protheus.doc} TMSA070Aut
	Função para realizar a gravação SDG		
    @type Function
    @author Caio Murakami
    @since 08/06/2020
    @version P12 R12.1.20
    @return lMovRep
*/
Function TMSA070Aut( aCab , nOpc  )
Local nCount	:= 1 
Local lExclui	:= .F. 
Local aArea		:= GetArea()

Default aCab	:= {}
Default nOpc	:= 3 

If nOpc == 3 
	RecLock("SDG",.T.)
ElseIf nOpc == 4 .Or. nOpc == 5 
	RecLock("SDG",.F.)
	If nOpc == 5 
		lExclui	:= .T. 
	EndIf 
EndIf 

If lExclui
	SDG->(DbDelete())
Else 
	VarInfo("aCabSDG", aCab )
	For nCount := 1 To Len(aCab )
		SDG->&(aCab[nCount,1])	:= aCab[nCount,2]
	Next nCount 

EndIf 

SDG->(MsUnlock())

RestArea(aArea)
Return 
