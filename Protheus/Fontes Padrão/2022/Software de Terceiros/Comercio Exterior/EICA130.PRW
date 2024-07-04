#INCLUDE "AVERAGE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#include "protheus.ch"
#INCLUDE "Eiccad00.ch"


Function MVC_EICA130(xRotAuto,nOpcAuto)
    Local oBrowse
    LOCAL cAlias:="SYD" //mjb150999, nOldArea:=Select()

    PRIVATE aMemos:={{"YD_TEXTO","YD_VM_TEXT"}} //LRL 25/05/04
    PRIVATE cDelFunc

    PRIVATE cCadastro := STR0019 //"TEC / NCM"
    PRIVATE aParam:={ {|| .T. } , {|| .T. } , {|nOpc| Ax130GrvCpo(nOpc) } , {|| .T. } }//AWR - 07/02/2006
    PRIVATE lTelaContent := .F. //MCF - 26/04/2016
    PRIVATE lTelaComexQA := .F. //MCF - 26/04/2016

    IF SYD->(FIELDPOS("YD_MOT_II")) # 0 .AND. SYD->(FIELDPOS("YD_MOT_IPI")) # 0//AWR - 08/02/2006
        AADD(aMemos,{"YD_MOT_II" ,"YD_MOII_VM"})
        AADD(aMemos,{"YD_MOT_IPI","YD_MOIPIVM"})
    ENDIF

    If xRotAuto == NIL
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias(cAlias)
        oBrowse:SetMenuDef("EICA130")
        oBrowse:SetDescription(STR0019)
        oBrowse:Activate()
    Else
        aRotina := MenuDef()
        FWMVCRotAuto(modelDef(), cAlias, nOpcAuto, {{"SYD_MASTER",xRotAuto}})
    Endif

    

Return Nil

Static Function modelDef()

    // Criar um Form Struct, para cada dicionário a ser exibido na tela
    // Criar um objeto modelo
    // Adicionar os Form Struct para o modelo criado
    // Atribuir a primary key do modelo
    // Atribuir o "Relation", entre os dicionarios, os quais seus dados serão exibidos na tela
    // Atribuir os description de cada dicionario adicionado
    Local cAlias := "SYD"
    Local oStruSYD := FWFormStruct(1, cAlias)
    Local oModel // Modelo de dados que será construído

    // Bloco é executado quando clica em um botão Incluir, alterar e etc.
    Local bVldActive := {|oModel| onVldAct(oModel, cAlias)}
    // bPost : Validações
    Local bPost := {|oModel| A130Post(oModel)}
    Local bCommit := {|oModel| onCommit(oModel)}

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New(cAlias, , bPost, bCommit)
    oModel:SetVldActivate(bVldActive)

    // Adiciona ao modelo um componente de formulário
    oModel:AddFields("SYD_MASTER", /*cOwner*/, oStruSYD)
    
    oModel:SetDescription(STR0019)
    oModel:SetPrimaryKey( {""} )
    
return oModel

Static Function viewDef()

    Local cAlias := "SYD"
    // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
    Local oModel := FWLoadModel("EICA130")
    // Cria a estrutura a ser usada na View
    Local oStruSYD := FWFormStruct(2, cAlias)
    Local nOpc
    // Interface de visualização construída
    Local oView

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado na View
    oView:SetModel(oModel)

    // Adiciona no nosso View um controle do tipo formulário
    // (antiga Enchoice)
    oView:AddField("SYD_MASTER", oStruSYD)
    oView:SetOwnerView("SYD_MASTER") 
    oView:EnableControlBar(.T.)

    If ChkFile("EVJ") //MCF - 26/10/2015
        oView:AddUserButton(STR0061, "NOTE", {|| Ax130ExNCM()}, , ,{MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})  //"Consultar EX-NCM"
    Endif

    If ChkFile("EVL") //MCF - 26/10/2015
        oView:AddUserButton(STR0067, "NOTE", {|| Ax130Anuen(), , ,{MODEL_OPERATION_VIEW, MODEL_OPERATION_UPDATE}}) //"Consultar Anuencias"
    Endif
    
Return oView

static function menuDef()

    Private aRotina := {}

    ADD OPTION aRotina TITLE STR0007 ACTION "PesqBrw" OPERATION 1 ACCESS 0 // Pesquisar
    ADD OPTION aRotina TITLE STR0008 ACTION "viewDef.EICA130" OPERATION 2 ACCESS 0 // Visualizar
    ADD OPTION aRotina TITLE STR0009 ACTION "viewDef.EICA130" OPERATION 3 ACCESS 0 // Incluir
    ADD OPTION aRotina TITLE STR0010 ACTION "viewDef.EICA130" OPERATION 4 ACCESS 0 // Alterar
    ADD OPTION aRotina TITLE STR0011 ACTION "viewDef.EICA130" OPERATION 5 ACCESS 0 // Excluir

    menuDefAd()

    
Return aRotina

// Para outras ações após executar o menuDef
static function menuDefAd()

    Local aComexContent := {}
    Local aComexDataQA := {} // GFP - 18/03/2015 //MCF - 02/02/2016
    Local aRotAdic := {}

    aAdd(aComexContent,{ STR0063 , "CD100MenuCnt" , 0 , 3})  //"Configurações" // GFP - 18/03/2015
    aAdd(aComexContent,{ STR0064 , "CD100IntNCM"  , 0 , 3})  //"TOTVS Comex Conteúdo - NCM" // GFP - 18/03/2015
    aAdd(aComexDataQA ,{ STR0063 , "CD100MenuQA"  , 0 , 3})  //"Configurações" // MCF - 02/02/2016
    aAdd(aComexDataQA ,{ STR0066 , "CD100CDQA"    , 0 , 3})  //"Comex Data QA"

    If FindFunction("EICCD100") //.AND. FindFunction("EasyComexDataQA")   // GFP - 18/03/2015 //MCF - 02/02/2016
        Aadd(aRotina, { STR0060,aComexContent , 0 , 0}) //"TOTVS Comex Conteúdo"
    EndIf
    If EasyGParam("MV_EIC0061",,.F.) .And. FindFunction("EasyComexDataQA") //MCF - 03/02/2016
        Aadd(aRotina, { STR0066,aComexDataQA  , 0 , 3}) //MCF - 02/02/2016
    Endif

    //FDR - 29/10/2012 - PE para manipular o aRotina
    If(EasyEntryPoint("EICA130"),ExecBlock("EICA130",.F.,.F.,"MENU"),)
           
Return

static Function A130Post(oModel)

    Local nOpc := oModel:getOperation()
    
    DO CASE
    CASE nOpc == MODEL_OPERATION_INSERT
        Return A30ValInc(oModel)
    ENDCASE

Return .T.

// Valida a inclusão
static Function A30ValInc(oModel)

    // Obtém o valor YD_TEC do formulário
    Local cYD_TEC := oModel:getValue("SYD_MASTER","YD_TEC")
    Local cYD_EX_NCM := oModel:getValue("SYD_MASTER","YD_EX_NCM")
    Local cYD_EX_NBM := oModel:getValue("SYD_MASTER","YD_EX_NBM")
    Local cYD_DESTAQ := oModel:getValue("SYD_MASTER","YD_DESTAQU")

    Local nLenArq:=LEN(SYD->YD_TEC),nLenMem:=LEN(cYD_TEC)

    If nLenArq>nLenMem
        cYD_TEC:=cYD_TEC+SPACE(nLenArq-nLenMem)
    Elseif nLenArq<nLenMem
        cYD_TEC:=cYD_TEC+SPACE(nLenMem-nLenArq)
    Endif

    // Insere YD_TEC alterado para o model
    oModel:setValue("SYD_MASTER","YD_TEC", cYD_TEC);

    // GFP - 17/12/2013 - Conforme legislação vigente, é possível incluir NCMs com TEC iguais e número de destaque diferentes. 
    If SYD->(DbSeek(xFilial()+cYD_TEC + cYD_EX_NCM + cYD_EX_NBM + cYD_DESTAQ))
        Help(" ",1,"JAGRAVADO")
        lValida := .F. //LGS - 07/08/2013 - Se N.c.m. já cadastrada variavel recebe valor .F.
        Return .F.
    Endif

    lValida := .T. //LGS - 07/08/2013 - Se cadastro ok variavel recebe valor .T.

Return .T.

/*
    Executa após as validações
*/
static Function onCommit(oModel)

    Local bAfter := {|oMdl,cId,cAlias,lNewRec,nOperation| MVCGravaMemo(oMdl,cId,cAlias,aMemos)}

    FWFormCommit(oModel,,bAfter)

    // Função do fonte EICCAD00.PRW
    Ax130GrvCpo(oModel:getOperation())

Return .T.

/*
    Ao clicar em um botão (Deleta, incluir, etc), essa função será executada.

*/
static function onVldAct(oModel, cAlias)

    Local nOpc := oModel:getOperation()

    DO CASE
    CASE nOpc == MODEL_OPERATION_DELETE
        Return A30ValDel(oModel, cAlias)
    ENDCASE

Return .T.

/*
    Valida a exclusão do NCM
    Se retornar falso, é porque não passou na validação
*/
static function A30ValDel(oModel, cAlias)

    /*
        Verifica se existe algum processo utilizando o NCM.
        Se existir, o NCM não será excluído
    */
    IF ! EasyValDelEIC(cAlias) // GFP - 28/08/2013
        Return .F.
    ENDIF

Return .T.