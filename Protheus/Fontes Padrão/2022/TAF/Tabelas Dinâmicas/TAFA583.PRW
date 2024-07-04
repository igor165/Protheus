#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA583.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA583
Cadastro de Prazos de Envio dos Eventos do eSocial        

@author Fabio Santos de Mendonca
@since 21/07/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA583()

    Local oBrw := FwMBrowse():New()

    If AliasIndic("V6Z")
        oBrw:SetDescription(STR0001) //"Cadastro de Prazos de Envio dos Eventos do eSocial"
        oBrw:SetAlias("V6Z")
        oBrw:SetMenuDef("TAFA583")
        oBrw:Activate()
    Else
        MsgAlert(STR0002)   //"Tabela V6Z não existe." 
    EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC para o Menu

@author Fabio Santos de Mendonca
@since 21/07/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF("TAFA583")

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados do Cadastro de Prazos de Envio de Eventos do eSocial

@author Fabio Santos de Mendonca
@since 21/07/2021
@version 1.0
@return oModel - Objeto do Modelo MVC
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStrV6Z := FWFormStruct(1,"V6Z")
    Local oStrV70 := FWFormStruct(1,"V70")
    Local oStrV71 := FWFormStruct(1,"V71")
    Local oModel  := MpFormModel():New("TAFA583")

    oModel:SetDescription(STR0003)  //"Prazos de Envio Eventos eSocial" 
    
    // Modelo da Legenda da Grid Mapeamento das Regras
    oStrV70:AddField( ;
                        AllTrim("") ,; 			    // [01] C Titulo do campo
                        AllTrim("") ,; 			    // [02] C ToolTip do campo
                        "V70_LEGEND" ,;             // [03] C identificador (ID) do Field
                        "C" ,;                      // [04] C Tipo do campo
                        50 ,;                       // [05] N Tamanho do campo
                        0 ,;                        // [06] N Decimal do campo
                        NIL ,;                      // [07] B Code-block de validação do campo
                        {|| legendBox() } ,;        // [08] B Code-block de validação When do campo
                        NIL ,;                      // [09] A Lista de valores permitido do campo
                        NIL ,;                      // [10] L Indica se o campo tem preenchimento obrigatório
                        { || IIF(V70->V70_STATUS == "1", "BR_VERDE","BR_VERMELHO") } ,;  		// [11] B Code-block de inicializacao do campo
                        NIL ,;                      // [12] L Indica se trata de um campo chave
                        NIL ,;                      // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual

    // Modelo da Legenda da Grid Complemento do Mapeamento das Regras
    oStrV71:AddField( ;
                        AllTrim("") ,; 			    // [01] C Titulo do campo
                        AllTrim("") ,; 			    // [02] C ToolTip do campo
                        "V71_LEGEND" ,;             // [03] C identificador (ID) do Field
                        "C" ,;                      // [04] C Tipo do campo
                        50 ,;                       // [05] N Tamanho do campo
                        0 ,;                        // [06] N Decimal do campo
                        NIL ,;                      // [07] B Code-block de validação do campo
                        {|| legendBox() } ,;        // [08] B Code-block de validação When do campo
                        NIL ,;                      // [09] A Lista de valores permitido do campo
                        NIL ,;                      // [10] L Indica se o campo tem preenchimento obrigatório
                        { || IIF(Posicione( "V70", 1, V71_FILIAL+V71_ID+V71_ITEMTB, "V70_STATUS" ) == "1", "BR_VERDE","BR_VERMELHO") } ,;  		// [11] B Code-block de inicializacao do campo
                        NIL ,;                      // [12] L Indica se trata de um campo chave
                        NIL ,;                      // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual


    // Associando Estruturas
    oModel:AddFields("MODEL_V6Z", /*cOwner*/, oStrV6Z)
    oModel:AddGrid("MODEL_V70", "MODEL_V6Z", oStrV70)
    oModel:AddGrid("MODEL_V71", "MODEL_V70", oStrV71)

    // Definindo Chave
    oModel:GetModel("MODEL_V6Z"):SetPrimaryKey({"V6Z_ID"})

    // Propriedades do Grid das Regras
    oModel:GetModel("MODEL_V70"):SetUniqueLine({"V70_ITEM"})
    oModel:GetModel("MODEL_V70"):SetNoInsertLine( .T. )
    oModel:GetModel("MODEL_V70"):SetNoDeleteLine( .T. )
    oModel:SetRelation("MODEL_V70", {{"V70_FILIAL", "V6Z_FILIAL"}, {"V70_ID", "V6Z_ID"}}, "V70_FILIAL + V70_ID")

    // Propriedades do Grid de Complemento das Regras
    oModel:GetModel("MODEL_V71"):SetUniqueLine({"V71_ITEM"})
    oModel:GetModel("MODEL_V71"):SetOptional( .T. )
    oModel:GetModel("MODEL_V71"):SetNoInsertLine( .T. )
    oModel:GetModel("MODEL_V71"):SetNoDeleteLine( .T. )
    oModel:SetRelation("MODEL_V71", {{"V71_FILIAL", "V70_FILIAL"}, {"V71_ID", "V70_ID"}, {"V71_ITEMTB", "V70_ITEM"}}, "V71_FILIAL + V71_ID + V71_ITEMTB")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do Cadastro de Prazos de Envio de Eventos do eSocial

@author Fabio Santos de Mendonca
@since 21/07/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oModel  := FwLoadModel("TAFA583")
    Local oStrV6Z := FWFormStruct(2,"V6Z")
    Local oStrV70 := FWFormStruct(2,"V70")
    Local oStrV71 := FWFormStruct(2,"V71")
    Local oView   := FWFormView():New()

    // Visão da Legenda da Grid Mapeamento das Regras
    oStrV70:AddField( ;            		                        
                        'V70_LEGEND' ,;     // [01]  C   Nome do Campo
                        "00" ,;             // [02]  C   Ordem
                        AllTrim( '' ) ,;    // [03]  C   Titulo do campo
                        AllTrim( '' ) ,;    // [04]  C   Descricao do campo
                        {'Legenda' } ,;     // [05]  A   Array com Help
                        'C' ,;              // [06]  C   Tipo do campo
                        '@BMP' ,;           // [07]  C   Picture
                        NIL ,;              // [08]  B   Bloco de Picture Var
                        '' ,;               // [09]  C   Consulta F3
                        .T. ,;              // [10]  L   Indica se o campo é alteravel
                        NIL ,;              // [11]  C   Pasta do campo
                        NIL ,;              // [12]  C   Agrupamento do campo
                        NIL ,;              // [13]  A   Lista de valores permitido do campo (Combo)
                        NIL ,;              // [14]  N   Tamanho maximo da maior opção do combo
                        NIL ,;              // [15]  C   Inicializador de Browse
                        .T. ,;              // [16]  L   Indica se o campo é virtual
                        NIL ,;              // [17]  C   Picture Variavel
                        NIL )               // [18]  L   Indica pulo de linha após o campo    

    // Visão da Legenda da Grid Complemento do Mapeamento das Regras
    oStrV71:AddField( ;
                        'V71_LEGEND' , ;    // [01]  C   Nome do Campo
                        "00" , ;            // [02]  C   Ordem
                        AllTrim( '' ) , ;   // [03]  C   Titulo do campo
                        AllTrim( '' ) , ;   // [04]  C   Descricao do campo
                        {'Legenda' } , ;    // [05]  A   Array com Help
                        'C' , ;             // [06]  C   Tipo do campo
                        '@BMP' , ;          // [07]  C   Picture
                        NIL , ;             // [08]  B   Bloco de Picture Var
                        '' , ;              // [09]  C   Consulta F3
                        .T. , ;             // [10]  L   Indica se o campo é alteravel
                        NIL , ;             // [11]  C   Pasta do campo
                        NIL , ;             // [12]  C   Agrupamento do campo
                        NIL , ;             // [13]  A   Lista de valores permitido do campo (Combo)
                        NIL , ;             // [14]  N   Tamanho maximo da maior opção do combo
                        NIL , ;             // [15]  C   Inicializador de Browse
                        .T. , ;             // [16]  L   Indica se o campo é virtual
                        NIL , ;             // [17]  C   Picture Variavel
                        NIL )               // [18]  L   Indica pulo de linha após o campo    

    // Remove Campos de Controle e Data de Vigência
    oStrV6Z:RemoveField("V6Z_FILIAL")
    oStrV6Z:RemoveField("V6Z_VALIDA")
    oStrV70:RemoveField("V70_FILIAL")
    oStrV70:RemoveField("V70_ID")
    oStrV71:RemoveField("V71_FILIAL")
    oStrV71:RemoveField("V71_ID")
    oStrV71:RemoveField("V71_ITEMTB")


    oView:SetModel(oModel)

    oView:AddField("VIEW_V6Z", oStrV6Z, "MODEL_V6Z")
    oView:EnableTitleView( "VIEW_V6Z", STR0001 )  //"Cadastro de Prazos de Envio dos Eventos do eSocial"

    oView:AddGrid("VIEW_V70", oStrV70, "MODEL_V70")
    oView:EnableTitleView("VIEW_V70", STR0004)  //"Mapeamento das Regras dos Prazos" 
        
    oView:AddGrid("VIEW_V71", oStrV71, "MODEL_V71")
    oView:EnableTitleView("VIEW_V71", STR0005)  //"Complemento das Regras"

    oView:CreateHorizontalBox("FIELDV6Z", 20 )
    oView:CreateHorizontalBox("GRIDV70", 50 )
    oView:CreateHorizontalBox("GRIDV71", 30 )

    oView:SetOwnerView("VIEW_V6Z", "FIELDV6Z" )
    oView:SetOwnerView("VIEW_V70", "GRIDV70" )
    oView:SetOwnerView("VIEW_V71", "GRIDV71" )

Return oView

/*/{Protheus.doc} legendBox
Box com as Legendas utilizadas no Grid

@author Fabio Santos de Mendonca
@since 22/07/2021
@version 1.0
@Return	.F., booleano, Retorna .F. pois é função usada para exibir o Box das Legendas e travar o campo para edição
/*/
Static Function legendBox()

    oLegend := FWLegend():New()

    oLegend:Add( { || }, "BR_VERDE"   , "Regra Ativa" ) // 
    oLegend:Add( { || }, "BR_VERMELHO" , "Regra Inativa" ) // 

    oLegend:Activate()
    oLegend:View()

Return .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont
Rotina para Carga e Atualização das tabelas que compõe a Tabela Autocontida
			
@author Fabio Santos de Mendonca
@since 21/07/2021
@version 1.0
@Param nVerEmp, numerico, Versão Corrente na Empresa
@Param nVerAtu, numerico, Versão Atual ( passado como referência )
@Return	aRet, Array com estrutura de Campos e conteúdo da Tabela
/*/
//-------------------------------------------------------------------
Static Function FAtuCont(nVerEmp, nVerAtu)

    Local aHeader := {}
    Local aBody   := {}
    Local aRet    := {}

    nVerAtu := 1032.01

    If nVerEmp < nVerAtu
        // V6Z - Cadastro Prazos Envio eSocial 
        PutV6Z(aHeader, aBody)
        aAdd( aRet, { aHeader, aBody } )

        // V70 - Mapeamento Regras dos Prazos    
        PutV70(aHeader, aBody)
        aAdd( aRet, { aHeader, aBody } )

        // V71 - Complemento das Regras
        PutV71(aHeader, aBody)
        aAdd( aRet, { aHeader, aBody } )
    EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PutV6Z
Rotina de Carga dos valores na Tabela V6Z
			
@author Fabio Santos de Mendonca
@since 21/07/2021
@version 1.0
@Param aHeader, array, Campos da Tabela
@Param aBody, array, Registros da Tabela
@Return	aRet, Array com estrutura de Campos e conteúdo da Tabela
/*/
//-------------------------------------------------------------------
Static Function PutV6Z(aHeader, aBody)

    aHeader   := {}
    aBody     := {}

    aAdd( aHeader, "V6Z_FILIAL" ) 
    aAdd( aHeader, "V6Z_ID" )
    aAdd( aHeader, "V6Z_CODEVE" )
    aAdd( aHeader, "V6Z_VALIDA" )

    //            FILIAL    ID          CODEVE      VALIDA 
    aAdd( aBody, {""        ,"000001"	,"S-1070"	,""})
    aAdd( aBody, {""        ,"000002"	,"S-1200"	,""})
    aAdd( aBody, {""        ,"000003"	,"S-1202"	,""})
    aAdd( aBody, {""        ,"000004"	,"S-1207"	,""})
    aAdd( aBody, {""        ,"000005"	,"S-1210"	,""})
    aAdd( aBody, {""        ,"000006"	,"S-1250"	,""})
    aAdd( aBody, {""        ,"000007"	,"S-1260"	,""})
    aAdd( aBody, {""        ,"000008"	,"S-1270"	,""})
    aAdd( aBody, {""        ,"000009"	,"S-1280"	,""})
    aAdd( aBody, {""        ,"000010"	,"S-1295"	,""})
    aAdd( aBody, {""        ,"000011"	,"S-1299"	,""})
    aAdd( aBody, {""        ,"000012"	,"S-1300"	,""})
    aAdd( aBody, {""        ,"000013"	,"S-2190"	,""})
    aAdd( aBody, {""        ,"000014"	,"S-2200"	,""})
    aAdd( aBody, {""        ,"000015"	,"S-2205"	,""})
    aAdd( aBody, {""        ,"000016"	,"S-2206"	,""})
    aAdd( aBody, {""        ,"000017"	,"S-2210"	,""})
    aAdd( aBody, {""        ,"000018"	,"S-2220"	,""})
    aAdd( aBody, {""        ,"000019"	,"S-2221"	,""})
    aAdd( aBody, {""        ,"000020"	,"S-2230"	,""})
    aAdd( aBody, {""        ,"000021"	,"S-2240"	,""})
    aAdd( aBody, {""        ,"000022"	,"S-2245"	,""})
    aAdd( aBody, {""        ,"000023"	,"S-2250"	,""})
    aAdd( aBody, {""        ,"000024"	,"S-2260"	,""})
    aAdd( aBody, {""        ,"000025"	,"S-2298"	,""})
    aAdd( aBody, {""        ,"000026"	,"S-2299"	,""})
    aAdd( aBody, {""        ,"000027"	,"S-2300"	,""})
    aAdd( aBody, {""        ,"000028"	,"S-2306"	,""})
    aAdd( aBody, {""        ,"000029"	,"S-2399"	,""})
    aAdd( aBody, {""        ,"000030"	,"S-2231"	,""})
    aAdd( aBody, {""        ,"000031"	,"S-2400"	,""})
    aAdd( aBody, {""        ,"000032"	,"S-2405"	,""})
    aAdd( aBody, {""        ,"000033"	,"S-2410"	,""})
    aAdd( aBody, {""        ,"000034"	,"S-2416"	,""})
    aAdd( aBody, {""        ,"000035"	,"S-2418"	,""})
    aAdd( aBody, {""        ,"000036"	,"S-2420"	,""})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PutV70
Rotina de Carga dos valores na Tabela V70
			
@author Fabio Santos de Mendonca
@since 21/07/2021
@version 1.0
@Param aHeader, array, Campos da Tabela
@Param aBody, array, Registros da Tabela
@Return	aRet, Array com estrutura de Campos e conteúdo da Tabela
/*/
//-------------------------------------------------------------------
Static Function PutV70(aHeader, aBody)

    aHeader   := {}
    aBody     := {}

    aAdd( aHeader, "V70_FILIAL" ) 
    aAdd( aHeader, "V70_ID" )
    aAdd( aHeader, "V70_ITEM" )
    aAdd( aHeader, "V70_MDCPRZ" ) //Modo de Calculo do Prazo:  1=MÊS SEGUINTE;2=MÊS ESPECÍFICO;3=DIA ANTERIOR;4=ULTIMO DIA MÊS SEGUINTE;5=MESMO DIA;6=SOMA DE DIAS;7=PRIMEIRO DIA UTIL SEGUINTE
    aAdd( aHeader, "V70_CRTAPU" ) //Criterio Apuracao        
    aAdd( aHeader, "V70_TABREF" ) //Tabela de Referencia(SX2)
    aAdd( aHeader, "V70_CMPREF" ) //Campo de Referencia(SX3) 
    aAdd( aHeader, "V70_DIA" )
    aAdd( aHeader, "V70_MESESP" ) //Mes Especifico           
    aAdd( aHeader, "V70_DSCPRZ" ) //Descricao do Prazo       
    aAdd( aHeader, "V70_FILTRO" ) //Filtro da Apuracao       
    aAdd( aHeader, "V70_STATUS" )

    // S-1070     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                      TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                  FILTRO                                                                                          STATUS
    aAdd( aBody, {""      ,"000001" ,"001"  ,"1"    ,"Mês de referência informado no evento"    ,"C1G"  ,"C1G_DTINI"  ,"15" ,""     ,"Até o dia 15 do mês subsequente."     ,"C1G_ESOCIA = '1' AND C1G_TPPROC IN ('1', '2') AND C1G_ATIVO = '1' AND C1G.D_E_L_E_T_ = ''"    ,"1"})

    // S-1200     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                      TABREF  CMDPREF       DIA   MESESP      DSCPRZ                                                                  FILTRO                                                                                   STATUS 
    aAdd( aBody, {""      ,"000002" ,"001"  ,"1"    ,"Apuração Mensal"                                          ,"C91"  ,"C91_PERAPU" ,"15" ,""         ,"Até o dia 15 do mês subsequente ao mês de referência do evento."      ,"C91_INDAPU = '1' AND C91_NOMEVE = 'S1200' AND C91_ATIVO = '1' AND C91.D_E_L_E_T_ = ''" ,"1"})
    aAdd( aBody, {""      ,"000002" ,"002"  ,"2"    ,"Apuração Anual (13º salário, gratificação natalina etc.)" ,"C91"  ,"C91_PERAPU" ,"20" ,"12"       ,"Até o dia 20 do mês de dezembro do ano a que se refere."              ,"C91_INDAPU = '2' AND C91_NOMEVE = 'S1200'AND C91_ATIVO = '1'  AND C91.D_E_L_E_T_ = ''" ,"1"})
    aAdd( aBody, {""      ,"000002" ,"003"  ,"1"    ,"Apuração Mensal - Segurado Especial"                      ,"C91"  ,"C91_PERAPU" ,"7"  ,""         ,"Até o dia 07 do mês subsequente ao mês de referência do evento."      ,"C91_INDAPU = '1' AND C91_NOMEVE = 'S1200' AND C91_ATIVO = '1' AND C91.D_E_L_E_T_ = ''" ,"1"})

    // S-1202     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                      TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                  FILTRO                                                                                      STATUS
    aAdd( aBody, {""      ,"000003" ,"001"  ,"1"    ,"Apuração Mensal"                                          ,"C91"  ,"C91_PERAPU" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao mês de referência do evento."      ,"C91_INDAPU = '1' AND C91_NOMEVE = 'S1202' AND C91_ATIVO = '1' AND C91.D_E_L_E_T_ = ''"    ,"1"})
    aAdd( aBody, {""      ,"000003" ,"002"  ,"2"    ,"Apuração Anual (13º salário, gratificação natalina etc.)" ,"C91"  ,"C91_PERAPU" ,"20" ,"12"   ,"Até o dia 20 do mês de dezembro do ano a que se refere."              ,"C91_INDAPU = '2' AND C91_NOMEVE = 'S1202' AND C91_ATIVO = '1' AND C91.D_E_L_E_T_ = ''"    ,"1"})

    // S-1207     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                      TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                FILTRO                                                                STATUS
    aAdd( aBody, {""      ,"000004" ,"001"  ,"1"    ,"Apuração Mensal"                                          ,"T62"  ,"T62_PERAPU" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao mês de referência do evento."    ,"T62_INDAPU = '1' AND T62_ATIVO = '1' AND T62.D_E_L_E_T_ = ''"       ,"1"})
    aAdd( aBody, {""      ,"000004" ,"002"  ,"2"    ,"Apuração Anual (13º salário, gratificação natalina etc.)" ,"T62"  ,"T62_PERAPU" ,"20" ,"12"   ,"Até o dia 20 do mês de dezembro do ano a que se refere."            ,"T62.T62_INDAPU = '2' AND T62_ATIVO = '1' AND T62.D_E_L_E_T_ = ''"   ,"1"})

    // S-1210     FILIAL  ID        ITEM    MDCPRZ  CRTAPU              TABREF  CMDPREF       DIA   MESESP  DSCPRZ                             FILTRO                                                               STATUS
    aAdd( aBody, {""      ,"000005" ,"001"  ,"1"    ,"Apuração Mensal"  ,"T3P"  ,"T3P_PERAPU" ,"15" ,""     ,"Até o dia 15 do mês seguinte"    ,"( T3P_INDAPU = '1' OR T3P_TPGUIA = '1' OR T3P_TPGUIA = '' ) AND T3P_ATIVO = '1' AND T3P.D_E_L_E_T_ = ''"      ,"1"})

    // S-1250     FILIAL  ID        ITEM    MDCPRZ  CRTAPU              TABREF  CMDPREF       DIA   MESESP  DSCPRZ                             FILTRO                                                               STATUS
    aAdd( aBody, {""      ,"000006" ,"001"  ,"1"    ,"Apuração Mensal"  ,"CMR"  ,"CMR_PERAPU" ,"15" ,""     ,"Até o dia 15 do mês seguinte"    ,"CMR_INDAPU = '1' AND CMR_ATIVO = '1' AND CMR.D_E_L_E_T_ = ''"      ,"1"})

    // S-1260     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                      TABREF  CMDPREF       DIA   MESESP          DSCPRZ                                                               FILTRO                                                               STATUS
    aAdd( aBody, {""      ,"000007" ,"001"  ,"1"    ,"Apuração Mensal"                                          ,"T1M"  ,"T1M_PERAPU" ,"15" ,""         ,"Até o dia 15 do mês seguinte"                                         ,"T1M_INDAPU = '1' AND T1M_ATIVO = '1' AND T1M.D_E_L_E_T_ = ''"      ,"1"})
    aAdd( aBody, {""      ,"000007" ,"002"  ,"1"    ,"Apuração Mensal - Segurado Especial"                      ,"T1M"  ,"T1M_PERAPU" ,"7"  ,""         ,"Até o dia 07 do mês subsequente ao mês de referência do evento."      ,"T1M_INDAPU = '1' AND T1M_ATIVO = '1' AND T1M.D_E_L_E_T_ = ''"      ,"1"})

    // S-1270     FILIAL  ID        ITEM    MDCPRZ  CRTAPU              TABREF  CMDPREF       DIA   MESESP  DSCPRZ                             FILTRO                                                               STATUS
    aAdd( aBody, {""      ,"000008" ,"001"  ,"1"    ,"Apuração Mensal"  ,"T2A"  ,"T2A_PERAPU" ,"15" ,""     ,"Até o dia 15 do mês seguinte"    ,"T2A_INDAPU = '1' AND T2A_ATIVO = '1' AND T2A.D_E_L_E_T_ = ''"      ,"1"})

    // S-1280     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                      TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                        FILTRO                                                                STATUS
    aAdd( aBody, {""      ,"000009" ,"001"  ,"1"    ,"Apuração Mensal"                                          ,"T3V"  ,"T3V_PERAPU" ,"15" ,""     ,"Até o dia 15 do mês seguinte"                               ,"T3V_INDAPU = '1' AND T3V_ATIVO = '1' AND T3V.D_E_L_E_T_ = ''"       ,"1"})
    aAdd( aBody, {""      ,"000009" ,"002"  ,"2"    ,"Apuração Anual (13º salário, gratificação natalina etc.)" ,"T3V"  ,"T3V_PERAPU" ,"20" ,"12"   ,"Até o dia 20 do mês de dezembro do ano a que se refere."    ,"T3V_INDAPU = '2' AND T3V_ATIVO = '1' AND T3V.D_E_L_E_T_ = ''"       ,"1"})

    // S-1295     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                      TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                              FILTRO                                                              STATUS
    aAdd( aBody, {""      ,"000010" ,"001"  ,"1"    ,"Apuração Mensal"                                          ,"T72"  ,"T72_PERAPU" ,"20" ,""     ,"Entre os dias 01 e 20 do mês subsequente ao da apuração mensal."  ,"T72_INDAPU = '1' AND T72_ATIVO = '1' AND T72.D_E_L_E_T_ = ''"     ,"1"})
    aAdd( aBody, {""      ,"000010" ,"002"  ,"2"    ,"Apuração Anual (13º salário, gratificação natalina etc.)" ,"T72"  ,"T72_PERAPU" ,"20" ,"12"   ,"Entre os dias 01 e 20 do mês de dezembro."                        ,"T72_INDAPU = '2' AND T72_ATIVO = '1' AND T72.D_E_L_E_T_ = ''"     ,"1"})

    // S-1299     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                      TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                              FILTRO                                                              STATUS
    aAdd( aBody, {""      ,"000011" ,"001"  ,"1"    ,"Apuração Mensal"                                          ,"CUO"  ,"CUO_PERAPU" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao mês de referência do evento."  ,"CUO_INDAPU = '1' AND CUO_ATIVO = '1' AND CUO.D_E_L_E_T_ = ''"     ,"1"})
    aAdd( aBody, {""      ,"000011" ,"002"  ,"2"    ,"Apuração Anual (13º salário, gratificação natalina etc.)" ,"CUO"  ,"CUO_PERAPU" ,"20" ,"12"   ,"Até o dia 20 do mês de dezembro do ano a que se refere."          ,"CUO_INDAPU = '2' AND CUO_ATIVO = '1' AND CUO.D_E_L_E_T_ = ''"     ,"1"})

    // S-1300     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                                                  TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                                  FILTRO                                                              STATUS
    aAdd( aBody, {""      ,"000012" ,"001"  ,"1"    ,"Empresa urbanas que obteve registro ou a licença para o exercício da respectiva atividade"                                            ,"T3Z"  ,"T3Z_PERAPU" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao que for obtido o registro ou a licença para o exercício da respectiva atividade."  ,"MONTH(T3Z_PERAPU + 1) > 1 AND T3Z_ATIVO = '1' AND T3Z.D_E_L_E_T_= ''" ,"1"})
    aAdd( aBody, {""      ,"000012" ,"002"  ,"2"    ,"Empresas urbanas em atividade no mês de janeiro"                                                                                      ,"T3Z"  ,"T3Z_PERAPU" ,"15" ,"2"    ,"Até o dia 15 de fevereiro de cada ano."                                                                               ,"MONTH(T3Z_PERAPU + 1) = 1 AND T3Z_ATIVO = '1' AND T3Z.D_E_L_E_T_= ''" ,"1"})
    aAdd( aBody, {""      ,"000012" ,"003"  ,"2"    ,"Envio do evento pelos empregadores rurais, relativo à contribuição sindical prevista no Decreto-lei nº 1.166, de 15 de abril de 1971" ,"T3Z"  ,"T3Z_PERAPU" ,"15" ,"10"   ,"Até o dia 15 de outubro de cada ano."                                                                                 ,"T3Z_ATIVO = '1' AND T3Z.D_E_L_E_T_ = ''" ,"1"})

    // S-2190     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                                      TABREF  CMDPREF       DIA MESESP  DSCPRZ                                            FILTRO                                      STATUS                                                                           
    aAdd( aBody, {""      ,"000013" ,"001"  ,"3"    ,"Dia do início da prestação do serviço pelo trabalhador admitido."                                                         ,"T3A"  ,"T3A_DTADMI" ,"" ,""     ,"Até o final do dia imediatamente anterior."     ,"T3A_ATIVO = '1' AND T3A.D_E_L_E_T_= ''"   ,"1"})
    aAdd( aBody, {""      ,"000013" ,"002"  ,"5"    ,"Admissão de empregado na data do início da obrigatoriedade de envio dos eventos não periódicos ao eSocial ( MV_TAFININ ).","T3A"  ,"T3A_DTADMI" ,"" ,""     ,"Até o próprio dia da admissão."                 ,"T3A_ATIVO = '1' AND T3A.D_E_L_E_T_ = ''"  ,"1"})

    // S-2200     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                                                                                                  TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                          FILTRO                                              STATUS
    aAdd( aBody, {""      ,"000014" ,"001"  ,"4"    ,"Vínculos iniciados até o último dia do mês anterior à essa obrigatoriedade ( MV_TAFININ )."                                                                                           ,"CUP"  ,"CUP_DTADMI" ,""   ,""     ,"Até o último dia do mês subsequente ao do início da obrigatoriedade de envio dos eventos não periódicos."     ,"CUP.D_E_L_E_T_ = ''"                              ,"1"})
    aAdd( aBody, {""      ,"000014" ,"002"  ,"3"    ,"Início da prestação dos serviços para os empregados admitidos a partir do dia seguinte ao início da obrigatoriedade de envio dos eventos não periódicos ao eSocial  ( MV_TAFININ )."  ,"CUP"  ,"CUP_DTADMI" ,""   ,""     ,"Até o dia imediatamente anterior ao do início da prestação dos serviços."                                     ,"CUP.D_E_L_E_T_ = ''"                              ,"1"})
    aAdd( aBody, {""      ,"000014" ,"003"  ,"1"    ,"Sucessão trabalhista."                                                                                                                                                                ,"CUP"  ,"CUP_DTADMI" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao da ocorrência."                                                            ,"CUP_INSANT != '' AND CUP.D_E_L_E_T_= ''"          ,"1"})
    aAdd( aBody, {""      ,"000014" ,"004"  ,"1"    ,"Empregador fizer a opção de enviar as informações preliminares de admissão por meio do evento S- 2190 – Admissão do Trabalhador – Registro Preliminar"                                ,"CUP"  ,"CUP_DTADMI" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao da ocorrência."                                                            ,"CUP_DTADMI < CUP_DTRANS AND CUP.D_E_L_E_T_ = ''"  ,"1"})
    aAdd( aBody, {""      ,"000014" ,"005"  ,"5"    ,"Empregados admitidos na data do início da obrigatoriedade de envio dos eventos não periódicos ao eSocial."                                                                            ,"CUP"  ,"CUP_DTADMI" ,""   ,""     ,"No dia do início da prestação dos serviços."                                                                  ,"CUP.D_E_L_E_T_ = ''"                              ,"1"})
    aAdd( aBody, {""      ,"000014" ,"006"  ,"1"    ,"Entrada em exercício de servidor estatutário, independentemente do regime previdenciário ao qual ele esteja vinculado."                                                               ,"CUP"  ,"CUP_DTEXER" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao da entrada em exercício de servidor estatutário."                          ,"CUP_TPREGT = '2' AND CUP.D_E_L_E_T_ = ''"         ,"1"})

    // S-2205     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                  TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                   FILTRO                                     STATUS                                                              
    aAdd( aBody, {""      ,"000015" ,"001"  ,"1"    ,"Data da ocorrência."  ,"T1U"  ,"T1U_DTALT" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao mês de referência."  ,"T1U_ATIVO = '1' AND T1U.D_E_L_E_T_= ''"  ,"1"})

    // S-2206     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                               TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                    FILTRO                                     STATUS                         
    aAdd( aBody, {""      ,"000016" ,"001"  ,"1"    ,"Data da ocorrência."              ,"T1V"  ,"T1V_DTALT"  ,"15" ,""     ,"Até o dia 15 do mês subsequente ao mês de referência."                  ,"T1V_ATIVO = '1' AND T1V.D_E_L_E_T_= ''"      ,"1"})
    aAdd( aBody, {""      ,"000016" ,"002"  ,"7"    ,"Prorrogação prazo Determinado."   ,"T1V"  ,"T1V_DTTERM" ,""   ,""     ,"No dia seguinte ao da prorrogação de contrato por prazo determinado."   ,"T1V_ATIVO = '1' AND T1V.D_E_L_E_T_= ''"      ,"1"})

    // S-2210     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                  TABREF  CMDPREF       DIA MESESP  DSCPRZ                                                    FILTRO                                                          STATUS                                                                  
    aAdd( aBody, {""      ,"000017" ,"001"  ,"7"    ,"Data da ocorrência."  ,"CM0"  ,"CM0_DTACID" ,"" ,""     ,"Até o primeiro dia útil seguinte ao da ocorrência."     ,"CM0_ATIVO = '1' AND CM0.D_E_L_E_T_= ''"                       ,"1"})
    aAdd( aBody, {""      ,"000017" ,"002"  ,"5"    ,"Caso de Morte."       ,"CM0"  ,"CM0_DTACID" ,"" ,""     ,"Deve ser registrada de imediato."                       ,"CM0_TPCAT = '3' AND CM0_ATIVO = '1' AND CM0.D_E_L_E_T_ = ''"  ,"1"})

    // S-2220     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                  TABREF  CMDPREF      DIA   MESESP  DSCPRZ                                                           FILTRO                                        STATUS                                                        
    aAdd( aBody, {""      ,"000018" ,"001"  ,"1"    ,"Data da ocorrência."  ,"C8B"  ,"C8B_DTASO" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao da realização do exame."    ,"C8B_ATIVO = '1' AND C8B.D_E_L_E_T_ = ''"    ,"1"})

    // S-2221     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                  TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                           FILTRO                                     STATUS                
    aAdd( aBody, {""      ,"000019" ,"001"  ,"1"    ,"Data da ocorrência."  ,"V3B"  ,"V3B_DTEXAM" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao da obtenção do resultado."  ,"V3B_ATIVO = '1' AND V3B.D_E_L_E_T_= ''"  ,"1"})

    // S-2230     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                                                                                                                                                                                  TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                          FILTRO                                                                                                                                  STATUS
    aAdd( aBody, {""      ,"000020" ,"001"  ,"1"    ,"Afastamento temporário ocasionado por acidente de trabalho ou doença decorrente do trabalho com duração não superior a 15 (quinze) dias."                                                                                                                             ,"CM6"  ,"CM6_DTAFAS" ,"15" ,""     ,"Até o dia 15 do mês subsequente da ocorrência."                               ,"CM6_EVENTO != 'R' AND CM6_EVENTO != 'F' AND (CM6_INFMTV = '2' OR CM6_INFMTV = '') AND C8N_CODIGO = '01' AND CM6_ATIVO = '1' AND CM6.D_E_L_E_T_= ''"                            ,"1"})
    aAdd( aBody, {""      ,"000020" ,"002"  ,"1"    ,"Afastamento temporário ocasionado por acidente de qualquer natureza ou doença não relacionada ao trabalho, com duração entre 3 (três) e 15 (quinze) dias."                                                                                                            ,"CM6"  ,"CM6_DTAFAS" ,"15" ,""     ,"Até o dia 15 do mês subsequente da ocorrência."                               ,"CM6_EVENTO != 'R' AND CM6_EVENTO != 'F' AND (CM6_INFMTV = '2' OR CM6_INFMTV = '') AND C8N_CODIGO = '03' AND CM6_ATIVO = '1' AND CM6.D_E_L_E_T_= ''"                            ,"1"})
    aAdd( aBody, {""      ,"000020" ,"003"  ,"6"    ,"Afastamento temporário ocasionado por acidente de trabalho, acidente de qualquer natureza, ou doença com duração superior a 15 (quinze) dias"                                                                                                                         ,"CM6"  ,"CM6_DTAFAS" ,"16" ,""     ,"Até o 16º dia da ocorrência."                                                 ,"CM6_EVENTO != 'R' AND CM6_EVENTO != 'F' AND (CM6_INFMTV = '2' OR CM6_INFMTV = '') AND C8N_CODIGO = '01' AND CM6_ATIVO = '1' AND CM6.D_E_L_E_T_ = ''"                            ,"1"})
    aAdd( aBody, {""      ,"000020" ,"004"  ,"6"    ,"Afastamentos temporários ocasionados pelo mesmo acidente ou doença, que ocorrerem dentro do prazo de 60 (sessenta) dias e totalizar, no somatório dos tempos, duração superior a 15 (quinze) dias, independentemente da duração individual de cada afastamento."      ,"CM6"  ,"CM6_DTAFAS" ,"16" ,""     ,"Devem ser enviados, isoladamente, até o 16º dia do afastamento."              ,"CM6_EVENTO != 'R' AND CM6_EVENTO != 'F' AND C8N_CODIGO = '01' AND CM6_INFMTV = '1' AND CM6_ATIVO = '1' AND CM6.D_E_L_E_T_ = ''"                                                                         ,"1"})
    aAdd( aBody, {""      ,"000020" ,"005"  ,"1"    ,"Demais afastamentos."                                                                                                                                                                                                                                                 ,"CM6"  ,"CM6_DTAFAS" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao da ocorrência."                            ,"CM6_EVENTO != 'R' AND CM6_EVENTO != 'F' AND CM6_INFMTV != '1' AND (C8N_CODIGO != '03' AND C8N_CODIGO != '01' AND C8N_CODIGO != '34') AND CM6_ATIVO = '1' AND CM6.D_E_L_E_T_ = ''"                                                                                              ,"1"})
    aAdd( aBody, {""      ,"000020" ,"006"  ,"1"    ,"Alteração de afastamento."                                                                                                                                                                                                                                            ,"CM6"  ,"CM6_DTAFAS" ,"15" ,""     ,"Até o dia 15 do mês subsequente à competência em que ocorreu a alteração."    ,"CM6_EVENTO = 'R' AND CM6_ATIVO = '1' AND CM6.D_E_L_E_T_ = ''"                                                                         ,"1"})
    aAdd( aBody, {""      ,"000020" ,"007"  ,"1"    ,"Término de afastamento."                                                                                                                                                                                                                                              ,"CM6"  ,"CM6_DTFAFA" ,"15" ,""     ,"Até o dia 15 do mês subsequente à competência em que ocorreu a alteração."    ,"CM6_EVENTO = 'F' AND CM6_ATIVO = '1' AND CM6.D_E_L_E_T_ = ''"                                                                         ,"1"})
    aAdd( aBody, {""      ,"000020" ,"008"  ,"6"    ,"Trabalhador avulso afastado pelo código 34 da Tabela 18 (Inatividade do trabalhador avulso (portuário ou não portuário) por período superior a 90 dias)."                                                                                                             ,"CM6"  ,"CM6_DTAFAS" ,"91" ,""     ,"O evento deve ser enviado a partir do 91º dia de inatividade."                ,"CM6_EVENTO != 'R' AND CM6_EVENTO != 'F' AND C8N_CODIGO = '34' AND CM6_ATIVO = '1' AND CM6.D_E_L_E_T_ = ''"                                                                        ,"1"})

    // S-2240     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                              TABREF  CMDPREF      DIA   MESESP  DSCPRZ                                                                                                                       FILTRO                                     STATUS                
    aAdd( aBody, {""      ,"000021" ,"001"  ,"1"    ,"Ingresso/admissão do trabalhor."                  ,"CM9"  ,"CM9_DTINI" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao início da obrigatoriedade dos eventos de SST ou do ingresso/admissão do trabalhor."     ,"CM9_ATIVO = '1' AND CM9.D_E_L_E_T_ = ''" ,"1"})
    aAdd( aBody, {""      ,"000021" ,"002"  ,"1"    ,"Alterações da informação inicial."                ,"CM9"  ,"CM9_DTALT" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao início da obrigatoriedade dos eventos de SST ou do ingresso/admissão do trabalhor."     ,"CM9_ATIVO = '1' AND CM9.D_E_L_E_T_ = ''" ,"1"})

    // S-2245     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                          TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                      FILTRO                                                                          STATUS                
    aAdd( aBody, {""      ,"000022" ,"001"  ,"1"    ,"Treinamento, capacitação ou exercício simulado."                                              ,"V3C"  ,"V3C_DTTCAP" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao da finalização do treinamento, capacitação ou exercício simulado."     ,"V3C_ATIVO = '1' AND V3C.D_E_L_E_T_= ''"                                       ,"1"})
    aAdd( aBody, {""      ,"000022" ,"002"  ,"1"    ,"Registro de autorização de intervenção em instalações elétricas e em máquinas e equipamentos.","V3C"  ,"V3C_DTTCAP" ,"15" ,""     ,"Até o dia 15 de mês subsequente à autorização."                                                           ,"V2M_CODIGO IN ('1006', '1207') AND V3C_ATIVO = '1' AND V3C.D_E_L_E_T_ = ''"   ,"1"})

    // S-2250     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                      TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                    FILTRO                                        STATUS                
    aAdd( aBody, {""      ,"000023" ,"001"  ,"6"    ,"Até 10 (dez) dias de sua comunicação."    ,"CM8"  ,"CM8_DTAVIS" ,"10" ,""     ,"Até 10 (dez) dias de sua comunicação."  ,"CM8_ATIVO = '1' AND CM8.D_E_L_E_T_= ''"     ,"1"})

    // S-2260     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                  TABREF  CMDPREF       DIA MESESP  DSCPRZ                                                                                        FILTRO                                      STATUS                
    aAdd( aBody, {""      ,"000024" ,"001"  ,"3"    ,"Prestação de serviços para a qual o empregado está sendo convocado."  ,"T87"  ,"T87_DTINIP" ,"" ,""     ,"Antes do início da prestação de serviços para a qual o empregado está sendo convocado."     ,"T87_ATIVO = '1' AND T87.D_E_L_E_T_= ''"   ,"1"})

    // S-2298     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                          TABREF  CMDPREF       DIA  MESESP  DSCPRZ                                                           FILTRO                                    STATUS                
    aAdd( aBody, {""      ,"000025" ,"001"  ,"1"    ,"Ocorrência de reintegração."  ,"CMF"  ,"CMF_DTRET" ,"15" ,""     ,"Até o dia 15 do mês seguinte a que se refere a reintegração."  ,"CMF_ATIVO = '1' AND CMF.D_E_L_E_T_= ''" ,"1"})

    // S-2299     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                          TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                  FILTRO                                                              STATUS                
    aAdd( aBody, {""      ,"000026" ,"001"  ,"6"    ,"Desligamento de empregados."                                                  ,"CMD"  ,"CMD_DTDESL" ,"10" ,""     ,"Até 10 (dez) dias seguintes à data do desligamento."  ,"CMD_TPINSC = '' AND CUP_TPREGT <> '2' AND CMD_ATIVO = '1' AND CMD.D_E_L_E_T_= ''"                           ,"1"})
    aAdd( aBody, {""      ,"000026" ,"002"  ,"1"    ,"Servidores de regime jurídico estatutário e regime administrativo especial."  ,"CMD"  ,"CMD_DTDESL" ,"15" ,""     ,"Até o dia 15 do mês subsequente."                     ,"CUP_TPREGT = '2' AND CMD_ATIVO = '1' AND CMD.D_E_L_E_T_= ''"      ,"1"})
    aAdd( aBody, {""      ,"000026" ,"003"  ,"1"    ,"Desligamento por sucessão."                                                   ,"CMD"  ,"CMD_DTDESL" ,"15" ,""     ,"Até o dia 15 do mês seguinte ao do desligamento."     ,"CMD_TPINSC != '' AND CMD_ATIVO = '1' AND CMD.D_E_L_E_T_= ''"      ,"1"})

    // S-2300     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                                                          TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                                                          FILTRO                                                              STATUS                
    aAdd( aBody, {""      ,"000027" ,"001"  ,"1"    ,"Trabalhadores que iniciaram suas atividades após início da obrigatoriedade de envio dos eventos não periódicos ao eSocial ( MV_TAFININ )."    ,"C9V"  ,"C9V_DTINIV" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao da sua ocorrência."                                                                                        ,"C9V_NOMEVE = 'S2300' AND C9V_ATIVO = '1' AND C9V.D_E_L_E_T_ = ''" ,"1"})
    aAdd( aBody, {""      ,"000027" ,"002"  ,"4"    ,"Trabalhadores que iniciaram suas atividades antes do início da obrigatoriedade de envio dos eventos não periódicos ao eSocial ( MV_TAFININ ).","C9V"  ,"C9V_DTINIV" ,""   ,""     ,"Até o último dia do mês subsequente ao do início dessa obrigatoriedade."  ,"C9V_NOMEVE = 'S2300' AND C9V_ATIVO = '1' AND C9V.D_E_L_E_T_ = ''" ,"1"})

    // S-2306     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                  TABREF  CMDPREF      DIA   MESESP  DSCPRZ                            FILTRO                                     STATUS                
    aAdd( aBody, {""      ,"000028" ,"001"  ,"1"    ,"Ocorrência de alteração contratual."  ,"T0F"  ,"T0F_DTALT" ,"15" ,""     ,"Até o dia 15 do mês seguinte."  ,"T0F_ATIVO = '1' AND T0F.D_E_L_E_T_ = ''" ,"1"})

    // S-2399     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                      TABREF  CMDPREF       DIA   MESESP  DSCPRZ                            FILTRO                                     STATUS                                                                                          
    aAdd( aBody, {""      ,"000029" ,"001"  ,"1"    ,"Ocorrência de desligamento de trabalhador sem vínculo."   ,"T92"  ,"T92_DTERAV" ,"15" ,""     ,"Até o dia 15 do mês seguinte."  ,"T92_ATIVO = '1' AND T92.D_E_L_E_T_ = ''" ,"1"})

    // S-2231     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                      TABREF  CMDPREF       DIA   MESESP  DSCPRZ                            FILTRO                                     STATUS                                                                                          
    aAdd( aBody, {""      ,"000030" ,"001"  ,"1"    ,"Data da ocorrência."  ,"V72"  ,"V72_DTINIC" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao mês de referência."  ,"V72_DTTERM = '' AND V72_ATIVO = '1' AND V72.D_E_L_E_T_= ''"  ,"1"})
    aAdd( aBody, {""      ,"000030" ,"002"  ,"1"    ,"Data da ocorrência."  ,"V72"  ,"V72_DTTERM" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao mês de referência."  ,"V72_DTINIC = '' AND V72_ATIVO = '1' AND V72.D_E_L_E_T_= ''"  ,"1"})

    // S-2400     FILIAL   ID        ITEM    MDCPRZ  CRTAPU                                                                                                              TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                                                                                 FILTRO                                                           STATUS 
    aAdd( aBody, {""      ,"000031" ,"001"  ,"1"    ,"Cadastro dos beneficiários do sistema de previdência dos regimes próprios."                                       ,"V73"  ,"V73_DTINIC" ,"15" ,""     ,"Até o dia 15 (quinze) do mês subsequente ao da data de concessão do benefício."                                                                                      ,"V73_DTALTE = '' AND V73_ATIVO = '1' AND V73.D_E_L_E_T_= ''"     ,"1"})

    // S-2405     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                               TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                                                                                 FILTRO                                                           STATUS 
    aAdd( aBody, {""      ,"000032" ,"001"  ,"1"    ,"Alterações de dados cadastrais dos beneficiários do sistema de previdência dos regimes próprios."                 ,"V73"  ,"V73_DTALTE" ,"15" ,""     ,"Até o dia 15 do mês subsequente ao mês de referência."                                                                                                               ,"V73_DTALTE <> '' AND V73_ATIVO = '1' AND V73.D_E_L_E_T_= ''"    ,"1"})

    // S-2410     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                               TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                                                                                 FILTRO                                                           STATUS 
    aAdd( aBody, {""      ,"000033" ,"001"  ,"1"    ,"Cadastro de Benefícios do sistema de previdência dos regimes próprios."                                            ,"V75"  ,"V75_DTINBE" ,"15" ,""     ,"Até o dia 15 (quinze) do mês subsequente ao da data de concessão do benefício."                                                                                     ,"V75_ATIVO = '1' AND V75.D_E_L_E_T_= ''"                          ,"1"})

    // S-2416     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                               TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                                                                                 FILTRO                                                           STATUS 
    aAdd( aBody, {""      ,"000034" ,"001"  ,"1"    ,"Alterações de dados no Benefício."                                                                                ,"V76"  ,"V76_DALTBE" ,"15" ,""     ,"Até o dia 15 (quinze) do mês subsequente ao da competência informada no evento."                                                                                     ,"V76_ATIVO = '1' AND V76.D_E_L_E_T_= ''"                          ,"1"})

    // S-2418     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                               TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                                                                                 FILTRO                                                           STATUS 
    aAdd( aBody, {""      ,"000035" ,"001"  ,"1"    ,"Reativação do benefício previamente cessado pelo Órgão Público."                                                  ,"V77"  ,"V77_DTREAT" ,"15" ,""     ,"Até o dia 15 (quinze) do mês seguinte a que se refere a reativação, desde que não ultrapasse a data do envio do evento S-1207, para o beneficiário a que se refere." ,"V77_ATIVO = '1' AND V77.D_E_L_E_T_= ''"                         ,"1"})

    // S-2420     FILIAL  ID        ITEM    MDCPRZ  CRTAPU                                                                                                               TABREF  CMDPREF       DIA   MESESP  DSCPRZ                                                                                                                                                                 FILTRO                                                           STATUS 
    aAdd( aBody, {""      ,"000036" ,"001"  ,"1"    ,"Informações utilizadas para a cessação da obrigatoriedade de pagamento dos benefícios."                           ,"V78"  ,"V78_DTTERM" ,"15" ,""     ,"Até o dia 15 (quinze) do mês seguinte a cessação do benefício."                                                                                                       ,"V78_ATIVO = '1' AND V78.D_E_L_E_T_= ''"                        ,"1"})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PutV71
Rotina de Carga dos valores na Tabela V71
			
@author Fabio Santos de Mendonca
@since 21/07/2021
@version 1.0
@Param aHeader, array, Campos da Tabela
@Param aBody, array, Registros da Tabela
@Return	aRet, Array com estrutura de Campos e conteúdo da Tabela
/*/
//-------------------------------------------------------------------
Static Function PutV71(aHeader, aBody)

    aHeader   := {}
    aBody     := {}

    aAdd( aHeader, "V71_FILIAL" )
    aAdd( aHeader, "V71_ID"     )
    aAdd( aHeader, "V71_ITEMTB" )
    aAdd( aHeader, "V71_ITEM" )
    aAdd( aHeader, "V71_TBJOIN" )
    aAdd( aHeader, "V71_JOIN"   )
    
    // ================================================================= S-1300
    // S-1300-001 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000012" ,"001"  ,"001"  ,"C1E"    ,"C1E_FILTAF = T3Z_FILIAL AND (C1E_PRDRUR = '2' OR C1E_PRDRUR = '') AND C1E_ATIVO = '1' AND C1E.D_E_L_E_T_ = ''" })      
    // S-1300-002 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN 
    aAdd( aBody, {""      ,"000012" ,"002"  ,"001"  ,"C1E"    ,"C1E_FILTAF = T3Z_FILIAL AND (C1E_PRDRUR = '2' OR C1E_PRDRUR = '') AND C1E_ATIVO = '1' AND C1E.D_E_L_E_T_ = ''"})      
    // S-1300-003 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN 
    aAdd( aBody, {""      ,"000012" ,"003"  ,"001"  ,"C1E"    ,"C1E_FILTAF = T3Z_FILIAL AND C1E_PRDRUR = '1' AND C1E_ATIVO = '1' AND C1E.D_E_L_E_T_ = ''"})

    // ================================================================= S-2190
    // S-2190-001 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000013" ,"002"  ,"001"  ,"SX6"    ,"X6_VAR = 'MV_TAFININ' AND X6_CONTEUD < T3A_DTADMI AND SX6.D_E_L_E_T_ = ''"})

    // ================================================================= S-2200
    // S-2200-001 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000014" ,"001"  ,"001"  ,"SX6"    ,"X6_VAR = 'MV_TAFININ' AND X6_CONTEUD > CUP_DTADMI AND SX6.D_E_L_E_T_ = ''"})
    // S-2200-002 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN 
    aAdd( aBody, {""      ,"000014" ,"002"  ,"001"  ,"SX6"    ,"X6_VAR = 'MV_TAFININ' AND X6_CONTEUD < CUP_DTADMI AND SX6.D_E_L_E_T_ = ''"})
    // S-2200-005 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN 
    aAdd( aBody, {""      ,"000014" ,"005"  ,"001"  ,"SX6"    ,"X6_VAR = 'MV_TAFININ' AND X6_CONTEUD = CUP_DTADMI AND SX6.D_E_L_E_T_ = ''"})
    // S-2200-004 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN 
    aAdd( aBody, {""      ,"000014" ,"004"  ,"001"  ,"C9V"    ,"C9V_FILIAL = CUP_FILIAL AND C9V_ID  = CUP_ID AND C9V_VERSAO = CUP_VERSAO AND C9V_NOMEVE = CUP_NOMEVE AND C9V_ATIVO = '1' AND C9V.D_E_L_E_T_ = ''"})
    aAdd( aBody, {""      ,"000014" ,"004"  ,"002"  ,"T3A"    ,"T3A_FILIAL = C9V_FILIAL AND  T3A_CPF  = C9V_CPF AND  T3A_DTNASC = C9V_DTNASC AND  T3A_DTADMI = CUP_DTADMI AND  T3A_ATIVO = '1' AND  T3A.D_E_L_E_T_ = ''"})

    // ================================================================= S-2230
    // S-2230-001 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000020" ,"001"  ,"001"  ,"C8N"    ,"C8N_ID = CM6_MOTVAF AND (C8N_VALIDA = '' OR C8N_VALIDA > GETDATE()) AND C8N.D_E_L_E_T_ = ''"})
    // S-2230-002 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000020" ,"002"  ,"001"  ,"C8N"    ,"C8N_ID = CM6_MOTVAF AND (C8N_VALIDA = '' OR C8N_VALIDA > GETDATE()) AND C8N.D_E_L_E_T_ = ''"})
    // S-2230-003 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000020" ,"003"  ,"001"  ,"C8N"    ,"C8N_ID = CM6_MOTVAF AND (C8N_VALIDA = '' OR C8N_VALIDA > GETDATE()) AND C8N.D_E_L_E_T_ = ''"})
    // S-2230-004 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN
    aAdd( aBody, {""      ,"000020" ,"004"  ,"001"  ,"C8N"    ,"C8N_ID = CM6_MOTVAF AND (C8N_VALIDA = '' OR C8N_VALIDA > GETDATE()) AND C8N.D_E_L_E_T_ = ''"})
    // S-2230-008 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000020" ,"008"  ,"001"  ,"C8N"    ,"C8N_ID = CM6_MOTVAF AND (C8N_VALIDA = '' OR C8N_VALIDA > GETDATE()) AND C8N.D_E_L_E_T_ = ''"})

    // ================================================================= S-2245
    // S-2245-002 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000022" ,"002"  ,"001"  ,"V2M"    ,"V2M_ID = V3C_CODTCA AND (V2M_VALIDA = '' OR V2M_VALIDA > GETDATE()) AND V2M.D_E_L_E_T_ = ''"})

    // ================================================================= S-2300
    // S-2300-001 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000027" ,"001"  ,"001"  ,"SX6"    ,"X6_VAR = 'MV_TAFININ' AND X6_CONTEUD < C9V_DTINIV AND SX6.D_E_L_E_T_ = ''"})
    // S-2300-002 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN   
    aAdd( aBody, {""      ,"000027" ,"002"  ,"001"  ,"SX6"    ,"X6_VAR = 'MV_TAFININ' AND X6_CONTEUD > C9V_DTINIV AND SX6.D_E_L_E_T_ = ''"})

    // ================================================================= S-1200
    // S-1200-001 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN
    aAdd( aBody, {""      ,"000002" ,"001"  ,"001"  ,"C1E"    ,"C1E_FILTAF = C91_FILIAL AND C1E_ATIVO = '1' AND C1E_CLAFIS <> '000014' AND C1E.D_E_L_E_T_ = ''" })
    aAdd( aBody, {""      ,"000002" ,"002"  ,"001"  ,"C1E"    ,"C1E_FILTAF = C91_FILIAL AND C1E_ATIVO = '1' AND C1E_CLAFIS <> '000014' AND C1E.D_E_L_E_T_ = ''" })
    aAdd( aBody, {""      ,"000002" ,"003"  ,"001"  ,"C1E"    ,"C1E_FILTAF = C91_FILIAL AND C1E_ATIVO = '1' AND C1E_CLAFIS = '000014' AND C1E.D_E_L_E_T_ = ''" })

    // ================================================================= S-1260
    // S-1260-001 FILIAL   ID       ITEMTB  ITEM    TBJOIN    JOIN 
    aAdd( aBody, {""      ,"000007" ,"001"  ,"001"  ,"C1E"    ,"C1E_FILTAF = T1M_FILIAL AND C1E_ATIVO = '1' AND C1E_CLAFIS <> '000014' AND C1E.D_E_L_E_T_ = ''" })
    aAdd( aBody, {""      ,"000007" ,"002"  ,"001"  ,"C1E"    ,"C1E_FILTAF = T1M_FILIAL AND C1E_ATIVO = '1' AND C1E_CLAFIS = '000014' AND C1E.D_E_L_E_T_ = ''" })  

Return
