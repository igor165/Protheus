#INCLUDE "EEC.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "EECEI201.CH"
#DEFINE ASPAS CHR(34)
#Define TITULO   1
#Define CAMPO    2
#Define PICT     3
#Define TAM      4
#Define DEC      5
#Define TIPO     6
#Define ARQ      7
#Define FIXO     8

/*
Status dos arquivos:
	N = Não Enviado
	V = Enviado
	C = Confirmado
	R = Cancelado
*/

/*
Função    : EI201INTCASH()
Objetivos : Integração Conciliação Automática
Parametros:
Retorno   : -
Autor     : Fabrício Romera
Revisao   : Allan Oliveira Monteiro - 11/02/2011
			Rodrigo Mendes Diaz - 21/01/2015
*/
Function EI201INTCASH(lAuto, lGerar, lRececeber)



Local   aOpc[0], aRestrONA[0], aRestrOV[0], aRestrOR[0],aRestrOG[0],aRestrOP[0]
Local   bOk, bCancel
Private aRotina := MenuDef("EI201INTCA")
Private aServ[0], aItens[0],aCols[0],aDados[0]
//Preenche diretórios para copiar arquivo
Private cDirTemp  := GetProfString("EEC_INTCASH","DIR_EXPORT",If(!IsBlind(),GetTempPath(),""),.T. ),;
        cDirServNE:= "\comex\cambio\conciliacao\naoenviados\" ,;
        cDirServE := "\comex\cambio\conciliacao\enviados\"    ,;
        cDirServC := "\comex\cambio\conciliacao\confirmados\" ,;
        cDirServRJ:= "\comex\cambio\conciliacao\cancelados\"
Private cDirImport := GetProfString("EEC_INTCASH","DIR_IMPORT","",.T. )
Private lBaseLimpa := .F.
Private cDadosParam := "Banco 'BBB', Conta 'CCC', Moeda 'MMM', Filiais 'FFF'"
Default lAuto := .F.
Default lGerar := .T.
Default lRececeber := .T.

   /* Vetor de itens
      1. Descrição do Item
      2. ID para controle interno
      3. Status (conteúdo dos campos do índice informado)
      4. aCampos
      5.
      6.
      7. */

   aAdd(aItens, {"Não Enviados"  , "ITN", "N",, "AVG_NENV"  ,"AVG_NENV"   , })  /*"WK_FLAG", {|| MarcaDesmarcaParc() }})*/
   aAdd(aItens, {"Enviados"      , "ITV", "V",, "AVG_IOK"   ,"AVG_IOK"    , })/*"WK_FLAG", {|| MsgInfo("Implementar")}})*/
   aAdd(aItens, {"Confirmados"   , "ITC", "C",, "AVG_IMPORT","AVG_IMPORT" , })/*"WK_FLAG", {|| MsgInfo("Implementar")}})*/
   aAdd(aItens, {"Cancelados"    , "ITR", "R",, "AVG_ICANC" ,"AVG_ICANC"  , })/*"WK_FLAG", {|| MsgInfo("Implementar")}})*/

   /* Vetor de serviços
      1.  Descrição do Serviço
      2.  Alias da Tabela de Serviço.
      3.  ID para controle interno.
      4.  aItens
      5.  aCampos MsSelect
      6.  Indice (número do índice da tabela
      7.  Imagem 1
      8.  Imagem 2 */

   aAdd(aServ, {"Conciliação Automática","EJA", "IT",aItens , "", 2, "", ""})

   aIds:= {"IT" ,"ITN" ,"ITV" ,"ITC" ,"ITR",;
           "IT" ,"ITN" ,"ITV" ,"ITC" ,"ITR",;
           "IT" ,"ITN" ,"ITV" ,"ITC" ,"ITR",;
           "IT" ,"ITN" ,"ITV" ,"ITC" ,"ITR",;
           "RAIZ",;
           "ITITN" ,"ITITV" ,"ITITC" ,"ITITR",;
           "ITITN" ,"ITITV" ,"ITITC" ,"ITITR"}

   //Preenche vetores de restrições de itens nas opções
   /* Vetor de ações
      1. Descricao da Opção
      2. Id
      3. Array com os IDs dos itens e serviços que possuem a opção
      4. Codblock com as funções
      5. Status
      6. Imagem 1
      7. Imagem 2 */

   //Ação Gerar arquivo em todas as pastas
   aRestrOG := IDTodosItens(aServ, aItens)      //Gerar Arquivo
   aAdd(aRestrOG,aServ[1][3])                   //Gerar Arquivo
   aAdd(aRestrOG, "RAIZ")                       //Gerar Arquivo

   //Ação Enviar na pasta "NaoEnviados"
   aAdd(aRestrOV, aServ[1][3]+aItens[1][2])     //Enviar

   //Ação Cancelar nas pastas "NaoEnviados, Enviados e Confirmados"
   aAdd(aRestrOR, aServ[1][3]+aItens[1][2])     //Cancelar
   aAdd(aRestrOR, aServ[1][3]+aItens[2][2])     //Cancelar
   aAdd(aRestrOR, aServ[1][3]+aItens[3][2])     //Cancelar

   //Ação Confirmar na pasta "Enviados"
   aAdd(aRestrOP,aServ[1][3]+aItens[2][2])      //Confirmar

   //Preenche vetor de opções
   //Vincular
   aAdd(aOpc,{ "Enviar";
             , "OV";
             , aIds;
             , {|| MsAguarde({|| EI201EnvParc(), AvAtuCentrInt("",aServ),LimpaWork("WK_EEQ")},"Enviar Arquivo")};
             , "";
             , "AVG_IREEN" ;
             , "AVG_IREEN" ;
             })

   //Gerar Arquivo
   aAdd(aOpc,{ "Gerar Arquivo";
             , "OG";
             , aIds;
             , {|| MsAguarde({|| EI201GeraArq(), AvAtuCentrInt("",aServ), LimpaWork("WK_EEQ")}, "Gerar Arquivo")};
             , "";
             ,"AVG_IPROC" ;
             ,"AVG_IPROC"})

   //Gerar Arquivo
   aAdd(aOpc,{ "Importar Arquivo";
             , "OI";
             , aIds;
             , {|| MsAguarde({|| EI201ImpArq(), AvAtuCentrInt("",aServ), LimpaWork("WK_EEQ")}, "Importar Arquivo")};
             , "";
             ,"AVG_IPROC" ;
             ,"AVG_IPROC"})

   //Rejeitar
   aAdd(aOpc,{ "Cancelar";
             , "OR";
             , aIds;
             , {|| MsAguarde({|| EI201RejArq(), AvAtuCentrInt("",aServ), LimpaWork("WK_EEQ")}, "Rejeitar Arquivo", "Alterando Situação do Arquivo...")};
             , "";
             ,"AVG_ICANC" ;
             ,"AVG_ICANC" })

   //Rejeitar
   aAdd(aOpc,{ "Carregar Parametros";
             , "PR";
             , aIds;
             , {|| MsAguarde({|| EI201GetPars() }, "Carregar Parametros", "Carregar Parametros")};
             , "";
             ,"AVG_ICANC" ;
             ,"AVG_ICANC" })


   /*
   //ExecVincParc
   aAdd(aOpc,{ "Confirmar";
             , "OP";
             , aRestrOP;
             , {|| MsAguarde({|| EI201ExecParc(), AvAtuCentrInt("",aServ), LimpaWork("WK_EEQ")}, "Confirmar")};
             , "";
             ,"AVG_INEW" ;
             ,"AVG_INEW"})
   */

   //Preenche variaveis de títulos
   cDlgTit     := "Integração International Cash"
   cTreeTit    := "International Cash"
   cTreeTitOpc := "Ações"
   cRaizTit    := "Serviços"
   cRaizTitOpc := "Ações"
   cPanelTit   := "International Cash"
   cRaizImg    := "AVG_IINT"
   cRaizImgOpc := "AVG_IOPT"

	//*** Limpa o EJA, excluindo registros cancelados que tenham sido gerados nos dias anteriores
	dLogIni := DToS(dDatabase-1)
	BeginSql Alias "QRYEJA"
		Select EJA.R_E_C_N_O_ As REC
		From %table:EJA% EJA
		Where
			EJA_STATUS = 'R'
			AND EJA_DTREJ < %exp:dLogIni%
			AND %NotDel%
		Order By
			EJA_DTENV
	EndSql
	While !QRYEJA->(Eof())
		EJA->(DbGoTo(QRYEJA->REC))
		If EJA->(RecLock("EJA", .F.))
			EJA->(DbDelete())
			EJA->(MsUnlock())
		EndIf
		QRYEJA->(DbSkip())
	EndDo
	QRYEJA->(DbCloseArea())
	DbSelectArea("EJA")
	//***

   //Cria Work p/ controle de parcelas vinculadas
   CriaWork("WK_EEQ")

   //Verifica se existe arquivo de parâmetros para execução automática e pergunta ao usuário de deseja executar desta forma.
   If !lAuto .And. (!File("\comex\cambio\conciliacao\conciliacao.ini") .Or. !MsgYesNo("Deseja executar integração automática?", "Aviso"))

	   //Opção Manual - Exibe a central de integrações.
	   AvCentIntegracao(aServ,aOpc , cDlgTit, cTreeTit, cTreeTitOpc, cRaizTit, cRaizTitOpc,cPanelTit, /*bOk*/, /*bCancel*/,cRaizImg, cRaizImgOpc,,,,,.F.)
	   //AvCentIntegracao(aServ,aAcao, STR0013, STR0014 , STR0015    , STR0014 , STR0015    , STR0016 ,   bOk  ,   bCancel  ,        ,            ,,,,,.F.)

   Else

      If !lAuto

 	  	  lGerar     := MsgYesNo("Deseja gerar novos arquivos?", "Aviso")
   		  lRececeber := MsgYesNo("Deseja importar novos arquivos?", "Aviso")

      EndIf

      //Opção Automática - Carrega o arquivo de parâmetros
      If File("\comex\cambio\conciliacao\conciliacao.ini")

         //*** Para cada seção do arquivo, carrega os parâmetros e preenche o Pergunte
         cArqIni := MemoRead("\comex\cambio\conciliacao\conciliacao.ini")
         Pergunte("EJA001", .F.)
         While (nPos1 := At("[", cArqIni)) > 0
            //*** Leitura da seção
            cArqIni := SubStr(cArqIni, nPos1+1)
            nPos2 := At("]", cArqIni)
            cParam := SubStr(cArqIni, 1, nPos2-1)
            cArqIni := SubStr(cArqIni, nPos2+1)
            //Carrega as perguntas
            aParam := Separa(cParam, ";")
            aEval(aParam, {|x| SetParam(x) })
            cDadosParam := StrTran(cDadosParam, "BBB", AllTrim(MV_PAR04))
            cDadosParam := StrTran(cDadosParam, "CCC", AllTrim(MV_PAR06))
            cDadosParam := StrTran(cDadosParam, "MMM", AllTrim(MV_PAR08))
            cDadosParam := StrTran(cDadosParam, "FFF", AllTrim(MV_PAR09))
            //***

            If lGerar
               //*** Executa a geração do arquivo para esta seção
               cMsgGer := "Gerando arquivo automático (XXX)."
               cMsgGer := StrTran(cMsgGer, "XXX", cDadosParam)
               ProcAuto({|| EI201GeraArq(.T.) }, cMsgGer, cMsgGer, .T.)
               //***
            EndIf

         EndDo
         //***

		 If lRececeber
	       	 //*** Processa o retorno dos arquivos
	         ProcAuto({|| EI201ImpArq(.T.) }, "Processando retorno automático.", "Processando retorno automático.", .T.)
	         //***
	     EndIf

      Else
         MsgAuto("Arquivo de Inicialização não encontrado.", "Aviso")
      EndIf
   EndIf

   //Fecha Work
   ExcluiWork("WK_EEQ")


Return

Function EI201GetPars()
Local oParams := AvImport():New()

	oParams:ChooseFile("Selecione o Arquivo de Parametros","Arquivo de parametros .ini | *.ini",,,,,"\comex\cambio\conciliacao\")
	If File("\comex\cambio\conciliacao\conciliacao.ini")
		MsgAuto("Arquivo de parametros carregado com sucesso.", "Aviso")
	Else
   		MsgAuto("Arquivo de parametros não carregado.", "Aviso")
	EndIf

Return Nil

Static Function SetParam(aSetParam)

   If At("=", aSetParam) > 0
      aSetParam := Separa(aSetParam, "=")
      If Len(aSetParam) = 2
         If "MV_PAR" $ Upper(aSetParam[1])
            If SX1->(DbSeek(AvKey("EJA001", "X1_GRUPO")+AvKey(Right(AllTrim(aSetParam[1]), 2), "X1_ORDEM")))
               &(aSetParam[1]) := Formata(aSetParam[2], SX1->X1_TIPO)
            EndIf
         Else
            &(aSetParam[1]) := aSetParam[2]
         EndIf
      EndIf
   EndIf


Return Nil

/*
Função    : EI201GeraArq()
Objetivos : Gerar um novo arquivo de International Cash (.xml) do processo de embarque selecionado
            e apresentar as parcelas de cambio desse processo.
Parametros:
Retorno   : lRet
Autor     : Allan Oliveira Monteiro
Data      : 08/03/2010
Obs       :
*/
Function EI201GeraArq(lAuto)
Local bGeraTxt, i
Local lRet := .T.
Local cNomeArq  := "",;
      cPreemb   := "",;
      cDtVcIni  := "",;
      cDtVcFim  := ""
Private aIntCash:= {}
Private nTotParc
Private cEI201File, cEI201Hora := Time()
Private cMarca   := "XX"

Default lAuto := .F.

Begin Sequence

   aCols := {}
   aDados:= {}

   LimpaWork("WK_EEQ")

   //*** Cancela todos os arquivos anteriores (enviados ou não)
   If !lBaseLimpa
      EI201CancAll(lAuto)
      lBaseLimpa := .T.
   EndIf
   //***

   //*** Na execução manual, exibe tela para selação de filiais e Pergunte com parâmetros adicionais.
   If !lAuto
      //Tela de seleção de filiais
      aSelFil := AvgSelectFil(.T.,"EEQ")
      //Quebra o retorno no formato do Select (entre aspas simples e separado por ponto e vírgula)
      cFilSel := ""
      For i:= 1 to len(aSelFil)
         cFilSel+="'"+aSelFil[i]+"'"
         If i < len(aSelFil)
            cFilSel+=","
         EndIf
      Next
      //Insere a informação no pergunte da filial
      MV_PAR09 := cFilSel
	   //Pergunte com parâmetros para a geração do arquivo de integração
	   If !Pergunte("EJA001", .T., "Seleção de Embarques de Exportação")
	      lRet:= .F.
	      Break
	   EndIf
      cDadosParam := StrTran(cDadosParam, "BBB", AllTrim(MV_PAR04))
      cDadosParam := StrTran(cDadosParam, "CCC", AllTrim(MV_PAR06))
      cDadosParam := StrTran(cDadosParam, "MMM", AllTrim(MV_PAR08))
      cDadosParam := StrTran(cDadosParam, "FFF", AllTrim(MV_PAR09))
	   //Carrega novamente (no pergunte o campo filial é apenas informativo)
      MV_PAR09 := cFilSel
   EndIf
   //***

   //*** Validações Gerais
   If Empty(MV_PAR04) .Or. Empty(MV_PAR05) .Or. Empty(MV_PAR06)
      MsgAuto("Banco, Agencia ou Conta não informados!", "Aviso")
      lRet:= .F.
      Break
   EndIf
   If Empty(MV_PAR08)
      MsgAuto("Moeda não informada.", "Aviso")
      lRet := .F.
      Break
   EndIf
   If Empty(MV_PAR09)
      MsgAuto("Filial não informada.", "Aviso")
      lRet := .F.
      Break
   EndIf
   //***

   //*** Parâmetros de busca de parcelas
   CriaWork("WK_SEL")
   cPreemb := MV_PAR01
   cDtVcIni:= DTOS(MV_PAR02)
   cDtVcFim:= DTOS(MV_PAR03)
   //***

   //*** Efetua a busca das pacelas a pagar que podem ser vinculadas
   ProcAuto({|| lRet := BuscaEEQ(cPreemb, cDtVcIni, cDtVcFim) }, "Buscando Parcelas.", "Buscando Parcelas.", .T.)
   If lRet
      //Exibe browse p/ seleção de parcelas
      lRet:= SelParcCambio(lAuto)
   EndIf
   //***

   If lRet .And. WK_EEQ->(EasyRecCount()) == 0
      MsgInfo(STR0048+STR0049,"Aviso")//Não foi possivel a geração do arquivo./"O processo não possui parcelas a pagar ou as parcelas a pagar estão com  a(s) data(s) de 'Crédito no Exterior, Data de Solicitação de Cambio e Data de Negociação' preenchidas. ".
      lRet:= .F.
      Break
   Else
      //Totalizador de valor das parcelas (para o XML)
      nTotParc := 0
      //*** Carrega as parcelas para o programa de geração do XML
      WK_EEQ->(DBGoTop())
      While WK_EEQ->(!EOF())
         aAdd(aIntCash,{WK_EEQ->EEQ_PREEMB,WK_EEQ->EEQ_DTCE,WK_EEQ->EEQ_VL,WK_EEQ->EEQ_PARC,WK_EEQ->EEQ_TIPO,WK_EEQ->EEQ_FASE,WK_EEQ->EEQ_FILIAL,WK_EEQ->EEQ_MOEDA})
         nTotParc += WK_EEQ->EEQ_VL

         If EasyEntryPoint("EECEI201")
            ExecBlock("EECEI201", .F., .F., "PREENCHE_AINTCASH")
         EndIf

         WK_EEQ->(DbSkip())
      EndDo
      //***


      //Nome do Arquivo XML
      cEI201File := cNomeArq := GetFileName()

      //*** Verificação da existência dos diretórios para a gravação dos arquivos de integração
      //Cria diretório Não Enviados
      If !CriaDiretorioEI201(cDirServNE)
         lRet:= .F.
         Break
      EndIf
      //Cria diretório Enviados
      If !CriaDiretorioEI201(cDirServE)
         lRet:= .F.
         Break
      EndIf
      //Cria diretório Confirmados
      If !CriaDiretorioEI201(cDirServC)
         lRet:= .F.
         Break
      EndIf
      //Cria diretório Cancelados
      If !CriaDiretorioEI201(cDirServRJ)
         lRet:= .F.
         Break
      EndIf
      //***

      //*** Gera o arquivo XML de integração
      cMsgXML := "Gerando arquivo de integração (XXX)."
      cMsgXML := StrTran(cMsgXML, "XXX", cDadosParam)
      bGeraXML:= {|| lRet:= CriaXMLEI201(cDirServNE, cNomeArq)}
      ProcAuto(bGeraXML, STR0028, STR0029, .T.) //Geração de arquivo / Gerando o arquivo para a integração...
      //***

      //Insere registros selecionados na tabela de controle conforme o arquivo em que foram gerados
      InsereEJA(cNomeArq,aIntCash)

      //*** Processa o envio da parcela
      EJA->(DbSetOrder(1))
      If EJA->(DbSeek(xFilial()+cNomeArq))
         EI201EnvParc(lAuto)
      EndIf
      //***

   EndIf

End Sequence

//Limpar Work
ExcluiWork("WK_SEL")

Return lRet

/*
Função    : InsereEJA()
Objetivos : Inserir dados gerado pelo arquivo txt na tabela EJA
Parametros: cPreemb,cNomeArq,aIntCash
Retorno   : -
Autor     : Allan Oliveira Monteiro
Data      : 12/03/2010
*/
Static Function InsereEJA(cNomeArq,aIntCash)
Local i

   //Insere Registros na tabela de controle EJA
   DbSelectArea("EJA")

   //Varre vetor de arquivos e vai inserindo conforme a qtde de embarque em cada arquivo
   For i := 1 to Len(aIntCash)

         EJA->(RecLock("EJA",.T.))
         EJA->EJA_FILIAL := xFilial("EJA")
         EJA->EJA_FILE   := cNomeArq
         EJA->EJA_SEQ    := AllTrim(Str(i))
         EJA->EJA_STATUS := "N"
         EJA->EJA_CONTA  := MV_PAR06
         EJA->EJA_MOEDA  := aIntCash[i][8]
         EJA->EJA_AGENCI := MV_PAR05
         EJA->EJA_BANCO  := MV_PAR04
         EJA->EJA_DTTRAN := aIntCash[i][2]
         EJA->EJA_VALOR  := aIntCash[i][3]
         EJA->EJA_MOTIVO := ""
         EJA->EJA_DETDEB := ""
         EJA->EJA_INFOAD := ""
         EJA->EJA_USER   := AllTrim(cUserName)
         EJA->EJA_DTGER  := dDataBase
         EJA->EJA_HRGER  := Time()
         EJA->EJA_TPPARC := aIntCash[i][5]
         EJA->EJA_PREEMB := aIntCash[i][1]
         EJA->EJA_PARC   := aIntCash[i][4]
         EJA->EJA_FASE   := aIntCash[i][6]
         EJA->EJA_FILPRC := aIntCash[i][7]
         EJA->(MsUnlock())

         If EasyEntryPoint("EECEI201")
            ExecBlock("EECEI201", .F., .F., "INSERE_EJA")
         EndIf

   Next

Return Nil


/*
Função    : IntCashEI201()
Objetivos : Criar o vetor aHeader que contem o layout passado pelo banco
Parametros:
Retorno   : lRet
Autor     : Allan Oliveira Monteiro
Data      : 09/03/2010
Obs       :
*/

Static Function IntCashEI201()
Local lRet := .T.
Local aHeader:= {}

Begin Sequence

/* Estrutura:
                1 - Título (definido pelo Itaú)
                2 - Campo correspondente no dicionário de dados do sistema.
                3 - Picture
                4 - Tamanho (quantidade de dígitos definido pelo Itaú)
                5 - Decimais (definido pelo Itaú)
                6 - Tipo (caracteres numéricos ou alfanuméricos, definido pelo Itaú)
                7 - Arquivo (tabela)
                8 - Valor fixo, informado pelo Itaú ou que será tratato antes de ser preenchido no aCols
                */


   /************
    Header do Arquivo; informações de cambio
    *********************************************/
   AAdd(aHeader, {STR0001,""          ,, 014, 0, "N", ""   ,     Nil}) //Nº do Cliente no Itaú BBA
   AAdd(aHeader, {STR0002,"EEQ_NCON"  ,, 015, 0, "N", ""   ,     Nil}) //Nº da Conta Cliente
   AAdd(aHeader, {STR0003,"EEQ_MOEDA" ,, 003, 0, "C","WK_EEQ" ,     Nil}) //Moeda
   AAdd(aHeader, {STR0004,"EEQ_AGEN"  ,, 003, 0, "C","EEQ" ,     Nil}) //Agência da Conta
   AAdd(aHeader, {STR0005,"EEQ_DTCE"  ,, 008, 0, "N", ""   ,     Nil}) //Data da Transferência
   AAdd(aHeader, {STR0006,"EEQ_VL"    ,, 050, 2, "N","EEQ" ,     Nil}) //Valor
   AAdd(aHeader, {STR0007,""          ,, 002, 0, "N", ""   ,     Nil}) //Motivo da Transferência
   AAdd(aHeader, {STR0008,"EEQ_BANC"  ,, 004, 0, "C", ""   ,     Nil}) //Cód. do Banco
   AAdd(aHeader, {STR0009,"Y5_CONTA"  ,, 034, 0, "C", ""   ,     Nil}) //Nº da Conta do Beneficiário
   AAdd(aHeader, {STR0010,"Y5_NOME"   ,, 035, 0, "C", ""   ,     Nil}) //Nome do Beneficiário
   AAdd(aHeader, {STR0011,"Y5_END"    ,, 105, 0, "C", ""   ,     Nil}) //Endereço do Beneficiário
   AAdd(aHeader, {STR0012,""          ,, 015, 0, "C", ""   ,     Nil}) //Beneficiário - End. SWIFT do Banco
   AAdd(aHeader, {STR0013,""          ,, 002, 0, "C", ""   ,     Nil}) //Beneficiário - Cód. de Clearing Local
   AAdd(aHeader, {STR0014,""          ,, 031, 0, "C", ""   ,     Nil}) //Beneficiário - Conta
   AAdd(aHeader, {STR0015,"A6_NOME"   ,, 035, 0, "C", ""   ,     Nil}) //Beneficiário - Nome do Banco
   AAdd(aHeader, {STR0016,"A6_END"    ,, 105, 0, "C", ""   ,     Nil}) //Beneficiário - Endereço do Banco
   AAdd(aHeader, {STR0017,""          ,, 015, 0, "C", ""   ,     Nil}) //Intermediário - End. SWIFT do Banco
   AAdd(aHeader, {STR0018,""          ,, 002, 0, "C", ""   ,     Nil}) //Intermediário - Cód. de Clearing Local
   AAdd(aHeader, {STR0019,""          ,, 031, 0, "C", ""   ,     Nil}) //Intermediário - Conta
   AAdd(aHeader, {STR0020,""          ,, 035, 0, "C", ""   ,     Nil}) //Intermediário - Nome do Banco
   AAdd(aHeader, {STR0021,""          ,, 105, 0, "C", ""   ,     Nil}) //Intermediário - Endereço do Banco
   AAdd(aHeader, {STR0022,""          ,, 140, 0, "C", ""   ,     Nil}) //Detalhes do Pagamento
   AAdd(aHeader, {STR0023,""          ,, 003, 0, "C", ""   ,     Nil}) //Detalhes do Débito
   AAdd(aHeader, {STR0023,""          ,, 210, 0, "C", ""   ,     Nil}) //Informações Adicionais

   //Posicionamento das tabelas, validação da linha do arquivo TXT e preenchimento de dados que devem ser manipulados.
   //Após a validação, chama a função GeraColEI201() para gravar as informações no aCols
   If !IntCashValid(aHeader)
      lRet:= .F.
      Break
   EndIf

End Sequence

Return lRet



/*
Função    : IntCashValid()
Objetivos : Efetuar as validações dos campos inseridos no Layout.
Parametros: aLayout (Vetor com o Layout do Banco)
Retorno   :
Autor     : Allan Oliveira Monteiro
Data      : 10/03/10
Obs       :
*/
Static Function IntCashValid(aLayout)
Local lRet := .T.
Local cNconta1    := "", cDtransf := ""

//cFornecedor := "",;

Begin Sequence

         /*DbSelectArea("SA2")
         SA2->(DBSetOrder(1))

         If !Empty(EEC->EEC_EXPORT)
            cFornecedor:= EEC->EEC_EXPORT + EEC->EEC_EXLOJA
         Else
            cFornecedor:= EEC->EEC_FORN + EEC->EEC_FOLOJA
         EndIf

         If SA2->(DBSeek(xFilial() + AllTrim(cFornecedor)))
             If Empty(SA2->A2_NUMCON)
                MsgInfo(STR0026,"Aviso")//O numero da conta do Fornecedor/Exportador não foi informado. Atualize o cadastro do Fornecedor/Exportador antes de prossegir:
             Else
                cNconta1         := StrTran(SA2->A2_NUMCON,"-","")
                cNconta1         := StrTran(cNconta1      ,"/","")
                aLayout[2][FIXO] := Val(cNconta1)
             EndIf
         Else
            MsgInfo(STR0025,"Aviso")//Fornecedor/Exportador não encontrado
            lRet:= .F.
            Break
         EndIf*/

         //Nº da conta Cliente
         cNconta1         := StrTran(WK_EEQ->EEQ_NCON ,"-","")
         cNconta1         := StrTran(cNconta1      ,"/","")
         aLayout[2][FIXO] := Val(cNconta1)

         //Data da Transferência
         cDtransf := AllTrim(Str(Month(WK_EEQ->EEQ_DTCE)))
         cDtransf := If(Val(cDtransf)< 10, "0"+cDtransf, cDtransf)
         cDtransf += AllTrim(Str(day(WK_EEQ->EEQ_DTCE)))
         cDtransf += AllTrim(Str(year(WK_EEQ->EEQ_DTCE)))
         aLayout[5][FIXO] := Val(cDtransf)

         DbSelectArea("SY5")
         SY5->(DbSetOrder(1))
         SY5->(DbSeek(xFilial("SY5")+AllTrim(WK_EEQ->EEQ_CODEMP)))

         //Nº da Conta do Beneficiário
         aLayout[9] [FIXO] := SY5->Y5_CONTA

         //Nome do Beneficiário
         aLayout[10][FIXO] := SY5->Y5_NOME

         //Endereço do Beneficiário
         aLayout[11][FIXO] := SY5->Y5_END

         DbSelectArea("SA6")
         SA6->(DbSetOrder(1))
         SA6->(DbSeek(xFilial("SA6")+AllTrim(SY5->Y5_BANCO)))

         //Beneficiário - Nome do Banco
         aLayout[15][FIXO] := SA6->A6_NOME

         //Beneficiário - Endereço do Banco
         aLayout[16][FIXO] := SA6->A6_END

         //Gravação da linha no aCols
         GeraColEI201(aLayout)


End Sequence


Return lRet




/*
Função    : GeraColEI201
Objetivo  : Gravar no array aCols a linha do arquivo, conforme o layout do Banco definido no array
            aHeader.
            Antes de gravar no aCols, as informações são gravadas na posição FIXO do aHeader.
Parâmetros: aHeader da linha do arquivo txt a ser processado
Retorno   :
Autor     : Wilsimar Fabrício da Silva
Data      :
Obs.      : Estrutura do array aCols:
                                     {
                                      x.1 - Identificação do registro
                                      x.n - Informações da linha
                                     }
            Esta função disponibiliza um ponto de entrada para a edição dos dados da linha antes
            da geração do arquivo de integração.
            A estrutura do array é a mesma, alterando apenas o seu tamanho.
            Cada linha é identificada pelo código da área (identificação do registro) conforme
            o layout disponibilizado pela Fiesp.
            Exemplo de busca da linha:
            AScan(aHeader, {|x| x[FIXO] == "010"}) ou If (aHeader[1][FIXO] == "010")
            "010": identificador da primeira linha da declaração da fatura comercial/
            certificado de origem.
*/
Static Function GeraColEI201(aHeader)
Local cAlias:= "",;
      cPad  := ""
Local xConteudo
Local nPos,;
      nCont,;
      nRecNo
Private aHeaderTemp:= {}

/* Estrutura aHeader:
             1 - Título (definido pelo Itaú)
             2 - Campo correspondente no dicionário de dados do sistema
             3 - Picture
             3 - Tamanho (quantidade de dígitos definido pelo Itaú)
             4 - Decimais (definido pelo Itaú)
             5 - Tipo (caracteres numéricos ou alfanuméricos, definido pelo Itaú)
             6 - Arquivo (tabela)
             7 - Valor fixo, informado pelo Itaú ou que será tratato antes de ser preenchido no aCols */

Begin Sequence

   AAdd(aCols, Array(Len(aHeader)))
   nPos:= Len(aCols)

   For nCont:= 1 To Len(aHeader)

      //Caracter a ser usado pelo Pad, ao definir os tamanhos dos registros
      If aHeader[nCont][TIPO] == "N"
         cPad:= "0"
      Else
         cPad:= ""
      EndIf

      //Se não houver o campo correspondente no dicionário de dados, irá preencher com  valor fixo da posição FIXO do array.
      If Empty(aHeader[nCont][ARQ])
         xConteudo:= aHeader[nCont][FIXO]
      Else
         cAlias:= aHeader[nCont][ARQ]
         xConteudo:= (cAlias)->&(aHeader[nCont][CAMPO])
      EndIf

      //Se o conteúdo for numérico, arredonda as casas decimais conforme as definições da Fiesp
      If ValType(xConteudo) == "N"

         //O tamanho é somado com um devido ao ponto (separador de decimais)
         xConteudo:= AllTrim(Str(Round(xConteudo, aHeader[nCont][DEC]), aHeader[nCont][TAM] + 1, aHeader[nCont][DEC]))
         xConteudo:= StrTran(xConteudo, ".", "")

      //Se for data, formata como DD/MM/AAAA
      ElseIf ValType(xConteudo) == "D"
         xConteudo:= Padl(Day(xConteudo), 2, "0") + "/" + Padl(Month(xConteudo), 2, "0") + "/" + Padl(Year(xConteudo), 4)

      Else
         xConteudo:= StrTran(AllTrim(xConteudo), ENTER, " ")
      EndIf


      //Fixação do tamanho do conteúdo que será gravado no arquivo txt
      If cPad == "0"
         xConteudo:= Padl(xConteudo, aHeader[nCont][TAM], cPad)

         //Picture
         //A função Transform elimina os espaços em branco.
         If !Empty(aHeader[nCont][PICT])
            xConteudo:= Transform(xConteudo, aHeader[nCont][PICT])
         EndIf
      Else
         //Picture
         //A função Transform elimina os espaços em branco.
         If !Empty(aHeader[nCont][PICT])
            xConteudo:= Transform(xConteudo, aHeader[nCont][PICT])
         EndIf

         xConteudo:= Padr(xConteudo, aHeader[nCont][TAM], cPad)
      EndIf

      aHeader[nCont][FIXO]:= xConteudo

      /* Ponto de entrada para alteração dos valores da linha antes da gravação no arquivo TXT.
         O ponto de entrada deve alterar a posição FIXO (7) do array aHeaderTemp.*/

      If EasyEntryPoint("EECEI201")

         ExecBlock("EECEI201", .F., .F., "ALTERA_ARRAY")

      EndIf

      AAdd(aDados, AClone(aHeader[nCont]))
      aCols[nPos][nCont]:= aHeader[nCont][FIXO]

   Next

End Sequence
Return

Static Function CriaXMLEI201(cDirTxt, cNomeTxt)
//Local cBuffer := "",;
Local cMsg    := "",;
      cNomeVis:= ""
Local cHeader1, cHeader2, cParcela
//Local hFile
Local lRet:= .T.
Local nPos1
Private cBuffer := "", hFile//RMD - Alteradas para possibilitar alteração via ponto de entrada

	//Cria o arquivo XML
	cNomeVis:= AllTrim(cNomeTxt) + ".xml"
	hFile:= EasyCreateFile(cDirTxt + cNomeVis, FC_READONLY)

	If hFile == -1
		cMsg:= DesErro201(FError())
		MsgAuto(STR0030 + cMsg, "Aviso") //O arquivo não pode ser criado. FError()
		lRet:= .F.
		Break
	EndIf

	//Carrega as informações principais
	cHeader1 := EasyExecAHU("EECEI201")

	//Separa o Header em dois blocos
	If (nPos1 := At("DADOS_ITEM", cHeader1)) > 0
		cHeader2 := SubStr(cHeader1, nPos1 + 10)
		cHeader1 := Left(cHeader1, nPos1 - 1)
	Else
		MsgAuto(STR0031, "Aviso") //O arquivo não pode ser gravado. FError()
		lRet:= .F.
		Break
	EndIf

	cBuffer := cHeader1
	If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		cMsg:= DesErro201(FError())
		MsgAuto(STR0031 + cMsg, "Aviso") //O arquivo não pode ser gravado. FError()
		lRet:= .F.
		Break
	EndIf

	WK_EEQ->(DbGoTop())
	EEC->(DbSetOrder(1))
	While WK_EEQ->(!Eof())
		EEQ->(DbGoTo(WK_EEQ->WK_RECNO))
		EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
		cParcela := EasyExecAHU("ECEI201A")

		cBuffer := cParcela
		If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
			cMsg:= DesErro201(FError())
			MsgAuto(STR0031 + cMsg, "Aviso") //O arquivo não pode ser gravado. FError()
			lRet:= .F.
			Break
		EndIf

		WK_EEQ->(DbSkip())
	EndDo
	//RMD - Possibilita alterar o XML via ponto de entrada
	If ExistBlock("EECEI201")
		ExecBlock("EECEI201", .F., .F., "CRIA_XML")
	EndIf	
	
	cBuffer := cHeader2	
	If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
		cMsg:= DesErro201(FError())
		MsgAuto(STR0031 + cMsg, "Aviso") //O arquivo não pode ser gravado. FError()
		lRet:= .F.
		Break
	EndIf

	FClose(hFile)

Return lRet

/*
Função    : CriaTxtEI201
Objetivo  : Geração dos arquivos TXT, com base no array aCols.
Parâmetros: cDirTxt - diretório para a criação do arquivo TXT
            cNomeTxt - nome do arquivo TXT (com a extensão)
            aCols - array com os dados a serem escritos no arquivo TXT
Retorno   : lRet
Autor     : Allan Oliveira Monteiro
Data      : 11/03/2010
Obs.      :
*/
Static Function CriaTxtEI201(cDirTxt, cNomeTxt, aCols)
Local cBuffer := "",;
      cMsg    := "",;
      cNomeVis:= ""
Local hFile
Local lRet:= .T.
Local nCont1,;
      nCont2/*,;
      nLinha*/

Begin Sequence


   //Arquivo para visualização
   /*nLinha:= 1
   cBuffer:= STR0160 + ENTER //Obs.: para os campos quantidade e valor, os três últimos dígitos devem ser considerados como decimais.
   For nCont1:= 1 To Len(aDados)
      If aDados[nCont1][TITULO] == STR0008 //Identificação do Registro
         cBuffer += ENTER
         cBuffer += STR0153 + StrZero(nLinha++, 3) + ENTER //Linha ###
      EndIf

      cBuffer += aDados[nCont1][TITULO]
      cBuffer += ": "
      cBuffer += aDados[nCont1][FIXO]
      cBuffer += ENTER
   Next

   If MsgYesNo(STR0152, cTitMsg) //Deseja visualizar o arquivo de integração antes de concluir a geração?
      If !VisualArqEI100(cBuffer)
         lRet:= .F.
         Break
      EndIf
   EndIf*/

   cNomeVis:= AllTrim(SubStr(cNomeTxt, 1/*, At(".", cNomeTxt) - 1*/)) + ".xml"

   hFile:= EasyCreateFile(cDirTxt + cNomeVis, FC_READONLY)

   If hFile == -1
      cMsg:= DesErro201(FError())
      MsgInfo(STR0030 + cMsg, "Aviso") //O arquivo não pode ser criado. FError()
      lRet:= .F.
      Break
   EndIf

   If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
      cMsg:= DesErro201(FError())
      MsgInfo(STR0031 + cMsg, "Aviso") //O arquivo não pode ser gravado. FError()
      lRet:= .F.
      Break
   EndIf

   FClose(hFile)


   //Arquivo de integração
   hFile:= EasyCreateFile(cDirTxt + /*cNomeTxt*/cNomeVis, FC_READONLY)
   cBuffer:= ""

   If hFile == -1
      cMsg:= DesErro201(FError())
      MsgInfo(STR0030 + cMsg, "Aviso") //O arquivo não pode ser criado. FError()
      lRet:= .F.
      Break
   EndIf

   For nCont1:= 1 To Len(aCols)
      For nCont2:= 1 To Len(aCols[nCont1])

         cBuffer += aCols[nCont1][nCont2]
      Next
      cBuffer += ENTER
   Next

   If FWrite(hFile, cBuffer, Len(cBuffer)) < Len(cBuffer)
      cMsg:= DesErro201(FError())
      MsgInfo(STR0031 + cMsg, "Aviso") //O arquivo não pode ser gravado. FError()
      lRet:= .F.
      Break
   EndIf

   FClose(hFile)

   MsgInfo(STR0032, "Aviso") //Arquivo gerado com sucesso
End Sequence
Return lRet



/*
Função    : DesErro201
Objetivo  : Retornar a descrição do erro na criação e gravação do arquivo.
Parâmetros: FError()
Retorno   : Descrição do erro
Autor     : Wilsimar Fabrício da Silva
Data      : 19/11/2009
Obs.      :
*/
Static Function DesErro201(nErro)
Local cDescErro:= ""

Begin Sequence

      Do Case
         Case nErro == 2
            cDescErro:= STR0033 //Arquivo não encontrado
         Case nErro == 3
            cDescErro:= STR0034 //Caminho não encontrado
         Case nErro == 4
            cDescErro:= STR0035 //Muitos arquivos abertos
         Case nErro == 5
            cDescErro:= STR0036 //Acessso negado
         Case nErro == 6
            cDescErro:= STR0037 //Manipulador Invalido
         Case nErro == 8
            cDescErro:= STR0038 //Memória Insuficiente
         Case nErro == 15
            cDescErro:= STR0039 //Drive especificado inválido
         Case nErro == 19
            cDescErro:= STR0040 //Tentativa de gravar em disco protegido contra gravação
         Case nErro == 21
            cDescErro:= STR0041 //Drive não esta pronto
         Case nErro == 23
            cDescErro:= STR0042 //Dados com erro de CRC
         Case nErro == 29
            cDescErro:= STR0043 //Erro de gravação
         Case nErro == 30
            cDescErro:= STR0044 //Erro de leitura
         Case nErro == 32
            cDescErro:= STR0045 //Violação de compartilhamento
         Case nErro == 33
            cDescErro:= STR0046 //Erro de Lock
         Case nErro == 430 .Or. nErro == 161
            cDescErro:= STR0033 //Arquivo não encontrado
         OtherWise
            cDescErro:= STR0047 //Erro desconhecido
      EndCase

End Sequence
Return cDescErro


/*
Função    : CriaDiretorioEI201
Objetivo  : Cria o diretório para armazenar os arquivos de integração
Parâmetros: cDirTxt - diretório para a criação do arquivo TXT
Retorno   : lRet
Autor     : Allan Oliveira Monteiro
Data      : 11/03/2010
Obs.      :
*/
Static Function CriaDiretorioEI201(cDirTxt)

Local cDirTemp:= ""
Local nPos
Local lRet:= .T.

Begin Sequence

   //Verificação da existência de cada diretório para criação
   If !lIsDir(cDirTxt)

      nPos:= At("\", cDirTxt)
      cDirTemp:= Lower(SubStr(cDirTxt, 1, nPos))
      cDirTxt := Lower(SubStr(cDirTxt, nPos + 1, Len(cDirTxt)))

      If AllTrim(cDirTemp) == "\"   //LGS-17/11/2015
         nPos     := At("\", cDirTxt)
         cDirTemp += SubStr(cDirTxt, 1, nPos)
         cDirTxt  := SubStr(cDirTxt, nPos + 1, Len(cDirTxt))
      EndIf

      While nPos > 0

         If !lIsDir(cDirTemp)
            MakeDir(cDirTemp)
         EndIf

         nPos:= At("\", cDirTxt)

         cDirTemp += SubStr(cDirTxt, 1, nPos)
         cDirTxt  := SubStr(cDirTxt, nPos + 1, Len(cDirTxt))

      End
      cDirTxt:= cDirTemp
   EndIf

   If !lIsDir(cDirTxt)
      MsgInfo(STR0027 + cDirTxt, "Aviso") //Não foi possível criar o diretório ###
      lRet:= .F.
   EndIf

End Sequence
Return lRet



/*------------------------------------------------------------------------------------------------------------------
Função    : IDTodosItens(aServ, aItens)
Objetivos : Retorna o id de todos os itens do array de itens de um serviço
Parametros:
Retorno   : -
Autor     : Fabrício Romera
Data      : 07/12
------------------------------------------------------------------------------------------------------------------*/
Static Function IDTodosItens(aServ, aItens)
   Local aRet[0], i, j

   For i:= 1 to Len(aServ)
      For j:= 1 to Len(aItens)
         aAdd(aRet, aServ[i][3]+aItens[j][2])
      Next
   Next
Return aRet

/*------------------------------------------------------------------------------------------------------------------
Função    : Formata()
Objetivos : Retorna o id de todos os itens do array de itens de um serviço
Parametros: cConteudo, cTipo
Retorno   : -
Autor     : Fabrício Romera
Data      : 09/12
Obs.      : D1 : Data, formato MMDDAAAA;
            D2 : Data, formata DDMMAAAA;
            N  : Numérico/Decimal;
            B  : Bloco de Código.
------------------------------------------------------------------------------------------------------------------*/
Static Function Formata(xConteudo, cTipo)
   Local xRet := xConteudo

   If cTipo == "D"
      xRet := CToD(xConteudo)
   ElseIf cTipo = "D1"
      xConteudo := AllTrim(xConteudo)
      xRet := Left(xConteudo,2)                                                //MM
      xConteudo := Right(xConteudo, 6)                                         //DDAAAA
      xRet := CtoD(Left(xConteudo,2) + "/" + xRet + "/" + Right(xConteudo, 4)) //DD/MM/AAAA
   ElseIf cTipo = "D2"
      xConteudo := AllTrim(xConteudo)
      xRet := Left(xConteudo,2)                                                //MM
      xConteudo := Right(xConteudo, 6)                                         //DDAAAA
      xRet := CtoD(xRet + "/" + Left(xConteudo,2) + "/" + Right(xConteudo, 4)) //DD/MM/AAAA
   Elseif cTipo = "N"
      xConteudo := StrTran(xConteudo, ",", ".")
      xRet := Val(xConteudo)
   Elseif cTipo = "F" //Tipo Decimal sem virgula
      //Coloca virgula
      If !Empty(xConteudo)
         xConteudo := Left(xConteudo, Len(xConteudo)-2)+"."+Right(xConteudo,2)
         xRet := Val(xConteudo)
      End If
   Elseif cTipo = "B"
      xRet := &(xConteudo)
   End If

Return xRet


/*------------------------------------------------------------------------------------------------------------------
Função    : GetFileName()
Objetivos : Retornar o proximo numero de arquivo p/ cadastro na tabela EJA
Parametros:
Retorno   : cFileName: próximo número da sequencia de arquivos.
Autor     : Fabrício Romera
Data      : 10/12/2009
------------------------------------------------------------------------------------------------------------------*/
Static Function GetFileName()
   /*
   Local cFileName := ""
   Local nZero := 15

   DbSelectArea("EJA")

   EJA->(DbGoTop())
   EJA->(DbSetOrder(1))
   EJA->(AvSeekLast(xFilial("EJA")))

   If !Empty(EJA->EJA_FILE)
      cFileName  := EJA->EJA_FILE
      cFileName  := StrTrim(Val(cFileName)+1)
      nZero      := nZero - Len(cFileName)
      cFileName  := Replicate("0", nZero) + cFileName
   Else
      cFileName  := Replicate("0", nZero - 1) + "1"
   End If
   */

//Return SM0->M0_CODIGO+"CAMT057-"+MV_PAR04+"_"+Ei201DtHr(dDataBase, cEI201Hora,,, "_")
Return AllTrim(MV_PAR04)+"_CAMT057-"+"BCIT"+"_"+Ei201DtHr(dDataBase, cEI201Hora,,, "_")

Static Function StrTrim(cTexto)
  cTexto := AllTrim(Str(cTexto))
Return cTexto



/*------------------------------------------------------------------------------------------------------------------
Função    : CriaWork(cAlias)
Objetivos : Cria work para controle de parcelas a vincular selecionadas.
Parametros:
Retorno   :
Autor     : Fabrício Romera
Data      : 10/12/2002
------------------------------------------------------------------------------------------------------------------*/
Static Function CriaWork(cAlias)
//Local aStruct := {}
Local cNomArq1:= ""
Private aStruct := {}//RMD - Possibilita alterar a estrutura do temporário via ponto de entrada

aCampos   := array(EEQ->(fcount()))
   /*aStruct := {{"WK_FLAG", "C", 02, 0},;
               {"EJA_RECNO" , "N", 10, 0},; //Campo para guardar o recno do registro da EJA, quando a parcela for selecionada para vinculo.
               {"R_E_C_N_O_", "N", 10, 0}}*/

   aAdd(aStruct, {"WK_FLAG"   , "C", 02, 0})
   aAdd(aStruct, {"EJA_RECNO" , "N", 10, 0})
   aAdd(aStruct, {"EEQ_FILIAL", "C", 02, 0})
   aAdd(aStruct, {"WK_RECNO", "N", 10, 0})
   aAdd(aStruct, {"EEQ_PREEMB", "C", AVSX3("EEQ_PREEMB",3), AVSX3("EEQ_PREEMB",4)})
   //RMD - Possibilita alterar a estrutura do temporário via ponto de entrada
   If ExistBlock("EECEI201")
      ExecBlock("EECEI201", .F., .F., "CRIAWORK")
   EndIf

   If Select(cAlias) == 0
      DbSelectArea("EEQ")
      cNomArq1 := E_CriaTrab("EEQ",aStruct, cAlias)
   Else
      (cAlias)->(avzap())
   EndIf

Return

/*------------------------------------------------------------------------------------------------------------------
Função    : EI201EnvParc()
Objetivos :
Parametros:
Retorno   :
Autor     : Fabrício Romera
Data      : 11/12/2009
------------------------------------------------------------------------------------------------------------------*/
Static Function EI201EnvParc(lAuto)
Local lRet      := .F.
Local cAlias    := ""
Local nStatus   := ""
Local cNomeArq  := ""
Private aRecEJA   := {} , aRecEEQ := {}
Default lAuto := .F.

Begin Sequence

   //Preenche campos necessários para busca pelo arquivo.
   cAlias    := Alias()
   cNomeArq  :=(cAlias)->EJA_FILE

   If lRet := lAuto .Or. MsgYesNo("Deseja enviar o arquivo " + AllTrim(cNomeArq) + "?", "Aviso")

      //*** Define o diretório local para gravação do arquivo a ser enviado.
      If !lAuto
         cDirTemp := cGetFile("","Diretório local para exportação de arquivos.", 0, cDirTemp,, GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY)
      EndIf
      If Empty(cDirTemp)
         Break
      EndIf
      //Grava a opção selecionada no temporário do usuário
      WriteProfString("EEC_INTCASH","DIR_EXPORT",cDirTemp,.T.)
      //***

      //*** Busca todos os Recnos envolvidos (tabela EJA).
      BuscaRecEEQ(1,cAlias,@aRecEJA)
      //***

      //*** Copia arquivo do servidor para a pasta local indicada pelo usuário
      If !CopiaArq(cNomeArq, cDirServNE, cDirTemp, .F.)
         Break
      End If
      //***

      //*** Exibe tela de controle de envio (caso não seja automático)
      If !TelaEnvio(cNomeArq, cDirTemp, @nStatus/*, cNroControle*/, lAuto)
         Break
      EndIf
      //***

      //*** Atualiza o status dos registros EJA enviados
      If nStatus = 1 //Enviados
         If AlteraEJA(nStatus,aRecEJA/*,aRecEEQ RMD - Parâmetro não utilizado*/)
            CopiaArq(cNomeArq, cDirServNE, cDirServE, .T.)
         EndIf
      ElseIf nStatus = 2 //Confirmados
         If EI201ExecParc()
            If AlteraEJA(nStatus,aRecEJA/*,aRecEEQ RMD - Parâmetro não utilizado*/)
               CopiaArq(cNomeArq, cDirServNE, cDirServC, .T.)
            EndIf
         EndIf
      ElseIf nStatus = 3 //Cancelados
         If AlteraEJA(nStatus,aRecEJA/*,aRecEEQ RMD - Parâmetro não utilizado*/)
            CopiaArq(cNomeArq, cDirServNE, cDirServRJ, .T.)
         EndIf
      EndIf
      //***

      If !(nStatus = 0 .Or. nStatus = 4)
         ExcluiArquivo(cNomeArq, cDirServNE)
         If !lAuto
            cMsgEnv := "Concluído o envio do arquivo 'XXX'."
            cMsgEnv := StrTran(cMsgEnv, 'XXX', Alltrim(cNomeArq))
            MsgAuto(cMsgEnv, "Aviso")
	     EndIf
      EndIf

   EndIf

End Sequence


Return lRet


/*
Função    : TelaEnvio()
Objetivos : Exibir tela de processo de envio do arquivo Int Cash.
Parametros: cDirTemp: Caminho completo do diretorio temporario
Retorno   : nRadio: Situação do Envio(1-Vinculado, 2-Rejeitado, 3-Cancelado)
Autor     : Fabrício Romera
Data      : 04/11/2009
*/
Static Function TelaEnvio(cNomeArq, cDirTemp, nStatus/*, cNroControle*/, lAuto)
   Local oDlgEnv, oPanelEnv1, oPanelEnv2, oGetDirTemp, oSayDirTemp/*, oSayNControle, oGetNControle*/, oRad, oSayStatus
   Local cSayDirTemp, /*cSayNControle, cGetNControle,*/ cSayStatus
   Local nRadio, nFase
   Local aOpc[0]
   Local lCancel := .T.

   Local bSetGet := {|u| If(PCount()>0, nRadio:= 1, nRadio)}
   Local bOk     := {|| lCancel:=.F., TelaEnvioOk(/*@cGetNControle,*/ @oPanelEnv1, @oPanelEnv2, @nFase, @oDlgEnv)}
   Local bCancel := {|| lCancel:=.T., oDlgEnv:End()}

   Default lAuto := .F.

   //Conteudo dos Objetos da Tela
   cSayDirTemp   := "Diretório do Arquivo Int Cash:"
   cDirTemp      := cDirTemp + AllTrim(cNomeArq) + ".xml"
  /* cSayNControle := "Informe o Nº de Controle:"
   cGetNControle := Space(20)*/
   cSayStatus    := "Informe a situação do envio:"
   nRadio        := 1
   nFase         := 1

   //Opções do RadioMenu
   aAdd(aOpc, "Enviado")
   aAdd(aOpc, "Conciliar Manualmente")
   aAdd(aOpc, "Cancelado")
   aAdd(aOpc, "Cancelar")

   If !lAuto

	   //Cria Tela de Controle de Envio
	   DEFINE MSDIALOG oDlgEnv TITLE "Envio de Arquivo International Cash" FROM 1, 1;
	                                                    TO 250, 400;
	                                                    PIXEL

	   //Primeira etapa do controle de envio
	   oPanelEnv1 := tPanel():New(1,1, "", oDlgEnv,,,,,,100,100)
	   oPanelEnv1:Align := CONTROL_ALIGN_ALLCLIENT

	   @ 25, 10 SAY   oSayPesLiq    VAR cSayDirTemp    SIZE 180, 10 OF oPanelEnv1 PIXEL
	   @ 35, 10 MSGET oGetDirTemp   VAR cDirTemp       SIZE 180, 10 OF oPanelEnv1 PIXEL

	 //  @ 50, 10 SAY   oSayNControle VAR cSayNControle  SIZE 180, 10 OF oPanelEnv1 PIXEL
	 //  @ 60, 10 MSGET oGetNControle VAR cGetNControle  SIZE 180, 10 OF oPanelEnv1 PIXEL



	   //Segunda etapa do controle de envio
	   oPanelEnv2 := tPanel():New(1,1, "", oDlgEnv,,,,,,100,100)
	   oPanelEnv2:Align := CONTROL_ALIGN_ALLCLIENT

	   @ 25, 10 SAY   oSayStatus    VAR cSayStatus     SIZE 180, 10 OF oPanelEnv2 PIXEL
	   oRad := TRadMenu():New( 35,10, aOpc, {|u| If(PCount()>0, nRadio:= u, nRadio)},oPanelEnv2,,,,,,,,90,09,,,,.T.)


	   //Exibe primeira etapa de controle de envio
	   oPanelEnv1:Show()
	   oPanelEnv2:Hide()

	   ACTIVATE MSDIALOG oDlgEnv CENTERED ON INIT EnchoiceBar(oDlgEnv, bOk, bCancel)

   Else

      nRadio  := 1
      lCancel := .F.

   EndIf

   If lCancel
      nRadio = 4 //Cancelado
   End If

   //Devolve situação de envio
   nStatus := nRadio

   //Devolve numero de controle
   //cNroControle := cGetNControle

Return !lCancel

/*
Função    : TelaEnvioOk()
Objetivos : Controlar evento click do botão Ok da EnchoiceBar
Parametros: cGetNControle, oPanelEnv1, oPanelEnv2, nFase, oDlgEnv
Retorno   :
Autor     : Fabrício Romera
Data      : 09/11/2009
*/
Static Function TelaEnvioOk(/*cGetNControle,*/ oPanelEnv1, oPanelEnv2, nFase, oDlgEnv)

   Begin Sequence

      If nFase = 1

         //Verifica se nº de controle foi informado
         /*If Empty(cGetNControle)
            MsgInfo("Nº de controle não informado.", "Aviso")
            Break
         End If*/

         //Exibe segunda etapa do controle de envio
         oPanelEnv1:Hide()
         oPanelEnv2:Show()
         nFase++

      Else

         oDlgEnv:End()

      End If

   End Sequence

Return

/*------------------------------------------------------------------------------------------------------------------
Função    : BuscaEEQ()
Objetivos : Busca todas parcelas de cambio na tabela EEQ que estao com datas credito no Exterio, Solicitação de Cambio
            e Negociação nao estiverem preenchidas, alem disso verifica - se as parcelas já estao vinculadas na integraçao,
            se sim não é apresentadas.
Parametros: cPreemb, cDtVcIni, cDtVcFim
Retorno   :
Autor     : Allan Oliveira Monteiro
Data      : 09/02/2011
------------------------------------------------------------------------------------------------------------------*/
Static Function BuscaEEQ(cPreemb, cDtVcIni, cDtVcFim)
   Local lRet    := .F.
   Local cConcat := If(Upper(AllTrim(TCGETDB()))=="ORACLE","||","+")
   Private cSql  := ""

   //*** Prepara o Select na base de dados
   cSql := " SELECT Q.R_E_C_N_O_ As WK_RECNO, * FROM " + RetSqlName("EEQ") + " Q"//RMD - Adicionado o recno para possibilitar o carregamento no temporário no AvReplace (o nome do campo no temporário foi alterado em manutenção anterior)
   cSql += " Where Q.EEQ_PREEMB "+cConcat+" Q.EEQ_PARC NOT IN ( "
   cSql += " SELECT S.EJA_PREEMB "+cConcat+" S.EJA_PARC FROM "+ RetSqlName("EJA") + " S where S.EJA_STATUS <> 'R' AND S.D_E_L_E_T_ <> '*')"
   cSql += " AND Q.EEQ_DTCE = '' AND Q.EEQ_SOL = '' AND Q.EEQ_DTNEGO = '' AND Q.D_E_L_E_T_ <> '*' AND Q.EEQ_TIPO = 'R' "
   If !Empty(cPreemb)
      //cSql += " AND Q.EEQ_NRINVO = '" + cPreemb + "'"
      cSql += " AND Q.EEQ_FFC = '" + cPreemb + "'"
   EndIf
   If !Empty(cDtVcIni)
      cSql += " AND Q.EEQ_VCT >= '" + cDtVcIni + "'"
   EndIf
   If !Empty(cDtVcFim)
      cSql += " AND Q.EEQ_VCT <= '" + cDtVcFim + "'"
   EndIf
   If !Empty(MV_PAR08)
      cSql += " AND Q.EEQ_MOEDA = '" + AvKey(MV_PAR08, "EEQ_MOEDA") + "'"
   EndIf
   If !Empty(MV_PAR09)
      //cSql += " AND Q.EEQ_FILIAL = '" + AvKey(MV_PAR09, "EEQ_FILIAL") + "'"
      cSql += " AND Q.EEQ_FILIAL In (" + MV_PAR09 + ") "
   EndIf
   //***

   //Possibilita personalizar o Select
   If EasyEntryPoint("EECEI201")
      ExecBlock("EECEI201", .F., .F., "ANTES_SQL")
   EndIf

   cSql := ChangeQuery(cSql)

   //Cria view
   DbUseArea(.T., "TOPCONN", TCGENQRY(,,cSql), "WK_TEMP", .F., .T.)

   //Ajusta tipo de campos dBase contra tipo SQL
   SX3->(DbSetOrder(1))
   SX3->(DbSeek("EEQ"))
   While SX3->X3_ARQUIVO == "EEQ"
      If SX3->X3_TIPO $ "D/L"
         TCSetField("WK_TEMP", SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, 0)
      EndIf
      SX3->(DbSkip())
   EndDo

   //Transfere dados da View para a Work que sera utilizada
   Do While WK_TEMP->(!EOF())
      WK_SEL->(DbAppend())
      AvReplace("WK_TEMP","WK_SEL")
      //Já exibe a parcela selecionada
      WK_SEL->WK_FLAG := cMarca
      WK_TEMP->(DbSkip())
   EndDo

   //Verifica se foram encontradas parcelas
   If WK_SEL->(EOF())
      cMsgBusca := "Não foram encontradas parcelas (XXX)."
      cMsgBusca := StrTran(cMsgBusca, "XXX", cDadosParam)
      MsgAuto(cMsgBusca, "Aviso")
      lRet := .F.
   Else
      lRet := .T.
   End If

   WK_SEL->(DbGoTop())

   //Exclui WK_TEMP
   WK_TEMP->(DbCloseArea())
   FErase("WK_TEMP"+GetDbExtension())

Return lRet

/*------------------------------------------------------------------------------------------------------------------
Função    : SelParcCambio()
Objetivos :
Parametros:
Retorno   : -
Autor     : Fabrício Romera
Data      : 11/12
------------------------------------------------------------------------------------------------------------------*/
Static Function SelParcCambio(lAuto)
   Local oDlg, oSel, oBut
   Local aPos, aSelPos
   Local bOk := {|| oDlg:End()}
   Local bCancel := {|| lCancel := .T., oDlg:End()}
   Local bMarcaTodos := {|u| MarcaTodos(cMarca,"WK_SEL","WK_FLAG")}
   Local cTitulo := "Seleção de Parcelas de Cambio a Gerar"
   Local lRet := .F., lCancel := .F.
   Local aButtons := {{"LBTIK",bMarcaTodos ,"Marcar/Desmarcar Todos"}}
   Private lSelec := .F.

   Private lInverte := .F.
   Default lAuto := .F.

   //Define aCampos
   aCampos := {;
                 {"WK_FLAG",,"",},;
                 {"EEQ_PREEMB",,AvSx3("EEQ_PREEMB",AV_TITULO),AvSx3("EEQ_PREEMB",AV_PICTURE)},;
                 {"EEQ_EVENT" ,,AvSx3("EEQ_EVENT" ,AV_TITULO),AvSx3("EEQ_EVENT" ,AV_PICTURE)},;
                 {"EEQ_NRINVO",,AvSx3("EEQ_NRINVO",AV_TITULO),AvSx3("EEQ_NRINVO",AV_PICTURE)},;
                 {"EEQ_PARC"  ,,AvSx3("EEQ_PARC"  ,AV_TITULO),AvSx3("EEQ_PARC"  ,AV_PICTURE)},;
                 {"EEQ_VCT"   ,,AvSx3("EEQ_VCT"   ,AV_TITULO),AvSx3("EEQ_VCT"   ,AV_PICTURE)},;
                 {"EEQ_VL"    ,,AvSx3("EEQ_VL"    ,AV_TITULO),AvSx3("EEQ_VL"    ,AV_PICTURE)},;
                 {"EEQ_MOEDA" ,,AvSx3("EEQ_MOEDA" ,AV_TITULO),AvSx3("EEQ_MOEDA" ,AV_PICTURE)};
              }
   //RMD - Possibilita customizar o range de parcelas apresentadas
   If ExistBlock("EECEI201")
      ExecBlock("EECEI201", .F., .F., "SELPARCCAMBIO")
   EndIf

   If !lAuto

	   //Cria Tela de Seleção de Parcelas
	   DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI, DLG_COL_INI TO DLG_LIN_FIM, DLG_COL_FIM OF oMainWnd PIXEL

	   //Pega Coordenadas da Tela
	   aPos := PosDlg(oDlg)

	   aSelPos := {aPos[1], aPos[2],aPos[3],aPos[4]}

	   //Cria oSelect
	   oSel := MsSelect():New("WK_SEL","WK_FLAG",, aCampos, @lInverte, @cMarca,aSelPos,,, oDlg)

	   //Rotina que controla marca/desmarca
	   oSel:bMark := {||VerParcSel("WK_SEL"), oSel:oBrowse:Refresh() }

	   //Exibe tela
	   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bOk, bCancel,,aButtons)

   EndIf

   If !lCancel

      WK_SEL->(DbGoTop())

      //Transfere parcela selecionada para a work de controle de parcelas a vincular
      Begin Sequence
         Do While WK_SEL->(!EOF())

            If WK_SEL->WK_FLAG = cMarca
               WK_EEQ->(DbAppend())
               AvReplace("WK_SEL","WK_EEQ")
               WK_EEQ->EEQ_FILIAL := WK_SEL->EEQ_FILIAL
            EndIf
            WK_SEL->(DbSkip())
         EndDo

      End Sequence

      lRet := .T.

   End If

Return lRet

/*------------------------------------------------------------------------------------------------------------------
Função    : MarcaTodos()
Objetivos : Marca/Desmarca todos os registros de uma work
Parametros: cMarca, cAliasWK: Alias da Work, cCampoFlag: nome do campo Flag
Retorno   : -
Autor     : Fabrício Romera
Data      : 11/12
-------------------------------------------------------------------------------------------------------------------*/
Static Function MarcaTodos(cMarca, cAliasWK, cCampoFlag)
   Local nRec

   nRec := (cAliasWK)->(RecNo())
   cMarca  := IF(!Empty((cAliasWK)->&(cCampoFlag)),Space(2),cMarca)

   (cAliasWK)->(dbGotop())
   (cAliasWK)->(DbEval({||(cAliasWK)->&(cCampoFlag):= cMarca},{|| .t. }))
   (cAliasWK)->(DbGoTo(nRec))

Return

/*------------------------------------------------------------------------------------------------------------------
Função    : ExcluiWork()
Objetivos : Excluir arquivo de trabalho utilizado na seleção de embarque.
Parametros:
Retorno   : -
Autor     : Fabrício Romera
Data      : 03/11
-------------------------------------------------------------------------------------------------------------------*/
Static Function ExcluiWork(cWork)

   //Exclui arquivo de trabalho
   If Select(cWork) > 0
      &(cWork)->(DbCloseArea())
     FErase(cWork+GetDbExtension())
   End If

Return

/*------------------------------------------------------------------------------------------------------------------
Função    : EI201RejArq()
Objetivos : Altera status do arquivo selecionado para "Rejeitado".
Parametros:
Retorno   : -
Autor     : Fabrício Romera
Data      : 03/11 - 16:15
Obs.      :
------------------------------------------------------------------------------------------------------------------*/
Static Function EI201RejArq(lAuto, cNomeArq, cStatus)//RMD - Possibilita especificar o arquivo/status que será rejeitado
Local lRet:= .F.
Local cDirOri := ""
Local cAlias := Alias(), cDirServNE := "", cDirServRJ := ""
Private aRecEJA := {}, aRecEEQ := {} 
Default cNomeArq := (cAlias)->EJA_FILE
Default cStatus := (cAlias)->EJA_STATUS
Default lAuto := .F.
   
Begin Sequence

   /* RMD - Deve se basear no arquivo informado no parâmetro/default da variável
   //Obtem informações do arquivo selecionado
   cAlias     := Alias()
   cNomeArq   := (cAlias)->EJA_FILE
   cSeqArq    := (cAlias)->EJA_SEQ
   cEEQPreemb := (cAlias)->EJA_PREEMB
   cEEQParc   := (cAlias)->EJA_PARC
   cEEQFase   := (cAlias)->EJA_FASE
   cStatus    := (cAlias)->EJA_STATUS
   */

   //Carrega os diretórios
   cDirServNE:= "\comex\cambio\conciliacao\naoenviados\"
   cDirServE := "\comex\cambio\conciliacao\enviados\"
   cDirServC := "\comex\cambio\conciliacao\confirmados\"
   cDirServRJ:= "\comex\cambio\conciliacao\cancelados\"

   //Define o diretório atual com base no status
   DO CASE
      Case cStatus == "N"
         cDirOri := cDirServNE
      Case cStatus == "V"
         cDirOri := cDirServE
      Case cStatus == "C"
         cDirOri := cDirServC
   END CASE

   //Confirma o cancelamento
   If lRet:= lAuto .Or. MsgYesNo("Deseja Cancelar o arquivo " + AllTrim(cNomeArq) + "?", "Aviso")

      //Busca Recno dos registros na tabela EJA
      //BuscaRecEEQ(2,cAlias,@aRecEJA,@aRecEJA,(cAlias)->EJA_STATUS)//RMD - Deve considerar a variável cStatus, e o quarto parâmetro não é usado
      BuscaRecEEQ(2,cAlias,@aRecEJA,,cStatus)

      If !Empty(aRecEJA)
         If File(cDirOri + cNomeArq)//RMD - Verifica se o arquivo realmente existe (pode ter sido apagado por outra parcela)
            //Copia arquivo da pasta naovinculados para pasta rejeitados
            CopiaArq(cNomeArq, cDirOri, cDirServRJ, .T.)
            //Exclui o arquivo original
            ExcluiArquivo(cNomeArq, cDirOri)
         EndIf
         //Altera Status de Envio para Rejeitado
         AlteraEJA(3,aRecEJA)
      EndIf
   EndIf

End Sequence

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
   FErase(AllTrim(cDirTemp) + AllTrim(cNomeArq) + ".xml")
Return

/*------------------------------------------------------------------------------------------------------------------
Função    : AlteraEJA()
Objetivos : Alterar Status de envio de arquivo p/ vinculado ou
do e demais informações.
Parametros: nStatus: Codigo do status selecionado pelo usuario(1-Enviado, 2-Rejeitado)
            nRecEJA: Recno do registro que sera alterado na tabela EJA.
            nRecEEQ: Recno da parcela de cambio correspondente ao arquivo/Seq da tabela EEQ.
                     (Usado somente em caso de Vinculo).
Retorno   :
Autor     : Fabrício Romera
Revisao   : Allan Oliveira Monteiro - 10/02/2011
Data      : 09/11/2009
------------------------------------------------------------------------------------------------------------------*/
Static Function AlteraEJA(nStatus, aRecEJA)
   Local lRet := .F.
   Local i
   Default aRecEJA := {} , nStatus := 0


Begin Sequence

   If Empty(aRecEJA)
      Break
   EndIf

   For i:= 1 to Len(aRecEJA)

      //Posiciona no registro e altera EJA.
      DbSelectArea("EJA")
      EJA->(DbGoTo(aRecEJA[i]))

      If EJA->(!EOF())
         EJA->(RecLock("EJA",.F.))

         If nStatus = 1 //Enviados
            /* RMD - Não dev atualizar os dados da parcela do EEQ. Estes dados já são definidos na inclusão do EJA
            //Busca informações da parcela de cambio vinculada ao arquivo.
            lEEQ := Len(aRecEEQ) <> 0 //LGS-18/11/2015
            If lEEQ
               DbSelectArea("EEQ")
               EEQ->(DbGoTo(aRecEEQ[i]))
               If EEQ->(!EOF())
                  cEEQPreemb := EEQ->EEQ_PREEMB
                  cEEQParc   := EEQ->EEQ_PARC
                  cEEQFase   := EEQ->EEQ_FASE
               EndIf
            EndIf
            */

            EJA->EJA_STATUS := "V"
            EJA->EJA_USEREN := AllTrim(cUserName)
            EJA->EJA_DTENV  := dDataBase
            EJA->EJA_HRENV  := Time()

            /*If lEEQ
               EJA->EJA_PREEMB := cEEQPreemb  //Emb. da parcela vinculada ao registro de Intl. Cash
               EJA->EJA_PARC   := cEEQParc    //Nro. da parcela vinculada ao registro de Intl. Cash
               EJA->EJA_FASE   := cEEQFase    //Fase da parcela vinculada ao registro de Intl. Cash
            EndIf
            */
         ElseIf nStatus = 2
            EJA->EJA_STATUS := "C" //Confirmado
            If Empty(EJA->EJA_USEREN) .And. Empty(EJA->EJA_DTENV) .And. Empty(EJA->EJA_HRENV)
               EJA->EJA_USEREN := AllTrim(cUserName)
               EJA->EJA_DTENV  := dDataBase
               EJA->EJA_HRENV  := Time()
            EndIf
            /*
            EJA->EJA_PREEMB := cEEQPreemb          //Emb. da parcela vinculada ao registro de Intl. Cash
            EJA->EJA_PARC   := cEEQParc            //Nro. da parcela vinculada ao registro de Intl. Cash
            EJA->EJA_FASE   := cEEQFase
            */
            EJA->EJA_USERCF := AllTrim(cUserName)
            EJA->EJA_DTCOF  := dDataBase
            EJA->EJA_HRCOF  := Time()

         ElseIf nStatus = 3 //Rejeitado
            EJA->EJA_STATUS := "R"
            EJA->EJA_USERRE := AllTrim(cUserName)
            EJA->EJA_DTREJ  := dDataBase
            EJA->EJA_HRREJ  := Time()
         End If

         EJA->(MsUnlock())

         lRet := .T.

      End If

   Next i

End Sequence

Return lRet


/*------------------------------------------------------------------------------------------------------------------
Função    : AltAutoEEQ()
Objetivos : Simula processo de manutenção na tabela EEQ alterando os campos conforme especificado.
Parametros:
Retorno   :
Autor     : Rodrigo Mendes
Data      : 16/12/2009
Revisão   : Fabrício Romera - 16/12/2009 - Ajustes p/ func. adequado no processo de Vinc. Intl. Cash
Obs.      : aEEQAuto = {cDescrCampo : Descrição do Campo.
                        xConteudo   : Conteudo que o campo ira receber.
                       )
------------------------------------------------------------------------------------------------------------------*/
Static Function AltAutoEEQ(aRecno, aEEQCampos)

   Local i
   Local cFilAtu
   //Guarda o retorno da execução automática
   Private lRet := .T.
   //Indica a operação a ser executada na manutenção de câmbio
   Private nEEQAuto := ALTERAR
   //Define a ação a ser executada na manutenção (botão da enchoicebar)
   Private bEEQAuto := {|| lRet := AltItemAuto(aRecno[i]) }
   //Guarda os campos que serão alterados
   Private aEEQAuto := aEEQCampos

   Private lEEQAuto := .T.
   Private LINTFINA
   Private aEEC

   Default aRecno := {}

   For i:= 1 to Len(aRecno)

      //Posiciona no registro da tabela EEC correspondente à parcela a ser alterada
      EEQ->(DbGoTo(aRecno[i]))

      //Ajusta cFilAnt para os casos de MultiFilial
      If !Empty(EEQ->EEQ_FILIAL)
      	cFilAtu := cFilAnt
      	cFilAnt := EEQ->EEQ_FILIAL
      EndIf

      EEC->(DbSetOrder(1))
      EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))

      //Executa manutenção na tabela
      If EEC->(!EOF())
         AF200MAN("EEQ", aRecno[i], nEEQAuto)
      End If

      //*** RMD - 19/11/15 - Tratamento adicional para verificar se as informações foram realmente gravadas
		If lRet
			EEQ->(DbGoTo(aRecno[i]))
      		aEval(aEEQCampos, {|x| If(EEQ->&(x[1]) <> x[2], lRet := .F., ) })
   		EndIf
      //***

      //Restaura a filial
      If !Empty(cFilAtu)
      	cFilAnt := cFilAtu
      EndIf

   Next i

Return lRet

//Executada após carregar a capa do câmbio, aciona a alteração da parcela desejada
Static Function AltItemAuto(nRecno)
   Local lRet
   Private lEEQAuto := .T.
   Private bEEQAuto := {|| }
   Private lExecAuto := .F.//RMD - Variável adicionada no Câmbio, precisa ser carregada para chamada externa


   //Posiciona a Work
   PosTMP(nRecno)
   //Executa a alteração
   lRet := AF200DetMan(ALT_DET,, .T.)

Return lRet

/*------------------------------------------------------------------------------------------------------------------
Função    : PosTMP()
Objetivos : Posiciona a Work interna da rotina de câmbio na parcela desejada, a partir do Recno da base de dados
Parametros: nRecno
Retorno   : -
Autor     : Rodrigo Mendes
Data      : 16/12/2009
------------------------------------------------------------------------------------------------------------------*/
Static Function PosTMP(nRecno)

   TMP->(DbGoTop())
   While TMP->(!Eof())
      If TMP->TMP_RECNO == nRecno
         Exit
      EndIf
      TMP->(DbSkip())
   EndDo

Return Nil

/*------------------------------------------------------------------------------------------------------------------
Função    : EI201ExecParc()
Objetivos : Executa função de alteração de parcelas de cambio(EEQ), para cada parcela selecionada durante o processo
            de vinculo de parcelas
Parametros:
Retorno   : -
Autor     : Fabrício Romera
Revisao   : Allan Oliveira Monteiro - 10/02/2010
Data      : 16/12/2009
------------------------------------------------------------------------------------------------------------------*/
Static Function EI201ExecParc()
   Local lRet       := .T.
   Local bListaWKEEQ:={|| lRet:= CarregaWKEEQ()}
   Local cNomeArq  := ""
   Private cAlias := Alias(), aRecEEQ := {}, aRecEJA := {}, aEEQCampos := {}


   Begin Sequence

      cNomeArq  := (cAlias)->EJA_FILE

      If WK_EEQ->(EasyRecCount()) == 0
         Processa(bListaWKEEQ, "Carrega Arquivo de Trabalho", "Carregando Arquivo...", .T.)
      EndIf

      lRet:= TelaDtCredExt()

      If lRet

         //Inicializa a variavel para efetuar a validaçao da manutençao de cambio
         lRet := .F.

         WK_EEQ->(DbGoTop())

         //Varre arquivo de trabalho de parcelas selecionadas
         Do While WK_EEQ->(!EOF())

            If WK_EEQ->(!Deleted()) .And. !Empty(WK_EEQ->EEQ_DTCE)

               //Define array de campos e conteudos a alterar
               aEEQCampos := {}
               aAdd(aEEQCampos, {"EEQ_DTCE", WK_EEQ->EEQ_DTCE})
			   aAdd(aEEQCampos, {"EEQ_BCOEXT", MV_PAR04})
			   aAdd(aEEQCampos, {"EEQ_AGCEXT", MV_PAR05})
			   aAdd(aEEQCampos, {"EEQ_CNTEXT", MV_PAR06})

			   If EasyEntryPoint("EECEI201")
                  ExecBlock("EECEI201", .F., .F., "AEEQCAMPOS_ALTERACAO")
               EndIf

               //Executa simulação de processo de manutenção de parcelas de cambio para alterar Data e Valor de Cred. Ext.
               If !AltAutoEEQ({WK_EEQ->WK_RECNO}, aEEQCampos)
                  Break
               End If

               //Altera Tabela de Controle de Integração Intl. Cash
               If !AlteraEJA(1, {WK_EEQ->EJA_RECNO}/*, {WK_EEQ->WK_RECNO} RMD - Parâmetro não utilizado*/)
                  Break
               End If

               lRet := .T.

            End If

            WK_EEQ->(DbSkip())

         EndDo

      EndIf

      If lRet


         If UPPER(AllTrim(Procname())) <> UPPER("EI201EnvParc")

            //Busca Recno do registro na tabela EJA
            BuscaRecEEQ(0,cAlias,@aRecEJA/*,@aRecEJA - RMD - Parâmetro duplicado*/)

            AlteraEJA(2,aRecEJA/*,aRecEEQ RMD - Parâmetro não utilizado*/)
            If !CopiaArq(cNomeArq, cDirServE, cDirServC, .T.)
               Break
            EndIf

            ExcluiArquivo(cNomeArq, cDirServE)

            MsgInfo("Parcelas vinculadas com sucesso!", "Intl. Cash")
         EndIf

      Else
         MsgInfo("Nenhuma parcela vinculada"       , "Intl. Cash")
      End If

   End Sequence

Return lRet




/*------------------------------------------------------------------------------------------------------------------
Função    : VerParcSel()
Objetivos : Controlar seleção de parcelas para que apenas uma parcela por vez possa ser selecionada.
Parametros: cMarca
Retorno   : -
Autor     : Fabrício Romera
Data      : 12/01/2010
Obs.      :
------------------------------------------------------------------------------------------------------------------*/
Static Function VerParcSel(cAliasWK)

   DbSelectArea(cAliasWK)

   //Controla seleção de parcelas
   If !Empty((cAliasWK)->WK_FLAG)
      //Verifica se alguma parcela já foi selecionada
      (cAliasWK)->WK_FLAG := cMarca//Permite seleção da parcela
   Else
      (cAliasWK)->WK_FLAG := "  "
   End If


Return cMarca

/*------------------------------------------------------------------------------------------------------------------
Função    : ParcelaSel()
Objetivos : Verifica se parcela corrente da WK_TEMP, ja existe na WK_SEL. Usada para controlar seleção de parcelas
            impedindo que uma parcela seja exibida para seleção se já estiver selecionada em outra parcela.
Parametros: -
Retorno   : -
Autor     : Fabrício Romera
Data      : 13/01/2010
Obs.      :
------------------------------------------------------------------------------------------------------------------*/
Static Function ParcelaSel()
   Local lRet := .F.

   WK_EEQ->(DbGoTop())

   //Varre work de parcelas selecionadas e verifica se parcela corrente ja foi selecionada.
   While WK_EEQ->(!EOF())

      If WK_EEQ->(!Deleted()) .And.;
         WK_EEQ->EEQ_PREEMB = WK_TEMP->EEQ_PREEMB .And.;
         WK_EEQ->EEQ_EVENT  = WK_TEMP->EEQ_EVENT  .And.;
         WK_EEQ->EEQ_NRINVO = WK_TEMP->EEQ_NRINVO .And.;
         WK_EEQ->EEQ_PARC   = WK_TEMP->EEQ_PARC   .And.;
         WK_EEQ->EEQ_VL     = WK_TEMP->EEQ_VL

         lRet := .T.

      End If

      WK_EEQ->(DbSkip())

   End

Return lRet

/*------------------------------------------------------------------------------------------------------------------
Função    : LimpaWork()
Objetivos : Limpar work.
Parametros: cAlias
Retorno   : -
Autor     : Fabrício Romera
Data      : 13/01/2010
Obs.      :
------------------------------------------------------------------------------------------------------------------*/
Static Function LimpaWork(cAlias)

   DbSelectArea(cAlias)

   &(cAlias)->(avzap())

Return

/*
Função    : CopiaArq()
Objetivos : Copiar arquivo de Int. Cash do servidor para o diretorio temporario da maquina do usuario.
Parametros:
Retorno   : cDirTemp: Caminho completo do diretorio temporario
Autor     : Fabrício Romera
Data      : 04/11/2009
*/
Static Function CopiaArq(cFileName, cDirOrig, cDirDest, lSilent)
  Local lRet := .T.
  Default lSilent := .F.

  //Copia Arquivo
  If File(cDirOrig+AllTrim(cFileName)+".xml")
     copy file (cDirOrig+AllTrim(cFileName)+".xml") to (cDirDest+AllTrim(cFileName)+".xml")
  EndIf

  If FError() > 0 .And. !lSilent
     MsgAuto("Não foi possivel copiar o arquivo para a pasta " + AllTrim(cDirDest) + ".", "Aviso")
     lRet := .F.
  EndIf

Return lRet


/*------------------------------------------------------------------------------------------------------------------
Função    : CarregaWKEEQ()
Objetivos : Carrega as parcelas do arquivo seleciona para WKEEQ
Parametros:
Retorno   : -
Autor     : Allan Oliveira Monteiro
Data      : 10/02/2011
------------------------------------------------------------------------------------------------------------------*/
Static Function CarregaWKEEQ()

Local lRet       := .F.
Local cAlias     := ""

 cAlias := Alias()

   //Busca Recno do registro na tabela EJA
   EJA->(DbSetOrder(1))
   EJA->(DbGotop())
   If EJA->(DbSeek(xFilial("EJA")+(cAlias)->EJA_FILE+"1  "/*+(cAlias)->EJA_SEQ*/))
      While EJA->(!EOF()) .And. AllTrim(EJA->EJA_FILE) == AllTrim((cAlias)->EJA_FILE)
         If !Empty(EJA->EJA_PREEMB) .And. !Empty(EJA->EJA_PARC) .And. !Empty(EJA->EJA_FASE) .And. (EJA->EJA_STATUS == "V" .Or. EJA->EJA_STATUS == "N")

            //Busca Recno da parcela vinculada ao arquivo, na tabela EEQ.
            EEQ->(DbSetOrder(1))
            If EEQ->(DbSeek(xFilial("EEQ")+EJA->EJA_PREEMB+EJA->EJA_PARC+EJA->EJA_FASE))
               WK_EEQ->(DBAPPEND())
               AvReplace("EEQ","WK_EEQ")
               WK_EEQ->EJA_RECNO := EJA->(Recno())
               WK_EEQ->WK_RECNO:= EEQ->(Recno())
               lRet := .T.
            EndIf

         EndIf

       EJA->(DbSkip())
       EndDo
   End If

Return lRet






/*------------------------------------------------------------------------------------------------------------------
Função    : TelaDtCredExt()
Objetivos : Apresenta as parcelas de cambio sem data de credito no exterior
Parametros:
Retorno   : -
Autor     : Allan Oliveira Monteiro
Data      : 11/02/2011
------------------------------------------------------------------------------------------------------------------*/

*--------------------------------*
Static Function TelaDtCredExt()
*--------------------------------*

   Local oDlgEnv, oSel, oBut, oGetDtCred, oSayDtCred, oPanelEnv1, oPanelEnv2
   Local aPos, aSelPos
   Local bOk     := {|| lCancel:=.F., TelaEnvioOk(@oPanelEnv1, @oPanelEnv2, @nFase, @oDlgEnv)}
   Local bCancel := {|| lCancel:=.T., lRet:= .F., oDlgEnv:End()}
   Local bMarcaTodos := {|u| MarcaTodos(cMarca,"WK_EEQ","WK_FLAG")}
   Local cTitulo := "Seleção de Parcelas para Credito no Exterior"
   Local lRet := .T., lCancel := .F.
   Local nFase, nCont, cSayDtCred, cDtCred := CToD("  /  /  ")
   Local aButtons := {{"LBTIK",bMarcaTodos ,"Marcar/Desmarcar Todos"}}
   Private lSelec := .F.

   Private lInverte := .F.
   Private cMarca   := "nX"


   nFase := 1
   cSayDtCred:= "Informe a Data de Crédito:"

   Begin Sequence

      //Filtro para apresentar as parcelas com a Dt de Cred. Exterior nao preenchidas
      //WK_EEQ->(DBSETFILTER({|| Empty(WK_EEQ->EEQ_DTCE)}, "Empty(WK_EEQ->EEQ_DTCE)"))
      WK_EEQ->(DBGOTOP())

      If WK_EEQ->(EOF())
          MsgInfo("A(s) parcela(s) de cambio ja possue(m) data de Crédito no Exterior","Aviso")
          lRet:= .F.
          Break
      EndIf

      //Define aCampos
      aCampos := {;
                    {"WK_FLAG",,"",},;
                    {"EEQ_PREEMB",,AvSx3("EEQ_PREEMB",AV_TITULO),AvSx3("EEQ_PREEMB",AV_PICTURE)},;
                    {"EEQ_EVENT" ,,AvSx3("EEQ_EVENT" ,AV_TITULO),AvSx3("EEQ_EVENT" ,AV_PICTURE)},;
                    {"EEQ_NRINVO",,AvSx3("EEQ_NRINVO",AV_TITULO),AvSx3("EEQ_NRINVO",AV_PICTURE)},;
                    {"EEQ_PARC"  ,,AvSx3("EEQ_PARC"  ,AV_TITULO),AvSx3("EEQ_PARC"  ,AV_PICTURE)},;
                    {"EEQ_VCT"   ,,AvSx3("EEQ_VCT"   ,AV_TITULO),AvSx3("EEQ_VCT"   ,AV_PICTURE)},;
                    {"EEQ_VL"    ,,AvSx3("EEQ_VL"    ,AV_TITULO),AvSx3("EEQ_VL"    ,AV_PICTURE)},;
                    {"EEQ_MOEDA" ,,AvSx3("EEQ_MOEDA" ,AV_TITULO),AvSx3("EEQ_MOEDA" ,AV_PICTURE)},;
                    {"EEQ_DTCE"  ,,AvSx3("EEQ_DTCE"  ,AV_TITULO),AvSx3("EEQ_DTCE"  ,AV_PICTURE)};
                 }

      //Cria Tela de Seleção de Parcelas
      DEFINE MSDIALOG oDlgEnv TITLE cTitulo FROM DLG_LIN_INI, DLG_COL_INI TO DLG_LIN_FIM, DLG_COL_FIM OF oMainWnd PIXEL


      //Primeiro*----------*
      oPanelEnv1 := tPanel():New(0,0, "", oDlgEnv,,,,,,680,330)


      //Pega Coordenadas da Tela
      aPos := PosDlg(oPanelEnv1)

      aSelPos := {aPos[1], aPos[2],aPos[3],aPos[4]}

      //Cria oSelect
      oSel := MsSelect():New("WK_EEQ","WK_FLAG",, aCampos, @lInverte, @cMarca,aSelPos,,, oPanelEnv1)

      //Rotina que controla marca/desmarca
      oSel:bMark := {||VerParcSel("WK_EEQ"), oSel:oBrowse:Refresh() }


      //Segundo*----------*
      oPanelEnv2 := tPanel():New(,, "", oDlgEnv,,,,,,200,200)

      @ 25, 10 SAY   oSayDtCred    VAR cSayDtCred   OF oPanelEnv2 PIXEL  SIZE 180, 10
      @ 35, 10 MSGET oGetDtCred    VAR cDtCred  SIZE  80, 10 PICTURE AVSX3("EEQ_DTCE",6)  OF oPanelEnv2  PIXEL


      //Exibe primeira etapa de controle de envio
      oPanelEnv1:Show()
      oPanelEnv2:Hide()



      //Exibe tela
      ACTIVATE MSDIALOG oDlgEnv CENTERED ON INIT EnchoiceBar(oDlgEnv, bOk, bCancel,,aButtons)

      If !lCancel

         nCont := 0

         WK_EEQ->(DBGOTOP())

         //Insere a data de Credito no Exterior na WK_EEQ
         WHILE WK_EEQ->(!EOF())

            If !Empty(WK_EEQ->WK_FLAG) .And. Empty(WK_EEQ->EEQ_DTCE)
               WK_EEQ->EEQ_DTCE := cDtCred
            EndIf

            If Empty(WK_EEQ->EEQ_DTCE)
               nCont++
            EndIf

         WK_EEQ->(DBSKIP())
         ENDDO

         /*
         If nCont > 0
            MsgInfo("Existem parcela(s) de cambio sem data de credito. Preencher a data de Credito das parcelas para que possa ser feito a confirmação.","Aviso")
            lRet := .F.
            WK_EEQ->(DBCLEARFILTER())
            //Função recursiva
            TelaDtCredExt()
         EndIf
         */

      lRet := .T.

      End If

   End Sequence

   WK_EEQ->(DBCLEARFILTER())

Return lRet


/*------------------------------------------------------------------------------------------------------------------
Função    : BuscaRecEEQ()
Objetivos : Busca as parcelas de cambio de arcordo com o arquivo selecionado.
Parametros:
Retorno   : -
Autor     : Allan Oliveira Monteiro
Data      : 14/02/2011
------------------------------------------------------------------------------------------------------------------*/
*--------------------------------------------------------*
Static Function BuscaRecEEQ(nTipo,cAlias,aRecEJA,aRecEEQ, cStatus)
*--------------------------------------------------------*
Local cFilEJA := EJA->(xFilial()) //(cAlias)->EJA_FILIAL//RMD - Deve considerar a filial do arquivo, pois a rotina é multifilial
Local cFile := (cAlias)->EJA_FILE
Default aRecEEQ := {}
Default cAlias := Alias()
Default cStatus := ""

If (cAlias)->(FieldPos("EJA_FILIAL")) > 0
   cFilEJA := (cAlias)->EJA_FILIAL
EndIf

If (nTipo == 0)

      //Busca Recno do registro na tabela EJA
      EJA->(DbSetOrder(1))
      EJA->(DbGoTop())
      If EJA->(DbSeek(cFilEJA+cFile))
         While EJA->(!EOF()) .And. AllTrim(EJA->EJA_FILIAL+EJA_FILE) == AllTrim(cFilEJA+cFile)
            If !Empty(EJA->EJA_PREEMB) .And. !Empty(EJA->EJA_PARC) .And. (Empty(cStatus) .Or. EJA->EJA_STATUS == cStatus)

               //Busca Recno da parcela vinculada ao arquivo, na tabela EEQ.
               EEQ->(DbSetOrder(1))
               If EEQ->(DbSeek(xFilial("EEQ")+EJA->EJA_PREEMB+EJA->EJA_PARC))
                  If (nTipo == 1 .Or. !Empty(EEQ->EEQ_DTCE))
                     AADD(aRecEEQ,EEQ->(RecNo()))
                     AADD(aRecEJA,EJA->(RecNo()))
                  EndIf
               EndIf

            EndIf

         EJA->(DbSkip())
         EndDo
      End If

//Envio
ElseIf nTipo == 1

      //Busca todos os Recnos da tabela EJA associados ao arquivo a ser enviado
      EJA->(DbSetOrder(1))
      EJA->(DbGoTop())
      If EJA->(DbSeek(cFilEJA+cFile))
         While EJA->(!EOF()) .And. AllTrim(EJA->EJA_FILIAL+EJA_FILE) == AllTrim(cFilEJA+cFile)
             If Empty(cStatus) .Or. EJA->EJA_STATUS == cStatus
               aAdd(aRecEJA,EJA->(RecNo()))
            EndIf
            EJA->(DbSkip())
          EndDo
      EndIf

//Cancelamento
ElseIf nTipo = 2
      EJA->(DbSetOrder(1))
      If EJA->(DbSeek(cFilEJA+cFile))
         While EJA->(!EOF()) .And. AllTrim(EJA->EJA_FILE) == AllTrim(cFile)
         	If (Empty(cStatus) .Or. EJA->EJA_STATUS == cStatus)

	            If !Empty(EJA->EJA_PREEMB) .And. !Empty(EJA->EJA_PARC) .And. !Empty(EJA->EJA_FASE)
	               AADD(aRecEJA,EJA->(RecNo()))

	               EEQ->(DbSetOrder(1))
                   //Busca Recno da parcela vinculada ao arquivo, na tabela EEQ.
                   EEQ->(DbSetOrder(1))
                   If EEQ->(DbSeek(xFilial("EEQ")+EJA->EJA_PREEMB+EJA->EJA_PARC))
                      If (nTipo == 1 .Or. !Empty(EEQ->EEQ_DTCE))
                         AADD(aRecEEQ,EEQ->(RecNo()))
                      EndIf
                   EndIf
	            EndIf

			EndIf

            EJA->(DbSkip())
         EndDo
      EndIf

EndIf

Return Nil

Function EI201RetDt(dData, cSep)
Default cSep := ""
Return SubStr(DToS(dData), 1, 4) + cSep + SubStr(DToS(dData), 5, 2) + cSep + SubStr(DToS(dData), 7, 2)

Function EI201RetHr(cHora, cSep)
Default cSep := ""
Return SubStr(cHora, 1, 2) + cSep + SubStr(cHora, 4, 2) + cSep + SubStr(cHora, 7, 2)

Function Ei201DtHr(dData, cHora, cSepData, cSepHora, cSepDtHr)
Default cSepData := ""
Default cSepHora := ""
Default cSepDtHr := "T"

Return EI201RetDt(dData, cSepData) + cSepDtHr + EI201RetHr(cHora, cSepHora)

Function EI201ImpArq(lAuto)
//Local oArquivo := AvImport():New()//RMD - Movida para private para manipulação no ponto de entrada
Local /*cLog := "", */cMensagem := ""//RMD - Movida para private para manipulação no ponto de entrada
Local aParcs := {}, aConc := {}
Local i, nInc
Local cDir := cDirImport
Local aFiles
Local cReferencia, nPosRef1, nPosRef2
Private aEEQCampos := {}
Private lForcaAtualizacao:= .F.
Private oArquivo := AvImport():New()
Private cLog := ""
Private lAltValor := .T.//RMD - Define se o valor da parcela será alterado quando recebido um valor menor (dentro da tolerância), possibilitando alterar via ponto de entrada
Private cMsgArquivo := ""
Default lAuto := .F.

    //*** Informa o diretório local para importação dos arquivos.
	If !lAuto
	    cDir := cGetFile("","Diretório local para importação de arquivos.", 0, cDir,, GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY)
	EndIf
	//Grava a opção no temporário do usuário
    If !Empty(cDir)
    	WriteProfString("EEC_INTCASH","DIR_IMPORT",cDir,.T.)
    EndIf
    //***

    If !Empty(cDir) //MCF - 28/04/2016
	    //*** Executa a importação para cada arquivo presente no diretório
		aFiles := Directory(cDir+"*.XML")
		For nInc := 1 To Len(aFiles)
			cLog := ""
			//Define o diretório interno para gravação do arquivo e importa
			oArquivo:SetFile(cDir + aFiles[nInc][1], "\comex\cambio\conciliacao\recebidos\")
			//Tratativa de erro na importação
			If !Empty(oArquivo:cLog)
				cLog += "Erro ao importar o arquivo: " + AllTrim(aFiles[nInc][1]) + ENTER
				cLog += oArquivo:cLog

			//Efetua a leitura do arquivo
			ElseIf oArquivo:Import()

				//*** Interpreta o arquivo XML recebido e adiciona no array aConc
				If ValType(XmlChildEx(oArquivo:oXML, "_DOCUMENT"))  == "O" .And. ValType(XMLChildEx(oArquivo:oXML:_DOCUMENT, "_BKTOCSTMRACCTRPT")) == "O" .And. ValType(XMLChildEx(oArquivo:oXML:_DOCUMENT:_BKTOCSTMRACCTRPT, "_RPT")) == "O"
					aParcs := XMLChildEx(oArquivo:oXML:_Document:_BkToCstmrAcctRpt:_Rpt, "_NTRY")
					If ValType(aParcs) == "O"
						aParcs := {aParcs}
					EndIf
				EndIf

				If ValType(aParcs) <> "A"
					aParcs := {}
				EndIf

				For i := 1 To Len(aParcs)
					//Verifica se possui a tag com a chave da parcela
					If 	!(ValType(XMLChildEx(aParcs[i], "_NTRYDTLS")) == "O" .And. ValType(XMLChildEx(aParcs[i]:_NTRYDTLS, "_TXDTLS")) == "O";
						.And. ValType(XMLChildEx(aParcs[i]:_NTRYDTLS:_TXDTLS, "_REFS")) == "O" .And. ValType(XMLChildEx(aParcs[i]:_NTRYDTLS:_TXDTLS:_REFS, "_PRTRY")) == "O";
						.And. ValType(XMLChildEx(aParcs[i]:_NTRYDTLS:_TXDTLS:_REFS:_PRTRY, "_REF")) == "O")
						Loop
					EndIf
					//Verifica se possui a tag com a data do crédito
					If 	!(ValType(XMLChildEx(aParcs[i], "_BOOKGDT")) == "O" .And. ValType(XMLChildEx(aParcs[i]:_BOOKGDT, "_DTTM")) == "O");
						.And. Len(aParcs[i]:_BOOKGDT:_DTTM:TEXT) >= 8
						Loop
					EndIf
					//Verifica se possui a tag com o valor do crédito
					If 	!(ValType(XMLChildEx(aParcs[i], "_AMTDTLS")) == "O" .And. ValType(XMLChildEx(aParcs[i]:_AMTDTLS, "_INSTDAMT")) == "O";
						.And. ValType(XMLChildEx(aParcs[i]:_AMTDTLS:_INSTDAMT, "_AMT")) == "O")
						Loop
					EndIf
					//Verifica se possui a tag com o código da conta
					If 	ValType(XMLChildEx(oArquivo:oXML:_DOCUMENT:_BKTOCSTMRACCTRPT:_RPT, "_ACCT")) == "O" .And. ValType(XMLChildEx(oArquivo:oXML:_DOCUMENT:_BKTOCSTMRACCTRPT:_RPT:_ACCT, "_ID")) == "O";
						.And. ValType(XMLChildEx(oArquivo:oXML:_DOCUMENT:_BKTOCSTMRACCTRPT:_RPT:_ACCT:_ID, "_OTHR")) == "O" .And. ValType(XMLChildEx(oArquivo:oXML:_DOCUMENT:_BKTOCSTMRACCTRPT:_RPT:_ACCT:_ID:_OTHR, "_ID")) == "O";
						.And. Empty(oArquivo:oXML:_DOCUMENT:_BKTOCSTMRACCTRPT:_RPT:_ACCT:_ID:_OTHR:_ID:TEXT)
						Loop
					EndIf
					//Verifica se possui a referência bancária (não é obrigatório)
					cReferencia := ""
					If 	ValType(XMLChildEx(aParcs[i], "_NTRYDTLS")) == "O" .And. ValType(XMLChildEx(aParcs[i]:_NTRYDTLS, "_TXDTLS")) == "O";
						.And. ValType(XMLChildEx(aParcs[i]:_NTRYDTLS:_TXDTLS, "_ADDTLTXINF")) == "O" .And. !Empty(aParcs[i]:_NTRYDTLS:_TXDTLS:_ADDTLTXINF:TEXT)
						//A referencia bancária é informada na tag ADDTLTXINF junto a outras informações. A mesma é precedida de duas barras (//) e sucedida por uma barra (/) ou pelo final da tag
						If (nPosRef1 := At("//", aParcs[i]:_NTRYDTLS:_TXDTLS:_ADDTLTXINF:TEXT)) > 0
					    /*
					    If (nPosRef2 := At("/", SubStr(aParcs[i]:_NTRYDTLS:_TXDTLS:_ADDTLTXINF:TEXT, nPosRef1 + 2))) > 0
							cReferencia := AllTrim(SubStr(aParcs[i]:_NTRYDTLS:_TXDTLS:_ADDTLTXINF:TEXT, nPosRef1 + 2, nPosRef2 - 1))
						Else
							cReferencia := AllTrim(SubStr(aParcs[i]:_NTRYDTLS:_TXDTLS:_ADDTLTXINF:TEXT, nPosRef1 + 2))
						EndIf
						*/
						cReferencia := GetRef(aParcs[i]:_NTRYDTLS:_TXDTLS:_ADDTLTXINF:TEXT)//Busca a referencia bancária
						EndIf
					EndIf

					cChave	:= aParcs[i]:_NTRYDTLS:_TXDTLS:_REFS:_PRTRY:_REF:TEXT
					dData	:= SToD(Left(StrTran(aParcs[i]:_BOOKGDT:_DTTM:TEXT, "-", ""), 8))
					cConta	:= AllTrim(oArquivo:oXML:_DOCUMENT:_BKTOCSTMRACCTRPT:_RPT:_ACCT:_ID:_OTHR:_ID:TEXT)
					nValor	:= Val(aParcs[i]:_AMTDTLS:_INSTDAMT:_AMT:TEXT)
					If !Empty(cChave) .And. nValor > 0 .And. !Empty(dData) .And. aScan(aConc, {|x| x[1] == cChave }) == 0 .And. BuscaLote(cChave, cConta)
						aAdd(aConc, {cChave, dData, AvKey(EJA->EJA_BANCO, "EEQ_BCOEXT"), AvKey(EJA->EJA_AGENCI, "EEQ_AGCEXT"), AvKey(EJA->EJA_CONTA, "EEQ_CNTEXT"), nValor, EJA->(Recno()), cReferencia})
					EndIf
				Next
				//***

	            //*** Atualiza as parcelas de câmbio
				For i := 1 To Len(aConc)

					//Busca a parcela
					If EEQ->(DbSeek(aConc[i][1]))

						//Possibilita customizar verificação da data de crédito da parcela
		                If EasyEntryPoint("EECEI201")
		                   ExecBlock("EECEI201", .F., .F., "AEEQCAMPOS_CHECAATUALIZACAO")
		                EndIf

		                //Verifica se já possui crédito no exterior
					    If !Empty(EEQ->EEQ_DTCE) .And. !lForcaAtualizacao
					    	Loop
					    EndIf

						aRecEEQ := {EEQ->(Recno())}

						/* ***
							Caso o valor recebido seja diferente do esperado, verifica se a diferença é menor ou igual a 150,
							caso positivo altera a parcela para o valor recebido.
							Caso negativo, aborta a atualização.
						*/
						If EEQ->EEQ_VL <> aConc[i][6]
							If (EEQ->EEQ_VL - aConc[i][6]) > 0 .And. (EEQ->EEQ_VL - aConc[i][6]) < 150
                        If lAltValor
                           aEEQCampos := {}
                           aAdd(aEEQCampos, {"EEQ_VL", aConc[i][6]})
                           If !AltAutoEEQ(aRecEEQ, aEEQCampos)
                              cLog += EEQ->("Processo: " + EEQ_PREEMB + ENTER + "Parcela: " + EEQ_PARC + ENTER + "Não foi possível atualizar a parcela automaticamente." + ENTER + ENTER)
                              Loop
                           EndIf
                        EndIf
					 		Else
					 			cLog += EEQ->("Processo: " + EEQ_PREEMB + ENTER + "Parcela: " + EEQ_PARC + ENTER + "Não foi possível atualizar pois o valor recebido na data de " + DToC(aConc[i][2]) + ", " + AllTrim(Transform(aConc[i][6], AvSx3("EEQ_VL", AV_PICTURE))) + ", é diferente do valor da parcela, " + AllTrim(Transform(EEQ_VL, AvSx3("EEQ_VL", AV_PICTURE))) + "." + ENTER + ENTER)
					 			Loop
					 		EndIf
				 		EndIf
				 		//***

				 		//*** Atualiza a parcela
				 		EEQ->(DbSeek(aConc[i][1]))
				 		aEEQCampos := {}
						aAdd(aEEQCampos, {"EEQ_DTCE", aConc[i][2]})
						If EEQ->(FieldPos("EEQ_BCOEXT") > 0 .And. FieldPos("EEQ_CNTEXT") > 0 .And. FieldPos("EEQ_AGCEXT") > 0)
							aAdd(aEEQCampos, {"EEQ_BCOEXT", aConc[i][3]})
							aAdd(aEEQCampos, {"EEQ_AGCEXT", aConc[i][4]})
							aAdd(aEEQCampos, {"EEQ_CNTEXT", aConc[i][5]})
						EndIf

						//Informa a referência bancária
						If !Empty(aConc[i][8])
							//aAdd(aEEQCampos, {"EEQ_RFBC", aConc[i][8]}) // RMD - 02/12/15 - Utilizar o campo de número de operação para registrar a referência.
							aAdd(aEEQCampos, {"EEQ_NROPAG", aConc[i][8]})
						EndIf

		  			    If EasyEntryPoint("EECEI201")
		                   ExecBlock("EECEI201", .F., .F., "AEEQCAMPOS_ALTERACAO")
		                EndIf
			 			If !AltAutoEEQ(aRecEEQ, aEEQCampos)
				 			cLog += EEQ->("Processo: " + EEQ_PREEMB + ENTER + "Parcela: " + EEQ_PARC + ENTER + "Não foi possível atualizar a parcela automaticamente." + ENTER + ENTER)
			 				Loop
			 			EndIf
			 			EEQ->(DbSeek(aConc[i][1]))
		 			   //Atualiza a situação de envio no registro do EJA
			 		   AlteraEJA(2, {aConc[i][7]})
			 		   //***
			 		
			 		cLog += EEQ->("Processo: " + EEQ_PREEMB + ENTER + "Parcela: " + EEQ_PARC + ENTER + "Data do Crédito: " + DToC(aConc[i][2]) + ENTER + "Valor: " + AllTrim(Transform(EEQ_VL, AvSx3("EEQ_VL", AV_PICTURE))) + ENTER + "Banco: " + AllTrim(aConc[i][3]) + " Agencia: " + AllTrim(aConc[i][4]) + " Conta: " + AllTrim(aConc[i][5]) + " Referência: " + AllTrim(aConc[i][8]) + ENTER + ENTER)
				
				EndIf
				
			Next
			//***

         /* Na versão dp TFS anterior à validação na versão 12 na Braskem o trecho acima estava duplicado*/

         //RMD - Possibilita ajustar o log via ponto de entrada
			If ExistBlock("EECEI201")
				ExecBlock("EECEI201", .F., .F., "IMPARQ_FINAL")
			EndIf
			
			cMsgArquivo := "Arquivo: " + AllTrim(aFiles[nInc][1]) + ENTER + ENTER
			If Empty(cLog)
				cMsgArquivo += "Não foram identificadas parcelas para atualização neste arquivo." + ENTER
			Else
				cMsgArquivo += cLog + ENTER
			EndIf
			
			cMensagem += cMsgArquivo

			   FRename(cDir + aFiles[nInc][1], cDir + aFiles[nInc][1] + ".ok")

			   If (nHdl := EasyCreateFile(StrTran(Lower(cDir + aFiles[nInc][1]), ".xml", ".log"))) > 0
			      FWrite(nHdl, cMsgArquivo)
			      FClose(nHdl)
			   EndIf

		   EndIf
		Next

		If !Empty(cMensagem)
			ViewAuto("Processamento finalizado, foram atualizadas as seguintes parcelas:" + ENTER + ENTER + cMensagem, "Aviso")
		Else
			MsgAuto("Não foram identificadas parcelas para atualização nos arquivos informados.", "Aviso")
		EndIf

    EndIf

Return Nil

Static Function GetRef(cObs)
Local cRef := ""
Local nPos1, nPos2

	If (nPos1 := At("//", cObs)) > 0
		If (nPos2 := At("//", SubStr(cObs, nPos1 + 2))) > 0
			cRef := GetRef(SubStr(cObs, nPos1 + 2))
		ElseIf (nPos2 := At("/", SubStr(cObs, nPos1 + 2))) > 0
			cRef := SubStr(cObs, nPos1 + 2, nPos2 - 1)
		Else
			cRef := SubStr(cObs, nPos1 + 2)
		EndIf
	EndIf

Return cRef

Static Function BuscaLote(cChave, cConta, cStatus)
Local lRet := .F.
Local cCond := "% And EJA_STATUS  <> 'R' And EJA_STATUS <> 'C' %"
Default cStatus := ""

	If cStatus == "R"
		cCond := "% And EJA_STATUS  = 'R' %"
	EndIf

	EEQ->(DbSetOrder(1))
	If EEQ->(DbSeek(cChave))

		BeginSql Alias "QRYEJA"
			Select EJA.R_E_C_N_O_ As REC
			From %table:EJA% EJA
			Where
				EJA_PREEMB	= %exp:EEQ->EEQ_PREEMB%
				And EJA_PARC	= %exp:EEQ->EEQ_PARC%
				And EJA_FILPRC  = %exp:EEQ->EEQ_FILIAL%
				And EJA_CONTA	= %exp:cConta%
				AND %NotDel%
				%exp:cCond%
			Order By
				EJA_DTENV
		EndSql
		If !QRYEJA->(Eof() .And. Bof())
			EJA->(DbGoTo(QRYEJA->REC))
			lRet := .T.
		EndIf
		QRYEJA->(DbCloseArea())
		If !lRet .And. cStatus <> "R"
			Return BuscaLote(cChave, cConta, "R")
		EndIf
	EndIf

Return lRet

Function EI201VldBco()
Local lRet := .T.
Local cMoeBco := "", lFound
Local aOrd := SaveOrd("SA6")

	SA6->(DbSetOrder(1))
	If lFound := SA6->(DbSeek(xFilial("SA6")+MV_PAR04+If(!Empty(MV_PAR05),MV_PAR05,"")+If(!Empty(MV_PAR06),MV_PAR06,"")))
		cMoeBco := SA6->A6_MOEEASY
	EndIf

	If ReadVar() $ "MV_PAR04/MV_PAR05/MV_PAR06"
		If !Empty(&(ReadVar())) .And. !lFound
			MsgAuto("Banco/Agencia/Conta não cadastrados.", "Aviso")
			lRet := .F.
		EndIf
		If !Empty(cMoeBco)
			MV_PAR08 := cMoeBco
		EndIf
	ElseIf ReadVar() == "MV_PAR08"
		If !Empty(MV_PAR08) .And. (lRet := ExistCpo("SYF")) .And. !Empty(cMoeBco) .And. MV_PAR08 <> cMoeBco
			MsgAuto(StrTran("Moeda não permitida por ser diferente da moeda cadastrada para a conta informada (XXX).", "XXX", cMoeBco), "Aviso")
			lRet := .F.
		EndIf
	EndIf

Return lRet

//Cancela todos os arquivos gerados em datas anteriores para todas as filiais
Function EI201CancAll(lAuto)
Default lAuto := .F.

	BeginSQL Alias "QRYEJA"
		Select EJA.EJA_FILIAL, EJA.EJA_FILE, EJA.EJA_STATUS
		From %table:EJA% EJA
		Where
			(EJA_STATUS = 'N' And EJA_DTGER < %exp:DToS(dDataBase)%) Or (EJA_STATUS = 'V' And EJA_DTENV < %exp:DToS(dDataBase)%)
			AND %NotDel%
		Group By
			EJA.EJA_FILIAL, EJA.EJA_FILE, EJA.EJA_STATUS
	EndSql

	EJA->(DbSetOrder(1))
	If QRYEJA->(!Eof() .And. !Bof())
		If lAuto .Or. MsgYesNo("Deseja cancelar as gerações e os envios de datas anteriores?", "Aviso")
			While QRYEJA->(!Eof())
				If EJA->(DbSeek(QRYEJA->(EJA_FILIAL+EJA_FILE)))
					EJA->(EI201RejArq(.T., QRYEJA->EJA_FILE, QRYEJA->EJA_STATUS))
				EndIf
				QRYEJA->(DbSkip())
			EndDo
		EndIf
	EndIf

	QRYEJA->(DbCloseArea())

Return Nil

Static Function ProcAuto(bBlock, cMsg, cTit, xPar1)

	If !IsBlind()
		Processa(bBlock, cMsg, cTit, xPar1)
	Else
		ConOut(cMsg)
		Eval(bBlock)
	EndIf

Return Nil

Static Function MsgAuto(cMsg, cTit)

	If !IsBlind()
		MsgInfo(cMsg, cTit)
	Else
		ConOut(cMsg)
	EndIf

Return Nil

Static Function ViewAuto(cMsg, cTit)

	If !IsBlind()
		EECView(cMsg, cTit)
	Else
		ConOut(cMsg)
	EndIf

Return Nil

Function EI201GerAuto(cEmp, cFil)
Default cEmp := ""
Default cFil := ""

	ConOut("Inciando geração automática.")
	If !Empty(cEmp) .And. !Empty(cFil)
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
	EndIf

	EI201INTCASH(.T., .T., .F.)

Return Nil

Function EI201RecAuto(cEmp, cFil)
Default cEmp := ""
Default cFil := ""

    ConOut("Inciando recebimento automático.")
	If !Empty(cEmp) .And. !Empty(cFil)
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
	EndIf

	EI201INTCASH(.T., .F., .T.)


Return Nil

Function EI201RFilter()
Local lRet := .T.

Begin Sequence

	If MV_PAR01 == 1 .And. EJA->EJA_STATUS <> "C"
		lRet := .F.
		Break
	EndIf

	If MV_PAR01 == 2 .And. EJA->EJA_STATUS <> "V" .And. EJA->EJA_STATUS <> "R"
		lRet := .F.
		Break
	EndIf

	If !Empty(MV_PAR02) .And. ((MV_PAR01 == 1 .And. EJA->EJA_DTCOF < MV_PAR02) .Or. (MV_PAR01 == 2 .And. EJA->EJA_DTGER < MV_PAR02))
		lRet := .F.
		Break
	EndIf

	If !Empty(MV_PAR03) .And. ((MV_PAR01 == 1 .And. EJA->EJA_DTCOF > MV_PAR03) .Or. (MV_PAR01 == 2 .And. EJA->EJA_DTGER > MV_PAR03))
		lRet := .F.
		Break
	EndIf

	If !Empty(MV_PAR04) .And. EJA->EJA_BANCO <> MV_PAR04
		lRet := .F.
		Break
	EndIf

	If !Empty(MV_PAR06) .And. EJA->EJA_CONTA <> MV_PAR06
		lRet := .F.
		Break
	EndIf

	If !Empty(MV_PAR08) .And. EEQ->EEQ_IMPORT <> MV_PAR08
		lRet := .F.
		Break
	EndIf

	If !Empty(MV_PAR09) .And. EEQ->EEQ_IMLOJA <> MV_PAR09
		lRet := .F.
		Break
	EndIf

End Sequence

Return lRet

Function EI201Report()
Local oReport := ReportDef()
Return oReport:PrintDialog()

Static Function ReportDef()
aTables := {"EJA"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo,  Pergunte, Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EECEI201", "Conciliação Automática","EJA002", {|oReport| Pergunte("EJA002", .F.), ReportPrint(oReport)}, "Exibe a relação de parcelas conciliadas automaticamente por meio de integração.")

oReport:oPage:lLandScape := .T.
oReport:oPage:lPortRait := .F.

oSecao1 := TRSection():New(oReport,"Parcelas Conciliadas Automaticamente",aTables,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"EJA_BANCO"  , "EJA"   , AVSX3("EJA_BANCO"  ,05)   , AVSX3("EJA_BANCO"  ,06), AVSX3("EJA_BANCO"   ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EJA_CONTA"  , "EJA"   , AVSX3("EJA_CONTA"  ,05)   , AVSX3("EJA_CONTA"  ,06), AVSX3("EJA_CONTA"   ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EJA_FILPRC" , "EJA"   , AVSX3("EJA_FILPRC" ,05)   , AVSX3("EJA_FILPRC" ,06), AVSX3("EJA_FILPRC"  ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EJA_DTCOF"  , "EJA"   , "Data Conc."              , AVSX3("EJA_DTCOF"  ,06), AVSX3("EJA_DTCOF"   ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EEC_IMPODE" , "EEC"   , "Cliente"                 , AVSX3("EEC_IMPODE" ,06), AVSX3("EEC_IMPODE"  ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EEQ_MOEDA"  , "EEQ"   , AVSX3("EEQ_MOEDA"  ,05)   , AVSX3("EEQ_MOEDA"  ,06), AVSX3("EEQ_MOEDA"   ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EJA_VALOR"  , "EJA"   , "Valor Pago"              , AVSX3("EJA_VALOR"  ,06), AVSX3("EJA_VALOR"   ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EJA_PREEMB" , "EJA"   , AVSX3("EJA_PREEMB" ,05)   , AVSX3("EJA_PREEMB" ,06), AVSX3("EJA_PREEMB"  ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EJA_PARC"   , "EJA"   , AVSX3("EJA_PARC"   ,05)   , AVSX3("EJA_PARC"   ,06), AVSX3("EJA_PARC"    ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EEQ_VCT"    , "EEQ"   , AVSX3("EEQ_VCT"    ,05)   , AVSX3("EEQ_VCT"    ,06), AVSX3("EEQ_VCT"     ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"EEQ_VL"     , "EEQ"   , AVSX3("EEQ_VL"     ,05)   , AVSX3("EEQ_VL"     ,06), AVSX3("EEQ_VL"      ,03), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DIFERENCA"  , "EEQ"   , "Diferença"               , AVSX3("EEQ_VL"     ,06), AVSX3("EEQ_VL"      ,03), /*lPixel*/, {|| EJA->EJA_VALOR - EEQ->EEQ_VL })
TRCell():New(oSecao1,"EEQ_DTCE"   , "EEQ"   , AVSX3("EEQ_DTCE"   ,05)   , AVSX3("EEQ_DTCE"   ,06), AVSX3("EEQ_DTCE"    ,03), /*lPixel*/, /*{|| code-block de impressao }*/)

Return oReport

Static Function ReportPrint(oReport)
Local oSection := oReport:Section("Parcelas Conciliadas Automaticamente")
Local cWhere := ReportFilter()

	BeginSQL Alias "WKTOT"
		Select
			Count(*) AS TOTAL
		From
			%table:EJA% EJA, %table:EEQ% EEQ, %table:EEC% EEC
		Where
			%exp:cWhere%
			EJA_FILPRC = EEQ_FILIAL AND EJA_PREEMB = EEQ_PREEMB AND EJA_PARC = EEQ_PARC AND
			EJA_FILPRC = EEC_FILIAL AND EJA_PREEMB = EEC_PREEMB AND
			EJA.%NotDel% AND EEQ.%NotDel% AND EEC.%NotDel%
	EndSql

	oReport:SetMeter(WKTOT->TOTAL)
	WKTOT->(DbCloseArea())

	BeginSql Alias "WKPARC"
		Select
			EJA.R_E_C_N_O_ EJA_RECNO, EEQ.R_E_C_N_O_ EEQ_RECNO, EEC.R_E_C_N_O_ EEC_RECNO
		From
			%table:EJA% EJA, %table:EEQ% EEQ, %table:EEC% EEC
		Where
			%exp:cWhere%
			EJA_FILPRC = EEQ_FILIAL AND EJA_PREEMB = EEQ_PREEMB AND EJA_PARC = EEQ_PARC AND
			EJA_FILPRC = EEC_FILIAL AND EJA_PREEMB = EEC_PREEMB AND
			EJA.%NotDel% AND EEQ.%NotDel% AND EEC.%NotDel%
	EndSql

	oSection:Init()

	Do While WKPARC->(!Eof()) .And. !oReport:Cancel()
	   EJA->(DbGoTo(WKPARC->EJA_RECNO))
	   EEQ->(DbGoTo(WKPARC->EEQ_RECNO))
	   EEC->(DbGoTo(WKPARC->EEC_RECNO))
	   oSection:PrintLine()
	   oReport:IncMeter()
	   WKPARC->(DbSkip())
	EndDo

	WKPARC->(DbCloseArea())

	oSection:Finish()

Return .T.


Static Function ReportFilter()
Local cFilter := "% "

	//Somente conciliados
	If MV_PAR01 == 1
		cFilter += "EJA_STATUS = 'C' AND "
	EndIf

	//Somente enviados e recebidos (não conciliados)
	If MV_PAR01 == 2
		cFilter += "(EJA_STATUS = 'V' OR EJA_STATUS = 'R') AND "
	EndIf

	If !Empty(MV_PAR02)
		If MV_PAR01 == 1
			cFilter += "EJA_DTCOF >= '" + DToS(MV_PAR02) + "' AND "
		Else //MV_PAR01 == 2
			cFilter += "EJA_DTGER >= '" + DToS(MV_PAR02) + "' AND "
		EndIF
	EndIf

	If !Empty(MV_PAR03)
		If MV_PAR01 == 1
			cFilter += "EJA_DTCOF <= '" + DToS(MV_PAR03) + "' AND "
		Else //MV_PAR01 == 2
			cFilter += "EJA_DTGER <= '" + DToS(MV_PAR03) + "' AND "
		EndIF
	EndIf

	If !Empty(MV_PAR04)
		cFilter += "EJA_BANCO = '" + MV_PAR04 + "' AND "
	EndIf

	If !Empty(MV_PAR06)
		cFilter += "EJA_CONTA = '" + MV_PAR06 + "' AND "
	EndIf

	If !Empty(MV_PAR08)
		cFilter += "EEQ_IMPORT = '" + MV_PAR08 + "' AND "
	EndIf

	If !Empty(MV_PAR09)
		cFilter += "EEQ_IMLOJA = '" + MV_PAR09 + "' AND "
	EndIf

	cFilter += "%"

Return cFilter

*-------------------------------------------*
Static Function MenuDef(cOrigem, lMBrowse)
*-------------------------------------------*
Local aRotina :=  {}
Default cOrigem  := AvMnuFnc()
Default lMBrowse := OrigChamada()

Do Case
   Case cOrigem == "EI201INTCA"   
   
      aAdd(aRotina, {"Incluir", "EI201INTCA", 0, 3   }) //"Incluir"
             	  	
EndCase

	// P.E. utilizado para adicionar itens no Menu da mBrowse
	If EasyEntryPoint("EECEI201MNU")
		aRotAdic := ExecBlock("EECEI201MNU",.f.,.f.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf


Return aRotina
