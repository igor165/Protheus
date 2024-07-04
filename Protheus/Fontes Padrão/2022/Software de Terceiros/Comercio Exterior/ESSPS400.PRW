/*
Programa   : ESSPS400
Objetivo   : Manutenção da Rotina de Processo de Serviços
Retorno    : Nil                                                                                                                                               
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 17/08/2012 11:00 
Revisao    :                          
*/

#Include 'Protheus.ch'
#Include "Average.ch"
#Include "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#define CANCELAR 10  //SSS - REQ 8 13/06/2014                                 
                                                                                         
Static aModels := {}

Function ESSPS400(cTipo,aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Local cFonte         := "ESSPS400"
Local oAvObject      := AvObject():New()
Local nPos
Local nAtuItems      := 0                            
Local nAtuAnexos     := 0
Local lRet
Local nProc := nOrig := nFilial :=0//LRS - 22/08/2017
Local cTextoTipo     := If(cTipo=="A","Aquisição", "Venda")
Private oBrowsePed
Private cBrwFiltro   := "EJW_TPPROC='"+cTipo+"'"  //Filtra pelo Tipo de Processo,'A' para Aquisicao e 'V' para Venda     
Private aRotina
Private cPed         := cTipo
Private lPS400Auto   := ValType(aCab) <> "U" .Or. ValType(aItens) <> "U" .Or. ValType(aAnexos) <> "U" .Or. ValType(nOpcAuto) <> "U" 
Private cMoedaIni    := ""
Private cFase        := "1"
Private lIntPedServ  := EasyGParam("MV_ESS0003",,.F.)//Verifica se deve executar a ExecAuto de geração do Registro de Serviço
Private lAltProc     := EasyGParam("MV_ESS0007",,.F.)//Verifica se deve exibir botão que permite alterar o numéro do Processo (Campo Chave)
Private cCadastro    := ""//Variavel necessaria na função MsDocument()
Private oModelAuto
Private lIntCom := EasyGParam("MV_COMSEIC",,.F.)//Verifica se está integrado com o módulo SIGACOM
Private lIntFat := EasyGParam("MV_FATSEEC",,.F.)//Verifica se está integrado com o módulo SIGAFAT
Private lIntLogix := AvFlags("ESS_EAI") //SSS - REQ. 8 - 11/06/2014 -  Verifica se a integração com Logix esta ativa 

Default aAnexos      := {}
Default lCallInv     := .F.
Private lAlteraValor := lCallInv //RRC - 10/05/2013 - Quando .T., indica que a chamada se original no ESSIS400() devido a uma alteração com um valor monetário maior que o Processo
Private lGeraProc    := .T. //RRC - 23/08/2013 - Valida se deve chamar a rotina de ExecAuto do Processo caso o cliente/fornecedor seja estrangeiro, para não exibir mensagem de erro (casos de integração com o SIGACOM e SIGAFAT)
//Private aRotina      := {}//FSY - 26/12/2013 - (Opção: Conhecimento)Variavel deve ser private e estar declarado na função onde estiver FWBROWSE
Private lCancel      :=.F. //IGOR CHIBA 17/06/14 

//EasyLinkAtu() //LRS - 20/10/2017 - Function transferida para o Avupdate02

//IGOR CHIBA 17/06/14  
IF nOpcAuto == 10 //se for cancelamento   
   lCancel  :=.t.
   nOpcAuto := 4 
ENDIF

SIX->(DbSetOrder(1)) //MCF - 09/08/2016
If EasyGParam("MV_ESS0027",,9) >= 10 .And. SIX->(DBSeek("ELM1")) .AND. Alltrim(SIX->CHAVE) == 'ELM_FILIAL+ELM_COD+ELM_CODCLI+ELM_LOJCLI+ELM_CODFOR+ELM_LOJFOR'
   EasyHelp("É necessário realizar uma alteração de indices para prosseguir com a utilização do Easy Siscoserv. Entre em contato com o administrador e peça para que o mesmo siga as "+;
            "orientações do documento http://tdn.totvs.com/display/PROT/ " + ENTER + "TUPFFU_DT_Implementacao_Easy_Siscoserv","Aviso")
   Return
EndIf

//LRS - 22/08/2017
IF (nProc := aScan(aCab, {|x| x[1]== "EJW_PROCES"})) >0 .and. (nOrig := aScan(aCab, {|x| x[1]== "EJW_ORIGEM"})) >0 .AND. (nFilial := aScan(aCab, {|x| x[1]== "EJW_FILIAL"})) >0 
   EJW->(DbSetOrder(2))
   If EJW->(DbSeek(aCab[nFilial][2]+AvKey(aCab[nProc][2],"EJW_PROCES")))
      IF Avkey(aCab[nOrig][2],"EJW_ORIGEM") <> EJW->EJW_ORIGEM
         EasyHelp("Erro na geração do processo de "+cTextoTipo+" no módulo Siscoserv(SIGAESS) pois já existe um processo de "+cTextoTipo+" cadastrado com o mesmo número de processo. "+ Chr(13) + Chr(10) +;
                  "Informe um número de processo diferente do informado.","Aviso")
         Return
      EndIF
   EndIF
EndIF

If !lPS400Auto
  
   oBrowsePed := FWMBrowse():New() //Instanciando a Classe   
   oBrowsePed:SetAlias("EJW") //Informando o Alias
   oBrowsePed:SetMenuDef(cFonte) //Nome do fonte do MenuDef
   oBrowsePed:SetDescription("Processo de Serviços") //Descrição a ser apresentada no Browse
   oBrowsePed:SetFilterDefault(cBrwFiltro) //Filtro dos registros a serem exibidos
   oBrowsePed:AddLegend( "EJW_STTPED='1'", "RED"   , "Aguardando registro" )//Campo para adicionar marcação
   oBrowsePed:AddLegend( "EJW_STTPED='2'", "BLUE"  , "Parcialmente em fase de registro" )//Campo para adicionar marcação
   oBrowsePed:AddLegend( "EJW_STTPED='3'", "YELLOW", "Em fase de registro" )//Campo para adicionar marcação
   oBrowsePed:AddLegend( "EJW_STTPED='4'", "GREEN" , "Encerrado" )//Campo para adicionar marcação   
   If lIntLogix
      oBrowsePed:AddLegend( "EJW_STTPED=='5'", "BLACK" , "Cancelado" )//SSS - REQ. 8 - 11/06/2014      
   EndIf 

   //THTS - 18/07/2017 - Criada a funcao AvGetCpBrw() para retirar do Browse campos que nao querem que sejam exibidos
   If Upper(cTipo) == "A"
	//aMosta := {"EJW_EXPORT", "EJW_LOJEXP", "EJW_DSCEXP"}
	//aEsconde := {"EJW_IMPORT", "EJW_LOJIMP", "EJW_DSCIMP"}
      oBrowsePed:SetOnlyFields(AvGetCpBrw("EJW",{"EJW_IMPORT", "EJW_LOJIMP", "EJW_DSCIMP"}))
   ElseIf Upper(cTipo) == "V"
	//aMosta := {"EJW_IMPORT", "EJW_LOJIMP", "EJW_DSCIMP"}
	//aEsconde := {"EJW_EXPORT", "EJW_LOJEXP", "EJW_DSCEXP"}
      oBrowsePed:SetOnlyFields(AvGetCpBrw("EJW",{"EJW_EXPORT", "EJW_LOJEXP", "EJW_DSCEXP"}))
   EndIf	

   oBrowsePed:Activate()   
           
   EJW->(dbClearFilter())
Else 
   
   Begin Sequence
   
   If ValidaIntegracao(@nOpcAuto, aCab, aItens, aAnexos, lAlteraValor)
      //RRC - 10/05/2013 - lAlteraValor verifica se a chamada veio do ESSIS400(), neste caso pode não passar todos os itens, é uma alteração dos valores monetários
      If nOpcAuto == 4 .And. !lAlteraValor
         nAtuItens  := Len(aItens)
         nAtuAnexos := Len(aAnexos)
         
         If Len(aItens) > 0
            aItens     := EasyEAutItens("EJW", "EJX", aCab, aItens, "EJW_FILIAL+EJW_TPPROC+EJW_PROCES", EJX->(IndexKey(1)), 1, EJW->(RecNO()))
         EndIf
         
         If Len(aAnexos) == 0
            aAnexos    := EasyEAutItens("EJW", "EL2", aCab, aAnexos,"EJW_FILIAL+EJW_TPPROC+EJW_PROCES", EL2->(IndexKey(1)), 1, EJW->(RecNO()))
         EndIf
         //Caso tenha sido acrescentado algum item a ser excluído pela função EasyEAutItens() e se o total de itens anteriores era zero, todos os itens cadastrados são para exclusão
         If (nAtuItens < Len(aItens) .Or. nAtuAnexos < Len(aAnexos)) .And. nAtuItens == 0 .AND. !IsInCallStack("ESSIN100")
            nOpcAuto := 5
         EndIf
      EndIf
      
      //Definições de WHEN dos campos
      INCLUI := nOpcAuto == INCLUIR
      ALTERA := nOpcAuto == ALTERAR
      EXCLUI := nOpcAuto == EXCLUIR
      
      aRotina := MenuDef()
      //oModel := ModelDef()
      //FWMVCRotAuto(oModel,"EJW",nOpcAuto,{{"EJWMASTER" ,aCapaAuto},{"EJXDETAIL",aItensAuto}},.T.,.T.)
      
      //RRC - 23/08/2013 - Valida se deve chamar a rotina de ExecAuto do Processo caso o cliente/fornecedor seja estrangeiro, para não exibir mensagem de erro (casos de integração com o SIGACOM e SIGAFAT)
      If lGeraProc
         If Len(aItens) > 0 .Or. EXCLUI .OR. IsInCallStack("ESSIN100") .or. lcancel // inclui lcancel  IGOR CHIBA 17/06/14 
            If (nPos := aScan(aModels,{|X| X[1] == cTipo})) == 0
               aAdd(aModels,{cTipo,ModelDef()})
               nPos := Len(aModels)
            EndIf
            oModelAuto := aModels[nPos][2]
         
            lMsErroAuto := !EasyMVCAuto("ESSPS400",nOpcAuto,{{"EJWMASTER" ,aCab, if(!INCLUI,EJW->(RecNo()),0)},{"EJXDETAIL",aItens},{"EL2DETAIL",aAnexos}},@oAvObject)
            If lMsErroAuto
               AEval(oAvObject:aError,{|X| AutoGrLog(x)})
            EndIf
         //ElseIf IsInCallStack("ESSIN100") //RRC - 23/08/2013 - Só exibe as mensagens de erro se for chamado da integração de arquivo CSV
         //   lMsErroAuto := .T.
         EndIf                                                                                                                                                           
      EndIf
   Else
      lMsErroAuto := .T.
      AEval(oAvObject:aError,{|X| AutoGrLog(x)})
   EndIf
   
   End Sequence
   
   lRet := lMsErroAuto   
EndIf

Return lRet


*------------------------*
Static Function MenuDef()
*------------------------*
Local cTitle := ""
//Private aRotina := {}//FSY - 26/12/2013 - Variavel deve ser private e estar declarado na função onde estiver FWBROWSE
Local aRotina := {}
Local aRotAdic := {} //LRS - 19/10/2017

If Type("cPed") == "C"

    If cPed=="V"
        cTitle  := "Faturamento"
    Else
        cTitle  := "Invoices"
    EndIf

    //Adiciona os botões na MBROWSE
    ADD OPTION aRotina TITLE "Pesquisar"             ACTION "AxPesqui"         OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar"            ACTION "VIEWDEF.ESSPS400" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"               ACTION "VIEWDEF.ESSPS400" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"               ACTION "VIEWDEF.ESSPS400" OPERATION 4 ACCESS 0
    //ADD OPTION aRotina TITLE "Excluir"               ACTION "FWExecView('EXCLUIR','VIEWDEF.ESSPS400', 5,,,{||PS400AtuPed()})" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"               ACTION "VIEWDEF.ESSPS400" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE cTitle                  ACTION "ESSPS500"         OPERATION 6 ACCESS 0
    //ADD OPTION aRotina TITLE "Invoices"              ACTION "ESSIS400"          OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE "Legendas"              ACTION "PS400Legenda"     OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE "Copiar Processo"       ACTION "VIEWDEF.ESSPS400" OPERATION 9 ACCESS 0   
    ADD OPTION aRotina TITLE "Atualizar Previsão"    ACTION "PSSelecData"      OPERATION 4 ACCESS 0 //FSY - 24/12/20113
    //ADD OPTION aRotina TITLE "Conhecimento"          ACTION "MsDocument"       OPERATION 4 ACCESS 0 //FSY - 26/12/20113

    If Type("lPS400Auto") == "L" .And. lPS400Auto  //SSS - REQ. 8  13/06/2014
      ADD OPTION aRotina TITLE "Cancelar"  ACTION "VIEWDEF.ESSPS400"  OPERATION 10 ACCESS 0
    EndIf

    //RRC - 09/05/2013
    If Type("cPed") == "C"
      //RRC - 11/06/2013 - Incluída condição para exibição do botão "Buscar Faturas"
      If (cPed == "A" .And. Type("lIntCom") == "L" .And. lIntCom .And. EasyGParam("MV_ESS0012",,.F.)) .OR. (cPed == "V" .And. Type("lIntFat") == "L" .And. lIntFat)  // GFP - 23/06/2014
          ADD OPTION aRotina TITLE "Buscar Invoices"    ACTION "PS400CallFat" OPERATION 4 ACCESS 0
      //ElseIf cPed == "V" .And. Type("lIntFat") == "L" .And. lIntFat 
      //   ADD OPTION aRotina TITLE "Buscar Faturas"     ACTION "PS400BuscFat(EJW->EJW_TPPROC,EJW->EJW_ORIGEM,EJW->EJW_PROCES)" OPERATION 10 ACCESS 0
      EndIf
      If cPed == "A" .And. Type("lIntPedServ") == "L" .And. lIntPedServ
          ADD OPTION aRotina TITLE "Atualiza RAS"       ACTION "PS400PendProc" OPERATION 4 ACCESS 0
      ElseIf cPed == "V" .And. Type("lIntPedServ") == "L" .And. lIntPedServ
          ADD OPTION aRotina TITLE "Atualiza RVS"       ACTION "PS400PendProc" OPERATION 4 ACCESS 0
      EndIf
      //RRC - 28/05/2013
      If Type("lAltProc") == "L" .And. lAltProc
          ADD OPTION aRotina TITLE "Altera NºProcesso"  ACTION "PS400NroProc" OPERATION 4 ACCESS 0
      EndIf
    EndIf

    //LRS - 19/10/2017 - RDMAKE para opção em MVC
    If EasyEntryPoint("PS400MNU")
      aRotAdic := ExecBlock("PS400MNU",.f.,.f.)
      If ValType(aRotAdic) == "A"
          AEval(aRotAdic,{|x| AAdd(aRotina,x)})
      EndIf
    EndIf

EndIf
Return aRotina
                                  
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEJW       := FWFormStruct(1,"EJW",{|cCpo| MostrCpo(cCpo)},)
Local oStruEJX       := FWFormStruct(1,"EJX",{|cCpo| MostrCpo(cCpo)},)
Local oStruEL2       := FWFormStruct(1,"EL2",{|cCpo| MostrCpo(cCpo)},)
Local bLinePos       := {|| PS400GridVal()}
Local bLinePre       := {|oGrid,nLine,cAction| PS400LinePre(oGrid,nLine,cAction)}  //RRC - 25/10/2013 - Atualização para validar a exclusão no modelo
Local bPosVal        := {|| SomaVal(),VerEnqRC()} //RRC - 19/03/2013 - Verifica os enquadramentos e Números de RC
Local bPosValidacao  := {|oMdl| If(oMdl:GetOperation() == 5 .or. lCancel ,PS400AtuPed(),.T.  )}
Local bCommit        := {|oMdl| GravDoc(cPed),GravCamp(oMdl)}  
//Local bGridValidacao := {|oModel|ESSPRE(oModel)} //SSS - REQ 8 16/06/2014
                                                                                            
oModel := MPFormModel():New("ESSPS400",/*bGridValidacao*/,bPosValidacao,bCommit,/*bCancel*/)

//Modelo para criação da antiga Enchoice com a estrutura da tabela
oModel:AddFields("EJWMASTER", /*nOwner*/, oStruEJW, /*bPre*/,/*bPos*/)     

//bPosVal := {|oModelGrid, nLinha, cAcao, cCampo| If(cAcao=="DELETE" .And. IsDeleted(),ItemDel(),)}                                                                
//Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("EJXDETAIL", "EJWMASTER", oStruEJX,  bLinePre , bLinePos , /*bPreVal*/,bPosVal, /*bLoad*/ )
oModel:AddGrid("EL2DETAIL", "EJWMASTER", oStruEL2,  bLinePre ,/*bLinePos*/ , /*bPreVal*/,bPosVal,/*bLoad*/ )

//Modelo de relação entre Capa e Detalhe
EJX->(dbSetOrder(1))
oModel:SetRelation("EJXDETAIL",{{"EJX_FILIAL", "xFilial('EJX')"}, {"EJX_TPPROC", "PS400Info('EJW_TPPROC')"}, {"EJX_PROCES", "EJW_PROCES"}} , EJX->(IndexKey(1)))
oModel:SetRelation("EL2DETAIL",{{"EL2_FILIAL", "xFilial('EL2')"}, {"EL2_TPPROC", "PS400Info('EJW_TPPROC')"}, {"EL2_PROCES", "EJW_PROCES"},{"EL2_REGIST", 'AvKey("","EL2_REGIST")' }} , EL2->(IndexKey(3)))

//RRC - 20/05/2013 - Caso específico em que o campo EJW_PROCES poderá ser editado 
If IsInCallStack("PS400NroProc")
   oStruEJW:SetProperty( "EJW_PROCES" , MODEL_FIELD_WHEN , {|| .T. })
EndIf

If Type("lPS400Auto") == "L" .And. EasyGParam("MV_ESS0027",,9) >= 10
   If !lPS400Auto
      oStruEL2:SetProperty( '*' , MODEL_FIELD_WHEN,{|| .F.})
      oModel:GetModel( "EL2DETAIL" ):SetNoInsertLine(.T.)
   EndIf
EndIf

//Informa grid não pussui preenchimento obrigátorio
oModel:GetModel( "EL2DETAIL" ):SetOptional( .T. ) 

//Definição da Chave Primária
oModel:SetPrimaryKey( { "EJW_FILIAL", "EJW_TPPROC", "EJW_PROCES"}) 
oModel:GetModel("EJXDETAIL"):SetUniqueLine({ "EJX_SEQPRC"} )

If Type("lPS400Auto") == "L" .And. Type("cPed") == "C" .And. !lPS400Auto .AND. EasyGParam("MV_ESS0027",,9) < 10
   If cPed == "V"
      oModel:GetModel("EL2DETAIL"):SetUniqueLine({ "EL2_RE"})
   ElseIf cPed == "A"
      oModel:GetModel("EL2DETAIL"):SetUniqueLine({ "EL2_DI"})
   EndIf
EndIf

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription("Processo de Serviços")
oModel:GetModel("EJWMASTER"):SetDescription("Processo")     // Título da Capa
oModel:GetModel("EJXDETAIL"):SetDescription("Serviços")   //Título do Detalhe 
oModel:GetModel("EL2DETAIL"):SetDescription("Documentos") //Título do Detalhe 

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("ESSPS400")

//Cria a estrutura a ser usada na View 
Local oStruEJW    := FWFormStruct(2,"EJW",{|cCpo| MostrCpo(cCpo)},) 
Local oStruEJX    := FWFormStruct(2,"EJX",{|cCpo| MostrCpo(cCpo)},)
Local oStruEL2    := If(EasyGParam("MV_ESS0004",,.F.),FWFormStruct(2,"EL2",{|cCpo| MostrCpo(cCpo)},),)
Local oView

//É necessário filtrar a tabela para que o MVC não permite navegar pelos registros inválidos nas operações de visualização/alteração.
EJW->(dbSetFilter(&("{||"+cBrwFiltro+"}"),cBrwFiltro))

//Cria o objeto de View      
oView := FWFormView():New()

//Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EJW", oStruEJW, "EJWMASTER")
oView:AddGrid( "VIEW_EJX", oStruEJX, "EJXDETAIL" )
If EasyGParam("MV_ESS0004",,.F.)
   oView:AddGrid( "VIEW_EL2", oStruEL2, "EL2DETAIL" )
EndIf
//Criar "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox( 'EMCIMA' , 50 ) 
If EasyGParam("MV_ESS0004",,.F.)
   oView:CreateVerticalBox( 'EMCIMAESQ' , 65, 'EMCIMA' )
   oView:CreateVerticalBox( 'EMCIMADIR' , 35, 'EMCIMA' )
EndIf
oView:CreateHorizontalBox( 'EMBAIXO', 50 )

//Relaciona o ID da View com o "box" para exibição 
If EasyGParam("MV_ESS0004",,.F.)
   oView:SetOwnerView("VIEW_EJW", "EMCIMAESQ")
   oView:SetOwnerView("VIEW_EL2", "EMCIMADIR")
Else
   oView:SetOwnerView("VIEW_EJW", "EMCIMA")
EndIf
oView:SetOwnerView("VIEW_EJX", "EMBAIXO")

//oView:SetViewAction("DELETELINE",{||ItemDel()})
//NOPADO por RRC - 28/10/2013 - Tratamento de validação transferido para a função PS400LinePre() no model
//oView:SetViewAction("DELETELINE",{|oObj,cDetail|aLines:= FWSaveRows(),ItemDel(cDetail),/*VerDatas(),*/FWRestRows(aLines)})  

//Remove campo da view
If !lPS400Auto
   oStruEJW:RemoveField("EJW_INT")
   oStruEJW:RemoveField("EJW_ORIGEM")
   oStruEJX:RemoveField("EJX_MODO")
EndIf

If ! EasyGParam("MV_ESS0021",,.F.)
   oStruEJW:RemoveField("EJW_CODEMP")
   oStruEJW:RemoveField("EJW_LOJEMP")
   oStruEJW:RemoveField("EJW_DSCEMP")
   oStruEJW:RemoveField("EJW_CGC")
EndIf

If EasyGParam("MV_ESS0004",,.F.) 
   oStruEL2:RemoveField("EL2_STTSIS") //Só deve aparecer na fase de registro.
EndIf

If !(EasyGParam("MV_ESS0027",,9) >= 10 .AND. EasyGParam("MV_ESS0004",,.F.))
   oStruEJX:RemoveField("EJX_MOVTEM")
Endif

//Liga a identificação do componente
oView:EnableTitleView("VIEW_EJW", "Processo", RGB(240,248,255))
oView:EnableTitleView("VIEW_EJX", "Serviços", RGB(240,248,255))
If EasyGParam("MV_ESS0004",,.F.)
   oView:EnableTitleView("VIEW_EL2", "Documentos", RGB(240,248,255))
EndIf
oView:bAfterViewActivate := {|oView| PS400ViewAtu(oView)} //FSM - 22/11/2012
oView:bCanActivate := {|oView| AtuView(oView)}
//oView:AddUserButton("Conhecimento"        , "CLIPS",{|| GetMsDocument()})
//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView


/*
Programa   : PS400Valid
Objetivo   : Validação dos campos que fazem parte da Rotina de Processo de Serviços
Parametros : Informação a ser validada
Retorno    : Lógico
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 20/08/2012 14:21 
Revisao    : 
*/

Function PS400Valid(cCampo)
Local oModel, oModelEJX, oModelEJW, oModelEL2  
Local cCont//, cCont2 
Local lRet       := .T. 
Local aOrd       := SaveOrd({"ELC"})   
Local cLoja      := ""
Default cCampo   := ""
oModel    := FWModelActive()

Begin Sequence

If ValType(oModel) == "O"
   oModelEJW := oModel:GetModel("EJWMASTER") 
   oModelEJX := oModel:GetModel("EJXDETAIL")
   oModelEL2 := oModel:GetModel("EL2DETAIL")
Else
	Break
EndIf  

If Substr(cCampo,1,3) == "EJX"
   If !Empty(PS400Info("EJX_STTPED")) .And. PS400Info("EJX_STTPED") <> "1" .AND. (!lIntPedServ .OR. PS400Info("EJX_STTPED") == "4")
      EasyHelp("O serviço não pode ser alterado pois apresenta status '" + BSCXBOX('EJX_STTPED',oModelEJX:GetValue("EJX_STTPED")) + "'","Aviso")
      lRet := .F.
      Break
   EndIf
EndIf

If Substr(cCampo,1,3) == "EJW"
   If oModel:GetOperation() == 4 .And. !Empty(PS400Info("EJW_STTPED")) .And. PS400Info("EJW_STTPED") <> "1" .AND. (!lIntPedServ .OR. PS400Info("EJX_STTPED") == "4")//FSM - 21/11/2012
      EasyHelp("O processo não pode ser alterado pois apresenta status '" + BSCXBOX('EJW_STTPED',oModelEJW:GetValue("EJW_STTPED")) + "'","Aviso")
      lRet := .F.
      Break
   EndIf
EndIf

Do Case
   Case cCampo == "EJX_NBS"
      cCont  := oModelEJX:GetValue("EJX_NBS")
      If !(vazio().Or.existcpo("EL0",cCont).And.LEN(ALLTRIM(cCont)) >= LEN(cCont).And.PS400VALNBS(cCont)/*FSY - 13/01/2013 - adicionado PS400VALNBS*/ )
         lRet := .F.
         //EasyHelp("Digite N.B.S valido! Selecione um N.B.S sem espaços e registrado no sistema.","Aviso")
         EasyHelp("Digite N.B.S valido! Selecione um N.B.S sem espaços, não esteja bloqueado e registrado no sistema.","Aviso")
      EndIf
       
   Case cCampo == "EJX_DTPRIN" .Or. cCampo == "EJX_DTPRFI" 
      //NOPADO por RRC - 14/10/2013 - Somente validar as datas após trocar de linha ou confirmar a ação
      /*cCont  := oModelEJX:GetValue("EJX_DTPRIN")
      cCont2 := oModelEJX:GetValue("EJX_DTPRFI")
     
      If !Empty(cCont) .And. !Empty(cCont2) .And. cCont > cCont2
         lRet := .F.
         EasyHelp("Data de Previsão Final deve ser maior ou igual a Data de Previsão Inicial.","Aviso")
      EndIf*/
      
   Case cCampo == "EJX_DTINI" .Or. cCampo == "EJX_DTFIM" 
      //NOPADO por RRC - 14/10/2013 - Somente validar as datas após trocar de linha ou confirmar a ação
      /*cCont  := oModelEJX:GetValue("EJX_DTINI") 
      cCont2 := oModelEJX:GetValue("EJX_DTFIM")
      
      If !Empty(cCont) .And. !Empty(cCont2) .And. cCont > cCont2
         lRet := .F.
         EasyHelp("Data Final deve ser maior ou igual a Data Inicial.","Aviso")
      EndIf*/
            
   Case cCampo == "EJX_VL_MOE"
   
      aValues := aClone(oModel:GetErrorMessage())
      
      //RRC - 11/10/2013 - Não deve validar diferença de um centavo caso seja chamada de MsExecAuto()
	  If !(Type("lPS400Auto") == "L" .And. lPS400Auto) .And. Abs(PS400Info("EJX_QTDE") * PS400Info("EJX_PRCUN") - M->EJX_VL_MOE) > 0.01
         lRet := .F.
         EasyHelp("O valor na moeda deve ser igual a quantidade multiplicado pelo preço unitário.","Aviso")
      ElseIf (aValues[2] == "EJX_PRCUN" .AND. PS400Info("EJX_SLDINV") + (aValues[8]-aValues[9]) < 0) .OR.;//(aValues[2] == "EJX_PRCUN" .AND. PS400Info("EJX_SLDINV") + PS400Info("EJX_QTDE") * (aValues[8]-aValues[9]) < 0) .OR.; //comentado por wfs - o array aValues[9] traz o valor total, apesar de vir identificado o campo EJX_PRCUN n a posição 2
             (aValues[2] == "EJX_VL_MOE" .AND. PS400Info("EJX_SLDINV") + (aValues[8]-aValues[9]) < 0)
             EEQ->(DbSetOrder(13)) //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROCES //LRS - 22/09/2014
             ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO //LRS - 22/09/2014
      		 If  ELA->(DbSeek(xFilial("ELA")+EJW->EJW_TPPROC+Alltrim(EJW->EJW_PROCES))) .AND.;
      		     EEQ->(DbSeek(xFilial("EEQ")+EJW->EJW_TPPROC+Alltrim(EJW->EJW_PROCES))) //LRS - 22/09/2014 - Verifica se Existe Invoice para poder alterar o valor
			     lRet := .F.
		         EasyHelp("O valor não pode ser menor do que o valor das invoices já emitidas para este serviço.","Aviso")
	     	 EndIF
      Else
         PS400SetDiff("EJW_VL_MOE")
      EndIf
      
   Case cCampo == "EJX_VL_REA"
      
      //RRC - 11/10/2013 - Não deve validar diferença de um centavo caso seja chamada de MsExecAuto()
      If !(Type("lPS400Auto") == "L" .And. lPS400Auto) .And. Abs(PS400Info("EJX_VL_MOE") * PS400Info("EJX_TX_MOE") - M->EJX_VL_REA) > 0.01
         lRet := .F.
         EasyHelp("O valor em reais deve ser igual ao valor da moeda multiplicado pela taxa da moeda.","Aviso")
      Else
         PS400SetDiff("EJW_VL_REA")
      EndIf
      
   /*Necessário atualizar os campos totalizadores EJW_VL_MOE  e EJW_VL_REA após alterar EJX_QTDE, EJX_TX_MOE e
   EJX_PRCUN. Ao alterar para o valor zero, os campos EJX_VL_REA e EJX_VL_MOE eram atualizados, mas a função de
   seus valids que atualizam os campos da capa EJW não eram executadas*/         
   
   Case cCampo == "EJX_QTDE" .Or. cCampo == "EJX_PRCUN"
      If Positivo()
         If PS400Info(cCampo) == 0
            oModelEJW:= oModel:GetModel("EJWMASTER")
            oModelEJW:SetValue("EJW_VL_MOE",oModelEJW:GetValue("EJW_VL_MOE")-oModelEJX:GetValue("EJX_VL_MOE"))
            oModelEJW:SetValue("EJW_VL_REA",oModelEJW:GetValue("EJW_VL_REA")-oModelEJX:GetValue("EJX_VL_REA"))
         EndIf
      Else
         lRet := .F.
      EndIf   
   
   Case cCampo == "EJX_TX_MOE"
      If Positivo()
         If PS400Info(cCampo) == 0
            oModelEJW:= oModel:GetModel("EJWMASTER")
            oModelEJW:SetValue("EJW_VL_REA",oModelEJW:GetValue("EJW_VL_REA")-oModelEJX:GetValue("EJX_VL_REA"))
         EndIf 
      Else
         lRet := .F.
      EndIf   
   
   Case cCampo == "EJX_ITEM"
      If !Empty(PS400Info("EJX_STTPED")) .And. PS400Info("EJX_STTPED") <> "1" .AND. (!lIntPedServ .OR. PS400Info("EJX_STTPED") == "4")
         lRet := .F.
         EasyHelp("O serviço não poderá ser alterado pois apresenta status '" + BSCXBOX('EJX_STTPED',oModelEJX:GetValue("EJX_STTPED")) + "'","Aviso")
      EndIf
      If lRet
         If !Vazio() .AND. !EXISTCPO("SB1",M->EJX_ITEM)
            lRet := .F.
         EndIf
      EndIf
      
   Case cCampo == "EJX_MODAQU" .Or. cCampo == "EJX_MODVEN"
      If oModelEJX:GetValue(cCampo) == "3"
         lRet := .F.
         EasyHelp("Esta opção não é válida para o Siscoserv.","Aviso")     
      EndIf      
   
   Case SubStr(cCampo,1,7) == "EJX_ENQ"
      If !Empty(oModelEJX:GetValue(cCampo)) .And. (lRet := ExistCpo("ELC",AvKey(oModelEJX:GetValue(cCampo),"ELC_CODENQ")))
         ELC->(DbSetOrder(1)) //ELC_FILIAL + ELC_CODENQ
         If Type("cPed") == "C" .And. cPed == "A" .And. ELC->(DbSeek(xFilial("ELC")+(oModelEJX:GetValue(cCampo)))) .And. !(lRet := ELC->ELC_MODAQU == "S")
            EasyHelp("Este enquadramento não está disponível para o Módulo de Aquisição","Aviso")     
         ElseIf Type("cPed") == "C" .And. cPed == "V" .And. ELC->(DbSeek(xFilial("ELC")+(oModelEJX:GetValue(cCampo)))) .And. !(lRet := ELC->ELC_MODVEN == "S")
            EasyHelp("Este enquadramento não está disponível para o Módulo de Venda","Aviso")
         EndIf   
      EndIf
      
   Case cCampo == "EJW_PROCES" 
      If lRet == .T. .AND. Type("M->EJW_PROCES") <> "U"  // GFP - 22/01/2014
         If !ExistChav("EJW",PS400Info("EJW_TPPROC")+M->EJW_PROCES)
            lRet := .F.
         EndIf
      EndIf 
  
   Case cCampo == "EJW_EXPORT"
      IF !SA2->( MSSEEK( xFilial("SA2") + M->EJW_EXPORT ))
        EasyHelp("Fornecedor "+Alltrim(M->EJW_EXPORT)+" não encontrado.","Aviso")
        lRet := .f.
      Else
        // MFR OSSME-2712
        cLoja := PS400Gatil("EJW_LOJEXP") // EJW->EJW_LOJEXP := PS400Gatil("EJW_LOJEXP")
        If !EasyGParam("MV_ESS0015",,.T.)
          If !Empty(cLoja) .And. EXISTCPO("SA2", M->EJW_EXPORT + cLoja) .And. !IsForeign("SA2", M->EJW_EXPORT+cLoja)
            lRet := .F.
            EasyHelp("Só é permitido utilizar fornecedor estrangeiro para importação de serviço.","Aviso")
          Else
            M->EJW_DSCEXP := SA2->A2_NOME
          EndIf
        Else
          If !Empty(cLoja)                                          //MFR OSSME-2712
            If lRet := EXISTCPO("SA2", M->EJW_EXPORT + cLoja) .And. SA2->(MSSEEK( xFilial("SA2") + M->EJW_EXPORT + cLoja))
              M->EJW_DSCEXP := SA2->A2_NOME
            EndIf
          EndIf
        EndIf
      EndIf  
   Case cCampo == "EJW_LOJEXP"
      If !Vazio()
        IF !Empty(PS400Info("EJW_EXPORT")) .And. !SA2->( MSSEEK( xFilial("SA2") + PS400Info("EJW_EXPORT") + M->EJW_LOJEXP ))
          EasyHelp("Fornecedor "+Alltrim(PS400Info("EJW_EXPORT"))+" loja "+M->EJW_LOJEXP+" não encontrado.","Aviso")
        EndIf
        If !EasyGParam("MV_ESS0015",,.T.)
          If !Empty(PS400Info("EJW_EXPORT"))
            If (lRet := EXISTCPO("SA2", PS400Info("EJW_EXPORT") + M->EJW_LOJEXP)) .And. !IsForeign("SA2", PS400Info("EJW_EXPORT")+M->EJW_LOJEXP)
              lRet := .F.
              EasyHelp("Só é permitido utilizar fornecedor estrangeiro para importação de serviço.","Aviso")
            Else
              M->EJW_DSCEXP := SA2->A2_NOME
            EndIf
          EndIf
        Else
          If !Empty(PS400Info("EJW_EXPORT")) 
            If (lRet := EXISTCPO("SA2", PS400Info("EJW_EXPORT") + M->EJW_LOJEXP)) .AND. SA2->(MSSEEK( xFilial("SA2") + PS400Info("EJW_EXPORT") + M->EJW_LOJEXP ))
              M->EJW_DSCEXP := SA2->A2_NOME
            EndIf
          EndIf
        EndIf
      EndIf
   Case cCampo == "EJW_IMPORT"
      IF !SA1->( MSSEEK( xFilial("SA1") + M->EJW_IMPORT ))
        EasyHelp("Cliente "+Alltrim(M->EJW_IMPORT)+" não encontrado.","Aviso")
        lRet := .F.
      Else
         // MFR OSSME-2712
         cLoja := PS400Gatil("EJW_LOJIMP")
         If !EasyGParam("MV_ESS0015",,.T.)
           If !Empty(cLoja) .And. EXISTCPO("SA1", M->EJW_IMPORT + cLoja) .And. !IsForeign("SA1", M->EJW_IMPORT+cLoja)
             lRet := .F.
             EasyHelp("Só é permitido utilizar cliente estrangeiro para exportação de serviço.","Aviso")
           Else
             M->EJW_DSCIMP := SA1->A1_NOME
           EndIf
         Else
           If !Empty(cLoja)                                          //MFR OSSME-2712
             If lRet := EXISTCPO("SA1", M->EJW_IMPORT + cLoja) .And. SA1->(MSSEEK( xFilial("SA1") + M->EJW_IMPORT + cLoja))
               M->EJW_DSCIMP := SA1->A1_NOME
             EndIf
           EndIf
         EndIf
      EndIf   
   Case cCampo == "EJW_LOJIMP"
      If !Vazio()
        IF !Empty(PS400Info("EJW_IMPORT")) .And. !SA1->( MSSEEK( xFilial("SA1") + PS400Info("EJW_IMPORT") + M->EJW_LOJIMP ))
          EasyHelp("Cliente "+Alltrim(PS400Info("EJW_IMPORT"))+" loja "+M->EJW_LOJIMP+" não encontrado.","Aviso")
        EndIf
        If !EasyGParam("MV_ESS0015",,.T.)
          If !Empty(PS400Info("EJW_IMPORT"))
            If (lRet := EXISTCPO("SA1", PS400Info("EJW_IMPORT") + M->EJW_LOJIMP)) .And. !IsForeign("SA1", PS400Info("EJW_IMPORT")+M->EJW_LOJIMP)
              lRet := .F.
              EasyHelp("Só é permitido utilizar cliente estrangeiro para exportação de serviço.","Aviso")
            Else
              M->EJW_DSCIMP := SA1->A1_NOME
            EndIf
          EndIf
        Else
          If !Empty(PS400Info("EJW_IMPORT")) 
            If (lRet := EXISTCPO("SA1", PS400Info("EJW_IMPORT") + M->EJW_LOJIMP)) .AND. SA1->( MSSEEK( xFilial("SA1") + PS400Info("EJW_IMPORT") + M->EJW_LOJIMP ))
              M->EJW_DSCIMP := SA1->A1_NOME
            EndIf
          EndIf
        EndIf
      EndIf  
   Case cCampo == "EJW_MOEDA"
      If !(lRet := EXISTCPO("SYF",M->EJW_MOEDA,1))
         lRet := .F.
      Else//FSY - condição incluida para que exiba mensagem no momento que o usuario alterar o campo.   
         If !Empty(cMoedaIni) .And. cMoedaIni != M->EJW_MOEDA  
            If !Empty(M->EJW_VL_MOE) .And. Type("lPS400Auto") == "L" .And. !lPS400Auto
               //MsgInfo("Será preciso alterar as taxas de conversão da moeda para reais, recalcular o(s) valor(es) manualmente e conferi-lo(s).","Aviso")
               EasyHelp("Será preciso alterar as taxas de conversão da moeda para reais, recalcular o(s) valor(es) manualmente e conferi-lo(s).","Aviso")  //SSS - REQ .8 13/06/2014
            EndIf
         EndIf 
         cMoedaIni := M->EJW_MOEDA//memorizar o ultimo valor na variavel private      
      EndIf
   Case cCampo == "EL2_RE" .Or. cCampo == "EL2_DI"
      If Type("cFase") # "U" .AND. cFase == "1"
      /*
         If ValType(oModelEJW) == "O" 
            If oModelEJW:GetValue("EJW_STTPED") <> "1"
               lRet := .F.
               EasyHelp("Este documento não pode ser alterado pois o Processo relacionado encontra-se em fase posterior: '" + BSCXBOX('EJW_STTPED',oModelEJW:GetValue("EJW_STTPED")) + "'.","Aviso")           
            EndIf
         EndIf
      */
         lRet := .T.
      Else
         If cCampo == "EL2_RE"
            lRet := RS400Valid("EL2_RE")
         ElseIf cCampo == "EL2_DI"
            lRet := RS400Valid("EL2_DI")
         EndIf
      EndIf   
   /*   
   Case cCampo == "EJW_DTENC" 
      If !Empty(M->EJW_DTENC) .And. If(Type("lPS400Auto") == "L" .And. !lPS400Auto,!MsgYesNo("Se a Data de Encerramento for preenchida, o processo será considerado encerrado, assim, nenhuma modificação poderá ocorrer. Deseja realmente isso?","Aviso"),.T.)
         lRet := .F.
      EndIf
   */
                  
   Case cCampo == "EJW_CODEMP"//FSY
      
      If cPed == "A"
         If !Vazio()
            lRet := EXISTCPO("SA1",M->EJW_CODEMP)
         EndIf
         
      ElseIf cPed == "V"
         If !Vazio()
            lRet := EXISTCPO("SA2",M->EJW_CODEMP)
         EndIf
         
      EndIf
      
   Case cCampo == "EJW_LOJEMP"//FSY
      If cPed == "A"
      
         If !Vazio()
            lRet := EXISTCPO("SA1",M->EJW_CODEMP+M->EJW_LOJEMP)
         EndIf
      
      ElseIf cPed == "V"
      
         If !Vazio()
            lRet := EXISTCPO("SA2",M->EJW_CODEMP+M->EJW_LOJEMP)
         EndIf
            
      EndIf
      
EndCase

End Sequence
RestOrd(aOrd,.T.)
Return lRet 

/*
Programa   : PS400GridVal
Objetivo   : Validação das linhas do Grid - Itens do Processo
Parametros : 
Retorno    : lRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 22/08/2012 09:44 
Revisao    : 
*/
        
Function PS400GridVal()
Local oModel, oModelEJX, oModelEL2 
Local cQtde, cVlMoe, cVlReal, cTxMoe, cPrecUn,  cDtPrFi, cDtPrIn, cDtFim, cDtIni
Local lRet := .T.
oModel    := FWModelActive()

If ValType(oModel) == "O"    
   oModel     := FWModelActive()
   oModelEJX  := oModel:GetModel("EJXDETAIL")
   oModelEL2  := oModel:GetModel("EL2DETAIL")
   cQtde      := oModelEJX:GetValue("EJX_QTDE")
   cVlMoe     := oModelEJX:GetValue("EJX_VL_MOE")
   cVlReal    := oModelEJX:GetValue("EJX_VL_REA")
   cTxMoe     := oModelEJX:GetValue("EJX_TX_MOE")
   cPrecUn    := oModelEJX:GetValue("EJX_PRCUN")
   cDtPrFi    := oModelEJX:GetValue("EJX_DTPRFI")
   cDtPrIn    := oModelEJX:GetValue("EJX_DTPRIN")
   cDtFim     := oModelEJX:GetValue("EJX_DTFIM")
   cDtIni     := oModelEJX:GetValue("EJX_DTINI")
    
   //Valida os valores com tolerência de 1 centavo
   //RRC - 11/10/2013 - Não deve validar diferença de um centavo caso seja chamada de MsExecAuto()
   If !(Type("lPS400Auto") == "L" .And. lPS400Auto) .And. Abs(cQtde * cPrecUn - cVlMoe) > 0.01 // BAK - 01/10/2012
      lRet := .F.
      EasyHelp("O valor da moeda deve ser igual a quantidade multiplicado pelo preço unitário, com tolerência de 1 centavo.","Aviso")
   EndIf 
   
   If !(Type("lPS400Auto") == "L" .And. lPS400Auto) .And. Abs(cVlMoe * cTxMoe - cVlReal) > 0.01 // BAK - 01/10/2012
      lRet := .F.
      EasyHelp("O valor em reais deve ser igual ao valor da moeda multiplicado pela taxa da moeda, com tolerência de 1 centavo.","Aviso")
   EndIf
   
   If !Empty(cDtPrFi) .And. !Empty(cDtPrIn)
      If cDtPrFi < cDtPrIn
         lRet := .F.
         EasyHelp("A data de previsão final deve ser maior ou igual a data de previsão inicial.","Aviso")
      EndIf
   EndIf
  
   If !Empty(cDtFim) .And. !Empty(cDtIni)
      If cDtFim < cDtIni
         lRet := .F.
         EasyHelp("A data real final deve ser maior ou igual a data real inicial.","Aviso")
      EndIf
   EndIf

EndIf 
  
Return lRet

/*
Programa   : PS400INFO
Objetivo   : Retornar o conteúdo atual requerido, equivalente a variável de memória para grids do mvc
             No grid do MVC, apenas a variável de memória do próprio campo é encontrada, isso durante sua edição
Parametros : Informação a ser pesquisada 
Retorno    : cRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 21/08/2012 10:33 
Revisao    : 
*/

Function PS400Info(cInfo)

Local oModel, oModelEJX, oModelEJW, oModelEL2 
Local cRet    := ""
Local aOrd    := SaveOrd({"SB1","EJX","EL0","SYA","SE4"})
Default cInfo := ""

If Substr(cInfo,1,3) == "EJW"
   oModel    := FWModelActive()
   oModelEJW := oModel:GetModel("EJWMASTER")
EndIf

If Substr(cInfo,1,3) == "EJX"
   oModel    := FWModelActive()
   oModelEJX := oModel:GetModel("EJXDETAIL")
EndIf 

If Substr(cInfo,1,3) == "EL2"
   oModel    := FWModelActive()
   oModelEL2 := oModel:GetModel("EL2DETAIL")
EndIf

Do Case
   Case cInfo == "EJW_IMPORT"
      cRet := oModelEJW:GetValue("EJW_IMPORT")
   Case cInfo == "EJW_LOJIMP"
      cRet := oModelEJW:GetValue("EJW_LOJIMP")
   Case cInfo == "EJW_EXPORT"
      cRet := oModelEJW:GetValue("EJW_EXPORT")
   Case cInfo == "EJW_LOJEXP"
      cRet := oModelEJW:GetValue("EJW_LOJEXP")
   
   Case cInfo == "EJX_ITEM" 
      cRet := oModelEJX:GetValue("EJX_ITEM")
      
   Case cInfo == "EJX_MODO"
      If Type("cPed") == "C" .And. cPed == "V"
         cRet := oModelEJX:GetValue("EJX_MODVEN")   
      ElseIf Type ("cPed") == "C" .And. cPed == "A"
         cRet := oModelEJX:GetValue("EJX_MODAQU") 
      Endif
             
   Case cInfo == "EJX_QTDE" 
      cRet := oModelEJX:GetValue("EJX_QTDE") 
   
   Case cInfo == "EJX_PRCUN"
      cRet := oModelEJX:GetValue("EJX_PRCUN")  
   
   Case cInfo == "EJX_VL_MOE" 
      cRet := oModelEJX:GetValue("EJX_VL_MOE")

   Case cInfo == "EJX_SLDINV" 
      cRet := oModelEJX:GetValue("EJX_SLDINV")
        
   Case cInfo == "EJX_SEQPRC"    
      cRet := oModelEJX:GetValue("EJX_SEQPRC")
      
   Case cInfo == "EJX_TX_MOE"    
      cRet := oModelEJX:GetValue("EJX_TX_MOE")
        
   Case cInfo == "EJX_VL_REA" 
      cRet := oModelEJX:GetValue("EJX_VL_REA")
      
   Case cInfo == "EJX_STTPED" 
      cRet := oModelEJX:GetValue("EJX_STTPED")

   Case cInfo == "EJX_NBS"        
      cRet := oModelEJX:GetValue("EJX_NBS")

   Case cInfo == "EJX_PAIS"        
      cRet := oModelEJX:GetValue("EJX_PAIS")

   Case cInfo == "EJW_VL_MOE"    
      cRet := oModelEJW:GetValue("EJW_VL_MOE")
       

   Case cInfo == "EJW_TPPROC"
      If Type("cPed") == "C" .And. cPed == "V"
         cRet := "V"  
      ElseIf Type ("cPed") == "C" .And. cPed == "A"
         cRet := "A"
      Endif
   
   Case cInfo == "EJW_INT"
      If Type("cPed") == "C" .And. cPed == "V"
         cRet := "N"
      Else
         cRet := "S"
      EndIf
      
   Case cInfo == "EJW_PROCES"        
      cRet := oModelEJW:GetValue("EJW_PROCES")
      
   Case cInfo == "EJW_STTPED"        
      cRet := oModelEJW:GetValue("EJW_STTPED")

   Case cInfo == "EJW_CONDPG"        
      cRet := oModelEJW:GetValue("EJW_CONDPG")

   //Tratamento abaixo para variáveis que pertencem a gatilhos e não são encontradas durante ExecAuto 
   Case cInfo == "B5_NBS"        
      cRet := Posicione("SB5",1,xFilial("SB5")+AvKey(PS400Info("EJX_ITEM"),"B5_COD"),"B5_NBS") 
   
   Case cInfo == "B1_DESC"        
      cRet := Posicione("SB1",1,xFilial("SB1")+AvKey(PS400Info("EJX_ITEM"),"B1_COD"),"B1_DESC") 
   
   Case cInfo == "B1_UM"        
      cRet := Posicione("SB1",1,xFilial("SB1")+AvKey(PS400Info("EJX_ITEM"),"B1_COD"),"B1_UM") 
   
   Case cInfo == "EYJ_MODSER"        
      cRet := Posicione("EYJ",1,xFilial("EYJ")+AvKey(PS400Info("EJX_ITEM"),"EYJ_COD"),"EYJ_MODSER") 
   
   Case cInfo == "EL0_DESC"        
      cRet := Posicione("EL0",1,xFilial("EL0")+AvKey(PS400Info("EJX_NBS"),"EL0_COD"),"EL0_DESC") 
   
   Case cInfo == "YA_DESCR"        
      cRet := Posicione("SYA",1,xFilial("SYA")+AvKey(PS400Info("EJX_PAIS"),"YA_CODGI"),"YA_DESCR") 
   
   Case cInfo == "E4_DESCRI"        
      cRet := Posicione("SE4",1,xFilial("SE4")+AvKey(PS400Info("EJW_CONDPG"),"E4_CODIGO"),"E4_DESCRI") 
   
   Case cInfo == "EL2_SEQREG"
      cRet := Space(AvSx3("EL2_SEQREG",AV_TAMANHO))
   
   Case cInfo == "EL2_REGIST"
      cRet := Space(AvSx3("EL2_REGIST",AV_TAMANHO))
   /*
   Case cInfo == "EL2_FASE" 
      cRet := oModelEL2:GetValue("EL2_FASE")
      If Empty(cRet)
         cRet := "1"
      EndIf  
   */                
EndCase
RestOrd(aOrd,.T.)
Return cRet

/*
Programa   : MostrCpo
Objetivo   : Verificar quais campos devem compor a estrutura  (Campos para Processo de Aquisição ou Venda de Serviços)
Parametros : Campos a serem verificados
Retorno    : lRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 21/08/2012 15:17 
Revisao    : 
*/

Static Function MostrCpo(cCpo)

Local lRet := .T.           
Local aCampos

   If Type("cPed") == "C" 
      /*
      If cPed == "V" .And. Alltrim(cCpo) $ "EJW_EXPORT/EJW_LOJEXP/EJW_DSCEXP/EJX_MODAQU"
         lRet := .F.
      EndIf
      If cPed == "A" .And. Alltrim(cCpo) $ "EJW_IMPORT/EJW_LOJIMP/EJW_DSCIMP/EJX_MODVEN"
         lRet := .F.
      EndIf
      */
      If cPed == "V"
         If lPS400Auto 
            aCampos := {"EJW_EXPORT" , "EJW_LOJEXP" , "EJW_DSCEXP" , "EJX_MODAQU" , "EL2_SEQREG" , "EL2_FASE"}
            If !EasyGParam("MV_ESS0027",,9) >= 10
               aadd(aCampos,"EL2_DI")
            EndIf
         Else
            If !EasyGParam("MV_ESS0027",,9) >= 10
               aCampos := {"EJW_EXPORT" , "EJW_LOJEXP" , "EJW_DSCEXP" , "EJX_MODAQU" , "EL2_REGIST" , "EL2_SEQREG" , "EL2_DI" , "EL2_PROCES" , "EL2_FASE" , "EL2_SEQPRC" , "EL2_SEQPAG"}
            Else
               aCampos := {"EJW_EXPORT" , "EJW_LOJEXP" , "EJW_DSCEXP" , "EJX_MODAQU" , "EL2_REGIST" , "EL2_SEQREG" , "EL2_PROCES" , "EL2_FASE" , "EL2_SEQPRC" , "EL2_SEQPAG"}
            EndIf
         EndIf
      EndIf

      If cPed == "A"
         If lPS400Auto 
            aCampos := {"EJW_IMPORT", "EJW_LOJIMP", "EJW_DSCIMP", "EJX_MODVEN", "EL2_SEQREG", "EL2_FASE"}
            If !EasyGParam("MV_ESS0027",,9) >= 10
               aadd(aCampos,"EL2_RE")
            EndIf
         Else
            If !EasyGParam("MV_ESS0027",,9) >= 10
               aCampos := {"EJW_IMPORT", "EJW_LOJIMP", "EJW_DSCIMP", "EJX_MODVEN", "EL2_REGIST", "EL2_SEQREG", "EL2_RE", "EL2_PROCES", "EL2_FASE", "EL2_SEQPRC", "EL2_SEQPAG"}
            Else
               aCampos := {"EJW_IMPORT", "EJW_LOJIMP", "EJW_DSCIMP", "EJX_MODVEN", "EL2_REGIST", "EL2_SEQREG", "EL2_PROCES", "EL2_FASE", "EL2_SEQPRC", "EL2_SEQPAG" }
            EndIf
         EndIf 
      EndIf
      
      //RRC - 08/05/2013
      If !lIntPedServ
         aAdd(aCampos,"EJW_MSGLOG")
      EndIf

      If aScan(aCampos,{|X| X == AllTrim(cCpo)}) > 0
         lRet := .F.
      EndIf        

   EndIf
   
Return lRet                                                                 

/*
Programa   : GravCamp
Objetivo   : Gravação de registro no conteúdo de campos não pertencentes ao model
Parametros : Objeto do Model
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 23/08/2012 09:42 
Revisao    : 
*/
Static Function GravCamp(oMdl)
Local aOrd       := SaveOrd({"EJX"})
Local aProcessos := {}
Local aProcs     := {}
Local cCont, cModo, cProcAlt
Local oModelEJX  := oMdl:GetModel("EJXDETAIL")
Local oModelEL2  := oMdl:GetModel("EL2DETAIL")
Local nOperation := oMdl:GetOperation()
Local nI
Local cCampo := ""      
Local cEmpr        := ""
Local cLoja        := ""
Local cEmprAlt     := ""
Local cLojaAlt     := ""
Local cProcesso    := ""
Local lRet := .T.
Local lAltEmpr  := .F.

If Type("lPS400Auto") <> "L"
   lPS400Auto:= .F.
EndIf

Begin Transaction
 
If Type("cPed") == "C"
   If cPed == "V"
      cCont  := "V"
      cModo  := "EJX_MODVEN"
      cCampo := "EL2_RE" 
   Else
      cCont  := "A"
      cModo  := "EJX_MODAQU"
      cCampo := "EL2_DI"
   EndIf
   
   If nOperation == ALTERAR
      If cPed == "V"
         cEmprAlt := EJW->EJW_IMPORT
         cLojaAlt := EJW->EJW_LOJIMP
      ElseIf cPed == "A"
         cEmprAlt := EJW->EJW_EXPORT
         cLojaAlt := EJW->EJW_LOJEXP
      EndIf
      cProcAlt := EJW->EJW_PROCES
   EndIf
   //Salva as operações efetuadas anteriormente  
   FWFormCommit(oMdl)
   cProcesso := EJW->EJW_PROCES 
   If cPed == "V"
      cEmpr := EJW->EJW_IMPORT
      cLoja := EJW->EJW_LOJIMP
   ElseIf cPed == "A"
      cEmpr := EJW->EJW_EXPORT
      cLoja := EJW->EJW_LOJEXP
   EndIf
   
   //Caso altera o campo chave do Número do Processo, deve atualizar todas as tabelas envolvidas
   If nOperation == ALTERAR .And. !(cProcAlt == cProcesso)
      Aadd(aProcessos,{cProcAlt,cProcesso})
      PS400AltProc(aProcessos,cCont)
   EndIf
   
   //RRC - 23/05/2013 - Verifica se houve alteração do cliente/fornecedor ou da loja
   If nOperation == ALTERAR .And. (!(cEmpr == cEmprAlt) .Or. !(cLoja == cLojaAlt))
      lAltEmpr := .T.
      Aadd(aProcs,{cProcesso,cEmprAlt,cEmpr,cLojaAlt,cLoja})
   EndIf
   
   //LGS - 30/12/2015 - Verifica se houve alteração do campo EJW_COMPL e Atualiza o campo EJY_COMPL 
   If nOperation == ALTERAR .And. EasyGParam("MV_ESS0024",,.F.) //O Conteudo inicializador do parametro é FALSO .F.
      If !Empty(M->EJW_COMPL)
         aOrdEJY:= SaveOrd({"EJY"})
         cQUERY := "  SELECT R_E_C_N_O_ AS RECNO FROM " + RetSqlName("EJY") 
         cQUERY += "  WHERE D_E_L_E_T_ <> '*' AND EJY_TPPROC = '" + EJW->EJW_TPPROC 
         cQUERY += "' AND EJY_PROCES = '" + EJW->EJW_PROCES + "'"
         cQUERY := ChangeQuery(cQuery)
      
         DbUseArea(.T., "TopConn", TCGenQry(,, cQUERY), "TABEJY", .T., .T.) 
         TABEJY->(DBGotop())
         Do While TABEJY->(!EOF())
            EJY->(DbGoTo( TABEJY->RECNO ))
            
            If EJY->EJY_COMPL <> M->EJW_COMPL
               EJY->( RecLock("EJY",.F.) )
               EJY->EJY_COMPL := M->EJW_COMPL
               EJY->( MsUnLock())         
            EndIf
            TABEJY->(DbSkip())
         EndDo
         TABEJY->(dbCloseArea())
         RestOrd(aOrdEJY,.T.)
      EndIf
   EndIf
   
   If nOperation <> MODEL_OPERATION_DELETE
      If EJW->( RECLOCK("EJW",.F.) )
         EJW->EJW_TPPROC := cCont
         EJW->(MSUNLOCK())
      EndIf
      //Atualiza o Modo de Prestação de serviços de acordo com o campo Virtual utilizado
      //"EJX_MODAQU" - "Aquisição" ou "EJX_MODVEN" - "Venda"
      //Estes campos são combos que possuem opções diferentes
      EJX->(DbSetOrder(1))
      For nI := 1 To oModelEJX:Length()
         oModelEJX:GoLine(nI)
         If !oModelEJX:IsDeleted()            
            If EJX->(DbSeek(xFilial("EJX") + AvKey(cCont,"EJX_TPPROC") + AvKey(cProcesso,"EJX_PROCES") +AvKey(oModelEJX:GetValue("EJX_SEQPRC"),"EJX_SEQPRC")))    
               /*RRC - 29/07/2013 - Quando for um Processo originado no SIGACOM ou SIGAFAT sem qualquer tipo de customização ou uma alteração decorrente de uma alteração do valor na invoice
                não terá acesso a informação do campo "Modo de Serviço", neste caso, impede que o ocorra o risco de alterar um registro já gravado pelo SIGAESS para um valor em branco*/
               If !IsInCallStack("IS400GRAVA") .And. !((AllTrim(EJW->EJW_ORIGEM) == "SIGACOM" .Or. AllTrim(EJW->EJW_ORIGEM) == "SIGAFAT") .And. lPS400Auto .And. Empty(oModelEJX:GetValue(cModo)) .And. Empty(CriaVar("EJX_MODAQU")))
                  If EJX->( RECLOCK("EJX",.F.) )
                     EJX->EJX_MODO := If(!Empty(oModelEJX:GetValue(cModo)),oModelEJX:GetValue(cModo),CriaVar("EJX_MODAQU"))
                     EJX->(MSUNLOCK())
                  EndIf
               EndIf
            EndIf
         Else
            //Verifique se o item possui valor agregado alguma invoice
            PS400ItemInv(oModelEJX:GetValue("EJX_SEQPRC"),.T.)
         EndIf
      Next
      
      If nOperation == MODEL_OPERATION_INSERT
         EL2->(DbSetOrder(1))
         For nI := 1 To oModelEL2:Length()
            oModelEL2:GoLine(nI)
            If !oModelEL2:IsDeleted()
               If EL2->(DbSeek(xFilial("EL2")+Space(Len(EL2->EL2_TPPROC))+Space(Len(EL2->EL2_REGIST))+;
                                              Space(Len(EL2->EL2_SEQREG))+AvKey(EJW->EJW_PROCES,"EL2_PROCES")+;
                                              Space(Len(EL2->EL2_SEQPRC))+Space(Len(EL2->EL2_SEQPAG))+;
                                              AvKey(oModelEL2:GetValue("EL2_SEQDOC"),"EL2_SEQDOC")))               
                  If EL2->( RECLOCK("EL2",.F.) )
                     EL2->EL2_TPPROC := cCont
                     EL2->(MSUNLOCK())
                  EndIf               
               EndIf
            EndIf
         Next
      EndIf 
      //NCF - 07/03/2013 - (ExecAuto Registro) - Inicio do tratamento para exclusão de documentos deletados do Processo
      /*For nI := 1 To oModelEL2:Length()
         oModelEL2:GoLine(nI)
         //Ao encontrar um RE ou uma DI em branco, o Documento e o status for 1 - "Aguardando Registro no Siscoserv", deletará a linha
         //Se o status for diferente disso, grava com o campo em branco, para que não perca o vínculo com a EL7
         If !oModelEL2:IsDeleted() .And. (oModelEL2:GetValue("EL2_STTSIS") == "1" .OR. EasyGParam("MV_ESS0027",,9) >= 10) .And. Empty(oModelEL2:GetValue(cCampo))
            oModelEL2:DeleteLine()
         EndIf
      Next     */                    
                  
      //Atualiza status do processo
      //igorchiba  17/06/14 se for cancelamento o status deve ser o que esta chegando
      IF !LCANCEL
         RS400StaPed(cCont,cProcesso)
      ENDIF
      //RRV - 02/04/2013 - Atualiza o status de pagamento.
      PS400StaPag(cPed, cProcesso)       
   EndIf

   //MFR 20/07/2017 TE-6287 WCC-523509
   if lIntPedServ
      EJW->EJW_MSGLOG := ''
     if nOperation <> MODEL_OPERATION_INSERT // Executa na exclusao ou alteracao
         PS400GeraReg(nOperation,.f.,.f.,.t.)
      EndIf
   EndIf
EndIf

End Transaction

//Gera registro automático a partir do processo   
If lIntPedServ
   //Função que verifica se existem Registros onde os Serviços deste processo estão relacionados.
   //Para os serviços que estão em algum registro, serão montados os arrays e chamada a rotina 
   //automática de Registro em modo de ALTERAÇÃO. Para serviços que não estejam em nenhum Registro, 
   //serão montados os arrays e chamada a rotina automática de Registro em modo de INCLUSÃO.                                              
   //Para Rotina de exclusão, será montado o array de capa e excluído o referido Registro        
   //RRC - 22/05/2013 - Verifica se houve alteração para um cliente/fornecedor e loja válidos, caso possua uma invoice, deve atualizar os dados
   If (lGerouReg := PS400GeraReg(nOperation,,lAlteraValor)) .And. lAltEmpr
      If Type("cPed") == "C"
         Begin Transaction
            PS400EmprAlt(aProcs,cPed)
         End Transaction
      EndIf   
   EndIf
   If lGerouReg  // GFP - 10/11/2014
      EJX->(DbSetOrder(1))
      If EJX->(DbSeek(xFilial("EJX")+EJW->EJW_TPPROC+EJW->EJW_PROCES))
         Do While EJX->(!Eof()) .AND. EJX->EJX_FILIAL == xFilial("EJX") .AND. EJX->EJX_TPPROC == EJW->EJW_TPPROC .AND. EJX->EJX_PROCES == EJW->EJW_PROCES
            If !Empty(EJX->EJX_DTINI)
               RS400StaPed(cCont,cProcesso,EJX->EJX_SEQPRC)
               Exit
            EndIf
            EJX->(DbSkip())
         EndDo
      EndIf
   EndIf
EndIF  
  
RestOrd(aOrd,.T.)   
Return lRet 

/*
Programa   : PS400PrxNum()
Objetivo   : Retornar a próxima sequência de Itens do Processo de Serviço a ser utilizada
Parametros : 
Retorno    : cSequen
Autor      : Rafael Ramos Capuano
Data/Hora  : 23/08/2012 09:42 
Revisao    : 
*/
/*FSY - 04/12/13 - Movido para a função PS400PRXNUM
Function PS400PrxNum(cCampo)

Local oModel     := FWModelActive() 
Local oModelEJX  := oModel:GetModel("EJXDETAIL")
Local oModelEL2  := oModel:GetModel("EL2DETAIL")
Local oModelUse 
Local nOperation := oModel:GetOperation()
Local nPrxSeq    := 1
Local cSequen    := ""
Local cSeqAtu 

   //Posiciona no última linha dos Itens do Registro de Serviços ou Documentos
   Do Case
      Case cCampo == "EJX_SEQPRC"
         oModelUse := oModelEJX
      
      Case cCampo == "EL2_SEQDOC" 
         oModelUse := oModelEL2
      
      Case cCampo == ""
         Return cCampo           
   EndCase
    
   //Posiciona no última linha de Itens de Processo       
   If nOperation == 3 .And. oModelUse:nLine == 0
      cSequen := StrZero(nPrxSeq,AvSx3(cCampo,AV_TAMANHO))
   ElseIf oModelUse:nLine <> 0
      oModelUse:GoLine(oModelUse:Length())
      cSeqAtu := oModelUse:GetValue(cCampo)
      nPrxSeq := Val(cSeqAtu)
      nPrxSeq := nPrxSeq + 1
      cSequen := StrZero(nPrxSeq,AvSx3(cCampo,AV_TAMANHO))
   Else
      cSequen := StrZero(nPrxSeq,AvSx3(cCampo,AV_TAMANHO))
   EndIf 
   
Return cSequen 
*/
/*
Programa   : ItemDel()
Objetivo   : Chamar a função PS400Trig() para atualizar o valor dos campos EJW_VL_MOE e EJW_VL_REA caso delete ou recupera um item deletado
Parametros : 
Retorno    : lRet
Autor      : Rafael Ramos Capuano
Data/Hora  : 23/08/2012 12:21 
Revisao    : 
*/
Function ItemDel(cDetail)
Local oModel     := FWModelActive()
Local oModelEJW  := oModel:GetModel("EJWMASTER")
Local oModelEJX  := oModel:GetModel("EJXDETAIL")
Local oModelEL2  := oModel:GetModel("EL2DETAIL")
Local oView      := FWViewActive()
Local lDel       := .T.
Local aOrd       := SaveOrd({"EJZ","EL4","EL8"})

//RRC - 10/09/2013 - Revisão no tratamento
If cDetail == "EJXDETAIL"//cDetail == "EJZDETAIL"     
   /*Valida pelo status do Processo (se tem ou não RAS/RVS) apenas quando o parâmetro MV_ESS0003 estiver (Geração automática de RAS/RVS) estiver desabilitado,
   já que neste caso, a ideia é excluir de lá também, mas para isso, não pode ter gerado lote de RAS/RVS*/
   If !Empty(oModelEJX:GetValue("EJX_STTPED")) .And. oModelEJX:GetValue("EJX_STTPED") <> "1" .AND. (!lIntPedServ .OR. oModelEJX:GetValue("EJX_STTPED") == "4")
      lDel := .F.
      EasyHelp("Este serviço não pode ser excluído pois apresenta status '" + BSCXBOX('EJX_STTPED',oModelEJX:GetValue("EJX_STTPED")) + "'","Aviso")
   Else
      EJZ->(DbSetOrder(3)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES+EJZ_SEQPRC
      EL4->(DbSetOrder(1)) //EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG+EL4_SQEVIT
      EL8->(DbSetOrder(2)) //EL8_FILIAL+EL8_IDLOTE
      If Type("cPed") == "C" .And. EJZ->(DbSeek(xFilial("EJZ")+cPed+oModelEJW:GetValue("EJW_PROCES")+oModelEJX:GetValue("EJX_SEQPRC"))) 
         If EL4->(DbSeek(xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG))
            //RRC - 28/11/2013 - Alteração para somente validar caso o lote não tenha sido cancelado
            Do While EL4->(!Eof()) .And. EL4->(EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG) == xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG
               If EL8->(DbSeek(xFilial("EL8")+EL4->EL4_IDLOTE)) .And. EL8->EL8_STATUS <> "C" .AND. !(EL8->EL8_STATUS == "P" .AND. Empty(EL4->EL4_NROREG)) //AAF 11/01/2017 - Permite estorno dos casos em que foi processado, mas não foi registrado no Siscoserv.
                  lDel := .F.
                  EasyHelp("Este serviço não pode ser excluído pois está vinculado a um lote não cancelado.","Aviso")
                  Exit
               EndIf
               EL4->(DbSkip())
            EndDo
         EndIf
      EndIf   
   EndIf  
   
   If !lDel .And. oModelEJX:IsDeleted()
      If Type("lPS400Auto") == "L" .And. !lPS400Auto
         oView:GETVIEWOBJ("EJXDETAIL")[3]:Refresh() //Atualiza o objeto
      EndIf
      oModelEJX:UnDeleteLine()
      RestOrd(aOrd,.T.)
      Return
   EndIf
   //RRC - 10/09/2013 - Verifica se possui invoice, neste caso, não poderá excluir
   If oModelEJX:IsDeleted() .And. cDetail == "EJXDETAIL" .And. Type("cPed") == "C"
      If !PS400ItemInv(oModelEJX:GetValue("EJX_SEQPRC"))
         RestOrd(aOrd,.T.)
         Return
      EndIf
   EndIf
   
   If oModelEJX:IsDeleted()  
      PS400Trig(0,oModelEJX:GetValue("EJX_VL_MOE"),"EJW_VL_MOE")
      PS400Trig(0,oModelEJX:GetValue("EJX_VL_REA"),"EJW_VL_REA") 
   Else   
      PS400Trig(oModelEJX:GetValue("EJX_VL_MOE"),0,"EJW_VL_MOE")
      PS400Trig(oModelEJX:GetValue("EJX_VL_REA"),0,"EJW_VL_REA")
   EndIf
Else
   If oModelEL2:GetValue("EL2_STTSIS") <> "1"// .Or. !Empty(M->EJW_DTENC)
      cMsg := "Este documento não pode ser excluído pois apresenta:"
      If oModelEL2:GetValue("EL2_STTSIS") <> "1" .AND. (!lIntPedServ .OR. oModelEL2:GetValue("EL2_STTSIS") == "3")
         cMsg += " Status '" + BSCXBOX('EL2_STTSIS',oModelEL2:GetValue("EL2_STTSIS")) + "'."
      EndIf
      /*If !Empty(M->EJW_DTENC)
         cMsg += " Data de Encerramento preenchida."
      EndIf*/
      EasyHelp(cMsg,"Aviso")
      If oModelEL2:IsDeleted()
         If Type("lPS400Auto") == "L" .And. !lPS400Auto
            oView:GETVIEWOBJ("EL2DETAIL")[3]:Refresh() //Atualiza o objeto
         EndIf
         oModelEL2:UnDeleteLine()
         RestOrd(aOrd,.T.)
         Return
      EndIf
   EndIf  
EndIf
RestOrd(aOrd,.T.)
Return .T.                             

/*
Programa   : PS400Trig()
Objetivo   : Atualizar o valor de campos caso delete ou recupera um item deletado
Parametros : ValorAtual - Valor do qual será subtraído caso esteja deletando
             ValorAnterior - Valor 
             cDestino - Campo Destino
Retorno    : 
Autor      : Rafael Ramos Capuano
Data/Hora  : 23/08/2012 12:44 
Revisao    : 
*/

Function PS400Trig(nValorAtual,nValorAnterior,cDestino)
Local oModel    := FWModelActive()
Local oModelEJW := oModel:GetModel("EJWMASTER")
Local oView     := FWViewActive()

oModelEJW:SetValue(cDestino,oModel:GetValue("EJWMASTER",cDestino)+nValorAtual-nValorAnterior)
//oView:Refresh()
//oView:updategets()
If Type("lPS400Auto") == "L" .And. !lPS400Auto
   oView:GETVIEWOBJ("EJWMASTER")[3]:Refresh()
EndIf
Return

Function PS400SetDiff(cDestino)
Local oModel    := FWModelActive()
Local aErrMsg   := oModel:GetErrorMessage()

If Valtype(aErrMsg[8]) == AvSx3(cDestino,AV_TIPO) .And. Valtype(aErrMsg[9]) == AvSx3(cDestino,AV_TIPO)
   //Atualiza conteúdo de campo de Processo de Serviços
   oModel:SetValue("EJWMASTER",cDestino,oModel:GetValue("EJWMASTER",cDestino)+aErrMsg[8]-aErrMsg[9])
EndIf

Return .T.

/*
Programa   : SomaVal()
Objetivo   : Utilizada via ExecView, soma os valores dos campos EJX_VL_MOE, EJX_VL_REA pertencentes ao itens do Processo de Serviço
             para atualizar os campos EJW_VL_MOE e EJW_VL_REA pertencentes a capa.
Parametros : 
Retorno    : 
Autor      : Rafael Ramos Capuano
Data/Hora  : 30/08/2012 15:37 
Revisao    : 
*/

Static Function SomaVal()
Local oModel    := FWModelActive()
Local oModelEJW := oModel:GetModel("EJWMASTER")
Local oModelEJX := oModel:GetModel("EJXDETAIL")
Local nLinha    := 1
Local nVlMoe    := 0
Local nVlRea    := 0
   
For nLinha := 1 To oModelEJX:Length()
   oModelEJX:GoLine(nLinha)
   If !oModelEJX:IsDeleted() 
      nVlMoe += oModelEJX:GetValue("EJX_VL_MOE")
      nVlRea += oModelEJX:GetValue("EJX_VL_REA")
   EndIf
Next
oModelEJW:SetValue("EJW_VL_MOE",nVlMoe)
oModelEJW:SetValue("EJW_VL_REA",nVlRea)

Return .T.


/*
Programa   : PS400Relacao()
Objetivo   : Iniciar o conteúdo dos campos especificados, X3_RELACAO
Parametros : cCampo
Retorno    : 
Autor      : Rafael Ramos Capuano
Data/Hora  : 28/08/2012 12:29 
Revisao    : 
*/

Function PS400Relacao(cCampo)
Local cRet       := ""
Local oModel
Local oModelEJX
Local aOrd       := SaveOrd({"SB1","EL0","SYA","SE4"})
 
Default cCampo   := ""

//If Type("lPS400Auto") == "L" .And. !lPS400Auto
   oModel := FWModelActive() //Necessário para o método GetOperation()
//ElseIf Type("lPS400Auto") == "L" .And. lPS400Auto
//   FWLoadModel("ESSPS400")  //Utiliza este método caso seja ExecAuto
//EndIf

//If ValType(oModel) == "O"
   oModelEJX  := oModel:GetModel("EJXDETAIL")
//EndIf

Do Case
   Case cCampo == "EJW_ORIGEM"
      //If Type("lPS400Auto") == "L" .And. !lPS400Auto
         //If Type("cPed") == "C" .And. cPed == "V"   
         //   cRet := "SIGAEEC"   
         //EndIf
         //If Type("cPed") == "C" .And. cPed == "A"   
         //   cRet := "SIGAEIC"   
         //EndIf
      //EndIf
      cRet := "ESSPS400"
   
   Case cCampo == "EJW_INT"
      If Type("lPS400Auto") == "L" .And. !lPS400Auto
         cRet := "N"
      EndIf
      If Type("lPS400Auto") == "L" .And. lPS400Auto
         cRet := "S"
      EndIf
   
   Case cCampo == "EJX_DSCITE" .And. ValType(oModelEJX) == "O"
      If /*Type("lPS400Auto") == "L" .And. !lPS400Auto .And.*/ oModel:GetOperation() <> 3 .And. oModelEJX:nLine == 0
         cRet := Posicione("SB1",1,xFilial("SB1")+AvKey(EJX->EJX_ITEM,"B1_COD"),"B1_DESC") 
      EndIf 
   
   Case cCampo == "EJX_DTPRFI"
      cRet := CToD("31/12/"+AllTrim(Str(Year(dDataBase))))
      
   Case cCampo == "EJX_DSCNBS" .And. ValType(oModelEJX) == "O"
      If /*Type("lPS400Auto") == "L" .And. !lPS400Auto .And.*/ oModel:GetOperation() <> 3 .And. oModelEJX:nLine == 0
         cRet := Posicione("EL0",1,xFilial("EL0")+AvKey(EJX->EJX_NBS,"EL0_COD"),"EL0_DESC")
      EndIf
   
   Case cCampo == "EJX_DSCPAI" .And. ValType(oModelEJX) == "O"
      If Type("lPS400Auto") == "L" .And. !lPS400Auto .And. oModel:GetOperation() <> 3 .And. oModelEJX:nLine == 0
         cRet := Posicione("SYA",1,xFilial("SYA")+AvKey(EJX->EJX_PAIS,"YA_CODGI"),"YA_DESCR") 
      EndIf 
      
   Case cCampo == "EJW_DSCCON" .And. ValType(oModelEJX) == "O"
      If Type("lPS400Auto") == "L" .And. !lPS400Auto .And. oModel:GetOperation() <> 3 .And. oModelEJX:nLine == 0
         cRet := Posicione("SE4",1,xFilial("SE4")+AvKey(EJW->EJW_CONDPG,"E4_CODIGO"),"E4_DESCRI") 
      EndIf 
   
   Case cCampo == "EJW_DTPROC"
      cRet := dDataBase
   
   Case cCampo == "EJW_STTPED"
      cRet := "1"
      //Opcão de Combo: 1 - "Aguardando o registro"
      
   Case cCampo == "EJX_STTPED"
      cRet := "1"
      //Opcão de Combo: 1 - "Aguardando o registro" 
    
   Case cCampo == "EJX_MODAQU" .Or. cCampo == "EJX_MODVEN" 
      //NOPADO por RRC - 14/10/2013 - Deverá realizar a mesma ação, seja por MsExecAuto() ou de forma manual
      //If Type("lPS400Auto") == "L" .And. !lPS400Auto .And. oModel:GetOperation() <> 3 .And. oModelEJX:nLine == 0
      If oModel:GetOperation() <> 3 .And. oModelEJX:nLine == 0
         cRet := EJX->EJX_MODO
      EndIf  
   /*FSY - 02/12/2013 - Nopado campo "EL2_SEQDOC" ira chamar direto a função RS400PrxNum() no SX3_RELACAO
   Case cCampo == "EL2_SEQDOC"  
      //RRC - 30/08/2013 - Ao incluir um pagamento, a variável cFase será nula
      If Type("cFase") == "C"
         IF cFase=='1'
            cRet := PS400PrxNum("EL2_SEQDOC")
         Else
            cRet := RS400PrxNum("EL2_SEQDOC")
         EndIf
      EndIf
   */   
   Case cCampo == "EL2_STTSIS"
      //RRC - 30/08/2013 - Ao incluir um pagamento, a variável cFase será nula
      If Type("cFase") == "C"
         IF cFase=='1'
            cRet := "1"
         Else
            cRet := RS400Relacao("EL2_STTSIS")
         EndIf
      EndIf

   Case cCampo == "EL2_PROCES"  
      //RRC - 30/08/2013 - Ao incluir um pagamento, a variável cFase será nula
      If Type("cFase") == "C"
         IF cFase=='1'
            cRet := EJW->EJW_PROCES
         Else
            cRet := RS400Relacao("EL2_PROCES")
         EndIf
      EndIf

   Case cCampo == "EJW_STTFAT" //RRV - 02/04/2013 - Inicializa com "Em aberto"
      cRet := "1"

   Case cCampo == "EJW_DSCEMP"
      If cPed == "A"
         cRet := Posicione("SA1",1,xFilial("SA1")+M->EJW_CODEMP+M->EJW_LOJEMP,"A1_NOME")
      ElseIf cPed == "V"
         cRet := Posicione("SA2",1,xFilial("SA2")+M->EJW_CODEMP+M->EJW_LOJEMP,"A2_NOME")
      End If

   Case cCampo == "EJW_SLDINV"
      If cPed == "A"
         cRet := PS400SalInv("A",M->EJW_PROCES)
      ElseIf cPed == "V"
         cRet := PS400SalInv("V",M->EJW_PROCES)
      End If

EndCase
RestOrd(aOrd,.T.)
Return cRet

/*
Programa   : CodToMoney
Objetivo   : Converter o codigo da moeda em simbolo
Retorno    : aCab
Autor      : Fabio Satoru Yamamoto - FSY
Data/Hora  : 24/09/2012 11:00 
Revisao    : 
*/
Static Function CodToMoney(aCab)
Local y

If (y := aScan(aCab, {|x| x[1]== "EJW_MOEDA"})) > 0 .AND. ValType(aCab[y][2]) == "N"
   aCab[y][2] := Left(EasyGParam("MV_SIMB"+Alltrim(Str(aCab[y][2]))),AvSX3("EJW_MOEDA",AV_TAMANHO))
End If

Return aClone(aCab) 



Static Function ValidaItensEAuto(aItens,aAnexos,nOpcAuto,aCab)
Local i, j, nPos, nPos2
Local lAnexos := .T.
Default nOpcAuto := 0
Default aCab     := {}

SB5->(dbSetOrder(1))

i := 1
Do While i <= Len(aItens)                                             

   
   //Adiciona a Filial                                       
   nPos := aScan(aItens[i],{|x|x[1]=="EJX_FILIAL"})
   If nPos == 0
      aAdd(aItens[i],{"EJX_FILIAL",xFilial("EJX"),NIL})
   EndIf   
   //Adiciona Tipo de processo
   nPos := aScan(aItens[i],{|x|x[1]=="EJX_TPPROC"})
   If nPos == 0
      aAdd(aItens[i],{"EJX_TPPROC",cPed,NIL})
   EndIf
   
   //AAF - 07/10/2014 - Tratamento para código de pais no formato do bacen (os 3 primeiros digitos da esquerda, com exceção do 0, são o código siscomex).
   nPos := aScan(aItens[i],{|x|x[1]=="EJX_PAIS"})
   If nPos > 0
      If Left(aItens[i][nPos][2],1) == "0" .And. Len(AllTrim(aItens[i][nPos][2])) > 3 //RMD - 10/12/14 - Somente se o código tiver mais de 3 dígitos.
         aItens[i][nPos][2] := SubStr(aItens[i][nPos][2],2,Len(aItens[i][nPos][2])) 
      EndIf
      If Len(aItens[i][nPos][2]) == 4
         aItens[i][nPos][2] := Left(aItens[i][nPos][2],3)      
      EndIf
   EndIf

   //AAF - 07/10/2014 - Se a data de previsao de fim estiver em branco, não integra-la para não remover o inicializador padrão, ja que o campo é obrigatório.
   nPos := aScan(aItens[i],{|x|x[1]=="EJX_DTPRFI"})
   If nPos > 0 .AND. Empty(aItens[i][nPos][2])
      aDel(aItens[i],nPos)
      aSize(aItens[i],Len(aItens[i])-1)
   EndIf
   
   IF LEN(ACAB)<> 0  .AND. (nPos:=aScan(ACAB,{|x| x[1] =="EJW_ORIGEM"})) <> 0 .AND. UPPER(ALLTRIM(aCab[nPos][2])) $ 'SIGAFAT/SIGACOM'
   
      //RRC - 04/11/2013 - Valida se o serviço possui NBS associada apenas para casos de inclusão     
      If nOpcAuto == INCLUIR .And. (nPos := aScan(aItens[i],{|X| X[1] == "EJX_NBS"}) == 0 .OR. Empty(aItens[i][nPos]) .AND. ValType(aCab[nPos][2]) == "C")
         If (nPos2 := aScan(aItens[i],{|X| X[1] == "EJX_ITEM"})) == 0 .OR. !SB5->(dbSeek(xFilial()+aItens[i][nPos2][2])) .OR. Empty(SB5->B5_NBS)
            aDel(aItens,i)
            aSize(aItens,Len(aItens)-1)
            i--
         EndIf
      EndIf   
   EndIf
   
   i++
EndDo 

/*
For i := 1 To Len(aItens)
   //Adiciona a Filial
   nPos := aScan(aItens[i],{|x|x[1]=="EJX_FILIAL"})
   If nPos == 0
      aAdd(aItens[i],{"EJX_FILIAL",xFilial("EJX"),NIL})
   EndIf   
   //Adiciona Tipo de processo
   nPos := aScan(aItens[i],{|x|x[1]=="EJX_TPPROC"})
   If nPos == 0
      aAdd(aItens[i],{"EJX_TPPROC",cPed,NIL})
   EndIf
Next i*/

If ValType(aAnexos) == "A" .And. Len(aAnexos) > 0
   For i := 1 To Len(aAnexos)
      //Adiciona a Filial
      nPos := aScan(aAnexos[i],{|x|x[1]=="EL2_FILIAL"})
      If nPos == 0
         aAdd(aAnexos[i],{"EL2_FILIAL",xFilial("EL2"),NIL})
      EndIf   
      //Adiciona Tipo de processo
      nPos := aScan(aAnexos[i],{|x|x[1]=="EL2_TPPROC"})
      If nPos == 0
         aAdd(aAnexos[i],{"EL2_TPPROC",cPed,NIL})
      EndIf
   Next i 
   lAnexos := Len(aAnexos)>0  
EndIf

Return Len(aItens)>0 .And. lAnexos

Static Function ValidaIntegracao(nOpcAuto,aCab,aDet,aAnex,lCallInv)
Local lRet := .T.
Local i
Local lOrigem   := .F.
Local lFilial   := .F.
Local lTpProc   := .F.
Local cExterior := ""
Default lCallInv := .F.
Begin Sequence

i := 1
Do While i <= Len(aCab)
   
   //Campo obrigatório apenas para inclusão via ExecAuto, caso contrário será preenchido automaticamente através da função PS400Relacao()
   If aCab[i][1] == "EJW_ORIGEM"
      lOrigem := !Empty(aCab[i][2])
      
   ElseIf aCab[i][1] == "EJW_FILIAL"
      lFilial := .T.
      
   ElseIf aCab[i][1] == "EJW_TPPROC"
      lTpProc := .T.
      
   ElseIf aCab[i][1] == "EJW_MOEDA"
      //RRC - 04/09/2013 - Tratamento para permitir a inclusão da moeda de acordo com o código do SIGAFIN para integração de arquivo texto (ESSIN100)
      If (ValType(aCab[i][2]) == "N" .Or. (ValType(aCab[i][2]) == "C" .And. IsInCallStack("ESSIN100")))
         If ValType(aCab[i][2]) == "C"
            IF Val(aCab[i][2]) > 0 .OR. Upper(AllTrim(aCab[i][2])) == Replicate("0",Len(Upper(AllTrim(aCab[i][2]))))
              aCab[i][2] := Val(aCab[i][2])
            EndIf
         EndIf
         
         If !Empty(EasyConvCod(If(ValType(aCab[i][2]) == "C",aCab[i][2],Alltrim(Str(aCab[i][2]))),"SYF"))  // GFP - 10/11/2014
		    aCab[i][2] := EasyConvCod(Alltrim(Str(aCab[i][2])),"SYF")
         ElseIf !Empty(EasyGParam("MV_SIMB"+If(ValType(aCab[i][2]) == "C",aCab[i][2],Alltrim(Str(aCab[i][2]))),,""))  // GFP - 10/11/2014
            aCab[i][2] := Left(EasyGParam("MV_SIMB"+If(ValType(aCab[i][2]) == "C",aCab[i][2],Alltrim(Str(aCab[i][2]))),,""),AvSX3("EJW_MOEDA",AV_TAMANHO))  // GFP - 10/11/2014
         EndIf
      EndIf
      
   ElseIf aCab[i][1] == "EJW_EXPORT"
      If cPed == "V"
         EasyHelp("Integração não permitida. O exportador não deve ser informado para processo de venda de serviço.","Aviso")
         lRet := .F.
         Break
      Else
         cExterior := aCab[i][2]+cExterior
      EndIf
      
   ElseIf aCab[i][1] == "EJW_LOJEXP"
      cExterior += aCab[i][2]

   ElseIf aCab[i][1] == "EJW_IMPORT"
      If cPed == "A"
         EasyHelp("Integração não permitida. O importador não deve ser informado para processo de aquisição de serviço.","Aviso")
         lRet := .F.
         Break
      Else
         cExterior := aCab[i][2]+cExterior
      EndIf
      
   ElseIf aCab[i][1] == "EJW_LOJIMP"
      cExterior += aCab[i][2]

   ElseIf aCab[i][1] == "EJW_VL_MOE" .OR. aCab[i][1] == "EJW_VL_REA"
      //Retira do Array caso os campos a seguir sejam previamentes informados, estes campos não são editáveis e serão preenchidos automaticamente
      aDel(aCab,i) //RRC - 30/08/2013 - Troca de variável nPos por i
      aSize(aCab,Len(aCab)-1)
      
   EndIf
   
   i++
EndDo
                                                        
If !lOrigem .And. !lCallInv
   EasyHelp("A origem da integração deve ser informada.","Aviso")
   lRet := .F.
   Break
EndIf
   
If !lFilial
   aAdd(aCab,{"EJW_FILIAL",xFilial("EJW"),NIL})
EndIf

If !lTpProc
   aAdd(aCab,{"EJW_TPPROC",cPed,NIL})
   ValidaDet(@aDet, cPed)
EndIf

//RRC - 21/08/2013 - Criado MV_ESS0015 para permitir ou não a inclusão do processo com cliente ou fornecedor nacional, fazendo neste caso, a validação apenas no RAS ou RVS
//Neste caso, nem chamará o ExecAuto, exceto quando for integração CSV
If nOpcAuto <> 5 .And. !IsForeign(if(cPed=="A","SA2","SA1"), cExterior)
   If Type("lGeraProc") == "L" .And. !EasyGParam("MV_ESS0015",,.T.) .And. !IsInCallStack("ESSIN100")
      lGeraProc := .F.
      Break
   EndIf
EndIf

If Len(aDet) == 0
   //nOpcAuto := 5
EndIf

//RRC - 16/05/2013 - Criado parâmetro para caso o usuário tente incluir um processo já existente por execauto, o sistema bloqueie, e não entenda que é alteração.
If (nOpcAuto == 3 .And. !EasyGParam("MV_ESS0006",,.F.)) .OR. nOpcAuto == 4 //UPSERT
   nOpcAuto := If(EasySeekAuto("EJW",aCab,1),4,3)
EndIf

If nOpcAuto <> 5 .And. !lCallInv .And. !ValidaItensEAuto(aDet,aAnex,nOpcAuto,aCab)//igor chiba 16/06/2014 inclui o acab para utilizar na validacao
   //Não chamar o help para não retornar erro de integração.
   //EasyHelp("Não há itens com N.B.S. para integração.","Aviso")
EndIf
                                                  
If nOpcAuto == 5 .And. !EasySeekAuto("EJW",aCab,1)
   //RRC - 23/08/2013 - Para não exibir nenhuma mensagem de erro (casos como integração com SIGAFAT e SIGACOM), nem chamará o ExecAuto, exceto quando for integração CSV
   If Type("lGeraProc") == "L" .And. !IsInCallStack("ESSIN100")
      lGeraProc := .F.
      Break
   Else
      EasyHelp("Não foi encontrado processo de serviço para exclusão.","Aviso")
      lRet := .F.
   EndIf
EndIf

End Sequence

Return lRet

/*
Programa   : PS400AtuPed()
Objetivo   : Validar a exclusão do Processo conforme seu status
Retorno    : Lógico
Autor      : Rafael Ramos Capuano
Data/Hora  : 02/10/2012 09:06
Revisao    : 
*/

Function PS400AtuPed()
Local lRet := .T.
Local aOrd := SaveOrd({"ELA","EL4","EJZ","EL8"})
Local cTextAct:= "excluído"

Begin Sequence

If AvFlags("ESS_EAI") .And. lCancel
   cTextAct:= "cancelado"
EndIf

//RRC - 28/06/2013 - Criado parâmetro que verifica se o Processo originado no SIGACOM ou SIGAFAT poderá ser excluído pelo SIGAESS, caso o conteúdo seja .T.
If Type("lPS400Auto") == "L" .And. !lPS400Auto .And. ( (!EasyGParam("MV_ESS0008",,.F.) .And. (Alltrim(EJW->EJW_ORIGEM) == "SIGACOM" .Or. AllTrim(EJW->EJW_ORIGEM) == "SIGAFAT")) .OR. AllTrim(EJW->EJW_ORIGEM) == "LOGIX")  
   EasyHelp("Este processo foi integrado e só poderá ser " + cTextAct + " pelo ERP " + AllTrim(EJW->EJW_ORIGEM) + ".","Aviso")
   lRet := .F.
   Break      
EndIf

If EJW->EJW_STTPED <> "1" .AND. (!lIntPedServ .OR. EJW->EJW_STTPED == "4")
   EasyHelp("O Processo não poderá ser " + cTextAct + " pois apresenta status '" + BSCXBOX('EJW_STTPED',EJW->EJW_STTPED)+"'","Aviso")
   lRet := .F.
   Break      
EndIf

//RRC - 14/10/2013 - Não poderá excluir o Processo caso haja um lote gerado com o RAS/RVS de algum de seus serviços
EJZ->(DbSetOrder(3)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES+EJZ_SEQPRC
EL4->(DbSetOrder(1)) //EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG+EL4_SQEVIT
EL8->(DbSetOrder(2)) //EL8_FILIAL+EL8_IDLOTE
If EJZ->(DbSeek(xFilial("EJZ")+EJW->EJW_TPPROC+EJW->EJW_PROCES)) 
   Do While EJZ->(!Eof()) .And. EJZ->(EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES) == xFilial("EJZ")+EJW->(EJW_TPPROC+EJW_PROCES) 
      If EL4->(DbSeek(xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG))
         //RRC - 28/11/2013 - Alteração para somente validar caso o lote não tenha sido cancelado
         Do While EL4->(!Eof()) .And. EL4->(EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG) == xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG
            If EL8->(DbSeek(xFilial("EL8")+EL4->EL4_IDLOTE)) .And. EL8->EL8_STATUS <> "C" .AND. !(EL8->EL8_STATUS == "P" .AND. Empty(EL4->EL4_NROREG)) //AAF 11/01/2017 - Permite estorno dos casos em que foi processado, mas não foi registrado no Siscoserv.
               EasyHelp("O processo não pode ser " + cTextAct + " pois possui serviço vinculado a um lote não cancelado.","Aviso")
               lRet := .F.
               Break
            EndIf
            EL4->(DbSkip())   
         EndDo
      EndIf
      EJZ->(DbSkip())
   EndDo
EndIf   

If Type("cPed") == "C"
   ELA->(DbSetOrder(4)) //ELA_FILIAL + ELA_TPPROC + ELA_PROCES + ELA_NRINVO
   If ELA->(DbSeek(xFilial("ELA")+AvKey(cPed,"ELA_TPPROC")+AvKey(M->EJW_PROCES,"ELA_PROCES")))
      EasyHelp("O processo não pode ser " + cTextAct + " pois possui invoice associada.")
      lRet := .F.
      Break
   EndIf
EndIf                   


End Sequence
RestOrd(aOrd,.T.)
Return lRet

Static Function IsForeign(cTabela, cChave)
Local cAbrev := Right(cTabela,2)
Local lRet   := .F.
Local aOldOrd

aOldOrd := (cTabela)->({IndexOrd(),RecNo()})

(cTabela)->(dbSetOrder(1))
//RRC - 19/04/2013 - Alteração para considerar apenas o campo do País, para ver se é estrangeiro
lRet    := (cTabela)->(!dbSeek(xFilial()+cChave) .Or. (/*&(cAbrev+"_EST") == "EX" .OR. */!Empty(&(cAbrev+"_PAIS")) .AND. !&(cAbrev+"_PAIS") == "105"))

(cTabela)->(dbSetOrder(aOldOrd[1]),dbGoTo(aOldOrd[2]))

Return lRet

/*
Programa   : PS400ViewAtu()
Objetivo   : Alterar os campos combo do processo quando a operação for
             Copiar Processo/Incluir
Retorno    : .T.
Autor      : Felipe Sales Martinez
Data       : 23/11/2012
*/

Static Function PS400ViewAtu(oView)
Local oModel := FWModelActive()
Local nLinha := 0
Local oMdlCap, oMdlDet, oMdlEL2

If oModel:GetOperation() == 3
	oMdlCap := oModel:GetModel("EJWMASTER")
	oMdlCap:SetValue("EJW_STTPED", "1")
	
	IF oMdlCap:GetValue("EJW_VL_MOE") <> 0
     oMdlCap:SetValue("EJW_SLDINV",EJW->EJW_VL_MOE) //LRS 05/09/2014 - Validação para pegar o saldo do processo copiado e levar para o processo novo.
  ENDIF 

  If !lPS400Auto .And. cModulo == "ESS" //NCF 21/03/2018 - Setar origem correta quando copiado de processos originados de outros módulos
     oMdlCap:SetValue("EJW_ORIGEM", "ESSPS400")   
  EndIf 
    
	oMdlDet := oModel:GetModel("EJXDETAIL")
	 
	For nLinha:=1 To oMdlDet:Length()
		oMdlDet:GoLine(nLinha)
		oMdlDet:SetValue("EJX_STTPED", "1")	    
      IF oMdlDet:GetValue("EJX_VL_MOE") <> 0
         oMdlDet:SetValue("EJX_SLDINV",oMdlDet:GetValue("EJX_VL_MOE"))
      EndIF
	Next
	oMdlDet:GoLine(1)
	
	If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EasyGParam("MV_ESS0004",,.F.)
	   oMdlEL2 := oModel:GetModel("EL2DETAIL")
       For nLinha := 1 To oMdlEL2:Length()
          oMdlEL2:GoLine(nLinha)
          If !oMdlEL2:IsDeleted()
             oMdlEL2:DeleteLine()
          EndIf
       Next
	EndIf
	oView:Refresh()
EndIf

Return .T. 

/*
Programa   : VerDatas()
Objetivo   : Verifica as Datas Iniciais, Finais, Prazo e de Registro dos serviços para atualizar os valores
             correspondentes da capa quando deletar ou recuperar uma linha do grid
             Data inicial : será a menor data inicial dentre os serviços
             Data final : será o maior Data final dentre os serviços
             Prazo : será o menor prazo dentre os serviços que possuem data de registro em branco
             Data de registro : será a maior data de registro dentre os serviços, para isso, todos os serviços devem
             estar com a data de registro preenchida
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 27/09/2012 09:34 
Revisao    : 08/03/2013 - NCF - Adaptada para o Processo de Serviços 
*/
/*NOPADO por RRC - 22/03/2013
Static Function VerDatas()
Local nI
Local oModel     
Local oModelEJY  
Local oModelEJZ  
Local oView      
Local aRows       
Local dDataIni   := CTOD("")
Local dDataFim   := CTOD("")
Local dPrazo     := CTOD("")
Local dReg       := CTOD("") 
Local lDtRegVaz  := .F.
//Local lDtIniVaz  := .F. 
//Local lDtFimVaz  := .F.
Local aDataInicio := {}
Local aDataFim    := {}

//If Type("lPS400Auto") == "L" .And. !lPS400Auto
   oModel    := FWModelActive()
//ElseIf Type("lPS400Auto") == "L" .And. lPS400Auto      
//   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf

oModelEJW  := oModel:GetModel("EJWMASTER")
oModelEJX  := oModel:GetModel("EJXDETAIL")
oView      := FWViewAction()
aRows      := FWSaveRows() 

For nI := 1 to oModelEJX:Length()
   oModelEJX:GoLine(nI)
   If !oModelEJX:IsDeleted()

      dDataIni := oModelEJX:GetValue("EJX_DTINI")
      dDataFim := oModelEJX:GetValue("EJX_DTFIM") 
      If !Empty(dDataIni) 
         aAdd(aDataInicio,dDataIni)
      EndIf
      
      If !Empty(dDataFim) 
         aAdd(aDataFim,dDataFim)
      EndIf

      If Empty(oModelEJX:GetValue("EJX_DTREG")) .And. !Empty(oModelEJX:GetValue("EJX_DTINI")) .And. !Empty(oModelEJX:GetValue("EJX_PRAZO")) .And. (Empty(dPrazo) .Or. dPrazo > oModelEJX:GetValue("EJX_PRAZO"))
         dPrazo := oModelEJX:GetValue("EJX_PRAZO")     
      EndIf   
      If Empty(oModelEJX:GetValue("EJX_DTREG")) //Verifica se existe algum serviço com data de registro em branco
         lDtRegVaz := .T.
         dReg      := CTOD("") 
      ElseIf  !lDtRegVaz .And. (Empty(dReg) .Or. dReg < oModelEJX:GetValue("EJX_DTREG"))
         dReg := oModelEJX:GetValue("EJX_DTREG")
      EndIf
   EndIf   
Next
*/
/*
Programa   : GravDoc()
Objetivo   : Efetuar a gravação dos Documentos relacionados ao Processo de Serviço apenas caso a DI ou RE tenha sido
             preenchido
Parametros : cPed - "A" - "Aquisição" ou "V" - "Venda"
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 18/09/2012 09:31 
Revisao    : 08/03/2013 - NCF - Adaptada para o Processo de Serviços
*/
Static Function GravDoc(cPed)
Local oModel    
Local oModelEL2 
Local nLinha    := 1
Local cCampo    := ""
Default cPed  := ""

oModel    := FWModelActive()

If Valtype(oModel) == "O"
   oModelEL2 := oModel:GetModel("EL2DETAIL")

   If cPed == "A"   
      cCampo := "EL2_DI"
   ElseIf cPed == "V"
      cCampo := "EL2_RE"   
   EndIf

   For nLinha := 1 To oModelEL2:Length()
      oModelEL2:GoLine(nLinha)
      //Ao encontrar um RE ou uma DI em branco, o Documento e o status for 1 - "Aguardando Registro no Siscoserv", deletará a linha
      //Se o status for diferente disso, grava com o campo em branco, para que não perca o vínculo com a EL7
      If (EasyGParam("MV_ESS0027",,9) < 10 .AND. !oModelEL2:IsDeleted() .And. oModelEL2:GetValue("EL2_STTSIS") == "1" .And. Empty(oModelEL2:GetValue(cCampo))) .OR.;
         (EasyGParam("MV_ESS0027",,9) >= 10 .AND. !oModelEL2:IsDeleted() .And. oModelEL2:GetValue("EL2_STTSIS") == "1" .And. Empty(oModelEL2:GetValue("EL2_DI")) .And. Empty(oModelEL2:GetValue("EL2_RE")))
         oModelEL2:DeleteLine()
      EndIf
   Next
   
EndIf

Return .T.  

/****************************************************************************************** 
ROTINA     : PS400GeraReg()  
Parametros : nOperation - Tipo da Operação(3-Inclusão;4-Alteração;5-Exclusão) 
Retorno    : Nenhum 
Objetivos  : Rotina de geração Automática do Registro de Serviços 
Autor      : Nilson César C. Filho
Data/Hora  : 12/03/2013 
*******************************************************************************************/ 
Static Function PS400GeraReg(nOperacao,lProcPend,lCallInv,lDelItem)

Local aOrdEJ      := SaveOrd({"EJW","EJX","EJY","EJZ","EL2"})
Local aExecAuto   := {}
Local aCab        := {}
Local aItens      := {}
Local aDocs       := {}
Local aLineDoc    := {}
Local aLineSrv    := {} 
Local nLineExec   := 1 
Local oErros      := AvObject():New()
Local lExibeMsg   := .F.
Local cOldFilter  := ""
Local lDelItem2  := .F.
Local nContReg   := 0
Default nOperacao := 4
Default lProcPend := .F. //RRC - 09/05/2013 - Verifica se a chamada veio do botão que gera RAS/RVS para processos pendentes 
Default lCallInv  := .F.
Default lDelItem  := .F. //MFR 20/07/2017
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.

//INICIO DO CONTROLE DE TRANSACAO
//NOPADO por RRC - 22/07/2013
//Begin TRANSACTION

/*Observação: RRC - 05/11/2013 - O botão "Atualiza RAS", estará disponível quando o parâmetro MV_ESS0003 estiver habilitado, neste caso, o sistema deve gerar um RAS
para um único Processo*/

Do Case

   Case nOperacao == 3

      aCab := {}
      aadd(aCab,{"EJY_REGIST"   ,EJW->EJW_PROCES,NIL})
      aadd(aCab,{"EJY_PROCES" ,EJW->EJW_PROCES,NIL})
      aadd(aCab,{If(EJW->EJW_TPPROC == 'A',"EJY_EXPORT","EJY_IMPORT"),If(EJW->EJW_TPPROC == 'A',EJW->EJW_EXPORT,EJW->EJW_IMPORT),NIL}) 
      aadd(aCab,{If(EJW->EJW_TPPROC == 'A',"EJY_LOJEXP","EJY_LOJIMP"),If(EJW->EJW_TPPROC == 'A',EJW->EJW_LOJEXP,EJW->EJW_LOJIMP),NIL})
      //aadd(aCab,{"EJY_PAIS"   ,EJW->EJW_PAIS  ,NIL})
      aadd(aCab,{"EJY_DTPROC" ,EJW->EJW_DTPROC,NIL})
      aadd(aCab,{"EJY_MOEDA"  ,EJW->EJW_MOEDA ,NIL})
      If EasyGParam("MV_ESS0021",,.F.) .And. EJW->(FieldPos("EJW_CODEMP"))>0 .And. EJW->(FieldPos("EJW_LOJEMP"))>0 .And. EJW->(FieldPos("EJW_CGC"))>0 
	     aadd(aCab,{"EJY_CODEMP" ,EJW->EJW_CODEMP ,NIL})//FSY
         aadd(aCab,{"EJY_LOJEMP" ,EJW->EJW_LOJEMP ,NIL})//FSY
         aadd(aCab,{"EJY_CGC"    ,EJW->EJW_CGC ,NIL})//FSY
	  End If 
	  //O campo EJY_COMPl do RAS ou RVS é usado para informar o motivo da retificação, já o EJW_COMPL para armazenar informações adicionais, portanto, são conteúdos diferentes
      //aAdd(aCab,{"EJY_COMPL"  ,EJW->EJW_COMPL, NIL})
      If EasyGParam("MV_ESS0027",,9) >= 10 /*.AND. PS400TipoVinc() <> "0"*/ //MCF - 12/08/2016
         aadd(aCab,{"EJY_TIPVIN" , PS400TipoVinc() , .T.})
      EndIf      
                  
      EJX->(DbSeek(xFilial("EJX")+EJW->EJW_TPPROC+EJW->EJW_PROCES)) 
      Do While EJX->(!Eof()) .And. EJX->EJX_FILIAL == EJW->EJW_FILIAL .And. EJX->EJX_TPPROC == EJW->EJW_TPPROC .And. EJX->EJX_PROCES == EJW->EJW_PROCES
        //RRC - 10/10/2013 - Não poderão ser registrados no SISCOSERV serviços que ainda não foram iniciados
        If EJX->EJX_DTINI > dDataBase    
           lExibeMsg := .T.
        Else
           aLineSrv:={}
           aadd(aLineSrv,{"EJZ_REGIST"  ,EJX->EJX_PROCES,Nil}) //RRC - 06/11/2013 - Necessário passar campo chave para tratamento no EasyEAutItens() na chamado do MsExecauto()         
           aadd(aLineSrv,{"EJZ_PROCES"  ,EJX->EJX_PROCES,Nil})
           aadd(aLineSrv,{"EJZ_SEQPRC"  ,EJX->EJX_SEQPRC,Nil})
           aadd(aLineSrv,{"EJZ_ITEM"	 ,EJX->EJX_ITEM  ,Nil})
           aadd(aLineSrv,{"EJZ_NBS"     ,EJX->EJX_NBS   ,Nil})
           aadd(aLineSrv,{"EJZ_PAIS"	 ,EJX->EJX_PAIS  ,Nil})
           aadd(aLineSrv,{If(EJW->EJW_TPPROC == 'A',"EJZ_MODAQU","EJZ_MODVEN"),EJX->EJX_MODO  ,Nil})
           aadd(aLineSrv,{"EJZ_DTPRIN"  ,EJX->EJX_DTPRIN,Nil})
           aadd(aLineSrv,{"EJZ_DTINI"   ,EJX->EJX_DTINI ,Nil})        
           aadd(aLineSrv,{"EJZ_DTPRFI"  ,EJX->EJX_DTPRFI,Nil})
           aadd(aLineSrv,{"EJZ_DTFIM"   ,EJX->EJX_DTFIM ,Nil})
           //aadd(aLineSrv,{"EJZ_CONDPG"  ,EJX->EJX_CONDPG,Nil})
           aadd(aLineSrv,{"EJZ_QTDE"	 ,EJX->EJX_QTDE  ,Nil})
           aadd(aLineSrv,{"EJZ_PRCUN"   ,EJX->EJX_PRCUN ,Nil})
           aadd(aLineSrv,{"EJZ_TX_MOE"  ,EJX->EJX_TX_MOE,Nil}) 
           //aadd(aLineSrv,{"EJZ_COMPL"   ,EJX->EJX_COMPL ,Nil}) 
           
           IF EJZ->(FieldPos("EJZ_UM"))>0    //LRS - 19/09/2014
              aadd(aLineSrv,{"EJZ_UM"      ,EJX->EJX_UM,Nil}) //SSS - REQ 8 - 13/06/2014
           EndIF   
           
           aAdd(aItens,aLineSrv)
        EndIf
        EJX->(DbSkip())   
      EndDo
      
      If EasyGParam("MV_ESS0027",,9) >= 10
         cOldFilter := EL2->(DbFilter())
         EL2->(DbClearFilter())
      EndIf
      
      EL2->(DbSetOrder(2))//"EL2_FILIAL+EL2_TPPROC+EL2_PROCES+EL2_SEQDOC"
      If EL2->(DbSeek(xFilial("EL2")+EJW->EJW_TPPROC+EJW->EJW_PROCES))
         Do While EL2->(!Eof()) .And. EL2->EL2_FILIAL == EJW->EJW_FILIAL .And. ;
                                      EL2->EL2_TPPROC == EJW->EJW_TPPROC .And. ;
                                      EL2->EL2_PROCES == EJW->EJW_PROCES          
            aLineDoc := {}
            aadd(aLineDoc,{"EL2_PROCES", ""   ,Nil})//RRC - 26/08/2013 - Grava EL2_PROCES em branco para não duplicar a DI ou RE no RAS/RVS
            aadd(aLineDoc,{"EL2_REGIST", EJW->EJW_PROCES   ,Nil})
            aadd(aLineDoc,{"EL2_SEQDOC", EL2->EL2_SEQDOC   ,Nil})               
            aadd(aLineDoc,{"EL2_SEQPAG", EL2->EL2_SEQPAG   ,Nil})
            If !EasyGParam("MV_ESS0027",,9) >= 10
               aadd(aLineDoc,{If(EJW->EJW_TPPROC == 'A',"EL2_DI","EL2_RE") , If(EJW->EJW_TPPROC == 'A',EL2->EL2_DI,EL2->EL2_RE) ,Nil})
            Else
               aadd(aLineDoc,{"EL2_DI" , EL2->EL2_DI ,Nil})
               aadd(aLineDoc,{"EL2_RE" , EL2->EL2_RE ,Nil})
               aadd(aLineDoc,{"EL2_SEQPRC", EL2->EL2_SEQPRC,Nil})
            Endif
            aadd(aLineDoc,{"EL2_STTSIS", "1"               ,Nil})
            aAdd(aDocs,aLineDoc)
         
            EL2->(DbSkip())                                      
         EndDo
      EndIf
      
      If !Empty(cOldFilter)
         EL2->(dbSetFilter(&("{||"+cOldFilter+"}"),cOldFilter))
      EndIf
   
      aAdd(aExecAuto,{aCab,aItens,aDocs,3}) 
   
   Case nOperacao == 4

      If EasyGParam("MV_ESS0027",,9) >= 10
         cOldFilter := EL2->(DbFilter())
         EL2->(DbClearFilter())
      EndIf

      EL2->(DbSetOrder(2))
      EL2->(DbSeek(xFilial("EL2")+EJW->EJW_TPPROC+EJW->EJW_PROCES))
      Do While EL2->(!Eof()) .And. EL2->EL2_FILIAL == EJW->EJW_FILIAL .And. ;
                                   EL2->EL2_TPPROC == EJW->EJW_TPPROC .And. ;
                                   EL2->EL2_PROCES == EJW->EJW_PROCES
         If Empty(EL2->EL2_REGIST)                                                                                         
            aLineDoc := {}
            aadd(aLineDoc,{"EL2_PROCES", ""   ,Nil}) //RRC - 26/08/2013 - Grava EL2_PROCES em branco para não duplicar a DI ou RE no RAS/RVS
            aadd(aLineDoc,{"EL2_REGIST", EJW->EJW_PROCES   ,Nil})
            aadd(aLineDoc,{"EL2_SEQDOC", EL2->EL2_SEQDOC   ,Nil})
            aadd(aLineDoc,{"EL2_SEQPAG", EL2->EL2_SEQPAG   ,Nil})
            aadd(aLineDoc,{If(EJW->EJW_TPPROC == 'A',"EL2_DI","EL2_RE") , If(EJW->EJW_TPPROC == 'A',EL2->EL2_DI,EL2->EL2_RE) ,Nil})
            
            If !EasyGParam("MV_ESS0027",,9) >= 10
               aadd(aLineDoc,{If(EJW->EJW_TPPROC == 'A',"EL2_DI","EL2_RE") , If(EJW->EJW_TPPROC == 'A',EL2->EL2_DI,EL2->EL2_RE) ,Nil})
            Else
               aadd(aLineDoc,{"EL2_DI" , EL2->EL2_DI ,Nil})
               aadd(aLineDoc,{"EL2_RE" , EL2->EL2_RE ,Nil})
               aadd(aLineDoc,{"EL2_SEQPRC", EL2->EL2_SEQPRC,Nil})
            Endif
            aadd(aLineDoc,{"EL2_STTSIS", "1"               ,Nil}) 
            aAdd(aDocs,aLineDoc)
         EndIf
        
         EL2->(DbSkip())                                      
      EndDo
      
      If !Empty(cOldFilter)
         EL2->(dbSetFilter(&("{||"+cOldFilter+"}"),cOldFilter))
      EndIf
      
      //EJZ->(DbSetOrder(3))
      //EJX->(DbSetOrder(1))
      EJX->( EJX->(DbSetOrder(1)) , DbSeek(xFilial("EJX")+EJW->EJW_TPPROC+EJW->EJW_PROCES)) 
      //EJY->(DbSetOrder(1))
      Do While EJX->(!Eof()) .And. EJX->EJX_FILIAL == EJW->EJW_FILIAL .And. EJX->EJX_TPPROC == EJW->EJW_TPPROC .And. EJX->EJX_PROCES == EJW->EJW_PROCES
      
         //Verifica se o Serviço do Processo está relacionado à algum Registro
         If EJZ->( EJZ->( DbSetOrder(3)) , DbSeek(xFilial("EJZ")+EJX->EJX_TPPROC+EJX->EJX_PROCES+EJX->EJX_SEQPRC) )
            //Posiciona na capa do Registro onde o serviço está sendo utilizado
            /*RRC - 06/11/2013 - Quando o MV_ESS0003 estiver habilitado, o sistema deve gerar um RAS para um único Processo, atribuindo dessa forma o mesmo conteúdo
            do EJW_PROCES para EJY_REGIST, que são os campos chave. 
            Neste caso, verifica se o Processo já possui um RAS/RVS único, e deve assegurar que serão atualizados somente serviços que não estejam em outro RAS/RVS
            EJW (Capa do Processo)
            EJX (Itens do Processo)
            EJY (Capa do RAS/RVS)
            EJZ (Itens do RAS/RVS)
            RAS/RVS gerado deve ser igual ao número do Processo*/     
            If EJZ->EJZ_REGIST == EJW->EJW_PROCES .And. EJY->( EJY->(DbSetOrder(1)) , DbSeek(xFilial("EJY")+EJW->EJW_TPPROC+EJW->EJW_PROCES))
               //RRC - 10/10/2013 - Não poderão ser registrados no SISCOSERV serviços que ainda não foram iniciados
               If EJX->EJX_DTINI > dDataBase    
                  lExibeMsg := .T.
               Else               
                  aLineSrv:={}
                  aadd(aLineSrv,{"EJZ_REGIST"  ,EJY->EJY_REGIST ,Nil})      //Nro. Do Processo no Registro
                  aadd(aLineSrv,{"EJZ_SEQREG"  ,EJZ->EJZ_SEQREG ,Nil})
                  aadd(aLineSrv,{"EJZ_ITEM"	   ,EJX->EJX_ITEM   ,Nil})
                  aadd(aLineSrv,{"EJZ_NBS"     ,EJX->EJX_NBS    ,Nil})
                  aadd(aLineSrv,{"EJZ_PAIS"	   ,EJX->EJX_PAIS   ,Nil})
                  aadd(aLineSrv,{If(EJW->EJW_TPPROC == 'A',"EJZ_MODAQU","EJZ_MODVEN")    ,EJX->EJX_MODO  ,Nil})
                  aadd(aLineSrv,{"EJZ_DTPRIN"  ,EJX->EJX_DTPRIN ,Nil})
                  aadd(aLineSrv,{"EJZ_DTINI"   ,EJX->EJX_DTINI  ,Nil})        
                  aadd(aLineSrv,{"EJZ_DTPRFI"  ,EJX->EJX_DTPRFI ,Nil})
                  aadd(aLineSrv,{"EJZ_DTFIM"   ,EJX->EJX_DTFIM  ,Nil})
                  aadd(aLineSrv,{"EJZ_QTDE"	   ,EJX->EJX_QTDE   ,Nil})
                  aadd(aLineSrv,{"EJZ_PRCUN"   ,EJX->EJX_PRCUN  ,Nil})
                  aadd(aLineSrv,{"EJZ_TX_MOE"  ,EJX->EJX_TX_MOE ,Nil}) 
                  //MFR 20/07/2017 TE-6287 WCC-523509
                  if lDelItem
                     lDelItem2 := PS400DelItm(EJX->EJX_NBS, EJX->EJX_PAIS, EJX->EJX_MODO, EJX->EJX_DTINI)
                  Else
                     lDelItem2 := .F.
                  EndIf

                  If lDelItem2
                    aadd(aLineSrv,{"AUTDELETA"  ,"S" ,Nil})
                  EndIf
                  //aadd(aLineSrv,{"EJZ_COMPL"   ,EJX->EJX_COMPL ,Nil})
               
                  //RRC - 05/11/2013 - Efetua busca no array para verificar se já montou a capa do RAS/RVS referente a este processo          
                  If Len(aExecAuto) > 0 .And. (nPosCapa := aScan(aExecAuto,{|X|  aScan(X[1],{|Campo| Campo[1] == "EJY_REGIST" .And. Campo[2] == EJW->EJW_PROCES }) })) > 0         
                     aAdd(aExecAuto[nPosCapa][2],aLineSrv)             
                     //MFR 20/07/2017 TE-6287 WCC-523509
                     if len(aExecAuto[nPosCapa]) = 5 .and. lDelItem2
                        aExecAuto[nPosCapa][5] := aExecAuto[nPosCapa][5] -1
                        if aExecAuto[nPosCapa][5] = 0
                           aExecAuto[nPosCapa][4] := 5
                        EndIf
                     Endif
                  Else
                     aadd(aCab,{"EJY_REGIST"   ,EJY->EJY_REGIST  ,NIL})
                     aadd(aCab,{"EJY_PROCES"   ,EJW->EJW_PROCES  ,NIL,.T.}) //RRC - Quarto parâmetro indica que executará os gatilhos do EJY_PROCES
                     aadd(aCab,{If(EJW->EJW_TPPROC == 'A',"EJY_EXPORT","EJY_IMPORT"),If(EJW->EJW_TPPROC == 'A',EJW->EJW_EXPORT,EJW->EJW_IMPORT),NIL}) 
                     aadd(aCab,{If(EJW->EJW_TPPROC == 'A',"EJY_LOJEXP","EJY_LOJIMP"),If(EJW->EJW_TPPROC == 'A',EJW->EJW_LOJEXP,EJW->EJW_LOJIMP),NIL})
                     aadd(aCab,{"EJY_DTPROC"   ,EJW->EJW_DTPROC,NIL})
                     aadd(aCab,{"EJY_MOEDA"    ,EJW->EJW_MOEDA ,NIL})
                     If EasyGParam("MV_ESS0021",,.F.) .And. EJW->(FieldPos("EJW_CODEMP"))>0 .And. EJW->(FieldPos("EJW_LOJEMP"))>0 .And. EJW->(FieldPos("EJW_CGC"))>0
				                aadd(aCab,{"EJY_CODEMP"  ,EJW->EJW_CODEMP ,NIL})//FSY
                        aadd(aCab,{"EJY_LOJEMP"  ,EJW->EJW_LOJEMP ,NIL})//FSY
                        aadd(aCab,{"EJY_CGC"     ,EJW->EJW_CGC ,NIL})//FSY
				             EndIf
                     If EasyGParam("MV_ESS0027",,9) >= 10 /*.AND. PS400TipoVinc() <> "0"*/ //MCF - 12/08/2016
                       aadd(aCab,{"EJY_TIPVIN" , PS400TipoVinc() ,.T.})
                     EndIf
                     //O campo EJY_COMPl do RAS ou RVS é usado para informar o motivo da retificação, já o EJW_COMPL para armazenar informações adicionais, portanto, são conteúdos diferentes
                     //aAdd(aCab,{"EJY_COMPL"  ,EJW->EJW_COMPL, NIL})
                     aAdd(aItens,aLineSrv)

                     EJZ->(DbSetOrder(1))
                     EJZ->(DbSeek(xFilial("EJZ")+EJX->EJX_TPPROC+EJY->EJY_REGIST))
                     Do While EJZ->(!Eof()) .And. EJZ->(EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST) == xFilial("EJZ")+EJX->EJX_TPPROC+EJY->EJY_REGIST
                       nContReg := nContReg + 1
                       EJZ->(DbSkip())
                     EndDo
                     //MFR 20/07/2017 TE-6287 WCC-523509
                     if lDelItem2
                        nContReg := nContReg -1
                     EndIf
                     aAdd(aExecAuto,{aCab,aItens,aDocs,iif(nContReg=0,5,4),nContReg})
//                      aAdd(aExecAuto,{aCab,aItens,aDocs,iif(nContDelIt = nContRegIt,5,4)})
                  EndIf
               EndIf
            EndIf
        //MFR 20/07/2017 TE-6287 WCC-523509
//       Else
         ElseIf ! ldelItem
            //RRC - 10/10/2013 - Não poderão ser registrados no SISCOSERV serviços que ainda não foram iniciados
            If EJX->EJX_DTINI > dDataBase    
               lExibeMsg := .T.
            Else  
               //Inclui Serviço sem Registro
               aLineSrv:={}
               aadd(aLineSrv,{"EJZ_REGIST"  ,EJX->EJX_PROCES,Nil}) //RRC - 06/11/2013 - Necessário passar campo chave para taratamento do EasyEAutItens() na chamado do MsExecauto()        
               aadd(aLineSrv,{"EJZ_PROCES"  ,EJX->EJX_PROCES,Nil})
               aadd(aLineSrv,{"EJZ_SEQPRC"  ,EJX->EJX_SEQPRC,Nil})
               aadd(aLineSrv,{"EJZ_ITEM"    ,EJX->EJX_ITEM  ,Nil})
               aadd(aLineSrv,{"EJZ_NBS"     ,EJX->EJX_NBS   ,Nil})
               aadd(aLineSrv,{"EJZ_PAIS"    ,EJX->EJX_PAIS  ,Nil})
               aadd(aLineSrv,{If(EJW->EJW_TPPROC == 'A',"EJZ_MODAQU","EJZ_MODVEN")    ,EJX->EJX_MODO  ,Nil})
               aadd(aLineSrv,{"EJZ_DTPRIN"  ,EJX->EJX_DTPRIN,Nil})
               aadd(aLineSrv,{"EJZ_DTINI"   ,EJX->EJX_DTINI ,Nil})        
               aadd(aLineSrv,{"EJZ_DTPRFI"  ,EJX->EJX_DTPRFI,Nil})
               aadd(aLineSrv,{"EJZ_DTFIM"   ,EJX->EJX_DTFIM ,Nil})
               aadd(aLineSrv,{"EJZ_QTDE"	,EJX->EJX_QTDE  ,Nil})
               aadd(aLineSrv,{"EJZ_PRCUN"   ,EJX->EJX_PRCUN ,Nil})
               aadd(aLineSrv,{"EJZ_TX_MOE"  ,EJX->EJX_TX_MOE,Nil}) 
               If EJZ->(FieldPos("EJZ_UM")) # 0   // GFP - 10/08/2015
                  aadd(aLineSrv,{"EJZ_UM"      ,EJX->EJX_UM,Nil})
               EndIf
               // aadd(aLineSrv,{"EJZ_COMPL"   ,EJX->EJX_COMPL ,Nil})                   
               
               //RRC - 05/11/2013 - Efetua busca no array para verificar se já montou a capa do RAS/RVS referente a este processo          
               //If Len(aExecAuto) > 0 .And. (nPosItem := aScan(aExecAuto,{|X|  aScan(X[2],{|Y|   aScan(Y,{|Campo| Campo[2] == EJW->EJW_PROCES  })        })        })) > 0                      
               If Len(aExecAuto) > 0 .And. (nPosCapa := aScan(aExecAuto,{|X|  aScan(X[1],{|Campo| Campo[1] == "EJY_REGIST" .And. Campo[2] == EJW->EJW_PROCES }) })) > 0         
                  //aAdd(aExecAuto[nPosItem][2],aLineSrv)                     
                  aAdd(aExecAuto[nPosCapa][2],aLineSrv)                     
               Else                   
                  aCab := {}
                  aadd(aCab,{"EJY_REGIST"   ,EJW->EJW_PROCES,NIL}) 
                  aadd(aCab,{"EJY_PROCES"   ,EJW->EJW_PROCES  ,NIL,.T.}) //RRC - Quarto parâmetro indica que executará os gatilhos do EJY_PROCES
                  aadd(aCab,{If(EJW->EJW_TPPROC == 'A',"EJY_EXPORT","EJY_IMPORT"),If(EJW->EJW_TPPROC == 'A',EJW->EJW_EXPORT,EJW->EJW_IMPORT),NIL}) 
                  aadd(aCab,{If(EJW->EJW_TPPROC == 'A',"EJY_LOJEXP","EJY_LOJIMP"),If(EJW->EJW_TPPROC == 'A',EJW->EJW_LOJEXP,EJW->EJW_LOJIMP),NIL})
                  aadd(aCab,{"EJY_DTPROC" ,EJW->EJW_DTPROC,NIL})
                  aadd(aCab,{"EJY_MOEDA"  ,EJW->EJW_MOEDA ,NIL})
                  If EasyGParam("MV_ESS0021",,.F.) .And. EJW->(FieldPos("EJW_CODEMP"))>0 .And. EJW->(FieldPos("EJW_LOJEMP"))>0 .And. EJW->(FieldPos("EJW_CGC"))>0
                     aadd(aCab,{"EJY_CODEMP"  ,EJW->EJW_CODEMP ,NIL})//FSY
                     aadd(aCab,{"EJY_LOJEMP"  ,EJW->EJW_LOJEMP ,NIL})//FSY
                     aadd(aCab,{"EJY_CGC"     ,EJW->EJW_CGC ,NIL})//FSY 
				          EndIf
                  aAdd(aItens,aLineSrv)
                  aAdd(aExecAuto,{aCab,aItens,aDocs,3})              
               EndIf
            EndIf              
         EndIf 
                
         EJX->(DbSkip()) 
      
      EndDo
      
      /*Do While (nPosDoc := aScan(aExecAuto,{|X| Len(X[3]) == 0 .And. X[4] == 3 })) > 0
         aExecAuto[nPos][3] := aDocs
      EndDo*/

   Case nOperacao == 5

      aadd(aCab,{"EJY_REGIST"   ,EJW->EJW_PROCES,NIL})
      //MFR 14/07/2017 WCC-523509
      //aAdd(aExecAuto,{aCab,aItens,aDocs,4})
      aAdd(aExecAuto,{aCab,aItens,aDocs,5})

EndCase

/*RRC - 10/10/2013 - Caso apenas alguns serviços do processo possuam RAS/RVS, ou seja, Processo parcialmente em fase de registro, e todos estes serviços sejam apagados
na alteração do processo, deve excluir o RAS/RVS relacionado a eles. Para isso monta um array com os dados do mesmo.*/
If Len(aExecAuto) == 0
   EJY->(DbSetOrder(1))//EJY_FILIAL+EJY_TPPROC+EJY_REGIST
   If EJY->(DbSeek(xFilial("EJY")+EJW->EJW_TPPROC+EJW->EJW_PROCES)) 
      aCab := {}
      aadd(aCab,{"EJY_REGIST"   ,EJY->EJY_REGIST  ,NIL})
      aadd(aCab,{"EJY_PROCES"   ,EJW->EJW_PROCES  ,NIL})
      aadd(aCab,{If(EJW->EJW_TPPROC == 'A',"EJY_EXPORT","EJY_IMPORT"),If(EJW->EJW_TPPROC == 'A',EJW->EJW_EXPORT,EJW->EJW_IMPORT),NIL}) 
      aadd(aCab,{If(EJW->EJW_TPPROC == 'A',"EJY_LOJEXP","EJY_LOJIMP"),If(EJW->EJW_TPPROC == 'A',EJW->EJW_LOJEXP,EJW->EJW_LOJIMP),NIL})
      //aadd(aCab,{"EJY_PAIS"   ,EJW->EJW_PAIS  ,NIL})
      aadd(aCab,{"EJY_DTPROC" ,EJW->EJW_DTPROC,NIL})
      aadd(aCab,{"EJY_MOEDA"  ,EJW->EJW_MOEDA ,NIL})
      //O campo EJY_COMPl do RAS ou RVS é usado para informar o motivo da retificação, já o EJW_COMPL para armazenar informações adicionais, portanto, são conteúdos diferentes
      //aAdd(aCab,{"EJY_COMPL"  ,EJW->EJW_COMPL, NIL})
      //aadd(aCab,{"EJY_PAIS"   ,EJW->EJW_PAIS  ,NIL})       
      aAdd(aExecAuto,{aCab,aItens,aDocs,4})
   EndIf
EndIf

If Len(aExecAuto) == 0 .And. lExibeMsg
   //Verifica se deve exibir mensagem caso não seja chamada de MsExecAuto() e nem ação do botão "Atualiza RAS/RVS"
   cMsgErro := "Este processo possui serviços ainda não iniciados, estes não poderão compor o "+If(EJW->EJW_TPPROC=="A","RAS","RVS")+" neste momento."
   If !lPS400Auto .And. !lProcPend
      //MsgInfo("O "+ If(EJW->EJW_TPPROC=="A","RAS","RVS") +" deste Processo não foi totalmente gerado "+CHR(13)+CHR(10)+;
      //          "devido ao(s) problema(s) abaixo:"+CHR(13)+CHR(10)+cMsgErro  )
                
      EasyHelp("O "+ If(EJW->EJW_TPPROC=="A","RAS","RVS") +" deste Processo não foi totalmente gerado "+CHR(13)+CHR(10)+;
                "devido ao(s) problema(s) abaixo:"+CHR(13)+CHR(10)+cMsgErro  )          //SSS - REQ 8 13/06/2014
   EndIf
   If EJW->(RecLock("EJW",.F.))
      EJW->EJW_MSGLOG := "Este processo possui serviços ainda não iniciados, estes não poderão compor o "+If(EJW->EJW_TPPROC=="A","RAS","RVS")+" neste momento."
      EJW->(MsUnLock())
   EndIf 
EndIf

For nLineExec:=1 To Len(aExecAuto)
     
   If cPed == "A"
      MsExecAuto({|a,b,c,d|ESSRA400(a,b,c,d)},aExecAuto[nLineExec][1],aExecAuto[nLineExec][2],aExecAuto[nLineExec][3],aExecAuto[nLineExec][4],lCallInv)
   ElseIf cPed == "V"
      MsExecAuto({|a,b,c,d|ESSRV400(a,b,c,d)},aExecAuto[nLineExec][1],aExecAuto[nLineExec][2],aExecAuto[nLineExec][3],aExecAuto[nLineExec][4],lCallInv)
   EndIf
   
   oErros:Error(GetAutoGRLog())
   cMsgErro := oErros:GetStrErrors()
   
   IF SUBSTR(cMsgErro,0,40) == "- Erro ao preencher campo 'País        '"
      cMsgErro := "- Erro ao preencher campo 'País' da Capa do registro de serviços, o campo País do cadastro do exportador não foi preenchido."
   ElseIF SUBSTR(cMsgErro,0,40) == "- Erro ao preencher campo 'Pais Prest. '"
      cMsgErro := "- Erro ao preencher campo 'Pais Prest.',o campo Pais Prest. não foi preenchido no Detalhe do registro de serviços "
   EndIF   	
                  
   If lMsErroAuto
      //DisarmTransaction()           
      If ValType(cMsgErro) == "U" .Or. Empty(cMsgErro)
         cMsgErro := "- Ocorreram problemas no momento da gravação do Registro de Serviços."        
      EndIf
      //RRC - 01/11/2013
      cMsgErro := StrTran(cMsgErro,"Erro","Problema")
      //RRC - 21/10/2013 - Grava mensagem caso existam serviços ainda não iniciados 
      If lExibeMsg
         cMsgErro += "- Este processo possui serviços ainda não iniciados, estes não poderão compor o "+If(EJW->EJW_TPPROC=="A","RAS","RVS")+" neste momento."
      EndIf                                        
      If !lPS400Auto .And. !lProcPend
        //MsgInfo("O "+ If(EJW->EJW_TPPROC=="A","RAS","RVS") +" deste Processo não foi totalmente gerado "+CHR(13)+CHR(10)+;
        //        "devido ao(s) problema(s) abaixo:"+CHR(13)+CHR(10)+cMsgErro  )
        EasyHelp("O "+ If(EJW->EJW_TPPROC=="A","RAS","RVS") +" deste Processo não foi gerado "+CHR(13)+CHR(10)+;
                 "devido ao(s) problema(s) abaixo:"+CHR(13)+CHR(10)+cMsgErro  ) //SSS - req 8 13/06/2014
                                                                                                                                    
        
      EndIf
      If EJW->(RecLock("EJW",.F.))
         EJW->EJW_MSGLOG := cMsgErro
         EJW->(MsUnLock())
      EndIf      
      Exit
   Else 
      //Verifica se deve exibir mensagem caso não seja chamada de MsExecAuto() e nem ação do botão "Atualiza RAS/RVS"
      If lExibeMsg
         cMsgErro := "Este processo possui serviços ainda não iniciados, estes não poderão compor o "+If(EJW->EJW_TPPROC=="A","RAS","RVS")+" neste momento."
         If !lPS400Auto .And. !lProcPend   
            //MsgInfo("O "+ If(EJW->EJW_TPPROC=="A","RAS","RVS") +" deste Processo não foi totalmente gerado "+CHR(13)+CHR(10)+;
            //    "devido ao(s) problema(s) abaixo:"+CHR(13)+CHR(10)+cMsgErro  )  
                
             EasyHelp("O "+ If(EJW->EJW_TPPROC=="A","RAS","RVS") +" deste Processo não foi totalmente gerado "+CHR(13)+CHR(10)+;
                      "devido ao(s) problema(s) abaixo:"+CHR(13)+CHR(10)+cMsgErro  )  // SSS - REQ 8 13/06/2014
         EndIf
      EndIf
      If EJW->(RecLock("EJW",.F.))
         EJW->EJW_MSGLOG := cMsgErro
         EJW->(MsUnLock())
      EndIf   
   EndIf
   
   
   
Next nLineExec

//NOPADO por RRC - 22/07/2013
//End TRANSACTION
//FIM DO CONTROLE DE TRANSACAO

RestOrd(aOrdEJ,.T.)   

Return !lMsErroAuto 
  



/*
Programa   : PS400FilEnq()
Objetivo   : Retornar o filtro utilizado pelo consulta padrão de enquadramentos (ELC)
Retorno    : cRet
Autor      : Rafael Ramos Capuano
Data       : 18/03/2013 - 16:33
*/

Function PS400FilEnq()
Local lRet := .F.

If IsInCallStack("ESSPS400")
   If Type("cPed") == "C"
      If cPed == "A"
         lRet := ELC->ELC_MODAQU == "S"
      Else
         lRet := ELC->ELC_MODVEN == "S"
      EndIf   
   EndIf
ElseIf IsInCallStack("ESSRS400")   
   If Type("cTpReg") == "C"
      If cTpReg == "A"
         lRet := ELC->ELC_MODAQU == "S"
      Else
         lRet := ELC->ELC_MODVEN == "S"
      EndIf   
   EndIf
EndIf
Return lRet


Static Function VerEnqRC()
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelEJX := oModel:GetModel("EJXDETAIL")
Local nI,nJ
Local aOrd      := SaveOrd({"ELC"})
ELC->(DbSetOrder(1)) //ELC_FILIAL + ELC_CODENQ

Begin Sequence

For nI := 1 To oModelEJX:Length()
   oModelEJX:GoLine(nI)
   If !oModelEJX:IsDeleted()
      For nJ := 1 To 3
         If !Empty(oModelEJX:GetValue("EJX_ENQ0"+AllTrim(Str(nJ)))) .And. Empty(oModelEJX:GetValue("EJX_RC0"+AllTrim(Str(nJ))))
            If ELC->(DbSeek(xFilial("ELC")+AvKey(oModelEJX:GetValue("EJX_ENQ0"+AllTrim(Str(nJ))),"ELC_CODENQ"))) .And. ELC->ELC_INDRC == "S"
               lRet := .F.
               EasyHelp("O serviço " + AllTrim(oModelEJX:GetValue("EJX_ITEM")) + " possui o enquadramento " + oModelEJX:GetValue("EJX_ENQ0"+AllTrim(Str(nJ))) + " que necessita do preenchimento do 'Nro. RC.'","Aviso")
               Break
            EndIf
         ElseIf Empty(oModelEJX:GetValue("EJX_ENQ0"+AllTrim(Str(nJ)))) .And. !Empty(oModelEJX:GetValue("EJX_RC0"+AllTrim(Str(nJ))))
            lRet := .F.
            EasyHelp("O serviço " + AllTrim(oModelEJX:GetValue("EJX_ITEM")) + " possui 'Nro. Rc.' sem enquadramento.","Aviso")
            Break
         EndIf      
      Next nJ
   EndIf
Next nI 

End Sequence
RestOrd(aOrd,.T.)
Return lRet           

/*
Programa   : PS400Legenda()
Objetivo   : Tela de legendas das cores de marcação.
Retorno    : 
Autor      : Fabio Satoru Yamamoto
Data       : 18/03/2013
*/
Function PS400Legenda()
Local aLegenda:= {}

   AAdd(aLegenda, {"BR_VERMELHO", 'Aguardando registro'})
   AAdd(aLegenda, {"BR_AZUL"    , 'Parcialmente em fase de registro'})
   AAdd(aLegenda, {"BR_AMARELO" , 'Em fase de registro'}) 
   AAdd(aLegenda, {"BR_VERDE"   , 'Encerrado'})  
   
   If lIntLogix //LGS-12/08/2015-So deve apresentar o status de cancelado qdo integrado com o Logix
      AAdd(aLegenda, {"BR_PRETO"   , 'Cancelado'})   //SSS - REQ.8 13/06/2014
   EndIF
   
   BrwLegenda("Processo de Serviços", 'Legendas', aLegenda) //Legenda

Return 
/*
Programa   : GetMsDocument()
Objetivo   : Função utilizada para chamada da rotina de vinculo de documento no metodo "oView:AddUserButton".
Autor      : Fabio Satoru Yamamoto
Data       : 03/04/2013
*/
//Deve existir objeto OMODEL ativo.
Static Function GetMsDocument()
Local oModel    := FWModelActive()
Local nOperacao := oModel:nOperation
Private aRotina := MenuDef() //FSY-17/01/2014
If nOperacao == 4//4 = ALTERAÇÃO
   MsDocument( "EJW", EJW->(RecNo()), 1,)
Else
   //MsgInfo("Opção permitida apenas para alteração!")
   EasyHelp("Opção permitida apenas para alteração!")  // SSS - REQ. 8 13/06/2014
End If 
Return .T.

Static Function AtuView(oView)
Local lRet := .T.
oView:aUserButtons := {} 
If Altera
   oView:AddUserButton("Conhecimento"        , "CLIPS",{|| GetMsDocument()})   
EndIf
lRet:= ESSPRE(oView)
Return lRet

/*
Programa   : PS400AtuReg()
Objetivo   : Realizar a geração automática do RAS/RVS para os processos
Retorno    : lRet
Parâmetros : nTotProc - Total de Processos a serem atualizados
Autor      : Rafael Ramos Capuano
Data       : 09/05/2013 - 13:37
Revisão    : set/2017 - posicionamento da tabela EJW pela query
*/   

Function PS400AtuReg(nTotProc)
Local lRet     := .T.
Local aOrd     := SaveOrd({"EJW","SM0"})
Local nRecProc := EJW->(Recno())
Local nRecEmpr := SM0->(Recno())
Local cFilOld  := xFilial("EJW")
Local cCodigo  := SM0->M0_CODIGO
Default nTotProc  := 0

Begin Sequence
If Type("cPed") == "C"
   EJW->(DbSetOrder(1)) //EJW_FILIAL + EJW_TPPROC + EJW_PROCES
   //RRC - 05/11/2013 - Alteração para atualizar todas as filiais
   If nTotProc > 0                                                 
      EJW->(DbGoTop())
      TMPEJW->(DBGoTop())
      SM0->(DbSetOrder(1))//M0_CODIGO+M0_CODFIL
      oProgress:SetRegua(nTotProc)
      //Do While EJW->(!Eof())   //comentado por wfs - 18/09/2017
      Do While TMPEJW->(!Eof())
         //wfs - posicionamento da tabela EJW pelos registros filtrados com a query
         EJW->(DBGoTo(TMPEJW->RECNO))
         //Se a filial do registro da EJW é a mesma que está ativa, não há necessidade de posicionar novamente na SM0
         If EJW->EJW_FILIAL == cFilAnt .Or. SM0->(DbSeek(cCodigo+EJW->EJW_FILIAL))
            If EJW->EJW_FILIAL <> cFilAnt
               cFilAnt := EJW->EJW_FILIAL
            EndIf
            PS400GeraReg(ALTERAR,.T.)
            If !oProgress:IncRegua()
               Break
            EndIf
            //EJW->(DbSkip()) //comentado por wfs - 18/09/2017
         EndIf
         TMPEJW->(DBSkip())
      EndDo
   EndIf
   // MsgInfo("Operação Finalizada!","Aviso")   
   EasyHelp("Operação Finalizada!","Aviso")     // SSS - REQ. 8 13/06/2014
EndIf   
End Sequence
EJW->(DbGoTo(nRecProc))
SM0->(DbGoTo(nRecEmpr)) //Restaura a filial da empresa ativa
cFilAnt := cFilOld      //Restaura conteúdo da variável private que mantém a filial ativa
RestOrd(aOrd,.T.)
Return lRet

/*
Programa   : PS400Qry()
Objetivo   : Monta query com os processos que possuem nota fiscal gerada pelo SIGACOM, e das despesas consideradas como Processo de Aquisição na integração SIGAEIC x SIGAESS
Parametros : cTipo - Tipo de Processo("A" - Aquisição e "V" - Venda), cProc - Processo a ser pesquisado 
Retorno    : lRet
Autor      : Rafael Ramos Capuano
Data       : 13/06/2013 - 11:21

*/
*-------------------------------*
Static Function PS400Qry(cTipo,cOrigem,cProc,cNota,cSerie,lInv,cForn,cLoja,cParc)
*-------------------------------*
Local cCond     := ""
Local cQuery    := ""
Local cRelac    := ""
Default cTipo   := ""
Default cProc   := ""
Default cOrigem := ""
Default cNota   := ""
Default cForn   := ""
Default cLoja   := ""
Default cParc   := ""
Default lInv    := .F.
Begin Sequence
  
  //RRC - 05/12/2013 - Atualização para cenário de integração entre SIGAEIC x SIGAESS com títulos gerados no SIGAFIN com origem do SIGAEIC
  If AllTrim(cOrigem) == "SIGAEIC"
     cRelac := "SWD.WD_CTRFIN1 = SE2.E2_NUM AND SWD.WD_PREFIXO = SE2.E2_PREFIXO AND SWD.WD_PARCELA = SE2.E2_PARCELA AND SWD.WD_FORN = SE2.E2_FORNECE AND SWD.WD_LOJA = SE2.E2_LOJA"
     cCond  := "SWD.WD_FILIAL = '" + xFilial("SWD") + "' AND SWD.WD_PREFIXO = '" + AvKey(cSerie,"WD_PREFIXO") + "' AND SWD.WD_CTRFIN1 = '" + AvKey(cNota,"WD_CTRFIN1") + "'"
     cCond  += " AND SWD.WD_PARCELA = '" + AvKey(cParc,"WD_PARCELA") + "' AND SWD.WD_FORN = '" + AvKey(cForn,"WD_FORN") + "' AND SWD.WD_LOJA = '" + AvKey(cLoja,"WD_LOJA") + "'"
     cCond  += /*" AND SE2.E2_ORIGEM = '" + AvKey(cOrigem,"E2_ORIGEM") + "'*/" AND SE2.E2_TIPO = " + "'" + MVNOTAFIS + "'"
     cCond  += " AND " + IIF(TcSrvType()<>"AS/400","SWD.D_E_L_E_T_<>'*' AND SE2.D_E_L_E_T_<>'*'","SWD.@DELETED@<>'*' AND SE2.@DELETED@<>'*'")
     cQuery := "SELECT DISTINCT SWD.R_E_C_N_O_ AS RECNO FROM " + RetSqlName("SWD") + " SWD INNER JOIN " + RetSqlName("SE2") + " SE2 ON "+ cRelac + " WHERE " + cCond
  ElseIf !lInv //Verifica se deve buscar as invoices (ELA,ELB) ou Notas Fiscais (SF1,SD1)
     If cTipo == "A"
        cRelac := "SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.F1_FORMUL = SD1.D1_FORMUL"                                                                                                               
        cCond  := "SF1.F1_FILIAL = '" + xFilial("SF1") + If(!Empty(cNota),"' AND SD1.D1_DOC = '" + AvKey(cNota,"D1_DOC"),"") + If(!Empty(cSerie),"' AND SD1.D1_SERIE = '" + AvKey(cSerie,"D1_SERIE"),"") + If(!Empty(cProc),"' AND SD1.D1_PEDIDO = '" + AvKey(cProc,"D1_PEDIDO"),"") + "' AND SD1.D1_TES <> '' AND SF1.F1_TIPO = 'N'"
        cCond  += " AND " + IIF(TcSrvType()<>"AS/400","SF1.D_E_L_E_T_<>'*' AND SD1.D_E_L_E_T_<>'*'","SF1.@DELETED@<>'*' AND SD1.@DELETED@<>'*'")
        cQuery := "SELECT DISTINCT SF1.R_E_C_N_O_ AS RECNO FROM " + RetSqlName("SF1") + " SF1 INNER JOIN " + RetSqlName("SD1") + " SD1 ON " + cRelac + " WHERE " + cCond
     ElseIf cTipo == "V"  // GFP - 02/09/2014
        cCond  := "SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_PEDIDO = '" + AvKey(cProc,"D2_PEDIDO") + "' AND " + IIF(TcSrvType()<>"AS/400","SD2.D_E_L_E_T_<>'*'","SD2.@DELETED@<>'*'")
        cQuery := "SELECT SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA FROM " + RetSqlName("SD2") + " SD2 WHERE " + cCond + " GROUP BY SD2.D2_DOC, SD2.D2_SERIE, SD2. D2_CLIENTE, SD2.D2_LOJA ORDER BY SD2.D2_DOC,SD2.D2_SERIE "
     EndIf
  Else  
     cCond  := "ELA.ELA_FILIAL = '" + xFilial("ELA") + If(!Empty(cNota),"' AND ELA.ELA_NRINVO = '" + AvKey(cNota,"ELA_NRINVO"),"") + If(!Empty(cProc),"' AND ELA.ELA_PROCES = '" + AvKey(cProc,"ELA_PROCES"),"") + "'"
     cCond  += " AND ELA.ELA_TPPROC = '" + AvKey(cTipo,"ELA_TPPROC") + "' AND ELA.ELA_ORIGEM = '" + AvKey(cOrigem,"ELA_ORIGEM") + "'"
     cCond  += " AND " + IIF(TcSrvType()<>"AS/400","ELA.D_E_L_E_T_<>'*'","ELA.@DELETED@<>'*'")
     cQuery := "SELECT DISTINCT ELA.R_E_C_N_O_ AS RECNO FROM " + RetSqlName("ELA") + " ELA WHERE " + cCond
  EndIf
  
End Sequence

Return cQuery

/*
Programa   : PS400PendProc()
Objetivo   : Realizar a geração automática do RAS/RVS para todos os processos
Retorno    : lRet
Autor      : Rafael Ramos Capuano
Data       : 09/05/2013 - 16:27
Revisão    : Set/2017 - Modificada a forma de filtrar os registros da tabela, corrigindo bug na aplicação de filtros que usam campos
             do tipo data e filtros relacionais. 
*/   

Function PS400PendProc()
Local lRet := .T.
Local lUserFiltro  := .F.
Local cMsg := ""
Local cFiltroDefault := ""
Local cFiltro        := ""
Local cQuery         := ""
Local nTotFiltro     := 0          
Local nTotProc       := 0
Local nI             := 2 
Local aOrd           := SaveOrd({"EJW"}) 
Local nRecProc       := EJW->(Recno())
Local nRecEmpr       := SM0->(Recno())
Local cFilOld        := xFilial("EJW") 
Private oProgress    := EasyProgress():New()

//RRC - 17/05/2013 - Verifica se existe um filtro adicionado pelo usuário na tela em conjunto com o filtro do programa
If Type("oBrowsePed") == "O" .And. Type("cPed") == "C"
   If (nTotFiltro := Len(oBrowsePed:oData:aFiltrate)) > 0  //Para o ESSPS400() sempre haverá o filtro por Tipo de Processo
      cFiltroDefault := oBrowsePed:oData:aFiltrate[1][2] //recebe o conteúdo do filtro default por Tipo de Processo definido pelo programa
      Do While nI <= nTotFiltro .And. !lUserFiltro
         //Verifica se existe um filtro de usuário ativo
         If !(cFiltroDefault == oBrowsePed:oData:aFiltrate[nI][2])
            lUserFiltro := .T.
         EndIf
         nI++ 
      EndDo
      /* comentado por wfs - set/2017 - adequação para uso de filtros com campo data e filtros de relacionamento
      cFiltro := oBrowsePed:oData:aFiltrate[nTotFiltro][2] //Recebe o conteúdo do filtro ativo no browse  


      EJW->(dbSetFilter(&("{||"+cFiltro+"}"),cFiltro))
      EJW->(DbSetOrder(1)) //EJW_FILIAL + EJW_TPPROC + EJW_PROCES
      //RRC - 04/11/2013 - Atualiza todas as filiais
      EJW->(DbGoTop())
      Do While EJW->(!Eof())
         nTotProc++
         EJW->(DbSkip())
      EndDo*/
      cQuery:= MontaQuery(oBrowsePed) //wfs 15/09/2017 - Retorna a query com os filtros realizados
      //contagem de registros
      nTotProc:= EasyQryCount(cQuery)
      //Filtro dos registros que serão atualizados
      EasyQry(cQuery, "TMPEJW")
      TcSetField("TMPEJW", "RECNO", "N", 8, 0)
   Else
      nTotProc := EJW->(EasyRecCount())
   EndIf
        
   If lUserFiltro
      If nTotProc > 1
         cMsg := "Foi definido um filtro para os processos. Deseja atualizar o "+ If(cPed=="A","RAS","RVS")+ " para os " + AllTrim(Str(nTotProc)) + " processos filtrados?"
      Else
         cMsg := "Foi definido um filtro para os processos. Deseja atualizar o "+ If(cPed=="A","RAS","RVS")+ " para o processo filtrado?"
      EndIf 
   Else
      If nTotProc > 1
         cMsg := "Deseja atualizar o " + If(cPed=="A","RAS","RVS")+ " para os " + AllTrim(Str(nTotProc)) + " processos?"
      Else
         cMsg := "Deseja atualizar o " + If(cPed=="A","RAS","RVS")+ " para o processo?"
      EndIf
   EndIf

   If nTotProc > 0 .And. MsgYesNo(cMsg,"Aviso")  
      oProgress:SetProcess({|| PS400AtuReg(nTotProc)},'Processando os dados...') 
      oProgress:Init()
   EndIf
   
   EJW->(DbClearFilter())

   If Select("TMPEJW") > 0
      TMPEJW->(DBCloseArea())
   EndIf

EndIf
EJW->(DbGoTo(nRecProc))
SM0->(DbGoTo(nRecEmpr)) //Restaura a filial da empresa ativa
cFilAnt := cFilOld      //Restaura conteúdo da variável private que mantém a filial ativa
RestOrd(aOrd,.T.)
Return lRet

/*
Programa   : PS400AltProc()
Objetivo   : Efetua a alteração do conteúdo do campo pertencente a chave primária EJW_PROCES (Processo) nas tabelas relacionadas
Parâmetros : Array com duas posições: uma referente ao conteúdo antigo do Processo e outra com o coteúdo atual. Tipo de Processo - "A" - Aquisição ou "V" - venda
Retorno    : lRet
Autor      : Rafael Ramos Capuano - (Adaptado do Original RS400AssociaPed() - Alessandro Alves Ferreira)
Data       : 16/05/2013 - 13:07
*/   

Static Function PS400AltProc(aProcessos,cTipo)
Local aTabsProc  := {}
Local aTabsReg   := {}
Local aOrd       := {}
Local cQuery
Local i, j
Local lIntFin      := EasyGParam("MV_AVG0226",,.F.)
Default aProcessos := {}
Default cTipo      := ""

If lIntPedServ
   aTabsReg := {"EJY","EJZ","EL2","EL9","EL1","EL3","EL4","EL5","EL6","EL7"}
EndIf
aTabsProc:= {"EJY","EJZ","EL2","EEQ","ELA","ELB","EL9","EL1"}   

If lIntFin
   cModulo := "ESS"             
   aOrd := SaveOrd({"SE1","SE2"})
   SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
   SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
EndIf

//Não está tratando processos em mais de um registro para documentos e pagamentos!
For i := 1 To Len(aProcessos)
   //Atualiza o número dos processos
   For j := 1 To Len(aTabsProc)
      cQuery := "Select R_E_C_N_O_ AS RECNO "
      cQuery += "From "+RetSqlName(aTabsProc[j])+" "+aTabsProc[j]+" "
      cQuery += "Where "+aTabsProc[j]+".D_E_L_E_T_ = '' AND "+aTabsProc[j]+"_FILIAL = '"+xFilial(aTabsProc[j])+"' AND " + aTabsProc[j]+"_TPPROC = '"+cTipo+"' AND "+aTabsProc[j]+"_PROCES = '"+AvKey(aProcessos[i][1],"EJY_PROCES")+"'"
                 
      If Select("WKPROC") > 0
         WKPROC->(dbCloseArea())
      EndIf
         
      
      cQuery := ChangeQuery(cQuery) //RRC - 04/11/2013 - Necessário devido a diferença entre sintaxe requerida pelo SQL Server e o Oracle
      dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"WKPROC",.F.,.F.)
      TcSetField("WKPROC","RECNO","N",8,0)
         
      Do While !WKPROC->(EoF())
         (aTabsProc[j])->(dbGoTo(WKPROC->RECNO))   
         RecLock(aTabsProc[j],.F.)
         (aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_PROCES"))>0,FieldPut(nPos,aProcessos[i][2]),))            
         If aTabsProc[j] == "EEQ"
            //(aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_PREEMB"))>0,FieldPut(nPos,cTipo+aProcessos[i][2]),))            
            If EEQ->(FieldPos("EEQ_PREEMB")) > 0          
               EEQ->EEQ_PREEMB := cTipo+aProcessos[i][2]
               //Se existir a integração com o Financeiro, deve alterar o conteúdo dos campos de histórico
               If lIntFin 
                  If cTipo == "A" 
                     If SE2->(DbSeek(xFilial("SE2")+AvKey(If(!Empty(EEQ->EEQ_PREFIX),EEQ->EEQ_PREFIX,cModulo),"E2_PREFIXO")+AvKey(EEQ->EEQ_FINNUM,"E2_NUM")+Int101Parc(EEQ->EEQ_PARC)+AvKey("NF","E2_TIPO")))
                        If SE2->(FieldPos("E2_HIST")) > 0
                           If RecLock("SE2",.F.)
                              SE2->E2_HIST := If(FindFunction('AF200HisEmb'),AF200HisEmb(),'Emb.:' + EEQ->EEQ_PREEMB)
                              SE2->(MsUnLock())
                           EndIf
                        EndIf
                     EndIf
                  ElseIf cTipo == "V"
                     If SE1->(DbSeek(xFilial("SE1")+cModulo+AvKey(EEQ->EEQ_FINNUM,"E1_NUM")+If('ESS' $ cModulo ,AvKey('1','E1_PARCELA'),AvKey(' ','E1_PARCELA'))+AvKey("NF","E1_TIPO")))
                        If SE1->(FieldPos("E1_HIST")) > 0
                           If RecLock("SE1",.F.)
                              SE1->E1_HIST := If(FindFunction('AF200HisEmb'),AF200HisEmb(),'Emb.:' + EEQ->EEQ_PREEMB)            
                              SE1->(MsUnLock())
                           EndIf
                        EndIf
                     EndIf
                  EndIf
               EndIf 
            Endif
         EndIf       
         (aTabsProc[j])->(MsUnLock())        
         WKPROC->(dbSkip())
      EndDo
   Next j
   //Atualiza número do Registro
   If lIntPedServ
      For j := 1 To Len(aTabsReg)
         cQuery := "Select R_E_C_N_O_ AS RECNO "
         cQuery += "From "+RetSqlName(aTabsReg[j])+" "+aTabsReg[j]+" "
         cQuery += "Where "+aTabsReg[j]+".D_E_L_E_T_ = '' AND "+aTabsReg[j]+"_FILIAL = '"+xFilial(aTabsReg[j])+"' AND " +aTabsReg[j]+"_TPPROC = '"+cTipo+"' AND "+aTabsReg[j]+"_REGIST = '"+AvKey(aProcessos[i][1],"EJW_PROCES")+"'"
                                       
         If Select("WKREG") > 0
            WKREG->(dbCloseArea())
         EndIf
         
         cQuery := ChangeQuery(cQuery) //RRC - 04/11/2013 - Necessário devido a diferença entre sintaxe requerida pelo SQL Server e o Oracle
         dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"WKREG",.F.,.F.)
         TcSetField("WKREG","RECNO","N",8,0)
         
         Do While !WKREG->(EoF())
            (aTabsReg[j])->(dbGoTo(WKREG->RECNO))
            RecLock(aTabsReg[j],.F.)
            (aTabsReg[j])->(If((nPos:=FieldPos(aTabsReg[j]+"_REGIST"))>0,FieldPut(nPos,aProcessos[i][2]),))            
            (aTabsReg[j])->(MsUnLock())
            WKREG->(dbSkip())
         EndDo
      Next j
   EndIf
Next i

RestOrd(aOrd,.T.)
Return .T.

/*
Programa   : PS400NroProc()
Objetivo   : Executar o viewdef com o campo EJW_PROCES liberado para alteração
Parâmetros : 
Retorno    : lRet
Autor      : Rafael Ramos Capuano 
Data       : 20/05/2013 - 10:46
*/

Function PS400NroProc()
Local aOrd    := SaveOrd({"EEQ"})
Local lLiq    := .F.
Local lIntFin := EasyGParam("MV_AVG0226",,.F.)

//RRC - 26/03/2013 - Verifica se existe parcela liquidada associada ao processo caso haja integração com o financeiro, neste caso, não deve permitir a alteração
If lIntFin
   EEQ->(DbSetOrder(13)) //EEQ->EEQ_FILIAL + EEQ->EEQ_TPPROC + EEQ->EEQ_PROCES
   cChave := xFilial("EEQ") + AvKey(EJW->EJW_TPPROC,"EEQ_TPPROC") + AvKey(EJW->EJW_PROCES,"EEQ_PROCES")
   If EEQ->(DbSeek(cChave))
      Do While !lLiq .And. EEQ->(!Eof()) .And. cChave == xFilial("EEQ") + EEQ->EEQ_TPPROC + EEQ->EEQ_PROCES
         lLiq := !Empty(EEQ->EEQ_PGT) 
         EEQ->(DbSkip())
      EndDo
   EndIf
EndIf

If !lLiq .And. !(AllTrim(EJW->EJW_ORIGEM) == "SIGACOM" .Or. AllTrim(EJW->EJW_ORIGEM) == "SIGAFAT")
   FWExecView('ALTERAR','VIEWDEF.ESSPS400', MODEL_OPERATION_UPDATE,  , { || .T. }, {|| .T.} )
ElseIf AllTrim(EJW->EJW_ORIGEM) == "SIGACOM" .Or. AllTrim(EJW->EJW_ORIGEM) == "SIGAFAT"
   EasyHelp("Este processo foi originado pelo módulo " + AllTrim(EJW->EJW_ORIGEM) + " e não poderá ter o número do processo alterado.")
Else
   EasyHelp("O número do Processo não pode sofrer alteração porque existe integração com o módulo Financeiro e parcela de câmbio liquidada.")
EndIf

RestOrd(aOrd,.T.)
Return .T.

/*
Programa   : PS400StaPag
Objetivo   : Atualizar o status de pagamento na capa em relação ao saldo dos processos.
Parâmetros : cTipo - Tipo de Processo; cPed - Processo
Autor      : Raphael Rodrigues Ventura
Data       : 02/04/2013 - 13:31:00
*/
Function PS400StaPag(cTipo, cPed)

Local aOrd    := SaveOrd({"EJW" ,"EJX"})
Local nSaldo  := 0
Local nTotal  := 0
Local cStatus := ''

Begin Sequence       
If ValType(cTipo) <> "U" .And. ValType(cPed) <> "U"
   EJX->(DbSetOrder(1))         
   If EJX->(DbSeek(xFilial("EJX") + AvKey(cTipo,"EJX_TPPROC") + AvKey(cPed,"EJX_PROCES")))       
      Do While EJX->(!EOF()) .And. xFilial("EJX") == EJX->EJX_FILIAL .And. AvKey(cTipo,"EJX_TPPROC") == EJX->EJX_TPPROC .And. AvKey(cPed,"EJX_PROCES") == EJX->EJX_PROCES
         nSaldo += EJX->EJX_SLDINV
         nTotal += EJX->EJX_VL_MOE
         EJX->(DbSkip())
      EndDo        
   EndIf
   
   If nSaldo == nTotal
      cStatus := '1'
   ElseIf nSaldo <> nTotal .And. nSaldo <> 0
      cStatus := '2'
   ElseIf nSaldo == 0
      cStatus := '3'
   EndIf
   
   EJW->(DbSetOrder(1))
   If EJW->(DbSeek(xFilial("EJW") + AvKey(cTipo,"EJW_TPPROC") + AvKey(cPed,"EJW_PROCES")))
      If EJW->(RecLock("EJW",.F.))
         EJW->EJW_STTFAT := cStatus
         EJW->(MsUnlock())
      EndIf
   EndIf  
EndIf
End Sequence
RestOrd(aOrd,.T.)

Return

/*
Programa   : PS400EmprAlt()
Objetivo   : Efetua a alteração do conteúdo do Cliente (Importador) ou Fornecedor (Exportador) e sua loja para as tabelas associadas.
Parâmetros : Array com duas posições: uma referente ao conteúdo antigo do Processo e outra com o coteúdo atual. Tipo de Processo - "A" - Aquisição ou "V" - venda
Retorno    : lRet
Autor      : Rafael Ramos Capuano - (Adaptado do Original RS400AssociaPed() - Alessandro Alves Ferreira)
Data       : 16/05/2013 - 13:07
*/   

Static Function PS400EmprAlt(aProcs,cTipo)
Local aTabsProc  := {}
Local aOrd       := {}
Local cQuery
Local i, j
Local lIntFin      := EasyGParam("MV_AVG0226",,.F.)
Default aProcs := {}
Default cTipo      := ""

aTabsProc:= {"ELA","ELB","EEQ"}   

If lIntFin
   cModulo := "ESS"             
   aOrd := SaveOrd({"SE1","SE2"})
   SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
   SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
EndIf

For i := 1 To Len(aProcs)
   //Atualiza o número dos processos
   For j := 1 To Len(aTabsProc)
      cQuery := "Select R_E_C_N_O_ AS RECNO "
      cQuery += "From "+RetSqlName(aTabsProc[j])+" "+aTabsProc[j]+" "
      cQuery += "Where "+aTabsProc[j]+".D_E_L_E_T_ = '' AND "+aTabsProc[j]+"_FILIAL = '"+xFilial(aTabsProc[j])+"' AND " +aTabsProc[j]+"_TPPROC = '"+cTipo+"' AND "+aTabsProc[j]+"_PROCES = '"+AvKey(aProcs[i][1],"EJW_PROCES")+"'"
                 
      If Select("WKEMPR") > 0
         WKEMPR->(dbCloseArea())
      EndIf
      
      cQuery := ChangeQuery(cQuery) //RRC - 04/11/2013 - Necessário devido a diferença entre sintaxe requerida pelo SQL Server e o Oracle   
      dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"WKEMPR",.F.,.F.)
      TcSetField("WKEMPR","RECNO","N",8,0)
         
      Do While !WKEMPR->(EoF())
         (aTabsProc[j])->(dbGoTo(WKEMPR->RECNO))   
         If RecLock(aTabsProc[j],.F.)
            //(aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_PREEMB"))>0,FieldPut(nPos,cTipo+aProcs[i][2]),))            
            If aTabsProc[j] == "ELA" .Or.aTabsProc[j] == "ELB"             
               If cTipo == "A" 
                  (aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_EXPORT"))>0 .And. FieldGet(nPos) == AvKey(aProcs[i][2],"EJW_EXPORT"),FieldPut(nPos,aProcs[i][3]),))            
                  (aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_LOJEXP"))>0 .And. FieldGet(nPos) == AvKey(aProcs[i][4],"EJW_LOJEXP"),FieldPut(nPos,aProcs[i][5]),))            
               ElseIf cTipo == "V"
                  (aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_IMPORT"))>0 .And. FieldGet(nPos) == AvKey(aProcs[i][2],"EJW_EXPORT"),FieldPut(nPos,aProcs[i][3]),))            
                  (aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_LOJIMP"))>0 .And. FieldGet(nPos) == AvKey(aProcs[i][4],"EJW_LOJEXP"),FieldPut(nPos,aProcs[i][5]),))            
               EndIf
            EndIf
            
            If aTabsProc[j] == "EEQ"
               If cTipo == "A" 
                  (aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_FORN"))>0 .And. FieldGet(nPos) == AvKey(aProcs[i][2],"EEQ_FORN"),FieldPut(nPos,aProcs[i][3]),))            
                  (aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_FOLOJA"))>0 .And. FieldGet(nPos) == AvKey(aProcs[i][4],"EEQ_FOLOJA"),FieldPut(nPos,aProcs[i][5]),))            
               ElseIf cTipo == "V"
                  (aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_IMPORT"))>0 .And. FieldGet(nPos) == AvKey(aProcs[i][2],"EEQ_IMPORT"),FieldPut(nPos,aProcs[i][3]),))            
                  (aTabsProc[j])->(If((nPos:=FieldPos(aTabsProc[j]+"_IMLOJA"))>0 .And. FieldGet(nPos) == AvKey(aProcs[i][4],"EEQ_IMLOJA"),FieldPut(nPos,aProcs[i][5]),))            
               EndIf
               //Se existir a integração com o Financeiro, deve alterar o conteúdo dos campos de histórico
           
               If lIntFin 
                  If cTipo == "A" 
                     If SE2->(DbSeek(xFilial("SE2")+AvKey(If(!Empty(EEQ->EEQ_PREFIX),EEQ->EEQ_PREFIX,cModulo),"E2_PREFIXO")+AvKey(EEQ->EEQ_FINNUM,"E2_NUM")+Int101Parc(EEQ->EEQ_PARC)+AvKey("NF","E2_TIPO")))
                        If SE2->(FieldPos("E2_HIST")) > 0
                           If RecLock("SE2",.F.)
                              SE2->E2_FORNECE := EEQ->EEQ_FORN
                              SE2->E2_LOJA    := EEQ->EEQ_FOLOJA
                              SE2->E2_NOMFOR  := Posicione("SA2",1,xFilial("SA2")+AvKey(EEQ->EEQ_FORN,"A2_COD")+AvKey(EEQ->EEQ_FOLOJA,"A2_LOJA"),"A2_NOME")
                              SE2->(MsUnLock())
                           EndIf
                        EndIf
                     EndIf
                  ElseIf cTipo == "V"
                     If SE1->(DbSeek(xFilial("SE1")+cModulo+AvKey(EEQ->EEQ_FINNUM,"E1_NUM")+If('ESS' $ cModulo ,AvKey('1','E1_PARCELA'),AvKey(' ','E1_PARCELA'))+AvKey("NF","E1_TIPO")))
                        If SE1->(FieldPos("E1_HIST")) > 0
                           If RecLock("SE1",.F.)
                              SE1->E1_CLIENTE := EEQ->EEQ_IMPORT
                              SE1->E1_LOJA    := EEQ->EEQ_IMLOJA
                              SE1->E1_NOMCLI  := Posicione("SA1",1,xFilial("SA1")+AvKey(EEQ->EEQ_IMPORT,"A1_COD")+AvKey(EEQ->EEQ_IMLOJA,"A1_LOJA"),"A1_NOME")
                              SE1->(MsUnLock())
                           EndIf
                        EndIf
                     EndIf
                  EndIf
               EndIf 
            EndIf
           
            (aTabsProc[j])->(MsUnLock())        
            WKEMPR->(dbSkip())
         EndIf
      EndDo
   Next j
Next i

RestOrd(aOrd,.T.)
Return .T.

/*
Programa   : PS400ItemInv()
Objetivo   : Verificar se o item do processo possui valor agregado em alguma invoice, para validar a exclusão
Parâmetros : cSeq - Sequência do item do Processo. lExcl - .T. para chamada de gravação(GravCamp),caso o item já esteja excluído do processo(EJX,) também deve ser excluído da invoice(ELB)
Retorno    : lRet - .T. caso permita exclusão, ou seja, não encontrou vínculo
Autor      : Rafael Ramos Capuano
Data       : 06/06/2013 - 17:11
*/   

Static Function PS400ItemInv(cSeq,lExcl) 
Local lRet      := .T.
Local cChaveAux := "", cChaveELA := "", cChaveELB := ""
Local aOrd      := SaveOrd({"ELA","ELB"}) 
Local oModel    := FWModelActive()
Local oModelEJX := oModel:GetModel("EJXDETAIL")
Local oView     := FWViewActive()
Default cSeq    := ""
Default lExcl   := .F.  //.F. quando a exclusão ainda não foi confirmada

If Type("lPS400Auto") <> "L" 
   lPS400Auto:= .F.
EndIf

Begin Sequence

If Type("cPed") == "C"
   ELA->(DbSetOrder(4)) //ELA_FILIAL + ELA_TPPROC + ELA_PROCES + ELA_NRINVO
   cChaveELA := xFilial("ELA")+AvKey(cPed,"ELA_TPPROC")+M->EJW_PROCES
   If ELA->(DbSeek(cChaveELA))
      If cPed == "A"
         ELB->(DbSetOrder(3)) //ELB_FILIAL+ELB_TPPROC+ELB_EXPORT+ELB_LOJEXP+ELB_NRINVO+ELB_PROCES+ELB_SEQPRC
         cChaveAux := xFilial("ELB")+AvKey(ELA->ELA_TPPROC,"ELB_TPPROC")+ELA->ELA_EXPORT+ELA->ELA_LOJEXP
      ElseIf cPed == "V"
         ELB->(DbSetOrder(2)) //ELB_FILIAL+ELB_TPPROC+ELB_IMPORT+ELB_LOJIMP+ELB_NRINVO+ELB_PROCES+ELB_SEQPRC
         cChaveAux := xFilial("ELB")+AvKey(ELA->ELA_TPPROC,"ELB_TPPROC")+ELA->ELA_IMPORT+ELA->ELA_LOJIMP
      EndIf
      Do While ELA->(!Eof()) .And. ELA->(ELA_FILIAL+ELA_TPPROC+ELA_PROCES) == cChaveELA
         cChaveELB := cChaveAux + AvKey(ELA->ELA_NRINVO,"ELB_NRINVO")+ELA->ELA_PROCES+AvKey(cSeq,"ELB_SEQPRC")
         //Verifique se o item possui valor agregado em alguma invoice
         If ELB->(DbSeek(cChaveELB))
            If !(ELB->(ELB_VLCAMB+ELB_VLEXT) == 0)
               EasyHelp("O serviço não pode ser excluído pois o processo possui invoice associada.")
               lRet := .F.
               If oModelEJX:IsDeleted()
                  If !lPS400Auto
                     oView:GETVIEWOBJ("EJXDETAIL")[3]:Refresh() //Atualiza o objeto
                  EndIf
                  oModelEJX:UnDeleteLine()
                  RestOrd(aOrd,.T.)
                  Break
               EndIf
               //A exclusão do item no Processo já foi confirmada, logo ele deve ser excluído da invoice também
            ElseIf lExcl
               ELB->(RecLock("ELB",.F.))
               ELB->(DbDelete())
               ELB->(MsUnLock())            
            EndIf
         EndIf
         ELA->(DbSkip())
      EndDo
   EndIf
EndIf   

End Sequence
RestOrd(aOrd,.T.)
Return lRet


/*
Programa   : PS400BuscFat
Objetivo   : Buscar faturas dos módulos SIGACOM e SIGAFAT, além dos títulos no SIGAFIN a partir da integração SIGAEIC x SIGAESS
Parâmetros : cProc - Numero do processo.
Autor      : Raphael Rodrigues Ventura
Data       : 24/04/2013 - 11:21:19
Revisão    : 05/12/2013 - 11:52 - RRC
*/
Function PS400BuscFat(cTipo,cOrigem,cProc,cNota,cSerie,lInteg,cForn,cLoja,cParc)

Local aOrd      := SaveOrd({"SF1","SD1","SF2","SD2","SE1","SE2","ELA","EEQ","EJX","EJW"})
Local aCab      := {}
Local aAuxItens := {}
Local aItens    := {}
Local aInvoices := {}
Local aAuxInv   := {} //Armazenas as invoices atualizadas
Local aAuxParcs := {}
Local aParcelas := {}
Local lCont     := .T.
Local lInv      := .F.
Local nI        := 0
Local nJ        := 0
Local nOpc      := 0
Local cQuery    := ""
Local cMsg      := ""
Local cChave    := ""
Local cMoeda    := ""
Local lGrav     := .T.
Local nOldRec   := 0
Local nTxMoeda
Local cMoeTit   := ""
Local lMostraMsg:= .F.
Local dTxMoeFat
Default cTipo   := ""
Default cOrigem := ""
Default cNota   := ""
Default cProc   := ""
Default cSerie  := ""
Default lInteg  := .F.
Default cForn   := "" //RRC - 05/12/2013 - Variáveis para integração SIGAEIC x SIGAESS com título gerado pelo SIGAFIN com origem do SIGAEIC
Default cLoja   := ""
Default cParc   := ""
Private lMsErroAuto := .F.

Begin Sequence

If EasyVal1Dup("A") .AND. Len(EasyGParam("MV_1DUP")) > Len(EEQ->EEQ_PARC)  // GFP - 01/09/2015
   MsgInfo("Não é possível efetuar a integração de parcelas de câmbio com o SIGAESS pois o conteudo "+;
            "do parametro 'MV_1DUP' não está em conformidade com o tamanho do campo EEQ_PARC."+ ENTER +;
            "O tamanho do campo EEQ_PARC,EL9_PARC e EL1_PARC deve ser o dobro do tamanho do conteudo informado no parametro 'MV_1DUP'.","Aviso")
   Break
EndIf

//wfs
If lInteg
   lMostraMsg:= lInteg
   lInteg:= .F.
EndIf
If Type("cAviso") == "U"
   cAviso := AvObject():New()
EndIf

If Empty(cTipo)
   //MsgInfo("O Tipo de processo (Aquisição ou Venda) não foi informado.","Aviso")
   Break
ElseIf Empty(cOrigem)
   //MsgInfo("A origem do processo não foi informada.","Aviso")
   Break
ElseIf AllTrim(cOrigem) == "SIGAEIC" .And. !(SWD->(FieldPos("WD_MOEDA")) > 0 .And. SWD->(FieldPos("WD_VL_MOE")) > 0 .And. SWD->(FieldPos("WD_TX_MOE")) > 0) .And. FindFunction("DI500ESS")
   Break   
ElseIf cTipo == "A" //Processo de Aquisicao 
   If cOrigem <> "SIGACOM" .And. cOrigem <> "SIGAEIC"
      //MsgInfo("O processo " + AllTrim(cProc) + " não foi integrado pelo SIGACOM.","Aviso")
      Break
   EndIf
ElseIf cTipo == "V" //Processo de Venda   
   If cOrigem <> "SIGAFAT"
      //MsgInfo("O processo " + AllTrim(cProc) + " não foi integrado pelo SIGAFAT.","Aviso")
      Break
   EndIf
EndIf   
//RRC - 13/06/2013 - Cria Query com os Pedidos a serem considerados pelo Siscoserv 
cQuery := PS400Qry(cTipo,cOrigem,cProc,cNota,cSerie,.F.,cForn,cLoja,cParc) 
      
If Select("WKNOTA") > 0
   WKNOTA->(dbCloseArea())
EndIf  

cQuery := ChangeQuery(cQuery) //RRC - 04/11/2013 - Necessário devido a diferença entre sintaxe requerida pelo SQL Server e o Oracle
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"WKNOTA",.F.,.F.)
TcSetField("WKNOTA","RECNO","N",8,0)

//RRC - 05/12/2013 - Integração SIGAEIC x SIGAESS com título gerado pelo SIGAFIN com origem do SIGAEIC
If AllTrim(cOrigem) == "SIGAEIC"
   nOldRec := SWD->(Recno())
   WKNOTA->(DbGoTop())
   Do While WKNOTA->(!Eof())
      SWD->(DbGoTo(WKNOTA->RECNO))
      DI500ESS(SWD->WD_HAWB,ALTERAR)
      WKNOTA->(DbSkip())
   EndDo
   SWD->(DbGoTo(nOldRec))
   Break  
EndIf
   
If cTipo == "A" //Processo de Aquisição  
   
   ELA->(DbSetOrder(4))   //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
   EJW->(DbSetOrder(1))   //EJW_FILIAL+EJW_TPPROC+EJW_PROCES
   EJX->(DbSetorder(1))   //EJX_FILIAL+EJX_TPPROC+EJX_PROCES+EJX_SEQPRC
   SD1->(DbSetOrder(1))   //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
   WKNOTA->(DbGoTop())
   //Inclusão e Alteração
   Do While WKNOTA->(!EOF())        
      SF1->(dbGoTo(WKNOTA->RECNO))
      cChave := xFilial("SD1")+AvKey(SF1->F1_DOC,"D1_DOC")+AvKey(SF1->F1_SERIE,"D1_SERIE")+AvKey(SF1->F1_FORNECE,"D1_FORNECE")+AvKey(SF1->F1_LOJA,"D1_LOJA")
       //Chave única SF1: F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL
       //Chave única ELA: ELA_FILIAL+ELA_TPPROC+ELA_EXPORT+ELA_LOJEXP+ELA_IMPORT+ELA_LOJIMP+ELA_NRINVO+ELA_PROCES
      SD1->(DbSeek(cChave))
	  
	  nItNF := 0
	  nValNF:= 0
	  Do While SD1->(!Eof()) .And. SD1->(D1_FILIAL + D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cChave .And. !Empty(SD1->D1_TES)
	     nItNF++
		 nValNF += SD1->D1_TOTAL
	     SD1->(DbSkip())
	  EndDo
	  
	  If SD1->(DbSeek(cChave)) 
         cMoeTit := PS400MdInv()

		 //SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
      SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
      //cChaveSE2 := xFilial("SE2")+AvKey(SF1->F1_PREFIXO,"E2_PREFIXO")+AvKey(SF1->F1_DUPL,"E2_NUM")
      cChaveSE2 := xFilial("SE2")+AvKey(SF1->F1_FORNECE, "E2_FORNECE") + AvKey(SF1->F1_LOJA, "E2_LOJA") + AvKey(SF1->F1_PREFIXO,"E2_PREFIXO")+AvKey(SF1->F1_DUPL,"E2_NUM")
      nVlTit := 0
      SE2->(DbSeek(cChaveSE2))                                         
      //Do While SE2->(!EOF()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == cChaveSE2 //SE2->E2_TIPO <> "CID" //LRS - 16/05/2016
      Do While SE2->(!EOF()) .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cChaveSE2 //SE2->E2_TIPO <> "CID" //LRS - 16/05/2016
         IF SE2->E2_TIPO == MVNOTAFIS //AAF 18/09/2017 - Tratamento para considerar nenhum outro imposto.
            nVlTit += SE2->E2_VALOR  //SE2->E2_VLCRUZ
         EndIf

         SE2->(DbSkip())
      EndDo
         
         oRateio:= EasyRateio():New(nVlTit,nValNF,nItNF,AvSx3("ELB_VLCAMB",AV_DECIMAL))
         
         Do While SD1->(!Eof()) .And. SD1->(D1_FILIAL + D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cChave .And. !Empty(SD1->D1_TES)
            If PosPrcESS(cTipo,SD1->D1_PEDIDO)
               //Verifica a origem do valor da moeda a ser considerado na invoice
               If !Empty(cMoeTit)
                  cMoeda := cMoeTit
               Else
                  cMoeda := "R$"
               EndIf
            Else
               SD1->(DbSkip()) //LRS - 29/08/2017  
               loop    
            EndIf
            If !(lInv := ELA->(DbSeek(xFilial("ELA")+AvKey(cTipo,"ELA_TPPROC")+AvKey(SD1->D1_PEDIDO,"ELA_PROCES")+AvKey(SF1->F1_DOC,"ELA_NRINVO"))))
               nOpc := INCLUIR                                    
            Else
               nOpc := ALTERAR
            EndIf
            //RRC - 11/06/2013 - Verifica se o item utilizado possui NBS associada, ou seja, se o mesmo é um serviço a ser considerado pelo Siscoserv             
            If (Empty(cProc) .Or. SD1->D1_PEDIDO == AvKey(cProc,"D1_PEDIDO")) .And. EJX->(dbSeek(xFilial("EJX")+AvKey(cTipo,"EJX_TPPROC")+AvKey(SD1->D1_PEDIDO,"EJX_PROCES")+AvKey(SD1->D1_ITEMPC,"EJX_SEQPRC"))) .And. !Empty(EJX->EJX_NBS)          
               //RRC - 12/06/2013 - Deve incluir uma nova invoice para cada Nota Fiscal encontrada, se já possuir a invoice, pode acrescentar um novo item
               //Chave única SF1: F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL
               If Empty(aAuxInv) .Or. !(nPosInv := aScan(aAuxInv,{|x| x == SD1->D1_DOC+SD1->D1_PEDIDO})) > 0

                  aCab      := {}
                  aItens    := {}
                  aAuxItens := {}
                  aAdd(aCab,{"ELA_FILIAL",xFilial("ELA")  ,Nil})
                  aAdd(aCab,{"ELA_TPPROC",cTipo           ,Nil})
                  aAdd(aCab,{"ELA_EXPORT",SF1->F1_FORNECE ,Nil})
                  aAdd(aCab,{"ELA_LOJEXP",SF1->F1_LOJA    ,Nil})
                  aAdd(aCab,{"ELA_ORIGEM",cOrigem         ,Nil})
                  aAdd(aCab,{"ELA_PROCES",SD1->D1_PEDIDO  ,Nil})
                  aAdd(aCab,{"ELA_NRINVO",SF1->F1_DOC     ,Nil})
                  aAdd(aCab,{"ELA_DTEMIS",SF1->F1_EMISSAO ,Nil})
                  aAdd(aCab,{"ELA_MOEDA" ,AvKey(cMoeda,"ELA_MOEDA")  ,Nil})

                  nTxMoeda := If(cMoeda == "R$",1,SF1->F1_TXMOEDA) //AAF 31/08/2015 - Cotação da moeda do título
                  aAdd(aCab,{"ELA_TX_MOE",nTxMoeda,Nil})
                  If cMoeda <> EJW->EJW_MOEDA
                     SC7->(dbSetOrder(1))
                     SC7->(dbSeek(xFilial("SC7")+SD1->D1_PEDIDO))
                     nTxMoePed := SC7->C7_TXMOEDA //AAF 31/08/2015 - Utilizar cotacao da moeda no pedido.
                     aAdd(aCab,{"ELA_TX_PED" , nTxMoePed           ,Nil})
                     aAdd(aCab,{"ELA_PARIDA" , nTxMoeda / nTxMoePed,Nil}) //AAF 31/08/2015 - Calculo correto da paridade entre titulo/invoice e processo.
                  EndIf
                  aAdd(aCab,{"ELA_DOC"   ,SF1->F1_DOC     ,Nil})
                  aAdd(aCab,{"ELA_SERIE" ,SF1->F1_SERIE   ,Nil})
                  aAdd(aCab,{"ELA_MODELO",AModNot(SF1->F1_ESPECIE),Nil})
                  aAdd(aAuxItens,{"ELB_SEQPRC" ,EJX->EJX_SEQPRC    ,Nil})

                  If cMoeda == "R$"
                     aAdd(aAuxItens,{"ELB_VLCAMB" ,SD1->D1_TOTAL   ,Nil})
                  Else
                     aAdd(aAuxItens,{"ELB_VLCAMB" ,oRateio:GetItemRateio(SD1->D1_TOTAL)   ,Nil}) //AAF 31/08/2015 - Considerar valor rateado da moeda do titulo para o valor em reais de cada item.
                  EndIf

                  aAdd(aAuxItens,{"ELB_VLEXT"  ,0  ,Nil})
                  aAdd(aItens,aClone(aAuxItens))

                  //Array auxiliar com as invoices do processo originadas da Nota Fiscal do SIGACOM
                  aAdd(aAuxInv,SD1->D1_DOC+SD1->D1_PEDIDO)                  
                  aAdd(aInvoices,{aClone(aCab),aClone(aItens),nOpc})                           
               Else               
                  aAuxItens := {}
                  aAdd(aAuxItens,{"ELB_SEQPRC" ,EJX->EJX_SEQPRC,Nil})
                  If cMoeda == "R$"
                     aAdd(aAuxItens,{"ELB_VLCAMB" ,SD1->D1_TOTAL   ,Nil})
                  Else
                     aAdd(aAuxItens,{"ELB_VLCAMB" ,oRateio:GetItemRateio(SD1->D1_TOTAL)   ,Nil}) //AAF 31/08/2015 - Considerar valor rateado da moeda do titulo para o valor em reais de cada item.
                  EndIf
                  aAdd(aAuxItens,{"ELB_VLEXT"  ,0  ,Nil})
                  aAdd(aInvoices[If(nPosInv>0,nPosInv,Len(aAuxItens))][2],aClone(aAuxItens))
               EndIf
               If (Empty(aAuxParcs) .Or. aScan(aAuxParcs,{|x| x[1] == SD1->D1_PEDIDO}) <= 0) .And. !Empty(SF1->F1_DUPL)
                  aAdd(aAuxParcs,{SD1->D1_PEDIDO,SD1->D1_DOC,SF1->F1_PREFIXO,SD1->D1_FORNECE,SD1->D1_LOJA})
               EndIf
            EndIf
            SD1->(DbSkip())
         EndDo
      EndIf
      aAdd(aParcelas,aClone(aAuxParcs))
      aAuxParcs := {}
      WKNOTA->(DbSkip())
   EndDo
   
   //Exclusão: Não existe o documento de entrada, porém, existe invoice com origem do SIGACOM  
   If WKNOTA->(Eof() .And. Bof())
      nOpc := EXCLUIR
      PS400ExclFat(cTipo,cOrigem,cProc,cNota,cSerie,lInteg)
   EndIf  
ElseIf cTipo == "V" //Processo de Venda
   
   ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
   EJX->(DbSetorder(1)) //EJX_FILIAL+EJX_TPPROC+EJX_PROCES+EJX_SEQPRC
   SF2->(dbsetorder(1)) //
   SD2->(dbSetOrder(3)) //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
   WKNOTA->(DbGoTop())
   Do While WKNOTA->(!EOF())
      SF2->(DbSeek(xFilial("SF2") + AvKey(WKNOTA->D2_DOC,"F2_DOC") + AvKey(WKNOTA->D2_SERIE,"F2_SERIE") + AvKey(WKNOTA->D2_CLIENTE,"F2_CLIENTE") + AvKey(WKNOTA->D2_LOJA,"F2_LOJA")))
      cChave := xFilial("SF2")+AvKey(SF2->F2_DOC,"F2_DOC")+AvKey(SF2->F2_SERIE,"F2_SERIE")+AvKey(SF2->F2_CLIENTE,"F2_CLIENTE")+AvKey(SF2->F2_LOJA,"F2_LOJA")
      // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
      cChaveSE1 := xFilial("SE1")+AvKey(SF2->F2_CLIENTE, "E1_CLIENTE") + AvKey(SF2->F2_LOJA, "E1_LOJA") + AvKey(SF2->F2_PREFIXO,"E1_PREFIXO")+AvKey(SF2->F2_DUPL,"E1_NUM")
      nItNF := 0
      nValNF:= 0
      SD2->(dbSeek(cChave))
      Do While SD2->(!Eof()) .And. SD2->(D2_FILIAL + D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == cChave .And. !Empty(SD2->D2_TES)
        nItNF++
        nValNF += SD2->D2_TOTAL
        SD2->(DbSkip())
      EndDo
      If SD2->(dbSeek(cChave))

        nVlTit := 0
        SE1->(DbSetOrder(2),DbSeek(cChaveSE1))
        Do While SE1->(!EOF()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cChaveSE1
          IF "NF" $ SE1->E1_TIPO //MVNOTAFIS
              nVlTit += SE1->E1_VALOR
              cMoeTit := EasyGParam("MV_SIMB"+Alltrim(Str(SE1->E1_MOEDA)),,"")
          EndIf
          SE1->(DbSkip())
        EndDo

        oRateio:= EasyRateio():New(nVlTit,nValNF,nItNF,AvSx3("ELB_VLCAMB",AV_DECIMAL))
  
        //RRC - 11/06/2013 - Verifica se o item possui NBS no processo associada para ser considerado pelo Siscoserv
        Do While SD2->(!Eof()) .And. SD2->(D2_FILIAL + D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == cChave .And. !Empty(SD2->D2_TES)
          If SD2->D2_PEDIDO == AvKey(cProc,"D2_PEDIDO") .And. EJX->(dbSeek(xFilial("EJX")+AvKey(cTipo,"EJX_TPPROC")+AvKey(cProc,"EJX_PROCES")+AvKey(SD2->D2_ITEMPV,"EJX_SEQPRC"))) .And. !Empty(EJX->EJX_NBS)
              If !PosPrcESS(cTipo,SD2->D2_PEDIDO)
                SD2->(DbSkip())
                loop
              else
                If !Empty(cMoeTit)
                  cMoeda := cMoeTit
                Else
                  cMoeda := "R$"
                EndIf
              EndIf

              //Chave única SF2: F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
              //Chave única ELA: ELA_FILIAL+ELA_TPPROC+ELA_EXPORT+ELA_LOJEXP+ELA_IMPORT+ELA_LOJIMP+ELA_NRINVO+ELA_PROCES
              //A condição será veradeira caso a invoice ainda não exista, ou caso ainda não tenha sida inserida no array que será usado no MsExecAuto.
              If !(lInv := ELA->(DbSeek(xFilial("ELA")+AvKey(cTipo,"ELA_TPPROC")+AvKey(cProc,"ELA_PROCES")+AvKey(SF2->F2_DOC,"ELA_NRINVO"))))
                nOpc := INCLUIR
              Else
                nOpc := ALTERAR
              EndIf

              //RRC - 12/06/2013 - Deve incluir uma nova invoice para cada Nota Fiscal encontrada, se já possuir a invoice, pode acrescentar um novo item
              If Empty(aAuxInv) .Or. !aScan(aAuxInv,{|x| x == SD2->D2_DOC+SD2->D2_PEDIDO}) > 0  // GFP - 13/08/2015
                aCab      := {}
                aItens    := {}
                aAuxItens := {}
                
                aAdd(aCab,{"ELA_FILIAL",xFilial("ELA")  ,Nil})
                aAdd(aCab,{"ELA_TPPROC",cTipo           ,Nil})    		
                aAdd(aCab,{"ELA_IMPORT",SF2->F2_CLIENTE ,Nil})
                aAdd(aCab,{"ELA_LOJIMP",SF2->F2_LOJA    ,Nil})
                aAdd(aCab,{"ELA_DOC"   ,SF2->F2_DOC     ,Nil})
                aAdd(aCab,{"ELA_SERIE" ,SF2->F2_SERIE   ,Nil})
                aAdd(aCab,{"ELA_MODELO",AModNot(SF2->F2_ESPECIE),Nil})
                aAdd(aCab,{"ELA_ORIGEM",cOrigem         ,Nil})
                aAdd(aCab,{"ELA_PROCES",cProc           ,Nil})
                aAdd(aCab,{"ELA_NRINVO",SF2->F2_DOC     ,Nil})
                aAdd(aCab,{"ELA_DTEMIS",SF2->F2_EMISSAO ,Nil})

                aAdd(aCab,{"ELA_MOEDA" ,AvKey(cMoeda,"ELA_MOEDA")  ,Nil})

                //AAF 31/08/2015 - Cotação da moeda do título
                //nTxMoeda - Taxa da moeda do título
                dTxMoeFat := IIF(!Empty(SF2->F2_DTTXREF),SF2->F2_DTTXREF,SF2->F2_EMISSAO)
                nTxMoeda := If(cMoeda == "R$",1,SF2->F2_TXMOEDA)
                IF nTxMoeda == 0
                    nTxMoeda := RecMoeda(dTxMoeFat, Posicione("SYF", 1, xFilial("SYF") + cMoeda, "YF_MOEFAT"))
                ENDIF
                aAdd(aCab,{"ELA_TX_MOE",nTxMoeda,Nil})
                If cMoeda <> EJW->EJW_MOEDA
                    nTxMoePed := RecMoeda(dTxMoeFat, Posicione("SYF", 1, xFilial("SYF") + EJW->EJW_MOEDA, "YF_MOEFAT"))
                    //AAF 31/08/2015 - Utilizar cotacao da moeda no pedido.
                    aAdd(aCab,{"ELA_TX_PED" , nTxMoePed           ,Nil})
                EndIf
                
                
                //ATENÇÃO
                //Ao efetuar alguma alteração no codigo em que trata os itens para o Array aAuxItens,
                //alterar tbm o Else, pois quando se tem mais de um item, ele tratará pelo Else
                aAdd(aAuxItens,{"ELB_SEQPRC" , EJX->EJX_SEQPRC,Nil})
                //AAF 31/08/2015 - Considerar valor rateado da moeda do titulo para o valor em reais de cada item.
                If cMoeda == "R$"
                    aAdd(aAuxItens,{"ELB_VLCAMB" ,SD2->D2_TOTAL   ,Nil})
                Else
                    aAdd(aAuxItens,{"ELB_VLCAMB" ,oRateio:GetItemRateio(SD2->D2_TOTAL)   ,Nil})
                EndIf
                aAdd(aAuxItens,{"ELB_VLEXT"  , 0  ,Nil})
                aAdd(aItens,aClone(aAuxItens))
                    
                //Array auxiliar com as invoices do processo originadas da Nota Fiscal do SIGACOM
                aAdd(aAuxInv,SD2->D2_DOC+SD2->D2_PEDIDO)  // GFP - 13/08/2015
                    
                aAdd(aInvoices,{aClone(aCab),aClone(aItens),INCLUIR})

              Else
                aAuxItens := {}
                If (nPos := aScan(aInvoices[Len(aAuxInv)][2], {|x| x[1][2] == EJX->EJX_SEQPRC })) > 0
                  If cMoeda == "R$"
                    aInvoices[Len(aAuxInv)][2][nPos][2][2] += SD2->D2_TOTAL
                  Else
                    aInvoices[Len(aAuxInv)][2][nPos][2][2] += oRateio:GetItemRateio(SD2->D2_TOTAL)
                  EndIf
                Else
                  aAdd(aAuxItens,{"ELB_SEQPRC" ,EJX->EJX_SEQPRC,Nil})
                  //AAF 31/08/2015 - Considerar valor rateado da moeda do titulo para o valor em reais de cada item.
                  If cMoeda == "R$"
                      aAdd(aAuxItens,{"ELB_VLCAMB" ,SD2->D2_TOTAL   ,Nil})
                  Else
                      aAdd(aAuxItens,{"ELB_VLCAMB" ,oRateio:GetItemRateio(SD2->D2_TOTAL)   ,Nil})
                  EndIf
                  aAdd(aAuxItens,{"ELB_VLEXT"  ,0  ,Nil})
                  aAdd(aInvoices[Len(aAuxInv)][2],aClone(aAuxItens))
                EndIf
              EndIf
          EndIf
          SD2->(dbSkip())
        EndDo
      EndIf
      WKNOTA->(DbSkip())
   EndDo
   
EndIf

If Len(aAuxInv) == 0 .And. !Empty(cProc) .And. nOpc <> EXCLUIR
   If !lInteg
      cAviso:Error("Não foram geradas " + If(cTipo=="A","invoices", "faturas") + " para o processo " + AllTrim(cProc) + ".")
   EndIf 
   Break
ElseIf nOpc <> EXCLUIR
   //RRC - 12/06/2013
   For nI := 1 To Len(aInvoices)
      /*O sistema irá atualizar a invoice e as parcelas de câmbio. Para o cenário desta função, os títulos já foram atualizados, sendo assim, o último
      parâmetro indica que o sistema não irá procurar pelos títulos, ou seja, a atualização se deu primeiro no SIGAFIN.*/
      MsExecAuto({|a,b,c,d,e,f,g| ESSIS400("ELA",,,cTipo,aInvoices[nI][1],aInvoices[nI][2],aInvoices[nI][3],.F.)})
      If lMsErroAuto                                    
         If !(ValType(NomeAutoLog()) == "U")
            cMsg := MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
         EndIf
         If !lInteg
            cAviso:Error("Processo: " + AllTrim(cProc) + " " + cMsg)
         EndIf
         Break
      EndIf
   Next nI
   If EasyGParam("MV_ESS0013",,.F.)
      For nI := 1 To Len(aParcelas)
         For nJ := 1 To Len (aParcelas[nI])
            lGrav := PS400GerParc(cTipo,aParcelas[nI][nJ][1],aParcelas[nI][nJ][2],aParcelas[nI][nJ][3],aParcelas[nI][nJ][4],aParcelas[nI][nJ][5],INCLUIR,lInteg)
         Next nJ
      Next nI
   EndIf
EndIf

//wfs
If lMostraMsg .And. cAviso:HasErrors()
   cAviso:Error("Integração Easy Siscoserv:")
   cAviso:Error('Acesse o módulo Easy Siscoserv (SIGAESS) e utilize a opção "Buscar Invoices" para atualizar as informações não integradas.')
   cAviso:ShowErrors()
EndIf

End Sequence

RestOrd(aOrd,.T.)

Return Nil

/*
Programa   : PS400ExclFat
Objetivo   : Atualizar o SIGAESS com a exclusão da invoice porque a nota fiscal de origem foi excluída: Integração com SIGACOM e SIGAFAT 
Parâmetros : cProc - Numero do processo.
Autor      : Rafael Ramos Capuano	
Data       : 24/06/2013 - 15:19
*/
 
Function PS400ExclFat(cTipo,cOrigem,cProc,cNota,cSerie,lInteg)
Local nRecno        := ELA->(Recno()) 
Local cQuery        := ""
Local cMsg          := ""
Local aCab          := {}
Local aItens        := {}
Default lInteg      := .F.
Private lMsErroAuto := .F.

If Type("cAviso") == "U"
   cAviso := AvObject():New()
EndIf

//RRC - 13/06/2013 - Cria Query as Invoices a serem excluídas
cQuery := PS400Qry(cTipo,cOrigem,cProc,cNota,cSerie,.T.) 
      
If Select("WKINV") > 0
   WKINV->(dbCloseArea())
EndIf  
   
cQuery := ChangeQuery(cQuery) //RRC - 04/11/2013 - Necessário devido a diferença entre sintaxe requerida pelo SQL Server e o Oracle
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"WKINV",.F.,.F.)
TcSetField("WKINV","RECNO","N",8,0)

Begin Sequence

WKINV->(DbGoToP())
If WKINV->(!(Eof() .And. Bof()))
   Do While WKINV->(!Eof())
      ELA->(DbGoTo(WKINV->RECNO))
      aCab := {}
      aAdd(aCab,{"ELA_FILIAL",ELA->ELA_FILIAL ,Nil})
      aAdd(aCab,{"ELA_TPPROC",ELA->ELA_TPPROC ,Nil})
      If cTipo == "A"
         aAdd(aCab,{"ELA_EXPORT",ELA->ELA_EXPORT ,Nil})
         aAdd(aCab,{"ELA_LOJEXP",ELA->ELA_LOJEXP ,Nil})
      ElseIf cTipo == "V"
         aAdd(aCab,{"ELA_IMPORT",ELA->ELA_IMPORT ,Nil})
         aAdd(aCab,{"ELA_LOJIMP",ELA->ELA_LOJIMP ,Nil})
      EndIf
      aAdd(aCab,{"ELA_PROCES",ELA->ELA_PROCES ,Nil})
      aAdd(aCab,{"ELA_NRINVO",ELA->ELA_NRINVO ,Nil})
      /*Ao excluir a invoice, o sistema irá excluir também as parcelas de câmbio. Para o cenário desta função, os títulos já foram excluídos, sendo assim, o último
      parâmetro indica que ao excluir as parcelas, o sistema não irá procurar pelos títulos, ou seja, a atualização se deu primeiro no SIGAFIN.*/
      MsExecAuto({|a,b,c,d,e,f,g,h| ESSIS400("ELA",,,cTipo,aCab,aItens,EXCLUIR,.F.)})
      If lMsErroAuto                                    
         If !(ValType(NomeAutoLog()) == "U")
            cMsg := MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
         EndIf
         If !lInteg
            cAviso:Error("Processo: " + AllTrim(cProc) + " " + cMsg)
         EndIf
         Break
      EndIf
      WKINV->(DbSkip())
   EndDo
EndIf

End Sequence                           
ELA->(DbGoTo(nRecno))
Return Nil

/*
Função     : PS400GerParc()
Parâmetros : cTipo - "A" para Aquisição e "V" para Venda, cProc - Processo, cDoc - Documento, cPrefixo - Prefixo, cFornece - Fornecedor, cLoja - Loja, nOpcParc - Operação a ser realizada 
Retorno    : Nil
Objetivos  : Gerar automaticamente as parcelas de câmbio a partir dos títulos que foram gerados no SIGAFIN
Autor      : Rafael Ramos Capuano - Adaptado do original - RS401GerPagto() - Allan Oliveira Monteiro - AOM
Data/Hora  : 01/07/2013
Revisao    : 
Obs.       :
*/
*------------------------*
Function PS400GerParc(cTipo,cProc,cDoc,cPrefixo,cEmpr,cLoja,nOpcParc,lInteg)
*------------------------*
Local aOrd          := SaveOrd({"EEQ","SE1","SE2","ELA","SF1","SF2","SD1","SD2","SE5"})
Local aEEQAuto      := {}
Local nPrxParc      := 0
Local nTotItens     := 0
Local nVlItens      := 0
Local nVlTit        := 0
Local nVlTitEst     := 0
//Local nVlPed        := 0
Local cChaveSD1     := "" 
Local cChaveSE2     := ""
Local cMsg          := ""
Local cMoeda        := ""
Local oRateio,oRateioEst
Local lSeek         := .F.       
Local lRet          := .T.
Default cTipo       := ""
Default cProc       := ""
Default cDoc        := ""
Default cPrefixo    := ""
Default cEmpr       := ""
Default cLoja       := ""
Default nOpcParc    := 0
Default lInteg      := .F.
Private lMsErroAuto := .F.
Private cFieldE2    := EasyGParam("MV_ESS0011",,"")
Private cFldE2      := ""

If Type("cAviso") == "U"
   cAviso := AvObject():New()
EndIf

Begin Sequence

// MPG - 28/02/2018
If !Empty(cFieldE2)
    // Se o campo cFieldE2 não existir no dicionário, mostra a mensagem de erro.
    If !AVSX3(cFieldE2, 0, "", .T.)
        EasyHelp("Conteudo inválido configurado para o parâmetro MV_ESS0011")
        Break
    Else
        cFldE2 := &(AVSX3(cFieldE2, 17) + "->" + cFieldE2)
    EndIf
EndIf

If nOpcParc == 0
   Break
EndIf

//Carrega o valor somente dos serviços
ELA->(DbSetOrder(4)) //ELA_FILIAL + ELA_TPPROC + ELA_NRINVO + ELA_PROCES
If ELA->(DbSeek(xFilial("ELA")+AvKey(cTipo,"ELA_TPPROC")+AvKey(cProc,"ELA_PROCES")+AvKey(cDoc,"ELA_NRINVO")))
   nVlItens := ELA->ELA_VLCAMB
   cMoeda   := AllTrim(ELA->ELA_MOEDA)
Else
   If !lInteg
      cAviso:Error("Não foram encontradas " + If(cTipo=="A","invoices", "faturas") + " para o processo " + AllTrim(cProc) + ".")
   EndIf
   lRet := .F.
   Break  
EndIf      

SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

If cTipo == "A" .And. SF1->(DbSeek(xFilial("SF1")+AvKey(ELA->ELA_DOC,"F1_DOC")+AvKey(cPrefixo,"F1_SERIE")+AvKey(cEmpr,"F1_FORNECE")+AvKey(cLoja,"F1_LOJA")))
   //Verifica o valor total da nota que originou a invoice e a quantidade de itens
   cChaveSD1 := xFilial("SD1")+AvKey(cDoc,"D1_DOC")+AvKey(cPrefixo,"D1_SERIE")+AvKey(cEmpr,"D1_FORNECE")+AvKey(cLoja,"D1_LOJA")  
   SD1->(DbSetOrder(1))   //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
   SD1->(DbSeek(cChaveSD1))
   SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA                                                                                               
   cChaveSE2 := xFilial("SE2")+AvKey(cPrefixo,"E2_PREFIXO")+AvKey(SF1->F1_DUPL,"E2_NUM")
   If SE2->(DbSeek(cChaveSE2))                                         
      Do While SE2->(!EOF()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == cChaveSE2
	  
	     If SE2->E2_TIPO == MVNOTAFIS .And. AvKey(cEmpr,"E2_FORNECE") == SE2->E2_FORNECE .And. AvKey(cLoja,"E2_LOJA") == SE2->E2_LOJA .And. Left(EasyGParam("MV_SIMB"+Alltrim(Str(SE2->E2_MOEDA))),AvSX3("ELA_MOEDA",AV_TAMANHO)) == cMoeda  // AAF - 02/09/2015
			 //Do While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cChaveSD1
			 //Calcula o valor total do pedido de acordo com a moeda utilizada
			 //nVlPed += &("SD1->D1_CUSTO"+If(AllTrim(STR(SE2->E2_MOEDA))=="1","",AllTrim(STR(SE2->E2_MOEDA))))
			 nTotItens++
			 nVlTit += SE2->E2_VLCRUZ
       nVlTitEst += SE2->E2_VALOR
			 //SD1->(DbSkip())
		 EndIf
		 
         SE2->(DbSkip())
      EndDo
      /*RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC, este campo tem o intuito de separar o valor total de um título composto
      por serviços (NBS) e mercadorias (NCM)*/
      If EEQ->(FieldPos("EEQ_VLSISC")) > 0
         oRateio:= EasyRateio():New(nVlItens,nVlTit,nTotItens,AvSx3("EEQ_VLSISC",AV_DECIMAL)) 

         oRateioEst:= EasyRateio():New(nVlItens,nVlTitEst,nTotItens,AvSx3("EEQ_VLSISC",AV_DECIMAL)) 
      EndIf
      
      SE2->(DbSeek(cChaveSE2)) 
      Do While SE2->(!EOF()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == cChaveSE2
         If SE2->E2_TIPO == MVNOTAFIS .And. AvKey(cEmpr,"E2_FORNECE") == SE2->E2_FORNECE .And. AvKey(cLoja,"E2_LOJA") == SE2->E2_LOJA .And. Left(EasyGParam("MV_SIMB"+Alltrim(Str(SE2->E2_MOEDA))),AvSX3("ELA_MOEDA",AV_TAMANHO)) == cMoeda
            //Instancia classe que realiza a operação do rateio para considerar o valor dos títulos que correspondem a serviços
            aEEQAuto := {}
            If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
               EEQ->(DbSetOrder(4)) //EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC
               lOk := EEQ->(DbSeek(xFilial("EEQ")+AvKey(cDoc,"EEQ_NRINVO")+AvKey(cTipo+cProc,"EEQ_PREEMB")+RetAsc(SE2->E2_PARCELA,AVSX3("EEQ_PARC",AV_TAMANHO),.F.)))
            Else            
               EEQ->(DbSetOrder(15)) //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO+EEQ_PARC  // GFP - 26/05/2015
               lOk := EEQ->(DbSeek(xFilial("EEQ")+AvKey(cTipo,"EEQ_TPPROC")+AvKey(cProc,"EEQ_PROCES")+AvKey(cDoc,"EEQ_NRINVO")+RetAsc(SE2->E2_PARCELA,AVSX3("EEQ_PARC",AV_TAMANHO),.F.)))
            EndIf
            If lOk
               nOpcParc := ALTERAR
            Else
               nOpcParc := INCLUIR
            EndIf
            aAdd(aEEQAuto,{"EEQ_FILIAL"    , AvKey(xFilial("EEQ"),"EEQ_FILIAL")                , Nil })
            aAdd(aEEQAuto,{"EEQ_PREEMB"    , AvKey(cTipo + cProc,"EEQ_PREEMB")                 , Nil })
            aAdd(aEEQAuto,{"EEQ_EVENT"     , "001"                                             , Nil })
            //aAdd(aEEQAuto,{"EEQ_NRINVO"  , SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORMUL      , Nil })
            aAdd(aEEQAuto,{"EEQ_NRINVO"    , AvKey(cDoc,"ELA_NRINVO")                          , Nil })
            //aAdd(aEEQAuto,{"EEQ_PARC"      , If(nOpcParc == ALTERAR,EEQ->EEQ_PARC,StrZero(Asc(SE2->E2_PARCELA),AvSx3("EEQ_PARC",AV_TAMANHO))) , Nil })
            aAdd(aEEQAuto,{"EEQ_PARC"      , If(nOpcParc == ALTERAR,EEQ->EEQ_PARC,RetAsc(SE2->E2_PARCELA,AVSX3("EEQ_PARC",AV_TAMANHO),.F.)) , Nil })
            aAdd(aEEQAuto,{"EEQ_VCT"       , SE2->E2_VENCREA                                   , Nil })
            aAdd(aEEQAuto,{"EEQ_MOEDA"     , Left(EasyGParam("MV_SIMB"+Alltrim(Str(SE2->E2_MOEDA))),AvSX3("EEQ_MOEDA",AV_TAMANHO)) , Nil })
            aAdd(aEEQAuto,{"EEQ_VL"        , /*SE2->E2_VALOR*/oRateioEst:GetItemRateio(SE2->E2_VALOR), Nil }) //LRS - 25/08/2017
            //O campo EEQ_VLSISC irá gatilhar o valor para EEQ_VL apenas quando este estiver vazio, neste caso, o gatilho não será executado, porque
            //o EEQ_VL pode ser maior devido ao valor contido no título que não se refere a serviços
            //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
            If EEQ->(FieldPos("EEQ_VLSISC")) > 0
               aAdd(aEEQAuto,{"EEQ_VLSISC"    , oRateio:GetItemRateio(SE2->E2_VLCRUZ)             , Nil })
            EndIf
            aAdd(aEEQAuto,{"EEQ_TPPROC"    , cTipo                                             , Nil })
            aAdd(aEEQAuto,{"EEQ_PROCES"    , cProc                                             , Nil })
            aAdd(aEEQAuto,{"EEQ_EMISSA"    , SE2->E2_EMISSAO                                   , Nil })
            aAdd(aEEQAuto,{"EEQ_DESCONT"   , SE2->E2_DESCONT                                   , Nil })
            aAdd(aEEQAuto,{"EEQ_FASE"      , "4"                                               , Nil })
            //Aquisiçao == "A" == "P" -> Cambio a Pagar, Venda == "V" == "R" -> Cambio a Receber
            aAdd(aEEQAuto,{"EEQ_TIPO"      , "P"                                               , Nil })
            If EEQ->(FieldPos("EEQ_PARVIN")) > 0 .And. nOpcParc == INCLUIR
               aAdd(aEEQAuto,{"EEQ_PARVIN" , If(nOpcParc == ALTERAR,EEQ->EEQ_PARC,RetAsc(SE2->E2_PARCELA,AVSX3("EEQ_PARC",AV_TAMANHO),.F.)) , Nil })
            EndIf
            //Na Aquisição será necessario gravar dados do Fornecedor
            aAdd(aEEQAuto,{"EEQ_FORN"   , SE2->E2_FORNECE                                      , Nil })
            aAdd(aEEQAuto,{"EEQ_FOLOJA" , SE2->E2_LOJA                                         , Nil })
            /*If EEQ->(FieldPos("EEQ_HVCT")) > 0
               aAdd(aEEQAuto,{"EEQ_HVCT"   ,                                                   , Nil })
            EndIf*/
            aAdd(aEEQAuto,{"EEQ_SOURCE"    , "SIGAFIN"                                         , Nil })
            aAdd(aEEQAuto,{"EEQ_TP_CON"    , "4"                                               , Nil })
            aAdd(aEEQAuto,{"EEQ_FINNUM"    , SE2->E2_NUM                                       , Nil })
            aAdd(aEEQAuto,{"EEQ_PREFIX"    , SE2->E2_PREFIXO                                   , Nil })
            //Se o título da parcela a ser incluída já estiver baixado, realizará duas chamadas de MsExecAuto()
            If nOpcParc <> INCLUIR
               SE5->(DbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
               lSeek :=  !Empty(SE2->E2_BAIXA) .And. SE5->(AvSeekLast(xFilial("SE5")+AvKey(SE2->E2_PREFIXO,"E5_PREFIXO")+AvKey(SE2->E2_NUM,"E5_NUMERO")+AvKey(SE2->E2_PARCELA,"E5_PARCELA")+AvKey(SE2->E2_TIPO,"E5_TIPO");
               +AvKey(SE2->E2_FORNECE,"E5_CLIFOR")+AvKey(SE2->E2_LOJA,"E5_LOJA")))
               aAdd(aEEQAuto,{"EEQ_DTCE"    , If(lSeek,SE5->E5_DTDISPO, SE2->E2_BAIXA)                , Nil })
               If lSeek .And. SE5->E5_MOEDA <> "01" //wfs - baixa com movimento no exterior
                  aAdd(aEEQAuto, {"EEQ_BCOEXT", SE5->E5_BANCO  , Nil })
                  aAdd(aEEQAuto, {"EEQ_AGCEXT", SE5->E5_AGENCIA, Nil })
                  aAdd(aEEQAuto, {"EEQ_CNTEXT", SE5->E5_CONTA  , Nil })
                  AAdd(aEEQAuto, {"EEQ_MODAL" , "2"            , Nil })
               Else
                  aAdd(aEEQAuto,{"EEQ_BANC"    , If(lSeek,SE5->E5_BANCO,"")                                , Nil })
                  aAdd(aEEQAuto,{"EEQ_AGEN"    , If(lSeek,SE5->E5_AGENCIA,"")                              , Nil })
                  aAdd(aEEQAuto,{"EEQ_NCON"    , If(lSeek,SE5->E5_CONTA,"")                                , Nil })
                  aAdd(aEEQAuto,{"EEQ_PGT"     , SE2->E2_BAIXA                                             , Nil })
               EndIf

               aAdd(aEEQAuto,{"EEQ_TX"      , If(lSeek .And. !Empty(SE5->E5_TXMOEDA),SE5->E5_TXMOEDA,1) , Nil })
               aAdd(aEEQAuto,{"EEQ_NROP"    , If(lSeek,If(!Empty(cFieldE2), cFldE2 ,""),"")     , Nil })
            EndIf
            /*Último parâmetro .F. indica que a origem vem do SIGAFIN, sendo assim ,ao excluir as parcelas, o sistema não irá procurá-las no SIGAFIN*/         
            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aEEQAuto,nOpcParc,cTipo,.F.)
            If lMsErroAuto
               /*Casos em que a função NomeAutoLog() não retornava a mensagem de erro após uma tentativa inválida de inclusão*/ 
               If ValType(cMsg := NomeAutoLog()) == "U"   
                  cMsg := "A integração das parcelas de câmbio do processo " + AllTrim(cProc) + " não foi concluída com êxito."        
               Else
                  cMsg := MemoRead(NomeAutoLog())
                  FErase(NomeAutoLog())
               EndIf
               If !lInteg
                  cAviso:Error("Processo: " + AllTrim(cProc) + " " + cMsg)
               EndIf
               lRet := .F.
               Break
            ElseIf nOpcParc == INCLUIR .And. !Empty(SE2->E2_BAIXA)               		
               //Verifica se o título da parcela incluída já foi baixado
               SE5->(DbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
               lSeek := SE5->(AvSeekLast(xFilial("SE5")+AvKey(SE2->E2_PREFIXO,"E5_PREFIXO")+AvKey(SE2->E2_NUM,"E5_NUMERO")+AvKey(SE2->E2_PARCELA,"E5_PARCELA")+AvKey(SE2->E2_TIPO,"E5_TIPO");
               +AvKey(SE2->E2_FORNECE,"E5_CLIFOR")+AvKey(SE2->E2_LOJA,"E5_LOJA")))

               If lSeek .And. SE5->E5_MOEDA <> "01" //wfs - baixa com movimento no exterior
                  aAdd(aEEQAuto, {"EEQ_BCOEXT", SE5->E5_BANCO  , Nil })
                  aAdd(aEEQAuto, {"EEQ_AGCEXT", SE5->E5_AGENCIA, Nil })
                  aAdd(aEEQAuto, {"EEQ_CNTEXT", SE5->E5_CONTA  , Nil })
                  AAdd(aEEQAuto, {"EEQ_MODAL" , "2"            , Nil })
               Else
                  aAdd(aEEQAuto,{"EEQ_BANC"    , If(lSeek,SE5->E5_BANCO,"")                                , Nil })
                  aAdd(aEEQAuto,{"EEQ_AGEN"    , If(lSeek,SE5->E5_AGENCIA,"")                              , Nil })
                  aAdd(aEEQAuto,{"EEQ_NCON"    , If(lSeek,SE5->E5_CONTA,"")                                , Nil })
                  aAdd(aEEQAuto,{"EEQ_PGT"     , SE2->E2_BAIXA                                             , Nil })
               EndIf

               aAdd(aEEQAuto,{"EEQ_DTCE"    , If(lSeek,SE5->E5_DTDISPO,"")                              , Nil })
               aAdd(aEEQAuto,{"EEQ_TX"      , If(lSeek .And. !Empty(SE5->E5_TXMOEDA),SE5->E5_TXMOEDA,1) , Nil })
               aAdd(aEEQAuto,{"EEQ_NROP"    , If(lSeek,If(!Empty(cFieldE2), cFldE2 ,""),"")     , Nil })
               /*Último parâmetro .F. indica que a origem vem do SIGAFIN, sendo assim ,ao excluir as parcelas, o sistema não irá procurá-las no SIGAFIN*/         
               MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aEEQAuto,ALTERAR,cTipo,.F.)
               If lMsErroAuto
                  /*Casos em que a função NomeAutoLog() não retornava a mensagem de erro após uma tentativa inválida de inclusão*/ 
                  If ValType(cMsg := NomeAutoLog()) == "U"   
                     cMsg := "A integração das parcelas de câmbio do processo " + AllTrim(cProc) + " não foi concluída com êxito."        
                  Else
                     cMsg := MemoRead(NomeAutoLog())
                     FErase(NomeAutoLog())
                  EndIf
                  If !lInteg
                     cAviso:Error("Processo: " + AllTrim(cProc) + " " + cMsg)
                  EndIf
                  lRet := .F.
                  Break
               EndIf
            EndIf
         EndIf
         SE2->(DbSkip())
      EndDo
   EndIf
EndIf
End Sequence
RestOrd(aOrd,.T.)

Return lRet

/*
Função     : PS400DelParc()
Parâmetros : cTipo - "A" para Aquisição e "V" para Venda, cProc - Processo, cDoc - Invoice 
Retorno    : Nil
Objetivos  : Excluir automaticamente as parcelas de câmbio devido a títulos excluídos do SIGAFIN
Autor      : Rafael Ramos Capuano
Data/Hora  : 01/07/2013
Revisao    : 
Obs.       :
*/

Function PS400DelParc(cTipo,cProc,cDoc)
Local aOrd     := SaveOrd({"EEQ"})
Local cChave   := ""
Local aEEQAuto := {}
Local lRet     := .T.
Default cTipo  := ""
Default cProc  := ""
Default cDoc   := ""

EEQ->(DbSetOrder(4)) //EEQ_FILIAL + EEQ_NRINVO + EEQ_PREEMB + EEQ_PARC
cChave := xFilial("EEQ")+AvKey(cDoc,"EEQ_NRINVO")+AvKey(cTipo+cProc,"EEQ_PREEMB")
Begin Sequence

If EEQ->(DbSeek(cChave))
   Do While EEQ->(!Eof()) .And. EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB) == cChave
      aAdd(aEEQAuto,{"EEQ_FILIAL"    , EEQ->EEQ_FILIAL        , Nil })
      aAdd(aEEQAuto,{"EEQ_NRINVO"    , EEQ->EEQ_NRINVO        , Nil })
      aAdd(aEEQAuto,{"EEQ_PREEMB"    , EEQ->EEQ_PREEMB        , Nil })
      aAdd(aEEQAuto,{"EEQ_PARC"      , EEQ->EEQ_PARC          , Nil })
      aAdd(aEEQAuto,{"EEQ_FASE"      , EEQ->EEQ_FASE          , Nil })
      /*Último parâmetro .F. indica que a origem vem do SIGAFIN, sendo assim ,ao excluir as parcelas, o sistema não irá procurá-las no SIGAFIN*/         
      MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aEEQAuto,EXCLUIR,cTipo,.F.)
      If lMsErroAuto
         /*Casos em que a função NomeAutoLog() não retornava a mensagem de erro após uma tentativa inválida de inclusão*/ 
         If ValType(cMsg := NomeAutoLog()) == "U"   
            cMsg := "A atualização das parcelas de câmbio do processo " + AllTrim(cProc) + " para o SIGAESS não foi concluída com êxito."        
         Else
            cMsg := MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
         EndIf
         lRet := .F.
         Break
      EndIf      
      EEQ->(DbSkip())
   EndDo
EndIf

End Sequence
RestOrd(aOrd,.T.)
Return lRet

/*
Programa   : PS400CallFat()
Objetivo   : Atualizar as invoices/faturas geradas pelo SIGACOM ou SIGAFAT
Retorno    : lRet
Autor      : Rafael Ramos Capuano
Data       : 18/07/2013 - 16:27
Revisão    : Set/2017 - Modificada a forma de filtrar os registros da tabela, corrigindo bug na aplicação de filtros que usam campos
             do tipo data e filtros relacionais. 
*/   

Function PS400CallFat()
Local lRet := .T.
Local lUserFiltro  := .F.
Local cFiltroDefault := ""
Local cFiltro        := ""
Local cMsg           := ""
Local nTotFiltro     := 0          
Local nTotProc       := 0
Local nI             := 2 
Local aOrd           := SaveOrd({"EJW"}) 
Private oProgress    := EasyProgress():New()

//RRC - 17/05/2013 - Verifica se existe um filtro adicionado pelo usuário na tela em conjunto com o filtro do programa
If Type("oBrowsePed") == "O" .And. Type("cPed") == "C"
   If (nTotFiltro := Len(oBrowsePed:oData:aFiltrate)) > 0  //Para o ESSPS400() sempre haverá o filtro por Tipo de Processo
      cFiltroDefault := oBrowsePed:oData:aFiltrate[1][2] //recebe o conteúdo do filtro default por Tipo de Processo definido pelo programa
      Do While nI <= nTotFiltro .And. !lUserFiltro
         //Verifica se existe um filtro de usuário ativo
         If !(cFiltroDefault == oBrowsePed:oData:aFiltrate[nI][2])
            lUserFiltro := .T.
         EndIf
         nI++ 
      EndDo
      /* comentado por WFS - set/2017 - adequação para uso de filtros com campo data e filtros de relacionamento
      cFiltro := oBrowsePed:oData:aFiltrate[nTotFiltro][2] //Recebe o conteúdo do filtro ativo no browse  

      EJW->(dbSetFilter(&("{||"+cFiltro+"}"),cFiltro))
      EJW->(DbSetOrder(1)) //EJW_FILIAL + EJW_TPPROC + EJW_PROCES
      EJW->(DbSeek(xFilial("EJW")+cPed))
      Do While EJW->(!Eof())
         nTotProc++
         EJW->(DbSkip())
      EndDo*/
      cQuery:= MontaQuery(oBrowsePed) //wfs 18/09/2017 - Retorna a query com os filtros realizados
      //contagem de registros
      nTotProc:= EasyQryCount(cQuery)
      //Filtro dos registros que serão atualizados
      EasyQry(cQuery, "TMPEJW")
      TcSetField("TMPEJW", "RECNO", "N", 8, 0)
   Else
      nTotProc := EJW->(EasyRecCount())
   EndIf
        
   If lUserFiltro
      If nTotProc > 1
         cMsg := "Foi definido um filtro para os processos. Deseja buscar as " + If(cPed=="A","invoices com origem do SIGACOM","faturas com origem do SIGAFAT") + " para os " + AllTrim(Str(nTotProc)) + " processos filtrados?"
      Else
         cMsg := "Foi definido um filtro para os processos. Deseja buscar a " + If(cPed=="A","invoice com origem do SIGACOM","fatura com origem do SIGAFAT") + " para o processo filtrado?"
      EndIf 
   Else
      If nTotProc > 1
         cMsg := "Deseja buscar as " + If(cPed=="A","invoices com origem do SIGACOM","faturas com origem do SIGAFAT") + " para os " + AllTrim(Str(nTotProc)) + " processos?"
      Else
         cMsg := "Deseja buscar a " + If(cPed=="A","invoice com origem do SIGACOM","fatura com origem do SIGAFAT") + " para o processo?"
      EndIf
   EndIf

   If nTotProc > 0 .And. MsgYesNo(cMsg,"Aviso")  
      oProgress:SetProcess({|| PS400Fat(nTotProc)},'Processando os dados...') 
      oProgress:Init()
   EndIf
   
   EJW->(DbClearFilter())

   If Select("TMPEJW") > 0
      TMPEJW->(DBCloseArea())
   EndIf

EndIf
RestOrd(aOrd,.T.)
Return lRet

/*
Programa   : PS400Fat()
Objetivo   : Atualizar as invoices/faturas geradas pelo SIGACOM ou SIGAFAT
Retorno    : lRet
Autor      : Rafael Ramos Capuano
Data       : 18/07/2013 - 13:37
*/   

Function PS400Fat(nTotProc)
Local lRet   := .T.
Local aOrd   := SaveOrd({"EJW"})
Private cAviso := AvObject():New()
Default nTotProc  := 0

Begin Sequence
If Type("cPed") == "C"
   EJW->(DbSetOrder(1)) //EJW_FILIAL + EJW_TPPROC + EJW_PROCES
   EJW->(DbSeek(xFilial("EJW")+cPed))
   If nTotProc > 0                                                 
      oProgress:SetRegua(nTotProc)
      //Do While EJW->(!Eof()) //comentado por wfs em 18/08/17
      TMPEJW->(DBGoTop())
      Do While TMPEJW->(!Eof())
         
         //wfs - posicionamento da tabela EJW pelos registros filtrados com a query
         EJW->(DBGoTo(TMPEJW->RECNO))
         
         PS400BuscFat(EJW->EJW_TPPROC,EJW->EJW_ORIGEM,EJW->EJW_PROCES)
         If !oProgress:IncRegua()
            Break
         EndIf
         //EJW->(DbSkip()) //comentado por wfs em 18/08/17
         TMPEJW->(DBSkip())
      EndDo
   EndIf
   cAviso:ShowErrors()
   //MsgInfo("A integração das " + If(cPed=="A","Invoices", "Faturas") + " para o SIGAESS foi finalizada.","Aviso")
   EasyHelp("A integração das " + If(cPed=="A","Invoices", "Faturas") + " para o SIGAESS foi finalizada.","Aviso")  //SSS - REQ. 8 13/06/2014
   
EndIf   
End Sequence

RestOrd(aOrd,.T.)
Return lRet

/*
Programa   : PS400SXB()
Objetivo   : Seleciona a consulta padrão caso for aquisição ou venda.
Retorno    : cRetorno
Autor      : Fabio Satoru Yamamoto
Data       : 21/10/2013
*/   
Function PS400SXB()
Local cRetorno := ""
Local  cTipo   := cPed

Do Case
   Case cTipo == "A"//Aquisição
      cRetorno:= ConPad1(,,,'IMP',,)
   Case cTipo == "V"//Venda
      cRetorno:= ConPad1(,,,'EXP3',,)
End Case

Return cRetorno

/*
Programa   : PS400SXBRET()
Objetivo   : Retorno utilizado pelo SXB - EJW4
Retorno    : cRet
Autor      : Fabio Satoru Yamamoto
Data       : 21/10/2013
*/   
Function PS400SXBRET(cCampo)
Local cRet  := ""
Local cTipo := cPed

If cTipo == "A"
   Do Case
      Case cCampo == "EJW_CODEMP"
         cRet := SA1->A1_COD
      Case cCampo == "EJW_LOJEMP"
         cRet := SA1->A1_LOJA
      Case cCampo == "EJW_NOME"
         cRet := SA1->A1_NOME
      Case cCampo == "EJW_CGC"
         cRet := SA1->A1_CGC
   End Case

ElseIf cTipo == "V"
   Do Case
      Case cCampo == "EJW_CODEMP"
         cRet := SA2->A2_COD
      Case cCampo == "EJW_LOJEMP"
         cRet := SA2->A2_LOJA
      Case cCampo == "EJW_NOME"
         cRet := SA2->A2_NOME
      Case cCampo == "EJW_CGC"
         cRet := SA2->A2_CGC
   End Case

End If
Return cRet

/*
Programa   : PS400INIBRW()
Objetivo   : Seleciona a consulta padrão caso for aquisição ou venda.
Retorno    : cRetorno
Autor      : Fabio Satoru Yamamoto
Data       : 21/10/2013
*/   
Function PS400INIBRW(cCampo)
Local cRetorno := ""
Local aOrd     := SaveOrd({"SA1","SA2"})
Local cTipo    := If (Type("cPed") == "U","",cPed) //MCF - 13/01/2015

Do Case
   Case cCampo == "EJW_DSCEMP"
      If cTipo == "A"//Aquisição
         cRetorno := Posicione("SA1",1,xFilial("SA1")+EJW->EJW_CODEMP+EJW->EJW_LOJEMP,"A1_NOME")

      ElseIf cTipo == "V"//Venda
         cRetorno := Posicione("SA2",1,xFilial("SA2")+EJW->EJW_CODEMP+EJW->EJW_LOJEMP,"A2_NOME")         
      End If

   Case cCampo == "EJW_SLDINV"
      If cTipo == "A"//Aquisição
         cRetorno := PS400SalInv("A",EJW->EJW_PROCES)
      ElseIf cTipo == "V"//Venda
         cRetorno := PS400SalInv("V",EJW->EJW_PROCES)
      End If

End Case      
RestOrd(aOrd,.T.)

Return cRetorno

/*
Programa   : PS400LinePre()
Objetivo   : Chamar a função PS400Trig() para atualizar o valor dos campos EJW_VL_MOE e EJW_VL_REA caso delete ou recupera um item deletado
Parametros : 
Retorno    : lRet
Autor      : Rafael Ramos Capuano
Data/Hora  : 28/10/2013 09:03 
Revisao    : 
*/
Function PS400LinePre(oGrid,nLine,cAction)
Local oModel    := FWModelActive()
Local oModelEJW := oModel:GetModel("EJWMASTER")
Local lRet      := .T.
Local aOrd      := SaveOrd({"EJZ","EL4","EL8"})

Begin Sequence

Do Case
   Case oGrid:cId == "EJXDETAIL"
      /*Valida pelo status do Processo (se tem ou não RAS/RVS) apenas quando o parâmetro MV_ESS0003 estiver (Geração automática de RAS/RVS) estiver desabilitado,
      já que neste caso, a ideia é excluir de lá também, mas para isso, não pode ter gerado lote de RAS/RVS*/
      If cAction == "DELETE"
         If !Empty(oGrid:GetValue("EJX_STTPED")) .And. oGrid:GetValue("EJX_STTPED") <> "1" .And. (!lIntPedServ .Or. oGrid:GetValue("EJX_STTPED") == "4")
            lRet := .F.
            EasyHelp("Este serviço não pode ser excluído pois apresenta status '" + BSCXBOX('EJX_STTPED',oGrid:GetValue("EJX_STTPED")) + "'","Aviso")
            Break
         Else
            EJZ->(DbSetOrder(3)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES+EJZ_SEQPRC
            EL4->(DbSetOrder(1)) //EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG+EL4_SQEVIT
            EL8->(DbSetOrder(2)) //EL8_FILIAL+EL8_IDLOTE
            If Type("cPed") == "C" .And. EJZ->(DbSeek(xFilial("EJZ")+cPed+oModelEJW:GetValue("EJW_PROCES")+oGrid:GetValue("EJX_SEQPRC"))) 
               //RRC - 28/11/2013 - Alteração para validar apenas se o lote foi cancelado
               If EL4->(DbSeek(xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG))
                  Do While EL4->(!Eof()) .And. EL4->(EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG) == xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG
                     If EL8->(DbSeek(xFilial("EL8")+EL4->EL4_IDLOTE)) .And. EL8->EL8_STATUS <> "C" .AND. !(EL8->EL8_STATUS == "P" .AND. Empty(EL4->EL4_NROREG)) //AAF 11/01/2017 - Permite estorno dos casos em que foi processado, mas não foi registrado no Siscoserv.
                        EasyHelp("Este serviço não pode ser excluído pois está vinculado a um lote não cancelado.","Aviso")
                        lRet := .F.
                        Break
                     EndIf
                     EL4->(DbSkip())   
                  EndDo
               EndIf     
            EndIf   
         EndIf  
   
         //RRC - 10/09/2013 - Verifica se possui invoice, neste caso, não poderá excluir
         If lRet .And. Type("cPed") == "C"
            If !PS400ItemInv(oGrid:GetValue("EJX_SEQPRC"))
               lRet := .F.
               Break
            EndIf
         EndIf
   
         If lRet .And. cAction == "DELETE"  
            PS400Trig(0,oGrid:GetValue("EJX_VL_MOE"),"EJW_VL_MOE")
            PS400Trig(0,oGrid:GetValue("EJX_VL_REA"),"EJW_VL_REA") 
         EndIf
      ElseIf cAction == "UNDELETE"   
         PS400Trig(oGrid:GetValue("EJX_VL_MOE"),0,"EJW_VL_MOE")
         PS400Trig(oGrid:GetValue("EJX_VL_REA"),0,"EJW_VL_REA")
      EndIf

   Case oGrid:cId == "EL2DETAIL" .And. cAction == "DELETE"
      If EasyGParam("MV_ESS0027",,9) >= 10 .AND. !IsInCallStack("PS400ViewAtu") .AND. !lPS400Auto
         lRet := .F.
         EasyHelp("Os documentos devem ser manipulados através do campo Mov. Temp. presente nos itens do processo","Aviso")
      Else
         If oGrid:GetValue("EL2_STTSIS") <> "1"
            lRet := .F.
            cMsg := "Este documento não pode ser excluído pois apresenta:"
            If oGrid:GetValue("EL2_STTSIS") <> "1" .AND. (!lIntPedServ .Or. oGrid:GetValue("EL2_STTSIS") == "3")
               cMsg += " Status '" + BSCXBOX('EL2_STTSIS',oGrid:GetValue("EL2_STTSIS")) + "'."
            EndIf
            EasyHelp(cMsg,"Aviso")
         EndIf
      EndIf
      
   Case oGrid:cId == "EL2DETAIL" .And. cAction == "UNDELETE"
      If EasyGParam("MV_ESS0027",,9) >= 10
         EasyHelp("Manutenção não permitida. Para utilização destes campos, configure o parâmetro 'MV_ESS0027' corretamente.","Aviso")
         lRet := .F.
      EndIf
     
EndCase
End Sequence
RestOrd(aOrd,.T.)
Return lRet

/*
Programa   : PS400SalInv
Objetivo   : Calcular o saldo restante no processo.
Parâmetros : cTipo - Tipo de Processo; cPed - Processo
Autor      : Fabio Satoru Yamamoto
Data       : 03/12/2013
*/
Function PS400SalInv(cTipo, cPed)
Local aOrd    := SaveOrd({"EJW" ,"EJX"})
Local nSaldo  := 0
Local nTotal  := 0

Begin Sequence
If ValType(cTipo) <> "U" .And. ValType(cPed) <> "U"
   EJX->(DbSetOrder(1))
   If EJX->(DbSeek(xFilial("EJX") + AvKey(cTipo,"EJX_TPPROC") + AvKey(cPed,"EJX_PROCES")))
      Do While EJX->(!EOF()) .And. xFilial("EJX") == EJX->EJX_FILIAL .And. AvKey(cTipo,"EJX_TPPROC") == EJX->EJX_TPPROC .And. AvKey(cPed,"EJX_PROCES") == EJX->EJX_PROCES
         nSaldo += EJX->EJX_SLDINV
         nTotal += EJX->EJX_VL_MOE
         EJX->(DbSkip())
      EndDo
   EndIf
   
EndIf
End Sequence
RestOrd(aOrd,.T.)

Return nSaldo

/*
Programa   : PSSelecData()
Objetivo   : Tela de seleção de processos para ajuste de data de previsao
Retorno    : Nil
Autores    : Fabio Satoru Yamamoto - FSY
Data/Hora  : 16/12/2013
*/
Function PSSelecData()
Local oBrowse
Local nPos
Local bOk       :={||PSSetData(aItem), oDlg:End()}
Local bCancel   :={|| oDlg:End()}
Local bMarca    :={|| If((nPos := aScan(aItem,TEMP->(Recno())))==0,Aadd(aItem,TEMP->(Recno())),(aDel(aItem,nPos),aSize(aItem,Len(aItem)-1)))}
Local bMarcaTds :={|oDlg| If(!Empty(aItem),aItem:={},aItem := GetAllItens()),oDlg:Refresh(.T.)}
Local aOrd      := SaveOrd({"EJW","EJX"}) //Guarda índices das tabelas utilizadas
Local aItem     := {}
Local aInd      := {"EJX_FILIAL+EJX_TPPROC+EJX_PROCES+EJX_SEQPRC"}
Local cQuery    := ""
Local cTipo     := cPed
Local bCode     := {||Posicione('SB1',1,xFilial('SB1')+AvKey(TEMP->EJX_ITEM,'B1_COD'),'B1_DESC')}

EasyHelp("Esta rotina ira atualizar a data de previsão do(s) serviço(s) em aberto. A data de prev. fim (EJX_DTFIM) não deve ser menor que a data de prev. inicio (EJX_DTPRIN) e a data fim (EJX_DTFIM) não preenchida.","Aviso")

If Pergunte("ESSPS003",.T.)

   If Select("TEMP") > 0 
      TEMP->(DbCloseArea())
   EndIf
   
   cQuery += "Select * "
   cQuery += "From "+RetSqlName("EJW")+" EJW "  
   cQuery += "Inner Join "+RetSqlName("EJX")+" On (EJW_PROCES = EJX_PROCES) "
   cQuery += "Where EJW.D_E_L_E_T_ = '' AND EJW.EJW_FILIAL = '"+xFilial("EJW")+"' AND " + "EJW.EJW_TPPROC = '"+cTipo+"' "
   cQuery += "AND EJX_FILIAL = '"+xFilial("EJX")+"' AND EJX_DTFIM = ' ' " 
   cQuery += "AND (EJX_DTPRIN >= " + DtoS(MV_PAR03) +" Or EJX_DTPRIN = ' ') "
   If !Empty(MV_PAR01)
      cQuery += "AND EJX_DTPRFI >= " + DtoS(MV_PAR01) +" "
   End If 
   If !Empty(MV_PAR02)   
      cQuery += "AND EJX_DTPRFI <= " + DtoS(MV_PAR02) +" "
   End If

   EasyWkQuery(cQuery,"TEMP", aInd)
   If !TEMP->(EOF().And.BOF())
      DEFINE MSDIALOG oDlg TITLE "Seleção de Processos de Data Previsão" FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL              
      
         DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TEMP" OF oDlg
            ADD MARKCOLUMN oColumn DATA {||If(aScan(aItem,TEMP->(Recno()))==0,'LBNO','LBOK')} DOUBLECLICK bMarca HEADERCLICK bMarcaTds   OF oBrowse
            ADD COLUMN     oColumn DATA &("{ || EJW_PROCES  }") TITLE AvSx3("EJW_PROCES", AV_TITULO) SIZE AvSx3("EJW_PROCES", AV_TAMANHO) OF oBrowse
            ADD COLUMN     oColumn DATA &("{ || EJX_SEQPRC  }") TITLE AvSx3("EJX_SEQPRC", AV_TITULO) SIZE AvSx3("EJX_SEQPRC", AV_TAMANHO) OF oBrowse
            ADD COLUMN     oColumn DATA &("{ || EJX_ITEM    }") TITLE AvSx3("EJX_ITEM"  , AV_TITULO) SIZE AvSx3("EJX_ITEM"  , AV_TAMANHO) OF oBrowse
            ADD COLUMN     oColumn DATA  (bCode               ) TITLE AvSx3("EJX_DSCITE", AV_TITULO) SIZE AvSx3("EJX_DSCITE", AV_TAMANHO) OF oBrowse
            ADD COLUMN     oColumn DATA &("{ || EJX_DTPRIN  }") TITLE AvSx3("EJX_DTPRIN", AV_TITULO) SIZE AvSx3("EJX_DTPRIN", AV_TAMANHO) OF oBrowse
            ADD COLUMN     oColumn DATA &("{ || EJX_DTPRFI  }") TITLE AvSx3("EJX_DTPRFI", AV_TITULO) SIZE AvSx3("EJX_DTPRFI", AV_TAMANHO) OF oBrowse
           
           //bAction:= {|oSeek| Ps400Seek(cTpReg, AllTrim(Upper(oSeek:cSeek)),1,oBrowse)}
           aOrder:= {{"Processo + Seq. Processo", {{"", "C", TamSx3("EJX_PROCES")[1], 0, "Processo",,},{"", "C", TamSx3("EJX_SEQPRC")[1], 0, "Seq. Processo",,}}, 1}} 
           oBrowse:SetSeek(/*bAction*/,aOrder) //MCF - 27/11/2015
              
           ACTIVATE FWBROWSE oBrowse
	       
	       If ValType(oBrowse:oBrowseUI:oFWSeek) == "O"    //verifica se é objeto
              //oBrowse:oFWSeek:aDefaultOrder := {} //Limpa o objeto mascara da pesquisa
              //oBrowse:oFWSeek:aOrder := {"Processo+Seq. Processo"} //Vetor da mascara
              //oBrowse:oFWSeek:aDefaultOrder := {{"EJX_FILIAL+EJX_TPPROC+EJX_PROCES+EJX_SEQPRC"}} //Chave para a pesquisa
              oBrowse:oBrowseUI:oFWSeek:SetAction({|cSeek,nOrder| Ps400Seek(cTipo, AllTrim(Upper(cSeek)),nOrder,oBrowse)}) //Entra na função quando clicar em pesquisar
              oBrowse:Refresh()
          EndIf
           
	   oDlg:lMaximized := .T.
      ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) CENTERED
       
   Else
      EasyHelp("Não foram encontrados Processos para os dados informados.","Aviso")
   EndIf
   TEMP->(DbCloseArea())
End If

RestOrd(aOrd,.T.)
Return Nil

/*
Programa   : PSSetData()
Objetivo   : Efetua a gravação da data de previsão nova.
Parâmetros : aItem - vetor contendo o recno da tabela temporaria
Retorno    : Nil
Autores    : Fabio Satoru Yamamoto - FSY
Data/Hora  : 17/12/2013
*/
Function PSSetData(aItem)
Local nCont 
Local nAlterado   := 0
Local aOrd        := SaveOrd({"EJW", "EJX"}) 
Private oProgress := EasyProgress():New()

If !Empty(aItem) .And. MsgYesNo("Deseja realmente alterar a(s) data(s) de previsão ?")
   Begin Sequence
   TEMP->(DbGoTop())
   For nCont := 1 To Len(aItem)   
      TEMP->(DbGoTo(aItem[nCont]))
      EJX->(DbSetOrder(1))//EJX_FILIAL+EJX_TPPROC+EJX_PROCES+EJX_SEQPRC
      If EJX->(dbSeek(xFilial("EJX")+TEMP->EJX_TPPROC+TEMP->EJX_PROCES+TEMP->EJX_SEQPRC))
         EJX->(dbRLock())
         EJX->EJX_DTPRFI := MV_PAR03
         EJX->(dbRUnLock())
         nAlterado += 1
      End If 
   Next
   Easyhelp ("Números de registro(s) alterado(s) com sucesso: " + Alltrim (Str(nAlterado)),"Aviso" )
   
   If lIntPedServ//Integração entre processo e registro.
      oProgress:SetProcess({|| PS401AtuReg(aItem)},'Processando os dados...') 
      oProgress:Init()
   End If
   
   End Sequence
   RestOrd(aOrd,.T.)
End If

Return

/*
Funcao          : PS400Seek(cSeek,nOrder,oBrowse)
Parametros      : cSeek - caixa de texto da pesquisa, nOrder - nº da escolha no combobox, oBrowse - Objeto
Retorno         : Lógico
Objetivos       : Setar o foco da tela do FWBROWSE
Autor           : Fabio Satoru Yamamoto
Data            : 14/02/2012
*/
Function PS400Seek(cTipo, cSeek,nOrder,oBrowse)
Local lRet    := .F.
Local lAux    := .F.
Local nRecno  := TEMP->(Recno())
If nOrder == 1
   lAux :=TEMP->(DbSeek(xFilial("EJX")+cTipo+cSeek))
EndIf

If lAux
   nRecno := TEMP->(Recno())
   lRet   := .T.
Else
   EasyHelp("Registro não encontrado")   
EndIf

oBrowse:GoTo(nRecno,.T.)

Return lRet  

/*
Programa   : PS401AtuReg()
Objetivo   : Realizar a geração automática do RAS/RVS para os processos
Retorno    : lRet
Parâmetros : aItem
Autor      : Fabio Satoru Yamamoto
Data       : 19/12/2013
*/
Function PS401AtuReg(aItem)
Local i        := 0
Local cChave   := ""
Local aChave   := {}

EJW->(DbSetOrder(1)) //EJW_FILIAL + EJW_TPPROC + EJW_PROCES
EJW->(DbGoTop())
Begin Sequence
   oProgress:SetRegua(Len(aItem))
   If Type("cPed") == "C"
      For i:= 1 to Len(aItem)

         TEMP->(dbGoTo(aItem[i]))
         If EJW->(DbSeek(xFilial("EJW") + TEMP->EJW_TPPROC + TEMP->EJW_PROCES)) .And. aScan(aChave , xFilial("EJW") + TEMP->EJW_TPPROC + TEMP->EJW_PROCES)==0
            PS400GeraReg(ALTERAR,.T.)
            If !oProgress:IncRegua()
               Break
            EndIf
            cChave := (xFilial("EJW") + TEMP->EJW_TPPROC + TEMP->EJW_PROCES)
            aAdd( aChave, (xFilial("EJW") + TEMP->EJW_TPPROC + TEMP->EJW_PROCES)  )
         End If

      Next
   EndIf
   EasyHelp("Operação Finalizada!","Aviso")
 
End Sequence

Return

/*
Programa   : PS401AtuReg()
Objetivo   : Realizar a geração automática do RAS/RVS para os processos
Retorno    : lRet
Parâmetros : aItem
Autor      : Fabio Satoru Yamamoto
Data       : 19/12/2013
*/
Function PS400DTVAL(cDtNova,cDtPrIn)
//Local bMarca    :={|| If((nPos := aScan(aItem,TEMP->(Recno())) ==0) .And. PS400DTVAL(MV_PAR03, TEMP->EJX_DTPRIN) ,Aadd(aItem,TEMP->(Recno())),(aDel(aItem,nPos),aSize(aItem,Len(aItem)-1)))}
//Local bMarcaTds :={|oDlg| If(!Empty(aItem),aItem:={},aItem := GetAllItens()),oDlg:Refresh(.T.)}
Local lRet := .T.
   If !Empty(cDtNova) .And. !Empty(cDtPrIn)
      If cDtNova < cDtPrIn
         lRet := .F.
         EasyHelp("A data de previsão final deve ser maior ou igual a data de previsão inicial.","Aviso")
      EndIf
   EndIf
Return lRet


/*
Programa   : PS400VALNBS()
Objetivo   : Realizar a geração automática do RAS/RVS para os processos
Retorno    : lRet
Parâmetros : aItem
Autor      : Fabio Satoru Yamamoto
Data       : 02/01/2014
*/
Function PS400VALNBS(cNBS)
Local lRet := .T. 
EL0->(dbSetOrder(1))//EL0_FILIAL+EL0_COD
   If EL0->(dbSeek(xFilial()+cNBS))
      If EL0->(FieldPos("EL0_MSBLQL"))>0 .And. EL0->EL0_MSBLQL == "1"
         lRet := .F.
      EndIf
   EndIf
Return lRet

/*
Funcao     : ESSPRE()
Parametros : oModel
Retorno    : Lógico
Objetivos  : Validar a abertura do modelo
Autor      : SSS - REQ 8
Data/Hora  : 16/06/2014
Revisão    : wfs - out/2015
Obs.       : 
*/
*----------------------------*
Static Function ESSPRE(oModel)  //SSS - REQ 8 16/06/2014
*----------------------------*
Local lRet:= .T.

Begin Sequence
   If AvFlags("ESS_EAI") .And.;
      (oModel:GetOperation() == ALTERAR .Or. oModel:GetOperation() == EXCLUIR) .And.;
      EJW->EJW_STTPED == "5"//CANCELADO
      //.And. PS400Info("EJW_STTPED") == "5"
      
      EasyHelp("Este processo foi cancelado no ERP de origem e não pode ser atualizado.", "Atenção")
      lRet:= .F.
      Break
   EndIf
End Sequence

Return lRet 
/*
Funcao      : ValidaDet
Parametros  : - array com os itens do processo
              - Tipo do processo
Retorno     : 
Objetivos   : Acrescentar o campo tipo no array de itens quanto rotina automática
Autor       : WFS
Data/Hora   : Abr/2015
Revisao     :
Obs.        :
*/
Static Function ValidaDet(aItens, cTipo)
Local nPos := 0
Local nCont:= 0

Begin Sequence

   For nCont:= 1 To Len(aItens)
      nPos:= AScan(aItens[nCont], {|x| AllTrim(Upper(x[1])) == "EJX_TPPROC"})
      
      If nPos == 0
         AAdd(aItens[nCont], {"EJX_TPPROC", cTipo, Nil})
      EndIf
   Next

End Sequence
Return

/*
Funcao      : PS400MdInv
Parametros  : 
Retorno     : cRet - Moeda da duplicata gerada pelo documento de entrada 
Objetivos   : Retornar a moeda do título no SIGAFIN gerado pela NF no SIGACOM para a invoice no SIGAESS
Autor       : NCF
Data/Hora   : Ago/2015
Revisao     :
Obs.        : Arquivos de detalhe da Nota Fiscal (SD1) deve estar posicionado.
*/
Function PS400MdInv()
Local cRet := ""
Local cQuery

cquery := "SELECT DISTINCT E2_MOEDA"
cquery += " FROM "+RetSqlName("SE2")+" TIT"
cquery += " INNER JOIN "+RetSqlName("SF1")+" NFE"
cquery += " ON TIT.E2_FILIAL  = NFE.F1_FILIAL  AND"
cquery +=    " TIT.E2_NUM     = NFE.F1_DOC     AND"
cquery +=    " TIT.E2_PREFIXO = NFE.F1_PREFIXO   AND"
cquery +=    " TIT.E2_FORNECE = NFE.F1_FORNECE AND"
cquery +=    " TIT.E2_LOJA    = NFE.F1_LOJA"
cquery +=    " WHERE TIT.D_E_L_E_T_ = ' '"
cquery +=    " AND NFE.D_E_L_E_T_ = ' '"
cquery +=    " AND NFE.F1_FILIAL = '" +SD1->D1_FILIAL +"'"
cquery +=    " AND NFE.F1_DOC = '"    +SD1->D1_DOC    +"'"
cquery +=    " AND NFE.F1_SERIE = '"  +SD1->D1_SERIE  +"'"
cquery +=    " AND NFE.F1_FORNECE = '"+SD1->D1_FORNECE+"'"
cquery +=    " AND NFE.F1_LOJA = '"   +SD1->D1_LOJA   +"'"

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "MOEDAINV", .T., .T.) 
      
MOEDAINV->(DBGotop())

IF MOEDAINV->(!EOF())
   cRet := EasyGParam("MV_SIMB"+Alltrim(Str(MOEDAINV->E2_MOEDA)),,"")
EndIf
If ValType(cRet) == 'L'
   cRet := ""
EndIf 

MOEDAINV->(DBCloseArea())

return cRet

*-------------------------*
Function PS400TipoVinc(cTipo)
*-------------------------*
Local cRet := "0"
Local cCodEmp    := ""
Local cLojEmp    := ""
Local aIdEmpr    := {}   //NCF - 20/09/2017 - tratamento para localizar fornecedor/cliente quando o CNPJ for repetido 
Local aChaves    := {}   //                   e a busca acontecer peloa tabela de tipos de vínculo.
Local i
Default cTipo := cPed

If cTipo =="A"
   
   //MCF - 03/08/2016
   If EasyGParam("MV_ESS0021",,.F.) .And. !Empty(EJW->EJW_CODEMP) .And. !Empty(EJW->EJW_LOJEMP)
      //cCodEmp := EJW->EJW_CODEMP
      //cLojEmp := EJW->EJW_LOJEMP
      aAdd(aIdEmpr, {EJW->EJW_CODEMP,EJW->EJW_LOJEMP})
   Else
      SA1->(DbSetOrder(3))
      If SA1->(DbSeek(xFilial()+SM0->M0_CGC))
         If EasyGParam("MV_VALCNPJ",,"2") == "1"
            Do While SA1->(!Eof()) .And. SA1->A1_CGC == SM0->M0_CGC
               aAdd(aIdEmpr, {SA1->A1_COD,SA1->A1_LOJA})
               SA1->(DbSkip())
               //cCodEmp := SA1->A1_COD
               //cLojEmp := SA1->A1_LOJA               
            EndDo 
         Else 
            aAdd(aIdEmpr, {SA1->A1_COD,SA1->A1_LOJA})
         EndIf
      EndIf
   EndIf

   For i:=1 to Len(aIdEmpr)
      aAdd(aChaves, xFilial("ELM")+AvKey(aIdEmpr[i][1],"ELM_CODCLI")+AvKey(aIdEmpr[i][2],"ELM_LOJCLI")+AvKey(EJW->EJW_EXPORT,"ELM_CODFOR")+AvKey(EJW->EJW_LOJEXP,"ELM_LOJFOR") )
   Next i
   //cChave := xFilial("ELM")+AvKey(cCodEmp,"ELM_CODCLI")+AvKey(cLojEmp,"ELM_LOJCLI")+AvKey(EJW->EJW_EXPORT,"ELM_CODFOR")+AvKey(EJW->EJW_LOJEXP,"ELM_LOJFOR")
   ELM->(DbSetOrder(1))

ElseIf cTipo =="V"

   If EasyGParam("MV_ESS0021",,.F.) .And. !Empty(EJW->EJW_CODEMP) .And. !Empty(EJW->EJW_LOJEMP)
      //cCodEmp := EJW->EJW_CODEMP
      //cLojEmp := EJW->EJW_LOJEMP
      aAdd(aIdEmpr, {EJW->EJW_CODEMP,EJW->EJW_LOJEMP})
   Else
      SA2->(DbSetOrder(3))
      If SA2->(DbSeek(xFilial()+SM0->M0_CGC))
         If EasyGParam("MV_VALCNPJ",,"2") == "1"
            Do While SA2->(!Eof()) .And. SA2->A2_CGC == SM0->M0_CGC
               aAdd(aIdEmpr, {SA2->A2_COD,SA2->A2_LOJA})
               SA2->(DbSkip())
               //cCodEmp := SA2->A2_COD
               //cLojEmp := SA2->A2_LOJA
            EndDo
         Else
            aAdd(aIdEmpr, {SA2->A2_COD,SA2->A2_LOJA})         
         EndIf
      EndIf
   EndIf
   
   For i:=1 to Len(aIdEmpr)
      aAdd(aChaves, xFilial("ELM")+AvKey(EJW->EJW_IMPORT,"ELM_CODCLI")+AvKey(EJW->EJW_LOJIMP,"ELM_LOJCLI")+AvKey(aIdEmpr[i][1],"ELM_CODFOR")+AvKey(aIdEmpr[i][2],"ELM_LOJFOR") )
   Next i
   //cChave := xFilial("ELM")+AvKey(EJW->EJW_IMPORT,"ELM_CODCLI")+AvKey(EJW->EJW_LOJIMP,"ELM_LOJCLI")+AvKey(cCodEmp,"ELM_CODFOR")+AvKey(cLojEmp,"ELM_LOJFOR")
   ELM->(DbSetOrder(1))
EndIf

For i:= 1 To Len(aChaves)
   If ELM->(DbSeek(aChaves[i]))
      cRet := ELM->ELM_TIPVIN
      EXIT
   EndIf
Next i

Return cRet

//MFR 15/02/2017
Function PS400Gatil(cCampo)
Local cRetorno:= ""
Private lFornEx  := EasyGParam("MV_ESS0015",,)//Verifica se deve pegar loja somente do exterior

If cCampo == "EJW_LOJEXP"
   SA2->(DBSetOrder(1))  
   IF SA2->(DbSeek(xFilial("SA2")+M->EJW_EXPORT))
        DO While SA2->(!Eof()) .AND. SA2->A2_FILIAL == xFilial("SA2") .AND. SA2->A2_COD == M->EJW_EXPORT
          if !lFornEx
            if SA2->A2_PAIS != "105" .AND. SA2->A2_MSBLQL # "1"
                cRetorno:= SA2->A2_LOJA
                Exit
            EndIf  
          else
            If SA2->A2_MSBLQL # "1"
              cRetorno:= SA2->A2_LOJA
              Exit
            EndIf
          EndIf
	      SA2->(DbSkip()) 
        EndDo
   EndIf   
   If empty(cRetorno)  
      MsgInfo("Fornecedor sem loja cadastrada no exterior", "Aviso")
   EndIf
EndIf     

If cCampo == "EJW_LOJIMP"
  SA1->(DBSetOrder(1))  
  IF SA1->(DbSeek(xFilial("SA1")+M->EJW_IMPORT))
    DO While SA1->(!Eof()) .AND. SA1->A1_FILIAL == xFilial("SA1") .AND. SA1->A1_COD == M->EJW_IMPORT
      if !lFornEx
          if SA1->A1_PAIS != "105" .AND. SA1->A1_MSBLQL # "1"
            cRetorno:= SA1->A1_LOJA
            Exit
          EndIf  
      else
        if SA1->A1_MSBLQL # "1"
          cRetorno:= SA1->A1_LOJA
          Exit
        EndIf
      EndIf
    SA1->(DbSkip()) 
    EndDo
  EndIf   
  If empty(cRetorno)  
    MsgInfo("Cliente sem loja cadastrada no exterior", "Aviso")
  EndIf
EndIf

Return cRetorno

/*
Programa   : PS400DelItm()
Objetivo   : Retornar o filtro utilizado pelo consulta padrão de enquadramentos (ELC)
Retorno    : cRet
Autor      : Rafael Ramos Capuano
Data       : 18/03/2013 - 16:33
*/


Function PS400DelItm(cNbs, cPais, cModo, dDtIni)
  return empty(cNbs) .or. empty(cPais) .or. empty(cModo) .or. empty(dDtIni) .or. dDtIni > dDataBase

/*
Funcao      : MontaQuery
Parametros  : Objeto FWMBrowse
Retorno     : cQuery - Query com os filtros aplicados pelo usuário
Objetivos   : Montar a expressão (query) com os filtros criados e aplicados pelo usuário no Browse
Autor       : wfs
Data/Hora   : set/2017
Revisao     :
Obs.        : 
*/
Static Function MontaQuery(oObj)
Local cFiltro:= ""
Local cQuery:= ""
Local cSubQuery:= ""
Local nCont
Local aFiltro:= {}
Local aFiltroRelacionamentos:= {}
Local aRelacionamentos:= {}
Local cAllFilial, nFilial
Local i, cExpFiltro, aExpFiltro
Begin Sequence

   /* Retorna a lista de filtros realizados */
   aFiltro:= oObj:oFwFilter:GetFilter()
   /*
   For nCont:= 1 To Len(aFiltro)
      If nCont > 1
         cFiltro += " And "
      EndIf
      //If Empty(aFiltro[nCont][3])
         cFiltro += "(" + aFiltro[nCont][2] + ")"
      //Else
         //cFiltro += "(" + aFiltro[nCont][3] + ")"
      //EndIf
   Next
   */
   For nCont:= 1 To Len(aFiltro)
      If nCont > 1
         cFiltro += " And "
      EndIf
      If Empty(aFiltro[nCont][3])
        iF AT( "ALLTRIM(" , UPPER(aFiltro[nCont][2]) ) > 0
          aFiltro[nCont][2] := STRTRAN( UPPER(aFiltro[nCont][2]) , "ALLTRIM(" , "" , 1 , 1 )
          aFiltro[nCont][2] := STRTRAN( UPPER(aFiltro[nCont][2]) , ")" , "" , 1 , 1 )
        Endif
        aFiltro[nCont][2] := STRTRAN( UPPER(aFiltro[nCont][2]) , "==" , "=" )
        aFiltro[nCont][2] := STRTRAN( UPPER(aFiltro[nCont][2]) , '"' , "'" )
        aFiltro[nCont][2] := STRTRAN( UPPER(aFiltro[nCont][2]) , '.AND.' , "AND" )
        aFiltro[nCont][2] := STRTRAN( UPPER(aFiltro[nCont][2]) , '.OR.' , "OR" )
        cFiltro += "(" + aFiltro[nCont][2] + ")"
      Else
         aExpFiltro := EasyStrSplit( aFiltro[nCont][3] , "#")
         If Len(aExpFiltro) > 1
            cExpFiltro := ""
            For i:=1 To Len(aExpFiltro)
               If "FWMNTFILDT" $ Upper(aExpFiltro[i])
                  cExpFiltro += &(aExpFiltro[i])
               Else
                  cExpFiltro += aExpFiltro[i]
               EndIf
            Next i
            cFiltro += "(" + cExpFiltro + ")"
         Else
            cFiltro += "(" + aExpFiltro[1] + ")"
         EndIf
      EndIf
   Next nCont   
   /* Filiais em uso */
   cAllFilial:= ""
   nFilial:= Len(oObj:aAllFilial)
   For nCont:= 1 To nFilial
      cAllFilial += "'" + oObj:aAllFilial[nCont] + "'"
      If nCont < nFilial
         cAllFilial += ", "
      EndIf
   Next

   /* Query principal */
   cQuery:= "Select EJW.R_E_C_N_O_ RECNO from " + RetSqlName("EJW") + " EJW Where EJW_FILIAL In (" + cAllFilial + ")"
   
   If !Empty(cFiltro)
      cQuery:= cQuery + " And " + cFiltro
   EndIf

   If TcSrvType() <> "AS/400"
      cQuery:= cQuery + " And EJW.D_E_L_E_T_ <> '*'"
   Else
      cQuery:= cQuery + " And @DELETED@ <>'*'"
   EndIf

   /* Retorna a lista de filtros de relacionamentos executados */
   aFiltroRelacionamentos:= oObj:oFwFilter:GetFilterRelation()

   /* Retorna a lista dos relacionamentos existentes para a EJW */
   aRelacionamentos:= oObj:oFwFilter:GetRelation()

   /* Se houver filtro de relacionamentos, deve ser verificado quais os campos envolvidos (domínio e contra-domínio)
      para a montagem da subquery */
   If Len(aFiltroRelacionamentos) == 0
      Break
   EndIf

   /* Criação da subquery, com filtros de relacionamentos de tabelas */
   cSubQuery:= MontaSubQuery(aRelacionamentos, aFiltroRelacionamentos)

   cQuery += " And Exists(" + cSubQuery + ")"

End Sequence

Return ChangeQuery(cQuery)

/*
Funcao      : MontaSubQuery
Parametros  : aRelacionamentos
              aFiltro
Retorno     : cQuery - Query com os filtros de relacionamentos aplicados pelo usuário.
              Este retorno será usado como subquery da query principal
Objetivos   : Montar a expressão (query) com os filtros criados e aplicados pelo usuário no Browse,
              usando o recurso de relacionamento de tabelas
Autor       : wfs
Data/Hora   : set/2017
Revisao     :
Obs.        : O Protheus aplica apenas um relacionamento por vez; neste caso, se houver relacionamentos com duas ou mais tabelas,
              apenas os filtros da última tabela/ último relacionamento selecionado será considerado.
*/
Static Function MontaSubQuery(aRelacionamentos, aFiltro)
Local aCposDominio:= {}
Local aCposContraD:= {}
Local cQuery:= ""
Local cTempQuery:= ""
Local cOldCompara:= ""
Local cAlias:= ""
Local nPos, nLenFiltro, x, y

   /* Verificação do relacionamento aplicado e dos filtros criados pelo usuário */
   nLenFiltro:= Len(aFiltro)
   For x:= 1 To nLenFiltro
      nPos:= AScan(aRelacionamentos, {|a| a[1] == .T. .And. a[2] == aFiltro[x][8]}) //posição 8: Alias
      If nPos > 0
         
         aCposDominio:= Strtokarr(aRelacionamentos[nPos][4], "+")
         aCposContraD:= Strtokarr(aRelacionamentos[nPos][5], "+")
         
         //subquery temporária
         cTempQuery:= ""
         For y:= 1 To Len(aCposDominio)
            cTempQuery += aCposDominio[y] + " = " + aCposContraD[y] + " And "
         Next
         If cTempQuery <> cOldCompara
            cOldCompara:= cTempQuery
         Else
            /* Se a comparação entre campos foi usada anteriormente, desconsidera */
            cTempQuery:= ""
         EndIf

         //subquery principal
         cQuery += cTempQuery + "(" + aFiltro[x][3] + ")"
         If x < nLenFiltro
            cQuery += " And "
         EndIf

         cAlias:= aFiltro[x][8] //posição 8: Alias
      EndIf
   Next
   
   //subquery principal
   cQuery:= "Select " + cAlias + ".R_E_C_N_O_ from " + RetSqlName(cAlias) + " " + cAlias + " Where " + cQuery
   If TcSrvType() <> "AS/400"
      cQuery:= cQuery + " And " + cAlias + ".D_E_L_E_T_ <> '*'"
   Else
      cQuery:= cQuery + " And @DELETED@ <>'*'"
   EndIf

Return ChangeQuery(cQuery)  


/*
Funcao      : PosPrcESS
Parametros  : cTipo   = "A"(Aquisição) ou "V"(Venda)
              cPedido = Nro do Pedido no SIGACOM/SIGAFAT
Retorno     : lRet    = Retorna se posicionou em um Processo de aquisião que possui origem em um destes dois módulos
Objetivos   : Posicionar no Processo do módulo SIGAESS gerado a partir de um Pedido de Compra/Venda
Autor       : NCF
Data/Hora   : Março/2018
Revisao     :
*/
Static Function PosPrcESS(cTipo,cPedido)

Local lRet     := .F.
Local cChave   := xFilial("EJW")+AvKey(cTipo,"EJW_TPPROC")+AvKey(cPedido,"EJW_PROCES")
Local cOrigCOM := AvKey("SIGACOM","EJW_ORIGEM")
Local cOrigFAT := AvKey("SIGAFAT","EJW_ORIGEM")
Begin Sequence
   EJW->(DbSeek(cChave))
   Do While EJW->&(IndexKey()) == cChave 
      If cTipo == "A"
         If EJW->EJW_ORIGEM == cOrigCOM
            lRet := .T.
            Break
         EndIf
      ElseIf cTipo == "V"
         If EJW->EJW_ORIGEM == cOrigFAT
            lRet := .T.
            Break
         EndIf
      EndIf   
      EJW->(DbSkip())
   EndDo
End Sequence

Return lRet

