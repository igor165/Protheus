#Include "EECDU400.Ch"
#Include "FILEIO.Ch"
#include "EEC.CH"
#Include "TOPCONN.ch"

#define ENTER CHR(13)+CHR(10)

/*
Programa   : EECDU400()
Objetivo   : Efetuar a geração e transmissão dos arquivos xml de integração DUE (Declaracao Unica de Exportacao)
Autor      :
Data       : 17/05/2017
*/
Function EECDU400()
Local aBuffer      := {}
Local cArqXMLDUE   := ""
Local cMsgStop     := ""
Local cBuffer      := ""

Private cMsgCpoDUE := ""
Private aAtributos := {}

   Begin Sequence

      if EEC->EEC_STATUS == "*"
         cMsgStop := "Não é possível gerar a DUE para um processo de embarque cancelado!"
         help( ,, "HELP" , STR0002 , cMsgStop , 1, 0)
         break
      endif
      // PONTO DE ENTRADA PADRÃO ROTINA
      If EasyEntryPoint("EECDU400")
         ExecBlock("EECDU400",.f.,.f.,"INICIO")
      EndIf

      //Atualizar o status para verificar inconsistências impeditivas de geração do arquivo
      DU400GrvStatus()

      If AvFlags("DU-E2")
         //Não permitir a transmissão caso o status seja diferente de 3=Aguardando Transmissão e 4=Aguardando Retificação
         If !Empty(cMsgCpoDUE)
            cMsgStop   := cMsgCpoDUE //WHRS TE-5041 542634 - Permitir retificação da DUE
            cMsgCpoDUE := ""
            AVGetSvLog(STR0002,cMsgStop,{7,15})    //Existem itens sem nota fiscal de Saída neste processo, portanto a Declaração Única de Exportação não poderá ser gerada!
            Break
         EndIf
      Else
         If !Empty(cMsgCpoDUE) .Or. (EEC->EEC_STTDUE <> "3" .And. EEC->EEC_STTDUE <> "4")
            If (EEC->EEC_STTDUE <> "3" .And. EEC->EEC_STTDUE <> "4")
               cMsgStop := STR0037 + ENTER + cMsgCpoDUE //"O atual status do processo não permite a transmissão da DU-E."
            Else
               cMsgStop   := cMsgCpoDUE
            EndIf
            cMsgCpoDUE := ""
            AVGetSvLog(STR0002,cMsgStop,{7,15})    //Existem itens sem nota fiscal de Saída neste processo, portanto a Declaração Única de Exportação não poderá ser gerada!
            Break
         EndIf
      EndIf

      //"Esta funcionalidade irá criar o XML utilizado na integração da declaração unica de exportação. Deseja prosseguir com a criação do XML?"###"Declaração Única de Exportação"
      If VldGerDUE(EEC->EEC_PREEMB)
         if EEC->(fieldpos("EEC_DUEMAN")) > 0 .and. ! empty(EEC->EEC_DUEMAN) ;
            .or. MsgYesNo(STR0003,STR0001)
               if  AvFlags("DU-E3")
                  if ValidLpco()
                     Help( ,, "HELP" , STR0002 , STR0046 , 1, 0) //"A DUE não pode ser gerada, verifique o tamanho do campo EK2_LPCO e compatibilize o tamanho do campo de acordo com o campo EE9_LPCO."
                     Break
                  endif
                  if EEC->(fieldpos("EEC_DUEMAN")) > 0 .and. ! empty(EEC->EEC_DUEMAN)
                     cSttDUE := 5
                  else
                     cSttDUE := 1
                  endif
                  // chama gravação das EK's
                  EECDU100GRV( cSttDUE, EEC->EEC_FILIAL, EEC->EEC_PREEMB, "" , __cUserID , dDataBase, cBuffer )
               Else
                  //Carrega Buffer com dados da declaração
                  cBuffer := EasyExecAHU("DUE_CNF")
                  cBuffer := EncodeUTF8(cBuffer)
                  cBuffer := StrTran(cBuffer,"&","e")
                  aadd( aBuffer, { cBuffer , EEC->EEC_FILIAL+EEC->EEC_PREEMB , EEC->( recno() ) , 0 } )
               endif

               //se não for due manual transmite
               if EEC->(fieldpos("EEC_DUEMAN")) == 0 .or. EEC->(fieldpos("EEC_DUEMAN")) > 0 .and. empty(EEC->EEC_DUEMAN)
                  //"Deseja transmitir esta Declaração Única de Exportação?"###"Declaração Única de Exportação"
                  if MsgYesNo(STR0004,STR0001)
                     If AvFlags("DU-E3")
                        cSeqHist := DUESeqHist( EEC->EEC_PREEMB )
                        if EK0->( dbsetorder(1) , DbSeek( EEC->EEC_FILIAL + EEC->EEC_PREEMB + cSeqHist ) )
                           cBuffer := EasyExecAHU("DUE3")
                           cBuffer := EncodeUTF8(cBuffer)
                           cBuffer := StrTran(cBuffer,"&","e")
                           aadd( aBuffer, { cBuffer , EEC->EEC_FILIAL+EEC->EEC_PREEMB , EEC->( recno() ) , EK0->( recno() ) } )

                           GerXMLDue(aBuffer)
                     Else
                           Help( ,, 'HELP',STR0002, STR0047 , 1, 0) //"Não foi gerado uma nova declaração, então acesse a rotina Transmissão DUE para definir qual delas será transmitida!"
                        endif
                     Else
                        GerXMLDue(aBuffer)
                     EndIf
                  endif
               EndIf
         EndIf
      EndIf

      // PONTO DE ENTRADA PADRÃO ROTINA
      If EasyEntryPoint("EECDU400")
            ExecBlock("EECDU400",.f.,.f.,"FIM")
      EndIf

      //Atualizar o status para verificar inconsistências impeditivas de geração do arquivo
      DU400GrvStatus()

   End Sequence

Return
/*/{Protheus.doc} ValidLpco()
    Valida se o campo EK2_LPCO possui tamanho maior ou igual ao EE9_LPCO, se não, não permite gerar
    @author Miguel Gontijo
    @since 03/04/2020
    @version 1.0
    @param none, param_type, param_descr
    @return lRet, Boolean, se não possui retornar falso
    /*/
Static Function ValidLpco()
Local lRet := .F.

    if AvSx3("EK2_LPCO",AV_TAMANHO) < AvSx3("EE9_LPCO",AV_TAMANHO)
        lRet := .T.
    endif

Return lRet
/**
Função para gerar o arquivo xml e transmitir o mesmo
**/
Function GerXMLDue(aBuffer)
Local hFile
Local cDirComex   := "\comex"
Local cDirXMLs    := "\comex\due\"
Local cId         := "01"
Local cProcesso   := Alltrim(AvAltCarac(EEC->EEC_PREEMB))
Local cArquivo    := ""
Local aArquivo    := {}
Local aArquivos   := {}
Local aDirect     := {}
Local nSeq
Local nX, nW

Private oError    := AvObject():New()

Begin Sequence

   //Verifica se exsite a pasta comex dentro da Protheus_data
   If !ExistDir(cDirComex)
      If MakeDir(cDirComex) <> 0
         MsgInfo(STR0005,STR0002)//"O sistema não pode criar os diretórios necessários para a geração do arquivo de integração"###"Atenção"
         Break
      EndIf
   EndIf

   If !ExistDir(cDirXMLs)
      If MakeDir(cDirXMLs) <> 0
         MsgInfo(STR0005,STR0002)//"O sistema não pode criar os diretórios necessários para a geração do arquivo de integração"###"Atenção"
         Break
      EndIf
   EndIf

   //Obter o próximo ID verificando arquivos existentes no diretório
   for nX := 1 to len(aBuffer)
      cProcesso   := Alltrim(AvAltCarac(Alltrim( aBuffer[nX][2] )))
      aDirect := Directory(Alltrim(cDirXMLs)+ cProcesso + "*.xml")
      nSeq := 1
      For nW := 1 to len(aDirect)
        If len( left( aDirect[nW][1] , len(aDirect[nW][1]) - 4 ) ) == len(cProcesso) + 2
            if left( aDirect[nW][1] , len(aDirect[nW][1]) - 6 ) == cProcesso
                nSeq++
            EndIf
        ElseIf len( left( aDirect[nW][1] , len(aDirect[nW][1]) - 4 ) ) == len(cProcesso) + 3
            if left( aDirect[nW][1] , len(aDirect[nW][1]) - 7 ) == cProcesso
                nSeq++
            EndIf
        EndIf
      Next
      cId := Alltrim(StrZero(nSeq,3))
      cArquivo := cDirXMLs + cProcesso + cId + ".xml"
      aadd( aArquivo , {cArquivo , aBuffer[nX][1] , aBuffer[nX][3] , aBuffer[nX][4] } )
   Next

   For nX := 1 to len(aArquivo)

      //Cria o arquivo
      hFile := EasyCreateFile(aArquivo[nX][1] , FC_READONLY)
      If hFile == -1
         MsgInfo(STR0006 + Str(FERROR()),STR0002) //"O arquivo não pode ser criado! Erro: " ### "Atenção"
         //cProcesso := ""
         //cArquivo  := ""
         //Break
      Else 
         //Escreve no arquivo
         If FWrite(hFile, aArquivo[nX][2], Len(aArquivo[nX][2])) < Len(aArquivo[nX][2])
            MsgInfo(STR0007,STR0002) //O arquivo não pode ser gravado. ### "Atenção"
            FErase(aArquivo[nX][1])
            //cProcesso := ""
            //Break
         Else
            //Fecha o arquivo
            FClose(hFile)
            aadd( aArquivos , { aArquivo[nX][1] , aArquivo[nX][3] , aArquivo[nX][4] } )
         EndIf
      EndIf

   Next

   if len(aArquivo) == 1
      If MsgYesNo(STR0008 + CHR(13) + CHR(10) + ;//"Arquivo gerado com sucesso em: "
                  aArquivo[1][1] + CHR(13) + CHR(10) + ;
                  STR0009, STR0001)//"Deseja visualizar o arquivo agora?"###"Declaração Única de Exportação"
        //RMD - 29/03/18 - Estava abrindo o arquivo diretamente no servidor. Passa a copiar para a pasta temp para abrir localmente.
        //ShellExecute("open", GetSrvProfString("ROOTPATH","") + cArquivo,"", "", 1)
        If CpyS2T(aArquivo[1][1], GetTempPath(.T.),,.F.)
            ShellExecute("open", GetTempPath(.T.)+cProcesso + cId + ".xml","", "", 1)
        EndIf
      EndIf
   EndIf

	// função para zipar e transmitir os arquivos
	EnvXMLDue(aArquivos)

End Sequence

if oError:HasErrors()
    oError:ShowErrors()
EndIf

Return //cArquivo
/*
Função     : EnvXMLDue()
Objetivo   : Fazer a transmissao do XML da DUE via Integrador JAVA
Parâmetros : cArqXMLDUE - Caminho do arquivo xml gerado
Retorno    :
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 18/05/2017
*/
Static Function EnvXMLDue(aArqXMLDUE)
Local lRet      := .T.
Local cDirTemp  := GetTempPath(.T.)
Local cDirClient:= GetClientDir()
Local cDirXMLDue:= GetSrvProfString("ROOTPATH","")
Local cXML      := "" // Right(cArqXMLDUE , Len(cArqXMLDUE ) - Rat("\", cArqXMLDUE ))
Local cProcesso := "" // Left(cXML , Rat(".", cXML ) -1 )
Local cArqDue   := dtos(ddatabase) + strtran( time() , ":" , "" ) // Left(cXML , Rat(".", cXML ) -1 )
Local cDirSvr   := "\comex\due\DUE_" + cArqDue + "\"
Local cCompName := GetComputerName()
Local cDirGerado:= cCompName+"\Gerado\"
Local cDirEnviad:= cCompName+"\Enviado\"
Local cDirRetorn:= cCompName+"\Retorno\"
Local cSrvGerado:= "\comex\due\Enviado\"
Local cSrvRetorn:= "\comex\due\Retorno\"
Local cDirJar   := "Jar\"
Local cDirUnzip := "Unzip\"
Local cRetDue   := "RET_DUE_" + cArqDue
Local cEnvDue   := ""
Local cBat      := ""
Local cConfWeb  := ""
Local cMsg      := ""
Local nC        := 1
Local cNameInteg := "" //Integrador que sera executado
Local cIntegProd := "tr-sw-web-solution-due.jar" //Nome que devera ter o integrador de producao
Local cIntegTest := "tr-sw-web-solution-due-teste.jar" //nome que deverá ter o integrador de teste que faz a simulação da transmissao (Sem validade com o portal da DUE)
Local lTest     := .F.
Local cMVEEC0054:= EasyGParam("MV_EEC0054",,1)

Private oUserParams:= EASYUSERCFG():New("EECDU400")

Begin Sequence

//THTS - 02/03/2018 - Verifica se existe o integrador de teste. Quando ele existir, a transmissao ira sempre utilziar o teste, caso não exista será executado o integrador padrão.
If File(cDirClient + cIntegTest)
    cNameInteg := cIntegTest
    lTest := .T.
Elseif File(cDirClient + cIntegProd)
    cNameInteg := cIntegProd
Else
    MsgStop( "Não existe nenhum integrador para transmissão da DUE na pasta do SmartClient!" + ENTER + ;
    "Certifique se de copiar o integrador para a pasta " + cDirClient + ENTER + ;
    "Em seguida tente novamente!" ;
     , STR0002 )
     Break
EndIf


If ( cMVEEC0054 == 2 .and. lTest) .or. (cMVEEC0054 == 1 .And. !MsgNoYes(STR0032 + ENTER +; //"O sistema está configurado para integração com a Base de Testes do Portal Único."
                                                                        STR0033 + ENTER +; //"Qualquer integração para a Base de Testes não terá qualquer efeito legal e não deve ser utilizada em um ambiente de produção."
                                                                        STR0034 + ENTER +; //"Para integrar com a Base Oficial (Produção) do Portal Único, altere o parâmetro 'MV_EEC0054' para 2."
                                                                        STR0035,STR0002)) //"Deseja prosseguir?"###Atenção
    if cMVEEC0054 == 2 .and. lTest
        MsgStop( "Não é possível integrar com a produção usando integrador de teste, favor verificar e tentar novamente!" , STR0002 )
    endif
    lRet := .F.
EndIf

If  lRet .And. EditConfigs()
   cDirTemp := If(!Empty(oUserParams:LoadParam("DIRTEMP","","EECDU400")),oUserParams:LoadParam("DIRTEMP"), cDirTemp)
   cDirTemp += if( "\DUE\" == alltrim(upper( Right(cDirTemp, 5 ) )) , "", "DUE\")

   //Cria a estrutura de pastas necessarias para execucao
   lRet := CriaPastas(cDirTemp,cDirJar,cDirGerado,cDirEnviad,cDirRetorn,cDirSvr,cCompName,cSrvGerado,cSrvRetorn,cDirUnzip)
   
   cConfWeb := ConfiguracoesWeb(cDirTemp + cDirJar) //MCF - 22/11/2017
   If Empty(cConfWeb)
      MsgInfo("Não foi possível criar o arquivo WebNavigation-PortalUnico-Enviroment.ini" ,STR0002)
      lRet := .F.
   EndIf

   If lRet .And. File(cDirClient + "Smartclient.exe")

      //Gera arquivo zip para integracao no java
      cEnvDue  := AE100GrInt(cDirTemp,aArqXMLDUE,cDirSvr,cArqDue)

      If !Empty(cEnvDue)
            // primeiro verifica se tem itens antigos na pasta de unzip e apaga tudo para realizar nova operação
            cDirUnZip   := cDirTemp + cDirRetorn + cDirUnzip
            aFilesRet := Directory(cDirUnZip+"*.*")  

            for nC := 1 to len(aFilesRet)
                fErase(cDirUnzip+aFilesRet[nC][1])
            Next

         Processa({|| lRet := ExecTransm(cDirClient, cNameInteg, cDirTemp, cDirJar, cDirGerado, cDirXMLDue, cDirSvr,cEnvDue + ".zip")},"Efetuando transmissão do arquivo solicitado...") //"Efetuando transmissão do arquivo solicitado..."
         If lRet
            lRet := file(cDirTemp + cDirRetorn + cRetDue + ".zip")
            cMsg := if( lRet, "", STR0048 ) // "Não foi possível encontrar o arquivo de retorno do pacote DUE. Tente novamente."
            if lRet
               //Copia arquivo de retorno para pasta Retorno do Servidor
               AvCpyFile(cDirTemp + cDirRetorn + cRetDue + ".zip", cSrvRetorn + cRetDue + ".zip",,.F.,,.F.)
               
               //Copia arquivo de envio para pasta Gerado do Servidor?
               AvCpyFile(cDirSvr + cEnvDue + ".zip", cSrvGerado + cEnvDue + ".zip",,.T.,,.F.)

                // unzip da pasta de lote 

                /*
                RMD - 05/06/18 - Por padrão, a função EasyUnzip copia os arquivos para o temporário do usuário e executa o VbScript de descompactação neste diretório.
                                 Quando utilizado Citrix, em algumas configurações o temporário do usuário fica em um servidor de arquivos com acesso restrito para execução de programas.
                                 Desta forma, a função foi alterada para poder receber um diretório específico para esta execução, e neste caso estamos indicando o diretório configurado 
                                 pelo usuário para execução da integração, desta forma o administrador já terá de liberar a execução de programas neste diretório por conta do integrador,
                                 evitando problemas também na execução do descompactador.
                */
                If !lIsDir(cDirTemp + "temp_unzip\")
                   MakeDir(cDirTemp + "temp_unzip\")
                EndIf

                if EasyUnZip( cRetDue + ".zip", cDirTemp + cDirRetorn , cDirUnzip,.T.,,cDirTemp + "temp_unzip\")
                    aFilesRet := Directory(cDirUnZip+"*.*")

                    for nC := 1 to len(aFilesRet)
                        cDuePrc     := left( aFilesRet[nC][1] , Rat( "." , aFilesRet[nC][1] ) - 1 )
                        if left(cDuePrc,4) == "DUE_"
                            cArqsDue := substr(cDuePrc,5,len(cDuePrc))
                        else
                            cArqsDue := cDuePrc
                        endif
                        cDirPrc     :=  cDuePrc+ "\"

                        if EasyUnZip( aFilesRet[nC][1] , cDirUnzip , cDirUnzip + cDirPrc ,.T.,,cDirTemp + "temp_unzip\")
                
                            //Processa arquivo de retorno 
                            cMsg += ProcRetDue( cDirUnzip + cDirPrc , cArqsDue )
                            cMsg += replicate("-",50) + ENTER
                            DirRemove( cDirUnzip + cDirPrc )
                            fErase(cDirUnzip+aFilesRet[nC][1])

                        EndIf

                    Next

                endif

            endif
         EndIf
      Else
        MsgStop(STR0010,STR0002)//"Não foi possível a geração do arquivo zip para integração."###"Atenção"
      EndIf

   Else
      If ExistDir(cDirSvr)
         DirRemove(cDirSvr)
      EndIf
      If lRet
         MsgInfo(STR0011,STR0002)//"Atalho configurado incorretamente! Verifique no atalho do smartclient a propriedade 'Iniciar em: '(Digite o diretório do smartclient)"###"Atenção"
      EndIf
   EndIf

    If ExistDir(cDirSvr)
        DirRemove(cDirSvr)
    EndIf
    If ExistDir(cDirUnzip)
        DirRemove(cDirUnzip)
    EndIf

EndIf

End Sequence

if ! empty(cMsg)
    EECVIEW(cMsg,STR0001,STR0031) //"Declaração Única de Exportação"###"Retorno da Integração"
EndIf

Return

/*
Função     : ExecTransm()
Objetivo   : Executar o integrador Java
Parâmetros : cDirClient - Diretorio onde se encontra o smartclient do protheus
             cDirTemp   - Diretorio temp da maquina que esta executando a aplicacao
             cDirJar    - Diretorio onde sera copiado o arquivo jar
             cDirGerado - Diretorio onde sera copiado o arquivo zip
             cDirXMLDue - Diretorio onde esta o protheus_data
             cDirIni    - Diretorio onde será gerado o arquivo .ini
             cEnvDue    - Nome do arquivo zip
Retorno    :
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 22/05/2017
*/
Static Function ExecTransm(cDirClient, cNameInteg, cDirTemp, cDirJar, cDirGerado, cDirXMLDue, cDirIni,cEnvDue)
Local lRet := .T.
Local cJavaParam := If(!Empty(oUserParams:LoadParam("DIRJAVA","","EECDU400")),oUserParams:LoadParam("DIRJAVA"), "Java.exe")
Local cArqBat
Local cBat
Local cDir

ProcRegua(0)

If File(cDirClient + cNameInteg)
    AvCpyFile(cDirClient + cNameInteg, cDirTemp + cDirJar + cNameInteg,,.F.,,.F.)
Else
    lRet := .F.
    MsgInfo(STR0012,STR0002)//"Integrador Java não localizado no diretório SmartClient."###"Atenção"
EndIf
If lRet .And. File(cDirIni + cEnvDue)
    AvCpyFile(cDirIni + cEnvDue, cDirTemp + cDirGerado + cEnvDue,,.F.,,.F.)
Else
    lRet := .F.
    MsgInfo(STR0013,STR0002)//"O arquivo a ser enviado na integração não foi localizado."###"Atenção"
EndIf

nPosTeste := At("\", cDirTemp) //MCF - 24/11/2017 - Execução do arquivo java em diretório remoto
cDir := Left(cDirTemp, nPosTeste)

If lRet
    //Cria o arquivo .bat para executar o integrador da DUE
    If File(cDirTemp + "ExecInteg.bat")
        Ferase(cDirTemp + "ExecInteg.bat")
    EndIf
    If File(cDirTemp + cDirJar + "IntegracaoDUE.txt")
        FErase(cDirTemp + cDirJar + "IntegracaoDUE.txt")
    EndIF

    cBat := 'Echo Executando Integrador ' + ENTER
    cBat += 'cd "' + cDirTemp + cDirJar + '" ' + ENTER
    cBat += '"' + cJavaParam + '"' + ' -jar ' + cNameInteg + ' "' + cDirTemp + cDirGerado + cEnvDue + '" '
    cBat += ' >> log.txt' + ENTER
    cBat += 'Echo Fim da integracao' + ENTER
    cBat += 'Echo > IntegracaoDUE.txt'

    cArqBat := EasyCreateFile(cDirTemp + "ExecInteg.bat")
    fWrite(cArqBat, cBat)
    fClose(cArqBat)
    shellExecute("Open", "cmd.exe", ' /k "'  + cDirTemp + 'ExecInteg.bat"', cDir, 0 )
    Processa({|lEnd| lRet := ExecIntJav((cDirTemp + cDirJar + "IntegracaoDUE.txt"),@lEnd) }, STR0014)//"Executando integrador..."
    Ferase(cDirTemp + "ExecInteg.bat")

EndIf

Return lRet

/*
Função     : AE100GrInt()
Objetivo   : Criar arquivo .Zip com a estrutura necessaria para executar o integrador java
Parâmetros : cDirTemp   - Diretorio temp da maquina que esta executando a aplicacao
             cArqXMLDUE - Arquivo XML gerado para Transmissao
Retorno    : lRet - determina se a estrutura de arquivos foi gerada corretamente
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 19/05/2017
*/
Static Function AE100GrInt(cDirTemp,aArqXMLDUE,cDirIni,cArqDue)
//Local oError    := AvObject():New()
Local cXML      := "" //Right(cArqXMLDUE , Len(cArqXMLDUE ) - Rat("\", cArqXMLDUE ))
Local cProcesso := "" //Left(cXML , Rat(".", cXML ) -1 )
Local cEnvDue   := "ENV_DUE_"+cArqDue
Local cArqIni   := ""
Local aArqZip   := {}
local nC

For nC := 1 to len(aArqXMLDUE)
    
    EEC->( DbGoto( aArqXMLDUE[nC][2] ) )
    if AvFlags("DU-E3")
        EK0->( DbGoto( aArqXMLDUE[nC][3] ) )
    EndIf

   cXML      := Right(aArqXMLDUE[nC][1] , Len(aArqXMLDUE[nC][1] ) - Rat("\", aArqXMLDUE[nC][1] ))
   cProcesso := Left( cXML , Rat(".", cXML  ) -1 )

    If !ExistDir(cDirIni+cProcesso)
    
        If MakeDir(cDirIni+cProcesso) <> 0
            //MsgInfo("O sistema não pode criar os diretórios necessários para a transmissão do arquivo." + ENTER + cDirIni,"Atenção")//###"Atenção"
            oError:Error("O sistema não pode criar os diretórios necessários para a transmissão do arquivo." + ENTER + cDirIni,.F.)
        EndIf
    
    EndIf

    cDirAux := cDirIni+cProcesso+"\"
    cArqIni := GeraArqIni(cDirAux,aArqXMLDUE[nC][1])
    
    if  !Empty(cArqIni) .And. AvCpyFile(aArqXMLDUE[nC][1],cDirAux+ cXML,,.F.,,.F.)
        
        //gera arquivo Zipinho da pasta do processo
        If EasyZIP("DUE_" + cProcesso,cDirAux,cDirTemp,oError,.T. )
            AvCpyFile( cDirAux+"DUE_"+cProcesso+".zip" , cDirIni+"DUE_"+cProcesso+".zip" ,,.F.,,.F. )
            fErase(cDirAux+"DUE_"+cProcesso+".zip")
            fErase(cDirAux+cArqIni)
            fErase(cDirAux+cXML)
            DirRemove(cDirAux)
            aadd( aArqZip , {cDirIni+"DUE_" + cProcesso + ".zip"} )
        Else
            //MsgInfo("Não foi possível gerar o arquivo zip.","Atenção")
            oError:Error("Não foi possível gerar o arquivo zip.",.F.) 
        EndIf

    Else
        //MsgInfo("Não foi possível gerar o arquivo de configuração.","Atenção")
        oError:Error("Não foi possível gerar o arquivo de configuração.",.F.) 
    endif


Next

//gera arquivo Zipão da pasta do lote
EasyZIP(cEnvDue,cDirIni,cDirTemp,oError,.T. )
for nC := 1 to len(aArqZip)
    fErase(aArqZip[nC][1])
Next

Return cEnvDue

/*
Função     : GeraArqIni()
Objetivo   : Criar arquivo .Ini
Parâmetros : cDirIni   - Diretorio temp da maquina que esta executando a aplicacao
             cArqXMLDUE - Arquivo XML gerado para Transmissao
Retorno    : cRet - Nome do arquivo .ini gerado. Caso não gere o arquivo, retorna em branco
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 19/05/2017
*/
Static Function GeraArqIni(cDirIni,cArqXMLDUE)
Local cRet := ""
Local cArqIni
Local cXML      := Right(cArqXMLDUE , Len(cArqXMLDUE ) - Rat("\", cArqXMLDUE ))
Local cProcesso := Left(cXML , Rat(".", cXML ) -1 )
Local cUrlPrd   := "https://portalunico.siscomex.gov.br" //Url para o portal de producao
Local cUrlTst   := "https://val.portalunico.siscomex.gov.br" //Url para o portal de Testes/Homologacao

Private cIni := ""
Private cTimeOutIni := "120"

cIni := "[config]"                                      + ENTER
If AvFlags("DU-E2") .And. !Empty(EEC->EEC_NRODUE)//RMD - Alterado para DU-E2, estava DU-E3, impedindo a retificação
    cIni += "method=rectifyDue"                             + ENTER    
Else
	cIni += "method=sendDue"                                + ENTER
EndIf
//Define se sera executada a integracao em embiente de producao ou homologacao
If EasyGParam("MV_EEC0054",,1) == 2 //Producao
    cIni += "environment=production"                    + ENTER
    cIni += "url=" + cUrlPrd                            + ENTER
Else //Teste
    cIni += "environment=training"                      + ENTER
    cIni += "url=" + cUrlTst                            + ENTER
EndIf
cIni += ""                                              + ENTER
cIni += "[params]"                                      + ENTER
if AvFlags("DU-E2") .or.  AvFlags("DU-E3")
    cIni += "due="          + Alltrim(EEC->EEC_NRODUE)  + ENTER //WHRS TE-5041 542634 - Permitir retificação da DUE
    cIni += "ruc="          + Alltrim(EEC->EEC_NRORUC)  + ENTER
Else
    cIni += "due="          + ""      + ENTER //WHRS TE-5041 542634 - Permitir retificação da DUE
    cIni += "ruc="          + ""      + ENTER
endif
cIni += "id_embarque='" + EEC->EEC_PREEMB + "'"         + ENTER
cIni += "id_filial="    + xFilial("EEC")                + ENTER
cIni += "xml_name="     + cXML                          + ENTER
cIni += ""                                              + ENTER
cIni += "[WebClientOptions]"                            + ENTER

//Verifica se possui proxy cadastrado
If !Empty(oUserParams:LoadParam("PROXYURL","","EECDU400"))
    cIni += "proxy.enabled=TRUE"                        + ENTER
    //cIni += "proxy.type=NTLM"                           + ENTER
    cIni += "proxy.host=" + Alltrim(oUserParams:LoadParam("PROXYURL","","EECDU400")) + ENTER
    cIni += "proxy.port=" + Alltrim(oUserParams:LoadParam("PROXYPRT","","EECDU400")) + ENTER
    cIni += "proxy.user=" + Alltrim(oUserParams:LoadParam("PROXYUSR","","EECDU400")) + ENTER
    cIni += "proxy.pass=" + Alltrim(oUserParams:LoadParam("PROXYPSS","","EECDU400")) + ENTER
Else
    cIni += "proxy.enabled=FALSE"                       + ENTER
EndIf

If EasyEntryPoint("EECDU400")
    ExecBlock("EECDU400",.f.,.f.,"GERAARQINI")
EndIf

//o tempo do Timeout e definido em segundos
cIni += "connectionRequestTimeout="+cTimeOutIni          + ENTER
cIni += "connectionTimeout="+cTimeOutIni                 + ENTER
cIni += "socketTimeout="+cTimeOutIni                     + ENTER

cArqIni := EasyCreateFile(cDirIni + cProcesso + ".ini")
If cArqIni != -1
    fWrite(cArqIni,cIni)
    fClose(cArqIni)
    cRet := cProcesso + ".ini"
EndIf

Return cRet

/*
Função     : CriaPastas()
Objetivo   : Criar a estrutura de pastas necessarias para execucao do integrador da DUE
Parâmetros : cDirTemp   - Diretorio principal a ser gerado na pasta temp (\temp\DUE\)
             cDirJar    - Diretorio onde ficara o arquivo .jar (\temp\Due\jar\)
             cDirGerado - Diretorio onde ficara os arquivos gerados para envio (\temp\Due\nome_maquina\Gerado)
             cDirEnviad - Diretorio onde ficara os arquivos já Enviados (\temp\Due\nome_maquina\Enviado)
             cDirRetorn - Diretorio onde ficara os arquivos de Retorno do Integrador (\temp\Due\nome_maquina\Retorno)
             cDirIni    - Diretorio onde sera gerado o arquivo .ini
             cCompName  - Nome da maquina
Retorno    : lRet       - Retorna .T. se criou a estrutura de pastas corretamente
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 19/05/2017
*/
Static Function CriaPastas(cDirTemp,cDirJar,cDirGerado,cDirEnviad,cDirRetorn,cDirIni,cCompName,cSrvGerado,cSrvRetorn,cDirUnzip)
Local lRet := .T.

//Verifica se existe a pasta due dentro da Temp
If !ExistDir(cDirTemp) // \temp\due\
    If MakeDir(cDirTemp) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cDirTemp,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .And. !ExistDir(cDirTemp + cCompName) // \temp\due\nome_maquina\
    If MakeDir(cDirTemp + cCompName) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cDirTemp + cCompName,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .And. !ExistDir(cDirTemp + cDirJar) // \temp\due\jar\
    If MakeDir(cDirTemp + cDirJar) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cDirTemp + cDirJar,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .And. !ExistDir(cDirTemp + cDirJar + "ConfiguracoesWeb",,.F.) // \temp\due\jar\ConfiguracoesWeb //MCF - 22/11/2017
    If MakeDir(cDirTemp + cDirJar + "ConfiguracoesWeb",,.F.) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cDirTemp + cDirJar + "ConfiguracoesWeb",STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .And. !ExistDir(cDirTemp + cDirGerado) // \temp\due\nome_maquina\Gerado
    If MakeDir(cDirTemp + cDirGerado) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cDirTemp + cDirGerado,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .And. !ExistDir(cDirTemp + cDirEnviad) // \temp\due\nome_maquina\Enviado
    If MakeDir(cDirTemp + cDirEnviad) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cDirTemp + cDirEnviad,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .And. !ExistDir(cDirTemp + cDirRetorn) // \temp\due\nome_maquina\Retorno
    If MakeDir(cDirTemp + cDirRetorn) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cDirTemp + cDirRetorn,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .And. !ExistDir(cDirTemp + cDirRetorn + cDirUnzip) // \temp\due\nome_maquina\Retorno\Unzip
    If MakeDir(cDirTemp + cDirRetorn + cDirUnzip) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cDirTemp + cDirRetorn + cDirUnzip,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .and. !empty(cDirIni) .And. !ExistDir(cDirIni)
    If MakeDir(cDirIni) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cDirIni,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .And. !ExistDir(cSrvGerado)
    If MakeDir(cSrvGerado) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cSrvGerado,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

If lRet .And. !ExistDir(cSrvRetorn)
    If MakeDir(cSrvRetorn) <> 0
        MsgInfo(STR0017 + ENTER +; //"O sistema não pode criar os diretórios necessários para a transmissão do arquivo."
                cSrvRetorn,STR0002)//###"Atenção"
        lRet := .F.
    EndIf
EndIf

Return lRet

/*
Função     : EditConfigs()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Edição de configurações do usuario
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 22/05/2017
*/
*-----------------------------------------*
Static Function EditConfigs()
*-----------------------------------------*
Local nLin := 40, nCol := 12
Local lRet := .F.
Local bOk := {|| iif( vldjavaexe(cDirJava), lRet := .T., lRet := .F. ) , iif( lRet, oDlg:End() ,  ) }
Local bCancel := {|| oDlg:End() }
Local oDlg
Local cDirJava  := If(!Empty(oUserParams:LoadParam("DIRJAVA","","EECDU400")),oUserParams:LoadParam("DIRJAVA"), "Java.exe")
Local cDirTrans := If(!Empty(oUserParams:LoadParam("DIRTEMP","","EECDU400")),oUserParams:LoadParam("DIRTEMP"),  GetTempPath(.T.)) //+ "DUE\"
Local cPrxUrl   := If(!Empty(oUserParams:LoadParam("PROXYURL","","EECDU400")),oUserParams:LoadParam("PROXYURL"), "")
Local cPrxPrt   := If(!Empty(oUserParams:LoadParam("PROXYPRT","","EECDU400")),oUserParams:LoadParam("PROXYPRT"), "")
Local cPrxUsr   := If(!Empty(oUserParams:LoadParam("PROXYUSR","","EECDU400")),oUserParams:LoadParam("PROXYUSR"), "")
Local cPrxPss   := If(!Empty(oUserParams:LoadParam("PROXYPSS","","EECDU400")),oUserParams:LoadParam("PROXYPSS"), "")
Local bSetFileTra := {|| cDirTrans := cGetFile("",STR0018, 0, cDirTrans,, GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) }  //"Diretório local para transmissão de arquivos"
Local bSetFileJav := {|| cDirJava  := cGetFile(,STR0019, 0, "\" ,.F., GETF_LOCALHARD,.T.) }  //"Diretório local onde encontra-se o executável 'Java.exe'."

   if at("DUE",upper(cDirTrans)) == 0
      if rat("\",cDirTrans) == len(cDirTrans)
         cDirTrans += "DUE\"
      else
         cDirTrans += "\DUE\" 
      endif
   endif

   cPrxUrl := If(Empty(cPrxUrl), Space(100), cPrxUrl)
   cPrxPrt := If(Empty(cPrxPrt), Space(6)  , cPrxPrt)
   cPrxUsr := If(Empty(cPrxUsr), Space(50) , cPrxUsr)
   cPrxPss := If(Empty(cPrxPss), Space(50) , cPrxPss)

   DEFINE MSDIALOG oDlg TITLE STR0020 + cUserName FROM 320,400 TO 820,785 OF oMainWnd PIXEL  //"Configurações para o usuário: "

      @ nLin, 6 To 111, 181 Label STR0021 Of oDlg Pixel  //"Preferências"
      nLin += 10
      @ nLin,nCol Say STR0018 Size 160,08 PIXEL OF oDlg  //"Diretório local para transmissão de arquivos"
      nLin += 10
      @ nLin,nCol MsGet cDirTrans Size 150,08 PIXEL WHEN .F. OF oDlg
      @ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileTra) SIZE 10,10 PIXEL OF oDlg

      nLin += 20
      @ nLin,nCol Say STR0019 Size 160,08 PIXEL OF oDlg  //"Diretório local onde encontra-se o executável 'Java.exe'."
      nLin += 10
      @ nLin,nCol MsGet cDirJava Size 150,08 PIXEL WHEN .F. OF oDlg
      @ nLin,nCol+150 BUTTON "..." ACTION Eval(bSetFileJav) SIZE 10,10 PIXEL OF oDlg

      nLin += 25
      @ nLin, 6 To 240, 181 Label STR0022 Of oDlg Pixel  //"Configurações de Proxy"
      nLin += 10
      @ nLin,nCol Say STR0023 Size 160,08 PIXEL OF oDlg  //"URL:"
      nLin += 10
      @ nLin,nCol MsGet cPrxUrl Size 150,08 PIXEL OF oDlg

      nLin += 20
      @ nLin,nCol Say STR0024 Size 160,08 PIXEL OF oDlg  //"Porta:"
      nLin += 10
      @ nLin,nCol MsGet cPrxPrt Size 150,08 PIXEL OF oDlg

      nLin += 20
      @ nLin,nCol Say STR0025 Size 160,08 PIXEL OF oDlg  //"Usuário:"
      nLin += 10
      @ nLin,nCol MsGet cPrxUsr Size 150,08 PIXEL OF oDlg

      nLin += 20
      @ nLin,nCol Say STR0026 Size 160,08 PIXEL OF oDlg  //"Senha:"
      nLin += 10
      @ nLin,nCol MsGet cPrxPss Size 150,08 PIXEL OF oDlg


   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lRet
      cDirTrans := If(!Empty(cDirTrans) .AND. Right(cDirTrans,1) <> "\",cDirTrans+"\",cDirTrans)
      oUserParams:SetParam("DIRTEMP",  If(!Empty(cDirTrans),cDirTrans,GetTempPath(.T.)),"EECDU400")
      oUserParams:SetParam("DIRJAVA" , cDirJava ,"EECDU400")
      oUserParams:SetParam("PROXYURL", If(!Empty(cPrxUrl),cPrxUrl,""),"EECDU400")
      oUserParams:SetParam("PROXYPRT", If(!Empty(cPrxPrt),cPrxPrt,""),"EECDU400")
      oUserParams:SetParam("PROXYUSR", If(!Empty(cPrxUsr),cPrxUsr,""),"EECDU400")
      oUserParams:SetParam("PROXYPSS", If(!Empty(cPrxPss),cPrxPss,""),"EECDU400")

   EndIf

Return lRet
/*
Função     : vldjavaexe()
Parametros : cDirJava
Retorno    : lRet
Objetivos  : validar se existe o caminho do arquivo Java
Autor      : Miguel Prado Gontijo
Data/Hora  : 10/09/2020
*/
static Function vldjavaexe(cDirJava)
Local lRet := .T.
    if ! file(cDirJava)
        MsgInfo("Arquivo java não encontrado verifique o caminho do arquivo e tente novamente.")
        lRet := .F.
    endif
Return lRet
/*
Função     : ExecIntJav()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Executar o integrador Java
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 22/05/2017
*/
Static Function ExecIntJav(cFileName,lEnd)
Local lRet   := .T.
Local cMensagem := STR0027 //"Tempo máximo para execução"
Local nSeconds  := 60*60
Local nTimeOut  := Seconds() + nSeconds
Local nHandle   := 0
Local nHour
Local nMinute
Local nSecond

ProcRegua(nSeconds)

Begin Sequence

    nHandle := F_ERROR
    //Tenta abrir o arquivo em modo exclusivo
    While lRet .And. (!File(cFileName) .Or. (nHandle := EasyOpenFile(cFileName, FO_EXCLUSIVE)) == F_ERROR)
        // Se o cliente cancelar ou o exceder o tempo
        If lEnd .Or. nTimeOut <= Seconds()
            lRet := .F.
        Else
            nHour   := Int( nSeconds / 3600 )
            nMinute := Int( ( nSeconds - (nHour*3600) ) / 60 )
            nSecond := Int( nSeconds - (nHour*3600) - (nMinute*60) )
            IncProc(cMensagem+" ("+StrZero(nHour,2)+":"+StrZero(nMinute,2)+":"+StrZero(nSecond,2)+")")
            AvDelay(1)
            nSeconds--
        EndIf
    End

    If nHandle != F_ERROR
        FClose( nHandle )
    EndIf
    If File(cFileName)
        FErase(cFileName)
    EndIF
End Sequence

Return lRet

/*
Função     : ProcRetDue()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Processa o arquivo de retorno do integrador DUE
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 23/05/2017
*/
Static Function ProcRetDue(cDirRetorn,cProcesso)
Local cTagErro  := "[Errors]"
Local cTagResp  := "[response]"
Local aIni      := {}
Local aArquivos := {}
Local cMsg      := STR0028 + ENTER + "(" + cProcesso + ".xml)" //"Não foi possível ler o arquivo de retorno da integração!"
Local cProtocDue:=""
Local cDateDue  := ""
Local cNroRuc   := ""
Local cChaveAcesso := ""
Local nI
Local aXml      := {}
Local aParam    := {}
Local cMemo     := ""

if file(cDirRetorn + cProcesso+".ini")
    aParam  := EasyGetINI(cDirRetorn + cProcesso + ".ini", "[params]" , "[",.T.,.T.)
    if len(aParam) > 0
        nPosEmb := aScan( aParam , {|x| 'id_embarque' $ x } )
        nPosFil := aScan( aParam , {|x| 'id_filial' $ x } )
        cFil    := AvKey( Alltrim( substr( aParam[nPosFil] , at("=",aParam[nPosFil]) +1 , len(aParam[nPosFil]))) , "EEC_FILIAL")
        cPreEmb := AvKey( Alltrim( substr( strtran(aParam[nPosEmb], "'" , "" ) , at( "=" , aParam[nPosEmb] ) +1 , len(aParam[nPosEmb]))) , "EEC_PREEMB")

        if AvFlags("DU-E3")
            cSeq := DUESeqHist(cPreEmb)
            DBSELECTAREA("EK0")
            EK0->( DbSetOrder(1) , MSSeek(cFil+cPreEmb+cSeq) )
        EndIF
        DBSELECTAREA("EEC")
        EEC->( DbSetOrder(1) , MsSeek(cFil+cPreEmb) )

        //Verifica se o integrador retornou algum erro
        aINI := EasyGetINI(cDirRetorn + cProcesso + ".ini", cTagErro, "[",.T., .T.)//RMD - Informa o último parâmetro para que a consulta seja case UNSENSITIVE
        If ValType(aINI) == "A" .And. Len(aINI) > 0
            cMsg := STR0029 + ENTER //"Não foi possível efetuar a transmissão do arquivo!"
            cMsg += "(" + cProcesso + ".xml)" + ENTER + ENTER
            For nI := 1 To Len(aINI)
                If At('=',Alltrim(aIni[nI])) > 0
                    cMsg += "-" + Right(Alltrim(aIni[nI]) , Len(Alltrim(aIni[nI]) ) - Rat("=", Alltrim(aIni[nI]) )) + ENTER
                EndIf
            Next
            if  AvFlags("DU-E3")
                // grava o xml de retorno na EK0 -- MPG - 28/03/2018
                EECDU100GRV( 3, EEC->EEC_FILIAL ,EEC->EEC_PREEMB, "" , __cUserID , dDataBase, "", cMsg )
            endif
        Else
            aINI := EasyGetINI(cDirRetorn + cProcesso + ".ini", cTagResp, "[",.T.,.T.)

            If ValType(aINI) == "A"
                If Len(aINI) > 0
                    cMsg := STR0030 + ENTER //"Arquivo transmitido com sucesso!"
                    cMsg += "(" + cProcesso + ".xml)" + ENTER + ENTER
                    For nI := 1 To Len(aINI)
                        If At('=',Alltrim(aIni[nI])) > 0
                            cMsg += Alltrim(aIni[nI]) + ENTER
                            If ("DUE" $ Upper(Left(aIni[nI],3))) .Or. ("NUMERODUE" $ Upper(aIni[nI]))
                                cProtocDue :=  Alltrim(Right(Alltrim(aIni[nI]) , Len(Alltrim(aIni[nI]) ) - Rat("=", Alltrim(aIni[nI]) )))
                            EndIf
                            If "DATE" $ Upper(Left(aIni[nI],4))
                                cDateDue :=  Alltrim(Right(Alltrim(aIni[nI]) , Len(Alltrim(aIni[nI]) ) - Rat("=", Alltrim(aIni[nI]) )))
                            EndIf
                            If ("RUC" $ Upper(Left(aIni[nI],3))) .Or. ("NUMERORUC" $ Upper(aIni[nI]))
                                cNroRuc :=  Alltrim(Right(Alltrim(aIni[nI]) , Len(Alltrim(aIni[nI]) ) - Rat("=", Alltrim(aIni[nI]) )))
                            EndIf
                            If ("CHAVEDEACESSO" $ Upper(aIni[nI])) .Or. ("CHAVEACESSO" $ Upper(aIni[nI]))
                                cChaveAcesso :=  Alltrim(Right(Alltrim(aIni[nI]) , Len(Alltrim(aIni[nI]) ) - Rat("=", Alltrim(aIni[nI]) )))
                            EndIf
                        EndIf
                    Next
                        
                    //Gravar o numero due no campo EEC_VMINGE
                    GrvDueMemo(cProtocDue,cDateDue,cNroRuc,cChaveAcesso)

                    if  AvFlags("DU-E3")
                            cMemo := memoread(cDirRetorn + cProcesso + ".xml")
                            /*aXml := EasyGetINI(cDirRetorn + cProcesso + ".xml", , ,.T.)
                            If ValType(aINI) == "A"
                                For nI := 1 to len(aXml)
                                    cMemo += aXml[nI] + ENTER
                                next
                            endif*/
                        // grava o xml de retorno na EK0 -- MPG - 28/03/2018
                        EECDU100GRV( 2, EEC->EEC_FILIAL , EEC->EEC_PREEMB, "" , __cUserID , dDataBase, cMemo , cMsg, cProtocDue, cNroRuc)
                    endif
                EndIf
            Else
                MsgStop("O Integrador não foi executado com sucesso pelo sistema! Verifique com o Administrador do sistema.",STR0002)
            EndIf
        EndIf
    else
        cMsg := "Não foi possível encontrar os parâmetros no arquivo de retorno " + cProcesso + ".ini no diretório " + cDirRetorn + "." 
    EndIf

    //aDir( cDirRetorn+ "\*.*",aArquivos) //Apaga arquivos de log que foram extraidaos do .zip
    aArquivos := Directory(cDirRetorn + "\*.*")
    For nI := 1 To Len(aArquivos)
        fErase(cDirRetorn + aArquivos[nI][1])
    Next
else
    cMsg := "Não foi possível encontrar o arquivo de retorno " + cProcesso + ".ini no diretório " + cDirRetorn + "." 
endif
// ponto de entrada

//Apagar arquivos que faltam
//EECVIEW(cMsg,STR0001,STR0031) //"Declaração Única de Exportação"###"Retorno da Integração"

Return cMsg

/*
Função     : GrvDueMemo()
Parametros : cProtocDue - Numero do protocolo / cDateDue - Data de registro
Retorno    : Nenhum
Objetivos  : Grava retorno no processo - protocolo e data da due
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Aleração   : Wanderson Henrique Reliquias de Souza - WHRS
Data/Hora  : 24/05/2017
*/
Static Function GrvDueMemo(cProtocDue,cDateDue, cNroRuc, cChaveAcesso)

Local nI        := 1
Local cMemo     := EasyMSMM(EEC->EEC_INFGER,AVSX3("EEC_VMINGE",AV_TAMANHO),,,LERMEMO,,,"EEC","EEC_INFGER")
Local nTotLinhas:= MlCount(cMemo)
Local cNewMemo  := ""
Local cLinha

If(AvFlags("DU-E2"))
    EEC->(RecLock("EEC", .F.))
    If !Empty(cProtocDue)
        EEC->EEC_NRODUE := cProtocDue //WHRS TE-5041 542634 - Permitir retificação da DUE
    EndIf
    If !Empty(cNroRuc)
        EEC->EEC_NRORUC := cNroRuc
    EndIf
    If EEC->(FieldPos("EEC_DTDUE")) > 0 .And. !Empty(cDateDue)
        EEC->EEC_DTDUE := CToD(cDateDue)
    ElseIf !Empty(cDateDue)
        EXL->(dbSetOrder(1))//EXL_FILIAL+EXL_PREEMB
        If EXL->(dbSeek(xFilial("EXL") + EEC->EEC_PREEMB)) .And. EXL->(RecLock("EXL",.F.))
            EXL->EXL_DTDSE := CToD(cDateDue)
            EXL->(MsUnlock())
        EndIf
    EndIf
    If EEC->(FieldPos("EEC_CHVDUE")) > 0 .And. !Empty(cChaveAcesso)
        EEC->EEC_CHVDUE := cChaveAcesso
    EndIf
    EEC->(MsUnlock())
Else
    While nI <= nTotLinhas //Ler as linhas do memo para saber se já existe um protocolo DUE
        cLinha := Alltrim(MemoLine(cMemo,,nI))
        If !("DUE:" $ cLinha)
            cNewMemo += cLinha + ENTER
        EndIf
        nI += 1
    End
    cNewMemo += "DUE: - " + cProtocDue + " - " + cDateDue
    EasyMSMM(EEC->EEC_INFGER,AVSX3("EEC_VMINGE",AV_TAMANHO),,cNewMemo,INCMEMO,,,"EEC","EEC_INFGER")
EndIf

Return
/*
Função     : DU400GetRg()
Parametros : cNf   = Numero da Nota Fiscal de Saida
             cSerie= Série da Nota Fiscal de Saida
Retorno    : aReg
Objetivos  : Retornar recnos dos itens embarcados na Nota de referência
Autor      : Nilson Cesar
Data/Hora  : 25/05/2017
*/
FUNCTION DU400GetRg(cNF,cSerie,cProces,cNumSeq)

Local aRegs := {}
Local cQry  := ""
Default cProces := ""
Default cNumSeq := ""

If /*Empty(cProces) .And.*/ Empty(cNumSeq) //RMD - 24/05/18 - Passa a utilizar o número do embarque nesta comparação
    cQry += "SELECT R_E_C_N_O_ RECNO"
    cQry += " FROM "+RetSqlName("EE9")
    cQry += " WHERE EE9_NF = '"+cNF+"'"
    cQry += " AND EE9_SERIE = '"+cSerie+"'"
    cQry += " AND EE9_PREEMB = '"+cProces+"'"
    cQry += " AND D_E_L_E_T_ = ' '"
Else
    cQry += "SELECT R_E_C_N_O_ RECNO"
    cQry += " FROM "+RetSqlName("EK2")
    cQry += " WHERE EK2_FILIAL = '"+xFilial("EK2")+"'"
    cQry += " AND EK2_PROCES= '"+cProces+"'"
    cQry += " AND EK2_NUMSEQ= '"+cNumSeq+"'"
    cQry += " AND EK2_NRNF  = '"+cNF+"'"
    cQry += " AND EK2_SERIE = '"+cSerie+"'"
    cQry += " AND D_E_L_E_T_= ' '"
EndIf

cQry:=ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QryRecs", .F., .T.)

QryRecs->(DBGoTop())
Do While (QryRecs->(!Bof()) .AND. QryRecs->(!Eof()))
   aAdd(aRegs,QryRecs->RECNO)
   QryRecs->(dBSkip())
EndDo

QryRecs->(DbCloseArea())

Return aRegs

/*
Função     : DU400ChkProc()
Parametros : cCase   = String de Identificação da verificação a ser feita
Retorno    : lRet    = Lógico
Objetivos  : Concentrar verificações que definem se o xml da DU-E pode ou não ser gerado.
Autor      : Nilson Cesar
Data/Hora  : 26/05/2017
*/
FUNCTION DU400ChkProc(cCase)
Local lRet := .T.
Local cQry := ""
Local cMsg := ""
Default cCase := ""


If !Empty(cCase)

   Do CASE

      CASE cCase == "ITENS_x_NOTAS"

         cQry += "SELECT *"
         cQry += " FROM "+RetSqlName("EE9")
         cQry += " WHERE EE9_PREEMB = '"+EEC->EEC_PREEMB+"'"
         cQry += " AND EE9_NF = '"+Space(AvSx3("EE9_NF",AV_TAMANHO))+"'"
         If TcSrvType() <> "AS/400"
            cQry += " AND D_E_L_E_T_ = ' '"
         EndIf

         cQry:=ChangeQuery(cQry)
         dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QryItxNf", .F., .T.)

         QryItxNf->(dbGotop())
         If QryItxNf->(!Eof()) .And. QryItxNf->(!Bof())
            cMsg += STR0037+ENTER
            Do While QryItxNf->(!Eof())
               cMsg += "Item: "+QryItxNf->EE9_COD_I+"| Seq. Embarque: "+QryItxNf->EE9_SEQEMB+ENTER
               QryItxNf->(DbSkip())
            EndDo
            lRet := .F.
         EndIf

         If Type("cMsgCpoDUE") == "C"
            cMsgCpoDUE := cMsg
         EndIf

         QryItxNf->(DbCloseArea())
         cQry := ""

   END CASE

EndIf

Return lRet

/*
Função     : DU400ChgMd()
Parametros : cMoeda
Retorno    : aRet, onde:
                   aRet[1] -> Se conseguiu encontrar a moeda correspondente
                   aRet[2] -> Se conseguiu
Objetivos  : Concentrar verificações que definem se o xml da DU-E pode ou não ser gerado.
Autor      : Nilson Cesar
Data/Hora  : 26/05/2017
*/
Function DU400ChgMd(cMoeda)
Local cMoedaRet := ""
Local aRet      := {}
Default cMoeda  := ""

aRet := {.F.,cMoeda}

If !Empty(cMoeda)

   cMoedaRet :=  Posicione("SYF",1,xfilial("SYF")+Alltrim(cMoeda),"YF_ISO")

   If !empty(cMoedaRet)
      aRet := {.T.,cMoedaRet}
   Else
      aRet := {.F.,cMoeda}
   EndIf

EndIf

REturn aRet

/*
Função     : DU400Relacao(cCampo)
Objetivo   : Inicializador padrão de campo, chamado pelo dicionário SX3
Parâmetros : cCampo
Retorno    : Dado inicial, conforme campo que original a chamada
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 25/05/2017
*/
Function DU400Relacao(cCampo)
Local xRet
Default cCampo:= ReadVar()

Begin Sequence

   Do Case
      Case cCampo == "EEC_STTDUE"
         //1=Pendente Informações;2=Aguardando Geração;3=Aguardando Transmissão;4=Aguardando Retransmissão;5=Registrada;6=Registro RE/DDE
         xRet:= "1"

    End Case
End Sequence

Return xRet
/*
Função     : DU400GrvStatus()
Objetivo   : Gravação do status de transmissão da DU-E no embarque de exportação
Parâmetros :
Retorno    :
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 29/05/2017
*/
Function DU400GrvStatus()
    If EEC->(RecLock("EEC", .F.))
        EEC->EEC_STTDUE:= DU400Status()
        EEC->(MsUnlock())
    EndIf
Return
/*
Função     : DU400StDue()
Objetivo   : Retornar para o dicionário X3_CBOX a lista de possíveis status da DUE
Parâmetros :
Retorno    : Lógico
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/
Function DU400StDue()
Local cBox:= ""
   cBox:= "1=Pendente Informações; 2=Aguardando Geração; 3=Aguardando Transmissão; 4=Aguardando Retificação; 5=Registrada DU-E; 6=Registro por RE/DDE; 7=Não registrado; 8=Embarque Cancelado; 9=DUE Manual"
Return cBox
/*
Função     : DU400Status()
Objetivo   : Atualização do status de transmissão da DU-E
Parâmetros :
Retorno    : Status corrente
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/
Function DU400Status()
Local cStatus:= "1"
Local cStatDUE := If(AvFlags("DU-E3"),getStatDUE(EEC->EEC_PREEMB,DUESeqHist(EEC->EEC_PREEMB)),"")
Local lEmbarqCancel := EEC->EEC_STATUS == "*"

   Begin Sequence

      /* Status: 6-Registro por RE/DDE
         Se ao menos um item tiver RE ou DDE ou se estiver preenchido na capa. */
      If TemDDE_RE()
         cStatus:= "6"

      // Status: 8 - Embarque Cancelado
      ElseIf lEmbarqCancel .and. cStatDUE == "4"
         cStatus:= "8"

      /* Status: 1-Pendente Informações
         Status do processo, enquanto houver informações obrigatórias para a transmissão sem preenchimento. */
      ElseIf (!EECTemDados() .Or. !EE9TemDados() .Or. !DU400SetVal(EEC->EEC_PREEMB,, .T. ) /*Valida as conversões de unidade de medida*/) .And. Empty(EEC->EEC_DTEMBA) //If(Type("aValItem") == "A", @aValItem , nil)
         cStatus:= "1"

      /* Status: 9-DUE Manual  */ // MPG - 27/03/2018 
      ElseIf AvFlags("DU-E3") .And. EEC->(fieldpos("EEC_DUEMAN")) > 0 .and. ! empty(EEC->EEC_DUEMAN) .and. cStatDUE == "5" .and. ! StDUERetif()
         cStatus:= "9"

      /* Status: 2-Aguardando Geração */ // MPG - 27/03/2018 
      ElseIf AvFlags("DU-E3") .And. (Empty(cStatDUE) .Or. cStatDUE $ "3|4") //Status=Falha na Transmissao
         cStatus:= "2"

      /* Status: 3-Aguardando Transmissão
         Informações obrigatórias preenchidas mas sem numero da DUE. */
      ElseIf (!DueProtocolo() .And. Empty(EEC->EEC_DTEMBA)) .or.  (AvFlags("DU-E3") .and. getStatDUE(EEC->EEC_PREEMB,DUESeqHist(EEC->EEC_PREEMB)) <> '2' .and. ! StDUERetif() ) //VldSttDUE(EEC->EEC_FILIAL , EEC->EEC_PREEMB))
         cStatus:= "3"

      /* Status: 4-Aguardando Retificação
         Numero da DU-E Preenchido, porém marcada para retificacao*/
      ElseIf DueProtocolo() .And. StDUERetif()
         cStatus := "4"

      /* Status: 5-Registrada DU-E
         Número da DU-E preenchido e nao marcado para retificacao*/
      ElseIf DueProtocolo() .And. !StDUERetif()
         cStatus:= "5"

      /* Status: 7-Não registrado
         Caso haja data de embarque e não possua RE/DDE nem DUE. */
      ElseIf !Empty(EEC->EEC_DTEMBA) .And. !DueProtocolo()
         cStatus:= "7"

      EndIf

   End Sequence

Return cStatus
/*
Função     : EECTemDados()
Objetivo   : Verificar se as informações da tabela EEC, necessárias para a transmissão da DU-E, foram preenchidas
Parâmetros :
Retorno    : lógico
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/

Static Function EECTemDados()
Local aCamposDUE1:= {}
Local lRet:= .T.
Local nCont
Local cMsg := ""
Local aAreaSYF := SYF->(getArea())
Local aAreaSYA := SYA->(getArea())
Local aAreaSA1 := SA1->(getArea())

Begin Sequence

   If EEC->EEC_EMFRRC <> "22"
      AAdd(aCamposDUE1, "EEC_RECALF")
      AAdd(aCamposDUE1, "EEC_EMFRRC")
      AAdd(aCamposDUE1, "EEC_URFDSP")
   EndIf
   AAdd(aCamposDUE1, "EEC_ENQCOD")
   AAdd(aCamposDUE1, "EEC_MOEDA")
   AAdd(aCamposDUE1, "EEC_IMPORT")
   AAdd(aCamposDUE1, "EEC_FORN")
   AAdd(aCamposDUE1, "EEC_MOTDIS")
   AAdd(aCamposDUE1, "EEC_PAISET")
   AAdd(aCamposDUE1, "EEC_RESPON")

   For nCont:= 1 To Len(aCamposDUE1)
      If aCamposDUE1[ncont] == "EEC_MOEDA"
         Chkfile("SYF")
         SYF->(dbSetOrder(1))
         If SYF->(dbSeek(xFilial("SYF") + EEC->EEC_MOEDA)) .And. Empty(SYF->YF_ISO)
            cMsg += "Campo: '"+ AvSx3("YF_ISO", AV_TITULO) +"' (YF_ISO) não informado!"+ENTER
            cMsg += "Verifique o cadastro da moeda informada no processo!"+ENTER
            lRet := .F.
         EndIf
      ElseIf aCamposDUE1[ncont] == "EEC_IMPORT"
         Chkfile("SYA")
         SA1->(dbSetOrder(1))
         SYA->(dbSetOrder(1))
         If SA1->(dbSeek(xFilial("SA1") + EEC->EEC_IMPORT + EEC->EEC_IMLOJA)) .And. SYA->(dbSeek(xfilial("SYA") + SA1->A1_PAIS)) .And. Empty(SYA->YA_PAISDUE)
            cMsg += "Campo: '"+ AvSx3("YA_PAISDUE", AV_TITULO) +"' (YA_PAISDUE) não informado!"+ENTER
            cMsg += "Verifique o cadastro do país do cliente informado no processo!"+ENTER
            lRet := .F.
         EndIf
      ElseIf aCamposDUE1[ncont] == "EEC_FORN"
         If Empty(BuscaCGCFor(EEC->EEC_FORN, EEC->EEC_FOLOJA))
            cMsg += "Campo: '"+ AvSx3("A2_CGC", AV_TITULO) +"' (A2_CGC) não informado!"+ENTER
            cMsg += "Verifique o cadastro do fornecedor/loja informado no processo!"+ENTER
            lRet := .F.
         EndIf
      ElseIf aCamposDUE1[ncont] == "EEC_MOTDIS"
         EEM->(DbSetOrder(1))
         If AvFlags("DU-E2") .And. !EEM->(dbSeek(xFilial("EEM")+EEC->EEC_PREEMB+AvKey('N',"EEM_TIPOCA"))) .And. Empty(EEC->EEC_MOTDIS)
            cMsg += "Campo: '"+ AvSx3(aCamposDUE1[ncont], AV_TITULO) +"' ("+ aCamposDUE1[ncont] +") deve ser informado para registro de DUE sem NF!"+ENTER
            lRet:= .F.
         EndIf
      ElseIf aCamposDUE1[ncont] == "EEC_PAISET"
         If Empty(Posicione("SYA",1,xfilial("SYA")+EEC->EEC_PAISET,"YA_PAISDUE"))
            cMsg += "Campo: '"+ AvSx3("YA_PAISDUE", AV_TITULO) +"' (YA_PAISDUE) não informado!"+ENTER
            cMsg += "Verifique o cadastro do país de destino do Embarque (EEC_PAISET)."+ENTER
            lRet:= .F.
         EndIf
      ElseIf aCamposDUE1[ncont] == "EEC_RESPON"
         If DU400HasJus(EEC->EEC_PREEMB)
            If Empty(EEC->EEC_RESPON)
               cMsg += "Campo: '"+ AvSx3(aCamposDUE1[ncont], AV_TITULO) +"' ("+ aCamposDUE1[ncont] +") não informado!"+ENTER
               cMsg += "É necessário informar o responsável pelo processo quando algum dos itens possuir justiticativa."+ENTER
               lRet:= .F.
            Else
                If Empty(Posicione("EE3", 1, xFilial("EE3")+"X"+EEC->(AvKey(EEC_FORN, "EE3_CONTAT")+AvKey(EEC_FOLOJA, "EE3_COMPL")), "EE3_EMAIL"))
                    cMsg += "Campo: '"+ AvSx3("EE3_EMAIL", AV_TITULO) +"' (EE3_EMAIL) não informado!"+ENTER
                    cMsg += "É necessário informar o e-mail do responsável pelo processo quando algum dos itens possuir justiticativa."+ENTER
                    cMsg += "Identifique o responsável pelo processo no campo " + AvSx3("EEC_RESPON", AV_TITULO) + " (EEC_RESPON) e informe um e-mail para o contato no cadastro de exportadores." +ENTER
                    lRet:= .F.
                EndIf
                If Empty(Posicione("EE3", 1, xFilial("EE3")+"X"+EEC->(AvKey(EEC_FORN, "EE3_CONTAT")+AvKey(EEC_FOLOJA, "EE3_COMPL")), "EE3_FONE"))
                    cMsg += "Campo: '"+ AvSx3("EE3_FONE", AV_TITULO) +"' (EE3_FONE) não informado!"+ENTER
                    cMsg += "É necessário informar o telefone do responsável pelo processo quando algum dos itens possuir justiticativa."+ENTER
                    cMsg += "Identifique o responsável pelo processo no campo " + AvSx3("EEC_RESPON", AV_TITULO) + " (EEC_RESPON) e informe um telefone para o contato no cadastro de exportadores." +ENTER
                    lRet:= .F.
                EndIf
            EndIf
         EndIf
      Else
         If Empty(EEC->&(aCamposDUE1[nCont]))
            cMsg += "Campo: '"+ AvSx3(aCamposDUE1[ncont], AV_TITULO) +"' ("+ aCamposDUE1[ncont] +") não informado!"+ENTER
            lRet:= .F.
         EndIf
      EndIf
   Next

    //Atualiza a chave das notsa fiscais na tabela EEM
    if EasyGParam("MV_EECFAT",,.F.) .and. EEM->(DbSetOrder(1) , DbSeek(xFilial("EEM")+EEC->EEC_PREEMB+"N"))
        Do While EEM->(!Eof() .And. EEM_FILIAL+EEM_PREEMB+EEM_TIPOCA == xFilial("EEM")+EEC->EEC_PREEMB+AvKey("N","EEM_TIPOCA"))
            If EEM->(FieldPos("EEM_CHVNFE")) > 0 .And. Empty(EEM->EEM_CHVNFE)
                SF2->(DbSetOrder(1))
                If SF2->(DbSeek(xFilial("SF2")+AvKey(EE9->EE9_NF,"F2_DOC")+AvKey(EE9->EE9_SERIE,"F2_SERIE")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))
                    EEM->(RecLock("EEM",.F.))
                    EEM->EEM_CHVNFE := SF2->F2_CHVNFE
                    EEM->(MsUnlock())
                EndIf
            EndIf
            EEM->(DbSkip())
        EndDo
    endif

End Sequence

RestArea(aAreaSYF)
RestArea(aAreaSYA)
RestArea(aAreaSA1)

If Type("cMsgCpoDUE") == "C" .And. !lRet
   cMsgCpoDUE += "[PROCESSO: '"+Alltrim(EEC->EEC_PREEMB)+"']"+ENTER+cMsg
EndIf

Return lRet

/*
Função     : EE9TemDados()
Objetivo   : Verificar se as informações da tabela EE9, necessárias para a transmissão da DU-E, foram preenchidas
Parâmetros :
Retorno    : lógico
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/
Static Function EE9TemDados()
Local aCamposDUE:= {}
Local aCamposDUE2:= {}
Local lRet:= .T.
Local cQuery:= ""
Local nCont:= 0
Local cMsg := ""
Local aArea := EEM->(GetArea())

   EEM->(DbSetOrder(1))
   EEM->(dbSeek(xFilial("EEM")+EEC->EEC_PREEMB+AvKey('N',"EEM_TIPOCA")))
   lSemNota := EEM->(Eof())

   AAdd(aCamposDUE, "EE9_POSIPI")
   AAdd(aCamposDUE, "EE9_SEQEMB")
   AAdd(aCamposDUE, "EE9_COD_I")
   //Drawback
   /* RMD - 28/06/18 - Não é possível validar desta forma, pois é possível ter itens com e sem drawback no mesmo processo. Esta validação bloquearia todos os itens.
   If !Empty(EEC->EEC_ENQCOX) .Or. "8110" $ AllTrim(EEC->EEC_ENQCOD)
      AAdd(aCamposDUE, "EE9_ATOCON")
   EndIf
   */

   aCamposDUE2 := aCamposDUE

   If !lSemNota
      AAdd(aCamposDUE, "EE9_NF")
   EndIf

   cQuery:= MontaQuery("EE9", aCamposDUE, aCamposDUE2, .T.)

   //Filtrar pro processo
   cQuery += " And EE9.EE9_PREEMB = '" + EEC->EEC_PREEMB + "'"

   //Se retornar registro, é porque os campos obrigatórios não foram preenchidos no processo.
   If EasyQryCount(cQuery) > 0
      cMsg += If(lSemNota,STR0040 + ENTER,"")//"Processo para registro antecipado (sem as notas fiscais)"
      cMsg += STR0041 + ENTER // "Existem itens do processo sem informações necessárias para a D.U-E."S
      EasyQry(cQuery,"REGPENDINF")
      REGPENDINF->(DbGotop())
      Do While REGPENDINF->(!Eof())
         cMsg += "Item: "+REGPENDINF->EE9_COD_I+"| " + STR0042 + REGPENDINF->EE9_SEQEMB+"| " + STR0043 +REGPENDINF->EE9_POSIPI+if(!lSemNota,"'| " + STR0044 + "'"+REGPENDINF->EE9_NF+"'","")+ENTER
         REGPENDINF->(DbSkip())
      EndDo
      REGPENDINF->(DbCloseArea())
      lRet:= .F.
   EndIf

If Type("cMsgCpoDUE") == "C" .And. !lRet
   cMsgCpoDUE += "["+STR0045+Alltrim(EEC->EEC_PREEMB)+"]"+ENTER+cMsg//"ITENS DO PROCESSO: "
EndIf

RestArea(aArea)
Return lRet

/*
Função     : MontaQuery()
Objetivo   : Montar uma query com base nos campos de um array
Parâmetros : cAlias - tabela origem da pesquisa
             aCampos - array com os campos para montagem da query
             aWhereCampos - campos adicionais da condição Where
             lVazio - indica se a condição é campos vazios ou campos preenchidos. Default: preenchidos
Observação : Será usado o operador Or na comparação dos campos, na senteça Where
Retorno    : cQuery - string com a query montada
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/
Static Function MontaQuery(cAlias, aCampos, aWhereCampos, lVazio)
Local cQuery:= "", cSelect:= "", cWhere:= "", cPrefixo:= "", cCond:= ""
Local nCont:= 0
Default aWhereCampos:= {}
Default lVazio:= .F.


   If SubStr(cAlias, 1, 1) <> "S"
      cPrefixo:= cAlias
   Else
      cPrefixo:= SubStr(cAlias, 2, 2)
   EndIf

   cSelect:= "Select "
   For nCont:= 1 To Len(aCampos)

      If nCont > 1
         cSelect += ", "
      EndIf

      cSelect +=  cPrefixo + "." + aCampos[nCont]

   Next

   cSelect += " From " + RetSqlName(cAlias) + " " + cPrefixo

   //Where
   cWhere:= "Where " + cPrefixo + "." + cPrefixo + "_FILIAL = '" + xFilial(cAlias) + "'"
   //Campos deletados
   If TcSrvType() <> "AS/400"
      cWhere += " And " + cPrefixo + ".D_E_L_E_T_ <> '*'"
   EndIf


   If Len(aWhereCampos) > 0

      If lVazio
         cCond:= " = ''"
      Else
         cCond:= " <> ''"
      EndIf

      cWhere += " And ("
      For nCont:= 1 To Len(aWhereCampos)
         If nCont > 1
            cWhere += " Or "
         EndIf

         cWhere +=  cPrefixo + "." + aWhereCampos[nCont] + cCond
      Next
      cWhere += ")"

   EndIf

   cQuery:= ChangeQuery(cSelect + " " + cWhere)

Return cQuery


/*
Função     : TemDDE_RE()
Objetivo   : Retornar se ao menos um item tem RE ou DDE ou se o DDE está preenchido na capa.
Parâmetros :
Retorno    : Lógico
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/
Static Function TemDDE_RE()
Local lRet:= .F.
Local cQuery:= ""
Local aCampos:= {"EE9_RE", "EE9_NRSD"}

   cQuery:= MontaQuery("EE9", aCampos, aCampos)
   cQuery += " And EE9.EE9_PREEMB = '" + EEC->EEC_PREEMB + "'"

   //Se retornar registro é porque foi registrado no Siscomex
   If EasyQryCount(cQuery) > 0 .Or. !Empty(EXL->EXL_DSE)
      lRet:= .T.
   EndIf


If Type("cMsgCpoDUE") == "C" .And. lRet
   cMsgCpoDUE += "[PROCESSO: '"+Alltrim(EEC->EEC_PREEMB)+"']"+ENTER+"Já possui registro por RE/DDE."
EndIf

Return lRet

/*
Função     : DueProtocolo()
Parametros :
Retorno    : Lógico - .T. se possui número de protocolo da DUE
Objetivos  : Ler as linhas do memo para saber se já existe um protocolo DUE
Autor      : WFS - Wilsimar Fabrício da Silva
Data/Hora  : 26/05/2017
*/
Static Function DueProtocolo()
Local lRet:= .F.
Local cMemo:= ""
Local nLinha:= 1
Local nTotLinhas:= 0
Local cLinha:= ""

If AvFlags("DU-E2")
    //WHRS TE-5041 542634 - Permitir retificação da DUE
    IF !EMPTY(EEC->EEC_NRODUE)
        lRet := .T. 
    ENDIF
ELSE
    DBSelectArea("EEC")
    cMemo:= MSMM(EEC->EEC_INFGER, AvSx3("EEC_VMINGE", AV_TAMANHO),,,LERMEMO)
    nTotLinhas:= MlCount(cMemo)

    While nLinha <= nTotLinhas
        cLinha := Alltrim(MemoLine(cMemo,, nLinha))
        If "DUE:" $ cLinha
            lRet:= .T.
            Exit
        EndIf
        nLinha++
    EndDo
EndIf

Return lRet

/*
Função     : ConfiguracoesWeb()
Parametros : cDirIni   - Diretorio temp da maquina que esta executando a aplicacao
Retorno    : cRet - Nome do arquivo .ini gerado. Caso não gere o arquivo, retorna em branco
Objetivos  : Ler as linhas do memo para saber se já existe um protocolo DUE
Autor      : MCF - Marcos Roberto Ramos Cavini Filho
Data/Hora  : 22/11/2017
*/

Static Function ConfiguracoesWeb(cDirJar)
Local cRet := ""
Local cConfWeb := ""
Local cArqConfWeb
Local cUrlPrd   := "https://portalunico.siscomex.gov.br" //Url para o portal de producao
Local cUrlTst   := "https://val.portalunico.siscomex.gov.br" //Url para o portal de Testes/Homologacao
Local cDirWeb := cDirJar + "ConfiguracoesWeb\"

cConfWeb := "[url-training]"      + ENTER
cConfWeb += "url=" + cUrlTst      + ENTER
cConfWeb += ""                    + ENTER   
cConfWeb += "[url-production]"    + ENTER
cConfWeb += "url=" + cUrlPrd      + ENTER

cArqConfWeb := EasyCreateFile(cDirWeb + "WebNavigation-PortalUnico-Enviroment.ini",,,.F.)
If cArqConfWeb != -1
    fWrite(cArqConfWeb,cConfWeb)
    fClose(cArqConfWeb)
    cRet := "WebNavigation-PortalUnico-Enviroment.ini"
EndIf

Return cRet

/*
Função     : VldGerDUE()
Parametros : 
Retorno    : lRet - .T. permitie gerar nova delcaracao; .F. nao permite gerar nova declaracao
Objetivos  : Verificar se ja existe due gerada para o processo e se pode gerar uma nova
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 14/05/2018
*/
Static Function VldGerDUE(cPreemb)
Local lRet      := .T.
Local cSeqHist  := ""

    If AvFlags("DU-E3")
        cSeqHist := DUESeqHist(cPreemb)
        EK0->(dbSetOrder(1))
        If !Empty(cSeqHist) .And. EK0->(dbSeek(xFilial("EK0") + cPreemb + cSeqHist))

            Do Case
                /* Se Ja existe DUE gerada e esta aguardando transmissao, nao permite gerar uma nova.*/
                Case EK0->EK0_STATUS == "1" //"Aguardando transmissão"
                    MsgInfo("Não é possível gerar uma nova DUE, pois já existe uma aguardando transmissão.",STR0002)//" "###"Atenção"
                    lRet := .F.

                Case EK0->EK0_STATUS $ "2|5" .And. EK0->EK0_RETIFI != "2" //"Transmitido com sucesso" ### "Não necessita Retificação"
                    MsgInfo("Não é possível gerar uma nova DUE, pois não existem dados novos para transmissão.",STR0002)//" "###"Atenção"
                    lRet := .F.

            End Case
        EndIf
    EndIf

Return lRet

/*
Função     : StDUERetif()
Parametros :
Retorno    : Lógico - .T. se possui número de protocolo da DUE, mas esta marcado que precisa retificar devido o embarque ter sofrido alteração.
Objetivos  : Apenas para DU-E3, verifica se a DUE que esta transmitida esta marcada como necessario retificacao
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 15/05/2018
*/
Function StDUERetif()
Local lRet      := .F.
Local cSeqHist  := ""

    If AvFlags("DU-E3") .And. !Empty(EEC->EEC_NRODUE) //THTS - 15/05/2018
        EK0->(dbSetOrder(1))
        cSeqHist := DUESeqHist(EEC->EEC_PREEMB)
        If !Empty(cSeqHist) .And. EK0->(msSeek(xFilial("EK0") + EEC->EEC_PREEMB + cSeqHist)) .And. EK0->EK0_RETIFI == "2" //1=DUE Válida; 2=Necessário Retificar;
            lRet := .T.
        EndIf
    EndIf

Return lRet

/*
Funcao     : DUESeqHist()
Parametros : 
Retorno    : cRet - Retorna a ultima sequencia da DUE caso existe.
Objetivos  : Verificar se existe DUE gerada para o processo
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 10/05/2018
*/
Function DUESeqHist(cPreemb)
Local cRet := ""
Local cQry := ""

cQry := "SELECT MAX(EK0_NUMSEQ) EK0_NUMSEQ "
cQry += "FROM " + RetSQLName("EK0")
cQry += " WHERE EK0_FILIAL   = '" + xFilial("EK0")  + "' "
cQry += " AND EK0_PROCES     = '" + cPreemb + "' "
cQry += " AND D_E_L_E_T_     = ' '"

If Select("TMPEK0") > 0
    TMPEK0->(dbCloseArea())
EndIf

cQry := ChangeQuery(cQry) 
DBUseArea(.T., "TOPCONN" , TCGenQry(,, cQry), "TMPEK0", .T., .T.)

If TMPEK0->(!EOF())
    cRet := TMPEK0->EK0_NUMSEQ
EndIf

TMPEK0->(dbCloseArea())

Return cRet

/*
Funcao     : getStatDUE()
Parametros : -
Retorno    : cRet - "1"="Aguardando transmissão"; "2"="Transmitido com sucesso"; "3"="Falha na transmissão"
Objetivos  : Retorna o status da ultima DUE gerada
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 15/05/2018
*/
Function getStatDUE(cPreemb,cSeqHist)
Local cRet      := ""
Local aAreaEK0  := EK0->(getarea())

EK0->(dbSetOrder(1))
If !Empty(cSeqHist) .And. EK0->(dbSeek(xFilial("EK0") + cPreemb + cSeqHist))
    cRet := EK0->EK0_STATUS
EndIf

restarea(aAreaEK0)
Return cRet

/*
Funcao : DU400GetNfSRem
Objetivos : Verifica as notas de remessa (saída) vinculadas à NF de saída da venda
Autor: : Rodrigo Mendes Diaz
cImport e cImLoja serão ignorados
*/
Function DU400GetNfSRem(cNFOri, cSerOri, cImport, cImLoja, cFatSeq, cPreemb, aNotas)
Local i    
Private aNfsItem := {}    
    //MFR 22/10/2019 OSSME-3933
    If EasyGParam("MV_EECFAT",,.F.)
       cFatSeq:= StrZero(val(cFatSeq), AvSx3("D2_ITEM", AV_TAMANHO))
    Else
       cFatSeq:= StrZero(val(cFatSeq), AvSx3("EES_FATSEQ", AV_TAMANHO))
    EndIf

    if AvFlags("NOTAS_FISCAIS_SAIDA_LOTE_EXPORTACAO")
        aNfsItem := DU400NFLtExp(cNFOri, cSerOri, cImport, cImLoja, cFatSeq, cPreemb, aNotas)
    endif
    
    If EasyEntryPoint("DU400NFREM")
        aNfsItem := ExecBlock("DU400NFREM", .F., .F., {cNFOri, cSerOri, cImport, cImLoja, cFatSeq})
    EndIf

    For i := 1 To Len(aNfsItem)
        If !aScan(aNotas, aNfsItem[i][1])
            aAdd(aNotas, {aNfsItem[i][1]})
        EndIf
    Next

Return aNfsItem

/*
Funcao     : DU400NFLtExp
Objetivos  : Verifica as notas de remessa (saída) vinculadas à NF de saída da venda
Autor:     : Rodrigo Mendes Diaz
cImport e cImLoja serão ignorados
*/
Function DU400NFLtExp(cNFOri, cSerOri, cImport, cImLoja, cFatSeq, cPreemb, aNotas)
    Local aNfsItem := {}

    If cNFOri <> Nil .And. cSerOri <> Nil

        BeginSql Alias "NFSREM"

            Select
                EK6_CHVNFE, EK6_ITEM , EK6_QUANT , EK6_NF, EK6_SERIE, EK6_CLIENT , EK6_LOJACL
            From 
                %table:EK6% EK6
            Where
                EK6.%NotDel% 
                And EK6.EK6_FILIAL = %xFilial:EK6% 
                //MFR 22/10/2019 OSSME-3933
                  And EK6.EK6_NFSD = %exp:cNFOri% 
                  And EK6.EK6_SENFSD = %exp:cSerOri%
                  And EK6.EK6_SQFTSD = %exp:cFatSeq%
                  And EK6.EK6_PREEMB = %exp:cPreemb%
        EndSql

        While NFSREM->(!Eof())
            aAdd(aNfsItem, {NFSREM->EK6_CHVNFE, DU400CnvSeq(NFSREM->EK6_ITEM), NFSREM->EK6_QUANT , NFSREM->EK6_NF, NFSREM->EK6_SERIE, NFSREM->EK6_CLIENT , NFSREM->EK6_LOJACL  }, )
            If aScan(aNotas, NFSREM->EK6_CHVNFE) == 0
                aAdd(aNotas, {NFSREM->EK6_CHVNFE})
            EndIf
            NFSREM->(DbSkip())
        EndDo
        NFSREM->(DbCloseArea())
    EndIf

Return aNfsItem
/*
Funcao     : DU400SetVal
Objetivos  : Obtém os valores de peso, quantidade e quantidade estatística do item efetuando as conversões necessárias e retorna mensagem caso falte alguma conversão
Autor:     : Rodrigo Mendes Diaz
*/
Function DU400SetVal(cPreemb, aValItem, lValid)
Local aAreaEE9 := EE9->( GetArea())
Local aAreaEYY := EYY->( GetArea())
Local oErrors, cErro
Local cMensagem := "A DUE não poderá ser gerada, pois não foi possível efetuar as seguintes conversões de unidade de medida dos itens: " + ENTER
Local lErro := .F., cUnNCM, aDadosItem
Local aEES, nQtdEES
Local aEYY:= {}, aEWI:= {}, aEYU:= {}
Local nX, nY, nW
Local oRatPeso,oRatQtdNCM,oRatQtdEmb,oRatVlrtot,oRatVlrPri,oRatVlsCob,oRatQtdEYY,oRatQtdEYU,oRatTotEYU,oRatQtdEWI,oRatTotEWI
Private nPesoKG, nQtdNCM, nQtdEmb, nVlrTot, nVlrPri
Default lValid := .F.
Default aValItem := {}

EE9->(DbSetOrder(2))
EE9->(DbSeek(xFilial()+cPreemb))
While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+cPreemb)

    // realiza a validação das conversões de unidades de medidas
    aDadosItem  := {{EE9->EE9_UNIDAD,EE9->EE9_SLDINI}, {If(!Empty(EE9->EE9_UNPES), EE9->EE9_UNPES, If(!Empty(EEC->EEC_UNIDAD),EEC->EEC_UNIDAD,"KG")),EE9->EE9_PSLQTO}} 
    If (nPesoKG := EasyConvQt(EE9->EE9_COD_I,aDadosItem, "KG", .F., @oErrors)) == -1
        cErro := "Sequência Emb.: " + AllTrim(EE9->EE9_SEQEMB) + " De: " + AllTrim(If(!Empty(EE9->EE9_UNPES), EE9->EE9_UNPES, EE9->EE9_UNIDAD)) + " Para: KG"
        If !At(cErro, cMensagem) > 0
            cMensagem += cErro + ENTER
        EndIf
        lErro := .T.
    EndIf
    cUnNCM := BuscaNCM(EE9->EE9_POSIPI, "YD_UNID")
    If (nQtdNCM := EasyConvQt(EE9->EE9_COD_I, aDadosItem, cUnNCM, .F., @oErrors)) == -1
        cErro := "Sequência Emb.: " + AllTrim(EE9->EE9_SEQEMB) + " De: " + AllTrim(EE9->EE9_UNIDAD) + " Para: " + Alltrim(cUnNCM)
        If !At(cErro, cMensagem) > 0
            cMensagem += cErro + ENTER
        EndIf
        lErro := .T.
    EndIf

    /// caso não seja a chamada da função que validar o status da DUE faz o rateio dos itens
    if !lValid .and. !lErro
        nQtdEmb := EE9->EE9_SLDINI
        nVlrPri := EE9->EE9_PRCINC - If( EasyGParam("MV_AVG0119",,.F.) , EE9->EE9_DESCON , EE9->EE9_VLDESC ) // Preço Incoterm - ( Desconto por item  ou  Desconto Proc.(rateado por item) )
        nVlrTot := EE9->EE9_PRCTOT
        nVlsCob := EE9->EE9_VLSCOB

        aEES := {}
        nQtdEES := 0
        //RMD - 29/11/18 - Caso seja a DUE3, verifica quantos itens da nota fiscal (EES) referem-se ao item do embarque (EE9) e guarda a quantidade de cada um no array aEES
        If AvFlags("DU-E3")
            BeginSql Alias "ITEES"
                Select
                    EES_NRNF, EES_SERIE, EES_PEDIDO, EES_SEQUEN, EES_FATSEQ, EES_QTDE, EES_PREEMB
                From 
                    %table:EES% EES
                Where
                    EES.%NotDel%
                    And EES.EES_FILIAL = %xFilial:EES%
                    And EES.EES_PREEMB = %exp:EE9->EE9_PREEMB%
                    And EES.EES_NRNF = %exp:EE9->EE9_NF%
                    And EES.EES_SERIE = %exp:EE9->EE9_SERIE%
                    And EES.EES_PEDIDO = %exp:EE9->EE9_PEDIDO%
                    And EES.EES_SEQUEN = %exp:EE9->EE9_SEQUEN%
            EndSql

            // RELACIONA AS NOTAS DE REMSESSA PARA AGREGAR AS LINHAS DA EES
            aEYY := {}
            if EYY->( dbsetorder(1) , msseek( xFilial("EYY")+EE9->EE9_PREEMB+EE9->EE9_SEQEMB ))
                While EYY->( !Eof() ) .AND. xFilial("EYY")+EE9->EE9_PREEMB+EE9->EE9_SEQEMB == EYY->(EYY_FILIAL+EYY_PREEMB+EYY_SEQEMB)
                                                                                // 1 ,           2     , 3
                        aadd( aEYY , { EYY->EYY_NFENT+EYY->EYY_SERENT+EYY->EYY_D1ITEM, EYY->EYY_QUANT  , 0 } )
                    EYY->(dbskip())
                EndDo
            endif
            
            // RELACIONA O DRAWBACK DA LINHA DA EE9 AS LINHAS DA EES
            aEWI := {}
            aEYU := {}
            if empty(EE9->EE9_ATOCON) .and. EYU->( dbsetorder(1) , msseek( xFilial("EYU")+EE9->EE9_PREEMB+EE9->EE9_SEQEMB ))
                While EYU->( !Eof() ) .AND. xFilial("EYU")+EE9->EE9_PREEMB+EE9->EE9_SEQEMB == EYU->(EYU_FILIAL+EYU_PREEMB+EYU_SEQEMB)
                    if EWI->( dbsetorder(1) , msseek( xFilial("EWI")+EYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3) ) )
                        While EWI->( !Eof() ) .AND. EWI->(EWI_PREEMB+EWI_SEQEMB+EWI_TIPO+EWI_CNPJ+EWI_POSIPI+EWI_ATOCON+EWI_SEQED3) == EYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3)
                                                                              //   1   ,       2      ,       3       , 4 , 5 
                                aadd( aEWI , { EWI->(EWI_NF+EWI_SERIE) , EWI->EWI_QTD , EWI->EWI_VLNF , 0 , 0 } )
                        EWI->( dbskip() )
                        enddo
                    endif                                      //   1     ,       2      ,       3        , 4 , 5 ,       6
                    aadd( aEYU , { EYU->(EYU_ATOCON+EYU_SEQED3+EYU_SEQEMB), EYU->EYU_QTD , EYU->EYU_VALOR , 0 , 0 ,  aClone(aEWI)} )
                    aEWI := {}
                EYU->(dbskip())
                EndDo
            endif

            ITEES->(dbgotop())
            While ITEES->(!Eof())
                                                //           1        ,   2     , 3, 4, 5, 6, 7,      8      ,     9       , 10
                    aAdd(aEES, ITEES->({EES_NRNF+EES_SERIE+EES_FATSEQ , EES_QTDE, 0, 0, 0, 0, 0, aClone(aEYY), aClone(aEYU), 0 }))
                    nQtdEES += ITEES->EES_QTDE
                ITEES->(DbSkip())
            EndDo
            ITEES->(DbCloseArea())
        EndIf

        If EasyEntryPoint("EECDU400")
            ExecBlock("EECDU400",.f.,.f.,"APURA_VALORES_ITEM")
        EndIf

        //RMD - 29/11/18 - Caso seja a DUE3, rateia os valores obtidos pela quantidade de cada item de nota fiscal associado
        If Len(aEES) > 0
            oRatPeso   := EasyRateio():New(nPesoKG, nQtdEES, Len(aEES), 5)
            oRatQtdNCM := EasyRateio():New(nQtdNCM, nQtdEES, Len(aEES), 5)
            oRatQtdEmb := EasyRateio():New(nQtdEmb, nQtdEES, Len(aEES), 5)
            oRatVlrtot := EasyRateio():New(nVlrTot, nQtdEES, Len(aEES), AVSX3("EE9_PRCTOT",4))
            oRatVlrPri := EasyRateio():New(nVlrPri, nQtdEES, Len(aEES), AVSX3("EE9_PRCINC",4))
            oRatVlsCob := EasyRateio():New(nVlsCob, nQtdEES, Len(aEES), AVSX3("EE9_PRCTOT",4))
            aEval(aEES, {|x| x[3] := oRatPeso:GetItemRateio(x[2]), x[4] := oRatQtdNCM:GetItemRateio(x[2]), x[5] := oRatQtdEmb:GetItemRateio(x[2]) , x[6] := oRatVlrtot:GetItemRateio(x[2]) , x[7] := oRatVlrPri:GetItemRateio(x[2]) , x[10] := oRatVlScOB:GetItemRateio(x[6]) })
            
            aEYU := {}
            aEYY := {}
            For nX:= 1 to Len(aEES)
                // notas de remessa dos itens
                For nY:= 1 to Len(aEES[nX][8])
                    if nX == 1
                        oRatQtdEYY := EasyRateio():New( aEES[nX][8][nY][2] , nQtdEES , Len(aEES) , 5)
                        aadd( aEYY , oRatQtdEYY )
                    endif
                    aEES[nX][8][nY][3] := aEYY[nY]:GetItemRateio( aEES[nX][2] )
                Next

                For nY:= 1 to Len(aEES[nX][9])
                    if nX == 1 //len(aEYU) < Len(aEES[nX][9]) //len(aEYU) == 0 // nX == 1
                        oRatQtdEYU := EasyRateio():New( aEES[nX][9][nY][2] , nQtdEES , Len(aEES) , 5)
                        oRatTotEYU := EasyRateio():New( aEES[nX][9][nY][3] , nQtdEES , Len(aEES) , AVSX3("EE9_PRCTOT",4))
                        aadd( aEYU , { oRatQtdEYU , oRatTotEYU , {} } )
                    endif
                    
                    aEES[nX][9][nY][4] := aEYU[nY][1]:GetItemRateio( aEES[nX][2] )
                    aEES[nX][9][nY][5] := aEYU[nY][2]:GetItemRateio( aEES[nX][2] )
                    
                    For nW:= 1 to Len(aEES[nX][9][nY][6] )
                        if nX == 1 //len(aEWI) <  Len(aEES[nX][9][nY][6] )
                            oRatQtdEWI := EasyRateio():New( aEES[nX][9][nY][6][nW][2] , nQtdEES , Len(aEES) , 5)
                            oRatTotEWI := EasyRateio():New( aEES[nX][9][nY][6][nW][3] , nQtdEES , Len(aEES) , AVSX3("EE9_PRCTOT",4))
                            aadd( aEYU[nY][3] , { oRatQtdEWI,oRatTotEWI } )
                        endif
                        
                        aEES[nX][9][nY][6][nW][4] := aEYU[nY][3][nW][1]:GetItemRateio( aEES[nX][2] )
                        aEES[nX][9][nY][6][nW][5] := aEYU[nY][3][nW][2]:GetItemRateio( aEES[nX][2] )
                        
                    Next
                Next
            Next
        EndIf
                    //        1        ,   2    ,    3   ,    4   ,    5   ,    6   ,   7
        aAdd(aValItem, {EE9->EE9_SEQEMB, nPesoKG, nQtdNCM, nQtdEmb, nVlrTot, nVlrPri, aEES })
    EndIf
    EE9->(DbSkip())
EndDo

If lErro .And. Type("cMsgCpoDUE") == "C"
   cMsgCpoDUE += "[PROCESSO: '"+Alltrim(EEC->EEC_PREEMB)+"']"+ENTER+cMensagem
EndIf

RestArea(aAreaEE9)
RestArea(aAreaEYY)
Return !lErro

/*
Funcao     : DU400GetVal
Objetivos  : Retorna os valores de peso, quantidade e quantidade estatística do item já convertidos
Autor:     : Rodrigo Mendes Diaz
*/
Function DU400GetVal(cSeqEmb, cVal, cEES, cEYY, cEYU, cEWI ) //cNrNf, cSerie, cFatSeq)
Local nVal := 0
Local nPosIt, nPosNf, nPosEYY
Default cSeqEmb := ""
Default cVal := ""
Default cEES := ""
Default cEYY := ""
Default cEYU := ""
Default cEWI := ""

    If (nPosIt := aScan(aValItem, {|x| x[1] == cSeqEmb})) > 0
        //RMD - 29/11/18 - Caso seja a DUE3, busca as informações relacionadas ao item da nota fiscal (EES)
        If !Empty(cEES) .And. Len(aValItem[nPosIt][7]) > 0 .and. (nPosNf := aScan(aValItem[nPosIt][7], {|x| x[1] == cEES  })) > 0 //.And. x[2] == cSerie .And. x[3] == cFatSeq
            Do Case
                Case cVal == "PESO"
                    nVal := aValItem[nPosIt][7][nPosNf][3]
                Case cVal == "QUANTIDADE_NCM"
                    nVal := aValItem[nPosIt][7][nPosNf][4]
                Case cVal == "QUANTIDADE"
                    nVal := aValItem[nPosIt][7][nPosNf][5]
                Case cVal == "TOTAL"
                    nVal := aValItem[nPosIt][7][nPosNf][6]
                Case cVal == "INCOTERM"
                    nVal := aValItem[nPosIt][7][nPosNf][7]
                Case cVal == "COBERTURA"
                    nVal := aValItem[nPosIt][7][nPosNf][10]
            EndCase
            // caso mande a variável referente ao EYY ele considera o mesmo, no caso apenas para a quantidade
            if !Empty(cEYY) .And. Len(aValItem[nPosIt][7][nPosNf][8]) > 0 .and. (nPosEYY := aScan(aValItem[nPosIt][7][nPosNf][8], {|x| x[1] == cEYY })) > 0
                Do Case
                    Case cVal == "QUANTIDADE"
                        nVal := aValItem[nPosIt][7][nPosNf][8][nPosEYY][3]
                EndCase
            endif
            // caso mande a variável referente ao EYU ele considera o mesmo
            if !Empty(cEYU) .And. Len(aValItem[nPosIt][7][nPosNf][9]) > 0 .and. (nPosEYU := aScan(aValItem[nPosIt][7][nPosNf][9], {|x| x[1] == cEYU })) > 0
                if Empty(cEWI)
                    Do Case
                        Case cVal == "QUANTIDADE"
                            nVal := aValItem[nPosIt][7][nPosNf][9][nPosEYU][4]
                        Case cVal == "TOTAL"
                            nVal := aValItem[nPosIt][7][nPosNf][9][nPosEYU][5]
                    EndCase
                else
                    // caso mande a variável referente ao EWI ele considera o mesmo
                    if Len( aValItem[nPosIt][7][nPosNf][9][nPosEYU][6] ) > 0 .and. (nPosEWI := aScan(aValItem[nPosIt][7][nPosNf][9][nPosEYU][6], {|x| x[1] == cEWI })) > 0
                        Do Case
                            Case cVal == "QUANTIDADE"
                                nVal := aValItem[nPosIt][7][nPosNf][9][nPosEYU][6][nPosEWI][4]
                            Case cVal == "TOTAL"
                                nVal := aValItem[nPosIt][7][nPosNf][9][nPosEYU][6][nPosEWI][5]
                        EndCase
                    endif
                endif
            endif
        Else
            Do Case
                Case cVal == "PESO"
                    nVal := aValItem[nPosIt][2]
                Case cVal == "QUANTIDADE_NCM"
                    nVal := aValItem[nPosIt][3]
                Case cVal == "QUANTIDADE"
                    nVal := aValItem[nPosIt][4]
                Case cVal == "TOTAL"
                    nVal := aValItem[nPosIt][5]
                Case cVal == "INCOTERM"
                    nVal := aValItem[nPosIt][6]
            EndCase
        EndIf
    EndIf

Return nVal

/*
Funcao     : DU400ObsEmb
Objetivos  : Retorna o campo de informações complementares e permite customização
Autor:     : Rodrigo Mendes Diaz
*/
Function DU400ObsEmb()
Private cObsEmb := Alltrim(MSMM(EEC->EEC_CODOBP,AVSX3("EEC_OBSPED",3)))

    If EasyEntryPoint("EECDU400")
        ExecBlock("EECDU400",.f.,.f.,"OBS_EMBARQUE")
    EndIf

Return ConverteXML(cObsEmb)

/*
Funcao     : DU400DscPrd
Objetivos  : Retorna o campo de descrição do produto (cadastro) e permite customização
Autor:     : Rodrigo Mendes Diaz
*/
Function DU400DscPrd(cProduto)
Private cDescPrd := Alltrim(Posicione("SB1", 1, xFilial("SB1")+avkey(cProduto,"EE9_COD_I"), "B1_DESC"))

    If EasyEntryPoint("EECDU400")
        ExecBlock("EECDU400",.f.,.f.,"DESC_PRODUTO")
    EndIf

Return ConverteXML(cDescPrd)

/*
Funcao     : DU400DscItem
Objetivos  : Retorna o campo de descrição do item (embarque) e permite customização
Autor:     : Rodrigo Mendes Diaz
*/
Function DU400DscItem()
Private cDescItem := AllTrim(MEMOLINE(MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES",3)),60,1))

    If EasyEntryPoint("EECDU400")
        ExecBlock("EECDU400",.f.,.f.,"DESC_ITEM")
    EndIf

Return ConverteXML(cDescItem)

/*
Funcao     : DU400CnvSeq
Objetivos  : Converte a sequência do item na nota de caractere (soma1) para numérico
Autor:     : Rodrigo Mendes Diaz
*/
Function DU400CnvSeq(cSeq)
Local nVal := 0
Local nLenSeq := Len(AllTrim(cSeq)), nPosSeq, nPos
Local cSeqCalc := StrZero(0, Len(Alltrim(cSeq)))
Static aCnvSeq := {}

    If (nPosSeq := aScan(aCnvSeq, {|x| x[1] == nLenSeq })) == 0
        aAdd(aCnvSeq, {nLenSeq, {}})
        nPosSeq := Len(aCnvSeq)
    EndIf

    If Len(aCnvSeq[nPosSeq][2]) > 0
        cSeqCalc := aCnvSeq[nPosSeq][2][Len(aCnvSeq[nPosSeq][2])]
    EndIf

    While (nPos := aScan(aCnvSeq[nPosSeq][2], AllTrim(cSeq))) == 0
        aAdd(aCnvSeq[nPosSeq][2], cSeqCalc := Soma1(cSeqCalc))
    EndDo

Return Alltrim(Str(nPos))

/*
Funcao     : DU400TpAC
Objetivos  : Retorna o código DUE para o tipo do Ato Concessório
Autor:     : Rodrigo Mendes Diaz
*/
Function DU400TpAC(cTpEDC)
Local cTpDUE := "AC"

Do Case
    Case cTpEDC == "A"
        cTpDUE := "AC"
    Case cTpEDC == "B"
        cTpDUE := "DSG"
    Case cTpEDC == "C"
        cTpDUE := "DSI"
    Case cTpEDC == "D"
        cTpDUE := "DSIG"
End Case

Return cTpDUE

/*
Funcao     : DU400HasJus()
Objetivos  : Verifica se existe justificativa para algum dos itens da DUE
Autor:     : Rodrigo Mendes Diaz
*/
Function DU400HasJus(cPreemb,cSeq)
Local lRet      := .F.
Default cSeq    := ""

if cSeq == ""
    If EE9->(FieldPos("EE9_JUSDUE")) > 0
        BeginSql Alias "JUSDUE"
            Select
                EE9_JUSDUE
            From 
                %table:EE9% EE9
            Where
                EE9.%NotDel%
                And EE9.EE9_FILIAL = %xFilial:EE9%
                And EE9.EE9_PREEMB = %exp:cPreemb%
                And EE9.EE9_JUSDUE <> ''
        EndSql
    EndIf
else
    If SELECT("EK2") > 0
       BeginSql Alias "JUSDUE"
           Select
               EK2_JUSDUE
           From 
               %table:EK2% EK2
           Where
               EK2.%NotDel%
               And EK2.EK2_FILIAL = %xFilial:EK2%
               And EK2.EK2_PROCES = %exp:cPreemb%
               And EK2.EK2_NUMSEQ = %exp:cSeq%
               And EK2.EK2_JUSDUE <> ''
       EndSql
    EndIf
endif

If SELECT("JUSDUE") > 0
   If JUSDUE->(!Eof() .And. !Bof())
      lRet := .T.
   EndIf
   JUSDUE->(DbCloseArea())
EndIf

Return lRet

/*
Funcao     : DU400GetAtt
Objetivos  : Retorna o atributo para o destaque de uma NCM
Autor:     : Rodrigo Mendes Diaz
*/
Function DU400GetAtt(cNCM, cDestaque)
Local cAtt := "", nPos

if ! ismemvar("aAtributos")
 aAtributos := {}
endif

If Len(aAtributos) == 0
    aAdd(aAtributos, {"01012100", "ATT_1", "01"})
    aAdd(aAtributos, {"01012100", "ATT_1", "99"})
    aAdd(aAtributos, {"01012900", "ATT_2", "01"})
    aAdd(aAtributos, {"01012900", "ATT_2", "99"})
    aAdd(aAtributos, {"01013000", "ATT_3", "01"})
    aAdd(aAtributos, {"01013000", "ATT_3", "99"})
    aAdd(aAtributos, {"01023110", "ATT_4", "01"})
    aAdd(aAtributos, {"01023110", "ATT_4", "99"})
    aAdd(aAtributos, {"01023190", "ATT_5", "01"})
    aAdd(aAtributos, {"01023190", "ATT_5", "99"})
    aAdd(aAtributos, {"01023911", "ATT_6", "01"})
    aAdd(aAtributos, {"01023911", "ATT_6", "99"})
    aAdd(aAtributos, {"01023919", "ATT_7", "01"})
    aAdd(aAtributos, {"01023919", "ATT_7", "99"})
    aAdd(aAtributos, {"01023990", "ATT_8", "01"})
    aAdd(aAtributos, {"01023990", "ATT_8", "99"})
    aAdd(aAtributos, {"01029000", "ATT_9", "01"})
    aAdd(aAtributos, {"01029000", "ATT_9", "99"})
    aAdd(aAtributos, {"01031000", "ATT_10", "01"})
    aAdd(aAtributos, {"01031000", "ATT_10", "99"})
    aAdd(aAtributos, {"01039100", "ATT_11", "01"})
    aAdd(aAtributos, {"01039100", "ATT_11", "99"})
    aAdd(aAtributos, {"01039200", "ATT_12", "01"})
    aAdd(aAtributos, {"01039200", "ATT_12", "99"})
    aAdd(aAtributos, {"01041011", "ATT_13", "01"})
    aAdd(aAtributos, {"01041011", "ATT_13", "99"})
    aAdd(aAtributos, {"01041019", "ATT_14", "01"})
    aAdd(aAtributos, {"01041019", "ATT_14", "99"})
    aAdd(aAtributos, {"01042010", "ATT_15", "01"})
    aAdd(aAtributos, {"01042010", "ATT_15", "99"})
    aAdd(aAtributos, {"01042090", "ATT_16", "01"})
    aAdd(aAtributos, {"01042090", "ATT_16", "99"})
    aAdd(aAtributos, {"01051300", "ATT_17", "01"})
    aAdd(aAtributos, {"01051300", "ATT_17", "99"})
    aAdd(aAtributos, {"01051400", "ATT_18", "01"})
    aAdd(aAtributos, {"01051400", "ATT_18", "99"})
    aAdd(aAtributos, {"01059900", "ATT_19", "01"})
    aAdd(aAtributos, {"01059900", "ATT_19", "99"})
    aAdd(aAtributos, {"01061400", "ATT_20", "01"})
    aAdd(aAtributos, {"01061400", "ATT_20", "99"})
    aAdd(aAtributos, {"01061900", "ATT_21", "99"})
    aAdd(aAtributos, {"01061900", "ATT_21", "01"})
    aAdd(aAtributos, {"01063200", "ATT_22", "01"})
    aAdd(aAtributos, {"01063200", "ATT_22", "99"})
    aAdd(aAtributos, {"01063390", "ATT_23", "01"})
    aAdd(aAtributos, {"01063390", "ATT_23", "99"})
    aAdd(aAtributos, {"01063900", "ATT_24", "01"})
    aAdd(aAtributos, {"01063900", "ATT_24", "99"})
    aAdd(aAtributos, {"01064100", "ATT_25", "01"})
    aAdd(aAtributos, {"01064100", "ATT_25", "99"})
    aAdd(aAtributos, {"01064900", "ATT_26", "01"})
    aAdd(aAtributos, {"01064900", "ATT_26", "99"})
    aAdd(aAtributos, {"01069000", "ATT_27", "01"})
    aAdd(aAtributos, {"01069000", "ATT_27", "99"})
    aAdd(aAtributos, {"02013000", "ATT_28", "09"})
    aAdd(aAtributos, {"02023000", "ATT_29", "09"})
    aAdd(aAtributos, {"02081000", "ATT_30", "01"})
    aAdd(aAtributos, {"02081000", "ATT_30", "99"})
    aAdd(aAtributos, {"02109911", "ATT_2095", "03"})
    aAdd(aAtributos, {"02109911", "ATT_2095", "10"})
    aAdd(aAtributos, {"02109911", "ATT_2095", "11"})
    aAdd(aAtributos, {"02109911", "ATT_2095", "99"})
    aAdd(aAtributos, {"02109919", "ATT_2095", "03"})
    aAdd(aAtributos, {"02109919", "ATT_2095", "10"})
    aAdd(aAtributos, {"02109919", "ATT_2095", "11"})
    aAdd(aAtributos, {"02109919", "ATT_2095", "99"})
    aAdd(aAtributos, {"02109920", "ATT_2095", "03"})
    aAdd(aAtributos, {"02109920", "ATT_2095", "10"})
    aAdd(aAtributos, {"02109920", "ATT_2095", "11"})
    aAdd(aAtributos, {"02109920", "ATT_2095", "99"})
    aAdd(aAtributos, {"02109930", "ATT_2095", "03"})
    aAdd(aAtributos, {"02109930", "ATT_2095", "10"})
    aAdd(aAtributos, {"02109930", "ATT_2095", "11"})
    aAdd(aAtributos, {"02109930", "ATT_2095", "99"})
    aAdd(aAtributos, {"02109940", "ATT_2095", "03"})
    aAdd(aAtributos, {"02109940", "ATT_2095", "10"})
    aAdd(aAtributos, {"02109940", "ATT_2095", "11"})
    aAdd(aAtributos, {"02109940", "ATT_2095", "99"})
    aAdd(aAtributos, {"02109990", "ATT_2095", "03"})
    aAdd(aAtributos, {"02109990", "ATT_2095", "10"})
    aAdd(aAtributos, {"02109990", "ATT_2095", "11"})
    aAdd(aAtributos, {"02109990", "ATT_2095", "99"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "999"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "717"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "549"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "242"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "226"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "102"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "75"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "467"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "44"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "636"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "554"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "678"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "338"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "92"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "675"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "618"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "320"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "207"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "177"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "623"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "61"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "650"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "375"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "252"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "709"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "473"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "175"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "42"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "570"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "538"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "1"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "700"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "27"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "295"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "361"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "70"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "357"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "716"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "122"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "118"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "51"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "459"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "219"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "342"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "365"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "2"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "418"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "34"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "713"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "710"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "677"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "640"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "519"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "402"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "300"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "602"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "505"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "626"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "127"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "276"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "724"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "468"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "684"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "707"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "591"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "680"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "526"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "564"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "439"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "322"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "690"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "264"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "288"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "97"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "148"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "315"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "91"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "94"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "498"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "553"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "390"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "404"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "628"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "292"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "317"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "637"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "621"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "274"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "706"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "358"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "619"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "65"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "211"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "481"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "382"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "662"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "620"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "147"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "599"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "124"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "475"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "654"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "573"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "56"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "214"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "461"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "407"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "671"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "381"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "160"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "685"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "105"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "359"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "327"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "708"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "562"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "134"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "251"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "201"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "36"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "17"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "248"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "341"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "607"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "311"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "179"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "192"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "606"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "57"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "433"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "273"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "698"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "74"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "270"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "633"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "656"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "24"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "396"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "215"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "609"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "669"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "101"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "603"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "43"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "32"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "584"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "403"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "3"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "191"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "183"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "401"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "493"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "178"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "416"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "586"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "80"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "186"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "377"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "373"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "448"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "647"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "443"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "531"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "506"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "285"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "422"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "617"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "190"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "76"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "230"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "546"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "26"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "243"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "400"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "142"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "593"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "552"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "517"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "457"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "587"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "495"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "244"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "54"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "213"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "307"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "556"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "227"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "83"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "509"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "343"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "340"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "297"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "686"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "426"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "695"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "176"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "718"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "389"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "126"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "704"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "613"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "558"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "398"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "104"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "673"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "25"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "536"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "408"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "693"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "149"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "571"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "163"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "15"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "263"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "581"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "496"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "456"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "648"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "486"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "168"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "572"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "143"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "445"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "347"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "196"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "123"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "255"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "277"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "258"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "474"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "287"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "49"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "425"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "634"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "567"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "239"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "280"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "362"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "515"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "23"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "508"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "316"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "423"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "72"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "384"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "319"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "533"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "427"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "299"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "278"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "30"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "643"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "106"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "534"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "444"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "516"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "14"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "489"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "663"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "612"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "182"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "66"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "712"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "447"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "197"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "10"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "366"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "692"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "631"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "608"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "604"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "289"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "171"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "522"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "157"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "200"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "40"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "290"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "155"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "574"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "174"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "535"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "346"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "687"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "217"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "555"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "229"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "206"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "721"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "59"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "325"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "646"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "21"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "589"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "28"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "89"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "667"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "339"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "329"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "298"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "561"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "259"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "482"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "100"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "48"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "454"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "236"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "189"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "293"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "566"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "432"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "419"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "328"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "218"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "576"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "428"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "405"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "323"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "391"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "332"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "188"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "144"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "374"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "689"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "220"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "166"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "614"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "638"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "551"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "412"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "430"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "518"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "93"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "337"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "670"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "395"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "198"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "113"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "245"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "442"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "86"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "488"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "694"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "451"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "172"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "501"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "446"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "181"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "691"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "387"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "305"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "699"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "410"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "331"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "187"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "304"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "665"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "154"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "63"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "112"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "715"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "529"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "345"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "279"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "199"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "569"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "476"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "333"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "271"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "429"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "151"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "275"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "487"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "438"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "688"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "676"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "624"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "318"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "714"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "399"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "52"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "12"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "583"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "547"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "71"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "500"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "159"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "120"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "491"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "622"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "321"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "548"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "651"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "87"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "435"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "150"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "250"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "502"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "520"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "136"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "310"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "642"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "193"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "588"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "541"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "413"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "301"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "262"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "19"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "484"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "368"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "107"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "205"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "165"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "115"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "590"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "568"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "82"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "610"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "530"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "635"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "544"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "477"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "434"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "153"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "664"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "152"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "68"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "254"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "560"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "629"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "35"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "645"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "132"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "472"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "585"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "511"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "550"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "464"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "224"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "453"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "658"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "421"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "527"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "463"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "194"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "683"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "67"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "5"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "302"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "525"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "233"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "367"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "494"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "666"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "565"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "257"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "417"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "20"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "641"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "524"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "55"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "173"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "267"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "184"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "436"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "125"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "703"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "424"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "309"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "378"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "138"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "212"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "73"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "595"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "351"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "47"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "632"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "109"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "414"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "232"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "701"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "575"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "723"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "462"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "674"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "349"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "247"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "169"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "167"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "592"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "45"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "284"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "441"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "261"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "228"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "4"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "231"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "210"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "393"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "237"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "579"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "577"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "470"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "627"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "145"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "528"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "204"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "286"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "111"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "655"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "545"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "77"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "208"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "344"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "209"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "492"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "392"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "406"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "485"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "450"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "84"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "563"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "291"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "269"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "139"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "108"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "630"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "326"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "503"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "605"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "639"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "241"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "469"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "46"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "96"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "348"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "50"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "355"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "95"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "490"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "660"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "223"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "697"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "240"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "314"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "260"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "265"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "679"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "62"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "672"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "363"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "514"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "335"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "397"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "137"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "719"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "131"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "180"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "283"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "386"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "170"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "88"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "582"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "119"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "388"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "437"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "11"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "499"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "559"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "537"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "356"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "41"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "324"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "657"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "79"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "411"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "543"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "129"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "352"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "60"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "312"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "29"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "78"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "294"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "268"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "449"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "415"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "336"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "121"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "594"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "597"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "303"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "146"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "578"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "512"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "16"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "8"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "161"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "234"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "103"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "596"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "222"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "253"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "350"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "156"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "117"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "281"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "598"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "625"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "644"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "478"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "376"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "221"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "256"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "90"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "216"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "580"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "313"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "383"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "306"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "130"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "272"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "682"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "238"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "158"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "85"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "330"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "480"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "371"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "98"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "380"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "334"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "653"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "81"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "354"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "141"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "725"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "600"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "466"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "53"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "513"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "440"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "471"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "420"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "13"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "37"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "649"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "9"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "249"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "202"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "128"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "539"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "69"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "64"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "110"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "18"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "705"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "696"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "540"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "99"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "668"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "203"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "611"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "479"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "364"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "38"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "266"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "114"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "616"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "661"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "225"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "460"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "497"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "659"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "116"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "722"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "615"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "360"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "140"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "455"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "504"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "409"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "39"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "431"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "370"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "353"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "164"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "458"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "521"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "31"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "7"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "58"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "22"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "507"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "483"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "510"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "162"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "379"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "369"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "185"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "296"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "135"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "601"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "557"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "282"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "246"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "681"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "652"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "385"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "702"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "235"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "542"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "372"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "465"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "394"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "452"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "711"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "308"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "720"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "133"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "33"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "6"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "195"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "523"})
    aAdd(aAtributos, {"03011190", "ATT_1530", "532"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "999"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "130"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "22"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "4"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "67"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "7"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "21"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "9"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "93"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "44"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "136"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "36"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "43"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "41"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "8"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "82"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "42"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "6"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "39"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "137"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "117"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "111"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "47"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "107"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "79"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "53"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "92"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "116"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "100"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "34"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "113"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "57"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "40"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "5"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "87"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "56"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "78"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "109"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "134"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "52"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "101"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "81"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "66"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "105"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "88"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "120"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "95"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "83"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "45"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "31"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "132"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "61"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "85"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "128"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "16"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "125"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "131"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "71"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "37"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "74"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "98"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "2"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "122"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "86"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "97"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "25"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "121"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "33"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "26"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "73"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "13"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "76"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "58"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "91"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "106"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "84"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "89"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "133"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "55"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "62"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "59"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "126"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "69"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "10"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "112"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "115"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "60"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "27"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "65"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "38"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "96"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "14"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "119"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "12"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "23"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "28"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "102"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "17"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "1"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "75"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "50"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "64"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "48"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "35"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "18"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "19"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "94"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "77"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "72"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "80"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "32"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "110"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "108"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "54"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "129"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "118"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "20"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "114"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "51"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "11"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "49"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "124"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "104"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "135"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "46"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "103"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "90"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "99"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "29"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "3"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "123"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "24"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "68"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "15"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "70"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "127"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "30"})
    aAdd(aAtributos, {"03011900", "ATT_1526", "63"})
    aAdd(aAtributos, {"03024990", "ATT_38", "01"})
    aAdd(aAtributos, {"03024990", "ATT_38", "99"})
    aAdd(aAtributos, {"03027300", "ATT_39", "01"})
    aAdd(aAtributos, {"03027300", "ATT_39", "99"})
    aAdd(aAtributos, {"03028100", "ATT_40", "01"})
    aAdd(aAtributos, {"03028100", "ATT_40", "99"})
    aAdd(aAtributos, {"03028200", "ATT_41", "01"})
    aAdd(aAtributos, {"03028200", "ATT_41", "99"})
    aAdd(aAtributos, {"03028990", "ATT_42", "01"})
    aAdd(aAtributos, {"03028990", "ATT_42", "99"})
    aAdd(aAtributos, {"03029100", "ATT_43", "01"})
    aAdd(aAtributos, {"03029100", "ATT_43", "99"})
    aAdd(aAtributos, {"03029200", "ATT_44", "99"})
    aAdd(aAtributos, {"03029200", "ATT_44", "01"})
    aAdd(aAtributos, {"03029900", "ATT_45", "01"})
    aAdd(aAtributos, {"03029900", "ATT_45", "02"})
    aAdd(aAtributos, {"03029900", "ATT_45", "03"})
    aAdd(aAtributos, {"03029900", "ATT_45", "99"})
    aAdd(aAtributos, {"03032500", "ATT_46", "01"})
    aAdd(aAtributos, {"03032500", "ATT_46", "99"})
    aAdd(aAtributos, {"03035990", "ATT_48", "01"})
    aAdd(aAtributos, {"03035990", "ATT_48", "99"})
    aAdd(aAtributos, {"03038190", "ATT_49", "01"})
    aAdd(aAtributos, {"03038190", "ATT_49", "99"})
    aAdd(aAtributos, {"03038200", "ATT_50", "01"})
    aAdd(aAtributos, {"03038200", "ATT_50", "99"})
    aAdd(aAtributos, {"03038990", "ATT_51", "01"})
    aAdd(aAtributos, {"03038990", "ATT_51", "99"})
    aAdd(aAtributos, {"03039100", "ATT_52", "01"})
    aAdd(aAtributos, {"03039100", "ATT_52", "99"})
    aAdd(aAtributos, {"03039200", "ATT_53", "01"})
    aAdd(aAtributos, {"03039200", "ATT_53", "99"})
    aAdd(aAtributos, {"03039990", "ATT_54", "01"})
    aAdd(aAtributos, {"03039990", "ATT_54", "02"})
    aAdd(aAtributos, {"03039990", "ATT_54", "99"})
    aAdd(aAtributos, {"03043900", "ATT_55", "01"})
    aAdd(aAtributos, {"03043900", "ATT_55", "99"})
    aAdd(aAtributos, {"03044700", "ATT_56", "01"})
    aAdd(aAtributos, {"03044700", "ATT_56", "99"})
    aAdd(aAtributos, {"03044800", "ATT_57", "01"})
    aAdd(aAtributos, {"03044800", "ATT_57", "99"})
    aAdd(aAtributos, {"03044990", "ATT_58", "01"})
    aAdd(aAtributos, {"03044990", "ATT_58", "99"})
    aAdd(aAtributos, {"03045100", "ATT_59", "01"})
    aAdd(aAtributos, {"03045100", "ATT_59", "99"})
    aAdd(aAtributos, {"03045600", "ATT_60", "01"})
    aAdd(aAtributos, {"03045600", "ATT_60", "99"})
    aAdd(aAtributos, {"03045700", "ATT_61", "01"})
    aAdd(aAtributos, {"03045700", "ATT_61", "99"})
    aAdd(aAtributos, {"03045900", "ATT_62", "01"})
    aAdd(aAtributos, {"03045900", "ATT_62", "99"})
    aAdd(aAtributos, {"03046900", "ATT_63", "01"})
    aAdd(aAtributos, {"03046900", "ATT_63", "99"})
    aAdd(aAtributos, {"03048890", "ATT_64", "01"})
    aAdd(aAtributos, {"03048890", "ATT_64", "99"})
    aAdd(aAtributos, {"03048990", "ATT_65", "01"})
    aAdd(aAtributos, {"03048990", "ATT_65", "99"})
    aAdd(aAtributos, {"03049300", "ATT_66", "01"})
    aAdd(aAtributos, {"03049300", "ATT_66", "99"})
    aAdd(aAtributos, {"03049600", "ATT_67", "01"})
    aAdd(aAtributos, {"03049600", "ATT_67", "99"})
    aAdd(aAtributos, {"03049700", "ATT_68", "01"})
    aAdd(aAtributos, {"03049700", "ATT_68", "99"})
    aAdd(aAtributos, {"03049900", "ATT_69", "01"})
    aAdd(aAtributos, {"03049900", "ATT_69", "99"})
    aAdd(aAtributos, {"03051000", "ATT_70", "99"})
    aAdd(aAtributos, {"03051000", "ATT_70", "01"})
    aAdd(aAtributos, {"03052000", "ATT_71", "01"})
    aAdd(aAtributos, {"03052000", "ATT_71", "99"})
    aAdd(aAtributos, {"03053100", "ATT_72", "01"})
    aAdd(aAtributos, {"03053100", "ATT_72", "99"})
    aAdd(aAtributos, {"03053900", "ATT_73", "01"})
    aAdd(aAtributos, {"03053900", "ATT_73", "99"})
    aAdd(aAtributos, {"03054400", "ATT_74", "01"})
    aAdd(aAtributos, {"03054400", "ATT_74", "99"})
    aAdd(aAtributos, {"03054990", "ATT_75", "01"})
    aAdd(aAtributos, {"03054990", "ATT_75", "99"})
    aAdd(aAtributos, {"03055200", "ATT_76", "01"})
    aAdd(aAtributos, {"03055200", "ATT_76", "99"})
    aAdd(aAtributos, {"03055390", "ATT_77", "01"})
    aAdd(aAtributos, {"03055390", "ATT_77", "99"})
    aAdd(aAtributos, {"03055400", "ATT_78", "01"})
    aAdd(aAtributos, {"03055400", "ATT_78", "99"})
    aAdd(aAtributos, {"03055900", "ATT_79", "01"})
    aAdd(aAtributos, {"03055900", "ATT_79", "99"})
    aAdd(aAtributos, {"03056400", "ATT_80", "01"})
    aAdd(aAtributos, {"03056400", "ATT_80", "99"})
    aAdd(aAtributos, {"03056990", "ATT_81", "01"})
    aAdd(aAtributos, {"03056990", "ATT_81", "99"})
    aAdd(aAtributos, {"03057100", "ATT_82", "01"})
    aAdd(aAtributos, {"03057100", "ATT_82", "99"})
    aAdd(aAtributos, {"03057200", "ATT_83", "01"})
    aAdd(aAtributos, {"03057200", "ATT_83", "99"})
    aAdd(aAtributos, {"03057900", "ATT_84", "01"})
    aAdd(aAtributos, {"03057900", "ATT_84", "99"})
    aAdd(aAtributos, {"03089000", "ATT_102", "01"})
    aAdd(aAtributos, {"03089000", "ATT_102", "99"})
    aAdd(aAtributos, {"04071900", "ATT_103", "01"})
    aAdd(aAtributos, {"04071900", "ATT_103", "99"})
    aAdd(aAtributos, {"05021090", "ATT_107", "01"})
    aAdd(aAtributos, {"05021090", "ATT_107", "99"})
    aAdd(aAtributos, {"05029010", "ATT_108", "01"})
    aAdd(aAtributos, {"05029010", "ATT_108", "99"})
    aAdd(aAtributos, {"05029020", "ATT_109", "01"})
    aAdd(aAtributos, {"05029020", "ATT_109", "99"})
    aAdd(aAtributos, {"05040019", "ATT_110", "01"})
    aAdd(aAtributos, {"05040019", "ATT_110", "99"})
    aAdd(aAtributos, {"05040090", "ATT_111", "01"})
    aAdd(aAtributos, {"05040090", "ATT_111", "99"})
    aAdd(aAtributos, {"05061000", "ATT_114", "01"})
    aAdd(aAtributos, {"05061000", "ATT_114", "99"})
    aAdd(aAtributos, {"05069000", "ATT_115", "01"})
    aAdd(aAtributos, {"05069000", "ATT_115", "99"})
    aAdd(aAtributos, {"05080000", "ATT_117", "01"})
    aAdd(aAtributos, {"05080000", "ATT_117", "99"})
    aAdd(aAtributos, {"05100090", "ATT_118", "01"})
    aAdd(aAtributos, {"05100090", "ATT_118", "99"})
    aAdd(aAtributos, {"05119110", "ATT_119", "01"})
    aAdd(aAtributos, {"05119110", "ATT_119", "99"})
    aAdd(aAtributos, {"05119190", "ATT_120", "01"})
    aAdd(aAtributos, {"05119190", "ATT_120", "99"})
    aAdd(aAtributos, {"05119991", "ATT_124", "01"})
    aAdd(aAtributos, {"05119991", "ATT_124", "99"})
    aAdd(aAtributos, {"05119999", "ATT_125", "01"})
    aAdd(aAtributos, {"05119999", "ATT_125", "99"})
    aAdd(aAtributos, {"06011000", "ATT_126", "01"})
    aAdd(aAtributos, {"06011000", "ATT_126", "99"})
    aAdd(aAtributos, {"06029021", "ATT_133", "01"})
    aAdd(aAtributos, {"06029021", "ATT_133", "99"})
    aAdd(aAtributos, {"06029029", "ATT_134", "01"})
    aAdd(aAtributos, {"06029029", "ATT_134", "99"})
    aAdd(aAtributos, {"06029089", "ATT_138", "01"})
    aAdd(aAtributos, {"06029089", "ATT_138", "06"})
    aAdd(aAtributos, {"06029089", "ATT_138", "03"})
    aAdd(aAtributos, {"06029089", "ATT_138", "04"})
    aAdd(aAtributos, {"06029089", "ATT_138", "05"})
    aAdd(aAtributos, {"06029089", "ATT_138", "99"})
    aAdd(aAtributos, {"06029089", "ATT_138", "02"})
    aAdd(aAtributos, {"06029090", "ATT_139", "01"})
    aAdd(aAtributos, {"06029090", "ATT_139", "04"})
    aAdd(aAtributos, {"06029090", "ATT_139", "99"})
    aAdd(aAtributos, {"09012100", "ATT_3039", "1"})
    aAdd(aAtributos, {"09012100", "ATT_3039", "2"})
    aAdd(aAtributos, {"09012100", "ATT_3039", "99"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "a"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "b"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "c"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "d"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "e"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "f"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "g"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "h"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "i"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "j"})
    aAdd(aAtributos, {"09012100", "ATT_3060", "k"})
    aAdd(aAtributos, {"09012200", "ATT_3039", "1"})
    aAdd(aAtributos, {"09012200", "ATT_3039", "2"})
    aAdd(aAtributos, {"09012200", "ATT_3039", "99"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "a"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "b"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "c"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "d"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "e"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "f"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "g"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "h"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "i"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "j"})
    aAdd(aAtributos, {"09012200", "ATT_3060", "k"})
    aAdd(aAtributos, {"12079110", "ATT_1416", "01"})
    aAdd(aAtributos, {"12079110", "ATT_1416", "02"})
    aAdd(aAtributos, {"12079190", "ATT_1416", "01"})
    aAdd(aAtributos, {"12079190", "ATT_1416", "02"})
    aAdd(aAtributos, {"12079910", "ATT_1416", "01"})
    aAdd(aAtributos, {"12079910", "ATT_1416", "02"})
    aAdd(aAtributos, {"12113000", "ATT_1416", "01"})
    aAdd(aAtributos, {"12113000", "ATT_1416", "02"})
    aAdd(aAtributos, {"12114000", "ATT_1416", "01"})
    aAdd(aAtributos, {"12114000", "ATT_1416", "02"})
    aAdd(aAtributos, {"12115000", "ATT_160", "01"})
    aAdd(aAtributos, {"12115000", "ATT_160", "99"})
    aAdd(aAtributos, {"12115000", "ATT_160", "03"})
    aAdd(aAtributos, {"12115000", "ATT_160", "04"})
    aAdd(aAtributos, {"12115000", "ATT_160", "05"})
    aAdd(aAtributos, {"12115000", "ATT_160", "07"})
    aAdd(aAtributos, {"12115000", "ATT_160", "08"})
    aAdd(aAtributos, {"12115000", "ATT_160", "09"})
    aAdd(aAtributos, {"12115000", "ATT_160", "10"})
    aAdd(aAtributos, {"12115000", "ATT_160", "11"})
    aAdd(aAtributos, {"12115000", "ATT_160", "12"})
    aAdd(aAtributos, {"12115000", "ATT_160", "13"})
    aAdd(aAtributos, {"12115000", "ATT_160", "02"})
    aAdd(aAtributos, {"12119090", "ATT_161", "01"})
    aAdd(aAtributos, {"12119090", "ATT_161", "99"})
    aAdd(aAtributos, {"12119090", "ATT_161", "03"})
    aAdd(aAtributos, {"12119090", "ATT_161", "04"})
    aAdd(aAtributos, {"12119090", "ATT_161", "05"})
    aAdd(aAtributos, {"12119090", "ATT_161", "06"})
    aAdd(aAtributos, {"12119090", "ATT_161", "07"})
    aAdd(aAtributos, {"12119090", "ATT_161", "08"})
    aAdd(aAtributos, {"12119090", "ATT_161", "09"})
    aAdd(aAtributos, {"12119090", "ATT_161", "10"})
    aAdd(aAtributos, {"12119090", "ATT_161", "11"})
    aAdd(aAtributos, {"12119090", "ATT_161", "12"})
    aAdd(aAtributos, {"12119090", "ATT_161", "02"})
    aAdd(aAtributos, {"13019090", "ATT_162", "01"})
    aAdd(aAtributos, {"13019090", "ATT_162", "99"})
    aAdd(aAtributos, {"13019090", "ATT_162", "02"})
    aAdd(aAtributos, {"13021110", "ATT_1416", "01"})
    aAdd(aAtributos, {"13021110", "ATT_1416", "02"})
    aAdd(aAtributos, {"13021190", "ATT_163", "01"})
    aAdd(aAtributos, {"13021190", "ATT_163", "99"})
    aAdd(aAtributos, {"13021190", "ATT_1416", "02"})
    aAdd(aAtributos, {"13021400", "ATT_164", "01"})
    aAdd(aAtributos, {"13021400", "ATT_164", "02"})
    aAdd(aAtributos, {"13021400", "ATT_164", "03"})
    aAdd(aAtributos, {"13021400", "ATT_164", "99"})
    aAdd(aAtributos, {"13021999", "ATT_165", "01"})
    aAdd(aAtributos, {"13021999", "ATT_165", "02"})
    aAdd(aAtributos, {"13021999", "ATT_165", "03"})
    aAdd(aAtributos, {"13021999", "ATT_165", "99"})
    aAdd(aAtributos, {"15159090", "ATT_167", "01"})
    aAdd(aAtributos, {"15159090", "ATT_167", "99"})
    aAdd(aAtributos, {"15159090", "ATT_1416", "02"})
    aAdd(aAtributos, {"15211000", "ATT_168", "01"})
    aAdd(aAtributos, {"15211000", "ATT_168", "02"})
    aAdd(aAtributos, {"15211000", "ATT_168", "99"})
    aAdd(aAtributos, {"16023100", "ATT_169", "10"})
    aAdd(aAtributos, {"16023100", "ATT_169", "11"})
    aAdd(aAtributos, {"16023100", "ATT_169", "01"})
    aAdd(aAtributos, {"16023210", "ATT_170", "10"})
    aAdd(aAtributos, {"16023210", "ATT_170", "11"})
    aAdd(aAtributos, {"16023210", "ATT_170", "01"})
    aAdd(aAtributos, {"16023220", "ATT_171", "10"})
    aAdd(aAtributos, {"16023220", "ATT_171", "11"})
    aAdd(aAtributos, {"16023220", "ATT_171", "01"})
    aAdd(aAtributos, {"16023230", "ATT_172", "10"})
    aAdd(aAtributos, {"16023230", "ATT_172", "11"})
    aAdd(aAtributos, {"16023230", "ATT_172", "01"})
    aAdd(aAtributos, {"16023290", "ATT_173", "10"})
    aAdd(aAtributos, {"16023290", "ATT_173", "11"})
    aAdd(aAtributos, {"16023290", "ATT_173", "01"})
    aAdd(aAtributos, {"16041800", "ATT_174", "01"})
    aAdd(aAtributos, {"16041800", "ATT_174", "99"})
    aAdd(aAtributos, {"16041900", "ATT_175", "01"})
    aAdd(aAtributos, {"16041900", "ATT_175", "99"})
    aAdd(aAtributos, {"16042090", "ATT_176", "01"})
    aAdd(aAtributos, {"16042090", "ATT_176", "99"})
    aAdd(aAtributos, {"21011190", "ATT_3039", "1"})
    aAdd(aAtributos, {"21011190", "ATT_3039", "2"})
    aAdd(aAtributos, {"21011190", "ATT_3039", "99"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "a"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "b"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "c"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "d"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "e"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "f"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "g"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "h"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "i"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "j"})
    aAdd(aAtributos, {"21011190", "ATT_3060", "k"})
    aAdd(aAtributos, {"21011200", "ATT_3039", "1"})
    aAdd(aAtributos, {"21011200", "ATT_3039", "2"})
    aAdd(aAtributos, {"21011200", "ATT_3039", "99"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "a"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "b"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "c"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "d"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "e"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "f"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "g"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "h"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "i"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "j"})
    aAdd(aAtributos, {"21011200", "ATT_3060", "k"})
    aAdd(aAtributos, {"22071010", "ATT_3278", "01"})
    aAdd(aAtributos, {"22071010", "ATT_3278", "99"})
    aAdd(aAtributos, {"22071090", "ATT_3258", "01"})
    aAdd(aAtributos, {"22071090", "ATT_3258", "99"})
    aAdd(aAtributos, {"22071090", "ATT_3258", "98"})
    aAdd(aAtributos, {"25221000", "ATT_3278", "01"})
    aAdd(aAtributos, {"25221000", "ATT_3278", "99"})
    aAdd(aAtributos, {"25222000", "ATT_3278", "01"})
    aAdd(aAtributos, {"25222000", "ATT_3278", "99"})
    aAdd(aAtributos, {"25232990", "ATT_3198", "01"})
    aAdd(aAtributos, {"25232990", "ATT_3198", "99"})
    aAdd(aAtributos, {"25232990", "ATT_3198", "98"})
    aAdd(aAtributos, {"25309030", "ATT_180", "01"})
    aAdd(aAtributos, {"25309030", "ATT_180", "99"})
    aAdd(aAtributos, {"25309090", "ATT_181", "02"})
    aAdd(aAtributos, {"25309090", "ATT_181", "03"})
    aAdd(aAtributos, {"25309090", "ATT_181", "99"})
    aAdd(aAtributos, {"25309090", "ATT_181", "01"})
    aAdd(aAtributos, {"26090000", "ATT_2958", "01"})
    aAdd(aAtributos, {"26090000", "ATT_2958", "99"})
    aAdd(aAtributos, {"26140090", "ATT_182", "01"})
    aAdd(aAtributos, {"26140090", "ATT_182", "02"})
    aAdd(aAtributos, {"26140090", "ATT_182", "99"})
    aAdd(aAtributos, {"26151090", "ATT_183", "01"})
    aAdd(aAtributos, {"26151090", "ATT_183", "99"})
    aAdd(aAtributos, {"26159000", "ATT_184", "01"})
    aAdd(aAtributos, {"26159000", "ATT_184", "02"})
    aAdd(aAtributos, {"26159000", "ATT_184", "99"})
    aAdd(aAtributos, {"26179000", "ATT_185", "01"})
    aAdd(aAtributos, {"26179000", "ATT_185", "99"})
    aAdd(aAtributos, {"27073000", "ATT_3278", "01"})
    aAdd(aAtributos, {"27073000", "ATT_3278", "99"})
    aAdd(aAtributos, {"27101210", "ATT_3278", "01"})
    aAdd(aAtributos, {"27101210", "ATT_3278", "99"})
    aAdd(aAtributos, {"27101230", "ATT_3278", "01"})
    aAdd(aAtributos, {"27101230", "ATT_3278", "99"})
    aAdd(aAtributos, {"27101249", "ATT_186", "01"})
    aAdd(aAtributos, {"27101249", "ATT_186", "99"})
    aAdd(aAtributos, {"27101251", "ATT_3278", "01"})
    aAdd(aAtributos, {"27101251", "ATT_3278", "99"})
    aAdd(aAtributos, {"27101259", "ATT_3199", "01"})
    aAdd(aAtributos, {"27101259", "ATT_3199", "99"})
    aAdd(aAtributos, {"27101259", "ATT_3199", "98"})
    aAdd(aAtributos, {"27101290", "ATT_187", "04"})
    aAdd(aAtributos, {"27101290", "ATT_187", "06"})
    aAdd(aAtributos, {"27101290", "ATT_187", "05"})
    aAdd(aAtributos, {"27101290", "ATT_187", "99"})
    aAdd(aAtributos, {"27101290", "ATT_187", "03"})
    aAdd(aAtributos, {"27101290", "ATT_187", "02"})
    aAdd(aAtributos, {"27101290", "ATT_187", "01"})
    aAdd(aAtributos, {"27101290", "ATT_187", "98"})
    aAdd(aAtributos, {"27101911", "ATT_3278", "01"})
    aAdd(aAtributos, {"27101911", "ATT_3278", "99"})
    aAdd(aAtributos, {"27101919", "ATT_188", "01"})
    aAdd(aAtributos, {"27101919", "ATT_188", "99"})
    aAdd(aAtributos, {"27101919", "ATT_188", "98"})
    aAdd(aAtributos, {"27101921", "ATT_3278", "01"})
    aAdd(aAtributos, {"27101921", "ATT_3278", "99"})
    aAdd(aAtributos, {"27109900", "ATT_2959", "01"})
    aAdd(aAtributos, {"27109900", "ATT_2959", "99"})
    aAdd(aAtributos, {"28012010", "ATT_3278", "01"})
    aAdd(aAtributos, {"28012010", "ATT_3278", "99"})
    aAdd(aAtributos, {"28042910", "ATT_191", "01"})
    aAdd(aAtributos, {"28042910", "ATT_191", "99"})
    aAdd(aAtributos, {"28045000", "ATT_192", "01"})
    aAdd(aAtributos, {"28045000", "ATT_192", "99"})
    aAdd(aAtributos, {"28047020", "ATT_3278", "01"})
    aAdd(aAtributos, {"28047020", "ATT_3278", "99"})
    aAdd(aAtributos, {"28051990", "ATT_193", "01"})
    aAdd(aAtributos, {"28051990", "ATT_193", "99"})
    aAdd(aAtributos, {"28051990", "ATT_1416", "02"})
    aAdd(aAtributos, {"28061010", "ATT_3278", "01"})
    aAdd(aAtributos, {"28061010", "ATT_3278", "99"})
    aAdd(aAtributos, {"28061020", "ATT_3278", "01"})
    aAdd(aAtributos, {"28061020", "ATT_3278", "99"})
    aAdd(aAtributos, {"28062000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28062000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28070010", "ATT_3278", "01"})
    aAdd(aAtributos, {"28070010", "ATT_3278", "99"})
    aAdd(aAtributos, {"28080010", "ATT_2938", "01"})
    aAdd(aAtributos, {"28080010", "ATT_2938", "99"})
    aAdd(aAtributos, {"28092011", "ATT_3278", "01"})
    aAdd(aAtributos, {"28092011", "ATT_3278", "99"})
    aAdd(aAtributos, {"28100010", "ATT_3278", "01"})
    aAdd(aAtributos, {"28100010", "ATT_3278", "99"})
    aAdd(aAtributos, {"28100090", "ATT_194", "01"})
    aAdd(aAtributos, {"28100090", "ATT_194", "99"})
    aAdd(aAtributos, {"28111990", "ATT_195", "02"})
    aAdd(aAtributos, {"28111990", "ATT_195", "03"})
    aAdd(aAtributos, {"28111990", "ATT_195", "99"})
    aAdd(aAtributos, {"28111990", "ATT_195", "01"})
    aAdd(aAtributos, {"28111990", "ATT_195", "98"})
    aAdd(aAtributos, {"28112990", "ATT_196", "01"})
    aAdd(aAtributos, {"28112990", "ATT_196", "99"})
    aAdd(aAtributos, {"28112990", "ATT_196", "03"})
    aAdd(aAtributos, {"28112990", "ATT_196", "04"})
    aAdd(aAtributos, {"28112990", "ATT_196", "02"})
    aAdd(aAtributos, {"28121400", "ATT_3278", "01"})
    aAdd(aAtributos, {"28121400", "ATT_3278", "99"})
    aAdd(aAtributos, {"28121919", "ATT_197", "01"})
    aAdd(aAtributos, {"28121919", "ATT_197", "99"})
    aAdd(aAtributos, {"28121920", "ATT_198", "01"})
    aAdd(aAtributos, {"28121920", "ATT_198", "99"})
    aAdd(aAtributos, {"28129000", "ATT_199", "01"})
    aAdd(aAtributos, {"28129000", "ATT_199", "02"})
    aAdd(aAtributos, {"28129000", "ATT_199", "99"})
    aAdd(aAtributos, {"28139090", "ATT_200", "01"})
    aAdd(aAtributos, {"28139090", "ATT_200", "99"})
    aAdd(aAtributos, {"28141000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28141000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28142000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28142000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28151100", "ATT_3278", "01"})
    aAdd(aAtributos, {"28151100", "ATT_3278", "99"})
    aAdd(aAtributos, {"28151200", "ATT_3278", "01"})
    aAdd(aAtributos, {"28151200", "ATT_3278", "99"})
    aAdd(aAtributos, {"28152000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28152000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28201000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28201000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28251010", "ATT_201", "01"})
    aAdd(aAtributos, {"28251010", "ATT_201", "99"})
    aAdd(aAtributos, {"28251020", "ATT_3278", "01"})
    aAdd(aAtributos, {"28251020", "ATT_3278", "99"})
    aAdd(aAtributos, {"28256020", "ATT_202", "01"})
    aAdd(aAtributos, {"28256020", "ATT_202", "99"})
    aAdd(aAtributos, {"28259090", "ATT_203", "01"})
    aAdd(aAtributos, {"28259090", "ATT_203", "02"})
    aAdd(aAtributos, {"28259090", "ATT_203", "03"})
    aAdd(aAtributos, {"28259090", "ATT_203", "99"})
    aAdd(aAtributos, {"28261990", "ATT_204", "01"})
    aAdd(aAtributos, {"28261990", "ATT_204", "99"})
    aAdd(aAtributos, {"28261990", "ATT_204", "03"})
    aAdd(aAtributos, {"28261990", "ATT_204", "04"})
    aAdd(aAtributos, {"28261990", "ATT_204", "05"})
    aAdd(aAtributos, {"28261990", "ATT_204", "06"})
    aAdd(aAtributos, {"28261990", "ATT_204", "02"})
    aAdd(aAtributos, {"28271000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28271000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28272010", "ATT_3278", "01"})
    aAdd(aAtributos, {"28272010", "ATT_3278", "99"})
    aAdd(aAtributos, {"28273200", "ATT_3278", "01"})
    aAdd(aAtributos, {"28273200", "ATT_3278", "99"})
    aAdd(aAtributos, {"28273960", "ATT_1416", "01"})
    aAdd(aAtributos, {"28273960", "ATT_1416", "02"})
    aAdd(aAtributos, {"28273999", "ATT_205", "01"})
    aAdd(aAtributos, {"28273999", "ATT_205", "99"})
    aAdd(aAtributos, {"28275900", "ATT_206", "01"})
    aAdd(aAtributos, {"28275900", "ATT_206", "99"})
    aAdd(aAtributos, {"28275900", "ATT_1416", "02"})
    aAdd(aAtributos, {"28276019", "ATT_207", "01"})
    aAdd(aAtributos, {"28276019", "ATT_207", "99"})
    aAdd(aAtributos, {"28276019", "ATT_1416", "02"})
    aAdd(aAtributos, {"28289011", "ATT_3278", "01"})
    aAdd(aAtributos, {"28289011", "ATT_3278", "99"})
    aAdd(aAtributos, {"28299050", "ATT_208", "01"})
    aAdd(aAtributos, {"28299050", "ATT_208", "02"})
    aAdd(aAtributos, {"28299050", "ATT_208", "99"})
    aAdd(aAtributos, {"28321090", "ATT_3200", "01"})
    aAdd(aAtributos, {"28321090", "ATT_3200", "99"})
    aAdd(aAtributos, {"28321090", "ATT_3200", "98"})
    aAdd(aAtributos, {"28331110", "ATT_3278", "01"})
    aAdd(aAtributos, {"28331110", "ATT_3278", "99"})
    aAdd(aAtributos, {"28332920", "ATT_1416", "01"})
    aAdd(aAtributos, {"28332920", "ATT_1416", "02"})
    aAdd(aAtributos, {"28332990", "ATT_209", "01"})
    aAdd(aAtributos, {"28332990", "ATT_209", "99"})
    aAdd(aAtributos, {"28334090", "ATT_210", "01"})
    aAdd(aAtributos, {"28334090", "ATT_210", "99"})
    aAdd(aAtributos, {"28341090", "ATT_211", "01"})
    aAdd(aAtributos, {"28341090", "ATT_211", "99"})
    aAdd(aAtributos, {"28342940", "ATT_212", "01"})
    aAdd(aAtributos, {"28342940", "ATT_212", "99"})
    aAdd(aAtributos, {"28342940", "ATT_1416", "02"})
    aAdd(aAtributos, {"28342990", "ATT_213", "01"})
    aAdd(aAtributos, {"28342990", "ATT_213", "03"})
    aAdd(aAtributos, {"28342990", "ATT_213", "99"})
    aAdd(aAtributos, {"28342990", "ATT_213", "02"})
    aAdd(aAtributos, {"28362010", "ATT_3278", "01"})
    aAdd(aAtributos, {"28362010", "ATT_3278", "99"})
    aAdd(aAtributos, {"28363000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28363000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28364000", "ATT_214", "01"})
    aAdd(aAtributos, {"28364000", "ATT_214", "99"})
    aAdd(aAtributos, {"28364000", "ATT_214", "98"})
    aAdd(aAtributos, {"28365000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28365000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28369100", "ATT_1416", "01"})
    aAdd(aAtributos, {"28369100", "ATT_1416", "02"})
    aAdd(aAtributos, {"28369912", "ATT_215", "01"})
    aAdd(aAtributos, {"28369912", "ATT_215", "99"})
    aAdd(aAtributos, {"28369919", "ATT_216", "01"})
    aAdd(aAtributos, {"28369919", "ATT_216", "02"})
    aAdd(aAtributos, {"28369919", "ATT_216", "99"})
    aAdd(aAtributos, {"28369920", "ATT_217", "01"})
    aAdd(aAtributos, {"28369920", "ATT_217", "99"})
    aAdd(aAtributos, {"28399030", "ATT_218", "01"})
    aAdd(aAtributos, {"28402000", "ATT_219", "01"})
    aAdd(aAtributos, {"28402000", "ATT_219", "99"})
    aAdd(aAtributos, {"28402000", "ATT_1416", "02"})
    aAdd(aAtributos, {"28413000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28413000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28415012", "ATT_3278", "01"})
    aAdd(aAtributos, {"28415012", "ATT_3278", "99"})
    aAdd(aAtributos, {"28415014", "ATT_3278", "01"})
    aAdd(aAtributos, {"28415014", "ATT_3278", "99"})
    aAdd(aAtributos, {"28416100", "ATT_3278", "01"})
    aAdd(aAtributos, {"28416100", "ATT_3278", "99"})
    aAdd(aAtributos, {"28444090", "ATT_220", "01"})
    aAdd(aAtributos, {"28444090", "ATT_220", "03"})
    aAdd(aAtributos, {"28444090", "ATT_220", "04"})
    aAdd(aAtributos, {"28444090", "ATT_220", "05"})
    aAdd(aAtributos, {"28444090", "ATT_220", "06"})
    aAdd(aAtributos, {"28444090", "ATT_220", "07"})
    aAdd(aAtributos, {"28444090", "ATT_220", "99"})
    aAdd(aAtributos, {"28444090", "ATT_220", "02"})
    aAdd(aAtributos, {"28470000", "ATT_3278", "01"})
    aAdd(aAtributos, {"28470000", "ATT_3278", "99"})
    aAdd(aAtributos, {"28499090", "ATT_221", "01"})
    aAdd(aAtributos, {"28499090", "ATT_221", "02"})
    aAdd(aAtributos, {"28499090", "ATT_221", "99"})
    aAdd(aAtributos, {"28500090", "ATT_222", "03"})
    aAdd(aAtributos, {"28500090", "ATT_222", "08"})
    aAdd(aAtributos, {"28500090", "ATT_222", "05"})
    aAdd(aAtributos, {"28500090", "ATT_222", "04"})
    aAdd(aAtributos, {"28500090", "ATT_222", "99"})
    aAdd(aAtributos, {"28500090", "ATT_222", "02"})
    aAdd(aAtributos, {"28500090", "ATT_222", "01"})
    aAdd(aAtributos, {"28500090", "ATT_222", "07"})
    aAdd(aAtributos, {"28500090", "ATT_222", "06"})
    aAdd(aAtributos, {"28500090", "ATT_222", "09"})
    aAdd(aAtributos, {"28500090", "ATT_222", "98"})
    aAdd(aAtributos, {"28521014", "ATT_3278", "01"})
    aAdd(aAtributos, {"28521014", "ATT_3278", "99"})
    aAdd(aAtributos, {"28521019", "ATT_224", "01"})
    aAdd(aAtributos, {"28521019", "ATT_224", "99"})
    aAdd(aAtributos, {"28521029", "ATT_225", "01"})
    aAdd(aAtributos, {"28521029", "ATT_225", "99"})
    aAdd(aAtributos, {"28539090", "ATT_226", "01"})
    aAdd(aAtributos, {"28539090", "ATT_226", "02"})
    aAdd(aAtributos, {"28539090", "ATT_226", "03"})
    aAdd(aAtributos, {"28539090", "ATT_226", "04"})
    aAdd(aAtributos, {"28539090", "ATT_226", "99"})
    aAdd(aAtributos, {"29011000", "ATT_227", "01"})
    aAdd(aAtributos, {"29011000", "ATT_227", "02"})
    aAdd(aAtributos, {"29011000", "ATT_227", "99"})
    aAdd(aAtributos, {"29021100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29021100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29022000", "ATT_3278", "01"})
    aAdd(aAtributos, {"29022000", "ATT_3278", "99"})
    aAdd(aAtributos, {"29023000", "ATT_3278", "01"})
    aAdd(aAtributos, {"29023000", "ATT_3278", "99"})
    aAdd(aAtributos, {"29024100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29024100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29024200", "ATT_3278", "01"})
    aAdd(aAtributos, {"29024200", "ATT_3278", "99"})
    aAdd(aAtributos, {"29024300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29024300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29024400", "ATT_3278", "01"})
    aAdd(aAtributos, {"29024400", "ATT_3278", "99"})
    aAdd(aAtributos, {"29029090", "ATT_228", "02"})
    aAdd(aAtributos, {"29029090", "ATT_228", "03"})
    aAdd(aAtributos, {"29029090", "ATT_228", "01"})
    aAdd(aAtributos, {"29029090", "ATT_228", "99"})
    aAdd(aAtributos, {"29031120", "ATT_3278", "01"})
    aAdd(aAtributos, {"29031120", "ATT_3278", "99"})
    aAdd(aAtributos, {"29031200", "ATT_3278", "01"})
    aAdd(aAtributos, {"29031200", "ATT_3278", "99"})
    aAdd(aAtributos, {"29031300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29031300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29031500", "ATT_3278", "01"})
    aAdd(aAtributos, {"29031500", "ATT_3278", "99"})
    aAdd(aAtributos, {"29032200", "ATT_1416", "02"})
    aAdd(aAtributos, {"29032200", "ATT_3278", "01"})
    aAdd(aAtributos, {"29032200", "ATT_3278", "99"})
    aAdd(aAtributos, {"29032300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29032300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29032900", "ATT_229", "01"})
    aAdd(aAtributos, {"29032900", "ATT_229", "99"})
    aAdd(aAtributos, {"29032900", "ATT_1416", "02"})
    aAdd(aAtributos, {"29033919", "ATT_231", "01"})
    aAdd(aAtributos, {"29033919", "ATT_231", "99"})
    aAdd(aAtributos, {"29033919", "ATT_231", "03"})
    aAdd(aAtributos, {"29033919", "ATT_231", "04"})
    aAdd(aAtributos, {"29033919", "ATT_231", "02"})
    aAdd(aAtributos, {"29037931", "ATT_1416", "01"})
    aAdd(aAtributos, {"29037931", "ATT_1416", "02"})
    aAdd(aAtributos, {"29037939", "ATT_232", "01"})
    aAdd(aAtributos, {"29037939", "ATT_232", "99"})
    aAdd(aAtributos, {"29037939", "ATT_1416", "02"})
    aAdd(aAtributos, {"29038110", "ATT_1416", "01"})
    aAdd(aAtributos, {"29038110", "ATT_1416", "02"})
    aAdd(aAtributos, {"29038190", "ATT_233", "01"})
    aAdd(aAtributos, {"29038190", "ATT_233", "99"})
    aAdd(aAtributos, {"29038190", "ATT_1416", "02"})
    aAdd(aAtributos, {"29039911", "ATT_3278", "01"})
    aAdd(aAtributos, {"29039911", "ATT_3278", "99"})
    aAdd(aAtributos, {"29039921", "ATT_3278", "01"})
    aAdd(aAtributos, {"29039921", "ATT_3278", "99"})
    aAdd(aAtributos, {"29039929", "ATT_234", "01"})
    aAdd(aAtributos, {"29039929", "ATT_234", "99"})
    aAdd(aAtributos, {"29039990", "ATT_235", "01"})
    aAdd(aAtributos, {"29039990", "ATT_235", "99"})
    aAdd(aAtributos, {"29042059", "ATT_236", "01"})
    aAdd(aAtributos, {"29042059", "ATT_236", "99"})
    aAdd(aAtributos, {"29042060", "ATT_237", "01"})
    aAdd(aAtributos, {"29042060", "ATT_237", "02"})
    aAdd(aAtributos, {"29042060", "ATT_237", "99"})
    aAdd(aAtributos, {"29042070", "ATT_238", "01"})
    aAdd(aAtributos, {"29042070", "ATT_238", "99"})
    aAdd(aAtributos, {"29042070", "ATT_238", "02"})
    aAdd(aAtributos, {"29042070", "ATT_238", "98"})
    aAdd(aAtributos, {"29042090", "ATT_239", "01"})
    aAdd(aAtributos, {"29042090", "ATT_239", "02"})
    aAdd(aAtributos, {"29042090", "ATT_239", "03"})
    aAdd(aAtributos, {"29042090", "ATT_239", "99"})
    aAdd(aAtributos, {"29049919", "ATT_240", "01"})
    aAdd(aAtributos, {"29049919", "ATT_240", "02"})
    aAdd(aAtributos, {"29049919", "ATT_240", "03"})
    aAdd(aAtributos, {"29049919", "ATT_240", "04"})
    aAdd(aAtributos, {"29049919", "ATT_240", "99"})
    aAdd(aAtributos, {"29051100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29051100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29051210", "ATT_3278", "01"})
    aAdd(aAtributos, {"29051210", "ATT_3278", "99"})
    aAdd(aAtributos, {"29051220", "ATT_3278", "01"})
    aAdd(aAtributos, {"29051220", "ATT_3278", "99"})
    aAdd(aAtributos, {"29051300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29051300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29051410", "ATT_3278", "01"})
    aAdd(aAtributos, {"29051410", "ATT_3278", "99"})
    aAdd(aAtributos, {"29051420", "ATT_3278", "01"})
    aAdd(aAtributos, {"29051420", "ATT_3278", "99"})
    aAdd(aAtributos, {"29052990", "ATT_241", "01"})
    aAdd(aAtributos, {"29052990", "ATT_241", "99"})
    aAdd(aAtributos, {"29052990", "ATT_1416", "02"})
    aAdd(aAtributos, {"29054300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29054300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29055100", "ATT_1416", "01"})
    aAdd(aAtributos, {"29055100", "ATT_1416", "02"})
    aAdd(aAtributos, {"29055910", "ATT_1416", "01"})
    aAdd(aAtributos, {"29055910", "ATT_1416", "02"})
    aAdd(aAtributos, {"29055990", "ATT_242", "01"})
    aAdd(aAtributos, {"29055990", "ATT_242", "99"})
    aAdd(aAtributos, {"29055990", "ATT_242", "03"})
    aAdd(aAtributos, {"29055990", "ATT_242", "04"})
    aAdd(aAtributos, {"29055990", "ATT_242", "05"})
    aAdd(aAtributos, {"29055990", "ATT_242", "06"})
    aAdd(aAtributos, {"29055990", "ATT_242", "07"})
    aAdd(aAtributos, {"29055990", "ATT_242", "08"})
    aAdd(aAtributos, {"29055990", "ATT_242", "09"})
    aAdd(aAtributos, {"29055990", "ATT_242", "02"})
    aAdd(aAtributos, {"29062990", "ATT_243", "01"})
    aAdd(aAtributos, {"29062990", "ATT_243", "99"})
    aAdd(aAtributos, {"29062990", "ATT_1416", "02"})
    aAdd(aAtributos, {"29071200", "ATT_244", "01"})
    aAdd(aAtributos, {"29071200", "ATT_244", "02"})
    aAdd(aAtributos, {"29071200", "ATT_244", "99"})
    aAdd(aAtributos, {"29071990", "ATT_245", "01"})
    aAdd(aAtributos, {"29071990", "ATT_245", "02"})
    aAdd(aAtributos, {"29071990", "ATT_245", "99"})
    aAdd(aAtributos, {"29072900", "ATT_246", "01"})
    aAdd(aAtributos, {"29072900", "ATT_246", "99"})
    aAdd(aAtributos, {"29072900", "ATT_1416", "02"})
    aAdd(aAtributos, {"29089919", "ATT_247", "01"})
    aAdd(aAtributos, {"29089919", "ATT_247", "02"})
    aAdd(aAtributos, {"29089919", "ATT_247", "03"})
    aAdd(aAtributos, {"29089919", "ATT_247", "04"})
    aAdd(aAtributos, {"29089919", "ATT_247", "99"})
    aAdd(aAtributos, {"29091100", "ATT_3218", "01"})
    aAdd(aAtributos, {"29091100", "ATT_3218", "99"})
    aAdd(aAtributos, {"29091100", "ATT_3218", "98"})
    aAdd(aAtributos, {"29091990", "ATT_248", "01"})
    aAdd(aAtributos, {"29091990", "ATT_248", "02"})
    aAdd(aAtributos, {"29091990", "ATT_248", "03"})
    aAdd(aAtributos, {"29091990", "ATT_248", "04"})
    aAdd(aAtributos, {"29091990", "ATT_248", "05"})
    aAdd(aAtributos, {"29091990", "ATT_248", "06"})
    aAdd(aAtributos, {"29091990", "ATT_248", "99"})
    aAdd(aAtributos, {"29093029", "ATT_249", "01"})
    aAdd(aAtributos, {"29093029", "ATT_249", "99"})
    aAdd(aAtributos, {"29094990", "ATT_250", "01"})
    aAdd(aAtributos, {"29094990", "ATT_250", "99"})
    aAdd(aAtributos, {"29094990", "ATT_1416", "02"})
    aAdd(aAtributos, {"29109090", "ATT_251", "01"})
    aAdd(aAtributos, {"29109090", "ATT_251", "99"})
    aAdd(aAtributos, {"29121919", "ATT_252", "01"})
    aAdd(aAtributos, {"29121919", "ATT_252", "99"})
    aAdd(aAtributos, {"29122100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29122100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29141100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29141100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29141200", "ATT_3278", "01"})
    aAdd(aAtributos, {"29141200", "ATT_3278", "99"})
    aAdd(aAtributos, {"29141300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29141300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29142210", "ATT_3278", "01"})
    aAdd(aAtributos, {"29142210", "ATT_3278", "99"})
    aAdd(aAtributos, {"29143100", "ATT_1416", "02"})
    aAdd(aAtributos, {"29143100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29143100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29143990", "ATT_253", "02"})
    aAdd(aAtributos, {"29143990", "ATT_253", "01"})
    aAdd(aAtributos, {"29143990", "ATT_253", "99"})
    aAdd(aAtributos, {"29143990", "ATT_253", "98"})
    aAdd(aAtributos, {"29144010", "ATT_3278", "01"})
    aAdd(aAtributos, {"29144010", "ATT_3278", "99"})
    aAdd(aAtributos, {"29145090", "ATT_255", "01"})
    aAdd(aAtributos, {"29145090", "ATT_255", "99"})
    aAdd(aAtributos, {"29145090", "ATT_1416", "02"})
    aAdd(aAtributos, {"29146200", "ATT_256", "01"})
    aAdd(aAtributos, {"29146200", "ATT_256", "99"})
    aAdd(aAtributos, {"29151100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29151100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29151290", "ATT_259", "01"})
    aAdd(aAtributos, {"29151290", "ATT_259", "99"})
    aAdd(aAtributos, {"29151290", "ATT_259", "98"})
    aAdd(aAtributos, {"29152100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29152100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29152400", "ATT_3278", "01"})
    aAdd(aAtributos, {"29152400", "ATT_3278", "99"})
    aAdd(aAtributos, {"29153100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29153100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29153300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29153300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29153931", "ATT_3278", "01"})
    aAdd(aAtributos, {"29153931", "ATT_3278", "99"})
    aAdd(aAtributos, {"29153939", "ATT_260", "03"})
    aAdd(aAtributos, {"29153939", "ATT_260", "04"})
    aAdd(aAtributos, {"29153939", "ATT_260", "99"})
    aAdd(aAtributos, {"29153939", "ATT_260", "02"})
    aAdd(aAtributos, {"29153939", "ATT_260", "01"})
    aAdd(aAtributos, {"29153939", "ATT_260", "98"})
    aAdd(aAtributos, {"29156019", "ATT_261", "01"})
    aAdd(aAtributos, {"29156019", "ATT_261", "99"})
    aAdd(aAtributos, {"29156019", "ATT_1416", "02"})
    aAdd(aAtributos, {"29156029", "ATT_262", "01"})
    aAdd(aAtributos, {"29156029", "ATT_262", "99"})
    aAdd(aAtributos, {"29156029", "ATT_1416", "02"})
    aAdd(aAtributos, {"29157039", "ATT_263", "01"})
    aAdd(aAtributos, {"29157039", "ATT_263", "99"})
    aAdd(aAtributos, {"29157039", "ATT_1416", "02"})
    aAdd(aAtributos, {"29159090", "ATT_264", "07"})
    aAdd(aAtributos, {"29159090", "ATT_264", "13"})
    aAdd(aAtributos, {"29159090", "ATT_264", "12"})
    aAdd(aAtributos, {"29159090", "ATT_264", "10"})
    aAdd(aAtributos, {"29159090", "ATT_264", "09"})
    aAdd(aAtributos, {"29159090", "ATT_264", "08"})
    aAdd(aAtributos, {"29159090", "ATT_264", "99"})
    aAdd(aAtributos, {"29159090", "ATT_264", "06"})
    aAdd(aAtributos, {"29159090", "ATT_264", "05"})
    aAdd(aAtributos, {"29159090", "ATT_264", "04"})
    aAdd(aAtributos, {"29159090", "ATT_264", "03"})
    aAdd(aAtributos, {"29159090", "ATT_264", "02"})
    aAdd(aAtributos, {"29159090", "ATT_264", "01"})
    aAdd(aAtributos, {"29159090", "ATT_264", "98"})
    aAdd(aAtributos, {"29163110", "ATT_3278", "01"})
    aAdd(aAtributos, {"29163110", "ATT_3278", "99"})
    aAdd(aAtributos, {"29163400", "ATT_1416", "02"})
    aAdd(aAtributos, {"29163400", "ATT_3278", "01"})
    aAdd(aAtributos, {"29163400", "ATT_3278", "99"})
    aAdd(aAtributos, {"29163990", "ATT_266", "01"})
    aAdd(aAtributos, {"29163990", "ATT_266", "02"})
    aAdd(aAtributos, {"29163990", "ATT_266", "99"})
    aAdd(aAtributos, {"29171110", "ATT_267", "01"})
    aAdd(aAtributos, {"29171110", "ATT_267", "99"})
    aAdd(aAtributos, {"29171990", "ATT_268", "01"})
    aAdd(aAtributos, {"29171990", "ATT_268", "99"})
    aAdd(aAtributos, {"29171990", "ATT_1416", "02"})
    aAdd(aAtributos, {"29181500", "ATT_269", "01"})
    aAdd(aAtributos, {"29181500", "ATT_269", "99"})
    aAdd(aAtributos, {"29181500", "ATT_1416", "02"})
    aAdd(aAtributos, {"29181690", "ATT_270", "01"})
    aAdd(aAtributos, {"29181690", "ATT_270", "99"})
    aAdd(aAtributos, {"29181690", "ATT_1416", "02"})
    aAdd(aAtributos, {"29181943", "ATT_271", "01"})
    aAdd(aAtributos, {"29181943", "ATT_271", "99"})
    aAdd(aAtributos, {"29189919", "ATT_275", "01"})
    aAdd(aAtributos, {"29189919", "ATT_275", "99"})
    aAdd(aAtributos, {"29189999", "ATT_276", "01"})
    aAdd(aAtributos, {"29189999", "ATT_276", "02"})
    aAdd(aAtributos, {"29189999", "ATT_276", "99"})
    aAdd(aAtributos, {"29202990", "ATT_279", "01"})
    aAdd(aAtributos, {"29202990", "ATT_279", "02"})
    aAdd(aAtributos, {"29202990", "ATT_279", "03"})
    aAdd(aAtributos, {"29202990", "ATT_279", "04"})
    aAdd(aAtributos, {"29202990", "ATT_279", "99"})
    aAdd(aAtributos, {"29209049", "ATT_280", "01"})
    aAdd(aAtributos, {"29209049", "ATT_280", "99"})
    aAdd(aAtributos, {"29209090", "ATT_281", "01"})
    aAdd(aAtributos, {"29209090", "ATT_281", "02"})
    aAdd(aAtributos, {"29209090", "ATT_281", "03"})
    aAdd(aAtributos, {"29209090", "ATT_281", "04"})
    aAdd(aAtributos, {"29209090", "ATT_281", "99"})
    aAdd(aAtributos, {"29211111", "ATT_3278", "01"})
    aAdd(aAtributos, {"29211111", "ATT_3278", "99"})
    aAdd(aAtributos, {"29211112", "ATT_3278", "01"})
    aAdd(aAtributos, {"29211112", "ATT_3278", "99"})
    aAdd(aAtributos, {"29211129", "ATT_282", "01"})
    aAdd(aAtributos, {"29211129", "ATT_282", "99"})
    aAdd(aAtributos, {"29211911", "ATT_3278", "01"})
    aAdd(aAtributos, {"29211911", "ATT_3278", "99"})
    aAdd(aAtributos, {"29211915", "ATT_3278", "01"})
    aAdd(aAtributos, {"29211915", "ATT_3278", "99"})
    aAdd(aAtributos, {"29211919", "ATT_283", "01"})
    aAdd(aAtributos, {"29211919", "ATT_283", "99"})
    aAdd(aAtributos, {"29211939", "ATT_284", "01"})
    aAdd(aAtributos, {"29211939", "ATT_284", "99"})
    aAdd(aAtributos, {"29211939", "ATT_284", "98"})
    aAdd(aAtributos, {"29211999", "ATT_285", "01"})
    aAdd(aAtributos, {"29211999", "ATT_285", "02"})
    aAdd(aAtributos, {"29211999", "ATT_285", "99"})
    aAdd(aAtributos, {"29212990", "ATT_286", "01"})
    aAdd(aAtributos, {"29212990", "ATT_286", "99"})
    aAdd(aAtributos, {"29213020", "ATT_1416", "01"})
    aAdd(aAtributos, {"29213020", "ATT_1416", "02"})
    aAdd(aAtributos, {"29213090", "ATT_287", "01"})
    aAdd(aAtributos, {"29213090", "ATT_287", "02"})
    aAdd(aAtributos, {"29213090", "ATT_287", "03"})
    aAdd(aAtributos, {"29213090", "ATT_287", "99"})
    aAdd(aAtributos, {"29214290", "ATT_288", "01"})
    aAdd(aAtributos, {"29214290", "ATT_288", "99"})
    aAdd(aAtributos, {"29214429", "ATT_290", "01"})
    aAdd(aAtributos, {"29214429", "ATT_290", "02"})
    aAdd(aAtributos, {"29214429", "ATT_290", "99"})
    aAdd(aAtributos, {"29214610", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214610", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214620", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214620", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214630", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214630", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214640", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214640", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214650", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214650", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214660", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214660", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214670", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214670", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214680", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214680", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214690", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214690", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214910", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214910", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214931", "ATT_1416", "01"})
    aAdd(aAtributos, {"29214931", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214939", "ATT_292", "01"})
    aAdd(aAtributos, {"29214939", "ATT_292", "99"})
    aAdd(aAtributos, {"29214939", "ATT_1416", "02"})
    aAdd(aAtributos, {"29214990", "ATT_293", "01"})
    aAdd(aAtributos, {"29214990", "ATT_293", "99"})
    aAdd(aAtributos, {"29214990", "ATT_1416", "02"})
    aAdd(aAtributos, {"29221400", "ATT_1416", "01"})
    aAdd(aAtributos, {"29221400", "ATT_1416", "02"})
    aAdd(aAtributos, {"29221600", "ATT_294", "01"})
    aAdd(aAtributos, {"29221600", "ATT_294", "02"})
    aAdd(aAtributos, {"29221600", "ATT_294", "03"})
    aAdd(aAtributos, {"29221600", "ATT_294", "99"})
    aAdd(aAtributos, {"29221700", "ATT_295", "01"})
    aAdd(aAtributos, {"29221700", "ATT_295", "02"})
    aAdd(aAtributos, {"29221700", "ATT_295", "99"})
    aAdd(aAtributos, {"29221800", "ATT_296", "01"})
    aAdd(aAtributos, {"29221800", "ATT_296", "99"})
    aAdd(aAtributos, {"29221959", "ATT_298", "01"})
    aAdd(aAtributos, {"29221959", "ATT_298", "99"})
    aAdd(aAtributos, {"29221999", "ATT_299", "03"})
    aAdd(aAtributos, {"29221999", "ATT_299", "12"})
    aAdd(aAtributos, {"29221999", "ATT_299", "06"})
    aAdd(aAtributos, {"29221999", "ATT_299", "99"})
    aAdd(aAtributos, {"29221999", "ATT_299", "02"})
    aAdd(aAtributos, {"29221999", "ATT_299", "01"})
    aAdd(aAtributos, {"29221999", "ATT_299", "14"})
    aAdd(aAtributos, {"29221999", "ATT_299", "98"})
    aAdd(aAtributos, {"29222990", "ATT_300", "01"})
    aAdd(aAtributos, {"29222990", "ATT_300", "99"})
    aAdd(aAtributos, {"29223111", "ATT_1416", "01"})
    aAdd(aAtributos, {"29223111", "ATT_1416", "02"})
    aAdd(aAtributos, {"29223112", "ATT_1416", "01"})
    aAdd(aAtributos, {"29223112", "ATT_1416", "02"})
    aAdd(aAtributos, {"29223120", "ATT_1416", "01"})
    aAdd(aAtributos, {"29223120", "ATT_1416", "02"})
    aAdd(aAtributos, {"29223130", "ATT_1416", "01"})
    aAdd(aAtributos, {"29223130", "ATT_1416", "02"})
    aAdd(aAtributos, {"29223921", "ATT_1416", "01"})
    aAdd(aAtributos, {"29223921", "ATT_1416", "02"})
    aAdd(aAtributos, {"29223929", "ATT_1416", "01"})
    aAdd(aAtributos, {"29223929", "ATT_1416", "02"})
    aAdd(aAtributos, {"29223990", "ATT_301", "01"})
    aAdd(aAtributos, {"29223990", "ATT_301", "99"})
    aAdd(aAtributos, {"29223990", "ATT_1416", "02"})
    aAdd(aAtributos, {"29224300", "ATT_1416", "02"})
    aAdd(aAtributos, {"29224300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29224300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29224410", "ATT_1416", "01"})
    aAdd(aAtributos, {"29224410", "ATT_1416", "02"})
    aAdd(aAtributos, {"29224420", "ATT_1416", "01"})
    aAdd(aAtributos, {"29224420", "ATT_1416", "02"})
    aAdd(aAtributos, {"29224990", "ATT_302", "03"})
    aAdd(aAtributos, {"29224990", "ATT_302", "09"})
    aAdd(aAtributos, {"29224990", "ATT_302", "08"})
    aAdd(aAtributos, {"29224990", "ATT_302", "07"})
    aAdd(aAtributos, {"29224990", "ATT_302", "04"})
    aAdd(aAtributos, {"29224990", "ATT_302", "99"})
    aAdd(aAtributos, {"29224990", "ATT_302", "02"})
    aAdd(aAtributos, {"29224990", "ATT_302", "01"})
    aAdd(aAtributos, {"29224990", "ATT_302", "06"})
    aAdd(aAtributos, {"29224990", "ATT_302", "05"})
    aAdd(aAtributos, {"29224990", "ATT_302", "10"})
    aAdd(aAtributos, {"29224990", "ATT_302", "98"})
    aAdd(aAtributos, {"29225099", "ATT_303", "01"})
    aAdd(aAtributos, {"29225099", "ATT_303", "03"})
    aAdd(aAtributos, {"29225099", "ATT_303", "04"})
    aAdd(aAtributos, {"29225099", "ATT_303", "05"})
    aAdd(aAtributos, {"29225099", "ATT_303", "06"})
    aAdd(aAtributos, {"29225099", "ATT_303", "07"})
    aAdd(aAtributos, {"29225099", "ATT_303", "08"})
    aAdd(aAtributos, {"29225099", "ATT_303", "09"})
    aAdd(aAtributos, {"29225099", "ATT_303", "10"})
    aAdd(aAtributos, {"29225099", "ATT_303", "11"})
    aAdd(aAtributos, {"29225099", "ATT_303", "99"})
    aAdd(aAtributos, {"29225099", "ATT_303", "02"})
    aAdd(aAtributos, {"29241100", "ATT_1416", "01"})
    aAdd(aAtributos, {"29241100", "ATT_1416", "02"})
    aAdd(aAtributos, {"29241919", "ATT_304", "01"})
    aAdd(aAtributos, {"29241919", "ATT_304", "99"})
    aAdd(aAtributos, {"29241921", "ATT_3278", "01"})
    aAdd(aAtributos, {"29241921", "ATT_3278", "99"})
    aAdd(aAtributos, {"29241929", "ATT_305", "01"})
    aAdd(aAtributos, {"29241929", "ATT_305", "99"})
    aAdd(aAtributos, {"29241929", "ATT_305", "98"})
    aAdd(aAtributos, {"29241999", "ATT_306", "01"})
    aAdd(aAtributos, {"29241999", "ATT_306", "99"})
    aAdd(aAtributos, {"29241999", "ATT_1416", "02"})
    aAdd(aAtributos, {"29242300", "ATT_1416", "02"})
    aAdd(aAtributos, {"29242300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29242300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29242400", "ATT_1416", "01"})
    aAdd(aAtributos, {"29242400", "ATT_1416", "02"})
    aAdd(aAtributos, {"29242913", "ATT_3278", "01"})
    aAdd(aAtributos, {"29242913", "ATT_3278", "99"})
    aAdd(aAtributos, {"29242914", "ATT_3278", "01"})
    aAdd(aAtributos, {"29242914", "ATT_3278", "99"})
    aAdd(aAtributos, {"29242919", "ATT_307", "01"})
    aAdd(aAtributos, {"29242919", "ATT_307", "99"})
    aAdd(aAtributos, {"29242919", "ATT_307", "98"})
    aAdd(aAtributos, {"29242939", "ATT_308", "01"})
    aAdd(aAtributos, {"29242939", "ATT_308", "99"})
    aAdd(aAtributos, {"29242939", "ATT_1416", "02"})
    aAdd(aAtributos, {"29242949", "ATT_309", "01"})
    aAdd(aAtributos, {"29242949", "ATT_309", "99"})
    aAdd(aAtributos, {"29242949", "ATT_1416", "02"})
    aAdd(aAtributos, {"29242969", "ATT_311", "01"})
    aAdd(aAtributos, {"29242969", "ATT_311", "02"})
    aAdd(aAtributos, {"29242969", "ATT_311", "99"})
    aAdd(aAtributos, {"29242999", "ATT_312", "01"})
    aAdd(aAtributos, {"29242999", "ATT_312", "02"})
    aAdd(aAtributos, {"29242999", "ATT_312", "03"})
    aAdd(aAtributos, {"29242999", "ATT_312", "04"})
    aAdd(aAtributos, {"29242999", "ATT_312", "05"})
    aAdd(aAtributos, {"29242999", "ATT_312", "99"})
    aAdd(aAtributos, {"29251200", "ATT_1416", "01"})
    aAdd(aAtributos, {"29251200", "ATT_1416", "02"})
    aAdd(aAtributos, {"29251910", "ATT_1416", "01"})
    aAdd(aAtributos, {"29251910", "ATT_1416", "02"})
    aAdd(aAtributos, {"29251990", "ATT_314", "01"})
    aAdd(aAtributos, {"29251990", "ATT_314", "02"})
    aAdd(aAtributos, {"29251990", "ATT_314", "03"})
    aAdd(aAtributos, {"29251990", "ATT_314", "99"})
    aAdd(aAtributos, {"29263011", "ATT_1416", "01"})
    aAdd(aAtributos, {"29263011", "ATT_1416", "02"})
    aAdd(aAtributos, {"29263012", "ATT_1416", "01"})
    aAdd(aAtributos, {"29263012", "ATT_1416", "02"})
    aAdd(aAtributos, {"29263020", "ATT_1416", "01"})
    aAdd(aAtributos, {"29263020", "ATT_1416", "02"})
    aAdd(aAtributos, {"29264000", "ATT_315", "01"})
    aAdd(aAtributos, {"29264000", "ATT_315", "99"})
    aAdd(aAtributos, {"29264000", "ATT_315", "05"})
    aAdd(aAtributos, {"29264000", "ATT_315", "06"})
    aAdd(aAtributos, {"29264000", "ATT_315", "07"})
    aAdd(aAtributos, {"29264000", "ATT_315", "12"})
    aAdd(aAtributos, {"29264000", "ATT_315", "13"})
    aAdd(aAtributos, {"29264000", "ATT_315", "04"})
    aAdd(aAtributos, {"29269030", "ATT_1416", "01"})
    aAdd(aAtributos, {"29269030", "ATT_1416", "02"})
    aAdd(aAtributos, {"29269099", "ATT_317", "04"})
    aAdd(aAtributos, {"29269099", "ATT_317", "10"})
    aAdd(aAtributos, {"29269099", "ATT_317", "09"})
    aAdd(aAtributos, {"29269099", "ATT_317", "05"})
    aAdd(aAtributos, {"29269099", "ATT_317", "99"})
    aAdd(aAtributos, {"29269099", "ATT_317", "03"})
    aAdd(aAtributos, {"29269099", "ATT_317", "02"})
    aAdd(aAtributos, {"29269099", "ATT_317", "01"})
    aAdd(aAtributos, {"29269099", "ATT_317", "06"})
    aAdd(aAtributos, {"29269099", "ATT_317", "98"})
    aAdd(aAtributos, {"29270010", "ATT_318", "02"})
    aAdd(aAtributos, {"29270010", "ATT_318", "99"})
    aAdd(aAtributos, {"29270010", "ATT_318", "01"})
    aAdd(aAtributos, {"29270029", "ATT_319", "01"})
    aAdd(aAtributos, {"29270029", "ATT_319", "99"})
    aAdd(aAtributos, {"29280090", "ATT_320", "01"})
    aAdd(aAtributos, {"29280090", "ATT_320", "99"})
    aAdd(aAtributos, {"29280090", "ATT_320", "03"})
    aAdd(aAtributos, {"29280090", "ATT_320", "04"})
    aAdd(aAtributos, {"29280090", "ATT_320", "05"})
    aAdd(aAtributos, {"29280090", "ATT_320", "06"})
    aAdd(aAtributos, {"29280090", "ATT_320", "07"})
    aAdd(aAtributos, {"29280090", "ATT_320", "08"})
    aAdd(aAtributos, {"29280090", "ATT_320", "02"})
    aAdd(aAtributos, {"29291090", "ATT_321", "01"})
    aAdd(aAtributos, {"29291090", "ATT_321", "99"})
    aAdd(aAtributos, {"29299022", "ATT_322", "01"})
    aAdd(aAtributos, {"29299022", "ATT_322", "99"})
    aAdd(aAtributos, {"29299090", "ATT_323", "01"})
    aAdd(aAtributos, {"29299090", "ATT_323", "02"})
    aAdd(aAtributos, {"29299090", "ATT_323", "03"})
    aAdd(aAtributos, {"29299090", "ATT_323", "99"})
    aAdd(aAtributos, {"29303022", "ATT_1416", "01"})
    aAdd(aAtributos, {"29303022", "ATT_1416", "02"})
    aAdd(aAtributos, {"29303029", "ATT_324", "01"})
    aAdd(aAtributos, {"29303029", "ATT_324", "99"})
    aAdd(aAtributos, {"29303029", "ATT_1416", "02"})
    aAdd(aAtributos, {"29306000", "ATT_325", "01"})
    aAdd(aAtributos, {"29306000", "ATT_325", "99"})
    aAdd(aAtributos, {"29309013", "ATT_326", "01"})
    aAdd(aAtributos, {"29309013", "ATT_326", "99"})
    aAdd(aAtributos, {"29309039", "ATT_327", "01"})
    aAdd(aAtributos, {"29309039", "ATT_327", "99"})
    aAdd(aAtributos, {"29309071", "ATT_1416", "01"})
    aAdd(aAtributos, {"29309071", "ATT_1416", "02"})
    aAdd(aAtributos, {"29309079", "ATT_329", "01"})
    aAdd(aAtributos, {"29309079", "ATT_329", "99"})
    aAdd(aAtributos, {"29309079", "ATT_1416", "02"})
    aAdd(aAtributos, {"29309099", "ATT_330", "01"})
    aAdd(aAtributos, {"29309099", "ATT_330", "02"})
    aAdd(aAtributos, {"29309099", "ATT_330", "99"})
    aAdd(aAtributos, {"29311000", "ATT_331", "01"})
    aAdd(aAtributos, {"29311000", "ATT_331", "99"})
    aAdd(aAtributos, {"29311000", "ATT_331", "03"})
    aAdd(aAtributos, {"29311000", "ATT_331", "04"})
    aAdd(aAtributos, {"29311000", "ATT_331", "05"})
    aAdd(aAtributos, {"29311000", "ATT_331", "06"})
    aAdd(aAtributos, {"29311000", "ATT_331", "07"})
    aAdd(aAtributos, {"29311000", "ATT_331", "08"})
    aAdd(aAtributos, {"29311000", "ATT_331", "09"})
    aAdd(aAtributos, {"29311000", "ATT_331", "10"})
    aAdd(aAtributos, {"29311000", "ATT_331", "11"})
    aAdd(aAtributos, {"29311000", "ATT_331", "02"})
    aAdd(aAtributos, {"29313100", "ATT_332", "01"})
    aAdd(aAtributos, {"29313100", "ATT_332", "99"})
    aAdd(aAtributos, {"29313100", "ATT_332", "03"})
    aAdd(aAtributos, {"29313100", "ATT_332", "04"})
    aAdd(aAtributos, {"29313100", "ATT_332", "05"})
    aAdd(aAtributos, {"29313100", "ATT_332", "06"})
    aAdd(aAtributos, {"29313100", "ATT_332", "07"})
    aAdd(aAtributos, {"29313100", "ATT_332", "02"})
    aAdd(aAtributos, {"29313200", "ATT_333", "01"})
    aAdd(aAtributos, {"29313200", "ATT_333", "99"})
    aAdd(aAtributos, {"29313200", "ATT_333", "03"})
    aAdd(aAtributos, {"29313200", "ATT_333", "04"})
    aAdd(aAtributos, {"29313200", "ATT_333", "05"})
    aAdd(aAtributos, {"29313200", "ATT_333", "06"})
    aAdd(aAtributos, {"29313200", "ATT_333", "07"})
    aAdd(aAtributos, {"29313200", "ATT_333", "02"})
    aAdd(aAtributos, {"29313300", "ATT_334", "01"})
    aAdd(aAtributos, {"29313300", "ATT_334", "99"})
    aAdd(aAtributos, {"29313300", "ATT_334", "03"})
    aAdd(aAtributos, {"29313300", "ATT_334", "04"})
    aAdd(aAtributos, {"29313300", "ATT_334", "05"})
    aAdd(aAtributos, {"29313300", "ATT_334", "06"})
    aAdd(aAtributos, {"29313300", "ATT_334", "07"})
    aAdd(aAtributos, {"29313300", "ATT_334", "02"})
    aAdd(aAtributos, {"29313400", "ATT_335", "01"})
    aAdd(aAtributos, {"29313400", "ATT_335", "99"})
    aAdd(aAtributos, {"29313400", "ATT_335", "03"})
    aAdd(aAtributos, {"29313400", "ATT_335", "04"})
    aAdd(aAtributos, {"29313400", "ATT_335", "05"})
    aAdd(aAtributos, {"29313400", "ATT_335", "06"})
    aAdd(aAtributos, {"29313400", "ATT_335", "07"})
    aAdd(aAtributos, {"29313400", "ATT_335", "02"})
    aAdd(aAtributos, {"29313500", "ATT_336", "05"})
    aAdd(aAtributos, {"29313500", "ATT_336", "99"})
    aAdd(aAtributos, {"29313500", "ATT_336", "07"})
    aAdd(aAtributos, {"29313500", "ATT_336", "01"})
    aAdd(aAtributos, {"29313500", "ATT_336", "02"})
    aAdd(aAtributos, {"29313500", "ATT_336", "03"})
    aAdd(aAtributos, {"29313500", "ATT_336", "04"})
    aAdd(aAtributos, {"29313500", "ATT_336", "06"})
    aAdd(aAtributos, {"29313600", "ATT_337", "01"})
    aAdd(aAtributos, {"29313600", "ATT_337", "99"})
    aAdd(aAtributos, {"29313600", "ATT_337", "03"})
    aAdd(aAtributos, {"29313600", "ATT_337", "04"})
    aAdd(aAtributos, {"29313600", "ATT_337", "05"})
    aAdd(aAtributos, {"29313600", "ATT_337", "06"})
    aAdd(aAtributos, {"29313600", "ATT_337", "07"})
    aAdd(aAtributos, {"29313600", "ATT_337", "02"})
    aAdd(aAtributos, {"29313700", "ATT_338", "01"})
    aAdd(aAtributos, {"29313700", "ATT_338", "99"})
    aAdd(aAtributos, {"29313700", "ATT_338", "03"})
    aAdd(aAtributos, {"29313700", "ATT_338", "04"})
    aAdd(aAtributos, {"29313700", "ATT_338", "05"})
    aAdd(aAtributos, {"29313700", "ATT_338", "06"})
    aAdd(aAtributos, {"29313700", "ATT_338", "07"})
    aAdd(aAtributos, {"29313700", "ATT_338", "02"})
    aAdd(aAtributos, {"29313991", "ATT_339", "01"})
    aAdd(aAtributos, {"29313991", "ATT_339", "02"})
    aAdd(aAtributos, {"29313991", "ATT_339", "99"})
    aAdd(aAtributos, {"29313994", "ATT_340", "01"})
    aAdd(aAtributos, {"29313994", "ATT_340", "02"})
    aAdd(aAtributos, {"29313994", "ATT_340", "99"})
    aAdd(aAtributos, {"29313996", "ATT_341", "01"})
    aAdd(aAtributos, {"29313996", "ATT_341", "99"})
    aAdd(aAtributos, {"29313996", "ATT_341", "03"})
    aAdd(aAtributos, {"29313996", "ATT_341", "04"})
    aAdd(aAtributos, {"29313996", "ATT_341", "05"})
    aAdd(aAtributos, {"29313996", "ATT_341", "06"})
    aAdd(aAtributos, {"29313996", "ATT_341", "07"})
    aAdd(aAtributos, {"29313996", "ATT_341", "02"})
    aAdd(aAtributos, {"29313997", "ATT_342", "01"})
    aAdd(aAtributos, {"29313997", "ATT_342", "99"})
    aAdd(aAtributos, {"29319059", "ATT_343", "01"})
    aAdd(aAtributos, {"29319059", "ATT_343", "07"})
    aAdd(aAtributos, {"29319059", "ATT_343", "03"})
    aAdd(aAtributos, {"29319059", "ATT_343", "04"})
    aAdd(aAtributos, {"29319059", "ATT_343", "05"})
    aAdd(aAtributos, {"29319059", "ATT_343", "06"})
    aAdd(aAtributos, {"29319059", "ATT_343", "08"})
    aAdd(aAtributos, {"29319059", "ATT_343", "09"})
    aAdd(aAtributos, {"29319059", "ATT_343", "10"})
    aAdd(aAtributos, {"29319059", "ATT_343", "99"})
    aAdd(aAtributos, {"29319059", "ATT_343", "02"})
    aAdd(aAtributos, {"29319090", "ATT_344", "01"})
    aAdd(aAtributos, {"29319090", "ATT_344", "99"})
    aAdd(aAtributos, {"29319090", "ATT_344", "03"})
    aAdd(aAtributos, {"29319090", "ATT_344", "04"})
    aAdd(aAtributos, {"29319090", "ATT_344", "05"})
    aAdd(aAtributos, {"29319090", "ATT_344", "06"})
    aAdd(aAtributos, {"29319090", "ATT_344", "07"})
    aAdd(aAtributos, {"29319090", "ATT_344", "08"})
    aAdd(aAtributos, {"29319090", "ATT_344", "09"})
    aAdd(aAtributos, {"29319090", "ATT_344", "10"})
    aAdd(aAtributos, {"29319090", "ATT_344", "11"})
    aAdd(aAtributos, {"29319090", "ATT_344", "02"})
    aAdd(aAtributos, {"29321100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29321100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29322000", "ATT_3202", "01"})
    aAdd(aAtributos, {"29322000", "ATT_3202", "99"})
    aAdd(aAtributos, {"29322000", "ATT_3202", "98"})
    aAdd(aAtributos, {"29329100", "ATT_1416", "02"})
    aAdd(aAtributos, {"29329100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29329100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29329200", "ATT_3278", "01"})
    aAdd(aAtributos, {"29329200", "ATT_3278", "99"})
    aAdd(aAtributos, {"29329300", "ATT_1416", "02"})
    aAdd(aAtributos, {"29329300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29329300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29329400", "ATT_1416", "02"})
    aAdd(aAtributos, {"29329400", "ATT_3278", "01"})
    aAdd(aAtributos, {"29329400", "ATT_3278", "99"})
    aAdd(aAtributos, {"29329500", "ATT_1416", "01"})
    aAdd(aAtributos, {"29329500", "ATT_1416", "02"})
    aAdd(aAtributos, {"29329999", "ATT_346", "01"})
    aAdd(aAtributos, {"29329999", "ATT_346", "02"})
    aAdd(aAtributos, {"29329999", "ATT_346", "99"})
    aAdd(aAtributos, {"29331111", "ATT_3278", "01"})
    aAdd(aAtributos, {"29331111", "ATT_3278", "99"})
    aAdd(aAtributos, {"29331119", "ATT_3201", "01"})
    aAdd(aAtributos, {"29331119", "ATT_3201", "99"})
    aAdd(aAtributos, {"29331119", "ATT_3201", "98"})
    aAdd(aAtributos, {"29332121", "ATT_1416", "01"})
    aAdd(aAtributos, {"29332121", "ATT_1416", "02"})
    aAdd(aAtributos, {"29332129", "ATT_1416", "01"})
    aAdd(aAtributos, {"29332129", "ATT_1416", "02"})
    aAdd(aAtributos, {"29332190", "ATT_347", "01"})
    aAdd(aAtributos, {"29332190", "ATT_347", "99"})
    aAdd(aAtributos, {"29332190", "ATT_1416", "02"})
    aAdd(aAtributos, {"29332999", "ATT_348", "01"})
    aAdd(aAtributos, {"29332999", "ATT_348", "02"})
    aAdd(aAtributos, {"29332999", "ATT_348", "99"})
    aAdd(aAtributos, {"29333110", "ATT_3278", "01"})
    aAdd(aAtributos, {"29333110", "ATT_3278", "99"})
    aAdd(aAtributos, {"29333120", "ATT_3278", "01"})
    aAdd(aAtributos, {"29333120", "ATT_3278", "99"})
    aAdd(aAtributos, {"29333200", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333200", "ATT_3278", "01"})
    aAdd(aAtributos, {"29333200", "ATT_3278", "99"})
    aAdd(aAtributos, {"29333311", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333311", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333312", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333312", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333319", "ATT_349", "01"})
    aAdd(aAtributos, {"29333319", "ATT_349", "99"})
    aAdd(aAtributos, {"29333319", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333321", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333321", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333322", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333322", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333329", "ATT_350", "01"})
    aAdd(aAtributos, {"29333329", "ATT_350", "99"})
    aAdd(aAtributos, {"29333329", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333330", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333330", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333341", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333341", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333342", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333342", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333349", "ATT_351", "01"})
    aAdd(aAtributos, {"29333349", "ATT_351", "99"})
    aAdd(aAtributos, {"29333349", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333351", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333351", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333352", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333352", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333359", "ATT_352", "01"})
    aAdd(aAtributos, {"29333359", "ATT_352", "99"})
    aAdd(aAtributos, {"29333359", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333361", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333361", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333362", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333362", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333363", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333363", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333369", "ATT_353", "01"})
    aAdd(aAtributos, {"29333369", "ATT_353", "99"})
    aAdd(aAtributos, {"29333369", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333371", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333371", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333372", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333372", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333379", "ATT_354", "01"})
    aAdd(aAtributos, {"29333379", "ATT_354", "99"})
    aAdd(aAtributos, {"29333379", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333381", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333381", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333382", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333382", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333383", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333383", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333384", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333384", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333389", "ATT_355", "01"})
    aAdd(aAtributos, {"29333389", "ATT_355", "99"})
    aAdd(aAtributos, {"29333389", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333391", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333391", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333392", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333392", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333393", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333393", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333399", "ATT_356", "01"})
    aAdd(aAtributos, {"29333399", "ATT_356", "99"})
    aAdd(aAtributos, {"29333399", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333912", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333912", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333915", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333915", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333919", "ATT_357", "01"})
    aAdd(aAtributos, {"29333919", "ATT_357", "02"})
    aAdd(aAtributos, {"29333919", "ATT_357", "99"})
    aAdd(aAtributos, {"29333924", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333924", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333929", "ATT_358", "01"})
    aAdd(aAtributos, {"29333929", "ATT_358", "02"})
    aAdd(aAtributos, {"29333929", "ATT_358", "99"})
    aAdd(aAtributos, {"29333931", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333931", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333932", "ATT_1416", "01"})
    aAdd(aAtributos, {"29333932", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333939", "ATT_359", "01"})
    aAdd(aAtributos, {"29333939", "ATT_359", "99"})
    aAdd(aAtributos, {"29333939", "ATT_1416", "02"})
    aAdd(aAtributos, {"29333989", "ATT_360", "01"})
    aAdd(aAtributos, {"29333989", "ATT_360", "02"})
    aAdd(aAtributos, {"29333989", "ATT_360", "99"})
    aAdd(aAtributos, {"29333999", "ATT_361", "02"})
    aAdd(aAtributos, {"29333999", "ATT_361", "59"})
    aAdd(aAtributos, {"29333999", "ATT_361", "58"})
    aAdd(aAtributos, {"29333999", "ATT_361", "57"})
    aAdd(aAtributos, {"29333999", "ATT_361", "56"})
    aAdd(aAtributos, {"29333999", "ATT_361", "55"})
    aAdd(aAtributos, {"29333999", "ATT_361", "54"})
    aAdd(aAtributos, {"29333999", "ATT_361", "53"})
    aAdd(aAtributos, {"29333999", "ATT_361", "52"})
    aAdd(aAtributos, {"29333999", "ATT_361", "51"})
    aAdd(aAtributos, {"29333999", "ATT_361", "50"})
    aAdd(aAtributos, {"29333999", "ATT_361", "49"})
    aAdd(aAtributos, {"29333999", "ATT_361", "48"})
    aAdd(aAtributos, {"29333999", "ATT_361", "47"})
    aAdd(aAtributos, {"29333999", "ATT_361", "46"})
    aAdd(aAtributos, {"29333999", "ATT_361", "45"})
    aAdd(aAtributos, {"29333999", "ATT_361", "44"})
    aAdd(aAtributos, {"29333999", "ATT_361", "43"})
    aAdd(aAtributos, {"29333999", "ATT_361", "42"})
    aAdd(aAtributos, {"29333999", "ATT_361", "41"})
    aAdd(aAtributos, {"29333999", "ATT_361", "40"})
    aAdd(aAtributos, {"29333999", "ATT_361", "39"})
    aAdd(aAtributos, {"29333999", "ATT_361", "38"})
    aAdd(aAtributos, {"29333999", "ATT_361", "37"})
    aAdd(aAtributos, {"29333999", "ATT_361", "35"})
    aAdd(aAtributos, {"29333999", "ATT_361", "34"})
    aAdd(aAtributos, {"29333999", "ATT_361", "33"})
    aAdd(aAtributos, {"29333999", "ATT_361", "32"})
    aAdd(aAtributos, {"29333999", "ATT_361", "31"})
    aAdd(aAtributos, {"29333999", "ATT_361", "30"})
    aAdd(aAtributos, {"29333999", "ATT_361", "29"})
    aAdd(aAtributos, {"29333999", "ATT_361", "28"})
    aAdd(aAtributos, {"29333999", "ATT_361", "27"})
    aAdd(aAtributos, {"29333999", "ATT_361", "26"})
    aAdd(aAtributos, {"29333999", "ATT_361", "25"})
    aAdd(aAtributos, {"29333999", "ATT_361", "24"})
    aAdd(aAtributos, {"29333999", "ATT_361", "23"})
    aAdd(aAtributos, {"29333999", "ATT_361", "22"})
    aAdd(aAtributos, {"29333999", "ATT_361", "21"})
    aAdd(aAtributos, {"29333999", "ATT_361", "20"})
    aAdd(aAtributos, {"29333999", "ATT_361", "19"})
    aAdd(aAtributos, {"29333999", "ATT_361", "18"})
    aAdd(aAtributos, {"29333999", "ATT_361", "17"})
    aAdd(aAtributos, {"29333999", "ATT_361", "16"})
    aAdd(aAtributos, {"29333999", "ATT_361", "15"})
    aAdd(aAtributos, {"29333999", "ATT_361", "14"})
    aAdd(aAtributos, {"29333999", "ATT_361", "13"})
    aAdd(aAtributos, {"29333999", "ATT_361", "12"})
    aAdd(aAtributos, {"29333999", "ATT_361", "11"})
    aAdd(aAtributos, {"29333999", "ATT_361", "10"})
    aAdd(aAtributos, {"29333999", "ATT_361", "09"})
    aAdd(aAtributos, {"29333999", "ATT_361", "08"})
    aAdd(aAtributos, {"29333999", "ATT_361", "07"})
    aAdd(aAtributos, {"29333999", "ATT_361", "06"})
    aAdd(aAtributos, {"29333999", "ATT_361", "05"})
    aAdd(aAtributos, {"29333999", "ATT_361", "04"})
    aAdd(aAtributos, {"29333999", "ATT_361", "03"})
    aAdd(aAtributos, {"29333999", "ATT_361", "99"})
    aAdd(aAtributos, {"29333999", "ATT_361", "01"})
    aAdd(aAtributos, {"29333999", "ATT_361", "36"})
    aAdd(aAtributos, {"29333999", "ATT_361", "98"})
    aAdd(aAtributos, {"29334110", "ATT_1416", "01"})
    aAdd(aAtributos, {"29334110", "ATT_1416", "02"})
    aAdd(aAtributos, {"29334120", "ATT_1416", "01"})
    aAdd(aAtributos, {"29334120", "ATT_1416", "02"})
    aAdd(aAtributos, {"29334940", "ATT_1416", "01"})
    aAdd(aAtributos, {"29334940", "ATT_1416", "02"})
    aAdd(aAtributos, {"29334990", "ATT_362", "01"})
    aAdd(aAtributos, {"29334990", "ATT_362", "03"})
    aAdd(aAtributos, {"29334990", "ATT_362", "04"})
    aAdd(aAtributos, {"29334990", "ATT_362", "99"})
    aAdd(aAtributos, {"29334990", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335311", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335311", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335312", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335312", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335321", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335321", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335322", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335322", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335323", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335323", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335330", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335330", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335340", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335340", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335350", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335350", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335360", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335360", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335371", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335371", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335372", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335372", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335380", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335380", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335400", "ATT_363", "01"})
    aAdd(aAtributos, {"29335400", "ATT_363", "99"})
    aAdd(aAtributos, {"29335400", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335510", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335510", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335520", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335520", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335530", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335530", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335540", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335540", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335916", "ATT_1416", "01"})
    aAdd(aAtributos, {"29335916", "ATT_1416", "02"})
    aAdd(aAtributos, {"29335919", "ATT_364", "01"})
    aAdd(aAtributos, {"29335919", "ATT_364", "99"})
    aAdd(aAtributos, {"29335919", "ATT_364", "02"})
    aAdd(aAtributos, {"29335919", "ATT_364", "98"})
    aAdd(aAtributos, {"29335929", "ATT_365", "01"})
    aAdd(aAtributos, {"29335939", "ATT_366", "01"})
    aAdd(aAtributos, {"29335939", "ATT_366", "02"})
    aAdd(aAtributos, {"29335939", "ATT_366", "03"})
    aAdd(aAtributos, {"29335939", "ATT_366", "04"})
    aAdd(aAtributos, {"29335939", "ATT_366", "05"})
    aAdd(aAtributos, {"29335939", "ATT_366", "99"})
    aAdd(aAtributos, {"29335949", "ATT_367", "01"})
    aAdd(aAtributos, {"29335949", "ATT_367", "02"})
    aAdd(aAtributos, {"29335949", "ATT_367", "03"})
    aAdd(aAtributos, {"29335949", "ATT_367", "99"})
    aAdd(aAtributos, {"29335999", "ATT_368", "01"})
    aAdd(aAtributos, {"29335999", "ATT_368", "02"})
    aAdd(aAtributos, {"29335999", "ATT_368", "99"})
    aAdd(aAtributos, {"29336919", "ATT_369", "01"})
    aAdd(aAtributos, {"29336919", "ATT_369", "99"})
    aAdd(aAtributos, {"29336919", "ATT_1416", "02"})
    aAdd(aAtributos, {"29336929", "ATT_370", "01"})
    aAdd(aAtributos, {"29336929", "ATT_370", "02"})
    aAdd(aAtributos, {"29336929", "ATT_370", "99"})
    aAdd(aAtributos, {"29337210", "ATT_1416", "01"})
    aAdd(aAtributos, {"29337210", "ATT_1416", "02"})
    aAdd(aAtributos, {"29337220", "ATT_1416", "01"})
    aAdd(aAtributos, {"29337220", "ATT_1416", "02"})
    aAdd(aAtributos, {"29337990", "ATT_372", "01"})
    aAdd(aAtributos, {"29337990", "ATT_372", "02"})
    aAdd(aAtributos, {"29337990", "ATT_372", "03"})
    aAdd(aAtributos, {"29337990", "ATT_372", "04"})
    aAdd(aAtributos, {"29337990", "ATT_372", "99"})
    aAdd(aAtributos, {"29339111", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339111", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339112", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339112", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339113", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339113", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339114", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339114", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339115", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339115", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339119", "ATT_373", "01"})
    aAdd(aAtributos, {"29339119", "ATT_373", "99"})
    aAdd(aAtributos, {"29339119", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339121", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339121", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339122", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339122", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339123", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339123", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339129", "ATT_374", "01"})
    aAdd(aAtributos, {"29339129", "ATT_374", "99"})
    aAdd(aAtributos, {"29339129", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339131", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339131", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339132", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339132", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339133", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339133", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339134", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339134", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339139", "ATT_375", "01"})
    aAdd(aAtributos, {"29339139", "ATT_375", "99"})
    aAdd(aAtributos, {"29339139", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339141", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339141", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339142", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339142", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339143", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339143", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339149", "ATT_376", "01"})
    aAdd(aAtributos, {"29339149", "ATT_376", "99"})
    aAdd(aAtributos, {"29339149", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339151", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339151", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339152", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339152", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339153", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339153", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339159", "ATT_377", "01"})
    aAdd(aAtributos, {"29339159", "ATT_377", "99"})
    aAdd(aAtributos, {"29339159", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339161", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339161", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339162", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339162", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339163", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339163", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339164", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339164", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339169", "ATT_378", "01"})
    aAdd(aAtributos, {"29339169", "ATT_378", "99"})
    aAdd(aAtributos, {"29339169", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339171", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339171", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339172", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339172", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339173", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339173", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339179", "ATT_379", "01"})
    aAdd(aAtributos, {"29339179", "ATT_379", "99"})
    aAdd(aAtributos, {"29339179", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339181", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339181", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339182", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339182", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339183", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339183", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339189", "ATT_380", "01"})
    aAdd(aAtributos, {"29339189", "ATT_380", "99"})
    aAdd(aAtributos, {"29339189", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339200", "ATT_381", "01"})
    aAdd(aAtributos, {"29339200", "ATT_381", "99"})
    aAdd(aAtributos, {"29339200", "ATT_381", "03"})
    aAdd(aAtributos, {"29339200", "ATT_381", "10"})
    aAdd(aAtributos, {"29339200", "ATT_381", "11"})
    aAdd(aAtributos, {"29339200", "ATT_381", "12"})
    aAdd(aAtributos, {"29339200", "ATT_381", "15"})
    aAdd(aAtributos, {"29339200", "ATT_381", "02"})
    aAdd(aAtributos, {"29339919", "ATT_382", "01"})
    aAdd(aAtributos, {"29339919", "ATT_382", "99"})
    aAdd(aAtributos, {"29339919", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339920", "ATT_383", "01"})
    aAdd(aAtributos, {"29339920", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339932", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339932", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339933", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339933", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339939", "ATT_384", "01"})
    aAdd(aAtributos, {"29339939", "ATT_384", "99"})
    aAdd(aAtributos, {"29339939", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339942", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339942", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339943", "ATT_1416", "01"})
    aAdd(aAtributos, {"29339943", "ATT_1416", "02"})
    aAdd(aAtributos, {"29339949", "ATT_385", "99"})
    aAdd(aAtributos, {"29339949", "ATT_385", "01"})
    aAdd(aAtributos, {"29339949", "ATT_385", "02"})
    aAdd(aAtributos, {"29339949", "ATT_385", "03"})
    aAdd(aAtributos, {"29339999", "ATT_386", "01"})
    aAdd(aAtributos, {"29339999", "ATT_386", "15"})
    aAdd(aAtributos, {"29339999", "ATT_386", "03"})
    aAdd(aAtributos, {"29339999", "ATT_386", "10"})
    aAdd(aAtributos, {"29339999", "ATT_386", "11"})
    aAdd(aAtributos, {"29339999", "ATT_386", "12"})
    aAdd(aAtributos, {"29339999", "ATT_386", "14"})
    aAdd(aAtributos, {"29339999", "ATT_386", "99"})
    aAdd(aAtributos, {"29339999", "ATT_386", "02"})
    aAdd(aAtributos, {"29341090", "ATT_387", "01"})
    aAdd(aAtributos, {"29341090", "ATT_387", "02"})
    aAdd(aAtributos, {"29341090", "ATT_387", "04"})
    aAdd(aAtributos, {"29341090", "ATT_387", "99"})
    aAdd(aAtributos, {"29342090", "ATT_388", "01"})
    aAdd(aAtributos, {"29342090", "ATT_388", "99"})
    aAdd(aAtributos, {"29342090", "ATT_1416", "02"})
    aAdd(aAtributos, {"29343010", "ATT_1416", "01"})
    aAdd(aAtributos, {"29343010", "ATT_1416", "02"})
    aAdd(aAtributos, {"29343020", "ATT_1416", "01"})
    aAdd(aAtributos, {"29343020", "ATT_1416", "02"})
    aAdd(aAtributos, {"29343090", "ATT_389", "01"})
    aAdd(aAtributos, {"29343090", "ATT_389", "99"})
    aAdd(aAtributos, {"29343090", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349111", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349111", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349112", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349112", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349121", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349121", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349122", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349122", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349123", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349123", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349129", "ATT_390", "01"})
    aAdd(aAtributos, {"29349129", "ATT_390", "99"})
    aAdd(aAtributos, {"29349129", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349131", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349131", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349132", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349132", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349133", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349133", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349141", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349141", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349142", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349142", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349149", "ATT_391", "01"})
    aAdd(aAtributos, {"29349149", "ATT_391", "99"})
    aAdd(aAtributos, {"29349149", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349150", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349150", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349160", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349160", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349170", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349170", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349919", "ATT_1416", "01"})
    aAdd(aAtributos, {"29349919", "ATT_1416", "02"})
    aAdd(aAtributos, {"29349939", "ATT_393", "01"})
    aAdd(aAtributos, {"29349939", "ATT_393", "02"})
    aAdd(aAtributos, {"29349939", "ATT_393", "03"})
    aAdd(aAtributos, {"29349939", "ATT_393", "04"})
    aAdd(aAtributos, {"29349939", "ATT_393", "05"})
    aAdd(aAtributos, {"29349939", "ATT_393", "99"})
    aAdd(aAtributos, {"29349949", "ATT_394", "01"})
    aAdd(aAtributos, {"29349949", "ATT_394", "02"})
    aAdd(aAtributos, {"29349949", "ATT_394", "03"})
    aAdd(aAtributos, {"29349949", "ATT_394", "99"})
    aAdd(aAtributos, {"29349952", "ATT_3278", "01"})
    aAdd(aAtributos, {"29349952", "ATT_3278", "99"})
    aAdd(aAtributos, {"29349953", "ATT_3278", "01"})
    aAdd(aAtributos, {"29349953", "ATT_3278", "99"})
    aAdd(aAtributos, {"29349969", "ATT_395", "01"})
    aAdd(aAtributos, {"29349969", "ATT_395", "02"})
    aAdd(aAtributos, {"29349969", "ATT_395", "03"})
    aAdd(aAtributos, {"29349969", "ATT_395", "99"})
    aAdd(aAtributos, {"29349999", "ATT_396", "02"})
    aAdd(aAtributos, {"29349999", "ATT_396", "46"})
    aAdd(aAtributos, {"29349999", "ATT_396", "45"})
    aAdd(aAtributos, {"29349999", "ATT_396", "44"})
    aAdd(aAtributos, {"29349999", "ATT_396", "43"})
    aAdd(aAtributos, {"29349999", "ATT_396", "42"})
    aAdd(aAtributos, {"29349999", "ATT_396", "41"})
    aAdd(aAtributos, {"29349999", "ATT_396", "40"})
    aAdd(aAtributos, {"29349999", "ATT_396", "39"})
    aAdd(aAtributos, {"29349999", "ATT_396", "38"})
    aAdd(aAtributos, {"29349999", "ATT_396", "37"})
    aAdd(aAtributos, {"29349999", "ATT_396", "36"})
    aAdd(aAtributos, {"29349999", "ATT_396", "35"})
    aAdd(aAtributos, {"29349999", "ATT_396", "34"})
    aAdd(aAtributos, {"29349999", "ATT_396", "33"})
    aAdd(aAtributos, {"29349999", "ATT_396", "32"})
    aAdd(aAtributos, {"29349999", "ATT_396", "31"})
    aAdd(aAtributos, {"29349999", "ATT_396", "30"})
    aAdd(aAtributos, {"29349999", "ATT_396", "29"})
    aAdd(aAtributos, {"29349999", "ATT_396", "28"})
    aAdd(aAtributos, {"29349999", "ATT_396", "27"})
    aAdd(aAtributos, {"29349999", "ATT_396", "26"})
    aAdd(aAtributos, {"29349999", "ATT_396", "25"})
    aAdd(aAtributos, {"29349999", "ATT_396", "24"})
    aAdd(aAtributos, {"29349999", "ATT_396", "23"})
    aAdd(aAtributos, {"29349999", "ATT_396", "22"})
    aAdd(aAtributos, {"29349999", "ATT_396", "21"})
    aAdd(aAtributos, {"29349999", "ATT_396", "20"})
    aAdd(aAtributos, {"29349999", "ATT_396", "19"})
    aAdd(aAtributos, {"29349999", "ATT_396", "18"})
    aAdd(aAtributos, {"29349999", "ATT_396", "17"})
    aAdd(aAtributos, {"29349999", "ATT_396", "16"})
    aAdd(aAtributos, {"29349999", "ATT_396", "15"})
    aAdd(aAtributos, {"29349999", "ATT_396", "14"})
    aAdd(aAtributos, {"29349999", "ATT_396", "13"})
    aAdd(aAtributos, {"29349999", "ATT_396", "12"})
    aAdd(aAtributos, {"29349999", "ATT_396", "11"})
    aAdd(aAtributos, {"29349999", "ATT_396", "10"})
    aAdd(aAtributos, {"29349999", "ATT_396", "09"})
    aAdd(aAtributos, {"29349999", "ATT_396", "08"})
    aAdd(aAtributos, {"29349999", "ATT_396", "07"})
    aAdd(aAtributos, {"29349999", "ATT_396", "06"})
    aAdd(aAtributos, {"29349999", "ATT_396", "05"})
    aAdd(aAtributos, {"29349999", "ATT_396", "04"})
    aAdd(aAtributos, {"29349999", "ATT_396", "03"})
    aAdd(aAtributos, {"29349999", "ATT_396", "99"})
    aAdd(aAtributos, {"29349999", "ATT_396", "01"})
    aAdd(aAtributos, {"29349999", "ATT_396", "48"})
    aAdd(aAtributos, {"29349999", "ATT_396", "98"})
    aAdd(aAtributos, {"29351000", "ATT_397", "01"})
    aAdd(aAtributos, {"29351000", "ATT_397", "03"})
    aAdd(aAtributos, {"29351000", "ATT_397", "04"})
    aAdd(aAtributos, {"29351000", "ATT_397", "07"})
    aAdd(aAtributos, {"29351000", "ATT_397", "99"})
    aAdd(aAtributos, {"29352000", "ATT_398", "01"})
    aAdd(aAtributos, {"29352000", "ATT_398", "03"})
    aAdd(aAtributos, {"29352000", "ATT_398", "04"})
    aAdd(aAtributos, {"29352000", "ATT_398", "07"})
    aAdd(aAtributos, {"29352000", "ATT_398", "99"})
    aAdd(aAtributos, {"29353000", "ATT_399", "01"})
    aAdd(aAtributos, {"29353000", "ATT_399", "03"})
    aAdd(aAtributos, {"29353000", "ATT_399", "04"})
    aAdd(aAtributos, {"29353000", "ATT_399", "07"})
    aAdd(aAtributos, {"29353000", "ATT_399", "99"})
    aAdd(aAtributos, {"29354000", "ATT_400", "01"})
    aAdd(aAtributos, {"29354000", "ATT_400", "03"})
    aAdd(aAtributos, {"29354000", "ATT_400", "04"})
    aAdd(aAtributos, {"29354000", "ATT_400", "07"})
    aAdd(aAtributos, {"29354000", "ATT_400", "99"})
    aAdd(aAtributos, {"29355000", "ATT_401", "01"})
    aAdd(aAtributos, {"29355000", "ATT_401", "03"})
    aAdd(aAtributos, {"29355000", "ATT_401", "04"})
    aAdd(aAtributos, {"29355000", "ATT_401", "07"})
    aAdd(aAtributos, {"29355000", "ATT_401", "99"})
    aAdd(aAtributos, {"29359019", "ATT_402", "01"})
    aAdd(aAtributos, {"29359019", "ATT_402", "02"})
    aAdd(aAtributos, {"29359019", "ATT_402", "03"})
    aAdd(aAtributos, {"29359019", "ATT_402", "04"})
    aAdd(aAtributos, {"29359019", "ATT_402", "99"})
    aAdd(aAtributos, {"29359099", "ATT_404", "01"})
    aAdd(aAtributos, {"29359099", "ATT_404", "03"})
    aAdd(aAtributos, {"29359099", "ATT_404", "04"})
    aAdd(aAtributos, {"29359099", "ATT_404", "07"})
    aAdd(aAtributos, {"29359099", "ATT_404", "99"})
    aAdd(aAtributos, {"29362190", "ATT_406", "01"})
    aAdd(aAtributos, {"29362190", "ATT_406", "02"})
    aAdd(aAtributos, {"29362190", "ATT_406", "03"})
    aAdd(aAtributos, {"29362190", "ATT_406", "04"})
    aAdd(aAtributos, {"29362190", "ATT_406", "05"})
    aAdd(aAtributos, {"29362190", "ATT_406", "99"})
    aAdd(aAtributos, {"29371100", "ATT_1416", "01"})
    aAdd(aAtributos, {"29371100", "ATT_1416", "02"})
    aAdd(aAtributos, {"29372399", "ATT_407", "01"})
    aAdd(aAtributos, {"29372399", "ATT_407", "99"})
    aAdd(aAtributos, {"29372399", "ATT_1416", "02"})
    aAdd(aAtributos, {"29372940", "ATT_1416", "01"})
    aAdd(aAtributos, {"29372940", "ATT_1416", "02"})
    aAdd(aAtributos, {"29372990", "ATT_408", "01"})
    aAdd(aAtributos, {"29372990", "ATT_408", "99"})
    aAdd(aAtributos, {"29372990", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391110", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391110", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391121", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391121", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391122", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391122", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391123", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391123", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391131", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391131", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391132", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391132", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391140", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391140", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391151", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391151", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391152", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391152", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391153", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391153", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391161", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391161", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391162", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391162", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391169", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391169", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391170", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391170", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391181", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391181", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391182", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391182", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391191", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391191", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391192", "ATT_1416", "01"})
    aAdd(aAtributos, {"29391192", "ATT_1416", "02"})
    aAdd(aAtributos, {"29391900", "ATT_409", "05"})
    aAdd(aAtributos, {"29391900", "ATT_409", "99"})
    aAdd(aAtributos, {"29391900", "ATT_409", "07"})
    aAdd(aAtributos, {"29391900", "ATT_409", "01"})
    aAdd(aAtributos, {"29391900", "ATT_409", "02"})
    aAdd(aAtributos, {"29391900", "ATT_409", "03"})
    aAdd(aAtributos, {"29391900", "ATT_409", "04"})
    aAdd(aAtributos, {"29391900", "ATT_409", "06"})
    aAdd(aAtributos, {"29393010", "ATT_3278", "01"})
    aAdd(aAtributos, {"29393010", "ATT_3278", "99"})
    aAdd(aAtributos, {"29394100", "ATT_1416", "02"})
    aAdd(aAtributos, {"29394100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29394100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29394200", "ATT_1416", "02"})
    aAdd(aAtributos, {"29394200", "ATT_3278", "01"})
    aAdd(aAtributos, {"29394200", "ATT_3278", "99"})
    aAdd(aAtributos, {"29394300", "ATT_1416", "01"})
    aAdd(aAtributos, {"29394300", "ATT_1416", "02"})
    aAdd(aAtributos, {"29394900", "ATT_411", "04"})
    aAdd(aAtributos, {"29394900", "ATT_411", "01"})
    aAdd(aAtributos, {"29394900", "ATT_411", "02"})
    aAdd(aAtributos, {"29394900", "ATT_411", "03"})
    aAdd(aAtributos, {"29394900", "ATT_411", "99"})
    aAdd(aAtributos, {"29394900", "ATT_411", "98"})
    aAdd(aAtributos, {"29395100", "ATT_1416", "01"})
    aAdd(aAtributos, {"29395100", "ATT_1416", "02"})
    aAdd(aAtributos, {"29395910", "ATT_3278", "01"})
    aAdd(aAtributos, {"29395910", "ATT_3278", "99"})
    aAdd(aAtributos, {"29395990", "ATT_413", "01"})
    aAdd(aAtributos, {"29395990", "ATT_413", "99"})
    aAdd(aAtributos, {"29395990", "ATT_1416", "02"})
    aAdd(aAtributos, {"29396100", "ATT_1416", "02"})
    aAdd(aAtributos, {"29396100", "ATT_3278", "01"})
    aAdd(aAtributos, {"29396100", "ATT_3278", "99"})
    aAdd(aAtributos, {"29396200", "ATT_1416", "02"})
    aAdd(aAtributos, {"29396200", "ATT_3278", "01"})
    aAdd(aAtributos, {"29396200", "ATT_3278", "99"})
    aAdd(aAtributos, {"29396300", "ATT_1416", "02"})
    aAdd(aAtributos, {"29396300", "ATT_3278", "01"})
    aAdd(aAtributos, {"29396300", "ATT_3278", "99"})
    aAdd(aAtributos, {"29396911", "ATT_414", "01"})
    aAdd(aAtributos, {"29396911", "ATT_414", "99"})
    aAdd(aAtributos, {"29396911", "ATT_414", "98"})
    aAdd(aAtributos, {"29396919", "ATT_415", "02"})
    aAdd(aAtributos, {"29396919", "ATT_415", "03"})
    aAdd(aAtributos, {"29396919", "ATT_415", "01"})
    aAdd(aAtributos, {"29396919", "ATT_415", "99"})
    aAdd(aAtributos, {"29396921", "ATT_1416", "01"})
    aAdd(aAtributos, {"29396921", "ATT_1416", "02"})
    aAdd(aAtributos, {"29396929", "ATT_416", "01"})
    aAdd(aAtributos, {"29396929", "ATT_416", "99"})
    aAdd(aAtributos, {"29396929", "ATT_1416", "02"})
    aAdd(aAtributos, {"29396990", "ATT_417", "01"})
    aAdd(aAtributos, {"29396990", "ATT_417", "02"})
    aAdd(aAtributos, {"29396990", "ATT_417", "03"})
    aAdd(aAtributos, {"29396990", "ATT_417", "99"})
    aAdd(aAtributos, {"29397111", "ATT_1416", "01"})
    aAdd(aAtributos, {"29397111", "ATT_1416", "02"})
    aAdd(aAtributos, {"29397112", "ATT_1416", "01"})
    aAdd(aAtributos, {"29397112", "ATT_1416", "02"})
    aAdd(aAtributos, {"29397119", "ATT_418", "01"})
    aAdd(aAtributos, {"29397119", "ATT_418", "99"})
    aAdd(aAtributos, {"29397119", "ATT_1416", "02"})
    aAdd(aAtributos, {"29397120", "ATT_1416", "01"})
    aAdd(aAtributos, {"29397120", "ATT_1416", "02"})
    aAdd(aAtributos, {"29397130", "ATT_1416", "01"})
    aAdd(aAtributos, {"29397130", "ATT_1416", "02"})
    aAdd(aAtributos, {"29397140", "ATT_1416", "01"})
    aAdd(aAtributos, {"29397140", "ATT_1416", "02"})
    aAdd(aAtributos, {"29397990", "ATT_419", "01"})
    aAdd(aAtributos, {"29397990", "ATT_419", "99"})
    aAdd(aAtributos, {"29397990", "ATT_1416", "02"})
    aAdd(aAtributos, {"30021100", "ATT_425", "01"})
    aAdd(aAtributos, {"30021100", "ATT_425", "02"})
    aAdd(aAtributos, {"30021100", "ATT_425", "99"})
    aAdd(aAtributos, {"30021100", "ATT_425", "04"})
    aAdd(aAtributos, {"30021100", "ATT_425", "03"})
    aAdd(aAtributos, {"30021229", "ATT_426", "01"})
    aAdd(aAtributos, {"30021229", "ATT_426", "02"})
    aAdd(aAtributos, {"30021229", "ATT_426", "03"})
    aAdd(aAtributos, {"30021229", "ATT_426", "04"})
    aAdd(aAtributos, {"30021229", "ATT_426", "99"})
    aAdd(aAtributos, {"30021300", "ATT_427", "01"})
    aAdd(aAtributos, {"30021300", "ATT_427", "02"})
    aAdd(aAtributos, {"30021300", "ATT_427", "03"})
    aAdd(aAtributos, {"30021300", "ATT_427", "04"})
    aAdd(aAtributos, {"30021300", "ATT_427", "99"})
    aAdd(aAtributos, {"30021900", "ATT_428", "01"})
    aAdd(aAtributos, {"30021900", "ATT_428", "02"})
    aAdd(aAtributos, {"30021900", "ATT_428", "03"})
    aAdd(aAtributos, {"30021900", "ATT_428", "04"})
    aAdd(aAtributos, {"30021900", "ATT_428", "99"})
    aAdd(aAtributos, {"30029099", "ATT_430", "02"})
    aAdd(aAtributos, {"30029099", "ATT_430", "99"})
    aAdd(aAtributos, {"30029099", "ATT_430", "01"})
    aAdd(aAtributos, {"30032099", "ATT_463", "01"})
    aAdd(aAtributos, {"30032099", "ATT_463", "99"})
    aAdd(aAtributos, {"30033911", "ATT_465", "01"})
    aAdd(aAtributos, {"30033911", "ATT_465", "99"})
    aAdd(aAtributos, {"30033911", "ATT_1416", "02"})
    aAdd(aAtributos, {"30033929", "ATT_481", "01"})
    aAdd(aAtributos, {"30033929", "ATT_481", "99"})
    aAdd(aAtributos, {"30033991", "ATT_492", "01"})
    aAdd(aAtributos, {"30033991", "ATT_492", "99"})
    aAdd(aAtributos, {"30034100", "ATT_497", "01"})
    aAdd(aAtributos, {"30034100", "ATT_497", "99"})
    aAdd(aAtributos, {"30034100", "ATT_1416", "02"})
    aAdd(aAtributos, {"30034200", "ATT_498", "01"})
    aAdd(aAtributos, {"30034200", "ATT_498", "99"})
    aAdd(aAtributos, {"30034200", "ATT_1416", "02"})
    aAdd(aAtributos, {"30034300", "ATT_499", "01"})
    aAdd(aAtributos, {"30034300", "ATT_499", "99"})
    aAdd(aAtributos, {"30034300", "ATT_1416", "02"})
    aAdd(aAtributos, {"30034940", "ATT_1416", "01"})
    aAdd(aAtributos, {"30034940", "ATT_1416", "02"})
    aAdd(aAtributos, {"30034990", "ATT_500", "01"})
    aAdd(aAtributos, {"30034990", "ATT_500", "99"})
    aAdd(aAtributos, {"30034990", "ATT_1416", "02"})
    aAdd(aAtributos, {"30036000", "ATT_501", "01"})
    aAdd(aAtributos, {"30036000", "ATT_501", "99"})
    aAdd(aAtributos, {"30039017", "ATT_508", "99"})
    aAdd(aAtributos, {"30039017", "ATT_508", "01"})
    aAdd(aAtributos, {"30039017", "ATT_1416", "02"})
    aAdd(aAtributos, {"30039038", "ATT_521", "01"})
    aAdd(aAtributos, {"30039038", "ATT_521", "99"})
    aAdd(aAtributos, {"30039038", "ATT_1416", "02"})
    aAdd(aAtributos, {"30039039", "ATT_522", "01"})
    aAdd(aAtributos, {"30039039", "ATT_522", "99"})
    aAdd(aAtributos, {"30039041", "ATT_1416", "01"})
    aAdd(aAtributos, {"30039041", "ATT_1416", "02"})
    aAdd(aAtributos, {"30039049", "ATT_529", "99"})
    aAdd(aAtributos, {"30039049", "ATT_529", "01"})
    aAdd(aAtributos, {"30039054", "ATT_1416", "01"})
    aAdd(aAtributos, {"30039054", "ATT_1416", "02"})
    aAdd(aAtributos, {"30039059", "ATT_537", "01"})
    aAdd(aAtributos, {"30039059", "ATT_537", "99"})
    aAdd(aAtributos, {"30039062", "ATT_1416", "01"})
    aAdd(aAtributos, {"30039062", "ATT_1416", "02"})
    aAdd(aAtributos, {"30039069", "ATT_544", "99"})
    aAdd(aAtributos, {"30039069", "ATT_544", "01"})
    aAdd(aAtributos, {"30039071", "ATT_545", "01"})
    aAdd(aAtributos, {"30039071", "ATT_545", "99"})
    aAdd(aAtributos, {"30039071", "ATT_1416", "02"})
    aAdd(aAtributos, {"30039074", "ATT_1416", "01"})
    aAdd(aAtributos, {"30039074", "ATT_1416", "02"})
    aAdd(aAtributos, {"30039079", "ATT_552", "99"})
    aAdd(aAtributos, {"30039079", "ATT_552", "01"})
    aAdd(aAtributos, {"30039085", "ATT_557", "99"})
    aAdd(aAtributos, {"30039085", "ATT_557", "01"})
    aAdd(aAtributos, {"30039085", "ATT_1416", "02"})
    aAdd(aAtributos, {"30039089", "ATT_561", "01"})
    aAdd(aAtributos, {"30039089", "ATT_561", "99"})
    aAdd(aAtributos, {"30039095", "ATT_566", "99"})
    aAdd(aAtributos, {"30039095", "ATT_566", "01"})
    aAdd(aAtributos, {"30039095", "ATT_1416", "02"})
    aAdd(aAtributos, {"30039099", "ATT_568", "01"})
    aAdd(aAtributos, {"30039099", "ATT_568", "99"})
    aAdd(aAtributos, {"30042099", "ATT_601", "99"})
    aAdd(aAtributos, {"30042099", "ATT_601", "01"})
    aAdd(aAtributos, {"30043290", "ATT_605", "99"})
    aAdd(aAtributos, {"30043290", "ATT_605", "01"})
    aAdd(aAtributos, {"30043911", "ATT_606", "99"})
    aAdd(aAtributos, {"30043911", "ATT_606", "01"})
    aAdd(aAtributos, {"30043929", "ATT_623", "99"})
    aAdd(aAtributos, {"30043929", "ATT_623", "01"})
    aAdd(aAtributos, {"30044100", "ATT_638", "99"})
    aAdd(aAtributos, {"30044100", "ATT_638", "01"})
    aAdd(aAtributos, {"30044100", "ATT_1416", "02"})
    aAdd(aAtributos, {"30044200", "ATT_639", "01"})
    aAdd(aAtributos, {"30044200", "ATT_639", "99"})
    aAdd(aAtributos, {"30044200", "ATT_1416", "02"})
    aAdd(aAtributos, {"30044940", "ATT_1416", "01"})
    aAdd(aAtributos, {"30044940", "ATT_1416", "02"})
    aAdd(aAtributos, {"30044990", "ATT_641", "01"})
    aAdd(aAtributos, {"30044990", "ATT_641", "99"})
    aAdd(aAtributos, {"30045060", "ATT_647", "99"})
    aAdd(aAtributos, {"30045060", "ATT_647", "01"})
    aAdd(aAtributos, {"30045060", "ATT_1416", "02"})
    aAdd(aAtributos, {"30045090", "ATT_648", "01"})
    aAdd(aAtributos, {"30045090", "ATT_648", "99"})
    aAdd(aAtributos, {"30046000", "ATT_649", "99"})
    aAdd(aAtributos, {"30046000", "ATT_649", "01"})
    aAdd(aAtributos, {"30049028", "ATT_661", "01"})
    aAdd(aAtributos, {"30049028", "ATT_661", "99"})
    aAdd(aAtributos, {"30049028", "ATT_1416", "02"})
    aAdd(aAtributos, {"30049029", "ATT_662", "99"})
    aAdd(aAtributos, {"30049029", "ATT_662", "01"})
    aAdd(aAtributos, {"30049031", "ATT_1416", "01"})
    aAdd(aAtributos, {"30049031", "ATT_1416", "02"})
    aAdd(aAtributos, {"30049039", "ATT_670", "99"})
    aAdd(aAtributos, {"30049039", "ATT_670", "01"})
    aAdd(aAtributos, {"30049044", "ATT_1416", "01"})
    aAdd(aAtributos, {"30049044", "ATT_1416", "02"})
    aAdd(aAtributos, {"30049052", "ATT_1416", "01"})
    aAdd(aAtributos, {"30049052", "ATT_1416", "02"})
    aAdd(aAtributos, {"30049059", "ATT_685", "01"})
    aAdd(aAtributos, {"30049059", "ATT_685", "99"})
    aAdd(aAtributos, {"30049061", "ATT_686", "01"})
    aAdd(aAtributos, {"30049061", "ATT_686", "99"})
    aAdd(aAtributos, {"30049064", "ATT_1416", "01"})
    aAdd(aAtributos, {"30049064", "ATT_1416", "02"})
    aAdd(aAtributos, {"30049068", "ATT_2878", "01"})
    aAdd(aAtributos, {"30049068", "ATT_2878", "99"})
    aAdd(aAtributos, {"30049069", "ATT_693", "01"})
    aAdd(aAtributos, {"30049069", "ATT_693", "99"})
    aAdd(aAtributos, {"30049075", "ATT_698", "99"})
    aAdd(aAtributos, {"30049075", "ATT_698", "01"})
    aAdd(aAtributos, {"30049075", "ATT_1416", "02"})
    aAdd(aAtributos, {"30049079", "ATT_702", "01"})
    aAdd(aAtributos, {"30049079", "ATT_702", "99"})
    aAdd(aAtributos, {"30049095", "ATT_707", "01"})
    aAdd(aAtributos, {"30049095", "ATT_707", "99"})
    aAdd(aAtributos, {"30049095", "ATT_1416", "02"})
    aAdd(aAtributos, {"30049099", "ATT_709", "01"})
    aAdd(aAtributos, {"30049099", "ATT_709", "99"})
    aAdd(aAtributos, {"31021010", "ATT_3278", "01"})
    aAdd(aAtributos, {"31021010", "ATT_3278", "99"})
    aAdd(aAtributos, {"31051000", "ATT_710", "01"})
    aAdd(aAtributos, {"31051000", "ATT_710", "99"})
    aAdd(aAtributos, {"31059090", "ATT_711", "01"})
    aAdd(aAtributos, {"31059090", "ATT_711", "99"})
    aAdd(aAtributos, {"32089039", "ATT_712", "01"})
    aAdd(aAtributos, {"32089039", "ATT_712", "02"})
    aAdd(aAtributos, {"32089039", "ATT_712", "99"})
    aAdd(aAtributos, {"33012912", "ATT_714", "01"})
    aAdd(aAtributos, {"33012912", "ATT_714", "99"})
    aAdd(aAtributos, {"33012913", "ATT_715", "01"})
    aAdd(aAtributos, {"33012913", "ATT_715", "99"})
    aAdd(aAtributos, {"33012916", "ATT_717", "01"})
    aAdd(aAtributos, {"33012916", "ATT_717", "99"})
    aAdd(aAtributos, {"33012990", "ATT_723", "04"})
    aAdd(aAtributos, {"33012990", "ATT_723", "05"})
    aAdd(aAtributos, {"33012990", "ATT_723", "99"})
    aAdd(aAtributos, {"33012990", "ATT_723", "03"})
    aAdd(aAtributos, {"33012990", "ATT_723", "01"})
    aAdd(aAtributos, {"33012990", "ATT_723", "02"})
    aAdd(aAtributos, {"33012990", "ATT_723", "98"})
    aAdd(aAtributos, {"34049029", "ATT_724", "01"})
    aAdd(aAtributos, {"34049029", "ATT_724", "99"})
    aAdd(aAtributos, {"35051000", "ATT_725", "01"})
    aAdd(aAtributos, {"35051000", "ATT_725", "99"})
    aAdd(aAtributos, {"36010000", "ATT_726", "01"})
    aAdd(aAtributos, {"36010000", "ATT_726", "99"})
    aAdd(aAtributos, {"36020000", "ATT_727", "01"})
    aAdd(aAtributos, {"36020000", "ATT_727", "03"})
    aAdd(aAtributos, {"36020000", "ATT_727", "04"})
    aAdd(aAtributos, {"36020000", "ATT_727", "05"})
    aAdd(aAtributos, {"36020000", "ATT_727", "06"})
    aAdd(aAtributos, {"36020000", "ATT_727", "99"})
    aAdd(aAtributos, {"36020000", "ATT_727", "02"})
    aAdd(aAtributos, {"36030060", "ATT_1635", "02"})
    aAdd(aAtributos, {"36030060", "ATT_1635", "99"})
    aAdd(aAtributos, {"36030060", "ATT_1635", "04"})
    aAdd(aAtributos, {"36030060", "ATT_1635", "01"})
    aAdd(aAtributos, {"36030060", "ATT_1635", "03"})
    aAdd(aAtributos, {"36069000", "ATT_729", "01"})
    aAdd(aAtributos, {"36069000", "ATT_729", "99"})
    aAdd(aAtributos, {"38011000", "ATT_730", "01"})
    aAdd(aAtributos, {"38011000", "ATT_730", "99"})
    aAdd(aAtributos, {"38021000", "ATT_3278", "01"})
    aAdd(aAtributos, {"38021000", "ATT_3278", "99"})
    aAdd(aAtributos, {"38140010", "ATT_731", "01"})
    aAdd(aAtributos, {"38140010", "ATT_731", "02"})
    aAdd(aAtributos, {"38140010", "ATT_731", "99"})
    aAdd(aAtributos, {"38140020", "ATT_732", "01"})
    aAdd(aAtributos, {"38140020", "ATT_732", "02"})
    aAdd(aAtributos, {"38140020", "ATT_732", "99"})
    aAdd(aAtributos, {"38140030", "ATT_733", "01"})
    aAdd(aAtributos, {"38140030", "ATT_733", "02"})
    aAdd(aAtributos, {"38140030", "ATT_733", "99"})
    aAdd(aAtributos, {"38140090", "ATT_734", "02"})
    aAdd(aAtributos, {"38140090", "ATT_734", "99"})
    aAdd(aAtributos, {"38140090", "ATT_734", "01"})
    aAdd(aAtributos, {"38140090", "ATT_734", "03"})
    aAdd(aAtributos, {"38140090", "ATT_734", "98"})
    aAdd(aAtributos, {"38151220", "ATT_735", "01"})
    aAdd(aAtributos, {"38151220", "ATT_735", "02"})
    aAdd(aAtributos, {"38151220", "ATT_735", "99"})
    aAdd(aAtributos, {"38151290", "ATT_736", "01"})
    aAdd(aAtributos, {"38151290", "ATT_736", "02"})
    aAdd(aAtributos, {"38151290", "ATT_736", "99"})
    aAdd(aAtributos, {"38248400", "ATT_737", "01"})
    aAdd(aAtributos, {"38248400", "ATT_737", "02"})
    aAdd(aAtributos, {"38248400", "ATT_737", "09"})
    aAdd(aAtributos, {"38248400", "ATT_737", "99"})
    aAdd(aAtributos, {"38248500", "ATT_738", "01"})
    aAdd(aAtributos, {"38248500", "ATT_738", "02"})
    aAdd(aAtributos, {"38248500", "ATT_738", "09"})
    aAdd(aAtributos, {"38248500", "ATT_738", "99"})
    aAdd(aAtributos, {"38248600", "ATT_739", "01"})
    aAdd(aAtributos, {"38248600", "ATT_739", "02"})
    aAdd(aAtributos, {"38248600", "ATT_739", "06"})
    aAdd(aAtributos, {"38248600", "ATT_739", "99"})
    aAdd(aAtributos, {"38248700", "ATT_740", "01"})
    aAdd(aAtributos, {"38248700", "ATT_740", "02"})
    aAdd(aAtributos, {"38248700", "ATT_740", "09"})
    aAdd(aAtributos, {"38248700", "ATT_740", "99"})
    aAdd(aAtributos, {"38248800", "ATT_741", "01"})
    aAdd(aAtributos, {"38248800", "ATT_741", "02"})
    aAdd(aAtributos, {"38248800", "ATT_741", "09"})
    aAdd(aAtributos, {"38248800", "ATT_741", "99"})
    aAdd(aAtributos, {"38249100", "ATT_742", "01"})
    aAdd(aAtributos, {"38249100", "ATT_742", "02"})
    aAdd(aAtributos, {"38249100", "ATT_742", "09"})
    aAdd(aAtributos, {"38249100", "ATT_742", "99"})
    aAdd(aAtributos, {"38249972", "ATT_743", "99"})
    aAdd(aAtributos, {"38249972", "ATT_743", "01"})
    aAdd(aAtributos, {"38249989", "ATT_744", "02"})
    aAdd(aAtributos, {"38249989", "ATT_744", "09"})
    aAdd(aAtributos, {"38249989", "ATT_744", "99"})
    aAdd(aAtributos, {"38249989", "ATT_744", "01"})
    aAdd(aAtributos, {"38249989", "ATT_744", "03"})
    aAdd(aAtributos, {"38260000", "ATT_745", "01"})
    aAdd(aAtributos, {"38260000", "ATT_745", "99"})
    aAdd(aAtributos, {"39029000", "ATT_746", "01"})
    aAdd(aAtributos, {"39029000", "ATT_746", "99"})
    aAdd(aAtributos, {"39219012", "ATT_747", "01"})
    aAdd(aAtributos, {"39219012", "ATT_747", "99"})
    aAdd(aAtributos, {"39219013", "ATT_1695", "99"})
    aAdd(aAtributos, {"39219013", "ATT_1695", "01"})
    aAdd(aAtributos, {"39219019", "ATT_748", "01"})
    aAdd(aAtributos, {"39219019", "ATT_748", "99"})
    aAdd(aAtributos, {"39269090", "ATT_749", "01"})
    aAdd(aAtributos, {"39269090", "ATT_749", "99"})
    aAdd(aAtributos, {"40025100", "ATT_750", "01"})
    aAdd(aAtributos, {"40025100", "ATT_750", "02"})
    aAdd(aAtributos, {"40025100", "ATT_750", "99"})
    aAdd(aAtributos, {"40025900", "ATT_751", "01"})
    aAdd(aAtributos, {"40025900", "ATT_751", "02"})
    aAdd(aAtributos, {"40025900", "ATT_751", "99"})
    aAdd(aAtributos, {"41069200", "ATT_757", "01"})
    aAdd(aAtributos, {"41069200", "ATT_757", "99"})
    aAdd(aAtributos, {"41139000", "ATT_759", "01"})
    aAdd(aAtributos, {"41139000", "ATT_759", "99"})
    aAdd(aAtributos, {"41142020", "ATT_762", "01"})
    aAdd(aAtributos, {"41142020", "ATT_762", "99"})
    aAdd(aAtributos, {"44011100", "ATT_796", "01"})
    aAdd(aAtributos, {"44011100", "ATT_796", "99"})
    aAdd(aAtributos, {"44011200", "ATT_797", "01"})
    aAdd(aAtributos, {"44011200", "ATT_797", "99"})
    aAdd(aAtributos, {"44012100", "ATT_798", "01"})
    aAdd(aAtributos, {"44012100", "ATT_798", "99"})
    aAdd(aAtributos, {"44012200", "ATT_799", "01"})
    aAdd(aAtributos, {"44012200", "ATT_799", "99"})
    aAdd(aAtributos, {"44021000", "ATT_2057", "001"})
    aAdd(aAtributos, {"44021000", "ATT_2057", "999"})
    aAdd(aAtributos, {"44029000", "ATT_2057", "001"})
    aAdd(aAtributos, {"44029000", "ATT_2057", "999"})
    aAdd(aAtributos, {"44031100", "ATT_802", "02"})
    aAdd(aAtributos, {"44031100", "ATT_802", "01"})
    aAdd(aAtributos, {"44031100", "ATT_802", "99"})
    aAdd(aAtributos, {"44031200", "ATT_803", "02"})
    aAdd(aAtributos, {"44031200", "ATT_803", "01"})
    aAdd(aAtributos, {"44031200", "ATT_803", "99"})
    aAdd(aAtributos, {"44032500", "ATT_808", "02"})
    aAdd(aAtributos, {"44032500", "ATT_808", "01"})
    aAdd(aAtributos, {"44032500", "ATT_808", "99"})
    aAdd(aAtributos, {"44032600", "ATT_809", "02"})
    aAdd(aAtributos, {"44032600", "ATT_809", "01"})
    aAdd(aAtributos, {"44032600", "ATT_809", "99"})
    aAdd(aAtributos, {"44034900", "ATT_810", "02"})
    aAdd(aAtributos, {"44034900", "ATT_810", "01"})
    aAdd(aAtributos, {"44034900", "ATT_810", "99"})
    aAdd(aAtributos, {"44039900", "ATT_816", "01"})
    aAdd(aAtributos, {"44039900", "ATT_816", "02"})
    aAdd(aAtributos, {"44039900", "ATT_816", "99"})
    aAdd(aAtributos, {"44041000", "ATT_817", "01"})
    aAdd(aAtributos, {"44041000", "ATT_817", "99"})
    aAdd(aAtributos, {"44042000", "ATT_818", "01"})
    aAdd(aAtributos, {"44042000", "ATT_818", "99"})
    aAdd(aAtributos, {"44061100", "ATT_819", "01"})
    aAdd(aAtributos, {"44061100", "ATT_819", "99"})
    aAdd(aAtributos, {"44061200", "ATT_820", "01"})
    aAdd(aAtributos, {"44061200", "ATT_820", "99"})
    aAdd(aAtributos, {"44069100", "ATT_821", "01"})
    aAdd(aAtributos, {"44069100", "ATT_821", "99"})
    aAdd(aAtributos, {"44069200", "ATT_822", "01"})
    aAdd(aAtributos, {"44069200", "ATT_822", "99"})
    aAdd(aAtributos, {"44071900", "ATT_825", "01"})
    aAdd(aAtributos, {"44071900", "ATT_825", "02"})
    aAdd(aAtributos, {"44071900", "ATT_825", "99"})
    aAdd(aAtributos, {"44072200", "ATT_1368", "99"})
    aAdd(aAtributos, {"44072200", "ATT_1368", "02"})
    aAdd(aAtributos, {"44072920", "ATT_834", "01"})
    aAdd(aAtributos, {"44072920", "ATT_834", "99"})
    aAdd(aAtributos, {"44072930", "ATT_835", "01"})
    aAdd(aAtributos, {"44072930", "ATT_835", "99"})
    aAdd(aAtributos, {"44072940", "ATT_836", "99"})
    aAdd(aAtributos, {"44072940", "ATT_836", "01"})
    aAdd(aAtributos, {"44072950", "ATT_837", "01"})
    aAdd(aAtributos, {"44072950", "ATT_837", "99"})
    aAdd(aAtributos, {"44072960", "ATT_838", "01"})
    aAdd(aAtributos, {"44072960", "ATT_838", "99"})
    aAdd(aAtributos, {"44072970", "ATT_839", "01"})
    aAdd(aAtributos, {"44072970", "ATT_839", "99"})
    aAdd(aAtributos, {"44072990", "ATT_1369", "99"})
    aAdd(aAtributos, {"44072990", "ATT_1369", "01"})
    aAdd(aAtributos, {"44072990", "ATT_1369", "02"})
    aAdd(aAtributos, {"44079920", "ATT_849", "01"})
    aAdd(aAtributos, {"44079920", "ATT_849", "99"})
    aAdd(aAtributos, {"44079930", "ATT_850", "01"})
    aAdd(aAtributos, {"44079930", "ATT_850", "99"})
    aAdd(aAtributos, {"44079960", "ATT_851", "01"})
    aAdd(aAtributos, {"44079960", "ATT_851", "99"})
    aAdd(aAtributos, {"44079970", "ATT_852", "01"})
    aAdd(aAtributos, {"44079970", "ATT_852", "99"})
    aAdd(aAtributos, {"44079990", "ATT_853", "02"})
    aAdd(aAtributos, {"44079990", "ATT_853", "01"})
    aAdd(aAtributos, {"44079990", "ATT_853", "99"})
    aAdd(aAtributos, {"44081099", "ATT_854", "01"})
    aAdd(aAtributos, {"44081099", "ATT_854", "99"})
    aAdd(aAtributos, {"44083910", "ATT_1370", "99"})
    aAdd(aAtributos, {"44083910", "ATT_1370", "01"})
    aAdd(aAtributos, {"44083991", "ATT_856", "01"})
    aAdd(aAtributos, {"44083999", "ATT_857", "01"})
    aAdd(aAtributos, {"44083999", "ATT_857", "99"})
    aAdd(aAtributos, {"44089010", "ATT_858", "01"})
    aAdd(aAtributos, {"44089010", "ATT_858", "99"})
    aAdd(aAtributos, {"44089090", "ATT_859", "01"})
    aAdd(aAtributos, {"44089090", "ATT_859", "99"})
    aAdd(aAtributos, {"44091000", "ATT_860", "01"})
    aAdd(aAtributos, {"44091000", "ATT_860", "99"})
    aAdd(aAtributos, {"44092200", "ATT_861", "01"})
    aAdd(aAtributos, {"44092200", "ATT_861", "99"})
    aAdd(aAtributos, {"44092900", "ATT_862", "01"})
    aAdd(aAtributos, {"44092900", "ATT_862", "99"})
    aAdd(aAtributos, {"44123100", "ATT_863", "99"})
    aAdd(aAtributos, {"44123100", "ATT_863", "01"})
    aAdd(aAtributos, {"44123300", "ATT_864", "01"})
    aAdd(aAtributos, {"44123300", "ATT_864", "99"})
    aAdd(aAtributos, {"44123400", "ATT_865", "99"})
    aAdd(aAtributos, {"44123400", "ATT_865", "01"})
    aAdd(aAtributos, {"44123900", "ATT_866", "01"})
    aAdd(aAtributos, {"44123900", "ATT_866", "99"})
    aAdd(aAtributos, {"44129400", "ATT_869", "99"})
    aAdd(aAtributos, {"44129400", "ATT_869", "01"})
    aAdd(aAtributos, {"44129900", "ATT_870", "99"})
    aAdd(aAtributos, {"44129900", "ATT_870", "02"})
    aAdd(aAtributos, {"44129900", "ATT_870", "01"})
    aAdd(aAtributos, {"44181000", "ATT_871", "01"})
    aAdd(aAtributos, {"44181000", "ATT_871", "99"})
    aAdd(aAtributos, {"44182000", "ATT_872", "01"})
    aAdd(aAtributos, {"44182000", "ATT_872", "99"})
    aAdd(aAtributos, {"44186000", "ATT_875", "99"})
    aAdd(aAtributos, {"44186000", "ATT_875", "01"})
    aAdd(aAtributos, {"44186000", "ATT_875", "02"})
    aAdd(aAtributos, {"44187900", "ATT_876", "99"})
    aAdd(aAtributos, {"44187900", "ATT_876", "01"})
    aAdd(aAtributos, {"44187900", "ATT_876", "02"})
    aAdd(aAtributos, {"44189900", "ATT_878", "99"})
    aAdd(aAtributos, {"44189900", "ATT_878", "01"})
    aAdd(aAtributos, {"54021100", "ATT_931", "01"})
    aAdd(aAtributos, {"54021100", "ATT_931", "02"})
    aAdd(aAtributos, {"54021100", "ATT_931", "99"})
    aAdd(aAtributos, {"54041990", "ATT_932", "01"})
    aAdd(aAtributos, {"54041990", "ATT_932", "02"})
    aAdd(aAtributos, {"54041990", "ATT_932", "99"})
    aAdd(aAtributos, {"54049000", "ATT_933", "01"})
    aAdd(aAtributos, {"54049000", "ATT_933", "02"})
    aAdd(aAtributos, {"54049000", "ATT_933", "99"})
    aAdd(aAtributos, {"55011000", "ATT_936", "01"})
    aAdd(aAtributos, {"55011000", "ATT_936", "02"})
    aAdd(aAtributos, {"55011000", "ATT_936", "99"})
    aAdd(aAtributos, {"55013000", "ATT_937", "01"})
    aAdd(aAtributos, {"55013000", "ATT_937", "99"})
    aAdd(aAtributos, {"55031100", "ATT_938", "01"})
    aAdd(aAtributos, {"55031100", "ATT_938", "02"})
    aAdd(aAtributos, {"55031100", "ATT_938", "99"})
    aAdd(aAtributos, {"55061000", "ATT_939", "01"})
    aAdd(aAtributos, {"55061000", "ATT_939", "02"})
    aAdd(aAtributos, {"55061000", "ATT_939", "99"})
    aAdd(aAtributos, {"55091100", "ATT_940", "01"})
    aAdd(aAtributos, {"55091100", "ATT_940", "02"})
    aAdd(aAtributos, {"55091100", "ATT_940", "99"})
    aAdd(aAtributos, {"55091210", "ATT_941", "01"})
    aAdd(aAtributos, {"55091210", "ATT_941", "02"})
    aAdd(aAtributos, {"55091210", "ATT_941", "99"})
    aAdd(aAtributos, {"56031310", "ATT_944", "01"})
    aAdd(aAtributos, {"56031310", "ATT_944", "02"})
    aAdd(aAtributos, {"56031310", "ATT_944", "99"})
    aAdd(aAtributos, {"56075019", "ATT_947", "01"})
    aAdd(aAtributos, {"56075019", "ATT_947", "02"})
    aAdd(aAtributos, {"56075019", "ATT_947", "99"})
    aAdd(aAtributos, {"57011011", "ATT_948", "99"})
    aAdd(aAtributos, {"57011011", "ATT_948", "01"})
    aAdd(aAtributos, {"57011012", "ATT_949", "01"})
    aAdd(aAtributos, {"57011012", "ATT_949", "99"})
    aAdd(aAtributos, {"57011020", "ATT_950", "01"})
    aAdd(aAtributos, {"57011020", "ATT_950", "99"})
    aAdd(aAtributos, {"57023100", "ATT_951", "01"})
    aAdd(aAtributos, {"57023100", "ATT_951", "99"})
    aAdd(aAtributos, {"57024100", "ATT_952", "01"})
    aAdd(aAtributos, {"57024100", "ATT_952", "99"})
    aAdd(aAtributos, {"57025010", "ATT_953", "01"})
    aAdd(aAtributos, {"57025010", "ATT_953", "99"})
    aAdd(aAtributos, {"57029100", "ATT_954", "01"})
    aAdd(aAtributos, {"57029100", "ATT_954", "99"})
    aAdd(aAtributos, {"57031000", "ATT_955", "01"})
    aAdd(aAtributos, {"57031000", "ATT_955", "99"})
    aAdd(aAtributos, {"58063200", "ATT_956", "01"})
    aAdd(aAtributos, {"58063200", "ATT_956", "02"})
    aAdd(aAtributos, {"58063200", "ATT_956", "99"})
    aAdd(aAtributos, {"58064000", "ATT_957", "01"})
    aAdd(aAtributos, {"58064000", "ATT_957", "02"})
    aAdd(aAtributos, {"58064000", "ATT_957", "99"})
    aAdd(aAtributos, {"59031000", "ATT_958", "01"})
    aAdd(aAtributos, {"59031000", "ATT_958", "02"})
    aAdd(aAtributos, {"59031000", "ATT_958", "99"})
    aAdd(aAtributos, {"59032000", "ATT_959", "01"})
    aAdd(aAtributos, {"59032000", "ATT_959", "02"})
    aAdd(aAtributos, {"59032000", "ATT_959", "99"})
    aAdd(aAtributos, {"59039000", "ATT_960", "01"})
    aAdd(aAtributos, {"59039000", "ATT_960", "02"})
    aAdd(aAtributos, {"59039000", "ATT_960", "03"})
    aAdd(aAtributos, {"59039000", "ATT_960", "99"})
    aAdd(aAtributos, {"59111000", "ATT_961", "01"})
    aAdd(aAtributos, {"59111000", "ATT_961", "99"})
    aAdd(aAtributos, {"59119000", "ATT_963", "01"})
    aAdd(aAtributos, {"59119000", "ATT_963", "02"})
    aAdd(aAtributos, {"59119000", "ATT_963", "99"})
    aAdd(aAtributos, {"60031000", "ATT_964", "01"})
    aAdd(aAtributos, {"60031000", "ATT_964", "99"})
    aAdd(aAtributos, {"60059010", "ATT_965", "01"})
    aAdd(aAtributos, {"60059010", "ATT_965", "99"})
    aAdd(aAtributos, {"60061000", "ATT_966", "01"})
    aAdd(aAtributos, {"60061000", "ATT_966", "99"})
    aAdd(aAtributos, {"61019010", "ATT_967", "01"})
    aAdd(aAtributos, {"61019010", "ATT_967", "99"})
    aAdd(aAtributos, {"61021000", "ATT_968", "01"})
    aAdd(aAtributos, {"61021000", "ATT_968", "99"})
    aAdd(aAtributos, {"61031010", "ATT_969", "01"})
    aAdd(aAtributos, {"61031010", "ATT_969", "99"})
    aAdd(aAtributos, {"61032910", "ATT_970", "01"})
    aAdd(aAtributos, {"61032910", "ATT_970", "99"})
    aAdd(aAtributos, {"61033100", "ATT_971", "01"})
    aAdd(aAtributos, {"61033100", "ATT_971", "99"})
    aAdd(aAtributos, {"61034100", "ATT_972", "01"})
    aAdd(aAtributos, {"61034100", "ATT_972", "99"})
    aAdd(aAtributos, {"61041910", "ATT_973", "01"})
    aAdd(aAtributos, {"61041910", "ATT_973", "99"})
    aAdd(aAtributos, {"61042910", "ATT_974", "01"})
    aAdd(aAtributos, {"61042910", "ATT_974", "99"})
    aAdd(aAtributos, {"61043100", "ATT_975", "01"})
    aAdd(aAtributos, {"61043100", "ATT_975", "99"})
    aAdd(aAtributos, {"61044100", "ATT_976", "01"})
    aAdd(aAtributos, {"61044100", "ATT_976", "99"})
    aAdd(aAtributos, {"61045100", "ATT_977", "01"})
    aAdd(aAtributos, {"61045100", "ATT_977", "99"})
    aAdd(aAtributos, {"61046100", "ATT_978", "01"})
    aAdd(aAtributos, {"61046100", "ATT_978", "99"})
    aAdd(aAtributos, {"61101100", "ATT_979", "01"})
    aAdd(aAtributos, {"61101100", "ATT_979", "99"})
    aAdd(aAtributos, {"61101900", "ATT_980", "01"})
    aAdd(aAtributos, {"61101900", "ATT_980", "99"})
    aAdd(aAtributos, {"61119010", "ATT_981", "01"})
    aAdd(aAtributos, {"61119010", "ATT_981", "99"})
    aAdd(aAtributos, {"61130000", "ATT_982", "01"})
    aAdd(aAtributos, {"61130000", "ATT_982", "99"})
    aAdd(aAtributos, {"61149010", "ATT_983", "01"})
    aAdd(aAtributos, {"61149010", "ATT_983", "99"})
    aAdd(aAtributos, {"61151013", "ATT_984", "01"})
    aAdd(aAtributos, {"61151013", "ATT_984", "99"})
    aAdd(aAtributos, {"61151091", "ATT_985", "01"})
    aAdd(aAtributos, {"61151091", "ATT_985", "99"})
    aAdd(aAtributos, {"61152910", "ATT_986", "01"})
    aAdd(aAtributos, {"61152910", "ATT_986", "99"})
    aAdd(aAtributos, {"61159400", "ATT_987", "01"})
    aAdd(aAtributos, {"61159400", "ATT_987", "99"})
    aAdd(aAtributos, {"61169100", "ATT_988", "01"})
    aAdd(aAtributos, {"61169100", "ATT_988", "99"})
    aAdd(aAtributos, {"62011100", "ATT_989", "01"})
    aAdd(aAtributos, {"62011100", "ATT_989", "99"})
    aAdd(aAtributos, {"62019100", "ATT_990", "01"})
    aAdd(aAtributos, {"62019100", "ATT_990", "99"})
    aAdd(aAtributos, {"62021100", "ATT_991", "01"})
    aAdd(aAtributos, {"62021100", "ATT_991", "99"})
    aAdd(aAtributos, {"62029100", "ATT_992", "01"})
    aAdd(aAtributos, {"62029100", "ATT_992", "99"})
    aAdd(aAtributos, {"62031100", "ATT_993", "01"})
    aAdd(aAtributos, {"62031100", "ATT_993", "99"})
    aAdd(aAtributos, {"62032910", "ATT_994", "01"})
    aAdd(aAtributos, {"62032910", "ATT_994", "99"})
    aAdd(aAtributos, {"62033100", "ATT_995", "01"})
    aAdd(aAtributos, {"62033100", "ATT_995", "99"})
    aAdd(aAtributos, {"62034100", "ATT_996", "01"})
    aAdd(aAtributos, {"62034100", "ATT_996", "99"})
    aAdd(aAtributos, {"62041100", "ATT_997", "01"})
    aAdd(aAtributos, {"62041100", "ATT_997", "99"})
    aAdd(aAtributos, {"62042100", "ATT_998", "01"})
    aAdd(aAtributos, {"62042100", "ATT_998", "99"})
    aAdd(aAtributos, {"62043100", "ATT_999", "01"})
    aAdd(aAtributos, {"62043100", "ATT_999", "99"})
    aAdd(aAtributos, {"62044100", "ATT_1000", "01"})
    aAdd(aAtributos, {"62044100", "ATT_1000", "99"})
    aAdd(aAtributos, {"62045100", "ATT_1001", "01"})
    aAdd(aAtributos, {"62045100", "ATT_1001", "99"})
    aAdd(aAtributos, {"62046100", "ATT_1002", "01"})
    aAdd(aAtributos, {"62046100", "ATT_1002", "99"})
    aAdd(aAtributos, {"62059010", "ATT_1003", "01"})
    aAdd(aAtributos, {"62059010", "ATT_1003", "99"})
    aAdd(aAtributos, {"62062000", "ATT_1004", "01"})
    aAdd(aAtributos, {"62062000", "ATT_1004", "99"})
    aAdd(aAtributos, {"62099010", "ATT_1005", "01"})
    aAdd(aAtributos, {"62099010", "ATT_1005", "99"})
    aAdd(aAtributos, {"62113300", "ATT_1006", "01"})
    aAdd(aAtributos, {"62113300", "ATT_1006", "02"})
    aAdd(aAtributos, {"62113300", "ATT_1006", "99"})
    aAdd(aAtributos, {"62113910", "ATT_1007", "01"})
    aAdd(aAtributos, {"62113910", "ATT_1007", "99"})
    aAdd(aAtributos, {"62114300", "ATT_1008", "01"})
    aAdd(aAtributos, {"62114300", "ATT_1008", "99"})
    aAdd(aAtributos, {"62142000", "ATT_1009", "01"})
    aAdd(aAtributos, {"62142000", "ATT_1009", "99"})
    aAdd(aAtributos, {"63012000", "ATT_1010", "01"})
    aAdd(aAtributos, {"63012000", "ATT_1010", "99"})
    aAdd(aAtributos, {"63019000", "ATT_1011", "01"})
    aAdd(aAtributos, {"63019000", "ATT_1011", "99"})
    aAdd(aAtributos, {"63079090", "ATT_1012", "01"})
    aAdd(aAtributos, {"63079090", "ATT_1012", "02"})
    aAdd(aAtributos, {"63079090", "ATT_1012", "03"})
    aAdd(aAtributos, {"63079090", "ATT_1012", "99"})
    aAdd(aAtributos, {"65061000", "ATT_1033", "01"})
    aAdd(aAtributos, {"65061000", "ATT_1033", "99"})
    aAdd(aAtributos, {"68151010", "ATT_1035", "01"})
    aAdd(aAtributos, {"68151010", "ATT_1035", "02"})
    aAdd(aAtributos, {"68151010", "ATT_1035", "99"})
    aAdd(aAtributos, {"68151020", "ATT_1036", "01"})
    aAdd(aAtributos, {"68151020", "ATT_1036", "02"})
    aAdd(aAtributos, {"68151020", "ATT_1036", "99"})
    aAdd(aAtributos, {"68151090", "ATT_1037", "01"})
    aAdd(aAtributos, {"68151090", "ATT_1037", "02"})
    aAdd(aAtributos, {"68151090", "ATT_1037", "99"})
    aAdd(aAtributos, {"69039092", "ATT_1038", "01"})
    aAdd(aAtributos, {"69039092", "ATT_1038", "99"})
    aAdd(aAtributos, {"69039099", "ATT_1039", "01"})
    aAdd(aAtributos, {"69039099", "ATT_1039", "99"})
    aAdd(aAtributos, {"69091990", "ATT_1040", "01"})
    aAdd(aAtributos, {"69091990", "ATT_1040", "99"})
    aAdd(aAtributos, {"70071100", "ATT_1041", "01"})
    aAdd(aAtributos, {"70071100", "ATT_1041", "99"})
    aAdd(aAtributos, {"70071900", "ATT_1042", "01"})
    aAdd(aAtributos, {"70071900", "ATT_1042", "99"})
    aAdd(aAtributos, {"70072100", "ATT_1043", "01"})
    aAdd(aAtributos, {"70072100", "ATT_1043", "99"})
    aAdd(aAtributos, {"70072900", "ATT_1044", "01"})
    aAdd(aAtributos, {"70072900", "ATT_1044", "99"})
    aAdd(aAtributos, {"70169000", "ATT_1045", "01"})
    aAdd(aAtributos, {"70169000", "ATT_1045", "99"})
    aAdd(aAtributos, {"70191100", "ATT_1046", "01"})
    aAdd(aAtributos, {"70191100", "ATT_1046", "99"})
    aAdd(aAtributos, {"70191210", "ATT_1047", "01"})
    aAdd(aAtributos, {"70191210", "ATT_1047", "99"})
    aAdd(aAtributos, {"70191290", "ATT_1048", "01"})
    aAdd(aAtributos, {"70191290", "ATT_1048", "99"})
    aAdd(aAtributos, {"70191900", "ATT_1049", "01"})
    aAdd(aAtributos, {"70191900", "ATT_1049", "99"})
    aAdd(aAtributos, {"70193100", "ATT_1050", "01"})
    aAdd(aAtributos, {"70193100", "ATT_1050", "99"})
    aAdd(aAtributos, {"70193200", "ATT_1051", "01"})
    aAdd(aAtributos, {"70193200", "ATT_1051", "99"})
    aAdd(aAtributos, {"70193900", "ATT_1052", "01"})
    aAdd(aAtributos, {"70193900", "ATT_1052", "99"})
    aAdd(aAtributos, {"70194000", "ATT_1053", "99"})
    aAdd(aAtributos, {"70194000", "ATT_1053", "01"})
    aAdd(aAtributos, {"70195100", "ATT_1054", "01"})
    aAdd(aAtributos, {"70195100", "ATT_1054", "99"})
    aAdd(aAtributos, {"70195290", "ATT_1055", "01"})
    aAdd(aAtributos, {"70195290", "ATT_1055", "99"})
    aAdd(aAtributos, {"70195900", "ATT_1056", "01"})
    aAdd(aAtributos, {"70195900", "ATT_1056", "99"})
    aAdd(aAtributos, {"70199010", "ATT_1057", "01"})
    aAdd(aAtributos, {"70199010", "ATT_1057", "99"})
    aAdd(aAtributos, {"70199090", "ATT_1058", "01"})
    aAdd(aAtributos, {"70199090", "ATT_1058", "99"})
    aAdd(aAtributos, {"70200090", "ATT_1059", "01"})
    aAdd(aAtributos, {"70200090", "ATT_1059", "99"})
    aAdd(aAtributos, {"71151000", "ATT_1060", "01"})
    aAdd(aAtributos, {"71151000", "ATT_1060", "02"})
    aAdd(aAtributos, {"71151000", "ATT_1060", "99"})
    aAdd(aAtributos, {"71159000", "ATT_1061", "01"})
    aAdd(aAtributos, {"71159000", "ATT_1061", "02"})
    aAdd(aAtributos, {"71159000", "ATT_1061", "99"})
    aAdd(aAtributos, {"72022900", "ATT_1062", "01"})
    aAdd(aAtributos, {"72022900", "ATT_1062", "99"})
    aAdd(aAtributos, {"72241000", "ATT_1063", "01"})
    aAdd(aAtributos, {"72241000", "ATT_1063", "99"})
    aAdd(aAtributos, {"72249000", "ATT_1064", "01"})
    aAdd(aAtributos, {"72249000", "ATT_1064", "99"})
    aAdd(aAtributos, {"72253000", "ATT_1065", "01"})
    aAdd(aAtributos, {"72253000", "ATT_1065", "99"})
    aAdd(aAtributos, {"72254090", "ATT_1066", "01"})
    aAdd(aAtributos, {"72254090", "ATT_1066", "99"})
    aAdd(aAtributos, {"72255090", "ATT_1067", "01"})
    aAdd(aAtributos, {"72255090", "ATT_1067", "99"})
    aAdd(aAtributos, {"72259100", "ATT_1068", "01"})
    aAdd(aAtributos, {"72259100", "ATT_1068", "99"})
    aAdd(aAtributos, {"72259200", "ATT_1069", "01"})
    aAdd(aAtributos, {"72259200", "ATT_1069", "99"})
    aAdd(aAtributos, {"72259990", "ATT_1070", "01"})
    aAdd(aAtributos, {"72259990", "ATT_1070", "99"})
    aAdd(aAtributos, {"72269100", "ATT_1071", "01"})
    aAdd(aAtributos, {"72269100", "ATT_1071", "99"})
    aAdd(aAtributos, {"72269200", "ATT_1072", "01"})
    aAdd(aAtributos, {"72269200", "ATT_1072", "99"})
    aAdd(aAtributos, {"72269900", "ATT_1073", "01"})
    aAdd(aAtributos, {"72269900", "ATT_1073", "99"})
    aAdd(aAtributos, {"72279000", "ATT_1074", "01"})
    aAdd(aAtributos, {"72279000", "ATT_1074", "99"})
    aAdd(aAtributos, {"72283000", "ATT_1075", "01"})
    aAdd(aAtributos, {"72283000", "ATT_1075", "99"})
    aAdd(aAtributos, {"72284000", "ATT_1076", "01"})
    aAdd(aAtributos, {"72284000", "ATT_1076", "99"})
    aAdd(aAtributos, {"72285000", "ATT_1077", "01"})
    aAdd(aAtributos, {"72285000", "ATT_1077", "99"})
    aAdd(aAtributos, {"72286000", "ATT_1078", "01"})
    aAdd(aAtributos, {"72286000", "ATT_1078", "99"})
    aAdd(aAtributos, {"72287000", "ATT_1079", "01"})
    aAdd(aAtributos, {"72287000", "ATT_1079", "99"})
    aAdd(aAtributos, {"72288000", "ATT_1080", "01"})
    aAdd(aAtributos, {"72288000", "ATT_1080", "99"})
    aAdd(aAtributos, {"73045190", "ATT_1081", "01"})
    aAdd(aAtributos, {"73045190", "ATT_1081", "99"})
    aAdd(aAtributos, {"73045910", "ATT_1082", "01"})
    aAdd(aAtributos, {"73045910", "ATT_1082", "99"})
    aAdd(aAtributos, {"73045990", "ATT_1083", "01"})
    aAdd(aAtributos, {"73045990", "ATT_1083", "99"})
    aAdd(aAtributos, {"73049019", "ATT_1084", "01"})
    aAdd(aAtributos, {"73049019", "ATT_1084", "99"})
    aAdd(aAtributos, {"73049090", "ATT_1085", "01"})
    aAdd(aAtributos, {"73049090", "ATT_1085", "99"})
    aAdd(aAtributos, {"73065000", "ATT_1086", "01"})
    aAdd(aAtributos, {"73065000", "ATT_1086", "99"})
    aAdd(aAtributos, {"73066100", "ATT_1087", "01"})
    aAdd(aAtributos, {"73066100", "ATT_1087", "99"})
    aAdd(aAtributos, {"73066900", "ATT_1088", "01"})
    aAdd(aAtributos, {"73066900", "ATT_1088", "99"})
    aAdd(aAtributos, {"73069090", "ATT_1089", "01"})
    aAdd(aAtributos, {"73069090", "ATT_1089", "99"})
    aAdd(aAtributos, {"73083000", "ATT_1090", "01"})
    aAdd(aAtributos, {"73083000", "ATT_1090", "99"})
    aAdd(aAtributos, {"75040010", "ATT_1091", "99"})
    aAdd(aAtributos, {"75040010", "ATT_1091", "01"})
    aAdd(aAtributos, {"75051110", "ATT_1092", "01"})
    aAdd(aAtributos, {"75051110", "ATT_1092", "99"})
    aAdd(aAtributos, {"75051121", "ATT_1093", "01"})
    aAdd(aAtributos, {"75051121", "ATT_1093", "99"})
    aAdd(aAtributos, {"75051129", "ATT_1094", "01"})
    aAdd(aAtributos, {"75051129", "ATT_1094", "99"})
    aAdd(aAtributos, {"75052100", "ATT_1095", "01"})
    aAdd(aAtributos, {"75052100", "ATT_1095", "99"})
    aAdd(aAtributos, {"75061000", "ATT_1096", "99"})
    aAdd(aAtributos, {"75061000", "ATT_1096", "01"})
    aAdd(aAtributos, {"75071100", "ATT_1097", "01"})
    aAdd(aAtributos, {"75071100", "ATT_1097", "99"})
    aAdd(aAtributos, {"75072000", "ATT_1098", "01"})
    aAdd(aAtributos, {"75072000", "ATT_1098", "99"})
    aAdd(aAtributos, {"75081000", "ATT_1099", "01"})
    aAdd(aAtributos, {"75081000", "ATT_1099", "99"})
    aAdd(aAtributos, {"76031000", "ATT_1100", "01"})
    aAdd(aAtributos, {"76031000", "ATT_1100", "99"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "14"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "5"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "28"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "11"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "23"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "15"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "4"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "17"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "12"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "25"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "20"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "26"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "24"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "16"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "18"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "6"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "30"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "13"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "3"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "19"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "8"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "7"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "27"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "10"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "22"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "1"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "2"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "29"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "21"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "9"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "31"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "32"})
    aAdd(aAtributos, {"76031000", "ATT_1698", "33"})
    aAdd(aAtributos, {"76042911", "ATT_1102", "01"})
    aAdd(aAtributos, {"76042911", "ATT_1102", "99"})
    aAdd(aAtributos, {"76042919", "ATT_1103", "01"})
    aAdd(aAtributos, {"76042919", "ATT_1103", "99"})
    aAdd(aAtributos, {"76082010", "ATT_1104", "01"})
    aAdd(aAtributos, {"76082010", "ATT_1104", "99"})
    aAdd(aAtributos, {"76082090", "ATT_1105", "01"})
    aAdd(aAtributos, {"76082090", "ATT_1105", "99"})
    aAdd(aAtributos, {"81019400", "ATT_1106", "01"})
    aAdd(aAtributos, {"81019400", "ATT_1106", "99"})
    aAdd(aAtributos, {"81019700", "ATT_1107", "01"})
    aAdd(aAtributos, {"81019700", "ATT_1107", "99"})
    aAdd(aAtributos, {"81019990", "ATT_1108", "01"})
    aAdd(aAtributos, {"81019990", "ATT_1108", "99"})
    aAdd(aAtributos, {"81039000", "ATT_1109", "01"})
    aAdd(aAtributos, {"81039000", "ATT_1109", "99"})
    aAdd(aAtributos, {"81041100", "ATT_1110", "01"})
    aAdd(aAtributos, {"81041100", "ATT_1110", "99"})
    aAdd(aAtributos, {"81041900", "ATT_1111", "02"})
    aAdd(aAtributos, {"81041900", "ATT_1111", "99"})
    aAdd(aAtributos, {"81041900", "ATT_1111", "01"})
    aAdd(aAtributos, {"81042000", "ATT_1112", "01"})
    aAdd(aAtributos, {"81042000", "ATT_1112", "99"})
    aAdd(aAtributos, {"81043000", "ATT_1113", "01"})
    aAdd(aAtributos, {"81043000", "ATT_1113", "02"})
    aAdd(aAtributos, {"81043000", "ATT_1113", "99"})
    aAdd(aAtributos, {"81049000", "ATT_1114", "01"})
    aAdd(aAtributos, {"81049000", "ATT_1114", "02"})
    aAdd(aAtributos, {"81049000", "ATT_1114", "99"})
    aAdd(aAtributos, {"81060010", "ATT_1115", "01"})
    aAdd(aAtributos, {"81060010", "ATT_1115", "99"})
    aAdd(aAtributos, {"81060090", "ATT_1116", "01"})
    aAdd(aAtributos, {"81060090", "ATT_1116", "99"})
    aAdd(aAtributos, {"81089000", "ATT_1117", "01"})
    aAdd(aAtributos, {"81089000", "ATT_1117", "99"})
    aAdd(aAtributos, {"81092000", "ATT_1118", "01"})
    aAdd(aAtributos, {"81092000", "ATT_1118", "99"})
    aAdd(aAtributos, {"81093000", "ATT_1119", "01"})
    aAdd(aAtributos, {"81093000", "ATT_1119", "99"})
    aAdd(aAtributos, {"81099000", "ATT_1120", "01"})
    aAdd(aAtributos, {"81099000", "ATT_1120", "99"})
    aAdd(aAtributos, {"81121200", "ATT_1121", "01"})
    aAdd(aAtributos, {"81121200", "ATT_1121", "02"})
    aAdd(aAtributos, {"81121200", "ATT_1121", "99"})
    aAdd(aAtributos, {"81129200", "ATT_1122", "01"})
    aAdd(aAtributos, {"81129200", "ATT_1122", "02"})
    aAdd(aAtributos, {"81129200", "ATT_1122", "99"})
    aAdd(aAtributos, {"81129900", "ATT_1123", "01"})
    aAdd(aAtributos, {"81129900", "ATT_1123", "02"})
    aAdd(aAtributos, {"81129900", "ATT_1123", "99"})
    aAdd(aAtributos, {"81130090", "ATT_1124", "01"})
    aAdd(aAtributos, {"81130090", "ATT_1124", "99"})
    aAdd(aAtributos, {"82055900", "ATT_1125", "01"})
    aAdd(aAtributos, {"82055900", "ATT_1125", "99"})
    aAdd(aAtributos, {"82072000", "ATT_1126", "01"})
    aAdd(aAtributos, {"82072000", "ATT_1126", "99"})
    aAdd(aAtributos, {"82073000", "ATT_1127", "01"})
    aAdd(aAtributos, {"82073000", "ATT_1127", "99"})
    aAdd(aAtributos, {"84121000", "ATT_1132", "01"})
    aAdd(aAtributos, {"84121000", "ATT_1132", "99"})
    aAdd(aAtributos, {"84122190", "ATT_1133", "01"})
    aAdd(aAtributos, {"84122190", "ATT_1133", "99"})
    aAdd(aAtributos, {"84131900", "ATT_1134", "01"})
    aAdd(aAtributos, {"84131900", "ATT_1134", "02"})
    aAdd(aAtributos, {"84131900", "ATT_1134", "99"})
    aAdd(aAtributos, {"84135010", "ATT_1135", "01"})
    aAdd(aAtributos, {"84135010", "ATT_1135", "02"})
    aAdd(aAtributos, {"84135010", "ATT_1135", "99"})
    aAdd(aAtributos, {"84135090", "ATT_1136", "01"})
    aAdd(aAtributos, {"84135090", "ATT_1136", "02"})
    aAdd(aAtributos, {"84135090", "ATT_1136", "99"})
    aAdd(aAtributos, {"84136011", "ATT_1137", "01"})
    aAdd(aAtributos, {"84136011", "ATT_1137", "99"})
    aAdd(aAtributos, {"84136019", "ATT_1138", "01"})
    aAdd(aAtributos, {"84136019", "ATT_1138", "99"})
    aAdd(aAtributos, {"84136090", "ATT_1139", "01"})
    aAdd(aAtributos, {"84136090", "ATT_1139", "99"})
    aAdd(aAtributos, {"84137080", "ATT_1140", "01"})
    aAdd(aAtributos, {"84137080", "ATT_1140", "99"})
    aAdd(aAtributos, {"84137090", "ATT_1141", "01"})
    aAdd(aAtributos, {"84137090", "ATT_1141", "02"})
    aAdd(aAtributos, {"84137090", "ATT_1141", "99"})
    aAdd(aAtributos, {"84138100", "ATT_1142", "01"})
    aAdd(aAtributos, {"84138100", "ATT_1142", "02"})
    aAdd(aAtributos, {"84138100", "ATT_1142", "99"})
    aAdd(aAtributos, {"84141000", "ATT_1143", "01"})
    aAdd(aAtributos, {"84141000", "ATT_1143", "99"})
    aAdd(aAtributos, {"84143099", "ATT_1144", "01"})
    aAdd(aAtributos, {"84143099", "ATT_1144", "99"})
    aAdd(aAtributos, {"84148029", "ATT_1145", "01"})
    aAdd(aAtributos, {"84148029", "ATT_1145", "99"})
    aAdd(aAtributos, {"84186999", "ATT_1146", "01"})
    aAdd(aAtributos, {"84186999", "ATT_1146", "99"})
    aAdd(aAtributos, {"84194090", "ATT_1147", "01"})
    aAdd(aAtributos, {"84194090", "ATT_1147", "99"})
    aAdd(aAtributos, {"84196000", "ATT_1148", "01"})
    aAdd(aAtributos, {"84196000", "ATT_1148", "99"})
    aAdd(aAtributos, {"84198940", "ATT_1149", "01"})
    aAdd(aAtributos, {"84198940", "ATT_1149", "99"})
    aAdd(aAtributos, {"84198999", "ATT_1150", "01"})
    aAdd(aAtributos, {"84198999", "ATT_1150", "99"})
    aAdd(aAtributos, {"84198999", "ATT_1150", "02"})
    aAdd(aAtributos, {"84199020", "ATT_1151", "01"})
    aAdd(aAtributos, {"84199020", "ATT_1151", "99"})
    aAdd(aAtributos, {"84213990", "ATT_1152", "01"})
    aAdd(aAtributos, {"84213990", "ATT_1152", "99"})
    aAdd(aAtributos, {"84219999", "ATT_2556", "01"})
    aAdd(aAtributos, {"84219999", "ATT_2556", "02"})
    aAdd(aAtributos, {"84219999", "ATT_4261", "01"})
    aAdd(aAtributos, {"84219999", "ATT_4261", "99"})
    aAdd(aAtributos, {"84223029", "ATT_1153", "01"})
    aAdd(aAtributos, {"84223029", "ATT_1153", "99"})
    aAdd(aAtributos, {"84289090", "ATT_1154", "01"})
    aAdd(aAtributos, {"84289090", "ATT_1154", "02"})
    aAdd(aAtributos, {"84289090", "ATT_1154", "03"})
    aAdd(aAtributos, {"84289090", "ATT_1154", "99"})
    aAdd(aAtributos, {"84351000", "ATT_1155", "01"})
    aAdd(aAtributos, {"84351000", "ATT_1155", "99"})
    aAdd(aAtributos, {"84384000", "ATT_1150", "01"})
    aAdd(aAtributos, {"84384000", "ATT_1150", "99"})
    aAdd(aAtributos, {"84384000", "ATT_1150", "02"})
    aAdd(aAtributos, {"84542090", "ATT_1157", "01"})
    aAdd(aAtributos, {"84542090", "ATT_1157", "02"})
    aAdd(aAtributos, {"84542090", "ATT_1157", "99"})
    aAdd(aAtributos, {"84543010", "ATT_1158", "01"})
    aAdd(aAtributos, {"84543010", "ATT_1158", "99"})
    aAdd(aAtributos, {"84563019", "ATT_1159", "01"})
    aAdd(aAtributos, {"84563019", "ATT_1159", "02"})
    aAdd(aAtributos, {"84563019", "ATT_1159", "03"})
    aAdd(aAtributos, {"84563019", "ATT_1159", "04"})
    aAdd(aAtributos, {"84563019", "ATT_1159", "99"})
    aAdd(aAtributos, {"84564000", "ATT_1160", "01"})
    aAdd(aAtributos, {"84564000", "ATT_1160", "02"})
    aAdd(aAtributos, {"84564000", "ATT_1160", "03"})
    aAdd(aAtributos, {"84564000", "ATT_1160", "04"})
    aAdd(aAtributos, {"84564000", "ATT_1160", "99"})
    aAdd(aAtributos, {"84565000", "ATT_1161", "01"})
    aAdd(aAtributos, {"84565000", "ATT_1161", "02"})
    aAdd(aAtributos, {"84565000", "ATT_1161", "03"})
    aAdd(aAtributos, {"84565000", "ATT_1161", "04"})
    aAdd(aAtributos, {"84569000", "ATT_1162", "01"})
    aAdd(aAtributos, {"84569000", "ATT_1162", "02"})
    aAdd(aAtributos, {"84569000", "ATT_1162", "03"})
    aAdd(aAtributos, {"84569000", "ATT_1162", "04"})
    aAdd(aAtributos, {"84569000", "ATT_1162", "99"})
    aAdd(aAtributos, {"84571000", "ATT_1163", "01"})
    aAdd(aAtributos, {"84571000", "ATT_1163", "02"})
    aAdd(aAtributos, {"84571000", "ATT_1163", "99"})
    aAdd(aAtributos, {"84581199", "ATT_1164", "01"})
    aAdd(aAtributos, {"84581199", "ATT_1164", "99"})
    aAdd(aAtributos, {"84581990", "ATT_1165", "01"})
    aAdd(aAtributos, {"84581990", "ATT_1165", "99"})
    aAdd(aAtributos, {"84629199", "ATT_1166", "01"})
    aAdd(aAtributos, {"84629199", "ATT_1166", "99"})
    aAdd(aAtributos, {"84629920", "ATT_1167", "01"})
    aAdd(aAtributos, {"84629920", "ATT_1167", "99"})
    aAdd(aAtributos, {"84629990", "ATT_1168", "01"})
    aAdd(aAtributos, {"84629990", "ATT_1168", "02"})
    aAdd(aAtributos, {"84629990", "ATT_1168", "99"})
    aAdd(aAtributos, {"84631010", "ATT_1169", "01"})
    aAdd(aAtributos, {"84631010", "ATT_1169", "99"})
    aAdd(aAtributos, {"84639010", "ATT_1170", "01"})
    aAdd(aAtributos, {"84639010", "ATT_1170", "02"})
    aAdd(aAtributos, {"84639010", "ATT_1170", "03"})
    aAdd(aAtributos, {"84639010", "ATT_1170", "04"})
    aAdd(aAtributos, {"84639010", "ATT_1170", "05"})
    aAdd(aAtributos, {"84639010", "ATT_1170", "99"})
    aAdd(aAtributos, {"84639090", "ATT_1171", "01"})
    aAdd(aAtributos, {"84639090", "ATT_1171", "99"})
    aAdd(aAtributos, {"84642090", "ATT_1172", "01"})
    aAdd(aAtributos, {"84642090", "ATT_1172", "99"})
    aAdd(aAtributos, {"84649019", "ATT_1173", "01"})
    aAdd(aAtributos, {"84649019", "ATT_1173", "99"})
    aAdd(aAtributos, {"84649090", "ATT_1174", "01"})
    aAdd(aAtributos, {"84649090", "ATT_1174", "99"})
    aAdd(aAtributos, {"84662090", "ATT_1175", "01"})
    aAdd(aAtributos, {"84662090", "ATT_1175", "99"})
    aAdd(aAtributos, {"84669490", "ATT_1176", "01"})
    aAdd(aAtributos, {"84669490", "ATT_1176", "99"})
    aAdd(aAtributos, {"84742090", "ATT_1177", "01"})
    aAdd(aAtributos, {"84742090", "ATT_1177", "02"})
    aAdd(aAtributos, {"84742090", "ATT_1177", "03"})
    aAdd(aAtributos, {"84742090", "ATT_1177", "04"})
    aAdd(aAtributos, {"84742090", "ATT_1177", "99"})
    aAdd(aAtributos, {"84775990", "ATT_1178", "01"})
    aAdd(aAtributos, {"84775990", "ATT_1178", "99"})
    aAdd(aAtributos, {"84793000", "ATT_1179", "01"})
    aAdd(aAtributos, {"84793000", "ATT_1179", "99"})
    aAdd(aAtributos, {"84795000", "ATT_1180", "01"})
    aAdd(aAtributos, {"84795000", "ATT_1180", "02"})
    aAdd(aAtributos, {"84795000", "ATT_1180", "99"})
    aAdd(aAtributos, {"84798210", "ATT_1184", "01"})
    aAdd(aAtributos, {"84798210", "ATT_1184", "02"})
    aAdd(aAtributos, {"84798210", "ATT_1184", "99"})
    aAdd(aAtributos, {"84798290", "ATT_1185", "01"})
    aAdd(aAtributos, {"84798290", "ATT_1185", "99"})
    aAdd(aAtributos, {"84798911", "ATT_1186", "01"})
    aAdd(aAtributos, {"84798911", "ATT_1186", "99"})
    aAdd(aAtributos, {"84798911", "ATT_1186", "03"})
    aAdd(aAtributos, {"84798911", "ATT_1186", "04"})
    aAdd(aAtributos, {"84798911", "ATT_1186", "02"})
    aAdd(aAtributos, {"84798999", "ATT_1187", "01"})
    aAdd(aAtributos, {"84798999", "ATT_1187", "99"})
    aAdd(aAtributos, {"84798999", "ATT_1187", "03"})
    aAdd(aAtributos, {"84798999", "ATT_1187", "04"})
    aAdd(aAtributos, {"84798999", "ATT_1187", "05"})
    aAdd(aAtributos, {"84798999", "ATT_1187", "06"})
    aAdd(aAtributos, {"84798999", "ATT_1187", "07"})
    aAdd(aAtributos, {"84798999", "ATT_1187", "08"})
    aAdd(aAtributos, {"84798999", "ATT_1187", "02"})
    aAdd(aAtributos, {"84799090", "ATT_1188", "01"})
    aAdd(aAtributos, {"84799090", "ATT_1188", "02"})
    aAdd(aAtributos, {"84799090", "ATT_1188", "99"})
    aAdd(aAtributos, {"84818039", "ATT_1189", "01"})
    aAdd(aAtributos, {"84818039", "ATT_1189", "02"})
    aAdd(aAtributos, {"84818039", "ATT_1189", "99"})
    aAdd(aAtributos, {"84818093", "ATT_1190", "01"})
    aAdd(aAtributos, {"84818093", "ATT_1190", "02"})
    aAdd(aAtributos, {"84818093", "ATT_1190", "99"})
    aAdd(aAtributos, {"84818094", "ATT_1191", "01"})
    aAdd(aAtributos, {"84818094", "ATT_1191", "02"})
    aAdd(aAtributos, {"84818094", "ATT_1191", "99"})
    aAdd(aAtributos, {"84818095", "ATT_1192", "01"})
    aAdd(aAtributos, {"84818095", "ATT_1192", "02"})
    aAdd(aAtributos, {"84818095", "ATT_1192", "99"})
    aAdd(aAtributos, {"84818096", "ATT_1193", "01"})
    aAdd(aAtributos, {"84818096", "ATT_1193", "02"})
    aAdd(aAtributos, {"84818096", "ATT_1193", "99"})
    aAdd(aAtributos, {"84818097", "ATT_1194", "01"})
    aAdd(aAtributos, {"84818097", "ATT_1194", "02"})
    aAdd(aAtributos, {"84818097", "ATT_1194", "99"})
    aAdd(aAtributos, {"84818099", "ATT_1195", "01"})
    aAdd(aAtributos, {"84818099", "ATT_1195", "02"})
    aAdd(aAtributos, {"84818099", "ATT_1195", "99"})
    aAdd(aAtributos, {"84821010", "ATT_1196", "01"})
    aAdd(aAtributos, {"84821010", "ATT_1196", "99"})
    aAdd(aAtributos, {"85024010", "ATT_1197", "01"})
    aAdd(aAtributos, {"85024010", "ATT_1197", "99"})
    aAdd(aAtributos, {"85044021", "ATT_1198", "01"})
    aAdd(aAtributos, {"85044021", "ATT_1198", "02"})
    aAdd(aAtributos, {"85044021", "ATT_1198", "99"})
    aAdd(aAtributos, {"85044022", "ATT_1199", "01"})
    aAdd(aAtributos, {"85044022", "ATT_1199", "02"})
    aAdd(aAtributos, {"85044022", "ATT_1199", "99"})
    aAdd(aAtributos, {"85044029", "ATT_1200", "01"})
    aAdd(aAtributos, {"85044029", "ATT_1200", "02"})
    aAdd(aAtributos, {"85044029", "ATT_1200", "99"})
    aAdd(aAtributos, {"85044030", "ATT_1201", "01"})
    aAdd(aAtributos, {"85044030", "ATT_1201", "02"})
    aAdd(aAtributos, {"85044030", "ATT_1201", "99"})
    aAdd(aAtributos, {"85044050", "ATT_1202", "01"})
    aAdd(aAtributos, {"85044050", "ATT_1202", "99"})
    aAdd(aAtributos, {"85044090", "ATT_1203", "01"})
    aAdd(aAtributos, {"85044090", "ATT_1203", "99"})
    aAdd(aAtributos, {"85059010", "ATT_1204", "01"})
    aAdd(aAtributos, {"85059010", "ATT_1204", "99"})
    aAdd(aAtributos, {"85142011", "ATT_1205", "01"})
    aAdd(aAtributos, {"85142011", "ATT_1205", "99"})
    aAdd(aAtributos, {"85142019", "ATT_1206", "01"})
    aAdd(aAtributos, {"85142019", "ATT_1206", "99"})
    aAdd(aAtributos, {"85143021", "ATT_1207", "01"})
    aAdd(aAtributos, {"85143021", "ATT_1207", "99"})
    aAdd(aAtributos, {"85143029", "ATT_1208", "99"})
    aAdd(aAtributos, {"85143029", "ATT_1208", "01"})
    aAdd(aAtributos, {"85143090", "ATT_1209", "01"})
    aAdd(aAtributos, {"85143090", "ATT_1209", "99"})
    aAdd(aAtributos, {"85144000", "ATT_1210", "99"})
    aAdd(aAtributos, {"85144000", "ATT_1210", "01"})
    aAdd(aAtributos, {"85258011", "ATT_1211", "01"})
    aAdd(aAtributos, {"85258011", "ATT_1211", "99"})
    aAdd(aAtributos, {"85258012", "ATT_1212", "01"})
    aAdd(aAtributos, {"85258012", "ATT_1212", "99"})
    aAdd(aAtributos, {"85258019", "ATT_1213", "01"})
    aAdd(aAtributos, {"85258019", "ATT_1213", "99"})
    aAdd(aAtributos, {"85258029", "ATT_1214", "02"})
    aAdd(aAtributos, {"85258029", "ATT_1214", "03"})
    aAdd(aAtributos, {"85258029", "ATT_1214", "99"})
    aAdd(aAtributos, {"85258029", "ATT_1214", "01"})
    aAdd(aAtributos, {"85261000", "ATT_1215", "01"})
    aAdd(aAtributos, {"85261000", "ATT_1215", "02"})
    aAdd(aAtributos, {"85261000", "ATT_1215", "99"})
    aAdd(aAtributos, {"85322190", "ATT_1218", "02"})
    aAdd(aAtributos, {"85322190", "ATT_1218", "99"})
    aAdd(aAtributos, {"85322190", "ATT_1218", "01"})
    aAdd(aAtributos, {"85322200", "ATT_1219", "01"})
    aAdd(aAtributos, {"85322200", "ATT_1219", "99"})
    aAdd(aAtributos, {"85322390", "ATT_1220", "01"})
    aAdd(aAtributos, {"85322390", "ATT_1220", "02"})
    aAdd(aAtributos, {"85322390", "ATT_1220", "99"})
    aAdd(aAtributos, {"85322490", "ATT_1221", "01"})
    aAdd(aAtributos, {"85322490", "ATT_1221", "02"})
    aAdd(aAtributos, {"85322490", "ATT_1221", "99"})
    aAdd(aAtributos, {"85322590", "ATT_1222", "01"})
    aAdd(aAtributos, {"85322590", "ATT_1222", "02"})
    aAdd(aAtributos, {"85322590", "ATT_1222", "99"})
    aAdd(aAtributos, {"85322990", "ATT_1223", "01"})
    aAdd(aAtributos, {"85322990", "ATT_1223", "02"})
    aAdd(aAtributos, {"85322990", "ATT_1223", "99"})
    aAdd(aAtributos, {"85353019", "ATT_1224", "01"})
    aAdd(aAtributos, {"85353019", "ATT_1224", "99"})
    aAdd(aAtributos, {"85359000", "ATT_1225", "01"})
    aAdd(aAtributos, {"85359000", "ATT_1225", "99"})
    aAdd(aAtributos, {"85408990", "ATT_1227", "01"})
    aAdd(aAtributos, {"85408990", "ATT_1227", "99"})
    aAdd(aAtributos, {"85414024", "ATT_1228", "01"})
    aAdd(aAtributos, {"85414024", "ATT_1228", "99"})
    aAdd(aAtributos, {"85431000", "ATT_1229", "01"})
    aAdd(aAtributos, {"85431000", "ATT_1229", "02"})
    aAdd(aAtributos, {"85431000", "ATT_1229", "03"})
    aAdd(aAtributos, {"85431000", "ATT_1229", "99"})
    aAdd(aAtributos, {"85432000", "ATT_1230", "01"})
    aAdd(aAtributos, {"85432000", "ATT_1230", "99"})
    aAdd(aAtributos, {"85433000", "ATT_1231", "01"})
    aAdd(aAtributos, {"85433000", "ATT_1231", "02"})
    aAdd(aAtributos, {"85433000", "ATT_1231", "99"})
    aAdd(aAtributos, {"85437099", "ATT_1232", "01"})
    aAdd(aAtributos, {"85437099", "ATT_1232", "02"})
    aAdd(aAtributos, {"85437099", "ATT_1232", "03"})
    aAdd(aAtributos, {"85437099", "ATT_1232", "99"})
    aAdd(aAtributos, {"87032100", "ATT_1237", "01"})
    aAdd(aAtributos, {"87032100", "ATT_1237", "99"})
    aAdd(aAtributos, {"87032210", "ATT_1238", "01"})
    aAdd(aAtributos, {"87032210", "ATT_1238", "99"})
    aAdd(aAtributos, {"87032290", "ATT_1239", "01"})
    aAdd(aAtributos, {"87032290", "ATT_1239", "99"})
    aAdd(aAtributos, {"87032310", "ATT_1240", "01"})
    aAdd(aAtributos, {"87032310", "ATT_1240", "99"})
    aAdd(aAtributos, {"87032390", "ATT_1241", "01"})
    aAdd(aAtributos, {"87032390", "ATT_1241", "99"})
    aAdd(aAtributos, {"87032410", "ATT_1242", "01"})
    aAdd(aAtributos, {"87032410", "ATT_1242", "99"})
    aAdd(aAtributos, {"87032490", "ATT_1243", "01"})
    aAdd(aAtributos, {"87032490", "ATT_1243", "99"})
    aAdd(aAtributos, {"87033110", "ATT_1244", "01"})
    aAdd(aAtributos, {"87033110", "ATT_1244", "99"})
    aAdd(aAtributos, {"87033190", "ATT_1245", "01"})
    aAdd(aAtributos, {"87033190", "ATT_1245", "99"})
    aAdd(aAtributos, {"87033210", "ATT_1246", "01"})
    aAdd(aAtributos, {"87033210", "ATT_1246", "99"})
    aAdd(aAtributos, {"87033290", "ATT_1247", "01"})
    aAdd(aAtributos, {"87033290", "ATT_1247", "99"})
    aAdd(aAtributos, {"87033310", "ATT_1248", "01"})
    aAdd(aAtributos, {"87033310", "ATT_1248", "99"})
    aAdd(aAtributos, {"87033390", "ATT_1249", "01"})
    aAdd(aAtributos, {"87033390", "ATT_1249", "99"})
    aAdd(aAtributos, {"87039000", "ATT_1255", "01"})
    aAdd(aAtributos, {"87039000", "ATT_1255", "99"})
    aAdd(aAtributos, {"87042190", "ATT_1256", "01"})
    aAdd(aAtributos, {"87042190", "ATT_1256", "99"})
    aAdd(aAtributos, {"87059090", "ATT_1257", "04"})
    aAdd(aAtributos, {"87059090", "ATT_1257", "99"})
    aAdd(aAtributos, {"87059090", "ATT_1257", "01"})
    aAdd(aAtributos, {"87059090", "ATT_1257", "02"})
    aAdd(aAtributos, {"87059090", "ATT_1257", "03"})
    aAdd(aAtributos, {"87071000", "ATT_1258", "01"})
    aAdd(aAtributos, {"87071000", "ATT_1258", "99"})
    aAdd(aAtributos, {"87079090", "ATT_1259", "01"})
    aAdd(aAtributos, {"87079090", "ATT_1259", "99"})
    aAdd(aAtributos, {"87082100", "ATT_1260", "01"})
    aAdd(aAtributos, {"87082100", "ATT_1260", "99"})
    aAdd(aAtributos, {"87082919", "ATT_1261", "01"})
    aAdd(aAtributos, {"87082919", "ATT_1261", "99"})
    aAdd(aAtributos, {"87082993", "ATT_1262", "01"})
    aAdd(aAtributos, {"87082993", "ATT_1262", "99"})
    aAdd(aAtributos, {"87082999", "ATT_1263", "01"})
    aAdd(aAtributos, {"87082999", "ATT_1263", "02"})
    aAdd(aAtributos, {"87082999", "ATT_1263", "03"})
    aAdd(aAtributos, {"87082999", "ATT_1263", "99"})
    aAdd(aAtributos, {"87089411", "ATT_1264", "99"})
    aAdd(aAtributos, {"87089411", "ATT_1264", "01"})
    aAdd(aAtributos, {"87089481", "ATT_1265", "01"})
    aAdd(aAtributos, {"87089481", "ATT_1265", "99"})
    aAdd(aAtributos, {"88010000", "ATT_1267", "01"})
    aAdd(aAtributos, {"88010000", "ATT_1267", "99"})
    aAdd(aAtributos, {"88021100", "ATT_1270", "01"})
    aAdd(aAtributos, {"88021100", "ATT_1270", "02"})
    aAdd(aAtributos, {"88021100", "ATT_1270", "99"})
    aAdd(aAtributos, {"88021210", "ATT_1271", "01"})
    aAdd(aAtributos, {"88021210", "ATT_1271", "02"})
    aAdd(aAtributos, {"88021210", "ATT_1271", "99"})
    aAdd(aAtributos, {"88021290", "ATT_1272", "01"})
    aAdd(aAtributos, {"88021290", "ATT_1272", "02"})
    aAdd(aAtributos, {"88021290", "ATT_1272", "99"})
    aAdd(aAtributos, {"88022010", "ATT_1273", "01"})
    aAdd(aAtributos, {"88022010", "ATT_1273", "02"})
    aAdd(aAtributos, {"88022010", "ATT_1273", "99"})
    aAdd(aAtributos, {"88022021", "ATT_1274", "01"})
    aAdd(aAtributos, {"88022021", "ATT_1274", "02"})
    aAdd(aAtributos, {"88022021", "ATT_1274", "99"})
    aAdd(aAtributos, {"88022022", "ATT_1275", "01"})
    aAdd(aAtributos, {"88022022", "ATT_1275", "02"})
    aAdd(aAtributos, {"88022022", "ATT_1275", "99"})
    aAdd(aAtributos, {"88022090", "ATT_1276", "01"})
    aAdd(aAtributos, {"88022090", "ATT_1276", "02"})
    aAdd(aAtributos, {"88022090", "ATT_1276", "99"})
    aAdd(aAtributos, {"88023021", "ATT_1278", "01"})
    aAdd(aAtributos, {"88023021", "ATT_1278", "02"})
    aAdd(aAtributos, {"88023021", "ATT_1278", "99"})
    aAdd(aAtributos, {"88023029", "ATT_1279", "01"})
    aAdd(aAtributos, {"88023029", "ATT_1279", "02"})
    aAdd(aAtributos, {"88023029", "ATT_1279", "99"})
    aAdd(aAtributos, {"88023031", "ATT_1280", "01"})
    aAdd(aAtributos, {"88023031", "ATT_1280", "02"})
    aAdd(aAtributos, {"88023031", "ATT_1280", "99"})
    aAdd(aAtributos, {"88023039", "ATT_1281", "01"})
    aAdd(aAtributos, {"88023039", "ATT_1281", "02"})
    aAdd(aAtributos, {"88023039", "ATT_1281", "99"})
    aAdd(aAtributos, {"88023090", "ATT_1282", "01"})
    aAdd(aAtributos, {"88023090", "ATT_1282", "02"})
    aAdd(aAtributos, {"88023090", "ATT_1282", "99"})
    aAdd(aAtributos, {"88024010", "ATT_1283", "01"})
    aAdd(aAtributos, {"88024010", "ATT_1283", "02"})
    aAdd(aAtributos, {"88024010", "ATT_1283", "99"})
    aAdd(aAtributos, {"88024090", "ATT_1284", "01"})
    aAdd(aAtributos, {"88024090", "ATT_1284", "02"})
    aAdd(aAtributos, {"88024090", "ATT_1284", "99"})
    aAdd(aAtributos, {"88026000", "ATT_1285", "01"})
    aAdd(aAtributos, {"88026000", "ATT_1285", "02"})
    aAdd(aAtributos, {"88026000", "ATT_1285", "03"})
    aAdd(aAtributos, {"88026000", "ATT_1285", "99"})
    aAdd(aAtributos, {"88031000", "ATT_1286", "01"})
    aAdd(aAtributos, {"88031000", "ATT_1286", "99"})
    aAdd(aAtributos, {"88032000", "ATT_1287", "01"})
    aAdd(aAtributos, {"88032000", "ATT_1287", "99"})
    aAdd(aAtributos, {"88033000", "ATT_1288", "01"})
    aAdd(aAtributos, {"88033000", "ATT_1288", "99"})
    aAdd(aAtributos, {"88040000", "ATT_1290", "01"})
    aAdd(aAtributos, {"88040000", "ATT_1290", "99"})
    aAdd(aAtributos, {"88051000", "ATT_1291", "01"})
    aAdd(aAtributos, {"88051000", "ATT_1291", "99"})
    aAdd(aAtributos, {"88052100", "ATT_1292", "01"})
    aAdd(aAtributos, {"88052100", "ATT_1292", "99"})
    aAdd(aAtributos, {"88052900", "ATT_1293", "01"})
    aAdd(aAtributos, {"88052900", "ATT_1293", "99"})
    aAdd(aAtributos, {"89061000", "ATT_1294", "01"})
    aAdd(aAtributos, {"89061000", "ATT_1294", "99"})
    aAdd(aAtributos, {"89069000", "ATT_1295", "01"})
    aAdd(aAtributos, {"89069000", "ATT_1295", "99"})
    aAdd(aAtributos, {"90021110", "ATT_1296", "01"})
    aAdd(aAtributos, {"90021110", "ATT_1296", "99"})
    aAdd(aAtributos, {"90022090", "ATT_1297", "01"})
    aAdd(aAtributos, {"90022090", "ATT_1297", "99"})
    aAdd(aAtributos, {"90029000", "ATT_1298", "01"})
    aAdd(aAtributos, {"90029000", "ATT_1298", "99"})
    aAdd(aAtributos, {"90051000", "ATT_1300", "01"})
    aAdd(aAtributos, {"90051000", "ATT_1300", "99"})
    aAdd(aAtributos, {"90058000", "ATT_1301", "01"})
    aAdd(aAtributos, {"90058000", "ATT_1301", "99"})
    aAdd(aAtributos, {"90069190", "ATT_1303", "01"})
    aAdd(aAtributos, {"90069190", "ATT_1303", "02"})
    aAdd(aAtributos, {"90069190", "ATT_1303", "99"})
    aAdd(aAtributos, {"90132000", "ATT_1305", "01"})
    aAdd(aAtributos, {"90132000", "ATT_1305", "99"})
    aAdd(aAtributos, {"90132000", "ATT_1305", "03"})
    aAdd(aAtributos, {"90132000", "ATT_1305", "04"})
    aAdd(aAtributos, {"90132000", "ATT_1305", "05"})
    aAdd(aAtributos, {"90132000", "ATT_1305", "06"})
    aAdd(aAtributos, {"90132000", "ATT_1305", "07"})
    aAdd(aAtributos, {"90132000", "ATT_1305", "08"})
    aAdd(aAtributos, {"90132000", "ATT_1305", "02"})
    aAdd(aAtributos, {"90138090", "ATT_1306", "01"})
    aAdd(aAtributos, {"90138090", "ATT_1306", "02"})
    aAdd(aAtributos, {"90138090", "ATT_1306", "99"})
    aAdd(aAtributos, {"90139000", "ATT_1307", "01"})
    aAdd(aAtributos, {"90139000", "ATT_1307", "99"})
    aAdd(aAtributos, {"90139000", "ATT_1307", "03"})
    aAdd(aAtributos, {"90139000", "ATT_1307", "04"})
    aAdd(aAtributos, {"90139000", "ATT_1307", "05"})
    aAdd(aAtributos, {"90139000", "ATT_1307", "06"})
    aAdd(aAtributos, {"90139000", "ATT_1307", "07"})
    aAdd(aAtributos, {"90139000", "ATT_1307", "08"})
    aAdd(aAtributos, {"90139000", "ATT_1307", "02"})
    aAdd(aAtributos, {"90142090", "ATT_1308", "01"})
    aAdd(aAtributos, {"90142090", "ATT_1308", "02"})
    aAdd(aAtributos, {"90142090", "ATT_1308", "99"})
    aAdd(aAtributos, {"90158090", "ATT_1309", "01"})
    aAdd(aAtributos, {"90158090", "ATT_1309", "99"})
    aAdd(aAtributos, {"90221999", "ATT_1310", "01"})
    aAdd(aAtributos, {"90221999", "ATT_1310", "02"})
    aAdd(aAtributos, {"90221999", "ATT_1310", "99"})
    aAdd(aAtributos, {"90222190", "ATT_1311", "04"})
    aAdd(aAtributos, {"90222190", "ATT_1311", "05"})
    aAdd(aAtributos, {"90222190", "ATT_1311", "06"})
    aAdd(aAtributos, {"90222190", "ATT_1311", "99"})
    aAdd(aAtributos, {"90222190", "ATT_1311", "01"})
    aAdd(aAtributos, {"90222190", "ATT_1311", "02"})
    aAdd(aAtributos, {"90222190", "ATT_1311", "03"})
    aAdd(aAtributos, {"90222990", "ATT_1312", "01"})
    aAdd(aAtributos, {"90222990", "ATT_1312", "99"})
    aAdd(aAtributos, {"90222990", "ATT_1312", "03"})
    aAdd(aAtributos, {"90222990", "ATT_1312", "04"})
    aAdd(aAtributos, {"90222990", "ATT_1312", "05"})
    aAdd(aAtributos, {"90222990", "ATT_1312", "06"})
    aAdd(aAtributos, {"90222990", "ATT_1312", "07"})
    aAdd(aAtributos, {"90222990", "ATT_1312", "02"})
    aAdd(aAtributos, {"90262010", "ATT_1313", "01"})
    aAdd(aAtributos, {"90262010", "ATT_1313", "02"})
    aAdd(aAtributos, {"90262010", "ATT_1313", "99"})
    aAdd(aAtributos, {"90262090", "ATT_1314", "01"})
    aAdd(aAtributos, {"90262090", "ATT_1314", "02"})
    aAdd(aAtributos, {"90262090", "ATT_1314", "03"})
    aAdd(aAtributos, {"90262090", "ATT_1314", "99"})
    aAdd(aAtributos, {"90278020", "ATT_1315", "01"})
    aAdd(aAtributos, {"90278020", "ATT_1315", "99"})
    aAdd(aAtributos, {"90292010", "ATT_1316", "99"})
    aAdd(aAtributos, {"90292010", "ATT_1316", "01"})
    aAdd(aAtributos, {"90311000", "ATT_1318", "01"})
    aAdd(aAtributos, {"90311000", "ATT_1318", "02"})
    aAdd(aAtributos, {"90311000", "ATT_1318", "99"})
    aAdd(aAtributos, {"90312090", "ATT_1319", "01"})
    aAdd(aAtributos, {"90312090", "ATT_1319", "99"})
    aAdd(aAtributos, {"90314990", "ATT_1320", "01"})
    aAdd(aAtributos, {"90314990", "ATT_1320", "99"})
    aAdd(aAtributos, {"90314990", "ATT_1320", "03"})
    aAdd(aAtributos, {"90314990", "ATT_1320", "04"})
    aAdd(aAtributos, {"90314990", "ATT_1320", "05"})
    aAdd(aAtributos, {"90314990", "ATT_1320", "06"})
    aAdd(aAtributos, {"90314990", "ATT_1320", "07"})
    aAdd(aAtributos, {"90314990", "ATT_1320", "02"})
    aAdd(aAtributos, {"90318020", "ATT_1321", "01"})
    aAdd(aAtributos, {"90318020", "ATT_1321", "02"})
    aAdd(aAtributos, {"90318020", "ATT_1321", "99"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "01"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "99"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "03"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "04"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "05"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "06"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "07"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "08"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "09"})
    aAdd(aAtributos, {"90318099", "ATT_1323", "02"})
    aAdd(aAtributos, {"90328911", "ATT_1324", "01"})
    aAdd(aAtributos, {"90328911", "ATT_1324", "02"})
    aAdd(aAtributos, {"90328911", "ATT_1324", "99"})
    aAdd(aAtributos, {"90328919", "ATT_1325", "01"})
    aAdd(aAtributos, {"90328919", "ATT_1325", "02"})
    aAdd(aAtributos, {"90328919", "ATT_1325", "99"})
    aAdd(aAtributos, {"92079010", "ATT_1371", "99"})
    aAdd(aAtributos, {"92079010", "ATT_1371", "01"})
    aAdd(aAtributos, {"92099200", "ATT_1372", "99"})
    aAdd(aAtributos, {"92099200", "ATT_1372", "01"})
    aAdd(aAtributos, {"92099400", "ATT_1373", "99"})
    aAdd(aAtributos, {"92099400", "ATT_1373", "01"})
    aAdd(aAtributos, {"92099900", "ATT_1374", "99"})
    aAdd(aAtributos, {"92099900", "ATT_1374", "01"})
    aAdd(aAtributos, {"93020000", "ATT_1342", "01"})
    aAdd(aAtributos, {"93020000", "ATT_1342", "99"})
    aAdd(aAtributos, {"93040000", "ATT_1343", "01"})
    aAdd(aAtributos, {"93040000", "ATT_1343", "99"})
    aAdd(aAtributos, {"93051000", "ATT_1344", "01"})
    aAdd(aAtributos, {"93051000", "ATT_1344", "99"})
    aAdd(aAtributos, {"93063000", "ATT_1345", "01"})
    aAdd(aAtributos, {"93063000", "ATT_1345", "99"})
    aAdd(aAtributos, {"93069000", "ATT_1346", "01"})
    aAdd(aAtributos, {"93069000", "ATT_1346", "99"})
    aAdd(aAtributos, {"93070000", "ATT_1347", "01"})
    aAdd(aAtributos, {"93070000", "ATT_1347", "02"})
    aAdd(aAtributos, {"93070000", "ATT_1347", "99"})
    aAdd(aAtributos, {"94012000", "ATT_1348", "01"})
    aAdd(aAtributos, {"94012000", "ATT_1348", "99"})
    aAdd(aAtributos, {"94016900", "ATT_1349", "01"})
    aAdd(aAtributos, {"94016900", "ATT_1349", "99"})
    aAdd(aAtributos, {"94019010", "ATT_1350", "01"})
    aAdd(aAtributos, {"94019010", "ATT_1350", "99"})
    aAdd(aAtributos, {"94036000", "ATT_1352", "01"})
    aAdd(aAtributos, {"94036000", "ATT_1352", "99"})
    aAdd(aAtributos, {"94039010", "ATT_1353", "01"})
    aAdd(aAtributos, {"94039010", "ATT_1353", "99"})
    aAdd(aAtributos, {"95030099", "ATT_1354", "01"})
    aAdd(aAtributos, {"95030099", "ATT_1354", "99"})
    aAdd(aAtributos, {"95081000", "ATT_1355", "01"})
    aAdd(aAtributos, {"95081000", "ATT_1355", "99"})
    aAdd(aAtributos, {"96019000", "ATT_1356", "01"})
    aAdd(aAtributos, {"96019000", "ATT_1356", "99"})
    aAdd(aAtributos, {"97050000", "ATT_1366", "03"})
    aAdd(aAtributos, {"97050000", "ATT_1366", "04"})
    aAdd(aAtributos, {"97050000", "ATT_1366", "99"})
    aAdd(aAtributos, {"97050000", "ATT_1366", "02"})
    aAdd(aAtributos, {"97050000", "ATT_1366", "01"})
    aAdd(aAtributos, {"97050000", "ATT_1366", "05"})
    aAdd(aAtributos, {"97050000", "ATT_1366", "06"})
EndIf

If (nPos := aScan(aAtributos, {|x| x[1] == AllTrim(cNCM) .And. x[3] == Alltrim(cDestaque) })) > 0
    cAtt := aAtributos[nPos][2]
EndIf

Return cAtt
