#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'
#include 'FWMVCDEF.CH'
#include 'TOTVS.CH'
#include 'GTPA700N.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700N()
Depósitos de Terceiros
@sample	GTPA700N()
@return	
@author	SIGAGTP | Flavio Martins
@since		10/02/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA700N(nOperation)
Local oMdl700B := FwLoadModel('GTPA700B')

If FwIsInCallStack("G700LoadMov")

	oMdl700B:SetOperation(MODEL_OPERATION_UPDATE)
	oMdl700B:Activate()
	oMdl700B:CommitData()
	oMdl700B:Destroy()
	
Else
	FwExecView(STR0001, 'VIEWDEF.GTPA700N', nOperation, , { || .T. } )  // "Depósitos de Terceiros"
Endif

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição do objeto oView
@sample	
@return	oView
@author	SIGAGTP | Flavio Martins
@since		10/02/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oStruCab	    := FWFormViewStruct():New()
Local oStruGrd	    := FWFormViewStruct():New()
Local oModel		:= FWLoadModel("GTPA700B")
Local oStruG6Y      := FWFormStruct(2,"G6Y")
Local oStruTot1     := FWCalcStruct( oModel:GetModel('700TOTAL1') )
Local oStruTot2     := FWCalcStruct( oModel:GetModel('700TOTAL2') )

	SetStruct(oStruCab,oStruGrd,oStruG6Y,"V")
	
    oView := FWFormView():New()

	oView:SetModel(oModel)	
	    
	oView:AddField("VIEW_CAB",oStruCab,"CABESC")
	oView:AddGrid("V_FICHA"  ,oStruGrd,"GRID1")
	oView:AddGrid("V_LANCAM" ,oStruG6Y,"GRID2")
	oView:AddField("V_TOTAL1" ,oStruTot1,'700TOTAL1')
	oView:AddField("V_TOTAL2" ,oStruTot2,'700TOTAL2')

	oView:CreateHorizontalBox("CABECALHO" , 15) // Cabeçalho
	oView:CreateHorizontalBox("FCHDEREME" , 15) // Ficha de Remessa
	oView:CreateHorizontalBox("LANCAMENT" , 55) // Lançamentos Diários
	oView:CreateHorizontalBox("TOTALIZA"  , 15) // Totalizadores

	oView:CreateVerticalBox("TOTAL1",50,"TOTALIZA")
	oView:CreateVerticalBox("TOTAL2",50,"TOTALIZA")
	
	oView:EnableTitleView("V_LANCAM", STR0002)  // "Depósitos"
	oView:EnableTitleView("V_TOTAL1", STR0003)  // "Total Ficha de Remessa"
	oView:EnableTitleView("V_TOTAL2", STR0004)  // "Total Depósitos"
	
	oView:SetOwnerView( "VIEW_CAB", "CABECALHO")
	oView:SetOwnerView( "V_FICHA", "FCHDEREME")
	oView:SetOwnerView( "V_LANCAM", "LANCAMENT")
	oView:SetOwnerView( "V_TOTAL1", "TOTAL1")
	oView:SetOwnerView( "V_TOTAL2", "TOTAL2")
	
	oView:AddIncrementalField('V_LANCAM','G6Y_ITEM')
	
	oView:SetNoDeleteLine('V_FICHA')
	oView:SetAfterViewActivate({|oView| oView:lModify := .T.,oView:GetModel():lModify := .T.})
	
	
Return(oView)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetStruct(oStruCab,oStruGrd,cTipo)
Define as estruturas da Tela em MVC - Model e View
@return	
@author	SIGAGTP | Flavio Martins
@since		10/02/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function SetStruct(oStruCab,oStruGrd,oStruG6Y,cTipo)
Local cFieldsIn := ""
Local aFldStr   := {}
Local aOrdem    := {}
Local nI        := 0

If ValType( oStruCab ) == "O"

    oStruCab:AddField(	"FILIAL",;				// [01]  C   Nome do Campo
                        "01",;						// [02]  C   Ordem
                        STR0005,;						// [03]  C   Titulo do campo // "Filial"
                        STR0005,;						// [04]  C   Descricao do campo // "Filial"
                        {STR0005},;					// [05]  A   Array com Help // "Selecionar" // "Filial"
                        "GET",;					// [06]  C   Tipo do campo
                        "",;						// [07]  C   Picture
                        NIL,;						// [08]  B   Bloco de Picture Var
                        "",;						// [09]  C   Consulta F3
                        .F.,;						// [10]  L   Indica se o campo é alteravel
                        NIL,;						// [11]  C   Pasta do campo
                        "",;						// [12]  C   Agrupamento do campo
                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;						// [15]  C   Inicializador de Browse
                        .T.,;						// [16]  L   Indica se o campo é virtual
                        NIL,;						// [17]  C   Picture Variavel
                        .F.)						// [18]  L   Indica pulo de linha após o campo
    
    oStruCab:AddField(	"CAIXA",;				// [01]  C   Nome do Campo
                        "02",;						// [02]  C   Ordem
                        STR0006,;						// [03]  C   Titulo do campo // "Caixa"
                        STR0006,;						// [04]  C   Descricao do campo // "Caixa"
                        {STR0006},;					// [05]  A   Array com Help // "Selecionar" // "Caixa"
                        "GET",;					// [06]  C   Tipo do campo
                        "",;						// [07]  C   Picture
                        NIL,;						// [08]  B   Bloco de Picture Var
                        "",;						// [09]  C   Consulta F3
                        .F.,;						// [10]  L   Indica se o campo é alteravel
                        NIL,;						// [11]  C   Pasta do campo
                        "",;						// [12]  C   Agrupamento do campo
                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;						// [15]  C   Inicializador de Browse
                        .T.,;						// [16]  L   Indica se o campo é virtual
                        NIL,;						// [17]  C   Picture Variavel
                        .F.)						// [18]  L   Indica pulo de linha após o campo

    oStruCab:AddField(	"AGENCIA",;				// [01]  C   Nome do Campo
                        "03",;						// [02]  C   Ordem
                        STR0007,;						// [03]  C   Titulo do campo // "Agência"
                        STR0008,;						// [04]  C   Descricao do campo // "Código da Agência"
                        {STR0008},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência"
                        "GET",;					// [06]  C   Tipo do campo
                        "",;						// [07]  C   Picture
                        NIL,;						// [08]  B   Bloco de Picture Var
                        "",;						// [09]  C   Consulta F3
                        .F.,;						// [10]  L   Indica se o campo é alteravel
                        NIL,;						// [11]  C   Pasta do campo
                        "",;						// [12]  C   Agrupamento do campo
                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;						// [15]  C   Inicializador de Browse
                        .T.,;						// [16]  L   Indica se o campo é virtual
                        NIL,;						// [17]  C   Picture Variavel
                        .F.)						// [18]  L   Indica pulo de linha após o campo
            
    oStruCab:AddField(	"DESCRIAGEN",;				// [01]  C   Nome do Campo
                        "04",;						// [02]  C   Ordem
                        STR0009,;						// [03]  C   Titulo do campo // "Descrição"
                        STR0010,;						// [04]  C   Descricao do campo // "Descrição da Agência"
                        {STR0010},;					// [05]  A   Array com Help // "Selecionar" // "Descrição da Agência"
                        "GET",;					// [06]  C   Tipo do campo
                        "",;						// [07]  C   Picture
                        NIL,;						// [08]  B   Bloco de Picture Var
                        "",;						// [09]  C   Consulta F3
                        .F.,;						// [10]  L   Indica se o campo é alteravel
                        NIL,;						// [11]  C   Pasta do campo
                        "",;						// [12]  C   Agrupamento do campo
                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;						// [15]  C   Inicializador de Browse
                        .T.,;						// [16]  L   Indica se o campo é virtual
                        NIL,;						// [17]  C   Picture Variavel
                        .F.)						// [18]  L   Indica pulo de linha após o campo
                        
    cFieldsIn := "CAIXA|AGENCIA|DESCRIAGEN"
    
    aFldStr := aClone(oStruCab:GetFields())
    
    For nI := 1 to Len(aFldStr)
    
        If ( !(aFldStr[nI,1] $ cFieldsIn) )
            oStruCab:RemoveField(aFldStr[nI,1])
        EndIf
    
    Next nI
                        
EndIf

If ValType( oStruGrd ) == "O"
    
    oStruGrd:AddField(	"FILIAL",;				// [01]  C   Nome do Campo
                    "01",;						// [02]  C   Ordem
                    STR0007,;						// [03]  C   Titulo do campo // "Filial"
                    STR0007,;						// [04]  C   Descricao do campo // "Filial"
                    {STR0007},;					// [05]  A   Array com Help // "Selecionar" // "Filial"
                    "GET",;					// [06]  C   Tipo do campo
                    "",;						// [07]  C   Picture
                    NIL,;						// [08]  B   Bloco de Picture Var
                    "",;						// [09]  C   Consulta F3
                    .F.,;						// [10]  L   Indica se o campo é alteravel
                    NIL,;						// [11]  C   Pasta do campo
                    "",;						// [12]  C   Agrupamento do campo
                    NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                    NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                    NIL,;						// [15]  C   Inicializador de Browse
                    .T.,;						// [16]  L   Indica se o campo é virtual
                    NIL,;						// [17]  C   Picture Variavel
                    .F.)						// [18]  L   Indica pulo de linha após o campo
    
    oStruGrd:AddField(	"CODCX",;				// [01]  C   Nome do Campo
                    "02",;						// [02]  C   Ordem
                    STR0005,;						// [03]  C   Titulo do campo // "Caixa"
                    STR0005,;						// [04]  C   Descricao do campo  // "Caixa" 
                    {STR0005},;					// [05]  A   Array com Help // "Selecionar"  // "Caixa"
                    "GET",;					// [06]  C   Tipo do campo
                    "",;						// [07]  C   Picture
                    NIL,;						// [08]  B   Bloco de Picture Var
                    "",;						// [09]  C   Consulta F3
                    .F.,;						// [10]  L   Indica se o campo é alteravel
                    NIL,;						// [11]  C   Pasta do campo
                    "",;						// [12]  C   Agrupamento do campo
                    NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                    NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                    NIL,;						// [15]  C   Inicializador de Browse
                    .T.,;						// [16]  L   Indica se o campo é virtual
                    NIL,;						// [17]  C   Picture Variavel
                    .F.)						// [18]  L   Indica pulo de linha após o campo
                    
    oStruGrd:AddField(	"CODAGE",;				// [01]  C   Nome do Campo
                    "03",;						// [02]  C   Ordem
                    STR0007,;						// [03]  C   Titulo do campo // "Agencia"
                    STR0008,;						// [04]  C   Descricao do campo // "Código da Agencia"
                    {STR0008},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agencia"
                    "GET",;					// [06]  C   Tipo do campo
                    "",;						// [07]  C   Picture
                    NIL,;						// [08]  B   Bloco de Picture Var
                    "",;						// [09]  C   Consulta F3
                    .F.,;						// [10]  L   Indica se o campo é alteravel
                    NIL,;						// [11]  C   Pasta do campo
                    "",;						// [12]  C   Agrupamento do campo
                    NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                    NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                    NIL,;						// [15]  C   Inicializador de Browse
                    .T.,;						// [16]  L   Indica se o campo é virtual
                    NIL,;						// [17]  C   Picture Variavel
                    .F.)						// [18]  L   Indica pulo de linha após o campo         

                    
    oStruGrd:AddField(	"FICHA",;				// [01]  C   Nome do Campo
                    "04",;						// [02]  C   Ordem
                    STR0011,;						// [03]  C   Titulo do campo // "Ficha de Remessa"
                    STR0011,;						// [04]  C   Descricao do campo // "Ficha de Remessa"
                    {STR0011},;					// [05]  A   Array com Help // "Selecionar" // "Ficha de Remessa"
                    "GET",;					// [06]  C   Tipo do campo
                    "",;						// [07]  C   Picture
                    NIL,;						// [08]  B   Bloco de Picture Var
                    "",;						// [09]  C   Consulta F3
                    .F.,;						// [10]  L   Indica se o campo é alteravel
                    NIL,;						// [11]  C   Pasta do campo
                    "",;						// [12]  C   Agrupamento do campo
                    NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                    NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                    NIL,;						// [15]  C   Inicializador de Browse
                    .T.,;						// [16]  L   Indica se o campo é virtual
                    NIL,;						// [17]  C   Picture Variavel
                    .F.)						// [18]  L   Indica pulo de linha após o campo
                    
    oStruGrd:AddField(	"DTINI",;				// [01]  C   Nome do Campo
                    "05",;						// [02]  C   Ordem
                    STR0012,;						// [03]  C   Titulo do campo // "Data Incial"
                    STR0012,;						// [04]  C   Descricao do campo  // "Data Incial"
                    {STR0012},;					// [05]  A   Array com Help // "Selecionar"  // "Data Incial"
                    "GET",;					// [06]  C   Tipo do campo
                    "",;						// [07]  C   Picture
                    NIL,;						// [08]  B   Bloco de Picture Var
                    "",;						// [09]  C   Consulta F3
                    .F.,;						// [10]  L   Indica se o campo é alteravel
                    NIL,;						// [11]  C   Pasta do campo
                    "",;						// [12]  C   Agrupamento do campo
                    NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                    NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                    NIL,;						// [15]  C   Inicializador de Browse
                    .T.,;						// [16]  L   Indica se o campo é virtual
                    NIL,;						// [17]  C   Picture Variavel
                    .F.)						// [18]  L   Indica pulo de linha após o campo	
    
    oStruGrd:AddField(	"DTFIN",;				// [01]  C   Nome do Campo
                    "06",;						// [02]  C   Ordem
                    STR0013,;						// [03]  C   Titulo do campo // "Data Final"
                    STR0013,;						// [04]  C   Descricao do campo // "Data Final"
                    {STR0013},;					// [05]  A   Array com Help // "Selecionar" // "Data Final"
                    "GET",;					// [06]  C   Tipo do campo
                    "",;						// [07]  C   Picture
                    NIL,;						// [08]  B   Bloco de Picture Var
                    "",;						// [09]  C   Consulta F3
                    .F.,;						// [10]  L   Indica se o campo é alteravel
                    NIL,;						// [11]  C   Pasta do campo
                    "",;						// [12]  C   Agrupamento do campo
                    NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                    NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                    NIL,;						// [15]  C   Inicializador de Browse
                    .T.,;						// [16]  L   Indica se o campo é virtual
                    NIL,;						// [17]  C   Picture Variavel
                    .F.)						// [18]  L   Indica pulo de linha após o campo	

    If G6X->(FieldPos('G6X_TITPRO')) > 0 .And. G6X->(FieldPos('G6X_DEPOSI')) > 0	

        oStruGrd:AddField("TITPRO",;				// [01]  C   Nome do Campo
                        "07",;						// [02]  C   Ordem
                        STR0014,;					// [03]  C   Titulo do campo // "Titulo Prov"
                        STR0014,;					// [04]  C   Descricao do campo // "Titulo Prov"
                        {STR0014},;					// [05]  A   Array com Help // "Selecionar" // "Titulo Prov"
                        "GET",;						// [06]  C   Tipo do campo
                        "",;						// [07]  C   Picture
                        NIL,;						// [08]  B   Bloco de Picture Var
                        "",;						// [09]  C   Consulta F3
                        .F.,;						// [10]  L   Indica se o campo é alteravel
                        NIL,;						// [11]  C   Pasta do campo
                        "",;						// [12]  C   Agrupamento do campo
                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;						// [15]  C   Inicializador de Browse
                        .T.,;						// [16]  L   Indica se o campo é virtual
                        NIL,;						// [17]  C   Picture Variavel
                        .F.)						// [18]  L   Indica pulo de linha após o campo

        oStruGrd:AddField("DEPOSI",;				// [01]  C   Nome do Campo
                        "08",;						// [02]  C   Ordem
                        STR0015,;					// [03]  C   Titulo do campo // "Tipo Pagto."
                        STR0015,;					// [04]  C   Descricao do campo // "Tipo Pagto."
                        {STR0015},;					// [05]  A   Array com Help // "Selecionar" // "Tipo Pagto."
                        "GET",;						// [06]  C   Tipo do campo
                        "",;						// [07]  C   Picture
                        NIL,;						// [08]  B   Bloco de Picture Var
                        "",;						// [09]  C   Consulta F3
                        .F.,;						// [10]  L   Indica se o campo é alteravel
                        NIL,;						// [11]  C   Pasta do campo
                        "",;						// [12]  C   Agrupamento do campo
                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;						// [15]  C   Inicializador de Browse
                        .T.,;						// [16]  L   Indica se o campo é virtual
                        NIL,;						// [17]  C   Picture Variavel
                        .F.)						// [18]  L   Indica pulo de linha após o campo

    Endif								 

    cFieldsIn := "FICHA|DTINI|DTFIN|"


    aFldStr := aClone(oStruGrd:GetFields())

    For nI := 1 to Len(aFldStr)

        If ( !(aFldStr[nI,1] $ cFieldsIn) )
            oStruGrd:RemoveField(aFldStr[nI,1])
        EndIf

    Next nI
        
EndIf

If ValType( oStruG6Y ) == "O"
        
    //Ajusta quais os campos que deverão aparecer na tela - Grid GYPDETAIL

    cFieldsIn := "G6Y_ITEM|G6Y_IDDEPO|G6Y_BANCO|G6Y_AGEBCO|"
    cFieldsIn += "G6Y_CTABCO|G6Y_VALOR|LEGENDA|"
    cFieldsIn += "G6Y_STSDEP|G6Y_FORPGT|G6Y_NUMFCH,G6Y_CHVTIT"

    aFldStr := aClone(oStruG6Y:GetFields())
    
    For nI := 1 to Len(aFldStr)
    
        If ( !(aFldStr[nI,1] $ cFieldsIn) )
            oStruG6Y:RemoveField(aFldStr[nI,1])
        EndIf
        
        If ( (aFldStr[nI,1] $ cFieldsIn) )
            oStruG6Y:SetProperty(aFldStr[nI,1], MVC_VIEW_CANCHANGE,  .T. )  
        EndIf
    
    Next nI
    
    AAdd(aOrdem,{"LEGENDA","G6Y_ITEM"})
    AAdd(aOrdem,{"G6Y_ITEM","G6Y_NUMFCH"})
    AAdd(aOrdem,{"G6Y_NUMFCH","G6Y_FORPGT"})
    AAdd(aOrdem,{"G6Y_FORPGT","G6Y_BANCO"})
    AAdd(aOrdem,{"G6Y_BANCO","G6Y_AGEBCO"})
    AAdd(aOrdem,{"G6Y_AGEBCO","G6Y_CTABCO"})
    AAdd(aOrdem,{"G6Y_CTABCO","G6Y_IDDEPO"})
    AAdd(aOrdem,{"G6Y_IDDEPO","G6Y_DATA"})
    AAdd(aOrdem,{"G6Y_DATA","G6Y_VALOR"})
    AAdd(aOrdem,{"G6Y_VALOR","G6Y_STSDEP"})
    AAdd(aOrdem,{"G6Y_STSDEP","G6Y_CARGA"})
    AAdd(aOrdem,{"G6Y_CARGA","G6Y_CHVTIT"})

    GTPOrdVwStruct(oStruG6Y,aOrdem)
    
EndIf
	
Return
