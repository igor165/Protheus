#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CTBS440C.CH"

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef

Definição do modelo de dados do mvc CTBS440A

@params:
	
@return: 
	oModel:	Objeto. Instância da classe FwFormModel()

@sample:
	
@author Fernando Radu Muscalu

@since 06/02/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oStruCab  := FwFormModelStruct():New()
Local oStruLog  := FwFormModelStruct():New()

Local oModel

Local bLoad     := {|oSub| CS440CLoad(oSub) }

SetStruct(oStruCab,oStruLog)

oModel := MPFormModel():New("CTBS440C")

oModel:AddFields("MASTER",/*cOwner */,oStruCab,,,bLoad)

oModel:AddGrid("DETAIL", "MASTER", oStruLog,,,,,bLoad)

oModel:GetModel("MASTER"):SetOnlyQuery(.t.)
oModel:GetModel("DETAIL"):SetOnlyQuery(.t.)

oModel:GetModel("DETAIL"):SetNoDeleteLine(.T.)

oModel:SetDescription(STR0001) //"Log com erro de carga de saldos"
oModel:GetModel("MASTER"):SetDescription(STR0002) //"Problema na execucao do multiprocessamento."
oModel:GetModel("DETAIL"):SetDescription(STR0003) //"As contas aglutinadoras abaixo, nao foram importadas: "

oModel:SetPrimaryKey({})

Return(oModel)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample		ViewDef()
 
@return		oView:  Objeto. Instânca da Classe FwFormView

@author	    Fernando Radu Muscalu
@since		19/03/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel    := FWLoadModel("CTBS440C")
Local oView
Local oStruCab  := FwFormViewStruct():New()
Local oStruLog  := FwFormViewStruct():New()

SetStruct(oStruCab,oStruLog,"V")

oView := FWFormView():New()
	
oView:SetModel(oModel)

oView:AddField("VW_MASTER", oStruCab,   "MASTER")
oView:AddGrid("VW_DETAIL",  oStruLog,   "DETAIL")

oView:CreateHorizontalBox('HEAD',20)
oView:CreateHorizontalBox('BODY',80)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0004) //"Log de erro da carga de saldo contábil das contas aglutinadoras"

oView:SetOwnerView("VW_MASTER","HEAD")
oView:SetOwnerView("VW_DETAIL","BODY")

oView:EnableTitleView("VW_MASTER",STR0005) //"Problema na execucao do multiprocessamento"
oView:EnableTitleView("VW_DETAIL",STR0003) //"As contas aglutinadoras abaixo, nao foram importadas: "

oView:GetViewObj("DETAIL")[3]:SetFilter(.t.)
oView:AddUserButton("Imprimir Log", 'PRINT', {|oView| GS44CPrint(oView) } )

Return(oView)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} SetStruct

Função que efetua a definição das estruturas dos submodelos do cabeçalho e do grid

@params:
    oStruCab:   Objeto. Instância da classe FwFormModelStruct ou FwFormViewStruct (cabeçalho)
    oStruLog:   Objeto. Instância da classe FwFormModelStruct ou FwFormViewStruct (itens ou log)
    cStrType:   Caractere. Tipo de estrutura - "M" Modelo; "V" View
@return: 
	oModel:	Objeto. Instância da classe FwFormModel()

@sample:
	
@author Fernando Radu Muscalu

@since 18/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function SetStruct(oStruCab,oStruLog,cStrType)

Local nI        := 0

Local aStruFld  := {}
Local aDescFld  := {}

Local oTable    

Default cStrType := "M"

oTable := CS440GetLog()

If oTable == nil //Tratamento de instanciamento de modelo para testes de framework
    oTable := CS440TabLog()
Endif

aStruFld   := aClone(oTable:GetStruct():GetFields())

If ( Upper(cStrType) == "M" )   //Tipo de Estrutura Model
    
    oStruCab:AddTable("",{""},"")

    oStruCab:AddField(	STR0006,;		            // 	[01]  C   Titulo do campo   //"Id. Bloco K"
                        STR0007,;		            // 	[02]  C   ToolTip do campo  //"Identificador do Bloco K"
                        "IDBLK",;    	            // 	[03]  C   Id do Field
                        "C",;			            // 	[04]  C   Tipo do campo
                        TamSx3("CQU_IDBLK")[1],;				            // 	[05]  N   Tamanho do campo
                        0,;				            // 	[06]  N   Decimal do campo
                        Nil,;			            // 	[07]  B   Code-block de validação do campo
                        Nil,;			            // 	[08]  B   Code-block de validação When do campo
                        Nil,;			            //	[09]  A   Lista de valores permitido do campo
                        .F.,;			            //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        Nil,;			            //	[11]  B   Code-block de inicializacao do campo
                        .F.,;			            //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;			            //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)			            // 	[14]  L   Indica se o campo é virtual

    For nI := 1 to Len(aStruFld)
        
        aDescFld := GetTitleField(aStruFld[nI,1]) 

        oStruLog:AddField(  aDescFld[2],;       // Título do Campo
                            aDescFld[3],;       // Tooltip da descrição do campo
                            aStruFld[nI,1],;    // Nome do Campo
                            aStruFld[nI,2],;    // Tipo do Campo
                            aStruFld[nI,3],;    // Tamanho do Campo
                            aStruFld[nI,4],;    // Decimal do Campo
                            {|| .T.},;          // Bloco de validação do campo (Valid)
                            {||	.T.},;          // Bloco de edição do campo (When)
                            Nil,;               // Lista de valores, caso seja um combobox
                            Nil,;               // Se o campo é obrigatório
                            Nil,;               // Inicializador padrão do campo
                            Nil,;               // O campo compõe uma chave única?
                            .F.,;               // Não atualiza o conteúdo?
                            .T. )               // O campo é virtual?

    Next nI

Else

    oStruCab:AddField(	"IDBLK",;			// [01]  C   Nome do Campo
                        "01",;						// [02]  C   Ordem
                        STR0006,;				// [03]  C   Titulo do campo //"Id. Bloco K"
                        STR0007,;				// [04]  C   Descricao do campo //"Identificador do Bloco K"
                        {STR0007},;				// [05]  A   Array com Help // "Selecionar" //"Identificador do Bloco K"
                        "GET",;					    // [06]  C   Tipo do campo
                        "@!",;						// [07]  C   Picture
                        NIL,;						// [08]  B   Bloco de Picture Var
                        "",;						// [09]  C   Consulta F3
                        .T.,;						// [10]  L   Indica se o campo é alteravel
                        NIL,;						// [11]  C   Pasta do campo
                        "",;						// [12]  C   Agrupamento do campo
                        Nil,;		                // [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;						// [15]  C   Inicializador de Browse
                        .T.,;						// [16]  L   Indica se o campo é virtual
                        NIL,;						// [17]  C   Picture Variavel
                        .F.)						// [18]  L   Indica pulo de linha após o campo

    For nI := 1 to Len(aStruFld)

        aDescFld := GetTitleField(aStruFld[nI,1]) 

        oStruLog:AddField(	aStruFld[nI,1],;			// [01]  C   Nome do Campo
                            StrZero(nI,2),;			// [02]  C   Ordem
                            aDescFld[2],;				// [03]  C   Titulo do campo
                            aDescFld[3],;				// [04]  C   Descricao do campo
                            {aDescFld[3]},;				// [05]  A   Array com Help // "Selecionar"
                            "GET",;					    // [06]  C   Tipo do campo
                            "@!",;						// [07]  C   Picture
                            NIL,;						// [08]  B   Bloco de Picture Var
                            "",;						// [09]  C   Consulta F3
                            .T.,;						// [10]  L   Indica se o campo é alteravel
                            NIL,;						// [11]  C   Pasta do campo
                            "",;						// [12]  C   Agrupamento do campo
                            Nil,;		                // [13]  A   Lista de valores permitido do campo (Combo)
                            NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
                            NIL,;						// [15]  C   Inicializador de Browse
                            .T.,;						// [16]  L   Indica se o campo é virtual
                            NIL,;						// [17]  C   Picture Variavel
                            .F.)						// [18]  L   Indica pulo de linha após o campo
    
    Next nI

EndIf

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GetTitleField

Função que efetua a definição das estruturas dos submodelos do cabeçalho e do grid

@params:
    oStruCab:   Objeto. Instância da classe FwFormModelStruct ou FwFormViewStruct (cabeçalho)
    oStruLog:   Objeto. Instância da classe FwFormModelStruct ou FwFormViewStruct (itens ou log)
    cStrType:   Caractere. Tipo de estrutura - "M" Modelo; "V" View
@return: 
	oModel:	Objeto. Instância da classe FwFormModel()

@sample:
	
@author Fernando Radu Muscalu

@since 18/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GetTitleField(cIdField,cTipoRet)

Local aTitles       := {}

Local nP            := 0

Default cTipoRet    := "" //"T" - Título; "D - Descrição completa (moldes tooltip); "''" - Ambos (Título + Descrição)

aAdd(aTitles,{"CONTA_AGL",STR0009,STR0008}) //"Conta Aglutinadora" //"Conta Aglutin."
aAdd(aTitles,{"MSG_ERRO",STR0011,STR0010}) //"Mensagem do erro" //"Mensagem Erro"

nP := aScan(aTitles,{|x| Upper(Alltrim(x[1])) == Upper(Alltrim(cIdField)) })

If ( nP > 0 )

    If ( cTipoRet == "T" )
        xRet := aTitles[nP,2]
    ElseIf ( cTipoRet == "D" )
        xRet := aTitles[nP,3]
    Else
        xRet := aClone(aTitles[nP])
    EndIf
            
EndIf

Return(xRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GS44CPrint()
                                   
Executa a impressão do Grid de Log.

@example 	GS44CPrint(oView)

@param		oView	Objeto. Instância da Classe FwFormView

@return     Nil

@author     Fernando Radu Muscalu
@since      19/03/2019
@version    12                
/*/
//------------------------------------------------------------------------------
Static Function GS44CPrint(oView)

Local oModel    := oView:GetModel()
Local oReport   := oModel:ReportDef()

oReport:PrintDialog()   

oView:Refresh("VW_DETAIL")

Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} CS440CLoad()
                                   
Executa a impressão do Grid de Log.

@example 	GS44CPrint(oView)

@param		oView	Objeto. Instância da Classe FwFormView

@return     Nil

@author     Fernando Radu Muscalu
@since      19/03/2019
@version    12                
/*/
//------------------------------------------------------------------------------
Static Function CS440CLoad(oSubModel) 

Local oTable

Local aReg  := {}

If ( oSubModel:GetId() == "DETAIL" )

    oTable := CS440GetLog()

    If ( ValType(oTable) == "O" )
        aReg := FWLoadByAlias(oSubModel,oTable:GetAlias(),oTable:GetRealName())
    EndIf

Else    //MASTER
    aReg := {{CQU->CQU_IDBLK},0}  
EndIf

Return(aReg)