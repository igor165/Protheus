#INCLUDE "EECSI100.ch"
/*
Programa : EECSI100.PRW
Objetivo : Geracao de Dados para o Siscomex - RE
Autor    : Cristiano A. Ferreira
Data/Hora: 16/12/1999 14:19
Obs.     : -LUCIANO CS - 16/04/2003.: QUANDO TEM OFFSHORE NAO PERMITIR GERAR
            DADOS PARA O SISCOMEX
           -LUCIANO CS - 30/10/2001.: VERIFICA A EXISTENCIA DO CAMPO YD_CATTEX.
            SE O MESMO EXISTIR, SERA ENVIADO AO SISCOMEX.
           -LUCIANO CS - 22/08/2002.: O VALOR MOSTRADO NA UNIDADE DE MEDIDA
            ESTATISCA ESTAVA IGUAL AO DA UNIDADE DE COMERCIALIZACAO. O CORRETO
            É O VALOR CONVERTIDO P/ A UNIDADE DA NCM.
            WFS 28/05/09: Correção nos tratamentos de geração de arquivos de integração com o Siscomex.
                          Alteração nas chamadas de funções, para que sejam usados os mesmos tratamentos
                          de geração das works.
*/
// Alterado por Heder M Oliveira - 12/27/1999
#INCLUDE "MSOBJECT.CH"
#include "EEC.CH"
#include "dbtree.ch"

// Opcoes ...
#define INCLUIR_RE 2
#Define ALTERAR_RE 4
#define PORTUGUES  cSXBID // "PORT. -PORTUGUES         "
#define BLOCK_READ 1024    // Blocos de leitura
// ** JBJ - 22/10/01 16:37 - Nro de Opcoes para geracao de RE
#define OPCGERRE 05
#define DIRHISSISC "hissisc"
// **

// ** By JBJ - 18/04/2002 - Defines para tela de retorno do Siscomex
#Define PEDIDO     01
#Define SEQUENCIA  02
#Define CODIGO     03
#Define DESCRICAO  04
#Define PRECOUNIT  05
#Define UNIDADEMED 06
#Define QUANTIDADE 07
#Define VALORTOTAL 08
#Define REFCLI     09

// WFS - 16/09/08 Defines para integração com o Siscomex nos agrupamentos por N.C.M. e Descrição
//#Define QTDCARACTER 75 // Quantidade de caracteres por linha no Siscomex - tela MCEX501C
//#Define QTDLINHAS    9 // Quantidade de linhas por processo - tela MCEX501C
#DEFINE ENTER CHR(13)+CHR(10)

/*
Funcao      : EECSI100()
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Geracao de Dados para o Siscomex
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 14:23
Revisao     :
Obs.        :
*/
Function EECSI100(nOpc,cIDLote)
Local oDlg
Local cCadastro := STR0001 //"Geração de Dados para o Siscomex"
Local nOpcao := 1, nOpcA := 0, aOpcao, i
Local cTitulo   := ""
LOCAL cPathOr := AllTrim(EasyGParam("MV_AVG0002"))  // Path para gravacao dos txt
LOCAL cPathDt := AllTrim(EasyGParam("MV_AVG0003"))  // Path de Retorno do txt
Local nAliasOld := Select()
Local cTempFile,cPedFile,cPedFile2,cFILEXT
Local cCodId   := UPPER(AvKey(EasyGParam("MV_AVG0035",,"PORT."),"X5_CHAVE"))
Local nTam := 0
//Private cMsgAux := "Possíveis Erros Encontrados na Geração do Lote:" + ENTER + ENTER  //Gravação do campo MEMO

//OAP - 07/02/2011 - Adequação para utilização do NovoEX ou do Antigo.
Private lValidN_EX := If(Type("lValidN_EX") == "L",lValidN_EX,If(EasyGParam("MV_AVG0201",,"1") == "1", .T. , IF(EasyGParam("MV_AVG0201",,"1") == "2" , .F. ,(MsgYesNo("Deseja Alterar o Parametro para permitir a utilização do NovoEx?")))) )
Private lEasyConvQt := FindFunction("EasyConvQt") // BAK - 02/05/2011 - Verificar se está compilado a função EasyConvQt()

PRIVATE lFIELD_RC := IF(EE9->(FIELDPOS("EE9_RC"))#0,.T.,.F.), lInclui:=.f.
Private lField_RV := If(EE9->(FieldPos("EE9_RV"))#0,.T.,.F.) // By JBJ - 24/07/02 - 15:43
Private lCatCot := If(EE9->(FieldPos("EE9_CATCOT"))#0,.T.,.F.) // GFP - 01/08/2012 - Categoria da Cota
Private cSXBID    := IncSpace(cCodId+"-"+SX5->(Tabela("ID",cCodId)),AVSX3("EE4_IDIOMA",AV_TAMANHO),.f.) //LRS - 17/05/2018 
Private cIDLoteRE := cIDLote

Private aRadio := {STR0006,;  // "01 - Usuários"
                   STR0007,;  // "02 - Inclusão de Registro"
                   STR0074  } // "03 - Retorno Siscomex"
Private aCNPJ     := {}
Private lWizardRE := .F. //ER - 06/07/2006
Private lItFabric := EasyGParam("MV_AVG0138",,.F.), aItFabric := {}, aItFabProc := {}, aAtosLidos := {} // By JPP - 14/11/2007 - 14:00
Private nRadio, oRad // By JPP - 10/12/2008 - 11:50

Private lAlt_Can_RE  := EasyGParam("MV_AVG0177",,.F.)  // By JPP - 18/12/2008 - 14:45

Private lSemCobCamb:= EE9->( FieldPos("EE9_VLSCOB") ) > 0   //TRP-03/03/2009
Private lShowRE:= .T.
Private lAltRe:= .F.
Private lAddAnexos := .T.

//OAP  - 19/01/2011
Private oObErroNEx

Private cSeqRE := "" //DFS - 28/12/11 - Inclusão da declaracao das variaveis para que, seja feita verificação se é NovoEx
Private cSeqAnexo := "" //DFS - 28/12/11 - Inclusão da declaracao das variaveis para que, seja feita verificação se é NovoEx
Private cCatCota := "" // GFP - 25/07/2012 - Inclusão da declaracao das variaveis para que, seja feita verificação se é NovoEx

If EECFlags("NOVOEX") .AND. ValType(nOpc) <> "N" .AND. ValType(cIDLote) <> "C"
   Private cErrosNEX := ""
   Return EECEI300()
EndIf

If Select("EXO") = 0 .and. SX2->(dbSetOrder(1), dbSeek("EXO"))
   dbSelectArea("EXO")
EndIf

If EECFlags("WIZARD_RE")
   lWizardRE := .T.
EndIf

Begin Sequence
   If lAlt_Can_RE
      Aadd(aRadio,STR0118 )  //"04 - Alteração RE",;
      Aadd(aRadio,STR0119)  //"05 - Cancelamento RE",;
      Aadd(aRadio,STR0120)  //"06 - Retorno Cancelamento RE"
   EndIf
   *
   cFILEXT := ALLTRIM(EasyGParam("MV_AVG0024",,""))
   cFILEXT := IF(cFILEXT=".","",cFILEXT)
   If !Empty(EasyGParam("MV_AVG0023",,"")) .And. !Empty(cFILEXT) .And.;
      (EE7->(FieldPos("EE7_INTERM")) # 0) .And. (EE7->(FieldPos("EE7_COND2")) # 0) .And.;
      (EE7->(FieldPos("EE7_DIAS2")) # 0) .And. (EE7->(FieldPos("EE7_INCO2")) # 0) .And.;
      (EE7->(FieldPos("EE7_PERC")) # 0) .And. (EE8->(FieldPos("EE8_PRENEG")) # 0) .AND.;
      cFILEXT = XFILIAL("EEC")
      *
      MSGINFO(STR0104,STR0038) //"Filial do Exterior não pode gerar dados para o SISCOMEX !"###"Atenção"
      BREAK
   ENDIF

   Private aHeader := {}, aCampos := Array(EEC->(fCount()))
   aSemSX3:= {{"WK_FLAG","C",02,0},{"WK_INFR","C",02,0},{"WK_PEDIDO","C",30,0}}
   //TRP - 29/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

   //GFP 25/10/2010
   aSemSX3 := AddWkCpoUser(aSemSX3,"EEC")

   cTempFile := EECCriaTrab("EEC",aSemSX3,"TRB")
   EECIndRegua("TRB",cTempFile+TEOrdBagExt(),"EEC_PREEMB")

   Set Index To (cTempFile+TEOrdBagExt())

   aCAMPOS := ARRAY(0)

   // ** By JBJ 04/04/02 - Cria Work para os pedidos
   cPedFile := EECCriaTrab(,{{"WK_FLAG","C",02,0},{"WK_PREEMB","C",20,0},{"WK_PEDIDO","C",20,0},;
                            {"WK_RE","C",12,0},{"WK_DTRE","C",08,0},{"WK_SEQUEN","C",06,0}},"TRB1")

   EECIndRegua("TRB1",cPedFile+TEOrdBagExt(),"WK_PEDIDO+WK_RE")

   cPedFile2:=EECGetIndexFile("TRB1", cPedFile, 1)//CriaTrab(Nil,.f.)
   EECIndRegua("TRB1",cPedFile2+TEOrdBagExt(),"WK_PREEMB")

   Set Index to (cPedFile+TEOrdBagExt()),(cPedFile2+TEOrdBagExt())

   //** JPM - 19/08/05
   If EasyEntryPoint("EECPSI00")
      ExecBlock("EECPSI00",.F.,.F.,{"ANTES_TELA",{},0})
   Endif

   aOpcao := aClone(aRadio)
   For i := 1 to Len(aOpcao)
      If SubStr(aOpcao[i],1,5) <> StrZero(i,2) + " - "
         aOpcao[i] := StrZero(i,2) + " - " + aOpcao[i]
      EndIf
   Next
   nTam := 8 * (Len(aOpcao) - 3) - 1
   //** Fim

   While .t.
      // Verifica a existencia do diretorio
      nOpcA := 0
      IF(Right(cPathOr,1) != "\", cPathOr += "\",)

      IF ! lIsDir(Left(cPathOr,Len(cPathOr)-1)) .AND. !EECFlags("NOVOEX")
         MSGINFO(STR0002 + cPathOr +")",STR0003) //"Diretorio para gravacao do txt não existe ("###"Aviso"
         break
      ENDIF

      IF(Right(cPathDt,1) != "\", cPathDt += "\",)

      // ** JBJ - 24/10/01 - 16:22 Verifica a existência do diretório HISSISC no sistema (Início) ...
      IF ! lIsDir(Left(cPathDt,Len(cPathDt)-1)) .AND. !EECFlags("NOVOEX")
         MakeDir(cPathDt)
      ENDIF

      /*
      IF ! lIsDir(Left(cPathDt,Len(cPathDt)-1))
         MSGINFO(STR0004 + cPathdt +")",STR0003) //"Diretorio de retorno do txt não existe ("###"Aviso"
         break
      ENDIF
      */

      // ** (Fim)
      If ValType(nOpc) <> "N" .OR. nOpc <= 0
         DEFINE MSDIALOG oDlg TITLE cCadastro FROM 1,1 TO 165+(2*nTam),240 OF oMainWnd Pixel

         @ 10,5 TO 60+nTam,113 LABEL STR0005 OF oDlg PIXEL //"Eventos:"

         If lWizardRE
            If !lAlt_Can_RE
               @ 23, 13 Radio oRad Var nOpcao Size 90, 09 Items STR0006,; //"01 - Usuários"
                                                                STR0007   //"02 - Inclusão de Registro"
            Else // By JPP - 10/12/2008 - 09:30
               @ 23, 13 Radio oRad Var nOpcao Size 90, 09 Items STR0006,; //"01 - Usuários"
                                                                STR0007,; //"02 - Inclusão de Registro"
                                                                STR0117,; //"03 - Retorno RE",;
                                                                STR0118,; //"04 - Alteração RE",;
                                                                STR0119,; //"05 - Cancelamento RE",;
                                                                STR0120 On Change (ValOpcRE(nOpcao)) Of oDlg Pixel //"06 - Retorno Cancelamento RE"
            EndIf
         Else

         /* JPM - possibilitar customização
         @ 23,13 RADIO oRad VAR nOpcao ;
                 SIZE 90,09 ITEMS STR0006,;  // "01 - Usuários"
                                   STR0007,; // "02 - Inclusão de Registro"
                                   STR0074 OF oDlg PIXEL //"03 - Retorno Siscomex"
         */
            oRad := TRadMenu():New( 23,13, aOpcao, bSETGET(nOpcao), oDlg,,,,,,,,90,09,,,,.t.) //JPM 19/08/05
         EndIf

         DEFINE SBUTTON FROM 65+nTam,53 TYPE 1 OF oDlg ACTION (If(ValOpcRE(nOpcao),(nOpcA:=1,oDlg:End()),)) ENABLE // By JPP - 10/12/2008 - 09:30
         DEFINE SBUTTON FROM 65+nTam,86 TYPE 2 OF oDlg ACTION (oDlg:End()) ENABLE

         ACTIVATE MSDIALOG oDlg CENTERED

        IF nOpcA == 0 // Cancel ...
           Exit
        Endif
    Else
	    nOpcao := nOpc
	End If

     Do Case
        Case nOpcao == 1
           aCampos := Array(EEC->(fCount())) // ** By JBJ - 08/04/02
           EECSI101() // Usuarios - Siscomex
           Loop
        Case nOpcao == 2
           cTitulo := cCadastro+STR0012 //" - Inclusão de Registro"
        Case nOpcao == 3
           If lWizardRe
              cInfLer := .T.
           Else
              cInfLer := MsgYesNo(STR0013,STR0014) //"Deseja visualizar informações de leitura ?"###"Vizualização"
           EndIf
           SI100Ret() // Retorno Siscomex
           Loop
        //WFS 28/05/09
        Case nOpcao == ALTERAR_RE
           lAltRe:= .T.
           cTitulo:= STR0001 + " - " + STR0114
           lShowRE:= .F. // usada para não exibir a mensagens de RE já associadas aos itens
        OtherWise //JPM - 19/08/05
           If lAlt_Can_RE // By JPP - 18/12/2008 - 15:00
              /*If nOpcao == 4 // Alteração de RE
                 SI102AltRE()
              ElseIf nOpcao == 5  // Cancelamento de RE nopado por WFS em 28/05/09*/
              If nOpcao == 5  // Cancelamento de RE nopado por WFS em 28/05/09
                 SI102CanRE()
              ElseIf nOpcao == 6  // Retorno do Cancelamento da RE
                 SI102RetCanRe()
              EndIf
           EndIf

           If EasyEntryPoint("EECPSI00")
              ExecBlock("EECPSI00",.F.,.F.,{"DEPOIS_TELA",{},nOpcao})
           Endif

           If ValType(nOpc) == "N" .AND. nOpc > 0
		      EXIT
		   Else
		      Loop
		   End If

     End Case

     SI100Main(nOpcao,cTitulo)

     If ValType(nOpc) == "N" .AND. nOpc > 0
        EXIT
     EndIf
  Enddo

  Select(nAliasOld)

End Sequence
IF SELECT("TRB") <> 0
   TRB->(E_EraseArq(cTempFile))
ENDIF
IF SELECT("TRB1") <> 0
   TRB1->(E_EraseArq(cPedFile,cPedFile2))
ENDIF
Return NIL

/*
Funcao      : SI100Main(nOpc,cTitulo)
Parametros  : nOpc    := Opcao Selecionada
              cTitulo := Titulo da janela
Retorno     : NIL
Objetivos   : Geracao de Dados para o Siscomex
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 15:45
Revisao     :
Obs.        :
*/
// Alterado por Heder M Oliveira - 2/2/2000
Static Function SI100Main(nOpc,cTitulo)

Local oDlg
Local nOpcA := 0
Local bExecAction := {|x| nOpcA := x, oDlg:End() }
Local oMark, aPos
Local cUser,nAgrupa:=0
Local bGera
Local aCpos := { { "WK_FLAG"         ,," "},;
                  ColBrw("EEC_PREEMB","TRB"),;
                  ColBrw("EEC_DTPROC","TRB"),;
                  ColBrw("EEC_LIBSIS","TRB"),;
                  { {|| IF(!Empty(TRB->WK_INFR),STR0015,STR0016)},,STR0017},;  //"Sim"###"Não"###"Forçar"
                  ;//RMD - 17/09/12 - Retirado por problemas claros de performance { {|| If(Empty(TRB->WK_FLAG),(SI100AddPed(.f.),SI100ChgMk(.t.),TRB->WK_PEDIDO),(/*SI100AddPed(.t.),*/SI100ChgMk(.t.),TRB->WK_PEDIDO))},,STR0079}}  //"Pedidos"
                  {{|| TRB->WK_PEDIDO },,STR0079}}  //"Pedidos"
                  //{ {|| IF(!Empty(WK_FLAG),(SI100AddPed(.f.),TRB->WK_PEDIDO),Nil /*SI100ChgMk(.f.)*/)},,"Pedidos"}}

Local bSelAll:={|| If(Empty(TRB->WK_FLAG),If(SI100ShowRe(.t.,.t.),(SI100MarkAll("TRB"),oMark:oBrowse:Refresh()),Nil),;
                   (SI100MarkAll("TRB"),oMark:oBrowse:Refresh()))}

Local aButtons:={}

//RMD - 17/09/12 - Atualiza as works somente no marca/desmarca
Private bAtuWorks := {|| If(Empty(TRB->WK_FLAG),(SI100AddPed(.f.),SI100ChgMk(.t.),TRB->WK_PEDIDO),(/*SI100AddPed(.t.),*/SI100ChgMk(.t.),TRB->WK_PEDIDO))}

If lWizardRE
   bGera := {|| If(WizardRE(nOpc), oDlg:End(),)}
Else
   //WFS 28/05/2009
   //If nOpc == ALTERAR_RE
      //A opção 6 no parâmetro da função SI102AltRE identifica que o agrupamento será por RE (nAgrupa:= 6),
      //dispensando a escolha do agrupamento uma vez que no Siscomex a alteração deverá ser realizada de acordo como foi lançado.
  //    bGera := {|| cUser:= SI100SelUser(oMark), If(!Empty(cUser), (Processa({|| SI102AltRE(cUser, nOpc, 6)})),), oDlg:End()}
  // Else
      bGera := {|| cUser := SI100SelUser(oMark), IF(!Empty(cUser) .And. !Empty(nAgrupa:=SI100MV()),(Processa({|| SI100GeraTxt(cUser,nOpc,nAgrupa) })),), oDlg:End() }
  // EndIf
EndIf

// ** Inclui os botoes na enchoicebar...
If !EECFlags("NOVOEX")
   aAdd(aButtons,{"LBTIK" ,bSelAll,STR0075}) //"Marca/Desmarca Todos"
EndIf
aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/  ,{|| SI100AddProc(oMark)},STR0076})  //"Inclui Processo"
aAdd(aButtons,{"PESQUISA" /*"PESQUISA"*/,{|| SI100PesqProc(oMark)},"Pesquisar"})
aAdd(aButtons,{"EXCLUIR" ,{|| SI100DelProc(oMark)},STR0077}) //"Exclui Processo"
aAdd(aButtons,{"MENURUN" /*"NOVACELULA"*/,{|| SI100ChgMk(.t.),SI100SelPed(),oMark:oBrowse:Refresh()},STR0078})  //"Selecao Pedidos"

If EasyEntryPoint("EECPSI00")      // By JPP - 16/08/2005 - 10:50 - Inclusão do ponto de entrada.
   ExecBlock("EECPSI00",.F.,.F.,{"PE_INICIO",{},0})
Endif

Begin Sequence

   DbSelectArea("TRB")

   //OAP - 08/02/2011
   DbSelectArea("EEC")

   Private lInverte := .f., cMarca := GetMark()

   // RMD - 22/11/2012 - Permite definir se será avaliada a base de dados em ambientes com problemas de performance.
   If !(EasyEntryPoint("EECKEEPFILES") .And. ExecBlock("EECKEEPFILES",.f.,.f.,"EECKEEPFILES")) .Or. MsgYesNo("Deseja verificar se existem processos disponíveis para a geração do RE?", "Aviso")
      Processa({|| SI100GrvTRB(nOpc) })
   EndIf

   TRB->(dbGoTop())

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

      aPos := PosDlg(oDlg)
      aPos[1] := 31//20

      //GFP 25/10/2010
      aCpos := AddCpoUser(aCpos,"EEC","2")

      oMark := MsSelect():New("TRB","WK_FLAG",,aCpos,@lInverte,@cMarca,aPos)
      If EECFlags("NOVOEX")
         oMark:bAval := {|| SI101OneMark("TRB", "WK_FLAG",oMark), Eval(bAtuWorks) } // RMD - 17/09/12
      Else
         oMark:bAval := {|| If(Empty(TRB->WK_FLAG),; // Se o embarque nao estiver marcado exibe msg de confirmacao ..
                            (If(!SI100ShowRe(.t.),;
                                TRB->WK_FLAG:="",TRB->WK_FLAG:=cMarca),; // Se o usuario confirmar, marca o embarque...
                                oMark:oBrowse:Refresh()),;
                         (TRB->WK_FLAG:="",oMark:oBrowse:Refresh()))} // Se o embarque não estiver marcado...
      EndIf

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bGera,bExecAction,,aButtons)

End Sequence

Return NIL

/*
Funcao      : SI100GrvTRB(nOpc)
Parametros  : nOpc := Opcao Selecionada
Retorno     : NIL
Objetivos   : Grava TRB baseado nos dados do EEC
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 16:15
Revisao     :
Obs.        :
*/
Static Function SI100GrvTRB(nOpc)

Local aOrd := SaveOrd("EEC",5)
Local nCont:= 0, i
Local cQuery

Begin Sequence

   ProcRegua(EEC->(LastRec()))
   // THTS - 18/10/2017 - Projeto Temporario no Banco de Dados. O dbZap dentro de transacao ocorria erro. Foi efetuado tratamento no avZap para resolver o problema.
   //TRB->(avzap())
   //TRB1->(avzap())
    avZap("TRB")
    avZap("TRB1")

   lTop:= .F.
   #IfDef TOP
      lTop:= .T.
   #EndIf
   If EECFlags("NOVOEX") .And. lTop

	  If Select("QUERY") > 0
	     QUERY->(dbCloseArea())
	  End If

	 cQuery := "Select DISTINCT EEC.R_E_C_N_O_ AS RECNO "+;
	            "from "+RetSqlName("EEC")+" EEC inner join " + RetSqlName("EE9") + " EE9 on EEC.EEC_PREEMB = EE9.EE9_PREEMB "+;
	            "where "+;
	            " EEC.D_E_L_E_T_ = ' ' AND EE9.D_E_L_E_T_ = ' ' AND "+;
				" EEC.EEC_FILIAL = '" + xFilial("EEC") + "' and EE9.EE9_FILIAL = '"+xFilial("EE9")+"' AND "+;
				" EEC.EEC_STASIS = '" + SI_LS + "' AND "+;
				" EEC.EEC_STATUS NOT IN('Q','*') AND "+;//AAF 01/06/2017 - Ignorar processos devolvidos/cancelados.
				" EE9.EE9_ID = '"+Space(Len(EE9->EE9_ID))+"' AND EE9_SEQRE = '"+Space(Len(EE9->EE9_SEQRE))+"' AND EE9_RE = '"+Space(Len(EE9->EE9_RE))+"' "

	  dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "QUERY", .F., .T.)

	  Do While !QUERY->(EoF())

	     EEC->(dbGoTo(QUERY->RECNO))

	     TRB->(dbAppend())
         AVReplace("EEC","TRB")
         TRB->TRB_ALI_WT:= "EEC"
         TRB->TRB_REC_WT:= EEC->(Recno())

         //RMD - 17/09/12 - Inclui pedidos deste embarque no work de pedidos, retirando a chamada desta função a partir da MsSelect
         SI100AddPed(.t.)
         SI100ChgMk(.t.)

         QUERY->(dbSkip())
	  End Do
   Else
      EEC->(dbSeek(xFilial()+SI_LS))

      While EEC->(!Eof() .And. EEC_FILIAL == xFilial("EEC")) .And.;
            EEC->EEC_STASIS == SI_LS

         IncProc(STR0023+Transf(EEC->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE))) //"Nro. Processo: "
         nCont ++

         TRB->(dbAppend())
         AVReplace("EEC","TRB")
         TRB->TRB_ALI_WT:= "EEC"
         TRB->TRB_REC_WT:= EEC->(Recno())

         //RMD - 17/09/12 - Inclui pedidos deste embarque no work de pedidos, retirando a chamada desta função a partir da MsSelect
         SI100AddPed(.t.)
         SI100ChgMk(.t.)

         EEC->(dbSkip())
      Enddo

	  For i:=nCont To EEC->(LastRec())
         IncProc()
      Next
   End If

End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : SI100MarkAll
Parametros  : cAlias
Retorno     : NIL
Objetivos   : Marca/Desmarca Todos
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 16:32
Revisao     : Jeferson Barros Jr. 04/04/2002 - 14:26
Obs.        : Trabalha de acordo com o alias definido.
*/
Static Function SI100MarkAll(cAlias)

Local cFlag, nRecNo:=0

Begin Sequence
   If Empty(cAlias)
      Break
   EndIf

   cFlag  := IF(!Empty((cAlias)->WK_FLAG),Space(2),cMarca)
   nRecNo := (cAlias)->(RecNo())

   (cAlias)->(dbGotop())

   (cAlias)->(dbEval({|| (cAlias)->WK_FLAG := cFlag},{|| .T. }))

   (cAlias)->(dbGoTo(nRecNo))

End Sequence

Return NIL

/*
Funcao      : SI100AddProc
Parametros  : oMark
Retorno     : NIL
Objetivos   : Inclui Processo
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 16:39
Revisao     :
Obs.        :
*/
Static Function SI100AddProc(oMark)

Local oDlg, cPedido := Space(AVSX3("EEC_PREEMB",AV_TAMANHO))
Local bValid      := {|| NaoVazio(cPedido).And.ExistEmbarq(cPedido) .AND. ValProc(cPedido)}  // DFS - Inclusão do campo "ValProc"
Local nOpcA := 0,nOldArea:=Select()
//DFS - 01/11/12 - Variaveis para validar se há processo marcado.
Local lMarcaTRB:= .T.
Local aOrdTRB:= {}

Begin Sequence
   IF EEC->(Eof() .Or. Bof())
      EEC->(dbGoTop())
   Endif

   DEFINE MSDIALOG oDlg TITLE STR0024+AVSX3("EEC_PREEMB",AV_TITULO) From 9,0 To 18,49 OF oMainWnd //"Seleção de "

      @ 3.4,0.8 SAY AVSX3("EEC_PREEMB",AV_TITULO)+STR0025 //" <F3>"
      @ 4.0,0.8 MSGET cPedido F3 "EEC" SIZE 80,8 VALID Eval(bValid) PICTURE AVSX3("EEC_PREEMB",AV_PICTURE)

   ACTIVATE MSDIALOG oDlg ON INIT ;
     EnchoiceBar(oDlg,{||nOpcA:=1,If(Eval(bValid),oDlg:End(),nOpcA:=0)},;
             {||oDlg:End()}) CENTERED

   IF nOpcA == 0
      Break
   Endif

   If TRB->(dbSeek(cPedido))
      HELP(" ",1,"AVG0005065") //msginfo("Processo já consta na lista","Aviso")
   Else

      If SI100ShowRe(.t.,,@cPedido)

         //DFS - 31/10/12 - Tratamento para não permitir selecionar dois processos ao mesmo tempo para geração de RE
         aOrdTRB:= SaveOrd("TRB")
         TRB->(DbGotop())
         Do While TRB->(!Eof())
            IF !Empty(TRB->WK_FLAG)
               lMarcaTRB:= .F.
               EXIT
            Endif
            TRB->(DbSkip())
         Enddo
         RestOrd(aOrdTRB,.T.)

         TRB->(dbAppend())
         AVReplace("EEC","TRB")
         TRB->WK_INFR := "S"
         //DFS - 01/11/12 - Se encontrar algum pedido marcado, trás o próximo desmarcado.
         If lMarcaTRB
            TRB->WK_FLAG := cMarca
         Else
            TRB->WK_FLAG := ""
         Endif
         TRB->TRB_ALI_WT:= "EEC"
         TRB->TRB_REC_WT:= EEC->(Recno())
    //     TRB->WK_PEDIDO:="Todos"

         // ** By JBJ - 04/04/02 - Inclui pedidos deste embarque no work de pedidos
         SI100AddPed(.t.)
         //RMD - 17/09/12 - Inclui pedidos deste embarque no work de pedidos, retirando a chamada desta função a partir da MsSelect
		 SI101OneMark("TRB", "WK_FLAG",oMark)
		 Eval(bAtuWorks)

      Else
        If(!lInclui,TRB->(DbDelete()),Nil)
      EndIf

   Endif

   TRB->(DbGoTop())
   oMark:oBrowse:Refresh()
End Sequence

Return NIL

Function SI100PesqProc(oMark)

Local oDlg, cPedido := Space(AVSX3("EEC_PREEMB",AV_TAMANHO))
Local bValid      := {|| NaoVazio(cPedido).And.ExistEmbarq(cPedido)}
Local nOpcA := 0,nOldArea:=Select()
Local bOk := {||nOpcA:=1,If(Eval(bValid),oDlg:End(),nOpcA:=0)}

Begin Sequence
   IF EEC->(Eof() .Or. Bof())
      EEC->(dbGoTop())
   Endif

   DEFINE MSDIALOG oDlg TITLE STR0024+AVSX3("EEC_PREEMB",AV_TITULO) From 9,0 To 18,45 OF oMainWnd //"Seleção de "

      @ 1.4,0.8 SAY AVSX3("EEC_PREEMB",AV_TITULO)+STR0025 //" <F3>"
      @ 2.4,1.2 MSGET cPedido F3 "EEC" SIZE 80,8 VALID Eval(bValid) PICTURE AVSX3("EEC_PREEMB",AV_PICTURE)

   ACTIVATE MSDIALOG oDlg ON INIT ;
     EnchoiceBar(oDlg,bOk,;
             {||oDlg:End()}) CENTERED

   IF nOpcA == 0
      Break
   Endif

   If !TRB->(dbSeek(cPedido))
      MsgInfo("Embarque não disponível para criação de novo lote de geração de RE")
   EndIf

   oMark:oBrowse:Refresh()
End Sequence

Return NIL

/*
Funcao      : SI100DelProc
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Exclui Processo
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 16:40
Revisao     :
Obs.        :
*/
Static Function SI100DelProc(oMark)

Local cPreemb := TRB->EEC_PREEMB
Local aAreaEEC := EEC->(GetArea())

Begin Sequence
   IF TRB->(EOF()).OR. TRB->(BOF())
      HELP(" ",1,"AVG0005066") //MSGINFO("Não há registros selecionados para exclusão!","Aviso")
      Break
   Endif
   IF MsgYesNo(STR0026+Transf(TRB->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE)),STR0003) //"Confirma Exclusão do Processo Nro. "###"Aviso"
      
      // Os processos selecionados Aguardando liberacao para siscomex, serão gravados no array aProcRec
      // para posteriormente serem efetivar o status após fechar a tela. EJA - 25/11/2017
      EEC->(dbSetOrder(1))
      If EEC->(dbSeek(xFilial('EEC') + cPreemb))
        aAdd(aProcRec, EEC->(Recno()))
      EndIf

      RestArea(aAreaEEC)
      
      TRB->(dbDelete())

      // ** By JBJ - 05/04/02 - Deleta os pedidos referentes a este embarque no TRB1
      SI100DelPed()

      TRB->(dbSkip(-1))
      IF TRB->(Bof())
         TRB->(dbGoTop())
      Endif

      oMark:oBrowse:Refresh()
   Endif

End Sequence

Return NIL

/*
Funcao      : SI100SelUser
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Selecao do Usuario
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 17:17
Revisao     :
Obs.        :
*/
Static Function SI100SelUser(oMark)

Local cUser := "", oDlg, nOpcA := 0
//Local cMarca := GetMark() // ** By JBJ -08/04/2002

Local aOrd := SaveOrd("EEP",1)
Local aCpos := ArrayBrowse("EEP")

Local cFiltro := "EEP->EEP_FILIAL == '"+xFilial("EEP")+"'"
Local nAreaOld := Select()

//Local nRec := TRB->(RecNo())
//Local lMarcado := .f.

Local oBrw

Begin Sequence

   /*
   AMS - Substituida a condição abaixo pela função IsMarcado.

   TRB->(dbGoTop())
   TRB->(dbEval({||lMarcado:=.t.},{||!Empty(WK_FLAG)},{||!lMarcado}))
   TRB->(dbGoTo(nRec))

   IF !lMarcado
      HELP(" ",1,"AVG0005067") //MsgInfo("Não há registros marcado para a Geração de Arquivos !","Aviso")
      Break
   Endif
   */
   If !IsMarcado("TRB", "WK_FLAG")
      Help(" ", 1, "AVG0005067") //"Não há registros marcado para a Geração de Arquivos !"
      Break
   EndIf

   EEP->(dbSeek(xFilial()))

   dbSelectArea("EEP")
   SET FILTER TO &cFiltro

   DEFINE MSDIALOG oDlg TITLE STR0027  FROM 9,0 TO 25,45 OF oMainWnd //"Seleção de Usuário"

      //GFP 25/10/2010
      aCpos := AddCpoUser(aCpos,"EEP","2")

      oBrw := MsSelect():New("EEP",,,aCpos,.f.,@cMarca,{3,2,105,178})
      oBrw:bAval := {|| nOpcA := 1 }

      DEFINE SBUTTON FROM 107,110 TYPE 1 OF oDlg ACTION (nOpcA:=1,oDlg:End()) ENABLE
      DEFINE SBUTTON FROM 107,143 TYPE 2 OF oDlg ACTION (oDlg:End()) ENABLE

   ACTIVATE MSDIALOG oDlg CENTERED

   IF nOpcA == 1
      cUser := EEP->EEP_CNPJ
   Endif

End Sequence

dbSelectArea("EEP")
SET FILTER TO

RestOrd(aOrd)
Select(nAreaOld)
oMark:oBrowse:Refresh()

TRB->(dbGoTop())

Return cUser
/*
Funcao      : SI100SelAgru
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Selecao do Agrupamento
Autor       : HEDER M OLIVEIRA
Data/Hora   : 02/02/00 10:56
Revisao     :
Obs.        :
*/
Static Function SI100SelAgru()

Local cAGRUPA := "", oDlg, nOpcA := 0,nOPCAO:=1
Local nAreaOld := Select()

Private aRad := {}
Private nLinBtn   := 80
Private nLenPanel := 75
Private nLenDlg   := 22

If lFIELD_RC
   aRad := {STR0030,;//"01 - Item"
            STR0031,;//"02 - N.C.M. + Item + Preço"
            STR0032,;//"03 - N.C.M. + Preço"
            STR0033,;//"04 - N.C.M."
            STR0034} //"05 - Item Por RC"
Else
   aRad := {STR0030,; //"01 - Item"
            STR0031,; //"02 - N.C.M. + Item + Preço"
            STR0032,; //"03 - N.C.M. + Preço"
            STR0033}  //"04 - N.C.M."
EndIf

If EasyEntryPoint("EECPSI00")
   ExecBlock("EECPSI00",.F.,.F.,{"TA",{},0})
Endif

Begin Sequence

   DEFINE MSDIALOG oDlg TITLE STR0028 FROM 9,0 TO nLenDlg,50 OF oMainWnd //"Seleção de Forma de Agrupamento"
      @ 10,5 TO nLenPanel,180 LABEL STR0029 OF oDlg PIXEL //"Agrupamentos:"

      /*
      IF lFIELD_RC
         @ 23,13 RADIO oRad VAR nOpcao ;
                 SIZE 80,09 ITEMS STR0030,; //"01 - Item"
                                  STR0031,; //"02 - N.C.M. + Item + Preço"
                                  STR0032,; //"03 - N.C.M. + Preço"
                                  STR0033,; //"04 - N.C.M."
                                  STR0034 OF oDlg PIXEL //"05 - Item Por RC"
      ELSE
         @ 23,13 RADIO oRad VAR nOpcao ;
                       SIZE 80,09 ITEMS STR0030,; //"01 - Item"
                                        STR0031,; //"02 - N.C.M. + Item + Preço"
                                        STR0032,; //"03 - N.C.M. + Preço"
                                        STR0033 OF oDlg PIXEL //"04 - N.C.M."
      ENDIF
      */
      // By OMJ - 07/12/2004 - Para incluir opçoes de agrupamento
      oRad := TRadMenu():New(23,13,aRad,bSETGET(nOpcao),oDlg,,,,,,,,80,09,,,,.T.)

      DEFINE SBUTTON FROM nLinBtn,180-60 TYPE 1 OF oDlg ACTION (nOpcA:=1,oDlg:End()) ENABLE
      DEFINE SBUTTON FROM nLinBtn,180-27 TYPE 2 OF oDlg ACTION (oDlg:End()) ENABLE

  ACTIVATE MSDIALOG oDlg CENTERED
  IF nOpcA == 0 .OR. EECFlags("NOVOEX") .AND. nOpcA == 1 // Cancel ...
     nOPCAO:=0
     BREAK
  Endif
End Sequence
Select(nAreaOld)

Return nOPCAO

/*
Funcao      : SI100GeraTxt
Parametros  : cUser := Identificacao do Usuario do Siscomex
              nOpc  := 1 - Inclusao
              nAgrupa := forma de agrupar os itens
Retorno     : .T. = Arquivo(s) *.INC gerados.
              .F. = Não houve geração de arquivos.
Objetivos   : Gera Txt
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 17:07
Revisao     : Jeferson Barros Jr. - 03/10/01 - 16:51
Obs.        :
*/
Function SI100GeraTxt(cUser,nOpc,nAgrupa)

Local nSeq := 0
Local cDir := EasyGParam("MV_AVG0002") // Diretorio para geracao dos arquivos
Local cFiles := "", cFile  := ""
Local hFile
Local cExt   := "."
Local nAliasOld := Select()
Local cFileTemp //Local cFileTemp := E_CriaTrab("EE9",aSemSX3,"Work")
LOCAL aAPOIO := {,.T.}, aRC := {},cOBS := "",X

Local cMemoObs

// ** By JBJ - 18/03/2002 - Tela de edição para os dados do siscomex
Local lEdit:=GetNewPar("MV_AVG0020",.F.)

// AMS - 14/05/2004 às 11:54. Declaração da variavel lTabConvUnid que indica se existe a Tab.Conversão de Unidades.
//Local lTabConvUnid := Select("SJ5") <> 0 //Nopado por ER - 19/02/2008. A verificação será realizada após a declaração das variáveis locais.
Local lTabConvUnid := .F.

Local cErrorLog    := ""

// AMS - 10/05/2005 às 14:37.
Local lRet     := .F., lRetSeek
Local aSchema  := {}
Local nSchema  := 0
Local nCNPJ    := 0
Local nRE      := 0
//OAP - 03/02/2011
Local NumAux := 0

PRIVATE aEE9 := {}, lOBS := .T.
Private lEEFSCC     := .F. // MPG - 03/01/2018 - criado variáveis para validação de cobertura cambial 
Private cRC, cEnqCod, lIntEDC:=EasyGParam("MV_EEC_EDC",,.F.) // ** Integracao ao EDC ...
Private cRV // ** By JBJ - 24/07/02 - 15:45
Private cOldAto
Private aEnquadra := {} // ** By OMJ - 06/02/03 - 15:09 ...
Private aEE9AgSufixo := {}
Private nSeqSisc := 0  // GFP - 28/08/2014

//ER - 19/02/2008
ChkFile("SJ5")
If Select("SJ5") > 0
   lTabConvUnid := .T.
EndIf

If nOpc = INCLUIR_RE
   cExt += "INC"
EndIf

aCampos := Array(EE9->(fCount())) // ** By JBJ - 08/04/2002
aSEMSX3 := CRIAESTRU(aCAMPOS,@aHEADER,"EE9")
X := ASCAN(aSEMSX3,{|X| X[1] = "EE9_UNIDAD"})
IF X <> 0
   aSEMSX3[X,3] := 20  // DEIXA COM O TAMANHO MAXIMO DO SISCOMEX
ENDIF

// by CAF 14/08/2003 - Maximo de decimais no SISCOMEX para QTDE = 5
x := aScan(aSemSX3,{|x| x[1] = "EE9_SLDINI"})
IF x > 0
   aSemSX3[X,3] := 18
   aSemSX3[x,4] := 5
Endif

AADD(aSEMSX3,{"WK_PRCTOT" ,"N",15,2}) ; AADD(aSEMSX3,{"WK_SLDINI"   ,"N",18,5})
AADD(aSEMSX3,{"WK_CGC1"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC2"     ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM1"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM2"     ,"C",10,0})
AADD(aSEMSX3,{"WK_UF1"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF2"      ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO1"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO2"     ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD1"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD2"     ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL1"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL2"     ,"N",15,2})
AADD(aSEMSX3,{"WK_TPCGC1","C",4,0})   ; AADD(aSEMSX3,{"WK_TPCGC2"  ,"C",4,0}) // By JPP - 14/11/2007 - 14:00
AADD(aSEMSX3,{"WK_CGC3"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC4"     ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM3"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM4"     ,"C",10,0})
AADD(aSEMSX3,{"WK_UF3"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF4"      ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO3"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO4"     ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD3"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD4"     ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL3"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL4"     ,"N",15,2})
AADD(aSEMSX3,{"WK_TPCGC3","C",4,0})   ; AADD(aSEMSX3,{"WK_TPCGC4"  ,"C",4,0}) // By JPP - 14/11/2007 - 14:00
AADD(aSEMSX3,{"WK_CGC5"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC6"     ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM5"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM6"     ,"C",10,0})
AADD(aSEMSX3,{"WK_UF5"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF6"      ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO5"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO6"     ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD5"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD6"     ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL5"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL6"     ,"N",15,2})
AADD(aSEMSX3,{"WK_TPCGC5","C",4,0})   ; AADD(aSEMSX3,{"WK_TPCGC6"  ,"C",4,0}) // By JPP - 14/11/2007 - 14:00
AADD(aSEMSX3,{"WK_CGC7"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC8"     ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM7"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM8"     ,"C",10,0})
AADD(aSEMSX3,{"WK_UF7"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF8"      ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO7"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO8"     ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD7"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD8"     ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL7"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL8"     ,"N",15,2})
AADD(aSEMSX3,{"WK_TPCGC7","C",4,0})   ; AADD(aSEMSX3,{"WK_TPCGC8"  ,"C",4,0}) // By JPP - 14/11/2007 - 14:00
AADD(aSEMSX3,{"WK_CGC9"   ,"C",14,0}) ; AADD(aSEMSX3,{"WK_CGC10"    ,"C",14,0})
AADD(aSEMSX3,{"WK_NBM9"   ,"C",10,0}) ; AADD(aSEMSX3,{"WK_NBM10" ,"C",10,0})
AADD(aSEMSX3,{"WK_UF9"    ,"C",02,0}) ; AADD(aSEMSX3,{"WK_UF10"     ,"C",02,0})
AADD(aSEMSX3,{"WK_ATO9"   ,"C",13,0}) ; AADD(aSEMSX3,{"WK_ATO10"    ,"C",13,0})
AADD(aSEMSX3,{"WK_QTD9"   ,"N",15,3}) ; AADD(aSEMSX3,{"WK_QTD10"    ,"N",15,3})
AADD(aSEMSX3,{"WK_VAL9"   ,"N",15,2}) ; AADD(aSEMSX3,{"WK_VAL10"    ,"N",15,2})
AADD(aSEMSX3,{"WK_TPCGC9" ,"C",4,0})  ; AADD(aSEMSX3,{"WK_TPCGC10"  ,"C",4,0}) // By JPP - 14/11/2007 - 14:00
AADD(aSEMSX3,{"WK_PERCOM" ,"N",6,2})  // by CAF 27/07/2001 Percentual comissao por item
AADD(aSEMSX3,{"WK_TEMOBS" ,"C",01,0}) ; AADD(aSEMSX3,{"WK_OBS1"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS2"   ,"C",75,0}) ; AADD(aSEMSX3,{"WK_OBS3"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS4"   ,"C",75,0}) ; AADD(aSEMSX3,{"WK_OBS5"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS6"   ,"C",75,0}) ; AADD(aSEMSX3,{"WK_OBS7"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS8"   ,"C",75,0}) ; AADD(aSEMSX3,{"WK_OBS9"   ,"C",75,0})
AADD(aSEMSX3,{"WK_OBS10"  ,"C",75,0}) ; AADD(aSEMSX3,{"WK_ENQCOD" ,"C",AvSX3("EEC_ENQCOD",AV_TAMANHO),0})
// By JPP - 14/11/2007 - 14:00
//TRP - 29/01/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
//cFileTemp := E_CriaTrab("EE9",aSemSX3,"Work")
aCampos:={}

//WFS 28/05/2009: Quando for alteração de RE, os campos abaixo serão usados na função SI102AltRE()
If nOpc == ALTERAR_RE
   AADD(aSEMSX3,{"WK_FLAG"   ,"C",02,2})
   AADD(aSEMSX3,{"WK_RE"     ,"C",12,0})
EndIF

cFileTemp := EECCriaTrab(,aSemSX3,"Work")

Begin Sequence
   /// SE FOR POR RC, VERIFICA SE TODOS OS ITENS TEM RC PREENCHIDO
   aAPOIO[1] := EE9->(INDEXORD())

      TRB->(DBGOTOP())

      While !TRB->(Eof())

         If !Empty(TRB->WK_FLAG)


            EE9->(dbSetOrder(3))
            EE9->(dbSeek(xFilial()+TRB->EEC_PREEMB))

            While EE9->(!Eof() .and. EE9_FILIAL == xFilial() .and. EE9_PREEMB == TRB->EEC_PREEMB)

               /*
               Rotina de consistencia para não permitir a geração de RE quando a unidade de medida do item
                             não estiver cadastrada na tabela de conversão para unidade de medida.
               Autor       : Alexsander Martins dos Santos
               Data e Hora : 14/05/2004 às 13:46.
               */
			   If EasyGParam("MV_AVG0065",, .T.) .and. lTabConvUnid

                  If EE9->(!Empty(EE9_FABR+EE9_FALOJA) .or. !Empty(EE9_ATOCON) .or. EE9_UNIDAD <> EasyGParam("MV_AVG0031",, "."))

                      //TRP - 09/09/2011 - Ponto de Entrada para atualizar a conversão de unidade de medida na tabela SJ5.
                      If EasyEntryPoint("EECSI100")
                         ExecBlock("EECSI100",.F.,.F.,"UNIDADE")
                      EndIf

                     SYD->(dbSetOrder(1))
                     SYD->(dbSeek(xFilial()+EE9->EE9_POSIPI))

                     // BAK - 02/05/2011 - Alteração para verificar se está compilado a função EasyConvQt(), caso contrario realiza o processo anterior
                     If lEasyConvQt
                        EasyConvQt(EE9->EE9_COD_I,GetEE9Qtds(),GetSYDUnid(SYD->YD_UNID, GetEE9Qtds()),.F.,@oObErroNEx)
                     ElseIf AVTransUnid(EE9->EE9_UNIDAD, SYD->YD_UNID, EE9->EE9_COD_I, EE9->EE9_SLDINI, .T.) = Nil
					    cErrorLog += STR0105 + AllTrim(EE9->EE9_SEQEMB) + STR0106 + AllTrim(EE9->EE9_PREEMB) + " " +; // O item com a sequencia ### do embarque ###
					                 STR0107 + EE9->EE9_UNIDAD + STR0108 + SYD->YD_UNID + " " +;                      // possui as unidades de medidas (De) ### (Para) ###
					                 STR0109 + ENTER                                                                  // não cadastrados na tabela de conversão de unidade de medidas.
                     EndIf

                  EndIf

                  //If EE9->(FieldPos("EE9_UNPES")) > 0 .and. !Empty(Work->EE9_UNPES) .and. EasyGParam("MV_AVG0031",, ".") <> "."
                  If EE9->(FieldPos("EE9_UNPES")) > 0 .and. !Empty(EE9->EE9_UNPES) .and. EasyGParam("MV_AVG0031",, ".") <> "." // By JPP - O sistema deve referir-se ao campo EE9->EE9_UNPES e não ao campo WORK->EE9_UNPES.

                     //BAK - 02/05/2011 - Alteração para verificar se está compilado a função EasyConvQt(), caso contrario realiza o processo anterior
                     If lEasyConvQt
                        EasyConvQt(EE9->EE9_COD_I,GetEE9Qtds(),GetSYDUnid(EasyGParam("MV_AVG0031"), GetEE9Qtds()),.F.,@oObErroNEx)
                     ElseIf AVTransUnid(EE9->EE9_UNPES, EasyGParam("MV_AVG0031"), EE9->EE9_COD_I, EE9->EE9_PSLQTO, .T.) = Nil
					    cErrorLog += STR0105 + AllTrim(EE9->EE9_SEQEMB) + STR0106 + AllTrim(EE9->EE9_PREEMB) + " " +;   // O item com a sequencia ### do embarque ###
					                 STR0107 + EE9->EE9_UNPES + STR0108 + EasyGParam("MV_AVG0031") + " " +;                  // possui as unidades de medidas (De) ### (Para) ###
					                 STR0109 + ENTER                                                                    // não cadastrados na tabela de conversão de unidade de medidas.
                     EndIf

                  EndIf

			   EndIf
			   //Final da consistencia.

               If nAgrupa = 5

                  // ** By JBJ 08/04/2002 - Gera apenas os pedidos marcados...
                  TRB1->(DbSetOrder(1))
                  TRB1->(DbSeek(EE9->EE9_PEDIDO+EE9->EE9_RE))

                  If Empty(TRB1->WK_FLAG)
                     EE9->(DbSkip())
                     Loop
                  EndIf

                  IF EMPTY(EE9->EE9_RC)
                     AADD(aRC,STR0035+TRB->EEC_PREEMB+STR0036+EE9->EE9_COD_I) //"Processo: "###" Item: "
                  ENDIF

               EndIf

               EE9->(dbSkip())

            End

         EndIf

         TRB->(DBSKIP())

      End

      IF LEN(aRC) > 0
         cOBS := STR0037+ENTER //"Os Seguintes Itens Estao Sem RC:"
         FOR X := 1 TO LEN(aRC)
             cOBS := cOBS+aRC[X]+ENTER
         NEXT
         MSGINFO(cOBS,STR0038) //"Atenção"
         BREAK
      ENDIF

      If Len(cErrorLog) > 0
         MsgInfo("Não foram encontrados conversões de medida para itens do embarque.", "Atenção")
         EECView(cErrorLog, "Inconsistência de dados", "Itens")
         Break
      EndIf

      EE9->(DBSETORDER(aAPOIO[1]))

//   ENDIF

   ProcRegua(TRB->(LastRec())+1)

   cDir := AllTrim(cDir)
   cDir := cDir+if(Right(cDir,1)=="\","","\")

   IncProc(STR0039+AVSX3("EEC_PREEMB",AV_TITULO)+" "+Transf(TRB->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE)))    //"Gerando "
   /*A função CNPJUniq retorna os CNPJ's unificados com base nos embarques selecionados*/
   aCNPJ := CNPJUniq()
   TRB->(dbGoTop())

   DO While TRB->(!Eof())
      IncProc()

	  Private aRegREs := {}

      aEnquadra := {} // ** By OMJ - 06/02/03 - 15:09 ...

      IF Empty(TRB->WK_FLAG)
         TRB->(dbSkip())
         Loop
      Endif

	  If EECFlags("NOVOEX")
	     cCond := "EE9_ID == '"+Space(Len(EE9->EE9_ID))+"' .AND. EE9_RE = '"+Space(Len(EE9->EE9_RE))+"'"

	     EE9->(dbSetFilter(&("{|| "+cCond+" }"), cCOnd))

		 nOrdEE9 := EE9->(IndexOrd())
		 EE9->(dbSetOrder(3))
		 lRetSeek := EE9->(dbSeek(xFilial("EE9")+TRB->EEC_PREEMB))
		 EE9->(dbSetOrder(nOrdEE9))

		 If !lRetSeek
		 	If TRB->EEC_STASIS == SI_SF
		  		cMsg := "O embarque " + AllTrim(TRB->EEC_PREEMB) + " encontra-se registrado no Siscomex." + ENTER
		  		cMsg += "Esta operação irá gerar um novo arquivo de integração para alteração do RE, exigindo o reenvio ao Siscomex." + ENTER
		  		cMsg += "Deseja prosseguir?"

		  		If !MsgYesNo(cMsg, STR0003 + " - Processo Finalizado")
			  	   	Break
		  		Else
		  			EE9->(DbClearFilter())
		  		EndIf
		 	Else
			    cMsg := "Não há itens para geração de RE no processo "+AllTrim(TRB->EEC_PREEMB) + ENTER
				cMsg += "Os itens já possuem RE ou estão aguardando retorno do Siscomex em outro Lote deste embarque." + ENTER
				cMsg += "Para alterar os registros no SISCOMEX é necessário que todos os itens possuam RE."
			    MsgStop(cMsg)
				Break
		 	EndIf
		 EndIf

	  EndIf

      /*
      AMS - 19/05/2005. Recebe a estrutura de quebra dos itens para geração da R.E.
      */
      aSchema := RESchema(TRB->EEC_PREEMB)
	  Private nSeqNovoEx := 1
	  nSeqSisc := 0  // GFP - 28/08/2014
      For nSchema := 1 To Len(aSchema) //Quebra por CNPJ.
         Private aREBase := {} //WFS - 25/09/2012 - Alterado para fora do laço (aSchema[nSchema])
         Private aMercsRE   := {}

         For nRE := 2 To Len(aSchema[nSchema]) //Quebra por R.E.

            /*
            Monta a work "Work" com os itens.
            */
            If !SI100GrvTemp(TRB->EEC_PREEMB, nAgrupa, TRB->WK_INFR, aSchema[nSchema][1], aSchema[nSchema][nRE][1])
            //IF ! SI100GrvTemp(TRB->EEC_PREEMB,nAgrupa,TRB->WK_INFR)
               MsgInfo(STR0040+ AVSX3("EEC_PREEMB",AV_TITULO)+" "+Transf(TRB->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE))+STR0041,STR0042) //"Não há itens do "###" para ser enviado !"###"Informação"
               TRB->(dbSkip())
               Loop
            Endif

            //By OMJ - 07/12/2004
            IF EasyEntryPoint("EECPSI00")
               ExecBlock("EECPSI00",.F.,.F.,{"WA",{},nAgrupa})
            Endif

            //WFS 28/05/09
            //Quando for alteração de RE, os tratamentos de geração do arquivo TXT serão realizados
            //no programa EECSI102.PRW
            If nOpc == ALTERAR_RE
               //Chama a função para a seleção dos itens e criação dos arquivos ea??????.inc
               SI102SelItem(@cFile, @cFiles, cUser)
            Else//If !EECFlags("NOVOEX")
               aSort(aMercsRE,,,{|X,Y| X[1]<Y[1]}) //DFS - 13/04/12 - Alterado local do tratamento para que, permita que os itens de um array sejam ordenados corretamente
               //LGS-27/05/14-Exibir tela de edição dos itens quando o agrupamento for feito por item.
               IF /*nAgrupa <> 1 .AND.*/ nAgrupa <> 5 .Or. lEdit // ** By JBJ - 18/03/2002 - Tela de edição de dados para o Siscomex.
                  //OAP - Adeuqção para o tratamento de erros na geração de um RE.
                  If (EECFlags("NOVOEX").AND. lValidN_EX) .AND. lEasyConvQt
                     //wfs 11/2012: exibe a mensagem apenas uma vez
                     If nRE == Len(aSchema[nSchema])
                        SI100FErro()

                        If Len(oObErroNEx:aWarning) > 0
                           oObErroNEx:ShowErrors(.T.)
                           // BAK - 03/05/2011
                           If Len(oObErroNEx:aWarning) > 0
                              cErrosNEX := "Possíveis Erros Encontrados na Geração do Lote:" + ENTER + ENTER
                           EndIf
                           For NumAux := 1 To Len(oObErroNEx:aWarning)
                              cErrosNEX := cErrosNEX +"- "+Alltrim(oObErroNEx:aWarning[NumAux])+ ENTER
                           Next NumAux
                        EndIf
                     EndIf
                  EndIf
                  //IF ! SI100EditTemp()
                  //Retirado tratamento já que não havia a chamada deste parâmetro na função -> aSchema[nSchema][1])

                  //DFS - 28/02/13 - Só chama a tela se for para adicionar vários anexos no mesmo RE
       	          If lAddAnexos .AND. Len(aSchema[nSchema]) == nRE  // GFP - 28/08/2014
                     IF ! SI100EditTemp(nAgrupa) //DFS - 16/07/12 - Inclusão de parâmetro para retirar o campo codigo do item quando utilizar o agrupamento por NCM
                        Loop//Break
                     Endif
                     //DFS - 15/04/13 - Caso passe a primeira vez, retorna .F. para variável, visto que, não deve abrir várias vezes a tela de edição de itens.
                     lAddAnexos := .F.
                  Endif
               Endif

               lObs:=.T.

               //SI100GrvEE9(TRB->EEC_PREEMB,nAgrupa)
               /*
               Atualiza o status dos itens do Embarque através dos itens da Work.
               */
               SI100GrvEE9(TRB->EEC_PREEMB, nAgrupa, aSchema[nSchema][1])

               aRegRes := {} //DFS - 31/05/2012 - Inclusão para não duplicar os itens na gravação do RE.

               //LCS 04/05/2001
               Work->(DBGOTOP())
               DO WHILE ! Work->(EOF())

                  cEnqCod := Work->WK_ENQCOD
                  cRC     := Work->EE9_RC
                  cOldAto := Work->EE9_ATOCON

                  // ** By JBJ - 24/07/02 - 15:47 ...
                  If lField_RV
                     cRV := Work->EE9_RV
                  EndIf

                  If lCatCot   // GFP - 25/07/2012 - Categoria de Cota
                     cCatCota  := Work->EE9_CATCOT
                  EndIf

				  nSeq := EasyGParam("MV_AVG0001") // Proxima seq.de arq. a ser gerado para o Siscomex

				  If !EECFlags("NOVOEX")
                     SetMv("MV_AVG0001",nSeq+1)
                     cFile := "EE"+Padl(nSeq,6,"0")+cExt

                     SI100CriaTxt(TRB->EEC_PREEMB, cUser, cDir, cFile, nAgrupa, aSchema[nSchema][1])

                     nPosCNPJ := aScan(aCNPJ, {|x| x[1] == aSchema[nSchema][1]})
                     aAdd(aCNPJ[nPosCNPJ][2], cFile)

                     cFiles += cFile+CRLF
                  Else
                     SI100CriaTxt(TRB->EEC_PREEMB, cUser, cDir, cFile, nAgrupa, aSchema[nSchema][1])
   			         WORK->(dbSkip())
				  EndIf

               ENDDO
            EndIf
         Next

      Next

	  If EECFlags("NOVOEX")
	     If !lAddAnexos
	        aSort(aMercsRE,,,{|X,Y| X[1]<Y[1]})

	       //DFS - 15/04/13 - Retirado tratamento para abrir novamente a tela de edição de itens.
           /* IF nAgrupa <> 1 .AND. nAgrupa <> 5 .Or. lEdit // ** By JBJ - 18/03/2002 - Tela de edição de dados para o Siscomex.
               //IF ! SI100EditTemp()
               IF ! SI100EditTemp(nAgrupa) //DFS - 16/07/12 - Inclusão de parâmetro para retirar o campo codigo do item quando utilizar o agrupamento por NCM
                  Break
               Endif
            Endif */

            lObs:=.T.
            SI100GrvEE9(TRB->EEC_PREEMB, nAgrupa)

            aRegRes := {} //DFS - 31/05/2012 - Inclusão para não duplicar os itens na gravação do RE.

            Work->(DBGOTOP())
            DO WHILE ! Work->(EOF())
               cEnqCod := Work->WK_ENQCOD
               cRC     := Work->EE9_RC
               cOldAto := Work->EE9_ATOCON

               // ** By JBJ - 24/07/02 - 15:47 ...
               If lField_RV
                  cRV := Work->EE9_RV
               EndIf

               If lCatCot   // GFP - 25/07/2012 - Categoria de Cota
                  cCatCota  := Work->EE9_CATCOT
               EndIf

               nSeq    := EasyGParam("MV_AVG0001") // Proxima seq.de arq. a ser gerado para o Siscomex

               //SI100CriaTxt(TRB->EEC_PREEMB,cUser,cDir,cFile,nAgrupa)
               SI100CriaTxt(TRB->EEC_PREEMB, cUser, cDir, cFile, nAgrupa)//, aSchema[nSchema][1])

			   If !EECFlags("NOVOEX")
                  nPosCNPJ := aScan(aCNPJ, {|x| x[1] == aSchema[nSchema][1]})
                  aAdd(aCNPJ[nPosCNPJ][2], cFile)
               Else
                  Work->(dbSkip())
               EndIf

               cFiles += cFile+CRLF
            ENDDO
	     EndIf

		 If Len(aRegREs) > 0
   		    SI100GrvREs(aRegREs)
         Else
            break
         EndIf
	  End If

      TRB->(dbSkip())
   Enddo
   //WFS 29/05/09
   //Retorna para a função SI102AltRE()
   If nOpc == ALTERAR_RE
      If !Empty(cFiles)
         cFiles += "####eof#####" + ENTER
         If File(cDir + "EECTOT.AVG")
            FErase(cDir + "EECTOT.AVG")
         Endif
         hFile:= EasyCreateFile(cDir + "EECTOT.AVG")
         FWrite(hFile, cFiles, Len(cFiles))
         FClose(hFile)
         MsgInfo(STR0065, STR0003) //"Arquivos gerados com sucesso!"###"Aviso"
         Return {.T., cFileTemp}
      EndIf
      If lWizardRe
         Return {lRet, cFileTemp}
      EndIf
   EndIf

   If !lWizardRe

      // Alterado por Heder M Oliveira - 2/15/2000
      IF ( EMPTY(cFILES) )
         BREAK
      ENDIF
      cFILES += "####eof#####"+CRLF
      IF File(cDir+"EECTOT.AVG")
         fErase(cDir+"EECTOT.AVG")
      Endif

      hFile := EasyCreateFile(cDir+"EECTOT.AVG")

      fWrite(hFile,cFiles,Len(cFiles))

      fClose(hFile)

      MsgInfo(STR0065,STR0003) //"Arquivos gerados com sucesso !"###"Aviso"
   EndIf

   lRet := .T.

End Sequence

If EECFlags("NOVOEX")
   EE9->(dbClearFilter())
EndIf

Work->(E_EraseArq(cFileTemp))
Select(nAliasOld)

TRB->(dbGotop())

Return(lRet)

/*
Funcao      : SI100CriaTxt
Parametros  : cProc := Nro. do Processo de Exportacao
              cUser := Identificacao do Usuario do Siscomex
              cDir  := Diretorio
              cFile := Nome do Arquivo a ser Gerado
              nAgrupa := forma de agrupar os itens
              cCNPJ := CNPJ da unidade exportadora.
Retorno     : NIL
Objetivos   : Cria Txt
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/12/1999 17:07
Revisao     :
Obs.        :
*/
// Alterado por Heder M Oliveira - 12/28/1999
Static Function SI100CriaTxt(cProc, cUser, cDir, cFile, nAgrupa, cCNPJ)

Local aOrd := SaveOrd({"EEP","EEC","EE9","SYD","SY6"})

Local hFile := 0,nCONT
// by CAF 27/01/05 - Local cBuffer := ""

Local cObs := "", cPeriod := "", cNcm
Local lP_RC

Local nTotPed:=0,nVlCalc:=0,nAvista:=0,nParcel:=0,nVlCons:=0,nFincia:=EEC->EEC_FINCIA,cFileItem,nSize:=0,;
      nLidos:=0, nVlAux:=0, nPerc:=0, nDias:=0, nSoma:=0, nNroParc :=0, nPeriodo:=0, nVlSemCob:=0

Local nTotCondVen:=0,nTotLocEmb:=0

Local cAtoCon:= Work->EE9_ATOCON
Local nx:=0, nIEnq:=0, z:=0, j, k, i
Local lDrawBack

Local nParcs := 0
Local cFormAux := ""
Local nEW0Valor := 0

Local nValorFOB := 0

//Eduardo/ WFS - 23/09/2008 - variável que informará se existem dados do Fabricante para os itens de embarque - EYU
Private lExistEYU := .F.

Private cKSA2 := ""  //TRP - 23/12/2011 - Private para mudar o Fornecedor/Exportador em customizações.
Private cBuffer := "" // by CAF 27/01/05 - Definido como private para utilização no ponto de entrada.
Private aRegsRE := {}

Private nSemCobCamb := 0 // JPM - 10/03/06 - Definido como private para utilização no ponto de entrada.

Private lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)

Private nAnteci :=0 // DFS - 01/09/2009 - Alteração da variável para Private, para que seja possível enxergá-la através de Customização

Private cExpFabr:= "", cExportForn:= ""
Private lLoopRE := .F. //DFS - Criação de variável para uso no ponto de entrada.

// LCS - 04/05/2001
// CAF 10/04/02
lP_RC := !Empty(cRC)

EEP->(dbSetOrder(1))
EEC->(dbSetOrder(1))
EE9->(dbSetOrder(4))

Begin Sequence

   If !EECFlags("NOVOEX")

      // Cria o Arquivo ...
      hFile := EasyCreateFile(cDir+cFile)

      IF ! (hFile > 0)
         MsgStop(STR0043+cDir+cFile,STR0003) //"Erro na criação do arquivo: "###"Aviso"
         Break
      Endif

      cFileItem := AllTrim(CriaTrab(,.F.))+".TXT"
      hItHandle := EasyCreateFile(cDir+cFileItem)
      If !(hItHandle>0)
         MsgStop(STR0043+cDir+cFileItem,STR0003) //"Erro na criação do arquivo: "###"Aviso"
         Break
      EndIf

   End If

   Private aRegRE := {}

   //By OMJ - 07/12/2004
   IF EasyEntryPoint("EECPSI00")
      ExecBlock("EECPSI00",.F.,.F.,{"WD",{},nAgrupa})
   Endif

   //ER - 04/12/2007 - Verifica se existe mais que 10 parcelas de cambio.
   SX3->(DbSetOrder(2))
   If SX3->(DbSeek("Y6_PERC_01"))
      While SX3->(!EOF()) .and. Left(SX3->X3_CAMPO,8) == "Y6_PERC_"
         nParcs ++
         SX3->(DbSkip())
      EndDo
   EndIf

   // ** Gravacao dos itens do txt ...
   Do While ! Work->(Eof())

	  lDrawBack := !Empty(Work->EE9_ATOCON)

      //By OMJ - 07/12/2004
      IF EasyEntryPoint("EECPSI00")
         ExecBlock("EECPSI00",.F.,.F.,{"WX",{},nAgrupa})
      Endif

      cBuffer:=""
      // Linha 05
      cNcm := Work->EE9_POSIPI

      IF SYD->(FieldPos("YD_SISCEXP")) > 0
         SYD->(DBSETORDER(1))
         SYD->(DBSEEK(XFILIAL("SYD")+WORK->EE9_POSIPI))

         // Completa com os dois ultimos digitos na geração da RE
         IF !Empty(SYD->YD_SISCEXP)
            cNcm := Left(Work->EE9_POSIPI,8)+SYD->YD_SISCEXP
         Else
            cNcm := Left(Work->EE9_POSIPI,8)+"00"
         Endif
      Endif

	  //LRS - 05/01/2015
      If EE9->(FIELDPOS("EE9_DTQNCM")) > 0 .And. !Empty(Work->EE9_DTQNCM)
         cNcm := Left(Work->EE9_POSIPI,8)+ Work->EE9_DTQNCM
      Endif

      // By OMJ - 25/02/2003 - 15:22 - Gravar no EE9 a descricao que foi para o RE.
      If lIntEDC
         SI100DscEE9(TRB->EEC_PREEMB,Work->EE9_SEQSIS,Work->EE9_VM_DES)
      EndIf

      cBuffer := cBuffer+"T3"+IncSpace(cNcm,10,.F.) // Ncm
      cBuffer := cBuffer+IncSpace(Work->EE9_NALSH,8)       // Naldi/SH
      cBuffer := cBuffer+IncSpace(StrTran(Work->EE9_VM_DES,CRLF," "),675,.F.) // Descricao da Mercadoria

	  SI100MemRE(aRegRE,"EWK_NCM"   ,cNCM)
	  SI100MemRE(aRegRE,"EWK_NALADI",Work->EE9_NALSH)

      IF SYD->(FIELDPOS("YD_CATTEX")) > 0
         SYD->(DBSETORDER(1))
         SYD->(DBSEEK(XFILIAL("SYD")+WORK->EE9_POSIPI))
         cBuffer := cBuffer+IncSpace(SYD->YD_CATTEX,4) // Categoria Textil
      ELSE
         cBuffer := cBuffer+IncSpace("",4) // Categoria Textil
      ENDIF
      IF ( !EMPTY(Posicione("SA2",1,xFilial("SA2")+Work->EE9_FABR+Work->EE9_FALOJA,"A2_EST")) )
         cBuffer := cBuffer+IncSpace(Posicione("SA2",1,xFilial("SA2")+Work->EE9_FABR+Work->EE9_FALOJA,"A2_EST"),2) // Estado Produtor
      ELSE
         cBuffer := cBuffer+IncSpace(Posicione("SA2",1,xFilial("SA2")+Work->EE9_FORN+Work->EE9_FOLOJA,"A2_EST"),2) // Estado Produtor
      ENDIF

      cBuffer := cBuffer+IncSpace(Work->EE9_SEQSIS,6) // Nro. linha item no proc. emb.

      cBuffer := cBuffer+CRLF

      // Linha 06
      cBuffer := cBuffer+"T4"+IncSpace(SI100Num(Work->EE9_PSLQTO,15,5),18) // Peso Lq. Unitario

      //AMS - 29/01/2004 às 17:07. Converção do peso p/ KG.
      //If EE9->(FieldPos("EE9_UNPES")) > 0 .And. !Empty(Work->EE9_UNPES) .and. EasyGParam("MV_AVG0031",, ".") <> "."
      //   cBuffer := cBuffer+IncSpace(SI100Num(AVTransUnid(Work->EE9_UNPES, EasyGParam("MV_AVG0031"), Work->EE9_COD_I, Work->EE9_SLDINI, .F.), 15, 5), 18)
      //Else
         cBuffer := cBuffer+IncSpace(SI100Num(Work->EE9_SLDINI,15,5),18)   // Qtde Uni Comercial
      //EndIf


      cBuffer := cBuffer+IncSpace(ALLTRIM(Work->EE9_UNIDAD),20,.F.)        // Unidade de Comerc.
	  SI100MemRE(aRegRE,"EWK_UMCOM",ALLTRIM(Work->EE9_UNIDAD))

      /// LCS - 22/08/2002
      // by CAF 04/07/2002
      ///IF Select("SJ5") > 0 // Verifica se o cliente esta usando o cadastro de conversao ...
      ///   // ** By JBJ - 15/06/2002 - 13:22 ...
      ///   cBuffer := cBuffer+IncSpace(SI100Num(AvTransUnid(Work->EE9_UNIDAD,SYD->YD_UNID,Work->EE9_COD_I,;
      ///                              Work->EE9_SLDINI,.F.),15,5),18)   // Qtde Uni Mercadoria
      ///Else
      //   cBuffer := cBuffer+IncSpace(SI100Num(Work->WK_SLDINI,15,5),18)  // Qtde Uni Mercadoria
      ///Endif

      /*
      Rotina de gravação da Qtde Uni. Mercadoria.
      Data e Hora : 06/02/2004 às 11:19
      Autor       : Alexsander Martins dos Santos
      Objetivo    : Gravação da Qtde Uni. Mercadoria quando a unidade de medida da NCM for diferente KG.
      */
      If Posicione("SYD", 1, xFilial("SYD")+Work->EE9_POSIPI, "YD_UNID") <> EasyGParam("MV_AVG0031",, "KG")
         cBuffer := cBuffer+IncSpace(SI100Num(Work->WK_SLDINI, 15, 5), 18) // Qtde Uni Mercadoria
      Else
         cBuffer := cBuffer+Space(18) // Qtde Uni Mercadoria
      EndIf
      //Final da rotina.

      //cBuffer := cBuffer+IncSpace(SI100Num(Work->EE9_PRCTOT,15,2),18)      // Preco Cond. Venda
      nTotCondVen := Work->EE9_PRCTOT
      If lSemCobCamb
         nTotCondVen += Work->EE9_VLSCOB
      EndIf
      cBuffer := cBuffer+IncSpace(SI100Num(nTotCondVen,15,2),18)      // Preco Cond. Venda

      // ** Acumula valor da condicao de venda ...
      nVlCalc+=Work->EE9_PRCTOT

      //Acumula valor total sem cobertura cambial
      If lSemCobCamb
         nVlSemCob+=Work->EE9_VLSCOB   //TRP-03/03/2009
      Endif
      // ** By JBJ - 14/08/03 - 11:50
      /*
      EE9->(DbSetOrder(9))
      If EE9->(DbSeek(xFilial("EE9")+AvKey(cProc,"EE9_PREEMB")+Work->EE9_SEQSIS))
         Do While EE9->(!Eof()) .And. EE9->EE9_PREEMB == AvKey(cProc,"EE9_PREEMB") .And.;
                                      EE9->EE9_SEQSIS == Work->EE9_SEQSIS
            If !Empty(EE9->EE9_RC)
               nFinCia += EE9->EE9_PRCTOT // Valor Financiado
            EndIf

            EE9->(DbSkip())
         EndDo
      EndIf
      */

      //cBuffer := cBuffer+IncSpace(SI100Num(Work->WK_PRCTOT,15,2),18)       // Preco Local de Embarque

      nTotLocEmb := Work->WK_PRCTOT
      If lSemCobCamb
         nTotLocEmb += Work->EE9_VLSCOB
      EndIf
      cBuffer := cBuffer+IncSpace(SI100Num(nTotLocEmb,15,2),18)       // Preco Local de Embarque


      // by CAF 27/07/2001 Percentual comissao por item cBuffer := cBuffer+IncSpace(SI100Num(EEC->EEC_VALCOM,5,2),5)         // Porcentual da Comissa Agente

      IF !Empty(Work->WK_PERCOM) .And. Empty(cRc)
         cBuffer := cBuffer+IncSpace(SI100Num(Work->WK_PERCOM,5,2),5) // Porcentual da Comissa Agente
		 IF (EEC->EEC_TIPCOM=="1")
            cFORMA      := "R"
            cFormAux    := "3"
         ELSEIF (EEC->EEC_TIPCOM=="2")
            cFORMA      := "G"
            cFormAux    := "1"
         ELSEIF (EEC->EEC_TIPCOM=="3")
            cFORMA      := "F"
            cFormAux    := "2"
         ELSE
            cFORMA      := ""
            cFormAux    := ""
         ENDIF

		 SI100MemRE(aRegRE,"EWK_PERCOM",Work->WK_PERCOM)
		 //SI100MemRE(aRegRE,"EWK_TIPCOM",EEC->EEC_TIPCOM)
		 SI100MemRE(aRegRE,"EWK_TIPCOM",cFormAux)//DFS - 27/01/12 - Variável usada apenas para o NovoEx, assim como o array.
      ELSE
         cBuffer := cBuffer+IncSpace("",5) // Porcentual da Comissa Agente
         cFORMA := ""
      ENDIF

      cBuffer := cBuffer+IncSpace(cFORMA,1)           // Forma
      cBuffer := cBuffer+IncSpace(Work->EE9_FINALI,3) // Finalidade

      // ** JPM - Tratamento para exportador/fornecedor - 21/03/06
      If !(TRB->EEC_INTERM $ cSim) .And. !Empty(TRB->(EEC_EXPORT+EEC_EXLOJA))
         cExportForn := TRB->(EEC_EXPORT+EEC_EXLOJA)
      Else
         cExportForn := TRB->(EEC_FORN+EEC_FOLOJA)
      EndIf

      // Exportador é o Fabricante ?
      // By JPP - 16/11/2006 - 13:50 - Quando os campos Work->(EE9_FABR+EE9_FALOJA) estiverem vazios, o sistema deve considerar o exportador igual ao fabricante.
      // Quando o ato concessorio estiver preenchido o fabricante deve ser diferente do exportador, senão o SISCOMEX, não
      // abre a tela para digitação dos dados do Ato concessório.

      /*EDUARDO/ WFS - 23/09/2008 -- Verificação da existência de dados do Fabricante para os itens
      de embarque de exportação.*/
      lExistEYU := .F.
      EYU->(DbSetOrder(1))
      If EYU->(DbSeek(xFilial("EYU")+Work->EE9_PREEMB+Work->EE9_SEQEMB))
         lExistEYU := .T.
      EndIf

       //WFS - 23/09/2008
      IF (Work->(EE9_FABR+EE9_FALOJA) == cExportForn .Or. Empty(Work->(EE9_FABR+EE9_FALOJA))) .And. (Empty(Work->EE9_ATOCON) .Or. !lExistEYU) // WFS - 25/09/2012 - Ajuste no tratamento para a verificação de fabricante
         cExpFabr := "S"
      ELSE
         cExpFabr := "N"
      ENDIF

      If EasyEntryPoint("EECSI100")
         ExecBlock("EECSI100",.F.,.F.,"SI100CRIATXT_EXPFABR")
      EndIf

      /* JPM - 21/03/06 - tratamento para o campo 22.
      IF !EMPTY(Work->EE9_FABR+Work->EE9_FALOJA) .or. !Empty(Work->EE9_ATOCON)
         // Exportador Não é o Fabricante ?
         cExpFabr := "N"
      ELSE
         cExpFabr := "S"
      ENDIF
      */

      cBuffer := cBuffer+IncSpace(cExpFabr,1) // Exportador eh fabricante
      cBuffer := cBuffer+Work->WK_TEMOBS      // Observacao do Exportador
      cBuffer := cBuffer+CRLF

	  SI100MemRE(aRegRE,"EWK_EXPFAB",cExpFabr)

	  //wfs 29/11/13
   	  If TRB->EEC_STASIS == SI_SF
         SI100MemRE(aRegRE,"EWK_NRORE",Work->EE9_RE)
   	  EndIf

      // Linha 07
      // AMS - 01/07/2003 - Geração do T5 quando o Ato Concessório estiver preenchido.
      //IF !Empty( Work->EE9_ATOCON ) // cExpFabr == "N" //.or. !Empty( Work->EE9_ATOCON )

      IF !Empty( Work->EE9_ATOCON ) .or. cExpFabr == "N"
         cBuffer := cBuffer+"T5"

         For nCont:=1 To 10
            IF ! Empty(Work->(FieldGet(FieldPos("WK_CGC"+Ltrim(Str(nCont))))))

                cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_CGC"+Ltrim(Str(nCont))))),14,.f.) // CGC
                /*WFS 09/03/08 - Correção do preenchimento da NCM + Destaque na quinta tela
                cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_NBM"+Ltrim(Str(nCont))))),8,.F.) // NCM -- WFS 24/09/2008
                cBuffer := cBuffer + "00" //WFS - 24/09/2008 -- NCM; exigido pelo Siscomex na Quinta Tela */
                cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_NBM"+Ltrim(Str(nCont))))),10,.F.)
                //---
                cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_UF"+Ltrim(Str(nCont))))),2,.f.) // UF
                If EECFLAGS("CONSIGNACAO")
                  //ER - 19/02/2008 - Verifica se é Remessa Normal ou Remessa de Back to Back.
                  If TRB->EEC_TIPO == PC_RC .or. TRB->EEC_TIPO == PC_BC
                      cBuffer := cBuffer+IncSpace("",13,.f.) // ATO CONCESSORIO
                  Else
                      cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_ATO"+Ltrim(Str(nCont))))),13,.f.) // ATO CONCESSORIO
                  EndIf
                Else
                   cBuffer := cBuffer+IncSpace(Work->(FieldGet(FieldPos("WK_ATO"+Ltrim(Str(nCont))))),13,.f.) // ATO CONCESSORIO
                EndIf
                cBuffer := cBuffer+IncSpace(SI100Num(Work->(FieldGet(FieldPos("WK_QTD"+Ltrim(Str(nCont))))),15,3),16,.f.) // Qtde
                cBuffer := cBuffer+IncSpace(SI100Num(Work->(FieldGet(FieldPos("WK_VAL"+Ltrim(Str(nCont))))),15,2),18,.f.) // Valor

            Else
                cBuffer := cBuffer+IncSpace("",14,.f.) // CGC
                cBuffer := cBuffer+IncSpace("",10,.F.) // NCM
                cBuffer := cBuffer+IncSpace("",2,.f.) // UF
                cBuffer := cBuffer+IncSpace("",13,.f.) // ATO CONCESSORIO
                cBuffer := cBuffer+IncSpace("",16,.f.) // Qtde
                cBuffer := cBuffer+IncSpace("",18,.f.) // Valor
            Endif
         Next nCont

         cBuffer := cBuffer+CRLF
      Endif

      // Linha 08
      If Work->WK_TEMOBS == "S"
         cObs:=""
         For nX:=1 To 10
             cObs:=cObs+Work->(FieldGet(FieldPos("WK_OBS"+AllTrim(Str(nX)))))
         Next

   	     SI100MemRE(aRegRE,"EWK_OBS",cObs)

         cBuffer := cBuffer+"T6"+cObs
         cBuffer := cBuffer+CRLF
      Endif

      // by CAF - Ponto de entrada antes da gravação do buffer por anexo
      IF EasyEntryPoint("EECPSI00")
         ExecBlock("EECPSI00",.F.,.F.,{"PE_IT",{},nAgrupa})
      Endif

      If !EECFlags("NOVOEX")
	     // Gravacao dos dados em no txt dos itens ...
         Fwrite(hItHandle,cBuffer,Len(cBuffer))
	  Else
	     Exit
	  EndIf

      lLoopRE := .F.   //DFS - 27/12/11 - Variavel que definirá se executa ou não as validações
      If EasyEntryPoint("EECSI100") //DFS - 27/12/11 - Ponto de Entrada para validação da geração de RE ao Siscomex
         ExecBlock("EECSI100",.F.,.F.,"CONTROLE_QUEBRA")
      EndIf

	  If lLoopRE
	     Exit
	  Endif

      Work->(dbSkip())

      IF nAgrupa == 5
         Exit
      Endif

      // Mudou o Enquadramento - gera uma novo RE
      If (cEnqCod <> Work->WK_ENQCOD)
         Exit
      EndIf

      // Mudou o Reg.de Credito - gera uma novo RE
      IF (cRC <> Work->EE9_RC)
         Exit
      Endif

      // Mudou o Reg. de Venda - gera uma nova RE
      If lField_RV
         If (cRV <> Work->EE9_RV) // By JBJ - 24/07/02 - 15:49
            Exit
         EndIf
      Endif

     If lCatCot   // GFP - 25/07/2012 - Categoria de Cota
        If (cCatCota <> Work->EE9_CATCOT)
            Exit
        EndIf
     EndIf

      /*
      // ** Mudou o AtoCon. - Gera uma nova RE.
      If (cOldAto <> Work->EE9_ATOCON)
         Exit
      EndIf
      */

      // ** Mudou o AtoCon. - Gera uma nova RE.
      If !lWizardRE .and. (cOldAto <> Work->EE9_ATOCON)
         Exit
      EndIf

   Enddo

   If !EECFlags("NOVOEX")
      cBuffer := "####eof#####"+ENTER
      fWrite(hItHandle,cBUFFER,Len(cBuffer))
   EndIf

   cBuffer := ""
   //fClose(hItHandle)

   // Posiciona o Usuario do Siscomex ...
   If !EECFlags("NOVOEX")
      EEP->(dbSeek(xFilial()+cUser))
   EndIf

   // Posiciona o Processo de Exportacao a ser gerado ...
   EEC->(dbSeek(xFilial()+cProc))
   // Alterado por Heder M Oliveira - 1/19/2000
   EEC->(RECLOCK("EEC",.F.))
   EEC->EEC_STASIS := SI_RS
   IF ( EMPTY(EEC->EEC_LIBSIS) )
      EEC->EEC_LIBSIS := dDATABASE
   ENDIF

   If !EECFlags("NOVOEX")
      EER->(RecLock("EER",.T.))
      EER->EER_FILIAL := xFilial("EER")
      EER->EER_CNPJ   := EEP->EEP_CNPJ
      EER->EER_PREEMB := EEC->EEC_PREEMB
      EER->EER_IDTXT  := cFile
      EER->EER_DTLIBS := EEC->EEC_LIBSIS
      EER->EER_DTGERS := dDataBase
      EER->EER_STASIS := SI_RS
      EER->(MsUnlock())
   EndIf

   // ** Gravacao da capa do txt ...

   // Verificar se gera o novo layout com as informacoes:
   // 1-CGC Representante e 2-CGC Representado
   IF EasyGParam("MV_AVG0036",.T.) // Verifica se o parametro existe
      IF ! Empty(EEC->EEC_EXPORT) .And. !(EEC->EEC_INTERM $ cSim) .And. !Empty(Posicione("SA2",1,xFilial("SA2")+EEC->EEC_EXPORT+EEC->EEC_EXLOJA,"A2_CGC"))
         cKSA2 := EEC->EEC_EXPORT+EEC->EEC_EXLOJA
      Else
         cKSA2 := EEC->EEC_FORN+EEC->EEC_FOLOJA
      Endif

      //TRP - 23/12/2011 - Ponto de Entrada para alteração do Fornecedor/Exportador.
      If EasyEntryPoint("EECSI100")
         ExecBlock("EECSI100",.F.,.F.,"ALTERA_FORNEXP")
      EndIf

      cBuffer := cBuffer+"ID"
      // by CAF 04/12/2003 17:00 cBuffer := cBuffer+IncSpace(Posicione("SA2",1,xFilial("SA2")+cKSA2,"A2_CGC"),14,.F.)
      cBuffer := cBuffer+IncSpace(SI100CNPJ(cKSA2),14,.F.)
      cBuffer := cBuffer+IncSpace(If(EasyGParam("MV_AVG0036",,"")=".", " ", EasyGParam("MV_AVG0036",,"")),14,.F.)
      cBuffer := cBuffer+CRLF
   Endif

   // Linha 01
   cBuffer := cBuffer+"NP"+IncSpace(EEC->EEC_PREEMB,20)+CRLF // Proc.Exp.

   If EECFlags("NOVOEX") //DFS - 27/12/11 - Verificar se é NovoEx, já que os campos da EWK são criados através do update UENOVOEX
      cSeqRE    := StrZero(Len(aRegREs)+1, AvSx3("EWK_SEQRE", AV_TAMANHO))
      cSeqAnexo := StrZero(Val(Work->EE9_SEQSIS), AvSx3("EWK_ANEXO", AV_TAMANHO))
   EndIf

   SI100MemRE(aRegRE,"EWK_FILIAL",xFilial("EWK"))
   SI100MemRE(aRegRE,"EWK_ID"    ,cIDLoteRE)
   SI100MemRE(aRegRE,"EWK_SEQRE" ,cSeqRE)
   SI100MemRE(aRegRE,"EWK_ANEXO" ,cSeqAnexo)
   SI100MemRE(aRegRE,"EWK_STATUS",-1)//Não retornado do Siscomex
   SI100MemRE(aRegRE,"EWK_TIPEXP",if(Empty(Posicione("SA2",1,xFilial("SA2")+cKSA2,"A2_TIPO")),"J",Posicione("SA2",1,xFilial("SA2")+cKSA2,"A2_TIPO")))
   SI100MemRE(aRegRE,"EWK_CGCEXP",SI100CNPJ(cKSA2))
   SI100MemRE(aRegRE,"EWK_PREEMB",EEC->EEC_PREEMB)

   // Linha 02
   cBuffer := cBuffer+"SE"+IncSpace(EEP->EEP_CNPJ,11)   // Codigo
   cBuffer := cBuffer+IncSpace("",12)                   // Senha
   cBuffer := cBuffer+IncSpace("",12)                   // Nova Senha
   cBuffer := cBuffer+IncSpace(EEP->EEP_SISTEM,62)+CRLF // Sistema

   // Linha 03
   cBuffer := cBuffer+"T1"

   /*
   AMS - 04/06/2005. Implementação para adicionar no array aEnquadra o codigo do enquadramento de Drawback
                     para o RE gerado quando o ato concessório do item estiver preenchido.
   */
   If lDrawBack .AND. !EECFlags("NOVOEX")
      SI100AddEnq(EEC->EEC_ENQCOX)
   Else
      If (nPos := aScan(aEnquadra, EEC->EEC_ENQCOX)) <> 0
         aDel(aEnquadra, nPos)
         aSize(aEnquadra, Len(aEnquadra)-1)
      EndIf
   EndIf

   /*
   AMS - 19/10/2005. Imposto a condição "!lDrawBack" para gerar a R.E. com os códigos de enquadramento somente quando
                     a R.E. não for de DrawBack (ato concessório nos itens preenchido).
   */
   If !lDrawBack .or. EasyGParam("MV_AVG0118",, .F.)

      SI100AddEnq(EEC->EEC_ENQCOD)

      For nIEnq := 1 To 5
         SI100AddEnq(EEC->(FieldGet(FieldPos("EEC_ENQCO"+AllTrim(Str(nIEnq))))))
      Next nIEnq

   EndIf

   nTotEnq := if(EECFlags("NOVOEX"),4,6)

   If !EECFlags("NOVOEX")
      For nIEnq := 1 To nTotEnq
         If nIEnq > Len(aEnquadra)
            cBuffer := cBuffer+IncSpace("",5)               // Enquadramento
         Else
            cBuffer := cBuffer+IncSpace(aEnquadra[nIEnq],5) // Enquadramento
	     	 //SI100MemRE(aRegRE,"EWK_CODEN"+AllTrim(Str(nIEnq)),aEnquadra[nIEnq])
         EndIf
      Next nIEnq
   EndIf

   // ** By JBJ - 24/07/02 - 16:22
   If lField_RV
      cBuffer := cBuffer+IncSpace(cRv,9) // Num do RV
	  SI100MemRE(aRegRE,"EWK_NUMRV",cRv)
   Else
      cBuffer := cBuffer+IncSpace(EEC->EEC_REGVEN,9)
	  SI100MemRE(aRegRE,"EWK_NUMRV",EEC->EEC_REGVEN)
   EndIf

   If lCatCot
      SI100MemRE(aRegRE,"EWK_CATCOT",Work->EE9_CATCOT)    // GFP - 25/07/2012 - Categoria de Cota
   EndIf

   cBuffer := cBuffer+IncSpace(SI100Data(EEC->EEC_LIMOPE),10) // Data Limite
   cBuffer := cBuffer+IncSpace(IF(lP_RC,LEFT(cRc,12),EEC->EEC_OPCRED),12) // Num do RC
   // cBuffer := cBuffer+IncSpace(IF(lP_RC,LEFT(WORK->EE9_RC,12),EEC->EEC_OPCRED),12) // Num do RC
   cBuffer := cBuffer+PADL(Transf(EEC->EEC_MRGNSC,"99.99"),5)  // Margem nao sacada
   cBuffer := cBuffer+IncSpace(EEC->EEC_GEDERE,13) // GE/DE/RE/Vinculado
   cBuffer := cBuffer+IncSpace(EEC->EEC_GDRPRO,15) // Num. Processo
   cBuffer := cBuffer+IncSpace(EEC->EEC_DIRIVN,15) // DI/RI/Vinculado
   cBuffer := cBuffer+IncSpace(EEC->EEC_URFDSP,7) // Unidade RF Despacho
   cBuffer := cBuffer+IncSpace(EEC->EEC_URFENT,7) // Unidade RF Embarque

   SI100MemRE(aRegRE,"EWK_DTLIM",EEC->EEC_LIMOPE)
   SI100MemRE(aRegRE,"EWK_MARSAC",EEC->EEC_MRGNSC)
   SI100MemRE(aRegRE,"EWK_GDRPRO",Val(EEC->EEC_GDRPRO))
   SI100MemRE(aRegRE,"EWK_NUMRC",IF(lP_RC,LEFT(cRc,12),EEC->EEC_OPCRED))
   SI100MemRE(aRegRE,"EWK_NUMREV",EEC->EEC_GEDERE)
   SI100MemRE(aRegRE,"EWK_NUMDIV",EEC->EEC_DIRIVN)

   SI100MemRE(aRegRE,"EWK_RFDESP",EEC->EEC_URFDSP)
   SI100MemRE(aRegRE,"EWK_RFEMB" ,EEC->EEC_URFENT)

   If EasyGParam("MV_AVG0140",,"I") == "C" .and. !Empty(EEC->EEC_CONSIG)
      SA1->(DbSetOrder(1))
      If SA1->(DbSeek(xFilial("SA1")+EEC->EEC_CONSIG+EEC->EEC_COLOJA))

         cBuffer := cBuffer+IncSpace(SA1->A1_NOME,55) // Nome do Consignatário
         cBuffer := cBuffer+IncSpace(AllTrim(SA1->A1_END),55,.F.) // End. Consignatário
         cBuffer := cBuffer+IncSpace(POSICIONE("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP"),4) // Cod. Pais

		 SI100MemRE(aRegRE,"EWK_PAISIM",POSICIONE("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP"))
	     SI100MemRE(aRegRE,"EWK_NOMIMP",SA1->A1_NOME)
	     SI100MemRE(aRegRE,"EWK_ENDIMP",AllTrim(SA1->A1_END))
      EndIf

   Else
      cBuffer := cBuffer+IncSpace(EEC->EEC_IMPODE,55) // Nome do Importador
      cBuffer := cBuffer+IncSpace(AllTrim(EEC->EEC_ENDIMP)+" - "+AllTrim(EEC->EEC_END2IM),55,.F.) // End. Import.

      //OAP - 14/02/2011 - A função POSICIONE não esrava funcionando corretamente. Houve apenas o desmenbramento da chamada.
      DbSelectArea("SA1")
      SA1->(DbSeek(xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))
      cBuscaPais := SA1->A1_PAIS

      //cPais  := Posicione("SA1",1,xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA,"A1_PAIS")
      cBuffer := cBuffer+IncSpace(POSICIONE("SYA",1,XFILIAL("SYA")+cBuscaPais,"YA_SISEXP"),4) // Cod. Pais

	  SI100MemRE(aRegRE,"EWK_PAISIM",POSICIONE("SYA",1,XFILIAL("SYA")+cBuscaPais,"YA_SISEXP"))
	  SI100MemRE(aRegRE,"EWK_NOMIMP",EEC->EEC_IMPODE)
	  SI100MemRE(aRegRE,"EWK_ENDIMP",AllTrim(EEC->EEC_ENDIMP)+" - "+AllTrim(EEC->EEC_END2IM))

   EndIf

   cBuffer := cBuffer+CRLF

   // Linha 04
   cBuffer := cBuffer+"T2"+IncSpace(POSICIONE("SYA",1,XFILIAL("SYA")+EEC->EEC_PAISDT,"YA_SISEXP"),4)  // Pais Destino
   cBuffer := cBuffer+IncSpace(ALLTRIM(EEC->EEC_INSCOD),5)											  // Instr.Negociacao
   cBuffer := cBuffer+IncSpace(EEC->EEC_INCOTE,3)													  // Cod.Cond.Venda
   cBuffer := cBuffer+IncSpace(EEC->EEC_MPGEXP,3) 													  // Mod.Transacao
   cBuffer := cBuffer+IncSpace(POSICIONE("SYF",1,XFILIAL("SYF")+EEC->EEC_MOEDA,"YF_COD_GI"),3) 	      // Moeda

   SI100MemRE(aRegRE,"EWK_PAISDE",POSICIONE("SYA",1,XFILIAL("SYA")+EEC->EEC_PAISDT,"YA_SISEXP"))
   SI100MemRE(aRegRE,"EWK_INSCOM",if(Empty(EEC->EEC_INSCOD),"-1",EEC->EEC_INSCOD))
   SI100MemRE(aRegRE,"EWK_TPINST",if(Empty(EEC->EEC_INSCOD),"-1","1"))
   SI100MemRE(aRegRE,"EWK_INCOTE",EEC->EEC_INCOTE)
   SI100MemRE(aRegRE,"EWK_MODPAG",EEC->EEC_MPGEXP)
   SI100MemRE(aRegRE,"EWK_MOEDA",POSICIONE("SYF",1,XFILIAL("SYF")+EEC->EEC_MOEDA,"YF_COD_GI"))

   // ** Utiliza sempre o valor calculado...
   nTotPed := nVlCalc

   //ER - 26/02/2008 - Verifica se existe adiantamento
   If lPagtoAnte
      EEQ->(DbSetOrder(1))
      If EEQ->(DbSeek(xFilial("EEQ")+EEC->EEC_PREEMB))
         While EEQ->(EEQ_FILIAL + EEQ_PREEMB) == xFilial("EEQ")+EEC->EEC_PREEMB
            If EEQ->EEQ_TIPO == "A" .and. EEQ->EEQ_FASE == "E"
               nAnteci += EEQ->EEQ_VL
            EndIf
            EEQ->(DbSkip())
         EndDo
      EndIf
   EndIf

   // DFS - 01/09/2009 - Criação de Ponto de Entrada para que seja possível alterar o Cálculo Antecipado na Rotina de R.E.
   If EasyEntryPoint("EECSI100")
      ExecBlock("EECSI100",.F.,.F.,"CALC_ANTECIPADO")
   EndIf

   // ** By JBJ - 14/08/03 - 11:50. (Tratamentos para Valor Total RE).
   nVlAux := nVlCalc-nFinCia
   nVlAux -= nAnteci

   If EEC->EEC_VLCONS <> 0 // Valor Consignado.
      nVlCons := nVlAux
   Else
      IF EEC->EEC_COBCAM $ cSim .And. EEC->EEC_MPGEXP <> "006" // S.Cobertura Cambial
         SY6->(DbSetOrder(1))
         If SY6->(DbSeek(xFilial("SY6")+EEC->(EEC_CONDPA+Str(EEC_DIASPA,3,0))))
            Do Case
               Case SY6->Y6_TIPO = "1" // Tipo 'Normal'.
                  nParcel := nVlAux // Valor da parcela

               Case SY6->Y6_TIPO = "2" // Tipo 'A vista'.
                  nAvista := nVlAux // Valor a vista.

               Case SY6->Y6_TIPO = "3" // Tipo 'Parcelado'.
                  //For z:=1 To 10
                  For z:=1 To nParcs
                     nPerc := SY6->&("Y6_PERC_"+StrZero(z,2))
                     nDias := SY6->&("Y6_DIAS_"+StrZero(z,2)) 

                     If nPerc > 0
                        If nDias = 0 // A vista.
                           nAvista += Round((nVlAux*(nPerc/100)),2) // Valor a vista.
                        ElseIf nDias > 0 // Parcelado.
                           nParcel += Round((nVlAux*(nPerc/100)),2) // Valor da parcela.
                        /*
                        Else // Antecipado.
                           nAnteci += Round((nVlAux*(nPerc/100)),2) // Valor antecipado.
                        */
                        EndIf
                     EndIf
                  Next

                  // ** Faz a verificação para possíveis resíduos.
                  //nSoma := (nAvista+nParcel+nAnteci)
                  nSoma := (nAvista+nParcel)
                  If nSoma <> nVlAux
                     If nParcel > 0
                        nParcel += Round((nVlAux-nSoma),2)
                     ElseIf nAvista > 0
                        nAvista += Round((nVlAux-nSoma),2)
                     /*
                     Else
                        nAnteci += Round((nVlAux-nSoma),2)
                     */
                     EndIf
                  EndIf
            EndCase
         EndIf
      Else
        // VALIDAÇÃO PARA VERIFICAR SE A MODALIDADE DE PAGAMENTO NÃO TEM COBERTURA CAMBIAL - MPG - 03/01/2018
        lEEFSCC := .T.
      EndIf
   Endif

   cBuffer := cBuffer+IncSpace(IF(lP_RC,"",SI100Num(nAnteci,15,2)),18)  // Vlr.Pagto Antecipado
   cBuffer := cBuffer+IncSpace(IF(lP_RC,"",SI100Num(nAvista ,15,2)),18) // Vlr.Pagto Vista

   // ** Calcular o nro de parcelas e a periodicidade.
   IF !Empty(nParcel)

      nNroParc := 1

      //For z:=1 To 10
      For z:=1 To nParcs

         nPerc := SY6->&("Y6_PERC_"+StrZero(z,2))
         nDias := SY6->&("Y6_DIAS_"+StrZero(z,2))

         If nPerc > 0 .And. nDias > 0

            /*
            AMS - 28/05/2004 às 10:50. Substituido a rotina original para armazenar a maior periodicidade.
            If nPeriodo = 0
               nPeriodo := nDias
            EndIf
            */

            //nNroParc ++
            nPeriodo := nDias

         EndIf

      Next

   Endif

   // Nro. de Parcelas
   IF lP_RC .OR. Empty(nParcel)
      cBUFFER := cBUFFER+IncSpace("",03)   // Nro.de Parc.
   ELSE
      If EEC->EEC_DIASPA <> 901
         cBuffer := cBuffer+IncSpace(SI100Num(EEC->EEC_NPARC,03),03)  // Nro.de Parc.
      Else
         cBuffer := cBuffer+IncSpace(SI100Num(nNroParc,03),03)  // Nro.de Parc.
      EndIf
   ENDIF

   // Periodicidade
   IF !Empty(nParcel) .And. !lP_RC
      cPeriod := AllTrim(GetNewPar("MV_AVG0011","-1"))

      IF EEC->(FieldPos("EEC_PERIOD")) > 0
         cPeriod := AllTrim(EEC->EEC_PERIOD)
      Endif
   Endif

   IF ! Empty(cPeriod) .And. cPeriod <> "-1"
      cBuffer := cBuffer+IncSpace(cPeriod,3) // Periodicidade
	  SI100MemRE(aRegRE,"EWK_PRAZO",cPeriod)
   Else
      IF lP_RC .OR. Empty(nParcel)
         cBUFFER := cBUFFER+INCSPACE("",3)   // PERIODICIDADE
      Else
         If EEC->EEC_DIASPA <> 901
            cBuffer := cBuffer+IncSpace(SI100Num(EEC->EEC_DIASPA,3),3) // Periodicidade
			SI100MemRE(aRegRE,"EWK_PRAZO",EEC->EEC_DIASPA)
         Else
            cBuffer := cBuffer+IncSpace(SI100Num(nPeriodo,3),3) // Periodicidade
			SI100MemRE(aRegRE,"EWK_PRAZO",nPeriodo)
         EndIf
      ENDIF
   Endif

   IF lP_RC .OR. Empty(nParcel)
      cBuffer := cBuffer+" "    // Indicador
   ELSE
      cBuffer := cBuffer+"D"    // Indicador
   ENDIF

   // VALOR DA PARCELA DEPENDENDO DAS OPCOES
   IF lP_RC .OR. Empty(nParcel)
      cBuffer := cBuffer+IncSpace("",18) // Valor da Parcela
   ELSE
      cBuffer := cBuffer+IncSpace(SI100Num(nParcel,15,2),18) // Valor da Parcela
   ENDIF

   cBuffer := cBuffer+IncSpace(IF(lP_RC,"",SI100Num(nVlCons,15,2)),18)   // Vlr.em Consignacao
   cBuffer := cBuffer+IncSpace(IF(lP_RC,"",SI100Num(IF(EEC->EEC_COBCAM $ cNao,nTotPed,If (nVlSemCob>0,nVlSemCob,nSemCobCamb)),15,2)),18) // Valor s/ Cobertura Cambial
   //cBuffer := cBuffer+IncSpace(SI100Num(IF(lP_RC,nVlCalc,nFincia),15,2),18) // Vlr. Financiamento RC
   cBuffer := cBuffer+IncSpace(SI100Num(nFincia,15,2),18) // Vlr. Financiamento RC

   /*
   SI100MemRE(aRegRE,"EWK_VLCCOB",nVlCalc-nFinCia)
   SI100MemRE(aRegRE,"EWK_VLSCOB",IF(EEC->EEC_COBCAM $ cNao,nTotPed,If (nVlSemCob>0,nVlSemCob,nSemCobCamb)))
   SI100MemRE(aRegRE,"EWK_VLCONS",nVlCons)
   */

   aCposRE := {{"EWK_VLCCOB",IF(EEC->EEC_COBCAM $ cSim,nVlCalc-nFinCia,0)},; //DFS - 03/01/12 - Inclusão de teste para verificar se tem cobertura cambial, caso contrário, manda zero.
               {"EWK_VLSCOB",IF(EEC->EEC_COBCAM $ cNao .AND. EEC->EEC_MPGEXP <> "002",nTotPed,If (nVlSemCob>0,nVlSemCob,nSemCobCamb))},;
               {"EWK_VLCONS",nVlCons}}

   //If !lAddAnexos  // Nopado por GFP - 20/08/2013
      aREBase := {}
   //EndIf

   //Acumula os valores da tag RE Base
   For i := 1 To Len(aCposRE)
      if (nPos := aScan(aREBase,{|Y| Y[1] == aCposRE[i][1]})) == 0
 	     aAdd(aREBase,aClone(aCposRE[i]))
 	     nPos := Len(aREBase)
      Else
		 aREBase[nPos][2] += aCposRE[i][2]
	  EndIf
   Next i

   SI100MemRE(aRegRE,"EWK_VLFINA",nFincia)

   aDrawbacks   := {}
   aFabricantes := {}
   If EECFlags("NOVOEX") .AND. (nPos := aScan(aMercsRE,{|X| X[1] == Work->(RecNo())})) > 0
      nContFab := 0
	  i := nPos
      Do While i <= Len(aMercsRE) .AND. aMercsRE[i][1] == Work->(RecNo())
	     aMercadoria := {}

		 SI100MemRE(aMercadoria,"EWL_FILIAL",xFilial("EWL"))
		 SI100MemRE(aMercadoria,"EWL_ID",cIDLoteRE)
		 SI100MemRE(aMercadoria,"EWL_SEQRE",cSeqRE)
		 SI100MemRE(aMercadoria,"EWL_SEQITE",i-nPos+1)
		 SI100MemRE(aMercadoria,"EWL_DESCR",SI100GetMerc(aMercsRE[i],"DESCR"))
		 SI100MemRE(aMercadoria,"EWL_VLVEND",SI100GetMerc(aMercsRE[i],"TOTAL_VENDA"))
		 SI100MemRE(aMercadoria,"EWL_VLFOB",SI100GetMerc(aMercsRE[i],"TOTAL_FOB"))
		 SI100MemRE(aMercadoria,"EWL_QTD",SI100GetMerc(aMercsRE[i],"QTD"))
		 SI100MemRE(aMercadoria,"EWL_QTDNCM",SI100GetMerc(aMercsRE[i],"QTDNCM"))
      	 SI100MemRE(aMercadoria,"EWL_PESO",SI100GetMerc(aMercsRE[i],"PESO"))

      	 //LGS-12/03/2014 - Valida o tamanho da descricao do produto p/ gravar o campo que sera utilizado na geração do XML integração da R.E.
      	 If EWL->(FIELDPOS("EWL_MUNICO"))>0
	     	If Len(aMercadoria[5,2]) < 131
	      	   SI100MemRE(aMercadoria,"EWL_MUNICO",1)
	      	Else
	      	   SI100MemRE(aMercadoria,"EWL_MUNICO",2)
	      	EndIf
	  	 EndIf

         IF EasyEntryPoint("EECSI100")//FSY - 02/08/2013 - Criado ponto de entreda para alterar o vetor aMercadoria "EWL".
            ExecBlock("EECSI100",.F.,.F.,"MERCADORIA")
         ENDIF

 		 SI100MemRE(aRegRE,"MERCADORIAS",aClone(aMercadoria))

 		 aSort(aMercsRE[i][3],,,{|X,Y| X[1] < Y[1]})

 		 l := aScan(aMercsRE[i][3],{|X| X[1] == "FABRICANTE"})
 		 Do While l>0 .AND. l< Len(aMercsRE[i][3]) .AND. aMercsRE[i][3][l][1] == "FABRICANTE"

            cChaveFab := aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_CGC"})][2]+;
                         aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_UF"})][2]

            If (nPosFab := aScan(aFabricantes,{|Y| Y[aScan(Y,{|Z| Z[1] == "EWO_CGC"})][2]+Y[aScan(Y,{|Z| Z[1] == "EWO_UF"})][2] == cChaveFab})) == 0
               aFabric     := {}
               nContFab++

               SI100MemRE(aFabric,"EWO_FILIAL",xFilial("EWO"))
               SI100MemRE(aFabric,"EWO_ID"    ,cIDLoteRE)
		       SI100MemRE(aFabric,"EWO_SEQRE" ,cSeqRE)
			   SI100MemRE(aFabric,"EWO_SEQFAB",nContFab)
               SI100MemRE(aFabric,"EWO_CGC"   ,aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_CGC"})][2])
               SI100MemRE(aFabric,"EWO_UF"    ,aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_UF"})][2])
               SI100MemRE(aFabric,"EWO_QTD"   ,aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_QTD"})][2])
               SI100MemRE(aFabric,"EWO_PESO"  ,aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_PESO"})][2])
               SI100MemRE(aFabric,"EWO_VALOR" ,aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_VALOR"})][2])
               SI100MemRE(aFabric,"EWO_OBS"   ,"")

               aAdd(aFabricantes,aClone(aFabric))
            Else
               aCpos := {{"EWO_QTD"  ,aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_QTD"  })][2]},;
                         {"EWO_PESO" ,aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_PESO" })][2]},;
                         {"EWO_VALOR",aMercsRE[i][3][l][2][aScan(aMercsRE[i][3][l][2],{|X| X[1] == "EWO_VALOR"})][2]}}

               For j := 1 To Len(aCpos)
                   If (nPos2 := aScan(aFabricantes[nPosFab],{|Y| Y[1] == aCpos[j][1]})) == 0
 	                  aAdd(aFabricantes[nPosFab],aClone(aCpos[j]))
		       	   Else
			          aFabricantes[nPosFab][nPos2][2] += aCpos[j][2]
			       EndIf
               Next j
            EndIf
 		    l++
 		 EndDo

 		 nValorFOB := SI100GetMerc(aMercsRE[i],"TOTAL_FOB")

         For j := 1 To Len(aMercsRE[i][2])
	        EE9->(dbGoTo(aMercsRE[i][2][j]))

	        SYD->(DBSetOrder(1))
            SYD->(DBSeek(xFilial()+EE9->EE9_POSIPI))

            If !Empty(EE9->EE9_ATOCON)

                // WFS - 21/09/2012 - Dados do produto para a geração do RE/Drawback
                If (nPosAto := AScan(aDrawbacks,{|X| x[1] == SI100CNPJ(cKSA2)+EE9->EE9_POSIPI+EE9->EE9_ATOCON+EE9->EE9_SEQED3})) > 0

                     aCpos := {{"EWM_VLCCOB", nValorFOB},;
                               {"EWM_VLSCOB",If(lSemCobCamb,EE9->EE9_VLSCOB,If (nVlSemCob>0,nVlSemCob,nSemCobCamb))},;
                               {"EWM_QTDE"  ,;
							   If(lEasyConvQt,;
							   EasyConvQt(EE9->EE9_COD_I,GetEE9Qtds(),GetSYDUnid(SYD->YD_UNID, GetEE9Qtds()),.F.,@oObErroNEx),;
							   AVTRANSUNID(AvKey(EE9->EE9_UNIDAD,"EE9_UNIDAD"),AvKey(SYD->YD_UNID,"YD_UNID"),EE9->EE9_COD_I,EE9->EE9_SLDINI,.F.))}} //LRS - 1/08/2014

                     nValorFOB := 0

                     For k := 1 To Len(aCpos)
                        if (nPos := AScan(aDrawbacks[nPosAto][3],{|Y| Y[1] == aCpos[k][1]})) == 0
                           aAdd(aDrawbacks[nPosAto][3],aClone(aCpos[k]))
                        Else
                           aDrawbacks[nPosAto][3][nPos][2] += aCpos[k][2]
                        EndIf
                     Next

                Else
                    aCpos := {{"EWM_CNPJ"  ,SI100CNPJ(cKSA2)},;
   	                {"EWM_NCM"   ,EE9->EE9_POSIPI},;
                    {"EWM_ATO"   ,EE9->EE9_ATOCON},;
                    {"EWM_SEQSIS",EE9->EE9_SEQED3},;
                    {"EWM_VLCCOB",/*EE9->EE9_PRCTOT RMD - 26/11/12 - Enviar o valor FOB*/ nValorFOB },;
                    {"EWM_VLSCOB",If(lSemCobCamb,EE9->EE9_VLSCOB,If (nVlSemCob>0,nVlSemCob,nSemCobCamb))},;
                    {"EWM_QTDE"  ,;
					If(lEasyConvQt,;
							   EasyConvQt(EE9->EE9_COD_I,GetEE9Qtds(),GetSYDUnid(SYD->YD_UNID, GetEE9Qtds()),.F.,@oObErroNEx),;
							   AVTRANSUNID(AvKey(EE9->EE9_UNIDAD,"EE9_UNIDAD"),AvKey(SYD->YD_UNID,"YD_UNID"),EE9->EE9_COD_I,EE9->EE9_SLDINI,.F.))}} //LRS - 1/08/2014

   	                 AAdd(aDrawbacks,{SI100CNPJ(cKSA2)+EE9->EE9_POSIPI+EE9->EE9_ATOCON+EE9->EE9_SEQED3,,aClone(aCpos)})

   	                 nValorFOB := 0

   	            EndIf
            EndIf
			/*
			RecLock("EE9",.F.)
     	    EE9->EE9_ID    := cIDLoteRE
	        EE9->EE9_SEQRE := cSeqRE
	        EE9->(MsUnLock())
			*/
			EYU->(dbSetOrder(1))//EYU_FILIAL+EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON
			EYU->(dbSeek(xFilial("EYU")+EE9->(EE9_PREEMB+EE9_SEQEMB)))
		    Do While !EYU->(EoF()) .AND. EYU->(EYU_FILIAL+EYU_PREEMB+EYU_SEQEMB) == EE9->(xFilial("EE9")+EE9_PREEMB+EE9_SEQEMB)

			   If !Empty(EYU->EYU_ATOCON)
			      If (nPosAto := aScan(aDrawbacks,{|X| x[1] == EYU->EYU_CNPJ+EYU->EYU_POSIPI+EYU->EYU_ATOCON+EYU->EYU_SEQED3})) > 0
				     aCpos := {{"EWM_VLCCOB",EYU->EYU_VALOR - EYU->EYU_VLSCOB},;
   			                   {"EWM_VLSCOB",EYU->EYU_VALOR},;
			                   {"EWM_QTDE"  ,EYU->EYU_QTD}}

                     For k := 1 To Len(aCpos)
                        if (nPos := aScan(aDrawbacks[nPosAto][3],{|Y| Y[1] == aCpos[k][1]})) == 0
                           aAdd(aDrawbacks[nPosAto][3],aClone(aCpos[k]))
               			Else
			               aDrawbacks[nPosAto][3][nPos][2] += aCpos[k][2]
                     	EndIf
                     Next k

				  Else
				     aCpos := {{"EWM_CNPJ"  ,EYU->EYU_CNPJ},;
			                   {"EWM_NCM"   ,EYU->EYU_POSIPI},;
			                   {"EWM_ATO"   ,EYU->EYU_ATOCON},;
			                   {"EWM_SEQSIS",EYU->EYU_SEQED3},;
			                   {"EWM_VLCCOB",EYU->EYU_VALOR - EYU->EYU_VLSCOB},;
   			                   {"EWM_VLSCOB",EYU->EYU_VALOR},;
			                   {"EWM_QTDE"  ,EYU->EYU_QTD}}
					 aAdd(aDrawbacks,{EYU->EYU_CNPJ+EYU->EYU_POSIPI+EYU->EYU_ATOCON+EYU->EYU_SEQED3,,aClone(aCpos)})
					 nPosAto := Len(aDrawbacks)
				  EndIf

				  EWI->(dbSetOrder(1))//EWI_FILIAL+EWI_PREEMB+EWI_SEQEMB+EWI_TIPO+EWI_CNPJ+EWI_POSIPI+EWI_ATOCON+EWI_SEQED3+EWI_SEQNF
				  EWI->(dbSeek(xFilial("EWI")+EYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3)))
				  Do While !EWI->(EoF()) .AND. EWI->(EWI_FILIAL+EWI_PREEMB+EWI_SEQEMB+EWI_TIPO+EWI_CNPJ+EWI_POSIPI+EWI_ATOCON+EWI_SEQED3) ==;
				                               xFilial("EWI")+EYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3)

					 nContNFs:= 0
					 aEval(aDrawbacks[nPosAto][3],{|X| if(X[1]=="NOTAS_FISCAIS",nContNFs++,)})

			         aNF     := {}

  				     SI100MemRE(aNF,"EWN_FILIAL",xFilial("EWN"))
			         SI100MemRE(aNF,"EWN_ID"    ,cIDLoteRE)
		             SI100MemRE(aNF,"EWN_SEQRE" ,cSeqRE)
			         SI100MemRE(aNF,"EWN_SEQDB" ,nPosAto)
                     SI100MemRE(aNF,"EWN_SEQNF" ,nContNFs+1)
                     SI100MemRE(aNF,"EWN_NF"    ,EWI->EWI_NF)
                     SI100MemRE(aNF,"EWN_DATA"  ,EWI->EWI_DTNF)
                     SI100MemRE(aNF,"EWN_QTD"   ,EWI->EWI_QTD)
                     SI100MemRE(aNF,"EWN_VALOR" ,EWI->EWI_VLNF)

				     SI100MemRE(aDrawbacks[nPosAto][3],"NOTAS_FISCAIS",aClone(aNF))

				     EWI->(dbSkip())
				  EndDo


			   EndIf

               If EasyEntryPoint ("EECSI100")
                  ExecBlock ("EECSI100", .F., .F., {"SI100_ALTERA_EYU"})
               Endif
               IIf( !lIntEDC .and. lEEFSCC , nEW0Valor := EYU->EYU_VLSCOB , nEW0Valor := EYU->EYU_VALOR+EYU->EYU_VLSCOB  ) // SE A MODALIDADE DE PAGAMENTO NÃO TEM COBERTURA CAMBIAL leva só o valor cambial sem cobertura - MPG - 03/01/2018
			   If EYU->EYU_TIPO == "1" //DFS - 18/04/12 - Inclusão de tratamento para só utilizar os dados da tabela EYU quando for Empresa Industrial.
    	          nContFab++
		          aFabric     := {}
    	          SI100MemRE(aFabric,"EWO_FILIAL",xFilial("EWO"))
		          SI100MemRE(aFabric,"EWO_ID"    ,cIDLoteRE)
		          SI100MemRE(aFabric,"EWO_SEQRE" ,cSeqRE)
		          SI100MemRE(aFabric,"EWO_SEQFAB",nContFab)
                  SI100MemRE(aFabric,"EWO_CGC"   ,EYU->EYU_CNPJ)
                  SI100MemRE(aFabric,"EWO_UF"    ,EYU->EYU_UF)
                  SI100MemRE(aFabric,"EWO_QTD"   ,EYU->EYU_QTDPRO)
                  SI100MemRE(aFabric,"EWO_PESO"  ,EYU->EYU_PESO)
                  SI100MemRE(aFabric,"EWO_VALOR" ,nEW0Valor)
                  SI100MemRE(aFabric,"EWO_OBS"   ,EYU->EYU_OBS)
                  SI100MemRE(aRegRE,"FABRICANTES",aClone(aFabric))
			   EndIf

		       EYU->(dbSkip())

			EndDo

            IF EasyEntryPoint("EECSI100")//FSY - 10/08/2013 - Criado ponto de entreda para alterar o vetor aFabric "EWO".
               ExecBlock("EECSI100",.F.,.F.,"FABRICANTE")
            ENDIF

			aRelac:= {}
    		SI100MemRE(aRelac,"EWP_FILIAL",xFilial("EWP"))
			SI100MemRE(aRelac,"EWP_ID"    ,cIDLoteRE)
		    SI100MemRE(aRelac,"EWP_SEQRE" ,cSeqRE)
			SI100MemRE(aRelac,"EWP_SEQITE",i-nPos+1)
            SI100MemRE(aRelac,"EWP_PREEMB",EE9->EE9_PREEMB)
            SI100MemRE(aRelac,"EWP_SEQEMB",EE9->EE9_SEQEMB)

			SI100MemRE(aRegRE,"RELACIONAMENTOS",aClone(aRelac))
		 Next j

		 i++
	  EndDo

      For j := 1 To Len(aFabricantes)
         SI100MemRE(aRegRE,"FABRICANTES",aClone(aFabricantes[j]))
      Next j
      For j := 1 To Len(aDrawbacks)
	     aDrawback := {}

   		 SI100MemRE(aDrawback,"EWM_FILIAL",xFilial("EWL"))
		 SI100MemRE(aDrawback,"EWM_ID",cIDLoteRE)
		 SI100MemRE(aDrawback,"EWM_SEQRE",cSeqRE)
		 SI100MemRE(aDrawback,"EWM_SEQDB",j)
		 SI100MemRE(aDrawback,"EWM_CNPJ",SI100GetMerc(aDrawbacks[j],"EWM_CNPJ"))
		 SI100MemRE(aDrawback,"EWM_NCM",SI100GetMerc(aDrawbacks[j],"EWM_NCM"))
		 SI100MemRE(aDrawback,"EWM_ATO",SI100GetMerc(aDrawbacks[j],"EWM_ATO"))
		 SI100MemRE(aDrawback,"EWM_SEQSIS",SI100GetMerc(aDrawbacks[j],"EWM_SEQSIS"))
		 SI100MemRE(aDrawback,"EWM_VLCCOB",SI100GetMerc(aDrawbacks[j],"EWM_VLCCOB"))
       	 SI100MemRE(aDrawback,"EWM_VLSCOB",SI100GetMerc(aDrawbacks[j],"EWM_VLSCOB"))
		 SI100MemRE(aDrawback,"EWM_QTDE",SI100GetMerc(aDrawbacks[j],"EWM_QTDE"))

		 aSort(aDrawbacks[j][3],,,{|X,Y| X[1] < Y[1]})
		 l := aScan(aDrawbacks[j][3],{|X| X[1] == "NOTAS_FISCAIS"})
		 Do While l > 0 .AND. l <= Len(aDrawbacks[j][3]) .AND. aDrawbacks[j][3][l][1] == "NOTAS_FISCAIS"
 		    SI100MemRE(aDrawback,"NOTAS_FISCAIS",aClone(aDrawbacks[j][3][l][2]))

		    l++
		 EndDo

		 SI100MemRE(aRegRE,"DRAWBACK",aClone(aDrawback))
	  Next j

   EndIf

   cBuffer := cBuffer+CRLF

   If EECFlags("NOVOEX")
      If Len(aDrawbacks) > 0 .AND. aScan(aEnquadra,EEC->EEC_ENQCOX) == 0
         SI100AddEnq(EEC->EEC_ENQCOX)
      EndIf

      For nIEnq := 1 To nTotEnq
         If nIEnq <= Len(aEnquadra)
       	    SI100MemRE(aRegRE,"EWK_CODEN"+AllTrim(Str(nIEnq)),aEnquadra[nIEnq])
       	 EndIf
      Next nIEnq
   EndIf

   // by CAF - Ponto de entrada antes da gravação do buffer da CAPA
   IF EasyEntryPoint("EECPSI00")
      ExecBlock("EECPSI00",.F.,.F.,{"PE_CA",{},nAgrupa})
   Endif

   If !EECFlags("NOVOEX")
      // Gravacao dos dados no Disco ...
      fWrite(hFile,cBuffer,Len(cBuffer))
      cBuffer := ""

      nSize:=fSeek(hItHandle,0,2)
      fSeek(hItHandle,0,0)

      DO WHILE nLidos <= nSize
         nLidos := nLidos+BLOCK_READ
         FREAD(hItHandle,@cBuffer,BLOCK_READ)

         FWRITE(hFile,cBuffer,Len(cBuffer))
      EndDo

      fClose(hItHandle)
      fErase(cDir+cFileItem)

      fClose(hFile)
   Else
      aAdd(aRegREs,aClone(aRegRE))

      //Adiciona os valores da RE base
      For i := 1 To Len(aREBase)
         aAdd(aRegREs[Len(aRegREs)],aREBase[i]) //Não dar aClone, pois está sendo acumulado o total do RE no mesmo espaco de memória
      Next i

   EndIf

   EEC->(MSUNLOCK())

End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : SI100Num
Parametros  : nValor := Valor Numerico
              nInt   := Numero de Inteiros
              nDec   := Numero de Decimais
Retorno     : cValor
Objetivos   : Converter um valor numerico em string
Autor       : Cristiano A. Ferreira
Data/Hora   : 17/12/1999 09:24
Revisao     :
Obs.        :
*/
Static Function SI100Num(nValor,nInt,nDec)

Local cNum := ""

Default nInt := 10, nDec := 0

Begin Sequence
   cNum := Str(nValor,nInt,nDec)
End Sequence

Return cNum

/*
Funcao      : SI100Data
Parametros  : dData := Data a ser convertida
Retorno     : cData
Objetivos   : Converter uma data em string
Autor       : Cristiano A. Ferreira
Data/Hora   : 20/12/1999 11:34
Revisao     :
Obs.        :
*/
Static Function SI100Data(dData)

Local cDat := Space(8)

Begin Sequence
   IF !Empty(dData)
      cDat := Padl(Day(dData),2,"0")+Padl(Month(dData),2,"0")+Str(Year(dData),4)
   Endif
End Sequence

Return cDat

/*
Funcao      : SI100Ret
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Retorno Siscomex
Autor       : Cristiano A. Ferreira
Data/Hora   : 21/12/1999 10:10
Revisao     : Jeferson Barros Jr
Data/Hora   : 09/04/2002 9:34
Obs.        :
*/
Function SI100Ret()

Local aArqErr := {},aFilesOk := {},aFilesErr:= {},;
      bProc,aOrd := SaveOrd({"EEC","EE9","EER"}),aStru := {{"WK_ARQ" ,"C", 12,0}}
Local cDirOrig := EasyGParam("MV_AVG0002") // Diretorio para leitura dos arquivos
Local cDirDest := EasyGParam("MV_AVG0003") // Diretorio destino
LOCAL WorkNFile:=E_CriaTrab(, aStru, "WorkNote")

Local bReadFile := {|x| SI100LoadTxT(x,cDirOrig,cDirDest)}//, aFiles:={}
Local cFile

Local aFileTot
Local nX:=1

PRIVATE nPROC := 0, aProcs:={}, aFiles:={},aEmbarque:={},nPosArray:=0,aDetalhe:={}


IF ! USED()
   HELP(" ",1,"AVG0005069") //MSGINFO(OemToAnsi("Não foi possível a abertura do Arquivo de Trabalho"),"Atenção")
   RETURN(.F.)
ENDIF
DBSELECTAREA("EEC")

EEC->(dbSetOrder(1))
EE9->(dbSetOrder(9)) // FILIAL+PREEMB+SEQSISC
EER->(dbSetOrder(2))

Begin Sequence
   cDirOrig := AllTrim(cDirOrig)
   cDirOrig := cDirOrig+if(Right(cDirOrig,1)=="\","","\")

   cDirDest := AllTrim(cDirDest)
   cDirDest := cDirDest+if(Right(cDirDest,1)=="\","","\")

   //WFS 21/10/09
   If lAltRe //se alteração de RE
      aFilesOk  := ASORT(Directory(cDirOrig+"EA*.OK"),,,{|N1,N2| N1[1] < N2[1]})
      aFilesErr := ASORT(Directory(cDirOrig+"EA*.ERR"),,,{|N1,N2| N1[1] < N2[1]})
   Else //se inclusão de RE
      aFilesOk  := ASORT(Directory(cDirOrig+"EE*.OK"),,,{|N1,N2| N1[1] < N2[1]})
      aFilesErr := ASORT(Directory(cDirOrig+"EE*.ERR"),,,{|N1,N2| N1[1] < N2[1]})
   EndIf

   // Carrega array com o(s) nome(s) do(s) txt(s) gerado(s) no retorno do siscomex...
   For nX:=1 To Len(aFilesOk)
      cFile := Substr(aFilesOk[nX][1],1,At(".",aFilesOk[nX][1])-1)

      If aScan(aFiles,cFile)=0
         aAdd(aFiles,cFile)
      EndIf
   Next

   For nX:=1 To Len(aFilesErr)
      cFile := Substr(aFilesErr[nX][1],1,At(".",aFilesErr[nX][1])-1)

      If aScan(aFiles,cFile)=0
         aAdd(aFiles,cFile)
      EndIf
   Next

   IF Empty(Len(aFilesOk)+Len(aFilesErr))
      HELP(" ",1,"AVG0005070") //MsgInfo("Não existem arquivos de retorno para o processamento !","Aviso")
      Break
   Endif

   bProc := {|| ProcRegua(Len(aFiles)),aEval(aFiles,bReadFile)}

   Processa(bProc)

   For nX:=1 To Len(aProcs)
      SI100Status(aProcs[nX])
   Next

   aFileTot := Directory(cDirOrig+"ET*.AVG")

   For nX:=1 To Len(aFileTot)
      IF File(cDirOrig+aFileTot[nX][1])
         copy file (cDirOrig+aFileTot[nX][1]) to (cDirDest+aFileTot[nX][1])
         fErase(cDirOrig+aFileTot[nX][1])
      EndIf
   Next

   If ValType(aEmbarque)#"U"
      // ** Tela de visualização dos resultados do retorno do siscomex...
      SI100Retorno()
   EndIf

End Sequence

//SI100Note(aArqErr,cDirDest)
WorkNote->(E_EraseArq(WorkNFile))

RestOrd(aOrd)

Return NIL
/*
Funcao      : SI100LoadTxT
Parametros  :
Retorno     : NIL
Objetivos   : Retorno Siscomex
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/04/2002 15:45
Revisao     :
Obs.        :
*/
Static Function SI100LoadTxT(cFile,cDirOrig,cDirDest)

Local nX, cFile2

Private aDetailTxt:={}, lErro := .f.

/*
** aDetailTXT por dimensão:
   [1][1] => SeqSis
   [1][2] => Nro Re
   [1][3] => Dta. Re
   [1][4] => Hora
   [1][5] => Status (OK ou ERR)
   [1][6] => cLine (para passar de parametro para o ponto de entrada EECPSI01)
**
*/
   // Monta o nome do arquivo (original)
   IF At(".",cFile) > 0
      cFile2 := Substr(cFile,1,At(".",cFile)-1)
   Else
      cFile2 := cFile
   Endif

   IF File(cDirOrig+cFile2+".INC")
      cFile2 += ".INC"
   ElseIf File(cDirOrig+cFile2+".ALT")
      cFile2 += ".ALT"
   Endif

   SI100LoadArray(cFile+".OK",cDirOrig,cDirDest,cFile2)
   SI100LoadArray(cFile+".ERR",cDirOrig,cDirDest,cFile2)

   For nX:=1 To Len(aDetailTxt)
      // ** Atualiza o EE9 ...
      SI100AtuRe(aDetailTxt[nX][1],aDetailTxt[nX][2],aDetailTxt[nX][3],aDetailTxt[nX][6],lErro)

      // ** Atualiza o EER ...
      SI100ATUEER(EEC->EEC_PREEMB,cFile2,If(!lErro,SI_SF,SI_ER),aDetailTxt[nX][3],aDetailTxt[nX][4],If(EECFLAGS("CONSIGNACAO"),aDetailTxt[nX][2],""))

      //ER - Atualiza os Detalhes do RE
      If EECFLAGS("CONSIGNACAO")
	     SI100AtuDet(EEC->EEC_PREEMB,aDetailTxt[nX][2],aDetailTxt[nX][1])
      EndIf

   Next

   // ** By JBJ 11/08/2003 - Final da gravação das informações do RE no(s) item(ns).
   If !lErro
      If EasyEntryPoint("EECPSI01")
         ExecBlock("EECPSI01",.f.,.f.,{"","PE_ENDGRV"})
      Endif
   EndIf

Return Nil

/*
Funcao      : SI100LoadArray
Parametros  :
Retorno     : NIL
Objetivos   : Carregar array com os dados do retorno do TXT
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/04/2002 17:43
Revisao     :
Obs.        :
*/
Static Function SI100LoadArray(cFile,cDirOrig,cDirDest,cFile2)

Local cLine := "", cPreEmb := "", cHora := "",dData := AVCTOD(""), nLidos := 0, hFile,lFileOk:=.f.,cSeqSisc:="",;
      aOrd:=SaveOrd("EE9"),cRe:="",nPos:=0,cDiretorio:=EasyGParam("MV_AVG0002")

Local cOldAnexo:="",cOldTxt:="",nPosAnexo:=0

#define FO_READ       0    // Open for reading (default)
#define FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)

Begin Sequence

   If File(cDirOrig+cFile)
      hFile := EasyOpenFile(cDirOrig+cFile,FO_READ+FO_EXCLUSIVE)
      nSize:=FSeek(hFile,0,2)

      FSeek(hFile,0,0)

      IF fError() != 0
         MsgStop(STR0044+LTrim(Str(fError())),STR0003) //"Erro do DOS nro. "###"Aviso"
         Break
      Endif

      If Right(cFile,3)=".OK"
         lFileOk:=.t.
      EndIf

   Else
      Break
   EndIf

   DO While nLidos < nSize

      nLidos += SI100ReadLn(hFile,@cLine,nSize)

      IF Empty(cLine)
         Loop
      ElseIf !lFileOk .And. Left(cLine,2)#"NP"
         Loop
      Endif

      If !lWizardRe
         If cInfLer
            MsgInfo(STR0045+cFile+CRLF+STR0046+Ltrim(Str(nLidos))+CRLF+STR0047+cLine) //"File: "###"Lidos: "###"Linha: "
         EndIf
      EndIf

      IF Empty(cPreEmb)


         IF lFileOk
            cPreEmb := Substr(cLine,1,20)
         Else
            cPreEmb := Substr(cLine,3,20)
         Endif

         nPos:=aScan(aEmbarque,{|aX| aX[1]=cPreEmb })

         If nPos = 0
            aAdd(aEmbarque,{Transf(AvKey(cPreEmb,"EEC_PREEMB"),AvSx3("EEC_PREEMB",AV_PICTURE)),{},{}}) // Embarque ...
            nPos:=Len(aEmbarque)
         EndIf


         IncProc(AVSX3("EEC_PREEMB",AV_TITULO)+" "+Transf(cPreEmb,AVSX3("EEC_PREEMB",AV_PICTURE)))

         EEC->(dbSeek(xFilial()+AvKey(cPreEmb,"EEC_PREEMB")))

         If aScan(aProcs,cPreEmb) = 0
            aAdd(aProcs,cPreEmb)
         EndIf

      Endif

      IF lFileOk
         cSeqSisc := AvKey(Substr(cLine,21,6),"EE9_SEQEMB")
         cHora    := StrTran(Substr(cLine,51,5),":","")
         dData    := AVCTOD(Substr(cLine,41,10))
         cRe      := Substr(cLine,27,02)+Substr(cLine,30,07)+Substr(cLine,38,03)

         aAdd(aDetailTxt,{cSeqSisc,cRe,dData,cHora,"OK",cLine})

         // ** Carrega as informacoes do Txt,dos anexos, e do seqsis
         If (Left(cFile,8)#cOldTxt)
            aAdd(aEmbarque[nPos][2],Left(cFile,8))// ** Nome Txt.Ok
         EndIf

         If (cRe # cOldAnexo)
            //aAdd(aEmbarque[nPos][2],{Transf(cRe,AvSx3("EE9_RE",AV_PICTURE)),{}}) // ** Anexo
            aAdd(aEmbarque[nPos][2],{Transf(cRe,AvSx3("EE9_RE",AV_PICTURE))+cSeqSisc+cPreEmb,{}}) // ** Anexo
            //nPosAnexo++
         EndIf

         nPosAnexo:=LEN(aEmbarque[nPos][2])//AWR - 19/04/2007 - A variavel nPosAnexo era zerada quando trocava de arquivo.
         //aAdd(aEmbarque[nPos][2][1+nPosAnexo][2],cSeqSisc) // ** SeqSisc
         IF nPosAnexo # 0
            aAdd(aEmbarque[nPos][2][nPosAnexo][2],Transf(cRe,AvSx3("EE9_RE",AV_PICTURE))+cSeqSisc+cPreEmb) // ** SeqSisc
         ENDIF

      Else
         lErro    := .t.
         cSeqSisc := AvKey(Substr(cLine,23,6),"EE9_SEQEMB")
         cHora    := StrTran(Substr(cLine,39,5),":","")
         dData    := AVCTOD("")
         cRe      := ""

         aAdd(aDetailTxt,{cSeqSisc,cRe,dData,cHora,"ERR",cLine})

         If (Left(cFile,8)#cOldTxt)
            aAdd(aEmbarque[nPos][3],Left(cFile,8))// ** Nome Txt.Err
         EndIf

      Endif
      cOldTxt:=Left(cFile,8)
      cOldAnexo:=cRe
   EndDo

   If Right(cDiretorio,1)#"\"
      cDiretorio+="\"
   EndIf

   aAdd(aDetalhe,{cFile,Directory(cDiretorio+cFile)})

   fClose(hFile)

   // ** Apaga os arquivos do diretorio ORISISC
   If File(cDirOrig+cFile)
     copy file (cDirOrig+cFile) to (cDirDest+cFile)
     fErase(cDirOrig+cFile)
   EndIf

   If File(cDirOrig+cFile2)
     copy file (cDirOrig+cFile2) to (cDirDest+cFile2)
     fErase(cDirOrig+cFile2)
   EndIf

   /*
   // ** Guarda o nro do processo de embarque para futura atualizacao do status ....
   If aScan(aProcs,{|aFind| aFind[1] = cPreEmb}) = 0
      aAdd(aProcs,{cPreEmb,lErro})
   EndIf
   */
End Sequence

RestOrd(aOrd)

Return Nil

/*
Funcao      : SI100AtuRe
Parametros  : lAtualiza => .t. - Geração Ok
                           .f. - Geração Erro
Retorno     : NIL
Objetivos   : Atualizar EE9 com os dados da RE
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/04/2002 17:15
Revisao     :
Obs.        :
*/
Static Function SI100AtuRe(cSeqSisc,cRe,dDtRe,cLine,lErro)

Local aOrd:=SaveOrd("EE9")

Begin Sequence

   EE9->(DbSetOrder(9))
   IF EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB+cSeqSisc))

      DO While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB;
         .And. EE9->EE9_SEQSIS == cSeqSisc

         EE9->(RecLock("EE9",.F.))

         EE9->EE9_STATUS := If(lErro,SI_ER,SI_SF)
         EE9->EE9_RE     := if(lErro,"",cRe)
         EE9->EE9_DTRE   := if(lErro,AvCtod(""),dDtRe)

         IF ! lErro
            // *** CAF 19/04/2001 - Gravacao de dados no EE9
            IF EasyEntryPoint("EECPSI01")
               ExecBlock("EECPSI01",.F.,.F.,{cLine,"PE_GRV"})
            Endif
         Endif

         EE9->(MsUnlock())
         EE9->(dbSkip())
      Enddo

   Else
      MsgStop(STR0049+CRLF+CRLF+; //"Erro de integridade no TXT ! "
      AVSX3("EEC_PREEMB",AV_TITULO)+" "+Transf(EEC->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE))+STR0050+cSeqSisc+STR0051,STR0003) //", Sequencia de Embarque "###" não encontrada !"###"Aviso"
   Endif

End Sequence

RestOrd(aOrd)

Return Nil

/*
Funcao      : SI100Status
Parametros  :
Retorno     : NIL
Objetivos   : Atualizar Status EEC
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/04/2002 18:34
Revisao     :
Obs.        :
*/
Static Function SI100Status(cProcesso)

Local aOrd:=SaveOrd("EEC"), cStatus := SI_SF // SISCOMEX Finalizado

Begin Sequence

   EEC->(DbSetOrder(1))

   If EEC->(dbSeek(xFilial()+cProcesso))

      EEC->(RecLock("EEC",.F.))

      EE9->(dbSetOrder(2))
      EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))

      While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB

         IF EE9->EE9_STATUS <> SI_SF
            IF EE9->EE9_STATUS == SI_ER // Erro SISCOMEX
               cStatus := SI_ER
               Exit
            Else
               cStatus := SI_AS // Aguardando Liberacao SISCOMEX
            Endif
         Endif

         EE9->(dbSkip())
      Enddo

      IF cStatus == SI_AS .And. !Empty(EEC->EEC_LIBSIS)
         cStatus := SI_LS // Aguardando envio para siscomex
      Endif

      EEC->EEC_STASIS := cStatus
      EEC->(MsUnlock())
   EndIf

End Sequence

RestOrd(aOrd)

Return Nil

/*
Funcao      : SI100ReadFile
Parametros  : cFile, cDirDest
Retorno     : NIL
Objetivos   : Leitura dos arquivos para Retorno Siscomex
Autor       : Cristiano A. Ferreira
Data/Hora   : 21/12/1999 10:40
Revisao     :
Obs.        :

Static Function SI100ReadFile(cFile,cDirOrig,cDirDest,nSize,aArqErr)

Local lArqOk := ".OK" $ cFile,lArqErr := ".ERR" $ cFile,;
      cLine := "", cPreEmb := "", cHora := "",;
      lLocked := .F., lAllOk := .F.,;
      dData := AVCTOD(""), nLidos := 0,hFile,cFile2,oBrowNote

//LOCAL lRC := .F. // Processo com Registro de Credito

//PRIVATE lATOCON := .T. // Indica se o campo Ato Concessório está vazio

#define FO_READ       0    // Open for reading (default)
#define FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)

Begin Sequence

   // Abre o arquivo para leitura no modo exclusivo ...
   hFile := EasyOpenFile(cDirOrig+cFile,FO_READ+FO_EXCLUSIVE)
   IF lArqErr
     AADD(aArqErr,cFile)
   ENDIF

   IF fError() != 0
      MsgStop(STR0044+LTrim(Str(fError())),STR0003) //"Erro do DOS nro. "###"Aviso"
      Break
   Endif

   DO While nLidos < nSize
      nLidos += SI100ReadLn(hFile,@cLine,nSize)
      // Alterado por Heder M Oliveira - 2/15/2000
      IF Empty(cLine)
         LOOP
      ELSEIF !lArqOk .AND. LEFT(cLINE,2)#"NP"
         LOOP
      Endif

      IF cInfLer
        MsgInfo(STR0045+cFile+CRLF+STR0046+Ltrim(Str(nLidos))+CRLF+STR0047+cLine) //"File: "###"Lidos: "###"Linha: "
      ENDIF
      IF Empty(cPreEmb)
         IF lArqOk
            cPreEmb := Substr(cLine,1,20)
         Else
            cPreEmb := Substr(cLine,3,20)
         Endif
         IncProc(AVSX3("EEC_PREEMB",AV_TITULO)+" "+Transf(cPreEmb,AVSX3("EEC_PREEMB",AV_PICTURE)))

         IF EEC->(dbSeek(xFilial()+AvKey(cPreEmb,"EEC_PREEMB")))
            EEC->(RecLock("EEC",.F.))
            lLocked := .t.
         Else
            MsgStop(AVSX3("EEC_PREEMB",AV_TITULO)+" "+Transf(cPreEmb,AVSX3("EEC_PREEMB",AV_PICTURE))+STR0048,STR0003) //" não encontrado !"###"Aviso"
            fClose(hFile)
            Break
         Endif
      Endif


      IF lArqOk
         lRC   := SI100LineOk(cLine,cFile)
         cHora := StrTran(Substr(cLine,51,5),":","")
         dData := AVCTOD(Substr(cLine,41,10))

      Else
         lRC   := SI100LineErr(cLine,cFile)
         cHora := StrTran(Substr(cLine,39,5),":","")
         dData := AVCTOD(Substr(cLine,29,10))

      Endif
   Enddo

   fClose(hFile)
   IF ! lRC
      EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))
      DO While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And.;
         EE9->EE9_PREEMB == EEC->EEC_PREEMB
         IF (lATOCON .AND. EMPTY(EE9->EE9_ATOCON)) .OR.;
            (! lATOCON .AND. ! EMPTY(EE9->EE9_ATOCON))
            IF EE9->EE9_STATUS <> SI_SF
               IF TYPE("SB1->B1_REPOSIC") <> "U" .AND. Posicione("SB1",1,xFilial("SB1")+EE9->EE9_COD_I,"B1_REPOSIC") $ cSim
                  EE9->(dbSkip())
                  Loop
               Endif
               lAllOk := .f.
               Exit
            Endif
         ENDIF
         lAllOk := .t.
         EE9->(dbSkip())
      Enddo
   ELSE
      lALLOK := .T.
   ENDIF

   cFile2 := Substr(cFile,1,At(".",cFile)-1)

   IF File(cDirOrig+cFile2+".INC")
      cFile2 += ".INC"
   ELSEIF File(cDirOrig+cFile2+".ALT")
      cFile2 += ".ALT"
   Endif
   // Alterado por Heder M Oliveira - 2/22/2000
   IF lAllOk
      IF nPROC = EEC->EEC_TOTITE
         IF ! lLocked
            EEC->(RecLock("EEC",.F.))
            lLocked := .t.
         Endif
         EEC->EEC_STASIS := SI_SF
         SI100ATUEER(EEC->EEC_PREEMB,cFile2,SI_SF,dDATA,cHORA)
      ENDIF
   ELSE
      IF ! lLocked
         EEC->(RecLock("EEC",.F.))
         lLocked := .t.
      Endif
      EEC->EEC_STASIS := SI_ER
      EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))
      DO While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And.;
         EE9->EE9_PREEMB == EEC->EEC_PREEMB
         *
         IF (lATOCON .AND. EMPTY(EE9->EE9_ATOCON)) .OR.;
            (! lATOCON .AND. ! EMPTY(EE9->EE9_ATOCON))
            EE9->(RecLock("EE9",.F.))
            EE9->EE9_STATUS :=SI_ER
            EE9->EE9_RE     := ""
            EE9->EE9_DTRE   := AVCTOD("")
            EE9->(MSUnlock())
         ENDIF
         EE9->(dbSkip())
      Enddo
      SI100ATUEER(EEC->EEC_PREEMB,cFile2,SI_ER,dDATA,cHORA)
   Endif

   IF lLocked
      EEC->(MSUnlock())
   Endif

   IF FILE(cDirOrig+cFile)
     copy file (cDirOrig+cFile) to (cDirDest+cFile)
     fErase(cDirOrig+cFile)
   ENDIF

   IF FILE(cDirOrig+cFile2)
     copy file (cDirOrig+cFile2) to (cDirDest+cFile2)
     fErase(cDirOrig+cFile2)
   ENDIF

End Sequence

Return NIL
*/
/*
Funcao      : SI100ReadLn
Parametros  : hFile, @cVar, nSize
Retorno     : Proxima Linha a ser lida
Objetivos   : Leitura dos arquivos para Retorno Siscomex
Autor       : Cristiano A. Ferreira
Data/Hora   : 21/12/1999 11:10
Revisao     :
Obs.        :
*/
Function SI100ReadLn(hFile,cVar,nSize)



Local cBuffer := ""
Local cAux    := ""

Local nBytes  := BLOCK_READ
Local nEndLine:= 0
Local nPos    := 0

Begin Sequence

   While (nEndLine := At(CRLF,cAux)) == 0 .And. (nPos:=fSeek(hFile,0,1))<nSize
      IF nBytes > (nSize-nPos)
         nBytes := (nSize-nPos)
      Endif
      cBuffer := Space(nBytes)
      fRead(hFile,@cBuffer,nBytes)
      cAux += cBuffer
   Enddo

   IF nPos < nSize
      nVolta := (Len(cAux)+1) - nEndLine
      nVolta -= 2
      fSeek(hFile,-nVolta,1)
      cVar := Substr(cAux,1,nEndLine-1)
   ELSE
      cVar := cAux
   ENDIF

End Sequence

Return Len(cVar)+2 // +2 por causa do CRLF

*--------------------------------------------------------------------
FUNCTION SI100Note(aArqErr,cDirDest)

LOCAL   aCpos := {{"WK_ARQ",,STR0052}} //"Arquivo"
Local bCancel := {|| oDlg:End() }
Local bOK := {|| oDlg:End() }, Ind:=0

IF LEN(aArqErr) == 0
  RETURN
ENDIF

FOR Ind:=1 TO LEN(aArqErr)
   WorkNote->(DBAPPEND())
   WorkNote->WK_Arq := aArqErr[Ind]
NEXT

WorkNote->(dbGoTop())

DEFINE MSDIALOG oDlg TITLE STR0053  FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Arquivos com Erro"
 oBrowNote:= MsSelect():New("WorkNote",,,aCpos,,,PosDlg(oDlg))
 oBrowNote:bAval:={||Winexec("NotePad"+" "+cDirDest+WorkNote->WK_ARQ )}
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)

RETURN .T.

/*
Funcao      : SI100GrvTemp
Parametros  : cPreEmb,nAgrupa
Retorno     : NIL
Objetivos   : Grava itens de um processo
Autor       : Cristiano A. Ferreira
Data/Hora   : 03/02/2000 17:02
Revisao     :
Obs.        :
*/
Static Function SI100GrvTemp(cPreEmb, nAgrupa, cForcar, cCNPJ, cRE)

Local aOrd := SaveOrd({"EE9","SA2"}) // A funcao SI100TabAgr altera a ordem do
                                      // EE9 baseado no tipo de agrupamento
Local bAgrupa, cAgrupa
Local aReposic := {}, nPesLiq := 0
Local nQtde := 0, nPrecoTot := 0, nPrecoFob := 0
Local lRet := .f., aRegAgru := {}, lPE := EasyEntryPoint("EECPSI00"), i
//Local cExpFabr:=IF(EMPTY(EEC->EEC_EXPORT+EEC->EEC_EXLOJA),EEC->EEC_FORN+EEC->EEC_FOLOJA,EEC->EEC_EXPORT+EEC->EEC_EXLOJA)
Local cCgc, nPos, nQtdOld, nValOld, nVlFob

// ** By JBJ - 31/10/2002 - 14:14
//LOCAL X,Y,cUFOLD := "",cUFATU,nTOTFOB,nDESCONPRO, nLinhas:=0
LOCAL Y,cUFOLD := "",/*cUFATU,*/nTOTFOB,nDESCONPRO, nLinhas:=0

//Local cDescTemp:="",nLinDesc:=0
Local nLinDesc:= 0
Local cRC := "", cCodEnq := ""
Local cRV // ** By JBJ - 24/07/02 - 15:50
LOCAL cUmTon  //cUMCONV  - TLM 28/02/08  Alterado para private, chamada da função SI101MtAtos , programa EECSI101
Local nQtdDet:=0, nx:=0, X_Local:=0

//ER - 06/09/2007 - Define se o Desconto será subtraído(.T.) ou somado(.F.) no Valor Fob, quando o preço for fechado.
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)
//Local lQuebraDesc := EasyGParam("MV_AVG0171", .T.) .And. EasyGParam("MV_AVG0171",, .F.) //WFS - 18/08/08 //DFS - 16/07/12 - Retirado parâmetro para que, utilize de acordo com o novo parâmetro MV_AVG0212
//Eduardo/ WFS - 23/09/2008 - variável que informará se existem dados do Fabricante para os itens de embarque - EYU
Local lExistEYU := .F.
Local cDestaque := "" //DFS - 13/03/12 - Declaração da variável para que, ao selecionar opção de filtro na geração de RE, sistema não apresente error.log
Local nEW0Valor := 0
//Guarda a quantidade de itens de cada RE
Local nMercsRE := 0
Private lEmpInd := .F.
Private X , cUMCONV, cUFATU
Private cDescTemp:= ""
Private aCposAux := {}  //DFS - 16/07/12 - Inclusão de array auxiliar para cópia dos campos gravados no aCpos.

SA2->(dbSetOrder(1))

If Type("nSemCobCamb") <> "N"
  nSemCobCamb := 0
EndIf
If Type("nSeqSisc") <> "N"  // GFP - 28/08/2014
   nSeqSisc := 0
EndIf
Begin Sequence
   cUMCONV := ""

   //wfs - 11/2012
   //If !EECFlags("NOVOEX") .OR. lAddAnexos
   //   Work->(avzap())
   //EndIf

   aEE9    := {}
   bAgrupa := SI100TabAgr(nAgrupa)

   // CALCULA O TOTAL FOB DO PROCESSO
   EEC->(DBSETORDER(1))
   EEC->(DBSEEK(XFILIAL("EEC")+cPREEMB))
   nVLATOCON := 0
   nTOTFOB   := EEC->((EEC_TOTPED+EEC_DESCON)-;
                      (EEC_FRPREV+EEC_FRPCOM+EEC_SEGPRE+EEC_DESPIN+AvGetCpo("EEC->EEC_DESP1")+AvGetCpo("EEC->EEC_DESP2")))

    // VALIDAÇÃO PARA VERIFICAR SE A MODALIDADE DE PAGAMENTO NÃO TEM COBERTURA CAMBIAL - MPG - 03/01/2018
    IF EEC->EEC_COBCAM # cSim .And. EEC->EEC_MPGEXP == "006" // S.Cobertura Cambial
        lEEFSCC := .T. 
    EndIf

   // ** By JBJ - 09/04/02 - Busca o último nro da sequencia...
   EE9->(DbSetOrder(9))
   EE9->(AVSeekLast(xFilial("EE9")+cPREEMB))

   nSeqSisc :=if(EECFlags("NOVOEX"),If(lAddAnexos.AND.nSeqSisc==0,0,nSeqNovoEx),Val(AllTrim(EE9->EE9_SEQSIS)))  // GFP - 28/08/2014

   // BUSCA OS ITENS NA ORDEM SELECIONADA
   EE9->(dbSeek(xFilial()+cPreEmb))
   DO WHILE ! EE9->(EOF()) .AND.;
      EE9->(EE9_FILIAL+EE9_PREEMB) = (XFILIAL("EE9")+cPREEMB)

      /*
      AMS - 19/05/2005. 1º - Verifica se o CNPJ da unidade exportadora no item(cCNPJItem) é igual ao
                             que esta sendo passado como parametro(cCNPJ).
                        2º - Verifica se a RE no item é igual ao que esta sendo passado como
                             parametro (cRE).
      */
      cCNPJItem := CNPJUnidExp(EE9->EE9_PREEMB, EE9->EE9_SEQEMB)
      If lWizardRE

         cREItem   := ContentMark("WorkAgrup", "WK_FLAG", "EXO_RE")

         If !Empty(cREItem)
            cREItem := &(cREItem)+EE9->EE9_AGRE
         Else
            cREItem := EE9->EE9_AGRE
         EndIf

      Else
         //AAF 31/01/2007 - Correção da Quebra de RE's para item com e sem Drawback.
         cREItem   := ""

      EndIf

      //cREItem += If(Empty(EE9->EE9_ATOCON), "AV", "AP") //AV = "Ato Vazio", AP = "Ato Preenchido". // By JPP - 14/11/2007 - 14:00
      //cREItem += If(Empty(EE9->EE9_ATOCON), "AV",EE9->EE9_ATOCON) //AV = "Ato Vazio", "Numero Ato Preenchido". // By JPP - 14/11/2007 - 14:00
      cREItem += If(Empty(EE9->EE9_ATOCON), "AV",EE9->EE9_ATOCON+EE9->EE9_SEQED3) //AV = "Ato Vazio", "Numero Ato Preenchido". // By JPP - 14/11/2007 - 14:00 - wfs - 11/2012

      If lItFabric // By JPP - 14/11/2007 - 14:00 - Efetua a quebra de RE quando o item de embarque possuir 2 atos concessórios diferentes(itens intermediários) para o mesmo Cnpj.
         nI := Ascan(aItFabric,{|x| x[2] == EE9->EE9_SEQEMB})
         If nI > 0
            cREItem := cREItem + StrZero(aItFabric[nI,4],3)
         EndIf
      EndIf

      If cCNPJItem <> cCNPJ .or. cRE <> cREItem
         EE9->(dbSkip())
         Loop
      EndIf

      // ** By JBJ 08/04/2002 - Gera apenas os pedidos marcados...
      TRB1->(DbSetOrder(1))
      TRB1->(DbSeek(EE9->EE9_PEDIDO+EE9->EE9_RE))

      If Empty(TRB1->WK_FLAG)
         EE9->(DbSkip())
         Loop
      EndIf

      cCodEnq := EEC->EEC_ENQCOD

      If !Empty(EE9->EE9_ATOCON)
         If lIntEDC // ** Verifica se esta integrado ao EDC ...
            ED0->(DbSetOrder(2))
         Endif
         If lIntEDC .And. ED0->(DbSeek(xFilial("ED0")+EE9->EE9_ATOCON))
            cCodEnq := ED0->ED0_ENQCOD
         Else
            If EEC->(FIELDPOS("EEC_ENQCOX")) # 0
               cCodEnq := EEC->EEC_ENQCOX
            Else
               cCodEnq := AvKey("81101","EEC_ENQCOD")
            EndIf
         EndIf
      EndIf
      // ** By OMJ - 06/02/03 - 15:09 ...
      SI100AddEnq(cCodEnq)

      If lWizardRe .and. !Empty(EE9->EE9_AGSUFI)
         EE9->(aAdd(aEE9AgSufixo, {Recno(),;
                                   cCodEnq+EE9_RC+If(lField_RV, EE9_RV, "")+EE9_AGSUFI+BuscaExportador(EE9_FABR, EE9_FALOJA, "A2_EST")+If(lCatCot, EE9->EE9_CATCOT, "")}))   // GFP - 02/08/2012 - Categoria da Cota
      Else

         // ** By JBJ - 24/07/02 - 15:55 ...
         //DFS - 08/11/12 - Inclusao do codigo do item para ordenar corretamente os itens com mesmas descrições.
         EE9->(AADD(aEE9,{RECNO(),cCodEnq+EE9_RC+If(lField_RV,EE9_RV,"")+EVAL(bAGRUPA)+POSICIONE("SA2",1,xFILIAL("SA2")+EE9->(EE9_FABR+EE9_FALOJA),"A2_EST")+If(lCatCot, EE9->EE9_CATCOT, ""),EE9->EE9_COD_I}))   // GFP - 02/08/2012 - Categoria da Cota
      EndIf

      EE9->(DBSKIP())
   ENDDO

   //DFS - 08/11/12 - Inclusao da terceira posicao do array para posicionar corretamente nas descrições iguais
   aEE9    := ASORT(aEE9,,,{|X,Y| X[2]+X[3] < Y[2]+Y[3]})
   cAgrupa := Space(Len(Eval(bAgrupa)))
   cCodEnq := ""

   ChkFile("SJ5")
   IF SELECT("SJ5") > 0 // Verifica se o cliente esta usando o cadastro de conversao ...
      IF Len(aEE9) > 0
         EE9->(DBGOTO(aEE9[1,1]))
         SYD->(DBSETORDER(1))
         SYD->(DBSEEK(XFILIAL("SYD")+EE9->EE9_POSIPI))
         cUMCONV := SYD->YD_UNID
      Endif
   ENDIF

   // PROCESSA O VETOR DOS ITENS NA ORDEM SELECIONADA
   aItFabProc := {} // By JPP - 14/11/2007 - 14:00
   aAtosLidos := {} // By JPP - 14/11/2007 - 14:00
   If lSemCobCamb
      nSemCobCamb:= 0  //TRP-03/03/2009
   Endif
   FOR X_Local := 1 To LEN(aEE9)

      X := X_Local

      EE9->(DBGOTO(aEE9[X,1]))

      IF SB1->(FieldPos("B1_REPOSIC")) > 0
         IF Posicione("SB1",1,xFilial("SB1")+EE9->EE9_COD_I,"B1_REPOSIC") $ cSim
            cCodMemo := Posicione("EE2",2,xFilial("EE2")+MC_CPRO+TM_GER+AvKey(EE9->EE9_COD_I,"EE2_COD")+PORTUGUES,"EE2_TEXTO")
            cDescItem := Alltrim(Memoline(MSMM(cCodMemo,AVSX3("EE2_VM_TEX",AV_TAMANHO)),60,1))
            AADD(aREPOSIC, {CDESCITEM,EE9->EE9_PSLQTO})
            Loop
         Endif
      Endif

      IF Empty(cForcar)
         IF !((EE9->EE9_STATUS <> SI_SF .And. !Empty(EE9->EE9_RE)) .Or.;
              (EE9->EE9_STATUS <> SI_RS .And. Empty(EE9->EE9_RE)))
            Loop
         Endif
      Endif

      lRet     := .T.
      cUFATU := POSICIONE("SA2",1,xFILIAL("SA2")+EE9->(EE9_FABR+EE9_FALOJA),"A2_EST")

      If EECFlags("NOVOEX") .AND. Empty(EE9->(EE9_FABR+EE9_FALOJA))
         cUFATU := POSICIONE("SA2",1,xFILIAL("SA2")+EE9->(EE9_FORN+EE9_FOLOJA),"A2_EST")
      EndIf

      //AMS - 02/07/2003 - Tendo o campo Ato Concessório preenchido e o campo Fabricante vazio é pego os dados do fornecedor.
      If !Empty( EE9->EE9_ATOCON ) .and. Empty( EE9->EE9_FABR )
         cUFATU := Posicione( "SA2", 1, xFilial( "SA2" )+EE9->( EE9_FORN+EE9_FOLOJA ), "A2_EST" )
      EndIf

      /*EDUARDO/ WFS - 23/09/2008 -- Verificação da existência de dados do Fabricante para os itens
      de embarque de exportação.*/
      lExistEYU := .F.
      lEmpInd  := .F.
      EYU->(DbSetOrder(1))
      If EYU->(DbSeek(xFilial("EYU")+EE9->EE9_PREEMB+EE9->EE9_SEQEMB))
         lExistEYU := .T.
         If EYU->(DbSeek(xFilial("EYU")+EE9->EE9_PREEMB+EE9->EE9_SEQEMB+"1")) //Verifica se existe Empresa Industrial.
            lEmpInd := .T.
         EndIf
      EndIf

      IF (cAgrupa != Eval(bAgrupa)) .Or.;
         (lPE .And. ExecBlock("EECPSI00",.F.,.F.,{"QB",aRegAgru,nAgrupa})) .OR.;
         (cUFOLD # cUFATU) .OR.;
         (cRC <> EE9->EE9_RC) .Or.;
         (cCodEnq <> SubStr(aEE9[X,2],1,Len(EEC->EEC_ENQCOD))) .Or.;
         (If(lField_RV,(cRV <> EE9->EE9_RV),.F.)) .Or.; // ** By JBJ - 24/07/02 - 15:52
         lExistEYU .OR.;
         (If(lCatCot,(cCatCota <> EE9->EE9_CATCOT),.F.)) // GFP - 01/08/2012 - Quebra por Categoria da Cota
         *
         cRC      := EE9->EE9_RC

         // ** By JBJ - 24/07/02 - 15:53
         If lField_RV
            cRV := EE9->EE9_RV
         EndIf

         If lCatCot  // GFP - 01/08/2012 - Categoria da Cota
            cCatCota := EE9->EE9_CATCOT
         EndIf

         cUFOLD   := cUFATU
         cAgrupa  := Eval(bAgrupa)
         If !EECFlags("NOVOEX") .OR. lAddAnexos
            nSeqSisc := nSEQSISC+1
         EndIf

         cCodEnq  := SubStr(aEE9[X,2],1,Len(EEC->EEC_ENQCOD))

         IF !Empty(nQtde)
            Work->EE9_SLDINI := nQtde
            Work->WK_SLDINI  := nQtde

            Work->WK_PRCTOT  := nPrecoFob //Total FOB.
            Work->EE9_PRCTOT := nPrecoTot //Total CIF.
            Work->EE9_PSLQTO := nPesLiq
            If lSemCobCamb
               Work->EE9_VLSCOB := nSemCobCamb  //TRP- 03/03/2009
            Endif
            ChkFile("SJ5")
            IF SELECT("SJ5") > 0 // Verifica se o cliente esta usando o cadastro de conversao ...
               //WORK->WK_SLDINI  := AVTRANSUNI(AvKey(WORK->EE9_UNIDAD,"EE9_UNIDAD"),cUMCONV,WORK->EE9_COD_I,WORK->EE9_SLDINI,.F.) // Qtde Uni Mercadoria
               WORK->WK_SLDINI  := ConvQtdAto(AvKey(WORK->EE9_UNIDAD,"EE9_UNIDAD"),cUMCONV,WORK->EE9_COD_I,WORK->EE9_SLDINI,"Work")  // Qtde Uni Mercadoria   // GFP - 22/09/2014
               // by CAF 13/08/2003 - Qdo tiver RV a Qtde. devera ser enviada em TL
               IF lField_RV .And. !Empty(Work->EE9_RV)
                  IF EE9->(FieldPos("EE9_UNPES")) > 0 .And. !Empty(EE9->EE9_UNPES)
                     cUmTon := ALLTRIM(EasyGParam("MV_AVG0030",,""))
                     cUmTon := IF(cUmTon=".","",cUmTon)
                     cUmTon := AvKey(cUmTon,"AH_UNIMED")

                     IF Empty(cUmTon)
                        //MsgInfo(STR0105+CRLF+STR0106,STR0003) //"Problema: O parametro MV_AVG0030 não foi encontrado !"###"Solução: Cadastre o parametro no módulo Configurador, MV_AVG0030 - Tipo: Caracter - Descrição: Código da U.M. Tonelada - Conteúdo: ??"###"Aviso"
                     Else
                        Work->EE9_SLDINI := Round(AVTRANSUNI(WORK->EE9_UNPES,cUmTon,,Work->EE9_PSLQTO,.F.),5) // Qtde Uni Comercializada
                     Endif
                  Else
                     // Padrão do Easy é KG
                     Work->EE9_SLDINI := Round(Work->EE9_PSLQTO/1000,5) // Qtde Uni Comercializada
                  Endif
                  Work->WK_SLDINI := Work->EE9_SLDINI
               Endif
            ENDIF

            // *** by CAF 17/03/2001 Gravacao da Descricao
            IF lPE
               ExecBlock("EECPSI00",.F.,.F.,{"GR",aRegAgru,nAgrupa,"1"})
            Endif
         Endif

         Work->(dbAppend())
         //Registra quantos itens estão relacionados neste RE
         nMercsRE := 0
         AvReplace("EE9","Work")
         ChkFile("SJ5")
         Work->TRB_REC_WT:= EE9->(Recno())
         IF SELECT("SJ5") > 0 // Verifica se o cliente esta usando o cadastro de conversao ...
            SYD->(DBSETORDER(1))
            SYD->(DBSEEK(XFILIAL("SYD")+EE9->EE9_POSIPI))
            cUMCONV := SYD->YD_UNID
         ENDIF
         Work->WK_ENQCOD  := cCodEnq
         Work->EE9_SEQSIS := Str(nSeqSisc,AVSX3("EE9_SEQSIS",3))
         cCodMemo := Posicione("EE2",2,xFilial("EE2")+MC_CPRO+TM_GER+AvKey(EE9->EE9_COD_I,"EE2_COD")+PORTUGUES,"EE2_TEXTO")
         //WFS 13/05/09
         //Se a descrição não estiver cadastrada no idioma do processo, traz a descrição que está digitada no item do processo.
         If Empty(cCodMemo)
            cCodMemo:= EE9->EE9_DESC
         EndIf
         cDescTemp :=MSMM(cCodMemo,AVSX3("EE2_VM_TEX",AV_TAMANHO))
         nLinDesc  :=MlCount(cDescTemp,AVSX3("EE2_VM_TEX",AV_TAMANHO))
         cDescItem :=""

         //DFS - 16/07/12 - Inclusão de tratamento para que, só pegue a descrição temporária, se não utilizar a opção de agrupamento por NCM
         If !(nAgrupa == 2 .Or. nAgrupa == 3 .Or. nAgrupa == 4 .Or. nAgrupa == 6 )
            cDescItem:= cDescTemp
         EndIf

         //DFS - 09/11/12 - Retirado antigo tratamento que colocava aspas nas descrições.
         If (nAgrupa == 2 .Or. nAgrupa == 3 .Or. nAgrupa == 4 .Or. nAgrupa == 6 )//WFS - 16/09/08 --- nAgrupa == 6 para alteração de RE. WFS 01/06/09
            For nX:=1 To nLinDesc
               cDescItem += AllTrim(StrTran(Memoline(cDescTemp,AVSX3("EE2_VM_TEX",AV_TAMANHO),nX),ENTER, ""))
            Next
         EndIf

         //DFS - 09/11/12 - Retirado antigo tratamento que colocava aspas nas descrições.
         //Work->EE9_VM_DES := IF(Empty(cDescItem),"", cDescItem) + Posicione("SYC",4,xFilial("SYC")+AVKEY(PORTUGUES,"YC_IDIOMA")+AVKEY(EE9->EE9_FPCOD,"YC_COD"),"YC_NOME")
         //wfs 11/2012 usado em ponto de entrada
         Work->EE9_VM_DES := cDescItem //NCF - 27/02/2017 - Caso o parâmetro esteja ligado, pode haver uma ou mais agentes de comissão vinculados à um mesmo item e por isso o total vai para o campo do processo.
         Work->WK_PERCOM  := IF(!EasyGParam("MV_AVG0077",,.F.) .And. !Empty(EE9->EE9_PERCOM) , EE9->EE9_PERCOM , ((EEC->EEC_VALCOM/EEC->EEC_TOTFOB)*100) ) // by CAF 27/07/2001 Percentual comissao por item

         WORK->WK_TEMOBS := "N"

         If lObs
            WORK->WK_TEMOBS := IF(!Empty(MSMM(EEC->EEC_CODOBP,AVSX3("EEC_OBSPED",AV_TAMANHO))),"S","N")
            cMemoObs:=StrTran(MSMM(EEC->EEC_CODOBP,AVSX3("EEC_OBSPED",AV_TAMANHO)),CRLF,Space(1))
            nLinhas:= Int(Len(cMemoObs)/75)+If(Len(cMemoObs)/75-Int(Len(cMemoObs)/75)>0,1,0)
            For nX:=1 To nLinhas
              Work->(FieldPut(FieldPos("WK_OBS"+AllTrim(Str(nX))),SubStr(cMemoObs,1+(nX-1)*75,75*nX)))
            Next
            // ** By JBJ 08/08/03 - 11:35 (Gravar a observação de documentos para todos os anexos).
            //lObs:=.F.
         EndIf

         nPesLiq   := 0
         nQtde     := 0
         nPrecoTot := 0
         nPrecoFob := 0
         If lSemCobCamb
            nSemCobCamb:= 0  //TRP-03/03/2009
         Endif
         aRegAgru  := {}

      //Endif - WFS - 16/09/08
         //WFS - 24/09/2008
         //se existe uma adição na tabela EYU, dados do fabricante do item, força a quebra do agrupamento por NCM
         //para o próximo agrupamento
         If lExistEYU
             cAgrupa:= ""
         EndIF

         IF lPE  //LCS
            ExecBlock("EECPSI00",.F.,.F.,{"GR_DSC_SISC",aRegAgru,nAgrupa,"1"})  //LCS
         Endif  //LCS

         //wfs 11/2012 usado em ponto de entrada
         cDescItem:= Work->EE9_VM_DES

         //DFS - 16/07/12 - Só deverá entrar se utilizar a opção de agrupamento por NCM
      ElseIf (nAgrupa == 2 .Or. nAgrupa == 3 .Or. nAgrupa == 4 .Or. nAgrupa >= 6) //nAgrupa == 6 para alteração de RE. WFS 01/06/09 -- // WFS - 21/09/2012 - ou para agrupamentos incluidos pelo usuário
         //*** WFS - 16/09/08
         /*
            Tratamento para inserir sempre a descrição completa de todos os itens no R.E., quando agrupado por N.C.M.
            apenas. Caso as descrições sejam maiores do que o permitido pelo Siscomex (QTDLINHAS - Número de linhas
            permitidas, QTDCARACTER - Quantidade de caracteres por linhas), o sistema automaticamente irá inserir
            uma nova quebra para o R.E., com a mesma N.C.M, para registrar o restante da descrição.
         */

         //DFS - 16/07/12 - Caso utilize separação de mercadorias, zera a variável cDescTemp
         If lSepMerc
            cDescTemp:= ""
         EndIf
         cCodMemo  := Posicione("EE2",2,xFilial("EE2")+MC_CPRO+TM_GER+AvKey(EE9->EE9_COD_I,"EE2_COD")+PORTUGUES,"EE2_TEXTO")
         //WFS 27/05/09
         //Se a descrição não estiver cadastrada no idioma do processo, traz a descrição que está digitada no item do processo.
         If Empty(cCodMemo)
            cCodMemo:= EE9->EE9_DESC
         EndIf
         cDescTemp := MSMM(cCodMemo,AVSX3("EE2_VM_TEX",AV_TAMANHO))
         cDescTemp := StrTran(cDescTemp,ENTER, " ")

         IF lPE  //LCS
            cDESCTEMP := ExecBlock("EECPSI00",.F.,.F.,{"GR_DSC_SISC",aRegAgru,nAgrupa,"2"})  //LCS
         Endif  //LCS

         //nLinDesc  := MlCount(cDescTemp,QTDCARACTER)

         //DFS - 16/07/12 - Verifica se utiliza ou não separação de mercadorias. Se não, inclue a barra "/", se não, coloca uma descrição por linha
         If !lSepMerc
            If !GetDescItem(cDescTemp)
               cDescItem:= AllTrim(StrTran(Work->EE9_VM_DES, ENTER, "") )
               If !Empty(cDescTemp)
                 cDescItem += " / " + cDescTemp
               EndIf
            EndIf
         Else
            cDescItem:= cDescTemp/*AllTrim(StrTran(Work->EE9_VM_DES, ENTER, "") ) */
         EndIf

         /*
            Se a descrição do próximo item não couber no espaço disponível na tela de registro do
            Siscomex (MCEX501C), retorna para o laço do FOR, para gerar um novo registro (agrupamento) na Work.
         */

         //DFS - 29/08/12 - Quando não utilizar a separação de mercadoria, a descrição poderá ter tamanho de 750 caracteres por linha.
                           //Se utilizar a separação de mercadoria a descrição poderá ter 130 caracteres por linha.
         If !lSepMerc
            If Len(cDescItem)>730
               cAgrupa:= ""
               X_Local--
               Loop //retorna para o laço for
            EndIf
         Else
            If Len(cDescItem)>130
               cAgrupa:= ""
               X_Local--
               Loop //retorna para o laço for
            EndIf
         EndIf
         //DFS - 16/07/12 - Work recebe o que está na variável cDescItem.
         Work->EE9_VM_DES:= cDescItem// + cDescTemp

         // *** Final do tratamento
      EndIf

	  If EECFLags("NOVOEX")
         //cDescItem := Work->EE9_VM_DES

	     //TRP - 16/02/2012 - Ponto de Entrada para alterar a descrição do item.
	     If EasyEntryPoint("EECSI100")
            ExecBlock("EECSI100",.F.,.F.,"ALTERA_DESCRI")
         EndIf

	     //DFS - 16/07/12 -  Verifica o Recno, o parâmetro (MV_AVG0212) e a função (GetDescItem) para decidir se grava separado as descrições ou separados por barra (/).
	     If !lSepMerc .AND. (nPosMerc := aScan(aMercsRE,{|X| X[1] == Work->(RecNo())})) > 0 ;
	        .OR. lSepMerc .AND. (nPosMerc := aScan(aMercsRE,{|X| X[1] == Work->(RecNo()) .AND. (nPos:=aScan(X[3],{|Y| Y[1] == "DESCR"})) > 0 .AND. X[3][nPos][2] == cDescItem})) > 0

   	        aAdd(aMercsRE[nPosMerc][2],EE9->(RecNo()))
   	        If !lSepMerc
   	           aMercsRE[nPosMerc][3][1][2] := cDescItem
   	        EndIf

   	        If nMercsRE == 5
   	           cAgrupa:= ""
   	        EndIf

	     Else

		    aCpos := {{"DESCR",cDescItem}}
		    aAdd(aMercsRE,{Work->(RecNo()),{EE9->(RecNo())},aClone(aCpos)})
		    //Registra quantos itens estão relacionados neste RE
		    ++nMercsRE
		    nPosMerc := Len(aMercsRE)

		    //If Len(cDescItem) > 150 .OR. Len(aMercsRE) == 5//Limite da Descricao para varios itens no Siscomex ...
		    If Len(cDescItem) > 130 .Or. nMercsRE == 5//Caso ultrapasse 5 itens em um mesmo RE, inicia novo agrupamento
   		       cAgrupa:= ""
		    EndIf
		 EndIf
		  //DFS - 16/07/12 - Inclusão da descrição temporária no array.
		  AADD(aCposAux,cDescTemp)
	  EndIf

      /// GRAVA A SEQUENCIA DO SISCOMEX NOS ITENS
      EE9->(RECLOCK("EE9",.F.))
      EE9->EE9_SEQSIS  := WORK->EE9_SEQSIS

      EE9->(MSUNLOCK())

      nDESCONPRO := 0
      IF EEC->EEC_PRECOA $ cSim .Or. EasyGParam("MV_AVG0085",,.F.)//RMD - No preço fechado este parâmetro define se o desconto será aplicado aos itens
         // JPM - 21/03/06 - no cálculo de fatores de multiplicação, não se deve arredondar o fator, pois só diminui a precisão.
         //nDESCONPRO := ROUND((EE9->EE9_PRCINC/nTOTFOB)*100,2)    // % FOB DO TOTAL
         nDESCONPRO := (EE9->EE9_PRCINC/nTOTFOB)*100    // % FOB DO TOTAL
         nDESCONPRO := ROUND((EEC->EEC_DESCON*nDESCONPRO)/100,2) // VALOR DO DESCONTO P/ O %
      ENDIF

      //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
      If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. EEC->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
         nVLFOB := Round(EE9->EE9_PRCINC,2)-nDESCONPRO              // VALOR NO LOCAL DO EMBARQUE COM O DESCONTO
      Else
         nVLFOB := Round(EE9->EE9_PRCINC,2)+nDESCONPRO
      EndIf

      // Nos incoterms EXW, FAS, FOB e FCA - Valor Condição Venda = Valor no Local de Embarque
      IF EEC->EEC_INCOTERM $ "EXW/FAS/FOB/FCA"
         nVlFob := Round(EE9->EE9_PRCTOT,2)
      Else
         // Verifica se o valor na Condicao de Venda eh menor que o valor no
         // Local de Embarque
         IF Round(EE9->EE9_PRCTOT,2) < nVlFob
            nVlFob := Round(EE9->EE9_PRCTOT,2)
         Endif
      EndIf

      // Verifica se existe o campo FOB por item
      IF EE9->(FieldPos("EE9_FOBPIT")) > 0
         IF EE9->EE9_FOBPIT > 0
            nVlFob := EE9->EE9_FOBPIT
         Endif
      Endif

      // Acumula Valor do Ato Concessorio
      IF ! EMPTY(EE9->EE9_ATOCON)
         nVLATOCON := nVLATOCON+Round(EE9->EE9_PRCTOT,2)
      ENDIF

      If lSemCobCamb
         nSemCobCamb +=  EE9->EE9_VLSCOB  //TRP-03/03/2009
      Endif

      //OAP - 19/01/2011
      /*   nQtdTrans := EasyConvQt(EE9->EE9_COD_I,{{AvKey(EE9->EE9_UNIDAD,"EE9_UNIDAD"),EE9->EE9_SLDINI}},cUMCONV,.F.,@oObErroNEx)
         If ValType(nQtdTrans) == "U" .OR. nQtdTrans == -1
            nQtdTrans := 0
         EndIf
      //nQtdTrans := AVTRANSUNID(AvKey(EE9->EE9_UNIDAD,"EE9_UNIDAD"),cUMCONV,EE9->EE9_COD_I,EE9->EE9_SLDINI,.F.) // Qtde Uni Mercadoria
      */

      // BAK - 02/05/2011 - Alteração para verificar se está compilado a função EasyConvQt(), caso contrario realiza o processo anterior
      If lEasyConvQt
         nQtdTrans := EasyConvQt(EE9->EE9_COD_I,GetEE9Qtds(),GetSYDUnid(cUMCONV, GetEE9Qtds()),.F.,@oObErroNEx)
         If ValType(nQtdTrans) == "U" .OR. nQtdTrans == -1
            nQtdTrans := 0
         EndIf
      Else
         nQtdTrans := AVTRANSUNID(AvKey(EE9->EE9_UNIDAD,"EE9_UNIDAD"),cUMCONV,EE9->EE9_COD_I,EE9->EE9_SLDINI,.F.) // Qtde Uni Mercadoria
      EndIf

      // AMS - 02/07/2003 - Gravar dados para T5 quando houver fabricante ou ato concessório preenchido.
      //WFS - 23/09/08 - Existindo dados e itens de embarque para o Fabricante (lExistEYU), estes serão
      // considerados na Work.
      IF EECFlags("NOVOEX") .OR. ! EMPTY(EE9->EE9_FABR+EE9->EE9_FALOJA) .or. !Empty( Work->EE9_ATOCON ) .or. lExistEYU
         // Exportador Não é o Fabricante
         nPos := 0
         IF EECFlags("NOVOEX") .OR. (Empty(Work->WK_UF1) .Or. Work->WK_UF1 == cUFATU)
            If EECFlags("NOVOEX") .OR. !lItFabric .or. (!lEmpInd .and. !Empty(EE9->EE9_FABR)) // By JPP - 14/11/2007 - 14:00
               For i := 1 To 10
                   cCgc := Work->(FieldGet(FieldPos("WK_CGC"+Ltrim(Str(i)))))
                   cNbm := Work->(FieldGet(FieldPos("WK_NBM"+Ltrim(Str(i)))))
                   /*WFS 09/03/09 - Verificação da existência do destaque da NCM na tabela
                                    de cadastro da NCM --- */
                   //cDestaque := Left(EE9->EE9_POSIPI,8)+"00" nopado por WFS 09/03/09
                   SYD->(DBSetOrder(1))
                   If SYD->(DBSeek(xFilial()+EE9->EE9_POSIPI))
                      If !EMPTY(SYD->YD_SISCEXP)
                         cDestaque := Left(EE9->EE9_POSIPI,8) + SYD->YD_SISCEXP//SYD->YD_DESTAQU
                      Else
                         cDestaque := Left(EE9->EE9_POSIPI,8) + "00"
                      EndIf
                   EndIf
                   //---
                   // By OMJ - 09/12/2004 - Buscar o destaque do Embarque.
                   If EE9->(FieldPos("EE9_DTQNCM")) > 0
                      cDestaque := Left(EE9->EE9_POSIPI,8)+If(!Empty(EE9->EE9_DTQNCM),EE9->EE9_DTQNCM,"00")
                   EndIf

                   IF Empty(cCgc) .Or. AllTrim(SA2->A2_CGC)+cDestaque == cCgc+cNbm
                      nPos := i
                      Exit
                   Endif

               Next

               IF nPos > 0 .And. nPos <= 10
                  Work->(FieldPut(FieldPos("WK_CGC"+Ltrim(Str(nPos))),SI100CNPJ(SA2->A2_COD+SA2->A2_LOJA)))

                  // By OMJ - 09/12/2004 - Buscar o destaque do Embarque.
                   /*WFS 09/03/09 - Verificação da existência do destaque da NCM na tabela
                                    de cadastro da NCM --- */
                   //cDestaque := Left(EE9->EE9_POSIPI,8)+"00" nopado por WFS 09/03/09
                   SYD->(DBSetOrder(1))
                   If SYD->(DBSeek(xFilial("SYD")+EE9->EE9_POSIPI))
                      If !EMPTY(SYD->YD_SISCEXP)
                         cDestaque := Left(EE9->EE9_POSIPI,8) + SYD->YD_SISCEXP//SYD->YD_DESTAQU
                      Else
                         cDestaque := Left(EE9->EE9_POSIPI,8) + "00"
                      EndIf
                   EndIf

                   //---
                  If EE9->(FieldPos("EE9_DTQNCM")) > 0
                     cDestaque := Left(EE9->EE9_POSIPI,8) + If(!Empty(EE9->EE9_DTQNCM),EE9->EE9_DTQNCM,"00")
                  EndIf
                  Work->(FieldPut(FieldPos("WK_NBM"+Ltrim(Str(nPos))),cDestaque))
                  Work->(FieldPut(FieldPos("WK_UF" +Ltrim(Str(nPos))),SA2->A2_EST))
                  Work->(FieldPut(FieldPos("WK_ATO"+Ltrim(Str(nPos))),EE9->EE9_ATOCON))

                  // by CAF 13/08/2003 - Qdo tiver RV a Qtde. devera ser enviada em TL
                  nQtdDet := EE9->EE9_SLDINI
                  ChkFile("SJ5")
                  IF SELECT("SJ5") > 0 // Verifica se o cliente esta usando o cadastro de conversao ...
                     If !EasyGParam("MV_AVG0127",,.F.)   // By JPP - 30/10/2006 - 17:00 - Inclusão do MV_AVG0127 - Em clientes como a DEICMAR, este valor não pode ser convertido para unidade da NCM.
                        //OAP - 19/01/2011
                        /*nQtdDet  := EasyConvQt(EE9->EE9_COD_I,{{EE9->EE9_UNIDAD,EE9->EE9_SLDINI}},cUMCONV,.F.,@oObErroNEx)
                        If ValType(nQtdDet) == "U" .OR. nQtdDet == -1
                           nQtdDet := 0
                        EndIf  */
                        // ** By JBJ - 24/09/03 - 13:17.
                        //nQtdDet  := AvTransUnid(EE9->EE9_UNIDAD,cUMCONV,EE9->EE9_COD_I,EE9->EE9_SLDINI,.F.) // Qtde Uni Mercadoria

                        // BAK - 02/05/2011 - Alteração para verificar se está compilado a função EasyConvQt(), caso contrario realiza o processo anterior
                        If lEasyConvQt
                           nQtdDet  := EasyConvQt(EE9->EE9_COD_I,GetEE9Qtds(),GetSYDUnid(cUMCONV, GetEE9Qtds()),.F.,@oObErroNEx)
                           If ValType(nQtdDet) == "U" .OR. nQtdDet == -1
                              nQtdDet := 0
                           EndIf
                        Else
                           nQtdDet  := AvTransUnid(EE9->EE9_UNIDAD,cUMCONV,EE9->EE9_COD_I,EE9->EE9_SLDINI,.F.) // Qtde Uni Mercadoria
                        EndIf

                     EndIf

                     IF lField_RV .And. !Empty(Work->EE9_RV)
                        nQtdDet := EE9->EE9_PSLQTO

                        IF EE9->(FieldPos("EE9_UNPES")) > 0 .And. !Empty(EE9->EE9_UNPES)
                           cUmTon := ALLTRIM(EasyGParam("MV_AVG0030",,""))
                           cUmTon := IF(cUmTon=".","",cUmTon)
                           cUmTon := AvKey(cUmTon,"AH_UNIMED")

                           IF Empty(cUmTon)
                              //MsgInfo(STR0105+CRLF+STR0106,STR0003) //"Problema: O parametro MV_AVG0030 não foi encontrado !"###"Solução: Cadastre o parametro no módulo Configurador, MV_AVG0030 - Tipo: Caracter - Descrição: Código da U.M. Tonelada - Conteúdo: ??"###"Aviso"
                           Else
                              nQtdDet := Round(AVTRANSUNI(WORK->EE9_UNPES,cUmTon,,nQtdDet,.F.),3) // Qtde Uni Comercializada
                           Endif
                        Else
                           // Padrão do Easy é KG
                           nQtdDet := Round(nQtdDet/1000,3) // Qtde Uni Comercializada
                        Endif
                     Endif
                  ENDIF

                  nQtdOld := Work->(FieldGet(FieldPos("WK_QTD"+Ltrim(Str(nPOs)))))
                  Work->(FieldPut(FieldPos("WK_QTD"+Ltrim(Str(nPos))),nQtdOld+nQtdDet))

                  nValOld := Work->(FieldGet(FieldPos("WK_VAL"+Ltrim(Str(nPos)))))
                  Work->(FieldPut(FieldPos("WK_VAL"+Ltrim(Str(nPos))),nValOld+nVlFob+nSemCobCamb))

                  // SE A MODALIDADE DE PAGAMENTO NÃO TEM COBERTURA CAMBIAL leva só o valor cambial sem cobertura - MPG - 03/01/2018
                  IIf( !lIntEDC .and. lEEFSCC , nEW0Valor := nSemCobCamb , nEW0Valor := nVlFob+nSemCobCamb  )

                  If EECFlags("NOVOEX") .AND. !lEmpInd //DFS - 18/04/2012 - Inclusão de validação para que, só envie os dados quando for Empresa Industrial
             	     If (nPosFab := aScan(aMercsRE[nPosMerc][3],{|Y| Y[1] == "FABRICANTE" .AND. Y[2][aScan(Y[2],{|Z| Z[1] == "EWO_CGC"})][2]+Y[2][aScan(Y[2],{|Z| Z[1] == "EWO_UF"})][2] == SI100CNPJ(SA2->A2_COD+SA2->A2_LOJA)+SA2->A2_EST})) == 0
             	        aCpos := {{"EWO_CGC",SI100CNPJ(SA2->A2_COD+SA2->A2_LOJA)},;
                                  {"EWO_UF",If(SA2->A2_EST <> "EX",SA2->A2_EST,SA2->A2_UFFIC)},;  // GFP - 22/06/2015
                                  {"EWO_QTD",nQtdTrans},{"EWO_PESO",EE9->EE9_PSLQTO},;
                                  {"EWO_VALOR",nEW0Valor}}

             	        aAdd(aMercsRE[nPosMerc][3],{"FABRICANTE",aClone(aCpos)})
             	     Else
                        aCpos := {{"EWO_QTD",nQtdTrans},{"EWO_PESO",EE9->EE9_PSLQTO},{"EWO_VALOR",nVlFob+nSemCobCamb}}

 	                    For i := 1 To Len(aCpos)
               	           if (nPos := aScan(aMercsRE[nPosMerc][3][nPosFab][2],{|Y| Y[1] == aCpos[i][1]})) == 0
 	                          aAdd(aMercsRE[nPosMerc][3][nPosFab][2],aClone(aCpos[i]))
		            	   Else
			                  aMercsRE[nPosMerc][3][nPosFab][2][nPos][2] += aCpos[i][2]
			               EndIf
                        Next i
                     EndIf
                  EndIf
               EndIf
            Else
               nPos := SI101MtAtos(nVlFob) // By JPP - 14/11/2007 - 14:00
            Endif
         EndIf
         IF nPos < 1 .Or. nPos > 10
            // Nao gravou os dados do fabricante ...
            cAgrupa := Space(Len(Eval(bAgrupa))) // focar quebra no agrupamento
            X       := X-1
            Loop // Nao pular de registro, processar novamente em um novo anexo
         Endif
      ENDIF

      aAdd(aRegAgru,EE9->(RecNo()))

      // AMS - 17/03/2004 às nPesLiq   += EE9->EE9_PSLQTO
      If EE9->(FieldPos("EE9_UNPES")) > 0 .And. !Empty(Work->EE9_UNPES) .and. EasyGParam("MV_AVG0031",, ".") <> "."
		 //OAP - 19/01/2011
         /*nPesLiq   += EasyConvQt(EE9->EE9_COD_I,{{EE9->EE9_UNPES,EE9->EE9_PSLQTO}},EasyGParam("MV_AVG0031"),.F.,@oObErroNEx)
         //nPesLiq   += AVTransUnid(EE9->EE9_UNPES, EasyGParam("MV_AVG0031"), EE9->EE9_COD_I, EE9->EE9_PSLQTO, .F.)*/

         // BAK - 02/05/2011 - Alteração para verificar se está compilado a função EasyConvQt(), caso contrario realiza o processo anterior
         If lEasyConvQt
            nPesLiq += EasyConvQt(EE9->EE9_COD_I,GetEE9Qtds(),GetSYDUnid(EasyGParam("MV_AVG0031"), GetEE9Qtds()),.F.,@oObErroNEx)
         Else
            nPesLiq += AVTransUnid(EE9->EE9_UNPES, EasyGParam("MV_AVG0031"), EE9->EE9_COD_I, EE9->EE9_PSLQTO, .F.)
         EndIf

      Else
         nPesLiq   += EE9->EE9_PSLQTO
      EndIf
      nQtde     += EE9->EE9_SLDINI
      nPrecoTot += Round(EE9->EE9_PRCTOT,2)
      nPrecoFob += Round(nVlFob,2)

	  If EECFlags("NOVOEX")
	     aCpos := {{"TOTAL_FOB",nVlFOB},{"TOTAL_VENDA",EE9->EE9_PRCTOT},{"PESO",EE9->EE9_PSLQTO},;
	               {"QTD",EE9->EE9_SLDINI},{"QTDNCM",nQtdTrans}}

	     For i := 1 To Len(aCpos)
	        if (nPos := aScan(aMercsRE[nPosMerc][3],{|Y| Y[1] == aCpos[i][1]})) == 0
	           aAdd(aMercsRE[nPosMerc][3],aClone(aCpos[i]))
			Else
			   aMercsRE[nPosMerc][3][nPos][2] += aCpos[i][2]
			EndIf
         Next i
	  EndIf

      /*
      If lSemCobCamb
         nSemCobCamb += EE9->EE9_VLSCOB  //TRP-03/03/2009
      Endif
      */
   NEXT

   For I:=1 to Len(aReposic)
      Work->EE9_VM_DES := Work->EE9_VM_DES + " " + aReposic[I,1]
      nPesLiq := nPesLiq + aReposic[I,2]
   Next

   IF !Empty(nQtde)
      Work->EE9_SLDINI := nQtde
      Work->WK_SLDINI  := nQtde

      Work->WK_PRCTOT  := nPrecoFob
      Work->EE9_PRCTOT := nPrecoTot
      Work->EE9_PSLQTO := nPesLiq
      If lSemCobCamb
         Work->EE9_VLSCOB := nSemCobCamb  //TRP-03/03/2009
      Endif
      ChkFile("SJ5")
      IF SELECT("SJ5") > 0 // Verifica se o cliente esta usando o cadastro de conversao ...
         //WORK->WK_SLDINI  := AVTRANSUNI(AvKey(WORK->EE9_UNIDAD,"EE9_UNIDAD"),cUMCONV,WORK->EE9_COD_I,WORK->EE9_SLDINI,.F.) // Qtde Uni Mercadoria
         WORK->WK_SLDINI  := ConvQtdAto(AvKey(WORK->EE9_UNIDAD,"EE9_UNIDAD"),cUMCONV,WORK->EE9_COD_I,WORK->EE9_SLDINI,"Work")  // Qtde Uni Mercadoria   // GFP - 22/09/2014
         // by CAF 13/08/2003 - Qdo tiver RV a Qtde. devera ser enviada em TL
         IF lField_RV .And. !Empty(Work->EE9_RV)
            IF EE9->(FieldPos("EE9_UNPES")) > 0 .And. !Empty(EE9->EE9_UNPES)
               cUmTon := ALLTRIM(EasyGParam("MV_AVG0030",,""))
               cUmTon := IF(cUmTon=".","",cUmTon)
               cUmTon := AvKey(cUmTon,"AH_UNIMED")

               IF Empty(cUmTon)
                //MsgInfo(STR0105+CRLF+STR0106,STR0003) //"Problema: O parametro MV_AVG0030 não foi encontrado !"###"Solução: Cadastre o parametro no módulo Configurador, MV_AVG0030 - Tipo: Caracter - Descrição: Código da U.M. Tonelada - Conteúdo: ??"###"Aviso"
               Else
                   Work->EE9_SLDINI := Round(AVTRANSUNI(WORK->EE9_UNPES,cUmTon,,Work->EE9_PSLQTO,.F.),5) // Qtde Uni Comercializada
               Endif
            Else
               // Padrão do Easy é KG
               Work->EE9_SLDINI := Round(Work->EE9_PSLQTO/1000,5) // Qtde Uni Comercializada
            Endif
            Work->WK_SLDINI := Work->EE9_SLDINI
         Endif
      ENDIF

      // *** by CAF 17/03/2001 Gravacao da Descricao
      IF EasyEntryPoint("EECPSI00")
         ExecBlock("EECPSI00",.F.,.F.,{"GR",aRegAgru,nAgrupa,"2"})
      Endif
   Endif

   Work->(dbGotop())

End Sequence

nSeqNovoEx := nSeqSisc

RestOrd(aOrd)

Return lRet

/*
Funcao      : SI100GrvEE9
Parametros  : cPreEmb,nAgrupa
Retorno     : .T./.F.
Objetivos   : Grava itens de um processo
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/02/2000 09:02
Revisao     :
Obs.        :
*/
Static Function SI100GrvEE9(cPreEmb,nAgrupa)

Local aOrd := SaveOrd("EE9") // A funcao SI100TabAgr altera a ordem do
                             // EE9 baseado no tipo de agrupamento
Local lRet := .f.

Begin Sequence

   EE9->(dbSeek(xFilial()+cPreEmb))

   DO While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And.;
      EE9->EE9_PREEMB == cPreEmb

      IF !((EE9->EE9_STATUS <> SI_SF .And. EE9->EE9_STATUS <> SI_RS) .Or.;
           (EE9->EE9_STATUS <> SI_RS .And. Empty(EE9->EE9_RE)))
         EE9->(DBSKIP())
         LOOP
      Endif

      // ** By JBJ 08/04/2002 - Gera apenas os pedidos marcados...
      TRB1->(DbSetOrder(1))
      TRB1->(DbSeek(EE9->EE9_PEDIDO+EE9->EE9_RE))

      If Empty(TRB1->WK_FLAG)
         EE9->(DbSkip())
         Loop
      EndIf

      lRet := .t.

      // Atualiza Status dos Itens do Embarque ...
      EE9->(RecLock("EE9",.F.))
      EE9->EE9_STATUS := SI_RS
      EE9->(MSUnlock())

      EE9->(DBSKIP())
   ENDDO

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : SI100EditTemp
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Edita itens a serem exportados para o Siscomex
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/02/2000 07:54
Revisao     :
Obs.        :
*/
Static Function SI100EditTemp(nAgrupa)

Local oDlg, nOpcA := 0
Local bOk, bCancel
Local oMsSelect, aPos

//Local cMarca := GetMark() // ** By JBJ - 08/04/2002

Local aCpos  := { {{|| Work->EE9_SEQSIS},,AVSX3("EE9_SEQSIS",AV_TITULO)},;
                  {{|| Transf(Work->EE9_COD_I,AVSX3("EE9_COD_I",AV_PICTURE))},,AVSX3("EE9_COD_I",AV_TITULO)},;
                  {{|| MemoLine(Work->EE9_VM_DES,60,1)},,AVSX3("EE9_VM_DES",AV_TITULO)},;
                  {{|| TRANSFORM(Work->EE9_POSIPI,AVSX3("EE9_POSIPI",AV_PICTURE))},,AVSX3("EE9_POSIPI",AV_TITULO)},;
                  {{|| TRANSFORM(Work->EE9_NALSH ,AVSX3("EE9_NALSH" ,AV_PICTURE))},,AVSX3("EE9_NALSH",AV_TITULO)},;
                  {{|| TRANSFORM(Work->EE9_PSLQTO,AVSX3("EE9_PSLQTO",AV_PICTURE))},,AVSX3("EE9_PSLQTO",AV_TITULO)},;
                  {{|| TRANSFORM(Work->EE9_SLDINI,AVSX3("EE9_SLDINI",AV_PICTURE))},,STR0054},; //"Qtd.Unid.Comercial"
                  {{|| TRANSFORM(Work->WK_SLDINI ,AVSX3("EE9_SLDINI",AV_PICTURE))},,STR0055},; //"Qtd.Unid.Mercadoria"
                  {{|| TRANSFORM(Work->EE9_PRCTOT, EECPreco("EE9_PRCTOT", AV_PICTURE) )},,STR0056},; //"Preco Cond. Venda"
                  {{|| TRANSFORM(Work->WK_PRCTOT ,EECPreco("EE9_PRCTOT", AV_PICTURE) )},,STR0057} } //"Preco Local de Embarque"

                //{{|| TRANSFORM(Work->EE9_PRCTOT,AVSX3("EE9_PRCTOT",AV_PICTURE))},,STR0056},; //"Preco Cond. Venda"

Local bEdit   := {|| SI100EditIt(oMsSelect) }
Local aButtons := { {"EDIT" /*STR0058*/,bEdit,STR0059} } //"ALT_CAD"###"Alterar Descrição" - DFS - 13/04/12 - Alterado descrição do botão.
Local nPos1, nPos2
If lSemCobCamb
   AADD(aCpos,{{|| TRANSFORM(Work->EE9_VLSCOB,AVSX3("EE9_VLSCOB",AV_PICTURE))},,AVSX3("EE9_VLSCOB",AV_TITULO)})  //TRP-03/03/2009
Endif

//DFS - 12/07/12 - Tratamento para retirar a descrição da tela quando a opção de agrupamento for por NCM e utilizar uma descrição por linha.
If Alltrim(Str(nAgrupa)) $ "2/3/4" .AND. lSepMerc
   nPos := Ascan(aCpos, {|x| x[3] == AVSX3("EE9_VM_DES",AV_TITULO)})
   aDel(aCpos,nPos)
   aSize(aCpos, Len(aCpos) - 1)
EndIf

//DFS - 12/07/12 - Tratamento para retirar o código do item da tela quando a opção de agrupamento for por NCM.
If Alltrim(Str(nAgrupa)) $ "2/3/4"
   nPos := Ascan(aCpos, {|x| x[3] == AVSX3("EE9_COD_I",AV_TITULO)})
   aDel(aCpos,nPos)
   aSize(aCpos, Len(aCpos) - 1)
EndIf

//DFS - 16/07/12 - Para sempre mostrar o item na segunda tela de edição. Anteriormente ficava desposicionada.
Work->(dbGoTop())

Begin Sequence

   DEFINE MSDIALOG oDlg TITLE STR0060  FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Edição de Itens - Siscomex"

      @ 18.2,4.8 SAY AVSX3("EEC_PREEMB",AV_TITULO) PIXEL
      @ 18.2,48  MSGET TRB->EEC_PREEMB SIZE 60,7 WHEN .F. PIXEL
      @ 32.5,4.8 SAY AVSX3("EEC_DTPROC",AV_TITULO) PIXEL
      @ 32.5,48  MSGET TRB->EEC_DTPROC SIZE 40,7 WHEN .F. PIXEL

      aPos := PosDlg(oDlg)
      aPos[1] := 48

      //GFP 26/10/2010
      aCpos := AddCpoUser(aCpos,"EE9","5","Work")

      oMsSelect := MsSelect():New("Work",,,aCpos,@lInverte,@cMarca,aPos) // ** By JBJ - 08/04/02
      //oMsSelect := MsSelect():New("Work",,,aCpos,,,aPos)
      oMsSelect:bAval := bEdit

      bOk     := {|| nOpcA:=1, oDlg:End() }
      bCancel := {|| If(!EECFlags("NOVOEX") .OR. MsgYesNo("Deseja cancelar a geração deste RE?"),oDlg:End(),)}

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

End Sequence

Return (nOpcA != 0)

/*
Funcao      : SI100EditIt
Parametros  : oMsSelect
Retorno     : NIL
Objetivos   : Edita itens a serem exportados para o Siscomex
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/02/2000 07:54
Revisao     :
Obs.        :
*/
Static Function SI100EditIt(oMsSelect)

Local bOk, bCancel, oDlg
Local oMemo
Local nOpcA := 0,nX:=0,nTam:=0
Local oFont
Local nI //DFS - 13/04/12 - Inclusão de variavel para contagem dos itens no array
Local nPos //DFS - 13/04/12 Variavel que receberá as informações do aCols.

Private nLenDlg := 30
Private aCols   := {}
Private aHeader := {}
Private oNewGetDados
Private lAltera:= .T.  //TRP - 07/08/2012 - Para não dar erro na MsNewGetDados em algumas builds.

Begin Sequence

   aAdd(aHeader,{ "Sequência"           , "EE9_SEQSIS" , AVSX3("EE9_SEQSIS",6) , AVSX3("EE9_SEQSIS",3) , AVSX3("EE9_SEQSIS",4) , /*VALIDACAO*/, NIL, AVSX3("EE9_SEQEMB",2) , NIL,NIL } )
   aAdd(aHeader,{ "Descrição do Produto", "EE9_VM_DESC", AVSX3("EE9_VM_DESC",6), AVSX3("EE9_VM_DESC",3), AVSX3("EE9_VM_DESC",4), /*VALIDACAO*/, NIL, AVSX3("EE9_VM_DESC",2), NIL,NIL } )

   nPos2 := nI := aScan(aMercsRe,{|X| X[1] == Work->(Recno())})

   //DFS - 13/04/12 - Inclusão de tratamento para trazer as descrições referentes à cada item, respeitando a opção de agrupamento.
   Do While nI <= Len(aMercsRE) .AND. aMercsRE[nI][1] == Work->(Recno())
      Aadd(aCols,Array(Len(aHeader)+1))
      nPos := Len(aCols)
      aCols[nPos,1] := nI-nPos2+1
      aCols[nPos,2] := aMercsRE[nI][3][1][2]
      aCols[nPos,Len(aCols[nPos])] := .F.
      nI++
   EndDo

   //By OMJ - 07/12/2004
   If EasyEntryPoint("EECPSI00")
      ExecBlock("EECPSI00",.F.,.F.,{"EA",{},0})
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0060 FROM 9,0 TO nLenDlg,80 OF oMainWnd //"Edição de Itens - Siscomex"

   //DFS - 13/04/12 - Inclusão de tela do tipo MSNEWGETDADOS para manipulação das descrições dos itens à serem enviados ao SISCOMEX
   oNewGetDados:= MsNewGetDados():New(081,000,250,400,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",,{"EE9_VM_DESC"},,999,"NaoVazio()",,"SI100DelCols()",oDlg,aHeader,aCols)
   oNewGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

   //By OMJ - 07/12/2004
   If EasyEntryPoint("EECPSI00")
      ExecBlock("EECPSI00",.F.,.F.,{"EG",{},0})
   EndIf

   bOk     := {|| nOpcA:=1, oDlg:End() }
   bCancel := {|| oDlg:End() }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   aCols := aClone(oNewGetDados:aCols)

   nI := aScan(aMercsRe,{|X| X[1] == Work->(Recno())})
   IF nOpcA == 1 // Ok
      nPos := 0
      Do While nI <= Len(aMercsRE) .AND. aMercsRE[nI][1] == Work->(Recno())
         ++nPos
         aMercsRE[nI][3][1][2] := aCols[nPos,2]
         Work->(DbGoTo(aMercsRE[nI][1]))
         Work->EE9_VM_DES := aCols[nPos,2]
         nI++
      EndDo

      //By OMJ - 07/12/2004
      If EasyEntryPoint("EECPSI00")
         ExecBlock("EECPSI00",.F.,.F.,{"ED",{},0})
      EndIf

      oMsSelect:oBrowse:Refresh()
   Endif

End Sequence

Return NIL

/*
Funcao      : SI100TabAgr(nAgrupa)
Parametros  : nAgrupa
Retorno     : bAgrupa
Objetivos   : Codicoes para agrupamento
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/02/2000 07:54
Revisao     :
Obs.        :
*/
Static Function SI100TabAgr(nP_Agrupa)

Local cCpoAgrup   := ""
PRIVATE bAgrupa   := {|| .t. },nAGRUPA

nAGRUPA := nP_AGRUPA
Begin Sequence

   If lWizardRE

      //Nopado por ER - 07/02/2008
      //bAgrupa := &(StrTran("{|| If(Empty(EE9->EE9_AGSUFI),'#', EE9->EE9_AGSUFI)}", "#", AllTrim(ContentMark("WorkAgrup", "WK_FLAG", "EXO_ANEXO"))))
      If Empty(EE9->EE9_AGSUFI)
         cCpoAgrup := AllTrim(ContentMark("WorkAgrup", "WK_FLAG", "EXO_ANEXO"))
         bAgrupa   := bAgrupa := &("{|| " + cCpoAgrup + "}")
      Else
         bAgrupa := {|| EE9->EE9_AGSUFI}
      EndIf

   Else
      Do Case
         Case nAgrupa == 1 .OR. nAGRUPA == 5// agrupado por item OU ITEM POR RC
            bAgrupa   := {|| EE9->EE9_SEQEMB }
            EE9->(dbSetOrder(3))
         Case nAgrupa == 2 // agrupado por ncm + item + preco
            bAgrupa   := {|| EE9->(EE9_POSIPI+EE9_COD_I+AvKey(EE9_PRECOI,"EE9_PRECOI")) }
            EE9->(dbSetOrder(4))
         Case nAgrupa == 3 // agrupado por ncm + preco
            bAgrupa   := {|| EE9->(EE9_POSIPI+AvKey(EE9_PRECOI,"EE9_PRECOI")) }
            EE9->(dbSetOrder(8)) // FILIAL+PREEMB+NCM+PRECO
         Case nAgrupa == 4 // agrupado por ncm
            bAgrupa   := {|| EE9->EE9_POSIPI }
            EE9->(dbSetOrder(4)) // FILIAL+PREEMB+NCM+COD_I
         Case nAgrupa == 6 // WFS 29/05/2009: agrupado por RE, para alterações de RE no Siscomex
            bAgrupa   := {|| EE9->EE9_RE}
      End Case
   EndIf

   IF EasyEntryPoint("EECPSI00")
      ExecBlock("EECPSI00",.F.,.F.,{"AG",{},nAGRUPA})
   ENDIF
END SEQUENCE
RETURN(bAgrupa)

/*
    Funcao   : SI100ATUEER(cPREEMB,cFILE,cSTATUS,dDATA,cHORA)
    Autor    : Heder M Oliveira
    Data     : 15/02/00 14:05
    Revisao  : 15/02/00 14:05
    Uso      : Atualizar status do EER
    Recebe   :
    Retorna  :
*/
STATIC FUNCTION SI100ATUEER(cPREEMB,cFILE,cSTATUS,dDATA,cHORA,cRE)

   Local lRET:=.T.,nOLDAREA:=SELECT()
   Local aOrd := {}
   Default cRE := ""

   BEGIN SEQUENCE
      IF EER->(dbSeek(xFilial("EER")+cPREEMB+cFile))
         EER->(RecLock("EER",.F.))
         EER->EER_STASIS := cSTATUS
         EER->EER_DTLANS := dDATA
         EER->EER_HRLANS := cHORA

         If EECFLAGS("CONSIGNACAO")
            /*
              Caso o aruivo de Retorno possua mais de uma linha,
              ficará gravada o ultimo RE, já que apenas o Anexo será diferente
              em cada Linha.
            */

            aOrd := SaveOrd({"EEC"})

            EEC->(DbSetOrder(1))
            If EEC->(DbSeek(xFilial("EEC")+cPreemb))
               If EEC->EEC_TIPO == PC_RC //Remessa por Consignação
                  EER->EER_RE     := Left(cRE,9) //RE sem Anexo
                  EER->EER_MANUAL := "N"
               EndIf
            EndIf

            RestOrd(aOrd)
         EndIf

         EER->(MsUnlock())
      ENDIF
   END SEQUENCE
   DBSELECTAREA(nOLDAREA)
RETURN lRET

/*
Funcao   : SI100MV
Autor    : Jeferson Barros Jr
Data     : 22/10/00 16:20
Uso      : Definir a opcao de agrupamento de acordo com o parametro MV_AVG0012
Revisao  :
Obs      :
*/
*------------------------*
Static Function SI100MV()
*------------------------*
Local cOpcao := AllTrim(GetNewPar("MV_AVG0012","N")), nOpcao:=0

Begin Sequence
  If cOpcao <> "N"
     nOpcao := Val(cOpcao)
     // ** Verifica se o parametro passado é valido de acordo com as opcoes disponiveis para geracao de re.
     If nOpcao < 1 .Or. nOpcao > OPCGERRE
        nOpcao := SI100SelAgru() // ** Abre a tela de para selecao ...
     EndIf
  Else
     nOpcao := SI100SelAgru()
  EndIf

End Sequence

Return nOpcao

/*
Funcao   : SI100SelPed
Autor    : Jeferson Barros Jr
Data     : 04/04/02 13:08
Uso      : Tela para selecao de pedidos a partir dos embarques selecionados.
Revisao  :
Obs      :
*/
*----------------------------*
Static Function SI100SelPed()
*----------------------------*
Local oDlg,oMark, aPos,cUser, nAgrupa:=0,aCpos:={},nOldArea:=Select(),cTempFile,cTitulo,nGera:=0,;
      aOrd:=SaveOrd("TRB1")

Local bOk     :={||nGera:=1,SI100ChgMk(.F.),oMark:oBrowse:Refresh(),oDlg:End()}
Local bCancel :={||oMark:oBrowse:Refresh(),oDlg:End()}
Local bSelAll :={||If(Empty(TRB2->WK_FLAG),If(SI100ShowRe(.f.,.t.),(SI100MarkAll("TRB2"),oMark:oBrowse:Refresh()),Nil),;
                                                                (SI100MarkAll("TRB2"),oMark:oBrowse:Refresh())) }
Local aButtons := {{"LBTIK",bSelAll ,STR0075}} //"Marca/Desmarca Todos"

Begin Sequence

   If TRB->(Eof()).Or. TRB->(Bof())
      MsgInfo(STR0066,STR0003) //"Nao existe processo selecionado para a selecao de pedido(s) !"###"Aviso"
      Break
   Endif

   aCAMPOS := ARRAY(0)

   aCpos := { { "WK_FLAG",," "},;
              { "WK_PEDIDO",,STR0080},;  //"Pedido   "
              {{|| Transf(TRB2->WK_RE,AVSX3("EE9_RE",AV_PICTURE))},,"Nro. R.E."},;
              { "WK_DTRE  ",,"Dt. R.E. "}}

   aSemSX3:= {{"WK_FLAG","C",02,0},{"WK_PREEMB","C",20,0},{"WK_PEDIDO","C",20,0},;
              {"WK_RE","C",12,0},{"WK_DTRE","C",08,0},{"WK_SEQUEN","C",06,0}}

   //TRP - 29/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

   //MCF - 08/06/2015
   aSemSX3:= AddWkCpoUser(aSemSX3,"EE9")

   // ** Cria work para dados filtrados
   cTempFile := EECCriaTrab(,aSemSX3,"TRB2")

   EECIndRegua("TRB2",cTempFile+TEOrdBagExt(),"WK_PEDIDO+WK_RE")

   Set Index to (cTempFile+TEOrdBagExt())

   // ** Filtra os dados com base no embarque...
   TRB1->(DbSetOrder(2))
   TRB1->(DbSeek(TRB->EEC_PREEMB))
   Do While TRB1->(!Eof()) .And. TRB1->WK_PREEMB = TRB->EEC_PREEMB
      TRB2->(DbAppend())
      AvReplace("TRB1","TRB2")
      TRB2->TRB_ALI_WT:= "EEC"
      TRB2->TRB_REC_WT:= EEC->(Recno())
      TRB1->(DbSkip())
   EndDo

   TRB2->(dbGoTop())

   cTitulo:=STR0072+AllTrim(AvSX3("EEC_PREEMB",AV_TITULO))+": "+AllTrim(Transf(TRB->EEC_PREEMB,AvSx3("EEC_PREEMB",AV_PICTURE))) //"Selecao de Pedidos - "

   DEFINE MSDIALOG oDlg TITLE  cTitulo FROM 9,0 TO 28,80 OF oMainWnd


      aPos := PosDlg(oDlg)
      aPos[1] := 31//20

      //GFP 26/10/2010
      aCpos := AddCpoUser(aCpos,"EE9","2")

      oMark := MsSelect():New("TRB2","WK_FLAG",,aCpos,@lInverte,@cMarca,aPos)
      oMark:bAval := {|| If(Empty(TRB2->WK_FLAG),;
                                (If(!SI100ShowRe(.f.),;
                                TRB2->WK_FLAG:="",TRB2->WK_FLAG:=cMarca),;
                                oMark:oBrowse:Refresh()),;
                         (TRB2->WK_FLAG:="",oMark:oBrowse:Refresh()))}

      oMark:oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

   // ** Grava o TRB1 de acordo com os pedidos marcados/desmarcados do TRB2
   // ** Se o botão sair for acionado, ele não altera o TRB1, não gravando os itens marcados/desmarcados
   If nGera = 1
      TRB1->(DbSetOrder(1))

      TRB2->(DbGoTop())

      Do While TRB2->(!Eof())
         TRB1->(DbSeek(TRB2->WK_PEDIDO+TRB2->WK_RE))
         If Empty(TRB2->WK_FLAG) // Se estiver desmarcado no TRB2 desmarca no TRB1
            TRB1->WK_FLAG:=""
         Else
            TRB1->WK_FLAG:=TRB2->WK_FLAG
         EndIf

         TRB2->(DbSkip())
      EndDo

   EndIf

   TRB2->(E_EraseArq(cTempFile))

End Sequence

DbSelectArea(nOLDAREA)

RestOrd(aOrd)

Return Nil

/*
Funcao     : SI100AddPed
Parametros : lMarca -> .t. adiciona pedidos marcados.
                       .f. adiciona pedidos não marcados.
Autor      : Jeferson Barros Jr
Data       : 04/04/02 13:59
Uso        : Inclui registro no Work de pedidos
Revisao    :
Obs        :
*/
*---------------------------------*
Static Function SI100AddPed(lMarca)
*---------------------------------*
Local aOrd:=SaveOrd("EE9")

Begin Sequence

   EE9->(DbSetOrder(2))
   EE9->(dbSeek(xFilial()+TRB->EEC_PREEMB))

   Do While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And. EE9->EE9_PREEMB == TRB->EEC_PREEMB

      TRB1->(DbSetOrder(1))
      If !TRB1->(DbSeek(EE9->EE9_PEDIDO+EE9->EE9_RE))
         TRB1->(DbAppend())
         TRB1->WK_FLAG   := If(lMarca,cMarca,"")
         TRB1->WK_PREEMB := TRB->EEC_PREEMB
         TRB1->WK_PEDIDO := EE9->EE9_PEDIDO
         TRB1->WK_RE     := EE9->EE9_RE
         TRB1->WK_DTRE   := Transf(EE9->EE9_DTRE,"  /  /  ")
         TRB1->WK_SEQUEN := EE9->EE9_SEQUEN

         // ** Atualiza a coluna PEDIDO
         TRB->WK_PEDIDO:=If(lMarca,STR0081,"") //"Todos"

      Else
         TRB1->WK_FLAG   := cMarca
      EndIf

      EE9->(DbSkip())
   EndDo

   If TRB->(!Eof())
      TRB->WK_INFR := "S"
   EndIf


End Sequence

RestOrd(aOrd)

Return Nil

/*
Funcao    : SI100ChgMk
Parametros: lEmbarque => .t. - Embarque
                         .f. - Pedido
Autor     : Jeferson Barros Jr
Data      : 04/04/02 15:16
Uso       : Sincroniza o marca/desmarca na tela de embarques com a tela de pedidos.
Revisao   :
Obs       :
*/
*-----------------------------------*
Static Function SI100ChgMk(lEmbarque)
*-----------------------------------*
Local nOldArea:=Select(),aOrd:=SaveOrd("TRB1"),lFound:=.f.,cPedidos:="",cTempMarca,;
      lMarcado:=.f.,lTodos:=.t.,aPedidos:={}, nx:=0

Begin Sequence

   If ValType(lEmbarque) == "U"
      Break
   EndIf

   If lEmbarque // ** Desmarca os pedidos a partir do embarque...

      TRB1->(DbSetOrder(2))

      // ** Verifica se existe algum pedido já marcado...
      TRB1->(DbSeek(TRB->EEC_PREEMB))
      Do While TRB1->(!Eof()) .And. TRB1->WK_PREEMB == TRB->EEC_PREEMB
         If !Empty(TRB1->WK_FLAG)
            lMarcado:=.t.
         EndIf
         TRB1->(DbSkip())
      EndDo

      If TRB1->(DbSeek(TRB->EEC_PREEMB))

         Do While TRB1->(!Eof()) .And. TRB1->WK_PREEMB == TRB->EEC_PREEMB

            If Empty(TRB->WK_FLAG)
               TRB1->WK_FLAG:=""
               TRB->WK_PEDIDO:=""
            Else
               If !lMarcado
                  TRB1->WK_FLAG :=TRB->WK_FLAG
                  TRB->WK_PEDIDO:=STR0081 //"Todos"
               EndIf
            EndIf

            TRB1->(DbSkip())
         EndDo

      EndIf

   Else // ** Desmarca o embarque a partir dos pedidos ...

      TRB2->(DbGoTop())

      Do While TRB2->(!Eof())
         If !Empty(TRB2->WK_FLAG)
            lFound:=.t.
            cTempMarca:=TRB2->WK_FLAG

            If aScan(aPedidos,AllTrim(TRB2->WK_PEDIDO)+", ")=0
               AaDd(aPedidos,AllTrim(TRB2->WK_PEDIDO)+", ")
            EndIf

         Else
            lTodos:=.f. // Indica se todos os pedidos estao marcados ou não ...
         EndIf
         TRB2->(DbSkip())
      EndDo

      If !lFound // ** Se não existir nenhum pedido marcado, desmarca o embarque
         TRB->WK_FLAG :=""
         TRB->WK_PEDIDO:=""
      Else

         TRB->WK_FLAG:=cTempMarca
         For nX:=1 to Len(aPedidos)
            cPedidos+=aPedidos[nX]
         Next

         // ** Atualiza a coluna PEDIDOS com os nomes dos pedidos ou com a palavra todos...
         TRB->WK_PEDIDO:=If(!lTodos,Left(Stuff(cPedidos,Len(cPedidos)-1,1," "),27)+If(Len(cPedidos)>27,"...",""),STR0081) //"Todos"
      EndIf

   EndIf

End Sequence

DbSelectArea(nOldArea)

RestOrd(aOrd)

Return Nil

/*
Funcao      : SI100DelPed
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Exclui pedidos do TRB1 referentes ao embarque deletado.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/04/2002 08:11
Revisao     :
Obs.        :
*/
*----------------------------*
Static Function SI100DelPed()
*----------------------------*
Local aOrd:=SaveOrd("TRB1")

Begin Sequence
   TRB1->(DbSetOrder(2))
   If TRB1->(DbSeek(TRB->EEC_PREEMB))
      Do While TRB1->(!Eof()) .And. TRB1->WK_PREEMB == TRB->EEC_PREEMB
         TRB1->(DbDelete())
         TRB1->(DbSkip())
      EndDo
   EndIf
End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : SI100ShowRe()
Parametros  : lEmbarque -> Tela de embarque ou tela de pedidos.
              lMarcaAll -> Se .t. Botao marca todos
Retorno     : NIL
Objetivos   : Exibe nro(s) de RE(s) e pede confirmação para a geração de nova(s) RE(s)
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/04/2002 13:17
Revisao     :
Obs.        :
*/
*-----------------------------------------------*
Static Function SI100ShowRe(lEmbarque,lMarcaAll,cPedido)
*-----------------------------------------------*
Local lRet:=.f., aOrd:=SaveOrd("EE9"),aNrRe:={},nOldArea:=Select(),;
      cRe:="",nRecno:=0, nx:=0

Default lMarcaAll :=.f.

Begin Sequence
   If Valtype(lEmbarque) = "U"
      Break
   EndIf

   If Valtype(cPedido) = "U"
      cPedido  := TRB->EEC_PREEMB
   EndIf
   If lEmbarque .And. !lMarcaAll // Tela de selecao de embarques ...

      EE9->(DbSetOrder(2))
      EE9->(dbSeek(xFilial()+cPedido/*TRB->EEC_PREEMB*/))
      Do While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And. EE9->EE9_PREEMB == TRB->EEC_PREEMB
         If !Empty(EE9->EE9_RE)
            If AsCan(aNrRe,EE9->EE9_RE)=0
               aAdd(aNrRE,EE9->EE9_RE)
            EndIf
         EndIf
         EE9->(DbSkip())
      EndDo

      If Len(aNrRe) > 0
         For nX:=1 To Len(aNrRe)
            cRE+=AllTrim(Transf(aNrRe[nX],AvSx3("EE9_RE",AV_PICTURE))+If(nX<Len(aNrRe),", "," "))
         Next

         If lShowRE .And. MsgYesNo(STR0069+cRE+STR0068,STR0003) //" ja associada(s) a este processo, deseja gerar nova(s) R.E.(s)?"###"Aviso" //"R.E.(s) "
            lRet:=.t.
         EndIf
      Else
         lRet:=.t.
      EndIf

      If(!lRet,lInclui:=.t.,Nil)

   ElseIf lEmbarque .And. lMarcaAll // Tela de embarques botão marca todos.

      nRecno:=TRB->(RecNo())
      EE9->(DbSetOrder(2))

      TRB->(DbGoTop())
      Do While TRB->(!Eof())

         EE9->(dbSeek(xFilial()+TRB->EEC_PREEMB))

         Do While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And. EE9->EE9_PREEMB == TRB->EEC_PREEMB
            If !Empty(EE9->EE9_RE)
               If AsCan(aNrRe,EE9->EE9_RE)=0
                  aAdd(aNrRE,EE9->EE9_RE)
               EndIf
            EndIf
            EE9->(DbSkip())
         EndDo

         TRB->(DbSkip())
      EndDo

      TRB->(DbGoTo(nRecNo))

      If Len(aNrRe)>0
         For nX:=1 To Len(aNrRe)
            cRE+=AllTrim(Transf(aNrRe[nX],AvSx3("EE9_RE",AV_PICTURE)))+If(nX<Len(aNrRe),", "," ")
         Next

         If lShowRE .And. MsgYesNo(STR0069+cRE+STR0068,STR0003) //"R.E.(s) "###" ja associada(s) a este processo, deseja gerar nova(s) R.E.(s)?"###"Aviso"
            lRet:=.t.
         EndIf
      Else
         lRet:=.t.
      EndIf

   ElseIf !lEmbarque .And. !lMarcaAll // Tela de selecao de pedidos ...

      EE9->(DbSetOrder(1))
      EE9->(dbSeek(xFilial()+TRB2->WK_PEDIDO+TRB2->WK_SEQUEN+TRB2->WK_PREEMB))

      If !Empty(EE9->EE9_RE)
         cRe:=AllTrim(Transf(EE9->EE9_RE,AvSx3("EE9_RE",AV_PICTURE)))

         If lShowRE .And. MsgYesNo(STR0070+cRE+STR0071,STR0003) //"R.E. "###" ja associada a este processo, deseja gerar uma nova R.E.?"###"Aviso"
            lRet:=.t.
         EndIf
      Else
         lRet:=.t.
      EndIf

   ElseIf !lEmbarque .And. lMarcaAll // Tela de selecao de pedidos botao marca todos...

      nRecno:=TRB2->(RecNo())

      TRB2->(DbGoTop())

      Do While TRB2->(!Eof())

         If !Empty(TRB2->WK_RE)
            If AsCan(aNrRe,TRB2->WK_RE)=0
               aAdd(aNrRE,TRB2->WK_RE)
            EndIf
         EndIf

         TRB2->(DbSkip())
      EndDo

      If Len(aNrRe)>0
         For nX:=1 To Len(aNrRe)
            cRE+=AllTrim(Transf(aNrRe[nX],AvSx3("EE9_RE",AV_PICTURE)))+If(nX<Len(aNrRe),", "," ")
         Next

         If lShowRE .And. MsgYesNo(STR0069+cRE+STR0068,STR0003) //"R.E.(s) "###" ja associada(s) a este processo, deseja gerar nova(s) R.E.(s)?"###"Aviso"
            lRet:=.t.
         EndIf
      Else
         lRet:=.t.
      EndIf

      TRB2->(DbGoTo(nRecNo))

   EndIf

   //WFS 28/05/2009
   //Alteração de RE: Se não possuir número de RE relacionado ao item, não poderá gerar o arquivo TXT
   If Len(aNrRE) < 1 .And. !lShowRE
      MsgInfo(STR0121, STR0003)
      lRet:= .F.
      lInclui:= .F.
   EndIf
End Sequence

DbSelectArea(nOldArea)

RestOrd(aOrd)

Return lRet

/*
Funcao      : SI100Retorno()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Tela principal (Manutenção do Retorno Siscomex)
Autor       : Jeferson Barros Jr.
Data/Hora   : 18/04/2002 16:40
Revisao     :
Obs.        :
*/
*-----------------------------*
Static Function SI100Retorno()
*-----------------------------*
Local lRet:=.t.
Local cUsad := Posicione("SX3",2,"EEC_PREEMB","X3_USADO")
Local bOk:={||oDlg:End()},bCancel:={||oDlg:End()}
Local aCombo:={STR0081,STR0082,STR0083},aProcs:={},aOrd:=SaveOrd("EEC") //"Todos"###"Finalizados"###"Pendentes"
Local nX:=0

Private cCombo:="",cMemo:=""
Private nUsado := Len(aHeader)
Private oMemo, oFont := TFont():New("Courier New",09,15),oTree,oTree2,oTree3,oGetDb,oDlg
Private aHeader:={}, aPagina:={},/* aRotina:={},*/ aCols:={},aPos:={}
Private lExistErro:=.f.,lExisteOk:=.f.

Begin Sequence

   n:=1 // ** Necessario para a WMultiline...

   // ** Colunas WMultiline
   aAdd(aHeader,{STR0084,"EE9_PEDIDO",AvSx3("EE9_PEDIDO",AV_PICTURE),AvSx3("EE9_PEDIDO",AV_TAMANHO),0,"",cUsad ,"C","ZZZ"}) //"Pedido"
   aAdd(aHeader,{STR0085,"EE9_SEQUEN",AvSx3("EE9_SEQUEN",AV_PICTURE),AvSx3("EE9_SEQUEN",AV_TAMANHO),0,"",cUsad ,"C","ZZZ"}) //"Sequencia"
   aAdd(aHeader,{STR0086,"EE9_COD_I" ,AvSx3("EE9_COD_I",AV_PICTURE) ,AvSx3("EE9_COD_I",AV_TAMANHO),0,"",cUsad ,"C","ZZZ"}) //"Cod. Item"
   aAdd(aHeader,{STR0098,"EE9_VM_DES",AvSx3("EE9_VM_DES",AV_PICTURE),AvSx3("EE9_VM_DES",AV_TAMANHO),0,"",cUsad,"C","ZZZ"}) //"Descricao"
   aAdd(aHeader,{STR0087,"EE9_PRECO" ,EECPreco("EE9_PRECO", AV_PICTURE),AvSx3("EE9_PRECO",AV_TAMANHO),EECPreco("EE9_PRECO", AV_DECIMAL),"",cUsad ,"N","ZZZ"}) //"Preco Unit."
   aAdd(aHeader,{STR0088,"EE9_UNIDAD",AvSx3("EE9_UNIDAD",AV_PICTURE),AvSx3("EE9_UNIDAD",AV_TAMANHO),0,"",cUsad,"C","ZZZ"}) //"Unid.Medida"
   aAdd(aHeader,{STR0089,"EE9_SLDINI",AvSx3("EE9_SLDINI",AV_PICTURE),AvSx3("EE9_SLDINI",AV_TAMANHO),AvSx3("EE9_SLDINI",AV_DECIMAL),"",cUsad ,"N","ZZZ"}) //"Quantidade "
   aAdd(aHeader,{STR0090,"EE9_PRCTOT",EECPreco("EE9_PRCTOT", AV_PICTURE),AvSx3("EE9_PRCTOT",AV_TAMANHO),EECPreco("EE9_PRCTOT", AV_DECIMAL),"",cUsad ,"N","ZZZ"})    //"Vlr.Total  "
   aAdd(aHeader,{STR0099,"EE9_REFCLI",AvSx3("EE9_REFCLI",AV_PICTURE),AvSx3("EE9_REFCLI",AV_TAMANHO),0,"",cUsad ,"C","ZZZ"})    //"Referencia Cliente"
 //aAdd(aHeader,{STR0090,"EE9_PRCTOT",AvSx3("EE9_PRCTOT",AV_PICTURE),AvSx3("EE9_PRCTOT",AV_TAMANHO),AvSx3("EE9_PRCTOT",AV_DECIMAL),"",cUsad ,"N","ZZZ"})    //"Vlr.Total  "
 //aAdd(aHeader,{STR0087,"EE9_PRECO" ,AvSx3("EE9_PRECO",AV_PICTURE),AvSx3("EE9_PRECO",AV_TAMANHO),AvSx3("EE9_PRECO",AV_DECIMAL),"",cUsad ,"N","ZZZ"}) //"Preco Unit."

   aAddAcols()

   DEFINE MSDIALOG oDlg TITLE STR0091 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Retorno Siscomex"

      aPos := PosDlg(oDlg)

      @ 15,03 Say STR0092 Size 50,08  PIXEL //"Processos:"
      @ 15,35 COMBOBOX cCombo ITEMS aCombo SIZE aPos[4]-35,8 ON CHANGE LoadProcess(oTree,oTree2,oTree3) PIXEL

      oTree := DbTree():New(028,002,aPos[3],102,oDlg,,,.T.)  // Tree com todas as opcoes...
      oTree2 := DbTree():New(028,002,aPos[3],102,oDlg,,,.T.) // Tree somente com os arquivos ok ...
      oTree3 := DbTree():New(028,002,aPos[3],102,oDlg,,,.T.) // Tree somente com os arquivos erro ...

      LoadTree(oTree,oTree2,oTree3)

      oGetDb := IW_MultiLine(28,102,aPos[3],aPos[4],.F.,.T.)

      // ** Tree com todos os processos (Txt Ok e Txt Err)
      oTree:bChange := {|| If(Left(oTree:GetCargo(),1)=="P" ,LoadMemo(SubStr(oTree:GetCargo(),2,20),.f.),Nil),;
                           If(Left(oTree:GetCargo(),2)=="TO",LoadMemo(SubStr(oTree:GetCargo(),3,8)+".OK",.t.),Nil),;
                           If(Left(oTree:GetCargo(),2)=="TE",LoadMemo(SubStr(oTree:GetCargo(),3,8)+".ERR",.t.,.t.),Nil),;
                           If(Left(oTree:GetCargo(),1)=="A" ,LoadBrowse(oTree:GetCargo()),Nil)}

      // ** Tree com os processos finalizados ... (.Ok)
      oTree2:bChange := {||If(Left(oTree2:GetCargo(),1)=="P" ,LoadMemo(SubStr(oTree2:GetCargo(),2,20),.f.),Nil),;
                           If(Left(oTree2:GetCargo(),2)=="TO",LoadMemo(SubStr(oTree2:GetCargo(),3,8)+".OK",.t.),Nil),;
                           If(Left(oTree2:GetCargo(),1)=="A" ,LoadBrowse(oTree2:GetCargo()),Nil)}

      // ** Tree com os processos com erro ...(.Err)
      oTree3:bChange := {|| If(Left(oTree3:GetCargo(),1)=="P" ,LoadMemo(SubStr(oTree3:GetCargo(),2,20),.f.),Nil),;
                           If(Left(oTree3:GetCargo(),2)=="TE",LoadMemo(SubStr(oTree3:GetCargo(),3,8)+".ERR",.t.,.t.),Nil)}


      @ 28,102 GET oMemo VAR cMemo MEMO HSCROLL SIZE aPos[4]-102,aPos[3]-28 READONLY FONT oFont OF oDlg UPDATE PIXEL


   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : LoadTree(oTree)
Parametros  : Objeto Tree
Retorno     : .T.
Objetivos   : Montar trees para todas as condições do combo processos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/04/2002 09:38
Revisao     :
Obs.        :
*/
*------------------------------*
Static Function LoadTree(oTree)
*------------------------------*
Local lRet:=.t.
Local nX:=0,nZ:=0,nP:=0,nNivel:=0

Begin Sequence

   For nX:=1 To Len(aEmbarque)

      *-----------------------------------------------------*
      *        Carrega o Tree com todos os arquivos         *
      *-----------------------------------------------------*

      nNivel:=0
      // ** Adiciona um embarque ao Tree...
      DBADDTREE oTree PROMPT aEmbarque[nX][1] OPENED RESOURCE 'PMSDOC' CARGO "P"+aEmbarque[nX][1]

      // ** Adiciona Txt.Ok ...
      For nZ:=1 To Len(aEmbarque[nX][2])
          If ValType(aEmbarque[nX][2][nZ])="C"
             // ** Adiciona um Txt.Ok ao Tree ...
             If nNivel>0
                DBENDTREE oTree
             EndIf

             DBADDTREE oTree PROMPT aEmbarque[nX][2][nZ] OPENED RESOURCE 'CHECKED' CARGO "TO"+aEmbarque[nX][2][nZ]
             nNivel++
          Else

             For nP:=1 To Len(aEmbarque[nX][2][nZ])
                // ** Adiciona um Anexo ao Tree ...
                If ValType(aEmbarque[nX][2][nZ][nP])="C"
                   DBADDITEM oTree PROMPT  SubStr(aEmbarque[nX][2][nZ][nP],1,14)  RESOURCE 'RELATORIO' CARGO +"A"+SubStr(aEmbarque[nX][2][nZ][nP],15,6)+SubStr(aEmbarque[nX][2][nZ][nP],21,20)
                EndIf
             Next

          EndIf
      Next

      // ** Adiciona Txt.err
      For nZ:=1 To Len(aEmbarque[nX][3])
          If !Empty(aEmbarque[nX][3][nZ])
             If nNivel>0
                DBENDTREE oTree
             EndIf
             DBADDTREE oTree PROMPT aEmbarque[nX][3][nZ] RESOURCE 'NOCHECKED' CARGO "TE"+aEmbarque[nX][3][nZ]
             nNivel++
          EndIf
      Next

      DBENDTREE oTree;DBENDTREE oTree

      oTree:Refresh()
      oTree:SetFocus()

      *--------------------------------------------------*
      *   Carrega o Tree2 com todos os arquivos Ok       *
      *--------------------------------------------------*

      nNivel:=0

      If Len(aEmbarque[nX][3]) = 0

         // ** Adiciona um embarque ao Tree...
         DBADDTREE oTree2 PROMPT aEmbarque[nX][1] OPENED RESOURCE 'PMSDOC' CARGO "P"+aEmbarque[nX][1]

         // ** Adiciona Txt.Ok ...
         For nZ:=1 To Len(aEmbarque[nX][2])
             If ValType(aEmbarque[nX][2][nZ])="C"
                // ** Adiciona um Txt.Ok ao Tree ..
                If nNivel>0
                   DBENDTREE oTree2
                EndIf

                DBADDTREE oTree2 PROMPT aEmbarque[nX][2][nZ] OPENED RESOURCE 'CHECKED' CARGO "TO"+aEmbarque[nX][2][nZ]
                nNivel++
                lExisteOk:=.t.
             Else

                For nP:=1 To Len(aEmbarque[nX][2][nZ])
                   // ** Adiciona um Anexo ao Tree ..
                   If ValType(aEmbarque[nX][2][nZ][nP])="C"
                      DBADDITEM oTree2 PROMPT  SubStr(aEmbarque[nX][2][nZ][nP],1,14)  RESOURCE 'RELATORIO' CARGO +"A"+SubStr(aEmbarque[nX][2][nZ][nP],15,6)+SubStr(aEmbarque[nX][2][nZ][nP],21,20)
                   EndIf
                Next

             EndIf
         Next

         DBENDTREE oTree2;DBENDTREE oTree2

      EndIf

      *--------------------------------------------------*
      *    Carrega o Tree3 com todos os arquivos ERR     *
      *--------------------------------------------------*

      nNivel:=0

      If Len(aEmbarque[nX][3]) > 0

         // ** Adiciona um embarque ao Tree...
         DBADDTREE oTree3 PROMPT aEmbarque[nX][1] OPENED RESOURCE 'PMSDOC' CARGO "P"+aEmbarque[nX][1]

         // ** Adiciona Txt.err
         For nZ:=1 To Len(aEmbarque[nX][3])
             If !Empty(aEmbarque[nX][3][nZ])
                If nNivel>0
                   DBENDTREE oTree3
                EndIf
                DBADDTREE oTree3 PROMPT aEmbarque[nX][3][nZ] RESOURCE 'NOCHECKED' CARGO "TE"+aEmbarque[nX][3][nZ]
                nNivel++
                lExistErro:=.t.
             EndIf
         Next

         DBENDTREE oTree3;DBENDTREE oTree3

      EndIf

   Next

   oTree2:Hide()
   oTree3:Hide()
   oTree :Show() //Deixa sempre o tree (Todos os arquivos) ativo como padrão.

End Sequence

Return lRet

/*
Funcao      : LoadMemo(cProcesso,lTxt,lErro)
Parametros  : cProcesso => Processo
              lTxt      => .t. Mostra informações do arquivo selecionado.
                           .f. Mostra informações do embarque selecionado.
              lErro     => .t. Mostra informações do arquivo e seu conteúdo.
                           .f. (Default) Mostra apenas as informações do arquivo.
Retorno     : .t.
Objetivos   : Setar o campo memo de acordo com a selecao do item do Tree.
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/04/2002 10:20.
Revisao     :
Obs.        :
*/
*---------------------------------------------*
Static Function LoadMemo(cProcesso,lTxt,lErro)
*---------------------------------------------*
Local cFileTxt:="",nPosFile:=0,;
      cDiretorio:=EasyGParam("MV_AVG0003"),lRet:=.t.

Default lErro:=.f.

Begin Sequence

   cMemo:=""

   aCols:={}
   n:=1

   oMemo:Show()
   oGetDb:oBrowse:Hide()

   If !lTxt
      EEC->(DbSetOrder(1))
      EEC->(DbSeek(xFilial("EEC")+cProcesso))

      // Carrega informações do processo de embarque ...
      cMemo+= STR0093+Replic(ENTER,2)      //" Dados do Processo de Embarque: "

      cMemo+= IncSpace(Space(1)+AvSx3("EEC_PREEMB",AV_TITULO),20,.f.)+": "+EEC->EEC_PREEMB+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_DTPROC",AV_TITULO),20,.f.)+": "+Transf(EEC->EEC_DTPROC,"  /  /  ")+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_STTDES",AV_TITULO),20,.f.)+": "+EEC->EEC_STTDES+ENTER

      If EasyGParam("MV_AVG0140",,"I") == "C" .and. !Empty(EEC->EEC_CONSIG)
         cMemo+= IncSpace(Space(1)+AvSx3("EEC_CONSDE",AV_TITULO),20,.f.)+": "+Posicione("SA1",1,xFilial("SA1")+EEC->EEC_CONSIG+EEC->EEC_COLOJA,"A1_NOME")+ENTER
      Else
         cMemo+= IncSpace(Space(1)+AvSx3("EEC_IMPODE",AV_TITULO),20,.f.)+": "+Posicione("SA1",1,xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA,"A1_NOME")+ENTER
      EndIf

      cMemo+= IncSpace(Space(1)+AvSx3("EEC_FORNDE",AV_TITULO),20,.f.)+": "+Posicione("SA2",1,xFilial("SA2")+EEC->EEC_FORN+EEC->EEC_FOLOJA,"A2_NOME")+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_INCOTE",AV_TITULO),20,.f.)+": "+EEC->EEC_INCOTE+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_MOEDA ",AV_TITULO),20,.f.)+": "+EEC->EEC_MOEDA+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_CONDPA",AV_TITULO),20,.f.)+": "+SY6Descricao(EEC->EEC_CONDPA+Str(EEC->EEC_DIASPA,AVSX3("EEC_DIASPA",3),AVSX3("EEC_DIASPA",4)),EEC->EEC_IDIOMA,1)+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_MPGEXP",AV_TITULO),20,.f.)+": "+EEC->EEC_MPGEXP+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_LIBSIS",AV_TITULO),20,.f.)+": "+If(!Empty(EEC->EEC_LIBSIS),Transf(EEC->EEC_LIBSIS,"  /  /  ")+ENTER,ENTER)
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_URFDSP",AV_TITULO),20,.f.)+": "+EEC->EEC_URFDSP+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_URFENT",AV_TITULO),20,.f.)+": "+EEC->EEC_URFENT+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_INSCOD",AV_TITULO),20,.f.)+": "+EEC->EEC_INSCOD+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_ENQCOD",AV_TITULO),20,.f.)+": "+EEC->EEC_ENQCOD+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_TOTITE",AV_TITULO),20,.f.)+": "+AllTrim(Str(EEC->EEC_TOTITE,AVSX3("EEC_TOTITE",AV_TAMANHO),0))+ENTER
      cMemo+= IncSpace(Space(1)+AvSx3("EEC_TOTPED",AV_TITULO),20,.f.)+": "+AllTrim(Transf(EEC->EEC_TOTPED,AvSX3("EEC_TOTPED",AV_PICTURE)))+ENTER

   Else
      cFileTxt:=AllTrim(cProcesso)

      nPosFile:=aScan(aDetalhe,{|aX| aX[1]=cFileTxt})

      If nPosFile>0
         cMemo+= STR0094+Replic(ENTER,2) //"Detalhes do arquivo de retorno : "
         cMemo+= STR0095+AllTrim(aDetalhe[nPosFile][2][1][1])+ENTER //"Nome         : "
         cMemo+= STR0096+AllTrim(Str(aDetalhe[nPosFile][2][1][2]))+STR0097+ENTER //"Tamanho      : "###" bytes"
         cMemo+= STR0100+Transf (aDetalhe[nPosFile][2][1][3],"  /  /  ")+ENTER //"Data geracao : "
         cMemo+= STR0101+AllTrim(aDetalhe[nPosFile][2][1][4])+ENTER //"Hora geracao : "
      EndIf

      If lErro
         cMemo+=Replic(ENTER,2)
         cMemo+=STR0102+ENTER //"Conteudo do arquivo de erro:"
         cMemo+=Replic("_",28)+Replic(ENTER,3) // ** Inclui uma divisória entre os dados do arquivo e seu conteúdo...

         // ** Carrega todo o conteúdo do arquivo de erro...
         cMemo+=MemoRead(cDiretorio+cFileTxt)

      EndIf

   EndIf

   oMemo:EnableVScroll(.t.)
   oMemo:EnableHScroll(.t.)

   oMemo:Refresh()

End Sequence

Return lRet

/*
Funcao      : aAddAcols
Parametros  : cPedido,cSequencia,cCodigo,cDescricao, nPrecoUnit,cUnidade,nQtde,nValTotal,cRefCli
Retorno     : .T.
Objetivos   : Incluir os Valores no aCols
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/04/02 10:19
Revisao     :
Obs.        :
*/
*------------------------------------------------------------------------------------------------------------*
Static Function aAddAcols(cPedido,cSequencia,cCodigo,cDescricao, nPrecoUnit,cUnidade,nQtde,nValTotal,cRefCli)
*------------------------------------------------------------------------------------------------------------*
Local lRet:= .T.

Begin Sequence

   aAdd(aCols,Array(10))
   aCols[Len(aCols)][10]           := .f.
   aCols[Len(aCols)][PEDIDO]       := cPedido
   aCols[Len(aCols)][SEQUENCIA]    := cSequencia
   aCols[Len(aCols)][CODIGO]       := cCodigo
   aCols[Len(aCols)][DESCRICAO]    := cDescricao
   aCols[Len(aCols)][PRECOUNIT]    := nPrecoUnit
   aCols[Len(aCols)][UNIDADEMED]   := cUnidade
   aCols[Len(aCols)][QUANTIDADE]   := nQtde
   aCols[Len(aCols)][VALORTOTAL]   := nValTotal
   aCols[Len(aCols)][REFCLI]       := cRefCli

End Sequence

Return lRet

/*
Funcao      : LoadBrowse(cSequencia)
Parametros  : cSequencia => Processo+Sequencia siscomex
Retorno     : .T.
Objetivos   : Montar WMultiline com os itens do EE9 correspondentes a este embarque e a esta sequencia.
Autor       : Jeferson Barros Jr.
Data/Hora   : 22/04/2002 08:22
Revisao     :
Obs.        :
*/
*------------------------------------*
Static Function LoadBrowse(cSequencia)
*------------------------------------*
Local lRet:=.t.,cProcesso:="",cSeq:=""
Local aOrd:=SaveOrd("EE9")

Begin Sequence

   cProcesso := AvKey(SubStr(cSequencia,8,20),"EEC_PREEMB")
   cSeq      := SubStr(cSequencia,2,6)

   aCols:={}
   oMemo:Hide()
   oGetDb:oBrowse:Show()

   EE9->(DbSetOrder(9))
   EE9->(DbSeek(xFilial("EE9")+cProcesso+cSeq))

   While !EE9->(EOF()) .AND. EE9->EE9_FILIAL=xFilial("EE9") .AND. EE9->EE9_PREEMB = cProcesso .And. EE9->EE9_SEQSIS=cSeq
      cDesc := MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES",3))
      aAddAcols(EE9->EE9_PEDIDO,EE9->EE9_SEQUEN,EE9->EE9_COD_I,cDesc, EE9->EE9_PRECO,EE9->EE9_UNIDAD,EE9->EE9_SLDINI,EE9->EE9_PRCTOT,EE9->EE9_REFCLI)
      EE9->(DbSkip())
   EndDo

   oGetDb:oBrowse:Refresh()

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : LoadProcess()
Parametros  : oTree,oTree2,oTree3
Retorno     : .T.
Objetivos   : Selecionar qual tree deve ser exibido.
Autor       : Jeferson Barros Jr.
Data/Hora   : 22/04/2002 14:49
Revisao     :
Obs.        :
*/
*-----------------------------------------------*
Static Function LoadProcess(oTree,oTree2,oTree3)
*-----------------------------------------------*
Local lRet:=.t.

Begin Sequence
   cMemo:= ""
   oMemo:Refresh()

   If cCombo==STR0081 //"Todos"
      oTree2:Hide()
      oTree3:Hide()
      oTree :Show()

   ElseIf cCombo==STR0082 //"Finalizados"
      oTree :Hide()
      oTree3:Hide()
      oTree2:Show()

      If !lExisteOk
         cMemo:= STR0103 //"Nao ha itens para esta selecao."
         oGetDb:Hide()
         oMemo:Refresh()
         oMemo:Show()
      EndIf

   Else // Pendente
      oTree :Hide()
      oTree2:Hide()
      oTree3:Show()

      If !lExistErro
         cMemo:=STR0103 //"Nao ha itens para esta selecao."
         oGetDb:Hide()
         oMemo:Refresh()
         oMemo:Show()
      EndIf

   EndIf

End Sequence

Return lRet

/*
Funcao      : SI100AddEnq
Parametros  : cCodEnq
Retorno     : Nil
Objetivos   : Adiciona enquadramentos na Matriz.
Autor       : Osman Medeiros Jr. (OMJ)
Data/Hora   : 06/02/2003 15:09
Revisao     :
Obs.        :
*/
*-----------------------------------------------*
Static Function SI100AddEnq(cCodEnq)
*-----------------------------------------------*
Local nPos

If ( nPos := aScan(aEnquadra,cCodEnq) ) = 0 .And. !Empty(cCodEnq)
   Aadd(aEnquadra,cCodEnq)
EndIf

Return Nil

/*
Funcao      : SI100DscEE9
Parametros  : cPreemb = Cod. do Embarque
              cSeqSis = Seq. do Siscomex
Retorno     : Nil
Objetivos   : Grava no EE9 a descricao q foi para o RE.
Autor       : Osman Medeiros Jr. (OMJ)
Data/Hora   : 25/02/2003 15:25
Revisao     :
Obs.        : A descricao será gravada para os itens que tem o
              mesmo agrupamento, mesmo nr. de EE9_SEQSIS
*/
*-----------------------------------------------*
Static Function SI100DscEE9(cPreemb,cSeqSis,cDescRE)
*-----------------------------------------------*
Local nAliasOld := Select()
Local aOrd := SaveOrd({"EE9"})
Local cFilEE9 := xFilial("EE9")

dbSelectArea("EE9")

EE9->(dbSetOrder(9)) //EE9_PREEMB+EE9_SEQSIS

EE9->(dbSeek(cFilEE9 + cPreemb + cSeqSis ))
Do While !EE9->(Eof()) .And.;
         EE9->EE9_FILIAL = cFilEE9 .And.;
         EE9->EE9_PREEMB = cPreemb .And.;
         EE9->EE9_SEQSIS = cSeqSis

   EE9->(RecLock("EE9",.F.))

   If !Empty(EE9->EE9_DESCRE)
      MSMM(EE9->EE9_DESCRE,,,,EXCMEMO)
   Endif

   MSMM(,AVSX3("EE9_VM_DRE",AV_TAMANHO),,cDescRE,INCMEMO,,,"EE9","EE9_DESCRE")

   EE9->(MsUnlock())

   EE9->(dbSkip())

EndDo

RestOrd(aOrd)

dbSelectArea(nAliasOld)

Return Nil

/*
Funcao      : SI100CNPJ
Parametros  : cKeySA2
Retorno     : cRet
Objetivos   : CNPJ (com tratamento para pessoa fisica)
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/12/2003 16:44
Revisao     :
Obs.        :
*/
Function SI100CNPJ(cKeySA2)

Local aOrd := SaveOrd("SA2")
Local cRet := Space(LEN(SA2->A2_CGC))

Begin Sequence
   SA2->(dbSetOrder(1))
   IF SA2->(dbSeek(xFilial("SA2")+cKeySA2))
      IF SA2->A2_TIPO == "F" .AND. !EECFlags("NOVOEX")
         cRet := "99999997000100"
      Else
         If Left(SA2->A2_ID_FBFN,1) $ "13" .AND. Empty(SA2->A2_CGC)  // GFP - 22/06/2015
            cRet := "99999999999999"
         Else
            cRet := SA2->A2_CGC
         EndIf
      Endif
   Endif
End Sequence

RestOrd(aOrd)

Return cRet

/*
Funcao      : SI100AtuDet
Parametros  : cPreemb  -> Nro. do Embarque
              cRE      -> Nro. do RE
              cSeqSisc -> Sequencia Siscomex
Retorno     : lRet
Objetivos   : Atualiza os Detalhes do RE (SY6), quanto a Rotina de Consignação está instalada.
Autor       : Eduardo C. Romanini
Data/Hora   : 10/05/2006 15:45
Revisao     :
Obs.        :
*/
Function SI100AtuDet(cPreemb,cRE,cSeqSisc)

Local lRet := .T.
Local nSaldo := 0
Local aOrd := SaveOrd({"EEC","EE9"})

Begin Sequence

   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(xFilial("EEC")+cPreemb))
      If EEC->EEC_TIPO <> PC_RC //Remessa por Consignação
         lRet := .F.
         Break
      EndIf
   EndIf

   /*
      Seek no EE9 para alimentar a variável nSaldo,
      com a soma da Quantidade de todos os Itens com a mesma Sequencia Siscomex.
      Com isso o nSaldo contém o Saldo do RE.
   */
   EE9->(DbSetOrder(9))
   EE9->(DbSeek(xFilial("EE9")+cPreemb+cSeqSisc))
   While EE9->(!EOF()) .and. EE9->(EE9_FILIAL+EE9_PREEMB+EE9_SEQSIS) == xFilial("EE9")+cPreemb+cSeqSisc
      nSaldo += EE9->EE9_SLDINI
      EE9->(DbSkip())
   EndDo

   If EY6->(RecLock("EY6",.T.))
      EY6->EY6_FILIAL := xFilial("EY6")
      EY6->EY6_PREEMB := Alltrim(cPreemb)
      EY6->EY6_RE     := Alltrim(cRE)
      EY6->EY6_SLDINI := nSaldo
      EY6->EY6_SLDATU := 0
      EY6->EY6_STATUS := RE_NP //Não Prorrogado
      EY6->EY6_PRAZO  := EEC->EEC_LIMOPE
      EY6->(MsUnlock())
   EndIf
End Sequence

RestOrd(aOrd)

Return lRet

/*
Função: ValOpcRE(nOpcao)
Parâmetros: nOpcao - opção selecionada na tela.
Retorno: .T. / .F.
Objetivo: Validar as opções de geração de RE.
Autor: Julio de Paula Paz
Data/Hora: 10/12/2008 - 11:30
*/
Static Function ValOpcRE(nOpcao)
Local lRet := .T.

Begin Sequence
   If lWizardRE .And. nOpcao = 3
      MsgInfo("Esta opção será realizada automáticamente após o envio dos dados para o SISCOMEX!","Atenção")
      lRet := .F.
      nRadio := 1
      oRad:Refresh()
   EndIf
End Sequence

Return lRet

/*
Função: ValProc(cPedido)
Parâmetros: cPedido - Pedido selecionado para integração com SISCOMEX.
Retorno: .T. / .F.
Objetivo: Permitir que seja adicionado uma validação via ponto de entrada
Autor: DFS - Diogo Felipe dos Santos
Data/Hora: 22/10/2009
*/

Static Function ValProc(cPedido)
Private lValProc := .T.

// DFS - Criação de pontro de entrada para adicionar validação.

If EasyEntryPoint ("EECSI100")
   ExecBlock ("EECSI100", .F., .F., {"ValProc", cPedido})
Endif
Return lValProc

Static Function SI100MemRE(aArray,cCampo,uInfo)
   If EECFlags("NOVOEX")
      aAdd(aArray,{cCampo,uInfo})
   EndIf
Return Nil

Static Function SI100GetMerc(aMerc,cCont)
Local uRet
Local nPos

if Len(aMerc)>=3
   If (nPos := aScan(aMerc[3],{|X| X[1] == cCont})) > 0 .AND. Len(aMerc[3][nPos]) >= 2
      uRet := aMerc[3][nPos][2]
   EndIf
EndIf

Return uRet

Static Function SI100GrvREs(aREs)
Local i
Local lTrans

lTrans := InTransact()

If !lTrans
   Begin Transaction

   For i := 1 To Len(aREs)
      GrvTabRE(aREs[i],"EWK")
   Next i

   End Transaction
Else
   For i := 1 To Len(aREs)
      GrvTabRE(aREs[i],"EWK")
   Next i
EndIf

If EasyEntryPoint ("EECSI100")
   ExecBlock ("EECSI100", .F., .F., {"SI100_GRAVA_TAB"})
Endif

Return Nil


Static Function GrvTabRE(aDados,cAlias)
Local i
Local uDado
Local nPos
Local aMemos := {{"EWK_CODOBS", "EWK_OBS"    },;
                 {"EWK_CODADM", "EWK_TRAADM" },;
                 {"EWK_CODERR", "EWK_ERROS"  }}

RecLock(cAlias,.T.)

For i := 1 To Len(aDados)
   uDado := aDados[i]

   If uDado[1] == "MERCADORIAS"
	  GrvTabRE(uDado[2],"EWL")
   ElseIf uDado[1] == "FABRICANTES"
	  GrvTabRE(uDado[2],"EWO")
   ElseIf uDado[1] == "DRAWBACK"
	  GrvTabRE(uDado[2],"EWM")
   ElseIf uDado[1] == "NOTAS_FISCAIS"
	  GrvTabRE(uDado[2],"EWN")
   ElseIf uDado[1] == "RELACIONAMENTOS"
      GrvTabRE(uDado[2],"EWP")
   EndIf

   If (nPos := (cAlias)->(FieldPos(uDado[1]))) > 0
      (cAlias)->(FieldPut(nPos,AvConvert(ValType(uDado[2]),AvSX3(uDado[1],AV_TIPO),AvSX3(uDado[1],AV_TAMANHO),uDado[2])))
   Else
      If (nPos := aScan(aMemos, {|x| x[2] == Upper(AllTrim(uDado[1])) })) > 0
         MSMM((cAlias)->&(aMemos[nPos][1]),,,,EXCMEMO)

         //RMD - 09/04/15 - Utiliza a função EasyMSMM para evitar que o registro seja destravado pela MSMM
         //MSMM(,AVSX3(aMemos[nPos][2],AV_TAMANHO),,AvConvert(ValType(uDado[2]),AvSX3(uDado[1],AV_TIPO),AvSX3(uDado[1],AV_TAMANHO),uDado[2]),INCMEMO,,,cAlias,aMemos[nPos][1])
         EasyMSMM(,AVSX3(aMemos[nPos][2],AV_TAMANHO),,AvConvert(ValType(uDado[2]),AvSX3(uDado[1],AV_TIPO),AvSX3(uDado[1],AV_TAMANHO),uDado[2]),INCMEMO,,,cAlias,aMemos[nPos][1])
      EndIf
   EndIf

Next i

(cAlias)->(MsUnLock())

If cAlias == "EWP"
   EE9->(dbSetOrder(3))
   If EE9->(dbSeek(xFilial("EE9")+EWP->(EWP_PREEMB+EWP_SEQEMB)))
      RecLock("EE9",.F.)
      EE9->EE9_ID    := EWP->EWP_ID
      EE9->EE9_SEQRE := EWP->EWP_SEQRE
      EE9->(MsUnLock())
   EndIf
EndIf

Return Nil



/*
Funcao      : SI100FErro
Parametros  :
Retorno     :
Objetivos   : Verifica erros relacionados a geração do RE
Autor       : Olliver Adami Pedroso
Data/Hora   : 28/01/2011
*/

Function SI100FErro()

Local aOrder    := SaveOrd({"SA1","SA2","EE5","EE7","SJ5"})
Local nPesoProd := -1
Local nPesoEmb  := -1

//CNPJ/CPF não informado.
If Select("SA2") == 0
   DbSelectArea("SA2")
EndIf
SA2->(DbSetOrder(1))   //A2_FILIAL+A2_COD

If SA2->(DbSeek(xFilial("SA2")+AvKey(Alltrim(TRB->EEC_FORN),"A2_COD")))
   If Empty(SA2->A2_CGC)
      oObErroNEx:Warning("Não foi inserido CPF no cadastro do fornecedor.")
   EndIf
EndIf

//O elemento pais-importador do arquivo de lote é inválido. Há informações divergentes de acordo com o xml schema.
If Select("SA1") == 0
   DbSelectArea("SA1")
EndIf
SA1->(DbSetOrder(1))   //A1_FILIAL+A1_COD

If Select("EE7") == 0
   DbSelectArea("EE7")
EndIf
EE7->(DbSetOrder(1))   //EE7_FILIAL+EE7_PEDIDO

If SA1->(DbSeek(xFilial("SA1")+AvKey(Alltrim(TRB->EEC_IMPORT),"A1_COD")))
   If EE7->(DbSeek(xFilial("EE7")+AvKey(Alltrim(TRB->EEC_PEDREF),"EE7_PEDIDO")))
      If Alltrim(EE7->EE7_PAISET) != Alltrim(SA1->A1_PAIS)
         oObErroNEx:Warning("O país cadastrado no cliente é diferente do país de destino inserido no pedido de exportação.")
      EndIf
   EndIf
EndIf

//O elemento orgao-rf-despacho do arquivo de lote é inválido. Há informações divergentes de acordo com o xml schema.
If Empty(TRB->EEC_URFDSP)
   oObErroNEx:Warning("A Unidade da Receita Federal(URF) de Despacho não foi preenchida.")
EndIf

//O elemento orgao-rf-embarque do arquivo de lote é inválido. Há informações divergentes de acordo com o xml schema.
If Empty(TRB->EEC_URFENT)
   oObErroNEx:Warning("A Unidade da Receita Federal(URF) de Entrega não foi preenchida.")
EndIf

//O elemento pais-importador do arquivo de lote é inválido. Há informações divergentes de acordo com o xml schema.
SA1->(DbSetOrder(1))   //A1_FILIAL+A1_COD

If SA1->(DbSeek(xFilial("SA1")+AvKey(Alltrim(TRB->EEC_IMPORT),"A1_COD")))
   If Empty(SA1->A1_PAIS)
      oObErroNEx:Warning("O País do Cliente não foi inserido no cadastro.")
   EndIf
EndIf

//Data Limite é de preenchimento obrigatório para alguns enquadramentos vinculados ao atributo “Prazo”
If Empty(TRB->EEC_LIMOPE) .And. (Alltrim(TRB->EEC_ENQCOD) $ "80102/80104" .Or.;
                                Alltrim(TRB->EEC_ENQCO1) $ "80102/80104" .Or.;
                                Alltrim(TRB->EEC_ENQCO2) $ "80102/80104" .Or.;
                                Alltrim(TRB->EEC_ENQCO3) $ "80102/80104")
   oObErroNEx:Warning("A data limite da operação não foi cadastrado no Processo de Exportação.")
EndIf

//Valor em Consignação deve ser maior que zero.
If !Empty(TRB->EEC_VLCONS)
   If !(Alltrim(TRB->EEC_ENQCOD) $ "80102/80114") .AND.;
      !(Alltrim(TRB->EEC_ENQCO1) $ "80102/80114") .AND.;
      !(Alltrim(TRB->EEC_ENQCO2) $ "80102/80114") .AND.;
      !(Alltrim(TRB->EEC_ENQCO3) $ "80102/80114")

      oObErroNEx:Warning("Com o valor de consignação preenchido no processo de exportação, é necessário cadastrar um enquadramento vinculado a esse parametro. Ver enquadramentos 80102 e 80114.")
   EndIf
EndIf

If Alltrim(TRB->EEC_ENQCOD) $ "80102/80114" .OR.;
   Alltrim(TRB->EEC_ENQCO1) $ "80102/80114" .OR.;
   Alltrim(TRB->EEC_ENQCO2) $ "80102/80114" .OR.;
   Alltrim(TRB->EEC_ENQCO3) $ "80102/80114"

   If Empty(TRB->EEC_VLCONS)
      oObErroNEx:Warning("De acordo com o(s) enquadramento(s) inserido(s) no processo, é necessário inserir um Valor de Consignação.")
   EndIf
EndIf

If !Empty(TRB->EEC_REGVEN)
   If TRB->EEC_ENQCOD != "81301" .OR.;
      TRB->EEC_ENQCO1 != "81301" .OR.;
      TRB->EEC_ENQCO2 != "81301" .OR.;
      TRB->EEC_ENQCO3 != "81301"

      oObErroNEx:Warning("Foi acrescentado um número de RV, porém não foi vinculado o código de enquadramento 81301 a este processo.")
   EndIf
EndIf

If !Empty(TRB->EEC_DIRIVN)
   If !(TRB->EEC_ENQCOD $ "99108/99122/99123") .OR.;
      !(TRB->EEC_ENQCO1 $ "99108/99122/99123") .OR.;
      !(TRB->EEC_ENQCO2 $ "99108/99122/99123") .OR.;
      !(TRB->EEC_ENQCO3 $ "99108/99122/99123")

      oObErroNEx:Warning("Foi acrescentado um número de DI, porém não foi vinculado o código de enquadramento 99108 ou 99122 ou 99123 a este processo.")
   EndIf
EndIf

If Select("EE5") == 0
   DbSelectArea("EE5")
EndIf

EE9->(DbSetOrder(3))  //EE9_FILIAL+EE9_PREEMB+EE9_SEQEMB
EE9->(DbSeek(xFilial("EE9")+TRB->EEC_PREEMB))

//Erros Relacionados aos pedidos do processo de embarque.
While EE9->(!EOF()) .AND. Alltrim(EE9->EE9_PREEMB) == Alltrim(TRB->EEC_PREEMB)

   // BAK - 02/05/2011 - Alteração para verificar se está compilado a função EasyConvQt(), caso contrario realiza o processo anterior
   If lEasyConvQt
      //nPesoProd := EasyConvQt(EE9->EE9_COD_I,{{EE9->EE9_UNIDAD,EE9->EE9_QE}},EE9->EE9_UNPES,.F.,@oObErroNEx) //comentado por wfs
      //nPesoProd := EasyConvQt(EE9->EE9_COD_I,{{EE9->EE9_UNIDAD,EE9->EE9_PSLQUN}},EE9->EE9_UNPES,.F.,@oObErroNEx)
      nPesoProd := EasyConvQt(EE9->EE9_COD_I,GetEE9Qtds(),GetSYDUnid(EE9->EE9_UNPES,GetEE9Qtds()),.F.,@oObErroNEx)

      EE5->(DbSetOrder(1))
      EE5->(DbSeek(xFilial("EE5")+AvKey(Alltrim(EE9->EE9_EMBAL1),"EE5_CODEMB")))
      If !Empty(EE5->EE5_PESO)
         nPesoEmb  := EasyConvQt("",{{"KG",EE5->EE5_PESO}},EE9->EE9_UNPES,.F.,@oObErroNEx)
      Else
         oObErroNEx:Warning("Não existe peso cadastrado para a embalagem " + Alltrim(EE9->EE9_EMBAL1) + " .")
      EndIf

     //DFS - 26/11/12 - Retirado tratamento, visto que, não é necessário validar o peso da embalagem e peso bruto final na geração do RE.
     /*If !nPesoProd < 0 .AND. !nPesoEmb < 0 .AND. nPesoProd + nPesoEmb <> EE9->EE9_PSBRUN
         oObErroNEx:Warning("Verificar o valor do Peso Bruto Final cadastrado no processo de exportação, para o produto " + Alltrim(MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES",AV_TAMANHO),,,LERMEMO))+" cujo item de pedido é de número: " +Alltrim(EE9->EE9_SEQUEN)+ " .")
      EndIf */
   EndIf

EE9->(DbSkip())
EndDo

RestOrd(aOrder)

Return Nil

/*
Funcao      : SI100DtSisco()
Parametros  : dData (Data corrente do processo)
Retorno     : cRet (Layout correto da data)
Objetivos   : Retorna a data com 4 digitos no ano (DD/MM/AAAA) para envio ao Siscomex
Autor       : Diogo Felipe dos Santos
Data/Hora   : 16/12/2011 16:15
*/
Function SI100DtSisco(dData)
Local cData:= ""
Local cRet := ""

Begin Sequence

   If Empty(dData)
      Break
   EndIf

   //Dia
   If Day(dData) < 10
      cData += "0"
   EndIf
   cData += LTrim(Str(Day(dData)))

   //Mês
   If Month(dData) < 10
      cData += "0"
   EndIf
   cData += LTrim(Str(Month(dData)))

   //Ano
   cData += LTrim(Str(Year(dData)))

  // cData := Padl(Day(cData), 2, "0") + "/" + Padl(Month(cData), 2, "0") + "/" + Padl(Year(cData), 4)

   cRet := SubStr(cData, 1, 2 ) + "/" + SubStr( cData, 3, 2) + "/" + SubStr(cData, 5, 4)

End Sequence

Return cRet

/*
Funcao      : GetEE9Qtds()
Objetivos   : Retorna informações sobre medidas do item que podem ser convertidas entre si.
Autor       : Diogo Felipe dos Santos
Data/Hora   : 02/03/2012
*/

Static Function GetEE9Qtds()
Local aRet

	aRet := {{EE9->EE9_UNIDAD,EE9->EE9_SLDINI},;
			 {If(!Empty(EE9->EE9_UNPES), EE9->EE9_UNPES, If(!Empty(EEC->EEC_UNIDAD),EEC->EEC_UNIDAD,"KG")),EE9->EE9_PSLQTO}}  // GFP - 23/09/2014

Return aRet

/*
Funcao      : GetSYDUnid()
Objetivos   : Retorna informações sobre unidade referentes ao Siscomex.
Autor       : Diogo Felipe dos Santos
Data/Hora   : 02/03/2012
*/

Static Function GetSYDUnid(cUnidSis, aUnidOrigem)
Local cUnidEasy := ""
Default aUnidOrigem := {}

//DFS - 01/11/12 - Troca da numeração do indice de acordo com o AtuSx
If SIX->(DbSeek("SAH"+"3"))
   SAH->(dbSetOrder(3))
   If SAH->(dbSeek(xFilial()+cUnidSis))
      While SAH->(!Eof() .And. AH_FILIAL+AH_COD_SIS == xFilial()+cUnidSis)
         If aScan(aUnidOrigem, {|x| x[1] == SAH->AH_UNIMED }) > 0
         	cUnidEasy := SAH->AH_UNIMED
         	Exit
         EndIf
         SAH->(DbSkip())
      EndDo
      If Empty(cUnidEasy) .And. SAH->(dbSeek(xFilial()+cUnidSis))
         cUnidEasy := SAH->AH_UNIMED
      EndIf
   Else
      cUnidEasy := cUnidSis
   EndIf
Else
   cUnidEasy := cUnidSis
EndIf

Return cUnidEasy

/*
Funcao      : SI100DelCols()
Objetivos   : Valida a linha da getdados .
Autor       : Diogo Felipe dos Santos
Data/Hora   : 11/04/2012
*/

Function SI100DelCols()

Return .F.

/*
Funcao      : GetDescItem()
Objetivos   : Retorna as descrições de acordo com o agrupamento.
Autor       : Diogo Felipe dos Santos
Data/Hora   : 13/07/2012
*/

Function GetDescItem(cDescTemp)
Local lRet := .F.

//DFS - 06/11/12 - Retirado tratamento que não validava a mesma descrição se a flag de separar mercadorias estivesse ligado.
//If !lSepMerc
lRet := aScan(aCposAux,{|x| x == cDescTemp}) > 0
//EndIf

Return lRet
*--------------------------------------------------------------------------*
* FIM DO PROGRAMA EECSI100.PRW                                             *
*--------------------------------------------------------------------------*
