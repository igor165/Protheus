#INCLUDE "PROTHEUS.CH"
#INCLUDE "AVERAGE.CH"                                                                                                                         
#INCLUDE "APWIZARD.CH"  
#INCLUDE "TOPCONN.CH"  
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOTVS.CH"

#DEFINE AQUISICAO  "A" 
#DEFINE VENDA      "V"

#Define NAO_ENVIADO	"N"
#Define ENVIADO		"E"
#Define RECEBIDO	"R"
#Define PROCESSADO	"P"
#Define CANCELADO	"C"

#DEFINE EXT_ZIP    ".zip"
#DEFINE EXT_INI    ".ini"
#DEFINE EXT_RET    ".ret"

#Define INC_REG    "1" //1=Inclusão Registro
#Define RET_REG	   "2" //2=Retificação de Registro
#Define INC_ADI    "3" //3=Inclusão Aditivo
#Define RET_ADI    "4" //4=Retificação Aditivo
#Define INC_PAG    "5" //5=Inclusão Pagamento
#Define CAN_PAG    "6" //6=Cancel. Pagamento
#Define RET_PAG    "7" //7=Retificação Pagamento

#Define ARQ_REPROC_V "essci101_v.lck"
#Define ARQ_REPROC_A "essci101_a.lck"

#Define ENTER CHR(13)+CHR(10)

Static nHdlLock := 0

/*
Funcao     : SS101GerLote()
Parametros : cTpServ - "A"  = Aquisição
                       "V"  = Venda
             cTpOpe  - INC_REG - "1" = Registro de Aquisição de Serviço (RAS) / Registro de Venda de Serviço (RVS)
                       RET_REG - "2" = Retificação de Aquisição de Serviço (Retificação RAS) / Retificação de Venda de Serviço (Retificação RVS)
                       INC_ADI - "3" = Aditivo ao Registro de Aquisição de Serviço (Aditivo RAS) / Aditivo ao Registro de Venda de Serviço (Aditivo RVS)
                       RET_ADI - "4" = Retificação de Aditivo de Aquisição de Serviço (Retificação RAS) / Retificação de Aditivo de Venda de Serviço (Retificação RVS)
                       INC_PAG - "5" = Registro de Pagamento de Serviço (RP) / Registro de Faturamento de Serviço (RF)
                       CAN_PAG - "6" = Cancelamento de Pagamento de Serviço (Cancelamento RP) / Cancelamento de Faturamento de Serviço (Cancelamento RF)
Retorno    : lRet
Objetivos  : Efetuar a geração dos Lotes SISCOSERV para que possa ser gerado o XML para envio
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 29/08/12 - 14:44
*/

*----------------------------------------*
Function SS101GerLote(cTpServ,cTpOpe)
*----------------------------------------*
Local oPanel, oWizard
Local lRet          := .F.
Local lGera         := .F. 
Local cTitulo       := "", cTexto := ""
//Local bCancel       := {|| CloseTables(), oWizard:oDlg:End() } //RMD - 11/04/17 - Na versão 12, precisa informar o Modal e o Owner
Local bCancel       := {|| CloseTables(), oWizard:oModal:oOwner:End()() }
Local bValidCancel  := {|| If(MsgYesNo("Confirma o cancelamento?", "Aviso"),Eval(bCancel) , .F.)   }
Local aBlockAction  := {}
Local oError        := AvObject():New()

Private cTipoServ   := cTpServ
Private cTipoOpe    := cTpOpe
Private aItens		:= {} //Array com os serviços selecionados para gerar Lote.
Private cNroLote    := ""
Private lBrwAtivo   := .F.
Private nRegs := 0

If IsFileLock(cTpServ)
   EasyHelp("Não é possível utilizar esta funcionalidade pois existe um reprocessamento pendente.","Aviso")
   Return lRet 
EndIf

If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EasyGParam("MV_ESS0028",,2) == 1  .AND.;
   !MsgNoYes("O sistema está configurado para integração com a Base de Testes do Portal do Siscoserv." + ENTER +;
            "Qualquer integração para a Base de Testes não terá qualquer efeito legal e não deve ser utilizada em um ambiente de produção." + ENTER +;
            "Para integrar com a Base Oficial (Produção) do Portal do Siscoserv, altere o parâmetro 'MV_ESS0028' para 2." + ENTER +;
            "Deseja prosseguir?","Aviso")  // GFP - 09/06/2016
   Return .F.
EndIf

If cTipoServ == AQUISICAO 

  Do Case
  
     Case cTipoOpe == INC_REG                                                                                                                                       
        cTitulo := "Registro de Aquisição de Serviço (RAS)" 
     Case cTipoOpe == RET_REG
        cTitulo := "Retificação de Aquisição de Serviço (Retificação RAS)"
     Case cTipoOpe == INC_ADI
        cTitulo := "Aditivo ao Registro de Aquisição de Serviço (Aditivo RAS)"
     Case cTipoOpe == RET_ADI
        cTitulo := "Retificação de Aditivo de Aquisição de Serviço (Retificação RAS)"
     Case cTipoOpe == INC_PAG
        cTitulo := "Registro de Pagamento de Serviço (RP)"
     Case cTipoOpe == CAN_PAG
        cTitulo := "Cancelamento de Pagamento de Serviço (Cancelamento RP)"   
     Case cTipoOpe == RET_PAG
        cTitulo := "Retificação de Pagamento de Serviço (RP)"
  
  End Case
  
  
ElseIf cTipoServ == VENDA


  Do Case
  
     Case cTipoOpe == INC_REG
        cTitulo := "Registro de Venda de Serviço (RVS)"
     Case cTipoOpe == RET_REG
        cTitulo := "Retificação de Venda de Serviço (Retificação RVS)"
     Case cTipoOpe == INC_ADI
        cTitulo := "Aditivo ao Registro de Venda de Serviço (Aditivo RVS)"
     Case cTipoOpe == RET_ADI
        cTitulo := "Retificação de Aditivo de Venda de Serviço (Retificação RVS)"
     Case cTipoOpe == INC_PAG
        cTitulo := "Registro de Faturamento de Serviço (RF)"
     Case cTipoOpe == CAN_PAG
        cTitulo := "Cancelamento de Faturamento de Serviço (Cancelamento RF)"
     Case cTipoOpe == RET_PAG
        cTitulo := "Retificação de Faturamento de Serviço (RF)"
          
  End Case

EndIF

cWiz_Title   := "Wizard de geração de Lotes"
cWiz_Header  := "Início"
cWiz_Message := "Apresentação"
cWiz_Text    := "Bem vindo ao assistente de Geração de Lotes, essa rotina é utilizada para auxiliá-lo na operação de " + cTitulo + " que tem como objetivo a geração de arquivos para integração com SISCOSERV."
                      //PanelName,Valid. Back  , Valid. Next                           ,Valid. Finish
aAdd( aBlockAction , {"USER_PN0" ,{||.F.}      ,{|| SS101SelServ(oWizard:OMPANEL[2])/*SS101SelLote(oWizard:OMPANEL[2])*/}  , {||.T.}               })
aAdd( aBlockAction , {"USER_PN1" ,{||.T.}      ,{|| Len(aItens) > 0 }                  , {||.T.}               })  
aAdd( aBlockAction , {"USER_PN2" ,{||.T.}      ,{||.T.}                                , {|| SS101Lote(oError)}      })

DEFINE WIZARD oWizard TITLE   cWiz_Title;
                         HEADER  cWiz_Header;
                         MESSAGE cWiz_Message;
                         TEXT    cWiz_Text;
                         PANEL   ;
                         NEXT    {|| PanelNext( oWizard,aBlockAction[1] )};
                         FINISH  aBlockAction[1][4]
   oPanel  := oWizard:oMPanel[Len(oWizard:oMPanel)]
   oPanel:cName := aBlockAction[1][1]//"USER_PN0"
                            
   CREATE PANEL oWizard HEADER "Seleção de Serviços"  ;
                        MESSAGE cTitulo;
						PANEL;
						BACK	{|| PanelBack(oWizard,aBlockAction[2]) };
						NEXT	{|| PanelNext(oWizard,aBlockAction[2]) };     
						FINISH aBlockAction[2][4];                        
						EXEC	{|| .T. }
      oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
      oPanel:cName := aBlockAction[2][1]
   
   CREATE PANEL oWizard HEADER "Geração dos Lotes"  ;
                        MESSAGE cTitulo;
						PANEL;
						BACK	{|| PanelNext(oWizard,aBlockAction[3]) }; //RRC - 28/08/2013 - Evita que ao clicar em "Voltar" seja gerado o lote
						NEXT	{|| PanelNext(oWizard,aBlockAction[3]) };     
						FINISH aBlockAction[3][4];                        
						EXEC	{|| .T. }
      oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
      oPanel:cName := aBlockAction[3][1]
      oSay1 := TSay():New ( 20, 10, {||'Clique no botão FINALIZAR para que o lote do(s) serviço(s) selecionado(s) seja(m) gerado(s)!'}, oPanel, , oWizard:oHeaderMsg:oFont, , , , .T., CLR_BLUE, CLR_WHITE, 200, 100, , , , , ,  )         
      
    
   oWizard:oCancel:bAction := bValidCancel
   oWizard:oDlg:Owner():lEscClose:= .F.         

ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

Return lRet 

*-----------------------------------------------*
Function SS101EnvLote(cTpServ, cTpOpe, cNroLote)
*-----------------------------------------------*
Local oPanel, oWizard 
Local lRet          := .F.
Local cTitulo       := ""
//Local bCancel       := {|| CloseTables(), oWizard:oDlg:End() } //RMD - 11/04/17 - Na versão 12, precisa informar o Modal e o Owner
Local bCancel       := {|| CloseTables(), oWizard:oModal:oOwner:End()() }
Local bValidCancel  := {|| If(!lEnvio .And. MsgYesNo("Confirma o cancelamento?", "Aviso"),Eval(bCancel) , If(lEnvio,MsgInfo("A ação é inválida pois o envio foi realizado, é necessário finalizar e efetuar o processamento. Em caso de erro na integração, um novo lote poderá ser gerado."),.F.))} //RRC - 26/08/2013 - Só cancela se não enviou o lote
Local aBlockAction  := {}
Local oError        := AvObject():New()
Local lNext         := .F.
Local lEnvio        := .F.     
Private aRetArqs    := {}

If IsFileLock(cTpServ)
   EasyHelp("Não é possível utilizar esta funcionalidade pois existe um reprocessamento pendente.")
   Return lRet 
EndIf

If !SS101ValAcao("ENVIAR", cTpServ, cTpOpe, cNroLote)
   Return lRet
EndIf

If cTpServ == AQUISICAO 

  Do Case
  
     Case cTpOpe == INC_REG
        cTitulo := "Registro de Aquisição de Serviço (RAS)" 
     Case cTpOpe == RET_REG
        cTitulo := "Retificação de Aquisição de Serviço (Retificação RAS)"
     Case cTpOpe == INC_ADI
        cTitulo := "Aditivo ao Registro de Aquisição de Serviço (Aditivo RAS)"
     Case cTpOpe == RET_ADI
        cTitulo := "Retificação de Aditivo de Aquisição de Serviço (Retificação RAS)"
     Case cTpOpe == INC_PAG
        cTitulo := "Registro de Pagamento de Serviço (RP)"
     Case cTpOpe == CAN_PAG
        cTitulo := "Cancelamento de Pagamento de Serviço (Cancelamento RP)"  
     Case cTpOpe == RET_PAG
        cTitulo := "Retificação de Pagamento de Serviço (RP)"
  
  End Case
  
  
ElseIf cTpServ == VENDA


  Do Case
  
     Case cTpOpe == INC_REG
        cTitulo := "Registro de Venda de Serviço (RVS)"
     Case cTpOpe == RET_REG
        cTitulo := "Retificação de Venda de Serviço (Retificação RVS)"
     Case cTpOpe == INC_ADI
        cTitulo := "Aditivo ao Registro de Venda de Serviço (Aditivo RVS)"
     Case cTpOpe == RET_ADI
        cTitulo := "Retificação de Aditivo de Venda de Serviço (Retificação RVS)"
     Case cTpOpe == INC_PAG
        cTitulo := "Registro de Faturamento de Serviço (RF)"
     Case cTpOpe == CAN_PAG
        cTitulo := "Cancelamento de Faturamento de Serviço (Cancelamento RF)"
     Case cTpOpe == RET_PAG
        cTitulo := "Retificação de Faturamento de Serviço (RF)"
          
  End Case

EndIF

cWiz_Title   := "Wizard de Integração SISCOSERV"
cWiz_Header  := "Início"
cWiz_Message := "Apresentação"
cWiz_Text    := "Bem vindo ao assistente de Integração com o SISCOSERV, essa rotina é utilizada para auxiliá-lo na integração de " +;
                cTitulo + " que tem como objetivo registrar as informações no SISCOSERV. Clique no botão AVANCAR para que os "+;
                "arquivos sejam preparados para o envio ao Siscoserv"

If EasyGParam("MV_AVG0221",,"INI") == "INI"
   
                        //PanelName ,Vld. Back , Vld. Next                                                                   ,Vld. Fin 
   aAdd( aBlockAction , {"USER_PN0" ,{||.F.}   , {|| .T.}                                                                    , {||.T.}       })
   aAdd( aBlockAction , {"USER_PN1" ,{||.T.}   , {|| SS101PrepArq(cTpOpe,cNroLote,oError)}                                   , {||.T.}       })  
   aAdd( aBlockAction , {"USER_PN2" ,{||.T.}   , {|| SS101ExecInt(cTpOpe,cNroLote,oError),SS103FinalInteg(cTpServ,cTpOpe,cNroLote,ESSCI100:cDirRecebidos,oError),lEnvio := .T.}                                   , {||.T.}       })
   //RRC - 22/08/2013 - Retirada última tela do wizard para que o sistema grave o arquivo de retorno mesmo que alguns  processos do lote não sejam registrados
   //aAdd( aBlockAction , {"USER_PN3" ,{||.T.}   , {|| SS103FinalInteg(cTpServ,cTpOpe,cNroLote,ESSCI100:cDirRecebidos,oError)}, {||.T.}       }) 
   //aAdd( aBlockAction , {"USER_PN4" ,{||.T.}   , {|| .T.}                                                                    , {||.T.}       }) 
   aAdd( aBlockAction , {"USER_PN3" ,{||.T.}   , {|| .T.}                                                                    , {||.T.}       }) 

   DEFINE WIZARD oWizard TITLE   cWiz_Title;
                         HEADER  cWiz_Header;
                         MESSAGE cWiz_Message;
                         TEXT    cWiz_Text;
                         PANEL   ;
                         NEXT    {|| PanelNext( oWizard,aBlockAction[1] )};
                         FINISH  aBlockAction[1][4]
      oPanel  := oWizard:oMPanel[Len(oWizard:oMPanel)]
      oPanel:cName := aBlockAction[1][1]//"USER_PN0"
   
      CREATE PANEL oWizard HEADER "Preparacao dos Arquivos"  ;
                           MESSAGE cTitulo;
		   					PANEL;
							BACK	{|| PanelBack(oWizard,aBlockAction[2]) };
							NEXT	{|| PanelNext(oWizard,aBlockAction[2]) };     
							FINISH aBlockAction[2][4];                        
							EXEC	{|| .T. }  
						
         oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
         oPanel:cName := aBlockAction[2][1]         
         oSay1 := TSay():New ( 20, 10, {||'Clique no botão AVANÇAR para que os arquivos sejam gerados para envio ao Siscoserv.'}, oPanel, , oWizard:oHeaderMsg:oFont, , , , .T., CLR_BLUE, CLR_WHITE, 200, 100, , , , , ,  )         
   
      CREATE PANEL oWizard HEADER "Envio ao Siscoserv"  ;
      	                  MESSAGE cTitulo;
							PANEL;
							BACK	{|| PanelBack(oWizard,aBlockAction[3]) };
							NEXT	{|| PanelNext(oWizard,aBlockAction[3]) };     
							FINISH aBlockAction[3][4];                        
							EXEC	{|| .T. }
	
         oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
         oPanel:cName := aBlockAction[3][1]         
         oSay2 := TSay():New ( 20, 10, {||'Clique no botão AVANÇAR para que a Integração seja efetuada.'}, oPanel, , oWizard:oHeaderMsg:oFont, , , , .T., CLR_BLUE, CLR_WHITE, 200, 100, , , , , ,  )         
        
        //NOPADO por RRC - 22/08/2013 - Retirada última tela do wizard para que o sistema grave o arquivo de retorno mesmo que alguns  processos do lote não sejam registrados
        /*CREATE PANEL oWizard HEADER "Log da Integração"  ;
    	                    MESSAGE cTitulo;
							PANEL;
							BACK	{|| PanelBack(oWizard,aBlockAction[4]) };
							NEXT	{|| PanelNext(oWizard,aBlockAction[4]) };     
							FINISH aBlockAction[4][4];                        
							EXEC	{|| .T. }
						
         oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
         oPanel:cName := aBlockAction[4][1]         
         oSay3 := TSay():New ( 20, 10, {||oError:GetStrErrors(oError:aError)+ENTER+"Clique no botão AVANÇAR para finalizar a integração" }, oPanel, , oWizard:oHeaderMsg:oFont, , , , .T., CLR_BLUE, CLR_WHITE, 200, 100, , , , , ,  )         
         */
      CREATE PANEL oWizard HEADER "Finalização"  ;
                           MESSAGE cTitulo;
	   						PANEL;
	   					   	BACK	{|| MsgInfo("A ação é inválida pois o envio foi realizado, é necessário finalizar e realizar o processamento. Em caso de erro na integração, um novo lote poderá ser gerado."),.F.}; //RRC - 26/08/2013 - Impede que o usuário clique em "Voltar" pois o envio já foi realizado
							NEXT	{|| PanelNext(oWizard,aBlockAction[4]) };     
							FINISH aBlockAction[4][4];                        
							EXEC	{|| .T. }
							
         oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
         oPanel:cName := aBlockAction[4][1]
         oSay3 := TSay():New ( 20, 10, {|| SS101GetLogEnd(ENVIADO,oError) }, oPanel, , oWizard:oHeaderMsg:oFont, , , , .T., CLR_BLUE, CLR_WHITE, 200, 100, , , , , ,  )         


      oWizard:oCancel:bAction := bValidCancel
      oWizard:oDlg:Owner():lEscClose:= .F.         

   ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }
Else
   cArqSrv := ESSCI100:cDirGerados+cNroLote+EXT_ZIP
   cDirTmp := GetTempPath(.T.) + "SISCOSERV\" + cNroLote + "\"
   cFile   := cDirTmp + cNroLote + EXT_ZIP
   
   lRet := .F.
   
   Begin Sequence
   
   If !lIsDir(GetTempPath(.T.) + "SISCOSERV\") .And. !(MakeDir(GetTempPath(.T.) + "SISCOSERV\") == 0)
      oError:Error( StrTran("Erro ao criar o diretório '###'.", "###", GetTempPath(.T.) + "SISCOSERV\"),.F.)
      lRet := .F.
      Break
   EndIf   
   
   If !lIsDir(GetTempPath(.T.) + "SISCOSERV\" + cNroLote + "\") .And. !(MakeDir(GetTempPath(.T.) + "SISCOSERV\" + cNroLote + "\") == 0)
      oError:Error( StrTran("Erro ao criar o diretório '###'.", "###", GetTempPath(.T.) + "SISCOSERV\" + cNroLote + "\"),.F.)
      lRet := .F.
      Break
   EndIf
   
   If !File(cArqSrv)
      MsgInfo(StrTran("O arquivo '###' não foi encontrado. Não será possível executar a rotina de envio.", "###", cArqSrv), "Aviso")
      Break
   EndIf
   
   If !CpyS2T(cArqSrv, cDirTmp, .T.)
      MsgInfo(StrTran("Erro ao copiar o arquivo '###' para o diretório temporário. Não será possível prosseguir.", "###", cArqOri), "Atenção")
      Self:cFileTemp := ""
      Break
   EndIf
   
   lRet := .T.

                        //PanelName ,Vld. Back , Vld. Next                                                                   ,Vld. Fin 
   aAdd( aBlockAction , {"USER_PN0" ,{||.F.}   , {|| .T.}                                                                    , {||.T.}       })
   aAdd( aBlockAction , {"USER_PN1" ,{||.T.}   , {|| .T.}                                   , {||.T.}       })  
   aAdd( aBlockAction , {"USER_PN2" ,{||.T.}   , {|| .T.}                                   , {||.T.}       })
   aAdd( aBlockAction , {"USER_PN3" ,{||.T.}   , {|| .T.}                                   , {||.T.}       }) 
   aAdd( aBlockAction , {"USER_PN4" ,{||.T.}   , {|| .T.}                                                                    , {||.T.}       }) 

   DEFINE WIZARD oWizard TITLE   cWiz_Title;
                         HEADER  cWiz_Header;
                         MESSAGE cWiz_Message;
                         TEXT    cWiz_Text;
                         PANEL   ;
                         NEXT    {|| PanelNext( oWizard,aBlockAction[1] )};
                         FINISH  aBlockAction[1][4]
      

      CREATE PANEL oWizard HEADER "Definição do arquivo do lote"		MESSAGE "Passo 1:";
																		PANEL;
																		BACK	{|| .T. };
																		NEXT	{|| .T. };
																		FINISH	{|| .T. };
																		EXEC	{|| oGet1:SetFocus() }
                                                                        oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
                                                                        oPanel:cName := "SEL_FILE"
      
      @ 25, 10 Say "Copie a localização do arquivo, clicando no botão ao lado do campo abaixo:" Of oPanel Pixel
      @ 40, 10 Get oGet1 Var cFile Size 210,12 Of oPanel Pixel
      oBtn1 := TBtnBmp2():New(81,438,26,26,"COPYUSER",,,,{||Alert("Botão 01")},oPanel,,,.T. )
      oBtn1:cDefaultAct := "COPY"
      oGet1:SelectAll()

      CREATE PANEL oWizard HEADER "Upload do arquivo no portal Siscoserv"	MESSAGE "Passo 2:";
																		PANEL;
																		BACK	{|| .T. };
																		NEXT	{|| .T. };
																		FINISH	{|| .T. };
																		EXEC	{|| .T. }
                                                                        oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
                                                                        oPanel:cName := "SEND_FILE"

      @20, 10 Say "No navegador, acesse o Siscoserv e navegue até a página 'Transmissão em Lote'. " + ENTER +;
                  "Copie e cole a localização do arquivo no campo destacado abaixo e confirme:" Size oPanel:nClientHeight, oPanel:nClientWidth Of oPanel Pixel
      @ 052, 18 BitMap ResName "AVG_ENVSSRVS" Size 595, 141 NoBorder Of oPanel Pixel

      /*CREATE PANEL oWizard HEADER "Retorno do lote"						MESSAGE "Passo 3:";
																		PANEL;
																		BACK	bValidLote;
																		NEXT 	bValidLote;
																		FINISH	bValidLote;
																		EXEC {|| lEnv := .T., oGet2:SetFocus() }
																		oPanel       := oWizard:oMPanel[Len(oWizard:oMPanel)]
																		oPanel:cName := "RET_LOTE"

         oGet2 := TelaLote(oPanel, @cLote)*/

      CREATE PANEL oWizard HEADER "Transmissão do lote"					MESSAGE "Final:";
																		PANEL;
																		BACK	{|| .T. };
																		NEXT	{|| .T. };
																		FINISH	{|| .T. }
																		oPanel       := oWizard:oMPanel[Len(oWizard:oMPanel)]
																		oPanel:cName := "FINAL"

      @20, 10 Say "Envio finalizado. " Size oPanel:nClientHeight, oPanel:nClientWidth Of oPanel Pixel
      //@ 052, 18 BitMap ResName "AVG_ENVRE3" Size 595, 141 NoBorder Of oPanel Pixel


   oWizard:oCancel:bAction := bValidCancel
   oWizard:oDlg:Owner():lEscClose:= .F.

   ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }
   
   End Sequence
   
EndIf

Return lRet 

*------------------------------*
Function SS101CanLote(cNroLote, lEstLiq)
*------------------------------* 
Local aOrdEL8  := SaveOrd("EL8")
Local lRet     := .T.
Local cErrors  := ""
Local cDirGer  := ""
Local cDirRej  := ""
Local cNomeArq := ""
Local oDir    
Default lEstLiq  := .F. //RRC - 06/03/2013 - Será .T. se a chamada vier de uma tentativa de estorno de liquidação (ESSRS401())

EL8->(DbSetOrder(2)) //EL8_FILIAL + EL8_IDLOTE
EL8->(DbSeek(xFilial("EL8")+AvKey(cNroLote,"EL8_IDLOTE")))

If IsFileLock(EL8->EL8_TPPROC)
   EasyHelp("Não é possível utilizar esta funcionalidade pois existe um reprocessamento pendente.","Aviso")
   Return lRet 
EndIf

If Type("ESSCI100") == "O"  //Se for chamada do fonte ESSRS401(), precisa instanciar a classe    
   cDirGer := ESSCI100:cDirGerados+cNroLote+EXT_ZIP
   cDirRej := ESSCI100:cDirRejeitados 
Else
   oDir :=  ESSCI100():New("Integração SISCOSERV", "", "Ações", "", "Ações", "")      
   cDirGer := oDir:cDirGerados+cNroLote+EXT_ZIP
   cDirRej := oDir:cDirRejeitados  
EndIf

If EL8->(DbSeek(xFilial()+Avkey(cNroLote,"EL8_IDLOTE")))    
   If EL8->EL8_STATUS $ 'NER'
      If lEstLiq .Or. MsgYesNo("Deseja realmente cancelar o lote "+EL8->EL8_IDLOTE+" ?","Cancelamento de Lote")
         SS101GrvEL8(CANCELADO,EL8->EL8_TPPROC,EL8->EL8_TIPENV,EL8->EL8_IDLOTE,cErrors)
         //RRC - 13/09/2013 - Limpa o conteúdo do campo EJZ_SEQAD caso um lote de Aditivo seja cancelado
         If EL8->EL8_TIPENV == INC_ADI
            CancelSeqAd()
         EndIf
      EndIf
      If EasyGParam("MV_AVG0221",,"INI") == "XML
      /*RRC - 14/03/2013 - O trecho abaixo tem o objetivo de mover o arquivo compactado caso ele exista.
      Utiliza a função Cpy2ST() para copiá-lo do servidor, que é o conteúdo do ESSCI100:cDirGerados("/comex/siscoserv/naoenviados/"), para o client.
      Depois, utiliza a função CpyTS2() para copiá-lo novamente, agora do client para o diretório correspondente ao ESSCI100:cDirRejeitados
      ("/comex/siscoserv/cancelados/"). Depois exclui aqueles que foram copiados e mantém o arquivo no diretório dos cancelados.*/
         cNomeArq := EL8->EL8_ARQENV
         If !File(cDirGer) .Or. !CpyS2T(cDirGer, GetClientDir(), .F. ) .Or. !CpyT2S(GetClientDir()+cNomeArq, cDirRej, .F. ) 
            EasyHelp("Não foi possível copiar o arquivo "+cNomeArq+" para o diretório de seu ambiente: "+cDirRej,"Aviso")
         EndIf
         If File(cDirGer)
            FErase(cDirGer)
         EndIf
         If File(GetClientDir()+cNomeArq)
            FErase(GetClientDir()+cNomeArq)
         EndIf
      EndIf      
   Else
      MsgAlert("Lote " + AllTrim(cNroLote) + " não pode ser cancelado pois já está processado no sistema","AVISO")
      lRet := .F.         
   EndIf
Else
   MsgAlert("Não foi localizado o Lote " + AllTrim(cNroLote) + " selecionado para o cancelamento","AVISO")
   lRet := .F.
EndIf                                                 

RestOrd(aOrdEL8)

Return lRet

*----------------------------*
Static Function CloseTables()
*----------------------------*
lRet := .T.

EJY->(MsUnLockAll())
EJZ->(MsUnLockAll())
EL1->(MsUnLockAll())
EL9->(MsUnLockAll())

Return lRet


/*
Função      : PanelBack(oWizard)
Parametros  : oWizard - Objeto da interface Wizard.
Retorno     : lRet - Verdadeiro - Recua ao painel anterior, Falso - Continua no mesmo painel.
Objetivos   : Efetuar validações ao clicar no botão 'Voltar' dos painéis do Wizard.
Autor       : Allan Oliveira Monteiro
Data/Hora   : 29/08/12 - 15:00
*/
Static Function PanelBack(oWizard,aBlockAction) 

Local cPanel := PanelName(oWizard)
Local lRet := .T.
Default aBlockAction := {"USER_PN1",{|| .T.},{|| .T.},{|| .F.}}

   If cPanel == aBlockAction[1] 
      If cPanel <> "USER_PN0"
         lRet := Eval(aBlockAction[4])
      Else
         lRet := .F.
      EndIf
   EndIf
   
   If lRet
      oWizard:nPanel := PanelPos( GetLastPanel(oWizard,cPanel), oWizard, .T.)
   EndIf

Return lRet 


/*
Função      : PanelNext(oWizard,aBlockAction )
Parametros  : oWizard - Objeto da interface Wizard.
              aBlockAction - Array contendo: [1]-Nome do Panel;[2]-Codeblock de execução do botão NEXT;[3]-Codeblock de execução do botão Finish
Retorno     : lRet - Verdadeiro - Avança ao próximo painel, Falso - Continua no mesmo painel.
Objetivos   : Efetuar validações ao clicar no botão 'Avançar' dos painéis do Wizard.
Autor       : Allan Oliveira Monteiro
Data/Hora   : 29/08/12 - 15:00
Alteração   : 11/10/2012 - Nilson César C. Filho
Obs         : Alteração para tratamento do parâmtro aBlockAction
*/
Static Function PanelNext(oWizard,aBlockAction)
Local cPanel := PanelName(oWizard)
Local lRet := .T.
Local nPanel := oWizard:nPanel
Default aBlockAction := {"USER_PN0",{|| .T.},{|| .T.},{|| .T.}}

   If cPanel == aBlockAction[1]
      lRet := Eval(aBlockAction[3])
   EndIf
   
   If !lRet
      oWizard:nPanel := nPanel
   //Else
   //   SetLastPanel(oWizard)
   EndIf

Return lRet   

/*
Função      : PanelName(oWizard)
Parametros  : oWizard - Objeto da interface Wizard.
Retorno     : Propridade cName do painel atual - Nome do painel definido na declaração do Wizard.
Objetivos   : Retornar o nome do painel atual (Propriedade cName)
Autor       : Allan Oliveira Monteiro
Data/Hora   : 29/08/12 - 15:00
*/
Static Function PanelName(oWizard)
Return oWizard:oMPanel[oWizard:nPanel]:cName

/*
Função      : PanelPos(cName, oWizard, lBack)
Parametros  : cName - Nome do painel que se deseja saber a posição
              oWizard - Objeto da interface Wizard
              lBack - Indica se foi chamado do botão 'Voltar' dos painéis de Wizard.
Retorno     : nPos - Posição do painel na propriedade oMPanel (array).
Objetivos   : Localizar a posição de um painel na propriedade oMPanel a partir de seu nome (Propriedade cName).
Autor       : Allan Oliveira Monteiro
Data/Hora   : 29/08/12 - 15:00
*/
Static Function PanelPos(cName, oWizard, lBack)
Local nInc, nPos := 0
Default lBack := .F.

   For nInc := 1 To Len(oWizard:oMPanel)
      If oWizard:oMPanel[nInc]:cName == cName
         nPos := nInc
         If lBack
            nPos += 1
         Else
            nPos -= 1
         EndIf
         Exit
      EndIf
   Next

Return nPos

/*
Função      : SetLastPanel(oWizard)
Parametros  : oWizard - Objeto da interface Wizard.
Retorno     : .T.
Objetivos   : Marcar o painel atual como o último painel exibido, guardando seu nome na variável private cLastPanel. 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 29/08/12 - 15:00
*/
/*Static Function SetLastPanel(oWizard)
   cLastPanel := PanelName(oWizard)
Return .T.*/
/*
Função      : GetLastPanel(oWizard,cPanelName)
Parametros  : oWizard - Objeto da interface Wizard.
cPanelName  : Nome do Panel Atual
Retorno     : .T.
Objetivos   : Marcar o painel atual como o último painel exibido, guardando seu nome na variável private cLastPanel. 
Autor       : Nilson César C. Filho
Data/Hora   : 18/10/2012 - 17:00
*/
Static Function GetLastPanel(oWizard,cPanelName)
Local nPos 
Local cRet := ""

nPos := aScan(oWizard:oMPANEL,{|x|x:CNAME == cPanelName})
If nPos == 1
   cRet := oWizard:oMPANEL[nPos]:cNAME
Else   
   cRet := oWizard:oMPANEL[nPos-1]:cNAME
EndIf

Return cRet 

*--------------------------*
Static Function SS101Lote(oError)
*--------------------------*
Local lRet

Processa({||lRet := SS101GrvLote(oError)},"Gerando Lote...") 

Return lRet

*------------------------------------------------*
Static Function SS101PrepArq(cTipoOpe,cLote,oError)
*------------------------------------------------*
Local lRet

If EasyGParam("MV_AVG0221",,"INI") == "INI"
   Processa({||aRetArqs := ESSCI103(cTipoOpe,cLote,oError)},"Preparando Arquivos para a Integração...") 
   lRet := aRetArqs[1]
EndIf

Return lRet
 
*--------------------------------------------------*
Static Function SS101ExecInt(cTipoOpe,cLote,oError)                                 
*--------------------------------------------------*
Local lRet

Processa({||lRet := SS103Integ(aRetArqs,oError)},"Executando a Integração com o SISCOSERV...") 
//Processa({||lRet := SS101LogInt(@cLog)        },"Obtendo o Log da Integração...")

Return lRet:= .T.  //para permitir exibição do próximo Panel
*------------------------------------------------*
Static Function SS103FinalInteg(cTpServ,cTpOpe,cLote,cDir,oError) 
*------------------------------------------------*
Local lRet := .T.

Processa({||lRet := SS103IntFim(cTpServ,cTpOpe,cLote,cDir,oError)},"Finalizando a Integração e atualizando o status...")

Return lRet := .T.
/*
Função      : SS101SelLote()
Parametros  : oPanel - Objeto da interface Wizard.
Retorno     : .T.
Objetivos   : Marcar o painel atual como o último painel exibido, guardando seu nome na variável private cLastPanel. 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 29/08/12 - 15:00
*/
*----------------------------*
Function SS101SelLote() //cAction->("INCLOTE", "ENVLOTE")
*----------------------------*
Local oBrowse, oColumn, oDlg
Local cAlias , cQuery := "" 
Local aCampos := {}, aIndices := {}, aOrder := {}, aFilter:= {} //LGS-15/01/2016
Local nCount  := 1, cIndice:= "" //LGS-15/01/2016
/*RRC - 16/09/2013 - Valida aditivos e atualiza contador de itens marcados. Quando é Retificação de Aditivo, o campo TMP->RECNO que guarda o Recno do Alias utilizado será sempre zero, já que é feito um
Group By por Seq.Aditivo (EJZ_SEQAD), sendo assim, controla os itens marcados pelo Recno da própria work*/
Local bMarca		:= {|| If((nPos := aScan(aItens, If(cTipoOpe==RET_ADI,TMP->(Recno()),TMP->RECNO))) == 0, GetMkItem(), If(cTipoOpe == INC_ADI,ValidAdt(nPos,oBrowse),(aDel(aItens, nPos), aSize(aItens, Len(aItens)-1)))),oSay1:Refresh()}
Local bMarcaTodos	:= {|oBrowse| If(Len(aItens) > 0, aItens := {}, aItens := GetAllItens()), oBrowse:Refresh(.T.),oSay1:Refresh() }
Local nInc, nPos
Local lRet := .T.
Local oSay1
Local oTotPanel
Local cCampo := "" //MCF - 19/01/2016
Local lLoop := .F.
Local Z := 0 //LRS - 16/03/2018

Local bOk := {|| oDlg:End()}
Local bCancel := {|| oDlg:End()}
Local aNotCpsSX3 := {{"RECNO","N",10,0}} //Campos da query que não estão no SX3
//Verifica o Alias a ser utilizado
Do Case
  
  Case cTipoOpe == INC_REG .Or. cTipoOpe == RET_REG
     cAlias := "EJY"
  Case cTipoOpe == INC_ADI .Or. cTipoOpe == RET_ADI
     cAlias := "EJZ"
  Case cTipoOpe == INC_PAG .Or. cTipoOpe == CAN_PAG .OR. cTipoOpe == RET_PAG
     cAlias := "EL9"
          
End Case

(cAlias)->(DbSetOrder(1))

//Carrega os campos a serem apresentados no Browse de acordo com Alias
aCampos := LoadCmpos(cAlias)

//Monta query com os filtros de acordo com as operações 
cQuery := MontaQry() //cAction->("INCLOTE", "ENVLOTE")


If select("TMP") > 0
   TMP->(dbClosearea())
EndIf

//LGS-15/01/2016
SIX->(DbSetOrder(1))
SIX->(DbSeek(cAlias))

Do While SIX->(!Eof()) .And. SIX->INDICE == cAlias  

   aTempORD := {}
   aTempIDX := EasyStrSplit(AllTrim(SIX->CHAVE),"+")
   lLoop    := .F. //MCF - 19/01/2016
   
   For nInc := 1 To Len(aTempIDX) //MCF - 19/01/2016
      cCampo := aTempIDX[nInc]
      If At(")",cCampo) > 0
         cCampo := SubStr(cCampo,At(cAlias,cCampo),At(")",cCampo))
      Endif
      
      If !(cAlias+".*" $ cQuery)
         If !(cCampo $ cQuery)
            lLoop := .T.
            Exit
         Endif
      EndIf
      aTempIDX[nInc] := cCampo 
   Next
   
   If lLoop
      SIX->(DbSkip())
      Loop
   Endif
   
   For nInc := 1 To Len(aTempIDX)
       aAdd(aTempORD,{ "", "C", AvSx3(aTempIDX[nInc], AV_TAMANHO), 0, AvSx3(aTempIDX[nInc], AV_TITULO),, } )
   Next
   
   If nCount == 1
      cIndice := AllTrim(SIX->CHAVE)
   Else
      aAdd(aIndices, AllTrim(SIX->CHAVE) )
   EndIf
   
   aAdd(aOrder, { "Filial + " + AllTrim(SIX->DESCRICAO), aTempORD, nCount } )  
   SIX->(DbSkip())
   nCount ++
EndDo

If !Empty(cIndice) 
   aAdd(aIndices, cIndice )
EndIf

//Cria Work para apresentar no FWBROWSE
EasyWkQuery(cQuery,"TMP",aIndices,aNotCpsSX3)

nInc := 1
Do While nInc <= Len(aCampos)
   If !TMP->(FieldPos(aCampos[nInc])) > 0
      aDel(aCampos,nInc)
      aSize(aCampos,Len(aCampos)-1)   
      nInc--
   EndIf
   nInc++
EndDo 

//LRS - 16/03/2018
For Z := 1 To Len (aCampos)
    AAdd(aFilter, {aCampos[z] , AvSx3(aCampos[z], AV_TITULO)    , AvSx3(aCampos[z], AV_TIPO)    , AvSx3(aCampos[z], AV_TAMANHO)    , AvSx3(aCampos[z], AV_DECIMAL),  AvSx3(aCampos[z], AV_PICTURE)})
Next

If TMP->(EOF()) .And. TMP->(BOF())
   lRet := .F.
EndIf

If lRet

   If Type("lBrwAtivo")=="L" .And. !lBrwAtivo
   
      //RMD - 12/07/16 - Somente cria a tela caso tenha identificado registros para exibição.
      oDlg := MSDialog():New(DLG_LIN_INI,DLG_COL_INI,DLG_LIN_FIM,DLG_COL_FIM,'Seleção de Processos',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
      DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TMP" LINE BEGIN 1 OF oDlg //oPanel
         /*RRC - 16/09/2013 - Quando é Retificação de Aditivo, o campo TMP->RECNO que guarda o Recno do Alias utilizado será sempre zero, já que é feito um
         Group By por Seq.Aditivo (EJZ_SEQAD), sendo assim, controla os itens marcados pelo Recno da própria work*/
         ADD MARKCOLUMN oColumn DATA { || If(aScan(aItens, If(cTipoOpe==RET_ADI,TMP->(Recno()),TMP->RECNO)) == 0, 'LBNO', 'LBOK') } DOUBLECLICK bMarca HEADERCLICK bMarcaTodos OF oBrowse
         For nInc := 1 To Len(aCampos)
             ADD COLUMN oColumn DATA &("{ ||" + aCampos[nInc] + " }") TITLE AvSx3(aCampos[nInc], AV_TITULO) PICTURE AvSx3(aCampos[nInc], AV_PICTURE)  SIZE AvSx3(aCampos[nInc], AV_TAMANHO) OF oBrowse
         Next

         oBrowse:lDbfFilter:= .T. //LRS - 16/03/2018
         oBrowse:SetUseFilter()
         oBrowse:SetFieldFilter(aFilter)

         oBrowse:SetSeek( ,aOrder) //LGS-15/01/2016
         oBrowse:Refresh()
      ACTIVATE FWBROWSE oBrowse
      
      If ValType(oBrowse:oBrowseUI:oFWSeek) == "O"    //verifica se é objeto
         oBrowse:oBrowseUI:oFWSeek:SetAction({|cSeek,nOrder| CI101Seek(AllTrim(Upper(cSeek)), nOrder, oBrowse)}) //Entra na função quando clicar em pesquisar
         oBrowse:Refresh()
      EndIf
      
      //RRC - 10/09/2013 - Adiciona texto para informar quantos itens foram marcados para compôr o lote
      oTotPanel := TPanel():New(01,01,"",oDlg,oDlg:oFont,,,,,oDlg:nClientHeight,10)
      oTotPanel:Align := CONTROL_ALIGN_BOTTOM
      oSay1 := TSay():New ( 1, 1, {||'Total de Itens Marcados: '+AllTrim(Str(Len(aItens)))}, oTotPanel, , oTotPanel:oFont, , , , .T., CLR_BLACK, CLR_WHITE, 200, 100, , , , , ,  )         
       
      //lBrwAtivo   := .T.

   EndIf
   oDlg:Activate(,,,.T.,,,{|Self|EnchoiceBar(oDlg,bOk,bCancel)},)
   nRegs := Len(aItens)
Else
   EasyHelp("Não foram encontrados registros para esta operação." + ENTER +;
            "Verifique se todos os requisitos foram respeitados, como: " + ENTER +;
            "- Para solicitar retificação, os processos e seus itens devem ter sido registrados anteriormente.","Aviso")
EndIf

Return lRet 

*--------------------------------*
Static Function LoadCmpos(cAlias)
*--------------------------------*
Local aCmpos := {}

SX3->(DbSetOrder(1))
If SX3->(DbSeek(cAlias))
   While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == cAlias
      If !("_FILIAL" $ SX3->X3_CAMPO .Or. "_TPPROC" $ SX3->X3_CAMPO)  .And. SX3->X3_CONTEXT <> "V" .And. SX3->X3_TIPO <> "M"
         //RRC - 29/04/2013 - Alteração para não exibir campos utilizados apenas no Rogistro de Venda quando for uma Aquisição
         If !(cAlias == "EJY") .Or. (cTipoServ == "V" .And. !("_EXPORT" $ SX3->X3_CAMPO .Or. "_LOJEXP" $ SX3->X3_CAMPO .Or. "_DSCEXP" $ SX3->X3_CAMPO)) .Or.;
            (cTipoServ == "A" .And. !("_IMPORT" $ SX3->X3_CAMPO .Or. "_LOJIMP" $ SX3->X3_CAMPO .Or. "_DSCIMP" $ SX3->X3_CAMPO)) 
            If !(cAlias == "EL9") .Or. !("_NRINVO" $ SX3->X3_CAMPO .Or. "_PROCES" $ SX3->X3_CAMPO) 
               AADD(aCmpos,SX3->X3_CAMPO)         
            EndIf
         EndIf         
      EndIf   
   SX3->(DbSkip())
   EndDo
EndIf

Return aClone(aCmpos)

*----------------------------------*
Static Function GetAllItens()
*----------------------------------*
Local nCont := 0 
Local aCmpos := {}
Local cMsg := "" , cMsgView := ""
Local nReg := EasyGParam("MV_AVG0223",,99999)//If( EasyGParam("MV_AVG0221",,"INI") == "INI", 51 ,Val(Alltrim(EasyGParam("MV_AVG0223",,"51"))) )
Local lLimiteItem := .F.
Private lLotePend := .F. //RRC - 16/09/2013 - Controla se existe um lote pendente de envio e processamento

TMP->(DbGoTop())
While TMP->(!Eof()) .And. !lLimiteItem .And. !lLotePend
   cMsg := ""
   cMsg += TabBloq()
   If Empty(cMsg)
     cMsg += ValidItem(.T.) //RRC - 10/09/2013 - Passa .T. Para indicar que estão sendo marcados todos os itens para validação de aditivo
   EndIf
   If !Empty(cMsg)
      cMsgView += cMsg + ENTER
      TMP->(DbSkip())
      Loop     
   EndIf
   If nCont < nReg
      nCont++
   ElseIf !lLimiteItem
      EasyHelp("Numero "+Alltrim(StrZero(nReg,4))+" máximo de registro(s) permitido(s) pelo SISCOSERV foi excedido, portanto só serao marcados os primeiros conforme Ordem dos registros.","Aviso")
      lLimiteItem := .T.
   EndIf
   //RRC - 30/04/2013 
   If !lLimiteItem
      /*RRC - 16/09/2013 - Quando é Retificação de Aditivo, o campo TMP->RECNO que guarda o Recno do Alias utilizado será sempre zero, já que é feito um
      Group By por Seq.Aditivo (EJZ_SEQAD), sendo assim, controla os itens marcados pelo Recno da própria work*/
      aAdd(aCmpos, If(cTipoOpe==RET_ADI,TMP->(Recno()),TMP->RECNO))
   EndIf
TMP->(DbSkip())                                                                                             
EndDo
If !Empty(cMsgView)                                                                                                                                         
   //Passa a mensagem via array para quebrar linha
   EECVIEW({{cMsgView,.T.}},"Aviso!")
EndIf

Return aClone(aCmpos)


*--------------------------------*
Static Function GetMkItem(cAlias)
*--------------------------------*
Local cMsg := ""
Local nReg := EasyGParam("MV_AVG0223",,99999)//If( EasyGParam("MV_AVG0221",,"INI") == "INI",99999 ,Val(Alltrim(EasyGParam("MV_AVG0223",,"51"))) )

Begin Sequence

   cMsg += TabBloq()
   If Empty(cMsg)
     cMsg += ValidItem()
   EndIf

   If !Empty(cMsg)
      EasyHelp(cMsg,"Aviso!")
      Break
   EndIf

   //Geração de arquivo xml -> max. 51 reg. no lote; Geração de arquivo ini -> max. 1 reg. no lote 
   If Len(aItens) < nReg
      /*RRC - 16/09/2013 - Quando é Retificação de Aditivo, o campo TMP->RECNO que guarda o Recno do Alias utilizado será sempre zero, já que é feito um
      Group By por Seq.Aditivo (EJZ_SEQAD), sendo assim, controla os itens marcados pelo Recno da própria work*/
      aAdd(aItens, If(cTipoOpe==RET_ADI,TMP->(Recno()),TMP->RECNO))
   Else
      EasyHelp("Foi excedido o numero de "+Alltrim(StrZero(nReg,4))+" registro(s) permitido(s) para geração do Lote no SISCOSERV. Para selecionar esse registro por favor desmarque outro registro.","Aviso")
   EndIf
   
End Sequence

Return 

*------------------------*
Static Function TabBloq()
*------------------------*
Local cMsg := ""
//Local cLastProc  := ""
//Local cLastSeqAd := ""
Local aSaveOrd   := SaveOrd({"EJY","EJZ","EL1","EL9","TMP"})

  
  EJY->(DbSetOrder(1))//EJY_FILIAL+EJY_TPPROC+EJY_REGIST
  EJZ->(DbSetOrder(2))//EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQAD
  //EL1->(DbSetOrder(1))//EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG+EL1_SEQPAG
  If cTipoOpe == INC_REG .Or. cTipoOpe == RET_REG 
     If EJY->(DbSeek(xFilial("EJY") + TMP->EJY_TPPROC+ TMP->EJY_REGIST))
        If !SoftLock("EJY")
           cMsg := "O processo: " + AllTrim(TMP->EJY_REGIST) + " está sendo utilizado por outro usuario." + Replicate(ENTER,2)
        EndIf
     EndIf
     
  ElseIf cTipoOpe == INC_ADI .Or. cTipoOpe == RET_ADI
     //RRC 16/09/2013 - Alterada chave de busca para considerar a Seq. Aditivo, na Retificação de Aditivo não traz o EJZ_SEQREG
     If EJZ->(DbSeek(xFilial("EJZ") + TMP->EJZ_TPPROC+ TMP->EJZ_REGIST + TMP->EJZ_SEQAD))
        If !SoftLock("EJZ")
           cMsg := "O processo/Sequencia: " + AllTrim(TMP->EJZ_REGIST)+ "/" + AllTrim(TMP->EJZ_SEQAD) + " está sendo utilizado por outro usuario." + Replicate(ENTER,2)
        EndIf
     EndIf
     //NOPADO por RRC - 10/09/2013 - Deve permitir gerar um lote com vários serviços para aditivo
     //RRC - 14/11/2012 - Verifica se as informações se referem a aditivos de mesma sequência e processo
     /*cLastProc  := TMP->EJZ_REGIST
     cLastSeqAd := TMP->EJZ_SEQAD
     TMP->(DbGoTop())
     Do While TMP->(!Eof())
        If !(TMP->EJZ_REGIST == cLastProc .And. TMP->EJZ_SEQAD == cLastSeqAd) .And. aScan( aItens , TMP->RECNO ) > 0
           cMsg := "Não podem ser selecionados aditivos de Registros ou Sequências diferentes." + Replicate(ENTER,2) 
           Exit  
        EndIf 
        TMP->(DbSkip())
     EndDo
     */
     

  ElseIf cTipoOpe == INC_PAG .Or. cTipoOpe == CAN_PAG .Or. cTipoOpe == RET_PAG
     EL9->(DbSetOrder(1)) //EL9_FILIAL + EL9_TPPROC + EL9_REGIST + EL9_SEQPAG
     If EL9->(DbSeek(xFilial("EL9") + TMP->EL9_TPPROC+ TMP->EL9_REGIST + TMP->EL9_SEQPAG ))
        If !SoftLock("EL9")
           cMsg := "O processo/Sequencia Pagto: " + AllTrim(TMP->EL9_REGIST)+ "/" + AllTrim(TMP->EL9_SEQPAG) + " está sendo utilizado por outro usuario." + Replicate(ENTER,2)
        EndIf
     EndIf 
     //NOPADO por RRC - 05/03/2013
     /*
     cLastProc := TMP->EL1_REGIST
     TMP->(DbGoTop())
     Do While TMP->(!Eof())
        If TMP->EL1_REGIST <> cLastProc .And. aScan( aItens , TMP->RECNO ) > 0
           cMsg := "Não podem ser selecionados pagamentos de Registros diferentes." + Replicate(ENTER,2) 
           Exit  
        EndIf 
        TMP->(DbSkip())
     EndDo
     */
  
  EndIf
  
  RestOrd(aSaveOrd,.T.)

Return cMsg


*--------------------------------*
Static Function ValidItem(lAllItens)
*--------------------------------*
Local cMsg := "", cQuery := "", cChave := "", cAguardCan := ""
Local aOrd := SaveOrd({"EJY","EL9","EJZ"})              
Local lOk := .T.
Default lAllItens := .F.

 cQuery += "SELECT EL8.R_E_C_N_O_ AS RECNO, EL8.EL8_STATUS, EL8.EL8_IDLOTE, EL8.EL8_TIPENV FROM " +  RetSqlName("EL8") + " EL8 " 
 cQuery += "WHERE EL8.EL8_STATUS <> 'P' AND EL8.EL8_STATUS <> 'C' AND EL8.EL8_TPPROC = '" + cTipoServ + "' AND " + "EL8.EL8_FILIAL = '" + xFilial("EL8") + "' AND "
 cQuery += IIF(TcSrvType()<>"AS/400","EL8.D_E_L_E_T_<>'*'","EL8.@DELETED@<>'*'")
  
 cQuery := ChangeQuery(cQuery)
 DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "QRYIT", .T., .T.) 
 
 QRYIT->(DbGoTop())
 While QRYIT->(!EOF())
    cMsg += "O lote " + QRYIT->EL8_IDLOTE + " está pendente. Para gerar um novo lote, será necessário o 'cancelamento' do mesmo ou o efetuar o 'processamento' no SIGAESS após o seu envio ao SISCOSERV."
    //RRC - 16/09/2013 - Controla caso seja chamada do GetAllItens(Marca Todos) para não exibir a mesma mensagem várias vezes
    lLotePend := .T.
    Exit
QRYIT->(DbSkip())
EndDo

If Select("QRYIT") > 0
   QRYIT->(DbCloseArea())   
EndIf

If Empty(cMsg)
   EJY->(DbSetOrder(1)) //EJY_FILIAL+EJY_TPPROC+EJY_REGIST 
   EJZ->(DbSetOrder(1)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQREG
   Do Case
      //RRC - 10/10/2013
      Case cTipoOpe == INC_REG
         If TMP->EJY_DTINI > dDataBase
            cMsg := "O Registro " + AllTrim(TMP->EJY_REGIST) + " possui serviços não iniciados, sendo assim, ainda não poderá ser registrado."
         ElseIf EJZ->(DbSeek(xFilial("EJZ")+TMP->EJY_TPPROC+TMP->EJY_REGIST))
            Do While EJZ->(!Eof()) .And. EJZ->(EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST) == xFilial("EJZ")+TMP->(EJY_TPPROC+EJY_REGIST)
               If EJZ->EJZ_DTINI > dDataBase
                  cMsg := "O Registro " + AllTrim(TMP->EJY_REGIST) + " possui serviços não iniciados, sendo assim, ainda não poderá ser registrado."
                  Exit
               EndIf
               //FSY - 13/01/2014 - Ajuste para impedir marcação de item com NBS bloqueado.
               If !PS400VALNBS(EJZ->EJZ_NBS)
                  cMsg := "Registro " + AllTrim(TMP->EJY_REGIST) + " contem item com NBS bloqueado."
                  Exit
               EndIf
               EJZ->(DbSkip())
            EndDo
         EndIf  
      
      Case cTipoOpe == INC_PAG .And. EJY->(DbSeek(xFilial("EJY")+AvKey(TMP->EL9_TPPROC,"EJY_TPPROC")+AvKey(TMP->EL9_REGIST,"EJY_REGIST")))
         //RRC - 29/04/2013 - Não pode gerar um lote de Pagamento ou Faturamento caso o status do RAS ou RVS esteja como "Parcialmente Registrado no Siscoserv"
         If EJY->EJY_STTSIS == "2"
            cMsg += "O Registro " + AllTrim(TMP->EL9_REGIST) + " apresenta status '"+BSCXBOX('EJY_STTSIS',EJY->EJY_STTSIS)+"'. Caso haja aditivo, é preciso enviá-lo, caso contrário, é preciso realizar a Retificação do Processo antes de enviar o "+If(EJY->EJY_TPPROC == "A","Pagamento","Faturamento")+"."+ Replicate(ENTER,2)  
         Else
            //RRC - 29/04/2013 - Verifica se a invoice/fatura não possui saldo maior que o Registro 
            If EJY->EJY_TPPROC == "A"      
               ELA->(DbSetOrder(2)) //ELA_FILIAL + ELA_TPPROC + ELA_IMPORT + ELA_LOJIMP + ELA_NRINVO + ELA_PROCES 
               cChave := xFilial("ELA")+AvKey(EJY->EJY_TPPROC,"ELA_TPPROC")+AvKey(EJY->EJY_IMPORT,"ELA_IMPORT")+AvKey(EJY->EJY_LOJIMP,"ELA_LOJIMP")+AvKey(TMP->EL9_NRINVO,"ELA_NRINVO")+AvKey(TMP->EL9_PROCES,"ELA_PROCES")
            ElseIf EJY->EJY_TPPROC == "V"
               ELA->(DbSetOrder(3)) //ELA_FILIAL + ELA_TPPROC + ELA_EXPORT + ELA_LOJEXP + ELA_NRINVO + ELA_PROCES
               cChave := xFilial("ELA")+AvKey(EJY->EJY_TPPROC,"ELA_TPPROC")+AvKey(EJY->EJY_EXPORT,"ELA_EXPORT")+AvKey(EJY->EJY_LOJEXP,"ELA_LOJEXP")+AvKey(TMP->EL9_NRINVO,"ELA_NRINVO")+AvKey(TMP->EL9_PROCES,"ELA_PROCES")
            EndIf   
            If ELA->(DbSeek(cChave))
               If ELA->(ELA_VL_MOE*ELA_TX_MOE) > EJY->EJY_VL_MOE*ELA->ELA_TX_PED  //AAF 25/08/2015
                  cMsg += If(EJY->EJY_TPPROC == "A","O pagamento","A fatura") + " do Processo/Sequência Pagamento: " + AllTrim(TMP->EL9_REGIST) + "/" + AllTrim(TMP->EL9_SEQPAG) + " possui saldo maior que o Registro, é preciso realizar a Retificação do Processo ou alterar o valor "+If(EJY->EJY_TPPROC == "A","da invoice.","da fatura.")+ Replicate(ENTER,2)   
               EndIf
            EndIf
            //RRC - 06/06/2013 - Incluída condição para verificar se o mesmo Registro possui algum Pagamento ou Faturamento com status "Aguardando Cancelamento"                    
            If Empty(cMsg)
               EL9->(DbSetOrder(1)) //EL9_FILIAL + EL9_TPPROC + EL9_REGIST + EL9_SEQPAG
               If EL9->(DbSeek(xFilial("EL9")+TMP->EL9_TPPROC+TMP->EL9_REGIST))
                  Do While EL9->(!Eof()) .And. lOk .And. EL9->EL9_TPPROC == TMP->EL9_TPPROC .And. EL9->EL9_REGIST == TMP->EL9_REGIST
                     lOk := !(EL9->EL9_STTSIS == "3") 
                     cAguardCan := BSCXBOX("EL9_STTSIS",EL9->EL9_STTSIS)
                     EL9->(DbSkip())
                  EndDo
                  If !lOk
                     cMsg += If(EJY->EJY_TPPROC == "A","O RAS " + AllTrim(TMP->EL9_REGIST) + " possui pagamento","O RVS " + AllTrim(TMP->EL9_REGIST) + " possui faturamento") + " com status '" + cAguardCan  + "'. É preciso realizar o cancelamento primeiro." + Replicate(ENTER,2)   
                  EndIf
               EndIf      
            EndIf
         EndIf
      
      /*RRC - 09/09/2013 - Não permite enviar um aditivo cujo Sequência do Registro (EJZ_SEQREG) do serviço seja superior a de outro serviço ainda não registrado
       e que não compõe o lote, uma vez que a ordem do envio, é importante para identificação do serviço no SISCOSERV, por exemplo, no Pagamento*/  
      Case !lAllItens .And. cTipoOpe == INC_ADI
         cChave := xFilial("EJZ")+TMP->EJZ_TPPROC+TMP->EJZ_REGIST
         If EJZ->(DbSeek(cChave))
            Do While !EJZ->(Eof()) .And. EJZ->(EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST) == cChave .And. Val(TMP->EJZ_SEQREG) > Val(EJZ->EJZ_SEQREG)
               //aItens guarda todos os dados selecionados para o lote
               If (Val(EJZ->EJZ_SEQAD) > 0 .Or. Empty(EJZ->EJZ_SEQAD)) .And. EJZ->EJZ_STTSIS == "1" .And. !aScan(aItens,EJZ->(Recno())) > 0
                  cMsg += "O serviço selecionado possui Sequência de Registro superior a de outro serviço ainda não registrado no " + If(TMP->EJZ_TPPROC=="A","RAS: ","RVS: ") + AllTrim(TMP->EJZ_REGIST) + ". Para envio do aditivo, é preciso seguir a ordem dessa sequência, ou enviá-los em um mesmo lote."          
                  Exit
               EndIf
               EJZ->(DbSkip())
            EndDo
         EndIf   
   EndCase
EndIf  
RestOrd(aOrd,.T.)   
Return cMsg

*-------------------------------*
Static Function MontaQry()
*-------------------------------*
Local  cCond1 := "", cCond2 := "" , cQuery := ""

Begin Sequence

   Do Case
   //RRC - 19/09/2013 - Alteração para considerar a filial ativa na query através da função xFilial()
    
      Case cTipoOpe == INC_REG //Registro de Aquisição de Serviço (RAS) / Registro de Venda de Serviço (RVS) 
                                             
         cCond1 += "EJY.EJY_FILIAL = '" + xFilial("EJY") + "' AND EJY.EJY_TPPROC = '" + cTipoServ + "' AND EJY.EJY_STTSIS = '1' AND " + IIF(TcSrvType()<>"AS/400","EJY.D_E_L_E_T_<>'*'","EJY.@DELETED@<>'*'")
         If EasyGParam("MV_ESS0027",,9) >= 10
            cCond1 += " AND (EJY.EJY_NIF <> '' OR EJY.EJY_MOTNIF <> '') "
         EndIf
         cAlias := "EJY"    
     
      Case cTipoOpe == RET_REG //Retificação de Aquisição de Serviço (Retificação RAS) / Retificação de Venda de Serviço (Retificação RVS)
  
         cCond1 += "AND EJY.EJY_FILIAL = '" + xFilial("EJY") + "' AND EJY.EJY_TPPROC = '" + cTipoServ + "' AND EJY.EJY_STTSIS = '2' AND " + IIF(TcSrvType()<>"AS/400","EJY.D_E_L_E_T_<>'*'","EJY.@DELETED@<>'*'")
         If EasyGParam("MV_ESS0027",,9) >= 10
            cCond1 += " AND (EJY.EJY_NIF <> '' OR EJY.EJY_MOTNIF <> '') "
         EndIf
         cCond2 += "EJZ.EJZ_SEQAD = '000' AND " /*EJZ.EJZ_STTSIS <> '3' AND " */+ IIF(TcSrvType()<>"AS/400","EJZ.D_E_L_E_T_<>'*'","EJZ.@DELETED@<>'*'")  // GFP - 10/08/2015
         cAlias := "EJY"
     
      Case cTipoOpe == INC_ADI //Aditivo ao Registro de Aquisição de Serviço (Aditivo RAS) / Aditivo ao Registro de Venda de Serviço (Aditivo RVS)
  
         cCond1 += "EJY.EJY_TPPROC = '" + cTipoServ + "' AND EJY.EJY_STTSIS = '2' AND " + IIF(TcSrvType()<>"AS/400","EJY.D_E_L_E_T_<>'*'","EJY.@DELETED@<>'*'")
         If EasyGParam("MV_ESS0027",,9) >= 10
            cCond1 += " AND (EJY.EJY_NIF <> '' OR EJY.EJY_MOTNIF <> '') "
         EndIf
         cCond2 += " AND EJZ.EJZ_STTSIS = '1'" + " AND EJZ.EJZ_FILIAL = '" + xFilial("EJZ") + "' AND " + IIF(TcSrvType()<>"AS/400","EJZ.D_E_L_E_T_<>'*'","EJZ.@DELETED@<>'*'")
         cAlias := "EJZ"
  
      Case cTipoOpe == RET_ADI //Retificação de Aditivo de Aquisição de Serviço (Retificação RAS) / Retificação de Aditivo de Venda de Serviço (Retificação RVS)
  
         cCond1 += "EJY.EJY_TPPROC = '" + cTipoServ + "' AND EJY.EJY_STTSIS = '2' AND " + IIF(TcSrvType()<>"AS/400","EJY.D_E_L_E_T_<>'*'","EJY.@DELETED@<>'*'")
         If EasyGParam("MV_ESS0027",,9) >= 10
            cCond1 += " AND (EJY.EJY_NIF <> '' OR EJY.EJY_MOTNIF <> '') "
         EndIf
         cCond2 += " AND EJZ.EJZ_SEQAD <> '' AND EJZ.EJZ_SEQAD <> '000'" + " AND EJZ.EJZ_FILIAL = '" + xFilial("EJZ") + "' AND EJZ.EJZ_STTSIS = '2' AND " + IIF(TcSrvType()<>"AS/400","EJZ.D_E_L_E_T_<>'*'","EJZ.@DELETED@<>'*'")
         //RRC - 16/09/2013 - Na retificação de Aditivo, é preciso enviar todos os itens da mesma sequência, ou seja, os que foram enviados no mesmo lote,
         //sendo assim, agrupa por EJZ_SEQAD
         cCond2 += " GROUP BY EJZ.EJZ_FILIAL, EJZ.EJZ_TPPROC, EJZ.EJZ_REGIST, EJZ.EJZ_SEQAD" 
         cAlias := "EJZ"
        
      Case cTipoOpe == INC_PAG //Registro de Pagamento de Serviço (RP) / Registro de Faturamento de Serviço (RF)
                                                                                     //RRC - 16/07/2013 - Condição para EJY não estar deletado
         cCond1 += "EJY.EJY_FILIAL = EL9.EL9_FILIAL AND EJY.EJY_TPPROC = EL9.EL9_TPPROC AND EJY.EJY_REGIST = EL9.EL9_REGIST AND EJY.EJY_NROREG <> '' AND " + IIF(TcSrvType()<>"AS/400","EJY.D_E_L_E_T_<>'*'","EJY.@DELETED@<>'*'") //FSM 
         cCond1 += " AND EL9.EL9_FILIAL = '" + xFilial("EL9") + "' AND EL9.EL9_TPPROC = '" + cTipoServ + "' AND EL9.EL9_STTSIS = '1' AND " + IIF(TcSrvType()<>"AS/400","EL9.D_E_L_E_T_<>'*'","EL9.@DELETED@<>'*'")
         cAlias := "EL9"
  
      Case cTipoOpe == CAN_PAG //Cancelamento de Pagamento de Serviço (Cancelamento RP) / Cancelamento de Faturamento de Serviço (Cancelamento RF)
						                                                             //RRC - 16/07/2013 - Condição para EJY não estar deletado
         cCond1 += "EJY.EJY_FILIAL = EL9.EL9_FILIAL AND EJY.EJY_TPPROC = EL9.EL9_TPPROC AND EJY.EJY_REGIST = EL9.EL9_REGIST AND EJY.EJY_NROREG <> '' AND " + IIF(TcSrvType()<>"AS/400","EJY.D_E_L_E_T_<>'*'","EJY.@DELETED@<>'*'")//FSM 
         cCond1 += " AND EL9.EL9_FILIAL = '" + xFilial("EL9") + "' AND EL9.EL9_TPPROC = '" + cTipoServ + "' AND EL9.EL9_STTSIS = '3' AND " + IIF(TcSrvType()<>"AS/400","EL9.D_E_L_E_T_<>'*'","EL9.@DELETED@<>'*'")
         cAlias := "EL9"
       
      Case cTipoOpe == RET_PAG //Retificação de Pagamento de Serviço (Retificação RP) / Retificação de Faturamento de Serviço (Retificação RF)
						                                                             //RRC - 16/07/2013 - Condição para EJY não estar deletado
         cCond1 += "EJY.EJY_FILIAL = EL9.EL9_FILIAL AND EJY.EJY_TPPROC = EL9.EL9_TPPROC AND EJY.EJY_REGIST = EL9.EL9_REGIST AND EJY.EJY_NROREG <> '' AND " + IIF(TcSrvType()<>"AS/400","EJY.D_E_L_E_T_<>'*'","EJY.@DELETED@<>'*'")//FSM 
         cCond1 += " AND EL9.EL9_FILIAL = '" + xFilial("EL9") + "' AND EL9.EL9_TPPROC = '" + cTipoServ + "' AND EL9.EL9_STTSIS = '5' AND " + IIF(TcSrvType()<>"AS/400","EL9.D_E_L_E_T_<>'*'","EL9.@DELETED@<>'*'")
         cAlias := "EL9"

   EndCase

   If cTipoOpe == INC_REG
   
      cQuery := "SELECT EJY.*, EJY.R_E_C_N_O_ AS RECNO FROM "  + RetSqlName("EJY") + " EJY WHERE " + cCond1

   ElseIf cTipoOpe == RET_REG
   
      cQuery := "SELECT EJY.*, EJY.R_E_C_N_O_ AS RECNO FROM "  + RetSqlName("EJY") + " EJY INNER JOIN"
      cQuery += " (SELECT DISTINCT EJZ.EJZ_FILIAL,EJZ.EJZ_TPPROC,EJZ.EJZ_REGIST FROM " +  RetSqlName("EJZ") + " EJZ WHERE " + cCond2 
      cQuery += " )A ON EJY.EJY_FILIAL = A.EJZ_FILIAL AND EJY.EJY_TPPROC = A.EJZ_TPPROC AND EJY.EJY_REGIST = A.EJZ_REGIST " +  cCond1
   
   ElseIf cTipoOpe == INC_ADI
   
      cQuery := "SELECT EJZ.*, EJZ.R_E_C_N_O_ AS RECNO FROM "  + RetSqlName("EJZ") + " EJZ INNER JOIN"
      cQuery += " (SELECT DISTINCT EJY.EJY_FILIAL,EJY.EJY_TPPROC,EJY.EJY_REGIST FROM " +  RetSqlName("EJY") + " EJY WHERE " + cCond1 
      cQuery += " )A ON EJZ.EJZ_FILIAL = A.EJY_FILIAL AND EJZ.EJZ_TPPROC = A.EJY_TPPROC AND EJZ.EJZ_REGIST = A.EJY_REGIST "   + cCond2

   //RRC - 16/09/2013 - Na retificação de Aditivo, não traz todos os campos da EJZ, pois agrupa as informações pelo EJZ_SEQAD
   ElseIf cTipoOpe == RET_ADI     
      
      cQuery := "SELECT EJZ.EJZ_FILIAL, EJZ.EJZ_TPPROC, EJZ.EJZ_REGIST, EJZ.EJZ_SEQAD FROM "  + RetSqlName("EJZ") + " EJZ INNER JOIN"
      cQuery += " (SELECT DISTINCT EJY.EJY_FILIAL,EJY.EJY_TPPROC,EJY.EJY_REGIST FROM " +  RetSqlName("EJY") + " EJY WHERE " + cCond1 
      cQuery += " )A ON EJZ.EJZ_FILIAL = A.EJY_FILIAL AND EJZ.EJZ_TPPROC = A.EJY_TPPROC AND EJZ.EJZ_REGIST = A.EJY_REGIST "   + cCond2
   
   ElseIf cTipoOpe == INC_PAG .Or. cTipoOpe == CAN_PAG .Or. cTipoOpe == RET_PAG
   
      //cQuery := "SELECT DISTINCT EL1.* FROM " + RetSqlName("EL1") + " EL1 WHERE " + cCond1
      cQuery := "SELECT DISTINCT MIN(EL9.R_E_C_N_O_) AS RECNO, EL9.EL9_FILIAL, EL9.EL9_TPPROC, EL9.EL9_REGIST, EL9.EL9_SEQPAG, EL9.EL9_DOC, EL9.EL9_DTPAG, EL9.EL9_STTSIS, EL9.EL9_DTREG, EL9.EL9_PRAZO,";
                +"SUM(EL9.EL9_VLCAMB) AS EL9_VLCAMB, SUM(EL9.EL9_VLEXT) AS EL9_VLEXT, EL9.EL9_NRINVO, EL9.EL9_PROCES "; //RRC - 02/05/2013 - Adicionados os campos EL9_NRINVO e EL9_PROCES na query para usar na ValidItem()
                +"FROM " + RetSqlName("EL9") + " EL9, " + RetSqlName("EJY") + " EJY " + " WHERE " + cCond1; //FSM
                +" GROUP BY EL9.EL9_FILIAL, EL9.EL9_TPPROC, EL9.EL9_REGIST, EL9.EL9_SEQPAG, EL9.EL9_DOC, EL9.EL9_DTPAG, EL9.EL9_STTSIS, EL9.EL9_DTREG, EL9.EL9_PRAZO, EL9.EL9_NRINVO, EL9.EL9_PROCES"
   EndIf
  
End Sequence

Return cQuery 



/*
Função     : SS101GrvLote()
Parâmetros : oError            
Retorno    : lRet - Retorna se ocorreu a gravação
Objetivos  : Efetua a gravação de Lotes no SISCOSERV
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 05/09/12 - 16:45
Revisao    : 
Obs.       :
*/
*----------------------*
Function SS101GrvLote(oError) 
*----------------------*
Local lRet := .T. ,lSeekEL5 ,lSeekEL6 ,lSeekEL7
Local cNumLote := "", cSeqEL3 := "" , cSeqEL4 := "" , cSeqAd := ""
Local cSeqEL5  := ""
Local i
Local aEnquad  := {} , aSeqAd := {}, aDocs := {}, aAuxItens := {} 
Local cMsgProc := ""
Local nTotCambio   := 0
Local nTotExterior := 0
Local aOrd     := SaveOrd({"EJY","EJX","EL7","EL2","EL1","EJZ"})

If cTipoServ == VENDA  
   
   Do Case  
   
      Case cTipoOpe == INC_REG
         cMsgProc := "Registrando Venda de Serviço (RVS)..."
      Case cTipoOpe == RET_REG
         cMsgProc := "Retificando Venda de Serviço (Retificação RVS)..."
      Case cTipoOpe == INC_ADI
         cMsgProc := "Registrando Aditivo de Venda de Serviço (Aditivo RVS)..."
      Case cTipoOpe == RET_ADI
         cMsgProc := "Retificando Aditivo de Venda de Serviço (Retificação RVS)..."
      Case cTipoOpe == INC_PAG
         cMsgProc := "Registrando Faturamento de Serviço (RF)..."
      Case cTipoOpe == CAN_PAG
         cMsgProc := "Cancelando Faturamento de Serviço (Cancelamento RF)..."
      Case cTipoOpe == RET_PAG
         cMsgProc := "Retificando Faturamento de Serviço (RF)..."  
   
   End Case
  
ElseIf cTipoServ == AQUISICAO     
  
  Do Case 
  
     Case cTipoOpe == INC_REG
        cMsgProc := "Registrando Aquisição de Serviço (RAS)..."
     Case cTipoOpe == RET_REG
        cMsgProc := "Retificando Aquisição de Serviço (Retificação RAS)..."
     Case cTipoOpe == INC_ADI
        cMsgProc := "Registrando Aditivo de Aquisição de Serviço (Aditivo RAS)..."
     Case cTipoOpe == RET_ADI
        cMsgProc := "Retificando Aditivo de Aquisição de Serviço (Retificação RAS)..."
     Case cTipoOpe == INC_PAG
        cMsgProc := "Registrando Pagamento de Serviço (RP)..."
     Case cTipoOpe == CAN_PAG
        cMsgProc := "Cancelando Pagamento de Serviço (Cancelamento RP)..."
     Case cTipoOpe == RET_PAG
        cMsgProc := "Retificando Pagamento de Serviço (RP)..."
  
  EndCase

EndIf     

Begin Sequence

   /*lRet := MsgYesNo("Deseja realmente efetuar a gravação do Lote?","Aviso")
   If !lRet
      Break
   EndIf*/
   
   /*RRC - 17/09/2013 - Quando é Retificação de Aditivo, aItens não tem o Recno do Alias utilizado, já que a query é feita com um
   Group By por Seq.Aditivo (EJZ_SEQAD),pois todos os itens do mesmo aditivo devem ser enviados novamente, sendo assim, guarda o recno da própria work.
   Portanto, é necessário buscar o recno da EJZ através da Seq. Aditivo*/
   If cTipoOpe == RET_ADI   
      EJZ->(DbSetOrder(2))//EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQAD
      For i := 1 To Len(aItens)
         TMP->(DbGoTo(aItens[i]))
         If EJZ->(DbSeek(xFilial("EJZ")+TMP->EJZ_TPPROC+TMP->EJZ_REGIST+TMP->EJZ_SEQAD))
            Do While !EJZ->(Eof()) .And. EJZ->(EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQAD) == xFilial("EJZ")+TMP->(EJZ_TPPROC+EJZ_REGIST+EJZ_SEQAD)
               aAdd(aAuxItens,EJZ->(Recno()))
               EJZ->(DbSkip())
            EndDo
         EndIf
      Next i
      aItens := {}
      aItens := aClone(aAuxItens)
   EndIf
    
   ProcRegua(Len(aItens))
   IncProc(cMsgProc) 
   EJY->(DbSetOrder(1))//EJY_FILIAL+EJY_TPPROC+EJY_REGIST
   EJZ->(DbSetOrder(1))//EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQREG
   EL2->(DbSetOrder(4))//EL2_FILIAL+EL2_TPPROC+EL2_REGIST+EL2_SEQPAG+EL2_SEQDOC
   EL7->(DbSetOrder(1))//EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SEQREG+EL7_SEQPAG+EL7_SEQDOC
   //EL1->(DbSetOrder(1))//EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG+EL1_SEQPAG
   EL1->(DbSetOrder(2))//EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQPAG
      
   Begin Transaction 
      //RRC - 20/09/2013 - Alterado tratamento para gerar o número do lote para considerar todas as filiais, ou seja, o id nunca se repetirá, não importando a filial
      cNumLote := EasySX8Seq("EL8","EL8_IDLOTE",1)
      
      For i := 1 To Len(aItens) 
                                 
         //INC_REG - "1" = Registro de Aquisição de Serviço (RAS) / Registro de Venda de Serviço (RVS)
         //RET_REG - "2" = Retificação de Aquisição de Serviço (Retificação RAS) / Retificação de Venda de Serviço (Retificação RVS)  
         If cTipoOpe == INC_REG .Or. cTipoOpe == RET_REG
                   
             EJY->(DbGoTo(aItens[i]))
             cSeqEL3 := SS101PrxNum("EL3",xFilial("EL3")+EJY->EJY_TPPROC+EJY->EJY_REGIST,1,"EL3_SQEVCP")//FSM - EJZ->EJZ_FILIAL
                       
             //Gravando a Capa RAS/RVS SISCOSERV
             If EL3->(RecLock("EL3",.T.))
                EL3->EL3_FILIAL := xFilial("EL3")
                EL3->EL3_TPPROC := EJY->EJY_TPPROC
                EL3->EL3_REGIST := EJY->EJY_REGIST 
                EL3->EL3_SQEVCP := cSeqEL3
                EL3->EL3_TIPENV := IF(cTipoOpe == INC_REG, "1", "2")
                EL3->EL3_NROREG := ""
                /*
                If cTipoServ == AQUISICAO
                   SA2->(DbSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA
                   If SA2->(DbSeek(xFilial("SA2") + EJY->EJY_EXPORT + EJY->EJY_LOJEXP ))
                      EL3->EL3_NOME   := SA2->A2_NOME
                      EL3->EL3_END    := SA2->A2_END
                      EL3->EL3_PAIS   := SA2->A2_PAIS
                      EL3->EL3_NIF    := SA2->A2_NIFEX
                   EndIf
                ElseIf cTipoServ == VENDA
                   SA1->(DbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
                   If SA1->(DbSeek(xFilial("SA1") + EJY->EJY_IMPORT + EJY->EJY_LOJIMP ))
                      EL3->EL3_NOME   := SA1->A1_NOME
                      EL3->EL3_END    := SA1->A1_END
                      EL3->EL3_PAIS   := SA1->A1_PAIS
                      EL3->EL3_NIF    := SA1->A1_NIF
                   EndIf
                EndIf
                */
                
                If cTipoServ == AQUISICAO
                   EL3->EL3_NOME   := EJY->EJY_DSCEXP
                ElseIf cTipoServ == VENDA
                   EL3->EL3_NOME   := EJY->EJY_DSCIMP
                EndIf
                
                EL3->EL3_END    := EJY->EJY_END
                EL3->EL3_PAIS   := PaisSisc(EJY->EJY_PAIS)//LRS
                EL3->EL3_NIF    := EJY->EJY_NIF
                      
                EL3->EL3_COMPL  := EJY->EJY_COMPL
                EL3->EL3_MOEDA  := Posicione( "SYF", 1 , xFilial("SYF") + Avkey(EJY->EJY_MOEDA,"YF_MOEDA") , "YF_COD_GI" ) //RRC
                EL3->EL3_IDLOTE := cNumLote             
                
                If EasyGParam('MV_ESS0021',,.F.)
                   If EL3->(FieldPos("EL3_CGC"))>0 .And. EJY->(FieldPos("EJY_CGC"))>0
                      EL3->EL3_CGC    := If(Empty(EJY->EJY_CGC),SM0->M0_CGC,EJY->EJY_CGC)//FSY 16/10/2013
                   End If               
                ElseIf EL3->(FieldPos("EL3_CGC"))>0
                   EL3->EL3_CGC := SM0->M0_CGC
                End If
                If EasyGParam("MV_ESS0027",,9) >= 10
                   EL3->EL3_MOTNIF := EJY->EJY_MOTNIF
                   EL3->EL3_TIPVIN := EJY->EJY_TIPVIN //If(EJY->EJY_TIPVIN <> "0",EJY->EJY_TIPVIN,"")
                EndIf
                If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL3->(FieldPos("EL3_TPINT")) # 0
                   EL3->EL3_TPINT := cValToChar(EasyGParam("MV_ESS0028"))
                EndIf
             EL3->(MsUnlock())
             EndIf 
          
             //Gravando Detalhes RAS/RVS SISCOSERV
             If EJZ->(DbSeek(xFilial("EJZ") + EJY->EJY_TPPROC + EJY->EJY_REGIST ))
                While EJZ->(!EOF()) .And. EJZ->EJZ_FILIAL == xFilial("EJZ");
                                    .And. EJZ->EJZ_TPPROC == EJY->EJY_TPPROC;
                                    .And. EJZ->EJZ_REGIST   == EJY->EJY_REGIST
             
                   If (!Empty(EJZ->EJZ_SEQAD) .And. EJZ->EJZ_SEQAD <> "000") .Or. (cTipoOpe == RET_REG .And. Empty(EJZ->EJZ_SEQAD))
                      EJZ->(DbSkip())
                      Loop
                   EndIf
                
                   cSeqEL4 := SS101PrxNum("EL4",EJZ->EJZ_FILIAL+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG,1,"EL4_SQEVIT")//FSM
                   //Array com os Enquadramentos
                   aEnquad := {}
                   aEnquad := SS101Enquad()
                
                   If EL4->(RecLock("EL4",.T.))
                
                      EL4->EL4_FILIAL := xFilial("EL4")
                      EL4->EL4_TPPROC := EJZ->EJZ_TPPROC
                      EL4->EL4_REGIST   := EJZ->EJZ_REGIST
                      EL4->EL4_SEQREG := EJZ->EJZ_SEQREG
                      EL4->EL4_SQEVIT := cSeqEL4
                      EL4->EL4_SQEVCP := cSeqEL3
                      EL4->EL4_TIPENV := IF(cTipoOpe == INC_REG, "1", "2")
                      EL4->EL4_NROREG := ""
                      EL4->EL4_NBS    := EJZ->EJZ_NBS
                      EL4->EL4_PAIS   := PaisSisc(EJZ->EJZ_PAIS)//LRS
                      EL4->EL4_MODO   := EJZ->EJZ_MODO
                      EL4->EL4_DTINI  := EJZ->EJZ_DTINI
                      
                      If !Empty(EJZ->EJZ_DTFIM)
                         EL4->EL4_DTFIM := EJZ->EJZ_DTFIM
                      Else
                         EL4->EL4_DTFIM := EJZ->EJZ_DTPRFI
                      EndIf
                      
                      EL4->EL4_VALOR  := EJZ->EJZ_VL_MOE
                      EL4->EL4_ENQ01  := aEnquad[1][1]
                      EL4->EL4_RC01   := aEnquad[1][2]
                      EL4->EL4_EXCL1  := aEnquad[1][3]
                      EL4->EL4_ENQ02  := aEnquad[2][1]
                      EL4->EL4_RC02   := aEnquad[2][2]
                      EL4->EL4_EXCL2  := aEnquad[2][3]
                      EL4->EL4_ENQ03  := aEnquad[3][1]
                      EL4->EL4_RC03   := aEnquad[3][2]
                      EL4->EL4_EXCL3  := aEnquad[3][3]
                      EL4->EL4_IDLOTE := cNumLote
                      EL4->EL4_SEQAD  := "000"
                      If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL4->(FieldPos("EL4_TPINT")) # 0
                         EL4->EL4_TPINT := cValToChar(EasyGParam("MV_ESS0028"))
                      EndIf
                
                   EL4->(MsUnlock())
                   EndIf
                   /*
                   //Gravando Documentos SISCOSERV
                   If EL2->(DbSeek(xFilial("EL2") + EJZ->EJZ_TPPROC + EJZ->EJZ_REGIST))
                      
                      While EL2->(!EOF()) .And. EL2->EL2_FILIAL == xFilial("EL2");
                                          .And. EL2->EL2_TPPROC == EJZ->EJZ_TPPROC;
                                          .And. EL2->EL2_REGIST   == EJZ->EJZ_REGIST//;
                                          //.And. EL2->EL2_SEQREG == EJZ->EJZ_SEQREG

                         If EL2->EL2_STTDOC == "4"//Cancelado no SISCOSERV
                            EL2->(DbSkip())
                            Loop 
                         EndIf 
                                       
                         lSeekEL7 := EL7->(DbSeek(xFilial("EL2")+EL2->EL2_TPPROC+EL2->EL2_REGIST+EL2->EL2_SEQREG+EL2->EL2_SEQPAG+EL2->EL2_SEQDOC ))
                      
                         If EL7->(RecLock("EL7",!lSeekEL7))
                            EL7->EL7_FILIAL := xFilial("EL7")
                            EL7->EL7_TPPROC := EL2->EL2_TPPROC
                            EL7->EL7_REGIST   := EL2->EL2_REGIST
                            EL7->EL7_SEQREG := EL2->EL2_SEQREG
                            EL7->EL7_SEQPAG := EL2->EL2_SEQPAG
                            EL7->EL7_SEQDOC := EL2->EL2_SEQDOC
                            EL7->EL7_RE     := EL2->EL2_RE
                            EL7->EL7_DI     := EL2->EL2_DI
                            EL7->EL7_SQEVCP := cSeqEL3
                            EL7->EL7_EXCL   := If(EL2->EL2_STTDOC == INC_ADI,"2","1")
                         EL7->(MsUnLock())
                         EndIf
                         
                         EL2->(DbSkip())
                      EndDo
                   EndIf               
                   */                             
                   If EJZ->(RecLock("EJZ",.F.))
                      EJZ->EJZ_SEQAD  := "000"
                   EJZ->(MsUnlock())    
                   EndIf

                EJZ->(DbSkip())
                EndDo

                //Gravando Documentos SISCOSERV
                //If EL2->(DbSeek(xFilial("EL2") + EJZ->EJZ_TPPROC + EJZ->EJZ_REGIST)) //RRC - 28/08/2013 - Adicionado EL2_SEQPAG no seek para evitar conflito com documentos de pagamento/faturamento
                If EL2->(DbSeek(xFilial("EL2") + EJY->EJY_TPPROC + EJY->EJY_REGIST + Space(AvSx3("EL2_SEQPAG",AV_TAMANHO))))
                   While EL2->(!EOF()) .And. EL2->EL2_FILIAL == xFilial("EL2");
                                       .And. EL2->EL2_TPPROC == EJY->EJY_TPPROC;
                                       .And. EL2->EL2_REGIST == EJY->EJY_REGIST;
                                       .And. Empty(EL2->EL2_SEQREG) .And. Empty(EL2->EL2_SEQPAG)
                                       //.And. EL2->EL2_SEQREG == EJZ->EJZ_SEQREG
                      //NOPADO por RRC - 17/10/2012
                      //If EL2->EL2_STTDOC == "4"//Cancelado no SISCOSERV
                        // EL2->(DbSkip())
                        // Loop 
                      //EndIf                       
                      aDocs := {}
                      aDocs := SS101Docs() 
                                      
                      //lSeekEL7 := EL7->(DbSeek(xFilial("EL2")+EL2->EL2_TPPROC+EL2->EL2_REGIST+EL2->EL2_SEQREG+EL2->EL2_SEQPAG+EL2->EL2_SEQDOC ))
                      If EL7->(RecLock("EL7",.T./*!lSeekEL7*/)) //RRC                        
                         EL7->EL7_FILIAL := xFilial("EL7")
                         EL7->EL7_TPPROC := EL2->EL2_TPPROC
                         EL7->EL7_REGIST   := EL2->EL2_REGIST
                         EL7->EL7_SEQREG := EL2->EL2_SEQREG
                         EL7->EL7_SEQPAG := EL2->EL2_SEQPAG
                         EL7->EL7_SEQDOC := EL2->EL2_SEQDOC
                         //If !(EasyGParam("MV_ESS0027",,9) >= 10)
                            EL7->EL7_RE     := aDocs[1]
                            EL7->EL7_DI     := aDocs[2]
                         //EndIf
                         If EasyGParam("MV_ESS0027",,9) >= 10
                            EL7->EL7_NBS    := EL4->EL4_NBS
                         EndIf
                         If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL7->(FieldPos("EL7_TPINT")) # 0
                            EL7->EL7_TPINT := cValToChar(EasyGParam("MV_ESS0028"))
                         EndIf
                         EL7->EL7_SQEVCP := cSeqEL3
                         EL7->EL7_EXCL   := aDocs[3]
                         EL7->EL7_IDLOTE := cNumLote
                         EL7->(MsUnLock())
                      EndIf
                                     
                  EL2->(DbSkip())                    
                  EndDo                                                  
               EndIf               

            EndIf
      
         //INC_ADI - "3" = Aditivo ao Registro de Aquisição de Serviço (Aditivo RAS) / Aditivo ao Registro de Venda de Serviço (Aditivo RVS)
         //RET_ADI - "4" = Retificação de Aditivo de Aquisição de Serviço (Retificação RAS) / Retificação de Aditivo de Venda de Serviço (Retificação RVS)        
         ElseIf  cTipoOpe == INC_ADI .Or. cTipoOpe == RET_ADI   
          
            EJZ->(DbGoTo(aItens[i]))
                  
            cSeqEL4 := SS101PrxNum("EL4",xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG,1,"EL4_SQEVIT") //FSM - EJZ->EJZ_FILIAL
            cSeqEL3 := SS101PrxNum("EL3",xFilial("EL3")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST,1,"EL3_SQEVCP") //FSM - EJZ->EJZ_FILIAL+
            cSeqEL3 := StrZero(Val(cSeqEL3) - 1, AVSX3("EL3_SQEVCP",AV_TAMANHO))
            If (nPos:= aScan(aSeqAd,{|x|  AllTrim(x[1]) == AllTrim(EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST) })) > 0
               cSeqAd := aSeqAd[nPos][2]    
            Else
               cSeqAd  := SS101PrxNum("EJZ",EJZ->EJZ_FILIAL+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST,2,"EJZ_SEQAD") //FSM
               AADD(aSeqAd,{EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST,cSeqAd})
            EndIf
          
            //Array com os Enquadramentos
            aEnquad := {}
            aEnquad := SS101Enquad()
           
            //Gravando Detalhes RAS/RVS SISCOSERV - Aditivos      
            If EL4->(RecLock("EL4",.T.))
                
               EL4->EL4_FILIAL := xFilial("EL4")
               EL4->EL4_TPPROC := EJZ->EJZ_TPPROC
               EL4->EL4_REGIST   := EJZ->EJZ_REGIST
               EL4->EL4_SEQREG := EJZ->EJZ_SEQREG
               EL4->EL4_SQEVIT := cSeqEL4
               EL4->EL4_SQEVCP := cSeqEL3
               EL4->EL4_TIPENV := IF(cTipoOpe == INC_ADI, INC_ADI, "4")
               EL4->EL4_NROREG := ""
               EL4->EL4_NBS    := EJZ->EJZ_NBS
               EL4->EL4_PAIS   := PaisSisc(EJZ->EJZ_PAIS)//LRS
               EL4->EL4_MODO   := EJZ->EJZ_MODO
               EL4->EL4_DTINI  := EJZ->EJZ_DTINI
               
               If !Empty(EJZ->EJZ_DTFIM)
                  EL4->EL4_DTFIM := EJZ->EJZ_DTFIM
               Else
                  EL4->EL4_DTFIM := EJZ->EJZ_DTPRFI
               EndIf
               
               EL4->EL4_VALOR  := EJZ->EJZ_VL_MOE
               EL4->EL4_ENQ01  := aEnquad[1][1]
               EL4->EL4_RC01   := aEnquad[1][2]
               EL4->EL4_EXCL1  := aEnquad[1][3]
               EL4->EL4_ENQ02  := aEnquad[2][1]
               EL4->EL4_RC02   := aEnquad[2][2]
               EL4->EL4_EXCL2  := aEnquad[2][3]
               EL4->EL4_ENQ03  := aEnquad[3][1]
               EL4->EL4_RC03   := aEnquad[3][2]
               EL4->EL4_EXCL3  := aEnquad[3][3]
               EL4->EL4_IDLOTE := cNumLote 
               If Empty(EJZ->EJZ_SEQAD)
                  EL4->EL4_SEQAD  := cSeqAd
               Else
                  EL4->EL4_SEQAD  := EJZ->EJZ_SEQAD 
               EndIf
               If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL4->(FieldPos("EL4_TPINT")) # 0
                  EL4->EL4_TPINT := cValToChar(EasyGParam("MV_ESS0028"))
               EndIf
            EL4->(MsUnlock())
            EndIf
            
            If Empty(EJZ->EJZ_SEQAD) .And. EJZ->(RecLock("EJZ",.F.))
               EJZ->EJZ_SEQAD  := cSeqAd
            EJZ->(MsUnlock())    
            EndIf
        
         //INC_PAG - "05" = Registro de Pagamento de Serviço (RP) / Registro de Faturamento de Serviço (RF)
         //CAN_PAG - "06" = Cancelamento de Pagamento de Serviço (Cancelamento RP) / Cancelamento de Faturamento de Serviço (Cancelamento RF)    
         ElseIf cTipoOpe == INC_PAG .Or. cTipoOpe == CAN_PAG .Or. cTipoOpe == RET_PAG
            nTotCambio   := 0 //RRC - 09/03/2013 - Zera os valores referentes a cada pagamento (EL5)
            nTotExterior := 0
            
            EL9->(DbGoTo(aItens[i]))
            EL5->(DbSetOrder(1))//EL5_FILIAL+EL5_TPPROC+EL5_REGIST+EL5_SEQPAG+EL5_SQEVPG
            //EL1->(DbSetOrder(1))//EL5_FILIAL+EL5_TPPROC+EL5_REGIST+EL5_SEQPAG+EL5_SQEVPG
            EL1->(DbSetOrder(2))//EL1_FILIAL + EL1_TPPROC + EL1_REGIST + EL1_SEQPAG
            cSeqEL5  := SS101PrxNum("EL5",xFilial("EL5")+EL9->EL9_TPPROC+EL9->EL9_REGIST+EL9->EL9_SEQPAG,1,"EL5_SQEVPG") //FSM - EL1->EL1_FILIAL
            lSeekEL5 := EL5->(DbSeek(xFilial("EL5") + EL9->EL9_TPPROC + EL9->EL9_REGIST + EL9->EL9_SEQPAG + cSeqEL5)) //EL6_SQEVPG
            
            
            //Gravando Pagamentos SISCOSERV
            EL5->(RecLock("EL5",!lSeekEL5))
         
            EL5->EL5_FILIAL := xFilial("EL5")
            EL5->EL5_TPPROC := EL9->EL9_TPPROC
            EL5->EL5_REGIST := EL9->EL9_REGIST 
            EL5->EL5_SEQPAG := EL9->EL9_SEQPAG
            EL5->EL5_SQEVPG := cSeqEL5
            EL5->EL5_TIPENV := If(EL9->EL9_STTSIS == "1","1",If(EL9->EL9_STTSIS == "5","3","2"))
            EL5->EL5_NROREG := ""
            EL5->EL5_DOC    := EL9->EL9_DOC
            EL5->EL5_DTPAG  := EL9->EL9_DTPAG
            EL5->EL5_VLCAMB := EL9->EL9_VLCAMB
            EL5->EL5_VLEXT  := EL9->EL9_VLEXT
            EL5->EL5_IDLOTE := cNumLote
            //RRC - 02/10/2013 - Alterado tratamento para gerar o número do lote para considerar todas as filiais
            EL5->EL5_PAGID  := EasySX8Seq("EL5","EL5_PAGID",4,.T.)
            If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL5->(FieldPos("EL5_TPINT")) # 0
               EL5->EL5_TPINT := cValToChar(EasyGParam("MV_ESS0028"))
            EndIf
            ConfirmSX8()
                        
            //Gravando detalhe do pagamento no EL6
            //DAR SEEK PELOS CAMPOS xFilial("EL5"), EL1->EL1_TPPROC,EL1->EL1_REGIST, EL1->EL1_SEQPAG
            //If EL6->(DbSeek(xFilial("EL6") +  EL1->EL1_TPPROC + EL1->EL1_REGIST + EL1->EL1_SEQREG + EL1->EL1_SEQPAG))
            EL6->(DbSetOrder(1))//'EL6_FILIAL + EL6_TPPROC + EL6_REGIST + EL6_SEQPAG + EL6_SQEVPG + EL6_SEQREG
            EL1->(DbSeek(xFilial("EL1") + EL9->EL9_TPPROC + EL9->EL9_REGIST + EL9->EL9_SEQPAG)) //EL6_SQEVPG
            Do While EL1->(!EOF()) .And. EL1->EL1_FILIAL == xFilial("EL1");
                                   .And. EL1->EL1_TPPROC == EL5->EL5_TPPROC;
                                   .And. EL1->EL1_REGIST   == EL5->EL5_REGIST;
                                   .And. EL1->EL1_SEQPAG == EL5->EL5_SEQPAG
               
               lSeekEL6 := EL6->(DbSeek(xFilial("EL6") + EL1->EL1_TPPROC + EL1->EL1_REGIST + EL1->EL1_SEQPAG + cSeqEL5 + EL1->EL1_SEQREG))//+EL6_SQEVPG
               
               EL6->(RecLock("EL6",!lSeekEL6))
               EL6->EL6_FILIAL := xFilial("EL6")
               EL6->EL6_TPPROC := EL1->EL1_TPPROC
               EL6->EL6_REGIST   := EL1->EL1_REGIST
               EL6->EL6_SEQPAG := EL1->EL1_SEQPAG
               EL6->EL6_SQEVPG := cSeqEL5
               EL6->EL6_SEQREG := EL1->EL1_SEQREG
               EL6->EL6_VLCAMB := EL1->EL1_VLCAMB//SOMAR E GRAVAR NO VALOR DO EL5 valor cambio
               EL6->EL6_VLEXT  := EL1->EL1_VLEXT //SOMAR E GRAVAR NO VALOR DO EL5 valor movido no exterior
               If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL6->(FieldPos("EL6_TPINT")) # 0
                  EL6->EL6_TPINT := cValToChar(EasyGParam("MV_ESS0028"))
               EndIf
               EL6->(MsUnlock())

               //nTotCambio   += EL1_VLCAMB
               //nTotExterior += EL1_VLEXT
               
               EL1->(dbSkip())
            End Do
            
            //EL5->EL5_VLCAMB := nTotCambio
            //EL5->EL5_VLEXT  := nTotExterior
            EL5->(MsUnlock())

            EL9->(DbGoTo(aItens[i]))
            //Gravando Documentos SISCOSERV
            If EL9->EL9_STTSIS <> "4" .And. EL2->(DbSeek(xFilial("EL2") +  EL9->EL9_TPPROC + EL9->EL9_REGIST + EL9->EL9_SEQPAG))
               While EL2->(!EOF()) .And. EL2->EL2_FILIAL == xFilial("EL2");
                                   .And. EL2->EL2_TPPROC == EL9->EL9_TPPROC;
                                   .And. EL2->EL2_REGIST == EL9->EL9_REGIST;
                                   .And. EL2->EL2_SEQPAG == EL9->EL9_SEQPAG
                  
                  //NOPADO por RRC - 18/10/2012
                  /*If EL2->EL2_STTDOC == "4"//Cancelado no SISCOSERV
                     EL2->(DbSkip())
                     Loop
                  EndIf */
                  
                  lSeekEL7 := EL7->(DbSeek(xFilial("EL2")+EL2->EL2_TPPROC+EL2->EL2_REGIST+EL2->EL2_SEQREG+EL2->EL2_SEQPAG+EL2->EL2_SEQDOC+cSeqEL5))
                  
                  EL7->(RecLock("EL7",!lSeekEL7))
                  EL7->EL7_FILIAL := xFilial("EL7")
                  EL7->EL7_TPPROC := EL2->EL2_TPPROC
                  EL7->EL7_REGIST := EL2->EL2_REGIST
                  EL7->EL7_SEQREG := EL2->EL2_SEQREG
                  EL7->EL7_SEQPAG := EL2->EL2_SEQPAG
                  EL7->EL7_SEQDOC := EL2->EL2_SEQDOC
                  If !(EasyGParam("MV_ESS0027",,9) >= 10)
                     EL7->EL7_RE     := EL2->EL2_RE
                     EL7->EL7_DI     := EL2->EL2_DI
                  Else
                     EL7->EL7_NBS    := EL4->EL4_NBS
                  EndIf
                  EL7->EL7_SQEVCP := cSeqEL5
                  EL7->EL7_EXCL   := If(EL9->EL9_STTSIS == INC_ADI,"2","1")
                  EL7->EL7_IDLOTE := cNumLote
                  If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL7->(FieldPos("EL7_TPINT")) # 0
                     EL7->EL7_TPINT := cValToChar(EasyGParam("MV_ESS0028"))
                  EndIf
                  EL7->(MsUnLock())
                 
                  EL2->(DbSkip())
               EndDo
            EndIf 

         EndIf
      
      IncProc()
        
      Next i     
                                                      
      //Gravando Lote SISCOSERV
      SS101GrvEL8("N",cTipoServ,cTipoOpe,cNumLote)//Nao Enviados 

      //Numero do Lote
      ConfirmSX8() 
   End Transaction 
   
   //Destrava todos os registros
   EJY->(MSUnLockAll())
   EJZ->(MSUnLockAll())
   EL9->(MSUnLockAll())
   
   
End Sequence   

//RRC - 14/03/2013 - Caso seja integração por XML, deve gerar o arquivo.zip contendo os XML no momento da geração do lote
If EasyGParam("MV_AVG0221",,"INI") == "XML"
   ESSCI102(aItens,cTipoOpe,,oError)
EndIf
RestOrd(aOrd,.T.)
Return lRet



/*
Função     : SS101GrvEL8()
Parâmetros : cStatus   - Status do Lote no SISCOSERV            
Retorno    : -
Objetivos  : Grava a tabela de integração de Lotes no SISCOSERV
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 05/09/12 - 16:45
Revisao    : 
Obs.       :
*/
*---------------------------------------------------------*
Function SS101GrvEL8(cStatus,cTpProc,cTpEnv,cIdLote,cErros,oError)
*---------------------------------------------------------*
Local lRet := .T.
Local aCampos := {}
Local lSeek   := {}
Local cMsgErr := "" , cDesStatus := "" 
Local cExtArqRec
Local cExtArqEnv
Local aOrdEL8 := SaveOrd("EL8")
Default cErros := ""

If ValType(oError) == "O" 
   If !Empty(cErros)
      cErros += ENTER
   EndIf
   cErros += oError:GetStrErrors()
EndIf

If EasyGParam("MV_AVG0221",,"INI") == "XML"
   cExtArqRec := ".xml"
   cExtArqEnv := ".zip"
Else
   cExtArqRec := ".ret"
   cExtArqEnv := ".ini"
EndIf

cTpEnv := AllTrim(Str(Val(cTpEnv)))
   

Begin Sequence

   EL8->(DbSetOrder(2))//EL8_FILIAL+EL8_IDLOTE

   lSeek   := EL8->( DbSeek( xFilial("EL8") + AvKey(cIdLote,"EL8_IDLOTE"))) 
   /*
   If !lSeek
      If lObjError 
         oError:Error(StrTran('O Lote "###" não pode ser enviado, pois não foi encontrado registro que comprove sua geração.', "###", cIdLote))
      Else         
         cMsgErr := StrTran('O Lote "###" não pode ser enviado, pois não foi encontrado registro que comprove sua geração.', "###", cIdLote)
      EndIf
      lRet    := .F.
      Break
   EndIf
   */
   
   Do Case
      Case cStatus == NAO_ENVIADO
         aCampos := {"EL8_DATAG", "EL8_HORAG", "EL8_USERG"}
      Case cStatus == ENVIADO
         aCampos := {"EL8_DATAE", "EL8_HORAE", "EL8_USERE","EL8_ARQENV"}
      Case cStatus == RECEBIDO
         aCampos := {"EL8_DATAR", "EL8_HORAR", "EL8_USERR","EL8_ARQREC"}
      Case cStatus == PROCESSADO .OR. cStatus == CANCELADO
         aCampos := {"EL8_DATAP", "EL8_HORAP", "EL8_USERP"}
   End Case

   If EL8->(RecLock("EL8",!lSeek))
      EL8->EL8_FILIAL   := xFilial("EL8")
      EL8->EL8_STATUS   := cStatus

      If !lSeek
         EL8->EL8_TPPROC   := cTpProc
         EL8->EL8_TIPENV   := cTpEnv
         EL8->EL8_IDLOTE   := cIdLote
      EndIf

      EL8->&(aCampos[1]):= dDataBase
      EL8->&(aCampos[2]):= Time()
      EL8->&(aCampos[3]):= cUserName 
      If cStatus == ENVIADO
         EL8->&(aCampos[4]):= cIdLote + cExtArqEnv
      ElseIf cStatus == RECEBIDO
         EL8->&(aCampos[4]):= cIdLote + cExtArqRec
      EndIf
      EL8->EL8_NROREG   := ""
      
      If lSeek .AND. !Empty(EL8->EL8_CODERR)
         MSMM(EL8->EL8_CODERR,,,,EXCMEMO)
      EndIf
      
      If !Empty(cErros)
         MsMM(,AVSX3("EL8_ERROS",AV_TAMANHO),,cErros,INCMEMO,,,"EL8","EL8_CODERR")
      EndIf
      If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL8->(FieldPos("EL8_TPINT")) # 0
         EL8->EL8_TPINT := cValToChar(EasyGParam("MV_ESS0028"))
      EndIf
      EL8->(MsUnLock())
   EndIf

End Sequence   

RestOrd(aOrdEL8,.T.)

Return lRet 
/*
Função     : SS101PrxNum()
Parâmetros : cAlias - Tabela
             cKey   - Chave do Indice
             nOrdem - Ordem do Indice
             cCampo - Campo que será gerado a sequencia
Retorno    : cSeq - Proxima sequencia a ser utilizada
Objetivos  : Verifica a ultima sequencia da tabela e somar + 1
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 04/09/12 - 15:30
Revisao    : 
Obs.       :
*/
*----------------------------------------------*
Function SS101PrxNum(cAlias,cKey,nOrdem,cCampo)
*--------------------------------------------- *
Local cSeq := ""
Local nOrdOld, nRecOld

nOrdOld  := (cAlias)->(IndexOrd())
nRecOld:= (cAlias)->(Recno()) 
(cAlias)->(DbSetOrder(nOrdem))
If (cAlias)->(!EOF()) .And. (cAlias)->(AVSeekLast(cKey))   
   cSeq := SomaIt((cAlias)->&(cCampo))
Else
   cSeq := StrZero ( 1, AVSX3(cCampo,AV_TAMANHO) )
EndIf

(cAlias)->(DbSetOrder(nOrdOld))
If nRecOld > 0 
   (cAlias)->(DbGoTo(nRecOld))
EndIf


Return cSeq 


/*
Função     : SS101Enquad()
Parâmetros : -
Retorno    : aEnq - [1] - Enquadramento
                    [2] - Numero RC
                    [3] - Status "1" - Inclusão ou "2" Exclusão 
Objetivos  : Verifica se o enquadramento foi incluido ou excluido e retorna seus respectivos valores
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 04/09/12 - 15:30
Revisao    : 
Obs.       :
*/
*-------------------------*
Function SS101Enquad() 
*-------------------------*
Local aEnq := {} 
Local nOrdOld, nRecOld 

Begin sequence

   nOrdOld  := EL4->(IndexOrd())
   nRecOld:= EL4->(Recno()) 

   EL4->(DbSetOrder(1))//EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG+EL4_SQEVIT 
   
   //NOPADO por RRC - 24/10/2012
   //If EL4->(!EOF()) .And. EL4->(AVSeekLast(xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG))   
   If EL4->(!EOF()) .And. SS101PosSeqAnt("EL4", xFilial("EL4")+EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG,{|| EL8->EL8_STATUS == PROCESSADO})
      If !Empty(EJZ->EJZ_ENQ01) .Or. Empty(EL4->EL4_ENQ01)
         AADD(aEnq,{EJZ->EJZ_ENQ01,EJZ->EJZ_RC01,"1"})   
      Else   
         AADD(aEnq,{EL4->EL4_ENQ01,EL4->EL4_RC01,"2"})    
      EndIf
      
      
      If !Empty(EJZ->EJZ_ENQ02) .Or. Empty(EL4->EL4_ENQ02)
         AADD(aEnq,{EJZ->EJZ_ENQ02,EJZ->EJZ_RC02,"1"})   
      Else   
         AADD(aEnq,{EL4->EL4_ENQ02,EL4->EL4_RC02,"2"}) 
      EndIf
      
      If !Empty(EJZ->EJZ_ENQ03) .Or. Empty(EL4->EL4_ENQ03)
         AADD(aEnq,{EJZ->EJZ_ENQ03,EJZ->EJZ_RC03,"1"})   
      Else   
         AADD(aEnq,{EL4->EL4_ENQ03,EL4->EL4_RC03,"2"}) 
      EndIf
    
   
   Else
      AADD(aEnq,{EJZ->EJZ_ENQ01,EJZ->EJZ_RC01,"1"})
      AADD(aEnq,{EJZ->EJZ_ENQ02,EJZ->EJZ_RC02,"1"})
      AADD(aEnq,{EJZ->EJZ_ENQ03,EJZ->EJZ_RC03,"1"})   
   EndIf

   EL4->(DbSetOrder(nOrdOld))
   If nRecOld > 0 
      EL4->(DbGoTo(nRecOld))
   EndIf
   
   
End Sequence

Return aClone(aEnq) 


*------------------------------*
Function SS101GetLogEnd(cStatus, oError)
*------------------------------*
Local cRet := "" 

If cStatus == ENVIADO
   If !oError:HasErrors()
      cRet += "ENVIO DOS DADOS AO SISCOSERV REALIZADO COM SUCESSO!"
   Else
      cRet += "ENVIO DOS DADOS AO SISCOSERV NÃO REALIZADO!"+ENTER
      cRet += "Verifique o log dos erros encontrados:"+ENTER
      cRet += oError:GetStrErrors(oError:aError)
   EndIf
ElseIf cStatus == PROCESSADO
   If !oError:HasErrors()
      cRet += "PROCESSAMENTO DO(s) LOTE(s) REALIZADO COM SUCESSO!"+ENTER
      
      If Len(oError:aWarning) > 0
         cRet += "Avisos:"+ENTER
         cRet += oError:GetStrErrors(oError:aWarning)
      EndIf
   Else
      cRet += "PROCESSAMENTO DO(s) LOTE(s) NÃO FOI CONCLUÍDO."+ENTER
      cRet += "Verifique os erros encontrados:"+ENTER
      cRet += oError:GetStrErrors(oError:aError)
   EndIf
EndIf

return cRet
   

/*
Função     : SS101LogInt() 
Parâmetros : cLog - Log da integração em texto
Retorno    :
Objetivos  : Retornar o log da integração 
Autor      : Nilson César C. Filho
Data/Hora  : 09/10/2012 - 15:30
Revisao    : 
Obs.       :
*/
FUNCTION SS101LogInt(cLog) 

Local cTexto       := ''
Local cFile        := ""
Local cMask        := "Arquivos Texto (*.TXT) |*.txt|"
//Geração dos arquivos de Integração
      
      cTexto := "**********LOG DA INTEGRAÇÃO**********"+ENTER+cTexto 
      __cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
			
      Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
         Define MsDialog oDlg Title "Processamento Finalizado" From 3,0 to 340,417 Pixel //STR0066 "Geração concluida."

         @ 5,5 Get oMemo  Var cLog MEMO Size 200,145 Of oDlg Pixel
         oMemo:bRClicked := {||AllwaysTrue()}
         oMemo:oFont:=oFont

         Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
         Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
      Activate MsDialog oDlg Center


Return .T.

Function SS101ProcLote(cTpServ, cTpOpe, cNroLote,oCentral,lReproc)
Local oPanel, oWizard 
Local lRet          := .F.
Local cTitulo       := ""
//Local bCancel       := {|| CloseTables(), oWizard:oDlg:End() } //RMD - 11/04/17 - Na versão 12, precisa informar o Modal e o Owner
Local bCancel       := {|| CloseTables(), oWizard:oModal:oOwner:End()() }
Local bValidCancel  := {|| If(!lLoteProc .And. MsgYesNo("Confirma o cancelamento?", "Aviso"),Eval(bCancel) , If(lLoteProc,MsgInfo("A ação é inválida, para processar um lote novamente é necessário finalizar esta operação."),.F.))   }
Local aBlockAction  := {}
Local oError         := AvObject():New()
Local lNext         := .F.
Local nRadio1       := 1
Local cFase         := ""
Local cTextoAux     := ""
Local lArqAnt       := (cTpServ == AQUISICAO .And. File(ARQ_REPROC_A)) .Or. (cTpServ == VENDA .And. File(ARQ_REPROC_V))
Local lLoteProc     := .F. //RRC - 26/08/2013 - Variável para impedir que o usuário clique em "Voltar" ou "Cancelar" após processar o lote
Default lReproc     := .F.
Default cTpOpe      := ""
Default cNroLote    := ""
Private aRetArqs    := {}
Private oProgress   := EasyProgress():New(.F.)
Private lDelArq     := .T.

//RRC - 02/05/2013 - Alteração para permitir reprocessar os lotes que não foram processados corretamente
If lReproc .And. !LockActions(cTpServ)
   EasyHelp( "Não foi possível utilizar a opção de forma exclusiva. Verifique se algum outro usuário do sistema está realizando a operação de Reprocessar no momento.")
   Return lRet
ElseIf IsFileLock(cTpServ)
   //RRC - 19/08/2013
   /*Variável lArqAnt verifica se o arquivo já estava criado antes do usuário clicar em "Reprocessar": quando essa opção era acionada e o usuário não avançava, não iniciava
   /o reprocessamento, mas o arquivo já era criado. Com este controle, o arquivo será apagado, a menos que ele já esteja no \system devido a um outro reprocessamento incompleto.*/
   //lDelArq := .F.
   lDelArq := !lArqAnt
   If !lReproc
      EasyHelp("Não é possível utilizar esta funcionalidade pois existe um reprocessamento pendente.","Aviso")
      Return lRet
   EndIf
EndIf

If lReproc
   cFase := "REPROCESSAR"
   If cTpServ == AQUISICAO 
      cTitulo := "Reprocessamento de Aquisição"
   ElseIf cTpServ == VENDA
      cTitulo := "Reprocessamento de Venda"
   EndIf 
Else
   cFase := "PROCESSAR"
EndIf      

If !SS101ValAcao(cFase, cTpServ, cTpOpe, cNroLote)
   Return lRet
EndIf

//RRC - 03/05/2013 - Caso seja um reprocessamento, a função SS101ValAcao() irá posicionar no primeiro lote já processado, de Aquisição ou Venda
If lReproc
   cNroLote := EL8->EL8_IDLOTE
EndIf

If cTpServ == AQUISICAO 

  Do Case
  
     Case cTpOpe == INC_REG
        cTitulo := "Registro de Aquisição de Serviço (RAS)" 
     Case cTpOpe == RET_REG
        cTitulo := "Retificação de Aquisição de Serviço (Retificação RAS)"
     Case cTpOpe == INC_ADI
        cTitulo := "Aditivo ao Registro de Aquisição de Serviço (Aditivo RAS)"
     Case cTpOpe == RET_ADI
        cTitulo := "Retificação de Aditivo de Aquisição de Serviço (Retificação RAS)"
     Case cTpOpe == INC_PAG
        cTitulo := "Registro de Pagamento de Serviço (RP)"
     Case cTpOpe == CAN_PAG
        cTitulo := "Cancelamento de Pagamento de Serviço (Cancelamento RP)" 
     Case cTpOpe == RET_PAG
        cTitulo := "Retificação de Pagamento de Serviço (RP)"  
  
  End Case
  
  
ElseIf cTpServ == VENDA


  Do Case
  
     Case cTpOpe == INC_REG
        cTitulo := "Registro de Venda de Serviço (RVS)"
     Case cTpOpe == RET_REG
        cTitulo := "Retificação de Venda de Serviço (Retificação RVS)"
     Case cTpOpe == INC_ADI
        cTitulo := "Aditivo ao Registro de Venda de Serviço (Aditivo RVS)"
     Case cTpOpe == RET_ADI
        cTitulo := "Retificação de Aditivo de Venda de Serviço (Retificação RVS)"
     Case cTpOpe == INC_PAG
        cTitulo := "Registro de Faturamento de Serviço (RF)"
     Case cTpOpe == CAN_PAG
        cTitulo := "Cancelamento de Faturamento de Serviço (Cancelamento RF)"
     Case cTpOpe == RET_PAG
        cTitulo := "Retificação de Faturamento de Serviço (RF)"
          
  End Case

EndIF

cWiz_Title   := "Wizard de Integração SISCOSERV"
cWiz_Header  := "Início"
cWiz_Message := "Apresentação"
//RRC - 03/05/2013
If !lReproc
   cWiz_Text := "Bem vindo ao assistente de Integração com o SISCOSERV, essa rotina é utilizada para auxiliá-lo na integração de " +;
             cTitulo + " que tem como objetivo registrar as informações no SISCOSERV. Clique no botão AVANCAR para que os "+;
             "arquivos retornados do SISCOSERV sejam processados e os dados sejam atualizados no sistema."
Else
   cWiz_Text := "Bem vindo ao assistente de Integração com o SISCOSERV, essa rotina tem como objetivo reprocessar todos os lotes " +;
                "do sistema, com o intuito de recuperar dados. "   
EndIf
                     //PanelName ,Vld. Back , Vld. Next                                                                  ,Vld. Fin 
//RRC - 26/08/2013 - Criado novo panel inicial para funcionamento do botão "voltar", já que o USER_PNO só estava sendo utilizado na tela de "Preparação de Arquivos" e a validação do PanelBack() impede essa ação para ele
//aAdd( aBlockAction , {"USER_PN0" ,{||.T.} , {|| oProgress:SetProcess({|| SS101RetLote(nRadio1,cNroLote,oCentral,oError,lReproc,cTpServ)},"Processando os dados..."),oProgress:Init(),lLoteProc := .T.}                , {||.T.}       })
//aAdd( aBlockAction , {"USER_PN1" ,{||.T.} , {||.T.}                                                                    , {||.T.}       })  
aAdd( aBlockAction , {"USER_PN0" ,{||.F.}   , {|| .T.}                                                                    , {||.T.}       })
aAdd( aBlockAction , {"USER_PN1" ,{||.T.}   , {|| oProgress:SetProcess({|| SS101RetLote(nRadio1,cNroLote,oCentral,oError,lReproc,cTpServ)},"Processando os dados..."),oProgress:Init(),lLoteProc := .T.}                , {||.T.}       })
aAdd( aBlockAction , {"USER_PN2" ,{||.T.}   , {||  oProgress:SetProcess({|| SS101FinLote(nRadio1,cNroLote,oCentral,oError,lReproc,cTpServ)},"Processando os dados...")}                                                                    , {||.T.}       })  


DEFINE WIZARD oWizard TITLE   cWiz_Title;
                      HEADER  cWiz_Header;
                      MESSAGE cWiz_Message;
                      TEXT    cWiz_Text;
                      PANEL   ;
                      NEXT    {|| PanelNext( oWizard,aBlockAction[1] )};
                      FINISH  aBlockAction[1][4]
   //RRC - 26/08/2013
   oPanel  := oWizard:oMPanel[Len(oWizard:oMPanel)]
   oPanel:cName := aBlockAction[1][1]//"USER_PN0"
   
   CREATE PANEL oWizard HEADER "Preparacao dos Arquivos"  ;
                        MESSAGE cTitulo;
						PANEL;
						BACK	{|| PanelBack(oWizard,aBlockAction[2]) };
						NEXT	{|| PanelNext(oWizard,aBlockAction[2]) };     
						FINISH  aBlockAction[2][4];                        
						EXEC	{|| .T. }  
	  oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
      oPanel:cName := aBlockAction[2][1]
      //RRC - 03/05/2013
      If !lReproc
         aOptions1:= {"Processar todos os lotes pendentes.",;
                   "Processar apenas o lote '"+cNroLote+"'"}
      
         @ 10,30 TO 50,220 LABEL "Seleção de Lotes" OF oPanel PIXEL
         oRadio1:= tRadMenu():New(20,35,aOptions1, {|u| If(PCount() > 0, nRadio1:=u, nRadio1)}, oPanel,,,,,,,,205,110,,,,.T.)     
         oSay1 := TSay():New ( 50, 30, {||'Clique no botão AVANÇAR para que os arquivos sejam processados.'}, oPanel, , oWizard:oHeaderMsg:oFont, , , , .T., CLR_BLUE, CLR_WHITE, 200, 100, , , , , ,  )         
      Else
         If cTpServ == AQUISICAO
            cTextoAux :=  "- Registro de Aquisição de Serviço (RAS);" + ENTER
            cTextoAux +=  "- Retificação de Aquisição de Serviço (Retificação RAS);" + ENTER
            cTextoAux +=  "- Aditivo ao Registro de Aquisição de Serviço (Aditivo RAS);" + ENTER
            cTextoAux +=  "- Retificação de Aditivo de Aquisição de Serviço (Retificação RAS);" + ENTER
            cTextoAux +=  "- Registro de Pagamento de Serviço (RP);" + ENTER
            cTextoAux +=  "- Cancelamento de Pagamento de Serviço (Cancelamento RP)." + ENTER + ENTER    
         ElseIf cTpServ == VENDA
            cTextoAux :=  "- Registro de Venda de Serviço (RVS);" + ENTER
            cTextoAux +=  "- Retificação de Venda de Serviço (Retificação RVS);" + ENTER
            cTextoAux +=  "- Aditivo ao Registro de Venda de Serviço (Aditivo RVS);" + ENTER
            cTextoAux +=  "- Retificação de Aditivo de Venda de Serviço (Retificação RVS);" + ENTER
            cTextoAux +=  "- Registro de Faturamento de Serviço (RF);" + ENTER
            cTextoAux +=  "- Cancelamento de Faturamento de Serviço (Cancelamento RF)." + ENTER + ENTER
         EndIf
         oSay1 := TSay():New ( 20, 10, {||'Atenção: O sistema irá reprocessar todos os lotes anteriores de ' + If(cTpServ==AQUISICAO,'Aquisição','Venda') + ' independentemente do tipo a que pertençam: '+ ENTER + cTextoAux + ' Clique em AVANÇAR para reprocessar as informações.'}, oPanel, , oWizard:oHeaderMsg:oFont, , , , .T., CLR_BLUE, CLR_WHITE, 200, 120, , , , , ,  )         
      
      EndIf  
   CREATE PANEL oWizard HEADER "Finalização"  ;
                        MESSAGE cTitulo;
						PANEL;
						BACK	{|| MsgInfo("A ação é inválida, para processar um lote novamente é necessário finalizar esta operação."),.F.}; //RRC - 26/08/2013 - Impede que o usuário clique em "Voltar" pois o processamento já foi realizado
						NEXT	{|| PanelNext(oWizard,aBlockAction[3]) };     
						FINISH aBlockAction[3][4];                        
						EXEC	{|| .T. }
						
      oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
      oPanel:cName := aBlockAction[3][1]         
      oSay2 := TSay():New ( 20, 10, {|| SS101GetLogEnd(PROCESSADO,oError) }, oPanel, , oWizard:oHeaderMsg:oFont, , , , .T., CLR_BLUE, CLR_WHITE, 200, 100, , , , , ,  )         


   oWizard:oCancel:bAction := bValidCancel
   oWizard:oDlg:Owner():lEscClose:= .F.         

ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

If lReproc  //RRC - 06/05/2013 - Assegura que o arquivo de controle não seja apagado, o que indica que o usuário não terminou o reprocessamento pendente
   //Se lDelArq for .T., ou nem foi iniciado o reprocessamento ou o mesmo foi completado com êxito, sendo assim, poderá apagar o arquivo de controle
   //Caso contrário, somente poderá fechar o arquivo
   UnLockActions(cTpServ,lDelArq)
EndIf     
Return lRet 

Function SS101RetLote(nRadio1,cNroLote, oCentral, oError, lReproc,cTpServ)
Local cChave   := ""
Local cQuery   := ""  
Local cIniInteg := ESSCI100:cDirRecebidos+cNroLote+EXT_INI
Local cRetInteg := ESSCI100:cDirRecebidos+cNroLote+EXT_RET
Local lArqXML
Local lProc  := .T.
Local aLotes, i
Local aLotReg := {}
Local aLotAdt := {}
Local aLotPag := {}
Local nTotLotes := 0
Default lReproc := .F.
Default cTpServ := ""
cChave := xFilial("EL8")+cNroLote
EL8->(dbSetOrder(2)) //EL8_FILIAL+EL8_IDLOTE
EL8->(dbSeek(cChave))

//RRC - 02/07/2013 - Variável para marcar o início do reprocessamento, neste caso, é criado um arquivo para garantir que nenhuma outra ação seja executada até o seu fim
If lReproc .And. Type("lDelArq") == "L"
   lDelArq := .F.
EndIf

Begin Sequence

If nRadio1 == 1
   If lReproc
      cChave := xFilial("EL8")+EL8->(EL8_TPPROC+EL8_STATUS)
      EL8->(dbSetOrder(3))//EL8_FILIAL+EL8_TPPROC+EL8_STATUS
   Else
      cChave := xFilial("EL8")+EL8->(EL8_TPPROC+EL8_TIPENV+EL8_STATUS)
      EL8->(dbSetOrder(1))//EL8_FILIAL+EL8_TPPROC+EL8_TIPENV+EL8_STATUS+EL8_IDLOTE   
   EndIf
   EL8->(dbSeek(cChave))
EndIf

//Este loop só processará 1 registro quando nRadio1 for 2 (o numero do lote é unico)
aLotes := {}
Do While EL8->(!EoF() .AND. Left(&(IndexKey()),Len(cChave)) == cChave)
   aAdd(aLotes,{oCentral:cDirRecebidos+EL8->EL8_ARQREC,EL8->EL8_IDLOTE})   
   If EL8->EL8_TIPENV $ "1/2"
      aAdd(aLotReg,EL8->EL8_IDLOTE)
   ElseIf EL8->EL8_TIPENV $ "3/4"
      aAdd(aLotAdt,EL8->EL8_IDLOTE)
   ElseIf EL8->EL8_TIPENV $ "5/6"                                                                           
      aAdd(aLotPag,EL8->EL8_IDLOTE)
   EndIf
   EL8->(dbSkip())
EndDo

//RRC - 10/05/2013 - Cria work temporária para medir o tempo previsto do processamento
//Monta query com os lotes relacionados a registros
If Len(aLotReg) > 0
   cQuery := SS101QryProc(aLotReg,"1")

   EasyWkQuery(cQuery,"WK_REG")
   nTotLotes := WK_REG->(EasyRecCount()) 
   If select("WK_REG") > 0
      WK_REG->(dbClosearea())
   EndIf
EndIf
//Monta query com os lotes relacionados a pagamentos
If Len(aLotAdt) > 0
   cQuery := SS101QryProc(aLotAdt,"2")

   EasyWkQuery(cQuery,"WK_ADT")
   nTotLotes := nTotLotes + WK_ADT->(EasyRecCount()) 
   If select("WK_ADT") > 0
      WK_ADT->(dbClosearea())
   EndIf
EndIf
//Monta query com os lotes relacionados a aditivos
If Len(aLotPag) > 0
   cQuery := SS101QryProc(aLotPag,"3")

   EasyWkQuery(cQuery,"WK_PAG")
   nTotLotes := nTotLotes + WK_PAG->(EasyRecCount()) 
   If select("WK_PAG") > 0
      WK_PAG->(dbClosearea())
   EndIf
EndIf

lArqXML := .F. /* Nopado para assumir default .F. - EasyGParam("MV_AVG0221",,"INI") == "XML"*/
oProgress:SetRegua(nTotLotes)

For i := 1 To Len(aLotes)
   If lArqXML
      lProc := .T. /* nopado por RNLP e variavel assume o default .T. - Função nao compilada/declarada em nenhum fonte do sistema - SS102ProcRet(aLotes[i][1],aLotes[i][2],oError)*/
   Else
      lProc := SS103ProcRet(aLotes[i][1],aLotes[i][2],oError)
   EndIf

Next i

If lReproc .And. i>Len(aLotes)//Desbloqueia as demais ações caso o reprocessamento tenha sido completado, apagando o arquivo de controle
   If Type("lDelArq") == "L"
      lDelArq := .T.
   EndIf
   UnLockActions(cTpServ)
EndIf
	
End Sequence

If select("WK_REG") > 0
   WK_REG->(dbClosearea())
EndIf

If select("WK_PAG") > 0
   WK_REG->(dbClosearea())
EndIf

Return .T.

Static Function GetComparacao(cTabela, cTipoProc, lForcaComp)
Local aCompara := {}
Default lForcaComp := .F.

If cTabela == "EJZ"
   aAdd(aCompara,{'EL4_NBS   ','EJZ_NBS   '})
   aAdd(aCompara,{'EL4_PAIS  ','PaisSisc(EJZ_PAIS)  '})
   aAdd(aCompara,{'EL4_MODO  ','EJZ_MODO  '})
   //LRS - 04/04/2017 - Nopado para atualizar o status do Processo mesmo com Manual 10
// If !(EasyGParam("MV_ESS0027",,9) >= 10)
      aAdd(aCompara,{'EL4_DTINI ','EJZ_DTINI '})
      aAdd(aCompara,{'EL4_DTFIM ','if(!Empty(EJZ_DTFIM),EJZ_DTFIM,EJZ_DTPRFI)'})
      aAdd(aCompara,{'EL4_VALOR ','EJZ_VL_MOE'})
// EndIf
   aAdd(aCompara,{'EL4_ENQ01 ','EJZ_ENQ01 '})
   aAdd(aCompara,{'EL4_RC01  ','EJZ_RC01  '})
   aAdd(aCompara,{'EL4_ENQ02 ','EJZ_ENQ02 '})
   aAdd(aCompara,{'EL4_RC02  ','EJZ_RC02  '})
   aAdd(aCompara,{'EL4_ENQ03 ','EJZ_ENQ03 '})
   aAdd(aCompara,{'EL4_RC03  ','EJZ_RC03  '})
   
ElseIf cTabela == "EJY"
   If cTipoProc == "A"
      aAdd(aCompara,{'EL3_NOME  ','EJY_DSCEXP'})
   Else
      aAdd(aCompara,{'EL3_NOME  ','EJY_DSCIMP'})
   EndIf
   aAdd(aCompara,{'EL3_END   ','EJY_END   '})
   aAdd(aCompara,{'EL3_PAIS  ','PaisSisc(EJY_PAIS)  '})
   aAdd(aCompara,{'EL3_NIF   ','EJY_NIF   '})
   If EasyGParam("MV_ESS0027",,9) >= 10
      aAdd(aCompara,{'EL3_MOTNIF','EJY_MOTNIF'})
      aAdd(aCompara,{'EL3_TIPVIN','EJY_TIPVIN'})
   EndIf
   aAdd(aCompara,{'EL3_COMPL ','EJY_COMPL '})
   aAdd(aCompara,{'EL3_MOEDA ','Posicione("SYF",1,xFilial("SYF")+Avkey(EJY->EJY_MOEDA,"YF_MOEDA"),"YF_COD_GI")'}) //RRC
   
ElseIf cTabela == "EL2" .AND. ((EasyGParam("MV_ESS0027",,9) >= 10) .OR. lForcaComp)
   aAdd(aCompara,{'EL7_RE    ','EL2_RE    '})
   aAdd(aCompara,{'EL7_DI    ','EL2_DI    '})

ElseIf cTabela == "EL9"
   aAdd(aCompara,{'EL5_VLCAMB','EL9_VLCAMB'})
   aAdd(aCompara,{'EL5_VLEXT ','EL9_VLEXT '})
   aAdd(aCompara,{'EL5_DOC   ','EL9_DOC   '})

   
EndIf

Return aClone(aCompara)

Static Function Compara(cAlias1, cAlias2, aComparacao, cProcesso, oErros)
Local i, nInd, lRet  := .T.

//RRC - 04/03/2013 - Verifica se no lote atual há conteúdo em branco para enquadramentos, DI ou RE (exclusão). Se a chamada vier do SS101DadosRet()
//mas não do Cadastro do RAS ou RVS, está ocorrendo o processamento do lote e não deve comparar, porque eles estarão com conteúdo em branco no
//cadastro, porém, o lote de retificação grava os dados novamente, mas o campo de exclusão para enquadramentos ou documentos receberá "2",
// indicando que o item foi excluído, logo não há diferenças encontradas.
If cAlias1 == "EL4"
   For i := 1 To 3
      If &("EL4->EL4_EXCL"+AllTrim(Str(i))) == "2" .And. (nInd := aScan(aComparacao,{|x| AllTrim(x[2]) == 'EJZ_ENQ0'+AllTrim(Str(i))})) > 0 .And. Empty((cAlias2)->(&(aComparacao[nInd][2]))) 
         aDel(aComparacao,nInd)
         aSize(aComparacao,Len(aComparacao)-1)
         If (nInd := aScan(aComparacao,{|x| AllTrim(x[2]) == 'EJZ_RC0'+AllTrim(Str(i))})) > 0
            aDel(aComparacao,nInd)
            aSize(aComparacao,Len(aComparacao)-1)
         EndIf
      EndIf
   Next i   
ElseIf cAlias1 == "EL7" .And. EL7->EL7_EXCL == "2"
   //No caso de pagamentos, pode haver RE e DI 
   If(nInd := aScan(aComparacao,{|x| AllTrim(x[2]) == 'EL2_DI'})) > 0 .And. Empty((cAlias2)->(&(aComparacao[nInd][2]))) 
      If(nInd := aScan(aComparacao,{|x| AllTrim(x[2]) == 'EL2_RE'})) > 0 .And. Empty((cAlias2)->(&(aComparacao[nInd][2]))) 
         Return lRet       
      EndIf
   EndIf
EndIf

For i := 1 To Len(aComparacao)
   xVal1 := (cAlias1)->(&(aComparacao[i][1]))
   xVal2 := (cAlias2)->(&(aComparacao[i][2]))   
   If ValType(xVal1) <> ValType(xVal2)
      oErros:Error("Tipos diferentes nos campos '"+aComparacao[i][1]+"' e '"+aComparacao[i][2]+"'.")
      lRet := .F.
      EXIT                                                                                  
   //MFR TE-6365 WCC-525538 MTRADE-1381             
   //ElseIf !Upper(AllTrim(cValToChar(xVal1))) == Upper(AllTrim(cValToChar(xVal2)))     
   ElseIf ! Upper(AllTrim(StrTran(StrTran(StrTran(cValToChar(xVal2),chr(13),""),chr(09),""),chr(10),""))) == Upper(AllTrim(StrTran(StrTran(StrTran(cValToChar(xVal1),chr(13),""),chr(09),""),chr(10),"")))     
      oErros:Warning("Encontrada diferença no processo '"+cProcesso+"'. Valor atual do campo "+AvSx3(aComparacao[i][1],AV_TITULO)+" é '"+Upper(AllTrim(cValToChar(xVal1)))+"', mas o valor enviado ao SISCOSERV é '"+Upper(AllTrim(cValToChar(xVal2)))+"').")
      lRet := .F.
      EXIT
   EndIf
Next i

Return lRet

Function SS101DadosRet(cTipo,oDados,lProc)
Local lRet    := .T. 
Local aOrd    := SaveOrd({"EJY","EL3","EL4","EL5","EL6","EL7"})
Local cBusca  := ""
Local cMsg    := ""
Local nAdi    := 0
Local lSeekAdi:= .T.
Local nRecAdi, nRecEL8, nRecEJY
Default lProc := .T.  //Verifica se deve processar os dados de retorno, caso contrário, a chamada veio da Rotina de Registro de Serviços
/*RRC - 14/11/2012 - Se a variável lProc for .F., significa que a chamada veio da rotina de Registro de Serviços, sendo assim, não fará os processos,
mas apenas a verificação dos status*/
If cTipo == "REGISTRO" .And. !lProc
   EL4->(DbSetOrder(2))//EL4_FILIAL+EL4_IDLOTE+EL4_TPPROC+EL4_REGIST+EL4_SEQREG
   cBusca := xFilial("EL4") + EL3->EL3_IDLOTE + EL3->EL3_TPPROC + oDados:GetValue("PROC")   
   aCompara := GetComparacao("EJZ",EL3->EL3_TPPROC)  
   If EL4->(DbSeek(cBusca))      
      Do While EL4->(!EOF() .And. EL4_FILIAL + EL4_IDLOTE + EL4_TPPROC + EL4_REGIST == cBusca)     
         AtualizaStatus("EJZ",aCompara,oDados,.F.)
         EL4->(DbSkip())
      EndDo
   Else
      cMsg += "Serviço não localizado no lote " + AllTrim(EL3->EL3_IDLOTE) + "."   
   EndIf
   
   //Verifica a existência de aditivos para atualizar o status
   Do While lSeekAdi
      nAdi++
      EL4->(DbSetOrder(4)) //EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQAD+EL4_SQEVCP
      If EL4->(DbSeek(xFilial("EL4") + EL3->EL3_TPPROC + oDados:GetValue("PROC") + StrZero(nAdi,AvSx3("EJZ_SEQAD",3))))
         cBusca := xFilial("EL4") + EL4->EL4_TPPROC + EL4->EL4_REGIST + EL4->EL4_SEQAD 
         Do While EL4->(!EOF() .And. EL4_FILIAL + EL4_TPPROC + EL4_REGIST + EL4_SEQAD == cBusca)    
            nRecAdi := EL4->(Recno())
            If SS101PosSeqAnt("EL4", xFilial("EL4")+ EL4->EL4_TPPROC + EL4->EL4_REGIST + EL4->EL4_SEQREG , {|| EL8->EL8_STATUS == PROCESSADO})
               aCompara := GetComparacao("EJZ",EL4->EL4_TPPROC)     
               AtualizaStatus("EJZ",aCompara,oDados,.F.)            
            EndIf
            EL4->(DbGoTo(nRecAdi))
            EL4->(DbSetOrder(4))
            EL4->(DbSkip())
         EndDo
      Else
         lSeekAdi := .F.
      EndIf
   EndDo
   EL7->(DbSetOrder(3))
   cBusca   := xFilial("EL7")+EL3->EL3_TPPROC+oDados:GetValue("PROC")+EL3->EL3_SQEVCP
   aCompara := GetComparacao("EL2",EL3->EL3_TPPROC)                                                    
   If EL7->(DbSeek(cBusca))      
      Do While EL7->(!EOF() .And. EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP == cBusca)     
         //RRC - 27/08/2013 - Verifica se é o mesmo lote
         If EL7->EL7_IDLOTE == EL3->EL3_IDLOTE 
            AtualizaStatus("EL2",aCompara,oDados)
         EndIf
         EL7->(DbSkip())
      EndDo   
   EndIf
   
   RS400StaReg(EJY->EJY_TPPROC,EJY->EJY_REGIST,EJY->EJY_DTENC)//Atualizar o status de acordo com o novo status dos serviços e dos documentos.    
   //RS401StatPg(EJY->EJY_TPPROC,EJY->EJY_REGIST)//Atualiza status do pagamento, que pode ser: '1=Em aberto;2=Parcialmente liquidado;3=Liquidado;',
   AtualizaStatus("EJY",GetComparacao("EJY",EJY->EJY_TPPROC),oDados,.F.)
   RS400DtReg(EJY->EJY_TPPROC,EJY->EJY_REGIST)//Atualiza a Data de Registro da Capa do Processo                
   If !Empty(cMsg)
      EasyHelp(cMsg,"Aviso")
   EndIf
ElseIf cTipo == "REGISTRO"  
   EL3->(dbSetOrder(2))//EL3_FILIAL+EL3_IDLOTE+EL3_TPPROC+EL3_REGIST 
   If EL3->(dbSeek(xFilial()+EL8->(EL8_IDLOTE+EL8_TPPROC)+oDados:GetValue("PROC")))
   
      RecLock("EL3",.F.)
      EL3->EL3_NROREG := oDados:GetValue("NROREG")
      EL3->(MsUnLock())
      
      aCompara := GetComparacao("EJZ",EL8->EL8_TPPROC)
      
      cChave := xFilial("EL4")+EL8->(EL8_IDLOTE+EL8_TPPROC)+oDados:GetValue("PROC")
      EL4->(dbSetOrder(2))//EL4_FILIAL+EL4_IDLOTE+EL4_TPPROC+EL4_REGIST+EL4_SEQREG
      EL4->(dbSeek(cChave)) 
      Do While EL4->(!Eof() .AND. EL4_FILIAL+EL4_IDLOTE+EL4_TPPROC+EL4_REGIST == cChave)        
         If AtualizaStatus("EJZ", aCompara, oDados)
            RecLock("EL4",.F.)
            EL4->EL4_NROREG := oDados:GetValue("NROREG")
            EL4->(MsUnLock())
         EndIf 
         EL4->(dbSkip())
      EndDo
      
      aCompara := GetComparacao("EL2",EL8->EL8_TPPROC,EasyGParam("MV_ESS0027",,9) >= 10)

      cChave := xFilial("EL7")+EL3->(EL3_TPPROC+EL3_REGIST+EL3_SQEVCP)
      EL7->(dbSetOrder(3))//EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP
      EL7->(dbSeek(cChave))
      Do While EL7->(!Eof() .AND. EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP == cChave)
         //RRC - 27/08/2013 - Verifica se é o mesmo lote
         If EL7->EL7_IDLOTE == EL3->EL3_IDLOTE .And. AtualizaStatus("EL2",aCompara,oDados)
            RecLock("EL7",.F.)
            EL7->EL7_NROREG := oDados:GetValue("NROREG")
            EL7->(MsUnLock())
         EndIf
         
         EL7->(dbSkip())
      EndDo
   
   //NOPADO por RRC - 24/10/2012
   //SS101GrvEL8(PROCESSADO,EL8->EL8_TPPROC,EL8->EL8_TIPENV,EL8->EL8_IDLOTE,oDados:GetValue("ERROS"))
   //If EJY->EJY_STTSIS == "3"
   RS400StaReg(EL8->EL8_TPPROC,oDados:GetValue("PROC"))//Atualizar o status de acordo com o novo status dos serviços e dos documentos.
   //EndIf
   nRecEJY := EJY->(Recno()) 
   EJY->(DbSetOrder(1))
   If EJY->(DbSeek(xFilial("EJY")+EL8->EL8_TPPROC+AvKey(oDados:GetValue("PROC"),"EJY_REGIST")))
      AtualizaStatus("EJY",GetComparacao("EJY",EL8->EL8_TPPROC),oDados)
   EndIf   
   //RRC - 30/10/2012 - Atualiza a Data de Registro da Capa do Processo
   RS400DtReg(EL8->EL8_TPPROC,oDados:GetValue("PROC"))
      
   /*RRC - 23/10/2012 - Verifica se o Registro poderá ser considerado Encerrado, neste caso, a Data de Encerramento será preenchida e o status
   do Processo dos Serviços será atualizado*/
   If EJY->EJY_STTSIS == "3" //Registrado no SISCOSERV //wfs 22/05/17
      VerDtEnc(EL8->EL8_TPPROC,oDados:GetValue("PROC"))     
   EndIf
   EJY->(DbGoTo(nRecEJY))
   Else
      oDados:Error("O Processo " + AllTrim(oDados:GetValue("PROC")) + " do lote " + AllTrim(EL8->EL8_IDLOTE) + " não foi localizado.") 
   EndIf
   
ElseIf cTipo $ "ADITIVO"
   
   //Posiciona no ultimo envio da capa para verificar se houveram alterações
   /*
   EL3->(dbSetOrder(1))//EL3_FILIAL+EL3_TPPROC+EL3_REGIST+EL3_SQEVCP
   
   nPosLote := EL8->(RecNo())
   
   EL3->(AvSeekLast(xFilial()+EL8->EL8_TPPROC+oDados:GetValue("PROC")))
   Do While !EL3->(BoF()) .AND. EL8->( !dbSeek(xFilial()+EL3->EL3_IDLOTE) .OR. EL8_STATUS <> PROCESSADO )
      EL3->(dbSkip(-1))
   EndDo
   
   EL8->(dbGoTo(nPosLote))
   */
   
   //RRC - 11/01/2013
   /*Irá posicionar no último Registro de Serviço (EL3) do qual faz parte o aditivo, mas vai desposicionar a EL8, pois os
   lotes serão diferentes, por isso guarda o recno*/
   nRecEL8 := EL8->(Recno())
   If SS101PosSeqAnt("EL3", xFilial("EL3")+EL8->EL8_TPPROC+oDados:GetValue("PROC"), {|| EL8->EL8_STATUS == PROCESSADO})
      EL8->(DbGoTo(nRecEL8))
      aCompara := GetComparacao("EJZ",EL8->EL8_TPPROC)
      
      cChave := xFilial("EL4")+EL8->(EL8_IDLOTE+EL8_TPPROC)+oDados:GetValue("PROC")
      EL4->(dbSetOrder(2))//EL4_FILIAL+EL4_IDLOTE+EL4_TPPROC+EL4_REGIST+EL4_SEQREG
      If EL4->(dbSeek(cChave))
         Do While EL4->(!Eof() .AND. EL4_FILIAL+EL4_IDLOTE+EL4_TPPROC+EL4_REGIST == cChave)
            If AtualizaStatus("EJZ", aCompara, oDados)
               RecLock("EL4",.F.)
               EL4->EL4_NROREG := oDados:GetValue("AD_NROREG")
               EL4->(MsUnLock())
            EndIf
            EL4->(dbSkip())
         EndDo
      
         //NOPADO por RRC - 24/10/2012
         //SS101GrvEL8(PROCESSADO,EL8->EL8_TPPROC,EL8->EL8_TIPENV,EL8->EL8_IDLOTE,oDados:GetValue("ERROS"))
      
         //If EJY->EJY_STTSIS == "3"
         //Atualizar o status de acordo com o novo status dos serviços e dos documentos.
         RS400StaReg(EL8->EL8_TPPROC,oDados:GetValue("PROC"))//Atualizar o status de acordo com o novo status dos serviços e dos documentos.
         //EndIf
         nRecEJY := EJY->(Recno()) 
         EJY->(DbSetOrder(1))
         //Atualiza status da capa conforme alterações com relação ao ultimo envio.
         If EJY->(DbSeek(xFilial("EJY")+EL8->EL8_TPPROC+AvKey(oDados:GetValue("PROC"),"EJY_REGIST")))
            AtualizaStatus("EJY",GetComparacao("EJY",EL8->EL8_TPPROC),oDados)
         EndIf 
              
         //RRC - 30/10/2012 - Atualiza a Data de Registro da Capa do Processo
         RS400DtReg(EL8->EL8_TPPROC,oDados:GetValue("PROC"))
      
         /*RRC - 23/10/2012 - Verifica se o Registro poderá ser considerado Encerrado, neste caso, a Data de Encerramento será preenchida e os status
         do Processo dos Serviços será atualizado*/
         //VerDtEnc(EL8->EL8_TPPROC,oDados:GetValue("PROC"))
         EJY->(DbGoTo(nRecEJY))
      Else
         oDados:Error("O aditivo do processo " + AllTrim(oDados:GetValue("PROC")) + " do lote " + AllTrim(EL8->EL8_IDLOTE) + " não foi localizado.") 
      EndIf
   Else
      oDados:Error("O Processo " + AllTrim(oDados:GetValue("PROC")) + " do lote " + AllTrim(EL8->EL8_IDLOTE) + " não foi localizado para envio do aditivo.") 
   EndIf
   
ElseIf cTipo $ "PAGAMENTO"
   
   //EL5->(dbSetOrder(2)) // EL5_FILIAL + EL5_IDLOTE + EL5_TPPROC + EL5_REGIST + EL5_SEQPAG
   //EL6->(DbSetOrder(1)) // EL6_FILIAL + EL6_TPPROC + EL6_REGIST + EL6_SEQPAG + EL6_SQEVPG + EL6_SEQREG
   EL5->(dbSetOrder(3)) // EL5_FILIAL + EL5_IDLOTE + EL5_TPPROC + EL5_REGIST + EL5_PAGID
     
   If EL5->(DbSeek(xFilial("EL5") + EL8->(EL8_IDLOTE+EL8_TPPROC) + oDados:GetValue("PROC") + AvKey(AllTrim(oDados:GetValue("PAGID")),"EL5_PAGID") ))
      //RRC - 02/05/2013 - Para cada pagamento, realiza o loop, devido ao índice
      //Do While EL5->(!Eof()) .And. EL5->(EL5_FILIAL + EL5_IDLOTE + EL5_TPPROC + EL5_REGIST) == xFilial("EL8") + EL8->(EL8_IDLOTE+EL8_TPPROC) + oDados:GetValue("PROC") //RRC - 09/01/2013   
         //If EL6->(DbSeek(xFilial('EL6') + EL5->EL5_TPPROC + EL5->EL5_REGIST + EL5->EL5_SEQPAG + EL5->EL5_SQEVPG))
         //RRC - 02/05/2013 - Gera um Número de Registro diferente para cada pagamento do processo
         AtualizaStatus("EL9",,oDados)
         VerDtEnc(EL5->EL5_TPPROC,oDados:GetValue("PROC")) //LRS 
         RecLock("EL5",.F.)
         EL5->EL5_NROREG := Alltrim(oDados:GetValue("PAG_NROREG"))
         EL5->(MsUnLock())                                 
            
         //Documentos vinculados ao pagamentos
         aCompara := GetComparacao("EL2",EL8->EL8_TPPROC)
         cChave := xFilial("EL7")+EL5->(EL5_TPPROC+EL5_REGIST+EL5_SEQPAG)
         EL7->(dbSetOrder(2)) // EL7_FILIAL + EL7_TPPROC + EL7_REGIST + EL7_SEQPAG
            
         If EL7->(dbSeek(cChave))
            Do While EL7->(!Eof()) .And. EL7->(EL7_FILIAL + EL7_TPPROC + EL7_REGIST + EL7_SEQPAG) == cChave
               //RRC - 27/08/2013 - O documento deve fazer parte do mesmo lote do pagamento/faturamento
               If EL5->EL5_IDLOTE == EL7->EL7_IDLOTE
                  RecLock("EL7",.F.)
                  EL7->EL7_NROREG := Alltrim(oDados:GetValue("PAG_NROREG")) //RRC - 09/01/2013       
                  EL7->(MsUnLock())
               EndIf
               EL7->(DbSkip())                  
            EndDo
         EndIf
         //EndIf
      //   EL5->(DbSkip())
      //EndDo
   Else
      oDados:Error(If(EL8->EL8_TPPROC=="A","O pagamento","O faturamento") + " do processo " + AllTrim(oDados:GetValue("PROC")) + " do lote " + AllTrim(EL8->EL8_IDLOTE) + " não foi localizado.") 
   EndIf
   
EndIf
RestOrd(aOrd,.T.)
Return lRet

Static Function AtualizaStatus(cTabela, aCompara, oDados, lProcessa)
Local lRet  := .T.
Local aOrdens := SaveOrd({"EJZ","EJY","EL9","EL2","EL7"}) 
Local cSeekEL9 := ""
Local cStatus  := ""
Default lProcessa := .T., aCompara := {} 

If cTabela == "EJZ"
   EJZ->(dbSetOrder(1))//EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQREG
   If (lRet := EJZ->(dbSeek(xFilial("EJZ")+EL4->(EL4_TPPROC+EL4_REGIST+EL4_SEQREG))))
      
      If !Compara("EL4", "EJZ", aCompara, EL4->EL4_REGIST, oDados)
         cStatus := "2" //Parcialmente registrado, já que existe diferença entre os dados do registro e do lote registrado.
      Else
         cStatus := "3" //Registrado no SISCOSERV.
      EndIf
      
      EL7->(dbSetOrder(3))//EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP
      If EasyGParam("MV_ESS0027",,9) >= 10 .AND. IsInCallStack("ESSRS400") .AND. EL7->(DbSeek(xFilial("EL7")+EL3->(EL3_TPPROC+EL3_REGIST+EL3_SQEVCP))) .AND. !Compara("EL7", "EL2", GetComparacao("EL2",EJY->EJY_TPPROC,.T.), EL3->EL3_REGIST, oDados)
         cStatus := "2" //Parcialmente registrado, já que existe diferença entre os dados do registro e do lote registrado.
      EndIf
      
      RecLock("EJZ",.F.)
      EJZ->EJZ_STTSIS := cStatus 
      /*RRC - 14/11/2012 - Controla da onde veio a chamada da função, se tiver vindo da rotina de Registro de Serviços,
      somente verificará os status, pois o valor será .F.*/
      If lProcessa 
         EJZ->EJZ_NROREG := If(oDados:GetValue("AD_NROREG")<>NIL,oDados:GetValue("AD_NROREG"),oDados:GetValue("NROREG"))             
         If EL8->EL8_TIPENV == "2" .Or. EL8->EL8_TIPENV == "4" //Verifica se é uma retificação
            EJZ->EJZ_DTRET := EL8->EL8_DATAR//dDataBase
         ElseIf EL8->EL8_TIPENV == "1" .Or. EL8->EL8_TIPENV == "3" //Verifica se está sendo registrado
            EJZ->EJZ_DTREG := EL8->EL8_DATAR//dDataBase
         EndIf
      EndIf
      EJZ->(MsUnLock())
   Else
      oDados:Error("Não foi possível encontrar o serviço sequencia "+EL4->EL4_SEQREG+" do processo "+AllTrim(EL4->EL4_REGIST) + " do lote " + AllTrim(EL4->EL4_IDLOTE) + ".")
   EndIf
ElseIf cTabela == "EJY"
   EJY->(dbSetOrder(1))//EJY_FILIAL+EJY_TPPROC+EJY_REGIST
   If (lRet := EJY->(dbSeek(xFilial("EJY")+EL3->(EL3_TPPROC+EL3_REGIST))))
      
      If !Compara("EL3", "EJY", aCompara, EL3->EL3_REGIST, oDados) //.AND. If(EasyGParam("MV_ESS0027",,9) >= 10,!Compara("EL7", "EL2", GetComparacao("EL2",EJY->EJY_TPPROC,.T.), EL3->EL3_REGIST, oDados),.T.)       
         cStatus := "2" //Parcialmente registrado, já que existe diferença entre os dados do registro e do lote registrado.
      Else
         cStatus := "3" //Registrado no SISCOSERV.
      EndIf
      
      RecLock("EJY",.F.)
      //RRC - 09/09/2013 - Não deve atualizar o RAS/RVS quando for transmissão de aditivo
      If lProcessa .And. oDados:GetValue("NROREG") <> NIL
         EJY->EJY_NROREG := oDados:GetValue("NROREG")
      EndIf
      /*RRC - 07/11/2012 - O status do registro é atualizado antes pela função RS400StaReg(), se seu status está como
      "Parcialmente Registrado", é devido aos status dos serviços, logo não poderá receber "Registrado no Siscoserv"*/
      If !(EJY->EJY_STTSIS == "2" .And. cStatus == "3")
         EJY->EJY_STTSIS := cStatus
      EndIf
      EJY->(MsUnLock())
   Else
      oDados:Error("Não foi possível encontrar o processo "+AllTrim(EL3->EL3_REGIST) + " do lote " + AllTrim(EL3->EL3_IDLOTE) + ".")
   EndIf
ElseIf cTabela == "EL2"
   //EL2->(dbSetOrder(1))//EL2_FILIAL+EL2_TPPROC+EL2_REGIST+EL2_SEQREG+EL2_SEQPAG+EL2_SEQDOC - Indice antigo para documentos de pagamentos- RRC 22/03/2013
   EL2->(DbSetOrder(4)) //EL2_FILIAL + EL2_TPPROC + EL2_REGIST + EL2_SEQPAG + EL2_SEQDOC
   
   
   If (lRet := EL2->(dbSeek(xFilial("EL2")+EL7->(EL7_TPPROC+EL7_REGIST+EL7_SEQPAG+EL7_SEQDOC))))
      
      If !Compara("EL7", "EL2", aCompara, EL7->EL7_REGIST, oDados)
         cStatus := "2" //Parcialmente registrado, já que existe diferença entre os dados do registro e do lote registrado.
      Else
         cStatus := "3" //Registrado no SISCOSERV.
      EndIf
      
      //RRC - 04/03/2013 - Caso o conteúdo do documento tenho sido apagado do RAS ou RVS, após o registro no Siscoserv faz a exclusão
      RecLock("EL2",.F.)
      If cStatus == "3" .And. Empty(EL2->EL2_DI) .And. Empty(EL2->EL2_RE)
         EL2->(DbDelete())
      Else   
         EL2->EL2_STTSIS := cStatus        
      EndIf
      EL2->(MsUnLock())
   Else
      oDados:Error("Não foi possível encontrar o documento sequencia "+EL7->EL7_SEQDOC+" do processo "+AllTrim(EL7->EL7_REGIST)+" do lote " + AllTrim(EL7->EL7_IDLOTE)+".")
   EndIf
ElseIf cTabela == "EL9"
   //EL1->(DbSetOrder(1))// EL1_FILIAL + EL1_TPPROC + EL1_REGIST + EL1_SEQREG + EL1_PARC + EL1_SEQPAG
   EL9->(DbSetOrder(1))  // EL9_FILIAL + EL9_TPPROC + EL9_REGIST + EL9_SEQPAG
   //NOPADO por RRC - 09/01/2013 - Alterada a chave para buscar os pagamentos
   //If EL1->(DbSeek(xFilial('EL1') + EL6->EL6_TPPROC + EL6->EL6_REGIST + EL6->EL6_SEQREG))
   cSeekEL9 := xFilial('EL9') + EL5->EL5_TPPROC + EL5->EL5_REGIST + EL5->EL5_SEQPAG
   If (lRet := EL9->(DbSeek(cSeekEL9)))
      //Caso as parcelas sejam vinculadas a um número de FFC, existirão sequências de pagamentos iguais para serviços diferentes.    
      //Do While EL9->(!EOF()) .And. EL9->(EL9_FILIAL + EL9_TPPROC + EL9->EL9_REGIST + EL9->EL9_SEQPAG) == cSeekEL9     
         If EL9->EL9_STTSIS == '1' .OR. EL9->EL9_STTSIS == '5'// 1=Aguardando registro no SISCOSERV;2=Registrado no SISCOSERV;3=Aguardando cancelamento no SISCOSERV;4=Cancelado no SISCOSERV.
            cStatus := '2'
         ElseIf EL9->EL9_STTSIS == '3'
            cStatus := '4'
         EndIf

         If EL9->(RecLock('EL9',.F.))
            If !Empty(cStatus)
               EL9->EL9_STTSIS := cStatus
            Else
               cStatus := EL9->EL9_STTSIS
            EndIf
            If cStatus == "2"
               EL9->EL9_NROREG := Alltrim(oDados:GetValue("PAG_NROREG")) //RRC - 09/01/2013            
               EL9->EL9_DTREG  := EL8->EL8_DATAR
            ElseIf cStatus == "4"
               EL9->EL9_DTCAN  := EL8->EL8_DATAR 
            EndIf
            If EasyGParam("MV_ESS0027",,9) >= 10 .AND. EL9->(FieldPos("EL9_TPINT")) # 0
               EL9->EL9_TPINT := cValToChar(EasyGParam("MV_ESS0028"))
            EndIf
            EL9->(MsUnLock())
         EndIf
      //   EL9->(DbSkip())                
      //EndDo
   Else
      oDados:Error(If(EL5->EL5_TPPROC=="A","O pagamento","O faturamento")+" do processo " + AllTrim(EL5->EL5_REGIST) + " não foi localizado no lote" + AllTrim(EL5->EL5_IDLOTE)+".")
   EndIf
EndIf
RestOrd(aOrdens,.T.)
Return lRet

/*
Programa   : VerDtEnc(cTipo,cProc)
Objetivo   : Verifica se o Registro será considerado "Encerrado", neste caso, a Data de Encerramento será preenchida e os status do Processo
             dos Serviços será atualizado
Parametros : cTipo - Tipo de Processo - "A" para Aquisição e "V" para Venda 
             cProc - Processo
Retorno    : 
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 22/10/2012 16:40 
Revisao    : 30/01/2013 13:51
*/

Static Function VerDtEnc(cTipo,cProc)
Local aOrd := SaveOrd({"EJY","EJZ","EL1","EL2"})
Local cChaveEJZ, cChaveEL1, cChaveEL2
Local lRet := .T.
Local lDataEnc := EasyGParam("MV_ESS0032",.F.,.T.) //LRS - 29/08/2017 

EJY->(DbSetOrder(1)) //EJY_FILIAL + EJY_TPPROC + EJY_REGIST
EJZ->(DbSetOrder(1)) //EJZ_FILIAL + EJZ_TPPROC + EJZ_REGIST + EJZ_SEQREG
EL1->(DbSetOrder(1)) //EL1_FILIAL + EL1_TPPROC + EL1_REGIST + EL1_SEQREG + EL1_PARC + EL1_SEQPAG
EL2->(DbSetOrder(1)) //EL2_FILIAL + EL2_TPPROC + EL2_REGIST

If EJY->(DbSeek(xFilial("EJY") + AvKey(cTipo,"EJY_TPPROC") + AvKey(cProc,"EJY_REGIST")))
   //Verifica se todos os serviços do Registro possuem status "Registrado no Siscoserv"
   If EJZ->(DbSeek(xFilial("EJZ") + AvKey(EJY->EJY_TPPROC,"EJZ_TPPROC") + AvKey(EJY->EJY_REGIST,"EJZ_REGIST")))
      cChaveEJZ := xFilial("EJZ") + AvKey(EJY->EJY_TPPROC,"EJZ_TPPROC") + AvKey(EJY->EJY_REGIST,"EJZ_REGIST")
      Do While lRet .And. EJZ->(!EOF()) .And. EJZ->(EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST) == cChaveEJZ
         //O campo EJZ_STTPAG foi excluído
         If (lRet := (EJZ->EJZ_STTSIS == "3" /*.And. EJZ->EJZ_STTPAG == "3"*/ .And. !Empty(EJZ->EJZ_DTREG) .And. EJY->EJY_STTSIS == "3" /*.And. EJY->EJY_STTPAG == "3"*/ .And. !Empty(EJY->EJY_DTREG)))
            
            nVlPagReg := 0 //AAF 20/04/2017 - Validar o saldo de pagamentos registrados.

            //Verifica se os pagamentos possuem status "Registrado no Siscoserv"
            If (lRet := EL1->(DbSeek(xFilial("EL1") + AvKey(EJZ->EJZ_TPPROC,"EL1_TPPROC") + AvKey(EJZ->EJZ_REGIST,"EL1_REGIST") + AvKey(EJZ->EJZ_SEQREG,"EL1_SEQREG"))))
               cChaveEL1 := xFilial("EL1") + AvKey(EJZ->EJZ_TPPROC,"EL1_TPPROC") + AvKey(EJZ->EJZ_REGIST,"EL1_REGIST") + AvKey(EJZ->EJZ_SEQREG,"EL1_SEQREG") 
               Do While(lRet .And. EL1->(!Eof()).And. EL1->(EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG) == cChaveEL1)
                  //Verifica se os pagamentos possuem documentos vinculados, caso tenha, verifica se apresentam status "Registrado no Siscoserv"
                  
                  //If /*(lRet := EL1->EL1_STTSIS == "2") .And. */EL2->(DbSeek(xFilial("EL2") + AvKey(EL1->EL1_TPPROC,"EL2_TPPROC") + AvKey(EL1->EL1_REGIST,"EL2_REGIST")))
                  /*   
                     cChaveEL2 := xFilial("EL2") + AvKey(EL1->EL1_TPPROC,"EL2_TPPROC") + AvKey(EL1->EL1_REGIST,"EL2_REGIST")
                     Do While(lRet .And. EL2->(!Eof()).And. EL2->(EL2_FILIAL+EL2_TPPROC+EL2_REGIST) == cChaveEL2)
                        lRet := EL2->EL2_STTSIS == "3"
                        EL2->(DbSkip())
                     EndDo
                  EndIf
                  */
                  
                  //AAF 20/04/2017 - Validar se os pagamentos foram todos registrados no Siscoserv.
                  EL9->(DbSetOrder(1))  // EL9_FILIAL + EL9_TPPROC + EL9_REGIST + EL9_SEQPAG
                  cSeekEL9 := xFilial('EL9') + EL1->(EL1_TPPROC+EL1_REGIST+EL1_SEQPAG)
                  If EL9->(DbSeek(xFilial("EL9")+AvKey(EL1->EL1_TPPROC,"EL9_TPPROC")+AvKey(EL1->EL1_REGIST,"EL9_REGIST")+AvKey(EL1->EL1_SEQPAG,"EL9_SEQPAG")))
                     If EL9->EL9_STTSIS == "2"//Registrado no Siscoserv
                        nVlPagReg += EL1->EL1_VLEXT + EL1->EL1_VLCAMB
                     ElseIf EL9->EL9_STTSIS <> "4"//Se nao está registrado nem cancelado no Siscoserv, está pendente e precisa ser registrado/cancelado.
                        lRet := .F.
                     EndIf
                  EndIf

                  EL1->(DbSkip())
               EndDo
            EndIf

            lRet := lRet .AND. (EJZ->EJZ_VL_MOE - nVlPagReg) <= 0.01 //AAF 20/04/2017 - Validar o saldo de pagamentos registrados.
         EndIf
         EJZ->(DbSkip())
      EndDo
      //RMD - 18/04/17 - Caso tenha pagamento pendente ou cancelado, deve remover a data de encerramento do processo.
      /* 
      If lRet
         If EJY->(RecLock("EJY",.F.))
            EJY->EJY_DTENC := dDataBase
            EJY->(MsUnlock())
            RS400StaReg(EJY->EJY_TPPROC,EJY->EJY_REGIST,EJY->EJY_DTENC)
         EndIf
      EndIf
      */
      IF lDataEnc //LRS - 29/08/2017
         If EJY->(RecLock("EJY",.F.))
            EJY->EJY_DTENC := If(lRet, dDataBase, CTod(""))
            EJY->(MsUnlock())
            RS400StaReg(EJY->EJY_TPPROC,EJY->EJY_REGIST,EJY->EJY_DTENC)
        EndIf
      EndIF
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return lRet

Function SS101PosSeqAnt(cAlias, cChave, bCond)
Local lRet := .F.
Local nOrd

Default bCond := {|| .T.}

Begin Sequence

   aOrd := SaveOrd("EL8")
   
   //Posiciona no ultimo envio da capa para verificar se houveram alterações
   If cAlias == "EL3"
      nOrd := 1//EL3_FILIAL+EL3_TPPROC+EL3_REGIST+EL3_SQEVCP
      
      If Len(cChave) <> Len(EL3->(EL3_FILIAL+EL3_TPPROC+EL3_REGIST))
         Break
      EndIf
   ElseIf cAlias == "EL4"
      nOrd := 1//EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG+EL4_SQEVIT

      If Len(cChave) <> Len(EL4->(EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG))
         Break
      EndIf
   //RRC - 24/10/2012
   ElseIf cAlias == "EL7"
      nOrd := 1 //EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SEQREG+EL7_SEQPAG+EL7_SEQDOC+EL7_SQEVCP   
      
      If Len(cChave) <> Len(EL7->(EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SEQREG+EL7_SEQPAG+EL7_SEQDOC))
         Break
      EndIf      
   EndIf
   
   (cAlias)->(dbSetOrder(nOrd))
   (cAlias)->(AvSeekLast(cChave))
   EL8->(DbSetOrder(2)) //EL8_FILIAL+EL8_IDLOTE
   Do While (cAlias)->(!BoF() .AND. Left(&(IndexKey()),Len(cChave)) == cChave) .AND. !(EL8->(dbSeek(xFilial()+(cAlias)->(&(cAlias+"_IDLOTE")))) .AND. Eval(bCond))
      (cAlias)->(dbSkip(-1))
   EndDo
   
   lRet := (cAlias)->(!BoF() .AND. Left(&(IndexKey()),Len(cChave)) == cChave)   
End Sequence

RestOrd(aOrd)

Return lRet

/*
Programa   : SS101Docs()
Objetivo   : Verificar se o RE ou a DI do Documento foi apagada, caracterizando uma exclusão, neste caso, atualizará o campo EL7->EL7_EXCL
             informando ser uma exclusão
Parametros : 
Retorno    : aClone(aDocs)
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 23/10/2012 15:45 
Revisao    : 
*/

Function SS101Docs()
Local aDocs   := {}
Local aOrd    := SaveOrd({"EL7"})
Local nRecOld := EL7->(Recno())

Begin Sequence
   EL7->(DbSetOrder(1)) //EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SEQREG+EL7_SEQPAG+EL7_SEQDOC+EL7_SQEVCP   
   If EL7->(!EOF()) .And. SS101PosSeqAnt("EL7",EL2->(EL2_FILIAL+EL2_TPPROC+EL2_REGIST+EL2_SEQREG+EL2_SEQPAG+EL2_SEQDOC),{|| EL8->EL8_STATUS == PROCESSADO})
      If Empty(EL2->EL2_RE) .And. Empty(EL2->EL2_DI)
         aAdd(aDocs,EL7->EL7_RE)
         aAdd(aDocs,EL7->EL7_DI)
         aAdd(aDocs,"2")         
      Else 
         aAdd(aDocs,EL2->EL2_RE)
         aAdd(aDocs,EL2->EL2_DI)
         aAdd(aDocs,"1")     
      EndIf
   Else
      aAdd(aDocs,EL2->EL2_RE)
      aAdd(aDocs,EL2->EL2_DI)
      aAdd(aDocs,"1")      
   EndIf
   If nRecOld > 0
      EL7->(DbGoTo(nRecOld))
   EndIf
End Sequence

RestOrd(aOrd,.T.)
Return aClone(aDocs)

/*FSM*/
Function SS101ValAcao(cFase, cTpProc, cTipEnv, cNroLote)
Local lRet := .T.
Local aOrd := SaveOrd({"EL8"})
Local cStatus := ""
Local cErro := ""

Do Case 
	Case cFase=="PROCESSAR"
		cStatus := "R"
		cErro   := "Não há registros a serem processados."

	Case cFase=="ENVIAR"
		cStatus := "N"
		cErro   := "Não há registros a serem enviados."
		
	//RRC - 02/05/2013 - Alteração para permitir reprocessar os lotes que não foram processados corretamente
	Case cFase=="REPROCESSAR"
		cStatus := "P"
		cErro   := "Não há registros a serem reprocessados."
EndCase

EL8->(DBSetOrder(1), DBGoTop() )

Begin Sequence
    
   //RRC - 03/05/2013 - No reprocessamento, ainda não estará posicionado em nenhum lote
   If  !(cFase == "REPROCESSAR") .And. (Empty(cNroLote) .Or. (Empty(cTpProc) .And. Empty(cTipEnv)))
      lRet := .F.
      Break
   EndIf

   If EL8->(BOF() .And. EOF())
      lRet := .F.
      Break
   EndIf

   Do While EL8->(!EOF())
      If cFase == "REPROCESSAR"
         If lRet := EL8->EL8_FILIAL == xFilial("EL8") .And. EL8->EL8_TPPROC==cTpProc .And. EL8->EL8_STATUS==cStatus
            Break
         EndIf
      Else
         If lRet := EL8->EL8_FILIAL == xFilial("EL8") .And. EL8->EL8_TPPROC==cTpProc .And. EL8->EL8_STATUS==cStatus .And. EL8->EL8_TIPENV==cTipEnv
            Break
         EndIf
      EndIf
      EL8->(DBSkip())
   EndDo

End Sequence

If(!lRet, EasyHelp(cErro,"Atenção"),Nil)

RestOrd(aOrd)
Return lRet

/*
Programa   : SS101GrvArq()
Objetivo   : Grava o arquivo de envio ao Siscoserv nas tabelas de histórico, EL3 (Capa RAS/RVS), EL4 (Detalhes RAS/RVS) ou EL5(Pagamentos)
Parametros : 
Retorno    : lRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 14/03/2012 15:22 
Revisao    : 
*/
/*
Function SS101GrvArq(cTipoOpe,cNumLote,cExt)
Local lRet   := .T.
Local aOrd   := SaveOrd({"EL3","EL4","EL5"})
Local cAlias := ""

If !Empty(cTipoOpe) .And. !Empty(cNumLote) .And. !Empty(cExt)
   Do Case 
      Case cTipoOpe == INC_REG .Or. cTipoOpe == RET_REG
         cAlias := "EL3"
         (cAlias)->(DbSetOrder(2)) //EL3_FILIAL + EL3_IDLOTE + EL3_TPPROC + EL3_REGIST    
      Case cTipoOpe == INC_ADI .Or. cTipoOpe ==  RET_ADI
         cAlias := "EL4"
         (cAlias)->(DbSetOrder(2)) //EL4_FILIAL + EL4_IDLOTE + EL4_TPPROC + EL4_REGIST + EL4_SEQREG    
      Case cTipoOpe == INC_PAG .Or. cTipoOpe ==  CAN_PAG
         cAlias := "EL5"
         (cAlias)->(DbSetOrder(2)) //EL5_FILIAL + EL5_IDLOTE + EL5_TPPROC + EL5_REGIST + EL5_SEQPAG    
   EndCase

   If (cAlias)->(DbSeek(xFilial()+cNumLote))
      Do While (cAlias)->(!Eof()) .And. (cAlias)->(&(cAlias+"_IDLOTE")) == cNumLote
         If (cAlias)->(RecLock(cAlias,.F.))
            (cAlias)->(&(cAlias+"_ARQENV")) := cNumLote+cExt
         EndIf                  
         (cAlias)->(DbSkip())   
      EndDo  
   EndIf     
EndIf
         
RestOrd(aOrd,.T.)
Return lRet*/

Static Function LockActions(cTpServ)
Local   lRet := .T.
Default cTpServ := ""
	//RRC - 06/05/2013		
	If nHdlLock == 0
	   If cTpServ == AQUISICAO .And. !File(ARQ_REPROC_A) 
	      nHdlLock	:= EasyCreateFile(ARQ_REPROC_A) //Alteração para a variável guardar o valor de nHandler
	   ElseIf cTpServ == VENDA .And. !File(ARQ_REPROC_V)
	      nHdlLock	:= EasyCreateFile(ARQ_REPROC_V) //Alteração para a variável guardar o valor de nHandler
	   ElseIf cTpServ == AQUISICAO .And. File(ARQ_REPROC_A)
	      nHdlLock := EasyOpenFile(ARQ_REPROC_A, 18)
	   ElseIf cTpServ == VENDA .And. File(ARQ_REPROC_V) 
	      nHdlLock := EasyOpenFile(ARQ_REPROC_V, 18)
	   EndIf
	ElseIf nHdlLock > 0
       If cTpServ == AQUISICAO .And. File(ARQ_REPROC_A)
          nHdlLock := EasyOpenFile(ARQ_REPROC_A, 18)
	   ElseIf cTpServ == VENDA .And. File(ARQ_REPROC_V) 
	      nHdlLock := EasyOpenFile(ARQ_REPROC_V, 18)
	   EndIf
    EndIf
    
    If nHdlLock == -1
	   lRet := .F.
	EndIf
Return lRet

Static Function UnLockActions(cTpServ,lDel)
Default lDel := .T.
	If nHdlLock > 0
		FClose(nHdlLock)
		//RRC - 06/05/2013 - Só apaga o arquivo caso o reprocessamento tenha sido com certeza completado
		If cTpServ == AQUISICAO  .And. File(ARQ_REPROC_A) .And. lDel
		   FErase(ARQ_REPROC_A)
		   nHdlLock := 0 //Variável recebe zero para que o arquivo de controle de reprocessamento possa ser criado novamente
		ElseIf cTpServ == VENDA .And. File(ARQ_REPROC_V) .And. lDel		   
		   FErase(ARQ_REPROC_V)
		   nHdlLock := 0 //Variável recebe zero para que o arquivo de controle de reprocessamento possa ser criado novamente
		EndIf
	EndIf

Return Nil

Static Function IsFileLock(cTpServ)
Local lRet := .F.
    If cTpServ == AQUISICAO
       lRet := File(ARQ_REPROC_A)
    ElseIf cTpServ == VENDA 
       lRet := File(ARQ_REPROC_V)
    EndIf
Return lRet

/*
Programa   : SS101QryProc()
Objetivo   : Monta query medir tempo do processamento
Retorno    : lRet
Autor      : Rafael Ramos Capuano
Data       : 09/05/2013 - 15:20

*/
*-------------------------------*
Static Function SS101QryProc(aTotLotes,cTipo)
*-------------------------------*
Local cCond  := ""
Local cCond2 := "" 
Local cQuery := ""
Local nI     := 0

Begin Sequence
  
  If cTipo == "1" //Registros
     cCond  := "EL3.EL3_FILIAL = '" + xFilial("EL3") + "'" + " AND (EL3.EL3_IDLOTE = '" + aTotLotes[1] + "'"
     For nI := 2 To Len(aTotLotes)
        cCond2 += " OR EL3.EL3_IDLOTE = '" + aTotLotes[nI] + "'" 
     Next
     cQuery := "SELECT EL3.* FROM " + RetSqlName("EL3") + " EL3 WHERE " + cCond + cCond2 + ")" + " AND " + IIF(TcSrvType()<>"AS/400","EL3.D_E_L_E_T_<>'*'","EL3.@DELETED@<>'*'")
  ElseIf cTipo == "2" //Aditivos
     cCond  := "EL4.EL4_FILIAL = '" + xFilial("EL4") + "'" + " AND (EL4.EL4_IDLOTE = '" + aTotLotes[1] + "'"
     For nI := 2 To Len(aTotLotes)
        cCond2 += " OR EL4.EL4_IDLOTE = '" + aTotLotes[nI] + "'" 
     Next
     cQuery := "SELECT EL4.* FROM " + RetSqlName("EL4") + " EL4 WHERE " + cCond + cCond2 + ")" + " AND " + IIF(TcSrvType()<>"AS/400","EL4.D_E_L_E_T_<>'*'","EL4.@DELETED@<>'*'")
  ElseIf cTipo == "3" //Pagamentos
     cCond  := "EL5.EL5_FILIAL = '" + xFilial("EL5") + "'" + " AND (EL5.EL5_IDLOTE = '" + aTotLotes[1] + "'"
     For nI := 2 To Len(aTotLotes)
        cCond2 += " OR EL5.EL5_IDLOTE = '" + aTotLotes[nI] + "'" 
     Next
     cQuery := "SELECT EL5.* FROM " + RetSqlName("EL5") + " EL5 WHERE " + cCond + cCond2 + ")" + " AND " + IIF(TcSrvType()<>"AS/400","EL5.D_E_L_E_T_<>'*'","EL5.@DELETED@<>'*'") 
  EndIf
End Sequence

Return cQuery

/*
Programa   : ValidAdt()
Objetivo   : Validar caso de aditivos onde há depêndencia entre o item retirado e os demais que estão marcados
             Para envio do aditivo, não deve permiter enviar um aditivo cujo a Sequência do Registro (EJZ_SEQREG) do serviço seja superior a de outro serviço
             ainda não registrado e que não compõe o lote, uma vez que a ordem do envio, é importante para identificação do serviço no SISCOSERV, por exemplo,
             no Pagamento.
Retorno    : Nil
Autor      : Rafael Ramos Capuano
Data       : 10/09/2013 - 08:48
*/   

Static Function ValidAdt(nPos,oBrowse)
Local nSeqPos   := 0
//Local nRecno    := TMP->(Recno())
EJZ->(DbSetOrder(2)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQAD
cChave := xFilial("EJZ")+TMP->EJZ_TPPROC+TMP->EJZ_REGIST+TMP->EJZ_SEQAD
If EJZ->(DbSeek(cChave))
   Do While !EJZ->(Eof()) .And. EJZ->(EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQAD) == cChave
      //aItens guarda todos os dados selecionados para o lote. Retira do array os itens validados
      If (nSeqPos := aScan(aItens,EJZ->(Recno()))) > 0 .And. Val(TMP->EJZ_SEQREG) < Val(EJZ->EJZ_SEQREG)
         aDel(aItens, nSeqPos)
         aSize(aItens, Len(aItens)-1)
         //TMP->(DbGoTo(nSeqPos))
         //Eval(oBrowse:aColumns[1]:GetDoubleClick())
         //TMP->(DbGoTo(nRecno))
         //Exit
      EndIf
      EJZ->(DbSkip())
   EndDo
EndIf
//Exclui o próprio item
aDel(aItens, nPos)
aSize(aItens, Len(aItens)-1)
oBrowse:Refresh(.F.)

Return

/*
Programa   : CancelSeqAd()
Objetivo   : Limpa o campo EJZ_SEQAD caso um lote de RAS/RVS ou Aditivo seja cancelado
Retorno    : Nil
Autor      : Rafael Ramos Capuano
Data       : 13/09/2013 - 10:20
*/
Static Function CancelSeqAd()
Local aOrd   := SaveOrd({"EL4","EJZ"})
//Considera que a tabela EL8 (Lote SISCOSERV) já está posicionada
EL4->(DbSetOrder(2)) //EL4_FILIAL+EL4_IDLOTE+EL4_TPPROC+EL4_REGIST+EL4_SEQREG
EJZ->(DbSetOrder(1)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST+EJZ_SEQREG
If EL8->EL8_STATUS == CANCELADO .And. EL4->(DbSeek(xFilial("EL4")+EL8->EL8_IDLOTE))
   Do While !EL4->(Eof()) .And. EL4->(EL4_FILIAL+EL4_IDLOTE) == EL8->(EL8_FILIAL+EL8_IDLOTE)
      If EJZ->(DbSeek(xFilial("EJZ")+EL4->EL4_TPPROC+EL4->EL4_REGIST+EL4->EL4_SEQREG)) .And. EJZ->(RecLock("EJZ",.F.))
         EJZ->EJZ_SEQAD := ""
         EJZ->(MsUnLock())
      EndIf
      EL4->(DbSkip())
   EndDo
EndIf
RestOrd(aOrd,.T.)
Return

/*
Programa   : PaisSisc()
Objetivo   : Corrige o pais salvo no EL4/EL3 para o codigo do pais ir certo para o arquivo de integração
Retorno    : cPais:= Pais corrigido do siscoserv
Autor      : Lucas Raminelli
Data       : 16/10/2014
*/
Static function PaisSisc(cCodGI)
Local cPais := cCodGI

    SYA->(DBSetOrder(1))
   If SYA->(DBSeek(xFilial()+cPais)) .AND. !Empty(SYA->YA_SISEXP)
	   //IF Len(AllTrim(SYA->YA_SISEXP)) > 3 MCF-08/01/2015
	      If Left(Alltrim(SYA->YA_SISEXP),2) =='00' //Caso o cliente ter colocado 0 na frente do codigo
		     cPais := Substr(Alltrim(SYA->YA_SISEXP),2,4)
		  Else
		     cPais := Substr(Alltrim(SYA->YA_SISEXP),1,3)
	      EndIf
	   //EndIf
   EndIF
   
Return cPais

/*
Programa   : CI101Seek()
Objetivo   : Setar o foco da tela do FWBROWSE
Retorno    : Lógico
Autor      : Laercio G Souza Jr - LGS
Data       : 15/01/2016
*/
Static Function CI101Seek(cSeek, nOrder, oBrowse)
Local lRet    := .F.
Local lAux    := .F.
Local nRecno  := TMP->(Recno())

lAux := TMP->(DbSeek(cSeek))
 
If lAux
   nRecno := TMP->(Recno())
   lRet   := .T.
Else
   EasyHelp("Registro não encontrado")   
EndIf

oBrowse:GoTo(nRecno,.T.)

Return lRet

Function SS101SelServ(oPanel)

@ 15,5 SAY "Clique no botão abaixo para selecionar os processos para integração." PIXEL OF oPanel
@ 45,5 SAY "Total de registros selecionados: " + AllTrim(cValToChar(nRegs)) PIXEL OF oPanel
@ 60,5 BUTTON "Processos" ACTION {||SS101SelLote()} SIZE 039,012 PIXEL OF oPanel

Return .T.

Function SS101FinLote(nRadio1,cNroLote,oCentral,oError,lReproc,cTpServ)
Local cIniInteg := ESSCI100:cDirRecebidos+cNroLote+EXT_INI
Local cRetInteg := ESSCI100:cDirRecebidos+cNroLote+EXT_RET



Return .T.
