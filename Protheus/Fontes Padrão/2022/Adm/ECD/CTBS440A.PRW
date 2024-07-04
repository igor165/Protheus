#Include "CTBS440A.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

Function CTBS440A()
Return()

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

Local oStruCQU  := FwFormStruct(1,"CQU")
Local oStruCQV  := FwFormStruct(1,"CQV")

Local oModel

Local bLoad     := {|oGrd| CS440Load(oGrd)}

Local aRelation := {}

SetStruct(oStruCQU,oStruCQV)

oModel := MPFormModel():New("CTBS440A",/*bPreValid*/, /*bPost*/, {||.t.})

oModel:AddFields("CQUMASTER",/*cOwner */,oStruCQU)

oModel:AddGrid("CQVDETAIL", "CQUMASTER", oStruCQV,,,,,bLoad)

aAdd(aRelation,{"CQV_FILIAL",   "xFilial('CQV')"})
aAdd(aRelation,{"CQV_IDBLK",    "CQU_IDBLK"})
aAdd(aRelation,{"CQV_CODCTA",   "CQU_CODCTA"})

oModel:SetRelation("CQVDETAIL", aRelation,"CQV_FILIAL+CQV_IDBLK+CQV_GRUFIL+CQV_CODEMP+CQV_CTAEMP") 

oModel:GetModel("CQUMASTER"):SetOnlyQuery(.t.)
oModel:GetModel("CQVDETAIL"):SetOnlyQuery(.t.)

oModel:GetModel("CQVDETAIL"):SetNoDeleteLine(.T.)

oModel:SetDescription(STR0001) //"Bloco K100 - Empresas Consolidadas"

oModel:SetPrimaryKey({})

Return(oModel)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} SetStruct

Função que efetua a definição das estruturas dos submodelos do cabeçalho e do grid

@params:
    oStruCQU:   Objeto. Instância da classe FwFormModelStruct ou FwFormViewStruct
    oStruCQV:   Objeto. Instância da classe FwFormModelStruct ou FwFormViewStruct
    cStrType:   Caractere. Tipo de estrutura - "M" Modelo; "V" View
@return: 
	oModel:	Objeto. Instância da classe FwFormModel()

@sample:
	
@author Fernando Radu Muscalu

@since 06/02/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function SetStruct(oStruCQU,oStruCQV,cStrType)

Local nI        := 0
Local nGrpTam   := 0
Local nEmpTam   := 0
Local nUNegTam  := 0
Local nFilTam   := 0

Local aTamanho  := {}
Local aStruFld  := {}

Default cStrType := "M"

aTamanho := ECDFilLength()

nGrpTam     := aTamanho[1]
nEmpTam     := aTamanho[2]
nUNegTam    := aTamanho[3]
nFilTam     := aTamanho[4]

If ( Upper(cStrType) == "M" )   //Tipo de Estrutura Model
    
    If ( !oStruCQU:HasField("CQU_IDBLK") )

        oStruCQU:AddField(  GetSx3Cache("CQU_IDBLK","X3_TITULO"),;  // Título do Campo
                            GetSx3Cache("CQU_IDBLK","X3_DESCRIC"),; // Tooltip da descrição do campo
                            "CQU_IDBLK",;                           // Nome do Campo
                            GetSx3Cache("CQU_IDBLK","X3_TIPO"),;    // Tipo do Campo
                            GetSx3Cache("CQU_IDBLK","X3_TAMANHO"),; // Tamanho do Campo
                            GetSx3Cache("CQU_IDBLK","X3_DECIMAL"),; // Decimal do Campo
                            {|| .T.},;                              // Bloco de validação do campo (Valid)
                            {||	.T.},;                              // Bloco de edição do campo (When)
                            Nil,;                                   // Lista de valores, caso seja um combobox
                            Nil,;                                   // Se o campo é obrigatório
                            MontaBlock(GetSx3Cache("CQU_IDBLK","X3_RELACAO")),;                                   // Inicializador padrão do campo
                            Nil,;                                   // O campo compõe uma chave única?
                            .F.,;                                   // Não atualiza o conteúdo?
                            .T. )                                   // O campo é virtual?

    EndIf

    If ( !oStruCQV:HasField("CQV_IDBLK") )

        oStruCQV:AddField(  GetSx3Cache("CQV_IDBLK","X3_TITULO"),;  // Título do Campo
                            GetSx3Cache("CQV_IDBLK","X3_DESCRIC"),; // Tooltip da descrição do campo
                            "CQV_IDBLK",;                           // Nome do Campo
                            GetSx3Cache("CQV_IDBLK","X3_TIPO"),;    // Tipo do Campo
                            GetSx3Cache("CQV_IDBLK","X3_TAMANHO"),; // Tamanho do Campo
                            GetSx3Cache("CQV_IDBLK","X3_DECIMAL"),; // Decimal do Campo
                            {|| .T.},;                              // Bloco de validação do campo (Valid)
                            {||	.T.},;                              // Bloco de edição do campo (When)
                            Nil,;                                   // Lista de valores, caso seja um combobox
                            Nil,;                                   // Se o campo é obrigatório
                            MontaBlock(GetSx3Cache("CQV_IDBLK","X3_RELACAO")),;                                   // Inicializador padrão do campo
                            Nil,;                                   // O campo compõe uma chave única?
                            .F.,;                                   // Não atualiza o conteúdo?
                            .T. )                                   // O campo é virtual?
        

    EndIf

    oStruCQV:AddField(  GetSx3Cache("CQR_GRUFIL","X3_TITULO"),;  // Título do Campo
                        GetSx3Cache("CQR_GRUFIL","X3_DESCRIC"),; // Tooltip da descrição do campo
                        "CQV_GRUFIL",;                           // Nome do Campo
                        GetSx3Cache("CQR_GRUFIL","X3_TIPO"),;    // Tipo do Campo
                        GetSx3Cache("CQR_GRUFIL","X3_TAMANHO"),; // Tamanho do Campo
                        GetSx3Cache("CQR_GRUFIL","X3_DECIMAL"),; // Decimal do Campo
                        {|| .T.},;                              // Bloco de validação do campo (Valid)
                        {||	.T.},;                              // Bloco de edição do campo (When)
                        Nil,;                                   // Lista de valores, caso seja um combobox
                        Nil,;                                   // Se o campo é obrigatório
                        Nil,;                                   // Inicializador padrão do campo
                        Nil,;                                   // O campo compõe uma chave única?
                        .F.,;                                   // Não atualiza o conteúdo?
                        .T. )                                   // O campo é virtual?

    //Novos campos adicionados ao submodelo CQV
    oStruCQV:AddField(  STR0002,;    // Título do Campo //"Grupo de Empresa"
                        STR0002,;    // Tooltip da descrição do campo //"Grupo de Empresa"
                        "CQV_XGRP",;            // Nome do Campo
                        "C",;                   // Tipo do Campo
                        nGrpTam,;               // Tamanho do Campo
                        0,;                     // Decimal do Campo
                        {|| .T.},;              // Bloco de validação do campo (Valid)
                        {||	.T.},;              // Bloco de edição do campo (When)
                        Nil,;                   // Lista de valores, caso seja um combobox
                        Nil,;                   // Se o campo é obrigatório
                        Nil,;                   // Inicializador padrão do campo
                        Nil,;                   // O campo compõe uma chave única?
                        .F.,;                   // Não atualiza o conteúdo?
                        .T. )                   // O campo é virtual?
    
    oStruCQV:AddField(  STR0003,;    // Título do Campo //"Empresa"
                        STR0003,;    // Tooltip da descrição do campo //"Empresa"
                        "CQV_XEMP",;            // Nome do Campo 
                        "C",;                   // Tipo do Campo
                        nEmpTam,;               // Tamanho do Campo
                        0,;                     // Decimal do Campo
                        {|| .T.},;              // Bloco de validação do campo (Valid)
                        {||	.T.},;              // Bloco de edição do campo (When)
                        Nil,;                   // Lista de valores, caso seja um combobox
                        Nil,;                   // Se o campo é obrigatório
                        {|| SubStr(CQR->CQR_GRUFIL,nGrpTam+1,nEmpTam)},;                   // Inicializador padrão do campo
                        Nil,;                   // O campo compõe uma chave única?
                        .F.,;                   // Não atualiza o conteúdo?
                        .T. )                   // O campo é virtual?
    
    oStruCQV:AddField(  STR0004,;  // Título do Campo //"Unidade de Negócio"
                        STR0004,;  // Tooltip da descrição do campo //"Unidade de Negócio"
                        "CQV_XUNEG",;            // Nome do Campo
                        "C",;                   // Tipo do Campo
                        nUNegTam,;              // Tamanho do Campo
                        0,;                     // Decimal do Campo
                        {|| .T.},;              // Bloco de validação do campo (Valid)
                        {||	.T.},;              // Bloco de edição do campo (When)
                        Nil,;                   // Lista de valores, caso seja um combobox
                        Nil,;                   // Se o campo é obrigatório
                        {|| SubStr(CQR->CQR_GRUFIL,nGrpTam+nEmpTam+1,nUNegTam)},;                   // Inicializador padrão do campo
                        Nil,;                   // O campo compõe uma chave única?
                        .F.,;                   // Não atualiza o conteúdo?
                        .T. )                   // O campo é virtual?
    
    oStruCQV:AddField(  STR0005,;              // Título do Campo //"Filial"
                        STR0006,;   // Tooltip da descrição do campo //"Filial de Sistema"
                        "CQV_XFIL",;            // Nome do Campo
                        "C",;                   // Tipo do Campo
                        nFilTam,;               // Tamanho do Campo
                        0,;                     // Decimal do Campo
                        {|| .T.},;              // Bloco de validação do campo (Valid)
                        {||	.T.},;              // Bloco de edição do campo (When)
                        Nil,;                   // Lista de valores, caso seja um combobox
                        Nil,;                   // Se o campo é obrigatório
                        {|| SubStr(CQR->CQR_GRUFIL,nGrpTam+nEmpTam+nUNegTam+1,nFilTam)},;                   // Inicializador padrão do campo
                        Nil,;                   // O campo compõe uma chave única?
                        .F.,;                   // Não atualiza o conteúdo?
                        .T. )                   // O campo é virtual?

    If ( !oStruCQV:HasField("CQV_CODCTA") )

        oStruCQV:AddField(  GetSx3Cache("CQV_CODCTA","X3_TITULO"),;  // Título do Campo
                            GetSx3Cache("CQV_CODCTA","X3_DESCRIC"),; // Tooltip da descrição do campo
                            "CQV_CODCTA",;                           // Nome do Campo
                            GetSx3Cache("CQV_CODCTA","X3_TIPO"),;    // Tipo do Campo
                            GetSx3Cache("CQV_CODCTA","X3_TAMANHO"),; // Tamanho do Campo
                            GetSx3Cache("CQV_CODCTA","X3_DECIMAL"),; // Decimal do Campo
                            {|| .T.},;                              // Bloco de validação do campo (Valid)
                            {||	.T.},;                              // Bloco de edição do campo (When)
                            Nil,;                                   // Lista de valores, caso seja um combobox
                            Nil,;                                   // Se o campo é obrigatório
                            Nil,;                                   // Inicializador padrão do campo
                            Nil,;                                   // O campo compõe uma chave única?
                            .F.,;                                   // Não atualiza o conteúdo?
                            .T. )                                   // O campo é virtual?

    EndIf
    
    //Adiciona índice
    oStruCQV:AddIndex(9,"IND09","CQV_FILIAL+CQV_IDBLK+CQV_GRUFIL+CQV_CODEMP+CQV_CTAEMP","Indice Conglomerado", "", "IND09",.T.)

    //Altera as propriedades da estrutura dos Submodelos
    oStruCQU:SetProperty("*",MODEL_FIELD_VALID  ,{|| .T.})
    oStruCQU:SetProperty("*",MODEL_FIELD_WHEN   ,{|| .T.})
    oStruCQV:SetProperty("*",MODEL_FIELD_VALID  ,{|| .T.})
    oStruCQV:SetProperty("*",MODEL_FIELD_WHEN   ,{|| .T.})

EndIf

Return()    

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CS440Load

efetua a carga de dados do submodelo do grid

@params:
    oGridCQV:   Objeto. Instância da classe FwFormGridModel   
@return: 
	aRet:	Array. Dados que comporão o grid
        aRet[n] 
            aRet[n][1]: Numérico. Id do registro (RecNo)
            aRet[n][2]: Array. são os dados de cada campo da estrutura de dados do submodelo (neste caso, estrutura de oGridCQV)
                aRet[n,2][1]: Qualquer tipo. Conteúdo do primeiro campo, de acordo com a estrutura
                aRet[n,2][2]: Qualquer tipo. Conteúdo do segundo campo, de acordo com a estrutura
                aRet[n,2][3]: Qualquer tipo. Conteúdo do terceiro campo, de acordo com a estrutura
                ...
                aRet[n,2][x]: Qualquer tipo. Conteúdo do (x-ézimo) elemento campo, de acordo com a estrutura    
@sample:    
	oModel:AddGrid("CQVDETAIL", "CQUMASTER", oStruCQV,,,,,{|oGridCQV| CS440Load(oGridCQV) }})
@author Fernando Radu Muscalu

@since 06/02/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function CS440Load(oGridCQV)

Local aRet      := {}
Local aFldConv  := {}
Local aIndex    := {{"IDX",{"CQV_FILIAL","CQV_IDBLK","CQV_GRUFIL","CQV_CODEMP","CQV_CTAEMP"}}}
Local aTamanho := ECDFilLength()

Local cFields   := ATFFld2Str(oGridCQV:GetStruct(),.f.,aFldConv,,,.t.)
Local cIdBlk    := ""
Local cCodCta   := ""
Local cQuery    := ""

Local nGrpTam   := Iif( aTamanho[1] > 0, aTamanho[1], 1)
Local nEmpTam   := Iif( aTamanho[2] > 0, aTamanho[2], 1)
Local nUNegTam  := Iif( aTamanho[3] > 0, aTamanho[3], 1)
Local nFilTam   := Iif( aTamanho[4] > 0, aTamanho[4], 1)

Local oGridCQU  := oGridCQV:GetModel():GetModel("CQUMASTER")
Local oTempTab

cIdBlk  := oGridCQU:GetValue("CQU_IDBLK")
cCodCta := oGridCQU:GetValue("CQU_CODCTA")

If ( At("CQV_GRUFIL",cFields) > 0 )
    cFields := StrTran(cFields,"CQV_GRUFIL","CQR_GRUFIL CQV_GRUFIL")
EndIf    

If ( At("CQV_XGRP",cFields) > 0 )
    cFields := StrTran(cFields,"CQV_XGRP","SUBSTRING(CQR_GRUFIL,1," + cValToChar(nGrpTam) + ") CQV_XGRP")
EndIf

If ( At("CQV_XEMP",cFields) > 0 )
    cFields := StrTran(cFields,"CQV_XEMP","SUBSTRING(CQR_GRUFIL," + cValToChar(nGrpTam+1) + "," + cValToChar(nEmpTam) + ") CQV_XEMP")
EndIf

If ( At("CQV_XUNEG",cFields) > 0 )
    cFields := StrTran(cFields,"CQV_XUNEG","SUBSTRING(CQR_GRUFIL," + cValToChar(nGrpTam+nEmpTam+1) + "," + cValToChar(nUNegTam) + ") CQV_XUNEG")
EndIf

If ( At("CQV_XFIL",cFields) > 0 )
    cFields := StrTran(cFields,"CQV_XFIL","SUBSTRING(CQR_GRUFIL," + cValToChar(nGrpTam+nEmpTam+nUNegTam+1) + "," + cValToChar(nFilTam) + ") CQV_XFIL")
EndIf

cQuery := "SELECT"
cQuery += " " + cFields + CHR(13)
cQuery += "FROM " + CHR(13)
cQuery += " " + RetSQLName("CQR") + " CQR " + CHR(13)
cQuery += "INNER JOIN " + CHR(13)
cQuery += " " + RetSQLName("CQV") + " CQV " + CHR(13)
cQuery += "ON " + CHR(13)
cQuery += " CQV_FILIAL = CQR_FILIAL " + CHR(13)
cQuery += " AND CQV_IDBLK = CQR_IDBLK " + CHR(13)
cQuery += " AND CQV_CODCTA = '" + cCodCta + "' " + CHR(13)
cQuery += " AND CQV_CODEMP = CQR_CODEMP " + CHR(13)
cQuery += " AND CQV.D_E_L_E_T_ = '' " + CHR(13)
cQuery += "WHERE " + CHR(13)
cQuery += " CQR_FILIAL = '" + xFilial("CQR") + "' " + CHR(13)
cQuery += " AND CQR_IDBLK = '" + cIdBlk + "' " + CHR(13)
cQuery += " AND CQR.D_E_L_E_T_ = '' "
cQuery += "ORDER BY " + CHR(13) 
cQuery += " CQV_FILIAL, " + CHR(13)
cQuery += " CQV_IDBLK,  " + CHR(13)
cQuery += " CQV_GRUFIL, " + CHR(13)
cQuery += " CQV_CODEMP, " + CHR(13)
cQuery += " CQV_CODCTA "

cQuery := ChangeQuery(cQuery)

oTempTab := ATFTempTable(cQuery,,aIndex,aFldConv)

aRet := FWLoadByAlias(oGridCQV,oTempTab:GetAlias(),oTempTab:GetRealName())

oTempTab:Delete()
FreeObj(oTempTab)

Return(aRet)