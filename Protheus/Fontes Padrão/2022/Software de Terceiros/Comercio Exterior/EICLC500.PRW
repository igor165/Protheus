#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "EICLC500.CH"

/*
Funcao      : EICLC500 -  REQ07
Parametros  : NENHUM
Retorno     : NENHUM
Objetivos   : Efetuar a rotina de contabilização
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     :
Obs.        :
*/
*-----------------*
Function EICLC500()
*-----------------*
LOCAL nI
PRIVATE cCadastro  := STR0001 //"Lançamento Contábil"
PRIVATE cMarca     := GetMark()
PRIVATE aRotina    := MenuDef()
PRIVATE aMarcados  :={}
PRIVATE aLotes     :={}
PRIVATE cExprFilTop:= " ECF_TPMODU = 'IMPORT' "
PRIVATE cFilAtual  :=cFilAnt //Quando clica em contabilizar deve ser executada a contabilizacao na filial atual, se o cursor tiver posicionado
//em outra filial (por o usuario ter acesso a varias filiais) ele considera ela como filial atual por isso devemos voltar para a filial atual

DBSELECTAREA('ECF')
//MarkBrow(cAlias,cCampo  ,cCpo,aCampo,lInvert,cMarca,cCtrlM,uPar8,cExpIni,cExpFim, cAval      , bParBloco,cExprFilTop, uPar14, aColors, uPar16, uPar17, uPar18, lShowAmb ] )
MarkBrow("ECF"   ,"ECF_OK",    ,      ,       ,cMarca,      ,     ,       ,       ,"CNTM_Des()",          ,cExprFilTop)

For nI:=1 to len(aMarcados) //Os campos de ECF_OK devem ser limpos AO SAIR
    ECF->(DBGOTO(aMarcados[nI][1]))
    IF SOFTLOCK('ECF')
       ECF->ECF_OK := SPACE(2)
       ECF->(MSUNLOCK())
    ENDIF
NEXT

Return Nil

/*
Funcao      : CNTM_Des()
Objetivos   : Marcar ou desmarcar um processo, adicionando os recnos em um array para posteriormente serem utlizados
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     :
Obs.        :
*/
*------------------------*
Function CNTM_Des()
*------------------------*
Local nPos    := ASCAN(aMarcados,{|x| x[1] == ECF->(RECNO())})
Local cChave  := ECF->ECF_FILIAL+ECF->ECF_TPMODU+ECF->ECF_NR_CON //Nao pode usar o xfilial() pq o usuario pode ter acesso a mais de uma filial pelo browse
Local lMarcar := !(ECF->ECF_OK == cMarca)
Local aSaveOrd:= SaveOrd("ECF")
Local oMark   := GetMarkBrow()

ECF->(DBSETORDER(4))//ECF_FILIAL+ECF_TPMODU+ECF_NR_CON+ECF_HAWB+ECF_FORN+ECF_IDENTC+ECF_ORIGEM
ECF->(DBSEEK(cChave))//Nao pode usar o xfilial() pq o usuario pode ter a cesso a mais de uma filial pelo browse
DO WHILE ECF->(!EOF()) .AND. cChave == ECF->ECF_FILIAL+ECF->ECF_TPMODU+ECF->ECF_NR_CON

   IF ECF->(DELETED())
      ECF->(DBSKIP())
      LOOP
   ENDIF

   nPos := ASCAN(aMarcados,{|x| x[1] == ECF->(RECNO())})

   IF lMarcar

      IF SOFTLOCK('ECF')
         ECF->ECF_OK := cMarca
         IF nPos == 0
            AADD(aMarcados,{ECF->(RECNO()),ECF->ECF_CONTAB,ECF->ECF_ID_CAM})
         ENDIF
         ECF->(MSUNLOCK())
      ENDIF

   ELSE

      IF SOFTLOCK('ECF')
         ECF->ECF_OK := SPACE(2)
         IF nPos <> 0
            ADEL(aMarcados,nPos)
            ASIZE(aMarcados,len(aMarcados)-1)
         ENDIF

         ECF->(MSUNLOCK())
      ENDIF

   ENDIF

   ECF->(DBSKIP())
ENDDO

RestOrd(aSaveOrd, .T.)
oMark:oBrowse:Refresh()//atualiza o browse

Return .t.


/*
Funcao      : L500MDES
Objetivos   : Marcar ou desmarcar todos os processos
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     :
Obs.        :
*/
*------------------------*
Function L500MDES()
*------------------------*
Local lMarcar := !(ECF->ECF_OK == cMarca)//Tem que ser antes do filtro
Local aSaveOrd:= SaveOrd("ECF")
Local oMark   := GetMarkBrow()
Local oFiltro := oMark:FWFILTER()
Local cFiltro := "",F
LOCAL nOldArea:= SELECT()
If (nTotFiltro := Len(oFiltro:ACHECKFIL)) > 1
    nAlgumAtivo:=0
    FOR F := 1 TO nTotFiltro
        IF oFiltro:ACHECKFIL[F]
           nAlgumAtivo++//conta pq tem um dos filtros fixo e nem sempre é o primeiro se o usuario gravar
        ENDIF
    NEXT
    IF nAlgumAtivo > 1//Se maior que 1, que é fixo, tem filro de usuario ativo
       cFiltro := oMark:OBROWSE:ODATA:AFILTRATE[1][2]   //recebe o conteúdo do filtro ATIVO DO USUARIO
    ENDIF
ENDIF
//ATESTE:=CLASSmetharray(oMark)
IF !EMPTY(cFiltro)
   cFiltro+=" .AND. ("+cExprFilTop+")"
   ECF->(dbSetFilter(&("{||"+cFiltro+"}"),cFiltro))
ENDIF
ECF->(DbGoTop())
DO WHILE ECF->(!EOF())

   IF ECF->(DELETED())
      ECF->(DBSKIP())
      LOOP
   ENDIF

   nPos:= ASCAN(aMarcados,{|x| x[1] == ECF->(RECNO())})
   IF lMarcar
      IF SOFTLOCK('ECF')
         ECF->ECF_OK := cMarca
         IF nPos == 0
            AADD(aMarcados,{ECF->(RECNO()),ECF->ECF_CONTAB,ECF->ECF_ID_CAM})
         ENDIF
         ECF->(MSUNLOCK())
      ENDIF
   ELSE
      IF SOFTLOCK('ECF')
         ECF->ECF_OK := SPACE(2)
         IF nPos <> 0
            ADEL(aMarcados,nPos)
            ASIZE(aMarcados,len(aMarcados)-1)
         ENDIF

         ECF->(MSUNLOCK())
      ENDIF
   ENDIF
   ECF->(DBSKIP())
ENDDO

DBSELECTAREA(nOldArea)
SET FILTER TO
RestOrd(aSaveOrd, .T.)
oMark:oBrowse:Refresh()//atualiza o browse

Return .t.
*------------------------*
Static Function MenuDef()
*------------------------*
Local aRotina := {}
//Adiciona os botões na MBROWSE
AADD(aRotina,{STR0002,"AxPesqui"  ,0,1})//"Pesquisar"
AADD(aRotina,{STR0003,"L500Visual",0,2})//"Visualizar"
AADD(aRotina,{STR0004,"L500CONTAB",0,3})//"Contabilizar"
AADD(aRotina,{STR0005,"L500CANCEL",0,4})//"Cancelar Contabiliazacao"
AADD(aRotina,{STR0006,"L500MDES"  ,0,4})//"Marca / desmarca todos"

Return AClone(aRotina)
/*
Funcao      : L500RET
Objetivos   : Retornar um valor da ECF, ou a proxima sequencia ou a flutuação de um registro
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     : wfs - mar/2017
            : acrescentado tratamento para itens sem cobertura cambial
Parametros  : 8º - lCoberturaCambial: .T. com cobertura/ .F. sem cobertura, default: .T.

Equivalências:
101 - 111
201 - 211
501 - 512
504 - 513
*/
*/
*----------------------------*
Function L500RET(cFIL,cTPMODU,cHAWB,cFORN,cIDENTC,cINVOIC,cTipo, lCoberturaCambial)
*----------------------------*
LOCAL cQuery   := ''
LOCAL cRet     := IF('SEQ'$ cTipo,'0001',1)
LOCAL cFilOld  := cFilAnt
LOCAL nOldArea := SELECT()
Default lCoberturaCambial:= .T.

cFilAnt:=cFIL
IF cTipo == 'NEXT_ECF_SEQ'
   cQuery += " SELECT MAX(ECF.ECF_SEQ) SEQ  FROM "+RETSQLNAME('ECF')+" ECF WHERE "+RetSqlCond("ECF")
ELSEIF cTipo == 'ECF_FLUTUA'
   cQuery += " SELECT MAX(R_E_C_N_O_)  REG  FROM "+RETSQLNAME('ECF')+" ECF WHERE "+RetSqlCond("ECF")
ENDIF

cQuery += " AND ECF_TPMODU ='"+cTpModu+"' "
cQuery += " AND ECF_HAWB   ='"+cHAwb  +"' "
cQuery += " AND ECF_FORN   ='"+cForn  +"' "
cQuery += " AND ECF_IDENTC ='"+cIdentc+"' "
cQuery += " AND ECF_INVOIC ='"+cInvoic+"' "

IF cTipo == 'ECF_FLUTUA'
   If lCoberturaCambial
      cQuery += " AND ECF_ID_CAM IN ('501','504','101')"
   Else
      cQuery += " AND ECF_ID_CAM IN ('512','513','111')"
   EndIf
ENDIF

IF SELECT('TEMP') <> 0
   TEMP->(DBCLOSEAREA())
ENDIF
cQuery := ChangeQuery(cQuery)
dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TEMP", .F., .F. )

TEMP->(DBGOTOP())
DO WHILE TEMP->(!EOF())
   IF cTipo == 'ECF_FLUTUA'
      ECF->(DBGOTO(TEMP->REG))
      cRet := ECF->ECF_PARIDA
   ELSEIF cTipo == 'NEXT_ECF_SEQ'
      cRet := STRZERO(VAL(TEMP->SEQ)+1,4)
   ENDIF

   EXIT
ENDDO
TEMP->(DBCLOSEAREA())
DBSELECTAREA(nOldArea)
cFilAnt := cFilOld

Return cRet


/*
Funcao      : L500CANCTB
Objetivos   : Cancelar uma contabilização se for do tipo 4- nao fazer nada/ 2-mudar para 3 e tentar integrar posteriormente/3-apenas integrar/1-enviar novo lançamento
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     :
Parametros  : array com os recnos dos ECFs que serao cancelados
*/

*-------------------------------------------------*
Function L500CANCTB(aCancela,lEnviaOK)//Essa funcao é sempre executada por lote
*-------------------------------------------------*
LOCAL nI        := 0
LOCAL aRegs     := {}
LOCAL aEnvia    := {}
LOCAL aEnvia999 := {}
LOCAL lOK       := .F.
PRIVATE aSeqInv := {}//USADO NA GerNewContab()
PRIVATE cLote   := ""//USADO NA GerNewContab()
DEFAULT lEnviaOK:= .T.//Se 1 dos envios, dentro da L500CANCTB(), deu erro, nem tenta enviar os ourtos só grava

EC6->(DBSETORDER(1))

For nI:=1 to len(aCancela)

   ECF->(DBGOTO(aCancela[nI]))

   IF ECF->(DELETED())
      LOOP
   ENDIF

   IF ECF->ECF_CONTAB == '4' //JA ESTA ESTORNADO NAO FAZER NADA
      LOOP
   ENDIF

   EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY(ECF->ECF_ID_CAM,'EC6_ID_CAM')))

   IF ECF->ECF_CONTAB == '2'  // EXCLUINDO EVENTO CONTÁBIL
      ECF->(MSUNLOCK())
      ECF->(RECLOCK('ECF',.F.))
      ECF->ECF_CONTAB := '3'
      ECF->(MSUNLOCK())
      IF EC6->EC6_CONTAB # '2' .AND. !EMPTY(ECF->ECF_LOTERP) .AND. !EMPTY(ECF->ECF_LANCAM)//Só envio para o estorno no logix o que tem lote erp
         IF ASCAN(aEnvia,ECF->(RECNO())) = 0
             AADD(aEnvia,ECF->(RECNO()))
         ENDIF
      ENDIF
      IF ASCAN(aRegs,ECF->(RECNO())) = 0
          AADD(aRegs,ECF->(RECNO()))
      ENDIF

   ELSEIF ECF->ECF_CONTAB == '3'  // EVENTO EXCLUÍDO PORÉM NAO ESTORNADO ERP
      IF EC6->EC6_CONTAB # '2' .AND. !EMPTY(ECF->ECF_LOTERP) .AND. !EMPTY(ECF->ECF_LANCAM)//Só envio para o estorno no logix o que tem lote erp
         IF ASCAN(aEnvia,ECF->(RECNO())) = 0
             AADD(aEnvia,ECF->(RECNO()))
         ENDIF
      ENDIF
      IF ASCAN(aRegs,ECF->(RECNO())) = 0
          AADD(aRegs,ECF->(RECNO()))
      ENDIF

   ELSEIF ECF->ECF_CONTAB == '1'  // período contábil encerrado
      ECF->(MSUNLOCK())
      ECF->(RECLOCK('ECF',.F.))
      ECF->ECF_CONTAB := '4'
      ECF->(MSUNLOCK())
      IF GerNewContab()
         IF ASCAN(aEnvia999,ECF->(RECNO())) = 0
             AADD(aEnvia999,ECF->(RECNO()))
         ENDIF
      ENDIF
   ENDIF
Next

IF ISINCALLSTACK('EICLC500') .OR. EasyGParam('MV_EIC0048',,.F.)//Se vem da manutencao contab senao (vem da NF ou Emb) só se MV_EIC0048 = .T.

   IF len(aEnvia999) <> 0 .AND. EasyGParam("MV_EIC_EAI",,.F.) .AND. lEnviaOK//Se 1 dos envios deu erro nem tenta enviar os ourtos só grava
      lEnviaOK := EICLC510(aEnvia999,3)//************** ENVIANDO UPSERT
      aRegs:={}//Nos lotes que geram 999 nao deleta nada
   ENDIF

   IF len(aEnvia) <> 0 .AND. EasyGParam("MV_EIC_EAI",,.F.) .AND. lEnviaOK//Se 1 dos envios deu erro nem tenta enviar os ourtos só grava
      lOK := EICLC510(aEnvia,5)//***************** ENVIANDO DELETE
      lEnviaOK := lOK//Se for falso nao tenta mais enviar
   ENDIF

ENDIF

IF LEN(aEnvia) = 0//Se todos os no. de ERP tiver em branco do lote é só deletar
   lOK:=.T.
ENDIF

IF lOK//deletandos registros fisicos se envio deu ok ou se todos os no. de ERP tiver em branco
   For nI:=1 to len(aRegs)
      ECF->(DBGOTO(aRegs[nI]))
      ECF->(MSUNLOCK())
      ECF->(RECLOCK('ECF',.F.))
      ECF->(DBDELETE())
      ECF->(MSUNLOCK())
   Next
ENDIF

Return .T.
/*
Funcao      : L500CONTAB()
Objetivos   : Realizar contabilização independente de quais registros estao marcados
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     :
Parametros  :
*/
*----------------------*
FUNCTION L500CONTAB()
*----------------------*
LOCAL cMsg:=STR0007+; //"Esta rotina é utilizada para gerar lançamentos contábeis de variação cambial "
            STR0008+; //"referente a todos processos de importação cadastrados no sistema que estão em "
            STR0009+; //"trânsito, ou seja, embarcados e ainda não recebidos (sem nota fiscal de entrada), "
            STR0010   //"efetivar os lançamentos contábeis ocorridos e integrar lote de lançamentos contábeis com o ERP. Deseja continuar?"

Local oUpd //THTS - 28/07/2017

PRIVATE dDtLanca  := CTOD('//')
PRIVATE lEfetDtEv := .F.
PRIVATE nDecimais := AVSX3("W9_FOB_TOT",4)//VARIÁVEL UTILIZADA NO DI500TRANS, DENTRO DO DI500RETVAL
PRIVATE lEfetiva  := .F.

cFilAnt := cFilAtual//Quando clica em contabilizar deve ser executada a contabilizacao na filial atual, se o cursor tiver posicionado
//em outra filial (por o usuario ter acesso a varias filiais) ele considera ela como filial atual por isso devemos voltar para a filial atual

IF EasyGParam('MV_EIC_ECO',,.F.) == 'S' .OR. !EasyGParam('MV_EIC0047',,.F.)
   MSGINFO(STR0011,STR0012) //"Ambiente não configurado para controle de lançamentos contábeis no módulo de importação"###"Atenção"
   RETURN .F.
ENDIF

IF !MSGYESNO(cMsg)
   RETURN .F.
ENDIF

//THTS - 28/07/2017
If FindFunction("AvUpdate01")
    oUpd := AVUpdate01():New()
    oUpd:aChamados := {{nModulo,{|o| UPDX1LC500(o)}}}
    oUpd:Init(,.T.)
EndIf

IF !Pergunte("EICLC500",.t.)
   RETURN .F.
ENDIF

//"Data da contabilizacao?" - 01
IF !EMPTY(MV_PAR01)
   dDtLanca := MV_PAR01
ENDIF

//GERAR INICIO DE TRANSITO SEGUNDO PERGUNTE - 02
IF MV_PAR02 == 1
   GerIniTran()//101
ENDIF

//GERAR FIM DE TRANSITO TERCEIRO PERGUNTE   - 03
IF MV_PAR03 == 1
   GerFimTran()//201
ENDIF

//VARIACAO CAMBIAL - 04
IF MV_PAR04 == 1
   PesqVarCamb()
ENDIF

PRIVATE lEfetivado:=.F.

IF MV_PAR07 == 1      //NCF - 08/12/2016 - Verificar Variável ants de entrad na integração
   lEfetDtEv := .T.
ENDIF
//INTEGRAR LANCAMENTOS PENDENTES QUINTO PERGUNTE  - 05
IF MV_PAR05 == 1 .AND. EasyGParam("MV_EIC_EAI",,.F.)
   IF MV_PAR06 == 1//"Efetivar lancamentos?" - 06 //Ja aproveita e ja efetiva os enviados com sucesso
      lEfetiva := .T.
   ENDIF
   IntLanca()
ENDIF

//"Efetivar lancamentos?" - 06
IF MV_PAR06 == 1
   EfetLanca()
ENDIF

RETURN.T.

/*
Funcao      : GERINITRAN()
Objetivos   : Gerar contabilizacao de inicio de transito para todos os processos que tiverem data de embarque preenchida e nao tiverem contabilizacao do tipo 101
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     : WFS - mar/2017
              Tratamento para processos com e sem cobertura cambial
              Equivalência:
              101 - 111
Parametros  :
*/
*---------------------------*
STATIC FUNCTION GERINITRAN()
*---------------------------*
Local cQry     :=""
LOCAL nOldArea := SELECT()
cQry+= " SELECT R_E_C_N_O_ REG FROM "+RETSQLNAME('SW6')+" SW6 WHERE "+RetSqlCond("SW6")+" AND W6_DT_EMB <> ''"
cQry+= " AND W6_HAWB NOT IN"
cQry+= " (SELECT ECF.ECF_HAWB  FROM "+RETSQLNAME('ECF')+" ECF WHERE "+RetSqlCond("ECF")+" AND (ECF_ID_CAM = '101' Or ECF_ID_CAM = '111') AND ECF_CONTAB <> '4')"

IF SELECT('TRAN') <> 0
   TRAN->(DBCLOSEAREA())
ENDIF
cQry := ChangeQuery(cQry)
dbUseArea( .t., "TopConn", TCGenQry(,,cQry),"TRAN", .F., .F. )

TRAN->(DBGOTOP())
DO WHILE TRAN->(!EOF())
   SW6->(DBGOTO(TRAN->REG))
   L500GERCTB('TM')
   TRAN->(DBSKIP())
ENDDO
TRAN->(DBCLOSEAREA())
DBSELECTAREA(nOldArea)
Return .T.


/*
Funcao      : GERFIMTRAN()
Objetivos   : Gerar contabilizacao de fim de transito para todos os processos que tiverem data de embarque e
              nota fiscal preenchida e nao tiverem contabilizacao do tipo 201
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     : WFS - mar/2017
              Tratamento para processos com e sem cobertura cambial
              Equivalência:
              201 - 211
Parametros  :
*/
*---------------------------*
STATIC FUNCTION GERFIMTRAN()
*---------------------------*
Local cQry     :=""
LOCAL nOldArea := SELECT()
cQry+= " SELECT R_E_C_N_O_ REG FROM "+RETSQLNAME('SW6')+" SW6 WHERE "+RetSqlCond("SW6")+" AND W6_DT_EMB <> '' AND W6_DT_NF <> ''"
cQry+= " AND W6_HAWB NOT IN"
cQry+= " (SELECT ECF.ECF_HAWB  FROM "+RETSQLNAME('ECF')+" ECF WHERE "+RetSqlCond("ECF")+" AND (ECF_ID_CAM = '201' Or ECF_ID_CAM = '211') AND ECF_CONTAB <> '4')"//"ECF_CONTAB" ,"1=Sim;2=Nao;3=Sol.Canc.;4=Cancelado"

IF SELECT('FTRAN') <> 0
   FTRAN->(DBCLOSEAREA())
ENDIF
cQry := ChangeQuery(cQry)
dbUseArea( .t., "TopConn", TCGenQry(,,cQry),"FTRAN", .F., .F. )

FTRAN->(DBGOTOP())
DO WHILE FTRAN->(!EOF())
   SW6->(DBGOTO(FTRAN->REG))
   GERVAR_TRA('TM')
   FTRAN->(DBSKIP())
ENDDO
FTRAN->(DBCLOSEAREA())
DBSELECTAREA(nOldArea)
Return .T.

/*
Funcao      : IntLanca()
Objetivos   : Enviar ao ERP todas contabilizacoes que nao tiverem LOTEERP e RELACA preenchidos, enviar por lote
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     :
Parametros  :
*/
*---------------------------*
STATIC FUNCTION IntLanca()
*---------------------------*
Local cQry       := ""
Local nI,lEnviOK := .T.
Local aRegs      :={}
LOCAL nOldArea   := SELECT()
cQry+= " SELECT R_E_C_N_O_ REG,ECF_NR_CON FROM "+RETSQLNAME('ECF')+" ECF  WHERE "+RetSqlCond("ECF")
cQry+= " AND ECF_LOTERP = '' AND ECF_RELACA = '' AND ECF_CONTAB IN ('1','2') "//"ECF_CONTAB" ,"1=Sim;2=Nao;3=Sol.Canc.;4=Cancelado"
cQry+= " ORDER BY ECF_NR_CON"
IF SELECT('LACAN') <> 0
   LACAN->(DBCLOSEAREA())
ENDIF
cQry := ChangeQuery(cQry)
dbUseArea( .t., "TopConn", TCGenQry(,,cQry),"LACAN", .F., .F. )

LACAN->(DBGOTOP())
cLote   := ''
lPrivez := .t.
DO WHILE LACAN->(!EOF())

   ECF->(DBGOTO(LACAN->REG))

   IF lPriVez
      cLote   := ECF->ECF_NR_CON
      lPrivez := .F.
   ENDIF
   IF cLote <>  ECF->ECF_NR_CON

      IF LEN(aRegs) <> 0
         ECF->(DBGOTO(aRegs[1]))
         IF lEnviOK .AND. (lEnviOK:=EICLC510(aRegs,3)) .AND. lEfetiva//SE DEU CERTO INTERACAO E É PARA EFETIVAR LANCAMENTOS
            For nI:=1 to len(aRegs)
               ECF->(DBGOTO(aRegs[nI]))
               IF ECF->ECF_CONTAB == '2'
                  ECF->(MSUNLOCK())
                  ECF->(RECLOCK('ECF',.F.))
                  ECF->ECF_CONTAB := '1'
                  ECF->(MSUNLOCK())
                  lEfetivado := .T.
               ENDIF
            Next
          ENDIF
      ENDIF
      //REPOSICIONANDO NO LOTE QUE ESTAVA NO LOOP
      ECF->(DBGOTO(LACAN->REG))
      cLote  := ECF->ECF_NR_CON
      aRegs  := {}

   ENDIF

   IF ASCAN(aRegs,ECF->(RECNO())) == 0
       AADD(aRegs,ECF->(RECNO()))
   ENDIF

   LACAN->(DBSKIP())
ENDDO
LACAN->(DBCLOSEAREA())
DBSELECTAREA(nOldArea)
IF LEN(aRegs)<> 0
   ECF->(DBGOTO(aRegs[1]))
   IF lEnviOK .AND. (lEnviOK:=EICLC510(aRegs,3)) .AND. lEfetiva //SE DEU CERTO INTERACAO E É PARA EFETIVAR LANCAMENTOS
      For nI:=1 to len(aRegs)
         ECF->(DBGOTO(aRegs[nI]))
         IF ECF->ECF_CONTAB == '2'
            ECF->(MSUNLOCK())
            ECF->(RECLOCK('ECF',.F.))
            ECF->ECF_CONTAB := '1'
            ECF->(MSUNLOCK())
            lEfetivado := .T.
         ENDIF
     Next
   ENDIF
ENDIF

//IF lEfetivado
//   MSGINFO("Lançamentos contáveis efetivados com sucesso.","Atenção")
//ENDIF

Return .T.

*---------------------------*
STATIC FUNCTION EfetLanca()//AWF - 22/08/2014 - "Efetivar lancamentos?" - 06
*---------------------------*
Local cQry       := ""

cQry+= " SELECT R_E_C_N_O_ REG,ECF_NR_CON FROM "+RETSQLNAME('ECF')+" ECF  WHERE "+RetSqlCond("ECF")
cQry+= " AND ECF_LOTERP <> '' AND ECF_CONTAB = '2' "//"ECF_CONTAB" ,"1=Sim;2=Nao;3=Sol.Canc.;4=Cancelado"
cQry+= " ORDER BY ECF_NR_CON"

IF SELECT('LACAN') <> 0
   LACAN->(DBCLOSEAREA())
ENDIF
cQry := ChangeQuery(cQry)
dbUseArea( .t., "TopConn", TCGenQry(,,cQry),"LACAN", .F., .F. )

LACAN->(DBGOTOP())

DO WHILE LACAN->(!EOF())

   ECF->(DBGOTO(LACAN->REG))
   IF ECF->(DELETED())
      LACAN->(DBSKIP())
      LOOP
   ENDIF

   ECF->(RECLOCK('ECF',.F.))
   ECF->ECF_CONTAB := '1'
   ECF->(MSUNLOCK())
   lEfetivado := .T.

   LACAN->(DBSKIP())
ENDDO

IF lEfetivado
   MSGINFO(STR0013+; //"Lançamentos Contabeis efetivados com sucesso. "
           STR0014+; //"Não será possível excluir os lançamentos efetivados. "
           STR0015,STR0012) //"Caso necessário reverte-los, serão gerados novos lançamentos contábeis de estorno."###"Atenção"
ENDIF

Return .T.

/*
Funcao      : L500CANCEL()
Objetivos   : Efetuar o cancelamento das contabilizações
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     :
Parametros  :
*/
*----------------------*
FUNCTION L500CANCEL()
*----------------------*
Local aRegs:={}
Local nI

IF EasyGParam('MV_EIC_ECO',,.F.) == 'S' .OR. !EasyGParam('MV_EIC0047',,.F.)
   MSGINFO(STR0011,STR0012) //"Ambiente não configurado para controle de lançamentos contábeis no módulo de importação"###"Atenção"
   RETURN .F.
ELSEIF LEN(aMarcados) == 0
   MSGINFO(STR0016,STR0012) //"É necessário selecionar os lotes contábeis a serem cancelados"###"Atenção"
   RETURN .F.
ENDIF

ECF->(DBSETORDER(4))//ECF_FILIAL+ECF_TPMODU+ECF_NR_CON+ECF_HAWB+ECF_FORN+ECF_IDENTC+ECF_ORIGEM
aLotes:={}
For nI:=1 to len(aMarcados)

    ECF->(DBGOTO(aMarcados[nI][1]))
    cChave:= ECF->ECF_FILIAL+ECF->ECF_TPMODU+ECF->ECF_NR_CON //Nao pode usar o xfilial() pq o usuario pode ter acesso a mais de uma filial pelo browse

    IF ASCAN(aLotes,{|C| C[1] == cChave}) = 0
       AADD(aLotes,{ cChave, {} })
    ELSE
       LOOP
    ENDIF

    ECF->(DBSEEK(cChave)) //Nao pode usar o xfilial() pq o usuario pode ter a cesso a mais de uma filial pelo browse

    aRegs:={}
    DO WHILE ECF->(!EOF()) .AND. cChave == ECF->ECF_FILIAL+ECF->ECF_TPMODU+ECF->ECF_NR_CON

       IF ECF->(DELETED())
          ECF->(DBSKIP())
          LOOP
       ENDIF

       IF ECF->ECF_CONTAB $ '4' .OR. ECF->ECF_ID_CAM == '999'//AWF - 20/08/2014 - '3,4' - Alteracao de definicao
          ECF->(DBSKIP())
          LOOP
       ENDIF

       IF ASCAN(aRegs,ECF->(RECNO()) ) = 0
          AADD (aRegs,ECF->(RECNO()) )
       ENDIF

       IF ASCAN(aMarcados,{|x| x[1] = ECF->(RECNO()) }) = 0
          AADD(aMarcados,{ECF->(RECNO()),ECF->ECF_CONTAB,ECF->ECF_ID_CAM})//Para validar abaixo as nova linhas do lote
       ENDIF

       ECF->(DBSKIP())
    ENDDO
    aLotes[LEN(aLotes),2] := ACLONE(aRegs)//Guardo os recnos por lote

NExt
ECF->(DBSETORDER(1))

IF ASCAN(aMarcados,{|x| x[2] $ '4' .OR. ALLTRIM(x[3]) == '999'}) <> 0 //AWF - 20/08/2014 - '3,4' - Alteracao de definicao
   MSGINFO(STR0017,STR0012) //"Não é possível estornar um lote contábil já cancelado."###"Atenção"
   RETURN .F.
ELSEIF ASCAN(aMarcados,{|x| x[2] == '1'}) <> 0  .AND.;
       !MSGYESNO(STR0018+; //"Existem lotes de contabilização que já possuem efetivação, cancelar irá gerar novamente um novo lote contábil com lançamentos de estorno."
                 STR0019) //"Tem certeza que deseja continuar?"
   RETURN .F.
ELSEIF ASCAN(aMarcados,{|x| x[2] == '1'}) ==  0  .AND.;
       !MSGYESNO(STR0020) //"Estes lotes de contabilização ainda não estão efetivados e serão excluídos. Deseja continuar?"
   RETURN .F.
ENDIF
PRIVATE lEnviaOK:=.T.//Se 1 dos envios, dentro da L500CANCTB() deu erro, nem tenta enviar os ourtos só grava
For NI:=1 to len(aLotes)//Tem que fazer os envios por lote
    aRegs := aLotes[NI,2]
    IF LEN(aRegs) <> 0
       L500CANCTB(aRegs)
    ENDIF
NEXT

For nI:=1 to len(aMarcados) //Os campos de ECF_OK devem ser limpos AO SAIR
    ECF->(DBGOTO(aMarcados[nI][1]))
    IF SOFTLOCK('ECF')
       ECF->ECF_OK := SPACE(2)
       ECF->(MSUNLOCK())
    ENDIF
NEXT

aMarcados:={}

RETURN .T.



/*
Funcao      : L500GERCTB
Objetivos   : Gerar contabilizacao do tipo 101
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     : WFS - mar/2017
              Tratamento para processos com e sem cobertura cambial
              Equivalência:
              101 - 111
              201 - 211
              501 - 512
              504 - 513
Parametros  : cOrigem = TE quando vem do eicdi500 ou TM quando vem do inicio de transito pergunte MV_PAR02 == 1
Obs         : O aValores terá o recno dos registros dos SW9 que serão gravados, porém as vezes uma invoice poderá estar quebrada por centro de custo, nesse caso o aValores terá 4 posições
*/
*----------------------------*
Function L500GERCTB(cOrigem)
*----------------------------*
LOCAL  aValores :={}
LOCAL  lComEAI  := EasyGParam("MV_EIC_EAI",,.F.)
LOCAL  LoK      := .F.
Local aOrd      := SaveOrd({"ECF","EC6"})
Local nI
PRIVATE cLote   := ""

IF TYPE("lChangeEmb") <> 'L' //pode ser chamada fora do embarque logo nao vai existir essa variavel
   lChangeEmb:=.T.
ENDIF

SW9->(DBSETORDER(3))
SW9->(DBSEEK(XFILIAL('SW9')+SW6->W6_HAWB))
bCond:= {|| XFILIAL('SW9')+SW6->W6_HAWB == SW9->W9_FILIAL+SW9->W9_HAWB}

ECF->(DBSETORDER(1))
EC6->(DBSETORDER(1))

//IF !EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY("101",'EC6_ID_CAM'))) //comentado por wfs
IF !EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY("101",'EC6_ID_CAM'))) .Or. !EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY("111",'EC6_ID_CAM')))
   lChangeEmb:=.F.
ENDIF

DO WHILE SW9->(!EOF()) .AND. EVAL(bCond) .AND. lChangeEmb

      aValCC   := LC500RatCC(xfilial('SW9'),SW9->W9_HAWB,SW9->W9_FORN,SW9->W9_INVOICE,AVSX3('ECF_VALOR',4))

      nValMoe  := DI500RetVal("TOT_INV", "TAB", .T., .F. )
      nValReais:= nValMoe * BuscaTaxa(SW9->W9_MOE_FOB,SW6->W6_DT_EMB, , .F.,,,EC6->EC6_TXCV) //DI500RetVal("TOT_INV", "TAB", .T., .T. )
      aValReais:= LC500RatCC(xfilial('SW9'),SW9->W9_HAWB,SW9->W9_FORN,SW9->W9_INVOICE,AVSX3('ECF_VALOR',4),nValReais,aValCC,nValMoe)

      IF LEN(aValCC)>0
         For nI:=1 to len(aValCC)
            AADD(aValores,{SW9->(RECNO())  ,;//RECNO DO SW9 - 1
                           aValCC[nI][2]   ,;//VALOR NA MOEDA DA INVOICE - 2
                           aValCC[nI][1]   ,;//CC DO LOGIX - 3
                           aValReais[nI][2]})//VALOR EM REAIS DA INVOICE - 4 - A array aValReais tem as mesmas dimensoes da aValCC
         Next
      ENDIF


   SW9->(DBSKIP())
ENDDO

IF Len(aValores) <> 0
   LOK :=.T.
ENDIF

IF LOK
   L500GRVCTB(aValores,cOrigem)
ENDIF

RestOrd(aOrd,.t.)

RETURN LoK

/*
Funcao      : L500GRVCTB
Objetivos   : Gerar contabilizacao do tipo 101
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     : WFS - mar/2017
              Diferenciar eventos contábeis para processos com e sem cobertura cambial
              Equivalência:
              101 - 111
              201 - 211
              501 - 512
              504 - 513
Parametros  : aValores array de invoices, terá 2 posições quando nao for integrado com ERP e 4 quando for, essa uma a mais irá guardar os centro de custos
              cOrigem = TE quando vier do eicdi500 TM quando vier da tela de contabilização
*/
*----------------------------*
Function L500GRVCTB(aValores,cOrigem)
*----------------------------*
LOCAL nI               := 0
LOCAL cSeq             := ''
LOCAL aInvoice         := {}
LOCAL aRegs            := {}
Local lCobCambial      := .T.
Local cEventInicioTrans:= ""
DEFAULT cOrigem        := 'TE'

ECF->(DBSETORDER(1))
EC6->(DBSETORDER(1))


For nI:=1 to len(aValores)

   IF aValores[nI][2] == 0 //NAO GRAVAR VALORES VAZIOS
      LOOP
   ENDIF

   IF EMPTY(cLote)
      cLote:= GetSXENUM('ECF','ECF_NR_CON')
      CONFIRMSX8()
   ENDIF

   SW9->(DBGOTO(aValores[nI][1]))
   lCobCambial:= TemCoberturaCambial(SW9->W9_COND_PA + Str(SW9->W9_DIAS_PA, 3, 0))
   If lCobCambial
      cEventInicioTrans:= "101"
   Else
      cEventInicioTrans:= "111"
   EndIf

   //sequencia deve ser por invoice
   IF ASCAN(aInvoice,SW9->W9_INVOICE+SW9->W9_FORN) == 0
      AADD(aInvoice,SW9->W9_INVOICE+SW9->W9_FORN)
      cSeq := L500RET(xFilial('ECF'),"IMPORT",SW6->W6_HAWB,SW9->W9_FORN,'',SW9->W9_INVOICE,'NEXT_ECF_SEQ', lCobCambial)
   ENDIF

   ECF->(RECLOCK('ECF',.T.))
   ECF->ECF_FILIAL  := xFilial("ECF")
   ECF->ECF_TPMODU  := "IMPORT"
   ECF->ECF_HAWB    := SW6->W6_HAWB
   ECF->ECF_FORN    := SW9->W9_FORN
   ECF->ECF_ORIGEM  := cOrigem
   ECF->ECF_INVOIC  := SW9->W9_INVOICE
   ECF->ECF_DI_NUM  := SW6->W6_DI_NUM
   ECF->ECF_ID_CAM  := cEventInicioTrans //"101"
   ECF->ECF_SEQ     := cSeq
   ECF->ECF_DTCONT  := SW6->W6_DT_EMB
   ECF->ECF_MOEDA   := SW9->W9_MOE_FOB

   EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY(cEventInicioTrans/*"101"*/,'EC6_ID_CAM')))

   IF LEN(aValores[nI]) = 4//lComEAI
      ECF->ECF_PARIDA  := BuscaTaxa(SW9->W9_MOE_FOB,SW6->W6_DT_EMB, , .F.,,,EC6->EC6_TXCV)//aValores[nI][4] / aValores[nI][2]
      ECF->ECF_VL_MOE  := aValores[nI][2]//NA MOEDA
      ECF->ECF_CC      := aValores[nI][3]//CC DO LOGIX
      ECF->ECF_VALOR   := aValores[nI][4]//aValores[nI][2]  * ECF->ECF_PARIDA// EM REAIS
   ELSE//!lComEAI
      ECF->ECF_PARIDA  := BuscaTaxa (ECF->ECF_MOEDA ,ECF->ECF_DTCONT, , .F.,,,EC6->EC6_TXCV)
      ECF->ECF_VL_MOE  := aValores[nI][2]
      ECF->ECF_VALOR   := aValores[nI][2] * ECF->ECF_PARIDA
   ENDIF

   ECF->ECF_DESCR   := EC6->EC6_DESC
   ECF->ECF_CTA_CR  := EasyMascCon(EC6->EC6_CTA_CR,SW9->W9_FORN,SW9->W9_FORLOJ,"","","","","","","",,SW9->W9_INCOTER) //THTS - 01/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm 
   ECF->ECF_CTA_DB  := EasyMascCon(EC6->EC6_CTA_DB,SW9->W9_FORN,SW9->W9_FORLOJ,"","","","","","","",,SW9->W9_INCOTER) //THTS - 01/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm 
   ECF->ECF_CONTAB  := "2"
   ECF->ECF_NR_CON  := cLote
   ECF->(MSUNLOCK())
// ECF->(DBCOMMIT())
   IF ASCAN(aRegs,ECF->(RECNO())) == 0
      AADD(aRegs,ECF->(RECNO()))
   ENDIF
Next

IF !ISINCALLSTACK('EICLC500') //CONTABILIZACAO NAO ENVIA NESSE MOMENTO POIS VAI ENVIAR POSTERIORMENTE
   EC6->(DBSETORDER(1))
   IF EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY(cEventInicioTrans/*"101"*/,'EC6_ID_CAM'))) .AND. EC6->EC6_CONTAB <> '2'; // ENVIAR AO ERP
                                                                                           .AND. EasyGParam('MV_EIC0048',,.F.);
                                                                                           .AND. EasyGParam("MV_EIC_EAI",,.F.)
      EICLC510(aRegs,3)
   ENDIF
ENDIF


Return .T.


/*
FUNCAO  : LC500RATCC
AUTOR   : igor chiba
DATA    :
Objetivo: se nao for passado o quinto parametro retornar um array com os valoresna moeda de uma invoice por centro de custo
          se for passado o quinto parametro, irá ratear este valor passado utilizando o array anterior como coeficiente, quando vem proveniente
          eicdi500 e do eicdi154 e 554 foi passado o valor total da invoice em reais
PARAMETRO: nvalRat, valor que será rateado, aValcc, array que já possui os coeficientes de cada CC, nTotCC, valor total da array com os CC , clOja do fornecedor
REVISAO: Jacomo Lisa - 01/07/2014 - Inclusão do parametro cFase e da validação de onde veio o rateio (lFase = PO ou DI)
RETORNO
*/
*---------------------------*
FUNCTION LC500RatCC(cFil,cHAwb,cForn,cInvo,nQtDec,nValRat,aValCC,nTotCC,cFase,cLoja)
*---------------------------*
Local aSIVal   :={}
Local aCCVal   :={}
Local aRet     :={}
Local nI,nX
DEFAULT nTotCC := 0
DEFAULT nQtDec := AVSX3('ECF_VALOR',4)
DEFAULT nValRat:= 0
DEFAULT cFase  := "SW8"
DEFAULT cLoja  := '.'
DEFAULT cFil   := xFilial("SW8")
DEFAULT cHAwb  := ""
DEFAULT cForn  := ""
DEFAULT cInvo  := ""
cLoja := AVKEY(cLoja,'W8_FORLOJ')//AWF - 18/08/2014

//SEGUNDA CHAMADA
//QUADO FOR PASSADO ESTE VALOR DEVE HAVER O ARRAY DE aValCC com os valores da primeira chamada da funcao  LC500RatCC
IF nValRat <> 0
   IF VALTYPE(aValCC) == 'A' .AND. LEN(aValCC) <> 0  //AWF - 18/08/2014 - Se nValRat <> 0 e array LEN(aValCC) = 0 deve devolver aRet:={}
      oRateio:=EasyRateio():New(nValRat,nTotCC,LEN(aValCC),nQtDec)// INSTANCIANDO METODO PARA RATEAR VALOR DE CADA SI POR PORCENTAGEM
      For nI:=1 to len(aValCC)
         nValor:=oRateio:GetItemRateio(aValCC[nI][2])
         AADD(aRet,{aValCC[nI][1],nValor})
      Next
   ENDIF
   Return aRet//neste ponto iremos retornar um array com 2 posicoes 1=CC 2= VALOR RATEADO
ENDIF

SW7->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SYS->(DBSETORDER(1))
SW3->(DBSETORDER(1))

//PRIMEIRA CHAMADA
nTotCC:=0
IF cFase == "SW8" //SOMANDO INVOICE POR SI DOS ITENS DA INVOICE OU ITENS DO PROCESSO
   //PEGAR TODAS INVOICES
   IF EMPTY(cInvo+cForn)
      SW8->(DBSEEK(cFil+cHawb))
      bInvoice :={|| .T.}
   ELSE
      SW8->(DBSEEK(cFil+cHawb+cInvo+cForn+cLoja))
      bInvoice :={||  SW8->W8_INVOICE == cInvo .AND. SW8->W8_FORN == cForn .AND. SW8->W8_FORLOJ == cLoja}
   ENDIF
   DO WHILE SW8->(!EOF()) .AND. SW8->W8_FILIAL  == cFil;
                          .AND. SW8->W8_HAWB    == cHawb;
                          .AND. EVAL(bInvoice)

      IF (nPos:=ASCAN(aSIVal,{|X| X[1] == SW8->W8_SI_NUM })) == 0
         AADD(aSIVal,{SW8->W8_SI_NUM,DI500RetVal("ITEM_INV", "TAB", .T., .F.)})
      ELSE
         aSIVal[nPos][2]+=DI500RetVal("ITEM_INV", "TAB", .T., .F.)
      ENDIF
      nTotCC+=DI500RetVal("ITEM_INV", "TAB", .T., .F.)
      SW8->(DBSKIP())
   ENDDO

ELSEIF cFase == "SW3" // VEIO DO PEDIDO
   SW3->(DBSEEK(cFil+cHawb))
   DO WHILE SW3->(!EOF()) .AND. SW3->W3_FILIAL  == cFil;
                          .AND. SW3->W3_PO_NUM  == cHawb
      IF (SW3->W3_SEQ <> 0)//.OR. (SW3->W3_FORN <> cForn )
         SW3->(DBSKIP())
         LOOP
      ENDIF

      IF (nPos:=ASCAN(aSIVal,{|X| X[1] == SW3->W3_SI_NUM })) == 0
         AADD(aSIVal,{SW3->W3_SI_NUM, SW3->W3_QTDE * SW3->W3_PRECO })
      ELSE
         aSIVal[nPos][2]+= SW3->W3_QTDE * SW3->W3_PRECO
      ENDIF
      nTotCC+=SW3->W3_QTDE * SW3->W3_PRECO

      SW3->(DBSKIP())
   ENDDO

ELSEIF cFase == 'SW7'//VEIO DO EMBARQUE
   SW7->(DBSEEK(cFil+cHawb))
   DO WHILE SW7->(!EOF()) .AND. SW7->W7_FILIAL  == cFil;
                             .AND. SW7->W7_HAWB    == cHawb

      IF (nPos:=ASCAN(aSIVal,{|X| X[1] == SW7->W7_SI_NUM })) == 0
         AADD(aSIVal,{SW7->W7_SI_NUM, SW7->W7_PRECO * SW7->W7_QTDE })
      ELSE
         aSIVal[nPos][2]+=SW7->W7_PRECO * SW7->W7_QTDE
      ENDIF
      nTotCC+=SW7->W7_PRECO * SW7->W7_QTDE
      SW7->(DBSKIP())
   ENDDO

ENDIF

//QUEBRANDO AS SIs por centro de custo da SYS nessa etapa o aSIVAL não terá SIs repetidas
For nI:=1 to len(aSIVal)
   IF !EasyGParam("MV_EIC_EAI",,.F.) .OR. !SYS->(DBSEEK(xFilial("SYS")+"I"+"S"+AVKEY(aSIVal[nI][1],"YS_HAWB")))//NO CAMPO YS_HAWB ESTA SENDO GRAVADO A SI
      //Return aRet
      aAdd(aCCVAl,{aSIVal[nI][1],{{AvKey("","YS_CC"),100,0}}}) //Não ha reteio por centro de custo. Retorna o valor total para centro de custo em branco.
   Else
      DO WHILE SYS->(!EOF()) .AND. SYS->YS_FILIAL == xFilial("SYS") ;
                             .AND. SYS->YS_HAWB   == AVKEY(aSIVal[nI][1],"YS_HAWB"); //NO CAMPO YS_HAWB ESTA SENDO GRAVADO A SI
                             .AND. SYS->YS_TPMODU == "I";
                             .AND. SYS->YS_TIPO   == "S"

         //1=SI  2= {1= CC  2=% SYS  3=VALOR QUE SERA CALCULADO POSTERIORMENTE}
         IF (nPos:=ASCAN(aCCVAl,{|x| x[1] == aSIVal[nI][1]})) == 0
            AADD(aCCVal,{aSIVal[nI][1],{{SYS->YS_CC, SYS->YS_PERC,0}}})
         ELSE
            AADD(aCCVal[nPos][2],{SYS->YS_CC,SYS->YS_PERC,0})
         ENDIF

         SYS->(DBSKIP())
      EndDo
   EndIf

   oRateio:=EasyRateio():New(aSIVal[nI][2],100,LEN(aCCVal[nI][2]),nQtDec)//  METODO PARA RATEAR VALOR DE CADA SI POR PORCENTAGEM New(Total da SI,100%,qtd de CC por si,DECIMAL)
   For nX:=1 to LEN(aCCVal[nI][2])
      aCCVal[nI][2][nX][3]:=  oRateio:GetItemRateio(aCCVal[nI][2][nX][2])//BUSCANDO O VALOR REFERENTE A CADA PORCENTAGEM
   Next
Next

//agrupando por centro de custo
For nI:=1 to len(aCCVAL)  //arrai com SIs
   For nX:=1 to len(aCCVAL[nI][2]) //array com CC por SI
      IF (nPos:=ASCAN(aRet,{|X| X[1] == aCCVAL[nI][2][nX][1] })) == 0
         AADD(aRet,{aCCVAL[nI][2][nX][1],aCCVAL[nI][2][nX][3]}) // 1- CC 2-VALOR DO somado de todos os CC de todas as SIs da INVOICE
      ELSE
         aRet[nPos][2]+=aCCVAL[nI][2][nX][3]
      ENDIF
   Next
Next

//1- CC 2-VALOR DO somado de todos os CC de todas as SIs da INVOICE

Return aRet



/*
Funcao      : GERVAR_TRA(cTipo)
Objetivos   : Gerar contabilizacao do tipo 501 ou 504 ou  201
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     : WFS - mar/2017
              Diferenciar eventos contábeis para processos com e sem cobertura cambial
              Equivalência:
              101 - 111
              201 - 211
              501 - 512
              504 - 513
Parametros  : cTipo ou TN OU TM

*/
*----------------------------*
Function GERVAR_TRA(cTipo)
*----------------------------*
LOCAL  aValores   :={}
LOCAL  nI,aTaxas  :={}
LOCAL  lComEAI    := EasyGParam("MV_EIC_EAI",,.F.)
Local  aOrd       := SaveOrd({"ECF","EC6"})
LOCAL  LoK        := .F.
LOCAL  nValRSVAR  := 0
LOCAL  cChave     := ""
Local lCobCambial := .T.
PRIVATE cLote     := ""
DEFAULT cTipo     := 'TN'

SW9->(DBSETORDER(3))
SW9->(DBSEEK(XFILIAL('SW9')+SW6->W6_HAWB))
bCond:= {|| XFILIAL('SW9')+SW6->W6_HAWB == SW9->W9_FILIAL+SW9->W9_HAWB}

DO WHILE SW9->(!EOF()) .AND. EVAL(bCond)

      lCobCambial:= TemCoberturaCambial(SW9->W9_COND_PA + Str(SW9->W9_DIAS_PA, 3, 0))
      nFlutua  := L500RET(xFilial('ECF'),"IMPORT",SW6->W6_HAWB,SW9->W9_FORN,"",SW9->W9_INVOICE,'ECF_FLUTUA', lCobCambial)
      nParidade:= SW9->W9_TX_FOB


      aValCC   := LC500RatCC(xfilial('SW9'),SW9->W9_HAWB,SW9->W9_FORN,SW9->W9_INVOICE,AVSX3('ECF_VALOR',4))

      nValMoe  := DI500RetVal("TOT_INV", "TAB", .T., .F. )

      nValRSTRA:= nValMoe * nParidade//TRANSPORTE SEMPRE TEM NA MOEDA
      aValRSTRA:= LC500RatCC(xfilial('SW9'),SW9->W9_HAWB,SW9->W9_FORN,SW9->W9_INVOICE,AVSX3('ECF_VALOR',4),nValRSTRA,aValCC,nValMoe)//TRANSPORTE SEMPRE TEM EM REIAS

      IF cTipo = 'TN'
         IF nFlutua # 0
            nValRSVAR:= nValMoe * (nParidade - nFlutua)//VARIACAO CAMBIAO NEM SEMPRE TEM NA MOEDA
         ENDIF
         IF nValRSVAR # 0
            aValRSVAR:= LC500RatCC(xfilial('SW9'),SW9->W9_HAWB,SW9->W9_FORN,SW9->W9_INVOICE,AVSX3('ECF_VALOR',4),nValRSVAR,aValCC,nValMoe)//VARIACAO CAMBIAO NEM SEMPRE TEM EM REAIS
         ENDIF
      ENDIF

      IF LEN(aValCC)>0
         For nI:=1 to len(aValCC)
            nValVarRS:= IF(cTipo = 'TN' .AND. nValRSVAR # 0 ,aValRSVAR[nI][2],0)//VALOR EM REAIS DA VARICAO CAMBIAL - 5 - A array aValRSVAR tem a mesma dimensoes da aValCC
            AADD(aValores,{SW9->(RECNO())  ,;//RECNO DO SW9 - 1
                           aValCC[nI][2]   ,;//VALOR NA MOEDA DA INVOICE - 2
                           aValCC[nI][1]   ,;//CC DO LOGIX - 3
                           aValRSTRA[nI][2],;//VALOR EM REAIS DO TRANSPORTE - 4 - A array aValReaisTRA tem a mesma dimensoes da aValCC
                           nValVarRS       })//VALOR EM REAIS DA VARIACAO CAMBIA - 5
         Next
      ENDIF



   SW9->(DBSKIP())
ENDDO

IF Len(aValores) <> 0
   LoK :=.T.
ENDIF

IF LOK
   GRVVAR_TRA(aValores,ctipo)//VARIACAO CAMBIAL
ENDIF

RestOrd(aOrd,.t.)

RETURN LoK

/*
Funcao      : GRVVAR_TRA(aValores,cOrigem)
Objetivos   : GRAVAR contabilizacao do tipo 501 ou 504 ou  201
Autor       : Igor CHiba
Data/Hora   : 20/06/14
Revisao     : WFS - mar/2017
              Diferenciar eventos contábeis para processos com e sem cobertura cambial
              Equivalência:
              101 - 111
              201 - 211
              501 - 512
              504 - 513
Parametros  : cTipo  = TN FAZER 2 lançamentos para cada invoice um do tipo 501 ou 504 e outro do tipo 201
              cTipo  = TM FAZER 1 lançamento do tipo 201
              aValores = array de invoices, quando tiver 4 posições é pq está rateada por centro de custo

*/
*----------------------------*
Function GRVVAR_TRA(aValores,cOrigem)
*----------------------------*
LOCAL nI,nJ
LOCAL cId           :=''
LOCAL aInvoice      :={}
LOCAL aAuxInv       :={}
LOCAL cSeq          := ''
LOCAL aRegs         := {}
LOCAL cTipo         := ''
Local lCobCambial   := .T.
Local cEvIniTransito:= ""
Local cEvFimTransito:= ""
Local cEvVarPositiva:= ""
Local cEvVarNegativa:= ""

DEFAULT cOrigem     :='TN'

ECF->(DBSETORDER(1))
EC6->(DBSETORDER(1))


IF(cOrigem =='TN',nVezes:=2,nVezes:=1) //SE FOR DA ORIGEM TN PRECISA TER 2 LANÇAMENTOS  O PRIMEIRO DO TIPO VAR E O SEGUNDO DO TIPO TRA

For nJ:=1 to nVezes//todos os valores do avalores devem ser lançados duas vezes cada uma com um tipo

   IF nJ == 1
      cTipo := IF (cOrigem == 'TN','VAR','TRA')//se for da origem TN o primeiro lançamento é do tipo variacao cambial se nao é do tipo transito
   ELSE
      cTipo := 'TRA' //no tipo TN precisa de um segundo lançamento do tipo transporte
   ENDIF
   FOR nI:=1 to len(aValores)

      IF aValores[nI][2] = 0 //NAO GRAVAR VALORES VAZIOS
         LOOP
      ENDIF

      SW9->(DBGOTO(aValores[nI][1]))
      lCobCambial:= TemCoberturaCambial(SW9->W9_COND_PA + Str(SW9->W9_DIAS_PA, 3, 0))
      If lCobCambial
         cEvIniTransito:= "101"
         cEvFimTransito:= "201"
         cEvVarPositiva:= "501"
         cEvVarNegativa:= "504"
      Else
         cEvIniTransito:= "111"
         cEvFimTransito:= "211"
         cEvVarPositiva:= "512"
         cEvVarNegativa:= "513"
      EndIf

      IF (nPos:=ASCAN(aAuxInv,{|I| I[1] == SW9->W9_INVOICE+SW9->W9_FORN} )) = 0
         nFlutua:= L500RET(xFilial('ECF'),"IMPORT",SW6->W6_HAWB,SW9->W9_FORN,"",SW9->W9_INVOICE,'ECF_FLUTUA', lCobCambial)
         AADD(aAuxInv, {SW9->W9_INVOICE+SW9->W9_FORN,nFlutua})
      ELSE
          nFlutua:= aAuxInv[nPos,2]
      ENDIF
      nParidade:= SW9->W9_TX_FOB

      IF cTipo == 'VAR'  //SE TIVER VARIACAO ZERADA NAO FAZER NADA
         IF (aValores[nI][2] * (nParidade - nFlutua)) = 0 .OR. nFlutua = 0 .OR. nParidade = 0
            LOOP
         ENDIF
      ENDIF

      IF EMPTY(cLote)
         cLote:= GetSXENUM('ECF','ECF_NR_CON')
         CONFIRMSX8()
      ENDIF

      //Sequencia deve geracao de invoice das invoice
      IF (nPos:=ASCAN(aInvoice,{|I| I[1] == SW9->W9_INVOICE+SW9->W9_FORN} )) = 0
         cSeq := L500RET(xFilial('ECF'),"IMPORT",SW6->W6_HAWB,SW9->W9_FORN,'',SW9->W9_INVOICE,'NEXT_ECF_SEQ', lCobCambial)
         AADD(aInvoice,{SW9->W9_INVOICE+SW9->W9_FORN,cSeq})
      ELSE
          cSeq := aInvoice[nPos,2]
      ENDIF

      ECF->(RECLOCK('ECF',.T.))
      ECF->ECF_FILIAL  := xFilial("ECF")
      ECF->ECF_TPMODU  := "IMPORT"
      ECF->ECF_HAWB    := SW6->W6_HAWB
      ECF->ECF_FORN    := SW9->W9_FORN
      ECF->ECF_ORIGEM  := cOrigem//IF(cOrigem == 'VAR' .OR. cOrigem == 'TRA','TN','TM')
      ECF->ECF_INVOIC  := SW9->W9_INVOICE
      ECF->ECF_DI_NUM  := SW6->W6_DI_NUM
      ECF->ECF_SEQ     := cSeq
      ECF->ECF_DTCONT  := SW6->W6_DT_NF
      ECF->ECF_MOEDA   := SW9->W9_MOE_FOB
      ECF->ECF_PARIDA  := nParidade

      IF cTipo == 'VAR'
         ECF->ECF_FLUTUA  := nFlutua
         ECF->ECF_VL_MOE  := aValores[nI][2]//VALOR NA MOEDA
         ECF->ECF_VALOR   := aValores[nI][5]//aValores[nI][2] * (nParidade - nFlutua)//(nFlutua- nParidade)//VALOR EM REAIS
         ECF->ECF_ID_CAM  := cId:=IF(ECF->ECF_VALOR < 0,cEvVarNegativa/*'504'*/,cEvVarPositiva/*'501'*/)

         IF !EMPTY(aValores[nI,3])// == 3
            ECF->ECF_CC   := aValores[nI][3]
         ENDIF


      ELSEIF cTipo == 'TRA'

         ECF->ECF_ID_CAM   := cId:= cEvFimTransito //'201'
         ECF->ECF_FLUTUA   := 0
         ECF->ECF_VL_MOE   := aValores[nI][2]//VALOR NA MOEDA
         ECF->ECF_VALOR    := aValores[nI][4]//ECF->ECF_VL_MOE * ECF->ECF_PARIDA //VALOR EM REAIS

         IF !EMPTY(aValores[nI,3])// == 3
            ECF->ECF_CC    := aValores[nI][3]
         ENDIF

      ENDIF

      EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY(ECF->ECF_ID_CAM,'EC6_ID_CAM')))
      ECF->ECF_DESCR   := EC6->EC6_DESC
      ECF->ECF_CTA_CR  := EasyMascCon(EC6->EC6_CTA_CR,SW9->W9_FORN,SW9->W9_FORLOJ,"","","","","","","",,SW9->W9_INCOTER) //THTS - 01/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm 
      ECF->ECF_CTA_DB  := EasyMascCon(EC6->EC6_CTA_DB,SW9->W9_FORN,SW9->W9_FORLOJ,"","","","","","","",,SW9->W9_INCOTER) //THTS - 01/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm       
      ECF->ECF_CONTAB  := "2"
      ECF->ECF_NR_CON  := cLote
      ECF->(MSUNLOCK())
//    ECF->(DBCOMMIT())
      IF ASCAN(aRegs,ECF->(RECNO())) == 0 .And. EC6->EC6_CONTAB <> '2'
         AADD(aRegs,ECF->(RECNO()))
      ENDIF
   Next
NEXT



IF !ISINCALLSTACK('EICLC500') //CONTABILIZACAO NAO ENVIA NESSE MOMENTO POIS VAI ENVIAR POSTERIORMENTE
   //EC6->(DBSETORDER(1))
   //IF !EMPTY(cId) .AND. EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY(cId,'EC6_ID_CAM'))) .AND. EC6->EC6_CONTAB <> '2'; // ENVIAR AO ERP 
   //                                                                                         .AND. EasyGParam('MV_EIC0048',,.F.);
   If len(aRegs) > 0 .AND. AvFlags("EIC_EAI")/*EasyGParam("MV_EIC_EAI",,.F.)*/ .AND. EasyGParam('MV_EIC0048',,.F.)
      EICLC510(aRegs,3)    
   ENDIF
ENDIF

Return .T.



/*
FUNCAO     : GerNewContab()
AUTOR      : Igor Chiba
DATA       : 27/06/14
OBJETIVO   : Gerar um novo lançamento do tipo 201 origem TN para os casos que tiveream lançamentos encerrado ECF_CONTAB == 1
PARAMETROS : NENHUM
*/
*----------------------------*
Static Function GerNewContab()
*----------------------------*
LOCAL nI
LOCAL aRegs   := {}
LOCAL aValores:= {}
LOCAL nPos    := 0

For nI:=1 to ECF->(FCOUNT())
   cCpo :=ECF->(FIELDNAME(nI))
   AADD(aValores,{cCpo,ECF->&(cCpo)})
Next

//sequencia deve ser lancamento de invoice
IF (nPos:=ASCAN(aSeqInv,{|S| S[1] == ECF->ECF_FILIAL+ECF->ECF_HAWB+ECF->ECF_INVOIC+ECF->ECF_FORN } )) == 0
   cSeq := L500RET(ECF->ECF_FILIAL,"IMPORT",ECF->ECF_HAWB,ECF->ECF_FORN,'',ECF->ECF_INVOIC,'NEXT_ECF_SEQ')
   AADD(aSeqInv,{ECF->ECF_FILIAL+ECF->ECF_HAWB+ECF->ECF_INVOIC+ECF->ECF_FORN,cSeq})
ELSE
   cSeq := aSeqInv[nPos,2]
ENDIF

EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY(ECF->ECF_ID_CAM,'EC6_ID_CAM')))

//THTS - 02/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm.
SA2->(dbSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
SA2->(dbSeek(xFilial("SA2") + AvKey(ECF->ECF_FORN,"A2_COD")))

SW9->(dbSetOrder(1)) //W9_FILIAL + W9_INVOICE + W9_FORN + W9_FORLOJ + W9_HAWB
SW9->(dbSeek(xFilial("SW9") + AvKey(ECF->ECF_INVOIC,"W9_INVOICE") + AvKey(ECF->ECF_FORN,"W9_FORN") + AvKey(SA2->A2_LOJA,"W9_FORLOJ") + AvKey(ECF->ECF_HAWB,"W9_HAWB")))

//gravando novo ECF
ECF->(RECLOCK('ECF',.T.))
For nI:=1 to len(aValores)
   cCpo         := aValores[nI][1]
   ECF->&(cCpo) := aValores[nI][2]
Next
IF EMPTY(cLote)
   cLote:= GetSXENUM('ECF','ECF_NR_CON')
   CONFIRMSX8()
ENDIF
ECF->ECF_NR_CON := cLote
ECF->ECF_ID_CAM := '999'
ECF->ECF_DTCONT := dDataBase
ECF->ECF_SEQ    := cSeq
ECF->ECF_DESCR  := 'ESTORNO: '+ EC6->EC6_ID_CAM + '-' + ECF->ECF_DESCR
ECF->ECF_CONTAB := '2'
ECF->ECF_CTA_CR := EasyMascCon(IF(!EMPTY(EC6->EC6_CCREST),EC6->EC6_CCREST,ECF->ECF_CTA_DB),SW9->W9_FORN,SW9->W9_FORLOJ,"","","","","","","",,SW9->W9_INCOTER)//EC6_CCREST (conforme "IMPORT" e ECF_ID_CAM) caso preenchido. Caso contrário, ECF_CTA_DB. //THTS - 02/06/2017
ECF->ECF_CTA_DB := EasyMascCon(IF(!EMPTY(EC6->EC6_CDBEST),EC6->EC6_CDBEST,ECF->ECF_CTA_CR),SW9->W9_FORN,SW9->W9_FORLOJ,"","","","","","","",,SW9->W9_INCOTER)//EC6_CDBEST (conforme "IMPORT" e ECF_ID_CAM) caso preenchido. Caso contrário, ECF_CTA_CR. //THTS - 02/06/2017
//Limpar pq ja pode tercido enviando o ECF_CONTAB = 1
ECF->ECF_LOTERP := ""
ECF->ECF_LANCAM := ""
ECF->ECF_RELACA := ""
ECF->(MSUNLOCK())

IF !EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY('999','EC6_ID_CAM'))) .OR. EC6->EC6_CONTAB = '2'//Nao envia
   RETURN .F.
ENDIF

//IF ASCAN(aRegs,ECF->(RECNO())) == 0
//   AADD(aRegs,ECF->(RECNO()))
//ENDIF

//IF lEnviaOK .AND. EC6->EC6_CONTAB <> '2' .AND. EasyGParam('MV_EIC0048',,.F.) .AND. EasyGParam("MV_EIC_EAI",,.F.)    //ENVIAR AO ERP
//   lRet := EICLC510(aRegs,3)
//   lEnviaOK := lRet//Se for falso nao tenta mais enviar
//ENDIF

Return .T.
/*
FUNCAO     :L500RETREG(cFIL,cHAWB,cId,cOrigem)
AUTOR      : Igor Chiba
DATA       : 27/06/14
OBJETIVO   : RETORNAR OS REGISTROS DAS CHAVES PASSADAS COMO PARAMETRO, utilizada para retornar os ECFs que serão cancelados, funcao chamada do
             EICDI500,EICDI154 E EICDI554
PARAMETROS : NENHUM
*/
*------------------------------------------------------------------*
Function L500RETREG(cFIL,cHAWB,cId,cOrigem)
*------------------------------------------------------------------*
LOCAL cQuery   := ''
LOCAL aReg     := {}
LOCAL nOldArea := SELECT()
cQuery += " SELECT R_E_C_N_O_ REG FROM "+RETSQLNAME('ECF')+" ECF WHERE " +RetSqlCond("ECF")
cQuery += " AND ECF_TPMODU ='IMPORT'"
cQuery += " AND ECF_HAWB   ='"+cHAwb  +"'"

IF !EMPTY(cId)
   cQuery += " AND ECF_ID_CAM IN ("+cID+") "
ENDIF

IF !EMPTY(cOrigem)
   cQuery += " AND ECF_ORIGEM ='"+cOrigem+"' "
ENDIF


IF SELECT('RET') <> 0
   RET->(DBCLOSEAREA())
ENDIF
cQuery := ChangeQuery(cQuery)
dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"RET", .F., .F. )

RET->(DBGOTOP())
DO WHILE RET->(!EOF())
   IF ASCAN(aReg,RET->REG) == 0
      AADD(aReg,RET->REG)
   ENDIF
   RET->(DBSKIP())
ENDDO
RET->(DBCLOSEAREA())
DBSELECTAREA(nOldArea)

Return aReg


/*
FUNCAO     : PesqVarCamb
AUTOR      : Igor Chiba
DATA       : 27/06/14
OBJETIVO   : PESQUISAR QUAIS PROCESSOS PRECISAM Gerar as variações cambiais da rotina de comtabilização
Revisao    : WFS - mar/2017
             Tratamento para processos com e sem cobertura cambial
             Equivalência:
             201 - 211
PARAMETROS : NENHUM
*/
*----------------------------*
Static Function PesqVarCamb()
*----------------------------*
Local cQry     :=""
LOCAL nOldArea := SELECT()
cQry+= " SELECT R_E_C_N_O_ REG FROM "+RETSQLNAME('SW6')+" SW6 WHERE "+RetSqlCond("SW6")+" AND W6_DT_EMB <> ''"
cQry+= " AND W6_HAWB NOT IN"
cQry+= " (SELECT ECF_HAWB FROM "+RETSQLNAME('ECF')+" ECF  WHERE "+RetSqlCond("ECF")+" AND (ECF_ID_CAM = '201' Or ECF_ID_CAM = '211') AND ECF_CONTAB <> '4')"

IF SELECT('CAMB') <> 0
   CAMB->(DBCLOSEAREA())
ENDIF
cQry := ChangeQuery(cQry)
dbUseArea( .t., "TopConn", TCGenQry(,,cQry),"CAMB", .F., .F. )

CAMB->(DBGOTOP())
DO WHILE CAMB->(!EOF())
   SW6->(DBGOTO(CAMB->REG))
   GerVarCamb()
   CAMB->(DBSKIP())
ENDDO
CAMB->(DBCLOSEAREA())
DBSELECTAREA(nOldArea)
Return .T.

/*
FUNCAO     : GerVarCamb()
AUTOR      : Igor Chiba
DATA       : 27/06/14
OBJETIVO   : Gerar as variações cambiais das rotinas de contabilizações
Revisao    : WFS - mar/2017
             Diferenciar eventos contábeis para processos com e sem cobertura cambial
             Equivalência:
             101 - 111
             201 - 211
             501 - 512
             504 - 513
PARAMETROS : NENHUM
*/
*----------------------------*
Function GerVarCamb()
*----------------------------*
LOCAL  aValores   :={}
LOCAL  lComEAI    := EasyGParam("MV_EIC_EAI",,.F.)
LOCAL  cAlias     := ALIAS()
LOCAL  LoK        := .F.
LOCAL  nI
Local lCobCambial:= .T.
PRIVATE cLote     := ""

SW9->(DBSETORDER(3))
SW9->(DBSEEK(XFILIAL('SW9')+SW6->W6_HAWB))
bCond:= {|| XFILIAL('SW9')+SW6->W6_HAWB == SW9->W9_FILIAL+SW9->W9_HAWB}

EC6->(DBSETORDER(1))
//EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY('501','EC6_ID_CAM')))

IF !EMPTY(SW6->W6_DT_NF)
   dDtVC:= IF(dDtLanca < SW6->W6_DT_NF,dDtLanca,SW6->W6_DT_NF)//UTILIZAR A MENOR DATA, A DO PERGUNTE OU DA NF
ELSE
   dDtVC:= dDtLanca //UTILIZAR A DATA DO PERGUNTE
ENDIF

DO WHILE SW9->(!EOF()) .AND. EVAL(bCond)

      lCobCambial:= TemCoberturaCambial(SW9->W9_COND_PA + Str(SW9->W9_DIAS_PA, 3, 0))
      nFlutua   :=  L500RET(xFilial('ECF'),"IMPORT",SW6->W6_HAWB,SW9->W9_FORN,"",SW9->W9_INVOICE,'ECF_FLUTUA', lCobCambial)

      If lCobCambial
         EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY('501','EC6_ID_CAM')))
      Else
         EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY('512','EC6_ID_CAM')))
      EndIf

      nParidade :=  BuscaTaxa(SW9->W9_MOE_FOB ,dDtVC, , .F.,,,EC6->EC6_TXCV)

      IF (nParidade - nFlutua) = 0 .OR. nFlutua = 0 .OR. nParidade = 0
         SW9->(DBSKIP())
         LOOP
      ENDIF

      aValCC   := LC500RatCC(xfilial('SW9'),SW9->W9_HAWB,SW9->W9_FORN,SW9->W9_INVOICE,AVSX3('ECF_VALOR',4))

      nValMoe  := DI500RetVal("TOT_INV", "TAB", .T., .F. )
      nValReais:= nValMoe * (nParidade - nFlutua)
      IF nValReais # 0
         aValReais:= LC500RatCC(xfilial('SW9'),SW9->W9_HAWB,SW9->W9_FORN,SW9->W9_INVOICE,AVSX3('ECF_VALOR',4),nValReais,aValCC,nValMoe)
      ENDIF

      IF LEN(aValCC)>0
         For nI:=1 to len(aValCC)
             nValVarRS:= IF(nValReais # 0 ,aValReais[nI][2],0)//VALOR EM REAIS DA VARICAO CAMBIAL - A array aValReais tem as mesmas dimensoes da aValCC
             AADD(aValores,{SW9->(RECNO()),;//RECNO DO SW9 - 1
                            aValCC[nI][2] ,;//VALOR NA MOEDA DA INVOICE - 2
                            aValCC[nI][1] ,;//CC DO LOGIX - 3
                            nValVarRS     })//VALOR EM REAIS DA VARIACAO - 4
         Next
      ENDIF

   SW9->(DBSKIP())
ENDDO

IF Len(aValores) <> 0
   LoK :=.T.
ENDIF

IF LOK
   GrvVarCamb(aValores)//VARIACAO CAMBIAL
ENDIF

DBSELECTAREA(cAlias)
RETURN LoK


/*
FUNCAO     : GrvVarCamb(aValores)
AUTOR      : Igor Chiba
DATA       : 27/06/14
OBJETIVO   : gravar as variações cambiais da rotina de comtabilização
Revisao    : WFS - mar/2017
             Diferenciar eventos contábeis para processos com e sem cobertura cambial
             Equivalência:
             101 - 111
             201 - 211
             501 - 512
             504 - 513
PARAMETROS : NENHUM
*/
*----------------------------*
Static Function GrvVarCamb(aValores)
*----------------------------*
LOCAL nI
LOCAL aInvoice      :={}
LOCAL cSeq          := ''
Local lCobCambial   := .T.
Local cEvVarPositiva:= ""
Local cEvVarNegativa:= ""

ECF->(DBSETORDER(1))
EC6->(DBSETORDER(1))

FOR nI:=1 to len(aValores)

   IF aValores[nI][2] == 0 //NAO GRAVAR VALORES VAZIOS
      LOOP
   ENDIF

   SW9->(DBGOTO(aValores[nI][1]))
   lCobCambial:= TemCoberturaCambial(SW9->W9_COND_PA + Str(SW9->W9_DIAS_PA, 3, 0))
   If lCobCambial
      cEvVarPositiva:= "501"
      cEvVarNegativa:= "504"
   Else
      cEvVarPositiva:= "512"
      cEvVarNegativa:= "513"
   EndIf

   IF ASCAN(aInvoice,SW9->W9_INVOICE+SW9->W9_FORN) == 0
      //Preciso atualizar as variaveis com a invoice corrente
      nFlutua   :=L500RET(xFilial('ECF'),"IMPORT",SW6->W6_HAWB,SW9->W9_FORN,"",SW9->W9_INVOICE,'ECF_FLUTUA', lCobCambial)
      nParidade :=BuscaTaxa(SW9->W9_MOE_FOB ,dDtVC, , .F.,,,EC6->EC6_TXCV)
   ENDIF

   IF ((nParidade - nFlutua) *  aValores[nI][2]) == 0 .OR. nFlutua = 0 .OR. nParidade = 0
      AADD(aInvoice,SW9->W9_INVOICE+SW9->W9_FORN)//Só executar o AADD se der LOOP, nao tem problema de repetir
      LOOP
   ENDIF

   //sequencia deve ser lancamento de invoice
   IF ASCAN(aInvoice,SW9->W9_INVOICE+SW9->W9_FORN) == 0
      AADD(aInvoice,SW9->W9_INVOICE+SW9->W9_FORN)
      cSeq := L500RET(xFilial('ECF'),"IMPORT",SW6->W6_HAWB,SW9->W9_FORN,'',SW9->W9_INVOICE,'NEXT_ECF_SEQ', lCobCambial)
   ENDIF

   IF EMPTY(cLote)
      cLote:= GetSXENUM('ECF','ECF_NR_CON')
      CONFIRMSX8()
   ENDIF

   ECF->(RECLOCK('ECF',.T.))
   ECF->ECF_FILIAL  := xFilial("ECF")
   ECF->ECF_TPMODU  := "IMPORT"
   ECF->ECF_HAWB    := SW6->W6_HAWB
   ECF->ECF_FORN    := SW9->W9_FORN
   ECF->ECF_ORIGEM  := 'TM'
   ECF->ECF_INVOIC  := SW9->W9_INVOICE
   ECF->ECF_DI_NUM  := SW6->W6_DI_NUM
   ECF->ECF_DTCONT  := dDtLanca
   ECF->ECF_MOEDA   := SW9->W9_MOE_FOB
   ECF->ECF_SEQ     := cSeq
   ECF->ECF_PARIDA  := nParidade
   ECF->ECF_FLUTUA  := nFlutua
   ECF->ECF_VL_MOE  := aValores[nI][2] //VALOR NA MOEDA
   ECF->ECF_VALOR   := aValores[nI][4] //VALOR EM REIAS
   IF !EMPTY(aValores[nI,3])
      ECF->ECF_CC   := aValores[nI][3]
   ENDIF
   ECF->ECF_ID_CAM  := IF(ECF->ECF_VALOR < 0,cEvVarNegativa/*'504'*/,cEvVarPositiva/*'501'*/)
   EC6->(DBSEEK(XFILIAL('EC6')+AVKEY("IMPORT",'EC6_TPMODU')+AVKEY(ECF->ECF_ID_CAM,'EC6_ID_CAM')))
   ECF->ECF_DESCR   := EC6->EC6_DESC
   ECF->ECF_CTA_CR  := EasyMascCon(EC6->EC6_CTA_CR,SW9->W9_FORN,SW9->W9_FORLOJ,"","","","","","","",,SW9->W9_INCOTER) //THTS - 01/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm 
   ECF->ECF_CTA_DB  := EasyMascCon(EC6->EC6_CTA_DB,SW9->W9_FORN,SW9->W9_FORLOJ,"","","","","","","",,SW9->W9_INCOTER) //THTS - 01/06/2017 - TE-5822 - Contabilização com conta contabil por Incoterm 
   ECF->ECF_CONTAB  := "2"
   ECF->ECF_NR_CON  := cLote
   ECF->(MSUNLOCK())

NEXT

Return .T.


Function LC500GtDtLc()

Local dDtRet := cToD("  /  /  ")

   If Type('lEfetDtEv') == 'L' .And. lEfetDtEv
      dDtRet := dDtLanca
   EndIf

Return dDtRet

/*
FUNCAO     : TemCoberturaCambial()
AUTOR      : wfs
DATA       : mar/2017
OBJETIVO   : Verificar se a condição de pagamento da commercial invoice é com cobertura cambial
PARAMETROS : Chave da condição de pagamento, conforme índice 1 da tabela SY6
*/
Static Function TemCoberturaCambial(cChaveCondPag)
Local lRet:= .T.
Default cChaveCondPag:= ""

Begin Sequence

   If Empty(cChaveCondPag)
      Break
   EndIf

   SY6->(DBSetOrder(1)) //Y6_FILIAL+Y6_COD+STR(Y6_DIAS_PA,3,0)
   lRet:= SY6->(DBSeek(xFilial() + cChaveCondPag)) .And. SY6->Y6_TIPOCOB <> "4" //sem cobertura cambial

End Sequence

Return lRet

/*
FUNCAO     : L500VISUAL()
AUTOR      : Tiago Henrique Tudisco dos Santos - THTS
DATA       : 02/06/2017
OBJETIVO   : Executar a visualizacao. Quando chamado o AxVisual direto da menudef, gerava erro dentro da MarkBrow.
*/
Function L500VISUAL(cAlias,nReg,nOpc)
    AxVisual(cAlias,nReg,2,)
Return

/*
FUNCAO     : UPDX1LC500()
AUTOR      : Tiago Henrique Tudisco dos Santos - THTS
DATA       : 28/07/2017
OBJETIVO   : Atualizar a pre selecao da pergunta.
*/
Static Function UPDX1LC500(o)
o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_PRESEL' })
o:TableData('SX1'  ,{'EICLC500'  ,"07"    ,2           })
Return