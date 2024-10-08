#Include "TOTVS.ch"
#Include "FWMVCDef.ch"
#Include "OFIA201.ch"
 
/*/
{Protheus.doc} OFIA201
Rotina que realiza o cadastro do DEF (DFS D-In) gerencial referencial da AGCO com informa��es de colaboradores.
@type   Function
@author Ot�vio Favarelli
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
     
    //Instanciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela
    oBrowse:SetAlias("VFF")
 
    //Setando a descri��o da rotina
    oBrowse:SetDescription(STR0001)	// Cadastro DFS Gerencial Referencial AGCO - Colaborador
    
    oBrowse:SetFilterDefault("VFF_TIPREG == '1'")

    SetKey(VK_F4,{|| OA2010017_TeclaF4() })
    
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)

Return Nil
 
/*/
{Protheus.doc} MenuDef
Fun��o padr�o do MVC respons�vel pela defini��o das op��es de menu do Browse do fonte OFIA201 que estar�o dispon�veis ao usu�rio.
@type   Static Function
@author Ot�vio Favarelli
@since  15/11/2019
@param  nil
@return aRot,   Matriz, Matriz que cont�m as op��es de menu a serem utilizadas pelo usu�rio.
/*/
Static Function MenuDef()
    
    Local aRot
    
    aRot := {}
    aRot := FWMVCMenu("OFIA201")
 
Return aRot

/*/
{Protheus.doc} ModelDef
Fun��o padr�o do MVC respons�vel pela cria��o do modelo de dados (regras de neg�cio) para a rotina OFIA201.
@type   Static Function
@author Ot�vio Favarelli
@since  15/11/2019
@param  nil
@return oModel, Objeto, Objeto que cont�m o modeldef.
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
    oStPaiVFF:SetProperty("VFF_CODDRF", MODEL_FIELD_OBRIGAT, .t. )                                      //Campo Obrigat�rio
    oStPaiVFF:SetProperty("VFF_TIPREG"  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "1")) // Inicializador Padr�o - 1=Colaborador
    oStFilhoVFG:SetProperty("VFG_TIPREG", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "1")) // Inicializador Padr�o - 1=Colaborador

    For nCntForA := 1 to Len(aTriggerPaiVFF)
        oStPaiVFF:AddTrigger(;
                            aTriggerPaiVFF[nCntForA,1],;   // [01] Id do campo de origem
                            aTriggerPaiVFF[nCntForA,2],;   // [02] Id do campo de destino
                            aTriggerPaiVFF[nCntForA,3],;   // [03] Bloco de codigo de valida��o da execu��o do gatilho
                            aTriggerPaiVFF[nCntForA,4])    // [04] Bloco de codigo de execu��o do gatilho
    Next

    For nCntForB := 1 to Len(aTriggerFilhoVFG)
        oStFilhoVFG:AddTrigger(;
                            aTriggerFilhoVFG[nCntForB,1],;   // [01] Id do campo de origem
                            aTriggerFilhoVFG[nCntForB,2],;   // [02] Id do campo de destino
                            aTriggerFilhoVFG[nCntForB,3],;   // [03] Bloco de codigo de valida��o da execu��o do gatilho
                            aTriggerFilhoVFG[nCntForB,4])    // [04] Bloco de codigo de execu��o do gatilho
    Next

    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New("OFIA201M")
    oModel:AddFields("VFFMASTER",/*cOwner*/,oStPaiVFF)
    oModel:AddGrid("VFGDETAIL","VFFMASTER",oStFilhoVFG,/*bLinePre*/,bLinePost,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner � para quem pertence

    //Fazendo o relacionamento entre o Pai e Filho
    aAdd(aVFGRel, {"VFG_FILIAL","VFF_FILIAL"} )
    aAdd(aVFGRel, {"VFG_CODCAB","VFF_CODCAB"} )
    aAdd(aVFGRel, {"VFG_TIPREG","VFF_TIPREG"} )

     
    oModel:SetRelation("VFGDETAIL", aVFGRel, VFG->(IndexKey(1))) //IndexKey -> quero a ordena��o e depois filtrado
    oModel:GetModel("VFGDETAIL"):SetUniqueLine({"VFG_CODCAB","VFG_TIPREG","VFG_CODSEQ"})    //N�o repetir informa��es ou combina��es
    oModel:SetPrimaryKey({})
     
    //Setando as descri��es
    oModel:SetDescription(STR0001)	// Cadastro DFS Gerencial Referencial AGCO - Colaborador
    oModel:GetModel("VFFMASTER"):SetDescription(STR0002)	// Cabe�alho Gerencial DFS AGCO
    oModel:GetModel("VFGDETAIL"):SetDescription(STR0003)	// Itens Gerencial DFS AGCO

Return oModel

/*/
{Protheus.doc} ViewDef
Fun��o padr�o do MVC respons�vel pela cria��o da vis�o de dados (intera��o do usu�rio) para a rotina OFIA201.
@type   Static Function
@author Ot�vio Favarelli
@since  15/11/2019
@param  nil
@return oView, Objeto, Objeto que cont�m o viewdef.
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
     
    //Adicionando os campos do cabe�alho e o grid dos filhos
    oView:AddField('VIEW_VFF'   ,oStPaiVFF  ,'VFFMASTER')
    oView:AddGrid('VIEW_VFG'    ,oStFilhoVFG,'VFGDETAIL')
     
    //Setando o dimensionamento de tamanho das box
    oView:CreateHorizontalBox('CABEC',20)
    oView:CreateHorizontalBox('GRID',80)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_VFF','CABEC')
    oView:SetOwnerView('VIEW_VFG','GRID')
     
    //Habilitando t�tulo
    oView:EnableTitleView('VIEW_VFF',STR0002)	// Cabe�alho Gerencial DFS AGCO
    oView:EnableTitleView('VIEW_VFG',STR0003)	// Itens Gerencial DFS AGCO
    
    //Incremento
    oView:AddIncrementField("VIEW_VFG", "VFG_CODSEQ")

    //For�a o fechamento da janela na confirma��o
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
Fun��o que trata o bloco de c�digo bLinePost do MVC respons�vel pela valida��o da transi��o entre linhas da grid. � chamado na cria��o da grid no ModelDef().
@type   Static Function
@author Ot�vio Favarelli
@since  15/11/2019
@param  oGridModel, Objeto,     Objeto que cont�m o modelo da grid (modeldef) para ser validado.
        nLine,      Num�rico,   Posi��o da linha que est� sendo verificada.
@return lRet,       Booleano,   Indica se a valida��o ocorreu com sucesso ou n�o.
/*/
Static Function LinePost(oGridModel, nLine)
    
    Local lRet := .t.   
    
    If !Empty(oGridModel:GetValue("VFG_CC")) .and. !Empty(oGridModel:GetValue("VFG_CODTEC"))
        lRet := .f.         
        Help(NIL, NIL, STR0004, NIL, STR0005, /* Informa��es Conflitantes | N�o � poss�vel informar na mesma linha Centro de Custo e C�digo do T�cnico. Imposs�vel continuar. */;
            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006}) // Informe apenas o Centro de Custo ou apenas o C�digo do T�cnico.
    EndIf

    If Empty(oGridModel:GetValue("VFG_CC")) .and. Empty(oGridModel:GetValue("VFG_CODTEC"))
        lRet := .f.         
        Help(NIL, NIL, STR0007, NIL, STR0008, /* Linha em Branco | N�o � poss�vel informar uma linha em branco no cadastro. Imposs�vel continuar. */;
            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0009}) // Informe o Centro de Custo ou o C�digo do T�cnico.
    EndIf
   
Return lRet

/*/
{Protheus.doc} OA2010037_CreateTrigger
Esta fun��o realiza a cria��o de gatilhos na Model das tabelas VFF e VFG.
@type   Static Function
@author Ot�vio Favarelli
@since  23/12/2019
@param	cTabOrig,	Caractere,	Tabela na qual os gatilhos ser�o criados.
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
Execu��o da tecla de atalho F4.
@type   Static Function
@author Ot�vio Favarelli
@since  22/12/2019
@param  nil
@return nil
/*/
Static Function OA2010017_TeclaF4()

Local cOkFunc := "OA201SEL"

// Realiza a chamada da fun��o OA180FTEC, que � uma consulta de t�cnicos por filiais
If ReadVar() $ "M->VFG_CODTEC"
    OA180FTEC(cOkFunc)
EndIf

Return

/*/
{Protheus.doc} OA201SEL
Esta fun��o realiza a sele��o / preenchimento da filial, do t�cnico e do nome do t�cnico.
Esta fun��o � utilizada na consulta de filial por t�cnico denominada OA180FTEC.
@type   Function
@author Ot�vio Favarelli
@since  22/12/2019
@param	cFilTec,	Caractere,	C�digo da Filial do T�cnico a ser preenchido.
        cCodTec,	Caractere,	C�digo do T�cnico a ser preenchido.
        cNomTec,	Caractere,	Nome do T�cnico a ser preenchido.
@return	lRetorno,	Booleano,	Informa se a sele��o deste t�cnico ocorreu com sucesso.
/*/
Function OA201SEL( cFilTec, cCodTec, cNomTec )

    Local lRetorno := .t.
    
    If .f. // Para n�o dar Warning
        OA201SEL(cFilTec, cCodTec, cNomTec)
    EndIf

    M->VFG_CODTEC := cCodTec

Return lRetorno

/*/
{Protheus.doc} OA2010027_TriggerVFG
Esta fun��o realiza o gatilho de campos da VFG.
@type   Static Function
@author Ot�vio Favarelli
@since  23/12/2019
@param	cCampoVFG,	Caractere,	Campo da VFG que precisa ser alimentado pelo gatilho.
@return	cTrigRet,	Caractere,	Regra de Preenchimento do gatilho.
/*/
Static Function OA2010027_TriggerVFG( cCampoVFG )

    Local cTrigRet
    
    If .f. // Para n�o dar Warning
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
