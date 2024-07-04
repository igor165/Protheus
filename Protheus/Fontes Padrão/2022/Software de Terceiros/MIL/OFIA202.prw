#Include "TOTVS.ch"
#Include "FWMVCDef.ch"
#Include "OFIA202.ch"

/*/
{Protheus.doc} OFIA202
Rotina que realiza o cadastro do DEF (DFS D-In) gerencial referencial da AGCO com informações de máquinas.
@type   Function
@author Otávio Favarelli
@since  15/11/2019
@param  nil
@return nil
/*/
Function OFIA202()
    
    Local aArea
    Local oBrowse
    Local cPergSX1

	//
	// Validacao de Licencas DMS
	//
	If !OFValLicenca():ValidaLicencaDMS()
		Return
	EndIf

    aArea       := GetArea()
    cPergSX1    := "OFIA202"
     
    //Instanciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela
    oBrowse:SetAlias("VFF")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(STR0001)	// Cadastro DFS Gerencial Referencial AGCO - Máquina
    
    oBrowse:SetFilterDefault("VFF_TIPREG == '2'")
    oBrowse:SetOnlyFields({"VFF_CODCAB","VFF_DESCAB","VFF_CODGRF","VFF_DESGRF"})

    SetKey(VK_F12,{ ||Pergunte( cPergSX1, .T. ,,,,.f.)  })

    //Ativa a Browse
    oBrowse:Activate()
    
    SetKey(VK_F12, NIL)

    RestArea(aArea)

Return Nil
 
/*/
{Protheus.doc} MenuDef
Função padrão do MVC responsável pela definição das opções de menu do Browse do fonte OFIA202 que estarão disponíveis ao usuário.
@type   Static Function
@author Otávio Favarelli
@since  15/11/2019
@param  nil
@return aRot,   Matriz, Matriz que contém as opções de menu a serem utilizadas pelo usuário.
/*/
Static Function MenuDef()
    
    Local aRot
    
    aRot := {}
    aRot := FWMVCMenu("OFIA202")
 
Return aRot
 
/*/
{Protheus.doc} ModelDef
Função padrão do MVC responsável pela criação do modelo de dados (regras de negócio) para a rotina OFIA202.
@type   Static Function
@author Otávio Favarelli
@since  15/11/2019
@param  nil
@return oModel, Objeto, Objeto que contém o modeldef.
/*/
Static Function ModelDef()
    Local oModel
    Local oStPaiVFF
    Local oStFilhoVFG
    Local aVFGRel
    Local aTriggerPaiVFF
    Local aTriggerFilhoVFG
    Local nCntForA, nCntForB

    oModel              := Nil
    oStPaiVFF           := FWFormStruct(1, "VFF")
    oStFilhoVFG         := FWFormStruct(1, "VFG")
    aVFGRel             := {}
    aTriggerPaiVFF      := OA2020017_CreateTrigger("VFF")
    aTriggerFilhoVFG    := OA2020017_CreateTrigger("VFG")
    
    //Alterando propriedades de campos
    oStPaiVFF:SetProperty("VFF_TIPREG"  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "2")) // Inicializador Padrão - 2=Máquina
    oStFilhoVFG:SetProperty("VFG_TIPREG", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "2")) // Inicializador Padrão - 2=Máquina

    For nCntForA := 1 to Len(aTriggerPaiVFF)
        oStPaiVFF:AddTrigger(;
                            aTriggerPaiVFF[nCntForA,1],;   // [01] Id do campo de origem
                            aTriggerPaiVFF[nCntForA,2],;   // [02] Id do campo de destino
                            aTriggerPaiVFF[nCntForA,3],;   // [03] Bloco de codigo de validação da execução do gatilho
                            aTriggerPaiVFF[nCntForA,4])    // [04] Bloco de codigo de execução do gatilho
    Next

    For nCntForB := 1 to Len(aTriggerFilhoVFG)
        oStFilhoVFG:AddTrigger(;
                            aTriggerFilhoVFG[nCntForB,1],;   // [01] Id do campo de origem
                            aTriggerFilhoVFG[nCntForB,2],;   // [02] Id do campo de destino
                            aTriggerFilhoVFG[nCntForB,3],;   // [03] Bloco de codigo de validação da execução do gatilho
                            aTriggerFilhoVFG[nCntForB,4])    // [04] Bloco de codigo de execução do gatilho
    Next

    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New("OFIA202M")
    oModel:AddFields("VFFMASTER",/*cOwner*/,oStPaiVFF)
    oModel:AddGrid("VFGDETAIL","VFFMASTER",oStFilhoVFG,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
     
    //Fazendo o relacionamento entre o Pai e Filho
    aAdd(aVFGRel, {"VFG_FILIAL","VFF_FILIAL"} )
    aAdd(aVFGRel, {"VFG_CODCAB","VFF_CODCAB"} )
    aAdd(aVFGRel, {"VFG_TIPREG","VFF_TIPREG"} )
    oModel:SetRelation("VFGDETAIL", aVFGRel, VFG->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
    oModel:GetModel("VFGDETAIL"):SetUniqueLine({"VFG_CODCAB","VFG_TIPREG","VFG_CODSEQ"})    //Não repetir informações ou combinações
    oModel:SetPrimaryKey({})
     
    //Setando as descrições
    oModel:SetDescription(STR0001)	// Cadastro DFS Gerencial Referencial AGCO - Máquina
    oModel:GetModel("VFFMASTER"):SetDescription(STR0002)	// Cabeçalho Gerencial DFS AGCO
    oModel:GetModel("VFGDETAIL"):SetDescription(STR0003)	// Itens Gerencial DFS AGCO

Return oModel
 
/*/
{Protheus.doc} ViewDef
Função padrão do MVC responsável pela criação da visão de dados (interação do usuário) para a rotina OFIA202.
@type   Static Function
@author Otávio Favarelli
@since  15/11/2019
@param  nil
@return oView, Objeto, Objeto que contém o viewdef.
/*/
Static Function ViewDef()
    Local oView
    Local oModel
    Local oStPaiVFF
    Local oStFilhoVFG

    oView       := Nil
    oModel      := FWLoadModel("OFIA202")
    oStPaiVFF   := FWFormStruct(2, "VFF")
    oStFilhoVFG := FWFormStruct(2, "VFG")
    
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_VFF'   ,oStPaiVFF  ,'VFFMASTER')
    oView:AddGrid('VIEW_VFG'    ,oStFilhoVFG,'VFGDETAIL')
     
    //Setando o dimensionamento de tamanho das box
    oView:CreateHorizontalBox('CABEC',20)
    oView:CreateHorizontalBox('GRID',80)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_VFF','CABEC')
    oView:SetOwnerView('VIEW_VFG','GRID')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_VFF',STR0002)	// Cabeçalho Gerencial DFS AGCO
    oView:EnableTitleView('VIEW_VFG',STR0003)	// Itens Gerencial DFS AGCO
    
    //Incremento
    oView:AddIncrementField("VIEW_VFG", "VFG_CODSEQ")

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //Remove os campos da View
    oStPaiVFF:RemoveField("VFF_TIPREG")
    oStPaiVFF:RemoveField("VFF_CODDRF")
    oStPaiVFF:RemoveField("VFF_DESDRF")
    oStFilhoVFG:RemoveField("VFG_CODCAB")
    oStFilhoVFG:RemoveField("VFG_DESCAB")
    oStFilhoVFG:RemoveField("VFG_TIPREG")
    oStFilhoVFG:RemoveField("VFG_CC")
    oStFilhoVFG:RemoveField("VFG_DESCC")
    oStFilhoVFG:RemoveField("VFG_CODTEC")
    oStFilhoVFG:RemoveField("VFG_NOMTEC")
    oStFilhoVFG:RemoveField("VFG_FILTEC")
    oStFilhoVFG:RemoveField("VFG_NOMFIL")

    
Return oView

/*/
{Protheus.doc} OA2020017_CreateTrigger
Esta função realiza a criação de gatilhos na Model das tabelas VFF e VFG.
@type   Static Function
@author Otávio Favarelli
@since  23/12/2019
@param	cTabOrig,	Caractere,	Tabela na qual os gatilhos serão criados.
@return	aAux,	    Matriz, 	Matriz com os gatilhos a serem criados.
/*/
Static Function OA2020017_CreateTrigger(cTabOrig)
    
    Local aAux      := {}
    Default cTabOrig := ""

    If cTabOrig == "VFF"
        AAdd(aAux,FwStruTrigger(;
                                "VFF_CODGRF" ,;                                                                 // Campo Dominio
                                "VFF_DESGRF" ,;                                                                 // Campo de Contradominio
                                'Posicione("VX5",1,xFilial("VX5")+"078"+M->VFF_CODGRF,"VX5_DESCRI")',;          // Regra de Preenchimento
                                .F. ,;                                                                          // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                           // Alias da tabela a ser posicionada
                                0 ,;                                                                            // Ordem da tabela a ser posicionada
                                "" ,;                                                                           // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                          // Condicao para execucao do gatilho
                                "01" ))                                                                         // Sequencia do gatilho (usado para identificacao no caso de erro)

    ElseIf cTabOrig == "VFG"        
        AAdd(aAux,FwStruTrigger(;       
                                "VFG_CODMAR" ,;                                                                 // Campo Dominio
                                "VFG_DESMAR" ,;                                                                 // Campo de Contradominio
                                'Posicione("VE1",1,xFilial("VE1")+M->VFG_CODMAR,"VE1_DESMAR")',;                // Regra de Preenchimento
                                .F. ,;                                                                          // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                           // Alias da tabela a ser posicionada
                                0 ,;                                                                            // Ordem da tabela a ser posicionada
                                "" ,;                                                                           // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                          // Condicao para execucao do gatilho
                                "01" ))                                                                         // Sequencia do gatilho (usado para identificacao no caso de erro)

        AAdd(aAux,FwStruTrigger(;       
                                "VFG_GRUMOD" ,;                                                                 // Campo Dominio
                                "VFG_DESGRU" ,;                                                                 // Campo de Contradominio
                                'Posicione("VVR",1,xFilial("VVR")+M->VFG_CODMAR+M->VFG_GRUMOD,"VVR_DESCRI")',;  // Regra de Preenchimento
                                .F. ,;                                                                          // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                           // Alias da tabela a ser posicionada
                                0 ,;                                                                            // Ordem da tabela a ser posicionada
                                "" ,;                                                                           // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                          // Condicao para execucao do gatilho
                                "01" ))                                                                         // Sequencia do gatilho (usado para identificacao no caso de erro)

        AAdd(aAux,FwStruTrigger(;       
                                "VFG_MODVEI" ,;                                                                 // Campo Dominio
                                "VFG_DESMOD" ,;                                                                 // Campo de Contradominio
                                'Posicione("VV2",1,xFilial("VV2")+M->VFG_CODMAR+M->VFG_MODVEI,"VV2_DESMOD")',;  // Regra de Preenchimento
                                .F. ,;                                                                          // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                           // Alias da tabela a ser posicionada
                                0 ,;                                                                            // Ordem da tabela a ser posicionada
                                "" ,;                                                                           // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                          // Condicao para execucao do gatilho
                                "01" ))                                                                         // Sequencia do gatilho (usado para identificacao no caso de erro)
    EndIf
   
Return aAux
