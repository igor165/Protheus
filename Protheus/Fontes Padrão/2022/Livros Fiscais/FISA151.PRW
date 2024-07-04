#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA151.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA151()

Cadastro das Atividades Econòmicas do Simples Nacional

@author Erick G. Dias
@since 28/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA151()

Local   oBrowse := Nil

IF	AliasIndic("F12") .AND. AliasIndic("F13") .AND. AliasIndic("F17")

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F12")
    oBrowse:SetDescription(STR0001) // Cadastro das Atividades Econòmicas do Simples Nacional    
    oBrowse:Activate()

Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações da Apuração do Simples Nacional
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA151" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Erick G Dias
@since 27/02/2017
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel	:= Nil
//Cria as estruturas das tabelas F12 e F13
Local oAtividade	     := FWFormStruct(1, "F12" )
Local oMercadoria	     := FWFormStruct(1, "F13" ,{|cCampo| CAMPOSF13( cCampo , "MERCADORIA" )})
Local oServico	         := FWFormStruct(1, "F13" ,{|cCampo| CAMPOSF13( cCampo , "SERVICO"    )})
Local oTra_Comu	         := FWFormStruct(1, "F13" ,{|cCampo| CAMPOSF13( cCampo , "TRA_COMU"   )})
Local oLocacao	         := FWFormStruct(1, "F13" ,{|cCampo| CAMPOSF13( cCampo , "LOCACAO"    )})

Local oSubAtividade  := FWFormStruct(1, "F17"                                               )
Local cMer           :=  "1"
Local cServ          :=  "2"
Local cTraComu       :=  "3"
Local cLoca          :=  "4"

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA151',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })

//Atribuindo estruturas para o modelo
oModel:AddFields( "FISA151",, oAtividade )

//Adiciona o Grid ao modelo
oModel:AddGrid( 'FISA151MERCADORIA'      , 'FISA151', oMercadoria,,{|oModelGrid| VALIDAGRID(oModelGrid, "MERCADORIA")})
oModel:AddGrid( 'FISA151SERVICO'         , 'FISA151', oServico,,{|oModelGrid| VALIDAGRID(oModelGrid, "SERVICO")})
oModel:AddGrid( 'FISA151TRA_COMU'        , 'FISA151', oTra_Comu,,{|oModelGrid| VALIDAGRID(oModelGrid, "TRANSPCOM")})
oModel:AddGrid( 'FISA151LOCACAO'         , 'FISA151', oLocacao,,{|oModelGrid| VALIDAGRID(oModelGrid, "LOCACAO")})
oModel:AddGrid( 'FISA151SUBATIVIDADE'    , 'FISA151', oSubAtividade)

oModel:GetModel( 'FISA151MERCADORIA' ):SetOptional( .T. )
oModel:GetModel( 'FISA151SERVICO' ):SetOptional( .T. )
oModel:GetModel( 'FISA151TRA_COMU' ):SetOptional( .T. )
oModel:GetModel( 'FISA151LOCACAO' ):SetOptional( .T. )
oModel:GetModel( 'FISA151SUBATIVIDADE' ):SetOptional( .T. )

oMercadoria:SetProperty('F13_TIPO'    ,     MODEL_FIELD_INIT    ,{||FSA151TIPO("1")} )
oServico:SetProperty(   'F13_TIPO'    ,     MODEL_FIELD_INIT    ,{||FSA151TIPO("2")} )
oTra_Comu:SetProperty(  'F13_TIPO'    ,     MODEL_FIELD_INIT    ,{||FSA151TIPO("3")} )
oLocacao:SetProperty(   'F13_TIPO'    ,     MODEL_FIELD_INIT    ,{||FSA151TIPO("4")} )

//Deixará desabilitado os campos abaixo
oAtividade:SetProperty('F12_CODATV'  , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
oAtividade:SetProperty('F12_TPREC'   , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
oSubAtividade:SetProperty('F17_SUBATV'   , MODEL_FIELD_WHEN, {|| oModel:GetOperation()==3 })


//Define linhas unicas do grid
oModel:GetModel( 'FISA151SUBATIVIDADE' ):SetUniqueLine( { 'F17_SUBATV' } )
oModel:GetModel( 'FISA151MERCADORIA' ):SetUniqueLine(   { 'F13_CFOP'    ,'F13_INIVIG' } )
oModel:GetModel( 'FISA151SERVICO' ):SetUniqueLine(      { 'F13_CODISS'  ,'F13_INIVIG' } )
oModel:GetModel( 'FISA151TRA_COMU' ):SetUniqueLine(     { 'F13_CFOP'    ,'F13_INIVIG' } )
oModel:GetModel( 'FISA151LOCACAO' ):SetUniqueLine(      { 'F13_GRUPO'   ,'F13_INIVIG' } )

oModel:GetModel( 'FISA151SUBATIVIDADE' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'FISA151SUBATIVIDADE' ):SetMaxLine(1)

oModel:SetPrimaryKey({""})

oModel:SetRelation( 'FISA151MERCADORIA'     , { { 'F13_FILIAL', 'xFilial( "F13" )' }, { 'F13_CODATV', 'F12_CODATV' }, { 'F13_TIPO', "'1'" }, { 'F13_IDATV', 'F12_ID' }}, "F13_CFOP+DTOS(F13_INIVIG)+DTOS(F13_FIMVIG)"     )
oModel:SetRelation( 'FISA151SERVICO'        , { { 'F13_FILIAL', 'xFilial( "F13" )' }, { 'F13_CODATV', 'F12_CODATV' }, { 'F13_TIPO', "'2'" }, { 'F13_IDATV', 'F12_ID' } }, "F13_CODISS+DTOS(F13_INIVIG)+DTOS(F13_FIMVIG)"  )
oModel:SetRelation( 'FISA151TRA_COMU'       , { { 'F13_FILIAL', 'xFilial( "F13" )' }, { 'F13_CODATV', 'F12_CODATV' }, { 'F13_TIPO', "'3'" }, { 'F13_IDATV', 'F12_ID' } }, "F13_CFOP+DTOS(F13_INIVIG)+DTOS(F13_FIMVIG)"    )
oModel:SetRelation( 'FISA151LOCACAO'        , { { 'F13_FILIAL', 'xFilial( "F13" )' }, { 'F13_CODATV', 'F12_CODATV' }, { 'F13_TIPO', "'4'" }, { 'F13_IDATV', 'F12_ID' } }, "F13_GRUPO+DTOS(F13_INIVIG)+DTOS(F13_FIMVIG)"   )

oModel:SetRelation( 'FISA151SUBATIVIDADE'   , { { 'F17_FILIAL', 'xFilial( "F17" )' }, { 'F17_CODATV', 'F12_CODATV' }                      }                             , "F17_SUBATV"  )

//Adicionando descrição ao modelo
oModel:SetDescription( STR0001 ) // Cadastro das Atividades Econòmicas do Simples Nacional

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erick G Dias
@since 27/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel            := FWLoadModel( "FISA151" )
Local oAtividade	    := FWFormStruct(2, "F12")
Local oMercadoria		:= FWFormStruct(2, "F13",{|cCampo| CAMPOSF13( cCampo , "MERCADORIA"  )})
Local oServico  		:= FWFormStruct(2, "F13",{|cCampo| CAMPOSF13( cCampo , "SERVICO"     )})
Local oTra_Comu  		:= FWFormStruct(2, "F13",{|cCampo| CAMPOSF13( cCampo , "TRA_COMU"    )})
Local oLocacoes  		:= FWFormStruct(2, "F13",{|cCampo| CAMPOSF13( cCampo , "LOCACAO"     )})
Local oSubAtividades	:= FWFormStruct(2, "F17"                                               )
Local oView             := Nil
Local cVersao 	        := GetVersao(.F.)

oView := FWFormView():New()
oView:SetModel( oModel )

//--------------------------------------
//Atribuindo formulários para interface
//--------------------------------------
oView:AddField( 'VIEW_ATIVIDADE'        , oAtividade          , 'FISA151'             )
oView:AddGrid(  'VIEW_MERCADORIA'       , oMercadoria         , 'FISA151MERCADORIA'   )
oView:AddGrid(  'VIEW_TRA_COMU'         , oTra_Comu           , 'FISA151TRA_COMU'     )
oView:AddGrid(  'VIEW_SERVICO'          , oServico            , 'FISA151SERVICO'      )
oView:AddGrid(  'VIEW_LOCACOES'         , oLocacoes           , 'FISA151LOCACAO'      )
oView:AddGrid(  'VIEW_SUBATIVIDADES'    , oSubAtividades      , 'FISA151SUBATIVIDADE' )

//Retira os campos de ID e  tipo da tela
oSubAtividades:RemoveField( 'F17_IDATV' )
oSubAtividades:RemoveField( 'F17_ID'    )
oAtividade:RemoveField(     'F12_ID'    )
oMercadoria:RemoveField(    'F13_ID'    )
oServico:RemoveField(       'F13_ID'    )
oTra_Comu:RemoveField(      'F13_ID'    )
oLocacoes:RemoveField(      'F13_ID'    )
oMercadoria:RemoveField(    'F13_TIPO'  )
oServico:RemoveField(       'F13_TIPO'  )
oTra_Comu:RemoveField(      'F13_TIPO'  )
oLocacoes:RemoveField(      'F13_TIPO'  )

//--------------------------------------
//Cria painel principal
//--------------------------------------
oView:CreateHorizontalBox( 'SUPERIOR', 20 )
oView:CreateHorizontalBox( 'INFERIOR', 80 )

//--------------------------------------
//Cria um folder no box Inferior
//--------------------------------------
oView:CreateFolder( 'FOLDER_GERAL', 'INFERIOR' )

//--------------------------------------
//Cria dois Sheets no folder geral
//--------------------------------------
oView:AddSheet( 'FOLDER_GERAL', 'ABA_RECEITAS'   , STR0010 ) //"Origem das Receitas"
oView:AddSheet( 'FOLDER_GERAL', 'ABA_SUBRECEITAS', STR0009 ) //"Sub Atividades Econômicas"

//--------------------------------------
//Cria box da aba de subatividade
//--------------------------------------
oView:CreateHorizontalBox( 'PAINEL_SUBATIVIDADES' , 100,,, 'FOLDER_GERAL', 'ABA_SUBRECEITAS' )
oView:CreateHorizontalBox( 'PAINEL_RECEITAS'      , 100,,, 'FOLDER_GERAL', 'ABA_RECEITAS'    )

//--------------------------------------
//Cria Novo Folder dentro do Folder das Receitas
//--------------------------------------
oView:CreateFolder( 'RECEITAS', 'PAINEL_RECEITAS' )

//--------------------------------------
//Adiciona novos Sheets no subfolder de receitas
//--------------------------------------
oView:AddSheet( 'RECEITAS' , 'ABA_MERCADORIA'          , "CFOP - " + STR0005  )//"Mercadorias"
oView:AddSheet( 'RECEITAS' , 'ABA_SERVICO_TRA_COMU'    , "CFOP - " +STR0007   )//"Serviços de Transportes/Comunicação"
oView:AddSheet( 'RECEITAS' , 'ABA_SERVICO'             , STR0006              )//"Serviços ISS"
oView:AddSheet( 'RECEITAS' , 'ABA_LOCACOES'            , STR0008              )//"Locações"

//--------------------------------------
//Cria os Box para caba aba
//--------------------------------------
oView:CreateHorizontalBox( 'MERCADORIA'   , 100 ,,, 'RECEITAS', 'ABA_MERCADORIA'        )
oView:CreateHorizontalBox( 'TRA_COMU'     , 100 ,,, 'RECEITAS', 'ABA_SERVICO_TRA_COMU'  )
oView:CreateHorizontalBox( 'SERVICO'      , 100 ,,, 'RECEITAS', 'ABA_SERVICO'           )
oView:CreateHorizontalBox( 'LOCACOES'     , 100 ,,, 'RECEITAS', 'ABA_LOCACOES'          )

//--------------------------------------
//Seta a View com seu respectivo Owner
//--------------------------------------
oView:SetOwnerView( 'VIEW_ATIVIDADE'       , 'SUPERIOR'             )
oView:SetOwnerView( 'VIEW_SUBATIVIDADES'   , 'PAINEL_SUBATIVIDADES' )
oView:SetOwnerView( 'VIEW_MERCADORIA'      , 'MERCADORIA'           )
oView:SetOwnerView( 'VIEW_SERVICO'         , 'SERVICO'              )
oView:SetOwnerView( 'VIEW_TRA_COMU'        , 'TRA_COMU'             )
oView:SetOwnerView( 'VIEW_LOCACOES'        , 'LOCACOES'             )

oView:EnableTitleView('VIEW_ATIVIDADE'       , STR0011  )//"Atividade Econômica"
oView:EnableTitleView('VIEW_MERCADORIA'      , STR0012  )//"Receitas de Mercadorias"
oView:EnableTitleView('VIEW_SERVICO'         , STR0013  )//"Receitas de Serviço - ISS"
oView:EnableTitleView('VIEW_TRA_COMU'        , STR0014  )//"Receitas de Serviço - Transporte/Comunicação"
oView:EnableTitleView('VIEW_LOCACOES'        , STR0015  )//"Receitas de Locação"
oView:EnableTitleView('VIEW_SUBATIVIDADES'   , STR0016  )//"Detalhamento das Sub Atividades"

//Desabilita ordenação do grid
IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID" )
	oView:SetViewProperty( "*", "GRIDNOORDER"  )
EndIF

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CAMPOSF13
Função que fará controle de quais campos serão exibidos nas abas.

@param		cCampo    - String  -  Campo da tabela F13
@param		cOpcao    - String  -  Aba de mercadoria, servicos ISS, servicos transporte/cmunicação ou localações

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CAMPOSF13( cCampo , cOpcao)

Local lRet 			:= .F.
Local cMercadoria   := "F13_CFOP/F13_ANEXO/F13_DCFOP/F13_DANEXO/F13_TIPO/F13_ID/F13_INIVIG/F13_FIMVIG"
Local cServico      := "F13_CODISS/F13_FATORR/F13_ASUB/F13_ANEXO/F13_DISS/F13_DANEXO/F13_DASUB/F13_TIPO/F13_ID/F13_TPSERV/F13_INIVIG/F13_FIMVIG"
Local cTra_Comu     := "F13_CFOP/F13_ANEXO/F13_DCFOP/F13_DANEXO/F13_TIPO/F13_ID/F13_INIVIG/F13_FIMVIG"
Local cLocacao      := "F13_GRUPO/F13_ANEXO/F13_DGRUPO/F13_DANEXO/F13_TIPO/F13_ID/F13_INIVIG/F13_FIMVIG"

If cOpcao = "MERCADORIA"
    If AllTrim( cCampo )  $ cMercadoria
        lRet := .T.
    EndIf
ElseIf cOpcao = "SERVICO"
    If AllTrim( cCampo )  $ cServico
        lRet := .T.
    EndIf
ElseIF  cOpcao = "TRA_COMU"
    If AllTrim( cCampo )  $ cTra_Comu
        lRet := .T.
    EndIf
ElseIF  cOpcao = "LOCACAO"
    If AllTrim( cCampo )  $ cLocacao
        lRet := .T.
    EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA151ATIV
Função que iniciará a carga inicial das atividades

@author Erick G Dias
@since 01/03/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA151ATIV()

//Verifica se já existe ao menos uma atividade cadastrada no banco
If !ExisteAtividade()

    //Realiza inclusão das atividades
    AdicionaAtividade()

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteAtividade
Função que verifica se já exise ao menos uma atividade já cadastrada no banco

@return lRet - Boolean - .T. se já existir informação no banco, .F. caso informação ainda não exista.
@author Erick G Dias
@since 01/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ExisteAtividade()

Local lRet:= .F.

dbSelectArea('F12')
dbSetOrder(1)

//Se houver ao menos uma linha criada na tabela F12, a rotina não fará a carga inicial das atividades
If	F12->( MsSeek ( xFilial('F12') ) )
    lRet:= .T.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvAtividade
Funçãoo que realiza gravação na tabela de atividade F12.

@param		cOp       - String  -  Opção, 1=Inclusão, 2=Edição
@param		cCodAtv   - String  -  Código da Atividade
@param		cDescr    - String  -  Descrição da atividade
@param		cTpAtv    - String  -  Tipo a atividade
@param		cTpRec    - String  -  Tipo da receita, mercado interno ou exportação

@author Erick G Dias
@since 01/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function GrvAtividade( cOp, cCodAtv, cDescr, cTpAtv, cTpRec )

//Inclusão
If cOp == "1"

    RecLock('F12',.T.)

    F12->F12_FILIAL     := xFilial("F12")
    F12->F12_ID         := FWUUID("F12")
    F12->F12_CODATV     := cCodAtv
    F12->F12_DESCR      := cDescr
    F12->F12_TPATIV     := cTpAtv
    F12->F12_TPREC      := cTpRec

    F12->(msUnlock())

EndIf

Return F12->F12_ID

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvDetAtividade
Funçãoo que realiza gravação do detalhamento da atividade na tabela F13

@param		cOp       - String  -  Opção, 1=Inclusão, 2=Edição
@param		cCodAtv   - String  -  Código da Atividade
@param		cAnexo    - String  -  Código do Anexo
@param		cCodIss   - String  -  Código do Serviço
@param		cFatorR   - String  -  Código do Serviço
@param		cAsub     - String  -  Código do Serviço
@param		cCfop     - String  -  Código do Serviço
@param		cGrupo    - String  -  Código do Serviço
@param		cTipo     - String  -  Código do Serviço
@param		cidAtv    - String  -  Id da Atividade

@author Erick G Dias
@since 01/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function GrvDetAtividade( cOp, cCodAtv, cAnexo, cCodIss, cFatorR, cAsub, cCfop, cGrupo, cTipo, cIdAtv )

//Inclusão
If cOp == "1"

    RecLock('F13',.T.)

    F13->F13_FILIAL     := xFilial("F13")
    F13->F13_ID         := FWUUID("F13")
    F13->F13_IDATV      := cIdAtv
    F13->F13_CODATV     := cCodAtv
    F13->F13_ANEXO      := cAnexo
    F13->F13_CODISS     := cCodIss
    F13->F13_FATORR     := cFatorR
    F13->F13_ASUB       := cAsub
    F13->F13_CFOP       := cCfop
    F13->F13_GRUPO      := cGrupo
    F13->F13_TIPO       := cTipo
    F13->F13_INIVIG     := CTOD("01/01/2018")

    F13->(msUnlock())

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvDetAtividade
Função que realiza gravação do detalhamento da atividade na tabela F13

@param		cOp       - String  -  Opção, 1=Inclusão, 2=Edição
@param		cCodAtv   - String  -  Código da Atividade
@param		cSubAtv   - String  -  Código da Sub Atividade
@param		cDescr    - String  -  Descrição da Sub Atividade
@param		cIrpj     - String  -  Opção de cálculo do IRPJ 1 = Calcula,2=Não CAlcula, 3=Reduz Alíquota
@param		cCsll     - String  -  Opção de cálculo do CSLL 1 = Calcula,2=Não CAlcula, 3=Reduz Alíquota
@param		cCofins   - String  -  Opção de cálculo do COFINS 1 = Calcula,2=Não CAlcula, 3=Reduz Alíquota
@param		cPis      - String  -  Opção de cálculo do PIS 1 = Calcula,2=Não CAlcula, 3=Reduz Alíquota
@param		cCpp      - String  -  Opção de cálculo do CPP 1 = Calcula,2=Não CAlcula, 3=Reduz Alíquota
@param		cIcms     - String  -  Opção de cálculo do ICMS 1 = Calcula,2=Não CAlcula, 3=Reduz Alíquota
@param		cIpi      - String  -  Opção de cálculo do IPI 1 = Calcula,2=Não CAlcula, 3=Reduz Alíquota
@param		cIss      - String  -  Opção de cálculo do ISS 1 = Calcula,2=Não CAlcula, 3=Reduz Alíquota
@paramcIdAtvcIss      - String  -  Id da Atividade

@author Erick G Dias
@since 01/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function GrvSubAtividade( cOp, cCodAtv, cSubAtv, cDescr, cIrpj, cCsll, cCofins, cPis, cCpp, cIcms, cIpi, cIss, cIdAtv )

//Inclusão
If cOp == "1"

    RecLock('F17',.T.)

    F17->F17_FILIAL  := xFilial("F17")
    F17->F17_ID      := FWUUID("F17")
    F17->F17_IDATV    := cIdAtv
    F17->F17_CODATV  := cCodAtv
    F17->F17_SUBATV  := cSubAtv
    F17->F17_DESCR   := cDescr
    F17->F17_IRPJ    := cIrpj
    F17->F17_CSLL    := cCsll
    F17->F17_COFINS  := cCofins
    F17->F17_PIS     := cPis
    F17->F17_CPP     := cCpp
    F17->F17_ICMS    := cIcms
    F17->F17_IPI     := cipi
    F17->F17_ISS     := cIss
    F17->(msUnlock())

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AdicionaAtividade
Função que fará chamada da gravação de cada Atividade do Simples

@author Erick G Dias
@since 01/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function AdicionaAtividade()

Local INCLUSAO      := "1"
Local cIdAtv        := ""

cIdAtv  := GrvAtividade( INCLUSAO, "01", STR0056, "0" , "1")//"Revenda de Mercadorias, exceto para o exterior"
AdicionaDetalhe( "01", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "02", STR0057, "0",  "2" )//"Revenda de Mercadorias para o exterior"
AdicionaDetalhe( "02", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "03", STR0058, "0",  "1" )//"Venda de mercadorias industrializadas pelo contribuinte, exceto para o exterior"
AdicionaDetalhe( "03", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "04", STR0059, "0",  "2" )//"Venda de mercadorias industrializadas pelo contribuinte para o exterior"
AdicionaDetalhe( "04", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "05", STR0060, "0", "1" )//"Locação de bens móveis, exceto para o exterior"
AdicionaDetalhe( "05", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "06", STR0061, "0", "2" )//"Locação de bens móveis para o exterior"
AdicionaDetalhe( "06", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "07", STR0062, "0", "1" )//"Pr estação de Serviços, exceto para o exterior"
AdicionaDetalhe( "07", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "08", STR0063, "0", "1" )//"Prestação de Serviços relacionados nos subitens 7.02, 7.05 e 16.1 da lista anexa à LC 116/2003, exceto para o exterior"
AdicionaDetalhe( "08", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "09", STR0064, "0", "2" )//"Prestação de Serviços para o exterior"
AdicionaDetalhe( "09", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "10", STR0065, "0", "2" )//"Prestação de Serviços relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003, para o exterior"
AdicionaDetalhe( "10", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "11", STR0066, "1", "1" )//"Serviços de comunicação; de transporte intermunicipal e interestadual de carga; e de transporte intermunicipal e interestadual de passageiros autorizados no inciso VI do art. 17 da LC 123, exceto para o exterior"
AdicionaDetalhe( "11", cIdAtv)

cIdAtv  := GrvAtividade( INCLUSAO, "12", STR0067, "1", "2" )//"Serviços de comunicação; de transporte intermunicipal e interestadual de carga; e de transporte intermunicipal e interestadual de passageiros autorizados no inciso VI do art. 17 da LC 123, para o exterior"
AdicionaDetalhe( "12", cIdAtv)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AdicionaDetalhe
Função responsável por realizar chamadas de gravação do detalhe da atividade
e da sub atividade.

@param		cAtividade       - String  -  Código da Atividade
@param		cIdAtv           - String  -  Id da Atividade

@author Erick G Dias
@since 01/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function AdicionaDetalhe( cAtividade, cIdAtv )

Local INCLUSAO      := "1"
Local CALCULA       := "1"
Local NAOCALCULA    := "2"

If cAtividade == "01" //Revenda

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5102",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5104",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5106",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5110",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5112",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5114",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5115",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5119",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5120",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5123",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5403",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5405",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6102",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6104",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6106",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6108",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6110",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6112",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6114",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6115",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6119",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6120",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6123",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6403",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"01",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6404",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv )

    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"01", /*SubAtividade*/"0101",/*Descrição*/ STR0017,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/CALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA, /*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"01", /*SubAtividade*/"0102",/*Descrição*/ STR0018,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/CALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA, /*IDATIVIDADE*/cIdAtv )


ElseIf cAtividade == "02" //Revenda para Exterior

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    GrvDetAtividade( INCLUSAO, /*Atividade*/"02",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"7102",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"02",/*Anexo*/"01",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"7106",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )

    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"02", /*SubAtividade*/"0201",/*Descrição*/ STR0019,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "03" //Venda

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    //TODO

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5101",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5103",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5105",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5109",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5111",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5113",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5118",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5122",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5124",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5125",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5401",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5402",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6101",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6103",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6105",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6107",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6109",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6111",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6113",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6118",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6122",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6124",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6125",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6401",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"03",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6402",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )


    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"03", /*SubAtividade*/"0301",/*Descrição*/ STR0020,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/CALCULA,/*IPI*/CALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"03", /*SubAtividade*/"0302",/*Descrição*/ STR0021,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/CALCULA,/*IPI*/CALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "04" //Venda para o Exterior

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    //TODO

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    GrvDetAtividade( INCLUSAO, /*Atividade*/"04",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"7101",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"04",/*Anexo*/"02",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"7105",/*Grupo*/"", /*Tipo*/"1", /*IdAtividade*/cIdAtv  )

    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"04", /*SubAtividade*/"0401",/*Descrição*/ STR0022,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "05" //Locação de vens móveis, exceto para exterior

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    //TODO

    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"05", /*SubAtividade*/"0501",/*Descrição*/ STR0023,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "06" //Locação de vens móveis, para o Exterior

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    //TODO

    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"06", /*SubAtividade*/"0601",/*Descrição*/ STR0024,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "07" //Prestação de Serviços, exceto para o exterior

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    //TODO

    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0701",/*Descrição*/ STR0025,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0702",/*Descrição*/ STR0026,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/CALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0703",/*Descrição*/ STR0027,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/CALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0704",/*Descrição*/ STR0028,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0705",/*Descrição*/ STR0029,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0706",/*Descrição*/ STR0030,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/CALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0707",/*Descrição*/ STR0031,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0708",/*Descrição*/ STR0032,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/NAOCALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0709",/*Descrição*/ STR0033,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/NAOCALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/CALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"07", /*SubAtividade*/"0710",/*Descrição*/ STR0034,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/NAOCALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "08" //PRestaçã serviços 7.02, 7.05 e 7.05 exceto para exterior.

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    //TODO

    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"08", /*SubAtividade*/"0801",/*Descrição*/ STR0035,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"08", /*SubAtividade*/"0802",/*Descrição*/ STR0036,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/CALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"08", /*SubAtividade*/"0803",/*Descrição*/ STR0037,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"08", /*SubAtividade*/"0804",/*Descrição*/ STR0038,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/NAOCALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"08", /*SubAtividade*/"0805",/*Descrição*/ STR0039,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/NAOCALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/CALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"08", /*SubAtividade*/"0806",/*Descrição*/ STR0040,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/NAOCALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"08", /*SubAtividade*/"0807",/*Descrição*/ STR0041,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"08", /*SubAtividade*/"0808",/*Descrição*/ STR0042,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/CALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"08", /*SubAtividade*/"0809",/*Descrição*/ STR0043,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "09" //Prestação de Serviços para Exterior

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    //TODO

    GrvSubAtividade( INCLUSAO, /*Atividade*/"09", /*SubAtividade*/"0901",/*Descrição*/ STR0044,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"09", /*SubAtividade*/"0902",/*Descrição*/ STR0045,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"09", /*SubAtividade*/"0903",/*Descrição*/ STR0046,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"09", /*SubAtividade*/"0904",/*Descrição*/ STR0047,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "10" //Prestação servços 7.02 7.05 para o exterior

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    //TODO

    GrvSubAtividade( INCLUSAO, /*Atividade*/"10", /*SubAtividade*/"1001",/*Descrição*/ STR0048,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"10", /*SubAtividade*/"1002",/*Descrição*/ STR0049,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/NAOCALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "11" //Serviço transportes comunicação exceto para exterior

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5301",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5302",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5303",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5304",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5305",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5306",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5307",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5351",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5352",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5353",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5354",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5355",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5356",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5357",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5359",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"5360",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6301",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6302",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6303",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6304",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6305",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6306",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6307",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6351",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6352",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6353",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6354",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6355",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6356",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6357",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6359",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    GrvDetAtividade( INCLUSAO, /*Atividade*/"11",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"6360",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )
    
    

    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"11", /*SubAtividade*/"1101",/*Descrição*/ STR0050,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/CALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"11", /*SubAtividade*/"1102",/*Descrição*/ STR0051,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"11", /*SubAtividade*/"1103",/*Descrição*/ STR0052,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/CALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"11", /*SubAtividade*/"1104",/*Descrição*/ STR0053,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/CALCULA,/*PIS*/CALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )

ElseIf cAtividade == "12" //Serviço transportes comunicação  para exterior

    //---------------------------------------
    //Gravação do detalhamento das atividades
    //---------------------------------------
    GrvDetAtividade( INCLUSAO, /*Atividade*/"12",/*Anexo*/"03",/*CodIss*/"",/*FatorR*/"",/*AnexoSub*/"",/*CFOP*/"7301",/*Grupo*/"", /*Tipo*/"3", /*IdAtividade*/cIdAtv  )

    //---------------------------------------
    //Gravação das SubAtividades
    //---------------------------------------
    GrvSubAtividade( INCLUSAO, /*Atividade*/"12", /*SubAtividade*/"1201",/*Descrição*/ STR0054,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
    GrvSubAtividade( INCLUSAO, /*Atividade*/"12", /*SubAtividade*/"1202",/*Descrição*/ STR0055,/*IRPJ*/CALCULA,/*CSLL*/CALCULA,/*Cofins*/NAOCALCULA,/*PIS*/NAOCALCULA,/*CPP*/CALCULA,/*ICMS*/NAOCALCULA,/*IPI*/NAOCALCULA,/*ISS*/NAOCALCULA,/*IDATIVIDADE*/cIdAtv )
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA151TIPO
Função que retornar o código do tipoe

@param		cOp       - String  -  Opção do Tipo do detalhamento da Atividade
@return     cOp       - String  -  Opção do Tipo do detalhamento da Atividade

@author Erick G Dias
@since 02/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function FSA151TIPO(cOp)
Return cOp

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Função que realiza as validações do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA150
@Return     lRet       - Booleano - REtorno com validação, .T. pode gravar, .F. não poderá gravar.
@author Erick G Dias
@since 05/03/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO( oModel )

Local lRet          := .T.
Local cAtividade    := oModel:GetValue ('FISA151',"F12_CODATV" )
Local cTpRec        := oModel:GetValue ('FISA151',"F12_TPREC" )
Local oSubAtv 	    := oModel:GetModel('FISA151SUBATIVIDADE'   )
Local oMercadoria 	:= oModel:GetModel('FISA151MERCADORIA'     )
Local oServico 	    := oModel:GetModel('FISA151SERVICO'        )
Local oTraComu 	    := oModel:GetModel('FISA151TRA_COMU'       )
Local oLocacao 	    := oModel:GetModel('FISA151LOCACAO'        )
Local nOperation 	:= oModel:GetOperation()
Local nX            := 0
Local cCfop         := ""

IF nOperation == MODEL_OPERATION_INSERT
    If	F12->( MsSeek ( xFilial('F12') + cAtividade ) )
        //Já código de atividade cadastrado
        lRet:= .F.
        Help( ,, 'Help',, STR0068 + cAtividade + ")" , 1, 0 ) //"Código de Atividade já cadastrado.
    EndIF
EndiF

//VAlidação do grid de Sub Atividades
IF lRet .AND. nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    //Percorre as linhas de sub atividades para verificar se já estão cadastradas em outra atividade
    For nX := 1 to  oSubAtv:Length(.T.)

        If F17->( MsSeek ( xFilial('F17') + oSubAtv:GetValue("F17_SUBATV",nX) ) ) .AND. cAtividade <> F17->F17_CODATV
            //Já sub Atividade já cadastrada
            Help( ,, 'Help',, STR0069  + oSubAtv:GetValue("F17_SUBATV",nX) +  STR0070 + F17->F17_CODATV + ")."  , 1, 0 ) //"Código de Sub Atividade já cadastrado na atividade
            lRet:= .F.
            Exit
        EndIF

    Next(nX)

EndiF

//Validação do grid de Mercadorias, serviço, transporte/comunicação e locações
IF lRet .AND. nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    //---------------------------
    //Valida grid de Mercadoria
    //---------------------------
    If lRet .AND. ValidF13( "CFOP", "F13_CFOP", cAtividade, oMercadoria )
        Help( ,, 'Help',, STR0071 + F13->F13_CFOP +  STR0070 + F13->F13_CODATV + "). "  , 1, 0 ) //CFOP já cadastrado na atividade
        lRet:= .F.
    EndIF

    //---------------------------
    //Valida Grid de serviços
    //---------------------------
    If lRet .AND. ValidF13( "CODISS", "F13_CODISS", cAtividade, oServico, cTpRec )
        Help( ,, 'Help',, STR0072 + F13->F13_CODISS + ") com tipo de receita (" + Iif(F12->F12_TPREC == '1'  ,"Mercado Interno"  , "Exportação" )  + ") " +  STR0070 + F13->F13_CODATV + ")."  , 1, 0 ) //Código de ISS á cadastrado na atividade
        lRet:= .F.
    EndIF

    //-----------------------------------------
    //Valida grid de Transporte e comunicação
    //-----------------------------------------
    If lRet .AND. ValidF13( "CFOP", "F13_CFOP", cAtividade, oTraComu )
        Help( ,, 'Help',, STR0071 + F13->F13_CFOP +  STR0070 + F13->F13_CODATV + "). "  , 1, 0 ) //CFOP já cadastrado na atividade
        lRet:= .F.
    EndIF

    //-------------------------
    //Valida grid de Locações
    //-------------------------
    If lRet .AND. ValidF13( "GRUPO", "F13_GRUPO", cAtividade, oLocacao, cTpRec )
        Help( ,, 'Help',, STR0073 + F13->F13_GRUPO +  STR0070 + F13->F13_CODATV + "). "  , 1, 0 ) //Grupo já cadastrado na atividade
        lRet:= .F.
    EndIF

    //--------------------------------------------------------------------
    //Validação de CFOP entre as abas mercadoria e transporte comunicação
    //--------------------------------------------------------------------
    If lRet .AND. ValidCFOP( oTraComu, oMercadoria, @cCfop )
        Help( ,, 'Help',, STR0071  + cCfop +  STR0074  , 1, 0 ) //CFOP informado na aba Mercadorias e também na aba Serviços - Transportes/Comunicação
        lRet:= .F.
    EndIF

    IF lRet .AND. cAtividade $ "08/10" .AND.  VldTpServ( "F13_TPSERV",  oServico)
        Help( ,, 'Help',, STR0075  , 1, 0 ) //CFOP informado na aba Mercadorias e também na aba Serviços - Transportes/Comunicação
        lRet:= .F.
    EndIF

    If lRet .And. VldAnxSub(oServico)
        Help( ,, 'Help',, STR0076, 1, 0,,,,,,{STR0077}) //"É obrigatório informar o anexo substituto para serviços sujeitos ao fator R."
        lRet := .F.
    EndIf

EndiF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidF13
Função que valida se o CFOP, Código ISS ou grupo já estão gravados
na tabela F13 para outros códigos de atividades

@param		cOp	        - String  -  Opção do campo a ser verificado
@param		cCampo	    - String  -  Campo da tabela F13
@param		cAtividade	- string  -  Código de atividade a ser verificado
@param		oModelo	    - string  -  Modelo a ser verificado

@Return     lRet       - Booleano - Indica a informação já foi utilizada em outro código de atividade

@author Erick G Dias
@since 05/03/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ValidF13( cOp, cCampo, cAtividade, oModelo, cTpRec)

Local lRet      := .F.
Local nX        := 0
Local lInterno  := .F.
Local lExterno  := .F.
Default cTpRec  := ""

dbSelectArea('F13')

//Seta o índice conforme campo a ser procurado
If cOp == "CFOP"
    dbSetOrder(3)
ElseIF cOp == "CODISS"
    dbSetOrder(5)
ElseIF cOp == "GRUPO"
    dbSetOrder(4)
EndIF

//Percorre as linhas do grid
For nX := 1 to  oModelo:Length()
    oModelo:GoLine( nX )
    
    IF cOp == "CODISS" .OR. cOp == "GRUPO"

        If  !oModelo:IsDeleted() .AND. !Empty(oModelo:GetValue(cCampo,nX)) .AND. F13->( MsSeek ( xFilial('F13') + oModelo:GetValue(cCampo,nX) ) ) .AND. F13->F13_CODATV <> cAtividade
                
            //Rodar F13 do mesmo código ISS e verificar se o código já existe em outra atividade
            //Somente poderá permitir o mesmo código de ISS para uma Atividade interna e uma atividade de exportação 
            //Não poderá permitir mesmo código de ISS para mais de uma atividade interna ou mais de uma atividade de exportação
            Do while F13->F13_FILIAL == xFilial ("F13") .AND. Alltrim(  Iif(cOp=="CODISS", F13->F13_CODISS , F13->F13_GRUPO ) ) == alltrim(oModelo:GetValue(cCampo,nX))
                
                If F13->F13_CODATV <> cAtividade 
                
                    IF F12->( MsSeek ( xFilial('F12') + F13->F13_CODATV ) )

                        IF F12->F12_TPREC == cTpRec
                            //Se atividade for diferente e mesmo tipo de receita, então não poderá permitir gravação
                            lRet:= .T.
                            Exit
                        ElseIF F12->F12_TPREC == '1'
                            //Indica que o código de ISS já está gravado em outra atividade porém com tipo de receita interna
                            lInterno    := .T.
                        ElseIF F12->F12_TPREC == '2'
                            //Indica que o código de ISS já está gravado em outra atividade porém com tipo de receita externa
                            lExterno    := .T.
                        EndIF                

                    EndIF

                EndIF
                
                F13->(dbSkip())  
            EndDo
            
            IF lInterno .AND. lExterno
                //Significa que este código de Iss já foi cadastrado para uma atividade interna e outra atividade de exportação.
                lRet:= .T.
                Exit
            EndIF

        EndIF

    Else

        If  !oModelo:IsDeleted() .AND. !Empty(oModelo:GetValue(cCampo,nX)) .AND. F13->( MsSeek ( xFilial('F13') + oModelo:GetValue(cCampo,nX) ) ) .AND. F13->F13_CODATV <> cAtividade
                
            lRet:= .T.
            Exit
        EndIF

    EndIf

Next(nX)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCFOP
Função que realiza verificação do CFOP entre as abas mercadoria e transporte/comunicação

@param		oModelA	    - Objeto  -  Objeto
@param		oModelB	    - Objeto  -  Objeto
@param		cRet	    - string  -  CFOP que está contido nas duas abas

@Return     lRet       - Booleano - Indica se o CFOP está contido nos dois modelos

@author Erick G Dias
@since 05/03/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ValidCFOP(oModelA, oModelB, cRet)

Local cCfop         := "/"
Local nX            := 0
Local lRet          := .F.
//Monta Lista de CFOP do Grid A
For nX := 1 to  oModelA:Length()
    oModelA:GoLine( nX )
    If  !oModelA:IsDeleted() .AND. !Empty( oModelA:GetValue("F13_CFOP",nX) )
        cCfop  += oModelA:GetValue("F13_CFOP",nX) + "/"
    EndIF
Next(nX)

//Roda o Grid B verificando se o CFOP está contido no Grid A
For nX := 1 to  oModelB:Length()
    oModelB:GoLine( nX )
    If  !oModelB:IsDeleted() .AND. !Empty( oModelB:GetValue("F13_CFOP",nX) ) .AND. oModelB:GetValue("F13_CFOP",nX) $ cCfop
        lRet    := .T.
        cRet    := oModelB:GetValue("F13_CFOP",nX)
        Exit
    EndIF
Next(nX)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteLimite
Função que verifica se tabela de limite já foi populada

@return lRet - Boolean - .T.indica que tabela já foi populada
@author Erick G Dias
@since 01/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ExisteLimite()

Local lRet:= .F.

dbSelectArea('F14')
dbSetOrder(1)

//Se houver ao menos uma linha criada na tabela F14, a rotina não fará a carga inicial dos limites
If	F14->( MsSeek ( xFilial('F14') ) )
    lRet:= .T.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA151LIMITE
Função que preenche os limites do Simples Nacional


@author Erick G Dias
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function FSA151LIMITE()

// Limites padrão
Local nFed          := 4800000
Local nEst          := 0
Local cUfSubLimite  := "AC/AP/RR"

If !ExisteLimite()

    dbSelectArea("SX5")
    dbSetOrder(1)
    If SX5->(MSSeek (xFilial ("SX5") +'12')) //Filtra tabela de Estados

        Do while SX5->X5_FILIAL == xFilial ("SX5") .AND. SX5->X5_TABELA == "12"
            IF Alltrim(SX5->X5_CHAVE) <> "EX"
                nEst    := 3600000
                nMun    := 3600000

                If Alltrim(SX5->X5_CHAVE) $ cUfSubLimite
                    //SubLimites de ICMS e ISS
                    nEst          := 1800000
                    nMun          := 1800000
                EndIF

                GrvLimite(/*UF*/Alltrim(SX5->X5_CHAVE), /*Limite Estadual*/nEst, /*Limite Federal*/nFed, /*Data Inicial*/STOD( "20180101"), /*Data Final*/STOD( space( 8 ) )  )
            EndIF
            SX5->(dbSkip())

        Enddo

    EndIF
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvLimite
FUnção que grava as informações do Limite

@param		cUf	        - String    -  UF
@param		nEst	    - Numeric   -  Limite estadual
@param		nFed	    - Numeric   -  Limite federal
@param		nMun	    - Numeric   -  Limite municipal
@param		dDtIni	    - Date      -  Data Inicial
@param		dDtFim	    - Date      -  Data final

@author Erick G Dias
@since 05/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function GrvLimite( cUf, nEst, nFed, dDtIni, dDtFim  )

RecLock('F14',.T.)

F14->F14_FILIAL     := xFilial("F14")
F14->F14_ID         := FWUUID("F14")
F14->F14_LEST       := nEst
F14->F14_LFED       := nFed
F14->F14_UF         := cUf
F14->F14_INIVIG     := dDtIni
F14->F14_FIMVIG     := dDtFim

F14->(msUnlock())

Return

Static Function VAlidTpServ(  )
Local lRet          := .T.
Local oModel        :=	FWModelActive()
Local oModelPai	    :=	oModel:GetModel('FISA151')
Local oModelServ    :=	oModel:GetModel('FISA151SERVICO')
Local cAtividade    := oModelPai:GetValue('F12_CODATV' )
Local cTpServ    := oModelServ:GetValue('F13_TPSERV' )

IF cAtividade $ "07/08/09/10" .AND. Empty(cTpServ)
    Help( ,, 'Help',, "Para esta Atividade é necessário informar o Tipo do Serviço" , 1, 0 ) //"Código de Sub Atividade já cadastrado na atividade
    lRet    := .F.
EndIF

alert(F12->F12_CODATV)

Return lRet


Static Function VldTpServ( cCampo,  oModelo)

Local lRet      := .F.
Local nX        := 0

//Percorre as linhas do grid
For nX := 1 to  oModelo:Length()
    oModelo:GoLine( nX )
    If  !oModelo:IsDeleted() .AND. Empty( oModelo:GetValue(cCampo,nX) )
        lRet:= .T.
        Exit
    EndIF

Next(nX)

Return lRet

Static Function VALIDAGRID(oModelGrid, cGrid)

Local nX := 0
Local cCampo := ""
Local nLinha := 0
Local lRet := .T.

Do Case

    Case cGrid == "MERCADORIA"
        cCampo := "F13_CFOP"
    Case cGrid == "SERVICO"
        cCampo := "F13_CODISS"
    Case cGrid == "TRANSPCOM"
        cCampo := "F13_CFOP"
    Case cGrid == "LOCACAO"
        cCampo := "F13_GRUPO"

EndCase

nLinha := oModelGrid:nLine

For nX := 1 to oModelGrid:Length()

    oModelGrid:GoLine(nX)

    If !oModelGrid:IsDeleted()

        // Se encontrou outra linha com a mesma chave...
        If oModelGrid:GetValue(cCampo, nX) == oModelGrid:GetValue(cCampo, nLinha)
            
            If oModelGrid:GetValue("F13_INIVIG", nX) < oModelGrid:GetValue("F13_INIVIG", nLinha)
                If Empty(oModelGrid:GetValue("F13_FIMVIG", nX)) .Or. (oModelGrid:GetValue("F13_FIMVIG", nX) > oModelGrid:GetValue("F13_INIVIG", nLinha))
                    Help( ,, 'Help',, "Já existe um registro vigente no período informado." , 1, 0 ) //"Código de Sub Atividade já cadastrado na atividade
                    lRet := .F.
                    oModelGrid:GoLine(nLinha)
                    Exit
                EndIf
            ElseIf oModelGrid:GetValue("F13_INIVIG", nX) > oModelGrid:GetValue("F13_INIVIG", nLinha)
               If oModelGrid:GetValue("F13_FIMVIG", nLinha) >= oModelGrid:GetValue("F13_INIVIG", nX)
                    Help( ,, 'Help',, "Já existe um registro vigente no período informado." , 1, 0 ) //"Código de Sub Atividade já cadastrado na atividade
                    lRet := .F.
                    oModelGrid:GoLine(nLinha)
                    Exit
                EndIf  
            EndIf

        EndIF

    EndIf

Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldAnxSub

Função para validar se o anexo substituto foi informado quando o serviço
for sujeito ao fator R.

@author joao.pellegrini
@since 24/07/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function VldAnxSub(oModelo)

Local lRet      := .F.
Local nX        := 0

//Percorre as linhas do grid
For nX := 1 to oModelo:Length()
    oModelo:GoLine( nX )
    If  !oModelo:IsDeleted() .And. !Empty(oModelo:GetValue("F13_CODISS",nX)) .And. AllTrim(oModelo:GetValue("F13_FATORR",nX)) == "1" .And. Empty(oModelo:GetValue("F13_ASUB",nX))
        lRet:= .T.
        Exit
    EndIF
Next(nX)

Return lRet