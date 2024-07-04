#INCLUDE "AVERAGE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "EFFEX102.CH"

/*
Programa        : EFFEX402.PRW
Objetivo        : Integração SIGAEFF x SIGAFIN
Autor           : Alessandro Alves Ferreira
Data/Hora       : 10/11/2009
*/
*-----------------*
Function EFFEX102()
*-----------------*
Return Nil

/*
Funcao....: EX102FlCaixa()
Objetivo..: Retornar os dados para fluxo de caixa no financeiro
Autor.....: Alessandro Alves Ferreira
*/
Function EX102FlCaixa(dDataTrab,aPeriodo,nMoeda,lAnalitico)
Local aRet
Local cSimbMoe
Local i
Local oInt

oInt := AvEFF_FIN():New()
aRet := oInt:SaldoValorContratos(dDataTrab)

If nMoeda <> 1
   cSimbMoe := EasyGParam("MV_SIMB"+Str(nMoeda,1))

   If !Empty(cSimbMoe)
      For i := 1 To Len(aRet)
         If aRet[i][9] <> cSimbMoe
            //aRet[i][6] := aRet[i][10]*BuscaTaxa(aRet[i][9],dDataTrab,,.F.,.T.)/BuscaTaxa(cSimbMoe,dDataTrab,,.F.,.T.)//xMoeda(aRet[i][10],SimbToMoeda(aRet[i][9]),SimbToMoeda(cSimbMoe),dDataTrab)
            aRet[i][6] := aRet[i][6]/BuscaTaxa(cSimbMoe,dDataTrab,,.F.,.T.)//xMoeda(aRet[i][10],SimbToMoeda(aRet[i][9]),SimbToMoeda(cSimbMoe),dDataTrab)
         Else
            aRet[i][6] := aRet[i][10]
         EndIf
      Next i
   EndIf
EndIf

Return aClone(aRet)

/*
Funcao....: EX102AprJuros()
Objetivo..: Apropriacao de juros executada no Financeiro para Contabilização
Autor.....: Alessandro Alves Ferreira
*/
Function EX102AprJuros(dDtProc,nHdlPrv,cPadrao,aFlagCtb,lUsaFlag,cLote,dDataApu)
Local oInt := AvEFF_FIN():New()
Private dDtApu := If(ValType(dDataApu) == "D",dDataApu,CTOD(""))  // GFP - 18/07/2014
Return oInt:ContabilizaEFF(dDtProc,nHdlPrv,cPadrao,aFlagCtb,lUsaFlag,cLote)

/*
Classe..: AvEFF_FIN
Objetivo: Controle da integração SIGAEFF x SIGAFIN
Autor...: Alessandro Alves Ferreira
Data....: 10/11/2009
*/
Class AvEFF_FIN INHERIT from AvObject

   Data lAtivo
   Data oContrato

   //Construtores
   Method New() Constructor

   //Tratamento de eventos financeiros
   Method EventoFinanceiro(cEvento)

   Method ApropriaJuros()
   Method LancPadEF3()
   Method LancPadECE()
   Method ContabilizaEFF()
   Method ContabEvento()
   Method SaldoValorContratos()

EndClass

   /*
      Método..: New()
      Classe..: AvEFF_FIN
      Objetivo: Construtor da classe AvEFF_FIN
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method New(oContra) Class AvEFF_FIN
      _Super:New()
      ::setClassName("AvEFF_FIN")

      ::lAtivo          := AvFlags("SIGAEFF_SIGAFIN")
      ::oContrato       := oContra

       // BAK - Tratamento para integrado somente com o financeiro
       If ::lAtivo
         If !ChkFile("SE5") .OR. !SE5->(FieldPos("E5_PROCTRA")) > 0
            ::lAtivo := .F.
            ::Error("Financeiro não está preparado para integração com SIGAEFF. O ambiente não possui o campo E5_PROCTRA. A integração com Financeiro será desativada.")

         ElseIf (nMax := Max(Len( SE2->(&(IndexKey(1))) ), Len( SE5->(&(IndexKey(15))) ) ) ) >  AvSx3("EF3_TITFIN",AV_TAMANHO) //FSM - 24/02/2012
            ::lAtivo := .F.
            ::Error('O tamanho do campo "Tit.Financ"(EF3_TITFIN) não está compatível com o modulo Financeiro. Solicite ao administrador que altere o tamanho deste campo para '+ AllTrim(Str(nMax)) +'.')

         EndIf
      EndIf

   Return Self

   /*
      Método..: EventoFinanceiro()
      Classe..: AvEFF_FIN
      Objetivo: Tratamento para os eventos financeiros para a integração
      Autor...: Alessandro Alves Ferreira
   */
   Method EventoFinanceiro(cEvento) Class AvEFF_FIN
      Local lOk := .T.

      Begin Sequence

      Do Case

      Case (!"ENCERRAMENTO_CONTRATO" $ cEvento .And. "CONTRATO" $ cEvento) .AND. EF1->EF1_TPMODU == "E" //Somente contratos exportação

         If AllTrim(EF3->EF3_CODEVE) <> "100"
            ::Warning("EventoFinanceiro - Chamada não posicionou a tabela de eventos do contrato (EF3).")
         EndIf

         oEmpr := AvEmprestimo():LoadEF3(@Self)

         If !oEmpr:lMovBco                                   //NCF - 13/07/2016
            Break
         EndIf

         Do Case

         Case "INCLUSAO" $ cEvento
            If !Empty(EF3->EF3_TITFIN)
               ::Warning(cEvento+": Já existe movimentação bancária no financeiro para esse contrato.")
               lOk := oEmpr:Altera()
            Else
               lOk := oEmpr:Inclui()
            EndIf

         Case "ALTERACAO" $ cEvento
            If Empty(EF3->EF3_TITFIN)
               ::Warning(cEvento+": Não há chave de documento de movimentação bancária no financeiro para esse contrato.")
               lOk := oEmpr:Inclui()
            Else
               lOk := oEmpr:Altera()
            EndIf

         Case "ESTORNO" $ cEvento
            If Empty(EF3->EF3_TITFIN)
               ::Warning(cEvento+": Não há chave de documento de movimentação bancária no financeiro para esse contrato.")
            Else
               lOk := oEmpr:Estorna()
            EndIf

         End Case

         If !lOk
            ::Error(oEmpr:aError)
         EndIf

         /*
         If !::oContrato:lParcelas .AND. !::oContrato:lImportacao

            //oTit := AvContaPagar():LoadEF1()

            If "ESTORNO" $ cEvento
               ::EstornaProvisorio()//oTit:EstornaProvisorio()
            Else
               ::lGeraProvisorio := .T.
            EndIf

         ElseIf ::oContrato:lParcelas .AND. !::oContrato:lImportacao

         EndIf
         */

   Case "ENCERRAMENTO_CONTRATO" $ cEvento .Or. "ENCARGOS" $ cEvento .OR. "PARCELA_PRINCIPAL" $ cEvento .OR. "PARCELA_JUROS" $ cEvento //.OR. !::oContrato:lParcelas .AND. "LIQUIDACAO_INVOICE" $ cEvento - FSM - 17/02/2012 - Nopado

         If "PARCELA_PRINCIPAL" $ cEvento .AND. !EF3->EF3_CODEVE == "700"
            ::Warning("EventoFinanceiro - PARCELA_PRINCIPAL - Evento precisa ter código 700")

         ElseIf "PARCELA_JUROS" $ cEvento .AND. !Left(EF3->EF3_CODEVE,2) == "71"
            ::Warning("EventoFinanceiro - PARCELA_PRINCIPAL - Evento precisa ter código 700")

         ElseIf "ENCARGOS" $ cEvento .AND. !Left(EF3->EF3_CODEVE,1) $ "3/4"
            ::Warning("EventoFinanceiro - GERACAO_ENCARGOS - Evento não começa com código 3 ou 4.")
         EndIf

         oTit := AvContaPagar():LoadEF3(@Self)
		 //lOk  := !oTit:HasErrors() FSM - 21/03/2012

         If oTit:lLiquidado .AND. Empty(EF3->EF3_TX_MOE)
            lOk := oTit:EstornaLiq()
         EndIf

		 //If lOk  - FSM - 21/03/2012
			 Do Case

			 Case "INCLUSAO" $ cEvento .AND. (lOk  := !oTit:HasErrors()) .And. EF3->EF3_VL_MOE > 0 //FSM - 02/03/2012
				If !Empty(EF3->EF3_TITFIN)
				   ::Warning(cEvento+": Já existe uma chave de titulo no financeiro para esse evento.")
				   lOk := oTit:Altera()
				Else
				   lOk := oTit:Inclui()
				EndIf

			 Case "ALTERACAO" $ cEvento .AND. (lOk  := !oTit:HasErrors()) .And. EF3->EF3_VL_MOE > 0 //FSM - 02/03/2012
				If Empty(EF1->EF1_DT_ENC)//FSY - 13/02/2014 - Ajuste para excluir parcela em aberta com o contrato encerrado no SIGAFIN
				   If Empty(EF3->EF3_TITFIN)
				      ::Warning(cEvento+": Não há uma chave de titulo no financeiro para esse evento.")
				      lOk := oTit:Inclui()
				   ElseIf !oTit:lLiquidado
				      lOk := oTit:Altera()
				   EndIf
				ElseIf !oTit:lLiquidado .AND. WorkEF3->EF3_TX_MOE == 0 //MCF - 06/11/2015
				   lOk := oTit:Estorna()//FSY - 13/02/2014
				EndIf

			 Case "ESTORNO" $ cEvento .or. "ALTERACAO" $ cEvento .AND. EF3->EF3_VL_MOE == 0 //FSM - 02/03/2012
				If Empty(EF3->EF3_TITFIN)
				   ::Warning(cEvento+": Não há uma chave de titulo no financeiro para esse evento.")
				Else
				   If oTit:lLiquidado
					  lOk := oTit:EstornaLiq()
				   EndIf

				   If lOk
					  lOk := oTit:Estorna()
				   EndIf
				EndIf

			 End Case
         //EndIf

         If lOk .AND. !oTit:lLiquidado .AND. !Empty(EF3->EF3_TX_MOE) .AND. !("ESTORNO" $ cEvento) .And. EF3->EF3_VL_MOE > 0 //FSM - 02/03/2012
            lOk := oTit:Liquida()
         EndIf

         If !lOk
            ::Error(oTit:aError)
         EndIf

      Case "VINCULACAO_INVOICE" $ cEvento
         /*
         oTit := AvContaPagar():LoadEF3(@Self)
         If !::oContrato:lParcelas .AND. !::oContrato:lImportacao
            //Atualizar os provisorios no financeiro
            If "ESTORNO" $ cEvento
               lOk := oTit:EstornaProvisorio()
            Else
               lOk := oTit:GeraProvisorio()
            EndIf
            ::lGeraProvisorio := .T.
         EndIf

         If !lOk
            ::Error(oTit:cError)
         EndIf
         */
      //Case "LIQUIDACAO_INVOICE" $ cEvento
         /*
         If !::oContrato:lParcelas .AND. !::oContrato:lImportacao

            oTitLiq := AvContaPagar():LoadEF3(@Self)

            EF3->(nOrdEF3:= IndexOrd(),nRecEF3:= RecNo())

            EF3->(dbSetOrder(1))//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
            If EF3->EF3_CODEVE $ "630/660"
               lOk := EF3->(dbSeek(xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)+"600"+EF3->(EF3_PARC+EF3_INVOIC)))
            ElseIf Left(EF3->EF3_CODEVE,2) == "64/67"
               lOk := EF3->(dbSeek(xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)+"65"+Right(EF3->EF3_CODEVE,1)+EF3->(EF3_PARC+EF3_INVOIC)))
            EndIf

            If !lOk
               ::Error("Vinculação não encontrada para essa liquidação")
               Break
            EndIf

            oTitVinc := AvContaPagar():LoadEF3(@Self)

            EF3->(dbSetOrder(nOrdEF3),dbGoTo(nRecEF3))

            //Atualizar os provisorios no financeiro
            If "ESTORNO" $ cEvento
               lOk := oTitLiq:EstornaLiq()
               If lOk
                  lOk := oTitLiq:EstornaEfetivo()
               EndIf
               If lOk
                  lOk := oTitVinc:GeraProvisorio()//oTit:GeraProvisorio()
               EndIf
            Else
               lOk := oTitVinc:Estorna()
               If lOk
                  lOk := oTitLiq:GeraEfetivo()
               EndIf
               If lOk
                  lOk := oTitLiq:Liquida()
               EndIf
            EndIf
         EndIf

         If !lOk
            ::Error(oTitVinc:cError)
            ::Error(oTitLiq:cError)
         EndIf
         */
      Case "ATUALIZA_PROVISORIOS" $ cEvento

         //If ::lGeraProvisorio
         //   ::GeraProvisorio()
         //   ::lGeraProvisorio := .F.
         //EndIf

      EndCase

      End Sequence

   Return lOk

   Method ContabEvento(oContrato,cEvento) Class AvEFF_FIN
      Local lRet := .F.

      EC6->(dbSetOrder(1))
      If EC6->(dbSeek(xFilial("EC6")+"FI"+if(oContrato:cTpModu == "I","IM","EX")+oContrato:cTpFin+cEvento))
         lRet := EC6->EC6_CONTAB == "1"
      EndIf

      If lRet
         If cEvento == "100" .AND. Empty(oContrato:dIniJur)
            lRet := .F.
         EndIf
      EndIf

   Return lRet
   /*
      Método..: LancPadEF3()
      Classe..: AvEFF_FIN
      Objetivo: Executa o lançamento padrão no SIGACTB para determinado contrato do SIGAEFF
      Autor...: Alessandro Alves Ferreira
   */
   Method LancPadEF3(oContrato,nHdlPrv,cPadrao,cLote,lUsaFlag,aFlagCTB) Class AvEFF_FIN
      Local nTotal   := 0

      EF3->(dbSetOrder(1))
      EF3->(dbSeek(oContrato:cChaveEF1))
      Do While EF3->( !Eof() .AND. Left(&(IndexKey()),Len(oContrato:cChaveEF1)) == oContrato:cChaveEF1)

         EC6->(dbSetOrder(1),dbSeek(xFilial()+If(EF1->EF1_TPMODU <> "I","FIEX","FIIM")+EF1->EF1_TP_FIN+EF3->EF3_CODEVE))  // GFP - 30/06/2014

         If Empty(EF3->EF3_NR_CON) .AND. ::ContabEvento(oContrato,EF3->EF3_CODEVE)

            SEH->(dbGoTo(0)) //Evita contabilizacao pelo SEH
            ECE->(dbGoTo(0)) //Evita contabilizacao pelo ECE

            //Lancamento Padrao no SIGACTB
            nTotal += DetProva(nHdlPrv,cPadrao,"EFFEX102",cLote)

     		If !lUsaFlag
     		   RecLock("EF3",.F.)
               EF3->EF3_NR_CON := cLote
               EF3->(MsUnLock())
            Else
			   aAdd( aFlagCTB, {"EF3_NR_CON", cLote, "EF3", EF3->( Recno() ), 0, 0, 0} )
			EndIf
         EndIf

         EF3->(dbSkip())
      EndDo

   Return nTotal

   Method LancPadECE(nHdlPrv,cPadrao,cLote,lUsaFlag,aFlagCTB) Class AvEFF_FIN
      Local nTotal := 0
      Local cNrVazio := ""
      Local aContabECE
      Local i

      //Contratos Estornados
      If ChkFile("ECE")
         cNrVazio := Space(Len(ECE->ECE_NR_CON))

         aContabECE := {}

         EF7->(dbSetOrder(1))
         EF7->(dbSeek(xFilial("EF7")))
         Do While EF7->( !EoF() .AND. EF7_FILIAL == xFilial("EF7") )

            ECE->(dbSetOrder(2))//ECE_FILIAL+ECE_TPMODU+ECE_NR_CON
            cChaveECE := xFilial("EF3")+"FI"+if(EF7->EF7_TP_FIN == "I","IM","EX")+EF7->EF7_FINANC+cNrVazio

            ECE->(dbSeek(cChaveECE))
            Do While ECE->( !Eof() .AND. Left(&(IndexKey()),Len(cChaveECE)) == cChaveECE)
               If Empty(ECE->ECE_NR_CON)
                  aAdd(aContabECE,ECE->(RecNo()))
               EndIf

               ECE->(dbSkip())
            EndDo

            EF7->(dbSkip())
         EndDo

         For i:= 1 To Len(aContabECE)
            ECE->(dbGoTo(aContabECE[i]))

            //Evita contabilizacao pelo SEH e EF3
            SEH->(dbGoTo(0))
            EF3->(dbGoTo(0))

            //Lancamento Padrao no SIGACTB
            nTotal += DetProva(nHdlPrv,cPadrao,"EFFEX102",cLote)

            If !lUsaFlag
               RecLock("ECE",.F.)
               ECE->ECE_NR_CON := cLote
               ECE->(MsUnLock())
            Else
               aAdd(aFlagCTB, {"ECE_NR_CON", cLote, "ECE", ECE->( Recno() ), 0, 0, 0} )
            EndIf

         Next i

      EndIf

      Return nTotal
   /*
      Método..: ContabilizaEFF()
      Classe..: AvEFF_FIN
      Objetivo: Dispara a contabilização dos contratos do SIGAEFF
      Autor...: Alessandro Alves Ferreira
   */
   Method ContabilizaEFF(dDtProc,nHdlPrv,cPadrao,aFlagCtb,lUsaFlag,cLote) Class AvEFF_FIN
      Local nValor    := 0
      Local cChaveEF1 := xFilial("EF1")//+"E"  // GFP - 30/06/2014
      Local oContra
      Local dBCotMoe := cToD("  /  /   ")
            //THTS - 15/03/2022 - NOPADO - A pergunta referente ao MV_PAR04 foi descontinuada pelo módulo.                     
      Local lContabil:= .T.//If(Type("MV_PAR04")=="N", MV_PAR04==1, .F.)//FSM - 29/06/2012
      ::New()

      If ::lAtivo
         dBCotMoe := EX102DtTela(dDtProc) //FSM - 27/04/2012

         EF1->(dbSetOrder(1))
         EF1->(dbSeek(cChaveEF1))
         Do While EF1->( !Eof() .AND. Left(&(IndexKey()),Len(cChaveEF1)) == cChaveEF1)

            oContra := AvEFFContra():LoadEF1()
            If EF1->EF1_TPMODU == "I" .OR. !oContra:lParcelas  // GFP - 30/06/2014
               oContra:ApropriaJurosVC(dDtProc, dBCotMoe) //FSM - 27/04/2012
               If VerPadrao(cPadrao) .And. lContabil //FSM - 04/04/2012
                  nValor += ::LancPadEF3(oContra,nHdlPrv,cPadrao,cLote,lUsaFlag,aFlagCtb)
               EndIf
            EndIf

            EF1->(dbSkip())
         EndDo

         //Lancamentos de Contratos Estornados
         If VerPadrao(cPadrao) .And. lContabil  //FSM - 04/04/2012
            nValor += ::LancPadECE(nHdlPrv,cPadrao,cLote,lUsaFlag,aFlagCtb)
         EndIf

      EndIf

   Return nValor

   /*
      Método..: SaldoValorContratos()
      Classe..: AvEFF_FIN
      Objetivo: Retorna os saldos atualizados dos contratos do SIGAEFF
      Autor...: Alessandro Alves Ferreira
   */
   Method SaldoValorContratos(dData,lReais) Class AvEFF_FIN
      Local lRet      := .T.
      Local cChaveEF1 := xFilial("EF1")+"E"
      Local aSaldos   := {}
      Local i, oContra, nPrACC, aJrACCAtu, nValor, aDados
      Local nValorRS, nPrACCRS
      Local oInv

      EF1->(dbSetOrder(1))
      EF1->(dbSeek(cChaveEF1))
      Do While EF1->( !Eof() .AND. Left(&(IndexKey()),Len(cChaveEF1)) == cChaveEF1)

         oContra := AvEFFContra():LoadEF1()
         oContra:AtualizaSaldos()

         If !oContra:lParcelas

            //Principal ACC Atualizado
            nPrACC   := oContra:nSaldo
            nPrACCRS := BuscaTaxa(oContra:cMoeda,dData,,.F.,.T.)*nPrACC//xMoeda(oContra:nSaldo,SimbToMoeda(oContra:cMoeda),1,dData)

            //Calcula total de Juros ACC
            aJrACCAtu := oContra:CalcJuros(oContra:dIniJur,dData,oContra:cTpFin,oContra:nSaldo)

            For i := 1 To Len(oContra:aInvVinc)
               oInv := oContra:aInvVinc[i]
               //Principal ACE Atualizado
               oInv:nValorRS := oContra:ValorRS(oInv:nValor,dData,"600")
               //Calcula total de Juros ACE
               oInv:aJuros   := oContra:CalcJuros(oContra:dIniJur,dData,oContra:cTpFin,oInv:nValor,{oInv:cPreemb,oInv:cInvoice,oInv:cParc})
            Next i

            //Principal ACC
            nValor   := nPrACC
            nValorRS := nPrACCRS

            //Juros ACC Reais
            aEval(aJrACCAtu,{|X| nValorRS+= X[3]})
            //Principal e Juros ACE Reais
            aEval(oContra:aInvVinc,{|X| if(!X:lLiquidado,(nValorRS += X:nValorRS, aEval(X:aJuros,{|Y| nValorRS += Y[3]})),)})

            //Juros ACC
            aEval(aJrACCAtu,{|X| nValor+= X[2]})
            //Principal e Juros ACE
            aEval(oContra:aInvVinc,{|X| if(!X:lLiquidado,(nValor += X:nValor, aEval(X:aJuros,{|Y| nValor += Y[2]})),)})

            aDados:={}
            aAdd(aDados,oContra:cContrato)
            aAdd(aDados,oContra:cBanco)
            aAdd(aDados,oContra:cAgencia)
            aAdd(aDados,oContra:cConta)
            aAdd(aDados,oContra:dIniJur)
            aAdd(aDados,oContra:nTaxa*nValor)//)nValorRS)
            aAdd(aDados,"EF1")
            aAdd(aDados,oContra:cChaveEF1)
            aAdd(aDados,oContra:cMoeda)
            aAdd(aDados,nValor)

            aAdd(aDados,oContra:dVencimento) //WHRS 01/08/2017 foi alterado o parameto de comparação do Ascan de dDataTrab para aRet[i][11] TE-6355 526889 / MTRADE-1262 - Fluxo de caixa com emprestimo do Exportação

            aAdd(aSaldos,aClone(aDados))
         EndIf

         EF1->(dbSkip())
      EndDo

   Return aClone(aSaldos)

/*
Classe..: AvContaPagar
Objetivo: Representar titulos a pagar no financeiro Microsiga
Autor...: Alessandro Alves Ferreira
Data....: 10/11/2009
*/
Class AvContaPagar INHERIT from AvTitulo

   Data aSE2
   Data cChaveSE2
   Data cMotBaixa
   Data cMoedaSiga
   Data nValorEve
   Data oIntFin
   Data cTpTx

   Method New() Constructor
   Method LoadEF3() Constructor

   Method SetNum()
   Method SetSE2()
   Method GetSE2Num()
   Method GetSE2Tp()
   Method SetTpTit()
   Method SetMotBaixa()
   Method SetNatureza()
   Method SetDtEmissao() // FSM - 14/03/2012
   Method Valida()
   Method VerificaLiq()

   Method PosicionaEF3()

   Method Inclui()
   Method Altera()
   Method Estorna()

   Method Liquida()
   Method EstornaLiq()

   Method IntegraSE2()
   Method GravaEF3()

EndClass

//Inicio - Métodos AvContaPagar
   /*
      Método..: New()
      Classe..: AvContaPagar
      Objetivo: Construtor da classe AvContaPagar
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method New(oObj) Class AvContaPagar
      if oObj:cClassName == "AvEFF_FIN"
         _Super:New(oObj:oContrato)
         ::setClassName("AvContaPagar")
         ::oIntFin    := oObj
         ::cChaveSE2  := ""
         ::cMoedaSiga := "1"
         ::aSE2       := {}
      Else
         _Super:New(oObj)
         ::setClassName("AvContaPagar")
      EndIf

   Return Self

   /*
      Método..: LoadEF3()
      Classe..: AvContaPagar
      Objetivo: Construtor da classe AvContaPagar com base em registro do EF3.
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method LoadEF3(oIntFin) Class AvContaPagar
      Local cTpTx
	  _Super:LoadEF3(oIntFin:oContrato)

      ::setClassName("AvContaPagar")
      ::oIntFin    := oIntFin
      ::cChaveSE2  := ""
      ::cMoedaSiga := "1"
      ::aSE2       := {}
      ::cChaveSE2 := Left(EF3->EF3_TITFIN, Len(SE2->(&(IndexKey(1)))) ) //FSM - 24/02/2012

      If !Empty(EF3->EF3_PARC)
         ::cParcela  := EF3->EF3_PARC
      Else
         ::cParcela := "1"
      EndIf

      If !Empty(::cChaveSE2)
         ::cTipoFin := ::GetSE2Tp()
      EndIf

      ::SetTpTit(EF3->EF3_CODEVE)
      ::SetNatureza(EF3->EF3_CODEVE)
      ::SetMotBaixa(EF3->EF3_CODEVE)

      ::dDtEve     := if(!Empty(EF3->EF3_DT_EVE), If( EF3->(FieldPos("EF3_DTOREV")) > 0 .And. !Empty(EF3->EF3_DTOREV), EF3->EF3_DTOREV , EF3->EF3_DT_EVE ) ,dDataBase) //NCF - 10/03/2016 - Considerar a Data de liquidação devido ao movimento bancário
      ::SetDtEmissao(EF3->EF3_CODEVE) //FSM - 14/03/2012

      ::dVencto	   := Max(::dDtEve,dDatabase)
      ::dVencReal  := DataValida(::dVencto,.T.)
      ::cMoedaSiga := Posicione("SYF",1,xFilial("SYF")+EF1->EF1_MOEDA,"YF_MOEFAT")
      ::cMoeda     := EF1->EF1_MOEDA //NCF - 24/03/2016 - Moeda não era carregada enste metodo, somente no método LoadEF3 sobrecarregado da classe AvEmprestimo
	  If Empty(::cMoedaSiga)
	     ::cMoedaSiga := SimbToMoeda(EF1->EF1_MOEDA)
      EndIf

      If !Empty(EF3->EF3_DT_DEB)
         ::dDtDebito := EF3->EF3_DT_DEB
      ElseIf !Empty(EF3->EF3_DT_DES)
         ::dDtDebito := EF3->EF3_DT_DES
      Else
         ::dDtDebito := ::dDtEve
      EndIf

      ::nValor     := EF3->EF3_VL_MOE
      ::nValorEve  := ::nValor

	   ::cTpTx := Posicione("EC6",1,xFilial("EC6")+If(EF1->EF1_TPMODU <> "I","FIEX","FIIM")+EF1->EF1_TP_FIN+EF3->EF3_CODEVE,"EC6_TXCV")

      If !Empty(EF3->EF3_VL_REA)
         ::nValorRS := EF3->EF3_VL_REA
      Else
         ::nValorRS := BuscaTaxa(::cMoeda,::dEmissao,,.F.,.T.,,::cTpTx)*::nValor//xMoeda(::nValor,::cMoedaSiga,1,::dEmissao)
      EndIf

      If !Empty(EF3->EF3_TX_MOE)
         ::nTaxa := EF3->EF3_TX_MOE
      Else
         ::nTaxa := BuscaTaxa(::cMoeda,::dEmissao,,.F.,.T.,,::cTpTx)
      EndIf

	  If Empty(::nTaxa)
	     Self:Error("Titulo não pode ser integrado pois a cotação de "+AllTrim(BSCXBOX("EC6_TXCV",::cTpTx))+" da moeda "+::cMoeda+" não está preenchida.")
	  EndIf

      ::VerificaLiq()
      ::SetHist()

   Return Self

   /*
      Método..: GetSE2Num()
      Classe..: AvContaPagar
      Objetivo: Retornar numero do titulo a pagar no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method GetSE2Num() Class AvContaPagar

      If ::cChaveSE2 <> SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
         SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
         SE2->(dbSeek(::cChaveSE2))
      EndIf

   Return SE2->E2_NUM

   /*
      Método..: GetSE2Tp()
      Classe..: AvContaPagar
      Objetivo: Retornar tipo do titulo a pagar no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method GetSE2Tp() Class AvContaPagar

      If ::cChaveSE2 <> SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
         SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
         SE2->(dbSeek(::cChaveSE2))
      EndIf

   Return SE2->E2_TIPO

   /*
      Método..: SetNum()
      Classe..: AvContaPagar
      Objetivo: Definir o numero do titulo a pagar no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method SetNum(cNumero) Class AvContaPagar

      If !Empty(::cChaveSE2)
         ::cNumTit := ::GetSE2Num()
      ElseIf !Empty(cNumero) .AND. ValType(cNumero) == "C"
         ::cNumTit := cNumero
      ElseIf Empty(::cNumTit)
         ::cNumTit := GetSXENum("SE2","E2_NUM")
         ConfirmSX8()
      EndIf

   Return Nil

   /*
      Método..: SetTpTit()
      Classe..: AvContaPagar
      Objetivo: Definir o tipo do titulo a pagar no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method SetTpTit(cCodEve) Class AvContaPagar

      If !Empty(::cChaveSE2)
         If ::cChaveSE2 <> SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
            SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
            SE2->(dbSeek(::cChaveSE2))
         EndIf

         ::cTipoFin := SE2->E2_TIPO
      ElseIf Empty(::cTipoFin) .AND. !Empty(cCodEve)

         ::cTipoFin := Posicione("EC6",1,xFilial("EC6")+"FI"+if(::oIntFin:oContrato:cTpModu=="I","IM","EX")+::oIntFin:oContrato:cTpFin+cCodEve,"EC6_TPTIT")

         If Empty(::cTipoFin)
            ::cTipoFin := "NF"
         EndIf


         //If cCodEve $ "630/660" .OR. Left(cCodEve,2) $ "64/67"

         /*ElseIf cCodEve == "600" .OR. Left(cCodEve,2) == "65"
            ::cTipoFin := "PRE"
         ElseIf cCodEve == "100"
            ::cTipoFin := "PR"*/
         //EndIf
      EndIf

   Return ::cTipoFin

   /*
      Método..: SetNatureza()
      Classe..: AvContaPagar
      Objetivo: Definir a natureza para o titulo a pagar no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method SetNatureza(cCodEve) Class AvContaPagar
      ::cNatureza := Posicione("EC6",1,xFilial("EC6")+"FI"+if(::oIntFin:oContrato:cTpModu=="I","IM","EX")+::oIntFin:oContrato:cTpFin+::cEvento,"EC6_NATFIN")

      If Empty(::cNatureza)
         ::cNatureza := Posicione("EF7",1,xFilial("EF7")+::oIntFin:oContrato:cTpFin,"EF7_NATFIN")
      EndIf

   Return ::cNatureza

   /*
      Método..: SetSE2()
      Classe..: AvContaPagar
      Objetivo: Definir o array de campos do SE2 para gravação do titulo a
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method SetSE2(aSE2,lBaixa) Class AvContaPagar
      Local lExiste, lMoedaEst, nTaxa
      Local nMoedaSA6 := 0
      Private cForn, cLoja, oTit
      Default lBaixa := .F.

      If ValType(aSE2) == "A" .AND. ::Valida(aSE2)
         ::aSE2 := aClone(aSE2)
      Else
         ::aSE2 :={}

         oTit := Self
         //Se nao tive fornecedor e loja no titulo, gera com o do banco do contrato
         If !Empty(oTit:cForn) .And. !Empty(oTit:cLoja)
            cForn := oTit:cForn
            cLoja := oTit:cLoja
         Else
            cForn := oTit:oEFFContra:cForn
            cLoja := oTit:oEFFContra:cLoja
         EndIf

         SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
         lExiste := !Empty(::cChaveSE2) .And. SE2->(dbSeek(::cChaveSE2)) //FSM - 02/03/2012

         aAdd(::aSE2,{ "E2_FILIAL"	 , If(lExiste,Left(Self:cChaveSE2,FwSizeFilial()),xFilial("SE2")) , Nil }) //NCF - 26/04/2017 - Enviar a filial correta do título em caso de liquidação de câmbio 
         aAdd(::aSE2,{ "E2_PREFIXO"	, "EFF"	      			, Nil })                                           //                   vinculado a contrato com vinculações multifiliais.
         aAdd(::aSE2,{ "E2_NUM"		, ::cNumTit				, Nil })
         aAdd(::aSE2,{ "E2_PARCELA" , ::cParcela            , Nil })
         aAdd(::aSE2,{ "E2_TIPO"	, ::cTipoFin           	, Nil })
         aAdd(::aSE2,{ "E2_NATUREZ"	, ::cNatureza			, Nil })
         aAdd(::aSE2,{ "E2_FORNECE"	, cForn  				, Nil })
         aAdd(::aSE2,{ "E2_LOJA"   	, cLoja  				, Nil })
         aAdd(::aSE2,{ "E2_VALOR"  	, ::nValor  			, Nil })
         aAdd(::aSE2,{ "E2_MOEDA"	, ::cMoedaSiga          , Nil })

         If !lBaixa
               aAdd(::aSE2,{ "E2_EMIS1"  	, dDatabase			, Nil })
               aAdd(::aSE2,{ "E2_EMISSAO"	, ::dEmissao         , Nil })
               aAdd(::aSE2,{ "E2_VENCORI"	, ::dVencto			, Nil })
               aAdd(::aSE2,{ "E2_HIST"   	, ::cHistorico		, Nil })
               aAdd(::aSE2,{ "E2_ORIGEM" 	, "SIGAEFF"			, Nil })
               aAdd(::aSE2,{ "E2_VENCTO"	, ::dVencto			, Nil }) //FSM - 21/03/212
               aAdd(::aSE2,{ "E2_VENCREA"	, ::dVencReal    	    , Nil })
			
            If !lExiste .OR. SE2->E2_TXMOEDA <= 0 //AAF 05/05/2017 - Garantir o envio da taxa correta, nos casos em que a base ja estava com o E2_TXMOEDA vazio.

               nTaxa := BuscaTaxa(::cMoeda,::dEmissao,,.F.,.T.,,::cTpTx)
               If Left(oTit:cEvento,2) $ "70"
                  aPosEF3 := EF3->({IndexOrd(),RecNo()})
                  EF3->(dbSetOrder(1))
                  EF3->(dbSeek(::oEFFContra:cChaveEF1+"100"))
                  
                  If !Empty(EF3->EF3_TX_MOE)
                     nTaxa := EF3->EF3_TX_MOE
                  EndIf
                  EF3->(dbSetOrder(aPosEF3[1]),dbGoTo(aPosEF3[2]))
               
               ElseIf Empty(nTaxa)
                  nTaxa := RecMoeda(::dEmissao, ::cMoedaSiga)
               EndIf

               //** AAF 24/01/2017 - Garante o envio da taxa ao financeiro
               aAdd(::aSE2,{ "E2_TXMOEDA"	, nTaxa, Nil })
               aAdd(::aSE2,{ "E2_VLCRUZ" 	, ::nValor * nTaxa , Nil })

            Else            
               //AAF 07/02/2017 - Mantem o valor em reais para não ter problema de variação câmbial
               aAdd(::aSE2,{ "E2_VLCRUZ" 	, ::nValor * SE2->E2_TXMOEDA , Nil })
            EndIf
               
         Else
            aAdd(::aSE2,{ "AUTVALREC" 	, ::nValor			, Nil })
            /* Se a moeda do evento (contrato) é a mesma do banco, enviar a taxa do dia e deixar o SIGAFIN apurar os cálculos. */
            lMoedaEst:= Posicione("SA6", 1, SA6->(xFilial()) + ::cBanco + ::cAgencia + ::cConta, "A6_MOEEASY") == ::cMoeda
            If lMoedaEst
               aAdd(::aSE2,{ "AUTTXMOEDA" 	, RecMoeda(dDataBase, ::cMoedaSiga), Nil })
            Else
               aAdd(::aSE2,{ "AUTTXMOEDA" 	, ::nTaxa			, Nil })
            EndIf

            aAdd(::aSE2,{ "AUTMOTBX" 	, ::cMotBaixa		, Nil })
            aAdd(::aSE2,{ "AUTDTBAIXA" 	, ::dDtEve 			, Nil })
            aAdd(::aSE2,{ "AUTBANCO" 	, ::cBanco      	, Nil })
            aAdd(::aSE2,{ "AUTAGENCIA" 	, ::cAgencia 		, Nil })
            aAdd(::aSE2,{ "AUTCONTA" 	, ::cConta  	    , Nil })
            aAdd(::aSE2,{ "AUTHIST" 	, "SIGAEFF " + ::cHistorico, Nil })
            AADD(::aSE2,{ "AUTDESCONT"   ,0                 , Nil })
            AADD(::aSE2,{ "AUTMULTA"     ,0                 , Nil })
            AADD(::aSE2,{ "AUTJUROS"     ,0                 , Nil })
            AADD(::aSE2,{ "AUTOUTGAS"    ,0                 , Nil })           

            nMoedaSA6 := Posicione("SA6", 1, SA6->(xFilial()) + ::cBanco + ::cAgencia + ::cConta, "A6_MOEDA")   
            If nMoedaSA6 > 1
               If lMoedaEst
                  AADD(::aSE2,{ "AUTVLRPG"     ,::nValor        , Nil })
               Else                  
                  AADD(::aSE2,{ "AUTVLRPG"     , Round(::nValor * ::nTaxa / RecMoeda( ::dDtEve, SA6->A6_MOEDA), AVSX3("WB_FOBMOE",AV_DECIMAL))        , Nil })
               EndIf               
            EndIf
           
            AADD(::aSE2,{ "AUTVLRME"     ,::nValor          , Nil })
            AADD(::aSE2,{ "AUTCHEQUE"    ,""                , Nil })
            AADD(::aSE2,{ "AUTDTDEB"     ,::dDtDebito       , Nil })
         EndIf

         ::Valida()
      EndIf
   IF EasyEntryPoint("EFFEX102")//FSY - 23/07/2013 - Criado ponto de entreda para alterar o vetor aSE2 do objeto oTit.
      ExecBlock("EFFEX102",.F.,.F.,"INT_SE2")
   ENDIF

   Return nil

   /*
      Método..: SetDtEmissao()
      Classe..: AvContaPagar
      Objetivo: Definir a data de emissao do titulo
      Autor...: Felipe Sales Martinez - FSM
      Data....: 14/03/2012
   */
   Method SetDtEmissao(cCodEve) Class AvContaPagar

       Local dDtEmissao

       If Left(cCodEve,2) $ "70/71"
          If !Empty(::oIntFin:oContrato:dIniJur)
             dDtEmissao := Min(::oIntFin:oContrato:dIniJur,dDataBase)
          EndIf
       ElseIf !Empty(::dDtEve)
          dDtEmissao := Min(::dDtEve,dDataBase)
       EndIf

	   If Empty(dDtEmissao)
	      dDtEmissao := dDataBase
	   EndIf

       ::dEmissao := dDtEmissao

   Return Nil


   /*
      Método..: Liquida()
      Classe..: AvContaPagar
      Objetivo: Baixa de contas a pagar no financeiro
      Autor...: Alessandro Alves Ferreira
   */
   Method Liquida() Class AvContaPagar
      Local lRet := .F.

      Begin Sequence

      ::SetNum() //MCF - 05/11/2015
      ::SetTpTit()

      If Empty(::cNumTit)
         ::Error("Titulo á liquidar não específicado")
         Break
      EndIf

      SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
      SE2->(dbSeek(::cChaveSE2))

      RegToMemory("SE2",.F.)

      ::SetSE2(,.T.)

      If !::lLiquidado
         lRet := ::IntegraSE2("BAIXA")
         If lRet
            ::lLiquidado := .T.
            ::dDataLiq   := dDataBase
         EndIf
      Else
         ::Warning("Tentativa de liquidar contas a pagar que já está liquidado.")
      EndIf

      End Sequence

   Return lRet

   /*
      Método..: Liquida()
      Classe..: AvContaPagar
      Objetivo: Estorno de baixa de contas a pagar no financeiro
      Autor...: Alessandro Alves Ferreira
   */
   Method EstornaLiq() Class AvContaPagar
      Local lRet := .F.

      Begin Sequence

      If Empty(::cChaveSE2)
         ::Error("Titulo á estornar liquidação não específicado")
         Break
      EndIf

      ::SetNum()
      ::SetTpTit()

      If ::lLiquidado
         lRet := ::IntegraSE2("ESTBAIXA")
         If lRet
            ::lLiquidado := .F.
            ::dDataLiq   := CTod("  /  /  ")
         EndIf
      Else
         ::Warning("Tentativa de liquidar contas a pagar que já está liquidado.")
      EndIf

      End Sequence

   Return lRet

   /*
      Método..: Inclui()
      Classe..: AvContaPagar
      Objetivo: Inclusao de contas a pagar no financeiro
      Autor...: Alessandro Alves Ferreira
   */
   Method Inclui() Class AvContaPagar
      ::SetNum()
      ::SetTpTit()
   Return ::IntegraSE2("INCLUIR")

   /*
      Método..: Altera()
      Classe..: AvContaPagar
      Objetivo: Alteracao de contas a pagar no financeiro
      Autor...: Alessandro Alves Ferreira
   */
   Method Altera() Class AvContaPagar
   Local lRet := .F.
   
      ::SetNum()
      ::SetTpTit()
      //WHRS TE-6335 526188 / MTRADE-1243 - Erro NAO VALOR na alteração de contrato
      if EasyGParam("MV_EFF0010",,.F.)
        if ::IntegraSE2("EXCLUIR")
          lRet := ::IntegraSE2("INCLUIR")
        ENDIF
      Else
        lRet := ::IntegraSE2("ALTERAR")
      ENDIF
      return lRet

   /*
      Método..: Estorna()
      Classe..: AvContaPagar
      Objetivo: Estorno de contas a pagar no financeiro
      Autor...: Alessandro Alves Ferreira
   */
   Method Estorna() Class AvContaPagar
      ::SetNum()
      ::SetTpTit()
   Return ::IntegraSE2("EXCLUIR")

   /*
      Método..: IntegraSE2()
      Classe..: AvContaPagar
      Objetivo: Executar integração com ERP Microsiga
      Autor...: Alessandro Alves Ferreira
   */
   Method IntegraSE2(cOpc) Class AvContaPagar
      Local cError

      ::SetSE2(,"BAIXA" $ cOpc)

      //lMsErroAuto := .F.
      //MSExecAuto({|a,b,c| FINA050(a,b,c)},::aSE2,,nOpc)

      If (nPosForn := aScan(::aSE2,{|X| X[1] == "E2_FORNECE"})) > 0 .AND. (nPosLoja := aScan(::aSE2,{|X| X[1] == "E2_LOJA"})) > 0
         SA2->(dbSetOrder(1))
         If !SA2->(dbSeek(xFilial("SA2")+::aSE2[nPosForn][2]+::aSE2[nPosLoja][2]))
            If Empty(::aSE2[nPosForn][2]) .OR. Empty(::aSE2[nPosLoja][2])
               cError := "Necessário preencher fornecedor e loja. Verifique o fornecedor/loja do encargo ou fornecedor/loja do banco de fechamento do contrato."
            EndIf
         EndIf
      EndIf

      If Len(::aSE2) > 0
         If SA2->(!EoF())
            cError := EECInFin(::aSE2, "SE2", cOpc,,,, "EF3")
             /* wfs - comentado. Exibir qualquer validação que retorne da integração.*/
            /*If At("HELP", StrTran(cError,"HELP: NOTAXAS","")) > 0 //FSM - 02/03/2012 //NCF - 04/04/2017 - Nopado novamente conforme informado acima.
			        cError := ""
            EndIf*/
         EndIf
      Else
         cError := "Titulo não definido."
      EndIf

      If !Empty(cError)
         //Help(" ", 1, "ERROGERACP")
         cError += "Dados da Integração:"+CHR(13)+CHR(10)                                                                              //NCF - 05/05/2017 - Melhoria na mensagem de erro para mostrar
         aEval(Self:aSE2,{|x| cError += x[1] + " = " + If( Valtype(x[2]) <> 'C', cValtochar(x[2]), x[2]) + CHR(13) + CHR(10) })        //                   os dados da integração para rastreamento.
         ::Error("Não foi possível "+If("BAIXA" $ cOpc,"baixar","gerar")+" o título financeiro do evento: "+ CHR(13) + CHR(10)+;
         ::cEvento+" - "+::cDescEve+" Parcela: "+::cParc+" Sequencia Contr.:"+::cSeq+Chr(13)+Chr(10)+Chr(13)+Chr(10)+cError)
      ElseIf cOPC $ "INCLUIR/ALTERAR"
         SE2->(dbSetOrder(1))////E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
         EasySeekAuto("SE2", ::aSE2, 1)//RMD - 16/04/14
         ::cChaveSE2 := SE2->(&(IndexKey()))
         ::GravaEF3()
      ElseIf cOPC $ "EXCLUIR"
         ::cChaveSE2 := ""
         ::GravaEF3()
      EndIf

   Return Empty(cError)

   /*
      Método..: Valida()
      Classe..: AvContaPagar
      Objetivo: Validações para integração de contas a pagar
      Autor...: Alessandro Alves Ferreira
   */
   Method Valida() Class AvContaPagar
      Local lRet := .T.

      SX3->(dbSetOrder(2))
      aEval(::aSE2,{|X| if(ValType(X[2])=="C".AND.SX3->(dbSeek(X[1])),X[2] := AvKey(X[2],X[1]),)})



   Return lRet

   /*
      Método..: VerificaLiq()
      Classe..: AvContaPagar
      Objetivo: Verifica se o titulo está baixado no financeiros
      Autor...: Alessandro Alves Ferreira
   */
   Method VerificaLiq() Class AvContaPagar

      If !Empty(::cChaveSE2)
         SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
         SE2->(dbSeek(::cChaveSE2))

         ::lLiquidado := !Empty(SE2->E2_BAIXA)

         If ::lLiquidado
            ::dDataLiq := SE2->E2_BAIXA
         EndIf
      EndIf

   Return ::lLiquidado

   /*
      Método..: GravaEF3()
      Classe..: AvContaPagar
      Objetivo: Gravar o EF3 com o numero do titulo no financeiro
      Autor...: Alessandro Alves Ferreira
   */
   Method GravaEF3() Class AvContaPagar
      Local nOldEF3

      If ::nRecNoEF3 > 0
         nOldEF3 := EF3->(RecNo())

         EF3->(dbGoTo(::nRecNoEF3))
         lLock := !EF3->(IsLocked())

         If(lLock,RecLock("EF3",.F.),)
         EF3->EF3_TITFIN := ::cChaveSE2
         If(lLock,EF3->(MsUnLock()),)

         EF3->(dbGoTo(nOldEF3))
      EndIf

   Return Nil

   Method SetMotBaixa(cEvento) Class AvContaPagar
      Default cEvento := ::cEvento

      ::cMotBaixa := Posicione("EC6",1,xFilial("EC6")+"FI"+if(::oEFFContra:cTpModu=="I","IM","EX")+::oEFFContra:cTpFin+cEvento,"EC6_MOTBX")

      If Empty(::cMotBaixa)
         If cEvento $ "700,630,660"
            ::cMotBaixa := Posicione("EF7",1,xFilial("EF7")+::oEFFContra:cTpFin,"EF7_MOTBXP")
         ElseIf Left(cEvento,2) $ "71,64,67"
            ::cMotBaixa := Posicione("EF7",1,xFilial("EF7")+::oEFFContra:cTpFin,"EF7_MOTBXJ")
         Else
            ::cMotBaixa := "NORMAL"
         Endif
      EndIf

   Return Nil

//Fim - Métodos AvContaPagar

/*
Classe..: AvEmprestimo
Objetivo: Representar empréstimos no financeiro Microsiga
Autor...: Alessandro Alves Ferreira
Data....: 10/11/2009
*/
Class AvEmprestimo INHERIT from AvObject

   Data oIntFin
   Data nRecNoEF3

   Data cNumero
   Data cOperacao
   Data cBanco
   Data cAgencia
   Data cConta

   Data cBancoMov
   Data cAgenciaMov
   Data cContaMov

   Data cNatureza
   Data dDtEmprestimo
   Data nValor
   Data nTaxa
   Data nValorRS
   Data cMoeda
   Data cMoedaSiga
   Data lLiquidado
   Data dDataLiq

   Data aSE5
   Data cChaveSE5

   Data cHistorico
   Data lMovBco

   Method New() Constructor
   Method LoadEF3() Constructor

   Method SetNum()
   Method SetSE5()

   Method GetSE5Num()
   Method SetTpEmp()
   Method Valida()
   Method VerificaLiq()

   Method Inclui()
   Method Altera()
   Method Estorna()
   Method IntegraSE5()
   Method SetNatureza()
   Method GravaEF3()

EndClass

//Inicio - Métodos AvEmprestimo
   /*
      Método..: New()
      Classe..: AvEmprestimo
      Objetivo: Contrutor da classe AvEmprestimo
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method New(oIntFin) Class AvEmprestimo
      _Super:New()
      ::setClassName("AvEmprestimo")

      ::oIntFin    := oIntFin
      ::cChaveSE5  := ""
      ::cMoedaSiga := "1"
      ::aSE5       := {}
      ::cNumero    := ""
      ::cOperacao  := ""
      ::cBanco     := ""
      ::cAgencia   := ""
      ::cConta     := ""
      ::cNatureza  := ""
      ::dDtEmprestimo:= CtoD("  /  /  ")
      ::nValor     := 0
      ::nTaxa      := 0
      ::nValorRS   := 0
      ::cMoeda     := ""
      ::lLiquidado := .F.
      ::dDataLiq   := CTod("  /  /  ")

      ::nRecNoEF3  := 0
      ::cBancoMov  := ""
      ::cAgenciaMov:= ""
      ::cContaMov  := ""
      ::cHistorico := ""
      ::lMovBco    := .T.                     //NCF - 13/07/2016

   Return Self

   /*
      Método..: LoadEF3()
      Classe..: AvEmprestimo
      Objetivo: Contrutor da Classe AvEmprestimo com base na tabela EF3
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method LoadEF3(oIntFin) Class AvEmprestimo
      ::New(@oIntFin)

      Begin Sequence

      cChaveEF3 := EF3->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT)
      cChaveEF1 := EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)

      If xFilial("EF3")+cChaveEF3 <> xFilial("EF1")+cChaveEF1
         nOldOrd := EF1->(IndexOrd())

         EF1->(dbSetOrder(1)) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE
         EF1->(dbSeek(xFilial("EF1")+cChaveEF3))

         EF1->(dbSetOrder(nOldOrd))
      EndIf

      ::nRecNoEF3     := EF3->(RecNo())

      ::cChaveSE5     := Left(EF3->EF3_TITFIN , Len( SE5->(&(IndexKey(15))) ) ) // FSM - 24/02/2012
      ::cBanco        := EF1->EF1_BAN_FI
      ::cAgencia      := EF1->EF1_AGENFI
      ::cConta        := EF1->EF1_NCONFI
      ::cBancoMov     := EF1->EF1_BAN_MO
      ::cAgenciaMov   := EF1->EF1_AGENMO
      ::cContaMov     := EF1->EF1_NCONMO
      ::dDtEmprestimo := EF3->EF3_DT_EVE //Max(EF3->EF3_DT_EVE,dDatabase)//Max(EF1->EF1_DT_JUR,dDatabase)//FSY - 19/06/2013 Chamado - THAXDV
      ::cMoeda        := EF1->EF1_MOEDA
      ::cMoedaSiga    := Posicione("SYF",1,xFilial("SYF")+EF1->EF1_MOEDA,"YF_MOEFAT")

	  If Empty(::cMoedaSiga)
	     ::cMoedaSiga := SimbToMoeda(EF1->EF1_MOEDA)
      EndIf

      ::SetNatureza()
      ::SetTpEmp(EF1->EF1_TP_FIN)

      //NCF - 11/07/2016 - Movimento Bancário de contrato PPE deve desconsiderar as transferências de ACC/ACE feitas para ele.
      //                   Quando a transferência corresponder ao total do emprestimo, não deve gerar movimento.
      If EF3->EF3_CODEVE == "100" .And. EF3->EF3_TP_EVE == "03" .And. EF1->EF1_VLTRAN <> 0
         If (EF3->EF3_VL_MOE - EF1->EF1_VLTRAN) == 0
            ::lMovBco := .F.
         Else
            ::nValorRS := BuscaTaxa(self:cMoeda,self:dDtEmprestimo,,.F.,.T.) * (EF3->EF3_VL_MOE - EF1->EF1_VLTRAN)
         EndIf
      Else
         If !Empty(EF3->EF3_VL_REA)
            ::nValorRS := EF3->EF3_VL_REA
         Else
            ::nValorRS := BuscaTaxa(::cMoeda,::dDtEmprestimo,,.F.,.T.)*::nValor//xMoeda(::nValor,::cMoedaSiga,1,::dEmissao)//GCC - 18/02/2014 - dDtEmprestimo
         EndIf
      EndIf

      If !Empty(EF3->EF3_TX_MOE)
         ::nTaxa := EF3->EF3_TX_MOE
      Else
         ::nTaxa := BuscaTaxa(::cMoeda,::dDtEmprestimo,,.F.,.T.)//xMoeda(1,::cMoedaSiga,1,::dEmissao)//GCC - 18/02/2014 - dDtEmprestimo
      EndIf

      ::lLiquidado := ::VerificaLiq()
      ::cHistorico := "SIGAEFF - "+AllTrim(oIntFin:oContrato:cTpFinDesc)+" - "+oIntFin:oContrato:cContrato

      End Sequence

   Return Self

   /*
      Método..: SetNum()
      Classe..: AvEmprestimo
      Objetivo: Definir o numero do movimento bancário do emprestimo no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method SetNum(cNumero) Class AvEmprestimo

      If !Empty(::cChaveSE5)
         ::cNumero := ::GetSE5Num()
      ElseIf !Empty(cNumero) .AND. ValType(cNumero) == "C"
         ::cNumero := cNumero
      ElseIf Empty(::cNumero)
         ::cNumero := EasyGetMVSeq("E5_PROCTRA")
         ConfirmSX8()
      EndIf

   Return Nil

   /*
      Método..: SetSE5()
      Classe..: AvEmprestimo
      Objetivo: Definir o numero do emprestimo no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method SetSE5(aSE5) Class AvEmprestimo
      If ValType(aSE5) == "A" .AND. ::Valida(aSE5)
         ::aSE5 := aClone(aSE5)
      Else
         ::aSE5 := {}

         aAdd(::aSE5,{"E5_FILIAL" ,xFilial("SE5") ,NIL}) //FSM - 10/05/2012
         aAdd(::aSE5,{"E5_BANCO"  ,::cBancoMov    ,NIL})
         aAdd(::aSE5,{"E5_AGENCIA",::cAgenciaMov  ,NIL})
         aAdd(::aSE5,{"E5_CONTA"  ,::cContaMov    ,NIL})
         aAdd(::aSE5,{"E5_DATA"   ,::dDtEmprestimo,NIL})
         aAdd(::aSE5,{"E5_VALOR"  ,::nValorRS     ,NIL})
         aAdd(::aSE5,{"E5_MOEDA"  ,::cOperacao    ,NIL})
         aAdd(::aSE5,{"E5_RECPAG" ,"R"            ,NIL})
         aAdd(::aSE5,{"E5_TIPODOC","  "           ,NIL})
         aAdd(::aSE5,{"E5_NATUREZ",::cNatureza    ,NIL})
         aAdd(::aSE5,{"E5_HISTOR" ,::cHistorico   ,NIL})
         aAdd(::aSE5,{"E5_DTDIGIT",dDataBase      ,NIL})
         aAdd(::aSE5,{"E5_DTDISPO",::dDtEmprestimo,NIL})
         aAdd(::aSE5,{"E5_PROCTRA",::cNumero      ,NIL})
         If SE5->(FieldPos("E5_ORIGEM"))>0
            aAdd(::aSE5,{"E5_ORIGEM","SIGAEFF",NIL})
         EndIf
         If ::cOperacao $ "C1/C2/C3/C4/C5/CH"
            aAdd(::aSE5,{"E5_MODSPB","3"          ,NIL})
         EndIf
         aAdd(::aSE5,{"INDEX"     ,15             ,NIL})

         ::Valida()
      EndIf

   Return Nil

   /*
      Método..: GetSE5Num()
      Classe..: AvEmprestimo
      Objetivo: Retorna o numero do emprestimo no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method GetSE5Num() Class AvEmprestimo
      SE5->(dbSetOrder(15))//E5_FILIAL+E5_PROCTRA
      SE5->(dbSeek(::cChaveSE5))
   Return SE5->E5_PROCTRA

   /*
      Método..: SetTpEmp()
      Classe..: AvEmprestimo
      Objetivo: Definir o tipo do emprestimo para o Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method SetTpEmp() Class AvEmprestimo
      ::cOperacao := Posicione("EF7",1,xFilial("EF7")+::oIntFin:oContrato:cTpFin,"EF7_NUMERA")
   Return ::cOperacao

   /*
      Método..: Valida()
      Classe..: AvEmprestimo
      Objetivo: Definir o numero do emprestimo no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method Valida() Class AvEmprestimo
      Local lRet := .T.
   Return lRet

   /*
      Método..: Inclui()
      Classe..: AvEmprestimo
      Objetivo: Inclui o Empréstimo no financeiro Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method Inclui() Class AvEmprestimo
      ::SetNum()
   Return ::IntegraSE5("RECEBER")

   /*
      Método..: Altera()
      Classe..: AvEmprestimo
      Objetivo: Altera o Empréstimo no financeiro Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method Altera() Class AvEmprestimo
      Local lRet := .T.

      SE5->(dbSetOrder(15))
      SE5->(dbSeek(::cChaveSE5))

      If SE5->E5_VALOR <> ::nValorRS
         ::SetNum()

         lRet := ::IntegraSE5("EXCLUIR")
         If lRet
            ::SetNum() //FSM - 24/02/2012
            lRet := ::IntegraSE5("RECEBER")
         EndIf
      EndIf

   Return lRet

   /*
      Método..: Estorna()
      Classe..: AvEmprestimo
      Objetivo: Estorna o Empréstimo no financeiro Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method Estorna() Class AvEmprestimo
      ::SetNum()
   Return ::IntegraSE5("EXCLUIR")

   /*
      Método..: IntegraSE5()
      Classe..: AvEmprestimo
      Objetivo: Faz a integração com a rotina de emprestimos no Microsiga
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method IntegraSE5(cOpc) Class AvEmprestimo
      Local cError
      Local dDtOld //FSY - 19/06/2013 - Chamado: THAXDV

      ::SetSE5()

      //lMsErroAuto := .F.
      //MSExecAuto({|a,b,c| FINA050(a,b,c)},::aSE2,,nOpc)

	  dDtOld := dDataBase //FSY - 19/06/2013 - Chamado: THAXDV

	  dDataBase := ::dDtEmprestimo//FSY - 19/06/2013 - Chamado: THAXDV

      If Len(::aSE5) > 0
         cError := EECInFin(::aSE5, "SE5", cOpc)
      Else
         cError := "Titulo não definido."
      EndIf

	  dDataBase := dDtOld//FSY - 19/06/2013 - Chamado: THAXDV

      SE5->(dbSetOrder(15)) //E5_FILIAL+E5_PROCTRA //FSM - 09/08/2012
      If !Empty(cError)

         cError += "Dados da Integração:"+CHR(13)+CHR(10)                                                                              //NCF - 24/05/2017 - Melhoria na mensagem de erro para mostrar
         aEval(Self:aSE5,{|x| cError += x[1] + " = " + If( Valtype(x[2]) <> 'C', cValtochar(x[2]), x[2]) + CHR(13) + CHR(10) })        //                   os dados da integração para rastreamento.

         ::Error("Não foi possível gerar a movimentação bancária referente ao recebimento do financiamento: "+cError)
      ElseIf cOPC $ "RECEBER/PAGAR"
         ::cChaveSE5 := SE5->(&(IndexKey()))
         ::GravaEF3()
      ElseIf cOPC $ "EXCLUIR"
         //FSM - 09/08/2012
         If SE5->(DBSeek(::cChaveSE5)) .And. !(UPPER(SE5->E5_SITUACA) == "C")
            ::Error("Não foi possível cancelar a movimentação bancária referente ao recebimento do financiamento.")
         Else
            ::cChaveSE5 := ""
            ::cNumero := "" //FSM - 24/02/2012
            ::GravaEF3()
         EndIf
      EndIf

   Return Empty(cError)

   /*
      Método..: VerificaLiq()
      Classe..: AvEmprestimo
      Objetivo: Retorna verdadeiro se o empréstimo já estiver liquidado
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method VerificaLiq() Class AvEmprestimo
      Local lRet := .F.
      /*
      If !Empty(::cChaveSE5)
         SEH->(dbSetOrder(1))//EH_FILIAL+EH_NUMERO+EH_REVISAO
         SEH->(dbSeek(xFilial("SEH")+::cChaveSE5))
         lRet := SEH->EH_SALDO == 0
      EndIf
      */
   Return lRet

   Method SetNatureza() Class AvEmprestimo

      If Empty(::cNatureza)
         ::cNatureza := Posicione("EF7",1,xFilial("EF7")+::oIntFin:oContrato:cTpFin,"EF7_NATFIN")
      EndIf

   Return ::cNatureza

   Method GravaEF3() Class AvEmprestimo
      Local nOldEF3

      If ::nRecNoEF3 > 0
         nOldEF3 := EF3->(RecNo())

         EF3->(dbGoTo(::nRecNoEF3))
         lLock := !EF3->(IsLocked())

         If(lLock,RecLock("EF3",.F.),)
         EF3->EF3_TITFIN := ::cChaveSE5
         If(lLock,EF3->(MsUnLock()),)

         EF3->(dbGoTo(nOldEF3))
      EndIf

   Return Nil

//Fim - Métodos AvEmprestimo

/*
  Função..: EX102LPad()
  Objetivo: Efetua a configuração dos campos de um lançamento padrão dependendo de seu parametro.
  Autor...: Felipe Sales Martinez - FSM
  Data....: 13/04/2012
*/
Function EX102LPad(cField)
Local xRet
Local aOrd
Local nOldRec
Local lEst := .F.

If !IsInCallStack("LancPadEF3") //FSM - 20/09/2012
   EF3->(dbGoTo(-1)) //Posiciona no EOF para não contabilizar se não vier da chamada do SIGAEFF.
EndIf

cField := StrTran(Upper(cField), " ", "")

   Do Case

      Case cField == "CTADEBITO" .Or. cField == "CTACREDITO"
           nOldRec := EC6->( RecNo() )
           aOrd := SaveOrd("EC6")

           EC6->(DBSetOrder(1))
           If (lEst := EC6->EC6_ID_CAM == "999")
              EC6->( DBSeek( xFilial("EC6")+"FIEX"+EF1->EF1_TP_FIN+EF3->EF3_EV_EST ) )
           EndIf

           If Upper(AllTrim(cField)) == "CTADEBITO"
              xRet := Ex102MascBanc( If( lEst .And. !Empty(EC6->EC6_CDBEST), EC6->EC6_CDBEST, EC6->EC6_CTA_DB ) )
           Else
              xRet := Ex102MascBanc( If( lEst .And. !Empty(EC6->EC6_CCREST), EC6->EC6_CCREST,  EC6->EC6_CTA_CR ) )
           EndIf

           EC6->(DBGoTo(nOldRec))
           RestOrd(aOrd)

      Case cField == "HISTORICO"
           xRet := AllTrim(EF1->EF1_CONTRA) + " - " + EC6->EC6_DESC

      Case cField == "VLRMOEDA1"
           xRet := Abs(EF3->EF3_VL_REA) //FSM -22/08/2012

      Case cField == "VLRMOEDA2"
           xRet := Abs(EF3->EF3_VL_MOE) //FSM -22/08/2012

      Case cField == "DESCRICAO"
           xRet := EC6->EC6_DESC

      OtherWise
           MsgInfo("Parâmetro passado incorretamente na função 'EX102LPad'. Verifique a documentação de integração dos modulos SIGAEFF X SIGAFIN X SIGACTB para configuração do Lançamento Padrão.","Atenção")
           xRet := &(cField)

   EndCase

Return xRet

/*
  Função..: Ex102MascBanc()
  Objetivo: Efetua a interpretação das mascaras para o campo de conta de debito e credito do LP.
  Autor...: Felipe Sales Martinez - FSM
  Data....: 16/04/2012
  Obs.....: As tabelas EC6, EF1 e EF3 devem estar posicionadas
*/
Static Function Ex102MascBanc(cConta)
Local cRet := cConta, cChave := ""
Local nTam := Len(EC6->EC6_CTA_CR)
Local aOrd := {}
Local lMultiFil  := VerSenha(115) .and. Posicione("SX2",1,"EF1","X2_MODO") == "C" .and. Posicione("SX2",1,"EEQ","X2_MODO") == "E" .AND. SX3->(DbSeek("EF3_FILORI"))

cConta := AllTrim(cConta)

Begin Sequence


     Do Case

        //Tipo Fornecedores
        Case cConta == Replicate("9",nTam)

             aOrd := SaveOrd({"SY5", "SA2"})
             //FSM - 24/08/2012
             SA2->(dbSetOrder(1))
             SA2->(dbSeek(xFilial("SA2")+EF1->EF1_EXPORT+EF1->EF1_LOJA))
             cRet := AllTrim(SA2->A2_CONTAB)

        //Tipo Cliente
        Case cConta == Replicate("8",nTam)
             aOrd := SaveOrd({"EEQ", "EEC", "SA1" })
             //FSM - 24/08/2012
             EEC->(DbSetOrder(1)) //EEC_FILIAL+EEC_PREEMB
             //EEC->(dbSeek(xFilial("EEC") + EF3->EF3_PREEMB))
			 EEC->(dbSeek(If(lMultiFil,EF3->EF3_FILORI,xFilial("EEC")) + EF3->EF3_PREEMB))

             SA1->(dbSetOrder(1))
             SA1->(dbSeek(xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA) )

             cRet := AllTrim(SA1->(&(EasyGParam("MV_EFF0007",,"A1_CONTAB")))) //FSM - 20/09/2012

        //Tipo Banco
        Case SubStr(cConta,1,nTam-1) == Replicate("7",nTam-1)
             aOrd := SaveOrd({"EEQ", "SA6", "ECI" })
             //FSM - 24/08/2012
             //EEQ->(DbSetOrder(1)) //EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
             //EEQ->(DbSeek( xFilial("EEQ") + EF3->EF3_PREEMB + EF3->EF3_PARC ))

             //If EF1->EF1_TP_FIN $ "01/02/03" //ACC/ACE/PRE //FSM - 24/08/2012
                If !Empty(EF3->EF3_BANC)
                   cChave := "EF3->EF3_BANC+EF3->EF3_AGEN+EF3->EF3_NCON"
                ElseIf !Empty(EF1->EF1_BAN_MO)
                   cChave := "EF1->EF1_BAN_MO+EF1->EF1_AGENMO+EF1->EF1_NCONMO"
                Else
                   cChave := "EF1->EF1_BAN_FI+EF1->EF1_AGENFI+EF1->EF1_NCONFI"
                EndIf
             //Else
             //   cChave := "EEQ->EEQ_BANC+EEQ->EEQ_AGEN+EEQ->EEQ_NCON"      //FSM - 24/08/2012
             //EndIf

             If Right(cConta,1) = "0"
                SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
                SA6->(DbSeek( xFilial("SA6") + &(cChave) )) //FSM - 24/08/2012
                cRet := Alltrim(SA6->A6_CONTABI)

             Else
                ECI->(DBSETORDER(2)) //ECI_FILIAL+ECI_BANCOD+ECI_AGENCI+ECI_NUMCON+ECI_TPMODU+ECI_TPCONT
                If ECI->(DbSeek( xFilial("ECI") + &(cChave) + "FIEX" + If(EF1->EF1_TP_FIN == "01","01","02") + Right(cConta,1)))
                   cRet := AllTrim(ECI->ECI_CONTAB)
                Else //FSM - 24/08/2012
                   cRet := Space(nTam) //AAF 21/08/2012 - Se não tiver conta cadastrada, retorna branco. Não pode retornar a mascara.
                EndIf

             EndIf

     End Case

End Sequence

If Len(aOrd) > 0
   RestOrd(aOrd)
EndIf

Return cRet

/*
  Função..: EX102DtTela()
  Objetivo: Exibe tela para o preenchimento da taxa do dia.
  Autor...: Felipe Sales Martinez - FSM
  Data....: 26/04/2012
  Obs.....:
*/
Static Function EX102DtTela(dDtProc)
Local nLinha := 10
Local bOk := {|| If(EX102GatVal(), oDlg:End(), Nil) }, bCancel := {|| EX102GatVal(.T.) }
Local oPanel

Private cCotacao  := Space(30), dDtCot := dDtProc
Private oDlg

DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 200,400 PIXEL STYLE DS_MODALFRAME //"Data Base da Cotação da Moeda"
  
  oDlg:lEscClose := .F. //desabilita fechar a janela ao pressinar esc.

  oPanel:= tPanel():New(01,01,"",oDlg,,,,,,100,100)
  oPanel:Align := CONTROL_ALIGN_ALLCLIENT

  @ nLinha,012  Say STR0004 Size 070,08 Pixel Of oPanel //"Data Cotação:"
  @ nLinha,050  MSGET dDtCot        SIZE 50,10 PICTURE "@D" Of oPanel PIXEL HASBUTTON


ACTIVATE MSDIALOG oDlg ON INIT( EnchoiceBar(oDlg,bOk,bCancel,,,,,,,.F.,.T.), )CENTERED

Return dDtCot

/*
  Função..: EX102GatVal()
  Objetivo: Preencher o campo de data da cotação da moeda.
  Autor...: Felipe Sales Martinez - FSM
  Data....: 26/04/2012
  Obs.....: A tabela SYE deve estar posicionada
*/
Static Function EX102GatVal(lForca)
Local lRet := .T.
Default lForca := .F.

If Empty(dDtCot)
   MsgInfo(STR0002,STR0001)//"Informe a data base da cotação da moeda."###"Atenção"
   lRet := .F.
EndIf

If lRet .And. lForca
   MsgInfo(STR0003,STR0001)//"O Processo de Apropriação está em execução, não é possível cancelar a operação."###"Atenção"
   lRet := .F.
EndIf

Return lRet

