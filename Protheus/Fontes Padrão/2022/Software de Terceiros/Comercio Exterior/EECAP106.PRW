#INCLUDE "EECAP106.CH"
#INCLUDE "EEC.cH"

/*
Funcao      : EECAP106
Parametros  : cFase = Fase do Processo ( OC_PE / OC_EM )
              lF3   = .T./.F.
Retorno     : Nenhum
Objetivos   : Tratamento de invoices a pagar em Back To Back
              Funciona como o F3 de invoices a pagar caso lF3 = .T.
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 31/08/2004 15:57
Revisao     :
Obs.        :
*/
*-----------------------*
Function EECAP106(cFase,lF3)
*-----------------------*
Local  aAux     := {}
Local  i
Local nOldReg   := 0
Default lF3     := .F.

Private  aAlter   := {}
Private  aHeader  := {}
Private  aCols    := {}
Private lF3InvPag := lF3
Private cFasePro  := cFase
Private cFilSY6   := xFilial("SY6")
Private cFilEE9   := xFilial("EE9")
Private lInvPed   := .T. //Verifica se existe invoice a pagar no Pedido.

EE9->( dbSetOrder(1) )
//Se for pedido e possuir embarque ou for aprovacao de credito, apenas visualiza
lVisual:= (cFase == OC_PE .AND. ( EE9->( dbSeek(cFilEE9+M->EE7_PEDIDO) )) .OR. nSelecao == APRVCRED .OR. nSelecao == VISUALIZAR .OR. nSelecao == EXCLUIR)

If ValType(cFase) == "U"
   If Select("WORKIT") > 0
      cFase = OC_PE
   Else
      cFase = OC_EM
   Endif
Endif

//Ordem para validação
SA2->( dbSetOrder(1) )

Begin Sequence

   //ER - 11/02/2007 - Verifica se a Invoice foi vinculada na Fase de Pedido
   If cFase == OC_EM
      nOldReg := WorkIp->(RecNo())
      WorkIp->(DbGoTop())
      While WorkIp->(!EOF())
         EXK->(DbSetOrder(1))
         If !EXK->(DbSeek(xFilial("EXK")+OC_PE+WorkIp->EE9_PEDIDO))
            lInvPed := .F.
            Exit
         EndIf
         WorkIp->(DbSkip())
      EndDo
      WorkIp->(DbGoTo(nOldReg))
   EndIf

   //Atualiza o valor da invoice a pagar
   If cFase == OC_PE .or. (cFase == OC_EM .and. !lInvPed)
      AP106VlInv(cFase)
   Else
      AP106InvEmb()
   Endif

   If cFase == OC_PE .OR. !lF3 .or. !lInvPed
      //Carrega os dados já salvos na memória para o aCols passado para a MSGetDados
      aCols:= aClone(aColsBtB)
   Endif

   //Passa a variavel de aHeaderBtB para aHeader
   aHeader:= aClone(aHeaderBtB)

   If !lF3InvPag .AND. !lVisual .AND. (cFase == OC_PE .or. !lInvPed)
      /*aAlter:= { "EXK_FORN","EXK_LOJA","EXK_INVOIC","EXK_MOEINV","EXK_CONDPA", "EXK_DIASPA",; nopado por WFS em 26/05/09 */
      aAlter:= { "EXK_FORN","EXK_LOJA","EXK_INVOIC","EXK_MOEINV","EXK_CONDPA",; // WFS 26/05/09
                 "EXK_DTEMBA","EXK_FRETE","EXK_MOEFRE","EXK_SEGURO", "EXK_MOESEG" }
   ElseIf !lF3InvPag .and. cFase == OC_EM .and. lInvPed
      aAlter:= { "EXK_DTEMBA","EXK_FRETE","EXK_MOEFRE","EXK_SEGURO", "EXK_MOESEG" }
   Endif

   //Blocos para inicialização de Campos na GetDados
   //bIniLoja := { || GDFieldPut("EXK_LOJA","."+Space(aHeader[GDFieldPos("EXK_LOJA")][4]-1),Len(aCols)) }
   bIniLoja := { || GDFieldPut("EXK_LOJA",Space(aHeader[GDFieldPos("EXK_LOJA")][4]),Len(aCols)) }
   bIniVenc := { || GDFieldPut("EXK_DTEMBA",CtoD("  /  /  "),Len(aCols)) }

   If EasyEntryPoint("EECAP106")
      ExecBlock("EECAP106",.F.,.F.,{ "ANTES_TELA" })
   Endif

   If Len(aCols) == 0
      /*
      Nopado por ER - 06/02/2007
      Será permitido incluir invoices a pagar no Embarque.

      If cFase == OC_EM
         MsgStop(STR0019)//"Não há invoices a pagar vinculadas neste embarque"
         BREAK
      Endif
      */
      //Adiciona Linha vazia no aCols
      aAdd( aCols, Array( Len(aHeader)+1 ) )
      For i:= 1 To Len(aHeader)
         aCols[Len(aCols)][i]:= CriaVar(aHeader[i][2])
      Next
      Eval(bIniLoja)                                  //Inicializa campo Loja
      aCols[Len(aCols)][len(aHeader)+1] := .F.        //Marca como não deletado
   Endif

   //OSSME-5747 - Error log ao clicar na opção 
   DbSelectArea("EXK")

   DEFINE MSDIALOG oDlgB2B TITLE STR0001 FROM 10, 10 TO 430, 790 OF oMainWnd Pixel //"Invoices a Pagar - Back to Back"

   oPanel:=	TPanel():New(0,0, "", oDlgB2B,, .T., ,,,0,0,,.T.)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   n := 1
   oMSGetD:= MSGetDados():New(2, 2, 175, 390, nSelecao,"AP106LinOK", nil,nil,.T.,aAlter,nil,nil,1500,nil,nil,nil,,oPanel) //LGS-30/06/2016

   //Botão OK
   lBtOK:= .F.

   //Blocos de código para botões da EnchoiceBar
   bOK    := {|| lBtOK:= .T.,oDlgB2B:End() }
   bCancel:= {|| aCols:= {} ,oDlgB2B:End() }

   //Bloco chamado na Inclusão de Linha da GetDados - Inicializa o campo LOJA
   If !lF3InvPag .AND. !lVisual .AND. (cFase == OC_PE .or. !lInvPed)
      oMSGetD:oBROWSE:bADD       := { || oMSGetD:LCHGFIELD := .F., oMSGetD:ADDLINE(),EVAL(bIniLoja),EVAL(bIniVenc) }
      oMSGetD:oBrowse:bDelete:= {|| AP106DelOK()}
   Else
      oMSGetD:oBROWSE:bADD    := {|| .F. }
      oMSGetD:oBrowse:bDelete := {|| .F. }
      If lF3InvPag
         oMSGetD:oBROWSE:bLDblClick := bOK //Duplo Clique
      Endif
   Endif

   ACTIVATE MSDIALOG oDlgB2B ON INIT EnchoiceBar(oDlgB2B,{|| if(AP106LinOK(),EVAL(bOk),.F.)},bCancel) CENTERED

   If lVisual
      RETURN .T.
   Endif

   If lF3InvPag
      If lBtOK
         //Atualiza os campos na Enchoice e Retorna a Invoice
         M->&( iif(cFase == OC_PE,"EE8","EE9")+"_FORN"  ) := GDFieldGet("EXK_FORN")
         M->&( iif(cFase == OC_PE,"EE8","EE9")+"_FOLOJA") := GDFieldGet("EXK_LOJA")
         cRetF3BtB := aCols[n][AP106FiPos("EXK_INVOIC")]
         RETURN .T.
      Else
         RETURN .F.
      Endif
   Endif

   //Elimina os Deletados
   aAux := {}
   aEval( aCols,{|XaCol,I| iIf(!GDDeleted(I) .OR. iIF(cFase == OC_EM, !Empty(GDFieldGet("EXK_INVOIC")),.F.), aAdd(aAux,aCols[i]),.F. )} )
   aCols:= {}
   aCols:= aAux

   //Grava alterações na memória ( aColsBtB )
   If lBtOK //.AND. Len(aCols) > 0 .AND. !Empty(GDFieldGet("EXK_INVOIC"))
      aColsBtB:= {}
      aColsBtB:= aClone(aCols)
      aCols:= {}
   Endif

End Sequence

RETURN NIL

/*
Funcao      : AP106LinOK
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Validação da linha da MSGetDados do Back To Back
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 01/09/2004
Revisao     :
Obs.        :
*/
Function AP106LinOK()
Local i
lVal:= .T.

//Verifica se há algum campo preenchido
For i:= 1 to Len(aHeader)
   If !Empty(aCols[n][i])
      If aHeader[i][2] == "EXK_LOJA"
         Loop
      Endif
      lVal:= .T.
      Exit
   Endif
   lVal:= .F.
Next

//Se não houver, exclui a ultima linha
If !lVal .AND. Len(aCols) > 1
   aAux:= {}
   aEval( aCols,{|XaCol,I| iIf(I <> Len(aCols) , aAdd(aAux,aCols[i]),.F. )} )
   aCols := {}
   aCols := aAux

   oMSGetD:ForceRefresh()
Endif

//Para o F3 não há validação
If lF3InvPag .OR. lVisual // .OR. cFasePro == OC_EM
   RETURN .T.
Endif

//Valida cada campo
For i:= 1 To Len(aHeader)
   If GDDeleted() //Desconsidera os Excluidos
      RETURN .T.
   Else
      //Verifica campos que não podem estar vazios
      If Empty(aCols[n][i]) .AND. aHeader[i][2] $ "EXK_FORN/EXK_LOJA/EXK_INVOIC/EXK_MOEINV/EXK_CONDPA" //EXK_DIASPA" - retirado por WFS em 27/05/09
         MsgStop(STR0002+aHeader[i][1])//"Este campo não pode estar vazio.Campo: "
         Return .F.
      Endif

      //Atualiza a variavel de validação
      M->&(aHeader[i][2]) := aCols[n][i]

      //Executa a validação do Dicionário para essa Coluna
      lVal:= &(aHeader[i][6])
      If !lVal
         MsgStop(STR0003+aHeader[i][1])//"Campo: "
         RETURN .F.
      Endif
   Endif
Next

//Valida Fornecedor+Loja+Invoice
For i:= 1 to Len(aCols)
   If GDFieldGet("EXK_FORN",i)+GDFieldGet("EXK_LOJA",i)+GDFieldGet("EXK_INVOIC",i) == GDFieldGet("EXK_FORN",n)+GDFieldGet("EXK_LOJA",n)+GDFieldGet("EXK_INVOIC",n);
   .AND. i <> n
      MsgStop(STR0004)//"Invoice já cadastrada para esse fornecedor e loja."
      lRet := .F.
   EndIf
Next

//Validações de Frete e Seguro
If Empty(GDFieldGet("EXK_FRETE")) .AND. !Empty(GDFieldGet("EXK_MOEFRE"))
   MsgStop(STR0005)//"Moeda do frete não pode estar preenchida caso não haja frete"
   RETURN .F.
Elseif !Empty(GDFieldGet("EXK_FRETE")) .AND. Empty(GDFieldGet("EXK_MOEFRE"))
   MsgStop(STR0006)//"Moeda do frete deve estar preenchida caso haja frete"
   RETURN .F.
Elseif Empty(GDFieldGet("EXK_SEGURO")) .AND. !Empty(GDFieldGet("EXK_MOESEG"))
   MsgStop(STR0007)//"Moeda do seguro não pode estar preenchida caso não haja seguro"
   RETURN .F.
Elseif !Empty(GDFieldGet("EXK_SEGURO")) .AND. Empty(GDFieldGet("EXK_MOESEG"))
   MsgStop(STR0008)//"Moeda do seguro deve estar preenchida caso haja seguro"
   RETURN .F.
Endif

RETURN .T.

/*
Funcao      : AP106DelOK()
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Validação da exclusão da linha da MSGetDados do Back To Back
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 09/09/04 - 14:15
Revisao     :
Obs.        :
*/
Function AP106DelOK()
lRet:= .T.

//Verifica se o valor da invoice é maior que 0
nPos := AP106FiPos("EXK_VLINV")
If nPos > 0
   If aCols[n][nPos] > 0
      MsgStop(STR0009)//"Invoice não pode ser excluida pois há itens vinculados a serem pagos"
      lRet := .F.
   Endif
Endif

If lRet
   //Inverte a Flag de Deleção
   aCols[n][Len(aCols[n])] := !aCols[n][Len(aCols[n])]

   oMSGetD:oBrowse:Refresh(.F.)
Endif

RETURN lRet

/*
Funcao      : AP106Dados()
Parametros  : Fase do Processo ( OC_EM / OC_PE )
Retorno     : .T.
Objetivos   : Carrega os dados da tabela EXK para o aColsBtB
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 31/08/2004 17:00
Revisao     :
Obs.        :
*/
Function AP106Dados(cFase)
Local i
Local cProcesso := iif(cFase == OC_PE,M->EE7_PEDIDO,EEC->EEC_PREEMB)

//Apenas adiciona a coluna EXK_INV
AP106ColVl(cFase)

If EasyEntryPoint("EECAP106")
   ExecBlock("EECAP106",.F.,.F.,{ "ANTES_CARREGAR" })
Endif

If nSelecao <> INCLUIR .AND. len(aColsBtB) == 0
   EXK->( dbSetOrder(1) )
   EXK->( dbSeek(cFilEXK+cFase+cProcesso) )
   Do While !EXK->( EoF() ) .AND. EXK->EXK_TIPO == cFase .AND. EXK->EXK_PROC == cProcesso
      //Carrega os dados para o aColsBtB
      aAdd( aColsBtB, Array( Len(aHeaderBtB)+1 ) )
      //RMD - 19/09/2006 - Alterada a forma como o aCols é alimentado, para não ficar fixo o número de campos da EXK
      /*
      For i:= 4 To EXK->( FCount() )
         //Carrega a partir do 4o campo, pois os 3 primeiros sao campos chave que não aparecem na MSGetDados
         aColsBtB[Len(aColsBtB)][i-3]:= EXK->( FieldGet(i) )
      Next
      */
      For i := 1 To Len(aHeaderBtB)
         aColsBtB[Len(aColsBtB)][i]:= EXK->&(aHeaderBtB[i][2])
      Next
      aColsBtB[Len(aColsBtB)][Len(aHeaderBtB)+1] := .F. //Marca como não deletado
      EXK->( dbSkip() )
   EndDo
Endif

RETURN .T.

/*
Funcao      : AP106Cols()
Parametros  : cFase = Fase do Processo ( OC_PE / OC_EM )
Retorno     : .T.
Objetivos   : Carrega o Array de campos da Invoice a Pagar
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 31/08/2004 16:40
Revisao     :
Obs.        :
*/
Function AP106Cols(cFase)

// Array de Colunas do MSGETDADOS para o Back To Back
aAdd(aHeaderBtB,{AVSX3("EXK_FORN",5)   ,"EXK_FORN"   ,AVSX3("EXK_FORN",6)    ,AVSX3("EXK_FORN",3)   ,AVSX3("EXK_FORN",4)   ,'EVAL(AVSX3("EXK_FORN",7)   )',nil,AVSX3("EXK_FORN",2)   ,nil,nil } )
aAdd(aHeaderBtB,{AVSX3("EXK_LOJA",5)   ,"EXK_LOJA"   ,AVSX3("EXK_LOJA",6)    ,AVSX3("EXK_LOJA",3)   ,AVSX3("EXK_LOJA",4)   ,'EVAL(AVSX3("EXK_LOJA",7)   )',".",AVSX3("EXK_LOJA",2)   ,".","." } )
aAdd(aHeaderBtB,{AVSX3("EXK_INVOIC",5) ,"EXK_INVOIC" ,AVSX3("EXK_INVOIC",6)  ,AVSX3("EXK_INVOIC",3) ,AVSX3("EXK_INVOIC",4) ,'EVAL(AVSX3("EXK_INVOIC",7))' ,nil,AVSX3("EXK_INVOIC",2) ,nil,nil } )
aAdd(aHeaderBtB,{AVSX3("EXK_MOEINV",5) ,"EXK_MOEINV" ,AVSX3("EXK_MOEINV",6)  ,AVSX3("EXK_MOEINV",3) ,AVSX3("EXK_MOEINV",4) ,'EVAL(AVSX3("EXK_MOEINV",7) )',nil,AVSX3("EXK_MOEINV",2) ,nil,nil } )
If cFase == OC_EM
   aAdd(aHeaderBtB,{AVSX3("EXK_VLINV",5)  ,"EXK_VLINV"  ,AVSX3("EXK_VLINV",6)   ,AVSX3("EXK_VLINV",3)  ,AVSX3("EXK_VLINV",4)  ,'.T.'                         ,nil,AVSX3("EXK_VLINV",2)  ,nil,nil } )
Endif
aAdd(aHeaderBtB,{AVSX3("EXK_CONDPA",5) ,"EXK_CONDPA" ,AVSX3("EXK_CONDPA",6)  ,AVSX3("EXK_CONDPA",3) ,AVSX3("EXK_CONDPA",4) ,'EVAL(AVSX3("EXK_CONDPA",7) )',nil,AVSX3("EXK_CONDPA",2) ,nil,nil } )
aAdd(aHeaderBtB,{AVSX3("EXK_DIASPA",5) ,"EXK_DIASPA" ,AVSX3("EXK_DIASPA",6)  ,AVSX3("EXK_DIASPA",3) ,AVSX3("EXK_DIASPA",4) ,'EVAL(AVSX3("EXK_DIASPA",7) )',nil,AVSX3("EXK_DIASPA",2) ,nil,nil } )
aAdd(aHeaderBtB,{AVSX3("EXK_DTEMBA",5) ,"EXK_DTEMBA" ,AVSX3("EXK_DTEMBA",6)  ,AVSX3("EXK_DTEMBA",3) ,AVSX3("EXK_DTEMBA",4) ,'EVAL(AVSX3("EXK_DTEMBA",7) )',nil,AVSX3("EXK_DTEMBA",2) ,nil,nil } )
aAdd(aHeaderBtB,{AVSX3("EXK_MOEFRE",5) ,"EXK_MOEFRE" ,AVSX3("EXK_MOEFRE",6)  ,AVSX3("EXK_MOEFRE",3) ,AVSX3("EXK_MOEFRE",4) ,'EVAL(AVSX3("EXK_MOEFRE",7) )',nil,AVSX3("EXK_MOEFRE",2) ,nil,nil } )
aAdd(aHeaderBtB,{AVSX3("EXK_FRETE",5)  ,"EXK_FRETE"  ,AVSX3("EXK_FRETE",6)   ,AVSX3("EXK_FRETE",3)  ,AVSX3("EXK_FRETE",4)  ,'EVAL(AVSX3("EXK_FRETE",7)  )',nil,AVSX3("EXK_FRETE",2)  ,nil,nil } )
aAdd(aHeaderBtB,{AVSX3("EXK_MOESEG",5) ,"EXK_MOESEG" ,AVSX3("EXK_MOESEG",6)  ,AVSX3("EXK_MOESEG",3) ,AVSX3("EXK_MOESEG",4) ,'EVAL(AVSX3("EXK_MOESEG",7) )',nil,AVSX3("EXK_MOESEG",2) ,nil,nil } )
aAdd(aHeaderBtB,{AVSX3("EXK_SEGURO",5) ,"EXK_SEGURO" ,AVSX3("EXK_SEGURO",6)  ,AVSX3("EXK_SEGURO",3) ,AVSX3("EXK_SEGURO",4) ,'EVAL(AVSX3("EXK_SEGURO",7) )',nil,AVSX3("EXK_SEGURO",2) ,nil,nil } )

Return .T.

/*
Funcao      : AP106EnchBar()
Parametros  : cFase = Fase do Processo ( OC_PE / OC_EM )
Retorno     : .T.
Objetivos   : Adiciona o Botão 'Invoices a Pagar - Back To Back' na Enchoice Bar
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 31/08/2004 16:40
Revisao     :
Obs.        :
*/
Function AP106EnchBar(cFase)

aAdd(aButtons,{"PRECO",{|| EECAP106(cFase) },STR0001,STR0001}) //"Invoices a Pagar - Back To Back"###"Invoices a Pagar - Back To Back"

Return .T.

/*
Funcao      : AP106VlInv()
Parametros  : cFase = Fase do Processo ( OC_PE / OC_EM )
Retorno     : .T. caso o calculo tenha sido realizado.
              .F. caso contrário.
Objetivos   : Atualiza o Valor da Invoice a Pagar no Back To Back
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 03/09/2004 15:00
Revisao     :
Obs.        :
*/
Function AP106VlInv(cFase)
cArea := iIF( cFase == OC_PE,"WORKIT","WORKIP" )

//Verifica se a coluna com o valor da invoice a pagar existe e cria se necessario
If !AP106ColVl(cFase)
   RETURN .F.
Endif

//Soma os (itens * QTD) e encontra o valor da invoice a pagar
nOldRec:=(cArea)->( RecNo() )//Guarda posição da Work
(cArea)->( dbGoTop() )
Do while (cArea)->( !EoF() )
   //Soma todos os itens de mesmo fornecedor+loja+invoice a pagar
   nPosINV:= aScan(aColsBtB,{|X| X[AP106FiPos("EXK_FORN"  )] == iIF( cFase == OC_PE,WORKIT->EE8_FORN  ,WORKIP->EE9_FORN  );
                           .AND. X[AP106FiPos("EXK_LOJA"  )] == iIF( cFase == OC_PE,WORKIT->EE8_FOLOJA,WORKIP->EE9_FOLOJA);
                           .AND. X[AP106FiPos("EXK_INVOIC")] == iIF( cFase == OC_PE,WORKIT->EE8_INVPAG,WORKIP->EE9_INVPAG) })
   If nPosINV > 0
      aColsBtB[nPosINV][AP106FiPos("EXK_VLINV")] += iIF( cFase == OC_PE, WORKIT->EE8_SLDINI * WORKIT->EE8_VLPAG,;//Qtd * Valor
                                                           WORKIP->EE9_SLDINI * WORKIP->EE9_VLPAG )
   Endif
   (cArea)->( dbSkip() )
Enddo
(cArea)->( dbGoTo(nOldRec) )//Retorna posição anterior da Work

RETURN .T.

/*
Funcao      : AP106ColVl(cFase)
Parametros  : cFase = Fase do Processo ( OC_PE / OC_EM )
Retorno     : .T. caso o a coluna já exista ou foi criada.
              .F. caso contrário.
Objetivos   : Adiciona a coluna EXK_VLINV no aHeaderBtB e já acerta o aColsBtB
              para exibição do Valor da Invoice a Pagar
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 03/09/2004 15:15
Revisao     :
Obs.        :
*/
Function AP106ColVl(cFase)
Local i

cArea := iIF( cFase == OC_PE,"WORKIT","WORKIP" )

//Verifica se Coluna EXK_VLINV existe, e cria caso não a encontre e exista itens no pedido
nPosVLINV:= AP106FiPos("EXK_VLINV")
If !(cArea)->( EoF() .AND. BoF() )
   If nPosVLINV == 0
      //Cria a Coluna após a Moeda da Invoice
      nPosVLINV:= AP106FiPos("EXK_MOEINV")+1
      aAdd(aHeaderBtB,nil)
      aIns(aHeaderBtB,nPosVLINV)
      aHeaderBtB[nPosVLINV] := {AVSX3("EXK_VLINV",5)  ,"EXK_VLINV"  ,AVSX3("EXK_VLINV",6)   ,AVSX3("EXK_VLINV",3)  ,AVSX3("EXK_VLINV",4)  ,'.T.'                         ,nil,AVSX3("EXK_VLINV",2)  ,nil,nil }
   Endif
Else
   If nPosVLINV == 0
      RETURN .F.
   Endif
Endif

For i := 1 to Len(aColsBtB)
   If !Len(aColsBtB[i]) > Len(aHeaderBtB)
      //Adiciona mais uma coluna,
      //pois a coluna EXK_VLINV não existia pois não havia itens no pedido
      aAdd(aColsBtB[i],nil)
      aIns(aColsBtB[i],nPosVLINV)
   Endif
   aColsBtB[i][nPosVLINV] := 0
Next

RETURN .T.

/*
Funcao      : AP106ItemEnc()
Parametros  : Fase do Processo ( OC_EM / OC_PE )
Retorno     : .T.
Objetivos   : Acerta o array de campos visiveis da enchoice dos itens do pedido, para exibir os campos
              de Back To Back.
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 09/09/04 - 11:56
Revisao     :
Obs.        :
*/
Function AP106ItemEnc(cFase,cPedido)

Local cInvPag := iIF(cFase == OC_PE,"EE8_INVPAG","EE9_INVPAG")
Local cVlPag  := iIF(cFase == OC_PE,"EE8_VLPAG" ,"EE9_VLPAG" )
Local aOrd := SaveOrd({"EE9"})
EE9->(DbSetOrder(1))
If ValType(cPedido) <> "C"
   cPedido := ""
Endif

/*
If cFase == OC_PE
   //Caso tenha ao menos uma Invoice, adiciona os campos do Back To Back nos itens
   lCond := Len(aColsBtB) > 0
Else
   //Caso o pedido seja Back to Back
   lCond := EXK->( dbSeek(cFilEXK+OC_PE+cPedido) )
Endif
*/
lCond := Len(aColsBtB) > 0

If lCond

   //Adiciona os campos do Back to Back na Enchoice
   If aScan(aItemEnchoice,cInvPag) == 0
      aAdd(aItemEnchoice,cInvPag)
      aAdd(aItemEnchoice,cVlPag)
      //** PLB 17/04/06 - Permite alteração dos campos Valor Unitário a Pagar
      //RMD - 05/05/06 - Não permite a alteração dos campos quando já estiver vinculado em fase de embarque.
      If cFase == OC_PE .AND. !(EE9->(DbSeek(xFilial()+M->(EE8_PEDIDO+EE8_SEQUEN))) .OR. nSelecao == APRVCRED .OR. nSelecao == VISUALIZAR)
         IIF(aScan(aEE8CamposEditaveis,cInvPag) == 0 , aAdd(aEE8CamposEditaveis,cInvPag) , )
         IIF(aScan(aEE8CamposEditaveis,cVlPag ) == 0 , aAdd(aEE8CamposEditaveis,cVlPag)  , )
      //**
      ElseIf cFase == OC_EM
         //Permite alteração do campo Valor Unitário a Pagar
         aAdd(aAltera,cInvPag)
         aAdd(aAltera,cVlPag)
      Endif
   Endif

      //Acerta o array de campos alteráveis, não permitindo alteração do campo de Invoice a Pagar
   /*
   If cFase == OC_EM
      aAux:= {}
      aEval( aAltera,{|cCampo| iIF(! cCampo $ "EE9_INVPAG / EE9_FORN / EE9_FOLOJA", aAdd(aAux,cCampo),.F. )} )
      aAltera := aAux
   Endif
   */

   //Caso seja inclusão de item no pedido, já inicializa o Fornecedor e Loja da Primeira Invoice do Back to Back
   If cFase == OC_PE .AND. nOPCI == INC_DET
      M->&( iif( cFase == OC_PE, "EE8","EE9" )+"_FORN"   ) := aColsBtB[1][AP106FiPos("EXK_FORN")]
      M->&( iif( cFase == OC_PE, "EE8","EE9" )+"_FOLOJA" ) := aColsBtB[1][AP106FiPos("EXK_LOJA")]
   Endif
Else
   //Caso o Pedido deixe de ser Back to Back, elimina os campos do Back to Back da Enchoice
   nPos:= aScan(aItemEnchoice,cInvPag)
   If nPos > 0
      aAux:= {}
   	   aEval( aItemEnchoice,{|cCampo| iIf(cCampo <> cInvPag .AND. cCampo <> cVlPag, aAdd(aAux,cCampo),.F. )} )
      aItemEnchoice:= aAux
   Endif
Endif
RestOrd(aOrd, .T.)
RETURN .T.

/*
Funcao      : AP106Valid
Parametros  : cValid = Parametro de Validação
Retorno     : .T./.F.
Objetivos   : Validações do Back to Back no Pedido
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 10/09/04 - 13:30
Revisao     :
Obs.        :
*/
Function AP106Valid(cValid)
Local i
Local nOldReg := 0
Local lInvPed := .T.
lRet := .T.

If Left(cValid,3) $ "EE9 / EEC"

   nOldReg := WorkIp->(RecNo())
   WorkIp->(DbGoTop())
   While WorkIp->(!EOF())
      EXK->(DbSetOrder(1))
      If !EXK->(DbSeek(xFilial("EXK")+OC_PE+WorkIp->EE9_PEDIDO))
         lInvPed := .F.
         Exit
      EndIf
      WorkIp->(DbSkip())
   EndDo
   WorkIp->(DbGoTo(nOldReg))
EndIf

If cValid $ "EXK_FRETE / EXK_SEGURO / EE9_VLPAG / EE8_VLPAG" .AND. M->&(cValid) < 0
   //Chamado do X3_VALID dos campos acima
   MsgStop(STR0016)//"Valor não pode ser menor que zero."
   RETURN .F.
Endif

If cValid $ "EXK_FORN / EXK_LOJA / EXK_INVOIC"
   //Chamado do X3_VALID dos campos acima
   nPosVLINV := GDFieldPos("EXK_VLINV")
   if nPosVLINV > 0 .AND. aCols[n][nPosVLINV] > 0 .AND. GDFieldGet(cValid,n) <> M->&(cValid)
      MsgStop(STR0017)//"Campo não pode ser alterado pois já possui itens vinculados a esta invoice"
      RETURN .F.
   EndIf
Endif

//** AAF 29/06/05 - Devido a problema com Validação no Fornecedor.
If cValid == "EXK_FORN"
   aOrdSA2:= SaveOrd("SA2")
   SA2->( dbSetOrder(1) )
   If !SA2->( dbSeek(xFilial("SA2")+M->EXK_FORN+GDFieldGet("EXK_LOJA",n)) )
      If SA2->( dbSeek(xFilial("SA2")+M->EXK_FORN) )
         GDFieldPut("EXK_LOJA", SA2->A2_LOJA, n)
      Else
         RestOrd(aOrdSA2)
         Help(" ", 1, "REGNOIS")
         RETURN .F.
      EndIf
   Endif
   RestOrd(aOrdSA2)
Endif
//**

If cValid == "PE_DET_OK"
   //Chamado do EECAP100
   If Len(aColsBtB) > 0 .AND. aScan(aColsBtB,{ |X| X[1] == M->EE8_FORN .AND. X[2] == M->EE8_FOLOJA .AND. X[3] == M->EE8_INVPAG }) == 0 .and. !Empty(M->EE8_INVPAG)
      MsgStop(STR0010)//"Essa Invoice a Pagar não pertence esse Fornecedor/Loja"
      lRet:= .F.
   EndIf

   If lRet
      //ER - 05/05/2006
      If !Empty(M->EE8_INVPAG) .and. Empty(M->EE8_VLPAG)
         MsgStop(STR0044)//"Preencha o Campo 'Pre. Un. Pag'"
         lRet:= .F.
      EndIf
   EndIf

   If lRet
      //ER - 05/05/2006
      If Empty(M->EE8_INVPAG) .and. !Empty(M->EE8_VLPAG)
         MsgStop(STR0045)//"Para informar o preço, preencha o campo 'Invoice Pag.' "
         lRet := .F.
      EndIf
   EndIf

   If lRet
      lRet:= AP106Valid("EE8_VLPAG")
   Endif

ElseIf cValid == "PE_PED_OK"
   //Chamado do EECAP100
   WORKIT->( dbGoTop() )
   Do While WORKIT->( !EoF() )
      If Empty(WORKIT->EE8_INVPAG)
         MsgStop(STR0011+WORKIT->EE8_SEQUEN)//"Processo contém Invoices a Pagar mas há itens não cadastrados para Back to Back. Sequencia do Item: "
         lRet:= .F.
         Exit
      Endif
      WORKIT->( dbSkip() )
   EndDo

ElseIf cValid == "EE8_INVPAG" .OR. cValid == "EE9_INVPAG"
   //Chamado do X3_VALID do EE8_INVPAG e EE9_VLPAG
   //Busca no aColsBtB para encontrar Invoice
   cAlias := Left(cValid,3)

   If cAlias == "EE8"
      //No Pedido
      lCond := aScan(aColsBtB,{ |x| X[AP106FiPos("EXK_FORN"  )] == M->EE8_FORN;
                              .AND. X[AP106FiPos("EXK_LOJA"  )] == M->EE8_FOLOJA;
                              .AND. X[AP106FiPos("EXK_INVOIC")] == M->EE8_INVPAG }) == 0
   Else
      //No Embarque
      EXK->( dbSetOrder(1) )
      If !lInvPed
         lCond := aScan(aColsBtB,{ |x| X[AP106FiPos("EXK_FORN"  )] == M->EE9_FORN;
                                 .AND. X[AP106FiPos("EXK_LOJA"  )] == M->EE9_FOLOJA;
                                 .AND. X[AP106FiPos("EXK_INVOIC")] == M->EE9_INVPAG }) == 0
      Else
         lCond := !EXK->( dbSeek(cFilEXK+OC_PE+M->EE9_PEDIDO+M->EE9_FORN+M->EE9_FOLOJA+M->EE9_INVPAG) )
      EndIf
   Endif

   IF lCond .and. !Empty(M->&(cValid))
      MsgStop(STR0012)//"Invoice não cadastrada para esse fornecedor e loja em BACK to BACK"
      lRet := .F.
   Endif

ElseIf cValid == "EE8_VLPAG" .OR. cValid == "EE9_VLPAG"
   //Chamado do X3_VALID do EE8_VLPAG e EE9_VLPAG
   //Converte os valores e compara
   cAlias := Left(cValid,3)

   If cAlias == "EE8"
      //No Pedido
      nPosInv   := aScan(aColsBtB,{ |x| X[AP106FiPos("EXK_FORN"  )] == M->&(cAlias+"_FORN");
                                  .AND. X[AP106FiPos("EXK_LOJA"  )] == M->&(cAlias+"_FOLOJA");
                                  .AND. X[AP106FiPos("EXK_INVOIC")] == M->&(cAlias+"_INVPAG") })
      lCond := nPosInv > 0
   Else
      //No Embarque
      EXK->( dbSetOrder(1) )
      If !lInvPed
         nPosInv   := aScan(aColsBtB,{ |x| X[AP106FiPos("EXK_FORN"  )] == M->&(cAlias+"_FORN");
                                     .AND. X[AP106FiPos("EXK_LOJA"  )] == M->&(cAlias+"_FOLOJA");
                                     .AND. X[AP106FiPos("EXK_INVOIC")] == M->&(cAlias+"_INVPAG") })
         lCond := nPosInv > 0
      Else
         lCond := EXK->( dbSeek(cFilEXK+OC_PE+M->EE9_PEDIDO+M->EE9_FORN+M->EE9_FOLOJA+M->EE9_INVPAG) )
      EndIf

   EndIf

   If lCond
      //Moedas
      If !lInvPed
         cMoedaPag := aColsBtB[nPosInv][AP106FiPos("EXK_MOEINV")]
      Else
         cMoedaPag := iIF(cAlias == "EE8",aColsBtB[nPosInv][AP106FiPos("EXK_MOEINV")],EXK->EXK_MOEINV)
      EndIf
      cMoedaRec := iIF(cAlias == "EE8",M->EE7_MOEDA,M->EEC_MOEDA)

      //Valores
      nVlPagR := M->&(cAlias+"_VLPAG") * iIF(cMoedaPag <> "R$ ",BuscaTaxa(cMoedaPag,dDataBase),1)
      nVlRecR := M->&(cAlias+"_PRECO") * iIF(cMoedaRec <> "R$ ",BuscaTaxa(cMoedaRec,dDataBase),1)

      If nVlPagR > nVlRecR
         //Adiciona a Picture
         cPictVlPag := AVSX3(cAlias+"_VLPAG",6)
         cVlPagUS := Transform(M->&(cAlias+"_VLPAG"),cPictVlPag)
         cVlRecUS := Transform(M->&(cAlias+"_PRECO"),cPictVlPag)
         cVlPagR  := Transform(nVlPagR              ,cPictVlPag)
         cVlRecR  := Transform(nVlRecR              ,cPictVlPag)

         MsgInfo(STR0013 + CHR(13) + CHR(10)+;//"Valor a pagar pelo item é maior do que o valor a receber."
                 CHR(13) + CHR(10)+;
                 STR0014 + cMoedaPag + ": " + AllTrim(cVlPagUS) + CHR(13) + CHR(10)+;
                 STR0015 + cMoedaRec + ": " + AllTrim(cVlRecUS) + CHR(13) + CHR(10)+;
                 STR0014 + "R$ "     + ": " + AllTrim(cVlPagR ) + CHR(13) + CHR(10)+;
                 STR0015 + "R$ "     + ": " + AllTrim(cVlRecR ) )
      EndIf

   EndIf

ElseIf cValid == "EXK_INVOIC"
   //Chamado do X3_VALID do campo EXK_INVOIC
   If Empty(M->EXK_INVOIC)
      lRet := .F.
   Endif

   //Valida Fornecedor+Loja+Invoice
   For i:= 1 to Len(aCols)
      If GDFieldGet("EXK_FORN",i)+GDFieldGet("EXK_LOJA",i)+GDFieldGet("EXK_INVOIC",i) == GDFieldGet("EXK_FORN",n)+GDFieldGet("EXK_LOJA",n)+M->EXK_INVOIC;
      .AND. i <> n
         MsgStop(STR0004)//"Invoice já cadastrada para esse fornecedor e loja."
         lRet := .F.
      EndIf
   Next

ElseIf cValid == "EM_VAL_PEDIDO"
   //Valida na Seleção de Pedidos no Embarque
   cOldArea:= Alias()
   cFilter := WORKIP->( dbFilter() )
   WorkIP->(dbSetFilter({|| WP_FLAG == cMarca },"WP_FLAG =='"+cMarca+"'"))

   WORKIP->(DbGoTop())
   If  !( WORKIP->( EoF() ) .AND. WORKIP->( BoF() ) ) .AND. WORKIP->EE9_PEDIDO <> EE7->EE7_PEDIDO .AND.;
       ( AP106isBackTo(EE7->EE7_PEDIDO,OC_PE) .OR. AP106isBackTo(WORKIP->EE9_PEDIDO,OC_PE) )
      lRet:= .F.
      MsgStop(STR0018)//"Não é possivel consolidar pedidos para um embarque Back to Back"
   Endif

   dbSelectArea("WORKIP")
   SET FILTER TO &cFilter
   dbSelectArea(cOldArea)

ElseIf cValid == "EXK_CONDPA"
   /*If SY6->( dbSeek(cFilSY6+M->EXK_CONDPA) ) nopado por WFS 26/05/09
      GDFieldPut("EXK_DIASPA", SY6->Y6_DIAS_PA)
   EndIf - nopado por WFS 26/05/09 */
   //WFS 27/05/09
   //Quando é alterado via F3
   If Empty(GDFieldGet("EXK_DIASPA", n)) .And. M->EXK_CONDPA == SY6->Y6_COD
      GDFieldPut("EXK_DIASPA", SY6->Y6_DIAS_PA)
   EndIf
   //Quando a condição de pagamento é digitada
   If M->EXK_CONDPA <> SY6->Y6_COD .And. M->EXK_CONDPA <> GDFieldGet("EXK_CondPa", n)
         SY6->(DBSeek(cFilSY6 + M->EXK_CONDPA))
         GDFieldPut("EXK_DIASPA", SY6->Y6_DIAS_PA)
   EndIf

   If SY6->Y6_TIPO == "3"
      If SY6->Y6_DIAS_01 < 0
         MsgStop(STR0021)//"Pagamento Antecipado não permitido em Back to Back"
         lRet:= .F.
      Endif
   Endif

ElseIf cValid == "EEC_DTEMBA"
   Begin Sequence

      If !Empty(M->EEC_DTEMBA)
         If Len(aColsBtb) == 0
            MsgStop(STR0019) //"Näo ha invoices a pagar vinculadas neste embarque"
            lRet := .F.
            Break
         EndIf
      EndIf

      //Chamado na validação do campo EEC_DTEMBA
      If !Empty(M->EEC_DTEMBA)
         For i:= 1 to Len(aColsBtB)
            If aColsBtB[i][AP106FiPos("EXK_DTEMBA")] > M->EEC_DTEMBA
               MsgStop(STR0020)//"Embarque não pode ocorrer antes do embarque do fornecedor de Back to Back"
               lRet := .F.
               BREAK
            Elseif Empty( aColsBtB[i][AP106FiPos("EXK_DTEMBA")] )
               //AAF 22/10/04
               aColsBtB[i][AP106FiPos("EXK_DTEMBA")] := M->EEC_DTEMBA
            Endif
         Next

      Endif

      //AAF 22/10/04
      cFilEEQ:= xFilial("EEQ")
      EEQ->( dbSetOrder(1) )
      EEQ->( dbSeek(cFilEEQ+M->EEC_PREEMB) )
      Do while !EEQ->( EoF() ) .AND. EEQ->EEQ_FILIAL == cFilEEQ .AND. EEQ->EEQ_PREEMB == M->EEC_PREEMB
         If EEQ->EEQ_EVENT == '129' .AND. !Empty(EEQ->EEQ_PGT)//Invoice a Pagar Back to Back
            MsgStop(STR0027)//"Data de Embarque não pode ser vazia pois já existe contratação de cambio para Back to Back"
            lRet := .F.
            BREAK
         Endif
         EEQ->( dbSkip() )
      Enddo

   End Sequence
Elseif cValid == "EXK_DTEMBA"
   //AAF 22/10/04
   if cFasePro == OC_EM .AND. !Empty(M->EEC_DTEMBA)
      If Empty(M->EXK_DTEMBA)
         MsgStop(STR0028)//"Data de embarque de fornecedor Back to Back não pode estar vazia pois o processo já está embarcado."
         lRet:= .F.
      Elseif M->EXK_DTEMBA > M->EEC_DTEMBA
         MsgStop(STR0029)//"Embarque de fornecedor Back to Back não pode ocorrer após a data de embarque de Exportação"
         lRet:= .F.
      Endif
   Endif

EndIf

Return lRet

/*
Funcao      : AP106Grv()
Parametros  : Fase do Processo ( OC_PE / OC_EM )
Retorno     : .T.
Objetivos   : Gravação das invoices a pagar do Back To Back
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 03/09/2004 14:30
Revisao     :
Obs.        :
*/
Function AP106Grv(cFase)
Local nLin,nCol
Local nOldReg   :=  0

Private lInvPed := .T.

cFilSY6 := xFilial("SY6")

//ER - 11/02/2007
If cFase == OC_EM
   nOldReg := WorkIp->(RecNo())
   WorkIp->(DbGoTop())
   While WorkIp->(!EOF())
      EXK->(DbSetOrder(1))
      If !EXK->(DbSeek(xFilial("EXK")+OC_PE+WorkIp->EE9_PEDIDO))
         lInvPed := .F.
         Exit
      EndIf
      WorkIp->(DbSkip())
   EndDo
   WorkIp->(DbGoTo(nOldReg))
EndIf


//AAF 25/10/04 - Coloca na ordem de Gravação da Invoices a Pagar
aColsBtB  := aSort( aColsBtB,,,{|x,y| x[1] + x[2] + x[3] + x[4] < y[1] + y[2] + y[3] + y[4]} )

cProcesso := iIF(cFase == OC_PE, M->EE7_PEDIDO, M->EEC_PREEMB)

If cFase == OC_PE .or. !lInvPed
   //Atualiza o valor das invoices a pagar
   AP106VlInv(cFase)
Else
   If lInvPed .and. cFase == OC_EM
      //Atualiza o valor das invoices a pagar, frete e seguro caso necessarios
      AP106InvEmb()
   EndIf
Endif

EXK->( dbSetOrder(1) )
EXK->( dbSeek(cFilEXK+cFase+cProcesso) )
For nLin:= 1 to Len(aColsBtB)

   //Enquanto se tratar das invoices do mesmo pedido, apenas trava e altera os registro
   //Grava todas as invoices
   If EXK->( !EoF() ) .AND. EXK->EXK_TIPO == cFase .AND. EXK->EXK_PROC == cProcesso
      RecLock("EXK",.F.)
   Else
      RecLock("EXK",.T.)
   Endif

   EXK->EXK_FILIAL := cFilEXK
   EXK->EXK_TIPO   := cFase
   EXK->EXK_PROC   := cProcesso
   For nCol:= 1 to Len(aHeaderBtB)
      EXK->( FieldPut(nCol + 3, aColsBtB[nLin][nCol]) )
   Next
   EXK->( dbSkip() )
Next

//Exclui o restante dos registros que ainda pertencem a este pedido
Do While EXK->( !EoF() ) .AND. EXK->EXK_TIPO == cFase .AND. EXK->EXK_PROC == cProcesso
   RecLock("EXK",.F.)
   EXK->( dbDelete() )
   EXK->( MsUnLock() )
   EXK->( dbSkip() )
EndDo
EXK->( dbCommit() )

Return .T.

/*
Funcao      : AP106InvEmb()
Parametros  : lCalc := Flag que indica se o calculo de frete e seguro deve ser realizado
Retorno     : .T.
Objetivos   : Adicionar Invoice a Pagar no Embarque e atualizar o valor das já inclusas
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 14/09/2004 12:06
Revisao     :
Obs.        :Chamada somente no Embarque
*/
Function AP106InvEmb(lCalc)
Default lCalc := .T.
nOldRec   := WORKIP->( RecNo() )
nPosVlInv := AP106FiPos("EXK_VLINV")


//Inclui as Invoices de Cada Item ou Adiciona em Invoice já inclusa
WORKIP->( dbGoTop() )
If WORKIP->( dbFilter() ) == "WP_FLAG =='"+cMarca+"'" .AND. WORKIP->( EoF() )
   //Caso não haja itens, não há invoices a pagar
   aColsBtB:= {}
Endif

Do While !WORKIP->( EoF() )
   nPos:= aScan(aColsBtB,{|X| X[AP106FiPos("EXK_FORN"  )] == WORKIP->EE9_FORN;
                        .AND. X[AP106FiPos("EXK_LOJA"  )] == WORKIP->EE9_FOLOJA;
                        .AND. X[AP106FiPos("EXK_INVOIC")] == WORKIP->EE9_INVPAG })

   EXK->( dbSetOrder(1) )
   EXK->( dbSeek(cFilEXK+OC_PE+WORKIP->EE9_PEDIDO+WORKIP->EE9_FORN+WORKIP->EE9_FOLOJA+WORKIP->EE9_INVPAG) )

   If nPos == 0
      //Adiciona Invoice
      aAdd( aColsBtB, Array( Len(aHeaderBtB)+1 ) )
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_FORN"  )] := WORKIP->EE9_FORN
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_LOJA"  )] := WORKIP->EE9_FOLOJA
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_INVOIC")] := WORKIP->EE9_INVPAG
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_MOEINV")] := EXK->EXK_MOEINV

      //Valor da Invoice
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_VLINV" )] := 0
      AP106VlInv(OC_EM)//Atualiza o Valor

      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_CONDPA")] := EXK->EXK_CONDPA
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_DIASPA")] := EXK->EXK_DIASPA
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_DTEMBA")] := EXK->EXK_DTEMBA

      //Frete
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_FRETE" )] := iIF(lCalc,AP106Frete(WORKIP->EE9_PEDIDO,WORKIP->EE9_INVPAG), EXK->EXK_FRETE)
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_MOEFRE")] := EXK->EXK_MOEFRETE

      //Seguro                                                         Seguro do Pedido * Valor atual da Invoice / Valor da Invoice no Pedido
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_SEGURO")] := iIF(lCalc,( EXK->EXK_SEGURO * aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_VLINV")] ) / EXK->EXK_VLINV , EXK->EXK_SEGURO)
      aColsBtB[Len(aColsBtB)][AP106FiPos("EXK_MOESEG")] := EXK->EXK_MOESEG
      aColsBtB[Len(aColsBtB)][len(aHeaderBtB)+1] := .F. //Marca como não deletado

   Elseif nPos > 0
      //Valor
      nOldVlInv := aColsBtB[nPos][AP106FiPos("EXK_VLINV")]
      //Valor da Invoice
      AP106VlInv(OC_EM)

      //Caso o Valor da Invoice esteja diferente, atualiza o valor de Frete e Seguro
      If nOldVlInv <> aColsBtB[nPos][AP106FiPos("EXK_VLINV" )]
         //Frete
         aColsBtB[nPos][AP106FiPos("EXK_FRETE" )] := AP106Frete(WORKIP->EE9_PEDIDO,WORKIP->EE9_INVPAG)
         //Seguro
         aColsBtB[nPos][AP106FiPos("EXK_SEGURO")] := ( EXK->EXK_SEGURO * aColsBtB[Len(aColsBtB)][5 ] ) / EXK->EXK_VLINV
      Endif
   Endif
   WORKIP->( dbSkip() )
EndDo
//Volta ao Registro em que estava
WORKIP->( dbGoTo(nOldRec) )

//Apaga as Invoice que não possuem itens ( Valor == 0 )
aAux:= {}
aEval(aColsBtB,{|XaCol,I| If(aColsBtB[I][AP106FiPos("EXK_VLINV")] > 0 ,aAdd(aAux,aColsBtB[I]),.F. )})
aColsBtB:= {}
aColsBtB:= aAux

Return .T.

/*
Funcao      : AP106Frete()
Parametros  : cPedido = Pedido com a base do Frete para Invoice a Pagar
              cInvPag = Invoice a Calcular o Frete
Retorno     : N - Calculo do Frete da Invoice a Pagar
Objetivos   : Retornar o Calculo do Frete da Invoice a Pagar
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 15/09/2004 09:52
Revisao     :
Obs.        : Chamada somente no Embarque
*/
Function AP106Frete(cPedido,cInvPag)
Local nPsBrutoEm := 0
Local nPsBrutoPe := 0
cFilEE8 := xFilial("EE8")

//Calcula o Peso Bruto dos Itens do Embarque
nRec:= WORKIP->( RecNo() )
WORKIP->( dbGoTop() )
Do While !WORKIP->( EoF() )
   If WORKIP->WP_FLAG  == cMarca .AND. WORKIP->EE9_INVPAG == cInvPag
      nPsBrutoEm += WorkIp->EE9_PSBRUN * WorkIp->EE9_QTDEM1
   Endif
   WORKIP->( dbSkip() )
EndDo
WORKIP->( dbGoTo(nRec) )

//Calcula o Peso Bruto dos Itens no Pedido
EE8->( dbSetOrder(1) )
EE8->( dbSeek(cFilEE8+cPedido ) )
Do While !EE8->( EoF() ) .AND. EE8->EE8_FILIAL = cFilEE8 .AND. EE8->EE8_PEDIDO == cPedido
   If EE8->EE8_INVPAG == cInvPag
      nPsBrutoPe += EE8->EE8_PSBRUN * EE8->EE8_QTDEM1
   Endif
   EE8->( dbSkip() )
EndDo

//Retorna o calculo do frete no Embarque = ( Calculo Frete do Pedido * Peso Bruto no Embarque ) / Peso Bruto do Pedido
RETURN ( EXK->EXK_FRETE * nPsBrutoEm ) / nPsBrutoPe

/*
Funcao      : AP106FiPos()
Parametros  : cField = Campo a ser procurado
Retorno     : N - A posição do campo no array aHeaderBtB
Objetivos   : Retornar a posição do campo
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 15/09/2004 15:52
Revisao     :
Obs.        :
*/
Function AP106FiPos(cField)
RETURN aScan(aHeaderBtB,{|X| X[2] == cField})

/*
Funcao      : AP106GrvParc()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar o evento 129 no EEQ
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 20/09/2004 13:35
Revisao     :
Obs.        :
*/
Function AP106GrvParc()
Local i,nLin
Local nLastParc := 0
Local lRet := .T.

cFilEEQ:= xFilial("EEQ")
cFilSY6:= xFilial("SY6")

Begin Sequence

If !Empty(M->EEC_DTEMBA)

   //Grava todas as invoices a pagar
   For nLin:= 1 to Len(aColsBtB)
      SY6->( dbSetOrder(1) )
      SY6->( dbSeek( cFilSY6+AVKey(aColsBtB[nLin][AP106FiPos("EXK_CONDPA")],"Y6_COD")+STR(aColsBtB[nLin][AP106FiPos("EXK_DIASPA")],3,0) ) )

      //Busca a ultima parcela gravada para esse processo
      //Parcela não pode se repetir para o mesmo processo mesmo em evento diferente
      EEQ->( dbSetOrder(1) )
      EEQ->( dbSeek(cFilEEQ+M->EEC_PREEMB) )
      DO While !EEQ->( EoF() ) .AND. EEQ->EEQ_FILIAL == cFilEEQ .AND. EEQ->EEQ_PREEMB == M->EEC_PREEMB
         nLastParc := iIF( VAL(EEQ->EEQ_PARC) > nLastParc, VAL(EEQ->EEQ_PARC),nLastParc )
         EEQ->( dbSkip() )
      EndDo

      //Caso não tenha encontra o processo no EEQ, não grava o evento do back to back
      //OSSME-5747 RNLP - não pode abortar a gravação caso não encontre o processo EEQ - Será gravado o câmbio a pagar da invoice quando a condição de pagto da invoice for Com cobertura cambial
      /*
      If nLastParc == 0 .and. (ValType(cTipoProc) == "C" .and. cTipoProc == PC_BN) //.And. !MsgYesNo(STR0071) //"Não foi encontrada Parcela de câmbio a Receber do Processo de Exportação. Deseja prosseguir com a inclusão da parcela de câmbio a pagar da invoice Back to Back? Caso responda não, o processo será gravado e a parcela não será gerada"
         Break //OSSME-5747 - RNLP - uso do break para que saia do sequence caso não seja necessário gerar parcela a pagar da invoice
      Endif
      */

      If SY6->Y6_MDPGEXP <> "006"
         If SY6->Y6_TIPO == "1"
            //Pagamento Normal

            //Posiciona na parcela do EEQ e retorna a parcela do pagamento do Back To Back
            //Retorna 00 caso não encontre
            cParcEEQ := AP106ParcBtB("01",;
                                    M->EEC_PREEMB,;
                                    aColsBtB[nLin][AP106FiPos("EXK_FORN")  ],;
                                    aColsBtB[nLin][AP106FiPos("EXK_LOJA")  ],;
                                    aColsBtB[nLin][AP106FiPos("EXK_INVOIC")])

            
            RecLock("EEQ",cParcEEQ == "00")

            EEQ->EEQ_FILIAL := cFilEEQ
            EEQ->EEQ_PREEMB := M->EEC_PREEMB
            EEQ->EEQ_FORN   := aColsBtB[nLin][AP106FiPos("EXK_FORN")]
            EEQ->EEQ_FOLOJA := aColsBtB[nLin][AP106FiPos("EXK_LOJA")]
            EEQ->EEQ_IMPORT := M->EEC_IMPORT
            EEQ->EEQ_IMLOJA := M->EEC_IMLOJA
            EEQ->EEQ_EVENT  := '129'
            EEQ->EEQ_NRINVO := aColsBtB[nLin][AP106FiPos("EXK_INVOIC")]

            If cParcEEQ == "00"
               EEQ->EEQ_PARC   := StrZero( nLastParc + 1, 2 )
            Endif

            EEQ->EEQ_VCT    := aColsBtB[nLin][AP106FiPos("EXK_DTEMBA")] + ( SY6->Y6_DIAS_PA )
            EEQ->EEQ_VL     := aColsBtB[nLin][AP106FiPos("EXK_VLINV" )]

            cMoedaPag       := aColsBtB[nLin][AP106FiPos("EXK_MOEINV")]

            EEQ->EEQ_VL += converte(aColsBtB[nLin][AP106FiPos("EXK_FRETE")], aColsBtB[nLin][AP106FiPos("EXK_MOEFRE")], cMoedaPag)
            EEQ->EEQ_VL += converte(aColsBtB[nLin][AP106FiPos("EXK_SEGURO")], aColsBtB[nLin][AP106FiPos("EXK_MOESEG")], cMoedaPag)


            EEQ->EEQ_MOEDA  := cMoedaPag
            EEQ->EEQ_EQVL   := EEQ->EEQ_VL * iIF(cMoedaPag <> "R$ ",BuscaTaxa(cMoedaPag,dDataBase),1)
            EEQ->EEQ_FORN   := aColsBtB[nLin][AP106FiPos("EXK_FORN"  )]
            EEQ->EEQ_FOLOJA := aColsBtB[nLin][AP106FiPos("EXK_LOJA"  )]
            EEQ->EEQ_IMPORT := M->EEC_IMPORT
            EEQ->EEQ_IMLOJA := M->EEC_IMLOJA
            EEQ->EEQ_FASE   := OC_EM
            EEQ->EEQ_TIPO   := "P" //Cambio a Pagar

            //AAF 22/10/04 - Adicionado gravação do campo EEQ_PARI ( ( Valor na Moeda * Taxa da Moeda ) / Taxa da Moeda do Processo ) / Valor na Moeda
            EEQ->EEQ_PARI   := ( ( EEQ->EEQ_VL * iIF(cMoedaPag <> "R$ ",BuscaTaxa(cMoedaPag,dDataBase),1) );
                                 / iIF(M->EEC_MOEDA <> "R$ ",BuscaTaxa(M->EEC_MOEDA,dDataBase),1)         );
                                 / EEQ->EEQ_VL

            //RMD - 25/11/08 - Todas as parcelas geradas pela exportação devem conter o identificador "1 - Cambio de Exportação" no campo EEQ_TP_CON
            If EEQ->(FieldPos("EEQ_TP_CON")) > 0
               EEQ->EEQ_TP_CON := "1"
            EndIf

            //THTS - 06/04/2017 - Grava o campo de versão do adapter a ser utilizado quando integrado ao Logix.
            EEQ->EEQ_EMISSAO := M->EEC_DTEMBA
            If EEQ->EEQ_TIPO != "R" .And. AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0
               EEQ->EEQ_EAIVRS := "2"
            ElseIf EEQ->(FieldPos("EEQ_EAIVRS")) > 0
               EEQ->EEQ_EAIVRS := "1"
            EndIf

            EEQ->( MsUnLock() )

            //DFS - 14/12/10 - Inclusão de tratamento para gerar titulo no financeiro na operação back to back
            If /*IsIntEnable("001") .And. */cParcEEQ == "00"
               If !(lRet := AvStAction("010"))
                  lRollBack:= .T.
                  Break
               Endif
            Endif

         ElseIf SY6->Y6_TIPO == "2"
            //Pagamento á Vista

            //Posiciona na parcela do EEQ e retorna a parcela do pagamento do Back To Back
            //Retorna 00 caso não encontre
            cParcEEQ := AP106ParcBtB("01",;
                                    M->EEC_PREEMB,;
                                    aColsBtB[nLin][AP106FiPos("EXK_FORN")  ],;
                                    aColsBtB[nLin][AP106FiPos("EXK_LOJA")  ],;
                                    aColsBtB[nLin][AP106FiPos("EXK_INVOIC")])

            //Pagamento Normal
            RecLock("EEQ",cParcEEQ == "00")

            EEQ->EEQ_FILIAL := cFilEEQ
            EEQ->EEQ_PREEMB := M->EEC_PREEMB
            EEQ->EEQ_FORN   := aColsBtB[nLin][AP106FiPos("EXK_FORN")]
            EEQ->EEQ_FOLOJA := aColsBtB[nLin][AP106FiPos("EXK_LOJA")]
            EEQ->EEQ_IMPORT := M->EEC_IMPORT
            EEQ->EEQ_IMLOJA := M->EEC_IMLOJA
            EEQ->EEQ_EVENT  := '129'
            EEQ->EEQ_NRINVO := aColsBtB[nLin][AP106FiPos("EXK_INVOIC")]

            If cParcEEQ == "00"
               EEQ->EEQ_PARC   := StrZero( nLastParc + 1, 2 )
            Endif

            EEQ->EEQ_VCT    := aColsBtB[nLin][AP106FiPos("EXK_DTEMBA")]
            EEQ->EEQ_VL     := aColsBtB[nLin][AP106FiPos("EXK_VLINV" )]

            cMoedaPag       := aColsBtB[nLin][AP106FiPos("EXK_MOEINV")]

            EEQ->EEQ_VL += converte(aColsBtB[nLin][AP106FiPos("EXK_FRETE")], aColsBtB[nLin][AP106FiPos("EXK_MOEFRE")], cMoedaPag)
            EEQ->EEQ_VL += converte(aColsBtB[nLin][AP106FiPos("EXK_SEGURO")], aColsBtB[nLin][AP106FiPos("EXK_MOESEG")], cMoedaPag)

            EEQ->EEQ_MOEDA  := cMoedaPag
            EEQ->EEQ_EQVL   := EEQ->EEQ_VL * iIF(cMoedaPag <> "R$ ",BuscaTaxa(cMoedaPag,dDataBase),1)
            EEQ->EEQ_FORN   := aColsBtB[nLin][AP106FiPos("EXK_FORN"  )]
            EEQ->EEQ_FOLOJA := aColsBtB[nLin][AP106FiPos("EXK_LOJA"  )]
            EEQ->EEQ_IMPORT := M->EEC_IMPORT
            EEQ->EEQ_IMLOJA := M->EEC_IMLOJA
            EEQ->EEQ_FASE   := OC_EM
            EEQ->EEQ_TIPO   := "P" //Cambio a Pagar

            //AAF 22/10/04 - Adicionado gravação do campo EEQ_PARI ( ( Valor na Moeda * Taxa da Moeda ) / Taxa da Moeda do Processo ) / Valor na Moeda
            EEQ->EEQ_PARI   := ( ( EEQ->EEQ_VL * iIF(cMoedaPag <> "R$ ",BuscaTaxa(cMoedaPag,dDataBase),1) );
                                 / iIF(M->EEC_MOEDA <> "R$ ",BuscaTaxa(M->EEC_MOEDA,dDataBase),1)         );
                                 / EEQ->EEQ_VL

            //RMD - 25/11/08 - Todas as parcelas geradas pela exportação devem conter o identificador "1 - Cambio de Exportação" no campo EEQ_TP_CON
            If EEQ->(FieldPos("EEQ_TP_CON")) > 0
               EEQ->EEQ_TP_CON := "1"
            EndIf

            //THTS - 06/04/2017 - Grava o campo de versão do adapter a ser utilizado quando integrado ao Logix.
            EEQ->EEQ_EMISSAO := M->EEC_DTEMBA
            If EEQ->EEQ_TIPO != "R" .And.AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0
               EEQ->EEQ_EAIVRS := "2"
            ElseIf EEQ->(FieldPos("EEQ_EAIVRS")) > 0
               EEQ->EEQ_EAIVRS := "1"
            EndIf

            EEQ->( MsUnLock() )

            //DFS - 14/12/10 - Inclusão de tratamento para gerar titulo no financeiro na operação back to back
            If /*IsIntEnable("001") .And. */cParcEEQ == "00"
               If !(lRet := AvStAction("010") )
                  lRollBack:= .T.
                  Break
               Endif
            Endif

         ElseIf SY6->Y6_TIPO == "3"
            //Para cada parcela da condição de pagamento Parcelado
            For i:= 1 To 10

               cParc := StrZero(i,2,0)
               If SY6->&("Y6_PERC_"+cParc) > 0
                  //Gera Evento 129 no EEQ

                  //Posiciona na parcela do EEQ e retorna a parcela do pagamento do Back To Back
                  cParcEEQ := AP106ParcBtB(StrZero( Val(cParc) + i, 2 ),; //MCF - 20/07/2016
                                          M->EEC_PREEMB,;
                                          aColsBtB[nLin][AP106FiPos("EXK_FORN")  ],;
                                          aColsBtB[nLin][AP106FiPos("EXK_LOJA")  ],;
                                          aColsBtB[nLin][AP106FiPos("EXK_INVOIC")])

                  RecLock("EEQ",cParcEEQ == "00")

                  EEQ->EEQ_FILIAL := cFilEEQ
                  EEQ->EEQ_PREEMB := M->EEC_PREEMB
                  EEQ->EEQ_FORN   := aColsBtB[nLin][AP106FiPos("EXK_FORN")]
                  EEQ->EEQ_FOLOJA := aColsBtB[nLin][AP106FiPos("EXK_LOJA")]
                  EEQ->EEQ_IMPORT := M->EEC_IMPORT
                  EEQ->EEQ_IMLOJA := M->EEC_IMLOJA
                  EEQ->EEQ_EVENT  := '129'
                  EEQ->EEQ_NRINVO := aColsBtB[nLin][AP106FiPos("EXK_INVOIC")]

                  If cParcEEQ == "00"
                     EEQ->EEQ_PARC   := StrZero( nLastParc + i, 2 )
                  Endif

                  EEQ->EEQ_VCT    := aColsBtB[nLin][AP106FiPos("EXK_DTEMBA")] + ( SY6->&("Y6_DIAS_"+cParc) )
                  EEQ->EEQ_VL     := aColsBtB[nLin][AP106FiPos("EXK_VLINV" )] * ( SY6->&("Y6_PERC_"+cParc) / 100 )

                  cMoedaPag       := aColsBtB[nLin][AP106FiPos("EXK_MOEINV")]

                  EEQ->EEQ_VL += converte(aColsBtB[nLin][AP106FiPos("EXK_FRETE")], aColsBtB[nLin][AP106FiPos("EXK_MOEFRE")], cMoedaPag)
                  EEQ->EEQ_VL += converte(aColsBtB[nLin][AP106FiPos("EXK_SEGURO")], aColsBtB[nLin][AP106FiPos("EXK_MOESEG")], cMoedaPag)

                  EEQ->EEQ_MOEDA  := cMoedaPag
                  EEQ->EEQ_EQVL   := EEQ->EEQ_VL * iIF(cMoedaPag <> "R$ ",BuscaTaxa(cMoedaPag,dDataBase),1)

                  EEQ->EEQ_FORN   := aColsBtB[nLin][AP106FiPos("EXK_FORN"  )]
                  EEQ->EEQ_FOLOJA := aColsBtB[nLin][AP106FiPos("EXK_LOJA"  )]
                  EEQ->EEQ_IMPORT := M->EEC_IMPORT
                  EEQ->EEQ_IMLOJA := M->EEC_IMLOJA
                  EEQ->EEQ_FASE   := OC_EM
                  EEQ->EEQ_TIPO   := "P" //Cambio a Pagar

                  //AAF 22/10/04 - Adicionado gravação do campo EEQ_PARI ( ( Valor na Moeda * Taxa da Moeda ) / Taxa da Moeda do Processo ) / Valor na Moeda
                  EEQ->EEQ_PARI   := ( ( EEQ->EEQ_VL * iIF(cMoedaPag <> "R$ ",BuscaTaxa(cMoedaPag,dDataBase),1) );
                                       / iIF(M->EEC_MOEDA <> "R$ ",BuscaTaxa(M->EEC_MOEDA,dDataBase),1)         );
                                       / EEQ->EEQ_VL

                  //THTS - 06/04/2017 - Grava o campo de versão do adapter a ser utilizado quando integrado ao Logix.
                  EEQ->EEQ_EMISSAO := M->EEC_DTEMBA
                  If EEQ->EEQ_TIPO != "R" .And. AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0
                     EEQ->EEQ_EAIVRS := "2"
                  ElseIf EEQ->(FieldPos("EEQ_EAIVRS")) > 0
                     EEQ->EEQ_EAIVRS := "1"
                  EndIf

                  EEQ->( MsUnLock() )

                  //DFS - 14/12/10 - Inclusão de tratamento para gerar titulo no financeiro na operação back to back
                  If /*IsIntEnable("001") .And.*/ cParcEEQ == "00"
                     If !(lRet := AvStAction("010") )
                        lRollBack:= .T.
                        Break
                     Endif
                  Endif

               Else
                  Exit
               Endif
            Next
         Endif
      EndIf
   Next

Else //Empty(M->EEC_DTEMBA)
   //Apaga as Invoices a Pagar do EEQ
   EEQ->( dbSetOrder(1) )
   EEQ->( dbSeek(cFilEEQ+M->EEC_PREEMB) )
   Do While !EEQ->( EoF() ) .AND. EEQ->EEQ_FILIAL == cFilEEQ .AND. EEQ->EEQ_PREEMB == M->EEC_PREEMB
      If EEQ->EEQ_EVENT == '129'
         //If IsIntEnable("001")  //DFS - 14/12/10 - Inclusão de tratamento para excluir titulo no financeiro na operação back to back
            If !(lRet := AvStAction("012"))
               lRollBack:= .T.
               Break
            Endif
         //Endif
         EEQ->( RecLock("EEQ",.F.), dbDelete(), MsUnLock() )
      Endif
      EEQ->( dbSkip() )
   EndDo

EndIf

EEQ->( dbCommit() )

End Sequence

RETURN lRet

/*
Funcao      : AP106GrvParc()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Posicionar na parcela indicada da invoice a pagar do Back to Back
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 20/09/2004 13:35
Revisao     :
Obs.        : Esta função é necessaria para encontrar a parcela a pagar do Back to Back pois a parcela gravada no EEQ
              é sequencial. A parcela da invoice a pagar nao é gravada no EEQ.
              Exemplo: Um Embarque com condicao de pagamento parcelado em 3 parcelas com uma invoice a pagar em 2 parcelas
              EMBARQUE   - Evento - Parcela - Parcela a Pagar
              EMBARQUE01 - 101    - 01
              EMBARQUE01 - 101    - 02
              EMBARQUE01 - 101    - 03
              EMBARQUE01 - 129    - 04      - 01
              EMBARQUE01 - 129    - 05      - 02
*/
Function AP106ParcBtB(cParc, cProcesso, cForn, cLoja, cInv)
Local nParc := 0

//Procura a Parcela a condicao de pagamento da invoice a pagar
EEQ->( dbSetOrder(1) )
EEQ->( dbSeek(cFilEEQ+cProcesso) )
Do While EEQ->EEQ_FILIAL == cFilEEQ .AND. EEQ->EEQ_PREEMB == cProcesso

   If EEQ->EEQ_EVENT == '129' .AND. EEQ->EEQ_FORN == cForn;
                              .AND. EEQ->EEQ_FOLOJA == cLoja;
                              .AND. EEQ->EEQ_NRINVO == cInv
      nParc++
      If Strzero(nParc,2,0) == cParc
         Return ( Strzero(nParc,2,0) )
      Endif
   Endif

   EEQ->( dbSkip() )
EndDo

Return "00"

/*
Funcao      : AP106isBackTo(cProcesso, cFase)
Parametros  : Nenhum
Retorno     : .T./.F. - Indica se o Processo é Back to Back ou não
Objetivos   : Posicionar na parcela indicada da invoice a pagar do Back to Back
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 23/09/2004 14:00
Revisao     :
Obs.        :
*/
Function AP106isBackTo(cProcesso, cFase )
Local lRet:= .F.
Default cFase := ""

If cFase <> ""
   EXK->( dbSetOrder(1) )
   If EXK->( dbSeek(xFilial("EXK")+cFase+cProcesso) )
      lRet:= .T.
   Endif

Else
   If Len(aColsBtB) > 0
      lRet := .T.
   Endif

Endif

Return lRet

/*
Funcao      : AP106SA2F3()
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Executar Consulta de Fornecedor
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 30/09/2004 08:40
Revisao     :
Obs.        :
*/
Function AP106SA2F3()
   Local lRet := .F.
   Local oDlgF3, Tb_Campos:={}, cOldArea:= Alias()
   Local bSetF3:= SetKey(VK_F3)
   Local oSeek,cSeek,oOrdem,cOrd,aOrdem:={},nOldInd:= SA2->( IndexOrd() )
   Local nRec

   Private lInverte := .F.
   Private cMarca := GetMark()
   Private cFilSA2:= xFilial("SA2")

   Begin Sequence
      //evitar recursividade
      Set Key VK_F3 TO

      bReturn:={||GDFieldPut("EXK_FORN",SA2->A2_COD,n),GDFieldPut("EXK_FOLOJA",SA2->A2_LOJA,n),oDlgF3:End()}

      cSeek := Space(45)
      aAdd(aOrdem,STR0022+" + "+STR0024)//"Código"###"Loja"
      aAdd(aOrdem,STR0023+" + "+STR0024)//"Fornecedor"###"Loja"

      AADD(Tb_Campos,{"A2_COD" ,,STR0022}) //"Código"
      AADD(Tb_Campos,{"A2_LOJA",,STR0024}) //"Loja"
      AADD(Tb_Campos,{"A2_NOME",,STR0023}) //"Fornecedor"
      AADD(TB_CAMPOS,ColBrw("A2_END"))//Endereco
      AADD(TB_CAMPOS,ColBrw("A2_CGC"))//CGC

      dbSelectArea("SA2")
      SA2->( dbSetOrder(1) )
      SA2->( dbSetFilter({|| SA2->A2_FILIAL == cFilSA2 },"SA2->A2_FILIAL == cFilSA2") )// .AND. LEFT(SA2->A2_ID_FBFN,1)$cTIPFOR
      SA2->( dbSeek( cFilSA2 ) )
      DEFINE MSDIALOG oDlgF3 TITLE STR0023 FROM 62,15 TO 310,460 OF oMainWnd PIXEL //"Fornecedor"

         oMark:= MsSelect():New("SA2",,,TB_Campos,@lInverte,@cMarca,{10,12,80,186})
         oMark:baval:= {|| nRec:=SA2->( RecNo() ), lRet:=.T., Eval(bReturn) }

         @ 091, 14 SAY STR0025 SIZE 42,7 OF oDlgF3 PIXEL //"Pesquisar por:"
         @ 090, 59 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 119, 42 OF oDlgF3 PIXEL ON CHANGE (SEEKF3(oMARK,,oOrdem))
         @ 104, 14 SAY STR0026 SIZE 32, 7 OF oDlgF3 PIXEL //"Localizar"
         @ 104, 58 MSGET oSeek VAR cSeek SIZE 120, 10 OF oDlgF3 PIXEL
         oSeek:bChange := {|nChar|SA2->(SEEKF3(oMARK,RTrim(oSeek:oGet:Buffer)))}

         DEFINE SBUTTON FROM 10,187 TYPE 1 ACTION (Eval(oMark:baval)) ENABLE OF oDlgF3 PIXEL
         DEFINE SBUTTON FROM 25,187 TYPE 2 ACTION (oDlgF3:End()) ENABLE OF oDlgF3 PIXEL

      ACTIVATE MSDIALOG oDlgF3

   END SEQUENCE

   SA2->( dbSetOrder(nOldInd) )
   SET FILTER TO
   dbSelectArea(cOldArea)

   IF !Empty(nRec)
      SA2->( dbGoTo(nRec) )
   Endif

   SetKey(VK_F3,bSetF3)

Return lRet

/*
Funcao      : Ap106ValidInt(nTipo)
Parametros  : nTipo - Tipo de operação.
Retorno     : .T./.F.
Objetivos   : Verificar uma condição em relação a integração e Exibir Mensagem.
Autor       : Julio de Paula Paz
Data/Hora   : 29/06/2005 14:00
Revisao     :
Obs.        :
*/

Function Ap106VlIntegra(nTipo) // By JPP - 29/06/2005 - 14:00 - Esta função substitui a condição abaixo devido a estouro de define.
Local lRet := .f.

Begin Sequence
   If EasyGParam("MV_AVG0094",, .F.) .and. EE7->(FieldPos("EE7_INTEGR") > 0 .and. EE7_INTEGR = "S")
      If nTipo == INC_DET .or. nTipo == EXC_DET
         MsgStop(STR0030, STR0024) //"Não é permitida a inclusão ou exclusão de itens para este processo devida-a sua geração através da integração."###"Atenção"
         lRet := .t.
      EndIf
   EndIf
End Sequence

Return lRet
/*
Funcao      : AP106CalcDesc(nOpc,nValDesc,lRecalc)
Parametros  : nOpc     = Tipo de operação (Inclusão/Alteração)
              nValdesc = Valor de Desconto
              lRecalc  = Recalcular .t./.f.
Retorno     : Valor de desconto
Objetivos   : Calcular o valor de desconto de acordo com o calculo da integracao do faturamento.
Autor       : Julio de Paula Paz
Data/Hora   : 24/06/2005 16:15
Revisao     :
Obs.        :
*/
Function AP106CalcDesc(nOpc,nValDesc,lRecalc)
Local nTotItens := 0,  nValorInc
Local nPorcento := 0, ndesconto, nTotVlsiga := 0
Local nQtdVen, nDescAtu, nTotDesc
Local nDecDesc := AvSx3("D2_DESCON",AV_DECIMAL),nDecPrc := AvSx3("D2_PRCVEN",AV_DECIMAL)
Local nDecTot := AvSx3("D2_TOTAL",AV_DECIMAL)

Local lConvUnid := (EE7->(FieldPos("EE7_UNIDAD")) # 0) .And. (EE8->(FieldPos("EE8_UNPES")) # 0) .And.;
                   (EE8->(FieldPos("EE8_UNPRC"))  # 0)

Begin Sequence

   WORKIT->(dbGoTop())
   Do While WORKIT->(!Eof())
      If lConvUnid
         nValorInc := ROUND((AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,;
                                   WorkIt->EE8_SLDINI,.F.)*WorkIt->EE8_PRECO),nDecTot)
      Else
         nValorInc := ROUND(WORKIT->(EE8_PRECO*EE8_SLDINI),nDecTot)
      EndIf
      nTotItens += nValorInc
      WORKIT->(DbSkip())
   EndDo

   nDescAtu := M->EE7_DESCON

   If nOpc == INCLUIR
      If lRecalc
         nDescAtu := nValDesc
      ElseIf EE7->(FieldPos("EE7_DSCORG")) > 0
         If M->EE7_DSCORG <> 0
            nDescAtu := M->EE7_DSCORG
         Else
            nDescAtu := M->EE7_DESCON
         Endif
      EndIf
   ElseIf nOpc == ALTERAR
      If lRecalc
         nDescAtu := nValDesc
      ElseIf EE7->(FieldPos("EE7_DSCORG")) > 0
         nDescAtu := If(M->EE7_DSCORG = 0,M->EE7_DESCON,M->EE7_DSCORG)
      EndIf
   EndIf

   WORKIT->(dbGoTop())
   Do While WORKIT->(!Eof())
      If lConvUnid
         nQtdVen   := AvTransUnid(WORKIT->EE8_UNIDAD, WORKIT->EE8_UNPRC, WORKIT->EE8_COD_I,WORKIT->EE8_SLDINI,.F.)
         nValorInc := ROUND((AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,;
                                   WorkIt->EE8_SLDINI,.F.)*WorkIt->EE8_PRECO),nDecTot)
      Else
         nValorInc := ROUND(WORKIT->(EE8_PRECO*EE8_SLDINI),nDecTot)
         nQtdVen   := WORKIT->EE8_SLDINI
      EndIf

      //FJH 07/02/06 - Desconto por itens
      If EasyGParam("MV_AVG0119",,.F.) .and. EE8->(FieldPos("EE8_DESCON")) > 0
         nDesconto := WorkIt->EE8_DESCON
      Else
         /* wfs 07/11/2019 - implementado o uso da função FtDescItem(), que olha para outras parametrizações e regras de negócio do SIGAFAF, como o parâmetro MV_ARREDFAT*/
         nPorcento := Round(nValorInc / nTotItens, 8) // Porcentage de desconto por item
         nDesconto := Round((nPorcento * nDescAtu), 8)
         nDesconto := Round(nDesconto/nQtdVen,nDecPrc)
         nDesconto := Round(nDesconto*nQtdVen,nDecDesc) // Desconto Siga
         FtDescItem(nValorInc, nValorInc, nQtdVen, M->EE8_PRCTOT, Nil, @nDesconto, 0, 2)
      Endif

      nTotVlsiga += nDesconto
      WORKIT->(DbSkip())
   EndDo

   If M->EE7_DESCON <> nTotVlSiga .And. !lRecalc .And. !EasyGParam("MV_AVG0085",,.F.)
      nTotDesc := nTotVlsiga
      If EE7->(FieldPos("EE7_DSCORG")) > 0
         nTotDesc := AP106CalcDesc(nOpc,M->EE7_DESCON,.t.)
      EndIf
      If M->EE7_DESCON <> nTotDesc
         MSGINFO(STR0031 + Transform(M->EE7_DESCON,AvSx3("EE7_DESCON",AV_PICTURE))+ENTER+;  // "O valor de desconto informado: "
              STR0032 + Transform(nTotDesc,AvSx3("EE7_DESCON",AV_PICTURE))+ENTER+;  // "Foi alterado para o valor: "
              STR0033)  //"Devido a compatibilização dos valores na integração com a Microsiga."
      EndIf
      If EE7->(FieldPos("EE7_DSCORG")) > 0
         M->EE7_DSCORG := M->EE7_DESCON
      EndIf
      M->EE7_DESCON :=  nTotDesc // nTotVlSiga
   EndIf

End Sequence
Return nTotVlSiga
/*
Funcao      : AP106TelaNProc(lAutomatico)
Parametros  : lAutomatico = .t. - Gravação do pedido automatica. Exibir mensagens apenas no servidor
                            .f. - Gravação do pedido não automatica. Solicitar novo codigo para o processo.
Retorno     :
Objetivos   : Exibir tela para solicitar o codigo do processo ou exibir mensagem no servidor.
Autor       : Julio de Paula Paz
Data/Hora   : 05/08/2005 13:35
Revisao     :
Obs.        :
*/
Function AP106TelaNProc(lAutomatico)
Local oDlg
Local lRet := .F.
Local cPictProc := AvSx3("EE7_PEDIDO",AV_PICTURE)
Local cProc := Space(AvSx3("EE7_PEDIDO",AV_TAMANHO)), oProc,;
      bOk   := {|| If(!Empty(cProc),(M->EE7_PEDIDO:=cProc,lRet:= .t.,oDlg:End()),Nil)},;
      bCancel := {|| lRet := .F., oDlg:End()}

Begin Sequence
   If Type("lSched") == "L" .And. lSched
      EECMsg(STR0034+M->EE7_PEDIDO+STR0035) // "Gravacao do Processo '" ###"' Cancelada. Ja existe um processo com este Codigo!"
      Break
   EndIf
   If lAutomatico
      ConOut(STR0034+M->EE7_PEDIDO+STR0035) // "Gravacao do Processo '" ###"' Cancelada. Ja existe um processo com este Codigo!"
   Else
      Msginfo(STR0039+M->EE7_PEDIDO+STR0040,STR0038) //  "Processo '" ### "' já Cadastrado. Digite um novo Código para o processo!" ### "Atenção"
      Define MsDialog oDlg Title STR0036 from 10,12 to 15,60 Of oMainWnd  // "Digite o Codigo do Processo"
         @ 18,07 Say STR0037 Pixel // "Processo"
         @ 18,40 Msget oProc Var cProc Size 100,10 Picture cPictProc Pixel
      Activate MsDialog oDlg On Init Enchoicebar(oDlg,bOk,bCancel) Centered
      If ! lRet
         MsgInfo(STR0041,STR0038) // "Gravação do Processo cancelada." ### "Atenção"
      EndIf
   EndIf
End Sequence

Return lRet

/*
Funcao      : AP106VerAgCom()
Parametros  : Nenhum.
Retorno     :
Objetivos   : verifica se os campos obrigatorios dos agentes de comissão estão preenchidos
Autor       : Fabio Justo Hildebrand.
Data/Hora   : 24/08/05 17:30.
Revisao     :
Obs.        :
*/

Function AP106VerAgCom()
Local lRet:=.T., nRegAnt:= WorkAg->(RecNo())

      If EECFlags("COMISSAO") //Testa se há tratamento por comissão
         WorkAg->(DbGoTop())
         While WorkAg->(!Eof())
            IF (Empty(WorkAg->EEB_TIPCOM).or.Empty(WorkAg->EEB_TIPCVL)).and.Left(WorkAg->EEB_TIPOAG,1) == CD_AGC
               lRet := .F.
               MsgAlert(STR0042) // "Há campos obrigatórios não preenchidos nos Agentes de Comissão vinculados ao processo"
            Endif
            WorkAg->(DbSkip())
         End
      Endif

WorkAg->(dbGoTo(nRegAnt))
Return lRet

/*
Funcao      : AP106Idioma
Parametros  : cFase -> "P" (OC_PE) = Ocorrência do Pedido.
                       "Q" (OC_EM) = Ocorrência do Embarque.
Retorno     : cIdioma
Objetivos   : Gatilho para o campo Idioma, pergunta se quer mudar tb os idiomas dos itens
Autor       : Fabio Hildebrand
Data/Hora   : 14/10/05 - 10:00
*/

*---------------------------------------*
Function AP106Idioma(cFase)
*---------------------------------------*
Local nRecno     := 0
Local aSaveOrd   := SaveOrd("EE2", 1)
Local lDiferente := .F.
Local cWork
Local cTab_Itens
Local cIdioma
Local cFiltro
//MFR 13/07/2017 MTRADE-1060 WCC-520749
Local lSimNao := .T.


Begin Sequence

   Do Case

      Case cFase = OC_PE
         cTab_Itens := "EE8"
         cWork      := "WorkIt"
         cIdioma    := M->EE7_IDIOMA

      Case cFase = OC_EM
         cTab_Itens := "EE9"
         cWork      := "WorkIp"
         cIdioma    := M->EEC_IDIOMA

      Otherwise
         Break

   EndCase

   cFiltro := (cWork)->(dbFilter())
   (cWork)->(dbClearFilter())

   If IsVazio(cWork)
      Break
   Else
      nRecno := (cWork)->(Recno())
   EndIf


//MFR 13/07/2017 MTRADE-1060 WCC-520749
//Se for automático NUNCA perguntar se deseja aualizar a descricao do item
   if !(cFase = OC_PE .and. lEE7Auto)

   // Checa se existe algum item com descrição em idioma diferente do escolhido
     (cWork)->(dbGoTop())
     While (cWork)->(!Eof())

//      If cFase = OC_EM .and. Empty((cWork)->WP_FLAG)
//         (cWork)->(dbSkip())
//         Loop
//      EndIf

         If EE2->(dbSeek(xFilial()+"3*"+cIdioma+(cWork)->&(cTab_Itens+"_COD_I")))
           If (cWork)->&(cTab_Itens+"_VM_DES") <> MSMM(EE2->EE2_TEXTO, AvSX3("EE2_VM_TEX", AV_TAMANHO))
              lDiferente := .T.
           EndIf
         Else
        //If AllTrim(cIdioma) <> PORTUGUES //PORT. -PORTUGUES

        If (cFase = OC_PE .AND. cIdioma <> EE7->EE7_IDIOMA) .Or. (cFase = OC_EM .AND. cIdioma <> EEC->EEC_IDIOMA) .Or. (AllTrim(cIdioma) <> PORTUGUES)//FSY - 20/09/2013 - Condição para retornar o idioma para portugues quando não estiver cadastrada na tabela EE2
              lDiferente := .T.
           EndIf
        EndIf

        If lDiferente
           Exit
        EndIf

        (cWork)->(dbSkip())

     End
   Else
     lDiferente := .T.
   EndIf

  // se for diferente pergunta se quer alterar
   //MFR 13/07/2017 MTRADE-1060 WCC-520749
   // só pergunta se não for automático e pedido
   If lDiferente .and. !(cFase = OC_PE .and. lEE7Auto) .And. !(cFase == OC_EM .And. lAe100Auto)
      lSimNao := MsgYesNo(STR0043+Capital(AllTrim(SubStr(cIdioma, 1, At("-", cIdioma)-1)))+" ?") //"Deseja alterar também os idiomas das descrições dos itens para "
   EndIf

   //MFR 13/07/2017 MTRADE-1060 WCC-520749
   If lSimNao

      (cWork)->(dbGoTop())

      While (cWork)->(!Eof())

         If EE2->(dbSeek(xFilial()+"3*"+cIdioma+(cWork)->&(cTab_Itens+"_COD_I")))
            (cWork)->&(cTab_Itens+"_VM_DES") := MSMM(EE2->EE2_TEXTO, AvSX3("EE2_VM_TEX", AV_TAMANHO))
            (cWork)->&(cTab_Itens+"_IDIOMA") := EE2->EE2_IDIOMA
         Else
            //MFR 13/07/2017 MTRADE-1060 WCC-520749
            if !(cFase = OC_PE .and. lEE7Auto) .And. !(cFase == OC_EM .And. lAe100Auto)
              Help(" ",1,"AVG0005001") // "Idioma não encontrado, Padrão: Português","Atenção"
            Endif

            (cWork)->&(cTab_Itens+"_VM_DES") := Posicione("SB1", 1, xFilial("SB1")+(cWork)->&(cTab_Itens+"_COD_I"), "B1_DESC")
            (cWork)->&(cTab_Itens+"_IDIOMA") := PORTUGUES //PORT. -PORTUGUES
         EndIf

         (cWork)->(dbSkip())

      End

   EndIf

   If !Empty(cFiltro) // JPM - 07/03/05 - testa se havia filtro
      (cWork)->(dbSetFilter(&("{|| "+cFiltro+"}"), cFiltro))
   EndIf

   (cWork)->(dbGoTo(nRecno))
   //MFR 13/07/2017 MTRADE-1060 WCC-520749
   if !(cFase = OC_PE .and. lEE7Auto) .And. !(cFase == OC_EM .And. lAe100Auto)
     oMsSelect:oBrowse:Refresh()
   EndIf

End Sequence

RestOrd(aSaveOrd, .T.)

Return(cIdioma)

/*
Funcao      : Ap106ChkVincInv()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Validar a vinculação das invoices.
Autor       : Eduardo C. Romanini.
Data/Hora   :
*/
*------------------------*
Function Ap106ChkVincInv()
*------------------------*
Local lRet:=.t., nInc:=0, cMsg:=""

Begin Sequence

   For nInc:=1 to Len(aColsBtb)
       If aColsBtb[nInc][5] == 0
          cMsg += Alltrim(aColsBtb[nInc][3])+If(nInc<>Len(aColsBtb),", ","")
       EndIf
   Next

   If !Empty(cMsg)
      MsgInfo(STR0046 + cMsg,STR0038)//"A(s) seguinte(s) invoice(s) não foram vinculadas a Nenhum Item: "###"Atenção"
      lRet := .F.
   EndIf

End Sequence

Return lRet
/*
Função     : Ap106CompraFOB
Objetivos  : Converter contrato de exportação para Compra FOB e vice-versa
Parâmetros : Nenhum
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data-Hora  : 23/01/06 - 09:45
*/
*---------------------------------------*
Function Ap106CompraFOB(cAlias,nReg,nOpc)
*---------------------------------------*
Local lRet := .T.

Begin Sequence

   // ** Validações iniciais
   If EasyEntryPoint("EECAP106")
      lRet := ExecBlock("EECAP106",.F.,.F.,{"VAL_INI_CMPFOB"})
      If ValType(lRet) <> "L"
         lRet := .F.
      EndIf
      If !lRet
         Break
      EndIf
   EndIf
   EE9->(DbSetOrder(1))
   If EE9->(DbSeek(xFilial()+EE7->EE7_PEDIDO)) // se o contrato possuir embarque, a conversão deve ser barrada
      MsgInfo(STR0055,STR0038) //"Este processo já possui embarque(s), sendo assim não poderá ser convertido. Antes de realizar a conversão, desvincule o processo de todos os embarques em que está sendo utilizado." ### "Atenção"
      lRet := .F.
      Break
   EndIf

   EEQ->(DbSetOrder(6)) //EEQ_FILIAL+EEQ_FASE+EEQ_PREEMB+EEQ_PARC
   If EEQ->(DbSeek(xFilial()+OC_PE+EE7->EE7_PEDIDO))
      MsgInfo(StrTran(STR0051,"###"," "),STR0038) //"Este processo###possui adiantamentos vinculados. Antes de realizar a conversão, desvincule os adiantamentos." ### "Atenção"
      lRet := .F.
      Break
   EndIf

   If aRotina[nOpc][4] = 10     // Contr. Exp. -> Compra FOB
      If EEQ->(DbSeek(cFilBr+OC_PE+EE7->EE7_PEDIDO))
         MsgInfo(StrTran(STR0051,"###"," "+STR0052+" "),STR0038) //"Este processo###possui adiantamentos vinculados. Antes de realizar a conversão, desvincule os adiantamentos." ### "(na filial Brasil)" ### "Atenção"
         lRet := .F.
         Break
      EndIf

      If lCommodity
         EE8->(DbSetOrder(1))
         EE8->(DbSeek(cFilBr+EE7->EE7_PEDIDO))
         While EE8->(!EoF() .And. EE8->(EE8_FILIAL+EE8_PEDIDO) == cFilBr+EE7->EE7_PEDIDO)
            If !Empty(EE8->EE8_RV)
               MsgInfo(STR0053,STR0038) //"Este processo está vinculado a R.V.'s na filial Brasil. Antes de realizar a conversão, faça a desvinculação das R.V.'s." ### "Atenção"
               lRet := .F.
               Break
            EndIf
            EE8->(DbSkip())
         EndDo

      EndIf

      If EECFlags("AMOSTRA")
         EXU->(DbSetOrder(2))
         If EXU->(DbSeek(cFilBr+EE7->EE7_PEDIDO))
            MsgInfo(STR0054,STR0038) //"Este processo possui amostra na filial Brasil. Desta forma, não poderá ser convertido." ### "Atenção"
            lRet := .F.
            Break
         EndIf
      EndIf

   EndIf

   If aRotina[nOpc][4] = 10     // Contr. Exp. -> Compra FOB
      If EE7->EE7_CPRFOB
         MsgInfo(STR0056,STR0038) //"Este processo já foi convertido para compra FOB." ### "Atenção"
         lRet := .F.
         Break
      EndIf

      lRet := CompraFOB(cAlias,nReg,nOpc)

   ElseIf aRotina[nOpc][4] = 11 // Compra FOB -> Contr. Exp.
      If ! EE7->EE7_CPRFOB
         MsgInfo(STR0057,STR0038) //"Este processo não é referente a 'Compra FOB', portanto a conversão não poderá ser realizada." ### "Atenção"
         lRet := .F.
         Break
      EndIf

      lRet := ContratoExp(cAlias,nReg,nOpc)

   EndIf

End Sequence

Return lRet

/*
Função     : CompraFOB
Objetivos  : Converter contrato de exportação para compra FOB
Parâmetros : Nenhum
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data-Hora  : 23/01/06 - 15:00
*/
*-----------------------------------------*
Static Function CompraFOB(cAlias,nReg,nOpc)
*-----------------------------------------*
Local lRet := .t., nRec := EE7->(RecNo())
Private lCompraFOB := .T.

Begin Sequence

   If Ap100Man(cAlias,nReg,ALTERAR)
      EE7->(DbSetOrder(1))
      EE7->(DbSeek(cFilBr+EE7->EE7_PEDIDO))
      //RMD - 27/04/06 - Transfere as amostras da filial exterior para a filial Brasil
      ConvAmostra("FOB", EE7->EE7_PEDIDO)
      Ap100DelPed()
      lRet := .T.
      MsgInfo(STR0048,STR0038) //"Conversão realizada com sucesso." ### "Atenção"
   Else
      lRet := .F.
      Break
   EndIf

End Sequence
EE7->(DbGoTo(nRec))

Return Nil

/*
Função     : ConvAmostra
Objetivos  : Transferir as amostras de um pedido para a filial oposta na conversão de contrato
Parâmetros : cTipo -> Tipo de conversão
             cPedido -> Número do pedido
Retorno    : Nil
Autor      : Rodrigo Mendes Diaz
Data-Hora  : 27/04/06
*/
*-----------------------------------------*
Static Function ConvAmostra(cTipo, cPedido)
*-----------------------------------------*
Local aOrd := SaveOrd({"EXU", "EXV"})
Local cFilAnt, cFilAtu
Default cPedido := ""

Begin Sequence
   If cTipo == "FOB"
      cFilAnt := cFilbr
      cFilAtu := cFilEx
   ElseIf cTipo == "CONTRATO"
      cFilAnt := cFilEx
      cFilAtu := cFilBr
   Else
      Break
   EndIf
   EXU->(DbSetOrder(2))
   EXV->(DbSetOrder(1))
   While EXU->(DbSeek(cFilAnt+cPedido))//EXU->(!Eof() .And. EXU_FILIAL == cFilAnt .And. EXU_PEDIDO == cPedido)
      While EXV->(DbSeek(cFilAnt+EXU->EXU_NROAMO))//EXV->(!Eof() .And. EXV_FILIAL == cFilAnt .And. EXV_NROAMO == EXU->EXU_NROAMO)
         EXV->(RecLock("EXV", .F.))
         EXV->EXV_FILIAL := cFilAtu
         EXV->(MsUnlock())
         EXV->(DbSkip())
      EndDo
      EXU->(RecLock("EXU", .F.))
      EXU->EXU_FILIAL := cFilAtu
      EXU->(MsUnlock())
      EXU->(DbSkip())
   EndDo

End Sequence
RestOrd(aOrd, .T.)

Return Nil

/*
Função     : ContratoExp
Objetivos  : Converter compra FOB para contrato de exportação normal
Parâmetros : Nenhum
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data-Hora  : 14/01/06
*/
*-------------------------------------------*
Static Function ContratoExp(cAlias,nReg,nOpc)
*-------------------------------------------*
Local nLinha1 := 6,nLinha2 := 6, nColuna := 6, nInc := 38, n := 14
Local lRet := .F., cFilBackup := cFilAnt

Private M->EE7_FORN := CriaVar("EE7_FORN") , M->EE7_FOLOJA := CriaVar("EE7_FOLOJA") , M->EE7_FORNDE := CriaVar("EE7_FORNDE")
Private M->EE7_IMPORT := CriaVar("EE7_IMPORT") , M->EE7_IMLOJA  := CriaVar("EE7_IMLOJA") , M->EE7_IMPODE := CriaVar("EE7_IMPODE")

Begin Sequence

   cFilAnt := cFilBr

   Define MsDialog oDlg Title STR0047 FROM 1,1 To 160,340 STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd Pixel //"Informe os dados da Filial Brasil:"

      oDlg:lEscClose := .F.
      AvBorda(oDlg)

      @ nLinha1+=n,nColuna      Say AvSx3("EE7_FORN",AV_TITULO) Pixel COLOR CLR_HBLUE
      @ nLinha2+=n,nColuna+nInc MsGet M->EE7_FORN Size 37,7 Pixel Picture AvSx3("EE7_FORN",AV_PICTURE);
                                F3 AvSx3("EE7_FORN",8) Valid (Vazio() .Or. ExistCpo("SA2",M->EE7_FORN) );
                                ON CHANGE (M->EE7_FOLOJA := Posicione("SA2",1,xFilial("SA2")+M->EE7_FORN,"A2_LOJA"),;
                                           M->EE7_FORNDE := SA2->A2_NOME )

      @ nLinha1 ,nColuna+2*nInc+20 Say AvSx3("EE7_FOLOJA",AV_TITULO) Pixel COLOR CLR_HBLUE
      @ nLinha2 ,nColuna+3*nInc+15 MsGet M->EE7_FOLOJA Size 10,7 Pixel Picture AvSx3("EE7_FOLOJA",AV_PICTURE);
                                   Valid (Vazio() .Or. ExistCpo("SA2",M->EE7_FORN+M->EE7_FOLOJA) );
                                   ON CHANGE (M->EE7_FORNDE := Posicione("SA2",1,xFilial("SA2")+M->EE7_FORN+M->EE7_FOLOJA,"A2_NOME"))

      @ nLinha1+=n,nColuna      Say AvSx3("EE7_FORNDE",AV_TITULO) Pixel
      @ nLinha2+=n,nColuna+nInc MsGet M->EE7_FORNDE Size 120,7 Pixel Picture AvSx3("EE7_FORNDE",AV_PICTURE) When .f. Valid .t.

      @ nLinha1+=n,nColuna      Say AvSx3("EE7_IMPORT",AV_TITULO) Pixel COLOR CLR_HBLUE
      @ nLinha2+=n,nColuna+nInc MsGet M->EE7_IMPORT Size 37,7 Pixel Picture AvSx3("EE7_IMPORT",AV_PICTURE);
                                F3 AvSx3("EE7_IMPORT",8) Valid (Vazio() .Or. ExistCpo("SA1",M->EE7_IMPORT) );
                                ON CHANGE (M->EE7_IMLOJA := Posicione("SA1",1,xFilial("SA1")+M->EE7_IMPORT,"A1_LOJA"),;
                                           M->EE7_IMPODE := SA1->A1_NOME )

      @ nLinha1,nColuna+2*nInc+20  Say AvSx3("EE7_IMLOJA",AV_TITULO) Pixel COLOR CLR_HBLUE
      @ nLinha2,nColuna+3*nInc+15  MsGet M->EE7_IMLOJA Size 10,7 Pixel Picture AvSx3("EE7_IMLOJA",AV_PICTURE);
                                   Valid (Vazio() .Or. ExistCpo("SA1",M->EE7_IMPORT+M->EE7_IMLOJA) );
                                   ON CHANGE (M->EE7_IMPODE := Posicione("SA1",1,xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA,"A1_NOME"))

      @ nLinha1+=n,nColuna      Say AvSx3("EE7_IMPODE",AV_TITULO) Pixel
      @ nLinha2+=n,nColuna+nInc MsGet M->EE7_IMPODE Size 120,7 Pixel Picture AvSx3("EE7_IMPODE",AV_PICTURE) When .f. Valid .t.

      bOk     := {|| If(ValTelaFob(),(lRet := .t.,oDlg:End()),Nil)  }
      bCancel := {|| lRet := .F., oDlg:End() }

   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) Centered

   cFilAnt := cFilBackup

   If !lRet
      Break
   EndIf

   Private cForn := M->EE7_FORN , cFoLoja := M->EE7_FOLOJA , cFoDesc := M->EE7_FORNDE
   Private cImport := M->EE7_IMPORT , cImLoja  := M->EE7_IMLOJA , cImDesc := M->EE7_IMPODE

   Processa({||Ap106GerPed()})

   MsgInfo(STR0048,STR0038) //"Conversão realizada com sucesso." ### "Atenção"

End Sequence

Return lRet

/*
Função     : ValTelaFob()
Objetivos  : Validar tela de conversão de compra Fob para pedido normal.
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 30/01/06 - 16:56
*/

Static Function ValTelaFob()
Local lRet := .T., i
Local aVars := {"EE7_FORN","EE7_FOLOJA","EE7_IMPORT","EE7_IMLOJA"}
Begin Sequence
   For i := 1 To Len(aVars)
      If Empty(M->&(aVars[i]))
         MsgInfo(STR0050,STR0038) //"Preencha todos os campos." ### "Atenção"
         lRet := .F.
         Break
      EndIf
   Next
End Sequence

Return lRet

/*
Função     : Ap106GerPed()
Objetivos  : Gerar pedido na filial Brasil com dados da Off-Shore
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 24/01/06 - 09:40
*/
*---------------------------*
Static Function AP106GerPed()
*---------------------------*

Local lRet := .T., aOrd := SaveOrd({"EE7","EE8","EE9"}),;
      i:=0,nRec:=0,nRecEE7:=0, cCmp:=""

Local aCmpNotCopy :={}, cFilBackup

Begin Sequence

   ProcRegua(5)

   nRecEE7:=EE7->(RecNo())

   // ** limpa campos referentes a Compra FOB no pedido exterior
   EE7->(RecLock("EE7",.F.))
   EE7->EE7_CPRFOB := .F.
   EE7->EE7_SHIPPE := ""
   EE7->EE7_SHLOJA := ""
   EE7->(MsUnlock())

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(cFilEx+EE7->EE7_PEDIDO))
   While EE8->(!EoF()) .And. EE8->(EE8_FILIAL+EE8_PEDIDO) == (cFilEx+EE7->EE7_PEDIDO)
      EE8->(RecLock("EE8",.F.))
      EE8->EE8_PRCCOM := 0
      EE8->EE8_UNPRCC := ""
      EE8->(MsUnlock())
      EE8->(DbSkip())
   EndDo
   // **

   // ** Carrega dados do pedido na memória
   For i := 1 TO EE7->(FCount())
      M->&(EE7->(FieldName(i))) := EE7->(FieldGet(i))
   Next

   M->EE7_FILIAL := cFilBr
   M->EE7_OBS    := EE7->(MSMM(EE7_CODMEM,TAMSX3("EE7_OBS")[1],,,LERMEMO))
   M->EE7_MARCAC := EE7->(MSMM(EE7_CODMAR,TAMSX3("EE7_MARCAC")[1],,,LERMEMO))
   M->EE7_OBSPED := EE7->(MSMM(EE7_CODOBP,TAMSX3("EE7_OBSPED")[1],,,LERMEMO))
   M->EE7_GENERI := EE7->(MSMM(EE7_DSCGEN,TAMSX3("EE7_GENERI")[1],,,LERMEMO))

   M->EE7_CLIENT := M->EE7_IMPORT
   M->EE7_CLLOJA := M->EE7_IMLOJA

   M->EE7_IMPORT := cImport
   M->EE7_IMLOJA := cImLoja
   M->EE7_IMPODE := cImDesc
   M->EE7_ENDIMP := EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,,1)
   M->EE7_END2IM := EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,,2)

   M->EE7_EXPORT := M->EE7_FORN
   M->EE7_EXLOJA := M->EE7_FOLOJA

   M->EE7_FORN   := cForn
   M->EE7_FOLOJA := cFoLoja

   M->EE7_INTERM := "1"
   M->EE7_LC_NUM := ""

   cFilBackup := cFilAnt
   cFilAnt    := cFilBr
   SY6->(DBSETORDER(1))
   SY6->(DBSEEK(XFILIAL("SY6")+M->EE7_CONDPA+STR(M->EE7_DIASPA,3,0)))
   M->EE7_COND2  := M->EE7_CONDPA
   M->EE7_DIAS2  := M->EE7_DIASPA
   M->EE7_MPGEXP := SY6->Y6_MDPGEXP
   M->EE7_INCO2  := M->EE7_INCOTE
   M->EE7_PERC   := 0

   cFilAnt := cFilBackup

   IncProc()

   // ** Define campos que não serão copiados da filial de off-shore nos itens
   aCmpNotCopy := {"EE8_DTFIX ", "EE8_ORIGEM", "EE8_QTDLOT",;
                   "EE8_STFIX ", "EE8_ORIGV ", "EE8_DTCOTA",;
                   "EE8_DIFERE", "EE8_MESFIX"}

   If EECFlags("COMMODITY")
      AAdd(aCmpNotCopy,"EE8_RV    ")
      AAdd(aCmpNotCopy,"EE8_DTRV  ")
      AAdd(aCmpNotCopy,"EE8_DTVCRV")
      AAdd(aCmpNotCopy,"EE8_SEQ_RV")
   EndIf

   // ** Grava os itens ...
   WorkIt->(AvZap())

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(cFilEx+M->EE7_PEDIDO))

   While EE8->(!Eof()) .AND. EE8->EE8_FILIAL == cFilEx .AND. EE8->EE8_PEDIDO == M->EE7_PEDIDO
      nRec := EE8->(RecNo())

      For i := 1 To EE8->(FCount())
         cCmp := EE8->(FieldName(i))
         If aScan(aCmpNotCopy,cCmp) = 0
            M->&(cCmp) := EE8->(FieldGet(i))
         EndIf
      Next

      M->EE8_PRENEG := M->EE8_PRECO

      If EE8->(FieldPos("EE8_UNPRNG")) > 0
         M->EE8_UNPRNG := M->EE8_UNPRC
      EndIf

      If EECFlags("CAFE")
         Ap104GatPreco("EE8_PRECO",.T.,"M")
      EndIf

      M->EE8_DIFE2 := EE8->EE8_DIFERE

      For i:=1 To Len(aMemoItem)
         If EE8->(FieldPos(aMemoItem[i][1])) > 0
            M->&(aMemoItem[i][2]) := MSMM(EE8->&(aMemoItem[i][1]),TAMSX3(aMemoItem[i][2])[1],,,LERMEMO)
         EndIf
      Next i

      If WorkIt->(RecLock("WorkIt", .T.))
         AvReplace("M","WorkIt")
         WorkIt->(MsUnlock())
      Endif
      EE8->(Dbgoto(nRec))
      EE8->(DbSkip())
   EndDo

   IncProc()

   // Grava tarefas padrao do cliente
   IF Select("WorkDoc") > 0
      aDocDeletados := {}
      WorkDoc->(AvZap())
      AddTarefa(Posicione("SA1",1,cFilBr+M->EE7_IMPORT+M->EE7_IMLOJA,"A1_PAIS"),M->EE7_IMPORT+M->EE7_IMLOJA)
      Ap100DocGrava(.f.,OC_PE,cFilBr)
   Endif

   // Grava as despesas
   AP100DadosPed("EET",cFilBr)
   // Grava as empresas
   AP100DadosPed("EEB",cFilBr)
   // Grava os bancos
   AP100DadosPed("EEJ",cFilBr)
   // Grava notifys
   AP100DadosPed("EEN",cFilBr)
   //RMD - 27/04/06 - Transfere as amostras da filial exterior para a filial Brasil
   ConvAmostra("CONTRATO", M->EE7_PEDIDO)

   IncProc()

   Ap100PrecoI(.t.)  // Recalcula Precos

   IncProc()

   // ** Grava os itens
   WorkIt->(DbGotop())
   While !WorkIt->(Eof())
      If EE8->(RecLock("EE8",.T.))
         AVReplace("WorkIt","EE8")

         EE8->EE8_FILIAL := cFilBr

         For i:=1 To Len(aMemoItem)
            If EE8->(FieldPos(aMemoItem[i][1])) > 0
               MSMM(,TAMSX3(aMemoItem[i][2])[1],,WorkIt->&(aMemoItem[i][2]),INCMEMO,,,"EE8",aMemoItem[i][1])
            EndIf
         Next i

         EE8->(MsUnlock())
      Endif
      WorkIt->(dbSkip())
   Enddo

   // ** Grava o pedido
   If EE7->(RecLock("EE7", .T.))
      AvReplace("M","EE7")
      EE7->EE7_FILIAL := cFilBr
      MSMM(,TAMSX3("EE7_OBS")[1],,M->EE7_OBS,INCMEMO,,,"EE7","EE7_CODMEM")
      MSMM(,TAMSX3("EE7_MARCAC")[1],,M->EE7_MARCAC,INCMEMO,,,"EE7","EE7_CODMAR")
      MSMM(,TAMSX3("EE7_OBSPED")[1],,M->EE7_OBSPED,INCMEMO,,,"EE7","EE7_CODOBP")
      MSMM(,TAMSX3("EE7_GENERI")[1],,M->EE7_GENERI,INCMEMO,,,"EE7","EE7_DSCGEN")
      EE7->(MsUnLock())
   Endif

   IncProc()

End Sequence

EE7->(DbGoTo(nRecEE7))

RestOrd(aOrd)

Return lRet

/*
Função     : Ap106EditPrice()
Objetivos  : Abrir tela para o usuário com MsGetDb para edição dos campos de preço de compra
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 24/01/06 - 15:45
*/
*-----------------------*
Function AP106EditPrice()
*-----------------------*
Local aAlter := {"EE8_UNPRCC","EE8_PRCCOM","EE8_DIFCPR"},;
      aCpos  := {"EE8_SEQUEN","EE8_UNPRCC","EE8_PRCCOM","EE8_DIFCPR","EE8_VM_DES"}
Local lRet := .F., aPos
Local oDlg, bOk := {|| oDlg:End(), lRet := .T. }, bCancel := {|| oDlg:End(), lRet := .F.}
Local cFileBackup := CriaTrab(,.F.)
Local nRec := WorkIt->(RecNo())

Private aHeader := EECMontaHeader(aCpos)
aHeader[5][8] := "C"
Begin Sequence

   dbSelectArea("WorkIt")
   //COPY TO (cFileBackup)
   TETempBackup(cFileBackup) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados
   WorkIt->(DbGoTop())

   Define MsDialog oDlg Title STR0049 FROM 1,1 To 25,95 STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd //"Preços de Compra"

      aPos := PosDlg(oDlg)
      oMsGetDb := MsGetDb():New(aPos[1],aPos[2],aPos[3],aPos[4],; // Posições da Tela
                                3,;                               // Tipo (Inclusão, Alt., etc.)
                                ,;                                // cLinhaOk
                                ,,.F.,;                           // Permite deleção de registros
                                aAlter,;                          // Campos que podem ser alterados
                                0,,,;                             // Nro. de Colunas que serão congeladas
                                "WorkIt",,,;                      // Work que será mostrada no Browse
                                .F.,;                             // Define se as linhas poderão ser incluídas
                                oDlg,;                            // Objeto no qual está inserida a MsGetDb
                                .T.,,;                            // Define se vai utilizar características do dicionário (gatilhos, consultas...)
                                ,)                                // Função que valida exclusão
      oMsGetDb:oBrowse:bAdd  := {||.F.} // não inclui novos itens

   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) Centered

   If !lRet
      dbSelectArea("WorkIt")
      AvZap()
      TERestBackup(cFileBackup)
   EndIf

End Sequence

WorkIt->(DbGoTo(nRec))

Return Nil

/*
Funcao      : AP106HistDet()
Objetivos   : Exibe o Histórico do Saldo do Item do Pedido
Retorno     : lRet
Autor       : Eduardo C. Romanini
Data/Hora   : 28/02/2007 - 11:27
*/
*--------------------*
Function AP106HistDet
*--------------------*
Local lRet := .T.

Local cPedido  := M->EE8_PEDIDO
Local cSequen  := M->EE8_SEQUEN
Local cSldIni  := M->EE8_SLDINI
Local cSldAtu  := M->EE8_SLDATU
Local cArqWork := ""
Local cPedFat  := ""
Local cItemPV  := ""

Local nTamCod  := 0

Local aPos    := {}
Local aSemSX3 := {}

Local bOk     := {|| oDlg:End()}
Local bCancel := {|| oDlg:End()}

Local oDlg
Local oMsSelect

Local aOrd := SaveOrd({"EE8","SD2","EE7","EE9"})

Private aCampos := {}
Private aHeader := {}

Begin Sequence

   DbSelectArea("EE8")

   If !lIntegra
      //Verifica se o Saldo já foi utilizado
      If  M->EE8_SLDINI == M->EE8_SLDATU
         lRet := .F.
         MsgInfo(STR0059,STR0038) //"Não há vinculação de Saldo para esse Item"###"Atenção"
         Break
      EndIf
   EndIf

   If !lIntEmb
      nTamCod := 20
   Else
      nTamCod := 40
   EndIf

   aSemSX3 := {{"WK_TIPO"    ,"C",30,0},;
               {"WK_COD"     ,"C",nTamCod,0},;
               {"WK_QTDVINC" ,"N",AVSX3("EE8_SLDATU",AV_TAMANHO),AVSX3("EE8_SLDATU",AV_DECIMAL)}}

   //Cria a Work de Histórico
   cArqWork := E_CriaTrab(,aSemSX3,"WorkHist")

   aBrowse := {{"WK_TIPO"   ,,STR0060},; //"Tipo"
               {"WK_COD"    ,,STR0061,"@!"},; //"Referencia"
               {"WK_QTDVINC",,STR0062,AVSX3("EE8_SLDATU",AV_PICTURE)}} //"Qtde. Vinculada"

   //Verifica o Saldo Utilizado em Embarques
   EE9->(DbSetOrder(1))
   If EE9->(DbSeek(xFilial("EE9")+M->EE8_PEDIDO+M->EE8_SEQUEN))
      While EE9->(!EOF()) .and. EE9->(EE9_FILIAL + EE9_PEDIDO + EE9_SEQUEN) == xFilial("EE9")+M->EE8_PEDIDO+M->EE8_SEQUEN
         WorkHist->(DbAppend())

         WorkHist->WK_TIPO    := STR0063 //"Embarque"
         WorkHist->WK_COD     := EE9->EE9_PREEMB
         WorkHist->WK_QTDVINC := EE9->EE9_SLDINI

         If lIntEmb
            EEC->(DbSetOrder(1))
            If EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB))
               WorkHist->WK_COD  := AllTrim(EE9->EE9_PREEMB) + " - PV:" +AllTrim(EEC->EEC_PEDFAT)
            EndIf
         EndIf

         EE9->(DbSkip())
      EndDo
   EndIf

   //Verifica o Saldo Utilizado em Notas Fiscais
   If lIntegra

      cItemPV := M->EE8_FATIT

      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(xFilial("EE7")+M->EE8_PEDIDO))
         cPedFat := EE7->EE7_PEDFAT
      EndIf

      //Pesquisa a Nota Fiscal de Saída
      SD2->(DbSetOrder(8))
      If SD2->(DbSeek(xFilial("SD2")+cPedFat+cItemPV))
         While SD2->(!EOF()) .and. SD2->(D2_FILIAL + D2_PEDIDO + D2_ITEMPV) == xFilial("SD2")+cPedFat+cItemPV

            //Verifica Notas de Devolução
            If SD2->D2_QTDEDEV > 0
               WorkHist->(DbAppend())

               WorkHist->WK_TIPO    := STR0064 //"Devolução"
               WorkHist->WK_COD     := AllTrim(SD2->D2_DOC)+ " - " +AllTrim(SD2->D2_SERIE)
               WorkHist->WK_QTDVINC := SD2->D2_QTDEDEV
            EndIf

            WorkHist->(DbAppend())

            WorkHist->WK_TIPO    := STR0065 //"Faturado"
            WorkHist->WK_COD     := AllTrim(SD2->D2_DOC)+ " - " +AllTrim(SD2->D2_SERIE)
            WorkHist->WK_QTDVINC := SD2->D2_QUANT

            SD2->(DbSkip())
         EndDo
      EndIf
   EndIf

   //Posiciona a Work no Primeiro Registro
   WorkHist->(DbGoTop())

   //Verifica se a Work está vazia
   If WorkHist->(EOF()) .or. WorkHist->(BOF())
      lRet := .F.
      Break
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0066 FROM 257,303 TO 545,796 PIXEL //"Histórico de Saldo"

	@ 021,008 Say STR0067   Size 021,008 PIXEL OF oDlg //"Pedido:"
	@ 021,044 MsGet cPedido Size 2.5 * AVSX3("EE8_PEDIDO",AV_TAMANHO),009 Picture AVSX3("EE8_PEDIDO",AV_PICTURE) When .F. PIXEL OF oDlg

    @ 021,132 Say STR0068   Size 029,008 PIXEL OF oDlg //"Sequencia:"
	@ 020,168 MsGet cSequen Size 006,009 When .F. PIXEL OF oDlg

    @ 037,009 Say STR0069   Size 030,008 PIXEL OF oDlg //"Saldo inicial"
	@ 036,044 MsGet cSldIni Size 4.5 * AVSX3("EE8_SLDINI",AV_TAMANHO),009 Picture AVSX3("EE8_SLDINI",AV_PICTURE) When .F. PIXEL OF oDlg

	@ 036,132 Say STR0070   Size 029,008 PIXEL OF oDlg //"Saldo Atual"
	@ 036,168 MsGet cSldAtu Size 4.5 * AVSX3("EE8_SLDATU",AV_TAMANHO),009 Picture AVSX3("EE8_SLDATU",AV_PICTURE) When .F. PIXEL OF oDlg

    aPos := PosDlgDown(oDlg)

	oMsSelect := MsSelect():New("WorkHist",,,aBrowse,,,aPos)

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) CENTERED

End Sequence

If Select("WorkHist") > 0
   WorkHist->(E_EraseArq(cArqWork))
EndIf

RestOrd(aOrd)

Return lRet


/*
Função     : converte()
Objetivos  : Converter um valor de uma moeda para o valor de uma outra moeda
Parâmetros : nValor    - Valor a ser convertido
             cMoedaDe - Moeda original do valor
             cMoedaPara    - Moeda para que o valor será convertido
*/
*-----------------------*
static Function converte(nValor,cMoedaDe, cMoedaPara)
*-----------------------*

Local nTaxaDe
Local nTaxaPara
Local nParidade
Local nValorConv

if Empty(cMoedaDe) .or. Empty(cMoedaPara)
   if Empty(nValor)
	   nValorConv := 0
   else
      nValorConv := nValor
   endif

else

   nTaxaDe := BuscaTaxa(cMoedaDe,dDataBase)
   nTaxaPara := BuscaTaxa(cMoedaPara,dDataBase)

   nParidade := nTaxaPara / nTaxaDe

   nValorConv := nValor * nParidade

endif

return nValorConv



*----------------------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAP106                                                               *
*----------------------------------------------------------------------------------------*

