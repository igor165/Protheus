#Include "EEC.cH"
#Include "EECAD101.CH"
#Include "TOPCONN.CH"

/*
Programa        : EECAD101.PRW
Objetivo        : 
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 19/10/2007
Obs. 
*/

#Define NAT_SALDO "SLD"
#Define ATIVO     "1"
#Define CANCELADO "2"

//Op��es da fun��o AF200DetMan
#define LIQ_DET     99
#define ELQ_DET     98
#define BXG_DET     97

// ** JPM - 16/12/2009 - performance muito pior que Macros.
//#Define bSetGet {|cAlias, cCpo, SetVal| If(cAlias == "M", Eval(MemVarBlock(cCpo), SetVal), Eval(FieldWBlock(cCpo, Select(cAlias)), SetVal)) }

/* JPM - 16/12/2009 - Definido como fun��o
//** AAF - 25/02/08 - Fixado o dia para dia 1 pois ao retornar um m�s sem alterar o dia, pode-se retornar uma data inv�lida, como 31/02/08.
//#Define bSubMes {|dData| SToD(StrZero(If(Month(dData) == 1, Year(dData) -1, Year(dData)), 4) + StrZero(If(Month(dData) == 1, 12, Month(dData) - 1), 2) + StrZero(Day(dData), 2)  ) }
#Define bSubMes {|dData| SToD(StrZero(If(Month(dData) == 1, Year(dData) -1, Year(dData)), 4) + StrZero(If(Month(dData) == 1, 12, Month(dData) - 1), 2) + "01"  ) }
//**
*/

/*
Funcao      : EECAD101
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Efetuar manuten��o e registro das movimenta��es das contas no exterior
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 19/10/07
Revisao     : 
Obs.        :
*/
Function EECAD101()
Local aOrd := SaveOrd({"EYR"})

Local aBrwLegenda
Private aLegenda := {{"BR_VERDE"   , STR0008},;//"Movimenta��o Ativa"
                     {"BR_VERMELHO", STR0009}}//"Movimenta��o Cancelada"

Private aRotina := MenuDef()

Private cAlias := "EYR",;
        cTitulo := STR0006 //"Manuten��o de Movimenta��es no Exterior"

aBrwLegenda := {{"EYR->EYR_FLAG == '1'", aLegenda[1][1]},;
                {"EYR->EYR_FLAG == '2'", aLegenda[2][1]}}

If EasyEntryPoint("EECAD101")
   ExecBlock("EECAD101",.f.,.f.,{"ANTES_MBROWSE"})
EndIf

mBrowse(6, 1, 22, 75, cAlias,,,,,, aBrwLegenda)

If EasyEntryPoint("EECAD101")
   ExecBlock("EECAD101",.f.,.f.,{"DEPOIS_MBROWSE"})
EndIf

RestOrd(aOrd, .F.)

Return Nil

/*
Funcao      : AD101MAN
Parametros  : cAlias - Alias da tabela em que ser� feita a manuten��o
              nReg - Recno do registro que ser� alterado
              nOpc - Indica o tipo de opera��o que ser� efetuada no registro
Retorno     : lOk
Objetivos   : Efetuar manuten��o no cadastro de movimenta��es no exterior
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 24/10/07 - 11:40
Revisao     : 
Obs.        : 
*/

Function AD101MAN(cAlias, nReg, nOpc, uPar1, aAuto)
Local oDlg, oEnchoice, i
Local bOk     := {|| If(lOk := (Obrigatorio(aGets,aTela) .And.;
                                AD101Vld("VALID_TELA_MOV")),; // ** JPM - 14/12/2009 - Valida��o da tela de movimenta��es
                                oDlg:End(),)},;
      bCancel := {|| oDlg:End()}

//Se o array "aAuto" for informado, a manuten��o � feita de forma autom�tica
Private lAutoAd101 := ValType(aAuto) == "A"
Private lOk := .F.
Private aGets[0],aTela[0]

Private nSelecao := nOpc // ** JPM - 14/12/2009 - nOpc como private

Default cAlias := "EYR"
Default nReg   := EYR->(Recno())

Begin Sequence

   ChkFile("SA6")
   RegToMemory(cAlias, nOpc == INCLUIR)
   
   If lAutoAd101
      aEval(aAuto, {|x| M->&(x[1]) := x[2] })

      //N�o exibe a tela da manuten��o, faz apenas a valida��o dos campos chave
      If nOpc == INCLUIR
         lOk := AD101Vld("AUTOINCLUDE")
      Else
         lOk := .T.
      EndIf
   Else
      
      If EasyEntryPoint("EECAD101")
         lRetPto := ExecBlock("EECAD101",.f.,.f.,{"ANTES_ENCHOICE"})
         If ValType(lRetPto) = "L" .And. !lRetPto
            Break
         EndIf
      EndIf
      
      If nOpc <> INCLUIR .And. nOpc <> VISUALIZAR
         If (cAlias)->EYR_ORIGEM $ "1
            MsgInfo("N�o � poss�vel dar manuten��o em movimentos que foram gerados automaticamente pelo sistema.","Aten��o")
            lOk := .F.
            Break
         EndIf

         If (cAlias)->EYR_FLAG = CANCELADO
            MsgInfo("Esta movimenta��o j� est� cancelada.","Aten��o")
            lOk := .F.
            Break
         EndIf
      EndIf
      
      DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 350,636 OF oMainWnd PIXEL

         oEnchoice := MsMGet():New(cAlias, nReg, nOpc,,,,GetCampos(nOpc),PosDlg(oDlg))
         
         // ** JPM - 15/12/2009 - Cria campos em areas fora da folder da enchoice para o caso de haver apenas um campo editavel na tela,
         //                       e haver a necessidade de se executar uma valida��o ou um when. (campos customizados)
         For i := 1 To Len(oEnchoice:oBox:aDialogs)
            TGet():New(3000, 3000, {|| },oEnchoice:oBox:aDialogs[i], 40, 8, "", ,,,,,,.T.,,,, .F., .F.,, .F., .F.,,"")
         Next
         
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   EndIf
   
   If lOk .And. nOpc <> VISUALIZAR
      BEGIN TRANSACTION
         ConfirmSx8()
         (cAlias)->(RecLock(cAlias, nOpc == INCLUIR))
         
         If nOpc == EXCLUIR
            If (cAlias)->EYR_FLAG <> CANCELADO
               (cAlias)->EYR_FLAG := CANCELADO
               (cAlias)->EYR_REF := M->EYR_REF
            EndIf
         Else
            AvReplace("M", cAlias)
         EndIf
         (cAlias)->(MsUnlock())

         If EasyEntryPoint("EECAD101")
            ExecBlock("EECAD101",.f.,.f.,{"GRAVA_MOV"})
         EndIf

      END TRANSACTION
      
      If M->EYR_NATURE <> NAT_SALDO
         //Atualiza o saldo para o m�s anterior, caso j� n�o for uma inclus�o de controle de saldo.
         AD101AtuSld(M->EYR_BANCO, M->EYR_AGEN, M->EYR_CONTA, Left(DToS(M->EYR_DATA), 6))
      EndIf
         
   ElseIf !lOk .And. nOpc == INCLUIR
      RollBackSxE()
   EndIf

End Sequence

Return lOk

/*
Funcao     : AD101VLD(cCampo)
Parametros : cCampo - Campo a ser validado
             cOri   - Indica a origem da chamada da valida��o, para permitir que o mesmo tratamento seja utilizado
                      em v�rios lugares.
Retorno    : lRet
Objetivos  : Validar os campos da manuten��o de movimenta��es no exterior.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 30/10/07 - 11:30
*/
Function AD101VLD(cCampo, cOri)
Local lRet := .T.
Local aOrd, aBanco
Default cCampo := ""
Default cOri   := ""

// ** JPM - 14/12/2009 - Vari�veis private para serem acessadas via rdmake
Private cCampoVld := cCampo 
Private cOriVld   := cOri

Begin Sequence

   If EasyEntryPoint("EECAD101")
      lRetPto := ExecBlock("EECAD101",.f.,.f.,{"ANTES_FUNCAO_VALIDACAO"})
      If ValType(lRetPto) = "L" .And. !lRetPto
         lRet := .F.
         Break
      EndIf
   EndIf

   Do Case
      Case cCampo == "BANCO"
         If Len(aBanco := BuscaBanco(&(RetField("BANCO", cOri)))) > 0
            &(RetField("AGENCIA", cOri)) := aBanco[2]
            &(RetField("CONTA"  , cOri)) := aBanco[3]
            &(RetField("NOME"   , cOri)) := aBanco[4]
            &(RetField("MOEDA"  , cOri)) := aBanco[5]
            &(RetField("PAIS"   , cOri)) := aBanco[6]
            AD101Vld("ATUMOEINI", cOri)
         Else
            MsgInfo(STR0010, STR0042)//"O banco informado n�o est� cadastrado no sistema."###"Aten��o"
            lRet := .F.
         EndIf
         
      Case cCampo == "AGENCIA"
         If Len(aBanco := BuscaBanco(&(RetField("BANCO", cOri)), &(RetField("AGENCIA", cOri)))) > 0
            &(RetField("CONTA", cOri)) := aBanco[3]
            &(RetField("NOME" , cOri)) := aBanco[4]
            &(RetField("MOEDA", cOri)) := aBanco[5]
            &(RetField("PAIS" , cOri)) := aBanco[6]
            AD101Vld("ATUMOEINI", cOri)
         Else
            MsgInfo(STR0011, STR0042)//"A agencia informada n�o est� cadastrada no sistema para o banco escolhido."###"Aten��o"
            lRet := .F.
         EndIf
         
      Case cCampo == "CONTA"
         If Len(aBanco := BuscaBanco(&(RetField("BANCO", cOri)), &(RetField("AGENCIA", cOri)), &(RetField("CONTA", cOri)) )) > 0
            &(RetField("NOME" , cOri)) := aBanco[4]
            &(RetField("MOEDA", cOri)) := aBanco[5]
            &(RetField("PAIS" , cOri)) := aBanco[6]
            AD101Vld("ATUMOEINI", cOri)
         Else
            MsgInfo(STR0012, STR0042)//"A conta informada n�o est� cadastrada no sistema para o banco e agencia escolhidos."###"Aten��o"
            lRet := .F.
         EndIf
         
      Case cCampo == "EYR_BANCO"
         lRet := AD101Vld("BANCO", "M")
      
      Case cCampo == "EYR_AGEN"
         lRet := AD101Vld("AGENCIA", "M")
      
      Case cCampo == "EYR_CONTA"
         lRet := AD101Vld("CONTA", "M")

      Case cCampo == "cBcoOri"
         lRet := AD101Vld("BANCO", "Ori")
         
      Case cCampo == "cAgeOri"
         lRet := AD101Vld("AGENCIA", "Ori")
      
      Case cCampo == "cCntOri"
         lRet := AD101Vld("CONTA", "Ori")

      Case cCampo == "cBcoDes"
         lRet := AD101Vld("BANCO", "Des")

      Case cCampo == "cAgeDes"
         lRet := AD101Vld("AGENCIA", "Des")
      
      Case cCampo == "cCntDes"
         lRet := AD101Vld("CONTA", "Des")

      Case cCampo == "EYR_DATA"
         M->EYR_ANOMES := Left(DtoS(M->EYR_DATA), 6)

      Case cCampo == "DTORI"
         dDtDes := dDtOri
      
      Case cCampo == "EYR_NATURE"
         lRet := EYQ->( dbSeek(xFilial("EYQ")+M->EYR_NATURE) )
         M->EYR_TIPMOV := EYQ->EYQ_TIPMOV
         //M->EYR_TIPMOV := Posicione("EYQ", 1, xFilial('EYQ')+M->EYR_NATURE, "EYQ_TIPMOV")
      
      Case cCampo == "ATUMOEINI"
         //If cOri <> "Des" //AAF - 03/03/08 - Removida condi��o, pois a moeda de transa��o � obrigat�ria e deve estar sempre preenchida.
         
         If Empty(&(RetField("MOEINI", cOri)))
            &(RetField("MOEINI", cOri)) := &(RetField("MOEDA", cOri))
            
            //** AAF 03/03/08 - Atualizar o valor na moeda da transa��o.
            If M->EYR_NATURE <> NAT_SALDO
               &(RetField("VALORINI", cOri)) := &(RetField("VALOR", cOri))
            EndIf
            //**
         EndIf
         
      Case cCampo == "EYR_MOEINI"
         AD101Vld("ATUVALOR", "M")

      Case cCampo == "EYR_VALINI"
         AD101Vld("ATUVALOR", "M")

      Case cCampo == "cMoeMov"
         AD101Vld("ATUVALOR", "Ori")
         AD101Vld("ATUVALDEST", "Ori")

      Case cCampo == "nValMov"
         AD101Vld("ATUVALOR", "Ori")
         AD101Vld("ATUVALDEST")

      Case cCampo == "ATUVALOR"
         &(RetField("VALOR", cOri)) := AD101ConVal(&(RetField("VALORINI", cOri)), &(RetField("MOEINI", cOri)), &(RetField("MOEDA", cOri)), &(RetField("DATA", cOri)))

      Case cCampo == "TRANSF"
        If Empty(cBcoOri) .Or. Empty(cAgeOri) .Or. Empty(cCntOri) .Or. Empty(cNatOri) .Or. Empty(dDtOri) .Or. Empty(cMoeMov) .Or. nValMov == 0 .Or. nValBco == 0 .Or.;
           Empty(cBcoDes) .Or. Empty(cAgeDes) .Or. Empty(cCntDes) .Or. Empty(cNatDes) .Or. Empty(dDtDes) .Or. Empty(cMoeDes) .Or. nValDes == 0

           MsgInfo(STR0013, STR0042)//"N�o foram informados todos os campos obrigat�rios. Favor verificar todos os campos em azul."###"Aten��o"
           lRet := .F.
        EndIf

      Case cCampo == "ATUVALDEST"
         nValDes := AD101ConVal(nValMov, cMoeMov, cMoeMov, dDtDes)
      
      Case cCampo == "AUTOINCLUDE"
         If (lRet := (Len(aBanco := BuscaBanco(M->EYR_BANCO, M->EYR_AGEN, M->EYR_CONTA)) > 0) .And. AD101Vld("EYR_NATURE") .And. AD101Vld("EYR_DATA"))
            &(RetField("MOEDA"  , cOri)) := aBanco[5]
            &(RetField("PAIS"   , cOri)) := aBanco[6]
            If lRet := (!Empty(M->EYR_MOEDA) .And. (M->EYR_VALOR > 0))
               AD101Vld("ATUMOEINI", cOri)
            EndIf
         EndIf
      // ** JPM - 14/12/2009 - Valida��o da tela de movimenta��es. Poder� ser acessado via rdmake
      Case cCampo == "VALID_TELA_MOV"
      
   End Case

   If EasyEntryPoint("EECAD101")
      lRetPto := ExecBlock("EECAD101",.f.,.f.,{"DEPOIS_FUNCAO_VALIDACAO"})
      If ValType(lRetPto) = "L" .And. !lRetPto
         lRet := .F.
         Break
      EndIf
   EndIf

End Sequence

If ValType(aOrd) == "A"
   RestOrd(aOrd, .T.)
EndIf

Return lRet

/*
Funcao     : BuscaBanco(cBco, cAge, cCnt, lRetBco)
Parametros : cBco - C�digo do banco
             cAge - Ag�ncia da conta
             cCnt - N�mero da conta
             lRetBco - Indica o tipo de retorno da fun��o
Retorno    : Se ".T." retorna array com informa��es da conta, se ".F.", retorna se a conta est� cadastrada
             no sistema
Objetivos  : Verifica se a conta informada est� cadastrada no sistema, e retorna as informa��es da mesma
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 07/11/07 - 11:00
*/
Static Function BuscaBanco(cBco, cAge, cCnt, lRetBco)
Local aOrd := SaveOrd("SA6")
Local aBanco := {}
Local cChave
Default lRetBco := .T.

   aOrd := SaveOrd("SA6")
   SA6->(DbSetOrder(1))
   cChave := xFilial("SA6")
   If ValType(cBco) == "C"
      cChave += AvKey(cBco, "A6_COD")
      If ValType(cAge) == "C"
         cChave += AvKey(cAge, "A6_AGENCIA")
         If ValType(cCnt) == "C"
            cChave += AvKey(cCnt, "A6_NUMCON")
         EndIf
      EndIf
   EndIf
   If SA6->(DbSeek(cChave))
      aAdd(aBanco, SA6->A6_COD)   
      aAdd(aBanco, SA6->A6_AGENCIA)
      aAdd(aBanco, SA6->A6_NUMCON)
      aAdd(aBanco, SA6->A6_NOME)
      aAdd(aBanco, SA6->A6_MOEEASY)
      aAdd(aBanco, SA6->A6_COD_P)
   EndIf

RestOrd(aOrd, .T.)
Return If(lRetBco, aBanco, Len(aBanco) > 0)

/*
Funcao     : AD101ConVal(nValor, cMoeOri, cMoeDes, dData)
Parametros : nValor  - Valor a ser convetido
             cMoeOri - C�digo da moeda de origem
             cMoeDes - C�digo da moeda de destino
             dData   - Data de base para a convers�o
Retorno    : nValor - Valor convertido
Objetivos  : Converte o valor informado da moeda de origem para a moeda de destino, utilizando o valor em reais como
             passo intermedi�rio na convers�o
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 07/11/07 - 11:00
*/
Function AD101ConVal(nValor, cMoeOri, cMoeDes, dData)
Local nTaxaOri := 1, nTaxaDes := 1

   If cMoeOri <> cMoeDes
      //Busca a taxa de convers�o de reais para a moeda de origem
      If !("R$" $ cMoeOri)
         If (nTaxaOri := BuscaTaxa(cMoeOri, If(ValType(dData) <> "D", dDatabase, dData),, .F.)) == 0
            nTaxaOri := 1
         EndIf
      EndIf
      //Busca a taxa de convers�o de reais para a moeda de destino
      If !("R$" $ cMoeDes)
         If (nTaxaDes := BuscaTaxa(cMoeDes, If(ValType(dData) <> "D", dDatabase, dData),, .F.)) == 0
            nTaxaDes := 1
         EndIf
      EndIf
      //Converte para o valor em reais
      nValor := nValor / nTaxaOri
      //Converte para o valor na moeda de destino
      nValor := nValor * nTaxaDes
   EndIf

Return nValor

/*
Funcao     : GetCampos(nOpc)
Parametros : nOpc - Indica a opera��o (INCLUIR, ALTERAR, etc.)
Retorno    : aCampos - Campos que ser�o exibidos na Enchoice
Objetivos  : Retornar os campos que ser�o exibidos na Enchoice, considerando o array aNotShow, com os campos que n�o devem ser exibidos.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 30/10/07 - 11:00
*/
Static Function GetCampos(nOpc)
Local lLoop, nInc, nPos
Local aOrd := SaveOrd("SX3")
Local aCampos := {}

// ** JPM - 14/12/2009 - Definido como private para ser acessado via rdmake
Private aNotShow := {{"EYR_FILORI", INCLUIR},;
                     {"EYR_HAWB"  , INCLUIR},;
                     {"EYR_INVOIC", INCLUIR},;
                     {"EYR_LINHA" , INCLUIR},;
                     {"EYR_PREEMB", INCLUIR},;
                     {"EYR_NRINVO", INCLUIR},;
                     {"EYR_PARC"  , INCLUIR}}
   
   If EasyEntryPoint("EECAD101")
      ExecBlock("EECAD101",.f.,.f.,{"DEFINE_CAMPOS_NAO_MOSTRADOS"})
   EndIf
   
   SX3->(DbSeek("EYR"))
   While SX3->(!Eof() .And. X3_ARQUIVO == "EYR")
      lLoop := .F.
      If (nPos := aScan(aNotShow, {|x| SX3->X3_CAMPO == If(ValType(x) == "A", IncSpace(x[1], 10, .F.), IncSpace(x, 10, .F.)) })) > 0
         If ValType(aNotShow[nPos]) <> "A" .Or. Len(aNotShow[nPos]) == 1
            lLoop := .T.
         Else
            For nInc := 2 To Len(aNotShow[nPos])
               If nOpc == aNotShow[nPos][nInc]
                  lLoop := .T.
                  Exit
               EndIf
            Next
         EndIf
      EndIf
      If !X3Uso(SX3->X3_USADO)
         lLoop := .T.
      EndIf
      If lLoop
         SX3->(DbSkip())
         Loop
      EndIf
      aAdd(aCampos, SX3->X3_CAMPO)
      SX3->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return aCampos

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as defini��es de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 24/10/07 - 11:00
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina  := { { STR0001, "AxPesqui" , 0 , 1},;   //"Pesquisar"
                    { STR0002, "AD101MAN" , 0 , 2},;   //"Visualizar"
                    { STR0003, "AD101MAN" , 0 , 3},;   //"Incluir"
                    { STR0004, "AD101MAN" , 0 , 4},;   //"Alterar"
                    { STR0005, "AD101MAN" , 0 , 5,3},; //"Cancelar"
                    { STR0007, "AD101TRF" , 0 , 3},;   //"Transferir"
                    { STR0014, "AD101LEG" , 0 , 2}}    //"Legenda"
                    

Begin Sequence

   If EasyEntryPoint("EAD101MNU")
      aRotAdic := ExecBlock("EAD101MNU",.f.,.f.)
   EndIf

   If ValType(aRotAdic) == "A"
      aEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf

End Sequence

Return aRotina

/*
Funcao     : AD101LEG()
Parametros : Nenhum
Retorno    : Chamada da fun��o de exibi��o da legenda da mBrowse
Objetivos  : Retornar a tela de legenda da Browse
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 07/11/07 - 11:00
*/
Function AD101LEG()
Return BrwLegenda(STR0006, STR0014, aLegenda)//"Manuten��o de Movimenta��es no Exterior"###"Legenda"

/*
Funcao      : AD101TRF
Parametros  : cAlias - Alias da tabela em que ser� feita a manuten��o
              nReg - Recno do registro que ser� alterado
              nOpc - Indica o tipo de opera��o que ser� efetuada no registro
Retorno     : lOk
Objetivos   : Efetuar a transfer�ncia de valores entre contas no exterior
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 24/10/07 - 11:40
Revisao     : 
Obs.        : 
*/
Function AD101TRF(cAlias, nReg, nOpc)

/* ** JPM - 14/12/2009 - vari�veis private para serem acessadas por rdmake.
Local oDlg
Local bOk     := {|| If(AD101Vld("TRANSF"), (lOk := .T., oDlg:End()),) },;
      bCancel := {|| oDlg:End()}

Local nLin := 15, nJumpLine := 12
Local nCol1 := 10, nCol2 := 50, nCol3 := 90, nCol4 := 120
*/

Private oDlgTrf
Private bOk     := {|| If(AD101Vld("TRANSF"), (lOk := .T., oDlgTrf:End()),) },;
        bCancel := {|| oDlgTrf:End()}
        
Private nLin := 15, nJumpLine := 12
Private nCol1 := 10, nCol2 := 50, nCol3 := 90, nCol4 := 120

Private cBcoOri  := Space(AvSx3("EYR_BANCO", AV_TAMANHO)),;
        cNBcoOri := Space(AvSx3("EYR_NOMBCO", AV_TAMANHO)),;
        cAgeOri  := Space(AvSx3("EYR_AGEN", AV_TAMANHO)),;
        cCntOri  := Space(AvSx3("EYR_CONTA", AV_TAMANHO)),;
        cPaiOri  := Space(AvSx3("EYR_PAIS", AV_TAMANHO)),;
        cNatOri  := Space(AvSx3("EYR_NATURE", AV_TAMANHO)),;
        dDtOri   := CToD("  /  /  "),;
        cMoeMov  := Space(AvSx3("EYR_MOEDA", AV_TAMANHO)),;
        cMoeBco  := Space(AvSx3("EYR_MOEDA", AV_TAMANHO)),;
        aMovOri  := {}

Private cBcoDes  := Space(AvSx3("EYR_BANCO", AV_TAMANHO)),;
        cNBcoDes := Space(AvSx3("EYR_NOMBCO", AV_TAMANHO)),;
        cAgeDes  := Space(AvSx3("EYR_AGEN", AV_TAMANHO)),;
        cCntDes  := Space(AvSx3("EYR_CONTA", AV_TAMANHO)),;
        cPaiDes  := Space(AvSx3("EYR_PAIS", AV_TAMANHO)),;
        cNatDes  := Space(AvSx3("EYR_NATURE", AV_TAMANHO)),;
        dDtDes   := CToD("  /  /  "),;
        cMoeDes  := Space(AvSx3("EYR_MOEDA", AV_TAMANHO)),;
        aMovDes  := {}

Private nValMov := 0,;
        nValBco := 0,;
        nValDes := 0

Private lOk := .F.
Private aCampos := {}

Begin Sequence
 
   If EasyEntryPoint("EECAD101")
      lRetPto := ExecBlock("EECAD101",.f.,.f.,{"ANTES_TELA_TRANSF"})
      If ValType(lRetPto) = "L" .And. !lRetPto
         Break
      EndIf
   EndIf

   DEFINE MSDIALOG oDlgTrf TITLE cTitulo + " - " + STR0007 FROM 0,0 TO 540,400 OF oMainWnd PIXEL//Transferir
      oDlgTrf:lEscClose := .F.
      
      //*** Origem
      @ nLin, 5 To nLin + 125, 197 LABEL STR0015 PIXEL OF oDlgTrf//"Origem"

      nLin += nJumpLine
      
      @ nLin+1, nCol1 SAY STR0016 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Banco"
      @ nLin, nCol2 MSGET cBcoOri F3 "BC6" Valid Vazio() .Or. AD101Vld("cBcoOri") Size 15, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0017 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Agencia"
      @ nLin, nCol2 MSGET cAgeOri Valid Vazio() .Or. AD101Vld("cAgeOri") Size 25, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0018 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Conta"
      @ nLin, nCol2 MSGET cCntOri Valid Vazio() .Or. AD101Vld("cCtaOri") Size 45, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0019 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Nome Banco"
      @ nLin, nCol2 MSGET cNBcoOri WHEN .F. Size 130, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0020 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Pa�s"
      @ nLin, nCol2 MSGET cPaiOri WHEN .F. Size 13, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0021 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Natureza"
      @ nLin, nCol2 MSGET cNatOri VALID Vazio() .Or. ExistCpo("EYQ", cNatOri) F3 "EYQ" Size 13, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0022 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Data"
      @ nLin, nCol2 MSGET dDtOri VALID AD101Vld("DTORI") Size 25, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0023 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Moeda Mov."
      @ nLin, nCol2 MSGET cMoeMov F3 "SYF" VALID Vazio() .Or. (ExistCpo("SYF") .And. AD101Vld("cMoeMov")) Size 13, 08 PIXEL OF oDlgTrf

      @ nLin+1, nCol3 SAY STR0024 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Valor Mov."
      @ nLin, nCol4 MSGET nValMov VALID Positivo() .And. AD101Vld("nValMov") PICTURE "@E 999,999,999,999.99" Size 60, 08 PIXEL OF oDlgTrf      

      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0025 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Moeda Bco."
      @ nLin, nCol2 MSGET cMoeBco WHEN .F. Size 13, 08 PIXEL OF oDlgTrf

      @ nLin+1, nCol3 SAY STR0026 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Valor Bco."
      @ nLin, nCol4 MSGET nValBco VALID Positivo() PICTURE "@E 999,999,999,999.99" Size 60, 08 PIXEL OF oDlgTrf

      nLin += nJumpLine*2
      //***
      
      If EasyEntryPoint("EECAD101")
         ExecBlock("EECAD101",.f.,.f.,{"TELA_TRANSF_DEPOIS_ORIGEM"})
      EndIf

      //*** Destino
      @ nLin, 5 To nLin + 115, 197 LABEL "Destino" PIXEL OF oDlgTrf

      nLin += nJumpLine
      
      @ nLin+1, nCol1 SAY STR0016 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Banco"
      @ nLin, nCol2 MSGET cBcoDes Valid Vazio() .Or. AD101Vld("cBcoDes") F3 "BC6" Size 15, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0017 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Agencia"
      @ nLin, nCol2 MSGET cAgeDes Valid Vazio() .Or. AD101Vld("cAgeDes") Size 25, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0018 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Conta"
      @ nLin, nCol2 MSGET cCntDes Valid Vazio() .Or. AD101Vld("cCntDes") Size 45, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0019 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Nome Banco"
      @ nLin, nCol2 MSGET cNBcoDes WHEN .F. Size 130, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0020 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Pa�s"
      @ nLin, nCol2 MSGET cPaiDes WHEN .F. Size 13, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0021 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Natureza"
      @ nLin, nCol2 MSGET cNatDes VALID Vazio() .Or. ExistCpo("EYQ", cNatDes) F3 "EYQ" Size 13, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0022 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Data"
      @ nLin, nCol2 MSGET dDtDes Size 25, 08 PIXEL OF oDlgTrf
      nLin += nJumpLine
      @ nLin+1, nCol1 SAY STR0027 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Moeda"
      @ nLin, nCol2 MSGET cMoeDes F3 "SYF" VALID Vazio() .Or. ExistCpo("SYF") WHEN .F. Size 13, 08 PIXEL OF oDlgTrf

      @ nLin+1, nCol3 SAY STR0028 PIXEL COLOR CLR_HBLUE OF oDlgTrf//"Valor"
      @ nLin, nCol4 MSGET nValDes VALID Positivo() PICTURE "@E 999,999,999,999.99" Size 60, 08 PIXEL OF oDlgTrf
      //***

      If EasyEntryPoint("EECAD101")
         ExecBlock("EECAD101",.f.,.f.,{"TELA_TRANSF_DEPOIS_DESTINO"})
      EndIf

   ACTIVATE MSDIALOG oDlgTrf ON INIT EnchoiceBar(oDlgTrf,bOk,bCancel) CENTERED
   
   If lOk
      aAdd(aMovOri, {"EYR_BANCO"  , cBcoOri   })
      aAdd(aMovOri, {"EYR_AGEN"   , cAgeOri   })
      aAdd(aMovOri, {"EYR_CONTA"  , cCntOri   })
      aAdd(aMovOri, {"EYR_NATURE" , cNatOri   })
      aAdd(aMovOri, {"EYR_DATA"   , dDtOri    })
      aAdd(aMovOri, {"EYR_MOEDA"  , cMoeBco   })
      aAdd(aMovOri, {"EYR_VALOR"  , nValBco   })
      aAdd(aMovOri, {"EYR_MOEINI" , cMoeMov   })
      aAdd(aMovOri, {"EYR_VALINI" , nValMov   })

      If EasyEntryPoint("EECAD101")
         ExecBlock("EECAD101",.f.,.f.,{"DEFINE_MOV_ORIGEM"})
      EndIf
      
      AD101MAN(,, INCLUIR,, aMovOri)

      aAdd(aMovDes, {"EYR_BANCO"  , cBcoDes   })
      aAdd(aMovDes, {"EYR_AGEN"   , cAgeDes   })
      aAdd(aMovDes, {"EYR_CONTA"  , cCntDes   })
      aAdd(aMovDes, {"EYR_NATURE" , cNatDes   })
      aAdd(aMovDes, {"EYR_DATA"   , dDtDes    })
      aAdd(aMovDes, {"EYR_MOEDA"  , cMoeDes   })
      aAdd(aMovDes, {"EYR_VALOR"  , nValDes   })

      If EasyEntryPoint("EECAD101")
         ExecBlock("EECAD101",.f.,.f.,{"DEFINE_MOV_DESTINO"})
      EndIf

      AD101MAN(,, INCLUIR,, aMovDes)
   EndIf

End Sequence

Return lOk

/*
Funcao      : AD101AtuSld(cBco, cAge, cCnt, cAnoMes)
Parametros  : cBco    - C�digo do banco
              cAge    - C�digo da ag�ncia
              cCnt    - C�digo da conta
              cAnoMes - Ano/M�s da atualiza��o
Retorno     : lRet
Objetivos   : Atualizar o saldo da conta no exterior para o Ano/M�s informado, gerando/atualizando movimenta��o especial
              de controle de saldo
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/11/07 - 09:00
Revisao     : 
Obs.        : 
*/
Static Function AD101AtuSld(cBco, cAge, cCnt, cAnoMes)
Local aOrd := SaveOrd("EYR"), aEYR := {}
Local nSaldo := 0
Local lDiferenca := .F.
Local bApura := {|nVal, cTip| If(cTip == "1", nVal, (nVal * -1))}
Local lRet := .F.
Local cMesAnt

   EYR->(DbSetOrder(2))
   If EYR->(DbSeek(xFilial()+cBco+cAge+cCnt+cAnoMes))
      While EYR->(!Eof() .And. EYR_FILIAL+EYR_BANCO+EYR_AGEN+EYR_CONTA+EYR_ANOMES == xFilial()+cBco+cAge+cCnt+cAnoMes)
         If EYR->EYR_NATURE <> NAT_SALDO .And. EYR->EYR_FLAG $ cSim
            nSaldo += Eval(bApura, EYR->EYR_VALOR, EYR->EYR_TIPMOV)
         EndIf
         EYR->(DbSkip())
      EndDo

      cMesAnt := Left(DToS(  SubMes(SToD(cAnoMes + "01")) ), 6)
      
      nSaldo += AD101GetSld(cBco, cAge, cCnt, cMesAnt)//Saldo at� o m�s anterior
      If EYR->(DbSeek(xFilial()+cBco+cAge+cCnt+cAnoMes+NAT_SALDO))
         If (lRet := EYR->(RecLock("EYR", .F.)))
            lDiferenca := EYR->EYR_VALOR <> nSaldo
            EYR->EYR_VALOR := nSaldo
            EYR->(MsUnlock())
         EndIf
      Else
         lRet := AD101AutoMv(INCLUIR, , cBco, cAge, cCnt, UltimoDia(SToD(cAnoMes + "01")), NAT_SALDO, nSaldo,,,,,,,,, STR0029)//"Movimenta��o de Controle Autom�tico de Saldo."
      EndIf
   EndIf
   If lDiferenca
      //Atualiza o saldo para os meses posteriores
      If EYR->(AvSeekLast(xFilial()+cBco+cAge+cCnt+cAnoMes))
        EYR->(DbSkip())
        If EYR->(!Eof() .And. EYR_FILIAL+EYR_BANCO+EYR_AGEN+EYR_CONTA == xFilial()+cBco+cAge+cCnt)
           AD101AtuSld(cBco, cAge, cCnt, EYR->EYR_ANOMES)
        EndIf
      EndIf
   EndIf

RestOrd(aOrd, .T.)
Return lRet

/*
Funcao      : AD101GetSld(cBco, cAge, cCnt, cAnoMes)
Parametros  : cBco    - C�digo do banco
              cAge    - C�digo da ag�ncia
              cCnt    - C�digo da conta
              cAnoMes - M�s/Ano no qual se deseja saber o saldo da conta/banco
Retorno     : nSaldo - Saldo da conta
Objetivos   : Retornar o saldo da conta/banco no exterior informado
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/11/07 - 11:00
Revisao     : 
Obs.        : 
*/
Function AD101GetSld(cBco, cAge, cCnt, cAnoMes)
Local aOrd := SaveOrd({"EYR", "SA6"})
Local nSaldo := 0
Local cAnoMesIni := "", cAnoMesAnt := ""
Default cAnoMes := ""

Begin Sequence
   
   If ValType(cAge) <> "C"
      SA6->(DbSeek(xFilial()+cBco))
      While SA6->(!Eof() .And. A6_FILIAL+A6_COD == xFilial()+cBco)
         nSaldo += AD101GetSld(SA6->A6_COD, SA6->A6_AGENCIA, SA6->A6_NUMCON, cAnoMes)
         SA6->(DbSkip())
      EndDo
   Else
      cBco := AvKey(cBco,"EYR_BANCO")
      cAge := AvKey(cAge,"EYR_AGEN")
      cCnt := AvKey(cCnt,"EYR_CONTA")
      EYR->(DbSetOrder(2))
      If Empty(cAnoMes)
         If EYR->(AvSeekLast(xFilial()+cBco+cAge+cCnt))
            cAnoMes := EYR->EYR_ANOMES
         Else
            Break
         EndIf
      EndIf
      If BuscaNatSld(cBco, cAge, cCnt, cAnoMes)
         nSaldo := EYR->EYR_VALOR
      Else
         EYR->(DbGoTop())
         If EYR->(DbSeek(xFilial()+cBco+cAge+cCnt))
            cAnoMesIni := EYR->EYR_ANOMES
            cAnoMesAnt := Left(DToS(SubMes(SToD(cAnoMes + "01"))), 6)
            While cAnoMesIni < cAnoMesAnt
               If BuscaNatSld(cBco, cAge, cCnt, cAnoMesAnt)
                  nSaldo := EYR->EYR_VALOR
                  Exit
               Else
                  cAnoMesAnt := Left(DToS(SubMes(SToD(cAnoMesAnt))),6)
               EndIf
            EndDo
         EndIf
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return nSaldo

/*
Funcao      : BuscaNatSld(cBco, cAge, cCnt, cAnoMes)
Parametros  : cBco    - C�digo do banco
              cAge    - C�digo da ag�ncia
              cCnt    - C�digo da conta
              cAnoMes - M�s/Ano no qual se deseja saber o saldo da conta/banco
Retorno     : lFound - Indica se a natureza de controle de saldo foi encontrada
Objetivos   : Procurar a natureza de controle de saldo para o m�s informado
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/11/07 - 11:00
Revisao     : 
Obs.        : 
*/
Static Function BuscaNatSld(cBco, cAge, cCnt, cAnoMes)
Local lFound := .F.
Local nRecno := EYR->(Recno())

   cBco := AvKey(cBco,"EYR_BANCO")
   cAge := AvKey(cAge,"EYR_AGEN")
   cCnt := AvKey(cCnt,"EYR_CONTA")

   EYR->(DbSetOrder(2))
   EYR->(DbSeek(xFilial()+cBco+cAge+cCnt+cAnoMes+NAT_SALDO))
   While EYR->(!Eof() .And. !Bof() .And. EYR_FILIAL+EYR_BANCO+EYR_AGEN+EYR_CONTA+EYR_ANOMES == xFilial()+cBco+cAge+cCnt+cAnoMes)
      If !(EYR->EYR_FLAG $ cSim)
         EYR->(DbSkip(-1))
         Loop
      EndIf
      If EYR->EYR_NATURE == NAT_SALDO
         lFound := .T.
         Exit
      EndIf
      EYR->(DbSkip(-1))
   EndDo

If !lFound
   EYR->(DbGoTo(nRecno))
EndIf
Return lFound

/*
Funcao      : AD101AutoMv(nOpc, cId, cBco, cAge, cCnt, dData, cNat, nValor, cMoeIni, nValIni, cMod, cFilInv, cProcInv, cInv, cParc, cOri, cRef)
Parametros  : nOpc     - Tipo de opera��o (INCLUIR, ALTERAR, etc)
              cId      - C�digo de movimenta��o j� existente
              cBco     - C�digo do banco
              cAge     - C�digo da ag�ncia
              cCnt     - C�digo da conta
              dData    - Data da movimenta��o
              cNat     - C�digo da Natureza
              nValor   - Valor da movimenta��o
              cMoeIni  - C�digo da moeda do valor da movimenta��o, quando diferente da moeda da conta
              nValIni  - Valor da movimenta��o na moeda informada ou na moeda do banco
              cMod     - Indica o m�dulo de origem da movimenta��o ("IMP" - SigaEIC, "EXP" - SigaEEC)
              cFilInv  - Filial da invoice de origem da movimenta��o
              cProcInv - Processo de origem da movimenta��o
              cInv     - C�digo da invoice de origem
              cParc    - Parcela da invoice de origem
              cOri     - Tipo de origem da movimenta��o
              cRef     - Refer�ncia da movimenta��o
Retorno     : lRet
Objetivos   : Incluir uma movimenta��o autom�tica no sistema
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/11/07 - 11:00
Revisao     : 
Obs.        : 
*/
Static Function AD101AutoMv(nOpc, cId, cBco, cAge, cCnt, dData, cNat, nValor, cMoeIni, nValIni, cMod, cFilInv, cProcInv, cInv, cParc, cOri, cRef)
Local aEYR := {}
Local lRet := .T.
Default cOri := "2"
Default cMod := ""
Default dData := dDataBase

Begin Sequence

   Do Case
      Case nOpc == INCLUIR
         If !(cOri $ "1/3")
            cOri := "1"
         EndIf
         //If Empty(cRef)
            //cRef := STR0030//"Inclus�o autom�tica de movimenta��o."
         //EndIf
         aAdd(aEYR, {"EYR_FILIAL" , xFilial("EYR")      })
         aAdd(aEYR, {"EYR_BANCO"  , cBco                })
         aAdd(aEYR, {"EYR_AGEN"   , cAge                })
         aAdd(aEYR, {"EYR_CONTA"  , cCnt                })
         aAdd(aEYR, {"EYR_NATURE" , cNat                })
         aAdd(aEYR, {"EYR_DATA"   , dData               })
         aAdd(aEYR, {"EYR_ANOMES" , Left(DToS(dData), 6)})
         aAdd(aEYR, {"EYR_VALOR"  , nValor              })
         If ValType(cMoeIni) == "C"
            aAdd(aEYR, {"EYR_MOEINI"  , cMoeIni})
         EndIf
         If ValType(nValIni) == "N"
            aAdd(aEYR, {"EYR_VALINI"  , nValIni})
         EndIf
         If Upper(cMod) == "EXP"
            aAdd(aEYR, {"EYR_FILORI" , cFilInv })
            aAdd(aEYR, {"EYR_PREEMB" , cProcInv})
            aAdd(aEYR, {"EYR_NRINVO" , cInv    })
            aAdd(aEYR, {"EYR_PARC"   , cParc   })
         ElseIf Upper(cMod) == "IMP"
            aAdd(aEYR, {"EYR_FILORI", cFilInv })
            aAdd(aEYR, {"EYR_HAWB"  , cProcInv})
            aAdd(aEYR, {"EYR_INVOIC", cInv    })
            aAdd(aEYR, {"EYR_LINHA" , cParc   })
         EndIf
         aAdd(aEYR, {"EYR_ORIGEM", cOri})
         aAdd(aEYR, {"EYR_REF"   , cRef})
         lRet := AD101MAN(,, INCLUIR,, aEYR)
      
      Case nOpc == EXCLUIR
         //If ValType(cRef) <> "C"
            //cRef := STR0031//"Exclus�o autom�tica de movimenta��o."
         //EndIf
         If ValType(cId) == "C"
            EYR->(DbSetOrder(1))
            If !EYR->(DbSeek(xFilial()+AvKey(cId, "EYR_ID")))
               Break
            EndIf
         ElseIf ValType(cFilInv) == "C" .And. ValType(cProcInv) == "C" .And. ValType(cInv) == "C" .And. ValType(cParc) == "C"
            If !AD101FndInv(cMod, cFilInv, cProcInv, cInv, cParc, cNat)
               Break
            EndIf
         Else
            Break
         EndIf
         aAdd(aEYR, {"EYR_FILIAL" , EYR->EYR_FILIAL})
         aAdd(aEYR, {"EYR_ID"     , EYR->EYR_ID})
         aAdd(aEYR, {"EYR_REF"   , cRef})
         lRet := AD101MAN(,, EXCLUIR,, aEYR)

   End Case

End Sequence

Return lRet

/*
Funcao     : AD101FndInv(cMod, cFilInv, cProcInv, cInv, cParc, cNat, lUser, lCancel)
Parametros : cMod - M�dulo de origem ("IMP" - SigaEIC, "EXP" - SigaEEC)
Retorno    : lRet - Informa se a invoice foi encontrada
Objetivos  : Verificar se uma invoice de importa��o/exporta��o no sistema
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 07/11/07 - 11:00
*/
Function AD101FndInv(cMod, cFilInv, cProcInv, cInv, cParc, cNat, lUser, lCancel)
Local lRet := .F.
Default lUser := .F.
Default lCancel := .F.

   Do Case
     Case Upper(cMod) == "EXP"
        EYR->(DbSetOrder(4))
        If EYR->(DbSeek(xFilial()+AvKey(cFilInv, "EYR_FILORI")+AvKey(cProcInv, "EYR_PREEMB")+AvKey(cInv, "EYR_NRINVO")+AvKey(cParc, "EYR_PARC")))
           While EYR->(EYR_FILIAL+EYR_FILORI+EYR_PREEMB+EYR_NRINVO+EYR_PARC) == xFilial("EYR")+AvKey(cFilInv, "EYR_FILORI")+AvKey(cProcInv, "EYR_PREEMB")+AvKey(cInv, "EYR_NRINVO")+AvKey(cParc, "EYR_PARC")
              If lUser .Or. EYR->EYR_ORIGEM $ "1/3"
                 If (lCancel .Or. EYR->EYR_FLAG <> CANCELADO) .And. (ValType(cNat) <> "C" .Or. EYR->EYR_NATURE == cNat)
                    lRet := .T.
                    Exit
                 EndIf
              EndIf
              EYR->(DbSkip())
           EndDo
        EndIf

     Case Upper(cMod) == "IMP"
        EYR->(DbSetOrder(5))
        If EYR->(DbSeek(xFilial()+AvKey(cFilInv, "EYR_FILORI")+AvKey(cProcInv, "EYR_HAWB")+AvKey(cInv, "EYR_INVOIC")+AvKey(cParc, "EYR_LINHA")))
           While EYR->(EYR_FILIAL+EYR_FILORI+EYR_HAWB+EYR_INVOIC+EYR_LINHA) == xFilial("EYR")+AvKey(cFilInv, "EYR_FILORI")+AvKey(cProcInv, "EYR_HAWB")+AvKey(cInv, "EYR_INVOIC")+AvKey(cParc, "EYR_LINHA")
              If lUser .Or. EYR->EYR_ORIGEM $ "1/3"
                 If lCancel .Or. EYR->EYR_FLAG <> CANCELADO
                    lRet := .T.
                    Exit
                 EndIf
              EndIf
              EYR->(DbSkip())
           EndDo
        EndIf

   End Case

Return lRet

/*
Funcao      : AD101GrvInv(cAliasBase, cAliasTemp, cMod, lDel, lBase, lIncluir, lExcluir)
Parametros  : cAliasBase - Alias da tabela da base de dados de 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/11/07 - 11:00
Revisao     : 
Obs.        : 
*/
Function AD101GrvInv(cAliasBase, cAliasTemp, cMod, lDel, lBase, lIncluir, lExcluir)
Local aOrd, aSave
Local lRet := .T.
Local lBaixaGerencial := .F. // jpm
// ** JPM - 10/12/2009 - passados por par�metros para que a fun��o que chama saiba se foram feitas as inclus�es ou exclus�es
//Local lIncluir := .F., lExcluir := .F.
Default cMod := ""
Default lDel := .F.
Default lBase := .T.
   aSave := {"EYR"}
   If cAliasBase <> "M"
      AAdd(aSave,cAliasBase)
   EndIf
   If cAliasTemp <> "M"
      AAdd(aSave,cAliasTemp)
   EndIf

   aOrd := SaveOrd(aSave)
   
   lIncluir := .F.// ** JPM - 10/12/2009 - passado por par�metro para que a fun��o que chama saiba se foram feitas as inclus�es ou exclus�es
   
   lExcluir := lDel
   If !lExcluir
      lExcluir := lIncluir := Ad101ChkInv(cAliasBase, cAliasTemp, cMod, ALTERAR, lBase)
   EndIf
   If !lExcluir .And. !lIncluir
      lExcluir := Ad101ChkInv(cAliasBase, cAliasTemp, cMod, EXCLUIR, lBase)
      lIncluir := Ad101ChkInv(cAliasBase, cAliasTemp, cMod, INCLUIR, lBase)
   EndIf

   Do Case
      Case (lBaixaGerencial := (Upper(cMod) == "EXPBXG")) .Or. Upper(cMod) == "EXPLIQ"
         If lExcluir
            //Cancela a movimenta��o anterior
            lRet := AD101AutoMv(EXCLUIR,;
                                ,;
                                RetField("EEQ_BCOEXT",, cAliasTemp, .T.),;
                                RetField("EEQ_AGCEXT",, cAliasTemp, .T.),;
                                RetField("EEQ_CNTEXT",, cAliasTemp, .T.),;
                                ,;
                                GetNatureza(cMod,RetField("EEQ_EVENT" ,, cAliasTemp, .T.)),;
                                ,;
                                ,;
                                ,;
                                "EXP",;
                                xFilial("EEQ"),;
                                RetField("EEQ_PREEMB",, cAliasTemp, .T.),;
                                RetField("EEQ_NRINVO",, cAliasTemp, .T.),;
                                RetField("EEQ_PARC"  ,, cAliasTemp, .T.),;
                                "1")//Origem - Sistema
         EndIf
         If lIncluir
            lRet := AD101AutoMv(INCLUIR,;
                                ,;
                                RetField("EEQ_BCOEXT",, cAliasTemp, .T.),;
                                RetField("EEQ_AGCEXT",, cAliasTemp, .T.),;
                                RetField("EEQ_CNTEXT",, cAliasTemp, .T.),;
                                RetField(If(lBaixaGerencial,"EEQ_DTCE","EEQ_PGT")  ,, cAliasTemp, .T.),;
                                GetNatureza(cMod,RetField("EEQ_EVENT" ,, cAliasTemp, .T.)),;
                                RetField("EEQ_VL",, cAliasTemp, .T.) - RetField("EEQ_CGRAFI",, cAliasTemp, .T.),;// AAF 26/02/08 - Subtrair comiss�o conta gr�fica. //RetField("EEQ_VL",, cAliasTemp, .T.),;
                                ,;
                                ,;
                                "EXP",;
                                xFilial("EEQ"),;
                                RetField("EEQ_PREEMB",, cAliasTemp, .T.),;
                                RetField("EEQ_NRINVO",, cAliasTemp, .T.),;
                                RetField("EEQ_PARC"  ,, cAliasTemp, .T.),;
                                "1")//Origem - Sistema
         EndIf
      
      Case Upper(cMod) == "IMP" .Or. Upper(cMod) == "IMPFFC"
         If lExcluir
            lRet := AD101AutoMv(EXCLUIR,;
                                ,;
                                RetField("WB_BANCO"  , cMod, cAliasTemp, .T.),;
                                RetField("WB_AGENCIA", cMod, cAliasTemp, .T.),;
                                RetField("WB_CONTA"  , cMod, cAliasTemp, .T.),;
                                ,;
                                GetNatureza(cMod,RetField("WB_EVENT",, cAliasTemp, .T.)),;
                                ,;
                                ,;
                                ,;
                                "IMP",;
                                xFilial("SWB"),;
                                RetField("WB_HAWB"   , cMod, cAliasTemp, .T.),;
                                RetField("WB_INVOICE", cMod, cAliasTemp, .T.),;
                                RetField("WB_LINHA"  , cMod, cAliasTemp, .T.),;
                                "1")//Origem - Sistema
         EndIf

         If lIncluir
            lRet := AD101AutoMv(INCLUIR,;
                                ,;
                                RetField("WB_BANCO"  , cMod, cAliasTemp, .T.),;
                                RetField("WB_AGENCIA", cMod, cAliasTemp, .T.),;
                                RetField("WB_CONTA"  , cMod, cAliasTemp, .T.),;
                                RetField("WB_CA_DT"  , cMod, cAliasTemp, .T.),;
                                GetNatureza(cMod,RetField("WB_EVENT",, cAliasTemp, .T.)),;
                                RetField("WK_VALBCO" , cMod, cAliasTemp, .T.),;
                                RetField("WB_MOEDA"  , cMod, cAliasTemp, .T.),;
                                RetField("WB_FOBMOE" , cMod, cAliasTemp, .T.),;
                                "IMP",;
                                xFilial("SWB"),;
                                RetField("WB_HAWB"   , cMod, cAliasTemp, .T.),;
                                RetField("WB_INVOICE", cMod, cAliasTemp, .T.),;
                                RetField("WB_LINHA"  , cMod, cAliasTemp, .T.),;
                                "1")//Origem - Sistema
         EndIf
         

   End Case

RestOrd(aOrd, .T.)
Return lRet

/*
Funcao     : 
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 07/11/07 - 11:00
*/
Function GetNatureza(cMod,cEvent)
Local cNat := ""
Default cEvent := Space(Len(EEQ->EEQ_EVENT))

   If cMod == "EXPLIQ"
      cNat := EasyGParam("MV_AVG0145",,"208")
   Else
      If Left(cMod,3) == "EXP"
         cTpModu := AvKey("EXPORT","EC6_TPMODU")
      Else
         cTpModu := AvKey("IMPORT","EC6_TPMODU")
      EndIf
      
      EC6->(dbSetOrder(1))
      EC6->(dbSeek(xFilial("EC6")+cTpModu+cEvent))
      cNat := EC6->EC6_NATURE
   EndIf
   
Return cNat

/*
Funcao     : 
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 07/11/07 - 11:00
*/
Function Ad101ChkInv(cAliasBase, cAliasTemp, cMod, nOpc, lBase)
Local lRet := .F.

   Do Case
      Case Upper(cMod) == "EXPBXG" .And. nOpc == INCLUIR
         lRet := (&(cAliasTemp+"->EEQ_CONTMV") == "1") .And. !Empty(&(cAliasTemp+"->EEQ_DTCE"))
         If lRet .And. lBase
            lRet := (&(cAliasBase+"->EEQ_CONTMV") <> "1") .Or. Empty(&(cAliasBase+"->EEQ_DTCE"))
         EndIf

      Case Upper(cMod) == "EXPBXG" .And. nOpc == ALTERAR
          If lBase .And. (&(cAliasTemp+"->EEQ_CONTMV") == "1") .And. !Empty(&(cAliasTemp+"->EEQ_DTCE"))
             If (&(cAliasBase+"->EEQ_CONTMV") == "1") .And. !Empty(&(cAliasBase+"->EEQ_DTCE"))
                lRet := (&(cAliasTemp+"->EEQ_VL") <> &(cAliasBase+"->EEQ_VL")) .Or.;
                        (&(cAliasTemp+"->EEQ_DTCE") <> &(cAliasBase+"->EEQ_DTCE"))
             EndIf
          EndIf

      Case Upper(cMod) == "EXPBXG" .And. nOpc == EXCLUIR
         If lBase
            lRet := (&(cAliasTemp+"->EEQ_CONTMV") <> "1") .Or. Empty(&(cAliasTemp+"->EEQ_DTCE"))
            If lRet
               lRet := (&(cAliasBase+"->EEQ_CONTMV") == "1") .Or. !Empty(&(cAliasBase+"->EEQ_DTCE"))
            EndIf
         EndIf
         
      Case Upper(cMod) == "EXPLIQ" .And. nOpc == INCLUIR
         lRet := (&(cAliasTemp+"->EEQ_CONTMV") == "1") .And. !Empty(&(cAliasTemp+"->EEQ_PGT")) .And. Empty(&(cAliasTemp+"->EEQ_EICHAW"))
         If lRet .And. lBase
            lRet := (&(cAliasBase+"->EEQ_CONTMV") <> "1") .Or. Empty(&(cAliasBase+"->EEQ_PGT"))
         EndIf

      Case Upper(cMod) == "EXPLIQ" .And. nOpc == ALTERAR
          If lBase .And. (&(cAliasTemp+"->EEQ_CONTMV") == "1") .And. !Empty(&(cAliasTemp+"->EEQ_PGT")) .And. Empty(&(cAliasTemp+"->EEQ_EICHAW"))
             lRet := (&(cAliasTemp+"->EEQ_VL") <> &(cAliasBase+"->EEQ_VL")) .Or.;
                     (&(cAliasTemp+"->EEQ_PGT") <> &(cAliasBase+"->EEQ_PGT"))
          EndIf

      Case Upper(cMod) == "EXPLIQ" .And. nOpc == EXCLUIR
         If lBase .And. Empty(&(cAliasTemp+"->EEQ_EICHAW"))
            lRet := (&(cAliasTemp+"->EEQ_CONTMV") <> "1") .Or. Empty(&(cAliasTemp+"->EEQ_PGT"))
            If lRet
               lRet := (&(cAliasBase+"->EEQ_CONTMV") == "1") .Or. !Empty(&(cAliasBase+"->EEQ_PGT"))
            EndIf
         EndIf
         
      Case (Upper(cMod) == "IMP" .Or. Upper(cMod) == "IMPFFC") .And. nOpc == INCLUIR
         If Upper(cMod) == "IMPFFC"
            // ** JPM - para FFC, sempre que estiver chamando o fechamento, vai executar (independente se alterou ou n�o)
            lRet := RetField("WB_TIPOPAG", cMod, cAliasTemp, .T.) == "2" .And. !Empty(RetField("WB_CA_DT", cMod, cAliasTemp, .T.))
         Else
            lRet := (RetField("WB_TIPOPAG", cMod, cAliasTemp, .T.) == "2") .And. !Empty(RetField("WB_CA_DT", cMod, cAliasTemp, .T.))
            If lRet .And. lBase
               lRet := (RetField("WB_TIPOPAG", cMod, cAliasBase, .T.) <> "2") .Or. Empty(RetField("WB_CA_DT", cMod, cAliasBase, .T.))
            EndIf
         EndIf

      Case (Upper(cMod) == "IMP" .Or. Upper(cMod) == "IMPFFC") .And. nOpc == ALTERAR
         If Upper(cMod) == "IMPFFC" // ** JPM - FFC n�o possui altera��o de fechamento
            lRet := .F.
         Else
            If lBase .And. (RetField("WB_TIPOPAG", cMod, cAliasTemp, .T.) == "2") .And. !Empty(RetField("WB_CA_DT", cMod, cAliasTemp, .T.))
               lRet := (RetField("WB_CA_DT", cMod, cAliasTemp, .T.) <> RetField("WB_CA_DT", cMod, cAliasBase, .T.)) .Or.;
                       (RetField("WB_FOBMOE", cMod, cAliasTemp, .T.) <> RetField("WB_FOBMOE", cMod, cAliasBase, .T.))
            EndIf
         EndIf

      Case (Upper(cMod) == "IMP" .Or. Upper(cMod) == "IMPFFC") .And. nOpc == EXCLUIR
         If lBase
            lRet := (RetField("WB_TIPOPAG", cMod, cAliasTemp, .T.) <> "2") .Or. (Empty(RetField("WB_CA_DT", cMod, cAliasTemp, .T.)))
            If lRet
               lRet := (RetField("WB_TIPOPAG", cMod, cAliasBase, .T.) == "2") .And. (!Empty(RetField("WB_CA_DT", cMod, cAliasBase, .T.)))
            EndIf
         EndIf
         
   End Case

Return lRet

/*
Funcao     : 
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 07/11/07 - 11:00
*/
Function Ad101ValBco(nValor, cMoeda, cMoeBco, nValBco, dData, lReceita)
Local oDlg
Local bOk := {|| lOk := .T., oDlg:End() },;
      bCancel := {|| oDlg:End() }
Local cCreDes := If(lReceita, "creditado", "debitado")
Local lOk := .F.
Default nValBco := 0

   If cMoeda <> cMoeBco
      If nValBco == 0
         nValBco := AD101ConVal(nValor, cMoeda, cMoeBco, dData)
      EndIf
      
      DEFINE MSDIALOG oDlg TITLE STR0034 FROM 0,0 TO 250,517 OF oMainWnd PIXEL//"Transfer�ncia no Exterior"
      aPOs := PosDlg(oDlg)
      
         @ aPos[1],aPos[2] TO aPos[3], aPos[4] LABEL "" PIXEL OF oDlg
         @ 25, 10 SAY  StrTran(StrTran(STR0035, "XXX", cMoeda), "YYY", cMoeBco) PIXEL OF oDlg//"A moeda da(s) invoice(s) (XXX) � diferente da moeda informada no cadastro da conta utilizada (YYY)."
         @ 35, 10 SAY  StrTran(STR0036, "XXX", cCreDes) PIXEL OF oDlg//"O sistema apurou o valor que ser� XXX na conta com base nas cota��es cadastradas."
         @ 45, 10 SAY  STR0037 PIXEL OF oDlg//"Por favor verifique o valor e ajuste-o caso necess�rio."

         @ 67, 10 SAY  STR0038 PIXEL OF oDlg//"Moeda da(s) Invoice(s):"
         @ 65, 70 MSGET cMoeda WHEN .F. PIXEL OF oDlg
         @ 67, 110 SAY  STR0039 PIXEL OF oDlg//"Valor da(s) Invoice(s):"
         @ 65, 165 MSGET nValor PICTURE AvSx3("EYR_VALOR", AV_PICTURE) WHEN .F. PIXEL OF oDlg
         
         
         @ 87, 10 SAY STR0040 PIXEL OF oDlg//"Moeda da Conta:"
         @ 85, 70 MSGET cMoeBco WHEN .F. PIXEL OF oDlg         
         @ 87, 110 SAY  StrTran(STR0041, "XXX", cCreDes) PIXEL OF oDlg//"Valor XXX:"
         @ 85, 165 MSGET nValBco PICTURE AvSx3("EYR_VALOR", AV_PICTURE) VALID Positivo(nValBco) PIXEL OF oDlg
   
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

      If !lOk
         nValBco := -1
      EndIf

   Else
      nValBco := nValor
   EndIf

Return nValBco

/*
Funcao     : 
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 07/11/07 - 11:00
*/
Function IsBancoExt(cBco, cAge, cCnt)
Local lRet := .F.
Local aOrd := SaveOrd("SA6")

  If  SA6->(DbSeek(xFilial()+cBco+cAge+cCnt))
     lRet := !Empty(SA6->A6_MOEEASY) .And. SA6->A6_CONEXP == "1"
  EndIf

RestOrd(aOrd, .T.)
Return lRet

/*
Funcao     : 
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 07/11/07 - 11:00
*/
Static Function RetField(cCampo, cOri, cAlias, lRetCont)
Local cRet := "", nPerc
Default cAlias := "M"
Default lRetCont := .F.

Begin Sequence
Do Case
   Case cCampo == "BANCO"
      If cOri == "Ori"
         cRet := "cBcoOri"
      ElseIf cOri == "Des"
         cRet := "cBcoDes"
      Else
         cRet := "M->EYR_BANCO"
      EndIf
      
   Case cCampo == "AGENCIA"
      If cOri == "Ori"
         cRet := "cAgeOri"
      ElseIf cOri == "Des"
         cRet := "cAgeDes"
      Else
         cRet := "M->EYR_AGEN"
      EndIf

   Case cCampo == "CONTA"
      If cOri == "Ori"
         cRet := "cCntOri"
      ElseIf cOri == "Des"
         cRet := "cCntDes"
      Else
         cRet := "M->EYR_CONTA"
      EndIf

   Case cCampo == "NOME"
      If cOri == "Ori"
         cRet := "cNBcoOri"
      ElseIf cOri == "Des"
         cRet := "cNBcoDes"
      Else
         cRet := "M->EYR_NOMBCO"
      EndIf

   Case cCampo == "MOEDA"
      If cOri == "Ori"
         cRet := "cMoeBco"
      ElseIf cOri == "Des"
         cRet := "cMoeDes"
      Else
         cRet := "M->EYR_MOEDA"
      EndIf
   
   Case cCampo == "MOEINI"
      If cOri == "Ori"
         cRet := "cMoeMov"
      //AAF 03/03/08 - O retorno padr�o � o campo na mem�ria.
      //ElseIf cOri == "M" 
      Else
         cRet := "M->EYR_MOEINI"
      EndIf
   
   Case cCampo == "DATA"
      If cOri == "Ori"
         cRet := dDtOri
      ElseIf cOri == "Des"
         cRet := dDtDes
      Else
         cRet := "EYR_DATA"
      EndIf

   Case cCampo == "PAIS"
      If cOri == "Ori"
         cRet := "cPaiOri"
      ElseIf cOri == "Des"
         cRet := "cPaiDes"
      Else
         cRet := "M->EYR_PAIS"
      EndIf

   Case cCampo == "VALOR"
      If cOri == "Ori"
         cRet := "nValBco"
      ElseIf cOri == "Des"
         cRet := "nValBco"
      Else
         cRet := "M->EYR_VALOR"
      EndIf

   Case cCampo == "VALORINI"
      If cOri == "Ori"
         cRet := "nValMov"
      Else
         cRet := "M->EYR_VALINI"
      EndIf

   Case cCampo == "WB_BANCO"
      If cOri == "IMPFFC" .And. cAlias == "M"
         cRet := "TBanco"
      Else
         cRet := cCampo
      EndIf

   Case cCampo == "WB_CONTA"
      If cOri == "IMPFFC" .And. cAlias == "M"
         cRet := "TConta"
      Else
         cRet := cCampo
      EndIf

   Case cCampo == "WB_AGENCIA"
      If cOri == "IMPFFC" .And. cAlias == "M"
         cRet := "TAgencia"
      Else
         cRet := cCampo
      EndIf

   Case cCampo == "WB_DT_DESE"
      If cOri == "IMPFFC" .And. cAlias == "M"
         cRet := "TDt_Dese"
      Else
         cRet := cCampo
      EndIf

   Case cCampo == "WK_VALBCO"
      If cOri == "IMPFFC" .And. cAlias == "M"
         nPerc := If(SWB->WB_PO_DI == 'A', SWB->WB_PGTANT, SWB->WB_FOBMOE) / nParcSel
         nAD101_VLPC := nAD101_VLTO * nPerc
         cRet := "nAD101_VLPC"
      Else
         cRet := cCampo
      EndIf

   Case cCampo == "WB_MOEDA"
      If cOri == "IMPFFC" .And. cAlias == "M"
         cRet := "TMoeda"
      Else
         cRet := cCampo
      EndIf

   Case cCampo == "WB_FOBMOE"
      If cOri == "IMPFFC" .And. cAlias == "M"
         cRet := If(SWB->WB_PO_DI == 'A', "WB_PGTANT", "WB_FOBMOE")
         cAlias := "SWB"
      Else
         cRet := If(&(cAlias + "->WB_PO_DI") == 'A', "WB_PGTANT", "WB_FOBMOE")
      EndIf

   Case cCampo == "WB_HAWB"
      If cOri == "IMPFFC" .And. cAlias == "M"
         cAlias := "SWB"
      EndIf
      cRet := cCampo

   Case cCampo == "WB_INVOICE"
      If cOri == "IMPFFC" .And. cAlias == "M"
         cAlias := "SWB"
      EndIf
      cRet := cCampo

   Case cCampo == "WB_LINHA"
      If cOri == "IMPFFC" .And. cAlias == "M"
         cAlias := "SWB"
      EndIf
      cRet := cCampo
   
   OtherWise
      cRet := cCampo

EndCase
End Sequence

If lRetCont
   cRet := &(cAlias+"->"+cRet)
EndIf

Return cRet


/*
Fun��o        : Ad101VincExp
Objetivos     : Validar a exist�ncia da classe
Autor         : Wilsimar Fabr�cio da Silva
Data          : 02/06/2010
*/

Function Ad101VincExp()
Return Nil

/*
Classe        : Ad101VincExp
Objetivos     : Encapsulamento da rotina de Vincula��o e Desvinc. de parcelas de c�mbio de importa��o 
                a parcelas de exporta��o na liquida��o, quando for "Transfer�ncia no Exterior", para a nova legs. cambial.
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/

Class Ad101VincExp
   
   Data   aFiles      AS ARRAY     HIDDEN // Arquivos da work
   Data   lFFC        AS LOGICAL   HIDDEN // Define se est� na rotina de FFC de importa��o
   Data   lAtivado    AS LOGICAL   HIDDEN // Define se a rotina est� ativada
   Data   cAliasVinc  AS CHARACTER HIDDEN // alias da work interna de vincula��es
   Data   cAliasEEQ   AS CHARACTER HIDDEN // Alias da work da tela de vincula��es
   Data   aAlias      AS ARRAY     HIDDEN // Alias utilizados
   Data   aStructEEQ  AS ARRAY     HIDDEN // Estrutura da work do EEQ
   Data   cAliasTRB   AS CHARACTER HIDDEN // Alias do TRB das parcelas de importa��o
   Data   aParc       AS ARRAY     HIDDEN // Array q armazena altera��es nas parcelas
   Data   cAliasBx    AS CHARACTER HIDDEN
   
   Method New(lFFC) Constructor // Nova transa��o
   Method Destroy()
   
   Method CriaWorkVinc()
   Method CriaWorkEEQ()
   Method ApagaWork()

   Method Release()
   
   Method ValVincExp()         // Validar tela de liquida��o, e talvez mostrar a tela de vinc. de parc. de exporta��o para cada parcela.
   Method TelaVinc()           // Mostrar tela de vincula��o
   Method SelecDados()
   Method AcaoVinc(cTipo,xAux)
   Method GravaVinc(lIncluiMov,lExcluiMov)
   Method BaixaAutomatica(nValor, lEstorno)
   Method AuxBaixa(aRecno,lQuebra)
   
   Method EstDadosTRB()
   
EndClass

/*
M�todo        : New()
Classe        : Ad101VincExp
Objetivos     : inicializa��o da rotina
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method New(lFFC; // Define se � FFC.
           ) Class Ad101VincExp
   
   Self:lAtivado := EECFlags("CAMBIO_EXT")
   Self:aFiles   := {}
   Self:aAlias   := {}
   
   // ** Define se est� sendo chamado da rotina de FFC
   If ValType(lFFC) <> "L"
      Self:lFFC := .F.
   Else
      Self:lFFC := lFFC
   EndIf
   
   // ** Define as works que est�o sendo utilizadas
   If Self:lFFC
      Self:cAliasTRB := "Work1"
      Self:cAliasBx  := "M"
   Else
      Self:cAliasTRB := "TRB"
      Self:cAliasBx  := Self:cAliasTRB
   EndIf
   
   // ** Se a rotina estiver ativada, cria as works.
   If Self:lAtivado
      Self:CriaWorkVinc()   
   EndIf
   
   // ** Inicia array de parcelas substitu�das.
   Self:aParc := {}
   
Return Self

/*
M�todo        : Destroy()
Classe        : Ad101VincExp
Objetivos     : Fim da rotina
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method Destroy() Class Ad101VincExp
   
   // ** Finalizar o objeto.
   If Self:lAtivado
      Self:Release()
      Self:ApagaWork()
   EndIf

Return (Self := Nil)

/*
M�todo        : CriaWorkVinc()
Classe        : Ad101VincExp
Objetivos     : criar work
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method CriaWorkVinc() Class Ad101VincExp

Local cArq, cArq2
Local aStruct

Begin Sequence
   
   aStruct := {}
   
   If !Self:lAtivado
      Break
   EndIf
   
   // ** Se a work j� est� criada, apenas d� um zap e sai.
   If !Empty(Self:cAliasVinc) .And. Select(Self:cAliasVinc) > 0
      (Self:cAliasVinc)->(avzap())
      Break
   EndIf
   
   Private aHeader:={}
   Private aCampos  := Array(EF3->(FCount()))
   
   AAdd(aStruct,{"TRB_RECNO","C",7,0})
   AAdd(aStruct,{"EEQ_RECNO","C",7,0})
   
   AddCpoWork(aStruct, "EEQ_FILIAL")
   AddCpoWork(aStruct, "EEQ_PREEMB")
   AddCpoWork(aStruct, "EEQ_PARC"  )
   AddCpoWork(aStruct, "EEQ_VL"    )
   
   Self:cAliasVinc := "VINC"
   
   AAdd(Self:aAlias,Self:cAliasVinc)
   
   cArq := E_CriaTrab(, aStruct, Self:cAliasVinc)

   IndRegua(Self:cAliasVinc, cArq+TeOrdBagExt(), "TRB_RECNO")

   cArq2 := CriaTrab(, .F.)
   IndRegua(Self:cAliasVinc, cArq2+TeOrdBagExt(),"EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC")
   
   aAdd(Self:aFiles, {Self:cAliasVinc,{cArq,cArq2}})
   
   Set Index to (cArq+TeOrdBagExt()), (cArq2+TeOrdBagExt())

End Sequence

Return

/*
M�todo        : CriaWorkEEQ()
Classe        : Ad101VincExp
Objetivos     : criar work da tela de vincula��o
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method CriaWorkEEQ() Class Ad101VincExp

Local cArq

Begin Sequence

   If !Self:lAtivado
      Break
   EndIf

   // ** Se a work j� est� criada, apenas d� um zap e sai.
   If !Empty(Self:cAliasEEQ) .And. Select(Self:cAliasEEQ) > 0
      (Self:cAliasEEQ)->(avzap())
      Break
   EndIf

   Self:aStructEEQ := {}
   
   Private aHeader:={}
   Private aCampos  := Array(EF3->(FCount()))
   
   AAdd(Self:aStructEEQ,{"WK_MARCA","C",2,0})
   AAdd(Self:aStructEEQ,{"EEQ_RECNO","N",7,0})
   
   AddCpoWork(Self:aStructEEQ, "EEQ_FILIAL")
   AddCpoWork(Self:aStructEEQ, "EEQ_PREEMB")
   AddCpoWork(Self:aStructEEQ, "EEQ_PARC"  )
   AddCpoWork(Self:aStructEEQ, "EEQ_MOEDA" )
   AddCpoWork(Self:aStructEEQ, "EEQ_VL"    )
   AddCpoWork(Self:aStructEEQ, "EEQ_FFC"   )

   AddCpoWork(Self:aStructEEQ, "WK_SALDO" , "EEQ_VL")
   AddCpoWork(Self:aStructEEQ, "WK_VLVINC", "EEQ_VL")

   AddCpoWork(Self:aStructEEQ, "EEQ_NRINVO")
   AddCpoWork(Self:aStructEEQ, "EEQ_DTCE")
   AddCpoWork(Self:aStructEEQ, "A1_NOME")
   AddCpoWork(Self:aStructEEQ, "YA_NOIDIOM")
   
   Self:cAliasEEQ := "SEL_EEQ"
   
   AAdd(Self:aAlias,Self:cAliasEEQ)
   
   cArq := E_CriaTrab(, Self:aStructEEQ, Self:cAliasEEQ)

   IndRegua(Self:cAliasEEQ, cArq+TeOrdBagExt(), "EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC")

   //cArq2 := CriaTrab(, .F.)
   //IndRegua(Self:cAliasEEQ, cArq2+TeOrdBagExt(),"EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC")
   //aAdd(Self:aFiles, {Self:cAliasEEQ,{cArq,cArq2}})
   
   aAdd(Self:aFiles, {Self:cAliasEEQ,{cArq}})
   
//   Set Index to (cArq+TeOrdBagExt()), (cArq2+TeOrdBagExt())

End Sequence

Return

/*
M�todo        : ApagaWork()
Classe        : Ad101VincExp
Objetivos     : Apagar works
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method ApagaWork() Class Ad101VincExp

Begin Sequence

   If !Self:lAtivado
      Break
   EndIf

   // ** Apaga todas as works utilizadas nesse objeto
   If ValType(Self:aFiles) = "A" // ** Dele��o das works

      Processa({|| ProcRegua(Len(Self:aFiles)),;
                   aEval(Self:aFiles, {|x| (x[1])->(DbCloseArea()),;
                                      aEval(x[2], {|y| FErase(y+TeOrdBagExt()) }),;
                                      IncProc() })},;
               "Aguarde",;
               "Eliminando arquivos tempor�rios")
               
      Break
   EndIf

End Sequence

Return

/*
M�todo        : Release()
Classe        : Ad101VincExp
Objetivos     : Liberar reclocks e dados em mem�ria e work
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method Release() Class Ad101VincExp
Local aRLockList, i

Begin Sequence
   
   If !Self:lAtivado
      Break
   EndIf
   
   // ** Libera locks no EEQ
   aRLockList := EEQ->( DBRLockList() )
   For i := 1  to  Len(aRLockList)
      EEQ->( DBGoTo(aRLockList[i]) )
      EEQ->( MSUnLock() )
   Next i

   // ** Libera locks no EEC
   aRLockList := EEC->( DBRLockList() )
   For i := 1  to  Len(aRLockList)
      EEC->( DBGoTo(aRLockList[i]) )
      EEC->( MSUnLock() )
   Next i
   
   // ** Apaga conte�do das works
   For i := 1 To Len(Self:aAlias)
      If Select(Self:aAlias[i]) > 0
         (Self:aAlias[i])->(avzap())
      EndIf
   Next

   // ** Inicializa array de parcelas substitu�das na quebra.
   Self:aParc := {}
   
End Sequence

Return

/*
M�todo        : ValVincExp()
Classe        : Ad101VincExp
Objetivos     : mostrar a tela de vinc. de parc. de exporta��o para cada parcela.
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method ValVincExp() Class Ad101VincExp
Local lRet := .T.
Local aBrowse, aPos, oDlg, nTot

Private lInverte := .F., cMarca := GetMark()

Begin Sequence

   If !Self:lAtivado
      Break
   EndIf
   
   // ** s� faz vinculos de parcelas de importa��o
   If IIF(lEFFTpMod,Work1->SWBEEQ,"SWB") <> "SWB"
      Break
   EndIf
   
   (Self:cAliasVinc)->(DbGoTop())
   
   // ** S� quando for transfer�ncia no exterior
   If !(M->WB_TIPOPAG == "2")
      Break
   EndIf
   
   aBrowse := AClone(TB_Campos)
   aBrowse[1] := {"WK_VINCEXP","",""}
   
   // ** s� mostra parcelas marcadas
   DbSelectArea("Work1")
   SET FILTER TO !Empty(WKFLAG)
   
   // ** Calcula o valor na moeda do banco para cada parcela (o sistema at� ent�o s� calculou para o total das parcelas)
   nTot := 0
   Work1->(DbGoTop())
   While Work1->(!EoF())
      Work1->WK_VALBCO := (nAD101_VLTO * Work1->WB_FOBMOE) / nParcSel
      nTot += Work1->WK_VALBCO
      
      Work1->(DbSkip())
   EndDo

   If nTot <> nAD101_VLTO
      Work1->(DbSkip(-1))
      Work1->WK_VALBCO -= (nTot - nAD101_VLTO)
   EndIf
   
   Work1->(DbGoTop())
   
   DEFINE MSDIALOG oDlg TITLE "Parcelas de Exporta��o - Clique 2 vezes para vincular" ;
                         FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM*0.75,DLG_COL_FIM*0.95 Pixel

      aPos := PosDlg(oDlg)
      oMark := MsSelect():New(Self:cAliasTRB,"WK_VINCEXP",,aBrowse,@lInverte,@cMarca,aPos)
      oMark:bAval := {|| Self:TelaVinc(),oMark:oBrowse:Refresh() } 

      oCol := oMark:oBrowse:aColumns[1]
      oCol           := TCColumn():New()
      oCol:lBitmap   := .T.
      oCol:lNoLite   := .T.
      oCol:nWidth    := 33
      oCol:bData     := {|| If((Self:cAliasTRB)->WK_VINCEXP="S", "BR_VERDE", "BR_VERMELHO")}
      oCol:cHeading  := ""
      
      oMark:oBrowse:aColumns[1] := oCol
      oDlg:lMaximized := .T.
      
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
                                              {|| If(Self:AcaoVinc("VALIDA_VINC_FFC"),;
                                                     (lRet := .T., oDlg:End()),;
                                                     lRet := .F.) },;
                                              {|| lRet := .F., oDlg:End() }) CENTERED
   
End Sequence

If !lRet
   Self:Release()
EndIf

DbSelectArea("Work1")
SET FILTER TO 

Return lRet

/*
M�todo        : TelaVinc()
Classe        : Ad101VincExp
Objetivos     : Tela para vincula��o de parcelas de exporta��o
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method TelaVinc() Class Ad101VincExp

Local lRet := .T.
Local aOrd := SaveOrd({Self:cAliasTRB,"EEQ"})

// ** Vari�veis de Tela e Controle
Local aPos, bOk, bCancel, aButtons := {}
Local nProp1 := 1.3
// ** Vari�veis para msselect
Private aBrowseParc, lInverte := .F., cMarca := GetMark(), oParc, oDlgVinc, nValAVincular
Private oSayVinc, oGetVinc

Begin Sequence
   If Self:lFFC
      nValAVincular := Work1->WK_VALBCO
   Else
      nValAVincular := M->WK_VALBCO
   EndIf
    
   If !Self:lAtivado
      Break
   EndIf

   // ** Cria Works
   Self:CriaWorkEEQ()

   aBrowseParc := {{"WK_MARCA"  ,,""        };
                  ,{"EEQ_FILIAL",,"Filial"  };
                  ,{"EEQ_PREEMB",,"Embarque"};
                  ,{"EEQ_PARC"  ,,"Parcela" };
                  ,{"EEQ_MOEDA" ,,"Moeda"   };
                  ,{{|| Transf((Self:cAliasEEQ)->EEQ_VL   ,AvSx3("EEQ_VL",AV_PICTURE)) },,"Valor Parc."  };
                  ,{{|| Transf((Self:cAliasEEQ)->WK_SALDO ,AvSx3("EEQ_VL",AV_PICTURE)) },,"Saldo a Vinc."};
                  ,{{|| Transf((Self:cAliasEEQ)->WK_VLVINC,AvSx3("EEQ_VL",AV_PICTURE)) },,"Vl.Vinculado" };
                  ,{"A1_NOME"   ,,"Cliente"};
                  ,{"YA_NOIDIOM",,"Cliente"};
                  ,{"EEQ_DTCE"  ,,"Vencto."};
                  ,{"EEQ_NRINVO",,"Invoice"};
                  ,{"EEQ_FFC"   ,,"FFC"    };
                  }
   
   Processa({|| Self:SelecDados() },"Buscando parcelas de Exporta��o...")
   
   If (Self:cAliasEEQ)->(EoF() .And. BoF())
      If !MsgNoYes("N�o h� parcelas de exporta��o que atendam �s condi��es para vincula��o. "+;
                   "Deseja continuar com a transfer�ncia no exterior?" + ENTER + ENTER+;
                   "As condi��es utilizadas s�o: "+ENTER+;
                   " - Deve controlar movimenta��es no exterior;"+ENTER+;
                   " - Banco/Ag�ncia/Conta no exterior deve ser igual ao banco preenchido;"+ENTER+;
                   " - Data de cr�dito no Exterior deve estar preenchida;"+ENTER+;
                   " - Data de liquida��o n�o pode estar preenchida;"+ENTER+;
                   " - N�o pode estar vinculada a contrato de financiamento de exporta��o;"+ENTER+;
                   "","Aten��o")
         lRet := .F.
      Else
         lRet := .T.
      EndIf
      Break
   EndIf

   DEFINE MSDIALOG oDlgVinc TITLE "Vincula��o de C�mbios de Exporta��o";
      FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM*0.7,DLG_COL_FIM*0.9;
      OF oMainWnd PIXEL
   
      aPos := PosDlg(oDlgVinc)
      
      // ** T�tulo
      @ aPos[1]+5, 5   Say "C�mbios de Exporta��o:" Size 120,8 Pixel Font TFont():New("Arial",9,16)               Of oDlgVinc
      
      // ** Bot�es de Filtro
      @ aPos[1]+5, 100 Button "&Filtro"             Size 30,10 Pixel Action Self:AcaoVinc("FILTRO_INVOICE")       Of oDlgVinc
      @ aPos[1]+5, 130 Button "&Limpar"             Size 30,10 Pixel Action Self:AcaoVinc("LIMPA_FILTRO_INVOICE") Of oDlgVinc
      
      // ** Apresenta valor restante a vincular
      @ aPos[1]+5, 200 SAY oSayVinc Var "Valor a vincular em "+AllTrim(M->WB_MOEDA)+":" PIXEL OF oDlgVinc
      @ aPos[1]+5, 280 MSGET oGetVinc Var nValAVincular PICTURE AvSx3("WB_FOBMOE", AV_PICTURE) WHEN .F. PIXEL OF oDlgVinc
      
      aPos[1] += 20
        
      // ** Browse com todas as parcelas de c�mbio de exporta��o que podem ser vinculadas.
      oParc   := MsSelect():New(Self:cAliasEEQ,"WK_MARCA",,aBrowseParc,@lInverte,@cMarca,{aPos[1],aPos[2],aPos[3],aPos[4]})
      oParc:bAval   := {|| Self:AcaoVinc("MARCA/DESMARCA") }
      
      bOk     := {|| If(Self:AcaoVinc("VALID_TELA"),(lRet := .T.,oDlgVinc:End()),)}
      bCancel := {|| lRet := .F., oDlgVinc:End()}
      
   ACTIVATE MSDIALOG oDlgVinc ON INIT EnchoiceBar(oDlgVinc,bOk,bCancel,,aButtons) CENTERED
   
   If !lRet
      Break
   EndIf
   
   // ** estorna dados do trb j� existentes
   Self:EstDadosTRB()
   
   (Self:cAliasEEQ)->(DbGoTop())
   While (Self:cAliasEEQ)->(!EoF())
      If !Empty((Self:cAliasEEQ)->WK_MARCA)
         
         // ** Cria registros de v�nculo na work, que ser�o usados na grava��o no m�todo GravaVinc
         (Self:cAliasVinc)->(DbAppend())
         (Self:cAliasVinc)->TRB_RECNO  := Str((Self:cAliasTRB)->(RecNo()),7)
         (Self:cAliasVinc)->EEQ_RECNO  := Str((Self:cAliasEEQ)->EEQ_RECNO,7)
         (Self:cAliasVinc)->EEQ_FILIAL := (Self:cAliasEEQ)->EEQ_FILIAL
         (Self:cAliasVinc)->EEQ_PREEMB := (Self:cAliasEEQ)->EEQ_PREEMB
         (Self:cAliasVinc)->EEQ_PARC   := (Self:cAliasEEQ)->EEQ_PARC
         (Self:cAliasVinc)->EEQ_VL     := (Self:cAliasEEQ)->WK_VLVINC

         If Self:lFFC
            (Self:cAliasTRB)->WK_VINCEXP := "S"
         EndIf
         
      EndIf

      (Self:cAliasEEQ)->(DbSkip())
   EndDo
   
End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
M�todo        : SelecDados()
Classe        : Ad101VincExp
Objetivos     : Selecionar dados para tela de vincula��o
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 17/12/2009
*/
Method SelecDados() Class Ad101VincExp
Local cQry, cPais, cSelect, nTot

Begin Sequence

   // ** Seleciona parcelas de c�mbio
   cSelect := "SELECT COUNT(*) AS TOT "
   cQry    := "FROM "+RetSqlName("EEQ")+" "+;
             "WHERE EEQ_CONTMV =  '1'"+; // Que controlem movimenta��es no exterior
               "AND EEQ_BCOEXT =  '"+M->WB_BANCO+"'"+; // que tenham os mesmos dados banc�rios
               "AND EEQ_AGCEXT =  '"+M->WB_AGENCIA+"'"+;
               "AND EEQ_CNTEXT =  '"+M->WB_CONTA+"'"+;
               "AND EEQ_DTCE   <> '"+Space(Len(DToS(EEQ->EEQ_DTCE)))+"'"+; // que estejam com data de cr�dito no exterior
               "AND EEQ_PGT    =  '"+Space(Len(DToS(EEQ->EEQ_PGT)))+"'"+;  // que n�o estejam liquidadas
               "AND D_E_L_E_T_<> '*'"
                            
   nAlias:=Select()
   If Select("QRY") > 0
      QRY->(DbCloseArea())
   EndIf
   TcQuery ChangeQuery(cSelect+cQry) ALIAS "QRY" NEW 
   
   nTot := QRY->TOT
   QRY->(DbCloseArea())
   
   ProcRegua(nTot+1)
   
   IncProc("Buscando Parcelas na Base de Dados...")
   cSelect := "SELECT R_E_C_N_O_ RECNO "
   TcQuery ChangeQuery(cSelect+cQry) ALIAS "QRY" NEW 
   
   EEQ->(DbSetOrder(1))
   EF3->(DbSetOrder(3)) //EF3_FILIAL+EF3_TPMODU+EF3_INVOIC+EF3_PARC+EF3_CODEVE

   (Self:cAliasVinc)->(DbSetOrder(2)) //EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC
   
   While QRY->(!EoF())
      EEQ->(DbGoTo(QRY->RECNO))
      IncProc("Formatando dados...")
      
      // ** N�o pode ter contrato de financiamento
      If EF3->(DbSeek(xFilial("EF3")+"E"+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC+AvKey("600","EF3_CODEVE")))
         QRY->(DbSkip())
         Loop
      EndIf
      
      (Self:cAliasEEQ)->(DbAppend())
      
      AvReplace("EEQ",Self:cAliasEEQ)
      
      (Self:cAliasEEQ)->EEQ_RECNO := EEQ->(RecNo())
      (Self:cAliasEEQ)->EEQ_VL -= EEQ->EEQ_CGRAFI
      
      (Self:cAliasEEQ)->WK_SALDO  := (Self:cAliasEEQ)->EEQ_VL
      (Self:cAliasEEQ)->WK_VLVINC := 0
      (Self:cAliasEEQ)->A1_NOME := Posicione("SA1",1,xFilial("SA1")+EEQ->(EEQ_IMPORT+EEQ_IMLOJA),"A1_NOME")

      cPais := AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_NOIDIOM"))  
      If Empty(cPais)
         cPais := AllTrim(SYA->YA_DESCR)
      EndIf
      (Self:cAliasEEQ)->YA_NOIDIOM := cPais
               
      // ** verifica os cambios de exp que j� foram vinculadas a outras parcelas de imp
      (Self:cAliasVinc)->(DbSeek(EEQ->(EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC)))
      While (Self:cAliasVinc)->(!EoF() .And.;
                                EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC == EEQ->(EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC))
         (Self:cAliasEEQ)->WK_SALDO  -= (Self:cAliasVinc)->EEQ_VL

         // ** verifica se j� foi marcado
         If (Self:cAliasVinc)->TRB_RECNO  == Str((Self:cAliasTRB)->(RecNo()),7)
            (Self:cAliasEEQ)->WK_MARCA  := cMarca
            (Self:cAliasEEQ)->WK_VLVINC += (Self:cAliasVinc)->EEQ_VL
            nValAVincular               -= (Self:cAliasVinc)->EEQ_VL
         Endif
         
         (Self:cAliasVinc)->(DbSkip())
      EndDo

      QRY->(DbSkip())
   EndDo
   
   QRY->(DbCloseArea())
   DbSelectArea(nAlias)
   
   (Self:cAliasEEQ)->(DbGoTop())
   
End Sequence

Return

/*
M�todo        : AcaoVinc()
Classe        : Ad101VincExp
Objetivos     : A��es da tela de vincula��o
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method AcaoVinc(cTipo,xAux) Class Ad101VincExp

Local lRet, aCpo, i, cFiltro, aOrd := {}, lRefreshParc := .F.
Local aFilter := {}, oDlg, nValVinc

Begin Sequence
   
   If !("FILTRO" $ cTipo)
      EECSaveFilter(Self:cAliasEEQ)
      (Self:cAliasEEQ)->(DbClearFilter())
   EndIf

   If cTipo == "FILTRO_INVOICE"
      aOrd := SaveOrd("SX3")
      SX3->(DbSetOrder(2))
      aCpo := {}
      For i := 1 To Len(Self:aStructEEQ)
         If SX3->(DbSeek(IncSpace(Self:aStructEEQ[i][1],10,.f.)))
            SX3->(AAdd(aCpo,{X3_CAMPO,X3Titulo(),If(!x3Uso(X3_USADO),.f.,.t.),X3_ORDEM,X3_TAMANHO,Trim(X3_PICTURE),X3_TIPO,X3_DECIMAL}))
         EndIf
      Next

      If !Empty(cFiltro := BuildExpr(Self:cAliasEEQ, , , .F. , , , , , , , aCpo))
         (Self:cAliasEEQ)->(DbSetFilter(&("{||"+cFiltro+"}"), cFiltro))
      EndIf
      lRefreshParc   := .T.
      
   ElseIf cTipo == "LIMPA_FILTRO_INVOICE"
      (Self:cAliasEEQ)->(DbClearFilter())
      lRefreshParc   := .T.

   ElseIf cTipo == "MARCA/DESMARCA"
      
      lRet := .T.
      EEQ->(DbGoTo((Self:cAliasEEQ)->EEQ_RECNO))
      
      // ** Se j� est� marcado
      If !Empty((Self:cAliasEEQ)->WK_MARCA)
         EEQ->(MsUnlock())
         
         (Self:cAliasEEQ)->WK_MARCA := "" // Retira a marca
         (Self:cAliasEEQ)->(WK_SALDO += WK_VLVINC) // retorna o valor para o saldo
         nValAVincular += (Self:cAliasEEQ)->WK_VLVINC // retorna o valor ao valor a vincular
         (Self:cAliasEEQ)->WK_VLVINC := 0 // o valor vinculado fica como zero
         lRefreshParc   := .T.
         
      Else
         // ** Quando vai marcar, primeiro tenta travar o registro do EEQ
         If !SoftLock("EEQ")
            MsgInfo("Esta parcela est� sendo utilizada por outro usu�rio.","Aten��o")
            lRet := .F.
            Break
         EndIf
         
         If !Empty((Self:cAliasEEQ)->EEQ_FFC)
            If !MsgYesNo("Esta parcela est� vinculada a FFC. Se prosseguir com a vincula��o, a mesma ser� retirada da FFC, "+;
                         "tendo que ser manipulada manualmente. Deseja prosseguir?","Aten��o")
               lRet := .F.
               Break
            EndIf
         EndIf
         // ** Analisa para ver qual valor ser� trazido como default na tela
         If nValAVincular > (Self:cAliasEEQ)->WK_SALDO
            nValVinc := (Self:cAliasEEQ)->WK_SALDO
         Else
            nValVinc := nValAVincular
         EndIf
         
         lRet := .F.
         DEFINE MSDIALOG oDlg TITLE "Digite o valor a ser vinculado:" FROM 10,10 TO 21,55 
         
            AvBorda(oDlg)
            @ 30,20 SAY  "Valor" Size 60,7 Pixel Of oDlg
            @ 30,60 MsGet nValVinc Picture AvSx3("EEQ_VL",AV_PICTURE) Size 50,8 Pixel Of oDlg
        
         ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(Self:AcaoVinc("VALID_TELA_VALOR",nValVinc),(lRet := .T.,oDlg:End()),)},{||lRet := .F.,oDlg:End()})
         
         If !lRet
            Break
         EndIf
         
         (Self:cAliasEEQ)->WK_VLVINC := nValVinc // atribui o valor vinculado
         nValAVincular -= (Self:cAliasEEQ)->WK_VLVINC // subtrai o valor a vincular
         (Self:cAliasEEQ)->(WK_SALDO -= WK_VLVINC) // subtrai o saldo
         (Self:cAliasEEQ)->WK_MARCA  := cMarca // marca
         lRefreshParc   := .T.
      EndIf
      oGetVinc:Refresh()

   ElseIf cTipo == "VALID_TELA_VALOR"
      
      lRet := .T.
      nValVinc := xAux
      If nValVinc > (Self:cAliasEEQ)->WK_SALDO
         MsgInfo("O valor digitado � maior que o saldo desta parcela de c�mbio de exporta��o.","Aten��o")
         lRet := .F.
         Break
      ElseIf nValVinc > nValAVincular
         MsgInfo("O valor digitado � maior que o valor a vincular da parcela de c�mbio de importa��o.","Aten��o")
         lRet := .F.
         Break
      ElseIf nValVinc <= 0
         MsgInfo("O valor deve ser maior que zero.","Aten��o")
         lRet := .F.
         Break
      EndIf
      
   ElseIf cTipo == "VALID_TELA"
      
      lRet := .T.
      If nValAVincular > 0
         If !MsgNoYes("Esse c�mbio ainda possui valor que n�o foi vinculado a parcelas de c�mbio de exporta��o. "+;
                      "Deseja liquid�-lo mesmo assim? Esse valor n�o liquidar� nenhum c�mbio de exporta��o, "+;
                      "mas abater� o saldo da conta do "+;
                      "Banco "  +AllTrim(M->WB_BANCO  )+", "+;
                      "Ag�ncia "+AllTrim(M->WB_AGENCIA)+", "+;
                      "Conta "  +AllTrim(M->WB_CONTA  )+".";
                      ,"Aten��o")
            lRet := .F.
            Break
         EndIf
      EndIf
      
   ElseIf cTipo == "VALIDA_VINC_FFC"
      lRet := .T.
      aOrd := SaveOrd(Self:cAliasTRB)
      (Self:cAliasTRB)->(DbGoTop())
      While (Self:cAliasTRB)->(!EoF())
         If (Self:cAliasTRB)->WK_VINCEXP <> "S"
            If !MsgNoYes("Existem parcelas que n�o foram vinculadas a parcelas de c�mbio de exporta��o. "+;
                         "Deseja liquid�-las mesmo assim? Essas parcelas n�o liquidar�o nenhum c�mbio de exporta��o, "+;
                         "mas abater�o saldo da conta do "+;
                         "Banco "  +AllTrim(M->WB_BANCO  )+", "+;
                         "Ag�ncia "+AllTrim(M->WB_AGENCIA)+", "+;
                         "Conta "  +AllTrim(M->WB_CONTA  )+".";
                         ,"Aten��o")
               lRet := .F.
            EndIf
            
            Break
         EndIf
         (Self:cAliasTRB)->(DbSkip())
      EndDo
   EndIf
   
End Sequence

EECRestFilter(aFilter)

RestOrd(aOrd,.T.)

If lRefreshParc
   oParc:oBrowse:Refresh()
EndIf

Return lRet

/*
M�todo        : GravaVinc()
Classe        : Ad101VincExp
Objetivos     : Gravar vincula��o de parcelas de exporta��o para o SWB posicionado
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method GravaVinc(lIncluiMov,lExcluiMov) Class Ad101VincExp

Local cChave, cQry, nParc, cParc, cParcAnt, cFilEmb
Default lIncluiMov := .F., lExcluiMov := .F.

Begin Sequence
   
   If !Self:lAtivado
      Break
   EndIf

   cChave := Str((Self:cAliasTRB)->(RecNo()),7)
   
   If lExcluiMov
      // ** Busca as parcelas do EEQ que est�o vinculadas a essa liquida��o de importa��o
      cQry := "SELECT R_E_C_N_O_ RECNO "+;
                "FROM "+RetSqlName("EEQ")+" "+;
               "WHERE EEQ_EICFIL = '"+SWB->WB_FILIAL +"'"+; //wfs
                 "AND EEQ_EICHAW = '"+(Self:cAliasTRB)->WB_HAWB   +"'"+;
                 "AND EEQ_EICPOD = '"+(Self:cAliasTRB)->WB_PO_DI  +"'"+;
                 "AND EEQ_EICINV = '"+(Self:cAliasTRB)->WB_INVOICE+"'"+;
                 "AND EEQ_EICFOR = '"+(Self:cAliasTRB)->WB_FORN   +"'"+;
                 "AND EEQ_EICLOJ = '"+(Self:cAliasTRB)->WB_LOJA   +"'"+;
                 "AND EEQ_EICLIN = '"+(Self:cAliasTRB)->WB_LINHA  +"'"+;
                 "AND D_E_L_E_T_<> '*'"
                            
      nAlias := Select()
      TcQuery cQry ALIAS "QRY" NEW 
      While QRY->(!EoF())
         EEQ->(DbGoTo(QRY->RECNO))
         Processa({|| Self:BaixaAutomatica(,.T.)},"Estornando baixas na Exporta��o...")
         QRY->(DbSkip())
      EndDo
      QRY->(DbCloseArea())
      DbSelectArea(nAlias)
   EndIf
   
   If lIncluiMov
      (Self:cAliasVinc)->(DbSetOrder(1)) //TRB_RECNO
      (Self:cAliasVinc)->(DbSeek( cChave ))

      // ** Procura na work cada uma das parcelas vinculadas a esta associa��o
      While (Self:cAliasVinc)->(!EoF() .And. TRB_RECNO == cChave )

         // ** Pega o n�mero da parcela original a ser vinculada e posiciona
         cParcAnt := (Self:cAliasVinc)->EEQ_PARC
         EEQ->(DbGoTo(Val((Self:cAliasVinc)->EEQ_RECNO)))
         cFilEmb := EEQ->(EEQ_FILIAL+EEQ_PREEMB)
         
         // ** Verifica se esta parcela j� foi quebrada. Se sim, tem que usar a parcela de res�duo
         While (nParc := AScan(Self:aParc, {|x| x[1] == cParcAnt .And. x[4] == cFilEmb})) > 0
            EEQ->(DbGoTo(Self:aParc[nParc][3]))
            cParcAnt := Self:aParc[nParc][2]
         EndDo
         
         Processa({|| cParc := Self:BaixaAutomatica( (Self:cAliasVinc)->EEQ_VL,.F.) },"Baixando parcelas Exporta��o...")

         // ** caso tenha sido uma baixa parcial, deve armazenar a parcela que substitui a parcela atual,
         //    pra ser usada nas pr�ximas vincula��es
         If cParc <> cParcAnt
            EEQ->(DbSetOrder(1))
            EEQ->(DbSeek((Self:cAliasVinc)->EEQ_FILIAL+(Self:cAliasVinc)->EEQ_PREEMB+cParc))
            
            If nParc > 0
               Self:aParc[nParc][2] := cParc
               Self:aParc[nParc][3] := EEQ->(RecNo())
            Else
               AAdd(Self:aParc,{cParcAnt,cParc,EEQ->(RecNo()),cFilEmb})
            EndIf
         EndIf
         
         (Self:cAliasVinc)->(DbSkip())
      EndDo

   EndIf
   
End Sequence

Return

/*
M�todo        : BaixaAutomatica()
Classe        : Ad101VincExp
Objetivos     : fazer a baixa de parcelas de exporta��o
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method BaixaAutomatica(nValor, lEstorno) Class Ad101VincExp

Local lRet := .T.
Local aOrd := SaveOrd("EEQ")
Local aRecno := {}, dData, lQuebra := .F.
Local cParc := EEQ->EEQ_PARC

Private lEEQAuto := .T., bEEQAuto
Private aEEQAuto
Private lFinanciamento := .F.
Private lTelaVincula := .F. //FSM - 01/03/2012
Private lOkEstor := .F.

// ** JPM - Vari�vel identificadora da rotina para rdmakes.
Private lAd101VImp := .T.

Default lEstorno := .F.

Begin Sequence
   
   ProcRegua(2)
   IncProc("Preparando Dados...")
   
   EEC->(DbSetOrder(1))
   EEC->(DbSeek(EEQ->(EEQ_FILIAL+EEQ_PREEMB)))
      
   If lEstorno
            
      aEEQAuto := {{"EEQ_EICFIL", ""};
                  ,{"EEQ_EICHAW", ""};
                  ,{"EEQ_EICPOD", ""};
                  ,{"EEQ_EICINV", ""};
                  ,{"EEQ_EICFOR", ""};
                  ,{"EEQ_EICLOJ", ""};
                  ,{"EEQ_EICLIN", ""};
                   }
      
      AAdd(aRecno, {EEQ->(RecNo()), ELQ_DET, AClone(aEEQAuto) } )      
      
   Else
   
      // ** se a FFC estiver preenchida, desvincula.
      If !Empty(EEQ->EEQ_FFC)
         EEQ->(EEQ_FFC := "",MsUnlock())
      EndIf
      
      If ValType(nValor) == "N" .And. EEQ->EEQ_VL - EEQ->EEQ_CGRAFI > nValor
         
         aEEQAuto := {{"EEQ_VL", nValor + Round(nValor*EEQ->EEQ_CGRAFI/(EEQ->EEQ_VL-EEQ->EEQ_CGRAFI),AvSx3("EEQ_VL", AV_DECIMAL))}} 

         AAdd(aRecno, {EEQ->(RecNo()), ALT_DET, AClone(aEEQAuto) } )
         lQuebra := .T.
      EndIf

      If (dData := &(Self:cAliasBx+"->WB_CA_DT")) < EEQ->EEQ_DTCE
         dData := EEQ->EEQ_DTCE
      EndIf
      
      aEEQAuto := {{"EEQ_EICFIL",  xFilial("SWB") }; //wfs
                  ,{"EEQ_EICHAW", &(Self:cAliasTrb+"->WB_HAWB  ") };
                  ,{"EEQ_EICPOD", &(Self:cAliasTrb+"->WB_PO_DI")  };
                  ,{"EEQ_EICINV", &(Self:cAliasTrb+"->WB_INVOICE")};
                  ,{"EEQ_EICFOR", &(Self:cAliasTrb+"->WB_FORN")   };
                  ,{"EEQ_EICLOJ", &(Self:cAliasTrb+"->WB_LOJA")   };
                  ,{"EEQ_EICLIN", &(Self:cAliasTrb+"->WB_LINHA")  };
                  ,{"EEQ_PGT"   , dData          };
                  ,{"EEQ_TX"    , &(Self:cAliasBx+"->WB_CA_TX")  };
                  ,{"EEQ_EQVL"  , &(Self:cAliasBx+"->WB_CA_TX") * nValor};
                  ,{"EEQ_BANC"  , &(Self:cAliasBx+"->WB_BANCO")  };
                  ,{"EEQ_AGEN"  , &(Self:cAliasBx+"->WB_AGENCIA")};
                  ,{"EEQ_NCON"  , &(Self:cAliasBx+"->WB_CONTA")  };
                  }

      If Empty(EEQ->EEQ_SOL)
         aAdd(aEEQAuto, {"EEQ_SOL", dData})
      EndIf
      
      If Empty(EEQ->EEQ_DTNEGO)
         aAdd(aEEQAuto, {"EEQ_DTNEGO", dData})
      EndIf

      AAdd(aRecno, {EEQ->(RecNo()), LIQ_DET, AClone(aEEQAuto) } )

   EndIf
   
   If lEstorno
      IncProc("Efetuando o estorno...")
   Else
      IncProc("Efetuando a baixa...")
   EndIf
   
   //Estorna a liquida��o
   bEEQAuto := {|| cParc := Self:AuxBaixa(aRecno,lQuebra) }

   AF200MAN("EEQ", EEQ->(Recno()), ALTERAR)

End Sequence

RestOrd(aOrd, .T.)

Return cParc

/*
M�todo        : AuxBaixa()
Classe        : Ad101VincExp
Objetivos     : fazer a baixa de parcelas de exporta��o
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method AuxBaixa(aRecno,lQuebra) Class Ad101VincExp

Local i, cParc, cNewParc := ""

Private aEEQAuto, lEEQAuto := .T., bEEQAuto

// ** JPM - essa vari�vel ser� setada dentro da fun��o AF200TrataParc, quando for feita uma quebra e gerada uma nova parcela.
Private cNewParcResiduo

Begin Sequence
   
   For i := 1 To Len(aRecno)
      
      PosTMP(aRecno[i][1])
      cParc     := TMP->EEQ_PARC
      aEEQAuto := aRecno[i][3]

      cNewParcResiduo := ""
      
      AF200DetMan(aRecno[i][2],, .T.)
      
      If lQuebra .And. !Empty(cNewParcResiduo)

         // ** se foi gerada uma nova parcela.
         If cNewParcResiduo <> cParc
            cNewParc := cNewParcResiduo
         EndIf
      EndIf
   Next

End Sequence

If Empty(cNewParc)
   cNewParc := cParc
EndIf

Return cNewParc

/*
Objetivos   : Posicionar na parcela tempor�ria na rotina de c�mbio
*/
*============================*
Static Function PosTMP(nRecno)
*============================*

Begin Sequence

   TMP->(DbGoTop())
   While TMP->(!Eof())
      If TMP->TMP_RECNO == nRecno
         Exit
      EndIf
      TMP->(DbSkip())
   EndDo

End Sequence

Return Nil

/*
M�todo        : EstDadosTRB()
Classe        : Ad101VincExp
Objetivos     : Estornar v�nculos com parc de exporta��o que est�o em mem�ria do TRB posicionado
Autor         : Jo�o Pedro Macimiano Trabbold
Data          : 10/12/2009
*/
Method EstDadosTRB() Class Ad101VincExp
Local cChave

Begin Sequence
   
   If !Self:lAtivado
      Break
   EndIf

   If Self:lFFC
      (Self:cAliasTRB)->WK_VINCEXP := ""
   EndIf
   
   cChave := Str((Self:cAliasTRB)->(RecNo()),7)
   
   (Self:cAliasVinc)->(DbSetOrder(1)) //TRB_RECNO
   (Self:cAliasVinc)->(DbSeek( cChave ))
   
   While (Self:cAliasVinc)->(!EoF() .And. TRB_RECNO == cChave )

      EEQ->(DbGoTo(Val((Self:cAliasVinc)->EEQ_RECNO)))
      EEQ->(MsUnlock())
      
      (Self:cAliasVinc)->(DbDelete())
      (Self:cAliasVinc)->(DbSkip())
   EndDo
   
End Sequence

Return

/*
Fun��o       : AddCpoWork
Objetivos    : Adicionar campos do SX3 no array para cria��o de work
Autor        : Jo�o Pedro Macimiano Trabbold
*/
*=============================================*
Static Function AddCpoWork(aWork,cCpo,cCpoBase)
*=============================================*
Local aSx3
Default cCpoBase := cCpo

aSx3 := AvSx3(cCpoBase)
aAdd(aWork,{cCpo,aSx3[2],aSx3[3],aSx3[4]})

Return

/*
Fun��o       : SubMes
*/
*===========================*
Static Function SubMes(dData)
*===========================*
Local cAno := StrZero(If(Month(dData) == 1, Year(dData) -1, Year(dData)), 4)
Local cMes := StrZero(If(Month(dData) == 1, 12, Month(dData) - 1), 2)
Local cDia := "01"

Return CToD(cDia+"/"+cMes+"/"+cAno)
