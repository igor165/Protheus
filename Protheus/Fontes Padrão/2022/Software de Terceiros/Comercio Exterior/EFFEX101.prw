#INCLUDE "AVERAGE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "TOPCONN.CH"
/*
Programa        : EFFEX101.PRW
Objetivo        : Financiamento de Comércio Exterior - Contrato de Financiamento
Autor           : Alessandro Alves Ferreira
Data/Hora       : 10/11/2009
*/
*-----------------*
Function EFFEX101()
*-----------------*
Return Nil

/*
Classe..: AvEFFContra
Objetivo: Representar contratos de financiamento de comercio exterior
Autor...: Alessandro Alves Ferreira
Data....: 10/11/2009
*/
Class AvEFFContra of AvObject

   //Integração Microsiga
   Data oIntFin

   //Contrato
   Data cTpModu
   Data cContrato
   Data cBanco
   Data cAgencia
   Data cConta
   Data cPraca
   Data cSeqCnt

   Data cForn
   Data cLoja

   //Parâmetros do contrato
   Data cTpFin
   Data cTpFinDesc
   Data lImportacao
   Data lParcelas
   Data lPorPeriodo
   Data lJurosAnt

   //Datas
   Data dContrato
   Data dVencimento
   Data dIniJur
   Data dEncerra
   Data dUltAprop

   //Valores
   Data cMoeda
   Data nVlContra

   //Saldo
   Data nSaldo
   Data nSaldoACE
   Data nAmortizado
   Data nSaldoRS
   Data nSaldoACERS
   Data nAmortizadoRS
   Data nJuros
   Data nJurosACE
   Data nJurLiq
   Data nJurosRS
   Data nJurosACERS
   Data nJurLiqRS

   //Chave do contrato
   Data cChaveEF1
   Data nRecEF1

   //Períodos de Juros
   Data aTpJuros
   Data aPeriodos

   //Invoices Vinculadas
   Data aInvVinc

   //Juros ACC já calculados
   Data aJurosACC
   
   Data nTaxa //AAF 22/08/2017

   //Construtores
   Method New(cTpModu,cContrato,cBanco,cPraca,cSeqCnt) Constructor
   Method LoadEF1() Constructor

   //Calulo de Juros
   Method CalcJuros()
   Method CalcPrincipal()
   Method CalcPeriodos()
   Method GetTpJuros()

   //Tratamento de eventos financeiros
   Method EventoEF3(cOperacao)
   Method EventoFinanceiro(cEvento)
   Method GrvEventoEstorno()

   //Atualização dos Saldos
   Method AtualizaSaldos()

   //Carregar Invoices Vinculadas
   Method LoadInvs()
   Method LoadJurACC()

   //Apropriacao de Juros e Variacao Cambial (p/ contabilizacao)
   Method ValApropJuros()
   Method ApropriaJurosVC()
   Method ValorRS()
   Method TaxaRS()

   Method ValidaCampo()

   //Integracoes
   Method CallEasyLink()
EndClass

   /*
      Método..: New()
      Classe..: AvTitulo
      Objetivo: Construtor da classe AvTitulo
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method New() Class AvEFFContra
      _Super:New()
      ::setClassName("AvEFFContra")

      //Integracao Microsiga
      ::oIntFin   := AvEFF_FIN():New(@Self)

      //Contrato
      ::cTpModu   := ""
      ::cContrato := ""
      ::cBanco    := ""
      ::cAgencia  := ""
      ::cConta    := ""
      ::cPraca    := ""
      ::cSeqCnt   := ""
      ::cForn     := ""
      ::cLoja     := ""

      //Parâmetros do contrato
      ::cTpFin      := ""
      ::cTpFinDesc  := ""
      ::lImportacao := .F.
      ::lParcelas   := .F.
      ::lPorPeriodo := .F.
      ::lJurosAnt   := .F.

      //Datas
      ::dContrato   := CToD("  /  /  ")
      ::dVencimento := CToD("  /  /  ")
      ::dIniJur     := CToD("  /  /  ")
      ::dEncerra    := CToD("  /  /  ")
      ::dUltAprop   := CToD("  /  /  ")

      //Valores
      ::nVlContra     := 0
      ::nSaldo        := 0
      ::nSaldoACE     := 0
      ::nAmortizado   := 0
      ::nSaldoRS      := 0
      ::nSaldoACERS   := 0
      ::nAmortizadoRS := 0
      ::nJuros        := 0
      ::nJurosACE     := 0
      ::nJurLiq       := 0
      ::nJurosRS      := 0
      ::nJurosACERS   := 0
      ::nJurLiqRS     := 0
      ::nRecEF1       := 0
      ::cChaveEF1     := ""
      ::nTaxa         := 0 //AAF 22/08/2017
	  
      ::aTpJuros  := {}
      ::aInvVinc  := {}
      ::aJurosACC := {}

   Return Self
   /*
      Método..: LoadEF1()
      Classe..: AvTitulo
      Objetivo: Construtor da classe AvEFFContra com base no contrato de financiamento (EF1).
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method LoadEF1(cTpModu,cContrato,cBanco,cPraca,cSeqCnt) Class AvEFFContra
      Local aPosEF3
	  
	  ::New()

      If ::ValidaParam(@cTpModu,"C","") .AND. Len(cTpModu) == Len(EF1->(EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT))
         EF1->(dbSetOrder(1))//EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT
         EF1->(dbSeek(cTpModu))

      ElseIf ::ValidaParam(@cTpModu,"C","") .AND. ::ValidaParam(@cContrato,"C","") .AND. ::ValidaParam(@cBanco,"C","") .AND.;
             ::ValidaParam(@cPraca,"C","") .AND. ::ValidaParam(@cSeqCnt,"C","")

         If !Empty(cTpModu) .AND. !Empty(cContrato) .AND. !Empty(cBanco) .AND. !Empty(cPraca) .AND. !Empty(cSeqCnt)
            EF1->(dbSetOrder(1))//EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT
            EF1->(dbSeek(xFilial("EF1")+cTpModu+cContrato+cBanco+cPraca+cSeqCnt))
         EndIf

      EndIf

      If EF1->(Eof())
         ::Error("Contrato de financiamento indeterminado.")
      Else

         //Contrato
         ::cTpModu     := EF1->EF1_TPMODU
         ::cContrato   := EF1->EF1_CONTRA
         ::cBanco      := EF1->EF1_BAN_FI
         ::cAgencia    := EF1->EF1_AGENFI
         ::cConta      := EF1->EF1_NCONFI
         ::cPraca      := EF1->EF1_PRACA
         ::cSeqCnt     := EF1->EF1_SEQCNT

         SA6->(dbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
         SA6->(dbSeek(xFilial("SA6")+::cBanco+if(!Empty(::cAgencia),::cAgencia+if(!Empty(::cConta),::cConta,""),"")))

         ::cForn       := SA6->A6_CODFOR
         ::cLoja       := SA6->A6_LOJFOR

         //Parâmetros do contrato
         ::cTpFin      := EF1->EF1_TP_FIN
         ::cTpFinDesc  := Posicione("EF7",1,xFilial("EF7")+::cTpFin,"EF7_DESCRI")
         ::lImportacao := EF1->EF1_TPMODU == "I"
         ::lParcelas   := EF1->EF1_CAMTRA == "1"
         ::lPorPeriodo := EF1->EF1_LIQPER == "1"
         ::lJurosAnt   := EF1->EF1_JR_ANT == "1"

         //Datas
         ::dContrato   := EF1->EF1_DT_CON
         ::dVencimento := EF1->EF1_DT_VEN
         ::dIniJur     := EF1->EF1_DT_JUR
         ::dEncerra    := EF1->EF1_DT_ENC
         ::dUltAprop   := EF1->EF1_DT_CTB

         //Valores
         ::cMoeda        := EF1->EF1_MOEDA
         ::nVlContra     := EF1->EF1_VL_MOE

         ::nSaldo        := 0
         ::nSaldoACE     := 0
         ::nAmortizado   := 0
         ::nSaldoRS      := 0
         ::nSaldoACERS   := 0
         ::nAmortizadoRS := 0
         ::nJuros        := 0
         ::nJurosACE     := 0
         ::nJurLiq       := 0
         ::nJurosRS      := 0
         ::nJurosACERS   := 0
         ::nJurLiqRS     := 0

         //Chave do contrato
         ::cChaveEF1 := xFilial("EF1")+::cTpModu+::cContrato+::cBanco+::cPraca+::cSeqCnt
         ::nRecEF1   := EF1->(RecNo())

         ::aTpJuros  := ::GetTpJuros()
         ::aInvVinc  := ::LoadInvs()
         ::aJurosACC := ::LoadJurACC()
		 
		 //AAF 22/08/2017
		 aPosEF3 := EF3->({IndexOrd(),RecNo()})
		 EF3->(dbSetOrder(1))
		 EF3->(dbSeek(::cChaveEF1+"100"))
		   
		 If !Empty(EF3->EF3_TX_MOE)
		    ::nTaxa := EF3->EF3_TX_MOE
		 EndIf
		   
		 EF3->(dbSetOrder(aPosEF3[1]),dbGoTo(aPosEF3[2]))
      EndIf

   Return Self

   Method EventoEF3(cOperacao,lMudouDtIni,lDtIniNaoVazio) Class AvEFFContra
      Local lDesabIntg := .F.
      Local aOrdEC6 := SaveOrd('EC6')
	  Local lSemLiquidar := .T. //Indica se integra titulo sem liquidação.
      Local lOk := .T. //NCF - 06/04/2017 - adição da variável para flag do controle de transações
      Static lLiquidado := .F. //FSM - 24/08/2012
	  Static lEstLiq    := .F.
	  Default lMudouDtIni    := .F.
      Default lDtIniNaoVazio := .F.

      If /*AvFlags("EEC_LOGIX") .AND.*/ EF3->(!EoF())                             //NCF - 24/06/2015 - Liberação do tratamento para outras integrações
         EC6->(DbSetOrder(1))
         EC6->(dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. EF1->EF1_TPMODU <> "I","FIEX","FIIM")+EF1->EF1_TP_FIN+EF3->EF3_CODEVE))
         lDesabIntg   := EC6->(FieldPos("EC6_DESINT")) > 0 .And. EC6->EC6_DESINT == '1'
		 lSemLiquidar := EC6->(FieldPos("EC6_DESINT")) == 0 .OR. !EC6->EC6_DESINT == '2'
         RestOrd(aOrdEC6,.T.)
      EndIf

      If cOperacao $ "ESTORNO/ALTERACAO/INCLUSAO" .AND. EF3->(!EoF()) .and. !lDesabIntg

         If cOperacao == "ESTORNO"
            ::GrvEventoEstorno()
         EndIf

         If EF3->EF3_CODEVE == "100"
            If lMudouDtIni .AND. lDtIniNaoVazio
               lOk := ::EventoFinanceiro("ESTORNO_CONTRATO")
            EndIf

            If !Empty(EF1->EF1_DT_JUR) .And. Empty(EF3->EF3_NR_CON) // NCF - 06/11/2018 - Não integrar alteração de contrato quando estiver contabilizado o evento 100.
               lOk := ::EventoFinanceiro(cOperacao+"_CONTRATO")
            EndIf

         ElseIf Left(EF3->EF3_CODEVE,1) $ "3/4"

			If lEstLiq
			   lOk := ::EventoFinanceiro("ESTORNO_LIQUIDACAO_ENCARGOS")
			EndIf

			If lSemLiquidar .OR. !cOperacao $ "ALTERACAO/INCLUSAO" .OR. lLiquidado //AAF 30/01/2015 - Permitir parametrizar integração de titulo apenas na liquidação
               lOk := ::EventoFinanceiro(cOperacao+"_ENCARGOS")
			ElseIf !lSemLiquidar .AND. lEstLiq
			   lOk := ::EventoFinanceiro("ESTORNO_ENCARGOS")
			EndIf

			If lLiquidado
			   If cOperacao $ "ALTERACAO/INCLUSAO"
			      Private lLiqJurEF3Auto := .T.
			   EndIf
			   lOk := ::EventoFinanceiro("LIQUIDACAO_ENCARGOS")
			EndIf

         ElseIf EF3->EF3_CODEVE == "600" // .OR. Left(EF3->EF3_CODEVE,2) == "65")// .AND. cOperacao <> "ALTERACAO" - FSM - 24/02/2012
            lOk := ::EventoFinanceiro(cOperacao+"_VINCULACAO_INVOICE")

         ElseIf Left(EF3->EF3_CODEVE,2) == "65" //FSM - 24/02/2012
            lOk := ::EventoFinanceiro(cOperacao+"_VINCULACAO_JUROS")

         ElseIf EF3->EF3_CODEVE == "630" //.Or. Left(EF3->EF3_CODEVE,2) == "64" .AND. cOperacao <> "ALTERACAO" - FSM - 24/02/2012
            lOk := ::EventoFinanceiro(cOperacao+"_LIQUIDACAO_INVOICE")

         ElseIf Left(EF3->EF3_CODEVE,2) $ "62/64/67/71" //AAF 18/07/2015 - Adicionado juros de PPE
            //NCF - 04/04/2014
			If lEstLiq
			   lOk := ::EventoFinanceiro('ESTORNO_LIQUIDACAO_PARCELA_JUROS')
			EndIf

			If lSemLiquidar .OR. !cOperacao $ "ALTERACAO/INCLUSAO" .OR. lLiquidado //AAF 30/01/2015 - Permitir parametrizar integração de titulo apenas na liquidação
               lOk := ::EventoFinanceiro(cOperacao+"_PARCELA_JUROS")
			ElseIf !lSemLiquidar .AND. lEstLiq
			   lOk := ::EventoFinanceiro("ESTORNO_PARCELA_JUROS")
			EndIf

			If lLiquidado
			   If cOperacao $ "ALTERACAO/INCLUSAO"
			      Private lLiqJurEF3Auto := .T.
			   EndIf
			   lOk := ::EventoFinanceiro('LIQUIDACAO_PARCELA_JUROS')
			EndIf

         ElseIf EF3->EF3_CODEVE $ "700/660" .AND. ( !Empty(::dIniJur) .OR. cOperacao == "ESTORNO" )
			If lEstLiq
			   lOk := ::EventoFinanceiro("ESTORNO_PARCELA_PRINCIPAL")
			EndIf

            If lSemLiquidar .OR. !cOperacao $ "ALTERACAO/INCLUSAO" .OR. lLiquidado //AAF 30/01/2015 - Permitir parametrizar integração de titulo apenas na liquidação
			   lOk := ::EventoFinanceiro(cOperacao+"_PARCELA_PRINCIPAL")
			ElseIf !lSemLiquidar .AND. lEstLiq
			   lOk := ::EventoFinanceiro("ESTORNO_PARCELA_PRINCIPAL")
			EndIf

			If lLiquidado
			   If cOperacao $ "ALTERACAO/INCLUSAO"
			      Private lLiqJurEF3Auto := .T.
			   EndIf
			   lOk := ::EventoFinanceiro("LIQUIDACAO_PARCELA_PRINCIPAL")
			EndIf

         ElseIf Left(EF3->EF3_CODEVE,2) == "71" .AND. ( !Empty(::dIniJur) .OR. cOperacao == "ESTORNO" )

			If lEstLiq
			   lOk := ::EventoFinanceiro("ESTORNO_PARCELA_JUROS")
			EndIf

			If lSemLiquidar .OR. !cOperacao $ "ALTERACAO/INCLUSAO" .OR. lLiquidado //AAF 30/01/2015 - Permitir parametrizar integração de titulo apenas na liquidação
               lOk := ::EventoFinanceiro(cOperacao+"_PARCELA_JUROS")
			ElseIf !lSemLiquidar .AND. lEstLiq
			   lOk := ::EventoFinanceiro("ESTORNO_PARCELA_JUROS")
            EndIf

			If lLiquidado
			   lOk := ::EventoFinanceiro("LIQUIDACAO_PARCELA_JUROS")
			EndIf
         //NCF - 04/12/2014
         ElseIf Left(EF3->EF3_CODEVE,2) $ "18/19" .And. lGerTitEvEnc

            If lEstLiq
               lOk := ::EventoFinanceiro('ESTORNO_LIQUIDACAO_ENCERRAMENTO_CONTRATO')
            EndIf

			If lSemLiquidar .OR. !cOperacao $ "ALTERACAO/INCLUSAO" .OR. lLiquidado //AAF 30/01/2015 - Permitir parametrizar integração de titulo apenas na liquidação
               lOk := ::EventoFinanceiro(cOperacao+"_ENCERRAMENTO_CONTRATO")
			ElseIf !lSemLiquidar .AND. lEstLiq
			   lOk := ::EventoFinanceiro("ESTORNO_ENCERRAMENTO_CONTRATO")
            EndIf

            If lLiquidado
            	 If cOperacao $ "ALTERACAO/INCLUSAO"
			        Private lLiqJurEF3Auto := .T.
			     EndIf
               lOk := ::EventoFinanceiro('LIQUIDACAO_ENCERRAMENTO_CONTRATO')
            EndIf

         EndIf

		 lLiquidado := .F.
		 lEstLiq    := .F.
      ElseIf cOperacao == "ESTORNO_LIQUIDACAO" //.AND. EF3->(!EoF()) - NOPADO POR AOM 03/02/2012 - testar integracao com Protheus
	     lEstLiq    := .T.
      ElseIf cOperacao == "LIQUIDACAO" //.AND. EF3->(!EoF()) - NOPADO POR AOM 03/02/2012 - testar integracao com Protheus
         lLiquidado := .T.
      EndIf
      //**

   Return lOk //Nil

   /*
      Método..: EventoFinanceiro()
      Classe..: AvEFFContra
      Objetivo: Evento financeiro no contrato de financiamento
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method EventoFinanceiro(cEvento) Class AvEFFContra
      Local lOk := .T. // lOk := .F. // BAK - Tratamento para integrado com o financeiro ou o logix

      If ::oIntFin:lAtivo
         lOk := ::oIntFin:EventoFinanceiro(cEvento)
      EndIf

      If !lOk
         ::Error(::oIntFin:aError)
      EndIf
	  lOk := lOk .AND. If( !AvFlags("EEC_LOGIX") .Or. "_CONTRATO" $ cEvento .OR. EX400EF3Alt(4,cEvento) , Self:CallEasyLink(cEvento) , .T. )  //NCF - 30/01/2019 - Só chamar integração casa haja integ. EAI ativa e o registro tiver sofrido alteração em campos integrados.

   Return lOk

   Method GrvEventoEstorno() Class AvEFFContra

      If EF3->EF3_VL_REA <> 0 .AND. (!Empty(EF3->EF3_NR_CON) .AND. EF3->EF3_CODEVE <> "999" .OR. EF3->EF3_CODEVE == "999" .AND. Empty(EF3->EF3_NR_CON))
         ECE->(RecLock("ECE",.T.))
         ECE->ECE_FILIAL := EF3->EF3_FILIAL
         ECE->ECE_TPMODU := "FI"+if(::cTpModu == "I","IM","EX")+::cTpFin
         ECE->ECE_CONTRA := EF3->EF3_CONTRA
         ECE->ECE_BANCO  := EF3->EF3_BAN_FI
         ECE->ECE_PRACA  := EF3->EF3_PRACA
         ECE->ECE_SEQCNT := EF3->EF3_SEQCNT
         ECE->ECE_TP_EVE := EF3->EF3_TP_EVE
         ECE->ECE_PREEMB := EF3->EF3_PREEMB
         ECE->ECE_INVEXP := EF3->EF3_INVOIC
         ECE->ECE_ID_CAM := "999"
         If EF3->EF3_CODEVE == "999"
            ECE->ECE_LINK   := EF3->EF3_EV_EST
         Else
            ECE->ECE_LINK   := EF3->EF3_CODEVE
         EndIf
         ECE->ECE_NR_CON := ""
         ECE->ECE_DT_EST := dDataBase
   	     ECE->ECE_VALOR  := EF3->EF3_VL_REA
      	 ECE->ECE_VL_MOE := EF3->EF3_VL_MOE
         ECE->ECE_MOE_FO := EF3->EF3_MOE_IN
         ECE->ECE_SEQ    := EF3->EF3_SEQ
         ECE->ECE_FORN   := EF3->EF3_FORN
         ECE->ECE_DT_LAN := EF3->EF3_DT_EVE
         ECE->(MSUnlock())
      EndIf

   Return Nil

   /*
      Método..: GetTpJuros()
      Classe..: AvEFFContra
      Objetivo: Setar os tipos de juros utilizados no contrato
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method GetTpJuros() Class AvEFFContra
      Local aTpJur := {}
      Local nPosJur

      EF2->(dbSetOrder(2))
      EF2->(dbSeek(::cChaveEF1))
      Do While !EF2->(EoF()) .AND. EF2->(EF2_FILIAL+EF2_TPMODU+EF2_CONTRA+EF2_BAN_FI+EF2_PRACA+EF2_SEQCNT) == ::cChaveEF1
         If (nPosJur := aScan(aTpJur,{|X| X == EF2->EF2_TIPJUR})) == 0
            aAdd(aTpJur,EF2->EF2_TIPJUR)
         EndIf
         EF2->(dbSkip())
      EndDo

   Return aClone(aTpJur)

   /*
      Método..: CalcJuros()
      Classe..: AvEFFContra
      Objetivo: Calcula juros para um período, tipo de financiamento, valor de principal ou invoice para um contrato
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   /*
   Considera o EF1 posicionado.
   aInvImp := {cHawb,cPoDI,cInvoice,cForn,cLoja,cLinha}
   aInvExp := {cPreemb,cInvoice,cParc}
   */
   Method CalcJuros(dDtIni,dDtFim,cTpFin,nValPrinc,oInvExp,oInvImp,dBCotMoe) Class AvEFFContra
      Local aJuros    := {}
      Local nValJuros := 0
      Local i, j
      Local aTaxas
      Local cInvoice
      Local aInvImp //FSM - 04/04/12

      Begin Sequence

      If ! (::ValidaParam(@dDtIni,"D") .AND.;
            ::ValidaParam(@dDtFim,"D",dDataBase) .AND.;
            ::ValidaParam(@cTpFin,"C",::cTpFin) .AND.;
            ::ValidaParam(@nValPrinc,"N",0) )
         ::Error("Parametro incorreto para o método CalcJuros")
         Break
      EndIf

      If ValType(oInvExp) == "O" .AND. oInvExp:ClassName() == "AvInvExp"
         cInvoice := xFilial("EEQ")+oInvExp:cChaveInv//aInvExp[2]+aInvExp[3]
      Else
         cInvoice := Space(AvSX3("EF2_FILIAL",AV_TAMANHO)+AvSX3("EF2_INVOIC",AV_TAMANHO)+AvSX3("EF2_PARC",AV_TAMANHO))
      EndIf

      ::GetTpJuros()

      If Len(::aTpJuros) == 0
         ::Warning("Não há juros cadastrados para esse contrato")
         Break
      EndIf

      If Empty(nValPrinc) .AND. !::lParcelas
         //nValPrinc := ::CalcPrincipal(dDtFim,aInvImp,{oInvExp:cPreemb,oInvExp:cInvoice,oInvExp:cParc}) //FSM - 04/04/2102
		 nValPrinc := ::CalcPrincipal(dDtFim,aInvImp,oInvExp)
      EndIf

      /*If nValPrinc == 0
         ::Warning("Não há valor de principal para calculo de juros.")
         Break
      EndIf*/

      For i := 1 To Len(::aTpJuros)
         If ::lParcelas
            //Calculo de juros pré-pagamento / securitizacao / FINIMP
            nValJuros := EX401ProvTot("EF1", "EF3", dDtFim, dDtIni, ::aTpJuros[i])
            //BuscaProvisoes(@nValJuros,.T.)  // GFP - 07/07/2014 - Função que calcula provisões já calculadas
         Else
            //Calculo de juros ACC / ACE
            //aTaxas    := EX400BusTx(EF1->EF1_TP_FIN,dDt,dContab,"EF1","EF2",aTpJur[i],,cFilOri,cInvoice,cParc)
            aTaxas   := EX401PerJur(dDtIni,dDtFim,if(!Empty(cInvoice),oInvExp:dDtEve,),::aTpJuros[i],cInvoice,if(Empty(cInvoice),"01","02"),,.T.)
            If Len(aTaxas) > 0
               aTaxas   := aTaxas[1][2]
            EndIf

            nValJuros := 0
            nDecimais := AvSX3("EF3_VL_MOE",AV_DECIMAL)

            For j := 1 To Len(aTaxas)
               nValJuros += Round(nValPrinc * (aTaxas[j][2] - aTaxas[j][1] + 1) * aTaxas[j][3]/100,nDecimais)
            Next j
         EndIf

         aAdd(aJuros,{::aTpJuros[i],nValJuros,::ValorRS(nValJuros, If(ValType(dBCotMoe)=="D", dBCotMoe, dDtFim) ,"520"),::TaxaRS(If(ValType(dBCotMoe)=="D", dBCotMoe, dDtFim) ,"520")}) //FSM - 08/08/2012 //FSM -22/08/2012
      Next i

      End Sequence

   Return aClone(aJuros)

   /*
      Método..: CalcPrincipal()
      Classe..: AvEFFContra
      Objetivo: Calcula o valor do principal da operação
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method CalcPrincipal(dDtFim,oInvImp,oInvExp) Class AvEFFContra //FSM - 04/04/2012
      Local nValPrinc := 0

      //If ::lImportacao .AND. ValType(aInvImp) == "A" .AND. Len(aInvImp) == 6 //RMD - 17/04/17 - Testar com Type pois a variável não é declarada
      If ::lImportacao .AND. Type("aInvImp") == "A" .AND. Len(aInvImp) == 6

         EF3->(dbSetOrder(7))//EF3_FILIAL+EF3_TPMODU+EF3_HAWB+EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA+EF3_CODEVE
         If EF3->(dbSeek(xFilial("EF3")+::cTpModu+aInvImp[1]+aInvImp[4]+aInvImp[5]+aInvImp[3]+aInvImp[6]+"630")) .OR.;
         EF3->(dbSeek(xFilial("EF3")+::cTpModu+aInvImp[1]+aInvImp[4]+aInvImp[5]+aInvImp[3]+aInvImp[6]+"660"))
            nValPrinc := 0 //Invoice já está liquidada
         ElseIf EF3->(dbSeek(xFilial("EF3")+::cTpModu+aInvImp[1]+aInvImp[4]+aInvImp[5]+aInvImp[3]+aInvImp[6]+"600"))
            nValPrinc := EF3->EF3_VL_MOE
         Else
            SWB->(dbSetOrder(1))//WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA
            If SWB->(dbSeek(xFilial("SWB")+aInvImp[1]+aInvImp[2]+aInvImp[3]+aInvImp[4]+aInvImp[5]+aInvImp[6]))
               If EF1->EF1_MOEDA == SWB->WB_MOEDA
                  nValPrinc := SWB->WB_FOBMOE
               Else
                  EC6->(dbSeek(xFilial("EC6")+"FI"+"IM"+::cTpFin+'100'))
                  nParidade := BuscaTaxa(SWB->WB_MOEDA,dDtFim,,.F.,.T.,,EC6->EC6_TXCV)/BuscaTaxa(::cMoeda,dDtFim,,.F.,.T.,,EC6->EC6_TXCV)

                  If nParidade > 0
                     nValPrinc := Round(EEQ->EEQ_VL*nParidade,AvSX3("EF3_VL_MOE",AV_DECIMAL))
                  Else
                     //Nao foi possível fazer a conversao
                     nValPrinc := 0
                  EndIf
               EndIf

            EndIf
         EndIf

      ElseIf !::lImportacao .AND. ValType(oInvExp) == "O" .AND. oInvExp:ClassName() == "AvInvExp" //FSM - 04/04/2012

         EF3->(dbSetOrder(3))//EF3_FILIAL+EF3_TPMODU+EF3_INVOIC+EF3_PARC+EF3_CODEVE
         If EF3->(dbSeek(xFilial("EF3")+EF1->EF1_TPMODU+oInvExp:cInvoice+oInvExp:cParc+"630")) .OR.;
         EF3->(dbSeek(xFilial("EF3")+EF1->EF1_TPMODU+oInvExp:cInvoice+oInvExp:cParc+"660"))
            nValPrinc := 0 //Invoice já está liquidada
         ElseIf EF3->(dbSeek(xFilial("EF3")+EF1->EF1_TPMODU+oInvExp:cInvoice+oInvExp:cParc+"600"))
            nValPrinc := EF3->EF3_VL_MOE
         Else
            EEQ->(dbSetOrder(1))//EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
            If EEQ->(dbSeek(xFilial("EEQ")+oInvExp:cPreemb+oInvExp:cParc))
               If EF1->EF1_MOEDA == EEQ->EEQ_MOEDA
                  nValPrinc := EEQ->EEQ_VL
               Else
                  EC6->(dbSeek(xFilial("EC6")+"FI"+"EX"+EF1->EF1_TP_FIN+'100'))
                  nParidade := BuscaTaxa(EEQ->EEQ_MOEDA,dDtFim,,.F.,.T.,,EC6->EC6_TXCV)/BuscaTaxa(EF1->EF1_MOEDA,dDtFim,,.F.,.T.,,EC6->EC6_TXCV)

                  If nParidade > 0
                     nValPrinc := Round(EEQ->EEQ_VL*nParidade,AvSX3("EF3_VL_MOE",AV_DECIMAL))
                  Else
                     //Nao foi possível fazer a conversao
                     nValPrinc := 0
                  EndIf
               EndIf
            EndIf
         EndIf
      Else
         //Buscar saldo do contrato
         aSaldos   := EX401Saldo("EF1",EF1->EF1_TPMODU,EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,EF1->EF1_SEQCNT,"EF3",.F.)
         nValPrinc := aSaldos[1] //Saldo do principal ACC em dolar
      EndIf

   Return nValPrinc

   /*
      Método..: AtualizaSaldos()
      Classe..: AvEFFContra
      Objetivo: Atualizar Saldos do Contrato
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method AtualizaSaldos() Class AvEFFContra

      If Select("WORKEF3") > 0 .AND. IsInCallStack("EFFEX500")
         aSaldos := EX401Saldo("M",::cTpModu,::cContrato,::cBanco,::cPraca,::cSeqCnt,"WORKEF3",.F.)
      Else
         EF1->(dbSetOrder(1),dbSeek(::cChaveEF1))
         aSaldos := EX401Saldo("EF1",::cTpModu,::cContrato,::cBanco,::cPraca,::cSeqCnt,"EF3",.F.)
      EndIf

      If Len(aSaldos) > 0
         ::nSaldo      := aSaldos[1] //Saldo do principal ACC em dolar
         ::nSaldoACE   := aSaldos[5] //Saldo do principal ACE em dolar
         ::nAmortizado := aSaldos[9] //Saldo do principal ACC em dolar

         ::nSaldoRS      := aSaldos[02]
         ::nSaldoACERS   := aSaldos[06]
         ::nAmortizadoRS := aSaldos[10]

         ::nJuros        := aSaldos[03]
         ::nJurosACE     := aSaldos[07]
         ::nJurLiq       := aSaldos[11]

         ::nJurosRS      := aSaldos[04]
         ::nJurosACERS   := aSaldos[08]
         ::nJurLiqRS     := aSaldos[12]

      Else
         ::Warning("AtualizaSaldos - Não foi possível atualizar os saldos do contrato!")
      EndIf

   Return nil

   /*
      Método..: ApropriaJurosVC()
      Classe..: AvEFFContra
      Objetivo: Atualizar as provisões de juros e variações cambiais do contrato para a data especificada.
      Autor...: Alessandro Alves Ferreira
   */
   Method ApropriaJurosVC(dData, dBCotMoe) Class AvEFFContra
      Local i, j
      Local cSeqEvent := GetSequencia(::cChaveEF1) // NCF - 09/01/2014 - Eventos gerados por uma mesma ação (Ex: contabilização) devem ter mesma sequencia para possibilitar o estorno em cadeia quando
      Local nOrd, nRecEF3, cSeekEF3
      Local cSeqs      := ""
      Local bCondSch   := {||}
      Local nVlJrTrfAb := 0
      Local nTaxaCt := 0 //MCF - 25/07/2016

	  ::AtualizaSaldos()                           //                    estornado o evento principal que gera esta cadeia de eventos.

	  If !Empty(::dEncerra)// .AND. ::dUltAprop >= ::dEncerra - Nopado por AAF em 21/08/2012 - Não apropriar juros e v.c. em contrato encerrado. //FSM -22/08/2012
         ::Warning("Não é possível apropriar juros. Contrato encerrado.")
		 Return Nil
      EndIf

      aEventosEF3 := {}

      //05/03/14 - Calcula a variação cambial mesmo que não esteja no período de juros
      //Variacao Cambial Principal ACC
      oVCPrACC := AvTitulo():New(Self)
	  If ::lParcelas .AND. ::cTpModu == "I" //AAF 18/07/2015 - Variação cambial do contrato PPE é igual a do ACC/ACE
         aValor := EX400CalcVlr("50",.F.,::nSaldo,::TaxaRS(dData,"500",dBCotMoe))
         oVCPrACC:nValorRS := Round(aValor[1],AvSX3("EF3_VL_REA",AV_DECIMAL)) //Round( ::TaxaRS(dData,"500",dBCotMoe)*::nSaldo,AvSX3("EF3_VL_REA",AV_DECIMAL)) - ::nSaldoRS //FSM -22/08/2012
      Else
         oVCPrACC:nValorRS := Round( ::TaxaRS(dData,"500",dBCotMoe)*::nSaldo,AvSX3("EF3_VL_REA",AV_DECIMAL)) - ::nSaldoRS //FSM -22/08/2012
      EndIf
      oVCPrACC:cEvento  := if(oVCPrACC:nValorRS>=0,"500","501")
      oVCPrACC:cTpEve   := ::cTpFin//If(::lParcelas,::cTpFin,"01") //ACC  //FINIMP  // GFP - 30/06/2014
      oVCPrACC:nTaxa    := ::TaxaRS(dData,"500",dBCotMoe)//BuscaTaxa(::cMoeda,If(ValType(dBCotMoe)=="D", dBCotMoe, dData ),,.F.,.T.) //FSM - 27/04/2012 //FSM -22/08/2012
      oVCPrACC:cSeq     := cSeqEvent //GetSequencia(::cChaveEF1)  //"0001"   // GFP - 07/07/2014
      oVCPrACC:cMoeda   := ::cMoeda

      If oVCPrACC:nValorRS <> 0//oVCPrACC:nTaxa <> Round(::nSaldoRS/::nSaldo,AvSX3("YE_TX_COMP",AV_DECIMAL))
         aAdd(aEventosEF3,oVCPrACC)
      EndIf

      If ::ValApropJuros(dData)
         //Eventos a gerar no EF3
         //aEventosEF3 := {}

         //Calcula total de Juros ACC
         aJrACCAtu := ::CalcJuros(::dIniJur, dData ,::cTpFin,::nSaldo, , ,dBCotMoe) //FSM - 08/08/2012
         //Calcula total de Juros de Transferências ACC para PPE                    //NCF - 23/03/2016
         If !Empty( cSeqs := RetMcr190Seq() )
            bCondSch   := &('{||EF3->EF3_TP_EVE == "01" .And. EF3->EF3_TX_MOE == 0 .And. EF3->EF3_SEQ $ "'+ cSeqs +'"}')
            nVlJrTrfAb := EX401EvSum("670","EF3",Self:cChaveEF1,.T.,bCondSch,,Self:lParcelas)
         Else
            nVlJrTrfAb := 0
         EndIf
         /*05/03/14 -  Calcula a variação cambial mesmo que não esteja no período de juros
         //Variacao Cambial Principal ACC
         oVCPrACC := AvTitulo():New(Self)
         //oVCPrACC:nValorRS := Round( BuscaTaxa(::cMoeda, If(ValType(dBCotMoe)=="D", dBCotMoe, dData ) ,,.F.,.T.)*::nSaldo,AvSX3("EF3_VL_REA",AV_DECIMAL)) - ::nSaldoRS //FSM - 27/04/2012
         oVCPrACC:nValorRS := Round( ::TaxaRS(dData,"500",dBCotMoe)*::nSaldo,AvSX3("EF3_VL_REA",AV_DECIMAL)) - ::nSaldoRS //FSM -22/08/2012
         oVCPrACC:cEvento  := if(oVCPrACC:nValorRS>=0,"500","501")
         oVCPrACC:cTpEve   := "01" //ACC
         oVCPrACC:nTaxa    := ::TaxaRS(dData,"500",dBCotMoe)//BuscaTaxa(::cMoeda,If(ValType(dBCotMoe)=="D", dBCotMoe, dData ),,.F.,.T.) //FSM - 27/04/2012 //FSM -22/08/2012
         oVCPrACC:cSeq     := "0001"
         oVCPrACC:cMoeda   := ::cMoeda
         */

         For i := 1 To Len(aJrACCAtu) //Len(::aTpJuros) - FSM - 04/04/2012
            //Provisao de Juros ACC
            oJrACC := AvTitulo():New(Self)
            oJrACC:nValor   := aJrACCAtu[i][2] - ::aJurosACC[i][2] - If(::lParcelas .AND. ::cTpModu == "E",::nJurLiq,0) //AAF 18/07/2015 - Retira o valor do juros liquidado do total de juros atualizados.
            oJrACC:cEvento  := if(oJrACC:nValor>0,"52","51")+::aTpJuros[i]
            oJrACC:nValor   := Abs(oJrACC:nValor) //FSM -22/08/2012
            oJrACC:nValorRS := ::ValorRS(oJrACC:nValor,dData,oJrACC:cEvento,dBCotMoe) //FSM - 27/04/12
            oJrACC:cTpEve   := ::cTpFin//If(::lParcelas,::cTpFin,"01") //ACC  //FINIMP  // GFP - 30/06/2014
            oJrACC:nTaxa    := ::TaxaRS(dData,oJrACC:cEvento,dBCotMoe)//BuscaTaxa(::cMoeda,If(ValType(dBCotMoe)=="D", dBCotMoe, dData ),,.F.,.T.)//FSM - 27/04/2012 //FSM -22/08/2012
            oJrACC:cSeq     := cSeqEvent //GetSequencia(::cChaveEF1,oVCPrACC:cSeq)  //"0001"   // GFP - 07/07/2014
            oJrACC:cMoeda := ::cMoeda
			If oJrACC:nValor <> 0
               aAdd(aEventosEF3,oJrACC)
			EndIf

            //Variacao cambial de Juros ACC
            oVCJrACC := AvTitulo():New(Self)
            oVCJrACC:nValor   := 0
            oVCJrACC:nValorRS := ::ValorRS((aJrACCAtu[i][2]+nVlJrTrfAb) - If(::lParcelas .AND. ::cTpModu == "E",::nJurLiq,0),dData,oJrACC:cEvento,dBCotMoe) - ::aJurosACC[i][3] - if(Left(oJrACC:cEvento,2)=="52",oJrACC:nValorRS,-oJrACC:nValorRS) //AAF 18/07/2015 - Retira o valor liquidado dos juros na moeda do contrato para atualizar o valor em reais para calculo de VC de juros.
            oVCJrACC:cEvento  := AllTrim(Str(550+if(oVCJrACC:nValorRS>=0,0,1)+Val(::aTpJuros[i])*2))
            oVCJrACC:cTpEve   := ::cTpFin//If(::lParcelas,::cTpFin,"01") //ACC  //FINIMP  // GFP - 30/06/2014
            oVCJrACC:nTaxa    := aJrACCAtu[i][4]//BuscaTaxa(::cMoeda,If(ValType(dBCotMoe)=="D", dBCotMoe, dData ),,.F.,.T.)//FSM - 27/04/2012 //FSM -22/08/2012
            oVCJrACC:cSeq     := cSeqEvent //GetSequencia(oVCJrACC:oEFFContra:cChaveEF1,oJrACC:cSeq)  //"0001"   // GFP - 07/07/2014
            oVCJrACC:cMoeda   := ::cMoeda

            If oVCJrACC:nValorRS <> 0//oJrACC:nTaxa <> Round(::aJurosACC[i][3]/::aJurosACC[i][2],AvSX3("YE_TX_COMP",AV_DECIMAL)) .AND. ::nSaldo > 0
               aAdd(aEventosEF3,oVCJrACC)
            EndIf

			//** AAF 20/01/2014 - Variação cambial de juros antecipado.
            EF3->(nOrd := IndexOrd(),nRecEF3 := RecNo())
            EF3->(dbSetOrder(1))//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE
            cSeekEF3 := ::cChaveEF1+"62"+AllTrim(Str(Val(::aTpJuros[i])))
            If EF3->(dbSeek(cSeekEF3))
               nVal620  := 0
               nVal620R := 0
               /*
               Do While EF3->(!EoF() .AND. Left(&(IndexKey()),Len(cSeekEF3)) == cSeekEF3)
                  nVal620  += EF3->EF3_VL_MOE
                  nVal620R += EF3->EF3_VL_REA
                  EF3->(dbSkip())
               EndDo
			    */
               nVal620  := EX401EvSum("62"+::aTpJuros[i],"EF3",::cChaveEF1,.T.,)
               nVal620R := EX401EvSum("62"+::aTpJuros[i],"EF3",::cChaveEF1,.F.,)

               nVal620R += EX401EvSum(AllTrim(Str(580+Val(::aTpJuros[i])*2)),"EF3",::cChaveEF1,.F.,)
               nVal620R += EX401EvSum(AllTrim(Str(581+Val(::aTpJuros[i])*2)),"EF3",::cChaveEF1,.F.,)

               nVal620  -= EX401EvSum("64"+::aTpJuros[i],"EF3",::cChaveEF1,.T.,{|| EF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0)})
               nVal620R -= EX401EvSum("64"+::aTpJuros[i],"EF3",::cChaveEF1,.F.,{|| EF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0)})

			   //Variacao cambial de juros antecipado.
               oVCJrAnt := AvTitulo():New(Self)
               oVCJrAnt:nValor   := 0
               oVCJrAnt:nValorRS := nVal620 * ::TaxaRS(dData,"58"+::aTpJuros[i],dBCotMoe) - nVal620R
               oVCJrAnt:cEvento  := AllTrim(Str(580+if(oVCJrAnt:nValorRS>=0,0,1)+Val(::aTpJuros[i])*2))
               oVCJrAnt:cTpEve   := ::cTpFin
               oVCJrAnt:nTaxa    := ::TaxaRS(dData,"58"+::aTpJuros[i],dBCotMoe)
               oVCJrAnt:cSeq     := cSeqEvent
               oVCJrAnt:cMoeda   := ::cMoeda

               If oVCJrAnt:nValorRS <> 0
                  aAdd(aEventosEF3,oVCJrAnt)
               EndIf
            EndIf
            EF3->(dbSetOrder(nOrd),dbGoTo(nRecEF3))
			//**
         Next i
      EndIf

	  If !::lParcelas                                                                                               //NCF - 24/06/2015 - Não buscar invoices para contratos parcelados
         aInvVincAtu := {}
         For i := 1 To Len(::aInvVinc)
            aAdd(aInvVincAtu,::aInvVinc[i]:clone())

            dDataFim := dData
            //**FSY - 19/06/2013 Chamado THAXDV
            If Val(EasyGParam("MV_EFF0008",,"1")) == 2
               EEQ->(dbSetOrder(4))
               EEQ->(dbSeek(xFilial("EEQ")+aInvVinc[i]:cInvoice+aInvVinc[i]:cPreemb+aInvVinc[i]:cParc))
               If !Empty(EEQ->EEQ_DTCE)
                  dDataFim := EEQ->EEQ_DTCE
               EndIf
            EndIf
            //**

   	        //If aInvVincAtu[i]:lLiquidado
               //AAF 21/08/2012 - Não se deve calcular mais provisões de juros e variações cambiais sobre invoice liquidada.
               //dDataFim := aInvVincAtu[i]:dDataLiq
               //LOOP
            //EndIf

            //Calcula valores atualizados de principal e juros ACE
            aInvVincAtu[i]:nSaldoRS := ::ValorRS(aInvVincAtu[i]:nSaldo,dData,"600",dBCotMoe) //FSY - 19/06/2013 Chamado THAXDV FSM - 27/04/12

		    If ::ValApropJuros(dData)
		       //aInvVincAtu[i]:aJuros   := ::CalcJuros(::dIniJur,dDataFim,::cTpFin,aInvVincAtu[i]:nValor,{aInvVincAtu[i]:cPreemb,aInvVincAtu[i]:cInvoice,aInvVincAtu[i]:cParc})
               If !aInvVincAtu[i]:lLiquidado
                  aInvVincAtu[i]:aJuros   := ::CalcJuros(::dIniJur,dDataFim,::cTpFin,aInvVincAtu[i]:nValor,aInvVincAtu[i],,dBCotMoe) //FSM -22/08/2012
               Else
                  aInvVincAtu[i]:aJuros := aClone(::aInvVinc[i]:aJuros)
                  For j := 1 to Len(::aTpJuros)
                     aInvVincAtu[i]:aJuros[j][3] := ::ValorRS(aInvVincAtu[i]:aJuros[j][2],dData,"520",dBCotMoe)
                     If Len(aInvVincAtu[i]:aJuros[j]) < 4
                        aAdd(aInvVincAtu[i]:aJuros[j],NIL)
                     EndIf
                     aInvVincAtu[i]:aJuros[j][4] := ::TaxaRS(dData,"520",dBCotMoe)
                  Next
               EndIf
            EndIf

            //Variacao cambial ACE
            oVCPrACE            := AvTitulo():New(Self)
            oVCPrACE:nValor     := 0
            oVCPrACE:nValorRS   := aInvVincAtu[i]:nSaldoRS - ::aInvVinc[i]:nSaldoRS
            oVCPrACE:cEvento    := if(oVCPrACE:nValorRS>=0,"500","501")
            oVCPrACE:cTpEve     := If(::lParcelas,::cTpFin,"02") //ACE  //FINIMP  // GFP - 30/06/2014
            oVCPrACE:nTaxa      := ::TaxaRS(dData,"600",dBCotMoe)//BuscaTaxa(::cMoeda,If(ValType(dBCotMoe)=="D", dBCotMoe, dDataFim ),,.F.,.T.)//FSY 19/06/2013 Chamado THAXDV / FSM - 27/04/2012 //FSM -22/08/2012
            oVCPrACE:cSeq       := cSeqEvent //aInvVincAtu[i]:cSeq   //NCF - 16/01/2015 - A sequencia tem de ser a do fechamento se não os eventos de vinculação podem ser excluidos juntos a eventos gerados pela
            oVCPrACE:cInvoice   := aInvVincAtu[i]:cInvoice           //                   contabilização que poderaão ser futuramente estornados se o ERP Externo rejeitar a contabilização
            oVCPrACE:cPreemb    := aInvVincAtu[i]:cPreemb
            oVCPrACE:cParc      := aInvVincAtu[i]:cParc
            oVCPrACE:cMoeda     := aInvVincAtu[i]:cMoeda

            If oVCPrACE:nValorRS <> 0 //oVCPrACE:nTaxa <> Round(::aInvVinc[i]:nValorRS/::aInvVinc[i]:nValor,AvSX3("YE_TX_COMP",AV_DECIMAL))
               aAdd(aEventosEF3,oVCPrACE)
            EndIf

            If ::ValApropJuros(dData)
               For j := 1 To Len(::aTpJuros)
                  //Provisao de Juros ACE
                  oJurACE            := AvTitulo():New(Self)
                  oJurACE:nValor     := aInvVincAtu[i]:aJuros[j][2] - ::aInvVinc[i]:aJuros[j][2]
                  oJurACE:cEvento    := if(oJurACE:nValor>0,"52","51")+::aTpJuros[j]
                  oJurACE:nValor     := Abs(oJurACE:nValor) //FSM -22/08/2012
                  oJurACE:nValorRS   := ::ValorRS(oJurACE:nValor,dData,oJurACE:cEvento,dBCotMoe) //FSY 19/06/2013 Chamado THAXDV / FSM - 27/04/12
                  oJurACE:cTpEve     := If(::lParcelas,::cTpFin,"02") //ACE  //FINIMP  // GFP - 30/06/2014
                  oJurACE:nTaxa      := ::TaxaRS(dData,oJurACE:cEvento,dBCotMoe)//BuscaTaxa(::cMoeda,If(ValType(dBCotMoe)=="D", dBCotMoe, dDataFim ),,.F.,.T.) //FSY 19/06/2013 Chamado THAXDV  FSM - 27/04/2012 //FSM -22/08/2012
                  oJurACE:cSeq       := cSeqEvent //aInvVincAtu[i]:cSeq   //NCF - 16/01/2015
                  oJurACE:cInvoice   := aInvVincAtu[i]:cInvoice
                  oJurACE:cPreemb    := aInvVincAtu[i]:cPreemb
                  oJurACE:cParc      := aInvVincAtu[i]:cParc
                  oJurACE:cMoeda     := aInvVincAtu[i]:cMoeda

				  If oJurACE:nValor <> 0
				     aAdd(aEventosEF3,oJurACE)
                  EndIf

                  //Variacao cambial de juros ACE
                  oVCJurACE          := AvTitulo():New(Self)
                  oVCJurACE:nValor   := 0
                  oVCJurACE:nValorRS := aInvVincAtu[i]:aJuros[j][3] - ::aInvVinc[i]:aJuros[j][3] - if(Left(oJurACE:cEvento,2)=="52",oJurACE:nValorRS,-oJurACE:nValorRS)
                  oVCJurACE:cEvento  := AllTrim(Str(550+if(oVCJurACE:nValorRS>=0,0,1)+Val(::aTpJuros[j])*2))
                  oVCJurACE:cTpEve   := If(::lParcelas,::cTpFin,"02") //ACE  //FINIMP  // GFP - 30/06/2014
                  oVCJurACE:nTaxa    := aInvVincAtu[i]:aJuros[j][4]//BuscaTaxa(::cMoeda,If(ValType(dBCotMoe)=="D", dBCotMoe, dDataFim ),,.F.,.T.)//FSM - 27/04/2012 //FSM -22/08/2012
                  oVCJurACE:cSeq     := cSeqEvent //aInvVincAtu[i]:cSeq   //NCF - 16/01/2015
                  oVCJurACE:cInvoice := aInvVincAtu[i]:cInvoice
                  oVCJurACE:cPreemb  := aInvVincAtu[i]:cPreemb
                  oVCJurACE:cParc    := aInvVincAtu[i]:cParc
                  oVCJurACE:cMoeda   := aInvVincAtu[i]:cMoeda

                  If oVCJurACE:nValorRS <> 0 //oVCJurACE:nTaxa <> Round(::aInvVinc[i]:aJuros[j][3]/::aInvVinc[i]:aJuros[j][2],AvSX3("YE_TX_COMP",AV_DECIMAL))
                     aAdd(aEventosEF3,oVCJurACE)
                  EndIf
               Next j
            Endif
	     Next i
      EndIf

      aSort(aEventosEF3,,,{|X,Y| X:cInvoice < Y:cInvoice})

      EF1->(dbGoTo(::nRecEF1))
      RecLock("EF1",.F.)

      nTaxaCt := ::TaxaRS(dData,"500",dBCotMoe) //MCF - 25/07/2016

      For i := 1 To Len(aEventosEF3)
         If aEventosEF3[i]:nValorRS <> 0
            aEventosEF3[i]:dDtEve := dData
            aEventosEF3[i]:GravaEF3(EF1->EF1_DT_CTB,EF1->EF1_TX_CTB,dData,nTaxaCt) //MCF - 25/07/2016
         EndIf
      Next i

      If dData <> EF1->EF1_DT_CTB
         EF1->EF1_DT_ANT := EF1->EF1_DT_CTB
         EF1->EF1_TX_ANT := EF1->EF1_TX_CTB
      EndIf

      EF1->EF1_DT_CTB := dData
      EF1->EF1_TX_CTB := nTaxaCt //::TaxaRS(dData,"500",dBCotMoe)//BuscaTaxa(::cMoeda,If(ValType(dBCotMoe)=="D", dBCotMoe, dData ),,.F.,.T.) //FSM - 27/04/2012 //FSM -22/08/2012
	  
	  //RMD - 04/10/17 - Atualiza novamente os saldos
	  ::AtualizaSaldos()
	  //Grava os campos de saldo
	  EF1->EF1_SLD_PM := ::nSaldo
      EF1->EF1_SLD_PR := ::nSaldoRS
      EF1->EF1_SLD_JM := ::nJuros
      EF1->EF1_SLD_JR := ::nJurosRS
      EF1->EF1_SL2_PM := ::nSaldoACE
      EF1->EF1_SL2_PR := ::nSaldoACERS
      EF1->EF1_SL2_JM := ::nJurosACE
      EF1->EF1_SL2_JR := ::nJurosACERS
      EF1->EF1_LIQPRM := ::nAmortizado
      EF1->EF1_LIQPRR := ::nAmortizadoRS
      EF1->EF1_LIQJRM := ::nJurLiq
      EF1->EF1_LIQJRR := ::nJurLiqRS
		 
      EF1->(MsUnLock())

   Return nil

   /*
      Método..: ValApropJuros()
      Classe..: AvEFFContra
      Objetivo: Validacao para atualização das provisões de juros e variações cambiais do contrato para a data especificada.
      Autor...: Alessandro Alves Ferreira
   */
   Method ValApropJuros(dData) Class AvEFFContra
      Local lRet := .T.

      If !Empty(::dEncerra)// .AND. ::dUltAprop >= ::dEncerra - Nopado por AAF em 21/08/2012 - Não apropriar juros e v.c. em contrato encerrado. //FSM -22/08/2012
         ::Warning("Não é possível apropriar juros. Contrato encerrado.")
         lRet := .F.
      ElseIf Empty(::dIniJur) .OR. ::dIniJur > dData
         ::Warning("Não é possível apropriar juros. Data de inicio de juros não preenchida.")
         lRet := .F.
      EndIf

   Return lRet

   /*
      Método..: LoadInvs()
      Classe..: AvEFFContra
      Objetivo: Carregar as invoices vinculadas ao contrato
      Autor...: Alessandro Alves Ferreira
   */
   Method LoadInvs() Class AvEFFContra
      Local aInvs := {}
      Local nOrd, nRecEF3
      Local cSeek

      EF3->(nOrd := IndexOrd(),nRecEF3 := RecNo())
      EF3->(dbSetOrder(1))//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE
      cSeek := ::cChaveEF1+"600"
      EF3->(dbSeek(cSeek))
      Do While EF3->(!EoF() .AND. Left(&(IndexKey()),Len(cSeek)) == cSeek)
         If EF3->EF3_TPMODU == "I"
            //EF3->(aAdd(aInvs,AvInvImp():LoadEF3(Self)))
         Else
            EF3->(aAdd(aInvs,AvInvExp():LoadEF3(Self)))
         EndIf

         EF3->(dbSkip())
      EndDo
      EF3->(dbSetOrder(nOrd),dbGoTo(nRecEF3))

   Return aClone(aInvs)

   /*
      Método..: ValorRS()
      Classe..: AvEFFContra
      Objetivo: Conversao de valor na moeda do contrato para reais
      Autor...: Alessandro Alves Ferreira
   */
   Method ValorRS(nValorMoeda,dData,cEvento, dBCotMoe) Class AvEFFContra
      Local nValRS, nTaxaMoe //FSM -22/08/2012

      nTaxaMoe := ::TaxaRS(dData,cEvento, dBCotMoe)
      nValRS   := Round(nValorMoeda * nTaxaMoe,AvSX3("EF3_VL_REA",AV_DECIMAL))

   Return nValRS

   /*
      Método..: TaxaRS()
      Classe..: AvEFFContra
      Objetivo: Conversao de valor na moeda do contrato para reais
      Autor...: Alessandro Alves Ferreira
   */
   Method TaxaRS(dData,cEvento, dBCotMoe) Class AvEFFContra
      Local nTaxaMoe, cCompraVenda //FSM -22/08/2012

      If !Empty(cEvento)
         cCompraVenda := Posicione("EC6",1,xFilial("EC6")+"FI"+if(::cTpModu=="I","IM","EX")+::cTpFin+cEvento,"EC6_TXCV")
      Else
         cCompraVenda := "1" //Venda
      EndIf

      nTaxaMoe := BuscaTaxa(::cMoeda,If(ValType(dBCotMoe)=="D",dBCotMoe,dData),,.F.,.T.,,cCompraVenda)
      //nValRS   := Round(nValorMoeda * nTaxaMoe,AvSX3("EF3_VL_REA",AV_DECIMAL)) //FSM -22/08/2012

   Return nTaxaMoe

   /*
      Método..: LoadJurACC()
      Classe..: AvEFFContra
      Objetivo:
      Autor...: Alessandro Alves Ferreira
   */
   Method LoadJurACC() Class AvEFFContra
      Local aJuros := {}, i
      Local cInvoice, cParc
      Local cNot190 := NIL//RetMcr190Seq()
      //cInvoice := CriaVar("EF3_INVOIC")
      //cParc    := CriaVar("EF3_PARC")

      For i := 1 To Len(::aTpJuros)
         If !::lParcelas
            bTpEve := {||EF3->EF3_TP_EVE=="01"}
         Else
            bTpEve := NIL
         EndIf

         //Provisao de Juros ACC
         nValJuros   := EX401EvSum("52"+::aTpJuros[i],"EF3",::cChaveEF1,.T.,bTpEve,,::lParcelas,cNot190)
         nValJurosRS := EX401EvSum("52"+::aTpJuros[i],"EF3",::cChaveEF1,.F.,bTpEve,,::lParcelas,cNot190)

         //Variacao cambial da provisao
         nValJurosRS += EX401EvSum(AllTrim(Str(550+Val(::aTpJuros[i])*2)),"EF3",::cChaveEF1,.F.,bTpEve,,::lParcelas)
         nValJurosRS += EX401EvSum(AllTrim(Str(551+Val(::aTpJuros[i])*2)),"EF3",::cChaveEF1,.F.,bTpEve,,::lParcelas)

         //Estorno de provisao
         nValJuros   -= EX401EvSum("51"+::aTpJuros[i],"EF3",::cChaveEF1,.T.,bTpEve,,::lParcelas) //FSM -22/08/2012
         nValJurosRS -= EX401EvSum("51"+::aTpJuros[i],"EF3",::cChaveEF1,.F.,bTpEve,,::lParcelas) //FSM -22/08/2012

         If !::lParcelas
            //Tranferencia de ACC para ACE
            nValJuros   -= EX401EvSum("65"+::aTpJuros[i],"EF3",::cChaveEF1,.T.,bTpEve)
            nValJurosRS -= EX401EvSum("65"+::aTpJuros[i],"EF3",::cChaveEF1,.F.,bTpEve)

            //Liquidações (Tranferência) // NCF - 22/03/2016
            nValJuros   -= EX401EvSum("67"+::aTpJuros[i],"EF3",::cChaveEF1,.T.,bTpEve)
            nValJurosRS -= EX401EvSum("67"+::aTpJuros[i],"EF3",::cChaveEF1,.F.,bTpEve)

         Else
            //Liquidacao de Juros
            nValJuros   -= EX401EvSum("71"+::aTpJuros[i],"EF3",::cChaveEF1,.T.,{|| EF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0)})
            nValJurosRS -= EX401EvSum("71"+::aTpJuros[i],"EF3",::cChaveEF1,.F.,{|| EF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0)})
         EndIf

         aAdd(aJuros,{::aTpJuros[i],nValJuros,nValJurosRS})
      Next i

   Return aClone(aJuros)

   Method ValidaCampo(cCampo) Class AvEFFContra
      Local lRet := .T.

      cCampo := AllTrim(cCampo)

      If cCampo == "EF1_TP_FIN" .And. AvFlags("SIGAEFF_SIGAFIN") // LRS 7/4/2014 - Mudado a validação para mensagens de erro no SigaEFF

         EF7->( dbSetOrder(1) )
         If EF7->( dbSeek(xFilial("EF7")+M->EF1_TP_FIN) )
            If M->EF1_TPMODU == "E" .AND. Empty(EF7->EF7_NUMERA)
               MsgStop("Esse tipo de financiamento não pode ser utilizado pois não foi definido um numerário para a movimentação financeira.","Aviso")
               lRet := .F.
            ElseIf Empty(EF7->EF7_MOTBXI)
               MsgStop("Esse tipo de financiamento não pode ser utilizado pois não foi definido o motivo de baixa para as invoices vinculadas.","Aviso")
               lRet := .F.
            ElseIf Empty(EF7->EF7_MOTBXP)
               MsgStop("Esse tipo de financiamento não pode ser utilizado pois não foi definido o motivo de baixa para as parcelas de principal.","Aviso")
               lRet := .F.
            ElseIf Empty(EF7->EF7_MOTBXJ)
               MsgStop("Esse tipo de financiamento não pode ser utilizado pois não foi definido o motivo de baixa para as parcelas de juros.","Aviso")
               lRet := .F.
            EndIf
         EndIf

      ElseIf cCampo == "EF1_BAN_FI"
         SA6->(dbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
         SA2->(dbSetOrder(1))

         If SA6->(dbSeek(xFilial("SA6")+M->EF1_BAN_FI+M->EF1_AGENFI+M->EF1_NCONFI))
            If !SA2->(dbSeek(xFilial("SA2")+SA6->A6_CODFOR+SA6->A6_LOJFOR))
               //MsgStop("Banco de fechamento nao pode ser utilizado pois o fornecedor e loja nao sao validos.","Aviso") MCF - 12/01/2016
               MsgStop("Necessário preencher os campos Fornecedor e Loja, no cadastro de banco, para que esse banco possa ser utilizado no financiamento.","Aviso")
               lRet := .F.
            EndIf
         EndIf

      ElseIf cCampo == "GRAVA_CAPA_OK"
         If M->EF1_TPMODU == "E"
            If Empty(M->EF1_BAN_MO) .OR. Empty(M->EF1_AGENMO) .OR. Empty(M->EF1_NCONMO)
               AvSetFocus("EF1_BAN_MO",oDlgFocus)
               MsgStop("Necessario preencher o banco, agencia e conta de movimentacao.","Aviso")
               lRet := .F.
            EndIf
         EndIf

         If lRet
            lRet := ::ValidaCampo("EF1_BAN_FI")
         EndIf
      EndIf

      If !lRet .AND. SX3->(dbSetOrder(2),dbSeek(cCampo))
         AvSetFocus(cCampo,oDlgFocus)
      EndIf

   Return lRet

   Method CallEasyLink(cEvento) Class AvEFFContra
   Local lRet := .T.

   If cEvento == 'INCLUSAO_CONTRATO'
      lRet := AvStAction('050')
   ElseIf cEvento == 'INCLUSAO_ENCARGOS'
      lRet := AvStAction('051')
   ElseIf cEvento == 'INCLUSAO_VINCULACAO_INVOICE'
      lRet := AvStAction('052')
   ElseIf cEvento == 'INCLUSAO_LIQUIDACAO_INVOICE'
      lRet := AvStAction('053')
   ElseIf cEvento == 'INCLUSAO_PARCELA_PRINCIPAL'
      lRet := AvStAction('054')
   ElseIf cEvento == 'INCLUSAO_PARCELA_JUROS'
      lRet := AvStAction('055')
   ElseIf cEvento == 'ALTERACAO_CONTRATO'
      lRet := AvStAction('056')
   ElseIf cEvento == 'ALTERACAO_ENCARGOS'
      lRet := AvStAction('057')
   ElseIf cEvento == 'ALTERACAO_VINCULACAO_INVOICE'
      lRet := AvStAction('058')
   ElseIf cEvento == 'ALTERACAO_LIQUIDACAO_INVOICE'
      lRet := AvStAction('059')
   ElseIf cEvento == 'ALTERACAO_PARCELA_PRINCIPAL'
      lRet := AvStAction('060')
   ElseIf cEvento == 'ALTERACAO_PARCELA_JUROS'
      lRet := AvStAction('061')
   ElseIf cEvento == 'ESTORNO_CONTRATO'
      lRet := AvStAction('062')
   ElseIf cEvento == 'ESTORNO_ENCARGOS'
      lRet := AvStAction('063')
   ElseIf cEvento == 'ESTORNO_VINCULACAO_INVOICE'
      lRet := AvStAction('064')
   ElseIf cEvento == 'ESTORNO_LIQUIDACAO_INVOICE'
      lRet := AvStAction('065')
   ElseIf cEvento == 'ESTORNO_PARCELA_PRINCIPAL'
      lRet := AvStAction('066')
   ElseIf cEvento == 'ESTORNO_PARCELA_JUROS'
      lRet := AvStAction('067')
   ElseIf cEvento == 'LIQUIDACAO_PARCELA_PRINCIPAL'
      lRet := AvStAction('068')
   ElseIf cEvento == 'LIQUIDACAO_PARCELA_JUROS'
      lRet := AvStAction('069')
   ElseIf cEvento == 'ESTORNO_LIQUIDACAO_PARCELA_PRINCIPAL'
      lRet := AvStAction('070')
   ElseIf cEvento == 'ESTORNO_LIQUIDACAO_PARCELA_JUROS'
      lRet := AvStAction('071')
   ElseIf cEvento == 'LIQUIDACAO_ENCARGOS'
      lRet := AvStAction('076')
   ElseIf cEvento == 'ESTORNO_LIQUIDACAO_ENCARGOS'
      lRet := AvStAction('077')
   ElseIf cEvento == 'INCLUSAO_ENCERRAMENTO_CONTRATO'                 //NCF - 04/12/2014 - Inclusão do eventos de encerramento de contrato para geração de contas a pagar
      lRet := AvStAction('055')
   ElseIf cEvento == 'ESTORNO_ENCERRAMENTO_CONTRATO'
      lRet := AvStAction('067')
   ElseIf cEvento == 'LIQUIDACAO_ENCERRAMENTO_CONTRATO'
      lRet := AvStAction('069')
   ElseIf cEvento == 'ESTORNO_LIQUIDACAO_ENCERRAMENTO_CONTRATO'
      lRet := AvStAction('070')
   EndIf

   Return lRet

//Retorna os períodos de juros para um período informado.
//dDataIni   - Data inicial do Período
//dDataFim   - Data Final do período
//[cTpJur]   - Tipo de juros
//[cInvoice] - Período específico para a invoice informada
Function EX401PerJur(dDataIni,dDataFim,dDtVinc,cTpJur,cInvoice,cTpFin,cAliasEF2,lGoTop)
Local i
Local aPer := {}, aPerACE := {}, aPerInv := {}, aPeriodos := {}
Local cSeek
Local nTaxa, nTaxaInv, nTaxaDia
Local dDtIniInv, dDtFimInv, dDtIni, dDtFim
Local nPosJur,nPosPer
Local lQuebrou
Local cChave, nRecNo
Default cAliasEF2:= "EF2"
Default lGoTop := .F. //LRS - 05/06/2018 - Parametro que define se vai dar DBGOTOP na alias WorkEF2

nRecNo:= (cAliasEF2)->(RecNo())
(cAliasEF2)->(DBSetOrder(1))
cTpJur := AvKey(cTpJur,"EF2_TIPJUR")
/* wfs 23/05/2016
   Se cAliasEF2 for EF2, EF2_FILIAL+EF2_TPMODU+EF2_CONTRA+EF2_BAN_FI+EF2_PRACA+EF2_SEQCNT+EF2_FILORI+EF2_INVOIC+EF2_PARC+EF2_TIPJUR.
   Se cAliasEF2 for WorkEF2, "EF2_FILORI+EF2_INVOIC+EF2_PARC+EF2_TP_FIN+EF2_TIPJUR+DTOS(EF2_DT_INI)+DTOS(EF2_DT_FIM).
   Quando for solicitado o cálculo com base na work, será apurado o período do item posicionado. */
cChave:= "EF2_FILIAL+EF2_TPMODU+EF2_CONTRA+EF2_BAN_FI+EF2_PRACA+EF2_SEQCNT"
cSeek := xFilial("EF2")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)
If cAliasEF2 == "WorkEF2"
   WorkEF2->(dbGoTop()) //AAF 23/03/2017
Else
   (cAliasEF2)->(dbSeek(cSeek))
EndIf

//Do While (cAliasEF2)->(!Eof() .AND. EF2_FILIAL+EF2_TPMODU+EF2_CONTRA+EF2_BAN_FI+EF2_PRACA+EF2_SEQCNT == cSeek)
Do While (cAliasEF2)->(!Eof() .AND. &(cChave) == cSeek)

   cInv := (cAliasEF2)->EF2_FILORI + (cAliasEF2)->EF2_INVOIC + (cAliasEF2)->EF2_PARC

   //Condições para considerar o período de juros
   If (Empty(cTpJur) .OR. cTpJur == (cAliasEF2)->EF2_TIPJUR) .AND.;
      (Empty(cInv) .OR. cInv == cInvoice) .AND.;  //FSM - 09/03/2012
      ((cAliasEF2)->EF2_DT_FIM >= dDataIni .AND. (cAliasEF2)->EF2_DT_INI <= dDataFim)

      //Taxa de juros/dia
      nTaxaDia := ((cAliasEF2)->EF2_TX_FIX + (cAliasEF2)->EF2_TX_VAR)/360

      If Empty(dDtVinc)
         dDtVinc := dDataFim
      EndIf
      dDtIniAce := dDtVinc+1

      //Garantir inicio do periodo ACE dentro do período total
      dDtIniAce := Max(dDtIniAce,dDataIni)
      dDtIniAce := Min(dDtIniAce,dDataFim)
      //Garantir vinculacao dentro do período total
      dDtVinc := Max(dDtVinc,dDataIni)
      dDtVinc := Min(dDtVinc,dDataFim)

      //Grava em um array as taxas de juros cadastradas
      If Empty(cInv)
         If cTpFin == "02" .AND. (cAliasEF2)->EF2_TP_FIN == "02"
            If (nPosJur := aScan(aPerACE,{|X| X[1] == (cAliasEF2)->EF2_TIPJUR})) > 0
               aAdd(aPerACE[nPosJur][2],{Max(Max((cAliasEF2)->EF2_DT_INI,dDataIni),dDtIniAce),Min((cAliasEF2)->EF2_DT_FIM,dDataFim),nTaxaDia})
            Else
               aAdd(aPerACE,{(cAliasEF2)->EF2_TIPJUR,{{Max(Max((cAliasEF2)->EF2_DT_INI,dDataIni),dDtIniAce),Min((cAliasEF2)->EF2_DT_FIM,dDataFim),nTaxaDia}}})
            EndIf
         Else //AAF 28/08/2015 - Não deve checar o tipo dos juros.
            If (nPosJur := aScan(aPer,{|X| X[1] == (cAliasEF2)->EF2_TIPJUR})) > 0
               aAdd(aPer[nPosJur][2],{Max((cAliasEF2)->EF2_DT_INI,dDataIni),Min((cAliasEF2)->EF2_DT_FIM,dDataFim),nTaxaDia})
            Else
               //aAdd(aPer,{EF2->EF2_TIPJUR,{{Max(EF2->EF2_DT_INI,dDataIni),Min(Min(EF2->EF2_DT_FIM,dDataFim),dDtVinc),nTaxaDia}}})
               aAdd(aPer,{(cAliasEF2)->EF2_TIPJUR,{{Max((cAliasEF2)->EF2_DT_INI,dDataIni),Min((cAliasEF2)->EF2_DT_FIM,dDataFim),nTaxaDia}}}) //AAF - 20/08/2012 - Calcular até o fim do período. //FSM -22/08/2012
            EndIf
         EndIf
      Else
         If (nPosJur := aScan(aPerInv,{|X| X[1] == (cAliasEF2)->EF2_TIPJUR})) > 0
            aAdd(aPerInv[nPosJur][2],{Max(Max((cAliasEF2)->EF2_DT_INI,dDataIni),dDtIniAce),Min((cAliasEF2)->EF2_DT_FIM,dDataFim),nTaxaDia})
         Else
            aAdd(aPerInv,{(cAliasEF2)->EF2_TIPJUR,{{Max(Max((cAliasEF2)->EF2_DT_INI,dDataIni),dDtIniAce),Min((cAliasEF2)->EF2_DT_FIM,dDataFim),nTaxaDia}}})
         EndIf
      EndIf

   EndIf

   (cAliasEF2)->(dbSkip())
EndDo

//Teoricamente, nenhum período pode ser cadastrado sobreposto.
//Os arrays ordenados são de períodos disjuntos.
For i := 1 To Len(aPerInv)
   aSort(aPerInv[i][2],,,{|X,Y| X[2] < Y[2]})
Next i
For i := 1 To Len(aPerACE)
   aSort(aPerACE[i][2],,,{|X,Y| X[2] < Y[2]})
Next i
For i := 1 To Len(aPer)
   aSort(aPer[i][2],,,{|X,Y| X[2] < Y[2]})
Next i

//Torna os array disjuntos dois a dois
ConsolidaPeriodos(aPerACE,aPerINV) //Retira dos períodos ACE o período especifico da invoice (prioridade para o juros especifico).
ConsolidaPeriodos(aPer,aPerACE)    //Retira dos períodos ACC o período especifico para ACE (prioridade para o juros ACE).
ConsolidaPeriodos(aPer,aPerINV)    //Retira dos períodos ACC o período especifico para ACE (prioridade para o juros ACE).

//Array com os períodos consolidados (uniao dos períodos)
AdicionaPeriodos(aPeriodos,aPerInv)
AdicionaPeriodos(aPeriodos,aPerACE)
AdicionaPeriodos(aPeriodos,aPer)

//Ordena o array de períodos
For i := 1 To Len(aPeriodos)
   aSort(aPeriodos[i][2],,,{|X,Y| X[2] < Y[2]})
Next i

(cAliasEF2)->(DBGoTo(nRecNo))
Return aClone(aPeriodos)

/*
Função          : AdicionaPeriodos()
Objetivo        :
Autor           :
Data            :
Obs.            :
Revisão         :
*/
Static Function AdicionaPeriodos(aPeriodoDest,aPeriodoOri)
Local i, j

For i := 1 To Len(aPeriodoOri)

   If (nPosPer := aScan(aPeriodoDest,{|X| X[1] == aPeriodoOri[i][1]})) == 0
      aAdd(aPeriodoDest,{aPeriodoOri[i][1],Array(0)})
      nPosPer := Len(aPeriodoDest)
   EndIf

   For j := 1 To Len(aPeriodoOri[i][2])
      aAdd(aPeriodoDest[nPosPer][2],aClone(aPeriodoOri[i][2][j]))
   Next j

Next i

Return nil

/*
Função          : ConsolidaPeriodo()
Objetivo        :
Autor           :
Data            :
Obs.            :
Revisão         :
*/
Static Function ConsolidaPeriodo(aPeriodoDest,aPeriodoOri)
Local i, j, k
Local nPosJur

//Retira dos as intersecções dos períodos
For i := 1 To Len(aPeriodoOri)
   //Para cada tipo de juros que possuir no periodo origem
   nPosJur := aScan(aPeriodoDest,{|X| X[1] == aPeriodoOri[i][1]})

   //Procura o tipo de juros nos períodos do destino
   If nPosJur > 0

      //Para cada período na origem
      For j := 1 To Len(aPeriodoOri[i][2])
         dDtIniInv := aPeriodoOri[i][2][j][1]
         dDtFimInv := aPeriodoOri[i][2][j][2]
         nTaxaInv  := aPeriodoOri[i][2][j][3]

         //Para cada período no destino
         k:=1
         While k <= Len(aPeriodoDest[nPosJur][2])
            dDtIni := aPeriodoDest[nPosJur][2][k][1]
            dDtFim := aPeriodoDest[nPosJur][2][k][2]
            nTaxa  := aPeriodoDest[nPosJur][2][k][3]

            //Verifica se o período origem tem intersecção com o destino
            If dDtFimInv >= dDtIni .AND. dDtIniInv <= dDtFim

               If dDtIniInv <= dDtIni .AND. dDtFimInv >= dDtFim
                  //Se o período origem contiver todo período destino, mata o período destino
                  aDel(aPeriodoDest[nPosJur][2],k)
                  aSize(aPeriodoDest[nPosJur][2],Len(aPeriodoDest[nPosJur][2])-1)
               Else
                  lQuebrou := .F.

                  If dDtIniInv > dDtIni
                     //Retira a parte contida no período origem
                     aPeriodoDest[nPosJur][2][k][2] := dDtIniInv-1
                     lQuebrou := .T.
                  EndIf

                  If dDtFimInv < dDtFim
                     If lQuebrou
                        //Retira a parte contida no período origem, mantendo o restante
                        aAdd(aPeriodoDest[nPosJur][2],NIL)
                        aIns(aPeriodoDest[nPosJur][2],k+1)
                        aPeriodoDest[nPosJur][2][k+1] := {dDtFimInv+1,dDtFim,nTaxa}
                     Else
                        //Retira a parte contida no período origem
                        aPeriodoDest[nPosJur][2][k][1] := dDtFimInv+1
                     EndIf
                  EndIf

               EndIf
            EndIf
            k++
         EndDo

      Next j

   EndIf
Next i

Return nil

//Fim Métodos - AvEFFContra

/*
Classe..: AvTitulo
Objetivo: Representar titulos financeiros
Autor...: Alessandro Alves Ferreira
Data....: 10/11/2009
*/
Class AvTitulo INHERIT from AvObject

   Data oEFFContra

   Data cTpEve
   Data cEvento
   Data cDescEve
   Data cNumTit
   Data cParcela
   Data cTipoFin
   Data cNatureza
   Data cForn
   Data cLoja
   Data dEmissao
   Data dVencto
   Data dVencReal
   Data cMoeda
   Data nValor
   Data nTaxa
   Data nValorRS
   Data cHistorico
   Data lLiquidado
   Data dDataLiq
   Data cBanco
   Data cAgencia
   Data cConta
   Data dDtDebito

   Data cInvoice
   Data cPreemb
   Data cParc
   Data cInvImp
   Data cHawb
   Data cLinha
   Data cPoDi
   Data dDtEve
   Data cSeq

   Data cChaveEF3
   Data nRecNoEF3

   Method New() Constructor
   Method LoadEF3()
   Method GravaEF3()
   Method SetHist()

EndClass

//Inicio - Métodos do AvTitulo
   /*
      Método..: New()
      Classe..: AvTitulo
      Objetivo: Construtor da classe AvTitulo
      Autor...: Alessandro Alves Ferreira
      Data....: 10/11/2009
   */
   Method New(oContra) Class AvTitulo
      _Super:New()
      ::setClassName("AvTitulo")
      ::oEFFContra := oContra

      ::dDtDebito := CTod("  /  /  ")
      ::cEvento   := ""
      ::cTpEve    := ""
      ::cDescEve  := ""
      ::cNumTit   := ""
      ::cParcela  := ""
      ::cTipoFin  := ""
      ::cNatureza := ""
      ::cForn	  := ""
      ::cLoja	  := ""
      ::dEmissao  := CTod("  /  /  ")
      ::dVencto	  := ""
      ::dVencReal := ""
      ::nValor	  := 0
      ::nValorRS  := ""
      ::cHistorico:= ""
      ::lLiquidado:= .F.
      ::dDataLiq  := CTod("  /  /  ")
      ::cMoeda    := ""
      ::cBanco    := ""
      ::cAgencia  := ""
      ::cConta    := ""
      ::cInvoice  := ""
      ::cPreemb   := ""
      ::cParc     := ""
      ::cInvImp   := ""
      ::cHawb     := ""
      ::cLinha    := ""
      ::cPoDi     := ""
      ::dDtEve    := CTod("")
      ::cSeq      := ""
      ::cChaveEF3 := ""
      ::nRecNoEF3 := 0

   Return Self

   /*
      Método..: LoadEF3()
      Classe..: AvTitulo
      Objetivo: Construtor da classe AvTitulo com base na tabela EF3.
      Autor...: Alessandro Alves Ferreira
   */
   Method LoadEF3(oContra) Class AvTitulo
      ::New(oContra)

      If EF3->(Eof())
         ::Error("LoadEF3 - Tabela EF3 não está posicionada.")
      Else
         ::nRecNoEF3 := EF3->(RecNo())

         ::cBanco     := if(!Empty(EF3->EF3_BANC),EF3->EF3_BANC,EF3->EF3_BAN_FI)
         ::cAgencia   := if(!Empty(EF3->EF3_AGEN),EF3->EF3_AGEN,EF3->EF3_AGENFI)
         ::cConta     := if(!Empty(EF3->EF3_NCON),EF3->EF3_NCON,EF3->EF3_NCONFI)

         /* Se informado, assume o banco da movimentação. */
         If !Empty(EF3->EF3_BC_MOV)
            ::cBanco  := EF3->EF3_BC_MOV
            ::cAgencia:= EF3->EF3_AG_MOV
            ::cConta  := EF3->EF3_CC_MOV
         EndIf

         ::cMoeda     := EF3->EF3_MOE_IN
         ::cEvento    := EF3->EF3_CODEVE

         If ::oEFFContra <> NIL
            ::cDescEve  := AllTrim(Posicione("EC6",1,xFilial("EC6")+"FI"+if(::oEFFContra:cTpModu=="I","IM","EX")+::oEFFContra:cTpFin+::cEvento,"EC6_DESC"))
         EndIf

         ::dDtEve    := if(!Empty(EF3->EF3_DT_EVE),EF3->EF3_DT_EVE,dDataBase)
         ::cTpEve    := EF3->EF3_TP_EVE
         ::cPreemb   := EF3->EF3_PREEMB
         ::cInvoice  := EF3->EF3_INVOIC
         ::cParc     := EF3->EF3_PARC

         ::cForn   := EF3->EF3_FORN
         ::cLoja   := EF3->EF3_LOJAFO

         ::cSeq    := EF3->EF3_SEQ

         ::nValor  := EF3->EF3_VL_MOE

         If !Empty(EF3->EF3_VL_REA)
            ::nValorRS := EF3->EF3_VL_REA
         Else
            ::nValorRS := Round(BuscaTaxa(::cMoeda,::dDtEve,,.F.,.T.)*::nValor,AvSX3("EF3_VL_REA",AV_DECIMAL))//xMoeda(::nValor,::cMoedaSiga,1,::dEmissao)
         EndIf

         ::nTaxa := Round(::nValorRS/::nValor,AvSX3("EF3_TX_MOE",AV_DECIMAL))

         If Empty(::nTaxa)
            If !Empty(EF3->EF3_TX_MOE)
               ::nTaxa := EF3->EF3_TX_MOE
            Else
               ::nTaxa := BuscaTaxa(::cMoeda,::dDtEve,,.F.,.T.)
            EndIf
         EndIf

      EndIf

   Return Self

   /*
      Método..: SetHist()
      Classe..: AvTitulo
      Objetivo: Definir o texto para histórico do titulo a pagar no Microsiga
      Autor...: Alessandro Alves Ferreira
   */
   Method SetHist(cHist) Class AvTitulo
      If ValType(cHist) == "C"
         ::cHistorico:= cHist
      Else
         //If Left(::cEvento,1) $ "3/4"
         ::cHistorico := AllTrim(::oIntFin:oContrato:cContrato)+" - "+AllTrim(::cDescEve)
         //EndIf
      EndIf
   Return Nil

   /*
      Método..: GravaEF3()
      Classe..: AvTitulo
      Objetivo: Gravar o titulo nos eventos do contrato de financiamento
      Autor...: Alessandro Alves Ferreira
   */
   Method GravaEF3(dDataCtAnt,nTxCtAnt,dDataCt,nTxCt) Class AvTitulo
      Local lEF3Ct := EF3->( FieldPos( "EF3_DT_CTB" ) ) > 0 .AND. EF3->( FieldPos( "EF3_TX_CTB" ) ) > 0 ;
            .AND. EF3->( FieldPos( "EF3_DT_ANT" ) ) > 0 .AND. EF3->( FieldPos( "EF3_TX_ANT" ) ) > 0

      If !Empty(::nRecNoEF3)
         EF3->(dbGoTo(::nRecNoEF3))
         RecLock("EF3",.F.)
      Else
         RecLock("EF3",.T.)
      EndIf

      EF1->(dbGoTo(::oEFFContra:nRecEF1))

      EF3->EF3_FILIAL := xFilial("EF3")
      EF3->EF3_CONTRA := EF1->EF1_CONTRA
      EF3->EF3_TPMODU := EF1->EF1_TPMODU
      EF3->EF3_TP_EVE := ::cTpEve
      EF3->EF3_CODEVE := ::cEvento
      EF3->EF3_BAN_FI := EF1->EF1_BAN_FI
      EF3->EF3_AGENFI := EF1->EF1_AGENFI
      EF3->EF3_NCONFI := EF1->EF1_NCONFI
      EF3->EF3_PRACA  := EF1->EF1_PRACA
      EF3->EF3_SEQCNT := EF1->EF1_SEQCNT
      EF3->EF3_ROF    := EF1->EF1_ROF
      EF3->EF3_MOE_IN := ::cMoeda
      EF3->EF3_INVOIC := ::cInvoice
      EF3->EF3_PREEMB := ::cPreemb
      EF3->EF3_PARC   := ::cParc
      EF3->EF3_INVIMP := ::cInvImp
      EF3->EF3_HAWB   := ::cHawb
      EF3->EF3_LINHA  := ::cLinha
      EF3->EF3_FORN   := ::cForn
      EF3->EF3_LOJAFO := ::cLoja
      EF3->EF3_PO_DI  := ::cPoDi
      EF3->EF3_VL_MOE := ::nValor
      EF3->EF3_VL_REA := ::nValorRS
      EF3->EF3_TX_MOE := ::nTaxa
      EF3->EF3_DT_EVE := ::dDtEve
      EF3->EF3_SEQ    := ::cSeq

      If lEF3Ct //MCF - 25/07/2016
         If dDataCt <> dDataCtAnt
            EF3->EF3_DT_ANT := dDataCtAnt
            EF3->EF3_TX_ANT := nTxCtAnt
         EndIf

         EF3->EF3_DT_CTB := dDataCt
         EF3->EF3_TX_CTB := nTxCt
      EndIf

	  If EasyEntryPoint("EFFEX101")
         ExecBlock("EFFEX101",.F.,.F.,"GRAVANDO_EF3_CONTAB")
      Endif

      EF3->(MsUnLock())

      EX401GrEncargos("EF3") // AAF 22/05/2015 - Gerar encargos

   Return nil
//Fim - Métodos do AvTitulo

/*
Classe..: AvInvExp
Objetivo: Representar invoices de exportacao vinculadas a contrato de financiamento
Autor...: Alessandro Alves Ferreira
*/
Class AvInvExp INHERIT from AvTitulo

   Data aJuros
   Data cChaveInv
   Data nSaldo
   Data nSaldoRS

   Method New() Constructor
   Method LoadEF3() Constructor

EndClass

//Inicio - Métodos do AvInvExp
   /*
      Método..: New()
      Classe..: AvInvExp
      Objetivo: Construtor da classe AvInvExp
      Autor...: Alessandro Alves Ferreira
   */
   Method New(oContra) Class AvInvExp
      _Super:New(oContra)
      ::setClassName("AvInvExp")
      ::aJuros     := {}
      ::nSaldo     := 0
      ::nSaldoRS   := 0
   Return Self

   /*
      Método..: LoadEF3()
      Classe..: AvInvExp
      Objetivo: Construtor da classe AvInvExp com base na tabela EF3.
      Autor...: Alessandro Alves Ferreira
   */
   Method LoadEF3(oContra) Class AvInvExp
      Local i, nValJuros, nValJurosRS
      Local cNotSeq190 := NIL//RetMcr190Seq()

      EF3->(nOldOrd:= IndexOrd(),nOldRec:= RecNo())

      _Super:LoadEF3(oContra)
      ::setClassName("AvInvExp")
      ::aJuros     := {}

      If ::oEFFContra <> NIL
         If  !::oEFFContra:lParcelas

            For i := 1 To Len(::oEFFContra:aTpJuros)
            //Transferencia de Juros
            nValJuros   := EX401EvSum("65"+::oEFFContra:aTpJuros[i],"EF3",::oEFFContra:cChaveEF1,.T.,{||EF3->EF3_TP_EVE=="01"},{::cInvoice,::cParc})
            nValJurosRS := EX401EvSum("65"+::oEFFContra:aTpJuros[i],"EF3",::oEFFContra:cChaveEF1,.F.,{||EF3->EF3_TP_EVE=="01"},{::cInvoice,::cParc})

            //Provisao de Juros
            nValJuros   += EX401EvSum("52"+::oEFFContra:aTpJuros[i],"EF3",::oEFFContra:cChaveEF1,.T.,{||EF3->EF3_TP_EVE=="02"},{::cInvoice,::cParc},oContra:lParcelas,cNotSeq190)
            nValJurosRS += EX401EvSum("52"+::oEFFContra:aTpJuros[i],"EF3",::oEFFContra:cChaveEF1,.F.,{||EF3->EF3_TP_EVE=="02"},{::cInvoice,::cParc},oContra:lParcelas,cNotSeq190)

            //Variacao cambial da provisao
            nValJurosRS += EX401EvSum(AllTrim(Str(550+Val(::oEFFContra:aTpJuros[i])*2)),"EF3",::oEFFContra:cChaveEF1,.F.,{||EF3->EF3_TP_EVE=="02"},{::cInvoice,::cParc},oContra:lParcelas)
            nValJurosRS += EX401EvSum(AllTrim(Str(551+Val(::oEFFContra:aTpJuros[i])*2)),"EF3",::oEFFContra:cChaveEF1,.F.,{||EF3->EF3_TP_EVE=="02"},{::cInvoice,::cParc},oContra:lParcelas)

            //Estorno de provisao
            nValJuros   -= EX401EvSum("51"+::oEFFContra:aTpJuros[i],"EF3",::oEFFContra:cChaveEF1,.T.,{||EF3->EF3_TP_EVE=="02"},{::cInvoice,::cParc},oContra:lParcelas) //FSM -22/08/2012
            nValJurosRS -= EX401EvSum("51"+::oEFFContra:aTpJuros[i],"EF3",::oEFFContra:cChaveEF1,.F.,{||EF3->EF3_TP_EVE=="02"},{::cInvoice,::cParc},oContra:lParcelas)//FSM -22/08/2012

            //Liquidações
            nValJuros   -= EX401EvSum("64"+::oEFFContra:aTpJuros[i],"EF3",::oEFFContra:cChaveEF1,.T.,{||EF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0 .AND. EF3_TP_EVE=="02")},{::cInvoice,::cParc}) //FSM -22/08/2012
            nValJurosRS -= EX401EvSum("64"+::oEFFContra:aTpJuros[i],"EF3",::oEFFContra:cChaveEF1,.F.,{||EF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0 .AND. EF3_TP_EVE=="02")},{::cInvoice,::cParc}) //FSM -22/08/2012

            aAdd(::aJuros,{::oEFFContra:aTpJuros[i],nValJuros,nValJurosRS})
            Next i

            //Variacao cambial da vinculacao
            ::nValorRS += EX401EvSum("500","EF3",::oEFFContra:cChaveEF1,.F.,{||EF3->EF3_TP_EVE=="02"},{::cInvoice,::cParc})
            ::nValorRS += EX401EvSum("501","EF3",::oEFFContra:cChaveEF1,.F.,{||EF3->EF3_TP_EVE=="02"},{::cInvoice,::cParc})
         EndIf

         ::nSaldo   := ::nValor
         ::nSaldoRS := ::nValorRS

         EF3->(dbSetOrder(1))
         ::lLiquidado := EF3->(dbSeek(::oEFFContra:cChaveEF1+"630"+::cParc+::cInvoice))
         If ::lLiquidado
            ::dDataLiq   := EF3->EF3_DT_EVE
            ::nSaldo     := 0
            ::nSaldoRS   -= EF3->EF3_VL_REA
         EndIf
      EndIf

      ::cChaveInv := ::cInvoice+::cParc

      EF3->(dbSetOrder(nOldOrd),dbGoTo(nOldRec))

   Return Self

/*
Funcao     : BuscaProvisoes()
Parametros : nValor, lSubtrai, nSaldo
Retorno    : NIL
Objetivos  : Ajusta valor passado via parametro analisando parcelas já liquidadas
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 07/07/2014 - 09:44
*/
Static Function BuscaProvisoes(nValor,lSubtrai,nSaldo)  // GFP - 07/07/2014
Local aOrd       := SaveOrd({"EF1","EF3"})
Local aProvisoes := {}
Local dDtApu     := If(Type('dDataApu') == "D",dDataApu,CTOD(""))  // NCF - 15/08/2014 - Ajuste para chamada a partir do EFFEX101
Local cNotSeq190 := 	()

EF3->(DbSetOrder(1))
If EF3->(DbSeek(xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)+"520"))
   Do While EF3->(!Eof()) .AND. EF3->EF3_TPMODU == EF1->EF1_TPMODU .AND.;
                                EF3->EF3_CONTRA == EF1->EF1_CONTRA .AND.;
                                EF3->EF3_BAN_FI == EF1->EF1_BAN_FI .AND.;
                                EF3->EF3_PRACA  == EF1->EF1_PRACA  .AND.;
                                EF3->EF3_SEQCNT == EF1->EF1_SEQCNT .AND.;
                                EF3->EF3_CODEVE == "520"

      If !(&(cNotSeq190))  //NCF - 18/03/2016
         EF3->(DbSkip())
         Loop
      EndIf

      If lSubtrai .AND. !Empty(dDtApu) .AND. EF3->EF3_DT_EVE <= dDtApu
         nValor -= EF3->EF3_VL_MOE
      ElseIf Empty(EF3->EF3_EV_VIN)
         aAdd(aProvisoes,{EF3->EF3_DT_EVE,EF3->EF3_TX_MOE})
      EndIf
      EF3->(DbSkip())
   EndDo
EndIf

If !lSubtrai .AND. Len(aProvisoes) # 0
   aSort(aProvisoes,,,{|X,Y| X[1] > Y[1]})
   nValor := Round(aProvisoes[1][2]*nSaldo,AvSX3("EF3_VL_REA",AV_DECIMAL))
EndIf

RestOrd(aOrd,.T.)
Return NIL

/*
Funcao     : GetSequencia()
Parametros : cChave, cSeqAnte
Retorno    : cSeq
Objetivos  : Busca a sequencia seguinte dos eventos do contrato
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 15/07/2014 : 13:57
*/
Static Function GetSequencia(cChave,cSeqAnt)
Local aOrd := SaveOrd("EF3")
Local cSeq := If(ValType(cSeqAnt) # "U", cSeqAnt, "0000")
If cSeq == "0000"
   EF3->(dbSetOrder(1))//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE
   If EF3->(DbSeek(cChave))
      Do While EF3->(!Eof()) .AND. EF3->(EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT) == cChave

         If EF3->EF3_SEQ > cSeq
            cSeq := EF3->EF3_SEQ
         EndIf

         EF3->(DbSkip())
      EndDo
   EndIf
EndIf
RestOrd(aOrd,.T.)
Return SomaIt(cSeq)


/*
Funcao     : RetMcr190Seq()
Parametros : CtipoRet -> M - retornar Macro / S - Retornar String com eventos encontrados
Retorno    : cSeek190En
Objetivos  : Retornar string do tipo macro para que a função principal possa evitar eventos que possuam
             a mesma sequencia de um evento de transferência (190)
Obs.       : O contrato precisa estar posicionado(tabela EF1)
Autor      : Nilson César C. Filho - NCF
Data/Hora  : 22/03/2016 : 10:00
*/
Function RetMcr190Seq(ctipoRet)

      Local cQry190Enc := cEvents := ""
      Local cSeek190En := ""
      Default cTipoRet := "S"
      cQry190Enc := "SELECT EF3_SEQ SEQUENCIA"     + ;
                    " FROM "+RetSQLName("EF3")                   + ;
                    " WHERE D_E_L_E_T_ = ' '"                    + ;
                    " AND EF3_FILIAL = '"+ xFilial("EF3")  + "'" + ;
                    " AND EF3_TPMODU = '"+ EF1->EF1_TPMODU + "'" + ;
                    " AND EF3_CONTRA = '"+ EF1->EF1_CONTRA + "'" + ;
                    " AND EF3_BAN_FI = '"+ EF1->EF1_BAN_FI + "'" + ;
                    " AND EF3_PRACA  = '"+ EF1->EF1_PRACA  + "'" + ;
                    " AND EF3_SEQCNT = '"+ EF1->EF1_SEQCNT + "'" + ;
                    " AND EF3_CODEVE = '"+ '190'           + "'"

      cQuery:=ChangeQuery(cQry190Enc)
      TcQuery cQuery ALIAS "SEQ190" NEW
      dbSelectArea("SEQ190")

      If SEQ190->(!Eof())

         Do While SEQ190->(!Eof())
            cEvents += SEQ190->SEQUENCIA + "/"
            SEQ190->(DbSkip())
         EndDo

         If cEvents <> ""
            cSeek190En := "!( EF3->EF3_SEQ $ '" + cEvents + "')"
         Else
            cSeek190En := "AllwaysTrue()"
         EndIf

      Else
         cSeek190En := "AllwaysTrue()"
      EndIf

      SEQ190->(dbCloseArea())


Return If(ctipoRet == "S",cEvents,cSeek190En)
