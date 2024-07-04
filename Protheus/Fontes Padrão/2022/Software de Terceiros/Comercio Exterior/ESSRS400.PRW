/*
Programa   : ESSRS400
Objetivo   : Manutenção da Rotina de Registro de Serviços
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 31/08/2012 14:52 
Revisao    : 
*/

#Include 'Protheus.ch'
#Include "Average.ch"
#Include "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

#Define PROCESSADO	"P"
#Define ENTER CHR(13)+CHR(10)

Static aModels := {}

Function ESSRS400(cTipo,aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Local cFonte       := "ESSRS400"
Local aCoors       := FWGetDialogSize( oMainWnd )
Local oAvObject    := AvObject():New()
Local nPos
Default lCallInv    := .F.
Private oBrowseUp   := NIL
Private oPanelUp    := NIL
Private oFWLayer    := NIL
Private oBrowseUp   := NIL 
Private oBrowseDown := NIL 
Private oRelacEL9   := NIL
Private oDlgPrinc   := NIL
Private cBrwFiltro  := "EJY->EJY_TPPROC=='"+cTipo+"'"  //Filtra pelo Tipo de Processo,'A' para Aquisicao e 'V' para Venda     
Private cTpReg      := cTipo
//Private aRotina     := {} FSY - 17/01/2014 - Nopado
Private lRS400Auto  := ValType(aCab) <> "U" .Or. ValType(aItens) <> "U" .Or. ValType(aAnexos) <> "U" .Or. ValType(nOpcAuto) <> "U"
Private cFase       := "2"
Private cCadastro   := ""//Variavel necessaria na função MsDocument()
Private oModelAuto

SIX->(DbSetOrder(1)) //MCF - 09/08/2016
If EasyGParam("MV_ESS0027",,9) >= 10 .And. SIX->(DBSeek("ELM1")) .AND. Alltrim(SIX->CHAVE) == 'ELM_FILIAL+ELM_COD+ELM_CODCLI+ELM_LOJCLI+ELM_CODFOR+ELM_LOJFOR'
   EasyHelp("É necessário realizar uma alteração de indices para prosseguir com a utilização do Easy Siscoserv. Entre em contato com o administrador e peça para que o mesmo siga as "+;
            "orientações do documento http://tdn.totvs.com/display/PROT/ " + ENTER + "TUPFFU_DT_Implementacao_Easy_Siscoserv","Aviso")
   Return
EndIf

//RRC - 11/11/2013 - Caso o compartilhamento entre EJY e EL9 sejam diferentes, não deve prossguir, uma vez que existe um relacionamento entre elas
Begin Sequence
If (!Empty(xFilial("EJY")) .And. Empty(xFilial("EL9"))) .Or. (Empty(xFilial("EJY")) .And. !Empty(xFilial("EL9")))
   If !lRS400Auto
      EasyHelp("O Compartilhamento das tabelas EJY (Registro de Serviços) e EL9 (Pagamentos do Processo) são diferentes, essa rotina não poderá ser executada.","Aviso")
   Else
      If Type("lMsErroAuto") == "L"
         lMsErroAuto := .T.
      EndIf
      oAvObject:Error("O Compartilhamento das tabelas EJY (Registro de Serviços) e EL9 (Pagamentos do Processo) são diferentes, essa rotina não poderá ser executada.")
      AEval(oAvObject:aError,{|X| AutoGrLog(x)})        
   EndIf
   Break
Else

   If !lRS400Auto
   
      Define MsDialog oDlgPrinc Title If(cTpReg=="A","Registro de Aquisição de Serviços (RAS)", "Registro de Venda de Serviços (RVS)") From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
   
      // Cria o conteiner onde serão colocados os browses
      oFWLayer := FWLayer():New()
      oFWLayer:Init( oDlgPrinc, .F., .T. )
   
      // Define Painel Superior
      oFWLayer:AddLine( 'UP', 50, .F. )// Cria uma "linha" com 50% da tela
      oFWLayer:AddCollumn( 'ALLUP', 100, .T., 'UP' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
      oPanelUp := oFWLayer:GetColPanel( 'ALLUP', 'UP' )// Pego o objeto desse pedaço do container

      // FWmBrowse Superior
      oBrowseUp:= FWmBrowse():New()
      oBrowseUp:SetOwner( oPanelUp )
      oBrowseUp:SetFilterDefault(cBrwFiltro) //Filtro dos registros a serem exibidos
   
      // Aqui se associa o browse ao componente de tela
      //oBrowseUp:SetDescription( "Serviços" )//"Serviços"
      oBrowseUp:SetDescription(If(cTpReg=="A","Registro de Aquisição de Serviços (RAS)","Registro de Venda de Serviços (RVS)")) //Descrição a ser apresentada no Browse
      oBrowseUp:SetAlias( 'EJY' )
      oBrowseUp:SetMenuDef(cFonte)
   
      // Define de onde virao os botoes deste browse
      oBrowseUp:SetProfileID( '1' ) // identificador (ID) para o Browse
      oBrowseUp:ForceQuitButton() // Força exibição do botão "Sair"
      oBrowseUp:DisableDetails()
      oBrowseUp:AddLegend( "EJY_STTSIS=='1'", "RED"  , "Aguardando registro" )//Campo para adicionar marcação
      oBrowseUp:AddLegend( "EJY_STTSIS=='2'", "BLUE" , "Parcialmente registrado" )//Campo para adicionar marcação
      oBrowseUp:AddLegend( "EJY_STTSIS=='3'", "GREEN", "Registrado" )//Campo para adicionar marcação   
   
      //THTS - 18/07/2017 - Criada a funcao AvGetCpBrw() para retirar do Browse campos que nao querem que sejam exibidos
      If Upper(cTipo) == "A"
            //aMosta := {"EJY_EXPORT", "EJY_LOJEXP", "EJY_DSCEXP"}
            //aEsconde := {"EJY_IMPORT", "EJY_LOJIMP", "EJY_DSCIMP"}
            oBrowseUp:SetOnlyFields(AvGetCpBrw("EJY",{"EJY_IMPORT", "EJY_LOJIMP", "EJY_DSCIMP"}))
      ElseIf Upper(cTipo) == "V"
            //aMosta := {"EJY_IMPORT", "EJY_LOJIMP", "EJY_DSCIMP"}
            //aEsconde := {"EJY_EXPORT", "EJY_LOJEXP", "EJY_DSCEXP"}
            oBrowseUp:SetOnlyFields(AvGetCpBrw("EJY",{"EJY_EXPORT", "EJY_LOJEXP", "EJY_DSCEXP"}))
      EndIf   
   
      oBrowseUp:Activate() 
   
      // Painel Inferior                 
      oFWLayer:AddLine( 'DOWN', 50, .F. )// Cria uma "linha" com 50% da tela
      oFWLayer:AddCollumn( 'ALLDOWN' , 100, .T., 'DOWN' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
      oPanelDown := oFWLayer:GetColPanel( 'ALLDOWN' , 'DOWN' ) // Pego o objeto inferior
   
      // FWmBrowse Parcelas de Cambio
      oBrowseDown:= FWMBrowse():New()
      oBrowseDown:SetOwner( oPanelDown )   
      oBrowseDown:SetDescription( If(cTpReg=="A","Pagamento (RP)", "Faturamento (RF)") )//"Pagamentos de Serviços"
      oBrowseDown:SetMenuDef( 'ESSPS402' ) // Nome do fonte do MenuDef 
      oBrowseDown:SetAlias( 'EL9' )
      oBrowseDown:SetProfileID( '2' ) 
      oBrowseDown:DisableDetails()
      oBrowseDown:ForceQuitButton() // Força exibição do botão "Sair"
      //oBrowseDown:SetFilterDefault(" EL9->EL9_FILIAL == '"+xFilial("EL9")+"' .AND. EL9->EL9_TPPROC == '"+cTpReg+"' .And. EL9->EL9_REGIST == '"+EJY->EJY_REGIST+"'")//Filtro do Browse
      oBrowseDown:AddLegend( "EL9_STTSIS=='1'", "RED"   , "Aguardando registro no SISCOSERV" )//Campo para adicionar marcação
      oBrowseDown:AddLegend( "EL9_STTSIS=='2'", "GREEN" , "Registrado no SISCOSERV" )//Campo para adicionar marcação
      oBrowseDown:AddLegend( "EL9_STTSIS=='3'", "YELLOW", "Aguardando cancelamento no SISCOSERV" )//Campo para adicionar marcação
      oBrowseDown:AddLegend( "EL9_STTSIS=='4'", "BLUE"  , "Cancelado no SISCOSERV" )//Campo para adicionar marcação
      oBrowseDown:AddLegend( "EL9_STTSIS=='5'", "WHITE" , "Aguardando retificação no SISCOSERV" )//Campo para adicionar marcação
   
      oBrowseDown:Activate() 

      // Relacionamento entre os Paineis
      DbSelectArea("EL9")
      oRelacEL9:= FWBrwRelation():New()
      /*RRC - 11/11/2013 - Tratamento para considerar múltiplas filiais:
      A função xFilial() retorna só a filial ativa, mas o browseUp exibe registros de todas as filiais da empresa, neste caso, o browseDown deve exibir os dados relacionados*/
      //oRelacEL9:AddRelation( oBrowseUp, oBrowseDown , { { 'EL9_FILIAL', 'xFilial("EL9")'}, { 'EL9_TPPROC' , 'EJY_TPPROC' }, { 'EL9_REGIST','EJY_REGIST'}} )
      oRelacEL9:AddRelation( oBrowseUp, oBrowseDown , { { 'EL9_FILIAL', 'EJY_FILIAL'}, { 'EL9_TPPROC' , 'EJY_TPPROC' }, { 'EL9_REGIST','EJY_REGIST'}} )
      oRelacEL9:Activate()
        
      oBrowseUp:Refresh()
      oBrowseDown:Refresh(.T.)

      Activate MsDialog oDlgPrinc Center
      EJY->(dbClearFilter())
   Else
      Begin Sequence

      If ValidaIntegracao(nOpcAuto, aCab, aItens, aAnexos, lCallInv)

         nOpcAuto := ValidaOperacao(nOpcAuto, aCab, aItens, aAnexos)
   
         If nOpcAuto == 4 .And. !lCallInv
            aItens := EasyEAutItens("EJY", "EJZ", aCab, aItens , "EJY_FILIAL+EJY_TPPROC+EJY_REGIST", EJZ->(IndexKey(1)), 1)
            //aAnexos:= EasyEAutItens("EJY", "EL2", aCab, aAnexos, "EJY_FILIAL+EJY_TPPROC+EJY_REGIST", EL2->(IndexKey(3))+"+EL2_SEQPAG", 3)//Antigo
            //RMD - 11/04/17 - A partir do manual 10, os anexos passaram a ser associados aos itens, com isso é necessário verificar a chave com o campo EJ2_SEQPRC
            If EasyGParam("MV_ESS0027",,9) >= 10
               aAnexos:= EasyEAutItens("EJY", "EL2", aCab, aAnexos, "EJY_FILIAL+EJY_TPPROC+EJY_REGIST", EL2->(IndexKey(3))+"+EL2_SEQPRC", 3)          
            Else
               aAnexos:= EasyEAutItens("EJY", "EL2", aCab, aAnexos, "EJY_FILIAL+EJY_TPPROC+EJY_REGIST", EL2->(IndexKey(3)), 3)          
            EndIf
         ElseIf nOpcAuto == 5
            If !EasySeekAuto("EJY",aCab,1)
               //EasyHelp("Não foi encontrado processo de serviço para exclusão.","Aviso")
               //lRet := .F.
               Break
            EndIf
         EndIf

         //Definições de WHEN dos campos
         INCLUI := nOpcAuto == INCLUIR
         ALTERA := nOpcAuto == ALTERAR
         EXCLUI := nOpcAuto == EXCLUIR
      
         aRotina := MenuDef()
      
         If (nPos := aScan(aModels,{|X| X[1] == cTipo})) == 0
            aAdd(aModels,{cTipo,ModelDef()})
            nPos := Len(aModels)
         EndIf
         oModelAuto := aModels[nPos][2]
      
         lMsErroAuto := !EasyMVCAuto("ESSRS400",nOpcAuto,{{"EJYMASTER" ,aCab},{"EJZDETAIL",aItens},{"EL2DETAIL",aAnexos}},@oAvObject)
         If lMsErroAuto
            AEval(oAvObject:aError,{|X| AutoGrLog(x)})
            //ConOut(GetErrMessage(oModel))   
         EndIf

      EndIf
   
      End Sequence   
   EndIf
EndIf
End Sequence
Return Nil

*------------------------*
Static Function MenuDef()
*------------------------*
Local aRotina := {}
Local cTitle

If Type("cTpReg") == "C" 

      If cTpReg == "V"
            cTitle := "Faturamentos"
      Else
            cTitle := "Pagamentos"
      EndIf

      //Adiciona os botões na MBROWSE
      ADD OPTION aRotina TITLE "Pesquisar"     ACTION "AxPesqui"         OPERATION 1 ACCESS 0
      ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.ESSRS400" OPERATION 2 ACCESS 0
      ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.ESSRS400" OPERATION 3 ACCESS 0
      ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.ESSRS400" OPERATION 4 ACCESS 0
      ADD OPTION aRotina TITLE "Excluir"       ACTION "RS400Excluir"     OPERATION 5 ACCESS 0  // GFP - 25/07/2014
      //ADD OPTION aRotina TITLE "Excluir"    ACTION "FWExecView('EXCLUIR','VIEWDEF.ESSRS400', 5,,,{|| RS400DelReg()})" OPERATION 5 ACCESS 0
      //ADD OPTION aRotina TITLE cTitle+" por serviços"     ACTION "ESSRS401"  	     OPERATION 6 ACCESS 0
      //ADD OPTION aRotina TITLE cTitle+" dos registros"    ACTION "ESSRS401"  	     OPERATION 7 ACCESS 0
      //ADD OPTION aRotina TITLE "Manutenção FFC" ACTION "ESSRS403"  	     OPERATION 6 ACCESS 0
      ADD OPTION aRotina TITLE "Legendas"      ACTION "RS400Legenda" OPERATION 9 ACCESS 0

EndIf

Return aRotina

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruEJY := FWFormStruct(1,"EJY",{|cCpo| MostrCpo(cCpo)},)
Local oStruEJZ := FWFormStruct(1,"EJZ",{|cCpo| MostrCpo(cCpo)},)
Local oStruEL2 := FWFormStruct(1,"EL2",{|cCpo| MostrCpo(cCpo)},)
Local bLinePos := {|| RS400GridVal()}
Local bLinePre := {|oGrid,nLine,cAction| RS400LinePre(oGrid,nLine,cAction)}  //RRC - 25/10/2013 - Atualização para validar a exclusão no modelo
//RRC - 10/09/2013 - Executa bPosValidação para verificar se pode excluir caso seja uma chamada da ExecAuto
Local bPosValidacao  := {|oMdl| If(oModel:GetOperation() == 5,RS400DelReg(),If(EasyGParam("MV_ESS0027",,9) >= 10,RS400VldNIF("EJY") /*.AND. RS400VldGrv()*/,.T.))} //MCF - 03/08/2016
Local bCommit  := {|oMdl| GravCamp(oMdl)}
Local bPosValEJZ  := {|| VerEnqRC()} //RRC - 19/03/2013 - Verifica os enquadramentos e Números de RC
Local bPosValEL2  := {|| GravDoc(cTpReg)}
Local nI                                                 

oModel := MPFormModel():New("ESSRS400",/*bGridValidacao*/,bPosValidacao,bCommit,/*bCancel*/)

//Modelo para criação da antiga Enchoice com a estrutura da tabela
oModel:AddFields("EJYMASTER", /*nOwner*/, oStruEJY,/*bPre*/,/*bPos*/)     
                                                             
//Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("EJZDETAIL", "EJYMASTER", oStruEJZ,  bLinePre , bLinePos , /*bPreVal*/,bPosValEJZ,/*bLoad*/ )
oModel:AddGrid("EL2DETAIL", "EJYMASTER", oStruEL2,  bLinePre ,/*bLinePos*/ , /*bPreVal*/,bPosValEL2,/*bLoad*/ )

//Modelo de relação entre Capa e Detalhe                                                                                                        

oModel:SetRelation("EJZDETAIL",{{"EJZ_FILIAL", "xFilial('EJZ')"}, {"EJZ_TPPROC", "RS400Info('EJY_TPPROC')"}, {"EJZ_REGIST", "EJY_REGIST"}} , EJZ->(IndexKey(1)))
//oModel:SetRelation("EL2DETAIL",{{"EL2_FILIAL", "xFilial('EL2')"}, {"EL2_TPPROC", "RS400Info('EJY_TPPROC')"}, {"EL2_REGIST", "EJY_REGIST"}, {"EL2_SEQREG", "RS400Info('EL2_SEQREG')"}} , EL2->(IndexKey(1)))
//oModel:SetRelation("EL2DETAIL",{{"EL2_FILIAL", "xFilial('EL2')"}, {"EL2_TPPROC", "RS400Info('EJY_TPPROC')"}, {"EL2_REGIST","EJY_REGIST"}, {"EL2_SEQPAG",'AvKey("","EL2_SEQPAG")'}, {"EL2_PROCES",'AvKey("","EL2_PROCES")'}} , EL2->(IndexKey(4)))// FSY - 04/12/13
oModel:SetRelation("EL2DETAIL",{{"EL2_FILIAL", "xFilial('EL2')"}, {"EL2_TPPROC", "RS400Info('EJY_TPPROC')"}, {"EL2_REGIST","EJY_REGIST"}, {"EL2_SEQPAG",'AvKey("","EL2_SEQPAG")'}} , EL2->(IndexKey(1)))// FSY - 04/12/13

//Informa grid não pussui preenchimento obrigátorio
oModel:GetModel( "EL2DETAIL" ):SetOptional( .T. ) 
 
//Valida se os campos podem ser alterados
For nI := 1 to Len(oStruEJY:aFields)
   If oStruEJY:aFields[nI][3] == "EJY_DTENC"
      oStruEJY:SetProperty( 'EJY_DTENC' , MODEL_FIELD_WHEN,{|| .T.})
   ElseIf oStruEJY:aFields[nI][3] == "EJY_PROCES"
      oStruEJY:SetProperty( 'EJY_PROCES', MODEL_FIELD_WHEN,{|| RS400When("EJY_PROCES")})
   ElseIf EasyGParam("MV_ESS0027",,9) >= 10 .AND. oStruEJY:aFields[nI][3] == "EJY_TIPVIN"
      oStruEJY:SetProperty( 'EJY_TIPVIN', MODEL_FIELD_WHEN,{|| RS400When("EJY_TIPVIN")})
   Else
      oStruEJY:SetProperty( oStruEJY:aFields[nI][3] , MODEL_FIELD_WHEN,{||Empty(RS400Info("EJY_DTENC"))})
   EndIf
Next

oStruEJZ:SetProperty( '*' , MODEL_FIELD_WHEN,{|| Empty(RS400Info("EJY_DTENC"))})

If Type("lRS400Auto") == "L"  .And.EasyGParam("MV_ESS0027",,9) >= 10
   If !lRS400Auto
      oStruEL2:SetProperty( '*' , MODEL_FIELD_WHEN,{|| .F.})
      oModel:GetModel( "EL2DETAIL" ):SetNoInsertLine(.T.)
   EndIf
EndIf

//Definição da Chave Primária
oModel:SetPrimaryKey( { "EJY_FILIAL", "EJY_TPPROC", "EJY_REGIST"}) 
oModel:GetModel("EJZDETAIL"):SetUniqueLine({ "EJZ_PROCES","EJZ_SEQPRC","EJZ_ITEM"})
If Type("cTpReg") == "C"  .And. Type("lRS400Auto") == "L"  .And. !lRS400Auto .AND. EasyGParam("MV_ESS0027",,9) < 10
   If cTpReg == "V"
      oModel:GetModel("EL2DETAIL"):SetUniqueLine({ "EL2_RE"})
   ElseIf cTpReg == "A"
      oModel:GetModel("EL2DETAIL"):SetUniqueLine({ "EL2_DI"})
   EndIf
EndIf
//Adiciona a descrição do Modelo de Dados
oModel:SetDescription("Registro de Serviços")
oModel:GetModel("EJYMASTER"):SetDescription("Registro")   // Título da Capa
oModel:GetModel("EJZDETAIL"):SetDescription("Serviços")   // Título da Capa
oModel:GetModel("EL2DETAIL"):SetDescription("Documentos") //Título do Detalhe 

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("ESSRS400")

//Cria a estrutura a ser usada na View 
Local oStruEJY  := FWFormStruct(2,"EJY",{|cCpo| MostrCpo(cCpo)}) 
Local oStruEJZ  := FWFormStruct(2,"EJZ",{|cCpo| MostrCpo(cCpo)},)
Local oStruEL2  := If(EasyGParam("MV_ESS0004",,.F.),FWFormStruct(2,"EL2",{|cCpo| MostrCpo(cCpo)},),)
Local oView
Private aLines  := {}

//É necessário filtrar a tabela para que o MVC não permite navegar pelos registros inválidos nas operações de visualização/alteração.
EJY->(dbSetFilter(&("{||"+cBrwFiltro+"}"),cBrwFiltro))

//Cria o objeto de View      
oView := FWFormView():New()

//Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EJY", oStruEJY, "EJYMASTER")
oView:AddGrid( "VIEW_EJZ", oStruEJZ, "EJZDETAIL" )
If EasyGParam("MV_ESS0004",,.F.)
   oView:AddGrid( "VIEW_EL2", oStruEL2, "EL2DETAIL" )
EndIf
//Criar "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox( 'EMCIMA'  , 50 )
If EasyGParam("MV_ESS0004",,.F.) 
   oView:CreateVerticalBox( 'EMCIMAESQ' , 65, 'EMCIMA' )
   oView:CreateVerticalBox( 'EMCIMADIR' , 35, 'EMCIMA' )
EndIf
oView:CreateHorizontalBox( 'EMBAIXO' , 50/*,,,"PASTAS","ABA01" */) 

//Relaciona o ID da View com o "box" para exibição 
If EasyGParam("MV_ESS0004",,.F.) 
   oView:SetOwnerView("VIEW_EJY", "EMCIMAESQ")
   oView:SetOwnerView("VIEW_EL2", "EMCIMADIR")
Else
   oView:SetOwnerView("VIEW_EJY", "EMCIMA")
EndIf
oView:SetOwnerView("VIEW_EJZ", "EMBAIXO")

//Remove campo da view
If Type("lRS400Auto") == "L"  .And. !lRS400Auto
   oStruEJZ:RemoveField("EJZ_MODO")
EndIf

If !EasyGParam("MV_ESS0021",,.F.)
   oStruEJY:RemoveField("EJY_CODEMP") 
   oStruEJY:RemoveField("EJY_LOJEMP")
   oStruEJY:RemoveField("EJY_DSCEMP")
   oStruEJY:RemoveField("EJY_CGC")
End If

If !(EasyGParam("MV_ESS0027",,9) >= 10 .AND. EasyGParam("MV_ESS0004",,.F.))
   oStruEJZ:RemoveField("EJZ_MOVTEM")
Endif

//Liga a identificação do componente                     
oView:EnableTitleView("VIEW_EJY", "Registro de Serviços"  , RGB(240,248,255))
//oView:EnableTitleView("VIEW_EJZ", "Serviços"  , RGB(240,248,255))
If EasyGParam("MV_ESS0004",,.F.) 
   oView:EnableTitleView("VIEW_EL2", "Documentos", RGB(240,248,255))
EndIf
//Habilita ButtonsBar
oView:EnableControlBar(.T.)

//Adicionando novo botão
oView:AddUserButton("Seleção de Processos", "CLIPS",{|oView| aLines:= FWSaveRows(),SelecPed(oModel),FWRestRows(aLines)})
oView:bCanActivate := {|oView| AtuView(oView)}
//oView:AddUserButton("Conhecimento"        , "CLIPS",{|| EJYMsDocument() })
Return oView

/*
Programa   : MostrCpo
Objetivo   : Verificar quais campos devem compor a estrutura  (Campos para Registro de Aquisição ou Venda de Serviços)
Parametros : Campos a serem verificados
Retorno    : lRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 31/08/2012 15:12 
Revisao    : 
*/

Static Function MostrCpo(cCpo)

Local lRet := .T.
Local aCampos

   If Type("cTpReg") == "C" 
      /*
      If cTpReg == "V" .And. Alltrim(cCpo) $ "EJY_EXPORT/EJY_LOJEXP/EJY_DSCEXP/EJZ_MODAQU/EL2_SEQREG/EL2_SEQPAG/EL2_DI"
         lRet := .F.
      EndIf
      If cTpReg == "A" .And. Alltrim(cCpo) $ "EJY_IMPORT/EJY_LOJIMP/EJY_DSCIMP/EJZ_MODVEN/EL2_SEQREG/EL2_SEQPAG/EL2_RE"
         lRet := .F.
      EndIf 
      */
      If cTpReg == "V"
         If lRS400Auto 
            aCampos := {"EJY_EXPORT","EJY_LOJEXP","EJY_DSCEXP","EJZ_MODAQU","EL2_SEQREG","EL2_FASE"}
         Else
            If !EasyGParam("MV_ESS0027",,9) >= 10
               aCampos := {"EJY_EXPORT","EJY_LOJEXP","EJY_DSCEXP","EJZ_MODAQU","EL2_REGIST","EL2_SEQREG","EL2_PROCES","EL2_FASE","EL2_DI","EL2_SEQPRC","EL2_SEQPAG"}
            Else
               aCampos := {"EJY_EXPORT","EJY_LOJEXP","EJY_DSCEXP","EJZ_MODAQU","EL2_REGIST","EL2_SEQREG","EL2_PROCES","EL2_FASE","EL2_SEQPRC","EL2_SEQPAG"}
            EndIf            
         EndIf
      EndIf
      If cTpReg == "A"
         If lRS400Auto 
            aCampos := {"EJY_IMPORT","EJY_LOJIMP","EJY_DSCIMP","EJZ_MODVEN","EL2_SEQREG","EL2_FASE"}
         Else
            If !EasyGParam("MV_ESS0027",,9) >= 10
               aCampos := {"EJY_IMPORT","EJY_LOJIMP","EJY_DSCIMP","EJZ_MODVEN","EL2_REGIST","EL2_SEQREG","EL2_PROCES","EL2_FASE","EL2_RE","EL2_SEQPRC","EL2_SEQPAG"}
            Else
               aCampos := {"EJY_IMPORT","EJY_LOJIMP","EJY_DSCIMP","EJZ_MODVEN","EL2_REGIST","EL2_SEQREG","EL2_PROCES","EL2_FASE","EL2_SEQPRC","EL2_SEQPAG"}
            EndIf
         EndIf 
      EndIf
      
      If aScan(aCampos,{|X| X == Alltrim(cCpo)}) > 0//Alltrim(cCpo) $ cCampos
         lRet := .F.
      EndIf 
   EndIf
   
Return lRet                                                                 

/*
Programa   : MdlCommit
Objetivo   : Gravação de registro no conteúdo de campos não pertencentes ao model
Parametros : Objeto do Model
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 31/08/2012 15:13 
Revisao    : 
*/
Static Function GravCamp(oMdl)
Local cCont, cProc, cModo, dDataEnc
Local oModelEJZ  := oMdl:GetModel("EJZDETAIL") 
Local oModelEL2  := oMdl:GetModel("EL2DETAIL")   
Local nOperation := oMdl:GetOperation()
Local nI
Local aOrd       := SaveOrd({"EJX","EJY","EJZ","EL2","EL1","EL9"})
Local oDados     := ERec():New()
Local aServicos  := {}
Local lRet := .T.
Local cCampo := "", cNBS := "", nValor := 0

Private lAltSta  :=.F.

Begin Transaction

If Type("cTpReg") == "C"
   If cTpReg == "V"
      cCont := "V"
      cModo := "EJZ_MODVEN" 
      cCampo := "EL2_RE"        
   Else   
      cCont := "A"
      cModo := "EJZ_MODAQU"
      cCampo := "EL2_DI"      
   EndIf
   
   //If nOperation <> MODEL_OPERATION_DELETE
   //   aServicos := RS400GetParc(cCont,RS400Info('EJY_REGIST')) // Retorna os serviços do registro que irão ser gerados as parcelas
   //EndIf
   
   cProc := RS400Info('EJY_REGIST')
   aServicos := {}
   aProcessos  := {}
   
   EJZ->(DbSetOrder(1))
   For nI := 1 To oModelEJZ:Length()
      oModelEJZ:GoLine(nI)
      // Retorna os serviços do registro que irão ser gerados as parcelas
      If !oModelEJZ:IsDeleted() .AND. nOperation <> MODEL_OPERATION_DELETE
         //RRC - 22/01/2013 
         If lStatus := EJZ->(DbSeek(xFilial("EJZ") + AvKey(cCont,"EJZ_TPPROC") + AvKey(cProc,"EJZ_REGIST") + AvKey(oModelEJZ:GetValue("EJZ_SEQREG"),"EJZ_SEQREG") ))    
            EL1->(DbSetOrder(1))
            lStatus := EL1->(DbSeek(xFilial("EL1")+AvKey(cCont,"EJZ_TPPROC") + AvKey(cProc,"EJZ_REGIST") + AvKey(oModelEJZ:GetValue("EJZ_SEQREG"),"EJZ_SEQREG") ))
         EndIf
         If !lStatus .And. !Empty(oModelEJZ:GetValue("EJZ_DTINI")) .And. !(oModelEJZ:GetValue("EJZ_DTINI")==EJZ->EJZ_DTINI)
            aAdd(aServicos,oModelEJZ:GetValue("EJZ_SEQREG"))
         EndIf
      EndIf
      
      aAdd(aProcessos,{oModelEJZ:GetValue("EJZ_PROCES"),oModelEJZ:GetValue("EJZ_SEQPRC"),oModelEJZ:IsDeleted()})
   Next
   
   cNBS := EJZ->EJZ_NBS  // GFP - 16/03/2016
   
   EL9->(DbSetorder(1))
   EL9->(DbSeek(xFilial("EL9")+AvKey(EJY->EJY_TPPROC,"EL9_TPPROC")+AvKey(EJY->EJY_REGIST,"EL9_REGIST")))  // GFP - 16/03/2016
   Do While EL9->(!Eof()) .And. EL9->(EL9_FILIAL+EL9_TPPROC+EL9_REGIST) == xFilial("EL9")+AvKey(EJY->EJY_TPPROC,"EL9_TPPROC")+AvKey(EJY->EJY_REGIST,"EL9_REGIST")
      nValor += EL9->EL9_VLCAMB
      EL9->(DbSkip())
   EndDo
   For nI := 1 To oModelEL2:Length()
      oModelEL2:GoLine(nI)
      //Ao encontrar um RE ou uma DI em branco, o Documento e o status for 1 - "Aguardando Registro no Siscoserv", deletará a linha
      //Se o status for diferente disso, grava com o campo em branco, para que não perca o vínculo com a EL7
      If EasyGParam("MV_ESS0027",,9) >= 10 .AND. nOperation <> MODEL_OPERATION_DELETE .AND. !oModelEL2:IsDeleted() .And. (oModelEL2:GetValue("EL2_STTSIS") == "1" .OR. Empty(oModelEL2:GetValue("EL2_STTSIS"))) .And. Empty(oModelEL2:GetValue("EL2_DI"))  .And. Empty(oModelEL2:GetValue("EL2_RE"))
         oModelEL2:DeleteLine()
      EndIf
   Next
   
   RestOrd(aOrd,.T.)
   
   FWFormCommit(oMdl) //Salva as operações efetuadas anteriormente  
   
   RS400AssociaPed(aProcessos,cCont)
   
   cProc    := EJY->EJY_REGIST
   dDataEnc := EJY->EJY_DTENC
      
   If nOperation == MODEL_OPERATION_INSERT
      If EJY->( RECLOCK("EJY",.F.) )
         EJY->EJY_TPPROC := cCont
         EJY->(MSUNLOCK())
      EndIf
      //Atualiza o Modo de Prestação de Serviços de acordo com conteúdo do Campo Virtual utilizado
      RS400Modo(cCont,cProc,cModo)
      
      //Atualiza status do serviço do Registro e do Processo
      RS400StaReg(cCont,cProc,dDataEnc)
      //Atualiza a Data do Registro da Capa
      RS400DtReg(cCont,cProc)
      
      //NCF - 07/03/2013 - (ExecAuto Registro) - Inicio do tratamento para exclusão de documentos deletados do registro
      For nI := 1 To oModelEL2:Length()
         oModelEL2:GoLine(nI)
         //Ao encontrar um RE ou uma DI em branco, o Documento e o status for 1 - "Aguardando Registro no Siscoserv", deletará a linha
         If !oModelEL2:IsDeleted() .And. (oModelEL2:GetValue("EL2_STTSIS") == "1" .OR. EasyGParam("MV_ESS0027",,9) >= 10) .And. Empty(oModelEL2:GetValue(cCampo))
            oModelEL2:DeleteLine()
         EndIf
      Next
   ElseIf nOperation == MODEL_OPERATION_UPDATE
      RS400Modo(cCont,cProc,cModo)
      //Atualiza status do serviço do Registro e do Processo quando for integracao csv MFR 27/02/2020
      if lRS400Auto
         RS400StaReg(cCont,cProc,dDataEnc)
      EndIf
      EL1->(DbSetOrder(1)) //EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG+EL1_PARC+EL1_SEQPAG
      EL9->(DbSetOrder(1)) //EL9_FILIAL+EL9_TPPROC+EL9_REGIST+EL9_SEQPAG
      For nI := 1 To oModelEJZ:Length()
         oModelEJZ:GoLine(nI)
         //Se deletar um serviço, deve atualizar seu status no processo para "Aguardando Registro no Siscoserv"
         If oModelEJZ:IsDeleted()// .And. (M->EJY_STTSIS == "2" .Or. M->EJY_STTSIS == "3") 
            RS400StaPed(cCont,oModelEJZ:GetValue("EJZ_PROCES"),oModelEJZ:GetValue("EJZ_SEQPRC"),.T.)
            //Este tratamento foi removido pois as parcelas de câmbio agora são geradas pela Invoice (ESSIS400) 
            /*If !(lRet := RS400DelParc(oModelEJZ:GetValue("EJZ_SEQREG")))
               DisarmTransaction()
               Break
            EndIf*/
         EndIf
      Next
      If M->EJY_STTSIS == "2" .Or. M->EJY_STTSIS == "3"
         If SS101PosSeqAnt("EL3", xFilial("EL3")+ EJY->EJY_TPPROC + EJY->EJY_REGIST, {|| EL8->EL8_STATUS == PROCESSADO})
            oDados:AddField("PROC",M->EJY_REGIST)
            SS101DadosRet("REGISTRO",oDados,.F.)
         EndIf   
      Else
         RS400StaReg(cCont,cProc,dDataEnc)
         //RS401StatPg(cCont,cProc)//Atualiza status do pagamento, que pode ser: '1=Em aberto;2=Parcialmente liquidado;3=Liquidado;'
         RS400DtReg(cCont,cProc)  
      EndIf
      If EasyGParam("MV_ESS0027",,9) >= 10
         If SS101PosSeqAnt("EL3", xFilial("EL3")+ EJY->EJY_TPPROC + EJY->EJY_REGIST, {|| EL8->EL8_STATUS == PROCESSADO})
            oDados:AddField("PROC",M->EJY_REGIST)
            SS101DadosRet("RF/RP",oDados)
         EndIf
      EndIf
      //NCF - 07/03/2013 - (ExecAuto Registro) - Inicio do tratamento para exclusão de documentos deletados do registro
      For nI := 1 To oModelEL2:Length()
         oModelEL2:GoLine(nI)
         //Ao encontrar um RE ou uma DI em branco, o Documento e o status for 1 - "Aguardando Registro no Siscoserv", deletará a linha
         //Se o status for diferente disso, grava com o campo em branco, para que não perca o vínculo com a EL7
         If !oModelEL2:IsDeleted() .And. (oModelEL2:GetValue("EL2_STTSIS") == "1" .OR. EasyGParam("MV_ESS0027",,9) >= 10) .And. Empty(oModelEL2:GetValue(cCampo))
            oModelEL2:DeleteLine()
         EndIf
      Next
      If !Empty(M->EJY_DTENC)  // GFP - 13/06/2014
         For nI := 1 To oModelEJZ:Length()
            oModelEJZ:GoLine(nI)
            RS400StaPed(cCont,oModelEJZ:GetValue("EJZ_PROCES"),oModelEJZ:GetValue("EJZ_SEQPRC"),.F.,.T.)
         Next
      EndIf
   Else //Só pode ser uma exclusão                        
      For nI := 1 To oModelEJZ:Length()
         oModelEJZ:GoLine(nI)
         RS400StaPed(cCont,oModelEJZ:GetValue("EJZ_PROCES"),oModelEJZ:GetValue("EJZ_SEQPRC"),.T.)
      Next
   EndIf
EndIf

End Transaction
//RRC - 15/10/2013 - Tratamento para atualizar os Pagamentos/Faturamentos referentes ao RAS/RVS
If (nOperation == MODEL_OPERATION_INSERT .Or. (nOperation == MODEL_OPERATION_UPDATE .AND. EJZ->EJZ_NBS <> cNBS))  // GFP - 16/03/2016
   RS400GeraPgto(cTpReg,cProc)
EndIf   
/*
If !lRet .And. nOperation <> MODEL_OPERATION_DELETE //Quando a operação de exclusão já faz a chamada do ElinkClearId() na função RS400DelReg()
   ELinkClearID() //Grava a ação que não foi concluída com sucesso na EYF (Logviewer)
ElseIf lRet
   RS400GerParc(cCont,EJY->EJY_REGIST, aServicos ) // Gera parcelas dos serviços do registro
EndIf 
*/
RestOrd(aOrd,.T.)  
Return lRet

/*
Programa   : RS400PrxNum()
Objetivo   : Retornar a próxima sequência de Itens do Registro de Serviço ou Documentos a ser utilizada
Parametros : Campo a receber o retorno
Retorno    : cSequen
Autor      : Rafael Ramos Capuano
Data/Hora  : 31/08/2012 15:45 
Revisao    : FSY - 02/12/2013 15:45 
*/

Function RS400PrxNum(cCampo)

Local oModel     := FWModelActive()
Local oModelEJZ  := oModel:GetModel("EJZDETAIL")
Local oModelEL2  := oModel:GetModel("EL2DETAIL")
Local oModelEJX  := oModel:GetModel("EJXDETAIL")
Local oModelUse
Local nOperation := oModel:GetOperation()
Local nPrxSeq    := 1
Local cSequen    := ""
Local cSeqAtu
Default cCampo   := ""

   //Posiciona no última linha dos Itens do Registro de Serviços ou Documentos
   Do Case

      Case cCampo == "EJX_SEQPRC"
         oModelUse := oModelEJX

      Case cCampo == "EJZ_SEQREG"
         oModelUse := oModelEJZ
      
      Case cCampo == "EL2_SEQDOC" 
         oModelUse := oModelEL2
      
      OtherWise
         Return cCampo     
      
   EndCase
    
   If nOperation == 3 .And. oModelUse:nLine == 0
      cSequen := StrZero(nPrxSeq,AvSx3(cCampo,AV_TAMANHO))
   ElseIf oModelUse:nLine <> 0
      oModelUse:GoLine(oModelUse:Length())
      cSeqAtu := oModelUse:GetValue(cCampo)
      nPrxSeq := Val(cSeqAtu)
      nPrxSeq := nPrxSeq + 1
      If Alltrim(Upper(EJW->EJW_ORIGEM)) == "SIGAFAT" .AND. Len(alltrim(cSeqAtu))<> AvSx3(cCampo,AV_TAMANHO) //LRS - 16/07/2015
         cSequen := StrZero(nPrxSeq,Len(alltrim(cSeqAtu)))
      Else
         cSequen := StrZero(nPrxSeq,AvSx3(cCampo,AV_TAMANHO))
      EndIF
   Else
      cSequen := StrZero(nPrxSeq,AvSx3(cCampo,AV_TAMANHO))
   EndIf  

Return cSequen

/*
Programa   : RS400INFO
Objetivo   : Retornar o conteúdo atual requerido, equivalente a variável de memória para grids do mvc
             No grid do MVC, apenas a variável de memória do próprio campo é encontrada, isso durante sua edição
Parametros : Informação a ser pesquisada 
Retorno    : cRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 31/08/2012 15:53 
Revisao    : 
*/

Function RS400Info(cInfo)

Local oModel, oModelEJY, oModelEJZ, oModelEL2
Local cRet    := ""
Local aOrd    := SaveOrd({"EJW","EJX","SB1","EL0","SE4","SYA","SA1","SA2"}) //Guarda índices utilzados na rotina
Default cInfo := ""

If Substr(cInfo,1,3) == "EJY"
   oModel    := FWModelActive()
   oModelEJY := oModel:GetModel("EJYMASTER")
EndIf 

If Substr(cInfo,1,3) == "EJZ"
   oModel    := FWModelActive()
   oModelEJZ := oModel:GetModel("EJZDETAIL")
EndIf

If Substr(cInfo,1,3) == "EL2"
   oModel    := FWModelActive()
   oModelEL2 := oModel:GetModel("EL2DETAIL")
EndIf

Do Case
       
   Case cInfo == "B1_DESC"
      //RRC - 06/08/2013 - Não carregava conteúdo da memória        
      //cRet := Posicione("SB1",1,xFilial("SB1")+AvKey(M->EJZ_ITEM,"B1_COD"),"B1_DESC") 
      oModel    := FWModelActive()
      oModelEJZ := oModel:GetModel("EJZDETAIL")
      cRet := Posicione("SB1",1,xFilial("SB1")+AvKey(oModelEJZ:GetValue("EJZ_ITEM"),"B1_COD"),"B1_DESC") 
     
   Case cInfo == "EL0_DESC"        
      cRet := Posicione("EL0",1,xFilial("EL0")+AvKey(M->EJZ_NBS,"EL0_COD"),"EL0_DESC") 
                                                                                                           
   Case cInfo == "YA_DESCR"        
      cRet := Posicione("SYA",1,xFilial("SYA")+AvKey(M->EJZ_PAIS,"YA_CODGI"),"YA_DESCR")  
      
   Case cInfo == "E4_DESCRI"        
      cRet := Posicione("SE4",1,xFilial("SE4")+AvKey(M->EJZ_CONDPG,"E4_CODIGO"),"E4_DESCRI") 
   
   Case cInfo == "EJY_DSCPAI" //Usado para gatilho do campo EJY_PROCES
      If !Empty(oModelEJY:GetValue("EJY_PAIS"))
         cRet := Posicione("SYA",1,xFilial("SYA")+AvKey(oModelEJY:GetValue("EJY_PAIS"),"YA_CODGI"),"YA_DESCR")                 
      Else
         cRet := ""   
      EndIf
    
   Case cInfo == "EJY_TPPROC" .Or. cInfo == "EJZ_TPPROC"
      If Type("cTpReg") == "C" .And. cTpReg == "V"
         cRet := "V"  
      ElseIf Type ("cTpReg") == "C" .And. cTpReg == "A"
         cRet := "A"
      EndIf   
   
   Case cInfo == "EJY_REGIST"
      cRet := oModelEJY:GetValue("EJY_REGIST")
      
   Case cInfo == "EJY_PROCES"      
      cRet := oModelEJY:GetValue("EJY_PROCES")

   Case cInfo == "EJY_DTENC"
      cRet := oModelEJY:GetValue("EJY_DTENC")

   Case cInfo == "EJZ_QTDE" 
      cRet := oModelEJZ:GetValue("EJZ_QTDE") 
   
   Case cInfo == "EJZ_PRCUN"
      cRet := oModelEJZ:GetValue("EJZ_PRCUN")  
   
   Case cInfo == "EJZ_VL_MOE" 
      cRet := oModelEJZ:GetValue("EJZ_VL_MOE")
        
   Case cInfo == "EJZ_TX_MOE"    
      cRet := oModelEJZ:GetValue("EJZ_TX_MOE")
        
   Case cInfo == "EJZ_VL_REA" 
      cRet := oModelEJZ:GetValue("EJZ_VL_REA")
   
   Case cInfo == "EJZ_PROCES" 
      cRet := oModelEJZ:GetValue("EJZ_PROCES")
      
   Case cInfo == "EJZ_SEQPRC" 
      cRet := oModelEJZ:GetValue("EJZ_SEQPRC")  
      
   Case cInfo == "EJZ_ITEM" 
      cRet := oModelEJZ:GetValue("EJZ_ITEM")     
   
   Case cInfo == "EJZ_DTREG"
      cRet := oModelEJZ:GetValue("EJZ_DTREG")            
   
   Case cInfo == "EJZ_PRAZO"
      cRet := oModelEJZ:GetValue("EJZ_PRAZO")       
   
   Case cInfo == "EJZ_SEQREG"
      cRet := oModelEJZ:GetValue("EJZ_SEQREG")           
   
   Case cInfo == "EJZ_STTSIS"
      cRet := oModelEJZ:GetValue("EJZ_STTSIS")
   
   Case cInfo == "EJZ_DTINI"
      cRet := oModelEJZ:GetValue("EJZ_DTINI")
      
   Case cInfo == "EJZ_TRIG_PRAZO" //Usado na condição do gatilho EJZ_PRAZO
      If !Empty(M->EJZ_PRAZO)
         cRet := M->EJZ_PRAZO-If(Empty(oModelEJZ:GetValue("EJZ_DTREG")),dDatabase,oModelEJZ:GetValue("EJZ_DTREG"))
      Else
         cRet := 0
      EndIf
      
   Case cInfo == "EJZ_TRIG_DTINI" //Usado na condição do gatilho EJZ_DTINI
      If !Empty(M->EJZ_DTINI)
         //cRet := M->EJZ_DTINI + EasyGParam("MV_AVG0225")
         //MFR 02/08/2017 WCC-526892 TE-6334         
         cRet := RS400GetPrazo(M->EJZ_DTINI,.T.)         
      Else
         oModelEJZ:SetValue("EJZ_DIAS",0)
         cRet := CTOD("")
      EndIf   
   Case cInfo == "EL2_SEQREG"
      cRet := Space(AvSx3("EL2_SEQREG",AV_TAMANHO))
   //FSY - 05/12/2013 - Adicionado EL2_DI e EL2_RE
   Case cInfo == "EL2_DI"
      cRet := oModelEL2:GetValue("EL2_DI")
   Case cInfo == "EL2_RE"
      cRet := oModelEL2:GetValue("EL2_RE")
	  
   Case cInfo == "EL2_PROCES"
      cRet := oModelEL2:GetValue("EL2_PROCES")
   
   Case cInfo == "EJY_IMPORT"
      cRet := oModelEJY:GetValue("EJY_IMPORT")
   
   Case cInfo == "EJY_LOJIMP"
      cRet := oModelEJY:GetValue("EJY_LOJIMP")
      
   Case cInfo == "EJY_EXPORT"
      cRet := oModelEJY:GetValue("EJY_EXPORT")

   Case cInfo == "EJY_LOJEXP"
      cRet := oModelEJY:GetValue("EJY_LOJEXP")

EndCase
RestOrd(aOrd,.T.)
Return cRet

/*
Programa   : RS400Valid
Objetivo   : Validação dos campos que fazem parte da Rotina de Registro de Serviços
Parametros : Informação a ser validada
Retorno    : Lógico
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 03/09/2012 10:08 
Revisao    : 
*/

Function RS400Valid(cCampo)
//Local oModel, oModelEJY, oModelEJZ  
Local oModel    
Local oModelEJY
Local oModelEJZ 
Local oModelEL1 
Local oModelEL2
Local oModelEL9 
Local cCont, cCont2//, cCont3
Local lRet      := .T.
Local lStatus   := .T.
Local aOrd      := SaveOrd({"EL1","EJW","EEQ","ELC"})
Local aRows     := {}
Local nCont     := 1
Local cPed
Local cSeqPed
Default cCampo := "" 

oModel    := FWModelActive()
oModelEJY := oModel:GetModel("EJYMASTER")
oModelEJZ := oModel:GetModel("EJZDETAIL")
oModelEL1 := oModel:GetModel("EL1MASTER")
oModelEL2 := oModel:GetModel("EL2DETAIL")
oModelEL9 := oModel:GetModel("EL9MASTER") //RRC - 28/08/2013

Do Case
   Case cCampo == "EJZ_DTPRIN" .Or. cCampo == "EJZ_DTPRFI" 
      //NOPADO por RRC - 14/10/2013 - Somente validar as datas após trocar de linha ou confirmar a ação
      /*cCont  := oModelEJZ:GetValue("EJZ_DTPRIN")
      cCont2 := oModelEJZ:GetValue("EJZ_DTPRFI")
     
      If !Empty(cCont) .And. !Empty(cCont2) .And. cCont > cCont2
         lRet := .F.
         EasyHelp("Data de Previsão Final deve ser maior ou igual a Data de Previsão Inicial.","Aviso")
      EndIf*/   
      
   Case cCampo == "EJZ_DTINI" .Or. cCampo == "EJZ_DTFIM" 
      //oModelEJY := oModel:GetModel("EJYMASTER")
      //NOPADO por RRC - 14/10/2013 - Somente validar as datas após trocar de linha ou confirmar a ação
      //cCont  := oModelEJZ:GetValue("EJZ_DTINI") 
      //cCont2 := oModelEJZ:GetValue("EJZ_DTFIM")
      
      If cCampo == "EJZ_DTINI"
         //AAF 25/04/2013 - Nopado pois a data de inicio não está mais associada a geração de parcelas.
         /*EEQ->(DbSetOrder(1))//EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
         If EEQ->(DbSeek(xFilial("EEQ") + AvKey(RS400Info("EJZ_TPPROC")+RS400Info("EJY_REGIST")+RS400Info("EJZ_SEQREG"),"EEQ_PREEMB") ))
            EasyHelp("A Data Inicial não poderá ser alterada pois já existe parcela de pagamento para este serviço.","Aviso")
            lRet := .F.                        	
         EndIf*/
      EndIf
      //NOPADO por RRC - 14/10/2013 - Somente validar as datas após trocar de linha ou confirmar a ação
      /*If lRet .And. !Empty(cCont) .And. !Empty(cCont2) .And. cCont > cCont2
         lRet := .F.
         EasyHelp("Data Final deve ser maior ou igual a Data Inicial.","Aviso")
      EndIf*/ 
      
      If lRet //Atualizará os valores da data inicial e final do Registro de Serviço
      /*   aRows := FWSaveRows()
         Do While nCont <= oModelEJZ:Length() .And. !lDtIniVaz .And. !lDtFimVaz
            oModelEJZ:GoLine(nCont)
            If !oModelEJZ:IsDeleted() .And. !Empty(RS400Info("EJZ_PROCES")) .And. Empty(oModelEJZ:GetValue("EJZ_DTINI"))
               lDtIniVaz := .T.
            EndIf
            If !oModelEJZ:IsDeleted() .And. !Empty(RS400Info("EJZ_PROCES")) .And. Empty(oModelEJZ:GetValue("EJZ_DTFIM"))
               lDtFimVaz := .T.
            EndIf
            nCont++
         EndDo
         FWRestRows(aRows) //Retorna a linha que estava antes de realizar o loop
         If cCampo == "EJZ_DTINI"
            If Empty(oModelEJZ:GetValue("EJZ_DTINI")) .Or. lDtIniVaz
               oModelEJY:SetValue("EJY_DTINI",CTOD(""))
            ElseIf Empty(oModelEJY:GetValue("EJY_DTINI")) .Or. (!Empty(oModelEJY:GetValue("EJY_DTINI")) .And. oModelEJY:GetValue("EJY_DTINI") > oModelEJZ:GetValue("EJZ_DTINI"))
               oModelEJY:SetValue("EJY_DTINI",oModelEJZ:GetValue("EJZ_DTINI"))         
            EndIf
         EndIf
         If cCampo == "EJZ_DTFIM"
            If Empty(oModelEJZ:GetValue("EJZ_DTFIM")) .Or. lDtFimVaz
               oModelEJY:SetValue("EJY_DTFIM",CTOD(""))  
            ElseIf Empty(oModelEJY:GetValue("EJY_DTFIM")) .Or. (!Empty(oModelEJY:GetValue("EJY_DTFIM")) .And. oModelEJY:GetValue("EJY_DTFIM") < oModelEJZ:GetValue("EJZ_DTFIM"))
               oModelEJY:SetValue("EJY_DTFIM",oModelEJZ:GetValue("EJZ_DTFIM")) 
            EndIf
         EndIf*/
         VerDatas()
      EndIf

   Case cCampo == "EJZ_NBS"
      cCont  := oModelEJZ:GetValue("EJZ_NBS")
      If !(vazio().Or.existcpo("EL0",cCont).And.LEN(ALLTRIM(cCont)) >= LEN(cCont).And.PS400VALNBS(cCont)/*FSY - 13/01/2013 - adicionado PS400VALNBS*/ )
         lRet := .F.
         EasyHelp("Digite N.B.S valido! Selecione um N.B.S sem espaços, não esteja bloqueado e registrado no sistema.","Aviso")
      EndIf
      
   Case cCampo == "EJY_PROCES"// .And. !lRS400Auto
      If Type("cTpReg") == "C"
         If !ExistCpo("EJW",RS400Info("EJY_TPPROC")+AvKey(M->EJY_PROCES,"EJW_PROCES"),1)
            lRet := .F.
         Else
            
            If AvFlags("ESS_EAI")
               EJW->(DBSetOrder(1)) //EJW_FILIAL+EJW_TPPROC+EJW_PROCES
               EJW->(DBSeek(xFilial() + AvKey(RS400Info("EJY_TPPROC"), "EJW_TPPROC") + AvKey(M->EJY_PROCES, "EJW_PROCES")))
               IF EJW->EJW_STTPED == "5"
                  EasyHelp("O processo informado não pode ser usado pois seu status encontra-se como 'Cancelado'.", "Aviso")     
                  lRet:= .F.
               ENDIF
            EndIf

            //RS400AtuReg()
            lOk   := .T.
            aRows := FWSaveRows()
            For nCont := 1 to oModelEJZ:Length()
               oModelEJZ:GoLine(nCont)
               If !oModelEJZ:IsDeleted() .And. !Empty(RS400Info("EJZ_PROCES")) .AND. RS400Info("EJZ_PROCES") <> M->EJY_PROCES
                  lOk  := .F.
                  EXIT
               EndIf
            Next
            FWRestRows(aRows) //Retorna a linha que estava antes de realizar o loop
                        
            //RRC - 26/10/2012 - Verifica o status do Processo escolhido
            If EJW->(DbSeek(xFilial("EJW") + RS400Info("EJY_TPPROC") + AvKey(M->EJY_PROCES,"EJW_PROCES")))  .And. (EJW->EJW_STTPED == "3" .Or. EJW->EJW_STTPED == "4")               
               //A variável lStatus controla se o Processo Base escolhido está em fase de "Aguardando Registro no Siscoserv" ou "Parcialmente registrado"
               lStatus := .F.
               //If If(!lRS400Auto,!MsgYesNo("O Processo Base selecionado possui status '" + BSCXBOX('EJW_STTPED',EJW->EJW_STTPED) + "', portanto seus serviços não serão vinculados a este Processo. Deseja continuar?"),.T.)
               //RRC - 22/05/2013 - A única forma de alterar o Processo Base por execauto é quando o Registro é atualizado automaticamente pelo processo e este sofreu alteração no campo chave: EJW_PROCES
               If If(!lRS400Auto,!MsgYesNo("O Processo Base selecionado possui status '" + BSCXBOX('EJW_STTPED',EJW->EJW_STTPED) + "', portanto seus serviços não serão vinculados a este Processo. Deseja continuar?"),.F.)
                  lRet    := .F.
               EndIf
            EndIf
                
            //If lStatus .And. !lOk .AND. If(Type("lPS400Auto") == "L" .And. !lPS400Auto,!MsgYesNo("Já existem processos associados a este registro. Deseja excluir os itens existentes?"),.T.)
            If lStatus .And. !lOk .AND. If(Type("lRS400Auto") == "U" .Or. !lRS400Auto,!MsgYesNo("Já existem processos associados a este registro. Deseja excluir os itens existentes?"),.F.)
               lRet := .F.
            EndIf                                                      
                       
            If lStatus .And. lRet
               RS400AtuReg(.T.)
            EndIf
            
         EndIf
      EndIf
   
   
    Case cCampo == "EJZ_MODAQU" .Or. cCampo == "EJZ_MODVEN"
      If oModelEJZ:GetValue(cCampo) == "3"
         lRet := .F.
         EasyHelp("Esta opção não é válida para o Siscoserv.","Aviso")     
      EndIf 
      
   Case cCampo == "MV_PROCES" //utilizada para variável de pergunte
      If Type("cTpReg") == "C"
         If !ExistCpo("EJW",RS400Info("EJY_TPPROC")+mv_par01)
            lRet := .F.
         EndIf     
      EndIf

   /*Necessário atualizar os campos totalizadores EJY_VL_MOE  e EJY_VL_REA após alterar EJZ_QTDE, EJZ_TX_MOE e EJZ_PRCUN
   /Ao alterar para o valor zero, os campos EJZ_VL_REA e EJZ_VL_MOE eram atualizados, mas a função de seus valids que 
   atualizam os campos da capa EJY não eram executadas*/         
   Case cCampo == "EJZ_QTDE" .Or. cCampo == "EJZ_PRCUN"
      If cCampo == "EJZ_QTDE"
         cPed    := oModelEJZ:GetValue("EJZ_PROCES")
         cSeqPed := oModelEJZ:GetValue("EJZ_SEQPRC")
         EJX->(DbSetOrder(1))
         EJX->(DbSeek(xFilial("EJX") + AvKey(cTpReg,"EJX_TPPROC") + aVKEY(cPed,"EJX_PROCES") + AvKey(cSeqPed,"EJX_SEQPRC"))) 
         If oModelEJZ:GetValue("EJZ_QTDE") < EJX->EJX_QTDE
            If Type("lRS400Auto") == "U" .Or. !lRS400Auto
               MsgInfo("Atenção: O saldo do item não utilizado não poderá ser utilizado futuramente para outro processo. Quantidade cadastrada = " + alltrim(Str(EJX->EJX_QTDE)))
            EndIf
         Endif
      Endif
      //O campo EJZ_STTPAG foi excluído   
      /*If RS400Info("EJZ_STTPAG") <> "1"    
         If If(Type("lPS400Auto") == "L" .And. !lPS400Auto,MsgYesNo("Este serviço já possui pagamento, deseja realmente alterar o valor?","Aviso"),.T.)
            If Positivo()
               If RS400Info(cCampo) == 0
                  //oModelEJY:= oModel:GetModel("EJYMASTER")
                  oModelEJY:SetValue("EJY_VL_MOE",oModelEJY:GetValue("EJY_VL_MOE")-oModelEJZ:GetValue("EJZ_VL_MOE"))
                  oModelEJY:SetValue("EJY_VL_REA",oModelEJY:GetValue("EJY_VL_REA")-oModelEJZ:GetValue("EJZ_VL_REA"))
               EndIf
            Else
               lRet := .F.
            EndIf
         Else
            lRet := .F.
         EndIf
      Else*/
         If Positivo()
            If RS400Info(cCampo) == 0
               //oModelEJY:= oModel:GetModel("EJYMASTER")
               oModelEJY:SetValue("EJY_VL_MOE",oModelEJY:GetValue("EJY_VL_MOE")-oModelEJZ:GetValue("EJZ_VL_MOE"))
               oModelEJY:SetValue("EJY_VL_REA",oModelEJY:GetValue("EJY_VL_REA")-oModelEJZ:GetValue("EJZ_VL_REA"))
            EndIf
         Else
            lRet := .F.
         EndIf  
      //EndIf      
        
   Case cCampo == "EJZ_TX_MOE"
      //O campo EJZ_STTPAG foi excluído  
      /*If RS400Info("EJZ_STTPAG") <> "1"
         If If(Type("lPS400Auto") == "L" .And. !lPS400Auto,MsgYesNo("Este serviço já possui pagamento, deseja realmente alterar o valor?","Aviso"),.T.)
            If Positivo()
               If RS400Info(cCampo) == 0
                  //oModelEJY:= oModel:GetModel("EJYMASTER")
                  oModelEJY:SetValue("EJY_VL_REA",oModelEJY:GetValue("EJY_VL_REA")-oModelEJZ:GetValue("EJZ_VL_REA"))
               EndIf 
            Else
               lRet := .F.
            EndIf   
         Else
            lRet := .F.
         EndIf
      Else*/
         If Positivo()
            If RS400Info(cCampo) == 0
               //oModelEJY:= oModel:GetModel("EJYMASTER")
               oModelEJY:SetValue("EJY_VL_REA",oModelEJY:GetValue("EJY_VL_REA")-oModelEJZ:GetValue("EJZ_VL_REA"))
            EndIf 
         Else
            lRet := .F.
         EndIf     
      //EndIf
         
   Case cCampo == "EJZ_VL_MOE"
      aValues := aClone(oModel:GetErrorMessage())

	//wfs 24/05/17 - replicado do essps400
      If (Type("lRS400Auto") == "U" .Or. !lRS400Auto) .And. Abs(RS400Info("EJZ_QTDE") * RS400Info("EJZ_PRCUN") - M->EJZ_VL_MOE) > 0.01
         lRet := .F.
         EasyHelp("O valor na moeda deve ser igual a quantidade multiplicado pelo preço unitário.", "Aviso")
      Else

	   If aValues[2] == "EJZ_PRCUN"
            nValor := 0    
         
            //wfs 24/05/17: considerar a existência de N invoices por processo/ item
            EL1->(DBSetOrder(1)) //EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG+EL1_PARC+EL1_SEQPAG
            EL1->(DBSeek(xFilial() + EJY->EJY_TPPROC + EJY->EJY_REGIST + RS400Info("EJZ_SEQREG")))
            While EL1->(!Eof()) .And.;
                  EL1->(EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG) == EL1->(xFilial()) + EJY->EJY_TPPROC + EJY->EJY_REGIST + RS400Info("EJZ_SEQREG")

               //EL9->(DbSetorder(1))
               EL9->(DBSetOrder(3)) //EL9_FILIAL+EL9_TPPROC+EL9_REGIST+EL9_PROCES+EL9_NRINVO+EL9_PARC
               //If EL9->(DbSeek(xFilial("EL9")+AvKey(EJY->EJY_TPPROC,"EL9_TPPROC")+AvKey(EJY->EJY_REGIST,"EL9_REGIST")))  // GFP - 16/03/2016
               If EL9->(DbSeek(xFilial() + EJY->EJY_TPPROC + EJY->EJY_REGIST + EJY->EJY_PROCES + EL1->EL1_NRINVO + EL1->EL1_PARC))
               //Do While EL9->(!Eof()) .And. EL9->(EL9_FILIAL+EL9_TPPROC+EL9_REGIST) == xFilial("EL9")+AvKey(EJY->EJY_TPPROC,"EL9_TPPROC")+AvKey(EJY->EJY_REGIST,"EL9_REGIST")
                  
                  IF EL9->EL9_STTSIS <> '4' //LRS - 22/11/2016
                     nValor += EL9->EL9_VLCAMB
                  EndIF

               EndIf    
               
               //EL9->(DbSkip())
               EL1->(DBSkip())
            EndDo
         
            If RS400Info("EJZ_VL_MOE") < nValor
               lRet := .F.
               EasyHelp("O valor não pode ser menor do que o valor dos "+ If(cTpReg=="A","RPs","RFs") +" já emitidos para este serviço.","Aviso")
            EndIF

         EndIf

         RS400SetDiff("EJY_VL_MOE")
         If RS400Info(cCampo) == 0
            oModelEJY:SetValue("EJY_VL_REA",oModelEJY:GetValue("EJY_VL_REA")-oModelEJZ:GetValue("EJZ_VL_REA"))
         EndIf 

      EndIf

   Case cCampo == "EJZ_VL_REA"

      //wfs 24/05/17 - replicado do essps400
      If (Type("lRS400Auto") == "U" .Or. !lRS400Auto) .And. Abs(RS400Info("EJZ_VL_MOE") * RS400Info("EJZ_TX_MOE") - M->EJZ_VL_REA) > 0.01
         lRet := .F.
         EasyHelp("O valor em reais deve ser igual ao valor da moeda multiplicado pela taxa da moeda.", "Aviso")
      Else
      //O campo EJZ_STTPAG foi excluído  
      /*If RS400Info("EJZ_STTPAG") <> "1"
         If If(Type("lPS400Auto") == "L" .And. !lPS400Auto,MsgYesNo("Este serviço já possui pagamento, deseja realmente alterar o valor?","Aviso"),.T.)
            RS400SetDiff("EJY_VL_REA") 
         Else
            lRet := .F.
         EndIf
      Else*/
         RS400SetDiff("EJY_VL_REA")   
      //EndIf

      EndIf
          
   Case cCampo == "EJY_REGIST"
      If !Empty(M->EJY_REGIST) .And. Type("cTpReg") == "C" .And. !ExistChav("EJY",RS400Info("EJY_TPPROC")+M->EJY_REGIST) 
         lRet := .F.
      EndIf
   
   Case cCampo == "EJZ_SEQPRC"
      If Type("cTpReg") == "C"
         If !ExistCpo("EJX",cTpReg+RS400Info("EJZ_PROCES")+M->EJZ_SEQPRC)
            lRet := .F.
         EndIf
      EndIf                            
    
   Case cCampo == "EJZ_CONDPG"  
      If !Empty(M->EJZ_CONDPG) .And. !ExistCpo("SE4",M->EJZ_CONDPG)         
         lRet := .F.
      EndIf
      If lRet == .T.
         EL1->(DbSetOrder(1))
         /*Utiliza o campo EJY_REGIST pois o campo EJZ_REGIST somente receberá seu conteúdo após o fim do cadastro,
          já que há um relacionamento*/      
         If EL1->(DbSeek(xFilial("EL1")+RS400Info("EJZ_TPPROC")+RS400Info("EJY_REGIST")+RS400Info("EJZ_SEQREG")))
            EasyHelp("A condição de pagamento não poderá ser alterada pois já existe pagamento para este serviço.","Aviso")
            lRet := .F.                        	
         EndIf
      EndIf		
   
   Case cCampo == "EJY_DTINI" .Or. cCampo == "EJY_DTFIM" 
      cCont  := oModelEJY:GetValue("EJY_DTINI") 
      cCont2 := oModelEJY:GetValue("EJY_DTFIM")
      
      If !Empty(cCont) .And. !Empty(cCont2) .And. cCont > cCont2
         lRet := .F.
         EasyHelp("Data Final deve ser maior ou igual a Data Inicial.","Aviso")
      EndIf     
   
   Case cCampo == "EJY_DTENC" 
      If !Empty(M->EJY_DTENC) .And. If(Type("lRS400Auto") == "U" .Or. !lRS400Auto,!MsgYesNo("Se a Data de Encerramento for preenchida, o processo será considerado encerrado, assim, nenhuma modificação poderá ocorrer. Deseja realmente isso?","Aviso"),.F.)
         lRet := .F.
      EndIf
   
   Case cCampo == "EJZ_PRAZO"
      /*                                                      
      cCont  := oModelEJY:GetValue("EJY_PRAZO")
      cCont2 := oModelEJZ:GetValue("EJZ_PRAZO")
      cCont3 := oModelEJZ:GetValue("EJZ_DTREG")
      //Preenche o Prazo da capa do registro com o menor prazo dos serviços
      If Empty(cCont3) .And. !Empty(cCont2) .And. (Empty(cCont) .Or. cCont > cCont2)
         oModelEJY:SetValue("EJY_PRAZO",cCont2)
      EndIf
      */
      VerDatas()
   Case cCampo == "EL2_RE" .Or. cCampo == "EL2_DI"
      If !(EasyGParam("MV_ESS0027",,9) >= 10) .AND. ValType(oModelEJY) == "U" .And. ValType(oModelEL9) == "O" .And. ValType(oModelEL2) == "O"
         If oModelEL9:GetValue("EL9_STTSIS") <> "1"
            lRet := .F.
            EasyHelp("Este documento não pode ser alterado pois o " + If(Type("cTpReg")=="C".And.cTpReg=="V","faturamento","pagamento") + " referente a ele apresenta Status Siscoserv '" + BSCXBOX('EL9_STTSIS',oModelEL9:GetValue("EL9_STTSIS")) + "'.","Aviso")           
         EndIf
      EndIf      
   Case SubStr(cCampo,1,7) == "EJZ_ENQ"
      If !Empty(oModelEJZ:GetValue(cCampo)) .And. (lRet := ExistCpo("ELC",AvKey(oModelEJZ:GetValue(cCampo),"ELC_CODENQ")))
         ELC->(DbSetOrder(1)) //ELC_FILIAL + ELC_CODENQ
         If Type("cTpReg") == "C" .And. cTpReg == "A" .And. ELC->(DbSeek(xFilial("ELC")+(oModelEJZ:GetValue(cCampo)))) .And. !(lRet := ELC->ELC_MODAQU == "S")            
            EasyHelp("Este enquadramento não está disponível para o Módulo de Aquisição","Aviso")
         ElseIf Type("cTpReg") == "C" .And. cTpReg == "V" .And. ELC->(DbSeek(xFilial("ELC")+(oModelEJZ:GetValue(cCampo)))) .And. !(lRet := ELC->ELC_MODVEN == "S")            
            EasyHelp("Este enquadramento não está disponível para o Módulo de Venda","Aviso")
         EndIf   
      EndIf
      
   Case cCampo == "EJY_EXPORT"
      //A validação por ExistCpo() está seperada para que caso esta retorna .F., exiba a mensagem de que o item não existe
      If (lRet := EXISTCPO("SA2",M->EJY_EXPORT)) .AND. !Empty(RS400Info("EJY_LOJEXP")) .And. !IsForeign("SA2", M->EJY_EXPORT+RS400Info("EJY_LOJEXP"))
         lRet := .F.
         EasyHelp("Só é permitido utilizar fornecedor estrangeiro para importação de serviço.","Aviso")
      EndIf
      
      If !Empty(RS400Info("EJY_PROCES")) .AND. !Empty(RS400Info("EJY_LOJEXP")) .AND. M->EJY_EXPORT != EJW->EJW_EXPORT //MCF - 11/08/2016
         lRet := .F.
         EasyHelp("Não é permitido alterar o fornecedor pois o número do processo foi informado","Aviso")
      EndIf
      
      
   Case cCampo == "EJY_LOJEXP"
      If !Vazio()
         //A validação por ExistCpo() está seperada para que caso esta retorna .F., exiba a mensagem de que o item não existe
         If (lRet := EXISTCPO("SA2",M->EJY_EXPORT+M->EJY_LOJEXP)) .AND. !IsForeign("SA2", M->EJY_EXPORT+M->EJY_LOJEXP)
            lRet := .F.
            EasyHelp("Só é permitido utilizar fornecedor estrangeiro para importação de serviço.","Aviso")
         EndIf
         
          If !Empty(RS400Info("EJY_PROCES")) .AND. M->EJY_LOJEXP != EJW->EJW_LOJEXP //MCF - 11/08/2016
            lRet := .F.
            EasyHelp("Não é permitido alterar o fornecedor pois o número do processo foi informado","Aviso")
         EndIf
      EndIf

      /*If EasyGParam("MV_ESS0027",,9) >= 10
         cChave := xFilial("ELM")+AvKey(M->EJY_EXPORT,"ELM_CODFOR")+AvKey(M->EJY_LOJEXP,"ELM_LOJFOR")
         cCampos:= "ELM_FILIAL+ELM_CODFOR+ELM_LOJFOR"
         ELM->(DbSetOrder(2))
         lPosiciona := ELM->(DbSeek(cChave))
         If !lPosiciona
            oModelEJY:SetValue("EJY_TIPVIN","0")
         EndIf
      EndIf*/

   Case cCampo == "EJY_IMPORT"
      //A validação por ExistCpo() está seperada para que caso esta retorna .F., exiba a mensagem de que o item não existe
      If (lRet := EXISTCPO("SA1",M->EJY_IMPORT)) .AND. !Empty(RS400Info("EJY_LOJIMP")) .And. !IsForeign("SA1", M->EJY_IMPORT+RS400Info("EJY_LOJIMP"))
         lRet := .F.
         EasyHelp("Só é permitido utilizar cliente estrangeiro para exportação de serviço.","Aviso")
      EndIf
            
      If !Empty(RS400Info("EJY_PROCES")) .AND. !Empty(RS400Info("EJY_LOJIMP")) .AND. M->EJY_IMPORT != EJW->EJW_IMPORT //MCF - 11/08/2016
         lRet := .F.
         EasyHelp("Não é permitido alterar o cliente pois o número do processo foi informado","Aviso")
      EndIf
            
   Case cCampo == "EJY_LOJIMP"
      If !Vazio()
         //A validação por ExistCpo() está seperada para que caso esta retorna .F., exiba a mensagem de que o item não existe
         If (lRet := EXISTCPO("SA1",M->EJY_IMPORT+M->EJY_LOJIMP)) .And. !IsForeign("SA1", M->EJY_IMPORT+M->EJY_LOJIMP)
            lRet := .F.
            EasyHelp("Só é permitido utilizar cliente estrangeiro para exportação de serviço.","Aviso")
         EndIf
         
         If !Empty(RS400Info("EJY_PROCES")) .AND. M->EJY_LOJIMP != EJW->EJW_LOJIMP //MCF - 11/08/2016
            lRet := .F.
            EasyHelp("Não é permitido alterar o cliente pois o número do processo foi informado","Aviso")
         EndIf
         
      EndIf
      
      /*If EasyGParam("MV_ESS0027",,9) >= 10
         cChave := xFilial("ELM")+AvKey(M->EJY_IMPORT,"ELM_CODCLI")+AvKey(M->EJY_LOJIMP,"ELM_LOJCLI")
         cCampos:= "ELM_FILIAL+ELM_CODCLI+ELM_LOJCLI"
         ELM->(DbSetOrder(3))
         lPosiciona := ELM->(DbSeek(cChave))
         If !lPosiciona
            oModelEJY:SetValue("EJY_TIPVIN","0")
         EndIf
      EndIf*/

   Case cCampo == "EJY_CODEMP"//FSY
      
      If cTpReg == "A"
         
         If !Vazio()
            lRet := EXISTCPO("SA1",M->EJY_CODEMP)
         EndIf
         
      ElseIf cTpReg == "V"
      
         If !Vazio()
            lRet := EXISTCPO("SA2",M->EJY_CODEMP)
         EndIf
      
      EndIf
      
   Case cCampo == "EJY_LOJEMP"//FSY
     
      If cTpReg == "A"
         If !Vazio()
            lRet := EXISTCPO("SA1",M->EJY_CODEMP+M->EJY_LOJEMP)
         EndIf
      
      ElseIf cTpReg == "V"
      
         If !Vazio()
            lRet := EXISTCPO("SA2",M->EJY_CODEMP+M->EJY_LOJEMP)
         EndIf
         
      EndIf
      

EndCase
RestOrd(aOrd,.T.)   
Return lRet   

/*
Programa   : RS400GridVal
Objetivo   : Validação das linhas do Grid - Serviços do Registro
Parametros : 
Retorno    : lRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 03/09/2012 10:27 
Revisao    : 
*/

Function RS400GridVal()
Local oModel,  oModelEJZ, oModelEL2
Local cQtde, cVlMoe, cVlReal, cTxMoe, cPrecUn,  cDtPrFi, cDtPrIn, cDtFim, cDtIni
Local lRet := .T.

   //If Type("lRS400Auto") == "L" .And. !lRS400Auto
      oModel    := FWModelActive()
   //ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
   //   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
   //EndIf

   If ValType(oModel) == "O"   
      oModelEJZ  := oModel:GetModel("EJZDETAIL")
      oModelEL2  := oModel:GetModel("EL2DETAIL") 
      cQtde   := oModelEJZ:GetValue("EJZ_QTDE")
      cVlMoe  := oModelEJZ:GetValue("EJZ_VL_MOE")
      cVlReal := oModelEJZ:GetValue("EJZ_VL_REA")
      cTxMoe  := oModelEJZ:GetValue("EJZ_TX_MOE")
      cPrecUn := oModelEJZ:GetValue("EJZ_PRCUN")
      cDtPrFi := oModelEJZ:GetValue("EJZ_DTPRFI")
      cDtPrIn := oModelEJZ:GetValue("EJZ_DTPRIN")
      cDtFim  := oModelEJZ:GetValue("EJZ_DTFIM")
      cDtIni  := oModelEJZ:GetValue("EJZ_DTINI")   
   
    
   //Valida os valores com tolerência de 1 centavo
   //RRC - 11/10/2013 - Não deve validar diferença de um centavo caso seja chamada de MsExecAuto()
   If !(Type("lRS400Auto") == "L" .And. lRS400Auto) .And. Abs(cQtde * cPrecUn - cVlMoe) > 0.01 // BAK - 01/10/2012 // !((cQtde * cPrecUn == cVlMoe) .Or. (cQtde * cPrecUn == (cVlMoe - 0.01)) .Or. (cQtde * cPrecUn == (cVlMoe + 0.01))) 
      lRet := .F.
      EasyHelp("O valor da moeda deve ser igual a quantidade multiplicado pelo preço unitário, com tolerência de 1 centavo.","Aviso")
   EndIf 
   
   If !(Type("lRS400Auto") == "L" .And. lRS400Auto) .And. Abs(cVlMoe * cTxMoe - cVlReal) > 0.01  // BAK - 01/10/2012 // !((cVlMoe * cTxMoe == cVlReal) .Or. (cVlMoe * cTxMoe == (cVlReal - 0.01)) .Or. (cVlMoe * cTxMoe == (cVlReal + 0.01)))
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
   If EasyGParam("MV_ESS0027",,9) >= 10 .AND. Empty(oModel:GetValue("EJYMASTER","EJY_TIPVIN"))
      oModel:LoadValue("EJYMASTER","EJY_TIPVIN","0") 
   EndIf
   
   EndIf
   
Return lRet

/*
Programa   : RS400LinePre
Objetivo   : Pré-Validação das linhas do Grid - Serviços do Registro
Parametros : oGrid (grid ativo), nLine (linha selecionada), cAction (código da ação realizada)
Retorno    : lRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 25/09/2012 14:29 
Revisao    : 25/10/2013 11:23
*/

Static Function RS400LinePre(oGrid, nLine, cAction)
Local aOrd  := SaveOrd({"EJW","EL4","EL8"})
Local aRows := FWSaveRows()
Local cMsg  := ""  
Local lRet  := .T.

Do Case
   Case oGrid:cId == "EJZDETAIL"
      If cAction == "UNDELETE"//Válido quando tenta recuperar serviço deletado
         EJW->(DbSetOrder(1))
         If EJW->(DbSeek(xFilial("EJW") + RS400Info("EJY_TPPROC") + oGrid:GetValue("EJZ_PROCES")))
            If RS400Info("EJY_TPPROC") == "A" .And. (EJW->EJW_EXPORT <> M->EJY_EXPORT .Or. EJW->EJW_LOJEXP <> M->EJY_LOJEXP)
               lRet := .F. //Verifica se o serviço a ser recuperado, realmente pertence ao Exportador e Loja do Registro atual
            ElseIf RS400Info("EJY_TPPROC") == "V" .And. (EJW->EJW_IMPORT <> M->EJY_IMPORT .Or. EJW->EJW_LOJIMP <> M->EJY_LOJIMP)
               lRet := .F. //Verifica se o serviço a ser recuperado, realmente pertence ao Importador e Loja do Registro atual
            EndIf
            If !lRet   
               If RS400Info("EJY_TPPROC") == "A"
                  EasyHelp("Serviço não pode ser recuperado pois não pertence ao Exportador e Loja utilizados.","Aviso")
                  lRet := .F.
               ElseIf RS400Info("EJY_TPPROC") == "V"
                  EasyHelp("Serviço não pode ser recuperado pois não pertence ao Importador e Loja utilizados.","Aviso")
                  lRet := .F.
               EndIf  
            EndIf   
         EndIf
         If lRet //Atualiza valores da capa
            RS400Trig(oGrid:GetValue("EJZ_VL_MOE"),0,"EJY_VL_MOE")
            RS400Trig(oGrid:GetValue("EJZ_VL_REA"),0,"EJY_VL_REA")
            VerDatas(nLine,cAction)
            FWRestRows(aRows)
         EndIf
      //RRC - 25/10/2013 - Não poderá apagar um serviço que já tenha sido vinculado a um lote
      ElseIf cAction == "DELETE" 
         If oGrid:GetValue("EJZ_STTSIS") <> "1" .Or. !Empty(M->EJY_DTENC)
            cMsg := "Este serviço não pode ser excluído pois apresenta:"
            If oGrid:GetValue("EJZ_STTSIS") <> "1"
               cMsg += " Status Siscoserv '" + BSCXBOX('EJZ_STTSIS',oGrid:GetValue("EJZ_STTSIS")) + "'."
            EndIf
            If !Empty(M->EJY_DTENC)
               cMsg += " Data de Encerramento preenchida."
            EndIf
         Else
            //RRC - 14/10/2013 - Verifica se possui lote vinculado 
            EL4->(DbSetOrder(1)) //EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG+EL4_SQEVIT
            //RRC - 28/11/2013 - Atualização para validar somente se o lote não foi cancelado
            EL8->(DbSetOrder(2)) //EL8_FILIAL+EL8_IDLOTE
            If Type("cTpReg") == "C" .And. EL4->(DbSeek(xFilial("EL4")+cTpReg+M->EJY_REGIST+oGrid:GetValue("EJZ_SEQREG")))
               Do While EL4->(!Eof()) .And. EL4->(EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG) == xFilial("EL4")+cTpReg+M->EJY_REGIST+oGrid:GetValue("EJZ_SEQREG")
                  If EL8->(DbSeek(xFilial("EL8")+EL4->EL4_IDLOTE)) .And. EL8->EL8_STATUS <> "C" .AND. !(EL8->EL8_STATUS == "P" .AND. Empty(EL4->EL4_NROREG)) //AAF 11/01/2017 - Permite estorno dos casos em que foi processado, mas não foi registrado no Siscoserv.
                     cMsg += "Este serviço não pode ser excluído pois está vinculado a um lote não cancelado."
                     Exit
                  EndIf
                  EL4->(DbSkip())   
               EndDo
            EndIf
         EndIf
         If !(lRet := Empty(cMsg))
            EasyHelp(cMsg,"Aviso")
         EndIf
         If lRet //Atualiza valores da capa
            RS400Trig(0,oGrid:GetValue("EJZ_VL_MOE"),"EJY_VL_MOE")
            RS400Trig(0,oGrid:GetValue("EJZ_VL_REA"),"EJY_VL_REA")                   
            VerDatas(nLine,cAction)
            FWRestRows(aRows)
         EndIf
      EndIf
   Case oGrid:cId == "EL2DETAIL" .And. cAction == "DELETE"
      If EasyGParam("MV_ESS0027",,9) >= 10 .AND. !lRS400Auto
         lRet := .F.
         EasyHelp("Os documentos devem ser manipulados através do campo Mov. Temp. presente nos itens do processo","Aviso")
      Else
         If oGrid:GetValue("EL2_STTSIS") <> "1" .Or. !Empty(M->EJY_DTENC)
            cMsg := "Este documento não pode ser excluído pois apresenta:"
            If oGrid:GetValue("EL2_STTSIS") <> "1"
               cMsg += " Status '" + BSCXBOX('EL2_STTSIS',oGrid:GetValue("EL2_STTSIS")) + "'."
            EndIf
            If !Empty(M->EJY_DTENC)
               cMsg += " Data de Encerramento preenchida."
            EndIf
            //RRC - 14/08/2013
            If Type("cTpReg") == "C"
               cMsg += " Se necessário, apague o conteúdo do campo para posterior retificação."   
            EndIf
            If !(lRet := Empty(cMsg))
               EasyHelp(cMsg,"Aviso")
            EndIf
         EndIf
      EndIf
EndCase

RestOrd(aOrd,.T.)
Return lRet 

/*
Programa   : ItemDel(cDetail)
Objetivo   : Chamar a função RS400Trig() para atualizar o valor dos campos EJY_VL_MOE e EJY_VL_REA caso delete ou recupera um item deletado
Parametros : cDetail - Grid aonde a linha foi deletada
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 03/09/2012 14:07 
Revisao    : 
*/
Static Function ItemDel(cDetail)

Local oModel 
Local oModelEJZ  
Local oModelEL2  
Local oView      
Local aOrd       
Local cMsg       := ""
Local oModelEJZ  
Local oModelEL2  
Default cDetail  := ""

//If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oModel    := FWModelActive()
//ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
//   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf

oView      := FWViewActive()
aOrd       := SaveOrd({"EJW","EL4","EL8"})
oModelEJZ  := oModel:GetModel("EJZDETAIL")
oModelEL2  := oModel:GetModel("EL2DETAIL")

//Verifica se a função foi chamado ao deletar uma linha pertencente aos "Serviços" do Registro
//Além disso, verifica se o registro a ser deletado ou recuperado, pertence ao Importador ("Aquisição") ou Exportador("Venda") e a Loja
If cDetail == "EJZDETAIL"
   If oModelEJZ:GetValue("EJZ_STTSIS") <> "1" .Or. !Empty(M->EJY_DTENC)
      cMsg := "Este serviço não pode ser excluído pois apresenta:"
      If oModelEJZ:GetValue("EJZ_STTSIS") <> "1"
         cMsg += " Status Siscoserv '" + BSCXBOX('EJZ_STTSIS',oModelEJZ:GetValue("EJZ_STTSIS")) + "'."
      EndIf
      If !Empty(M->EJY_DTENC)
         cMsg += " Data de Encerramento preenchida."
      EndIf
   Else
      //RRC - 14/10/2013 - Verifica se possui lote vinculado 
      EL4->(DbSetOrder(1)) //EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG+EL4_SQEVIT
      //RRC - 28/11/2013 - Atualização para validar somente se o lote não foi cancelado
      EL8->(DbSetOrder(2)) //EL8_FILIAL+EL8_IDLOTE
      If Type("cTpReg") == "C" .And. EL4->(DbSeek(xFilial("EL4")+cTpReg+M->EJY_REGIST+oModelEJZ:GetValue("EJZ_SEQREG")))
         Do While EL4->(!Eof()) .And. EL4->(EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG) == xFilial("EL4")+cTpReg+M->EJY_REGIST+oModelEJZ:GetValue("EJZ_SEQREG")
            If EL8->(DbSeek(xFilial("EL8")+EL4->EL4_IDLOTE)) .And. EL8->EL8_STATUS <> "C" .AND. !(EL8->EL8_STATUS == "P" .AND. Empty(EL4->EL4_NROREG)) //AAF 11/01/2017 - Permite estorno dos casos em que foi processado, mas não foi registrado no Siscoserv.
               cMsg += "Este serviço não pode ser excluído pois está vinculado a um lote não cancelado."
               Exit
            EndIf
            EL4->(DbSkip())   
         EndDo 
      EndIf     
   EndIf
   If !Empty(cMsg)
      EasyHelp(cMsg,"Aviso")
      If oModelEJZ:IsDeleted()
         If Type("lRS400Auto") == "L" .And. !lRS400Auto      
            oView:GETVIEWOBJ("EJZDETAIL")[3]:Refresh() //Atualiza o objeto
         EndIf
         oModelEJZ:UnDeleteLine()
         RestOrd(aOrd,.T.)
         Return
      EndIf
   EndIf
   EJW->(DbSetOrder(1))                                                       
   If EJW->(DbSeek(xFilial("EJW") + RS400Info("EJY_TPPROC") + AvKey(oModelEJZ:GetValue("EJZ_PROCES"),"EJW_PROCES")))
      If RS400Info("EJY_TPPROC") == "V" //Se deve pesquisar pelo Importador ou Exportador
         If EJW->EJW_IMPORT <> M->EJY_IMPORT .Or. EJW->EJW_LOJIMP <> M->EJY_LOJIMP
            RestOrd(aOrd,.T.)
            Return
         EndIf
      ElseIf RS400Info("EJY_TPPROC") == "A"
         If EJW->EJW_EXPORT <> M->EJY_EXPORT .Or. EJW->EJW_LOJEXP <> M->EJY_LOJEXP
            RestOrd(aOrd,.T.)   
            Return
         EndIf   
      EndIf
      If oModelEJZ:IsDeleted() //Verifica se o serviço está sendo deletado ou recuperado
         RS400Trig(0,oModelEJZ:GetValue("EJZ_VL_MOE"),"EJY_VL_MOE")
         RS400Trig(0,oModelEJZ:GetValue("EJZ_VL_REA"),"EJY_VL_REA")                   
      Else
         RS400Trig(oModelEJZ:GetValue("EJZ_VL_MOE"),0,"EJY_VL_MOE")
         RS400Trig(oModelEJZ:GetValue("EJZ_VL_REA"),0,"EJY_VL_REA")
      EndIf
   EndIf   
Else
   If oModelEL2:GetValue("EL2_STTSIS") <> "1" .Or. !Empty(M->EJY_DTENC)
      cMsg := "Este documento não pode ser excluído pois apresenta:"
      If oModelEL2:GetValue("EL2_STTSIS") <> "1"
         cMsg += " Status '" + BSCXBOX('EL2_STTSIS',oModelEL2:GetValue("EL2_STTSIS")) + "'."
      EndIf
      If !Empty(M->EJY_DTENC)
         cMsg += " Data de Encerramento preenchida."
      EndIf
      //RRC - 14/08/2013
      If Type("cTpReg") == "C"
         cMsg += " Se necessário, apague o conteúdo do campo para posterior retificação."   
      EndIf
      EasyHelp(cMsg,"Aviso")
      If oModelEL2:IsDeleted()
         If Type("lRS400Auto") == "L" .And. !lRS400Auto
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
Programa   : RS400Trig()
Objetivo   : Atualizar o valor de campos caso delete ou recupera um item deletado
Parametros : ValorAtual - Valor do qual será subtraído caso esteja deletando
             ValorAnterior - Valor 
             cDestino - Campo Destino
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 03/08/2012 14:15 
Revisao    : 
*/

Static Function RS400Trig(nValorAtual,nValorAnterior,cDestino)
Local oModel   
Local oModelEJY 
Local oView     

//If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oModel    := FWModelActive()
//ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
//   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf

oModelEJY := oModel:GetModel("EJYMASTER")
oView     := FWViewActive() 

oModelEJY:SetValue(cDestino,oModel:GetValue("EJYMASTER",cDestino)+nValorAtual-nValorAnterior)
//oView:Refresh()
//oView:updategets()
If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oView:GETVIEWOBJ("EJYMASTER")[3]:Refresh()
EndIf

Return


Function RS400SetDiff(cDestino)
Local oModel    := FWModelActive()
Local aErrMsg   := oModel:GetErrorMessage() 

If Valtype(aErrMsg[8]) == AvSx3(cDestino,AV_TIPO) .And. Valtype(aErrMsg[9]) == AvSx3(cDestino,AV_TIPO)
   //Atualiza conteúdo de campo de Processo de Serviços
   oModel:SetValue("EJYMASTER",cDestino,oModel:GetValue("EJYMASTER",cDestino)+aErrMsg[8]-aErrMsg[9])
EndIf
/*
Local oModel
Local aErrMsg   

If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oModel    := FWModelActive()
ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
EndIf

If ValType(oModel) == "O"
   aErrMsg   := oModel:GetErrorMessage()
EndIf

If Valtype(aErrMsg[8]) == AvSx3(cDestino,AV_TIPO) .And. Valtype(aErrMsg[9]) == AvSx3(cDestino,AV_TIPO)
   //Atualiza conteúdo de campo de Registro de Serviços
   oModel:SetValue("EJYMASTER",cDestino,oModel:GetValue("EJYMASTER",cDestino)+aErrMsg[8]-aErrMsg[9])
EndIf
*/
Return .T.  

/*
Programa   : RS400Relacao()
Objetivo   : Iniciar o conteúdo dos campos especificados, X3_RELACAO
Parametros : cCampo
Retorno    : cRet
Autor      : Rafael Ramos Capuano
Data/Hora  : 28/08/2012 12:29 
Revisao    : 
*/

Function RS400Relacao(cCampo)
Local cRet      := ""
Local aOrd      := SaveOrd({"SB1","EL0","SYA","SE4"})
Local oModel    

//Local oModelEJY := oModel:GetModel("EJYMASTER")
Local oModelEJZ   
Default cCampo  := ""

//If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oModel    := FWModelActive()
//ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
//   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf 

//If ValType(oModel) == "O"
   oModelEJZ := oModel:GetModel("EJZDETAIL")
//EndIf

Do Case   
   Case cCampo == "EJY_DTPROC"// .And. ValType(oModelEJZ) == "O"
   //If Type("lRS400Auto") == "L" .And. !lRS400Auto
      cRet := dDataBase 
   //EndIf
   Case cCampo == "EJY_DSCPAI"// .And. ValType(oModelEJZ) == "O"
      If /*Type("lRS400Auto") == "L" .And. !lRS400Auto .And.*/ oModel:GetOperation() <> 3
         cRet := Posicione("SYA",1,xFilial("SYA")+AvKey(EJY->EJY_PAIS,"YA_CODGI"),"YA_DESCR") 
      EndIf 
   
   Case cCampo == "EJY_DIAS"
      //If Type("lRS400Auto") == "L" .And. !lRS400Auto
         If !Empty(M->EJY_PRAZO)
            cRet := M->EJY_PRAZO-If(Empty(M->EJY_DTREG),dDatabase,M->EJY_DTREG)
         Else
            cRet := 0
         EndIf  
      //EndIf
   
   Case cCampo == "EJY_STTSIS" .Or. cCampo == "EJZ_STTSIS" .Or. cCampo == "EL2_STTSIS"
      //If Type("lRS400Auto") == "L" .And. !lRS400Auto
         cRet := "1"
      //EndIf
        //Inicializa campos com combo
   
   Case cCampo == "EJZ_DIAS" .And. ValType(oModelEJZ) == "O"
      If /*Type("lRS400Auto") == "L" .And. !lRS400Auto .And.*/ oModel:GetOperation() <> 3 .And. oModelEJZ:nLine == 0
         If !Empty(EJZ->EJZ_PRAZO)
            cRet := EJZ->EJZ_PRAZO-If(Empty(EJZ->EJZ_DTREG),dDatabase,EJZ->EJZ_DTREG)         
         EndIf
      //Caso seja inclusão, já é inicializado como zero, durante a inclusão dos dados, existe um gatilho para preenchê-lo através do campo EJZ->EJZ_PRAZO
      EndIf
      
   Case cCampo == "EJZ_DSCITE" .And. ValType(oModelEJZ) == "O"
      If /*Type("lRS400Auto") == "L" .And. !lRS400Auto .And.*/ oModel:GetOperation() <> 3 .And. oModelEJZ:nLine == 0
         cRet := Posicione("SB1",1,xFilial("SB1")+AvKey(EJZ->EJZ_ITEM,"B1_COD"),"B1_DESC") 
      EndIf
   
   Case cCampo == "EJZ_DSCNBS" .And. ValType(oModelEJZ) == "O"
      If /*Type("lRS400Auto") == "L" .And. !lRS400Auto .And.*/ oModel:GetOperation() <> 3 .And. oModelEJZ:nLine == 0
         cRet := Posicione("EL0",1,xFilial("EL0")+AvKey(EJZ->EJZ_NBS,"EL0_COD"),"EL0_DESC") 
      EndIf  
   
   Case cCampo == "EJZ_DSCPAI" .And. ValType(oModelEJZ) == "O"
      If /*Type("lRS400Auto") == "L" .And. !lRS400Auto .And.*/ oModel:GetOperation() <> 3 .And. oModelEJZ:nLine == 0
         cRet := Posicione("SYA",1,xFilial("SYA")+AvKey(EJZ->EJZ_PAIS,"YA_CODGI"),"YA_DESCR") 
      EndIf 
      
   Case cCampo == "EJZ_DSCCON" .And. ValType(oModelEJZ) == "O"
      If /*Type("lRS400Auto") == "L" .And. !lRS400Auto .And.*/ oModel:GetOperation() <> 3 .And. oModelEJZ:nLine == 0
         cRet := Posicione("SE4",1,xFilial("SE4")+AvKey(EJZ->EJZ_CONDPG,"E4_CODIGO"),"E4_DESCRI") 
      EndIf 
    
    Case (cCampo == "EJZ_MODAQU" .Or. cCampo == "EJZ_MODVEN") .And. ValType(oModelEJZ) == "O"
      If /*Type("lRS400Auto") == "L" .And. !lRS400Auto .And.*/ oModel:GetOperation() <> 3 .And. oModelEJZ:nLine == 0
         cRet := EJZ->EJZ_MODO
      EndIf
    Case cCampo == "EJZ_DTPRFI"
       cRet := CToD("31/12/"+AllTrim(Str(Year(dDataBase)))) 
       
    Case cCampo == "EJY_DSCEMP"
      If cTpReg == "A"
         cRet := Posicione("SA1",1,xFilial("SA1")+M->EJY_CODEMP+M->EJY_LOJEMP,"A1_NOME")
      ElseIf cTpReg == "V"
         cRet := Posicione("SA2",1,xFilial("SA2")+M->EJY_CODEMP+M->EJY_LOJEMP,"A2_NOME")
      End If
      
EndCase
RestOrd(aOrd,.T.)
Return cRet

/*
Programa   : SelecPed()
Objetivo   :
Parâmetros : oModel: Modelo ativo 
Retorno    : Nil
Autores    : Rafael Ramos Capuano - RRC 
Data/Hora  : 04/09/2012 14:09 
*/
Static Function SelecPed(oModel)

Local oBrowse
Local cEmpr     := ""
Local cLoja     := ""
Local cProc     := ""
Local cQuery    := ""
Local nLin
Local nPos
Local bOk       :={|| RestOrd(aOrd,.T.),ItensSel(aItens),oDlg:End()}
Local bCancel   :={|| oDlg:End()}
Local bMarca    :={|| If((nPos := aScan(aItens,TEMP->(Recno())))==0,Aadd(aItens,TEMP->(Recno())),(aDel(aItens,nPos),aSize(aItens,Len(aItens)-1)))}
Local bMarcaTds :={|oBrowse| If(!Empty(aItens),aItens:={},aItens := GetAllItens()),oBrowse:Refresh(.T.)}
Local aOrd      := SaveOrd({"EJW","EJX"}) //Guarda índices das tabelas utilizadas
Local aCampos   := GetCampos()
Local aItens    := {}                    
Local aInd      := {"EJX_FILIAL+EJX_TPPROC+EJX_PROCES+EJX_SEQPRC"}//FSY-24/12/2013

If oModel:GetOperation() <> 3 .And. oModel:GetOperation() <> 4
   EasyHelp("Este botão somente poderá ser utilizado nas rotinas de inclusão ou alteração.","Aviso")
   Return
EndIf

If !Empty(oModel:GetValue("EJYMASTER", "EJY_DTENC"))
   EasyHelp("Este registro foi encerrado e não poderá sofrer alterações.","Aviso")
   Return	  
EndIf

If Type("cTpReg") == "C"
   If cTpReg == "V"
      cEmpr := oModel:GetValue("EJYMASTER", "EJY_IMPORT")
      cLoja := oModel:GetValue("EJYMASTER", "EJY_LOJIMP")
   ElseIf cTpReg == "A"
      cEmpr := oModel:GetValue("EJYMASTER", "EJY_EXPORT")
      cLoja := oModel:GetValue("EJYMASTER", "EJY_LOJEXP")
   EndIf

   If Empty(oModel:GetValue("EJYMASTER", "EJY_REGIST"))
      EasyHelp("É necessário informar o Número do Registro.","Aviso")
      Return 
   EndIf
   
   If Empty(oModel:GetValue("EJYMASTER", "EJY_PROCES"))
      EasyHelp("É necessário informar o Processo Base.","Aviso")
      Return 
   EndIf
     
   If (Empty(cEmpr) .Or. Empty(cLoja)).And. cTpReg == "V"
      EasyHelp("É necessário informar o Importador e a Loja.","Aviso")
      Return
   ElseIf (Empty(cEmpr) .Or. Empty(cLoja)) .And. cTpReg == "A"
      EasyHelp("É necessário informar o Exportador e a Loja.","Aviso")
      Return
   EndIf
      
   If Pergunte("ESSRS001",.T.)
      //Cria a query para filtrar os Processos a serem exibidos
      cQuery := CriaQry(oModel)   
      
      If Select("TEMP") > 0 
         TEMP->(DbCloseArea())
      EndIf 
      
      Private oModelEJZ := oModel:GetModel("EJZDETAIL")
      EasyWkQuery(cQuery,"TEMP",aInd,,{|cWork| !(cWork)->(oModelEJZ:SeekLine({{"EJZ_PROCES",EJX_PROCES},{"EJZ_SEQPRC",EJX_SEQPRC}}))})
      
      If !TEMP->(EOF().And.BOF())
         DEFINE MSDIALOG oDlg TITLE "Seleção de Processos" FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL              
            DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TEMP" OF oDlg                                               
	           ADD MARKCOLUMN oColumn DATA {||If(aScan(aItens,TEMP->(Recno()))==0,'LBNO','LBOK')} DOUBLECLICK bMarca HEADERCLICK bMarcaTds OF oBrowse
		       For nLin := 1 To Len(aCampos) 
		          If aCampos[nLin][2] <> "V"
		             If Alltrim(Upper(aCampos[nLin][1])) == "EJX_MODO"   
		                ADD COLUMN oColumn DATA &("{ || BSCXBOX('EJX_MODO',"+aCampos[nLin][1]+") }") TITLE AvSx3(aCampos[nLin][1], AV_TITULO) SIZE 50 OF oBrowse 
		              Else
		                ADD COLUMN oColumn DATA &("{ ||" + aCampos[nLin][1] + " }") TITLE AvSx3(aCampos[nLin][1], AV_TITULO) SIZE AvSx3(aCampos[nLin][1], AV_TAMANHO) OF oBrowse 
		             EndIf
		          Else         
		             ADD COLUMN oColumn DATA &("{ ||" + CriaVar(aCampos[nLin][1]) + " }") TITLE AvSx3(aCampos[nLin][1], AV_TITULO) SIZE AvSx3(aCampos[nLin][1], AV_TITULO) OF oBrowse
		          EndIf                                                  
		       Next
		      	
		      	//bAction:= {|oSeek| Ps400Seek(cTpReg, AllTrim(Upper(oSeek:cSeek)),1,oBrowse)}
              aOrder:= {{"Processo + Seq. Processo", {{"", "C", TamSx3("EJX_PROCES")[1], 0, "Processo",,},{"", "C", TamSx3("EJX_SEQPRC")[1], 0, "Seq. Processo",,}}, 1}} 
              oBrowse:SetSeek(/*bAction*/,aOrder) //MCF - 27/11/2015
		      		
	        ACTIVATE FWBROWSE oBrowse
	           
	         If ValType(oBrowse:oBrowseUI:oFWSeek) == "O"    //verifica se é objeto //MCF - 27/11/2015
	            //oBrowse:oBrowseUI:oFWSeek:aDefaultOrder := {} //Limpa o objeto mascara da pesquisa
	            //oBrowse:oBrowseUI:oFWSeek:aOrder := {"Processo+Seq. Processo"} //Vetor da mascara
	            //oBrowse:oBrowseUI:oFWSeek:aDefaultOrder := {{"EJX_PROCES+EJX_SEQPRC"}} //Chave para a pesquisa
	            oBrowse:oBrowseUI:oFWSeek:SetAction({|cSeek,nOrder| Ps400Seek(cTpReg, AllTrim(Upper(cSeek)),nOrder,oBrowse)}) //Entra na função quando clicar em pesquisar
	            oBrowse:Refresh()
	         EndIf
            
            oDlg:lMaximized := .T.
         ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) CENTERED      
         TEMP->(DbCloseArea())
      Else
         EasyHelp("Não foram encontrados Processos para os dados informados.","Aviso")    
      EndIf      
   EndIf
EndIf
Return Nil

/*
Programa   : CriaQry()
Objetivo   : Criar query para buscar os Itens de Processo de Serviço
Parametros : cQuery: Variável a receber a query. oModel: Modelo ativo
Retorno    : cQuery
Autores    : Rafael Ramos Capuano - RRC 
Data/Hora  : 04/09/2012 14:09
Revisão
*/

Static Function CriaQry(oModel)
Local cEmpr   := ""
Local cMoeda  := ""
//Local cRelac  := ""
//Local cCond   := ""
//Local cItens  := ""
Local cLoja   := ""

If Type("cTpReg") == "C"
   cProcesso := oModel:GetValue("EJYMASTER", "EJY_REGIST")
   If cTpReg == "V"
      cEmpr  := oModel:GetValue("EJYMASTER", "EJY_IMPORT")
      cLoja  := oModel:GetValue("EJYMASTER", "EJY_LOJIMP")
   ElseIf cTpReg == "A"     
      cEmpr  := oModel:GetValue("EJYMASTER", "EJY_EXPORT")
      cLoja  := oModel:GetValue("EJYMASTER", "EJY_LOJEXP")
   EndIf
   cMoeda    := oModel:GetValue("EJYMASTER", "EJY_MOEDA" )
EndIf

Begin Sequence 
 
   /*
   cRelac := " EJX INNER JOIN  ( SELECT DISTINCT EJW.EJW_FILIAL, EJW.EJW_TPPROC, EJW.EJW_PROCES  FROM " +RetSqlName("EJW")+" EJW"
   
   //Caso seja 'Aquisição', o exportador será informado, caso seja 'Venda', o importador será informado
   //Um dos dois campos estará preenchido  
   If Type("cTpReg") == "C"   
      If cTpReg == "V"
         cRelac += " WHERE EJW.EJW_IMPORT = '"+cEmpr+"' AND EJW.EJW_LOJIMP = '"+cLoja+"'"
      ElseIf cTpReg == "A"     
         cRelac += " WHERE EJW.EJW_EXPORT = '"+cEmpr+"' AND EJW.EJW_LOJEXP = '"+cLoja+"'" 
      EndIf
   EndIf 
   
   If !Empty(cMoeda)
      cRelac += " AND EJW.EJW_MOEDA = '"+cMoeda+"'"
   EndIf
   
   //Filtra pelo Processo    
   If !Empty(mv_par01)
      cRelac += " AND EJW.EJW_PROCES = '"+mv_par01+"'
   EndIf
   cRelac += " AND EJW.D_E_L_E_T_ <> '*')  A ON A.EJW_FILIAL = EJX_FILIAL AND A.EJW_TPPROC = EJX.EJX_TPPROC AND A.EJW_PROCES = EJX.EJX_PROCES AND  EJX.D_E_L_E_T_ <> '*'"  
   
   cItens := ContItens()
   //Verifica se o item já pertence ao grid dos Serviços
   If !Empty(cItens)
      cCond := " WHERE EJX.EJX_PROCES+EJX.EJX_SEQPRC NOT IN('"+cItens+"') AND EJX.EJX_STTPED = '1'"
      //Filtra pelo Código NBS   
      If !Empty(mv_par02)
         cCond += " AND EJX.EJX_NBS = '"+mv_par02+"'"
      EndIf  
   Else
      cCond := " WHERE EJX.EJX_STTPED = '1'" 
      If !Empty(mv_par02)
         cCond += " AND EJX.EJX_NBS = '"+mv_par02+"'"
      EndIf  
   EndIf
   cQuery := "SELECT EJX.*, (SELECT YA_DESCR FROM "+RetSqlName("SYA")+" WHERE YA_CODGI = EJX_PAIS) AS EJX_DSCPAI FROM "+RetSqlName("EJX")+cRelac+cCond
   */

   cSelect := "SELECT EJX.*, "
   cSelect += "(SELECT YA_DESCR FROM "+RetSqlName("SYA")+" WHERE YA_CODGI = EJX_PAIS) AS EJX_DSCPAI "
   
   //Relaciona capa do processo, item do processo e item do registro
   cFrom   := "FROM "+RetSqlName("EJW")+" EJW INNER JOIN "+RetSqlName("EJX")+" EJX ON "
   cFrom   += "EJW.EJW_FILIAL = EJX.EJX_FILIAL AND EJW.EJW_TPPROC = EJX.EJX_TPPROC AND EJW.EJW_PROCES = EJX.EJX_PROCES "
   cFrom   += "LEFT OUTER JOIN "+RetSqlName("EJZ")+" EJZ ON "
   cFrom   += "EJZ.EJZ_FILIAL = EJX.EJX_FILIAL AND EJZ.EJZ_TPPROC = EJX.EJX_TPPROC AND EJZ.EJZ_PROCES = EJX.EJX_PROCES AND EJZ.EJZ_SEQPRC = EJX.EJX_SEQPRC AND EJZ.D_E_L_E_T_ = '' "
   cFrom   += "AND EJZ.EJZ_REGIST <> '"+cProcesso+"' "
   
   //Filtro para não trazer serviços de processos já utilizados outros registros
   cWhere  := "WHERE EJX.D_E_L_E_T_ = '' AND EJW.D_E_L_E_T_ = '' AND EJZ.EJZ_PROCES IS NULL "
   cWhere  += "AND EJW.EJW_FILIAL = '"+xFilial("EJW")+"' "
   
   //Filtro por importador/exportador
   If cTpReg == "V"
      cWhere += "AND EJW.EJW_IMPORT = '"+cEmpr+"' AND EJW.EJW_LOJIMP = '"+cLoja+"' "
   ElseIf cTpReg == "A"     
      cWhere += "AND EJW.EJW_EXPORT = '"+cEmpr+"' AND EJW.EJW_LOJEXP = '"+cLoja+"' " 
   EndIf
   
   //Filtro por Moeda
   If !Empty(cMoeda)
      cWhere += "AND EJW.EJW_MOEDA = '"+cMoeda+"' "
   EndIf
   
   //Filtra por Processo
   If !Empty(mv_par01)
      cWhere += "AND EJW.EJW_PROCES = '"+mv_par01+"' "
   EndIf
   
   //Filtra pelo Código NBS
   If !Empty(mv_par02)
      cWhere += "AND EJX.EJX_NBS = '"+mv_par02+"' "
   EndIf
   //RRC - 10/10/2013 - Não poderão ser registrados no SISCOSERV serviços que ainda não foram iniciados
   cWhere += "AND EJX.EJX_DTINI <= '"+DTOS(dDataBase)+"' "
   
   cQuery := ChangeQuery(cSelect + cFrom + cWhere)
   
End Sequence

Return cQuery

/*
Programa   : GetCampos()
Objetivo   : Adicionar os campos a serem exibidos para a "Seleção dos Processos"
Retorno    : aClone(aCampos)
Autores    : Rafael Ramos Capuano - RRC 
Data/Hora  : 05/09/2012 09:24
Revisão
*/

Static Function GetCampos()
Local aCampos :={}
Local aOrd    := SaveOrd({"SX3"})
DbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("EJX"))

Do While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "EJX"
   If "_PROCES" $ SX3->X3_CAMPO .Or. "_SEQPRC" $ SX3->X3_CAMPO .Or. "_ITEM" $ SX3->X3_CAMPO .Or.;
   "_NBS" $ SX3->X3_CAMPO .Or. "_MODO" $ SX3->X3_CAMPO .Or. "_DSCPAI" $ SX3->X3_CAMPO .Or. "_DTINI";
   $ SX3->X3_CAMPO .Or. "_DTFIM" $ SX3->X3_CAMPO .Or. "_VL_MOE" $ SX3->X3_CAMPO .Or. "_VL_REA" $ SX3->X3_CAMPO    
      Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_CONTEXT})
   EndIf
   SX3->(dbSkip())
EndDo

RestOrd(aOrd,.T.)
Return aClone(aCampos)

/*
Programa   : GetAllItens()
Objetivo   : Adicionar todos os itens do Processo de Serviços em um array para retornar ao grid em "Registro de Serviços"
Retorno    : aClone(aAllItens)
Autores    : Rafael Ramos Capuano - RRC 
Data/Hora  : 10/09/2012 14:42
Revisão
*/

Function GetAllItens()
Local nRec := TEMP->(Recno())
Local aAllItens := {}

TEMP->(DbGoTop())
Do While !TEMP->(Eof())
   Aadd(aAllItens,TEMP->(Recno()))
   TEMP->(DbSkip())
EndDo
TEMP->(DbGoTo(nRec))

Return aClone(aAllItens)

/*
Programa   : ItensSel()
Objetivo   : Retorna para o grid em "Registro de Serviços" todos os itens selecionados
Retorno    : Nil
Autores    : Rafael Ramos Capuano - RRC 
Data/Hora  : 10/09/2012 15:18
Revisão
*/
Static Function ItensSel(aItens)

Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oModelEJZ := oModel:GetModel("EJZDETAIL")
Local oModelEL2 := oModel:GetModel("EL2DETAIL")
Local nCont

//If Type("lRS400Auto") == "L" .And. !lRS400Auto
//   oModel    := FWModelActive()
//ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
//   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf

If !Empty(aItens)
   TEMP->(DbGoTop())
   For nCont := 1 To Len(aItens)   
      TEMP->(DbGoTo(aItens[nCont]))
      If !Empty(RS400Info("EJZ_PROCES"))
         ForceAddLine(oModelEJZ)
      EndIf
      oModelEJZ:SetValue("EJZ_PROCES",TEMP->EJX_PROCES)
      oModelEJZ:SetValue("EJZ_SEQPRC",TEMP->EJX_SEQPRC)
      oModelEJZ:SetValue("EJZ_ITEM"  ,TEMP->EJX_ITEM  )
      oModelEJZ:SetValue("EJZ_NBS"   ,TEMP->EJX_NBS   )
      If RS400Info("EJY_TPPROC") == "V"
         oModelEJZ:SetValue("EJZ_MODVEN",TEMP->EJX_MODO)
      ElseIf RS400Info("EJY_TPPROC") == "A"
         oModelEJZ:SetValue("EJZ_MODAQU",TEMP->EJX_MODO)
      EndIf
      oModelEJZ:SetValue("EJZ_PAIS"  ,TEMP->EJX_PAIS  )
      oModelEJZ:SetValue("EJZ_DTPRIN",TEMP->EJX_DTPRIN)
      oModelEJZ:SetValue("EJZ_DTPRFI",TEMP->EJX_DTPRFI)      
      oModelEJZ:SetValue("EJZ_DTINI" ,TEMP->EJX_DTINI )
      oModelEJZ:SetValue("EJZ_DTFIM" ,TEMP->EJX_DTFIM )
      //oModelEJZ:SetValue("EJZ_CONDPG",TEMP->EJX_CONDPG)  
      oModelEJZ:SetValue("EJZ_QTDE"  ,TEMP->EJX_QTDE  )
      oModelEJZ:SetValue("EJZ_PRCUN" ,TEMP->EJX_PRCUN )
      oModelEJZ:SetValue("EJZ_VL_MOE",TEMP->EJX_VL_MOE)
      oModelEJZ:SetValue("EJZ_TX_MOE",TEMP->EJX_TX_MOE)
      oModelEJZ:SetValue("EJZ_VL_REA",TEMP->EJX_VL_REA) 
      //oModelEJZ:SetValue("EJZ_COMPL" ,TEMP->EJX_COMPL)
      oModelEJZ:SetValue("EJZ_ENQ01" ,TEMP->EJX_ENQ01 )
      oModelEJZ:SetValue("EJZ_RC01"  ,TEMP->EJX_RC01  )
      oModelEJZ:SetValue("EJZ_ENQ02" ,TEMP->EJX_ENQ02 )
      oModelEJZ:SetValue("EJZ_RC02"  ,TEMP->EJX_RC02  )
      oModelEJZ:SetValue("EJZ_ENQ03" ,TEMP->EJX_ENQ03 )
      oModelEJZ:SetValue("EJZ_RC03"  ,TEMP->EJX_RC03  )
      
   Next
     
   EL2->(DbSetOrder(2))//'EL2_FILIAL+EL2_TPPROC+EL2_PROCES+EL2_SEQDOC'
   If EL2->(DbSeek(xFilial("EL2")+RS400Info("EJY_TPPROC")+TEMP->EJX_PROCES))
      Do While EL2->(!EOF()) .And. xFilial("EL2") == EL2->EL2_FILIAL .And. RS400Info("EJY_TPPROC") == EL2->EL2_TPPROC .And. TEMP->EJX_PROCES == EL2->EL2_PROCES
         Do Case     
            Case cTpReg == "A"
               If !Empty(RS400Info("EL2_DI"))
                  ForceAddLine(oModelEL2)
               End If
               oModelEL2:SetValue("EL2_DI",EL2->EL2_DI)
        
            Case cTpReg == "V"    
               If !Empty(RS400Info("EL2_RE"))
                  ForceAddLine(oModelEL2)
               End If
               oModelEL2:SetValue("EL2_RE",EL2->EL2_RE)
        
         End Case
        
         oModelEL2:SetValue("EL2_STTSIS" ,EL2->EL2_STTSIS)
         EL2->(DbSkip())
      EndDo
   EndIf
   
   AtuTotais()
   VerDatas()
   If Type("lRS400Auto") == "L" .And. !lRS400Auto
      oView:GETVIEWOBJ("EJYMASTER")[3]:Refresh()
   EndIf   
   oModelEJZ:GoLine(1)
EndIf
 
Return

/*
Programa   : ContItens()
Objetivo   : Concatena os processos e a sequência dos mesmos em uma string, esta string fará parte da condição da query
             criada ao clicar em "Seleção de Processos" que exibirá apenas os registros que ainda não fazem parte do Grid
Retorno    : cItens
Autores    : Rafael Ramos Capuano - RRC 
Data/Hora  : 11/09/2012 13:17
Revisão
*/

Static Function AtuTotais()
//Local cItens := ""
Local nCont
Local oModel    := FWModelActive()
Local oModelEJZ := oModel:GetModel("EJZDETAIL")
Local nTotMOE   := 0
Local nTotREA   := 0

//If Type("lRS400Auto") == "L" .And. !lRS400Auto
//   oModel    := FWModelActive()
//ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
//   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf

For nCont := 1 To oModelEJZ:Length()
   oModelEJZ:GoLine(nCont)
   If !Empty(oModelEJZ:GetValue("EJZ_PROCES")) .And. !Empty(oModelEJZ:GetValue("EJZ_SEQPRC")) .And. !oModelEJZ:IsDeleted()
      nTotMOE += oModelEJZ:GetValue("EJZ_VL_MOE")
      nTotREA += oModelEJZ:GetValue("EJZ_VL_REA")
   EndIf
Next

oModel:SetValue("EJYMASTER","EJY_VL_MOE",nTotMOE)
oModel:SetValue("EJYMASTER","EJY_VL_REA",nTotREA)

Return Nil

/*
Programa   : RS400AtuReg()
Objetivo   : Permite ao usuário a opção de já preencher o grid pertencente ao Registro de Serviços com todos os Serviços
             cadastrados relacionados a este Processo. 
Retorno    : Conteúdo atual do campo EJY_PROCES
Autores    : Rafael Ramos Capuano - RRC 
Data/Hora  : 17/09/2012 10:19
Revisão    : Fabio Satoru Yamamoto - FSY - 09/12/2013
*/
Function RS400AtuReg(lExclui)
Local oModel    := FWModelActive()
Local oModelEJY := oModel:GetModel("EJYMASTER") 
Local oModelEJZ := oModel:GetModel("EJZDETAIL")
Local oModelEL2 := oModel:GetModel("EL2DETAIL")
Local oView     := FWViewActive() 
Local aOrd      := SaveOrd({"EJZ","EJX","EJY","EJW"}) //Guarda índices da capa e da origem dos campos cujos conteúdos serão retornados ao grid
Local nCont
Local lMsg      := .F.
Default lExclui := .F.

//Esta função é chamada dentro da RS400Valid() para deletar os serviços anteriores, posteriormente é chamada no gatilho do campo EJY_PROCES para adicionar os novos serviços
If EJW->(DbSeek(xFilial("EJW") + RS400Info("EJY_TPPROC") + AvKey(M->EJY_PROCES,"EJW_PROCES"))) .And. (EJW->EJW_STTPED == "1" .Or. EJW->EJW_STTPED == "2")  
   If lExclui
      
      For nCont := 1 to oModelEJZ:Length()
         oModelEJZ:GoLine(nCont)
         If !oModelEJZ:IsDeleted() .And. !Empty(RS400Info("EJZ_PROCES"))
            oModelEJZ:DeleteLine()
         EndIf
      Next

      For nCont := 1 to oModelEL2:Length()
         oModelEL2:GoLine(nCont)
         If !oModelEL2:IsDeleted() .And.If ( RS400Info("EJY_TPPROC") == "A" ,!Empty(RS400Info("EL2_DI")),!Empty(RS400Info("EL2_RE"))  )
            oModelEL2:DeleteLine()
         EndIf
      Next
      
      oModelEJZ:GoLine(1)
      oModelEL2:GoLine(1)
      oModelEJY:SetValue("EJY_VL_MOE",0       )
      oModelEJY:SetValue("EJY_VL_REA",0       )
      oModelEJY:SetValue("EJY_DTINI" ,CTOD(""))
      oModelEJY:SetValue("EJY_DTFIM" ,CTOD(""))
      oModelEJY:SetValue("EJY_PRAZO" ,CTOD(""))
      If Type("lRS400Auto") == "L" .And. !lRS400Auto
         oView:GETVIEWOBJ("EJZDETAIL")[3]:Refresh() //Atualiza a view devido às linhas deletadas
      EndIf

   ElseIf lRS400Auto .OR. MsgYesNo("Deseja selecionar todos os serviços pertencentes a este Processo?","Aviso")  

      EJX->(DbSetOrder(1))
      If EJX->(DbSeek(xFilial("EJX")+RS400Info("EJY_TPPROC")+M->EJY_PROCES))
         Do While EJX->(!EOF()) .And. xFilial("EJX") == EJX->EJX_FILIAL .And. RS400Info("EJY_TPPROC") == EJX->EJX_TPPROC .And. M->EJY_PROCES == EJX->EJX_PROCES
            //RRC - 10/10/2013 - Não poderão ser registrados no SISCOSERV serviços que ainda não foram iniciados
            If EJX->EJX_STTPED == "1" .And. EJX->EJX_DTINI <= dDataBase
               If !Empty(RS400Info("EJZ_PROCES"))
                 ForceAddLine(oModelEJZ)
               EndIf
               oModelEJZ:SetValue("EJZ_PROCES",EJX->EJX_PROCES)
               oModelEJZ:SetValue("EJZ_SEQPRC",EJX->EJX_SEQPRC)
               oModelEJZ:SetValue("EJZ_ITEM"  ,EJX->EJX_ITEM  )
               oModelEJZ:SetValue("EJZ_NBS"   ,EJX->EJX_NBS   )
               If RS400Info("EJY_TPPROC") == "V"
                  oModelEJZ:SetValue("EJZ_MODVEN",EJX->EJX_MODO)
               ElseIf RS400Info("EJY_TPPROC") == "A"
                  oModelEJZ:SetValue("EJZ_MODAQU",EJX->EJX_MODO)
               EndIf
               oModelEJZ:SetValue("EJZ_PAIS"  ,EJX->EJX_PAIS  )
               oModelEJZ:SetValue("EJZ_DTPRIN",EJX->EJX_DTPRIN)
               oModelEJZ:SetValue("EJZ_DTPRFI",EJX->EJX_DTPRFI)
               oModelEJZ:SetValue("EJZ_DTINI" ,EJX->EJX_DTINI )
               oModelEJZ:SetValue("EJZ_DTFIM" ,EJX->EJX_DTFIM )
               oModelEJZ:SetValue("EJZ_COMPL" ,EJX->EJX_COMPL )
               oModelEJZ:SetValue("EJZ_ENQ01" ,EJX->EJX_ENQ01 )
               oModelEJZ:SetValue("EJZ_RC01"  ,EJX->EJX_RC01  )
               oModelEJZ:SetValue("EJZ_ENQ02" ,EJX->EJX_ENQ02 )
               oModelEJZ:SetValue("EJZ_RC02"  ,EJX->EJX_RC02  )
               oModelEJZ:SetValue("EJZ_ENQ03" ,EJX->EJX_ENQ03 )
               oModelEJZ:SetValue("EJZ_RC03"  ,EJX->EJX_RC03  )
               oModelEJZ:SetValue("EJZ_QTDE"  ,EJX->EJX_QTDE  )
               oModelEJZ:SetValue("EJZ_PRCUN" ,EJX->EJX_PRCUN )
               oModelEJZ:SetValue("EJZ_VL_MOE",EJX->EJX_VL_MOE)
               oModelEJZ:SetValue("EJZ_TX_MOE",EJX->EJX_TX_MOE)
               oModelEJZ:SetValue("EJZ_VL_REA",EJX->EJX_VL_REA)
               oModelEJZ:SetValue("EJZ_UM"    ,EJX->EJX_UM    )  // GFP - 17/08/2015

            ElseIf !lMsg .And. EJX->EJX_STTPED == "1" .And. EJX->EJX_DTINI > dDataBase
               lMsg := .T.
            EndIf
            EJX->(DbSkip())
         
         EndDo
         EL2->(DbSetOrder(2))//EL2_FILIAL+EL2_TPPROC+EL2_PROCES+EL2_SEQDOC
         If EL2->(DbSeek(xFilial("EL2")+RS400Info("EJY_TPPROC")+M->EJY_PROCES))
            Do While EL2->(!EOF()) .And. xFilial("EL2") == EL2->EL2_FILIAL .And. RS400Info("EJY_TPPROC") == EL2->EL2_TPPROC .And. M->EJY_PROCES == EL2->EL2_PROCES         
               If !Empty(RS400Info("EL2_REGIST"))
                  ForceAddLine(oModelEL2)
               EndIf
               oModelEL2:SetValue( "EL2_SEQDOC" , EL2->EL2_SEQDOC )
               oModelEL2:SetValue( "EL2_RE" , EL2->EL2_RE )
               oModelEL2:SetValue( "EL2_DI" , EL2->EL2_DI )
               oModelEL2:SetValue( "EL2_STTSIS" , EL2->EL2_STTSIS )
               EL2->(DbSkip())
            EndDo
         End If      
           
         AtuTotais()
         VerDatas()
         If Type("lRS400Auto") == "L" .And. !lRS400Auto
            oView:GETVIEWOBJ("EJYMASTER")[3]:Refresh()
         EndIf
         oModelEJZ:GoLine(1)
         oModelEL2:GoLine(1)  
         //RRC - 10/10/2013
         If lMsg
            EasyHelp("Este processo possui serviços ainda não iniciados, estes não poderão compor o Registro neste momento.","Aviso")           
         EndIf
      EndIf   
   EndIf 
EndIf

RestOrd(aOrd,.T.)
Return M->EJY_PROCES


/*
Programa   : GravDoc()
Objetivo   : Efetuar a gravação dos Documentos relacionados ao Registro de Serviço apenas caso a DI ou RE tenha sido
             preenchido
Parametros : cTpReg - "A" - "Aquisição" ou "V" - "Venda"
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 18/09/2012 09:31 
Revisao    : 
*/

Static Function GravDoc(cTpReg)
Local oModel    
Local oModelEL2 
Local nLinha    := 1
Local cCampo    := ""
Default cTpReg  := ""

//If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oModel    := FWModelActive()
//ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
//   oModel    := FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf 

If Valtype(oModel) == "O"
   oModelEL2 := oModel:GetModel("EL2DETAIL")

   If cTpReg == "A"   
      cCampo := "EL2_DI"
   ElseIf cTpReg == "V"
      cCampo := "EL2_RE"   
   EndIf

   For nLinha := 1 To oModelEL2:Length()
      oModelEL2:GoLine(nLinha)
      //Ao encontrar um RE ou uma DI em branco, o Documento e o status for 1 - "Aguardando Registro no Siscoserv", deletará a linha
      //Se o status for diferente disso, grava com o campo em branco, para que não perca o vínculo com a EL7
      If (EasyGParam("MV_ESS0027",,9) < 10 .AND. !oModelEL2:IsDeleted() .And. oModelEL2:GetValue("EL2_STTSIS") == "1" .And. Empty(oModelEL2:GetValue(cCampo))) .OR.; 
         (EasyGParam("MV_ESS0027",,9) >= 10 .AND. !oModelEL2:IsDeleted() .And. oModelEL2:GetValue("EL2_STTSIS") == "1" .And. Empty(oModelEL2:GetValue("EL2_DI")) .And. Empty(oModelEL2:GetValue("EL2_RE"))) .OR.;
         (EasyGParam("MV_ESS0027",,9) >= 10 .AND. !oModelEL2:IsDeleted() .And. Empty(oModelEL2:GetValue("EL2_SEQPRC")))
         oModelEL2:DeleteLine()
      EndIf
   Next
   
EndIf

Return .T.

/*
Programa   : RS400WHEN()
Objetivo   : Verificar a possibilidade de edição dos campos
Parametros : cCampo - Campo a ser verificado
Retorno    : lRet
Autor      : Rafael Ramos Capuano
Data/Hora  : 25/09/2012 09:24 
Revisao    : 31/10/2012 11:46
*/

Function RS400WHEN(cCampo)
Local oModel  
//Local oModelEJY := oModel:GetModel("EJYMASTER")
Local oModelEJZ 
Local nCont     := 1
Local lRet      := .T.
Local aRows     := {}
Default cCampo  := ""


oModel    := FWModelActive()
oModelEJZ := oModel:GetModel("EJZDETAIL")
 
If !Empty(RS400Info("EJY_DTENC"))
   lRet := .F.
Else
   Do Case 
   Case cCampo == "EJY_PROCES"
      If ValType(oModelEJZ) == "O" .And. oModelEJZ:nLine <> 0
         aRows := FWSaveRows()
         Do While nCont <= oModelEJZ:Length() .And. lRet
            oModelEJZ:GoLine(nCont)
            If !oModelEJZ:IsDeleted() .And. !Empty(RS400Info("EJZ_PROCES")) .And. !Empty(RS400Info("EJZ_SEQPRC")) .And. !Empty(RS400Info("EJZ_ITEM"));
            .And. (RS400Info("EJZ_STTSIS") <> "1" .And. !lRS400Auto/* .Or. RS400Info("EJZ_STTPAG") <> "1"*/)
               //RRC - 16/05/2013 - Para casos de MsExecAuto, deve retornar .T. para que execute os gatilhos e dessa forma possa algum dado cadastral, por exemplo: Endereço
               lRet  := .F.
            EndIf
            nCont++
         EndDo
         FWRestRows(aRows)
      EndIf  
  
/*   Case cCampo == "EJY_TIPVIN"
      If cTpReg=="A"
         cChave := xFilial("ELM")+AvKey(RS400Info("EJY_EXPORT"),"ELM_CODFOR")+AvKey(RS400Info("EJY_LOJEXP"),"ELM_LOJFOR")
         cCampos:= "ELM_FILIAL+ELM_CODFOR+ELM_LOJFOR"
         ELM->(DbSetOrder(2))
      ElseIf cTpReg=="V"
         cChave := xFilial("ELM")+AvKey(RS400Info("EJY_IMPORT"),"ELM_CODCLI")+AvKey(RS400Info("EJY_LOJIMP"),"ELM_LOJCLI")
         cCampos:= "ELM_FILIAL+ELM_CODCLI+ELM_LOJCLI"
         ELM->(DbSetOrder(3))
      EndIf
      lRet := ELM->(DbSeek(cChave))   */
   
   EndCase
EndIf

Return lRet

/*
Programa   : VerDatas()
Objetivo   : Verifica as Datas Iniciais, Finais, Prazo e de Registro dos serviços para atualizar os valores
             correspondentes da capa quando deletar ou recuperar uma linha do grid
             Data inicial : será a menor data inicial dentre os serviços
             Data final : será o maior Data final dentre os serviços
             Prazo : será o menor prazo dentre os serviços que possuem data de registro em branco
             Data de registro : será a maior data de registro dentre os serviços, para isso, todos os serviços devem
             estar com a data de registro preenchida
Parâmetros : nLine (Linha do grid) e cAction (ação realizada), estas variáveis serão consideradas apenas quando a chamada vier da função RS400LinePre(),
             que valida a exclusão ou recuperação do item do grid
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 27/09/2012 09:34 
Revisao    : 25/10/2013 15:13
*/

Static Function VerDatas(nLine,cAction)
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
Local nQtdDtFim := 0
Local aDataInicio := {}
Local aDataFim    := {}
Default nLine     := 0
Default cAction   := ""

//If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oModel    := FWModelActive()
//ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
//   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf

oModelEJY  := oModel:GetModel("EJYMASTER")
oModelEJZ  := oModel:GetModel("EJZDETAIL")
oView      := FWViewAction()
aRows      := FWSaveRows() 

For nI := 1 to oModelEJZ:Length()
   oModelEJZ:GoLine(nI)
   /*RRC - 25/10/2013 - Quando a chamada vier do RS400LinePre(), o item não foi completamente excluído ou recuperado, por isso verifica as variáveis nLine e cAction
   para verificar se deve atualizar os valores lançadas no capa, já que só pode considerar as linhas não deletadas*/
   If (nI == nLine .And. cAction == "UNDELETE") .Or. (nI <> nLine .And. !oModelEJZ:IsDeleted()) 
      /*If Empty(dDataIni) .And. Empty(dDataFim)
         dDataIni := oModelEJZ:GetValue("EJZ_DTINI")
         dDataFim := oModelEJZ:GetValue("EJZ_DTFIM")
      EndIf
      If Empty(oModelEJZ:GetValue("EJZ_DTINI"))  
         lDtIniVaz := .T.
         dDataIni  := CTOD("")
      EndIf
      If Empty(oModelEJZ:GetValue("EJZ_DTFIM"))  
         lDtFimVaz := .T.
         dDataFim  := CTOD("")
      EndIf    
      If !lDtIniVaz .And. dDataIni > oModelEJZ:GetValue("EJZ_DTINI")
         dDataIni := oModelEJZ:GetValue("EJZ_DTINI")
      EndIf   
      If !lDtFimVaz .And. dDataFim < oModelEJZ:GetValue("EJZ_DTFIM")
         dDataFim := oModelEJZ:GetValue("EJZ_DTFIM")   
      EndIf */
      dDataIni := oModelEJZ:GetValue("EJZ_DTINI")
      dDataFim := oModelEJZ:GetValue("EJZ_DTFIM") 
      If !Empty(dDataIni) 
         aAdd(aDataInicio,dDataIni)
      EndIf
      
      If !Empty(dDataFim) 
         aAdd(aDataFim,dDataFim)
      EndIf

      If Empty(oModelEJZ:GetValue("EJZ_DTREG")) .And. !Empty(oModelEJZ:GetValue("EJZ_DTINI")) .And. !Empty(oModelEJZ:GetValue("EJZ_PRAZO")) .And. (Empty(dPrazo) .Or. dPrazo > oModelEJZ:GetValue("EJZ_PRAZO"))
         dPrazo := oModelEJZ:GetValue("EJZ_PRAZO")     
      EndIf   
      If Empty(oModelEJZ:GetValue("EJZ_DTREG")) //Verifica se existe algum serviço com data de registro em branco
         lDtRegVaz := .T.
         dReg      := CTOD("") 
      ElseIf  !lDtRegVaz .And. (Empty(dReg) .Or. dReg < oModelEJZ:GetValue("EJZ_DTREG"))
         dReg := oModelEJZ:GetValue("EJZ_DTREG")
      EndIf
      
      nQtdDtFim++
   EndIf   
Next

// A data inicio deverá ser preenchida com a menor data caso algum serviço ja tenha sido iniciado, independente dos outros.
// A data fim deverá ser preenchida com a maior data caso todos serviços ja tenha sido finalizado.
If Len(aDataInicio) > 0
   aDataInicio := aSort(aDataInicio)
   oModelEJY:SetValue("EJY_DTINI",aDataInicio[1])
EndIf

oModelEJY:SetValue("EJY_DTFIM",CTOD(""))
If Len(aDataFim) > 0 .And. Len(aDataFim) == nQtdDtFim
   aDataFim := aSort(aDataFim)
   oModelEJY:SetValue("EJY_DTFIM",aDataFim[Len(aDataFim)])
EndIf

oModelEJY:SetValue("EJY_PRAZO",dPrazo)
oModelEJY:SetValue("EJY_DTREG",dReg)

FWRestRows(aRows) 
If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oView:GETVIEWOBJ("EJYMASTER")[3]:Refresh() // Atualiza capa do registro     
EndIf

Return .T.

/*
Programa   : RS400DtReg()
Objetivo   : Atualiza a Data do Registro da capa com a maior Data de Registro dos serviços, para isso, todos os serviços devem possui a data de
             Registro preenchida
Parâmetros : cTipo - Tipo de Processo, cProc - Registro
Retorno    : Nil
Autor      : Rafael Ramos Capuano
Data/Hora  : 01/10/2012 11:35 
Revisao    : 
*/

Function RS400DtReg(cTipo, cProc)
Local aOrd   := SaveOrd({"EJY","EJZ"})
Local dReg

If ValType(cTipo) <> "U" .And. ValType(cProc) <> "U"
   EJZ->(DbSetOrder(1))
   If EJZ->(DbSeek(xFilial("EJZ")+cTipo+cProc))
      Do While EJZ->(!EOF()) .And. xFilial("EJZ") == EJZ->EJZ_FILIAL .And. AvKey(cTipo,"EJZ_TPPROC") == EJZ->EJZ_TPPROC .And. AvKey(cProc,"EJZ_REGIST") == EJZ->EJZ_REGIST     
         If Empty(EJZ->EJZ_DTREG)            
            EJY->(DbSetOrder(1))
            If EJY->(DbSeek(xFilial("EJY")+AvKey(cTipo,"EJY_TPPROC")+AvKey(cProc,"EJY_REGIST"))) .And. !Empty(EJY->EJY_DTREG)
               If EJY->(RecLock("EJY",.F.))
                  EJY->EJY_DTREG := CTOD("")
                  EJY->EJY_STTSIS := "1"  //"Aguardando registro no SISCOSERV"    // GFP - 17/02/2014
                  EJY->(MsUnLock())
               EndIf
            EndIf
            Return
         ElseIf Empty(dReg) .Or. dReg < EJZ->EJZ_DTREG 
            dReg := EJZ->EJZ_DTREG 
         EndIf 
         EJZ->(DbSkip())  
      EndDo 
   EndIf
   EJY->(DbSetOrder(1))
   If EJY->(DbSeek(xFilial("EJY")+cTipo+cProc))
      If EJY->(RecLock("EJY",.F.))
         EJY->EJY_DTREG  := dReg
         /* RMD - 10/12/14 - REVER O TRECHO ABAIXO
         If IsInCallStack("ESSIN100")
            EJY->EJY_STTSIS := "3"  //"Registrado no SISCOSERV"    // GFP - 17/02/2014
         EndIf
         */
         EJY->(MsUnLock())
      EndIf
   EndIf
EndIf
RestOrd(aOrd,.T.)
Return

/*
Programa   : RS400StaReg(cTipo,cProc,dDataEnc)
Objetivo   : Atualiza status dos serviços do registro
Parâmetros : cTipo - Tipo de Processo, cProc - Registro, dDataEnc - Se informada indica que o registro foi encerrado
Retorno    : Nil
Autor      : Rafael Ramos Capuano
Data/Hora  : 02/10/2012 10:59 
Revisao    : 
*/

Function RS400StaReg(cTipo,cProc,dDataEnc)
Local aOrd       := SaveOrd({"EJY" ,"EJZ","EL2"})
Local cMenorSta  := ""
Local nCont      := 0
Local nCont2     := 0
Local lEncer     := .F.
Local nRecno     := EJY->(Recno())

Begin Sequence
If ValType(cTipo) <> "U" .And. ValType(cProc) <> "U"
   If ValType(dDataEnc) <> "U" .And. !Empty(dDataEnc)
      lEncer := .T.
   EndIf
   //Verifica campo EJZ_STTSIS(Status Siscoserv dos Serviços)
   EJZ->(DbSetOrder(1))
   If EJZ->(DbSeek(xFilial("EJZ") + AvKey(cTipo,"EJZ_TPPROC") + AvKey(cProc,"EJZ_REGIST")))
      Do While EJZ->(!EOF()) .And. xFilial("EJZ") == EJZ->EJZ_FILIAL .And. AvKey(cTipo,"EJZ_TPPROC") == EJZ->EJZ_TPPROC .And. AvKey(cProc,"EJZ_REGIST") == EJZ->EJZ_REGIST     
         If Empty(cMenorSta) .Or. Val(cMenorSta) > Val(EJZ->EJZ_STTSIS)          
            cMenorSta := EJZ->EJZ_STTSIS            
         EndIf
         //Atualiza status do serviço do registro
         RS400StaPed(cTipo,EJZ->EJZ_PROCES,EJZ->EJZ_SEQPRC,.F.,lEncer,cMenorSta)  // GFP - 24/02/2014
         If EJZ->EJZ_STTSIS == "1"
            nCont++
         Else 
            nCont2++   
         EndIf
         EJZ->(DbSkip())
      EndDo
   EndIf
   
   //Verifica campo EL2_STTSIS(Status Siscoserv dos Documentos relacionados ao Registro de Serviço)
   //EL2->(DbSetOrder(1)) //EL2_FILIAL + EL2_TPPROC + EL2_REGIST + EL2_SEQPAG + EL2_SEQPAG  - ìndice antigo para documento de pagamento - RRC - 22/03/2013
   EL2->(DbSetOrder(4)) //EL2_FILIAL + EL2_TPPROC + EL2_REGIST + EL2_SEQPAG + EL2_SEQDOC
   //If EL2->(DbSeek(xFilial("EL2") + AvKey(cTipo,"EL2_TPPROC") + AvKey(cProc,"EL2_REGIST")+Space(AvSx3("EL2_SEQREG",AV_TAMANHO))+Space(AvSx3("EL2_SEQPAG",AV_TAMANHO))))
   If EL2->(DbSeek(xFilial("EL2") + AvKey(cTipo,"EL2_TPPROC") + AvKey(cProc,"EL2_REGIST")+Space(AvSx3("EL2_SEQPAG",AV_TAMANHO))))
      Do While EL2->(!EOF()) .And. xFilial("EL2") == EL2->EL2_FILIAL .And. AvKey(cTipo,"EL2_TPPROC") == EL2->EL2_TPPROC .And.;
       AvKey(cProc,"EL2_REGIST") == EL2->EL2_REGIST .And. Empty(EL2->EL2_SEQREG) .And. Empty(EL2->EL2_SEQPAG)    
         If Empty(cMenorSta) .Or. Val(cMenorSta) > Val(EL2->EL2_STTSIS)          
            cMenorSta := EL2->EL2_STTSIS            
         EndIf
         If EL2->EL2_STTSIS == "1"
            nCont++
         ElseIf !Empty(EL2->EL2_STTSIS)  
            nCont2++   
         EndIf
         EL2->(DbSkip())
      EndDo
   EndIf
        
   EJY->(DbSetOrder(1))
   If EJY->(DbSeek(xFilial("EJY") + AvKey(cTipo,"EJY_TPPROC") + AvKey(cProc,"EJY_REGIST")))
      If EJY->(RecLock("EJY",.F.))
      /*O Status Siscoserv da capa será "Parcialmente Registrado no Siscoserv" quando:
         - Existirem serviços com o Status Siscoserv "Em aberto" e outros "Registrados no Siscoserv" 
         - O menor status dos serviços for "Parcialmente Registrado no Siscoserv"*/
         If nCont > 0 .And. nCont2 > 0
            EJY->EJY_STTSIS := "2"
         Else
            EJY->EJY_STTSIS := cMenorSta 
         EndIf
         EJY->(MsUnlock())
      EndIf
   EndIf  
EndIf
End Sequence
EJY->(DbGoTo(nRecno))
RestOrd(aOrd,.T.)
Return

/*
Programa   : RS400StaPed(cTipo,cPed,cSeqPed,lDelReg,lEncer)
Objetivo   : Atualiza status dos serviços do processo
Parâmetros : cTipo - Tipo de Processo, cPed - Processo, cSeqPed - Sequência do Processo, lEncer - Indica se o serviço foi encerrado
             Se não informada a Sequência do Processo, a função irá apenas atualizar o conteúdo da capa
             do Processo.
             lDelReg - Informa que o item passado como parâmetro, está sendo deletado do Cadastro de Registro de Serviços        
Retorno    : Nil
Autor      : Rafael Ramos Capuano
Data/Hora  : 02/10/2012 11:57 
Revisao    : 
*/

Function RS400StaPed(cTipo, cPed, cSeqPed, lDelReg, lEncer, cMenorSta)
Local aOrd      := SaveOrd({"EJW" ,"EJX"})
Local nCont     := 0
Local nCont2    := 0
//Local lDtEfet   := .F.  // GFP - 10/11/2014 //MCF - 05/01/2014
Default lDelReg := .F.
Default lEncer  := .F.
Default cMenorSta := ""   // GFP - 24/02/2014

Begin Sequence       
If ValType(cTipo) <> "U" .And. ValType(cPed) <> "U"
   EJX->(DbSetOrder(1))         
   If EJX->(DbSeek(xFilial("EJX") + AvKey(cTipo,"EJX_TPPROC") + AvKey(cPed,"EJX_PROCES")))       
      Do While EJX->(!EOF()) .And. xFilial("EJX") == EJX->EJX_FILIAL .And. AvKey(cTipo,"EJX_TPPROC") == EJX->EJX_TPPROC .And. AvKey(cPed,"EJX_PROCES") == EJX->EJX_PROCES                      
         //Muda o status para "Encerrado"
         If ValType(cSeqPed) <> "U" .And. AvKey(cSeqPed,"EJX_SEQPRC") == EJX->EJX_SEQPRC .And. lEncer
            If EJX->(RecLock("EJX",.F.))
               EJX->EJX_STTPED := "4" 
               EJX->(MsUnlock())               
            EndIf
         //Muda o status para "Em fase de registro"         
         ElseIf ValType(cSeqPed) <> "U" .And. AvKey(cSeqPed,"EJX_SEQPRC") == EJX->EJX_SEQPRC .And. (EJX->EJX_STTPED == "1" .Or. (EJX->EJX_STTPED == "4" .And. !lDelReg .And. !lEncer))
            If EJX->(RecLock("EJX",.F.))
               EJX->EJX_STTPED := "3" 
               EJX->(MsUnlock())               
            EndIf
         //Muda o Status para "Aguardando Registro no Siscoserv"                                                                                      
         ElseIf ValType(cSeqPed) <> "U" .And. AvKey(cSeqPed,"EJX_SEQPRC") == EJX->EJX_SEQPRC .And. lDelReg .And. !lEncer
            If EJX->(RecLock("EJX",.F.))
               EJX->EJX_STTPED := "1"                                   
               EJX->(MsUnlock())  
            EndIf
         EndIf            
         If Empty(cMenorSta) .Or. Val(cMenorSta) > Val(EJX->EJX_STTPED)
            cMenorSta := EJX->EJX_STTPED
         EndIf
         If EJX->EJX_STTPED == "1"
            nCont++
         ElseIf EJX->EJX_STTPED <> "4" 
            nCont2++   
         EndIf
         //lDtEfet := !Empty(EJX->EJX_DTINI)  // GFP - 10/11/2014 //MCF - 05/01/2014
         EJX->(DbSkip())
      EndDo        
   EndIf
   EJW->(DbSetOrder(1))
   If EJW->(DbSeek(xFilial("EJW") + AvKey(cTipo,"EJW_TPPROC") + AvKey(cPed,"EJW_PROCES")))
      If EJW->(RecLock("EJW",.F.))
         If lEncer  // GFP - 13/06/2014
            EJW->EJW_STTPED := "4" 
         ElseIf nCont > 0 .And. nCont2 > 0
            EJW->EJW_STTPED := "2"
         ElseIf /*lDtEfet .AND.*/ Type("lGerouReg") == "L" .And. lGerouReg // GFP - 10/11/2014 //MCF - 05/01/2014
            EJW->EJW_STTPED := "3"
         Else
            EJW->EJW_STTPED := cMenorSta 
         EndIf
         EJW->(MsUnlock())
      EndIf
   EndIf  
EndIf
End Sequence
RestOrd(aOrd,.T.)
Return

Static Function ForceAddLine(oModelGrid)
Local lDel := .F.

If oModelGrid:Length() >= oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If !oModelGrid:IsDeleted()
      oModelGrid:DeleteLine()
      lDel := .T.
   EndIf
   oModelGrid:AddLine()
   oModelGrid:GoLine(1)
   If lDel
      oModelGrid:UnDeleteLine()
   EndIf
   oModelGrid:GoLine(oModelGrid:Length())
EndIf

Return .T.

/*
Programa   : RS400Modo(cCont,cProc,cModo)
Objetivo   : Atualiza campo Modo de Prestação de Serviços de acordo com conteúdo do campo virtual utilizado:
             "EJZ_MODAQU" - "Aquisição" ou "EJZ_MODVEN" - Venda 
             Estes campos combos possuem opções diferentes
Parâmetros : cCont - Tipo de Processo, cProc - Nº do Registro, cModo - Conteúdo do Campo Virtual de Modo de Prestação     
Retorno    : Nil
Autor      : Rafael Ramos Capuano
Data/Hora  : 11/10/2012 16:01 
Revisao    : 
*/

Function RS400Modo(cCont,cProc,cModo)
Local aOrd      := SaveOrd({"EJZ"})
Local oModel
Local oModelEJZ 
Local nI

//If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oModel    := FWModelActive()
//ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
//   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf

If Valtype(oModel) == "O"
   oModelEJZ := oModel:GetModel("EJZDETAIL")

   If ValType(cCont) <> "U" .And. ValType(cProc) <> "U" .And. ValType(cModo) <> "U"
      EJZ->(DbSetOrder(1))
      For nI := 1 To oModelEJZ:Length()
         oModelEJZ:GoLine(nI)
         If !oModelEJZ:IsDeleted()            
            If EJZ->(DbSeek(xFilial("EJZ") + AvKey(cCont,"EJZ_TPPROC") + AvKey(cProc,"EJZ_REGIST") + AvKey(oModelEJZ:GetValue("EJZ_SEQREG"),"EJZ_SEQREG") ))    
               If EJZ->( RECLOCK("EJZ",.F.) )
                  EJZ->EJZ_MODO := oModelEJZ:GetValue(cModo)
                  EJZ->(MSUNLOCK())
               EndIf
            EndIf
         EndIf
      Next
   EndIf

EndIf
      
RestOrd(aOrd,.T.)      
Return 

/*
Programa   : RS400DelReg()
Objetivo   : Validar a exclusão do Registro conforme seu status
Retorno    : Lógico
Autor      : Rafael Ramos Capuano
Data/Hora  : 16/10/2012 10:00
Revisao    : 
*/

Function RS400DelReg()
Local lRet      := .T.
Local nI
Local oModel    
Local oModelEJZ 
Local cMsg      := ""
Local cChave    := ""
Local aOrd      := SaveOrd({"ELA","EL3","EL8"})
ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
EL3->(DbSetOrder(1)) //EL3_FILIAL+EL3_TPPROC+EL3_REGIST+EL3_SQEVCP
//If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oModel    := FWModelActive()
   oModelEJZ := oModel:GetModel("EJZDETAIL")
//EndIf

Begin Transaction
//RRC - 14/10/2013 - Não poderá excluir o RAS/RVS se ao menos um lote tenha sido gerado com ele, sendo este registrado ou não
If EJY->EJY_STTSIS <> "1"
   cMsg := "O Registro não poderá ser excluído pois apresenta Status Siscoserv '" + BSCXBOX('EJY_STTSIS',EJY->EJY_STTSIS) + "'"
   EasyHelp(cMsg + ".","Aviso")
   lRet := .F.
ElseIf EL3->(DbSeek(xFilial("EL3")+EJY->EJY_TPPROC+EJY->EJY_REGIST))
   //RRC - 28/11/2013 - Alteração para somente validar caso o lote não tenha sido cancelado
   EL8->(DbSetOrder(2)) //EL8_FILIAL+EL8_IDLOTE   
   Do While EL3->(!Eof()) .And. EL3->(EL3_FILIAL+EL3_TPPROC+EL3_REGIST) == xFilial("EL3")+EJY->EJY_TPPROC+EJY->EJY_REGIST
      If EL8->(DbSeek(xFilial("EL8")+EL3->EL3_IDLOTE)) .And. EL8->EL8_STATUS <> "C" .And. !Empty(EL3->EL3_NROREG)
         cMsg := "O Registro não poderá ser excluído pois está vinculado a um lote não cancelado."
         EasyHelp(cMsg + ".","Aviso")
         lRet := .F.
         Exit
      EndIf
      EL3->(DbSkip())   
   EndDo
Else
   //Exclui os pagamentos/faturamentos relacionados ao Registro
   If !(lRet := RS400DelPgto())
      DisarmTransaction()
      Break
   EndIf
   //RRC - 11/04/2013 - Ativa novamente o objeto oModel, no momento de excluir os pagamentos/faturamentos ele está sendo desativado após o MsExecAuto() de outro modelo
   oModel:Activate()
   //Exclui as parcelas de câmbio geradas para os serviços
   //Este tratamento foi removido pois as parcelas de câmbio agora são geradas pela Invoice (ESSIS400) 
   /*For nI := 1 To oModelEJZ:Length()    
      oModelEJZ:GoLine(nI)
      If !(lRet := RS400DelParc(oModelEJZ:GetValue("EJZ_SEQREG")))
         DisarmTransaction()
         Break
      EndIf
   Next*/
EndIf
   
End Transaction

If !lRet
   ELinkClearID()
EndIf
RestOrd(aOrd,.T.)
Return lRet
     
/*
Programa   : RS400GerParc()
Objetivo   : Gerar parcelas de todos os serviços com a data de inicial (EJZ_DTINI)
Retorno    : Lógico
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 16/10/2012 10:00
Revisao    : 
*/

Static Function RS400GerParc(cTpProc,cProc,aGerParc)
Local lRet := .T.
Local i
Local nOrd := EJZ->(IndexOrd())
Local nRec := EJZ->(Recno())
Default aGerParc := {}
Default cTpProc := ""
Default cProc := ""

Begin Sequence

   EJZ->(DbSetOrder(1))
   For i := 1 To Len(aGerParc)
      If EJZ->(DbSeek(xFilial("EJZ") + AvKey(cTpProc,"EJZ_TPPROC") + AvKey(cProc,"EJZ_REGIST") + AvKey(aGerParc[i],"EJZ_SEQREG")))
         If !(lRet:=RS401GerPagto(.F.))
            Break
         EndIf   
      EndIf
   Next

End Sequence

EJZ->(DbSetOrder(nOrd))
EJZ->(DbGoTo(nRec))

Return lRet

/*
Static Function RS400GetParc(cTpProc,cProc)
Local aRet := {}
Local nRecEJZ := EJZ->(Recno())
Local nOrdEJZ := EJZ->(IndexOrd()) 
Local oModel
Local oModelEJZ
Local nI
Local lStatus := .F.

Default cTpProc := ""
Default cProc := ""

//If Type("lRS400Auto") == "L" .And. !lRS400Auto
   oModel    := FWModelActive()
//ElseIf Type("lRS400Auto") == "L" .And. lRS400Auto      
//   FWLoadModel("ESSRS400")  //Utiliza este método caso seja ExecAuto
//EndIf

Begin Sequence

   If Valtype(oModel) <> "O" .Or. Valtype(oModelEJZ := oModel:GetModel("EJZDETAIL")) <> "O"
      Break
   EndIf

   EJZ->(DbSetOrder(1))
   For nI := 1 To oModelEJZ:Length()
      oModelEJZ:GoLine(nI)
      If !oModelEJZ:IsDeleted()
         //RRC - 22/01/2013 
         If lStatus := EJZ->(DbSeek(xFilial("EJZ") + AvKey(cTpProc,"EJZ_TPPROC") + AvKey(cProc,"EJZ_REGIST") + AvKey(oModelEJZ:GetValue("EJZ_SEQREG"),"EJZ_SEQREG") ))    
            EL1->(DbSetOrder(1))
            lStatus := EL1->(DbSeek(xFilial("EL1")+AvKey(cTpProc,"EJZ_TPPROC") + AvKey(cProc,"EJZ_REGIST") + AvKey(oModelEJZ:GetValue("EJZ_SEQREG"),"EJZ_SEQREG") ))
         EndIf
         If !lStatus .And. !Empty(oModelEJZ:GetValue("EJZ_DTINI")) .And. !(oModelEJZ:GetValue("EJZ_DTINI")==EJZ->EJZ_DTINI)
            aAdd(aRet,oModelEJZ:GetValue("EJZ_SEQREG"))
         EndIf
      EndIf
   Next

End Sequence

EJZ->(DbGoTo(nRecEJZ))
EJZ->(DbSetOrder(nOrdEJZ))

Return aClone(aRet)
*/


/*
Programa   : RS400DelParc()
Objetivo   : Exclui as parcelas de câmbio geradas para os serviços
Retorno    : Lógico
Autor      : Rafael Ramos Capuano
Data/Hora  : 18/01/2013 16:54
Revisao    : 
*/
/* AAF 25/04/2013 - Função nopado pois não esta mais em uso.
Static Function RS400DelParc(cSeqPro)
Local lRet      := .T.
Local cMsg      := ""
Local aEEQAuto  := {}
Local aOrd      := SaveOrd({"EEQ","EJZ"})
Default cSeqPro := ""
Private lMSErroAuto := .F.

Begin Sequence
If !Empty(cSeqPro)
   EEQ->(DbSetOrder(1))//EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
   If EEQ->(DbSeek(xFilial("EEQ") + AvKey(RS400Info("EJZ_TPPROC")+RS400Info("EJY_REGIST")+cSeqPro,"EEQ_PREEMB") ))  
      Do While EEQ->(!Eof()) .And. xFilial("EEQ") == EEQ->EEQ_FILIAL .And. AvKey(RS400Info("EJZ_TPPROC")+RS400Info("EJY_REGIST")+cSeqPro,"EEQ_PREEMB") == EEQ->EEQ_PREEMB 
         aEEQAuto := {}
         aAdd(aEEQAuto,{"EEQ_FILIAL", EEQ->EEQ_FILIAL , Nil }) 
         aAdd(aEEQAuto,{"EEQ_PREEMB", EEQ->EEQ_PREEMB , Nil }) 
         aAdd(aEEQAuto,{"EEQ_PARC"  , EEQ->EEQ_PARC   , Nil }) 
         aAdd(aEEQAuto,{"EEQ_FASE"  , EEQ->EEQ_FASE   , Nil })        
         MsExecAuto({|x,y,z,w,k| EECAF500(x,y,z,w,k)},"EEQ", , ,aEEQAuto,5)              
         If lMsErroAuto
            //Para casos de execauto do Siscoserv, mesmo com a chamada do EasyHelp() na função AF500AtuaEEQ(), a função NomeAutoLog()
            //não retornava a mensagem de erro após uma inclusão com sucesso e tentativa inválida de exclusão logo em seguida 
            If ValType(cMsg := NomeAutoLog()) == "U"   
               cMsg := "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
            Else
               cMsg := MemoRead(NomeAutoLog())
               FErase(NomeAutoLog())     
            EndIf
            EasyHelp(cMsg)
            lRet := .F.
            Break
         Else
            EEQ->(DbSkip())   
         EndIf                      
      EndDo      
   EndIf
EndIf
End Sequence
RestOrd(aOrd,.T.)
Return lRet
*/

Static Function ValidaOperacao(nOpcAuto, aCab, aItens, aAnexos)
Local nOpcNew := nOpcAuto
Local nPos

If nOpcAuto == 3 .OR. nOpcAuto == 4 //UPSERT
   nOpcNew := If(EasySeekAuto("EJY",aCab,1),4,3)
EndIf

/*
MFR 14/07/2017 WCC-523509
Comentado conforme orientação do Rodrigo e Alessandro
If Len(aItens) == 0 .AND. EasyGParam("MV_ESS0027",,9) < 10
   nOpcNew := 5
EndIf
*/

nPos := aScan(aCab,{|x|x[1]=="EJY_EXPORT"})
If nPos > 0 .AND. ValType(aCab[nPos][2]) == "C" .AND. cTpReg == "A"
   nPos2 := aScan(aCab,{|x|x[1]=="EJY_LOJEXP"})
   If nPos2 > 0
      //RRC - 08/05/2013
      /*If !IsForeign("SA2", aCab[nPos][2]+aCab[nPos2][2])
         //EasyHelp("Não é possível integrar o processo de aquisição de serviço. A loja do exportador não foi informada.","Atenção")
         //nOpcNew := 5
      EndIf*/
   Else
      EasyHelp("Não é possível integrar processo de aquisição de serviço. A loja do exportador não foi informada.","Atenção")
      Break
   EndIf
EndIf

nPos := aScan(aCab,{|x|x[1]=="EJY_IMPORT"})
If nPos > 0.AND. ValType(aCab[nPos][2]) == "C" .AND. cTpReg == "V"
   nPos2 := aScan(aCab,{|x|x[1]=="EJY_LOJIMP"})
   If nPos2 > 0
      //RRC - 08/05/2013
      /*If !IsForeign("SA1", aCab[nPos][2]+aCab[nPos2][2])
         //EasyHelp("Não é possível integrar processo de aquisição de serviço. A loja do exportador não foi informada.","Atenção")
         //nOpcNew := 5
      EndIf*/
   Else
      EasyHelp("Não é possível integrar processo de venda de serviço. A loja do importador não foi informada.","Atenção")
      Break
   EndIf
EndIf

Return nOpcNew  

Static Function IsForeign(cTabela, cChave)
Local cAbrev := Right(cTabela,2)
Local lRet   := .F.
Local aOldOrd

aOldOrd := (cTabela)->({IndexOrd(),RecNo()})

(cTabela)->(dbSetOrder(1))
lRet    := (cTabela)->(dbSeek(xFilial()+cChave) .AND. (&(cAbrev+"_EST") == "EX" .OR. !Empty(&(cAbrev+"_PAIS")) .AND. !&(cAbrev+"_PAIS") == "105"))

(cTabela)->(dbSetOrder(aOldOrd[1]),dbGoTo(aOldOrd[2]))

Return lRet

Static Function ValidaIntegracao(nOpcAuto,aCab,aDet,aAnex,lCallInv)
Local lRet := .T.
Default lCallInv := .F.
Begin Sequence
   
   //Campo obrigatório apenas para inclusão via ExecAuto, caso contrário será preenchido automaticamente através da função PS400Relacao()
   /*If nOpcAuto == 3
      nPos := aScan(aCab,{|x|x[1]=="EJY_ORIGEM"})
      If nPos == 0
         EasyHelp("A origem da integração deve ser informada.","Aviso")
         lRet := .F.
         Break
      EndIf
   EndIf*/
  
   //CodToMoney(aCab)
   
   /* GFP - 25/02/2014
   nPos := aScan(aCab,{|x|x[1]=="EJY_EXPORT"})
   If nPos > 0 .AND. cTpReg == "V"
      EasyHelp("Integração não permitida. O exportador não deve ser informado para processo de venda de serviço.","Aviso")
      lRet := .F.
      Break
   EndIf
   
   nPos := aScan(aCab,{|x|x[1]=="EJY_IMPORT"})
   If nPos > 0 .AND. cTpReg == "A"
      EasyHelp("Integração não permitida. O importador não deve ser informado para processo de aquisição de serviço.","Aviso")
      lRet := .F.
      Break
   EndIf
   */
   //Retira do Array caso os campos a seguir sejam previamentes informados, estes campos não são editáveis e serão preenchidos automaticamente
   nPos := aScan(aCab,{|x|x[1]=="EJY_VL_MOE"})
   If nPos > 0
      aDel(aCab,nPos)
      aSize(aCab,Len(aCab)-1)
   EndIf
   
   nPos := aScan(aCab,{|x|x[1]=="EJY_VL_REA"})
   If nPos > 0
      aDel(aCab,nPos)
      aSize(aCab,Len(aCab)-1)
   EndIf
   
   nPos := aScan(aCab,{|x|x[1]=="EJY_FILIAL"})
   If nPos == 0
      aAdd(aCab,{"EJY_FILIAL",xFilial("EJY"),NIL})
      /*aDel(aCab,nPos)
      aSize(aCab,Len(aCab)-1)*/
   EndIf
   
   //Adiciona Tipo de processo
   nPos := aScan(aCab,{|x|x[1]=="EJY_TPPROC"})
   If nPos == 0
      aAdd(aCab,{"EJY_TPPROC",cTpReg,NIL})
      /*aDel(aCab,nPos)
      aSize(aCab,Len(aCab)-1)*/
   EndIf
   
   If !lCallInv .And. !ValidaItensEAuto(aCab,aDet,aAnex,nOpcAuto)
      //Não chamar o help para não retornar erro de integração.
      //EasyHelp("Não há itens com N.B.S. para integração.","Aviso")
   EndIf
   
End Sequence
Return lRet 

Static Function ValidaItensEAuto(aCab,aItens,aAnexos,nOpcAuto)
Local i, j, nPos, nPos2
Local lAnexos := .T.
Local aOrdEJZ := {}
Local cLastSeqPro 

SB5->(dbSetOrder(1))

aOrdEJZ := SaveOrd({"EJZ"})
EJZ->(DbSetOrder(1))
If nOpcAuto == 4 .AND. EJZ->(AvSeekLast(xFilial("EJY")+aCab[nPos := aScan(aCab,{|x|x[1]=="EJY_TPPROC"})][2]+aCab[nPos := aScan(aCab,{|x|x[1]=="EJY_REGIST"})][2]))
   cLastSeqPro := EJZ->EJZ_SEQREG
Else
   cLastSeqPro := STRZERO(0,AvSX3("EJZ_SEQREG",AV_TAMANHO))
EndIf
RestOrd(aOrdEJZ,.T.)

For i := 1 To Len(aItens)

   nPos := aScan(aItens[i],{|x|x[1]=="EJZ_FILIAL"})
   If nPos == 0
      aAdd(aItens[i],{"EJZ_FILIAL",xFilial("EJZ"),NIL})
   EndIf
   
   //Adiciona Tipo de processo
   nPos := aScan(aItens[i],{|x|x[1]=="EJZ_TPPROC"})
   If nPos == 0
      aAdd(aItens[i],{"EJZ_TPPROC",cTpReg,NIL})
   EndIf
   
   //Adiciona as Sequencias dos Serviço no Processo
   nPos := aScan(aItens[i],{|x|x[1]=="EJZ_SEQREG"})
   If nPos == 0
      cLastSeqPro := STRZERO( (cLastSeqPro := Val(cLastSeqPro) + 1),AvSX3("EJZ_SEQREG",AV_TAMANHO) )
      aAdd( aItens[i],{"EJZ_SEQREG", cLastSeqPro ,NIL})
   Else
      aItens[i][npos][2] := StrZero(Val(aItens[i][npos][2]),AvSx3("EJZ_SEQREG",3))
   EndIf

   //Ajusta a Sequência de Aditivo ao serviço conforme tamanho do campo caso esteja na chave
   nPos := aScan(aItens[i],{|x|x[1]=="EJZ_SEQAD"})
   If nPos > 0
      If Val(aItens[i][npos][2]) > 0
         aItens[i][npos][2] := STRZERO( Val(aItens[i][npos][2]),AvSx3("EJZ_SEQAD",AV_TAMANHO) )
      Else
         aItens[i][npos][2] := SPACE( AvSx3("EJZ_SEQAD",AV_TAMANHO) )
      EndIf
   EndIf

   //RRC - 06/11/2013 - Adiciona no array o campo EJZ_REGIST pertencente a esta chave
   nPos := aScan(aItens[i],{|x|x[1]=="EJZ_REGIST"})
   If nPos == 0
      If (nPos := aScan(aCab,{|x|x[1]=="EJY_REGIST"})) > 0
         aAdd(aItens[i],{"EJZ_REGIST",aCab[nPos][2],NIL})
      EndIf
   EndIf       
   
Next i

If ValType(aAnexos) == "A"
   For i := 1 To Len(aAnexos)
      //Adiciona a Filial
      nPos := aScan(aAnexos[i],{|x|x[1]=="EL2_FILIAL"})
      If nPos == 0
         aAdd(aAnexos[i],{"EL2_FILIAL",xFilial("EL2"),NIL})
      EndIf   
      //Adiciona Tipo de processo
      nPos := aScan(aAnexos[i],{|x|x[1]=="EL2_TPPROC"})
      If nPos == 0
         aAdd(aAnexos[i],{"EL2_TPPROC",cTpReg,NIL})
      EndIf
   Next i 
   lAnexos := Len(aAnexos)>0  
EndIf 

Return Len(aItens)>0 .And. lAnexos

Function RS400AssociaPed(uProcesso,cTipo)
Local aProcessos := {}
Local aTabelas   := {/*"EL9","EL1","EL2"*/}
Local cQuery
Local i, j

If ValType(uProcesso) == "A" .AND. ValType(uProcesso[1]) == "C"
   aAdd(aProcessos,uProcesso)
ElseIf ValType(uProcesso) == "A" .AND. ValType(uProcesso[1]) == "A"
   aProcessos := uProcesso
EndIf

//Não está tratando processos em mais de um registro para documentos e pagamentos!
For i := 1 To Len(aProcessos)
   EJZ->(dbSetOrder(3))
   
      For j := 1 To Len(aTabelas)
         cQuery := "Select R_E_C_N_O_ AS RECNO "
         cQuery += "From "+RetSqlName(aTabelas[j])+" "+aTabelas[j]+" "
         cQuery += "Where "+aTabelas[j]+".D_E_L_E_T_ = '' AND "+aTabelas[j]+"_PROCES = '"+AvKey(aProcessos[i][1],"EJZ_PROCES")+"'"
         
         If aTabelas[j] == "EL2"
            cQuery += " AND EL2.EL2_SEQPAG <> ''"
         EndIf
         
         If Select("WKTMP") > 0
            WKTMP->(dbCloseArea())
         EndIf
         
         dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"WKTMP",.F.,.F.)
         TcSetField("WKTMP","RECNO","N",8,0)
         
         Do While !WKTMP->(EoF())
            (aTabelas[j])->(dbGoTo(WKTMP->RECNO))
            
            RecLock(aTabelas[j],.F.)
            If EJZ->(dbSeek(xFilial("EJZ")+cTipo+Avkey(aProcessos[i][1],"EJZ_PROCES")+AvKey(aProcessos[i][2],"EJZ_SEQPRC"))) .AND. !aProcessos[i][3]
               (aTabelas[j])->(If((nPos:=FieldPos(aTabelas[j]+"_REGIST"))>0,FieldPut(nPos,EJZ->EJZ_REGIST),))
               (aTabelas[j])->(If((nPos:=FieldPos(aTabelas[j]+"_SEQREG"))>0,FieldPut(nPos,EJZ->EJZ_SEQREG),))
            Else
               (aTabelas[j])->(If((nPos:=FieldPos(aTabelas[j]+"_REGIST"))>0,"",))
               (aTabelas[j])->(If((nPos:=FieldPos(aTabelas[j]+"_SEQREG"))>0,"",))
            EndIf
            (aTabelas[j])->(MsUnLock())
            
            WKTMP->(dbSkip())
         EndDO
      Next j

Next i

Return .T.


/*
Programa   : VerEnqRC()
Objetivo   : Verifica se foi incluído algum enquadramento vinculado a um Registro de Operação de Crédito (obriga preenchimento do campo do RC)
Retorno    : lRet
Autor      : Rafael Ramos Capuano
Data       : 19/03/2013 - 10:50
*/

Static Function VerEnqRC()
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelEJZ := oModel:GetModel("EJZDETAIL")
Local nI,nJ
Local aOrd      := SaveOrd({"ELC"})
ELC->(DbSetOrder(1)) //ELC_FILIAL + ELC_CODENQ

Begin Sequence

For nI := 1 To oModelEJZ:Length()
   oModelEJZ:GoLine(nI)
   If !oModelEJZ:IsDeleted()
      For nJ := 1 To 3
         If !Empty(oModelEJZ:GetValue("EJZ_ENQ0"+AllTrim(Str(nJ)))) .And. Empty(oModelEJZ:GetValue("EJZ_RC0"+AllTrim(Str(nJ))))
            If ELC->(DbSeek(xFilial("ELC")+AvKey(oModelEJZ:GetValue("EJZ_ENQ0"+AllTrim(Str(nJ))),"ELC_CODENQ"))) .And. ELC->ELC_INDRC == "S"
               lRet := .F.
               EasyHelp("O serviço " + AllTrim(oModelEJZ:GetValue("EJZ_ITEM")) + " possui o enquadramento " + oModelEJZ:GetValue("EJZ_ENQ0"+AllTrim(Str(nJ))) + " que necessita do preenchimento do 'Nro. RC.'","Aviso")
               Break
            EndIf
         ElseIf Empty(oModelEJZ:GetValue("EJZ_ENQ0"+AllTrim(Str(nJ)))) .And. !Empty(oModelEJZ:GetValue("EJZ_RC0"+AllTrim(Str(nJ))))
            lRet := .F.
            EasyHelp("O serviço " + AllTrim(oModelEJZ:GetValue("EJZ_ITEM")) + " possui 'Nro. Rc.' sem enquadramento.","Aviso")
            Break
         EndIf      
      Next nJ
   EndIf
Next nI 

End Sequence
RestOrd(aOrd,.T.)
Return lRet 
          
/*
Programa   : RS400Legenda()
Objetivo   : Tela de legendas das cores de marcação.
Retorno    : 
Autor      : Fabio Satoru Yamamoto
Data       : 18/03/2013
*/
Function RS400Legenda()
Local aLegenda:= {}

   AAdd(aLegenda, {"BR_VERMELHO", 'Aguardando registro no SISCOSERV'})
   AAdd(aLegenda, {"BR_AZUL" , 'Parcialmente registrado no SISCOSERV'}) 
   AAdd(aLegenda, {"BR_VERDE"   , 'Registrado no SISCOSERV'}) 
   BrwLegenda("Registro de Serviços", 'Legendas', aLegenda) //Legenda

Return

/*
Programa   : RS400Atua()
Objetivo   : Atualiza tela de Registro de Serviços
Retorno    : 
Autor      : Rafael Ramos Capuano
Data       : 27/03/2013
*/

Function RS400Atua()
   If Type("oBrowseUp") == "O"
      oBrowseUp:Refresh()
   EndIf

   If Type("oBrowseDown") == "O"
      oBrowseDown:Refresh(.T.)
   EndIf
Return Nil

/*
Programa   : EJYMsDocument()
Objetivo   : Função utilizada para chamada da rotina de vinculo de documento no metodo "oView:AddUserButton".
Autor      : Fabio Satoru Yamamoto
Data       : 03/04/2013
*/
//Deve existir objeto OMODEL ativo.
Static Function EJYMsDocument()                                                          
Local oModel    := FWModelActive()
Local nOperacao := oModel:nOperation
Private aRotina := MenuDef()//FSY - 17/01/2014 - Necessario para MsDocument()
If nOperacao == 4//4 = ALTERAÇÃO
   MsDocument( "EJY", EJY->(RecNo()), 1,)
Else
   MsgInfo("Opção permitida apenas para alteração!")
End If 
Return .T. 

/*
Programa   : EL9MsDocument()
Objetivo   : Função utilizada para chamada da rotina de vinculo de documento no metodo "oView:AddUserButton".
Autor      : Fabio Satoru Yamamoto
Data       : 03/04/2013
*/
//Deve existir objeto OMODEL ativo.
Static Function EL9MsDocument()
Local oModel    := FWModelActive()
Local nOperacao := oModel:nOperation
If nOperacao == 4//4 = ALTERAÇÃO
   MsDocument( "EL9", EL9->(RecNo()), 1,)
Else
   MsgInfo("Opção permitida apenas para alteração!")
End If 
Return .T.

/*
Programa   : RS400GeraPgto(cTpProc,cReg)
Objetivo   : Atualiza os pagamentos/faturamentos do Registro de Aquisição ou Venda de Serviços 
Parâmetros : cTipo - Tipo de Processo, cReg - Registro 
Retorno    : Lógico
Autor      : Rafael Ramos Capuano
Data/Hora  : 08/04/2013 17:20 
Revisao    : 
*/

Function RS400GeraPgto(cTpReg,cReg)
Local lRet          := .T.
Local cChave        := ""
Local aOrd          := SaveOrd({"EJZ","ELA","EEQ","EL9","EL1"})
Local aProc         := {}
Local aEL9Auto      := {}
Local dDtBaixa      := CTOD("")
Local lExclPagto    := .F.
Local lExisteServ   := .F.
Private lMsErroAuto := .F.
Default cTpReg      := "", cReg := ""
 
ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
   EEQ->(DbSetOrder(4)) //EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB+EEQ_PARC
Else
   EEQ->(DbSetOrder(15)) //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO+EEQ_PARC  // GFP - 26/05/2015
EndIf
EJZ->(DbSetOrder(3)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES+EJZ_SEQPRC
EL9->(DbSetOrder(1)) //EL9_FILIAL+EL9_TPPROC+EL9_REGIST_EL9_SEQPAG
EL1->(DbSetOrder(2)) //EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQPAG
                                             
Begin Sequence     
   If !Empty(cTpReg) .And. !Empty(cReg)
      /*RRC - 21/10/2013 - Antes da atualização dos pagamentos, verifica se existe algum pagamento inválido na base: Para os casos em que o Processo não está mais neste RAS,
      ou não existe parcela de câmbio liquidada (Aquisição) ou invoice gerada (Venda).*/
      If EL9->(DbSeek(xFilial("EL9")+cTpReg+cReg))
         Do While EL9->(!Eof()) .And. EL9->(EL9_FILIAL+EL9_TPPROC+EL9_REGIST) == xFilial("EL9")+cTpReg+cReg
            lExclPagto  := .F.
            lExisteServ := .F.
            //Só poderá tentar a exclusão se o status do pagamento for "Aguardando Registro" ou "Registrado"
            If EL9->EL9_STTSIS == "1" .Or. EL9->EL9_STTSIS == "2"
               If EL1->(DbSeek(xFilial("EL1")+cTpReg+cReg+EL9->EL9_SEQPAG))
                  Do While EL1->(!Eof()) .And. EL1->(EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQPAG) == xFilial("EL1")+cTpReg+cReg+EL9->EL9_SEQPAG
                     //Verifica se o Processo possui RAS/RVS
                     If !EJZ->(DbSeek(xFilial("EJZ")+cTpReg+EL1->EL1_PROCES))
                        lExclPagto := .T.
                     Else
                        //Verifica se está comparando com o mesmo RAS/RVS   
                        Do While EJZ->(!Eof()) .And. EJZ->(EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES) == xFilial("EJZ")+cTpReg+EL1->EL1_PROCES
                           If EJZ->EJZ_REGIST == cReg
                              lExisteServ := .T.
                              //Quando o tipo for de Aquisição, caso o processo do serviço referente ao pagamento não está mais neste RAS e não tem parcela de câmbio liquidado, deve ser excluído
                              If cTpReg == "A"
                                 If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015                                 
                                    lExclPagto := !EEQ->(DbSeek(xFilial("EEQ")+AvKey(EL1->EL1_NRINVO,"EEQ_NRINVO")+AvKey(cTpReg+EL1->EL1_PROCES,"EEQ_PREEMB")+AvKey(EL1->EL1_PARC,"EEQ_PARC"))) .Or. If( EEQ->EEQ_MODAL == "2", Empty(EEQ->EEQ_DTCE)  ,Empty(EEQ->EEQ_PGT) ) 
                                 Else                                                                                                                                                                                                           //NCF - 16/03/2018 - Liq.Cambio com Mov. Exterior é caraterizado como liquidação quando data de credito ext. estiver preenchida.
                                    lExclPagto := !EEQ->(DbSeek(xFilial("EEQ")+AvKey(EL1->EL1_TPPROC,"EEQ_TPPROC")+AvKey(/*cTpReg+*/EL1->EL1_PROCES,"EEQ_PROCES")+AvKey(EL1->EL1_NRINVO,"EEQ_NRINVO")+AvKey(EL1->EL1_PARC,"EEQ_PARC"))) .Or. If( EEQ->EEQ_MODAL == "2", Empty(EEQ->EEQ_DTCE)  ,Empty(EEQ->EEQ_PGT) )  // GFP - 26/05/2015                                 
                                 EndIf
                                 Exit
                              //Quando o tipo for de Venda, caso o processo do serviço referente ao faturamento não está mais neste RVS e não tem invoice (fatura), deve ser excluído
                              ElseIf cTpReg == "V"
                                 lExclPagto := !ELA->(DbSeek(xFilial("ELA")+cTpReg+EL1->EL1_PROCES+AvKey(EL1->EL1_NRINVO,"ELA_NRINVO")))
                                 Exit                              
                              EndIf
                           EndIf
                           EJZ->(DbSkip())                    
                        EndDo
                        //Se o serviço relacionado ao pagamento/faturamento não estiver mais vinculado ao RAS/RVS em questão deve excluir
                        If !lExisteServ
                           lExclPagto := .T.
                        EndIf
                     EndIf
                     EL1->(DbSkip())
                  EndDo
               EndIf
               If lExclPagto
                  aEL9Auto := {}
                  aAdd(aEL9Auto,{'EL9_FILIAL',EL9->EL9_FILIAL ,NIL})
                  aAdd(aEL9Auto,{'EL9_TPPROC',EL9->EL9_TPPROC ,NIL})
                  aAdd(aEL9Auto,{'EL9_REGIST',EL9->EL9_REGIST ,NIL})
                  aAdd(aEL9Auto,{'EL9_SEQPAG',EL9->EL9_SEQPAG ,NIL})
                  MSExecAuto({|a,b,c,d| ESSPS402(a,b,c,d)},aEL9Auto,,EXCLUIR,cTpReg)
                  If lMsErroAuto                                    
                     If !(ValType(NomeAutoLog()) == "U")
                        cMsg := MemoRead(NomeAutoLog())
                        FErase(NomeAutoLog())
                     EndIf
                     EasyHelp(cMsg)
                     Break
                  EndIf
               EndIf
            EndIf
            EL9->(DbSkip())
         EndDo
      EndIf
      
      //Atualiza os demais pagamentos/faturamentos de serviços cujos Processos ainda se encontram neste RAS/RVS
      EJZ->(DbSetOrder(1)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQREG
      If EJZ->(DbSeek(xFilial("EJZ")+AvKey(cTpReg,"EJZ_TPPROC")+AvKey(cReg,"EJZ_REGIST")))
         Do While EJZ->(!Eof()) .And. xFilial("EJZ") == EJZ->EJZ_FILIAL .And. EJZ->EJZ_TPPROC == AvKey(cTpReg,"EJZ_TPPROC") .And. EJZ->EJZ_REGIST == AvKey(cReg,"EJZ_REGIST")
            If ELA->(DbSeek(xFilial("ELA")+AvKey(EJZ->EJZ_TPPROC,"ELA_TPPROC")+AvKey(EJZ->EJZ_PROCES,"ELA_PROCES")))
               //Atualiza a invoice para cada processo vinculado ao Registro, caso haja mais de um serviço do mesmo processo, não é necessário atualizar novamente
               If aScan(aProc,{|X| X == EJZ->EJZ_PROCES}) == 0
                  aAdd(aProc, EJZ->EJZ_PROCES)
                  Do While ELA->(!Eof()) .And. ELA->ELA_FILIAL == xFilial("ELA") .And. ELA->ELA_TPPROC == AvKey(EJZ->EJZ_TPPROC,"ELA_TPPROC") .And. ELA->ELA_PROCES == AvKey(EJZ->EJZ_PROCES,"ELA_PROCES")
                     If ELA->ELA_TPPROC == "V"
                        If !IS400GeraPgto(,ELA->ELA_TPPROC,ELA->ELA_PROCES,ELA->ELA_NRINVO,.T.)
                           Break
                        EndIf
                     ElseIf ELA->ELA_TPPROC == "A"
                        If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
                           cChave := xFilial("EEQ")+AvKey(ELA->ELA_NRINVO,"EEQ_NRINVO")+AvKey(ELA->ELA_TPPROC+ELA->ELA_PROCES,"EEQ_PREEMB")
                           cCond := 'EEQ->EEQ_FILIAL + EEQ->EEQ_NRINVO + EEQ->EEQ_PREEMB'
                        Else
                           cChave := xFilial("EEQ")+AvKey(ELA->ELA_TPPROC,"EEQ_TPPROC")+AvKey(ELA->ELA_PROCES,"EEQ_PROCES")+AvKey(ELA->ELA_NRINVO,"EEQ_NRINVO")  // GFP - 26/05/2015
                           cCond := 'EEQ->(EEQ_FILIAL+EEQ_TPPROC+EEQ_PROCES+EEQ_NRINVO)'
                        EndIf

                        If EEQ->(DbSeek(cChave))						    
                           Do While EEQ->(!Eof()) .And. cChave == &cCond
                              //RRC - 28/08/2013 - Só deve gerar o pagamento caso tenha liquidado a parcela de câmbio
                              dDtBaixa := CTOD("")
                              If EEQ->EEQ_MODAL == "1"
                                 dDtBaixa := EEQ->EEQ_PGT
                              Else
                                 dDtBaixa := EEQ->EEQ_DTCE
                              EndIf
                              // MPG - 07/01/2020
                              // a data de baixa vem da chamada anterior podendo ser a data da baixa ou a data de inicio do serviço
                              // caso a data de inicio seja maior que a data do pagamento deve ser a data de inicio e vice-versa
                              if dDtBaixa < EJY->EJY_DTINI
                                 dDtBaixa := EJY->EJY_DTINI
                              endif
                              If !Empty(dDtBaixa)
                                 If !PS402Pagto(EEQ->(Recno()),3,dDtBaixa,,.T.)
                                    Break
                                 EndIf
                              EndIf
                              EEQ->(DbSkip())
                           EndDo
                        EndIf
                     EndIf
                     ELA->(DbSkip())
                  EndDo
               EndIf
            EndIf
            EJZ->(DbSkip())
         EndDo
      EndIf
   EndIf
End Sequence
RestOrd(aOrd,.T.)
Return lRet

/*
Programa   : RS400DelPgto()
Objetivo   : Exclui os pagamentos/faturamentos "Em aberto" do Registro de Aquisição ou Venda de Serviços 
Parâmetros : cReg - Registro
Retorno    : Lógico
Autor      : Rafael Ramos Capuano
Data/Hora  : 11/04/2013 09:34 
Revisao    : 
*/

Static Function RS400DelPgto()
Local lRet   := .T.
Local cChave := "", cMsg := ""
Local aOrd   := SaveOrd({"EL9","EL1"})
Local aEL9Auto := {}
Local aEL1Auto := {}
Local aEL1Info := {}
Private lMsErroAuto := .F.

EL9->(DbSetOrder(1)) //EL9_FILIAL+EL9_TPPROC+EL9_REGIST+EL9_SEQPAG
EL1->(DbSetOrder(2)) //EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQPAG

Begin Sequence

   EL9->(DbSeek(xFilial("EL9")+AvKey(EJY->EJY_TPPROC,"EL9_TPPROC")+AvKey(EJY->EJY_REGIST,"EL9_REGIST")))
   Do While EL9->(!Eof()) .And. EL9->(EL9_FILIAL+EL9_TPPROC+EL9_REGIST) == xFilial("EL9")+AvKey(EJY->EJY_TPPROC,"EL9_TPPROC")+AvKey(EJY->EJY_REGIST,"EL9_REGIST")
      //Se entrou na função, é porque não existem pagamentos "Registrados" ou "Aguardando Cancelamento" no Siscoserv, mas podem haver "Cancelados" que não serão excluídos
      If EL9->EL9_STTSIS <> "4"  
         aEL9Auto := {}
         aAdd(aEL9Auto,{'EL9_FILIAL',EL9->EL9_FILIAL ,NIL})
         aAdd(aEL9Auto,{'EL9_TPPROC',EL9->EL9_TPPROC ,NIL})
         aAdd(aEL9Auto,{'EL9_REGIST',EL9->EL9_REGIST ,NIL})
         aAdd(aEL9Auto,{'EL9_SEQPAG',EL9->EL9_SEQPAG ,NIL})
      
         cChave := xFilial("EL1") + AvKey(EL9->EL9_TPPROC,"EL1_TPPROC") + AvKey(EL9->EL9_REGIST,"EL1_REGIST") + AvKey(EL9->EL9_SEQPAG,"EL1_SEQPAG")
         If EL1->(DbSeek(cChave))
            aEL1Auto := {}
            Do While EL1->(!Eof()) .And. EL1->(EL1_FILIAL + EL1_TPPROC + EL1_REGIST + EL1_SEQPAG) == cChave 
               aEL1Info := {}
               aAdd(aEL1Info,{"EL1_FILIAL"   ,EL1->EL1_FILIAL ,Nil})
               aAdd(aEL1Info,{"EL1_TPPROC"   ,EL1->EL1_TPPROC ,Nil})
               aAdd(aEL1Info,{"EL1_REGIST"   ,EL1->EL1_REGIST ,Nil})
               aAdd(aEL1Info,{"EL1_SEQREG"   ,EL1->EL1_SEQREG ,Nil})
               aAdd(aEL1Info,{"EL1_SEQPAG"   ,EL1->EL1_SEQPAG ,Nil})
               aAdd(aEL1Auto,aClone(aEL1Info))
               EL1->(DbSkip())
            EndDo
        
            MSExecAuto({|a,b,c,d| ESSPS402(a,b,c,d)},aEL9Auto,aEL1Auto,EXCLUIR,EJY->EJY_TPPROC)
            If lMsErroAuto                                    
               If !(ValType(NomeAutoLog()) == "U")
                  cMsg := MemoRead(NomeAutoLog())
                  FErase(NomeAutoLog())
               EndIf
               EasyHelp(cMsg)
               Break
            EndIf
         EndIf
      EndIf
      EL9->(DbSkip())      
   EndDo
End Sequence
RestOrd(aOrd,.T.)
Return lRet

//MFR 02/08/2017 WCC-526892 TE-6334
Function RS400GetPrazo(dDtIni,lRasRvs)
Local dDtPrazo
Local nMes
Local nAno
//MFR 02/08/2017 WCC-526892 TE-6334
Default lRasRvs := .F.
//MFR 02/08/2017 WCC-526892 TE-6334
if !lRasRvs .AND. EasyGParam("MV_ESS0031",.T.)
   nMes := Month(dDtIni) + EasyGParam("MV_ESS0031",.T.,1)
Else
   nMes := Month(dDtIni) + EasyGParam("MV_AVG0225",.T.,1)
EndIf   

nAno := Year(dDtIni)+Int(nMes/12)
nMes := nMes%12

dDtPrazo := CTOD("01/"+StrZero(nMes+1,2)+"/"+StrZero(nAno,4))-1

Return DataValida(dDtPrazo,.F.)

Static Function AtuView(oView)
Local lRet := .T.
Local nI   := 1
Local nPos := aScan(oView:aUserButtons,    {|X|  Alltrim(X[1]) == "Conhecimento"}) 
Local nPos2:= aScan(oView:aUserButtons,    {|X|  AllTrim(X[1]) == "Seleção de Processos"}) 
//Verifica se já existe o botão "Conhecimento" na view, pois só deve incluí-lo se for uma alteração
If Altera .And. nPos <= 0
   oView:AddUserButton("Conhecimento"        , "CLIPS",{|| EJYMsDocument()})  
ElseIf !Altera .And. nPos > 0
   aDel(oView:aUserButtons, nPos)
   aSize(oView:aUserButtons, Len(oView:aUserButtons) - 1)  
EndIf       
       
Return lRet 
/*
Função     : RS400FilProc()
Parâmetros : 
Retorno    : lRet
Objetivos  : Filtra os processos para consulta padrão EJW, através do tipo ("Aquisição" ou "Venda") e cujo status seja "Aguardando Registro" ou "Parcialmente Registrado"
             para trazer os serviços
Autor      : Rafael Ramos Capuano
Data/Hora  : 26/08/2013
Revisao    : 
Obs.       :
*/ 

Function RS400FilProc() 
Local lRet := .F.
Return lRet := EJW->EJW_TPPROC == RS400Info("EJY_TPPROC") .And. (EJW->EJW_STTPED == "1" .Or. EJW->EJW_STTPED == "2")


/*
Programa   : PS400SXB()
Objetivo   : Seleciona a consulta padrão caso for aquisição ou venda.
Retorno    : cRetorno
Autor      : Fabio Satoru Yamamoto
Data       : 21/10/2013
*/   
Function RS400SXB()
Local cRetorno:= ""

Do Case
   Case cTpReg == "A"//Aquisição
      cRetorno:= ConPad1(,,,'IMP',,)
   Case cTpReg == "V"//Venda
      cRetorno:= ConPad1(,,,'EXP3',,)
End Case

Return cRetorno


/*
Programa   : RS400SXBRET()
Objetivo   : Retorno utilizado pelo SXB - EJW4
Retorno    : cRet
Autor      : Fabio Satoru Yamamoto
Data       : 21/10/2013
*/   
Function RS400SXBRET(cCampo)
Local cRet  := ""
Local cTipo := cTpReg

If cTipo == "A"
   Do Case
      Case cCampo == "EJY_CODEMP"
         cRet := SA1->A1_COD
      Case cCampo == "EJY_LOJEMP"
         cRet := SA1->A1_LOJA
      Case cCampo == "EJY_NOME"
         cRet := SA1->A1_NOME
      Case cCampo == "EJY_CGC"
         cRet := SA1->A1_CGC
   End Case

ElseIf cTipo == "V"
   Do Case
      Case cCampo == "EJY_CODEMP"
         cRet := SA2->A2_COD
      Case cCampo == "EJY_LOJEMP"
         cRet := SA2->A2_LOJA
      Case cCampo == "EJY_NOME"
         cRet := SA2->A2_NOME
      Case cCampo == "EJY_CGC"
         cRet := SA2->A2_CGC
   End Case

End If
Return cRet

/*
Programa   : PS400SXB()
Objetivo   : Seleciona a consulta padrão caso for aquisição ou venda.
Retorno    : cRetorno
Autor      : Fabio Satoru Yamamoto
Data       : 21/10/2013
*/
Function RS400INI()
Local cRetorno:= ""

Do Case
   Case cTpReg == "A"//Aquisição
      cRetorno:= ConPad1(,,,'IMP',,)
   Case cTpReg == "V"//Venda
      cRetorno:= ConPad1(,,,'EXP3',,)
End Case

Return cRetorno

/*
Programa   : RS400INIBRW()
Objetivo   : Seleciona a consulta padrão caso for aquisição ou venda.
Retorno    : cRetorno
Autor      : Fabio Satoru Yamamoto
Data       : 21/10/2013
*/   
Function RS400INIBRW(cCampo)
Local cRetorno := ""
Local aOrd     := SaveOrd({"SA1","SA2"})
Local cTipo    := EJY->EJY_TPPROC //LGS-07/07/2016 

Do Case 
   Case cCampo == "EJY_DSCEMP"
      If cTipo == "A"//Aquisição
         cRetorno := Posicione("SA1",1,xFilial("SA1")+EJY->EJY_CODEMP+EJY->EJY_LOJEMP,"A1_NOME")
      ElseIf cTipo == "V"//Venda
         cRetorno := Posicione("SA2",1,xFilial("SA2")+EJY->EJY_CODEMP+EJY->EJY_LOJEMP,"A2_NOME")
      End If
End Case
RestOrd(aOrd,.T.)

Return cRetorno

/*
Programa   : RS400Excluir()
Objetivo   : Validação da exclusão do registro
Retorno    : NIL
Autor      : Guilherme Fernandes Pilan - GFP
Data       : 25/07/2014 - 11:01
Revisão    : wfs 23/05/17
             Correção do Alias usado no poscionamento de registro (de ejz para ejy).
             Alterado o momento da exibição da mensagem de validação.
             Alterado para permitir a exclusão do RAS/ RVS originado replicação de dados
             do processo de aquisição/ venda, caso o usuário opte pela opção.
*/ 
*-----------------------------------------*
Function RS400Excluir(cAlias,nReg,nOpc)   
*-----------------------------------------*
/*Local aOrd := SaveOrd("EJW")
Begin Sequence
   EJZ->(DbGoTo(nReg))
   EJW->(DbSetOrder(1))
   EJW->(DbSeek(xFilial("EJW")+EJZ->(EJZ_TPPROC + EJZ_PROCES)))
   If EJW->EJW_INT == "S" .And. !AvFlags("ESS_EAI") // Integrado via CSV
      EasyHelp("Não é permitido excluir um registro originado através de uma integração." + ENTER +;
               "A exclusão do processo " + AllTrim(EJW->EJW_PROCES) + " deve ser efetuada via integração.","Aviso")
      Break
   EndIf   
   FWExecView('Excluir registro','VIEWDEF.ESSRS400', MODEL_OPERATION_DELETE,  , { || .T. }, { || .T.} )
End Sequence         
RestOrd(aOrd,.T.)*/

FWExecView('Excluir registro','VIEWDEF.ESSRS400', MODEL_OPERATION_DELETE,  , { || .T. }, { || RS400ValExc(nReg)} )

Return Nil

/*
Programa   : RS400ValExc()
Objetivo   : Validação da exclusão do registro
             Verificar se houve replicação automática do registro de serviço e alertar o usuário,
             quando realizada exclusão manual.
Parâmetro  : nReg
Retorno    : Lógico
Autor      : wfs
Data       : mai/2017
Revisão    : 
*/ 
*-----------------------------------------*
Function RS400ValExc(nReg)
*-----------------------------------------*
Local aOrd := SaveOrd("EJW")
Local lRet:= .T.
Local cMsg:= ""

Begin Sequence

   EJY->(DbGoTo(nReg))
   EJW->(DbSetOrder(1))
   EJW->(DbSeek(xFilial("EJW")+EJY->(EJY_TPPROC + EJY_PROCES)))
   If !lRs400Auto .And. EasyGParam("MV_ESS0003",, .F.) .And. EJW->EJW_INT == "S" .And. !AvFlags("ESS_EAI")
      cMsg:= "O processo " + AllTrim(EJW->EJW_PROCES) + " foi originado via integração com o módulo/ sistema " + AllTrim(EJW->EJW_ORIGEM) + "." + ENTER +;
             "É recomendável que a exclusão do processo seja efetuada via integração." + ENTER + ENTER +;
             "Deseja prosseguir?"
      lRet:= MsgYesNo(cMsg, "Aviso")
      If !lRet      
         Break
      EndIf
   EndIf   

End Sequence         

RestOrd(aOrd, .T.)
Return lRet


/*
Funcao     : RS400InfCpl()
Parametros : Nenhum
Retorno    : String
Objetivos  : Atualizar o campo EJY_COMPL com a Informação do campo EJW_COMPL
Autor      : Laercio G Souza Jr - LGS
Data/Hora  : 30/12/2014 - 10:00
*/
*----------------------------*
Function RS400InfCpl()
*----------------------------*
Local cRet

If EasyGParam("MV_ESS0024",,.F.) //O Conteudo inicializador do parametro é FALSO .F.
   aOrdEJW:= SaveOrd({"EJW"})
   EJW->(DbSetOrder(1))
   If EJW->(DbSeek(xFilial("EJW")+RS400Info("EJY_TPPROC")+M->EJY_PROCES))      
      cRet := EJW->EJW_COMPL
   EndIf
   RestOrd(aOrdEJW,.T.)
Else
   cRet := M->EJY_COMPL
EndIf

Return cRet


*---------------------------*
Function RS400VldNIF(cTable)
*---------------------------*
Local lRet := .T.
Local oModel, nOperacao
Default cTable := Alias()

Begin Sequence

   Do Case
      Case cTable == "EXJ"
         If Empty(M->EXJ_NIF) .AND. Empty(M->EXJ_MOTNIF)
            EasyHelp("Caso o campo 'NIF' não seja preenchido, é necessário que o campo 'Mot.NIF' seja informado com o motivo de não preenchimento do NIF.","Aviso")
            lRet := .F.
         EndIf
         If !Empty(M->EXJ_NIF) .AND. !Empty(M->EXJ_MOTNIF)
            EasyHelp("Somente é possível preencher o campo 'Mot.NIF' caso o NIF não seja informado.","Aviso")
            lRet := .F.
         EndIf
         If lRet
            M->A1_NIF := M->EXJ_NIF
         EndIf
      Case cTable == "SA2"
         If Empty(M->A2_NIFEX) .AND. Empty(M->A2_MOTNIF)
            EasyHelp("Caso o campo 'NIF' não seja preenchido, é necessário que o campo 'Mot.NIF' seja informado com o motivo de não preenchimento do NIF.","Aviso")
            lRet := .F.
         EndIf
         If !Empty(M->A2_NIFEX) .AND. !Empty(M->A2_MOTNIF)
            EasyHelp("Somente é possível preencher o campo 'Mot.NIF' caso o NIF não seja informado.","Aviso")
            lRet := .F.
         EndIf
      Case cTable == "EJY"
         oModel    := FWModelActive()
         nOperacao := oModel:nOperation
         If (nOperacao == 3 .OR. nOperacao == 4) .AND. (Empty(oModel:GetValue("EJYMASTER","EJY_NIF")) .AND. Empty(oModel:GetValue("EJYMASTER","EJY_MOTNIF")))
            EasyHelp("Caso o campo 'NIF' não seja preenchido, é necessário que o campo 'Mot.NIF' seja informado com o motivo de não preenchimento do NIF.","Aviso")
            lRet := .F.
         EndIf
         If (nOperacao == 3 .OR. nOperacao == 4) .AND. (!Empty(oModel:GetValue("EJYMASTER","EJY_NIF")) .AND. !Empty(oModel:GetValue("EJYMASTER","EJY_MOTNIF")))
            EasyHelp("Somente é possível preencher o campo 'Mot.NIF' caso o NIF não seja informado.","Aviso")
            lRet := .F.
         EndIf
   End Case

End Sequence

Return lRet

*--------------------------------*
Function RS400CBox(cCampo)
*--------------------------------*
Local cRet, cChave := ""
Local oModel := FWModelActive()

   Do Case
      Case cCampo == "EJY_TIPVIN"
         cRet := "0=Sem Vinculação;1=Filial;2=Sucursal;3=Controlada;4=Outras"
      Case cCampo == "EL9_STTSIS"
         cRet := "1=Aguardando registro no SISCOSERV;2=Registrado no SISCOSERV;3=Aguardando cancelamento no SISCOSERV;4=Cancelado no SISCOSERV;5=Aguardando Retificação no SISCOSERV"
      Case cCampo == "EL8_TIPENV"
         cRet := "1=Inclusão Registro;2=Retificação de Registro;3=Inclusão Aditivo;4=Retificação Aditivo;5=Inclusão Pagamento;6=Cancel. Pagamento;7=Retificação Pagamento"
   End Case

Return cRet

/*
*------------------------*
Function RS400VldGrv()
*------------------------*
Local lRet := .T.
Local oModel := FWModelActive()

If EasyGParam("MV_ESS0027",,9) >= 10
   If Empty(oModel:GetValue("EJYMASTER","EJY_TIPVIN")) .AND. RS400VldCBox()
      EasyHelp("É necessário preencher o campo 'Tip. Vinc.'.","Aviso")
      lRet := .F.
   EndIf
EndIf

Return lRet

*------------------------*
Function RS400VldCBox()
*------------------------*
If cTpReg=="A"
   cChave := xFilial("ELM")+AvKey(EJY->EJY_EXPORT,"ELM_CODFOR")+AvKey(EJY->EJY_LOJEXP,"ELM_LOJFOR")
   cCampos:= "ELM_FILIAL+ELM_CODFOR+ELM_LOJFOR"
   ELM->(DbSetOrder(2))
ElseIf cTpReg=="V"
   cChave := xFilial("ELM")+AvKey(EJY->EJY_IMPORT,"ELM_CODCLI")+AvKey(EJY->EJY_LOJIMP,"ELM_LOJCLI")
   cCampos:= "ELM_FILIAL+ELM_CODCLI+ELM_LOJCLI"
   ELM->(DbSetOrder(3))
EndIf
Return ELM->(DbSeek(cChave))
*/

*------------------------*
Function RS400DIRE()
*------------------------*
Local oModel  := FWModelActive(), oDlg
Local oView   := FWFormView():New()
Local oStruEL2  := FWFormStruct(2,"EL2",{|cCpo| MostrCpo(cCpo)},)
Local bOk := {|| nOpcA := 1, oDlg:End()}
Local bCancel := {|| nOpcA := 0, oDlg:End()}
Local nOperation := oModel:GetOperation()
Private oModelCap, oModelIt

If oModel:aModelStruct[1][2] == "EJWMASTER"
   oModelCap:= oModel:GetModel("EJWMASTER")
   oModelIt := oModel:GetModel("EJXDETAIL")
   Private cTpReg := cPed
Else
   oModelCap:= oModel:GetModel("EJYMASTER")
   oModelIt := oModel:GetModel("EJZDETAIL")
EndIf

If nOperation == 3 .OR. nOperation == 4
   FWExecView('Manutenção','VIEWDEF.ESSDC400', MODEL_OPERATION_UPDATE,  , { || .T. }, { || .T.}, 20 )
EndIf

Return .T.

*-------------------------*
Function RS400TipoVincRS(cTipo)
*-------------------------*
Local cRet       := "0"
Local cCodEmp    := ""
Local cLojEmp    := ""
Default cTipo    := cPed

If cTipo =="A"
   
   //MCF - 11/08/2016
   If EasyGParam("MV_ESS0021",,.F.) .And. !Empty(M->EJY_CODEMP) .And. !Empty(M->EJY_LOJEMP)
      cCodEmp := M->EJY_CODEMP
      cLojEmp := M->EJY_LOJEMP
   Else
      SA1->(DbSetOrder(3))
      If SA1->(DbSeek(xFilial()+SM0->M0_CGC))
         cCodEmp := SA1->A1_COD
         cLojEmp := SA1->A1_LOJA
      EndIf
   EndIf
   
   cChave := xFilial("ELM")+AvKey(cCodEmp,"ELM_CODCLI")+AvKey(cLojEmp,"ELM_LOJCLI")+AvKey(M->EJY_EXPORT,"ELM_CODFOR")+AvKey(M->EJY_LOJEXP,"ELM_LOJFOR")
   ELM->(DbSetOrder(1))

ElseIf cTipo =="V"

   If EasyGParam("MV_ESS0021",,.F.) .And. !Empty(M->EJY_CODEMP) .And. !Empty(M->EJY_LOJEMP)
      cCodEmp := M->EJY_CODEMP
      cLojEmp := M->EJY_LOJEMP
   Else
      SA2->(DbSetOrder(3))
      If SA2->(DbSeek(xFilial()+SM0->M0_CGC))
         cCodEmp := SA2->A2_COD
         cLojEmp := SA2->A2_LOJA
      EndIf
   EndIf
   
   cChave := xFilial("ELM")+AvKey(M->EJY_IMPORT,"ELM_CODCLI")+AvKey(M->EJY_LOJIMP,"ELM_LOJCLI")+AvKey(cCodEmp,"ELM_CODFOR")+AvKey(cLojEmp,"ELM_LOJFOR")
   ELM->(DbSetOrder(1))
EndIf

If ELM->(DbSeek(cChave))
   cRet := ELM->ELM_TIPVIN
EndIf

Return cRet
