#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA220.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA220()  

Rotina para realizar a configuração de quais CFOPs e quais CST deverão
fazer parte da composição do coeficiente de apropriação do CIAP.
Deverá ser definido um operando, e quais CFOPS e CST que compoem este operando

@author Erick G Dias
@since 08/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA220()

Local   oBrowse := Nil
Local   oSay
Local   aOper   := {}

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F1F")
    //Verifica se existe ao menos uma linha na F1F, se não existir fará a carga inicial
    If !F1F->(DbSeek(xFilial("F1F")))
        Begin Transaction
        FwMsgRun(,{|oSay| Fsa220CI(oSay,.F.,aOper) },STR0006,"")//"Processando carga inicial de CFOPs e CSTs"
        End Transaction	
    EndIF
    
    //Verifica se existe os novos operandos 09 e 10, caso não exista, exetua a carga inicial apenas deles
    If !F1F->(DbSeek(xFilial("F1F")+"09")) .And. !F1F->(DbSeek(xFilial("F1F")+"10") ) 
        aAdd (aOper, {"09", "10"})

        Begin Transaction
        FwMsgRun(,{|oSay| Fsa220CI(oSay,.F., aOper) },STR0006,"")//"Processando carga inicial de CFOPs e CSTs"
        End Transaction	
    EndIF
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F1F")
    oBrowse:SetDescription(STR0001)//"Configuração do Coeficiente do CIAP"
    oBrowse:Activate()    
    
Else
    Help("",1,"Help","Help",STR0002,1,0)//"Dicionário desatualizado, favor verificar atualização do sistema" 
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 08/03/2019
@version P12.1.23

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA220" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Funcao generica MVC do model

@author Erick G Dias
@since 08/03/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai corresponndente ao cabeçalho 
Local oCabecalho := FWFormStruct(1, "F1F")

//Estrutura Filho correspondente a tabela de CFOP e CST
Local oCFOPCST := FWFormStruct(1, "F1G")

//Instanciando o modelo
oModel := MPFormModel():New('FISA220')

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA220",, oCabecalho)

//Adiciona o Grid ao modelo
oModel:AddGrid('FISA220CFOPCST', 'FISA220', oCFOPCST)

//Grid não pode ser vazio...
oModel:GetModel('FISA220CFOPCST'):SetOptional(.F.)

//Não permite alterar o conteúdo do campo F20_CODIGO na edição
oCabecalho:SetProperty('F1F_OPERAN', MODEL_FIELD_WHEN, {|| (oModel:GetOperation() == MODEL_OPERATION_INSERT)})

//Define para não repetir o CFOP
oModel:GetModel('FISA220CFOPCST'):SetUniqueLine({'F1G_CFOP','F1G_CST'})

//Relacionamento entre as tabelas F1F cabeçalho com F1G CFOP e F1G_CST
oModel:SetRelation('FISA220CFOPCST', {{'F1G_FILIAL', 'xFilial("F1G")'},{'F1G_IDCAB', 'F1F_ID'}}, F1G->(IndexKey(1)))

//Validação do CFOP feita através do próprio MVC.
oCFOPCST:SetProperty('F1G_CFOP' , MODEL_FIELD_VALID, {||( VldCFOP(oModel) )})

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001)//"Configuração do Coeficiente do CIAP"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@author Erick G Dias
@since 08/03/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel := FWLoadModel("FISA220")

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F1F")
Local oCFOPCST   := FWFormStruct(2, "F1G")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formulários para interface
oView:AddField('VIEW_CAB'    , oCabecalho , 'FISA220')
oView:AddGrid('VIEW_CFOPCST' , oCFOPCST   , 'FISA220CFOPCST')

//Retira da view os campos de ID
oCabecalho:RemoveField('F1F_ID')
oCFOPCST:RemoveField('F1G_ID')
oCFOPCST:RemoveField('F1G_IDCAB')
oCFOPCST:RemoveField('F1G_OPERAN')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox('SUPERIOR', 20)
oView:CreateHorizontalBox('INFERIOR', 80)

//O formulário da interface será colocado dentro do container
oView:SetOwnerView('VIEW_CAB'      , 'SUPERIOR')
oView:SetOwnerView('VIEW_CFOPCST'  , 'INFERIOR')

//Colocando título do formulário
oView:EnableTitleView('VIEW_CAB'      , STR0001)//"Configuração para Coeficiente CIAP"
oView:EnableTitleView('VIEW_CFOPCST'  , STR0003)//"CFOP"

oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta as opções do combo da opção do operando

@author Erick G Dias
@since 08/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FSA220OP()
Local cRet	:= ""

cRet	:= '01=Saídas Tributadas;02=Dev. Saídas Tributadas;03=Saídas Não Tributadas;04=Dev. Saídas Não Tributadas;'
cRet	+= '05=Exportações;06=Dev. Exportações;07=Equiparadas a Exportação;08=Dev. Equiparadas a Exportação;09=Total de Saídas;10=Dev. Total de Saídas'

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA220VLOR
Função que monta as opções do combo da opção valor de origem

@author Erick G Dias
@since 08/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FSA220VLOR()
Local cRet := ""

cRet	:= '01=Valor Contábil;02=Valor da Mercadoria;03=Isentas;04=Outras;05=Base ICMS;06=Outras + Isentas;'
cRet	+= '07=Base ICMS + Outras;08=Base ICMS + Isentas;09=Base ICMS + Outras + Isentas'

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa220CI
Função que realizar a carga inicial automática dos CFOPS e CSTs nos operandos.

@author Erick G Dias
@since 14/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function Fsa220CI(oSay, lAutomato, aOper)

Local cIdOperando   := ""
Local cOperando     := ""
Local aCstTrib      := {"00", "20"} //CST Tributado Integralmente ou Redução de base de cálculo
Local aCstNTrib     := {"30", "40", "41", "50"} //CST Isenta, Não Tributada ou Suspenso
Local aCstSTTrib    := {"10", "70"} //CST Tributado com ST ou redução com ST
Local aCstSTNTrib   := {"60"} //CST CObrado anteriormente por ST
Local aCstExp       := {"41"} //CST Não tributado
Local aCFOPTrib     := {} //Array com CFOPS Tributados sem ST
Local aCFOPNTrib    := {} //Array com CFOPs não Tributados sem ST
Local aCFOPEXP      := {} //Array com CFOPs de Exportação
Local aCFOPEquip    := {} //Array com CFOPs de Venda equiparada a exportação
Local aDevTrib      := {} //Array com CFOPs de develução de operações tributadas sem ST
Local aDevNTrib     := {} //Array com CFOPs de develução de operações não tributadas sem ST
Local aDevExp       := {} //Array com CFOPS de devolução de exportação
Local aDevEquip     := {} //Array com CFOPs de devolução de exportação equiparada
Local aCFOPSTT      := {} //Array com CFOP Tributados com ST
Local aCFOPSTNT     := {} //Array com CFOP Não Tributados com ST
Local aDevSTT       := {} //Array de devolução de venda Tributada com ST
Local aDevSTNT      := {} //Array de devolução de venda não Tributada com ST
Local nX            := 0
Default lAutomato := .F.

If !lAutomato
    oSay:cCaption := (STR0007)//"Processando CFOPs e CSTs..."
    ProcessMessages()
EndIF

//-----------------------------------
//CFOP de Saídas Tributadas sem ST
//-----------------------------------
aAdd (aCFOPTrib, {"5101", "5102", "5103", "5104", "5105", "5106", "5109", "5110", "5111", "5112", "5113", "5114", "5115", "5116", "5117", "5118", "5119", "5120", "5122","5123",;
                  "5124", "5125", "5251", "5252", "5253", "5254", "5255", "5256", "5257", "5258", "5301", "5302", "5303", "5304", "5305", "5306", "5307", "5351", "5352", "5353",;
                  "5354", "5355", "5356", "5357", "5359", "5360", "5451", "5551", "5651", "5652", "5653", "5654", "5655", "5656", "5667", "5910",;
                  "5911", "5933", "5949", "6101", "6102", "6103", "6104", "6105", "6106", "6107", "6108", "6109", "6110", "6111", "6112", "6113", "6114", "6115", "6116", "6117",;
                  "6118", "6119", "6120", "6122", "6123", "6124", "6125", "6251", "6252", "6253", "6254", "6255", "6256", "6257", "6258", "6301", "6302", "6303", "6304", "6305",;
                  "6306", "6307", "6351", "6352", "6353", "6354", "6355", "6356", "6357", "6359", "6360", "6551", "6651", "6652", "6653", "6654",;
                  "6655", "6656", "6667", "6910", "6911", "6933", "6949"})

//-------------------------------------------
//CFOP de Saídas Tributadas com ST
//-------------------------------------------
aAdd (aCFOPSTT, {"5401", "5402", "6401","6402"})

//-----------------------------------------------
//CFOP de Devoluções de Saídas Tributadas sem ST
//-----------------------------------------------
aAdd (aDevTrib, {"1201", "1202", "1203", "1204", "1205", "1206", "1207", "1553", "1660", "1661", "1662", "2201", "2202", "2203", "2204", "2205", "2206", "2207",;
                 "2553", "2660", "2661", "2662"})

//-----------------------------------------------
//CFOP de Devoluções de Saídas Tributadas com ST
//-----------------------------------------------
aAdd (aDevSTT, {"1410", "2410"})

//-------------------------------------
//CFOP de Saídas Não Tributadas sem ST
//-------------------------------------
aAdd (aCFOPNTrib, {"5101", "5102", "5103", "5104", "5105", "5106", "5109", "5110", "5111", "5112", "5113", "5114", "5115", "5116", "5117", "5118", "5119", "5120", "5122","5123",;
                  "5124", "5125", "5251", "5252", "5253", "5254", "5255", "5256", "5257", "5258", "5301", "5302", "5303", "5304", "5305", "5306", "5307", "5351", "5352", "5353",;
                  "5354", "5355", "5356", "5357", "5359", "5360", "5451", "5551", "5651", "5652", "5653", "5654", "5655", "5656", "5667", "5910",;
                  "5911", "5932", "5933", "5949", "6101", "6102", "6103", "6104", "6105", "6106", "6107", "6108", "6109", "6110", "6111", "6112", "6113", "6114", "6115", "6116", "6117",;
                  "6118", "6119", "6120", "6122", "6123", "6124", "6125", "6251", "6252", "6253", "6254", "6255", "6256", "6257", "6258", "6301", "6302", "6303", "6304", "6305",;
                  "6306", "6307", "6351", "6352", "6353", "6354", "6355", "6356", "6357", "6359", "6360", "6551", "6651", "6652", "6653", "6654",;
                  "6655", "6656", "6667", "6910", "6911", "6932", "6933", "6949"})

//-------------------------------------
//CFOP de Saídas Não Tributadas som ST
//-------------------------------------
aAdd (aCFOPSTNT, {"5403", "5405", "6403","6405"})

//-----------------------------------------------
//CFOP de Devoluções Saídas Não Tributadas sem ST
//--------------------------------------------------
aAdd (aDevNTrib, {"1201", "1202", "1203", "1204", "1205", "1206", "1207", "1553", "1660", "1661", "1662", "2201", "2202", "2203", "2204", "2205", "2206", "2207",;
                 "2553", "2660", "2661", "2662"})  

//-----------------------------------------------
//CFOP de Devoluções Saídas Não Tributadas com ST
//-----------------------------------------------
aAdd (aDevSTNT, {"1411", "2411"})

//------------------
//Saídas Exportações
//------------------
aAdd (aCFOPEXP, {"7101", "7102", "7105", "7106", "7127", "7251", "7301", "7358", "7501", "7551", "7651","7654", "7667", "7949"})

//-----------------------------
//Devoluções Saídas Exportações
//-----------------------------
aAdd (aDevExp, {"3201","3202", "3205", "3206", "3207", "3211", "3503", "3553"})
//--------------------------------
//Saídas equiparadas a exportação
//--------------------------------
aAdd (aCFOPEquip, {"5501", "5502", "6501", "6502"})

//-------------------------------------------
//Devoluções Saídas equiparadas a exportação
//-------------------------------------------
aAdd (aDevEquip, {"1503", "1504", "2503","2504"})

If Empty( aOper )

    //--------------------------------------------------------------------------------------------
    //Saídas Tributadas
    //------------------------
    If !lAutomato
        oSay:cCaption := (STR0008)//"Processando CFOPs e CSTs Tributados"
        ProcessMessages()
    EndIF
    cOperando   := "01"
    cIdOperando := AddOperando(cOperando) 
    //Processa CST e CFOPS SEM ST
    ProcCfopCSt(aCstTrib, aCFOPTrib[1], "07"/*Base Cálculo + Outras*/, cOperando, cIdOperando)
    //Processa CST e CFOPS COM ST
    ProcCfopCSt(aCstSTTrib, aCFOPSTT[1], "07"/*Base Cálculo + Outras*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Devoluções Saídas Tributadas
    //------------------------
    If !lAutomato
        oSay:cCaption := (STR0009)//"Processando CFOPs e CSTs de Devoluções Tributadas"
        ProcessMessages()
    EndIF
    cOperando := "02"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de devolução SEM ST
    ProcCfopCSt(aCstTrib, aDevTrib[1], "07"/*Base Cálculo + Outras*/, cOperando, cIdOperando)
    //Processa os CSTs e CFOPS de devolução COM ST
    ProcCfopCSt(aCstSTTrib, aDevSTT[1], "07"/*Base Cálculo + Outras*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Saídas Não Tributadas
    //------------------------
    If !lAutomato
        oSay:cCaption := (STR0010)//"Processando CFOPs e CSTs Não Tributados"
        ProcessMessages()
    EndIF
    cOperando := "03"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS não tributados SEM ST
    ProcCfopCSt(aCstNTrib, aCFOPNTrib[1], "03"/*Isentas*/, cOperando, cIdOperando)
    //Processa os CSTs e CFOPS não tributados COM ST
    ProcCfopCSt(aCstSTNTrib, aCFOPSTNT[1], "03"/*Isentas*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Devoluções Saídas Não Tributadas
    //---------------------------------
    If !lAutomato
        oSay:cCaption := (STR0011)//"Processando CFOPs e CSTs de Devoluções Não Tributados"
        ProcessMessages()
    EndIF
    cOperando := "04"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS não tributados SEM ST
    ProcCfopCSt(aCstNTrib, aDevNTrib[1], "03"/*Isentas*/, cOperando, cIdOperando)
    //Processa os CSTs e CFOPS não tributados COM ST
    ProcCfopCSt(aCstSTNTrib, aDevSTNT[1], "03"/*Isentas*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Saídas Exportação
    //---------------------------------
    If !lAutomato
        oSay:cCaption := (STR0012)//"Processando CFOPs e CSTs de Exportação"
        ProcessMessages()
    Endif
    cOperando := "05"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de Exportação
    ProcCfopCSt(aCstExp, aCFOPEXP[1], "01"/*Valor Contábil*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------


    //--------------------------------------------------------------------------------------------
    //Devoluções Saídas Exportação
    //---------------------------------
    If !lAutomato
        oSay:cCaption := (STR0013)//"Processando CFOPs e CSTs de devoluções de Exportação"
        ProcessMessages()
    EndIF
    cOperando := "06"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de Exportação
    ProcCfopCSt(aCstExp, aDevExp[1], "01"/*Valor Contábil*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Saídas Equiparadas a Exportação
    //---------------------------------
    If !lAutomato
        oSay:cCaption := (STR0014)//"Processando CFOPs e CSTs Equiparados a Exportação"
        ProcessMessages()
    EndIF
    cOperando := "07"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de Equiparados a Exportação
    ProcCfopCSt(aCstExp, aCFOPEquip[1], "01"/*Valor Contábil*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Devoluções Equiparadas a Exportação
    //------------------------------------
    If !lAutomato
        oSay:cCaption := (STR0015)//"Processando CFOPs e CSTs Devoluções Equiparados a Exportação"
        ProcessMessages()
    EndIF
    cOperando := "08"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de Devolução Equiparados a Exportação
    ProcCfopCSt(aCstExp, aDevEquip[1], "01"/*Valor Contábil*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------

EndIf

If !Empty( aOper )
    For nX  := 1 to Len(aOper[1])
        cOperando   := AllTrim(aOper[1][nX])
        If cOperando == "09"
            //--------------------------------------------------------------------------------------------
            //Total de Saídas
            //------------------------
            If !lAutomato
                oSay:cCaption := (STR0016)//"Processando CFOPs e CSTs Total de saídas e Devoluções de Totais de Saídas"
                ProcessMessages()
            EndIF
            cIdOperando := AddOperando(cOperando) 
            //Processa CST e CFOPS SEM ST
            ProcCfopCSt(aCstTrib, aCFOPTrib[1], "01"/*Valor Contábil*/, cOperando, cIdOperando)
            //Processa CST e CFOPS COM ST
            ProcCfopCSt(aCstSTTrib, aCFOPSTT[1], "01"/*Valor Contábil*/, cOperando, cIdOperando)
        EndIf

        If cOperando == "10"
            //--------------------------------------------------------------------------------------------
            //Devolução Total de Saídas
            //------------------------
            If !lAutomato
                oSay:cCaption := (STR0016)//"Processando CFOPs e CSTs Total de saídas e Devoluções de Totais de Saídas"
                ProcessMessages()
            EndIF
            cIdOperando := AddOperando(cOperando) 
            //Processa os CSTs e CFOPS de devolução SEM ST
            ProcCfopCSt(aCstTrib, aDevTrib[1], "01"/*Valor Contábil*/, cOperando, cIdOperando)
            //Processa os CSTs e CFOPS de devolução COM ST
            ProcCfopCSt(aCstSTTrib, aDevSTT[1], "01"/*Valor Contábil*/, cOperando, cIdOperando)
        EndIf

    Next nX
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddOperando
Método que faz inclusão do operando

@author Erick G Dias
@since 14/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function AddOperando(cOperando)
Local cIdF1F    := ""

//Verifica se operando está preenchido e se não existe no banco
IF !Empty(cOperando) .AND. !F1F->(DbSeek(xFilial("F1F")+cOperando))
    //Inclui novo operando
    cIdF1F    := FWUUID("F1F")
    RecLock("F1F",.T.)
	F1F->F1F_FILIAL := xFilial("F1F")
	F1F->F1F_OPERAN   := cOperando
    F1F->F1F_ID       := cIdF1F
    F1F->(MsUnlock ())

EndIF

Return cIdF1F

//-------------------------------------------------------------------
/*/{Protheus.doc} AddCFOPCST
Função que faz a inclusão do CFOP, do CST e do valor de origem

@author Erick G Dias
@since 14/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function AddCFOPCST(cCFOP, cCST, cVlOrig, cOperando, cIdCab)

IF !Empty(cCFOP) .AND. !Empty(cCST) .AND. !Empty(cVlOrig) .AND. !Empty(cOperando) .AND. !Empty(cIdCab) .AND. !F1G->(DbSeek(xFilial("F1G")+cCFOP+cCST+cVlOrig+cOperando))
    //Inclui novo CFOP e CST
    RecLock("F1G",.T.)
	
    F1G->F1G_FILIAL := xFilial("F1G")
    F1G->F1G_ID     := FWUUID("F1G")
    F1G->F1G_IDCAB  := cIdCab
	F1G->F1G_CFOP   := cCFOP
    F1G->F1G_CST    := cCST
    F1G->F1G_VLORIG := cVlOrig
    F1G->F1G_OPERAN := cOperando

    F1G->(MsUnlock ())
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCfopCSt
Função auxiliar para processar cadastro da carga automática

@author Erick G Dias
@since 14/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function ProcCfopCSt(aCst, aCfop, cVlOrig, cOperando, cIdCab)

Local nCst  := 0
Local nCfop := 0

//Laço no array de CST
For nCst   := 1 to Len(aCst)
    //Laço no array de CFOP
    For nCfop:= 1 to Len(aCfop)
        AddCFOPCST(aCfop[nCfop] /*CFOP*/  , aCst[nCst] /*CST de ICMS*/ , cVlOrig /*Valor de Oritem*/, cOperando /*Operando*/, cIdCab/*Id do cabeçaho*/)
    Next nCont2

Next nCst

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCFOP
Função que terá a validação do CFOP.

@author Erick G Dias
@since 14/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function VldCFOP(oModel)
Local lRet      := .F.
Local cCFOP 	:= oModel:GetValue ('FISA220CFOPCST',"F1G_CFOP")
Local cIniCfop 	:= Substr(oModel:GetValue ('FISA220CFOPCST',"F1G_CFOP"),1,1)
Local cOperando := oModel:GetValue ('FISA220',"F1F_OPERAN")

//Permite CFOP vazio, equivalente a função Vazio()
If Empty(cCFOP)
    lRet := .T.

//Verifica se o CFOP existe
ElseIf SX5->( MsSeek ( xFilial('SX5') + "13" + cCFOP ) )
    //Se existir verificará se está digitando CFOP de saída para operando de saída e CFOP de entrada para operando de entrada
    If cOperando $ "01/03/05/07/09" .AND. cIniCfop $ "5/6/7"
        //Somente pode permitir CFOPS de saídas
        lRet := .T.
    ElseIf cOperando $ "02/04/06/08/10" .AND. cIniCfop $ "1/2/3"
        //Somente pode permtir CFOPS de entradas
        lRet := .T.    
    EndIF

EndIF

Return lRet