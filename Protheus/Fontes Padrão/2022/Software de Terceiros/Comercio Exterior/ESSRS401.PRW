#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH" 
#INCLUDE "ESSRS401.CH" 


/*
Função     : ESSRS401
Parâmetros : -
Retorno    : -
Objetivos  : Manutenção dos Pagamentos de Serviços(EJZ)
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 23/08/12 - 10:15
Revisao    : 
Obs.       :
*/
Function ESSRS401(nOpc, nReg, nOpc)
Private lRs401R := .F.

If nOpc==6
   lRs401R := .F.
   ESSRS401S()
Else
   If RS400PgtReg(1,, .T.)
      lRs401R := .T.
      ESSRS401R()
   EndIf
EndIf

Return Nil

/*
"Pagamentos por Serviços"
*/
Function ESSRS401S()
Local aCoors := FWGetDialogSize( oMainWnd )
Private oPanelUp := NIL, oFWLayer := NIL, oPanelLeft := NIL, oPanelRight:= NIL, oBrowseUp:= NIL, oBrowseLeft:= NIL, oBrowseRight:= NIL, oRelacEJZ:= NIL, oRelacEEQ:= NIL
Private oDlgPrinc := NIL
Private aRotina := NIL


Define MsDialog oDlgPrinc Title If(cTpReg=="A",STR0001, "Faturamentos") From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //"Pagamentos"
   
   // Cria o conteiner onde serão colocados os browses
   oFWLayer := FWLayer():New()
   oFWLayer:Init( oDlgPrinc, .F., .T. )
   
   // Define Painel Superior
   oFWLayer:AddLine( 'UP', 50, .F. )// Cria uma "linha" com 50% da tela
   oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
   oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )// Pego o objeto desse pedaço do container

   // Painel Inferior                 
   oFWLayer:AddLine( 'DOWN', 50, .F. )// Cria uma "linha" com 50% da tela
   oFWLayer:AddCollumn( 'LEFT' , 50, .T., 'DOWN' )// Na "linha" criada eu crio uma coluna com 50% da tamanho dela
   oFWLayer:AddCollumn( 'RIGHT', 50, .T., 'DOWN' )// Na "linha" criada eu crio uma coluna com 50% da tamanho dela
   
   oPanelLeft := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' ) // Pego o objeto do pedaço esquerdo
   oPanelRight := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' ) // Pego o objeto do pedaço direito
   
   // FWmBrowse Superior Det. dos Registros de Serviços
   oBrowseUp:= FWmBrowse():New()
   oBrowseUp:SetOwner( oPanelUp )
   oBrowseUp:SetFilterDefault(" EJZ->EJZ_FILIAL == EJY->EJY_FILIAL .AND. EJZ->EJZ_TPPROC == EJY->EJY_TPPROC .And. EJZ->EJZ_REGIST == EJY->EJY_REGIST ")//Filtro do Browse
   
   // Aqui se associa o browse ao componente de tela
   oBrowseUp:SetDescription( STR0002 )//"Serviços"
   oBrowseUp:SetAlias( 'EJZ' )
   oBrowseUp:SetMenuDef( '' )
   
   // Define de onde virao os botoes deste browse
   oBrowseUp:SetProfileID( '1' ) // identificador (ID) para o Browse
   oBrowseUp:ForceQuitButton() // Força exibição do botão "Sair"
   oBrowseUp:DisableDetails()
   oBrowseUp:Activate() 
   
   
   // FWmBrowse Parcelas de Cambio
   oBrowseLeft:= FWMBrowse():New()
   oBrowseLeft:SetOwner( oPanelLeft )   
   oBrowseLeft:SetDescription( STR0003 )
   oBrowseLeft:SetMenuDef( 'ESSRS401' ) // Nome do fonte do MenuDef 
   oBrowseLeft:SetAlias( 'EEQ' )
   oBrowseLeft:SetProfileID( '2' ) 
   //oRelacEJZ:AddRelation( oBrowseUp, oBrowseLeft , { { 'EEQ_FILIAL', 'xFilial("EEQ")' }, { 'EEQ_TPPROC' , 'EJZ_TPPROC' }, { 'EEQ_REGIST','EJZ_REGIST'}, { 'EEQ_SEQREG','EJZ_SEQREG'} } )
   //RRC - 14/02/2013
   //oBrowseLeft:SetFilterDefault("EEQ->EEQ_FILIAL == xFilial('EJZ') .AND. EEQ->EEQ_TPPROC == EJZ->EJZ_TPPROC .And. EEQ->EEQ_REGIST == EJZ->EJZ_REGIST .And. EEQ->EEQ_SEQREG == EJZ->EJZ_SEQREG")//Filtro do Browse
   oBrowseLeft:DisableDetails()
   oBrowseLeft:ForceQuitButton() // Força exibição do botão "Sair"
   //AF200ParcLiq se for liquidado eh true se nao false
   oBrowseLeft:AddLegend( "!AF200ParcLiq()", "RED"   , "Nao Baixado" )//Campo para adicionar marcação
   oBrowseLeft:AddLegend( "AF200ParcLiq()" , "Green" , "Baixado" )//Campo para adicionar marcação 
   oBrowseLeft:Activate() 
   
   
   // FWmBrowse Pagamentos de Serviços
   oBrowseRight:= FWMBrowse():New()
   oBrowseRight:SetOwner( oPanelRight )
   oBrowseRight:SetDescription( If(cTpReg=="A",STR0004, "Faturamentos de Serviços") )//"Pagamentos de Serviços"
   oBrowseRight:SetMenuDef( 'ESSRS402' )
   oBrowseRight:DisableDetails()// exiba nenhum botao
   oBrowseRight:SetAlias( 'EL1' )
   oBrowseRight:SetProfileID( '3' )
   //RRC - 14/02/2013
   //oBrowseRight:SetFilterDefault("EL1->EL1_FILIAL == xFilial('EJZ') .AND. EL1->EL1_TPPROC == EJZ->EJZ_TPPROC .And. EL1->EL1_REGIST == EJZ->EJZ_REGIST")//Filtro do Browse
   oBrowseRight:AddLegend( "EL9_STTSIS=='1'", "RED"   , "Aguardando registro no SISCOSERV" )//Campo para adicionar marcação
   oBrowseRight:AddLegend( "EL9_STTSIS=='2'", "GREEN" , "Registrado no SISCOSERV" )//Campo para adicionar marcação
   oBrowseRight:AddLegend( "EL9_STTSIS=='3'", "YELLOW", "Aguardando cancelamento no SISCOSERV" )//Campo para adicionar marcação
   oBrowseRight:AddLegend( "EL9_STTSIS=='4'", "BLUE"  , "Cancelado no SISCOSERV" )//Campo para adicionar marcação
      
   oBrowseRight:Activate()


   DbSelectArea("EEQ")
   // Relacionamento entre os Paineis

   //oRelacEJZ:= FWBrwRelation():New()
   //oRelacEJZ:AddRelation( oBrowseUp, oBrowseLeft , { { 'EEQ_FILIAL', 'xFilial("EEQ")' }, { 'EEQ_TPPROC' , 'EJZ_TPPROC' }, { 'EEQ_REGIST','EJZ_REGIST'}, { 'EEQ_SEQREG','EJZ_SEQREG'} } )
   //oRelacEJZ:Activate()
   oRelacEL1:= FWBrwRelation():New()   
   oRelacEL1:AddRelation( oBrowseUp, oBrowseRight, { { 'EL1_FILIAL', 'xFilial("EL1")' }, { 'EL1_TPPROC','EJZ_TPPROC'  }, {'EL1_REGIST', 'EJZ_REGIST'}/*,{ 'EL1_SEQREG','EJZ_SEQREG' }*/ } )
   EL1->(DbSetOrder(2))
   oRelacEL1:Activate() 

   oBrowseUp:Refresh()
   oBrowseLeft:Refresh(.T.)
   oBrowseRight:Refresh(.T.)
  
Activate MsDialog oDlgPrinc Center

Return

/*
"Pagamentos dos Registros"
*/
Function ESSRS401R()
Local aCoors := FWGetDialogSize( oMainWnd )
Private oPanelUp := NIL, oFWLayer := NIL, oPanelLeft := NIL, oPanelRight:= NIL, oBrowseUp:= NIL, oBrowseLeft:= NIL, oBrowseRight:= NIL, oRelacEJZ:= NIL, oRelacEEQ:= NIL
Private oDlgPrinc := NIL
Private aRotina := NIL


Define MsDialog oDlgPrinc Title If(cTpReg=="A",STR0001, "Faturamentos") From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //"Pagamentos" 
   
   // Cria o conteiner onde serão colocados os browses
   oFWLayer := FWLayer():New()
   oFWLayer:Init( oDlgPrinc, .F., .T. )
   
   // Define Painel Superior
   oFWLayer:AddLine( 'UP', 50, .F. )// Cria uma "linha" com 50% da tela
   oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
   oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )// Pego o objeto desse pedaço do container

   // Painel Inferior                 
   oFWLayer:AddLine( 'DOWN', 50, .F. )// Cria uma "linha" com 50% da tela
   oFWLayer:AddCollumn( 'ALL_D' , 100, .T., 'DOWN' )
   
   oPanelDown := oFWLayer:GetColPanel( 'ALL_D' , 'DOWN' )
   
   // FWmBrowse Parcelas de Cambio
   oBrowseUp:= FWmBrowse():New()
   oBrowseUp:SetOwner( oPanelUp )
   //oBrowseUp:SetFilterDefault(" EJY->EJY_FILIAL == EEQ->EEQ_FILIAL .AND. EJY->EJY_TPPROC == EEQ->EEQ_TPPROC .And. EJY->EJY_REGIST == EEQ->EEQ_REGIST ") //Filtro do Browse
   oBrowseUp:SetDescription( "Parcelas dos "+If(cTpReg=="A",STR0001, "Faturamentos") )
   oBrowseUp:SetMenuDef( 'ESSRS401' ) // Nome do fonte do MenuDef 
   oBrowseUp:SetAlias( 'EEQ' )
   oBrowseUp:SetProfileID( '1' ) 
   oBrowseUp:DisableDetails()
   oBrowseUp:AddLegend( "!AF200ParcLiq()", "RED"   , "Nao Baixado" )//Campo para adicionar marcação
   oBrowseUp:AddLegend( "AF200ParcLiq()" , "Green" , "Baixado" )//Campo para adicionar marcação 
   
   oBrowseUp:Activate() 
   
   // FWmBrowse Pagamentos de Serviços
   oBrowseDown:= FWMBrowse():New()
   oBrowseDown:SetOwner( oPanelDown )
   oBrowseDown:SetDescription( If(cTpReg=="A",STR0004, "Faturamentos de Serviços") )//"Pagamentos de Serviços"
   oBrowseDown:SetMenuDef( 'ESSRS402' )
   oBrowseDown:DisableDetails( )//Exiba nenhum botão
   oBrowseDown:SetAlias( 'EL1' )
   oBrowseDown:SetProfileID( '2' )
   //RRC - 14/02/2013
   //oBrowseDown:SetFilterDefault("EL1->EL1_FILIAL == xFilial('EEQ') .AND. EL1->EL1_TPPROC == EEQ->EEQ_TPPROC .And. EL1->EL1_REGIST == EEQ->EEQ_REGIST")//Filtro do Browse
   oBrowseDown:ForceQuitButton() // Força exibição do botão "Sair"
   oBrowseDown:AddLegend( "EL9_STTSIS=='1'", "RED"   , "Aguardando registro no SISCOSERV" )//Campo para adicionar marcação
   oBrowseDown:AddLegend( "EL9_STTSIS=='2'", "BLUE"  , "Registrado no SISCOSERV" )//Campo para adicionar marcação
   oBrowseDown:AddLegend( "EL9_STTSIS=='3'", "YELLOW", "Aguardando cancelamento no SISCOSERV" )//Campo para adicionar marcação
   oBrowseDown:AddLegend( "EL9_STTSIS=='4'", "GREEN" , "Cancelado no SISCOSERV" )//Campo para adicionar marcação
   oBrowseDown:Activate()

   DbSelectArea("EEQ")

   //oRelacEL1:= FWBrwRelation():New()   
   //oRelacEL1:AddRelation( oBrowseUp ,oBrowseDown, { { 'EL1_FILIAL', 'xFilial("EL1")' }, { 'EL1_TPPROC','EEQ_TPPROC'  }, {'EL1_REGIST', 'EEQ_REGIST'} } )
   EL1->(DbSetOrder(2))
   //oRelacEL1:Activate() 

   oBrowseUp:Refresh()
   oBrowseDown:Refresh(.T.)
   
Activate MsDialog oDlgPrinc Center

Return


/*
Função     : MenuDef()
Parâmetros : -
Retorno    : aRotina
Objetivos  : Operações de pagamentos
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 23/08/12 - 10:35
Revisao    : 
Obs.       :
*/
Static Function MenuDef() 

Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0005     ACTION "AxPesqui"     OPERATION 1 ACCESS 0 //"Pesquisar" 
ADD OPTION aRotina TITLE STR0006     ACTION "RS401Menu"    OPERATION 2 ACCESS 0 //"Visualizar" 
ADD OPTION aRotina TITLE STR0007     ACTION "RS401Menu"    OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0008     ACTION "RS401Menu"    OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0009     ACTION "RS401Menu"    OPERATION 5 ACCESS 0 //"Excluir" 
ADD OPTION aRotina TITLE STR0010     ACTION "RS401Menu"    OPERATION 6 ACCESS 0 //"Liquidar" 
ADD OPTION aRotina TITLE STR0011     ACTION "RS401Menu"    OPERATION 7 ACCESS 0 //"Estornar Liq."
ADD OPTION aRotina TITLE "Legendas"  ACTION "RS401Legenda" OPERATION 7 ACCESS 0 //"Estornar Liq."

If EECFlags("CAMBIO_EXT")
  ADD OPTION aRotina TITLE STR0012 ACTION "RS401Menu"    OPERATION 97 ACCESS 0 //"Bx. Geren."
EndIf

ADD OPTION aRotina TITLE STR0013   ACTION "RS401GerPagto" OPERATION 3 ACCESS 0 //"Gerar Parc."


Return aRotina

Static Function ModelDef()
Return

Static Function ViewDef()
Return



/*
Função     : RS401Menu()
Parâmetros : cAlias - Alias da Tabela Correspondent
             nRec   - Numero do Registro selecionado
             nOpc   - Numero da Operação selecionada
Retorno    : aRotina
Objetivos  : Chamar a Rotina EECAF500 que efetua as operaçoes (Incluir,Alterar,Excluir,Liquidar,Estornar Liq.)
             e atualizar os browsers
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 24/08/12 - 11:35
Revisao    : 
Obs.       :
*/
Function RS401Menu(cAlias,nRec,nOpc)
/*NOPADO por RRC - 10/04/2013 - Os campos EEQ_REGIST  e EEQ_SEQREG foram excluídos, as operações de pagamento/faturamento são realizadas pelo ESSRS402()
If nOpc == INCLUIR .OR. EEQ->(EEQ_FILIAL+EEQ_TPPROC+EEQ_REGIST+EEQ_SEQREG) == xFilial("EEQ")+EJZ->(EJZ_TPPROC+EJZ_REGIST+EJZ_SEQREG) .Or. ( (!(Type("lRs401R")=="L") .Or. lRs401R) .And. EJZ->(DBSetOrder(1), DBseek(EEQ->(xFilial()+EEQ_TPPROC+EEQ_REGIST+EEQ_SEQREG))) )
   If RS400PgtReg(2,nOpc,.T.)
      EECAF500(cAlias,nRec,nOpc)
      If Type("oBrowseDown")=="O"
         oBrowseDown:Refresh(.T.)
         oBrowseUp:Refresh(.T.)
      Else
         oBrowseUp:Refresh()////Nao deve-se passar o parmetro .T. no refresh pois disposiciona o registro.
         oBrowseLeft:Refresh(.T.)
         oBrowseRight:Refresh(.T.)
      EndIf
   EndIf
Else
   Help("",,"ARQVAZIO")
EndIf
*/
Return

   
/*
Função     : RS401PrxNum()
Parâmetros : cKey - Indice (1) da Tabela EL1
Retorno    : cSeq - Proxima sequencia a ser utilizada
Objetivos  : Verifica a ultima sequencia da tabela de Pagamento e soma + 1
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 24/08/12 - 15:30
Revisao    : 
Obs.       :
*/
*-------------------------*
Function RS401PrxNum(cKey)
*-------------------------*
Local cSeq := ""
Local nOrdAnt, nRecWkEL1

nOrdAnt  := EL1->(IndexOrd())
nRecWkEL1:= EL1->(Recno()) 
EL1->(DbSetOrder(2))//EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQPAG
If EL1->(AVSeekLast(xFilial("EL1")+cKey))   
   cSeq := SomaIt(EL1->EL1_SEQPAG)
Else
   cSeq := "01"
EndIf

EL1->(DbSetOrder(nOrdAnt))
If nRecWkEL1 > 0 
   EL1->(DbGoTo(nRecWkEL1))
EndIf


Return cSeq


/*
Função     : RS401GerPagto()
Parâmetros : -
Retorno    : -
Objetivos  : Gerar a(s) parcela(s) de Cambio(EEQ)
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 24/08/12 - 17:35
Revisao    : 
Obs.       :
*/
*------------------------*
Function RS401GerPagto(lHelp)
*------------------------*
Local i
Local lSeek
Local aBrowse:= {}
Local cMsg := ""
Local aEEQAuto := {}
Local aOrd   := SaveOrd({"EL2","EL1","EEQ"})
Local lRet:=.T.
Private lMSErroAuto := .F.

// Utilizado no ponto de entrada
Private aParc := {} 
Private dDtIni

Default lHelp := .T.

lHelp := If(ValType(lHelp)<>"L", .T., lHelp)

Begin Sequence

   EEQ->(DbSetOrder(1))//EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
   lSeek := EEQ->(DbSeek(xFilial("EEQ") + AvKey(EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG,"EEQ_PREEMB") + STRZERO(1,2) + IF(EJZ->EJZ_TPPROC == "A","4","3") ))
   
   // BAK - 02/10/2012
   If lSeek
      If lHelp
         EasyHelp(STR0018,STR0014) //  "Existe parcela de câmbio gerada.","Aviso!"
      EndIf
      Break   
   EndIf
   
   If !RS400PgtReg(2, 3, lHelp)
      Break
   EndIf
      
   If EJZ->(EOF())
      If lHelp 
         EasyHelp(STR0015,STR0014)//"Não existem parcelas de câmbio a serem geradas, pois não foram encontrados registros de serviços.","Aviso!"
      EndIf
      Break
   EndIf
                    
   If Empty(EJZ->EJZ_DTINI) //É necessario a data efetiva de inicio estar preenchida para gerar parcela de cambio para o serviço
      If lHelp
         EasyHelp(STR0016,STR0014)//"Não será possivel gerar parcelas de cambio para esse serviço pois a data efetiva de inicio nao esta preenchida.","Aviso!"
      EndIf
      Break
   EndIf

   dDtIni := EJZ->EJZ_DTINI   
   aParc := Condicao(EJZ->EJZ_VL_MOE,EJZ->EJZ_CONDPG,,EJZ->EJZ_DTINI,,,,,,)  
      
   // Ponto de entrada
   If EasyEntryPoint("EECAF500")
      ExecBlock("EECAF500",.F.,.F.,{ "GERACAO_PARCELA_SERVICO" })
   Endif
    
   For i := 1 To Len(aParc)
      aEEQAuto := {}
      aAdd(aEEQAuto,{"EEQ_FILIAL", AvKey(xFilial("EEQ"),"EEQ_FILIAL")                    , Nil })
      aAdd(aEEQAuto,{"EEQ_PREEMB", AvKey(EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG   ,"EEQ_PREEMB")   , Nil })
      aAdd(aEEQAuto,{"EEQ_EVENT" , IF(EJZ->EJZ_TPPROC == "A","001","501")                , Nil })
      aAdd(aEEQAuto,{"EEQ_NRINVO", EJZ->EJZ_REGIST                                         , Nil })
      aAdd(aEEQAuto,{"EEQ_PARC"  , AvKey(STRZERO(i,AVSX3("EEQ_PARC",3),0),"EEQ_PARC") , Nil })
      aAdd(aEEQAuto,{"EEQ_VCT"   , aParc[i][1]                                           , Nil })
      aAdd(aEEQAuto,{"EEQ_MOEDA" , EJY->EJY_MOEDA                                        , Nil })
      aAdd(aEEQAuto,{"EEQ_PARI"  , 1                                                     , Nil })
      aAdd(aEEQAuto,{"EEQ_VL"    , aParc[i][2]                                           , Nil })
      aAdd(aEEQAuto,{"EEQ_DECAM" , "2"                                                   , Nil })
      aAdd(aEEQAuto,{"EEQ_FASE"  , AvKey(IF(EJZ->EJZ_TPPROC == "A","4","3"),"EEQ_FASE")  , Nil })
      aAdd(aEEQAuto,{"EEQ_TIPO"  , IF(EJZ->EJZ_TPPROC == "A","P","R")                    , Nil }) //Aquisiçao == "A" == "P" -> Cambio a Pagar, Venda == "V" == "R" -> Cambio a Receber
      If EEQ->(FieldPos("EEQ_PARVIN")) > 0
         aAdd(aEEQAuto,{"EEQ_PARVIN" , STRZERO(i,Len(AllTrim(STR(i)))+1,0)               , Nil })
      EndIf
      If EJZ->EJZ_TPPROC == "A" //Na Aquisição será necessario gravar dados do Fornecedor
         aAdd(aEEQAuto,{"EEQ_FORN"   , EJY->EJY_EXPORT                                   , Nil })
         aAdd(aEEQAuto,{"EEQ_FOLOJA" , EJY->EJY_LOJEXP                                   , Nil })
      Else //Caso seja Venda será necessario gravar dados do Importador
         aAdd(aEEQAuto,{"EEQ_IMPORT" , EJY->EJY_IMPORT                                   , Nil })
         aAdd(aEEQAuto,{"EEQ_IMLOJA" , EJY->EJY_LOJIMP                                   , Nil })
      EndIf
      If EEQ->(FieldPos("EEQ_HVCT")) > 0
         aAdd(aEEQAuto,{"EEQ_HVCT"   , aParc[i][1]                                       , Nil })
      EndIf
      aAdd(aEEQAuto,{"EEQ_TPPROC"    , EJZ->EJZ_TPPROC                                   , Nil })
      aAdd(aEEQAuto,{"EEQ_MODAL"     , "1"                                               , Nil })
      If EEQ->(FieldPos("EEQ_EMISSA")) > 0
         aAdd(aEEQAuto,{"EEQ_EMISSA"   , dDtIni                                          , Nil })
      EndIf
      aAdd(aEEQAuto,{"EEQ_TP_CON"    , IF(EJZ->EJZ_TPPROC == "A","4","3")                , Nil })

      MsExecAuto({|l,y,z,w,x,k| EECAF500(l,y,z,w,x,k)},"EEQ", , ,aEEQAuto,3,EJZ->EJZ_TPPROC)
      If lMsErroAuto
         //RRC - 20/02/2013
         /*Para casos de execauto do Siscoserv com chamada direta da função RS400GerParc(), mesmo com a chamada do EasyHelp() na função AF500AtuaEEQ(),
         a função NomeAutoLog() não retornava a mensagem de erro após uma tentativa inválida de inclusão*/ 
         If ValType(cMsg := NomeAutoLog()) == "U"   
            cMsg := "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."        
         Else
            cMsg := MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
         EndIf
         EasyHelp(cMsg)
         lRet := .F.
         Break
      EndIf

   Next i
      
      
End Sequence

If Type("oBrowseUp")=="O"
   If Type("oBrowseDown")=="O"
      oBrowseDown:Refresh(.T.)
      oBrowseUp:Refresh(.T.)
   Else
      oBrowseUp:Refresh()//Nao deve-se passar o parmetro .T. no refresh pois disposiciona o registro.
      oBrowseLeft:Refresh(.T.)
      oBrowseRight:Refresh(.T.)
   EndIf
EndIf

RestOrd(aOrd,.T.)

Return lRet

/*
Função     : RS401Pagto()
Parâmetros : nTipo - 1 := Inclusao e 2 := Estorno
Retorno    : -
Objetivos  : Gera o pagamento de acordo com os dados da parcela de cambio(EEQ)
             e o serviço(EJZ)
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 28/08/12 - 13:35
Revisao    : 
Obs.       :
*/
*------------------------------------*
Function RS401Pagto(nTipo,cSeqPag,lExibMsg)
*------------------------------------*
Local cDoc       := EasyGParam("MV_AVG0224",,"EEQ_NRINVO")//Campo responsavel pelo Numero do Documento(EL1_DOC) no Pagamento de Servicos.
Local nPrazo     := EasyGParam("MV_AVG0225",,30)//Prazo de Dias para registrar o pagamento no SISCOSERV.
Local aOrd       := SaveOrd({"EL2","EL1","EEQ"})
Local lRet       := .T.
Default nTipo    := 1
Default cSeqPag  := RS401PrxNum(EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST)
Default lExibMsg := .T. //RRC - 08/03/2013 - Verifica se exibe a mensagem de confirmação de estorno de liquidação
Private cCanLote := ""
Begin Sequence 

   If nTipo == 1 // Inclusao

      // BAK - 09/10/2012
      // Caso seja uma parcela a aquisição e nao for o mesmo fornecedor do Servico, nao gerar o pagamento de servico
      If EEQ->EEQ_TPPROC == "A" .And. !AllTrim(Upper(EJY->EJY_EXPORT+EJY->EJY_LOJEXP)) == AllTrim(Upper(EEQ->EEQ_FORN+EEQ->EEQ_FOLOJA))
         Break
      EndIf

      // Caso seja uma parcelar a venda e nao for o mesmo cliente do Servico, nao gerar o pagamento de servico
      If EEQ->EEQ_TPPROC == "V" .And. !AllTrim(Upper(EJY->EJY_IMPORT+EJY->EJY_LOJIMP)) == AllTrim(Upper(EEQ->EEQ_IMPORT+EEQ->EEQ_IMLOJA))
         Break
      EndIf
   
      If EL1->(RecLock("EL1",.T.))

         EL1->EL1_FILIAL := xFilial("EL1")
         EL1->EL1_TPPROC := EEQ->EEQ_TPPROC
         EL1->EL1_SEQPAG := cSeqPag //RS401PrxNum(EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST)
         EL1->EL1_PARC   := EEQ->EEQ_PARC
         EL1->EL1_DOC    := EEQ->&(cDoc)
         EL1->EL1_DTPAG  := IF(EEQ->EEQ_MODAL == "2",EEQ->EEQ_DTCE,EEQ->EEQ_PGT)
         If EEQ->EEQ_MODAL == "2"
            EL1->EL1_VLEXT := EEQ->EEQ_VL
         Else
            EL1->EL1_VLCAMB:= EEQ->EEQ_VL
         EndIf
         //EL1->EL1_STTSIS := "1"
         //EL1->EL1_PRAZO  := EL1->EL1_DTPAG + nPrazo
         //RRC - 10/04/2013 - O campo EEQ_SEQPAG foi excluído
         /*If EEQ->(RecLock("EEQ",.F.))
            EEQ->EEQ_SEQPAG := EL1->EL1_SEQPAG
            EEQ->(MsUnlock())
         EndIf*/
         EL1->(MsUnLock())   
         //RRC - 10/04/2013 - OS campos EEQ_REGIST e EEQ_SEQREG foram excluídos
         //RS401STTPAG(1,EEQ->EEQ_TPPROC,EEQ->EEQ_REGIST,EEQ->EEQ_SEQREG)//Registra status do pagamento na tabela EJZ na operação de Liquidação da Parcela de Cambio
      EndIf


   ElseIf nTipo == 2 // Estorno - Não vai deletar a parcela mas sim alterar o status "EL1_STTSIS"
      //EL2->(DbSetOrder(1))//EL2_FILIAL+EL2_TPPROC+EL2_REGIST+EL2_SEQREG+EL2_SEQPAG+EL2_SEQDOC
      //EL1->(DbSetOrder(1))//EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG+EL1_PARC+EL1_SEQPAG
      /*RRC - 10/04/2013 - O campo EEQ_SEQPAG, EEQ_REGIST e EEQ_SEQREG foram excluídos
      
      If EL1->(DbSeek(xFilial("EL1") + EEQ->EEQ_TPPROC + EEQ->EEQ_REGIST + EEQ->EEQ_SEQREG + EEQ->EEQ_PARC + EEQ->EEQ_SEQPAG))
         
         //Verifica se o Registro ja foi integrado no SISCOSERV, caso sim altera o status para cancelado, caso nao exclui o registro de pagto.

         //1=Aguardando registro no SISCOSERV; 2=Registrado no SISCOSERV; 3=Aguardando cancelamento no SISCOSERV; 4=Cancelado no SISCOSERV.
         If EL1->EL1_STTSIS <> "1" .Or. !RS401VerLote(EL1->EL1_TPPROC, EL1->EL1_REGIST, EL1->EL1_SEQPAG)      
            If lExibMsg .And. !MsgYesNo(STR0017,STR0014)//"Esse serviço já foi registrado no SISCOSERV, deseja continuar com o cancelamento?","Aviso" 
               lRet := .F.
               DisarmTransaction()
               Break
            EndIf
            If EL1->(RecLock("EL1",.F.))
               EL1->EL1_STTSIS := "3"                              
               EL1->(MsUnlock())
            EndIf
            //RRC - 06/03/2013 - Se existir lote gerado ainda não registrado, terá que cancelá-lo para dar continuidade
         ElseIf Empty(cCanLote) .Or. (If(MsgYesNo(STR0019+cCanLote+STR0020,STR0014),SS101CanLote(cCanLote, .T.),.F.)) //STR0019: "Este serviço possui o lote " - STR0020: " não cancelado. Deseja continuar?"            
            //RRC - 16/10/2012 - Exclui os Documentos relacionados a este Pagamento
            If EL2->(DbSeek(xFilial("EL2") + EL1->EL1_TPPROC + EL1->EL1_REGIST + EL1->EL1_SEQREG + EL1->EL1_SEQPAG))
               Do While EL2->(!EOF()) .And. xFilial("EL2") == EL2->EL2_FILIAL .And. EL2->EL2_TPPROC == EL1->EL1_TPPROC .And.;
               EL2->EL2_REGIST == EL1->EL1_REGIST .And. EL2->EL2_SEQREG == EL1->EL1_SEQREG .And. EL2->EL2_SEQPAG == EL1->EL1_SEQPAG     
                  If EL2->(RecLock("EL2",.F.)) 
                     EL2->(DbDelete())
                  EL2->(MsUnlock())
                  EndIf
                  EL2->(DbSkip())
               EndDo
            EndIf
            If EL1->(RecLock("EL1",.F.))
               EL1->(DbDelete())
               EL1->(MsUnlock())
            EndIf
         Else
            lRet := .F.
            DisarmTransaction()
            Break     
         EndIf
         
         //Limpa Sequencia da Parcela de Pagamento na EEQ
         //RRC - 10/04/2013 - Os campos EEQ_SEQPAG, EEQ_REGIST e EEQ_SEQREG foram excluídos
         //If EEQ->(RecLock("EEQ",.F.))
         //   EEQ->EEQ_SEQPAG := ""
         //   EEQ->(MsUnlock())
         //EndIf
         //RS401STTPAG(2,EEQ->EEQ_TPPROC,EEQ->EEQ_REGIST,EEQ->EEQ_SEQREG)//Registra status do pagamento na tabela EJZ na operação de Estorno da Liquidação da Parcela de Cambio
     
      EndIf*/
      
   EndIf

End Sequence
RestOrd(aOrd,.T.)
Return lRet


/*
Função     : RS401STTPAG()
Parâmetros : nTipo - 1 := Liquidação e 2 := Estorno da Liq.
Retorno    : -
Objetivos  : Atualiza o status de pagamento dos serviços(EJZ)
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 28/08/12 - 17:05
Revisao    : 
Obs.       :
*/
*--------------------------*
Function RS401STTPAG(nTipo, cTpProc, cProc, cSeqPro)
*--------------------------*
/*Local nValorLiquidado := 0 
Local cStatusPag := ""
Local aOrd  := SaveOrd({"EL1","EJZ"})

EJZ->(DbSetOrder(1))//EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQREG
If EJZ->(DbSeek(xFilial("EJZ") + cTpProc + cProc + cSeqPro))
   EL1->(DbSetOrder(1)) // EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG
   If EL1->(DbSeek( xFilial("EL1") + cTpProc + cProc + cSeqPro)) 
      Do While EL1->(!Eof()) .And. EL1->(EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG) == xFilial("EL1") + cTpProc + cProc + cSeqPro
         //RRC - 07/03/2013 - Somente considera os valores de pagamentos com status "Aguardando Registro no Siscoserv" ou "Registrado no Siscoserv"
         If EL1->EL1_STTSIS == "1" .Or. EL1->EL1_STTSIS == "2"
            nValorLiquidado +=  EL1->EL1_VLEXT + EL1->EL1_VLCAMB
         EndIf
         EL1->(DbSkip())
      EndDo
   EndIf

   If nValorLiquidado > 0 .And. nValorLiquidado <> EJZ->EJZ_VL_MOE
      cStatusPag := "2"//Parcialmente liquidado
   Else
      If nTipo == 1 
        cStatusPag := "3"//liquidado
      ElseIf nTipo == 2
        cStatusPag := "1"//Aberto
      EndIf
   EndIf

   If EJZ->(RecLock("EJZ",.F.))
      EJZ->EJZ_STTPAG := cStatusPag
      EJZ->(MsUnlock())
   EndIf
   RS401STATPG(EJZ->EJZ_TPPROC,EJZ->EJZ_REGIST)

EndIf

RestOrd(aOrd,.T.)
*/
Return


/*
Programa   : RS401STATPG(cTipo,cProc)
Objetivo   : Atualiza status de pagamento da capa do Registro de Serviço (EJY) com base nos dados do detalhe (EJZ)
Parâmetros : cTipo - Tipo de Processo, cProc - Processo       
Retorno    : Nil
Autor      : Rafael Ramos Capuano
Data/Hora  : 04/10/2012 15:01 
Revisao    : 
*/

Function RS401STATPG(cTipo,cProc)
/*
Local aOrd      := SaveOrd({"EJZ","EJY"})
Local cMenorSta := ""
Local nCont     := 0
Local nCont2    := 0
       
If ValType(cTipo) <> "U" .And. ValType(cProc) <> "U"
   EJZ->(DbSetOrder(1))         
   If EJZ->(DbSeek(xFilial("EJZ") + AvKey(cTipo,"EJZ_TPPROC") + AvKey(cProc,"EJZ_REGIST")))       
      Do While EJZ->(!EOF()) .And. xFilial("EJZ") == EJZ->EJZ_FILIAL .And. AvKey(cTipo,"EJZ_TPPROC") == EJZ->EJZ_TPPROC .And. AvKey(cProc,"EJZ_REGIST") == EJZ->EJZ_REGIST    
         If Empty(cMenorSta) .Or. Val(cMenorSta) > Val(EJZ->EJZ_STTPAG)
            cMenorSta := EJZ->EJZ_STTPAG
         EndIf
         If EJZ->EJZ_STTPAG == "1"
            nCont++
         Else 
            nCont2++   
         EndIf
         EJZ->(DbSkip())
      EndDo        
   EndIf   
   EJY->(DbSetOrder(1))
   If EJY->(DbSeek(xFilial("EJY") + AvKey(cTipo,"EJY_TPPROC") + AvKey(cProc,"EJY_REGIST"))) 
      If EJY->(RecLock("EJY",.F.))
         If nCont > 0 .And. nCont2 > 0
            EJY->EJY_STTPAG := "2"
         Else
            EJY->EJY_STTPAG := cMenorSta
         EndIf
      EndIf
   EndIf   
EndIf 
RestOrd(aOrd,.T.)*/
Return

/*
Programa   : RS401VerLote()
Objetivo   : Verificar a existência do lote e também se está com status cancelado.    
Parâmetros : Campos para busca nas tabelas EL5 (Pagamentos Siscoserv) e EL8 (Lote Siscoserv), lDoc
Retorno    : Lógico
Autor      : Rafael Ramos Capuano
Data/Hora  : 18/10/2012 - 11:52 
Revisao    : 06/03/2013 - 14:35
*/ 

Function RS401VerLote(cTpProc, cProc, cSeqPag/*, lDoc*/)
Local aOrd := SaveOrd({"EL5","EL8"})
Local lRet := .T.
Default cTpProc := "", cProc := "", cSeqPag := ""
//Default lDoc := .F. //Verifica se a chamada veio do ESSRS402()
//RRC - 06/03/2013 - Atualiza variável private (não declarar a variável)
cCanLote := ""

EL5->(DbSetOrder(1))
EL8->(DbSetOrder(2))
If EL5->(DbSeek(xFilial("EL5") + AvKey(cTpProc,"EL5_TPPROC") + AvKey(cProc ,"EL5_REGIST") + AvKey(cSeqPag,"EL5_SEQPAG")))//filial+tipo+registro+seq.pagamento

   Do While EL5->(!EOF()) .And. xFilial("EL5")  == EL5->EL5_FILIAL .And.;
                                EL5->EL5_TPPROC == cTpProc         .And.;
                                EL5->EL5_REGIST == cProc           .And.;
                                EL5->EL5_SEQPAG == cSeqPag
      
      //RRC - 30/10/2013 - Caso o lote esteja cancelado ou tenha processado mas o mesmo não foi registrado (verifica nas validações dos campo EL2_RE e EL2_DI), poderá alterar o documento
      If EL8->(DbSeek(xFilial("EL8") + EL5->EL5_IDLOTE)) .And. EL8->EL8_STATUS <> "C" .And. EL8->EL8_STATUS <> "P"
         /*RRC - 06/03/2013 - Caso seja uma tentativa de estorno de liquidação, verifica se existe algum lote ainda não registrado para dar prosseguimento. 
         Status possíveis de lote não registrado: Não Enviado, Enviado ou Recebido. Neste caso, guardará o número do lote para que o mesmo seja cancelado.
         Se estiver acessando a rotina de documentos, logo não está tentando estornar uma liquidação, sendo assim, apenas verifica
         se existe algum lote gerado, caso haja, registrado ou não, não poderei alterar o documento*/
         //lRet := (!lDoc .And. EL8->EL8_STATUS <> "P")
         lRet := .F.
         cCanLote := EL8->EL8_IDLOTE
      EndIf
      
      EL5->(DbSkip())
   EndDo   

EndIf

RestOrd(aOrd,.T.)

Return lRet

Static Function RS400PgtReg(nTipo, nOpc, lHelp)
Local lRet := .T.
Local aOrdEEQ
Default lHelp := .T.
                                 
Do Case
   Case nTipo==1
        aOrdEEQ := SaveOrd({"EEQ"})
        If !EEQ->(DbSetOrder(1), DbSeek(xFilial("EEQ") + EJY->EJY_TPPROC+EJY->EJY_REGIST))
            If(lHelp, EasyHelp("Não há parcela de pagamento a ser exibida. Entre na opção '"+If(cTpReg=="A",STR0001, "Faturamentos")+" por Serviços' e tente novamente.","Atenção"), Nil)
            lRet := .F.
        EndIf
        RestOrd(aOrdEEQ)

   Case nTipo==2
        If Type("lRs401R")=="L" .And. lRs401R .And. (nOpc==3 .Or. nOpc==9)
            If(lHelp, EasyHelp("Esta operação não é permitida para a opção '"+If(cTpReg=="A",STR0001, "Faturamentos")+" dos Registros'. Entre na opção 'Pagamentos por Serviços' e tente novamente.","Atenação"), Nil)
            lRet := .F.
        EndIf
EndCase

Return lRet

/*
Programa   : RS401Legenda()
Objetivo   : Tela de legendas das cores de marcação.
Retorno    : 
Autor      : Fabio Satoru Yamamoto
Data       : 18/03/2013
*/
Function RS401Legenda()
Local aLegenda:= {}
                                              
   AAdd(aLegenda, {"BR_VERMELHO", 'Parcela não liquidado'})
   AAdd(aLegenda, {"BR_VERDE"   , 'Parcela liquidado'    })
   BrwLegenda("Parcelas", 'Legendas', aLegenda) //Legendas

Return