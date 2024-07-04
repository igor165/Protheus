#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA065.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³GPEA065   ³ Autor ³ Marcelo Silveira                  ³ Data ³ 31/01/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Outros Benefícios                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Emerson Campos|06/05/14|M_RH003/310901  |Disponibilizado a nova opção de Solicitação ³±±
±±³              |        |                |Subsídio Acadêmico, assim que ocorrer a apro³±±
±±³              ³        ³                ³-vação do RH será apresentado a tela, para  ³±±
±±³              ³        ³                ³complementar as informações                 ³±±
±±³Flavio Correa |06/05/15|PCREQ-2680      |Alterada função Gp65FilRIS para tratar qdo  ³±±
±±³              |        |                |chamada do GPEA061                          ³±±
±±³Wesley Alves  |14/03/19|DRHPONTP-3223   |Alterada função Gp065PreValid para alterar  ³±±
±±³Pereira       |        |                |o registro correto de subsidio academico    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


/*/
Function GPEA065()

Local cFiltraRh
Local oBrwSRA
Local xRetFilRh

oBrwSRA := FWmBrowse():New()
oBrwSRA:SetAlias( 'SRA' )
oBrwSRA:SetDescription(STR0006)	//"Cadastro de Outros Benefícios"

//Inicializa o filtro utilizando a funcao FilBrowse
xRetFilRh := CHKRH(FunName(),"SRA","1")
If ValType(xRetFilRh) == "L"
	cFiltraRh := if(xRetFilRh,".T.",".F.")
Else
	cFiltraRh := xRetFilRh
EndIf

GpLegMVC(@oBrwSRA)	// Adicionar a Legenda no Browse

//Filtro padrao do Browse conforme tabela SRA (Funcionários)
oBrwSRA:SetFilterDefault(cFiltraRh)

oBrwSRA:DisableDetails()
oBrwSRA:Activate()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef    ³ Autor ³ Marcelo Silveira      ³ Data ³31/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Menu Funcional                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi(STR0001)  ACTION 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi(STR0002)  ACTION 'VIEWDEF.GPEA065' 	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0003)  ACTION 'VIEWDEF.GPEA065' 	OPERATION 4 ACCESS 0 //"Manutenção"
ADD OPTION aRotina TITLE OemToAnsi(STR0004)  ACTION 'VIEWDEF.GPEA065' 	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE OemToAnsi(STR0022)  ACTION 'VIEWDEF.GPEA068' 	OPERATION 2 ACCESS 0 //"Visualização do Càlculo"
ADD OPTION aRotina TITLE OemToAnsi(STR0030)  ACTION 'VIEWDEF.GPEA068' 	OPERATION 4 ACCESS 0 //"Manutenção do Càlculo"
ADD OPTION aRotina TITLE OemToAnsi(STR0016)  ACTION "Gp065Lote()"  		OPERATION 2 ACCESS 0//"Lançamento em Lote"

Return( aRotina )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Marcelo Silveira      ³ Data ³31/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para o Cadastro de  ³±±
±±³          ³Outros Beneficios (RI1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModelDef()

Local aAux			:= {}
Local aStructRI1	:= {}

Local cWhenRI1		:= ""
//Define os campos do SRA que serão apresentados na tela
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+ "|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA 		:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRI1 		:= FWFormStruct(1, 'RI1', /*bAvalCampo*/,/*lViewUsado*/)
Local oMdlRI1

Local nX			:= 0

// Blocos de codigo do modelo
Local bLinePos		:= {|oMdl, nLine| Gp065LinePos(oMdl, nLine)}
Local bPreValid		:= {|oMdl| Gp065PreValid(oMdl)}
Local bPosValid		:= {|oMdl| Gp065PosValid(oMdl)}

// Variável utilizada para carregar as informações da solicitação no oModel, quando a rotina é executada pela TCFA040
lFirst := .T.

//Cria o objeto do Modelo de Dados
oMdlRI1 := MPFormModel():New('GPEA065', bPreValid , bPosValid, {|oModel|Gp065Commit(oModel)}/*bCommit*/, /*bCancel*/)

//Adiciona ao modelo uma estrutura de formulário de edição por campo
oMdlRI1:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

//Adiciona ao modelo uma estrutura de formulário de edição por grid
oMdlRI1:AddGrid( 'RI1DETAIL', 'SRAMASTER', oStruRI1, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

aStructRI1 := oStruRI1:GetFields()

For nX := 1 to Len(aStructRI1)
	cWhenRI1 := "{ |oGrid| fRI1When( '" + aStructRI1[nX,3] + "',oGrid ) } "
	oStruRI1:SetProperty( aStructRI1[nX,3], MODEL_FIELD_WHEN, &(cWhenRI1) )
Next nX

oStruRI1:SetProperty( "RI1_PD" , MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, 'Vazio() .Or. ExistCpo("SRV")'))
oStruRI1:SetProperty( "RI1_PD1", MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, 'Vazio() .Or. ExistCpo("SRV")'))

aAux := FwStruTrigger('RI1_PD','RI1_DESCPD','SRV->RV_DESC',.T.,'SRV',1,'xFilial("SRV",SRA->RA_FILIAL) + M->RI1_PD','.T.')
oStruRI1:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

aAux := FwStruTrigger('RI1_PD1','RI1_DESC1','SRV->RV_DESC',.T.,'SRV',1,'xFilial("SRV",SRA->RA_FILIAL) + M->RI1_PD1','.T.')
oStruRI1:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

aAux := FwStruTrigger('RI1_PD2','RI1_DESC2','SRV->RV_DESC',.T.,'SRV',1,'xFilial("SRV",SRA->RA_FILIAL) + M->RI1_PD2','.T.')
oStruRI1:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

//Faz relaciomaneto entre os compomentes do model
oMdlRI1:SetRelation('RI1DETAIL', {{'RI1_FILIAL', 'xFilial("RI1")'}, {'RI1_MAT', 'RA_MAT'}}, RI1->(IndexKey(1)))

If GetRPORelease() >= "12.1.025"
	// A partir da release 12.1.25 a chave da tabela será alterada para permitir cadastrar o mesmo benefício em períodos diferentes
	oMdlRI1:GetModel('RI1DETAIL'):SetUniqueLine({'RI1_FILIAL', 'RI1_MAT', 'RI1_BENEF', 'RI1_TABELA', 'RI1_DINIPG'})
Else
	oMdlRI1:GetModel('RI1DETAIL'):SetUniqueLine({'RI1_FILIAL', 'RI1_MAT', 'RI1_BENEF', 'RI1_TABELA'})
EndIf

//Permite grid sem dados
oMdlRI1:GetModel('RI1DETAIL'):SetOptional(.T.)

oMdlRI1:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlRI1:GetModel('SRAMASTER'):SetOnlyQuery(.T.)

//Adiciona a descricao do Modelo de Dados
oMdlRI1:SetDescription(OemToAnsi(STR0006))  //"Cadastro de Outros Benefícios"

//Adiciona a descricao do Componente do Modelo de Dados
oMdlRI1:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0005)) //"Funcionário"
oMdlRI1:GetModel('RI1DETAIL'):SetDescription(OemToAnsi(STR0007)) //"Outros Benefícios"

Return( oMdlRI1	)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Marcelo Silveira      ³ Data ³31/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualizador de dados do Cadastro de Outros Beneficios (RI1)  ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ViewDef()

Local oView

//Define os campos do SRA que serão apresentados na tela
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}

//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA065')

//Cria a estrutura a ser usada na View
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRI1 := FWFormStruct(2, 'RI1')

//Cria o objeto de View
oView := FWFormView():New()

//Remove campos da estrutura e ajusta ordem dos campos na view
oStruRI1:RemoveField('RI1_MAT')

//Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')

oStruSRA:SetNoFolder()

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RI1', oStruRI1, 'RI1DETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 10)
oView:CreateHorizontalBox('INFERIOR', 90)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RI1', 'INFERIOR')

oView:AddIncrementField('VIEW_RI1',"RI1_COD")

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_RI1', OemToAnsi(STR0006)) //"Cadastro de Outros Beneficios"

Return( oView )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fRI1When     ³ Autor ³ Leandro Drumond       ³ Data ³ 04/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³When dos campos da RI1										 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fRI1When()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fRI1When(cCampo,oGrid)
Local lRet := .F.

If cCampo <> "RI1_TPCALC" .and. oGrid:GetValue("RI1_TPCALC") <> "2" //Se não for automatico, permite edição
	lRet := .T.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp065LinePos³ Autor ³ Marcelo Silveira      ³ Data ³31/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao linha do Cadastro de Outros Beneficios (RI1)        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Gp065LinePos( oMdlRI1 )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oMdlRI1 = Objeto do modelo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRetorno = .T. ou .F.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp065LinePos( oMdlRI1, nLine )

	Local lRet	:= .T.
	Local nI
	Local cTipo
	Local cCodBen
	Local dDataIni
	Local dDataFim

	If oMdlRI1:GetValue("RI1_DINIPG") > oMdlRI1:GetValue("RI1_DFIMPG") .and. !Empty(oMdlRI1:GetValue("RI1_DFIMPG"))
		lRet := .F.
		Help(,,STR0010,, STR0023, 1, 0 )  // "Data do Inicio do Pagamento não pode ser menor que a data do final do pagamento." # "Atencao"
	ElseIf Empty(oMdlRI1:GetValue("RI1_TABELA"))
		lRet := .F.
		Help(,,STR0010,, STR0013, 1, 0 )  // "Código da tabela deve ser preenchido." # "Atencao"
	ElseIf Empty(oMdlRI1:GetValue("RI1_BENEF"))
		lRet := .F.
		Help(,,STR0010,, STR0015, 1, 0 )  // "Código do beneficio deve ser preenchido." # "Atencao"
	EndIf

	If lret .And. GetRPORelease() >= "12.1.025" .And. !IsBlind()

		cTipo := oMdlRI1:GetValue("RI1_BENEF")
		cCodBen := oMdlRI1:GetValue("RI1_TABELA")
		dDataIni := oMdlRI1:GetValue("RI1_DINIPG")
		dDataFim := oMdlRI1:GetValue("RI1_DFIMPG")

		For nI := 1 To oMdlRI1:Length()
			oMdlRI1:GoLine(nI)

			If ! oMdlRI1:IsDeleted() .And. nI != nLine
				// Se Houver alguma intersecção entre os períodos do mesmo benefício apresenta uma mensagem informando o usuário
				If (cTipo == oMdlRI1:GetValue("RI1_BENEF") .And. cCodBen == oMdlRI1:GetValue("RI1_TABELA")) .And. ;
					(oMdlRI1:GetValue("RI1_DINIPG") >= dDataIni .And. oMdlRI1:GetValue("RI1_DINIPG") <= dDataFim .Or.;
					oMdlRI1:GetValue("RI1_DFIMPG") >= dDataIni .And. oMdlRI1:GetValue("RI1_DFIMPG") <= dDataFim .Or. ;
					(oMdlRI1:GetValue("RI1_DINIPG") <= dDataIni .And. oMdlRI1:GetValue("RI1_DFIMPG") >= dDataFim ))

					// "O Funcionário possui dois benefícios do mesmo tipo e código no mesmo período. Deseja continuar?" # Benefício duplicado
					If ! (lret := MsgYesNo(STR0041 + STR0043, STR0040))
						// Benefício duplicado # "O Funcionário possui dois benefícios do mesmo tipo e código no mesmo período. # Informe um período diferente para o benefício.
						Help(,, STR0040,, STR0041, 1, 0, ,,,,, {STR0042})
					EndIf
				EndIf
			EndIf
		Next

	EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Gp065Lote   	³ Autor ³ Leandro Drumond   ³ Data ³ 19.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua gravacao em lote.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp065Lote()

Local aArea		:= GetArea()
Local bProcesso	:= {|oSelf| GPMProc_Lote(oSelf)}
Local cPerg     := "GPA065"
Local cDesc1	:= OemToAnsi(STR0017)	//"Gravação em Lote de Benefícios"
Local cDesc2	:= OemToAnsi(STR0018)	//"Este Programa realizará a gravação dos benefícios definidos para todos os funcinários do intervalo."

Private aLog		:= {}
Private aTitle		:= {}

Pergunte(cPerg,.F.)

tNewProcess():New( "GPEA065", cDesc1, bProcesso, cDesc2, cPerg, , , , , .T., .T.  )

If Len(aLog) > 0
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Apresenta com Log de erros                              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fMakeLog(aLog,aTitle,,.T.,"TRFLOTE",STR0019,"M","P",,.F.)  //"LOG de cadastramento em Lote de beneficios"
EndIf

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GPMProc_Lote	³ Autor ³ Leandro Drumond   ³ Data ³ 20.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua gravacao em lote.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GPMProc_Lote(oSelf)

Local cCodSeq	:= ""
Local cFiltro	:= ""
Local bFiltro
Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel	:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lOfusca	:= Len(aFldRel) > 0

// Leitura dos parametros
cCodBenef   := mv_par04
cCodTab		:= mv_par05
cPdBen		:= mv_par06
cPdDesc		:= mv_par07
cPdEmp		:= mv_par08
cPropor		:= AllTrim(STR(mv_par09))
dDtIni		:= mv_par10
dDtFim		:= mv_par11
cCategoria	:= mv_par12
cSituacao	:= mv_par13

MakeAdvplExpr("GPA065")

cFilInf	:= mv_par01
cMatricula	:= mv_par02
cCC			:= mv_par03

If Empty(cCodTab)
	Help(,,STR0010,, STR0013, 1, 0 )  // "Código da tabela não foi preenchido." # "Atencao"
	Return(.F.)
EndIf

If !Empty(cFilInf)
	cFiltro += cFilInf
EndIf

If !Empty(cMatricula)
	If Empty(cFiltro)
		cFiltro += cMatricula
	Else
		cFiltro += " .AND. " + cMatricula
	EndIf
EndIf

If !Empty(cCC)
	If Empty(cFiltro)
		cFiltro += cCC
	Else
		cFiltro += " .AND. " + cCC
	EndIf
EndIf

// Filtrar os funcionarios que serao processados //
dbSelectArea( "SRA" )
dbSetOrder( 1 )

If !Empty(cFiltro)
	bFiltro := { || &(cFiltro) }
	SRA->(DbSetfilter( bFiltro, cFiltro ))
EndIf

oSelf:SetRegua1(SRA->(RecCount()))

DbGoTop()

If SRA->( Eof()	 )
	Aadd(aTitle, OemToAnsi(STR0024))  //"Nenhum funcionário a processar!"
	Aadd( aLog,{} )
Else
	Aadd(aTitle, OemToAnsi(STR0025))  //"Inconsistência na geração de beneficios!"
	Aadd(aLog,{} )
EndIf

While SRA->( !Eof() )

	If oSelf:lEnd
		Break
	EndIf

	If SRA->(Eof())
		Exit
	EndIf

	If !(SRA->RA_SITFOLH $ cSituacao)
		SRA->(DbSkip())
		Loop
	EndIf

	If !(SRA->RA_CATFUNC $ cCategoria)
		SRA->(DbSkip())
		Loop
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste Filiais e Acessos                                             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !( SRA->RA_FILIAL $ fValidFil() )
		dbSelectArea("SRA")
		dbSkip()
		Loop
	EndIf

	oSelf:IncRegua1(OemToAnsi(STR0020) + "  " + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " - " + If(lOfusca, Replicate('*', 15), SRA->RA_NOME) )//"Gerando beneficio para:"

	DbSelectArea("RI1")

	cCodSeq := "001"

	If DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cCodBenef + cCodTab)
		RecLock("RI1",.F.)
		aAdd( aLog[1], OemToAnsi(STR0026) + "  " + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " - " + If(lOfusca, Replicate('*', 15), SRA->RA_NOME ) )//"Funcionario: "
		aAdd( aLog[1], Space(6) + OemToAnsi(STR0027) + " " + ;										//"Beneficio alterado: "
						OemToAnsi(STR0028) + " " + RI1->RI1_BENEF + " - " + fDescRCC("S011",RI1->RI1_BENEF,1,2,3,30) + " / " + ; 							//"Tipo de Beneficio: "
						OemToAnsi(STR0029) + " " + RI1->RI1_TABELA + " - " + FDESC('RIS',RI1->RI1_BENEF+RI1->RI1_TABELA,'RIS_DESC') ) 						// "Código Beneficio: "
	Else
		If DbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			While !Eof() .and. RI1_FILIAL + RI1_MAT == SRA->RA_FILIAL + SRA->RA_MAT
				cCodSeq := Soma1(cCodSeq)
				DbSkip()
			EndDo
		EndIf
		RecLock("RI1",.T.)
	EndIf

	RI1_FILIAL 	:= SRA->RA_FILIAL
	RI1_MAT		:= SRA->RA_MAT
	RI1_COD		:= cCodSeq
	RI1_BENEF	:= cCodBenef
	RI1_TABELA  := cCodTab
	RI1_PD		:= cPdBen
	RI1_PD1		:= cPdDesc
	RI1_PD2		:= cPdEmp
	RI1_PROPOR 	:= cPropor
	RI1_DINIPG	:= dDtIni
	RI1_DFIMPG	:= dDtFim

	MsUnLock()

	SRA->(DbSkip())
EndDo

If !Empty(cFiltro)
	cFiltro := ".T."
	bFiltro := { || .T. }
	SRA->(DbSetfilter( bFiltro, cFiltro ))
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Gp65BenefVld	³ Autor ³ Leandro Drumond   ³ Data ³ 20.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valid do campo RI1_BENEF.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp65BenefVld(lLote, cCodTab)
Local aArea		:= GetArea()
Local cVar		:= &(ReadVar())
Local cDesc		:= ""
Local lRet 		:= .F.
Local nPosIni	:= 1
Local nLenCod	:= 0
Local nOrdem	:= 0
Local nX		:= 0

DEFAULT cCodTab := "S011"
DEFAULT lLote	:= .F.

DbSelectARea("RCB")
RCB->(dbSetOrder(3))
If RCB->(dbSeek(xFilial("RCB")+"BRA_S01101"+cCodTab))

	nLenCod := RCB->RCB_TAMAN
	nOrdem := Val(RCB->RCB_ORDEM)

	RCB->(dbSetOrder(1))
	RCB->(dbSeek(xFilial("RCB")+cCodTab))

	While nX < nOrdem .and. RCB->RCB_CODIGO == cCodTab

		If Val(RCB->RCB_ORDEM) < nOrdem
			nPosIni += RCB->RCB_TAMAN
			nX++
		EndIf
		RCB->(DbSkip())
	EndDo

	RCC->(dbSetOrder(1))

	If RCC->(dbSeek(xFilial("RCC")+cCodTab))
		While RCC->RCC_CODIGO == cCodTab .and. !lRet
			If cVar == SubStr(RCC->RCC_CONTEU,nPosIni,nLenCod) .and.;
				(Empty(RCC->RCC_FIL) .or. RCC->RCC_FIL == SRA->RA_FILIAL)
				lRet := .T.
				cDesc := SubStr(RCC->RCC_CONTEU,nPosIni+nLenCod,30)
			EndIf
			RCC->(DbSkip())
		EndDo
	EndIf
EndIf

If lRet .and. !lLote
	oModel := FWModelActivate()
	oModel:GetModel("RI1DETAIL"):SetValue("RI1_DESCBN",cDesc)
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Gp65FilRIS	³ Autor ³ Leandro Drumond   ³ Data ³ 20.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro da consulta padrao RIS.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp65FilRIS()
Local oModel 	:= FWModelActivate()
Local cBenef   	:= ""
Local cFiltro 	:= ""
Local oBen

If IsInCallStack("Gp065Lote")
	cBenef := mv_par04
ElseIf IsInCallStack("GPEA061")
	cBenef := oModel:GetModel('GPEA061_TMP'):GetValue("TMP_TPBEN")
//ElseIf IsInCallStack("TESTE1")
//	cBenef := oModel:GetModel('GPEA061_SLY'):GetValue("LY_TIPO")
Else
	If Valtype(oModel:GetModel('RI1DETAIL')) == "O"
		cBenef := oModel:GetModel('RI1DETAIL'):GetValue("RI1_BENEF")
	ElseIf Valtype(oModel:GetModel('GPEA061_SLY')) == "O"
		cBenef := oModel:GetModel('GPEA061_SLY'):GetValue("LY_TIPO")
	EndIf
Endif

cFiltro := " RIS->RIS_TPBENE == '" + cBenef + "' "

cFiltro := "@#" + cFiltro + "@#"

Return cFiltro

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Gp65TabVld	³ Autor ³ Leandro Drumond   ³ Data ³ 20.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valid do campo RI1_TABELA.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function  Gp65TabVld(lLote)
Local lRet		:= .T.
Local cVar		:= &(ReadVar())
Local oModel
Local oGrid

DEFAULT lLote := .F.

If !lLote
	oModel 	:= FWModelActivate()
	oGrid   	:= oModel:GetModel('RI1DETAIL')
EndIf

DbSelectArea("RIS")

If DbSeek(xFilial("RIS")+If(!lLote,oGrid:GetValue("RI1_BENEF"),mv_par04)+cVar)
	If !lLote
		oGrid:SetValue("RI1_DESCTB",RIS->RIS_DESC)
		oGrid:SetValue("RI1_PD",RIS->RIS_PD)
		oGrid:SetValue("RI1_PD1",RIS->RIS_PD1)
		oGrid:SetValue("RI1_PD2",RIS->RIS_PD2)
		oGrid:SetValue("RI1_PROPOR",RIS->RIS_PROPOR)
	EndIf
Else
	Help(,,STR0010,, STR0021, 1, 0 )  // "Cod. da Tabela não localizado." # "Atencao"
	lRet := .F.
EndIf

Return lRet


Static Function Gp065PreValid(oMdl)

	Local lRet		:= .T.
	Local oGrid
	Local nOrd1RH4	:= RetOrdem( "RH4", "RH4_FILIAL+RH4_CODIGO+STR(RH4_ITEM,3,0)" )

	Static lFirst := .T.

	If IsInCallStack("TCFA040") .And. lFirst

		lFirst := .F. // A função é chamada várias vezes pelo MVC, mas deve executar apenas uma vez

		If !Empty(cRH3Cod)
			oGrid := oMdl:GetModel('RI1DETAIL')

			If !Empty(oGrid:GetValue("RI1_BENEF"))
				oGrid:AddLine()
			Endif

			oGrid:SetValue("RI1_BENEF", "83")

			//Buscar jornada solicitada
			DbSelectArea("RH4")
			RH4->(DbSetOrder(nOrd1RH4))
			RH4->(dbSeek(xFilial("RH4") + cRH3Cod))

			While RH4->(!Eof()) .AND. RH4->RH4_FILIAL + RH4->RH4_CODIGO == xFilial("RH4") + cRH3Cod

				Do Case
					Case alltrim(RH4->RH4_CAMPO) == "RI1_TABELA"
						oGrid:SetValue("RI1_TABELA", SubStr(RH4->RH4_VALNOV, 1, 2))
					Case alltrim(RH4->RH4_CAMPO) == "RI1_DINIPG"
						oGrid:SetValue("RI1_DINIPG", CtoD(RH4->RH4_VALNOV))
					Case alltrim(RH4->RH4_CAMPO) == "RI1_DFIMPG"
						oGrid:SetValue("RI1_DFIMPG", CtoD(RH4->RH4_VALNOV))
				EndCase

				RH4->(dbSkip())
			EndDo
		Else
			lRet:= .F.
		EndIf
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp065Commit ³ Autor ³ Flavio Correa         ³ Data ³03/05/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Commit														³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Gp065Commit(oModel)
Local nOperation	:= oModel:GetOperation()
Local oModelRI1 	:= oModel:GetModel("RI1DETAIL")
Local cTmp		:= ""
Local oRIQ
Local oRI1
Local nLinhas		:= 0
Local nI			:= 1
Local nX			:= 1
Local nRI1			:= oModelRI1:Length()


If nOperation == MODEL_OPERATION_DELETE .Or. nOperation == MODEL_OPERATION_UPDATE
		For nX := 1 To nRI1
			oModelRI1:GoLine( nX )
			If oModelRI1:IsDeleted() .Or. nOperation == MODEL_OPERATION_DELETE
				cTmp := GetNextAlias()
				BeginSql alias cTmp
					SELECT R_E_C_N_O_ AS RECNO FROM  %table:RIQ% RIQ
					WHERE RIQ.RIQ_FILIAL = %exp:oModelRI1:GetValue("RI1_FILIAL")%
					AND RIQ.RIQ_MAT =  %exp:oModelRI1:GetValue("RI1_MAT")%
					AND RIQ.%notDel%
					AND RIQ.RIQ_TPBENE =  %exp:oModelRI1:GetValue("RI1_BENEF")%
					AND RIQ.RIQ_COD =  %exp:oModelRI1:GetValue("RI1_TABELA")%
				EndSql

				While !(cTmp)->(Eof())
					dbSelectArea("RIQ")
					RIQ->(dbGoto((cTmp)->RECNO))
					RecLock("RIQ",.F.)
						RIQ->(dbDelete())
					RIQ->(msUnlock())
					(cTmp)->(dbSkip())
				EndDo
				(cTmp)->(dbCloseArea())
			EndIf
		Next nX

		FWFormCommit(oModel) //Grava novo registro

EndIf

Return .T.


Static Function Gp065PosValid(oModel)

Local AREGS := {}
Local lret := .T.
Local nX
Local nOperation	:= oModel:GetOperation()
Local oModelRI1 	:= oModel:GetModel("RI1DETAIL")
Local nRI1			:= oModelRI1:Length()
Local dAuxini
Local dAuxFim
Local cTpBen
Local cCodBen

	if nOperation <> MODEL_OPERATION_DELETE
		FOR NX := 1 TO nRI1
			oModelRI1:GoLine( nX )
			if !oModelRI1:IsDeleted()

				dAuxini := oModel:GetModel('RI1DETAIL'):GetValue("RI1_DINIPG")
				dAuxFim := oModel:GetModel('RI1DETAIL'):GetValue("RI1_DFIMPG")
				cTpBen  := oModel:GetModel('RI1DETAIL'):GetValue("RI1_BENEF")
				cCodBen := oModel:GetModel('RI1DETAIL'):GetValue("RI1_TABELA")

				if empty(dAuxini) .and. empty(dAuxFim)
					Help( ,, STR0010 , , STR0034 , 1, ,,,,,, {STR0037})
					return(.f.)
				Endif

				IF dAuxini >= dAuxFim .and. !empty(dAuxFim) .and. !empty(dAuxini)
					Help( ,, STR0010 , , STR0035 , 1, ,,,,,, {STR0038})
					return(.f.)
				EndIf

				IF dAuxFim <= dAuxini  .and. !empty(dAuxFim) .and. !empty(dAuxini)
					Help( ,, STR0010 , , STR0036 , 1, ,,,,,, {STR0039})
					return(.f.)
				EndIf

				if aScan( AREGS , { |z| (!empty(dAuxini) .and. dAuxini >= z[1] .and. dAuxini <= z[2] .AND. z[3] == cTpBen .AND. z[4] == cCodBen) } ) > 0
					Help( ,, STR0031 , , STR0032 , 1, ,,,,,, {STR0033})
					return(.f.)
				elseIF aScan( AREGS , { |z| (!empty(dAuxFim) .and. dAuxFim >= z[1] .and. dAuxFim <= z[2] .AND. z[3] == cTpBen .AND. z[4] == cCodBen) } ) > 0
					Help( ,, STR0031 , , STR0032 , 1, ,,,,,, {STR0033})
					return(.f.)
				ELSE
					AADD(AREGS, {dAuxini, dAuxFim, cTpBen, cCodBen})
				Endif
			Endif
		Next NX
	Endif
return lret