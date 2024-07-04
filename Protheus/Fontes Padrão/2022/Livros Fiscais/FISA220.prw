#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA220.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA220()  

Rotina para realizar a configura��o de quais CFOPs e quais CST dever�o
fazer parte da composi��o do coeficiente de apropria��o do CIAP.
Dever� ser definido um operando, e quais CFOPS e CST que compoem este operando

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
    //Verifica se existe ao menos uma linha na F1F, se n�o existir far� a carga inicial
    If !F1F->(DbSeek(xFilial("F1F")))
        Begin Transaction
        FwMsgRun(,{|oSay| Fsa220CI(oSay,.F.,aOper) },STR0006,"")//"Processando carga inicial de CFOPs e CSTs"
        End Transaction	
    EndIF
    
    //Verifica se existe os novos operandos 09 e 10, caso n�o exista, exetua a carga inicial apenas deles
    If !F1F->(DbSeek(xFilial("F1F")+"09")) .And. !F1F->(DbSeek(xFilial("F1F")+"10") ) 
        aAdd (aOper, {"09", "10"})

        Begin Transaction
        FwMsgRun(,{|oSay| Fsa220CI(oSay,.F., aOper) },STR0006,"")//"Processando carga inicial de CFOPs e CSTs"
        End Transaction	
    EndIF
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F1F")
    oBrowse:SetDescription(STR0001)//"Configura��o do Coeficiente do CIAP"
    oBrowse:Activate()    
    
Else
    Help("",1,"Help","Help",STR0002,1,0)//"Dicion�rio desatualizado, favor verificar atualiza��o do sistema" 
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

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

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai corresponndente ao cabe�alho 
Local oCabecalho := FWFormStruct(1, "F1F")

//Estrutura Filho correspondente a tabela de CFOP e CST
Local oCFOPCST := FWFormStruct(1, "F1G")

//Instanciando o modelo
oModel := MPFormModel():New('FISA220')

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA220",, oCabecalho)

//Adiciona o Grid ao modelo
oModel:AddGrid('FISA220CFOPCST', 'FISA220', oCFOPCST)

//Grid n�o pode ser vazio...
oModel:GetModel('FISA220CFOPCST'):SetOptional(.F.)

//N�o permite alterar o conte�do do campo F20_CODIGO na edi��o
oCabecalho:SetProperty('F1F_OPERAN', MODEL_FIELD_WHEN, {|| (oModel:GetOperation() == MODEL_OPERATION_INSERT)})

//Define para n�o repetir o CFOP
oModel:GetModel('FISA220CFOPCST'):SetUniqueLine({'F1G_CFOP','F1G_CST'})

//Relacionamento entre as tabelas F1F cabe�alho com F1G CFOP e F1G_CST
oModel:SetRelation('FISA220CFOPCST', {{'F1G_FILIAL', 'xFilial("F1G")'},{'F1G_IDCAB', 'F1F_ID'}}, F1G->(IndexKey(1)))

//Valida��o do CFOP feita atrav�s do pr�prio MVC.
oCFOPCST:SetProperty('F1G_CFOP' , MODEL_FIELD_VALID, {||( VldCFOP(oModel) )})

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001)//"Configura��o do Coeficiente do CIAP"

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

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel := FWLoadModel("FISA220")

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F1F")
Local oCFOPCST   := FWFormStruct(2, "F1G")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formul�rios para interface
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

//O formul�rio da interface ser� colocado dentro do container
oView:SetOwnerView('VIEW_CAB'      , 'SUPERIOR')
oView:SetOwnerView('VIEW_CFOPCST'  , 'INFERIOR')

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_CAB'      , STR0001)//"Configura��o para Coeficiente CIAP"
oView:EnableTitleView('VIEW_CFOPCST'  , STR0003)//"CFOP"

oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta as op��es do combo da op��o do operando

@author Erick G Dias
@since 08/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FSA220OP()
Local cRet	:= ""

cRet	:= '01=Sa�das Tributadas;02=Dev. Sa�das Tributadas;03=Sa�das N�o Tributadas;04=Dev. Sa�das N�o Tributadas;'
cRet	+= '05=Exporta��es;06=Dev. Exporta��es;07=Equiparadas a Exporta��o;08=Dev. Equiparadas a Exporta��o;09=Total de Sa�das;10=Dev. Total de Sa�das'

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA220VLOR
Fun��o que monta as op��es do combo da op��o valor de origem

@author Erick G Dias
@since 08/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FSA220VLOR()
Local cRet := ""

cRet	:= '01=Valor Cont�bil;02=Valor da Mercadoria;03=Isentas;04=Outras;05=Base ICMS;06=Outras + Isentas;'
cRet	+= '07=Base ICMS + Outras;08=Base ICMS + Isentas;09=Base ICMS + Outras + Isentas'

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa220CI
Fun��o que realizar a carga inicial autom�tica dos CFOPS e CSTs nos operandos.

@author Erick G Dias
@since 14/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function Fsa220CI(oSay, lAutomato, aOper)

Local cIdOperando   := ""
Local cOperando     := ""
Local aCstTrib      := {"00", "20"} //CST Tributado Integralmente ou Redu��o de base de c�lculo
Local aCstNTrib     := {"30", "40", "41", "50"} //CST Isenta, N�o Tributada ou Suspenso
Local aCstSTTrib    := {"10", "70"} //CST Tributado com ST ou redu��o com ST
Local aCstSTNTrib   := {"60"} //CST CObrado anteriormente por ST
Local aCstExp       := {"41"} //CST N�o tributado
Local aCFOPTrib     := {} //Array com CFOPS Tributados sem ST
Local aCFOPNTrib    := {} //Array com CFOPs n�o Tributados sem ST
Local aCFOPEXP      := {} //Array com CFOPs de Exporta��o
Local aCFOPEquip    := {} //Array com CFOPs de Venda equiparada a exporta��o
Local aDevTrib      := {} //Array com CFOPs de develu��o de opera��es tributadas sem ST
Local aDevNTrib     := {} //Array com CFOPs de develu��o de opera��es n�o tributadas sem ST
Local aDevExp       := {} //Array com CFOPS de devolu��o de exporta��o
Local aDevEquip     := {} //Array com CFOPs de devolu��o de exporta��o equiparada
Local aCFOPSTT      := {} //Array com CFOP Tributados com ST
Local aCFOPSTNT     := {} //Array com CFOP N�o Tributados com ST
Local aDevSTT       := {} //Array de devolu��o de venda Tributada com ST
Local aDevSTNT      := {} //Array de devolu��o de venda n�o Tributada com ST
Local nX            := 0
Default lAutomato := .F.

If !lAutomato
    oSay:cCaption := (STR0007)//"Processando CFOPs e CSTs..."
    ProcessMessages()
EndIF

//-----------------------------------
//CFOP de Sa�das Tributadas sem ST
//-----------------------------------
aAdd (aCFOPTrib, {"5101", "5102", "5103", "5104", "5105", "5106", "5109", "5110", "5111", "5112", "5113", "5114", "5115", "5116", "5117", "5118", "5119", "5120", "5122","5123",;
                  "5124", "5125", "5251", "5252", "5253", "5254", "5255", "5256", "5257", "5258", "5301", "5302", "5303", "5304", "5305", "5306", "5307", "5351", "5352", "5353",;
                  "5354", "5355", "5356", "5357", "5359", "5360", "5451", "5551", "5651", "5652", "5653", "5654", "5655", "5656", "5667", "5910",;
                  "5911", "5933", "5949", "6101", "6102", "6103", "6104", "6105", "6106", "6107", "6108", "6109", "6110", "6111", "6112", "6113", "6114", "6115", "6116", "6117",;
                  "6118", "6119", "6120", "6122", "6123", "6124", "6125", "6251", "6252", "6253", "6254", "6255", "6256", "6257", "6258", "6301", "6302", "6303", "6304", "6305",;
                  "6306", "6307", "6351", "6352", "6353", "6354", "6355", "6356", "6357", "6359", "6360", "6551", "6651", "6652", "6653", "6654",;
                  "6655", "6656", "6667", "6910", "6911", "6933", "6949"})

//-------------------------------------------
//CFOP de Sa�das Tributadas com ST
//-------------------------------------------
aAdd (aCFOPSTT, {"5401", "5402", "6401","6402"})

//-----------------------------------------------
//CFOP de Devolu��es de Sa�das Tributadas sem ST
//-----------------------------------------------
aAdd (aDevTrib, {"1201", "1202", "1203", "1204", "1205", "1206", "1207", "1553", "1660", "1661", "1662", "2201", "2202", "2203", "2204", "2205", "2206", "2207",;
                 "2553", "2660", "2661", "2662"})

//-----------------------------------------------
//CFOP de Devolu��es de Sa�das Tributadas com ST
//-----------------------------------------------
aAdd (aDevSTT, {"1410", "2410"})

//-------------------------------------
//CFOP de Sa�das N�o Tributadas sem ST
//-------------------------------------
aAdd (aCFOPNTrib, {"5101", "5102", "5103", "5104", "5105", "5106", "5109", "5110", "5111", "5112", "5113", "5114", "5115", "5116", "5117", "5118", "5119", "5120", "5122","5123",;
                  "5124", "5125", "5251", "5252", "5253", "5254", "5255", "5256", "5257", "5258", "5301", "5302", "5303", "5304", "5305", "5306", "5307", "5351", "5352", "5353",;
                  "5354", "5355", "5356", "5357", "5359", "5360", "5451", "5551", "5651", "5652", "5653", "5654", "5655", "5656", "5667", "5910",;
                  "5911", "5932", "5933", "5949", "6101", "6102", "6103", "6104", "6105", "6106", "6107", "6108", "6109", "6110", "6111", "6112", "6113", "6114", "6115", "6116", "6117",;
                  "6118", "6119", "6120", "6122", "6123", "6124", "6125", "6251", "6252", "6253", "6254", "6255", "6256", "6257", "6258", "6301", "6302", "6303", "6304", "6305",;
                  "6306", "6307", "6351", "6352", "6353", "6354", "6355", "6356", "6357", "6359", "6360", "6551", "6651", "6652", "6653", "6654",;
                  "6655", "6656", "6667", "6910", "6911", "6932", "6933", "6949"})

//-------------------------------------
//CFOP de Sa�das N�o Tributadas som ST
//-------------------------------------
aAdd (aCFOPSTNT, {"5403", "5405", "6403","6405"})

//-----------------------------------------------
//CFOP de Devolu��es Sa�das N�o Tributadas sem ST
//--------------------------------------------------
aAdd (aDevNTrib, {"1201", "1202", "1203", "1204", "1205", "1206", "1207", "1553", "1660", "1661", "1662", "2201", "2202", "2203", "2204", "2205", "2206", "2207",;
                 "2553", "2660", "2661", "2662"})  

//-----------------------------------------------
//CFOP de Devolu��es Sa�das N�o Tributadas com ST
//-----------------------------------------------
aAdd (aDevSTNT, {"1411", "2411"})

//------------------
//Sa�das Exporta��es
//------------------
aAdd (aCFOPEXP, {"7101", "7102", "7105", "7106", "7127", "7251", "7301", "7358", "7501", "7551", "7651","7654", "7667", "7949"})

//-----------------------------
//Devolu��es Sa�das Exporta��es
//-----------------------------
aAdd (aDevExp, {"3201","3202", "3205", "3206", "3207", "3211", "3503", "3553"})
//--------------------------------
//Sa�das equiparadas a exporta��o
//--------------------------------
aAdd (aCFOPEquip, {"5501", "5502", "6501", "6502"})

//-------------------------------------------
//Devolu��es Sa�das equiparadas a exporta��o
//-------------------------------------------
aAdd (aDevEquip, {"1503", "1504", "2503","2504"})

If Empty( aOper )

    //--------------------------------------------------------------------------------------------
    //Sa�das Tributadas
    //------------------------
    If !lAutomato
        oSay:cCaption := (STR0008)//"Processando CFOPs e CSTs Tributados"
        ProcessMessages()
    EndIF
    cOperando   := "01"
    cIdOperando := AddOperando(cOperando) 
    //Processa CST e CFOPS SEM ST
    ProcCfopCSt(aCstTrib, aCFOPTrib[1], "07"/*Base C�lculo + Outras*/, cOperando, cIdOperando)
    //Processa CST e CFOPS COM ST
    ProcCfopCSt(aCstSTTrib, aCFOPSTT[1], "07"/*Base C�lculo + Outras*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Devolu��es Sa�das Tributadas
    //------------------------
    If !lAutomato
        oSay:cCaption := (STR0009)//"Processando CFOPs e CSTs de Devolu��es Tributadas"
        ProcessMessages()
    EndIF
    cOperando := "02"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de devolu��o SEM ST
    ProcCfopCSt(aCstTrib, aDevTrib[1], "07"/*Base C�lculo + Outras*/, cOperando, cIdOperando)
    //Processa os CSTs e CFOPS de devolu��o COM ST
    ProcCfopCSt(aCstSTTrib, aDevSTT[1], "07"/*Base C�lculo + Outras*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Sa�das N�o Tributadas
    //------------------------
    If !lAutomato
        oSay:cCaption := (STR0010)//"Processando CFOPs e CSTs N�o Tributados"
        ProcessMessages()
    EndIF
    cOperando := "03"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS n�o tributados SEM ST
    ProcCfopCSt(aCstNTrib, aCFOPNTrib[1], "03"/*Isentas*/, cOperando, cIdOperando)
    //Processa os CSTs e CFOPS n�o tributados COM ST
    ProcCfopCSt(aCstSTNTrib, aCFOPSTNT[1], "03"/*Isentas*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Devolu��es Sa�das N�o Tributadas
    //---------------------------------
    If !lAutomato
        oSay:cCaption := (STR0011)//"Processando CFOPs e CSTs de Devolu��es N�o Tributados"
        ProcessMessages()
    EndIF
    cOperando := "04"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS n�o tributados SEM ST
    ProcCfopCSt(aCstNTrib, aDevNTrib[1], "03"/*Isentas*/, cOperando, cIdOperando)
    //Processa os CSTs e CFOPS n�o tributados COM ST
    ProcCfopCSt(aCstSTNTrib, aDevSTNT[1], "03"/*Isentas*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Sa�das Exporta��o
    //---------------------------------
    If !lAutomato
        oSay:cCaption := (STR0012)//"Processando CFOPs e CSTs de Exporta��o"
        ProcessMessages()
    Endif
    cOperando := "05"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de Exporta��o
    ProcCfopCSt(aCstExp, aCFOPEXP[1], "01"/*Valor Cont�bil*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------


    //--------------------------------------------------------------------------------------------
    //Devolu��es Sa�das Exporta��o
    //---------------------------------
    If !lAutomato
        oSay:cCaption := (STR0013)//"Processando CFOPs e CSTs de devolu��es de Exporta��o"
        ProcessMessages()
    EndIF
    cOperando := "06"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de Exporta��o
    ProcCfopCSt(aCstExp, aDevExp[1], "01"/*Valor Cont�bil*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Sa�das Equiparadas a Exporta��o
    //---------------------------------
    If !lAutomato
        oSay:cCaption := (STR0014)//"Processando CFOPs e CSTs Equiparados a Exporta��o"
        ProcessMessages()
    EndIF
    cOperando := "07"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de Equiparados a Exporta��o
    ProcCfopCSt(aCstExp, aCFOPEquip[1], "01"/*Valor Cont�bil*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------



    //--------------------------------------------------------------------------------------------
    //Devolu��es Equiparadas a Exporta��o
    //------------------------------------
    If !lAutomato
        oSay:cCaption := (STR0015)//"Processando CFOPs e CSTs Devolu��es Equiparados a Exporta��o"
        ProcessMessages()
    EndIF
    cOperando := "08"
    cIdOperando := AddOperando(cOperando) 
    //Processa os CSTs e CFOPS de Devolu��o Equiparados a Exporta��o
    ProcCfopCSt(aCstExp, aDevEquip[1], "01"/*Valor Cont�bil*/, cOperando, cIdOperando)
    //--------------------------------------------------------------------------------------------

EndIf

If !Empty( aOper )
    For nX  := 1 to Len(aOper[1])
        cOperando   := AllTrim(aOper[1][nX])
        If cOperando == "09"
            //--------------------------------------------------------------------------------------------
            //Total de Sa�das
            //------------------------
            If !lAutomato
                oSay:cCaption := (STR0016)//"Processando CFOPs e CSTs Total de sa�das e Devolu��es de Totais de Sa�das"
                ProcessMessages()
            EndIF
            cIdOperando := AddOperando(cOperando) 
            //Processa CST e CFOPS SEM ST
            ProcCfopCSt(aCstTrib, aCFOPTrib[1], "01"/*Valor Cont�bil*/, cOperando, cIdOperando)
            //Processa CST e CFOPS COM ST
            ProcCfopCSt(aCstSTTrib, aCFOPSTT[1], "01"/*Valor Cont�bil*/, cOperando, cIdOperando)
        EndIf

        If cOperando == "10"
            //--------------------------------------------------------------------------------------------
            //Devolu��o Total de Sa�das
            //------------------------
            If !lAutomato
                oSay:cCaption := (STR0016)//"Processando CFOPs e CSTs Total de sa�das e Devolu��es de Totais de Sa�das"
                ProcessMessages()
            EndIF
            cIdOperando := AddOperando(cOperando) 
            //Processa os CSTs e CFOPS de devolu��o SEM ST
            ProcCfopCSt(aCstTrib, aDevTrib[1], "01"/*Valor Cont�bil*/, cOperando, cIdOperando)
            //Processa os CSTs e CFOPS de devolu��o COM ST
            ProcCfopCSt(aCstSTTrib, aDevSTT[1], "01"/*Valor Cont�bil*/, cOperando, cIdOperando)
        EndIf

    Next nX
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddOperando
M�todo que faz inclus�o do operando

@author Erick G Dias
@since 14/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function AddOperando(cOperando)
Local cIdF1F    := ""

//Verifica se operando est� preenchido e se n�o existe no banco
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
Fun��o que faz a inclus�o do CFOP, do CST e do valor de origem

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
Fun��o auxiliar para processar cadastro da carga autom�tica

@author Erick G Dias
@since 14/03/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function ProcCfopCSt(aCst, aCfop, cVlOrig, cOperando, cIdCab)

Local nCst  := 0
Local nCfop := 0

//La�o no array de CST
For nCst   := 1 to Len(aCst)
    //La�o no array de CFOP
    For nCfop:= 1 to Len(aCfop)
        AddCFOPCST(aCfop[nCfop] /*CFOP*/  , aCst[nCst] /*CST de ICMS*/ , cVlOrig /*Valor de Oritem*/, cOperando /*Operando*/, cIdCab/*Id do cabe�aho*/)
    Next nCont2

Next nCst

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCFOP
Fun��o que ter� a valida��o do CFOP.

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

//Permite CFOP vazio, equivalente a fun��o Vazio()
If Empty(cCFOP)
    lRet := .T.

//Verifica se o CFOP existe
ElseIf SX5->( MsSeek ( xFilial('SX5') + "13" + cCFOP ) )
    //Se existir verificar� se est� digitando CFOP de sa�da para operando de sa�da e CFOP de entrada para operando de entrada
    If cOperando $ "01/03/05/07/09" .AND. cIniCfop $ "5/6/7"
        //Somente pode permitir CFOPS de sa�das
        lRet := .T.
    ElseIf cOperando $ "02/04/06/08/10" .AND. cIniCfop $ "1/2/3"
        //Somente pode permtir CFOPS de entradas
        lRet := .T.    
    EndIF

EndIF

Return lRet