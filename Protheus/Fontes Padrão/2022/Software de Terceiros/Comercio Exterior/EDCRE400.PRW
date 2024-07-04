#include "AVERAGE.CH"
#include "EDCRE400.ch"

/*
Função   :EDCRE400()
Autor    :Igor de Araújo Chiba
Data     :03/04/2009
Objetivo :Função principal, mbrowse para exibir os registros de RE externo
Revisão  :Alessandro Alves Ferreira em 23/04/09
*/
*--------------------------------------------------------------------------------------*
//Function EDCRE400()
Function EDCRE400(aCabx , lPrevia , lInclui , nOpcao) // BAK - Tratamento para rotina de ExecAuto
*--------------------------------------------------------------------------------------*
//FSM - 03/10/2011 - Variaveis de filtro:
Local lTemFiltro := .F.
Local cFilter := ""
Local nPosRE := 0
Local nPosPed := 0
Local nPosPos := 0
Local lRet := .T.
Default lPrevia := .F.
Default nOpcao := 3

Private cCadastro := STR0001//"Manutencao de RE externo"
Private aRotina   := MenuDef()
                     /*{{STR0002,"AxPesqui"  ,0,1},;//"Pesquisar"
                      {STR0003,"RE400Manut",0,2},; //"Visualizar"
                      {STR0004,"RE400Manut",0,3},;//"Incluir"
                      {STR0005,"RE400Manut",0,4},;//"Alterar"
                      {STR0006,"RE400Manut",0,5},;//"Excluir"
                      {STR0007,"RE400Compr",0,6}}//"Comp.Ato.Concess"
                   //   {STR0007,"RE400Compr",0,4}}//"Comp.Ato.Concess"*/
Private cOrigem   := "EDCRE400"
Private cFilSA2Aux:= xFilial("SA2")
Private lAbriuSA2 := AbreArqExp("SA2",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))),cFilSA2Aux) // Abre arq. SA2 de outra Empresa/Filial de acordo com os parametros.

Private aColunas   := {{AvSx3("ED9_EXPORT",AV_TITULO),"ED9_EXPORT"}, {AvSx3("ED9_RE",AV_TITULO),"ED9_RE"},;
                       {AvSx3("ED9_DTRE",AV_TITULO)  ,"ED9_DTRE"}  , {AvSx3("ED9_DTEMB" ,AV_TITULO),"ED9_DTEMB"},;
                       {AvSx3("ED9_POSICA",AV_TITULO),"ED9_POSICA"}, {AvSx3("ED9_PROD" ,AV_TITULO),"ED9_PROD"},;
                       {AvSx3("ED9_DESC",AV_TITULO)  ,"ED9_DESC"}  , {AvSx3("ED9_PESO" ,AV_TITULO),"ED9_PESO"},;
                       {AvSx3("ED9_QTD",AV_TITULO)   ,"ED9_QTD"}   , {AvSx3("ED9_QTD" ,AV_TITULO),"ED9_QTD"},;
                       {AvSx3("ED9_UM",AV_TITULO)    ,"ED9_UM"}    , {AvSx3("ED9_VL_FOB" ,AV_TITULO),"ED9_VL_FOB"},;
                       {AvSx3("ED9_MOEDA",AV_TITULO) ,"ED9_MOEDA"} , {AvSx3("ED9_VALMOE" ,AV_TITULO),"ED9_VALMOE"},;
                       {AvSx3("ED9_NF",AV_TITULO)    ,"ED9_NF"}    , {AvSx3("ED9_SERIE" ,AV_TITULO),"ED9_SERIE"},;
                       {AvSx3("ED9_EMISSA",AV_TITULO),"ED9_EMISSA"}, {AvSx3("ED9_AC" ,AV_TITULO),"ED9_AC"},;
                       {AvSx3("ED9_NCM",AV_TITULO)   ,"ED9_NCM"}   , {AvSx3("ED9_VAL_SE" ,AV_TITULO),"ED9_VAL_SE"},;
                       {AvSx3("ED9_VALCOM",AV_TITULO),"ED9_VALCOM"}, {AvSx3("ED9_VALORI" ,AV_TITULO),"ED9_VALORI"},;
                       {AvSx3("ED9_UMNCM",AV_TITULO) ,"ED9_UMNCM"} , {AvSx3("ED9_QTDNCM" ,AV_TITULO),"ED9_QTDNCM"},;
                       {AvSx3("ED9_SALISE",AV_TITULO),"ED9_SALISE"}, {AvSx3("ED9_FASEDR" ,AV_TITULO),"ED9_FASEDR"},;
                       {AvSx3("ED9_DT_INT",AV_TITULO),"ED9_DT_INT"}} //FSM - 03/10/2011


Private aCabAuto := aCabx
Private lPrevAuto := lPrevia
Private lIncAuto := lInclui
Private nOpcAuto := nOpcao
Private lReExtAuto := Type("aCabAuto") == "A" .And. Type("lIncAuto") == "L"

If !AvFlags("INDICEED9") .Or. !AvFlags("INDICEEDD")
   Return .F.
EndIf

If lAbriuSA2
   cFilSA2Aux   := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSA2Aux)),cFilSA2Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif

// BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
If (Type("lReExtAuto") == "U" .Or. lReExtAuto == .F.)

    //Verifica se a tabela já possui filtro
	lTemFiltro := !Empty( ED9->( DBFilter() ) )


	cFilter := "ED9_RE # '" + space(AVSX3("ED9_RE",AV_TAMANHO)) + "'"

	//Adiciona um novo filtro junto com que já existia
	If lTemFiltro
		cFilter := "("+ED9->(DbFilter())+") .And. ("+cFilter+")"
		ED9->(DbClearFilter())
	EndIf

	//Filtro
	If !Empty(cFilter)
		ED9->(dbSetFilter(&("{|| " + cFilter + " }"), cFilter))
	EndIf

   mBrowse(6,1,22,75,"ED9",aColunas)

Else

   nPosRE := aScan(aCabAuto,{|X| X[1] == "ED9_RE"})
   nPosPed := aScan(aCabAuto,{|X| X[1] == "ED9_PEDIDO"})
   nPosPos := aScan(aCabAuto,{|X| X[1] == "ED9_POSICA"})

   If nPosRE == 0  // Caso no cenário de Vendas para exportadores
      aAdd(aCabAuto,{"ED9_RE",AvKey("","ED9_RE"),Nil})
   EndIf

   If nPosPed == 0  // Caso no cenário de RE Externos
      aAdd(aCabAuto,{"ED9_PEDIDO",AvKey("","ED9_PEDIDO"),Nil})
   EndIf

   If nPosPos == 0 // Caso esteja sem o Campo Posicao.
      Return .F.
   EndIf

   If nOpcAuto == 6 // Rotina de comprovação do ato
      If EasySeekAuto("ED9",aCabAuto,1)
         mBrowseAuto(nOpcAuto,aCabAuto,"ED9",.F.)
      EndIf
   EndIf
EndIf

If lAbriuSA2
   FechaArqExp("SA2",.T.)
Endif

Return lRet

/*
Função   :CadEDCRE
Autor    :Igor de Araújo Chiba
Data     :03/02009
Objetivo :Manutenção de RE externos
*/
*--------------------------------------------------------------------------------------*
Function RE400Manut(cAlias,nReg,nOpc)
*--------------------------------------------------------------------------------------*
Local oDlg
Local lOk     := .F.
Local bOk     := {|| IF((nOpc == 2 .OR. OBRIGATORIO(aGets,aTela)) .And. RE400ValCp(nOpc) ,(lOk:=.T.,oDlg:End()),  )}
Local bCancel := {|| oDlg:End()}
Local nI      := 0
//AOM - 31/11/10
Local lEECEDC := EasyGParam("MV_EEC_EDC",,.F.)
Local lEICEDC := EasyGParam("MV_EIC_EDC",,.F.)
Local lED9_PEDIDO := ED9->(FieldPos("ED9_PEDIDO")) > 0

Private cFilED9     := xFilial('ED9')
Private aMostraCpos := {}
Private aAlteraCpos := {}
Private aGets[0], aTela[0][0]
Private lInclui := If (nOpc == INCLUIR,.T.,.F.) //DFS - Inclusão de variável lógica para definir se é inclusão ou não.

If ED9->(FieldPos("ED9_CODEXP")) > 0
   aAdd(aMostraCpos,"ED9_CODEXP")
   aAdd(aMostraCpos,"ED9_EXPLOJ")
   aAdd(aMostraCpos,"ED9_DESEXP")
EndIf

aAdd(aMostraCpos,"ED9_EXPORT")
aAdd(aMostraCpos,"ED9_RE")
aAdd(aMostraCpos,"ED9_POSICA")
aAdd(aMostraCpos,"ED9_DTRE")
aAdd(aMostraCpos,"ED9_DTEMB")
aAdd(aMostraCpos,"ED9_DESC")
aAdd(aMostraCpos,"ED9_PESO")
aAdd(aMostraCpos,"ED9_QTD")
aAdd(aMostraCpos,"ED9_UM")
aAdd(aMostraCpos,"ED9_VL_FOB")
aAdd(aMostraCpos,"ED9_TX_MOE")
aAdd(aMostraCpos,"ED9_VALMOE")
aAdd(aMostraCpos,"ED9_MOEDA")
aAdd(aMostraCpos,"ED9_NF")
aAdd(aMostraCpos,"ED9_SERIE")
aAdd(aMostraCpos,"ED9_EMISSA")
aAdd(aMostraCpos,"ED9_NCM")
aAdd(aMostraCpos,"ED9_PROD")
aAdd(aMostraCpos,"ED9_VAL_SE")
aAdd(aMostraCpos,"ED9_VALCOM")
aAdd(aMostraCpos,"ED9_VALORI")
aAdd(aMostraCpos,"ED9_UMNCM")
aAdd(aMostraCpos,"ED9_QTDNCM")
aAdd(aMostraCpos,"ED9_TX_USS")
aAdd(aMostraCpos,"ED9_DTAVRB")

aAlteraCpos := aClone(aMostraCpos)

aAdd(aMostraCpos,"ED9_AC")
aAdd(aMostraCpos,"ED9_SEQSIS")

IF nOpc == 3 //Incluir
   FOR nI:=1 to ED9->(FCOUNT())
      M->&(ED9->(FIELDNAME(nI) )) := Criavar(ED9->(FIELDNAME(nI)))
   NEXT
ELSEIF nOpc == 2 .OR. nOpc == 4 .OR. nOpc == 5   //outras opções exeto pesquisar
   FOR nI:=1 to ED9->(FCOUNT())
      M->&(ED9->(FIELDNAME(nI) )) := ED9->(FIELDGET(nI))
   NEXT

   IF nOpc == 5  .AND. ( !EMPTY(ED9->ED9_AC) .OR. !EMPTY(ED9->ED9_SALISE) )
      MSGINFO(STR0008)//"RE não pode ser excluído pois está vinculado a Ato Concessório."
      Return .F.
   ENDIF

   IF nOpc == 4  .AND.  !EMPTY(ED9->ED9_AC)
      MSGINFO(STR0009)//"RE não pode ser alterado pois está vinculado a Ato Concessorio."
      Return .F.
   ENDIF
ENDIF

   //oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE;//oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   OF oDlg PIXEL
      oEnch1   := MsMGet()  :New( cAlias, nReg, nOpc, , , , aMostraCpos, 	PosDlg(oDlg), aAlteraCpos, 3 )
      oEnch1:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //RRC - 17/04/2012
   ACTIVATE MSDIALOG oDlg ON INIT ENCHOICEBAR(oDlg,bOk,bCancel)//CENTERED

   IF lOk  .AND. nOpc <> 2 .AND. !InTransact()
      IF (nOpc == 3 .OR. nOpc == 4)//INCLUIR E ALTERAR
         BEGIN Transaction
            ED9->(DBSETORDER(1))
            //lInclui := !ED9->(DBSEEK(cFilED9+M->ED9_RE+M->ED9_AC+M->ED9_POSICA))
            If lED9_PEDIDO
               lInclui := !ED9->(DBSEEK(cFilED9+M->ED9_RE+M->ED9_PEDIDO+M->ED9_POSICA))
            Else
               lInclui := !ED9->(DBSEEK(cFilED9+M->ED9_RE+M->ED9_AC+M->ED9_POSICA))
            EndIf
            dbSelectArea("ED9")
            ED9->(RECLOCK('ED9',lInclui))
            ED9->ED9_FILIAL := xFilial("ED9")
            //FOR nI:=1 to ED9->(FCOUNT())
            FOR nI:=2 to ED9->(FCOUNT())//JVR - 28/04/10 - Desconsidera o Filial que ja foi gravado.
               FIELDPUT(nI,M->&(ED9->(FIELDNAME(nI))  ))
            NEXT
            ED9->(MSUNLOCK())
         END Transaction
      ELSEIF  nOpc ==  5        // Deletar
         BEGIN Transaction
            ED9->(RECLOCK('ED9',.F.))
            ED9->(DBDELETE())
            ED9->(MSUNLOCK())
         END Transaction
      ENDIF
   ElseIf lOk  .AND. nOpc <> 2
      IF (nOpc == 3 .OR. nOpc == 4)//INCLUIR E ALTERAR
         ED9->(DBSETORDER(1))
         //lInclui := !ED9->(DBSEEK(cFilED9+M->ED9_RE+M->ED9_AC+M->ED9_POSICA))
         If lED9_PEDIDO
            lInclui := !ED9->(DBSEEK(cFilED9+M->ED9_RE+M->ED9_PEDIDO+M->ED9_POSICA))
         Else
            lInclui := !ED9->(DBSEEK(cFilED9+M->ED9_RE+M->ED9_AC+M->ED9_POSICA))
         EndIf
         dbSelectArea("ED9")
         ED9->(RECLOCK('ED9',lInclui))
         ED9->ED9_FILIAL := xFilial("ED9")
         //FOR nI:=1 to ED9->(FCOUNT())
         FOR nI:=2 to ED9->(FCOUNT())//JVR - 28/04/10 - Desconsidera o Filial que ja foi gravado.
            FIELDPUT(nI,M->&(ED9->(FIELDNAME(nI))  ))
         NEXT
         ED9->(MSUNLOCK())
      ELSEIF  nOpc ==  5        // Deletar
         ED9->(RECLOCK('ED9',.F.))
         ED9->(DBDELETE())
         ED9->(MSUNLOCK())
      ENDIF
   ENDIF

   //AOM - 31/11/2010 - Mensagens obrigatória no Drawback quando há integração com EIC e EEC
   If nOpc == 3 .And. lOk
      If lEECEDC
         MsgInfo(STR0030)//"A integração dos módulos Easy Export Control e Easy Drawback Control está habilitada, portanto a rotina só deve ser utilazada para os RE`s que não estão registrados no módulo de Exportação."
      EndIf

      If lEICEDC
         MsgInfo(STR0031)//"A integração dos módulos Easy Import Control e Easy Drawback Control está habilitada, portanto a rotina só deve ser utilazada para os RE`s que não estão registrados no módulo de Importação."
      EndIf
   EndIf

Return .T.

/*
Função   :ValidED9()
Autor    :Igor de Araújo Chiba
Data     :03/02009
Objetivo :Validar campos do ED9
*/
*--------------------------------------------------------------------------------------*
Function RE400ValidED9()
*--------------------------------------------------------------------------------------*
Local cVar := READVAR()
Local lRet := .T.

//FSM - 27/09/2011
If Type("lVendasExp") == "L" .And. lVendasExp == .T.
   lInclui := INCLUI
EndIf


IF Type("cOrigem") == "C" .And. cOrigem # "EDCRE400" //FSM - 27/09/2011
   RETURN .T.
ENDIF

DO CASE
   CASE cVar == 'M->ED9_QTD'
      If !lInclui //DFS - 19/04/2011 - Variável para utilizar a validação apenas quando não for inclusão.
         IF ED9->ED9_SALISE < ED9->ED9_QTD - M->ED9_QTD //(M->ED9_QTD - ED9->ED9_QTD)
            nTam:= AVSX3('ED9_QTD',AV_TAMANHO)//serve tambem para o campo ED9_SALISE
            nDec:= AVSX3('ED9_QTD',AV_DECIMAL)//serve tambem para o campo ED9_SALISE
            //Alert("Quantidade anterior: "+ALLTRIM(STR(ED9->ED9_QTD,nTam,nDec))+" subtraido da quantidade atual nao pode ser maior que o Saldo da Insencao: "+ALLTRIM(STR(ED9->ED9_SALISE,nTam,nDec)))
            MsgStop(STR0010)//"Quantidade insuficiente para comprovação dos Ato Concessórios Isenção ao qual este RE está vinculado."
            lRet := .F.
         ENDIF
      ENDIF
   CASE cVar == 'M->ED9_SEQSIS'
      IF !EMPTY(M->ED9_AC)
         MsgStop(STR0011)//"Sequencia siscomex nao pode ser alterada se o ato concessorio estiver preenchido"
         lRet:=.F.
      ENDIF
ENDCASE

Return lRet

/*
Função   :RE400Compr()
Autor    :Igor de Araújo Chiba
Data     :03/02009
Objetivo :Tela para escolha da vinculação/desvinculação do ato Concessório a um R.E
*/
*--------------------------------------------------------------------------------------*
Function RE400Compr()
*--------------------------------------------------------------------------------------*
Local oDlg
Local lOk        := .F.
Local nLinha     := 5
Local nColuna1   := 5
Local nColuna2   := 50
Local nColuna3   := nColuna2+20

Local nPula      := 12
Local nLarg      := 30
Local nAlt       := 8
Local nOpc       := 0
Local nI         := 0
Local lRet := .T.

Private nTam    := AVSX3('ED9_SEQSIS',AV_TAMANHO)
Private cAc     := SPACE(AVSX3('ED9_AC'    ,AV_TAMANHO))
Private cSeqSis := SPACE(AVSX3('ED9_SEQSIS',AV_TAMANHO))

FOR nI:=1 to ED9->(FCOUNT())
   M->&(ED9->(FIELDNAME(nI) )) := ED9->(FIELDGET(nI))
NEXT

// BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
If lReExtAuto

   cAc     := aCabAuto[aScan(aCabAuto, {|x| "ED9_AC" == AllTrim(Upper(x[1]))})][2]
   cSeqSis := aCabAuto[aScan(aCabAuto, {|x| "ED9_SEQSIS" == AllTrim(Upper(x[1]))})][2]
   nOpc    := 1
   lOk     := ValAtConcess()

Else

   IF  !EMPTY(ED9->ED9_AC) .OR. !EMPTY(ED9->ED9_SEQSIS)
      cAc      := ED9->ED9_AC
      cSeqSis  := StrZero(If(ValType(ED9->ED9_SEQSIS)=="N",ED9->ED9_SEQSIS,Val(ED9->ED9_SEQSIS)),nTam)//STRZERO(ED9->ED9_SEQSIS,nTam)//JVR - 28/04/10
   ENDIF

   DEFINE MSDIALOG oDlg Title STR0012 FROM 0,0 TO 110,200 OF oDlg PIXEL //"Comprovação de Ato Concessorio"
      @nLinha,nColuna1 SAY STR0013 OF oDlg PIXEL //"Ato Concessorio"
      @nLinha,nColuna2 MSGET cAc F3 'ED3' SIZE 50,8 OF oDlg PIXEL
      nLinha+=nPula
      @nLinha,nColuna1 SAY STR0014 OF oDlg PIXEL //"Seq. Siscomex"
      @nLinha,nColuna2 MSGET cSeqSis     SIZE 30,8 OF oDlg PIXEL
      nLinha+=nPula
      nLinha+=5

      Define SButton  From nLinha,nColuna1 Type 1 Action EVAL({||nOpc:=1,lOk:=ValAtConcess(),oDlg:End()})  Enable Of oDlg Pixel
      Define SButton  From nLinha,nColuna3 Type 2 Action EVAL({||oDlg:End()})                      Enable Of oDlg Pixel

   ACTIVATE MSDIALOG oDlg CENTERED

EndIf

   IF nOpc==1
      IF lOk

         // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
         If !lReExtAuto
            If EMPTY(cAc) .AND. EMPTY(cSeqSis) .AND. !Empty(ED9->ED9_AC) .AND. !Empty(ED9->ED9_SEQSIS)
               lOk := MSGYESNO(STR0015)//"Deseja desvincular Ato Concessorio"
            EndIf
            If !EMPTY(cAc) .AND. !EMPTY(cSeqSis) .AND. (cAc <> ED9->ED9_AC .OR.;
               If (ValType("ED9->ED9_SEQSIS") == "N", Val(cSeqSis) <> ED9->ED9_SEQSIS,cSeqSis <> ED9->ED9_SEQSIS))
               lOk := MSGYESNO(STR0016)//"Deseja vincular Ato Concessorio"
            EndIf
         EndIf

         // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
         If lOk .AND. !Empty(ED9->ED9_AC) .AND. !Empty(ED9->ED9_SEQSIS) .And. (!lReExtAuto .Or. (Type("lIncAuto") == "L" .And. !lIncAuto))
            ED3->(DBSETORDER(2)	)// AC+SEQSIS
            ED3->(dbSeek(xFilial("ED3")+ED9->ED9_AC+StrZero(If(ValType(ED9->ED9_SEQSIS)=="N",ED9->ED9_SEQSIS,Val(ED9->ED9_SEQSIS)),nTam)))//STRZERO(ED9->ED9_SEQSIS,nTam)//JVR - 28/04/10
            If lRet := ((lOk := RE400ValDesvinc()) .And. !lPrevAuto)
               RE400Desvinc()
            EndIf
         EndIf

         // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
         If lOk .AND. !EMPTY(cAc) .AND. !EMPTY(cSeqSis) .And. (!lReExtAuto .Or. (Type("lIncAuto ") == "L" .And. lIncAuto))
            ED3->(DBSETORDER(2))// AC+SEQSIS
            ED3->(dbSeek(xFilial("ED3")+AvKey(cAc,"ED3_AC")+AvKey(cSeqSis,"ED3_SEQSIS")))
            If lRet := RE400ValVinc() .And. RE400GrvAnt(cAc,M->ED9_PROD,M->ED9_POSICA,M->ED9_DTEMB,M->ED9_QTD,If(ED9->(FieldPos("ED9_PEDIDO")) > 0 ,M->ED9_PEDIDO,"")) .And. !lPrevAuto //AOM - 28/06/2011
               RE400Vinc()
            EndIf
         ENDIF

      ENDIF

   ENDIF

   If Type("lReExtAuto") == "L" .And. lReExtAuto
      lMSErroAuto := !lRet
   EndIf

Return lRet

/*
Função   :ValAtConcess()
Autor    :Igor de Araújo Chiba
Data     :03/02009
Objetivo :Validar a rotina de ato concessório
*/
*--------------------------------------------------------------------------------------*
STATIC FUNCTION ValAtConcess()
*--------------------------------------------------------------------------------------*
Local lVazio := .F.

IF EMPTY(cAc) .AND. EMPTY(cSeqSis)
   cSeqSis := StrZero(If(ValType(ED9->ED9_SEQSIS)=="N",ED9->ED9_SEQSIS,Val(ED9->ED9_SEQSIS)),nTam)//STRZERO(ED9->ED9_SEQSIS,nTam)//JVR - 28/04/10
   cAc     := ED9->ED9_AC
   lVazio  := .T.
ENDIF

ED3->(DBSETORDER(2))// AC+SEQSIS
IF ED3->(DBSEEK( XFILIAL("ED3")+ AVKEY(cAc,'ED3_AC')  + AVKEY(cSeqSis,'ED3_SEQSIS')  ))
   If lVazio
     cAc    :=""
     cSeqSis:=""
     Return .T.
   EndIf

   /*
   IF ED9->ED9_QTD > ED3->ED3_SALDO
      MsgINfo(STR0017+TRANS(ED3->ED3_SALDO,AVSX3("ED3_SALDO",6)) )//"Saldo de quantidade (unidade de estoque) é insuficiente para a comprovação: "
      Return .F.
   ENDIF
   IF ED9->ED9_QTDNCM > ED3->ED3_SALNCM
      MsgINfo(STR0018+TRANS(ED3->ED3_SALNCM,AVSX3("ED3_SALNCM",6)) )//"Saldo de quantidade (unidade de compra) é insuficiente para a comprovação: "
      Return .F.
   ENDIF

   IF ED9->ED9_VL_FOB > ED3->ED3_SAL_CO
      MsgINfo(STR0019+TRANS(ED3->ED3_SAL_CO,AVSX3("ED3_SAL_CO",6)) )//"Saldo de valor com cobertura cambial insuficiente: "
      Return .F.
   ENDIF

   IF ED9->ED9_VAL_SE > ED3->ED3_SAL_SE
      MsgINfo(STR0020+TRANS(ED3->ED3_SAL_SE,AVSX3("ED3_SAL_SE",6)) )//"Saldo de valor sem cobertura cambial insuficiente: "
      Return .F.
   ENDIF*/
Else

   // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
   If !lReExtAuto
      MsgINfo(STR0021)//"Ato concessorio não encontrado."
   Else
      EasyHelp(STR0021)
   EndIf
   Return .F.

ENDIF

Return .T.

***************************
Static Function Re400Vinc()
***************************

If !InTransact()
   BEGIN Transaction
      Re400GrvVinc()
   END Transaction
Else
   Re400GrvVinc()
EndIf

If !lReExtAuto
   MsgInfo(STR0032)//'Vinculacao do ato concessorio realizado com sucesso'
EndIf

Return .T.

***************************
Static Function Re400GrvVinc()
***************************
Local nPerQtd
Local lRet := .t.

//AOM - 28/06/2011 - Grava Anterioridade do Drawback
RE400GrvEDD(ED9->ED9_RE)
WorkAnt->(DbCloseArea())

If ED9->ED9_QTD > ED3->ED3_SALDO
   nPerQtd := ED3->ED3_SALDO / ED9->ED9_QTD
Else
   nPerQtd := 1
EndIf

If ED9->ED9_QTDNCM > ED3->ED3_SALNCM
   nPerQtd := Min(nPerQtd,ED3->ED3_SALNCM / ED9->ED9_QTDNCM)
EndIF

ED9->(RECLOCK("ED9",.F.))
ED9->ED9_AC     := cAc
ED9->ED9_SEQSIS := If(ValType(ED9->ED9_SEQSIS)=="N",VAL(cSeqSis),cSeqSis)//VAL(cSeqSis)//JVR - 28/04/10
ED9->ED9_QT_AC  := nPerQtd*ED9->ED9_QTD
ED9->ED9_VL_AC  := nPerQtd*ED9->ED9_VL_FOB
ED9->(MSUNLOCK())

ED3->(RECLOCK("ED3",.F.))//JA ESTA POSICIONADO ATRAVES DO SEEK DO VALID
ED3->ED3_SALDO  -= ED9->ED9_QT_AC
ED3->ED3_SALNCM -= nPerQtd*ED9->ED9_QTDNCM
ED3->ED3_SAL_CO -= ED9->ED9_VL_AC
ED3->ED3_SAL_SE -= nPerQTd*ED9->ED9_VAL_SE
ED3->(MSUNLOCK())

Return lRet

******************************
Static Function RE400Desvinc()
******************************

If !InTransact()
   BEGIN Transaction
      RE400GrvDesvinc()
   END Transaction
Else
   RE400GrvDesvinc()
EndIf

If !lReExtAuto
   MsgInfo(STR0033)//'Desvinculacao do ato concessorio realizado com sucesso'
EndIf

Return .T.

******************************
Static Function RE400GrvDesvinc()
******************************
//AOM - 28/06/2011 - Grava Anterioridade do Drawback
RE400DELEDD()

ED3->(RECLOCK("ED3",.F.))//JA ESTA POSICIONADO ATRAVES DO SEEK DO VALID
ED3->ED3_SALDO  += ED9->ED9_QT_AC
ED3->ED3_SALNCM += ED9->ED9_QTDNCM * ED9->ED9_QT_AC / ED9->ED9_QTD
ED3->ED3_SAL_CO += ED9->ED9_VL_AC
ED3->ED3_SAL_SE += ED9->ED9_VAL_SE * ED9->ED9_QT_AC / ED9->ED9_QTD
ED3->(MSUNLOCK())

ED9->(RECLOCK("ED9",.F.))
ED9->ED9_AC     := ''
ED9->ED9_QT_AC  := 0
ED9->ED9_VL_AC  := 0
ED9->ED9_SEQSIS := If(ValType(ED9->ED9_SEQSIS)=="N",0,"")//0 //JVR - 28/04/10
ED9->(MSUNLOCK())

Return .T.

*********************************
Static Function RE400ValDesvinc()
*********************************
Local lRet := .T.


Begin Sequence
   ED0->(dbSetOrder(1))
   ED0->(dbSeek(xFilial("ED0")+ED3->ED3_PD))

   If !Empty(ED0->ED0_DT_ENC)
      // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
      If Type("lReExtAuto") == "L" .and. lReExtAuto
         EasyHelp(STR0022)
         lRet := .F.
      Else
         lRet := MsgYesNo(STR0022)//"Ato Concessório já encerrado. Não é possível desvincular RE."
      EndIf
   EndIf

   If lRet .AND. !SoftLock("ED0")
      lRet := .F.
   EndIf

End Sequence

Return lRet

*********************************
Static Function RE400ValVinc()
*********************************
Local lRet := .T.
Local cMsg := ""
Local lSemVerif := IsInCallStack("EasyDesEDC") // BAK - Se a chamada da função for pela EasyEDCApu, não pode ocorrer a verificação de saldo

Begin Sequence

   ED0->(dbSetOrder(1))
   ED0->(dbSeek(xFilial("ED0")+ED3->ED3_PD))

   If !Empty(ED0->ED0_DT_ENC)
      // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
      If Type("lReExtAuto") == "L" .and. lReExtAuto
         EasyHelp(STR0023)
      Else
         MsgStop(STR0023)//"Ato Concessório já encerrado. Não é possível vincular RE."
      EndIf
      lRet := .F.

   EndIf

   If lRet .AND. ED0->ED0_MODAL <> "1"
      cMsg := STR0027//"Comprovação pode ser feita apenas para Atos Concessórios de Suspensão."

      // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
      If Type("lReExtAuto") == "L" .and. lReExtAuto
         EasyHelp(cMsg,"")
      Else
         MsgStop(cMsg)
      EndIf
      lRet := .F.

   EndIf


   If lRet .AND. ED3->ED3_NCM <> ED9->ED9_NCM
      cMsg := STR0028//"NCM do Ato Concessório (#NCM1#) diferente da NCM do RE (#NCM2#)"
      cMsg := StrTran(cMsg,"#NCM1#",ED3->ED3_NCM)
      cMsg := StrTran(cMsg,"#NCM2#",ED9->ED9_NCM)

      // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
      If Type("lReExtAuto") == "L" .and. lReExtAuto
         EasyHelp(cMsg,"")
      Else
         MsgStop(cMsg)
      EndIf
      lRet := .F.

   EndIf

   If lRet .AND. !Empty(ED3->ED3_PROD) .AND. AllTrim(ED3->ED3_PROD) <> AllTrim(ED9->ED9_PROD)
      cMsg := STR0029//"Produto do Ato Concessório (#PROD1#) diferente do Produto do RE (#PROD2#)"
      cMsg := StrTran(cMsg,"#PROD1#",ED3->ED3_PROD)
      cMsg := StrTran(cMsg,"#PROD2#",ED9->ED9_PROD)

      // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
      If Type("lReExtAuto") == "L" .and. lReExtAuto
         EasyHelp(cMsg,"")
      Else
         MsgStop(cMsg)
      EndIf
      lRet := .F.

   EndIf

   If lSemVerif
      Break
   EndIf

   If lRet .AND. ED3->ED3_SALDO < ED9->ED9_QTD .OR. ED3->ED3_QTDNCM < ED9->ED9_QTDNCM
      cMsg := STR0024

      // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
      If Type("lReExtAuto") == "L" .and. lReExtAuto
         cMsg := SubStr(cMsg,1,Len(STR0034))//"Não há saldo de quantidade disponível no Ato Concessório."
         EasyHelp(cMsg,"")
      Else
         lRet := MsgYesNo(cMsg)//"Não há saldo de quantidade disponível no Ato Concessório. Deseja associar o RE parcialmente ao Ato Concessório?"
      EndIf

   EndIf

   If lRet .AND. (ED3->ED3_SAL_CO  < ED9->ED9_VL_FOB)
      cMsg := STR0025

      // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
      If Type("lReExtAuto") == "L" .and. lReExtAuto
         cMsg := SubStr(cMsg,1,Len(STR0035))//"Não há saldo de valor disponível no Ato Concessório."
         EasyHelp(cMsg,"")
      Else
         lRet := MsgYesNo(cMsg)//"Não há saldo de valor disponível no Ato Concessório. Deseja continuar?"
      EndIf

   EndIf

   If lRet .AND. (ED3->ED3_SAL_SE < ED9->ED9_VAL_SE)
      cMsg := STR0026

      // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
      If Type("lReExtAuto") == "L" .and. lReExtAuto
         cMsg := SubStr(cMsg,1,Len(STR0036))//"Não há saldo de valor sem cobertura cambial disponível no Ato Concessório."
         EasyHelp(cMsg,"")
      Else
         lRet := MsgYesNo(cMsg)//"Não há saldo de valor sem cobertura cambial disponível no Ato Concessório. Deseja continuar?"
      EndIf

   EndIf

   // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
   If lRet .And. Type("lReExtAuto") == "L" .and. lReExtAuto .And. !Empty(cMsg)
      lRet := .F.
   EndIf

End Sequence

If lRet .AND. !SoftLock("ED0")
   lRet := .F.
EndIf

Return lRet

/*
Funcao      : RE400GrvAnt
Parametros  : cAto,cProd,cSequen,dDtEmba,nQtdComp,cPedido
Retorno     : lRet
Objetivos   : Efetua as validadações da anterioridade de Drawback
Autor       : Allan Oliveira Monteiro
Data/Hora   : 28/06/2011
Revisao     :
Obs.        :
*/

*--------------------------------------------------------------------------------------------*
Function RE400GrvAnt(cAto,cProd,cSequen,dDtEmba,nQtdComp,cPedido)  //GFC - 18/07/2003 - Anterioridade Drawback
*--------------------------------------------------------------------------------------------*
Local aSX3Ant:={}, aControle:={}, nTotED1:=0,  ni:=0, cCampo, aArrayAux:={}, nInd:=0
Local nRecAux, nQtdAux:=0, i:=0
Local aOrd := {}
Local lRet := .T.
Local aItNegativo := {} , aItPositivo := {}
Local cMsg := ""
Local cPreemb := ""
Local lCompNacion := AvFlags("SEQMI")
Local cSeekEDD := ""
Local lTpOcor   := EDD->(FIELDPOS("EDD_CODOCO")) > 0 .And. EDD->(FIELDPOS("EDD_DESTIN")) > 0 //AOM - 22/06/2012 - Campos para gravação de Itens comprados na Anterioridade


aOrd := SaveOrd({"ED0","ED1","ED2","ED3","ED9","SB1"})

 If(ValType(cAto)     <> "C" .Or. Empty(cAto)   , cAto    := Space(AVSX3("EDD_AC"    ,AV_TAMANHO)), cAto     )
 If(ValType(cProd)    <> "C" .Or. Empty(cProd)  , cProd   := Space(AVSX3("EDD_PROD"  ,AV_TAMANHO)), cProd    )
 If(ValType(cSequen)  <> "C" .Or. Empty(cSequen), cSequen := Space(AVSX3("EDD_SEQUEN",AV_TAMANHO)), cSequen  )
 If(ValType(dDtEmba)  <> "D" .Or. Empty(dDtEmba), dDtEmba := Space(AVSX3("EDD_DTRE"  ,AV_TAMANHO)), dDtEmba  )
 If(ValType(nQtdComp) <> "N"                    , nQtdComp := 0                                   , nQtdComp )
 If(ValType(cPedido)  <> "C" .Or. Empty(cPedido), cPedido := Space(AVSX3("EDD_PEDIDO",AV_TAMANHO)), cPedido  )

Private lExibeMsg1 := .T.
Private lExibeMsg2  := .T. //AOM - 01/07/2011 - Exibe as mensagens para verificar se deseja apropriar a anterioridade.


Private FWorkAnt, FWorkAnt2, FWorkAnt3, FWorkAnt4
//Habilita o calculo do Lead Time por produção

IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o campo Lead Time na Tabela EYJ
	Private lLeadTime := EDC->(FieldPos("EDC_LEADTI")) > 0 .and. EYJ->(FieldPos("EYJ_PRODUC")) > 0 .AND.;
						 EDC->(FieldPos("EDC_PRODUC")) > 0 .and. EasyGParam("MV_AVG0184",.F.,.F.)
Else
	Private lLeadTime := SB1->(FieldPos("B1_LEADTI")) > 0 .AND. EDC->(FieldPos("EDC_LEADTI")) > 0 .and.;
                         SB1->(FieldPos("B1_PRODUC")) > 0 .AND. EDC->(FieldPos("EDC_PRODUC")) > 0 .and.;
                         EasyGParam("MV_AVG0184",.F.,.F.)
EndIF

//Parametro com o Lead Time para anterioridade de Isenção
Private nLeadTime:=EasyGParam("MV_LEADANT",,30)

//Indica qual data usar para verificar a anterioridade.
Private cAntExp := EasyGParam("MV_ANT_EXP",,"1")

Private aHeader := {}, aCampos := Array(EDD->(FCount()))

Begin Sequence

EDD->(dbSetOrder(1)) // BAK - Indice alterado no update UDVE400(), verificação ocorrido no AvFlags(INDICEEDD)
ED0->(dbSetOrder(2))
ED1->(dbSetOrder(1))
ED2->(dbSetOrder(2))
SB1->(dbSetOrder(1))

If !Empty(M->ED9_RE)
   cPreemb := AvKey(M->ED9_RE,"ED9_RE") + AvKey(M->ED9_POSICA,"ED9_POSICA")
   cPedido := ""
ElseIf !Empty(cPedido)
   cPreemb := ""
EndIf

If Type("lMFilEDC") == "U"
   lMFilEDC  := VerSenha(115)  ;
                .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0  ;
                .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0
EndIf

//Verifica se a data da anterioridade sera a da Nota fiscal ou da Data de Embarque
If !Empty(M->ED9_EMISSA) .And. Empty(M->ED9_RE) //FSM - 29/09/2011
   dDtEmba := M->ED9_EMISSA
EndIf

//Prenche a data de embarque
If Empty(dDtEmba)
   If Type("M->ED9_DTEMB") <> "U" .and. !Empty(M->ED9_DTEMB) .And. cAntExp == "2"
      dDtEmba:=M->ED9_DTEMB

   ElseIf cAntExp == "1" .And. !Empty(M->ED9_EMISSA)
      dDtEmba := M->ED9_EMISSA
   Else
      dDtEmba:=dDataBase
   EndIf
EndIf

//Verifica se a modalidade do Ato é Suspensão se nao for sai da rotina
ED0->(dbSeek(xFilial("ED0")+ AvKey(cAto,"ED0_AC")))
If ED0->ED0_MODAL <> "1"
   lRet := .F.
   Break
EndIf

If Select("WorkAnt") = 0

   AAdd(aSX3Ant,{"EDD_REC"   ,"N",10,0})
   If EDD->(FieldPos("EDD_SEQMI")) > 0
      AAdd(aSX3Ant,{"EDD_SEQMI" , AvSX3("EDD_SEQMI",2),AvSX3("EDD_SEQMI",3),AvSX3("EDD_SEQMI",4)})
   EndIf

   //Inclui campos referente tratamento Multi-Filial do Drawback
   If lMFilEDC
      AAdd( aSX3Ant, {"EDD_FILEXP", AVSX3("EDD_FILEXP",AV_TIPO), AVSX3("EDD_FILEXP",AV_TAMANHO), AVSX3("EDD_FILEXP",AV_DECIMAL)} )
      AAdd( aSX3Ant, {"EDD_FILIMP", AVSX3("EDD_FILIMP",AV_TIPO), AVSX3("EDD_FILIMP",AV_TAMANHO), AVSX3("EDD_FILIMP",AV_DECIMAL)} )
   EndIf

   //AOM - 31/08/2011
   AAdd( aSX3Ant, {"EDD_ITFAT", AVSX3("EDD_QTD",AV_TIPO), AVSX3("EDD_QTD",AV_TAMANHO), AVSX3("EDD_QTD",AV_DECIMAL)} )


   //AOM - 25/06/2012
   If lTpOcor
      AAdd( aSX3Ant, {"EDD_CODOCO", AVSX3("EDD_CODOCO",AV_TIPO), AVSX3("EDD_CODOCO",AV_TAMANHO), AVSX3("EDD_CODOCO",AV_DECIMAL)} )
      AAdd( aSX3Ant, {"EDD_DESTIN", AVSX3("EDD_DESTIN",AV_TIPO), AVSX3("EDD_DESTIN",AV_TAMANHO), AVSX3("EDD_DESTIN",AV_DECIMAL)} )
   EndIf

   FWorkAnt  :=E_CriaTrab("EDD",aSX3Ant,"WorkAnt")
   FWorkAnt2 :=E_Create(,.F.)
   FWorkAnt3 :=E_Create(,.F.)
   IndRegua("WorkAnt",FWorkAnt+TEOrdBagExt()  ,"EDD_AC+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN"+IF(lTpOcor,"+EDD_CODOCO",""))//AOM - 27/06/2012
   IndRegua("WorkAnt",FWorkAnt2+TEOrdBagExt() ,"EDD_AC+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_ITEM+DTOS(EDD_DTREG)")
   IndRegua("WorkAnt",FWorkAnt3+TEOrdBagExt() ,"EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN")

   If lCompNacion
      FWorkAnt4 :=E_Create(,.F.)
      IndRegua("WorkAnt",FWorkAnt4+TEOrdBagExt() ,"EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN")
   EndIf

   If lCompNacion
      SET INDEX TO (FWorkAnt+TEOrdBagExt()),(FWorkAnt2+TEOrdBagExt()),(FWorkAnt3+TEOrdBagExt()),(FWorkAnt4+TEOrdBagExt())
   Else
      SET INDEX TO (FWorkAnt+TEOrdBagExt()),(FWorkAnt2+TEOrdBagExt()),(FWorkAnt3+TEOrdBagExt())
   EndIf

Else

   WorkAnt->(avzap())

EndIf

//Busca o item principal e compara as estruturas
If !ED1->(dbSeek(xFilial("ED1")+ED0->ED0_PD+AvKey(cProd,"ED1_PROD")))
   cItem := IG400BuscaItem("E", cProd, ED0->ED0_PD)
   If AvCompEstr(cItem, cProd, ED3->ED3_PD, .F., .T., , .T.)
      cProd := cItem
   EndIf
   ED1->(dbSeek(xFilial("ED1")+ED0->ED0_PD+AvKey(cProd,"ED1_PROD")))
EndIf

Do While !ED1->(EOF()) .and. ED1->ED1_AC == cAto .and. AllTrim(ED1->ED1_PROD) == AllTrim(cProd)
   nTotED1 += ED1->ED1_QTD
   ED1->(dbSkip())
EndDo

If SB1->(dbSeek(xFilial("SB1")+AvKey(cProd,"B1_COD"))) .AND. ED2->(dbSeek(xFilial("ED2")+ED0->ED0_PD+AvKey(cProd,"ED2_PROD")))

   //Verifica se utiliza Lead Time por produção

   If lLeadTime
     If EYJ->(FieldPos("EYJ_LEADTI")) > 0 // LRS 11/02/2014 -
		 If EYJ->EYJ_LEADTI > 0 .and. EYJ->EYJ_PRODUC > 0
		 	nLeadTime := Int((nQtdComp * EYJ->EYJ_LEADTI)/EYJ->EYJ_PRODUC)
		 ElseIf EYJ->EYJ_LEADTI > 0 .and. EYJ->EYJ_PRODUC = 0
		 	nLeadTime := Int((nQtdComp * EYJ->EYJ_LEADTI)/nQtdComp)
		 EndIf
     else
	    If SB1->B1_LEADTI > 0 .and. SB1->B1_PRODUC > 0
	       nLeadTime := Int((nQtdComp * SB1->B1_LEADTI)/SB1->B1_PRODUC)
	    ElseIf SB1->B1_LEADTI > 0 .and. SB1->B1_PRODUC = 0
	       nLeadTime := Int((nQtdComp * SB1->B1_LEADTI)/nQtdComp)
	    EndIf
     EndIf
   EndIF

   dDataLimite := dDtEmba - nLeadTime

   Do While !ED2->(EOF()) .and. ED2->ED2_FILIAL==xFilial("ED2") .and. ED2->ED2_PD==ED0->ED0_PD .and.;
   AllTrim(ED2->ED2_PROD) == AllTrim(cProd)
      If ED2->ED2_MARCA == "1"
         //Utilizar Quantidade Calculada para baixa de saldo.
         nQtdCal := Round(ED2->ED2_QTD * ((100 - Max(ED2->(ED2_PERCPE - ED2_PERCAP),0)) / 100 ),AvSx3("ED2_QTD",4))

         If (nPos:=aScan(aControle,{|x| AllTrim(x[2])==AllTrim(ED2->ED2_ITEM)})) = 0
            aAdd(aControle,{cProd,ED2->ED2_ITEM,nQtdCal/nTotED1,.T.,(nQtdCal/nTotED1) * nQtdComp})

            WorkAnt->(dbSetOrder(2))
            If !WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN))+AvKey(ED2->ED2_ITEM,"EDD_ITEM")))

               dbSelectArea("WorkAnt")

               If !EDD->(dbSeek(xFilial("EDD")+cAto+Space(Len(EDD->EDD_PREEMB))+Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN))+AvKey(ED2->ED2_ITEM,"EDD_ITEM"))) .Or. EDD->EDD_DTREG > dDataLimite

                  aControle[Len(aControle),4] := .F.
                  Do While !EDD->(EOF()) .And. EDD->EDD_FILIAL==xFilial("EDD") .And. AllTrim(EDD->EDD_AC) == AllTrim(cAto) .And.;
                  Empty(EDD->EDD_PREEMB) .And. Empty(EDD->EDD_PEDIDO) .And. AllTrim(EDD->EDD_ITEM)==AllTrim(ED2->ED2_ITEM);
                  .And. (!lTpOCor .Or. Empty(EDD->EDD_CODOCO) )//AOM - 26/06/2012
                     //WorkAnt->(RecLock("WorkAnt",.T.))
                     WorkAnt->(DBAPPEND())
                     FOR i := 1 TO WorkAnt->(FCount())
                        cCampo := FIELDNAME(i)
                        If EDD->(FieldPos(cCampo)) # 0
                           WorkAnt->&(cCampo) := EDD->&(cCampo)
                        EndIf
                     NEXT i
                     WorkAnt->EDD_REC := EDD->(RecNo())
                     //WorkAnt->(msUnlock())
                     EDD->(dbSkip())
                  EndDo

               Else

                  Do While !EDD->(EOF()) .And. EDD->EDD_FILIAL==xFilial("EDD") .And. EDD->EDD_AC==cAto .And.;
                  Empty(EDD->EDD_PREEMB) .And. Empty(EDD->EDD_PEDIDO) .And. AllTrim(EDD->EDD_ITEM)==AllTrim(ED2->ED2_ITEM);
                  .And. (!lTpOCor .Or. Empty(EDD->EDD_CODOCO) )//AOM - 26/06/2012
                     //WorkAnt->(RecLock("WorkAnt",.T.))
                     WorkAnt->(DBAPPEND())
                     FOR i := 1 TO WorkAnt->(FCount())
                        cCampo := FIELDNAME(i)
                        If EDD->(FieldPos(cCampo)) # 0
                           WorkAnt->&(cCampo) := EDD->&(cCampo)
                        EndIf
                     NEXT i
                     WorkAnt->EDD_REC := EDD->(RecNo())
                     //WorkAnt->(msUnlock())
                     EDD->(dbSkip())
                  EndDo

               EndIf
            EndIf
         Else
            // Utilizar Quantidade Calculada para baixa de saldo.
            aControle[nPos,3] += nQtdCal/nTotED1 //ED2->ED2_QTD/nTotED1
            aControle[nPos,5] += (nQtdCal/nTotED1) * nQtdComp//(ED2->ED2_QTD/nTotED1) * nQtdComp
         EndIf
      EndIf
      ED2->(dbSkip())
   EndDo

   WorkAnt->(dbSetOrder(1)) //EDD_AC+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN
   If !WorkAnt->(dbSeek( cAto + AvKey(cPreemb,"EDD_PREEMB") +AvKey(cPedido,"EDD_PEDIDO") + AvKey(cSequen,"EDD_SEQUEN")))

      WorkAnt->(dbSetOrder(2))
      For ni:=1 to Len(aControle)
         lMaior  := .F.
         nQtdAux := aControle[ni,5]

         If !WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN))+AvKey(aControle[ni,2],"ED9_PROD"))) .or.;
         (WorkAnt->EDD_DTREG > dDataLimite .And. (!lTpOCor .Or. Empty(WorkAnt->EDD_CODOCO) )) //AOM 27/06/12

            //Adiciona o no array aItNegativo para apresentar a mensagem de apropriação
            If (nPos:=aScan(aItNegativo,{|x| Alltrim(x[2])==Alltrim(aControle[ni,2])})) == 0
               AADD(aItNegativo,{Alltrim(cSequen),Alltrim(cProd),Alltrim(aControle[ni,2]),Alltrim(cAto),DToC(dDataLimite) })
            EndIf

            //WorkAnt->(RecLock("WorkAnt",.T.))
            WorkAnt->(DBAPPEND())
            WorkAnt->EDD_AC     := cAto
            WorkAnt->EDD_PD     := ED0->ED0_PD
            WorkAnt->EDD_ITEM   := aControle[ni,2]
            WorkAnt->EDD_PREEMB := cPreemb
            WorkAnt->EDD_PEDIDO := cPedido
            WorkAnt->EDD_SEQUEN := cSequen
            WorkAnt->EDD_QTD    := aControle[ni,5] * -1
            //WorkAnt->EDD_DTREG  := dDtEmba
            WorkAnt->EDD_DTRE   := dDtEmba
            WorkAnt->EDD_QTD_EX := nQtdComp
            WorkAnt->EDD_LEAD   := nLeadTime
            WorkAnt->EDD_PROD   := cProd
            WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
            If lMFilEDC
               WorkAnt->EDD_FILEXP := cFilAnt
            EndIf
            //AOM - 26/06/2012
            If lTpOcor
               If Empty(WorkAnt->EDD_PEDIDO)
                  WorkAnt->EDD_DESTIN := "RE EXTERNO"
               Else
                  WorkAnt->EDD_DESTIN := "VENDAS P/ EXPORTADORES"
               EndIf
            EndIf
            //WorkAnt->(msUnlock())

         Else

            Do While !WorkAnt->(EOF()) .and. AllTrim(WorkAnt->EDD_AC) == AllTrim(cAto) .and. Empty(WorkAnt->EDD_PREEMB) .And. Empty(WorkAnt->EDD_PEDIDO) .and.;
            AllTrim(WorkAnt->EDD_ITEM)==AllTrim(aControle[ni,2]) .and. WorkAnt->EDD_DTREG <= dDataLimite .and. aControle[ni,5] > 0
               If aControle[ni,5] < WorkAnt->EDD_QTD .And. (!lTpOCor .Or. Empty(WorkAnt->EDD_CODOCO) ) //AOM 27/06/12
                  aArrayAux := {}
                  nRecAux:=WorkAnt->(RecNo())
                  For nInd:=1 to WorkAnt->(FCount())
                     aAdd(aArrayAux,WorkAnt->(FieldGet(nInd)))
                  Next nInd

                  // WorkAnt->(RecLock("WorkAnt",.T.))   //Registro utilizado de acordo com anterioridade
                  WorkAnt->(DBAPPEND())
                  For nInd:=1 to Len(aArrayAux)
                     WorkAnt->&(FIELDNAME(nInd)) := aArrayAux[nInd]
                  Next nInd
                  WorkAnt->EDD_PREEMB := cPreemb
                  WorkAnt->EDD_PEDIDO := cPedido
                  WorkAnt->EDD_SEQUEN := cSequen
                  WorkAnt->EDD_QTD    := aControle[ni,5]
                  WorkAnt->EDD_DTRE   := dDtEmba
                  WorkAnt->EDD_QTD_EX := nQtdComp
                  WorkAnt->EDD_LEAD   := nLeadTime
                  WorkAnt->EDD_PROD   := cProd
                  WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
                  WorkAnt->EDD_REC    := 0
                  If lMFilEDC
                     WorkAnt->EDD_FILEXP := cFilAnt
                  EndIf
                  //WorkAnt->(msUnlock())
                  //AOM - 26/06/2012
                  If lTpOcor
                     If Empty(WorkAnt->EDD_PEDIDO)
                        WorkAnt->EDD_DESTIN := "RE EXTERNO"
                     Else
                        WorkAnt->EDD_DESTIN := "VENDAS P/ EXPORTADORES"
                     EndIf
                  EndIf

                  //Quantidade a comprovar com os outros registros.
                  nQtdAux -= aControle[ni,5]

                  WorkAnt->(dbGoTo(nRecAux))   //Registro com saldo não utilizado
                  WorkAnt->EDD_QTD    := WorkAnt->EDD_QTD - aControle[ni,5]

                  aControle[ni,5] := 0
               Else
                  aControle[ni,5] -= WorkAnt->EDD_QTD
                  lMaior := .T.
               EndIf

               //Adiciona o no array aItPositivo para apresentar a mensagem de apropriação no final
               If (nPos:=aScan(aItPositivo,{|x| Alltrim(x[2])==AllTrim(aControle[ni,2])})) == 0
                  AADD(aItPositivo,{AllTrim(cSequen),Alltrim(cProd),Alltrim(aControle[ni,2]),Alltrim(cAto),DToC(dDataLimite) })
               EndIf

               WorkAnt->(dbSkip())
            EndDo
            If aControle[ni,5] > 0

               //Adiciona o no array aItNegativo para apresentar a mensagem de apropriação
               If (nPos:=aScan(aItNegativo,{|x| Alltrim(x[2])==Alltrim(aControle[ni,2])})) == 0
                  AADD(aItNegativo,{Alltrim(cSequen),Alltrim(cProd),Alltrim(aControle[ni,2]),Alltrim(cAto),DToC(dDataLimite) })
               EndIf

               //WorkAnt->(RecLock("WorkAnt",.T.))
               WorkAnt->(DBAPPEND())
               WorkAnt->EDD_AC     := cAto
               WorkAnt->EDD_PD     := ED0->ED0_PD
               WorkAnt->EDD_ITEM   := aControle[ni,2]
               WorkAnt->EDD_PREEMB := cPreemb
               WorkAnt->EDD_PEDIDO := cPedido
               WorkAnt->EDD_SEQUEN := cSequen
               WorkAnt->EDD_QTD    := aControle[ni,5] * -1
               //WorkAnt->EDD_DTREG  := dDtEmba
               WorkAnt->EDD_DTRE   := dDtEmba
               WorkAnt->EDD_QTD_EX := nQtdComp
               WorkAnt->EDD_LEAD   := nLeadTime
               WorkAnt->EDD_PROD   := cProd
               WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
               If lMFilEDC
                  WorkAnt->EDD_FILEXP := cFilAnt
               EndIf

               //AOM - 26/06/2012
               If lTpOcor
                  If Empty(WorkAnt->EDD_PEDIDO)
                     WorkAnt->EDD_DESTIN := "RE EXTERNO"
                  Else
                     WorkAnt->EDD_DESTIN := "VENDAS P/ EXPORTADORES"
                  EndIf
               EndIf
               //WorkAnt->(msUnlock())

               WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN))+AvKey(aControle[ni,2],"ED9_PROD")))
               Do While !WorkAnt->(EOF()) .and. AllTrim(WorkAnt->EDD_AC) == AllTrim(cAto) .and. Empty(WorkAnt->EDD_PREEMB) .And. Empty(WorkAnt->EDD_PEDIDO) .and.;
               AllTrim(WorkAnt->EDD_ITEM)==AllTrim(aControle[ni,2]) .and. WorkAnt->EDD_DTREG <= dDataLimite .and.;
               nQtdAux > 0  .And. (!lTpOCor .Or. Empty(WorkAnt->EDD_CODOCO) ) //AOM 27/06/12
                  WorkAnt->EDD_PREEMB := cPreemb
                  WorkAnt->EDD_PEDIDO := cPedido
                  WorkAnt->EDD_SEQUEN := cSequen
                  WorkAnt->EDD_DTRE   := dDtEmba
                  WorkAnt->EDD_QTD_EX := nQtdComp
                  WorkAnt->EDD_LEAD   := nLeadTime
                  WorkAnt->EDD_PROD   := cProd
                  WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
                  If lMFilEDC
                     WorkAnt->EDD_FILEXP := cFilAnt
                  EndIf
                  //AOM - 26/06/2012
                  If lTpOcor
                     If Empty(WorkAnt->EDD_PEDIDO)
                        WorkAnt->EDD_DESTIN := "RE EXTERNO"
                     Else
                        WorkAnt->EDD_DESTIN := "VENDAS P/ EXPORTADORES"
                     EndIf
                  EndIf
                  nQtdAux -= WorkAnt->EDD_QTD
                  //Procurar pois o registro atual foi desposicionado, devido a alteração em campos chave.
                  WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN))+AvKey(aControle[ni,2],"ED9_PROD")))//WorkAnt->(dbSkip())
               EndDo

            ElseIf lMaior

               //Adiciona o no array aItPositivo para apresentar a mensagem de apropriação no final
               If (nPos:=aScan(aItPositivo,{|x| Alltrim(x[2])==Alltrim(aControle[ni,2])})) == 0
                  AADD(aItPositivo,{AllTrim(cSequen),Alltrim(cProd),Alltrim(aControle[ni,2]),Alltrim(cAto),DToC(dDataLimite) })
               EndIf

               WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN))+AvKey(aControle[ni,2],"ED9_PROD")))
               Do While !WorkAnt->(EOF()) .and. AllTrim(WorkAnt->EDD_AC) == AllTrim(cAto) .and. Empty(WorkAnt->EDD_PREEMB) .And. Empty(WorkAnt->EDD_PEDIDO) .and.;
               AllTrim(WorkAnt->EDD_ITEM)==AllTrim(aControle[ni,2]) .and. WorkAnt->EDD_DTREG <= dDataLimite .and.;
               nQtdAux > 0 .And. (!lTpOCor .Or. Empty(WorkAnt->EDD_CODOCO) ) //AOM 27/06/12
                  WorkAnt->EDD_PREEMB := cPreemb
                  WorkAnt->EDD_PEDIDO := cPedido
                  WorkAnt->EDD_SEQUEN := cSequen
                  WorkAnt->EDD_DTRE   := dDtEmba
                  WorkAnt->EDD_QTD_EX := nQtdComp
                  WorkAnt->EDD_LEAD   := nLeadTime
                  WorkAnt->EDD_PROD   := cProd
                  WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
                  If lMFilEDC
                     WorkAnt->EDD_FILEXP := cFilAnt
                  EndIf

                  //AOM - 26/06/2012
                  If lTpOcor
                     If Empty(WorkAnt->EDD_PEDIDO)
                        WorkAnt->EDD_DESTIN := "RE EXTERNO"
                     Else
                        WorkAnt->EDD_DESTIN := "VENDAS P/ EXPORTADORES"
                     EndIf
                  EndIf
                  nQtdAux -= WorkAnt->EDD_QTD
                  //Procurar pois o registro atual foi desposicionado, devido a alteração em campos chave.
                  WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN))+AvKey(aControle[ni,2],"ED9_PROD")))//WorkAnt->(dbSkip())
               EndDo
            EndIf
         EndIf
      Next ni
   EndIf
EndIf

If Len(aControle) == 0 .AND. ED0->ED0_TIPOAC <> "06" // Não bloqueia Atos Genéricos.

   // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
   If Type("lReExtAuto") == "L" .and. lReExtAuto
      EasyHelp(STR0037)//"Este Ato Concessório não possui importação para nenhum dos itens."
   Else
      MsgInfo(STR0037)//"Este Ato Concessório não possui importação para nenhum dos itens."
   EndIf

   lRet := .F.
   Break
Endif

If Type("lReExtAuto") == "L" .and. !lReExtAuto
   cMsg += ENTER + Replicate("-",218) + ENTER
EndIf

/*
aItNegativo [1] := SEQUENCIA DO ATO
aItNegativo [2] := PRODUTO EXPORTAR
aItNegativo [3] := ITEM IMPORTAR
aItNegativo [4] := ATO CONCESSÓRIO
aItNegativo [5] := DATA LIMITE
*/
If !Empty(aItNegativo)
   cMsg += STR0038 + aItNegativo[1][2] + STR0039 + aItNegativo[1][1] + "." + REPLICATE(ENTER,2) //"PRODUTO EXPORTADO: " // " SEQUÊNCIA: "
   cMsg += STR0040  + REPLICATE(ENTER,2)//"ITENS QUE NÃO POSSUEM SALDOS DE IMPORTAÇÕES."
   For i:= 1  to Len(aItNegativo)
     //cMsg += "Produto Exportado " + aItNegativo[i][2] + " na sequência " + aItNegativo[i][1] + " não possui importação para o Item " + aItNegativo[i][3] + " , de sua estrutura, que comprove anterioridade no Ato  " + aItNegativo[i][4] + " com entrada anterior á " + aItNegativo[i][5] + "." + ENTER
     cMsg += STR0041 + aItNegativo[i][3] + STR0042 + aItNegativo[i][4] + STR0043 + aItNegativo[i][5] + "." + ENTER //"Não possui importação para o Item " //" , de sua estrutura, que comprove anterioridade no Ato  "//" com entrada anterior á "
   Next i
   If Type("lReExtAuto") == "L" .and. !lReExtAuto
      cMsg += ENTER + Replicate("-",218) + ENTER
   EndIf
EndIf


/*
aItPositivo [1] := SEQUENCIA DO ATO
aItPositivo [2] := PRODUTO EXPORTAR
aItPositivo [3] := ITEM IMPORTAR
aItPositivo [4] := ATO CONCESSÓRIO
aItPositivo [5] := DATA LIMITE
*/
IF !Empty(aItPositivo)
   cMsg += STR0038 + aItPositivo[1][2] + STR0039 + aItPositivo[1][1] + "." + REPLICATE(ENTER,2)//"PRODUTO EXPORTADO: "//" SEQUÊNCIA: "
   cMsg += STR0044 + REPLICATE(ENTER,2)//"ITENS COM SALDOS DE IMPORTAÇÕES."
   For i := 1 to Len(aItPositivo)
      cMsg += STR0045 + aItPositivo[i][3] + STR0046 + aItPositivo[i][4] + STR0047 + aItPositivo[i][5] + "." + ENTER  //"Possui importação para o item "//" de sua estrutura, que comprove anterioridade no Ato "//" com entrada anterior á data "
   Next i
EndIf

//Ponto de Entrada para Exibir ou nao a mensagem de apropriação atraves da variavel "lExibeMsg1 e lExibeMsg2" - AOM - 01/07/2011
IF(EasyEntryPoint("EDCRE400"),Execblock("EDCRE400",.F.,.F.,{"RE400GRVANT_EXIBEMSG",aItPositivo,aItNegativo}),)

/* Exibe quando não for chamada da reapuração de saldos */
IF !Empty(aItNegativo) .And. lExibeMsg1 .And. !IsInCallStack("EDCAP400")

   // BAK - Tratamento para Integração Drawback - (RE`s Externas e Comprovações externas DICompras nacionais) - 25/08/2011
   If Type("lReExtAuto") == "L" .and. lReExtAuto
      EasyHelp(cMsg,"")
      lRet:= .F.
      Break
   Else
      IF EECView(cMsg,"Apropriação de Anterioridade")
         If lExibeMsg2 .And. !MsgYesNo(STR0048)//"Deseja Efetuar a apropriação do Ato Concessório ?"
            RE400DelWkAnt(cAto,cPedido,cSequen)
            lRet:= .F.
            Break
         EndIf
      Else
         RE400DelWkAnt(cAto,cPedido,cSequen)
         lRet:= .F.
         Break
      EndIf
   EndIf

EndIf

End Sequence

RestOrd(aOrd)

Return lRet

*--------------------------------------------------------------------------------------------*
Function RE400DelWkAnt(cAc,cPed,cSeq)
*--------------------------------------------------------------------------------------------*
Local nQtdAux := nRecAux := 0
Local cPreemb := AvKey(M->ED9_RE,"ED9_RE") + AvKey(M->ED9_POSICA,"ED9_POSICA")
Local cSeekAnt := ""
Local lCompNacion := AvFlags("SEQMI")

WorkAnt->(dbSetOrder(1))
If !Empty(cAc) .and. WorkAnt->(dbSeek(cAc + AvKey(cPreemb,"EDD_PREEMB") +AvKey(cPed,"EDD_PEDIDO") + AvKey(cSeq,"EDD_SEQUEN")))
   Do While WorkAnt->(dbSeek(cAc + AvKey(cPreemb,"EDD_PREEMB") +AvKey(cPed,"EDD_PEDIDO") + AvKey(cSeq,"EDD_SEQUEN")))

      If Empty(WorkAnt->EDD_HAWB)
         WorkAnt->(dbDelete())
      Else
         nQtdAux := WorkAnt->EDD_QTD
         nRecAux := WorkAnt->(RecNo())

         If lCompNacion .And. Empty(WorkAnt->EDD_HAWB) .and. !Empty(WorkAnt->EDD_HAWB)
            WorkAnt->(DbSetOrder(4))
            cSeekAnt := WorkAnt->EDD_HAWB+WorkAnt->EDD_INVOIC+WorkAnt->EDD_PO_NUM+WorkAnt->EDD_POSICA+WorkAnt->EDD_PGI_NU+WorkAnt->EDD_AC+WorkAnt->EDD_SEQMI+Space(Len(WorkAnt->EDD_PREEMB))+Space(Len(WorkAnt->EDD_PEDIDO))+Space(Len(WorkAnt->EDD_SEQUEN))
         Else
            WorkAnt->(dbSetOrder(3))
            cSeekAnt := WorkAnt->EDD_HAWB+WorkAnt->EDD_INVOIC+WorkAnt->EDD_PO_NUM+WorkAnt->EDD_POSICA+WorkAnt->EDD_PGI_NU+WorkAnt->EDD_AC+WorkAnt->EDD_SEQSII+Space(Len(WorkAnt->EDD_PREEMB))+Space(Len(WorkAnt->EDD_PEDIDO))+Space(Len(WorkAnt->EDD_SEQUEN))
         EndIf

         If WorkAnt->(dbSeek(cSeekAnt))
            WorkAnt->EDD_QTD += nQtdAux
            WorkAnt->(dbGoTo(nRecAux))
            WorkAnt->(dbDelete())
         Else
            WorkAnt->(dbGoTo(nRecAux))
            WorkAnt->EDD_PREEMB := ""
            WorkAnt->EDD_PEDIDO := ""
            WorkAnt->EDD_SEQUEN := ""
            WorkAnt->EDD_DTRE   := AvCtoD("  /  /  ")
            WorkAnt->EDD_QTD_EX := 0
            WorkAnt->EDD_LEAD   := 0
            WorkAnt->EDD_PROD   := ""
            WorkAnt->EDD_SEQSIE := ""
            If lMFilEDC
               WorkAnt->EDD_FILEXP := ""
            EndIf
         EndIf
         WorkAnt->(dbSetOrder(1))
      EndIf

      WorkAnt->(dbSkip())
   EndDo
EndIf

Return .T.

/* Revisão: nov/2018.
            Passou a ser chamada da função AE100Grava()
*/
*--------------------------------------------------------------------------------------------*
Function RE400GrvEDD(cRegSiscomex)
*--------------------------------------------------------------------------------------------*
Local cCampo := ""
Local xi := 0
Local cSeek := ""
Local lCompNacion := AvFlags("SEQMI")
Default cRegSiscomex:= ""

dbSelectArea("WorkAnt")

WorkAnt->(dbGoTop())
Do While !WorkAnt->(EOF())
   EDD->(dbGoTo(WorkAnt->EDD_REC))
   If !(EDD->(BOF()) .or. EDD->(EOF()))
      If lCompNacion .And. Empty(WorkAnt->EDD_HAWB) .And. !Empty(WorkAnt->EDD_PO_NUM) .And. !Empty(WorkAnt->EDD_SEQMI)  // AAF - 23/09/2013
         ED4->(DbSetOrder(8))
         cSeek := xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + AvKey(WorkAnt->EDD_SEQMI,"ED4_SEQMI")
      Else
         ED4->(DbSetOrder(2))
         cSeek := xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + AvKey(WorkAnt->EDD_SEQSII,"ED4_SEQSIS")
      EndIf
      If (lCompNacion .And. !Empty(WorkAnt->EDD_SEQMI) .OR. !Empty(WorkAnt->EDD_SEQSII)) .AND. ED4->(DbSeek(cSeek))  // AAF - 23/09/2013
         If ED4->(RecLock("ED4",.F.))
            If ED4->(FieldPos("ED4_SNCMEX")) > 0  .And. ED4->(FieldPos("ED4_SQTDEX")) > 0 .And. (!Empty(WorkAnt->EDD_PREEMB) .Or. !Empty(WorkAnt->EDD_PEDIDO))
               If !Empty(EDD->EDD_PREEMB) .Or. !Empty(EDD->EDD_PEDIDO)
                  ED4->ED4_SNCMEX += ((EDD->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL) - (WorkAnt->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL))
                  ED4->ED4_SQTDEX +=  (EDD->EDD_QTD - WorkAnt->EDD_QTD)
               Else
                  ED4->ED4_SNCMEX -= WorkAnt->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL
                  ED4->ED4_SQTDEX -= WorkAnt->EDD_QTD
               EndIf
            EndIf
         ED4->(MsUnlock())
         EndIf
      EndIf


      EDD->(RecLock("EDD",.F.))
      FOR xi := 1 TO FCount()
         cCampo := FIELDNAME(xi)
         If EDD->(FieldPos(cCampo)) # 0
            EDD->&(cCampo) := WorkAnt->&(cCampo)
         EndIf
      NEXT xi
      EDD->(msUnlock())

   Else
      EDD->(RecLock("EDD",.T.))
      EDD->EDD_FILIAL := xFilial("EDD")
      FOR xi := 1 TO FCount()
         cCampo := FIELDNAME(xi)
         If EDD->(FieldPos(cCampo)) # 0
            EDD->&(cCampo) := WorkAnt->&(cCampo)
         EndIf
      NEXT xi

      If lCompNacion .And. Empty(WorkAnt->EDD_HAWB) .And. !Empty(WorkAnt->EDD_PO_NUM) .And. !Empty(WorkAnt->EDD_SEQMI)  // AAF - 23/09/2013
         ED4->(DbSetOrder(8))
         cSeek := xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + AvKey(WorkAnt->EDD_SEQMI,"ED4_SEQMI")
      Else
         ED4->(DbSetOrder(2))
         cSeek := xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + AvKey(WorkAnt->EDD_SEQSII,"ED4_SEQSIS")
      EndIf
      If (lCompNacion .And. !Empty(WorkAnt->EDD_SEQMI) .OR. !Empty(WorkAnt->EDD_SEQSII)) .AND. ED4->(DbSeek(cSeek))  // AAF - 23/09/2013
         If ED4->(RecLock("ED4",.F.))
            If ED4->(FieldPos("ED4_SNCMEX")) > 0  .And. ED4->(FieldPos("ED4_SQTDEX")) > 0 .And. (!Empty(EDD->EDD_PREEMB) .Or. !Empty(EDD->EDD_PEDIDO))
               ED4->ED4_SNCMEX -= EDD->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL
               ED4->ED4_SQTDEX -= EDD->EDD_QTD
            EndIf
         ED4->(MsUnlock())
         EndIf
      EndIf

      EDD->(msUnlock())
   EndIf

   /* WFS 13/nov/18
      Gravação de log migrada da função AE100Grava(). */
   If EDD->EDD_QTD < 0
      AELogAnt(cRegSiscomex)
   EndIf

   WorkAnt->(dbSkip())
EndDo

Return Nil


*--------------------------------------------------------------------------------------------*
Function RE400DELEDD()
*--------------------------------------------------------------------------------------------*
Local aItens := {} , nI := 0
Local cPedido := ""
Local cPreemb := ""
Local lED9_PEDIDO := ED9->(FieldPos("ED9_PEDIDO")) > 0
Private CFILEDD := xFilial("EDD")

//AOM - 19/12/2011
If lED9_PEDIDO  .And.  Empty(ED9->ED9_RE)
   cPedido := ED9->ED9_PEDIDO
   cPreemb := ""
Else
   cPedido := ""
   cPreemb := ED9->ED9_RE + ED9->ED9_POSICA
EndIf

DbSelectArea("EDD")
EDD->(DbSetOrder(3))
If EDD->(dbSeek(CFILEDD+AvKey((cPreemb),"EDD_PREEMB")+AvKey(cPedido,"EDD_PEDIDO")+AvKey(ED9->ED9_POSICA,"EDD_SEQUEN")+AvKey(ED9->ED9_PROD,"EDD_PROD")+AvKey(ED9->ED9_AC,"ED9_AC")+AvKey(ED9->ED9_SEQSIS,"ED9_SEQSIS")))
   ACDelAnt(CFILEDD+AvKey((cPreemb),"EDD_PREEMB")+AvKey(cPedido,"EDD_PEDIDO")+AvKey(ED9->ED9_POSICA,"EDD_SEQUEN")+AvKey(ED9->ED9_PROD,"EDD_PROD")+AvKey(ED9->ED9_AC,"ED9_AC")+AvKey(ED9->ED9_SEQSIS,"ED9_SEQSIS"))
Else

   If Len(aItens := IG400AllItens("E", ED9->ED9_PROD)) > 0
      For nI:=1 To Len(aItens)
         If EDD->(dbSeek(CFILEDD+AvKey((cPreemb),"EDD_PREEMB")+AvKey(cPedido,"EDD_PEDIDO")+AvKey(ED9->ED9_POSICA,"EDD_SEQUEN")+AvKey(aItens[nI][1],"EDD_PROD")+AvKey(ED9->ED9_AC,"ED9_AC")+AvKey(ED9->ED9_SEQSIS,"ED9_SEQSIS")))
            ACDelAnt(CFILEDD+AvKey((cPreemb),"EDD_PREEMB")+AvKey(cPedido,"EDD_PEDIDO")+AvKey(ED9->ED9_POSICA,"EDD_SEQUEN")+AvKey(aItens[nI][1],"EDD_PROD")+AvKey(ED9->ED9_AC,"ED9_AC")+AvKey(ED9->ED9_SEQSIS,"ED9_SEQSIS"))
         EndIf
      Next
   EndIf

EndIf


Return Nil



/*
Programa   : AltOnlyAc()
Objetivo   : Função chamada no When dos campos ED9, quando deseja-se
             alterar os registro e o ato esta preenchido.
Retorno    : Logico
Autor      : Felipe Sales Martinez
Data/Hora  : 05/10/2011
Obs.       :
*/
Function RE400AltOnlyAc()
Local lRet := .T.

Begin Sequence

   If Type("M->ED9_AC") # "U" .And. ALTERA .And. !Empty(M->ED9_AC)
      lRet := .F.
   EndIf

End Sequence

Return lRet

/*
Funcao     : MenuDef()
Parametros :
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      :
Data/Hora  : dez/2015
*/

Static Function MenuDef()
Local aRotina:= {{STR0002,"AxPesqui"  ,0,1},;//"Pesquisar"
                 {STR0003,"RE400Manut",0,2},; //"Visualizar"
                 {STR0004,"RE400Manut",0,3},;//"Incluir"
                 {STR0005,"RE400Manut",0,4},;//"Alterar"
                 {STR0006,"RE400Manut",0,5},;//"Excluir"
                 {STR0007,"RE400Compr",0,6}}//"Comp.Ato.Concess"
Return aRotina

/*
Funcao     : RE400ValCp()
Parametros : nOpc
Retorno    : .T. ou .F.
Objetivos  : Verificar preenchimento de campos não obrigatórios mas de preenchimento
             necessário.
Autor      : Nilson César
Data/Hora  : Ago/2019
*/
Static Function RE400ValCp(nOpc)
Local lRet := .T.

If nOpc == 3 .Or. nOpc == 4
   If Empty(M->ED9_RE)
      EasyHelp(  StrTran(STR0049,"####",AvSx3("ED9_RE",AV_TITULO)),"ED9_RE")   //"O Campo #### deve ser informado!"
      lRet := .F.
   EndIf
EndIf

Return lRet
