/*==================================================================================================================
* Programa   : EECEI103.PRW
* Objetivo   : Integração
* Parâmetros : Nenhum
* Retorno    : Lógico (.T. ou .F.)
* Autor      : Bruno Akyo Kubagawa
* Data       : Setembro de 2010
* Obs.       : Fluxo de funcionamento do programa:
               1. Parâmetros para a geração do arquivo
               2. Validação e verificação da existência do arquivo, para não sobrepor arquivos existente já que o
                  nome do arquivo para Fatura será composto pela palavra FATURA, mais o número da fatura e letra do 
                  container e para o Certificado XXXX.
               3. Criação dos arrays aHeader, aDetail e aTrailler conforme layout dos campos Facisc para a 
                  linha correspondente.
                  Estes arrays serão a base para a criação do array aCols com as informações finais que serão usadas
                  para a geração do arquivo de integração.

                  Arquivo de Fatura:
                     - Estrutura dos arrays aHeader, aDetail, aTrailler:
                            {
                              1. - Infomações dos Campos (Dicionario de Dados)
                            }
                     - Estrutura do array aDadosFat:
                            {
                              {
                                1. - aHeader
                                {
                                  2. - aDetail
                                }
                                3. - aTrailer
                              }
                            }  

                  Arquivo de Certificado:
                     - Estrutura do array aHeader, aDetail:
                            {
                              1. - Id do Fabricante e as informações dos campos (Dicionario de Dados)
                            }
                     - Estrutura do array aDadosCo:
                            {
                              {
                                1. - aHeader
                                {
                                  2. - aDetail
                                }
                              }
                            } 

             	  Estruta do aCols
             	     {
             	        1. - aDadosFat
             	        2. - aDadosCo
             	     }
             	     
             	  3.1. Funções staticas para posicionamento de registros, validação das informações e 
             	       preenchimento de dados que devem ser manipulados antes da geração do arquivo.
               4. Criação dos aCols (Fatura e Certificado) com base no aHeader, aDetail e aTrailler.
               5. Criação dos diretórios.
               6. Criação do arquivo texto.
             O recebimento do número do processo e o local para a geração do arquivo TXT se dará por 
             meio de parâmetros.
==================================================================================================================*/

#Include "EEC.CH"
#Include "EECEI103.CH"
#Include "RWMAKE.CH"
#Include "FILEIO.CH"
//#Define FAT_CERT "FC" //Fatura Comercial - Certificado de Origem
#Define FAT_CERT "RAIZ"//FSY - 25/09/2013 - Ajuste para exibir as ações na tela.
#Define ST_N     "N"   //Arquivos não enviados
#Define ST_E     "E"   //Arquivos enviados
#Define ST_A     "A"   //Arquivos aprovados
#Define ST_R     "R"   //Arquivos rejeitados
#Define ACAO_NA  "NA"  //Código da ação que indica a geração de um novo arquivo
#Define ACAO_EA  "EA"  //Código da ação que indica o envio de um novo arquivo
#Define ACAO_RA  "RA"  //Código da ação que indica o retorno do arquivo enviado
#Define ACAO_VA  "VA"  //Código da ação que indica a visualização do arquivo
#Define ENTER CHR(13)+CHR(10)

/*==================================================================================================================
* Função    : EECEI103
* Objetivo  : Chamada da central de integrações para o início das operações
* Parâmetros: 
* Retorno   : 
* Autor     : Bruno Akyo Kubagawa
* Data      : 17/09/2009
* Obs.      :
==================================================================================================================*/
Function EECEI103()
Local aServ   := {},;
      aAcao   := {},;
      aItens  := {},;
      aIdsArq := {},;
      aCampos1:= {},;
      aCampos2:= {}
Local bAcao,bOk,bCancel
Local cAlias:= "E12"
Private aGets    := {},;
        aTela    := {}
Private cDirGerado := "\Comex\FACISC\Gerados\",;
        cDirEnviado:= "\Comex\FACISC\Enviados\",;
        cAcordoCom := Space(0),; // Código do Acordo
        cCadastro  := STR0001 ,; // Cadastro de Fatura - Certificado de Origem
        cTitMsg    := Space(0),;
        cRetMsg    := Space(0)
Private aIds       := {}

Begin Sequence

/*==============================Estrutura aIds===========================
1. - Fatura ou Certificado de Origem
2. - Identificar: Header (1), Detail (2), Trailler (3) e delimitador (*)
=========================================================================*/
   aAdd(aIds,{STR0002,STR0003}) //"Fatura","Certificado de Origem"
   aAdd(aIds,{"1","2","3","*"})

   //Campos que serão exibidos na Work de arquivos não enviados
 //  aCampos1:= {"E12_ARQUIV", "E12_PREEMB", "E12_USUACR", "E12_DATACR", "E12_HORACR"}
   //Campos que serão exibidos na Work de arquivos enviados
 //  aCampos2:= {"E12_ARQUIV", "E12_PREEMB", "E12_USUAEN", "E12_DATAEN", "E12_HORAEN"}

/*=============================Estrutura aItens==========================
1. - Descrição do Item
2. - ID para controle interno
3. - Status (conteúdo dos campos do índice informado)
4. - aCampos
5.
6.
7.
=========================================================================*/
   AAdd(aItens, {STR0004, ST_N, /*FAT_CERT +*/ ST_N, , "Folder5", "Folder6"})
   AAdd(aItens, {STR0005, ST_E, /*FAT_CERT +*/ ST_E, , "Folder5", "Folder6"})
   AAdd(aItens, {STR0006, ST_A, /*FAT_CERT +*/ ST_A, , "Folder5", "Folder6"})
   AAdd(aItens, {STR0007, ST_R, /*FAT_CERT +*/ ST_R, , "Folder5", "Folder6"})

/*==============================Estrutura aServ===========================
1. - Descrição do Serviço
2. - Alias da Tabela de Serviço
3. - Id de Serviço
4. - aItens
5. - aCampos MsSelect
6. - Indice (número do índice da tabela
7. - Resource Open
8. - Resource Close 
=========================================================================*/
   AAdd(aServ, {STR0008, cAlias, FAT_CERT , aItens, , 1, "Folder5", "Folder6"}) //Fatura - C. Origem 

/*==============================Estrutura aAcao===========================
1. - Descrição da Ação
2. - ID para controle interno da Ação
3. - aIdsArq
     Estrutura aIdsArq:
     3.1 - Descrição do Serviço
     3.2 - Não Enviados
     3.3 - Enviados
     3.4 - Aceitos
     3.5 - Rejeitados
4. - Bloco de Código
5. - ID para controle interno (Não enviados, Enviados)
6. - Resource Open
7. - Resource Close
=========================================================================*/
   //Ação: Geração de um novo arquivo
   aIdsArq:= {FAT_CERT + ST_N}
   bAcao:= {|| EI103GeraArq(),AvAtuCentrInt("", aServ)}
   AAdd(aAcao, {STR0009, ACAO_NA, aIdsArq, bAcao, ST_N, "sdurecall", "sdurecall"}) // Novo Arquivo

   //Ação: Envio de arquivo
   aIdsArq:= {FAT_CERT + ST_N}
   bAcao:= {|| EI103EnviaArq(),AvAtuCentrInt("", aServ)}
   AAdd(aAcao, {STR0010, ACAO_EA, aIdsArq, bAcao, ST_E, "bmppost", "bmppost"}) //Enviar Arquivo

   //Ação: Retornar o status do arquivo enviado - Aceito ou Rejeitado
   aIdsArq:= {FAT_CERT + ST_E}
   bAcao:= {|| EI103RetArq(),AvAtuCentrInt("", aServ)}
   AAdd(aAcao, {STR0011, ACAO_RA, aIdsArq, bAcao,, "reload", "reload"}) //Retornar Arquivo

   //Ação: Visualizar o arquivo de integração gerado
   aIdsArq:= {FAT_CERT , FAT_CERT + ST_N , FAT_CERT + ST_E , FAT_CERT + ST_A , FAT_CERT + ST_R}
   bAcao:= {|| EI103VisualArq()}
   AAdd(aAcao, {STR0012, ACAO_VA, aIdsArq, bAcao,,"sdufind", "sdufind"}) //Visualizar Arquivo

   //AvCentIntegracao(aServ, aAcao, STR0013, STR0014, STR0015, STR0014, STR0015, STR0016, bOk, bCancel) //Central de Integrações, Serviços, Ações, , , Integração - Ippex
   AvCentIntegracao(aServ, aAcao, STR0013, STR0014, STR0015, STR0014, STR0015, STR0016, bOk, bCancel,,,,,,,.F.)

End Sequence

Return Nil

/*==================================================================================================================
* Função    : EI103GeraArq
* Objetivo  : Controlar a geração dos arquivos de integração
* Parâmetros: 
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 27/08/2009
* Obs.      : 
==================================================================================================================*/
Function EI103GeraArq()
Local aCols        := {}
Local nCont        := 0,;
      nInc         := 0
Local lRet         := .T.
Local bGeraTxt
Local cPreemb      := Space(0)
Local cDiretorio   := Space(0)
Local cInvoice     := Space(0)
Private aInvoices  := {}
Private aProdEXA   := {}
Private aNomeArq   := {}

//RMD - 26/06/14 - Disponibilizado para utilização em ponto de entrada
Private aDadosFat  := {}
Private aDadosCO   := {}

Begin Sequence

   If !Pergunte("EI103A", .T.,STR0008) //Fatura - C. Origem
      cRetMsg := Space(0)
      lRet:= .F.
      Break
   EndIf
   cPreemb  := MV_PAR01
   cInvoice := MV_PAR02

   //Carrega os dados para o arqivo TXT.
   //Função FatLayoutEI103 e CertLayoutEI103 carrega o vetor aNomeArq, para geração dos nomes dos arquivos TXT.
   aDadosFat := FatLayoutEI103(cPreemb, cInvoice)
   aDadosCO  := CertLayoutEI103(cPreemb, cInvoice)

   //Verificação das informações da Fatura e Certificado.
   If Empty(aDadosFat) .Or. Empty(aDadosCO)
      lRet := .F.
      Break
   EndIf

   //RMD - 26/06/14 - Para possibilitar a alteração das informações dos dados do certificado (aDadosFat e aDadosCO)
   If EasyEntryPoint("EECEI103")
      ExecBlock("EECEI103", .F., .F., "VALIDA_DADOS")
   EndIf

   //Validação para geração do arquivo, verifica se o arquivo ja existe.
   If !ValidGeraArqEI103(cPreemb, cInvoice)
      lRet := .F.
      BReak
   EndIf

   //Verificação da existência dos diretórios para a gravação dos arquivos de integração
   //Caso negativo, os diretórios serão criados.
   cDiretorio := cDirGerado + xFilial("EEC") + Alltrim(cPreemb) + If(!Empty(cInvoice), "\" + AllTrim(cInvoice) + "\", "")  // GFP - 06/09/2016
   If !CriaDiretorioEI103(cDiretorio)
      lRet := .F.
      Break         
   EndIf

   //Gera todos os arquivos...
   aCols :=  {aDadosFat, aDadosCO}
   bGeraTxt:= {|| lRet:= FaciscCriaTxtEI103(cDiretorio, aNomeArq , aCols)}
   Processa(bGeraTxt, STR0017 , STR0018 , .T.) //Geração de arquivo , Gerando o arquivo para integração...

   If lRet
      //Gravação dos dados da geração do arquivo na tabela de histórico
      For nCont := 1 To Len(aNomeArq)
         FaciscAtuE12EI103(aNomeArq[nCont][1], cPreemb, cInvoice, aNomeArq[nCont][2])
      Next nCont
   EndIf

End Sequence

If !lRet
   MsgInfo(STR0019 + ; //O arquivo de integração não foi gerado.
           If(Empty(cRetMsg),Space(0),Replic(ENTER,2) + "Motivo: " + ENTER + cRetMsg), "Atenção")
EndIf

Return lRet

/*==================================================================================================================
* Função    : EI103EnviaArq
* Objetivo  : Controlar o envio de arquivos, exibição da tela ao usuário e mover o arquivo de integração
              do diretório gerados para o diretório enviados dentro da sua respectiva pasta.
* Parâmetros: 
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 27/08/2009
* Obs.      : 
==================================================================================================================*/
Function EI103EnviaArq()
Local bOk     := {|| lBotao:= AtualizaStatusEI103(ST_E,aArquivos), oDlg:End()},;
      bCancel := {|| lBotao:= .F., oDlg:End()},;
      bGetFat    := {|x| If(PCount() > 0, cExibeFat:= x, cExibeFat)},;
      bGetCo     := {|y| If(PCount() > 0, cExibeCo:= y, cExibeCo)}
Local cDirOrigem := Space(0),;
      cDirDestino:= Space(0),;
      cAlias     := Alias(),;
      cPreemb    := Space(0),;
      cExibeArq  := Space(0),;
      cInvoice   := Space(0)
Local lRet   := .T.,;
      lBotao := .F.
Local nInferior:= 150,;
      nDireita := 500,;
      i        := 0
Local oDlg
Local hFile
Local aFiles    := {},;
      aArquivos := {}

Begin Sequence

   If (cAlias)->(EasyRecCount()) == 0
      cRetMsg := STR0020 //Não existem arquivos a serem enviados para este serviço.
      lRet:= .F.
      Break
   EndIf

   cPreemb    := (cAlias)->E12_PREEMB
   cInvoice   := (cAlias)->E12_NRINVO
   cDirOrigem := cDirGerado + xFilial("EEC") + AllTrim(cPreemb) + If(!Empty(cInvoice), "\" + AllTrim(cInvoice) + "\", "\")
   cDirDestino:= GetTempPath() + "facisc\"

   E12->(DbSetOrder(4)) //E12_PREEMB+E12_INVOICE+E12_ARQTIP
   If E12->(DbSeek(xFilial()+cPreemb+cInvoice+"F"))
      aAdd(aArquivos,{AllTrim(E12->E12_ARQUIV),cPreemb,cInvoice})
   EndIf

   E12->(DbSetOrder(4))
   If E12->(DbSeek(xFilial()+cPreemb+cInvoice+"C"))
      aAdd(aArquivos,{AllTrim(E12->E12_ARQUIV),cPreemb,cInvoice})
   EndIf

   //Criação do diretório destino
   If !CriaDiretorioEI103(cDirDestino)
      lRet:= .F.
      Break
   EndIf

   For i := 1 To Len(aArquivos)
      // Verifica se existe o arquivo na pasta temporaria
      If File(cDirDestino + aArquivos[i][1])
         FErase(cDirDestino + aArquivos[i][1])
      EndIf

      //Copia o arquivo para o diretório temporário do terminal do usuário
      If !CpyS2T(cDirOrigem + aArquivos[i][1], cDirDestino)
         If File(cDirOrigem + aArquivos[i][1])
            cRetMsg := STR0021 //Não foi possível copiar o arquivo de integração para o terminal do usuário.
         Else
            cRetMsg := STR0022 //Arquivo de origem não encontrado.
         EndIf
         lRet:= .F.
         Break
      EndIf
   Next
   
   //Tela para exibição do caminho do arquivo de integração
   cExibeFat:= cDirDestino + aArquivos[1][1]
   cExibeCo := cDirDestino + aArquivos[2][1]
   Define MsDialog oDlg Title STR0016 From 0, 0 To nInferior, nDireita Pixel Of oMainWnd  //Integração FACISC - Ippex

      TSay():New(25, 10, {|| STR0002 + ":"}, oDlg,,,,,, .T.) //Fatura
      TGet():New(24, 42, bGetFat, oDlg, 200, 08,,,,,,,, .T.)
      TSay():New(37, 10, {|| STR0064 + ":"}, oDlg,,,,,, .T.) //Certificado
      TGet():New(36, 42, bGetCo, oDlg, 200, 08,,,,,,,, .T.)
      @ 49, 223 BMPButton Type 14 Action WinExec("Explorer " + cDirDestino)

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered


   //Após a atualização do status, o arquivo será movido para o diretório enviados.
   If lBotao

      For i := 1 To Len(aArquivos)
      
         //Apagando o arquivo temporário
         If File(cDirDestino + aArquivos[i][1])
            FErase(cDirDestino + aArquivos[i][1])
         EndIf

         //Criação do diretório de enviados
         cDirDestino := cDirEnviado + xFilial("EEC") + AllTrim(cPreemb) + If(!Empty(cInvoice), "\" + AllTrim(cInvoice) + "\", "")  // GFP - 06/09/2016
         If !CriaDiretorioEI103(cDirDestino)
            lRet:= .F.
            Break
         EndIf

         /*************
         Arquivo de integração
         ***********************/

         //Apagando o arquivo, caso seja reenvio
         If File(cDirDestino + aArquivos[i][1])
            FErase(cDirDestino + aArquivos[i][1])
         EndIf

         //Criação do arquivo de integração para onde o atual será copiado
         hFile:= EasyCreateFile(cDirDestino + aArquivos[i][1])
         If hFile == -1
            cRetMsg := STR0024 //O arquivo não pode ser criado na pasta de 'Enviados'.
            lRet:= .F.
            Break
         EndIf
         FClose(hFile)

         //Movendo o arquivo para o diretório \enviados\
         If !__CopyFile(cDirOrigem + aArquivos[i][1], cDirDestino + aArquivos[i][1])
            cRetMsg := STR0025 //Não foi possível mover o arquivo para o diretório 'Enviados'.
            lRet:= .F.
            Break
         EndIf

         //Apagando o arquivo de origem
         If File(cDirOrigem + aArquivos[i][1])
            FErase(cDirOrigem + aArquivos[i][1])
         EndIf

         //Apagando o diretório...
         aFiles := Directory(cDirOrigem + aArquivos[i][1])
         If Empty(aFiles)
            DirRemove(cDirOrigem)
         EndIf
      Next
   EndIf

End Sequence

If !lRet
   MsgInfo(cRetMsg,"Atenção")
EndIf

Return lRet

/*==================================================================================================================
* Função    : EI103RetArq
* Objetivo  : Gravar o status do retorno da integração após o envio do arquivo para a Facisc.
              Esta função exibirá ao usuário as opções de alterar o status do arquivo para aceito
              ou rejeitado.
* Parâmetros: 
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 27/08/2009
* Obs.      : 
==================================================================================================================*/
Function EI103RetArq()
Local bOk    := {|| lOk:= .T., oDlg:End()},;
      bCancel:= {|| lOk:= .F., oDlg:End()},;
      bRadio := {|x| If(PCount() > 0, nRadio:= x, nRadio)},;
      bGet   := {|x| If(PCount() > 0, cObs:= x, cObs)}
Local cAlias    := Alias(),;
      cTitulo   := Space(0),;
      cObs      := Space(0),;
      cTipoInteg:= Space(0),;
      cRet      := Space(0),;
      cPreemb   := Space(0),;
      cInvoice  := Space(0)
Local lRet:= .F.,;
      lOk := .F.
Local nRadio   := 1,;
      nInferior:= 230,;
      nDireita := 500,;
      nCont
Local aArquivos := {}
Local oDlg,;
      oMultiGet

Begin Sequence

   If (cAlias)->(EasyRecCount()) == 0
      cRetMsg := STR0020 //Não existem arquivos a serem enviados para este serviço.
      lRet:= .F.
      Break
   EndIf

   cTitulo:= StrTran(STR0026,"XXX",AllTrim((cAlias)->E12_NRINVO)) //Gravação do retorno da integração Facisc - Invoice: 'XXX'
   Define MsDialog oDlg Title cTitulo From 0, 0 To nInferior, nDireita Pixel Of oMainWnd

      TRadMenu():New(20, 10, {STR0027, STR0028}, bRadio, oDlg,,,,,,,, 50, 40,,,, .T.) //Aceitos, Rejeitados
      TSay():New(50, 10, {|| STR0029}, oDlg,,,,,, .T.) //Observações
      oMultiGet:= TMultiGet():New(60, 10, bGet, oDlg, 231, 30,,,,,, .T.)
      oMultiGet:lWordWrap:= .T.

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered


   If lOk

      cPreemb  := (cAlias)->E12_PREEMB
      cInvoice := (cAlias)->E12_NRINVO
 
      E12->(DbSetOrder(4)) //E12_PREEMB+E12_INVOICE+E12_ARQTIP
      If E12->(DbSeek(xFilial()+cPreemb+cInvoice+"F"))
         aAdd(aArquivos,{AllTrim(E12->E12_ARQUIV),cPreemb,cInvoice})
      EndIf

      E12->(DbSetOrder(4))
      If E12->(DbSeek(xFilial()+cPreemb+cInvoice+"C"))
         aAdd(aArquivos,{AllTrim(E12->E12_ARQUIV),cPreemb,cInvoice})
      EndIf

      //Atualização do status da tabela E12
      Do Case
         Case nRadio == 1 //Aceitos
            For nCont:=1 To Len(aArquivos)
               E12->(DBSetOrder(3)) //E12_FILIAL + E12_ARQUIV + E12_PREEMB + E12_NRINVO
               If E12->(DBSeek(xFilial() + AvKey(aArquivos[nCont][1],"E12_ARQUIV") + AvKey(aArquivos[nCont][2],"E12_PREEMB") + AvKey(aArquivos[nCont][3],"E12_NRINVO")))
                  Begin Transaction
                     If E12->(RecLock("E12", .F.))
                        E12->E12_STATUS:= ST_A
                        E12->E12_OBSERV:= StrTran(cObs, ENTER, " ")
                        E12->(MsUnlock())
                     EndIf
                  End Transaction
               EndIf
            Next
            cRet := STR0030
            lRet := .T.
            Break
         Case nRadio == 2 //Rejeitados
            For nCont:=1 To Len(aArquivos)
               E12->(DBSetOrder(3)) //E12_FILIAL + E12_ARQUIV + E12_PREEMB + E12_NRINVO
               If E12->(DBSeek(xFilial() + AvKey(aArquivos[nCont][1],"E12_ARQUIV") + AvKey(aArquivos[nCont][2],"E12_PREEMB") + AvKey(aArquivos[nCont][3],"E12_NRINVO")))
                  Begin Transaction
                     If E12->(RecLock("E12", .F.))
                        E12->E12_STATUS:= ST_R
                        E12->E12_OBSERV:= cObs
                        E12->(MsUnlock())
                     EndIf
                  End Transaction
               EndIf
            Next
            cRet := STR0030
            lRet:= .T.
            Break
         OtherWise
            cRet := "Operação não realizada."
            lRet:= .F.
            Break
      End Case
   Else
      cRet := "Operação não realizada."
      lRet := .F.
      Break
   EndIf

End Sequence

MsgInfo(cRet, "Atenção") //Operação finalizada com sucesso.

Return lRet

/*==================================================================================================================
* Função    : EI103VisualArq
* Objetivo  : Ler os arquivos de integração gerados e chamar a função para a visualização. Será mantido o
              último arquivo gerado e o último arquivo enviado, de acordo com o status do processo.
* Parâmetros: 
* Retorno   : Nil
* Autor     : Bruno Akyo Kubagawa
* Data      : 27/08/2009
* Obs.      : 
==================================================================================================================*/
Function EI103VisualArq()
Local cArquivo  := Space(0),;
      cDiretorio:= Space(0),;
      cAlias    := Alias(),;
      cBuffer   := Space(0),;
      cPreemb   := Space(0),;
      cInvoice  := Space(0)
Local lRet      := .T.
Local nTamArq
Local hFile

Begin Sequence

   If (cAlias)->(EasyRecCount()) == 0
      cRetMsg := STR0020 //Não existem arquivos a serem enviados para este serviço.
      lRet:= .F.
      Break
   EndIf

   //Posiciona a tabela EEC no embarque correspondente
   EEC->(DBSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
   EEC->(DBSeek(xFilial() + AvKey((cAlias)->E12_PREEMB, "EEC_PREEMB")))

   cPreemb    := AllTrim((cAlias)->E12_PREEMB)
   cInvoice   := AllTrim((cAlias)->E12_NRINVO)

   If (cAlias)->E12_STATUS == ST_N
      cDiretorio:= cDirGerado + xFilial("EEC") + AllTrim(cPreemb) + If(!Empty(cInvoice), "\" + AllTrim(cInvoice) + "\", "")
   Else
      cDiretorio:= cDirEnviado + xFilial("EEC") + AllTrim(cPreemb) + If(!Empty(cInvoice), "\" + AllTrim(cInvoice) + "\", "")
   EndIf

   cArquivo:= SubStr((cAlias)->E12_ARQUIV, 1, At(".", (cAlias)->E12_ARQUIV)-1) + ".txt"

   hFile:= EasyOpenFile(cDiretorio + cArquivo, FO_READ)
   If hFile == -1
      cRetMsg := StrTran(STR0031,"XXX",cArquivo) //O arquivo 'XXX' não pode ser aberto.
      lRet:= .F.
      Break
   EndIf

   //Lê o tamanho do arquivo e retorna à posição inicial
   nTamArq:= FSeek(hFile, 0, FS_END)
   FSeek(hFile, 0)

   If FRead(hFile, @cBuffer, nTamArq) <> nTamArq
      cRetMsg := StrTran(STR0031,"XXX",cArquivo) //O arquivo 'XXX' não pode ser aberto.
      lRet:= .F.
      Break
   EndIf

   //Função para a visualização do arquivo
   VisualArqEI103(cBuffer)

   FClose(hFile)

End Sequence

If !lRet
   MsgInfo(cRetMsg,"Atenção")
EndIf

Return Nil

/*==================================================================================================================
* Função    : ValidGeraArqEI103
* Objetivo  : Verificar se já existe arquivo gerado para este processo (com base na tabela E12).
              Caso possua arquivo com o status enviado, o usuário será informado e o arquivo não será gerado.
              Caso possua arquivo com o status não enviado, o usuário será informado e o sistema solicitará
              a confirmação do usuário antes da geração do arquivo. O arquivo gerado substituirá o existente,
              inclusive as informações da tabela.
              Quando o status do arquivo for aceito e for fatura comercial / certificado de origem, o usuário será
              informado que o processo possui integração concluída e não gerará novo arquivo.
              Arquivos com o status rejeitado serão recriados com o mesmo critério de uma primeira geração.
* Parâmetros: cPreemb - Código do Processo
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 27/08/2009
* Obs.      :
==================================================================================================================*/
Static Function ValidGeraArqEI103(cPreemb, cInvoice)
Local lRet      := .T.
Local i         := 0
Local cArquivo  := Space(0)
Local lRetFATCO := .F.
Begin Sequence

/*=========== Estrutura do vetor aNomeArq ==============
{
  n. Arquivo da fatura
  m. Arquivo do certificado
  o. Tipo do arquivo (Fatura ou Certificado)
}
========================================================*/

   //Verifica se já existe o arquivo para este processo para o arquivo de Fatura
   For i := 1 To Len(aNomeArq)
      E12->(DBSetOrder(3)) //E12_FILIAL + E12_ARQUIV + E12_PREEMB + E12+NRINVO + E12_STATUS
      If E12->(DBSeek(xFilial("E12") + AvKey(aNomeArq[i][1], "E12_ARQUIV") + AvKey(cPreemb,"E12_PREEMB") + AvKey(cInvoice,"E12_NRINVO")))

         //Se existe arquivo com o status enviado, não será gerado outro
         If E12->E12_STATUS == ST_E
            cRetMsg := STR0034 + AllTrim(cPreemb) + ; //O arquivo não será gerado pois o processo 
                       STR0035 + DtoC(E12->E12_DATAEN) +;  //  possui arquivo enviado em 
                       STR0036 + AllTrim(E12->E12_USUAEN) + "." // pelo usuário
            lRet := .F.
            Break
         EndIf

         //Se existe arquivo com o status não enviado, o sistema irá sugerir a geração de um outro arquivo,
         //substituindo as informações do anterior, inclusive no histórico da tabela E12.
         If E12->E12_STATUS == ST_N
            lRetFATCO := .T.
            cArquivo += E12->E12_ARQUIV + Space(1)
         EndIf 

         //Quando o status do arquivo for aceito o usuário será informado que o processo possui integração
         //concluída e não será gerado novo arquivo.
         If E12->E12_STATUS == ST_A
            cRetMsg := STR0043 //O processo de integração com a Facisc foi concluído para este embarque. O status do arquivo está definido como 'A' - aceito.
            lRet := .F.
            Break
         EndIf

      EndIf
   Next i

End Sequence

If lRetFATCO
   lRet := MsgYesNo(STR0037 + AllTrim(cPreemb) + STR0038 + AllTrim(cArquivo) + STR0039 + DtoC(E12->E12_DATACR) +;  //O processo , possui arquivos gerados ' , ' em
           STR0040 + AllTrim(E12->E12_USUACR) + STR0041, "Atenção") // pelo usuário , com o Status 'Não Enviado'. Deseja substituí-lo?
   If !lRet
      cRetMsg := STR0042 //O arquivo não foi substituído.
      lRet := .F.
      Break
   EndIf
EndIf

Return lRet

/*=================================================================================================================
* Função    : CriaDiretorioEI103
* Objetivo  : Cria o diretório para armazenar os arquivos de integração
* Parâmetros: cDirTxt - diretório para a criação do arquivo TXT
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 23/08/2010
* Obs.      :
=================================================================================================================*/
Static Function CriaDiretorioEI103(cDirTxt)
Local cDirTemp:= Space(0)
Local nPos
Local lRet:= .T.

Begin Sequence

   //Verificação da existência de cada diretório para criação
   If !lIsDir(cDirTxt)

      nPos := At("\", cDirTxt)
      cDirTemp:= Lower(SubStr(cDirTxt, 1, nPos))
      cDirTxt := Lower(SubStr(cDirTxt, nPos + 1, Len(cDirTxt)))

      While nPos > 0

         If Len(AllTrim(cDirTemp)) > 1 .AND. !lIsDir(cDirTemp)
            MakeDir(cDirTemp)
         EndIf

         nPos:= At("\", cDirTxt)

         cDirTemp += SubStr(cDirTxt, 1, nPos)
         cDirTxt  := SubStr(cDirTxt, nPos + 1, Len(cDirTxt))

      End
      cDirTxt:= cDirTemp
   EndIf

   If !lIsDir(cDirTxt)
      cRetMsg := StrTran(STR0044, "XXX", AllTRim(cDirTxt)) //Não foi possível criar o diretório 'XXX'.
      lRet:= .F.
      Break
   EndIf

End Sequence

Return lRet

/*==================================================================================================================
* Função    : FaciscCriaTxtEI103
* Objetivo  : Geração dos arquivos TXT, com base no array aCols.
* Parâmetros: cDirTxt  - diretório para a criação do arquivo TXT
              aNomeTxt - vetor com os nomes do arquivo TXT (com a extensão)
              aCols - array com os dados a serem escritos no arquivo TXT
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 23/08/2010
* Obs.      :
==================================================================================================================*/
Static Function FaciscCriaTxtEI103(cDirTxt , aNomeTxt , aCols)
Local aBuffer := {}
Local hFile
Local lRet:= .T.
Local i := 0 ,;
      j := 0

Begin Sequence

   For i := 1 To Len(aCols)
      For j := 1 To Len(aCols[i])
         // o vetor aCols em sua primeria dimensao está carregado com os dados da fatura 
         // e na segunda dimensao está carregado com os dados certificado de origem.
         // Assim o vetor aNomeTxt está carregado na primeira dimensão com os nomes dos arquivos das faturas de 
         // acordo com os números da Invoice e a segunda dimensão com os nomes dos arquivos dos certificados.
         aAdd(aBuffer,Buffer(aCols[i][j], aIds[1][i]))
         If Empty(aBuffer[j])
            lRet := .F.
            Break
         EndIf
      Next
   Next
      
   For i:=1 To Len(aNomeTxt)
      //Arquivo de integração
      hFile := EasyCreateFile(cDirTxt + aNomeTxt[i][1], FC_READONLY)
      If hFile == -1
         cRetMsg := StrTran(STR0045, "XXX" , AllTrim(aNomeTxt[i][1])) //O arquivo 'XXX' não pode ser criado.
         lRet:= .F.
         Break
      EndIf
      If FWrite(hFile, aBuffer[i], Len(aBuffer[i])) < Len(aBuffer[i])
         cRetMsg := StrTran(STR0046, "XXX" , AllTrim(aNomeTxt[i][1])) //O arquivo 'XXX' não pode ser gerado.
         lRet:= .F.
         Break
      EndIf
      FClose(hFile)   
   Next

   If lRet
      MsgInfo(STR0047, "Atenção") //Arquivos gerados com sucesso.
   EndIf

End Sequence

Return lRet

/*==================================================================================================================
* Função    : FaciscAtuE12EI103
* Objetivo  : Gravação dos dados da geração do arquivo na tabela de históricos
* Parâmetros: cArquivo - diretório para a criação do arquivo TXT
              cPreemb - Código do Processo
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 23/08/2010
* Obs.      :
==================================================================================================================*/
Static Function FaciscAtuE12EI103(cArquivo, cPreemb , cInvoice, cArqTipo)
Local cAlias:= "E12"
Local lInclui:= .F.

Begin Sequence

   DBSelectArea(cAlias)
   DBSetOrder(3) //E12_FILIAL + E12_ARQUIV + E12_PREEMB + E12_NRINVO
   //Se o registro não existe na tabela, será criado outro
   lInclui:= !E12->(DBSeek(xFilial("E12") + AvKey(cArquivo, "E12_ARQUIV") + AvKey(cPreemb,"E12_PREEMB") + AvKey(cInvoice,"E12_NRINVO")))

   Begin Transaction
      If RecLock(cAlias, lInclui)
         E12_FILIAL := xFilial(cAlias)
         E12_ARQUIV := cArquivo
         E12_TIPO   := FAT_CERT
         E12_STATUS := ST_N
         E12_PREEMB := cPreemb
         E12_NRINVO := cInvoice
         E12_ARQTIP := cArqTipo
         E12_USUACR := cUserName
         E12_DATACR := dDataBase
         E12_HORACR := Time()
         E12->(MSUnlock())
      EndIf
   End Transaction
End Sequence
Return

/*=================================================================================================================
* Função    : VerifAcordoEI103
* Objetivo  : Listar os acordos comerciais existentes para o processo de exportação com base no código da norma
              gravado no item do processo, quando houver mais de um acordo comercial vinculado.
* Parâmetros: cPreemb - Código do Processo
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 23/08/2010
* Obs.      :
=================================================================================================================*/
Static Function VerifAcordoEI103(cPreemb)
Local aCodNorma := {},;
      aAcordo   := {},;
      aItens    := {}
Local lRet      := .T.
Local bList  := {|x| If(Pcount() > 0, cAcordoCom:= x, cAcordoCom)},;
      bOk    := {|| oDlg:End()},;
      bCancel:= {|| lRet:= .F., oDlg:End()}
Local nInferior:= 200,;
      nDireita := 400,;
      nCont
Local oDlg,;
      oList


Begin Sequence

   //Coletando os códigos das normas existentes nos itens do processo
   EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
   If EE9->(DBSeek(xFilial("EE9") + cPreemb))
      Do While EE9->(!EOF()) .and. EE9->(EE9_FILIAL+EE9_PREEMB) == xFilial("EE9")+AvKey(AllTrim(cPreemb),"EE9_PREEMB")
         //Se o código da norma estiver preenchido adiciona-o no array, caso já não tenha sido.
         If !Empty(EE9->EE9_CODNOR) .And.AScan(aCodNorma, EE9->EE9_CODNOR) == 0
            AAdd(aCodNorma, EE9->EE9_CODNOR)
         EndIf
         EE9->(DBSkip())
      EndDo

      //Verificação de quais acordos comerciais as normas estão relacionadas
      EEI->(DBSetOrder(1)) //EEI_FILIAL + EEI_COD
      For nCont:= 1 To Len(aCodNorma)
         If EEI->(DBSeek(xFilial("EEI") + aCodNorma[nCont]))
            If Empty(EEI->EEI_ACCOME)
               cRetMsg := StrTran(STR0048, "XXX", AllTrim(aCodNorma[nCont])) //O campo 'Acordo Com.' não foi preenchido no cadastro da norma. Atualize a tabela 'Normas' antes de prosseguir: 'XXX'.
               lRet:= .F.
               Break
            EndIf

            If AScan(aAcordo, EEI->EEI_ACCOME) == 0
               AAdd(aAcordo, EEI->EEI_ACCOME)
            EndIf

         Else
            cRetMsg := STR0049 //O código da norma vinculado ao item do processo não foi localizado. Revise os itens do processo de embarque antes de prosseguir.
            lRet:= .F.
            Break
         EndIf
      Next
   EndIf

   If Empty(aAcordo)
      cRetMsg := STR0065 //A norma não está vinculado com o item do embarque. Revise o vinculo entre o pais de entrega, acordo comercial e a norma.
      lRet:= .F.
      Break
   EndIf
 
   
   If Len(aAcordo) == 1
      cAcordoCom := aAcordo[1]
   Else

      For nCont:= 1 To Len(aAcordo)
         /*=============================Estrutura aItens==========================
         1. Código do acordo + descrição do acordo
         =========================================================================*/
         AAdd(aItens, aAcordo[nCont] + " - " + Posicione("E11", 1, E11->(xFilial("E11")) + ;
                                                          aAcordo[nCont], "E11_DESRED"))
      Next


      //Criação da tela para que o usuário possa escolher qual Acordo Comercial
      //usado na geração do arquivo de integração
      Define MsDialog oDlg Title STR0050 From 0, 0 To nInferior, nDireita Pixel Of oMainWnd //Acordo Comercial

         oSay:= TSay():New(20, 20, {|| STR0051}, oDlg,,,,,, .T.,,, 160, 40) //Este processo possui mais de um Acordo Comercial vinculado. Selecione um para a geração do arquivo de integração com a Facisc ou revise as normas de origem vinculadas aos itens do processo.
         oSay:lWordWrap:= .T.
         oList:= TListBox():New(50, 20, bList, aItens, 160, 40,, oDlg,,,, .T.,, bOk)
         oList:Select(1)

      Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered
   
   EndIf

   cAcordoCom := SubStr(cAcordoCom, 1, AvSX3("EEI_ACCOME", AV_TAMANHO))
   
   If Empty(cAcordoCom)
      cRetMsg := STR0052 //Foi encontrada uma inconsistência no cadastro de 'Acordos Comerciais'.
      lRet:= .F.
   EndIf

   If E11->(FieldPos("E11_INTEGR")) > 0
      E11->(DbSetOrder(1))
      If E11->(DbSeek(xFilial()+cAcordoCom))
         If AllTrim(E11->E11_INTEGR) != "FACISC"
            cRetMsg := STR0052 + Replic(ENTER,2) +;//Foi encontrada uma inconsistência no cadastro de 'Acordos Comerciais'.
                       "Verifique o campo 'Integração'." 
            lRet:= .F.
            Break
         EndIf
      EndIf
   EndIf

End Sequence

Return lRet

/*=========================================================================================
Função    : FatLayoutEI103
Objetivo  : Buscas das Informações para a FATURA.
Parâmetros: cPreemb - Código do Processo
Retorno   : aCols
Autor     : Bruno Akyo Kubagawa
Data      : 23/08/2010
Obs.      :
===========================================================================================*/
Static Function FatLayoutEI103(cPreemb, cInvoice)
Local lRet         := .T.
Local aHeader      := {},;
      aDetail      := {},;
      aTrailler    := {},;
      aCols        := {},;
      aProdEXR     := {}
Local cCondPgto    := Space(0),;
      cPaisOrigem  := Space(0),;
      cPortoDes    := Space(0),;
      cTipoEmb     := Space(0),;
      cMoedaSeg    := Space(0),;
      cMoedaFrete  := Space(0),;
      cObsCont     := Space(0),;
      cDescNavio   := Space(0),;
      cPortoEmb    := Space(0),;
      cUnidade     := Space(0),;
      cDescItem    := Space(0),;
      cExtArq      := ".txt"
Local nTotCaixa    := 0,;
      i            := 0,;
      j            := 0,;
      nPrecoUnItem := 0,;
      nPesoLiqItem := 0

/*============Estrutura aHeader e aTrailler=============
1. Infomação do Campo (Dicionario de Dados)
========================================================*/

/*===================Estrutura aDetail==================
1. Infomação de cada item (Dicionario de Dados)
========================================================*/

/*====================Estrutura aCols===================
1. aHeader   - vetor com as informações do cabeçalho
2. aDetail   - vetor com as informações do itens
3. aTrailler - vetor com as informações do rodapé
========================================================*/

Begin Sequence
   
   If Empty(cPreemb)
      cRetMsg := STR0053 //O processo de embarque não foi informado.
      lRet := .F.
      Break
   EndIf

   EEC->(DbSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
   If !EEC->(DBSeek(xFilial()+AllTrim(cPreemb)))
      cRetMsg := StrTran(STR0054, "XXX", AllTrim(cPreemb)) //O processo de embarque 'XXX' não foi encontrado na base de dados.
      lRet := .F.
      Break
   Else

//=============================== Informações da CAPA do Embarque ===========================
//====================== Inicio da gravação dos cabeçalho desta fatura ====================== 
      //Carregando a descrição do Navio
      If !Empty(EEC->EEC_EMBARC)
         cDescNavio := Posicione("EE6",1,xFilial("EE6")+AllTrim(EEC->EEC_EMBARC),"EE6_NOME")
      EndIf

      //Carregando a descrição da cond. de pagamento
      If !Empty(EEC->EEC_CONDPA)
         SY6->(DbSetOrder(1))
         If SY6->(DbSeek(xFilial("SY6")+AllTrim(EEC->EEC_CONDPA)))
            cCondPgto := AllTrim(MSMM(SY6->Y6_DESC_P, 48,,, LERMEMO))
         EndIf
      EndIf

      //Carregando a Origem (Descrição do Pais) e o Porto de Origem
      If !Empty(EEC->EEC_ORIGEM)
         SY9->(DbSetOrder(2)) //Y9_FILIAL + Y9_SIGLA
         If SY9->(DbSeek(xFilial("SY9")+AllTrim(EEC->EEC_ORIGEM)))
            cPortoEmb := AllTrim(SY9->Y9_DESCR)
            cPaisOrigem := Posicione("SYA",1,xFilial("SYA")+AllTrim(SY9->Y9_PAIS),"YA_DESCR")
         EndIf
      EndIf

      //Carregando o Porto de Destino
      If !Empty(EEC->EEC_DEST)
         cPortoDes := Posicione("SY9",2,xFilial("SY9")+AllTrim(EEC->EEC_DEST),"Y9_DESCR")
      EndIf

      //Carregando o Tipo de Embalagem
      If !Empty(EEC->EEC_EMBAFI)
         cTipoEmb := Posicione("EE5",1,xFilial("EE5")+AllTrim(EEC->EEC_EMBAFI),"EE5_DESC")
      EndIf

      //Adicionando no vetor aProdEXA os códigos do container e os produtos
      EX9->(DbSetOrder(1)) // EX9_FILIAL + EX9_PREEMB + EX9_CONTNR
      If !EX9->(DbSeek(xFilial("EX9")+cPreemb))
         
         //DFS - 11/01/13 - Caso não encontre registros na tabela EX9, trás os registros da tabela EE9.
         EE9->(DbSetOrder(2))
         EE9->(DbSeek(xFilial()+cPreemb))
         While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+cPreemb)
	         aAdd(aProdEXA,{"", EE9->EE9_SEQEMB, "", EE9->EE9_SLDINI, ""})
	         EE9->(DbSkip())
	     EndDo
         
         /*
         cRetMsg := StrTran(STR0056, "XXX", AllTrim(cPreemb)) //O processo de embarque 'XXX' não possui container na base de dados.
         lRet := .F.
         Break
         */
         
      Else
         Do While EX9->(!Eof()) .And. EX9->(EX9_FILIAL + EX9_PREEMB) == xFilial("EX9")+AvKey(AllTrim(cPreemb),"EX9_PREEMB")
            If EECFlags("ESTUFAGEM")
            	aEval(GetProds(EX9->EX9_ID), {|x| aAdd(aProdEXA, x) })
            Else
	            EXA->(DbSetOrder(1)) // EXA_FILIAL + EXA_PREEMB + EXA_CONTNR + EXA_SEQEMB + EXA_LOTE
	            If EXA->(DbSeek(xFilial("EXA") + cPreemb + EX9->EX9_CONTNR))
	               Do While EXA->(!Eof()) .And. AllTrim(EXA->EXA_PREEMB) == AllTrim(cPreemb) .And. AllTrim(EXA->EXA_CONTNR) == AllTrim(EX9->EX9_CONTNR) 
	                  aAdd(aProdEXA,{EXA->EXA_CONTNR,EXA->EXA_SEQEMB,EXA->EXA_LOTE,EXA->EXA_QTDE,MSMM(EX9->EX9_OBS,60,,, LERMEMO)})
	                  EXA->(DbSkip())
	               EndDO
	            EndIf
	        EndIf
            EX9->(DbSkip())
         EndDo
      EndIf
      //***

      //*** RMD - 07/12/12 - Permite que não seja obrigatório o envio de informações de containeres.
      //If Empty(aProdEXA)
      //   cRetMsg := StrTran(STR0066, "XXX", AllTrim(cPreemb)) //O container do processo 'XXX' não está carregado.
      //   lRet := .F.
      //   Break
      //EndIf
      //***

//================================= Informações das Invoices ================================
      EXP->(DbSetOrder(1))
      If EXP->(DbSeek(xFilial()+EEC->EEC_PREEMB+cInvoice))
         While EXP->(!Eof() .And. EXP_FILIAL + EXP_PREEMB + EXP_NRINVO == xFilial() + EEC->EEC_PREEMB + cInvoice)
            aHeader   := {}
			aDetail   := {}
			aTrailler := {}
			nTotCaixa := 0

                  //Vetor para os nomes dos arquivos de fatura.
                  aAdd(aNomeArq,{"FATURA-" + AllTrim(EEC->EEC_PREEMB) + "-" + AllTrim(EXP->EXP_NRINVO) + cExtArq,"F"})

                  //Vetor para os informações das invoices.
                  aAdd(aInvoices,{EXP->EXP_NRINVO,EXP->EXP_DTINVO})

                  aAdd(aHeader,aIds[2][4] + ;
/*Importador*/    If(Empty(EEC->EEC_IMPODE), aIds[2][4],AllTrim(EEC->EEC_IMPODE) + aIds[2][4]))
/*NrInvoice*/     aAdd(aHeader,If(Empty(EXP->EXP_NRINVO), aIds[2][4],AllTrim(EXP->EXP_NRINVO) + aIds[2][4]))
/*DataInvoice*/   aAdd(aHeader,If(Empty(EXP->EXP_DTINVO), aIds[2][4],AllTrim(PictureDt(EXP->EXP_DTINVO)) + aIds[2][4]))
/*Navio*/         aAdd(aHeader,If(Empty(cDescNavio)     , aIds[2][4],AllTrim(cDescNavio) + aIds[2][4]))
/*DataEmbarque*/  aAdd(aHeader,If(Empty(EEC->EEC_DTEMBA), aIds[2][4],AllTrim(PictureDt(EEC->EEC_DTEMBA)) + aIds[2][4]))
/*CondPagto*/     aAdd(aHeader,If(Empty(cCondPgto)      , aIds[2][4],AllTrim(cCondPgto) + aIds[2][4]))
/*Origem*/        aAdd(aHeader,If(Empty(cPaisOrigem)    , aIds[2][4],AllTrim(cPaisOrigem) + aIds[2][4]))
/*PortoEmbarque*/ aAdd(aHeader,If(Empty(cPortoEmb)      , aIds[2][4],AllTrim(cPortoEmb) + aIds[2][4]))
/*PortoDestino*/  aAdd(aHeader,If(Empty(cPortoDes)      , aIds[2][4],AllTrim(cPortoDes) + aIds[2][4]))
/*Marcas*/        aAdd(aHeader,If(Empty(EEC->EEC_CODMAR), aIds[2][4],AllTrim(MSMM(EEC->EEC_CODMAR, 40,,, LERMEMO)) + aIds[2][4]))
/*TipoEmbalagem*/ aAdd(aHeader,If(Empty(cTipoEmb)       , aIds[2][4],AllTrim(cTipoEmb) + aIds[2][4]))
/*Observacao*/    aAdd(aHeader,If(Empty(EEC->EEC_CODMEM), aIds[2][4],AllTrim(MSMM(EEC->EEC_CODMEM, 60,,, LERMEMO)) + aIds[2][4]))
/*Moeda1*/        aAdd(aHeader,If(Empty(EEC->EEC_MOEDA) , aIds[2][4],AllTrim(EEC->EEC_MOEDA) + aIds[2][4]))
/*Moeda2*/        aAdd(aHeader,If(Empty(EEC->EEC_MOEDA) , aIds[2][4],AllTrim(EEC->EEC_MOEDA) + aIds[2][4]))
//===================== Fim da gravação dos cabeçalho desta fatura ====================== 

//====================== Inicio da gravação dos itens desta fatura ====================== 
            EXR->(DbSetOrder(1))
            EXR->(DbSeek(xFilial()+EXP->(EXP_PREEMB+EXP_NRINVO)))
            Do While EXR->(!Eof() .And. EXR_FILIAL+EXR_PREEMB+EXR_NRINVO == xFilial()+EXP->(EXP_PREEMB+EXP_NRINVO)) 
                   
                  //Armazenando a unidade do produto
                  EE9->(DbSetOrder(3))
                  If EE9->(DbSeek(xFilial("EE9") + EXR->EXR_PREEMB + EXR->EXR_SEQEMB))
                      cDescItem    := AllTrim(MSMM(EE9->EE9_DESC, 30,,, LERMEMO))
                      nPesoLiqItem := EE9->EE9_PSLQUN
                      nPrecoUnItem := EE9->EE9_PRECO
                      SB1->(DbSetOrder(1))
                      If SB1->(DbSeek(xFilial("SB1")+EE9->EE9_COD_I))
                         cUnidade  := Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_UNIMED")
                      EndIF
                   EndIf
                   
                   aAdd(aDetail,{aIds[2][4] +;
/*QtdeItem*/       If(Empty(EXR->EXR_SLDINI), aIds[2][4],AllTrim(Transf(EXR->EXR_SLDINI,"@R 999,999,999,999")) + If (!Empty(cUnidade),Space(1) + AllTrim(cUnidade)+aIds[2][4],aIds[2][4])),;
/*PesoLiqItem*/    If(Empty(nPesoLiqItem)   , aIds[2][4],AllTrim(Transf(nPesoLiqItem,"@R 999,999,999.999")) + aIds[2][4]),;
/*DescMaterial*/   If(Empty(cDescItem)      , aIds[2][4],AllTrim(cDescItem) + aIds[2][4]),;
/*PrecoUnitItem*/  If(Empty(nPrecoUnItem)   , aIds[2][4],AllTrim(Transf(nPrecoUnItem,"@R 999,999,999,999.99")) + aIds[2][4]),;
/*PrecoTotItem*/   If(Empty(EXR->EXR_PRCTOT), aIds[2][4],AllTrim(Transf(EXR->EXR_PRCTOT,"@R 999,999,999,999.99")) + aIds[2][4])})

                   //Armazenando o Total de Caixa
                   nTotCaixa += EXR->EXR_SLDINI
                   aAdd(aProdEXR,EXR->EXR_SEQEMB)
		           EXR->(DbSkip())
			EndDo            
//====================== Fim da gravação dos itens desta fatura//====================== 
			
//====================== Inicio da gravação das informações do Rodapé====================== 
            EXL->(DbSetOrder(1)) // EXL_FILIAL + EXL_PREEMB
            If EXL->(DbSeek(xFilial("EXL")+AllTrim(cPreemb)))
               //Carregando MoedaSeg e MoedaFrete
               cMoedaSeg   := If(Empty(EXL->EXL_MDSE),Space(0),AllTrim(EXL->EXL_MDSE))
               cMoedaFrete := If(Empty(EXL->EXL_MDFR),Space(0),AllTrim(EXL->EXL_MDFR))
            EndIf

            //Armazenando a obervação do container
            For i:=1 To Len(aProdEXR)
               For j:=1 To Len(aProdEXA)
                  If aProdEXA[j][2] == aProdEXR[i] .And. At(aProdEXA[j][5],cObsCont) == 0 .And. Rat(aProdEXA[j][5],cObsCont) == 0
                     cObsCont += Alltrim(aProdEXA[j][5]) + Space(1)
                  EndIf
               Next
            Next

/*Message*/      aAdd(aTrailler,aIds[2][4] + if(Empty(EEC->EEC_CODOBP), aIds[2][4],AllTrim(MSMM(EEC->EEC_CODOBP, 60,,, LERMEMO)) + aIds[2][4]))
/*Obsrodape*/    aAdd(aTrailler,aIds[2][4])
/*TotCaixas*/    aAdd(aTrailler,If(Empty(nTotCaixa)      , aIds[2][4],AllTrim(Str(nTotCaixa)) + aIds[2][4]))
/*TotPesLiq*/    aAdd(aTrailler,If(Empty(EXP->EXP_PESLIQ), aIds[2][4],AllTrim(Transf(EXP->EXP_PESLIQ,"@R 999,999,999.999")) + aIds[2][4]))
/*TotPesBru*/    aAdd(aTrailler,If(Empty(EXP->EXP_PESBRU), aIds[2][4],AllTrim(Transf(EXP->EXP_PESBRU,"@R 999,999,999.999")) + aIds[2][4]))
/*MoedFob*/      aAdd(aTrailler,If(Empty(EEC->EEC_MOEDA) , aIds[2][4],AllTrim(EEC->EEC_MOEDA) + aIds[2][4]))
/*VlrTotFob*/    aAdd(aTrailler,If(Empty(EXP->EXP_VLFOB) , aIds[2][4],AllTrim(Transf(EXP->EXP_VLFOB,"@R 999,999,999,999.99")) + aIds[2][4]))
/*MoedaSeg*/     aAdd(aTrailler,If(Empty(cMoedaSeg)      , aIds[2][4],AllTrim(cMoedaSeg) + aIds[2][4]))
/*VlrTotSeg*/    aAdd(aTrailler,If(Empty(EXP->EXP_SEGPRE), aIds[2][4],AllTrim(Transf(EXP->EXP_SEGPRE,"@R 999,999,999,999.99")) + aIds[2][4]))
/*MoedaFrete*/   aAdd(aTrailler,If(Empty(cMoedaFrete)    , aIds[2][4],AllTrim(cMoedaFrete) + aIds[2][4]))
/*VlrTotFrete*/  aAdd(aTrailler,If(Empty(EXP->EXP_FRPREV), aIds[2][4],AllTrim(Transf(EXP->EXP_FRPREV,"@R 999,999,999,999.99")) + aIds[2][4]))
/*MoedaTotinv*/  aAdd(aTrailler,If(Empty(EEC->EEC_MOEDA) , aIds[2][4],AllTrim(EEC->EEC_MOEDA) + aIds[2][4]))
/*VlrTotInv*/    aAdd(aTrailler,If(Empty(EXP->EXP_TOTPED), aIds[2][4],AllTrim(Transf(EXP->EXP_TOTPED,"@R 999,999,999,999.99")) + aIds[2][4]))
/*ObsContainer*/ aAdd(aTrailler,If(Empty(cObsCont)       , aIds[2][4],AllTrim(cObsCont) + aIds[2][4]))
//====================== Fim da gravação das informações do Rodapé====================== 
            cObsCont := Space(0)
            aProdEXR := {}

            If Empty(aHeader) .Or. Empty(aDetail) .Or. Empty(aTrailler)
               lRet := .F.
               cRetMsg := StrTran(STR0063, "XXX", AllTrim(cPreemb)) //Foi encontrada uma inconsistência no cadastro de 'Invoices' para o processo: 'XXX' durante a geração do arquivo da Fatura.
               Break
            EndIf
            
            //Armazenando o Header, Detail e o Trailler da FATURA
            aAdd(aCols, {aHeader, aDetail, aTrailler})

            EXP->(DbSkip())
         EndDo
      Else
         //*** RMD - 22/11/12 - Considera o embarque como uma fatura única
            aHeader   := {}
			aDetail   := {}
			aTrailler := {}
			nTotCaixa := 0

                  //Vetor para os nomes dos arquivos de fatura.
                  aAdd(aNomeArq,{"FATURA-" + AllTrim(EEC->EEC_PREEMB) + cExtArq,"F"})

                  //Vetor para os informações das invoices.
                  aAdd(aInvoices,{EEC->EEC_PREEMB,EEC->EEC_DTPROC})

                  aAdd(aHeader,aIds[2][4] + ;
/*Importador*/    If(Empty(EEC->EEC_IMPODE), aIds[2][4],AllTrim(EEC->EEC_IMPODE) + aIds[2][4]))
/*NrInvoice*/     aAdd(aHeader,If(Empty(EEC->EEC_PREEMB), aIds[2][4],AllTrim(EEC->EEC_PREEMB) + aIds[2][4]))
/*DataInvoice*/   aAdd(aHeader,If(Empty(EEC->EEC_DTPROC), aIds[2][4],AllTrim(PictureDt(EEC->EEC_DTPROC)) + aIds[2][4]))
/*Navio*/         aAdd(aHeader,If(Empty(cDescNavio)     , aIds[2][4],AllTrim(cDescNavio) + aIds[2][4]))
/*DataEmbarque*/  aAdd(aHeader,If(Empty(EEC->EEC_DTEMBA), aIds[2][4],AllTrim(PictureDt(EEC->EEC_DTEMBA)) + aIds[2][4]))
/*CondPagto*/     aAdd(aHeader,If(Empty(cCondPgto)      , aIds[2][4],AllTrim(cCondPgto) + aIds[2][4]))
/*Origem*/        aAdd(aHeader,If(Empty(cPaisOrigem)    , aIds[2][4],AllTrim(cPaisOrigem) + aIds[2][4]))
/*PortoEmbarque*/ aAdd(aHeader,If(Empty(cPortoEmb)      , aIds[2][4],AllTrim(cPortoEmb) + aIds[2][4]))
/*PortoDestino*/  aAdd(aHeader,If(Empty(cPortoDes)      , aIds[2][4],AllTrim(cPortoDes) + aIds[2][4]))
/*Marcas*/        aAdd(aHeader,If(Empty(EEC->EEC_CODMAR), aIds[2][4],AllTrim(MSMM(EEC->EEC_CODMAR, 40,,, LERMEMO)) + aIds[2][4]))
/*TipoEmbalagem*/ aAdd(aHeader,If(Empty(cTipoEmb)       , aIds[2][4],AllTrim(cTipoEmb) + aIds[2][4]))
/*Observacao*/    aAdd(aHeader,If(Empty(EEC->EEC_CODMEM), aIds[2][4],AllTrim(MSMM(EEC->EEC_CODMEM, 60,,, LERMEMO)) + aIds[2][4]))
/*Moeda1*/        aAdd(aHeader,If(Empty(EEC->EEC_MOEDA) , aIds[2][4],AllTrim(EEC->EEC_MOEDA) + aIds[2][4]))
/*Moeda2*/        aAdd(aHeader,If(Empty(EEC->EEC_MOEDA) , aIds[2][4],AllTrim(EEC->EEC_MOEDA) + aIds[2][4]))
//===================== Fim da gravação dos cabeçalho desta fatura ====================== 

//====================== Inicio da gravação dos itens desta fatura ====================== 
            EE9->(DbSetOrder(3))
            EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
            Do While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+EEC->EEC_PREEMB) 

                   cDescItem    := AllTrim(MSMM(EE9->EE9_DESC, 30,,, LERMEMO))
                   nPesoLiqItem := EE9->EE9_PSLQUN
                   nPrecoUnItem := EE9->EE9_PRECO
                   cUnidade  := Posicione("SAH",1,xFilial("SAH")+EE9->EE9_UNIDAD,"AH_UNIMED")

                   aAdd(aDetail,{aIds[2][4] +;
/*QtdeItem*/       If(Empty(EE9->EE9_SLDINI), aIds[2][4],AllTrim(Transf(EE9->EE9_SLDINI,"@R 999,999,999,999")) + If (!Empty(cUnidade),Space(1) + AllTrim(cUnidade)+aIds[2][4],aIds[2][4])),;
/*PesoLiqItem*/    If(Empty(nPesoLiqItem)   , aIds[2][4],AllTrim(Transf(nPesoLiqItem,"@R 999,999,999.999")) + aIds[2][4]),;
/*DescMaterial*/   If(Empty(cDescItem)      , aIds[2][4],AllTrim(cDescItem) + aIds[2][4]),;
/*PrecoUnitItem*/  If(Empty(nPrecoUnItem)   , aIds[2][4],AllTrim(Transf(nPrecoUnItem,"@R 999,999,999,999.99")) + aIds[2][4]),;
/*PrecoTotItem*/   If(Empty(EE9->EE9_PRCTOT), aIds[2][4],AllTrim(Transf(EE9->EE9_PRCTOT,"@R 999,999,999,999.99")) + aIds[2][4])})

                   //Armazenando o Total de Caixa
                   nTotCaixa += EE9->EE9_SLDINI
                   aAdd(aProdEXR,EE9->EE9_SEQEMB)
               
               EE9->(DbSkip())
			EndDo
//====================== Fim da gravação dos itens desta fatura//====================== 

//====================== Inicio da gravação das informações do Rodapé====================== 
            EXL->(DbSetOrder(1)) // EXL_FILIAL + EXL_PREEMB
            If EXL->(DbSeek(xFilial("EXL")+AllTrim(cPreemb)))
               //Carregando MoedaSeg e MoedaFrete
               cMoedaSeg   := If(Empty(EXL->EXL_MDSE),Space(0),AllTrim(EXL->EXL_MDSE))
               cMoedaFrete := If(Empty(EXL->EXL_MDFR),Space(0),AllTrim(EXL->EXL_MDFR))
            EndIf

            //Armazenando a obervação do container
            For i:=1 To Len(aProdEXR)
               For j:=1 To Len(aProdEXA)
                  If aProdEXA[j][2] == aProdEXR[i] .And. At(aProdEXA[j][5],cObsCont) == 0 .And. Rat(aProdEXA[j][5],cObsCont) == 0
                     cObsCont += Alltrim(aProdEXA[j][5]) + Space(1)
                  EndIf
               Next
            Next

/*Message*/      aAdd(aTrailler,aIds[2][4] + if(Empty(EEC->EEC_CODOBP), aIds[2][4],AllTrim(MSMM(EEC->EEC_CODOBP, 60,,, LERMEMO)) + aIds[2][4]))
/*Obsrodape*/    aAdd(aTrailler,aIds[2][4])
/*TotCaixas*/    aAdd(aTrailler,If(Empty(nTotCaixa)      , aIds[2][4],AllTrim(Str(nTotCaixa)) + aIds[2][4]))
/*TotPesLiq*/    aAdd(aTrailler,If(Empty(EEC->EEC_PESLIQ), aIds[2][4],AllTrim(Transf(EEC->EEC_PESLIQ,"@R 999,999,999.999")) + aIds[2][4]))
/*TotPesBru*/    aAdd(aTrailler,If(Empty(EEC->EEC_PESBRU), aIds[2][4],AllTrim(Transf(EEC->EEC_PESBRU,"@R 999,999,999.999")) + aIds[2][4]))
/*MoedFob*/      aAdd(aTrailler,If(Empty(EEC->EEC_MOEDA) , aIds[2][4],AllTrim(EEC->EEC_MOEDA) + aIds[2][4]))
/*VlrTotFob*/    aAdd(aTrailler,If(Empty(EEC->EEC_VLFOB) , aIds[2][4],AllTrim(Transf(EEC->EEC_VLFOB,"@R 999,999,999,999.99")) + aIds[2][4]))
/*MoedaSeg*/     aAdd(aTrailler,If(Empty(cMoedaSeg)      , aIds[2][4],AllTrim(cMoedaSeg) + aIds[2][4]))
/*VlrTotSeg*/    aAdd(aTrailler,If(Empty(EEC->EEC_SEGPRE), aIds[2][4],AllTrim(Transf(EEC->EEC_SEGPRE,"@R 999,999,999,999.99")) + aIds[2][4]))
/*MoedaFrete*/   aAdd(aTrailler,If(Empty(cMoedaFrete)    , aIds[2][4],AllTrim(cMoedaFrete) + aIds[2][4]))
/*VlrTotFrete*/  aAdd(aTrailler,If(Empty(EEC->EEC_FRPREV), aIds[2][4],AllTrim(Transf(EEC->EEC_FRPREV,"@R 999,999,999,999.99")) + aIds[2][4]))
/*MoedaTotinv*/  aAdd(aTrailler,If(Empty(EEC->EEC_MOEDA) , aIds[2][4],AllTrim(EEC->EEC_MOEDA) + aIds[2][4]))
/*VlrTotInv*/    aAdd(aTrailler,If(Empty(EEC->EEC_TOTPED), aIds[2][4],AllTrim(Transf(EEC->EEC_TOTPED,"@R 999,999,999,999.99")) + aIds[2][4]))
/*ObsContainer*/ aAdd(aTrailler,If(Empty(cObsCont)       , aIds[2][4],AllTrim(cObsCont) + aIds[2][4]))
//====================== Fim da gravação das informações do Rodapé====================== 
            cObsCont := Space(0)
            aProdEXR := {}

            If Empty(aHeader) .Or. Empty(aDetail) .Or. Empty(aTrailler)
               lRet := .F.
               cRetMsg := StrTran(STR0063, "XXX", AllTrim(cPreemb)) //Foi encontrada uma inconsistência no cadastro de 'Invoices' para o processo: 'XXX' durante a geração do arquivo da Fatura.
               Break
            EndIf
            
            //Armazenando o Header, Detail e o Trailler da FATURA
            aAdd(aCols, {aHeader, aDetail, aTrailler})
         //***
      EndIf
   EndIf

End Sequence

If !lRet
   aCols := {}
EndIf

Return aCols

/*=========================================================================================
Função    : CertLayoutEI103
Objetivo  : Buscas das Informações para o Certificado de Origem.
Parâmetros: cPreemb - Código do Processo
Retorno   : aCols
Autor     : Bruno Akyo Kubagawa
Data      : 23/08/2010
Obs.      :
===========================================================================================*/
Static Function CertLayoutEI103(cPreemb, cInvoice)
Local aCols         := {},;
      aDetail       := {},;
      aHeader       := {}
Local lRet          := .T.
Local i             := 0
Local cExtArq       := ".txt"
Local dDataInv
Private cEndImp2    := Space(0),;
        cEndFabr1   := Space(0),;
        cEndFabr2   := Space(0),;
        cEndCons1   := Space(0),;
        cEndCons2   := Space(0),;
        cEndExp1    := Space(0),;
        cEndExp2    := Space(0),;
        cDesExp     := Space(0),;
        cDesCons    := Space(0),;
        cMeioTransp := Space(0),;
        cDesPais    := Space(0),;
        cContainer  := Space(0),;
        cDesFabr    := Space(0),;
        cDescNavio  := Space(0),;
        cPortoEmb   := Space(0),;
        cFabricante := Space(0),;
        cDescNorma  := Space(0)

Begin Sequence

   If Empty(cPreemb)
      cRetMsg := STR0053 //O processo de embarque não foi informado.
      lRet := .F.
      Break
   EndIf
   
//=============================== Inicio das informações da CAPA do Embarque ===========================
   EEC->(DbSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
   If !EEC->(DBSeek(xFilial()+AllTrim(cPreemb)))
      cRetMsg := StrTran(STR0054, "XXX", AllTrim(cPreemb)) //O processo de embarque 'XXX' não foi encontrado na base de dados.
      lRet := .F.
      Break
   Else
      If !Empty(EEC->EEC_IMPORT)
         SA1->(DbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
         //Carregando o endereço do importador.
         If SA1->(DbSeek(xFilial("SA1")+AllTrim(EEC->EEC_IMPORT)))
            cEndImp2 := If(Empty(SA1->A1_BAIRRO),Space(0),AllTrim(SA1->A1_BAIRRO) + ", ") +;
                        If(Empty(SA1->A1_MUN),Space(0),AllTrim(SA1->A1_MUN) + " - ") +;
                        If(Empty(SA1->A1_ESTADO),Space(0),AllTrim(SA1->A1_ESTADO) + " - ") +;
                        If(Empty(SA1->A1_PAIS),Space(0),Posicione("SYA",1,xFilial("SYA")+AllTrim(SA1->A1_PAIS),"YA_DESCR"))
         EndIf
      EndIf

      //Carregando o endereço do consignatário.
      If !Empty(EEC->EEC_CONSIG)
         SA1->(DbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
         If SA1->(DbSeek(xFilial("SA1")+AllTrim(EEC->EEC_CONSIG)))
            cDesCons  := AllTrim(SA1->A1_NOME)
            cEndCons1 := AllTrim(SA1->A1_END)
            cEndCons2 := If(Empty(SA1->A1_BAIRRO),Space(0),AllTrim(SA1->A1_BAIRRO) + ", ") +;
                         If(Empty(SA1->A1_MUN),Space(0),AllTrim(SA1->A1_MUN) + " - ") +;
                         If(Empty(SA1->A1_ESTADO),Space(0),AllTrim(SA1->A1_ESTADO) + " - ") +;
                         If(Empty(SA1->A1_PAIS),Space(0),Posicione("SYA",1,xFilial("SYA")+AllTrim(SA1->A1_PAIS),"YA_DESCR"))
         EndIf
      EndIf

      //Carregando o endereço do exportador.
      If !Empty(EEC->EEC_EXPORT)
         SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
         If SA2->(DBSeek(xFilial("SA2")+EEC->EEC_EXPORT))
            cDesExp  := AllTrim(SA2->A2_NOME)
            cEndExp1 := If(Empty(SA2->A2_END),Space(0),AllTrim(SA2->A2_END)) +;
                        If(Empty(SA2->A2_NR_END),Space(0),", " + AllTrim(SA2->A2_NR_END))
            cEndExp2 := If(Empty(SA2->A2_BAIRRO),Space(0),AllTrim(SA2->A2_BAIRRO) + ", ") + ;
                        If(Empty(SA2->A2_MUN),Space(0),AllTrim(SA2->A2_MUN) + " - ") + ;
                        If(Empty(SA2->A2_ESTADO),Space(0),AllTrim(SA2->A2_ESTADO) + " - ")+;
                        If(Empty(SA2->A2_PAIS),Space(0),Posicione("SYA", 1, SYA->(xFilial("SYA")) + AllTrim(SA2->A2_PAIS), "YA_DESCR"))
         EndIf
      EndIf

      //Carregando a descrição do Navio
      If !Empty(EEC->EEC_EMBARC)
         cDescNavio := Posicione("EE6",1,xFilial("EE6")+AllTrim(EEC->EEC_EMBARC),"EE6_NOME")
      EndIf

      //Carregando a Origem (Descrição do Pais) e o Porto de Origem
      If !Empty(EEC->EEC_ORIGEM)
         cPortoEmb := Posicione("SY9",2,xFilial("SY9")+AllTrim(EEC->EEC_ORIGEM),"Y9_DESCR")
      EndIf

      //Carregando a Descriçao do Destino
      If !Empty(EEC->EEC_DEST)
         SY9->(DbSetOrder(2)) //Y9_FILIAL + Y9_SIGLA
         If SY9->(DbSeek(xFilial("SY9")+AllTrim(EEC->EEC_DEST)))
            cDesPais := Posicione("SYA",1,xFilial("SYA")+AllTrim(SY9->Y9_PAIS),"YA_DESCR")
         EndIf
      EndIf

      //Carregando Meio de Transporte
      If !Empty(EEC->EEC_VIA)
         cMeioTransp := Posicione("SYQ",1,xFilial("SYQ")+AllTrim(EEC->EEC_VIA),"YQ_DESCR")
      EndIf
    
      //Carregando o acordo comercial
      If !VerifAcordoEI103(cPreemb)
         lRet := .F.
         Break
      EndIf
//================================= Final das informações da CAPA do Embarque ============================

//=============================== Carregando as informações do Header e Detail ===========================
      For i := 1 To Len(aInvoices)
         
         cInvoice := aInvoices[i][1]
		 dDataInv := aInvoices[i][2]
		 
         aHeader := GeraCOHeader(cPreemb, cInvoice, dDataInv)
         aDetail := GeraCODetail(cPreemb, cInvoice)

         If Empty(aHeader) .Or. Empty(aDetail)
            lRet := .F.
            Break
         EndIf

         //Vetor para os nomes dos arquivos de certificado de origem.
         aAdd(aNomeArq,{"CO-" + AllTrim(EEC->EEC_PREEMB) + "-" + AllTrim(cInvoice) + cExtArq,"C"})

         //Armazenando o Header e Detail do Certificado de Origem	     
		 aAdd(aCols, {aHeader, aDetail})

	  Next
   EndIf

End Sequence

If !lRet
   aCols := {}
EndIf

Return aCols

/*=========================================================================================
Função    : GeraCOHeader
Objetivo  : Preenchimento do aHeader para certificado de origem.
Parâmetros: cPreemb  - Código do Processo
            cInvoice - Nº da Invoice
            dDataInv - Data da Invoice
Retorno   : aCols
Autor     : Bruno Akyo Kubagawa
Data      : 23/08/2010
Obs.      :
===========================================================================================*/
Static Function GeraCOHeader(cPreemb, cInvoice, dDataInv)
Local aRet := {}
Local lExp := .F.

Begin Sequence

   If !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
      aRetorno := {}
      cRetMsg := StrTran(STR0057, "XXX", AllTrim(cAcordoCom)) //Não foi encontrado nenhum acordo para o Id: 'XXX'.
      Break
   EndIf

   EXP->(DbSetOrder(1))	

   //RMD - 22/11/12
   //Verifica se existe alguma invoice para o embaque, caso exista, busca as informações dela, caso contrário utiliza o embarque como base das informações
   lEXP := EXP->(DbSeek(xFilial()+cPreemb))
   If !lEXP .Or. EXP->(DbSeek(xFilial()+cPreemb+cInvoice))
   
      /*ID Acordo*/
      aAdd(aRet, aIds[2][4] + AllTrim(cAcordoCom) + aIds[2][4])

     /*Fabricante*/
      If Empty(cDesExp) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cDesExp)  + aIds[2][4])
      EndIf

      /*Export*/
      If Empty(cDesExp) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cDesExp) + aIds[2][4])
      EndIf

      /*Import*/
      If Empty(EEC->EEC_IMPODE) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(EEC->EEC_IMPODE) + aIds[2][4])
      EndIf
 
      /*Consignee*/
      If Empty(cDesCons) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cDesCons) + aIds[2][4])
      EndIf
                     
      /*Porto embarque*/
      If Empty(cPortoEmb) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cPortoEmb) + aIds[2][4])
      EndIf

      /*Pais de destino*/
      If Empty(cDesPais) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cDesPais) + aIds[2][4])
      EndIf

      /*Número do BL*/
      If Empty(If(lEXP, EXP->EXP_NRCONH, EEC->EEC_NRCONH)) .Or. !(cAcordoCom $ "Comum Arquivo")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(If(lEXP, EXP->EXP_NRCONH, EEC->EEC_NRCONH)) + aIds[2][4])
      EndIf

      /*Data do BL*/
      If Empty(If(lEXP, EXP->EXP_DTCONH, EEC->EEC_DTCONH)) .Or. !(cAcordoCom $ "Comum Arquivo")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(PictureDt(If(lEXP, EXP->EXP_DTCONH, EEC->EEC_DTCONH))) + aIds[2][4])
      EndIf

      /*Número do Invoice*/
      If Empty(cInvoice) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cInvoice) + aIds[2][4])
      EndIf

      /*Data do Invoice*/
      If Empty(dDataInv) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(PictureDt(dDataInv)) + aIds[2][4])
      EndIf

      /*Marca*/
      If Empty(EEC->EEC_CODMAR) .Or. !(cAcordoCom $ "16/17")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(MSMM(EEC->EEC_CODMAR, 40,,, LERMEMO))  + aIds[2][4])
      EndIf

      /*Peso Líquido*/
      If Empty(If(lEXP, EXP->EXP_PESLIQ, EEC->EEC_PESLIQ)) .Or. !(cAcordoCom $ "17")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(Transf(If(lEXP, EXP->EXP_PESLIQ, EEC->EEC_PESLIQ),"@R 999,999,999.999")) + aIds[2][4])
      EndIf

      /*Peso Bruto*/
      If Empty(If(lEXP, EXP->EXP_PESBRU, EEC->EEC_PESBRU)) .Or. !(cAcordoCom $ "16/17")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(Transf(If(lEXP, EXP->EXP_PESBRU, EEC->EEC_PESBRU),"@R 999,999,999.999")) + aIds[2][4])
      EndIf

      /*Navio*/
      If Empty(cDescNavio) .Or. !(cAcordoCom $ "17")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cDescNavio) + aIds[2][4])
      EndIf

      /*Data Envio*/
      aAdd(aRet, aIds[2][4])

      /*Hora Envio*/
      aAdd(aRet, aIds[2][4])

      /*Data Embarque*/
      If Empty(EEC->EEC_DTEMBA) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(PictureDt(EEC->EEC_DTEMBA)) + aIds[2][4])
      EndIf

      /*Endereço Importador - parte 1*/
      If Empty(EEC->EEC_ENDIMP) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(EEC->EEC_ENDIMP) + aIds[2][4])
      EndIf

      /*Endereço Importador - parte 2*/
      If Empty(cEndImp2) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cEndImp2) + aIds[2][4])
      EndIf
 
      /*Endereço Consignatario - parte 1*/
      If Empty(cEndCons1) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cEndCons1) + aIds[2][4])
      EndIf

      /*Endereço Consignatario - parte 2*/
      If Empty(cEndCons2) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cEndCons2) + aIds[2][4])
      EndIf

      /*Endereço Produtor - parte 1*/
      If Empty(cEndExp1) .Or. !(cAcordoCom $ "16/17/18/19")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cEndExp1) + aIds[2][4])
      EndIf

      /*Endereço Produtor - parte 2*/
      If Empty(cEndExp2) .Or. !(cAcordoCom $ "16/17/18/19")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cEndExp2) + aIds[2][4])
      EndIf

      /*Meio de Transporte*/
      If Empty(cMeioTransp) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(cMeioTransp) + aIds[2][4])
      EndIf

      /*Valor do Certificado*/
      If Empty(If(lEXP, EXP->EXP_TOTPED, EEC->EEC_TOTPED)) .Or. !(cAcordoCom $ "16/17")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(Transf(If(lEXP, EXP->EXP_TOTPED, EEC->EEC_TOTPED),"@R 999,999,999,999.99")) + aIds[2][4])
      EndIf

      /*Especie*/
      If Empty(EEC->EEC_MOEDA) .Or. !(cAcordoCom $ "16")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(EEC->EEC_MOEDA) + aIds[2][4])
      EndIf

      /*Mercadoria*/
      If Empty(EEC->EEC_DSCGEN) .Or. !(cAcordoCom $ "16")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(MSMM(EEC->EEC_DSCGEN, 30,,, LERMEMO)) + aIds[2][4])
      EndIf

      /*Data Assinatura do Exportador*/
      If Empty(EEC->EEC_DTEMBA) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(PictureDt(EEC->EEC_DTEMBA)) + aIds[2][4])
      EndIf

      /*Data Assinatura da Federação*/
      If Empty(EEC->EEC_DTEMBA) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19/20")
         aAdd(aRet, aIds[2][4])
      Else
         aAdd(aRet, AllTrim(PictureDt(EEC->EEC_DTEMBA)) + aIds[2][4])
      EndIf

      /*Observação*/
      aAdd(aRet, aIds[2][4])
   EndIf

End Sequence

Return aRet

/*=========================================================================================
Função    : GeraCODetail
Objetivo  : Buscas das Informações para o Certificado de Origem.
Parâmetros: cPreemb - Código do Processo
            cInvoice - Nº da Invoice
Retorno   : aCols
Autor     : Bruno Akyo Kubagawa
Data      : 23/08/2010
Obs.      :
===========================================================================================*/
Static Function GeraCODetail(cPreemb, cInvoice)
Local aRet        := {},;
      aRetorno    := {}
Local nQtdItemInv := 0,;
      nQtdCont    := 0,;
      j           := 0
Local lEXR := .F.

Begin Sequence

   If !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19")
      aRetorno := {}
      cRetMsg := StrTran(STR0057, "XXX", AllTrim(cAcordoCom)) //Não foi encontrado nenhum acordo para o Id: 'XXX'.
      Break
   EndIf
   
   EXR->(DbSetOrder(1))
   //RMD - 22/11/12
   //Verifica se existe alguma invoice para o embaque, caso exista, busca as informações dela, caso contrário utiliza o embarque como base das informações
   lEXR := EXR->(DbSeek(xFilial()+cPreemb))
   If lEXR
      EXR->(DbSeek(xFilial()+cPreemb+cInvoice))
   Else
      EE9->(DbSetOrder(3))
      EE9->(DbSeek(xFilial()+cPreemb))
   EndIf
   
   While If(lEXR, EXR->(!Eof() .And. EXR_FILIAL+EXR_PREEMB+EXR_NRINVO == xFilial()+cPreemb+cInvoice), EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+EEC->EEC_PREEMB))

   	  If lEXR
         EE9->(DbSetOrder(3))
         EE9->(DbSeek(xFilial()+cPreemb+EXR->EXR_SEQEMB))
      EndIf
   
   	  //*** Busca a Norma
      EEI->(DbSetOrder(1))
      If EEI->(DbSeek(xFilial("EEI")+AllTrim(EE9->EE9_CODNOR)))
         cDescNorma := MSMM(EEI->EEI_DESC, 60,,, LERMEMO)
      EndIf
	  //***
	  
	  nQtdItemInv := If(lEXR, EXR->EXR_SLDINI, EE9->EE9_SLDINI)
      //*** Verificando os container por produtos
	  For j:=1 To Len(aProdEXA)

         If If(lEXR, EXR->EXR_SEQEMB, EE9->EE9_SEQEMB) == aProdEXA[j][2] .And. aProdEXA[j][4] > 0

            aRet := {}

			cContainer := aProdEXA[j][1]

	        /*Container*/
	        If Empty(cContainer) .Or. !(cAcordoCom $ "17")
               aAdd(aRet, aIds[2][4] + aIds[2][4])
	        Else
               aAdd(aRet, aIds[2][4] + AllTrim(cContainer) + aIds[2][4])
            EndIf

            /*Quantidade de caixas*/
	        If nQtdItemInv > aProdEXA[j][4]
               nQtdCont := aProdEXA[j][4]
		    Else
			   nQtdCont := nQtdItemInv
		    EndIf

	        If nQtdCont < 0 .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/16/17/18/19")
	           aAdd(aRet, aIds[2][4])
	        Else
               aAdd(aRet, AllTrim(Str(nQtdCont)) + aIds[2][4])
            EndIf

            /*Mercadoria*/
	        If Empty(EE9->EE9_DESC) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/17/18/19") //mais o Comum Arquivo
               aAdd(aRet, aIds[2][4])
  	        Else
               aAdd(aRet, AllTrim(MSMM(EE9->EE9_DESC, 30,,, LERMEMO)) + aIds[2][4])
            EndIf
            
            /*Classificação Fiscal(NALADI /NCM)*/
	        If (Empty(EE9->EE9_NALSH) .And. Empty(EE9->EE9_POSIPI)) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/17")
	           aAdd(aRet, aIds[2][4])
	        Else
	           If !Empty(EE9->EE9_POSIPI)
                  aAdd(aRet, AllTrim(EE9->EE9_POSIPI) + aIds[2][4])
               Else
                  aAdd(aRet, AllTrim(EE9->EE9_NALSH) + aIds[2][4])
               EndIf
            EndIf
            
            /*Valor*/
	        If Empty(If(lEXR, EXR->EXR_PRCTOT, EE9->EE9_PRCTOT)) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/18/19")
	           aAdd(aRet, aIds[2][4])
	        Else
	           aAdd(aRet, AllTrim(Transf(If(lEXR, EXR->EXR_PRCTOT, EE9->EE9_PRCTOT),"@R 999,999,999,999.99")) + aIds[2][4])
            EndIf
            
            /*Criterio de Origem*/
	        If Empty(EE9->EE9_CODNOR) .Or. !(cAcordoCom $ "12")
	           aAdd(aRet, aIds[2][4])
	        Else
	           aAdd(aRet, AllTrim(EE9->EE9_CODNOR) + aIds[2][4])
            EndIf
            
            /*Norma*/
	        If Empty(EE9->EE9_CODNOR) .Or. !(cAcordoCom $ "01/02/03/04/05/06/07/08/09/10/11/13/14")
	           aAdd(aRet, aIds[2][4])
	        Else
	           aAdd(aRet, AllTrim(cDescNorma) + aIds[2][4])
            EndIf
		 
            aAdd(aRetorno, aRet)

	        If nQtdItemInv > aProdEXA[j][4]
               nQtdItemInv -= aProdEXA[j][4]
			   aProdEXA[j][4] := 0
		    Else
			   aProdEXA[j][4] -= nQtdItemInv
			   nQtdItemInv := 0
		    EndIf

         EndIf
		 
		 If nQtdItemInv <= 0
		    Exit
		 EndIf

	  Next
	  //***
	  
	  If lEXR
         EXR->(DbSkip())
      Else
         EE9->(DbSkip())
      EndIf
   EndDo

End Sequence

Return aRetorno

/*==================================================================================================================
* Função    : AtualizaStatusEI103
* Objetivo  : Alterar o status do arquivo no banco de dados.
* Parâmetros: cStatus   - Status a ser gravado.
*             aArquivos - Vetor com os arquivos.
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 23/08/2010
* Obs.      : O registro deve estar posicionado na tabela
==================================================================================================================*/
Static Function AtualizaStatusEI103(cStatus, aArquivos)
Local lRet:= .F.
Local i   := 1
Begin Sequence

   If cStatus == ST_E
      If !MsgYesNo(STR0058, "Atenção") //Esta operação alterará o status do arquivo para 'Enviado'. Deseja prosseguir?
         lRet:= .F.
         Break
      EndIf
   EndIf

   For i:=1 To Len(aArquivos)
      E12->(DbSetOrder(3))
      If E12->(DbSeek(xFilial()+AvKey(aArquivos[i][1],"E12_ARQUIV")+aArquivos[i][2]+aArquivos[i][3]))
         Begin Transaction
            If E12->(RecLock("E12", .F.))
               If cStatus == ST_E
                  E12->E12_USUAEN:= cUserName
                  E12->E12_DATAEN:= dDataBase
                  E12->E12_HORAEN:= Time()
               EndIf
               E12->E12_STATUS:= cStatus
               E12->(MsUnlock())
            EndIf
         End Transaction
      EndIf
   Next
   lRet:= .T.

End Sequence
Return lRet

/*==================================================================================================================
* Função    : VisualArqEI103
* Objetivo  : Alterar o status do arquivo no banco de dados.
* Parâmetros: Status a ser gravado.
* Retorno   : Lógico
* Autor     : Bruno Akyo Kubagawa
* Data      : 23/08/2010
* Obs.      : 
==========================================================================================================*/
Static Function VisualArqEI103(cBuffer)
Local bOk    := {|| lRet:= .T., oDlg:End()},;
      bCancel:= {|| lRet:= .F., oDlg:End()},;
      bGet   := {|x| If(PCount() > 0, cBuffer:= x, cBuffer)}
Local lRet
Local nInferior:= 500,;
      nDireita := 800
Local oDlg,;
      oFont,;
      oMultiGet

Begin Sequence


   oFont:= TFont():New("Arial",, -12) 
   Define MsDialog oDlg Title STR0059 From 0, 0 To nInferior, nDireita Pixel Of oMainWnd //Visualização do arquivo

      oMultiGet:= TMultiGet():New(20, 10, bGet, oDlg, 385, 220, oFont,,,,, .T.,,,,,, .T.)
      oMultiGet:lWordWrap:= .T.

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered


End Sequence
Return

/*==========================================================================================================
* Função    : Buffer
* Objetivo  : Armazenar no Buffer (variavel) para criaçao do Txt.
* Parâmetros: aDados - informações da Fatura ou Certificado
              cTipo - Tipo de Arquivo
* Retorno   : cBuffer - com as informações do txt.
* Autor     : Bruno Akyo Kubagawa
* Data      : 23/08/2010
* Obs       : 
==========================================================================================================*/
Static Function Buffer(aDados, cTipo)
Local cFaturaH  := Space(0),;
      cFaturaD  := Space(0),;
      cFaturaT  := Space(0),;
      cCertOriH := Space(0),;
      cCertOriD := Space(0),;
      cBuffer   := Space(0)
Local nCont     := 0,;
      nCont1    := 0

   Begin Sequence
      Do Case

      Case cTipo == STR0002 //Fatura

         cFaturaH := aIds[2][1]
         For nCont := 1 To Len(aDados[1])
            cFaturaH += aDados[1][nCont]
         Next

         For nCont := 1 To Len(aDados[2])
            cFaturaD += aIds[2][2]
            For nCont1 := 1 To Len(aDados[2][nCont])
               cFaturaD += aDados[2][nCont][nCont1] 
            Next
            cFaturaD += ENTER
         Next

         cFaturaT := aIds[2][3]
         For nCont := 1 To Len(aDados[3])
            cFaturaT += aDados[3][nCont]   
         Next

         cBuffer := cFaturaH + ENTER + cFaturaD + cFaturaT

         If Empty(cBuffer)
            cRetMsg := STR0060 //Durante a geração do arquivo Fatura, os dados não foram carregados corretamente.
            Break
         EndIf

         Break
   
      Case cTipo == STR0003 //Certificado de Origem

         cCertOriH += aIds[2][1]
         For nCont := 1 To Len(aDados[1])
            cCertOriH += aDados[1][nCont]
         Next

         For nCont := 1 To Len(aDados[2])
            cCertOriD += aIds[2][2]
            For nCont1 := 1 To Len(aDados[2][nCont])
               cCertOriD += aDados[2][nCont][nCont1] 
            Next
            cCertOriD += ENTER
         Next

         cBuffer := cCertOriH + ENTER + cCertOriD
         If Empty(cBuffer)
            cRetMsg := STR0061 //Durante a geração do arquivo Certificado, os dados não foram carregados corretamente.
            Break
         EndIf

         Break

      End Case
   End Sequence

Return cBuffer

/*================================================================================================================*
* Funcao    : PictureDt(dData)
* Parametro : dData - Valor de um campo data.
* Retorno   : Caracter.
* POR       : Bruno Akyo Kubagawa
* Data      : 23/08/2010
* Obs.      : Mudar o forma do campo data de acordo com o Layout da FACISC.
*=================================================================================================================*/
Static Function PictureDt(dData)
Local cData := DToS(dData)
Local cAno  := SubStr(cData,1,4)
Local cMes  := SubStr(cData,5,2)
Local cDia  := SubStr(cData,7,2)

cData := cAno + "-" + cMes + "-" + cDia

Return cData

/*================================================================================================================*
* Funcao    : ValidEmb(cPreemb)
* Parametro : cPreemb - Processo de embarque
* Retorno   : Logico.
* POR       : Bruno Akyo Kubagawa
* Data      : 23/08/2010
* Obs.      : Função utilizada para o dicionario de dados do pergunte.
*=================================================================================================================*/
Function ValidEmb(cPreemb, cInvoice)
Local lRet := .T.

Begin Sequence

EEC->(DbSetOrder(1))
If !EEC->(DbSeek(xFilial()+cPreemb))
   MsgInfo("Processo " + Alltrim(cPreemb) + " não cadastrado no sistema.","Atenção")
   lRet := .F.
   Break
Else
   EXP->(DbSetOrder(1))
   If !EXP->(DbSeek(xFilial()+cPreemb+cInvoice))
      MsgInfo("Nº de invoice não é referente ao processo: " + AllTrim(cPreemb) +".","Atenção")
      lRet := .F.
      Break
   EndIf
EndIf

End Sequence
Return lRet

Static Function GetProds(cIDSup)
Local aProds := {}
Local aOrd := SaveOrd("EYH")

	EYH->(DbSetOrder(3))
    EYH->(DbSeek(xFilial()+"S"+EEC->EEC_PREEMB+cIdSup))
    While EYH->(EYH_FILIAL+EYH_ESTUF+EYH_PREEMB+EYH_IDVINC == xFilial()+"S"+EEC->EEC_PREEMB+cIdSup)
		If !Empty(EYH->EYH_SEQEMB)
			aAdd(aProds, {EX9->EX9_CONTNR, EYH->EYH_SEQEMB,EYH->EYH_LOTE,EYH->EYH_QTDEMB,If(EYH->(FieldPos("EYH_CODMAR")) > 0, MSMM(EYH->EYH_CODMAR,60,,, LERMEMO), MSMM(EX9->EX9_OBS,60,,, LERMEMO))})
		Else
			aEval(GetProds(EYH->EYH_ID), {|x| aAdd(aProds, x) })
		EndIf
        EYH->(DbSkip())
     EndDo

RestOrd(aOrd, .T.)
Return aClone(aProds)
