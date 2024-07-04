#INCLUDE "EEC.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "Average.ch"
#DEFINE ASPAS CHR(34)

/*
Função    : EI200INTITA()
Objetivos : Integração Carta Remessa Eletrônica ItaúBBA
Parametros: -
Retorno   : -
Autor     : Fabrício Romera 
Data      : 29/10/09
Revisão   : Guilherme Fernandes Pilan - GFP
Data      : 10/03/2014
Objetivos : Tratamento para envio de XML para Citibank
*/

Function EI200IntItau()
Local   aOpc[0], aRestrONA[0], aRestrOV[0], aRestrOE[0], aRestrOR[0], aRestrCF[0], aRestrRT[0] 
Local   aOrd:= SaveOrd({"EEC"})
Private aRotina := MenuDef("EI200INTIT")
Private aServ[0], aItens[0]
Private oUserParams := EASYUSERCFG():New()
Private lCitiBank := .F.
        
   //Preenche vetor de itens                                              
   aAdd(aItens, {"Não Enviados"                       , "ITN",  "N", , "AVG_NENV" , "AVG_NENV" })
   aAdd(aItens, {"Enviados(Aguardando Retorno...)"    , "ITE",  "E", , "AVG_IREEN", "AVG_IREEN"})   
   aAdd(aItens, {"Rejeitados"                         , "ITR",  "R", , "AVG_ICANC", "AVG_ICANC"})
   aAdd(aItens, {"Aprovados"                          , "ITA",  "A", , "AVG_IOK"  , "AVG_IOK"  })

   //Preenche vetor de serviços
   aAdd(aServ, {"Carta Remessa Eletrônica","EW9", "ITA",aItens , "", 2, "", ""})

   //Preenche vetores de restrições de itens nas opções
   aRestrONA := IDTodosItens(aServ, aItens)      //Novo Arquivo
   aAdd(aRestrONA, "RAIZ")                       //Novo Arquivo
   aAdd(aRestrONA, aServ[1][3])                  //Novo Arquivo
   aRestrCF   := IDTodosItens(aServ, aItens)     //Configurações
   aAdd(aRestrCF  , "RAIZ")                      //Configurações
   aAdd(aRestrCF , aServ[1][3])                  //Configurações
   aRestrOV := IDTodosItens(aServ, aItens)       //Visualizar
   aAdd(aRestrOE, aServ[1][3]+aItens[1][2])      //Enviar
   aAdd(aRestrOR, aServ[1][3]+aItens[2][2])      //Rejeitar
   aAdd(aRestrRT, aServ[1][3]+aItens[2][2])      //Retorno

   //Preenche vetor de opções
   aAdd(aOpc, {"Novo Arquivo" , "ONA",aRestrONA , {|| NovoArquivo(), AvAtuCentrInt("",aServ)}         , "","AVG_IADD" ,"AVG_IADD" })
   aAdd(aOpc, {"Visualizar"   , "OV" ,aRestrOV  , {|| VisualizarArquivo()}                            , "","AVG_IVIS" ,"AVG_IVIS" })
   aAdd(aOpc, {"Enviar"       , "OE" ,aRestrOE  , {|| EnviarArquivo(), AvAtuCentrInt("",aServ)}       , "","AVG_IENV" ,"AVG_IENV" })
   aAdd(aOpc, {"Rejeitar"     , "OR" ,aRestrOR  , {|| RejeitarArquivo(), AvAtuCentrInt("",aServ)}     , "","AVG_ICANC","AVG_ICANC"})  
   aAdd(aOpc, {"Configurações", "OCF",aRestrCF  , {|| EditConfigs(), AvAtuCentrInt("",aServ) }        , "","NCO"      ,"NCO"      })
   aAdd(aOpc, {"Retorno"      , "ORT",aRestrRT  , {|| Processa({||RetArquivo()},"Aprovando Remessa...","Aprovando Remessa...",.T.), AvAtuCentrInt("",aServ) }                      , "","OPEN"     ,"OPEN"     })

   //Preenche variaveis de títulos
   cDlgTit     := "Controle de Integração de Carta Remessa"
   cTreeTit    := "Carta Remessa ItaúBBA"
   cTreeTitOpc := "Ações"
   cRaizTit    := "Serviços"
   cRaizImg    := "AVG_IINT"
   cRaizTitOpc := "Opções"
   cRaizImgOpc := "AVG_IOPT"
   cPanelTit   := "Integração ItaúBBA"

   //Cria tela de controle de integração de carta remessa
   AvCentIntegracao(aServ,aOpc,cDlgTit,cTreeTit,cTreeTitOpc,cRaizTit, cRaizTitOpc,cPanelTit,,,cRaizImg, cRaizImgOpc,,,,,.T.)//FSY - 05/06/2013 - alterado para permitir valor 0 (zero) no campo “Qt. Originais” na tela "Seleção de Documentos" da rotina "Carta Remessa"

   RestOrd(aOrd)
Return           

/*
Função    : NovoArquivo()
Objetivos : Gerar um novo arquivo de carta remessa (.XML) com os processos de embarque selecionados.
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 03/11 - 16:00
*/                                      
Static Function NovoArquivo()
   Local cNomeArqXML := "" 
   Local aPreembSel[0], aXML[0], aDocs[0] , aInstr[0], aFrases[0]    
   Local i
   Local lAborta:= .T.
   
   Private lEnd:= .T.
   
   Begin Sequence            
                            
      //Gera nome do arquivo XML
      cNomeArqXML := GetNomeArq()
   
      //Seleciona Embarques e cria arquivo de trabalho
      Processa({|lEnd| aPreembSel := SelPreemb(@lEnd)}, "Novo Arquivo",, lAborta)

      //Verifica se algum item foi selecionado
      If Empty(aPreembSel)
         MsgInfo("Nenhum embarque selecionado.", "Aviso")
         Break
      End If

      //Seleciona documentos e instruções para cada remessa
      For i := 1 to Len(aPreembSel)

         //Documentos
         aAdd(aDocs ,SelecDocs(aPreembSel[i][1]))
         
         //DFS - 29/10/12 - Retirada validação para número de documentos originais, visto que, alguns despachantes podem enviar apenas cópias.
         //Verifica se algum documento foi selecionado
         /*If Empty(aDocs[i])
            MsgInfo("Nenhum documento selecionado para o embarque.", "Aviso")
            Break
         End If */

         //Insere os documentos informados na tabela de documentos da remessa
         InsereDocs(aDocs[i])

      Next         

      //Instruções
      If !SelecInstr(aPreembSel, @aInstr, @aFrases)    
         Break
      End If

      //Insere na tabela de instruções da remessa
      InsereInstr(aInstr, aFrases, Len(aPreembSel))

      //Insere informações no(s) arquivo(s)
      Processa({|| aXML := MontaArqXML(cNomeArqXML, aPreembSel, aDocs, aInstr, aFrases)},"Novo Arquivo")

      If Empty(aXML)
         Break
      End If

      //Insere registros selecionados na tabela de controle conforme o arquivo em que foram gerados
      InsereEW9(aPreembSel, aXML)

   End Sequence

Return

/*
Função    : EnviarArquivo()
Objetivos : Disponibilizar arquivo de carta remessa para envio pelo Internet Banking e alterar seu Status.
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 03/11 - 16:15
Obs.      :
Revisão   : WFS 29/07/07
*/
Static Function EnviarArquivo()
  Local cDirTemp := "", cDirServN := "", cDirServE := "", cDirServR := "", cNomeArq:= "", cNroControle := ""
  Local cDirTemp2:= ""
  Local nStatus := 0
  
  Begin Sequence

     cNomeArq := &(Alias()+"->EW9_FILE")

     If Empty(cNomeArq)
        MsgInfo("Nenhum item selecionado.", "Aviso")
        Break
     End If

     //Preenche diretórios para copiar arquivo
     cDirTemp  := GetTempPath()
     cDirServN := "\comex\itau\naoenviados\"                  
     cDirServE := "\comex\itau\enviados\"                  
     cDirServR := "\comex\itau\rejeitados\"                  

     cDirTemp2:= cGetFile('|', "Informe o diretório onde o arquivo será salvo", 0, cDirTemp, .T.,;
                          GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY, .F.)
     If !Empty(cDirTemp2)
        cDirTemp:= cDirTemp2

        //Copia arquivo do servidor para a pasta Temp ou pasta informada pelo usuário
        If !CopiaArq(cNomeArq, cDirServN, cDirTemp)
           Break
        End If  

        //Exibe tela de controle de envio e preenche status de envio 
        TelaEnvio(cNomeArq, cDirTemp, @nStatus, @cNroControle)
     Else
     
        nStatus:= 3
     EndIf

     //Altera o status de envio e
     //Muda a pasta do arquivo no servidor conforme situação de envio
     If nStatus = 1
        AlteraEW9(nStatus, cNroControle, cNomeArq)                        
        CopiaArq(cNomeArq, cDirServN, cDirServE)
     ElseIf nStatus = 2
        AlteraEW9(nStatus, cNroControle, cNomeArq)                             
        CopiaArq(cNomeArq, cDirServN, cDirServR)        
     EndIf

     //Exclui arquivo da pasta Temp              
     //ExcluiArquivo(cNomeArq, cDirTemp) nopado por WFS em 29/07/07

     If !(nStatus = 0 .Or. nStatus = 3)   
        ExcluiArquivo(cNomeArq, cDirServN)                              
        MsgInfo("Situação de envio atualizada.", "Controle de Envio de Arquivo Remessa")
     End If          
     
  End Sequence  

Return                   

/*
Função    : CopiaArqTemp()
Objetivos : Copiar arquivo de carta remessa do servidor para o diretorio temporario da maquina do usuario.
Parametros: 
Retorno   : cDirTemp: Caminho completo do diretorio temporario
Autor     : Fabrício Romera 
Data      : 04/11/2009
*/
Static Function CopiaArq(cFileName, cDirOrig, cDirDest)
  Local lRet := .T.
                                 
  //WFS 29/07/07
  If File(cDirDest + cFileName + ".xml")
     ExcluiArquivo(cDirDest + cFileName)
  EndIf

  //Copia Arquivo 
  If File(cDirOrig+AllTrim(cFileName)+".xml")
     copy file (cDirOrig+AllTrim(cFileName)+".xml") to (cDirDest+AllTrim(cFileName)+".xml")
  EndIf                                                                            
                
  If FError() > 0    
     MsgInfo("Não foi possivel copiar o arquivo para a pasta temporária.", "Aviso")
     lRet := .F.
  EndIf     

Return lRet

/*
Função    : TelaEnvio()
Objetivos : Exibir tela de processo de envio do arquivo remessa.
Parametros: cDirTemp: Caminho completo do diretorio temporario
Retorno   : nRadio: Situação do Envio(1-Enviado, 2-Rejeitado, 3-Cancelado)
Autor     : Fabrício Romera 
Data      : 04/11/2009
*/                                                              
Static Function TelaEnvio(cNomeArq, cDirTemp, nStatus, cNroControle)   
   Local oDlgEnv, oPanelEnv1, oPanelEnv2, oGetDirTemp, oSayDirTemp, oSayNControle, oGetNControle, oRad, oSayStatus
   Local cSayDirTemp, cSay2DirTemp, cSayNControle, cGetNControle, cSayStatus
   Local nRadio, nFase
   Local aOpc[0]
   Local lCancel := .T.
   
   Local bSetGet := {|u| If(PCount()>0, nRadio:= 1, nRadio)}
   Local bOk     := {|| lCancel:=.F., TelaEnvioOk(@cGetNControle, @oPanelEnv1, @oPanelEnv2, @nFase, @oDlgEnv)} 
   Local bCancel := {|| lCancel:=.T., oDlgEnv:End()}
                          
   //Conteudo dos Objetos da Tela
   cSayDirTemp   := "Copie os dados abaixo e informe-os no site ItaúBBA."
   cSay2DirTemp  := "Diretório do Arquivo Remessa:"
   cDirTemp      := cDirTemp + AllTrim(cNomeArq) + ".XML"
   cSayNControle := "Informe o Nº de Controle:"          
   cGetNControle := Space(13)                             
   cSayStatus    := "Informe a situação do envio:"
   nRadio        := 1 
   nFase         := 1                             
   
   //Opções do RadioMenu
   aAdd(aOpc, "Enviado")
   aAdd(aOpc, "Rejeitado")
   aAdd(aOpc, "Cancelar")                                                                                                
             
   //Cria Tela de Controle de Envio
   DEFINE MSDIALOG oDlgEnv TITLE "Envio de Remessa" FROM 1, 1;
                                                    TO 200, 400;
                                                    PIXEL
                                      
   //Primeira etapa do controle de envio                                      
   oPanelEnv1 := tPanel():New(0,0, "", oDlgEnv,,,,,,200,200) 
   
   @ 15, 10 SAY   oSayPesLiq    VAR cSayDirTemp    SIZE 180, 10 OF oPanelEnv1 PIXEL
   @ 25, 10 SAY   oSay2PesLiq   VAR cSay2DirTemp   SIZE 180, 10 OF oPanelEnv1 PIXEL
   @ 35, 10 MSGET oGetDirTemp   VAR cDirTemp       SIZE 180, 10 OF oPanelEnv1 PIXEL

   @ 50, 10 SAY   oSayNControle VAR cSayNControle  SIZE 180, 10 OF oPanelEnv1 PIXEL
   @ 60, 10 MSGET oGetNControle VAR cGetNControle  SIZE 180, 10  VALID ValNrControle(cGetNControle) OF oPanelEnv1 PIXEL

   
   
   //Segunda etapa do controle de envio      
   oPanelEnv2 := tPanel():New(,, "", oDlgEnv,,,,,,200,200)    

   @ 25, 10 SAY   oSayStatus    VAR cSayStatus     SIZE 180, 10 OF oPanelEnv2 PIXEL         
   oRad := TRadMenu():New( 35,10, aOpc, {|u| If(PCount()>0, nRadio:= u, nRadio)},oPanelEnv2,,,,,,,,90,09,,,,.T.)

   //Exibe primeira etapa de controle de envio     
   oPanelEnv1:Show()
   oPanelEnv2:Hide()

   ACTIVATE MSDIALOG oDlgEnv CENTERED ON INIT EnchoiceBar(oDlgEnv, bOk, bCancel)

   If lCancel
      nRadio = 3 //Cancelado      
   End If     

   //Devolve situação de envio
   nStatus := nRadio          

   //Devolve numero de controle      
   cNroControle := cGetNControle 

Return 
                      
/*
Função    : TelaEnvioOk()
Objetivos : Controlar evento click do botão Ok da EnchoiceBar
Parametros: cGetNControle, oPanelEnv1, oPanelEnv2, nFase, oDlgEnv
Retorno   : 
Autor     : Fabrício Romera 
Data      : 09/11/2009
*/                    
Static Function TelaEnvioOk(cGetNControle, oPanelEnv1, oPanelEnv2, nFase, oDlgEnv)        
   
   Begin Sequence                    
   
      If nFase = 1
         
         //Verifica se nº de controle foi informado
         If Empty(cGetNControle)
            MsgInfo("Nº de controle não informado.", "Aviso")
            Break
         End If
         
         //Exibe segunda etapa do controle de envio
         oPanelEnv1:Hide()
         oPanelEnv2:Show()                         
         nFase++                         
         
      Else             
                         
         oDlgEnv:End()
             
      End If
      
   End Sequence
   
Return         

/*
Função    : AlteraEW9()
Objetivos : Alterar Status de envio de arquivo.
Parametros: nStatus: Codigo do status selecionado pelo usuario(1-Enviado, 2-Rejeitado)
Retorno   : 
Autor     : Fabrício Romera 
Data      : 09/11/2009
*/
Static Function AlteraEW9(nStatus, cNroControle, cNomeArq)

   DbSelectArea("EW9")  
   DbSetOrder(1)
   DbSeek(xFilial("EW9")+cNomeArq)                         
   
   While EW9->(!EOF()) .And. EW9->EW9_FILIAL == xFilial("EW9") .And. EW9->EW9_FILE = cNomeArq           
                                   
      EW9->(RecLock("EW9",.F.))
                     
      If !Empty(cNroControle)
         EW9->EW9_NCONTROL  := cNroControle
      End If         
                     
      If nStatus = 1 //Enviado 
         EW9->EW9_STATUS := "E"
         EW9->EW9_USEREN := AllTrim(cUserName)
         EW9->EW9_DTENV  := dDataBase
         EW9->EW9_HRENV  := Time()               
      ElseIf nStatus = 2 //Rejeitado                                       
         EW9->EW9_STATUS := "R"
         EW9->EW9_USERRE := AllTrim(cUserName)
         EW9->EW9_DTREJ  := dDataBase
         EW9->EW9_HRREJ  := Time()
      ElseIf nStatus = 3 //Aprovados                                     
         EW9->EW9_STATUS := "A"
         EW9->EW9_USERAP := AllTrim(cUserName)
         EW9->EW9_DTAPR  := dDataBase
         EW9->EW9_HRAPR  := Time()                                
      End If                      

      EW9->(MsUnlock())

      EW9->(DbSkip())

   EndDo
         
Return

/*
Função    : ExcluiArquivo()
Objetivos : Exclui arquivo da pasta temporaria
Parametros: cNomeArq, cDirTemp
Retorno   : 
Autor     : Fabrício Romera 
Data      : 09/11/2009
*/    
Static Function ExcluiArquivo(cNomeArq, cDirTemp)
   FErase(AllTrim(cDirTemp) + AllTrim(cNomeArq) + ".XML")
Return
  

/*
Função    : RejeitarArquivo()
Objetivos : Altera status do arquivo selecionado para "Rejeitado".
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 03/11 - 16:15
Obs.      :
*/
Static Function RejeitarArquivo()    
   Local cNomeArq := "", cDirServE := "", cDirServR := ""
  
   //Verifica arquivo selecionado       
   cNomeArq := (Alias())->EW9_FILE//FSY - 05/06/2013 - alterado para permitir valor 0 (zero) no campo “Qt. Originais” na tela "Seleção de Documentos" da rotina "Carta Remessa"       
                                      
   If !Empty(cNomeArq)                
   
     //Preenche diretórios para copiar arquivo
     cDirServE := "\comex\itau\enviados\"                  
     cDirServR := "\comex\itau\rejeitados\"                  
     
     //Copia arquivo do servidor para a pasta Temp                                                   
     If !CopiaArq(cNomeArq, cDirServE, cDirServR)
        Break
     End If                                           
     ExcluiArquivo(cNomeArq, cDirServE)                              
     
      //Altera Status de Envio para Rejeitado             
      AlteraEW9(2,"",cNomeArq)                                                     
      
      MsgInfo("Situação de envio atualizada.", "Rejeição de Arquivo Remessa")
            
   End If 
          
Return                         

/*
Função    : GetNomeArq()
Objetivos : 
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 04/11/2009
*/
Static Function GetNomeArq()
   Local cNomeArq := ""
   Local nQtdeZero
   
   DbSelectArea("EW9")
   
   EW9->(DbGoTop())
   EW9->(DbSetOrder(1))
   EW9->(AvSeekLast(xFilial("EW9")))
      
   If !Empty(EW9->EW9_FILE) 
      cNomeArq  := EW9->EW9_FILE
      cNomeArq  := StrTrim(Val(cNomeArq)+1)
      nQtdeZero := 15 - Len(cNomeArq)
      cNomeArq  := Replicate("0", nQtdeZero) + cNomeArq
   Else   
      cNomeArq  := Replicate("0", 14) + "1"      
   End If
            
Return cNomeArq
             
/*
Função    : SelPreemb()
Objetivos : 
Parametros: 
Retorno   : -
Autor     : Fabrício Romera  
Revisão   : Allan Oliveira Monteiro
Data      : 18/02/2010 - 15:50
            WFS 27/07/07
            Adaptação do programa para chamada realizada através do menu.
*/
Static Function SelPreemb(lEnd)
   Local oDlg, oSel, oBut
   Local bOk    := {|| oDlg:End()}, bCancel := {|| lCancel := .T., oDlg:End()}, bMarcaTodos := {|u| MarcaTodos(cMarca)},;
         bEdita := {|| EditDadosCartaRemes(4)},;
         bVisual:= {|| EditDadosCartaRemes(2)}

   Local aPreembSel[0], aSelPos[4]
   Local lCancel := .F., lMarca := .T.
   Local aButtons:= {{"LBTIK"    , bMarcaTodos, "Marcar/ desmarcar todos"              , "Marcar"},;
                     {"EDIT"     , bEdita     , "Edição dos dados complementares"      , "Editar"},;
                     {"BMPVISUAL", bVisual    , "Visualização dos dados complementares", "Visualizar"}}
   
   Private cChave := "", cCondLoop := "", cCondIf := "", cSql := ""
   Private aCampos[0], aStruct[0], aPos[0]
   Private cMarca := GetMark()
   Private lInverte := .F.
   Private cOrder := 0
   
   Begin Sequence
      
      ProcRegua(4)//Tamanho da regua
                           
      //Preenche variaveis de filtro
      If !Pergunte("EW9001", .T., "Seleção de Embarques de Exportação")
         Break
      End If

      //WFS 26/06/10
      If Empty(MV_PAR01) .And. Empty(MV_PAR05)
         MsgInfo("Por favor informe um processo ou um período inicial para a seleção dos processos de embarque", "Aviso")
         Break
      EndIf

      If Empty(MV_PAR02) .And. Empty(MV_PAR06)
         MsgInfo("Por favor informe um processo ou um período final para a seleção dos processos de embarque", "Aviso")
         Break
      EndIf
                                                                                                         	
      //Arquivo de Trabalho                                             
      IncProc("Processando Embarques, Aguarde.")//Incrementa a regua      
      CriaWKEEC()
      IncProc("Processando Embarques, Aguarde.")//Incrementa a regua      
      GetWKEEC(@lEnd)          
      IncProc("Processando Embarques, Aguarde.")//Incrementa a regua      
              
      //Define aCampos                                                                      
      aCampos := {;                                                                           
                  {"WK_FLAG",,"",},;            
                  {"EEC_PREEMB",,AvSx3("EEC_PREEMB",AV_TITULO),AvSx3("EEC_PREEMB",AV_PICTURE)},;
                  {"EEC_PEDREF",,AvSx3("EEC_PEDREF",AV_TITULO),AvSx3("EEC_PEDREF",AV_PICTURE)},;
                  {"EEC_IMPODE",,AvSx3("EEC_IMPODE",AV_TITULO),AvSx3("EEC_IMPODE",AV_PICTURE)},;
                  {"EEC_IMLOJA",,AvSx3("EEC_IMLOJA",AV_TITULO),AvSx3("EEC_IMLOJA",AV_PICTURE)},;
                  {"EEC_STTDES",,AvSx3("EEC_STTDES",AV_TITULO),AvSx3("EEC_STTDES",AV_PICTURE)},;
                  {"EEC_DTPROC",,AvSx3("EEC_DTPROC",AV_TITULO),AvSx3("EEC_DTPROC",AV_PICTURE)},;
                  {"EEC_DTEMBA",,AvSx3("EEC_DTEMBA",AV_TITULO),AvSx3("EEC_DTEMBA",AV_PICTURE)};
                 }
                  
      //Cria Tela de Seleção de Processos
      DEFINE MSDIALOG oDlg TITLE "Seleção de Embarques de Exportação" FROM DLG_LIN_INI, DLG_COL_INI;
                                                                      TO DLG_LIN_FIM, DLG_COL_FIM;
                                                                      OF oMainWnd PIXEL          
                              
         //Pega Coordenadas da Tela                                                                 
         aPos := PosDlg(oDlg)                                                                 
                                                                 
         //Define Coordenadas do MsSelect
         aSelPos := {aPos[1],aPos[2],aPos[3], aPos[4]}                                                                                                           
                                                      		
         //Cria oSelect
         oSel := MsSelect():New("WK_EEC","WK_FLAG",, aCampos, @lInverte, @cMarca,aSelPos,,, oDlg)
         oSel:bAval := {|| MarcaEmb(cMarca) } //AOM - 23/02/10 
            
  
      ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bOk, bCancel,,aButtons)
      
      If lCancel 
         Break
      End If                   

      WK_EEC->(DbGoTop())                     
   
      //Verifica registros marcados e os adiciona em aPreembSel
      Do While WK_EEC->(!Eof())
         If !Empty(WK_EEC->WK_FLAG)
            aAdd(aPreembSel,{WK_EEC->EEC_PREEMB, WK_EEC->R_E_C_N_O_})                                    
         End If
         WK_EEC->(DbSkip())                                                                         
      EndDo
      
   End Sequence

   //Exclui arquivo de trabalho
   ExcluiWork("WK_EEC")
      
Return aPreembSel

/*
Função    : MarcaTodos()   
Objetivos : Marca/Desmarca todos os registros do MsSelect
Parametros: cMarca
Retorno   : -
Autor     : Fabrício Romera 
Revisão   : Allan Oliveira Monteiro
Data      : 24/02/2010 - 09:30
*/
Static Function MarcaTodos(cMarca)   
   Local nRec, lRet 
   Local cMsg := "", cMsgFinal := "" , cMsgBco := "" , cMsgBcoFim := ""
   Local aImport := {}
   
   Begin Sequence
   
      nRec := WK_EEC->(RecNo())
      cMarca  := IF(!Empty(WK_EEC->WK_FLAG),Space(2),cMarca)
      
      //Verifica dados dos processos para que seja validados e marcados para carta remessa
      WK_EEC->(dbGotop())
      While WK_EEC->(!Eof())
         lRet:= .T.
         If !Empty(cMsg := ValidEmb())
            cMsgFinal += ENTER + cMsg + Replicate(ENTER,2) 
            lRet:= .F.
         EndIf 
      
         If !Empty(cMsgBco := ValidBco(aImport)) 
            If cMsgBco <> "1"
               cMsgBcoFim += ENTER + cMsgBco + Replicate(ENTER,2)
            EndIf
            lRet:= .F.
         EndIf 
            
         If lRet
            WK_EEC->WK_FLAG := cMarca
         EndIf
      
         WK_EEC->(DbSkip())
      EndDo
   
      If !Empty(cMsgFinal)
         cMsgFinal := "Alguns embarques não puderam ser marcados, verifique a(s) mensagem(s) abaixo: " + Replicate(ENTER,2) + cMsgFinal
         EECView({{cMsgFinal, .T.}}, "Aviso")
      EndIf 
   
      If !Empty(cMsgBcoFim) 
         cMsgBcoFim := "Há importador(es) sem cadastro de banco cobrador, verifica a(s) mensagem(s) abaixo: " + Replicate(ENTER,2)+ cMsgBcoFim
         EECView({{cMsgBcoFim, .T.}}, "Aviso")
      EndIf
   
   End Sequence
   
   WK_EEC->(DbGoTo(nRec))     
      
Return

/*
Função    : SetVarBusca()   
Objetivos : Setar valores para as variaveis de filtro de busca na tabela EEC
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 30/10 - 15:50
Obs       : cChave    : Chave de busca no Seek.
            cOrder    : Ordem do indice utilizado para Seek.
            cCondLoop : Condição que sera utilizada no While de preenchimento da WK_EEC.
            cCondIf   : Condição que sera utilizada no IF de preenchimento da WK_EEC.

*/
Static Function SetVarBusca(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)   
   
   //Seta valor inicial das variaveis de busca
   cChave    := "xFilial('EEC')"   
   cCondLoop := "EEC->(!Eof()) .And. EEC->EEC_FILIAL == xFilial('EEC')"
   cCondIf := ".T."
   cOrder    := 1
                                            
   //Verifica se busca sera feita por Importador ou por Processo
   If !Empty(MV_PAR03) .And. !Empty(MV_PAR04)            
   
      //Verifica se foi informado valor inicial de Importador
      If !Empty(MV_PAR03)
         cOrder := 6
         cChave += "+'" + AllTrim(MV_PAR03) + "'"                    
      End If
      //Verifica se foi informado valor final de Importador
      If !Empty(MV_PAR04)
         cOrder := 6   
         cCondLoop += " .And. EEC->EEC_IMPORT <= MV_PAR04"      
      End If                                  
      //Verifica se foi informado valor inicial de Processo
      If !Empty(MV_PAR01)
         cCondIf +=  " .And. EEC->EEC_PREEMB >= MV_PAR01 "
      End If   
      //Verifica se foi informado valor final de Processo
      If !Empty(MV_PAR02)
         cCondIf +=  " .And. EEC->EEC_PREEMB <= MV_PAR02 "
      End If
      //WFS 27/07/10
      //Verifica se foi informado o período inicial do processo
      If !Empty(MV_PAR05)
         cCondIf +=  " .And. EEC->EEC_DTPROC >= MV_PAR05 "
      EndIf
      //Verifica se foi informado o período final do processo
      If !Empty(MV_PAR06)
         cCondIf +=  " .And. EEC->EEC_DTPROC <= MV_PAR06 "
      EndIf

   Else                                                    
   
      //Verifica se foi informado valor inicial de Processo
      If !Empty(MV_PAR01)
         cOrder := 1
         cChave += "+'" + AllTrim(MV_PAR01) + "'"                    
      End If
      //Verifica se foi informado valor final de Processo                    
      If !Empty(MV_PAR02)
         cOrder := 1   
         cCondLoop += " .And. EEC->EEC_PREEMB <= MV_PAR02"      
      End If                                  
      //Verifica se foi informado valor inicial de Importador
      If !Empty(MV_PAR03)
         cCondIf +=  " .And. EEC->EEC_IMPORT >= MV_PAR03 "
      End If   
      //Verifica se foi informado valor final de Importador      
      If !Empty(MV_PAR04)
         cCondIf +=  " .And. EEC->EEC_IMPORT <= MV_PAR04 "
      End If
      //WFS 27/07/10
      //Verifica se foi informado o período inicial do processo
      If !Empty(MV_PAR05)
         cCondIf +=  " .And. EEC->EEC_DTPROC >= MV_PAR05 "
      EndIf
      //Verifica se foi informado o período final do processo
      If !Empty(MV_PAR06)
         cCondIf +=  " .And. EEC->EEC_DTPROC <= MV_PAR06 "
      EndIf
      
   End If    
               
Return 

/*
Função    : CriaWKEEC()
Objetivos : 
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 03/11 
*/
Static Function CriaWKEEC()
      
   //Cria Work                      
   aStruct := {{"WK_FLAG", "C", 02, 0},;
               {"EEC_PREEMB",    AvSx3("EEC_PREEMB"   ,AV_TIPO),AvSx3("EEC_PREEMB"   ,AV_TAMANHO),AvSx3("EEC_PREEMB"   ,AV_DECIMAL)},;
               {"EEC_PEDREF",    AvSx3("EEC_PEDREF"   ,AV_TIPO),AvSx3("EEC_PEDREF"   ,AV_TAMANHO),AvSx3("EEC_PEDREF"   ,AV_DECIMAL)},;
               {"EEC_IMLOJA",    AvSx3("EEC_IMLOJA"   ,AV_TIPO),AvSx3("EEC_IMLOJA"   ,AV_TAMANHO),AvSx3("EEC_IMLOJA"   ,AV_DECIMAL)},;
               {"EEC_IMPODE",    AvSx3("EEC_IMPODE"   ,AV_TIPO),AvSx3("EEC_IMPODE"   ,AV_TAMANHO),AvSx3("EEC_IMPODE"   ,AV_DECIMAL)},;
               {"EEC_DTPROC",    AvSx3("EEC_DTPROC"   ,AV_TIPO),AvSx3("EEC_DTPROC"   ,AV_TAMANHO),AvSx3("EEC_DTPROC"   ,AV_DECIMAL)},;
               {"EEC_DTEMBA",    AvSx3("EEC_DTEMBA"   ,AV_TIPO),AvSx3("EEC_DTEMBA"   ,AV_TAMANHO),AvSx3("EEC_DTEMBA"   ,AV_DECIMAL)},;
               {"EEC_STTDES",    AvSx3("EEC_STTDES"   ,AV_TIPO),AvSx3("EEC_STTDES"   ,AV_TAMANHO),AvSx3("EEC_STTDES"   ,AV_DECIMAL)},;
               {"R_E_C_N_O_" , "N", 10, 0};
              }

   cNomArq := E_CriaTrab(,aStruct,"WK_EEC")

Return                                                                                

/*
Função    : GetWKEEC()
Objetivos : 
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 03/11 
*/
Static Function GetWKEEC(lEnd)

   #IFDEF TOP         
      
      //Select de acordo com o filtro feito pelo usuário             
      cSql := " SELECT "
      cSql += " ' ' as WK_FLAG,"                          //Campo p/ Marcação no Objeto Select
      cSql += " EEC.* "
      cSql += " FROM " + RetSqlName("EEC") + " EEC"
      cSql += " WHERE " 
      cSql += " EEC_FILIAL = '" + xFilial("EEC") + "'"
      If !Empty(MV_PAR01)
         cSql += " AND EEC_PREEMB >= '" + MV_PAR01 + "'"
      End If     
      If !Empty(MV_PAR02)
         cSql += " AND EEC_PREEMB <= '" + MV_PAR02 + "'"
      End If
      If !Empty(MV_PAR03)
         cSql += " AND EEC_IMPORT >= '" + MV_PAR03 + "'"
      End If                
      If !Empty(MV_PAR04)
         cSql += " AND EEC_IMPORT <= '" + MV_PAR04 + "'"
      End If                  
      //WFS 27/07/2010
      If !Empty(MV_PAR05)
         cSql += " AND EEC_DTPROC >= '" + DtoS(MV_PAR05) + "'"
      End If             
      If !Empty(MV_PAR06)
         cSql += " AND EEC_DTPROC <= '" + DtoS(MV_PAR06) + "'"
      End If             
                                                                     
      cSql += " AND EEC.EEC_DTEMBA <> '' AND EEC.D_E_L_E_T_ <> '*'

      cSql += " ORDER BY EEC_PREEMB "                                        
      
      cSql := ChangeQuery(cSql)      
                                                        
      //Cria view
      DbUseArea(.T., "TOPCONN", TCGENQRY(,,cSql), "WK_TEMP", .F., .T.)               
      TCSetField("WK_TEMP", "EEC_DTPROC", "D")
      TCSetField("WK_TEMP", "EEC_DTEMBA", "D")
                 
      //Transfere dados da View para a Work que sera utilizada
      Do While WK_TEMP->(!EOF())
         If lEnd
            MsgInfo("Operação abortada.", "Aviso")
            Exit
         EndIf

         WK_EEC->(DbAppend())         
         AvReplace("WK_TEMP","WK_EEC")
         WK_TEMP->(DbSkip())           
      EndDo       
      
      //Exclui WK_TEMP      
      WK_TEMP->(DbCloseArea())
      FErase("WK_TEMP"+GetDbExtension())         
      
    #ELSE
      //*DBF*     
      
      //Busca informações conforme parametros de filtro
      SetVarBusca(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06)
      
      EEC->(DbGoTop())
      EEC->(DbSetOrder(cOrder))
      //EEC->(DbSeek(xFilial("EEC")))
      EEC->(DbSeek(&cChave))
                  
      //Preenche work conforme parametros de filtro  
      Do While &(cCondLoop)
         If &(cCondIf)
            If lEnd
               MsgInfo("Operação abortada.", "Aviso")
               Exit
            EndIf
            
            WK_EEC->(DbAppend())
            AvReplace("EEC","WK_EEC") 
            WK_EEC->R_E_C_N_O_ := EEC->(RecNo())
         End If                    
         EEC->(DbSkip())
      EndDo
                      
   #ENDIF 
     
   WK_EEC->(DbGoTop())                                                
                                                             
Return                               

/*
Função    : ExcluiWork()
Objetivos : Excluir arquivo de trabalho utilizado na seleção de embarque.
Parametros: 
Retorno   : -
Autor     : Fabrício Romera
Data      : 03/11
*/
Static Function ExcluiWork(cWork)           

   //Exclui arquivo de trabalho       
   If Select(cWork) > 0 
      &(cWork)->(DbCloseArea())
     FErase(cWork+GetDbExtension())      
   End If         
   
Return

/*
Função    : InsereEW9()  
Objetivos : 
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 03/11 - 15:25
*/
Static Function InsereEW9(aPreembSel, aXML)  
   Local nEmbarque := 0, i, j
   
   //Insere Registros na tabela de controle EW9
   DbSelectArea("EW9")  
                                       
   //Varre vetor de arquivos e vai inserindo conforme a qtde de embarque em cada arquivo                                       
   For i := 1 to Len(aXML)                              
      For j := 1 to aXML[i][3] //De um até a qtde de embarques do arquivo aXML[i]
         
         nEmbarque++
    
         EW9->(RecLock("EW9",.T.))
         EW9->EW9_FILIAL := xFilial("EW9")
         EW9->EW9_FILE   := aXML[i][2]
         EW9->EW9_PREEMB := aPreembSel[nEmbarque][1]
         EW9->EW9_STATUS := "N"
         EW9->EW9_USER   := AllTrim(cUserName)
         EW9->EW9_DTGER  := dDataBase
         EW9->EW9_HRGER  := Time()
         
         EW9->(MsUnlock())                                           
      Next                                                     
   Next      

Return 

/*
Função    : MontaArqXML()
Objetivos : 
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 04/11 - 15:00
*/
Static Function MontaArqXML(cNomeArqXML, aPreembSel, aDocs, aInstr, aFrases)
   Local cXML  := "", cDir := "\comex\itau\naoenviados\"
   Local aWork[0]
   Local i
   Private cTipoRem := ""

   ProcRegua(Len(aPreembSel)+3)//Tamanho da regua
   
   IncProc("Criando Arquivo Remessa, Aguarde.")//Incrementa a regua
   
   //Cabeçalho
   cXML := GetCabecalho(aPreembSel)
         
   //Remessas(Processos de Embarque selecionados)
   For i := 1 to Len(aPreembSel)                     
                                   
      //Posiciona EEC no embarque corrente
      EEC->(DbGoTo(aPreembSel[i][2]))            
      //Posiciona EXL no embarque corrente
      EXL->(DbSetOrder(1))
      EXL->(DbSeek(xFilial("EXL")+aPreembSel[i][1]))
      
      If EXL->(FieldPos("EXL_BANCO")) > 0
         lCitibank := Alltrim(EXL->EXL_BANCO) == "2"
      EndIf
      
      cTipoRem := EXL->EXL_TPREM
            
      //<REMESSA>
      cXML += ENTER + Space(3) + "<REMESSA " + GetRemessa(aPreembSel[i]) + ">" + ENTER  

      //<EMISSOR>
      //cXML += GetEmissor(aPreembSel[i])  //Verificar
      //<COURIER>
      cXML += GetCourier(aPreembSel[i])    //OK
      //<IMPORTADOR>
      cXML += GetImport(aPreembSel[i])     //OK
      //<BANCO COBRADOR>
      cXML += GetBcoCobr(aPreembSel[i])    //OK
      //<CREDITO DE EXTERIOR>
      //cXML += GetCredExt(aPreembSel[i])  //Verificar
      //<FATURAS>
      cXML += GetFaturas(aPreembSel[i][1]) //OK
      //<SAQUES>
      cXML += GetSaques(aPreembSel[i][1])  //OK
      //<COMAGS>
      //cXML += GetComags(aPreembSel[i])   //Verificar
      //<CONTRATOS>
      //cXML += GetCntrts(aPreembSel[i])   //Não implementado
      //<CONTRATO_RES>
      //cXML += GetCntrtRE(aPreembSel[i])  //Não implementado
      //<RES>
      cXML += GetRES(aPreembSel[i][1])     //OK
      //<OPRS>
      //cXML += GetOprs(aPreembSel[i])     //Não implementado
      //<Documentos>
      cXML += GetDoctos(aDocs[i])          //OK
      //<Instruções>
      cXML += GetInstrs(aInstr[i])         //OK
      //<Frases>
      cXML += GetFrases(aFrases[i])        //OK
      
      //Informações Citibank
      If lCitiBank
         cXML += GetCitibank()
      EndIf
      
      cXML += ENTER + Space(3) + "</REMESSA>" + ENTER
      
      IncProc("Criando Arquivo Remessa, Aguarde.")
   Next     
   
   cXML += ENTER + "</REMESSAS>"                     
   
   //Cria arquivo(s) XML e preenche vetor de arquivos
   aXML := CriaArqXML(cXML, cNomeArqXML, Len(aPreembSel), cDir)   
   IncProc("Criando Arquivo Remessa, Aguarde.")
           
   //Exclui Arquivos Temporarios
   For i:= 1 to Len(aWork)
      ExcluiWork("WK_"+aWork[i][1])
   Next      
   
   IncProc("Criando Arquivo Remessa, Aguarde.")   
                                                   
Return aXML

Static Function GetCitiBank()
Local cXML := ""

	cXML += "<TRANSPORTADOR>"  + EXL->EXL_NCOMP  + "</TRANSPORTADOR>" + ENTER
	cXML += "<NAVIO>"  + EXL->EXL_NNAVIO  + "</NAVIO>" + ENTER
	cXML += "<DESTINO>"  + EXL->EXL_PDEST  + "</DESTINO>" + ENTER
    
	

Return cXML

/*
Função    : CriaArqXML()
Objetivos : Criar fisicamente o(s) arquivo(s) .XML com as remessas.
Parametros: cXML: conteudo do arquivo .XML, cNomeArq: nome do arquivo fisico, cQtdeRemessas: quantidade de 
            remessas, cDir: diretorio de criação do arquivo.
Retorno   : 
Autor     : Fabrício Romera 
Data      : 
*/             
Static Function CriaArqXML(cXML, cNomeArq, cQtdeRemessas, cDir)
   Local aXML[0]
   Local nCont   := 0, i                            
   Local nTamMax := 511000
   
   //Adiciona arquivo principal no array de arquivos   
   aAdd(aXML, {cXML, cNomeArq, cQtdeRemessas})                
   aAdd(aXML, {"","",0})                                            

   //Verifica se arquivo ultrapassou o limite de 512KB
   If Len(cXML) < nTamMax         
      //Se não ultrapassou cria o arquivo fisicamente
      nFile := EasyCreateFile(cDir + cNomeArq + ".XML", FC_NORMAL)          
      fWrite(nFile, cXML, nTamMax)   
      fClose(nFile)      
   Else                                    
   
      //Gera nome fisico para o arquivo de quebra
      cNomeArq  := StrTrim(Val(cNomeArq)+1)
      nQtdeZero := 15 - Len(cNomeArq)
      cNomeArq  := Replicate("0", nQtdeZero) + cNomeArq
      aXML[2][2] := cNomeArq
                                            
      nCont := 2                     
                                         
      //Quebra Arquivo Remessa
      Do While Len(aXML[nCont-1][1]) > nTamMax         
           
         //Quebra arquivo .XML gerando um novo arquivo                 
         QuebraStr(@aXML[nCont-1][1], @aXML[nCont][1])                               
         
         //Atualiza qtde do vetor de arquivos        
         aXML[nCont][3]++
         aXML[nCont-1][3]--
                                                                                    
         //Verifica se arquivo de quebra também ultrapassou tamanho máximo
         If Len(aXML[nCont][1]) > nTamMax .And. Len(aXML[nCont-1][1]) < nTamMax
            nCont++                  
            aAdd(aXML, {"","",0})
            //Gera nome fisico do novo arquivo           
            cNomeArq  := StrTrim(Val(cNomeArq)+1)
            nQtdeZero := 15 - Len(cNomeArq)
            cNomeArq  := Replicate("0", nQtdeZero) + cNomeArq
            aXML[nCont][2] := cNomeArq                                            
         End If                           
      EndDo                 
      
      //Cria arquivos fisicamente
      For i:= 1 to Len(aXML)
         nFile := EasyCreateFile(cDir + aXML[i][2] + ".XML", FC_NORMAL)          
         fWrite(nFile, aXML[i][1], nTamMax)   
         fClose(nFile)
      Next         
   End If
   
   If fError() = 0 
      MsgInfo("Arquivo gerado com sucesso!", "Novo Arquivo")            
   Else
      aXML := {}
      MsgInfo("Ocorreu um erro na geração do arquivo.", "Novo Arquivo")
   End If

Return aXML

/*
Função    : QuebraStr()
Objetivos : Função que ira quebrar o arquivo XML colocando a ultima remessa deste no arquivo XML de quebra
Parametros: cXML: conteudo do arquivo, cXMLQuebra: conteudo do arquivo de quebra.  
Retorno   : -
Autor     : Fabrício Romera 
Data      : 11/11 - 11:20
*/             
Static Function QuebraStr(cXML, cXMLQuebra)
   Local cAux := "", cQtdXML := ""
   Local nPosQtd := 0, nCaracQtd := 0
   
   //Extrai ultima remessa do arquivo .XML
   cAux := Right(cXML, Len(cXML) - RAT("<REMESSA", cXML)+1)
   cAux := Left(cAux, RAT("</REMESSAS>", cAux)-1)          
   
   //Exclui ultima remessa do arquivo .XML
   cXML := Left(cXML, RAT("<REMESSA", cXML)-1)          
   cXML += ENTER + "</REMESSAS>"
   
   //Prepara arquivo de quebra
   If Empty(cXMLQuebra)                                                                                          
      //Se for um novo arquivo de quebra adiciona cabeçalho
//      cXMLQuebra := ""//GetCabecalho()
//      cXMLQuebra := "<?xml version="+ASPAS+"1.0"+ASPAS+"?>" + ENTER
//      cXMLQuebra += "<REMESSAS"
//      cXMLQuebra += ENTER + "   QTDE =" + "          >"
      cXMLQuebra := "<?xml version="+ASPAS+"1.0"+ASPAS+"?>"+ENTER
      cXMLQuebra += "<REMESSAS"
      cXMLQuebra += ENTER + "   QTDE =" + ASPAS + Space(3) + ">"
   Else
      //Se o arquivo de quebra já existir retira tag de fim de arquivo      
      cXMLQuebra := Left(cXMLQuebra, RAT("</REMESSAS>", cXMLQuebra))                
   End If                     
                                          
   //Adiciona remessa extraida ao arquivo de quebra
   cXMLQuebra += cAux
   cXMLQuebra += ENTER + "</REMESSAS>"   
   
   //Altera Quantidades
   //Pega e altera qtde de remessas do arquivo XML
   nPosQtd := AT("QTDE =", cXML) + 7                 //Posição em que está a informação de Quantidade
   nCaracQtd := AT("<REMESSA ", cXML) - nPosQtd      //Numero de caracteres que a informação de Quantidade Ocupa
   cQtdXML := Substr(cXML, nPosQtd, nCaracQtd)       //Quantidade de Remessas
   cQtdXML := StrTrim(Val(cQtdXML)-1)                //Subtrai a remessa que passou para o arquivo de quebra

   //Substitui no arquivo                    
   cQtdXML := cQtdXML+ASPAS+">"+ENTER+SPACE(3)
   cXML    := Stuff(cXML, nPosQtd, nCaracQtd, cQtdXML)

   //Pega qtde de remessas do arquivo de quebra
   nPosQtd := AT("QTDE =", cXMLQuebra) + 7           //Posição em que está a informação de Quantidade
   nCaracQtd := AT("<REMESSA ",cXMLQuebra) - nPosQtd //Numero de caracteres que a informação de Quantidade Ocupa
   cQtdXML := Substr(cXMLQuebra, nPosQtd, nCaracQtd) //Quantidade de Remessas
   cQtdXML := StrTrim(Val(cQtdXML)+1)                //Soma Hum
      
   //Substitui no arquivo de quebra                    
   cQtdXML    := cQtdXML+ASPAS+">"+ENTER+SPACE(3) //"QTDE">   
   cXMLQuebra := Stuff(cXMLQuebra, nPosQtd, nCaracQtd, cQtdXML)  
                                                        
Return

/*
Função    : -
Objetivos : Funções que retornam as informações necessárias para montagem da string com o conteudo do arquivo .XML
Parametros: 
Retorno   : -
Autor     : Fabrício Romera 
Data      : 04/11
*/

Static Function GetCabecalho(aPreembSel)        
   Local cInfo := ""
   
   cInfo := "<?xml version="+ASPAS+"1.0"+ASPAS+" encoding= "+ ASPAS +"ISO-8859-1"+ASPAS+"?>"+ENTER
   cInfo += "<REMESSAS"
   cInfo += ENTER + "   QTDE =" + ASPAS + StrTrim(Len(aPreembSel)) + ASPAS + ">"

Return cInfo

Static Function GetRemessa(aPreembSel)
   Local cInfo := ""

   cInfo += ENTER + "      REFERENCIA          = " + ASPAS + Formata(EEC->EEC_PREEMB, "C")     + ASPAS
   cInfo += ENTER + "      CNPJ_CPF            = " + ASPAS + GetCNPJ()                         + ASPAS 
   cInfo += ENTER + "      COD_BANCO           = " + ASPAS + "184"                             + ASPAS //ItaúBBA
   cInfo += ENTER + "      COD_PRACA           = " + ASPAS + Formata(EXL->EXL_PRACA,  "C")     + ASPAS 
   cInfo += ENTER + "      TP_REMESSA          = " + ASPAS + Formata(cTipoRem,  "C")           + ASPAS 
   cInfo += ENTER + "      TP_VENCIMENTO       = " + ASPAS + Formata(EXL->EXL_TPVENC, "C")     + ASPAS 
   cInfo += ENTER + "      COD_MOEDA           = " + ASPAS + GetMoeda(EEC->EEC_MOEDA)          + ASPAS 
   cInfo += ENTER + "      VLR_NEGOCIADO       = " + ASPAS + Formata(EEC->EEC_TOTPED, "F")     + ASPAS
   
   If EXL->EXL_TPVENC == "P"  
      cInfo += ENTER + "      VLR_JUROS           = " + ASPAS + If(!Empty(EXL->EXL_INSTJR) .And. At("%", EXL->EXL_INSTJR) == 0, Formata(StrTran(EXL->EXL_INSTJR, ",", "."),"C"), "0")   + ASPAS //DFS - 29/10/12 - Trocar virgula por ponto
   EndIf
   
   cInfo += ENTER + "      DT_EMBARQUE         = " + ASPAS + Formata(EEC->EEC_DTEMBA, "D")     + ASPAS

   If lCitiBank
      cInfo += ENTER + "      MERCADORIA          = " + ASPAS + EXL->EXL_DESCM                  + ASPAS 
      cInfo += ENTER + "      BL			          = " + ASPAS + EEC->EEC_NRCONH                 + ASPAS   // GFP - 10/03/2014
   Endif

   cInfo += ENTER + "      INSTRUIR_PGTO_COMAG = " + ASPAS + "N"                               + ASPAS //*** Verificar
   cInfo += ENTER + "      DESPESAS_BRASIL     = " + ASPAS + Formata(EXL->EXL_DESPBR, "C")     + ASPAS 
   cInfo += ENTER + "      DESPESAS_EXTERIOR   = " + ASPAS + Formata(EXL->EXL_DESPEX, "C")     + ASPAS 
   cInfo += ENTER + "      OFFSHORE            = " + ASPAS + "N"                               + ASPAS //*** Verificar

Return cInfo
/*                                                                  
Static Function GetEmissor()
   Local cInfo := ""

   cInfo += ENTER + "      <EMISSOR "           
   cInfo += ENTER + Space(9) + "NOME     = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(9) + "ENDERECO = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(9) + "CIDADE   = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(9) + "COD_PAIS = " + ASPAS + "" + ASPAS + ">"        
   cInfo += ENTER + "      </EMISSOR>"       + ENTER        
    
Return cInfo                                                    
*/
Static Function GetCourier() 
   Local cInfo := ""

   cInfo += ENTER + "      <COURIER" 
   cInfo += ENTER + Space(9) + "CODIGO        = " + ASPAS + Formata(EXL->EXL_CODCOU, "C") + ASPAS 
   cInfo += ENTER + Space(9) + "NOME          = " + ASPAS + Formata(EXL->EXL_NOMCOU, "C") + ASPAS 
   cInfo += ENTER + Space(9) + "NRO_CONTA     = " + ASPAS + Formata(EXL->EXL_CONCOU, "C") + ASPAS 
   cInfo += ENTER + Space(9) + "COD_SLIP      = " + ASPAS + Formata(EXL->EXL_SLIPCO, "C") + ASPAS 
   cInfo += ENTER + Space(9) + "DT_ENVIO_SLIP = " + ASPAS + Formata(EXL->EXL_SLIPDT, "D") + ASPAS + ">"
   cInfo += ENTER + "      </COURIER>"            + ENTER      
   
Return cInfo

Static Function GetImport()         
   Local cInfo := ""              
                                                                   
   //Busca Informações Sobre Importador   
   SA1->(DbSetOrder(1))
   SA1->(DbSeek(xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))                               
 
   cInfo += ENTER + "      <IMPORTADOR" 
   cInfo += ENTER + Space(9) + "NOME        = " + ASPAS + Formata(SA1->A1_NOME, "C")  + ASPAS
   cInfo += ENTER + Space(9) + "ENDERECO    = " + ASPAS + Formata(SA1->A1_END, "C")   + ASPAS
   cInfo += ENTER + Space(9) + "COMPLEMENTO = " + ASPAS + ""                          + ASPAS //*** VERIFICAR
   cInfo += ENTER + Space(9) + "CIDADE      = " + ASPAS + Formata(SA1->A1_MUN, "C")   + ASPAS
   cInfo += ENTER + Space(9) + "COD_PAIS    = " + ASPAS + GetPais(SA1->A1_PAIS)       + ASPAS + ">"
   cInfo += ENTER + "      </IMPORTADOR>"       + ENTER   
   
Return cInfo

Static Function GetBcoCobr() //Enviar apenas em caso de COB - Cobrança de Exportação
Local cInfo := ""
   
Begin Sequence   
   
   //AOM - 14/02/2012 - Caso Tipo de Remessa seja "Remessa Direta" nao envia o banco Cobrador
   If cTipoRem == "RDM"
      Break
   EndIf
   
   EWR->(DbSetOrder(2))
   EWR->(DbSeek(xFilial("EWR") + EEC->(EEC_IMPORT+EEC_IMLOJA) + EXL->EXL_CODBCO))
  
   cInfo += ENTER + "      <BCO_COBRADOR" 
   
 //cInfo += ENTER + Space(9) + "CODIGO        = " + ASPAS + EXJ->EXJ_COBCOD          + ASPAS
   cInfo += ENTER + Space(9) + "CODIGO        = " + ASPAS + EWR->EWR_COBCOD          + ASPAS

   If !Empty(EWR->EWR_COBDEP)//(EXJ->EXJ_COBDEP)
    //cInfo += ENTER + Space(9) + "DEPTO_ENVIO   = " + ASPAS + EXJ->EXJ_COBDEP       + ASPAS
      cInfo += ENTER + Space(9) + "DEPTO_ENVIO   = " + ASPAS + EWR->EWR_COBDEP       + ASPAS
   EndIf
 //cInfo += ENTER + Space(9) + "NOME          = " + ASPAS + EXJ->EXJ_BCOCOB          + ASPAS 
 //cInfo += ENTER + Space(9) + "ENDERECO      = " + ASPAS + EXJ->EXJ_COBEND          + ASPAS
 //cInfo += ENTER + Space(9) + "CIDADE        = " + ASPAS + EXJ->EXJ_COBCID          + ASPAS
 //cInfo += ENTER + Space(9) + "COD_PAIS      = " + ASPAS + GetPais(EXJ->EXJ_COBPAI) + ASPAS + ">" 
   cInfo += ENTER + Space(9) + "NOME          = " + ASPAS + EWR->EWR_BCOCOB          + ASPAS
   cInfo += ENTER + Space(9) + "ENDERECO      = " + ASPAS + EWR->EWR_COBEND          + ASPAS
   cInfo += ENTER + Space(9) + "CIDADE        = " + ASPAS + EWR->EWR_COBCID          + ASPAS
   cInfo += ENTER + Space(9) + "COD_PAIS      = " + ASPAS + GetPais(EWR->EWR_COBPAI) + ASPAS + ">"  
   cInfo += ENTER + "      </BCO_COBRADOR>"       + ENTER      

End Sequence

Return cInfo

/*
Static Function GetCredExt() //Não utilizado na Braskem
   Local cInfo := ""                                        
         
   cInfo += ENTER + Space(6) + "<CREDITO_EXTERIOR" 
   cInfo += ENTER + Space(9) + "VLR_CREDITO   = " + ASPAS + "" + ASPAS + ">"   
   cInfo += GetBcoCred()
   cInfo += GetBcoInte()
   cInfo += ENTER + Space(6) + "</CREDITO_EXTERIOR>"     + ENTER                                                                                                                                   
   
Return cInfo                        

Static Function GetBcoCred(cTipo) //Não utilizado na Braskem
   Local cInfo := ""                       
                           
   cInfo += ENTER + Space(9) + "<BCO_CREDITO"
   cInfo += ENTER + Space(12) + "CODIGO        = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "NOME          = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "CIDADE        = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "COD_PAIS      = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "SWIFT         = " + ASPAS + "" + ASPAS      
   cInfo += ENTER + Space(12) + "NRO_CONTA     = " + ASPAS + "" + ASPAS + ">"        
   cInfo += ENTER + Space(9) + "</BCO_CREDITO>"    + ENTER    

Return cInfo                  

Static Function GetBcoInte() //Não utilizado na Braskem 
   Local cInfo := ""                                        
                           
   cInfo += ENTER + Space(9) + "<BCO_INTERMEDIARIO"
   cInfo += ENTER + Space(12) + "CODIGO        = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "NOME          = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "CIDADE        = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "COD_PAIS      = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "SWIFT         = " + ASPAS + "" + ASPAS      
   cInfo += ENTER + Space(12) + "NRO_CONTA     = " + ASPAS + "" + ASPAS + ">"        
   cInfo += ENTER + Space(9) + "</BCO_INTERMEDIARIO>" 
   
Return cInfo
*/
//Monta Tag de Faturas
Static Function GetFaturas(cPreemb)
   Local cInfo := ""
   Local aFaturas[0] //aFaturas: 1-Sequencia, 2-nNumero, 3-cTipo, 4-nValor, 5-dData, 6-nPrazo, 7-dVencimento}
   Local nQtde := 0  //Qtde de Faturas
   Local i
   
   //Busca informações de faturas
   If Select("EXP") > 0 .And. DbSeek(xFilial("EXP")+cPreemb)
   
      //Preenche array com informações das faturas
      Do While EXP->(!EOF()) .And. EXP->EXP_FILIAL == xFilial("EXP") .And. EXP->EXP_PREEMB = cPreemb
         nQtde++
         aAdd(aFaturas, ;
             {nQtde,;            //Sequencia
              EXP->EXP_NRINVO,;  //Numero
              "P",;              //Tipo
              EXP->EXP_TOTPED,;  //Valor
              EXP->EXP_DTINVO,;  //Data
              If(EXL->EXL_TPVENC == "V", 0, EXP->EXP_PRAZO),;   //Prazo //DFS - 29/10/12 - Validação no calculo do vencimento
              If(EXL->EXL_TPVENC == "V" .And. !Empty(EEC->EEC_DTEMBA), EEC->EEC_DTEMBA, EXP->EXP_DTINVO+EXP->EXP_PRAZO); //Vencimento
             })
          EXP->(DbSkip())   
      EndDo
   Else
      EEQ->(DbSetOrder(1))
      EEQ->(DbSeek(xFilial()+cPreemb))
      While EEQ->(!Eof() .And. EEQ_FILIAL+EEQ_PREEMB == xFilial()+cPreemb)
         If EEQ->EEQ_EVENT == "101"
            nQtde++
            aAdd(aFaturas, ;
                {nQtde,;            //Sequencia
                 EEQ->EEQ_NRINVO,;  //Numero
                 "P",;              //Tipo
                 EEQ->EEQ_VL,;  //Valor
                 EEC->EEC_DTEMBA,;  //Data
                 If(EXL->EXL_TPVENC == "V", 0, EEQ->EEQ_VCT - EEC->EEC_DTEMBA),;   //Prazo //DFS - 29/10/12 - Validação no calculo do vencimento
                 If(EXL->EXL_TPVENC == "V", EEC->EEC_DTEMBA, EEQ->EEQ_VCT); //Vencimento
                })         
            EndIf
         EEQ->(DbSkip())
      EndDo
   EndIf
                      
   //Cria TAG de informações de faturas
   cInfo += ENTER + Space(6) + "<FATURAS" 
   cInfo += ENTER + Space(9) + "QTDE          = " + ASPAS + StrTrim(nQtde)                + ASPAS + ""
   cInfo += ENTER + Space(9) + "TENOR         = " + ASPAS + Formata(EXL->EXL_TENOR, "C")  + ASPAS + ">"   
                                         
   //Cria TAG para cada fatura
   For i:= 1 to nQtde
      cInfo += ENTER + GetFatura(aFaturas[i])
   Next
   
   cInfo += ENTER + Space(6) + "</FATURAS>" + ENTER
   
Return cInfo

Static Function GetFatura(aFaturas)                                 
   Local cInfo := ""                                        
   
   cInfo += ENTER + Space(09) + "<FATURA"
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + Formata(aFaturas[1], "N", 3) + ASPAS
   cInfo += ENTER + Space(12) + "NUMERO        = " + ASPAS + Formata(aFaturas[2], "C") + ASPAS
   cInfo += ENTER + Space(12) + "TP_FATURA     = " + ASPAS + Formata(aFaturas[3], "C") + ASPAS
   cInfo += ENTER + Space(12) + "VLR_FATURA    = " + ASPAS + Formata(aFaturas[4], "F") + ASPAS
   cInfo += ENTER + Space(12) + "DT_BASE       = " + ASPAS + Formata(aFaturas[5], "D") + ASPAS      
   cInfo += ENTER + Space(12) + "PRAZO         = " + ASPAS + Formata(aFaturas[6], "N") + ASPAS   
   cInfo += ENTER + Space(12) + "DT_VENCIMENTO = " + ASPAS + Formata(aFaturas[7], "D") + ASPAS + ">"     
   cInfo += ENTER + Space(09) + "</FATURA>"                                             
      
Return cInfo

Static Function GetSaques(cPreemb)                                 
   Local cInfo := ""                                        
   Local aSaques[0] //aSaques: 1-Sequencia, 2-cTipo, 3-nValor, 4-dData, 5-nPrazo, 6-dVencimento
   Local nQtde := 0  //Qtde de Saques
   Local i
   Local nRegEEQ := 0
   
   //Busca informações de faturas
   DbSelectArea("EEQ")
   DbSetOrder(1)
   DbSeek(xFilial("EEQ")+cPreemb)
   
   //Preenche array com informações das faturas
   Do While EEQ->(!EOF()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And. EEQ->EEQ_PREEMB = cPreemb
      If EEQ->EEQ_EVENT = "101"
         nQtde++
         aAdd(aSaques, ;
             {nQtde,;                        //Sequencia
              "P",;                          //Tipo
              EEQ->EEQ_VL,;                  //Valor
              EEC->EEC_DTEMBA,;              //Data
              If(EXL->EXL_TPVENC <> "V" .And. !Empty(EEC->EEC_DTEMBA) .And. !Empty(EEQ->EEQ_VCT),EEQ->EEQ_VCT-EEC->EEC_DTEMBA,0),; //Prazo   //DFS - 10/10/12 - Tratamento para que o prazo e o vencimento sejam calculados corretamente.
              If(EXL->EXL_TPVENC == "V", EEC->EEC_DTEMBA, EEQ->EEQ_VCT);                  //Vencimento
             })
         nRegEEQ := EEQ->(Recno())
       EndIf                                    
       EEQ->(DbSkip())   
   EndDo 
   
   If !Empty(EXL->EXL_INSTJR) .And. At("%", EXL->EXL_INSTJR) == 0 .And. nRegEEQ > 0
   		 EEQ->(DbGoTo(nRegEEQ))
         nQtde++
         aAdd(aSaques, ;
             {nQtde,;                                         //Sequencia
              "J",;                                           //Tipo
              Val(StrTran(EXL->EXL_INSTJR,",",".")),;         //Valor //DFS - 29/10/12 - Trocar possivel virgula por ponto. 
              EEC->EEC_DTEMBA,;                               //Data
              If(EXL->EXL_TPVENC <> "V" .And. !Empty(EEC->EEC_DTEMBA) .And. !Empty(EEQ->EEQ_VCT),EEQ->EEQ_VCT-EEC->EEC_DTEMBA,0),; //Prazo   //DFS - 10/10/12 - Tratamento para que o prazo e o vencimento sejam calculados corretamente.
              If(EXL->EXL_TPVENC == "V", EEC->EEC_DTEMBA, EEQ->EEQ_VCT);                  //Vencimento
             })
   EndIf

   cInfo += ENTER +  "      <SAQUES"
   cInfo += ENTER + Space(9) + "QTDE          = " + ASPAS + StrTrim(nQtde) + ASPAS + ">"

   //Cria TAG para cada saque
   For i:= 1 to nQtde
      cInfo += ENTER + GetSaque(aSaques[i])
   Next

   cInfo += ENTER + "      </SAQUES>"             + ENTER      
   
Return cInfo

Static Function GetSaque(aSaques)                                  
   Local cInfo := ""                                        

   cInfo += ENTER + "         <SAQUE"   
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + Formata(aSaques[1], "N", 3) + ASPAS
   cInfo += ENTER + Space(12) + "TP_SAQUE      = " + ASPAS + Formata(aSaques[2], "C") + ASPAS
   cInfo += ENTER + Space(12) + "VLR_SAQUE     = " + ASPAS + Formata(aSaques[3], "F") + ASPAS
   cInfo += ENTER + Space(12) + "DT_BASE       = " + ASPAS + Formata(aSaques[4], "D") + ASPAS
   cInfo += ENTER + Space(12) + "PRAZO         = " + ASPAS + Formata(aSaques[5], "N") + ASPAS
   cInfo += ENTER + Space(12) + "DT_VENCIMENTO = " + ASPAS + Formata(aSaques[6], "D") + ASPAS + ">"
   cInfo += ENTER + "         </SAQUE>"
      
Return cInfo
/*
Static Function GetComags()                                 
   Local cInfo := ""     

   cInfo += ENTER + Space(6)  + "<COMAGS"   
   cInfo += ENTER + Space(9)  + "QTDE          = " + ASPAS + "" + ASPAS + ">"     
   
   cInfo += ENTER + Space(9)  + "<COMAG"
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "TP_SAQUE      = " + ASPAS + "" + ASPAS   
   cInfo += ENTER + Space(12) + "TP_COMAG      = " + ASPAS + "" + ASPAS   
   cInfo += ENTER + Space(12) + "VLR_COMAG     = " + ASPAS + "" + ASPAS + ">"
   cInfo += GetAgente()
   cInfo += GetBcoCred()
   cInfo += GetBcoInte()
   cInfo += ENTER + Space(9) + "</COMAG>"          + ENTER                                         
   cInfo += ENTER + Space(6) + "</COMAGS>"         + ENTER                                         
                                                                 
Return cInfo

Static Function GetAgente()                                 
   Local cInfo := ""                                        
   
   cInfo += ENTER + Space(12) + "<AGENTE"   
   cInfo += ENTER + Space(15) + "NOME          = " + ASPAS + "" + ASPAS   
   cInfo += ENTER + Space(15) + "ENDERECO      = " + ASPAS + "" + ASPAS      
   cInfo += ENTER + Space(15) + "COMPLEMENTO   = " + ASPAS + "" + ASPAS         
   cInfo += ENTER + Space(15) + "CIDADE        = " + ASPAS + "" + ASPAS         
   cInfo += ENTER + Space(15) + "COD_PAIS      = " + ASPAS + "" + ASPAS + ">"           
   cInfo += ENTER + Space(12)  + "</AGENTE>"        + ENTER                                                                     
   
Return cInfo                                                         

Static Function GetCntrts()
   Local cInfo := ""                                        
                         
   cInfo += ENTER + Space(6) + "<CONTRATOS"
   cInfo += ENTER + Space(9) + "QTDE          = " + ASPAS + "" + ASPAS + ">"     
   
   //Contratos
   cInfo += GetCntrto()
      
   cInfo += ENTER + Space(6) + "</CONTRATOS>"     + ENTER                                                              
   
Return cInfo

Static Function GetCntrto()                                 
   Local cInfo := ""                                        
                         
   cInfo += ENTER + Space(09) + "<CONTRATO"
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "COD_PRACA     = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "ANO           = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "NUMERO        = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "VLR_A_VINCULAR= " + ASPAS + "" + ASPAS  + ">"  
   cInfo += ENTER + Space(09) + "</CONTRATO>"
      
Return cInfo                                                      
*/
/*Static Function GetCntrtRE()                                      
   Local cInfo := ""                                              

   cInfo += ENTER + Space(6) + "<CONTRATO_RES" 
   cInfo += ENTER + Space(9) + "QTDE          = " + ASPAS + "" + ASPAS + ">"        
   cInfo += GetCntrRES()
   cInfo += ENTER + Space(6) + "</CONTRATO_RES>"  + ENTER */                                            
   
Return cInfo
/*
Static Function GetCntrRES()                                
   Local cInfo := ""                                                                  
   
   cInfo += ENTER + Space(9) + "<RE"
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "ID_CONTRATO   = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "ANO_RE        = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "NRO_RE        = " + ASPAS + "" + ASPAS
   cInfo += ENTER + Space(12) + "SEQ_INI       = " + ASPAS + "" + ASPAS   
   cInfo += ENTER + Space(12) + "SEQ_FIM       = " + ASPAS + "" + ASPAS   
   cInfo += ENTER + Space(12) + "VLR_PROVISAO  = " + ASPAS + "" + ASPAS   
   cInfo += ENTER + Space(12) + "NRO_SD        = " + ASPAS + "" + ASPAS + ">"
   cInfo += ENTER + Space(9) + "</RE>"
         
Return cInfo
*/
Static Function GetRES(cPreemb)                                    
   Local cInfo := ""
   Local aRES:= {}     //aRES: 1-Sequencia, 2-nAno, 3-nNro, 4-nSeqIni, 5-nSeqFim, 6-nVlrProvisao, 7-nNro_SD
   //Local aRESID[0]
   Local nQtde := 0  //Qtde de RES
   Local i, nSeqIni,nSeqFim    
   Local nSeq := 0, nAno := 0, nCont:=0
   Local cRES:= ""                        

   //Busca informações de RES
   DbSelectArea("EE9")
   DbSetOrder(3)
   DbSeek(xFilial("EE9")+cPreemb)
   
   //Preenche array com informações de RES
   Do While EE9->(!EOF()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And. EE9->EE9_PREEMB = cPreemb      
      
         //Cadastra RE no array de controle de RES
         //aAdd(aRESID, EE9->EE9_RE) 
         
         //Verifica sequência inicial e final de RE    
         If nSeq > Val(SUBSTR(EE9->EE9_RE,10,12)) .or. nSeq = 0
            nSeqIni:= SUBSTR(EE9->EE9_RE,10,12)
         EndIf
             
         If nSeq < Val(SUBSTR(EE9->EE9_RE,10,12))
            nSeqFim:= SUBSTR(EE9->EE9_RE,10,12)
         EndIf)
         nSeq:=Val(SUBSTR(EE9->EE9_RE,10,12)) 
         
         //Verifica o ano de RE    
         If Val(SUBSTR(EE9->EE9_RE,1,2)) <= 50
            nAno:= Val("20"+Left(EE9->EE9_RE,2))
         Else
            nAno:= Val("19"+Left(EE9->EE9_RE,2))
         EndIf  
         
         //Verifica se RE do Embarque corrente já foi cadastrado             
         If !Empty(cRES) .And. cRES == SUBSTR(EE9->EE9_RE,1,9) 
            aRES[nCont][1][1] := nQtde 
            aRES[nCont][4][1] := nSeqIni  
            aRES[nCont][5][1] := nSeqFim  
            aRES[nCont][6][1] := aRES[nCont][6][1] + EE9->EE9_PRCTOT
            aRES[nCont][7][1] := Left(EE9->EE9_NRSD, 11) 
            
         Else 
            
            //Incrementa Qtde de RES Cadastrados   
            nQtde++
            nCont++         
            AAdd(aRES, ;
                {{nQtde},;                  //Sequencia
                 {nAno},;                   //Ano
                 {SUBSTR(EE9->EE9_RE,1,9)},;//Nro
                 {nSeqIni},;                //nSeqIni
                 {nSeqFim},;                //nSeqFim
                 {EE9->EE9_PRCTOT},;        //Valor Provisao
                 {Left(EE9->EE9_NRSD, 11)}; //Nro SD                                                                   
                })
         EndIf 
         
         cRES:= SUBSTR(EE9->EE9_RE,1,9)
      
      EE9->(DbSkip())
      
   EndDo                     

   //Cria geral de RES
   cInfo += ENTER + Space(6) + "<RES"
   cInfo += ENTER + Space(9) + "QTDE          = "  + ASPAS + StrTrim(nQtde) + ASPAS + ">"
   
   //Cria TAG para cada RE
   For i:= 1 to nQtde
      cInfo += GetRE(aRES[i])
   Next

   cInfo += ENTER + Space(6) + "</RES>"            + ENTER

Return cInfo

Static Function GetRE(aRES)                                     
   Local cInfo := ""                                        
                     
   cInfo += ENTER + Space(9) + "<RE"
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + Formata(aRES[1][1], "N", 3) + ASPAS
   cInfo += ENTER + Space(12) + "ANO_RE        = " + ASPAS + Formata(aRES[2][1], "N") + ASPAS
   cInfo += ENTER + Space(12) + "NRO_RE        = " + ASPAS + Formata(aRES[3][1], "C", 7) + ASPAS
   cInfo += ENTER + Space(12) + "SEQ_INI       = " + ASPAS + Formata(aRES[4][1], "C", 3) + ASPAS
   cInfo += ENTER + Space(12) + "SEQ_FIM       = " + ASPAS + Formata(aRES[5][1], "C", 3) + ASPAS
   cInfo += ENTER + Space(12) + "VLR_PROVISAO  = " + ASPAS + Formata(aRES[6][1], "F") + ASPAS
   cInfo += ENTER + Space(12) + "NRO_SD        = " + ASPAS + Formata(aRES[7][1], "C") + ASPAS + ">"  
   cInfo += ENTER + Space(9) + "</RE>"   
   
Return cInfo

/*
Static Function GetOprs()                                                                                       
   Local cInfo := ""                                        
                        
   cInfo += ENTER + Space(6) + "<OPRS" 
   cInfo += ENTER + Space(9) + "QTDE          = " + ASPAS + "" + ASPAS  + ">"  
   cInfo += GetOpr()    
   cInfo += ENTER + Space(6) + "</OPRS>"          + ENTER                                              
      
Return cInfo

Static Function GetOpr()                                    
   Local cInfo := ""                                        

   cInfo += ENTER + Space(9) + "<OPR"
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + "" + ASPAS   
   cInfo += ENTER + Space(12) + "NRO_OPR       = " + ASPAS + "" + ASPAS + ">"
   cInfo += ENTER + Space(9) + "</OPR>" 
      
Return cInfo
*/
Static Function GetDoctos(aDocs)
   Local cInfo := ""
   Local i, nTotal := 0

   For i := 1 To Len(aDocs)
      If !aDocs[i][Len(aDocs[i])]
         nTotal += 1
      EndIf
   Next

   cInfo += ENTER + Space(6) + "<DOCUMENTOS"
   cInfo += ENTER + Space(9) + "QTDE          = " + ASPAS + Formata(nTotal, "N") + ASPAS  + ">"

   For i := 1 to Len(aDocs)
      If !aDocs[i][Len(aDocs[i])]  //AOM - 19/02/10
         cInfo += GetDocto(aDocs[i], i)
      EndIf
   Next

   cInfo += ENTER + Space(6) + "</DOCUMENTOS>"    + ENTER  
               
Return cInfo                 

Static Function GetDocto(aDocs, nSeq)                                  
   Local cInfo := ""                                        
                         
   cInfo += ENTER + Space(9) + "<DOCUMENTO"
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + Formata(nSeq    , "N", 3) + ASPAS   
   cInfo += ENTER + Space(12) + "DESCRICAO     = " + ASPAS + Formata(aDocs[3], "C") + ASPAS
   //RMD - 19/09/12 - As posiçõe dos campos "Qtd.Originais" e "Qtd. Copias" estavam invertidas.
   cInfo += ENTER + Space(12) + "QTDE_COPIAS   = " + ASPAS + Formata(aDocs[5], "N", 3) + ASPAS
   cInfo += ENTER + Space(12) + "QTDE_ORIGINAIS= " + ASPAS + Formata(aDocs[4], "N", 3) + ASPAS + ">"     
   cInfo += ENTER + Space(9) + "</DOCUMENTO>" 
         
Return cInfo



Static Function GetInstrs(aInstr)
   Local cInfo := ""
   Local i, nCount := 0
   Local cDescM:= ""

   cInfo += ENTER + "      <INSTRUCOES"
   cInfo += ENTER + Space(9) + "QTDE                   = " + ASPAS + Formata(CountInst(aInstr),    "N")  + ASPAS
   cInfo += ENTER + Space(9) + "CPL_001_INST_JUROS     = " + ASPAS + If(At("%", EXL->EXL_INSTJR) > 0, Formata(EXL->EXL_INSTJR,"C"), "") + ASPAS //DFS - 29/10/12 - Tratamento para juros
   cInfo += ENTER + Space(9) + "CPL_008_TP_PROTESTO    = " + ASPAS + Formata(EXL->EXL_TPPROT,"C") + ASPAS
   cInfo += ENTER + Space(9) + "CPL_008_PRAZO_PROTESTO = " + ASPAS + Formata(EXL->EXL_PRZPRO,"C") + ASPAS
   cInfo += ENTER + Space(9) + "CPL_017_VLR_DIF_1      = " + ASPAS + Formata(EXL->EXL_VLRANT,"N", 15) + ASPAS
   cInfo += ENTER + Space(9) + "CPL_018_VLR_DIF_2      = " + ASPAS + Formata(EXL->EXL_VLRBCO,"N", 15) + ASPAS
   cInfo += ENTER + Space(9) + "CPL_018_BCO_NEG_DIF_2  = " + ASPAS + Formata(EXL->EXL_BCONEG,"C") + ASPAS

   Begin Sequence
      For i := 1 to Len(aInstr)
         If !aInstr[i][7] .And. aInstr[i][2] = "999"
            /* nopado por WFS em 29/07/10
               Tratamento realizado na tabela EWC
            //CAMPO MEMO DO EXL 
            cDescM := EXL->(MSMM(EXL_CINSTA,TAMSX3("EXL_MINSTA")[1],,,LERMEMO))*/
            cDescM := aInstr[i][4]
            cDescM := STRTran(cDescM,ENTER," ")
            cInfo += ENTER + Space(9) + "CPL_999_INST_ADICIONAL = " + ASPAS + Formata(cDescM, "C") + ASPAS + ">"
            Break
         EndIf
      Next
      cInfo += ENTER + Space(9) + "CPL_999_INST_ADICIONAL = " + ASPAS + "" + ASPAS + ">"
   End Sequence

   For i := 1 to Len(aInstr)
      If !aInstr[i][7] //AOM - 19/02/10
         nCount++
         cInfo += GetInstr(aInstr[i], nCount)
      EndIf
   Next
      
   cInfo += ENTER + Space(6) + "</INSTRUCOES>" + ENTER
            
Return cInfo
   
//Conta quantas instrucoes serao enviadas.
Static Function CountInst(aInstr)
Local nCount := 0, nInc

   For nInc := 1 To Len(aInstr)
      If !aInstr[nInc][7]
         nCount++
      EndIf
   Next

Return nCount

Static Function GetInstr(aInstr, nSeq)                                  
   Local cInfo := ""                                           
                         
   cInfo += ENTER + Space(9)  + "<INSTRUCAO"
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + Formata(nSeq ,     "N", 3) + ASPAS   
   cInfo += ENTER + Space(12) + "CODIGO        = " + ASPAS + Formata(AllTrim(Str(Val(aInstr[2]))), "C") + ASPAS + ">"
   cInfo += ENTER + Space(9)  + "</INSTRUCAO>"   
            
Return cInfo

Static Function GetFrases(aFrases)                                 
   Local cInfo := ""     
   Local i
   Local nFrases := 0 //LBL - 28/10/2013
                          
   cInfo += ENTER + Space(6) + "<FRASES" 
   cInfo += ENTER + Space(9) + "QTDE          = "  + ASPAS + Formata(CountFrases(aFrases), "N") + ASPAS + ">"   
   
   For i := 1 to Len(aFrases)
      If !aFrases[i][7] //AOM - 19/02/10
         nFrases++ //LBL - 28/10/2013
         cInfo += GetFrase(aFrases[i], nFrases)
      EndIf
   Next
         
   cInfo += ENTER + Space(6) + "</FRASES>"         + ENTER     
         
Return cInfo

//Conta quantas frases serão enviadas
Static Function CountFrases(aFrases)
Local nCount := 0, nInc

   For nInc := 1 To Len(aFrases)
      If !aFrases[nInc][7] //DFS - 29/10/12 - Troca de i para nInc, visto que, a declaração da variavel é nInc
         nCount++
      EndIf
   Next

Return nCount

Static Function GetFrase(aFrases, nSeq)                                  
   Local cInfo := ""        
                         
   cInfo += ENTER + Space(9) + "<FRASE"   
   cInfo += ENTER + Space(12) + "SEQUENCIA     = " + ASPAS + Formata(nSeq,       "N", 3) + ASPAS   
   cInfo += ENTER + Space(12) + "CODIGO        = " + ASPAS + Formata(aFrases[2], "C", 20) + ASPAS + ">"   
   cInfo += ENTER + Space(9) + "</FRASE>" 
                                      
Return cInfo                                            

//Verifica EEC e busca CNPJ/CPF na tabela SA2
Static Function GetCNPJ()
Local cBusca := ""
Private cCNPJ:= ""

   Begin Sequence                      
                   
      cBusca := If(!Empty(EEC->EEC_EXPORT),EEC->EEC_EXPORT,EEC->EEC_FORN)
      
      If Empty(cBusca)
         cBusca := ""
         Break
      End If
      
      DbSelectArea("SA2")  
      SA2->(DbSetOrder(1))
      SA2->(DbSeek(xFilial("SA2")+cBusca))
   
      //Retorna CNPJ
      cBusca := IIf(Empty(SA2->A2_CGC),"",Formata(SA2->A2_CGC,"C"))   
      
      If EasyEntryPoint("EECEI200")
         ExecBlock("EECEI200", .F., .F., "ALTERA_CNPJ")
      EndIf

      If !Empty(cCNPJ)
         cBusca:= Formata(cCNPJ, "C")
      EndIf

   End Sequence

Return cBusca
   
//Busca código Itaú p/ moeda
Static Function GetMoeda(cMoeda)
      
   Begin Sequence                      
                   
      If Empty(cMoeda)
         cMoeda := ""
         Break
      End If
      
      DbSelectArea("SYF")  
      SYF->(DbSetOrder(1))
      SYF->(DbSeek(xFilial("SYF")+AvKey(cMoeda, "YF_MOEDA")))
   
      //Retorna código Itaú da moeda   
      //cMoeda := IIf(Empty(SYF->YF_INTITAU),"",Formata(SYF->YF_INTITAU,"C")) nopado por WFS em 29/07/10
      cMoeda:= "0" + SYF->YF_COD_GI
      
   End Sequence      

Return cMoeda
                                    
//Retorna o nome da cidade
Static Function GetPais(cPais)      

   Begin Sequence                      

      If Empty(cPais)
         cPais := ""
         Break
      End If

      DbSelectArea("SYA")  
      SYA->(DbSetOrder(1))
      SYA->(DbSeek(xFilial("SYA")+cPais))

      //Retorna código Itaú da moeda   
      cPais := IIf(Empty(SYA->YA_SISEXP),"",Formata(SYA->YA_SISEXP,"C"))   

   End Sequence      

Return cPais

Static Function StrTrim(cTexto)
  cTexto := AllTrim(Str(cTexto))
Return cTexto
             
//Verifica se campo é nulo, se for retorna vazio ""
Static Function Formata(cTexto, cTipo, nLen)
Local nZeros := 0

Do Case
   Case cTipo = "C"   
      //Caracter
      cTexto := IIf(Empty(cTexto), "", AllTrim(cTexto))
      
   Case cTipo = "N"
      //Number
      cTexto := IIf(Empty(cTexto), "0", StrTrim(cTexto))       
      //Coloca zeros à esquerda
      If !Empty(nLen)
         nZeros := nLen - Len(cTexto)
         cTexto := Replicate("0", nZeros) + cTexto
      End If         
   Case cTipo = "F"                                      
      //Real
      //DFS - 15/10/12 - Se não estiver vazio a variavel, acrescenta o valor com duas casas decimais.
      cTexto := IIf(Empty(cTexto), "0.00", Alltrim(Str(cTexto,,2)))
   Case cTipo = "D"  
      //Data
      If Empty(cTexto)
         cTexto = ""         
      Else                       
         nDia := Day(cTexto)
         nMes := Month(cTexto)
         nAno := Year(cTexto)         
         cTexto := StrTrim(nDia) + "/" + StrTrim(nMes) + "/" + StrTrim(nAno) 
      End If                                  
   Case cTipo = "M"                         
      //Memo
      cTexto := MSMM(cTexto, nLen)
      cTexto := IIf(Empty(cTexto), "", AllTrim(cTexto))   
End Case
      
Return cTexto

Static Function IDTodosItens(aServ, aItens)
   Local aRet[0], i, j
   
   For i:= 1 to Len(aServ)
      For j:= 1 to Len(aItens)
         aAdd(aRet, aServ[i][3]+aItens[j][2])
      Next   
   Next

Return aRet

/*
Função    : SelecDocs()
Objetivos : Função que cria getdados para seleção de documentos para o embarque informado.
Parametros: cEmb: Embarque p/ seleção dos documentos.
Retorno   : -
Autor     : Fabrício Romera    
Revisão   : Allan Oliveira Monteiro
Data      : 24/11
*/
Static Function SelecDocs(cEmb)
   Local aDocs[0], aRet[0]
   Local oDlg, oSay
   Local i , nUsado  := 0
   Local bOk     := {|| If(lOk := ValidaOK() .And. EI100VLDLINHA(),oDlg:End(),)}
   Local bCancel := {|| lOk := .F., oDlg:End()}
   Local lOk := .F. 
   Local nValor := 0
   Private lRefresh := .T.
   Private aHeader[0], aCols[0], aRotina[0]
   Private cPreemb := cEmb
   Private oGetDados

   //Define aRotina
   /*aAdd(aRotina, {"Pesquisar", "AxPesqui", 0, 1})
   aAdd(aRotina, {"Visualizar","AxVisual", 0, 2})
   aAdd(aRotina, {"Incluir",   ""        , 0, 3})
   aAdd(aRotina, {"Alterar",   ""        , 0, 4})
   aAdd(aRotina, {"Excluir",   "AxDeleta", 0, 5})*/
   aRotina := MenuDef("SELECDOCS")

   //Define aHeader
   DbSelectArea("SX3")
   DbSetOrder(1)
   DbSeek("EWA")            
   While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "EWA"       
      If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL 
         nUsado++
         Aadd(aHeader,{Trim(X3Titulo()),;
                       SX3->X3_CAMPO,;
                       SX3->X3_PICTURE,;                    
                       SX3->X3_TAMANHO,;
                       SX3->X3_DECIMAL,;
                       SX3->X3_VALID,;                                                            
                       "",;
                       SX3->X3_TIPO,;                                              
                       ,;
                       ""})
      End If
      SX3->(DbSkip())
   End                                   
   
   
   DbSelectArea("EWA")
   If EWA->(DbSeek(xFilial()+cPreemb))
      While EWA->(!Eof() .And. EWA_FILIAL+EWA_PREEMB == xFilial()+cPreemb)
         //Carrega aCols
         aAdd(aCols, Array(Len(aHeader) + 1))
         For i := 1 To Len(aHeader)
            aCols[Len(aCols)][i] := EWA->&(aHeader[i][2])
         Next
         aCols[Len(aCols)][Len(aCols[1])] := .F.
         EWA->(DbSkip())
      EndDo
   Else
      AAdd(aCols, Array(nUsado + 1))
      For i:= 1 To nUsado
         aCols[1][i]:= CriaVar(aHeader[i][2])
      Next
      aCols[1][nUsado +1]:= .F.
   EndIf
                                
   //Define conteudo da label de descrição do processo
   cSay := "Informe os documentos referentes ao embarque " + cPreemb

   //Cria Dialog
   DEFINE MSDIALOG oDlg TITLE "Seleção de Documentos" FROM 200,1 TO 620,600 PIXEL   

      @ 15, 3 SAY oSay VAR cSay SIZE 180, 10 OF oDlg PIXEL
      
      //AOM - 19/02/10                              
      oGetDados := MsGetDados():New(25, 3, 209, 297, 4, "EI100VLDLINHA()", /*uTudoOk*/, /*cIniCpos*/, .T.,;
                                   {"EWA_CODDOC", "EWA_QTORIG", "EWA_QTCOPI"}, /*nFreeze*/,, 99,/*uFieldOk*/,;
                                   /*uSuperDel*/,,/*uDelOk*/, oDlg)

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

   //Preenche vetor de retorno com informações de documentos
   If lOk
      For i := 1 to Len(aCols)
         //Verifica se documento e quantidade de originais foram informados.
         If !Empty(aCols[i][3]) .OR. !Empty(aCols[i][4])//FSY - 05/06/2013 - alterado para permitir valor 0 (zero) no campo “Qt. Originais” na tela "Seleção de Documentos" da rotina "Carta Remessa"
            aAdd(aRet, aCols[i])
         End If
      Next
   End If

Return aRet                                                       

/*
Função    : InsereDocs()
Objetivos : Função que insere os documentos selecionados na tabela de controle de Documentos da Remessa "EWA"
Parametros: aDocs: array de documentos selecionados -retornado da função SelecDocs()
Retorno   : -
Autor     : Fabrício Romera
Revisão   : Allan Oliveira Monteiro
Data      : 03/12
*/
Static Function InsereDocs(aDocs)
   Local i

   DbSelectArea("EWA")

   For i := 1 to Len(aDocs)
      //Excluir registro caso esteja marcado para deleção - AOM - 19/02/10
      If aDocs[i][Len(aDocs[i])] == .T.
         If EWA->(DbSeek(xFilial("EWA")+aDocs[i][1]+aDocs[i][2]))
            EWA->(Reclock("EWA", .F.))
            EWA->(DbDelete())
            EWA->(MsUnlock())
         EndIf
      Else
          //Verificar se já existe o registro - AOM - 19/02/10
         If EWA->(DbSeek(xFilial("EWA")+aDocs[i][1]+aDocs[i][2]))
            EWA->(RecLock("EWA",.F.))
         Else 
            EWA->(RecLock("EWA",.T.)) 
         EndIf
         //
           EWA->EWA_FILIAL  := xFilial("EWA")
           EWA->EWA_PREEMB  := aDocs[i][1]
           EWA->EWA_CODDOC  := aDocs[i][2]
           EWA->EWA_DESCR   := aDocs[i][3]
           EWA->EWA_QTORIG  := aDocs[i][4]
           EWA->EWA_QTCOPI  := aDocs[i][5]
           EWA->(MsUnlock())
      EndIf

   Next

Return

/*
Função    : InsereInstr()
Objetivos : Função que insere as instruções selecionadas na tabela de controle de Instruções da Remessa "EWB"
Parametros: aInstr: array de instruções, aFrases: array de frases, nQtPreemb: quantidade de embarques da remessa.
Retorno   : -
Autor     : Fabrício Romera 
Revisão   : Allan Oliveira Monteiro
Data      : 03/12
*/
Static Function InsereInstr(aInstr, aFrases, nQtPreemb)
   Local i, j
      
   DbSelectArea("EWC")  
   EWC->(DBSetOrder(1)) //EWC_FILIAL + EWC_PREEMB + EWC_CODINS 
   For i := 1 to nQtPreemb   
   
      For j := 1 to Len(aInstr[i])
         //Verificar se já existe o registro - AOM - 19/02/10                                   
         If !aInstr[i][j][7]
            If EWC->(DbSeek(xFilial("EWC")+AvKey(aInstr[i][j][1], "EWC_PREEMB") + AvKey(aInstr[i][j][2], "EWC_CODINS")))
               EWC->(RecLock("EWC",.F.))
            Else
               EWC->(RecLock("EWC",.T.)) 
            EndIf
            EWC->EWC_FILIAL  := xFilial("EWC")
            EWC->EWC_PREEMB  := aInstr[i][j][1]
            EWC->EWC_CODINS  := aInstr[i][j][2]
            EWC->EWC_TIPO    := aInstr[i][j][3]    
            EWC->EWC_DESCRI  := aInstr[i][j][4]
            EWC->EWC_TPVCTO  := aInstr[i][j][5]
            EWC->EWC_NUSAR   := aInstr[i][j][6]
            EWC->(MsUnlock())
         Else 
            //Excluir registro caso esteja marcado para deleção - AOM - 19/02/10
            If EWC->(DbSeek(xFilial("EWC")+AvKey(aInstr[i][j][1], "EWC_PREEMB") + AvKey(aInstr[i][j][2], "EWC_CODINS")))
               EWC->(RecLock("EWC",.F.))
               EWC->(DbDelete())
               EWC->(MsUnlock())   
            EndIf                                               
         EndIf                
      Next         
      
      For j := 1 to Len(aFrases[i])                                        
      
         If !aFrases[i][j][7] 
            //Verificar se já existe o registro - AOM - 19/02/10  
            If EWC->(DbSeek(xFilial("EWC")+ AvKey(aFrases[i][j][1], "EWC_PREEMB") + AvKey(aFrases[i][j][2], "EWC_CODINS")))
               EWC->(RecLock("EWC",.F.))
            Else
               EWC->(RecLock("EWC",.T.)) 
            EndIf                                                      
            EWC->EWC_FILIAL  := xFilial("EWC")
            EWC->EWC_PREEMB  := aFrases[i][j][1]
            EWC->EWC_CODINS  := aFrases[i][j][2]
            EWC->EWC_TIPO    := aFrases[i][j][3]    
            EWC->EWC_DESCRI  := aFrases[i][j][4]
            EWC->EWC_TPVCTO  := aFrases[i][j][5]
            EWC->EWC_NUSAR   := aFrases[i][j][6]
            EWC->(MsUnlock()) 
         Else
            //Excluir registro caso esteja marcado para deleção - AOM - 19/02/10
            If EWC->(DbSeek(xFilial("EWC")+ AvKey(aFrases[i][j][1], "EWC_PREEMB") + AvKey(aFrases[i][j][2], "EWC_CODINS")))
               EWC->(RecLock("EWC",.F.))
               EWC->(DbDelete())
               EWC->(MsUnlock())   
            EndIf                                              
         EndIf      
         
      Next            
   Next         
                                                          
Return

/*
Função    : SelecInstr()
Objetivos : Função que cria GetDados para seleção de instruções e frases.
Parametros: aPreembSel: array de embarques selecionados, aInstr: array onde serão inseridas as instr. selecionadas,
            aFrases: array onde serão inseridas as frases selecionadas.
Retorno   : -
Autor     : Fabrício Romera
Data      : 01/12
*/
Static Function SelecInstr(aPreembSel, aInstr, aFrases)
   Local oDlg, oSay
   Local i, j , nUsado  := 0, nInc
   Local bOk     := {|| Iif(lOk := EI100ValInst() .And. EI200VERINS(), oDlg:End(),)}
   Local bCancel := {|| lOk := .F., oDlg:End()}
   Local lOk := .F.
   Private lRefresh := .T.
   Private aHeader[0], aCols[0], aRotina[0]
   Private cPreemb := "", oGetDados

   //Define aRotina
   /*aAdd(aRotina, {"Pesquisar", "AxPesqui", 0, 1})
   aAdd(aRotina, {"Visualizar","AxVisual", 0, 2})
   aAdd(aRotina, {"Incluir",   ""        , 0, 3})
   aAdd(aRotina, {"Alterar",   ""        , 0, 4})
   aAdd(aRotina, {"Excluir",   "AxDeleta", 0, 5})*/
   aRotina := MenuDef("SELECINSTR")

   //Define aHeader
   DbSelectArea("SX3")
   DbSetOrder(1)
   DbSeek("EWC")
   While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "EWC"
      If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL 
         nUsado++
         Aadd(aHeader,{Trim(X3Titulo()),;
                       SX3->X3_CAMPO,;
                       SX3->X3_PICTURE,;
                       SX3->X3_TAMANHO,;
                       SX3->X3_DECIMAL,;
                       SX3->X3_VALID,;
                       "",;
                       SX3->X3_TIPO,;
                       ,;
                       ""})
      End If
      SX3->(DbSkip())
   End
   
   For i := 1 to Len(aPreembSel)
   
      aCols := {}
      cPreemb := aPreembSel[i][1]

      If EWC->(DbSeek(xFilial()+cPreemb))
         While EWC->(!Eof() .And. EWC_FILIAL+EWC_PREEMB == xFilial()+cPreemb)
            //Carrega aCols
            aAdd(aCols, Array(Len(aHeader) + 1))
            For nInc := 1 To Len(aHeader)
               aCols[Len(aCols)][nInc] := EWC->&(aHeader[nInc][2])
            Next
            aCols[Len(aCols)][Len(aCols[1])] := .F.
            EWC->(DbSkip())
         EndDo
      EndIf

      //Define conteudo da label de descrição do processo
      cSay := "Informe as instruções referentes ao embarque " + cPreemb

      //Cria Dialog
      DEFINE MSDIALOG oDlg TITLE "Seleção de Instruções" FROM 200,1 TO 620,600 PIXEL

         @ 15, 3 SAY oSay VAR cSay SIZE 180, 10 OF oDlg PIXEL

         //AOM - 19/02/10                                 
         oGetDados := MsGetDados():New(25, 3, 209, 297, INCLUIR, "EI100ValInst()", /*uTudoOk*/, /*cIniCpos*/, .T.,;
                                      {"EWC_CODINS", "EWC_DESCRI"}, /*nFreeze*/,, 99, , /*uSuperDel*/,,/*uDelOk*/, oDlg)

      ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

      //Preenche vetor de retorno com informações de documentos    
      If lOk

         aAdd(aInstr, {})
         aAdd(aFrases,{})

         For j := 1 to Len(aCols)
            //Verifica se documento e quantidade de originais foram informados.
            If !Empty(aCols[j][2]) .And. !Empty(aCols[j][4]) .And. aCols[j][3] <> "3"    //Instrução
               aAdd(aInstr[i],  aCols[j])
            ElseIf !Empty(aCols[j][2]) .And. !Empty(aCols[j][4]) .And. aCols[j][3] = "3" //Frase
               aAdd(aFrases[i], aCols[j])
            End If
         Next
      End If

   Next

Return lOk

//Valida Linha da Instrução
Function EI200VLDINS()
   Local cCodIns   := "", cNUsarCom := "", cTipoVenc := "", cMensErro := ""
   Local lRet := .T. , i

   Begin Sequence

      If Empty(aCols[n, 4])
         MsgInfo("Informe um código de instrução válido", "Aviso")
         Break
      End If
      //                                  
      
      cTipoVenc := Alltrim(aCols[n, 5])
      cCodIns   := "/" + Alltrim(aCols[n, 2]) + "/" //Guarda codigo da instrução selecionada

      //Valida se instrução selecionada não é conflitante com outra já escolhida.
      For i := 1 to Len(aCols)
         cNUsarCom   := "/" + Alltrim(aCols[i, 6]) + "/"

         If cCodIns $ cNUsarCom
            cMensErro := "Instrução inválida. Não é possivel utiliza-la em conjunto com as instruções: " + ;
                         AllTrim(aCols[n][6]) + "."
            lRet := .F.          
            
         //Valida Tipo de Vencimento(Não pode haver tipos P(Prazo) e V(Vista) selecionados para mesmo arquivo).
         ElseIf cTipoVenc != "A" .And. AllTrim(aCols[i][5]) != "A" .And. !Empty(AllTrim(aCols[i][5])) .And. Empty(aCols[i][7])
            If cTipoVenc <> AllTrim(aCols[i][5])         
               lRet := .F.
               cMensErro := "Instrução inválida. Tipo de vencimento incompativel com outras instruções selecionadas."
            End If                           
         End If

      Next

      If !lRet

         MsgInfo(cMensErro, "Aviso")

         aCols[n][2] := Space(20)
         aCols[n][3] := Space(1)
         aCols[n][4] := Space(135)
         aCols[n][5] := Space(1)
         aCols[n][6] := Space(20)

         lRet := .T.
                                
	  End If 
	  

   End Sequence

Return lRet

/*
Função    : EI100ValInst()
Objetivos : Validar alguns itens dos documentos de seleção de instruções
Parametros: -                                     
Retorno   : -
Autor     : Allan Oliveira monteiro 
Data      : 23/02/2010 
*/

Function EI100ValInst()
   Local cCodIns   := "", cNUsarCom := ""   
   Local lRet := .T. , i, nCont := 0
   
   Begin Sequence
     
      //cCodIns   := "/" + Alltrim(STR(val(aCols[n, 2]))) + "/" //Guarda codigo da instrução selecionada
      cCodIns   :=   "/" + Alltrim(aCols[n, 2]) + "/" //Guarda codigo da instrução selecionada

      //Valida se instrução selecionada não é conflitante com outra já escolhida.
      For i := 1 to Len(aCols)
         If !aCols[i, 7]
            cNUsarCom := "/" + Alltrim(aCols[i, 6]) + "/"
         EndIf

         If cCodIns $ cNUsarCom .And. !aCols[n, 7]
            lRet := .F.
            MsgInfo("A opção escolhida não pode ser utilizada junto com algumas intruções. Verifique a coluna 'Não Usar Com'.","Aviso")
            break
         EndIf
         
         If AllTrim(aCols[n, 2]) == AllTrim(aCols[i, 2]) .And. !aCols[i, 7]
            nCont++
            If nCont > 1
               lRet := .F.
               MsgInfo("Já Existe a instrução escolhida para este processo.","Aviso")
               break 
            EndIf
         EndIf
      Next
      
      /*Verificação do Tipo do Vencimento escolhido na Carta Remessa no embarque, se condiz
        com as instruções na geração do XML*/
      //AOM - 23/02/2010  
      DbSelectArea("EXL")
      EXL->(DBSetOrder(1))
      EXL->(Dbseek(xFilial("EXL") + AllTrim(aCols[n, 1])))
      
      If EXL->EXL_TPVENC == "P" .And. AllTrim(aCols[n, 5]) == "V" .And. !aCols[n, 7]
         MsgInfo("O tipo de vencimento escolhido nas instruções deve ser 'A Prazo ou Ambos' conforme a Carta de Remessa escolhida no Embarque.","Aviso")
         lRet := .F.
      ElseIf EXL->EXL_TPVENC == "V" .And. AllTrim(aCols[n, 5]) == "P" .And. !aCols[n, 7]
         MsgInfo("O tipo de vencimento escolhido nas instruções deve ser 'A Vista ou Ambos' conforme a Carta de Remessa escolhida no Embarque.","Aviso")
         lRet := .F.
      EndIf
   
   End Sequence
         
Return lRet

/*
Função    : EI100VLDLINHA()
Objetivos : Verifica se existe documento selecionado para carta remessa
Parametros: -
Retorno   : lRet
Autor     : Fabrício Romera 
Revisão   : Allan Oliveira Monteiro
Data      : 22/02/2010 
*/

Function EI100VLDLINHA()
   Local lRet := .F.
   Local i, nCont:= 0

   Begin Sequence
      
      //AOM - 22/02/2010
      For i:=1 to Len(aCols)
         If AllTrim(aCols[n, 2]) == AllTrim(aCols[i, 2]) .And. !aCols[i, 6]
            nCont++
            If nCont > 1
               MsgInfo("Já Existe o documento escolhido para este processo.")
               Break
            EndIf
         EndIf 
      Next

      If (Empty(aCols[n, 3]) .And. Len(aCols) = n .And. Empty(aCols[n, 6])) .or. (Empty(aCols[n, 2]) .And. aCols[n, 6] == .F.)
         MsgInfo("Informe um código de documento válido", "Aviso")
         Break
      End If
                                                                                                   
      //DFS - 29/10/12 - Validação para que, dê a mensagem, apenas se não houver qnt original e qnt copia.
      If Empty(aCols[n, 4]) .AND. Empty(aCols[n,5]) 
         MsgInfo("Informe a quantidade de documentos originais ou a quantidade de cópias", "Aviso")
         Break
      End If 
      
      lRet := .T.

   End Sequence

Return lRet


/*
Função    : ValidaOK()
Objetivos : Verifica se existe documento selecionado para carta remessa
Parametros: -
Retorno   : lRet
Autor     : Fabrício Romera 
Revisão   : Allan Oliveira Monteiro
Data      : 25/02/2010 
*/
Static Function ValidaOK()

   Local i,nCont := 0, lRet := .T.
                                                                                     
   Begin Sequence                                                        
      
      //Verifica se existe documento selecionado - AOM 25/02/2010 
      For i:= 1 to Len(aCols)      
         If Empty(aCols[1, 2]) .or. aCols[1, 6] == .T. 
            If aCols[i, 6] == .T.
               nCont++ 
            Else
               Break
            EndIf
         Else 
            Break
         EndIf
         
      Next                                                               
      
      If nCont > 1
         MsgInfo("Informar documento cadastrado para o primeiro registro.", "Aviso")
      Else
         MsgInfo("Nenhum documento informado.", "Aviso") 
      EndIf       
      lRet := .F.      
      
   End Sequence
   
Return lRet            

/*
Função    : VisualizaXML()
Objetivos : Abrir arquivo .XML para visualização.
Parametros: cArqXML: nome do arquivo XML, cDirArq: diretorio do arquivo                                     
Retorno   : -
Autor     : Fabrício Romera 
Data      : 27/11/2009 
*/
/*Static Function VisualizaXML(cArqXML, cDirArq)
                                   
   Local i, aDirectory := {}
   Local cXml := "", cTagXSL := ""
   Local cTemp  := GetTempPath()
   Local cDestTemp := cTemp + "IntItau\"
   Local cNewXML   := cDestTemp + cArqXML
   Local cOrigXSL  := "\comex\itau\resources\"
   Local cArqXSL   := ""
      
   //Verifica se ja existe o diretorio IntItau na pasta Temp, caso exista limpa o diretorio.
   If !lIsDir(cDestTemp)
      nRet := MakeDir(cDestTemp)
      If nRet < 0
         Alert("Erro na criação do diretório na pasta Temp.")
         Return .F.
      EndIf
   Else 
      //Apaga os arquivos do diretorio na pasta temp.
      aDirectory := DIRECTORY(cDestTemp + "*.*",)
      For i:=1 to len(aDirectory)
         FERASE(cDestTemp + aDirectory[i][1])
      Next i
   EndIf
   
   //Faz a leitura do arquivo XML.
   cXml := MemoRead(cDirArq + cArqXML)
   If cXml == ""
      Alert("Erro de leitura de arquivo.")
      Return .F.
   EndIf                                          
   
   //Adiciona definição do arquivo XSL ao arquivo XSL
   cTagXSL := '<?xml-stylesheet type="text/xsl" href="IntItaRemVis.xsl"?>'
   cArqXSL := "IntItaRemVis.xsl"
   cXml    := cTagXSL + cXml
   
   Begin Sequence
      //Cria o XML na pasta temp com a definição da linha que ira conter o XSL.
      If !MemoWrite(cNewXML, cXml)
         Alert("Erro na abertura do arquivo.")
         Break
      EndIf
                        
      //copia o XSL para a pasta temp
      If !CpyS2T( cOrigXSL + cArqXSL, cDestTemp)
         Alert("Erro na gravação de copia de arquivo de layout na pasta temporaria.")
         Break
      EndIf

      //Executa o arquivo XML com o layout ja definido.     
      nRet := ShellExecute("open",cNewXML,"","", 1)
      If nRet <= 32
         Alert("Erro na exibição do arquivo.")
         Break
      EndIf
   End Sequence
         
Return */                          
                          
/*
Função    : VisualizarArquivo()
Objetivos : Opção de visualizar arquivo de carta remessa eletrônica da central de integrações Itaú.
Parametros: -
Retorno   : -
Autor     : Fabrício Romera 
Data      : 30/11/2009 - 11:11 
*/
Static Function VisualizarArquivo()
   Local cNomeArq := "", cDirArq := ""
   Local oXMl 
   Local cChave := xFilial("EXL")+&(Alias()+"->EW9_PREEMB")
                                   
   Begin Sequence                                      
      //Preenche nome do arquivo
      cNomeArq := AllTrim(&(Alias()+"->EW9_FILE")) + ".xml"
      
      EXL->(DbSeek(cChave))
      
      If EXL->(FieldPos("EXL_BANCO")) > 0
         lCitibank := Alltrim(EXL->EXL_BANCO) == "2"
      EndIf      
                                                        
      //Verifica se há item foi selecionado
      If Empty(cNomeArq)
         MsgInfo("Nenhum item selecionado.", "Aviso")
         Break
      End If          
   
      //Verifica qual a pasta selecionada
      If Right(Alias(), 3) = aItens[1][2]         //Não Enviados
         cDirArq := "\comex\itau\naoenviados\"                        
      ElseIf Right(Alias(), 3) = aItens[2][2]     //Enviados
         cDirArq := "\comex\itau\enviados\"      
      ElseIf Right(Alias(), 3) = aItens[3][2]     //Rejeitados      
         cDirArq := "\comex\itau\rejeitados\"  
      ElseIf Right(Alias(), 3) = aItens[4][2] 
         cDirArq := "\comex\itau\aprovados\"   
      End If
      
      //Chama função de exibição de XML
      //VisualizaXML(cNomeArq, cDirArq)  - NOPADO POR AOM - 23/02/2011 - pois foi criada a classe generica para visualização de XML e XSL 
      // AOM - 23/02/2011 - Visualização do XML   

     If lCitiBank      
         oXML := EasyXSLView():New(cDirArq+cNomeArq, "EECEI203", .T.)  
     Else
        oXML := EasyXSLView():New(cDirArq+cNomeArq, "EECEI202", .T.)
     EndIf

   End Sequence

Return

Function EI200CADINSTR()
Private oUpdAtu
Private cCadastro := "Inform. Carta Remessa"  
Private aRotina   := MenuDef("EI200CADIN") //MenuDef()  // GFP - 10/10/2014

//*** GFP - Tratamento para carga padrão da tabela EWB - 19/08/2011
If FindFunction("AvUpdate01")
   oUpdAtu := AvUpdate01():New()
EndIf

If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
   If ChkFile("EWB")
      oUpdAtu:aChamados := {{nModulo,{|o| EDadosEWB(o)}}}
      oUpdAtu:Init(,.T.)
   EndIf
EndIf
//*** Fim GFP

mBrowse( 6, 1,22,75,"EWB")   // GFP - 10/10/2014   //AxCadastro("EWB")
Return

Static Function EDadosEWB(o)
o:TableStruct('EWB',{'EWB_FILIAL','EWB_TIPO','EWB_CODINS','EWB_DESCRI','EWB_TPVCTO','EWB_NUSAR'},1)
o:TableData('EWB',{'  ','2','01                  ','In case of delay payment, collect interest at the rate of <juros> from maturity until effective payment. Do not waive interest charges.','A','28                  '},,.F.)
o:TableData('EWB',{'  ','1','22                  ','Deliver documents to Drawee only against payment of all your charges, Drawer will not accept any deduction of total invoice amount. Any problems pls contact us by Swift.','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','25                  ','Please, confirm as soon as possible by tested msg the acceptance by drawee as well as your guarantee for payment at maturity as per previously agreement between drawer and drawee.','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','02                  ','Deliver documents against acceptance of draft(s).                                                                                      ','P','5                   '},,.F.)
o:TableData('EWB',{'  ','1','03                  ','Deliver documents against payment.                                                                                                     ','V','4/5/6/7             '},,.F.)
o:TableData('EWB',{'  ','1','04                  ','Deliver documents against payment for draft at sight and acceptance for remaining drafts.                                              ','A','3/5/6/7             '},,.F.)
o:TableData('EWB',{'  ','1','05                  ','Deliver documents against written undertaking to pay on due date.                                                                      ','P','2/3/4/6/7           '},,.F.)
o:TableData('EWB',{'  ','1','06                  ','Deliver documents to drawee free of payment and/or acceptance.                                                                         ','V','3/4/5/7/29          '},,.F.)
o:TableData('EWB',{'  ','1','07                  ','Deliver documents to drawee under advice to us. Present enclosed accepted draft(s) for payment at maturity.                            ','A','3/4/5/6             '},,.F.)
o:TableData('EWB',{'  ','2','08                  ','In case of <tipo>, protest draft after <dias> days.                                                                                    ','A','14/15/16/28/30      '},,.F.)
o:TableData('EWB',{'  ','1','09                  ','In case of non acceptance, advise us by Telex/Swift stating reasons.                                                                   ','P','10/11               '},,.F.)
o:TableData('EWB',{'  ','1','10                  ','In case of non acceptance/non payment, advise us by Telex/Swift stating reasons.                                                       ','P','9/11                '},,.F.)
o:TableData('EWB',{'  ','1','11                  ','In case of non payment, advise us by Telex/Swift stating reasons.                                                                      ','A','9/10                '},,.F.)
o:TableData('EWB',{'  ','1','12                  ','Inform us the maturity date by Telex/Swift.                                                                                            ','P','                    '},,.F.)
o:TableData('EWB',{'  ','1','13                  ','Original documents were sent directly to drawee by the drawer.                                                                         ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','14                  ','Protest in case of non acceptance, advising us by Telex/Swift.                                                                         ','P','8/15/16/28          '},,.F.)
o:TableData('EWB',{'  ','1','15                  ','Protest in case of non acceptance/non payment, advising us by Telex/Swift                                                              ','P','8/14/16/28/30       '},,.F.)
o:TableData('EWB',{'  ','1','16                  ','Protest in case of non payment, advising us by Telex/Swift.                                                                            ','A','8/14/15/28/30       '},,.F.)
o:TableData('EWB',{'  ','2','17                  ','The difference of <dif1> was paid in advance.                                                                                          ','A','                    '},,.F.)
o:TableData('EWB',{'  ','2','18                  ','The difference of <dif2> was negotiated with <banqueiro>.                                                                              ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','19                  ','Please collect all your charges from Drawee. Our customer will not accept any deduction of payment.                                    ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','20                  ','You are authorized to receive partial payments.                                                                                        ','A','26                  '},,.F.)
o:TableData('EWB',{'  ','1','21                  ','Please deliver documents to Drawee only against drafts acceptance and your guarantee on the same. Please confirm us by Swift.          ','P','                    '},,.F.)
o:TableData('EWB',{'  ','1','23                  ','You are authorized to deliver documents against payment of drafts separetely.                                                                                            ','P','                    '},,.F.)
o:TableData('EWB',{'  ','1','24                  ','Deliver documents against payment at sight, and acceptance for remaining and your GUARANTEE.                                                                             ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','26                  ','You are not authorized to receive partial payments.                                                                                                                                ','A','20                  '},,.F.)
o:TableData('EWB',{'  ','1','27                  ','You are authorized to deliver documents against payment of invoice separetely.                                                                                                     ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','28                  ','In case of delay payment do not collect interest. In case of non payment do not protest.                                                                                           ','A','1/8/14/15/16        '},,.F.)
o:TableData('EWB',{'  ','1','31                  ','You are authorized to lift one original of B/L to Drawee for inspection proposal.                                                                                                  ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','32                  ','Advise acceptance of this draft to Standard Bank Plc, swift code SBLLGB2L.                                                                                                         ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','35                  ','Charges may not be waived and documents must not be delivered                                                                                                                      ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','37                  ','Do not release documents without payment.                                                                                                                                          ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','38                  ','Do not waive your charges                                                                                                                                                          ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','39                  ','Payment of charges must not be waived                                                                                                                                              ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','40                  ','Deliver documents against payment for draft at sight                                                                                                                               ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','41                  ','Deliver documents within 48 hours under remittance register.                                                                                                                       ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','42                  ','Deliver documents within 48 hours under remittance register and draft endorsement.                                                                                                 ','P','                    '},,.F.)
o:TableData('EWB',{'  ','1','43                  ','In case of payment after due date, the importer will be charged with a monthly fine of 2% over commercial invoice totals.                                                          ','A','                    '},,.F.)
o:TableData('EWB',{'  ','1','44                  ','In case of delay 10 days of due, the draft will be protest. All charges must be covered by importer.                                                                               ','A','34                  '},,.F.)
o:TableData('EWB',{'  ','2','999                 ','<Texto livre em inglês>                                                                                                                                                            ','A','                    '},,.F.)

Return Nil

/*
Função    : EI200VERDOC()
Objetivos : Verifica existencia de registro na tabela EWA.
Parametros: -
Retorno   : -
Autor     : Fabrício Romera
Data      : 30/11/2009 - 11:11
*/
Function EI200VERDOC(cCodDoc)
   Local lRet := .F.
   
   If !Empty(cCodDoc)
      //Incrementa o zero ao lado esquerdo do numero menor que dez
      If Val(cCodDoc) < 10
         cCodDoc := M->EWA_CODDOC := "0" + AllTrim(Str(Val(cCodDoc)))
      EndIf 
      
      //Busca registro na tabela de documentos
      dbSelectArea("SX5")
      DbSetOrder(1)
      DbSeek(xFilial("SX5")+"YU"+cCodDoc) 
      
   
      If SX5->(!EOF())
         lRet := .T.
      Else
         aCols[n, 3]   := Space(20)
         aCols[n, 2]   := Space(10)
         M->EWA_CODDOC := Space(10)
         MsgInfo("Código de documento não cadastrado.","Aviso")
      End If
   Else
      lRet := .T.
   End If

Return lRet    


/*
Função    : EI200VERINS()
Objetivos : Verifica se a instrução escolhida está cadastrada EWB, e valida se alguns campos da Carta Remessa
            no embarque estão preenchidos de acordo com a instrução escolhida.
Parametros: cCodInst
Retorno   : lRet
Autor     : Allan Oliveira Monteiro 
Data      : 01/03/2010
*/
Function EI200VERINS(cCodInst)
    Local lRet := .F. , Msg := "" , ncont := 0
    /*colocando os zeros a esquerda quando em todos as instruções quando 
      é clicado no botão "OK" na instrução*/
    If Empty(cCodInst)
       For nCont := 1 to Len(aCols)
          If val(aCols[nCont][2]) < 10 
             aCols[nCont][2] := "0" + AllTrim(Str(Val(aCols[nCont][2])))
          ElseIf val(aCols[nCont][2]) < 100  
             aCols[nCont][2] :=  M->EWC_CODINS := AllTrim(Str(Val(aCols[nCont][2])))
          EndIf
       Next

       /*Else 
       //DFS - 19/10/12 - Retirado tratamento que, não encontrava cadastros com caracter. 
       //colocando os zeros à esquerda na instrução escolhida
       If val(cCodInst) >= 1 .AND. val(cCodInst) < 10 
         cCodInst :=  M->EWC_CODINS := "0" + AllTrim(Str(Val(cCodInst)))
       ElseIf val(cCodInst) < 100  
         cCodInst :=  M->EWC_CODINS := AllTrim(Str(Val(cCodInst)))
       EndIf */
    EndIf
    

    Begin Sequence 
       /*DbSelectArea("EWB")
       EWB(DbSetOrder(1))
       If !Empty(cCodInst)
          If !(EWB->(Dbseek(xFilial("EWB")+ AllTrim(cCodInst))))
             Msg("Instrução Inválida. Informe uma instrução cadastrada!","Aviso")
             Break
          EndIf
       Else
          for nCont:= 1 to Len(aCols)
             If aCols[nCont][7]== .F. .and. !(EWB->(Dbseek(xFilial("EWB")+  AllTrim(aCols[nCont][2]))))
                Msg("Instrução Inválida. Informe uma instrução cadastrada!","Aviso")
                Break   
             EndIf
          Next
       EndIf */ 
    
       /* AOM - 05/03/2010 - Validando as instruções de acordo com os campos preenchidos da EXL(Carta Remessa),a
         condição verifica quando é clicado no botão "OK" da instrução ou quando é selecionada uma nova instrução.*/ 
       DbSelectArea("EXL")
       EXL->(DbSetOrder(1))   
       If EXL->(Dbseek(xFilial("EXL")+ AllTrim(aCols[1][1])))
          If Empty(cCodInst)          
             For nCont := 1 to Len(aCols)
                If aCols[nCont][Len(aCols[nCont])] == .T.
                   Loop
                EndIf
                If AllTrim(aCols[nCont][2]) == "01" .And. Empty(EXL->EXL_INSTJR)
	               Msg:= "Para instrução '(01)' é necessário o campo " + AVSX3("EXL_INSTJR",5) + " estar preenchido."
	               Msg+= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o conteudo do campo."  
	               MsgInfo(Msg) 
	               Msg:= ""
	               Break
	            EndIf 
	            If AllTrim(aCols[nCont][2]) == "08" .And. Empty(EXL->EXL_TPPROT) .And. Empty(EXL->EXL_PRZPRO)
	               Msg:= "Para instrução '(08)' são necessário alguns campos estarem preenchidos. "
	               Msg+= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o(s) campo(s) "
	               Msg+= +AVSX3("EXL_TPPROT",5) + ", "+AVSX3("EXL_PRZPRO",5) + "."   
	               MsgInfo(Msg) 
	               Msg:= ""
	               Break
	            EndIf
	            If AllTrim(aCols[nCont][2]) == "17" .And. Empty(EXL->EXL_VLRANT) 
	               Msg:= "Para instrução '(17)' é necessário o campo " + AVSX3("EXL_VLRANT",5) + " estar preenchido."  
	               Msg+= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o conteudo do campo. " 
	               MsgInfo(Msg) 
	               Msg:= ""
	               Break
	            EndIf
	            If AllTrim(aCols[nCont][2]) == "18" .And. Empty(EXL->EXL_VLRBCO) .And. Empty(EXL->EXL_BCONEG)
	               Msg:= "Para instrução '(08)' são necessário alguns campos estarem preenchidos. "
	               Msg:= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o(s) campo(s) "
	               Msg+= AVSX3("EXL_VLRBCO",5) + ", "+AVSX3("EXL_BCONEG",5)+ " se está(ão) preenchido(s)."  
	               MsgInfo(Msg) 
	               Msg:= ""
	               Break
	            EndIf
	            /* nopado por WFS em 29/07/10
	               será considerado a instrução da tabela EWC
	            If AllTrim(aCols[nCont][2]) == "999" .And. Empty(EXL->EXL_CINSTA) 
	               Msg:= "Para instrução '(999)' é necessário o campo " + AVSX3("EXL_CINSTA",5) + " estar preenchido."  
	               Msg+= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o conteudo do campo. " 
	               MsgInfo(Msg) 
	               Msg:= ""
	               Break
	            EndIf */
             Next
        
          Else

	         If AllTrim(M->EWC_CODINS) == "01" .And. Empty(EXL->EXL_INSTJR)
	            Msg:= "Para instrução '(01)' é necessário o campo " + AVSX3("EXL_INSTJR",5) + " estar preenchido."
	            Msg+= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o conteudo do campo."  
	            MsgInfo(Msg) 
	            Msg:= ""
	            Break
	         EndIf 
	         If AllTrim(M->EWC_CODINS) == "08" .And. Empty(EXL->EXL_TPPROT) .And. Empty(EXL->EXL_PRZPRO)
	            Msg:= "Para instrução '(08)' são necessário alguns campos estarem preenchidos. "
	            Msg+= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o(s) campo(s) "
	            Msg+= +AVSX3("EXL_TPPROT",5) + ", "+AVSX3("EXL_PRZPRO",5) + "."   
	            MsgInfo(Msg) 
	            Msg:= ""
	            Break
	         EndIf
	         If AllTrim(M->EWC_CODINS) == "17" .And. Empty(EXL->EXL_VLRANT) 
	            Msg:= "Para instrução '(17)' é necessário o campo " + AVSX3("EXL_VLRANT",5) + " estar preenchido."  
	            Msg+= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o conteudo do campo. " 
	            MsgInfo(Msg) 
	            Msg:= ""
	            Break
	         EndIf
	         If AllTrim(M->EWC_CODINS) == "18" .And. Empty(EXL->EXL_VLRBCO) .And. Empty(EXL->EXL_BCONEG)
	            Msg:= "Para instrução '(08)' são necessário alguns campos estarem preenchidos. "
	            Msg:= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o(s) campo(s) "
	            Msg+= AVSX3("EXL_VLRBCO",5) + ", "+AVSX3("EXL_BCONEG",5)+ " se está(ão) preenchido(s)."  
	            MsgInfo(Msg) 
	            Msg:= ""
	            Break
	         EndIf
	         /* nopado por WFS em 29/07/10
	            Será considerado as instruções da tabela EWC
	         If AllTrim(M->EWC_CODINS) == "999" .And. Empty(EXL->EXL_CINSTA) 
	               Msg:= "Para instrução '(999)' é necessário o campo " + AVSX3("EXL_CINSTA",5) + " estar preenchido."  
	               Msg+= "Verifique no Embarque a opção(Dados Complementares) na pasta Carta Remessa o conteudo do campo. " 
	               MsgInfo(Msg) 
	               Msg:= ""
	               Break
	         EndIf*/
     
             DbSelectArea("EWB")
             EWB->(DbSetOrder(1))
             If Empty(cCodInst) .or. !(EWB->(Dbseek(xFilial("EWB")+ AllTrim(cCodInst))))
                M->EWC_CODINS := Space(20)
                MsgInfo("Código de Instrução não cadastrado.","Aviso") 
                break
             End If
          EndIf
       EndIf
       lRet := .T.
       
    End Sequence
    
Return lRet

/*
Função    : MarcaEmb()
Objetivos : Verificar se existe se as validações de embarque e banco cobrador retorna algum valor para efetuar
            a marcação do processo para carta remessa.
Parametros: cMarca
Retorno   : lRet
Autor     : Allan Oliveira Monteiro 
Data      : 23/02/10
Revisão   : WFS 27/07/10
            Inclusão dos tratamentos de edição de dados adicionais (EXL) devido à
            alteração da chamada da rotina de carta remessa para o menu.
*/
Static Function MarcaEmb(cMarca)
Local cMsg, cMsgBco 
Local aImport := {}
Local lRet:= .F.

Begin Sequence
   
   //verifica se o processo está marcado
   cMarca  := IF(!Empty(WK_EEC->WK_FLAG),Space(2),cMarca)
   
   
   //Monta a mensagem para a validação da carta remessa no embarque
   //cMsg   := ValidEmb() nopado por WFS em 27/07/10
   
   //Monta a mensagem para validação do banco cobrador
   cMsgBco:= ValidBco(aImport)
   
   /* nopado por WFS em 27/07/10
   If !Empty(cMsg)
      MsgInfo(cMsg, "Aviso")
      Break 
   EndIf */
   
   If !Empty(cMsgBco)
      MsgInfo(cMsgBco, "Aviso")
      Break
   EndIf

   //Monta a mensagem para a validação da carta remessa no embarque
   cMsg:= ValidEmb()

   If !Empty(cMsg)
      lRet:= EditDadosCartaRemes(4)
   Else
      lRet:= .T.
   EndIf

   If lRet
      WK_EEC->WK_FLAG := cMarca
   EndIf

End Sequence

Return Nil 

/*
Função    : ValidEmb()
Objetivos : Verificar se os campos na opção 'Dados Complementares' da aba 'Carta Remessa' estão preenchidos 
            no Embarque.
Parametros: -
Retorno   : cMsg
Autor     : Allan Oliveira Monteiro 
Data      : 23/02/10
*/

Static Function ValidEmb()
   Local lRet := .T.
   Local cMsg := "", cMsgtit:= ""
   
   
   DbSelectArea("EXL")
   EXL->(DBSetOrder(1))
   EXL->(DbSeek(xFilial("EXL")+WK_EEC->EEC_PREEMB))
   
   cMsgtit := "Para o processo " + AllTrim(WK_EEC->EEC_PREEMB)
   cMsgtit += " existe(m) campo(s) obrigatório(s) não preenchido(s), necessários para a geração da carta remessa." + ENTER
   cMsgtit += "Clique no botão 'Editar' da barra de ferramentas para acessar o modo de edição ou "
   cMsgtit += "verifique o(s) seguinte(s) campo(s) na pasta 'Dados complementares' da manutenção do embarque: " + ENTER

   If Empty(EXL->EXL_TPREM)
      cMsg:= "Tipo Remessa"
      lRet:= .F.   
   EndIf
   
   If Empty(EXL->EXL_PRACA)
      If !Empty(cMsg)
         cMsg+= ", Cod. Praca"
      Else
         cMsg:= "Cod. Praca "
      EndIf
      lRet:= .F.
   EndIf 
   
   If Empty(EXL->EXL_TPVENC)
      If !Empty(cMsg)
         cMsg+= ", Tipo Venc."
      Else
         cMsg:= "Tipo Venc. "
      EndIf
      lRet:= .F.
   EndIf
   
   If Empty(EXL->EXL_DESPBR)
      If !Empty(cMsg)
         cMsg+= ", Desp. Brasil"
      Else
         cMsg:= "Desp. Brasil "
      EndIf
      lRet:= .F.
   EndIf 
   
   If Empty(EXL->EXL_DESPEX)
      If !Empty(cMsg)
         cMsg+= ", Desp. Ext."
      Else
         cMsg:= "Desp. Ext. "
      EndIf
      lRet:= .F.
   EndIf
   
   If Empty(EXL->EXL_CODCOU)
      If !Empty(cMsg)
         cMsg+= ", Cta. Courier"
      Else
         cMsg:= "Cta. Courier "
      EndIf
      lRet:= .F.
   EndIf
   
   If Empty(EXL->EXL_SLIPCO)
      If !Empty(cMsg)
         cMsg+= ", Cod. Slip"
      Else
         cMsg:= "Cod. Slip "
      EndIf
      lRet:= .F.
   EndIf
   
   If Empty(EXL->EXL_SLIPDT)
      If !Empty(cMsg)
         cMsg+= ", Dt.Env. Slip"
      Else
         cMsg:= "Dt.Env. Slip "
      EndIf
      lRet:= .F.
   EndIf
   
   If Empty(EXL->EXL_TENOR)
      If !Empty(cMsg)
         cMsg+= ", Vnc. a Partir"
      Else
         cMsg:= "Vnc. a Partir "
      EndIf
      lRet:= .F.
   EndIf
   
   cMsg := cMsgTit + cMsg

Return If(lRet, "", cMsg)  

/*
Função    : ValidBco(aImport)
Objetivos : Verificar se os campos na opção 'Informações complementares' no cadastro de 'Importadores' 
            estão preenchidos.
Parametros: aImport - Array onde é inserido os importadores, para não existir duplicidade na mensagem.
Retorno   : cMsgBco
Autor     : Allan Oliveira Monteiro 
Data      : 24/02/10
*/

Static Function ValidBco(aImport) 
   Local lRet := .T.
   Local cMsgBco := "", cMsgBcotit:= "" 
   Local nPos := 0 
   
   DbSelectArea("EEC")
   EEC->(DbSetOrder(1))
   EEC->(DbSeek(xFilial("EEC")+ WK_EEC->EEC_PREEMB))
   
   DbSelectArea("EWR")
   EWR->(DbSetOrder(1))
   EWR->(DbSeek(xFilial("EWR")+ EEC->EEC_IMPORT + EEC->EEC_IMLOJA))
   
   /*DbSelectArea("EXJ")
   EXJ->(DbSetOrder(1))
   EXJ->(DbSeek(xFilial("EXJ")+ EEC->EEC_IMPORT + EEC->EEC_IMLOJA)) */
   
   //Controle para verificar se já foi adicionado o mesmo importador
   nPos:= AScan(aImport,AllTrim(EEC->(EEC_IMPORT + EEC_PREEMB)))
   
   If nPos = 0
      
      //Adiciona o importador ao vetor caso não seja repetido
      AAdd(aImport, AllTrim(EEC->(EEC_IMPORT + EEC_PREEMB)))
   
      cMsgBcotit := "O importador " + AllTrim(WK_EEC->EEC_IMPODE) + " informado no processo " + AllTrim(WK_EEC->EEC_PREEMB)
      cMsgBcotit += " contém campo(s) não preenchido(s)." + ENTER 
      cMsgBcotit += "Verifique no cadastro do importador, opção 'informações complementares', " 
      cMsgBcotit += "os dados informados para o banco cobrador referente ao(s) campo(s): " + ENTER 
   
      If Empty(EWR->EWR_BCOCOB)//(EXJ->EXJ_BCOCOB)
         cMsgBco:= "Bco.Cobrador"
         lRet:= .F.
      EndIf
   
      If Empty(EWR->EWR_COBCOD)//(EXJ->EXJ_COBCOD)
         If !Empty(cMsgBco)
            cMsgBco+= ", CONGER Bco"
         Else
            cMsgBco:= "CONGER Bco"
         EndIf
         lRet:= .F.
      EndIf
   
      If Empty(EWR->EWR_COBDEP)//(EXJ->EXJ_COBDEP)
         If !Empty(cMsgBco)
            cMsgBco+= ", Dep.Bco.Cob."
         Else
            cMsgBco:= "Dep.Bco.Cob."
         EndIf
         lRet:= .F.
      EndIf 
   
      If Empty(EWR->EWR_COBEND)//(EXJ->EXJ_COBEND)
         If !Empty(cMsgBco)
            cMsgBco+= ", End.Bco.Cob."
         Else
            cMsgBco:= "End.Bco.Cob."
         EndIf
         lRet:= .F.
      EndIf 
   
      If Empty(EWR->EWR_COBCID)//(EXJ->EXJ_COBCID)
          If !Empty(cMsgBco)
             cMsgBco+= ", Cid.Bco.Cob."
          Else
             cMsgBco:= "Cid.Bco.Cob."
         EndIf
         lRet:= .F.
      EndIf 
   
      If Empty(EWR->EWR_COBPAI)//(EXJ->EXJ_COBPAI)
         If !Empty(cMsgBco)
            cMsgBco+= ", Pais.Bco.Cob"
         Else
            cMsgBco:= "Pais.Bco.Cob"
         EndIf
         lRet:= .F.
      EndIf  
   
      cMsgBco := cMsgBcoTit + cMsgBco 
   Else
      //Opção valida quando o importador esta em mais de um processo e já foi validado. 
      cMsgBco := "1"
      lRet    := .F.
   EndIf

Return If(lRet, "", cMsgBco)  

/*Function EIVALIDREM(cTpRem,cInstJr)
   Local lRet := .T.

   If AllTrim(cTpRem) == "COB" .And. Empty(cInstJr)
       MsgInfo("O tipo da Remessa é COB, portanto a instrução de Juros deve ser preenchida.","Aviso")
       lRet := .F.
   EndIf 
   

Return lRet*/


/*
Função    : EditDadosCartaRemes()
Objetivos : Habilitar a edição dos dados complementares (EXL) referente à carta remessa
Parametros: 
Retorno   : Lógico
Autor     : Wilsimar Fabrício da Silva
Data      : 27/07/10
*/

Static Function EditDadosCartaRemes(nOpcao)
Local aOrd:= SaveOrd({"EXL"}),;
      aCampos   := {},;
      aEditaveis:= {}
Local bOk    := {|| lRet:= GravaDados(), oDlgRem:End()},;
      bCancel:= {|| lRet:= .F., oDlgRem:End()}
Local cFolder:= "",;
      cAlias := "EXL",;
      cTitulo:= "Dados complementares - Carta Remessa",;
      cCampo := ""
Local lRet    := .F.,;
      lMemoria:= .T.
Local nRecNo,;
      nPos
Local oDlgRem   
Local aPos
Local i

Begin Sequence

   EXL->(DBSetOrder(1)) //EXL_FILIAL + EXL_PREEMB
   EXL->(DBSeek(xFilial() + WK_EEC->EEC_PREEMB))
   nRecNo:= EXL->(RecNo())

   //Verifica qual a folder definida para os campos utilizados na rotina de carta remessa
   SX3->(DBSetOrder(2)) //X3_CAMPO
   SX3->(DBSeek("EXL_TPREM"))
   cFolder:= SX3->X3_FOLDER

   //Criação do array com os dados que serão exibidos na MsmGet
   SX3->(DBSetOrder(1)) //X3_ARQUIVO + X3_ORDEM
   SX3->(DBSeek("EXL"))

   
   // DFS / WFS - 14/05/12 - O objeto MsmGet adiciona os campos de usuário automaticamente. Com o tratamento abaixo, os campos de usuário deixam de ser adicionados 
   // automaticamente e serão adicionados apenas os campos de usuário que se adequarem as condições de montagem do array aCampos (X3_FOLDER = cFolder)
   cCampo:= "NOUSER"
   AAdd(aCampos, cCampo)

   While SX3->(!Eof()) .And. SX3->(X3_ARQUIVO) == cAlias

      If SX3->X3_FOLDER == cFolder .And. X3Uso(SX3->X3_USADO)

         cCampo:= SX3->X3_CAMPO

         //Campos que serão visualizados
         AAdd(aCampos, cCampo)

         //Campos que serão editados
         If  cNivel >= SX3->X3_NIVEL
            AAdd(aEditaveis, cCampo)
         EndIf

         //Variáveis de memória
         If SX3->X3_CONTEXT = "V"
            M->&(cCampo):= CriaVar(cCampo)
         Else
            nPos:= (cAlias)->(FieldPos(cCampo))
            If nPos > 0
               M->&(cCampo):= (cAlias)->(FieldGet(nPos))
            EndIf
         EndIf
      EndIf
   
      SX3->(DBSkip())
   EndDo
   
   //AOM - 05/04/2012 - Carregar o Embarque
   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(xFilial("EEC") + WK_EEC->EEC_PREEMB))
      For i := 1 to EEC->(FCount())
         M->&(EEC->(FieldName(i))) := EEC->&( FieldName(i) )
      Next i
   EndIf
   
   Define MsDialog oDlgRem Title cTitulo From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM Of oMainWnd Pixel
   aPos := PosDlg(oDlg)

      MsmGet():New(cAlias,;
                   nRecNo,;
                   nOpcao,;
                /*uPar1*/,;
                /*uPar2*/,;
                /*uPar3*/,;
                  aCampos,;
                     aPos,;
               aEditaveis,;
                /*uPar4*/,;
                /*uPar5*/,;
                /*uPar6*/,;
                /*uPar7*/,;
                  oDlgRem,;
                /*uPar8*/,;
                 lMemoria,;
              /*lColuna*/,;
                /*uPar9*/,;
            /*lSemPastas*/)

   Activate MsDialog oDlgRem Centered On Init EnchoiceBar(oDlgRem, bOk, bCancel)

End Sequence
Return lRet

/*
Função    : GravaDados()
Objetivos : Gravação dos dados adicionais da carta de remessa (EXL)
Parametros: 
Retorno   : 
Autor     : Wilsimar Fabrício da Silva
Data      : 27/07/10
*/

Static Function GravaDados()
Local cMsg:= ""
Local lRet:= .F.

Begin Sequence

   //Atualiza base de dados
   EXL->(RecLock("EXL", .F.))
   AvReplace("M", "EXL")
   EXL->(MsUnlock())


   //Monta a mensagem para a validação da carta remessa
   cMsg:= ValidEmb()
   If !Empty(cMsg)
      MsgInfo(cMsg, "Aviso")
      lRet:= .F.
   Else
      lRet:= .T.
   EndIf
   
End Sequence
Return lRet


/*
Função    : EI200Instrucao()
Objetivos : Exibir as instruções cadastradas para o processo
Parametros: 
Retorno   : 
Autor     : Wilsimar Fabrício da Silva
Data      : 29/07/10
*/

Function EI200Instrucao()
Local cRet := ""
Local cPreemb:= ""

Begin Sequence

   If Select("WK_EEC") > 0
      cPreemb:= WK_EEC->EEC_PREEMB
   Else
      cPreemb:= M->EEC_PREEMB
   EndIf
   
   If EWC->(DBSeek(xFilial() + cPreemb))
      While EWC->(!Eof()) .And.;
            EWC->(EWC_FILIAL + EWC_PREEMB) == EWC->(xFilial()) + cPreemb

         cRet += AllTrim(EWC->EWC_CODINS) + " - " + AllTrim(EWC->EWC_DESCRI) + ENTER

         EWC->(DbSkip())
      EndDo
   EndIf

End Sequence
Return cRet 



/*
Função    : EditConfigs()
Objetivos : Configura o Diretório de importação dos Arquivos de Retorno da Carta Remassa
Parametros: 
Retorno   : 
Autor     : Allan Oliveira Monteiro
Data      : 16/02/2010
*/
*----------------------------*
Static Function EditConfigs()
*----------------------------* 

Local nLin := 15, nCol := 12
Local lRet := .F.
Local bOk := {|| lRet := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local oDlg
Local cDir := oUserParams:LoadParam("DIRLOCAL", "c:\CARTAREMESSA\")
Local cTitulo := "Configurações para o usuário: " + cUserName
Local bChooseFile := {|| cDir := cGetFile("","Diretório local para importação de arquivos de lote", 0, cDir,, GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) }

   SetKey(VK_F3, bChooseFile)

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 330,360 TO 455,760 OF oMainWnd PIXEL

    @ nLin, 6 To 58, 182 Label "Preferências" Of oDlg Pixel
    nLin += 10
	@ nLin,nCol Say "Diretório local para importação de arquivos" Size 160,08 PIXEL OF oDlg
    nLin += 10
	@ nLin,nCol MsGet cDir Size 150,08 PIXEL OF oDlg
	@ nLin,nCol+150 BUTTON "..." ACTION Eval(bChooseFile) SIZE 10,10 PIXEL OF oDlg

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   SetKey(VK_F3, Nil)   

   If lRet
      oUserParams:SetParam("DIRLOCAL", cDir)
   EndIf

Return Nil



/*
Função    : RetArquivo()
Objetivos : Importa o arquivo de carta remessa indicando o status do Itau Bank Line
Parametros: 
Retorno   : 
Autor     : Allan Oliveira Monteiro
Data      : 16/02/2010
*/
*---------------------------*
Static Function RetArquivo()
*---------------------------* 
Local lRet := .T. , i, j
Local cDir := oUserParams:LoadParam("DIRLOCAL", "c:\CARTAREMESSA\")
Local cDirServE := "", cDirServA := ""
Local aFiles := {}, aDados := {} , aOrd := SaveOrd("EW9")
Local nCampo , nPos
Local cLine , cStatusArq := "AUTORIZADA" , cNomeArq := "" , cMsg := "", cMsgConf := ""


lRet := MsgYesNo("Deseja enviar arquivos de remessa para aprovação?", "Aviso")


If lRet    


     //Preenche diretórios para copiar arquivo                  
     cDirServE := "\comex\itau\enviados\"                   
     cDirServA := "\comex\itau\aprovados\"
     
     //Adiciona todos os arquivos txt do diretório no array
     aFiles := Directory(cDir + "*.txt")
     
     //Regua
     ProcRegua(Len(aFiles)) 
     
     
     If Empty(aFiles)
        MsgInfo("Não foi encontrado nenhum arquivo txt compativel")
        Return lRet
     EndIf
     
     /*Adiciona os dados do arquivo txt no array "aDados" 
       aDados[i][1] := Status de retorno para verificar se a remessa foi AUTORIZADA
       aDados[i][2] := Nr do Controle que no caso é a referencia do Banco
       aDados[i][3] := Referencia do Cliente */
     For i:= 1 to Len(aFiles)
     
        FT_FUSE(cDir+aFiles[i][1])
        FT_FGOTOP()
        cLine := "" 
   
        While !FT_FEOF()
           nCampo := 1
      
	       cLine := AllTrim(StrTran(FT_FReadLn(),CHR(9),""))
      
           If !Empty(cLine)
           aAdd(aDados, {})
              While (nPos := At(";", cLine)) > 0  //separador dos dados do arquivo
                 aAdd(aDados[Len(aDados)], Left(cLine, nPos - 1))
                 cLine := SubStr(cLine, nPos + 1)
                 If nCampo > 2
                    Exit
                 EndIf            
                 nCampo++
              EndDo
	       EndIf
	       
	    FT_FSKIP()
        EndDo
        FT_FUSE()
        
        
        /*Relaciona os dados do arquivo txt com os dados da Remessa (EW9) 
          se o numero de controle do arquivo for o mesmo que o da remessa e 
          o Status estiver como AUTORIZADO o arquivo é movida para pasta APROVADOS*/
        For j:= 1 To Len(aDados)
           If Empty(aDados[j])
              lRet := .F.
              MsgInfo("Arquivo txt invalido.")
              Exit
           EndIf
	       EW9->(DbGotop())
	       EW9->(DbSetOrder(3))
	       If EW9->(DbSeek(xFilial("EW9")+AvKey(aDados[j][2],"EW9_NCONTR")))
	          cNomeArq := EW9->EW9_FILE
	          While EW9->(!EOF()) .And. EW9->EW9_FILIAL == xFilial("EW9") .And. AllTrim(EW9->EW9_NCONTR) ==  AllTrim(aDados[j][2])
	                
	             //Verifica se o arquivo está enviado
	             If EW9->EW9_STATUS <> "E"
	                EW9->(DBSKIP())
	                Loop  
	             EndIf
	                
	                
	             //Verifica o Status, se Estiver aprovado altera o Status do arquivo
	             If UPPER(aDados[j][1]) == cStatusArq 
	                AlteraEW9(3, aDados[j][2], cNomeArq)
	                cMsgConf += "O arquivo xml: " + AllTrim(cNomeArq) + " foi autorizado." + ENTER
	             Else
	                lRet := .F.
	                cMsg += "No arquivo: " + AllTrim(aFiles[i][1]) + " o numero do Controle: " + AllTrim(aDados[j][2]) 
	                cMsg += " não está autorizado para o embarque: " +  AllTrim(EW9->EW9_PREEMB) + " do arquivo xml: " + AllTrim(cNomeArq) + "." + ENTER + ENTER
	             EndIf
	          EW9->(DBSKIP())   
	          EndDo
	           
	          If lRet 
	             If CopiaArq(cNomeArq, cDirServE, cDirServA)
	                ExcluiArquivo(cNomeArq, cDirServE)
	             EndIf 
	          EndIf
	       Else
	          lRet := .F.
	          cMsg += "No arquivo: " + AllTrim(aFiles[i][1]) + " para numero do Controle: " + AllTrim(aDados[j][2])
	          cMsg += " nao existe(m) embarque(s) enviados relacionados." + ENTER + ENTER   
	       EndIf        
	    Next j
	       
	    If Len(aDados) == 0
	       lRet := .F.
	       cMsg += "O arquivo: " + AllTrim(aFiles[i][1]) + " está vazio."
	    EndIf
	       
	    If !lRet
	       If !(FRename(cDir + aFiles[i][1], cDir + aFiles[i][1] + ".err") == 0)
             MsgInfo("Não foi possível renomear o arquivo "+AllTrim(aFiles[i][1])+" para "+aFiles[i][1]+".err")
           EndIf
	       lRet := .T.
	    Else
	       If !(FRename(cDir + aFiles[i][1], cDir + aFiles[i][1] + ".ok") == 0)
             MsgInfo("Não foi possível renomear o arquivo "+AllTrim(aFiles[i][1])+" para "+aFiles[i][1]+".ok")
           EndIf
	    EndIf
        
     Next i
     
     
     If !Empty(cMsg)
        EECVIEW(cMsg,"Mensagens de erro no retorno!")    
     EndIf
     
     If !Empty(cMsgConf)
        EECVIEW(cMsgConf,"Autorização de Remessa!") 
     EndIF 
     
EndIf
     
RestOrd(aOrd,.T.)     

Return lRet 



/*
Função    : ValNrControle()
Objetivos : Verifica se o numero de controle já esta associado para outro arquivo xml
Parametros: 
Retorno   : 
Autor     : Allan Oliveira Monteiro
Data      : 18/02/2010
*/
*-------------------------------------------*
Static Function ValNrControle(cGetNControle)
*-------------------------------------------*
Local lRet := .T.
Local aOrd := SaveOrd("EW9") 

DbSelectArea("EW9")
EW9->(DbGotop())
EW9->(DbSetOrder(3))
If EW9->(DbSeek(xFilial("EW9")+AvKey(cGetNControle,"EW9_NCONTR")))
   If EW9_STATUS <> "R"
      lRet := .F.
      MsgInfo("O numero de Controle: "+ Alltrim(cGetNControle) + " já esta cadastrado para o arquivo xml: " + AllTrim(EW9->EW9_FILE))
   EndIf
EndIf

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 10/10/2014 - 14:16
Obs        : Modificada por NCF - 23/07/2018
*/

*-------------------------------------------*
Static Function MenuDef(cOrigem, lMBrowse)
*-------------------------------------------*
Local aRotina :=  {}
Default cOrigem  := AvMnuFnc()
Default lMBrowse := OrigChamada()

Do Case
   Case cOrigem == "EI200INTIT"   
     
      aAdd(aRotina,{ "Pesquisar"   ,"AxPesqui"  , 0 , 1  })
      aAdd(aRotina,{ "Visualizar"  ,"AxVisual"  , 0 , 2  })
      aAdd(aRotina,{ "Incluir"     ,"AxInclui"  , 0 , 3  })
      aAdd(aRotina,{ "Alterar"     ,"AxAltera"  , 0 , 4  })
      aAdd(aRotina,{ "Excluir"     ,"AxDeleta"  , 0 , 5  })

   Case cOrigem == "SELECDOCS"
   
      aAdd(aRotina, {"Pesquisar", "AxPesqui", 0, 1})
      aAdd(aRotina, {"Visualizar","AxVisual", 0, 2})
      aAdd(aRotina, {"Incluir",   ""        , 0, 3})
      aAdd(aRotina, {"Alterar",   ""        , 0, 4})
      aAdd(aRotina, {"Excluir",   "AxDeleta", 0, 5})
      
   Case cOrigem == "SELECINSTR"
   
      aAdd(aRotina, {"Pesquisar", "AxPesqui", 0, 1})
      aAdd(aRotina, {"Visualizar","AxVisual", 0, 2})
      aAdd(aRotina, {"Incluir",   ""        , 0, 3})
      aAdd(aRotina, {"Alterar",   ""        , 0, 4})
      aAdd(aRotina, {"Excluir",   "AxDeleta", 0, 5})
      
   Case cOrigem == "EI200CADIN"
   
      aAdd(aRotina,{ "Pesquisar"   ,"AxPesqui"  , 0 , 1  })
      aAdd(aRotina,{ "Visualizar"  ,"AxVisual"  , 0 , 2  })
      aAdd(aRotina,{ "Incluir"     ,"AxInclui"  , 0 , 3  })
      aAdd(aRotina,{ "Alterar"     ,"AxAltera"  , 0 , 4  })
      aAdd(aRotina,{ "Excluir"     ,"AxDeleta"  , 0 , 5  })
    
   Case cOrigem == "EI200INTIT"
   
      aAdd(aRotina, {"Incluir", "EI200INTIT", 0, 3   }) //"Incluir"
             	  	
EndCase

	// P.E. utilizado para adicionar itens no Menu da mBrowse
	If EasyEntryPoint("EECEI200MNU")
		aRotAdic := ExecBlock("EECEI200MNU",.f.,.f.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf


Return aRotina
