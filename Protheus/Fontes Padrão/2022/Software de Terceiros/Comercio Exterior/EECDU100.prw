#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'EECDU100.ch'
#Include 'topconn.ch'

#define ENTER CHR(13)+CHR(10)
/*/{Protheus.doc} EECDU100
   (rotina para histórico e controle da geração e transmissão da DUE)
   @type  Function
   @author Miguel Prado Gontijo
   @since 28/03/2018
   @version 1
   @param param, param_type, param_descr
   @return returno,return_type, return_description
   @example
   (examples)
   #@see (lINCLUDEinks_or_references) 'TOTVS.CH'
   /*/
Function EECDU100(xRotAuto,nOpcAuto)
 
Local aArea       := GetArea()
Local aAreaEK0    := EK0->(GetArea())
Local cFiltro     := iif( IsInCallStack("EECAE100") , "EK0_FILIAL == '"+EEC->EEC_FILIAL+"' .AND. EK0_PROCES == '"+EEC->EEC_PREEMB+"'" , "" )

Private cTitulo   := OemToAnsi(STR0001) //"Transmissão DUE"

Private lDueAuto  := ValType(xRotAuto) == "A" .And. ValType(nOpcAuto) == "N"
Private aRotAuto  := iif( lDueAuto, aclone(xRotAuto) , nil )

Private aRotina   := MenuDef()
Private oBrowse

If ! lDueAuto //xRotAuto == NIL
   //Instânciando FWMBrowse - Somente com dicionário de dados
   oBrowse := FWMBrowse():New()
   oBrowse:setmenudef("EECDU100")
   //oBrowse:AddFilter("Embarque",cFiltro)
   oBrowse:SetFilterDefault( cFiltro )
    
   //Setando a tabela de cadastro de Autor/Interprete
   oBrowse:SetAlias("EK0")

   //Setando a descrição da rotina
   oBrowse:SetDescription(STR0001)
   
    //Legendas
   oBrowse:AddLegend( "EK0->EK0_STATUS == '1'", "BR_AMARELO"    , STR0002 )                // "Aguardando transmissão"
   oBrowse:AddLegend( "EK0->EK0_STATUS == '2'", "BR_VERDE"      , STR0003 )                // "Transmitido com sucesso"
   oBrowse:AddLegend( "EK0->EK0_STATUS == '3'", "BR_VERMELHO"   , STR0004 )                // "Falha na transmissão"
   oBrowse:AddLegend( "EK0->EK0_STATUS == '4'", "BR_PRETO"      , "Embarque Cancelado" )   // 'Embarque Cancelado'
   oBrowse:AddLegend( "EK0->EK0_STATUS == '5'", "BR_LARANJA"    , "DUE Manual" )           // 'DUE Manual'

   //Ativa a Browse
   oBrowse:Activate()
Else
   FWMVCRotAuto(ModelDef(),"EK0",nOpcAuto,{{"EK0MASTER",xRotAuto}})
EndIf

RestArea(aAreaEK0)
RestArea( aArea )

Return
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Menu com as rotinas                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
   Local aRot := {}

   ADD OPTION aRot TITLE 'Visualizar'          ACTION 'VIEWDEF.EECDU100'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
   ADD OPTION aRot TITLE 'Legenda'             ACTION 'LegEK0()'           OPERATION 6                      ACCESS 0 //OPERATION X
   if isMemVar("lDueAuto") .and. lDueAuto
      ADD OPTION aRot TITLE 'Incluir'          ACTION 'VIEWDEF.EECDU100'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
   else
      ADD OPTION aRot TITLE 'Gerar Declaração' ACTION 'GeraDecl()'         OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION X
   endif
   ADD OPTION aRot TITLE 'Transmitir'          ACTION 'DUETransmit()'      OPERATION 6                      ACCESS 0 //OPERATION X
   ADD OPTION aRot TITLE 'Transmitir DUE Lote' ACTION 'EECDU300()'         OPERATION 6                      ACCESS 0 //OPERATION X
   ADD OPTION aRot TITLE 'Excluir'             ACTION 'VIEWDEF.EECDU100'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
   //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.EECDU100' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4

Return aRot
/*---------------------------------------------------------------------*
 | Func:  LegEK0                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Legendas                                                     |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function LegEK0()
Local _aLegenda := {}

_aLegenda := {  {'BR_AMARELO'    , STR0002 },;               // 'Aguardando transmissão'
                {'BR_VERDE'      , STR0003 },;               // 'Transmitido com sucesso'
                {'BR_VERMELHO'   , STR0004 },;               // 'Falha na transmissão'
                {'BR_PRETO'      , "Embarque Cancelado" },;  // 'Embarque Cancelado'
                {'BR_LARANJA'    , "DUE Manual" }}           // DUE Manual

BrwLegenda( "Status", "Legenda", _aLegenda)

Return .t.
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 Static Function ModelDef()

    //Criação do objeto do modelo de dados
    Local oModel  := Nil
    Local bPost   := { |o| DU100VALID(o) }
    Local bCommit := { |oModel| du100Commit(oModel) }
    //Criação da estrutura de dados utilizada na interface
    Local oStEK0 := FWFormStruct(1, "EK0")
    Local oStEK1 := FWFormStruct(1, "EK1")
    Local oStEK2 := FWFormStruct(1, "EK2")
    Local oStEK3 := FWFormStruct(1, "EK3")
    Local oStEK4 := FWFormStruct(1, "EK4")

    Local oStEK7
    Local oStEK8
    Local oStEKK 
    Local oMdlEvent := DU100EV():New()
    
    if avflags("DU-E3.1")
        oStEK7 := FWFormStruct(1, "EK7")
        oStEK8 := FWFormStruct(1, "EK8")
    endif
    If Avflags("STATUS_DUE")
       oStEKK := FWFormStruct(1, "EKK")
    EndIf

    aRelEK1 := {{"EK1_FILIAL","EK0_FILIAL"},;
                {"EK1_PROCES","EK0_PROCES"},;
                {"EK1_NUMSEQ","EK0_NUMSEQ"}}

    aRelEK2 := {{"EK2_FILIAL","EK1_FILIAL"},;
                {"EK2_PROCES","EK1_PROCES"},;
                {"EK2_NUMSEQ","EK1_NUMSEQ"}}

    aRelEK3 := {{"EK3_FILIAL","EK2_FILIAL"},;
                {"EK3_PROCES","EK2_PROCES"},;
                {"EK3_NUMSEQ","EK2_NUMSEQ"}}

    aRelEK4 := {{"EK4_FILIAL","EK2_FILIAL"},;
                {"EK4_PROCES","EK2_PROCES"},;
                {"EK4_NUMSEQ","EK2_NUMSEQ"}}

    if avflags("DU-E3.1")
        aRelEK7 := {{"EK7_FILIAL","EK2_FILIAL"},;
                    {"EK7_PREEMB","EK2_PROCES"},;
                    {"EK7_NUMSEQ","EK2_NUMSEQ"}}

        aRelEK8 := {{"EK8_FILIAL","EK7_FILIAL"},;
                    {"EK8_PREEMB","EK7_PREEMB"},;
                    {"EK8_NUMSEQ","EK7_NUMSEQ"}}
    endif

    If Avflags("STATUS_DUE")
      aRelEKK := {{"EKK_FILIAL","EK0_FILIAL"},;
                  {"EKK_PROCES","EK0_PROCES"},;
                  {"EKK_NUMSEQ","EK0_NUMSEQ"}}
    EndIf

    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("EECDU100",/*bPre*/, bPost ,bCommit,/*bCancel*/)
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("EK0MASTER",/*cOwner*/ ,oStEK0 )

    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'EK0_FILIAL','EK0_PROCES','EK0_NUMSEQ'})

    oModel:AddFields("EK1DETAIL","EK0MASTER",oStEK1 )
    oModel:AddGrid(  "EK2DETAIL","EK1DETAIL",oStEK2 )
    oModel:AddGrid(  "EK3DETAIL","EK2DETAIL",oStEK3 )
    oModel:AddGrid(  "EK4DETAIL","EK2DETAIL",oStEK4 )
    if avflags("DU-E3.1")
        oModel:AddGrid(  "EK7DETAIL","EK2DETAIL",oStEK7 )
        oModel:AddGrid(  "EK8DETAIL","EK7DETAIL",oStEK8 )
    endif
    If Avflags("STATUS_DUE")
       oModel:AddGrid(  "EKKDETAIL","EK0MASTER",oStEKK )
    EndIf
    // Adicionar a tabela nova para exibir o histórico de status

    oModel:SetRelation("EK1DETAIL",aRelEK1, EK1->(IndexKey(1)))
    oModel:SetRelation("EK2DETAIL",aRelEK2, EK2->(IndexKey(1)))
    oModel:SetRelation("EK3DETAIL",aRelEK3, EK3->(IndexKey(1)))
    oModel:SetRelation("EK4DETAIL",aRelEK4, EK4->(IndexKey(1)))
    if avflags("DU-E3.1")
        oModel:SetRelation("EK7DETAIL",aRelEK7, EK7->(IndexKey(1)))
        oModel:SetRelation("EK8DETAIL",aRelEK8, EK8->(IndexKey(1)))
    endif
    If Avflags("STATUS_DUE")
       oModel:SetRelation("EKKDETAIL",aRelEKK, EKK->(IndexKey(1)))
    EndIf
    //Adicionando descrição ao modelo
    oModel:SetDescription(STR0001)
     
    //Setando a descrição do formulário
    oModel:GetModel("EK0MASTER"):SetDescription(STR0001)
    oModel:GetModel("EK1DETAIL"):SetDescription("Capa Embarque")
    oModel:GetModel("EK2DETAIL"):SetDescription("Itens Embarque / Itens NF")
    oModel:GetModel("EK3DETAIL"):SetDescription("NFs de Saída")
    oModel:GetModel("EK4DETAIL"):SetDescription("NFs de Entrada")
    if avflags("DU-E3.1")
        oModel:GetModel("EK7DETAIL"):SetDescription("Drawback Itens")
        oModel:GetModel("EK8DETAIL"):SetDescription("NFs Drawback Itens")
    endif
    oModel:GetModel("EK1DETAIL"):SetDescription("Historico de status da DUE")

    oModel:GetModel("EK1DETAIL"):SetOptional( .T. )
    oModel:GetModel("EK2DETAIL"):SetOptional( .T. )
    oModel:GetModel("EK3DETAIL"):SetOptional( .T. )
    oModel:GetModel("EK4DETAIL"):SetOptional( .T. )
    if avflags("DU-E3.1")
      oModel:GetModel("EK7DETAIL"):SetOptional( .T. )
      oModel:GetModel("EK8DETAIL"):SetOptional( .T. )
    endif
    If Avflags("STATUS_DUE")
       oModel:GetModel("EKKDETAIL"):SetOptional( .T. )
    EndIf
    
    oModel:InstallEvent("DU100EV", , oMdlEvent)

Return oModel
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()

    //Criação do objeto do modelo de dados da Interface
    Local oModel := FWLoadModel("EECDU100")
     
    //Criação da estrutura de dados utilizada na interface
    Local oStEK0 := FWFormStruct(2, "EK0")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'EK0_NOME|EK0_DTAFAL|'}
    Local oStEK1 := FWFormStruct(2, "EK1")  //, {|x| x $ "EK1_PROCES|EK1_NUMSEQ|EK1_TIPDUE|EK1_NRODUE|EK1_URFDSP|EK1_RECALF|EK1_EMFRRC|EK1_FOREXP"} )
    Local oStEK2 := FWFormStruct(2, "EK2")
    Local oStEK3 := FWFormStruct(2, "EK3")
    Local oStEK4 := FWFormStruct(2, "EK4")
    Local oStEK7
    Local oStEK8
    Local oStEKK

    //Criando oView como nulo
    Local oView := Nil
 
    if avflags("DU-E3.1")
        oStEK7 := FWFormStruct(2, "EK7")
        oStEK8 := FWFormStruct(2, "EK8")
    endif
    If Avflags("STATUS_DUE")
       oStEKK := FWFormStruct(2, "EKK")
    EndIf

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_EK0", oStEK0, "EK0MASTER")
    oView:AddField("VIEW_EK1", oStEK1, "EK1DETAIL")
    oView:AddGrid( "VIEW_EK2", oStEK2, "EK2DETAIL")
    oView:AddGrid( "VIEW_EK3", oStEK3, "EK3DETAIL")
    oView:AddGrid( "VIEW_EK4", oStEK4, "EK4DETAIL")
    if avflags("DU-E3.1")
        oView:AddGrid( "VIEW_EK7", oStEK7, "EK7DETAIL")
        oView:AddGrid( "VIEW_EK8", oStEK8, "EK8DETAIL")
    endif
    If Avflags("STATUS_DUE")
       oView:AddGrid( "VIEW_EKK", oStEKK, "EKKDETAIL")
    EndIf
   // Adicionar a tabela nova para exibir o histórico de status

    //FOLDERR PARA CAPA E ITENS EMBARQUE, NFS ENTRADA E SAIDA
    oView:CreateFolder( 'EK0FOLDER') //, 'TELA')

    oView:AddSheet('EK0FOLDER',"DUE","Histórico Due")
    oView:CreateHorizontalBox( 'BOXEK0', 100, , , 'EK0FOLDER', 'DUE')

    // ADCIONA A ABA PARA A EK1 E EK2
    oView:AddSheet('EK0FOLDER',"EMB","Processo Embarque")
    oView:CreateHorizontalBox( 'BOXEK1', 50, , , 'EK0FOLDER', 'EMB')
    oView:CreateHorizontalBox( 'BOXEK2', 50, , , 'EK0FOLDER', 'EMB')

    // ADCIONA A ABA PARA A EK3 E EK4
    oView:AddSheet('EK0FOLDER',"NFS","Notas Fiscais")
    oView:CreateHorizontalBox( 'BOXEK3', 50, , , 'EK0FOLDER', 'NFS')
    oView:CreateHorizontalBox( 'BOXEK4', 50, , , 'EK0FOLDER', 'NFS')

    if avflags("DU-E3.1")
        // ADCIONA A ABA PARA A EK7 E EK8
        oView:AddSheet('EK0FOLDER',"DRB","Drawback")
        oView:CreateHorizontalBox( 'BOXEK7', 50, , , 'EK0FOLDER', 'DRB')
        oView:CreateHorizontalBox( 'BOXEK8', 50, , , 'EK0FOLDER', 'DRB')
    endif

    If Avflags("STATUS_DUE")
       oView:AddSheet('EK0FOLDER',"STA","Histórico de status DUE")
       oView:CreateHorizontalBox( 'BOXEKK', 100, , , 'EK0FOLDER', 'STA')
    EndIf

    oView:SetOwnerView("VIEW_EK0","BOXEK0")
    oView:SetOwnerView("VIEW_EK1","BOXEK1")
    oView:SetOwnerView("VIEW_EK2","BOXEK2")
    oView:SetOwnerView("VIEW_EK3","BOXEK3")
    oView:SetOwnerView("VIEW_EK4","BOXEK4")
    if avflags("DU-E3.1")
        oView:SetOwnerView("VIEW_EK7","BOXEK7")
        oView:SetOwnerView("VIEW_EK8","BOXEK8")
    endif
    If Avflags("STATUS_DUE")
       oView:SetOwnerView("VIEW_EKK","BOXEKK")
    EndIf

    oModel:GetModel("EK0MASTER"):SetDescription(STR0001)
    oModel:GetModel("EK1DETAIL"):SetDescription("Capa Embarque")
    oModel:GetModel("EK2DETAIL"):SetDescription("Itens Embarque / Itens NF")
    oModel:GetModel("EK3DETAIL"):SetDescription("NFs de Saída")
    oModel:GetModel("EK4DETAIL"):SetDescription("NFs de Entrada/ Nfs Quebra Lote")
    if avflags("DU-E3.1")
        oModel:GetModel("EK7DETAIL"):SetDescription("Drawback Itens")
        oModel:GetModel("EK8DETAIL"):SetDescription("NFs Drawback Itens")
    endif
    If Avflags("STATUS_DUE")
       oModel:GetModel("EKKDETAIL"):SetDescription("Status em Sequência")
    EndIf

    oView:EnableTitleView('VIEW_EK0', STR0001 )
    oView:EnableTitleView('VIEW_EK1', "Capa Embarque")
    oView:EnableTitleView('VIEW_EK2', "Itens Embarque / Itens NF")
    oView:EnableTitleView('VIEW_EK3', "NFs de Saída")
    oView:EnableTitleView('VIEW_EK4', "NFs de Entrada/ Nfs Quebra Lote")
    if avflags("DU-E3.1")
        oView:EnableTitleView('VIEW_EK7', "Drawback Itens")
        oView:EnableTitleView('VIEW_EK8', "NFs Drawback Itens")
    endif
    If Avflags("STATUS_DUE")
       oView:EnableTitleView('VIEW_EKK', "Status DUE")
    EndIf
    
Return oView
/*---------------------------------------------------------------------*
 | Func:  du100Commit                                                  |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/08/2020                                                   |
 | Desc:  função de commit da tela de due                              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function du100Commit(oModel)
Local nOperation := oModel:GetOperation()

   if nOperation == 5
      FWFormCommit( oModel )
   else
      if lDueAuto
         nPosProces := 0
         if (nPosProces := ascan(aRotAuto, {|x| x[1] == "EK0_PROCES" })) > 0 .and. ! empty(aRotAuto[nPosProces][2]) 
            cProcess := aRotAuto[nPosProces][2]
            xValidEEC( xFilial("EEC") , cProcess )
         endif
      endif
   endif

return .t.
/*---------------------------------------------------------------------*
 | Func:  GeraDecl                                                     |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Tela para selecionar um processo e gerar a declaração        |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function GeraDecl()
   Local aAreaEEC	:= EEC->(GetArea())
   Local oPanel, oGet
   Local nAlt, nLarg
   
   Private oDlg
   Private cProcess := space(TamSX3("EEC_PREEMB")[1])

   //Define a janela do Browse
   nAlt  := 300
   nLarg := 400
   oDlg = TDialog():New(0, 0, nAlt, nLarg ,STR0001,,,,,,,,,.T.)
      nLin  := 5
      nCol  := 5
      nAlt  := 140
      nLarg := 193
      lLowered := .F.
      lRaised	:= .T.
      oPanel:= tPanel():New(nLin,nCol,,oDlg,,,,,/*CLR_GRAY*/,nLarg,nAlt,lLowered,lRaised)

      nAlt  := 040
      nLarg := 180
      oSay:= TSay():New(nLin,nCol,{|| STR0005 },oPanel,,,,,,.T.,,,nLarg,nAlt) // 'Selecione o processo de exportação para o qual deseja gerar a declaração.'
      oSay:enable()

      nLin  := 040
      nCol  := 030
      nAlt  := 010
      nLarg := 100
      oSay:= TSay():New(nLin,nCol,{|| "Processo de embarque:" },oPanel,,,,,,.T.,,,nLarg,nAlt) // Processo de embarque:
      oSay:enable()

      nLin  := 050
      nCol  := 030
      nAlt  := 011
      nLarg := 100
      @ nlin,nCol MSGET oGet VAR cProcess SIZE nLarg,nAlt PIXEL HASBUTTON OF oPanel F3 "EEC" ;
      VALID ( .T. ) ;
      WHEN .T. PICTURE "@!" 

      nLin  := 100
      nCol  := 030
      nAlt  := 020
      nLarg := 060
      oTButton := TButton():New( nLin, nCol, "Gerar Declaração", oPanel,{|| iif(xValidEEC( xFilial("EEC") , cProcess ), oDlg:End() , nil) }, nLarg,nAlt,,,.F.,.T.,.F.,,.F.,,,.F. )
      oTButton1 := TButton():New( nLin, nCol + 070, "Cancela"   , oPanel,{|| oDlg:End() , oBrowse:Refresh(.T.) }, nLarg,nAlt,,,.F.,.T.,.F.,,.F.,,,.F. )

   oPanel:align := CONTROL_ALIGN_ALLCLIENT
   oDlg:Activate(,,,.T.)

   restarea(aAreaEEC)

Return
/*---------------------------------------------------------------------*
 | Func:  xValidEEC                                                    |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Validação do botão gerar para gerar a DUE                    |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function xValidEEC(cFil,cPro)
Local aAreaEEC := EEC->(getarea()) 
Local lRet     := .T.

   if !Empty(cPro)
      DbSelectArea("EEC")
      If EEC->( dbsetorder(1) , dbseek(cFil+cPro) )
         
         EECDU400()
         // PONTO DE ENTRADA PADRÃO ROTINA
         If EasyEntryPoint("EECDU100")
               ExecBlock("EECDU100",.f.,.f.,"OK_DUE")
         EndIf

      Else
         Help( ,, 'HELP',STR0001, "Processo: " + cFil + "-" + alltrim(cPro) + " não existe." , 1, 0)
         lRet := .F.
      Endif
   Else
      Help( ,, 'HELP',STR0001, "Preencha o campo de processo." , 1, 0)
      lRet := .F.
   Endif

   restarea(aAreaEEC)

Return lRet
/*---------------------------------------------------------------------*
 | Func:  DU100VALID                                                   |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Validação para deletar a linha                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function DU100VALID(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()
   /*
   EK0->EK0_STATUS == '1' // "Aguardando transmissão"
   EK0->EK0_STATUS == '2' // "Transmitido com sucesso"
   EK0->EK0_STATUS == '3' // "Falha na transmissão"
   EK0->EK0_STATUS == '4' // "Embarque Cancelado"
   EK0->EK0_STATUS == '5' // "DUE Manual"
   */
   If nOperation == 5 .and. EK0->EK0_STATUS == "2"
      Help( ,, 'HELP',STR0001, STR0006 , 1, 0) // "Não é permitido exclusão de declarações já transmitidas."
      lRet := .F.
   EndIf

return lRet
/*---------------------------------------------------------------------*
 | Func:  EECDU100GRV                                                  |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Função para gravar na tabela EK0 chamada na geração e        |
 | transmissão dos XMLs da DUE                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function EECDU100GRV( nOpt, cFil , cProcesso, cSeq , __cUserID , dDataBase, cBuffer , cMsg ,cNroDUE, cNroRUC)
Default cNroDUE := ""
Default cNroRUC := ""
Private aValItem := {}
Private cMsgCpoDUE := ""
Private nOp := nOpt, cProc := cProcesso, cSeque := cSeq

   begin transaction
      If alltrim(str(nOpt)) $ "1|5" // geração do xml

         // busca próxima sequencia do histórico
         cSeq    := xSeqEK0()
         cSeque  := cSeq
         // Grava a capa do histórico
         EK0->(Reclock("EK0",.T.))
         EK0->EK0_STATUS   := alltrim(str(nOpt))
         EK0->EK0_FILIAL   := cFil
         EK0->EK0_PROCES   := cProcesso
         EK0->EK0_USER     := __cUserID
         EK0->EK0_DATA     := dDataBase
         EK0->EK0_TRANSM   := cBuffer
         EK0->EK0_NUMSEQ   := cSeq
         EK0->EK0_RETIFI   := "1"
         EK0->( msunlock() )
         
         // função para ratear os itens em caso de notas e seq lotes
         if DU400SetVal(cProcesso,aValItem)
            // FUNÇÃO PARA GRAVAR AS EK'S FILHAS
            GerEKs()
         else
            DisarmTransaction()
            Break
         endif

         // gera o xml de espelho // GERA XML DUE VERSÃO 3
         cBuffer := EasyExecAHU("DUE3")

         if !empty(cBuffer)
            EK0->(Reclock("EK0",.F.))
            EK0->EK0_TRANSM   := cBuffer
            EK0->( msunlock() )
         endif

      elseif nOpt == 2 // pega o retorno do envio
         cSeq:= DUESeqHist(cProcesso)
         cSeque := cSeq
         EK0->(Reclock("EK0",.F.))
         EK0->EK0_STATUS   := "2"
         EK0->EK0_RECEBI   := cBuffer
         EK0->EK0_MESAGE   := cMsg
         EK0->EK0_RETIFI   := "1" //DUE nao necessita retificacao
         EK0->( msunlock() )
         //Grava o numero DUE e RUC na tabela de historico
         EK1->(dbSetOrder(1))
         If EK1->(dbSeek(xFilial("EK1") + cProcesso + cSeq))
            EK1->(Reclock("EK1",.F.))
            EK1->EK1_NRODUE := cNroDUE
            EK1->EK1_NRORUC := cNroRUC
            EK1->(MsUnlock())
         EndIf

      elseif nOpt == 3 // grava a msg de falha
         EK0->(Reclock("EK0",.F.))
         EK0->EK0_STATUS   := "3"
         EK0->EK0_MESAGE   := cMsg
         EK0->( msunlock() )
      endif
      
      If EasyEntryPoint("EECDU100")
         ExecBlock("EECDU100",.F.,.F.,"ALTERA_ITEM")
      Endif

   end transaction

Return 
/*---------------------------------------------------------------------*
 | Func:  xSeqEK0                                                      |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  retorna o próximo sequencial do histórico due                |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function xSeqEK0()
Local aAreaEK0 := EK0->(GetArea())
Local cSeq     := "001"
Local cQry     := ""

   If TcSrvType()<>"AS/400"

      cQry += "SELECT MAX(EK0_NUMSEQ) EK0_NUMSEQ " + CRLF
      cQry += "FROM "+RetSQLName("EK0")+" " + CRLF
      cQry += "WHERE EK0_FILIAL   = '"+EEC->EEC_FILIAL +"' " + CRLF
      cQry += "AND EK0_PROCES     = '"+EEC->EEC_PREEMB+"' " + CRLF
      cQry += "AND D_E_L_E_T_ <> '*'"

      if Select( "TMPEK0" ) > 0
         TMPEK0->( dbclosearea() )
      endif

      DBUseArea(.T., "TOPCONN" , TCGenQry(,, cQry), "TMPEK0", .T., .T.) 
      iif( TMPEK0->(!EOF()) .AND. !Empty(TMPEK0->EK0_NUMSEQ) , cSeq := Soma1(TMPEK0->EK0_NUMSEQ) , cSeq )

   else

      EK0->( dbsetorder(1) , MsSeek( EEC->EEC_FILIAL + EEC->EEC_PREEMB) )
      cXPreemb := EEC->EEC_FILIAL + EEC->EEC_PREEMB
      While EK0->(!EOF()) .and. EK0->EK0_FILIAL + EK0->EK0_PROCES == cXPreemb
         cSeq := Soma1(EK0->EK0_NUMSEQ)
         EK0->(dbskip())
      EndDo

   endif

   restarea(aAreaEK0)

Return cSeq
/*---------------------------------------------------------------------*
 | Func:  DUETransmit                                                  |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Função para geração do arquivo e transmissão dos XMLs da DUE |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function DUETransmit()
Local aAreaEEC := EEC->(GetArea())
Local aBuffer   := {}

   If VldDUETrmt(EK0->EK0_FILIAL , EK0->EK0_PROCES, EK0->EK0_NUMSEQ) .And. msgyesno( STR0007 ,STR0001) // "Deseja transmitir esta Declaração Única de Exportação?"
      If EEC->( dbsetorder(1), msseek( EK0->EK0_FILIAL + EK0->EK0_PROCES ) )
         cBuffer := EK0->EK0_TRANSM
         cBuffer := EncodeUTF8(cBuffer)
         cBuffer := StrTran(cBuffer,"&","e")
         aadd( aBuffer , { cBuffer , EK0->EK0_FILIAL + EK0->EK0_PROCES , EEC->( recno() ) , EK0->( recno() ) } )
         GerXMLDue(aBuffer)
         DU400GrvStatus() //Atualzia o status da DUE na tabela EEC
      else
         Help( ,, 'HELP',STR0001, STR0008 + Alltrim(EK0->EK0_PROCES) , 1, 0) // "Não foi encontrado o processo: "
      endif
   endif

   RestArea(aAreaEEC)

Return
/*---------------------------------------------------------------------*
 | Func:  DU100DUE()                                                   |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Função para verificar se o processo teve uma DUE registrada  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function DU100DUE()
Local lRet := .F.

   cAliasQry:=GetNextAlias()
   BeginSql Alias cAliasQry
      SELECT EK0_PROCES 
      FROM %table:EK0% 
      WHERE %notDel%
      AND EK0_FILIAL   = %EXP:EEC->EEC_FILIAL%
      AND EK0_PROCES   = %EXP:EEC->EEC_PREEMB%
      AND EK0_STATUS   = '2'
   EndSql
   (cAliasQry)->(DbGoTop())
   If (cAliasQry)->(!Eof())
      lRet := .T.
   EndIf
   (cAliasQry)->(DbCloseArea())

return lRet
/*---------------------------------------------------------------------*
 | Func:  VldDUETrmt                                                  |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Função para verificar se o processo tem transmissão finalziada DUE |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function VldDUETrmt(cFil,cPreemb,cNumSeq)
Local lRet          := .T.
Local cUltimaSeq    := DUESeqHist(cPreemb)

   Begin Sequence

      If cNumSeq < cUltimaSeq
         Help( ,, 'HELP',STR0001, "Não é possível realizar a transmissão."+ENTER+"Existe um arquivo com uma sequência acima para o processo " + Alltrim(cPreemb) , 1, 0)
         lRet := .F.
         Break
      EndIf

      If EK0->EK0_STATUS == "2" //Transmitido
         Help( ,, 'HELP',STR0001, "Não é possível realizar a transmissão."+ENTER+"O arquivo selecionado já está transmitido." , 1, 0)
         lRet := .F.
         Break
      EndIf

      If EK0->EK0_STATUS == "3" //Falha
         Help( ,, 'HELP',STR0001, "Não é possível realizar a transmissão."+ENTER+"O arquivo selecionado já foi transmitido e registrou falha na transmissão." , 1, 0)
         lRet := .F.
         Break
      EndIf

      If EK0->EK0_STATUS == "4" //Cancelado
         Help( ,, 'HELP',STR0001, "Não é possível realizar a transmissão."+ENTER+"O arquivo selecionado foi cancelado." , 1, 0)
         lRet := .F.
         Break
      EndIf

      If EK0->EK0_STATUS == "5" //DUE Manual
         Help( ,, 'HELP',STR0001, "Não é possível realizar a transmissão."+ENTER+"O arquivo selecionado é uma DUE Manual." , 1, 0)
         lRet := .F.
         Break
      EndIf

   End Sequence

Return lRet
/*---------------------------------------------------------------------*
 | Func:  VldSttDUE                                                    |
 | Autor: Miguel Gontijo                                               |
 | Data:  28/03/2018                                                   |
 | Desc:  Função para verificar se existe DUE transmitida              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Function VldSttDUE(cFil,cPreemb)
Local aAreaEK0  := {}
Local cQry := ""
Local lRet := .F.

   If TcSrvType()<>"AS/400"
      cQry += "SELECT EK0_FILIAL,EK0_PROCES,EK0_NUMSEQ,EK0_STATUS " + CRLF
      cQry += "FROM "+RetSQLName("EK0")+" " + CRLF
      cQry += "WHERE EK0_FILIAL = '"+cFil+"' " + CRLF
      cQry += "AND EK0_PROCES = '"+cPreemb+"' " + CRLF
      cQry += "AND D_E_L_E_T_<>'*'" + CRLF
      cQry += "AND EK0_STATUS = '2'" + CRLF
      cQry += "ORDER BY EK0_PROCES, EK0_NUMSEQ DESC"

      if Select( "TMPEK0" ) > 0
         TMPEK0->( dbclosearea() )
      endif
      DBUseArea(.T., "TOPCONN" , TCGenQry(,, cQry), "TMPEK0", .T., .T.) 
      iif( TMPEK0->(!EOF()) , lRet:= .T. , lRet )
   else
      aAreaEK0 := EK0->(getarea())
      EK0->( dbsetorder(1) , MsSeek( EEC->EEC_FILIAL + EEC->EEC_PREEMB) )
      While EK0->(!EOF()) .and. EK0->(EK0_FILIAL+EK0_PROCES) == cFilL+cPreemb
         if EK0->EK0_STATUS == "2"
            lRet:= .T.
            Exit
         endif
         EK0->(dbskip())
      EndDo
      restarea(aAreaEK0)
   endif

Return lRet
/*-------------------------------------------------------------------------*
 | Func:  DU100CancelDues                                                  |
 | Autor: Miguel Gontijo                                                   |
 | Data:  30/06/2020                                                       |
 | Desc:  Cancela todas as Dues referentes ao processo                     |
 | Obs.:  /                                                                |
 *------------------------------------------------------------------------*/
Function DU100CancelDue( cChaveEK0 )

   if EK0->(dbsetorder(1),msseek( cChaveEK0 ))
      while EK0->(!eof()) .and. EK0->EK0_FILIAL+EK0->EK0_PROCES == cChaveEK0 
         reclock("EK0",.F.)
         EK0->EK0_STATUS := "4"
         EK0->(msunlock())
         EK0->(dbskip())
      enddo
   endif

Return
/*-------------------------------------------------------------------------*
 | Func:  eecdu100del                                                      |
 | Autor: Miguel Gontijo                                                   |
 | Data:  28/03/2018                                                       |
 | Desc:  Deletas os registros das eks referentes ao processo              |
 | Obs.:  /                                                                |
 *------------------------------------------------------------------------*/
Function eecdu100del( cChvEK0 )
Local aAreaEK0 := EK0->(getarea())
Local lRet := .T.

   if EK0->( dbsetorder(1) , dbseek( cChvEK0 ) )
      while EK0->( !eof() ) .AND. cChvEK0 == EK0->EK0_FILIAL+EK0->EK0_PROCES
         oModel := FwLoadModel("EECDU100")
         oModel:SetOperation(MODEL_OPERATION_DELETE)
         oModel:Activate()

         If oModel:VldData()
            oModel:CommitData()
         Else
            // VarInfo("",oModel:GetErrorMessage())
            EasyHelp(alltrim(oModel:GetErrorMessage()[6]) ,STR0001) //"Esse processo de embarque possui DUE transmitida e não pode ser excluída."
            lRet := .F.
            Exit
         EndIf
         oModel:DeActivate()
         EK0->(dbskip())
      enddo
   EndIf

   restarea(aAreaEK0)

Return lRet
/*-------------------------------------------------------------------------*
 | Func:  GerEKs                                                           |
 | Autor: Miguel Gontijo                                                   |
 | Data:  28/03/2018                                                       |
 | Desc:  Grava as ek's com os dados a serem enviados no xml para histórico|
 | Obs.:  /                                                                |
 *------------------------------------------------------------------------*/
Function GerEKs()
Local aAreaEE9 := EE9->(GetArea())
Local aAreaEEM := EEM->(GetArea())
Local aAreaEES := EES->(GetArea())
Local aAreaEYY := EYY->(GetArea())
Local aAreaEYU := EYU->(GetArea())
Local aAreaEWI := EWI->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local acodMoeda := {}
Local aNfsRem   := {}
Local cPaisOriPrc := ""
Local cPaisDstPrc := ""
Local lSemNota := .T. 
Local lEE9NFPOS:= .F. //Utilizada para veroficara se posicionou o item da EE9 referente ao item da NF (EES)
Local lSF1NFPOS:= .T.
Local lEk4Lote  := .F.
Local cChaveEEM := xFilial("EEM")+EEC->EEC_PREEMB+AvKey('N',"EEM_TIPOCA")
Local nX := 0
Local cSeqEK7 := ""
Local cSeqEK8 := ""

     If AvFlags("DU-E3.1")
        cSeqEK7 := padR( '', tamsx3("EK7_SEQEK7")[1] , '0' )
        cSeqEK8 := padR( '', tamsx3("EK8_SEQEK8")[1] , '0' )
     EndIf

     SA2->( dbsetorder(1) , msseek( xFilial("SA2")+EEC->EEC_FORN+EEC->EEC_FOLOJA ) )
          cPaisOriPrc := GetAdvFVal("SYA","YA_PAISDUE",xFilial("SYA")+SA2->A2_PAIS ,1,"",.T.)
     SA1->( dbsetorder(1) , msseek( xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA ) )
          cPaisDstPrc := GetAdvFVal("SYA","YA_PAISDUE",xFilial("SYA")+SA1->A1_PAIS ,1,"",.T.)

     If EEM->( DbSetOrder(1) , msseek( cChaveEEM ))
          lSemNota := .F. 
     EndIf 

     EK1->(Reclock("EK1",.T.))
     EK1->EK1_FILIAL := EK0->EK0_FILIAL
     EK1->EK1_PROCES := EK0->EK0_PROCES
     EK1->EK1_NUMSEQ := EK0->EK0_NUMSEQ

     EK1->EK1_TIPDUE := iif( lSemNota , "2" , "1" ) //Tem NF? 1=Sim; 2=Não
     EK1->EK1_NRODUE := EEC->EEC_NRODUE
     EK1->EK1_URFDSP := EEC->EEC_URFDSP
     EK1->EK1_RECALF := EEC->EEC_RECALF

     If AvFlags("DU-E3.1")
        EK1->EK1_URFENT := EEC->EEC_URFENT
        EK1->EK1_RECEMB := EEC->EEC_RECEMB
     Else
        If EEC->(FieldPos("EEC_RECEMB")) > 0 .and. EK1->(FieldPos("EK1_RECEMB")) > 0
            EK1->EK1_RECEMB := EEC->EEC_RECEMB
        EndIf
        If EEC->(FieldPos("EEC_URFENT")) > 0 .and. EK1->(FieldPos("EK1_URFENT")) > 0
            EK1->EK1_URFENT := EEC->EEC_URFENT
        endif
     EndIf

     EK1->EK1_EMFRRC := EEC->EEC_EMFRRC

     EK1->EK1_FOREXP := EEC->EEC_FOREXP
     EK1->EK1_DESFOR := GetAdvFVal( "EVN", "EVN_DESCRI" , xFilial("EVN")+EEC->EEC_FOREXP+"CUS" , 1, "" , .T. )
     EK1->EK1_OBSFOR := EEC->EEC_OBSFOR

     EK1->EK1_SITESP := EEC->EEC_SITESP
     EK1->EK1_DESSIT := GetAdvFVal( "EVN", "EVN_DESCRI" , xFilial("EVN")+EEC->EEC_SITESP+"AHZ" , 1, "" , .T. )
     EK1->EK1_OBSSIT := EEC->EEC_OBSSIT

     EK1->EK1_ESPTRA := EEC->EEC_ESPTRA
     EK1->EK1_DESTRA := GetAdvFVal( "EVN", "EVN_DESCRI" , xFilial("EVN")+EEC->EEC_ESPTRA+"TRA" , 1, "" , .T. )
     EK1->EK1_OBSTRA := EEC->EEC_OBSTRA

     EK1->EK1_MOTDIS := EEC->EEC_MOTDIS
     EK1->EK1_DESDIS := GetAdvFVal( "EVN", "EVN_DESCRI" , xFilial("EVN")+EEC->EEC_MOTDIS+"ACG" , 1, "" , .T. )

     aCodMoeda := DU400ChgMd(Alltrim(EEC->EEC_MOEDA)) 
     EK1->EK1_MOEDA := acodMoeda[2]

     EK1->EK1_FORN   := SA2->A2_COD
     EK1->EK1_FOLOJA := SA2->A2_LOJA
     EK1->EK1_FORNDE := SA2->A2_NOME
     EK1->EK1_CGC    := SA2->A2_CGC
     EK1->EK1_PAISDU := cPaisOriPrc
     EK1->EK1_FOREST := SA2->A2_EST
     EK1->EK1_FOREND := SA2->A2_END

     EK1->EK1_NRORUC := EEC->EEC_NRORUC
     EK1->EK1_INCOTE := EEC->EEC_INCOTE

     EK1->EK1_IMPORT := SA1->A1_COD
     EK1->EK1_IMLOJA := SA1->A1_LOJA
     EK1->EK1_IMPODE := SA1->A1_NOME
     EK1->EK1_PAISIM := cPaisDstPrc
     EK1->EK1_ENDIMP := SA1->A1_END

    If EK1->(FieldPos("EK1_PAISET")) > 0
        EK1->EK1_PAISET :=  GetAdvFVal("SYA","YA_PAISDUE",xFilial("SYA")+EEC->EEC_PAISET ,1,"",.T.)
    EndIf

     EK1->EK1_ENQCOD := EEC->EEC_ENQCOD
     EK1->EK1_ENQCO1 := EEC->EEC_ENQCO1
     EK1->EK1_ENQCO2 := EEC->EEC_ENQCO2
     EK1->EK1_ENQCO3 := EEC->EEC_ENQCO3
     
     EK1->EK1_VALCOM := EEC->EEC_VALCOM
     EK1->EK1_TOTFOB := EEC->EEC_TOTFOB
     EK1->EK1_OBSPED := DU400ObsEmb()
     
    if avflags("DU-E3.1")
        EK1->EK1_RESPDE := EEC->EEC_RESPDE
        EK1->EK1_LATDES := EEC->EEC_LATDES
        EK1->EK1_LONDES := EEC->EEC_LONDES
        EK1->EK1_ENDDES := EEC->EEC_ENDDES
        EK1->EK1_RESPON := EEC->EEC_RESPON
        If EE3->( dbsetorder(2),dbseek(xFilial("EE3")+EEC->EEC_RESPON) ) //EE3_FILIAL + EE3_NOME
            EK1->EK1_EMAIL  := EE3->EE3_EMAIL
            EK1->EK1_FONE   := EE3->EE3_FONE
        EndIf
        EK1->EK1_JUSRET := EEC->EEC_JUSRET
    endif
    
    if EK1->(fieldpos("EK1_ENQCOX")) > 0
        EK1->EK1_ENQCOX := EEC->EEC_ENQCOX
    endif

    EK1->(msunlock())
    If lSemNota
        EE9->( DbSetOrder(3) , msseek( xFilial("EE9")+EEC->EEC_PREEMB))
        While EE9->(!Eof()) .And. EE9->(EE9_FILIAL+EE9_PREEMB) == EEC->(EEC_FILIAL+EEC_PREEMB)
                EK2->(Reclock("EK2",.T.))
                EK2->EK2_FILIAL := EK0->EK0_FILIAL
                EK2->EK2_PROCES := EK0->EK0_PROCES
                EK2->EK2_NUMSEQ := EK0->EK0_NUMSEQ
                EK2->EK2_SEQUEN := EE9->EE9_SEQUEN
                EK2->EK2_SEQEMB := EE9->EE9_SEQEMB
                EK2->EK2_COD_I  := EE9->EE9_COD_I
                EK2->EK2_SLDINI := Du400GetVal(EE9->EE9_SEQEMB, "QUANTIDADE")
                EK2->EK2_PRCTOT := Du400GetVal(EE9->EE9_SEQEMB, "TOTAL")
                EK2->EK2_PRCINC := Du400GetVal(EE9->EE9_SEQEMB, "INCOTERM")
                EK2->EK2_ATOCON := EE9->EE9_ATOCON
                EK2->EK2_PCARGA := EE9->EE9_PCARGA
                EK2->EK2_OBSPCA := EE9->EE9_OBSPCA
                EK2->EK2_PERCOM := EE9->EE9_PERCOM
                If EE9->(FieldPos("EE9_LPCO")) > 0
                    EK2->EK2_LPCO   := EE9->EE9_LPCO
                EndIf
                If EK2->(FieldPos("EK2_DESTAQ")) > 0
                    EK2->EK2_DESTAQ := GetAdvFVal( "EYJ", "EYJ_DESEXP" , xFilial("EYJ")+EE9->EE9_COD_I , 1, "" , .T. )
                EndIf
                EK2->EK2_PEDIDO := EE9->EE9_PEDIDO
                EK2->EK2_VM_DES := DU400DscItem()
                EK2->EK2_POSIPI := EE9->EE9_POSIPI
                EK2->EK2_UNIDAD := EE9->EE9_UNIDAD
                EK2->EK2_UNPES  := EE9->EE9_UNPES
                EK2->EK2_PSLQUN := EE9->EE9_PSLQUN

                if avflags("DU-E3.1")
                    EK2->EK2_SEQED3 := EE9->EE9_SEQED3
                    EK2->EK2_JUSDUE := EE9->EE9_JUSDUE
                    EK2->EK2_VLSCOB := EE9->EE9_VLSCOB
                    //Quantidade NCM
                    EK2->EK2_QTDNCM := Du400GetVal(EE9->EE9_SEQEMB, "QUANTIDADE_NCM")
                    //Peso
                    EK2->EK2_PESNCM := Du400GetVal(EE9->EE9_SEQEMB, "PESO")
                    EK2->EK2_DESC   := DU400DscPrd(EE9->EE9_COD_I)

                    If Empty(EE9->EE9_ATOCON)
                        If EYU->(FieldPos("EYU_TPAC") > 0 .And. DbSeek(xFilial()+EEC->EEC_PREEMB+EE9->EE9_SEQEMB ))
                            //Criar registro na tabela nova
                            While EYU->(!Eof() .And. EYU_FILIAL+EYU_PREEMB+EYU_SEQEMB == xFilial()+EEC->EEC_PREEMB+EE9->EE9_SEQEMB )
                                cSeqEK7 := soma1(cSeqEK7)
                                    EK7->(Reclock("EK7",.T.))
                                    EK7->EK7_FILIAL := EK0->EK0_FILIAL
                                    EK7->EK7_PREEMB := EYU->EYU_PREEMB
                                    EK7->EK7_SEQEMB := EYU->EYU_SEQEMB
                                    EK7->EK7_NUMSEQ := EK0->EK0_NUMSEQ
                                    EK7->EK7_SEQEK7 := cSeqEK7
                                    EK7->EK7_POSIPI := EYU->EYU_POSIPI
                                    EK7->EK7_CNPJ   := EYU->EYU_CNPJ
                                    EK7->EK7_VLSCOB := EYU->EYU_VLSCOB
                                    EK7->EK7_VALOR  := EYU->EYU_VALOR
                                    EK7->EK7_QTD    := EYU->EYU_QTD
                                    EK7->EK7_ATOCON := EYU->EYU_ATOCON
                                    EK7->EK7_TPAC   := DU400TpAC(EYU->EYU_TPAC)
                                    EK7->EK7_SEQED3 := EYU->EYU_SEQED3
                                    EK7->EK7_TIPO   := EYU->EYU_TIPO
                                EK7->(msunlock())
                                If EWI->( dbsetorder(1) , MsSeek(xFilial("EWI")+EYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3))) //FieldPos("EWI_CHVNFE") > 0 .And.
                                    Do While EWI->(!EoF() .AND. xFilial("EWI")+EWI_PREEMB+EWI_SEQEMB+EWI_TIPO+EWI_CNPJ+EWI_POSIPI+EWI_ATOCON+EWI_SEQED3 == xFilial("EYU")+EYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3))
                                        cSeqEK8 := soma1(cSeqEK8)
                                            EK8->(Reclock("EK8",.T.))
                                            EK8->EK8_FILIAL := EK0->EK0_FILIAL
                                            EK8->EK8_PREEMB := EWI->EWI_PREEMB
                                            EK8->EK8_SEQEMB := EWI->EWI_SEQEMB
                                            EK8->EK8_NUMSEQ := EK0->EK0_NUMSEQ
                                            EK8->EK8_SEQEK8 := cSeqEK8
                                            EK8->EK8_NF     := EWI->EWI_NF
                                            EK8->EK8_SERIE  := EWI->EWI_SERIE
                                            EK8->EK8_DTNF   := EWI->EWI_DTNF
                                            if EWI->( fieldpos("EWI_CHVNFE") ) > 0
                                                EK8->EK8_CHVNFE := EWI->EWI_CHVNFE
                                            endif
                                            EK8->EK8_CNPJ   := EK7->EK7_CNPJ
                                            EK8->EK8_VLNF   := EWI->EWI_VLNF
                                            EK8->EK8_QTD    := EWI->EWI_QTD
                                            EK8->EK8_ATOCON := EWI->EWI_ATOCON
                                            EK8->EK8_SEQED3 := EWI->EWI_SEQED3
                                            EK8->EK8_POSIPI := EWI->EWI_POSIPI
                                            EK8->EK8_TIPO   := EWI->EWI_TIPO
                                        EK8->(msunlock())
                                    EWI->(DbSkip())
                                    EndDo
                                endif
                            EYU->(DbSkip())
                            EndDo
                        Endif
                    Else
                        cSeqEK7 := soma1(cSeqEK7)
                            EK7->(Reclock("EK7",.T.))
                            EK7->EK7_FILIAL := EK0->EK0_FILIAL
                            EK7->EK7_PREEMB := EE9->EE9_PREEMB
                            EK7->EK7_SEQEMB := EE9->EE9_SEQEMB
                            EK7->EK7_NUMSEQ := EK0->EK0_NUMSEQ
                            EK7->EK7_SEQEK7 := cSeqEK7
                            EK7->EK7_ATOCON := EE9->EE9_ATOCON
                            EK7->EK7_VLSCOB := EE9->EE9_VLSCOB
                            EK7->EK7_SEQED3 := EE9->EE9_SEQED3
                            EK7->EK7_TIPO   := EE9->EE9_TPAC                            
                            EK7->EK7_POSIPI := EE9->EE9_POSIPI
                            If GetMv("MV_EEC_EDC",,.F.)
                                EK7->EK7_TPAC   := DU400TpAC(Posicione("ED0", 2, xFilial("ED0")+EE9->EE9_ATOCON, "ED0_TIPOAC"))
                                EK7->EK7_CNPJ   := Posicione('SYT', 1, xFilial('SYT')+Posicione("ED0", 2, xFilial("ED0")+EE9->EE9_ATOCON, "ED0_IMPORT"), 'YT_CGC')
                                EK7->EK7_VALOR  := EE9->EE9_VL_AC - EE9->EE9_VLSCOB
                                EK7->EK7_QTD    := Posicione("ED3", 2, xFilial("ED3")+EE9->EE9_ATOCON+EE9->EE9_SEQED3, "AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,EE9->EE9_QT_AC)")
                            Else
                                EK7->EK7_TPAC   := DU400TpAC(EE9->(If(FieldPos("EE9_TPAC") > 0 .And. !Empty(EE9_TPAC), EE9_TPAC, "")))
                                EK7->EK7_CNPJ   := If(!Empty(EEC->EEC_EXPORT+EEC->EEC_EXLOJA), SI100CNPJ(EEC->EEC_EXPORT+EEC->EEC_EXLOJA), SI100CNPJ(EEC->EEC_FORN+EEC->EEC_FOLOJA))
                                EK7->EK7_VALOR  := EE9->EE9_PRCINC - If( EasyGParam("MV_AVG0119",,.F.) , EE9->EE9_DESCON , EE9->EE9_VLDESC ) - EE9->EE9_VLSCOB
                                EK7->EK7_QTD    := EK2->EK2_QTDNCM
                            EndIf
                        EK7->(msunlock())
                    EndIf
                endif
            EK2->(msunlock())
            EE9->(dbSkip())
        End
    Else // quando o processo tem notas fiscais integradas com o protheus 
        if EEM->( DbSetOrder(1) , msseek( cChaveEEM ))
            While EEM->(!EOF()) .AND. cChaveEEM == EEM->(EEM_FILIAL + EEM_PREEMB + EEM_TIPOCA)
                //Grava capa da Nota Fiscal - EEM na tabela EK3
                EK3->(Reclock("EK3",.T.))
                EK3->EK3_FILIAL := EK0->EK0_FILIAL
                EK3->EK3_PROCES := EK0->EK0_PROCES
                EK3->EK3_NUMSEQ := EK0->EK0_NUMSEQ
                EK3->EK3_TIPOCA := EEM->EEM_TIPOCA
                EK3->EK3_NRNF   := EEM->EEM_NRNF
                EK3->EK3_SERIE  := EEM->EEM_SERIE
                EK3->EK3_DTNF   := EEM->EEM_DTNF
                EK3->EK3_CODEMI := SA1->A1_COD
                EK3->EK3_LOJEMI := SA1->A1_LOJA
                EK3->EK3_CGC    := SA1->A1_CGC
                EK3->EK3_CHVNFE := EEM->EEM_CHVNFE
                EK3->(msunlock())

                //Grava itens da Nota Fiscal - EES na tabela EK2
                cChaveEES := xFilial("EES")+AvKey(EEC->EEC_PREEMB,"EES_PREEMB") +AvKey(EEM->EEM_NRNF,"EES_NRNF")+AvKey(EEM->EEM_SERIE,"EES_SERIE")
                if EES->( dbsetorder(1) , msseek( cChaveEES ))
                    While EES->(!EOF()) .AND. cChaveEES == EES->(EES_FILIAL + EES_PREEMB + EES_NRNF + EES_SERIE)
                        //Posiciona o item da EE9 referente ao item da EES
                        lEE9NFPOS := PosEE9ItNF(xFilial("EE9")+EES->EES_PREEMB+EES->EES_PEDIDO+EES->EES_SEQUEN, EES->EES_NRNF, EES->EES_SERIE)
                        lEk4Lote    := EK4Lote(EES->EES_PREEMB, EES->EES_COD_I, EES->EES_SEQUEN, EES->EES_NRNF, EES->EES_SERIE)
                            EK2->(Reclock("EK2",.T.))
                            EK2->EK2_FILIAL := EES->EES_FILIAL
                            EK2->EK2_PROCES := EES->EES_PREEMB
                            EK2->EK2_NUMSEQ := EK0->EK0_NUMSEQ
                            EK2->EK2_SEQUEN := EES->EES_SEQUEN
                            EK2->EK2_COD_I  := EES->EES_COD_I
                            EK2->EK2_SLDINI := Du400GetVal(EE9->EE9_SEQEMB, "QUANTIDADE", EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ)
                            EK2->EK2_PRCTOT := Du400GetVal(EE9->EE9_SEQEMB, "TOTAL"     , EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ)
                            EK2->EK2_PRCINC := Du400GetVal(EE9->EE9_SEQEMB, "INCOTERM"  , EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ)
                            EK2->EK2_FATSEQ := DU400CnvSeq(EES->EES_FATSEQ)
                            EK2->EK2_PEDIDO := EES->EES_PEDIDO
                            EK2->EK2_NRNF   := EES->EES_NRNF
                            EK2->EK2_SERIE  := EES->EES_SERIE
                            If EK2->(FieldPos("EK2_DESTAQ")) > 0
                                EK2->EK2_DESTAQ := GetAdvFVal( "EYJ", "EYJ_DESEXP" , xFilial("EYJ")+EES->EES_COD_I , 1, "" , .T. )
                            EndIf
                            if avflags("DU-E3.1")
                                EK2->EK2_JUSDUE := EE9->EE9_JUSDUE
                                EK2->EK2_QTDNCM := Du400GetVal(EE9->EE9_SEQEMB, "QUANTIDADE_NCM", EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ)
                                EK2->EK2_PESNCM := Du400GetVal(EE9->EE9_SEQEMB, "PESO"          , EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ)
                                EK2->EK2_DESC   := DU400DscPrd(EES->EES_COD_I)
                                EK2->EK2_SEQED3 := EE9->EE9_SEQED3
                                EK2->EK2_JUSDUE := EE9->EE9_JUSDUE
                                EK2->EK2_VLSCOB := Du400GetVal(EE9->EE9_SEQEMB, "COBERTURA" , EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ)
                            endif
                            If lEE9NFPOS // confirma a existência de uma linha da EE9 para evitar error log
                                EK2->EK2_SEQEMB := EE9->EE9_SEQEMB
                                if avflags("DU-E3.1")
                                    If Empty(EE9->EE9_ATOCON)
                                        If EYU->(FieldPos("EYU_TPAC") > 0 .And. DbSeek(xFilial()+EEC->EEC_PREEMB+EE9->EE9_SEQEMB ))
                                            //Criar registro na tabela nova
                                            While EYU->(!Eof() .And. EYU_FILIAL+EYU_PREEMB+EYU_SEQEMB == xFilial()+EEC->EEC_PREEMB+EE9->EE9_SEQEMB )
                                                    EK7->(Reclock("EK7",.T.))
                                                    EK7->EK7_FILIAL := EK0->EK0_FILIAL
                                                    EK7->EK7_PREEMB := EYU->EYU_PREEMB
                                                    EK7->EK7_SEQEMB := EYU->EYU_SEQEMB
                                                    EK7->EK7_NUMSEQ := EK0->EK0_NUMSEQ
                                                    EK7->EK7_SEQEK7 := EK2->EK2_FATSEQ
                                                    EK7->EK7_POSIPI := EYU->EYU_POSIPI
                                                    EK7->EK7_CNPJ   := EYU->EYU_CNPJ
                                                    EK7->EK7_VLSCOB := EYU->EYU_VLSCOB
                                                    EK7->EK7_VALOR  := Du400GetVal(EE9->EE9_SEQEMB, "TOTAL", EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ , , EYU->(EYU_ATOCON+EYU_SEQED3+EYU_SEQEMB)) // EYU->EYU_VALOR
                                                    EK7->EK7_QTD    := Du400GetVal(EE9->EE9_SEQEMB, "QUANTIDADE", EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ , , EYU->(EYU_ATOCON+EYU_SEQED3+EYU_SEQEMB)) //EYU->EYU_QTD
                                                    EK7->EK7_ATOCON := EYU->EYU_ATOCON
                                                    EK7->EK7_TPAC   := DU400TpAC(EYU->EYU_TPAC)
                                                    EK7->EK7_SEQED3 := EYU->EYU_SEQED3
                                                    EK7->EK7_TIPO   := EYU->EYU_TIPO
                                                EK7->(msunlock())
                                                If EWI->( dbsetorder(1) , MsSeek(xFilial("EWI")+EYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3))) //FieldPos("EWI_CHVNFE") > 0 .And.
                                                    Do While EWI->(!EoF() .AND. xFilial("EWI")+EWI_PREEMB+EWI_SEQEMB+EWI_TIPO+EWI_CNPJ+EWI_POSIPI+EWI_ATOCON+EWI_SEQED3 == xFilial("EYU")+EYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3))
                                                            EK8->(Reclock("EK8",.T.))
                                                            EK8->EK8_FILIAL := EK0->EK0_FILIAL
                                                            EK8->EK8_PREEMB := EWI->EWI_PREEMB
                                                            EK8->EK8_SEQEMB := EWI->EWI_SEQEMB
                                                            EK8->EK8_NUMSEQ := EK0->EK0_NUMSEQ
                                                            EK8->EK8_SEQEK8 := EK2->EK2_FATSEQ
                                                            EK8->EK8_NF     := EWI->EWI_NF
                                                            EK8->EK8_SERIE  := EWI->EWI_SERIE
                                                            EK8->EK8_DTNF   := EWI->EWI_DTNF
                                                            if EWI->( fieldpos("EWI_CHVNFE") ) > 0
                                                                EK8->EK8_CHVNFE := EWI->EWI_CHVNFE
                                                            endif
                                                            EK8->EK8_CNPJ   := EK7->EK7_CNPJ
                                                            EK8->EK8_VLNF   := Du400GetVal(EE9->EE9_SEQEMB, "TOTAL", EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ , , EYU->(EYU_ATOCON+EYU_SEQED3+EYU_SEQEMB) , EWI->(EWI_NF+EWI_SERIE)) //EWI->EWI_VLNF
                                                            EK8->EK8_QTD    := Du400GetVal(EE9->EE9_SEQEMB, "QUANTIDADE", EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ , , EYU->(EYU_ATOCON+EYU_SEQED3+EYU_SEQEMB), EWI->(EWI_NF+EWI_SERIE)) //EWI->EWI_QTD
                                                            EK8->EK8_ATOCON := EWI->EWI_ATOCON
                                                            EK8->EK8_SEQED3 := EWI->EWI_SEQED3
                                                            EK8->EK8_POSIPI := EWI->EWI_POSIPI
                                                            EK8->EK8_TIPO   := EWI->EWI_TIPO
                                                        EK8->(msunlock())
                                                        EWI->(DbSkip())
                                                    EndDo
                                                endif
                                                EYU->(DbSkip())
                                            EndDo
                                        Endif
                                    Else
                                        EK7->(Reclock("EK7",.T.))
                                        EK7->EK7_FILIAL := EK0->EK0_FILIAL
                                        EK7->EK7_PREEMB := EE9->EE9_PREEMB
                                        EK7->EK7_SEQEMB := EE9->EE9_SEQEMB
                                        EK7->EK7_NUMSEQ := EK0->EK0_NUMSEQ
                                        EK7->EK7_SEQEK7 := EK2->EK2_FATSEQ
                                        EK7->EK7_ATOCON := EE9->EE9_ATOCON
                                        EK7->EK7_VLSCOB := EE9->EE9_VLSCOB
                                        EK7->EK7_SEQED3 := EE9->EE9_SEQED3
                                        EK7->EK7_TIPO   := EE9->EE9_TPAC
                                        EK7->EK7_POSIPI := EE9->EE9_POSIPI
                                        If GetMv("MV_EEC_EDC",,.F.)
                                            EK7->EK7_TPAC   := DU400TpAC(Posicione("ED0", 2, xFilial("ED0")+EE9->EE9_ATOCON, "ED0_TIPOAC"))
                                            EK7->EK7_CNPJ   := Posicione('SYT', 1, xFilial('SYT')+Posicione("ED0", 2, xFilial("ED0")+EE9->EE9_ATOCON, "ED0_IMPORT"), 'YT_CGC')
                                            EK7->EK7_VALOR  := EE9->EE9_VL_AC - EE9->EE9_VLSCOB
                                            EK7->EK7_QTD    := Posicione("ED3", 2, xFilial("ED3")+EE9->EE9_ATOCON+EE9->EE9_SEQED3, "AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,EE9->EE9_QT_AC)")
                                        Else
                                            EK7->EK7_TPAC   := DU400TpAC(EE9->(If(FieldPos("EE9_TPAC") > 0 .And. !Empty(EE9_TPAC), EE9_TPAC, "")))
                                            EK7->EK7_CNPJ   := If(!Empty(EEC->EEC_EXPORT+EEC->EEC_EXLOJA), SI100CNPJ(EEC->EEC_EXPORT+EEC->EEC_EXLOJA), SI100CNPJ(EEC->EEC_FORN+EEC->EEC_FOLOJA))
                                            EK7->EK7_VALOR  := EE9->EE9_PRCINC - If( EasyGParam("MV_AVG0119",,.F.) , EE9->EE9_DESCON , EE9->EE9_VLDESC ) - EE9->EE9_VLSCOB
                                            EK7->EK7_QTD    := EK2->EK2_QTDNCM
                                        EndIf
                                        EK7->(msunlock())
                                    EndIf
                                EndIf
                                EK2->EK2_PCARGA := EE9->EE9_PCARGA
                                EK2->EK2_OBSPCA := EE9->EE9_OBSPCA
                                EK2->EK2_PERCOM := EE9->EE9_PERCOM
                                If EE9->(FieldPos("EE9_LPCO")) > 0
                                    EK2->EK2_LPCO   := EE9->EE9_LPCO
                                EndIf
                                EK2->EK2_VM_DES := DU400DscItem()
                                EK2->EK2_POSIPI := EE9->EE9_POSIPI
                                EK2->EK2_UNIDAD := EE9->EE9_UNIDAD
                                EK2->EK2_UNPES  := EE9->EE9_UNPES
                                EK2->EK2_PSLQUN := EE9->EE9_PSLQUN
                                EK2->EK2_ATOCON := EE9->EE9_ATOCON

                                if (!lEk4Lote .and. !avflags("DU-E3.1")) .or. avflags("DU-E3.1") //valida a quebra de lote e !avflags("DU-E3.1")
                                    // grava as notas de remessa para cada linha da EES
                                    cChaveEYY := xFilial("EYY")+EE9->EE9_PREEMB+EE9->EE9_SEQEMB
                                    if EYY->( dbsetorder(1) , msseek( cChaveEYY ))
                                        While EYY->( !Eof() ) .AND. cChaveEYY == EYY->(EYY_FILIAL+EYY_PREEMB+EYY_SEQEMB)
                                            if EES->EES_NRNF+EES->EES_SERIE == EYY->EYY_NFSAI+EYY->EYY_SERSAI
                                                lSF1NFPOS := SF1->( dbsetorder(1) , msseek( xfilial("SF1")+AvKey(EYY->EYY_NFENT,"F1_DOC")+AvKey(EYY->EYY_SERENT,"F1_SERIE")+AvKey(EYY->EYY_FORN,"F1_FORNECE")+AvKey(EYY->EYY_FOLOJA,"F1_LOJA") ) )
                                                SA2->( dbsetorder(1) , msseek( xFilial("SA2")+AvKey(EYY->EYY_FORN,"F1_FORNECE")+AvKey(EYY->EYY_FOLOJA,"F1_LOJA") ) )
                                                EK4->(Reclock("EK4",.T.))
                                                EK4->EK4_FILIAL := EYY->EYY_FILIAL
                                                EK4->EK4_PROCES := EYY->EYY_PREEMB
                                                EK4->EK4_NUMSEQ := EK0->EK0_NUMSEQ
                                                EK4->EK4_SEQUEN := EYY->EYY_SEQEMB
                                                EK4->EK4_NFENT  := EYY->EYY_NFENT
                                                EK4->EK4_SERENT := EYY->EYY_SERENT
                                                if EK4->(fieldpos("EK4_FATSEQ")) > 0
                                                    EK4->EK4_FATSEQ := DU400CnvSeq(EES->EES_FATSEQ)
                                                endif
                                                If lSF1NFPOS
                                                    EK4->EK4_ESPECI := SF1->F1_ESPECIE
                                                EndIf
                                                EK4->EK4_FORNEC := SA2->A2_COD
                                                EK4->EK4_LOJA   := SA2->A2_LOJA
                                                EK4->EK4_CGC    := SA2->A2_CGC
                                                EK4->EK4_PEDIDO := EYY->EYY_PEDIDO
                                                EK4->EK4_SEQPED := EYY->EYY_SEQUEN //Sequencia do Pedido
                                                cQuant := Du400GetVal(EE9->EE9_SEQEMB, "QUANTIDADE", EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ , EYY->EYY_NFENT+EYY->EYY_SERENT+EYY->EYY_D1ITEM)
                                                If AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
                                                    EK4->EK4_QUANT  := AVTransUnid(EYY->EYY_UNIDAD,BuscaNCM(EYY->EYY_POSIPI, "YD_UNID"),EYY->EYY_D1PROD,cQuant) //EYY->EYY_QUANT
                                                else
                                                    EK4->EK4_QUANT  := AVTransUnid(EE9->EE9_UNIDAD,BuscaNCM(EE9->EE9_POSIPI, "YD_UNID"),EE9->EE9_COD_I,cQuant) //EE9->EE9_SLDINI
                                                endif
                                                //EK4->EK4_QUANT  :=  Du400GetVal(EE9->EE9_SEQEMB, "QUANTIDADE", EES->EES_NRNF+EES->EES_SERIE+EES->EES_FATSEQ , EYY->EYY_NFENT+EYY->EYY_SERENT+EYY->EYY_D1ITEM)
                                                EK4->EK4_COD_I  := EYY->EYY_D1PROD
                                                EK4->EK4_D1ITEM := EYY->EYY_D1ITEM
                                                EK4->EK4_CHVNFE := EYY->EYY_CHVNFE
                                                EK4->EK4_NFSAI  := EYY->EYY_NFSAI
                                                EK4->EK4_SERSAI := EYY->EYY_SERSAI
                                                EK4->(msunlock())
                                            EndIf
                                            EYY->(dbskip())
                                        EndDo
                                    endif
                                endif
                            EndIf
                            EK2->(MsUnlock())
                            // grava as notas de qubra de lote para cada linha da EES
                            if avflags("DU-E3.1")
                                aNfsRem := {}
                                if len( (aNfsRem := DU400GetNfSRem(EEM->EEM_NRNF, EEM->EEM_SERIE, EEC->EEC_IMPORT, EEC->EEC_IMLOJA, EES->EES_FATSEQ, EES->EES_PREEMB, @aNfsRem) ) ) > 0
                                    For nX:= 1 to Len(aNfsRem)
                                        // X2_UNICO - --EK4_FILIAL+EK4_PROCES+EK4_NUMSEQ+EK4_SEQUEN+EK4_NFSAI+EK4_SERSAI+EK4_D1ITEM
                                        EK4->(Reclock("EK4",.T.))
                                        EK4->EK4_FILIAL := EES->EES_FILIAL
                                        EK4->EK4_PROCES := EES->EES_PREEMB
                                        EK4->EK4_NUMSEQ := EK1->EK1_NUMSEQ
                                        EK4->EK4_SEQUEN := EE9->EE9_SEQEMB
                                        EK4->EK4_NFSAI  := EES->EES_NRNF    // nota de venda
                                        EK4->EK4_SERSAI := EES->EES_SERIE   // serie nf de venda
                                        if EK4->(fieldpos("EK4_FATSEQ")) > 0
                                            EK4->EK4_FATSEQ := EES->EES_FATSEQ // d2item da nota de venda
                                        endif
                                        if len( aNfsRem[nX] ) > 3
                                            EK4->EK4_DOC    := aNfsRem[nX][4] // nota de remessa de lote
                                            EK4->EK4_SERIE  := aNfsRem[nX][5] // serie de remessa de lote
                                            EK4->EK4_CLIENT := aNfsRem[nX][6] 
                                            EK4->EK4_LOJACL := aNfsRem[nX][7]
                                        endif
                                        EK4->EK4_CHVNFS := aNfsRem[nX][1]
                                        EK4->EK4_D2ITEM := aNfsRem[nX][2]
                                        EK4->EK4_D2QTD  := AVTransUnid(EE9->EE9_UNIDAD,BuscaNCM(EE9->EE9_POSIPI, "YD_UNID"),EE9->EE9_COD_I,aNfsRem[nX][3])
                                        EK4->EK4_CGC    := SA2->A2_CGC
                                        EK4->EK4_PEDIDO := EES->EES_PEDIDO
                                        EK4->EK4_SEQPED := EES->EES_SEQUEN //Sequencia do Pedido
                                        EK4->EK4_COD_I  := EES->EES_COD_I
                                        EK4->EK4_QUANT  := EES->EES_QTDE
                                        EK4->(msunlock())
                                    Next
                                endif
                            endif
                        EES->(dbSkip())
                    EndDo
                EndIf
                EEM->(dbSkip())
            EndDo
        EndIf
    EndIf

   // PONTO DE ENTRADA PADRÃO ROTINA
   If EasyEntryPoint("EECDU100")
      ExecBlock("EECDU100",.f.,.f.,"GEREKS")
   EndIf

restarea(aAreaEE9)
restarea(aAreaEEM)
restarea(aAreaEES)
restarea(aAreaEYY)
restarea(aAreaEYU)
restarea(aAreaEWI)
restarea(aAreaSA1)
restarea(aAreaSA2)

Return
// valida se existe quebra de lote para a linha da ee9, onde mais de uma EEs é quebra lote
static function EK4Lote(cEES_PREEMB, cEES_COD_I, cEES_SEQUEN, cEES_NRNF, cEES_SERIE)
Local nl := 0
Local cQuery := ""
Local lRet := .F.

   cQuery += " SELECT EES_PREEMB, EES_COD_I, EES_SEQUEN, EES_NRNF, EES_SERIE "
   cQuery += " FROM "+retsqlname("EES")+" S "
   cQuery += " INNER JOIN "+retsqlname("EE9")+" E "
   cQuery += " ON EE9_PREEMB = EES_PREEMB "
   cQuery += " AND EE9_SEQEMB = EES_SEQUEN "
   cQuery += " AND EE9_NF = EES_NRNF "
   cQuery += " AND EE9_SERIE = EES_SERIE "
   cQuery += " AND EE9_COD_I = EES_COD_I "
   cQuery += " AND E.D_E_L_E_T_<>'*' "
   cQuery += " WHERE S.D_E_L_E_T_<>'*' "
   cQuery += " AND EES_FILIAL =    '"+xFilial("EES")+"'"
   cQuery += " AND EES_PREEMB =    '"+cEES_PREEMB+"'   "
   cQuery += " AND EES_COD_I =     '"+cEES_COD_I+"'    "
   cQuery += " AND EES_SEQUEN =    '"+cEES_SEQUEN+"'   "
   cQuery += " AND EES_NRNF=       '"+cEES_NRNF+"'     "
   cQuery += " AND EES_SERIE=      '"+cEES_SERIE+"'    "

   if Select( "TMPEES" ) > 0
      TMPEES->( dbclosearea() )
   endif

   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TOPCONN" , TCGenQry(,, cQuery), "TMPEES", .T., .T.) 
   TMPEES->(dbgotop())
   TMPEES->(dbeval( {|| nl++ , iif( nl > 1 , lRet := .T. , ) },,{|| !lRet }))
   TMPEES->( dbclosearea() )

return lRet
/*
Função     : PosEE9ItNF()
Parametros : cChave - Chave de pesquina na EE9 (xFilial("EE9")+EES->EES_PREEMB+EES->EES_PEDIDO+EES->EES_SEQUEN)
Retorno    : lRet - Retorna .T. se posicionou o item da EE9 referente ao item da NF - EES
Objetivos  : Posicionar o item da EE9 equivalente ao item da NF
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 26/04/2018
*/
Function PosEE9ItNF(cChave,cNota,cSerie)
Local lRet := .F.

   EE9->(DbSetOrder(2)) //EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN
   EE9->(MsSeek(cChave))
   While EE9->(!Eof()) .And. cChave == EE9->EE9_FILIAL + EE9->EE9_PREEMB + EE9->EE9_PEDIDO + EE9->EE9_SEQUEN
      If EE9->EE9_NF == cNota .And. EE9->EE9_SERIE == cSerie
         lRet := .T.
         Exit
      EndIf
      EE9->(dbSkip())
   End

Return lRet

/*
Função     : DU100PAISE()
Parametros : -
Retorno    : cRet - Codigo do pais DUE de destino - EK1_PAISET/EEC_PAISET
Objetivos  : Caso nao exista o campo da EK1, retornar o campo equivalente da EEC
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 10/10/2019
*/
Function DU100PAISE()
Local cRet      := ""
Local aAreaEEC  := EEC->(GetArea())

   EEC->(dbsetorder(1))
   If EK1->(FieldPos("EK1_PAISET")) > 0
      cRet := EK1->EK1_PAISET
   Else
      If EEC->(dbSeek(xFilial("EEC") + EK1->EK1_PROCES))
         cRet := GetAdvFVal("SYA","YA_PAISDUE",xFilial("SYA")+EEC->EEC_PAISET ,1,"",.T.)
      EndIf
   EndIf
   RestArea(aAreaEEC)

Return cRet


/*
CLASSE PARA CRIAÇÃO DE EVENTOS E VALIDAÇÕES NOS FORMULÁRIOS
THTS - TIAGO HENRIQUE TUDISCO DOS SANTOS
 */
Class DU100EV FROM FWModelEvent
     
   Method New()
   Method InTTS()

End Class

Method New() Class DU100EV
Return

Method InTTS(oModel, cModelId) Class DU100EV
   DU400GrvStatus()
Return