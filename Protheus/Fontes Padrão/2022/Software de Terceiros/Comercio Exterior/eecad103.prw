#Include "EEC.cH"
#Include "EECAD103.CH"

/*
Programa        : EECAD103.PRW
Objetivo        : Controlar a internação de recursos no exterior
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 27/11/2007
Obs. 
*/

#Define EVENTOS_REC "101"
#Define EVE_REMESSA "750"

//Opções da função AF200DetMan
#define LIQ_DET     99
#define ELQ_DET     98

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Function EECAD103
Local aOrd := SaveOrd({"EYV"})

Private aRotina := MenuDef()

Private cAlias  := "EYV",;
        cTitulo := STR0006 //"Manutenção de Internações de Recursos"

mBrowse( 6, 1,22,75,cAlias,,,,,,{},,,,,,,,"EYV_TIPO = '1'")

RestOrd(aOrd, .F.)
Return Nil

/*
Funcao      : 
Parametros  : cAlias - Alias da tabela em que será feita a manutenção
              nReg - Recno do registro que será alterado
              nOpc - Indica o tipo de operação que será efetuada no registro
Retorno     : lOk
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 
Revisao     : 
Obs.        : 
*/

Function AD103MAN(cAlias, nReg, nOpc)
Local oDlg
Local bOk     := {|| If(lOk := (Obrigatorio(aGets,aTela) .And. AD103VLD("BOK")), oDlg:End(), )},;
      bCancel := {|| oDlg:End()}
Local lRet := .F.
Private lOk := .F.
Private aGets[0],aTela[0]
Private cProcOrigem:= "AD103MAN"

RegToMemory(cAlias, nOpc == INCLUIR)
If nOpc == INCLUIR
   M->EYV_TIPO := "1"//Internação de recursos
EndIf

Do While !lRet //AAF 27/02/08 - Não sair enquanto não gravar ou o usuário cancelar

   //** AAF 27/02/08 - Limpar aGets e aTela para serem carregados numa segunda execução da enchoice.
   aGets := {}
   aTela := {}
   lOk := .F. 
   //**

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 350,636 OF oMainWnd PIXEL

      EnChoice(cAlias, nReg, nOpc,,,,,PosDlg(oDlg), GetCamposEdit(nOpc))

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lOk
      BEGIN TRANSACTION
         
         Begin Sequence
            
            //ConfirmSx8()
            
            If nOpc == INCLUIR .And. !(lRet := Ad103IntRec())
               Break
            EndIf

            If nOpc == EXCLUIR
               MsAguarde({|| lRet := Ad103EIntRec()}, STR0007, STR0015)//"Aguarde"###"Cancelando internação de recursos."
               If !lRet
                  Break
               EndIf
            EndIf
   
            (cAlias)->(RecLock(cAlias, nOpc == INCLUIR))

            If nOpc == EXCLUIR
               (cAlias)->(DbDelete())
            Else
               AvReplace("M", cAlias)
            EndIf
            (cAlias)->(MsUnlock())
            
            ConfirmSx8() //AAF 27/02/08 - Confirma a sequencia somente com a gravação.
            lRet := .T.
         End Sequence
         
         If !lRet
            While __lSX8
               RollBackSX8()
            Enddo
         EndIf

      END TRANSACTION
   Else
      RollBackSxE()
      lRet := .T.
   EndIf

EndDo

Return lOk

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetCamposEdit(nOpc)
Local aCampos

  If nOpc == ALTERAR
     aCampos := {"EYV_RFBC", "EYV_CORR"}
  ElseIf nOpc <> INCLUIR
     aCampos := {}
  EndIf

Return aCampos

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Function AD103Vld(cCampo)
Local lRet := .T.
Local aOrd := SaveOrd({"SY5", "SA6"})

Begin Sequence

   SA6->(DBSetOrder(1)) //A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON

   Do Case
      Case cCampo == "EYV_CORR"
         If !Empty(M->EYV_CORR)
            SY5->(DbSetOrder(3))
            If (SY5->(DbSeek(xFilial("SY5")+AvKey("5-CORRETORA CAMBIO","Y5_TIPOAGE")+M->EYV_CORR)))
               M->EYV_CRNO := SY5->Y5_NOME 
            Else
              Help(" ",1,"AVG0005078") //"Corretora não cadastrada !"
              lRet := .F.
            EndIf
         Else
            M->EYV_CRNO := ""
         EndIf

      Case cCampo == "EYV_TAXA"
         M->EYV_VLCONV := M->EYV_VALOR * M->EYV_TAXA
      
      Case cCampo == "EYV_VALOR"
         M->EYV_VLCONV := M->EYV_VALOR * M->EYV_TAXA
      
      //WFS 12/04/2010
      Case cCampo == "EYV_BCOORI"

         If !SA6->(DBSeek(xFilial()+M->(EYV_BCOORI)))
            MsgInfo("Banco/Agência/Conta não encontrado.","Atenção")
            lRet := .F.
         Else
            M->EYV_AGEORI:= SA6->A6_AGENCIA
            M->EYV_CTAORI:= SA6->A6_NUMCON
            M->EYV_NBCORI:= SA6->A6_NOME

            M->EYV_MOEDA := SA6->A6_MOEEASY
         EndIf

         //M->EYV_MOEDA := Posicione('SA6', 1, xFilial('SA6')+M->(EYV_BCOORI+EYV_AGEORI+EYV_CTAORI), 'A6_MOEEASY')            
      
      Case cCampo == "EYV_AGEORI"         

         If !SA6->(DBSeek(xFilial()+M->(EYV_BCOORI + EYV_AGEORI)))
            MsgInfo("Banco/Agência/Conta não encontrado.","Atenção")
            lRet := .F.
         Else
            M->EYV_CTAORI:= SA6->A6_NUMCON
            M->EYV_NBCORI:= SA6->A6_NOME

            M->EYV_MOEDA := SA6->A6_MOEEASY
         EndIf

      Case cCampo == "EYV_CTAORI"

         If !SA6->(DBSeek(xFilial()+M->(EYV_BCOORI + EYV_AGEORI + EYV_CTAORI)))
            MsgInfo("Banco/Agência/Conta não encontrado.","Atenção")
            lRet := .F.
         Else
            M->EYV_MOEDA := SA6->A6_MOEEASY
         EndIf

      //WFS 13/04/2010
      Case cCampo == "EYV_BCODES"

         If !SA6->(DBSeek(xFilial()+M->(EYV_BCODES)))
            MsgInfo("Banco/Agência/Conta não encontrado.","Atenção")
            lRet := .F.
         Else
            M->EYV_AGEDES:= SA6->A6_AGENCIA
            M->EYV_CTADES:= SA6->A6_NUMCON
            M->EYV_NBCDES:= SA6->A6_NOME
         EndIf

      Case cCampo == "EYV_AGEDES"

         If !SA6->(DBSeek(xFilial()+M->(EYV_BCODES + EYV_AGEDES)))
            MsgInfo("Banco/Agência/Conta não encontrado.","Atenção")
            lRet := .F.
         Else
            M->EYV_CTADES:= SA6->A6_NUMCON
            M->EYV_NBCDES:= SA6->A6_NOME
         EndIf
         
      Case cCampo == "EYV_CTADES"

         If !SA6->(DBSeek(xFilial()+M->(EYV_BCODES + EYV_AGEDES + EYV_CTADES)))
            MsgInfo("Banco/Agência/Conta não encontrado.","Atenção")
            lRet := .F.
         EndIf

      //WFS 12/04/2010
      Case cCampo == "EYV_BCOLIQ"
      
         If !SA6->(DBSeek(xFilial()+M->(EYV_BCOLIQ)))
            MsgInfo("Banco/Agência/Conta não encontrado.","Atenção")
            lRet := .F.
         Else
            M->EYV_AGELIQ:= SA6->A6_AGENCIA
            M->EYV_CTALIQ:= SA6->A6_NUMCON
            M->EYV_NBCLIQ:= SA6->A6_NOME
         EndIf

      Case cCampo == "EYV_AGELIQ"
      
         If !SA6->(DBSeek(xFilial()+M->(EYV_BCOLIQ + EYV_AGELIQ)))
            MsgInfo("Banco/Agência/Conta não encontrado.","Atenção")
            lRet := .F.
         Else
            M->EYV_CTALIQ:= SA6->A6_NUMCON
            M->EYV_NBCLIQ:= SA6->A6_NOME
         EndIf

      Case cCampo == "EYV_CTALIQ"
      
         If !SA6->(DBSeek(xFilial()+M->(EYV_BCOLIQ + EYV_AGELIQ)))
            MsgInfo("Banco/Agência/Conta não encontrado.","Atenção")
            lRet := .F.
         EndIf

      Case cCampo == "BOK"
         lRet := AD103Vld("BANCOS")
         
      Case cCampo == "BANCOS"
         SA6->(DbSetOrder(1))
         //Conta de Origem
         If !Empty(M->EYV_BCOORI) .Or. !Empty(M->EYV_AGEORI) .Or. !Empty(M->EYV_CTAORI)
            If !(lRet := SA6->(DbSeek(xFilial()+M->(EYV_BCOORI+EYV_AGEORI+EYV_CTAORI))))
               MsgInfo(StrTran(STR0017, "###", STR0019) + ENTER + STR0018, STR0016)//"A conta ### (de origem) informada não existe no cadastro de bancos"+ENTER+"Escolha uma conta válida"###"Atenção"
               Break
            EndIf
         EndIf
         //Conta de liquidação
         If !Empty(M->EYV_BCOLIQ) .Or. !Empty(M->EYV_AGELIQ) .Or. !Empty(M->EYV_CTALIQ)
            If !(lRet := SA6->(DbSeek(xFilial()+M->(EYV_BCOLIQ+EYV_AGELIQ+EYV_CTALIQ))))
               MsgInfo(StrTran(STR0017, "###", STR0020) + ENTER + STR0018, STR0016)//"A conta ### (de liquidação)informada não existe no cadastro de bancos"+ENTER+"Escolha uma conta válida"###"Atenção"
               Break
            EndIf
         EndIf
         //Conta de destino (Câmbio Simultâneo)
         If Type("M->EYV_BCODES") == "C" .And. Type("M->EYV_AGEDES") == "C" .And. Type("M->EYV_CTADES") == "C"
            If !Empty(M->EYV_BCODES) .Or. !Empty(M->EYV_AGEDES) .Or. !Empty(M->EYV_CTADES)
               If !(lRet := SA6->(DbSeek(xFilial()+M->(EYV_BCODES+EYV_AGEDES+EYV_CTADES))))
                  MsgInfo(StrTran(STR0017, "###", STR0021) + ENTER + STR0018, STR0016)//"A conta ### (de destino) informada não existe no cadastro de bancos"+ENTER+"Escolha uma conta válida"###"Atenção"
                  Break
               EndIf
            EndIf
         EndIf

   End Case

End Sequence

RestOrd(aOrd)
Return lRet

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Function Ad103IntRec(lCambioSim)
Local aOrd := SaveOrd({"EEC", "EE9", "EEQ"})
Local aProcsAno := {}, aValToInt := {}, aEEQ
Local nInc1
Local nValEmb := 0, nValLiq := 0, nValDisp := 0
Local nSaldo := 0
Local lRet := .T.

Private nMoeda  := 1, nRecno  := 1,;
        nTotEmb := 2, nContMv := 2,;
        nTotLiq := 3, nDtCred := 3,;
        nPerce  := 4, nParcs  := 4, nDtLiq := 4,;
        nVal    := 5, nDisp   := 5,;
        nBco    := 6, nEmbs   := 6,;
        nAge    := 7,;
        nCnt    := 8

Default lCambioSim := .F.

Begin Sequence

   nValInt := M->EYV_VALOR

   //*** Verifica o saldo para a conta informada
   MsAguarde({|| nSaldo := AD101GetSld(M->EYV_BCOORI, M->EYV_AGEORI, M->EYV_CTAORI) }, STR0007, STR0008)//"Aguarde"###"Verificando o saldo da conta informada."
   If nSaldo < nValInt
      MsgInfo(STR0009, STR0010)//"A conta informada não possui saldo suficiente para internação."###"Aviso"
      lRet := .F.
      Break
   EndIf
   //***
   
   //*** Busca os processos embarcados nos ultimos 12 meses
   Processa({|| aProcsAno := Ad103TotEmbs(M->EYV_DATA, M->EYV_MOEDA, 12, .T.) })
   //***
   
   //*** Verifica para cada mês o valor disponível para internação no banco informado
   For nInc1 := 1 To Len(aProcsAno)
      nValDisp += GetValRec(aProcsAno[nInc1], M->EYV_BCOORI, M->EYV_AGEORI, M->EYV_CTAORI, M->EYV_MOEDA, .F.)
   Next
   //***
   
   //** AAF 27/02/08 - Verifica saldo para câmbio simultâneo
   If lCambioSim .AND. nValDisp < nValInt
      cMsg := STR0022+Chr(13)+Chr(10)//"Não há saldo suficiente de disponibilidades de invoices de exportação para liquidação."
      cMsg += Chr(13)+Chr(10)
      cMsg += STR0023+TransForm(nValDisp,AvSX3("EEQ_VL",AV_PICTURE))+Chr(13)+Chr(10)//"Saldo disponível: "
      cMsg += STR0024+TransForm(nValInt,AvSX3("EEQ_VL",AV_PICTURE))+Chr(13)+Chr(10)//"Câmbio simultâneo solicitado: "
         
      MsgStop(cMsg)
      lRet := .F.
      Break
   EndIf
   //**
   
   //*** Distribui o valor a ser internado entre os meses, priorizando a liquidação de 70% dos embarques dos ultimos meses para os mais recentes
   Processa({|| aValToInt := DistribVal(aProcsAno, nValInt, M->EYV_BCOORI, M->EYV_AGEORI, M->EYV_CTAORI, M->EYV_MOEDA, nValDisp <= nValInt, .T.) })
   //***

   //*** Faz a baixa das parcelas de câmbio para cada mês distibuindo o valor entre os embarques, priorizando a liquidação de 70% do valor de cada embarque
   Processa({|| lRet := BaixaRec(aProcsAno, aValToInt, M->EYV_BCOORI, M->EYV_AGEORI, M->EYV_CTAORI, M->EYV_MOEDA, .T., lCambioSim) })
   If !lRet
      Break
   EndIf
   //***

   //*** Caso sobre algum saldo não vinculado a parcelas de câmbio, gera uma parcela de câmbio tipo III e faz a sua baixa para vincular com a internação
   aEval(aValToInt, {|x| nValInt -= x })
   If nValInt > 0
         aEEQ := {{"EEQ_PREEMB", "XXX"                   },;
                  {"EEQ_EVENT" , "751"                   },;
                  {"EEQ_PARC"  , GetParc("XXX")          },;
                  {"EEQ_VCT"   , M->EYV_DATA             },;
                  {"EEQ_MOEDA" , M->EYV_MOEDA            },;
                  {"EEQ_VL"    , nValInt                 },;
                  {"EEQ_PARI"  , 1                       },;
                  {"EEQ_DTCE"  , M->EYV_DATA             },;
                  {"EEQ_BCOEXT", M->EYV_BCOORI           },;
                  {"EEQ_AGCEXT", M->EYV_AGEORI           },;
                  {"EEQ_CNTEXT", M->EYV_CTAORI           },;
                  {"EEQ_CONTMV", "2"                     },;
                  {"EEQ_TP_CON", "3"                     },;
                  {"EEQ_INTERN", M->EYV_INTERN           }} 
                  
      Processa({|| lRet := AD103RemRec(aEEQ) })
   EndIf
   //***

End Sequence

RestOrd(aOrd, .T.)
Return lRet

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function BaixaRec(aProcs, aValToInt, cBco, cAge, cCnt, cMoeda, lProcessa, lCambioSim)
Local nInc1, nInc2
Local lRet := .T.

Begin Sequence
   
   If lProcessa
      ProcRegua(Len(aProcs))
   EndIf
   For nInc1 := 1 To Len(aProcs)
      If lProcessa
         IncProc(StrTran(STR0011, "###", AllTrim(Str(nInc1)) + "/" + AllTrim(Str(Len(aProcs))) ))//"Efetuando a liquidação das parcelas de câmbio (###)"
      EndIf
      For nInc2 := 1 To Len(aProcs[nInc1])
         If aProcs[nInc1][nInc2][nMoeda] == cMoeda .And. aValToInt[nInc1] > 0
            If !(lRet := BaixaParcelas(aProcs[nInc1][nInc2][nEmbs], aProcs[nInc1][nInc2][nDisp] == 0, aValToInt[nInc1], cBco, cAge, cCnt, lCambioSim))
               Break
            EndIf
         EndIf
      Next
   Next

End Sequence

Return lRet

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function BaixaParcelas(aEmbs, lInt100, nValor, cBco, cAge, cCnt, lCambioSim)
Local aOrd := SaveOrd("EEC")
Local lRet := .T.
Local aValores, aEEQ
Local nInc1, nInc2

Begin Sequence
   
   If !lInt100
      aValores := DistribLiq(aEmbs, nValor)
   EndIf

   For nInc1 := 1 To Len(aEmbs)
      If lCambioSim
         EEC->(DbGoTo(aEmbs[nInc1][nRecno]))
         aEEQ := {{"EEQ_PREEMB", EEC->EEC_PREEMB         },;
                  {"EEQ_EVENT" , EVE_REMESSA             },;
                  {"EEQ_PARC"  , GetParc(EEC->EEC_PREEMB)},;
                  {"EEQ_VCT"   , M->EYV_DATA             },;
                  {"EEQ_MOEDA" , M->EYV_MOEDA            },;
                  {"EEQ_VL"    , nValor                  },;// AAF - 26/02/08 - Remessa é do valor total. {"EEQ_VL"    , aValores[nInc1]         },;
                  {"EEQ_PARI"  , 1                       },;
                  {"EEQ_DTCE"  , M->EYV_DATA             },;
                  {"EEQ_BCOEXT", M->EYV_BCODES           },;
                  {"EEQ_AGCEXT", M->EYV_AGEDES           },;
                  {"EEQ_CNTEXT", M->EYV_CTADES           },;
                  {"EEQ_CONTMV", "1"                     },;
                  {"EEQ_TP_CON", "4"                     },;
                  {"EEQ_INTERN", M->EYV_INTERN           }}
         
         //** AAF 26/02/08 - Preencher os campos para liquidação do câmbio simultâneo.
         aAdd(aEEQ,{"EEQ_PGT"   , M->EYV_DATA  })
         aAdd(aEEQ,{"EEQ_TX"    , M->EYV_TAXA  })
         aAdd(aEEQ,{"EEQ_EQVL"  , M->EYV_TAXA * nValor})
         aAdd(aEEQ,{"EEQ_BANC"  , M->EYV_BCOLIQ})
         aAdd(aEEQ,{"EEQ_AGEN"  , M->EYV_AGELIQ})
         aAdd(aEEQ,{"EEQ_NCON"  , M->EYV_CTALIQ})
         aAdd(aEEQ,{"EEQ_SOL"   , M->EYV_DATA})
         aAdd(aEEQ,{"EEQ_DTNEGO", M->EYV_DATA})
         //**
         
         //Gera parcela de remessa quando for câmbio simultâneo
         AD103RemRec(aEEQ)
      EndIf
      For nInc2 := 1 To Len(aEmbs[nInc1][nParcs])
         If aEmbs[nInc1][nParcs][nInc2][nContMv] .And. !Empty(aEmbs[nInc1][nParcs][nInc2][nDtCred]) .And. Empty(aEmbs[nInc1][nParcs][nInc2][nDtLiq]);
            .And. aEmbs[nInc1][nParcs][nInc2][nBco] == cBco .And. aEmbs[nInc1][nParcs][nInc2][nAge] == cAge .And. aEmbs[nInc1][nParcs][nInc2][nCnt] == cCnt
            If lInt100
               If !(lRet := BaixaAutomatica(aEmbs[nInc1][nParcs][nInc2][nRecno]))
                  Break
               EndIf
            Else
               If !(lRet := BaixaAutomatica(aEmbs[nInc1][nParcs][nInc2][nRecno], aValores[nInc1]))
                  Break
               EndIf
               aValores[nInc1] -= aEmbs[nInc1][nParcs][nInc2][nVal]
               If aValores[nInc1] == 0
                  Exit
               EndIf
            EndIf
         EndIf
      Next
   Next

End Sequence
RestOrd(aOrd, .T.)
Return lRet

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function DistribLiq(aEmbs, nValor)
Local aValores := Array(Len(aEmbs))
Local nInc1

//** AAF - 26/02/08 - Inicializar os valores com zero.
aFill(aValores,0)
//**

Begin Sequence

   For nInc1 := 1 To Len(aEmbs)
      If aEmbs[nInc1][nTotLiq] < aEmbs[nInc1][nTotEmb] * 0.7
         If nValor > aEmbs[nInc1][nTotEmb] * 0.7 - aEmbs[nInc1][nTotLiq]
            aValores[nInc1] := aEmbs[nInc1][nTotEmb] * 0.7 - aEmbs[nInc1][nTotLiq]
         Else
            aValores[nInc1] := nValor
         EndIf
         nValor -= aValores[nInc1]
         aEmbs[nInc1][nTotLiq] += aValores[nInc1]
         If nValor == 0
            Break
         EndIf
      EndIf
   Next

   For nInc1 := 1 To Len(aEmbs)
      If aEmbs[nInc1][nTotLiq] < aEmbs[nInc1][nTotEmb]
         If nValor > aEmbs[nInc1][nTotEmb] - aEmbs[nInc1][nTotLiq]
            aValores[nInc1] += aEmbs[nInc1][nTotEmb] - aEmbs[nInc1][nTotLiq]
         Else
            aValores[nInc1] += nValor
         EndIf
         nValor -= aValores[nInc1]
         If nValor == 0
            Break
         EndIf
      EndIf
   Next

End Sequence

Return aValores

/*
Funcao      : 
Parametros  : lCambioSim - Indica se é câmbio simultâneo
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Function Ad103EIntRec()
Local aOrd := SaveOrd("EEQ")
Local lRet := .T.

   EEQ->(DbSetOrder(11))
   EEQ->(DbSeek(xFilial()+M->EYV_INTERN))
   While EEQ->(!Eof() .And. EEQ_FILIAL+EEQ_INTERN == xFilial()+M->EYV_INTERN )
      lRet := BaixaAutomatica(EEQ->(Recno()),, .T.)
      EEQ->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return lRet

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function BaixaAutomatica(nRecNo, nValor, lEstorno)
Local lRet := .T.
Local aOrd := SaveOrd("EEQ")
Private lEEQAuto := .T., bEEQAuto
Private aEEQAuto
Private lFinanciamento := .F.
Private lTelaVincula := .F. //FSM - 01/03/2012
Private lOkEstor := .F.
Default lEstorno := .F.

   EEQ->(DbGoTo(nRecNo))
   If lEstorno
      EEC->(DbSetOrder(1))
      EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
      
      nEEQAuto := ALTERAR
      
      //** AAF 26/02/08 - Tratamento de estorno de câmbio simultâneo
      If EEQ->EEQ_EVENT == EVE_REMESSA
         //Exclui a remessa
         bEEQAuto := {|| PosTMP(nRecNo), lRet := AF200DetMan(ELQ_DET,, .T.), /*nopado por RNLP 23/09/20 - Uso da função exigiria declara-la como Static If(lRet,AF200ESTPARC(),)*/ ,AF200STATUS()}
      Else
         //Estorna a liquidação
         bEEQAuto := {|| PosTMP(nRecNo), lRet := AF200DetMan(ELQ_DET,, .T.) }
      EndIf

      aEEQAuto := {{"EEQ_INTERN", ""}}
      AF200MAN("EEQ", EEQ->(Recno()), ALTERAR)
   Else
      If ValType(nValor) == "N" .And. EEQ->EEQ_VL - EEQ->EEQ_CGRAFI > nValor // AAF 26/02/08 - Considerar a comissão conta gráfica.
         EEC->(DbSetOrder(1))
         EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
         //Quebra a parcela
         nEEQAuto := ALTERAR
         bEEQAuto := {|| PosTMP(nRecNo), lRet := AF200DetMan(ALT_DET,, .T.) }
         
         //** AAF 26/02/08 - Considerar a comissão conta gráfica.
         //aEEQAuto := {{"EEQ_VL", nValor}}
         aEEQAuto := {{"EEQ_VL", nValor + Round(nValor*EEQ->EEQ_CGRAFI/(EEQ->EEQ_VL-EEQ->EEQ_CGRAFI),AvSx3("EEQ_VL", AV_DECIMAL))}} 
         //**

         //** AAF 26/02/08 - Adiciona mais uma parcela na sequencia de parcelas do processo
         GetParc(EEQ->EEQ_PREEMB)
         //**
         
         AF200MAN("EEQ", EEQ->(Recno()), ALTERAR)
         
      EndIf

      //Faz a baixa
      EEQ->(DbGoTo(nRecNo))
      EEC->(DbSetOrder(1))
      EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
      nEEQAuto := ALTERAR
      bEEQAuto := {|| PosTMP(nRecNo), lRet := AF200DetMan(LIQ_DET,, .T.) }

      aEEQAuto := {{"EEQ_PGT"   , M->EYV_DATA  },;
                   {"EEQ_TX"    , M->EYV_TAXA  },;
                   {"EEQ_EQVL"  , M->EYV_TAXA * EEQ->EEQ_VL},;
                   {"EEQ_BANC"  , M->EYV_BCOLIQ},;
                   {"EEQ_AGEN"  , M->EYV_AGELIQ},;
                   {"EEQ_NCON"  , M->EYV_CTALIQ},;
                   {"EEQ_INTERN", M->EYV_INTERN}}

      If Empty(EEQ->EEQ_SOL)
         aAdd(aEEQAuto, {"EEQ_SOL", M->EYV_DATA})
      EndIf
      If Empty(EEQ->EEQ_DTNEGO)
         aAdd(aEEQAuto, {"EEQ_DTNEGO", M->EYV_DATA})
      EndIf
      AF200MAN("EEQ", EEQ->(Recno()), ALTERAR)
   EndIf

RestOrd(aOrd, .T.)
Return lRet

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function PosTMP(nRecno)

   TMP->(DbGoTop())
   While TMP->(!Eof())
      If TMP->TMP_RECNO == nRecno
         Exit
      EndIf
      TMP->(DbSkip())
   EndDo

Return Nil

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Function AD103RemRec(aEEQ)
Local lRet := .T.
Private lFinanciamento := .F.
Private lTelaVincula := .F. //FSM - 01/03/2012
Private lEEQAuto := .T.
Private bEEQAuto := {|| lOk := .T. }
Private nEEQAuto := INCLUIR
Private aEEQAuto := aEEQ

   If aScan(aEEQAuto, {|x| "EEQ_PREEMB" $ x[1] }) > 0
      M->EEQ_PREEMB := aEEQAuto[aScan(aEEQAuto, {|x| "EEQ_PREEMB" $ x[1] })]
   EndIf
   lRet := AF500MAN("EEQ", EEQ->(Recno()), nEEQAuto)

Return lRet

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
/*
Static Function GetParc(cPreemb)
Local aOrd := SaveOrd("EEQ")
Local nParc:= 0
   
   EEQ->(DbSeek(xFilial("EEQ")+AvKey(cPreemb,"EEQ_PREEMB")))
   While EEQ->(!Eof() .And. EEQ_FILIAL+EEQ_PREEMB == xFilial("EEQ")+AvKey(cPreemb,"EEQ_PREEMB"))
      ++nParc
      EEQ->(DbSkip())
   EndDo
   
RestOrd(aOrd, .T.)

Return StrZero(nParc + 1, AvSx3("EEQ_PARC", AV_TAMANHO))
*/
//** AAF 26/02/08 - Busca a ultima parcela
Static Function GetParc(cPreemb)
Local aOrd := SaveOrd("EEQ")

EEQ->(dbSetOrder(1))
EEQ->(AvSeekLast(xFilial("EEQ")+AvKey(cPreemb,"EEQ_PREEMB")))
nSeqParc := Val(EEQ->EEQ_PARC)
  
RestOrd(aOrd, .T.)
Return StrZero(nSeqParc+1, AvSx3("EEQ_PARC", AV_TAMANHO))
//**

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function DistribVal(aProcs, nValor, cBco, cAge, cCnt, cMoeda, lInt100, lProcessa)
Local nInc1, nInc2
Local aValores := Array(Len(aProcs))
Default lInt100 := .F.

Begin Sequence

   If !lInt100
      If lProcessa
         ProcRegua(2 * Len(aProcs))
      EndIf
      For nInc1 := Len(aProcs) To 1 Step -1
         If lProcessa
            IncProc(StrTran(STR0012, "###", AllTrim(Str(nInc1)) + "/" + AllTrim(Str(2*Len(aProcs))) ))//"Distribuindo valores que serão internados (###)."
         EndIf
         aValores[nInc1] := 0
         If nValor == 0
            Loop
         EndIf
         For nInc2 := 1 To Len(aProcs[nInc1])
            If aProcs[nInc1][nInc2][nMoeda] == cMoeda
               nValLiq := Round(aProcs[nInc1][nInc2][nTotEmb] * 0.7, AvSx3("EEQ_VL", AV_DECIMAL))
               nValLiq -= aProcs[nInc1][nInc2][nTotLiq]
               If nValLiq > aProcs[nInc1][nInc2][nDisp]
                  nValLiq := aProcs[nInc1][nInc2][nDisp]
               EndIf
               If nValLiq > nValor
                  aValores[nInc1] := nValor
               ElseIf nValLiq > 0
                  aValores[nInc1] := nValLiq
               EndIf
               aProcs[nInc1][nInc2][nDisp] -= aValores[nInc1]
            EndIf
            nValor -= aValores[nInc1]
            If nValor == 0
               Exit
            EndIf
         Next
      Next
   EndIf
   
   If nValor == 0
      Break
   EndIf

   //Interna 100%
   
   //AAF 26/02/08 - Este for também deve ser do fim para o inicio, pois o aProcs está ordenado do mais recente para o mais antigo.
   //For nInc1 := 1 To Len(aProcs)
   For nInc1 := Len(aProcs) To 1 Step -1
      If lProcessa
         IncProc(StrTran(STR0012, "###", AllTrim(Str(Len(aProcs) + nInc1)) + "/" + AllTrim(Str(2*Len(aProcs))) ))//"Distribuindo valores que serão internados (###)."
      EndIf
      
      //** AAF - 26/02/08 - Retirado - Não zerar os valores de internação calculados acima.
      If lInt100
         aValores[nInc1] := 0
      EndIf
      //**
      
      If nValor == 0
         Loop
      EndIf
      
      For nInc2 := 1 To Len(aProcs[nInc1])
         If aProcs[nInc1][nInc2][nMoeda] == cMoeda
            If aProcs[nInc1][nInc2][nDisp] > nValor
               aValores[nInc1] += nValor
               aProcs[nInc1][nInc2][nDisp] -= nValor
            Else
               nValor -= aProcs[nInc1][nInc2][nDisp]
               aValores[nInc1] += aProcs[nInc1][nInc2][nDisp]
               aProcs[nInc1][nInc2][nDisp] := 0
            EndIf
            If nValor == 0
               Exit
            EndIf
         EndIf
      Next
   Next

End Sequence

Return aValores

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetValRec(aProcs, cBco, cAge, cCnt, cMoeda, lLiq)
Local nValor := 0, nValorTot := 0
Local nInc1, nInc2, nInc3
Default lLiq := .T.

   For nInc1 := 1 To Len(aProcs)
      If aProcs[nInc1][nMoeda] == cMoeda
         nValor := 0
         For nInc2 := 1 To Len(aProcs[nInc1][nEmbs])
            For nInc3 := 1 To Len(aProcs[nInc1][nEmbs][nInc2][nParcs])
               aParcela := aProcs[nInc1][nEmbs][nInc2][nParcs][nInc3]
               If aParcela[nBco] == cBco .And. aParcela[nAge] == cAge .And. aParcela[nCnt] == cCnt
                  If aParcela[nContMv] .And. !Empty(aParcela[nDtCred]) .And. (!Empty(aParcela[nDtLiq]) == lLiq)
                     nValor += aParcela[nVal]
                  EndIf
               EndIf
            Next
         Next
         aProcs[nInc1][nDisp] := nValor
         nValorTot += nValor
      EndIf
   Next

Return nValorTot

/*
Funcao      : Ad103TotEmbs
Parametros  : 
Retorno     : 
Objetivos   : Retornar os processos que foram embarcados no Ano+Mes definido e o valor total de cada um.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 27/11/07
*/
Function Ad103TotEmbs(dData, cMoeda, nMeses, lProcessa)
Local aProcsAno := {}
Local aProcsMes := {}, aInvoices

//** AAF - 25/02/08 - Fixado o dia para dia 1 pois ao retornar um mês sem alterar o dia, pode-se retornar uma data inválida, como 31/02/08.
//Local bSubMes := {|dData| SToD(StrZero(If(Month(dData) == 1, Year(dData) -1, Year(dData)), 4) + StrZero(If(Month(dData) == 1, 12, Month(dData) - 1), 2) + StrZero(Day(dData), 2)  ) }
Local bSubMes := {|dData| SToD(StrZero(If(Month(dData) == 1, Year(dData) -1, Year(dData)), 4) + StrZero(If(Month(dData) == 1, 12, Month(dData) - 1), 2) + "01"  ) }
//**

Local bMesAno := {|dData| SubStr(DToS(dData), 5, 2) + "/" + Left(DToS(dData), 4) }
Local nInc, nPos1, nPos2
Default cMoeda := ""
Default nMeses := 1
Default lProcessa := .F.

/*
 nMoeda             nTotEmb            nTotLiq          nPerce                 nEmbs
{MOEDA            , TOTAL EMBARCADO  , TOTAL LIQUIDADO, PORCENTAGEM LIQUIDADA, ARRAY DE EMBARQUES}

 nRecno             nTotEmb            nTotLiq          nParcs
{RECNO DO EMBARQUE, TOTAL DO EMBARQUE, TOTAL LIQUIDADO, ARRAY DE PARCELAS DE CÂMBIO}

 nRecno             nContMv            nDtCred          nDtLiq           nValLiq
{RECNO DA PARCELA,  CONTROLAMOV?     , DATA CRÉDITO   , DATA LIQUIDAÇÃO, VALOR}
*/

If nMeses > 1

   If lProcessa
      ProcRegua(nMeses + 1)
      IncProc(StrTran(STR0013, "###", AllTrim(Str(nMeses))))//"Verificando os processos embarcados nos ultimos ### meses."
   EndIf
   
   For nInc := 1 To nMeses
      If lProcessa
         IncProc(STR0014 + Eval(bMesAno, dData))//"Verificando processos embarcados em: "
      EndIf

      //Busca todos os processos embarcados nos ultimos 12 meses
      aAdd(aProcsAno, Ad103TotEmbs(dData, M->EYV_MOEDA))

      dData := Eval(bSubMes, dData)
   Next

Else

   EEC->(DbSetOrder(12))
   EE9->(DbSetOrder(2))
   EEC->(DbSeek(xFilial()+Left(DToS(dData), 6)))
   While EEC->(!Eof() .And. EEC->EEC_FILIAL+Left(DToS(EEC_DTEMBA), 6) == xFilial()+Left(DToS(dData), 6))
      If !(EEC->EEC_COBCAM $ cNao) .And. !(EEC->EEC_STATUS == ST_PC) .And. (Empty(cMoeda) .Or. EEC->EEC_MOEDA == cMoeda)
         If (nPos1 := aScan(aProcsMes, {|x| x[nMoeda] == EEC->EEC_MOEDA })) == 0
            aAdd(aProcsMes, Array(6))
            nPos1 := Len(aProcsMes)
            aProcsMes[nPos1][nMoeda ] := EEC->EEC_MOEDA
            aProcsMes[nPos1][nTotEmb] := 0
            aProcsMes[nPos1][nTotLiq] := 0
            aProcsMes[nPos1][nPerce ] := 0
            aProcsMes[nPos1][nDisp  ] := 0
            aProcsMes[nPos1][nEmbs  ] := {}
         EndIf

         aAdd(aProcsMes[nPos1][nEmbs], Array(4))
         nPos2 := Len(aProcsMes[nPos1][nEmbs])
         aProcsMes[nPos1][nEmbs][nPos2][nRecno ] := EEC->(Recno())
         aProcsMes[nPos1][nEmbs][nPos2][nTotEmb] := 0
         aProcsMes[nPos1][nEmbs][nPos2][nTotLiq] := 0
         aProcsMes[nPos1][nEmbs][nPos2][nParcs ] := {}

         EE9->(DbSetOrder(2))
         EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
         While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+EEC->EEC_PREEMB)
            aProcsMes[nPos1][nEmbs][nPos2][nTotEmb] += EE9->EE9_PRCTOT
            EE9->(DbSkip())
         EndDo
         
         aInvoices := BuscaInvoices(EEC->EEC_PREEMB)
         aProcsMes[nPos1][nEmbs][nPos2][nTotLiq] := aInvoices[1]
         aProcsMes[nPos1][nEmbs][nPos2][nParcs ] := aInvoices[2]
         
         aProcsMes[nPos1][nTotEmb] += aProcsMes[nPos1][nEmbs][nPos2][nTotEmb]
         aProcsMes[nPos1][nTotLiq] += aProcsMes[nPos1][nEmbs][nPos2][nTotLiq]
         
      EndIf
      EEC->(DbSkip())
   EndDo
   
   For nInc := 1 To Len(aProcsMes)
      aProcsMes[nInc][nPerce] := aProcsMes[nPos1][nTotLiq] / aProcsMes[nPos1][nTotEmb]
   Next

EndIf

Return If(nMeses > 1, aProcsAno, aProcsMes)

/*
Funcao      : BuscaInvoices
Parametros  : cProc - Processo de embarque
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 
Revisao     : 
Obs.        :
*/
Static Function BuscaInvoices(cProc)
Local aRetorno := {0, {}}
Local aInvoices := aRetorno[2]
Local nPos

   EEQ->(DbSeek(xFilial()+cProc))
   While EEQ->(!Eof() .And. EEQ_FILIAL+EEQ_PREEMB == xFilial()+cProc)
      If EEQ->EEQ_EVENT $ EVENTOS_REC
         aAdd(aInvoices, Array(8))
         nPos := Len(aInvoices)
         aInvoices[nPos][nRecno ] := EEQ->(Recno())
         aInvoices[nPos][nContMv] := EEQ->EEQ_CONTMV $ cSim
         aInvoices[nPos][nDtCred] := EEQ->EEQ_DTCE
         aInvoices[nPos][nDtLiq ] := EEQ->EEQ_PGT
         aInvoices[nPos][nVal   ] := EEQ->EEQ_VL - EEQ->EEQ_CGRAFI //AAF 26/02/08 - Considerar a comissão conta gráfica.
         aInvoices[nPos][nBco   ] := EEQ->EEQ_BCOEXT
         aInvoices[nPos][nAge   ] := EEQ->EEQ_AGCEXT
         aInvoices[nPos][nCnt   ] := EEQ->EEQ_CNTEXT
         If !Empty(EEQ->EEQ_PGT)
            aRetorno[1] += EEQ->EEQ_VL - EEQ->EEQ_CGRAFI //AAF 26/02/08 - Considerar a comissão conta gráfica.
         EndIf
      EndIf
      EEQ->(DbSkip())
   EndDo

Return aRetorno

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as definições de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 24/10/07 - 11:00
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina  := { { STR0001, "AxPesqui" , 0 , 1},;   //"Pesquisar"
                    { STR0002, "AD103MAN" , 0 , 2},;   //"Visualizar"
                    { STR0003, "AD103MAN" , 0 , 3},;   //"Incluir"
                    { STR0004, "AD103MAN" , 0 , 4},;   //"Alterar"
                    { STR0005, "AD103MAN" , 0 , 5,3}}  //"Cancelar"

Begin Sequence

   If EasyEntryPoint("EAD103MNU")
      aRotAdic := ExecBlock("EAD103MNU",.f.,.f.)
   EndIf

   If ValType(aRotAdic) == "A"
      aEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf

End Sequence

Return aRotina
