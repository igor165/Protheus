//**************************************************************************//
// Programa....: EECAF500.PRW
// Programador.: Alessandro Alves Ferreira - AAF
// Data........: 21 de Novembro de 2005
// Objetivo....: Manutenção de Câmbio da Exportação sem vinculo com Embarque
//**************************************************************************//
//**************************************************************************//
//**************************-----REVISAO-----**********************************//
// Programador.: Pedro Luiz Nunes Baroni - PLB                                 //
// Data........: 22 de Maio de 2006                                            //
// Objetivo....: Vinculacao de Invoices a Financiamentos de Export. e Import.  //
//*****************************************************************************//

#Include "EEC.CH"
#Include "EECAF500.ch"

#Define OPC_VIS 2
#Define OPC_INC 3
#Define OPC_ALT 4
#Define OPC_EST 5
#Define OPC_LIQ 6
#Define OPC_ELQ 7
#Define OPC_VIN 8  // PLB 23/05/06
#Define OPC_EVN 9

//** PLB 01/06/06 - Eventos do Financiamento
#Define EV_EMBARQUE     "600"
#Define EV_LIQ_PRC      "630"
#Define EV_LIQ_JUR      "640"
#Define EV_PRINC_PREPAG "700"
#Define EV_JUROS_PREPAG "710"
#Define EV_ESTORNO      "999"

#define ACC             "01"
#define ACE             "02"
#define PRE_PAGTO       "03"
#define SECURITIZACAO   "04"
//**

#define BXG_DET     97//Baixa Gerencial - RMD - 08/11/07
//***********************************************//
//Função......: EECAF500()
//Programador.: Alessandro Alves Ferreira - AAF
//Objetivo....: Manutenção de Câmbio da Exportação sem vinculo com Embarque
//Data........: 21/11/05 - 17:53
//***********************************************//
Function EECAF500(cAlias,nRec,nOpc,xAutoCab,nOpcAuto,cTipo,lAtuTit)
//***********************************************//
Local nTpProc := 0
Local nProc   := 0
Local nSeqPro := 0
Local lSeek   := .T.
Local lCont   := .T. //RRC - 27/03/2013
Local nPos    := 0   //RRC - 06/09/2013
Local dDtEmissa
Local cFiltro := ""

Private aRotina   := {}
Private cCadastro := STR0001 //"Manutenção de Câmbio Tipo 3/4"

If AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")//THTS - 21/03/2017 - Adiantamento de Fornecedores 
	cCadastro := STR0112//"Manutenção de Adiantamento a Fornecedor"
	If Type("lOkEvent") = "U"
	   lOkEvent := EEQ->(FieldPos("EEQ_EVENT")) > 0
	EndIf	
EndIf

If Type("cTpReg") == "U"
   Private cTpReg := ""
EndIf

//** Flags
Private lIntCont       := EasyGParam("MV_EEC_ECO",,.F.) // Define Integração entre SIGAEEC - SIGAECO
Private lFinanciamento := EasyGParam("MV_EFF"    ,,.F.) // Define se há financiamento.
Private lTelaVincula   := .F. //FSM - 01/03/2012
Private lIntFina       := EasyGParam("MV_EEC_EFF",,.F.) // Define Integração entre SIGAEEC - SIGAEFF
Private lACCACE        := .T. //EasyGParam("MV_ACC_ACE",,.T.) // Define tranferência de ACC p/ ACE.
Private cMarca := GetMark()
Private lTemTipoEEQ    := EEQ->( FieldPos("EEQ_TP_CON") ) > 0 //Verifica se o Campo está na Base de Dados.
Private lMultiFil      := VerSenha(115) .and. Posicione("SX2",1,"EEC","X2_MODO") == "E" .and.;
                          Posicione("SX2",1,"EF1","X2_MODO") == "C"
//** PLB 22/05/06 -  Integrar com o Financiamento se os dois MVs estiverem ativos
Private aVinculados   := {} ,;
        nDesvinculado := 0

// PLB 21/12/06 - Tabela de Cadastro de Financiamentos.
Private lCadFin := ChkFile("EF7")  .And.  ChkFile("EF8")  .And.  ChkFile("EF9")

Private lEF2_INVOIC := EF2->( FieldPos("EF2_INVOIC") ) > 0   ,;
        lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")  ) > 0

// Testa se existe os campos nos arquivos  - Usada no EFFEX400
SX3->( DBSetOrder(2) )
Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
                     SX3->(DBSeek("ECE_BANCO"))  .and. SX3->(DBSeek("ECE_PRACA"))  .and.;
                     SX3->(DBSeek("EF3_OBS"))   .AND. SX3->(DBSeek("EF3_NROP"))
//Usada no EFFEX400
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0


Private lPrePag     := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PREPAG")) > 0 .and.;
                       EF1->(FieldPos("EF1_CLIENT")) > 0 .and. EF1->(FieldPos("EF1_CLLOJA")) > 0 .and.;
                       EF1->(FieldPos("EF1_ROF")) > 0    .and. EF1->(FieldPos("EF1_INI_IR")) > 0 .and.;
                       EF1->(FieldPos("EF1_FIM_IR")) > 0 .and. EF1->(FieldPos("EF1_PERCIR")) > 0 .and.;
                       EF1->(FieldPos("EF1_REAJIR")) > 0 .and. EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and.;
                       EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and. EF3->(FieldPos("EF3_NROP")) > 0 .and.;
                       EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0 .and.;
                       EF3->(FieldPos("EF3_SLDVIN")) > 0

// BAK - 02/10/2012
Private lAF500Auto := Valtype(xAutoCab) == "A" .And. Valtype(nOpcAuto) == "N"
Private aAF500Auto := xAutoCab

//RRC - 01/07/2013 - Utilizado na integração entre SIGAESS e SIGAFIN quando os títulos na SE2 e SE5 são atualizados antes que na EEQ (Parcelas de câmbio)
Default lAtuTit    := .T.
Private lGeraTit   := lAtuTit
Private lCpoAcrDcr := AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") //NCF - 14/08/2015 - Tratamento Acresc./Decres./Multa/Juros/Desconto no controle de cambio SIGAESS x SIGAFIN
//THTS - 28/02/2018
Private aTmpAlt		:= {}
Private aEAIDelete	:= {}
Private aEAIUpsert	:= {}

lFinanciamento := lFinanciamento .And. lIntFina .and. !cFilAnt $ GetMV("MV_AVG0024",,"")

If Type("lNaoCancelar") == "L"
   lNaoCancelar := .F.
EndIF

If lFinanciamento
   cFilEF3 := xFilial("EF3")
   cFilEF2 := xFilial("EF2")
   cFilEF1 := xFilial("EF1")
   Private lIsContab := .F.  // PLB 18/06/07 - Identifica se o Contrato de Financiamento foi Contabilizado - Var utilizada no EFFEX400
EndIf
//**
dbSelectArea("EEQ")
EEQ->( dbSetOrder(1) )

aRotina:= MenuDef()

If EasyEntryPoint("EECAF500") // By GFC - 11/09/2006 - Inclusão do ponto de entrada.
   ExecBlock("EECAF500",.F.,.F.,"AROTINA")
EndIf

If Select("TMP") > 0
   TMP->(DbCloseArea())
EndIf

If lTemTipoEEQ
   //Filtro para o MBrowse

   lFiltra := .T.
   If EasyEntryPoint("EECAF500") // By OMJ - 03/10/2006 - Inclusão do ponto de entrada.
      ExecBlock("EECAF500",.F.,.F.,"FILTRO")
   EndIf

	//THTS - 21/03/2017 - Se for Adiantamento de Fornecedores, nao realiza o filtro, pois a EEQ ja estara filtrada.   
   If lFiltra .And. !(AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116"))
       cFiltro := "EEQ_FASE == '3' .OR. EEQ_FASE == '4'" // LRS - 18/05/2017 - Novo tratamento para o filtro no MBrowse
      //EEQ->( dbSetFilter( {|| EEQ_FASE == '3' .OR. EEQ_FASE == '4'}, "EEQ_FASE == '3' .OR. EEQ_FASE == '4'"))
   EndIf

   /*RRC - 27/11/2013 - Caso o compartilhamento entre ELA e EEQ sejam diferentes, não deve prossguir, uma vez que existe um relacionamento entre elas
   Atualizado para verificar também se o campo EEQ_PROCES está contido no array o que indentifica ser chamada do SIGAESS*/
   If nModulo == 85 .Or. (IsInCallStack("ESSIN100") .Or. IsInCallStack("ESSPS400")) //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS - .Or. (Type("aAF500Auto") == "A" .And. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
      If (!Empty(xFilial("ELA")) .And. Empty(xFilial("EEQ"))) .Or. (Empty(xFilial("ELA")) .And. !Empty(xFilial("EEQ")))
         EasyHelp("O Compartilhamento das tabelas EEQ (Parcelas de Câmbio) e ELA (Invoices de Serviços) são diferentes, essa rotina não poderá ser executada.","Aviso")
         lCont := .F.
      EndIf
   Else
      If lFiltra
         cFiltro := "(EEQ_FASE == '3' .OR. EEQ_FASE == '4') .And. Empty(EEQ_PROCES)"
      EndIf
   EndIf

   If lCont .And. !lAF500Auto
      //RRC - 27/03/2013 - Alteração para o Easy Siscoserv, posiciona na invoice associada a parcela
      If IsInCallStack("ESSPS400")
         If nOpc <> 3
            //ELA->(DbSetOrder(1)) //ELA_FILIAL+ELA_TPPROC+ELA_EXPORT+ELA_LOJEXP+ELA_IMPORT+ELA_LOJIMP+ELA_NRINVO+ELA_PROCES
            ELA->(DbSetOrder(4))//ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO //alterado para ser utilizado para o uso de fornecedor e cliente diferentes do processo
            //If !(lCont := ELA->(DbSeek(xFilial("ELA")+AvKey(EEQ->EEQ_TPPROC,"ELA_TPPROC")+AvKey(EEQ->EEQ_FORN,"ELA_EXPORT")+AvKey(EEQ->EEQ_FOLOJA,"ELA_LOJEXP")+AvKey(EEQ->EEQ_IMPORT,"ELA_IMPORT");
            //   +AvKey(EEQ->EEQ_IMLOJA,"ELA_LOJIMP")+AvKey(EEQ->EEQ_NRINVO,"ELA_NRINVO")+AvKey(EEQ->EEQ_PROCES,"ELA_PROCES"))))
            If !(lCont := ELA->(DbSeek(xFilial("ELA")+AvKey(EEQ->EEQ_TPPROC,"ELA_TPPROC")+AvKey(EEQ->EEQ_PROCES,"ELA_PROCES")+AvKey(EEQ->EEQ_NRINVO,"ELA_NRINVO"))))
               EasyHelp("Não foi encontrada a invoice associada a essa parcela.")
               //RRC - 09/12/2013 - Validação para não permitir alteração de parcela originadas pelo SIGAFIN, SIGAEIC ou SIGAEEC
            ElseIf nOpc == 4 .And. (AllTrim(Upper(EEQ->EEQ_SOURCE)) == "SIGAFIN" .Or. AllTrim(Upper(EEQ->EEQ_SOURCE)) == "SIGAEIC" .Or. AllTrim(Upper(EEQ->EEQ_SOURCE)) == "SIGAEEC")
               lCont := .F.
               EasyHelp("Esta parcela foi originada pelo " + AllTrim(EEQ->EEQ_SOURCE) + " e não poderá ser alterada pelo módulo SIGAESS.")
            Else
               cTpReg := ELA->ELA_TPPROC
            EndIf
         ElseIf !(lCont := xFilial("EEQ") == EJW->EJW_FILIAL)
            EasyHelp("A filial selecionada para a parcela de câmbio é diferente da utilizada pelo Processo relacionado.","Aviso")
         ElseIf (AllTrim(ELA->ELA_ORIGEM) == "SIGACOM" .Or. Alltrim(ELA->ELA_ORIGEM) == "SIGAFAT") .And. !EasyGParam("MV_ESS0010",,.T.)
            lCont := .F.
            EasyHelp("Esta invoice foi originada pelo " + AllTrim(ELA->ELA_ORIGEM) + " e novas parcelas de câmbio não poderão ser incluídas.","Aviso")
         Else
            cTpReg := ELA->ELA_TPPROC
         EndIf

      EndIf
      //AOM - 21/08/2012
      If lCont
         If ValType(cAlias) == "C" .And. ValType(nOpc) == "N"
            AF500Tela(cAlias,nRec,nOpc)
         Else
            //MBrowse(0,0,0,0,"EEQ",NIL,NIL,NIL,NIL,3,NIL,NIL,NIL,02,,.F.,,,cFiltro)// LRS - 18/05/2017 - Novo tratamento para o filtro no MBrowse
            AF500TelFWM(cFiltro) //LRS 
         EndIf
      EndIf
   ElseIf lCont
      //RRC - 10/04/2013 - Preenche o Embarque concatenando o Tipo do Processo, Processo e a Sequência, caso não seja informado
      If !aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PREEMB" }) > 0
         //Antigo tratamento para preencher o EEQ_PREEMB
         /*If (nTpProc := aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_TPPROC" })) > 0 .And. (nProc := aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_REGIST" })) > 0;
            .And. (nSeqPro := aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_SEQREG" })) > 0
             AADD(aAF500Auto,{"EEQ_PREEMB",AvKey(AvKey(aAF500Auto[nTpProc][2],"EJZ_TPPROC")+AvKey(aAF500Auto[nProc][2],"EJZ_REGIST")+AvKey(aAF500Auto[nSeqPro][2],"EJZ_SEQREG"),"EEQ_PREEMB"),NIL})
         EndIf

         If (nTpProc := aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_TPPROC" })) > 0 .And. (nProc := aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" })) > 0;
            .And. (nSeqPro := aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_SEQPRC" })) > 0
            aAdd(aAF500Auto,{"EEQ_PREEMB",AvKey(AvKey(aAF500Auto[nTpProc][2],"EJX_TPPROC")+AvKey(aAF500Auto[nProc][2],"EJX_PROCES")+AvKey(aAF500Auto[nSeqPro][2],"EJX_SEQREG"),"EEQ_PREEMB"),NIL})
         EndIf*/
         If (nTpProc := aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_TPPROC" })) > 0 .And. (nProc := aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" })) > 0
            aAdd(aAF500Auto,{"EEQ_PREEMB",AvKey(AvKey(aAF500Auto[nTpProc][2],"ELA_TPPROC")+AvKey(aAF500Auto[nProc][2],"ELA_PROCES"),"EEQ_PREEMB"),NIL})
         EndIf

      EndIf
      //RRC - 27/11/2013 - Atualização para verificar se o campo EEQ_PROCES está no array, o que também indica ser chamada do SIGAESS
      If IsInCallStack("ESSIN100") //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0)

         If Select("ELA") == 0 .And. !ChkFile("ELA")
            Break
         EndIf
         //RRC - 06/09/2013 - Tratamento para permitir a inclusão da moeda de acordo com o código do SIGAFIN para integração de arquivo texto (ESSIN100)
         If (nPos := aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_MOEDA" })) > 0
            If ValType(aAF500Auto[nPos][2]) == "N" .Or. (ValType(aAF500Auto[nPos][2]) == "C" .And. IsInCallStack("ESSIN100"))  // AAF - 10/11/2014
               If ValType(aAF500Auto[nPos][2]) == "C"
			      If Val(aAF500Auto[nPos][2]) > 0 .OR. !Empty(aAF500Auto[nPos][2]) .AND. Upper(AllTrim(aAF500Auto[nPos][2])) == Replicate("0",Len(Upper(AllTrim(aAF500Auto[nPos][2]))))  // AAF - 10/11/2014
                     aAF500Auto[nPos][2] := Val(aAF500Auto[nPos][2])
				  Endif
               EndIf

               //RMD - 26/11/14 - Somente volta para caracter se o campo for do tipo numérico.
			   If ValType(aAF500Auto[nPos][2]) == "N"
				If !Empty(EasyConvCod(Alltrim(Str(aAF500Auto[nPos][2])),"SYF"))
					aAF500Auto[nPos][2] := EasyConvCod(Alltrim(Str(aAF500Auto[nPos][2])),"SYF")
				ElseIf !Empty(EasyGParam("MV_SIMB"+Alltrim(Str(aAF500Auto[nPos][2])),,""))
					aAF500Auto[nPos][2] := Left(EasyGParam("MV_SIMB"+Alltrim(Str(aAF500Auto[nPos][2])),,""),AvSX3("EJW_MOEDA",AV_TAMANHO))
				EndIf
			  EndIf
            EndIf
         EndIf
         /*
         If cTipo == "A"
            ELA->(DbSetOrder(3))   // ELA_FILIAL+ELA_TPPROC+ELA_EXPORT+ELA_LOJEXP+ELA_NRINVO+ELA_PROCES
            //RRC - 04/10/2013 - Alterado seek na ELA com o uso do xFilial("ELA")
            If ELA->(DbSeek(xFilial("ELA") + AvKey(cTipo,"ELA_TPPROC") + GetField(aAF500Auto,"EEQ_FORN",.T.) + GetField(aAF500Auto,"EEQ_FOLOJA",.T.) + GetField(aAF500Auto,"EEQ_NRINVO",.T.) + GetField(aAF500Auto,"EEQ_PROCES",.T.)))
               dDtEmissa := ELA->ELA_DTEMIS
            EndIf
         ElseIf cTipo == "V"
            ELA->(DbSetOrder(2))   // ELA_FILIAL+ELA_TPPROC+ELA_IMPORT+ELA_LOJIMP+ELA_NRINVO+ELA_PROCES
             //RRC - 04/10/2013 - Alterado seek na ELA com o uso do xFilial("ELA")
            If ELA->(DbSeek(xFilial("ELA") + AvKey(cTipo,"ELA_TPPROC") + GetField(aAF500Auto,"EEQ_IMPORT",.T.) + GetField(aAF500Auto,"EEQ_IMLOJA",.T.) + GetField(aAF500Auto,"EEQ_NRINVO",.T.) + GetField(aAF500Auto,"EEQ_PROCES",.T.)))
               dDtEmissa := ELA->ELA_DTEMIS
            EndIf
         EndIf
         */
         ELA->(DbSetOrder(4))   // ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
         //RRC - 04/10/2013 - Alterado seek na ELA com o uso do xFilial("ELA")
         If ELA->(DbSeek(xFilial("ELA") + AvKey(cTipo,"ELA_TPPROC")+ GetField(aAF500Auto,"EEQ_PROCES",.T.) +  GetField(aAF500Auto,"EEQ_NRINVO",.T.) ))
            dDtEmissa := ELA->ELA_DTEMIS
         EndIf

         If !Empty(dDtEmissa)
            SetFieldAuto(@aAF500Auto,cTipo,dDtEmissa)
         Else

            EasyHelp("Invoice não encontrada.")
            lCont := .F.
         EndIf

      EndIf
      /*RRC - 04/04/2013 - Alterado terceiro parâmetro enviado ao EasySeekAut, pois a chave única da EEQ foi alterada:
      Chave Antiga:
      Ordem 1: //EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
      Chave Atual:
      Ordem 4://EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB+EEQ_PARC

      //If (lSeek := EasySeekAuto("EEQ",aAF500Auto,1)) .Or. nOpcAuto == 3 .Or. nOpcAuto == 4*/
      If lCont //RRC - Continua o processamento apenas caso tenha validado corretamente a invoice
         If (lSeek := EasySeekAuto("EEQ",aAF500Auto,If(!SIX->(dbSeek("EEQF")),4,15))) .Or. nOpcAuto == 3 .Or. nOpcAuto == 4  // GFP - 02/06/2015
            //Caso esteja sendo enviado uma alteração e o processo não estiver cadastrado no sistema, será considerado como inclusão.
            //Caso esteja sendo enviado uma inclusão e o processo já estiver cadastrado no sistema, será considerado uma alteração
            If !lSeek .And. nOpcAuto == 4
               nOpcAuto := 3
            ElseIf lSeek .And. nOpcAuto == 3
               nOpcAuto := 4
            EndIf
            mBrowseAuto(nOpcAuto,aAF500Auto,"EEQ",.F.)
         ElseIf nOpcAuto == 5
            EasyHelp(STR0103,STR0011)
         EndIf
      EndIf
   EndIf
Else
   EasyHelp(STR0010,STR0011)//"Os Dicionários estão desatualizados. Necessária atualização no sistema para execução desta rotina."###"Aviso"
EndIf

//AOM - 27/08/2012 - Limpa Filtro Caso a Tabela esteja filtrada
If !Empty(EEQ->(DbFilter()))
  EEQ->(DbClearFilter())
EndIf

Return .T.

//**********************************************************//
//Programador: Alex Wallauer - AWR
//Objetivo...: Manutenção de Parcelas de Câmbio
//Data.......: 10/04/06 - 12:34
//**********************************************************//
Function AF500Tela(cAlias,nRec,nOpc)
//**********************************************************//
LOCAL oDlg, oDlg2, oDlg3 //RRC - 15/08/2012
Local lConf       := .T. //RRC - 15/08/2012
Local lValidCamb  := .F. //THTS - 28/02/2018 - Utilizada para validar ou nao o numero do processo digitado na inclusao do cambio 3/4
Local lOk         := .F.
Local lExecAuto   := Type("lAF500Auto") == "L" .And. lAF500Auto
Local aExecAuto   := If(Type('aAF500Auto') == "A",aClone(aAF500Auto),Nil)
Local nPosEmb     := 0
Local nPosInv     := 0
Local nPosAuto    := 0
Local nRecOld     := 0
Local cPictVl     := "@E 999,999,999,999.99"
Local oPanel

Private aBtns     := {}
PRIVATE cFilEEQ   := xFilial("EEQ")
PRIVATE nTipo     :=nOpc
/*RRC - 06/12/2013 - Necessário declarar as variáveis bSeek e bWhile, pois na rotina "Controle de Câmbio" do SIGAEIC também existem essas
variáveis privates com o mesmo nome, por onde ocorre a chamada para integração entre SIGAEIC x SIGAESS*/
Private bSeek     := {||}
Private bWhile    := {||}

/* Apenas quando for executado via chamada de menu, bloquear o estorno de todas as parcelas simultaneamente.*/ 
If nOpc == OPC_EST .And. AvFlags("EEC_LOGIX") .And. Empty(EEQ->EEQ_PROCES)
      MsgStop("Para realizar o estorno da parcela, acesse o processo em modo de alteração e execute a ação 'Estorno'.", "Estorno da parcela")
      Return .T.
EndIf

aSemSX3:={}
Aadd(aSemSX3,{"WK_MARCA"  ,"C",02,0})
Aadd(aSemSX3,{"WK_RECNO"  ,"N",12,0})

//LGS-17/02/2014
Aadd(aSemSX3,{"EEQ_VLSISC","N",15,2})
Aadd(aSemSX3,{"EEQ_PREEMB","C",20,0})
Aadd(aSemSX3,{"EEQ_IMLOJA","C",2, 0})
Aadd(aSemSX3,{"EEQ_HVCT","D"  ,8, 0})
Aadd(aSemSX3,{"EEQ_TPPROC","C",1, 0})
Aadd(aSemSX3,{"EEQ_NRINVO","C",20,0}) //LRS - 21/01/2016

aCampos:=ARRAY(EEQ->(FCOUNT()))
aHeader:={}
cFile1:=E_CriaTrab("EEQ",aSemSX3) // O ALIAS SERA TRB

If !Used()
   Help(" ",1,"E_NAOHAREA")
   Return .F.
EndIf

//RRC - 26/09/2013 - Criação de novo índice para o SIGAESS
If IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIS400") .Or. IsInCallStack("PS400BUSCFAT")//RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And.  (aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0)) //wfs - considerar chamada do sigacom
   IndRegua("TRB",cFile1+TEOrdBagExt(),"EEQ_PARC+EEQ_NRINVO")
Else
   IndRegua("TRB",cFile1+TEOrdBagExt(),"EEQ_PARC")
EndIf
M->EEQ_PREEMB:=SPACE(LEN(EEQ->EEQ_PREEMB))

If lExecAuto
   // Caso de exclusão
   If ((nPosAuto := aScan(aExecAuto,{ |X| AllTrim(Upper(X[1])) == "AUTDELETA"})) > 0 .And. ValType(aExecAuto[nPosAuto][2]) == "C" .And. aExecAuto[nPosAuto][2] == "S") .Or. nTipo == OPC_EST
      nTipo := OPC_EST
   Else // Caso de alteração
      If nTipo == OPC_ALT
         cCpoLiq := "EEQ_PGT"
         //If (nPosAuto := aScan(aExecAuto,{ |X| AllTrim(Upper(X[1])) == "EEQ_MODAL" })) > 0 .And. ValType(aExecAuto[nPosAuto][2]) == "D" .And. aExecAuto[nPosAuto][2] == "2" //RMD - 17/09/18 - Estava testando o EEQ_MODAL como tipo data
         If (nPosAuto := aScan(aExecAuto,{ |X| AllTrim(Upper(X[1])) == "EEQ_MODAL" })) > 0 .And. ValType(aExecAuto[nPosAuto][2]) == "C" .And. aExecAuto[nPosAuto][2] == "2"
            cCpoLiq := "EEQ_DTCE"
         EndIf
         If (nPosAuto := aScan(aExecAuto,{ |X| AllTrim(Upper(X[1])) == cCpoLiq})) > 0 .And. ValType(aExecAuto[nPosAuto][2]) == "D"
            // Caso nao satisfaça nenhuma condição abaixo, será respeitada alteração
            If Empty(aExecAuto[nPosAuto][2]) .And. EEQ->(FieldPos(cCpoLiq)) > 0 .And. !Empty(EEQ->&(cCpoLiq))
               nTipo := OPC_ELQ
            ElseIf !Empty(aExecAuto[nPosAuto][2]) .And. EEQ->(FieldPos(cCpoLiq)) > 0 .And. Empty(EEQ->&(cCpoLiq))
               nTipo := OPC_LIQ
            EndIf
         EndIf
      EndIf
   EndIf
EndIf

/*IF nTipo # OPC_INC
*/
   If lExecAuto
      If (nPosEmb := aScan( aExecAuto , { |X| AllTrim(Upper(X[1])) == "EEQ_PREEMB" } )) > 0
         M->EEQ_PREEMB := aExecAuto[nPosEmb][2]
      EndIf

      If (nPosInv := aScan( aExecAuto , { |X| AllTrim(Upper(X[1])) == "EEQ_NRINVO" } )) > 0
         M->EEQ_NRINVO := aExecAuto[nPosInv][2]
      EndIf

   ElseIf (IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSPS401"))
      If nOpc <> OPC_INC
         M->EEQ_PREEMB := EEQ->EEQ_PREEMB
      Else
         //M->EEQ_PREEMB := AvKey(EJX->EJX_TPPROC+EJX->EJX_PROCES+EJX->EJX_SEQPRC,"EEQ_PREEMB")
         //RRC -27/03/2013 - Considera apenas o Tipo de Processo e o Processo para montar o EEQ_PREEMB
         M->EEQ_PREEMB := AvKey(ELA->ELA_TPPROC+ELA->ELA_PROCES/*+ELA->ELA_NRINVO*/,"EEQ_PREEMB")
      EndIf
   ElseIf IsInCallStack("ESSRS400")
      If nOpc <> OPC_INC
         M->EEQ_PREEMB := EEQ->EEQ_PREEMB
      Else
         M->EEQ_PREEMB := AvKey(EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG,"EEQ_PREEMB")
      EndIf
   ElseIf nTipo # OPC_INC
      M->EEQ_PREEMB:=EEQ->EEQ_PREEMB
   EndIf
 /*
   IF (IsInCallStack("ESSRS401") .Or. lExecAuto)
      TRB->(DBAPPEND())
      AvReplace("EEQ","TRB")
      TRB->WK_RECNO := EEQ->(Recno())
   Else*/

      //ASK 11/01/07 17:24 - Alteração do codeblock para garantir que a busca seja feita sempre com a ordem 1
      //bSeek  :={|| EEQ->(dbSeek(cFilEEQ+M->EEQ_PREEMB)) }
      nRecOld := EEQ->(Recno())
      //RRC - 27/11/2013 - Acrescentada condição para verificar se o campo EEQ_PROCES está no array, o que também indica ser uma chamada para o SIGAESS
      If IsInCallStack("ESSIN100") .OR. IsInCallStack("ESSPS400") //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0)
         If !SIX->(dbSeek("EEQF"))    // GFP - 02/06/2015
            bSeek  :={|| EEQ->(DbSetOrder(4)), EEQ->(dbSeek(cFilEEQ+ELA->ELA_NRINVO+M->EEQ_PREEMB)) }
         Else
            bSeek  :={|| EEQ->(DbSetOrder(15)), EEQ->(dbSeek(cFilEEQ+AvKey(ELA->ELA_TPPROC,"EEQ_TPPROC")+AvKey(ELA->ELA_PROCES,"EEQ_PROCES")+AvKey(ELA->ELA_NRINVO,"EEQ_NRINVO"))) }
         EndIf
         bWhile :={|| EEQ->EEQ_NRINVO == ELA->ELA_NRINVO .AND. EEQ->EEQ_PREEMB == M->EEQ_PREEMB .AND. cFilEEQ == EEQ->EEQ_FILIAL }
      
      ElseIf AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")//THTS - 21/03/2017 - Adiantamento de Fornecedores  
		  		bSeek  :={|| EEQ->(DbSetOrder(16)), EEQ->(dbSeek(cFilEEQ+AvKey(SA2->A2_COD,"EEQ_PREEMB")+"609"+"F"+AvKey(SA2->A2_COD,"EEQ_FORN")+AvKey(SA2->A2_LOJA,"EEQ_FOLOJA"))) }
	        	bWhile :={|| cFilEEQ == EEQ->EEQ_FILIAL .And. EEQ->EEQ_PREEMB == avKey(SA2->A2_COD,"EEQ_PREEMB") .And. EEQ->EEQ_EVENT == "609" .And. EEQ->EEQ_FASE == "F" .And. EEQ->EEQ_FORN == avKey(SA2->A2_COD,"EEQ_FORN") .And. EEQ->EEQ_FOLOJA == avKey(SA2->A2_LOJA,"EEQ_FOLOJA")}
      Else
         bSeek  :={|| EEQ->(DbSetOrder(1)), EEQ->(dbSeek(cFilEEQ+M->EEQ_PREEMB)) }
         bWhile :={|| EEQ->EEQ_PREEMB == M->EEQ_PREEMB .AND. cFilEEQ == EEQ->EEQ_FILIAL }
      EndIf

      bRecNo :={|R| TRB->WK_RECNO:=R , TRB->WK_MARCA := cMarca }
      MsAguarde( {|| E_GravaTRB("EEQ",bSeek,,bWhile,,bRecNo,"TRB") } )
      EEQ->(DbGoTo(nRecOld))
/*   EndIf

ENDIF*/

If nTipo == OPC_VIS
   cTitulo := STR0003+IIF(lMultiFil," - "+AvSX3("EEQ_FILIAL",5)+": "+cFilEEQ,"") //"Visualizacao"
Elseif nTipo == OPC_ALT
   cTitulo := STR0005+IIF(lMultiFil," - "+AvSX3("EEQ_FILIAL",5)+": "+cFilEEQ,"") //"Alteracao"
Elseif nTipo == OPC_INC
   cTitulo := STR0004+IIF(lMultiFil," - "+AvSX3("EEQ_FILIAL",5)+": "+cFilEEQ,"") //"Inclusao"
Elseif nTipo == OPC_EST
   cTitulo := STR0006+IIF(lMultiFil," - "+AvSX3("EEQ_FILIAL",5)+": "+cFilEEQ,"") //"Estorno"
ElseIf nTipo == OPC_LIQ
   cTitulo := STR0018+IIF(lMultiFil," - "+AvSX3("EEQ_FILIAL",5)+": "+cFilEEQ,"") //"Liquidação da Parcela"
ElseIf nTipo == OPC_ELQ
   cTitulo := STR0019+IIF(lMultiFil," - "+AvSX3("EEQ_FILIAL",5)+": "+cFilEEQ,"") //"Estorno de Liquidação da Parcela"
EndIf

cTitulo:=IIF(lMultiFil,cCadastro+" - "+AvSX3("EEQ_FILIAL",5)+": "+cFilEEQ,"")

aTB_Campos:=ARRAYBROWSE("EEQ","TRB")

If (nPos := aScan(aTB_Campos, {|x| x[3] == AvSx3("EEQ_VM_REC", 5) })) > 0
   aDel(aTB_Campos, nPos)
   aSize(aTB_Campos, Len(aTB_Campos) - 1)
EndIf

If EEQ->(FieldPos("EEQ_EMISSA")) > 0 // BAK - 26/09/2012
   aAdd(aTB_Campos,{{|| Transf(TRB->EEQ_EMISSA,AvSx3("EEQ_EMISSA",AV_PICTURE))},"",AvSx3("EEQ_EMISSA",AV_TITULO)})
EndIf

//NCF - 10/08/2015
IF lCpoAcrDcr  .And. !lExecAuto
   AAdd(aTB_Campos, {{|| Transf(TRB->EEQ_ACRESC,cPictVl)},"",AVSX3("EEQ_ACRESC",AV_TITULO)} ) //"Acrescimos"
   AAdd(aTB_Campos, {{|| Transf(TRB->EEQ_DECRES,cPictVl)},"",AVSX3("EEQ_DECRES",AV_TITULO)} ) //"Decrescimos"
ENDIF

//** PLB 24/05/06
If lFinanciamento
   aVinculados   := {}
   nDesvinculado := 0
   TRB->( DBGoTop() )
   EF3->( DBSetOrder(3) )
   Do While !TRB->( EoF() )
      If !Empty(TRB->EEQ_NRINVO) .And. EF3->( DBSeek(cFilEF3+IIF(TRB->EEQ_TP_CON$"3","E","I")+TRB->EEQ_NRINVO+TRB->EEQ_PARC+EV_EMBARQUE) )  .And.  EF3->EF3_PREEMB==M->EEQ_PREEMB
         EEQ->( DBGoTo(TRB->WK_RECNO) )
         AAdd(aVinculados,Array(18))
         aVinculados[Len(aVinculados)][1]  := EEQ->EEQ_PREEMB   // Processo
         aVinculados[Len(aVinculados)][2]  := EEQ->EEQ_NRINVO   // Invoice
         aVinculados[Len(aVinculados)][3]  := EEQ->EEQ_PARC     // Parcela
         aVinculados[Len(aVinculados)][4]  := EEQ->EEQ_TP_CON   // Tipo do Contrato
         aVinculados[Len(aVinculados)][5]  := EF3->EF3_TPMODU   // Tipo do Modulo
         aVinculados[Len(aVinculados)][6]  := EF3->EF3_CONTRA   // Numero do Contrato
         aVinculados[Len(aVinculados)][7]  := EF3->EF3_BAN_FI   // Banco
         aVinculados[Len(aVinculados)][8]  := EF3->EF3_PRACA    // Praca
         aVinculados[Len(aVinculados)][9]  := EF3->EF3_SEQCNT   // Sequencia do Contrato
         aVinculados[Len(aVinculados)][10] := EF3->EF3_SEQ      // Sequencia dos Eventos
         aVinculados[Len(aVinculados)][11] := EF3->EF3_VL_MOE   // Valor na Moeda
         aVinculados[Len(aVinculados)][12] := EF3->EF3_TX_MOE   // Taxa na Moeda
         aVinculados[Len(aVinculados)][13] := EF3->EF3_DT_EVE   // Data do Evento
         aVinculados[Len(aVinculados)][14] := IIF(Left(EF3->EF3_EV_VIN,2)==Left(EV_JUROS_PREPAG,2),"2","1")   // Tipo de Vinculacao
         aVinculados[Len(aVinculados)][15] := Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+IIF(lEFFTpMod,EF3->EF3_SEQCNT,""),"EF1_DT_ENC")
         aVinculados[Len(aVinculados)][16] := EF3->( RecNo() )  // RecNo do Evento de Vinculacao (600)
         aVinculados[Len(aVinculados)][17] := EF3->EF3_TX_CON //LRS - 23/02/2018
         aVinculados[Len(aVinculados)][18] := EF3->EF3_VL_INV //LRS - 23/02/2018
      EndIf
      TRB->( DBSkip() )
   EndDo
EndIf
//**

DO WHILE .T.

   If !lExecAuto
      oMainWnd:ReadClientCoords()//So precisa declarar uma vez para o Programa todo
   EndIf

   lOK:= .F.
   If nTipo == OPC_INC //RRC -  15/08/2012 - Exibe a tela solicitando o Processo

      If !lExecAuto .And. (IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSPS400")) .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. AvFlags("CONTROLE_SERVICOS_VENDA") //AOM - 21/08/2012 - Caso essa rotina seja chamada pela função de pagamentos de serviços é preenchido o Preemb automatico
         If IsInCallStack("ESSRS400")
            M->EEQ_PREEMB := EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG
         ElseIf IsInCallStack("ESSPS400")
            //M->EEQ_PREEMB := EJX->EJX_TPPROC+EJX->EJX_PROCES+EJX->EJX_SEQPRC
            //RRC -27/03/2013 - Considera apenas o Tipo de Processo e o Processo para montar o EEQ_PREEMB
            M->EEQ_PREEMB := ELA->ELA_TPPROC+ELA->ELA_PROCES//+ELA->ELA_NRINVO
            M->EEQ_NRINVO := ELA->ELA_NRINVO
         EndIf
         If(!AF500MAN(cAlias,TRB->WK_RECNO,3,.T., M->EEQ_PREEMB),lConf:= .F.,lConf:=.T.)
      
      ElseIf !lExecAuto .And. AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")//THTS - 17/03/2017 - Adiantamento de Fornecedores
     		
			M->EEQ_PREEMB := SA2->A2_COD
			If(!AF500MAN(cAlias,TRB->WK_RECNO,3,.T.),lConf:= .F.,lConf:=.T.)     
      		
      ElseIf !lExecAuto
         DEFINE MSDIALOG oDlg3 TITLE STR0100 From 0,0 To 15,80 OF oMainWnd //"Gera Arquivo" // BAK - 24/09/12

           oPanel:=TPanel():New(0, 0, "", oDlg3,, .F., .F.,,, 0, 0)
           oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

           @ 16,10 SAY   STR0035       SIZE 30,10 OF oPanel PIXEL  //"Processo"
           @ 16,40 MSGET M->EEQ_PREEMB SIZE 75,08 PICTURE AVSX3("EEQ_PREEMB",6)  OF oPanel PIXEL  WHEN (nTipo = OPC_INC .AND. TRB->(EOF() .AND. BOF())) VALID If(!lValidCamb,ExistChav("EEQ", M->EEQ_PREEMB, 1),) //THTS - 28/02/2018

         ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlg3,{ || If(!AF500MAN(cAlias,TRB->WK_RECNO,3,.T., M->EEQ_PREEMB),(lConf:= .F.,lValidCamb:=.F.),(lConf:=.T.,lValidCamb := .T.)), oDlg3:End()} ,{||lConf:= .F., oDlg3:End()}) CENTERED
      Else
         If (nPosEmb := aScan( aExecAuto , { |X| AllTrim(Upper(X[1])) == "EEQ_PREEMB" } )) > 0
            M->EEQ_PREEMB := aExecAuto[nPosEmb][2]

            If (nPosInv := aScan( aExecAuto , { |X| AllTrim(Upper(X[1])) == "EEQ_NRINVO" } )) > 0
               M->EEQ_NRINVO := aExecAuto[nPosInv][2]
            EndIf

            If !AF500Valid("EEQ_PREEMB")
               Exit
            EndIf
         Else
            AF500Valid("EEQ_PREEMB")
            Exit
         EndIf
      EndIf
   EndIf

   //RRC - 16/08/2012 - Só mostrará a tela com as parcelas referentes ao Processo caso já haja alguma parcela incluída
   If lExecAuto .Or. (lConf .And. !TRB->(EOF() .And. BOF()))

      //AOM - 24/08/2012  - Caso a Função seja executada pela rotina de serviços nao apresentar tela para seleção das parcelas
      If (IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSPS400") .Or. (AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")))  .And. !lExecAuto //THTS - 22/03/2017
         //TRB->WK_RECNO := EEQ->(RECNO())
         //RRC - 26/09/2013 - SIGAESS utiliza outro índice
         If IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIS400") //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And.  (aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
            TRB->(dbSeek(EEQ->EEQ_PARC+EEQ->EEQ_NRINVO))
            //THTS - 30/06/2017 - Deixa o valor igual ao valor siscoserv quando houve retenção de imposto para permitir a alteracao do valor cheio e quebra do titulo.
            If nOpc == 4 .And. nModulo == 85 .And. ELA->ELA_ORIGEM !="SIGACOM" .And. EEQ->(FieldPos("EEQ_VLSISC")) > 0 .And. EEQ->EEQ_VLSISC > 0 .And. EEQ->EEQ_VLSISC != EEQ->EEQ_VL 
                TRB->EEQ_VL := EEQ->EEQ_VLSISC
            EndIf
         Else
            TRB->(dbSeek(EEQ->EEQ_PARC))
         EndIf
         AF500MAN(cAlias,TRB->WK_RECNO,nTipo,,TRB->EEQ_PREEMB)
         EXIT
      ElseIf lExecAuto
         //TRB->WK_RECNO := EEQ->(RECNO())
         //RRC - 26/09/2013 - SIGAESS utiliza outro índice
         If IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIS400") .Or. IsInCallStack("PS400BUSCFAT") //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And.  (aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
            TRB->(dbSeek(EEQ->EEQ_PARC+EEQ->EEQ_NRINVO))
         Else
            TRB->(dbSeek(EEQ->EEQ_PARC))
         EndIf
         AF500MAN(cAlias,TRB->WK_RECNO,nTipo)
         EXIT
      ElseIf !lExecAuto

         IF nTipo = OPC_INC .OR. nTipo = OPC_ALT
            //@ 10,nColBrow         BUTTON STR0004 SIZE 33,12 ACTION (AF500MAN(cAlias,TRB->WK_RECNO,3)) OF oDlg PIXEL//"Inclusão"
            //@ 10,nColBrow+=nExtra BUTTON STR0005 SIZE 33,12 ACTION (AF500MAN(cAlias,TRB->WK_RECNO,4)) OF oDlg PIXEL//"Alteração"
            //@ 10,nColBrow+=nExtra BUTTON STR0006 SIZE 33,12 ACTION (AF500MAN(cAlias,TRB->WK_RECNO,5)) OF oDlg PIXEL//"Estorno"
            //** PLB 23/05/06
            //DEFINE BUTTON oBtnInc RESOURCE "BMPINCLUIR" /*"EDIT"*/ OF oBar GROUP TOOLTIP STR0004  //"Inclusao"
            //oBtnInc:cTitle  := STR0004  //"Inclusao"
            //oBtnInc:bAction := { || AF500MAN(cAlias,TRB->WK_RECNO,3) }

            //RRC - 15/08/2012 - Somente será disponibilizado o botão "Incluir" para rotinas de alterações ou caso não hajam Parcelas, pois neste caso, um novo Processo poderá ser incluído
            If nTipo == OPC_ALT .Or. !TRB->(EOF() .And. BOF())
               Aadd(aBtns,{,{ || AF500MAN(cAlias,TRB->WK_RECNO,3) },STR0004})
            EndIf
            //DEFINE BUTTON oBtnAlt RESOURCE "EDIT" /*"ALT_CAD"*/ OF oBar GROUP TOOLTIP STR0005  //"Alteração"
            //oBtnAlt:cTitle  := STR0005  //"Alteração"
            //oBtnAlt:bAction := { || AF500MAN(cAlias,TRB->WK_RECNO,4) }
            Aadd(aBtns,{,{ || AF500MAN(cAlias,TRB->WK_RECNO,4) },STR0005})

            //DEFINE BUTTON oBtnEst RESOURCE "EXCLUIR" OF oBar GROUP TOOLTIP STR0006  //"Estorno"
            //oBtnEst:cTitle  := STR0006  //"Estorno"
            //oBtnEst:bAction := { || AF500MAN(cAlias,TRB->WK_RECNO,5) }
            Aadd(aBtns,{,{ || AF500MAN(cAlias,TRB->WK_RECNO,5) },STR0120} ) //"Excluir"

            //nColBrow:=130
            //@ 22,nColBrow         BUTTON STR0007 SIZE 33,12 ACTION (AF500MAN(cAlias,TRB->WK_RECNO,6)) OF oDlg PIXEL//"Liquidação"
            //@ 22,nColBrow+=nExtra BUTTON STR0008 SIZE 33,12 ACTION (AF500MAN(cAlias,TRB->WK_RECNO,7)) OF oDlg PIXEL//"Est. Liquid."
            //** PLB 23/05/06
            If lFinanciamento .And. lEFFTpMod
               //DEFINE BUTTON oBtnVin RESOURCE "BAIXATIT" OF oBar GROUP TOOLTIP STR0044  //"Vinculacao"
               //oBtnVin:cTitle  := STR0044  //"Vinculacao"
               //oBtnVin:bAction := { || AF500VIN(cAlias,TRB->WK_RECNO,8) }
               Aadd(aBtns,{,{ || AF500VIN(cAlias,TRB->WK_RECNO,8), oMark:oBrowse:Refresh() },STR0044})

               //DEFINE BUTTON oBtnEVn RESOURCE "SDUERASE" /*"BMPDEL"*/ OF oBar GROUP TOOLTIP STR0070  //"Est. Vincul."
               //oBtnEVn:cTitle  := STR0070  //"Est. Vincul."
               //oBtnEVn:bAction := { || AF500VIN(cAlias,TRB->WK_RECNO,9) }
               Aadd(aBtns,{,{ || AF500VIN(cAlias,TRB->WK_RECNO,9) } ,STR0070}) //"Estornar Vinculação"
            EndIf

            //DEFINE BUTTON oBtnLiq RESOURCE "LIQCHECK" OF oBar GROUP TOOLTIP STR0007  //"Liquidação"
            //oBtnLiq:cTitle  := STR0007  //"Liquidação"
            //oBtnLiq:bAction := { || AF500MAN(cAlias,TRB->WK_RECNO,6) }
            Aadd(aBtns,{,{ || AF500MAN(cAlias,TRB->WK_RECNO,6) } ,STR0007})

            //DEFINE BUTTON oBtnELq RESOURCE "NOCHECKED" OF oBar GROUP TOOLTIP STR0008  //"Est. Liquid."
            //oBtnELq:cTitle  := STR0008  //"Est. Liquid."
            //oBtnELq:bAction := { || AF500MAN(cAlias,TRB->WK_RECNO,7) }
            Aadd(aBtns,{,{ || AF500MAN(cAlias,TRB->WK_RECNO,7) }  ,STR0008})

               //**

           If EECFlags("CAMBIO_EXT")
              //DEFINE BUTTON oBtnAlt RESOURCE "BUDGET" OF oBar GROUP TOOLTIP STR0079//STR0079	"Bx. Geren."
              //oBtnAlt:cTitle  := STR0078//STR0078	"Baixa Gerencial"
              //oBtnAlt:bAction := { || AF500MAN(cAlias,TRB->WK_RECNO, BXG_DET) }
              Aadd(aBtns,{,{ || AF500MAN(cAlias,TRB->WK_RECNO, BXG_DET) } ,STR0079})
           EndIf


         ELSEIF nTipo = OPC_VIS

            //@ 22,nColBrow+=nExtra BUTTON STR0003 SIZE 35,12 ACTION (AF500MAN(cAlias,TRB->WK_RECNO,2)) OF oDlg PIXEL//"Visualização"
            //DEFINE BUTTON oBtnVis RESOURCE "BMPVISUAL" /*"ANALITICO"*/ OF oBar GROUP TOOLTIP STR0003  //"Visualização"
            //oBtnVis:cTitle  := STR0003  //"Visualização"
            //oBtnVis:bAction := { || AF500MAN(cAlias,TRB->WK_RECNO,2) }
            Aadd(aBtns,{,{ || AF500MAN(cAlias,TRB->WK_RECNO,2) },STR0003})

         ELSEIF nTipo = OPC_EST

            AADD(aTB_Campos,NIL)
            aIns(aTB_Campos,1)
            aTB_Campos[1] := {"WK_MARCA","",""}
            //@ 22,nColBrow+=nExtra BUTTON STR0006 SIZE 33,12 ACTION ( IF(MSGYESNO(STR0036),AF500Estorno(),) ) OF oDlg PIXEL//"Estorno" //"Confirma o Estono?"
            //DEFINE BUTTON oBtnEst RESOURCE "EXCLUIR" OF oBar GROUP TOOLTIP STR0006 //"Estorno"
            //oBtnEst:cTitle  := STR0006 //"Estorno"
            //oBtnEst:bAction := { || IF(MSGNoYes(STR0036),AF500Estorno(),) }
            Aadd(aBtns,{,{ || IF(MsgYesNo(STR0120),AF500Estorno(),) }  , STR0120 }) //"Excluir"

         ENDIF

         //@ 22,nColBrow+=nExtra BUTTON STR0037 SIZE 33,12 ACTION (oDlg:End()) OF oDlg PIXEL //"Sair"
         //DEFINE BUTTON oBtnExt RESOURCE "FINAL" OF oBar GROUP TOOLTIP STR0037  //"Sair"
         //oBtnExt:cTitle  := STR0037  //"Sair"
         //oBtnExt:bAction := { || oDlg:End() }

         if EasyEntryPoint("EECAF500")
            ExecBlock("EECAF500",.F.,.F.,"BTN_AF500TELA")
         endif

         cTitulo := M->EEQ_PREEMB
         DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM  OF oMainWnd PIXEL
            aPos := PosDLG(oDLG)
            aPos[1]+=30

            TRB->(DBGOTOP())
            oMark:=MSSELECT():New("TRB",IF(nTipo = OPC_EST,"WK_MARCA",),,aTB_Campos,.F.,cMarca,aPos)
            oMark:oBrowse:bWhen:={||DBSELECTAREA("TRB"),.T.}
            oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //RRC - 13/08/2012 - Centraliza a tela
            oDlg:lMaximized := .T.
         ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aBtns)
      EndIf

   EndIf

   EXIT

ENDDO

IF SELECT('TRB') # 0
   TRB->(E_EraseArq(cFile1))
ENDIF

nOpc:=4
Return nOpc


//**********************************************************//
//Função.....: AF500MAN(cAlias,nRec,nTipo)
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Manutenção de Parcelas de Câmbio
//Data.......: 22/11/05 - 09:45
//**********************************************************//
Function AF500MAN(cAlias,nRec,nTip,lAtua, cNrProcess)
//**********************************************************//
Local oDlg, nInd, nInd2, nOrd
Local lRet := .F.

// BAK - 02/10/2012
Local lExecAuto := Type("lAF500Auto") == "L" .And. lAF500Auto
Local aExecAuto := If(Type('aAF500Auto') == "A",aClone(aAF500Auto),Nil)
Local nPos

Local nSeq            //AHAC - 11/07/2014 - Num. Parcela Automática  - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
Local bIntLogix       //AHAC - 11/07/2014 - Integração Logix - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
Local aOrdSA2		:= {} //THTS - 27/03/2017 - guarda a area da SA2
Local lAlterouDtCred:= .F.
Private lConfirma  := .F.
Private cTxtConfir := "" // BAK - 01/10/2012
If nTip == OPC_INC
   cTxtConfir := STR0101 // Confirma a inclusao?
ElseIf nTip==OPC_ALT
   cTxtConfir := STR0075  // Confirma a alteracao?
ElseIf nTip==OPC_LIQ
   cTxtConfir := STR0102 // Confirma a liquidacao?
ElseIf nTip==OPC_EST
   cTxtConfir := STR0036 // Confirma a liquidacao?
EndIf

Private aMostra    := {}
Private aButtons   := {}
Private bOK        := {|| lOK:= .T., If(!lExecAuto , oDlg:End() , )}
Private bOK2       := {|| lOK:= .T., If(!lExecAuto , oDlg:End() , )}
Private bCancel    := {|| lOK:= .F., If(!lExecAuto , oDlg:End() , )}
Private bBarOk     := {|| If(nTip==OPC_INC .Or. nTip==OPC_ALT .Or. nTip==OPC_LIQ,If(ValObrAF500(nTip).And. ( If(!lExecAuto,lConfirma:=MsgYesNo(cTxtConfir),.T.) ),Eval(bOk),),IIF(nTip==OPC_EST,IIF( If(!lExecAuto,lConfirma:=MsgYesNo(cTxtConfir),.T.),Eval(bOk),),Eval(bOk)))}
Private bBarCancel := {||If(nTip==OPC_INC .Or. nTip==OPC_ALT .Or. nTip==OPC_LIQ,If( ( If(!lExecAuto,MsgYesNo((STR0076+Chr(13)+Chr(10)+STR0077)),.T.) ),Eval(bCancel),),Eval(bCancel))} //"Deseja Realmente Sair?"###"Todas as alterações serão perdidas."
Private cPictDt    := AvSx3("EEQ_PGT",6)
Private oEnc       //RRC - 15/08/2012 - Objeto criado pela função MsmGet() - RRC - 14/08/2012
Private lLiqAutoFinancing:= .F., aLiqAuto:= {}

If AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")//THTS - 27/03/2017 - Adiantamento de Fornecedores
	aOrdSA2 := SaveOrd({"SA2"})
EndIf

Default lAtua      := .F. //RRC - 16/08/2012
Default cNrProcess:= ""

If Type("lEEQAuto") <> "L" .Or. !lEEQAuto
   //RRC - 15/08/2012 - Irá exibir uma janela solicitando o processo apenas em caso de inclusão e se não houver nenhuma parcela cadastrada
   //If ValType(nTipo) == "N" .And. nTipo == 3 .And. nTip == OPC_INC  .And. !TRB->(EOF() .And. BOF())
     // IF !AF500Valid("EEQ_PREEMB",.T.)
       //  RETURN .F.
      //ENDIF
  // Else
      IF !AF500Valid("EEQ_PREEMB")
         RETURN .F.
      ENDIF
   //EndIf
EndIf

If Type("lEEQAuto") <> "L" .Or. !lEEQAuto
   IF nTip # OPC_INC
      IF TRB->(EOF() .AND. BOF())
         EasyHelp(STR0041)  //"Nao existem parcelas."
         RETURN .F.
      ENDIF
      IF nRec # 0
         EEQ->(DBGOTO(nRec))
      ENDIF
   ENDIF
EndIf

//AHAC - 11/07/2014 - Definição da chamada da Integração Logix - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
IF AF500EAIIntg(M->EEQ_PROCES, M->EEQ_FASE)
   If nTip == OPC_INC .OR. nTip == OPC_ALT  // AAF - 10/11/2014
      If Type("lIntTitLogix") == "U" .OR. lIntTitLogix
         bIntLogix := {|| if(M->EEQ_TIPO=="P",EECAF510("EEQ",3),EECAF530("EEQ",3))} //UPSERT
      Else
         bIntLogix := {|| .T.} //Não integrar nesse caso.
      EndIf
   ElseIf nTip==OPC_EST
      DBSELECTAREA("TRB")
      PACK
      If TRB->(EasyReccount("TRB")) == 1//Ultimo registro da TRB = Delete
         bIntLogix := {|| if(M->EEQ_TIPO=="P",EECAF510("EEQ",5),EECAF530("EEQ",5))} //DELETE  // AAF - 10/11/2014
      Else
         bIntLogix := {|| if(M->EEQ_TIPO=="P",EECAF510("EEQ",3),EECAF530("EEQ",3))} //UPSERT  // AAF - 10/11/2014
      EndIf
   ElseIf nTip==OPC_LIQ
      bIntLogix := {|| if(M->EEQ_TIPO=="P",EECAF511("EEQ",3),EECAF531("EEQ",3))} //UPSERT  // AAF - 10/11/2014
   ElseIf nTip==OPC_ELQ
      bIntLogix := {|| if(M->EEQ_TIPO=="P",EECAF512("EEQ",3),EECAF532("EEQ",3))} //UPSERT  // AAF - 10/11/2014
   EndIf
EndIf

Private lOK := .F.
Private aTela:={},aGets:={}
Private aAltera := {}
Private cFilEEQ := xFilial("EEQ")
Private nReg    := nRec
Private nTipoP  := nTip

EF1->( DBSetOrder(1) )
EF3->( DBSetOrder(3) )
//** PLB 23/05/06 - Verifica se a parcela possui vinculacao
lVinculada := lFinanciamento .And. !Empty(EEQ->EEQ_NRINVO) .And. EF3->( DBSeek(cFilEF3+IIF(EEQ->EEQ_TP_CON $ "3","E","I")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_EMBARQUE) )  .And.  EF3->EF3_PREEMB==M->EEQ_PREEMB
//**

// BAK - 28/09/2012
Private lLiqParWhen := nTip == OPC_LIQ
INCLUI := nTip == OPC_INC
ALTERA := nTip == OPC_ALT
EXCLUI := nTip == OPC_EST

Begin Sequence

   //Validação para FFC
   If nTipoP <> OPC_INC .And. !Empty(EEQ->EEQ_FFC) .And. nTipoP <> OPC_VIN .And. nTipoP <> OPC_EVN
      /*RRC - 15/02/2013 - Não será válida a condição abaixo caso a chamada venha da rotina de Registro de Serviços (RAS ou RVS)
      do Siscoserv, pois será uma exclusão do registro com todas as suas parcelas não liquidada associadas aos serviços*/
      If !((IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSPS400")) .And. !IsInCallStack("ESSRS401"))
         EasyHelp(STR0034)//"Processo com FFC. Utilize a manutenção de FFC."
         nTipoP := OPC_VIS
         nTip  := OPC_VIS
      EndIf
   EndIf

   //Validação para Liquidação com movimento no exterior ou contrato de câmbio.
   If nTipoP == OPC_LIQ .and. AF200ParcLiq()
      if EasyVerModal("EEQ")
         cMsgHelp := strtran(STR0012, "XX" , STR0121 ) //"movimento no exterior"
         cMsgHelp := strtran(cMsgHelp, "DD" , Transf(EEQ->EEQ_DTCE,cPictDt) ) 
      else
         cMsgHelp := strtran(STR0012, "XX" , STR0122 ) //"contrato de câmbio"
         cMsgHelp := strtran(cMsgHelp, "DD" , Transf(EEQ->EEQ_PGT,cPictDt) )
      endif
      EasyHelp( cMsgHelp +".",STR0013) //"Parcela liquidada com XX em DD " ###"Atenção"
      BREAK
   EndIf

   //Validação para Alteração.
   If nTipoP == OPC_ALT
      If /*EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->EEQ_MODAL <> "2"*/ !EasyVerModal("EEQ") .And. AF200ParcLiq() .And. Type("lAF500Auto") == "L" .And. !lAF500Auto//AOM - 24/08/2012 - NOPADO - !Empty(EEQ->EEQ_PGT)
         Help(" ",1,"AVG0005075") //EasyHelp("Parcela Com Câmbio Contratado !","Atenção")
         BREAK
      ElseIf lVinculada // PLB 23/05/06
         EasyHelp(STR0042)//"Parcela nao pode ser alterada pois possui vinculacao."
         Break
      ElseIf /*!Empty(EEQ->EEQ_PGT)*/ AF200ParcLiq() .And. lGeraTit //RRC - 15/07/2013 - Verifica se a parcela já está liquidada, neste caso só continuará com a alteração se for uma atualização do SIGAFIN indicado por lGerTit
         EasyHelp("Parcela não pode ser alterada pois está liquidada.")
         Break
      EndIf
   EndIf

   If nTipoP == OPC_ELQ .AND. !AF200ParcLiq()//AOM - 24/08/2012 - NOPADO -
      EasyHelp(STR0025)//"Parcela não está liquidada."
      Break
   EndIf

   If nTipoP == OPC_EST
      If AF200ParcLiq()//AOM - 24/08/2012 - NOPADO - !Empty(EEQ->EEQ_PGT)
         EasyHelp(STR0031+Chr(13)+Chr(10)+STR0032)//"Parcela não pode ser excluida pois já está liquidada."###"Estorne a Liquidação."
         BREAK
      ElseIf lVinculada // PLB 23/05/06
         EasyHelp(STR0043)//"Parcela nao pode ser estornada pois possui vinculacao."
         Break
      EndIf
   EndIf

   lSair := .F.
   If(EasyEntryPoint("EECAF500"),ExecBlock("EECAF500",.F.,.F.,"VALIDA_MANUT"),)
   IF lSair
      lRet := .F.
      RETURN lRet
   ENDIF

   If nTipoP == OPC_VIS
      cTitulo := STR0014//"Visualização de Parcela"
   Elseif nTipoP == OPC_ALT
      cTitulo := STR0015//"Alteração de Parcela"
   Elseif nTipoP == OPC_INC
      cTitulo := STR0016//"Inclusão de Parcela"
   Elseif nTipoP == OPC_EST
      cTitulo := STR0017//"Estorno de Parcela"
   ElseIf nTipoP == OPC_LIQ
      cTitulo := STR0018//"Liquidação da Parcela"
   ElseIf nTipoP == OPC_ELQ
      cTitulo := STR0019//"Estorno de Liquidação da Parcela"
   EndIf

   dbSelectArea("EEQ")
   EEQ->( dbSetOrder(1) )
   M->EEC_NRINVO := criaVar("ELA_NRINVO")
   If nTipoP <> OPC_INC
      //MFR 04/08/2017 TE-6334 WCC-526892 MTRADE-1269
      RegToMemory("EEQ", INCLUI)
     	RestOrd(aOrdSA2,.T.)
      /*         
      For nInd := 1 To EEQ->( FCount() )
         M->&(EEQ->( FieldName(nInd) )) := EEQ->( FieldGet(nInd) )
      Next nInd
      */
      //AOM - 24/08/2012 - Incializa o campo pois o mesmo é utilizado no gatilho do campo EEQ_TX
      M->EEQ_VLFCAM := 0
      //RRC - 13/05/2013 - Inicializa o campo EEQ_VM_REC para o gatilho do EEQ_TX
      M->EEQ_VM_REC := CriaVar("EEQ_VM_REC")

      IF EF1->EF1_TP_FIN == "05" //LRS - 21/02/2018
         IF EF1->EF1_MOEDA == EEQ->EEQ_MOEDA
            M->EEQ_TX := EF1->EF1_TX_MOE
         ENDIF
      ENDIF

      If lcpoAcrDcr  .And. !lExecAuto                                                               //NCF - 11/08/2015
         If nTipoP == OPC_ALT
            M->EEQ_VM_REC := M->EEQ_VL + (M->EEQ_ACRESC - M->EEQ_DECRES)
         ElseIf nTipoP == OPC_LIQ .OR. nTipoP == OPC_ELQ
            M->EEQ_VM_REC := M->EEQ_VL +  (M->EEQ_ACRESC - M->EEQ_DECRES) + M->EEQ_MULTA + M->EEQ_JUROS - M->EEQ_DESCON
         EndIf
      EndIf

   Else
      M->EEQ_VLFCAM := 0

      If Empty(cNrProcess) .And. !Empty(M->EEQ_PREEMB)
         cNrProcess:= M->EEQ_PREEMB
      EndIf
    //MFR 04/08/2017 TE-6334 WCC-526892 MTRADE-1269
      RegToMemory("EEQ", INCLUI)
	RestOrd(aOrdSA2,.T.)
    /*
      For nInd := 1 To EEQ->( FCount() )
         If ( !EEQ->( FieldName(nInd) ) $ "EEQ_NRINVO,EEQ_TP_CON,EEQ_PREEMB" )
            M->&( EEQ->( FieldName(nInd) ) ) := CriaVar( EEQ->( FieldName(nInd) ) )
         EndIf
      Next nInd
    */      
      //RRC - 13/05/2013 - Inicializa o campo EEQ_VM_REC para o gatilho do EEQ_TX
      M->EEQ_VM_REC := CriaVar("EEQ_VM_REC")

      //AHAC - 11/07/2014 - Numeração automática da Parcela - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
      //THTS - 21/03/2017 - Alteracao ao gerar a numeracao da parcela
      If !lExecAuto
         nSeq := 0
         If AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")
            nSeq := AF500adPar() //Busca a ultima parcela gerada de adiantamento de fornecedor
         Else
            If !(TRB->(EOF() .AND. BOF()))
                  TRB->(DBGOBOTTOM())
                  nSeq := VAL(TRB->EEQ_PARC)
            EndIf
         EndIf
         M->EEQ_PARC := StrZero(++nSeq,AvSX3("EEQ_PARC",AV_TAMANHO))
      EndIf
      
      //Número do processo digitado pelo usuário na inclusão manual do câmbio 3 e 4
      If !Empty(cNrProcess)
         M->EEQ_PREEMB:= cNrProcess
      EndIf

      //RRC - 26/03/2013 - Alteração para o Easy Siscoserv
      If IsInCallStack("ESSPS400") .Or. (Type("lAF500Auto") == "L" .And. lAF500Auto)
         M->EEQ_NRINVO := ELA->ELA_NRINVO
         If ELA->ELA_TPPROC == "A"
            M->EEQ_EVENT := "001"
            M->EEQ_TIPO  := "P"
         ElseIf ELA->ELA_TPPROC == "V"
            M->EEQ_EVENT := "501"
            M->EEQ_TIPO  := "R"
         EndIf

         If ELA->(FieldPos("ELA_EXPINV"))>0 .And. ELA->(FieldPos("ELA_ELJINV"))>0 .And. !Empty(ELA->ELA_EXPINV) .And. !Empty(ELA->ELA_ELJINV)
            M->EEQ_FORN   := ELA->ELA_EXPINV
            M->EEQ_FOLOJA := ELA->ELA_ELJINV
         Else
            M->EEQ_FORN   := ELA->ELA_EXPORT
            M->EEQ_FOLOJA := ELA->ELA_LOJEXP
         End If

         If ELA->(FieldPos("ELA_IMPINV"))>0 .And. ELA->(FieldPos("ELA_ILJINV"))>0  .And. !Empty(ELA->ELA_IMPINV) .And. !Empty(ELA->ELA_ILJINV)
            M->EEQ_IMPORT := ELA->ELA_IMPINV
            M->EEQ_IMLOJA := ELA->ELA_ILJINV
         Else
            M->EEQ_IMPORT := ELA->ELA_IMPORT
            M->EEQ_IMLOJA := ELA->ELA_LOJIMP
         End If

         M->EEQ_MOEDA  := ELA->ELA_MOEDA
         M->EEQ_EMISSA := ELA->ELA_DTEMIS

      Else
         M->EEQ_NRINVO := Space(AvSx3("EEQ_NRINVO",3))
      EndIf

      If Type('cTpReg') == "C"
         If cTpReg=='A'
            M->EEQ_TP_CON := '4'
         Else
            M->EEQ_TP_CON := '3'
         EndIf
      Else
         If IsVazio("EEQ") .Or. !(EEQ->EEQ_FASE $ "3/4")
            M->EEQ_TP_CON := "3"
         ElseIf EEQ->EEQ_FASE == '3'
            M->EEQ_TP_CON := "3"
         Elseif EEQ->EEQ_FASE == '4'
            M->EEQ_TP_CON := "4"
         Else
            M->EEQ_TP_CON := CriaVar("EEQ_TP_CON")
         EndIf
      EndIf

      If lExecAuto .And. (nPos := aScan(aExecAuto,{|X| AllTrim(Upper(X[1])) == "EEQ_TPPROC"})) > 0
         If 'A' $ aExecAuto[nPos][2]
            M->EEQ_TP_CON := '4'
         Else
            M->EEQ_TP_CON := '3'
         EndIf
      EndIf

      //THTS - 17/03/2017 - Adiantamento Fornecedores
      If !lExecAuto .And. AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")
	      	M->EEQ_EVENT	:= "609" //Evento especifico para adiantamento de fornecedores
      		M->EEQ_TIPO	:= "A" //Adiantamento
      		M->EEQ_FORN	:= SA2->A2_COD
      		M->EEQ_FOLOJA	:= SA2->A2_LOJA
      		M->EEQ_TP_CON	:= "4" //Para adiantamento de fornecedor, o tipo deve ser Cambio Exportacao
      EndIf

   EndIf

   If Type("aEEQAuto") == "A"
      aEval(aEEQAuto, {|x| Eval(MemVarBlock(x[1]), x[2]) })
   EndIf

   nOrdSX3:= SX3->( IndexOrd() )
   SX3->( dbSetOrder(2) )

   // Campos que seram apresentados na Enchoice.
   aMostra := {"EEQ_NRINVO","EEQ_PARC","EEQ_VCT"   ,"EEQ_VL"    ,"EEQ_SOL"   ,"EEQ_DTNEGO",;
               /*"EEQ_DECAM" ,*/"EEQ_BANC","EEQ_AGEN"  ,"EEQ_NCON"  ,"EEQ_NOMEBC","EEQ_RFBC"  ,;
               /*"EEQ_CORR"  ,"EEQ_FFC",*/ "EEQ_DTCE"  ,/*"EEQ_EQVL"  ,*/"EEQ_EVENT" ,"EEQ_PREEMB",;
               "EEQ_TP_CON",/*"EEQ_TX"  ,*/"EEQ_DESCON","EEQ_VM_REC"}/* FSM - 18/12/10 */

   //RRC - 26/03/2013 - Alteração para o Easy Siscoserv
   If !IsInCallStack("ESSPS400")
      aAdd(aMostra,"EEQ_FFC")
      aAdd(aMostra,"EEQ_CORR")
      aAdd(aMostra,"EEQ_DECAM")
   EndIf
   //RRC - 27/11/2013 - Atualização para verificar no array se o campo EEQ_PROCES foi informado, pois isso indica ser uma chamada do SIGAESS
   If EEQ->(FieldPos("EEQ_VLSISC")) > 0 .And. (nModulo == 85 .Or. IsInCallStack("ESSPS400")) //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And. aScan(aAF500Auto, { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
      aAdd(aMostra,"EEQ_VLSISC")
   EndIf
   //RRC - 13/11/2013 - Exibe o número do título gerado pela parcela de câmbio
   If nTipoP <> OPC_INC .And. EEQ->(FieldPos("EEQ_FINNUM")) > 0 .And. EasyGParam("MV_AVG0226",,.F.)
      aAdd(aMostra,"EEQ_FINNUM")
   EndIf
   If SX3->( dbSeek("EEQ_DESEVE") )
      aAdd(aMostra,"EEQ_DESEVE")
   EndIf

   //AOM - 21/08/2012 - Campo Modalidade de Pagamento
   If EEQ->(FieldPos("EEQ_MODAL")) > 0
      aAdd(aMostra,"EEQ_MODAL")
   EndIf

   If nTipoP == OPC_LIQ .OR. nTipoP == OPC_ELQ .OR. nTipoP == OPC_VIS
      aAdd(aMostra,"EEQ_NROP")
      aAdd(aMostra,"EEQ_PGT")
      aAdd(aMostra,"EEQ_TX")
      aAdd(aMostra,"EEQ_EQVL")
   EndIf

   If nTipoP == OPC_ALT
      aAdd(aMostra,"EEQ_NROP")
   EndIf

   If EEQ->(FieldPos("EEQ_OBS")) > 0
      aAdd(aMostra,"EEQ_OBS")
   EndIf

   If EECFlags("FRESEGCOM")
      //RRC - 26/03/2013 - Alteração para o Easy Siscoserv
      If !IsInCallStack("ESSPS400")
         aAdd(aMostra,"EEQ_CODEMP")
         aAdd(aMostra,"EEQ_PARI")
      EndIf

      If !IsInCallStack("ESSPS400") .OR. ELA->ELA_TPPROC == "A"
         aAdd(aMostra,"EEQ_FORN")
         If SX3->( dbSeek("EEQ_DESFOR") )
            aAdd(aMostra,"EEQ_DESFOR")
         EndIf
         aAdd(aMostra,"EEQ_FOLOJA")
      EndIf

      aAdd(aMostra,"EEQ_MOEDA")
      aAdd(aMostra,"EEQ_TIPO")

      If !IsInCallStack("ESSPS400") .OR. ELA->ELA_TPPROC == "V"
         aAdd(aMostra,"EEQ_IMPORT")
         aAdd(aMostra,"EEQ_IMLOJA")
         If SX3->( dbSeek("EEQ_DESIMP") )
            aAdd(aMostra,"EEQ_DESIMP")
         EndIf
      EndIf

   EndIf

   If EEQ->(FieldPos("EEQ_EMISSA")) > 0 // BAK - 26/09/2012
      aAdd(aMostra, "EEQ_EMISSA")
   EndIf

   If EEQ->(FieldPos("EEQ_MOTIVO")) > 0  //LRS - 16/09/2014
      aAdd(aMostra,"EEQ_MOTIVO")
   EndIf

   IF lCpoAcrDcr .And. !lExecAuto
      If nTipoP == OPC_INC .OR. nTipoP == OPC_ALT
         If IsReceita(TRB->EEQ_EVENT)
            aAdd(aMostra,"EEQ_ACRESC")
            aAdd(aMostra,"EEQ_DECRES")
         EndIf
      ElseIf nTipoP == OPC_LIQ .OR. nTipoP == OPC_ELQ
         aAdd(aMostra,"EEQ_ACRESC")
         aAdd(aMostra, "EEQ_DECRES")
         AAdd(aMostra, "EEQ_MULTA")
         AAdd(aMostra, "EEQ_JUROS")
         If aScan(aMostra, "EEQ_DESCON") == 0
            AAdd(aMostra, "EEQ_DESCON")
         EndIf
      EndIf
   ENDIF

   SX3->( dbSetOrder(nOrdSX3) )

   // Campos que serem editaveis na Enchoice
   aAltera := {}

   If nTipoP == OPC_INC .OR. nTipoP == OPC_ALT .OR. nTipoP == OPC_LIQ
      aAltera:={"EEQ_DTCE"  ,"EEQ_SOL"   ,"EEQ_DTNEGO",/*"EEQ_DECAM" ,*/;
                "EEQ_CORR"  ,"EEQ_DESCON","EEQ_PGT"   ,;
                "EEQ_NROP"  ,/*"EEQ_TX"    ,*//* "EEQ_OBS"   ,*/;
                "EEQ_VCT"   ,/*"EEQ_EQVL"  ,*/"EEQ_TIPO"}

      //RRC - 26/03/2013 - Alteração para o Easy Siscoserv
      If !IsInCallStack("ESSPS400")
         aAdd(aAltera,"EEQ_DECAM")
      EndIf

      // BAK - 28/09/2012
      If nTipoP == OPC_LIQ
         aAdd(aAltera,"EEQ_TX")
         aAdd(aAltera,"EEQ_EQVL")
      EndIf

      //AOM - 21/08/2012 - Campo Modalidade de Pagamento
      If EEQ->(FieldPos("EEQ_MODAL")) > 0  .And. nTipoP <> OPC_LIQ .And. nTipoP <> OPC_ELQ
         aAdd(aAltera,"EEQ_MODAL")
      EndIf

      If nTipoP <> OPC_LIQ
         aAdd(aAltera,"EEQ_VL"    )
         
         If !(AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116"))//THTS - 17/03/2017 - se for adiatamento fornc. nao deixa trocar
         		aAdd(aAltera,"EEQ_TP_CON")
         EndIf
         
         //RRC - 26/03/2013 - Não permite alteração destes campos para o Easy Siscoserv
         If !IsInCallStack("ESSPS400") .And. !(AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116"))//THTS - 17/03/2017 - se for adiatamento fornc. nao deixa trocar
            aAdd(aAltera,"EEQ_FORN"  )
            aAdd(aAltera,"EEQ_FOLOJA")
            aAdd(aAltera,"EEQ_IMPORT")
            aAdd(aAltera,"EEQ_IMLOJA")
         EndIf
         //RRC - 27/11/2013 - Atualização para verificar no array se o campo EEQ_PROCES foi informado, pois isso indica ser uma chamada do SIGAESS
         If EEQ->(FieldPos("EEQ_VLSISC")) > 0  .And. (nModulo == 85 .Or. IsInCallStack("ESSPS400")) //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And. aScan(aAF500Auto, { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
            aAdd(aAltera,"EEQ_VLSISC")
         EndIf
      EndIf

      If EEQ->(FieldPos("EEQ_MOTIVO")) > 0   //LRS - 16/09/2014
	     aAdd(aAltera,"EEQ_MOTIVO")
	  EndIf

      If nTipoP == OPC_INC .OR. nTipoP == OPC_ALT
         //AHAC - 11/07/2014 - EEQ_PARC travado no caso de - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
         If !AvFlags("ESS_EAI") .And. !(AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116"))//THTS - 21/03/2017 - se for adiatamento fornc. nao deixa alterar
            aAdd(aAltera,"EEQ_PARC")
         EndIf

         //RRC - 26/03/2013 - Não permite alteração da Invoice para o Easy Siscoserv
         If !IsInCallStack("ESSPS400")
            aAdd(aAltera,"EEQ_NRINVO")
         EndIf
      EndIf

      If nTipoP == OPC_INC
         
         //THTS - 17/03/2017 - Nao deixa alterar se for adiantamento de fornecedor
         If !(AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")) 
         	 aAdd(aAltera,"EEQ_EVENT")
         EndIf
         
         //RRC - 27/11/2013 - Atualização para verificar se o campo EEQ_PROCES, pois este indica ser chamada do SIGAESS
         If !(nModulo == 85 .Or. IsInCallStack("ESSPS400"))  //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
            aAdd(aAltera,"EEQ_MOEDA")
         EndIf
      EndIf

      If EECFlags("FRESEGCOM")
         If nTipoP == OPC_INC .OR. nTipoP == OPC_ALT
            If !IsInCallStack("ESSPS400") .And. !(AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")) //RRC - 26/03/2013 - Alteração para o Easy Siscoserv | //THTS - 20/03/2017 - EECAC116 - nao permite alteracao para adiant. forn.
               aAdd(aAltera,"EEQ_CODEMP")
               aAdd(aAltera,"EEQ_PARI")
            EndIf
            //Só permitir alteração de Importador e Fornecedor nos eventos de outras despesas não contabilizadas.
            //RRC - 26/03/2013 - Não permite alteração destes campos para o Easy Siscoserv
            If !IsInCallStack("ESSPS400") .And. !(AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")) .And. (nTipoP == OPC_INC .OR. ( Left(EEQ->EEQ_EVENT,1) $ "3/4" .AND. If(lIntCont,Empty(EEQ->EEQ_NR_CON),.T.) )) //THTS - 17/03/2017 - EECAC116 - nao permite alteracao para adiant. forn.
               aAdd(aAltera,"EEQ_IMPORT")
               aAdd(aAltera,"EEQ_IMLOJA")
               aAdd(aAltera,"EEQ_FORN")
               aAdd(aAltera,"EEQ_FOLOJA")
            EndIf
            //RRC - 27/11/2013 - Atualização para verificar se o campo EEQ_PROCES, pois este indica ser chamada do SIGAESS
            If (nTipoP == OPC_INC  .Or.  nTipoP == OPC_ALT) .And. !(nModulo == 85 .Or. IsInCallStack("ESSPS400")) //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -   .Or. (Type("aAF500Auto") == "A" .And. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
               aAdd(aAltera,"EEQ_MOEDA")
            EndIf
         EndIf
      EndIf

      If EEQ->(FieldPos("EEQ_EMISSA")) > 0 // BAK - 26/09/2012
         aAdd(aAltera, "EEQ_EMISSA")
      EndIf

      If lCpoAcrDcr .And. !lExecAuto
         If nTipoP == OPC_INC .Or. nTipoP == OPC_ALT
            If IsReceita(TRB->EEQ_EVENT)
               AAdd(aAltera, "EEQ_ACRESC")
               AAdd(aAltera, "EEQ_DECRES")
            EndIf
         ElseIf nTipoP == OPC_LIQ
            AAdd(aAltera, "EEQ_MULTA")
            AAdd(aAltera, "EEQ_JUROS")
            If aScan(aAltera, "EEQ_DESCON") == 0
               AAdd(aAltera, "EEQ_DESCON")
            EndIf
         EndIf
      EndIf

      //Tratamentos para alteração de campos de usuário.
      SX3->( dbSetOrder(1) )
      SX3->( dbSeek("EEQ") )

      Do While !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == "EEQ"

         If SX3->X3_PROPRI == "U"
            If ( X3Uso(SX3->X3_USADO) .AND. aScan(aAltera,AllTrim(Sx3->X3_CAMPO)) == 0 )
               aAdd(aAltera,AllTrim(Sx3->X3_CAMPO))
            EndIf
         EndIf

         Sx3->(DbSkip())
      EndDo
   EndIf

   aAdd(aMostra, IncSpace("EEQ_NROPAG", Len(SX3->X3_CAMPO), .F.))

   aAdd(aMostra, IncSpace("EEQ_MOEBCO", Len(SX3->X3_CAMPO), .F.))
   aAdd(aMostra, IncSpace("EEQ_PRINBC", Len(SX3->X3_CAMPO), .F.))
   aAdd(aMostra, IncSpace("EEQ_VLMBCO", Len(SX3->X3_CAMPO), .F.))

   aAdd(aMostra, IncSpace("EEQ_BCOEXT", Len(SX3->X3_CAMPO), .F.))
   aAdd(aMostra, IncSpace("EEQ_CNTEXT", Len(SX3->X3_CAMPO), .F.))
   aAdd(aMostra, IncSpace("EEQ_AGCEXT", Len(SX3->X3_CAMPO), .F.))
   aAdd(aMostra, IncSpace("EEQ_NBCEXT", Len(SX3->X3_CAMPO), .F.))

   aadd(aAltera,"EEQ_BANC"  )
   aadd(aAltera,"EEQ_AGEN"  )
   aadd(aAltera,"EEQ_NCON"  )
   aadd(aAltera,"EEQ_NOMEBC")
   aadd(aAltera,"EEQ_RFBC"  )

   aAdd(aAltera, IncSpace("EEQ_BCOEXT", Len(SX3->X3_CAMPO), .F.))
   aAdd(aAltera, IncSpace("EEQ_CNTEXT", Len(SX3->X3_CAMPO), .F.))
   aAdd(aAltera, IncSpace("EEQ_AGCEXT", Len(SX3->X3_CAMPO), .F.))
   aAdd(aAltera, IncSpace("EEQ_NBCEXT", Len(SX3->X3_CAMPO), .F.))

   aAdd(aAltera, IncSpace("EEQ_PRINBC", Len(SX3->X3_CAMPO), .F.)) //                   paridade negociada e valor do tit. na moeda do banco.
   aAdd(aAltera, IncSpace("EEQ_VLMBCO", Len(SX3->X3_CAMPO), .F.))   

   If EECFlags("CAMBIO_EXT") .And. !AVFLAGS("CAMBIO_EXP_MOV_EXT")
      aAdd(aAltera,"EEQ_NROPAG") //AAF 04/03/08 - Adicionado campo para ordem de pagamento.
   EndIf
   
   If EECFlags("CAMBIO_EXT") .and. nTipoP == BXG_DET
      aAdd(aMostra, IncSpace("EEQ_CONTMV", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_CONTMV", Len(SX3->X3_CAMPO), .F.))
   endif

   aAdd(aAltera,"EEQ_OBS")  // AAF - 10/11/2014

   If (IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSPS400")  .Or.  IsInCallStack("ESSPS401")).And. AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. AvFlags("CONTROLE_SERVICOS_VENDA") .And. aScan(aMostra, {|x| x="EEQ_PREEMB"})>0 //FSM - 29/10/2012
      aDel(aMostra, aScan(aMostra, {|x| x="EEQ_PREEMB"}))
      aSize(aMostra, Len(aMostra))
   EndIf

   //Calcula o saldo disponível com relação ao valor negociado para alocacao na parcela.
   nOrd    := EEQ->( IndexOrd() )
   nRecEEQ := EEQ->( RecNo() )

   IF nTipoP # OPC_VIS
      bOK := {|| If(nTipoP <> OPC_EST, If(Obrigatorio(aGets,aTela) .AND. AF500Valid("OK"),Eval(bOK2), ), Eval(bOK2))}
   ENDIF
   lOK:= .F.

   If(EasyEntryPoint("EECAF500"),ExecBlock("EECAF500",.F.,.F.,"ANTES_TELA_MANUT"),)

   If Type("lEEQAuto") == "L" .And. lEEQAuto
      If Type("bEEQAuto") == "B"
         Eval(bEEQAuto)
      EndIf
   ElseIf !lExecAuto
      DEFINE MSDIALOG oDlg TITLE cTITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
         aPos := PosDLG(oDLG)

         //Não permite alterações em FFC.
         If nTipoP <> OPC_INC .AND. !Empty(EEQ->EEQ_FFC)
            aAltera := {}
         EndIf

         //NOPADO por RRC - 14/08/2012 - Criação objeto MsmGet()
         //Enchoice("EEQ",0, If(nTipoP == BXG_DET, ALTERAR, nTipoP),,,,aMostra,aPos,aAltera,3)
         //oEnc:=MsmGet():New("EEQ",, If(nTipoP == BXG_DET, ALTERAR, nTipoP),,,,aMostra,aPos,aAltera,3,,,,oDlg)
         oEnc:=MsmGet():New("EEQ",, If(nTipoP > Len(aRotina), ALTERAR, nTipoP),,,,aMostra,aPos,aAltera,3,,,,oDlg)
         oEnc:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //RRC - 13/08/2012 - Centraliza a tela

         If nTipoP == OPC_ALT//FSY - 20/01/2014 - Botão conhecimento na ação alterar
            Aadd(aButtons,{"CLIPS",{ ||  MsDocument( "EEQ", EEQ->(RecNo()), 1,) }  ,"Conhecimento"})//FSY-17/01/2014-Botão conhecimento. //EEQ
         End If
         DEFINE SBUTTON oBTN FROM 5000,235 TYPE 1 ENABLE OF oDlg
         oDlg:lMaximized := .T.
      ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDLG,bBarOK,bBarCancel,,aButtons), If(nTipoP==OPC_ELQ, If(AF500ELiq(),Eval(bOK),Eval(bCancel)),))
   Else
      EnchAuto("EEQ",aExecAuto,bBarOk,nTipoP,aAltera)
      // Força a validação quando for exclusão da parcela, pois na manutenção de exclusao nao esta rodando a execução do codeblock
      If nTipoP == OPC_EST
         Eval(bBarOk)
      EndIf

      //RRC - 15/07/2013 - Tratamento para casos de estorno da baixa
      If nTipoP == OPC_ELQ
         If AF500ELiq(.T.)
            Eval(bOK)
         Else
            Eval(bCancel)
         EndIf
      EndIf
      lRet := lOk

      If Type("lMsErroAuto") == "L" .And. lMsErroAuto
         lOk := !lMsErroAuto
      EndIf

   EndIf

   If !IsInCallStack("AeGerParc") .And. lConfirma .And. (nTip == 3 .Or. nTip == 4) .AND. IsInCallStack("ESSPS400")  //LGS-17/02/2014  // GFP - 22/10/2014
      cVlDig    := M->EEQ_VL       //Valor Digitado
      cVlTotInv := ELA->ELA_VL_MOE //Valor Total da Invoice
      cProcesso	:= M->EEQ_PREEMB   //Numero do processo
      If !(VALINCALT(cVlDig,cVlTotInv,cProcesso,nTip,cAlias,nRec,lAtua,ELA->ELA_NRINVO))
      	 Break
      EndIf
   EndIf

   If(EasyEntryPoint("EECAF500"),ExecBlock("EECAF500",.F.,.F.,"APOS_TELA_MANUT"),)//O lOK esta PRIVATE pode ser usado para sair (lOK:=.F.)

   If lOK .And. nTipoP # OPC_VIS //THTS - 21/03/2017 - Nao atualizar a EEQ quando for visualizacao
      //RRC - 15/02/2013 - Verifica se já não existe uma transação aberta antes de chamar a função responsável por realizar as operações na tabela EEQ
      If !InTransact()
         Begin Transaction
            Processa({|| lRet:= (AF500AtuaEEQ(nRec, @lAlterouDtCred) .AND. IIF( AF500EAIIntg(M->EEQ_PROCES, M->EEQ_FASE), EVAL(bIntLogix), .T.))}, STR0001)
            //If !(lRet := (AF500AtuaEEQ(nRec) .AND. /*AHAC*/ IF(lMV_ESS_EAI,EVAL(bIntLogix), .T.))) //AHAC - 11/07/2014 - Integração Logix - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
            If !lRet
               /*Para casos de execauto do Siscoserv, mesmo com a chamada do EasyHelp() na função AF500AtuaEEQ(), a variável de erro
               não era atualizada após uma inclusão com sucesso e tentativa inválida de exclusão logo em seguida*/
               If Type("lMSErroAuto") <> "U" .And. !lMSErroAuto
                  lMSErroAuto := !lRet
               EndIf
               ELinkRollBackTran()
            EndIf
          End Transaction
          If !lRet
             ELinkClearID()
          EndIf
      Else
         If !(lRet := (AF500AtuaEEQ(nRec, @lAlterouDtCred) .AND. /*AHAC*/ IF( AF500EAIIntg(M->EEQ_PROCES, M->EEQ_FASE),EVAL(bIntLogix), .T.))) //AHAC - 11/07/2014 - Integração Logix - EF TDE_REQ9.0_ESS - Projeto Proposta 140117
            /*Para casos de execauto do Siscoserv, mesmo com a chamada do EasyHelp() na função AF500AtuaEEQ(), a variável de erro
            não era atualizada após uma inclusão com sucesso e tentativa inválida de exclusão logo em seguida*/
            If Type("lMSErroAuto") <> "U" .And. !lMSErroAuto
               lMSErroAuto := !lRet
            EndIf
            ELinkRollBackTran()
            //ELinkClearID()
         EndIf
      EndIf
      /* WFS set-2016 - execução da liquidação do evento principal.
         Migrado para fora da transação, para abertura de tela.
         Objetivos: possibilitar ao usuário informar os dados para liquidação do evento e
         executar a tela fora da transação.
         A flag lLiqAutoFinancing será alterada para verdadeiro quando o evento principal (700) for totalmente liquidado. */
      If lFinanciamento
         If EasyGParam("MV_LIQAUTO",, .F.) .And. lLiqAutoFinancing

            //Variáveis privadas utilizadas no EFFEX400 e EFFEX401
            Private aGetProv := {}  ,;
                    lInverte := .F. ,;
                    cMod     := "E" ,;
                    cTX_100  := ""  ,;
                    cTX_520  := ""

            Processa({|| AF201SelLiq(aLiqAuto)}, "Integração Easy Financing", "Liquidação do Financiamento.")
         EndIf
      EndIf
   EndIf

   //RRC - 25/03/2013 - Atualiza saldo a baixar e o status da invoice associada a parcela
   If lRet .And. (IsInCallStack("ESSPS400") .Or. (Type("lAF500Auto") == "L" .And. lAF500Auto))
      //If nTipoP == OPC_LIQ //wfs - movimento no exterior
      /* Após ter sido baixada no exterior, a parcela não permitirá alteração, evitando duplicação desta operação */
      If nTipoP == OPC_LIQ .Or. (nTipoP == OPC_ALT .And. EasyVerModal("EEQ") .And. !Empty(EEQ->EEQ_DTCE))
         If RecLock("ELA",.F.)
            //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
            ELA->ELA_SLDPAG := ELA->ELA_SLDPAG - (If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL))
            ELA->(MsUnLock())
         EndIf
         IS400StaInv()
      //ElseIf nTipoP == OPC_ELQ //wfs - movimento no exterior
      /*Mesmo quando for baixa com movimento no exterior, o estorno será realizado pela ação de estorno da liquidação,
        quando realizada manualmente. Porém, vinda pela integração com o SIGAFIN, a operação será de alteração. */
      ElseIf nTipoP == OPC_ELQ .Or. (nTipoP == OPC_ALT .And. EasyVerModal("EEQ") .And. Empty(EEQ->EEQ_DTCE) .And. lAlterouDtCred)
         If RecLock("ELA",.F.)
            //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
            ELA->ELA_SLDPAG := ELA->ELA_SLDPAG + (If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL))
            ELA->(MsUnLock())
         EndIf
         IS400StaInv()
      EndIf
   EndIf

   //RRC - 16/08/2012 - Para uso da função Refresh() no objeto, este deverá já ter sido aberto
   If !lExecAuto .And. ((Type("lEEQAuto") <> "L" .Or. !lEEQAuto) .And. lAtua == .F.  .And. (!IsInCallStack("ESSRS400") .And. !IsInCallStack("ESSPS400") .And. !(AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")) ))//AOM - 24/08/2012 | THTS - 17/03/2017 adiconada EECAC116
      oMark:oBrowse:Refresh()
   EndIf

End Sequence

If AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")//THTS - 27/03/2017 - Adiantamento de Fornecedores
	RestOrd(aOrdSA2,.T.)
EndIf

dbSelectArea(cAlias)

Return lRet

//*******************************************************************************
//LGS-17/02/2014-Função para Validar a Inclusão e Alteração de parcelas de cambio
//*******************************************************************************
Function VALINCALT(cVlrDig,cVlrTotInv,cProcesso,nOpc,cAlias,nRec,lAtua,cNrInvo)
//*******************************************************************************
Local cVlTotParc := cTotalSoma := nEEQ := 0
Local nCont      := nTipoParc  := nPrxParc := 0
Local lGeraParc  := .F.
Local lRet	     := .T.
Private cUltParc := ""
Begin Sequence
cProcesso := AvKey(cProcesso,"EEQ_PREEMB")
EEQ->(DbSetOrder(4)) //EEQ_FILIAL, EEQ_NRINVO, EEQ_PREEMB, EEQ_PARC
If EEQ->(DbSeek(xFilial("EEQ") + cNrInvo + cProcesso))
	DO WHILE EEQ->(!Eof()) .And. EEQ->EEQ_NRINVO == cNrInvo .And. EEQ->EEQ_PREEMB == cProcesso
		If ELA->ELA_ORIGEM !="SIGACOM" .And. EEQ->(FieldPos("EEQ_VLSISC")) > 0 .And. (nModulo == 85 .Or. IsInCallStack("ESSPS400")) //THTS - 29/06/2017 - Caso seja siscoserv, verifica o valor no EEQ_VLSISC
         cVlTotParc += EEQ->EEQ_VLSISC
      Else
         cVlTotParc += EEQ->EEQ_VL
      EndIf
      nCont += 1
      If cUltParc < EEQ->EEQ_PARC //THTS - 29/06/2017 - Armazena a maior parcela gerada
         cUltParc := EEQ->EEQ_PARC
      EndIf
		EEQ->(DbSkip())
	ENDDO
EndIf

//THTS - 29/06/2017 - Retirado, pois o nCont nem sempre sera a ultima parcela, o que dava erro de unique constraint
//cUltParc := StrZero(nCont,AvSx3("EEQ_PARC",3))//cValToChar(nCont)  // GFP - 13/03/2015

Do Case
	Case nOpc == 3
		If nCont == 0
			If cVlrDig > cVlrTotInv
				MsgInfo(STR0104) //Não é permitido incluir parcela com valor maior que o total da invoice.
				lRet := .F.
			Else
				Break
			EndIf
		Else
			cTotalSoma := (cVlTotParc + cVlrDig)
			If cTotalSoma > cVlrTotInv
				MsgInfo(STR0105 + STR0107) //"A soma total do valor das parcelas + o valor digitado ultrapassa o valor total da invoice." // "Não é permitido incluir parcelas onde a soma do valor total seja maior que o total da invoice."
				lRet := .F.
			Else
				Break
			EndIf
		EndIf

	Case nOpc == 4
		If nCont > 1 .And. (cVlTotParc == cVlrTotInv)
			If TRB->(!Eof()) .And. TRB->(dbSeek(M->EEQ_PARC))
				If cVlrDig == TRB->EEQ_VL
					Break
				ElseIf cVlrDig < TRB->EEQ_VL
				    nTipoParc := "1"
				    lGeraParc := .T.
				Else
					MsgInfo (STR0106 + Trans(TRB->EEQ_VL,'@E999.999.999,9999') ) //"Não é permitido a alteração do valor onde a soma do valor total seja maior que o total da invoice, corrija o valor digitado ou mantenha o mesmo valor, "
					AF500MAN(cAlias,nRec,nOpc,lAtua)
					lRet:= .F.
					Break
	      	 	EndIf
      	   	EndIf

    	ElseIf nCont > 1 .And. (cVlTotParc < cVlrTotInv)
			If TRB->(!Eof()) .And. TRB->(dbSeek(M->EEQ_PARC))
				If cVlrDig == TRB->EEQ_VL
					Break
				ElseIf cVlrDig > TRB->EEQ_VL
					cTotalSoma := (cVlTotParc + (cVlrDig - TRB->EEQ_VL))
					If cTotalSoma > cVlrTotInv
						MsgInfo (STR0106 + Trans(TRB->EEQ_VL,'@E999.999.999,9999') ) //"Não é permitido a alteração do valor onde a soma do valor total seja maior que o total da invoice, corrija o valor digitado ou mantenha o mesmo valor, "
						AF500MAN(cAlias,nRec,nOpc,lAtua)
						lRet:= .F.
						Break
					Else
						Break
					EndIf
	      	 	EndIf
      	   	EndIf

    	Else
      		If cVlrDig < cVlrTotInv
      			If TRB->(!Eof()) .And. TRB->(dbSeek(M->EEQ_PARC))
      			   TRB->(DBGoTop())
				   nTipoParc := "2"
				   lGeraParc := .T.
	        	EndIf
      		Else
      			Break
      		EndIf
      	EndIf

      	If lGeraParc
      		nCont++ //(Numero da proxima parcela)
      		If nTipoParc == "1"
			   TRB->EEQ_PARC   := AvKey(EasyGetParc(nCont),"EEQ_PARC")
			   TRB->EEQ_VL     := TRB->EEQ_VL - M->EEQ_VL
			   TRB->EEQ_VLSISC := TRB->EEQ_VL
			Else /*If nTipoParc == 2*/
			   TRB->EEQ_PARC   := AvKey(EasyGetParc(nCont),"EEQ_PARC")
		       TRB->EEQ_VL     := ELA->ELA_VL_MOE - M->EEQ_VL
		       TRB->EEQ_VLSISC := ELA->ELA_VL_MOE - M->EEQ_VL
	  		EndIf
			TRB->EEQ_PREEMB := M->EEQ_PREEMB
	      	TRB->EEQ_IMLOJA := M->EEQ_IMLOJA
	      	TRB->EEQ_HVCT   := M->EEQ_HVCT
	      	TRB->EEQ_TPPROC := M->EEQ_TPPROC
	      	TRB->EEQ_EMISSA := DATE()
	      	If AF500EAIIntg(M->EEQ_PROCES, M->EEQ_FASE)
              TRB->EEQ_FINNUM:= ""
      		EndIf
	      	EEQ->(RecLock("EEQ",.T.))
	      	AvReplace("TRB","EEQ")
	      	EEQ->EEQ_FINNUM := ""  // GFP - 13/03/2015

	      	If AF500EAIIntg(M->EEQ_PROCES, M->EEQ_FASE)
	      	   /* Armazena o registro novo para transmissão ao ERP, via EAI. */
	      	   AAdd(aEAIUpsert, EEQ->(RecNo()))
	      	EndIf

	      	EEQ->( MsUnLock() )
	      	nEEQ := EEQ->(Recno())  // GFP - 13/03/2015
	      	PS500Atua()
			If !(AF500Integ(nEEQ,OPC_INC,.F.,.F.))  // GFP - 13/03/2015
				EasyHelp(STR0096) // "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
			EndIf
      	EndIf
    EndCase

End Sequence
Return lRet

//***************************************************//
Function AF500ELiq(lMsg)
//***************************************************//
Local nPos
Local cStatus
Default lMsg:= .F.
PRIVATE lRet:= .F.

If(EasyEntryPoint("EECAF500"),ExecBlock("EECAF500",.F.,.F.,"VALIDA_ESTORNA_LIQUIDACAO"),)
IF lRet
   RETURN .F.
ENDIF

If lMsg .Or. MsgYesNo(STR0026)//"Confirma Estorno da Liquidação?"

   If(EasyEntryPoint("EECAF500"),ExecBlock("EECAF500",.F.,.F.,"ESTORNA_LIQUIDACAO"),)
   IF lRet
      RETURN .F.
   ENDIF

      If EasyVerModal("M")
            M->EEQ_DTCE:= CToD("  /  /  ")
            //MFR OSSME-2433 28/02/2019
            M->EEQ_PGT:= CToD("  /  /  ")
      Else
            M->EEQ_PGT:= CToD("  /  /  ")
      EndIf  

   //** PLB 02/06/06 - Estorna evento de liquidacao no contrato de Financiamento
   If lFinanciamento
      nPos := AScan( aVinculados , { |x| x[2]+x[3] == M->EEQ_NRINVO+M->EEQ_PARC } )
      If nPos > 0
         Processa( {|| AF500ELqFin(nPos) } , STR0071 )  //"Estornando Eventos de Financiamento..."
      EndIf
   EndIf
   //**

   lRet := .T.


   If lRet .AND. nModulo == 85 .AND. IsInCallStack("ESSPS500") .AND. EasyGParam("MV_ESS0027",,9) >= 10
      //MFR 05/06/2019 OSSME-3017 
      If PS402Pagto(nRecEEQ,7,"",@cStatus) .AND. @cStatus <> '1' .AND. cTpReg=='A' .AND. !MsgYesNo(STR0111,STR0011)  //"Deseja cancelar o RP referente a este câmbio?"   ###  "Aviso"
         If Type("lNaoCancelar") == "L"
            lNaoCancelar := .T.
         EndIF
      EndIf
   EndIf
EndIf

Return lRet

//***************************************************//
//Função......: AF500Valid()
//Programador.: Alessandro Alves Ferreira - AAF
//Objetivo....: Validações para o câmbio do tipo 3/4.
//Data........: 29/11/05 - 15:21
//***************************************************//
Function AF500Valid(cCampo/*,lVerif*/)
//***********************************************//
//Local oDlg3           //RRC - 15/08/2012
//Default lVerif := .F. //RRC - 15/08/2012
Local cTpMod := ""
Local cChave := ""
Local aOrd := {} //LRS - 20/02/2018
Local aEventsAdt := {"605","606"} // NCF - 03/07/2019
Local cEventsAd  := ""            // NCF - 03/07/2019
lRet := .T.

Do Case

   Case cCampo == "EEQ_TP_CON"
      If !(M->EEQ_TP_CON $ "3/4")
         EasyHelp(STR0027)//"Só é permitida a manutenção dos contratos tipo 3 e tipo 4."
         lRet := .F.
      EndIf

   Case cCampo == "EEQ_PARC"
      //EEQ->( dbSetOrder(1) )

//    If If(nTipoP <> OPC_INC, M->EEQ_PARC <> EEQ->EEQ_PARC, .T.) .AND. EEQ->( dbSeek(xFilial("EEQ")+M->EEQ_PREEMB+M->EEQ_PARC) )
      //RRC - 26/09/2013 - SIGAESS utiliza outro índice
      If IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIS400") .Or. IsInCallStack("PS400BUSCFAT") //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS - .Or. (Type("aAF500Auto") == "A" .And.  (aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0)) //wfs - considerar chamada do módulo sigacom
         cChave := M->EEQ_PARC+M->EEQ_NRINVO
      Else
         cChave := M->EEQ_PARC
      EndIf

      If nTipoP = OPC_INC .AND. TRB->( dbSeek(cChave) )
         EasyHelp(STR0028)//"Parcela já cadastrada para este Processo."
         lRet := .F.
      EndIf

      aOrd :=SaveOrd({"EEQ"}) //LRS - 20/02/2018
      EEQ->( dbSetOrder(4))
      IF nTipoP = OPC_INC
            If M->EEQ_TP_CON $ "3/4"
                  IF EEQ->(dbSeek(xFilial("EEC")+Avkey(M->EEQ_NRINVO,"EEQ_NRINVO")+Avkey(M->EEQ_PREEMB,"EEQ_PREEMB")+AvKey(M->EEQ_PARC,"EEQ_PARC")))
                        EasyHelp(STR0028)//"Parcela já cadastrada para este Processo."
                        lRet := .F.
                  EndIF 
            EndIF
      EndIF
      RestOrd(aOrd,.T.)

   Case cCampo == "EEQ_PREEMB"
      //If lVerif == .T. //RRC - 15/08/2012 - Solicita o processo após clicar em "Inclusão" no botão "Ações Relacionadas" do "Câmbio Serviços"
         //DEFINE MSDIALOG oDlg3 TITLE STR0062 From 9,0 To 18,50 OF oMainWnd //"Gera Arquivo"
           // @ 16,10 SAY   STR0035       SIZE 30,10 OF oDlg3 PIXEL  //"Processo"
            //@ 16,40 MSGET M->EEQ_PREEMB SIZE 75,08 PICTURE AVSX3("EEQ_PREEMB",6)  OF oDlg3 PIXEL  WHEN (nTipo = OPC_INC .AND. TRB->(EOF() .AND. BOF()))//Valid AF500Valid("EEQ_PREEMB")
         //ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlg3,{||oDlg3:End()},{||lRet:=.F.,oDlg3:End()})
      //EndIf

      EEC->( dbSetOrder(1) )
      EEQ->( dbSetOrder(1) )

      If EMPTY(M->EEQ_PREEMB)
         EasyHelp(STR0038) //"Processo nao informado"
         lRet := .F.
//    ElseIf If(nTipo <> OPC_INC, M->EEQ_PREEMB <> EEQ->EEQ_PREEMB, .T.) .AND. EEQ->( dbSeek(xFilial("EEQ")+M->EEQ_PREEMB))//+M->EEQ_PARC) )
      ElseIf (TRB->(EOF() .AND. BOF())) .AND. EEC->( dbSeek(xFilial("EEC")+M->EEQ_PREEMB)) .AND. !IsInCallStack("ESSRS400") .And. !IsInCallStack("ESSPS400")// AOM - 28/08/2012  - //+M->EEQ_PARC) )
//       EasyHelp(STR0028)//"Parcela já cadastrada para este Processo."
         EasyHelp(LEFT(STR0029,27))//"Processo já está cadastrado no Embarque da Exportação."
         lRet := .F.
      ElseIf EEC->( dbSeek(xFilial("EEC")+M->EEQ_PREEMB) )
         EasyHelp(STR0029)//"Processo já está cadastrado no Embarque da Exportação."
         lRet := .F.
      EndIf


   Case (cCampo == "EEQ_FORN" .OR. cCampo == "EEQ_IMPORT") .And. IsInCallStack("ESSIN100")
      Do Case
         Case ELA->ELA_TPPROC == "A"
            If !Empty(ELA->ELA_EXPINV).And.!(M->EEQ_FORN   == ELA->ELA_EXPINV .And. M->EEQ_FOLOJA == ELA->ELA_ELJINV)
               lRet := .F.
               EasyHelp("O Fornecedor: "+Alltrim(M->EEQ_FORN)+" Loja: "+Alltrim(M->EEQ_FOLOJA)+" não se relaciona ao Fornecedor registrado na invoice.")
               lMSErroAuto := .T.
            ElseIf Empty(ELA->ELA_EXPINV).And.!(M->EEQ_FORN   == ELA->ELA_EXPORT .And. M->EEQ_FOLOJA == ELA->ELA_LOJEXP)
               lRet := .F.
               EasyHelp("O Fornecedor: "+Alltrim(M->EEQ_FORN)+" Loja: "+Alltrim(M->EEQ_FOLOJA)+" não se relaciona ao Fornecedor registrado na invoice")
               lMSErroAuto := .T.
            End If

         Case ELA->ELA_TPPROC == "V"
            If !Empty(ELA->ELA_IMPINV).And.!(M->EEQ_IMPORT == ELA->ELA_IMPINV .And. M->EEQ_IMLOJA == ELA->ELA_ILJINV)
               lRet := .F.
               EasyHelp("O Importador: "+Alltrim(M->EEQ_IMPORT)+" Loja: "+ Alltrim(M->EEQ_IMLOJA)+" não se relaciona ao importador registrado na invoice.")
               lMSErroAuto := .T.
            ElseIf Empty(ELA->ELA_IMPINV).And.!(M->EEQ_IMPORT == ELA->ELA_IMPORT .And. M->EEQ_IMLOJA == ELA->ELA_LOJIMP)
               lRet := .F.
               EasyHelp("O Importador: "+Alltrim(M->EEQ_IMPORT)+" Loja: "+ Alltrim(M->EEQ_IMLOJA)+" não se relaciona ao importador registrado na invoice.")
               lMSErroAuto := .T.
            End If
      End Case


   Case cCampo == "OK"
      //RRC - 11/07/2013 - Verifica a Origem da invoice para validar se pode ou não adicionar novas parcelas de câmbio pelo SIGAESS
      If IsInCallStack("ESSIN100") .And. ValType("nTipoP") <> "U"
         If nTipoP == OPC_INC .And. (AllTrim(ELA->ELA_ORIGEM) == "SIGACOM" .Or. AllTrim(ELA->ELA_ORIGEM) == "SIGAFAT") .And. !EasyGParam("MV_ESS0010")
            EasyHelp("Esta invoice foi originada pelo " + AllTrim(ELA->ELA_ORIGEM) + " e novas parcelas de câmbio não poderão ser incluídas.","Aviso")
            lRet := .F.
         //RRC  - 09/12/2013 - Valida se a parcela de câmbio foi gerada pelo SIGAFIN ou se a origem é o SIGAEIC ou SIGAEEC. Nestes casos, ela não poderá ser alterada pelo SIGAESS.
         ElseIf nTipoP > OPC_INC .And. (AllTrim(Upper(EEQ->EEQ_SOURCE)) == "SIGAFIN" .Or. (AllTrim(Upper(EEQ->EEQ_SOURCE)) == "SIGAEIC" .And. !(EasyGParam("MV_EASYFDI",,"") == "S" .And. EasyGParam("MV_EASYFIN",,"") == "S")) .Or. AllTrim(Upper(EEQ->EEQ_SOURCE)) == "SIGAEEC")
            EasyHelp("Parcela gerada pelo " + AllTrim(Upper(EEQ->EEQ_SOURCE)) + ". Não será possível modificá-la pelo SIGAESS.")
            lRet := .F.
         EndIf
      EndIf

      If Empty(M->EEQ_PREEMB) .And. lRet
         EasyHelp(STR0030)//"O Processo deve estar preenchido."
         lRet := .F.
      ElseIf nTipoP == OPC_LIQ .And. lRet                                                                                     //NCF - 08/10/2015 - Integ. EEC x ESS (Desp./Comiss.)
         If Empty(M->EEQ_DTCE) .And. !EECFlags("CAMBIO_EXT") .And. EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. M->EEQ_MODAL == "2" .And. If(EEQ->(FieldPos("EEQ_EVTORI")) > 0,M->EEQ_EVTORI <> "122",.T.)
            EasyHelp(STR0033)//"Obrigatório o preenchimento da Data de Crédito no Exterior para liquidação."
            lRet := .F.
         //** PLB 05/06/06                                                                        //NCF - 08/10/2015 - Integ. EEC x ESS (Desp./Comiss.)
         ElseIf  IF(EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. M->EEQ_MODAL == "2",Empty(M->EEQ_DTCE) .And. If(EEQ->(FieldPos("EEQ_EVTORI")) > 0,M->EEQ_EVTORI <> "122",.T.) ,Empty(M->EEQ_PGT))//AOM - 24/08/2012 // BAK - 27/09/2012
            Help("",1,"AVG0005092")
            lRet := .F.
         //ElseIf !EasyVerModal() .AND. !(M->EEQ_TX > 0)
         ElseIf !EasyVerModal("M") .AND. !(M->EEQ_TX > 0)
            Help("",1,"AVG0005093")
            lRet := .F.
         ElseIf !AF500Valid("BANCO")
            lRet := .F.
         EndIf
         //**
      EndIf

      If lRet
         If nTipoP == OPC_ALT  .And.  Empty(M->EEQ_MOEDA)
            EasyHelp(STR0045)  //"Obrigatorio o preenchimento da Moeda."
            lRet := .F.
         ElseIf !AF500Valid("EEQ_PREEMB")
            lRet:= .F.
         ElseIf !AF500Valid("EEQ_IMPORT")
            lRet := .F.
         ElseIf !AF500Valid("EEQ_PARC")
            lRet:= .F.
         ElseIf !AF500Valid("EEQ_VL") // BAK - 27/09/2012
            lRet := .F.
         ElseIf !AF500Valid("BANCO") // BAK - 27/09/2012
            lRet := .F.
         ElseIf !AF500Valid("MOEDA") // BAK - 27/09/2012
            lRet := .F.
         ElseIf nTipoP == OPC_LIQ .And. !AF500Valid("EEQ_NROP")
            lRet := .F.
         EndIf
      EndIf

      //RRC - 27/11/2013 - Validação do SIGAESS com a atualização da verificação do campo EEQ_PROCES no array, o que também indica ser chamada para o SIGAESS
      If lRet .And. (nModulo == 85 .Or. IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100") .Or. IsInCallStack("DI505ESS")) //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
         //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
         If EEQ->(FieldPos("EEQ_VLSISC")) > 0 .And. (Empty(M->EEQ_VLSISC)) //.Or. M->EEQ_VLSISC > M->EEQ_VL) //THTS - 29/06/2017 - Retirado no TE-6013
            If Empty(M->EEQ_VLSISC)
               EasyHelp("Valor Siscoserv inválido. Conteúdo não informado.")
               lRet := .F.
            EndIf
            /*Else //THTS - 29/06/2017 - Retirado no TE-6013
               If !(Type("lAF500Auto") == "L" .And. lAF500Auto)
                  EasyHelp("Valor Siscoserv inválido. Considere que o valor dos serviços deve ser igual ou inferior ao valor da parcela.")
                  lRet := .F.
               Else
                  M->EEQ_VLSISC := M->EEQ_VL
               EndIf
            EndIf*/
         EndIf
         //RRC - 06/08/2013 - Valida Agência e Número da Conta para o módulo SIGAESS
         If lRet .And. nTipoP == OPC_LIQ
            If (lRet := AF200Valid("EEQ_AGEN"))
               lRet := AF200Valid("EEQ_NCON")
            EndIf
         EndIf
      EndIf

   Case cCampo == "EEQ_EVENT"

      cTpMod := "EXPORT"
      //RRC - 16/01/2013 - Alteração para buscar o campo "EEQ_REGIST" no Array                                                                                        //RRC - 06/08/2013 - Verifica se o Array existe
      If (IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSRS403") .Or. IsInCallStack("ESSPS401") .Or. IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100")) .Or. (Type("aAF500Auto") == "A" .And.  (aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_REGIST" }) > 0)) //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
         cTpMod := "SISCSV"
      EndIf

      EC6->( dbSetOrder(1) )//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC                                                                      //NCF - 08/10/2015 - Integ. EEC x ESS (Desp./Comiss.)
      If (lRet := EC6->( dbSeek(xFilial("EC6")+cTpMod+M->EEQ_EVENT) )) .And. (EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. M->EEQ_TP_CON $ "3/4" .OR. Empty(M->EEQ_TP_CON) ) .And. If(EEQ->(FieldPos("EEQ_EVTORI")) > 0,M->EEQ_EVTORI <> "122",.T.)
         If EC6->EC6_RECDES == '1'
            M->EEQ_TIPO := "R"
         ElseIf EC6->EC6_RECDES == '2'
            M->EEQ_TIPO := "P"
         EndIf
      ElseIf EEQ->(FieldPos("EEQ_EVTORI")) > 0 .And. M->EEQ_EVTORI == "122"  //NCF - 08/10/2015 - Integ. EEC x ESS (Desp./Comiss.)
         M->EEQ_TIPO := "P"
         lRet := .T.
      ElseIf !lRet
         EasyHelp(STR0103) // "Não existe registro relacionado a este código."
      EndIf

		//THTS - 21/03/2017 - Nao permite utilizar o evento 609 de adiantamento a fornecedor
      If lRet .And. M->EEQ_EVENT=='609' //Adiantamento a Fornecedor
      	  lRet := .F.
         EasyHelp(STR0113)//"Este evento não é válido para processos de câmbio exportação."
      EndIf

	//THTS - 08/05/2017 - 514495 / MTRADE-879 - Bloquear evento desconto e devolucao quanto habilitado MV_AVG0213 e MV_AVG0214
      If lRet .And. M->EEQ_EVENT $ '801|802' .And. (EECFlags("TIT_PARCELAS") .And. EECFlags("ALT_EASYLINK"))
         lRet := .F.
         EasyHelp(STR0114 +" "+ STR0115) //"Não é possível aplicar Desconto(801)/Devolução(802), pois a integração com o financeiro não permite alterações no título (Parâmetros MV_AVG0213 e MV_AVG0214)." //"Para conceder um desconto, utilize o campo de desconto por parcela (Parâmetro MV_EEC0046)."
      EndIf

      //RRC - 26/03/2013 - Validação para o Easy Siscoserv
      If lRet .And. (IsInCallStack("ESSPS400") .Or. (Type("lAF500Auto") == "L" .And. lAF500Auto))
         If ELA->ELA_TPPROC == "A"
            If !(lRet := Val(AllTrim(M->EEQ_EVENT)) > 0 .And. Val(AllTrim(M->EEQ_EVENT)) < 501)
               EasyHelp("Este evento não é válido para processos de aquisição de serviço.")
            EndIf
         ElseIf ELA->ELA_TPPROC == "V"
            If !(lRet := Val(AllTrim(M->EEQ_EVENT)) > 500)
               EasyHelp("Este evento não é válido para processos de venda de serviço.")
            EndIf
         EndIf
      EndIf
      //NCF - 03/07/2019 - Validação para adiantamentos de cliente tipos "RA"/"NCC"
      If IsInCallStack('AC100Adian') .And. Select('Work_Pgto') .And. Type('M->EEQ_EVENT') <> 'U'         
         If Empty(M->EEQ_EVENT) .Or. Ascan(aEventsAdt, Alltrim(M->EEQ_EVENT)) == 0
            aEval( aEventsAdt, {|X| cEventsAd += (X+",") } )
            EasyHelp(  StrTran(  STR0116 , "###" , cEventsAd   ) ) //"Código do evento de adiantamento inválido! O evento deve ser informado e deve estar entre os códigos: ###"
            lRet := .F.
         Else
            M->EEQ_MODAL := "1" //+ " - Contrato de Câmbio"              
         EndIf
      EndIf

   Case cCampo == "EEQ_VL"

      //RRC - 25/03/2013 - Incluída condição do SIGAESS: Não permite incluir um valor de parcela superior ao saldo a baixar da invoice invulcada
      If M->EEQ_VL == 0
         EasyHelp(STR0097) // "Valor da parcela inváido."
         lRet := .F.
         //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
      ElseIf (nTipoP == OPC_LIQ .And. Type("lAF500Auto") == "L" .And. lAF500Auto .And. If(EEQ->(FieldPos("EEQ_VLSISC")) > 0,EEQ->EEQ_VLSISC,EEQ->EEQ_VL) > ELA->ELA_SLDPAG) //AAF - 25/04/2013 - Validar apenas em caso de execauto. Na tela a validação é feita no menu.
         EasyHelp("Não é possível liquidar esta parcela pois não há saldo a receber suficiente para a Invoice")
         lRet := .F.
      EndIf

      /*If nTipoP == OPC_LIQ .And. M->EEQ_VL <> EEQ->EEQ_VL
         EasyHelp(STR0097) // "Valor da parcela inváido."
         lRet := .F.
      EndIf*/
   Case cCampo == "BANCO"  //NCF - 08/10/2015 - Integ. EEC x ESS (Desp./Comiss.)
      If nTipoP == OPC_LIQ .And. If(EEQ->(FieldPos("EEQ_EVTORI")) > 0,M->EEQ_EVTORI <> "122",.T.)
         If EasyVerModal("M") // EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. M->EEQ_MODAL == "2"
            If EEQ->(FieldPos("EEQ_BCOEXT")) > 0 .And. Empty(M->EEQ_BCOEXT)
               EasyHelp(STR0098) // "Informe o banco no exterior."
               lRet := .F.
            EndIf
         Else
            If Empty(M->EEQ_BANC)
               EasyHelp(STR0099) // "Informe o banco."
               lRet := .F.
            EndIf
         EndIf
      EndIf
   Case cCampo == "MOEDA"
      If nTipoP == OPC_INC
         If Empty(M->EEQ_MOEDA)
            EasyHelp("Informe a moeda.")
            lRet := .F.
          //RRC - 11/07/2013 - Validação para o Easy Siscoserv
         ElseIf (nModulo == 85 .Or. IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100")) .And. ELA->ELA_MOEDA <> M->EEQ_MOEDA
            EasyHelp("A moeda da parcela de câmbio deve ser a mesma da invoice")
            lRet := .F.
         EndIf
       EndIf
   Case cCampo == "EEQ_NROP"
      If nTipoP == OPC_LIQ
      //RRC - 01/10/2013 - Não fará validação pelo contrato de câmbio. Só exibirá mensagem de aviso caso não seja chamada de ExecAuto
         If Empty(M->EEQ_NROP) .And. !(Type("lAf500Auto") == "L" .And. lAf500Auto .And. If(EEQ->(FieldPos("EEQ_EVTORI")) > 0,M->EEQ_EVTORI <> "122",.T.) );
         .AND. (EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. M->EEQ_MODAL <> "2") //LRS - 13/10/2016 - Não mostrar a mensagem caso for movimento exterior.
            EasyHelp("Contrato de câmbio não informado.")                         //NCF - 08/10/2015 - Integ. EEC x ESS (Desp./Comiss.)
            If AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116") //THTS - 15/05/2017 - Não permitir liquidar adt fornecedor sem o numero do contrato
                lRet := .F.
            EndIf
         EndIf
      EndIf

   Case cCampo == "EEQ_VLSISC"
      //RRC - 27/11/2013  -Alteração para verificar se o campo EEQ_PROCES está contido no array para identificar que é uma parcela do SIGAESS
      If (nModulo == 85 .Or. IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100")) //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0))
         If !Positivo(M->EEQ_VLSISC)
            EasyHelp("Valor Siscoserv inválido. Considere o valor dos serviços incluídos no processo.")
            lRet := .F.
         EndIf
      EndIf

EndCase
   //RRC - 19/07/2013
   /*Para casos de execauto do SIGAESS para invoices originadas do SIGACOM:
   Cenários em que no mesmo execauto a invoice e as parcelas de câmbio (títulos inicialmente gerados no SIGAFIN) eram incluídas mas ocorria falha na liquidação das parcelas,
   a variável lMSErroAuto não era atualizada mesmo com as mensagens de validação.*/
   If !lRet .And. Type("lAf500Auto") == "L" .And. lAf500Auto .And. Type("lGeraTit") == "L" .And. !lGeraTit .And. Type("lMSErroAuto") == "L" .And. !lMSErroAuto
      lMSErroAuto := !lRet
   EndIf

Return lRet

//***********************************************//
//Função......: AF500Filtro()
//Programador.: Alessandro Alves Ferreira - AAF
//Objetivo....: Manutenção de Câmbio da Exportação sem vinculo com Embarque
//Data........: 30/11/05 - 10:53
//***********************************************//
Function AF500Filtro()
//***********************************************//
Local lOK     := .F.
Local bOK     := {|| lOK:= .T., oDlg:End() }
Local bCancel := {|| lOK:= .F., oDlg:End() }
Local nRadOpc

cFilter := EEQ->( dbFilter() )
If cFilter == "EEQ_FASE == '3'"
   nRadOpc := 1
ElseIf cFilter == "EEQ_FASE == '4'"
   nRadOpc := 2
ElseIf cFilter == "EEQ_FASE == '3' .OR. EEQ_FASE == '4'"
   nRadOpc := 3
EndIf

DEFINE MSDIALOG oDlg TITLE STR0021; //"Filtro por Tipo de Contrato"
FROM 10,10 TO 22,59 OF oMainWnd

oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS - 16/05/2017
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT 

   @ 15,3 RADIO oRadOpc VAR nRadOpc ITEMS STR0022, STR0023, STR0024 SIZE 80,15 OF oPanel PIXEL//"Contrato Tipo 3"###"Contrato Tipo 4"###"Ambos"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel) CENTERED

If lOK
   If nRadOpc == 1
      EEQ->( dbSetFilter( {|| EEQ_FASE == '3'}, "EEQ_FASE == '3'")) //Contrato Tipo 3
   ElseIf nRadOpc == 2
      EEQ->( dbSetFilter( {|| EEQ_FASE == '4'}, "EEQ_FASE == '4'")) //Contrato Tipo 4
   Else
      EEQ->( dbSetFilter( {|| EEQ_FASE == '3' .OR. EEQ_FASE == '4'}, "EEQ_FASE == '3' .OR. EEQ_FASE == '4'")) //Ambos
   EndIf
EndIf

Return .T.

*------------------------------------------------------------*
FUNCTION AF500Estorno()//AWR - 11/04/2006
*------------------------------------------------------------*
Local lTemMarcados   :=.F.
Local cVinculadas    := ""    // PLB 30/05/06
Local cBaixadas      := ""    // PLB 30/05/06
Local cMsg           := ""
Local lRet           := .T.

PROCREGUA(TRB->(EasyReccount("TRB")))

TRB->(DBGOTOP())

lSair := .F.
If(EasyEntryPoint("EECAF500"),ExecBlock("EECAF500",.F.,.F.,"ESTORNO"),)
IF lSair
   RETURN .F.
ENDIF

Begin Transaction

DO WHILE TRB->(!EOF())

   INCPROC(STR0039+TRB->EEQ_PARC) //"Lendo Parcela: "

   IF EMPTY(TRB->WK_MARCA)
      TRB->(DBSKIP())
      LOOP
   ENDIF

   lTemMarcados:=.T.

   EEQ->(DBGOTO(TRB->WK_RECNO))

   If AF200ParcLiq()
      if empty(cbaixadas)
         cbaixadas := STR0117 //"Existe(m) parcela(s) baixada(s) de invoice que não pode(m) ser excluída(s)."
      endif
      cBaixadas += ENTER + STR0118 + EEQ->EEQ_NRINVO + STR0119 + EEQ->EEQ_PARC //"Invoice: " "Parcela: "
      TRB->(DbSkip())
      Loop
   EndIf

   // PLB 23/05/06 - Verifica se parcela esta vinculada
   If lFinanciamento .And. !Empty(EEQ->EEQ_NRINVO) .And. EF3->( DBSeek(cFilEF3+IIF(EEQ->EEQ_TP_CON $ "3","E","I")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC) )  .And.  EF3->EF3_PREEMB==M->EEQ_PREEMB
      if empty(cVinculadas)
         cVinculadas := "Existe(m) parcela(s) de invoice vinculada(s) a contrato de financiamento e não pode(m) ser excluída(s)" //STR0046;
      endif
      cVinculadas += ENTER + STR0118 + EEQ->EEQ_NRINVO + STR0119 + EEQ->EEQ_PARC //"Invoice: " "Parcela: "
      TRB->( DBSkip() )
      Loop
   EndIf

   If !(lRet := AF500Integ(,OPC_EST))
      EasyHelp(STR0096) //"A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
      ELinkRollBackTran()
      Exit
   EndIf

   EEQ->(RecLock("EEQ",.F.))
   EEQ->(dbDelete())
   EEQ->(MsUnLock())

   TRB->(dbDelete())
   TRB->(DBSKIP())

ENDDO

End Transaction

If !lRet
   ELinkClearID()
EndIf

If !lTemMarcados
   EasyHelp(STR0040) //"Nao existe registros Marcados."
   RETURN .F.
EndIF

TRB->( DBGoTop() )

if ! empty(cBaixadas) .or. ! empty(cVinculadas)
   cMsg := iif( !empty(cBaixadas), cBaixadas + ENTER + ENTER, "" ) + cVinculadas
   eecview(cMsg,STR0013)
endif

RETURN .T.


******************************************************************************************
//** PLB 23/05/06 - Funcao para Vinculacao de Parcelas a contrato de Financiamento
******************************************************************************************
Function AF500Vin(cAlias,nRec,nTip)
******************************************************************************************

 Local nPos
 Local lOK      := .F.
 Local nNewEEQ  := 0
 Local nSaldoParcela, nSaldoVincula, nVincular
 Private cMod := ""   // Variavel utilizada no EFFEX400
 Private cTX_100 , cTX_520
 Private aHeader    := {} ,;
         aCampos    := {} ,;
         aSemSX3EEQ := {} ,;
         aAltera    := {} ,;
         aBtnVin    := {} ,;
         oGet       := {} ,;
         bCancel    := {|| lOK:= .F., oDlg2:End()} ,;
         bOK        := {|| lOK:= .T., oDlg2:End()} ,;
         lGrvEvento := .F.

   IF !AF500Valid("EEQ_PREEMB")
      RETURN .F.
   ENDIF

   If nTip # OPC_INC
      If TRB->(EOF() .AND. BOF())
         EasyHelp(STR0041)  //"Nao existem parcelas."
         Return .F.
      EndIf
      If nRec # 0
         EEQ->(DBGOTO(nRec))
      EndIf
   EndIf

   If nTip == OPC_VIN
      /* comentado por wfs
         a função AF200ParcLiq() executa a função EasyVerModal() que passou a tratar movimento no exterior, através do campo de data
         de crédito, bloquando a vincuação da parcela de câmbio tipo 3 ao contrato. Voltada a verificação para o campo de data de liquidação. */
      //If AF200ParcLiq()//AOM - 24/08/2012 - NOPADO - !Empty(EEQ->EEQ_PGT)
      If !Empty(EEQ->EEQ_PGT)
         EasyHelp(STR0050)  //"Parcela nao pode ser vinculada pois ja foi liquidada."
         Return .F.
      ElseIf Empty(EEQ->EEQ_NRINVO)
         EasyHelp(STR0051)  //"Parcela nao pode ser vinculada pois nao possui Numero de invoice."
         Return .F.
      ElseIf Empty(EEQ->EEQ_MOEDA)
         EasyHelp(STR0052)  //"Parcela nao pode ser vinculada pois campo Moeda nao esta preenchido."
         Return .F.
      EndIf
   ElseIf nTip == OPC_EVN
      If !Empty(EEQ->EEQ_PGT) //AF200ParcLiq()//AOM - 24/08/2012 - NOPADO - !Empty(EEQ->EEQ_PGT) wfs
         EasyHelp(STR0053+Chr(13)+Chr(10)+STR0032)//"Vinculacao nao pode ser estornado pois Parcela ja foi liquidada."###"Estorne a Liquidação."
         Return .F.
      Else
         nPos := AScan( aVinculados , { |x| EEQ->EEQ_NRINVO+EEQ->EEQ_PARC==x[2]+x[3] } )
         If nPos == 0
            EasyHelp(STR0054)  //"Nao ha Vinculacao a estornar."
            Return .F.
         //ElseIf !Empty( aVinculados[nPos][15] )
            //EasyHelp("Vinculacao nao pode ser estornada pois Contrato foi encerrado em "+DToC(aVinculados[nPos][15])+".")//"Vinculacao nao pode ser estornada pois Contrato foi encerrado em " #### "."
            //Return .F.
         EndIf
      EndIf
   EndIf

      SX3->( DBSetOrder(2) )
      SX3->( DBSeek("EEQ_VL") )
      aHeader := { { AVSX3("EF2_CONTRA"  ,5),"EF2_CONTRA",AVSX3("EF2_CONTRA",6), AVSX3("EF2_CONTRA",3), AVSX3("EF2_CONTRA",4),"",SX3->X3_USADO, AVSX3("EF2_CONTRA",2),"EF2"    ,SX3->X3_CONTEXT } ,;  // Contrato
                   { AVSX3("EF3_BAN_FI"  ,5),"BANCO"     ,AVSX3("EF3_BAN_FI",6), AVSX3("EF3_BAN_FI",3), AVSX3("EF3_BAN_FI",4),"",SX3->X3_USADO, AVSX3("EF3_BAN_FI",2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Banco
                   { AVSX3("EF3_PRACA"   ,5),"PRACA"     ,AVSX3("EF3_PRACA" ,6), AVSX3("EF3_PRACA" ,3), AVSX3("EF3_PRACA" ,4),"",SX3->X3_USADO, AVSX3("EF3_PRACA" ,2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Praca
                   { AVSX3("EF3_SEQCNT"  ,5),"SEQ_CON"   ,AVSX3("EF3_SEQCNT",6), AVSX3("EF3_SEQCNT",3), AVSX3("EF3_SEQCNT",4),"",SX3->X3_USADO, AVSX3("EF3_SEQCNT",2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Sequencia do Contrato
                   { STR0080         ,"VL_VINC"   ,AVSX3("EEQ_VL"    ,6), AVSX3("EEQ_VL"    ,3), AVSX3("EEQ_VL"    ,4),"",SX3->X3_USADO, AVSX3("EEQ_VL"    ,2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Valor a Vincular //STR0080	"Vl. Vincular"
                   { STR0081          ,"DT_VINC"   ,AVSX3("EEQ_PGT"   ,6), AVSX3("EEQ_PGT"   ,3), AVSX3("EEQ_PGT"   ,4),"",SX3->X3_USADO, AVSX3("EEQ_PGT"   ,2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Data de Vinculacao //STR0081	"Dt. Vincul."
                   { STR0082          ,"VL_PARC"   ,AVSX3("EEQ_VL"    ,6), AVSX3("EEQ_VL"    ,3), AVSX3("EEQ_VL"    ,4),"",SX3->X3_USADO, AVSX3("EEQ_VL"    ,2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Valor da Parcela //STR0082	"Vl. Parcela"
                   { STR0083          ,"TX_VINC"   ,AVSX3("EEQ_TX"    ,6), AVSX3("EEQ_TX"    ,3), AVSX3("EEQ_TX"    ,4),"",SX3->X3_USADO, AVSX3("EEQ_TX"    ,2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Taxa de Vinculacao //STR0083	"Tx. Vincul."
                   { EX401STR(164)    ,"TX_CONTR"  ,AVSX3("EF3_TX_MOE",6), AVSX3("EF3_TX_MOE",3), AVSX3("EF3_TX_MOE",4),"",SX3->X3_USADO, AVSX3("EF3_TX_MOE",2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // LRS - 21/02/2018
                   { STR0084           ,"MOE_NEG"   ,AVSX3("EEQ_MOEDA" ,6), AVSX3("EEQ_MOEDA" ,3), AVSX3("EEQ_MOEDA" ,4),"",SX3->X3_USADO, AVSX3("EEQ_MOEDA" ,2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Moeda Negociada //STR0084	"Moeda Neg."
                   { STR0085            ,"DT_VENC"   ,AVSX3("EEQ_PGT"   ,6), AVSX3("EEQ_PGT"   ,3), AVSX3("EEQ_PGT"   ,4),"",SX3->X3_USADO, AVSX3("EEQ_PGT"   ,2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Data de Vencimento//	STR0085	"Dt. Vcto."
	                   { STR0086           ,"DT_RECEB"  ,AVSX3("EEQ_PGT"   ,6), AVSX3("EEQ_PGT"   ,3), AVSX3("EEQ_PGT"   ,4),"",SX3->X3_USADO, AVSX3("EEQ_PGT"   ,2),"WorkEEQ",SX3->X3_CONTEXT } ,;  // Data de Recebimento //STR0086	"Dt. Receb."
                   { AVSX3("EF6_TP_VIN"  ,5),"TP_VINC"   ,AVSX3("EF6_TP_VIN",6), AVSX3("EF6_TP_VIN",3), AVSX3("EF6_TP_VIN",4),"",SX3->X3_USADO, AVSX3("EF6_TP_VIN",2),"WorkEEQ",SX3->X3_CONTEXT }   } // Tipo de Vinculacao
                  
      SX3->( DBSetOrder(1) )

      aSemSX3EEQ := { { "EF2_CONTRA",AVSX3("EF2_CONTRA",2) , AVSX3("EF2_CONTRA",3) , AVSX3("EF2_CONTRA",4) } ,;
                      { "BANCO"     ,AVSX3("EF3_BAN_FI",2) , AVSX3("EF3_BAN_FI",3) , AVSX3("EF3_BAN_FI",4) } ,;
                      { "PRACA"     ,AVSX3("EF3_PRACA" ,2) , AVSX3("EF3_PRACA" ,3) , AVSX3("EF3_PRACA" ,4) } ,;
                      { "SEQ_CON"   ,AVSX3("EF3_SEQCNT",2) , AVSX3("EF3_SEQCNT",3) , AVSX3("EF3_SEQCNT",4) } ,;
                      { "VL_VINC"   ,AVSX3("EEQ_VL"    ,2) , AVSX3("EEQ_VL"    ,3) , AVSX3("EEQ_VL"    ,4) } ,;
                      { "DT_VINC"   ,AVSX3("EEQ_PGT"   ,2) , AVSX3("EEQ_PGT"   ,3) , AVSX3("EEQ_PGT"   ,4) } ,;
                      { "VL_PARC"   ,AVSX3("EEQ_VL"    ,2) , AVSX3("EEQ_VL"    ,3) , AVSX3("EEQ_VL"    ,4) } ,;
                      { "TX_VINC"   ,AVSX3("EEQ_TX"    ,2) , AVSX3("EEQ_TX"    ,3) , AVSX3("EEQ_TX"    ,4) } ,;
                      { "TX_CONTR"  ,AVSX3("EF3_TX_MOE",2) , AVSX3("EF3_TX_MOE",3) , AVSX3("EF3_TX_MOE",4) } ,;
                      { "MOE_NEG"   ,AVSX3("EEQ_MOEDA" ,2) , AVSX3("EEQ_MOEDA" ,3) , AVSX3("EEQ_MOEDA" ,4) } ,;
                      { "DT_VENC"   ,AVSX3("EEQ_PGT"   ,2) , AVSX3("EEQ_PGT"   ,3) , AVSX3("EEQ_PGT"   ,4) } ,;
                      { "DT_RECEB"  ,AVSX3("EEQ_PGT"   ,2) , AVSX3("EEQ_PGT"   ,3) , AVSX3("EEQ_PGT"   ,4) } ,;
                      { "TP_VINC"   ,AVSX3("EF6_TP_VIN",2) , 11                    , 0                     } ,;
                      { "JA_VINC"   ,"L"                   , 1                     , 0                     }   }

      If EasyEntryPoint("EECAF500")
         ExecBlock("EECAF500",.F.,.F.,"AF500VINC_WorkEEQ")
      endif      
      cWKFileName := E_CRIATRAB(,aSemSX3EEQ,"WorkEEQ")
      RecLock("WorkEEQ",.T.)
      WorkEEQ->VL_VINC   := EEQ->EEQ_VL
      WorkEEQ->DT_VINC   := dDataBase
      WorkEEQ->VL_PARC   := EEQ->EEQ_VL
      WorkEEQ->TX_VINC   := BuscaTaxa(EEQ->EEQ_MOEDA,dDataBase,,.F.,.T.,,)
      WorkEEQ->MOE_NEG   := EEQ->EEQ_MOEDA
      WorkEEQ->DT_VENC   := EEQ->EEQ_VCT
      WorkEEQ->DT_RECEB  := EEQ->EEQ_DTNEGO
      WorkEEQ->TX_CONTR  := WorkEEQ->TX_VINC
      nPos := AScan( aVinculados , { |x| EEQ->EEQ_NRINVO+EEQ->EEQ_PARC==x[2]+x[3] } )
      If nPos > 0
         WorkEEQ->EF2_CONTRA  := aVinculados[nPos][6]
         WorkEEQ->BANCO       := aVinculados[nPos][7]
         WorkEEQ->PRACA       := aVinculados[nPos][8]
         WorkEEQ->SEQ_CON     := aVinculados[nPos][9]
         WorkEEQ->TX_VINC     := aVinculados[nPos][17]
         WorkEEQ->DT_VINC     := aVinculados[nPos][13]
         WorkEEQ->TP_VINC     := aVinculados[nPos][14]+"-"+BSCXBOX("EF6_TP_VIN",aVinculados[nPos][14])
         WorkEEQ->TX_CONTR    := aVinculados[nPos][12] //LRS - 23/02/2018
         WorkEEQ->VL_PARC     := aVinculados[nPos][18] //LRS - 23/02/2018
         WorkEEQ->VL_VINC     := aVinculados[nPos][11] //LRS - 23/02/2018
         WorkEEQ->JA_VINC     := .T.
      Else
         WorkEEQ->JA_VINC     := .F.
         WorkEEQ->TP_VINC     := "1-"+BSCXBOX("EF6_TP_VIN","1")
      EndIf
      WorkEEQ->( MSUnlock() )

      If nTip == OPC_VIN
         cTitle  := STR0044  //"Vinculacao"
         aAltera := { "EF2_CONTRA", "BANCO", "PRACA", "SEQ_CON", "VL_VINC", "DT_VINC", "TX_VINC"}
      ElseIf nTip == OPC_EVN
         cTitle  := STR0070 //"Estornar Vinculação"
         aAltera := {}
      EndIf

      If EasyEntryPoint("EECAF500")
         ExecBlock("EECAF500",.F.,.F.,"AF500VINC")
      endif
      
      cMod := If(nModulo == 85,cMod,If(TRB->EEQ_TP_CON $ "13","E",If(TRB->EEQ_TP_CON $ "24","I","")))   // GFP - 18/06/2015
      DEFINE MSDIALOG oDlg2 TITLE cTitle FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
                            TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

         WorkEEQ->(oGet:=MsGetDb():New(15,1,(oDlg2:nClientHeight-4)/2,(oDlg2:nClientWidth-4)/2,4,,,,;
                                       .T.,aAltera,,.F.,,"WorkEEQ","AF500ValVinc()",.T.))
         oGet:lCondicional := .T.
         oGet:oBrowse:bwhen:={||(dbSelectArea("WorkEEQ"),.t.)}
         oGet:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
         oGet:oBrowse:Refresh()
         oGet:oBROWSE:Badd := {||.F.}
      ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{|| IIF(nTip == OPC_VIN,IIF(AF500ValVinc("All"),Eval(bOk),),Eval(bOk)) },bCancel,,aBtns)

      If lOK

         If nTip == OPC_EVN
            If MsgYesNo(STR0055)  // "Confirma o Estorno da Vinculacao?"
               AF500EstVin(OPC_EVN)
            EndIf

         ElseIf nTip == OPC_VIN
            If nDesvinculado > 0
               AF500EstVin(OPC_VIN)
            EndIf

          Begin TransAction

            If lGrvEvento  .And.  !WorkEEQ->JA_VINC
               EF1->(DbSeek(xFilial("EF1")+IIF(EEQ->EEQ_TP_CON$"3","E","I")+WorkEEQ->EF2_CONTRA+WorkEEQ->BANCO+WorkEEQ->PRACA+WorkEEQ->SEQ_CON) )
               EC6->( DBSetOrder(1) )
               EC6->(DbSeek(xFilial("EC6")+"FIEX"+EF1->EF1_TP_FIN+'520' ))
               cTX_100 := EC6->EC6_TXCV
               cTX_520 := EC6->EC6_TXCV
               cMod  := EF1->EF1_TPMODU
               cTipo := EF1->EF1_TP_FIN
               nSaldoParcela := WorkEEQ->VL_PARC
               nSaldoVincula := WorkEEQ->VL_VINC
               nVincular     := 0

               Do While nSaldoVincula > 0

                  If EEQ->EEQ_TP_CON $ "3"  .And.  EF1->EF1_CAMTRA == "1"
                     nVincular     := 0
                     EF3->( DBSetOrder(1) )
                     EF3->( DBSeek(cFilEF3+"E"+WorkEEQ->EF2_CONTRA+WorkEEQ->BANCO+WorkEEQ->PRACA+WorkEEQ->SEQ_CON+IIF(Left(WorkEEQ->TP_VINC,1)=="1",EV_PRINC_PREPAG,EV_JUROS_PREPAG)) )
                     Do While !EF3->( EoF() )  .And.  nVincular==0  ;
                              .And.  WorkEEQ->EF2_CONTRA+WorkEEQ->BANCO+WorkEEQ->PRACA+WorkEEQ->SEQ_CON+IIF(Left(WorkEEQ->TP_VINC,1)=="1",EV_PRINC_PREPAG,EV_JUROS_PREPAG)==EF3->( EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE )
                        If EF3->EF3_SLDVIN > 0
                           If EF3->EF3_SLDVIN > nSaldoVincula   // Se o saldo a vincular do EF3 for maior que o valor a vincular,
                              nVincular := nSaldoVincula        // vincula apenas o restante do valor
                           Else
                              nVincular := EF3->EF3_SLDVIN      // caso contrario vincula a parcela inteira do EF3
                           EndIf
                        Else
                           EF3->( DBSkip() )
                           Loop
                        EndIf
                     EndDo
                  Else
                     nSaldoVincula := 0
                     nSaldoParcela := WorkEEQ->VL_PARC
                     nVincular     := WorkEEQ->VL_VINC
                  EndIf


                  EX400GrvEventos(WorkEEQ->EF2_CONTRA,EEQ->EEQ_NRINVO,EEQ->EEQ_PREEMB,nVincular,dDataBase,;
                                  EEQ->EEQ_MOEDA,EEQ->EEQ_PARC,EF1->EF1_MOEDA,"EF1","EF3","CAMB",,WorkEEQ->TX_VINC,;
                                  WorkEEQ->DT_VINC,EEQ->EEQ_FILIAL,WorkEEQ->BANCO,;
                                  WorkEEQ->PRACA,Left(WorkEEQ->TP_VINC,1),IIF(EEQ->EEQ_TP_CON$"3","E","I"),WorkEEQ->SEQ_CON,,,,,WorkEEQ->TX_CONTR)

                  EF3->( DBSetOrder(3) )
                  EF3->( DBSeek(cFilEF3+IIF(EEQ->EEQ_TP_CON$"3","E","I")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_EMBARQUE) )
                  AAdd( aVinculados , Array(18) )
                  aVinculados[Len(aVinculados)][1]  := EEQ->EEQ_PREEMB   // Processo
                  aVinculados[Len(aVinculados)][2]  := EEQ->EEQ_NRINVO   // Invoice
                  aVinculados[Len(aVinculados)][3]  := EEQ->EEQ_PARC     // Parcela
                  aVinculados[Len(aVinculados)][4]  := EEQ->EEQ_TP_CON   // Tipo do Contrato
                  aVinculados[Len(aVinculados)][5]  := EF3->EF3_TPMODU   // Tipo do Modulo
                  aVinculados[Len(aVinculados)][6]  := EF3->EF3_CONTRA   // Numero do Contrato
                  aVinculados[Len(aVinculados)][7]  := EF3->EF3_BAN_FI   // Banco
                  aVinculados[Len(aVinculados)][8]  := EF3->EF3_PRACA    // Praca
                  aVinculados[Len(aVinculados)][9]  := EF3->EF3_SEQCNT   // Sequencia do Contrato
                  aVinculados[Len(aVinculados)][10] := EF3->EF3_SEQ      // Sequencia dos Eventos
                  aVinculados[Len(aVinculados)][11] := EF3->EF3_VL_MOE   // Valor na Moeda
                  aVinculados[Len(aVinculados)][12] := EF3->EF3_TX_MOE   // Taxa na Moeda
                  aVinculados[Len(aVinculados)][13] := EF3->EF3_DT_EVE   // Data do Evento
                  aVinculados[Len(aVinculados)][14] := IIF(Left(EF3->EF3_EV_VIN,2)==Left(EV_JUROS_PREPAG,2),"2","1")   // Tipo de Vinculacao
                  aVinculados[Len(aVinculados)][15] := Posicione("EF1",1,cFilEF1+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT,"EF1_DT_ENC")
                  aVinculados[Len(aVinculados)][16] := EF3->( RecNo() )  // RecNo do Evento de Vinculacao (600)
                  aVinculados[Len(aVinculados)][17] := EF3->EF3_TX_CON //LRS - 23/02/2018
                  aVinculados[Len(aVinculados)][18] := EF3->EF3_VL_INV //LRS - 23/02/2018

                  If EEQ->EEQ_TP_CON $ "3"  .And.  EF1->EF1_CAMTRA == "1"
                     If nVincular < nSaldoVincula
                        Processa( {|| nNewEEQ := AF500QuebraInv(nSaldoParcela,nVincular) } , STR0072 )  //"Quebrando Parcela do Cambio..."
                        EEQ->( DBGoTo(nNewEEQ) )
                        nSaldoParcela := nSaldoParcela - nVincular
                     EndIf
                     nSaldoVincula := nSaldoVincula - nVincular
                  EndIf

               EndDo

            EndIf
            If WorkEEQ->VL_VINC < WorkEEQ->VL_PARC
               Processa( {|| nNewEEQ := AF500QuebraInv(nSaldoParcela,nVincular) } , STR0072 )  //"Quebrando Parcela do Cambio..."
            Else
               EF3->( DBSeek(cFilEF3+IIF(EEQ->EEQ_TP_CON$"3","E","I")+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EV_EMBARQUE) )
               RecLock("EEQ",.F.)
               EEQ->EEQ_FI_TOT := "S"
               EEQ->EEQ_VL_PAR := 0
               EEQ->EEQ_NROP   := WorkEEQ->EF2_CONTRA
               EEQ->EEQ_BANC   := EF3->EF3_BAN_FI
               EEQ->EEQ_AGEN   := EF3->EF3_AGENFI
               EEQ->EEQ_NCON   := EF3->EF3_NCONFI
               EEQ->EEQ_NOMEBC := Posicione("SA6",1,xFilial("SA6")+EF3->EF3_BAN_FI+EF3->EF3_AGENFI+EF3->EF3_NCONFI,"A6_NOME")               
               EEQ->( MSUnLock() )
               If EasyEntryPoint("EECAF500")
                  ExecBlock("EECAF500",.F.,.F.,"AF500VINC_GRAVA_EEQ")
               Endif
            EndIf

          End TransAction

         EndIf

   EndIf

      lGrvEvento := .F.
      WorkEEQ->( E_ERASEARQ(cWKFileName) )

   DBSelectArea(cAlias)

Return .T.


******************************************************************************************
//** PLB 23/05/06 - Funcao para Estorno da Vinculacao de Parcelas a contrato de Financiamento
******************************************************************************************
Function AF500EstVin(nCall)
******************************************************************************************

 Local nOrdEF3 := 0

   nOrdEF3 := EF3->( IndexOrd() )
   EF3->( dbSetOrder(4) )

Begin TransAction
   If nCall == OPC_VIN
      EF3->( DBGoTo(nDesvinculado) )
      cTpModu := EF3->EF3_TPMODU
      cCont   := EF3->EF3_CONTRA
      cBanc   := EF3->EF3_BAN_FI
      cPrac   := EF3->EF3_PRACA
      cSeqCon := EF3->EF3_SEQCNT
      cSeq    := EF3->EF3_SEQ
      nPos := AScan( aVinculados , { |x| x[16] == nDesvinculado } )
      nDesvinculado := 0
   ElseIf nCall == OPC_EVN
      nPos := AScan( aVinculados , { |x| x[2]==TRB->EEQ_NRINVO  .And.  x[3]==TRB->EEQ_PARC } )
      cTpModu := aVinculados[nPos][5]
      cCont   := aVinculados[nPos][6]
      cBanc   := aVinculados[nPos][7]
      cPrac   := aVinculados[nPos][8]
      cSeqCon := aVinculados[nPos][9]
      cSeq    := aVinculados[nPos][10]
   EndIf
   ADel(  aVinculados , nPos )
   ASize( aVinculados , Len(aVinculados)-1 )

   EF1->( DBSeek(xFilial("EF1")+cTpModu+cCont+cBanc+cPrac+cSeqCon) )

   Reclock("EEQ",.F.)
   EEQ->EEQ_FI_TOT := " "
   EEQ->EEQ_NROP   := Space(Len(EEQ->EEQ_NROP))
   EEQ->( MSUnLock() )
   cMod := EF1->EF1_TPMODU
   EF3->( DBSeek(cFilEF3+cTpModu+cCont+cBanc+cPrac+cSeqCon+cSeq) )
   Do While !EF3->( EoF() )  .And.  EF3->EF3_FILIAL==cFilEF3  ;
            .And.  EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT==cTpModu+cCont+cBanc+cPrac+cSeqCon  ;
            .And.  EF3->EF3_SEQ == cSeq

      EX400AtuSaldos("VIN",,,"EEC")
      If EF3->EF3_CODEVE == EV_EMBARQUE
         EX400MotHis("VIN",EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_TP_FIN,EF3->EF3_PREEMB,EF3->EF3_INVOIC,EF3->EF3_PARC,EF3->EF3_CODEVE,EF3->EF3_SEQ,cTpModu,EF1->EF1_SEQCNT)
      EndIf

      RecLock("EF3",.F.)
      If !Empty(EF3->EF3_NR_CON)
         EF3->EF3_EV_EST := EF3->EF3_CODEVE
         EF3->EF3_DT_EST := dDataBase
         EF3->EF3_CODEVE := EV_ESTORNO
         EF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
      Else
         EF3->( DBDelete() )
      EndIf
      EF3->( MSUnLock() )
      EF3->( DBSkip() )
   EndDo

End TransAction

   EF3->( DBSetOrder(nOrdEF3) )

Return .T.


******************************************************************************************
// PLB 25/05/06 - Funcao de Validacao da MSGetDB de Vinculacao
******************************************************************************************
Function AF500ValVinc(cCampo)
******************************************************************************************

 Local lRet      :=  .T. ,;
       nPos      :=  0   ,;
       nPos2     :=  0   ,;
       nSaldoCnt := 0    ,;
       nDel := 0  //LRS - 22/02/2018

 Private lAltTpVin := .F.


   If ValType(cCampo) == "U"
      cCampo := SubStr(ReadVar(),4)
   EndIf
   cCampo := Upper(cCampo)
   EF1->( DBSetOrder(1) )

   Begin Sequence

      Do Case

         Case cCampo == "EF2_CONTRA"
            If Empty(M->EF2_CONTRA)
               EasyHelp(STR0056)  //"Preencha o numero do contrato."
               lRet := .F.
               Break
            EndIf
            //If //WorkEEQ->EF2_CONTRA <> M->EF2_CONTRA  .And.  ;
               //!Empty(WorkEEQ->EF2_CONTRA)  .And.  !Empty(WorkEEQ->BANCO)    .And.  ;
               //!Empty(WorkEEQ->PRACA)       .And.  !Empty(WorkEEQ->SEQ_CON)  .And.  ;
               //EF1->( DBSeek(xFilial("EF1")+IIF(EEQ->EEQ_TP_CON$"3","E","I")+WorkEEQ->EF2_CONTRA+WorkEEQ->BANCO+WorkEEQ->PRACA+WorkEEQ->SEQ_CON) )  .And.  ;
               //!Empty(EF1->EF1_DT_ENC)
                  //EasyHelp("Parcela nao pode ser desvinculada pois o contrato ja foi encerrado.")
                  //lRet := .F.
                  //Break
            //EndIf
            If !EF1->( DBSeek(xFilial("EF1")+IIF(EEQ->EEQ_TP_CON$"3","E","I")+M->EF2_CONTRA) )
               Help("",1,"REGNOIS")
               lRet := .F.
               Break
            ElseIf !Empty(EF1->EF1_DT_ENC)
               EasyHelp(STR0057)  //"Nao e possivel vincular a invoice, pois o contrato ja foi encerrado."
               lRet := .F.
               Break
            ElseIf EEQ->EEQ_TP_CON $ "3"  .And.  Empty(EF1->EF1_DT_JUR)
               EasyHelp(STR0058)  //"Nao e possivel vincular a invoice, pois a data de inicio do juros nao esta preenchida no contrato."
               lRet := .F.
               Break
            ElseIf EEQ->EEQ_TP_CON $ "4"  .And.  !Empty(EF1->EF1_DT_JUR)
               EasyHelp(STR0059)  //"Nao e possível vincular a invoice, pois a data de inicio do juros ja esta preenchida no contrato."
               lRet := .F.
               Break
            ElseIf WorkEEQ->DT_VENC  >  EF1->EF1_DT_VEN
               EasyHelp(AllTrim(STR0048)+" "+AllTrim(EEQ->EEQ_NRINVO)+" "+STR0049+" "+Alltrim(EEQ->EEQ_PARC)+STR0060)   // "Invoice " ## " Parcela " ## " possui data de vencimento maior que a data limite para vinculacao."
               lRet := .F.
               Break
            Else
               If EEQ->EEQ_TP_CON $ "3"  .And.  EF1->EF1_CAMTRA == "1"
                  AF500ParPgt()
               Else
                  WorkEEQ->TP_VINC := "1-"+BSCXBOX("EF6_TP_VIN","1")
               EndIf
               // Verifica se ha alteracao nos dados do contrato
               If lAltTpVin  .Or.  WorkEEQ->EF2_CONTRA+WorkEEQ->BANCO+WorkEEQ->PRACA+WorkEEQ->SEQ_CON  <>  M->EF2_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT
                  // Verifica se parcela ja esta vinculada
                  If WorkEEQ->JA_VINC
                     nPos  := AScan( aVinculados , { |x| EEQ->EEQ_NRINVO+EEQ->EEQ_PARC==x[2]+x[3] } )
                     // Verifica se nao esta no array de Desvinculados
                     If nDesvinculado != aVinculados[nPos][16]
                        nDesvinculado := aVinculados[nPos][16]  // RecNo do Evento de Financiamento em EF3
                        WorkEEQ->JA_VINC := .F.
                     EndIf
                  Else
                     nPos := AScan( aVinculados , { |x|  EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT == x[2]+x[3]+x[6]+x[7]+x[8]+x[9]  .And.  x[14] $ WorkEEQ->TP_VINC } )
                     // Verifica se esta no array de Vinculados
                     If nPos > 0
                        //Verifica se esta no array de Desvinculados
                        If nDesvinculado == aVinculados[nPos][16]
                           //Deleta do array de Desvinculados
                           nDesvinculado := 0
                           WorkEEQ->JA_VINC := .T.
                        EndIf
                     EndIf
                  EndIf
               EndIf
               WorkEEQ->BANCO   := EF1->EF1_BAN_FI
               WorkEEQ->PRACA   := EF1->EF1_PRACA
               WorkEEQ->SEQ_CON := EF1->EF1_SEQCNT
               WorkEEQ->DT_VINC := dDataBase
               IF WorkEEQ->MOE_NEG <> EF1->EF1_MOEDA
                  AADD(oGet:aAlter,"TX_CONTR")  
               Else
                  IF(nDel := aScan(oGet:aAlter,"TX_CONTR") > 0,aDel(oGet:Alter,nDel),)
               EndIF
               IF EF1->EF1_TP_FIN == "05" .AND. WorkEEQ->MOE_NEG == EF1->EF1_MOEDA //LRS - 21/02/2018
                  WorkEEQ->TX_VINC := EF1->EF1_TX_MOE  
               EndIF
               WorkEEQ->TX_CONTR:= EF1->EF1_TX_MOE
               lAltTpVin   := .F.
               lGrvEvento := .T.
            EndIf

         Case cCampo == "BANCO"
            If Empty(M->BANCO)
               WorkEEQ->PRACA   := Space( Len(WorkEEQ->PRACA)   )
               WorkEEQ->SEQ_CON := Space( Len(WorkEEQ->SEQ_CON) )
            ElseIf Empty(WorkEEQ->EF2_CONTRA)
               EasyHelp(STR0061)  //"O campo contrato deve ser digitado primeiro."
               lRet := .F.
               Break
            ElseIf !EF1->( DBSeek(xFilial("EF1")+IIF(EEQ->EEQ_TP_CON$"3","E","I")+WorkEEQ->EF2_CONTRA+M->BANCO) )
               Help("",1,"REGNOIS")
               lRet := .F.
               Break
            Else
               // Verifica se ha alteracao nos dados do contrato
               If WorkEEQ->BANCO+WorkEEQ->PRACA+WorkEEQ->SEQ_CON  <>  M->BANCO+EF1->EF1_PRACA+EF1->EF1_SEQCNT
                  // Verifica se parcela ja esta vinculada
                  If WorkEEQ->JA_VINC
                     nPos  := AScan( aVinculados , { |x| EEQ->EEQ_NRINVO+EEQ->EEQ_PARC==x[2]+x[3] } )
                     // Verifica se nao esta no array de Desvinculados
                     If nDesvinculado != aVinculados[nPos][16]
                        nDesvinculado := aVinculados[nPos][16]  // RecNo do Evento de Financiamento em EF3
                        WorkEEQ->JA_VINC := .F.
                     EndIf
                  Else
                     nPos  := AScan( aVinculados , { |x|  EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT == x[2]+x[3]+x[6]+x[7]+x[8]+x[9] } )
                     // Verifica se esta no array de Vinculados
                     If nPos > 0
                        //Verifica se esta no array de Desvinculados
                        If nDesvinculado == aVinculados[nPos][16]
                           //Deleta do array de Desvinculados
                           nDesvinculado := 0
                           WorkEEQ->JA_VINC := .T.
                        EndIf
                     EndIf
                  EndIf
               EndIf
               WorkEEQ->PRACA   := EF1->EF1_PRACA
               WorkEEQ->SEQ_CON := EF1->EF1_SEQCNT
               WorkEEQ->DT_VINC := dDataBase
               lGrvEvento := .T.
            EndIf

         Case cCampo == "PRACA"
            If Empty(M->PRACA)
               WorkEEQ->SEQ_CON := Space( Len(WorkEEQ->SEQ_CON) )
            ElseIf Empty(WorkEEQ->EF2_CONTRA)
               EasyHelp(STR0061)  //"O campo contrato deve ser digitado primeiro."
               lRet := .F.
               Break
            ElseIf Empty(WorkEEQ->BANCO)
               EasyHelp(STR0062)  //"O campo banco deve ser digitado primeiro."
               lRet := .F.
               Break
            ElseIf !EF1->( DBSeek(xFilial("EF1")+IIF(EEQ->EEQ_TP_CON$"3","E","I")+WorkEEQ->EF2_CONTRA+WorkEEQ->BANCO+M->PRACA) )
               WorkEEQ->SEQ_CON := Space( Len(WorkEEQ->SEQ_CON) )
               Help("",1,"REGNOIS")
               lRet := .F.
               Break
            Else
               // Verifica se ha alteracao nos dados do contrato
               If WorkEEQ->PRACA+WorkEEQ->SEQ_CON  <>  M->PRACA+EF1->EF1_SEQCNT
                  // Verifica se parcela ja esta vinculada
                  If WorkEEQ->JA_VINC
                     nPos  := AScan( aVinculados , { |x| EEQ->EEQ_NRINVO+EEQ->EEQ_PARC==x[2]+x[3] } )
                     // Verifica se nao esta no array de Desvinculados
                     If nDesvinculado != aVinculados[nPos][16]
                        nDesvinculado := aVinculados[nPos][16]  // RecNo do Evento de Financiamento em EF3
                        WorkEEQ->JA_VINC := .F.
                     EndIf
                  Else
                     nPos  := AScan( aVinculados , { |x|  EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT == x[2]+x[3]+x[6]+x[7]+x[8]+x[9] } )
                     // Verifica se esta no array de Vinculados
                     If nPos > 0
                        //Verifica se esta no array de Desvinculados
                        If nDesvinculado == aVinculados[nPos][16]
                           //Deleta do array de Desvinculados
                           nDesvinculado := 0
                           WorkEEQ->JA_VINC := .T.
                        EndIf
                     EndIf
                  EndIf
               EndIf
               WorkEEQ->SEQ_CON := EF1->EF1_SEQCNT
               WorkEEQ->DT_VINC := dDataBase
               lGrvEvento := .T.
            EndIf

         Case cCampo == "SEQ_CON"
            If !Empty(M->SEQ_CON)
               If Empty(WorkEEQ->EF2_CONTRA)
                  EasyHelp(STR0061)  //"O campo contrato deve ser digitado primeiro."
                  lRet := .F.
                  Break
               ElseIf Empty(WorkEEQ->BANCO)
                  EasyHelp(STR0062)  //"O campo banco deve ser digitado primeiro."
                  lRet := .F.
                  Break
               ElseIf Empty(WorkEEQ->PRACA)
                  EasyHelp(STR0063)  //"O campo praca deve ser digitado primeiro."
                  lRet := .F.
                  Break
               ElseIf !EF1->( DBSeek(xFilial("EF1")+IIF(EEQ->EEQ_TP_CON$"3","E","I")+WorkEEQ->EF2_CONTRA+WorkEEQ->BANCO+WorkEEQ->PRACA+M->SEQ_CON) )
                  Help("",1,"REGNOIS")
                  lRet := .F.
                  Break
               EndIf

               // Verifica se ha alteracao nos dados do contrato
               If WorkEEQ->SEQ_CON  <>  EF1->EF1_SEQCNT
                  // Verifica se parcela ja esta vinculada
                  If WorkEEQ->JA_VINC
                     nPos  := AScan( aVinculados , { |x| EEQ->EEQ_NRINVO+EEQ->EEQ_PARC==x[2]+x[3] } )
                     // Verifica se nao esta no array de Desvinculados
                     If nDesvinculado != aVinculados[nPos][16]
                        nDesvinculado := aVinculados[nPos][16]  // RecNo do Evento de Financiamento em EF3
                        WorkEEQ->JA_VINC := .F.
                     EndIf
                  Else
                     nPos  := AScan( aVinculados , { |x|  EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT == x[2]+x[3]+x[6]+x[7]+x[8]+x[9] } )
                     // Verifica se esta no array de Vinculados
                     If nPos > 0
                        //Verifica se esta no array de Desvinculados
                        If nDesvinculado == aVinculados[nPos][16]
                           //Deleta do array de Desvinculados
                           nDesvinculado := 0
                           WorkEEQ->JA_VINC := .T.
                        EndIf
                     EndIf
                  EndIf
               EndIf
               WorkEEQ->DT_VINC := dDataBase
               lGrvEvento := .T.
            EndIf

         Case cCampo == "VL_VINC"
            If Empty(WorkEEQ->EF2_CONTRA)  .Or.  Empty(WorkEEQ->BANCO)  .Or.  ;
               Empty(WorkEEQ->PRACA)       .Or.  Empty(WorkEEQ->SEQ_CON)
                  EasyHelp(STR0064)  //"Preencha todos os campos do contrato primeiro."
                  lRet := .F.
                  Break
            ElseIf !(M->VL_VINC > 0)
               Help(" ",1,"AVG0005232") //EasyHelp("Valor deve ser maior que zero.")
               lRet := .F.
               Break
            ElseIf M->VL_VINC > WorkEEQ->VL_PARC
               Help(" ",1,"AVG0005233") //EasyHelp("Valor maior que o saldo da parcela.")
               lRet := .F.
               Break
            Else
               EF1->( DBSeek(xFilial("EF1")+IIF(EEQ->EEQ_TP_CON$"3","E","I")+WorkEEQ->EF2_CONTRA+WorkEEQ->BANCO+WorkEEQ->PRACA+WorkEEQ->SEQ_CON) )
               If EF1->EF1_CAMTRA == "1"
                  nSaldoCnt := AF500SldPar(SubStr(WorkEEQ->TP_VINC,3))
               Else
                  If EF1->EF1_TP_FIN == ACE
                     nSaldoCnt := EF1->EF1_SL2_PM
                  Else
                     nSaldoCnt := EF1->EF1_SLD_PM
                  EndIf
               EndIf
               If M->VL_VINC > nSaldoCnt
                  EasyHelp(STR0065+AllTrim(Transform(nSaldoCnt,AVSX3("EEQ_VL",6)))+").")  //"O Valor a Vincular e maior que o Saldo do Contrato (R$ "
                  If  TRB->EEQ_TP_CON $ "4"  // Remessa
                     If MsgYesNo(STR0066+AllTrim(Str(EF1->EF1_VL_MOE+M->VL_VINC-nSaldoCnt))+"?")  //"Deseja aumentar o valor do Contrato para R$ "
                        RecLock("EF1",.F.)
                        EF1->EF1_VL_MOE := M->VL_VINC - nSaldoCnt
                        EF1->EF1_SLD_PM := M->VL_VINC - nSaldoCnt
                        EF1->( MSUnLock() )
                     Else
                        lRet := .F.
                        Break
                     EndIf
                  Else
                     lRet := .F.
                     Break
                  EndIf
               EndIf
               If M->VL_VINC <> WorkEEQ->VL_VINC
                  // Verifica se parcela ja esta vinculada
                  If WorkEEQ->JA_VINC
                     nPos  := AScan( aVinculados , { |x| EEQ->EEQ_NRINVO+EEQ->EEQ_PARC==x[2]+x[3] .And. WorkEEQ->VL_VINC==x[11] } )
                     // Verifica se nao esta no array de Desvinculados
                     If nDesvinculado != aVinculados[nPos][16]
                        nDesvinculado := aVinculados[nPos][16]  // RecNo do Evento de Financiamento em EF3
                        WorkEEQ->JA_VINC := .F.
                     EndIf
                  Else
                     nPos  := AScan( aVinculados , { |x|  EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT == x[2]+x[3]+x[6]+x[7]+x[8]+x[9] .And. M->VL_VINC==x[11] } )
                     // Verifica se esta no array de Vinculados
                     If nPos > 0
                        //Verifica se esta no array de Desvinculados
                        If nDesvinculado == aVinculados[nPos][16]
                           //Deleta do array de Desvinculados
                           nDesvinculado := 0
                           WorkEEQ->JA_VINC := .T.
                        EndIf
                     EndIf
                  EndIf
                  lGrvEvento := .T.
                  //WorkEEQ->VL_PARC := (WorkEEQ->TX_VINC * M->VL_VINC) / WorkEEQ->TX_CONTR //LRS - 23/02/2018
               EndIf
            EndIf

         Case cCampo == "DT_VINC"
            If WorkEEQ->JA_VINC
               EasyHelp(STR0067)  //"A Invoice ja esta vinculada a este Contrato. Para alterar a Data ou a Taxa estorne e vincule novamente."
               lRet := .F.
               Break
            ElseIf M->DT_VINC > dDataBase
               EasyHelp(STR0068)  //"A Data de Vinculacao nao pode ser maior que a data corrente do sistema."
               lRet := .F.
               Break
            EndIf
            If M->DT_VINC <> WorkEEQ->DT_VINC
               lGrvEvento := .T.
            EndIf

         Case cCampo == "TX_VINC"
            If WorkEEQ->JA_VINC
               EasyHelp(STR0067)  //"A Invoice ja esta vinculada a este Contrato. Para alterar a Data ou a Taxa estorne e vincule novamente."
               lRet := .F.
               Break
            ElseIf !(M->TX_VINC > 0)
               Help(" ",1,"AVG0005232") //EasyHelp("Valor deve ser maior que zero.")
               lRet := .F.
               Break
            EndIf
            If M->TX_VINC <> WorkEEQ->TX_VINC
               lGrvEvento := .T.
               WorkEEQ->VL_PARC := (M->TX_VINC * WorkEEQ->VL_VINC) / WorkEEQ->TX_CONTR //LRS - 23/02/2018
               IF WorkEEQ->MOE_NEG == EF1->EF1_MOEDA
                  WorkEEQ->TX_CONTR := M->TX_VINC
               ENDIF
            EndIf

         Case cCampo == "ALL"
            If Empty(WorkEEQ->EF2_CONTRA) .Or. Empty(WorkEEQ->BANCO) .Or. Empty(WorkEEQ->PRACA) .Or. Empty(WorkEEQ->SEQ_CON)
                  EasyHelp(STR0064)  //"Preencha todos os campos do contrato."
                  lRet := .F.
                  Break
            ElseIf !(WorkEEQ->TX_VINC > 0)
               EasyHelp(STR0069)
               lRet := .F.
               Break
            Else
               EF1->( DBSeek(xFilial("EF1")+IIF(EEQ->EEQ_TP_CON$"3","E","I")+WorkEEQ->EF2_CONTRA+WorkEEQ->BANCO+WorkEEQ->PRACA+WorkEEQ->SEQ_CON) )
               If EF1->EF1_CAMTRA == "1"
                  nSaldoCnt := AF500SldPar(SubStr(WorkEEQ->TP_VINC,3))
               Else
                  If EF1->EF1_TP_FIN == ACE
                     nSaldoCnt := EF1->EF1_SL2_PM
                  Else
                     nSaldoCnt := EF1->EF1_SLD_PM
                  EndIf
               EndIf
               If WorkEEQ->VL_VINC  >  nSaldoCnt
                  EasyHelp(STR0065+AllTrim(Transform(nSaldoCnt,AVSX3("EEQ_VL",6)))+").")  //"O Valor a Vincular e maior que o Saldo do Contrato (R$ "
                  If  TRB->EEQ_TP_CON $ "4"  // Remessa
                     If MsgYesNo(STR0066+AllTrim(Str(EF1->EF1_VL_MOE+WorkEEQ->VL_VINC-nSaldoCnt))+"?")  //"Deseja aumentar o valor do Contrato para R$ "
                        RecLock("EF1",.F.)
                        EF1->EF1_VL_MOE += WorkEEQ->VL_VINC - nSaldoCnt
                        EF1->EF1_SLD_PM += WorkEEQ->VL_VINC - nSaldoCnt
                        EF1->( MSUnLock() )
                     Else
                        lRet := .F.
                        Break
                     EndIf
                  Else
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

         Case cCampo == "TX_CONTR" //LRS - 23/02/2018
              If Empty(WorkEEQ->TX_CONTR)
                 Help(" ",1,"AVG0005232") //"Valor deve ser maior que zero."
                 lRet := .F.
              Else
                 WorkEEQ->VL_PARC := (WorkEEQ->TX_VINC * WorkEEQ->VL_VINC) / M->TX_CONTR
                 IF WorkEEQ->VL_VINC > WorkEEQ->VL_PARC
                    WorkEEQ->VL_VINC := WorkEEQ->VL_PARC
                    M->VL_VINC := WorkEEQ->VL_PARC
                    AF500ValVinc("VL_VINC")
                 EndIF                 
              ENDIF

      End Case

   End Sequence


Return lRet


******************************************************************************************
// PLB 25/05/06 - Quebra Parcelas da Invoice
******************************************************************************************
Function AF500QuebraInv(nSaldo,nVlParc)
******************************************************************************************

 Local i          := 0    ,;
       nOldRec    := 0    ,;
       nNewRec    := 0    ,;
       cLastParc  := "00" ,;
       aQuebraEEQ := {}   ,;
       nRecEF3    := 0    ,;
       cParcOri   := ""   

   nRecEF3 := EF3->( RecNo() )
   EF3->( DBSeek(cFilEF3+IIF(TRB->EEQ_TP_CON$"3","E","I")+TRB->EEQ_NRINVO+TRB->EEQ_PARC+EV_EMBARQUE) )
   nOldRec := EEQ->( RecNo() )

 Begin TransAction
   For i := 1  to  EEQ->( FCount() )
      AAdd( aQuebraEEQ , EEQ->&( FieldName(i) ) )
   Next i

   TRB->(DBSeek(EEQ->EEQ_PARC))
   TRB->EEQ_VL := nVlParc

   If !Empty(EEQ->EEQ_ORIGEM)
      cParcOri := EEQ->EEQ_ORIGEM
   Else
      cParcOri := EEQ->EEQ_PARC
   EndIf
 
   RecLock("EEQ",.F.)
   EEQ->EEQ_VL := nVlParc
   EEQ->EEQ_FI_TOT := "S"
   EEQ->EEQ_VL_PAR := 0
   EEQ->EEQ_NROP   := WorkEEQ->EF2_CONTRA
   EEQ->EEQ_BANC   := EF3->EF3_BAN_FI
   EEQ->EEQ_AGEN   := EF3->EF3_AGENFI
   EEQ->EEQ_NCON   := EF3->EF3_NCONFI
   EEQ->EEQ_NOMEBC := Posicione("SA6",1,xFilial("SA6")+EF3->EF3_BAN_FI+EF3->EF3_AGENFI+EF3->EF3_NCONFI,"A6_NOME")
   EEQ->EEQ_PARFIN := EEQ->EEQ_PARC
   EEQ->( MSUnLock() )
   EF3->( DBGoTo(nRecEF3) )

   If !(AF500Integ(nOldRec,4,.T.,.F.))
      EasyHelp(STR0096) // "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
      Break
   EndIf

   RecLock("EEQ",.T.)
   
   For i := 1  to  Len(aQuebraEEQ)
      If EEQ->( FieldName(i) ) <> "EEQ_PARC"
         EEQ->&( FieldName(i) ) := aQuebraEEQ[i]
      EndIf
   Next i
   nNewRec := EEQ->( RecNo() )
   EEQ->( DBSeek(cFilEEQ+M->EEQ_PREEMB+TRB->EEQ_PARC) )
   Do While !EEQ->( EOF() ) .And. cFilEEQ+M->EEQ_PREEMB == EEQ->EEQ_FILIAL+EEQ->EEQ_PREEMB
      EEQ->( DBSkip() )
   EndDo
   EEQ->( DBSkip(-1) )
   cLastParc := EEQ->EEQ_PARC
   If  Val(cLastParc)+1  <  10
      cLastParc := PadL(AllTrim(Str(Val(cLastParc)+1)),2,"0")
   Else
      cLastParc := AllTrim(Str(Val(cLastParc)+1))
   EndIf
   EEQ->( DBGoTo(nNewRec) )
   EEQ->EEQ_PARC   := cLastParc
   EEQ->EEQ_VL     := nSaldo - nVlParc
   EEQ->EEQ_ORIGEM := cParcOri
   EEQ->( MSUnLock() )

   RecLock("TRB",.T.)
   For i := 1  To  TRB->( FCount() )
      cFieldEEQ := TRB->( FieldName(i) )
      If EEQ->( FieldPos(cFieldEEQ) ) > 0
         TRB->&(cFieldEEQ) := EEQ->&(cFieldEEQ)
      EndIf
   Next i
   TRB->WK_MARCA := cMarca
   TRB->WK_RECNO := EEQ->( RecNo() )
   TRB->( MSUnLock() )
   oMark:oBrowse:Refresh()
   TRB->( DBGoTop() )

   If !(AF500Integ(nNewRec,OPC_INC,.F.,.F.))
      EasyHelp(STR0096) // "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
      Break
   EndIf

 End TransAction

   EEQ->( dbSetFilter( {|| EEQ_FASE == '3' .OR. EEQ_FASE == '4'}, "EEQ_FASE == '3' .OR. EEQ_FASE == '4'"))
   EEQ->( DBGoTo(nOldRec) )

Return nNewRec


******************************************************************************************
//** PLB 25/05/06 - Função para retorno do Saldo de Contrato com Parcelas de Pagamento.
******************************************************************************************
Function AF500SldPar(cTipo)
******************************************************************************************

 Local nSld        := 0 ,;
       nRecEF3     := 0 ,;
       nOrdEF3     := 0

   cTipo := Upper(AllTrim(cTipo))
   nOrdEF3 := EF3->( IndexOrd() )
   nRecEF3 := EF3->( RecNo() )
   EF3->( dbSetOrder(1) )

   If cTipo == "PRINCIPAL"

      If TRB->EEQ_TP_CON $ "3"  // Recebimento

         EF3->( DBSeek(cFilEF3+"E"+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+Left(EV_PRINC_PREPAG,2)) )
         Do While EF3->( !EoF() .AND. EF3_FILIAL+"E"+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+Left(EF3_CODEVE,2) == cFilEF3+"E"+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT+Left(EV_PRINC_PREPAG,2)) )
            nSld += EF3->EF3_SLDVIN
            EF3->( DBSkip() )
         EndDo

      ElseIf TRB->EEQ_TP_CON $ "4"  // Remessa

         nSld := EF1->EF1_VL_MOE
         EF3->( DBSeek(cFilEF3+"I"+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+EV_EMBARQUE) )
         Do While EF3->( !EoF() .AND. EF3_FILIAL+"I"+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE == cFilEF3+"I"+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT+EV_EMBARQUE) )
            nSld -= EF3->EF3_VL_MOE
            EF3->( DBSkip() )
         EndDo

      EndIf

   ElseIf cTipo == "JUROS"
      EF2->(dbSetOrder(2))

      EF3->( dbSeek(cFilEF3+IIF(TRB->EEQ_TP_CON$"3","E","I")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+Left(EV_JUROS_PREPAG,2)) )

      Do While EF3->( !EoF() .AND. EF3_FILIAL+IIF(TRB->EEQ_TP_CON$"3","E","I")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+Left(EF3_CODEVE,2) == cFilEF3+IIF(TRB->EEQ_TP_CON$"3","E","I")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT+Left(EV_JUROS_PREPAG,2)) )

         EF2->( dbSeek(xFilial("EF2")+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+If(lEF2_INVOIC,Space(Len(EF2->EF2_FILORI+EF2->EF2_INVOIC+EF2->EF2_PARC)),"")+;
                                      EF1->EF1_TP_FIN+If(lEF2_TIPJUR,Right(EF3->EF3_CODEVE,1),"")+DtoS(EF3->EF3_DT_EVE),.T.))

         If EF2->(Eof()) .or. If(lEFFTpMod,EF2->EF2_TPMODU,"")+EF2->EF2_CONTRA <> If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA .or.;
         EF2->EF2_TP_FIN <> EF1->EF1_TP_FIN .or. iif(lTemChave,EF2->EF2_BAN_FI+EF2->EF2_PRACA+If(lEFFTpMod,EF2->EF2_SEQCNT,"")<>EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),.F.) .or.;
         If(lEF2_TIPJUR,EF2->EF2_TIPJUR<>Right(EF3->EF3_CODEVE,1),.F.)
            EF2->(dbSkip(-1))
         EndIf

         If EF2->EF2_DT_INI > EF3->EF3_DT_EVE
            EF2->(dbSkip(-1))

            If EF2->(BOF()) .or.;
            If(lEFFTpMod,EF2->EF2_TPMODU,"")+EF2->EF2_CONTRA <> If(cAliasEF1=="M",If(lEFFTpMod,M->EF2_TPMODU,"")+M->EF1_CONTRA,If(lEFFTpMod,EF2->EF2_TPMODU,"")+EF1->EF1_CONTRA) .or.;
            EF2->EF2_TP_FIN <> If(cAliasEF1=="M",M->EF1_TP_FIN,EF1->EF1_TP_FIN) .or. iif(lTemChave,EF2->EF2_BAN_FI+EF2->EF2_PRACA+If(lEFFTpMod,EF2->EF2_SEQCNT,"")<>EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),.F.) .or.;
            If(lEF2_TIPJUR,EF2->EF2_TIPJUR<>Right(EF3->EF3_CODEVE,1),.F.)
               EF3->(dbSkip())
               Loop
            ElseIf (EF2->EF2_DT_INI > EF3->EF3_DT_EVE .or. EF2->EF2_DT_FIM < EF3->EF3_DT_EVE) .or.;
            EF2->EF2_USEINV == "2"
               EF3->(dbSkip())
               Loop
            Else
               nSld += EF3->EF3_SLDVIN
            EndIf
         ElseIf EF2->EF2_DT_INI > EF3->EF3_DT_EVE .or. EF2->EF2_DT_FIM < EF3->EF3_DT_EVE .or.;
         EF2->EF2_USEINV == "2"
            EF3->(dbSkip())
            Loop
         Else
            nSld += EF3->EF3_SLDVIN
         EndIf

         EF3->( DBSkip() )
      EndDo

   EndIf

   EF3->( DBSetOrder(nOrdEF3) )
   EF3->( DBGoTo(nRecEF3) )

Return nSld

******************************************************************************************
//** PLB 25/05/06 - Opcao de Vinculacao a Principal ou Juros
******************************************************************************************
Static Function AF500ParPgt()
******************************************************************************************

 Local oDlg3            ,;
       oCombo           ,;
       cTitle   := ""   ,;
       cMsg     := ""   ,;
       cSelecao := ""   ,;
       aValores := {""}

   aValores := { STR0089 , STR0090 } //	STR0089	"1-PRINCIPAL" //STR0090	"2-JUROS"

   cTitle := STR0073  //"Vinculacao a Contrato com Parcelas de Pagamento"
   cMsg   := STR0074  //"Vincular a:"

   DEFINE MSDIALOG oDlg3 TITLE cTitle FROM oMainWnd:nTop+150, oMainWnd:nLeft+50 TO oMainWnd:nTop +250, oMainWnd:nLeft + 400 OF oMainWnd PIXEL

   @ 12,25  Say STR0074 Of oDlg3 pixel
   @ 12,68  Combobox oCombo var cSelecao items aValores size 80,08 of oDlg3 pixel
   @ 32,70 BUTTON "OK" SIZE 34,11 Of oDlg3 pixel ACTION oDlg3:END()

   ACTIVATE MSDIALOG oDlg3 centered

   If cSelecao  <>  WorkEEQ->TP_VINC
      lAltTpVin := .T.
   EndIf
   WorkEEQ->TP_VINC := cSelecao

Return .T.


******************************************************************************************
//** PLB 01/06/06 - Liquidacao de Parcela de Invoice vinculada a Financiamento
******************************************************************************************
Function AF500LiqFin()
******************************************************************************************

 Local aTaxaLiq := {}  ,;
       lLiquida := .F. ,;
       nTxCon   := 0
 Local cCpoDt:=EasyGParam("MV_CPODTJR",,"EEQ_DTCE")
 Local lExecLiq:= .F.
 Local nPos

 // Variaveis privadas utilizadas no EFFEX400 e EFFEX401
 Private aGetProv := {}  ,;
         lInverte := .F. ,;
         cMod     := ""  ,;
         cTX_100  := ""  ,;
         cTX_520  := ""

  aLiqAuto:= {}
  Begin TransAction

   // Alteracao de Taxa de Liquidacao de Financiamento para Moeda diferente do Contrato
   aTaxaLiq := {}
   If ( nPos := AScan( aVinculados , { |x| EEQ->EEQ_NRINVO+EEQ->EEQ_PARC==x[2]+x[3] } ) )  >  0
      EF3->( DBSeek(cFilEF3+aVinculados[nPos][5]+aVinculados[nPos][2]+aVinculados[nPos][3]+EV_EMBARQUE) )
      EF1->( DBSeek(cFilEF1+aVinculados[nPos][5]+aVinculados[nPos][6]+aVinculados[nPos][7]+aVinculados[nPos][8]+aVinculados[nPos][9]))

      If EF3->EF3_MOE_INV <> EF1->EF1_MOEDA
         IF EF1->EF1_TP_FIN == "05"//LRS - 23/02/2018
            nTxCon := EF1->EF1_TX_MOE
         Else
            nTxCon := BuscaTaxa(EF1->EF1_MOEDA,EEQ->EEQ_PGT,,.F.,.T.,,"1")
         EndIF
         AAdd( aTaxaLiq , { aVinculados[nPos][06]          ,; // 1-Contrato
                            aVinculados[nPos][07]          ,; // 2-Banco
                            aVinculados[nPos][08]          ,; // 3-Praca
                            aVinculados[nPos][09]          ,; // 4-Sequencia Contrato
                            aVinculados[nPos][02]          ,; // 5-Invoice
                            aVinculados[nPos][03]          ,; // 6-Parcela
                            IF(/*EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->EEQ_MODAL == "2"*/EasyVerModal("EEQ"),EEQ->EEQ_DTCE,EEQ->EEQ_PGT)                   ,; // 7-Data Liquidacao - AOM - 24/08/2012
                            EEQ->EEQ_MOEDA                 ,; // 8-Moeda Invoice
                            EEQ->EEQ_TX                    ,; // 9-Taxa Liquidacao
                            EEQ->EEQ_VL                    ,; // 10-Valor Moeda Invoice
                            EF1->EF1_MOEDA                 ,; // 11-Moeda Contrato
                            nTxCon                         ,; // 12-Taxa Contrato
                            EEQ->EEQ_VL*EEQ->EEQ_TX/nTxCon ,; // 13-Valor Moeda Contrato
                            } )
         lLiquida := .T.
      EndIf

      If lLiquida
         aTaxaLiq := EX401GetLiq(aTaxaLiq)
         nPos2 := AScan(aTaxaLiq,{|x| x[5]+x[6]==aVinculados[nPos][2]+aVinculados[nPos][3]})
      EndIf

      cMod := EF1->EF1_TPMODU
      EC6->( DBSetOrder(1) )
      EC6->(DbSeek(xFilial("EC6")+"FIEX"+EF1->EF1_TP_FIN+'520' ))
      cTX_100 := EC6->EC6_TXCV
      cTX_520 := EC6->EC6_TXCV

      // Liquidacao no Contrato de Financiamento
      EX400Liquida( EF1->EF1_CONTRA            ,;  // cContrato
                    EEQ->EEQ_NRINVO            ,;  // cInvoice
                    EEQ->EEQ_PARC              ,;  // cParc
                    M->EEQ_PREEMB              ,;  // cPreemb
                    EEQ->EEQ_VL                ,;  // nValor
                    EEQ->EEQ_MOEDA             ,;  // cMoeInv
                    EF1->EF1_MOEDA             ,;  // cMoeCont
                    "EF1"                      ,;  // cAliasEF1
                    "EF3"                      ,;  // cAliasEF3
                    "CAMB"                     ,;  // cChamada
                    EEQ->EEQ_TX                ,;  // nTx
                    /*IF(EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->EEQ_MODAL == "2" EasyVerModal(),EEQ->EEQ_DTCE,EEQ->EEQ_PGT)*/ EEQ->&(cCpoDt),;  // dData   AOM - 24/08/2012 //wfs - mesmo tratamento da função GeraLiq() - effaf200
                    If(!Empty(EEQ->EEQ_DTNEGO), EEQ->EEQ_DTNEGO, EEQ->EEQ_PGT),;  // dDtLiq //wfs - mesmo tratamento da função GeraLiq() - effaf200
                    /*IF(EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->EEQ_MODAL == "2" EasyVerModal(),EEQ->EEQ_DTCE,EEQ->EEQ_PGT)*/ EEQ->EEQ_PGT,;  // dDtRealLiq   AOM - 24/08/2012 //wfs - mesmo tratamento da função GeraLiq() - effaf200
                    If(lMulTiFil,cFilEEQ,Nil)  ,;  // cFilOri
                                               ,;  // nVlMoeAnt
                    IIF(EF1->EF1_CAMTRA=="1" .And. aVinculados[nPos][14]=="2",IIF(lLiquida .And. nPos2>0,aTaxaLiq[nPos2][13],EEQ->EEQ_VL),) ,;  // nVlMoeAtu
                                               ,;  // nVlReaAnt
                                               ,;  // nVlReaAtu
                    EEQ->EEQ_BANC              ,;  // cBanco
                    EEQ->EEQ_AGEN              ,;  // cAgencia
                    EF1->EF1_NCONFI            ,;  // cConta
                    aVinculados[nPos][8]       ,;  // cPraca
                                               ,;  // lBxForc
                    EEQ->EEQ_VL * EEQ->EEQ_TX  ,;  // nValorRea
                                               ,;  // cParcAux
                    EEQ->EEQ_NROP              ,;  // cNrOp
                    aVinculados[nPos][16]      ,;  // nRecEF3Liq
                    aVinculados[nPos][5]       ,;  // cTpModu
                    EF1->EF1_SEQCNT            ,;  // cSeqCon
                    "EEQ"                      ,;  // cOrigem
                    EEQ->EEQ_FORN              ,;  // cForn
                    EEQ->EEQ_FOLOJA            ,;  // cLojaFo
                                               ,;  // cPo_Di
                    IIF(lLiquida .And. nPos2>0,aTaxaLiq[nPos2][13],),; // nVlMoeLiq
                                               ,;  //lEvRefi
                    @lExecLiq) //lExecLiq

      DBSelectArea("EEQ")

   EndIf

  End TransAction

   /* WFS 06/09/16 - Chamada da tela de liquidação do evento.
      Objetivos: possibilitar ao usuário informar os dados para liquidação do evento e
      executar a tela fora da transação.
      A flag lExecLiq será alterada para verdadeiro quando o evento principal for liquidado totalmente. */
   If lExecLiq
      EF3->(DBSetOrder(1))
      If EF3->(DBSeek(xFilial() + EF3->EF3_TPMODU + EF1->EF1_CONTRA + EF1->EF1_BAN_FI + EF3->EF3_PRACA + EF1->EF1_SEQCNT + EF3->EF3_EV_VIN + EF3->EF3_PARVIN))
         lLiqAutoFinancing:= lExecLiq
         AAdd(aLiqAuto, EF3->(RecNo()))
      EndIf
   EndIf

Return .T.


******************************************************************************************
//** PLB 01/06/06 - Estorno de Liquidacao de Parcela de Invoice vinculada a Financiamento
******************************************************************************************
Function AF500ELqFin(nPos)
******************************************************************************************

 Local nOrdEF3 := 0  ,;
       cSeq    := ""

 // Utilizada no EFFEX400
 Private cMod := ""

   If AvFlags("SIGAEFF_SIGAFIN") .OR. Avflags("EEC_LOGIX")
      oEFFContrato := AvEFFContra():LoadEF1()
   EndIf

   nOrdEF3 := EF3->( IndexOrd() )
                //              TpModu            Contrato               Banco               Praca                SeqCnt
   EF1->( DBSeek(cFilEF1+aVinculados[nPos][5]+aVinculados[nPos][6]+aVinculados[nPos][7]+aVinculados[nPos][8]+aVinculados[nPos][9]) )
   EF3->( DBSetOrder(1) )
   If EF3->( DBSeek(cFilEF3+aVinculados[nPos][5]+aVinculados[nPos][6]+aVinculados[nPos][7]+aVinculados[nPos][8]+aVinculados[nPos][9]+EV_LIQ_PRC) ) ;
      .Or. ( lPrePag  .And.  EF1->EF1_CAMTRA == "1"  .And.  EF3->( DBSeek(cFilEF3+aVinculados[nPos][5]+aVinculados[nPos][6]+aVinculados[nPos][7]+aVinculados[nPos][8]+aVinculados[nPos][9]+Left(EV_LIQ_JUR,2)) ) )

      Do While !EF3->( Eof() )  .And.  EF3->EF3_FILIAL == cFilEF3  .And.  EF3->EF3_CONTRA == aVinculados[nPos][6]  ;
               .And.  EF3->EF3_BAN_FI == aVinculados[nPos][7] .And.  EF3->EF3_PRACA == aVinculados[nPos][8]  ;
               .And.  EF3->EF3_SEQCNT == aVinculados[nPos][9]  ;
               .And.  ( EF3->EF3_CODEVE == EV_LIQ_PRC  .Or.  (lPrePag .and. EF1->EF1_CAMTRA == "1"  .And.  Left(EF3->EF3_CODEVE,2) == Left(EV_LIQ_JUR,2) ) )

         If EF3->EF3_INVOIC == aVinculados[nPos][2]  .And.  EF3->EF3_PARC == aVinculados[nPos][3]
            cSeq := EF3->EF3_SEQ
         EndIf
         EF3->( DBSkip() )
      Enddo

      If !Empty(cSeq)

         EF3->( DBSetOrder(4))
         EF3->( DBSeek(cFilEF3+aVinculados[nPos][5]+aVinculados[nPos][6]+aVinculados[nPos][7]+aVinculados[nPos][8]+aVinculados[nPos][9]+cSeq) )

         Do While !EF3->( Eof() )  .And.  EF3->EF3_FILIAL == cFilEF3  .And.  EF3->EF3_CONTRA == aVinculados[nPos][6]  ;
                  .And.  EF3->EF3_BAN_FI == aVinculados[nPos][7] .And.  EF3->EF3_PRACA == aVinculados[nPos][8]  ;
                  .And.  EF3->EF3_SEQCNT == aVinculados[nPos][9] .And.  EF3->EF3_SEQ == cSeq

            cMod := EF1->EF1_TPMODU

            EX400AtuSaldos("LIQ",,,"EEC")

            If (EF3->EF3_CODEVE == EV_LIQ_PRC .Or. Left(EF3->EF3_CODEVE,2) == Left(EV_LIQ_JUR,2) )
               EX400MotHis("LIQ",EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_TP_FIN,EF3->EF3_PREEMB,EF3->EF3_INVOIC,EF3->EF3_PARC,EF3->EF3_CODEVE,EF3->EF3_SEQ,EF1->EF1_TPMODU,EF1->EF1_SEQCNT)
            EndIf

            /* Permitir estorno de baixa automática dos eventos de juros */
            If AvFlags("SIGAEFF_SIGAFIN") .OR. Avflags("EEC_LOGIX")
               If Avflags("EEC_LOGIX") .And. !Empty(EF3->EF3_SEQBX)
                  oEFFContrato:EventoEF3("ESTORNO_LIQUIDACAO")
               EndIf
               oEFFContrato:EventoEF3("ESTORNO")
            EndIf


            EF3->(RecLock("EF3",.F.))
            If !Empty(EF3->EF3_NR_CON)
               EF3->EF3_EV_EST := EF3->EF3_CODEVE
               EF3->EF3_DT_EST := dDataBase
               EF3->EF3_CODEVE := EV_ESTORNO
               EF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
            Else
               EF3->( DBDelete() )
            EndIf
            EF3->( MSUnlock() )
            EF3->( DBSkip() )
         EndDo

      Endif

   EndIf

   EF3->( DBSetOrder(nOrdEF3) )

Return .T.

/*
Funcao     : ValObrAF500
Parametros : Nenhum
Retorno    : lRet
Objetivos  : Validar a gravação do cambio desvinculado(a receber ou a pagar).
Autor      : Felipe S. Martinez
Data/Hora  : 18/01/2010
*/
Static Function ValObrAF500()
Local lRet := .T.
Local cMsg := ""
Local cAviso := STR0091  + ENTER // "Informar o(s) seguinte(s) campo(s):" + ENTER

Begin Sequence

   If Empty(M->EEQ_EVENT)
      cAviso += STR0092 + ENTER // "- Evento" + ENTER
      lRet := .F.
   endif
   
   if Empty(M->EEQ_NRINVO) //Somente validar a invoice quando estiver no modulo Exportação
      cAviso += STR0093 + ENTER // "- Invoice" + ENTER
      lRet := .F.
   endif

   if M->EEQ_TIPO == "P" .And. Empty(M->EEQ_FORN)
      cAviso += STR0094 + ENTER // "- Cod.Fornecedor." + ENTER
      lRet := .F.
   endif
   
   if M->EEQ_TIPO == "R" .And. Empty(M->EEQ_IMPORT)
      cAviso += STR0095 + ENTER // "- Cod Importador."+ ENTER
      lRet := .F.
   endif
   
   if ! lRet
      cMsg := cAviso
      break 
   endif

   if nTipoP == OPC_ALT .and. EasyVerModal("M") .and. ! empty(M->EEQ_DTCE)
      cMsg := STR0123 + ENTER // "Não é possível preencher a data de crédito no exterior quando estiver alterando uma parcela na modalidade de movimento no exterior."
      cMsg += STR0123 //"Para liquidar a parcela com movimento no exterior use a rotina Liquidar."
      lRet := .F.
      Break
   endif

   //Checa se possui o tratamento para movimento no exterior e se a data de crédito no exterior foi preenchida na operação atual
   if !avflags("EEC_LOGIX") //.or. avflags("EEC_LOGIX") .and. isreceita(M->EEQ_EVENT)
      If EasyVerModal("M") .And. !Empty(M->EEQ_DTCE) .And. (TRB->WK_RECNO == 0 .Or. Empty(TRB->EEQ_DTCE))
         //Verifica se o banco no exterior foi preenchido e localiza o seu cadastro
         If !Empty(M->EEQ_BCOEXT) .And. !Empty(M->EEQ_AGCEXT).And. !Empty(M->EEQ_CNTEXT) .And. SA6->(DbSetOrder(1),DbSeek(xFilial("SA6")+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT))) .And. SA6->A6_MOEEASY <> M->EEQ_MOEDA
            If lRet := Af200ChkMd(SA6->A6_MOEEASY, M->EEQ_DTCE, "YF_MOEFAT",M->EEQ_EVENT)
               lRet := Af200ChkMd(M->EEQ_MOEDA, M->EEQ_DTCE, "YF_MOEFAT",M->EEQ_EVENT)
            EndIf
         EndIf
      EndIf
   endif

End Sequence

If !lRet
   EasyHelp(cMsg,STR0013)
EndIf

Return lRet

Static Function AF500Integ(nRecno,nOpc,lAltTit,lAlt_Pgt) // BAK - 24/09/12
Local lRet := .T.
Local cInclusao := ""
Local cAlteracao := ""
Local cExclusao := ""
Local cBaixa := ""
Local cEstorno := ""
Local lAchouTit := .T.
Local lEstorno := .T.
Local lFinanceiro := ChkFile("SE1") .And. ChkFile("SE2") .And. ChkFile("SE5")
Local lSeekFin := .F.
Local cModAux  := cModulo //RRC - 28/11/2013 - Guarda a variável cModulo pois a mesma poderá ser alterada
Private nParcEst// Utilizada no estorno
Private cNatureza:= ""

Default lAltTit := .F.
Default lAlt_Pgt := .F.

Begin Sequence

   If ValType(nOpc) <> "N" .Or. nOpc == OPC_VIS
      Break
   EndIf

   If ValType(nRecno) == "N" .And. nRecno > 0 // Na exclusão da parcela do financeiro ja está posicionado no EEQ
      EEQ->(DbGoTo(nRecno))
   EndIf
	
	If AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116") //THTS - 22/03/2017 - Se for adiantamento a fornecedor com integracao Logix

		If "A" $ EEQ->EEQ_TIPO .And. "F" $ EEQ->EEQ_FASE .And. "609" == EEQ->EEQ_EVENT
			cBaixa		:= "091" // Baixa de parcela de Adiantamento a Fornecedor 
			cEstorno	:= "092" // Estorno de parcela de Adiantamento a Fornecedor

			If nOpc == OPC_LIQ
	       	lRet := AvStAction(cBaixa)
	      	EndIf
	
	      	If nOpc == OPC_ELQ .And. !Empty(EEQ->EEQ_FINNUM)
	         	lRet := AvStAction(cEstorno)
	      	EndIf			
						
		EndIf

	Else //Fluxo do cambio 3/4
	
	   If "R" $ EEQ->EEQ_TIPO // IsReceita(EEQ->EEQ_EVENT)
	      cInclusao := "020" // Inclusão de parcela de cambio a receber
	      cAlteracao := "021" // Alteração de parcela de cambio a receber
	      cExclusao := "022" // Exclusão de parcela de cambio a receber
	      cBaixa := "023" // Baixa de parcela de cambio a receber
	      cEstorno := "024" // Estorno de parcela de cambio a receber
	      //RRC - 27/11/2013 - Alteração para verificar se for chamada de MSExecAuto() com o campo EEQ_PROCES no array, o que também idnicar ser do SIGAESS
	      If IsInCallStack('ESSRS400') .Or. IsInCallStack("ESSPS400")  .Or.  IsInCallStack("ESSPS401") .Or. IsInCallStack("ESSIN100") //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0)
	         cModulo := "ESS"
	      EndIf
	      If lFinanceiro .And. !Empty(EEQ->EEQ_FINNUM)
	         SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	         SE5->(DbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
	         lAchouTit := SE1->(DbSeek(xFilial()+cModulo+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(EECGetFinParc(EEQ->EEQ_PARC), "E1_PARCELA")+AvKey("NF","E1_TIPO")))
	         lEstorno := AF201PosicSE5("SE1")
	      EndIf
	      lEstorno := !IsIntEnable("001") .Or. lEstorno
	   Else
	      cInclusao := "025" // Inclusão de parcela de cambio a pagar
	      cAlteracao := "026" // Alteração de parcela de cambio a pagar
	      cExclusao := "027" // Exclusão de parcela de cambio a pagar
	      cBaixa := "028" // Baixa de parcela de cambio a pagar
	      cEstorno := "029" // Estorno de parcela de cambio a pagar
	      //RRC - 27/11/2013 - Alteração para verificar se for chamada de MSExecAuto() com o campo EEQ_PROCES no array, o que também idnicar ser do SIGAESS
	      If IsInCallStack('ESSRS400') .Or. IsInCallStack("ESSPS400")  .Or.  IsInCallStack("ESSPS401") .Or. IsInCallStack("ESSIN100") //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And. aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0)
	         cModulo := "ESS"
	      EndIf
	      If lFinanceiro .And. !Empty(EEQ->EEQ_FINNUM)
	         SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	         SE5->(DbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
	         If "ESS" $ cModulo // IsInCallStack('ESSRS400') .Or. IsInCallStack("ESSPS400")  .Or.  IsInCallStack("ESSPS401")
	            lAchouTit:= SE2->(DbSeek(xFilial()+AvKey(If(!Empty(EEQ->EEQ_PREFIX),EEQ->EEQ_PREFIX,cModulo),"E2_PREFIXO")+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+Int101Parc(EEQ->EEQ_PARC)+AvKey("NF","E2_TIPO")))
	         Else
	            lAchouTit:= SE2->(DbSeek(xFilial()+cModulo+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+AvKey("", "E2_PARCELA")+AvKey("NF","E2_TIPO")))
	         EndIf
	         lEstorno := AF201PosicSE5("SE2")
	      EndIf
	      lEstorno := !IsIntEnable("001") .OR. lEstorno
	   EndIf
	
	   If nOpc == OPC_INC // Inclusão de parcela
	      lRet := AvStAction(cInclusao)
	
	      //RRC - 14/11/2013 - Confirma se após chamar a integração entre SIGAESS x SIGAFIN o título foi gerado
	      If lRet .And. !Empty(EEQ->EEQ_FINNUM) .And. cModulo $ "ESS"
	         If "R" $ EEQ->EEQ_TIPO
	            SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	            lSeekFin := .T.
	            If !(lAchouTit := SE1->(DbSeek(xFilial()+cModulo+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(EECGetFinParc(EEQ->EEQ_PARC), "E1_PARCELA")+AvKey("NF","E1_TIPO"))))
	               lRet := .F.
	            EndIf
	         Else
	            SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	            lSeekFin := .T.
	            If !(lAchouTit := SE2->(DbSeek(xFilial()+AvKey(If(!Empty(EEQ->EEQ_PREFIX),EEQ->EEQ_PREFIX,cModulo),"E2_PREFIXO")+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+Int101Parc(EEQ->EEQ_PARC)+AvKey("NF","E2_TIPO"))))
	               lRet := .F.
                  ElseIf lAchouTit .And. cModulo $ "ESS" .And. ELA->ELA_ORIGEM !="SIGACOM" .And. EEQ->EEQ_VL != SE2->E2_VALOR //THTS - 29/06/2017 - Se incluiu o titulo, verifica se o valor do titulo e diferente do valor EEQ e atualiza a EEQ (Retencao de impostos)
                     EEQ->EEQ_VL := SE2->E2_VALOR
                  EndIf
	         EndIf
	      EndIf
	
	      // Baixa na inclusão
	      If lRet .And. AF200ParcLiq() .And. !Empty(EEQ->EEQ_FINNUM)
	         If lFinanceiro
	            If "R" $ EEQ->EEQ_TIPO
	               //RRC - 14/11/2013 - Evita uma nova busca desnecessária na tabela do SIGAFIN
	               If !lSeekFin
	                  SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	                  lAchouTit := SE1->(DbSeek(xFilial()+cModulo+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(EECGetFinParc(EEQ->EEQ_PARC), "E1_PARCELA")+AvKey("NF","E1_TIPO")))
	               EndIf
	               SE5->(DbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
	            Else
	               SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	               SE5->(DbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
	               If "ESS" $ cModulo .And. !lSeekFin
	                  lAchouTit:= SE2->(DbSeek(xFilial()+AvKey(If(!Empty(EEQ->EEQ_PREFIX),EEQ->EEQ_PREFIX,cModulo),"E2_PREFIXO")+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+Int101Parc(EEQ->EEQ_PARC)+AvKey("NF","E2_TIPO")))
	               ElseIf !lSeekFin
	                  lAchouTit:= SE2->(DbSeek(xFilial()+cModulo+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+AvKey("", "E2_PARCELA")+AvKey("NF","E2_TIPO")))
	               EndIf
	            EndIf
	         EndIf
	
	         If (lAchouTit .Or. !IsIntEnable("001")) // Baixa de parcela
	            lRet := AvStAction(cBaixa)
	         EndIf
	      EndIf
	   EndIf
	
	   //RRC - 14/11/2013 - Adicionada condição para chamar a integração apenas caso a parcela tenha gerado o título: verifica o EEQ_FINNUM
	   If !Empty(EEQ->EEQ_FINNUM)
	      If nOpc == OPC_ALT .And. !AF200ParcLiq() .And. !lAlt_Pgt .And. lAltTit // Alteração de parcela
	         lRet := AvStAction(cAlteracao)
            //THTS - 29/06/2017 - Se incluiu o titulo, verifica se o valor do titulo e diferente do valor EEQ e atualiza a EEQ (Retencao de impostos)
            If lRet .And. cModulo $ "ESS" .And. ELA->ELA_ORIGEM !="SIGACOM" .And. SE2->(DbSeek(xFilial()+AvKey(If(!Empty(EEQ->EEQ_PREFIX),EEQ->EEQ_PREFIX,cModulo),"E2_PREFIXO")+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+Int101Parc(EEQ->EEQ_PARC)+AvKey("NF","E2_TIPO"))) .And. EEQ->EEQ_VL != SE2->E2_VALOR
               EEQ->EEQ_VL := SE2->E2_VALOR
            EndIf
	      EndIf
	
	      If nOpc == OPC_EST .And. !AF200ParcLiq()  // Exclusão de parcela
	         lRet := AvStAction(cExclusao)
	      EndIf
	
	      If nOpc == OPC_LIQ .And. lAlt_Pgt .And. AF200ParcLiq() .And. (lAchouTit .Or. !IsIntEnable("001")) // Baixa de parcela
	         lRet := AvStAction(cBaixa)
	      EndIf
	
	      If nOpc == OPC_ELQ .And. lAlt_Pgt .And. !AF200ParcLiq() .And. (lAchouTit .Or. !IsIntEnable("001")) .And. lEstorno // Estorno de parcela
	         lRet := AvStAction(cEstorno)
	      EndIf
	   EndIf
	EndIf
End Sequence
//RRC - 28/11/2013
cModulo := cModAux

Return lRet

/*
Programa   : AF500AtuaEEQ
Objetivo   : Atualizar os dados da tabela EEQ de acordo com o tipo de operação
Parametros : nRec
Retorno    : lRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 15/02/2012 16:37
Revisao    :
*/
Static Function AF500AtuaEEQ(nRec, lAlterouDtCred)
Local lAltTit := .F.
Local lAlt_Pgt := .F.
Local lRet := .T.
Local aCposInt := {"EEQ_FORN", "EEQ_FOLOJA", "EEQ_IMPORT", "EEQ_IMLOJA", "EEQ_BANC", "EEQ_VCT", "EEQ_VL","EEQ_PGT","EEQ_DTCE"}
// BAK - 27/09/2012
Local dDtBase := cToD("")
Local dDtTrb := cToD("")
Local nRecEEQ := 0
Local cSeqPag := ""
Local cModAux := cModulo //RRC - 28/11/2013 - Guarda a variável cModulo pois a mesma porderá ser alterada posteriormente
Local lCposTRB := TRB->( FieldPos("EEQ_ACRESC") > 0 .and. FieldPos("EEQ_DECRES") > 0  .and.  ;
                         FieldPos("EEQ_MULTA") > 0  .and. FieldPos("EEQ_JUROS") > 0   .and. FieldPos("EEQ_DESCON") > 0 )
Local lEstornarPgto:= .F.
Default lAlterouDtCred:= .F.
Private lRetPto := .T.//RMD - 17/04/17 - Possibilita abortar a gravação via Ponto de Entrada

Begin Sequence

   //Fase deve ser a mesma que o Tipo do Contrato.
   M->EEQ_FASE := M->EEQ_TP_CON

	//THTS - 21/03/2017 - Se for adiantamento de fornecedor, grava o campo saldo na inclusao e na alteracao
	If AvFlags("ADTFOREAI") .And. IsInCallStack("EECAC116")
		M->EEQ_SALDO 	:= M->EEQ_VL
		M->EEQ_FASE	:= "F" //Adiantamento Fornecedor
		M->EEQ_TP_CON	:= "4" //Cambio de Exportacao
	EndIf

   //RRC - 17/11/2012 - Preenche a Data do Histórico de Vencimento caso esteja em branco
   If EEQ->(FieldPos("EEQ_HVCT")) > 0 .And. Empty(M->EEQ_HVCT)
      M->EEQ_HVCT := M->EEQ_VCT
   EndIf

   // BAK - 27/09/2012
   If EEQ->(FieldPos("EEQ_BCOEXT")) > 0
      aAdd(aCposInt,"EEQ_BCOEXT")
   EndIf

   If lCpoAcrDcr
      aAdd(aCposInt, "EEQ_ACRESC" )
      aAdd(aCposInt, "EEQ_DECRES")
   EndIf

   lAltTit := AvGeraTit("M","EEQ",aCposInt)

   //AOM - 21/08/2012 - Grava a relação dos serviços com a parcela de cambio
   If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. AvFlags("CONTROLE_SERVICOS_VENDA")
      If IsInCallStack("ESSRS400")
         M->EEQ_PREEMB := EJZ->EJZ_TPPROC+EJZ->EJZ_REGIST+EJZ->EJZ_SEQREG
         M->EEQ_TPPROC := EJZ->EJZ_TPPROC
         //M->EEQ_REGIST := EJZ->EJZ_REGIST
         //M->EEQ_SEQREG := EJZ->EJZ_SEQREG
      ElseIf IsInCallStack("ESSPS400")
         /*
         M->EEQ_PREEMB := EJX->EJX_TPPROC+EJX->EJX_PROCES+EJX->EJX_SEQPRC
         M->EEQ_TPPROC := EJX->EJX_TPPROC
         M->EEQ_PROCES := EJX->EJX_PROCES
         M->EEQ_SEQPRC := EJX->EJX_SEQPRC
         */
         //RRC -27/03/2013 - Considera apenas o Tipo de Processo e o Processo para montar o EEQ_PREEMB
         M->EEQ_PREEMB := ELA->ELA_TPPROC+ELA->ELA_PROCES//+ELA->ELA_NRINVO
         M->EEQ_TPPROC := ELA->ELA_TPPROC
         M->EEQ_PROCES := ELA->ELA_PROCES
         M->EEQ_NRINVO := ELA->ELA_NRINVO
         //M->EEQ_SEQPRC := ELA->EJX_SEQPRC
      EndIf

      If EEQ->(FieldPos("EEQ_SOURCE")) > 0 .And. Type("M->EEQ_SOURCE") == "C"
         If Empty(M->EEQ_SOURCE) .And. (Type("lAF500Auto") == "U" .Or. !lAF500Auto)
            //RRC - 28/11/2013 - Atualização para verificar se o campo EEQ_PROCES está prenchido no array pois isso também indica ser chamada do SIGAESS
            If IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSRS400") //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS -  .Or. (Type("aAF500Auto") == "A" .And.  aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0)
               cModulo := "ESS"
            EndIf
            M->EEQ_SOURCE := cModulo
         EndIf
      EndIf
   EndIf

   //RMD - 10/11/07 - Nova legislação de câmbio
   If EECFlags("CAMBIO_EXT")
      If nTipoP == BXG_DET
         //Grava as movimentações
         AD101GrvInv("EEQ", "M", "EXPBXG",, nTipoP <> OPC_INC)
      ElseIf nTipoP == OPC_EST
         AD101GrvInv("EEQ", "M",, .T.)
      EndIf
   EndIf

   If nTipoP == OPC_INC
      EEQ->(RecLock("EEQ",.T.))

      If Type("lEEQAuto") <> "L" .Or. !lEEQAuto
         TRB->(DBAPPEND())
      EndIf
   Else
      EEQ->(DBGOTO(nRec))
      lAltTit := AvGeraTit("M","EEQ",aCposInt)
      EEQ->(RecLock("EEQ",.F.))
   EndIf

   If AF500EAIIntg(M->EEQ_PROCES, M->EEQ_FASE)

      /* Armazena os RecNo's dos registros que sofreram alteração.
         Todo registro alterado será excluído e incluído no ERP de destino.
         No ERP Logix, quando a parcela está contabilizada, a única forma de desfazer a contabilização é
         excluíndo e reinserindo o documento financeiro. */
      Do Case
         Case nTipoP == OPC_INC
            AAdd(aEAIUpsert, EEQ->(RecNo()))
            nReg:= EEQ->(RecNo())

         Case nTipoP == OPC_EST
            AAdd(aEAIDelete, nRec)

         OtherWise
            AAdd(aEAIDelete, nRec)
            AAdd(aEAIUpsert, nRec)
      EndCase

   EndIf

   If nTipoP <> OPC_EST
      // BAK - 26/09/2012
      dDtBase := AF200DtBaixa()
      dDtTrb := AF200DtBaixa("M")

      //Flag para indicar que houve alteração da data de crédito, para validar o estorno do pagamento no ESS quando for movimento no exterior
      If EasyVerModal("M")
         lAlterouDtCred:= dDtBase <> dDtTrb
         lEstornarPgto:= !Empty(dDtBase) .And. lAlterouDtCred
      EndIf

      AvReplace("M","EEQ")
      If Type("lEEQAuto") <> "L" .Or. !lEEQAuto
         AvReplace("M","TRB")
         TRB->WK_RECNO:=EEQ->(RECNO())
      EndIf

      If lcpoAcrDcr .And. lCposTRB                                                              //NCF - 11/08/2015
         If nTipoP <> OPC_LIQ
            TRB->EEQ_VM_REC := TRB->EEQ_VL + (TRB->EEQ_ACRESC - TRB->EEQ_DECRES)
         Else
            TRB->EEQ_VM_REC := TRB->EEQ_VL + (TRB->EEQ_ACRESC - TRB->EEQ_DECRES + TRB->EEQ_MULTA + TRB->EEQ_JUROS - TRB->EEQ_DESCON)
         EndIf
         TRB->EEQ_EQVL := TRB->EEQ_VM_REC * TRB->EEQ_TX
         EEQ->EEQ_EQVL := TRB->EEQ_EQVL
      EndIf

      If dDtTrb <> dDtBase .And. TRB->WK_RECNO <> 0
         lAlt_Pgt := .T.
      EndIf

   Else
      EEQ->(dbDelete())
      If Type("lEEQAuto") <> "L" .Or. !lEEQAuto
         TRB->(dbDelete())
      EndIf
   EndIf

   If(EasyEntryPoint("EECAF500"),ExecBlock("EECAF500",.F.,.F.,"GRAVACA0_EEQ"),)
   //RMD - 17/04/17 - Possibilita abortar a gravação via Ponto de Entrada
   If !lRetPto
      lRet := .F.
   EndIf

   If Type("lEEQAuto") <> "L" .Or. !lEEQAuto
      TRB->WK_RECNO := EEQ->(Recno()) // BAK - 24/09/2012
   EndIF

   EEQ->( MsUnLock() )

   //AOM - 24/08/2012 - Função para gerar os pagamentos das parcelas de cambios de Serviços
   /*If IsInCallStack("ESSRS400")
      If ChkFile("EL1",.T.)
         If nTipoP == OPC_LIQ
            RS401Pagto(1) //Parametro "1" indica Inclusão das parcelas
         ElseIf nTipoP == OPC_ELQ
            RS401Pagto(2) //Parametro "2" indica Estorno das parcelas
         EndIf
      EndIf
   EndIf
   */
   //RRC - 25/03/2013 - Incluída condição para só gerar pagamento se for um Processo de Aquisição de serviços
   //If ChkFile("EL9",.T.) .And. EEQ->EEQ_TPPROC == "A"
   If ChkFile("EL9") .And. Select("EL9") > 0
      If EEQ->EEQ_TPPROC == "A" 
            nRecEEQ := EEQ->(Recno())
            If !(EasyGParam("MV_ESS0027",,9) >= 10 .AND. Type("lNaoCancelar") == "L" .AND. lNaoCancelar)
                //MFR 06/06/2019 OSSME-3066
                if ( (nTipoP == OPC_LIQ .And. PS402Pagto(nRecEEQ,7,"",@cSeqPag) .And. @cSeqPag <>  "2")  .Or. nTipoP <> OPC_LIQ )
                  If (nTipoP == OPC_LIQ .Or. nTipoP == OPC_INC .And. !Empty(dDtTrb))
                        lRet := PS402Pagto(nRecEEQ,3,dDtTrb,@cSeqPag)
                  ElseIf nTipoP == OPC_ELQ
                        lRet := PS402Pagto(nRecEEQ,5,dDtBase,@cSeqPag)
                  EndIf

                  //Movimento no exterior //wfs
                  If nTipoP == OPC_ALT .And. EasyVerModal("M")
                        //Estorno do pagamento no exterior
                        If lEstornarPgto
                              lRet := PS402Pagto(nRecEEQ,5,dDtBase,@cSeqPag)
                        EndIf
                        If lAlterouDtCred .And. !Empty(EEQ->EEQ_DTCE)
                              lRet := PS402Pagto(nRecEEQ,3,dDtTrb,@cSeqPag)
                        EndIf
                  EndIf
                EndIf  
            EndIf
            // WHRS 13/07/17 TE-6273 523509/526414 - MTRADE-1245 [BERACA ERRO-3] - Geração de títulos da Invoice no processo de venda
            //Função PS500Atua() utilizada no final da execução automática do ESSPS402() para atualizar a tela desposiciona o registro
            EEQ->(DbGoTo(nRecEEQ))
      EndIf

      /* WHRS 13/07/17 TE-6273 523509/526414 - MTRADE-1245 [BERACA ERRO-3] - Geração de títulos da Invoice no processo de venda
      //Função PS500Atua() utilizada no final da execução automática do ESSPS402() para atualizar a tela desposiciona o registro
      EEQ->(DbGoTo(nRecEEQ))
      */

      If !lRet
         Break
      EndIf

   Else
      EasyHelp("Não foi possível abrir a tabela de registro de pagamento (EL9).", "Geração do RP")
      lRet:= .F.
      Break
   EndIf

   //RRC - 11/07/2013 - Na operação de exclusão da parcela de câmbio do SIGAESS gerada pela SIGAFIN, não deve chamar a integração com o Financeiro
   If !(nTipoP == OPC_EST .And. AllTrim(EEQ->EEQ_SOURCE) == "SIGAFIN")
      If (Type("lGeraTit") <> "L" .Or. lGeraTit) .And. !(lRet := AF500Integ(EEQ->(Recno()),nTipoP,lAltTit,lAlt_Pgt))
         EasyHelp(STR0096) // "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
         Break
      EndIf
   EndIf
   //** PLB 01/06/06
   If lFinanciamento
      If nTipoP == OPC_LIQ
         AF500LiqFin()
      EndIf
   EndIf
   //**

End Sequence

//RRC - 28/11/2013 - Guarda a variável cModulo pois a mesma poderá ser alterada posteriormente
cModulo := cModAux
Return lRet

Static Function SetFieldAuto(aExecAuto,cTipo,dDtEmissa)
Local cProces := ""
Local cNrInvo := ""
Local cPreemb := ""

Local lRet := .T.

Default cTipo := ""

Begin Sequence

   If ValType(aExecAuto) <> "A" .Or. Empty(aExecAuto)
      Break
   EndIf

   cProces := GetField(aExecAuto,"EEQ_PROCES")
   cNrInvo := GetField(aExecAuto,"EEQ_NRINVO")
   cPreemb := AvKey(AvKey(cTipo,"EEQ_TIPO") + AvKey(cProces,"EEQ_PROCES"),"EEQ_PREEMB")

   dDtVenc := GetField(aExecAuto,"EEQ_VCT")
   dDtCe   := GetField(aExecAuto,"EEQ_DTCE")
   dDtPgt  := GetField(aExecAuto,"EEQ_PGT")
   cModal  := GetField(aExecAuto,"EEQ_MODAL")

   nRecELA := ELA->(Recno())
   nOrdELA := ELA->(IndexOrd())

   // Será utilizado a data de vencimento que estiver no arquivo texto, caso nao esteja vindo será atribuido pelo seguinte critério:
   // - Data da liquidação de contrato de cambio ou data de credito no exterior;
   // - Data da emissão da Invoice
   If Empty(dDtVenc)
      If (Empty(cModal) .Or. "1" $ cModal) .And. !Empty(dDtPgt)
         dDtVenc := dDtPgt
      ElseIf !Empty(dDtCe)
         dDtVenc := dDtCe
      Else
         dDtVenc := dDtEmissa
      EndIf
   EndIf

   Do Case
      Case cTipo == "A"
         aAdd(aExecAuto,{"EEQ_PREEMB", cPreemb    , Nil })
         aAdd(aExecAuto,{"EEQ_EVENT" , "001"      , Nil })
         aAdd(aExecAuto,{"EEQ_DECAM" , "2"        , Nil })
         aAdd(aExecAuto,{"EEQ_FASE"  , "4"        , Nil })
         aAdd(aExecAuto,{"EEQ_TIPO"  , "P"        , Nil })
         aAdd(aExecAuto,{"EEQ_TPPROC", cTipo , Nil })
         If !Empty(dDtVenc)
            aAdd(aExecAuto,{"EEQ_VCT"   , dDtVenc       , Nil })
         EndIf

     Case cTipo == "V"
         aAdd(aExecAuto,{"EEQ_PREEMB", cPreemb    , Nil })
         aAdd(aExecAuto,{"EEQ_EVENT" , "501"      , Nil })
         aAdd(aExecAuto,{"EEQ_DECAM" , "2"        , Nil })
         aAdd(aExecAuto,{"EEQ_FASE"  , "3"        , Nil })
         aAdd(aExecAuto,{"EEQ_TIPO"  , "R"        , Nil })
         aAdd(aExecAuto,{"EEQ_TPPROC", cTipo , Nil })
         If !Empty(dDtVenc)
            aAdd(aExecAuto,{"EEQ_VCT"   , dDtVenc       , Nil })
         EndIf

   End Case
End Sequence

Return lRet

Static Function GetField(aArray,cCampo,lSeek)
Local nPos
Local cRet := ""

Default lSeek := .F.

If (nPos := aScan(aArray,{|X| AllTrim(Upper(X[1])) == AllTrim(Upper(cCampo))})) > 0
   cRet := aArray[nPos][2]
EndIf

If lSeek
   cRet := AvKey(cRet,cCampo)
EndIf

Return cRet


/*
Programa   : AF500Trig()
Objetivo   : Verifica a condição para que os gatilhos sejam disparados
Parametros : cCampo, cSeq
Retorno    : Lógico
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 24/07/2013 16:29
Revisao    :
*/

Function AF500Trig(cCampo,cSeq)
Local lRet     := .T.
Default cCampo := ""
Default cSeq   := ""

Do Case
   //Utilizado apenas para SIGAESS (Easy Siscoserv), devido ao campo EEQ_VLSISC (Valor da parcela relativo a serviços)
   Case cCampo == "EEQ_VL" .And. cSeq == "004"
      lRet := IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100")  //RMD - 05/07/16 - Caso venha do SISCOSERV já possui o campo EEQ_PROCESS - .Or. (Type("aAF500Auto") == "A" .And.  aScan( aAF500Auto , { |X| AllTrim(Upper(X[1])) == "EEQ_PROCES" }) > 0)) .And. (Empty(M->EEQ_VLSISC) .Or. M->EEQ_VLSISC > M->EEQ_VL))

EndCase
Return lRet

/*
Funcao      : AF500MOTBAIXA()
Parametros  : cMotivo
Retorno     : lOK
Objetivos   : Consulta padrao Motivo Baixa
Autor       : Lucas Raminelli
Data/Hora   : 29/10/2014
Revisao     :
Obs.        :
*/
FUNCTION AF500MOTBAIXA()

Local cArqTemp, cMarca := GetMark()
Local aSemSX3 := {},TB_Campos :={},aWork:= ReadMotBx()
Local lOK :=.F. ,lInverte := .F.
LOCAL bOK  :={|| lOK:=.T.,oDlg:End() },bSetF3 := SetKey(VK_F3),OldWork:=SELECT(),oDlg
Local nRecnoAtu := 0, cCampo := ReadVar()
Local i
Local aMotBx := {}
Private aCampos := {}

BEGIN SEQUENCE

   aMotBx := strTokArr(aWork[1], '³')
   If !Empty(aMotBx)
      Aadd(aSemSX3,{"WK_MOTCOD",AVSX3("EEQ_MOTIVO",AV_TIPO),AVSX3("EEQ_MOTIVO",AV_TAMANHO),AVSX3("EEQ_MOTIVO",AV_DECIMAL)})
      Aadd(aSemSX3,{"WK_MOTIVO",AVSX3("EEQ_MOTIVO",AV_TIPO),Len(aMotBx[2]),0})
   Else
      Aadd(aSemSX3,{"WK_MOTCOD",AVSX3("EEQ_MOTIVO",AV_TIPO),AVSX3("EEQ_MOTIVO",AV_TAMANHO),AVSX3("EEQ_MOTIVO",AV_DECIMAL)})
      Aadd(aSemSX3,{"WK_MOTIVO",AVSX3("EEQ_MOTIVO",AV_TIPO),10,0})
   EndIf

	cArqTemp:= E_CriaTrab(,aSEMSX3,"WKMOTBAI")

	For I:=1 to len(aWork)
      aMotBx := StrTokArr(aWork[i], '³')
      WKMOTBAI->(DBAPPEND())
      If !Empty(aMotBx)
	      WKMOTBAI->WK_MOTCOD:=  Alltrim(aMotBx[1])
	      WKMOTBAI->WK_MOTIVO:=  AllTrim(aMotBx[2])
      Else
	      WKMOTBAI->WK_MOTCOD:=  Alltrim(SubStr(aWork[i],0,3))
	      WKMOTBAI->WK_MOTIVO:=  AllTrim(SubStr(aWork[i], 7, 10))
	   EndIf
      If Alltrim(WKMOTBAI->WK_MOTCOD) == AllTrim(&(cCampo))
	      nRecnoAtu := WKMOTBAI->(Recno())
	   EndIf
      WKMOTBAI->(DBCOMMIT())
	Next

	If nRecnoAtu > 0
		WKMOTBAI->(DbGoto(nRecnoAtu))
	Else
		WKMOTBAI->(DBGotop())
	EndIf

    AADD(Tb_Campos,{{||WKMOTBAI->WK_MOTCOD},,STR0110}) //STR0108 - Codigo da Baixa
    AADD(Tb_Campos,{{||WKMOTBAI->WK_MOTIVO},,STR0108}) //STR0108 - Motivo da Baixa

    DEFINE MSDIALOG oDlg TITLE STR0108 FROM 62,15 TO 300,460 OF oMainWnd PIXEL  //STR0108 - Motivo da Baixa

            oMark:= MsSelect():New("WKMOTBAI",,,TB_Campos,@lInverte,@cMarca,{10,12,100,186})
            oMark:bAval:=bOk

			DEFINE SBUTTON FROM 10,187 TYPE 1  ACTION (Eval(oMark:baval)) ENABLE OF oDlg PIXEL
            DEFINE SBUTTON FROM 25,187 TYPE 2  ACTION (oDlg:End()) ENABLE OF oDlg PIXEL

    ACTIVATE MSDIALOG oDlg

    IF lOK
      // If (i := aScan(aWork, {|x| Alltrim(WKMOTBAI->WK_MOTIVO) $ x })) > 0
	  //    &(cCampo) := Alltrim(SubStr(aWork[i],0,3))
      // EndIf
      &(cCampo) := WKMOTBAI->WK_MOTCOD
	ENDIF

	WKMOTBAI->(E_EraseArq(cArqTemp))

END SEQUENCE
SetKey(VK_F3,bSetF3)

DbSelectArea(OldWork)

RETURN lOK

/*
Funcao     : AF500ValMot()
Parametros : cMotivo
Retorno    : Nenhum
Objetivos  : Validação do campo motivo
Autor      : Lucas Raminelli - LRS
Data/Hora  : 12/09/2014
*/
*----------------------------*
Function AF500ValMot()
*----------------------------*
Local lRet := .F.
Local aMotivos := ReadMotBx()
Local cMotivo := ""

	If !Empty(ReadVar())
		cMotivo := &(ReadVar())
	EndIf

	If !Empty(cMotivo)
		aEval(aMotivos, {|x| If(Alltrim(cMotivo) $ Alltrim(SubStr(x, 0, 3)), lRet := .T.,) })
	Else
		lRet := .T.
	EndIf

	If !lRet
		MsgInfo(STR0109,STR0011)// Motivo não cadastrado # Aviso
	EndIf

Return lRet

Static Function MenuDef()
Local aRotina:= {}

   aAdd(aRotina,{STR0002 ,"AxPesqui"    ,0,1})//"Pesquisa"
   aAdd(aRotina,{STR0003 ,"AF500Tela"   ,0,2})//"Visualização"
   aAdd(aRotina,{STR0004 ,"AF500Tela"   ,0,3})//"Inclusão"
   aAdd(aRotina,{STR0005 ,"AF500Tela"   ,0,4})//"Alteração"
   aAdd(aRotina,{STR0120 ,"AF500Tela"   ,0,5})//"Excluir"
   //aAdd(aRotina,{STR0009 ,"AF500Filtro" ,0,6})//"Filtro por Tipo"
   aAdd(aRotina,{STR0020 ,"AF200REL"    ,0,4})//"Follow-Up"

Return AClone(aRotina)


/*
Funcao     : AF500adPar()
Parametros : 
Retorno    : Numero da parcela a ser gerada
Objetivos  : Buscar o numero da nova parcela a ser gerada para o adiantamento de fornecedor 
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 28/04/2017
*/
Static Function AF500adPar()

Local nRet := 0
Local cQuery := ""

cQuery := " SELECT MAX(EEQ_PARC) EEQ_PARC"
cQuery += " FROM " + RetSQLName("EEQ") + " EEQ "
cQuery += " WHERE EEQ_PREEMB	= '" + AvKey(SA2->A2_COD,"EEQ_PREEMB") + "' "
cQuery += " AND EEQ_EVENT    	= '609' "
cQuery += " AND EEQ_FASE 	= 'F' " 
cQuery += " AND EEQ_FORN 	= '" + AvKey(SA2->A2_COD,"EEQ_FORN") + "' "
cQuery += " AND EEQ_FOLOJA	= '" + AvKey(SA2->A2_LOJA,"EEQ_FOLOJA") + "' "
cQuery += IIF( TcSrvType()=="AS/400"," AND EEQ.@DELETED@ <> '*' "," AND EEQ.D_E_L_E_T_ <> '*' ")

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPADPAR", .T., .T.)

If TMPADPAR->(!EOF())
    nRet := Val(TMPADPAR->(EEQ_PARC)) //Ultima parcela gerada
EndIf

TMPADPAR->(dbCloseArea())

Return nRet


Function AF500TelFWM(cFIlTela)     
	Local oMBrowse := Nil
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "EEQ" )
	oMBrowse:SetDescription( STR0001 ) //Manutenção de Cambio tipo3/4
	oMBrowse:SetFilterDefault( cFilTela )
      oMBrowse:DisableDetails()
	oMBrowse:SetMenuDef( "MenuDef" )
      //oMBrowse:AddFilter( STR0022 , cFIlTela,,.T. ) //Fase igual a 3
      oMBrowse:AddFilter( STR0022 , "EEQ->EEQ_FASE == '3'" ) //Fase igual a 3
	oMBrowse:AddFilter( STR0023 , "EEQ->EEQ_FASE == '4'" ) //Fase Igual a 4
	

	oMBrowse:Activate()
	
Return( Nil )


/*
Funcao     : AF500EAIIntg()
Parametros : EEQ_PROCES, EEQ_FASE
Retorno    : Lógico
Objetivos  : Retornar se a integração está habilitada para o módulo que está executando a rotina de câmbio 3 e 4.
             Quando for o Easy Siscoserv, o campo EEQ_PROCES estará preenchido; quando for Easy Export (ou qualquer outro onde está a chamada da função via menu),
             o campo EEQ_PROCES estará vazio.
             Não deve ser executada  integração de inclusão de títulos efetivos quando for parcela de adiantamento ao fornecedor, que possui integração específica.
Autor      : wfs
Data/Hora  : jan/2018
*/
Function AF500EAIIntg(cProcesso, cFase)
Local lRet:= .F.

Begin Sequence

   /* Se é integração do Easy Siscoserv via EAI e se a parcela de câmbio foi originada pelo módulo. */
   If (lRet:= AvFlags("ESS_EAI") .And. !Empty(cProcesso))
      Break  
   EndIf

   /* Se é integração do Easy Export Control via EAI e se a parcela de câmbio foi originada pela rotina de câmbio desvinculado. Não pode considerar os câmbios
      de adiantamento ao fornecedor. */
   If (lRet:= AvFlags("EEC_LOGIX") .And. Empty(cProcesso) .And. cFase <> "F")
      Break
   EndIf

End Sequence

Return lRet
