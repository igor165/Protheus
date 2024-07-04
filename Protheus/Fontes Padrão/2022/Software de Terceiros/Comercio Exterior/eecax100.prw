#INCLUDE "eecax100.ch"
#include "DbTree.ch"
#include "EEC.cH"

/*
Programa        : EECAX100.PRW
Objetivo        : Funções diversas utilizadas nas rotinas de processo de exportação e processos de embarque. 
                  As funções constantes neste fonte poderão ser utilizadas em ambas as fazes, sem nenhum 
                  tratamento adicional.               
Autor           : Jeferson Barros Jr.
Data/Hora       : 05/02/2005 10:16.
Obs.            : 
*/


#COMMAND E_RESET_AREA =>  If(Select("Wk_Field") > 0, Wk_Field->(E_EraseArq(cArqField,cArqField2)),Nil) ;;
                          If(Select("Wk_Geral") > 0, Wk_Geral->(E_EraseArq(cArqGeral,cArqGeral2,cArqGeral3)),Nil) ;;
                          If(Select("Wk_Atu")   > 0, Wk_Atu->(E_EraseArq(cArqAtu,cArqAtu2)),Nil)

#Define REG_CAPA    "H"
#Define REG_ITEM    "D"
#Define REG_COMP    "C"
#Define VLD_MAIN    "MAIN"
#Define VLD_DET     "DET"
#Define VLD_ATU     "ATU"
#Define VLD_EXIT    "EXIT"
#Define BT_CAPA     "CAP"
#Define BT_ITEM     "IT"
#Define BT_ITEMCOMP "ITCOM"
#Define BT_DET      "DET"
#Define BT_ATU      "ATU"
#Define BT_COMP     "COM"

/*
Funcao      : AxFieldUpdate()
Parametros  : cFase - Fase de Pedido (Default).
                      Fase de Embarque.
Retorno     : .t./.f.
Objetivos   : Controles para atualização das diversas filiais de Off-shore por campo. O usuário
              poderá escolher quais campos deverão ser atualizados. Os tratamentos serão realizados
              para os campos de capa, itens e tabelas de complementos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/02/2005 - 14:37.
Revisao     :
Obs.        :
*/
*---------------------------*
Function AxFieldUpdate(cFase)
*---------------------------*
Local lRet:= .t., aOrd:=SaveOrd({"EE7","EE8","EEC","EE9","EEB","EEJ","EET","EEN"})

Private lChangeCapa := .f., lChangeItem := .f., lChangeComplemento := .f.,;
        lLoadMarked := EasyGParam("MV_AVG0080",,.f.)

Private cMarca := GetMark(),;
        cArqField, cArqField2, cArqGeral, cArqGeral2, cArqGeral3,;
        cArqAtu  , cArqAtu2

Private aDespInt := {}, aCmpDespInt := {}, aCapaLocalidades:={}, aItemLocalidades:={}

Private aCamposBrasil := {"EE7_COND2" ,"EEC_COND2" ,;
                          "EE7_DIAS2" ,"EEC_DIAS2" ,;
                          "EE7_INCO2" ,"EEC_INCO2" ,;
                          "EE7_CONDPA","EEC_CONDPA",;
                          "EE7_DIASPA","EEC_DIASPA",;
                          "EE7_IMPORT","EEC_IMPORT",;
                          "EE7_IMLOJA","EEC_IMLOJA",;
                          "EE7_IMPODE","EEC_IMPODE",;
                          "EE7_ENDIMP","EEC_ENDIMP",;
                          "EE7_END2IM","EEC_END2IM",;
                          "EE7_INCOTE","EEC_INCOTE",;
                          "EE7_FORN"  ,"EEC_FORN"  ,;
                          "EE7_FOLOJA","EEC_FOLOJA",;
                          "EE7_CLIENT","EEC_CLIENT",;
                          "EE7_CLLOJA","EEC_CLLOJA",;
                          "EE8_PRECO" ,"EE8_PRECOI",;
                          "EE8_RV"}


Default cFase := OC_PE // Fase pedido.

Begin Sequence

   //If Type("lEE7Auto") == "L" .And. lEE7Auto //WHRS TE-7768 540063/ MTRADE-1723 - Exibição de MsgInfo na execução da rotina automática
   If Type("lEE7AUTO") <> "L" .Or. !lEE7Auto //RMD - 06/02/17 - A condição estava invertida, o correto é não mostrar a tela quando for execauto   
     // Chamar função para verificar e levantar em quais tabelas houveram alterações.
        MsAguarde({|| MsProcTxt(STR0001), AxVerifyChanges(cFase)}, STR0002) //"Analisando alterações..."###"Aguarde"
   ELSE
	   AxVerifyChanges(cFase)
   endIf

   Do Case
      Case (lChangeCapa .Or. lChangeComplemento) .And. !lChangeItem
           If Len(aCapaLocalidades) = 0
              lRet:=.t.
              Break
           EndIf

      Case lChangeItem .And. !lChangeCapa .And. !lChangeComplemento
           If Len(aItemLocalidades) = 0
              lRet:=.t.
              Break
           EndIf
   EndCase

   /* Caso algum campo tenha sofrido alterações, o sistema exibe tela para que o usuário
      usuário configure o processo de atualização nas demais filiais. */

   If lChangeCapa .Or. lChangeItem .Or. lChangeComplemento
      If !AxTela(cFase)
         lRet := .t.
         Break
      EndIf
   EndIf

End Sequence

//** Apaga os arquivos temporários
E_RESET_AREA

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : AxVerifyChanges()
Parametros  : cFase - Fase de Pedido.
                      Fase de Embarque.
Retorno     : .t./.f.
Objetivos   : Verificar e levantar todas as alterações realizadas nos campos da capa, itens e 
              tabelas de complemento.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/02/2005 - 10:43.
Revisao     :
Obs.        :
*/
*------------------------------------*
Static Function AxVerifyChanges(cFase)
*------------------------------------*
Local aStruct:={}, aAux:={}
Local lRet:=.t.
Local j:=0, nRec := 0

Private cId
Private aCampos := {}
Private aVerifyCapa := {} // Capa.
        aVerifyItem := {} // Item.
        aVerifyEXL  := {} // Dados complementares de embarque.
        aVerifyEEB  := {} // Empresas.
        aVerifyEET  := {} // Despesas.
        aVerifyEEN  := {} // Notifys.
        aVerifyEEJ  := {} // Bancos.
        aTabelas    := {} // Tabelas.

Begin Sequence


   /* a) Neste ponto o sistema irá carregar todos os locais onde o usuário poderá
         replicar as alterações. */

   // ** Verifica os locais para atualização da capa do processo.
   AxLocalidades(cFase,"C",If(cFase==OC_PE,M->EE7_PEDIDO,M->EEC_PREEMB))

   If cFase == OC_PE
      /* Verifica os locais para atualização dos dados dos itens do
         pedido. */

      WorkIt->(DbGoTop())
      Do While WorkIt->(!Eof())
         AxLocalidades(cFase,"D",WorkIt->EE8_PEDIDO+WorkIt->EE8_SEQUEN)
         WorkIt->(DbSkip())
      EndDo
   Else
      /* Verifica os locais para atualização dos dados dos itens do
         processo de embarque. */
      nRec:=EEC->(Recno())

      WorkIp->(DbGoTop())
      Do While WorkIp->(!Eof())                
         If !lIntermed
            AxLocalidades(cFase,"D",WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN+WorkIp->EE9_PREEMB)
         Else

            /* Para filial exterior, posiciona na capa para considerar os vários níveis de 
               off-shore. */

            If EEC->EEC_FILIAL == cFilEx
               nRecAux:=EEC->(Recno())
               
               EEC->(DbSetOrder(1))
               If EEC->(DbSeek(cFilEx+WorkIp->EE9_PREEMB))
                  EEC->(DbSetOrder(14))
                  If EEC->(DbSeek(cFilEx+EEC->EEC_PREEMB))
                     AxLocalidades(OC_EM,"D",WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN+EEC->EEC_PREEMB)
                  EndIf
               EndIf
               EEC->(DbGoTo(nRecAux))
            Else
               /* Filial Brasil:
                  - Para esta filial o sistema irá considerar o processo na filial de off-shore,
                    além dos vários níveis de off-shore. */

               AxLocalidades(cFase,"D",WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN+WorkIp->EE9_PREEMB)
            EndIf
         EndIf
         
         WorkIp->(DbSkip())
      EndDo

      EEC->(DbGoTo(nRec))
   EndIf

   /* Caso não existir processos para replicar as informações, o sistema
      não apresenta a tela de replicação de informações. */

   If Len(aCapaLocalidades) = 0 .And. Len(aItemLocalidades) = 0
      lRet:=.f.
      Break
   EndIf

   If Select("Wk_Main") == 0

      // Cria work principal de controle dos campos alterados.
      //aAdd(aStruct,{"WK_FILIAL","C",002,0})
      aAdd(aStruct,{"WK_FILIAL","C",FwSizeFilial(),0}) //RMD - 07/02/17 - Utilizar o tamanho correto do campo Filial
      aAdd(aStruct,{"WK_PROC"  ,"C",AvSx3("EE7_PEDIDO",AV_TAMANHO),0})
      aAdd(aStruct,{"WK_FASE"  ,"C",001,0})
      aAdd(aStruct,{"WK_SEQUEN","C",AvSx3("EE8_SEQUEN",AV_TAMANHO),0})
      aAdd(aStruct,{"WK_CODCOM","C",020,0})
      aAdd(aStruct,{"WK_CAMPO" ,"C",010,0})
      aAdd(aStruct,{"WK_MARCA" ,"C",002,0})
      aAdd(aStruct,{"WK_OBS"   ,"C",100,0})
      aAdd(aStruct,{"WK_RECNO" ,"N",007,0})
      aAdd(aStruct,{"WK_RECNOD","N",007,0})

      /* Índice utilizado para controle de alterações nos campos da capa  e controles específicos de 
         alteração de campos nas telas de detalhe dos itens e complementos. */

      cArqMain := E_CriaTrab(,aStruct,"Wk_Main")
      IndRegua("Wk_Main",cArqMain+TEOrdBagExt(),"WK_CAMPO+WK_SEQUEN","AllwayTrue()",;
                                              "AllwaysTrue()",STR0003) //"Processando Arquivo Temporario ..."

      // Índice utilizado para controle de alteraçãos por item do processo.
      cArqMain2 := CriaTrab(,.f.)
      IndRegua("Wk_Main",cArqMain2+TEOrdBagExt(),"WK_FILIAL+WK_PROC+WK_FASE+WK_CAMPO+WK_SEQUEN","AllwayTrue()","AllwaysTrue()",;
                                                                                      STR0003) //"Processando Arquivo Temporario ..."

      // ** Indices (3 e 4) utilizados para controle de alteração de campos de complementos e inclusão/exclusão de complementos..
      cArqMain3 := CriaTrab(,.f.)
      IndRegua("Wk_Main",cArqMain3+TEOrdBagExt(),"WK_CODCOM","AllwayTrue()","AllwaysTrue()",STR0003) //"Processando Arquivo Temporario ..."

      cArqMain4 := CriaTrab(,.f.)
      IndRegua("Wk_Main",cArqMain4+TEOrdBagExt(),"WK_FILIAL+WK_PROC+WK_FASE+WK_CODCOM+WK_CAMPO","AllwayTrue()","AllwaysTrue()",STR0003) //"Processando Arquivo Temporario ..."

      Set Index to (cArqMain+TEOrdBagExt()), (cArqMain2+TEOrdBagExt()), (cArqMain3+TEOrdBagExt()), (cArqMain4+TEOrdBagExt())
   Else
      Wk_Main->(avzap())
   Endif

   // Cria work de campos.
   aStruct := {}
   aAdd(aStruct,{"WK_MARCA","C",02,0})
   aAdd(aStruct,{"WK_FIELD","C",15,0}) // Titulo.
   aAdd(aStruct,{"WK_FOLDER","C",015,0})   
   aAdd(aStruct,{"WK_CMPID","C",10,0}) // Nome do campo.
   aAdd(aStruct,{"WK_VLOLD","C",60,0})
   aAdd(aStruct,{"WK_VLATU","C",60,0})
   aAdd(aStruct,{"WK_TIPO ","C",01,0})
   aAdd(aStruct,{"WK_ORDEM","C",02,0})
   aAdd(aStruct,{"WK_RECNO","N",07,0})

   If Select("Wk_Field") == 0
      cArqField:= E_CriaTrab(,aStruct,"Wk_Field")
      IndRegua("Wk_Field",cArqField+TEOrdBagExt(),"WK_ORDEM+WK_FIELD+WK_TIPO","AllwayTrue()","AllwaysTrue()",;
                                                                            STR0003) //"Processando Arquivo Temporario ..."
      cArqField2:= CriaTrab(,.f.)
      IndRegua("Wk_Field",cArqField2+TEOrdBagExt(),"WK_FIELD","AllwayTrue()","AllwaysTrue()",;
                                                            STR0003) //"Processando Arquivo Temporario ..."
      Set Index to (cArqField+TEOrdBagExt()), (cArqField2+TEOrdBagExt())
   Endif

   // Cria work geral.
   aCampos := {}
   aStruct := {}
   aAdd(aStruct,{"WK_MARCA" ,"C",002,0})
   aAdd(aStruct,{"WK_REGIS" ,"C",100,0})
   aAdd(aStruct,{"WK_CAMPOS","C",100,0})
   aAdd(aStruct,{"WK_TABELA","C",003,0})
   aAdd(aStruct,{"WK_SEQUEN","C",AvSx3("EE8_SEQUEN",AV_TAMANHO),0})
   aAdd(aStruct,{"WK_CODPRO","C",AvSx3("EE8_COD_I" ,AV_TAMANHO),0})
   aAdd(aStruct,{"WK_CODCOM","C",020,0})
   aAdd(aStruct,{"WK_DESPID","C",002,0}) // Identificador utilizado para as despesas internacionais.
   aAdd(aStruct,{"WK_RECNO" ,"N",007,0})

   If Select("Wk_Geral") == 0
      cArqGeral:= E_CriaTrab(,aStruct,"Wk_Geral")
      IndRegua("Wk_Geral",cArqGeral+TEOrdBagExt(),"WK_REGIS+WK_TABELA","AllwayTrue()","AllwaysTrue()",;
                                                                     STR0003) //"Processando Arquivo Temporario ..."
      cArqGeral2:= CriaTrab(,.f.)
      IndRegua("Wk_Geral",cArqGeral2+TEOrdBagExt(),"WK_SEQUEN","AllwayTrue()","AllwaysTrue()",;
                                                 STR0003) //"Processando Arquivo Temporario ..."
      cArqGeral3:= CriaTrab(,.f.)
      IndRegua("Wk_Geral",cArqGeral3+TEOrdBagExt(),"WK_CODPRO","AllwayTrue()","AllwaysTrue()",;
                                                 STR0003) //"Processando Arquivo Temporario ..."

      Set Index to (cArqGeral+TEOrdBagExt()),(cArqGeral2+TEOrdBagExt()),(cArqGeral3+TEOrdBagExt())
   Endif

   // Cria work de atualizações.
   aCampos := {}
   aStruct := {}
   aAdd(aStruct,{"WK_MARCA" ,"C",002,0})
   aAdd(aStruct,{"WK_PROC"  ,"C",AvSx3("EE7_PEDIDO",AV_TAMANHO),0})
   aAdd(aStruct,{"WK_FASE"  ,"C",001,0})
   aAdd(aStruct,{"WK_FILIAL","C",015,0})
   //aAdd(aStruct,{"WK_CODFIL","C",002,0})
   aAdd(aStruct,{"WK_CODFIL","C",FwSizeFilial(),0}) //RMD - 07/02/17 - Utilizar o tamanho correto do campo Filial
   aAdd(aStruct,{"WK_OBS"   ,"C",100,0})
   aAdd(aStruct,{"WK_RECNO" ,"N",007,0})

   If Select("Wk_Atu") == 0
      cArqAtu:= E_CriaTrab(,aStruct,"Wk_Atu")
      IndRegua("Wk_Atu",cArqAtu+TEOrdBagExt(),"WK_CODFIL+WK_PROC+WK_FASE","AllwayTrue()","AllwaysTrue()",;
                                                                STR0003) //"Processando Arquivo Temporario ..."
      cArqAtu2:= CriaTrab(,.f.)
      IndRegua("Wk_Atu",cArqAtu2+TEOrdBagExt(),"WK_PROC","AllwayTrue()","AllwaysTrue()",;
                                                       STR0003) //"Processando Arquivo Temporario ..."

      Set Index to (cArqAtu+TEOrdBagExt()), (cArqAtu2+TEOrdBagExt())
   Endif

   /* Realiza levantamento dos campos utilizados na rotina de despesas
      internacionais. Todos os campos de cada despesa serão carregados.
      Os arrays abaixo, serão utilizados em diversas funções para realização
      do controle de replicação de dados para despesas internacionais. */

   If EECFlags("FRESEGCOM")
      aDespInt := X3DIReturn()
      For j:=1 To Len(aDespInt)
         cId := aDespInt[j][1]
         aAdd(aCmpDespInt,"EXL_MD" +cId)  // Moeda.
         aAdd(aCmpDespInt,"EXL_VD" +cId)  // Valor na moeda da despesa.
         aAdd(aCmpDespInt,aDespInt[j][2]) // Valor da Despesa na moeda do processo.
         aAdd(aCmpDespInt,"EXL_PA" +cId)  // Paridade.
         aAdd(aCmpDespInt,"EXL_EM" +cId)  // Empresa.
         aAdd(aCmpDespInt,"EXL_DE" +cId)  // Nome da Empresa.
         aAdd(aCmpDespInt,"EXL_FO" +cId)  // Fornecedor.
         aAdd(aCmpDespInt,"EXL_LF" +cId)  // Loja do Fornecedor.
         aAdd(aCmpDespInt,"EXL_CP" +cId)  // Condição de Pagamento.
         aAdd(aCmpDespInt,"EXL_DP" +cId)  // Dias de Pagamento.
         aAdd(aCmpDespInt,"EXL_DC" +cId)  // Descrição da Condição de Pagamento.
         aAdd(aCmpDespInt,"EXL_DT" +cId)  // Data Base.
      Next
   EndIf

   /* Carrega os arrays com os campos que deverão ser
      verificados após as alterações. */

   // ** Campos que não serão validados para as tabelas de capa do pedido ou embarque.
   If cFase == OC_PE

      /* Capa - Pedido: Levantamento dos campos que deverão ser tratados e os campos que não serão
                        atualizados pela função de replicação de dados. */

      /* aAux:={"EE7_STATUS","EE7_STTDES","EE7_INTERM","EE7_CLIENT",;
                "EE7_CLLOJA","EE7_EXPORT","EE7_EXLOJA"} */

      aAux:={"EE7_STATUS","EE7_STTDES","EE7_INTERM","EE7_EXPORT","EE7_EXLOJA"}
      aVerifyCapa := AxLoadArray("EE7",AHdEnchoice ,aAux)

      /* Item - Pedido: Levantamento dos campos que deverão ser tratados e os campos que não serão
                        atualizados pela função de replicação de dados. */

      aAux:={"EE8_SLDINI","EE8_QTDEM1"} //aAux:={"EE8_SLDINI","EE8_QTDEM1","EE8_PRENEG"}
      aVerifyItem := AxLoadArray("EE8",aItemEnchoice,aAux)
   Else

      /* Capa - Embarque: Levantamento dos campos que deverão ser tratados e os campos que não serão 
                          atualizados pela função de replicação de dados. */

      aAux:={"EEC_STTDES", "EEC_INTERM",; //"EEC_CLIENT","EEC_CLLOJA",;
             "EEC_EXPORT", "EEC_EXLOJA", "EEC_URFDSP",;
             "EEC_URFENT", "EEC_ENQCOD", "EEC_ENQCOX", "EEC_ENQCO1",;
             "EEC_ENQCO2", "EEC_ENQCO3", "EEC_ENQCO4", "EEC_ENQCO5",;
             "EEC_REGVEN", "EEC_OPCRED", "EEC_LIMOPE", "EEC_GEDERE",;
             "EEC_GDRPRO", "EEC_DIRIVN", "EEC_SECEX" , "EEC_MRGNSC",;
             "EEC_VLMNSC", "EEC_ANTECI", "EEC_VISTA" , "EEC_NPARC" ,;
             "EEC_PARCEL", "EEC_VLCONS", "EEC_COBCAM", "EEC_FINCIA",;
             "EEC_LIBSIS", "EEC_LC_NUM"}

	  aAdd(aHDEnchoice, "EEC_STATUS")	
      aVerifyCapa := AxLoadArray("EEC",AHdEnchoice ,aAux)

      /* Item - Embarque: Levantamento dos campos que deverão ser tratados e os campos que não serão
                          atualizados pela função de replicação de dados. */

      aAux:={"EE9_PRECO" , "EE9_SLDINI", "EE9_QTDEM1", "EE9_RE"  , "EE9_DTRE",;
             "EE9_ATOCON", "EE9_RV"    , "EE9_FINALI", "EE9_NRSD", "EE9_RC"  ,;
             "EE9_DTAVRB"}

      If EECFlags("COMMODITY") .Or. lIntermed
         AAdd(aAux, "EE9_PRECOI")
      EndIf

      aVerifyItem := AxLoadArray("EE9",aItemEnchoice,aAux)
   EndIf

   aAux:={}
   aVerifyEEB  := AxLoadArray("EEB", aAgEnchoice, aAux)

   aAux:={}
   aVerifyEEJ  := AxLoadArray("EEJ", aInEnchoice, aAux)

   aAux:={}
   aVerifyEEN  := AxLoadArray("EEN", aNoEnchoice, aAux)

   aAux:={}
   aVerifyEET  := AxLoadArray("EET", {}, aAux)

   /* Verifica quais campos foram alterados e realiza a gravação da 
      work principal */

   aTabelas := If(cFase==OC_PE, {"EE7","EE8","EEB","EET","EEN","EEJ"},;
                                {"EEC","EE9","EEB","EET","EEN","EEJ"})

   // ** Tratamentos específicos para a tabela de EXL (Complementos de Embarque).
   If EECFlags("COMPLE_EMB") .Or. EECFlags("FRESEGCOM")
      aAux := {}
      aVerifyEXL  := AxLoadArray("EXL", {}, aAux)

      If cFase == OC_EM
         aAdd(aTabelas,"EXL")
      EndIf
   EndIf

   If EasyEntryPoint("EECAX100")
      ExecBlock("EECAX100",.f.,.f.,{"ANTES_AXCHANGES"})
   EndIf
   
   For j:=1 To Len(aTabelas)
      If aTabelas[j] $ "EE8/EE9"
         If Len(aItemLocalidades) >  0
            AxChanges(aTabelas[j],cFase)
         EndIf      
      Else
         If Len(aCapaLocalidades) >  0
            AxChanges(aTabelas[j],cFase)
         EndIf      
      EndIf
   Next

End Sequence

Return lRet

/*                                                           
Funcao      : AxLocalidades()
Parametros  : cFase - OC_PE - Pedido.
                      OC_EM - Embarque. 
              cTipo - "C" - Para os campos da capa e dados das tabelas de complementos;
                      "D" - Para os itens.        

Retorno     : .t.
Objetivos   : Analisar e levantar todos os locais onde o usuário poderá 
              replicar as alterações realizadas no processo atual.
Autor       : Jeferson Barros Jr.
Data/Hora   : 24/02/2005 - 16:31.
Revisao     :
Obs.        : Esta função trabalha recursivamente para tratar os casos
              de processos com off-shore em castata.
*/
*---------------------------------------------*
Static Function AxLocalidades(cFase,cTipo,cKey)
*---------------------------------------------*
Local lRet:= .t., aOrd:= SaveOrd({"EE7","EE8","EE9","EEC"})
Local cOldProc
Local nRec:=0

Begin Sequence

   /* Esta função trabalha recursivamente para tratar os casos
      de processos com off-shore em castata. */

   // ** Trata os parâmetros recebidos.
   cFase := Upper(AllTrim(cFase))
   cTipo := Upper(AllTrim(cTipo))

   Do Case
      Case cFase == OC_PE // Pedido de Exportação.

           If cTipo == "C" // Campo capa/complemento.
 
              /* Caso o ambiente possua a rotina de Off-shore habilitada, o  sistema
                 verifica se o processo existe na filial de off-shore, de acordo com
                 a flag 'Intermediação'. */

              If (lIntermed .And. AvGetM0Fil() == cFilBr .And. M->EE7_INTERM $ cSim)
                 EE7->(DbSetOrder(1))
                 If EE7->(DbSeek(cFilEx+cKey))
                    aAdd(aCapaLocalidades,{cFilEx,;
                                           EE7->EE7_PEDIDO,;
                                           OC_PE,;
                                           STR0004,; //"Pedido Off-Shore"
                                           EE7->(RecNo())})
                 EndIf
              EndIf

              EEC->(DbSetOrder(14))
              If EEC->(DbSeek(xFilial("EEC")+M->EE7_PEDIDO))
                 Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL == xFilial("EEC") .And.;
                                              EEC->EEC_PEDREF == M->EE7_PEDIDO

                    If !Empty(EEC->EEC_NIOFFS)
                       EEC->(DbSkip())
                       Loop
                    EndIf

                    // ** Testa condições gerais para disponibilizar o embarque para atualização.
                    If AxCanUpdate(xFilial("EEC"),EEC->EEC_PREEMB)
                       aAdd(aCapaLocalidades,{ xFilial("EEC") ,;
                                               EEC->EEC_PREEMB,;
                                               OC_EM,;
                                               If(!Empty(EEC->EEC_DTEMBA),STR0005,"N/C"),; //"Embarcado"
                                               EEC->(RecNo())})
                    EndIf

                    nRec:= EEC->(RecNo())
                    Do Case
                       Case (lIntermed .And. AvGetM0Fil() == cFilBr .And. EEC->EEC_INTERM $ cSim)
                            EEC->(DbSetOrder(1))
                            If EEC->(DbSeek(cFilEx+EEC->EEC_PREEMB))

                               // ** Testa condições gerais para disponibilizar o embarque para atualização.
                               If AxCanUpdate(cFilEx,EEC->EEC_PREEMB)                                                   
                                  aAdd(aCapaLocalidades,{ cFilEx,;
                                                          EEC->EEC_PREEMB,;
                                                          OC_EM,;
                                                          If(!Empty(EEC->EEC_DTEMBA),STR0005,"N/C"),; //"Embarcado"
                                                          EEC->(RecNo())})
                               EndIf

                               EEC->(DbSetOrder(14))
                               AxLocalidades(OC_EM,"C",EEC->EEC_PREEMB)
                            EndIf

                       Case (lIntermed .And. AvGetM0Fil() == cFilEx)
                            AxLocalidades(OC_EM,"C",EEC->EEC_PREEMB)
                    EndCase

                    EEC->(DbGoTo(nRec))
                    EEC->(DbSkip())
                 EndDo
              EndIf

           ElseIf cTipo == "D"

              /* Caso o yambiente possua a rotina de Off-shore habilitada, o  sistema
                 verifica se o processo existe na filial de off-shore, de acordo com
                 a flag 'Intermediação'. */

              If (lIntermed .And. AvGetM0Fil() == cFilBr .And. M->EE7_INTERM $ cSim)
                 EE8->(DbSetOrder(1))
                 If EE8->(DbSeek(cFilEx+cKey))

                    aAdd(aItemLocalidades,{ EE8->EE8_SEQUEN,;
                                            cFilEx,;
                                            EE8->EE8_PEDIDO,;
                                            OC_PE,;
                                            "Pedido Off-Shore",;
                                            0,; // SeqEmb.
                                            EE8->(RecNo())})
                 EndIf
              EndIf

              If !lIntermed .Or. AvGetM0Fil() == cFilBr
                 cOldProc := ""
                 EE9->(DbSetOrder(1))
                 If EE9->(DbSeek(xFilial("EE9")+cKey))                              
                    Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And.;
                                                 EE9->EE9_PEDIDO+EE9->EE9_SEQUEN == cKey

                       If aScan(aItemLocalidades,{|x| x[1] == EE9->EE9_SEQUEN .And.;
                                                      x[2] == xFilial("EE9")  .And.;
                                                      x[3] == EE9->EE9_PREEMB .And.;
                                                      x[4] == OC_EM}) = 0

                          // ** Testa condições gerais para disponibilizar o embarque para atualização.
                          If AxCanUpdate(xFilial("EE9"),EE9->EE9_PREEMB)

                             aAdd(aItemLocalidades,{ EE9->EE9_SEQUEN,;
                                                     xFilial("EE9") ,;
                                                     EE9->EE9_PREEMB,;
                                                     OC_EM,;
                                                     If(!Empty(Posicione("EEC",1,xFilial("EEC")+EE9->EE9_PREEMB,"EEC_DTEMBA")),;
                                                        STR0005,"N/C"),; //"Embarcado"
                                                     EE9->EE9_SEQEMB,;
                                                     EE9->(RecNo())})
                          EndIf

                          If lIntermed
                             If cOldProc <> EE9->EE9_PREEMB
                                AxLocalidades(OC_EM,"D",EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+EE9->EE9_PREEMB)
                                cOldProc := EE9->EE9_PREEMB
                             EndIf
                          EndIf
                       EndIf

                       EE9->(DbSkip())
                    EndDo
                 EndIf
              Else
                 EE9->(DbSetOrder(1))
                 If EE9->(DbSeek(xFilial("EE9")+cKey))
                    Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And.;
                                                 EE9->EE9_PEDIDO+EE9->EE9_SEQUEN == cKey
                       AxLocalidades(OC_EM,"D",EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+EE9->EE9_PREEMB)
                       EE9->(DbSkip())
                    EndDo
                 EndIf
              EndIf
           EndIf

      Case cFase == OC_EM // Processo de Embarque.

           If !lIntermed
              Break
           EndIf

           If cTipo == "C" // Campo capa/complemento.

              If (lIntermed .And. EEC->EEC_FILIAL == cFilBr .And. EEC->EEC_INTERM $ cSim)
                 EEC->(DbSetOrder(1))
                 If EEC->(DbSeek(cFilEx+cKey))

                    // ** Testa condições gerais para disponibilizar o embarque para atualização.                    
                    If AxCanUpdate(cFilEx,EEC->EEC_PREEMB)
                       aAdd(aCapaLocalidades,{ cFilEx,;
                                               EEC->EEC_PREEMB,;
                                               OC_EM,;
                                               If(!Empty(EEC->EEC_DTEMBA),STR0005,"N/C"),; //"Embarcado"
                                               EEC->(RecNo())})
                    EndIf
                    AxLocalidades(OC_EM,"C",EEC->EEC_PREEMB)
                 EndIf
              Else
                 EEC->(DbSetOrder(14)) // Filial + Pedido de Referência.
                 If EEC->(DbSeek(cFilEx+cKey))
                    Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL == cFilEx .And.;
                                                 EEC->EEC_PEDREF == cKey
                       If !Empty(EEC->EEC_NIOFFS)
                          // ** Testa condições gerais para disponibilizar o embarque para atualização.
                          If AxCanUpdate(cFilEx,EEC->EEC_PREEMB)
                             aAdd(aCapaLocalidades,{ cFilEx,;
                                                     EEC->EEC_PREEMB,;
                                                     OC_EM,;
                                                     If(!Empty(EEC->EEC_DTEMBA),STR0005,"N/C"),; //"Embarcado"
                                                     EEC->(RecNo())})
                          EndIf
                          AxLocalidades(OC_EM,"C",EEC->EEC_PREEMB)
                          Exit
                       EndIf
                       EEC->(DbSkip())
                    EndDo
                 EndIf
              EndIf

           ElseIf cTipo == "D"

              EE9->(DbSetOrder(1))
              If EE9->(DbSeek(cFilEx+cKey))
                 Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == cFilEx  .And.;
                                              EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+EE9->EE9_PREEMB == cKey

                    If aScan(aItemLocalidades,{|x| x[1] == EE9->EE9_SEQUEN .And.;
                                                   x[2] == cFilEx          .And.;
                                                   x[3] == EE9->EE9_PREEMB .And.;
                                                   x[4] == OC_EM}) = 0

                       // ** Testa condições gerais para disponibilizar o embarque para atualização.
                       If AxCanUpdate(cFilEx,EE9->EE9_PREEMB)
                          aAdd(aItemLocalidades,{ EE9->EE9_SEQUEN,;
                                                  cFilEx,;
                                                  EE9->EE9_PREEMB,;
                                                  OC_EM,;
                                                  "N/C",;
                                                  EE9->EE9_SEQEMB,;
                                                  EE9->(RecNo())})
                       EndIf
                    EndIf

                    EEC->(DbSetOrder(1))
                    If EEC->(DbSeek(cFilEx+EE9->EE9_PREEMB))
                       EEC->(DbSetOrder(14))
                       If EEC->(DbSeek(cFilEx+EE9->EE9_PREEMB)) //EEC->EEC_PREEMB
                          Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL == cFilEx .And.;
                                                       EEC->EEC_PEDREF == EE9->EE9_PREEMB //EEC->EEC_PREEMB
                             If !Empty(EEC->EEC_NIOFFS)
                                AxLocalidades(OC_EM,"D",EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+EEC->EEC_PREEMB)
                                Exit
                             EndIf
                             EEC->(DbSkip())
                          EndDo
                       EndIf
                    EndIf

                    EE9->(DbSkip())
                 EndDo
              EndIf
           EndIf
   EndCase

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : AxChanges(cAlias,cFase).
Parametros  : cAlias - Alias da tabela a ser analisada.
              cFase  - Pedido/Embarque.
Retorno     : .t.
Objetivos   : Analisar e levantar as alterações realizadas nos campos da tabela
              recebida como parâmetro.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/02/2005 - 10:59.
Revisao     :
Obs.        :
*/
*-------------------------------------*
Static Function AxChanges(cAlias,cFase)
*-------------------------------------*
Local cProcesso, cWork, cMsg:="", cNmCampos:="", xConteudo, cNmRecno, cOldFilter, cAux, cCmpCod
Local cFilAtu:=""
Local lRet:=.t., lChange := .f., lChangeDespInt := .f., lAdd := .f., lAddDespInt := .f.
Local aAux :={}, aOrd:=SaveOrd({"EXL"}), aDel :={}, aChangeDespInt :={}, aInfoDest:={}
Local bResumo, bOldFilter
Local j:=0, nRec := 0, nPosDesp := 0, k:=0, nRecEEC:=0, nRecEXL:=0, nRec_Aux := 0

/* JPM - 02/06/05 - colocado como Private na função AxVerifyChanges para ser alterada pelo ponto de entrada
Local aCamposBrasil := {"EE7_COND2" ,"EEC_COND2" ,;
                        "EE7_DIAS2" ,"EEC_DIAS2" ,;
                        "EE7_INCO2" ,"EEC_INCO2" ,;
                        "EE7_CONDPA","EEC_CONDPA",;
                        "EE7_DIASPA","EEC_DIASPA",;
                        "EE7_IMPORT","EEC_IMPORT",;
                        "EE7_IMLOJA","EEC_IMLOJA",;
                        "EE7_IMPODE","EEC_IMPODE",;
                        "EE7_ENDIMP","EEC_ENDIMP",;
                        "EE7_END2IM","EEC_END2IM",;
                        "EE7_INCOTE","EEC_INCOTE",;
                        "EE7_FORN"  ,"EEC_FORN"  ,;
                        "EE7_FOLOJA","EEC_FOLOJA",;
                        "EE8_PRECO" ,"EE8_PRECOI",;
                        "EE8_RV"}
*/
Local nOrd, lUltimoNivel
Local cCposMesmaFilial
Local lRetPonto

Private aCmpMemo:={}

cCposMesmaFilial := "EE7_LC_NUM/EEC_LC_NUM/EE7_MPGEXP/EEC_MPGEXP/EE7_CONDPA/EEC_CONDPA/EE7_DIASPA/EEC_DIASPA/"
cCposMesmaFilial += "EE7_INCOTE/EEC_INCOTE"

Begin Sequence

   cProcesso := If(cFase==OC_PE , EE7->EE7_PEDIDO, EEC->EEC_PREEMB)
   cAlias    := AllTrim(Upper(cAlias))
   cFilAtu   := If(cFase==OC_PE, xFilial("EE7"), xFilial("EEC"))

   Private cAliasPto := cAlias
   
   Do Case
      Case cAlias $ "EE7/EEC"

           /* Controles diversos para verificação das alterações nas tabelas
              diferentes das EE7/EEC .*/

           aCmpMemo := {{cAlias+"_CODMEM",cAlias+"_OBS"   },;
                        {cAlias+"_CODMAR",cAlias+"_MARCAC"},;
                        {cAlias+"_CODOBP",cAlias+"_OBSPED"},;
                        {cAlias+"_DSCGEN",cAlias+"_GENERI"}}
           
           // ** JPM - 26/07/06
           If EasyEntryPoint("EECAX100")
              ExecBlock("EECAX100",.f.,.f.,{"AXCHANGES_VERIFY_CAPA"})
           EndIf
           
           SX3->(DbSetOrder(2))
           For j:=1 To Len(aVerifyCapa)

              SX3->(DbSeek(aVerifyCapa[j]))
              If SX3->X3_CONTEXT = "V" .And. SX3->X3_TIPO <> "M"
                 Loop
              EndIf

              nPos := aScan(aCmpMemo,{|x| x[2] == aVerifyCapa[j]}) // Tratamentos para os campos memo.
              If nPos > 0
                 xConteudo := AllTrim(Msmm((cAlias)->&(aCmpMemo[nPos][1]),AvSx3(aCmpMemo[nPos][2],AV_TAMANHO)))
              Else
                 xConteudo := (cAlias)->&(aVerifyCapa[j])
              EndIf

              If xConteudo <> M->&(aVerifyCapa[j]) // Verifica se houve alteração.

                 For k:=1 To Len(aCapaLocalidades)

                    // Valida se o destino é válido para o campo corrente.

                    /* Se o campo pertencer ao aCamposBrasil, o mesmo só poderá ser atualizado no 
                       embarque da mesma filial. */

                    If lIntermed .And. cFilAtu == cFilBr//RMD - 28/06/18 - Se não tiver intermediação não executa a validação da filial.
                       If aScan(aCamposBrasil,aVerifyCapa[j]) > 0
                          If aCapaLocalidades[k][1] <> cFilBr .Or.;
                             aCapaLocalidades[k][3] <> OC_EM
                             Loop
                          EndIf
                       EndIf
                    EndIf

                    /* Caso a tabela seja a EE7, para adicionar o registro na  wk_main, o  sitema verifica
                       inicialmente  se o  campo que sofreu a  alteração existe na tabela do EEC.  Caso  o
                       campo não exista, os embarque disponíveis para atualização para o processo corrente
                       não estarão disponíveis apenas para este campo. */

                    If aCapaLocalidades[k][3] == OC_EM
                       If cAlias == "EE7"
                          If !AxCheckCmp(aVerifyCapa[j])
                             Loop
                          EndIf
                       EndIf

                       If aVerifyCapa[j] <> "EEC_DTEMBA"
                          // ** Verifica se o embarque possui dt. de embarque.
                          nRec_Aux:= EEC->(RecNo())
                          EEC->(DbSetOrder(1))
                          If EEC->(DbSeek(aCapaLocalidades[k][1]+aCapaLocalidades[k][2]))
                             If !Empty(EEC->EEC_DTEMBA)
                                EEC->(DbGoTo(nRec_Aux))
                                Loop
                             EndIf
                          EndIf
                          EEC->(DbGoTo(nRec_Aux))
                       EndIf
                    EndIf

                    If aVerifyCapa[j]  $ cCposMesmaFilial //"EE7_LC_NUM/EEC_LC_NUM/EE7_MPGEXP/EEC_MPGEXP"
                       If aCapaLocalidades[k][1] <> xFilial(cAlias)
                          Loop
                       EndIf
                    EndIf

                    /* ** JPM - 25/04/05 - Tratamentos específicos para Carta de Crédito: */

                    If aVerifyCapa[j] == "EE7_LC_NUM"

                       If aCapaLocalidades[k][3] == OC_EM
                       
                          nRec_Aux := EEC->(RecNo())
                       
                          /* A carta de crédito só será replicada no Último embarque da sequência de Off-Shores. 
                             Se estiver ligada a rotina de Multi Off-Shore, deve-se fazer a verificação */
                          If xFilial("EE7") == cFilEx .And. lMultiOffShore
                             lUltimoNivel := .t.
                             EEC->(DbSetOrder(14))
                             If EEC->(DbSeek(aCapaLocalidades[k][1]+aCapaLocalidades[k][2]))
                                While EEC->(!EoF()) .And. EEC->(EEC_FILIAL+EEC_PEDREF) ==;
                                                          aCapaLocalidades[k][1]+aCapaLocalidades[k][2]
                                   If !Empty(EEC->EEC_NIOFFS)
                                      lUltimoNivel := .f.
                                      Exit
                                   Endif
                                   EEC->(DbSkip())
                                EndDo
                                If !lUltimoNivel
                                   EEC->(DbGoTo(nRec_Aux))
                                   Loop
                                EndIf
                             EndIf
                          EndIf
                          EEC->(DbGoTo(nRec_Aux))                        
                       EndIf   
                    Endif
                    
                    // ** Grava registro na work principal.
                    Wk_Main->(DbAppend())
                    Wk_Main->WK_FILIAL := aCapaLocalidades[k][1]
                    Wk_Main->WK_PROC   := aCapaLocalidades[k][2]
                    Wk_Main->WK_FASE   := aCapaLocalidades[k][3]
                    Wk_Main->WK_OBS    := aCapaLocalidades[k][4]
                    Wk_Main->WK_CAMPO  := aVerifyCapa[j]
                    Wk_Main->WK_MARCA  := If(lLoadMarked, cMarca,"")
                    Wk_Main->WK_RECNO  := (cAlias)->(RecNo())
                    Wk_Main->WK_RECNOD := aCapaLocalidades[k][5] // RECNO do processo de destino.

                    /* O sistema seta a flag 'lAdd' para controlar se o campo estará  disponível para
                       replicação de alterações. Caso o campo, não tenha destinos para replicação das
                       alterações, o campo não será apresentado na tela de replicações. */

                    lAdd := .t.
                 Next

                 If lAdd
                    // ** Grava registro na work de Campos.
                    Wk_Field->(DbAppend())
                    Wk_Field->WK_FIELD := AvSx3(aVerifyCapa[j],AV_TITULO)

                    If !Empty(AvSx3(aVerifyCapa[j],12)) // Verifica se o campo é do tipo combo.
                       Wk_Field->WK_VLOLD := If(!Empty(xConteudo),;
                                                 AllTrim(BscxBox(aVerifyCapa[j],xConteudo)),;
                                                 "(Vazio)")
                       Wk_Field->WK_VLATU := If(!Empty(M->&(aVerifyCapa[j])),;
                                                 AllTrim(BscxBox(aVerifyCapa[j],M->&(aVerifyCapa[j]))),;
                                                 "(Vazio)")
                    Else
                       Wk_Field->WK_VLOLD := If(!Empty(xConteudo),AllTrim(Transf(xConteudo,AvSx3(aVerifyCapa[j],AV_PICTURE))),;
                                                 "(Vazio)")
                       Wk_Field->WK_VLATU := If(!Empty(M->&(aVerifyCapa[j])),;
                                                 AllTrim(Transf(M->&(aVerifyCapa[j]),AvSx3(aVerifyCapa[j],AV_PICTURE))),;
                                                 "(Vazio)")
                    EndIf
                    Wk_Field->WK_FOLDER:= Ax100BuscaFolder(aVerifyCapa[j])
                    Wk_Field->WK_CMPID := aVerifyCapa[j]
                    Wk_Field->WK_TIPO  := REG_CAPA
                    Wk_Field->WK_ORDEM := AvSx3(aVerifyCapa[j],1) // Ordem.
                    Wk_Field->WK_MARCA := If(lLoadMarked, cMarca,"")
                    Wk_Field->WK_RECNO := (cAlias)->(RecNo())

                    lChangeCapa := .t. // Flag de controle para identificação de alterações na capa.
                    lAdd:=.f.
                 EndIf
              EndIf
           Next

      Case cAlias == "EXL"

           /* Para o EXL (Tabela de dados complementares do EEC) poderão existir tantos dados
              que são continuação da capa do embarque, como dados relativos a informações  de
              despesas  internacionais. Dessa  maneira, o sistema  irá  realizar  tratamentos
              específicos considerando cada situação. (Capa e Despesas Internacionais). */

           // ** Verifica se o embarque possui dados lançados no EXL.
           EXL->(DbSetOrder(1))
           If !EXL->(DbSeek(xFilial("EXL")+M->EEC_PREEMB))
              lRet:=.f.
              Break
           EndIf

           aCmpMemo := {}

           SX3->(DbSetOrder(2))
           For j:=1 To Len(aVerifyEXL)

              SX3->(DbSeek(aVerifyEXL[j]))
              If SX3->X3_CONTEXT = "V" .And. SX3->X3_TIPO <> "M"
                 Loop
              EndIf

              nPos := aScan(aCmpMemo,{|x| x[2] == aVerifyEXL[j]}) // Verifica se o campo é um memo.

              If nPos > 0
                 xConteudo := AllTrim(Msmm(EXL->&(aCmpMemo[nPos][1]),AvSx3(aCmpMemo[nPos][2],AV_TAMANHO)))
              Else
                 /* O tratamento abaixo garante o tratamento dos campos da tabela do EEC que são utilizados 
                    na rotina de despesas internacionais. Ex.: EEC_FRPREV, EEC_SEGPRE, etc... 
                    Indepentende se o campo faz parte da tabela EEC ou EXL, o tratamento abaixo irá 
                    funcionar automaticamente. */

                 cAux := Left(aVerifyEXL[j],3)
                 xConteudo := (cAux)->&(aVerifyEXL[j])
              EndIf

              If (xConteudo <> M->&(aVerifyEXL[j])) // Verifica se houve alguma alteração.

                 If EECFlags("FRESEGCOM")
                    /* Neste ponto o sistema verifica se o campo refere-se a alguma despesa
                       internacional */

                    nPosDesp := aScan(aCmpDespInt,aVerifyEXL[j])
                    If nPosDesp > 0
                       lChangeDespInt := .t.
                       Do Case
                          Case Left(aVerifyEXL[j],3) == "EXL"
                               cId := Right(AllTrim(aVerifyEXL[j]),2)

                          Case Left(aVerifyEXL[j],3) == "EEC"
                               nPosDesp := aScan(aDespInt,{|x| x[2] == aVerifyEXL[j]})
                               If nPosDesp > 0
                                  cId := aDespInt[nPosDesp][1]
                               EndIf
                       EndCase

                       /* No array aChangeDespInt, será gravado as despesas internacionais que sofreram
                          alterações. Existirá apenas uma ocorrência para cada despesa. */

                       nPosDesp := aScan(aChangeDespInt,{|x| x[1] == cId})
                       If nPosDesp == 0
                          aAdd(aChangeDespInt,{cId,; // Identificador da despesa.
                                               AllTrim(AvSx3(aVerifyEXL[j],AV_TITULO))+"/ "}) // Campos alterados para a despesa.
                       Else
                          aChangeDespInt[nPosDesp][2] +=  AllTrim(AvSx3(aVerifyEXL[j],AV_TITULO))+"/ "
                       EndIf

                       cNmCampos += AllTrim(AvSx3(aVerifyEXL[j],AV_TITULO))+"/ "
                    EndIf
                 EndIf

                 For k:=1 To Len(aCapaLocalidades)

                    If aCapaLocalidades[k][3] == OC_EM
                       // ** Verifica se o embarque possui dt. de embarque.
                       nRec_Aux:= EEC->(RecNo())
                       EEC->(DbSetOrder(1))
                       If EEC->(DbSeek(aCapaLocalidades[k][1]+aCapaLocalidades[k][2]))
                          If !Empty(EEC->EEC_DTEMBA)
                             EEC->(DbGoTo(nRec_Aux))
                             Loop
                          EndIf
                       EndIf
                       EEC->(DbGoTo(nRec_Aux))

                       /* Neste ponto o sistema deverá realizar alguns tratamentos para verificar se a desp.inter. poderá
                          ser replicada no processo de destino. */

                       nPosDesp := aScan(aCmpDespInt,aVerifyEXL[j])
                       If nPosDesp > 0
                          If cId == "FR" .Or. cId == "SE"
                             If !AxCheckIncoterm(cId,EEC->EEC_INCOTE,aCapaLocalidades[k][1],aCapaLocalidades[k][2])
                                Loop
                             EndIf
                          EndIf
                          lAddDespInt := .t.                          
                       EndIf
                    EndIf

                    // ** Grava registro na work principal.
                    Wk_Main->(DbAppend())
                    Wk_Main->WK_FILIAL := aCapaLocalidades[k][1]
                    Wk_Main->WK_PROC   := aCapaLocalidades[k][2]
                    Wk_Main->WK_FASE   := aCapaLocalidades[k][3]
                    Wk_Main->WK_OBS    := aCapaLocalidades[k][4]
                    Wk_Main->WK_CAMPO  := aVerifyEXL[j]
                    Wk_Main->WK_MARCA  := If(lLoadMarked, cMarca,"")

                    If !Empty(cId)
                       Wk_Main->WK_CODCOM := "EXL"+AllTrim(cId)
                    EndIf

                    Wk_Main->WK_RECNO  := EXL->(RecNo())

                    nRecExl := EXL->(RecNo())
                    nRecEEC := EEC->(RecNo())

                    EEC->(DbGoTo(aCapaLocalidades[k][5]))
                    If Left(aVerifyEXL[j],3) = "EEC"
                       Wk_Main->WK_RECNOD := EEC->(RecNo())
                    Else
                       If EXL->(DbSeek(EEC->EEC_FILIAL+EEC->EEC_PREEMB))
                          Wk_Main->WK_RECNOD := EXL->(RecNo())
                       EndIf
                    EndIf

                    EEC->(DbGoTo(nRecEEC))
                    EXL->(DbGoTo(nRecEXL))
                    lAdd := .t.
                 Next

                 If lAdd                 
                    // ** Grava registro na work de Campos.
                    Wk_Field->(DbAppend())
                    Wk_Field->WK_FIELD := AvSx3(aVerifyEXL[j],AV_TITULO)
                    Wk_Field->WK_CMPID := aVerifyEXL[j]

                    If !Empty(AvSx3(aVerifyEXL[j],12)) // Verifica se o campo é do tipo combo.
                       Wk_Field->WK_VLOLD := If(!Empty(xConteudo),;
                                                AllTrim(BscxBox(aVerifyEXL[j],xConteudo)),;
                                                "(Vazio)")
                       Wk_Field->WK_VLATU := If(!Empty(M->&(aVerifyEXL[j])),;
                                                 AllTrim(BscxBox(aVerifyEXL[j],M->&(aVerifyEXL[j]))),;
                                                 "(Vazio)")
                    Else
                        Wk_Field->WK_VLOLD := If(!Empty(xConteudo),AllTrim(Transf(xConteudo,AvSx3(aVerifyEXL[j],AV_PICTURE))),;
                                                "(Vazio)")
                        Wk_Field->WK_VLATU := If(!Empty(M->&(aVerifyEXL[j])),;
                                                AllTrim(Transf(M->&(aVerifyEXL[j]),AvSx3(aVerifyEXL[j],AV_PICTURE))),;
                                                "(Vazio)")
                    EndIf
                    Wk_Field->WK_FOLDER:= Ax100BuscaFolder(aVerifyEXL[j])                 
                    If lChangeDespInt
                       Wk_Field->WK_TIPO  := REG_COMP
                    Else
                       Wk_Field->WK_TIPO  := REG_CAPA
                       lChangeCapa        := .t.
                    EndIf

                    Wk_Field->WK_TIPO  := If(lChangeDespInt,REG_COMP,REG_CAPA)
                    Wk_Field->WK_ORDEM := AvSx3(aVerifyEXL[j],1) // Ordem.
                    Wk_Field->WK_MARCA := If(lLoadMarked, cMarca,"")
                    Wk_Field->WK_RECNO := EXL->(RecNo())
                   
                    lAdd:=.f.
                 EndIf
              EndIf
           Next

           /* Neste ponto o sistema irá analisar se alguma alteração foi realizada nas despesas
              internacionais, no array aChangeDespInt, estarão gravadas todas as informações de
              cada despesa. (Campos alterados p/ exibir no browse e Id das despesas alteradas). */

           If EECFlags("FRESEGCOM")
              If lChangeDespInt .And. Len(aChangeDespInt) > 0 .And. lAddDespInt

                 For j:= 1 To Len(aChangeDespInt)

                    nPosDesp := aScan(aDespInt,{|x| x[1] == aChangeDespInt[j][1]})

                    // ** Descrição da despesa que será exibida para o usuário no browse.
                    If nPosDesp > 0
                       cMsg := STR0006+AllTrim(AvSx3(aDespInt[nPosDesp][2], AV_TITULO)) //"Despesa Int.: "
                       cMsg := If(Len(cMsg)>100,MemoLine(cMsg,97,1)+"...",cMsg)
                    EndIf

                    // ** Resumo com os campos que sofreram alterações.
                    cNmCampos := AllTrim(aChangeDespInt[j][2])
                    If Right(cNmCampos,1) == "/"
                       cNmCampos := SubStr(cNmCampos,1,Len(cNmCampos)-1)
                       cNmCampos := If(Len(cNmCampos)>100,AllTrim(MemoLine(cNmCampos,97,1))+"...",;
                                                          AllTrim(cNmCampos))
                    EndIf

                    // ** Grava registro na work genérica.
                    Wk_Geral->(DbAppend())
                    Wk_Geral->WK_REGIS  := cMsg  
                    Wk_Geral->WK_TABELA := "EXL"
                    Wk_Geral->WK_RECNO  := EXL->(Recno())
                    Wk_Geral->WK_CAMPOS := cNmCampos
                    Wk_Geral->WK_MARCA  := If(lLoadMarked, cMarca,"")
                    Wk_Geral->WK_DESPID := aDespInt[nPosDesp][1]
                    Wk_Geral->WK_CODCOM := "EXL"+AllTrim(aDespInt[nPosDesp][1])
                 Next
                 lChangeComplemento := .t.
              EndIf
           EndIf

      OtherWise 
      
           /* O sistema irá realizar a verificação das alterações nas tabelas de 
              Complementos. */

           aCmpMemo:={}                                    	

           Do Case
              Case cAlias == "EE8"
                   cWork    := "WorkIt"
                   bResumo  := {|cAliasWk| "Seq.: "+;
                                           AllTrim((cAliasWk)->&(cAlias+"_SEQUEN"))+" / "+;
                                           AllTrim(Transf((cAliasWk)->&(cAlias+"_COD_I"),AvSx3(cAlias+"_COD_I",AV_PICTURE)))+" / "+;
                                           AllTrim(Memoline((cAliasWk)->&(cAlias+"_VM_DES"),AvSx3(cAlias+"_VM_DES",AV_TAMANHO),1))}
                   aAux     := aClone(aVerifyItem)
                   aCmpMemo := {{"EE8_DESC","EE8_VM_DES"}}
                   //** PLB 02/04/07
                   If EECFlags("AMOSTRA")
                      AAdd(aCmpMemo, { "EE8_QUADES", "EE8_DSCQUA" } )
                   EndIf
                   //**

                   // O sistema irá realizar automaticamente a exclusão de itens nas filiais de off-shore.
                   aDel     := {}
                   cNmRecno := "EE8_RECNO"

              Case cAlias == "EE9"
                   cWork    := "WorkIp"
                   bResumo  := {|cAliasWk| "Seq.: "+;
                                           AllTrim((cAliasWk)->&(cAlias+"_SEQEMB"))+" / "+;
                                           AllTrim(Transf((cAliasWk)->&(cAlias+"_COD_I"),AvSx3(cAlias+"_COD_I",AV_PICTURE)))+" / "+;
                                           AllTrim(Memoline((cAliasWk)->&(cAlias+"_VM_DES"),AvSx3(cAlias+"_VM_DES",AV_TAMANHO),1))}
                   aAux     := aClone(aVerifyItem)
                   aCmpMemo := {{"EE9_DESC","EE9_VM_DES"}}
                   //** PLB 02/04/07
                   If EECFlags("AMOSTRA")
                      AAdd(aCmpMemo, { "EE9_QUADES", "EE9_DSCQUA" } )
                   EndIf
                   //**
                   cNmRecno := "WP_RECNO"

                   // O sistema irá realizar automaticamente a exclusão de itens nas filiais de off-shore.
                   aDel := {}

              Case cAlias == "EEB"
                   cWork    := "WorkAg"
                   /*
                   bResumo  := {|cAlias| STR0007+ AllTrim((cAlias)->EEB_CODAGE)+" - "+; //"Agente: "
                                                  Capital(AllTrim((cAlias)->EEB_NOME)  +" ( "+SubStr(AllTrim((cAlias)->EEB_TIPOAG),3)+")")}
                   JPM - 06/06/05 */
                   
                   /* se estiver ativo o tratamento de tipo de comissão por item, mostra o tipo da comissão 
                      quando for agente recebedor de comissão */
                   If EE8->(FieldPos("EE8_TIPCOM")) > 0 .And. EE9->(FieldPos("EE9_TIPCOM")) > 0
                      bResumo  := {|cAlias| STR0007+ AllTrim((cAlias)->EEB_CODAGE)+" - "+; //"Agente: "
                                                     Capital(AllTrim((cAlias)->EEB_NOME)  +" ("+;
                                                     AllTrim(Tabela("YE",Left((cAlias)->EEB_TIPOAG,1),.f.))+")") +;
                                                     If((cAlias)->EEB_TIPOAG = CD_AGC,;
                                                     "; " + AvSx3("EEB_TIPCOM",AV_TITULO) + ": " +;
                                                     BscxBox("EEB_TIPCOM",(cAlias)->EEB_TIPCOM),"") }
                   Else
                      bResumo  := {|cAlias| STR0007+ AllTrim((cAlias)->EEB_CODAGE)+" - "+; //"Agente: "
                                                     Capital(AllTrim((cAlias)->EEB_NOME)  +" ( "+;
                                                     AllTrim(Tabela("YE",Left((cAlias)->EEB_TIPOAG,1),.f.))+")")}
                   EndIf
                   
                   aAux     := aClone(aVerifyEEB)
                   aCmpMemo := {}
                   aDel     := aClone(aAgDeletados)
                   cNmRecno := "WK_RECNO"
                   cCmpCod  := "EEB_CODAGE"

              Case cAlias == "EEN"
                   cWork    := "WorkNo"
                   bResumo  := {|cAlias| "Notify: "+ AllTrim((cAlias)->EEN_IMPORT)+" - "+;
                                                     AllTrim((cAlias)->EEN_IMPODE)}
                   aCmpMemo := {}
                   aAux     := aClone(aVerifyEEN)
                   aDel     := aClone(aNoDeletados)
                   cNmRecno := "WK_RECNO"
                   cCmpCod  := "EEN_IMPORT"

              Case cAlias == "EET"
                   cWork    := "WorkDe"
                   bResumo  := {|cAlias| STR0008+ AllTrim(Transf((cAlias)->EET_DESPES,AvSx3("EET_DESPES",AV_PICTURE)))+" - "+; //"Despesa: "
                                                  AllTrim(Posicione("SYB",1,xFilial("SYB")+(cAlias)->EET_DESPES,"YB_DESCR"))+;
                                                  Capital(If(EECFlags("FRESEGCOM"),;
                                                  STR0009+AllTrim(Posicione("SY5",1,xFilial("SY5")+(cAlias)->EET_CODAGE,"Y5_NOME"))+;  //" - Empresa: "
                                                  " ( "+SubStr(AllTrim((cAlias)->EET_TIPOAG),3)+")",;
                                                  ""))}
                   aCmpMemo := {}
                   aAux     := aClone(aVerifyEET)
                   aDel     := aClone(aDeDeletados)
                   cNmRecno := "EET_RECNO"
                   cCmpCod  := "EET_DESPES"

              Case cAlias == "EEJ"
                   cWork    := "WorkIn"
                   bResumo  := {|cAlias| STR0010+ AllTrim(Transf((cAlias)->EEJ_CODIGO,AvSx3("EEJ_CODIGO",AV_PICTURE)))+" - "+; //"Banco: "
                                                    AllTrim((cAlias)->EEJ_NOME)}
                   aCmpMemo := {}
                   aAux     := aClone(aVerifyEEJ)
                   aDel     := aClone(aInDeletados)
                   cNmRecno := "WK_RECNO"
                   cCmpCod  := "EEJ_CODIGO"
           EndCase

           (cWork)->(DbGoTop())
           Do While (cWork)->(!Eof())

              /* Para as tabelas de complementos o sistema irá realizar os tratamentos
                 para os registros incluídos ou excluídos. Visto que os mesmos poderão
                 ser replicados com os mesmos tratamentos utilizados para os campos.*/

              If Empty((cWork)->&(cNmRecNo)) .And. !(cAlias $ "EE8/EE9")

                 For k:=1 To Len(aCapaLocalidades)

                    If aCapaLocalidades[k][3] == OC_EM
                       // ** Verifica se o embarque possui dt. de embarque.
                       nRec_Aux:= EEC->(RecNo())
                       EEC->(DbSetOrder(1))
                       If EEC->(DbSeek(aCapaLocalidades[k][1]+aCapaLocalidades[k][2]))
                          If !Empty(EEC->EEC_DTEMBA)
                             EEC->(DbGoTo(nRec_Aux))
                             Loop
                          EndIf
                       EndIf
                       EEC->(DbGoTo(nRec_Aux))
                    EndIf

                    If cAlias == "EEJ"
                       If Left(WorkIn->EEJ_TIPOBC,1) == BC_DIM // Banco do Importador.
                          If aCapaLocalidades[k][1] <> AvGetM0Fil() //xFilial("EE8")
                             Loop
                          EndIf
                       EndIf
                    EndIf
                    
                    // JPM - 06/06/05 - Filtros customizados para inclusão na Wk_Main.
                    If EasyEntryPoint("EECAX100") 
                       lRetPonto := ExecBlock("EECAX100",.f.,.f.,{"FILTRO_COMPLEMENTO_INCLUIR",cAlias,k,cWork,cFase})
                       If ValType(lRetPonto) == "L" .And. !lRetPonto
                          Loop
                       EndIf
                    EndIf

                    // ** Grava registro na work principal.
                    Wk_Main->(DbAppend())
                    Wk_Main->WK_FILIAL := aCapaLocalidades[k][1]
                    Wk_Main->WK_PROC   := aCapaLocalidades[k][2]
                    Wk_Main->WK_FASE   := aCapaLocalidades[k][3]
                    Wk_Main->WK_OBS    := aCapaLocalidades[k][4]
                    Wk_Main->WK_CODCOM := AllTrim(cAlias)+AllTrim((cWork)->&(cCmpCod))
                    Wk_Main->WK_CAMPO  := "I"
                    Wk_Main->WK_MARCA  := If(lLoadMarked, cMarca,"")
                    Wk_Main->WK_RECNO  := (cWork)->(RecNo())
                    Wk_Main->WK_RECNOD := 0
                    lAdd := .t.
                 Next

                 If Empty(cMsg)
                    cMsg := Eval(bResumo,cWork)
                    If Len(cMsg) > 100
                       cMsg := MemoLine(cMsg,97,1)+"..."
                    EndIf
                 EndIf

                 If lAdd
                    // ** Grava registro na work genérica.
                    Wk_Geral->(DbAppend())
                    Wk_Geral->WK_REGIS  := AllTrim(cMsg)
                    Wk_Geral->WK_CAMPOS := STR0011 //"Registro novo."
                    Wk_Geral->WK_TABELA := cAlias
                    Wk_Geral->WK_MARCA  := If(lLoadMarked, cMarca,"")
                    Wk_Geral->WK_RECNO  := (cWork)->(RecNo())
                    Wk_Geral->WK_CODCOM := AllTrim(cAlias)+AllTrim((cWork)->&(cCmpCod))

                    lChangeComplemento := .t.
                    lAdd:=.f.
                 EndIf
                 
              Else // Verifica se o registro foi alterado.

                 cNmCampos := ""
                 (cAlias)->(DbGoTo((cWork)->&(cNmRecNo)))

                 SX3->(DbSetOrder(2))
                 For j:=1 To Len(aAux)

                    SX3->(DbSeek(aAux[j]))
                    If SX3->X3_CONTEXT = "V" .And. SX3->X3_TIPO <> "M"
                       Loop
                    EndIf

                    nPos := aScan(aCmpMemo,{|x| x[2] == aAux[j]})
                    If nPos > 0
                       xConteudo := AllTrim(Msmm((cAlias)->&(aCmpMemo[nPos][1]),AvSx3(aCmpMemo[nPos][2],AV_TAMANHO)))
                    Else
                       xConteudo := (cAlias)->&(aAux[j])
                    EndIf

                    If (cWork)->(FieldPos((cWork)->(aAux[j]))) > 0 .And. xConteudo <> (cWork)->&(aAux[j]) //THTS - 26/10/2017 - Verifica se o campo a ser testado existe na Work
                       If Empty(cMsg)
                          cMsg := Eval(bResumo,cWork)
                          If Len(cMsg) > 100
                             cMsg += MemoLine(cMsg,97,1)+"..."
                          EndIf
                       EndIf

                       If cAlias $ "EE8/EE9"
                          For k:=1 To Len(aItemLocalidades)

                              If aItemLocalidades[k][4] == OC_EM
                                 // ** Verifica se o embarque possui dt. de embarque.
                                 nRec_Aux:= EEC->(RecNo())
                                 EEC->(DbSetOrder(1))
                                 If EEC->(DbSeek(aItemLocalidades[k][2]+aItemLocalidades[k][3]))
                                    If !Empty(EEC->EEC_DTEMBA)
                                       EEC->(DbGoTo(nRec_Aux))
                                       Loop
                                    EndIf
                                 EndIf
                                 EEC->(DbGoTo(nRec_Aux))
                              EndIf

                              /* Se o campo pertencer ao aCamposBrasil, o mesmo só poderá ser atualizado no 
                                 embarque da mesma filial. */

                              If lIntermed .And. aScan(aCamposBrasil,aAux[j]) > 0//RMD - 28/06/18 - Se não tiver intermediação não executa a validação da filial.
                                 If aItemLocalidades[k][2] <> cFilBr .Or.;
                                    aItemLocalidades[k][4] <> OC_EM
                                    Loop
                                 EndIf
                              EndIf

                              /* Caso a tabela seja o EE8, para adicionar o registro na  wk_main, o sitema verifica
                                 inicialmente se o  campo que  sofreu  a alteração existe  na tabela do EE9. Caso o
                                 campo não exista os embarque disponíveis para atualização para o processo corrente
                                 não estarão disponíveis apenas para este campo. */

                              If cAlias == "EE8" .And. aAux[j] <> "EE8_PRENEG"
                                 If aItemLocalidades[k][4] == OC_EM
                                    If !AxCheckCmp(aAux[j])
                                       Loop
                                    EndIf
                                 EndIf
                              EndIf

                              /* O preço negociado será replicado apenas nos processos de embarque na
                                 filial do exterior. */

                              If cAlias == "EE8" .And. aAux[j] == "EE8_PRENEG"
                                 If aItemLocalidades[k][2] == cFilBr .Or. aItemLocalidades[k][4] <> OC_EM
                                    Loop
                                 EndIf
                              EndIf

                              If aItemLocalidades[k][1] = (cAlias)->&(calias+"_SEQUEN")
                                 Wk_Main->(DbAppend())
                                 Wk_Main->WK_FILIAL := aItemLocalidades[k][2]
                                 Wk_Main->WK_PROC   := aItemLocalidades[k][3]
                                 Wk_Main->WK_FASE   := aItemLocalidades[k][4]
                                 Wk_Main->WK_OBS    := aItemLocalidades[k][5]
                                 Wk_Main->WK_CAMPO  := aAux[j]
                                 Wk_Main->WK_MARCA  := If(lLoadMarked, cMarca,"")
                                 Wk_Main->WK_SEQUEN := aItemLocalidades[k][1]
                                 Wk_Main->WK_RECNO  := (cAlias)->(Recno())
                                 Wk_Main->WK_RECNOD := aItemLocalidades[k][7]

                                 /* O sistema seta a flag 'lAdd' para controlar se o campo estará  disponível para
                                    replicação de alterações. Caso o campo, não tenha destinos para replicação das
                                    alterações, o campo não será apresentado na tela de replicações. */
                                 lAdd := .t.
                              EndIf
                          Next
                       Else
                          For k:=1 To Len(aCapaLocalidades)
                              
                              If aCapaLocalidades[k][3] == OC_EM
                                 // ** Verifica se o embarque possui dt. de embarque.
                                 nRec_Aux:= EEC->(RecNo())
                                 EEC->(DbSetOrder(1))
                                 If EEC->(DbSeek(aCapaLocalidades[k][1]+aCapaLocalidades[k][2]))
                                    If !Empty(EEC->EEC_DTEMBA)
                                       EEC->(DbGoTo(nRec_Aux))
                                       Loop
                                    EndIf
                                 EndIf
                                 EEC->(DbGoTo(nRec_Aux))
                              EndIf

                              /* Se o campo pertencer ao aCamposBrasil, o mesmo só poderá ser atualizado no 
                                 embarque da mesma filial. */

                              If lIntermed .And. aScan(aCamposBrasil,aAux[j]) > 0////RMD - 28/06/18 - Se não tiver intermediação não executa a validação da filial.
                                 If aItemLocalidades[k][2] <> cFilBr .Or.;
                                    aItemLocalidades[k][4] <> OC_EM
                                    Loop
                                 EndIf
                              EndIf


                              If cAlias == "EEJ"
                                 If Left(WorkIn->EEJ_TIPOBC,1) == BC_DIM // Banco do Importador.
                                    If aCapaLocalidades[k][1] <> AvGetM0Fil() //xFilial("EE8")
                                       Loop
                                    EndIf
                                 EndIf
                              EndIf

                              // JPM - 06/06/05 - Filtros customizados para inclusão na Wk_Main.
                              If EasyEntryPoint("EECAX100") 
                                 lRetPonto := ExecBlock("EECAX100",.f.,.f.,{"FILTRO_COMPLEMENTO_ALTERAR",cAlias,k,aAux[j],cWork,cFase})
                                 If ValType(lRetPonto) == "L" .And. !lRetPonto
                                    Loop
                                 EndIf
                              EndIf
                              
                              // ** Grava registro na work principal.                           
                              Wk_Main->(DbAppend())
                              Wk_Main->WK_FILIAL := aCapaLocalidades[k][1]
                              Wk_Main->WK_PROC   := aCapaLocalidades[k][2]
                              Wk_Main->WK_FASE   := aCapaLocalidades[k][3]
                              Wk_Main->WK_OBS    := aCapaLocalidades[k][4]

                              If !(cAlias $ "EE8/EE9")
                                 Wk_Main->WK_CODCOM := AllTrim(cAlias)+AllTrim((cWork)->&(cCmpCod))
                              EndIf

                              Wk_Main->WK_CAMPO  := aAux[j] 
                              Wk_Main->WK_MARCA  := If(lLoadMarked, cMarca,"")
                              Wk_Main->WK_RECNO  := (cAlias)->(Recno())                   

                              aInfoDest := {aCapaLocalidades[k][1],aCapaLocalidades[k][2],aCapaLocalidades[k][3],0}
                              Wk_Main->WK_RECNOD := AxFindRecDest(cWork,cAlias,cCmpCod,aInfoDest)

                              lAdd := .t.
                          Next
                       EndIf

                       // ** Grava registro na work de Campos.
                       If lAdd
                          Wk_Field->(DbAppend())
                          Wk_Field->WK_FIELD := AvSx3(aAux[j],AV_TITULO)
                          Wk_Field->WK_CMPID := aAux[j]

                          If !Empty(AvSx3(aAux[j],12)) // Verifica se o campo é do tipo combo.
                             Wk_Field->WK_VLOLD := If(!Empty(xConteudo),;
                                                   AllTrim(BscxBox(aAux[j],xConteudo)),;
                                                   STR0012) //"(Vazio)"
                             Wk_Field->WK_VLATU := If(!Empty((cWork)->&(aAux[j])),;
                                                   AllTrim(BscxBox(aAux[j],(cWork)->&(aAux[j]))),;
                                                   STR0012) //"(Vazio)"
                          Else
                             Wk_Field->WK_VLOLD := If(!Empty(xConteudo),AllTrim(Transf(xConteudo,AvSx3(aAux[j],AV_PICTURE))),;
                                                   STR0012) //"(Vazio)"
                             Wk_Field->WK_VLATU := If(!Empty((cWork)->&(aAux[j])),;
                                                   AllTrim(Transf((cWork)->&(aAux[j]),AvSx3(aAux[j],AV_PICTURE))),;
                                                   STR0012) //"(Vazio)"
                          EndIf
                          Wk_Field->WK_FOLDER:= Ax100BuscaFolder(aAux[j])
                          Wk_Field->WK_TIPO  := If(cAlias $ "EE8/EE9",REG_ITEM,REG_COMP)
                          Wk_Field->WK_ORDEM := AvSx3(aAux[j],1) // Ordem.
                          Wk_Field->WK_MARCA := If(lLoadMarked, cMarca,"")
                          Wk_Field->WK_RECNO := (cAlias)->(RecNo())

                          cNmCampos += AllTrim(AvSx3(aAux[j],AV_TITULO))+"/ "
    
                          If cAlias $ "EE8/EE9"
                             lChangeItem := .t.
                          Else
                             lChangeComplemento := .t.
                          EndIf
                          lChange := .t.
                          lAdd:=.f.
                       EndIf
                    EndIf
                 Next

                 If lChange
                    cNmCampos := AllTrim(cNmCampos)
                    If Right(cNmCampos,1) == "/"
                       cNmCampos := SubStr(cNmCampos,1,Len(cNmCampos)-1)
                       cNmCampos := If(Len(cNmCampos)>100, AllTrim(MemoLine(cNmCampos,97,1))+"...",;
                                                           AllTrim(cNmCampos))
                    EndIf

                    If Empty(cMsg)
                       cMsg := AllTrim(Eval(bResumo,cWork))
                       If Len(cMsg) > 100
                          cMsg += MemoLine(cMsg,97,1)+"..."
                       EndIf
                    EndIf

                    // ** Grava registro na work genérica.
                    Wk_Geral->(DbAppend())
                    Wk_Geral->WK_REGIS  := cMsg
                    Wk_Geral->WK_TABELA := cAlias
                    Wk_Geral->WK_MARCA  := If(lLoadMarked, cMarca,"")
                    Wk_Geral->WK_RECNO  := (cAlias)->(Recno())
                    Wk_Geral->WK_CAMPOS := cNmCampos

                    If cAlias $ "EE8/EE9"
                       Wk_Geral->WK_SEQUEN := (cAlias)->&(cAlias+"_SEQUEN")
                       Wk_Geral->WK_CODPRO := (cAlias)->&(cAlias+"_COD_I")
                    Else
                       Wk_Geral->WK_CODCOM := AllTrim(cAlias)+AllTrim((cWork)->&(cCmpCod))
                    EndIf
                    lChange := .f.                                                        
                 EndIf
              EndIf

              cMsg := ""
              (cWork)->(DbSkip())
           EndDo

           // ** Verifica se existem itens deletados.
           If Len(aDel) > 0
              For j:=1 To Len(aDel)
                 (cAlias)->(DbGoTo(aDel[j]))

                 For k:=1 To Len(aCapaLocalidades)

                    If aCapaLocalidades[k][3] == OC_EM
                       // ** Verifica se o embarque possui dt. de embarque.
                       nRec_Aux:= EEC->(RecNo())
                       EEC->(DbSetOrder(1))
                       If EEC->(DbSeek(aCapaLocalidades[k][1]+aCapaLocalidades[k][2]))
                          If !Empty(EEC->EEC_DTEMBA)
                             EEC->(DbGoTo(nRec_Aux))
                             Loop
                          EndIf
                       EndIf
                       EEC->(DbGoTo(nRec_Aux))
                    EndIf

                    If cAlias == "EEJ"
                       If Left(EEJ->EEJ_TIPOBC,1) == BC_DIM // Banco do Importador.
                          If aCapaLocalidades[k][1] <> AvGetM0Fil() //xFilial("EE8")
                             Loop
                          EndIf
                       EndIf
                    EndIf
                    
                    // JPM - 06/06/05 - Filtros customizados para inclusão na Wk_Main.
                    If EasyEntryPoint("EECAX100") 
                       lRetPonto := ExecBlock("EECAX100",.f.,.f.,{"FILTRO_COMPLEMENTO_EXCLUIR",cAlias,k,cWork,cFase})
                       If ValType(lRetPonto) == "L" .And. !lRetPonto
                          Loop
                       EndIf
                    EndIf

                    Wk_Main->(DbAppend())
                    Wk_Main->WK_FILIAL := aCapaLocalidades[k][1]
                    Wk_Main->WK_PROC   := aCapaLocalidades[k][2]
                    Wk_Main->WK_FASE   := aCapaLocalidades[k][3]
                    Wk_Main->WK_OBS    := aCapaLocalidades[k][4]
                    Wk_Main->WK_CODCOM := AllTrim(cAlias)+AllTrim((cAlias)->&(cCmpCod))
                    Wk_Main->WK_CAMPO  := "E"
                    Wk_Main->WK_MARCA  := If(lLoadMarked, cMarca,"")
                    Wk_Main->WK_RECNO  := aDel[j]

                    aInfoDest := {aCapaLocalidades[k][1],aCapaLocalidades[k][2],aCapaLocalidades[k][3],aDel[j]}
                    Wk_Main->WK_RECNOD := AxFindRecDest(cWork,cAlias,cCmpCod,aInfoDest)
                    lAdd:=.t.
                 Next
                 
                 /* Tratamentos  para  carregar  texto que será exibido na tela de campos para
                    itens (Pedido/Embarque) e tabelas de complementos. (Campo memo apresentado
                    na cabeçalho da tela). */

                 If lAdd                 
                    Do Case
                       Case cAlias == "EE8"
                            cMsg := "Seq.: "+;
                                    AllTrim(EE8->EE8_SEQUEN)+" / "+;
                                    AllTrim(Transf(EE8->EE8_COD_I,AvSx3("EE8_COD_I",AV_PICTURE)))+" / "+;
                                    AllTrim(Memoline(Msmm(EE8->EE8_DESC,AVSX3("EE8_VM_DES",AV_TAMANHO)),;
                                                     AvSx3("EE8_VM_DES",AV_TAMANHO),1))
                       Case cAlias == "EE9"
                            cMsg := "Seq.: "+;
                                    AllTrim(EE9->EE9_SEQEMB)+" / "+;
                                    AllTrim(Transf(EE9->EE9_COD_I,AvSx3("EE9_COD_I",AV_PICTURE)))+" / "+;
                                    AllTrim(Memoline(Msmm(EE9->EE9_DESC,AVSX3("EE9_VM_DES",AV_TAMANHO)),;
                                                     AvSx3("EE9_VM_DES",AV_TAMANHO),1))
                       OtherWise

                            // ** Para as demais tabelas utiliza os comandos do 'bResumo'.
                            cMsg := Eval(bResumo,cAlias)
                    EndCase

                    If Len(cMsg) > 100
                       cMsg += MemoLine(cMsg,97,1)+"..."
                    EndIf

                    // ** Grava registro na work genérica.
                    Wk_Geral->(DbAppend())
                    Wk_Geral->WK_REGIS  := AllTrim(cMsg)
                    Wk_Geral->WK_CAMPOS := STR0013 //"Registro excluido."
                    Wk_Geral->WK_TABELA := cAlias
                    Wk_Geral->WK_RECNO  := aDel[j]
                    Wk_Geral->WK_MARCA  := If(lLoadMarked, cMarca,"")

                    If cAlias $ "EE8/EE9"
                       Wk_Geral->WK_SEQUEN := (cAlias)->&(cAlias+"_SEQUEN")
                       Wk_Geral->WK_CODPRO := (cAlias)->&(cAlias+"_COD_I")
                    Else
                       Wk_Geral->WK_CODCOM := cAlias+AllTrim((cAlias)->&(cCmpCod))
                    EndIf
                    lAdd:=.f.
      
                    If cAlias $ "EE8/EE9"
                       lChangeItem := .t.
                    Else
                       lChangeComplemento := .t.
                    EndIf
                 EndIf
              Next
           EndIf
      EndCase

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : AxTela()
Parametros  : cFase - Fase de Pedido.
                      Fase de Embarque.
Retorno     : .t./.f.
Objetivos   : Construir/Exibir tela para que o usuário configure a atualização nos processos e filiais
              de off-shore existentes.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/02/2005 - 10:50.
Revisao     :
Obs.        :
*/
*---------------------------*
Static Function AxTela(cFase)
*---------------------------*
Local lRet := .t.
Local lInverte := .f.
Local oDlg, oFldCapa, oFldItem , oFldComplemento, oBtMkCapa, oBtMkItem, oBtMkCompl, oSayFindCapa, oSayFindItem,;
      oSayFindCompl , oFindCapa, oFindItem, oFindCompl, oComboCapa, oBtFindCapa, oComboItem, oBtFindItem
Local nOpca    := 0, j:=0
Local aButtons :={}, aPosDlg := {}, aDialogs:={}, aPrompts:={}, aCmpField:={}, aCmpGeral := {},;
      aOpcCapa :={STR0014}, aOpcItem:={STR0015,STR0016} //"Campo"###"Sequencia"###"Cod.Produto"
Local cTitulo, cToFindCapa := Space(100), cToFindItem := Space(100), cToFindCompl := Space(100),;
      cOpcCapa, cOpcItem
Local bCancel  := {|| If(AxValid(VLD_EXIT),oDlg:End(),nil)},;
      bOk      := {|| If(AxValid(VLD_MAIN),(nOpca := 1, if((Type("lEE7Auto") <> "L" .Or. !lEE7Auto /*RMD - 22/12/17*/), oDlg:End(), )),nil)}

Private oFld, oBrowseField, oBrowseItem, oBrowseComp, oPanelCapa, oPanelItem, oPanelComplemento

Begin Sequence

   cTitulo := STR0017+; //"Controle de Atualizações - Processo Nro.: "
              If(cFase == OC_PE,AllTrim(Transf(EE7->EE7_PEDIDO,AvSx3("EE7_PEDIDO",AV_PICTURE))),;
                                AllTrim(Transf(EEC->EEC_PREEMB,AvSx3("EEC_PREEMB",AV_PICTURE))))

   // ** Definições para criação dos folders.
   If lChangeCapa
      aAdd(aDialogs,"CP")
      aAdd(aPrompts,STR0018) //"&Capa"
   EndIf

   If lChangeItem
      aAdd(aDialogs,"IT")
      aAdd(aPrompts,STR0019) //"&Itens"
   EndIf

   If lChangeComplemento
      aAdd(aDialogs,"CO")
      aAdd(aPrompts,STR0020) //"C&omplementos"
   EndIf

   //RMD - 22/12/17 - Se for Execauto não exibe a tela
   If Type("lEE7Auto") <> "L" .Or. !lEE7Auto

   Define MsDialog oDlg Title cTitulo From 5,0 To 30,95 STYLE nOR(DS_MODALFRAME, WS_POPUP) Of oMainWnd

       oDlg:lEscClose  := .F.
       aPosDlg := PosDlg(oDlg)
       aPosDlg [3] -= 15

       oFld := TFolder():New(aPosDlg[1],aPosDlg[2],aPrompts,aDialogs,oDlg,,,,.t.,.f.,aPosDlg[4],aPosDlg[3])
       oFld:bChange := {|nOption| AxTrataObj(nOption)}
       aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont)})

       // ** Tratamentos para os folders.
       For j:=1 To Len(oFld:aDialogs)
          Do Case
             Case oFld:aDialogs[j]:cCaption = STR0018 //"&Capa"
                  oFldCapa := oFld:aDialogs[j]

                  @ 00,00 MsPanel oPanelCapa Prompt "" Size 400,15 of oFldCapa

                  @ 01,01 BUTTON oBtMkCapa PROMPT STR0021 ; //"Marca/Desmarca Todos (Capa)"
                          SIZE 085,10 ACTION AxMarca(BT_CAPA) Of oPanelCapa Pixel

                  @ 02,090 Say oSayFindCapa   Var STR0022  Size 100,010 Of oPanelCapa Pixel COLOR CLR_HBLUE //"Pesquisar"
                  @ 01,120 COMBOBOX oComboCapa Var cOpcCapa Items aOpcCapa Size 80,09 Of oPanelCapa Pixel
                  @ 01,201 Get oFindCapa Var cToFindCapa  Size 100,008 Of oPanelCapa Pixel
                  @ 01,302 BUTTON oBtFindCapa PROMPT "Ok" SIZE 15,10 ACTION AxFind(BT_CAPA,cOpcCapa,cToFindCapa) ;
                                                                      Of oPanelCapa  Pixel

             Case oFld:aDialogs[j]:cCaption = "&Itens"
                  oFldItem := oFld:aDialogs[j]
                  
                  @ 00,00 MsPanel oPanelItem Prompt "" Size 400,15 of oFldItem

                  @ 01,01 BUTTON oBtMkItem PROMPT STR0023 ; //"Marca/Desmarca Todos (Itens)"
                          SIZE 085,10 ACTION AxMarca(BT_ITEM) Of oPanelItem Pixel

                  @ 02,090 Say oSayFindItem   Var STR0022  Size 100,010 Of oPanelItem Pixel COLOR CLR_HBLUE //"Pesquisar"
                  @ 01,120 COMBOBOX oComboItem Var cOpcItem Items aOpcItem Size 80,09 Pixel Of oPanelItem
                  @ 01,201 Get oFindItem Var cToFindItem  Size 100,008 of oPanelItem Pixel 
                  @ 01,302 BUTTON oBtFindItem PROMPT "Ok" SIZE 15,10 ACTION AxFind(BT_ITEMCOMP,cOpcItem,cToFindItem);
                                                                     Of oPanelItem Pixel
             Case oFld:aDialogs[j]:cCaption = STR0020 //"C&omplementos"
                  oFldComplemento := oFld:aDialogs[j]
                  @ 00,00 MsPanel oPanelComplemento Prompt "" Size 400,15 of oFldComplemento
                  @ 01,01 BUTTON oBtMkCompl PROMPT "Marca/Desmarca Todos (Compl.)" ;
                          SIZE 085,10 ACTION AxMarca(BT_COMP) Of oPanelComplemento Pixel
          EndCase
       Next

       aPosDlg[1] += 25
       aPosDlg[3] += 15

       aCmpField := {{"WK_MARCA","","  "},;
                     {{||Wk_Field->WK_FIELD} ,"",STR0014},; //"Campo"
                     {{||Wk_Field->WK_FOLDER},"","Pasta"},; 
                     {{||Wk_Field->WK_VLOLD} ,"",STR0024},; //"Valor Antigo"
                     {{||Wk_Field->WK_VLATU} ,"",STR0025}}  //"Valor Atual"
                                             
       oBrowseField := MsSelect():New("Wk_Field","WK_MARCA",,aCmpField,@lInverte,@cMarca,;
                                                 {aPosDlg[1],aPosDlg[2],aPosDlg[3],aPosDlg[4]},,,oFldCapa)

       oBrowseField:bAval := {|| AxAtuTela(,BT_CAPA),oBrowseField:oBrowse:Refresh()}

       If lChangeItem
          aCmpGeral := {{"WK_MARCA","","  "},;
                        {{||Wk_Geral->WK_REGIS} ,"",STR0026},; //"Registro"
                        {{||Wk_Geral->WK_CAMPOS},"",STR0027}} //"Campos"

          oBrowseItem := MsSelect():New("Wk_Geral","WK_MARCA",,aCmpGeral,@lInverte,@cMarca,;
                                                    {aPosDlg[1],aPosDlg[2],aPosDlg[3],aPosDlg[4]},,,oFldItem)

          oBrowseItem:bAval := {|| AxDetTela(,BT_ITEM),oBrowseItem:oBrowse:Refresh()}
       EndIf

       If lChangeComplemento
          aCmpGeral := {{"WK_MARCA","","  "},;
                        {{||Wk_Geral->WK_REGIS} ,"",STR0026},; //"Registro"
                        {{||Wk_Geral->WK_CAMPOS},"",STR0027}} //"Campos"

          oBrowseComp := MsSelect():New("Wk_Geral","WK_MARCA",,aCmpGeral,@lInverte,@cMarca,;
                                                    {aPosDlg[1],aPosDlg[2],aPosDlg[3],aPosDlg[4]},,,oFldComplemento)
          /* Observações:
             No 'bAval' do 'BrowseComp':
             a) Para os registros  de  complementos incluídos ou excluídos o sistema irá abrir
                diretamente a tela de localidades;
             b) Para os registros alterados, irá realizar o tratamento normal e abrir  a  tela
                com os campos que foram alterados para que o usuário marque para cada registro
                os destinos para as alterações. */

          oBrowseComp:bAval := {|| If((AllTrim(Wk_Geral->WK_CAMPOS) $ STR0028),; //"Registro excluido./Registro novo."
                                       AxAtuTela(,BT_COMP),AxDetTela(,BT_COMP)),oBrowseComp:oBrowse:Refresh()}
       EndIf

   Activate MsDialog oDlg On Init (EnchoiceBar(oDlg,bOk,bCancel,,aButtons),AxSetObj()) Centered
   Else/*RMD - 22/12/17*/
      
        Eval(bOK)
   EndIf
End Sequence

Return lRet

/*
Funcao      : AxDetTela().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Construir/Exibir tela para que o usuário configure a atualização dos campos para 
              os itens e complementos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/02/2005 - 09:02.
Revisao     :
Obs.        :
*/
*-------------------------*
Static Function AxDetTela()
*-------------------------*
Local lRet := .t., lInverte := .f., lMarcado := .f.
Local oDlg, oBtMk, oSayFindCapa, oFindCapa, oBrowseDet, oMemo, oComboCapa, oBtFindCapa, oDetPanel
Local oFont := TFont():New("Arial Ocidental",06,15)
Local nOpca    := 0, nRec := 0, j:=0
Local aButtons :={}, aPosDlg := {}, aCmpDetField:={}, aOpcCapa := {STR0014}, aMarca:={}, aMarcaAtu:={} //"Campo"
Local cTitulo, cToFindCapa := Space(100), cMemo, cAlias, cWork, cAux, cOldFilter, cOpcCapa,;
      cTipo, cCampos:=""
Local bCancel  := {|| oDlg:End()},;
      bOk      := {|| If(AxValid(VLD_DET),(nOpca := 1, oDlg:End()),nil)},;
      bOldFilter

Begin Sequence

   cAlias := Wk_Geral->WK_TABELA
   Do Case
      Case cAlias $ "EE8/EE9"
           nRec := (cAlias)->(Recno())
           (cAlias)->(DbGoTo(Wk_Geral->WK_RECNO))

           cMemo := STR0029+AllTrim((cAlias)->&(cAlias+If(cAlias=="EE8","_SEQUEN","_SEQEMB")))+" / "+; //"Seq./ Prod.: "
                                    AllTrim(Transf((cAlias)->&(cAlias+"_COD_I"),AvSx3(cAlias+"_COD_I",AV_PICTURE)))+;
                                    ENTER
           cMemo += STR0030+Memoline(Msmm((cAlias)->&(cAlias+"_DESC"), AVSX3(cAlias+"_VM_DES",AV_TAMANHO)),; //"Desc.: "
                                       AvSx3(cAlias+"_VM_DES",AV_TAMANHO),1)
           (cAlias)->(DbGoTo(nRec))
           cTipo := REG_ITEM

      Case cAlias $ "EXL"

           cMemo := Wk_Geral->WK_REGIS
           cTipo := REG_COMP

      Case cAlias $ "EEB/EET/EEN/EEJ"
           nRec := (cAlias)->(Recno())
           (cAlias)->(DbGoTo(Wk_Geral->WK_RECNO))
           Do Case
              Case cAlias == "EEB"
                   cMemo := STR0007+AllTrim(EEB->EEB_CODAGE)+" - "+AllTrim(EEB->EEB_NOME) //"Agente: "

              Case cAlias == "EET"
                   cMemo := STR0008+ AllTrim(Transf(EET->EET_DESPES,AvSx3("EET_DESPES",AV_PICTURE)))+" - "+; //"Despesa: "
                                         AllTrim(Posicione("SYB",1,xFilial("SYB")+EET->EET_DESPES,"YB_DESCR"))+ENTER

                   If EECFlags("FRESEGCOM")
                      cMemo += STR0031+AllTrim(Posicione("SY5",1,xFilial("SY5")+EET->EET_CODAGE,"Y5_NOME")) //"Empresa : "
                   EndIf

              Case cAlias == "EEN"
                   cMemo := STR0032+ AllTrim(EEN->EEN_IMPORT)+" - "+AllTrim(EEN->EEN_IMPODE) //"Notify: "

              Case cAlias == "EEJ"
                   cMemo := STR0010+ AllTrim(Transf(EEJ->EEJ_CODIGO,AvSx3("EEJ_CODIGO",AV_PICTURE)))+" - "+; //"Banco: "
                                                   AllTrim(EEJ->EEJ_NOME)
           EndCase

           (cAlias)->(DbGoTo(nRec))
           cTipo := REG_COMP
   EndCase

   cTitulo := STR0033 //"Controle de Atualizações - Itens/Complementos."

   cOldFilter := Wk_Field->(DbFilter())
   bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

   // Set dos filtros para as tabelas de itens/complementos.
   Do Case
      Case cAlias $ "EE8/EE9/EEB/EET/EEN/EEJ"
           Wk_Field->(DbClearFilter())
           Wk_Field->(DbSetFilter({|| Str(Wk_Field->WK_RECNO,7,0) == Str(Wk_Geral->WK_RECNO,7,0) .And.;
                                      Wk_Field->WK_TIPO == cTipo .And.;
                                      Left(Wk_Field->WK_CMPID,3) == Wk_Geral->WK_TABELA},;
                                      "Str(Wk_Field->WK_RECNO,7,0) == '"+Str(Wk_Geral->WK_RECNO,7,0)+"' .And. "+;
                                      "Wk_Field->WK_TIPO == '"+cTipo+"' .And. "+;
                                      "Left(Wk_Field->WK_CMPID,3) == '"+Wk_Geral->WK_TABELA+"'"))
      Case cAlias == "EXL"

           /* a) Carrega os campos que deverão ser apresentados para a despesa internacional selecionada.
              b) Considera além dos campos do EXL, os campos que serão atualizados na capa para cada grupo
                 de campos referente a despesa internacional. */

           nPos := aScan(aDespInt,{|x| x[1] = Wk_Geral->WK_DESPID})
           If nPos > 0
              cCampos := AllTrim(aDespInt[nPos][2])
           EndIf

           Wk_Field->(DbClearFilter())
           Wk_Field->(DbSetFilter({|| Str(Wk_Field->WK_RECNO,7,0)== Str(Wk_Geral->WK_RECNO,7,0) .And. ;
                                      Wk_Field->WK_TIPO  == cTipo .And.;
                                      Right(AllTrim(Wk_Field->WK_CMPID),2) ==  Wk_Geral->WK_DESPID .Or.;
                                      Wk_Field->WK_CMPID = cCampos },;
                                      "Str(Wk_Field->WK_RECNO,7,0) == '"+Str(Wk_Geral->WK_RECNO,7,0)+"' .And. "+;
                                      "Wk_Field->WK_TIPO == '"+cTipo+"' .And. "+;
                                      "Right(AllTrim(Wk_Field->WK_CMPID),2) == '"+Wk_Geral->WK_DESPID+"'.Or. "+;
                                      "Wk_Field->WK_CMPID == '"+cCampos+"'"))
   EndCase

   /* Controles para armazenar os itens marcados/desmarcados para restauração em caso de 
      cancelamento das operações pelo usuário na tela de seleção de campos. */

   Wk_Field->(DbGoTop())
   Do While Wk_Field->(!Eof())

      aAdd(aMarca,{Wk_Field->(RecNo()),;
                   Wk_Field->WK_MARCA})

      Wk_Main->(DbSetOrder(1))
      If Wk_Main->(DbSeek(Wk_Field->WK_CMPID+Wk_Geral->WK_SEQUEN))
         Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CAMPO  == Wk_Field->WK_CMPID .And.;
                                          Wk_Main->WK_SEQUEN == Wk_Geral->WK_SEQUEN
            aAdd(aMarcaAtu,{Wk_Main->(RecNo()),;
                            Wk_Main->WK_MARCA})
            Wk_Main->(DbSkip())
         EndDo
      EndIf

      Wk_Field->(DbSkip())
   EndDo

   Wk_Field->(DbSetOrder(1))
   Wk_Field->(DbGoTop())

   Define MsDialog oDlg Title cTitulo From 9,0 To 34,80 Of oMainWnd

       oDlg:lEscClose  := .f.
       aPosDlg := PosDlg(oDlg)

       @ 00,00 MsPanel oDetPanel Prompt "" Size 400,39 of oDlg
       @ 01,01 Get oMemo Var cMemo MEMO HSCROLL SIZE aPosDlg[4]-1,aPosDlg[1]+08 READONLY FONT oFont COLOR CLR_HBLUE Of oDetPanel UPDATE Pixel     
       oMemo:lWordWrap := .F.

       @ 25,01 BUTTON oBtMk PROMPT STR0034 ; //"Marca/Desmarca Todos"
                                              SIZE 068,10 ACTION AxMarca(BT_DET) Of oDetPanel Pixel

       @ 25,075 Say oSayFindCapa  Var STR0022  Size 100,010 Of oDetPanel Pixel COLOR CLR_HBLUE //"Pesquisar"
       @ 25,105 COMBOBOX oComboCapa Var cOpcCapa Items aOpcCapa Size 80,09 Pixel Of oDetPanel
       @ 25,186 Get oFindCapa Var cToFindCapa  Size 113,008 of oDetPanel Pixel 
       @ 25,300 BUTTON oBtFindCapa PROMPT "Ok" SIZE 15,10 ACTION AxFind(BT_DET,cOpcCapa,cToFindCapa);
                                                                       Of oDetPanel Pixel
       aPosDlg[1] += 38
       aCmpDetField := {{"WK_MARCA","","  "},;
                        {{||Wk_Field->WK_FIELD} ,"", STR0014},; // "Campo"
                        {{||Wk_Field->WK_FOLDER},"", "Pasta"},;
                        {{||Wk_Field->WK_VLOLD} ,"", STR0024},; // "Valor Antigo"
                        {{||Wk_Field->WK_VLATU} ,"", STR0025}}  // "Valor Atual"

       oBrowseDet := MsSelect():New("Wk_Field","WK_MARCA",,aCmpDetField,@lInverte,@cMarca,;
                                                           {aPosDlg[1],aPosDlg[2],aPosDlg[3],aPosDlg[4]},,,oDlg)

       oBrowseDet:bAval := {|| AxAtuTela(,BT_DET),oBrowseDet:oBrowse:Refresh()}
       
	   oDetPanel:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
       oBrowseDet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	   
   Activate MsDialog oDlg On Init (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) Centered //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   If nOpca = 1
      // ** Verifica se existe algum item marcado.
      lMarcado := .f.

      Wk_Field->(DbGoTop())
      Do While Wk_Field->(!Eof())
         If !Empty(Wk_Field->WK_MARCA)
            lMarcado := .t.
            Exit
         EndIf
         Wk_Field->(DbSkip())
      EndDo

      Wk_Geral->WK_MARCA := If(lMarcado,cMarca,Space(2))

   Else // Botão 'cancelar' acionado.

      /* O sistema irá recuperar a situação existente quando a tela foi carregada inicialmente,
         caso o usuário tenha marcado/desmarcado algum campo, as informações serão restauradas. */

      If Len(aMarca) > 0
         For j:= 1 To Len(aMarca)
            Wk_Field->(DbGoTo(aMarca[j][1]))
            Wk_Field->WK_MARCA := aMarca[j][2]
         Next
      EndIf

      If Len(aMarcaAtu) > 0
         For j:= 1 To Len(aMarcaAtu)
            Wk_Main->(DbGoTo(aMarcaAtu[j][1]))
            Wk_Main->WK_MARCA := aMarcaAtu[j][2]
         Next
      EndIf
   EndIf

   If !Empty(cOldFilter)
      Wk_Field->(DbClearFilter())
      Wk_Field->(DbSetFilter(bOldFilter,cOldFilter))
      Wk_Field->(DbSetOrder(1))
      Wk_Field->(dbGoTop())
   EndIf

End Sequence

Return lRet

/*
Funcao      : AxAtuTela().
Parametros  : lCall - .t. - Chamada automaticamente pelo botão marca/desmarca todos.
                      .f. - Chamada no clique duplo. (Default).
              cBotao - BT_CAPA/BT_ITEM - Trata diretamente a Wk_Field.
                       BT_COMP/BT_DET  - Trata diretamente a Wk_Geral e Wk_Field.
Retorno     : .t./.f.
Objetivos   : Construir/Exibir tela para que o usuário configure os locais onde serão realizadas as 
              atualizações.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/02/2005 - 09:37.
Revisao     :
Obs.        :
*/
*-------------------------------------*
Static Function AxAtuTela(lCall,cBotao)
*-------------------------------------*
Local lRet := .t., lInverte := .f., lTemItemMarcado := .f., lTemCampoMarcado := .f.
Local oDlg, oBtMk, oBrowseAtu, oAtuPanel
Local nOpca    := 0, nRec := 0, k:=0, lVerif
Local aButtons :={}, aPosDlg := {}, aCmpAtu:={}
Local cTitulo, cOldFilter, cTipo
Local bCancel  := {|| oDlg:End(),lRet:=.f.},;
      bOk      := {|| If(AxValid(VLD_ATU),(nOpca := 1, oDlg:End()),nil)},;
      bOldFilter

Default lCall := .f.

Begin Sequence

   Wk_Atu->(avzap())

   If lCall // Chamada pelo botão marca/desmarca todos.
      lVerif := AxVerifBrasil(cBotao) //Verifica se todos os campos pertencem a aCamposBrasil
      Do Case
         Case (cBotao $ BT_CAPA+"/"+BT_COMP)

             /* Para montar a work de localidades, para capa ou complementos, o sistema se baseia,
                no array com os processos onde o pedido foi utilizado. */

             For k:=1 To Len(aCapaLocalidades)
               If (lVerif .and. aCapaLocalidades[k][1] == AvGetM0Fil()) .or. !lVerif 
                Wk_Atu->(DbAppend())
                Wk_Atu->WK_MARCA  := Space(2)
                Wk_Atu->WK_CODFIL := aCapaLocalidades[k][1]
                Wk_Atu->WK_PROC   := aCapaLocalidades[k][2]
                Wk_Atu->WK_FASE   := aCapaLocalidades[k][3]
                Wk_Atu->WK_OBS    := aCapaLocalidades[k][4]

                If lIntermed
                   Wk_Atu->WK_FILIAL := If(aCapaLocalidades[k][1] == cFilBr, STR0035,STR0036) //"Brasil"###"Off-Shore"
                   EndIf
                EndIf
             Next

         Case cBotao == BT_ITEM

             /* Para montar a work de localidades, para os itens, o sistema se baseia,
                no array com todos os embarques onde o item foi utilizado. */

             Wk_Atu->(DbSetOrder(1))

             For k:=1 To Len(aItemLocalidades)
                nRec := Wk_Geral->(RecNo())

                // Neste ponto a Wk_Geral, estará filtrada com os registros referentes apenas aos itens.            
                Wk_Geral->(DbGoTop())
                Do While Wk_Geral->(!Eof())
                   If Wk_Geral->WK_SEQUEN == aItemLocalidades[k][1]

                      If (lVerif .and. aItemLocalidades[k][2] == AvGetM0Fil()) .or. !lVerif 
                      If !Wk_Atu->(DbSeek(aItemLocalidades[k][2]+aItemLocalidades[k][3]+aItemLocalidades[k][4]))
                         Wk_Atu->(DbAppend())
                         Wk_Atu->WK_MARCA  := Space(2)
                         Wk_Atu->WK_CODFIL := aItemLocalidades[k][2]
                         Wk_Atu->WK_PROC   := aItemLocalidades[k][3]
                         Wk_Atu->WK_FASE   := aItemLocalidades[k][4]                         
                         Wk_Atu->WK_OBS    := aItemLocalidades[k][5]

                         If lIntermed
                            Wk_Atu->WK_FILIAL := If(aItemLocalidades[k][2] == cFilBr, STR0035,STR0036) //"Brasil"###"Off-Shore"
                         EndIf
                      EndIf
                   EndIf
                   EndIf
                   Wk_Geral->(DbSkip())
                EndDo                
                Wk_Geral->(DbGoTo(nRec))
             Next

         Case cBotao == BT_DET
             
            If !Empty(Wk_Geral->WK_SEQUEN)

               /* Para montar a work de localidades, para os itens, o sistema se baseia no array com 
                  todos os embarques onde o item foi utilizado (Considerando as filiais de off-shore. */

               For k:=1 To Len(aItemLocalidades)                
                  If  Wk_Geral->WK_SEQUEN == aItemLocalidades[k][1]
                     If (lVerif .and. aItemLocalidades[k][2] == AvGetM0Fil()) .or. !lVerif 
                     If !Wk_Atu->(DbSeek(aItemLocalidades[k][2]+aItemLocalidades[k][3]))
                        Wk_Atu->(DbAppend())
                        Wk_Atu->WK_MARCA  := Space(2)
                        Wk_Atu->WK_CODFIL := aItemLocalidades[k][2]
                        Wk_Atu->WK_PROC   := aItemLocalidades[k][3]
                        Wk_Atu->WK_FASE   := aItemLocalidades[k][4]
                        Wk_Atu->WK_OBS    := aItemLocalidades[k][5]

                        If lIntermed
                           Wk_Atu->WK_FILIAL := If(aItemLocalidades[k][2] == cFilBr, STR0035,STR0036) //"Brasil"###"Off-Shore"
                        EndIf
                     EndIf
                  EndIf
                  EndIf
               Next
            Else

               /* Quando o sistema estiver montando a work de localidades para registros referentes a 
                  complementos, o sistema deverá considerar apenas os processos que poderão ser atualizados
                  para os campos da capa e compos de complementos diversos */

               For k:=1 To Len(aCapaLocalidades)
                  If (lVerif .and. aCapaLocalidades[k][1] == AvGetM0Fil()) .or. !lVerif 
                  Wk_Atu->(DbAppend())
                  Wk_Atu->WK_MARCA  := Space(2)
                  Wk_Atu->WK_CODFIL := aCapaLocalidades[k][1]
                  Wk_Atu->WK_PROC   := aCapaLocalidades[k][2]
                  Wk_Atu->WK_FASE   := aCapaLocalidades[k][3]
                  Wk_Atu->WK_OBS    := aCapaLocalidades[k][4]

                  If lIntermed
                    Wk_Atu->WK_FILIAL := If(aCapaLocalidades[k][1] == cFilBr, STR0035,STR0036) //"Brasil"###"Off-Shore"
                     EndIf
                  EndIf
               Next
            EndIf
      EndCase

   Else  // Chamada diretamente pelo usuário no browse.

      Do Case
         Case (cBotao $ BT_CAPA+"/"+BT_COMP)

              Do Case
                 Case (cBotao == BT_COMP) .And.;
                      (AllTrim(Wk_Geral->WK_CAMPOS) $ STR0028) //"Registro excluido./Registro novo."

                      /* Para os casos de registros de complementos
                         incluídos. */

                      Wk_Atu->(DbSetOrder(1))
                      Wk_Main->(DbSetOrder(3))
                      If Wk_Main->(DbSeek(Wk_Geral->WK_CODCOM))
                         Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CODCOM  == Wk_Geral->WK_CODCOM

                            If Wk_Main->WK_RECNO <> Wk_Geral->WK_RECNO
                               Wk_Main->(DbSkip())
                               Loop
                            EndIf

                            If !Wk_Atu->(DbSeek(Wk_Main->WK_FILIAL+Wk_Main->WK_PROC))
                               Wk_Atu->(DbAppend())
                               Wk_Atu->WK_MARCA  := Wk_Main->WK_MARCA
                               Wk_Atu->WK_PROC   := Wk_Main->WK_PROC
                               Wk_Atu->WK_FASE   := Wk_Main->WK_FASE
                               Wk_Atu->WK_OBS    := Wk_Main->WK_OBS
                               Wk_Atu->WK_CODFIL := Wk_Main->WK_FILIAL

                               If lIntermed
                                  Wk_Atu->WK_FILIAL := If(Wk_Main->WK_FILIAL == cFilBr, STR0035,STR0036) //"Brasil"###"Off-Shore"
                               EndIf
                            EndIf

                            Wk_Main->(DbSkip())
                         EndDo
                      EndIf

                 OtherWise

                      Wk_Main->(DbSetOrder(1))
                      If Wk_Main->(DbSeek(Wk_Field->WK_CMPID))
                         Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CAMPO  == Wk_Field->WK_CMPID

                            // ** Amarração dos campos dos complementos.
                            If (cBotao == BT_COMP) .And. (Wk_Main->WK_RECNO  <> Wk_Field->WK_RECNO)
                               Wk_Main->(DbSkip())
                               Loop
                            EndIf

                            Wk_Atu->(DbAppend())
                            Wk_Atu->WK_MARCA  := Wk_Main->WK_MARCA
                            Wk_Atu->WK_CODFIL := Wk_Main->WK_FILIAL
                            Wk_Atu->WK_FASE   := Wk_Main->WK_FASE
                            Wk_Atu->WK_PROC   := Wk_Main->WK_PROC
                            Wk_Atu->WK_OBS    := Wk_Main->WK_OBS

                            If lIntermed
                               Wk_Atu->WK_FILIAL := If(Wk_Main->WK_FILIAL == cFilBr, STR0035,STR0036) //"Brasil"###"Off-Shore"
                            EndIf
                            Wk_Main->(DbSkip())
                         EndDo
                      EndIf
              EndCase

         Case cBotao $ (BT_DET+"/"+BT_ITEM)

              Wk_Main->(DbSetOrder(1))
              If !Empty(Wk_Geral->WK_SEQUEN)
                 If Wk_Main->(DbSeek(Wk_Field->WK_CMPID+Wk_Geral->WK_SEQUEN))
                    Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CAMPO  == Wk_Field->WK_CMPID .And.;
                                                     Wk_Main->WK_SEQUEN == Wk_Geral->WK_SEQUEN

                       If (Wk_Main->WK_RECNO  == Wk_Geral->WK_RECNO)
                          Wk_Atu->(DbAppend())
                          Wk_Atu->WK_MARCA  := Wk_Main->WK_MARCA
                          Wk_Atu->WK_CODFIL := Wk_Main->WK_FILIAL
                          Wk_Atu->WK_FASE   := Wk_Main->WK_FASE                          
                          Wk_Atu->WK_PROC   := Wk_Main->WK_PROC
                          Wk_Atu->WK_OBS    := Wk_Main->WK_OBS
                          If lIntermed
                             Wk_Atu->WK_FILIAL := If(Wk_Main->WK_FILIAL == cFilBr, STR0035,STR0036) //"Brasil"###"Off-Shore"
                          EndIf
                       EndIf
                       Wk_Main->(DbSkip())
                    EndDo
           	     EndIf
              Else
                 If Wk_Main->(DbSeek(Wk_Field->WK_CMPID))
                    Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CAMPO  == Wk_Field->WK_CMPID 

                       If (Wk_Main->WK_RECNO  == Wk_Geral->WK_RECNO)
                          Wk_Atu->(DbAppend())
                          Wk_Atu->WK_MARCA  := Wk_Main->WK_MARCA
                          Wk_Atu->WK_FASE   := Wk_Main->WK_FASE
                          Wk_Atu->WK_PROC   := Wk_Main->WK_PROC
                          Wk_Atu->WK_OBS    := Wk_Main->WK_OBS
                          Wk_Atu->WK_CODFIL := Wk_Main->WK_FILIAL
                          If lIntermed
                             Wk_Atu->WK_FILIAL := If(Wk_Main->WK_FILIAL == cFilBr, STR0035,STR0036) //"Brasil"###"Off-Shore"
                          EndIf
                       EndIf
                       Wk_Main->(DbSkip())
                    EndDo
           	     EndIf
              EndIf
      EndCase   
   EndIf

   cTitulo := STR0037 //"Controle de Atualizações - Replicações"
   Wk_Atu->(DbSetOrder(2))
   Wk_Atu->(DbGoTop())

   Define MsDialog oDlg Title cTitulo From 9,0 To 30,60 Of oMainWnd

       oDlg:lEscClose  := .f.

       @ 00,00 MsPanel oAtuPanel Prompt "" Size 400,15 of oDlg
       @ 01,01 BUTTON oBtMk PROMPT STR0034 ; //"Marca/Desmarca Todos"
                                              SIZE 068,10 ACTION AxMarca(BT_ATU) Of oAtuPanel Pixel
       aPosDlg := PosDlg(oDlg)
       aPosDlg[1] += 13

       If lIntermed
          aCmpAtu := {{"WK_MARCA","","  "},;
                      {{||Wk_Atu->WK_PROC}  ,"",STR0038},; //"Processo"
                      {{||Wk_Atu->WK_FILIAL},"",STR0039}  ,; //"Filial"
                      {{||Wk_Atu->WK_OBS}   ,"",STR0040}} //"Obsevação"
       Else
          aCmpAtu := {{"WK_MARCA","","  "},;
                      {{||Wk_Atu->WK_PROC},"",STR0038 },; //"Processo"
                      {{||Wk_Atu->WK_OBS} ,"",STR0040}} //"Obsevação"
       EndIf                            
       
       oBrowseAtu := MsSelect():New("Wk_Atu","WK_MARCA",,aCmpAtu,@lInverte,@cMarca,;
                                                        {aPosDlg[1],aPosDlg[2],aPosDlg[3],aPosDlg[4]},,,oDlg)                                 
       
	   oAtuPanel:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
       oBrowseAtu:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	   
   Activate MsDialog oDlg On Init (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) Centered //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   If nOpca = 1
     If lCall // Chamada pelo botão marca/desmarca todos.
         Do Case
            Case cBotao == BT_CAPA

                 /* Neste ponto o sistema irá realizar a leitura de todos os registros da
                    Wk_Atu, para tratar as localidades (destinos) marcados pelo usuário. */

                 nRec := Wk_Field->(Recno())

                 Wk_Field->(DbGoTop())
                 Do While Wk_Field->(!Eof())

                    Wk_Atu->(DbGoTop())
                    Do While Wk_Atu->(!Eof())
                       Wk_Main->(DbSetOrder(2))
                       If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+Wk_Field->WK_CMPID))
                          Wk_Main->WK_MARCA  := Wk_Atu->WK_MARCA

                          If !lTemItemMarcado
                             lTemItemMarcado := !Empty(Wk_Main->WK_MARCA)
                          EndIf
                       EndIf

                       Wk_Atu->(DbSkip())
                    EndDo

                    Wk_Field->WK_MARCA := If(lTemItemMarcado,cMarca,Space(2))
                    lTemItemMarcado :=.f.

                    Wk_Field->(DbSkip())
                 EndDo

                 Wk_Field->(DbGoTo(nRec))
                 
            Case cBotao == BT_DET

                 nRec := Wk_Field->(Recno())

                 Wk_Field->(DbGoTop())
                 Do While Wk_Field->(!Eof())

                    Wk_Atu->(DbGoTop())
                    Do While Wk_Atu->(!Eof())

                       If !Empty(Wk_Geral->WK_SEQUEN) // Registros referentes a itens.

                          Wk_Main->(DbSetOrder(2))
                          If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+Wk_Field->WK_CMPID+;
                                                                                Wk_Geral->WK_SEQUEN))
                             Wk_Main->WK_MARCA  := Wk_Atu->WK_MARCA
                             If !lTemItemMarcado
                                lTemItemMarcado := !Empty(Wk_Main->WK_MARCA)
                             EndIf
                          EndIf
                       Else

                          Wk_Main->(DbSetOrder(4))
                          If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+;
                                                                Wk_Geral->WK_CODCOM+Wk_Field->WK_CMPID))

                             Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_FILIAL == Wk_Atu->WK_CODFIL   .And.;
                                                              Wk_Main->WK_PROC   == Wk_Atu->WK_PROC     .And.;
                                                              Wk_Main->WK_FASE   == Wk_Atu->WK_FASE     .And.;
                                                              Wk_Main->WK_CODCOM == Wk_Geral->WK_CODCOM .And.;
                                                              Wk_Main->WK_CAMPO  == Wk_Field->WK_CMPID

                                If Wk_Main->WK_RECNO == Wk_Geral->WK_RECNO
                                   
                                   Wk_Main->WK_MARCA  := Wk_Atu->WK_MARCA
                                   If !lTemItemMarcado
                                      lTemItemMarcado := !Empty(Wk_Main->WK_MARCA)
                                   EndIf
                                   Exit
                                EndIf
                                Wk_Main->(DbSkip())
                             EndDo
                          EndIf
                       EndIf
                       Wk_Atu->(DbSkip())
                    EndDo

                    Wk_Field->WK_MARCA := If(lTemItemMarcado,cMarca,Space(2))
                    lTemItemMarcado :=.f.
                    Wk_Field->(DbSkip())
                 EndDo

                 Wk_Field->(DbGoTo(nRec))

            Case (cBotao $ BT_ITEM+"/"+BT_COMP)

                 nRec := Wk_Geral->(Recno())

                 cOldFilter := Wk_Field->(DbFilter())
                 bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

                 Wk_Geral->(DbGoTop())
                 Do While Wk_Geral->(!Eof())

                    If AllTrim(Wk_Geral->WK_CAMPOS) $ STR0028 //"Registro excluido./Registro novo."

                       Wk_Atu->(DbGoTop())
                       Do While Wk_Atu->(!Eof())
                          Wk_Main->(DbSetOrder(4))
                          If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+;
                                              Wk_Geral->WK_CODCOM))

                             Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_FILIAL == Wk_Atu->WK_CODFIL   .And.;
                                                              Wk_Main->WK_PROC   == Wk_Atu->WK_PROC     .And.;
                                                              Wk_Main->WK_FASE   == Wk_Atu->WK_FASE     .And.;
                                                              Wk_Main->WK_CODCOM == Wk_Geral->WK_CODCOM 

                                If Wk_Main->WK_RECNO == Wk_Geral->WK_RECNO
                                   Wk_Main->WK_MARCA := Wk_Atu->WK_MARCA

                                   If !lTemItemMarcado
                                      lTemItemMarcado := !Empty(Wk_Main->WK_MARCA)
                                   EndIf
                                EndIf
                                Wk_Main->(DbSkip())
                             EndDo
                          EndIf

                          Wk_Atu->(DbSkip())
                       EndDo
                       
                       /*
                       Wk_Atu->(DbGoTop())
                       Do While Wk_Atu->(!Eof())
                       
                          Wk_Main->(DbSetOrder(3))
                          If Wk_Main->(DbSeek(Wk_Geral->WK_CODCOM))
                          
                             Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CODCOM == Wk_Geral->WK_CODCOM

                                If Wk_Main->WK_RECNO  == Wk_Geral->WK_RECNO
                                   Wk_Main->WK_MARCA := Wk_Atu->WK_MARCA
                                EndIf

                                If !lTemItemMarcado
                                   lTemItemMarcado := !Empty(Wk_Main->WK_MARCA)
                                EndIf
                                Wk_Main->(DbSkip())
                             EndDo
                          EndIf
                          Wk_Atu->(DbSkip())
                       EndDo
                       */
                       
                       Wk_Geral->WK_MARCA := If(lTemItemMarcado,cMarca,Space(2))
                       lTemItemMarcado    := .f.

                       Wk_Geral->(DbSkip())
                       Loop
                    EndIf

                    cTipo := If(cBotao==BT_ITEM,REG_ITEM,REG_COMP)

                    Wk_Field->(DbClearFilter())
                    Wk_Field->(DbSetFilter({|| Str(Wk_Field->WK_RECNO,7,0) == Str(Wk_Geral->WK_RECNO,7,0) .And. ;
                                                   Wk_Field->WK_TIPO == cTipo},;
                                                   "Str(Wk_Field->WK_RECNO,7,0) == '"+Str(Wk_Geral->WK_RECNO,7,0)+"' .And. "+;
                                                   "Wk_Field->WK_TIPO == '"+cTipo+"'"))                    
                    Wk_Field->(DbGoTop())
                    Do While Wk_Field->(!Eof())

                       Wk_Atu->(DbGoTop())
                       Do While Wk_Atu->(!Eof())
                          
                          If !Empty(Wk_Geral->WK_SEQUEN)                          
                             Wk_Main->(DbSetOrder(2))
                             If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+Wk_Field->WK_CMPID+;
                                                                                   Wk_Geral->WK_SEQUEN))
                                Wk_Main->WK_MARCA  := Wk_Atu->WK_MARCA
                                If !lTemItemMarcado
                                   lTemItemMarcado := !Empty(Wk_Main->WK_MARCA)
                                EndIf
                             EndIf
                          Else
                             Wk_Main->(DbSetOrder(4))                          
                             If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+;
                                                                   Wk_Geral->WK_CODCOM+Wk_Field->WK_CMPID))
                                Wk_Main->WK_MARCA  := Wk_Atu->WK_MARCA
                                If !lTemItemMarcado
                                   lTemItemMarcado := !Empty(Wk_Main->WK_MARCA)
                                EndIf
                             EndIf
                          EndIf
                         
                          Wk_Atu->(DbSkip())
                       EndDo

                       Wk_Field->WK_MARCA := If(lTemItemMarcado,cMarca,Space(2))
                       lTemItemMarcado    := .f.

                       If !lTemCampoMarcado
                          lTemCampoMarcado := !Empty(Wk_Field->WK_MARCA)
                       EndIf

                       Wk_Field->(DbSkip())
                    EndDo

                    Wk_Field->(DbClearFilter())
                    If !Empty(cOldFilter)
                       Wk_Field->(DbSetFilter(bOldFilter,cOldFilter))
                       Wk_Field->(DbGoTop())
                    EndIf

                    Wk_Geral->WK_MARCA := If(lTemCampoMarcado,cMarca,Space(2))
                    lTemCampoMarcado := .f.

                    Wk_Geral->(DbSkip())
                 EndDo

                 Wk_Geral->(DbGoTo(nRec))
         EndCase

      ElseIf !lCall

         Wk_Atu->(DbGoTop())
         Do While Wk_Atu->(!Eof())

            Do Case
               Case cBotao == BT_ITEM
                    Wk_Main->(DbSetOrder(2))
                    If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+Wk_Field->WK_CMPID+;
                                                                                          Wk_Geral->WK_SEQUEN))
                       If Wk_Main->WK_RECNO == Wk_Field->WK_RECNO
                          Wk_Main->WK_MARCA := Wk_Atu->WK_MARCA
                       EndIf
                    EndIf

               Case cBotao $ BT_DET+"/"+BT_COMP           
                    If !Empty(Wk_Geral->WK_SEQUEN)

                       // Atualiza a wk_main. (Work Final com as informações para atualização nas demais filiais).
                       Wk_Main->(DbSetOrder(2))
                       If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+;
                                           Wk_Field->WK_CMPID+Wk_Geral->WK_SEQUEN))

                          Wk_Main->WK_MARCA := Wk_Atu->WK_MARCA
                       EndIf
                    Else
                                    
                       If cBotao == BT_DET
                          Wk_Main->(DbSetOrder(4))
                          If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+Wk_Geral->WK_CODCOM+Wk_Field->WK_CMPID))
                             Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_FILIAL == Wk_Atu->WK_CODFIL   .And.;
                                                              Wk_Main->WK_PROC   == Wk_Atu->WK_PROC     .And.;
                                                              Wk_Main->WK_FASE   == Wk_Atu->WK_FASE     .And.;
                                                              Wk_Main->WK_CODCOM == Wk_Geral->WK_CODCOM .And.;
                                                              Wk_Main->WK_CAMPO  == Wk_Field->WK_CMPID

                                If Wk_Main->WK_RECNO == Wk_Field->WK_RECNO
                                   Wk_Main->WK_MARCA := Wk_Atu->WK_MARCA
                                EndIf
                                Wk_Main->(DbSkip())
                             EndDo
                          EndIf
                       Else
                          Wk_Main->(DbSetOrder(4))               
                          If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+Wk_Geral->WK_CODCOM))
                             Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_FILIAL == Wk_Atu->WK_CODFIL   .And.;
                                                              Wk_Main->WK_PROC   == Wk_Atu->WK_PROC     .And.;
                                                              Wk_Main->WK_FASE   == Wk_Atu->WK_FASE     .And.;
                                                              Wk_Main->WK_CODCOM == Wk_Geral->WK_CODCOM

                                If Wk_Main->WK_RECNO == Wk_Geral->WK_RECNO
                                   Wk_Main->WK_MARCA := Wk_Atu->WK_MARCA
                                EndIf
                                Wk_Main->(DbSkip())
                             EndDo
                          EndIf
                       EndIf
                    EndIf 

               OtherWise // cBotao == BT_CAPA

                    Wk_Main->(DbSetOrder(2))
                    If Wk_Main->(DbSeek(Wk_Atu->WK_CODFIL+Wk_Atu->WK_PROC+Wk_Atu->WK_FASE+Wk_Field->WK_CMPID))
                       If Wk_Main->WK_RECNO == Wk_Field->WK_RECNO
                          Wk_Main->WK_MARCA := Wk_Atu->WK_MARCA
                       EndIf
                    EndIf
            EndCase
 
            If !lTemItemMarcado
               lTemItemMarcado := !Empty(Wk_Atu->WK_MARCA)
            EndIf

            Wk_Atu->(DbSkip())
         EndDo

         If cBotao == BT_COMP .Or. cBotao == BT_ITEM
            Wk_Geral->WK_MARCA := If(lTemItemMarcado,cMarca,"")
         Else
            Wk_Field->WK_MARCA := If(lTemItemMarcado,cMarca,"")
         EndIf
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : AxValid()
Parametros  : cOpc - Validação da tela principal ou da tela de detalhes.
Retorno     : .t./.f.
Objetivos   : Validações Diversas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/02/2005 - 08:32.
Revisao     :
Obs.        :
*/
*---------------------------*
Static Function AxValid(cOpc)
*---------------------------*
Local lRet:=.t., lItemMarcado := .f.
Local lMarcouItem := .f., lMarcouComplemento := .f., lMarcouCapa := .f.
Local cMsg := "", cCmp :=""
Local j:=0

Begin Sequence

  cOpc := AllTrim(Upper(cOpc))

  Do Case
     Case cOpc == VLD_MAIN
          Wk_Main->(DbGoTop())
          Do While Wk_Main->(!Eof()) .And. !lItemMarcado
             If !Empty(Wk_Main->WK_MARCA)
                lItemMarcado := .t.
             EndIf
             Wk_Main->(DbSkip())
          EndDo
          Wk_Main->(DbGoTop())

          If lItemMarcado
             If (Type("lEE7Auto") <> "L" .Or. !lEE7Auto /*RMD - 22/12/17*/) .And. !MsgYesNo(STR0041,STR0042) //"Confirma a atualização dos dados ?"###"Atenção"
                lRet:=.f.
                Break
             EndIf
          Else
             If Type("lEE7Auto") <> "L" .Or. !lEE7Auto /*RMD - 22/12/17*/
                MsgStop(STR0043,STR0042) //"Não existe(m) campo(s) marcado(s) para atualização."###"Atenção"
             EndIf
             lRet:=.f.
             Break
          EndIf

          /* by jbj - Neste ponto o sistema irá verificar se existe alguma pasta que possua  todos os itens  desmarcados,
                      em caso  positivo irá verificar com o usuário se ele "esqueceu" de marcar  os itens daquela  pasta. 
                      Obs: O tratamento será realizado apenas se o mv que carrega os itens já marcados estiver desligado. */

          If !lLoadMarked
             Wk_Main->(DbGoTop())
             Do While Wk_Main->(!Eof())                
                If !Empty(Wk_Main->WK_MARCA)
                   Do Case 
                      Case !Empty(Wk_Main->WK_SEQUEN) // Refere-se a campo de item.
                           lMarcouItem := .t.
                           
                      Case Empty(Wk_Main->WK_SEQUEN) .And. !Empty(Wk_Main->WK_CODCOM) // Refere-se a campo de complemento.
                           lMarcouComplemento := .t.
                           
                      Case Empty(Wk_Main->WK_SEQUEN) .And. Empty(Wk_Main->WK_CODCOM)  // Refere-se a campoda capa.
                           lMarcouCapa := .t.
                   EndCase
                EndIf
                Wk_Main->(DbSkip())
             EndDo
             Wk_Main->(DbGoTop())

             Do Case
                Case lChangeCapa .And. !lMarcouCapa
                     cMsg := STR0046 //"Nenhum campo alterado na capa do processo foi marcado para replicação. Deseja continuar?"
                Case lChangeItem .And. !lMarcouItem
                     cMsg := STR0047 //"Nenhum campo alterado no(s) item(ns) do processo foi marcado para replicação. Deseja continuar?"
                Case lChangeComplemento .And. !lMarcouComplemento             
                     cMsg := STR0048 //"Nenhum campo alterado no(s) complemento(s) do processo foi marcado para replicação. Deseja continuar?"
             EndCase

             If (Type("lEE7Auto") <> "L" .Or. !lEE7Auto /*RMD - 22/12/17*/) .And. !Empty(cMsg)
                If !MsgYesNo(cMsg,STR0042) //"Atenção"
                   lRet:=.f.
                EndIf
             EndIf
          EndIf

          // Neste ponto o sistema irá acertar o recno de origem e destino dos campos referentes a despesas internacionais.
          For j:=1 To Len(aDespInt)
             cCmp := aDespInt[j][2]
             Wk_Main->(DbSetOrder(1))
             If Wk_Main->(DbSeek(cCmp))
                Wk_Main->WK_RECNO := EEC->(RecNo())
             EndIf
          Next
          Wk_Main->(DbGoTop())

     Case cOpc == VLD_EXIT

          If (Type("lEE7Auto") <> "L" .Or. !lEE7Auto /*RMD - 22/12/17*/) .And.  !MsgYesNo(STR0044,STR0042) //"Deseja realmente sair sem replicar as alterações ?"###"Atenção"
             lRet:=.f.
             Break
          Else
             Wk_Main->(avzap())
          EndIf
  EndCase

End Sequence

Return lRet

/*
Funcao      : AxLoadArray()
Parametros  : cTabela - Nome da tabela para verificação dos campos a serem controlados.
Retorno     : aRet - Array com os nomes dos campos que deverão ser analisados.
Objetivos   : Carregar os arrays com os campos que deverão ser analisados após as alterações.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/02/2005 - 10:01.
Revisao     :
Obs.        :
*/
*----------------------------------------------------*
Static Function AxLoadArray(cTabela,aCmp,aNaoComparar)
*----------------------------------------------------*
Local j:=0, k:=0
Local aOrd:= SaveOrd("SX3")
Private aRet := {}

Begin Sequence

   cTabela := AllTrim(Upper(cTabela))

   SX3->(DbSetOrder(1))

   Do Case
      Case !(cTabela $ "EET/EXL") //* Para as demais tabelas, o tratamento é genérico.  

           For j:= 1 To Len(aCmp)
              If aScan(aNaoComparar,aCmp[j]) = 0
                 If aScan(aCmpDespInt,aCmp[j]) = 0 // Verifica se o campo é utilizado na rotina de Desp. Inter.
                    aAdd(aRet,aCmp[j])
                 EndIf
              EndIf
           Next

           /* Para os tratamentos da capa  do embarque, o sistema  verifica os  campos  pertencentes
              os tratamentos realizados pelo botão 'faturamento', controlados pelo array aItemFatura
              no eecae102.prw */

           If cTabela == "EEC"
              For k:=1 To Len(aItemFatura)
                 If aScan(aRet,AllTrim(aItemFatura[k])) = 0 .And. !(aItemFatura[k] = "NOUSER") // JPM - 28/03/06 - elemento para não aparecer campos de usuário na enchoice de faturamento.
                    aAdd(aRet,AllTrim(aItemFatura[k]))
                 EndIf
              Next
           EndIf
           
           /* Para os campos de usuário, o sistema irá verificar se o mesmo já está no array de campos
              da enchoice, caso o mesmo não estiver, será adicionado no array de retorno. */

           SX3->(DbSeek(cTabela))
           Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cTabela

              /* Os campos memo de usuário, deverão ser adicionados, no array de controle de
                 campos memo. */

              If X3Uso(SX3->X3_USADO) .And. SX3->X3_PROPRI = "U" .And. SX3->X3_TIPO == "M"
                 Sx3->(DbSkip())
                 Loop
              EndIf

              If (X3Uso(SX3->X3_USADO) .And. SX3->X3_PROPRI = "U") .Or.;
                 (X3Uso(SX3->X3_USADO) .And. cTabela == "EEB")

                 If aScan(aNaoComparar,SX3->X3_CAMPO)  = 0 .And.;
                    aScan(aRet,AllTrim(SX3->X3_CAMPO)) = 0 .And.;
                    aScan(aCmpDespInt,SX3->X3_CAMPO) = 0 // Verifica se o campo é utilizado na rotina de Desp. Inter.

                    // Inclui no array de retorno.
                    aAdd(aRet,AllTrim(SX3->X3_CAMPO))
                 EndIf
              EndIf
              SX3->(DbSkip())
           EndDo

           /* Para os casos em que a digitação do peso líquido total e do peso bruto total está
              habilitada, o sistema irá disponibilizar os campos para replicação. */

           If lLibPes .And. cTabela $ "EE8/EE9"
              aAdd(aRet,cTabela+"_PSLQTO")
              aAdd(aRet,cTabela+"_PSBRTO")
           EndIf

      Case cTabela == "EXL"

           /* Tratamentos para verificar os campos da tabela de dados complementares do embarque. (EXL)
              O sistema irá realizar tratamentos diferenciados para campos do EXL que correspondem 
              apenas à complementos e campos do EXL referentes a despesas internacionais. */

           SX3->(DbSeek("EXL"))
           Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EXL"

              /* Os campos memo de usuário, deverão ser adicionados, no array de controle de
                 campos memo. */

              If X3Uso(SX3->X3_USADO) .And. SX3->X3_PROPRI = "U" .And. SX3->X3_TIPO == "M"
                 Sx3->(DbSkip())
                 Loop
              EndIf

              If X3Uso(SX3->X3_USADO)
                 If aScan(aNaoComparar,SX3->X3_CAMPO)  = 0 .And.;
                    aScan(aRet,AllTrim(SX3->X3_CAMPO)) = 0

                    // Inclui no array de retorno.
                    aAdd(aRet,AllTrim(SX3->X3_CAMPO))
                 EndIf
              EndIf
              SX3->(DbSkip())
           EndDo

           /* Verifica se existe algum campo relativo a despesas internacionais que não está incluido
              no array.*/
           For j:= 1  To Len(aCmpDespInt)
              If aScan(aRet,aCmpDespInt[j]) = 0
                 aAdd(aRet,aCmpDespInt[j])
              EndIf
           Next

      Case cTabela == "EET"

           // ** Tratamentos específicos para a tabela de despesas.
           SX3->(DbSeek("EET"))
           Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EET"

              /* Os campos memo de usuário, deverão ser adicionados, no array de controle de
                 campos memo. */

              If X3Uso(SX3->X3_USADO) .And. SX3->X3_PROPRI = "U" .And. SX3->X3_TIPO == "M"
                 Sx3->(DbSkip())
                 Loop
              EndIf

              If X3Uso(SX3->X3_USADO)
                 If aScan(aNaoComparar,SX3->X3_CAMPO) = 0
                    aAdd(aRet,SX3->X3_CAMPO)
                 EndIf
              EndIf
              SX3->(DbSkip())
           EndDo
   EndCase  

End Sequence

If EasyEntryPoint("EECAX100")
   ExecBlock("EECAX100",.F.,.F.,"AXLOADARRAY")
EndIf

RestOrd(aOrd,.t.)

Return aRet

/*
Funcao      : AxTrataObj
Parametros  : nOption
Retorno     : .t.
Objetivos   : Exibir/Ocultar Objetos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/02/2005 - 17:28.
Revisao     :
Obs.        :
*/
*---------------------------------*
Static Function AxTrataObj(nOption)
*---------------------------------*
Local lRet:=.t.

Begin Sequence

   Do Case
      Case oFld:aDialogs[nOption]:cCaption = STR0018 //"&Capa"

           Wk_Field->(DbClearFilter())
           Wk_Field->(DbSetFilter({|| Wk_Field->WK_TIPO == REG_CAPA},"Wk_Field->WK_TIPO == '"+REG_CAPA+"'"))
           
           Wk_Field->(DbSetOrder(1))
           Wk_Field->(DbGoTop())

           oBrowseField:oBrowse:Refresh()
           
      Case oFld:aDialogs[nOption]:cCaption = STR0019 //"&Itens"

           Wk_Geral->(DbClearFilter())
           Wk_Geral->(DbSetFilter({|| Wk_Geral->WK_TABELA $ "EE8/EE9"},"Wk_Geral->WK_TABELA $ 'EE8/EE9'"))
           Wk_Geral->(DbGoTop())

           oBrowseItem:oBrowse:Refresh()

      Case oFld:aDialogs[nOption]:cCaption = STR0020 //"C&omplementos"

           Wk_Geral->(DbClearFilter())
           Wk_Geral->(DbSetFilter({|| Wk_Geral->WK_TABELA $ "EEB/EET/EEN/EEJ/EXL"},"Wk_Geral->WK_TABELA $ 'EEB/EET/EEN/EEJ/EXL'"))
           Wk_Geral->(DbGoTop())

           oBrowseComp:oBrowse:Refresh()
   End Case

End Sequence

Return lRet

/*
Funcao      : AxSetObj
Parametros  : Nenhum
Retorno     : .t.
Objetivos   : Tratar exibição inicial dos objetos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/02/2005 - 08:19.
Revisao     :
Obs.        :
*/
*------------------------*
Static Function AxSetObj()
*------------------------*
Local lRet:=.t.

Begin Sequence

   oFld:Align := CONTROL_ALIGN_ALLCLIENT

   If lChangeCapa
      oPanelCapa:Align := CONTROL_ALIGN_TOP

      Wk_Field->(DbClearFilter())
      Wk_Field->(DbSetFilter({|| Wk_Field->WK_TIPO == REG_CAPA},"Wk_Field->WK_TIPO == '"+REG_CAPA+"'"))

      Wk_Field->(DbSetOrder(1))
      Wk_Field->(DbGoTop())

      oBrowseField:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oBrowseField:oBrowse:Refresh()
   EndIf

   If lChangeItem
      If !lChangeCapa
         oBrowseField:oBrowse:Hide()
      EndIf

      oPanelItem:Align := CONTROL_ALIGN_TOP

      Wk_Geral->(DbClearFilter())
      Wk_Geral->(DbSetFilter({|| Wk_Geral->WK_TABELA $ "EE8/EE9"},"Wk_Geral->WK_TABELA $ 'EE8/EE9'"))
      Wk_Geral->(DbGoTop())

      oBrowseItem:oBrowse:Refresh()
      oBrowseItem:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   EndIf   
   
   If lChangeComplemento .And. !lChangeItem
      If !lChangeCapa
         oBrowseField:oBrowse:Hide()
      EndIf

      oPanelComplemento:Align := CONTROL_ALIGN_TOP

      Wk_Geral->(DbClearFilter())
      Wk_Geral->(DbSetFilter({|| Wk_Geral->WK_TABELA $ "EEB/EET/EEN/EEJ/EXL"},"Wk_Geral->WK_TABELA $ 'EEB/EET/EEN/EEJ/EXL'"))
      Wk_Geral->(DbGoTop())

      oBrowseComp:oBrowse:Refresh()
      oBrowseComp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

   ElseIf lChangeComplemento
      oPanelComplemento:Align := CONTROL_ALIGN_TOP
      oBrowseComp:oBrowse:Refresh()
      oBrowseComp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   EndIf

End Sequence

Return lRet

/*
Funcao      : AxMarca
Parametros  : cBotao - Indica de qual botão foi acionada.
Retorno     : .t.
Objetivos   : Marca/Desmarca Registros.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/02/2005 - 12:54.
Revisao     :
Obs.        :
*/
*-----------------------------*
Static Function AxMarca(cBotao)
*-----------------------------*
Local bMarca, bForMarca, bDesMarca, bForDesMarca
Local lRet:=.t.
Local cTipo

Begin Sequence

   cBotao := AllTrim(Upper(cBotao))

   Do Case
      Case cBotao == BT_CAPA

           Wk_Field->(DbGoTop())
           lMarca := Empty(Wk_Field->WK_MARCA)

           /* Chama tela de localidades, os locais onde o usuário selecionou para 
              replicar a alteração irá valer para todos os registros. */

           If lMarca
              If !AxAtuTela(.t.,cBotao)
                 lRet:=.f.
                 Break
              EndIf
           Else

              Wk_Main->(DbSetOrder(1))

              nRec := Wk_Field->(RecNo())
              Wk_Field->(DbGoTop())
              Do While Wk_Field->(!Eof())

                 Wk_Field->WK_MARCA := Space(2)

                 // Atualiza a wk_main. (Work Final com as informações para atualização nas demais filiais).
                 If Wk_Main->(DbSeek(Wk_Field->WK_CMPID))
                    Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CAMPO  == Wk_Field->WK_CMPID
                       Wk_Main->WK_MARCA := Space(2)
                       Wk_Main->(DbSkip())
                    EndDo
                 EndIf

                 Wk_Field->(DbSkip())
              EndDo
              Wk_Field->(DbGoTo(nRec))
           EndIf

      Case cBotao == BT_DET

           Wk_Field->(DbGoTop())
           lMarca := Empty(Wk_Field->WK_MARCA)

           /* Chama tela de localidades, os locais onde o usuário selecionou para 
              replicar a alteração irá valer para todos os registros. */

           If lMarca
              If !AxAtuTela(.t.,cBotao)
                 lRet:=.f.
                 Break
              EndIf
           Else

              nRec := Wk_Field->(RecNo())
              
              Wk_Field->(DbGoTop())
              Do While Wk_Field->(!Eof())

                 Wk_Field->WK_MARCA := Space(2)

                 If !Empty(Wk_Geral->WK_SEQUEN)
                    // Atualiza a wk_main. (Work Final com as informações para atualização nas demais filiais).
                    Wk_Main->(DbSetOrder(1))
                    If Wk_Main->(DbSeek(Wk_Field->WK_CMPID+Wk_Geral->WK_SEQUEN))
                       Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CAMPO  == Wk_Field->WK_CMPID .And.;
                                                        Wk_Main->WK_SEQUEN == Wk_Geral->WK_SEQUEN
                          Wk_Main->WK_MARCA := Space(2)
                          Wk_Main->(DbSkip())
                       EndDo
                    EndIf
                 Else
                    Wk_Main->(DbSetOrder(3))
                    If Wk_Main->(DbSeek(Wk_Geral->WK_CODCOM))
                       Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CODCOM == Wk_Geral->WK_CODCOM
                          If Wk_Main->WK_RECNO == Wk_Geral->WK_RECNO                                  
                             Wk_Main->WK_MARCA := Space(2)
                          EndIf
                          Wk_Main->(DbSkip())
                       EndDo
                    EndIf
                 EndIf
                 
                 Wk_Field->(DbSkip())
              EndDo
              Wk_Field->(DbGoTo(nRec))
           EndIf

      Case cBotao == BT_ITEM .Or. cBotao == BT_COMP

           nRec := Wk_Geral->(RecNo())

           Wk_Geral->(DbGoTop())
           lMarca := Empty(Wk_Geral->WK_MARCA)

           /* Chama tela de localidades, os locais onde o usuário selecionou 
              para replicar a alteração irá valer para todos os registros. */

           If lMarca
              If !AxAtuTela(.t.,cBotao)
                 lRet:=.f.
                 Break
              EndIf
           Else

              cOldFilter := Wk_Field->(DbFilter())
              bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

              Do While Wk_Geral->(!Eof())

                 Wk_Geral->WK_MARCA := Space(2)

                 // ** Para os casos de registros incluidos e excluídos.
                 If AllTrim(Wk_Geral->WK_CAMPOS) $ STR0028                 //"Registro excluido./Registro novo."
                    Wk_Main->(DbSetOrder(3))
                    If Wk_Main->(DbSeek(Wk_Geral->WK_CODCOM))
                       Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CODCOM == Wk_Geral->WK_CODCOM
                          Wk_Main->WK_MARCA := Space(2)
                          Wk_Main->(DbSkip())
                       EndDo
                    EndIf
                    Wk_Geral->(DbSkip())
                    Loop
                 EndIf

                 cTipo := If(cBotao==BT_ITEM,REG_ITEM,REG_COMP)

                 Wk_Field->(DbClearFilter())
                 Wk_Field->(DbSetFilter({|| Str(Wk_Field->WK_RECNO,7,0) == Str(Wk_Geral->WK_RECNO,7,0) .And.;
                                            Wk_Field->WK_TIPO == cTipo},;
                                            "Str(Wk_Field->WK_RECNO,7,0) == '"+Str(Wk_Geral->WK_RECNO,7,0)+"' .And. "+;
                                            "Wk_Field->WK_TIPO == '"+cTipo+"'"))

                 Wk_Field->(DbGoTop())
                 Do While Wk_Field->(!Eof())

                    Wk_Field->WK_MARCA := Space(2)

                    If !Empty(Wk_Geral->WK_SEQUEN)
                       Wk_Main->(DbSetOrder(1))
                       If Wk_Main->(DbSeek(Wk_Field->WK_CMPID+Wk_Geral->WK_SEQUEN))
                          Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CAMPO  == Wk_Field->WK_CMPID .And.;
                                                           Wk_Main->WK_SEQUEN == Wk_Geral->WK_SEQUEN
                             Wk_Main->WK_MARCA := Space(2)
                             Wk_Main->(DbSkip())
                          EndDo
                       EndIf
                    Else
                       Wk_Main->(DbSetOrder(3))
                       If Wk_Main->(DbSeek(Wk_Geral->WK_CODCOM))
                          Do While Wk_Main->(!Eof()) .And. Wk_Main->WK_CODCOM == Wk_Geral->WK_CODCOM
                             If Wk_Main->WK_RECNO == Wk_Geral->WK_RECNO
                                Wk_Main->WK_MARCA := Space(2)
                             EndIf
                             Wk_Main->(DbSkip())
                          EndDo
                       EndIf
                    EndIf
                    Wk_Field->(DbSkip())
                 EndDo

                 If !Empty(cOldFilter)
                    Wk_Field->(DbClearFilter())
                    Wk_Field->(DbSetFilter(bOldFilter,cOldFilter))
                    Wk_Field->(DbGoTop())
                 EndIf

                 Wk_Geral->(DbSkip())
              EndDo
              Wk_Geral->(DbGoTo(nRec))
           EndIf

      Case cBotao == BT_ATU

           nRec := Wk_Atu->(Recno())

           Wk_Atu->(DbGoTop())
           lMarca := Empty(Wk_Atu->WK_MARCA)

           Do While Wk_Atu->(!Eof())
              Wk_Atu->WK_MARCA := If(lMarca,cMarca,Space(2))
              Wk_Atu->(DbSkip())
           EndDo

           Wk_Atu->(DbGoTo(nRec))
   EndCase

End Sequence

Return lRet

/*
Funcao      : AxFind.
Parametros  : cBotao - Indica de qual botão foi acionada.
              cOpcao - Opcao de pesquisa.
              cKey   - Texto a ser pesquisado.
Retorno     : .t.
Objetivos   : Pesquisa.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/02/2005 - 15:43.
Revisao     :
Obs.        :
*/
*----------------------------------------*
Static Function AxFind(cBotao,cOpcao,cKey)
*----------------------------------------*
Local lRet:=.t., aOrd:={}

Begin Sequence

   cBotao := AllTrim(Upper(cBotao))
   cOpcao := AllTrim(Upper(cOpcao))
   cKey   := AllTrim(cKey)

   If Empty(cKey)
      lRet:=.f.
      Break
   EndIf

   Do Case
      Case cBotao == BT_CAPA .Or. cBotao == BT_DET
           aOrd:=SaveOrd("Wk_Field")
           If cOpcao == "CAMPO"
              Wk_Field->(DbSetOrder(2))
              Wk_Field->(DbGoTop())
              Wk_Field->(DbSeek(cKey,.t.))
           EndIf

      Case cBotao == BT_ITEMCOMP
           aOrd:=SaveOrd("Wk_Geral")
           aOpcItem:={STR0015,STR0016} //"Sequencia"###"Cod.Produto"

           Do Case
              Case cOpcao == "SEQUENCIA"
                   Wk_Geral->(DbSetOrder(2))
              Case cOpcao == "COD.PRODUTO"
                   Wk_Geral->(DbSetOrder(3))
           EndCase

           Wk_Geral->(DbGoTop())
           Wk_Geral->(DbSeek(cKey,.t.))
   EndCase

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AxCheckCmp.
Parametros  : cCampo - Campo a ser pesquisado na tabela do embarque (EE9/EEC).
Retorno     : .t. - Caso o campo exista na tabela correspondente na fase de embarque.
              .f. - Caso o campo não exista na tabela correspondete na fase de embarque.
Objetivos   : Verificar se o campo passado como parâmetro existe na tabela correspondente em fase
              de embarque.
Autor       : Jeferson Barros Jr.
Data/Hora   : 02/03/2005 - 15:22.
Revisao     :
Obs.        :
*/
*--------------------------------*
Static Function AxCheckCmp(cCampo)
*--------------------------------*
Local lRet:=.f., aOrd:=SaveOrd({"SX3"})

Begin Sequence

   If Empty(cCampo)
      Break
   EndIf

   cCampo := AllTrim(Upper(cCampo))

   Do Case
      Case Left(cCampo,3) == "EE7"
           cCmpToFind := "EEC"+SubStr(cCampo,4)
      Case Left(cCampo,3) == "EE8"
           cCmpToFind := "EE9"+SubStr(cCampo,4)          
   EndCase

   SX3->(DbSetOrder(2))
   If SX3->(DbSeek(cCmpToFind))
      If SX3->X3_CONTEXT <> "V" .Or. (SX3->X3_CONTEXT == "V" .And. SX3->X3_TIPO == "M")
         lRet:=.t.
         Break
      EndIf
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AxFindRecDest.
Parametros  : cWork, cAlias, cCmpCod (Nome do campo do código do complemento).
              aInfoDest - [1] - Filial
                          [2] - Processo
                          [3] - Fase.
                          [4] - RecNo do registro deletado.
Retorno     : Recno no destino.
Objetivos   : Encontrar o recno do registro de destino para controle de replicações de 
              complementos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/03/2005 - 14:54.
Revisao     :
Obs.        :
*/
*-----------------------------------------------------------*
Static Function AxFindRecDest(cWork,cAlias,cCmpCod,aInfoDest)
*-----------------------------------------------------------*
Local aOrd := SaveOrd({cWork,cAlias})
Local nRet := 0, cFil, cProc, cFase, nRecDel, cCod, cCodAux
Local cAliasIt, lTipComChave

Begin Sequence

   cFil    := aInfoDest[1]
   cProc   := aInfoDest[2]
   cFase   := aInfoDest[3]
   nRecDel := aInfoDest[4]
   
   If cFase == OC_PE
      cAliasIt := "EE8"
   Else
      cAliasIt := "EE9"
   EndIf
   lTipComChave := (cAliasIt)->(FieldPos(cAliasIt+"_TIPCOM")) > 0 // JPM - 02/06/05 - Tipo de Comissão por Item
   
   (cAlias)->(DbSetOrder(1))

   Do Case
      Case cAlias == "EEB"
           If nRecDel <> 0
              EEB->(DbGoTo(nRecDel))
              cCod    := EEB->&(cCmpCod)
              cCodAux := EEB->EEB_TIPOAG + If(lTipComChave,EEB->EEB_TIPCOM,"") // JPM
           Else
              cCod    := (cWork)->&(cCmpCod)
              cCodAux := (cWork)->EEB_TIPOAG + If(lTipComChave,(cWork)->EEB_TIPCOM,"") // JPM
           EndIf

           If EEB->(DbSeek(cFil+cProc+cFase+cCod+cCodAux))
              nRet := EEB->(Recno())
           EndIf

      Case cAlias == "EET"

           If nRecDel <> 0
              EET->(DbGoTo(nRecDel))
              cCod    := EET->EET_DESPES
              cCodAux := EET->EET_CODAGE
           Else
              cCod    := (cWork)->EET_DESPES
              cCodAux := (cWork)->EET_CODAGE
           EndIf

           If EET->(DbSeek(cFil+cProc+cFase))
              Do While EET->(!Eof()) .And. EET->EET_FILIAL == cFil  .And.;
                                           EET->EET_PEDIDO == cProc .And.;
                                           EET->EET_OCORRE == cFase

                 If EET->EET_DESPES == cCod .And.;
                    EET->EET_CODAGE == cCodAux
                    nRet := EET->(RecNo())
                    Break
                 EndIf
                 EET->(DbSkip())
              EndDo
           EndIf

      Case cAlias == "EEN"

           If nRecDel <> 0
              EEN->(DbGoTo(nRecDel))
              cCod    := EEN->EEN_IMPORT
              cCodAux := EEN->EEN_IMLOJA
           Else
              cCod    := (cWork)->EEN_IMPORT
              cCodAux := (cWork)->EEN_IMLOJA
           EndIf

           If EEN->(DbSeek(cFil+cProc+cFase+cCod+cCodAux))
              nRet := EEN->(Recno())
           EndIf

      Case cAlias == "EEJ"

           If nRecDel <> 0
              EEJ->(DbGoTo(nRecDel))
              cCod := EEJ->EEJ_CODIGO
           Else
              cCod := (cWork)->EEJ_CODIGO
           EndIf

           If EEJ->(DbSeek(cFil+cProc+cFase))
              Do While EEJ->(!Eof()) .And. EEJ->EEJ_FILIAL == cFil  .And.;
                                           EEJ->EEJ_PEDIDO == cProc .And.;
                                           EEJ->EEJ_OCORRE == cFase

                 If EEJ->EEJ_CODIGO == cCod
                    nRet := EEJ->(RecNo())
                    Break
                 EndIf
                 EEJ->(DbSkip())
              EndDo
           EndIf
   EndCase

End Sequence

RestOrd(aOrd,.t.)

Return nRet

/*
Funcao      : AxCanUpdate
Parametros  : cFil, cProc
Retorno     : .t. - O processo poderá ser atualizado.
              .f. - O processo não poderá ser atualizado.
Objetivos   : Verificar se o embarque poderá ser atualizado.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/03/2005 - 15:38.
Revisao     :
Obs.        :
*/
*-------------------------------------*
Static Function AxCanUpdate(cFil,cProc)
*-------------------------------------*
Local lRet := .t.
Local aOrd:= SaveOrd("EEC")

Begin Sequence

   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(cFil+cProc))
      If EEC->EEC_STATUS == ST_PC // Verifica se o processo está cancelado.
         lRet := .f.
         Break
      EndIf

      /*
      If !Empty(EEC->EEC_DTEMBA) // Verifica se o processo está embarcado.
         lRet := .f.
         Break
      EndIf      
      */
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao          : AX100GrvRpl()
Parametros      : Nenhum
Retorno         : aRetProc - Retorna um array com Filial, Processo e Fase caso o processo tenha sido modificado.
Objetivos       : Gravar as replicações para outros processos( PEDIDO/EMBARQUE/OFF-SHORE ).
Autor           : Alessandro Alves Ferreira - AAF
Data/Hora       : 09/03/05 15:36
Obs.            :
*/
Function AX100GrvRpl(cFil, cProcesso, cFase)
Local lRet:= .F., lAppend := .t.
Local nInd
Local aRetProc:= {}
Local cAlias:= If( Select("WORKIT") > 0,"EE7","EE9")
Local aSaveOrd := SaveOrd({"EE7", "EE8", "EEC", "EE9"})

Private aMemos := {{"EE7_CODMEM","EE7_OBS"},;
                   {"EE7_CODMAR","EE7_MARCAC"},;
                   {"EE7_CODOBP","EE7_OBSPED"},;
                   {"EE7_DSCGEN","EE7_GENERI"},;
                   {"EEC_CODMEM","EEC_OBS"},;
                   {"EEC_CODMAR","EEC_MARCAC"},;
                   {"EEC_CODOBP","EEC_OBSPED"},;
                   {"EEC_DSCGEN","EEC_GENERI"},;
                   {"EE8_DESC"  ,"EE8_VM_DES"},;
                   {"EE9_DESC"  ,"EE9_VM_DES"}}

//** PLB 02/04/07
If EECFlags("AMOSTRA")
   AAdd(aMemos, { "EE8_QUADES", "EE8_DSCQUA" } )
   AAdd(aMemos, { "EE9_QUADES", "EE9_DSCQUA" } )
EndIf
//**

ChkFile("EEC")
ChkFile("EE9")

// ** JPM - 27/07/06
If EasyEntryPoint("EECAX100")
   ExecBlock("EECAX100",.f.,.f.,{"GRV_REPL_INICIO"})
EndIf

Do While !WK_MAIN->( EoF() ) .AND. WK_MAIN->WK_FILIAL == cFil;
                             .AND. WK_MAIN->WK_PROC   == cProcesso;
                             .AND. WK_MAIN->WK_FASE   == cFase
   
   cAlias:= Left(WK_MAIN->WK_CAMPO,3)
   
   If !Empty(WK_MAIN->WK_MARCA)
      lRet:= .T.
      
      If AllTrim(cAlias) == "E"
         cAliasD := If( Left(WK_MAIN->WK_CODCOM,3) == "EE8", "EE9", Left(WK_MAIN->WK_CODCOM,3) )
         
         (cAliasD)->( dbGoTo(WK_MAIN->WK_RECNOD) )
         If !(cAliasD)->( EoF() )
            RecLock(cAliasD,.F.)
            (cAliasD)->( dbdelete() )
            (cAliasD)->( MsUnLock() )
         Endif
         
      ElseIf AllTrim(cAlias) == "I"
         cAliasOr:= AX100WkAlias( Left(WK_MAIN->WK_CODCOM,3) )
         cAliasD := If(cFase == OC_EM .AND. cAliasOr == "WORKIT", "EE9", Left(WK_MAIN->WK_CODCOM,3) )
                 
         //Carrega os dados em um Array
         (cAliasOr)->( dbGoTo(WK_MAIN->WK_RECNO) )
         aDados:= {}
         For nInd:= 1 To (cAliasOr)->( FCount() )
            cCampoD:= cAliasD+SubStr((cAliasOr)->( FieldName(nInd) ),4)
            
            If (cAliasD)->( FieldPos(cCampoD) ) > 0 .AND.;
                          ( !SubStr(cCampoD,5) $ "FILIAL/PREEMB/PEDIDO/OCORRE/PROCES" )// .OR. ( (cAliasOr == "WORKIT" .OR. cAliasOr == "WORKIP") .AND. SubStr(cCampoD,5) == "PEDIDO" ))
               
               aAdd(aDados,{ FieldWBlock( cCampoD, Select(cAliasD)),;//Code-Block para Gravação
                             (cAliasOr)->( FieldGet(nInd) )        })//Informação a gravar
            Endif
         Next

         /* Caso o camplemento já exista no processo de destino o sistema irá apenas atualizar as informações.
            caso contrário o sistema irá adicionar o complemento. */
         lAppend := AxExisteComplemento()

         //Grava Registro
         RecLock(cAliasD,lAppend)
         Eval((cAliasD)->(FieldWBlock(cAliasD+"_FILIAL",Select(cAliasD))),cFil)

         If (cAliasD)->( FieldPos(cAliasD+"_PREEMB") ) > 0
            Eval((cAliasD)->(FieldWBlock(cAliasD+"_PREEMB",Select(cAliasD))),cProcesso)
         Endif
         
         If (cAliasD)->( FieldPos(cAliasD+"_PEDIDO") ) > 0 //.AND. !( cAliasOr == "WORKIT" .OR. cAliasOr == "WORKIP" )
            Eval((cAliasD)->(FieldWBlock(cAliasD+"_PEDIDO",Select(cAliasD))),cProcesso)
         Endif
         
         If (cAliasD)->( FieldPos(cAliasD+"_PROCES") ) > 0
            Eval((cAliasD)->(FieldWBlock(cAliasD+"_PROCES",Select(cAliasD))),cProcesso)
         Endif

         If (cAliasD)->( FieldPos(cAliasD+"_OCORRE") ) > 0
            Eval((cAliasD)->(FieldWBlock(cAliasD+"_OCORRE",Select(cAliasD))),cFase)
         Endif

         aEval(aDados,{|X| Eval(X[1],X[2])})
         (cAliasD)->( MsUnLock() )
      Else
         If WK_MAIN->WK_FASE == OC_EM
            cAliasD:= If(cAlias == "EE7", "EEC", If(cAlias=="EE8","EE9",cAlias) )
         Else
            cAliasD:= cAlias
         EndIf

         nPosMemo:= aScan(aMemos,{|X| X[2] == AllTrim(WK_MAIN->WK_CAMPO)})
         
         If nPosMemo == 0
            (cAlias)->( dbGoTo(WK_MAIN->WK_RECNO) )
            xInfo :=  (cAlias)->( Eval( FieldBlock(WK_MAIN->WK_CAMPO)))

            If AllTrim(Upper(Wk_Main->WK_CAMPO)) $ "EE8_PRENEG"
               cCampoD := "EE9_PRECO"
            Else
               cCampoD:= cAliasD+SubStr(WK_MAIN->WK_CAMPO,4)
            EndIf

            If !Empty(WK_MAIN->WK_RECNOD)
               (cAliasD)->(dbGoTo(WK_MAIN->WK_RECNOD))
               If !(cAliasD)->(EoF())
                  RecLock(cAliasD,.F.)
                  Eval(FieldWBlock(cCampoD,Select(cAliasD)),xInfo)
                  (cAliasD)->(MsUnlock())
               Endif
            Else
               AxAddComplemento(cFil,cProcesso,cFase)
            EndIf
         Else
            (cAlias)->(dbGoTo(WK_MAIN->WK_RECNO))
            cMemoInfo := (cAlias)->(MSMM(Eval(FieldBlock(aMemos[nPosMemo][1])),;
                                         TAMSX3(aMemos[nPosMemo][2])[1],,,LERMEMO))

            cCampoD:= cAliasD+SubStr(aMemos[nPosMemo][1],4)

            If !Empty(WK_MAIN->WK_RECNOD)
               (cAliasD)->( dbGoTo(WK_MAIN->WK_RECNOD))
               If !(cAliasD)->(EoF())
                  RecLock(cAliasD,.F.)
                  MSMM(Eval(FieldWBlock(cCampoD,Select(cAliasD))),,,,EXCMEMO)
                  MSMM(,TAMSX3(cAliasD+SubStr(WK_MAIN->WK_CAMPO,4))[1],,cMemoInfo,INCMEMO,,,cAliasD,cCampoD)
                  (cAliasD)->(MsUnlock())
               EndIf
            Else
               AxAddComplemento(cFil,cProcesso,cFase)
            EndIf
         Endif
      Endif
   Endif

   WK_MAIN->(DbSkip())
EndDo

if lRet
   aRetProc := {cFil,cProcesso,cFase}
Endif

RestOrd(aSaveOrd, .T.)

Return aRetProc

/*
Funcao          : AX100WkAlias()
Parametros      : cAlias - Tabela a qual se deseja retornar a work.
Retorno         : Alias da Work
Objetivos       : Retorna o alias da work para a tabela especificada.
Autor           : Alessandro Alves Ferreira - AAF
Data/Hora       : 10/03/05 11:00
Obs.            :
*/
Function AX100WkAlias(cAlias)
Local aWorks:= { {"EE8"   ,"EE9"   ,"EEB"   ,"EET"   ,"EEN"   ,"EEJ"   ,"EEK"   ,"EXB"    ,"EEM"   ,"EXM"     },;
                 {"WORKIT","WORKIP","WORKAG","WORKDE","WORKNO","WORKIN","WORKEM","WORKDOC","WORKNF","WorkCalc"} }

Return aWorks[2][aScan(aWorks[1],cAlias)]

/*
Funcao          : AX100GrvProcs()
Parametros      : aProcessos - Processos a serem acertados.
                  aProcessos[][1] - Filial
                  aProcessos[][2] - Processo
                  aProcessos[][3] - Fase
Retorno         : .T.
Objetivos       : Acertar a base de dados com as gravações das alterações replicadas para off-shore.
Autor           : Alessandro Alves Ferreira - AAF
Data/Hora       : 10/03/05 11:00
Obs.            :
*/
Function AX100GrvProcs(aProcessos)
Local nInd, i, aOrd:= SaveOrd({"EE7","EEC"})
Local cFase := If(Select("WORKIT") > 0,OC_PE,OC_EM)
Local aMem:= {}, aMemEXL := {}

//Guarda Filial Anterior
Local cFilOld := cFilAnt
Local nRecSM0 := SM0->( RecNo() )
Local cEmpresa:= SM0->M0_CODIGO
Private lAx100 := .T.

If cFase == OC_PE
   cAlias:= "EE7"
Else
   cAlias:= "EEC"
   
   //Guarda dados do EXL
   For nInd := 1 TO EXL->(FCount())
      aAdd(aMemEXL,{ MemVarBlock( EXL->( FieldName(nInd) ) ), M->( FieldGet(nInd) ) })
   Next nInd
Endif

(cAlias)->( dbSetOrder(1) )

//Guarda dados da Capa
For nInd := 1 TO (cAlias)->(FCount())
   aAdd(aMem,{ MemVarBlock( (cAlias)->( FieldName(nInd) ) ) } )
   aAdd(aMem[Len(aMem)], Eval(aMem[Len(aMem)][1]) )
Next nInd

AP104TrataWorks(.T.,cFase)//Troca o alias das Works atualmente abertas.

For nInd := 1 To Len(aProcessos)
   //Posiciona na Filial.
   SM0->( dbGoTop() )
   Do While !SM0->( EoF() )
      If SM0->M0_CODIGO == cEmpresa .AND. AvGetM0Fil() == aProcessos[nInd][1]
         EXIT
      Endif
      SM0->( dbSkip() )
   EndDo
   
   cFilAnt:= aProcessos[nInd][1]    //Seta a filial da função xFilial.
   cAliasD:= If(aProcessos[nInd][3]==OC_PE,"EE7","EEC")

   IncProc(STR0045+aProcessos[nInd][1]+" - "+aProcessos[nInd][2]) //"Atualizando: Filial "
   
   If !(cAliasD)->( dbSeek( aProcessos[nInd][1]+aProcessos[nInd][2]+aProcessos[nInd][3] ))
      Loop
   Endif
   
   //Carrega os campos
   For I := 1 TO (cAliasD)->(FCount())
      M->&((cAliasD)->(FieldName(I))) := (cAliasD)->(FieldGet(I))
   Next
   
   Do Case
      Case aProcessos[nInd][3] == OC_PE
         dbSelectArea("EE7")

         //Carrega os campos Memo
         M->EE7_OBS    :=EE7->(MSMM(EE7_CODMEM,TAMSX3("EE7_OBS")[1],,,LERMEMO))
         M->EE7_MARCAC :=EE7->(MSMM(EE7_CODMAR,TAMSX3("EE7_MARCAC")[1],,,LERMEMO))
         M->EE7_OBSPED :=EE7->(MSMM(EE7_CODOBP,TAMSX3("EE7_OBSPED")[1],,,LERMEMO))
         M->EE7_GENERI :=EE7->(MSMM(EE7_DSCGEN,TAMSX3("EE7_GENERI")[1],,,LERMEMO))
         
         aNomWorks:= AP102SetWorks()                           //Carrega novas Works para o Processo.
         AP102LoadPed(aProcessos[nInd][2], aProcessos[nInd][1])//Carrega os dados do Processo.
         AP102SetGrvPed(.F.)                                   //Grava o Processo.
         AP102DelWorks(aNomWorks)                              //Exclui Works.
         
      Case aProcessos[nInd][3] == OC_EM
         dbSelectArea("EEC")
         
         //Carrega os campos do EXL
         For I := 1 TO EXL->(FCount())
            M->&(EXL->(FieldName(I))) := EXL->(FieldGet(I))
         Next
         
         M->EEC_MARCAC := MSMM(EEC->EEC_CODMAR,AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
         M->EEC_GENERI := MSMM(EEC->EEC_DSCGEN,AVSX3("EEC_GENERI",AV_TAMANHO),,,LERMEMO)
         M->EEC_OBSPED := MSMM(EEC->EEC_CODOBP,AVSX3("EEC_OBSPED",AV_TAMANHO),,,LERMEMO)
         M->EEC_OBS    := MSMM(EEC->EEC_CODMEM,AVSX3("EEC_OBS",AV_TAMANHO),,,LERMEMO)
         
         EXL->( dbSetOrder(1) )
         If EXL->( dbSeek(xFilial("EXL")+M->EEC_PREEMB) )
            For I := 1 TO EXL->( FCount() )
               M->&(EXL->( FieldName(I) )) := EXL->( FieldGet(I) )
            Next
         EndIf
         
         M->EEC_PESLIQ:=M->EEC_PESBRU:=M->EEC_TOTITE:=M->EEC_TOTPED:=0 // ** JPM
         
         //** VARIAVEIS PRIVATE NECESSARIAS PARA ATUALIZAÇÃO DO EMBARQUE
         cMarca:= GetMark()
         Private bTotal := {|x| x := if(x=="SOMA",1,-1),;
                      M->EEC_PESLIQ += x*If(lConvUnid,AvTransUnid(WorkIp->EE9_UNPES,M->EEC_UNIDAD,WorkIp->EE9_COD_I,WorkIp->EE9_PSLQTO,.F.),WorkIp->EE9_PSLQTO),;
                      M->EEC_PESBRU += x*If(lConvUnid,AvTransUnid(WorkIp->EE9_UNPES,M->EEC_UNIDAD,WorkIp->EE9_COD_I,WorkIp->EE9_PSBRTO,.F.),WorkIp->EE9_PSBRTO),;
                      M->EEC_TOTPED += x*WorkIP->EE9_PRCINC,;
                      M->EEC_TOTITE += x*1,;
                      AE100TTela(.F.)}
         Private lIntDraw := EasyGParam("MV_EEC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC

         cIDCAPA       := M->EEC_IDIOMA
         cFilSYS       := xFilial("SYS")
         SX3->(DBSETORDER(2))
         lYSTPMODU     := SX3->(DBSEEK("YS_TPMODU")) .AND. SX3->(DBSEEK("YS_MOEDA"))
         aPreCalcDeletados:={}

         // ** Define se o controle de quantidades entre Br e Off-Shore está ativo.
         Private lConsolida := EECFlags("INTERMED")
         Private lConsolOffShore := .f. // define se tem offshore
         
         //** Tratamentos da rotina de controle de quantidades
         If EECFlags("INTERMED")
            Private aConsolida := {}
            Ap104KeyX3(aConsolida) // acerta tamanho

            // Campos da work de agrupamento e da msselect
            aGrpCpos  := {"WP_FLAG",;
                          "EE9_PEDIDO","EE9_ORIGEM","EE9_COD_I" ,"EE9_VM_DES",;
                          "EE9_FORN"  ,"EE9_FOLOJA","EE9_FABR"  ,"EE9_FALOJA",;
                          "EE9_PART_N","EE9_PRECO" ,"EE9_UNIDAD","EE9_SLDINI",;
                          "EE9_PRCTOT","EE9_PRCINC","EE9_PSLQUN","EE9_PSLQTO",;
                          "EE9_EMBAL1","EE9_QTDEM1","EE9_QE"    ,"EE9_PSBRUN",;
                          "EE9_PSBRTO","WP_SLDATU"}
            Ap104KeyX3(aGrpCpos) // acerta tamanho
   
            // Informações referentes aos campos acima. "S" - Sempre igual, "N" - Não é sempre igual, "T" - Totaliza
            // Obs.: para cada posição do aGrpCpos, deve ter uma posição correspondente no aGrpInfo
            aGrpInfo  := {"S",;
                          "S","S","S","S",;
                          "S","S","S","S",;
                          "S","N","S","T",;
                          "T","T","S","T",;
                          "S","T","S","S",;
                          "T","T"}
      
            Private bConsolida, cGrpFilter, cConsolida := Ap104StrCpos(aConsolida)// variáveis para filtro
            Private b2Consolida, c2GrpFilter // filtro da filial oposta

            ASize(aGrpCpos,Len(aGrpCpos)+Len(aConsolida)) //redimensiona para colocar os campos do aConsolida.
            ASize(aGrpInfo,Len(aGrpCpos))
            For i := 1 To Len(aConsolida)
               If (nPos := AScan(aGrpCpos,aConsolida[i])) > 0
                  aGrpInfo[nPos] := "S"
                  ASize(aGrpCpos,Len(aGrpCpos)-1)
                  ASize(aGrpInfo,Len(aGrpCpos))
               Else
                  AIns(aGrpCpos,i+4)
                  aGrpCpos[i+4] := aConsolida[i]
                  AIns(aGrpInfo,i+4)
                  aGrpInfo[i+4] := "S" // sempre igual
               EndIf
            Next
         EndIf
         //**
         
         aNomWorks:= AE102SetWorks()                           //Carrega novas Works para o Processo a Acertar.
         AE102LoadEmb(aProcessos[nInd][2], aProcessos[nInd][1])//Carrega os dados do Processo.
         AE102SetGrvEmb(.F.)                                   //Grava o Processo.
         AE102DelWorks(aNomWorks)                              //Exclui Works.
   End Case
   
Next

cFilAnt:= cFilOld       //Retorna a filial.
SM0->( dbGoTo(nRecSM0) )//Posiciona na Filial.

AP104TrataWorks(.F.,cFase)//Restaura as Works.

//Retorna dados da Capa
aEval(aMem,{|X| Eval(X[1],X[2]) })

If cFase == OC_EM
   aEval(aMemEXL,{|X| Eval(X[1],X[2]) })
Endif

RestOrd(aOrd)
Return .T.

/*
Funcao          : AX100BuscaFolder()
Parametros      : cCampo - Campo correspondente.
Retorno         : Descrição da pasta onde o campo (cCampo) está alocado.
Objetivos       : Retornar a descrição da pasta onde o campo (cCampo) está alocado.
Autor           : Jeferson Barros Jr.
Data/Hora       : 02/05/05 11:50.
Obs.            :
*/
*--------------------------------------*
Static Function Ax100BuscaFolder(cCampo)
*--------------------------------------*
Local cRet := "Sem Pasta", cFolder, cTab
Local aOrd := SaveOrd({"SX3","SXA"})

Begin Sequence

   cCampo := AllTrim(Upper(cCampo))
   If Empty(cCampo) 
      Break
   EndIf

   SX3->(DbSetOrder(2))
   If SX3->(DbSeek(cCampo))
      cTab    := SX3->X3_ARQUIVO
      cFolder := SX3->X3_FOLDER

      If !Empty(cTab) .And. !Empty(cFolder)
         SXA->(DbSetOrder(1))
         If SXA->(DbSeek(cTab+cFolder))
            cRet := SubStr(AllTrim(SXA->XA_DESCRIC),1,15)
         EndIf
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return cRet

/*
Funcao          : AxExisteComplemento().
Parametros      : Nenhum.
Retorno         : .t./.f.
Objetivos       : Verificar se o registro de complemento deverá ser incluído ou alterado na filial de off-shore.
Autor           : Jeferson Barros Jr.
Data/Hora       : 10/05/05 13:44.
Obs.            : Considera que a Wk_Main está posicionada no registro que deverá ser testado.
*/
*-----------------------------------*
Static Function AxExisteComplemento()
*-----------------------------------*
Local lRet:=.t.
Local cAlias, cCod, cTipo, cAgente
Local lTipComChave
Begin Sequence

   cAlias := AX100WkAlias(Left(Wk_Main->WK_CODCOM,3))
   aOrd   := SaveOrd(cAlias)

   If Wk_Main->WK_RECNOD <> 0
      lRet:=.f.
      Break
   EndIf

   If Wk_Main->WK_FASE = OC_PE
      lTipComChave := EE8->(FieldPos("EE8_TIPCOM")) > 0
   Else
      lTipComChave := EE9->(FieldPos("EE9_TIPCOM")) > 0
   EndIf
   
   (cAlias)->(DbGoTo(Wk_Main->WK_RECNO))

   Do Case
      Case cAlias == "WORKAG"
           EEB->(DbSetOrder(1))
           // lRet := !EEB->(DbSeek(cFilEx+Wk_Main->WK_PROC+Wk_Main->WK_FASE+WorkAg->EEB_CODAGE+WorkAg->EEB_TIPOAG)) - JPM - 02/06/05
           lRet := !EEB->(DbSeek(cFilEx+Wk_Main->WK_PROC+Wk_Main->WK_FASE+WorkAg->EEB_CODAGE+WorkAg->EEB_TIPOAG + ;
                                 If(lTipComChave,WorkAg->EEB_TIPCOM,"") ))

      Case cAlias == "WORKIN"

           cCod  := WorkIn->EEJ_CODIGO
           cTipo := WorkIn->EEJ_TIPOBC

           EEJ->(DbSetOrder(1))
           If EEJ->(DbSeek(cFilEx+Wk_Main->WK_PROC+Wk_Main->WK_FASE))
              Do While EEJ->(!Eof()) .And. EEJ->EEJ_FILIAL == cFilEx .And.;
                                           EEJ->EEJ_PEDIDO == Wk_Main->WK_PROC .And.;
                                           EEJ->EEJ_OCORRE == Wk_Main->WK_FASE

                 If cCod == EEJ->EEJ_CODIGO .And. cTipo == EEJ->EEJ_TIPOBC
                    lRet := .f. 
                    Break
                 EndIf

                 EEJ->(DbSkip())
              EndDo
           EndIf

      Case cAlias == "WORKDE"

           cCod    := WorkDe->EET_DESPES
           cAgente := WorkDe->EET_TIPOAG

           EET->(DbSetOrder(1))
           If EET->(DbSeek(cFilEx+Wk_Main->WK_PROC+Wk_Main->WK_FASE))
              Do While EEJ->(!Eof()) .And. EET->EET_FILIAL == cFilEx .And.;
                                           EET->EET_PEDIDO == Wk_Main->WK_PROC .And.;
                                           EET->EET_OCORRE == Wk_Main->WK_FASE

                 If cCod == EET->EET_DESPES .And. cAgente == EET->EET_TIPOAG
                    lRet := .f.
                    Break
                 EndIf

                 EET->(DbSkip())
              EndDo
           EndIf

      Case cAlias == "WORKNO"
           EEN->(DbSetOrder(1))
           lRet := !EEN->(DbSeek(cFilEx+Wk_Main->WK_PROC+Wk_Main->WK_FASE+WorkNo->EEN_IMPORT+WorkNo->EEN_IMLOJA))

   EndCase

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao          : AxAddComplemento().
Parametros      : Nenhum.
Retorno         : .t./.f.
Objetivos       : Incluir complemento na filial de destino.
Autor           : Jeferson Barros Jr.
Data/Hora       : 10/05/05 17:04.
Obs.            : 
*/
*----------------------------------------------------*
Static Function AxAddComplemento(cFil,cProcesso,cFase)
*----------------------------------------------------*
Local cAliasOf, cAlias, cCampoD
Local aDados := {}
Local lRet   := .t.
Local nInd   := 0
Local nRec, nRecMain := Wk_Main->WK_RECNO

Begin Sequence

   cAlias:= Left(Wk_Main->WK_CODCOM,3)
   
   (cAlias)->(DbGoTo(Wk_Main->WK_RECNO))
   
   aDados:= {}
   For nInd:= 1 To (cAlias)->(FCount())
       cCampoD:= cAlias+SubStr((cAlias)->(FieldName(nInd)),4)

       If (cAlias)->(FieldPos(cCampoD)) > 0 .And. (!SubStr(cCampoD,5) $ "FILIAL/PREEMB/PEDIDO/OCORRE/PROCES")
          aAdd(aDados,{FieldWBlock(cCampoD,Select(cAlias)),(cAlias)->(FieldGet(nInd))})
       Endif
   Next

   RecLock(cAlias,.t.)
   Eval((cAlias)->(FieldWBlock(cAlias+"_FILIAL",Select(cAlias))),cFil)

   If (cAlias)->(FieldPos(cAlias+"_PREEMB")) > 0
      Eval((cAlias)->(FieldWBlock(cAlias+"_PREEMB",Select(cAlias))),cProcesso)
   Endif

   If (cAlias)->(FieldPos(cAlias+"_PEDIDO")) > 0
      Eval((cAliasD)->(FieldWBlock(cAlias+"_PEDIDO",Select(cAliasD))),cProcesso)
   Endif

   If (cAlias)->(FieldPos(cAlias+"_PROCES")) > 0
      Eval((cAlias)->(FieldWBlock(cAlias+"_PROCES",Select(cAlias))),cProcesso)
   Endif

   If (cAlias)->(FieldPos(cAliasD+"_OCORRE")) > 0
      Eval((cAlias)->(FieldWBlock(cAlias+"_OCORRE",Select(cAlias))),cFase)
   Endif

   aEval(aDados,{|x| Eval(x[1],x[2])})
   (cAlias)->( MsUnLock())
   
   // JPM - 03/06/05 - Tratamentos para evitar duplicação de registros
   nRec := Wk_Main->(RecNo())
   Wk_Main->(DbGoTop())
   While Wk_Main->(!Eof())
      If (cAlias+cFil+cProcesso+cFase) == (Wk_Main->(Left(WK_CODCOM,3)+WK_FILIAL+WK_PROC+WK_FASE)) .And. ;
         nRecMain == Wk_Main->WK_RECNO .And. Wk_Main->(RecNo()) <> nRec
         
         Wk_Main->(DbDelete())
      EndIf   
      Wk_Main->(DbSkip())
   EndDo
   Wk_Main->(DbGoTo(nRec))

End Sequence

Return lRet

/*
Funcao          : AxCheckIncoterm().
Parametros      : cDespId   - Identifica a despesa internacional.
                  cIncoterm - Código do icorterm do processo de origem.
                  cFil      - Filial de destino.
                  cProc     - Processo de Destino.
Retorno         : .t./.f.
Objetivos       : Verificar se a despesa internacional poderá ser replicada no processo, 'cProc', de acordo com
                  as exigências do icoterm do processo.
Autor           : Jeferson Barros Jr.
Data/Hora       : 17/05/05 11:49.
Obs.            :
*/
*-----------------------------------------------------------*
Static Function AxCheckIncoterm(cDespId,cIncoterm,cFil,cProc)
*-----------------------------------------------------------*
Local aOrd := SaveOrd({"EEC","SYJ"})
Local lRet := .t.

Begin Sequence

   If Empty(cDespId) .Or. Empty(cIncoterm) .Or. Empty(cFil) .Or. Empty(cProc)
      lRet:=.f.
      Break
   EndIf

   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(cFil+cProc))

      // Caso o icoterm seja igual ao do processo de origem, o sistema não valida o destino.
      If EEC->EEC_INCOTE == cIncoterm
         Break
      EndIf

      SYJ->(DbSetOrder(1))
      If SYJ->(DbSeek(xFilial("SYJ")+EEC->EEC_INCOTE))
         Do Case
            Case cDespId == "FR"
                 If SYJ->YJ_CLFRETE $ cNao
                    lRet:=.f.
                    Break
                 EndIf

            Case cDespId == "SE"
                 If SYJ->YJ_CLSEGUR $ cNao
                    lRet:=.f.
                    Break
                 EndIf
         EndCase
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet


/*
Funcao          : AxVerifBrasil
Parametros      : cBotao (BT_CAPA/BT_DET/BT_ITEM/BT_COMP)
Retorno         : lRet(.T./.F.)
Objetivos       : Exibir opções de Replicação quando se utiliza o botão Marcar/Desmarcar Todos.
                  Caso todos os campos alterados estejam dentro da Array aCamposBrasil, a replicação de
                  dados só poderá ocorrer na filial Brasil. No caso de exitir ao menos um campo que não
                  faça parte do aCamposBrasil, é apresentada todas as filiais para Replicação.
Autor           : Eduardo C. Romanini
Data/Hora       : 02/09/05 14:00
Obs.            :
*/
*-----------------------------------------------------------*
Static Function AxVerifBrasil(cBotao)
*-----------------------------------------------------------*
Local lRet := .T.
Local nRecNo := Wk_Field->(RecNo()), nRecNo2 := Wk_Geral->(RecNo()), nRecNo3 := Wk_Main->(RecNo())
Local cCampo, cTipo
Local cOldFilter, bOldFilter


Begin Sequence

   cOldFilter := Wk_Field->(DbFilter())
   bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")
   
   //Verificação da fase em que se encontra o botão Marcar/Desmarcar Todos.   
   Do Case
      Case cBotao == BT_CAPA  //Capa
         
         Wk_Field->(DbGoTop())
         //Nesse ponto o sistema verifica se todos os campos pertencem a aCamposBrasil.
         While Wk_Field->(!EOF())
            If aScan(aCamposBrasil,Alltrim(Wk_Field->WK_CMPID)) == 0 //Caso algum campo não seja encontrado na array,
               lRet := .F.                                           //a função retorna False.
               Break
            EndIF
            Wk_Field->(DbSkip())
         EndDo       
      
      Case cBotao $ "BT_ITEM/BT_COM"   //Item ou Complemento - 1º Tela
        
        //Verificação do Tipo
        IF cBotao == BT_ITEM
           cTipo := "D" //Item        
        ELSE
           cTipo := "C" //Complemento
        EndIF
                        
        Wk_Geral->(DbGoTop()) 
        While Wk_Geral->(!EOF()) 
           
           //Se for um registro novo ou excluído, todas as filiais deverão ser exibidas.
           IF cTipo == "C" .And. (AllTrim(Wk_Geral->WK_CAMPOS) $ STR0028) //"Registro excluido./Registro novo."
              lRet := .F.
              Break
           EndIf 
           
           //Filtra a Work       
           Wk_Field->(DbClearFilter())           
           Wk_Field->(DbSetFilter({|| Str(Wk_Field->WK_RECNO,7,0) == Str(Wk_Geral->WK_RECNO,7,0) .And.;
                                            Wk_Field->WK_TIPO == cTipo},;
                                            "Str(Wk_Field->WK_RECNO,7,0) == '"+Str(Wk_Geral->WK_RECNO,7,0)+"' .And. "+;
                                            "Wk_Field->WK_TIPO == '"+cTipo+"'"))
              
           Wk_Field->(DbGoTop())       
           While Wk_Field->(!EOF())
              cCampo := Wk_Field->WK_CMPID
              If aScan(aCamposBrasil,Alltrim(cCampo)) == 0 //Caso algum campo não seja encontrado na array,
                 lRet := .F.                               //a função retorna False.
                 Break
              EndIf   
              Wk_Field->(DbSkip())
           EndDo
           
           Wk_Geral->(DbSkip())
        EndDo
      
      Case cBotao == BT_DET  //Item ou Complemento - 2º Tela
      
         Wk_Field->(DbGoTop())
         While Wk_Field->(!EOF())
            If aScan(aCamposBrasil,Alltrim(Wk_Field->WK_CMPID)) == 0 //Caso algum campo não seja encontrado na array,
               lRet := .F.                                           //a função retorna False.
               Break
            EndIF
            Wk_Field->(DbSkip())
         EndDo      
        
   EndCase        

End Sequence

If !Empty(cOldFilter)
   Wk_Field->(DbClearFilter())
   Wk_Field->(DbSetFilter(bOldFilter,cOldFilter))
   Wk_Field->(DbGoto(nRecNo))
EndIf

Wk_Geral->(DbGoto(nRecNo2))
Wk_Main->(DbGoto(nRecNo3))
Return lRet
*-------------------------------------------------------------------------------------------------------------------*
*                                     Fim do programa EECAX100                                                      *
*-------------------------------------------------------------------------------------------------------------------*
