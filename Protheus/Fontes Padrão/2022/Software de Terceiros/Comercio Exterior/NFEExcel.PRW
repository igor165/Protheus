#Include "Average.ch"
#Include "Protheus.ch"
#Include "AP5MAIL.CH"
#Include "NFEExcel.ch"

static _aCposPlan := {}
static _aPosCpos  := {} // [1] Posição da planilha - [2] Posição do vetor _aCposPlan
// Posições dos campos chaves
static POS_HAWB   := 0
static POS_INVOIC := 0
static POS_FORN   := 0
static POS_FORLOJ := 0
static POS_PO_NUM := 0
static POS_POSICA := 0
static POS_SEQUEN := 0
static POS_SEQDUI := 0

#define CAMPO     1
#define TITULO    2
#define TAMANHO   7
#define DECIMAL   8
#define TIPO      9

//SENHA DO ARQUIVO NFE.XLA: avNFE
/*------------------------------------------------------------------------------------
Funcao      : expNFEExcel
Parametros  : pProcesso - nº do processo que será exportado para XLS
              nValid - =1 segue o modelo de geração do xls antigo
                       =2 segue o modelo de geração do xls novo via javascript
Retorno     :
Objetivos   : Exportar um determinado processo para uma planilha XLS, com formatação
              pré-definida.
Autor       : Anderson Soares Toledo
Data/Hora   : 30/10/08
Revisao     : WFS 13/08/09 - o processamento antes executado no diretório SmartClient(getClientDir())
              passou a ser executado no diretório temporário do usuário (GetTempPath())
Obs.        : Maiores informações consultar EF - Nota Fiscal Eletrônica
*------------------------------------------------------------------------------------*/
Function expNFEExcel(pProcesso,nValid)
   Local aOrd     := {} //armazena as informações das tabelas que terão indices alterados
   Local aInvoice := {} //armazena todas as invoices encontradas no processo
   Local lAdicao  := .F.//flag para verificar se o processo já possui adições
   Local i,j              //contador
   Local cBody          //Mensagem que será enviada no email com a planilha para o despachante
   Local hashChvCFO := "" , aDadosCFO := {}
   //Private cMV_DESC := ""// DFS - Parametro para escolher o tipo de descrição na imp/exp de excel
   Private cMV_DESC := If(ValType(EasyGParam("MV_AVG0194",,"0")) == "N", AllTrim(Str(EasyGParam("MV_AVG0194",,"0"))), EasyGParam("MV_AVG0194",,"0"))  //RMD - 11/12/2012
   //JVR - 03/02/2010 - utilizado no ponto de entrada
   Private aAltDadosXLS := {}

   Private aHeader[0],aCampos := {}
   Private cNomeFile         //armazena o arquivo da work WKEXCEL
   Private aEstru := {}      //estrutura da work WKEXCEL

  //Variaveis com o conteudo alterado pela função showDLGEmail
   Private cNomeXLS := pProcesso+space(50-len(pProcesso)) //Nome do XLS que será criado
   Private cDestXLS := GetTempPath()+space(150-Len(GetTempPath())) //Caminho de onde será salvo o XLS, tamanho total 150 caracteres
   Private cEmailDesp                                     //Email do Despachante
   Private cEmailCC   := space(100)                       //Email que será enviado Cópia
   Private cAssunto                                       //Assunto do Email
   Private cFrom                                          //Email do Remetente
   Private cDestino:=''                                   //path e nome do arquivo da planilha a ser gerada
   if nValid == 1
      //ISS - 13/12/10 - Variável necessária para validar a existencia de geração de nota fiscal de despesa no sistema.
      PRIVATE lCposNFDesp := (SWD->(FIELDPOS("WD_B1_COD")) # 0 .And. SWD->(FIELDPOS("WD_DOC")) # 0 .And. SWD->(FIELDPOS("WD_SERIE")) # 0;                   //NCF - Campos da Nota Fiscal de Despesas
                           .And. SWD->(FIELDPOS("WD_ESPECIE")) # 0 .And. SWD->(FIELDPOS("WD_EMISSAO")) # 0 .AND. SWD->(FIELDPOS("WD_B1_QTDE")) # 0;
                           .And. SWD->(FIELDPOS("WD_TIPONFD")) # 0)
      Private cTempDbf := GetTempPath() + CriaTrab(,.F.) + "\"  //RMD - 11/12/2012
      Private oDadosCFOP := tHashMap():New()
      Private lRegTCFO := FindFunction("DI590XLA")

      //Verifica se existe a macro no remote
      If !ExistFile()
         return .F.
      EndIf

      If ExisteNF(pProcesso)
         Alert(StrTran(STR0001,"###",alltrim(pProcesso))) //"O processo ### já existe Nota Fiscal"
         return .F.
      EndIf

      If Empty(Trim(cMV_DESC)) //LGS-14/08/2014
         cMV_DESC := "0"
         PutMV("MV_AVG0194","0")
      EndIf

      aOrd := SaveOrd({"SW8","SW9","SB1","SA2","SAH","SWP","EIJ","SY8","SJR","SX3",;
                     "SJC","SWZ","SW7","SYD","SJZ","SJP","SJY","SY6","SJ8","SJ6"})

      SW8->(dbSetOrder(1)) //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_FORN+W8_FORLOJ   // GFP - 04/11/2014
      SW9->(dbSetOrder(3)) //W9_FILIAL+W9_HAWB

      SW9->(dbSeek(xFilial("SW9")+pProcesso))

      //Armazena todas invoices encontradas no processo
      While SW9->W9_HAWB == pProcesso
         If aScan(aInvoice, {|x| x == SW9->W9_INVOICE}) == 0
            aAdd(aInvoice,SW9->W9_INVOICE)
         EndIf
         SW9->(dbSkip())
      EndDo

      If len(aInvoice) == 0
         Alert(STR0002) // "Não existe invoice para este processo."
         RestOrd(aOrd)
         Return .F.
      EndIf

      //Verifica se já existem Adições no processo
      for i := 1 to len(aInvoice)
         SW8->(dbSeek(xFilial("SW8")+pProcesso+aInvoice[i]))  // GFP - 04/11/2014
         While SW8->(!EOF()) .And. SW8->W8_HAWB == pProcesso .And. SW8->W8_INVOICE == aInvoice[i]
            If !Empty(SW8->W8_ADICAO) .And. !Empty(SW8->W8_SEQ_ADI)
               lAdicao := .T.
               exit
            EndIf
            SW8->(dbSkip())
         EndDo
      next

      //Alerta o usuário a existencia de adições, e pergunta se deseja prosseguir
      if lAdicao
         If !ApMsgYesNo(STR0003)//"Existem itens que possuem adições, deseja gerar a planilha?"
            RestOrd(aOrd)
            Return .F.
         EndIf
      EndIf

      //Obtem estrutura da work
      aEstru := CriaEstru("E")

      cNomeFile := E_CriaTrab(,aEstru,"WKEXCEL")
      E_INDREGUA("WKEXCEL",cNomeFile+TEOrdBagExt(), "WK_HAWB" )

      SW6->(dbSetOrder(1))
      SB1->(dbSetOrder(1))
      SA2->(dbSetOrder(1))
      SAH->(dbSetOrder(1))
      SWP->(dbSetOrder(1))
      EIJ->(dbSetOrder(1))
      SY8->(dbSetOrder(1))
      SJR->(dbSetOrder(1))
      SX3->(dbSetOrder(2))
      SJC->(dbSetOrder(1))
      SJZ->(dbSetOrder(1))
      SJP->(dbSetOrder(1))
      SJY->(dbSetOrder(1))
      SW9->(dbSetOrder(1))
      SY6->(dbSetOrder(1))
      SY8->(dbSetOrder(1))
      SJ6->(dbSetOrder(1))

      for i := 1 to len(aInvoice)
         SW8->(dbSeek(xFilial("SW8")+pProcesso+aInvoice[i]))   // GFP - 04/11/2014

         While SW8->(!EOF()) .And. SW8->W8_HAWB == pProcesso .And. SW8->W8_INVOICE == aInvoice[i]
            RecLock("WKEXCEL",.T.)

               WKEXCEL->WK_HAWB    := pProcesso

               SB1->(dbSeek(xFilial("SB1")+AvKey(SW8->W8_COD_I,"B1_COD")))
               Do Case //DFS - Tratamento para escolher o tipo de descrição na imp/exp excel no desembaraço
               Case cMV_DESC == "0"
                  WKEXCEL->WK_DESC_I  := SB1->B1_DESC  //DFS - 21/04/10 - Pega a descricao resumida
               Case cMV_DESC == "1"
                  WKEXCEL->WK_DESC_I  := StrTran(SB1->(MSMM(B1_DESC_I, TAMSX3("B1_VM_I")[1] ,,,LERMEMO)), ENTER, " ")  //DFS - 21/04/10 - Pega a descricao em Ingles
               Case cMV_DESC == "2"
                  WKEXCEL->WK_DESC_I  := SB1->(MSMM(B1_DESC_GI,TAMSX3("B1_VM_GI")[1],,,LERMEMO))  //DFS - 21/04/10 - Pega a descricao da LI
               Case cMV_DESC == "3"
                  WKEXCEL->WK_DESC_I  := SB1->(MSMM(B1_DESC_P, TAMSX3("B1_VM_P")[1],,,LERMEMO))   //DFS - 21/04/10 - Pega a descricao em Portugues
               EndCase

               WKEXCEL->WK_COD_I   := SB1->B1_COD //CCH - 09/09/09 - Inclusão do código do item na planilha Excel exportada.
               WKEXCEL->WK_NCM     := SW8->W8_TEC
               WKEXCEL->WK_EX_NCM  := SW8->W8_EX_NCM
               WKEXCEL->WK_EX_NBM  := SW8->W8_EX_NBM

               SA2->(dbSeek(xFilial("SA2")+AvKey(SW8->W8_FABR,"A2_COD")+EICRetLoja("SW8","W8_FABLOJ")))
               WKEXCEL->WK_FABR    := SA2->A2_NOME

               WKEXCEL->WK_INVOICE := SW8->W8_INVOICE

               SA2->(dbSeek(xFilial("SA2")+AvKey(SW8->W8_FORN,"A2_COD")+EICRetLoja("SW8","W8_FABLOJ")))
               WKEXCEL->WK_FORN    := SA2->A2_NOME
               WKEXCEL->WK_CODFORN := SW8->W8_FORN
               IF EICLOJA()
                  WKEXCEL->WK_LOJFORN := SW8->W8_FORLOJ
               ENDIF
               SAH->(dbSeek(xFilial("SAH")+AvKey(SW8->W8_UNID,"AH_UNIMED")))

               If !Empty(SW8->W8_UNID)
                  WKEXCEL->WK_UNID    := alltrim(SW8->W8_UNID)+"-"+alltrim(SAH->AH_UMRES)
               EndIF

               WKEXCEL->WK_QTDE    := SW8->W8_QTDE
               WKEXCEL->WK_PRECO   := STR( SW8->W8_PRECO , AVSX3("W8_PRECO"  ,AV_TAMANHO), AVSX3("W8_PRECO"  ,AV_DECIMAL) ) //SW8->W8_PRECO
               WKEXCEL->WK_PEDIDO  := SW8->W8_PO_NUM
               WKEXCEL->WK_POSICAO := SW8->W8_POSICAO
               WKEXCEL->WK_PGI_NUM := SW8->W8_PGI_NUM

               //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
               SW9->(dbSeek(xFilial("SW9")+AvKey(SW8->W8_INVOICE,"W9_INVOICE")+AvKey(SW8->W8_FORN,"W9_FORN")+EICRetLoja("SW8","W8_FORLOJ")+AvKey(SW8->W8_HAWB,"W9_HAWB")))
               WKEXCEL->WK_INCOTER := SW9->W9_INCOTER
               WKEXCEL->WK_MOEDA   := SW9->W9_MOE_FOB
               WKEXCEL->WK_ADICAO  := SW8->W8_ADICAO
               WKEXCEL->WK_SEQ_ADI := SW8->W8_SEQ_ADI

               If lRegTCFO
                  If !Empty(SW8->W8_OPERACA)
                     hashChvCFO := SW8->W8_OPERACA
                     aDadosCFO := {}
                     If !IsMemVar("oDadosCFOP") .Or. oDadosCFOP == Nil
                        oDadosCFOP:= tHashMap():New()
                     EndIf
                     If !oDadosCFOP:Get(hashChvCFO, @aDadosCFO)
                        SWX->(DbSetOrder(1))
                        SWZ->(DbSetOrder(2))
                        If SWZ->( DbSeek( xFilial("SWZ") + SW8->W8_OPERACA)  )
                           If SWX->( DbSeek( xFilial("SWX") + SWZ->WZ_CFO)  )
                              WKEXCEL->WK_COD_CFO := SWX->WX_COD
                              WKEXCEL->WK_DSC_CFO := SWX->WX_DESC
                           EndIf
                           WKEXCEL->WK_OPRCFOP := SWZ->WZ_OPERACA
                           WKEXCEL->WK_DSCCFOP := SWZ->WZ_DESC
                        EndIf
                        aDadosCFO := { WKEXCEL->WK_COD_CFO, WKEXCEL->WK_DSC_CFO, WKEXCEL->WK_OPRCFOP, WKEXCEL->WK_DSCCFOP }
                        oDadosCFOP:Set(hashChvCFO, aDadosCFO)
                     Else
                        WKEXCEL->WK_COD_CFO := aDadosCFO[1]
                        WKEXCEL->WK_DSC_CFO := aDadosCFO[2]
                        WKEXCEL->WK_OPRCFOP := aDadosCFO[3]
                        WKEXCEL->WK_DSCCFOP := aDadosCFO[4]                  
                     EndIf
                  EndIf
                  WKEXCEL->WK_REG_II  := SW8->W8_REGTRI +" - "+ Posicione("SJP", 1, xFilial("SJP")+Left(SW8->W8_REGTRI,1), "JP_DESC")
                  WKEXCEL->WK_REG_IPI := SW8->W8_REGIPI +" - "+ UPPER( BSCXBOX("EIJ_REGIPI",Left(SW8->W8_REGIPI,1) ) )
                  WKEXCEL->WK_REG_PC  := SW8->W8_REG_PC +" - "+ Posicione("SJP", 1, xFilial("SJP")+Left(SW8->W8_REG_PC,1), "JP_DESC")
               EndIf

               //Ponto de entrada para personalizar os dados exportados na work
               If EasyEntryPoint("NFEEXCEL")
                  ExecBlock("NFEEXCEL",.F.,.F.,"EXPDADOS")
               EndIf

               //JVR - 03/02/10
               aAltDadosXLS := {}
               If(EasyEntryPoint("NFEEXCEL"),Execblock("NFEEXCEL",.F.,.F.,"DADOSXLS"),)//JVR - 02/02/2010 - Permite alterar o conteudo da Work.
               For j:=1 to Len(aAltDadosXLS)
                  If WKEXCEL->(FieldPos(aAltDadosXLS[j][1])) > 0 .and. chkfile(aAltDadosXLS[j][2]) .and.;
                     (aAltDadosXLS[j][2])->(FieldPos(aAltDadosXLS[j][3])) > 0

                     WKEXCEL->(FieldPut(FieldPos(aAltDadosXLS[j][1]), (aAltDadosXLS[j][2])->(FieldGet(FieldPos(aAltDadosXLS[j][3])))))
                  EndIf
               Next j
               //**

            MsUnlock("WKEXCEL")
            SW8->(dbSkip())
         EndDo
      Next   
   EndIf   
   lOk := ShowDlgEmail(.T.,pProcesso)
   If lOK
      geraEnvio(nValid,pProcesso)
   EndIf   

   RestOrd(aOrd,.T.)

   If Select("WKEXCEL") <> 0
      WKEXCEL->(E_EraseArq(cNomeFile))
   EndIf

Return

/*
Funcao      : geraEnvio
Parametros  : lValid = 1 gera o xls no formato antigo
                     = 2 gera o xls no formato novo com javascript
Objetivos   : Se é a geração antriga, gera a planilha, salva e envia por email se for o caso,
              Se é a geração nova, a planilha em si já está gerada, então salva e envia por email se for o caso
Autor       : Maurício Frison
Data        : Setembro/2022
*/
static function geraEnvio(nValid,pProcesso)
Local cName    := alltrim(cNomeXLS)+if(nValid==1,".xls",".xlsx")
local cMsgRet  := ""

      cDestino := alltrim(cDestXLS)+cName

      If !FILE(cDestino) .Or.;
             ApMsgYesNo(StrTran(STR0004,"###",' ' +cDestino)) // "Deseja sobrescrever o arquivo ###.xls existente?"

         //Copia o Arquivo para o computador do usuário, gera o arquivo VbScript e cria a planilha
         cMsgRet := STR0011 //"Ocorreu algum erro no processo de exportação para XLS"
         If (nVAlid==2 .And. EasyExpXLS()) .or. (nValid==1 .And. Cpy2Rmt() .And. GeraVbs() .And. DBF2XLS() ) 
            cMsgRet := StrTran(STR0005,"###",cName) //"Arquivo ###.xls gerado com sucesso."
            If !Empty(cEmailDesp)
               If ApMsgYesNo(StrTran(STR0006,"###",alltrim(cEmailDesp))) //"Deseja enviar o arquivo gerado para o email: ### ?"
                  //Mensagem que irá para o email enviado ao despachante com a planilha
                  cBody := STR0007 + ENTER + ENTER //"Sr(a) Despachante:"
                  cBody += STR0008 + pProcesso + ENTER //"Anexo planilha com os dados referentes ao processo: "
                  cBody += STR0009 //"Após preencher, favor remeter para este email."
                  cBody += ENTER + ENTER

                  cBody += STR0010 //"Obs.: E-mail gerado automaticamente pelo SIGAEIC"

                  SendMail(cFrom,cEmailDesp,cEmailCC,cAssunto,cBody,cDestXLS,cName)
               EndIf
            EndIf
         EndIf
         MsgInfo(cMsgRet)
         if nValid==1
            DelTemp(.T.)
         EndIf   
      EndIf
return   
/*------------------------------------------------------------------------------------
Funcao      : DBF2XLS
Parametros  :
Retorno     :
Objetivos   : Verifica se existe o Excel instalado na máquina e executa o arquivo vbScript
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function DBF2XLS()

   If ! ApOleClient( 'MsExcel' )
      Return .F.
   Else
      Processa({||WaitRun('cmd.exe "/c pushd '+cTempDbf+' && cscript.exe nfe.vbs"')}, STR0012) //"Gerando Planilha XLS"  //RMD - 11/12/2012
   EndIf

Return .T.

/*------------------------------------------------------------------------------------
Funcao      : Cpy2Rmt
Parametros  :
Retorno     :
Objetivos   : Copia o Arquivo DBF gerado para a pasta Remote do client
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function Cpy2Rmt()
   Local cOrigem := GetSrvProfString("STARTPATH","")+cNomeFile+".dbf"
   Local cDest := cTempDbf  //RMD - 11/12/2012
   Local lRet
   Local cNomeFileTemp:= cNomeFile

   //RMD - 01/06/18 - Sempre copia utilizando AvCpyFile, que já converte para XML conforme configuração dos temporários.
   WKEXCEL->(DbCloseArea())
   AvCpyFile(cNomeFile+If(!TeTempBanco(),GetdbExtension(),""), cDest + "wkexcel.dbf")
   If File(cDest + "wkexcel.xml")
      WaitRun("AvgXML2DBF.exe " + cDest)
   EndIf
   cNomeFile := "wkexcel"
   lRet:= File(cDest + "wkexcel.dbf")
   E_EraseArq(cNomeFileTemp)

Return lRet

/*------------------------------------------------------------------------------------
Funcao      : geraVbs
Parametros  : Valor lógico informando se a função está sendo chamada na exportação do processo para XLS
              Se for na exportação para XLS - .T.
              Se for na importação do XLS para o Protheus - .F.
Retorno     :
Objetivos   : Gerar um arquivo vbScript com as informações necessárias para executar a macro
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function geraVbs(lExp)
   Local cVbs
   Local nHandler

   Default lExp := .T.

   if lExp
      cVbs := 'Dim xl' + ENTER
      cVbs += 'Dim xlw'+ ENTER
      cVbs += 'Set xl = CreateObject("Excel.Application")'+ ENTER
      //Informa o diretório que se encontra a macro
      cVbs += 'Set xlw = xl.Workbooks.Open("'+cTempDbf+'NFE.xla")' + ENTER //Abrir o arquivo do Excel  //RMD - 11/12/2012
      //Informa o diretório que se encontra o arquivo DBF
      cVbs += 'xl.Run "NFE.xla!setPath","'+ cTempDbf+'"' + ENTER  //RMD - 11/12/2012
      //Informa o nome do DBF
      cVbs += 'xl.Run "NFE.xla!setDBF","'+alltrim(cNomeFile)+'"' + ENTER
      //Informa a pasta de onde será salva a planilha gerada
      cVbs += 'xl.Run "NFE.xla!setDest","'+alltrim(cDestXLS)+'"'+ ENTER
      //Informa o nome da planilha que serpa criada
      cVbs += 'xl.Run "NFE.xla!setFile","'+alltrim(cNomeXLS)+'"' + ENTER
      //Apresenta mensagem na tela
      cVbs += 'Wscript.Echo "Gerando arquivo '+alltrim(cNomeXLS)+'.xls"' + ENTER
      //Executa a macro
      cVbs += 'xl.Run "NFE.xla!DBF2XLS"' + ENTER
      //Finaliza os objetos
      cVbs += 'xlw.Close False' + ENTER
      cVbs += 'xl.Quit' + ENTER
      cVbs += 'xl.Destroy' + ENTER //WFS 13/08/09
      cVbs += 'Set xlw = Nothing ' + ENTER// Liberamos a memória
      cVbs += 'Set xl = Nothing' + ENTER
   Else
      cVbs := 'Dim xl' + ENTER
      cVbs += 'Dim xlw'+ ENTER
      cVbs += 'Set xl = CreateObject("Excel.Application")'+ ENTER
      cVbs += 'Set xlw = xl.Workbooks.Open("'+cTempDbf+'NFE.xla")' + ENTER //Abrir o arquivo do Excel      //RMD - 11/12/2012
      //Informa o caminho de onde se encotra o XLS
      cVbs += 'xl.Run "NFE.xla!setPath","'+ alltrim(cOrigPath)+'"' + ENTER
      //Informa o nome do XLS
      cVbs += 'xl.Run "NFE.xla!setFile","'+alltrim(cFile)+'"' + ENTER
      //Informa a estrutura do DBF que será criado com as informações do XLS,
      //a estrutrura é criada com base no SX3
      cVbs += 'xl.Run "NFE.xla!setEstru","'+StruSQL()+'"' + ENTER
      //Informa quais campos são numéricos, tendo em vista que não é possível
      //verificar através da macro diretamente
      cVbs += 'xl.Run "NFE.xla!setNumFields","'+cNumFields+'"' + ENTER
      cVbs += 'Wscript.Echo "Gerando arquivo '+alltrim(cFile)+'.dbf"' + ENTER
      //Executa a macro
      cVbs += 'xl.Run "NFE.xla!XLS2DBF"' + ENTER
      //Finaliza os objetos
      cVbs += 'xlw.Close False' + ENTER
      cVbs += 'xl.Quit' + ENTER
      cVbs += 'xl.Destroy' + ENTER //WFS 13/08/09
      cVbs += 'Set xlw = Nothing ' + ENTER// Liberamos a memória
      cVbs += 'Set xl = Nothing' + ENTER
   EndIF

   //Caso exista um arquivo antigo, exclui
   if File(cTempDbf+"nfe.vbs")  //RMD - 11/12/2012
      FErase(cTempDbf+"nfe.vbs")
   EndIf

   //Cria o arquivo vbScript
   nHandler := EasyCreateFile(cTempDbf+"nfe.vbs")  //RMD - 11/12/2012
   FWrite(nHandler, cVbs)
   FClose(nHandler)

Return .T.

/*------------------------------------------------------------------------------------
Funcao      : delTemp
Parametros  : lExp = Valor lógico informando se a função está sendo chamada na exportação do processo para XLS
              Se for na exportação para XLS - .T.
              Se for na importação do XLS para o Protheus - .F.
Retorno     :
Objetivos   : Apagar os arquivos temporários criados
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function delTemp(lExp)
   default lExp := .F.

   If File(cTempDbf+"nfe.vbs")  //RMD - 11/12/2012
      FErase(cTempDbf+"nfe.vbs")
   EndIf

   If lExp
      IF File(cTempDbf+cNomeFile+".dbf")  //RMD - 11/12/2012
         FErase(cTempDbf+cNomeFile+".dbf")
      EndIf
   Else
      If File(cOriDBF)
         FErase(cOriDBF)
      EndIf
      If File(cDestDBF)
         FErase(cDestDBF)
      EndIf
      If File(GetSrvProfString("STARTPATH","")+alltrim(cDbf)+".dbf")
         FErase(GetSrvProfString("STARTPATH","")+alltrim(cDbf)+".dbf")
      EndIf
   EndIf
   //RMD - 11/12/2012
   If File(cTempDbf+"nfe.xla")
      FErase(cTempDbf+"nfe.xla")
   EndIf
   If File(cTempDbf+"nfe.xls")
      FErase(cTempDbf+"nfe.xls")
   EndIF
   If lIsDir(cTempDbf)
      DirRemove(cTempDbf)
   EndIf

Return

/*------------------------------------------------------------------------------------
Funcao      : showDLGEmail
Parametros  : lExp - Valor lógico informando se a função está sendo chamada na exportação do processo para XLS
                     Se for na exportação para XLS - .T.
                     Se for na importação do XLS para o Protheus - .F.
              pProcesso - nº do Processo que está importando/exportando
Retorno     : Valor lógico, .T. se as informações foram confirmadas ou .F. se o usuário cancelou a operação
Objetivos   : Obter dados para a criação do arquivo (Nome e caminho de onde será salvo) e para quais endereços será
              enviado o email
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function showDLGEmail(lExp,pProcesso)
   Local oDlg
   Local lOpc //Valor lógico informando se as informações foram confirmadas ou se o usuário cancelou a operação
   Local nCol := 10, nLinha := 10
   Local aOrd := SaveOrd({"SW6","SY5"})
   Local nLinhaFim := 340
   Local aUsuario //Armazena as informações do usuario logado

   // Sugere como email do Despachante, o email que consta no cadastro de despachante
   SW6->(dbSeek(xFilial("SW6")+AvKey(pProcesso,"B1_COD")))
   SY5->(dbSeek(xFilial("SY5")+AvKey(SW6->W6_DESP,"Y5_COD")))
   cEmailDesp := SY5->Y5_EMAIL + space(100 - len(SY5->Y5_EMAIL)) //mantem o tamanho da MsGet de 100 caracteres

   //Sugere como email do remetendo o endereço cadastrado do usuário logado
   //JVR - 08/09/09 - Posiciona o usuario para a busca de informações corretas.
   If PswSeek(__cUserId, .T.)
      aUsuario := PswRet(1)
   EndIf
   If Len(aUsuario) < 1 .Or. Len(aUsuario[1]) < 14 .Or. ValType(aUsuario[1][14]) <> "C"
      cFrom    := ""
   Else
      cFrom    := AllTrim(aUsuario[1][14]) + space(100 - len(AllTrim(aUsuario[1][14]))) //sugere o endereço de email cadastrado do usuário logado
   EndIf

   //Sugere como assunto: Processo 'nome processo'
   cAssunto := STR0113 + pProcesso + space(50 - len(STR0113 + pProcesso))

   If lExp
      nLinhaFim += 35
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0013 From 0,0 to nLinhaFim,500 PIXEL //"Parâmetros email"
      @ nLinha, nCol Say STR0014 of oDlg Pixel //"Nome do Arquivo"
      nLinha += 10
      if lExp
         @ nLinha, nCol MsGet cNomeXLS Size 230,10 Valid(valParam("NomeXLS")) of oDlg Pixel
         nLinha += 15
         @ nLinha, nCol Say STR0015 of oDlg Pixel //"Diretório"
         nLinha += 10
         @ nLinha, nCol MsGet cDestXLS Size 200,10 Valid(valParam("DestXLS")) of oDlg Pixel
         nLinha += 15
      Else
         @ nLinha, nCol MsGet cFile Size 230,10  when .F. of oDlg Pixel
         nLinha += 15
      EndIF

      @ nLinha, nCol Say STR0114 of oDlg Pixel //"De"
      nLinha += 10
      @ nLinha, nCol MsGet cFrom Size 230,10 Valid(valParam("From")) of oDlg Pixel
      nLinha += 15

      @ nLinha, nCol Say STR0016 of oDlg Pixel //"Email Despachante"
      nLinha += 10
      @ nLinha, nCol MsGet cEmailDesp Size 230,10 Valid(valParam("EmailDesp")) of oDlg Pixel
      nLinha += 15
      @ nLinha, nCol Say "CC" of oDlg Pixel
      nLinha += 10
      @ nLinha, nCol MsGet cEmailCC Size 230,10 Valid(valParam("EmailCC")) of oDlg Pixel
      nLinha += 15
      @ nLinha, nCol Say STR0017 of oDlg Pixel //"Assunto"
      nLinha += 10
      @ nLinha, nCol MsGet cAssunto Size 230,10 of oDlg Pixel
      nLinha += 20
      @ nLinha, nCol+123 Button STR0018 Size 50,15 Action(lOpc := .T., oDlg:End()) of oDlg Pixel // OK
      @ nLinha, nCol+178 Button STR0019 Size 50,15 Action(lOpc := .F., oDlg:End()) of oDlg Pixel // "Cancelar"

      If lExp
         Define SBUTTON From 45, 212 Type 14 Action(selDir()) enable of oDlg Pixel
      EndIf

   ACTIVATE MSDIALOG oDlg Centered

   If lExp
      cNomeXLS := AltCaracter(cNomeXLS)
   EndIf

   RestOrd(aOrd,.T.)

Return lOpc

/*------------------------------------------------------------------------------------
Funcao      : ValParam
Parametros  : Campo para validação
Retorno     : Valor lógico - .T. a informação do campo é válida, .F. a informação não é válida
Objetivos   : Validar as informações da Dialog da função showDLGEmail
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function ValParam(cCampo)
   Local lRet := .T.
   Local aDir
   Local cTempXLS

   If cCampo == "NomeXLS"
      If Len(alltrim(cNomeXLS)) < 3
         Alert(STR0020) //"Insira um nome de arquivo válido."
         lRet := .F.
      EndIf
   ElseIf cCampo == "DestXLS"
      If RAT("\",cDestXLS) == len(alltrim(cDestXLS))
         cTempXLS := subStr(cDestXLS,1,len(alltrim(cDestXLS))-1)
      Else
         cTempXLS := cDestXLS
      EndIf
      aDir := Directory(cTempXLS,"D")
      //if len(aDir) == 0 WFS 13/08/09
      If (Len(aDir) == 0 .Or. !lIsDir(cTempXLS)) .And. Upper(AllTrim(cTempXLS)) <> GetTempPath()

         Alert(STR0021) //"Insira um diretório de destino válido."
         lRet := .F.

      EndIf
   ElseIf cCampo == "EmailDesp"
      If At("@",cEmailDesp) <= 1 .Or. At(".",cEmailDesp) <= 3
         Alert(STR0022)//"Insira um email válido."
         lRet := .F.
      EndIf
   ElseIf cCampo == "From"
      If At("@",cFrom) <= 1 .Or. At(".",cFrom) <= 3
         Alert(STR0022)//"Insira um email válido."
         lRet := .F.
      EndIf
   ElseIf cCampo == "EmailCC"
      If !Empty(cEmailCC) .And. (At("@",cEmailCC) <= 1 .Or. At(".",cEmailCC) <= 3)
         Alert(STR0022) //"Insira um email válido."
         lRet := .F.
      EndIf
   EndIf

Return lRet


/*------------------------------------------------------------------------------------
Funcao      : selDir
Parametros  :
Retorno     :
Objetivos   : Apresentar uma Dialog para o usuário selecionar o diretório desejado
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function selDir()
   Local cTitle:= STR0023//"Selecione o Diretório"
   Local cMask := ""//"Arquivo Excel|*.xls"
   Local nDefaultMask //:= 0
   Local cDefaultDir  := GetTempPath()
   Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY
   Local cPath

   cPath := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,,nOptions)

   If Empty(cPath)
      Return cDestXLS
   Else
      cDestXLS := cPath + space(len(cDestXLS) - len(cPath)) // mantem o tamanho da msGet de 150 caracteres
   EndIf
Return


/*------------------------------------------------------------------------------------
Funcao      : CriaEstru
Parametros  : pOpc - Caracter
                E - estrutura para a work WKEXCEL (Exportação para XLS)
                I - estrutura para a work WKDADOSXLS (Importação dos dados da XLS)
                ERRO - estrutura para a work WKERRO  (Importação dos dados da XLS)
Retorno     : vetor com a estrutura solicitada
Objetivos   : Fornecer a estrutura para criação das works
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        : Versão beta, alguns campos não estão sendo exportados para a planilha
*------------------------------------------------------------------------------------*/
Static Function CriaEstru(pOpc)
   Local nTamanho
   Private aEstru := {}

   If pOpc == "E" .Or. pOpc == "I"
      aAdd(aEstru,{"WK_HAWB"      ,AVSX3("W8_HAWB"   ,AV_TIPO), AVSX3("W8_HAWB"   ,AV_TAMANHO),0                             }) //	Processo
      //aAdd(aEstru,{"WK_DESC_I" ,AVSX3("B1_DESC"   ,AV_TIPO), AVSX3("B1_DESC"   ,AV_TAMANHO),0                             }) // Descrição do item

      Do Case
      Case cMV_DESC == "0"
         aAdd(aEstru,{"WK_DESC_I" ,AVSX3("B1_DESC"  ,AV_TIPO), AVSX3("B1_DESC"   ,AV_TAMANHO),0                             }) // Descrição do item
      Case cMV_DESC == "1"
         aAdd(aEstru,{"WK_DESC_I" ,AVSX3("B1_DESC"  ,AV_TIPO), 220,0                             }) // Descrição do item
      Case cMV_DESC == "2"
         aAdd(aEstru,{"WK_DESC_I" ,AVSX3("B1_DESC"  ,AV_TIPO), 220,0                             }) // Descrição do item
      Case cMV_DESC == "3"
         aAdd(aEstru,{"WK_DESC_I" ,AVSX3("B1_DESC"  ,AV_TIPO), 220,0                             }) // Descrição do item
      EndCase

      aAdd(aEstru,{"WK_COD_I"  ,AVSX3("B1_COD"    ,AV_TIPO),AVSX3("B1_COD"    ,AV_TAMANHO),0                             }) // Código do Item - CCH - 09/09/09
      aAdd(aEstru,{"WK_NCM"    ,AVSX3("W8_TEC"    ,AV_TIPO),AVSX3("W8_TEC"    ,AV_TAMANHO),0                             }) // NCM
      aAdd(aEstru,{"WK_EX_NCM" ,AVSX3("W8_EX_NCM" ,AV_TIPO),AVSX3("W8_EX_NCM" ,AV_TAMANHO),0                             }) // EX_NCM
      aAdd(aEstru,{"WK_EX_NBM" ,AVSX3("W8_EX_NBM" ,AV_TIPO),AVSX3("W8_EX_NBM" ,AV_TAMANHO),0                             }) // EX_NBM
      aAdd(aEstru,{"WK_FABR"   ,AVSX3("A2_NOME"   ,AV_TIPO),AVSX3("A2_NOME"   ,AV_TAMANHO),0                             }) // Fabricante
      aAdd(aEstru,{"WK_INVOICE",AVSX3("W8_INVOICE",AV_TIPO),AVSX3("W8_INVOICE",AV_TAMANHO),0                             }) // Invoice
      aAdd(aEstru,{"WK_CODFORN",AVSX3("W8_FORN"   ,AV_TIPO),AVSX3("W8_FORN"   ,AV_TAMANHO),0                             }) // Código Fornecedor
      IF EICLOJA()
         aAdd(aEstru,{"WK_LOJFORN",AVSX3("W8_FORLOJ"   ,AV_TIPO),AVSX3("W8_FORLOJ"   ,AV_TAMANHO),0                             }) //Loja Fornecedor
      ENDIF
      aAdd(aEstru,{"WK_FORN"   ,AVSX3("A2_NOME"   ,AV_TIPO),AVSX3("A2_NOME"   ,AV_TAMANHO),0                             }) // Nome Fornecedor
      aAdd(aEstru,{"WK_MOEDA"  ,AVSX3("W9_MOE_FOB",AV_TIPO),AVSX3("W9_MOE_FOB"  ,AV_TAMANHO),0                             }) // Moeda
      nTamanho := AVSX3("W8_UNID"   ,AV_TAMANHO) + AVSX3("AH_UMRES"   ,AV_TAMANHO) + 1// +1 para adicionar o caracter "-" separando os campos
      aAdd(aEstru,{"WK_UNID"   ,"C"                        ,CorrigeTam(nTamanho)                      ,0                             }) // Unidade de medida
      aAdd(aEstru,{"WK_QTDE"   ,AVSX3("W8_QTDE"   ,AV_TIPO),AVSX3("W8_QTDE"   ,AV_TAMANHO),AVSX3("W8_QTDE" ,AV_DECIMAL)  }) // Quantidade
      aAdd(aEstru,{"WK_PRECO"  ,"C"/*AVSX3("W8_PRECO"  ,AV_TIPO)*/,AVSX3("W8_PRECO"  ,AV_TAMANHO),AVSX3("W8_PRECO",AV_DECIMAL)  }) // Preço
      aAdd(aEstru,{"WK_PEDIDO" ,AVSX3("W8_PO_NUM" ,AV_TIPO),AVSX3("W8_PO_NUM" ,AV_TAMANHO),0                             }) // Pedido
      aAdd(aEstru,{"WK_POSICAO",AVSX3("W8_POSICAO",AV_TIPO),AVSX3("W8_POSICAO",AV_TAMANHO),0                             }) // Posição
      aAdd(aEstru,{"WK_PGI_NUM",AVSX3("W8_PGI_NUM",AV_TIPO),AVSX3("W8_PGI_NUM",AV_TAMANHO),0                             }) // Número da PLI
      aAdd(aEstru,{"WK_INCOTER",AVSX3("W9_INCOTER",AV_TIPO),AVSX3("W9_INCOTER",AV_TAMANHO),0                             }) // Incoterm
      aAdd(aEstru,{"WK_ADICAO" ,AVSX3("W8_ADICAO" ,AV_TIPO),AVSX3("W8_ADICAO" ,AV_TAMANHO),0                             }) // Adição
      aAdd(aEstru,{"WK_SEQ_ADI",AVSX3("W8_SEQ_ADI",AV_TIPO),AVSX3("W8_SEQ_ADI",AV_TAMANHO),0                             }) // Sequencia do item na adição

      If lRegTCFO
         aAdd(aEstru,{"WK_REG_II" ,AVSX3("W8_REGTRI" ,AV_TIPO),60                            ,0                             }) // Regime Trib. II
         aAdd(aEstru,{"WK_REG_IPI",AVSX3("W8_REGIPI" ,AV_TIPO),60                            ,0                             }) // Regime Trib. IPI
         aAdd(aEstru,{"WK_REG_PC" ,AVSX3("W8_REG_PC" ,AV_TIPO),60                            ,0                             }) // Regime Trib. PIS/COFINS
         aAdd(aEstru,{"WK_COD_CFO",AVSX3("WX_COD"    ,AV_TIPO),AVSX3("WX_COD"    ,AV_TAMANHO),0                             }) // Código C.F.O
         aAdd(aEstru,{"WK_DSC_CFO",AVSX3("WX_DESC"   ,AV_TIPO),AVSX3("WX_DESC"   ,AV_TAMANHO),0                             }) // Descrição do C.F.O      
         aAdd(aEstru,{"WK_OPRCFOP",AVSX3("WZ_OPERACA",AV_TIPO),AVSX3("WZ_OPERACA",AV_TAMANHO),0                             }) // Operação de C.F.O.P
         aAdd(aEstru,{"WK_DSCCFOP",AVSX3("WZ_DESC"   ,AV_TIPO),AVSX3("WZ_DESC"   ,AV_TAMANHO),0                             }) // Descrição da Operação de C.F.O.P
      EndIf

      If pOpc == "I"
         aAdd(aEstru,{"WK_ERRO","C",50,0})
      EndIf

   ElseIf pOpc == "ERRO"
      aAdd(aEstru,{"WK_LINHA" ,"N",4,0})
      aAdd(aEstru,{"WK_SEQ"   ,"N",2,0})
      aAdd(aEstru,{"WK_MOTIVO","C",100,0})
      aAdd(aEstru,{"WK_ALERTA","L",1,0})
   EndIf

   //Ponto de entrada para alterar a estrutura da Work
   If EasyEntryPoint("NFEEXCEL")
      ExecBlock("NFEEXCEL",.F.,.F.,"SET_ESTRUTURA")
   EndIf

return aEstru


/*------------------------------------------------------------------------------------
Funcao      : SendMail
Parametros  : pFrom      - Endereço de email do remetente
              pEmailDesp - Endereço de email do despachante
              pEmailCC   - Endereço de email para enviar cópia do email
              pAssunto   - Assunto do email
              pBody      - Mensagem do email
              pPath      - Caminho de onde se encontra o arquivo que será anexado
              pFile      - Nome do arquivo que será anexado
Retorno     :
Objetivos   : Enviar email ao despachante com a planilha criada em anexo
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function SendMail(pFrom,pEmailDesp,pEmailCC,pAssunto,pBody,pPath,pFile)

   Local lAutentica  := EasyGParam("MV_RELAUTH",,.F.)
   Local lOk
   Local cOrigem
   Local cDestino

   Local cErrorMsg := ""

   Local cFrom, cTo, cCC, cAttachment, cBody, cSubject

   cServer   := EasyGParam("MV_RELSERV")
   cAccount  := EasyGParam("MV_RELACNT") //Usado na autenticação no servidor
   cPassword := EasyGParam("MV_RELAPSW") //Usado na autenticação no servidor
   cFrom     := alltrim(pFrom)
   cTo       := alltrim(pEmailDesp)
   cCC       := alltrim(pEmailCC)
   cSubject  := alltrim(pAssunto)

   //Corpo do e-mail
   cBody := pBody

   If(Empty(cFrom) .Or. Empty(cTo))
      Alert(STR0115) //Remetente ou destinatário em branco, não será possível o envio do email.
      Return .F.
   EndIf

   //Copia o arquivo que será anexado para o servidor
   cOrigem  := alltrim(pPath)+alltrim(pFile)
   cDestino := GetSrvProfString("STARTPATH","")
   If CpyT2S(cOrigem,cDestino,.F.) == .F.
      Alert(STR0024) //"Erro ao copiar o anexo para o servidor."
      Return .F.
   EndIf

   //Anexo
   cAttachment := cDestino + alltrim(pFile)

   //Conecta no servido de e-mails
   CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

   If !lOK
      Alert(STR0025,STR0026) // "Falha na Conexão com Servidor de E-Mail","ERRO"
      Return .F.
   EndIf

   //Faz autenticação
   If lAutentica
      If !MailAuth(cAccount,cPassword)
         Alert(STR0027,STR0026) //"Falha na Autenticacao do Usuário","ERRO"
         DISCONNECT SMTP SERVER RESULT lOk

         IF !lOk
            GET MAIL ERROR cErrorMsg
            Alert(STR0028+cErrorMsg,STR0026) //"Erro na Desconexao: "cErrorMsg, "ERRO"
            Return .F.
         EndIf
	  EndIf
   EndIf

   //Envia
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
   Else
      SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
   EndIf

   If !lOK
      Alert(STR0029)//"Falha no Envio de E-Mail"
   Else
      MsgInfo(STR0030) // "Email enviado com sucesso."
   EndIf

   FErase(cAttachment)

   DISCONNECT SMTP SERVER
Return

/*------------------------------------------------------------------------------------
Funcao      : ImpProcXLS
Parametros  :
Retorno     :
Objetivos   : Importar dados de um XLS, validar os dados e gravar na base de dados
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        : Versão beta, alguns campos não existem na planilha
*------------------------------------------------------------------------------------*/
Function ImpProcXLS()
   Local cSubStr //Armazena substrings com apenas o código de campos chaves
   Local nICMS   //Armazena o valor do ICMS da base de dados
   Local nTamCampo //Armazena o tamanho de campos na base de dados
   Local oDLG
   Local nLinha //Chave usada na WKERRO, usado para identificar qual item da MsSelect pertence o erro
   Local nSeq   //Sequencial do erro para cada item na WKERRO
   Local aCores := {}  //Condição para a marcação da MsSelect
   Local lErro  := .F.  //Flag para marcar se existem erros ou alerta, caso seja somente alerta, a integração pode continuar normalmente
   Local lErroAdi := .F. //Flag para verificar se existem erros na adição
   Local lIntegra := .F.
   Local bOk := {|| }
   Local bCancel := {|| }
   Local lOk := .F.

   Local aOrdSW9:= {}

   Local cBody // Corpo da mensagem que será enviada por parametro para o função responsável pelo envio do email

   Local cFileWork //Armazena o arquivo da WKDADOSXLS
   Local cFileErro //Armazena o arquivo da WKERRO
   Local aButtons := {} //Botão Legenda na EnChoice - "Legenda"
   Local cLoja := ""
   //JVR - 03/02/2010 - utilizado no ponto de entrada
   Local i
   local nRetVld := 0

   Private aAltDadosXLS := {}

   Private oSelect
   Private aCampos //Vetor com os campos para a MsSelect
   Private aEstru    //Estrutura da work WKDADOSXLS
   Private aEstrErro //Estrutura da work WKERRO

   Private cOriDBF := "" //Armazena a origem do DBF temporário
   Private cDestDBF := ""//Armazena a origem do DBF temporário

   //Variáveis usadas para a integração com o EXCEL
   Private cOrigPath := GetTempPath()+space(150-Len(GetTempPath())) //tamanho total 150 caracteres - caminho de onde se encontra o arquivo
   Private cFile //Nome do XLS que será importado
   Private cDBF  //Nome do arquivo DBF gerado, devido a restrição do DBF, o tamanho máximo é de 8 caracteres
   Private cNumFields := "" //Informa para a planilha do EXCEL, quais campos são numéricos
   Private cMV_DESC   := ""

   //Variáveis para o envio do email, valores alterados pela função showDlgEmail
   Private cDestXLS
   Private cNomeXLS
   Private cEmailDesp
   Private cEmailCC   := ""
   Private cAssunto   := ""
   Private cTempDbf   := ""
   Private lRegTCFO   := .F.

   nRetVld := DI501XLSVld('SW6',SW6->(recno()))
   if nRetVld <> 1
      if nRetVld == 2 // Processo tipo DUIMP e Manual
         return EasyImpXLS(SW6->(recno()))
      endif
      return .F.
   endif

   aCores := {{ "Empty(WKDADOSXLS->WK_ERRO)" , "BR_VERDE" } , { "!Empty(WKDADOSXLS->WK_ERRO)" , "BR_VERMELHO" } }  //Condição para a marcação da MsSelect
   bOk := {|| lIntegra := .T.,oDlg:End()}
   bCancel := {|| oDlg:End()}
   aButtons := {{"DBG09",{||Legenda("ITENS")},STR0106,STR0106}} //Botão Legenda na EnChoice - "Legenda"
   cNumFields := "" //Informa para a planilha do EXCEL, quais campos são numéricos
   cMV_DESC := If(ValType(EasyGParam("MV_AVG0194",,"0")) == "N", AllTrim(Str(EasyGParam("MV_AVG0194",,"0"))), EasyGParam("MV_AVG0194",,"0"))  //RMD - 11/12/2012
   cEmailCC := space(100)
   cAssunto := STR0050 + space(12)  //"PROCESSO"
   cTempDbf := GetTempPath() + CriaTrab(,.F.) + "\"  //RMD - 11/12/2012
   lRegTCFO := FindFunction("DI590XLA") //RegTriCFO()

   //Verifica se existe a macro no remote
   If !ExistFile()
      return .F.
   EndIf

   //Apresenta a tela de seleção do arquivo
   lOk := showDLGImp()

   If lOk
      //Gera o vbsScript
      GeraVbs(.F.)

      //Corrige o nome do arquivo DBF para o tamanho máximo de 8 caracteres
      //if len(cDBF) > 8         // Nopado por GFP - 11/12/2012
      //   cDBF = subStr(cDBF,1,8)
      //EndIf

      If File(cOrigPath+cDBF+".dbf")
         FErase(cOrigPath+cDBF+".dbf")
      EndIF

      If File(cOrigPath+SubStr(cDBF,1,8)+".dbf")    //GFP - 11/12/2012
         FErase(cOrigPath+SubStr(cDBF,1,8)+".dbf")
      EndIF

      //Executa a macro
      Processa({||WaitRun('cmd.exe "/c pushd '+cTempDbf+' && cscript.exe nfe.vbs"')}, STR0031) //"Importando dados"  //RMD - 11/12/2012

      If Select("WKDADOSXLS") > 0
         WKDADOSXLS->(DbCloseArea())
      EndIf
      aEstru := CriaEstru("I")
      cFileWork := E_CriaTrab(,aEstru,"WKDADOSXLS")

      If Select("WKERRO") > 0
         WKDADOSXLS->(DbCloseArea())
      EndIf
      aEstrErro := CriaEstru("ERRO")
      cFileErro := E_CriaTrab(,aEstrErro,"WKERRO")

      If !File(Alltrim(cOrigPath)+Alltrim(cDBF)+".dbf")   //GFP - 11/12/2012
         If File(Alltrim(cOrigPath)+Alltrim(Left(cDBF, 8))+".dbf")
         	cDBF := Alltrim(Left(cDBF, 8))
         EndIf
      Else//RMD - 11/06/18 - Força renomear o arquivo para um nome com 8 caracteres, pois o AVGXML2DBF não suporta arquivos com mais de 8 caracteres no nome
        If Len(cDBF) > 8
           If File(Alltrim(cOrigPath)+Alltrim(Left(cDBF, 8))+".dbf")
              FErase(Alltrim(cOrigPath)+Alltrim(Left(cDBF, 8))+".dbf")
           EndIf
           FRename(Alltrim(cOrigPath)+Alltrim(cDBF)+".dbf", Alltrim(cOrigPath)+Alltrim(Left(cDBF, 8))+".dbf")
           cDBF := Alltrim(Left(cDBF, 8))
        EndIf
      EndIf

      //Copia o arquivo para o servidor
      cOriDBF  := alltrim(cOrigPath)+alltrim(cDBF)+".dbf"
      cDestDBF := GetSrvProfString("STARTPATH","")

      //RMD - 01/06/18 - Faz a conversão do arquivo para XML e abre via AVGXML2DBF devido à descontinuidade dos temporários locais
      EasyGetRDD()
      If File("AvgXML2DBF.exe",2)
        WaitRun("AvgXML2DBF.exe " + cOrigPath + " tipo=dbf")//Converte para XML no client
        If File(cOrigPath + cDBF + ".xml")
          CpyT2S(cOrigPath + cDBF + ".xml", "\comex\")//Copia para o server
          FErase(cOrigPath + cDBF + ".xml")
          If File("\comex\" + cDBF + ".xml")
              AvgXML2DBF("\comex\" + cDBF + ".xml", @cDbf)//Transforma em temporário (Alias XML)
              FErase("\comex\" + cDBF + ".xml")
          EndIf
          TETempReopen(cDBF + If(TeTempBanco(), "", GetdbExtension()) ,, "DBFXLS")//Reabre com o novo alias
        EndIf
      EndIf

      If Select("DBFXLS") == 0
         Alert(STR0032) //"Erro ao copiar o arquivo temporário para o servidor."
         WKDADOSXLS->(E_EraseArq(cFileWork))
         WKERRO->(E_EraseArq(cFileErro))
         DelTemp()
         Return .F.
      EndIf

      SX3->(dbSetOrder(2))
      SW8->(dbSetOrder(6))
      SYP->(dbSetOrder(1))
      SYJ->(dbSetOrder(1))
      EIJ->(dbSetOrder(1))
      SY8->(dbSetOrder(1))
      SJR->(dbSetOrder(1))
      SJC->(dbSetOrder(1))
      SW9->(dbSetOrder(1))
      SW6->(dbSetOrder(1))


      If ExisteNF(DBFXLS->WK_HAWB)
         Alert(StrTran(STR0001,"###",alltrim(DBFXLS->WK_HAWB))) // "O processo "+alltrim(DBFXLS->WK_HAWB)+" já existe Nota Fiscal")
         return .F.
      EndIf

      //Realiza a validação dos dados
      //A work WKERRO, armazena a posição do item na msSelect e o erro encontrado
      //Verifica se existem erros na adição e sequencia de adição
      lErroAdi := VerifSeq()

      DBFXLS->(dbGoTop())

      While DBFXLS->(!EOF())
         SW8->(dbSeek(xFilial("SW8")+AvKey(DBFXLS->WK_HAWB,"W8_HAWB")+AvKey(DBFXLS->WK_INVOICE,"W8_INVOICE")+AvKey(DBFXLS->WK_PEDIDO,"W8_PO_NUM")+;
                                     AvKey(DBFXLS->WK_POSICAO,"W8_POSICAO")+AvKey(DBFXLS->WK_PGI_NUM,"W8_PGI_NUM")))

         nSeq := 1

         RecLock("WKDADOSXLS",.T.)

         nLinha := WKDADOSXLS->(Recno())

         //Dados não editáveis na planilha
         WKDADOSXLS->WK_HAWB := DBFXLS->WK_HAWB
         WKDADOSXLS->WK_DESC_I := DBFXLS->WK_DESC_I
         WKDADOSXLS->WK_COD_I  := DBFXLS->WK_COD_I // Código do Item - CCH - 09/09/09
         WKDADOSXLS->WK_NCM := DBFXLS->WK_NCM
         WKDADOSXLS->WK_EX_NCM := DBFXLS->WK_EX_NCM
         WKDADOSXLS->WK_EX_NBM := DBFXLS->WK_EX_NBM
         WKDADOSXLS->WK_FABR := DBFXLS->WK_FABR
         WKDADOSXLS->WK_INVOICE := DBFXLS->WK_INVOICE
         WKDADOSXLS->WK_CODFORN := DBFXLS->WK_CODFORN
         IF EICLOJA()
            WKDADOSXLS->WK_LOJFORN := DBFXLS->WK_LOJFORN
         ENDIF
         WKDADOSXLS->WK_FORN := DBFXLS->WK_FORN
         WKDADOSXLS->WK_MOEDA := DBFXLS->WK_MOEDA
         WKDADOSXLS->WK_UNID := DBFXLS->WK_UNID
         WKDADOSXLS->WK_QTDE := DBFXLS->WK_QTDE
         WKDADOSXLS->WK_PRECO := DBFXLS->WK_PRECO
         WKDADOSXLS->WK_PEDIDO := DBFXLS->WK_PEDIDO
         WKDADOSXLS->WK_POSICAO := DBFXLS->WK_POSICAO
         WKDADOSXLS->WK_PGI_NUM := DBFXLS->WK_PGI_NUM


         //Ponto de entrada para retornar os dados da work do excel (DBFXLS) para a work que será usada na importação na base de dados (WKDADOSXLS)
         If EasyEntryPoint("NFEEXCEL")
            ExecBlock("NFEEXCEL",.F.,.F.,"IMPDADOS_WORK")
         EndIf

         //JVR - 03/02/10
         aAltDadosXLS := {}
         If(EasyEntryPoint("NFEEXCEL"),Execblock("NFEEXCEL",.F.,.F.,"DADOSXLS"),)//JVR - 02/02/2010 - Permite alterar o conteudo da Work.
         For i:=1 to Len(aAltDadosXLS)
            If WKEXCEL->(FieldPos(aAltDadosXLS[i][1])) > 0 .and. chkfile(aAltDadosXLS[i][2]) .and.;
                  (aAltDadosXLS[i][2])->(FieldPos(aAltDadosXLS[i][3])) > 0

               WKEXCEL->(FieldPut(FieldPos(aAltDadosXLS[i][1]), (aAltDadosXLS[i][2])->(FieldGet(FieldPos(aAltDadosXLS[i][3])))))
            EndIf
         Next i
         //**

         IF EICLOJA() .And. Empty(cLoja := DBFXLS->WK_LOJFORN)

            aOrdSW9:= SaveOrd({"SW9"})

            SW9->(DbSetOrder(1))

            IF SW9->(dbSeek(xFilial("SW9")+AvKey(DBFXLS->WK_INVOICE,"W9_INVOICE")+AvKey(DBFXLS->WK_CODFORN,"W9_FORN")))

               DO WHILE SW9->(!EOF()) .AND. xFilial("SW9") == SW9->W9_FILIAL .AND. DBFXLS->WK_INVOICE == SW9->W9_INVOICE .AND. DBFXLS->WK_CODFORN == SW9->W9_FORN

                  IF SW9->W9_HAWB == DBFXLS->WK_HAWB
                     cLoja:= SW9->W9_FORLOJ
                     EXIT
                  ENDIF

                  SW9->(DbSkip())
               ENDDO

            ENDIF

            RestOrd(aOrdSW9,.T.)

            //SA2->(DbSetOrder(1))
            //IF SA2->(DbSeek(xFilial("SA2")+ AvKey(DBFXLS->WK_CODFORN,"W9_FORN")))
            //   cLoja:= SA2->A2_LOJA
            //ENDIF

         ENDIF


         If !Empty(DBFXLS->WK_INCOTER)
            //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
            SW9->(dbSeek(xFilial("SW9")+AvKey(DBFXLS->WK_INVOICE,"W9_INVOICE")+AvKey(DBFXLS->WK_CODFORN,"W9_FORN")+IF(EICLOJA(),cLoja,"")+AvKey(DBFXLS->WK_HAWB,"W9_HAWB")))
            //Verifica se está diferente na base
            If Alltrim(SW9->W9_INCOTER) <> alltrim(DBFXLS->WK_INCOTER)
               //Verifica se é um Incoterm válido
               If !SYJ->(dbSeek(xFilial("SYJ")+AvKey(DBFXLS->WK_INCOTER,"YJ_COD")))
                  WKERRO->(dbAppend())
                  WKERRO->WK_LINHA := nLinha
                  WKERRO->WK_SEQ   := nSeq
                  WKERRO->WK_MOTIVO  := STR0033+DBFXLS->WK_INCOTER //"Incoterm Incorreto: "
                  WKERRO->WK_ALERTA  := .F.
                  WKDADOSXLS->WK_ERRO := STR0034 //"Clique para visualizar os erros"
                  lErro := .T.
                  nSeq++
               Else //Diferente da base
                  WKERRO->(dbAppend())
                  WKERRO->WK_LINHA := nLinha
                  WKERRO->WK_SEQ   := nSeq
                  WKERRO->WK_MOTIVO  := STR0035+DBFXLS->WK_INCOTER //"Incoterm informado diferente da Invoice: "
                  WKERRO->WK_ALERTA  := .T.
                  WKDADOSXLS->WK_ERRO := STR0034 //"Clique para visualizar os erros"
                  nSeq++
               EndIf
            EndIf
            WKDADOSXLS->WK_INCOTER := DBFXLS->WK_INCOTER
         EndIf

         If lErroAdi
            WKERRO->(dbAppend())
            WKERRO->WK_LINHA := nLinha
            WKERRO->WK_SEQ   := nSeq
            WKERRO->WK_MOTIVO  := STR0049 //"Existem erros na Adição, não obedece uma ordem."
            WKERRO->WK_ALERTA  := .F.
            WKDADOSXLS->WK_ERRO := STR0034 //"Clique para visualizar os erros"
            lErro := .T.
         EndIf

         If !Empty(DBFXLS->WK_ADICAO)
            SX3->(dbSeek("W8_ADICAO"))
            nTamCampo := SX3->X3_TAMANHO
            cSubStr := alltrim(DBFXLS->WK_ADICAO)
            cSubStr := acertaChave(cSubStr,nTamCampo,.T.)
            WKDADOSXLS->WK_ADICAO := cSubStr
         EndIf

         If !Empty(DBFXLS->WK_SEQ_ADI)
            SX3->(dbSeek("W8_SEQ_ADI"))
            nTamCampo := SX3->X3_TAMANHO
            cSubStr := alltrim(DBFXLS->WK_SEQ_ADI)
            cSubStr := acertaChave(cSubStr,nTamCampo,.T.)
            WKDADOSXLS->WK_SEQ_ADI := cSubStr
         EndIf

         If lRegTCFO
            WKDADOSXLS->WK_REG_II  := DBFXLS->WK_REG_II
            WKDADOSXLS->WK_REG_IPI := DBFXLS->WK_REG_IPI
            WKDADOSXLS->WK_REG_PC  := DBFXLS->WK_REG_PC
            WKDADOSXLS->WK_COD_CFO := DBFXLS->WK_COD_CFO
            WKDADOSXLS->WK_DSC_CFO := DBFXLS->WK_DSC_CFO
            WKDADOSXLS->WK_OPRCFOP := DBFXLS->WK_OPRCFOP
            WKDADOSXLS->WK_DSCCFOP := DBFXLS->WK_DSCCFOP
         End

         MsUnlock("WKDADOSXLS")
         DBFXLS->(dbSkip())
      EndDo

      aCampos :={{"WK_HAWB"    ,"",STR0050,"" },;
                 {"WK_DESC_I"  ,"",STR0051,"" },;
                 {"WK_COD_I"   ,"",STR0116,"" },; // Código do Item - CCH - 09/09/09
                 {"WK_NCM"     ,"",STR0052,"" },;
                 {"WK_EX_NCM"  ,"",STR0053,"" },;
                 {"WK_EX_NBM"  ,"",STR0054,"" },;
                 {"WK_FABR"    ,"",STR0055,"" },;
                 {"WK_INVOICE" ,"",STR0056,"" },;
                 {"WK_FORN"    ,"",STR0057,"" },;
                 {"WK_MOEDA"   ,"",STR0069,"" },;
                 {"WK_UNID"    ,"",STR0058,"" },;
                 {"WK_QTDE"    ,"",STR0059,"" },;
                 {"WK_PRECO"   ,"",STR0060,"" },;
                 {"WK_PEDIDO"  ,"",STR0061,"" },;
                 {"WK_POSICAO" ,"",STR0062,"" },;
                 {"WK_PGI_NUM" ,"",STR0063,"" },;
                 {"WK_INCOTER" ,"",STR0065,"" },;
                 {"WK_ADICAO"  ,"",STR0080,"" },;
                 {"WK_SEQ_ADI" ,"",STR0081,"" }}
      If lRegTCFO
         aAdd(aCampos,{"WK_REG_II"  ,"",STR0117,"" }) //"REG.TRIBUT.II"
         aAdd(aCampos,{"WK_REG_IPI" ,"",STR0118,"" }) //"REG.TRIBUT.IPI"
         aAdd(aCampos,{"WK_REG_PC"  ,"",STR0119,"" }) //"REG.TRIBUT.PIS-COFINS"
         aAdd(aCampos,{"WK_COD_CFO" ,"",STR0120,"" }) //"CÓDIGO DO CFOP"
         aAdd(aCampos,{"WK_DSC_CFO" ,"",STR0121,"" }) //"DESCRIÇÃO DO CFO"
         aAdd(aCampos,{"WK_OPRCFOP" ,"",STR0122,"" }) //"COD.OPERACÃO CFOP"
         aAdd(aCampos,{"WK_DSCCFOP" ,"",STR0123,"" }) //"DESC.OPERACÃO CFOP"
      EndIf

      aAdd(aCampos,{"WK_ERRO "   ,"",STR0082,"" } )

      WKDADOSXLS->(dbGoTop())

      //Ponto de entrada para personalizar a estrutura da tela de retorno (aCampos)
      If EasyEntryPoint("NFEEXCEL")
         ExecBlock("NFEEXCEL",.F.,.F.,"TELA_RETORNO")
      EndIf

      aPos := {}

      DEFINE MSDIALOG oDlg TITLE STR0083 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM-15,DLG_COL_FIM-15 Pixel //"Dados obtidos XLS"
         aPos := PosDlg(oDlg)
         If SetMDIChild()
            aPos[3] -= 5
         EndIf

         oSelect :=MsSelect():New("WKDADOSXLS",,,aCampos,@lInverte,@cMarca,aPos,,,,,aCores)
         //Apresenta os erros encontrados no item selecionado
         oSelect:oBrowse:Align :=  CONTROL_ALIGN_ALLCLIENT //wfs
         oSelect:bAval := {|| ShowErrors()}
         oDlg:lMaximized:=.T.
      Activate MSDIALOG oDlg on Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

      If lIntegra
         If !lErro
            If ApMsgYesNo(STR0084) //"Deseja atualizar a base de dados com os dados da planilha?"
               Processa({|| AtuDados()},STR0085) //"Atualizando Base de Dados"
            EndIf
         Else
            If ApMsgYesNo(STR0086) //"Existem erros na planilha, deseja enviar um email com a planilha comunicando os erros ao despachante?"
               showDLGEmail(.F.,WKDADOSXLS->WK_HAWB)
               cBody := MontaMSG()
               SendMail(cFrom,cEmailDesp,cEmailCC,cAssunto,cBody,cOrigPath,cFile)
            EndIf
         EndIf
      EndIf

      DBFXLS->(dbCloseArea())
      WKDADOSXLS->(E_EraseArq(cFileWork))
      WKERRO->(E_EraseArq(cFileErro))
      DelTemp()

   EndIf
Return

/*------------------------------------------------------------------------------------
Funcao      : showDLGImp
Parametros  :
Retorno     :
Objetivos   : Apresentar Dialog para o usuário informar o XLS que deseja importar
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function showDLGImp(cExtensao)
   Local nCol   := 10
   Local nLinha := 10
   Local oDlg
   Local lRet := .F.
   Local bOk := {|| lRet := .T.,oDlg:End()}

   default cExtensao := "xls"

   DEFINE MSDIALOG oDlg TITLE STR0087 From 0,0 to 150,500 PIXEL //"Importação de processos"
      @ nLinha, nCol Say STR0088 of oDlg Pixel //"Caminho do XLS"
      nLinha += 10
      @ nLinha, nCol MsGet cOrigPath  Size 200,10 Valid() of oDlg Pixel
      nLinha += 20
      @ nLinha, nCol+123 Button STR0018 Size 50,15 Action(if(valFile(cExtensao),eval(bOk),)) of oDlg Pixel //"OK"
      @ nLinha, nCol+178 Button STR0019 Size 50,15 Action(lRet := .F., oDlg:End()) of oDlg Pixel //"Cancelar"

      Define SBUTTON From 20, 212 Type 14 Action(selXLS(cExtensao)) enable of oDlg Pixel

   ACTIVATE MSDIALOG oDlg Centered

return lRet

/*------------------------------------------------------------------------------------
Funcao      : selXLS
Parametros  :
Retorno     :
Objetivos   : Apresentar Dialog para o usuário selecionar o arquivo XLS
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function selXLS(cExtensao)
   Local cTitle:= STR0089//"Selecione o processo"
   Local cMask := "" 
   Local nDefaultMask //:= 0
   Local cDefaultDir  := GetTempPath()
   Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE
   Local cOrig

   default cExtensao := "xls"

   cMask := STR0090+"|*." + cExtensao //"Arquivo Excel
   cOrig := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,,nOptions)

   If Empty(cOrig)
      Return cOrigPath
   Else
      cOrigPath := cOrig + space(len(cOrigPath) - len(cOrig)) // mantem o tamanho da msGet de 150 caracteres
   EndIf
Return


/*------------------------------------------------------------------------------------
Funcao      : valFile
Parametros  :
Retorno     : Valor lógico informando se o arquivo é válido
Objetivos   : Válidar se o arquivo selecionado é válido
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function valFile(cExtensao)
   Local lRet := .F.
   Local aDir

   default cExtensao := "xls"

   //Obtem informações do arquivo
   aDir := Directory(cOrigPath)

   If len(aDir) > 0
      //Armazena o nome
      cFile := Upper(aDir[1][1]) //wfs
      //Verifica a extensão do arquivo
      If !(subStr(cFile,AT(".",cFile),len(cFile)) == "." + alltrim(upper(cExtensao)))
         Alert(STR0091) //"Extensão do arquivo inválida."
         Return lRet
      EndIf
      //Armazena o caminho
      cOrigPath := subStr(cOrigPath,1,RAT("\",cOrigPath))
      //Armazena o nome do arquivo sem a extensão
      cDBF := subStr(cFile,1,AT(".",cFile)-1)
      lRet := .T.
   Else
      Alert(STR0092) //"Arquivo não encontrado!"
   EndIf

Return lRet


/*------------------------------------------------------------------------------------
Funcao      : StruSQL
Parametros  : String contendo a estrutrura para a macro criar o arquivo DBF
Retorno     :
Objetivos   : Obter a estrutura dos campos no SX3 para a macro criar um DBF com a estrutura compatível
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function StruSQL()
   Local nTamanho
   Private cStru

   //A estrura criada terá os sequinte forma
   //Nome do campo + tipo + tamanho
   //Tipo: Char ou Decimal
   //Tamanho se tipo Char (x) se Decimal (x,x)
   //Ex. WK_NOME Char(30), WK_DEC DECIMAL (10,2)

   cStru := "WK_HAWB "  + convTipo(AVSX3("W8_HAWB"   ,AV_TIPO),"WK_HAWB") + "(" + alltrim(str(AVSX3("W8_HAWB"   ,AV_TAMANHO))) +If(AVSX3("W8_HAWB"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_HAWB" ,AV_DECIMAL)))+"),","),")
   Do Case
      Case cMV_DESC == "0"
         cStru += "WK_DESC_I "+ convTipo(AVSX3("B1_DESC",AV_TIPO),"WK_DESC_I") + "(" + "220" /* alltrim(str(AVSX3("B1_DESC"    ,AV_TAMANHO))) */ +If(AVSX3("B1_DESC"    ,AV_TIPO) == "N","," +alltrim(str(AVSX3("B1_DESC"    ,AV_DECIMAL)))+"),","),")
      Case cMV_DESC == "1"
         cStru += "WK_DESC_I "+ convTipo(AVSX3("B1_DESC",AV_TIPO),"WK_DESC_I") + "(" + "220" /* alltrim(str(AVSX3("B1_DESC_I"  ,AV_TAMANHO))) */ +If(AVSX3("B1_DESC_I"  ,AV_TIPO) == "N","," +alltrim(str(AVSX3("B1_DESC_I"  ,AV_DECIMAL)))+"),","),")
      Case cMV_DESC == "2"
         cStru += "WK_DESC_I "+ convTipo(AVSX3("B1_DESC",AV_TIPO),"WK_DESC_I") + "(" + "220" /* alltrim(str(AVSX3("B1_DESC_GI" ,AV_TAMANHO))) */ +If(AVSX3("B1_DESC_GI" ,AV_TIPO) == "N","," +alltrim(str(AVSX3("B1_DESC_GI" ,AV_DECIMAL)))+"),","),")
      Case cMV_DESC == "3"
         cStru += "WK_DESC_I "+ convTipo(AVSX3("B1_DESC",AV_TIPO),"WK_DESC_I") + "(" + "220" /* alltrim(str(AVSX3("B1_DESC_P"  ,AV_TAMANHO))) */ +If(AVSX3("B1_DESC_P"  ,AV_TIPO) == "N","," +alltrim(str(AVSX3("B1_DESC_P"  ,AV_DECIMAL)))+"),","),")
   EndCase
   cStru += "WK_COD_I " + convTipo(AVSX3("B1_COD"   ,AV_TIPO),"WK_COD_I") + "(" + alltrim(str(AVSX3("B1_COD"   ,AV_TAMANHO))) +If(AVSX3("B1_COD"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("B1_COD" ,AV_DECIMAL)))+"),","),")    // Código do Item - CCH - 09/09/09
   cStru += "WK_NCM    "+ convTipo(AVSX3("W8_TEC"   ,AV_TIPO),"WK_NCM")  + "(" + alltrim(str(AVSX3("W8_TEC"   ,AV_TAMANHO)))  +If(AVSX3("W8_TEC"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_TEC" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_EX_NCM "+ convTipo(AVSX3("W8_EX_NCM"   ,AV_TIPO),"WK_EX_NCM") + "(" + alltrim(str(AVSX3("W8_EX_NCM"   ,AV_TAMANHO))) +If(AVSX3("W8_EX_NCM"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_EX_NCM" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_EX_NBM "+ convTipo(AVSX3("W8_EX_NBM"   ,AV_TIPO),"WK_EX_NBM") + "(" + alltrim(str(AVSX3("W8_EX_NBM"   ,AV_TAMANHO))) +If(AVSX3("W8_EX_NBM"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_EX_NBM" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_FABR "+ convTipo(AVSX3("A2_NOME"   ,AV_TIPO),"WK_FABR") + "(" + alltrim(str(AVSX3("A2_NOME"   ,AV_TAMANHO))) +If(AVSX3("A2_NOME"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("A2_NOME" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_INVOICE "+ convTipo(AVSX3("W8_INVOICE"   ,AV_TIPO),"WK_INVOICE") + "(" + alltrim(str(AVSX3("W8_INVOICE"   ,AV_TAMANHO))) +If(AVSX3("W8_INVOICE"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_INVOICE" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_FORN "+ convTipo(AVSX3("A2_NOME"   ,AV_TIPO),"WK_FORN") + "(" + alltrim(str(AVSX3("A2_NOME"   ,AV_TAMANHO))) +If(AVSX3("A2_NOME"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("A2_NOME" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_MOEDA "+ convTipo(AVSX3("W9_MOE_FOB"   ,AV_TIPO),"W9_MOE_FOB") + "(" + alltrim(str(AVSX3("W9_MOE_FOB"   ,AV_TAMANHO))) +If(AVSX3("W9_MOE_FOB"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W9_MOE_FOB" ,AV_DECIMAL)))+"),","),")
   nTamanho := AVSX3("W8_UNID"   ,AV_TAMANHO) + AVSX3("AH_UMRES"   ,AV_TAMANHO) + 1// +1 para adicionar o caracter "-" separando os campos
   cStru += "WK_UNID Char" + "(" + alltrim(str(CorrigeTam(nTamanho))) +"),"
   cStru += "WK_QTDE "+ convTipo(AVSX3("W8_QTDE"   ,AV_TIPO),"WK_QTDE") + "(" + alltrim(str(AVSX3("W8_QTDE"   ,AV_TAMANHO))) +If(AVSX3("W8_QTDE"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_QTDE" ,AV_DECIMAL)))+"),","),")
   //cStru += "WK_PRECO "+ convTipo(AVSX3("W8_PRECO"   ,AV_TIPO),"WK_PRECO") + "(" + alltrim(str(AVSX3("W8_PRECO"   ,AV_TAMANHO))) +If(AVSX3("W8_PRECO"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_PRECO" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_PRECO Char("+Alltrim(Str(AvSX3("W8_PRECO",3)))+"),"
   cStru += "WK_PEDIDO "+ convTipo(AVSX3("W8_PO_NUM"   ,AV_TIPO),"WK_PEDIDO") + "(" + alltrim(str(AVSX3("W8_PO_NUM"   ,AV_TAMANHO))) +If(AVSX3("W8_PO_NUM"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_PO_NUM" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_POSICAO "+ convTipo(AVSX3("W8_POSICAO"   ,AV_TIPO),"WK_POSICAO") + "(" + alltrim(str(AVSX3("W8_POSICAO"   ,AV_TAMANHO))) +If(AVSX3("W8_POSICAO"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_POSICAO" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_PGI_NUM "+ convTipo(AVSX3("W8_PGI_NUM"   ,AV_TIPO),"WK_PGI_NUM") + "(" + alltrim(str(AVSX3("W8_PGI_NUM"   ,AV_TAMANHO))) +If(AVSX3("W8_PGI_NUM"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_PGI_NUM" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_INCOTER "+ convTipo(AVSX3("W9_INCOTER"   ,AV_TIPO),"WK_INCOTER") + "(" + alltrim(str(AVSX3("W9_INCOTER"   ,AV_TAMANHO))) +If(AVSX3("W9_INCOTER"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W9_INCOTER" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_ADICAO "+ convTipo(AVSX3("W8_ADICAO"   ,AV_TIPO),"WK_ADICAO") + "(" + alltrim(str(AVSX3("W8_ADICAO"   ,AV_TAMANHO))) +If(AVSX3("W8_ADICAO"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_ADICAO" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_SEQ_ADI "+ convTipo(AVSX3("W8_SEQ_ADI"   ,AV_TIPO),"WK_SEQ_ADI") + "(" + alltrim(str(AVSX3("W8_SEQ_ADI"   ,AV_TAMANHO))) +If(AVSX3("W8_SEQ_ADI"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_SEQ_ADI" ,AV_DECIMAL)))+"),","),")
   cStru += "WK_CODFORN " + convTipo(AVSX3("W8_FORN"   ,AV_TIPO),"WK_CODFORN") + "(" + alltrim(str(AVSX3("W8_FORN"   ,AV_TAMANHO))) +If(AVSX3("W8_FORN"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_FORN" ,AV_DECIMAL)))+")",")")

   IF EICLOJA()
      cStru += ", WK_LOJFORN " + convTipo(AVSX3("W8_FORLOJ"   ,AV_TIPO),"WK_LOJFORN") + "(" + alltrim(str(AVSX3("W8_FORLOJ"   ,AV_TAMANHO))) +If(AVSX3("W8_FORLOJ"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_FORLOJ" ,AV_DECIMAL)))+")",")")
   ENDIF

   If lRegTCFO
      cStru += ", WK_REG_II " + convTipo(AVSX3("W8_REGTRI" ,AV_TIPO),"WK_REG_II" ) + "(" + alltrim(str(60                              )) +If(AVSX3("W8_REGTRI"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_REGTRI" ,AV_DECIMAL)))+"),","),")
      cStru += "WK_REG_IPI "  + convTipo(AVSX3("W8_REGIPI" ,AV_TIPO),"WK_REG_IPI") + "(" + alltrim(str(60                              )) +If(AVSX3("W8_REGIPI"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_REGIPI" ,AV_DECIMAL)))+"),","),")
      cStru += "WK_REG_PC "   + convTipo(AVSX3("W8_REG_PC" ,AV_TIPO),"WK_REG_PC" ) + "(" + alltrim(str(60                              )) +If(AVSX3("W8_REG_PC"   ,AV_TIPO) == "N","," +alltrim(str(AVSX3("W8_REG_PC" ,AV_DECIMAL)))+"),","),")
      cStru += "WK_COD_CFO "  + convTipo(AVSX3("WX_COD"    ,AV_TIPO),"WK_COD_CFO") + "(" + alltrim(str(AVSX3("WX_COD"      ,AV_TAMANHO))) +If(AVSX3("WX_COD"      ,AV_TIPO) == "N","," +alltrim(str(AVSX3("WX_COD"    ,AV_DECIMAL)))+"),","),")
      cStru += "WK_DSC_CFO "  + convTipo(AVSX3("WX_DESC"   ,AV_TIPO),"WK_DSC_CFO") + "(" + alltrim(str(AVSX3("WX_DESC"     ,AV_TAMANHO))) +If(AVSX3("WX_DESC"     ,AV_TIPO) == "N","," +alltrim(str(AVSX3("WX_DESC"   ,AV_DECIMAL)))+"),","),")
      cStru += "WK_OPRCFOP "  + convTipo(AVSX3("WZ_OPERACA",AV_TIPO),"WK_OPRCFOP") + "(" + alltrim(str(AVSX3("WZ_OPERACA"  ,AV_TAMANHO))) +If(AVSX3("WZ_OPERACA"  ,AV_TIPO) == "N","," +alltrim(str(AVSX3("WZ_OPERACA",AV_DECIMAL)))+"),","),")
      cStru += "WK_DSCCFOP "  + convTipo(AVSX3("WZ_DESC"   ,AV_TIPO),"WK_DSCCFOP") + "(" + alltrim(str(AVSX3("WZ_DESC"     ,AV_TAMANHO))) +If(AVSX3("WZ_DESC"     ,AV_TIPO) == "N","," +alltrim(str(AVSX3("WZ_DESC"   ,AV_DECIMAL)))+")",")")
   ENDIF

   //Ponto de entrada para personalizar a estrutura da Work a ser gerada pelo Excel
   If EasyEntryPoint("NFEEXCEL")
      ExecBlock("NFEEXCEL",.F.,.F.,"SET_ESTRUTURA_MACRO")
   EndIf

Return cStru

/*------------------------------------------------------------------------------------
Funcao      : convTipo
Parametros  : pTipo  - Tipo do campo no SX3 - N para numérico e C para caracter
              pCampo - Nome do campo que será criado
Retorno     : String com o tipo do campo no padrão SQL
Objetivos   : Converter o tipo do campo para o padrão SQL
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        : Usada na função SQLEstru
*------------------------------------------------------------------------------------*/
Static Function convTipo(pTipo,pCampo)
   Local cTipo := ""

   If pTipo == "N"
      cTipo := "Decimal"
      //Caso o campo seja numérico, adiciona na variável private cNumFields
      //usada para infomar a macro quais campos são numéricos
      If pCampo <> NIL
         cNumFields += pCampo + "/"
      EndIf
   Elseif pTipo == "C"
      cTipo := "Char"
   EndIF

return cTipo

/*------------------------------------------------------------------------------------
Funcao      : CorrigeTam
Parametros  : Numérico com o tamanho do campoq será criado
Retorno     : Valor corrigido
Objetivos   : Verificar se um campo não está com tamanho maior que 254 caracteres
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        : Usada na função SQLEstru
*------------------------------------------------------------------------------------*/
Static Function CorrigeTam(nTamanho)
   if nTamanho > 254
      nTamanho := 254
   EndIF
Return nTamanho

/*------------------------------------------------------------------------------------
Funcao      : AcertaChave
Parametros  : cChave - String que será transformada no padrão existente na base de dados
                       e retirado o caracter "-" se existir
              nTam  - Tamanho que o campo deverá ter, acrescentando zeros a esquerda
              lZero - Valor lógico informando se deverá ser acrescentado zeros a esquerda
Retorno     : Campo corrigido
Objetivos   : Transformar um valor obtido no XLS para o padrão existente no sistema
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function AcertaChave(cChave,nTam,lZero)
   Local cAux
   Default lZero := .F.

   If At("-",cChave) > 0
      cChave := SubStr(cChave,1,At("-",cChave)-1)
   EndIf
   If lZero
      If nTam - len(cChave) > 0
         cAux := StrZero(0,nTam-len(cChave))
         cChave := cAux + cChave
      EndIf
   EndIf
return cChave

/*------------------------------------------------------------------------------------
Funcao      : ShowErrors
Parametros  :
Retorno     :
Objetivos   : Montar Dialog mostrando os erros do registro selecionado
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function ShowErrors()
   Local oDlg
   Local oSel
   Local aCampos := {{"WK_LINHA" ,,"REGISTRO"},;
                     {"WK_SEQ"   ,,"SEQUENCIA"},;
                     {"WK_MOTIVO",,"DESCRIÇÃO"}}

   Local bOk := {|| oDlg:End()}
   Local bCancel := {|| oDlg:End()}
   Local aCores := {{ "WKERRO->WK_ALERTA", "BR_AMARELO" } , { "!WKERRO->WK_ALERTA" , "BR_VERMELHO" } }

   Local aButtons := {{"DBG09",{||Legenda("ERRO")},STR0106,STR0106}} //Legenda

   Local aPos
   WKERRO->(dbSetFilter({|| alltrim(str(WKERRO->WK_LINHA)) == alltrim(str(WKDADOSXLS->(Recno())))}, "WK_LINHA = " + AllTrim(Str(WKDADOSXLS->(Recno()))) + " "))
   WKERRO->(dbGoTop())

   DEFINE MSDIALOG oDlg TITLE STR0093 FROM DLG_LIN_INI-100,DLG_COL_INI TO (DLG_LIN_FIM-100)/2,DLG_COL_FIM-10 Pixel //"Não conformidades"
      aPos := PosDlg(oDlg)
      if SetMDIChild()
         aPos[3] -= 5
      EndIf

      oSel :=MsSelect():New("WKERRO",,,aCampos,@lInverte,@cMarca,aPos,,,,,aCores)
   Activate MSDIALOG oDlg on Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

   WKERRO->(dbClearFilter())
return


/*------------------------------------------------------------------------------------
Funcao      : AtuDados
Parametros  :
Retorno     :
Objetivos   : Atualizar os dados obtidos no XLS na base de dados
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        : Versão beta, alguns campos não existem na planilha
*------------------------------------------------------------------------------------*/
Static Function AtuDados()
Local lEIJ //Armazena se o registro existe na tabela EIJ, para atualizar os campos
Local aOrd := SaveOrd({"SW8","EIJ","SW9"})
Local cReg
Local cTot := alltrim(str(WKDADOSXLS->(EasyRecCount())))
Local aOrdSW9:= {}
Local cLoja := ""
WKDADOSXLS->(dbGoTop())

ProcRegua(val(cTot))


Begin Transaction
   While WKDADOSXLS->(!EOF())
      cReg := alltrim(str(WKDADOSXLS->(RECNO())))
      IncProc("Registro " + cReg + " de " + cTot )
      IF SW8->(dbSeek(xFilial("SW8")+AvKey(WKDADOSXLS->WK_HAWB,"W8_HAWB")+AvKey(WKDADOSXLS->WK_INVOICE,"W8_INVOICE")+AvKey(WKDADOSXLS->WK_PEDIDO,"W8_PO_NUM")+;
                                  AvKey(WKDADOSXLS->WK_POSICAO,"W8_POSICAO")+AvKey(WKDADOSXLS->WK_PGI_NUM,"W8_PGI_NUM")))

         lEIJ := EIJ->(dbSeek(xFilial("EIJ")+AvKey(SW8->W8_HAWB,"W8_HAWB")+AvKey(SW8->W8_GRUPORT,"EIJ_ADICAO")))

         IF EICLOJA() .And. Empty(cLoja := WKDADOSXLS->WK_LOJFORN)

            aOrdSW9:= SaveOrd({"SW9"})

            SW9->(DbSetOrder(1))
            IF SW9->(dbSeek(xFilial("SW9")+AvKey(WKDADOSXLS->WK_INVOICE,"W9_INVOICE")+AvKey(WKDADOSXLS->WK_CODFORN,"W9_FORN")))

               DO WHILE SW9->(!EOF()) .AND. xFilial("SW9") == SW9->W9_FILIAL .AND. DBFXLS->WK_INVOICE == SW9->W9_INVOICE .AND. DBFXLS->WK_CODFORN == SW9->W9_FORN

                  IF SW9->W9_HAWB == DBFXLS->WK_HAWB
                     cLoja:= SW9->W9_FORLOJ
                     EXIT
                  ENDIF

                  SW9->(DbSkip())
               ENDDO

            ENDIF

            RestOrd(aOrdSW9,.T.)

         ENDIF
         */

        If !Empty(WKDADOSXLS->WK_INCOTER)
            //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
            IF SW9->(dbSeek(xFilial("SW9")+AvKey(WKDADOSXLS->WK_INVOICE,"W9_INVOICE")+AvKey(WKDADOSXLS->WK_CODFORN,"W9_FORN")+IF(EICLOJA(),cLoja,"")+AvKey(WKDADOSXLS->WK_HAWB,"W9_HAWB")))
               RecLock("SW9",.F.)
                  SW9->W9_INCOTER := alltrim(WKDADOSXLS->WK_INCOTER)
               MsUnlock("SW9")
            EndIF
         EndIf

         If !Empty(WKDADOSXLS->WK_ADICAO)
            RecLock("SW8",.F.)
               SW8->W8_ADICAO := alltrim(WKDADOSXLS->WK_ADICAO)
            MsUnlock("SW8")
         EndIf

         If !Empty(WKDADOSXLS->WK_SEQ_ADI)
            RecLock("SW8",.F.)
               SW8->W8_SEQ_ADI := alltrim(WKDADOSXLS->WK_SEQ_ADI)
            MsUnlock("SW8")
         EndIf

      Else
         Alert(STR0094 + WKDADOSXLS->WK_HAWB) //"Erro ao localizar o processo "
      EndIf

      //Ponto de entrada para personalizar a importação de dados na base
      If EasyEntryPoint("NFEEXCEL")
         ExecBlock("NFEEXCEL",.F.,.F.,"IMPDADOS_BASE")
      EndIf

      WKDADOSXLS->(dbSkip())
   EndDo
End Transaction

RestOrd(aOrd,.T.)

return

/*------------------------------------------------------------------------------------
Funcao      : MontaMSG
Parametros  :
Retorno     : String com a mensagem que será enviada para o despachante, contendo os erros
              encontrados na planilha
Objetivos   : Montar mensagem com os erros encontrados na planilha
Autor       : Anderson Soares Toledo
Data/Hora   :
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function MontaMSG()
   Local cMSG

   WKDADOSXLS->(dbGoTop())

   cMSG := STR0095 + ENTER + ENTER //"Sr(a) Despachante:"
   cMSG += STR0096 + alltrim(WKDADOSXLS->WK_HAWB)  + ENTER //"Foram encontradas as seguintes divergências no processo "

   While WKDADOSXLS->(!EOF())
      //Verifica se o registro contem erros
      If !Empty(WKDADOSXLS->WK_ERRO)
         // Caso a mensagem contenha mais de 64000 caracteres, a mensagem será truncada para evitar 'String Overflow'
         if len(cMSG) < 64000
            cMSG += ENTER // pula  linha separando os itens

            cMSG += STR0097 + alltrim(WKDADOSXLS->WK_INVOICE) + STR0098 + alltrim(WKDADOSXLS->WK_PEDIDO) + STR0099 + alltrim(WKDADOSXLS->WK_POSICAO) + ENTER //"Invoice: ", " Pedido: " , " Posição: "
            cMSG += STR0100 + alltrim(WKDADOSXLS->WK_DESC_I)+ STR0101 + alltrim(WKDADOSXLS->WK_NCM) + ENTER //"Item: ", " NCM: "

            //Filtra a work com o registro corrente da WKDADOS XLS
            WKERRO->(dbSetFilter({|| alltrim(str(WKERRO->WK_LINHA)) == alltrim(str(WKDADOSXLS->(Recno())))}, "WK_LINHA = " + AllTrim(Str(WKDADOSXLS->(Recno()))) + " "))
            WKERRO->(dbGoTop())

            While WKERRO->(!EOF())
               cMSG += alltrim(WKERRO->WK_MOTIVO) + ENTER
               WKERRO->(dbSkip())
            EndDo
            WKERRO->(dbClearFilter())
         EndIf
      EndIf
      WKDADOSXLS->(dbSkip())
   EndDo
   cMSG += ENTER + STR0010// "Mensagem gerada automaticamente pelo SIGAEIC."

return cMSG

/*------------------------------------------------------------------------------------
Funcao      : VerifSeq
Parametros  :
Retorno     :
Objetivos   : Verificar se a sequencia das Adições e da quebras das adições estão corretas
Autor       : Anderson Soares Toledo
Data/Hora   : 30/10/08
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function VerifSeq()
   Local aAdicao := {}
   Local lErro
   Local x,j
   Local nTam
   Local aConf

   DBFXLS->(dbGoTop())

   While DBFXLS->(!EOF())
      If aScan(aAdicao,{|x| x == val(DBFXLS->WK_ADICAO)}) == 0
         aAdd(aAdicao, val(DBFXLS->WK_ADICAO))
      EndIf
      DBFXLS->(dbSkip())
   EndDo

   aSort(aAdicao)
   nTam := len(aAdicao)
   For x := 1 to nTam
      if aAdicao[x] <> x
         Alert(STR0102) //"Erro na Adição, não obedece uma sequência."
         lErro := .T.
         return lErro
      EndIf
   Next

   DBFXLS->(dbGoTop())

   Private aSeqAdi[nTam][1]

   For x:= 1 to len(aAdicao)
      While DBFXLS->(!EOF())
         nAdicao := val(DBFXLS->WK_ADICAO)
         if len(aSeqAdi[nAdicao]) == 1
            if aSeqAdi[nAdicao][1] == NIL
               aSeqAdi[nAdicao][1] := val(DBFXLS->WK_SEQ_ADI)
            Else
               aAdd(aSeqAdi[nAdicao],val(DBFXLS->WK_SEQ_ADI))
            EndIf
         Else
            aAdd(aSeqAdi[nAdicao],val(DBFXLS->WK_SEQ_ADI))
         EndIf
         DBFXLS->(dbSkip())
      EndDo
   Next

   aSort(aSeqAdi)
   For x := 1 to len(aSeqAdi)
      aSort(aSeqAdi[x])
      For j:= 1 to len(aSeqAdi[x])
         if aSeqAdi[x][j] <> j
            Alert(STR0103) //"Erro na sequência da adição, não respeita uma ordem."
            lErro := .T.
            return lErro
         EndIf
      Next
   Next

Return lErro


/*------------------------------------------------------------------------------------
Funcao      : AltCaracter
Parametros  : cFile - Nome do arquivo que será salvo
Retorno     : String com o nome do arquivo corrigido
Objetivos   : Retirar caracteres não reconhecidos pelas chamadas do Protheus
Autor       : Anderson Soares Toledo
Data/Hora   : 30/10/08
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function AltCaracter(cFile)
   cFile := alltrim(cFile)
   cFile := strTran(cFile,"'","_")
   cFile := strTran(cFile,"/","_")
   cFile := strTran(cFile,"\","_")
   cFile := strTran(cFile,"(","_")
   cFile := strTran(cFile,")","_")
   cFile := strTran(cFile,",","_")
   cFile := strTran(cFile,";","_")
   cFile := strTran(cFile,"*","_")
   cFile := strTran(cFile,"$","_")
   cFile := strTran(cFile,"@","_")
   cFile := strTran(cFile,"!","_")
   cFile := strTran(cFile,"|","_")
   cFile := strTran(cFile,":","_")
   cFile := strTran(cFile,"?","_")
   cFile := strTran(cFile,"<","_")
   cFile := strTran(cFile,">","_")
   cFile := strTran(cFile,'"',"_")
   cFile := strTran(cFile,"-","_")
   cFile := strTran(cFile," ","_")
return cFile


/*------------------------------------------------------------------------------------
Funcao      : ExistFile
Parametros  :
Retorno     :
Objetivos   : Verificar se os arquivos necessários existem no cliente, caso negativo, copiar do servidor
Autor       : Anderson Soares Toledo
Data/Hora   : 30/10/08
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function ExistFile()
   Local lRet := .T., h
   Local cPath := GetSrvProfString("STARTPATH","")

   If !lIsDir(cTempDbf)  //RMD - 11/12/2012
      MakeDir(cTempDbf)
   EndIf

   If !File(cTempDbf+"nfe.xla")   //RMD - 11/12/2012
      If FindFunction("DI590XLA")
         h := fcreate(cTempDbf+"nfe.xla")
         fwrite(h,DI590XLA())
         fclose(h)
         //Pega do repositório
      ElseIf File(GetSrvProfString("STARTPATH","")+"nfe.xla")
        If !CpyS2T(cPath+"nfe.xla",cTempDbf,.F.)  //RMD - 11/12/2012
            Alert(STR0104 + "nfe.xla") // "Erro ao copiar o arquivo nfe.xla
            lRet := .F.
         EndIf
      Else
         Alert(StrTran(STR0105,"###","nfe.xla")) // "Arquivo nfe.xla não encontrado no servidor, contate o Administrador."
         lRet :=  .F.
      EndIf
   EndIf

   If !File(cTempDbf+"nfe.xls")   //RMD - 11/12/2012
      If FindFunction("DI590XLS")
         h := fcreate(cTempDbf+"nfe.xls")
         fwrite(h,DI590XLS())
         fclose(h)
      ElseIf File(cPath+"nfe.xls")
         If !CpyS2T(cPath+"nfe.xls",cTempDbf,.F.)  //RMD - 11/12/2012
            Alert(STR0104 + "nfe.xls") //"Erro ao copiar o arquivo nfe.xls
            lRet := .F.
         EndIf
      Else
         Alert(StrTran(STR0105,"###","nfe.xls")) // "Arquivo nfe.xls não encontrado no servidor, contate o Administrador."
         lRet := .F.
      EndIf
   EndIf
return lRet


/*------------------------------------------------------------------------------------
Funcao      : Legenda
Parametros  : cOrigem, origem da chamada da função
                       ITENS - Tela de Dados obtidos XLS
                       ERRO  - Tela de Detalhe das não-conformidades encontradas
Retorno     :
Objetivos   : Apresentar tela com legenda da MsSelect
Autor       : Anderson Soares Toledo
Data/Hora   : 30/10/08
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Static  Function Legenda(cOrigem)
   if UPPER(cOrigem) == "ITENS"
      BrwLegenda(STR0106,STR0107,{	{"BR_VERDE"   ,STR0109},;  // Nenhum erro encontrado
                                    {"BR_VERMELHO",STR0110}} ) //"Erro/Alerta encontrado"
   ElseIf UPPER(cOrigem) == "ERRO"
      BrwLegenda(STR0106,STR0108,{	{"BR_AMARELO" ,STR0111}    ,;  //"Mensagem de Alerta, apenas informativa"
                                    {"BR_VERMELHO",STR0112}} )     //"Erro, necessário a correção para prosseguir"
   EndIf
return


/*------------------------------------------------------------------------------------
Funcao      : ExisteNF
Parametros  :
Retorno     :
Objetivos   : Verificar se o processo já não exite NF
Autor       : Anderson Soares Toledo
Data/Hora   : 30/10/08
Revisao     : ISS 13/12/10 - Incluido tratamento caso o sistema tenha geração de nota de despesa (NFD)
Obs.        :
*------------------------------------------------------------------------------------*/
Static Function ExisteNF(pProcesso)
   Local aOrd
   Local lRet := .F.

   aOrd := SaveOrd({"SF1"})

   SF1->(dbSetOrder(5)) //xFilial+F1_HAWB

   lRet := SF1->(dbSeek(xFilial("SF1")+AvKey(pProcesso,"F1_HAWB")))

   //ISS - 13/12/10 - Incluido tratamento caso o sistema tenha geração de nota de despesa (NFD)
   If lCposNFDesp .AND. lRet
      lRet := ExistHAWBNFE(AvKey(pProcesso,"F1_HAWB"))
   EndIf

   RestOrd(aOrd,.T.)
return lRet

function ExpXlsJS(cBinario)
Local nHandle := 0
Local lRet := .t.
nHandle := FCreate(cDestino)
FWrite(nHandle, decode64(cBinario))
FClose(nHandle)
lRet := nHandle # 0
return lRet

static function SeekSb1(cAlias)
Local cVar := (cAlias)+'->WV_COD_I'
SB1->(dbSeek(xFilial("SB1")+AvKey(&cVar,"B1_COD")))
Return

static function getVlrCampo(cAlias,cCampo,cTipo)
Local xRetorno := '',cVar:=''
Do Case    
   Case cCampo == "B1_DESC_I"
         SeekSb1(cAlias)
         xRetorno := StrTran(SB1->(MSMM(B1_DESC_I, TAMSX3("B1_VM_I")[1] ,,,LERMEMO)), ENTER, " ")  //DFS - 21/04/10 - Pega a descricao em Ingles
   Case cCampo == "B1_DESC_GI"
         SeekSb1(cAlias)
         xRetorno := SB1->(MSMM(B1_DESC_GI,TAMSX3("B1_VM_GI")[1],,,LERMEMO))  //DFS - 21/04/10 - Pega a descricao da LI
   Case cCampo == "B1_DESC_P"
         SeekSb1(cAlias)
         xRetorno := SB1->(MSMM(B1_DESC_P, TAMSX3("B1_VM_P")[1],,,LERMEMO))   //DFS - 21/04/10 - Pega a descricao em Portugues
   Case cTipo == "D"
         cVar := (cAlias)+'->'+cCampo 
         xRetorno :=dtoc(sTod(&cVar))
   otherWise    
   cVar := (cAlias)+'->'+cCampo 
   xRetorno := If(ValType(&cVar)=="C",rtrim(&cVar),&cVar) //B1_DESC já entra aqui direto
EndCase
return xRetorno

/*
Funcao      : getJson()
Parâmetros  :
Retorno     : Retorna o json com as informações a serem geradas na planilha, aqui caberá o ponto de entrada para que o cliente inclua mais campos na exportação dos dados
Objetivos   : REtornar um json com as informações para gerar a planilha
Autor       : Maurício Frison
Data        : Setembro/2022
*/
//funcionando 

static function getJson()
Local oJson := jsonobject():New()
Local aJson := {}, aDetailAux := {}, aDetails := {}
Local aJsonTitulos := {}
Local aCpos := setCposPlan()
Local i,k,nCount:=0
Local nLenAcpos := len(aCpos)
Local cAliasTemp := GetNextAlias()
Local tmpQuery := getSelectPlan(cAliasTemp, aCpos)
Local xValor := nil


//carrega jason com títulos
For i:=1 to nLenACpos
    AADD(aJsonTitulos,JsonObject():new())
    aJsonTitulos[i]['TITULO'] := aCpos[i][2]
    aJsonTitulos[i]['READONLY'] := aCpos[i][5]
    aJsonTitulos[i]['COLOR'] := aCpos[i][6]
    aJsonTitulos[i]['TAMANHO'] := aCpos[i][10]
next i 

//carrega json com os valores da tabela na horizonta (tipo grid)
nCount:=0
While !(tmpQuery)->(Eof()) 
    nCount += 1
    aDetailAux:={}
    for i:=1 to nLenACpos          
             oJson := JsonObject():new()
             oJson['VALOR'] := getVlrCampo(tmpQuery,aCpos[i][1],aCpos[i][9]) 
             AADD(aDetailAux,oJson)  
    next i
    AADD(aDetails,aDetailAux)       
    (tmpQuery)->(DbSkip())			
EndDo

(tmpQuery)->(DbCloseArea())

//monta json final
for i:=1 to nLenACpos  
    //carrega jason com os atributos do cabeçalho
    Aadd(aJson,JsonObject():new())
    aJson[i] := aJsonTitulos[i]

   //carrega jason com os atributos dos campos
   aDetailAux:={}
   Aadd(aDetailAux,JsonObject():new())
   aDetailAux[1]['READONLY'] := aCpos[i][3]

   Aadd(aDetailAux,JsonObject():new())
   aDetailAux[2]['COLOR'] := aCpos[i][4]
   aJson[i]['DETAILS'] := aDetailAux
    
   //carrega jason com os valores dos campos na vertical (com o campo, seus atributos e com todos os seus valores que vieram da tabela e depois vai para o próximo campo e etc...) 
   aDetailAux:={}    
   for k:=1 to nCount
//     aadd(aDetailAux,adetails[k][i]) NÃO ESTAVA TRAZENDO A SEGUNDA INFORMAÇÃO DO 'VALOR'
       aadd(aDetailAux,JsonObject():new())       
       aDetails[k][i]:GetJsonValue("VALOR", @xValor)
       aDetailAux[k]['VALOR'] := xValor
   next K    

   aJson[i]['VALORES'] := aDetailAux
next i

oJson:set(aJson)  
return oJson:toJson()


/*
Funcao      : EasyExpXLS()
Parâmetros  :
Retorno     :
Objetivos   :
Autor       :
Data        :

*/
Function EasyExpXLS()
Local oEasyJS := EasyJS():New()
Local cRet:=cErros:=''
Local cExcelJS := Decode64(getExcelBin64())
Local cJson := ''
Local lRet:=.F.
oEasyJS:AddLib(cExcelJS + getFuncsPlan())
oEasyJS:Activate()

cJson := getJson()
//EECView(cJson, 'AVISO')
//RETURN

oEasyJS:runJSSync("expConvXls('" + cJson + "').then((x)=>{retAdvpl(x)}).catch((x)=>{retAdvpl(x)});",{|x| cRet := x } , {|x| cErros := x } )
If(!empty(cErros),EasyHelp(STR0157 + cErros),If(empty(cRet),EasyHelp(STR0157 + STR0158),lRet := ExpXlsJS(cRet))) //Erro na geração da planilha: Retorno da geração da planilha vazio
oEasyJS:Destroy()
return lRet


/*
Funcao      : EasyImpXLS()
Parâmetros  :
Retorno     :
Objetivos   : Realizar a importação do arquivo XLS utilizando o framework EXCELJS
Autor       :
Data        :
Obs         : 
*/
static function EasyImpXLS( nRecSW6 )
   local aArea      := {}
   local aAreaSW6   := {}
   local lOk        := .F.
   local nHandle    := -1
   local nSize      := 0
   local cBuffer    := ""
   local nBytes     := 0
   local cMensagem  := STR0126 // "Foi identificado numéro, versão e data da DUIMP informada."
   local cSolucao   := STR0127 //  "Para realizar a importação da planilha, deverá remover essas informações manualmente."

   default nRecSW6    := SW6->(recno())

   aArea := getArea()

   dbSelectArea("SW6")
   aAreaSW6 := SW6->(getArea())
   SW6->(dbGoTo(nRecSW6))

   lOk := empty(SW6->W6_DI_NUM) .and. empty(SW6->W6_VERSAO) .and. empty(SW6->W6_DTREG_D)

   if lOk
      cMensagem := ""
      cSolucao := ""

      if showDLGImp("xlsx")

         if file( cOrigPath + cFile )
            nHandle := fOpen(cOrigPath + cFile)
         endif

         cMensagem := STR0128 + CHR(10) + CHR(10) + cOrigPath + alltrim(cFile) // "Falha ao abrir a planilha."
         if nHandle <> -1

            nSize := fSeek(nHandle,0,2)
            fSeek(nHandle,0)
            cBuffer := ""
            nBytes := fRead(nHandle,@cBuffer,nSize)
            fClose(nHandle)

            cMensagem  := STR0129 // "Falha ao ler a planilha."

            if !empty(cBuffer)

               cMensagem := ""
               cBuffer := Encode64(cBuffer) 
               FWMsgRun(, {|oSay| ProcImpXLS(@oSay, cBuffer, @cMensagem, @cSolucao) }, STR0130, STR0131 + "..." ) // "Processando", "Processando a importação da planilha..."

            endif

         endif

      endif

   endif

   if( !empty(cMensagem), EasyHelp(cMensagem, STR0125 , cSolucao), ) // "AVISO"

   restArea(aAreaSW6)
   restArea(aArea)

return

/*
Funcao      : ProcImpXLS()
Parâmetros  :
Retorno     : 
Objetivos   : Inicia o processamento da importação do arquivo XLS
Autor       : Maurício Frison
Data 	      : Setembro 2022
*/ 
static function ProcImpXLS(oSay, cBuffer, cMensagem, cSolucao)
   local oEasyJS    := nil
   local cExcelJS   := ""
   local cRet       := ""
   local cErros     := ""

   default cBuffer    := ""
   default cMensagem  := ""
   default cSolucao   := ""

   oSay:SetText(STR0132 + "...") // "Lendo os dados da planilha"
   ProcessMessage()

   oEasyJS := EasyJS():New()
   cExcelJS := Decode64(getExcelBin64())
   oEasyJS:AddLib(cExcelJS + getFuncsPlan())
   oEasyJS:Activate()

   cRet := ""
   cErros := ""
   oEasyJS:runJSSync("impConvXls('" + cBuffer + "', 1, retAdvpl, retAdvplError);",{|x| cRet := x } , {|x| cErros := decodeutf8(x) } )
   cMensagem := STR0133 + CHR(10) + CHR(10) + STR0134 + ": " + if( !empty(cErros) , cErros, if( empty(cRet) , STR0135, "") ) // "Falha ao importar a planilha." ## "Motivo" ## "Sem informação."

   if !empty(cRet)
      ProcXLS(oSay, cRet, @cMensagem, @cSolucao)
   endif

   oEasyJS:Destroy() //se deixar o destroy não chega na função ProcXLS

return

/*
Funcao      : ProcXLS()
Parâmetros  :
Retorno     : 
Objetivos   : Processa o retorno do framework ExcelJS
Autor       : Maurício Frison
Data 	      : Setembro 2022
*/ 
static function ProcXLS(oSay, jJsonPlan, cMsgRet, cSolucao)
   local aCpos      := {}
   local oJsonPlan  := nil
   local aHeadPlan  := {}
   local aRowsPlan  := {}
   local nLinhas    := 0 
   local cHawb      := ""
   local cChaveSW9  := ""
   local cChaveSWV  := ""
   local aSeek      := {}
   local aDados     := {}
   local aModelSW9  := {}
   local jMdlSW9Rel := nil
   local jMdlSWVRel := nil
   local jModelo    := nil
   local nPosCpo    := 0
   local nPosIDPTCP := 0
   local nPosVRSACP := 0
   local nPosDUIMP  := 0 
   local nPosVersao := 0 
   local nPosDtReg  := 0 
   local cDuimp     := ""
   local cVersao    := ""
   local dDataReg   := ctod("")
   local nRecSW6    := SW6->(recno())

   default cMsgRet    := ""
   default cSolucao   := ""

   begin sequence

      oJsonPlan := JsonObject():New()
      aCpos := setCposPlan()
      aPosCpos := Array(8)
      cMsgRet := ""

      oSay:SetText( STR0136 + "...") // "Validando os dados da planilha"
      ProcessMessage()
      if !ValidPlan(jJsonPlan, oJsonPlan, aCpos, @aHeadPlan, @aRowsPlan, @cMsgRet)
         break
      endif

      cMsgRet := ""
      aModelSW9 := {}
      // POS_HAWB   - Posição do Hawb
      // POS_INVOIC - Posição do Invoice
      // POS_FORN   - Posição do Fornecedor
      // POS_FORLOJ - Posição do Loja
      // POS_PO_NUM - Posição do PO
      // POS_POSICA - Posição do Posição
      // POS_SEQUEN - Posição do Sequência
      // POS_SEQDUI - Posição do Sequência DUIMP
      nPosCpo := getPosCpo(aCpos, "EIJ_IDPTCP"  )
      if nPosCpo > 0
         nPosIDPTCP := aScan( aHeadPlan, { |X| X == aCpos[nPosCpo][TITULO] } ) 
      endif

      nPosCpo := getPosCpo(aCpos, "EIJ_VRSACP"  )
      if nPosCpo > 0
         nPosVRSACP := aScan( aHeadPlan, { |X| X == aCpos[nPosCpo][TITULO] } ) 
      endif

      nPosCpo := getPosCpo(aCpos, "W6_DI_NUM"  )
      if nPosCpo > 0
         nPosDUIMP := aScan( aHeadPlan, { |X| X == aCpos[nPosCpo][TITULO] } ) 
      endif

      nPosCpo := getPosCpo(aCpos, "W6_VERSAO"  )
      if nPosCpo > 0
         nPosVersao := aScan( aHeadPlan, { |X| X == aCpos[nPosCpo][TITULO] } ) 
      endif

      nPosCpo := getPosCpo(aCpos, "W6_DTREG_D"  )
      if nPosCpo > 0
         nPosDtReg := aScan( aHeadPlan, { |X| X == aCpos[nPosCpo][TITULO] } ) 
      endif

      for nLinhas := 1 to len( aRowsPlan )

         if nPosDUIMP > 0 .and. nPosVersao > 0 .and. nPosDtReg > 0 .and. ;
            !empty( aRowsPlan[nLinhas][nPosDUIMP] ) .and. !empty( aRowsPlan[nLinhas][nPosVersao] ) .and. !empty( aRowsPlan[nLinhas][nPosDtReg] )
            cDuimp := aRowsPlan[nLinhas][nPosDUIMP]
            cVersao := aRowsPlan[nLinhas][nPosVersao]
            dDataReg := aRowsPlan[nLinhas][nPosDtReg]
         endif

         cHawb := aRowsPlan[nLinhas][POS_HAWB]
         // adicionando o modelo da invoice (SW9DETAIL)
         cChaveSW9 := cHawb + ;
                  aRowsPlan[nLinhas][POS_INVOIC] + ;
                  aRowsPlan[nLinhas][POS_FORN] + ;
                  aRowsPlan[nLinhas][POS_FORLOJ]
         aSeek := {}
         aAdd( aSeek , { "W9_FILIAL" ,  xFilial("SW9") })
         aAdd( aSeek , { "W9_HAWB"   ,  aRowsPlan[nLinhas][POS_HAWB] })
         aAdd( aSeek , { "W9_INVOICE",  aRowsPlan[nLinhas][POS_INVOIC] })
         aAdd( aSeek , { "W9_FORN"   ,  aRowsPlan[nLinhas][POS_FORN] })
         aAdd( aSeek , { "W9_FORLOJ" ,  aRowsPlan[nLinhas][POS_FORLOJ] })
         aDados := {}
         jMdlSW9Rel := aAddModel(@aModelSW9, "SW9DETAIL", cChaveSW9, aSeek, aDados)

         // adicionando o modelo dos itens de cada invoice (SWVDETAIL)
         cChaveSWV := cChaveSW9 + ;
                  aRowsPlan[nLinhas][POS_PO_NUM] + ;
                  aRowsPlan[nLinhas][POS_POSICA] + ; 
                  aRowsPlan[nLinhas][POS_SEQUEN]
         aSeek := {}
         aAdd( aSeek , { "WV_FILIAL" ,  xFilial("SWV") })
         aAdd( aSeek , { "WV_HAWB"   ,  aRowsPlan[nLinhas][POS_HAWB] })
         aAdd( aSeek , { "WV_INVOICE",  aRowsPlan[nLinhas][POS_INVOIC] })
         aAdd( aSeek , { "WV_FORN"   ,  aRowsPlan[nLinhas][POS_FORN] })
         aAdd( aSeek , { "WV_FORLOJ" ,  aRowsPlan[nLinhas][POS_FORLOJ] })
         aAdd( aSeek , { "WV_PO_NUM" ,  aRowsPlan[nLinhas][POS_PO_NUM] })
         aAdd( aSeek , { "WV_POSICAO",  aRowsPlan[nLinhas][POS_POSICA] })
         aAdd( aSeek , { "WV_SEQUENC",  aRowsPlan[nLinhas][POS_SEQUEN] })
         aDados := {}
         aAdd( aDados , { "WV_SEQDUIM",  aRowsPlan[nLinhas][POS_SEQDUI] })
         jMdlSWVRel := aAddModel(@jMdlSW9Rel, "SWVDETAIL", cChaveSWV, aSeek, aDados)

         if nPosIDPTCP > 0 .and. nPosVRSACP > 0 .and. !empty(aRowsPlan[nLinhas][nPosIDPTCP]) .and. !empty(aRowsPlan[nLinhas][nPosVRSACP])
            // adicionando o modelo de dados de cada item (EIJMASTER)
            aSeek := {}
            aDados := {}
            aAdd( aDados , { "EIJ_IDPTCP",  aRowsPlan[nLinhas][nPosIDPTCP] })
            aAdd( aDados , { "EIJ_VRSACP",  aRowsPlan[nLinhas][nPosVRSACP] })
            aAddModel(@jMdlSWVRel, "EIJMASTER", cChaveSWV, aSeek, aDados)
         endif
      next

      if len(aModelSW9) > 0

         jModelo := JsonObject():New()
         jModelo:set(aModelSW9[1])
         fwfreeobj(aModelSW9)
         fwfreeobj(jMdlSW9Rel)

         oSay:SetText(STR0137 + "...") // "Importando os dados da planilha"
         ProcessMessage()

         if !EICLP501(cHawb, jModelo)
            break
         endif

         cMsgRet := ""
         if !AtuProcess( nRecSW6, cDuimp, cVersao, dDataReg, @cMsgRet, @cSolucao)
            break
         endif

         MsgInfo( STR0138 , STR0125 ) // "Planilha importada com sucesso." ## "AVISO"

      endif

   end sequence

   fwfreeobj(oJsonPlan)
   fwfreeobj(jModelo)

return

/*
Funcao      : AtuProcess()
Parâmetros  :
Retorno     : 
Objetivos   : Atualização do Numero da Duimp, Versão da Duimp e Data de registro da Duimp
Autor       : Maurício Frison
Data 	      : Setembro 2022
*/ 
static function AtuProcess( nRecSW6, cDuimp, cVersao, dDataReg, cMsg, cSolucao)
   local lRet       := .F.
   local oRegExp    := nil
   local nCpos      := 0

   private nOPC_mBrw  := 4

   default nRecSW6    := SW6->(recno())
   default cDuimp     := ""
   default cVersao    := ""
   default dDataReg   := ctod("")
   default cMsg       := ""
   default cSolucao   := ""

   begin sequence

   if empty(cDuimp) .or. empty(cVersao) .or. empty(dDataReg)
      cMsg := STR0152 // "O Número, Versão ou Data de Registro da DUIMP não foi informado ou está incorreto."
      break
   endif

   cMsg := ""

   cDuimp := alltrim(StrTran(cDuimp, "-", ""))

   oRegExp := tRegex():new("([Z])\w+")
   oRegExp:SetPattern('^[0-9]{2}[A-Z]{2}[0-9]{11}')
   if !oRegExp:Search(cDuimp)
      cMsg := STR0153 + CHR(10) + CHR(10) // "O formato do Número da DUIMP não foi preenchido corretamente." 
      cMsg += STR0154 + ": " + cDuimp // "Valor informado"
      cSolucao := STR0155 + CHR(10) + CHR(10) // "Deverá ser informado no formato: 'NNAANNNNNNNNNNN' "
      cSolucao += STR0156 + ": 22BR00000012345" // "Exemplo"
      break
   endif

   DbSelectArea("SW6")
   SW6->(dbgoto(nRecSW6))
   // carregando na memoria os campos devido ao DI_Valid
   for nCpos := 1 to SW6->(FCount())
      M->&(SW6->(FieldName(nCpos))) := SW6->(FieldGet(nCpos))
   NEXT nCpos
   M->W6_TX_US_D := SW6->W6_TX_US_D
   M->W6_TIPOREG := SW6->W6_TIPOREG
   M->W6_FORMREG := SW6->W6_FORMREG
   M->W6_HAWB    := SW6->W6_HAWB

   M->W6_REGMANU := cDuimp 
   M->W6_VSMANU := cVersao
   M->W6_DTMANU := dDataReg

   if !DI_Valid("W6_VSMANU") .or. !DI_Valid("W6_DTMANU") .or. !DI_Valid("W6_REGMANU")
      break
   endif

   SW6->(dbgoto(nRecSW6))
   if reclock("SW6", .F.)
      SW6->W6_REGMANU := M->W6_REGMANU
      SW6->W6_VSMANU := M->W6_VSMANU
      SW6->W6_DTMANU := M->W6_DTMANU
      SW6->W6_DI_NUM := M->W6_REGMANU
      SW6->W6_VERSAO := M->W6_VSMANU
      SW6->W6_DTREG_D := M->W6_DTMANU
      SW6->(MsUnlock())
   endif

   lRet := .T.

   end sequence

   fwfreeobj(oRegExp)

return lRet

/*
Funcao      : aAddModel()
Parâmetros  :
Retorno     : 
Objetivos   : Adiciona modelo de dados (EICLP500)
Autor       : Maurício Frison
Data 	      : Setembro 2022
*/ 
static function aAddModel(aModelos, cModelo, cChave, aSeek, aDados)
   local nPosChave  := 0
   local cChaveRet  := ""
   local jModel     := nil
   local jMdlChave  := nil

   default aModelos   := {}
   default cModelo    := ""
   default cChave     := ""
   default aSeek      := {}
   default aDados     := {}

   if !empty(cModelo)
      nPosModelo := aScan( aModelos, { |X| !X:GetJsonValue(cModelo, @cChaveRet) .or. !empty(cChaveRet)} )
      if nPosModelo == 0
         jModel := JsonObject():New()
         jModel[cModelo] := {}
         aAdd( aModelos, jModel )
      else
         jModel := aModelos[nPosModelo]
      endif
   endif

   if !empty(cChave)
      cChaveRet := ""
      nPosChave := aScan( jModel[cModelo], { |X| X:GetJsonValue("CHAVE", @cChaveRet) .and. cChaveRet == cChave} )
      if nPosChave == 0
         jMdlChave := JsonObject():New()
         jMdlChave["CHAVE"] := cChave
         jMdlChave["SEEK"] := aClone(aSeek)
         jMdlChave["DADOS"] := aClone(aDados)
         jMdlChave["RELACIONAMENTOS"] := {}
         aAdd( jModel[cModelo] , jMdlChave)
      else
         jMdlChave := jModel[cModelo][nPosChave]
      endif
      jMdlChave["DADOS"] := aClone(aDados)
   endif

   aSize(aDados,0)
   aSize(aSeek,0)

return jMdlChave["RELACIONAMENTOS"]

/*
Funcao     : ValidPlan
Objetivo   : Validação das colunas e linhas da planilha para importação
Parametros : jJsonPlan - Planilha em Json (caracter)
             oJsonPlan - Objeto Json da planilha
             aCpos - Vetor com os campos {Campo, Titulo}
             aHeadPlan - Retorna o cabeçalho da planilha
             aRowsPlan - Retorna as linhas da planilha
             cError - Mensagem de erro
Retorno    : lRet - Lógico
Autor      : Bruno Akyo Kubagawa
Data       : Setembro/2022
*/
static function ValidPlan(jJsonPlan, oJsonPlan, aCpos, aHeadPlan, aRowsPlan, cError)
   local lRet       := .F.
   local aNames     := {}
   local nTotalCol  := 0
   local nCpos      := 0
   local nPosCpo    := 0
   local xRet       := nil 
   local nRow       := 0
   local aRows      := {}
   local aRow       := {}
   local nLenRow    := 0
   local nCol       := 0
   local aCells     := {}
   local xCell      := nil

   default oJsonPlan  := JsonObject():New()
   default aCpos      := setCposPlan()
   default aHeadPlan  := {}
   default aRowsPlan  := {}
   default cError     := ""

   xRet := oJsonPlan:FromJson(jJsonPlan)
   lRet := xRet == nil

   cError := STR0139 + if( !lRet , CHR(10) + CHR(10) + STR0140 + ":" + xRet, "" ) // "Falha ao converter a planilha em objeto json." ## "Erro"
   if lRet

      aNames := oJsonPlan:getNames()
      lRet := .F.
      cError := STR0141 // "Estrutura da planilha inválida."
      POS_HAWB := 0
      POS_INVOIC := 0
      POS_FORN := 0
      POS_FORLOJ := 0
      POS_PO_NUM := 0
      POS_POSICA := 0
      POS_SEQUEN := 0
      POS_SEQDUI := 0
 
      if aScan( aNames, { |X| alltrim(X) == "header" }) > 0 .and. aScan( aNames, { |X| alltrim(X) == "rows" }) > 0

         aHeadPlan := oJsonPlan["header"][1]

         // Relação das colunas da planilha com o que está determinado na função setCposPlan
         aSize( _aPosCpos, 0)
         _aPosCpos := {}
         nTotalCol := len(aHeadPlan)
         for nCpos := 1 to nTotalCol
            nPosCpo := getPosCpo(aCpos, "", aHeadPlan[nCpos] )
            if nPosCpo > 0
               if aCpos[nPosCpo][CAMPO] == "WV_HAWB"
                  POS_HAWB := nCpos
               elseif aCpos[nPosCpo][CAMPO] == "WV_INVOICE"
                  POS_INVOIC := nCpos
               elseif aCpos[nPosCpo][CAMPO] == "WV_FORN"
                  POS_FORN := nCpos
               elseif aCpos[nPosCpo][CAMPO] == "WV_FORLOJ"
                  POS_FORLOJ := nCpos
               elseif aCpos[nPosCpo][CAMPO] == "WV_PO_NUM"
                  POS_PO_NUM := nCpos
               elseif aCpos[nPosCpo][CAMPO] == "WV_POSICAO"
                  POS_POSICA := nCpos
               elseif aCpos[nPosCpo][CAMPO] == "WV_SEQUENC"
                  POS_SEQUEN := nCpos
               elseif aCpos[nPosCpo][CAMPO] == "WV_SEQDUIM"
                  POS_SEQDUI := nCpos
               endif 
            endif
            aAdd( _aPosCpos, { nCpos, nPosCpo} )
         next

         cError += CHR(10) + STR0142 // "Colunas principais não foram encontradas."
         if POS_HAWB > 0 .and. POS_INVOIC > 0 .and. POS_FORN > 0 .and. POS_FORLOJ > 0 .and. POS_PO_NUM > 0 .and. POS_POSICA > 0 .and. POS_SEQUEN > 0 .and. POS_SEQDUI > 0

            cError := STR0143 // "Planilha sem informações para importação."
            aRows := oJsonPlan["rows"]

            for nRow := 1 to len(aRows)

               aRow := aRows[nRow]['row']
               nLenRow := len(aRow)

               if aScan( aRow, { |X| X <> nil}) > 0

                  nCol := 1
                  aCells := {}
                  while nCol <= nTotalCol
                     xCell := nil
                     if nCol <= nLenRow
                        xCell := aRow[nCol]
                     endif

                     if xCell <> nil
                        nPosCpo := _aPosCpos[nCol][2]
                        if nPosCpo > 0
                           do case
                              case aCpos[nPosCpo][TIPO] == "C" 
                                 xCell := PadR(xCell, aCpos[nPosCpo][TAMANHO])
                              case aCpos[nPosCpo][TIPO] == "D"
                                 xCell := if( valtype(xCell) == "C" , if ( at( "-", subStr( xCell, 1 , 10)) > 0 , stod( StrTran( subStr( xCell, 1 , 10), "-", "") ), ctod(xCell)), ctod(""))
                              //case aCpos[nPosCpo][TIPO] == "N" .and. valtype(xCell) == "C"
                              //   xCell := Val( StrTran(xCell,",",".") )
                           end case
                        endif
                     endif
                     aAdd( aCells , xCell)
                     nCol += 1
                  end

                  if len(aCells) > 0 
                     aAdd( aRowsPlan, aClone(aCells) )
                     aSize( aCells , 0)
                     aCells := {}
                  endif

               endif

            next

            if len(aRowsPlan) > 0
               cError := STR0144 + CHR(10) + CHR(10) + STR0145 + ": " + SW6->W6_HAWB + CHR(10) + STR0146 + ": " + aRowsPlan[POS_HAWB][1] // "O processo posicionado não é o mesmo informado da planilha." ## "Processo posicionado" ## "Processo da planiha"
               if SW6->W6_HAWB == aRowsPlan[POS_HAWB][1]
                  nRow := aScan( aRowsPlan, { |X| X[POS_SEQDUI] == nil .or. empty(X[POS_SEQDUI])}) 
                  cError := STR0147 + if( nRow > 0 , CHR(10) + STR0148 + ": " + cValTochar(nRow+1), "") // "A sequência da DUIMP não foi informado na planilha." ## "Linha da planilha"
                  if nRow == 0
                     cError := ""
                     lRet := .T.
                  endif
               endif
            endif

         endif

      endif

   endif

return lRet

/*
Funcao     : getPosCpo
Objetivo   : Retorna a posição de um determinado campo
Parametros : aCpos - Vetor com os campos {Campo, Titulo}
             aHeadPlan - Vetor com cabeçalho da planilha
             cCampo - campo a ser buscado
             cTitulo - busca pelo titulo
Retorno    : nPos - posição do campo do vetor aCpos
Autor      : Bruno Akyo Kubagawa
Data       : Setembro/2022
*/
static function getPosCpo(aCpos, cCampo, cTitulo)
   local nPos       := 0

   default aCpos      := setCposPlan()
   default cCampo     := ""
   default cTitulo    := ""

   if !empty(cCampo) .or. !empty(cTitulo)
      nPos := if( !empty(cCampo) , aScan( aCpos, { |X| X[CAMPO] == alltrim(cCampo) } ), aScan( aCpos, { |X| X[TITULO] == alltrim(cTitulo) } )) 
   endif

return nPos

/*
Funcao     : getFuncsPlan
Objetivo   : Cria uma string com as funções necessárias para a importação e exportação de dados via planilha eletrônica
Parametros : -
Retorno    : cRet - String com todas as funções necessárias para a importação e exportação de dados via planilha eletrônica
Autor      : Maurício Frison
Data       : Setembro/2022
*/
Static function getFuncsPlan()
Local cVar

begincontent var cVar

function convBinario(binario) {
   return btoa(Array.from(new Uint8Array(binario)).map((a) => { return String.fromCharCode(a) }).join(''))
};

async function expConvXls(cJson) { 
   var planilha = await expGeraXls(cJson); 
   planilha = convBinario(planilha); 
   return planilha; 
};

function getBoolean(parametro){
let Retorno = true;
if (parametro == 'false') {
   Retorno = false
}
return Retorno;
}

function expCelula(num){
    let n=num;
    let a=n/26;
    let b=Math.trunc(a);
    let cFinal = '';
    let d = 0;
    if (a <=1) {
       cFinal = String.fromCharCode(n+64);
    } else {
      d = n-(26*b);
      if (d === 0){
         d = 26;
         b = b-1;
      }
      
      cFinal =   String.fromCharCode(b+64) + String.fromCharCode(d+64);
    }
    return cFinal
  };

function expGeraXls(cJson) {   
   return new Promise (resolve =>{      
      const oJson = JSON.parse(cJson); 
      const wb = new ExcelJS.Workbook();
      const ws = wb.addWorksheet('Sheet1'); 
      const password = Math.trunc(Math.random()*1000000).toString();           
      let nColunas = Object.keys(oJson).length;
      ws.getRow(1).font = { bold: true };
      for (let i=0; i < nColunas; i++)  {
          const coluna = ws.getColumn(i+1);
          coluna.width = oJson[i].TAMANHO;
          let celula = this.expCelula(i+1)+'1';
          ws.getCell(celula).value = oJson[i].TITULO;  
          if (oJson[i].COLOR != 'Default') {          
             ws.getCell(celula).fill = {type: 'pattern',pattern:'solid',fgColor:{argb:oJson[i].COLOR},};
          }   
          lcheck = this.getBoolean(oJson[i].READONLY);        
          ws.getCell(celula).protection = {locked: lcheck};          
      }   
      let nLinhas = Object.keys(oJson[0].VALORES).length;
      for (let i=0; i < nColunas; i++)  {
          for (let j=0; j < nLinhas; j++)  {         
               let celula = this.expCelula(i+1)+(j+2);
               ws.getCell(celula).value = oJson[i].VALORES[j].VALOR
               if (oJson[i].DETAILS[1].COLOR != 'Default') {          
                  ws.getCell(celula).fill = {type: 'pattern',pattern:'solid',fgColor:{argb:oJson[i].DETAILS[1].COLOR},};               
               }                     
               lcheck =  this.getBoolean(oJson[i].DETAILS[0].READONLY);        
               ws.getCell(celula).protection = {locked: lcheck};
          }
      }    
      ws.protect(password);
      wb.xlsx.writeBuffer()
         .then(function (buffer) {
         resolve(buffer);
     });  
   })
 };

 async function impConvXls(cBuffer, cWorkSheet, retAdvpl, retAdvplError) { 
   var jSonPlan = {};
   var WorkBook = await impGeraXls(cBuffer);

   if( WorkBook ) {
      var WorkSheet = WorkBook.getWorksheet(cWorkSheet);
      if(WorkSheet) {

         jSonPlan = { header: [], rows: [] };
 
         var row = '';
         for (i = 1; i <= WorkSheet._rows.length; i++) {
            dados = [];
            row = WorkSheet.getRow(i);
            row.eachCell({includeEmpty: true}, (cell, colNumber) => {
               dados.push( row.getCell(colNumber).value );
            });

            if( i === 1){
               jSonPlan.header.push( dados  );
            } else {
               if(dados.length){
                  jSonPlan.rows.push( { linha: i , row: dados } );
               }
            }
         }

         if (jSonPlan) {
            retAdvpl(JSON.stringify(jSonPlan));
         } else {
            retAdvplError(STR0149); // 'Planilha em branco.'
         }
      } else {
         retAdvplError(STR0150); // 'Planilha com problema [WorkSheet inválido].'
      }
   } else {
      retAdvplError(STR0151); // 'Planilha com problema [WorkBook inválido].'
   }

};

 function impGeraXls(cBuffer) {
   return new Promise (resolve =>{
      const wb = new ExcelJS.Workbook();
      cBuffer = atob(cBuffer);
      wb.xlsx.load(cBuffer) 
         . then(function (wb) {
         resolve(wb);
     }) 
   })
 };

endcontent
Return cVar

/*
Funcao     : getTamanho
Objetivo   : determinar a largura da coluna ser gerada no excel, pega o tamanho definido no dicionário ou tamanho do título, o que for maior
Parametros : -cCampo: Campo a ser determinada a largura da coluna
Retorno    : nTam: largura da coluna
Autor      : Maurício Frison
Data       : Setembro/2022
*/
static function getTamanho(cCampo)
Local nTamDic := getSX3Cache(cCampo,"X3_TAMANHO")
Local nTamTit := LEN(alltrim(getSX3Cache(cCampo,"X3_TITULO")))
Local nTam := if(nTamDic > nTamTit, nTamDic, nTamTit) + 2
return nTam

/*
Funcao     : setCposPlan
Objetivo   : De/para para as colunas da planilha
Parametros : -
Retorno    : aCpos - Vetor com os campos {Campo, Titulo, ReadOnly_Campo, Color_Campo, ReadOnly_Titulo, Color_Titulo,Tamanho dicionário,decimal,tipo, tamanho célula excel}
Autor      : Bruno Akyo Kubagawa
Data       : Setembro/2022
*/
static function setCposPlan()
   local aCpos      := {}
   local cCampo     := ""
   local nCpo       := 0
   local aCposUser  := {}
   local cTabela    := ""
   local nAt        := 0
   local cReadOnly  := ""
   local cColor     := ""
   local aTabelas   := {}

   if len(_aCposPlan) == 0
      aTabelas := { "SWV", "SW8", "SW9", "EIJ", "SWZ", "SWX", "SW6", "SB1" }
      cCampo := getDesPrd()                                                   //procurar pela cor em hexadecimal, retirar o caracter # e colocar o 0x na frente 
      _aCposPlan := {;                                                       //https://ajuda.getcommerce.com.br/article/506-tabela-de-cores-hexadecimal
         { "WV_HAWB"    , alltrim(getSX3Cache("WV_HAWB"    , "X3_TITULO")), "true"  , "0xD3D3D3" , "true" , "0x778899" , getSX3Cache("WV_HAWB"    , "X3_TAMANHO"), getSX3Cache("WV_HAWB"    , "X3_DECIMAL"), getSX3Cache("WV_HAWB"    , "X3_TIPO"),getTamanho("WV_HAWB") }, ; // PROCESSO
         { "WV_INVOICE" , alltrim(getSX3Cache("WV_INVOICE" , "X3_TITULO")), "true"  , "0xD3D3D3" , "true" , "0x778899" , getSX3Cache("WV_INVOICE" , "X3_TAMANHO"), getSX3Cache("WV_INVOICE" , "X3_DECIMAL"), getSX3Cache("WV_INVOICE" , "X3_TIPO"),getTamanho("WV_INVOICE") }, ; // INVOICE
         { "WV_FORN"    , alltrim(getSX3Cache("WV_FORN"    , "X3_TITULO")), "true"  , "0xD3D3D3" , "true" , "0x778899" , getSX3Cache("WV_FORN"    , "X3_TAMANHO"), getSX3Cache("WV_FORN"    , "X3_DECIMAL"), getSX3Cache("WV_FORN"    , "X3_TIPO"),getTamanho("WV_FORN") }, ; // FORNECEDOR
         { "WV_FORLOJ"  , alltrim(getSX3Cache("WV_FORLOJ"  , "X3_TITULO")), "true"  , "0xD3D3D3" , "true" , "0x778899" , getSX3Cache("WV_FORLOJ"  , "X3_TAMANHO"), getSX3Cache("WV_FORLOJ"  , "X3_DECIMAL"), getSX3Cache("WV_FORLOJ"  , "X3_TIPO"),getTamanho("WV_FORLOJ") }, ; // LOJA
         { "W8_FABR"    , alltrim(getSX3Cache("W8_FABR"    , "X3_TITULO")), "true"  , "0xD3D3D3" , "true" , "0x778899" , getSX3Cache("W8_FABR"    , "X3_TAMANHO"), getSX3Cache("W8_FABR"    , "X3_DECIMAL"), getSX3Cache("W8_FABR"    , "X3_TIPO"),getTamanho("W8_FABR") }, ; // FABRICANTE
         { "W8_FABLOJ"  , alltrim(getSX3Cache("W8_FABLOJ"  , "X3_TITULO")), "true"  , "0xD3D3D3" , "true" , "0x778899" , getSX3Cache("W8_FABLOJ"  , "X3_TAMANHO"), getSX3Cache("W8_FABLOJ"  , "X3_DECIMAL"), getSX3Cache("W8_FABLOJ"  , "X3_TIPO"),getTamanho("W8_FABLOJ") }, ; // LOJA
         { "WV_PO_NUM"  , alltrim(getSX3Cache("WV_PO_NUM " , "X3_TITULO")), "true"  , "0xD3D3D3" , "true" , "0x778899" , getSX3Cache("WV_PO_NUM"  , "X3_TAMANHO"), getSX3Cache("WV_PO_NUM"  , "X3_DECIMAL"), getSX3Cache("WV_PO_NUM"  , "X3_TIPO"),getTamanho("WV_PO_NUM") }, ; // PEDIDO
         { "WV_POSICAO" , alltrim(getSX3Cache("WV_POSICAO" , "X3_TITULO")), "true"  , "0xD3D3D3" , "true" , "0x778899" , getSX3Cache("WV_POSICAO" , "X3_TAMANHO"), getSX3Cache("WV_POSICAO" , "X3_DECIMAL"), getSX3Cache("WV_POSICAO" , "X3_TIPO"),getTamanho("WV_POSICAO") }, ; // POSIÇÃO
         { "WV_SEQUENC" , alltrim(getSX3Cache("WV_SEQUENC" , "X3_TITULO")), "true"  , "0xD3D3D3" , "true" , "0x778899" , getSX3Cache("WV_SEQUENC" , "X3_TAMANHO"), getSX3Cache("WV_SEQUENC" , "X3_DECIMAL"), getSX3Cache("WV_SEQUENC" , "X3_TIPO"),getTamanho("WV_SEQUENC") } ; // SEQUÊNCIA 
      }

      aAdd( aCposUser, { "W9_MOE_FOB" , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "W9_INCOTER" , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "WV_COD_I"   , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { cCampo       , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "W8_TEC"     , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "W8_UNID"    , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "WV_QTDE"    , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "W8_PRECO"   , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "W8_REGTRI"  , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "W8_REGIPI"  , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "W8_REG_PC"  , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "WX_COD"     , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "WX_DESC"    , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "WZ_OPERACA" , "true" , "0xD3D3D3" } )
      aAdd( aCposUser, { "WZ_DESC"    , "true" , "0xD3D3D3" } )

      aCposUser := if(EasyEntryPoint("NFEEXCEL"), ExecBlock("NFEEXCEL",.F.,.F., { "EXP_DADOS_DUIMP", aCposUser }) , aCposUser )
      if valtype(aCposUser) == "A"
         for nCpo := 1 to len(aCposUser)
            if len(aCposUser[nCpo]) > 0
               cCampo := alltrim(aCposUser[nCpo][1])
               nAt := at( "_", cCampo)
               if nAt > 0
                  cTabela := substr( cCampo, 1, nAt - 1)
                  cTabela := if(len(cTabela)==2, "S" + cTabela , cTabela)
                  if aScan( aTabelas , { |X| X == cTabela}) > 0 .and. (cTabela)->(ColumnPos( cCampo )) > 0
                     if aScan( _aCposPlan, { |X| X[CAMPO] == cCampo } ) == 0 .and. !( cCampo $ "WV_SEQDUIM||EIJ_IDPTCP||EIJ_VRSACP||W6_DI_NUM||W6_VERSAO||W6_DTREG_D" )
                        cReadOnly := if( len(aCposUser[nCpo]) > 1 , aCposUser[nCpo][2] , "true" )
                        cColor := if( len(aCposUser[nCpo]) > 2 , if( len(alltrim(aCposUser[nCpo][3])) == 6, "0x" + alltrim(aCposUser[nCpo][3]), alltrim(aCposUser[nCpo][3]) ) , "0xD3D3D3")
                        aAdd( _aCposPlan, { cCampo, alltrim(getSX3Cache(cCampo,"X3_TITULO")) , cReadOnly , cColor, "true" , "0x778899" , getSX3Cache(cCampo,"X3_TAMANHO"), getSX3Cache(cCampo,"X3_DECIMAL"), getSX3Cache(cCampo, "X3_TIPO"), getTamanho(cCampo) } )
                     endif
                  endif
               endif
            endif
         next
      EndIf   

      aAdd( _aCposPlan, { "WV_SEQDUIM" , alltrim(getSX3Cache("WV_SEQDUIM" , "X3_TITULO")) , "false" , "Default" , "true" , "0x778899" , getSX3Cache("WV_SEQDUIM" , "X3_TAMANHO"), getSX3Cache("WV_SEQDUIM" , "X3_DECIMAL"), getSX3Cache("WV_SEQDUIM" , "X3_TIPO"),getTamanho("WV_SEQDUIM") } ) // SEQ. DUIMP
      aAdd( _aCposPlan, { "EIJ_IDPTCP" , alltrim(getSX3Cache("EIJ_IDPTCP" , "X3_TITULO")) , "false" , "Default" , "true" , "0x778899" , getSX3Cache("EIJ_IDPTCP" , "X3_TAMANHO"), getSX3Cache("EIJ_IDPTCP" , "X3_DECIMAL"), getSX3Cache("EIJ_IDPTCP" , "X3_TIPO"),getTamanho("EIJ_IDPTCP") } ) // ID PORTAL
      aAdd( _aCposPlan, { "EIJ_VRSACP" , alltrim(getSX3Cache("EIJ_VRSACP" , "X3_TITULO")) , "false" , "Default" , "true" , "0x778899" , getSX3Cache("EIJ_VRSACP" , "X3_TAMANHO"), getSX3Cache("EIJ_VRSACP" , "X3_DECIMAL"), getSX3Cache("EIJ_VRSACP" , "X3_TIPO"),getTamanho("EIJ_VRSACP") } ) // VERSÃO DO CATÁLOGO
      aAdd( _aCposPlan, { "W6_DI_NUM"  , alltrim(getSX3Cache("W6_DI_NUM"  , "X3_TITULO")) , "false" , "Default" , "true" , "0x778899" , getSX3Cache("W6_DI_NUM"  , "X3_TAMANHO"), getSX3Cache("W6_DI_NUM"  , "X3_DECIMAL"), getSX3Cache("W6_DI_NUM"  , "X3_TIPO"),getTamanho("W6_DI_NUM") }  ) // NÚMERO DUIMP
      aAdd( _aCposPlan, { "W6_VERSAO"  , alltrim(getSX3Cache("W6_VERSAO"  , "X3_TITULO")) , "false" , "Default" , "true" , "0x778899" , getSX3Cache("W6_VERSAO"  , "X3_TAMANHO"), getSX3Cache("W6_VERSAO"  , "X3_DECIMAL"), getSX3Cache("W6_VERSAO"  , "X3_TIPO"),getTamanho("W6_VERSAO") }  ) // VERSÃO DUIMP
      aAdd( _aCposPlan, { "W6_DTREG_D" , alltrim(getSX3Cache("W6_DTREG_D" , "X3_TITULO")) , "false" , "Default" , "true" , "0x778899" , getSX3Cache("W6_DTREG_D" , "X3_TAMANHO"), getSX3Cache("W6_DTREG_D" , "X3_DECIMAL"), getSX3Cache("W6_DTREG_D" , "X3_TIPO"),getTamanho("W6_DTREG_D") } ) // DATA REGISTRO

   endif

   aCpos := aClone(_aCposPlan)

return aCpos

/*
Funcao     : getSelectPlan
Objetivo   : Retornar uma instâcia da execução de uma query
Parametros : - cAliasTemp : alias para criação da tabela temporária
Retorno    : Retornar uma instâcia da execução de uma query
Autor      : Mauricio Frison
Data       : Setembro/2022
*/
static function getSelectPlan(cAliasTemp, aCpos)
Local	oQrySWV := FWPreparedStatement():New(getQryPlan(aCpos))
	   oQrySWV:SetString(1,SW6->W6_HAWB)
	   cQuery := oQrySWV:GetFixQuery()
   	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasTemp, .T., .T. )
Return cAliasTemp
	

/*
Funcao     : getQryPlan
Objetivo   : Retornar select para geração da planilha eletrônica
Parametros : -
Retorno    : Retorna a string com o selecta a ser gerado
Autor      : Mauricio Frison
Data       : Setembro/2022
*/
static function getQryPlan(aCpos)
   local cQuery     := ""
   local nCpos      := 0
   local cCampos    := ""

   default aCpos      := setCposPlan()

   for nCpos := 1 to len(aCpos)
      cCampos += aCpos[nCpos][CAMPO] + ", "
   next
   cCampos := SubStr( alltrim(cCampos) , 1, len(alltrim(cCampos)) - 1)

   cQuery := " SELECT "
   cQuery += cCampos
   cQuery += " FROM " + RetSqlName("SWV") + " SWV LEFT JOIN " + RetSqlName("SW8") + " SW8 ON (W8_FILIAL = '" + xFilial("SW8") + "' AND WV_HAWB = W8_HAWB AND WV_INVOICE = W8_INVOICE AND WV_PO_NUM = W8_PO_NUM AND WV_POSICAO = W8_POSICAO AND W8_PGI_NUM = WV_PGI_NUM AND SW8.D_E_L_E_T_ = ' ') "
   cQuery += "                                   LEFT JOIN " + RetSqlName("SW9") + " SW9 ON (W9_FILIAL = '" + xFilial("SW9") + "' AND WV_INVOICE = W9_INVOICE AND WV_FORN = W9_FORN AND WV_FORLOJ = W9_FORLOJ AND WV_HAWB = W9_HAWB AND SW9.D_E_L_E_T_ = ' ') "
   cQuery += "  	                               LEFT JOIN " + RetSqlName("EIJ") + " EIJ ON (EIJ_FILIAL = '" + xFilial("EIJ") + "' AND WV_HAWB = EIJ_HAWB AND WV_ID = EIJ_IDWV AND EIJ.D_E_L_E_T_ = ' ') "
   cQuery += "                                   LEFT JOIN " + RetSqlName("SWZ") + " SWZ ON (WZ_FILIAL = '" + xFilial("SWZ") + "' AND EIJ_OPERAC = WZ_OPERACA AND SWZ.D_E_L_E_T_ = ' ') "
   cQuery += "                                   LEFT JOIN " + RetSqlName("SWX") + " SWX ON (WX_FILIAL = '" + xFilial("SWX") + "' AND WZ_CFO = WX_COD AND SWX.D_E_L_E_T_ = ' ') "
   cQuery += "                                   LEFT JOIN " + RetSqlName("SW6") + " SW6 ON (W6_FILIAL = '" + xFilial("SW6") + "' AND WV_HAWB = W6_HAWB AND SW6.D_E_L_E_T_ = ' ') "
   cQuery += "                                   LEFT JOIN " + RetSqlName("SB1") + " SB1 ON (B1_FILIAL = '" + xFilial("SB1") + "' AND WV_COD_I = B1_COD AND SB1.D_E_L_E_T_ = ' ') "      
   cQuery += " WHERE SWV.WV_FILIAL = '" + xFilial("SWV") + "' AND SWV.D_E_L_E_T_ = ' ' AND SWV.WV_HAWB= ? "

return cQuery

/*
Funcao     : getDesPrd
Objetivo   : Retornar o campo da descrição do produto conforme parâmetro MV_AVG0194
Parametros : 
Retorno    : Retorna o campo ser utilizado para pegar o título do campo da descrição do produto conforme parâmetro MV_AVG0194
Autor      : Mauricio Frison
Data       : Setembro/2022
*/
static function getDesPrd()
Local cCampo := ''
Local cMV_DESC := If(ValType(EasyGParam("MV_AVG0194",,"0")) == "N", AllTrim(Str(EasyGParam("MV_AVG0194",,"0"))), EasyGParam("MV_AVG0194",,"0"))  //RMD - 11/12/2012 
do case 
   case cMV_DESC == "1"
        cCampo := "B1_DESC_I"
   case cMV_DESC == "2"
        cCampo := "B1_DESC_GI"
   case cMV_DESC == "3"
        cCampo := "B1_DESC_P"
   otherwise 
        cCampo := "B1_DESC"
endcase
return cCampo
