#Include "TOTVS.ch"
#Include "FWMVCDef.ch"
#Include "OFIA201.ch"
 
/*/
{Protheus.doc} OFIA201
Rotina que realiza o cadastro do DEF (DFS D-In) gerencial referencial da AGCO com informações de colaboradores.
@type   Function
@author Otávio Favarelli
@since  15/11/2019
@param  nil
@return nil
/*/
Function OFIA201()
    
    Local aArea
    Local oBrowse

	//
	// Validacao de Licencas DMS
	//
	If !OFValLicenca():ValidaLicencaDMS()
		Return
	EndIf

    aArea := GetArea()
     
    //Instanciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela
    oBrowse:SetAlias("VFF")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(STR0001)	// Cadastro DFS Gerencial Referencial AGCO - Colaborador
    
    oBrowse:SetFilterDefault("VFF_TIPREG == '1'")

    SetKey(VK_F4,{|| OA2010017_TeclaF4() })
    
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)

Return Nil
 
/*/
{Protheus.doc} MenuDef
Função padrão do MVC responsável pela definição das opções de menu do Browse do fonte OFIA201 que estarão disponíveis ao usuário.
@type   Static Function
@author Otávio Favarelli
@since  15/11/2019
@param  nil
@return aRot,   Matriz, Matriz que contém as opções de menu a serem utilizadas pelo usuário.
/*/
Static Function MenuDef()
    
    Local aRot
    
    aRot := {}
    aRot := FWMVCMenu("OFIA201")
 
Return aRot

/*/
{Protheus.doc} ModelDef
Função padrão do MVC responsável pela criação do modelo de dados (regras de negócio) para a rotina OFIA201.
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
    Local bLinePost
    Local nCntForA, nCntForB

    oModel              := Nil
    oStPaiVFF           := FWFormStruct(1, "VFF")
    oStFilhoVFG         := FWFormStruct(1, "VFG")
    aVFGRel             := {}
    aTriggerPaiVFF      := OA2010037_CreateTrigger("VFF")
    aTriggerFilhoVFG    := OA2010037_CreateTrigger("VFG")
    bLinePost            := { |oGridModel, nLine| LinePost(oGridModel, nLine) }
    
    //Alterando propriedades de campos
    oStPaiVFF:SetProperty("VFF_CODDRF", MODEL_FIELD_OBRIGAT, .t. )                                      //Campo Obrigatório
    oStPaiVFF:SetProperty("VFF_TIPREG"  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "1")) // Inicializador Padrão - 1=Colaborador
    oStFilhoVFG:SetProperty("VFG_TIPREG", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "1")) // Inicializador Padrão - 1=Colaborador

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
    oModel := MPFormModel():New("OFIA201M")
    oModel:AddFields("VFFMASTER",/*cOwner*/,oStPaiVFF)
    oModel:AddGrid("VFGDETAIL","VFFMASTER",oStFilhoVFG,/*bLinePre*/,bLinePost,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

    //Fazendo o relacionamento entre o Pai e Filho
    aAdd(aVFGRel, {"VFG_FILIAL","VFF_FILIAL"} )
    aAdd(aVFGRel, {"VFG_CODCAB","VFF_CODCAB"} )
    aAdd(aVFGRel, {"VFG_TIPREG","VFF_TIPREG"} )

     
    oModel:SetRelation("VFGDETAIL", aVFGRel, VFG->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
    oModel:GetModel("VFGDETAIL"):SetUniqueLine({"VFG_CODCAB","VFG_TIPREG","VFG_CODSEQ"})    //Não repetir informações ou combinações
    oModel:SetPrimaryKey({})
     
    //Setando as descrições
    oModel:SetDescription(STR0001)	// Cadastro DFS Gerencial Referencial AGCO - Colaborador
    oModel:GetModel("VFFMASTER"):SetDescription(STR0002)	// Cabeçalho Gerencial DFS AGCO
    oModel:GetModel("VFGDETAIL"):SetDescription(STR0003)	// Itens Gerencial DFS AGCO

Return oModel

/*/
{Protheus.doc} ViewDef
Função padrão do MVC responsável pela criação da visão de dados (interação do usuário) para a rotina OFIA201.
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
    oModel      := FWLoadModel("OFIA201")
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
    oStFilhoVFG:RemoveField("VFG_CODCAB")
    oStFilhoVFG:RemoveField("VFG_DESCAB")
    oStFilhoVFG:RemoveField("VFG_TIPREG")
    oStFilhoVFG:RemoveField("VFG_CODMAR")
    oStFilhoVFG:RemoveField("VFG_DESMAR")
    oStFilhoVFG:RemoveField("VFG_GRUMOD")
    oStFilhoVFG:RemoveField("VFG_DESGRU")
    oStFilhoVFG:RemoveField("VFG_MODVEI")
    oStFilhoVFG:RemoveField("VFG_DESMOD")
    
Return oView

/*/
{Protheus.doc} LinePost
Função que trata o bloco de código bLinePost do MVC responsável pela validação da transição entre linhas da grid. É chamado na criação da grid no ModelDef().
@type   Static Function
@author Otávio Favarelli
@since  15/11/2019
@param  oGridModel, Objeto,     Objeto que contém o modelo da grid (modeldef) para ser validado.
        nLine,      Numérico,   Posição da linha que está sendo verificada.
@return lRet,       Booleano,   Indica se a validação ocorreu com sucesso ou não.
/*/
Static Function LinePost(oGridModel, nLine)
    
    Local lRet := .t.   
    
    If !Empty(oGridModel:GetValue("VFG_CC")) .and. !Empty(oGridModel:GetValue("VFG_CODTEC"))
        lRet := .f.         
        Help(NIL, NIL, STR0004, NIL, STR0005, /* Informações Conflitantes | Não é possível informar na mesma linha Centro de Custo e Código do Técnico. Impossível continuar. */;
            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006}) // Informe apenas o Centro de Custo ou apenas o Código do Técnico.
    EndIf

    If Empty(oGridModel:GetValue("VFG_CC")) .and. Empty(oGridModel:GetValue("VFG_CODTEC"))
        lRet := .f.         
        Help(NIL, NIL, STR0007, NIL, STR0008, /* Linha em Branco | Não é possível informar uma linha em branco no cadastro. Impossível continuar. */;
            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0009}) // Informe o Centro de Custo ou o Código do Técnico.
    EndIf
   
Return lRet

/*/
{Protheus.doc} OA2010037_CreateTrigger
Esta função realiza a criação de gatilhos na Model das tabelas VFF e VFG.
@type   Static Function
@author Otávio Favarelli
@since  23/12/2019
@param	cTabOrig,	Caractere,	Tabela na qual os gatilhos serão criados.
@return	aAux,	    Matriz, 	Matriz com os gatilhos a serem criados.
/*/
Static Function OA2010037_CreateTrigger(cTabOrig)
    
    Local aAux      := {}
    Default cTabOrig := ""

    If cTabOrig == "VFF"
        AAdd(aAux,FwStruTrigger(;
                                "VFF_CODGRF" ,;                                                         // Campo Dominio
                                "VFF_DESGRF" ,;                                                         // Campo de Contradominio
                                'Posicione("VX5",1,xFilial("VX5")+"078"+M->VFF_CODGRF,"VX5_DESCRI")',;  // Regra de Preenchimento
                                .F. ,;                                                                  // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                   // Alias da tabela a ser posicionada
                                0 ,;                                                                    // Ordem da tabela a ser posicionada
                                "" ,;                                                                   // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                  // Condicao para execucao do gatilho
                                "01" ))                                                                 // Sequencia do gatilho (usado para identificacao no caso de erro)
                                
        AAdd(aAux,FwStruTrigger(;
                                "VFF_CODDRF" ,;                                                         // Campo Dominio
                                "VFF_DESDRF" ,;                                                         // Campo de Contradominio
                                'Posicione("VX5",1,xFilial("VX5")+"079"+M->VFF_CODDRF,"VX5_DESCRI")',;  // Regra de Preenchimento
                                .F. ,;                                                                  // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                   // Alias da tabela a ser posicionada
                                0 ,;                                                                    // Ordem da tabela a ser posicionada
                                "" ,;                                                                   // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                  // Condicao para execucao do gatilho
                                "01" ))                                                                 // Sequencia do gatilho (usado para identificacao no caso de erro)
    ElseIf cTabOrig == "VFG"
        AAdd(aAux,FwStruTrigger(;
                                "VFG_CC" ,;                                                             // Campo Dominio
                                "VFG_DESCC" ,;                                                          // Campo de Contradominio
                                'Posicione("CTT",1,xFilial("CTT")+M->VFG_CC,"CTT_DESC01")',;            // Regra de Preenchimento
                                .F. ,;                                                                  // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                   // Alias da tabela a ser posicionada
                                0 ,;                                                                    // Ordem da tabela a ser posicionada
                                "" ,;                                                                   // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                  // Condicao para execucao do gatilho
                                "01" ))                                                                 // Sequencia do gatilho (usado para identificacao no caso de erro)
        
        AAdd(aAux,FwStruTrigger(;
                                "VFG_CODTEC" ,;                                                         // Campo Dominio
                                "VFG_NOMTEC" ,;                                                         // Campo de Contradominio
                                "StaticCall(OFIA201,OA2010027_TriggerVFG,'VFG_NOMTEC')",;               // Regra de Preenchimento
                                .F. ,;                                                                  // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                   // Alias da tabela a ser posicionada
                                0 ,;                                                                    // Ordem da tabela a ser posicionada
                                "" ,;                                                                   // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                  // Condicao para execucao do gatilho
                                "01" ))                                                                 // Sequencia do gatilho (usado para identificacao no caso de erro)
        
        AAdd(aAux,FwStruTrigger(;
                                "VFG_CODTEC" ,;                                                         // Campo Dominio
                                "VFG_FILTEC" ,;                                                         // Campo de Contradominio
                                "StaticCall(OFIA201,OA2010027_TriggerVFG,'VFG_FILTEC')",;               // Regra de Preenchimento
                                .F. ,;                                                                  // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                   // Alias da tabela a ser posicionada
                                0 ,;                                                                    // Ordem da tabela a ser posicionada
                                "" ,;                                                                   // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                  // Condicao para execucao do gatilho
                                "02" ))                                                                 // Sequencia do gatilho (usado para identificacao no caso de erro)

        AAdd(aAux,FwStruTrigger(;
                                "VFG_CODTEC" ,;                                                         // Campo Dominio
                                "VFG_NOMFIL" ,;                                                         // Campo de Contradominio
                                "StaticCall(OFIA201,OA2010027_TriggerVFG,'VFG_NOMFIL')",;               // Regra de Preenchimento
                                .F. ,;                                                                  // Se posicionara ou nao antes da execucao do gatilhos
                                "" ,;                                                                   // Alias da tabela a ser posicionada
                                0 ,;                                                                    // Ordem da tabela a ser posicionada
                                "" ,;                                                                   // Chave de busca da tabela a ser posicionada
                                NIL ,;                                                                  // Condicao para execucao do gatilho
                                "03" ))                                                                 // Sequencia do gatilho (usado para identificacao no caso de erro)
    EndIf
   
Return aAux

/*/
{Protheus.doc} OA2010017_TeclaF4
Execução da tecla de atalho F4.
@type   Static Function
@author Otávio Favarelli
@since  22/12/2019
@param  nil
@return nil
/*/
Static Function OA2010017_TeclaF4()

Local cOkFunc := "OA201SEL"

// Realiza a chamada da função OA180FTEC, que é uma consulta de técnicos por filiais
If ReadVar() $ "M->VFG_CODTEC"
    OA180FTEC(cOkFunc)
EndIf

Return

/*/
{Protheus.doc} OA201SEL
Esta função realiza a seleção / preenchimento da filial, do técnico e do nome do técnico.
Esta função é utilizada na consulta de filial por técnico denominada OA180FTEC.
@type   Function
@author Otávio Favarelli
@since  22/12/2019
@param	cFilTec,	Caractere,	Código da Filial do Técnico a ser preenchido.
        cCodTec,	Caractere,	Código do Técnico a ser preenchido.
        cNomTec,	Caractere,	Nome do Técnico a ser preenchido.
@return	lRetorno,	Booleano,	Informa se a seleção deste técnico ocorreu com sucesso.
/*/
Function OA201SEL( cFilTec, cCodTec, cNomTec )

    Local lRetorno := .t.
    
    If .f. // Para não dar Warning
        OA201SEL(cFilTec, cCodTec, cNomTec)
    EndIf

    M->VFG_CODTEC := cCodTec

Return lRetorno

/*/
{Protheus.doc} OA2010027_TriggerVFG
Esta função realiza o gatilho de campos da VFG.
@type   Static Function
@author Otávio Favarelli
@since  23/12/2019
@param	cCampoVFG,	Caractere,	Campo da VFG que precisa ser alimentado pelo gatilho.
@return	cTrigRet,	Caractere,	Regra de Preenchimento do gatilho.
/*/
Static Function OA2010027_TriggerVFG( cCampoVFG )

    Local cTrigRet
    
    If .f. // Para não dar Warning
        OA2010027_TriggerVFG( cCampoVFG )
    EndIf

    Do Case
        Case cCampoVFG == "VFG_NOMTEC"
            If Empty(FwFldGet("VFG_CODTEC"))
                cTrigRet := " "
            Else
                If Type("cNomTec") == "U"
                    cTrigRet := Posicione("VAI",1,xFilial("VAI")+FwFldGet("VFG_CODTEC"),"VAI_NOMTEC")
                Else
                    cTrigRet := cNomTec
                EndIf
            EndIf
        Case cCampoVFG == "VFG_FILTEC"
            If Empty(FwFldGet("VFG_CODTEC"))
                cTrigRet := " "
            Else
                If Type("cFilTec") == "U" .Or. Empty(cFilTec)
                    cTrigRet := Posicione("VAI",1,xFilial("VAI")+FwFldGet("VFG_CODTEC"),"VAI_FILPRO")
                Else
                    cTrigRet := cFilTec
                EndIf
            EndIf
        Case cCampoVFG == "VFG_NOMFIL"
            If Empty(FwFldGet("VFG_CODTEC"))
                cTrigRet := " "
            Else
                cTrigRet := FWFilialName( , FwFldGet("VFG_FILTEC") )
            EndIf
        Otherwise
            cTrigRet := " "
    EndCase

Return cTrigRet
