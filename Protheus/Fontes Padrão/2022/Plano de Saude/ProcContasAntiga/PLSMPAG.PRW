#include "PLSMGER.CH" 
#include "PLSMLIB.CH"

#IFDEF TOP
	#include "TOPCONN.CH"
#ENDIF

#include "PROTHEUS.CH"

#DEFINE PLPMONEY_G "@E 999,999,999,999.99"
#DEFINE PLPMONEY_M "@E 999,999.99"	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSLDCRE ³ Autor ³ Tulio Cesar           ³ Data ³ 06.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o saldo de um credenciado em um determinado mes    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno                                                             ³
//³                                                                     ³
//³ [1]      Operacao correta .F./.T.                                   ³
//³ [2]    - Vetor com Composicao do Pagamento                          ³
//³ [2,1]  - 2(C)redito 1(D)ebito                                       ³
//³ [2,2]  - Valor                                                      ³
//³ [2,3]  - Codigo do Lancamento (C 03)                                ³
//³ [2,4]  - Descricao Evento                                           ³
//³ [2,7]  - Imagem p/ DbTree                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function PLSLDCRE(	cCodRDA,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,;
                  	cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,cCodForn,cLoja,aLancPagto,;
                  	cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,cCodDC,lCalcImp,;
                  	cCodNat,lGuiCob,lPgtDiv,lGerLot,lMudUs,nNewUs,nApUsDif,;
					lAtuGui,cOpeLote,cLote,dVencto,cExcPeg,cTipTitInt,nPosTitInt,cNoExcPeg,lAneste)

LOCAL nFor			:=0	
LOCAL cCodLan
LOCAL cDesLan
LOCAL cDebCre
LOCAL cImgTree
LOCAL aPropri

LOCAL cVerba
LOCAL aRetProPri

LOCAL nVlrB_IR     := 0
LOCAL nVlrB_INPF   := 0
LOCAL nVlrB_INPJ   := 0
LOCAL nVlrB_INJF   := 0
LOCAL nVlrB_INHP   := 0
LOCAL nVlrB_INUN   := 0

LOCAL nVlrB_PIS    := 0
LOCAL nVlrB_COF    := 0
LOCAL nVlrB_CSL    := 0
LOCAL nVlrB_ISS    := 0

LOCAL nOrdBAU      := BAU->(IndexOrd())
LOCAL _nVlrAux     := 0
LOCAL nSaldo       := 0
LOCAL nSldGlo      := 0
LOCAL nTotDeb      := 0
LOCAL nTotCre      := 0
LOCAL nTotal       := 0
LOCAL cUso			:= ''
LOCAL lPFCoop		:= .f.
LOCAL lINSS192		:= .f.
LOCAL lINSS182		:= .f.

LOCAL cMVPLSRDAG   := getNewPar("MV_PLSRDAG","999999")

LOCAL cSQL
LOCAL aRetPad      := {.F.,{},{},{},{},{},{},0,.F.,.F.,0,{},0,0,0} 
LOCAL aRetNiv1     := {}
LOCAL aRetNiv2     := {}
LOCAL aVerbasFol   := {}
LOCAL aResumo      := {0}
Local aSEFIP       := {}

LOCAL cCodPlaAnt
LOCAL cCCAnt
LOCAL cTipUsrAnt
LOCAL nVlrBD7
LOCAL lClaINS      := ( BD7->(FieldPos("BD7_CLAINS")) > 0 )
LOCAL nVlrBD7PFI   := 0
LOCAL nVlrBD7PJI   := 0
LOCAL nVlrBD7JFI   := 0
LOCAL nVlrBD7PHP   := 0
LOCAL nVlrCreDIF   := 0
LOCAL nVlrDebDIF   := 0

// Inserido tratamento com base no campo BBB_TIPOCT para adequar o tratamento a apuracao da base do INSS
// essa variacao ocorre em funcao do responsavel financeiro, nao em funcao do contrato ou do prestador
Local nVlrBGQPFI	:= 0
Local nVlrBGQPJI	:= 0
Local nVlrBGQJFI	:= 0

Local aUsDif       := {}
Local cCodEmpAnt
Local cMatricAnt
Local nIndSEFIP
Local nInd
Local aVrPgtDiv    := {}
Local cOriLan
Local cCod170
Local lCposVld	:= (BBC->(FieldPos("BBC_VLDINI")) > 0 .And. BBC->(FieldPos("BBC_VLDFIM")) > 0)
Local cCdIRRet := GetNewPar("MV_PLCIRRT","")
Local nVrIRRet := 0
LOCAL nVlrRefTde := 0	//Odontologico
Local aRetAux  	:= {}
Local lTemImp  	:= .F.
Local lGeraL   	:= .F.
Local lTemMvt  	:= .F.
Local aRecBD6  	:= {}
Local lPagRda  	:= GetNewPar("MV_PLPGRDA","0") == "1" //Incrementa na base do imposto, guias pagas diretamente na Rda
Local nVlrBD6Ato := 0  
Local nX,nStr    := 0
Local nTot       := 0
Local nTotC      := 0
Local nTotD      := 0
Local aStruBD7 	:= BD7->(DbStruct())
Local cChaveGui	:= ""
Local cChaveCab	:= ""
Local nCntFor  	:= ""
Local cRefReg	:=""
Local n			:= 0
LOCAL lObrPto  	:= .F.
LOCAL nVlrGlo  	:= 0   
LOCAL nVlrTx   	:= 0
LOCAL nVlrSer  	:= 0
LOCAL cRecBCI	:= 0
LOCAL cProcDe  	:= MV_PAR33
LOCAL cProcAte 	:= MV_PAR34
LOCAL cCdPeg	:= ""
LOCAL lAtuGlo	:= .F.
LOCAL aArea		:= GetArea()

Local lBD7_VLTXPG 	:= BD7->(FieldPos("BD7_VLTXPG")) > 0
Local lBD7_VLADSE 	:= BD7->(FieldPos("BD7_VLADSE")) > 0
Local lBD7_USDIF  	:= BD7->(FieldPos("BD7_USDIF"))  > 0
Local lBD7_VLRDIF 	:= BD7->(FieldPos("BD7_VLRDIF")) > 0
Local lBD7_TPUSDF 	:= BD7->(FieldPos("BD7_TPUSDF")) > 0 
Local lBBB_INCISS 	:= BBB->(FieldPos("BBB_INCISS")) > 0
Local lBGQ_INCISS 	:= BGQ->(FieldPos("BGQ_INCISS")) > 0
Local lBCE_INCISS 	:= BCE->(FieldPos("BCE_INCISS")) > 0
Local lBGQ_ATIVO  	:= BGQ->(FieldPos("BGQ_ATIVO")) > 0
Local lBBB_TIPOCT 	:= BBB->(FieldPos("BBB_TIPOCT")) > 0
Local aBaseDif    	:= {0,0,0,0}//{PF,PJ,FL,HP} - para quando for diferenciar as bases de inss e gerar mais de um titulo por lote de pagamento para o prestador
Local cProduto	 	:= ''
Local cTes		    	:= ''
LOCAL nVlrDescNf 		:= 0
LOCAL lPLMPACTA 		:= Existblock("PLMPACTA")        
LOCAL lVlrGlo 		:= (Type("nValorGlo")<>"U" .and. nValorGlo > 0)
LOCAL lPLPAGBD7		:= Existblock("PLPAGBD7")
LOCAL lPLMPALAN 		:= Existblock("PLMPALAN")
LOCAL lPLSPAG01      := ExistBlock("PLSPAG01")
Local lstaTiSS		:= GETNEWPAR("MV_STATISS",.F.)

DEFAULT aLancPagto := {}
DEFAULT cCalcImp   	:= BAU->BAU_CALIMP
DEFAULT cCdEmpDeS  	:= ""
DEFAULT cCdEmpAteS 	:= ""
DEFAULT cExcessao  	:= ""
DEFAULT cLoteImp   	:= ""
DEFAULT cCodDC     	:= ""
DEFAULT lCalcImp   	:= .F.
DEFAULT cCodNat    	:= ""
DEFAULT lGuiCob    	:= .F.
DEFAULT lPgtDiv    	:= .F.
DEFAULT lGerLot    	:= .F.
DEFAULT lMudUs     	:= .F.
DEFAULT nNeWUs     	:= 0
DEFAULT nApUsDif   	:= 2
DEFAULT lAtuGui	   	:= .F.
DEFAULT cOpeLote   	:= ""
DEFAULT cLote	   	:= ""
DEFAULT cExcPeg	   	:= ""
DEFAULT cNoExcPeg	:= "" // Variavel criada para trazer somente as PEG´s não selecionadas. para tratamento de estouro em BD #CAIO MACIENTE
DEFAULT dVencto	   	:= StoD("")                           
DEFAULT cTipTitInt 	:= "2"  //Indica o tipo de fatura de intercambio: 1-NDC / 2-Fatura /3-Ambos
DEFAULT nPosTitInt 	:= 1   //Indica qual titulo de intercambio esta sendo gerado. '2' corresponde ao segundo tit de intercambio e nao considera os debitos e creditos                       
DEFAULT cLocDigIn 	:= ""
DEFAULT cLocDigFi 	:= "" 
DEFAULT cCodOpe 	:= PlsIntPad()
DEFAULT lAneste 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for a rda generica nao traz valor...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMVPLSRDAG == cCodRDA
	Return(aRetPad)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao veio a matriz de lancamentos de faturamento ele deve ser criada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aLancPagto) == 0
	PLSMONLPGT(aLancPagto,PLSINTPAD())
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se esta posicionado o BAU...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BAU->BAU_CODIGO <> cCodRDA
	BAU->(DbSetOrder(1))
	BAU->(DbSeek(xFilial("BAU")+cCodRDA,.F.))
	BAU->(DbSetOrder(nOrdBAU))
Endif
If !Empty(IIf(BAU->(FieldPos("BAU_BASINS")) > 0, BAU->BAU_BASINS, ""))
	If  BAU->BAU_TIPPE == "F" .and. BAU->BAU_BASINS == "0" // 0=Nao;1=Sim ==> Tipo Pessoa Fisica e Divide a Base do INSS (Base Unificada: 0 - Nao)
		lINSS192 := .T.
	Else
		lINSS182 := .T.
	EndIf
Else
	lINSS182 := .T.
EndIf
lPFCoop := IIF(BAU->BAU_TIPPE == "F" .and. BAU->BAU_COPCRE=='1', .T., .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata a obrigatoriedade de gerar protocolo web ou não.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lObrPto := PLSOBRPRDA() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua for para navegar por todos os lancamentos...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFor := 1 To Len(aLancPagto)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta variaveis para o lancamento de pagto atual...                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOpeLan := aLancPagto[nFor,1]
	cCodLan := aLancPagto[nFor,2]+aLancPagto[nFor,3]
	cDesLan := aLancPagto[nFor,4]
	cDebCre := aLancPagto[nFor,6]
	cImgTree:= aLancPagto[nFor,7]
	aPropri := aLancPagto[nFor,9]
	cVerba  := aLancPagto[nFor,10]
	cUso    := aLancPagto[nFor,11]

	If cCalcImp $ '1'
	
		cProduto:= aLancPagto[nFor,12]    
		cTes	:= aLancPagto[nFor,13]    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ@¿
		//³Busco a TES na tabela BLS caso exita os lançamentos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ@Ù		
		If Len(aLancPagto[nFor,9])>0 
			
			cRefReg := iIf(BAU->BAU_TIPPE == 'F',"1","2")
			
			For n := 1 to Len(aLancPagto[nFor,9])
				
				If aLancPagto[nFor,9,n,1]= cRefReg
					cTes:= aLancPagto[nFor,9,n,10]    
				Endif
				
			Next n
			
		Endif
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa se lancamento eh valido para esse tipo de integracao (pls ou folha)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! (cUso $ "3, " .Or. cUso == cCalcImp .Or. (cUso == "1" .and. cCalcImp $ "3,4")) .And. BAU->BAU_CALIMP == '3' 
		Loop
	Endif
	
	//cada lancamento deve atualizar essa variavel com o total
	nSaldo  := 0 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 101 --<<<<< Producao Medica                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "101" .And. BAU->BAU_PAGPRO <> "0" //Campo na RDA (BAU_PAGPRO). Pagar Producao S/N
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca o valor da movimentacao...                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cSQL := "SELECT "

		cSQL += " BD7_CODPLA, BD7_CC, BD7_TIPUSR, BD7_CODEMP, BD7_MATRIC, BD7_VLRPAG,BD7_VLRGLO,BD7_REFTDE, BD7.R_E_C_N_O_ RECBD7, BD7_ANOPAG, BD7_MESPAG "

		If lBD7_VLADSE .And. lBD7_VLTXPG
        	cSQL += " ,BD7_VLADSE, BD7_VLTXPG "
        EndIf
        
		If lClaINS
			cSQL += " , BD7_CLAINS "
		Endif
		
		//Indica se o tratamento odontologico esta ativo no ambiente Plano de Saude.
		If GetNewPar("MV_PLATIOD","0") == '1'	.And. BD7->(FieldPos("BD7_USDIF"))  > 0 .And. BD7->(FieldPos("BD7_TPUSDF"))  > 0 .And. BD7->(FieldPos("BD7_VLRDIF")) > 0
			
			cSQL += " , BD7_VLRDIF, BD7_TPUSDF "
			
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para incrementar na base do imposto, guias pagas diretamente na Rda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPagRda
			cSQL += ", BD6_PAGRDA ,BD6_VRPRDA, BD6.R_E_C_N_O_ BD6REC "
		EndIf
		
		If lPgtDiv
			cSQL += ", BD6_CODTAB, BD6_CODPAD, BD6_CODPRO "
		EndIf
		
	  	cSQL += " FROM " + RetSQLName("BD7") + " BD7, " + RetSQLName("BCI") + " BCI "
	  	
	  	If  lGuiCob  .Or. lPgtDiv .Or. lPagRda // pagar somente guias ja cobradas
			cSQL += ", " + RetSQLName("BD6") + " BD6"
	  	Endif
      
      	cSQL += " WHERE ( BD7_FILIAL =  '" + xFilial("BD7") + "' ) AND "
      	cSQL +=       " ( BD7_CODOPE =  '" + cCodOpe+"' ) AND " 
	  	cSQL +=       " ( BD7_CODLDP >= '" + cLocDigIn+"' AND BD7_CODLDP <= '"+cLocDigFi+"' ) AND "
	  	
	  	If lObrPto
	  	   cSQL +=       " ( BD7_CODLDP <> '" + PLSRETLDP(9) + "' ) AND "
	  	Endif
	  	
	  	cSQL +=       " ( BD7_CODLDP <> '" + PLSRETLDP(4) + "' ) AND "   
      	
      	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para trazer o saldo posicionado por processo							  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	//Inicio
      	If BCI->(FieldPos("BCI_PROCES")) > 0
	      	
	      	If !Empty(cProcDe/*MV_PAR33*/) .or. !EMPTY(cProcAte/*MV_PAR34*/)
				
				If EMPTY(cProcDe) .OR. ISALPHA(cProcAte)
					cSQL2 := "select MIN(BCI_PROCES) AS PRCMEN, MAX(BCI_PROCES) AS PRCMAI "
					cSQL2 += "FROM " + RetSQLName("BCI")
					cSQL2 += " WHERE BCI_PROCES <> '' AND D_E_L_E_T_ = ''"
					
					cSQL2 := ChangeQuery(cSQL2)
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL2),"TrbBCI",.F.,.T.)
					
					If !EMPTY(TRBBCI->PRCMEN)
						If EMPTY(cProcDe) 
							cProcDe := TRBBCI->PRCMEN
						EndIf
					EndIf
	
					If ISALPHA(cProcAte)
						cProcAte := TRBBCI->PRCMAI
					EndIf 
					
					TrbBCI->(DbCloseArea())
				EndIf
								
	      		BCI->(dbSetOrder(13))
	      		If BCI->(dbSeek(xFilial("BCI")+cCodOpe+cProcDe))
	      			
	      			If !EMPTY(cProcDe) .AND. !EMPTY(cProcAte)
	      			
		     			While BCI->BCI_PROCES >= cProcDe .AND. BCI->BCI_PROCES <= cProcAte 
		      				
		      				IF BCI->BCI_CODRDA == cCodRDA
			      				
			      				cRecBCI	:= BCI->(Recno())
			      				BCI->(dbSkip())
			      				
			      				If BCI->BCI_CODRDA == cCodRDA
				      				BCI->(DbGoTo(cRecBCI))
				      				cCdPeg += BCI->BCI_CODPEG + ", "
			      				Else
				      				BCI->(DbGoTo(cRecBCI))
				      				cCdPeg += BCI->BCI_CODPEG
			      				EndIf
		    				EndIf
		      				
		      				BCI->(dbSkip())
		      			EndDo
		      			
		      			cSQL += " BD7_CODPEG IN(" + cCdPeg + ") AND " 
		      			
	      			EndIf
	      			
	      		EndIf
	      	Else 
      			cSQL +=       " ( BD7_CODPEG >= '" + cCodPegIn+"' AND BD7_CODPEG <= '"+cCodPegFi+"' ) AND "
	      	EndIf
      	Else
      		cSQL +=       " ( BD7_CODPEG >= '" + cCodPegIn+"' AND BD7_CODPEG <= '"+cCodPegFi+"' ) AND "
      	EndIf

      	cSQL +=       " ( BD7_NUMERO >= '" + cNumMovIn+"' AND BD7_NUMERO <= '"+cNumMovFi+"' ) AND "
	  
		If !Empty(cCdEmpDeS) .or. !Empty(cCdEmpAteS)
			cSQL += " ( BD7_CODEMP >= '"+cCdEmpDeS+"' AND BD7_CODEMP <= '"+cCdEmpAteS+"' ) AND "
		Endif
		
		If ! Empty(cExcessao)
			cSQL += "( NOT BD7_CODEMP IN "+MontaExpFil(cExcessao,4)+" ) AND "
		Endif
		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Tratamento para verificar as PEG não selecionadas e selecionadas para o tratamento na montagem da QUERY
		// a quantidade maior sai da query entrando a menor para não dar erro na execução da query.
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If Len(cNoExcPeg) > Len(cExcPeg) .AND. !empty(cExcPeg)
			cSQL += "( NOT BD7_CODPEG IN " + FormatIn(cExcPeg,",")+ " ) AND "
		ElseIf !empty(cNoExcPeg)
			cSQL += "( NOT BD7_CODPEG NOT IN " + FormatIn(cNoExcPeg,",") + " ) AND "
		Endif
	
  		cSQL += " ( BD7_SITUAC = '1' )  AND "

     	// item acima foi comentado devido que quando tiramos o saldo posicionado ainda não temo o numero do lote e quando geramos o lote nos temos o numero do lote em todo o BD7 ainda ele esta gravando  EBD7_FASE = '4'  ja sao eventos faturados.
        cSQL += " (BD7_FASE = '3' OR (BD7_FASE = '4' AND BD7_OPELOT = ''  AND BD7_NUMLOT = '') )  AND "
      
      	cSQL += " ( BD7_BLOPAG <> '1' ) AND "
      
      	If !(Empty(dDatMvIni) .And. Empty(dDatMvFin))
       		cSQL += " ( BD7_DATPRO >= '"+dtos(dDatMvIni)+"' AND BD7_DATPRO <= '"+dtos(dDatMvFin)+"' ) AND "
      	Endif 

		cSQL += " ( BD7_CODRDA = '"+cCodRDA+"' ) AND "

  		// Otimizacao oracle para usar indices
		cSQL += " ( BD7_ANOPAG < '"+cAno+"' OR (BD7_ANOPAG = '"+cAno+"' AND BD7_MESPAG  <= '"+cMes+"' ) ) AND "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao generica que trata campos do estorno		   					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FindFunction("PlReChvEst")
			aRetAux  := PlReChvEst("BD7",.F.,.T.,.F.,.T.)
			cSQL     += aRetAux[1]
		Endif
		
		cSQL += " BD7.D_E_L_E_T_ = ' ' "
		
		If  lGuiCob .Or. lPgtDiv .Or. lPagRda// pagar somente guias ja cobradas
			cSQL += " AND BD7_FILIAL = BD6_FILIAL "
			cSQL += " AND BD7_CODOPE = BD6_CODOPE "
			cSQL += " AND BD7_CODLDP = BD6_CODLDP "
			cSQL += " AND BD7_CODPEG = BD6_CODPEG "
			cSQL += " AND BD7_NUMERO = BD6_NUMERO "
			cSQL += " AND BD7_ORIMOV = BD6_ORIMOV "
			cSQL += " AND BD7_SEQUEN = BD6_SEQUEN "
			cSQL += " AND BD6.D_E_L_E_T_ = ' ' "
			
			If lGuiCob
				cSQL += " AND BD6_PREFIX <> '"+Space(TamSx3("BD6_PREFIX")[1])+"' "
				cSQL += " AND BD6_NUMTIT <> '"+Space(TamSx3("BD6_NUMTIT")[1])+"' "
				cSQL += " AND BD6_PARCEL <> '"+Space(TamSx3("BD6_PARCEL")[1])+"' "
				cSQL += " AND BD6_TIPTIT <> '"+Space(TamSx3("BD6_TIPTIT")[1])+"' "
			EndIf
			
		Endif
		
		cSQL += " AND BCI.BCI_FILIAL = '" + xFilial("BCI") + "' "
		cSQL += " AND BCI.BCI_CODOPE = BD7.BD7_CODOPE "
		cSQL += " AND BCI.BCI_CODLDP = BD7.BD7_CODLDP "
		cSQL += " AND BCI.BCI_CODPEG = BD7.BD7_CODPEG "	
		cSql += " AND BCI.D_E_L_E_T_ = ' ' "
		If lstaTiSS
			cSQL += " AND BCI_STTISS = '3' "
		EndIf	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somente pega as guias de um determinado lote de importacao		  	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BD7->(FieldPos("BD7_SEQIMP")) > 0
			If !Empty(cLoteImp) .Or. GetNewPar("MV_PLFTGLI", .T.)
				cSQL += "AND BD7_SEQIMP = '"+cLoteImp+"'  "
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Novo Ponto de entrada de Filtro para Cliente 						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPLMPACTA
			cSQL += Execblock("PLMPACTA",.f.,.f.,{})
		Endif
		
		cSQL += "ORDER BY BD7_CODPLA, BD7_CC, BD7_TIPUSR, BD7_CODEMP, BD7_MATRIC "
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acessa a BD...                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
		
		For nCntFor := 1 To Len(aStruBD7)
			If ( aStruBD7[nCntFor,2]<>"C" )
				TcSetField("TrbMPG",aStruBD7[nCntFor,1],aStruBD7[nCntFor,2],aStruBD7[nCntFor,3],aStruBD7[nCntFor,4])
			EndIf
		Next nCntFor
		
		//Verifica se inclui recursos de glosa
		If lVlrGlo
			lAtuGlo := .T.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Le todo o resultado para acumular valores...                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While ! TrbMPG->(Eof())
		
			If TrbMPG->(BD7_ANOPAG+BD7_MESPAG) >  cAno + cMes
				TrbMPG->(DbSkip())
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula BD7 arredondando o valor em cada registro lido              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodPlaAnt := TrbMPG->BD7_CODPLA
			cCCAnt     := TrbMPG->BD7_CC
			cTipUsrAnt := TrbMPG->BD7_TIPUSR
			cCodEmpAnt := TrbMPG->BD7_CODEMP
			cMatricAnt := TrbMPG->BD7_MATRIC
			nVlrBD7    := 0
			nSldGlo    := 0
			nVlrBD6Ato := 0
			nVlrBD7PFI := 0
			nVlrBD7PJI := 0
			nVlrBD7JFI := 0
			nVlrBD7PHP := 0
			
			While ! TrbMPG->(Eof()) .and. TrbMPG->BD7_CODPLA == cCodPlaAnt .and.;
					TrbMPG->BD7_CC     == cCCAnt     .and. TrbMPG->BD7_TIPUSR == cTipUsrAnt .and.;
					TrbMPG->BD7_CODEMP == cCodEmpAnt .and. TrbMPG->BD7_MATRIC == cMatricAnt
				
				//tem que ter esta validacao novamente pois a validacao do primeiro while so checa a primeira linha.
				If TrbMPG->(BD7_ANOPAG+BD7_MESPAG) > cAno + cMes
					TrbMPG->(DbSkip())
					Loop
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alteracao na logica do sistema.                               ³
				//³Se nao obtiver a classificacao correta, optara por classificar³
				//³em Pessoa Fisica, onde ha maior retencao de imposto, porem    ³
				//³nao compromete a empresa por sonegacao. RC - 20100415.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  		If lClaINS .and. !Empty(TrbMPG->BD7_CLAINS)    
		  		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pessoa Juridica                                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					If TrbMPG->BD7_CLAINS == "2" .or. BAU->BAU_BASINS == '1'
					    
					    If cTipTitInt == "3"
							Iif(nPosTitInt == 1,nVlrBD7PJI += (round(TrbMPG->BD7_VLRPAG,2) -  round(TrbMPG->BD7_VLADSE,2)),nVlrBD7PJI += round(TrbMPG->BD7_VLADSE,2))
						Else   
							nVlrBD7PJI += round(TrbMPG->BD7_VLRPAG,2) 
						EndIf
						cTipUsrAnt := "2"
						aBaseDif[2] += round(TrbMPG->BD7_VLRPAG,2)
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pessoa Juridica Filantropica                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					ElseIf TrbMPG->BD7_CLAINS == "3"
									
						If cTipTitInt == "3"
							Iif(nPosTitInt == 1,nVlrBD7JFI += (round(TrbMPG->BD7_VLRPAG,2) -  round(TrbMPG->BD7_VLADSE,2)),nVlrBD7JFI += round(TrbMPG->BD7_VLADSE,2) )	
						Else 
							nVlrBD7JFI += round(TrbMPG->BD7_VLRPAG,2) 
						EndIf
						cTipUsrAnt := "3"
						aBaseDif[3] += round(TrbMPG->BD7_VLRPAG,2)
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Honorario Patronal                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					ElseIf TrbMPG->BD7_CLAINS == "4"
								
						If cTipTitInt == "3"
							Iif(nPosTitInt == 1,nVlrBD7PHP += (round(TrbMPG->BD7_VLRPAG,2) -  round(TrbMPG->BD7_VLADSE,2)),nVlrBD7PHP += round(TrbMPG->BD7_VLADSE,2) )
						Else
							nVlrBD7PHP += round(TrbMPG->BD7_VLRPAG,2)
						EndIf
						cTipUsrAnt := "4"
						aBaseDif[4] += round(TrbMPG->BD7_VLRPAG,2)
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pessoa Física                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					Else
			
						If cTipTitInt == "3"  
							Iif(nPosTitInt == 1,nVlrBD7PFI += (round(TrbMPG->BD7_VLRPAG,2) -  round(TrbMPG->BD7_VLADSE,2)),nVlrBD7PFI += round(TrbMPG->BD7_VLADSE,2))	
						Else
							nVlrBD7PFI += round(TrbMPG->BD7_VLRPAG,2)
						EndIf
						
						cTipUsrAnt := "1"
						aBaseDif[1] += round(TrbMPG->BD7_VLRPAG,2)
						
					Endif
					
				Else 
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pessoa Juridica                                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					If TrbMPG->BD7_TIPUSR == "2" .or. BAU->BAU_BASINS == '1'
			
						If cTipTitInt == "3"  
							Iif(nPosTitInt == 1,nVlrBD7PJI += (round(TrbMPG->BD7_VLRPAG,2) -  round(TrbMPG->BD7_VLADSE,2)),nVlrBD7PJI += round(TrbMPG->BD7_VLADSE,2))
						Else  
							nVlrBD7PJI += round(TrbMPG->BD7_VLRPAG,2)
						EndIf
						cTipUsrAnt := "2"  
						aBaseDif[2] += round(TrbMPG->BD7_VLRPAG,2)
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pessoa Juridica Filantropica                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					ElseIf TrbMPG->BD7_TIPUSR == "3"
					   
						If cTipTitInt == "3" 
							Iif(nPosTitInt == 1,nVlrBD7JFI += (round(TrbMPG->BD7_VLRPAG,2) -  round(TrbMPG->BD7_VLADSE,2)),nVlrBD7JFI += round(TrbMPG->BD7_VLADSE,2) )
						Else  
							nVlrBD7JFI += round(TrbMPG->BD7_VLRPAG,2) 
						EndIf 
						cTipUsrAnt := "3"
						aBaseDif[3] += round(TrbMPG->BD7_VLRPAG,2)
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Honorario Patronal                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					ElseIf TrbMPG->BD7_TIPUSR == "4"
								
						If cTipTitInt == "3"
							Iif(nPosTitInt == 1,nVlrBD7PHP += (round(TrbMPG->BD7_VLRPAG,2) -  round(TrbMPG->BD7_VLADSE,2)),nVlrBD7PHP += round(TrbMPG->BD7_VLADSE,2) )
						Else
							nVlrBD7PHP += round(TrbMPG->BD7_VLRPAG,2)
						EndIf
						
						cTipUsrAnt := "4"
						aBaseDif[4] += round(TrbMPG->BD7_VLRPAG,2)
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pessoa Física                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					Else
					 
						If cTipTitInt == "3"
							Iif(nPosTitInt == 1,nVlrBD7PFI += (round(TrbMPG->BD7_VLRPAG,2) - round(TrbMPG->BD7_VLADSE,2)),nVlrBD7PFI += round(TrbMPG->BD7_VLADSE,2))
						Else
							nVlrBD7PFI += round(TrbMPG->BD7_VLRPAG,2)
						EndIf
						
						cTipUsrAnt := "1"
						aBaseDif[1] += round(TrbMPG->BD7_VLRPAG,2)
						
					Endif
					
				Endif    
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma valores, se for intercambio A500 tipo 3-Ambos, diferencia servicos e taxas     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cTipTitInt == "3"
					iIf(nPosTitInt == 1, nVlrBD7 += round(TrbMPG->BD7_VLRPAG,2), nVlrSer += round(TrbMPG->BD7_VLADSE,2))					
				Else
					nVlrBD7 += round(TrbMPG->BD7_VLRPAG,2) 
				EndIf  
					 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se for lote de intercambio 3-Ambos, separa Glosas de Servico e Taxas                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cTipTitInt $ "1-2" .or. !(lBD7_VLTXPG .And. lBD7_VLADSE)
				
					// Se for Tipo 1-2 ou não tiver os novos campos, trata o tipo 3 como tipo 2.
					nVlrGlo += round(TrbMPG->BD7_VLRGLO,2) 	
					nSldGlo += round(TrbMPG->BD7_VLRGLO,2)
					
					// Mandará a variável nVlrSer para o BAF_VLRGLO
					nVlrSer += round(TrbMPG->BD7_VLRGLO,2) 	
					
				Else
				
					// Se for Tipo 3 e tem os campos
					// Titulo de Serviços	-> cTipTitInt = 3 e nPosTitInt = 1 
					If nPosTitInt == 1		
					
						// Valor da Glosa é igual a glosa menos ADSE glosada ( adicional de servico apresentado _VLADSE menos pago _VLTXPG )
						nVlrGlo += round(TrbMPG->BD7_VLRGLO,2) 
						nSldGlo += round(TrbMPG->BD7_VLRGLO,2)
						
						// Mandará a variável nVlrSer para o BAF_VLRGLO e nVlrTx para o BAF_VLTXGL
						nVlrSer += round(TrbMPG->BD7_VLRGLO,2) - ((round(TrbMPG->BD7_VLADSE,2) - round(TrbMPG->BD7_VLTXPG,2)))
						nVlrTx  += (round(TrbMPG->BD7_VLADSE,2) - round(TrbMPG->BD7_VLTXPG,2))
						
					// Titulo de Taxas		-> cTipTitInt = 3 e nPosTitInt = 2
					Else							
						// Valor de Taxas pago _VLTXPG
						nVlrTx  += round(TrbMPG->BD7_VLTXPG,2)
						
					EndIf	
					
				EndIf	

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acumula o valor da REFTDE pra odontologico...                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If GetNewPar("MV_PLATIOD","0") == '1' //Indica se o tratamento odontologico esta ativo no ambiente Plano de Saude.
					nVlrRefTde += round(TrbMPG->BD7_REFTDE,2)
				EndIf
				
				If lPgtDiv
					
					nInd := aScan(aVrPgtDiv, { |x| x[1]+x[2]+x[3] == TrbMPG->BD6_CODTAB + TrbMPG->BD6_CODPAD + TrbMPG->BD6_CODPRO })
					
					If nInd == 0
						aAdd(aVrPgtDiv, { TrbMPG->BD6_CODTAB, TrbMPG->BD6_CODPAD, TrbMPG->BD6_CODPRO, 0, "101" })
						nInd := Len(aVrPgtDiv)
					EndIf
					
					aVrPgtDiv[nInd, 4] += round(TrbMPG->BD7_VLRPAG,2)
					
				EndIf
				
				//Indica se o tratamento odontologico esta ativo no ambiente Plano de Saude.
				If 	lBD7_USDIF .And. lBD7_VLRDIF .And. lBD7_TPUSDF .And. nApUsDif == 1 .AND. GetNewPar("MV_PLATIOD","0") == '1'
					
					If TrbMPG->BD7_TPUSDF = "1"
						nVlrDebdif += round(TrbMPG->BD7_VLRPAG - TrbMPG->BD7_VLRDIF,2)
					ElseIf TrbMPG->BD7_TPUSDF = "2"
						nVlrCredif += round(TrbMPG->BD7_VLRDIF - TrbMPG->BD7_VLRPAG,2)
					EndIf
					
				EndIf
				
				lAtuGui := !Empty(cLoteImp)
				
				If (lAtuGui .Or. lAtuGlo) .And. (!Empty(cLote) .And. !Empty(cOpeLote))
				
					BD7->(DbGoTo(TrbMPG->RECBD7))
				
					cChaveGui := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)
					cChaveCab := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
					
					BD7->(RecLock("BD7",.F.))
					BD7->BD7_NUMLOT := cLote
					BD7->BD7_OPELOT := cOpeLote
					BD7->BD7_FASE   := "4"
					BD7->BD7_DTGRCP := dVencto
					BD7->BD7_DTPAGT := dDataBase
					BD7->(MsUnLock())
					
					If lPLPAGBD7
						Execblock("PLPAGBD7",.F.,.F.,{cChaveGui})
					Endif
					
					AtualizaGuiaPagto("1",cChaveGui,cLote,cOpeLote,nil,cChaveCab)
					
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se houve co-participacao paga diretamente na Rda para  ³
				//³ incrementar a base de impostos                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPagRda
					If Ascan(aRecBD6,{|x| x[1] == TrbMPG->BD6REC}) == 0
						Aadd(aRecBD6,{TrbMPG->BD6REC})
						nVlrBD6Ato += IIf(TrbMPG->BD6_PAGRDA == "1",round(TrbMPG->BD6_VRPRDA,2),0)
					EndIf
				EndIf
				
			TrbMPG->(DbSkip())
			Enddo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula o saldo desse lancamento...                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nSaldo  += nVlrBD7
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Para cada linha do resultado analisa se sera base dos impostos...   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRetProPri := AnalisaImp(cCalcImp,cTipUsrAnt,aPropri,nVlrBD7 + IIf(cTipTitInt $ "1-2",nSldGlo,0),;
									@nVlrB_IR,@nVlrB_INPF,@nVlrB_INPJ,@nVlrB_INJF,@nVlrB_PIS,@nVlrB_COF,@nVlrB_CSL,;
									aVerbasFol,nVlrBD7PFI,nVlrBD7PJI,nVlrBD7JFI,cCodEmpAnt,cMatricAnt,@aSEFIP,;
									@nVlrB_ISS,lPagRda,nVlrBD6Ato,@nVlrB_INHP,@nVlrBD7PHP)
									
			nInd := aScan(aRetNiv2, { |x| x[3]+x[4]+x[5] == cCodLan + cCodPlaAnt + cCCAnt })
			
			If nInd == 0
			
				aadd(aRetNiv2,{	cDebCre,;
								nVlrBD7,;
								cCodLan,;
								cCodPlaAnt,;
								cCCAnt,;
								"",;
								"BD7",;
								cProduto,;
								cTes})
								
			Else
				aRetNiv2[nInd, 2] += nVlrBD7
			EndIf
			
		endDo
		TrbMPG->(DbCloseArea())
		
		//Inclui no vetor Composicao de Pagamento                             
		If !empty(cLoteImp) .And. nVlrSer + nVlrTx + nVlrGlo > 0
			lTemMvt := .T.
		EndIf 
		
		If nSaldo > 0
			
			lTemMvt := .T.
			nInd 	:= aScan(aRetNiv1, { |x| x[1]+x[3]+x[4] == cDebCre + cCodLan + cDesLan })
			
			If nInd == 0
			
					aadd(aRetNiv1,{	cDebCre,;
									nSaldo,;
									cCodLan,;
									cDesLan,;
									cImgTree})
			Else
				aRetNiv1[nInd, 2] += nSaldo
			EndIf
			
		Endif
		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 102     --<<<<< Debitos mensais fixos          ³
	//³                                                                     ³
	//³ Para pagar uma unica vez no mes ele testa se se2 do ano/mes ja exist³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan $ "102" .And. lBBB_TIPOCT  
		
		cSQL := "SELECT BBC_CC AS CC, BBC_CODSER AS CODSER, BBC_VALOR, BBC_QTDCH, BBC_NROPGT "
		cSQL += " FROM "+RetSQLName("BBC")+" WHERE "
		cSQL += " ( BBC_FILIAL = '"+xFilial("BBC")+"' ) AND "
		cSQL += " ( BBC_CODIGO = '"+cCodRDA+"' ) AND "
		cSQL += " ( BBC_PROMED = '1' ) AND "
		cSQL += " ( BBC_STATUS = '1' ) AND "
		cSQL += " ( BBC_DEBCRE = '1' ) AND "		// Débitos
		If lCposVld // BOPS 98697
			cSQL += " ( '" + cAno + cMes + "01' >= BBC_VLDINI ) AND "
			cSQL += " ( ( '" + DtoS(LastDay(CtoD("01/"+cMes+"/"+cAno))) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
		EndIf
		cSQL += " ( D_E_L_E_T_ = ' ' ) "
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
		TCSETFIELD("TrbMPG","BBC_VALOR","N",nVlPrec,nVlDec)
		TcSetField("TrbMPG","BBC_QTDCH","N",nVlPrec,nVlDec)
		
		nTotDeb := 0
		BBB->(DbSetOrder(1))
		While ! TrbMPG->(Eof())
			If  ! empty(cCodDC) .and. ! TrbMPG->CODSER $ cCodDC
				TrbMPG->(DbSkip())
				Loop
			Endif

			If ! PLMOVCRE(BAU->BAU_CODIGO,cAno,cMes,,IIf(Empty(TrbMPG->BBC_NROPGT),"0",TrbMPG->BBC_NROPGT),"102",cCodOpe,cOpeLote)
				TrbMPG->(DbSkip())
				Loop
			EndIf
			
			_nVlrAux := 0
			If TrbMPG->BBC_VALOR > 0 //Lancado em Reais
				_nVlrAux := TrbMPG->BBC_VALOR
			ElseIf TrbMPG->BBC_QTDCH > 0 //Lancado em Qtd de CH
				//Estou criando esse M->BBC_QTDCH para reaproveitar a funcao PLSA755QTD que pega o valor baseado na qtd de ch
				M->BBC_QTDCH := 0
				PLSA755Qtd(cCodOpe,TrbMPG->BBC_QTDCH,cAno,cMes,cCodRDA,"M->BBC_QTDCH")
				_nVlrAux := M->BBC_QTDCH
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apuracao das bases dos impostos...                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BBB->(DbSeek(xFilial("BBB")+TrbMPG->CODSER,.F.))
			If  BBB->BBB_INCINS == "1" .AND. BAU->BAU_TIPPE == "F"
				nIndSEFIP := fIndSEFIP("", "", "", "", cCalcImp, @aSEFIP)
				If BAU->BAU_BASINS == '1' .or. BBB->BBB_TIPOCT == "2"
					nVlrB_INPJ -= _nVlrAux
					aSEFIP[nIndSEFIP, 7] -= _nVlrAux
				Else
					If BBB->BBB_TIPOCT == "3"
						nVlrB_INJF -= _nVlrAux
						aSEFIP[nIndSEFIP, 8] -= _nVlrAux
					ElseIf BBB->BBB_TIPOCT == "1"
						nVlrB_INPF -= _nVlrAux
						aSEFIP[nIndSEFIP, 6] -= _nVlrAux
					Else
						nVlrB_INHP -= _nVlrAux
						aSEFIP[nIndSEFIP, 9] -= _nVlrAux
					Endif
				EndIf
			Endif
			
			nVlrB_IR  -= IIf( BBB->BBB_INCIR == "1",  _nVlrAux, 0 )
			nVlrB_PIS -= IIf( BBB->BBB_INCPIS == "1", _nVlrAux, 0 )
			nVlrB_COF -= IIf( BBB->BBB_INCCOF == "1", _nVlrAux, 0 )
			nVlrB_CSL -= IIf( BBB->BBB_INCCSL == "1", _nVlrAux, 0 )
			nVlrB_ISS -= IIf( lBBB_INCISS .And. BBB->BBB_INCISS == "1", _nVlrAux, 0 )
			
			nTotDeb += _nVlrAux
			nSaldo  -= _nVlrAux
			
			If ! Empty(BBB->BBB_VERBA)
				cVerba := BBB->BBB_VERBA
				AnalisaVerbas(BBB->BBB_VERBA,aVerbasFol,_nVlrAux)
			Endif
			
			aadd(aRetNiv2,{	cDebCre,;
							_nVlrAux,;
							cCodLan,;
							"",;
							TrbMPG->CC,;
							TrbMPG->CODSER,;
							"BBC",;
							cProduto,;
							cTes})
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para que quando houver creditos para a RDA ³
			//³esses creditos viram desconto no pedido de compra e   ³
			//³na  nota fiscal de entrada                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlrDescNf+=TrbMPG->BBC_VALOR	
			If TrbMPG->CODSER $ cCdIRRet
				nVrIRRet += TrbMPG->BBC_VALOR
			EndIf
	
			TrbMPG->(DbSkip())
		Enddo
		TrbMPG->(DbCloseArea())
		
		If nTotDeb > 0
			lTemMvt := .T.
			aadd(aRetNiv1,{	cDebCre,;
							nTotDeb,;
							cCodLan,;
							cDesLan,;
							cImgTree})
		Endif
		nSaldo  := nTotDeb
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 103     --<<<<< Creditos         mensais fixos ³
	//³                                                                     ³
	//³ Para pagar uma unica vez no mes ele testa se se2 do ano/mes ja exist³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan $ "103" .And. lBBB_TIPOCT
	
		cSQL := "SELECT BBC_CC AS CC, BBC_CODSER AS CODSER, BBC_VALOR, BBC_QTDCH, BBC_NROPGT "
		cSQL += " FROM "+RetSQLName("BBC")+" WHERE "
		cSQL += " ( BBC_FILIAL = '"+xFilial("BBC")+"' ) AND "
		cSQL += " ( BBC_CODIGO = '"+cCodRDA+"' ) AND "
		cSQL += " ( BBC_PROMED = '1' ) AND "
		cSQL += " ( BBC_STATUS = '1' ) AND "
		cSQL += " ( BBC_DEBCRE = '2' ) AND "		// Créditos
		
		If lCposVld // BOPS 98697
			cSQL += " ( '" + cAno + cMes + "01' >= BBC_VLDINI ) AND "
			cSQL += " ( ( '" + DtoS(LastDay(CtoD("01/"+cMes+"/"+cAno))) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
		EndIf
		
		cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
		
		TcSetField("TrbMPG","BBC_VALOR","N",nVlPrec,nVlDec)
		TcSetField("TrbMPG","BBC_QTDCH","N",nVlPrec,nVlDec)
		
		nTotCre := 0
		BBB->(DbSetOrder(1))
		While ! TrbMPG->(Eof())
			
			If  ! empty(cCodDC) .and. ! TrbMPG->CODSER $ cCodDC
				TrbMPG->(DbSkip())
				Loop
			Endif

			If !PLMOVCRE(BAU->BAU_CODIGO,cAno,cMes,,IIf(Empty(TrbMPG->BBC_NROPGT),"0",TrbMPG->BBC_NROPGT),"103",cCodOpe,cOpeLote)
				TrbMPG->(DbSkip())
				Loop
			EndIf
			
			_nVlrAux := 0
			If TrbMPG->BBC_VALOR > 0 //Lancado em Reais
				_nVlrAux := TrbMPG->BBC_VALOR
			ElseIf TrbMPG->BBC_QTDCH > 0 //Lancado em Qtd de CH
				//Estou criando esse M->BBC_QTDCH para reaproveitar a funcao PLSA755QTD que pega o valor baseado na qtd de ch
				M->BBC_QTDCH := 0
				PLSA755Qtd(cCodOpe,TrbMPG->BBC_QTDCH,cAno,cMes,cCodRDA,"M->BBC_QTDCH")
				_nVlrAux := M->BBC_QTDCH
			Endif
			
			BBB->(DbSeek(xFilial("BBB")+TrbMPG->CODSER,.F.))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apuracao das bases dos impostos...                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  BBB->BBB_INCINS == "1" .AND. BAU->BAU_TIPPE == "F"
				nIndSEFIP := fIndSEFIP("", "", "", "", cCalcImp, @aSEFIP)

				If BAU->BAU_BASINS == '1' .or. BBB->BBB_TIPOCT == "2"
					nVlrB_INPJ += _nVlrAux
					aSEFIP[nIndSEFIP, 7] += _nVlrAux
					aBaseDif[2] += _nVlrAux
				Else
					If BBB->BBB_TIPOCT == "3"
						nVlrB_INJF += _nVlrAux
						aSEFIP[nIndSEFIP, 8] += _nVlrAux
						aBaseDif[3] += _nVlrAux
					ElseIf BBB->BBB_TIPOCT == "1"
						nVlrB_INPF += _nVlrAux
						aSEFIP[nIndSEFIP, 6] += _nVlrAux
						aBaseDif[1] += _nVlrAux
					Else
						nVlrB_INHP += _nVlrAux
						aSEFIP[nIndSEFIP, 9] += _nVlrAux
						aBaseDif[4] += _nVlrAux
					Endif
				EndIf
			Endif
			
			nVlrB_IR  += IIf( BBB->BBB_INCIR  == "1", _nVlrAux, 0 )
			nVlrB_PIS += IIf( BBB->BBB_INCPIS == "1", _nVlrAux, 0 )
			nVlrB_COF += IIf( BBB->BBB_INCCOF == "1", _nVlrAux, 0 )
			nVlrB_CSL += IIf( BBB->BBB_INCCSL == "1", _nVlrAux, 0 )
			nVlrB_ISS += IIf( lBBB_INCISS .and. BBB->BBB_INCISS == "1", _nVlrAux, 0 )
			
			nTotCre += _nVlrAux
			nSaldo  += _nVlrAux
			
			If ! Empty(BBB->BBB_VERBA)
				AnalisaVerbas(BBB->BBB_VERBA,aVerbasFol,_nVlrAux)
			Endif
			
			aadd(aRetNiv2,{	cDebCre,;
							_nVlrAux,;
							cCodLan,;
							"",;
							TrbMPG->CC,;
							TrbMPG->CODSER,;
							"BBC",;
							cProduto,;
							cTes})
		
			TrbMPG->(DbSkip())
		Enddo
		TrbMPG->(DbCloseArea())
		
		If nTotCre > 0
			lTemMvt := .T.
			aadd(aRetNiv1,{	cDebCre,;
							nTotCre,;
							cCodLan,;
							cDesLan,;
							cImgTree})
			nSaldo  := nTotCre
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 104 <<<<< Creditos Gerais                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "104"
		cSQL := "SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR, BGQ_INCINS AS INCINS, "
		cSQL += "BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL, "
		cSQL += IIf(BGQ->(FieldPos("BGQ_INCISS")) > 0, "BGQ_INCISS AS INCISS, ", "" )
		cSQL += "BGQ_CODEMP, BGQ_CONEMP, BGQ_SUBCON, BGQ_MATRIC "
		cSQL += " FROM "+RetSQLName("BGQ")+" WHERE "
		cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
		cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
		cSQL += " ( BGQ_ANO < '" + cAno + "' OR (BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '"+ cMes +"' )) AND "
		If lBGQ_ATIVO // .And. GetNewPar("MV_PLATIOD","0") == '1'
			cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
		endIf
		
		cSQL += " ( BGQ_TIPO   = '2' ) AND "
		cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
		
		cSQL += "( BGQ_OPELOT = '    '  OR BGQ_OPELOT ='"+cOpelote+"') AND "
		cSQL += " ( BGQ_NUMLOT = '          '  OR BGQ_NUMLOT='"+cLote+"' ) AND " 

		cSQL += " ( D_E_L_E_T_ = ' ' ) "
		
		If lPLMPALAN
			cSQL += Execblock("PLMPALAN",.f.,.f.,{})
		Endif
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
		TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
		
		nTotCre := 0
		BBB->(DbSetOrder(1))
		While ! TrbMPG->(Eof())
			
			If  ! empty(cCodDC) .and. ! TrbMPG->CODLAN $ cCodDC
				TrbMPG->(DbSkip())
				Loop
			Endif
		
			If BAU->BAU_BASINS == '1' .or. TrbMPG->TIPOCT == "2"
				aBaseDif[2] += TrbMPG->VALOR
			Else
				If TrbMPG->TIPOCT == "1"
					aBaseDif[1] += TrbMPG->VALOR
				ElseIf TrbMPG->TIPOCT == "3"
					aBaseDif[3] += TrbMPG->VALOR
				Else
					aBaseDif[4] += TrbMPG->VALOR
				EndIf
			EndIf		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apuracao das bases dos impostos...                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  TrbMPG->INCINS == "1" .AND. BAU->BAU_TIPPE == "F"
				nIndSEFIP := fIndSEFIP(TrbMPG->BGQ_CODEMP, TrbMPG->BGQ_CONEMP, TrbMPG->BGQ_SUBCON, TrbMPG->BGQ_MATRIC, cCalcImp, @aSEFIP)
				If BAU->BAU_BASINS == '1' .or. TrbMPG->TIPOCT == "2"
					nVlrB_INPJ += TrbMPG->VALOR
					aSEFIP[nIndSEFIP, 7] += TrbMPG->VALOR
				Else
					If TrbMPG->TIPOCT == "3"
						nVlrB_INJF += TrbMPG->VALOR
						aSEFIP[nIndSEFIP, 8] += TrbMPG->VALOR
					ElseIf TrbMPG->TIPOCT == "1"
						nVlrB_INPF += TrbMPG->VALOR
						aSEFIP[nIndSEFIP, 6] += TrbMPG->VALOR
					Else
						nVlrB_INHP += TrbMPG->VALOR
						aSEFIP[nIndSEFIP, 9] += TrbMPG->VALOR
					Endif
				EndIf
			Endif
			If cCalcImp $ '1' .and. Empty(cTes) .And. BBB->(msSeek(xFilial("BBB")+TrbMPG->CODLAN))
				cTes := BBB->BBB_TES
			EndIf
			
			nVlrB_IR  += IIf( TrbMPG->INCIR  == "1", TrbMPG->VALOR, 0 )
			nVlrB_PIS += IIf( TrbMPG->INCPIS == "1", TrbMPG->VALOR, 0 )
			nVlrB_COF += IIf( TrbMPG->INCCOF == "1", TrbMPG->VALOR, 0 )
			nVlrB_CSL += IIf( TrbMPG->INCCSL == "1", TrbMPG->VALOR, 0 )
			nVlrB_ISS += IIf( lBGQ_INCISS .And. TrbMPG->INCISS == "1", TrbMPG->VALOR, 0 )
			
			nTotCre += TrbMPG->VALOR
			nSaldo  += TrbMPG->VALOR
			
			If ! Empty(TrbMPG->BGQ_VERBA)
				AnalisaVerbas(TrbMPG->BGQ_VERBA,aVerbasFol,TrbMPG->VALOR)
			Endif
			
			aadd(aRetNiv2,{	cDebCre,;
							TrbMPG->VALOR,;
							cCodLan,;
							"",;
							TrbMPG->CC,;
							TrbMPG->CODLAN,;
							"BGQ",;
							cProduto,;
							cTes})
			
			TrbMPG->(DbSkip())
		Enddo
		TrbMPG->(DbCloseArea())
		
		If nTotCre > 0
			lTemMvt := .T.
			nSaldo 	:= nTotCre
			aadd(aRetNiv1,{	cDebCre,;
							nTotCre,;
							cCodLan,;
							cDesLan,;
							cImgTree})
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 105 <<<<< Debitos  Gerais                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "105"

		cSQL := "SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR,BGQ_INCINS AS INCINS, "
		cSQL += "BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL, "
		cSQL += IIf(lBGQ_INCISS, "BGQ_INCISS AS INCISS, ", "" )
		cSQL += "BGQ_CODEMP, BGQ_CONEMP, BGQ_SUBCON, BGQ_MATRIC "
		cSQL += " FROM "+RetSQLName("BGQ")+" WHERE "
		cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
		cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
		cSQL += " ( BGQ_ANO < '" + cAno + "' OR (BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '"+ cMes +"' )) AND "
		If lBGQ_ATIVO // .And. GetNewPar("MV_PLATIOD","0") == '1'
			cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
		EndIf

		cSQL += " ( BGQ_TIPO   = '1' ) AND "
		cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
		
		cSQL += "( BGQ_OPELOT = '    '  OR BGQ_OPELOT ='"+cOpelote+"') AND "
		cSQL += " ( BGQ_NUMLOT = '          '  OR BGQ_NUMLOT='"+cLote+"' ) AND "     

		cSQL += " ( D_E_L_E_T_ = ' ' ) "
		
		If lPLMPALAN
			cSQL += Execblock("PLMPALAN",.f.,.f.,{})
		Endif
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
		TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
		
		nTotDeb := 0
		BBB->(DbSetOrder(1))
		While ! TrbMPG->(Eof())
			
			If  ! empty(cCodDC) .and. ! TrbMPG->CODLAN $ cCodDC
				TrbMPG->(DbSkip())
				Loop
			Endif
		
			If BAU->BAU_BASINS == '1' .or. TrbMPG->TIPOCT == "2"
					aBaseDif[2] -= TrbMPG->VALOR
			Else
				If TrbMPG->TIPOCT == "1"
					aBaseDif[1] -= TrbMPG->VALOR
				ElseIf TrbMPG->TIPOCT == "3"
					aBaseDif[3] -= TrbMPG->VALOR
				Else
					aBaseDif[4] -= TrbMPG->VALOR
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apuracao das bases dos impostos...                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  TrbMPG->INCINS == "1" .AND. BAU->BAU_TIPPE == "F"
				
				nIndSEFIP := fIndSEFIP(TrbMPG->BGQ_CODEMP, TrbMPG->BGQ_CONEMP, TrbMPG->BGQ_SUBCON, TrbMPG->BGQ_MATRIC, cCalcImp, @aSEFIP)
				
				If BAU->BAU_BASINS == '1' .or. TrbMPG->TIPOCT == "2"
					nVlrB_INPJ -= TrbMPG->VALOR
					aSEFIP[nIndSEFIP, 7] -= TrbMPG->VALOR			
				Else
					If     TrbMPG->TIPOCT == "3"
						nVlrB_INJF -= TrbMPG->VALOR
						aSEFIP[nIndSEFIP, 8] -= TrbMPG->VALOR
					ElseIf TrbMPG->TIPOCT == "1"
						nVlrB_INPF -= TrbMPG->VALOR
						aSEFIP[nIndSEFIP, 6] -= TrbMPG->VALOR
					Else
						nVlrB_INHP -= TrbMPG->VALOR
						aSEFIP[nIndSEFIP, 9] -= TrbMPG->VALOR
					Endif
				EndIf
			Endif
			
			nVlrB_IR  -= IIf( TrbMPG->INCIR == "1",  TrbMPG->VALOR, 0 )
			nVlrB_PIS -= IIf( TrbMPG->INCPIS == "1", TrbMPG->VALOR, 0 )
			nVlrB_COF -= IIf( TrbMPG->INCCOF == "1", TrbMPG->VALOR, 0 )
			nVlrB_CSL -= IIf( TrbMPG->INCCSL == "1", TrbMPG->VALOR, 0 )
			nVlrB_ISS -= IIf( lBGQ_INCISS .and. TrbMPG->INCISS == "1", TrbMPG->VALOR, 0 )
			
			nTotDeb += TrbMPG->VALOR
			nSaldo  -= TrbMPG->VALOR
			
			If ! Empty(TrbMPG->BGQ_VERBA)
				AnalisaVerbas(TrbMPG->BGQ_VERBA,aVerbasFol,TrbMPG->VALOR)
			Endif
			
			aadd(aRetNiv2,{	cDebCre,;
							TrbMPG->VALOR,;
							cCodLan,;
							"",;
							TrbMPG->CC,;
							TrbMPG->CODLAN,;
							"BGQ",;
							cProduto,;
							cTes})
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para que quando houver creditos para a RDA ³
			//³esses creditos viram desconto no pedido de compra e   ³
			//³na  nota fiscal de entrada                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			nVlrDescNf += TrbMPG->VALOR
			
			If TrbMPG->CODLAN $ cCdIRRet
				nVrIRRet += TrbMPG->VALOR
			EndIf
			
			TrbMPG->(DbSkip())
		Enddo
		TrbMPG->(DbCloseArea())
		
		If nTotDeb > 0
			lTemMvt := .T.
			nSaldo := nTotDeb
			aadd(aRetNiv1,{	cDebCre,;
							nTotDeb,;
							cCodLan,;
							cDesLan,;
							cImgTree})
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 106 --<<<<< Apontamentos de producao medica    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "106"
		cSQL := "SELECT BCE_CC AS CC,BCE_VERBA, BCE_TIPOCT AS TIPOCT, BCE_CODPAG AS CODLAN, BCE_CC AS CC, BCE_VLRAPT AS VALOR,BCE_INCIR AS INCIR, "
		cSQL += "BCE_INCINS AS INCINS, BCE_INCPIS AS INCPIS, BCE_INCCOF AS INCCOF, BCE_INCCSL AS INCCSL "
		cSQL += IIf(BCE->(FieldPos("BCE_INCISS")) > 0, ", BCE_INCISS AS INCISS ", "" )
		cSQL += " FROM "+RetSQLName("BCE")+" WHERE "
		cSQL += " ( BCE_FILIAL = '"+xFilial("BCE")+"' ) AND "
		cSQL += " ( BCE_CODIGO = '"+cCodRDA+"' ) AND "
		cSQL += " ( BCE_CODINT = '"+cCodOpe+"' ) AND "
		cSQL += " ( BCE_ANOPAG = '"+cAno+"' ) AND "
		cSQL += " ( BCE_MESPAG = '"+cMes+"' ) AND "
		cSQL += " ( BCE_OPELOT = '    ' ) AND "
		cSQL += " ( BCE_NUMLOT = '          ' ) AND "
		cSQL += " ( D_E_L_E_T_ = ' ' ) "
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
		TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
		
		nTotCre := 0
		BBB->(DbSetOrder(1))
		While ! TrbMPG->(Eof())
			
			If BAU->BAU_BASINS == '1' .or. TrbMPG->TIPOCT == "2"
				aBaseDif[2] += TrbMPG->VALOR
			Else
				If TrbMPG->TIPOCT == "1"
					aBaseDif[1] += TrbMPG->VALOR
				ElseIf TrbMPG->TIPOCT == "3"
					aBaseDif[3] += TrbMPG->VALOR
				Else
					aBaseDif[4] += TrbMPG->VALOR
				EndIf
			EndIf		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apuracao das bases dos impostos...                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  TrbMPG->INCINS == "1" .AND. BAU->BAU_TIPPE == "F"
				
				nIndSEFIP := fIndSEFIP("", "", "", "", cCalcImp, @aSEFIP)
				
				If BAU->BAU_BASINS == '1' .or. TrbMPG->TIPOCT == "2"
					nVlrB_INPJ += TrbMPG->VALOR
					aSEFIP[nIndSEFIP, 7] += TrbMPG->VALOR
				Else
					If     TrbMPG->TIPOCT == "3"
						nVlrB_INJF += TrbMPG->VALOR
						aSEFIP[nIndSEFIP, 8] += TrbMPG->VALOR
					ElseIf TrbMPG->TIPOCT == "1"
						nVlrB_INPF += TrbMPG->VALOR
						aSEFIP[nIndSEFIP, 6] += TrbMPG->VALOR
					Else
						nVlrB_INHP += TrbMPG->VALOR
						aSEFIP[nIndSEFIP, 9] += TrbMPG->VALOR
					Endif
				EndIf
				
			Endif
			
			nVlrB_IR  += IIf( TrbMPG->INCIR  == "1", TrbMPG->VALOR, 0 )
			nVlrB_PIS += IIf( TrbMPG->INCPIS == "1", TrbMPG->VALOR, 0 )
			nVlrB_COF += IIf( TrbMPG->INCCOF == "1", TrbMPG->VALOR, 0 )
			nVlrB_CSL += IIf( TrbMPG->INCCSL == "1", TrbMPG->VALOR, 0 )
			nVlrB_ISS += IIf( lBCE_INCISS .and. TrbMPG->INCISS == "1", TrbMPG->VALOR, 0 )
			
			nTotCre += TrbMPG->VALOR
			nSaldo  += TrbMPG->VALOR
			
			If ! Empty(TrbMPG->BCE_VERBA)
				AnalisaVerbas(TrbMPG->BCE_VERBA,aVerbasFol,TrbMPG->VALOR)
			Endif
			
			aadd(aRetNiv2,{	cDebCre,;
							TrbMPG->VALOR,;
							cCodLan,;
							"",;
							TrbMPG->CC,;
							TrbMPG->CODLAN,;
							"BCE",;
							cProduto,;
							cTes})
			
			TrbMPG->(DbSkip())
		Enddo
		TrbMPG->(DbCloseArea())
		
		If nTotCre > 0
			lTemMvt := .T.
			nSaldo 	:= nTotCre
			aadd(aRetNiv1,{	cDebCre,;
							nTotCre,;
							cCodLan,;
							cDesLan,;
							cImgTree})
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 107 --<<<<< Faixa de Desconto				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "107"
		If(BY6->(FieldPos("BY6_VIGINI")) > 0 .And. BY6->(FieldPos("BY6_VIGFIN")) > 0 )
			cSQL := "SELECT BY6_CODIGO,BY6_CODINT,BY6_FAIDE,BY6_FAIATE,BY6_PERDES "
			
			If(BY6->(FieldPos("BY6_VIGINI")) > 0 .And. BY6->(FieldPos("BY6_VIGFIN")) > 0 )
				cSQL += ", BY6_VIGINI, BY6_VIGFIN "
			EndIf
			
			cSQL += " FROM "+RetSQLName("BY6")+" WHERE "
			cSQL += " ( BY6_FILIAL = '"+xFilial("BY6")+"' ) AND "
			cSQL += " ( BY6_CODIGO = '"+cCodRDA+"' ) AND "
			cSQL += " ( BY6_CODINT = '"+cCodOpe+"' ) AND "
			cSQL += " BY6_VIGINI <> ' ' AND
			cSQL += " BY6_VIGINI <= '"+DTOS(dDataBase)+"' AND "
			cSQL += " (BY6_VIGFIN = ' ' OR "
			cSQL += " BY6_VIGFIN >= '"+DTOS(dDataBase)+"') AND "
			cSQL += " ( D_E_L_E_T_ = ' ' ) "
			
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBY6",.F.,.T.)
			TcSetField("TrbBY6","BY6_FAIDE","N",17,4)
			TcSetField("TrbBY6","BY6_FAIATE","N",17,4)
			TcSetField("TrbBY6","BY6_PERDES","N",6,3)
			TcSetField("TrbBY6","BY6_VIGINI","D",8,0)
			TcSetField("TrbBY6","BY6_VIGFIN","D",8,0)
			
			nTotCre := 0
			BLR->(DbSetOrder(1)) //BLR_FILIAL, BLR_CODINT, BLR_PROPRI, BLR_CODLAN
			If ! TrbBY6->(Eof())
				
				For nX := 1 To Len(aRetNiv2)
					If BLR->(DbSeek(xFilial("BLR")+TrbBY6->BY6_CODINT+aRetNiv2[nX][3]))
						If BLR->(FieldPos("BLR_DESPRO")) > 0 .And. BLR->BLR_DESPRO == '1' 
							If BLR->BLR_DEBCRE == '2' .And.;
								aRetNiv2[nX][2] >= TrbBY6->BY6_FAIDE .And. aRetNiv2[nX][2] <= TrbBY6->BY6_FAIATE
								nTotC += aRetNiv2[nX][2] 
							ElseIf BLR->BLR_DEBCRE == '1'
								nTotD += aRetNiv2[nX][2]	
							EndIf	
						EndIf
					EndIf
				Next nX
				
				nTot := nTotC - nTotD
				
				While ! TrbBY6->(Eof())
					
					nTotCre := ((nTot * TrbBY6->BY6_PERDES) / 100)
					nSaldo  := ((nTot * TrbBY6->BY6_PERDES) / 100)
					
					aadd(aRetNiv2,{	cDebCre,;
									TrbBY6->BY6_PERDES,;
									cCodLan,;
									"",;
									"",;
									"",;
									"BY6",;
									cProduto,;
									cTes})
				
					TrbBY6->(DbSkip())
				Enddo
				TrbBY6->(DbCloseArea())
				
				If nTotCre > 0
					lTemMvt := .T.
					nSaldo 	:= nTotCre
					aadd(aRetNiv1,{	cDebCre,;
									nTotCre,;
									cCodLan,;
									cDesLan,;
									cImgTree})
				Endif			
			Endif
		Endif
	Endif
	
	If Select( "TrbBY6" ) > 0
		TrbBY6->( dbCloseArea() )
	Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lancamento de codigo 167 --<<<<< Valor Base INSS Hon.Patronal       ³
//³ Quando o calculo de impostos NAO eh pelo financeiro (pela folha)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  cCodLan == "167" .And. BAU->BAU_TIPPE == 'F' .and. nVlrB_INHP > 0 .and. BAU->BAU_BASINS <> '1'
		nSaldo 	:= nVlrB_INHP
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_INHP,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lancamento de codigo 169 --<<<<< IR Retido Outras Fontes            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "169"
		
		cCod169 := GetNewPar("MV_PLCIRRT","")
		If !Empty(cCod169)
			
			cOriLan := "BGQ"
			cSQL := "SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR,BGQ_INCINS AS INCINS, "
			cSQL += "BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL "
			cSQL += " FROM "+RetSQLName("BGQ")+" WHERE "
			cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
			cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
			cSQL += " ( BGQ_ANO = '" + cAno + "' AND BGQ_MES = '"+ cMes +"' ) AND "
			cSQL += " ( BGQ_CODLAN = '" + AllTrim(cCod169) + "' ) AND ( BGQ_TIPO = '3' ) AND "
			cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
			cSQL += " ( BGQ_OPELOT = '    ' ) AND "
			cSQL += " ( BGQ_NUMLOT = '          ' ) AND "
			If lBGQ_ATIVO
				cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
			EndIf
			
			cSQL += " ( D_E_L_E_T_ = ' ' ) "
			
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)		
			TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao encontrou em debitos/creditos variaveis o lancamento ref a   ³
			//³ "Sal Contrib IRRF Outras Empresas" busca em debitos/creditos fixos. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TrbMPG->(Eof())
				TrbMPG->(DbCloseArea())
				cOriLan := "BBC"
				cSQL := "SELECT BBC_CODSER AS CODLAN, BBC_CC AS CC, BBC_VALOR AS VALOR, BBC_NROPGT "
				cSQL += " FROM "+RetSQLName("BBC")+" WHERE "
				cSQL += " ( BBC_FILIAL = '"+xFilial("BBC")+"' ) AND "
				cSQL += " ( BBC_CODIGO = '"+cCodRDA+"' ) AND "
				cSQL += " ( BBC_PROMED = '1' ) AND "
				cSQL += " ( BBC_STATUS = '1' ) AND "
				cSQL += " ( BBC_CODSER = '" + AllTrim(cCod169) + "' ) AND  ( BBC_DEBCRE = '3' ) AND "
				If lCposVld
					cSQL += " ( '" + cAno + cMes + "01' >= BBC_VLDINI ) AND "
					cSQL += " ( ( '" + DtoS(LastDay(CtoD("01/"+cMes+"/"+cAno))) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
				EndIf
				cSQL += " ( D_E_L_E_T_ = ' ' ) "
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
				TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
			EndIf
			
			nTotCre := 0
			BBB->(DbSetOrder(1))
			While ! TrbMPG->(Eof())
				
				If cOriLan == "BBC" .And. ;
						! PLMOVCRE(BAU->BAU_CODIGO,cAno,cMes,,IIf(Empty(TrbMPG->BBC_NROPGT),"0",TrbMPG->BBC_NROPGT),cCod169,cCodOpe,cOpeLote)
					TrbMPG->(DbSkip())
					Loop
				EndIf
				
				nTotCre += TrbMPG->VALOR
				
				aadd(aRetNiv2,{	cDebCre,;
								TrbMPG->VALOR,;
								cCodLan,;
								"",;
								TrbMPG->CC,;
								TrbMPG->CODLAN,;
								cOriLan,;
								cProduto,;
								cTes})
			
				TrbMPG->(DbSkip())
			Enddo
			TrbMPG->(DbCloseArea())
			
			If nTotCre > 0
				nVrIRRet += nTotCre
				nSaldo 	:= nVrIRRet
				lTemMvt := .T.
				aadd(aRetNiv1,{	cDebCre,;
								nVrIRRet,;
								cCodLan,;
								cDesLan,;
								cImgTree})
			EndIf
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 170 <<<<< Sal Contrib Outras Empresas          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "170" 
		
		cCod170 := GetNewPar("MV_PLSCIOE","")
		If !Empty(cCod170)
			cOriLan := "BGQ"
			cSQL := "SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR,BGQ_INCINS AS INCINS, "
			cSQL += "BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL "
			cSQL += " FROM "+RetSQLName("BGQ")+" WHERE "
			cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
			cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
			cSQL += " ( BGQ_ANO = '" + cAno + "' AND BGQ_MES = '"+ cMes +"' ) AND "
			If lBGQ_ATIVO
				cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
			EndIf
			
			cSQL += " ( BGQ_CODLAN = '" + AllTrim(cCod170) + "' ) AND ( BGQ_TIPO = '3' ) AND "
			cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
			cSQL += " ( BGQ_OPELOT = '    ' ) AND "
			cSQL += " ( BGQ_NUMLOT = '          ' ) AND "
			cSQL += " ( D_E_L_E_T_ = ' ' ) "
			
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)		
			TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao encontrou em debitos/creditos variaveis o lancamento ref a   ³
			//³ "Sal Contrib INSS Outras Empresas" busca em debitos/creditos fixos. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TrbMPG->(Eof())
				TrbMPG->(DbCloseArea())
				cOriLan := "BBC"
				cSQL := "SELECT BBC_CODSER AS CODLAN, BBC_CC AS CC, BBC_VALOR AS VALOR, BBC_NROPGT "
				cSQL += " FROM "+RetSQLName("BBC")+" WHERE "
				cSQL += " ( BBC_FILIAL = '"+xFilial("BBC")+"' ) AND "
				cSQL += " ( BBC_CODIGO = '"+cCodRDA+"' ) AND "
				cSQL += " ( BBC_PROMED = '1' ) AND "
				cSQL += " ( BBC_STATUS = '1' ) AND "
				// BOPS 98697
				cSQL += " ( BBC_CODSER = '" + AllTrim(cCod170) + "' ) AND  ( BBC_DEBCRE = '3' ) AND "
				If lCposVld
					cSQL += " ( '" + cAno + cMes + "01' >= BBC_VLDINI ) AND "
					cSQL += " ( ( '" + DtoS(LastDay(CtoD("01/"+cMes+"/"+cAno))) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
				EndIf
				cSQL += " ( D_E_L_E_T_ = ' ' ) "
				
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
				TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
			EndIf
			
			nTotCre := 0
			BBB->(DbSetOrder(1))
			While ! TrbMPG->(Eof())
				
				If cOriLan == "BBC" .And. ;
						! PLMOVCRE(BAU->BAU_CODIGO,cAno,cMes,,IIf(Empty(TrbMPG->BBC_NROPGT),"0",TrbMPG->BBC_NROPGT),cCod170,cCodOpe,cOpeLote)
					TrbMPG->(DbSkip())
					Loop
				EndIf
				
				nTotCre += TrbMPG->VALOR
				
				aadd(aRetNiv2,{	cDebCre,;
								TrbMPG->VALOR,;
								cCodLan,;
								"",;
								TrbMPG->CC,;
								TrbMPG->CODLAN,;
								cOriLan,;
								cProduto,;
								cTes})
			
				TrbMPG->(DbSkip())
			Enddo
			TrbMPG->(DbCloseArea())
			
			If nTotCre > 0
				lTemMvt := .T.
				nSaldo 	:= nTotCre
				aadd(aRetNiv1,{	cDebCre,;
								nTotCre,;
								cCodLan,;
								cDesLan,;
								cImgTree})
			Endif
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Lancamento de codigo 182 --<<<<< Valor Base INSS                    
	//³ Base total INSS quando for calculo de impostos pelo financeiro      
	//³ ou eh Pessoa Fisica Nao Cooperado e Base for Unificada                                   
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If cCodLan == "182" .And. BAU->BAU_TIPPE == 'F' .And. (nVlrB_INPF + nVlrB_INPJ + nVlrB_INJF + nVlrB_INHP) > 0 .and. BAU->BAU_BASINS == '1'
		
		nSaldo := nVlrB_INPF + nVlrB_INPJ + nVlrB_INJF + nVlrB_INHP
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nSaldo,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 184 --<<<<< Valor Base ISS                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "184" .And. nVlrB_ISS > 0
		nSaldo 	:= nVlrB_ISS
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_ISS,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 186 --<<<<< Valor Base PIS                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "186" .And. nVlrB_PIS > 0
		nSaldo 	:= nVlrB_PIS
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_PIS,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 188 --<<<<< Valor Base COFINS                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "188" .And. nVlrB_COF > 0
		nSaldo 	:= nVlrB_COF
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_COF,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 190 --<<<<< Valor Base CSLL                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "190" .And. nVlrB_CSL > 0
		nSaldo 	:= nVlrB_CSL
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_CSL,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 192 --<<<<< Valor Base INSS PF                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "192" .And. BAU->BAU_TIPPE == 'F' .And. nVlrB_INPF > 0 .and. BAU->BAU_BASINS <> '1'
		nSaldo 	:= nVlrB_INPF
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_INPF,;
						cCodLan,;
						cDesLan,;
						cImgTree})
		Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 194 --<<<<< Valor Base INSS PJ                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  cCodLan == "194" .And. BAU->BAU_TIPPE == 'F' .and. nVlrB_INPJ > 0 .And. BAU->BAU_BASINS <> '1'
		
		nSaldo 	:= nVlrB_INPJ
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_INPJ,;
						cCodLan,;
						cDesLan,;
						cImgTree})
		Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 196 --<<<<< Valor Base INSS PJ Filantropico    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  cCodLan == "196" .And. BAU->BAU_TIPPE == 'F' .and. nVlrB_INJF > 0 .And. BAU->BAU_BASINS <> '1'
		
		nSaldo 	:= nVlrB_INJF
		lTemMvt := .T.
		
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_INJF,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lancamento de codigo 198 --<<<<< Valor Base Imposto de Renda        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "198"
		
		cCod198 := GetNewPar("MV_PLCIRRF","")
		cOriLan := "BGQ"
		cSQL := "SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR,BGQ_INCINS AS INCINS, "
		cSQL += "BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL "
		cSQL += " FROM "+RetSQLName("BGQ")+" WHERE "
		cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
		cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
		cSQL += " ( BGQ_ANO = '" + cAno + "' AND BGQ_MES = '"+ cMes +"' ) AND "
		cSQL += " ( BGQ_CODLAN = '" + AllTrim(cCod198) + "' ) AND ( BGQ_TIPO = '3' ) AND "
		cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
		cSQL += " ( BGQ_OPELOT = '    ' ) AND "
		
		If lBGQ_ATIVO
			cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
		EndIf
		
		cSQL += " ( BGQ_NUMLOT = '          ' ) AND "
		cSQL += " ( D_E_L_E_T_ = ' ' ) "
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)	
		TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao encontrou em debitos/creditos variaveis o lancamento ref a   ³
		//³ "Sal Contrib INSS Outras Empresas" busca em debitos/creditos fixos. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TrbMPG->(Eof())
			TrbMPG->(DbCloseArea())
			cOriLan := "BBC"
			cSQL := "SELECT BBC_CODSER AS CODLAN, BBC_CC AS CC, BBC_VALOR AS VALOR, BBC_NROPGT "
			cSQL += " FROM "+RetSQLName("BBC")+" WHERE "
			cSQL += " ( BBC_FILIAL = '"+xFilial("BBC")+"' ) AND "
			cSQL += " ( BBC_CODIGO = '"+cCodRDA+"' ) AND "
			cSQL += " ( BBC_PROMED = '1' ) AND "
			cSQL += " ( BBC_STATUS = '1' ) AND "
			cSQL += " ( BBC_CODSER = '" + AllTrim(cCod198) + "' ) AND  ( BBC_DEBCRE = '3' ) AND "
			If lCposVld
				cSQL += " ( '" + cAno + cMes + "01' >= BBC_VLDINI ) AND "
				cSQL += " ( ( '" + DtoS(LastDay(CtoD("01/"+cMes+"/"+cAno))) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
			EndIf
			cSQL += " ( D_E_L_E_T_ = ' ' ) "
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
			TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
		EndIf
		
		nTotCre := 0
		BBB->(DbSetOrder(1))
		While ! TrbMPG->(Eof())
			
			If cOriLan == "BBC" .And. ! PLMOVCRE(BAU->BAU_CODIGO,cAno,cMes,,IIf(Empty(TrbMPG->BBC_NROPGT),"0",TrbMPG->BBC_NROPGT),cCod198,cCodOpe,cOpeLote)
				TrbMPG->(DbSkip())
				Loop
			EndIf
			
			nTotCre += TrbMPG->VALOR
			
			aadd(aRetNiv2,{	cDebCre,;
							TrbMPG->VALOR,;
							cCodLan,;
							"",;
							TrbMPG->CC,;
							TrbMPG->CODLAN,;
							cOriLan,;
							cProduto,;
							cTes})
			
			TrbMPG->(DbSkip())
		Enddo
		TrbMPG->(DbCloseArea())
		
		nVlrB_IR += nTotCre
		nSaldo 	:= nVlrB_IR
		
		if nVlrB_IR > 0
			aadd(aRetNiv1,{	cDebCre,;
							nVlrB_IR,;
							cCodLan,;
							cDesLan,;
							cImgTree})
		endIf		
							
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Debitos Gerias - Pagamento Intercambio de Anestesista				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodLan == "104" .And. lAneste .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
		If PLSALIASEX("B7R")
		cSQL := "SELECT SUM(B7R_VLRDIF) AS VALOR, SUM(B7R_VLRGLO) AS GLOSA, BRJ_CODIGO, BRJ_TPPAG "
		cSQL += " FROM "+RetSQLName("B7R")+" B7R "
		cSql += " INNER JOIN "+RetSqlName("BRJ")+" BRJ "
		cSql += " ON  BRJ.BRJ_FILIAL = B7R.B7R_FILIAL "
		cSql += " AND BRJ.BRJ_CODIGO = B7R.B7R_CODBRJ "
		cSql += " AND BRJ.BRJ_CODIGO = '"+cLoteImp+"' "
		cSql += " AND BRJ.BRJ_OPEORI = '"+BAU->BAU_CODOPE+"' "
		cSql += " AND BRJ.BRJ_STATUS = '1' " // A Faturar
		cSql += " AND BRJ.BRJ_REGPRI = '1' "
		cSQL += " AND BRJ.D_E_L_E_T_ = ' ' "
		cSQL += " WHERE B7R_FILIAL = '"+xFilial("B7R")+"' AND "
		cSQL += " B7R.D_E_L_E_T_ = ' ' "
		cSQL += " GROUP BY BRJ_CODIGO, BRJ_TPPAG "
	
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbB7R",.F.,.T.)	
		
		TcSetField("TrbB7R","VALOR","N",nVlPrec,nVlDec)
		TcSetField("TrbB7R","GLOSA","N",nVlPrec,nVlDec)
		
		If ! TrbB7R->(Eof()) .And. TrbB7R->VALOR > 0
		
			If TrbB7R->BRJ_TPPAG == "2"
				nSaldo  := TrbB7R->VALOR - TrbB7R->GLOSA		
				nVlrGlo := TrbB7R->GLOSA
			Else
				nSaldo := TrbB7R->VALOR
			EndIf	
			
			If nSaldo > 0 
				aadd(aRetNiv2,{	cDebCre,;
								nSaldo,;
								cCodLan,;
								"",;
								"",;
								"",;
								"B7R"})
			
				aadd(aRetNiv1,{	cDebCre,;
								nSaldo,;
								cCodLan,;
								cDesLan,;
								cImgTree})
			EndIf		
	
		Endif
		TrbB7R->(DbCloseArea())
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Monta totalizador da verba...                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(cVerba)
		AnalisaVerbas(cVerba,aVerbasFol,nSaldo)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Monta total acumulado...                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	cDebCre == "1"
		nTotal -= nSaldo
	ElseIf cDebCre == "2"
		nTotal += nSaldo
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui no vetor Composicao de Pagamento                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPLSPAG01
		ExecBLock("PLSPAG01",.F.,.F.,{cCodRda,cAno,cMes,cCodLan,nSaldo,lGerLot})
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe imposto                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTemImp := IIf((nVlrB_IR + nVlrB_INPF + nVlrB_INPJ + nVlrB_INJF + nVlrB_INHP + nVlrB_PIS + nVlrB_COF + nVlrB_CSL + nVlrB_ISS) > 0, .T., .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao tenha imposto, nem valor e tenha movimentacao ele ira gerar o lancamento  ³
//³ de credito de 1 centavo para que seja gerado o titulo e dado baixa na movimentacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotal == 0 .AND. !lTemImp .AND. lTemMvt
	lGeraL := .T.
Endif
aUsDif := {nVlrDebdif,nVlrCredif}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta retorno padrao...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aResumo[1] := nTotal

// Determina mesmo não havendo valor a pagar para a RDA e tem somente glosa devemos forçar para a mudança de flag para faturado para atender algumas empresas que controlam esse status
If	nTotal <> 0 .OR. lTemImp .or. lTemMvt .or. GetNewPar("MV_PLFORGE",.F.)  
	aRetPad  := {.T.,aRetNiv1,aVerbasFol,aResumo,aRetNiv2,aSEFIP,aVrPgtDiv,nVrIRRet,lTemImp,lGeraL,nVlrRefTde,aUsDif,nVlrGlo,nVlrSer,nVlrTx,aBaseDif,nVlrDescNf}
ElseIf cCalcImp $ '1,4'
	aRetPad  := {.F.,aRetNiv1,aVerbasFol,aResumo,aRetNiv2,aSEFIP,aVrPgtDiv,nVrIRRet,lTemImp,lGeraL,nVlrRefTde,aUsDif,nVlrGlo,nVlrSer,nVlrTx,aBaseDif,nVlrDescNf}
Endif

RestArea(aArea)

Return(aRetPad)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLGERCRE ³ Autor ³ Tulio Cesar           ³ Data ³ 07.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Gerar titulo para um credenciado em um deterinado ano/mes  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLGERCRE(cOpeRda,cCodRda,cCodForn,cLoja,cAno,cMes,dVencto,cPrefixo,cNumero,cTipo,cHisTit,;
					cOpeLote,cLote,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,cCodPegFi,cNumMovIn,cNumMovFi,;
					cCodOpe,aLancPagto,cCdEmpDeS,cCdEmpAteS,cExcessao,lGerPagBlo,cLoteImp,cCodDC,lCalcImp,cCodNat,;
					lGuiCob,lUltCaLc,nApUsDif,lAtuGui,cExcPeg,cTipTitInt,nPosTitInt,lAneste)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros                                                          ³
//³ cOpeRda  - Operadora da RDA (4 Digitos)                             ³
//³ cCodRda  - Codigo da Rda (6 Digitos)                                ³
//³ cCodForn - Codigo do Fornecedor (6 Digitos)                         ³
//³ cLoja    - Loja (2 Digitos)                                         ³
//³ cAno     - Ano Base do Saldo (4 Digitos)                            ³
//³ cMes     - Mes Base do Saldo (2 Digitos)                            ³
//³ dVencto  - Data do vencimento                                       ³
//³ cPrefixo - Prefixo do Titulo                                        ³
//³ cNumero  - Numero do Titulo                                         ³
//³ cTipo    - Tipo do Titulo                                           ³
//³ cHisTit  - Historico do Titulo (E2_HIST)                            ³
//³ cOpeLote - Operadora do lote de pagamento                           ³
//³ cLote    - Numero do lote de pagamento                              ³
//| cLoteImp - Indica se eh pagamento de um determinado lote apenas	    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno em uma matriz na seguinte estrutura                         ³
//³ "1"  - Titulo gerado com sucesso                                    ³
//³ "?"  - Demais criticas que podem ser visualizadas abaixo            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados SA2...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdSA2 := SA2->(IndexOrd())
LOCAL nRecSA2 := SA2->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados BAU...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBAU := BAU->(IndexOrd())
LOCAL nRecBAU := BAU->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de gravacao do historio, lote de pagamento RDA,(B03)       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lHist := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cPrefSE1
LOCAL cNumeroE1
LOCAL cTipoE1
LOCAL cParcelaE1
LOCAL aProxAno
LOCAL cSQL
LOCAL aSaldo
LOCAL aCritica   := {}
LOCAL cNatPonto
LOCAL nOrdSE2    := nPlOrdSE2
LOCAL cNaturez	 := ''
LOCAL aCompPag   := {}
LOCAL aCompPagD  := {}
LOCAL nFor
LOCAL cCalcImp
LOCAL aCampos
LOCAL nOldMod
LOCAL lOK        := .T.
LOCAL aVerbasFol := {}
LOCAL cCC
LOCAL nValorBIR  := 0
LOCAL nValorBISS	:= 0
LOCAL nValorBINS	:= 0
LOCAL nValorBCSL	:= 0
LOCAL nValorBCOF	:= 0
LOCAL nValorBPIS	:= 0
LOCAL nValorBSES	:= 0

LOCAL nInsOutEmp := 0
LOCAL cCondPag  	:= ""
LOCAL cTipoTit	:= ""

LOCAL nValorBIN1 := 0
LOCAL nValorBIN2 := 0
LOCAL nValorBIN3 := 0
LOCAL nValorBIN4 := 0
local nValDefaut := 0.01
 
LOCAL nPercBIN1  := 0
LOCAL nPercBIN2  := 0
LOCAL nPercBIN3  := 0

LOCAL nSomaAr    := 0
LOCAL nDifSoma
LOCAL lAutonomo

LOCAL nPos
LOCAL nVlrSE2	 := 0
LOCAL lVlrNeg
LOCAL aVerbas    := {}
Local aSEFIP     := {}
Local cCliente
Local cLojaCli
Local nInd
Local cCodEmp
Local cConEmp
Local cSubCon
Local cMatric
Local aRetCli
Local aBaixa
Local lBaixou

LOCAL nVlrFATINT	:= 0
LOCAL nVlrFATNDC	:= 0
LOCAL nVlrFATFAT	:= 0
LOCAL nGlosaPag     := 0
LOCAL lPagInterc    := .F.
LOCAL cCodCreGlo    := GetNewPar("MV_PLSCDCG","   ")
LOCAL cCodCreTit    := GetNewPar("MV_PLSCDCT","   ")
LOCAL cCodCreRes    := GetNewPar("MV_PLSREUS","902")
LOCAL cCodCreUdf    := GetNewPar("MV_PLSCUSD","903")
LOCAL cCodDebUdf    := GetNewPar("MV_PLSDUSD","904")
LOCAL cCodRestUdf   := GetNewPar("MV_PLSRUSD","905")
LOCAL aValorRes 	:= {}
LOCAL nValorUsRes 	:= 0
LOCAL nVlrRes       := 0
LOCAL lCriadoBGQAut := .F.
LOCAL nRecnoBGQ		:= 0
LOCAL nRecnoBRJ		:= 0
LOCAL nRecnoSE1		:= 0
LOCAL nRecnoSE2		:= 0
LOCAL nValDbBGQ     := 0
LOCAL lAtuaBRJPag   := .F.
LOCAL nRecTitVin	:= 0
LOCAL lConAji 		:= .F.
LOCAL aBasesImp
LOCAL aImpostos		:= {}
LOCAL aRetImp		:= {0,0,.F.,''}
LOCAL nValImp      	:= 0
LOCAL nVlrImp      	:= 0 // Valor total dos Impostos para somar na NDF
LOCAL nVlrIR		:= 0
LOCAL nVlrDebVar	:= 0
LOCAL cCopCre		:= ''
LOCAL cChkSE2		:= ''
LOCAL aRecnoDP		:= {}
LOCAL nRecNDF		:= 0
LOCAL i				:= 0
LOCAL lContrRet 	:= 	!Empty(SE2->(FieldPos("E2_VRETPIS"))) .And. !Empty(SE2->(FieldPos("E2_VRETCOF"))) .And. ;
	!Empty(SE2->(FieldPos("E2_VRETCSL"))) .And. !Empty(SE2->(FieldPos("E2_PRETPIS"))) .And. ;
	!Empty(SE2->(FieldPos("E2_PRETCOF"))) .And. !Empty(SE2->(FieldPos("E2_PRETCSL")))
LOCAL nOrdBA0 		:= BA0->(IndexOrd())
LOCAL nRecBA0 		:= BA0->(Recno())
LOCAL nImp	  		:= 0
LOCAL aTpCalc 		:= {}
Local aBMR    		:= {}
LOCAL aImpMes		:= {}
LOCAL dNextMes
LOCAL dNextVen
LOCAL lSoINSS		:= .F.
LOCAL aRetVLRNF		:= {}
LOCAL nVrAcresc		:= 0
LOCAL nVrDecresc	:= 0
LOCAL lINSS182		:= .F.
LOCAL lINSS192		:= .F.
Local nVrIRRet		:= 0
LOCAL cPagTot		:= ""
LOCAL j				:= 0
Local cParcela		:= space(TamSx3("E2_PARCELA")[1])
LOCAL aRetTitOpe 	:= {}
LOCAL nRecSe2Bmr:=0
LOCAL aItens:={}                                                                     
LOCAL lPgtoImp   := GetNewPar("MV_PLPGUNI","1") == "4"
LOCAL cPrefNDF	:= ""
LOCAL cNumNDF		:= ""
LOCAL nDescC7		:= 0
LOCAL nTotDesc	:= 0
Local lA1_CEINSS := SA1->(FieldPos("A1_CEINSS")) > 0
Local lBQC_CLAINS := BQC->(FieldPos("BQC_CLAINS")) > 0
Local lBAU_BASINS := BAU->(FieldPos("BAU_BASINS")) > 0
Local lBAU_MATFU3 := BAU->(FieldPos("BAU_MATFU3")) > 0
Local lBAU_MATFU4 := BAU->(FieldPos("BAU_MATFU4")) > 0
Local lC7_PLOPELT := SC7->(Fieldpos("C7_PLOPELT"))>0
Local cLotPcPls   := ''
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Varios Pagamentos Mes com calculo Impostos - LA 20100619                ³
//³ Neste cenário todos os pagamentos do mes terao calculo impostos         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lGerSE1		:= .F.
Local cSemana	:= ''
Local cSeqSRC	:= '' 
Local nForSE2		:= 0 //Contador para o For do SE2
Local nForSE2Lim	:= 0 //Limite para o For do SE2 para geração de títulos com naturezas distintas
Local cNatPF		:= GetNewPar("MV_PLSNTPF",cNaturez)
Local cNatPJ		:= GetNewPar("MV_PLSNTPJ",cNaturez)
Local cNatFT		:= GetNewPar("MV_PLSNTFT",cNaturez)
Local cNatHP		:= GetNewPar("MV_PLSNTHP",cNaturez)
Local nVez			:= 0
Local nVezSE2		:= 0
Local aINSSE2		:= {}
Local lBMR_ANOVCT	:= BMR->(FieldPos('BMR_ANOVCT')) >0
Local lBMR_MESVCT	:= BMR->(FieldPos('BMR_MESVCT')) >0
Local lBBB_INCISS 	:= BBB->(FieldPos("BBB_INCISS")) > 0
Local lBGQ_INCISS 	:= BGQ->(FieldPos("BGQ_INCISS")) > 0
Local nPosINS		:= 2
Local nHNumPag		:= 0
Local nTenta		:= 0
Local aCopSld		:= {}
Local cChaveSem     := ""
Local lPLSPGSRC		:= ExistBlock("PLSPGSRC")
Local lPLSPGSC7 	:= ExistBlock("PLSPGSC7")
Local lPLSPAG02		:= ExistBlock("PLSPAG02")
Local nPrcSld   	:= 0

PRIVATE nValorPag	:= 0
DEFAULT cCdEmpDeS  := ""
DEFAULT cCdEmpAteS := ""
DEFAULT cExcessao  := ""
DEFAULT lGerPagBlo := .F.
DEFAULT cLoteImp   := ""
DEFAULT cCodDC     := ""
DEFAULT lCalcImp   := .F.
DEFAULT cCodNat    := ""
DEFAULT lGuiCob    := .F.
DEFAULT lUltCalc   := .F.
DEFAULT nApUsDif   := 2
DEFAULT lAtuGui	   := .F.
DEFAULT cExcPeg	   := ""
DEFAULT cTipTitInt := "2"  //Indica o tipo de fatura de intercambio: 1-NDC / 2-Fatura /3-Ambos
DEFAULT nPosTitInt := 1   //Indica numeracao do titulo que esta sendo gerado. (1-Todos os titulos / 2-Titulo 'Fatura' do A500 quando o lote e do tipo 3-Ambos)
Default lAneste		:= .F.
Private nMoeda     := 1    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata o parametro caso esteja cadastrado e sem conteudo...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodCreTit := Iif(len(cCodCreTit)==3,cCodCreTit,cCodCreTit+space(3-len(cCodCreTit)))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata vencimento invalido...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(dVencto)
	aCritica := {"2","Data de Vencimento Invalida",0}
	Return(aCritica)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe o fornecedor informado...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA2->(DbSetOrder(1))
If ! SA2->(DbSeek(xFilial("SA2")+cCodForn+cLoja,.F.))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	
	aCritica := {"3","Fornecedor Invalido",0}
	Return(aCritica)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe a rede de atendimento...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->(DbSetOrder(1))
If ! BAU->(DbSeek(xFilial("BAU")+cCodRda,.F.))
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	
	aCritica := {"4","Rede de Atendimento Invalida",0}
	Return(aCritica)
Endif
cCopCre := BAU->BAU_COPCRE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se tem pagamento dividido e testa se ja foi processado..   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BAU->BAU_MODPAG $ "2,3"
	BEQ->(DbSetOrder(1))
	If ! BEQ->(DbSeek(xFilial("BEQ")+BAU->BAU_CODIGO+cAno+cMes,.F.))
		BAU->(DbSetOrder(nOrdBAU))
		BAU->(DbGoTo(nRecBAU))
		SA2->(DbSetOrder(nOrdSA2))
		SA2->(DbGoTo(nRecSA2))
		
		aCritica := {"5","deve ser executada a rotina gerar pagto dividido antes de efetuar o pagamento.",0}
		Return(aCritica)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a RDA estiver bloqueada trata se pode gerar ou nao...            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(BAU->BAU_CODBLO) .And. ! lGerPagBlo
	aCritica := {"6","RDA Bloqueada. Nao e possivel gerar pagamento.",0}
	Return(aCritica)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for um pagamento de intercambio tratar regras especificas...     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BA0->(FieldPos("BA0_CONAJI")) > 0 .and. GetNewPar("MV_PLHACON","0") == "1" //habilita o controle de contestação via sistema?
	
	If !Empty(cLoteImp) .And. PLSALIASEX("BRJ") .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
		
		BA0->(DbSetOrder(1))
		If BA0->(MsSeek(xFilial("BA0")+BAU->BAU_CODOPE))
			
			cPagTot := "1" // pagar valor integral
			
			BRJ->(DbSetOrder(1))
			If BRJ->(DbSeek(xFilial("BRJ")+cLoteImp,.F.))
				
				Do While ! BRJ->(Eof()) .And. BRJ->(BRJ_FILIAL+BRJ_CODIGO) == xFilial("BRJ")+cLoteImp
					// Inserido tratamento para inibir erro de seleção, está faturando BD7 para um RDA e gerando título em outro RDA
					If BAU->BAU_CODOPE # BRJ->BRJ_OPEORI
						BRJ->(dbSkip())
						Loop
					EndIf 
					If BRJ->BRJ_REGPRI == "1" .And. BRJ->BRJ_STATUS == "1" //Registro Principal e Status "a Faturar"
						nRecnoBRJ  := BRJ->(Recno())
						lAtuaBRJPag := .T.
						
						If BRJ->(FieldPos("BRJ_TPPAG")) > 0 .And. BRJ->BRJ_TPPAG == "1".And. !lAneste
							
							nVlrFATINT := BRJ->BRJ_VALOR
							nVlrFATNDC := BRJ->BRJ_VLRNDC
							nVlrFATFAT := BRJ->BRJ_VLRFAT
							lPagInterc := .T.
							
							If BRJ->(FieldPos("BRJ_TIPORE")) > 0 .and. BRJ->(FieldPos("BRJ_PREFIR")) > 0 .and. ;
								BRJ->(FieldPos("BRJ_PARCER")) > 0 .and. BRJ->(FieldPos("BRJ_NUMREC")) > 0 .and. ;
								BRJ->(FieldPos("BRJ_FORNEC")) > 0 .and. BRJ->(FieldPos("BRJ_LOJA")) > 0
								
								SE2->(DbSetOrder(1))
								If SE2->(MsSeek(xFilial("SE2")+BRJ->(BRJ_PREFIR+BRJ_NUMREC+BRJ_PARCER+BRJ_TIPORE+BRJ_FORNEC+BRJ_LOJA)))
									nRecTitVin := SE2->(Recno())
								Endif
							EndIf
						Endif
						cPagTot := BRJ->BRJ_TPPAG
						Exit
					EndIf
					BRJ->(DbSkip())
				EndDo
			Endif
		Endif
	Endif
ElseIf !Empty(cLoteImp) .And. PLSALIASEX("BRJ") .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
	
		BRJ->(DbSetOrder(1))
		If BRJ->(msSeek(xFilial("BRJ")+cLoteImp))
			Do While ! BRJ->(Eof()) .And. BRJ->(BRJ_FILIAL+BRJ_CODIGO) == xFilial("BRJ")+cLoteImp
			
				If BRJ->BRJ_REGPRI == "1" .And. BRJ->BRJ_STATUS == "1" //Registro Principal e Status "a Faturar"
				
				// Inserido tratamento para inibir erro de seleção, está faturando BD7 para um RDA e gerando título em outro RDA
				If BAU->BAU_CODOPE # BRJ->BRJ_OPEORI
					BRJ->(dbSkip())
					Loop
				EndIf 
					nRecnoBRJ  := BRJ->(Recno())
					lAtuaBRJPag := .T.
					
				If BRJ->(FieldPos("BRJ_TPPAG")) > 0 .And. BRJ->BRJ_TPPAG == "1" .And. !lAneste
						nVlrFATINT := BRJ->BRJ_VALOR
						nVlrFATNDC := BRJ->BRJ_VLRNDC
						nVlrFATFAT := BRJ->BRJ_VLRFAT
						lPagInterc := .T.
						
						If BRJ->(FieldPos("BRJ_TIPORE")) > 0 .and. BRJ->(FieldPos("BRJ_PREFIR")) > 0 .and. ;
							BRJ->(FieldPos("BRJ_PARCER")) > 0 .and. BRJ->(FieldPos("BRJ_NUMREC")) > 0 .and. ;
							BRJ->(FieldPos("BRJ_FORNEC")) > 0 .and. BRJ->(FieldPos("BRJ_LOJA")) > 0
							
							SE2->(DbSetOrder(1))
							If SE2->(MsSeek(xFilial("SE2")+BRJ->(BRJ_PREFIR+BRJ_NUMREC+BRJ_PARCER+BRJ_TIPORE+BRJ_FORNEC+BRJ_LOJA)))
								nRecTitVin := SE2->(Recno())
							Endif
						Endif
					Endif
					cPagTot := BRJ->BRJ_TPPAG
					Exit
				EndIf
				BRJ->(DbSkip())
			EndDo
		Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica saldo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCalcImp := IF(BAU->(FieldPos("BAU_CALIMP"))>0,BAU->BAU_CALIMP,"2")

aSaldo := PLSLDCRE(BAU->BAU_CODIGO,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,;
					cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,BAU->BAU_CODSA2,BAU->BAU_LOJSA2,aLancPagto,;
					cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,cCodDC,lCalcImp,cCodNat,lGuiCob,;
               		/*lPgtDiv*/,.T.,/*lMudUs*/,/*nNewUs*/,nApUsDif,lAtuGui,cOpeLote,cLote,dVencto,cExcPeg,cTipTitInt,nPosTitInt,,lAneste)
                   
                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se saldo zero e teve movimentacao gera credito de 0.01 para gerar o titulo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aSaldo[10] .and. GetNewPar('MV_PLGER1C', .T.)	// 1.a .F.
	
	BBB->(DbSetOrder(1))
	If ! BBB->(DbSeek(xFilial("BBB")+cCodCreTit,.F.)) .Or. BBB->BBB_TIPSER == "1"
	
		BAU->(DbSetOrder(nOrdBAU))
		BAU->(DbGoTo(nRecBAU))
		SA2->(DbSetOrder(nOrdSA2))
		SA2->(DbGoTo(nRecSA2))
		
		aCritica := {"C","Parametro MV_PLSCDCT nao cadastrado ou invalido.",0}
		Return(aCritica)
	Endif
	
	If GetNewPar("MV_PLVLDEF", .T.)
   		BGQ->(RecLock("BGQ",.T.))
		BGQ->BGQ_FILIAL 	:= xFilial("BGQ")
		BGQ->BGQ_CODSEQ 	:= GETSX8NUM("BGQ","BGQ_CODSEQ")
		BGQ->BGQ_CODIGO 	:= BAU->BAU_CODIGO
		BGQ->BGQ_NOME   	:= BAU->BAU_NOME
		BGQ->BGQ_ANO    	:= cAno
		BGQ->BGQ_MES    	:= cMes
		BGQ->BGQ_CODLAN 	:= BBB->BBB_CODSER
		BGQ->BGQ_VALOR  	:= nValDefaut
		BGQ->BGQ_TIPO   	:= BBB->BBB_TIPSER
		BGQ->BGQ_TIPOCT 	:= BBB->BBB_TIPOCT
		BGQ->BGQ_INCIR  	:= BBB->BBB_INCIR
		BGQ->BGQ_INCINS 	:= BBB->BBB_INCINS
		BGQ->BGQ_INCPIS 	:= BBB->BBB_INCPIS
		BGQ->BGQ_INCCOF 	:= BBB->BBB_INCCOF
		BGQ->BGQ_INCCSL 	:= BBB->BBB_INCCSL
		BGQ->BGQ_VERBA  	:= BBB->BBB_VERBA
		BGQ->BGQ_CODOPE 	:= PlsIntPad()
		BGQ->BGQ_CONMFT 	:= BBB->BBB_CONMFT
		BGQ->BGQ_OBS    	:= "CREDITO GERADO PARA CRIAR O TITULO"
		BGQ->BGQ_LANAUT 	:= "1"
		BGQ->BGQ_OPELAU 	:= BAU->BAU_CODOPE
		BGQ->BGQ_NUMLAU 	:= "" //Sera gravado logo abaixo quando o titulo for gerado...
		BGQ->BGQ_INTERC		:= "0"
		If lBBB_INCISS .AND. lBGQ_INCISS
			BGQ->BGQ_INCISS := BBB->BBB_INCISS
		EndIf
		BGQ->(msUnLock())
		ConfirmSX8()
		nRecnoBGQ := BGQ->(Recno())
	Endif
    //Refaz o saldo...
    If Empty(cLoteImp)// nao devo refazer o saldo para pagamento de intercambio senao vai zerar o valor da glosa da BAF
	    aSaldo := PLSLDCRE(	BAU->BAU_CODIGO,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,;
 	     	           		cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,BAU->BAU_CODSA2,BAU->BAU_LOJSA2,aLancPagto,;
                    		cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,cCodDC,lCalcImp,cCodNat,lGuiCob,/*lPgtDiv*/,.T.,;
                     		/*lMudUs*/,/*nNewUs*/,/*nApUsDif*/,/*lAtuGui*/,/*cOpeLote*/,/*cLote*/,/*dVencto*/,cExcPeg,cTipTitInt,nPosTitInt)
	EndIf
Endif

// Ponto de Entrada criado em 21/06/2006 - BOPS 101839
If ExistBlock("PLVLRNF")
	aRetVLRNF := ExecBlock("PLVLRNF",.F.,.F.,{ aSaldo, cAno, cMes, cPrefixo, cNumero })
	If aRetVLRNF[1]
		aSaldo := PLSLDCRE(BAU->BAU_CODIGO,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,;
		                   cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,BAU->BAU_CODSA2,BAU->BAU_LOJSA2,aLancPagto,;
		                   cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,cCodDC,lCalcImp,cCodNat,lGuiCob,/*lPgtDiv*/,/*lGerLot*/,;
		                   /*lMudUs*/,/*nNewUs*/,nApUsDif,lAtuGui,cOpeLote,cLote,/*dVencto*/,cExcPeg,cTipTitInt,nPosTitInt)
	EndIf     
	If aSaldo[1]
		nVrDecresc  := aRetVLRNF[2]
		aSaldo[4,1] += aRetVLRNF[2]
		
		nVrAcresc   := aRetVLRNF[3]
		aSaldo[4,1] -= aRetVLRNF[3]
	Else
		nVrDecresc  := 0
		nVrAcresc   := 0
	EndIf
Else
	nVrAcresc  := 0
	nVrDecresc := 0
Endif

// Tipo 4 - Calcula varios pagamentos no mes com impostos sem provisionar - LA 20100619
If GetNewPar("MV_PLPGUNI","1") $ "3,4"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca bases e impostos ja calculados no mes para a RDA              				³
	//³ Este array sera usado no calculo dos impostos - implementacao feita 				³
	//³ para atender a necessidade de calcular mais de um pagamento no mes. 				³
	//³ Melhoria para atendimento a parametrizacao financeira e a Lei 10925 - RC 20100416.. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Envio array com conteudo dos impostos a calcular pela emissao (.T.) ou pelo vencimento (.F.)
	// aTpCalc	[1]	- IRRF
	// 			[2] - INSS
	//			[3] - PIS / Cofins / CSLL
	// Analiso condicoes da lei atual para o IRRF (16/04/2010): PJ sempre na emissao; PF configuravel no parametro MV_VENCIRF
	aAdd( aTpCalc, IIf(BAU->BAU_TIPPE == 'J', .T., IIf( GetNewPar('MV_VENCIRF','E')=='E', .T., .F. )  )  )

	// Condicoes atuais para INSS (16/04/2010): PF na competencia, PJ nao ha
	aAdd( aTpCalc, BAU->BAU_TIPPE == 'F' )

	// Condicoes atuais para PIS / Cofins / CSLL (16/04/2010): PF nao calcula, PJ depende do parametro MV_BX10925. Tratamento direto no módulo financeiro
	aAdd( aTpCalc, IIf(BAU->BAU_TIPPE == 'F', .F., IIf( GetNewPar('MV_BX10925','2')=='2', .T., .F. )  )  )
	aImpMes := PLSPGTMES(cCodRDA, cAno, cMes, PlsIntPad(), aTpCalc, StrZero(Year(dVencto),4), StrZero(Month(dVencto),2),cCalcImp,lUltCalc )
Else
	aImpMes := { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao tenha movimentacao e tambem nao tenha lancamentos de Cre-  ³
//³ dito de Provisao de INSS ou nao seja o Ultimo Calculo, gera critica.³
//³ aSaldo[1] => indica que tem saldo (positivo ou negativo)            ³
//³ aSaldo[9] => indica que base para impostos                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								// Prov.Inss PJ + Prov.INSS PF + Prov.INSS JF + Prov.INSS HP
If ! aSaldo[1] .And. ! aSaldo[9] .And. (aImpMes[8]+aImpMes[9]+aImpMes[12]+aImpMes[24] == 0 .Or. ! lUltCalc)
	
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	
	// Quando Intercambio Não houver Pagto e glosar 100% a importação
	If lPagInterc .And. Empty(aSaldo[4])
		nValorPag:=0
	Else
		aCritica := {"D","Nao existem movimentacoes neste Ano/Mes",0}
		Return(aCritica)
	Endif
		// nInssPJ + nInssPF + nInssJF + nInssHP + nInssBU
ElseIf aImpMes[3]+aImpMes[5]+aImpMes[11]+aImpMes[22]+aImpMes[27] > 0 .And. !lPgtoImp
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	
	aCritica := {"I","Ultimo calculo ja efetuado para este RDA neste Ano/Mes",0}
	Return(aCritica)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao tenha movimentacao mas tenha lancamentos de Credito de     ³
	//³ Provisao de INSS, atualiza array com zero para evitar erro na linha ³
	//³ abaixo: "nValorPag := aSaldo[4,1]"                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 					Prov.Inss PJ + Prov.INSS PF + Prov.INSS JF + Prov.INSS HP
	If ! aSaldo[1] .And. (aImpMes[8]+aImpMes[9]+aImpMes[12]+aImpMes[24] > 0 .or. lUltCalc)
		aAdd(aSaldo[4], 0)
	EndIf
	aVerbasFol	:= aSaldo[3]
	aCompPag  	:= aSaldo[2] // Composicao do Pagamento
	nValorPag 	:= aSaldo[4,1]
	aCompPagD 	:= aSaldo[5]
	aSEFIP   	:= aSaldo[6]
	nVrIRRet  	:= aSaldo[8] 
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento da natureza do titulo...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ! ExistBlock("PLNATESP")
	If  ! empty(cCodNat) // natureza informada no pergunte
		cNaturez := cCodNat
	Else
		cNaturez := SA2->A2_NATUREZ
		If  Empty(cNaturez) .Or. ! Eval({|| SED->(DbSetOrder(1)), SED->(DbSeek(xFilial("SED")+cNaturez,.F.)) })
			BAU->(DbSetOrder(nOrdBAU))
			BAU->(DbGoTo(nRecBAU))
			SA2->(DbSetOrder(nOrdSA2))
			SA2->(DbGoTo(nRecSA2))
			aCritica := {"9","Natureza do credenciado invalida",0}
			Return(aCritica)
		Endif
	Endif
Else
	cNaturez := ExecBLock("PLNATESP",.F.,.F.)
	If ValType(cNaturez) <> "C" .Or. ! Eval({|| SED->(DbSetOrder(1)), SED->(DbSeek(xFilial("SED")+cNaturez,.F.)) })
		BAU->(DbSetOrder(nOrdBAU))
		BAU->(DbGoTo(nRecBAU))
		SA2->(DbSetOrder(nOrdSA2))
		SA2->(DbGoTo(nRecSA2))
		
		aCritica := {"A","Ponto de entrada PLNATESP invalido",0}
		Return(aCritica)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a chave do titulo ja nao existe na base (seguranca)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SE2->(DbSetOrder(1))
If SE2->(DbSeek(xFilial("SE2")+cPrefixo+cNumero+cParcela+cTipo+cCodForn+cLoja,.F.))
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	
	aCritica := {"B","Prefixo+Numero+Parcela+Tipo+Fornecedor+Loja ja existe",0}
	Return(aCritica)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for um pagamento de intercambio vou comparar a fatura com o saldo a pagar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPagInterc    
	If cCalcImp $ '2,3,4'		// Financeiro ou Folha-Financeiro  
		nGlosaPag := Iif(Len(aSaldo)>12,aSaldo[13],0)
	Else
		nGlosaPag := IIf(nVlrFATINT > nValorPag, nVlrFATINT-nValorPag, 0 )
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o valor de glosa for maior que zero, irei lancar um debito contra a rda...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nGlosaPag > 0		// Só terá valor se for intercâmbio
	BBB->(DbSetOrder(1))
	If ! BBB->(DbSeek(xFilial("BBB")+cCodCreGlo,.F.)) .Or. BBB->BBB_TIPSER == "1"
		BAU->(DbSetOrder(nOrdBAU))
		BAU->(DbGoTo(nRecBAU))
		SA2->(DbSetOrder(nOrdSA2))
		SA2->(DbGoTo(nRecSA2))
		
		aCritica := {"8","Parametro MV_PLSCDCG nao cadastrado ou invalido.",0}
		Return(aCritica)
	Endif
	
	BGQ->(RecLock("BGQ",.T.))
		BGQ->BGQ_FILIAL	:= xFilial("BGQ")
		BGQ->BGQ_CODSEQ 	:= GETSX8NUM("BGQ","BGQ_CODSEQ")
		BGQ->BGQ_CODIGO 	:= BAU->BAU_CODIGO
		BGQ->BGQ_NOME   	:= BAU->BAU_NOME
		BGQ->BGQ_ANO    	:= cAno
		BGQ->BGQ_MES    	:= cMes
		BGQ->BGQ_CODLAN 	:= BBB->BBB_CODSER
		BGQ->BGQ_VALOR  	:= nGlosaPag
		BGQ->BGQ_TIPO   	:= BBB->BBB_TIPSER
		BGQ->BGQ_TIPOCT 	:= BBB->BBB_TIPOCT
		BGQ->BGQ_INCIR  	:= BBB->BBB_INCIR
		BGQ->BGQ_INCINS 	:= BBB->BBB_INCINS
		BGQ->BGQ_INCPIS 	:= BBB->BBB_INCPIS
		BGQ->BGQ_INCCOF 	:= BBB->BBB_INCCOF
		BGQ->BGQ_INCCSL 	:= BBB->BBB_INCCSL
		BGQ->BGQ_VERBA  	:= BBB->BBB_VERBA
		BGQ->BGQ_CODOPE 	:= PlsIntPad()
		BGQ->BGQ_CONMFT 	:= BBB->BBB_CONMFT
		BGQ->BGQ_OBS    	:= "GERADO PELA ROTINA DE LOTE PAGAMENTO"
		BGQ->BGQ_LANAUT 	:= "1"
		BGQ->BGQ_OPELAU 	:= BAU->BAU_CODOPE
		BGQ->BGQ_NUMLAU 	:= "" //Sera gravado logo abaixo quando o titulo for gerado...
		BGQ->BGQ_INTERC 	:= "0"
		BGQ->BGQ_NUMLOT 	:= cLote
		BGQ->BGQ_OPELOT 	:= cOpeLote
		BGQ->BGQ_ATIVO		:= '1'
		BGQ->BGQ_INTERC 	:= IIf(Empty(cLoteImp),'0','1')
		If lBBB_INCISS .AND. lBGQ_INCISS
			BGQ->BGQ_INCISS := BBB->BBB_INCISS
		EndIf
	BGQ->(msUnLock())
	ConfirmSX8()
	lCriadoBGQAut	:= .T.
	nRecnoBGQ		:= BGQ->(Recno())
	
	// No caso de Intercâmbio Tipo 3, como passa novamente na função, já realiza a atualização 
	If cTipTitInt $ '1-2'
		// Fazer a gravação do 104 no aSaldo, para passar ao aCompPag, quando não for Intercambio Tipo 3.
		BLR->(dbSetOrder(1))
		BLR->(dbSeek(xFilial('BLR')+PlsIntPad()+'104',.F.))
		aCopSld := aClone(aSaldo[2])
		nInd := aScan(aCopSld, { |x| x[3]+AllTrim(x[4])+AllTrim(x[5]) == '104'+AllTrim(BLR->BLR_DESCRI)+AllTrim(BLR->BLR_IMG) } )
		If nInd == 0
			aAdd( aSaldo[2], { BLR->BLR_DEBCRE,	nGlosaPag, '104', BLR->BLR_DESCRI, BLR->BLR_IMG, '104', "BGQ", '', ''} )
		Else
			aSaldo[2,nInd,2] += nGlosaPag
		EndIf
		// Se for ajustar total: aSaldo[4,1]
	EndIf

	If ! aSaldo[1]
		If	lCriadoBGQAut
			BGQ->(RecLock("BGQ",.F.))
			BGQ->(DbDelete())
			BGQ->(MsUnLock())
		Endif
		
		BAU->(DbSetOrder(nOrdBAU))
		BAU->(DbGoTo(nRecBAU))
		SA2->(DbSetOrder(nOrdSA2))
		SA2->(DbGoTo(nRecSA2))
		
		aCritica := {"D","Nao existem movimentacoes neste Ano/Mes",0}
		Return(aCritica)
	Else
		aVerbasFol	:= aSaldo[3]
		aCompPag  	:= aSaldo[2] // Composicao do Pagamento
		nValorPag 	:= aSaldo[4,1]
		aCompPagD 	:= aSaldo[5]
		aSEFIP    	:= aSaldo[6]
		nVrIRRet  	:= aSaldo[8]
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geração de Dedito/Credito para Us diferenciada                              .³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Indica se o tratamento odontologico esta ativo no ambiente Plano de Saude.
If nApUsdif == 1 .and. (nPos := Ascan(aSaldo[2],{|x| X[3] = "101"})) > 0 .and.	(aSaldo[12,1] > 0 .OR. aSaldo[12,2] > 0) .and. GetNewPar("MV_PLATIOD","0") == '1' 

	If aSaldo[12,1] > 0

		PlsBGQLanc(cCodDebUdf,"2",nOrdBAU,nRecBAU,nOrdSA2,nRecSA2,@aCritica,cAno,cMes,"1",aSaldo[12,1],"Parametro MV_PLSDUDF nao cadastrado ou invalido.")
		
		If Len(aCritica) = 0
			nRecnoBGQ	:= BGQ->(Recno())
			nValDbBGQ	:= aSaldo[12,1]
			
			//Refaz o saldo...
		    aSaldo := PLSLDCRE(BAU->BAU_CODIGO,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,;
	          	               cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,BAU->BAU_CODSA2,BAU->BAU_LOJSA2,aLancPagto,;
	                           cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,cCodDC,lCalcImp,cCodNat,lGuiCob,;
	                           /*lPgtDiv*/,/*lGerLot*/,/*lMudUs*/,/*nNewUs*/,/*nApUsDif*/,/*lAtuGui*/,/*cOpeLote*/,;
	                           /*clote*/,/*dVencto*/,cExcPeg)

			If ! aSaldo[1]
				BGQ->(RecLock("BGQ",.F.))
				BGQ->(DbDelete())
				BGQ->(MsUnLock())
				
				BAU->(DbSetOrder(nOrdBAU))
				BAU->(DbGoTo(nRecBAU))
				SA2->(DbSetOrder(nOrdSA2))
				SA2->(DbGoTo(nRecSA2))
				
				aCritica := {"D","Nao existem movimentacoes neste Ano/Mes",0}
				Return(aCritica)
			Else
				aVerbasFol	:= aSaldo[3]
				aCompPag  	:= aSaldo[2] // Composicao do Pagamento
				nValorPag 	:= aSaldo[4,1]
				aCompPagD 	:= aSaldo[5]
				aSEFIP   	:= aSaldo[6]
				
			Endif
			
			PlsBGQLanc(cCodRestUdf,"1",nOrdBAU,nRecBAU,nOrdSA2,nRecSA2,@aCritica,cAno,cMes,"0",nValDbBGQ,"Parametro MV_PLSRUDF nao cadastrado ou invalido.")
			
		EndIf
	EndIf
	
	If aSaldo[12,2] > 0
	
		PlsBGQLanc(cCodCreUdf,"1",nOrdBAU,nRecBAU,nOrdSA2,nRecSA2,@aCritica,cAno,cMes,"1",aSaldo[12,2],"Parametro MV_PLSCUDF nao cadastrado ou invalido.")
		
		If Len(aCritica) = 0
			nRecnoBGQ	:= BGQ->(Recno())
			
			//Refaz o saldo...
		   	aSaldo := PLSLDCRE(BAU->BAU_CODIGO,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,;
	                          cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,BAU->BAU_CODSA2,BAU->BAU_LOJSA2,aLancPagto,;
	                          cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,cCodDC,lCalcImp,cCodNat,lGuiCob,;
							  /*lPgtDiv*/,/*lGerLot*/,/*lMudUs*/,/*nNewUs*/,/*nApUsDif*/,/*lAtuGui*/,/*cOpeLote*/,;
	                          /*clote*/,/*dVencto*/,cExcPeg)


			If ! aSaldo[1]
			
				BGQ->(RecLock("BGQ",.F.))
				BGQ->(DbDelete())
				BGQ->(MsUnLock())
				
				BAU->(DbSetOrder(nOrdBAU))
				BAU->(DbGoTo(nRecBAU))
				SA2->(DbSetOrder(nOrdSA2))
				SA2->(DbGoTo(nRecSA2))
				
				aCritica := {"D","Nao existem movimentacoes neste Ano/Mes",0}
				Return(aCritica)
				
			Else
				aVerbasFol	:= aSaldo[3]
				aCompPag  	:= aSaldo[2] // Composicao do Pagamento
				nValorPag 	:= aSaldo[4,1]
				aCompPagD 	:= aSaldo[5]
				aSEFIP		:= aSaldo[6]
			Endif
			
		EndIf
		
	EndIf
Endif

If cPagTot == "1"

	If cTipTitInt == "3"   
		Iif(nPosTitInt == 1,nValorPag := nVlrFATNDC, nValorPag := nVlrFATFAT) 
	Else
		nValorPag := nVlrFATINT
	EndIf
	
EndIf

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Grava tabela B15 - BASES INSS PAGAMENTOS RDA'S - SEFIP                         ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Ordena Tabela aSEFIP por CODEMP / CONEMP / SUBCON / MATRIC / CALCIMP           ³
// ³ aSEFIP:                                                                        ³
// ³ 1 - Codigo da Empresa/Grupo                                                    ³
// ³ 2 - Contrato                                                                   ³
// ³ 3 - SubContrato                                                                ³
// ³ 4 - Matricula Familia                                                          ³
// ³ 5 - Calcula Imposto: 1 ou 3 - Integracao com Folha de Pagamento                ³
// ³ 6 - Base INSS Pessoa Fisica                                                    ³
// ³ 7 - Base INSS Pessoa Juridica                                                  ³
// ³ 8 - Base INSS Juridica Filantropica                                            ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aSEFIP,,, { |x,y| x[1]+x[2]+x[3]+x[4]+x[5] > y[1]+y[2]+y[3]+y[4]+y[5]})

cCodEmp  := Space(4)
cConEmp  := Space(12)
cSubCon  := Space(9)
cMatric  := Space(6)

// BOPS 104251 - Trata valores negativos para evitar diferencas no calculo do INSS
For nInd := Len(aSEFIP) To 1 Step -1
	
	If aSEFIP[nInd, 6] < 0
		PlsAjSEFIP(aSEFIP, nInd, 6)
	EndIf
	If aSEFIP[nInd, 7] < 0
		PlsAjSEFIP(aSEFIP, nInd, 7)
	EndIf
	If aSEFIP[nInd, 8] < 0
		PlsAjSEFIP(aSEFIP, nInd, 8)
	EndIf
	If aSEFIP[nInd, 9] < 0
		PlsAjSEFIP(aSEFIP, nInd, 9)
	EndIf
	
Next nInd

For nInd := 1 To Len(aSEFIP)

	If ! aSEFIP[nInd, 5] $ "3,4" .Or. ; // Integracao com Folha de Pagamento
		aSEFIP[nInd, 6] + aSEFIP[nInd, 7] + aSEFIP[nInd, 8] + aSEFIP[nInd, 9] == 0 // Nao há nenhum valor
		Loop
	EndIf
	
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³ Se CONEMP/SUBCON for diferente de "", foi gravado o BGQ             ³
	// ³ Verifica nivel de cobranca do SubContrato/Contrato/Empresa e define ³
	// ³ cliente/loja                                                        ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aSEFIP[nInd, 2]+aSEFIP[nInd, 3])
	
		If cCodEmp+cConEmp+cSubCon <> aSEFIP[nInd, 1]+aSEFIP[nInd, 2]+aSEFIP[nInd, 3]
	
			cCodEmp  := aSEFIP[nInd, 1]
			cConEmp  := aSEFIP[nInd, 2]
			cSubCon  := aSEFIP[nInd, 3]
			// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// ³ Branca Cliente/Loja pois se nao encontrar SubContrato/Contra ³
			// ³ to/Empresa ira considerar a propria OPERADORA como o TOMADOR ³
			// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCliente := Space(6)
			cLojaCli := Space(2)
			
			// Posiciona BG9 - Grupo/Empresa
			BG9->(DbSetOrder(1))
			BG9->(DbSeek(xFilial("BG9")+cCodOpe+cCodEmp,.F.))
			
			// Posiciona BT5 - Contrato
			BT5->(DbSetOrder(1))
			BT5->(DbSeek(xFilial("BT5")+cCodOpe+cCodEmp+cConEmp,.F.))
			
			// Posiciona BQC - Sub-Contrato
			BQC->(DbSetOrder(1))
			BQC->(DbSeek(xFilial("BQC")+cCodOpe+cCodEmp+cConEmp+BT5->BT5_VERSAO+cSubCon,.F.))
			
			If BQC->BQC_COBNIV == "1" .And.  ! Empty(BQC->BQC_CODCLI)
				cCliente := BQC->BQC_CODCLI
				cLojaCli := BQC->BQC_LOJA
			ElseIf BT5->BT5_COBNIV == "1" .And.  ! Empty(BT5->BT5_CODCLI)
				
				If BT5->BT5_INTERC == "1" .And. AllTrim(BT5->BT5_TIPOIN) == GetNewPar("MV_PLSCDIE","1")// Eventual
					BA0->(DbSetOrder(1))
					If BA0->(DbSeek(xFilial("BA0")+cOpeOri,.F.)) .And. ! Empty(BA0->BA0_CODCLI)
						cCliente := BA0->BA0_CODCLI
						cLojaCli := BA0->BA0_LOJA
						BA0->(DbSetOrder(nOrdBA0))
						BA0->(DbGoTo(nRecBA0))
					Endif
				Else
					cCliente := BT5->BT5_CODCLI
					cLojaCli := BT5->BT5_LOJA
				Endif
				
			ElseIf ! Empty(BG9->BG9_CODCLI)
				cCliente := BG9->BG9_CODCLI
				cLojaCli := BG9->BG9_LOJA
			Endif
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+cCliente+cLojaCli,.F.))
				// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				// ³ "Pessoa Fisica" ira considerar a propria Cooperativa como o TOMADOR ³
				// ³ por isso branca Cliente/Loja (desde que nao possua CEI)             ³
				// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (IIf(lA1_CEINSS, Empty(SA1->A1_CEINSS), .T.) .And. ;
					IIf(lBQC_CLAINS, BQC->BQC_CLAINS == "1", .F.)) // BQC_CLAINS igual a "1" trata como PESSOA FISICA
					cCliente := Space(6)
					cLojaCli := Space(2)
				EndIf
			Else
				cCliente := Space(6)
				cLojaCli := Space(2)
			EndIf
			
		EndIf
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³ Se CODEMP/MATRIC igual a "", branca Cliente/Loja para que seja con- ³
	// ³ siderado o TOMADOR como a propria OPERADORA. Esses registros foram  ³
	// ³ gravados a partir das tabelas BBC, BCE e, em alguns casos, do BGQ   ³
	// ³ e nao foi possivel definir nivel de cobranca.                       ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf Empty(aSEFIP[nInd, 1]+aSEFIP[nInd, 4])
		cCliente := Space(6)
		cLojaCli := Space(2)
	Else
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// ³ Se trocou CODEMP/MATRIC, posiciona arquivos e executa        ³
		// ³ PLSRETNCB para retornar nivel de cobranca                    ³
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCodEmp+cMatric <> aSEFIP[nInd, 1]+aSEFIP[nInd, 4]
			cCodEmp  := aSEFIP[nInd, 1]
			cMatric  := aSEFIP[nInd, 4]
			// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// ³ Branca Cliente/Loja pois se nao encontrar usuario/familia,   ³
			// ³ ira considerar a propria OPERADORA como o TOMADOR            ³
			// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCliente := Space(6)
			cLojaCli := Space(2)
			// Posiciona BA1 - Usuario
			BA1->(DbSetOrder(1))
			If BA1->(DbSeek(xFilial("BA1")+cCodOpe+cCodEmp+cMatric,.F.))
				// Posiciona BA3 - Familia
				BA3->(DbSetOrder(1))
				If BA3->(DbSeek(xFilial("BA3")+cCodOpe+BA1->(BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB),.F.))
					// Posiciona BG9 - Grupo/Empresa
					BG9->(DbSetOrder(1))
					BG9->(DbSeek(xFilial("BG9")+cCodOpe+BA1->BA1_CODEMP,.F.))
					// Posiciona BT5 - Contrato
					BT5->(DbSetOrder(1))
					BT5->(DbSeek(xFilial("BT5")+cCodOpe+BA1->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON),.F.))
					// Posiciona BQC - Sub-Contrato
					BQC->(DbSetOrder(1))
					BQC->(DbSeek(xFilial("BQC")+cCodOpe+BA1->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB),.F.))

					aRetCli := PLSRETNCB(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,BA1->BA1_OPEORI)

					If aRetCli[1]
						// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						// ³ "Pessoa Fisica" ira considerar a propria Cooperativa como o TOMADOR ³
						// ³ por isso branca Cliente/Loja (desde que nao possua CEI)             ³
						// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (IIf(lA1_CEINSS, Empty(SA1->A1_CEINSS), .T.) .And. ;
							IIf(lBQC_CLAINS, BQC->BQC_CLAINS == "1", .F.)) // BQC_CLAINS igual a "1" trata como PESSOA FISICA
							cCliente := Space(6)
							cLojaCli := Space(2)
						Else
							cCliente := aRetCli[2]
							cLojaCli := aRetCli[3]
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	B15->(DbSetOrder(1))
	If  !B15->(DbSeek(xFilial("B15")+cCodOpe+cAno+cMes+SubStr(cLote, 7, 4)+cCodRDA+cCliente+cLojaCli,.F.))
		B15->(RecLock("B15",.T.))
		B15->B15_FILIAL := xFilial("B15")
		B15->B15_OPERDA := cCodOpe
      	B15->B15_ANOLOT := cAno
       	B15->B15_MESLOT := cMes	
		B15->B15_NUMLOT := SubStr(cLote,7,4)
		B15->B15_CODRDA := cCodRda
		B15->B15_CLIENT := cCliente
		B15->B15_LOJA   := cLojaCli
	Else
		B15->(RecLock("B15",.F.))
	EndIf
	
	If !Empty(IIf(lBAU_BASINS, BAU->BAU_BASINS, ""))
		If  BAU->BAU_TIPPE == "J" .OR. BAU->BAU_BASINS # "0" // 0=Nao;1=Sim
			lINSS182 := .T.
		EndIf
	Else
		lINSS182 := .T.
	EndIf
	
	If lINSS182 
		B15->B15_BASEPJ += (aSEFIP[nInd, 6] + aSEFIP[nInd, 7] + aSEFIP[nInd, 8] + aSEFIP[nInd, 9])
	Else
		B15->B15_BASEPF += aSEFIP[nInd, 6]
		B15->B15_BASEPJ += aSEFIP[nInd, 7]
		B15->B15_BASEJF += aSEFIP[nInd, 8]
		B15->B15_BASEHP += aSEFIP[nInd, 9]
	EndIf
	B15->(MsUnlock())
	
Next nInd
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre a transacao...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona condicao de pagamento - odontologico						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aSaldo) >= 11 .and. GetNewPar("MV_PLATIOD","0") == '1'  //Indica se o tratamento odontologico esta ativo no ambiente Plano de Saude.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta query                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := " SELECT BZ2_CPAGTO "
	cSQL += " FROM " + RetSQLName("BZ2")
	cSQL += " WHERE BZ2_FILIAL =  '" + xFilial("BZ2") + "' AND "
	cSQL += " BZ2_CODIGO = '" + cCodRDA + "' AND "
	cSQL += " BZ2_CODINT = '" + cCodOpe + "' AND "
	cSQL += Alltrim(Str(Round(aSaldo[11],0))) + " BETWEEN BZ2_FAIDE AND BZ2_FAIATE AND "
	cSQL += " D_E_L_E_T_ = ' '  "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa query                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBZ2",.F.,.T.)	
	
	cCondPag := TrbBZ2->BZ2_CPAGTO
	
	TRBBZ2->(DbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pagamento com calculo de impostos atraves do financeiro             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  cCalcImp == "2"
	
	nVlrSE2 	:= 0
	nVlrDebVar 	:= 0
	
	for nImp := 1 to Len(aCompPag)
		nVlrSE2 	+= iif(aCompPag[nImp,1] == "2", aCompPag[nImp,2], 0 )
		nVlrDebVar	+= iif(aCompPag[nImp,1] == "1", aCompPag[nImp,2], 0 )
	next
	
	nPos := Ascan(aCompPag,{|x| x[3]== "182"})   // Base INSS - quando imposto calculado pelo financeiro e base unificada
	If  nPos > 0
		nValorBINS += aCompPag[nPos,2]
		nForSE2Lim := 1
	Else 	
	
		nPos := Ascan(aCompPag,{|x| x[3]== "192"})   // Base INSS PF
		If  nPos > 0
			nValorBINS += aCompPag[nPos,2]
			nValorBIN1 += aCompPag[nPos,2]
			nForSE2Lim++
		Endif
		
		nPos := Ascan(aCompPag,{|x| x[3]== "194"})   // Base INSS PJ
		If  nPos > 0
			nValorBINS += aCompPag[nPos,2]
			nValorBIN2 += aCompPag[nPos,2]
			nForSE2Lim++
		Endif
		
		nPos := Ascan(aCompPag,{|x| x[3]== "196"})   // Base INSS PF fins filantropicos
		If  nPos > 0
			nValorBINS += aCompPag[nPos,2]
			nValorBIN3 += aCompPag[nPos,2]
			nForSE2Lim++
		Endif
		
		nPos := Ascan(aCompPag,{|x| x[3]== "167"})   // Base INSS Honorário Patronal
		If  nPos > 0
			nValorBINS += aCompPag[nPos,2]
			nValorBIN4 += aCompPag[nPos,2]
			nForSE2Lim++
		EndIf

	EndIf
	
	nPos := Ascan(aCompPag,{|x| x[3]== "198"})  // Base IR
	If  nPos > 0
		nValorBIR += aCompPag[nPos,2]
	Endif
	
	nPos := Ascan(aCompPag,{|x| x[3]== "188"})   // Base Cofins
	If  nPos > 0
		nValorBCOF += aCompPag[nPos,2]
	Endif
	
	nPos := Ascan(aCompPag,{|x| x[3]== "190"})   // Base CSL
	If  nPos > 0
		nValorBCSL += aCompPag[nPos,2]
	Endif
	
	nPos := Ascan(aCompPag,{|x| x[3]== "186"})   // Base PIS
	If  nPos > 0
		nValorBPIS += aCompPag[nPos,2]
	Endif
	
	nPos := Ascan(aCompPag,{|x| x[3]== "184"})   // Base ISS
	If  nPos > 0
		nValorBISS += aCompPag[nPos,2]
	Endif
	nValorBSES := 0 //Nao possui
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ necessario para o financeiro nao considerar o e2_valor na base zero                 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If cTipTitInt == "2"
		nVlrSE2	:= Iif(nVlrFatInt > 0,nVlrFatInt,IIf(nVlrSE2 > 0, nVlrSE2, 0) )
	ElseIf cTipTitInt == "3"		
		nVlrSE2 := Iif(nPosTitInt == 1, nVlrFATNDC, nVlrFATFAT )	 
	ElseIf cTipTitInt == "1"
		nVlrSE2	:= iif(nVlrSE2 < 0, 0, nVlrSE2 )
	EndIf  
	
	cNomForn := Posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ")
	cNaturez := posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NATUREZ")		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄˆ¿
	//³Com a nova versao do fina050 devemos informar as bases para que o mesmo no execauto faça os calaulos respeitando a natureza.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄˆÙ
	nValorBIR	:= Iif(nValorBIR  <= 0 .and. nVlrSE2 > 0, nVlrSE2, Iif(nValorBIR  < 0, 0, nValorBIR ))
	nValorBPIS	:= Iif(nValorBPIS <= 0 .and. nVlrSE2 > 0, nVlrSE2, Iif(nValorBIR  < 0, 0, nValorBPIS))
	nValorBCOF	:= Iif(nValorBCOF <= 0 .and. nVlrSE2 > 0, nVlrSE2, Iif(nValorBCOF < 0, 0, nValorBCOF))
	nValorBCSL	:= Iif(nValorBCSL <= 0 .and. nVlrSE2 > 0, nVlrSE2, Iif(nValorBCSL < 0, 0, nValorBCSL))
	nValorBINS	:= Iif(nValorBINS <= 0 .and. nVlrSE2 > 0, nVlrSE2, Iif(nValorBINS < 0, 0, nValorBINS))
	nValorBISS	:= Iif(nValorBISS <= 0 .and. nVlrSE2 > 0, nVlrSE2, Iif(nValorBISS < 0, 0, nValorBISS))
	// se for pessoa juridica, ou se esta usando apenas uma natureza (nao diferencia as bases), ou eh PF mas ja nem tem base mais para a competencia
	// ou está configurado com base única de INSS
	If BAU->BAU_TIPPE == 'J' .or. (nForSE2Lim == 0 .and. nVlrSE2 > 0) .or. BAU->BAU_BASINS == '1' .or.; 
		( cNatPF == cNatPJ .and. cNatPJ == cNatFT .and. cNatFT == cNatHP ) 
		nForSE2Lim := 1
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Define dados para inclusao via rotina automatica...                 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	aBasesImp := {nValorBIR,nValorBCOF,nValorBISS,nValorBCSL,nValorBPIS,nValorBINS,nValorBSES, nVlrSE2}
	
	aINSSE2		:= { nValorBIN1, nValorBIN2, nValorBIN3, nValorBIN4 }
	SE2->(DbSetOrder(1))
	For nForSE2 := 1 TO nForSE2Lim
		
		If nVlrSE2 <= 0
			Exit
		EndIf
	
		If nForSE2 > 1
			If Empty(cNumero)
				cNumero  := GetMV("MV_PLNUME2")
            	cNumero  := Eval({|| &cNumero  })           	
            EndIf	

			cParcela := StrZero( nForSE2-1, Len(cParcela) )
			While SE2->(DbSeek(xFilial("SE2")+cPrefixo+cNumero+cParcela+cTipo+cCodForn+cLoja,.F.)) .and. nTenta < 200
				cNumero := Soma1(cNumero)
				/// Abre controle de semáforos da numeração do Titulo
				cChaveSem := "PLSMPAG"+cNumero+".SMF"
				nHNumPag  := PLSAbreSem(cChaveSem)
				While nHNumPag == 0
					cNumero  := Soma1(cNumero)	
					PLSAFechaSem(nHNumPag,cChaveSem)
					nHNumPag := PLSAbreSem(cChaveSem)
				EndDo
				nTenta ++ 
			EndDo
			
			If SE2->(Found())		
				aCritica := {"B","Prefixo+Numero+Parcela+Tipo+Fornecedor+Loja ja existe",0}
				Return(aCritica)
			EndIf
		EndIf

	aCampos :=	{	{"E2_FILIAL" 	,xFilial("SE2")     ,NIL},;
					{"E2_PREFIXO"	,cPrefixo           ,Nil},;
					{"E2_NUM"		,cNumero            ,Nil},;
					{"E2_PARCELA"	,cParcela           ,Nil},;
					{"E2_TIPO"		,cTipo              ,Nil},;
					{"E2_FORNECE"	,cCodForn           ,Nil},;
					{"E2_LOJA"		,cLoja              ,Nil},;
					{"E2_NOMFOR"	,cNomForn,Nil},;
					{"E2_EMISSAO"	,iif(AllTrim(cTipo) == "PA",dVencto,dDataBase)	,NIL},;
					{"E2_EMIS1"  	,iif(AllTrim(cTipo) == "PA",dVencto,dDataBase)	,NIL},;
					{"E2_VENCTO"	,dVencto            ,NIL},;
					{"E2_VENCREA" 	,DataValida(dVencto),NIL},;
					{"E2_VENCORI" 	,dVencto            ,NIL},;
					{"E2_DECRESC" 	,nVrDecresc         ,NIL},;
					{"E2_ACRESC"  	,nVrAcresc          ,NIL},;
					{"E2_PLLOTE"  	,cLote              ,NIL},;
					{"E2_PLOPELT" 	,cOpeLote          	,NIL},;
					{"E2_CODRDA"  	,cCodRda           	,NIL},;
					{"E2_ANOBASE" 	,cAno              	,NIL},;
					{"E2_MESBASE" 	,cMes              	,NIL} }
		
	aadd(aCampos,{"E2_DESDOBR" 	,"N"		,NIL})
	aadd(aCampos,{"E2_DIRF" 	,"1"		,NIL})
	aadd(aCampos,{"E2_HIST" 	,cHisTit	,NIL})
	aadd(aCampos,{"E2_DATAAGE" 	,DataValida(dVencto)	,NIL})
	aadd(aCampos,{"E2_ORIGEM"	,"PLSMPAG"	,NIL})
	
	If AllTrim(cTipo) == "PA" 
		aadd(aCampos,{"AUTBANCO"    ,posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_BANCO"),Nil })
		aadd(aCampos,{"AUTAGENCIA"  ,posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_AGENCIA"),Nil})
		aadd(aCampos,{"AUTCONTA"    ,posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NUMCON"),Nil})
   EndIf
	
	If  SE2->(FieldPos("E2_SEST")) > 0
		aadd(aCampos,{"E2_SEST", 0, NIL})
	Endif
	If  BAU->(FieldPos("BAU_CODRET")) > 0
		aAdd(aCampos,{"E2_CODRET", BAU->BAU_CODRET, Nil})
	EndIf
	
	If (nPos := ascan(acampos,{|x| x[1]="E2_RETCNTR"})) == 0
		aAdd(aCampos,{"E2_RETCNTR",0,Nil})
	EndIf
	aadd(aCampos,{"E2_LA", "", NIL})            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Como ja estamos enviando para o financeiro as bases de 
	//³calculo  dos impostos devemos deixar os campos abaixo por
	//³ultimo devido a função do Fina050(FA050Nat2())      
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
		If nForSE2Lim > 1	
			If aINSSE2[1] > 0 .and. nForSE2 == 1
				cNaturez := GetNewPar("MV_PLSNTPF",cNaturez)
				aadd(aCampos,{"E2_BASEINS" , nValorBIN1, NIL})
				aINSSE2[1]	:= 0
				nPosINS		:= 1
			ElseIf aINSSE2[2] > 0 .and. nForSE2 == 2 
				cNaturez := GetNewPar("MV_PLSNTPJ",cNaturez)
				aadd(aCampos,{"E2_BASEINS" , nValorBIN2, NIL})
				aINSSE2[2]	:= 0			
				nPosINS		:= 2
			ElseIf aINSSE2[3] > 0 .and. nForSE2 == 3
				cNaturez := GetNewPar("MV_PLSNTFT",cNaturez)
				aadd(aCampos,{"E2_BASEINS" , nValorBIN3, NIL})
				aINSSE2[3]	:= 0			
				nPosINS		:= 3
			ElseIf aINSSE2[4] > 0 .and. nForSE2 == 4
				cNaturez := GetNewPar("MV_PLSNTHP",cNaturez)
				aadd(aCampos,{"E2_BASEINS" , nValorBIN4, NIL})
				aINSSE2[4]	:= 0			
				nPosINS		:= 4
			EndIf
		Else
			aadd(aCampos,{"E2_BASEINS" , nValorBINS, NIL})
		EndIf

	aadd(aCampos,{"E2_NATUREZ" 	,cNaturez	,NIL})
	aadd(aCampos,{"E2_MOEDA" 	,01	,NIL})
		
		If nForSE2 == 1 	
			
			aadd(aCampos,{"E2_BASEIRF"	,nValorBIR 	,NIL} )
			aadd(aCampos,{"E2_BASEPIS"	,nValorBPIS	,NIL} )
			aadd(aCampos,{"E2_BASECOF"	,nValorBCOF	,NIL} )
			aadd(aCampos,{"E2_BASECSL"	,nValorBCSL	,NIL} )
			aadd(aCampos,{"E2_VALOR" 	,nVlrSE2	,NIL})
			aadd(aCampos,{"E2_SALDO" 	,nVlrSE2	,NIL})
			aadd(aCampos,{"E2_VLCRUZ" 	,nVlrSE2	,NIL})

		Else
		
			aadd(aCampos,{"E2_BASEIRF"	,0	,NIL } )
			aadd(aCampos,{"E2_BASEPIS"	,0	,NIL } )
			aadd(aCampos,{"E2_BASECOF"	,0	,NIL } )
			aadd(aCampos,{"E2_BASECSL"	,0	,NIL } )
			aadd(aCampos,{"E2_VALOR" 	,IIf(Len(aSaldo) >= 16,aSaldo[16,nForSE2], 0 ), NIL} )
			aadd(aCampos,{"E2_SALDO" 	,IIf(Len(aSaldo) >= 16,aSaldo[16,nForSE2], 0 ), NIL} )
			aadd(aCampos,{"E2_VLCRUZ" 	,IIf(Len(aSaldo) >= 16,aSaldo[16,nForSE2], 0 ), NIL} )
			
		EndIf
		
		If SE2->(FieldPos("E2_BASEISS")) > 0
			aadd(aCampos,{"E2_BASEISS" , Iif( nForSE2Lim == 1, nValorBISS, 0 ), NIL})
		EndIf


	aImpostos := {0,0,0,0,0,0,0} // 1-nValorIR ,2-nValorCOF ,3-nValorISS ,4-nValorCSL ,5-nValorPIS ,6-nValorINS ,7-nValorSES
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava SE2 - Contas a Pagar                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PLStoSE2(aCampos,,aImpostos,.F.,cCopCre,'PLSMPAG',cCondPag,lUltCalc)
		disarmTransaction()
		Return {"F",STR0061,nVlrSE2}//"Erro na geração dos titulos no financeiro."
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Utilizado para baixa/Compensacao caso tenha debitos
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Aadd(aRecnoDP, SE2->(recno()) )
		
	If nForSE2Lim > 1 .And. SE2->E2_INSS > 0
		If nForSE2 == 1
			cAuxCod := "193"
		ElseIf nForSE2 == 2
			cAuxCod := "195"
		ElseIf nForSE2 == 3
			cAuxCod := "197"
		Else
			cAuxCod := "168"
		Endif
		
		aBMR := {cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),cAuxCod,SE2->E2_INSS,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	EndIf
	
	If nForSE2Lim > 1 .And. SE2->E2_IRRF > 0
		nValImp := SE2->E2_IRRF
		nVlrIr	+= SE2->E2_IRRF
		
		aBMR := {cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"199",nValImp,"1",StrZero(Year(dVencto),4),StrZero(Month(dVencto),2)}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	EndIf

	If lCriadoBGQAut
		BGQ->(DbGoTo(nRecnoBGQ))
		BGQ->(RecLock("BGQ",.F.))
			BGQ->BGQ_PREFIX := cPrefixo			//SE2->E2_PREFIXO
			BGQ->BGQ_NUMTIT := cNumero			//SE2->E2_NUM
			BGQ->BGQ_PARCEL := cParcela			//SE2->E2_PARCELA
			BGQ->BGQ_TIPTIT := cTipo				//SE2->E2_TIPO
		BGQ->(MsUnLock())  
		             
		If GetNewPar("MV_GERPTU","1") == "1" //0 - 4.1B NAO GERA TITULO CONTESTACAO / 1 - GERA TITULO CONTESTACAO
			aRetTitOpe	:= CriaTITOpe(BRJ->BRJ_OPEORI,cAno,cMes,nGlosaPag,PlsIntPad())
			lGerSE1 	:= aRetTitOpe[1]    
		EndIf
	Endif
	
	If lAtuaBRJPag .or. lGerSE1
		BRJ->(DbGoTo(nRecnoBRJ))
		BRJ->(RecLock("BRJ",.F.))
		
		If lAtuaBRJPag
			If BRJ->( FieldPos("BRJ_PREE2N") ) > 0 .AND. BRJ->( FieldPos("BRJ_NUME2N") ) > 0 .AND. BRJ->( FieldPos("BRJ_PARE2N") ) > 0 .AND. BRJ->( FieldPos("BRJ_TIPE2N") ) > 0 .AND. ((cTipTitInt == '3' .And. nPosTitInt == 1) .Or. cTipTitInt == '1')

				BRJ->BRJ_PREE2N := cPrefixo		//SE2->E2_PREFIXO
				BRJ->BRJ_NUME2N := cNumero		//SE2->E2_NUM
				BRJ->BRJ_PARE2N := cParcela		//SE2->E2_PARCELA
				BRJ->BRJ_TIPE2N := cTipo			//SE2->E2_TIPO      
  				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Realizado tratamento para quando for tipo 3-Ambos, 	  
				//³	gerar registro de Contestacao 	 					  				
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ				
				If cTipTitInt == "3" .AND. nPosTitInt == 1   
					BRJ->BRJ_STATUS := "1"								
				Else
			   		BRJ->BRJ_STATUS := "2"			// No caso se for somente NDC (Ele nao estava atualizando o Status no BRJ)
			 	EndIf 
				
				BRJ->BRJ_STATUS := "2"
				
			ElseIf BRJ->( FieldPos("BRJ_PRESE2") ) > 0 .AND. BRJ->( FieldPos("BRJ_NUMSE2") ) > 0 .AND. BRJ->( FieldPos("BRJ_PARSE2") ) > 0 .AND. BRJ->( FieldPos("BRJ_TIPSE2") ) > 0
				BRJ->BRJ_PRESE2 := cPrefixo		//SE2->E2_PREFIXO
				BRJ->BRJ_NUMSE2 := cNumero		//SE2->E2_NUM
				BRJ->BRJ_PARSE2 := cParcela		//SE2->E2_PARCELA
				BRJ->BRJ_TIPSE2 := cTipo			//SE2->E2_TIPO
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realizado tratamento para quando for tipo 3-Ambos, 	  ³
			//³	gerar registro de Contestacao 	 					  ³				
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			If cTipTitInt == "3" .AND. nPosTitInt == 1   
				BRJ->BRJ_STATUS := "1"								
			Else
				BRJ->BRJ_STATUS := "2"			// No caso se for somente NDC (Ele nao estava atualizando o Status no BRJ)
			EndIf
		Endif
		
   		If lGerSE1 .And. ((cTipTitInt == '3' .And. nPosTitInt == 1) .Or. cTipTitInt == '1')
			BRJ->BRJ_PRENDC := aRetTitOpe[2] //cPrefixo
			BRJ->BRJ_NUMNDC := aRetTitOpe[3] //cNumero
			BRJ->BRJ_PARNDC := aRetTitOpe[4] //cParcela
			BRJ->BRJ_TIPNDC := aRetTitOpe[5] //cTipo  
		ElseIf lGerSE1 .And. ((cTipTitInt == '3' .And. nPosTitInt == 2) .Or. cTipTitInt == '2') 
			BRJ->BRJ_PREFIX := aRetTitOpe[2] //cPrefixo
			BRJ->BRJ_NUMTIT := aRetTitOpe[3] //cNumero
			BRJ->BRJ_PARCEL := aRetTitOpe[4] //cParcela
			BRJ->BRJ_TIPTIT := aRetTitOpe[5] //cTipo
		Endif
		If BRJ->(FieldPos("BRJ_GERPTU")) > 0
			BRJ->BRJ_GERPTU := GetNewPar("MV_GERPTU","1")
		EndIf
		BRJ->(MsUnLock())
	Endif
		If nHNumPag > 0
			/// Fecha controle de semáforos da numeração do Titulo
			PLSFechaSem(nHNumPag ,cChaveSem)	
		EndIf
		
	Next nForSE2

//b.	Prestador PF c/cálculo via GPE e geração via GPE: não irá gerar título e não irá gerar pedido de compra (receberá holerite)
ElseIf  cCalcImp == "4"    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o valor eh negativo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If  nValorPag < 0
		nVlrSE2 := nValorPag * -1
		lVlrNeg := .T.
		cTipo   := "NDF"
	Else
		nVlrSE2 := IIf(nValorPag == 0, IIf(GetNewPar('MV_PLGER1C',.T.), 0.01, 0) , nValorPag )
		lVlrNeg := .F.
	Endif
	// =====> TEM QUE CHEGAR AQUI COM O ACOMPPAG PREENCHIDO OS VALORES DOS IMPOSTOS
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ calcular impostos    					                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	nPos       := Ascan(aCompPag,{|x| x[3]== "170"})  // Sal contrib outras empresas
	nInsOutEmp := If(nPos > 0,aCompPag[nPos,2],0)
	nPos       := Ascan(aCompPag,{|x| x[3]== "182"})   // Base INSS
    nValorBINS := If(nPos > 0,(lAutonomo:=.T.,aCompPag[nPos,2]),(lAutonomo:=.F.,0))
	nPos       := Ascan(aCompPag,{|x| x[3]== "192"})   // Base INSS PF
	nValorBIN1 := If(nPos > 0,aCompPag[nPos,2],0)
	nPos       := Ascan(aCompPag,{|x| x[3]== "194"})   // Base INSS PJ
	nValorBIN2 += If(nPos > 0,aCompPag[nPos,2],0)
	nPos       := Ascan(aCompPag,{|x| x[3]== "196"})   // Base INSS PF fins filantropicos
	nValorBIN3 += If(nPos > 0,aCompPag[nPos,2],0)
	nPos       := Ascan(aCompPag,{|x| x[3]== "167"})   // Base INSS Hon Patronal
	nValorBIN4 += If(nPos > 0,aCompPag[nPos,2],0)
	nPos       := Ascan(aCompPag,{|x| x[3]== "198"})	// Base IR
	nValorBIR  := If(nPos > 0,aCompPag[nPos,2],0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se existe "Sal Contrib Out Empresas" ja gravado no BMR e nao encontrou no BGQ (CODLAN = 170), ³
	//³ atualiza variavel "nInsOutEmp" com o conteudo de aImpMes[1] = "Sal Contrib Out Empresas"      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If aImpMes[1] > 0 .And. nInsOutEmp == 0
		nInsOutEmp := aImpMes[1]
	EndIf

	// Posiciona Indices
	SRA->(DbSetOrder(1))         
	SRC->(dbSetOrder(1))
	SRV->(DbSetOrder(2))
	
	cSemana := Space(Len(SRC->RC_SEMANA))
	cSeqSRC := Space(Len(SRC->RC_SEQ))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// Se lançamento de INSS geral (não cooperados, INSS Lcto 182) ou lançamento de INSS PF (Lcto 192)
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nValorBINS >0 .or. nValorBIN1 >0 
	    If !Empty(BAU->BAU_MATFUN)
			If  SRA->(dbSeek(IIf(!Empty(BAU->BAU_FILFUN),BAU->BAU_FILFUN,xFilial("SRA"))+BAU->BAU_MATFUN,.F.))                   
				SRV->(dbSeek(xFilial("SRV")+GetNewPar("MV_PLCDFOL","0218"))) 		// Id do codigo da folha para calculo do prestador
				While SRC->(DbSeek(If(!Empty(BAU->BAU_FILFUN),BAU->BAU_FILFUN,xFilial("SRC"))+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC+cSemana+cSeqSRC, .F.))
					cSeqSRC:= Soma1(cSeqSRC)
					If cSeqSRC > Replicate('Z',Len(cSeqSRC))
						Exit
					EndIf
				EndDo
				
				If !SRC->(Found()) 		// SRC->(DbSeek(If(!Empty(BAU->BAU_FILFUN),BAU->BAU_FILFUN,xFilial("SRC"))+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC, .F.))
					RecLock("SRC",.T.)
					SRC->RC_FILIAL	:= If(!Empty(BAU->BAU_FILFUN),BAU->BAU_FILFUN,xFilial("SRC"))
					SRC->RC_MAT		:= SRA->RA_MAT
					SRC->RC_PD		:= SRV->RV_COD
					SRC->RC_TIPO1	:= "V"
					SRC->RC_QTDSEM	:= 0
					SRC->RC_HORAS	:= 0
					SRC->RC_VALOR	:= If( nValorBINS >0, nValorBINS, nValorBIN1+IIf(!lBAU_MATFU3, nValorBIN3, 0)+IIf(!lBAU_MATFU4, nValorBIN4, 0) ) 
					SRC->RC_DATA	:= Date()
					SRC->RC_CC		:= SRA->RA_CC
					SRC->RC_PARCELA:= 0
					SRC->RC_TIPO2	:= "G"
					SRC->RC_LOTPLS	:= xFilial('SRC')+Space(12-Len(xFilial('SRC'))) + cLote
					SRC->RC_CODRDA	:=BAU->BAU_CODIGO
					SRC->RC_SEQ		:= cSeqSRC 
					SRC->(MsUnlock())
				Endif	
			Endif
		Else
			MsgInfo("A RDA "+BAU->BAU_CODIGO+ " esta sem codigo de funcionario.")
			disarmTransaction()
			Return {"G","A RDA "+BAU->BAU_CODIGO+ " esta sem codigo de funcionario.",nValorBIN1}//"Erro na geração dos titulos no financeiro."
		Endif				
	Endif	
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se tiver base de inss pessoa jurídica (nValorBIN2) o sistema irá pegar o cadastro de funcionario BAU_MATFU2 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nValorBIN2 >0 .and. !Empty(BAU->BAU_MATFU2)
		If  SRA->(dbSeek(IIf(!Empty(BAU->BAU_FILFU2),BAU->BAU_FILFU2,xFilial("SRA"))+BAU->BAU_MATFU2,.F.))                   
			SRV->(dbSeek(xFilial("SRV")+GetNewPar("MV_PLCDFOL","0218"))) 		// Id do codigo da folha para calculo do prestador
			While SRC->(DbSeek(IIf(!Empty(BAU->BAU_FILFU2),BAU->BAU_FILFU2,xFilial("SRC"))+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC+cSemana+cSeqSRC, .F.))
				cSeqSRC:= Soma1(cSeqSRC)
				If cSeqSRC > Replicate('Z',Len(cSeqSRC))
					Exit
				EndIf
			EndDo
			
			If !SRC->(Found()) 		// SRC->(DbSeek(If(!Empty(BAU->BAU_FILFUN),BAU->BAU_FILFUN,xFilial("SRC"))+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC, .F.))
				RecLock("SRC",.T.)
				SRC->RC_FILIAL	:= If(!Empty(BAU->BAU_FILFU2),BAU->BAU_FILFU2,xFilial("SRC"))
				SRC->RC_MAT		:= SRA->RA_MAT
				SRC->RC_PD		:= SRV->RV_COD
				SRC->RC_TIPO1	:= "V"
				SRC->RC_QTDSEM	:= 0
				SRC->RC_HORAS	:= 0
				SRC->RC_VALOR	:= nValorBIN2 
				SRC->RC_DATA	:= Date()
				SRC->RC_CC		:= SRA->RA_CC
				SRC->RC_PARCELA:= 0
				SRC->RC_TIPO2	:= "G"
				SRC->RC_LOTPLS	:= xFilial('SRC') + Space(12-Len(xFilial('SRC'))) + cLote
				SRC->RC_CODRDA	:=BAU->BAU_CODIGO
				SRC->RC_SEQ		:= cSeqSRC 
				SRC->(MsUnlock())
			Endif	
		Endif
	ElseIf nValorBIN2 >0
		MsgInfo("A RDA "+BAU->BAU_CODIGO+ " esta sem codigo de funcionario 2.")
		disarmTransaction()
		Return {"2","A RDA "+BAU->BAU_CODIGO+ " esta sem codigo de funcionario 2.",nValorBIN2}//"Erro na geração dos titulos no financeiro."
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se tiver base inss jur filantrópica (nValorBIN3) o sistema irá pegar o cadastro de funcionario BAU_MATFU3 pois trata de 	    ³
	//³aliquota de 20% e os demais sera gravado na src de outra filial cadastrada no campo 	BAU_MATFU4								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nValorBIN3 > 0 .and. lBAU_MATFU3 .and. !Empty(BAU->BAU_MATFU3)
		If  SRA->(dbSeek(IIf(!Empty(BAU->BAU_FILFU3),BAU->BAU_FILFU3,xFilial("SRA"))+BAU->BAU_MATFU3,.F.))                   
			SRV->(dbSeek(xFilial("SRV")+GetNewPar("MV_PLCDFOL","0218"))) 		// Id do codigo da folha para calculo do prestador
			While SRC->(DbSeek(If(!Empty(BAU->BAU_FILFU3),BAU->BAU_FILFU3,xFilial("SRC"))+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC+cSemana+cSeqSRC, .F.))
				cSeqSRC:= Soma1(cSeqSRC)
				If cSeqSRC > Replicate('Z',Len(cSeqSRC))
					Exit
				EndIf
			EndDo
			
			If !SRC->(Found())
				RecLock("SRC",.T.)
				SRC->RC_FILIAL	:= If(!Empty(BAU->BAU_FILFU3),BAU->BAU_FILFU3,xFilial("SRC"))
				SRC->RC_MAT		:= SRA->RA_MAT
				SRC->RC_PD		:= SRV->RV_COD
				SRC->RC_TIPO1	:= "V"
				SRC->RC_QTDSEM	:= 0
				SRC->RC_HORAS	:= 0
				SRC->RC_VALOR	:= nValorBIN3 
				SRC->RC_DATA	:= Date()
				SRC->RC_CC		:= SRA->RA_CC
				SRC->RC_PARCELA:= 0
				SRC->RC_TIPO2	:= "G"
				SRC->RC_LOTPLS	:= xFilial('SRC') + Space(12-Len(xFilial('SRC'))) + cLote
				SRC->RC_CODRDA	:= BAU->BAU_CODIGO
				SRC->RC_SEQ		:= cSeqSRC 
				SRC->(MsUnlock())
			Endif	
		Endif
	ElseIf nValorBIN3 >0
		MsgInfo("A RDA "+BAU->BAU_CODIGO+ " esta sem codigo de funcionario 3.")
		disarmTransaction()
		Return {"G","A RDA "+BAU->BAU_CODIGO+ " esta sem codigo de funcionario 3.",nValorBIN3}//"Erro na geração dos titulos no financeiro."
	Endif	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se tiver base de inss hon patronal (nValorBIN4) o sistema irá pegar o cadastro de funcionario BAU_MATFU4 	    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nValorBIN4 >0  .and. lBAU_MATFU4 .and. !Empty(BAU->BAU_MATFU4)
		If  SRA->(dbSeek(IIf(!Empty(BAU->BAU_FILFU4),BAU->BAU_FILFU4,xFilial("SRA"))+BAU->BAU_MATFU4,.F.))                   
			SRV->(dbSeek(xFilial("SRV")+GetNewPar("MV_PLCDFOL","0218"))) 		// Id do codigo da folha para calculo do prestador
			While SRC->(DbSeek(If(!Empty(BAU->BAU_FILFU4),BAU->BAU_FILFU4,xFilial("SRC"))+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC+cSemana+cSeqSRC, .F.))
				cSeqSRC:= Soma1(cSeqSRC)
				If cSeqSRC > Replicate('Z',Len(cSeqSRC))
					Exit
				EndIf
			EndDo
			
			If !SRC->(Found()) 		// SRC->(DbSeek(If(!Empty(BAU->BAU_FILFUN),BAU->BAU_FILFUN,xFilial("SRC"))+SRA->RA_MAT+SRV->RV_COD+SRA->RA_CC, .F.))
				RecLock("SRC",.T.)
				SRC->RC_FILIAL	:= If(!Empty(BAU->BAU_FILFU4),BAU->BAU_FILFU4,xFilial("SRC"))
				SRC->RC_MAT		:= SRA->RA_MAT
				SRC->RC_PD		:= SRV->RV_COD
				SRC->RC_TIPO1	:= "V"
				SRC->RC_QTDSEM	:= 0
				SRC->RC_HORAS	:= 0
				SRC->RC_VALOR	:= nValorBIN4 
				SRC->RC_DATA	:= Date()
				SRC->RC_CC		:= SRA->RA_CC
				SRC->RC_PARCELA:= 0
				SRC->RC_TIPO2	:= "G"
				SRC->RC_LOTPLS	:= xFilial('SRC') + Space(12-Len(xFilial('SRC'))) + cLote
				SRC->RC_CODRDA	:= BAU->BAU_CODIGO
				SRC->RC_SEQ		:= cSeqSRC 
				SRC->(MsUnlock())
			Endif	
		Endif
	ElseIf nValorBIN4 >0
		MsgInfo("A RDA "+BAU->BAU_CODIGO+ " esta sem codigo de funcionario 4.")
		disarmTransaction()
		Return {"G","A RDA "+BAU->BAU_CODIGO+ " esta sem codigo de funcionario 4.",nValorBIN4}//"Erro na geração dos titulos no financeiro."
	Endif	

		
	//Criação do ponto de entrada para realizar novas tratativas na inclusão da SRC - Pagamento autonomo
	If lPLSPGSRC
		ExecBlock("PLSPGSRC",.F.,.F.,{BAU->BAU_CODIGO,cLote})	
	Endif	

//c.Prestador PJ c/cálculo via FIN: não irá gerar título e irá gerar pedido de compra com base de impostos 
// (prestador emitirá NF conforme relatório fornecido via pedido de compra)
ElseIf  cCalcImp == "1" .and.  (BAU->BAU_TIPPE == 'J' .OR. GetNewPar("MV_PLPFFIN",.F.) == .T.) 

	If aSaldo[1]
		
		//Verificando o grupo de compras
		aGrupo := UsrGrComp(RetCodUsr())
		If Len(aGrupo) > 0
			cGrupCom := aGrupo[1]
		Else	
			cGrupCom := ""
		Endif
		
		/*
		Esse item foi alterado devido ao grupode empresa há clientes que possui mais de 5 digitos de filial assim ocasionando a gravação do lote errado  
		cLotPcPls 	:= IIf(Len(xFilial('SC7'))==2, cLote, xFilial('SC7')+Space(12-Len(xFilial('SC7')))+cLote )
		*/ 
		cLotPcPls 	:= cLote
		_cNumPc		:= ""
		
		aCab := {	{"C7_NUM"		,_cNumPc		,nil},;
					{"C7_EMISSAO"	, Date()		,nil},;
					{"C7_FORNECE"	,cCodForn		,nil},;
					{"C7_LOJA"		,cLoja			,nil},;
					{"C7_COND"    	,iIf(!empty(SA2->A2_COND),SA2->A2_COND,MV_PAR37)    		,nil},;
					{"C7_CONTATO"   ,". "    		,nil},;
					{"C7_FILENT"  	,xFilial("SC7"),nil}} // Filial Entrega

		nTotDesc := 0
		nDescC7	 := IIf(Len(aSaldo[5])>0, 0, aSaldo[17] )		//Debitos BGQ
		nPrcSld  := 0     
		cProduto := ""
		cTesAux	 := ""

		For i:=1 to len(aSaldo[5])
			
			//Acumulo os Debitos
			If aSaldo[5,i,1] == "1"
				nDescC7	+= aSaldo[5,i,2]
			//Acumulo os Creditos	
			Else
				nPrcSld += aSaldo[5,i,2]
			EndIf

			If Empty(cProduto)
				cProduto := Iif(!Empty(aSaldo[5,i,8]),aSaldo[5,i,8],MV_PAR36)
			EndIf
			
			If Empty(cTesAux)
				cTesAux := Iif(!Empty(aSaldo[5,i,9]),aSaldo[5,i,9],MV_PAR38)
			EndIf

		Next i

		If nDescC7 >= nPrcSld
			nTotDesc := nDescC7 - nPrcSld//Se os debitos sao maiores do que o credito vou gerar um NDF
			nDescC7  := nPrcSld//Desconto de 100% no pedido, a diferenca vai gerar 1 NDF
		EndIf

		aAdd(aItens,{	{"C7_ITEM"		,StrZero(1,4),Nil},;
						{"C7_PRODUTO"	,cProduto			,Nil},;
						{"C7_QUANT"		,1					,Nil},;
						{"C7_PRECO"		,nPrcSld			,Nil},;
						{"C7_TOTAL"		,nPrcSld			,Nil},;
						{"C7_DATPRF"	,dDataBase			,Nil},;
						{"C7_TES"		,cTesAux			,Nil},;
						{"C7_FLUXO"		,"S"				,Nil},;
						{"C7_LOCAL"		,"01"				,Nil},;
						{"C7_ORIGEM"    ,"PLSMPAG"  		,nil},;
						{"C7_CODRDA"	,cCodRda			,Nil},;
						{"C7_LOTPLS"	,cLotPcPls			,Nil},;
						{"C7_VLDESC"	,nDescC7			,Nil},;
			{"C7_USER"			,RetCodUsr()			,Nil},;
			{"C7_GRUPCOM"		,cGrupCom			,Nil},;
						{"C7_PLOPELT"	,cOpeLote			,Nil}})

		If Len(aItens)>0 .And. nPrcSld > nDescC7//Gravacao do pedido de compra

			If lPLSPGSC7
				aRetPtoEnt := ExecBlock("PLSPGSC7",.F.,.F.,{aCab,aItens,aSaldo})
				If Valtype(aRetPtoEnt) == "A"
					aCab	:= aRetPtoEnt[1]
					aItens	:= aRetPtoEnt[2]
					aSaldo	:= aRetPtoEnt[3]
				Endif
			Endif
				
			lMsHelpAuto := .T.
			lMsErroAuto := .F.
			
			MsExecAuto({|X,Y,Z,W| MATA120(X,Y,Z,W)},1, aCab, aItens, 3)
			
			SC7->(ConfirmSX8())

			If lMsErroAuto //SE NAO HOUVE ERRO
				lOK:=.F.
				MostraErro()
			Endif
			
			
			// ATUALIZANDO O GRUPO DE COMPRAS
			
			If lOK .AND. !Empty(cGrupCom)
				SC7->(Reclock("SC7",.F.))
				SC7->C7_GRUPCOM:=	cGrupCom
				SC7->(MsUnlock())
			Endif	
			
		Endif
		
		//Sobrou desconto pra dar, entao devo gerar SE2 - NDF
		If nTotDesc > 0 

			cPrefNDF := GETMV("MV_PLPREE2")
			cPrefNDF := Eval({|| &cPrefNDF })
			cNumNDF  := GetMV("MV_PLNUME2")
			cNumNDF  := Eval({|| &cNumNDF  })

			aCampos := {{"E2_FILIAL"	,xFilial("SE2")	,NIL},;
						{"E2_PREFIXO"	,cPrefNDF			,Nil},;
						{"E2_NUM"		,cNumNDF			,Nil},;
						{"E2_TIPO"		,"NDF"				,Nil},;
						{"E2_FORNECE"	,cCodForn			,Nil},;
						{"E2_LOJA"		,cLoja				,Nil},;
						{"E2_ORIGEM"	,"PLSMPAG"			,Nil},;
						{"E2_EMISSAO"	,iif(AllTrim(cTipo)=="PA",dVencto,dDataBase)	,NIL},;
						{"E2_NATUREZ" 	,SA2->A2_NATUREZ	,NIL},;
						{"E2_VENCTO"	,dDataBase			,NIL},;
						{"E2_VENCREA"	,dDataBase			,NIL},;
						{"E2_PLLOTE"	,cLote				,NIL},;
						{"E2_PLOPELT"	,cOpeLote			,NIL},;
						{"E2_CODRDA"	,cCodRda			,NIL},;
						{"E2_ANOBASE"	,cAno				,NIL},;
						{"E2_MESBASE"	,cMes				,NIL},;
						{"E2_VALOR"		,nTotDesc			,Nil}}

			lMsHelpAuto := .t.
			lMsErroAuto := .f.
			MsExecAuto({ | a,b | Fina050(a,b) }, aCampos, 3)

			If lMsErroAuto
				lOK:=.F.
				MostraErro()
			EndIf

		EndIf
		
	Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pagamento com calculo de impostos atraves da integracao com a folha ³
//³ de forma automatica, sem ter que entrar no modulo SIGAGPE           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// cCalcImp == '3' OU ( cCalcImp == '1' .and. MV_PLPFFIN == .F.  .AND. BAU->BAU_TIPPE <> 'J' )
// ==> calcula pelo módulo GPE e gera títulos no módulo FIN
Else	 
	nForSE2Lim:=1		
	nVlrSE2 	:= nVlrDebVar := nVlrIr := nVlrImp := 0
	nValorBIR	:= nValorBINS := nValorBIN1 := nValorBIN2 := nValorBIN3 := nValorBIN4 := nInsOutEmp := 0
	
	for nImp := 1 to Len(aCompPag)
		nVlrSE2		+= iif(aCompPag[nImp,1]== "2", aCompPag[nImp,2], 0 )
		nVlrDebVar	+= iif(aCompPag[nImp,1]== "1", aCompPag[nImp,2], 0 )
	next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve calcular impostos                .                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//1 - pagamento unico no mes 
	//3 - Varios pagamentos no Mes com provisao de INSS 
	//4 - Varios pagamentos no Mes sem provissao
	if  GetNewPar("MV_PLPGUNI","1") $ "1,3,4"  
		
		nPos     	:= Ascan(aCompPag,{|x| x[3]== "170"})  // Sal contrib outras empresas
		nInsOutEmp	:= If(nPos > 0,aCompPag[nPos,2],0)

		nPos		:= Ascan(aCompPag,{|x| x[3]== "182"})   // Base INSS Unica
	   	nValorBINS	:= If(nPos > 0,aCompPag[nPos,2],0)

		nPos     	:= Ascan(aCompPag,{|x| x[3]== "192"})   // Base INSS PF
		nValorBIN1	:= If(nPos > 0,aCompPag[nPos,2],0)

		nPos     	:= Ascan(aCompPag,{|x| x[3]== "194"})   // Base INSS PJ
		nValorBIN2  := If(nPos > 0,aCompPag[nPos,2],0)

		nPos     	:= Ascan(aCompPag,{|x| x[3]== "196"})   // Base INSS PF fins filantropicos
		nValorBIN3  := If(nPos > 0,aCompPag[nPos,2],0)
	
		nPos     	:= Ascan(aCompPag,{|x| x[3]== "167"})   // Base INSS Honorário Patronal
		nValorBIN4  := If(nPos > 0,aCompPag[nPos,2],0)

		nPos     	:= Ascan(aCompPag,{|x| x[3]== "198"})  // Base IR
		nValorBIR 	:= If(nPos > 0,aCompPag[nPos,2],0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se existe "Sal Contrib Out Empresas" ja gravado no BMR e nao encontrou no BGQ (CODLAN = 170), ³
		//³ atualiza variavel "nInsOutEmp" com o conteudo de aImpMes[1] = "Sal Contrib Out Empresas"      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if aImpMes[1] > 0 .And. nInsOutEmp == 0
			nInsOutEmp := aImpMes[1]
		endIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Retorna o valor dos impostos
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		aRetImp := PLSINTGPE(.F.,cCodRda,cAno,cMes,aVerbas,cOpeLote,cLote,cNaturez,cCodForn,cLoja,cHisTit,nValorBIR,nValorBIN1,nValorBIN2,nInsOutEmp,lAutonomo,dVencto,aImpMes,lUltCalc,nVrIRRet,nValorBIN3,lPgtoImp,aCompPag,getNewPar("MV_PLPGUNI","1") == "4",cNumero,lHist,,nValorBIN4,nValorBINS)

		// Atualiza valor da base do IR caso tenha atualizado na função PLSINTGPE 
		nPos     	:= Ascan(aCompPag,{|x| x[3]== "198"})  // Base IR
		nValorBIR 	:= If( nPos > 0, aCompPag[nPos,2], nValorBIR )
	
		// Aglutina impostos
		nVlrIr	:= aRetImp[1]
		nVlrImp	:= aRetImp[1]+aRetImp[2]
		
		//3 - Varios pagamentos no mes com provisao de INSS
		if  GetNewPar("MV_PLPGUNI","1") == "3"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se eh o ultimo calculo do mes, devera gravar o lancamento "181 - Credito Prov INSS" na compo- ³
			//³ sicao do pagamento, bem como, adiciona-lo no valor do titulo (nVlrSE2).                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if lUltCalc
				if aImpMes[8]+aImpMes[9]+aImpMes[12]+aImpMes[24] > 0
					aAdd(aCompPag, { "2", aImpMes[8]+aImpMes[9]+aImpMes[12]+aImpMes[24], "181", "Credito Prov INSS", "3" })
					nVlrSE2 += aImpMes[8]+aImpMes[9]+aImpMes[12]+aImpMes[24]
					nVlrImp -= aImpMes[8]+aImpMes[9]+aImpMes[12]+aImpMes[24]
				endIf
			else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ Se nao eh o ultimo calculo do mes, zera o valor de INSS para nao gravar o titulo de INSS. 
				//³ IMPORTANTE: na rotina que grava o 
				//³ BMR, ja trata se grava o lancamento como "INSS" ou "Provisao de INSS".                    
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				aRetImp[2]	:= 0
			endIf
		endIf
		if  !aRetImp[3]
			aCritica := {"H",aRetImp[4],nVlrSE2}
		endIf
		
	else
		aRetImp := {0,0,.F.,''}
	endIf
	
	if nRecTitVin == 0
	
		if aRetImp[2] > 0 // INSS
		     lSoINSS := .F.
		endIf     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ necessario para o financeiro nao considerar o e2_valor na base zero                 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		nVlrSE2 := iif(nVlrSE2<0,0,nVlrSE2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Guarda o tipo do titulo que deve ser considerado para geracao dos impostos
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cTipoTit := cTipo	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define dados para inclusao via rotina automatica...                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCampos :=	{	{"E2_FILIAL" 	,xFilial("SE2")  	,NIL},;
						{"E2_PREFIXO"	,cPrefixo       	,Nil},;
						{"E2_NUM"		,cNumero        	,Nil},;
						{"E2_PARCELA"	,cParcela       	,Nil},;
						{"E2_TIPO"		,cTipo          	,Nil},;
						{"E2_FORNECE"	,cCodForn       	,Nil},;
						{"E2_LOJA"		,cLoja          	,Nil},;
						{"E2_NOMFOR" 	,posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"),Nil},;
						{"E2_EMISSAO"	,dDataBase      	,NIL},;
						{"E2_EMIS1"  	,dDataBase      	,NIL},;
						{"E2_VENCTO"	,dVencto        	,NIL},;
						{"E2_VENCREA"	,DataValida(dVencto),NIL},;
						{"E2_VENCORI"	,dVencto        	,NIL},;  
						{"E2_DECRESC" 	,nVrDecresc     	,NIL},;
						{"E2_ACRESC"  	,nVrAcresc      	,NIL},;
						{"E2_PLLOTE"  	,cLote          ,NIL},;
						{"E2_PLOPELT" 	,cOpeLote       	,NIL},;
						{"E2_CODRDA"  	,cCodRda        ,NIL},;
						{"E2_ANOBASE" 	,cAno           ,NIL},;
						{"E2_MESBASE" 	,cMes           ,NIL},;
						{"E2_DESDOBR"	,"N"				,NIL},;
						{"E2_DIRF" 		,"1"				,NIL},;
						{"E2_HIST" 		,cHisTit			,NIL},;
						{"E2_PARCIR"  	,strzero(1,TamSx3("E2_PARCIR")[1]),NIL},;
						{"E2_PARCINS" 	,strzero(1,TamSx3("E2_PARCINS")[1]),NIL},;
						{"E2_ORIGEM"	,"PLSMPAG"			,NIL},;
						{"E2_BASEIRF" 	,nValorBIR		,NIL},;
						{"E2_BASEPIS" 	,0		,NIL},;
						{"E2_BASECOF" 	,0		,NIL},;
						{"E2_BASECSL" 	,0		,NIL}}	

		if  SE2->(FieldPos("E2_BASEINS")) > 0
			aadd(aCampos,{"E2_BASEINS", nValorBINS+nValorBIN1+nValorBIN2+nValorBIN3+nValorBIN4, NIL})
		endIf
		if  SE2->(FieldPos("E2_BASEISS")) > 0
			aadd(aCampos,{"E2_BASEISS", 0, NIL})
		endIf
		if  SE2->(FieldPos("E2_SEST")) > 0
			aadd(aCampos,{"E2_SEST", 0, NIL})
		endif
		if  BAU->(FieldPos("BAU_CODRET")) > 0
			aAdd(aCampos,{"E2_CODRET", BAU->BAU_CODRET, Nil})
		endIf
		if (nPos := ascan(acampos,{|x| x[1]="E2_RETCNTR"})) == 0
			aAdd(aCampos,{"E2_RETCNTR",0,Nil})
		endIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Como ja estamos enviando para o financeiro as bases de 
		//³calculo  dos impostos devemos deixar os campos abaixo por     
		//³ultimo devido a função do no Fina050(FA050Nat2())      
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		aadd(aCampos,{"E2_NATUREZ" 	,cNaturez	,NIL})
		aadd(aCampos,{"E2_MOEDA" 	,01	,NIL})
		aadd(aCampos,{"E2_VALOR" 	,nVlrSE2 - nVlrImp	,NIL})
		aadd(aCampos,{"E2_SALDO" 	,nVlrSE2 - nVlrImp	,NIL})
		aadd(aCampos,{"E2_VLCRUZ" 	,nVlrSE2 - nVlrImp	,NIL})

		dbSelectArea("SED")
		dbSeek(xFilial("SED")+cNaturez)
		If SED->ED_CALCIRF == 'S' .OR. SED->ED_CALCINS == 'S'
			disarmTransaction()
			return {"L","Natureza para P.F. nao deve calcular IR e INSS",nVlrSE2}//"Erro na geração dos titulos no financeiro."
		EndIf 
		
		// 1-nValorIR ,2-nValorCOF ,3-nValorISS ,4-nValorCSL ,5-nValorPIS ,6-nValorINS ,7-nValorSES
		aImpostos := {aRetImp[1],0,0,0,0,aRetImp[2],0}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava SE2 - Contas a Pagar                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( GetNewPar('MV_PLGER1C', .T.) .and. (nVlrSE2-nVlrImp)<=0 ) .or. nVlrSE2 > 0 
		
			If !PLStoSE2(aCampos,,aImpostos,.F.,cCopCre,'PLSMPAG',cCondPag,lUltCalc)
				disarmTransaction()
				return {"F",STR0061,nVlrSE2}//"Erro na geração dos titulos no financeiro."
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Utilizado para baixa/Compensacao caso tenha debitos
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			Aadd(aRecnoDP, SE2->(recno()) )
		EndIf
	else
		// Se encontrou titulo vinculado
		SE2->(DbGoTo(nRecTitVin))
		SE2->(Reclock("SE2",.F.))
		SE2->E2_PLOPELT := cOpeLote
		SE2->E2_PLLOTE  := cLote
		SE2->E2_CODRDA  := cCodRda
		SE2->E2_ANOBASE := cAno
		SE2->E2_MESBASE := cMes
		SE2->(MsUnlock())
	endIf
	
	if lCriadoBGQAut
		BGQ->(DbGoTo(nRecnoBGQ))
		BGQ->(RecLock("BGQ",.F.))
			BGQ->BGQ_PREFIX := SE2->E2_PREFIXO
			BGQ->BGQ_NUMTIT := SE2->E2_NUM
			BGQ->BGQ_PARCEL := SE2->E2_PARCELA
			BGQ->BGQ_TIPTIT := SE2->E2_TIPO
		BGQ->(MsUnLock())     
		
		if GetNewPar("MV_GERPTU","1") == "1" //0 - 4.1B NAO GERA TITULO CONTESTACAO / 1 - GERA TITULO CONTESTACAO
			aRetTitOpe	:= CriaTITOpe(BRJ->BRJ_OPEORI,cAno,cMes,nGlosaPag,PlsIntPad())
			lGerSE1 	:= aRetTitOpe[1]
		endIf
	endIf
	
	if lAtuaBRJPag .or. lGerSE1 
		BRJ->(DbGoTo(nRecnoBRJ))
		BRJ->(RecLock("BRJ",.F.))
   		
   		if lGerSE1 .And. ((cTipTitInt == '3' .And. nPosTitInt == 1) .Or. cTipTitInt == '1')
			BRJ->BRJ_PRENDC := aRetTitOpe[2] //cPrefixo
			BRJ->BRJ_NUMNDC := aRetTitOpe[3] //cNumero
			BRJ->BRJ_PARNDC := aRetTitOpe[4] //cParcela
			BRJ->BRJ_TIPNDC := aRetTitOpe[5] //cTipo  
		elseIf lGerSE1 .And. ((cTipTitInt == '3' .And. nPosTitInt == 2) .Or. cTipTitInt == '2') 
			BRJ->BRJ_PREFIX := aRetTitOpe[2] //cPrefixo
			BRJ->BRJ_NUMTIT := aRetTitOpe[3] //cNumero
			BRJ->BRJ_PARCEL := aRetTitOpe[4] //cParcela
			BRJ->BRJ_TIPTIT := aRetTitOpe[5] //cTipo	
		endIf
		if lAtuaBRJPag
	 		if BRJ->( FieldPos("BRJ_PREE2N") ) > 0 .AND. BRJ->( FieldPos("BRJ_NUME2N") ) > 0 .AND. BRJ->( FieldPos("BRJ_PARE2N") ) > 0 .AND. BRJ->( FieldPos("BRJ_TIPE2N") ) > 0 .AND. ((cTipTitInt == '3' .And. nPosTitInt == 1) .Or. cTipTitInt == '1')     
				BRJ->BRJ_PREE2N := cPrefixo		//SE2->E2_PREFIXO
				BRJ->BRJ_NUME2N := cNumero		//SE2->E2_NUM
				BRJ->BRJ_PARE2N := cParcela		//SE2->E2_PARCELA
				BRJ->BRJ_TIPE2N := cTipo			//SE2->E2_TIPO
			
			elseIf BRJ->( FieldPos("BRJ_PRESE2") ) > 0 .AND. BRJ->( FieldPos("BRJ_NUMSE2") ) > 0 .AND. BRJ->( FieldPos("BRJ_PARSE2") ) > 0 .AND. BRJ->( FieldPos("BRJ_TIPSE2") ) > 0
				BRJ->BRJ_PRESE2 := SE2->E2_PREFIXO
				BRJ->BRJ_NUMSE2 := SE2->E2_NUM
				BRJ->BRJ_PARSE2 := SE2->E2_PARCELA
				BRJ->BRJ_TIPSE2 := SE2->E2_TIPO
			endIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realizado tratamento para quando for tipo 3-Ambos, 	  ³
			//³	gerar registro de Contestacao 	 					  ³				
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  
			if cTipTitInt == "3" .AND. nPosTitInt == 1	
				BRJ->BRJ_STATUS := "1"								
			else						
				BRJ->BRJ_STATUS := "2"
			endIf
		endIf
		BRJ->(MsUnLock())
	endIf
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava BMR - Composicao do Pagamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if  lOK
	nVlrImp := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ So tem valor quando e pagamento pelo financeiro pois pela folha ainda nao registrou os impostos
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	nValImp := iif(lContrRet,SE2->E2_VRETPIS,SE2->E2_PIS)
	if  nValImp > 0
		nVlrImp	+= nValImp
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"187",nValImp,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endif
	
	nValImp := iif(lContrRet,SE2->E2_VRETCOF,SE2->E2_COFINS)
	if  nValImp > 0
		nVlrImp	+= nValImp
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"189",nValImp,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endif
	
	nValImp := iif(lContrRet,SE2->E2_VRETCSL,SE2->E2_CSLL)
	if  nValImp > 0
		nVlrImp	+= nValImp
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"191",nValImp,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endif
	
	nValImp := SE2->E2_INSS
	if  nValImp > 0 .And. nForSE2Lim == 1
		nVlrImp	+= nValImp
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"183",nValImp,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endif
	
	nValImp := SE2->E2_IRRF
	if  nValImp > 0 .And. nForSE2Lim == 1
		nVlrImp += nValImp
		nVlrIr	 += nValImp
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"199",nValImp,"1",StrZero(Year(dVencto),4),StrZero(Month(dVencto),2)}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endif
	
	nValImp := SE2->E2_ISS
	if  nValImp > 0
		nVlrImp += nValImp
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"185",nValImp,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endif

	if lPLSPAG02
		ExecBLock("PLSPAG02",.F.,.F.,{cCodOpe,cCodRda,cOpeLote,cAno,cMes,Subs(cLote,7,4), nVlrSE2, nVlrImp})
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Financeiro e pela folha
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	for nFor := 1 to len(aCompPag)
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),aCompPag[nFor,3],aCompPag[nFor,2],aCompPag[nFor,1],IIf(aCompPag[nFor,3]$'182/192/194/196/167',cAno,StrZero(Year(dVencto),4)),IIf(aCompPag[nFor,3]$'182/192/194/196/167',cMes,StrZero(Month(dVencto),2))}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava BMS - Composicao do Pagamento p/ contabilidade                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 To Len(aCompPagD)
		BMS->(RecLock("BMS",.T.))
			BMS->BMS_FILIAL := xFilial("BMS")
			BMS->BMS_OPERDA := cCodOpe
			BMS->BMS_CODRDA := cCodRda
			BMS->BMS_OPELOT := cOpeLote
			BMS->BMS_ANOLOT := cAno
			BMS->BMS_MESLOT := cMes
			BMS->BMS_NUMLOT := SUBS(cLote,7,4)
			BMS->BMS_DEBCRE := aCompPagD[nFor,01]
			BMS->BMS_VLRPAG := aCompPagD[nFor,02]
			BMS->BMS_CODLAN := aCompPagD[nFor,03]
			BMS->BMS_CODPLA := aCompPagD[nFor,04]
			BMS->BMS_CC		:= aCompPagD[nFor,05]
			BMS->BMS_CODSER := aCompPagD[nFor,06]
			BMS->BMS_ORIGEM := aCompPagD[nFor,07]
		BMS->(msUnLock())
	Next
Endif

If lOk .AND. !lAneste
	
	cChkSE2 := SE2->( E2_FILIAL+'|'+E2_PREFIXO+'|'+E2_NUM+'|'+E2_PARCELA+'|'+E2_TIPO+'|'+E2_FORNECE+'|'+E2_LOJA )
	
	//Aponta dados sobre o pagamento que acabou de ser feito... 
	PLSATUVINP(cLote,cOpeLote,cCodOpe,cLocDigIn,cLocDigFi,cCodPegIn,cCodPegFi,cNumMovIn,cNumMovFi,;
				dDatMvIni,dDatMvFin,cCodRDA,cAno,cMes,"1",dVencto,cCdEmpDeS,cCdEmpAteS,cExcessao,;
				cCodDC,lGuiCob,cLoteImp,lSoINSS,cExcPeg, iIf(cCalcImp == "2", cChkSE2 ,nil))
				
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se eh integracao com a folha e se deve calcular impostos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOk .AND. cCalcImp $ "3,4"
	aRetImp	:= PLSINTGPE(.T.,cCodRda,cAno,cMes,aVerbas,cOpeLote,cLote,cNaturez,cCodForn,cLoja,cHisTit,/*nValorBIR*/,/*nValorBIN1*/,/*nValorBIN2*/,/*nInsOutEmp*/,lAutonomo,dVencto,aImpMes,IIf(getNewPar("MV_PLPGUNI","1") == "4",.T.,lUltCalc),nVrIRRet,/*nValorBIN3*/,GetNewPar("MV_PLPGUNI","1")$"1,3,4",/*aCompPag*/,getNewPar("MV_PLPGUNI","1") == "4",cNumero,lHist,cTipoTit,/*nValorBIN4*/,/*nValorBINS*/)
	If !aRetImp[3]
		aCritica := {"H",aRetImp[4],nVlrSE2}
	Else
		nVlrIr	:= aRetImp[1]
		nVlrImp := aRetImp[2]
	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizar A TABELA B15                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lUltCalc .and. GetNewPar("MV_PLPGUNI","1") == "3" ) .Or. GetNewPar("MV_PLPGUNI","1") $ "1,4"
	PLSB15_IMP(cOpeLote, cAno, cMes, cCodRDA)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realizo a baixa do titulo principal e em seguida realizo a³
//³geracao da NDF, quando o saldo do prestador for negativo. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVlrDebVar > 0 .AND. ( Empty(cLoteImp) .or. nPosTitInt < 2 ) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dados para inclusao via rotina automatica...                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos :=	{	{"E2_FILIAL"	,xFilial("SE2")	,NIL},;
					{"E2_PREFIXO"	,cPrefixo       	,Nil},;
					{"E2_NUM"		,cNumero        	,Nil},;
					{"E2_PARCELA"	,cParcela       	,Nil},;
					{"E2_TIPO"		,"NDF"          	,Nil},;
					{"E2_FORNECE"	,cCodForn       	,Nil},;
					{"E2_LOJA"		,cLoja          	,Nil},;
					{"E2_NOMFOR" 	,posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"),Nil},;
					{"E2_EMISSAO"	,iif(AllTrim(cTipo)=="PA",dVencto,dDataBase)	,NIL},;
					{"E2_EMIS1"  	,iif(AllTrim(cTipo)=="PA",dVencto,dDataBase)	,NIL},;
					{"E2_VENCTO"	,dVencto        	,NIL},;
					{"E2_VENCREA"	,DataValida(dVencto)	,NIL},;
					{"E2_VENCORI" 	,dVencto        	,NIL},;
					{"E2_DECRESC" 	,0					,NIL},;
					{"E2_ACRESC"  	,0					,NIL},;
					{"E2_PLLOTE"  	,cLote          ,NIL},;
					{"E2_PLOPELT" 	,cOpeLote       	,NIL},;
					{"E2_CODRDA"  	,cCodRda        	,NIL},;
					{"E2_ANOBASE" 	,cAno           ,NIL},;
					{"E2_MESBASE" 	,cMes           ,NIL},;
					{"E2_INSS"   	,0 			      	,NIL},;
					{"E2_ISS"    	,0             	,NIL},;
					{"E2_CSLL"   	,0             	,NIL},;
					{"E2_COFINS" 	,0             	,NIL},;
					{"E2_PIS"    	,0             	,NIL},;
					{"E2_IRRF"   	,0					,NIL},;					
					{"E2_BASEIRF" 	,0		,NIL},;
					{"E2_BASEPIS" 	,0		,NIL},;
					{"E2_BASECOF" 	,0		,NIL},;
					{"E2_BASECSL" 	,0		,NIL}}
					
	If  SE2->(FieldPos("E2_BASEINS")) > 0
		aadd(aCampos,{"E2_BASEINS", 0, NIL})
	EndIf
	If  SE2->(FieldPos("E2_BASEISS")) > 0
		aadd(aCampos,{"E2_BASEISS", 0, NIL})
	EndIf
	If  SE2->(FieldPos("E2_SEST")) > 0
		aadd(aCampos,{"E2_SEST", 0, NIL})
	Endif
	If  BAU->(FieldPos("BAU_CODRET")) > 0
		aAdd(aCampos,{"E2_CODRET", BAU->BAU_CODRET, Nil})
	EndIf
	if (nPos := ascan(acampos,{|x| x[1]="E2_RETCNTR"})) == 0
		aAdd(aCampos,{"E2_RETCNTR",0,Nil})
	endIf
	
	if cCalcImp == "2"
		aadd(aCampos,{"E2_DIRF", "1", NIL})
	else
		aadd(aCampos,{"E2_DIRF",iif(aRetImp[1]+aRetImp[2] > 0,"1","2"), NIL})
	endif	
	
	aadd(aCampos,{"E2_DESDOBR" 	,"N"		,NIL})
	aadd(aCampos,{"E2_HIST" 		,cHisTit	,NIL})
	aadd(aCampos,{"E2_DATAAGE" 	,DataValida(dVencto)	,NIL})
	aadd(aCampos,{"E2_ORIGEM"	,"PLSMPAG"	,NIL})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Natureza
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If GetNewPar('MV_PLNATPF','1')=='1'
		cNaturez := GetNewPar('MV_PLNTNDF','')
		cNaturez += Space( TamSx3("E2_NATUREZ")[1] - Len(cNaturez) )
	endIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄo
	//³Como ja estamos enviando para o financeiro as bases de ³
	//³calculo  dos impostos devemos deixar a natureza por    ³
	//³ultimo devido a função do no Fina050(FA050Nat2())      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄo
	aadd(aCampos,{"E2_NATUREZ" 	,cNaturez	,NIL})
	aadd(aCampos,{"E2_MOEDA" 	,01	,NIL})
	aadd(aCampos,{"E2_VALOR" 	,nVlrDebVar	,NIL})
	aadd(aCampos,{"E2_SALDO" 	,nVlrDebVar	,NIL})
	aadd(aCampos,{"E2_VLCRUZ" 	,nVlrDebVar	,NIL})
	
	// 1-nValorIR ,2-nValorCOF ,3-nValorISS ,4-nValorCSL ,5-nValorPIS ,6-nValorINS ,7-nValorSES
	aImpostos := {0,0,0,0,0,0,0} 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava SE2 - Contas a Pagar                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PLStoSE2(aCampos,,aImpostos,.t.,cCopCre,'PLSMPAG',cCondPag,lUltCalc)
		disarmTransaction()
		return {"F",STR0061,nVlrSE2}//"Erro na geração dos titulos no financeiro."
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Compensacao automatica do titulo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If Len(aRecnoDP) > 0
	
		// Armazena recno pois no momento está posicionado, porém na compensação posiciona no título FT compensado
		nRecNDF	:= SE2->(Recno()) 
		For nVez := 1 to Len(aRecnoDP)	

			// Exclusão de títulos de 1 centavo 
			SE2->(dbGoTo(aRecnoDP[nVez]))
			If SE2->E2_VALOR == 0.01 .and. !GetNewPar('MV_PLGER1C', .T.)
				
				//Exclusão deve ter o registro SE2 posicionado
				aArray := {}
				lMsErroAuto := .F.
				aArray := { { "E2_PREFIXO" , SE2->E2_PREFIXO , NIL },;
							{ "E2_NUM"     , SE2->E2_NUM     , NIL } }
 
				MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
 
				If lMsErroAuto
				    MostraErro()
				Endif
 
				Exit		
			EndIf
			
			SE2->(dbGoTo(nRecNDF))
			MaIntBxCP(2,{aRecnoDP[nVez]},,{SE2->(recno())},,{.f.,.f.,.f.,.f.,.f.,.f.},,,,SE2->E2_VALOR)
			SE2->(dbGoTo(nRecNDF))
			If SE2->E2_SALDO <= 0
				Exit
			EndIf
		Next nVez
	EndIf	 
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executo a funcao que vai gravar o historico de contestacao		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  FindFunction("PlGerCon") .and. lCriadoBGQAut .and. nRecnoSE1 > 0 .and. nRecnoSE2 > 0 .and. nRecnoBRJ > 0 .and. lOK
	
	BRJ->(DbGoTo(nRecnoBRJ))
	SE1->(DbGoTo(nRecnoSE1))
	SE2->(DbGoTo(nRecnoSE2))
	
	PlGerCon(PlsIntPad(),PlsIntPad(),BRJ->BRJ_OPEORI,BRJ->BRJ_CODIGO,cOpeLote+cAno+cMes+SUBS(cLote,7,4),;
				'1',SE2->E2_PREFIXO,SE1->E1_PREFIXO,SE2->E2_NUM,SE1->E1_NUM,SE2->E2_PARCELA,;
				SE1->E1_PARCELA,SE2->E2_TIPO,SE1->E1_TIPO,nVlrFATINT,nGlosaPag,0,nVlrSE2,'1',;
				cAno,cMes)
Endif

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refaz dados salvos...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA2->(DbSetOrder(nOrdSA2))
SA2->(DbGoTo(nRecSA2))

BAU->(DbSetOrder(nOrdBAU))
BAU->(DbGoTo(nRecBAU))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta retorno da funcao...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len(aCritica) == 0 .and. lOK 
    If nVlrSE2 > 0 .or. !GetNewPar("MV_PLFORGE",.F.) .or. nVlrDebVar > 0 .Or. nPrcSld > 0
        If nVlrSE2 > 0
		aCritica := {"1","Titulo gerado com sucesso ",nVlrSE2}
        elseif nVlrDebVar > 0
            aCritica := {"1","NDF gerado com sucesso",nVlrDebVar}
        elseif nPrcSld > 0
            aCritica := {"1","Pedido de compra gerado com sucesso ",nPrcSld}
        EndIf        
	Else
		aCritica := {"7","Nao houve saldo neste Ano/Mes",0}
	EndIf		
Endif

Aadd(aCritica,aSaldo)//04
Aadd(aCritica,nVlrDebVar+nVlrImp)//05
Aadd(aCritica,nVlrIr)//06

Return(aCritica)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVALPAG  ³ Autor ³ Tulio Cesar       ³ Data ³ 15.03.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de pagamento a uma rede de atendimento     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVALPAG(cFunCha)
LOCAL cAno        := ""
LOCAL cMes        := ""
LOCAL dDatMvIni   := ctod("")
LOCAL dDatMvFin   := ctod("")
LOCAL cLocDigIn   := ""
LOCAL cLocDigFi   := ""
LOCAL cCodPegIn   := ""
LOCAL cCodPegFi   := ""
LOCAL cNumMovIn   := ""
LOCAL cNumMovFi   := ""
LOCAL cCodOpe     := PLSINTPAD()
LOCAL aValor      := {}
LOCAL oDlg
LOCAL nOrdBAU  := BAU->(IndexOrd())
LOCAL nRecBAU  := BAU->(Recno())
LOCAL bRest    := { || BAU->(DbSetOrder(nOrdBAU)), BAU->(DbGoTo(nRecBAU)) }
LOCAL oTree
LOCAL oTreeVerba
LOCAL nInd        := 0           
LOCAL cQuebra     := ""
LOCAL bOK      := { || oDlg:End() }
LOCAL oGrupo
LOCAL oSay
LOCAL oSayTot
LOCAL nTotCre  := 0
LOCAL nTotDeb  := 0
LOCAL nTotal   := 0
LOCAL cTipo       := ""
LOCAL aButtons := { }
LOCAL cBmp        := ""
LOCAL aVerbas     := {}
LOCAL oFolder
LOCAL cCdEmpDeS   := ""
LOCAL cCdEmpAteS  := ""
LOCAL cExcessao   := ""
LOCAL cLoteImp    := ""
LOCAL cCodNat  	  := ""
LOCAL lGuiCob  	  := .F.
LOCAL cPagCod  	  := ""
LOCAL aADDButtons :={}    
LOCAL i           := 0
LOCAL cProcDe     := MV_PAR33
LOCAL cProcate    := MV_PAR34
LOCAL aArea		:= GetArea()
LOCAL lAneste    := .F.
DEFAULT cFunCha 	:= ""

//Nome da Enchoice
cCadastro := "Produção do Prestador - "+mv_par01+"/"+mv_par02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a funcao chamadora for "PLSA470" (Botao "Saldo Posicionado"), nao ³
//³ chama tela de parametros e aproveita os parametros ja informados.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFunCha == "PLSA470"  
	
	If !EMPTY(cProcDe) .OR. !EMPTY(cProcate)
		cAno       := mv_par01
	   	cMes       := mv_par02
		dDatMvIni  := mv_par06
		dDatMvFin  := mv_par07 
	   	cCodOpe    := mv_par14
	   	cLocDigIn  := ""
	  	cLocDigFi  := "ZZZZ"
	  	cNumMovIn  := ""
	  	cNumMovFi  := "ZZZZZZZZ"
	Else
		cAno       := mv_par01
	    cMes       := mv_par02           
	    dDatMvIni  := mv_par06
	    dDatMvFin  := mv_par07
	    cLocDigIn  := mv_par08
	    cLocDigFi  := mv_par09
	    cCodPegIn  := mv_par10
	    cCodPegFi  := mv_par11
	    cNumMovIn  := mv_par12
	    cNumMovFi  := mv_par13
	    cCodOpe    := mv_par14
	    cCdEmpDeS  := mv_par15
	    cCdEmpAteS := mv_par16
	    cExcessao  := mv_par17
	    cLoteImp   := mv_par19
	    cPagCod	   := cCodDC                                
		lAneste    := mv_par41==1
	EndIf                         
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca dados dos parametros pelo usuario...                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Pergunte("PLS206",.T.)
	   Eval(bRest)
	   Return
	Else
	   cAno       := mv_par01
	   cMes       := mv_par02           
	   dDatMvIni  := mv_par03
	   dDatMvFin  := mv_par04
	   cLocDigIn  := mv_par05
	   cLocDigFi  := mv_par06
	   cCodPegIn  := mv_par07
	   cCodPegFi  := mv_par08
	   cNumMovIn  := mv_par09
	   cNumMovFi  := mv_par10
	   cCodOpe    := mv_par11
	   cCdEmpDeS  := mv_par12
	   cCdEmpAteS := mv_par13
	   cExcessao  := mv_par14
	   cLoteImp   := mv_par15
	Endif
EndIf

if Type('cExcPeg') <> 'C'
   cExcPeg := ""
endIf
if Type('cNoExcPeg') <> 'C'
	cNoExcPeg := ""
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa funcao que retornara composicao de cobranca...              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCalcImp := IF(BAU->(FieldPos("BAU_CALIMP"))>0,BAU->BAU_CALIMP,"2")

aValor := PLSLDCRE(BAU->BAU_CODIGO,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,;
					cCodPegIn,cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,BAU->BAU_CODSA2,;
					BAU->BAU_LOJSA2,/*aLancPagto*/,cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,;
					cPagCod,.F.,cCodNat,lGuiCob,/*lPgtDiv*/,/*lGerLot*/,/*lMudUs*/,/*nNewUs*/,/*nApUsDif*/,/*lAtuGui*/,;
           			/*cOpeLote*/,/*cLote*/,/*dVencto*/,cExcPeg,,,cNoExcPeg,lAneste)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata uma possivel nao-conformidade na rotina...                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! aValor[1]
	Help("",1,"PLVALPAG",,STR0062,1) //"Não existem dados de produção disponíveis para serem exibidos para essa RDA."
	eval(bRest)
	Return
Else
	aVerbas := aClone(aValor[3])
	aEval(aValor[2], { |x| If(x[1]=="2",nTotCre := nTotCre + x[2], If(x[1]=="1",nTotDeb := nTotDeb + x[2],nil))})
	If nTotDeb >= nTotCre
		cTipo  := "Debito"
		nTotal := nTotDeb - nTotCre
	Else
		cTipo  := "Credito"
		nTotal := nTotCre - nTotDeb
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona nos arquivos utilizados...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BA0")+cCodOpe,.F.))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para permite acrescentar botoes na Tela Valor de Producao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock( "PLPGBUT" ) )
	aADDButtons:=ExecBlock("PLPGBUT",.F.,.F.)
	If ValType(aADDButtons) == "A"
		For i:=1 to Len(aADDButtons)
			AADD(aButtons,aADDButtons[i])
		Next i
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dialogo com usuario...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE "Producao da Rede de Atendimento  -   "+cAno+" / "+cMes   FROM 007.2,010.3 TO 035.4,109.3 OF GetWndDefault()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define folder...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 030,005 FOLDER oFolder SIZE 196,177 OF oDlg  PIXEL	PROMPTS	"Lancamentos de Pagamento","Verbas X Valores (Int. Folha)"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta says...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 031, 208 GROUP oGrupo TO 047, 359 PIXEL OF oDlg LABEL " Operadora "  COLOR CLR_HBLUE, CLR_HRED
PLSSAYESP(038,;
			215,;
			{ || TransForm(BA1->BA1_CODINT,"@R !.!!!")+ "  -  "+subs(BA0->BA0_NOMINT,1,35) },;
			150,;
			006,;	
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

@ 051, 208 GROUP oGrupo TO 067, 359 PIXEL OF oDlg LABEL " Rede de Atendimento "  COLOR CLR_HBLUE, CLR_HRED
PLSSAYESP(058,;
			215,;
			{ || BAU->(BAU_CODIGO+" - "+BAU_NOME) },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

@ 076, 208 GROUP oGrupo TO 092, 284 PIXEL OF oDlg LABEL " Registro "  COLOR CLR_HBLUE, CLR_HRED
PLSSAYESP(083,;
			215,;
			{ || AllTrim(BAU->BAU_SIGLCR)+" "+BAU->BAU_EST+"-"+AllTrim(BAU->BAU_CONREG) },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

If cPaisLOC == 'BRA'
	@ 096, 208 GROUP oGrupo TO 120, 350 PIXEL OF oDlg LABEL " ATENÇÃO "  COLOR CLR_HRED, CLR_HBLUE
	PLSSAYESP(103,;
				215,;
				{ || "A apresentação da base do imposto não caracteriza" },;
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")
	
	PLSSAYESP(111,;
				215,;
				{ || "a retenção devida." },;
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto tree...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTree := DbTree():New(005,005,157,187,oFolder:aDialogs[1],nil,nil,.T.,nil)
oTree:BuildTrb(100, 2)
oTree:BeginUpdate()
oTree:SetEnable()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto tree...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTreeVerba := DbTree():New(005,005,157,187,oFolder:aDialogs[2],nil,nil,.T.,nil)
oTreeVerba:BuildTrb(100, 2)
oTreeVerba:BeginUpdate()
oTreeVerba:SetEnable()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados da composicao de cobranca...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nInd := 1 To Len(aValor[2])
	oTree:AddTree(aValor[2,nInd,3]+" - "+AllTrim(aValor[2,nInd,4]) + " - "+TransForm(aValor[2,nInd,2],PLPMONEY_G),nil,AllTrim(aValor[2,nInd,5]),AllTrim(aValor[2,nInd,5]),nil)
	oTree:EndTree()
Next
oTree:EndUpdate()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados das verbas...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nInd := 1 To Len(aValor[3])
	oTreeVerba:AddTree(aValor[3,nInd,1]+" - "+aValor[3,nInd,3]+ " - "+TransForm(aValor[3,nInd,2],PLPMONEY_G),nil,"GROUP","GROUP",nil)
	oTreeVerba:EndTree()
Next
oTreeVerba:EndUpdate()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta totalizadores...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 175, 208 GROUP oGrupo TO 192, 256 PIXEL OF oDlg LABEL " Creditos " COLOR CLR_HBLUE, CLR_HRED
PLSSAYESP(182,;
			210,;
			{ || TransForm(nTotCre,PLPMONEY_G)},;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

@ 175, 260 GROUP oGrupo TO 192, 305 PIXEL OF oDlg LABEL " Debitos "  COLOR CLR_HBLUE, CLR_HRED
PLSSAYESP(182,;
			259,;
			{ || TransForm(nTotDeb,PLPMONEY_G)},;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

@ 175, 310 GROUP oGrupo TO 192, 390 PIXEL OF oDlg LABEL " TOTAL "  COLOR CLR_HBLUE, CLR_HBLUE
PLSSAYESP(182,;
			315,;
			{ || TransForm(nTotal,PLPMONEY_G)+" - ("+cTipo+")"  },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bOK,.F.,aButtons)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bRest)
RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSATUVINP³ Autor ³ Tulio Cesar           ³ Data ³ 06.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Aponta dados apos efetuar pagamento a uma RDA              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSATUVINP(cLote,cOpeLote,cCodOpe,cLocDigIn,cLocDigFi,cCodPegIn,cCodPegFi,cNumMovIn,cNumMovFi,;
                    dDatMvIni,dDatMvFin,cCodRDA,cAno,cMes,cTipoUpt,dVencto,cCdEmpDeS,cCdEmpAteS,cExcessao,;
                    cCodDC,lGuiCob,cLoteImp,lSoINSS,cExcPeg, cChkSE2)
LOCAL aRegsBD7     	:= {}
LOCAL nFor,nI
LOCAL cChaveGui    	:= ""
LOCAL aAtualizados	:= {}
LOCAL aRetAux	   		:= {}
LOCAL cSQL
LOCAL cChaveCab
LOCAL cAnoPag      	:= ""
LOCAL cMesPag      	:= ""
Local cNroPgt
Local lINSSOutEmpBGQ
Local cCod170
Local lCposVld	   	:= (BBC->(FieldPos("BBC_VLDINI")) > 0 .And. BBC->(FieldPos("BBC_VLDFIM")) > 0)
Local aStruBD7 	   	:= BD7->(DbStruct())
Local nCntFor  	   	:= 0
LOCAL lObrPto  	   	:= .F.
Local lBBB_INCISS 	:= BBB->(FieldPos("BBB_INCISS")) > 0
Local lBGQ_INCISS 	:= BGQ->(FieldPos("BGQ_INCISS")) > 0
Local lOk				:= .T.
local lBD7_CHKSE2		:= BD7->(fieldPos("BD7_CHKSE2")) > 0
Local lPLPABD7      	:= Existblock("PLPAGBD7")
LOCAL lPLLIMBD7		:= Existblock("PLLIMBD7")
Local lUsaSIP			:= "1" $ GetNewPar("MV_PLSTIPO","")
Local lCentralObr		:= GetNewPar("MV_PLSEXCO",.F.)
Local lstaTiSS		:= GETNEWPAR("MV_STATISS",.F.) 

DEFAULT cCdEmpDeS  	:= ""
DEFAULT cCdEmpAteS 	:= ""
DEFAULT cExcessao  	:= ""
DEFAULT cCodDC     	:= ""
DEFAULT lGuiCob    	:= .F.
DEFAULT lSoINSS    	:= .F.
DEFAULT cLoteImp   	:= ""
DEFAULT cCodRDA    	:= ""
DEFAULT cExcPeg	   	:= ""
default cChkSE2		:= ""

BBB->(DbSetOrder(1))
If  ! empty(cCodDC)
	cCodDC := alltrim(cCodDC)
	If  right(cCodDC,1) == ","
		cCodDC := left(cCodDC,len(cCodDC)-1)
	Endif
	cCodDC := "('" + strtran(cCodDC,",","','") + "')"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata a obrigatoriedade de gerar protocolo web ou não.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lObrPto := PLSOBRPRDA() 

BAU->(dbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Condicao      					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cTipoUpt "1" - Atualizar o Lote
//         "2" - Limpar o lote
If  cTipoUpt == "1"
	cSQL := " SELECT "
	cSQL += " BD7.R_E_C_N_O_ AS REG "
	cSQL += " FROM " + RetSQLName("BD7") + " BD7, " + RetSQLName("BCI") + " BCI "
	If  lGuiCob  // pagar somente guias ja cobradas
		cSQL += ", " + RetSQLName("BD6") + " BD6"
	Endif
			
	cSQL += " WHERE ( BD7_FILIAL =  '" + xFilial("BD7") + "' ) AND "
	cSQL +=       " ( BD7_CODOPE =  '" + cCodOpe+"' ) AND "
    cSQL +=       " ( BD7_CODLDP >= '" + cLocDigIn+"' AND BD7_CODLDP <= '"+cLocDigFi+"' ) AND "
    If lObrPto
	   cSQL +=       " ( BD7_CODLDP <> '" + PLSRETLDP(9) + "' ) AND  "
	Endif
	   
	cSQL +=       " ( BD7_CODLDP <> '" + PLSRETLDP(4) + "' ) AND "
	
    cSQL +=       " ( BD7_CODPEG >= '" + cCodPegIn+"' AND BD7_CODPEG <= '"+cCodPegFi+"' ) AND "
    cSQL +=       " ( BD7_NUMERO >= '" + cNumMovIn+"' AND BD7_NUMERO <= '"+cNumMovFi+"' ) AND "
	If ( Empty(cCdEmpDeS) .And. Empty(cCdEmpAteS) ) .Or. ( Empty(cCdEmpDeS) .And. Upper(cCdEmpAteS) = "ZZZZ" )
		//nao precisa filtrar...
	Else
		cSQL += " ( BD7_CODEMP >= '"+cCdEmpDeS+"' AND BD7_CODEMP <= '"+cCdEmpAteS+"' ) AND "
	Endif
	
	If ! Empty(cExcessao)
		cSQL += "( NOT BD7_CODEMP IN "+MontaExpFil(cExcessao,4)+" ) AND "
	Endif
	cSQL += " ( BD7_SITUAC = '1' ) AND "
   cSQL += " ( BD7_FASE   = '3' OR (BD7_FASE = '4' AND BD7_OPELOT = ''  AND BD7_NUMLOT = '') ) AND "
	cSQL += " ( BD7_BLOPAG <> '1' ) AND "
	
	If ! ( Empty(dDatMvIni) .And. Empty(dDatMvFin) )
		cSQL += " ( BD7_DATPRO >= '"+dtos(dDatMvIni)+"' AND BD7_DATPRO <= '"+dtos(dDatMvFin)+"' ) AND "
	Endif
	
	If !Empty(cCodRDA)
		cSQL += " ( BD7_CODRDA = '"+cCodRDA+"' ) AND "
	EndIf          
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// Tratamento para verificar as PEG não selecionadas e selecionadas para o tratamento na montagem da QUERY
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If Len(cNoExcPeg) > Len(cExcPeg) .AND. !empty(cExcPeg)
		cSQL += "( NOT BD7_CODPEG IN " + FormatIn(cExcPeg,",")+ " ) AND "
	ElseIf !empty(cNoExcPeg)
		cSQL += "( NOT BD7_CODPEG NOT IN " + FormatIn(cNoExcPeg,",") + " ) AND "
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao generica que trata campos do estorno							   	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("PlReChvEst")
		aRetAux  := PlReChvEst("BD7",.F.,.T.,.F.,.T.)
		cSQL     += aRetAux[1]
	Endif
	cSQL += " ( BD7.D_E_L_E_T_ = ' ' ) "
	If  lGuiCob // pagar somente guias ja cobradas
		cSQL += " AND BD7_FILIAL = BD6_FILIAL "
		cSQL += " AND BD7_CODOPE = BD6_CODOPE "
		cSQL += " AND BD7_CODLDP = BD6_CODLDP "
		cSQL += " AND BD7_CODPEG = BD6_CODPEG "
		cSQL += " AND BD7_NUMERO = BD6_NUMERO "
		cSQL += " AND BD7_ORIMOV = BD6_ORIMOV "
		cSQL += " AND BD7_SEQUEN = BD6_SEQUEN "
		cSQL += " AND BD6.D_E_L_E_T_ = ' ' "
		cSQL += " AND BD6_PREFIX <> '"+Space(TamSx3("BD6_PREFIX")[1])+"' "
		cSQL += " AND BD6_NUMTIT <> '"+Space(TamSx3("BD6_NUMTIT")[1])+"' "
		cSQL += " AND BD6_PARCEL <> '"+Space(TamSx3("BD6_PARCEL")[1])+"' "
		cSQL += " AND BD6_TIPTIT <> '"+Space(TamSx3("BD6_TIPTIT")[1])+"' "
	Endif

	cSQL += " AND BCI.BCI_FILIAL = '" + xFilial("BCI") + "' "
	cSQL += " AND BCI.BCI_CODOPE = BD7.BD7_CODOPE "
	cSQL += " AND BCI.BCI_CODLDP = BD7.BD7_CODLDP "
	cSQL += " AND BCI.BCI_CODPEG = BD7.BD7_CODPEG "	
	cSql += " AND BCI.D_E_L_E_T_ = ' ' "
	If lstaTiSS
		cSQL += " AND BCI_STTISS = '3' "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente pega as guias de um determinado lote de importacao		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BD7->(FieldPos("BD7_SEQIMP")) > 0
		If !Empty(cLoteImp) .Or. GetNewPar("MV_PLFTGLI", .T.)
			cSQL += "AND ( BD7_SEQIMP = '"+cLoteImp+"' ) "
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Novo Ponto de entrada de Filtro para Cliente 						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Existblock("PLMPACTA")
		cSQL += Execblock("PLMPACTA",.f.,.f.,{})
	Endif
 	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBD7",.F.,.T.)
	
	For nCntFor := 1 To Len(aStruBD7)
		If ( aStruBD7[nCntFor,2]<>"C" )
			TcSetField("TrbBD7",aStruBD7[nCntFor,1],aStruBD7[nCntFor,2],aStruBD7[nCntFor,3],aStruBD7[nCntFor,4])
		EndIf
	Next nCntFor
	
	While ! TrbBD7->(Eof())
		
		BD7->(DbGoTo(TRBBD7->REG))
		If BD7->(BD7_ANOPAG+BD7_MESPAG) >  cAno+cMes
			TrbBD7->(DbSkip())
			Loop
		EndIf
		cChaveGui := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)
		cChaveCab := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
      	cAnoPag   := BD7->BD7_ANOPAG
      	cMesPag   := BD7->BD7_MESPAG
		
		BD7->(RecLock("BD7",.F.))
		BD7->BD7_NUMLOT := cLote
		BD7->BD7_OPELOT := cOpeLote
		
		if lBD7_CHKSE2
			BD7->BD7_CHKSE2 := cChkSE2
		endIf
		
		BD7->BD7_FASE   := "4"
		BD7->BD7_DTGRCP := dVencto
		BD7->BD7_DTPAGT := dDataBase	//Encerramento - geracao do pagamento da RDA
		BD7->(MsUnLock())
		
		If lPLPABD7
			Execblock("PLPAGBD7",.F.,.F.,{cChaveGui})
		Endif
		
		If Ascan(aAtualizados,cChaveGui) > 0
			TrbBD7->(DbSkip())
			Loop
		Endif
		
		AtualizaGuiaPagto("1",cChaveGui,cLote,cOpeLote,aAtualizados,cChaveCab)
		
		TrbBD7->(DbSkip())
	Enddo
	TrbBD7->(DbCloseArea())

	cSQL := "SELECT BCE.R_E_C_N_O_ RECBCE FROM "+RetSQLName("BCE")+" BCE WHERE "
	cSQL += " ( BCE_FILIAL = '"+xFilial("BCE")+"' ) AND "
	If !Empty(cCodRDA)
		cSQL += " ( BCE_CODIGO = '"+cCodRDA+"' ) AND "
	EndIf
	cSQL += " ( BCE_CODINT = '"+cCodOpe+"' ) AND "
	cSQL += " ( BCE_ANOPAG = '"+cAno+"' ) AND "
	cSQL += " ( BCE_MESPAG = '"+cMes+"' ) AND "
	cSQL += " ( BCE_OPELOT = '"+PlsIntPad()+"' ) AND "
	cSQL += " ( BCE_NUMLOT = '"+Space(TamSx3("BCE_NUMLOT")[1])+"' ) AND "
	cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	TcSetField("TRB","RECBCE","N",16,0)
	Do While ! TRB->(Eof())
		BCE->(DbGoTo(TRB->RECBCE))
		BCE->(RecLock("BCE", .F.))
		BCE->BCE_NUMLOT := cLote
		BCE->BCE_OPELOT := cOpeLote
		BCE->(MsUnlock())
		TRB->(DbSkip())
	EndDo
	TRB->(DbCloseArea())
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se houve Salario Contribuicao INSS Outras Empresas infor-  ³
	//³ mado no BGQ - Debitos/Creditos Variaveis                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCod170 := GetNewPar("MV_PLSCIOE","")
	
	cSQL := "SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR,BGQ_INCINS AS INCINS, "
	cSQL += "BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL "
	cSQL += " FROM "+RetSQLName("BGQ")+" WHERE "
	cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
	cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
	
	If !Empty(cCodRDA)
		cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
	EndIf
	
	cSQL += " (BGQ_ANO = '" + cAno + "' AND BGQ_MES = '"+ cMes +"' ) AND "
	
	If Empty(cCod170)
		cSQL += " ( BGQ_TIPO   = '3' ) AND "
	Else
		cSQL += " ( BGQ_CODLAN = '" + AllTrim(cCod170) + "' ) AND "
	EndIf
	
	If BGQ->(FieldPos("BGQ_ATIVO")) > 0
		cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
	EndIf
	
	cSQL += " ( BGQ_OPELOT = '"+Space(TamSx3("BGQ_OPELOT")[1])+"' ) AND "
	cSQL += " ( BGQ_NUMLOT = '"+Space(TamSx3("BGQ_NUMLOT")[1])+"' ) AND "
	
	cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
	TcSetField("TrbMPG","VALOR","N",nVlPrec,nVlDec)
	If  ! TrbMPG->(Eof())
		lINSSOutEmpBGQ := .T.
	Else
		lINSSOutEmpBGQ := .F.
	EndIf
	TrbMPG->(DbCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava BBC-Deb/Cred Fixo em BGQ para ficar registrado o historico,   ³
	//³ pois o BBC pode ser alterado a qualquer momento                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT BBC_DEBCRE AS DEBCRE, BBC_CC AS CC, BBC_CODSER AS CODSER, BBC_VALOR, BBC_QTDCH, R_E_C_N_O_ BBC_RECNO, "
	cSQL += " BBC_CODIGO AS CODRDA, BBC_NROPGT "
	cSQL += " FROM "+RetSQLName("BBC")+" WHERE "
	cSQL += " ( BBC_FILIAL = '"+xFilial("BBC")+"' ) AND "
	If !Empty(cCodRDA)
		cSQL += " ( BBC_CODIGO = '"+cCodRDA+"' ) AND "
	EndIf
	cSQL += " ( BBC_PROMED = '1' ) AND "
	cSQL += " ( BBC_STATUS = '1' ) AND "
	If lCposVld  // BOPS 98697
		cSQL += " ( '" + cAno + cMes + "01' >= BBC_VLDINI ) AND "
		cSQL += " ( ( '" + DtoS(LastDay(CtoD("01/"+cMes+"/"+cAno))) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
	EndIf
	If !Empty(cCodDC)
		cSQL += " ( BBC_CODSER IN "+cCodDC+" ) AND "
	EndIf
	cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)
	TcSetField("TrbMPG","BBC_VALOR","N",nVlPrec,nVlDec)
	TcSetField("TrbMPG","BBC_QTDCH","N",nVlPrec,nVlDec)
	TcSetField("TrbMPG","BBC_RECNO","N",16,0)
	If lCposVld
		TcSetField("TrbMPG","BBC_VLDFIM","D",8,0)
		TcSetField("TrbMPG","BBC_VLDINI","D",8,0)
	EndIf
	While !TrbMPG->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o lancamento eh "Salario Contribuicao INSS Outras Empresas" e    ³
		//³ encontrou tambem no BGQ (Debitos/Creditos variaveis), despreza.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Empty(cCod170) .And. TrbMPG->DEBCRE == "3" .And. lINSSOutEmpBGQ) .Or. ;
			(! Empty(cCod170) .And. TrbMPG->CODSER == cCod170 .And. lINSSOutEmpBGQ)
			TrbMPG->(DbSkip())
			Loop
		EndIf
			If lSoINSS .And. TrbMPG->BBC_NROPGT <> "0"
				TrbMPG->(DbSkip())
				Loop
			EndIf
		cNroPgt	:= IIf( Empty(TrbMPG->BBC_NROPGT), '0', TrbMPG->BBC_NROPGT )

		If ! PLMOVCRE(cCodRDA,cAno,cMes,,cNroPgt,,cCodOpe,cOpeLote)
			TrbMPG->(DbSkip())
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona tabelas                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BBC->(dbGoTo(TrbMPG->BBC_RECNO))
		BBB->(DbSeek(xFilial("BBB")+TrbMPG->CODSER,.F.))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula valor                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nVlrAux := 0
		If TrbMPG->BBC_VALOR > 0 //Lancado em Reais
			_nVlrAux := TrbMPG->BBC_VALOR
		ElseIf TrbMPG->BBC_QTDCH > 0 //Lancado em Qtd de CH
			//Estou criando esse M->BBC_QTDCH para reaproveitar a funcao PLSA755QTD que pega o valor baseado na qtd de ch
			M->BBC_QTDCH := 0
			PLSA755Qtd(cCodOpe,TrbMPG->BBC_QTDCH,cAno,cMes,cCodRDA,"M->BBC_QTDCH")
			_nVlrAux := M->BBC_QTDCH
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava BGQ-Deb/Cred Mensal para ficar como historico                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BGQ->(RecLock("BGQ",.T.))
		BGQ->BGQ_FILIAL := xFilial("BGQ")
		BGQ->BGQ_CODSEQ := GETSX8NUM("BGQ","BGQ_CODSEQ")
		BGQ->BGQ_CODIGO := BBC->BBC_CODIGO
		BGQ->BGQ_NOME   := posicione("BAU",1,xFilial("BAU")+BBC->BBC_CODIGO,"BAU_NOME")
		BGQ->BGQ_ANO    := cAno
		BGQ->BGQ_MES    := cMes
		BGQ->BGQ_CODLAN := BBC->BBC_CODSER
		BGQ->BGQ_VALOR  := _nVlrAux
		BGQ->BGQ_QTDCH  := BBC->BBC_QTDCH
		BGQ->BGQ_TIPO   := BBC->BBC_DEBCRE
		BGQ->BGQ_TIPOCT := BBB->BBB_TIPOCT
		BGQ->BGQ_INCIR  := BBB->BBB_INCIR
		BGQ->BGQ_INCINS := BBB->BBB_INCINS
		BGQ->BGQ_INCPIS := BBB->BBB_INCPIS
		BGQ->BGQ_INCCOF := BBB->BBB_INCCOF
		BGQ->BGQ_INCCSL := BBB->BBB_INCCSL
		BGQ->BGQ_VERBA  := BBB->BBB_VERBA
		BGQ->BGQ_CODOPE := PlsIntPad()
		BGQ->BGQ_CONMFT := BBB->BBB_CONMFT
		BGQ->BGQ_OBS    := "LANCAMENTO ORIGINADO DO DEB/CRED FIXO NA RDA"
		BGQ->BGQ_USMES  := 0 // verificar como preencher AGS ???
		BGQ->BGQ_NUMLOT := cLote
		BGQ->BGQ_OPELOT := cOpeLote
		BGQ->BGQ_LANAUT := "1"
		BGQ->BGQ_OPELAU := plsintpad()
		BGQ->BGQ_NUMLAU := "BBC"
		BGQ->BGQ_CC	  := BBC->BBC_CC
		BGQ->BGQ_ITECTA := BBC->BBC_ITECTA
		BGQ->BGQ_CLVL   := BBC->BBC_CLVL
		BGQ->BGQ_NUMCOB := ""
		BGQ->BGQ_INTERC := "0"
		BGQ->BGQ_CODEMP := ""
		BGQ->BGQ_MATRIC := ""
		BGQ->BGQ_NMSQLA := ""
		BGQ->BGQ_HORACN := ""
		BGQ->BGQ_QTDCH1 := 0
		BGQ->BGQ_QTDPAC := 0
		BGQ->BGQ_INTERC	:= IIf(Empty(cLoteImp),'0','1')
		If lBBB_INCISS .AND. lBGQ_INCISS
			BGQ->BGQ_INCISS := BBB->BBB_INCISS
		EndIf
		BGQ->(msUnLock())
		ConfirmSX8()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acessa proximo registro                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TrbMPG->(DbSkip())
	Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha arquivo de trabalho                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	TrbMPG->(DbCloseArea())
	
	cSQL := "SELECT BGQ.R_E_C_N_O_ RECBGQ FROM "+RetSQLName("BGQ")+" BGQ WHERE "
	cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
	If !Empty(cCodRDA)
		cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
	Endif
	cSQL += " ( BGQ_ANO < '" + cAno + "' OR (BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '"+ cMes +"' )) AND "
	If BGQ->(FieldPos("BGQ_ATIVO")) > 0 // .And.GetNewPar("MV_PLATIOD","0") == '1'
		cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
	EndIf
	cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
	cSQL += " ( BGQ_NUMLOT = '          ' ) AND "
	If  ! empty(cCodDC)
		cSQL += " ( BGQ_CODLAN IN " + cCodDC + " ) AND "
	Endif
	cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
	
	If Existblock("PLMPALAN")
		cSQL += Execblock("PLMPALAN",.f.,.f.,{})
	Endif
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	TcSetField("TRB","RECBGQ","N",16,0)
	
	Do While ! TRB->(Eof())
		BGQ->(DbGoTo(TRB->RECBGQ))
		//Outras Empresas e mes diferente da competencia NAO considerar
		If ((!Empty(cCod170) .And. BGQ->BGQ_CODLAN == AllTrim(cCod170) );
			.Or. BGQ->BGQ_TIPO == "3").And. !(BGQ->BGQ_ANO == cAno .And. BGQ->BGQ_MES == cMes)
			TRB->(DbSkip())
			Loop
		Endif
		BGQ->(RecLock("BGQ", .F.))
		BGQ->BGQ_NUMLOT := cLote
		BGQ->BGQ_OPELOT := cOpeLote
		BGQ->(MsUnlock())
		TRB->(DbSkip())
	EndDo
	TRB->(DbCloseArea())
	
// Limpar o Lote
ElseIf cTipoUpt == "2"
	
	cSQL := "SELECT "
	cSQL += " BD7.R_E_C_N_O_ AS REG "
	cSQL += " FROM "+RetSQLName("BD7")+" BD7 WHERE "
	cSQL += " ( BD7_FILIAL = '"+xFilial("BD7")+"' ) AND "
	cSQL += " ( BD7_CODOPE = '"+cCodOpe+"' ) AND "
	cSQL += " ( BD7_OPELOT = '"+cOpeLote+"' ) AND "
	cSQL += " ( BD7_NUMLOT = '"+cAno+cMes+cLote+"' ) AND "
	If !Empty(cCodRDA)
		cSQL += " ( BD7_CODRDA = '"+cCodRDA+"' ) AND "
	EndIf
	cSQL += " ( D_E_L_E_T_ = ' ' ) "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBD7",.F.,.T.)
	TcSetField("TrbBD7","REG","N",16,0)
	TrbBD7->( DBEval({|| aadd(aRegsBD7,TrbBD7->REG) }) )
	TrbBD7->(DbCloseArea())
	
	cSQL := "SELECT BD7.R_E_C_N_O_ RECBD7 FROM "+RetSQLName("BD7")+" BD7 WHERE "
	cSQL += " ( BD7_FILIAL = '"+xFilial("BD7")+"' ) AND "
	cSQL += " ( BD7_CODOPE = '"+cCodOpe+"' ) AND "
	cSQL += " ( BD7_OPELOT = '"+cOpeLote+"' ) AND "
	cSQL += " ( BD7_NUMLOT = '"+cAno+cMes+cLote+"' ) AND "
	If !Empty(cCodRDA)
		cSQL += " ( BD7_CODRDA = '"+cCodRDA+"' ) AND "
	EndIf
	cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	
	For nCntFor := 1 To Len(aStruBD7)
		If ( aStruBD7[nCntFor,2]<>"C" )
			TcSetField("TRB",aStruBD7[nCntFor,1],aStruBD7[nCntFor,2],aStruBD7[nCntFor,3],aStruBD7[nCntFor,4])
		EndIf
	Next nCntFor
	
	Do While ! TRB->(Eof())
		
		BD7->(DbGoTo(TRB->RECBD7))
    	
    	cAnoPag := BD7->BD7_ANOPAG
    	cMesPag := BD7->BD7_MESPAG
		
		BD7->(RecLock("BD7", .F.))
		BD7->BD7_NUMLOT := ""
		BD7->BD7_OPELOT := ""
		
		if lBD7_CHKSE2
			BD7->BD7_CHKSE2 := ""
		endIf
		
		BD7->BD7_FASE   := "3"
		BD7->BD7_DTGRCP := StoD("")
		BD7->BD7_DTPAGT := StoD("")	//Encerramento - geracao do pagamento da RDA
		BD7->(MsUnlock())
		
		If lPLLIMBD7
			Execblock("PLLIMBD7",.F.,.F.,{})
		Endif
		
		TRB->(DbSkip())
	EndDo
	
	TRB->(DbCloseArea())
	
	For nFor := 1 To Len(aRegsBD7)
		
		BD7->(DbGoTo(aRegsBD7[nFor]))
		cChaveGui := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)
		cChaveCab := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
		
		If Ascan(aAtualizados,cChaveGui) > 0
			Loop
		Endif
		
		BD7->(DbSetOrder(6))
		If ! BD7->(DbSeek(xFilial("BD7")+cChaveGui+"4",.F.)) //nao existe nada faturado para esta guia, em nenhum BD7...
			//atualizar ela como pronta novamente...
			BD7->(DbGoTo(aRegsBD7[nFor])) //Reposicionar...
			AtualizaGuiaPagto("0",cChaveGui,cLote,cOpeLote,aAtualizados,cChaveCab)
		Endif
	Next
	cSQL := "SELECT BCE.R_E_C_N_O_ RECBCE FROM "+RetSQLName("BCE")+" BCE WHERE "
	cSQL += " ( BCE_FILIAL = '"+xFilial("BCE")+"' ) AND "
	If !Empty(cCodRDA)
		cSQL += " ( BCE_CODIGO = '"+cCodRDA+"' ) AND "
	EndIf
	cSQL += " ( BCE_CODINT = '"+cCodOpe+"' ) AND "
	cSQL += " ( BCE_ANOPAG = '"+cAno+"' ) AND "
	cSQL += " ( BCE_MESPAG = '"+cMes+"' ) AND "
	cSQL += " (  BCE_OPELOT = '"+cOpeLote
	cSQL += "'  AND BCE_NUMLOT = '"+cAno+cMes+cLote+"' ) AND "
	cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	TcSetField("TRB","RECBCE","N",16,0)
	Do While ! TRB->(Eof())
		BCE->(DbGoTo(TRB->RECBCE))
		BCE->(RecLock("BCE", .F.))
		BCE->BCE_NUMLOT := ""
		BCE->BCE_OPELOT := ""
		BCE->(MsUnlock())
		TRB->(DbSkip())
	EndDo
	TRB->(DbCloseArea())
	
	cSQL := "SELECT BGQ.R_E_C_N_O_ RECBGQ FROM "+RetSQLName("BGQ")+" BGQ WHERE "
	cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
	If !Empty(cCodRDA)
		cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
	EndIF
	cSQL += " ( BGQ_ANO < '" + cAno + "' OR (BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '"+ cMes +"' )) AND "
	cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
	cSQL += " ( BGQ_OPELOT = '"+cOpeLote+"'  AND BGQ_NUMLOT = '"+cAno+cMes+cLote+"' ) AND  "
	cSQL += " ( BGQ_LANAUT = '1' ) AND "
	cSQL += " ( BGQ_PREFIX = ' ' AND BGQ_NUMTIT = ' ' AND BGQ_TIPTIT = ' ' ) AND "
	If BGQ->(FieldPos("BGQ_ATIVO")) > 0
		cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
	EndIf
	//cSQL += " ( Rtrim(BGQ_NUMLAU) = 'BBC' ) AND "
	cSQL += "  BGQ_INTERC <> '1'  AND "
	cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	TcSetField("TRB","RECBGQ","N",nVlPrec,nVlDec)
	Do While ! TRB->(Eof())
		BGQ->(DbGoTo(TRB->RECBGQ))
		BGQ->(RecLock("BGQ", .F.))
		BGQ->(DbDelete())
		BGQ->(MsUnlock())
		TRB->(DbSkip())
	EndDo
	TRB->(DbCloseArea())
	
	//EXCLUO LANCAMENTO AUTOMATICO DE INTERCAMBIO
	cSQL := "SELECT BGQ.R_E_C_N_O_ RECBGQ FROM "+RetSQLName("BGQ")+" BGQ WHERE "
	cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
	If !Empty(cCodRDA)
		cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
	EndIf
	cSQL += " ( BGQ_ANO < '" + cAno + "' OR (BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '"+ cMes +"' )) AND "
	cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
	cSQL += " ( BGQ_OPELOT = '"+cOpeLote+"'  AND BGQ_NUMLOT = '"+cAno+cMes+cLote+"' ) AND  "
	cSQL += " ( BGQ_INTERC = '1' AND BGQ_NUMCOB = ' ') AND "
	cSQL += " ( BGQ_LANAUT = '1' ) AND "
	If BGQ->(FieldPos("BGQ_ATIVO")) > 0
		cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
	EndIf
	cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	TcSetField("TRB","RECBGQ","N",16,0)
	Do While ! TRB->(Eof())
		BGQ->(DbGoTo(TRB->RECBGQ))
		BGQ->(RecLock("BGQ", .F.))
		BGQ->(DbDelete())
		BGQ->(MsUnlock())
		TRB->(DbSkip())
	EndDo
	TRB->(DbCloseArea())
	cSQL := "SELECT BGQ.R_E_C_N_O_ RECBGQ FROM "+RetSQLName("BGQ")+" BGQ WHERE "
	cSQL += " ( BGQ_FILIAL = '"+xFilial("BGQ")+"' ) AND "
	If !Empty(cCodRDA)
		cSQL += " ( BGQ_CODIGO = '"+cCodRDA+"' ) AND "
	EndIf
	cSQL += " ( BGQ_ANO < '" + cAno + "' OR (BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '"+ cMes +"' )) AND "
	cSQL += " ( BGQ_CODOPE = '"+cCodOpe+"' ) AND "
	cSQL += " ( BGQ_OPELOT = '"+cOpeLote+"' AND BGQ_NUMLOT = '"+cAno+cMes+cLote+"' ) AND "
	If BGQ->(FieldPos("BGQ_ATIVO")) > 0
		cSQL += " ( BGQ_ATIVO  <> '0' ) AND "
	EndIf
	cSQL += " ( D_E_L_E_T_ = ' ' ) "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	TcSetField("TRB","RECBGQ","N",16,0)
	Do While ! TRB->(Eof())
		BGQ->(DbGoTo(TRB->RECBGQ))
		
		If ( BGQ->BGQ_LANAUT <> "1" ) .Or. ;
			( BGQ->BGQ_LANAUT == "1" .And. Empty(BGQ->BGQ_NMSQLA) )
			BGQ->(RecLock("BGQ", .F.))
			BGQ->BGQ_NUMLOT := ""
			BGQ->BGQ_OPELOT := ""
			BGQ->(MsUnlock())
		Endif
		
		TRB->(DbSkip())
	EndDo
	TRB->(DbCloseArea())
	If lCentralObr .And. lUsaSIP//Chama o JOB da central de obrigacoes para o SIP

		cChvOpe := xFilial("BA0")+cOpeLote
		nTipProc := 1
		aThreads := {}
		
		aAdd(aThreads,{;
		{2},;								//01-
		"JobSIP"+StrZero(nTipProc,2),;		//02-
		"Nao",;								//03-
		nTipProc,;							//04-
		0,;									//05-
		Time(),;							//06-
		"",;								//07-
		"",;								//08-
		"JobSIPSta"+StrZero(nTipProc,2),;	//09-
		"BR_VERDE",;						//10-
		"JobSIPPerc"+StrZero(nTipProc,2),;	//11-
		Nil,;								//12-
		"JobSIPProc"+StrZero(nTipProc,2),;	//13-
		"JobSIPEvPr"+StrZero(nTipProc,2),;	//14-
		0,;									//15-
		"JobSIPEvDs"+StrZero(nTipProc,2),;	//16-
		0,;									//17-
		"Normal",;							//18-
		0,;									//19-
		0,;									//20-
		.F.,;								//21-
		{},;								//22-
		})
		
		cDataRef := DTOS(dDataBase)
		cTipData := GetNewPar("MV_PLSIPDT","1")
		cRegANS := Posicione("BA0",1,cChvOpe,"BA0_SUSEP")
		lGerRepas := .F.
		nFor := 1
		lCriticado := .F.
		aLotePgto := {/*1*/cOpeLote,/*2*/cAno,/*3*/cMes,/*4*/cLote,/*5*/.F.}
		
		StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,cDataRef,cTipData,cRegANS,lGerRepas,nFor,1,lCriticado,aLotePgto)
	  //StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,cDataRef,cTipData,cRegANS,lGerRepas,nFor,1,lCriticado,{})

	EndIf
	
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSCRIABLR ³ Autor ³ Tulio Cesar         ³ Data ³ 21.06.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Cria os codigos de lancamento de pagamento de sistema...   ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCRIABLR(cCodOpe)
LOCAL nFor
BLR->(DbSetOrder(1))
For nFor := 100 To 200
	// Pula lançamentos vagos para evitar pesquisa inutil, há um aviso na funçao de criaçao PLSINCBLR()
	If nFor == 107
		nFor := 166
	EndIf
	If !BLR->(DbSeek(xFilial("BLR")+cCodOpe+StrZero(nFor,3),.F.))
		PLSINCBLR(StrZero(nFor,3),cCodOpe)
	Endif
Next

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSMONLPGT³ Autor ³ Tulio Cesar           ³ Data ³ 21.06.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Monta um array com os lancamento de pagto e propriedades   ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSMONLPGT(aLancPagto,cCodOpe)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aPropri
Local lBLR_CODPRO := BLR->(FieldPos("BLR_CODPRO")) > 0
Local lBLR_TES := BLR->(FieldPos("BLR_TES"   )) > 0
Local lBLS_INCISS := BLS->(FieldPos("BLS_INCISS")) > 0
Local lBLS_TES := BLS->(FieldPos("BLS_TES")) > 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa a existencia dos codigos de lancamentos de sistema (internos) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSCRIABLR(cCodOpe)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera matriz (teoricamente ela sempre vai vir zerada)...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLancPagto := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acessa arquivo principal (BLR)...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BLR->(DbSetOrder(1))
If BLR->(DbSeek(xFilial("BLR")+cCodOpe,.F.))
	While ! BLR->(Eof()) .And. BLR->(BLR_FILIAL+BLR_CODINT) == xFilial("BLR")+cCodOpe
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera matriz com as propriedades do lancto atual...                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aPropri := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca as propriedades...                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BLS->(DbSetOrder(1))
		If BLS->(DbSeek(xFilial("BLS")+BLR->(BLR_CODINT+BLR_PROPRI+BLR_CODLAN),.F.))
			While ! BLS->(Eof()) .And. BLS->(BLS_FILIAL+BLS_CODINT+BLS_CODLAN) == ;
				xFilial("BLS")+BLR->(BLR_CODINT+BLR_PROPRI+BLR_CODLAN)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona as propriedades...                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aPropri,{BLS->BLS_CALIMP,;
								BLS->BLS_TIPOCT,;
								BLS->BLS_INCIR,;
								BLS->BLS_INCINS,;
								BLS->BLS_INCPIS,;
								BLS->BLS_INCCOF,;
								BLS->BLS_INCCSL,;
					IIf(lBLS_INCISS, BLS->BLS_INCISS, "1" ),;
				BLS->BLS_VERBA,;
				IIf(lBLS_TES, BLS->BLS_TES, "" ) })                                               
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acessa proxima propriedade...                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BLS->(DbSkip())
			Enddo
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona cod. lancamento mais propriedades...                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aLancPagto,{BLR->BLR_CODINT,;
							BLR->BLR_PROPRI,;
							BLR->BLR_CODLAN,;
							BLR->BLR_DESCRI,;
							BLR->BLR_SEQUEN,;
							BLR->BLR_DEBCRE,;
							AllTrim(BLR->BLR_IMG),;
							BLR->BLR_CONTAB,;
							aPropri,;
							BLR->BLR_VERBA,;
		BLR->BLR_USO,;                                           
		IIf(lBLR_CODPRO, BLR->BLR_CODPRO, "" ),;
		IIf(lBLR_TES, BLR->BLR_TES, "" ) })
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acessa proximo lancto de pagto...                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BLR->(DbSkip())
	Enddo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aLancPagto)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³AnalisaImp³ Autor ³ Tulio Cesar           ³ Data ³ 21.06.04    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Analisa se uma determinada combinacao vai ter impostos ou nao ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AnalisaImp(cTipCalc,cTipUsr,aPropri,nValor,;
							nVlrB_IR,nVlrB_INPF,nVlrB_INPJ,nVlrB_INJF,nVlrB_PIS,nVlrB_COF,nVlrB_CSL,;
							aVerbasFol,nVlrBD7PFI,nVlrBD7PJI,nVlrBD7JFI,cCodEmp,cMatric,aSEFIP,nVlrB_ISS,;
							lPagRda,nVlrBD6Ato,nVlrB_INHP, nVlrBD7PHP)
                           
LOCAL nPos		:= 0
LOCAL cVerba   	:= ""
LOCAL nIndSEFIP	:= 0
LOCAL cNewTpCalc := ""

DEFAULT nVlrBD7PFI := 0
DEFAULT nVlrBD7PJI := 0
DEFAULT nVlrBD7JFI := 0
DEFAULT nVlrBD7PHP := 0
DEFAULT nVlrBD6Ato := 0
DEFAULT nVlrB_INHP := 0
DEFAULT lPagRda    := .F.

//Para atualizar a base de impostos
If lPagRda 
	nValor += nVlrBD6Ato
EndIf

// Para geração da SEFIP é esperado o tipo 3 ou 4, não posso alterar e gravar como 1.
// BLS_CALIMP (1-Folha/2-Financeiro)
If  cTipCalc $ "3,4" // Compatibiliza nova forma de calculo (4)
	cNewTpCalc := "1"
Else
	cNewTpCalc := "2" 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa para o tipo de integracao e depois tipo de usuario...         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := Ascan(aPropri,{|x| x[1] == cNewTpCalc .And. x[2] == cTipUsr })

If nPos == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa para o tipo de integracao e depois tipo de usuario indiferente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos := Ascan(aPropri,{|x| x[1] == cNewTpCalc .And. x[2] == "9" })
Endif

If nPos > 0

	// Somente para documentacao
	//  lIncINSS := aPropri[nPos,4]=="1"
	//	lIncIR   := aPropri[nPos,3]=="1"
	//	lIncPIS  := aPropri[nPos,5]=="1"
	//	lIncCof  := aPropri[nPos,6]=="1"
	//	lIncCSL  := aPropri[nPos,7]=="1"
	//	lIncISS  := aPropri[nPos,8]=="1"
	cVerba   := aPropri[nPos,9]
	
	nVlrB_IR	+= IIf( aPropri[nPos,3] == "1", nValor, 0 )
	nVlrB_PIS	+= IIf( aPropri[nPos,5] == "1", nValor, 0 )
	nVlrB_COF	+= IIf( aPropri[nPos,6] == "1", nValor, 0 )
	nVlrB_CSL	+= IIf( aPropri[nPos,7] == "1", nValor, 0 )
	nVlrB_ISS	+= IIf( aPropri[nPos,8] == "1", nValor, 0 )
	
	If aPropri[nPos,4] == "1"
		
		nIndSEFIP := fIndSEFIP(cCodEmp, "", "", cMatric, cTipCalc, @aSEFIP)
		
		If cTipUsr == "2" 									//PJ
			nVlrB_INPJ += nVlrBD7PJI
			aSEFIP[nIndSEFIP, 7] += nVlrBD7PJI
		ElseIf cTipUsr == "3" 								//PJ filant
			nVlrB_INJF += nVlrBD7JFI
			aSEFIP[nIndSEFIP, 8] += nVlrBD7JFI
		ElseIf cTipUsr == "4" 								// Classifica como Honorario Patronal
			nVlrB_INHP += nVlrBD7PHP
			aSEFIP[nIndSEFIP, 9] += nVlrBD7PHP
		Else												// Classifica como PF
			nVlrB_INPF += nVlrBD7PFI
			aSEFIP[nIndSEFIP, 6] += nVlrBD7PFI
		Endif
		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Monta totalizador da verba...                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AnalisaVerbas(cVerba,aVerbasFol,nValor)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSINCBLR ³ Autor ³ Tulio Cesar           ³ Data ³ 06.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Inclui os codigos do BLR (lancamento de pagamento) sob     ³±±±
±±³          ³ demanda...                                                 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSINCBLR(cCodigo,cCodOpe)
Local aParCBLR:={}

If cCodigo = "101"
	aParCBLR:={cCodOpe,"1","01","Producao","001","2","0","3","S4WB005N"}
ElseIf cCodigo == "102"
	aParCBLR:={cCodOpe,"1","02","Debitos mensais fixos","002","1","0","3","S4WB005N"}
ElseIf cCodigo == "103"
	aParCBLR:={cCodOpe,"1","03","Creditos mensais fixos","003","2","0","3","S4WB005N"}
ElseIf cCodigo == "104"
	aParCBLR:={cCodOpe,"1","04","Creditos variaveis","004","2","0","3","S4WB005N"}
ElseIf cCodigo == "105"
	aParCBLR:={cCodOpe,"1","05","Debitos variaveis","005","1","0","3","S4WB005N"}
ElseIf cCodigo == "106"
	aParCBLR:={cCodOpe,"1","06","Apontamentos Producao","006","2","0","3","SALARIOS"}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATENCAO:                                                                  ³
//³Se utilizar lancamentos de 107 a 165, deve-se modificar a PLSCRIABLR(),   ³
	//³funçao da chamada desta rotina, para que seja considerados os lancamentos.³
	//³RC - 20100416.                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cCodigo == "166"
	aParCBLR:={cCodOpe,"1","66","Prov INSS Hon.Patronal ","966","1","0","3","DEPEDENTES"}
ElseIf cCodigo == "167"
	aParCBLR:={cCodOpe,"1","67","Valor Base INSS Hon.Patronal","967","3","0","1","DEPEDENTES"}
ElseIf cCodigo == "168"
	aParCBLR:={cCodOpe,"1","68","Valor INSS Honorário Patronal","968","1","0","1","RESPONSA"}
ElseIf cCodigo == "169"
	aParCBLR:={cCodOpe,"1","69","IR Retido Out Fontes","969","3","0","1","DEPEDENTES"}
ElseIf cCodigo == "170"
	aParCBLR:={cCodOpe,"1","70","Sal Contrib INSS Out Empresas","970","3","0","1","DEPEDENTES"}
ElseIf cCodigo == "178"
	aParCBLR:={cCodOpe,"1","78","Prov INSS PJ Filantropica","978","1","0","3","DEPEDENTES"}
ElseIf cCodigo == "179"
	aParCBLR:={cCodOpe,"1","79","Prov INSS PJ","979","1","0","3","DEPEDENTES"}
ElseIf cCodigo == "180"
	aParCBLR:={cCodOpe,"1","80","Prov INSS PF","980","1","0","3","DEPEDENTES"}
ElseIf cCodigo == "181"
	aParCBLR:={cCodOpe,"1","81","Cred Prov INSS","981","2","0","3","DEPEDENTES"}
ElseIf cCodigo == "182"
	aParCBLR:={cCodOpe,"1","82","Valor Base INSS","982","3","0","3","DEPEDENTES"}
ElseIf cCodigo == "183"
	aParCBLR:={cCodOpe,"1","83","Valor INSS","983","1","0","3","RESPONSA"}
ElseIf cCodigo == "184"
	aParCBLR:={cCodOpe,"1","84","Valor Base ISS","984","3","0","2","DEPEDENTES"}
ElseIf cCodigo == "185"
	aParCBLR:={cCodOpe,"1","85","Valor ISS","985","1","0","2","RESPONSA"}
ElseIf cCodigo == "186"
	aParCBLR:={cCodOpe,"1","86","Valor Base PIS","986","3","0","2","DEPEDENTES"}
ElseIf cCodigo == "187"
	aParCBLR:={cCodOpe,"1","87","Valor PIS","987","1","0","2","RESPONSA"}
ElseIf cCodigo == "188"
	aParCBLR:={cCodOpe,"1","88","Valor Base COFINS","988","3","0","2","DEPEDENTES"}
ElseIf cCodigo == "189"
	aParCBLR:={cCodOpe,"1","89","Valor COFINS","989","1","0","2","RESPONSA"}
ElseIf cCodigo == "190"
	aParCBLR:={cCodOpe,"1","90","Valor Base CSLL","990","3","0","2","DEPEDENTES"}
ElseIf cCodigo == "191"
	aParCBLR:={cCodOpe,"1","91","Valor CSLL","991","1","0","2","RESPONSA"}
ElseIf cCodigo == "192"
	aParCBLR:={cCodOpe,"1","92","Valor Base INSS PF","992","3","0","1","DEPEDENTES"}
ElseIf cCodigo == "193"
	aParCBLR:={cCodOpe,"1","93","Valor INSS PF","993","1","0","1","RESPONSA"}
ElseIf cCodigo == "194"
	aParCBLR:={cCodOpe,"1","94","Valor Base INSS PJ","994","3","0","1","DEPEDENTES"}
ElseIf cCodigo == "195"
	aParCBLR:={cCodOpe,"1","95","Valor INSS PJ","995","1","0","1","RESPONSA"}
ElseIf cCodigo == "196"
	aParCBLR:={cCodOpe,"1","96","Valor Base INSS PJ Filantropicas","996","3","0","1","DEPEDENTES"}
ElseIf cCodigo == "197"
	aParCBLR:={cCodOpe,"1","97","Valor INSS PJ Filantropicas","997","1","0","1","RESPONSA"}
ElseIf cCodigo == "198"
	aParCBLR:={cCodOpe,"1","98","Valor Base Imposto de Renda","998","3","0","3","DEPEDENTES"}
ElseIf cCodigo == "199"
	aParCBLR:={cCodOpe,"1","99","Imposto de Renda","999","1","0","3","RESPONSA"}
Endif

If Len(aParCBLR)>0
	BLR->(RecLock("BLR",.T.))
	BLR->BLR_FILIAL  := xFilial("BLR")
	BLR->BLR_CODINT  := aParCBLR[1]
	BLR->BLR_PROPRI  := aParCBLR[2]
	BLR->BLR_CODLAN  := aParCBLR[3]
	BLR->BLR_DESCRI  := aParCBLR[4]
	BLR->BLR_SEQUEN  := aParCBLR[5]
	BLR->BLR_DEBCRE  := aParCBLR[6]
	BLR->BLR_CONTAB  := aParCBLR[7]
	BLR->BLR_USO     := aParCBLR[8]
	BLR->BLR_IMG     := aParCBLR[9]
	BLR->(MsUnLock())
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLMOVCRE ³ Autor ³ Tulio Cesar           ³ Data ³ 07.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna se ja foi gerado titulo para um credenciado em um  ³±±±
±±³          ³ determinado Ano/Mes                                        ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLMOVCRE(cCodRDA,cAno,cMes,lMsg,cNroPgt,cCodlan,cCodOpe,cOpeLote)
LOCAL nOrdSE2   := nPlOrdSE2
LOCAL lReturn   := .T.
LOCAL nOrdBAU   := BAU->(IndexOrd())
LOCAL nRecBAU   := BAU->(Recno())
Local nPgtos    := 0
Local cCod170 	:= GetNewPar("MV_PLSCIOE","")
LOCAL cNumPre		:= ""
DEFAULT lMsg    := .F.
DEFAULT cNroPgt := "0"
DEFAULT cCodlan := ""
DEFAULT cCodOpe := PlsIntPad()
DEFAULT cOpeLote := PlsIntPad() 

If BAU->BAU_CODIGO <> cCodRDA
	BAU->(DbSetOrder(1))
	BAU->(DbSeek(xFilial("BAU")+cCodRDA,.F.))
	BAU->(DbSetOrder(nOrdBAU))
Endif

BMR->(dbSetOrder(1))
// Se codigo 0 (zero) todos os Pagamentos deverao conter este lancamento de Debito/Credito Fixo senao, 
// conta qtos pagamentos ja foram efetuados para este lancamento
// BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN
If BMR->(DbSeek(xFilial("BMR")+cCodOpe+cCodRDA+cOpeLote+cAno+cMes,.F.)) .and. cNroPgt <> "0" 
	cLastLote := BMR->BMR_NUMLOT
	nPgtos++
	Do While !BMR->(Eof()) .And. BMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT) == ;
		xFilial("BMR")+cCodOpe+cCodRDA+cOpeLote+cAno+cMes
		If BMR->BMR_NUMLOT # cLastLote
			cLastLote := BMR->BMR_NUMLOT
			nPgtos++
		Endif
		BMR->(DbSkip())
	EndDo
Endif


// Se está chamando pelo PLSLDCRE vem com o cCodlan preenchido e adiciona 1 que é o pagamento que será gerado agora,
// senão já foi gerado o título e já vem com o nPgtos no número do pagamento atual 
nPgtos += IIf(Empty(cCodlan),0, 1)
	
// Verifica se o pagamento que esta sendo calculado, eh o que devera conter este lancto de Debito/Credito Fixo
// ou Caso ainda nao haja pagamento calculado, so permite se o cNroPgt for igual a 0-Todos os Pagamento ou 1-Primeiro Pagamento
If Alltrim(Str(nPgtos)) <> cNroPgt .and. !cNroPgt $ "0"
	lReturn := .F.
EndIf

If lMsg .And. !lReturn
	Help("",1,"PLMOVCRE")
Endif

BAU->(DbGoTo(nRecBAU))

Return(lReturn)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLCANCRE ³ Autor ³ Tulio Cesar           ³ Data ³ 20.06.01 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Cancelar geracao de titulos a pagar.                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLCANCRE()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros                                                          ³
//³ nenhum   - o titulo deve estar posicionado                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aCampos   := {}
LOCAL nOldMod
LOCAL lOK       := .T.
LOCAL nOrdSE2   := SE2->(IndexOrd())
LOCAL nRecSE2   := SE2->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Campos que serao gravados com valores pre-definidos no SE2... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {{"E2_PREFIXO"  ,SE2->E2_PREFIXO, Nil},;
			{"E2_NUM"	   ,SE2->E2_NUM,	  Nil},;
			{"E2_PARCELA"  ,SE2->E2_PARCELA, Nil},;
			{"E2_TIPO"	   ,SE2->E2_TIPO,	  Nil},;
			{"E2_FORNECE"  ,SE2->E2_FORNECE, Nil},;
			{"E2_LOJA"     ,SE2->E2_LOJA,    Nil},;
			{"E2_ORIGEM"   ,SE2->E2_ORIGEM,  Nil},;
			{"E2_NATUREZ"  ,SE2->E2_NATUREZ, Nil}}

lMsErroAuto := .F.
lMsHelpAuto := .T.

SE2->(DbSetOrder(1))

// Ponto de Entrada criado em 06/04/2006 - BOPS 96540
If ExistBlock("PLSE2EXC")
	ExecBlock("PLSE2EXC",.F.,.F.)
Endif

SE2->(dbGoTo(nRecSE2))

if empty(SE2->E2_TITPAI) .or. getNewPar("MV_PLPGUNI","1") == "2"
	msExecAuto({|x,y,z| Fina050(x,y,z)},aCampos,K_Excluir,K_Excluir)
endIf


If lMsErroAuto
	MostraErro()
	lOK := .F.
Endif

SE2->(DbSetOrder(nOrdSE2))
SE2->(DbGoTo(nRecSE2))

Return({lOK})
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³analisaverbas³ Autor ³ Tulio Cesar        ³ Data ³ 20.06.01 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Analisa a inclusao de valores nas verbas para a folha de pg³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AnalisaVerbas(cVerba,aVerbasFol,nValor)
LOCAL nPos
If ! Empty(cVerba)
	nPos := Ascan(aVerbasFol,{|x| x[1] == cVerba})
	If nPos > 0
		aVerbasFol[nPos,2] += nValor
	Else
		aadd(aVerbasFol,{cVerba,nValor,SRV->(Posicione("SRV",1,xFilial("SRV")+cVerba,"RV_DESC"))})
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³AtualizaGuiaPagto³ Autor ³ TOTVS		   ³ Data ³ 20.06.01 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Atualiza Guia Pagamentos									 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AtualizaGuiaPagto(cTipo,cChaveGui,cLote,cOpeLote,aAtualizados,cChaveCab)
//cTipo "1" Atualizar
//      "0" Desatualizar
Local cTipRec		:= "" //P - Peg; G-Guia; I-Item
Local cChaveBCI	:= SubStr(cChaveCab,1,Len(cChaveCab)-TamSx3("BD7_NUMERO")[1])
Local lRecGlo := PLSALIASEX("B4D")//BCI->(FieldPos("BCI_CODGLO")) > 0 
Local cOldNumGui	:= ""
Default cTipo		:= ""
Default cChaveGui	:= ""
Default cLote       := ""
Default cOpeLote    := ""
Default aAtualizados:= {}
Default cChaveCab	:= ""

BD6->(DbSetOrder(1))
If BD6->(DbSeek(xFilial("BD6")+cChaveGui,.F.))
	While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
		xFilial("BD6")+cChaveGui
		If ( cTipo == "1" .And. BD6->BD6_FASE == "3" ) .Or. ;
			( cTipo == "0" .And. BD6->BD6_FASE == "4" )
			//Verifico se mudou de guia e descubro o tipo de recurso da nova guia
			If lRecGlo .AND. cOldNumGui != BD6->BD6_NUMERO
				cTipRec := ChkTpRec(BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG),BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))
			EndIf
			BD6->(RecLock("BD6",.F.))
			If cTipo == "1"
				BD6->BD6_NUMLOT := cLote
				BD6->BD6_OPELOT := cOpeLote
				BD6->BD6_FASE   := "4"
				BD6->BD6_DTPAGT := dDataBase	//Encerramento - geracao do pagamento da RDA
				If lRecGlo .AND. cTipRec == "I" .AND. BD6->BD6_VLRGLO > 0
					//Inclui recurso para o procedimento
					PlsNewRecG("BD6",cChaveCab,cChaveBCI,cTipRec,cTipo,cLote,cOpeLote)
				EndIf
			Else
				BD6->BD6_NUMLOT := ""
				BD6->BD6_OPELOT := ""
				BD6->BD6_FASE   := "3"
				BD6->BD6_DTPAGT := StoD("")		//Encerramento - geracao do pagamento da RDA
				If lRecGlo .AND. cTipRec == "I" .AND. BD6->BD6_VLRGLO > 0
					//Inclui recurso para o procedimento
					PlsNewRecG("BD6",cChaveCab,cChaveBCI,cTipRec,cTipo,cLote,cOpeLote)
				EndIf
			Endif
			cOldNumGui := BD6->BD6_NUMERO
			BD6->(MsUnLock())
		Endif
		BD6->(DbSkip())
	Enddo
Endif
If lRecGlo
	cTipRec := ChkTpRec(cChaveBCI,cChaveCab)
EndIf
If lRecGlo .AND. cTipRec == "P"
	//Inclui recurso para o procedimento
	PlsNewRecG( "BCI",cChaveCab,cChaveBCI,cTipRec,cTipo,cLote,cOpeLote)
EndIf
cOldGui := ""
If BD7->BD7_TIPGUI <> "05"//BD5
	BD5->(DbSetOrder(1))
	If BD5->(DbSeek(xFilial("BD5")+cChaveCab,.F.))
		If ( cTipo == "1" .And. BD5->BD5_FASE == "3" ) .Or. ;
			( cTipo == "0" .And. BD5->BD5_FASE == "4" )
			BD5->(RecLock("BD5",.F.))
			If cTipo == "1"
				BD5->BD5_NUMLOT := cLote
				BD5->BD5_OPELOT := cOpeLote
				BD5->BD5_FASE   := "4"
				BD5->BD5_DTPAGT := dDataBase	//Encerramento - geracao do pagamento da RDA 
				If lRecGlo .AND. cTipRec == "G"
					//Inclui recurso para o procedimento
					PlsNewRecG("BD5",cChaveCab,cChaveBCI,cTipRec,cTipo,cLote,cOpeLote)
				EndIf
			Else
				BD5->BD5_NUMLOT := ""
				BD5->BD5_OPELOT := ""
				BD5->BD5_FASE   := "3"
				BD5->BD5_DTPAGT := StoD("")	//Encerramento - geracao do pagamento da RDA
				If lRecGlo .AND. cTipRec == "G"
					//Inclui recurso para o procedimento
					PlsNewRecG("BD5",cChaveCab,cChaveBCI,cTipRec,cTipo,cLote,cOpeLote)
				EndIf
			Endif
			BD5->(MsUnLock())
			aadd(aAtualizados,cChaveGui)
		Endif
	Endif
	cAlias := "BD5"
Else //BE4
	BE4->(DbSetOrder(1))
	If BE4->(DbSeek(xFilial("BE4")+cChaveCab,.F.))
		If ( cTipo == "1" .And. BE4->BE4_FASE == "3" ) .Or. ;
			( cTipo == "0" .And. BE4->BE4_FASE == "4" )
			BE4->(RecLock("BE4",.F.))
			If cTipo == "1"
				BE4->BE4_NUMLOT := cLote
				BE4->BE4_OPELOT := cOpeLote
				BE4->BE4_FASE   := "4"
				BE4->BE4_DTPAGT := dDataBase	//Encerramento - geracao do pagamento da RDA
				If lRecGlo .AND. cTipRec == "G"
					//Inclui recurso para o procedimento
					PlsNewRecG("BE4",cChaveCab,cChaveBCI,cTipRec,cTipo,cLote,cOpeLote)
				EndIf
			Else
				BE4->BE4_NUMLOT := ""
				BE4->BE4_OPELOT := ""
				BE4->BE4_FASE   := "3"
				BE4->BE4_DTPAGT := StoD("")	//Encerramento - geracao do pagamento da RDA
				If lRecGlo .AND. cTipRec == "G"
					//Inclui recurso para o procedimento
					PlsNewRecG("BE4",cChaveCab,cChaveBCI,cTipRec,cTipo,cLote,cOpeLote)
				EndIf
			Endif
			BE4->(MsUnLock())
			aadd(aAtualizados,cChaveGui)
		Endif
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³CriaSX1206	   ³ Autor ³ TOTVS		   ³ Data ³ 20.06.01 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³Cria Perguntas			 								 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChkTpRec(cChaveBCI,cChaveCab)
Local cTipRec	:= "P"
//cChaveGui := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)
	BCI->(DbSetOrder(1)) //BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC
	BD5->(DbSetOrder(1)) //BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_SITUAC+BD5_FASE+dtos(BD5_DATPRO)+BD5_OPERDA+BD5_CODRDA
	B4D->(DbSetOrder(5)) //B4D_FILIAL+B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT
	//cChaveB4D := cChaveCab
	//Identifica o tipo de Recurso que será incluído
	If BCI->(MsSeek(xFilial("BCI")+cChaveBCI))
		If BCI->(FieldPos("BCI_CODGLO")) > 0 .And. !Empty(BCI->BCI_CODGLO)
			cTipRec := "P"
			//cChaveB4D := cChaveBCI
		Else
			If BD7->BD7_ORIMOV == "1" 
				If BD5->(MsSeek(xFilial("BD5")+cChaveCab)) .AND. !Empty(BD5->BD5_CODGLO)
					cTipRec := "G"
				Else
					cTipRec := "I"
				EndIf
			Else
				If BE4->(MsSeek(xFilial("BE4")+cChaveCab)) .AND. !Empty(BE4->BE4_CODGLO)
					cTipRec := "G"
				Else
					cTipRec := "I"
				EndIf
			EndIf
		EndIf 
	Else
		cTipRec := "I"
	EndIf
Return cTipRec

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³MontaExpFil	   ³ Autor ³ TOTVS		   ³ Data ³ 20.06.01 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³Monta Expressao Filtro	 								 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaExpFil(cExcessao,nTam)
LOCAL nFor
LOCAL cRet := "("
LOCAL cAux := Alltrim(cExcessao)

For nFor := 1 To Len(cAux) Step nTam
	cRet += "'"+Subs(cAux,nFor,nTam)+"',"
	nFor ++
Next

cRet := Subs(cRet,1,Len(cRet)-1)+")"

Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaTITOpeºAutor  ³Microsiga           º Data ³  05/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria título de contestação                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CriaTITOpe(cOpeOri,cAno,cMes,nVlrGlosa,cCodInt)
LOCAL nOrdBA0 := BA0->(IndexOrd())
LOCAL nRecBA0 := BA0->(Recno())
LOCAL nOrdSA1 := SA1->(IndexOrd())
LOCAL nRecSA1 := SA1->(Recno())
Local cNumero       := ""
LOCAL cPrefixo:= GetNewPar("MV_PLPREE1",'"PLS"')
LOCAL cTipTit := GetNewPar("MV_PLSTPTA",'"FT"')
LOCAL aCpoSE1 := {}
LOCAL aBases  := {0,0,0,0,0,0}
LOCAL lContabiliza := .F.
Local nDiasVcto := GetNewPar("MV_PLVCTTC", 10)
LOCAL lRet      := .F.
DEFAULT cCodInt := ""

cPrefixo := eval({|| &cPrefixo })
cTipTit  := eval({|| &cTipTit })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na operadora origem para pegar o cliente...               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA0->(DbSetOrder(1))
SA1->(DbSetOrder(1))
If BA0->(DbSeek(xFilial("BA0")+cOpeOri,.F.)) .And. SA1->(DbSeek(xFilial("SA1")+BA0->(BA0_CODCLI+BA0_LOJCLI),.F.))
	
	cNumero := PLSE1NUM(cPrefixo)
	
	aadd(aCpoSE1, {"E1_FILIAL"	 , xFilial("SE1")} )
	aadd(aCpoSE1, {"E1_TIPO"     , cTipTit        } )
	aadd(aCpoSE1, {"E1_CLIENTE"  , SA1->A1_COD    } )
	aadd(aCpoSE1, {"E1_LOJA"     , SA1->A1_LOJA   } )
	aadd(aCpoSE1, {"E1_NATUREZ"  , SA1->A1_NATUREZ} )
	aadd(aCpoSE1, {"E1_EMISSAO"  , dDataBase      } )
	aadd(aCpoSE1, {"E1_EMIS1"    , dDataBase      } )
	aadd(aCpoSE1, {"E1_MOEDA"    , 1              } )
	aadd(aCpoSE1, {"E1_OCORREN"  , "01"           } )
	aadd(aCpoSE1, {"E1_FLUXO"    , "S"            } )
	aadd(aCpoSE1, {"E1_STATUS"   , "A"            } )
	aadd(aCpoSE1, {"E1_PROJPMS"  , "2"            } )
	aadd(aCpoSE1, {"E1_VENCORI"  , dDataBase + nDiasVcto } )
	aadd(aCpoSE1, {"E1_VENCTO"   , dDataBase + nDiasVcto } )
	aadd(aCpoSE1, {"E1_ANOBASE"  , cAno           } )
	aadd(aCpoSE1, {"E1_MESBASE"  , cMes           } )
	aadd(aCpoSE1, {"E1_PREFIXO"  , cPrefixo       } )
	aadd(aCpoSE1, {"E1_NUM"      , cNumero        } )
	aadd(aCpoSE1, {'E1_PARCELA'	, ''   	         } )
	aadd(aCpoSE1, {"E1_VENCREA"  , DataValida(dDataBase + nDiasVcto)} )
	aadd(aCpoSE1, {"E1_VLCRUZ"   , nVlrGlosa      } )
	aadd(aCpoSE1, {"E1_IRRF"	    , 0              } )
	aadd(aCpoSE1, {"E1_VALOR"    , nVlrGlosa      } )
	aadd(aCpoSE1, {"E1_NOMCLI"   , SA1->A1_NOME   } )
	aadd(aCpoSE1, {"E1_SALDO"    , nVlrGlosa      } )
	aadd(aCpoSE1, {"E1_MULTNAT"  , "2"            } )
	aadd(aCpoSE1, {'E1_DECRESC'	, 0              } )
	aadd(aCpoSE1, {'E1_SDDECRE'	, 0              } )
	aadd(aCpoSE1, {'E1_ACRESC'	, 0              } )
	aadd(aCpoSE1, {'E1_SDACRES'	, 0              } )
	aadd(aCpoSE1, {'E1_VALLIQ'	, 0              } )
	aadd(aCpoSE1, {'E1_NUMBCO'	, ""             } )
	aadd(aCpoSE1, {'E1_PLNUCOB'	, ""             } )
	aadd(aCpoSE1, {'E1_INSS'	    , 0              } )
	aadd(aCpoSE1, {'E1_COFINS'	, 0              } )
	aadd(aCpoSE1, {'E1_PIS'		, 0              } )
	aadd(aCpoSE1, {'E1_IRRF'	    , 0              } )
	aadd(aCpoSE1, {'E1_CSLL'	    , 0              } )
	aadd(aCpoSE1, {'E1_ISS'      , 0				 } )
	aadd(aCpoSE1, {'E1_ORIGEM' 	, "PLSMPAG"	     } )
	aadd(aCpoSE1, {'E1_CODINT'	, cCodInt        } )
	aadd(aCpoSE1, {'E1_CODEMP'	, ""             } )
	aadd(aCpoSE1, {'E1_CODCOR'	, ""             } )
	aadd(aCpoSE1, {'E1_ROTINA'	, "FINA040"      } )
	aadd(aCpoSE1, {'E1_APLVLMN'	, "1" 			 } )
	If SE1->(FieldPos('E1_VRETIRF')) > 0
		aadd(aCpoSE1, {'E1_VRETIRF'	, 0			 } )
	EndIf
	If  SE1->(FieldPos("E1_PLORIG")) > 0
		Aadd(aCpoSE1, {'E1_PLORIG', ""            } )
	Endif
	If  SE1->(FieldPos("E1_CODISS")) > 0
		Aadd(aCpoSE1, {'E1_CODISS', ""            } )
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array para geracao de NOTA                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PLStoSe1(aCpoSE1,aBases,cMes,cAno,"PLSMPAG",lContabiliza,nil,nil,cPrefixo,nil,nil,nil,nil,nil,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se houver PE grava BRJ com as informacoes alteradas                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PLSE1GRV")
		cPrefixo := SE1->E1_PREFIXO  
		cNumero  := SE1->E1_NUM 
		cTipTit  := SE1->E1_TIPO
	Endif	    
	
	lRet := .T.
	
Endif

BA0->(DbSetOrder(nOrdBA0))
BA0->(DbGoTo(nRecBA0))
SA1->(DbSetOrder(nOrdSA1))
SA1->(DbGoto(nRecSA1))

Return({lRet,cPrefixo,cNumero,"",cTipTit})



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PLSDEPIR ³ Autor ³ Angelo Sperandio      ³ Data ³ 23.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Identifica o numero de dependentes para IR do prestador    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSDEPIR(cCodRda,cAno,cMes)
Local nDepIr    := 0
Local cDepIr
Local nIdade
Local lTemDep   := .F.
Local nTamChave
Local cChaveInd
Local cChaveSRA
Local cChaRda
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se possui dependentes cadastrados na RDA e quantos incidem p/ IR³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  BBE->(FieldPos("BBE_TIPDIR")) > 0
	BBE->(dbSetOrder(1))
	BBE->(DbSeek(xFilial("BBE") + cCodRda,.F.))
	While ! BBE->(eof()) .and. BBE->BBE_FILIAL + BBE->BBE_CODIGO == xFilial("BBE") + cCodRda;
		.and. val(substr(dtos(BBE->BBE_DATINC),1,6)) <= val(cAno+cMes)
		lTemDep := .T.
		If  BBE->BBE_TIPDIR == '1' // sem limite de idade
			nDepIr++
		Else
			If  BBE->BBE_TIPDIR == '2' // ate 21 anos
				nIdade := int((val(cAno+cMes) - val(substr(dtos(BBE->BBE_DATNAS),1,6))) / 100)
				If  nIdade <= 21
					nDepIr++
				Endif
			Else
				If  BBE->BBE_TIPDIR == '3' // ate 24 anos
					nIdade := int((val(cAno+cMes) - val(substr(dtos(BBE->BBE_DATNAS),1,6))) / 100)
					If  nIdade <= 24
						nDepIr++
					Endif
				Endif
			Endif
		Endif
		BBE->(dbSkip())
	Enddo
Endif
cDepIr := strzero(nDepIr,2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao possui dependentes cadastrados na RDA, verifica no SRA            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ! lTemDep
	If  GetNewPar("MV_PLCHSRA","1") == "1" // chave SRA - 1=CPF 2=RG
		cChaRda   := posicione("BAU",1,xFilial("BAU")+cCodRda,"BAU_CPFCGC")
		nTamChave := TamSX3("RA_CIC")[1]
		cChaveInd := "RA_CIC + RA_FILIAL + RA_MAT"
		cChaveSRA := left(cChaRda+space(nTamChave),nTamChave)
	Else
		cChaRda   := posicione("BAU",1,xFilial("BAU")+cCodRda,"BAU_RG")
		nTamChave := TamSX3("RA_RG")[1]
		cChaveInd := "RA_RG + RA_FILIAL"
		cChaveSRA := left(cChaRda+space(nTamChave),nTamChave)
	Endif
	If (nOrdemSRA := RetOrdem("SRA",cChaveInd,.T.)) <> 0
		SRA->(dbSetOrder(nOrdemSRA))
		If  ! Empty(cChaveSRA) .and. SRA->(DbSeek(cChaveSRA,.F.))
			cDepIr := SRA->RA_DEPIR
		Endif
	Endif
Endif
If  empty(cDepIr)
	cDepIr := "00"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da funcao                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cDepIr)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PLSINTGPE³ Autor ³ Angelo Sperandio      ³ Data ³ 13.08.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Calcula impostos atraves da integracao com a folha         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSINTGPE(lGraImp,cCodRda,cAno,cMes,aVerbas,cOpeLote,cLote,cObsoleto,cCodForn,cLoja,cHisTit,nBIrPls,nBInsPfPls,nBInsPjPls,nScoOutEmp,lAutonomo,dVenTit,aImpMes,lUltCalc,nVrIRRet,nBInsJFPls,lPgtoImp,aCompPag,lPgUni4,cNumero,lHist,cTipoTit,nBInsHPPls,nBInsUNPls)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ Procedimentos:                                                      ³
//³ - Calcular pro-labore pela folha                                    ³
//³ - Fazer os demais lancamento no PLS:                                ³
//³   . Plantonistas                                                    ³
//³   . Demais debitos/creditos                                         ³
//³ - Fazer o calculo da RDA pelo PLS                                   ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPercJur  	:= GetNewPar("MV_PLINSPJ",0.20) //0.20 – tipo numérico – Descrição: Perc. Inss para atendimento a pessoa jurídica
Local nPercFis  	:= GetNewPar("MV_PLINSPF",0.20) //0.20- tipo numérico - Descrição: Perc. Inss para atendimento a pessoa física
Local nPercJF	  	:= GetNewPar("MV_PLINSFT",0.20) //0.20- tipo numérico - Descrição: Perc. Inss para atendimento a pessoa jurídica filantrópica
Local nPercHp	  	:= GetNewPar("MV_PLINSHP",0.11) //0.11- tipo numérico - Descrição: Perc. Inss para atendimento em honorários patronais

Local nBasInCal		:= 0 		// base de INSS já calculada anteriormente
Local aPensaoPLS	:= {}
Local lRet			:= .F.
Local cRet          := ""
Local cChaveSRA
LOCAL nPos
LOCAL cChaveInd
Local nBasePro	:= 0
local nBaseJur	:= 0
local nBaseFis	:= 0
local nBaseJF	:= 0
local nBaseHP	:= 0
Local nBaseUN	:= 0
Local nValoJur,nValoFis,nValoPro
Local nValAuxJ,nValAuxP,nValAuxF
Local nBsAcumJ,nBsAcumP,nBsAcumF
Local nBaseTot,nBaseOut,nValoOut,nBaseAux
Local nTamChave		:= 0
Local nValBaseIr		:= 0.00
Local nValIr			:= 0.00
Local nValDedInss	:= 0.00
Local nx				:= 0
Local nOrdemSRA		:= 0
Local cFilProc     	:= SM0->M0_CODFIL
Local dData_Ref
Local cFilMatCorr	:= ""
Local cDepIr       	:= "00"
Local cChaRda
Local nTetoInss
Local aBMR    		:= {}
Local aIrrf        	:= {}
Local aSE2         	:= {}
Local nSE2         	:= 0
Local nVlrSE2      	:= 0
Local nValor       	:= 0
Local nTotal       	:= 0
Local i
Local lFirst       	:= .T.
Local aImpostos		:= {}
Local cAnoSE2
Local cMesSE2
Local nBirFol      	:= 0 // base irrf folha
Local nVirFol      	:= 0 // valor irrf folha
Local nInssFol     	:= 0 // valor inss folha
Local nInssFis		:= 0
Local nInssJur		:= 0
Local nInssJF		:= 0
Local nInssHP		:= 0
Local nInssBU		:= 0
Local nInssUni		:= 0
Local dNextDay
Local n
Local dNextMes
Local dNextVen
Local dVencRea
Local aRecnoIrf     := {}
Local aRecnoIns     := {}
Local lSalvou       := .F.
Local nSeq          := 0
Local cParcIns 		 := ''
Local nRecSeG  		 := 0
local nVlrAux			:= 0
Local cHistor       := ""
Local nDedFol
Local cIdeRot       := "PLSMPAG "
Local cCodCha       := cOpeLote + cLote + CCodRda
Local dVencto
Local lTemIrfAdi
Local cAnoMesIrf    := ""
Local cCodRet
LOCAL nAuxRetImp    := 0
LOCAL cCondPag   	:= ""
LOCAL aArea
LOCAL cTitPai 		:= ""
local cLojaLan		:= '00'
local cCodFInss		:= allTrim(getNewPar("MV_FORINSS","INSS"))
local cNatuInss		:= allTrim(&(getNewPar("MV_INSS","INSS")))
local cCodFIR			:= allTrim(getNewPar("MV_UNIAO","UNIAO"))
local cNatuIR			:= allTrim(&(getNewPar("MV_IRF",'IR')))
Local lBMR_ANOVCT := BMR->(FieldPos('BMR_ANOVCT')) >0
Local lBMR_MESVCT := BMR->(FieldPos('BMR_MESVCT')) >0
Local lBAU_CODRET := BAU->(FieldPos("BAU_CODRET")) > 0
Local nTamCodFol	    := TamSX3("RV_CODFOL")[1] // verifica se foi aplicado o update na folha que passa para 4 o numero de caractere,
Local cNaturez	:= ''
Private nRedDep      := 0
cCodFInss 	:= cCodFInss + space(tamSx3("A2_COD")[1] - len(cCodFInss))
cNatuInss 	:= cNatuInss + space(tamSx3("ED_CODIGO")[1] - len(cNatuInss))
cCodFIR 	:= cCodFIR + space(tamSx3("A2_COD")[1] - len(cCodFIR))
cNatuIR 	:= cNatuIR + space(tamSx3("ED_CODIGO")[1] - len(cNatuIR))

Private aTabIr[6,3]

DEFAULT aVerbas     := {}
DEFAULT nBIrPls     := 0
DEFAULT nBInsPfPls  := 0
DEFAULT nBInsPjPls  := 0
DEFAULT nBInsJFPls  := 0
DEFAULT nBInsHPPls  := 0
DEFAULT nBInsUNPls  := 0
DEFAULT nScoOutEmp  := 0
DEFAULT lAutonomo   := .F.
// Caso nao tenha sido passado como parametro, zera array de bases e impostos ja calculados no mes para a RDA
DEFAULT aImpMes     := { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
DEFAULT lUltCalc    := .F.
DEFAULT nVrIRRet    := 0
DEFAULT aCompPag    := {}
DEFAULT lPgUni4		:= .F.
DEFAULT cNumero     := ""
DEFAULT lHist       := .T. // Controle da gravacao de historico RDA,rotina de pagamento de lote RDA. Tabela B03.
DEFAULT cTipoTit		:= cTipo
DEFAULT lPgtoImp		:= .f.

// Verifica se utiliza base unica de INSS
If !cCodRDA == BAU->BAU_CODIGO
	BAU->(dbSetOrder(1))
	BAU->(dbSeek(xFilial('BAU')+cCodRDA,.F.))
EndIf
nPercFis	:= IIf( BAU->BAU_BASINS == '1', nPercJur, nPercFis )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina ano/mes para calculo de IR                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMv("MV_VENCIRF") == "E"
	cAnoMesIrf := substr(dtos(dDataBase),1,6)
ElseIf GetMv("MV_VENCIRF") == "C"
	cAnoMesIrf := substr(dtos(dDataBase),1,6)
Else
	cAnoMesIrf := substr(dtos(dVenTit),1,6)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona BAU                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  BAU->BAU_CODIGO <> cCodRDA
	BAU->(DbSetOrder(1))
	If  ! BAU->(DbSeek(xFilial("BAU")+cCodRDA,.F.))
		Return({0,0,.F.,"RDA nao encontrada"})
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  GetNewPar("MV_PLCHSRA","1") == "1" // chave SRA - 1=CPF 2=RG
	cChaRda   := BAU->BAU_CPFCGC
	nTamChave := TamSX3("RA_CIC")[1]
	cChaveInd := "RA_CIC + RA_FILIAL + RA_MAT"
	nTamChave := TamSX3("RA_CIC")[1]
	cChaveSRA := left(cChaRda+space(nTamChave),nTamChave)
Else
	cChaRda   := BAU->BAU_RG
	nTamChave := TamSX3("RA_RG")[1]
	cChaveInd := "RA_RG + RA_FILIAL"
	nTamChave := TamSX3("RA_RG")[1]
	cChaveSRA := left(cChaRda+space(nTamChave),nTamChave)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida parametros                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  empty(cAno) .or. empty(cMes)
	msgStop("Mes/Ano invalido: " + cMes + "/" + cAno)
	Return({0,0,.F.,"Mes/Ano invalido"})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica verbas utilizadas                              	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  len(aVerbas) == 0

	If nTamCodFol > 3
		aVerbas := array(9999,7) //Como o RV_CODFOL agora pode ter até 4 posições, temos que inicializar com 9999, ou irá dar array out of bounds ali embaixo
	else
		aVerbas := array(999,7)
	EndIf
	
	For nPos := 1 to len(aVerbas)
		aVerbas[nPos,1] := "" // Identificador de calculo
		aVerbas[nPos,2] := "" // Codigo da verba
		aVerbas[nPos,3] := 0  // INSS
		aVerbas[nPos,4] := 0  // IR acumulados
		aVerbas[nPos,5] := 0  // IR adiantamento
		aVerbas[nPos,6] := 0  // IR
		aVerbas[nPos,7] := 0  // INSS p/ IR
	Next
	SRV->(dbGoTop())
	While ! SRV->(eof())
		If nTamCodFol > 3 // para os casos em que fou aplicado o update na folha passando para 4 o tamanho do id fol
			If  Substr(SRV->RV_CODFOL,2,3) $ getNewPar("MV_PLCODFL","066,012,015,010,064,065,221,013,288")
				aVerbas[val(SRV->RV_CODFOL),1] := Substr(SRV->RV_CODFOL,2,3)
			aVerbas[val(SRV->RV_CODFOL),2] := SRV->RV_COD
			aVerbas[val(SRV->RV_CODFOL),3] := 0
			aVerbas[val(SRV->RV_CODFOL),4] := 0
			aVerbas[val(SRV->RV_CODFOL),5] := 0
			aVerbas[val(SRV->RV_CODFOL),6] := 0
			aVerbas[val(SRV->RV_CODFOL),7] := 0
			Endif
		Else
			If  SRV->RV_CODFOL $ getNewPar("MV_PLCODFL","066,012,015,010,064,065,221,013,288")
				aVerbas[val(SRV->RV_CODFOL),1] := SRV->RV_CODFOL
				aVerbas[val(SRV->RV_CODFOL),2] := SRV->RV_COD
				aVerbas[val(SRV->RV_CODFOL),3] := 0
				aVerbas[val(SRV->RV_CODFOL),4] := 0
				aVerbas[val(SRV->RV_CODFOL),5] := 0
				aVerbas[val(SRV->RV_CODFOL),6] := 0
				aVerbas[val(SRV->RV_CODFOL),7] := 0
			Endif
		Endif
		SRV->(dbSkip())
	Enddo
	// IR---
	// 066 valor ir
	// 012 valor ir adiantamento
	// 015 base ir (ja com o inss abatido)
	// 010 base ir adiantamento (ja com o inss abatido) (ja contem o ir da folha)
	// INSS---
	// 064 valor inss
	// 065 valor inss ferias
	// 221 base inss prolabore e autonomo
	// 013 salario contribuicao ate limite
	// 288 sal contribuicao outras empresas
Else
	For nPos := 1 to len(aVerbas)
		aVerbas[nPos,3] := 0
		aVerbas[nPos,4] := 0
		aVerbas[nPos,5] := 0
		aVerbas[nPos,6] := 0
		aVerbas[nPos,7] := 0
	Next
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o ambiente do GPE antes de calcular				 ³
//³ Seta e Carrega os Mnemonicos.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetMnemonicos(NIL,NIL,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis necessarias ao calculo e carga de tabelas.		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
c__Roteiro	:= "FOL"											// Indica para as funcoes da folha que o
SRA->(DbSeek(xFilial("SRA")))
// calculo e do tipo "Folha de Pagamento"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando a Tabela do Salario Minimo						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ! Sal_Min(@Val_SalMin,cAno+cMes,xFilial())
	return({0,0,.F.,"Tabela salario minimo nao encontrada"})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando a  Tabela do INSS								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ! Car_inss(@aTInss,cAno+cMes)
	return({0,0,.F.,"Tabela de INSS nao encontrada"})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Variaveis Codigos da Folha							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !FP_CODFOL(@aCodFol,cFilProc)
	return({0,0,.F.,"Ident. de calculo da Folha nao encontrados"})
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verifica se foram cadastrados os identificadores para calculo
//³ do autonomo que presta servico a P.Fisica e Juridica.		 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Pagto servicos prestados P.FISICA Ded INSS Base IR
if	empty(aCodFol[349,1]) .Or. empty(aCodFol[167,1]) 	   	 
	return({0,0,.F.,"Verbas nao encontradas - id. calculo: 349,167"})
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verifica o fornecedor e natureza para INSS
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SED->(dbSetOrder(1))//ED_FILIAL+ED_CODIGO
if !SED->(dbSeek(xFilial("SED")+cNatuInss,.F.))
	return({0,0,.F.,"Natureza ["+cNatuInss+"] invalida"})
endIf

SA2->(DbSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA
if !SA2->(DbSeek(xFilial("SA2")+cCodFInss + cLojaLan,.f.))
	return({0,0,.F.,"Fornecedor ["+cCodFInss+"] invalido"})
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verifica o fornecedor e natureza para IR
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if !SED->(dbSeek(xFilial("SED")+cNatuIR,.F.))
	return({0,0,.F.,"Natureza ["+cNatuIR+"] invalida"})
endIf

if !SA2->(DbSeek(xFilial("SA2")+cCodFIr + cLojaLan,.f.))
	return({0,0,.F.,"Fornecedor ["+cCodFIr+"] invalido"})
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Teto do recolhimento de INSS                              	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTetoInss := aTInss[Len(aTInss),1]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca o funcionario atual em outros registros do cadastro	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOrdemSRA := RetOrdem("SRA",cChaveInd,.T.)) <> 0

	SRA->(dbSetOrder(nOrdemSRA))
	If !Empty(cChaveSRA) .and. SRA->(DbSeek(cChaveSRA,.F.))
		While ! SRA->(eof())
			If  GetNewPar("MV_PLCHSRA","1") == "1" // chave SRA - 1=CPF 2=RG
				If  SRA->RA_CIC <> cChaveSRA
					Exit
				Endif
			Else
				If  SRA->RA_RG <> cChaveSRA
					Exit
				Endif
			Endif
			If  SRA->RA_SITFOLH <> "D" .or. (SRA->RA_SITFOLH == "D" .and. MesAno(SRA->RA_DEMISSA) == cAno+cMes)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Busca os valores do movimento existentes para esta matricula.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  cAno+cMes == getmv("MV_FOLMES")  //  EM CACHOEIRO A FOLHA SEMPRE ESTA FECHADA ?????????   VERIFICAR DEMAIS CLIENTES
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Folha em aberto - busca os valores do movimento mensal       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SRC->(dbsetorder(1))
					If SRC->(DbSeek(SRA->(RA_FILIAL+RA_MAT),.F.))
					    While ! SRC->(eof()) .and. SRC->(RC_FILIAL+RC_MAT) == SRA->(RA_FILIAL+RA_MAT)
						    nPos := aScan(aVerbas,{|x| x[2]== SRC->RC_PD})
						    If  nPos > 0
							    aVerbas[nPos,3] += SRC->RC_VALOR
						    Endif
						    SRC->(dbskip())
					    Enddo
				    EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa variaveis                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lTemIrfAdi := .F.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Folha fechada - busca valores da folha no acumulados anuais  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SRD->(dbsetorder(4))
					SRD->(DbSeek(SRA->(RA_FILIAL+RA_MAT)+cAno+cMes,.F.))
					While ! SRD->(eof()) .and. SRD->(RD_FILIAL+RD_MAT+substr(dtos(SRD->RD_DATPGT),1,6)) == SRA->(RA_FILIAL+RA_MAT)+cAno+cMes
			    //No While acima trocamos o RD_DATARQ pelo _DATPGT devido a solicitacao do cliete 		
						nPos := aScan(aVerbas,{|x| x[2]== SRD->RD_PD})
						If  nPos > 0
							
							// Se for verba de INSS, soma direto no array de verbas
							// 064 valor inss
							// 065 valor inss ferias
							// 221 base inss prolabore e autonomo
							// 013 salario contribuicao ate limite
							If  aVerbas[nPos,1] $ "064,065,221,013"
								aVerbas[nPos,3] += SRD->RD_VALOR
								If  substr(dtos(SRD->RD_DATPGT),1,6) == cAnoMesIrf
									aVerbas[nPos,7] += SRD->RD_VALOR
								Endif
							Endif
							
							// Se for verba de INSS, soma direto no array de verbas
							// 288 sal contribuicao outras empresas
							//  --> Como somava somente se RD_SEMANA estivesse vazio, havia alguns casos que
							//      nao estava calculando corretamente o desconto de INSS para a RDA.
							//      Passou a salvar o valor do ultimo lancamento ref. id de calculo 288,
							//      independente do campo "semana" estar preenchido.
							// If  aVerbas[nPos,1] == "288" .and. empty(SRD->RD_SEMANA)
							//    aVerbas[nPos,3] += SRD->RD_VALOR
							If  aVerbas[nPos,1] == "288"
								aVerbas[nPos,3] := SRD->RD_VALOR
							Endif
							
							// Se for verba de IR, soma no array de verbas de IR - buscou no SRD-Acumulados Anuais
							// 066 304 valor ir
							// 015 683 base ir (ja com o inss abatido)
							If  aVerbas[nPos,1] $ "066,015"
								If  substr(dtos(SRD->RD_DATPGT),1,6) == cAnoMesIrf
									aVerbas[nPos,4] += SRD->RD_VALOR
								Endif
							Endif
						Endif
						
						SRD->(dbskip())
						
					Enddo
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Folha fechada - verifica se ja existe algum valor calculado na folha do mes  ³
					//³ apenas imposto de renda - regime de caixa                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SRC->(dbsetorder(1))
					SRC->(DbSeek(SRA->(RA_FILIAL+RA_MAT),.F.))
					While ! SRC->(eof()) .and. SRC->(RC_FILIAL+RC_MAT) == SRA->(RA_FILIAL+RA_MAT)
						
						nPos := aScan(aVerbas,{|x| x[2]== SRC->RC_PD})
						If  nPos > 0
							
							// Se for verba de IR, soma no array de verbas de IR - buscou no SRC-Folha do Mes
							// 012 valor ir adiantamento
							// 010 base ir adiantamento (ja com o inss abatido) (ja contem o ir da folha)
							If  aVerbas[nPos,1] $ "012,010"
								aVerbas[nPos,5] += SRC->RC_VALOR
								lTemIrfAdi      := .T.
							Endif
							
						Endif
						
						SRC->(dbskip())
						
					Enddo
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Soma IR no array de verbas                                                   ³
					//³ Se teve IR no SRC-Folha do Mes, pega ele                                     ³
					//³ Se nao, pega do SRD-Acumulados Anuais                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nPos := 1 to len(aVerbas)
						If  lTemIrfAdi
							aVerbas[nPos,6] += aVerbas[nPos,5]
						Else
							aVerbas[nPos,6] += aVerbas[nPos,4]
						Endif
						aVerbas[nPos,4] := 0
						aVerbas[nPos,5] := 0
					Next
				Endif
			Endif
			SRA->(dbSkip())
		Enddo
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ Seleciona lotes referentes ao ano/mes base informados               ³
//³ - Busca informacoes para inss - verifica apenas no ano/mes          ³
//³   informado, pois o inss eh calculado com base no ano/mes da        ³
//³   prestacao do servico                                              ³
//³ - Identifica ano/mes para deducao do inss no calculo do ir          ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGraImp
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta query                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := " SELECT BMR_ANOLOT||BMR_MESLOT||BMR_NUMLOT AS BMRLOTE, BMR_CODLAN, BMR_VLRPAG, R_E_C_N_O_ AS BMR_RECNO"
	cSQL += "  FROM " + RetSQLName("BMR")
	cSQL += "  WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
	cSQL += "    AND BMR_OPERDA = '" + cOpeLote + "' "
	cSQL += "    AND BMR_CODRDA = '" + cCodRda + "' "
	cSQL += "    AND BMR_OPELOT = '" + cOpeLote + "' "
	cSQL += "    AND BMR_ANOLOT = '" + cAno    + "' "
	cSQL += "    AND BMR_MESLOT = '" + cMes    + "' "
	cSQL += "    AND D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY BMRLOTE, BMR_CODLAN, R_E_C_N_O_ "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa query                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
	TcSetField("Trb","BMR_VLRPAG","N",nVlPrec,nVlDec)
	TcSetField("Trb","BMR_RECNO","N",16,0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa arquivo de trabalho                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ! Trb->(eof())
		If TRB->BMRLOTE <> cLote
			TRB->(dbSkip())
			Loop
		EndIf
	
		Do Case
		Case TRB->BMR_CODLAN $  "183,193,195,197,168,199" .and. !lPgUni4
			Trb->(dbCloseArea())
			Return({0,0,.F.,"Impostos ja calculados"})
		Case TRB->BMR_CODLAN == "167"
			nBInsHPPls += Trb->BMR_VLRPAG  // base inss hon.patronal
		Case TRB->BMR_CODLAN == "168" .and. lPgUni4 
			nInssHP   += Trb->BMR_VLRPAG  // valor inss hon patronal			
		Case TRB->BMR_CODLAN == "170"
			nScoOutEmp := Trb->BMR_VLRPAG  // sal contrinuicao outras empresas
		Case TRB->BMR_CODLAN == "182"
			nBInsUNPls += Trb->BMR_VLRPAG  // base inss (credenciado)
		Case TRB->BMR_CODLAN == "183" .and. lPgUni4
			nInssUni   += Trb->BMR_VLRPAG  // valor inss unico
		Case TRB->BMR_CODLAN == "192"
			nBInsPfPls += Trb->BMR_VLRPAG  // base inss pf
		Case TRB->BMR_CODLAN == "193" .and. lPgUni4 
			nInssFis   += Trb->BMR_VLRPAG  // valor inss pf
		Case TRB->BMR_CODLAN == "194"
			nBInsPjPls += Trb->BMR_VLRPAG  // base inss pj
		Case TRB->BMR_CODLAN == "195" .and. lPgUni4
			nInssJur   += Trb->BMR_VLRPAG  // valor inss pj
		Case TRB->BMR_CODLAN == "196"
			nBInsJFPls += Trb->BMR_VLRPAG  // base inss pj filantropico
		Case TRB->BMR_CODLAN == "197" .and. lPgUni4 
			nInssJF   += Trb->BMR_VLRPAG  // valor inss jur filantrópico
		EndCase
		If nInssHP+nScoOutEmp+nInssUni+nInssFis+nInssJur+nInssJF > 0
			lRet := .T. // para indicar que encontrou algum titulo para calcular impostos
		EndIf
		Trb->(dbSkip())
	Enddo
	Trb->(dbCloseArea())
else
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se houve movimentacao com incidencia para impostos ou eh o ultimo   ³
//³ calculo e ja havia bases de impostos gravadas no BMR                ³
//³ aImpMes[02] = Base INSS PJ                                          ³
//³ aImpMes[04] = Base INSS PF                                          ³
//³ aImpMes[23] = Base INSS HP                                          ³
//³ aImpMes[06] = Base IRRF                                             ³
//³ aImpMes[10] = Base IRRF JF                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if  (nBIrPls + nBInsPfPls + nBInsPjPls + nBInsJFPls + nBInsHPPls + nBInsUNPls + nScoOutEmp) > 0 .or. (lUltCalc .And. aImpMes[2]+aImpMes[4]+aImpMes[6]+aImpMes[23]+aImpMes[10]+aImpMes[26] > 0)
		lRet := .T.
	endif
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ Busca informacoes dos meses seguintes ao ano/mes base, para         ³
//³ recalcular o irrf acumulado                                         ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lGraImp
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para montar array com informacoes de irrf          ³
	//³ Exemplo: no inicio da utilizacao do sistema, pode-se montar uma     ³
	//³          tabela auxiliar com os valores referentes aos meses        ³
	//³          anteriores que ja haviam sido calculados no sistema antigo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ExistBlock("PLPAGANT")
		
		aIrrf := ExecBLock("PLPAGANT",.F.,.F.,{cCodRda,cAno,cMes,aIrrf})
		
		If len(aIrrf) > 0
			nSeq++
			cHistor := "Base IR sistema antigo   Mes/Ano      Base IR    Ir Retido"
			PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor)
			
			nSeq++
			cHistor := "Base IR sistema antigo   Mes/Ano      Base IR    Ir Retido"
			cHistor := "                         -------   ----------   ----------"
			PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor)
			
			For nPos := 1 to len(aIrrf)
				nSeq++
				cHistor := space(25) + ;
							aIrrf[nPos,2] + "/" + aIrrf[nPos,1] + space(3) + ;
							transform(aIrrf[nPos,3],PLPMONEY_G) + space(3) + ;
							transform(aIrrf[nPos,4],PLPMONEY_G)
				PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor)
			Next
		Endif
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDtEmis	:= DTOS(STOD(cAno+cMes+"01")-90) //Para a query achar o indice da SE2, os 90 dias e uma margem de seguranca para casos de emissao antecipada
	cSQL := " SELECT BMR_ANOLOT, BMR_MESLOT, BMR_CODLAN, BMR_VLRPAG, "
	cSQL += "        E2_PREFIXO, E2_NUM,     E2_PARCELA, E2_FORNECE, E2_LOJA, E2_NATUREZ, E2_TIPO,    "
	cSQL += "        E2_EMISSAO, E2_VENCTO,  E2_ANOBASE, E2_MESBASE, E2_VALOR, "
	cSQL += "        SE2.R_E_C_N_O_ AS E2_RECNO, "
	cSQL += "        BMR.R_E_C_N_O_ AS BMR_RECNO  "
	cSQL += "  FROM " + RetSQLName("BMR") + " BMR, " +  RetSQLName("SE2") + " SE2 "
	cSQL += "  WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
	cSQL += "    AND BMR_CODRDA = '" + cCodRda + "' "
	cSQL += "    AND BMR.D_E_L_E_T_ = ' ' "
	cSQL += "    AND E2_FILIAL  = '" + xFilial("SE2") + "' "
	cSQL += "    AND E2_EMISSAO >= '" + cDtEmis + "' "
	cSQL += "    AND E2_PLOPELT = BMR_OPERDA "
	cSQL += "    AND E2_PLLOTE  = BMR_ANOLOT||BMR_MESLOT||BMR_NUMLOT "
	cSQL += "    AND E2_CODRDA  = BMR_CODRDA "
	cSQL += "    AND SE2.D_E_L_E_T_ = ' ' "
	cSQL += "  ORDER BY E2_VENCTO,E2_RECNO " 	//SUBSTRING(E2_VENCTO,1,6),E2_RECNO "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa query                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
	TcSetField("Trb","E2_VENCTO","D",8,0)
	TcSetField("Trb","E2_EMISSAO","D",8,0)
	TcSetField("Trb","E2_VALOR","N",nVlPrec,nVlDec)
	TcSetField("Trb","BMR_VLRPAG","N",nVlPrec,nVlDec)
	TcSetField("Trb","E2_RECNO","N",16,0)
	TcSetField("Trb","BMR_RECNO","N",16,0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa arquivo de trabalho                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ! Trb->(eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salva natureza                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  empty(cNaturez) .and. Trb->E2_FORNECE == cCodForn
			cNaturez := Trb->E2_NATUREZ
		Endif
		//³ Desconsidera tipos NDF, INSS e IR                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  Trb->E2_TIPO == MVINSS .or. Trb->E2_TIPO == MVTAXA
			Trb->(dbSkip())
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salva em array para calculo do IR                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  lGraImp // indica que eh para gravar impostos, ou seja, tem mais de um pagamento no mes
			cAnoSE2 := substr(dtos(Trb->E2_VENCTO),1,4)
			cMesSE2 := substr(dtos(Trb->E2_VENCTO),5,2)
		Else
			cAnoSE2 := substr(dtos(Trb->E2_EMISSAO),1,4)
			cMesSE2 := substr(dtos(Trb->E2_EMISSAO),5,2)
		Endif
		
		If  cAnoSE2+cMesSE2 >= Substr(dtos(dVenTit),1,6) //cAno+cMes   //mes /ano vencto do lote
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva natureza                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  empty(cNaturez) .and. Trb->E2_FORNECE == cCodForn .and. Trb->E2_LOJA == cLoja
				cNaturez := Trb->E2_NATUREZ
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula valor e base IR                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos := aScan(aRecnoIrf,Trb->BMR_RECNO)
			
			If  nPos == 0
			
				lSalvou	:= .F.
				nPos 		:= aScan(aIrrf,{|x| x[1] == cAnoSE2 .and. x[2] == cMesSE2})
				
				If  nPos == 0
					aadd(aIrrf,{cAnoSE2,cMesSE2,0,0,0})
					nPos := len(aIrrf)
				Endif
				
				Do Case
					Case TRB->BMR_CODLAN == "198"
						aIrrf[nPos,3] += Trb->BMR_VLRPAG  // base irrf
						
						If  empty(Trb->E2_PARCELA) .and. TRB->E2_ANOBASE+TRB->E2_MESBASE == cAno+cMes
							aIrrf[nPos,5] := Trb->E2_RECNO    // recno do ultimo SE2
						Endif
						
						lSalvou := .T.
					Case TRB->BMR_CODLAN == "199" .and. Alltrim(TRB->E2_PARCELA) $ StrZero(2, TamSX3("E2_PARCELA")[1]) .and. int(Trb->BMR_VLRPAG*100) == int(Trb->E2_VALOR*100)
						aIrrf[nPos,4] += Trb->BMR_VLRPAG  // valor irrf
						lSalvou := .T.
				EndCase
				
				If  lSalvou
					aadd(aRecnoIrf,Trb->BMR_RECNO)
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva em array para gerar NDF INSS proporcional a cada titulo       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos := aScan(aRecnoIns,Trb->BMR_RECNO)
			If  nPos == 0
				aadd(aRecnoIns,Trb->BMR_RECNO)
				
				If  TRB->E2_ANOBASE+TRB->E2_MESBASE == cAno+cMes
					
					If  TRB->BMR_CODLAN $ "182,192,194,196,167"
						nPos := aScan(aSE2,{|x| x[2] == Trb->E2_NUM})
						
						If  nPos == 0
							aadd(aSE2,{Trb->E2_PREFIXO,Trb->E2_NUM,Trb->E2_VENCTO,0,0})
							nPos := len(aSE2)
						Endif
						
						aSE2[nPos,4]	+= Trb->BMR_VLRPAG  // valor base inss
						nSE2        	+= Trb->BMR_VLRPAG  // valor base inss total
					Endif
				Endif
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acessa proximo registro                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Trb->(dbSkip())
	Enddo
	Trb->(dbCloseArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o % de cada SE2                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nPos := 1 to len(aSE2)
		aSE2[nPos,5] := aSE2[nPos,4] / nSE2
	Next
Else // !lGraImp 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aImpMes[6] = Base IRRF                                              ³
	//³ aImpMes[7] = IRRF                                                   ³  
	//³ aImpMes[21] = Valor descontado da parcela do IRRF (MV_PLCIRRT)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aIrrf,{StrZero(Year(dVenTit),4),StrZero(Month(dVenTit),2),nBIrPls+aImpMes[6]+aImpMes[27],aImpMes[7]+aImpMes[21],0})
endif
// Zera a base de Imposto de Renda para as RDA's que nao deverao calcular o imposto - BOPS 97434
lBAU_CALIRF := BAU->(FieldPos("BAU_CALIRF")) > 0
for nPos := 1 to len(aIrrf)
	// Nao calcula IR
	if lBAU_CALIRF .and. BAU->BAU_CALIRF == "0"
		aIrrf[nPos, 3] := 0
	endIf
next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ Calcula inss                                                        ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para montagem da base e desconto   	        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nBasInssFol := 0 // sal contribuicao inss outras empresas
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sal Contribuicao inss outras empresas                               ³
//³ Somente procura na folha se nao foi lancado no PLS                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nScoOutEmp == 0
	nPos := aScan(aVerbas,{ |x| x[1] == "288" } )
	If  nPos > 0
		nScoOutEmp := aVerbas[nPos,3]
	Endif
Endif
nBasInssFol += nScoOutEmp
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava memoria de calculo                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGraimp
	nSeq++
	cHistor := "==> RDA: " + BAU->BAU_CODIGO + " " + BAU->BAU_NOME
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
	nSeq++
	cHistor := "Bases INSS   Pessoa Juridica.: " + transform(nBInsPjPls,PLPMONEY_G) + "   Sal Contrib Out Emp: " + transform(nScoOutEmp,PLPMONEY_G)
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
	nSeq++
	cHistor := "             Pessoa Fisica...: " + transform(nBInsPfPls,PLPMONEY_G)
	nSeq++
	cHistor := "             Jur.Filantropica: " + transform(nBInsJFPls,PLPMONEY_G)
	nSeq++
	cHistor := "             Hon.Patronal....: " + transform(nBInsHPPls,PLPMONEY_G)
	nSeq++
	cHistor := "             Unificada.......: " + transform(nBInsUNPls,PLPMONEY_G)
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Base inss pro-labore                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos	:= aScan(aVerbas,{ |x| x[1] == "221" } ) // base inss pro-labore/autonomo
nBasInssFol += If(nPos > 0,aVerbas[nPos,3],0)
nPos	:= aScan(aVerbas,{ |x| x[1] == "013" } ) // salario contribuicao ate limite
nBasInssFol += If(nPos > 0,aVerbas[nPos,3],0)

nBaseHP := nBaseJur := nBaseFis := nBaseJF := nBaseUN := 0
nInssHP := nInssJur := nInssFis := nInssJF := nInssUN := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se eh o ultimo calculo do mes, ira considerar todas as bases existentes ³
//³ no BMR mais as bases encontradas no lote que esta sendo calculado.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUltCalc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deve-se priorizar a reducao da base de INSS HP, uma vez que ³
//³a aliquota HP eh de 11% enquanto o INSS PF/PJ/JF eh de 20%. ³
//³RC - 20151010.                                              ³
//³ Variaveis de Base:          					 	       ³
//³ aImpMes[02] = Base INSS PJ 								   ³
//³ aImpMes[04] = Base INSS PF          					   ³
//³ aImpMes[10] = Base INSS JF          					   ³
//³ aImpMes[23] = Base INSS HP          					   ³
//³ aImpMes[26] = Base INSS Unica          					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nBasInCal	:= aImpMes[2]+aImpMes[04]+aImpMes[10]+aImpMes[23]+aImpMes[26]
	
	If BAU->BAU_BASINS == '1'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula inss com base unificada 						 	        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nBaseUN := Min(nBInsUNPls + nBasInCal + nBasInssFol, nTetoInss) - ( nBasInCal + nBasInssFol	)
		nBaseUN := IIf(nBaseUN < 0, 0, nBaseUN)
		nInssUN := NoRound(nBaseUN * nPercJur,2)	
	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula inss honorário patronal 						 	        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPgtoImp // Tipo 4 - Varios pgtos com impostos
			If  nBasInCal > 0 // Ja existiu pagamento
				nBaseHP := Min(nBInsHPPls + nBasInCal, nTetoInss) - nBasInCal
			Else
				nBaseHP := Min(nBInsHPPls + nBasInssFol, nTetoInss) - nBasInssFol
			Endif
		Else
			nBaseHP := Min(nBInsHPPls + nBasInssFol + aImpMes[23], nTetoInss) - ( nBasInssFol + aImpMes[23] )
		endIf
		nBaseHP := IIf(nBaseHP < 0, 0, nBaseHP)
		nInssHP := NoRound(nBaseHP * nPercHP,2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula inss pessoa juridica       						 	        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPgtoImp // Tipo 4 - Varios pgtos com impostos
			If  nBasInCal > 0 // Ja existiu pagamento
				nBaseJur := Min(nBInsPjPls + nBaseHP + nBasInCal, nTetoInss) - ( nBasInCal + nBaseHP )
			Else
				nBaseJur := Min(nBInsPjPls + nBaseHP + nBasInssFol, nTetoInss) - ( nBasInssFol + nBaseHP )
			Endif
		Else
			nBaseJur := Min(nBInsPjPls + nBaseHP + nBasInssFol + aImpMes[2], nTetoInss) - ( nBaseHP + nBasInssFol + aImpMes[2] )
		endIf
		nBaseJur := IIf(nBasejur < 0, 0, nBaseJur)
		nInssJur := NoRound(nBaseJur * nPercJur,2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula inss pessoa fisica           					 	        ³
		//³ aImpMes[02] = Base INSS PJ          						 	    ³
		//³ aImpMes[04] = Base INSS PF            						 	    ³
		//³ aImpMes[10] = Base INSS JF             					   			³
		//³ aImpMes[23] = Base INSS HP             					   			³
		//³ aImpMes[05] = INSS PF          						 	            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPgtoImp // Tipo 4 - Varios pgtos com impostos
			If  nBasInCal > 0 // Ja existiu pagamento
				nBaseFis := Min(nBInsPfPls + nBasInCal + nBaseHP + nBaseJur, nTetoInss) - ( nBasInCal + nBaseHP + nBaseJur )
			Else
				nBaseFis := Min(nBInsPfPls + nBaseHP + nBaseJur + nBasInssFol,nTetoInss) - ( nBaseHP + nBasInssFol + nBaseJur )
			EndIf
		Else
			nBaseFis := Min(nBInsPfPls + nBaseHP + nBaseJur + nBasInssFol + aImpMes[4] , nTetoInss) - ( nBaseHP + nBasInssFol + nBaseJur + aImpMes[4])
		EndIf
		nBaseFis := IIf(nBaseFis < 0, 0, nBaseFis)
		nInssFis := NoRound(nBaseFis * nPercFis,2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula inss pessoa juridica filantropica				 	        ³
		//³ aImpMes[02] = Base INSS PJ          						 	    ³
		//³ aImpMes[04] = Base INSS PF            						 	    ³
		//³ aImpMes[10] = Base INSS JF             					   			³
		//³ aImpMes[23] = Base INSS HP             					   			³
		//³ aImpMes[05] = INSS PF          						 	            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPgtoImp // Tipo 4 - Varios pgtos com impostos
			If  nBasInCal > 0 // Ja existiu pagamento
				nBaseJF := Min(nBInsJFPls + nBaseHP + nBaseJur + nBaseFis + nBasInCal, nTetoInss) - ( nBasInCal + nBaseHP + nBaseJur + nBaseFis )
			Else
				nBaseJF := Min(nBInsJFPls + nBaseHP + nBaseJur + nBaseFis + nBasInssFol,nTetoInss) - ( nBaseHP  + nBaseJur + nBaseFis + nBasInssFol )
			EndIf
		Else
			nBaseJF := Min(nBInsJFPls + nBaseHP + nBaseJur + nBaseFis + nBasInssFol + aImpMes[10] , nTetoInss) - ( nBaseHP + nBasInssFol + nBaseJur + nBaseFis + aImpMes[10] )
		EndIf
		nBaseJF := IIf(nBaseJF < 0, 0, nBaseJF)
		nInssJF := NoRound(nBaseJF * nPercJF,2)
	
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao eh o ultimo calculo do mes, ira considerar apenas as bases encontra- ³
//³ das no lote que esta sendo calculado mais as provisoes, se houver.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deve-se priorizar a reducao da base de INSS HP, uma vez que ³
//³a aliquota HP eh de 11% enquanto o INSS PF/PJ/JF eh de 20%. ³
//³RC - 20151010.                                              ³
//³ Variaveis de Base:          					 	       
//³ aImpMes[02] = Base INSS PJ          					   
//³ aImpMes[04] = Base INSS PF          					   
//³ aImpMes[10] = Base INSS JF          					   
//³ aImpMes[23] = Base INSS HP          					   
//³ aImpMes[26] = Base INSS Unificada          					   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If BAU->BAU_BASINS == '1'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula inss base unificada     						 	        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nBaseUN := Min(nBInsUNPls + nBasInssFol + aImpMes[26], nTetoInss) - ( nBasInssFol + aImpMes[26] )
		nBaseUN := IIf(nBaseUN < 0, 0, nBaseUN)
		nInssUN := NoRound(nBaseUN * nPercJur,2)
		// Zera variáveis de INSS separados por serviço
		nBaseHP := nBaseJur := nBaseFis := nBaseJF := 0
		nInssHP := nInssJur := nInssFis := nInssJF := 0

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula inss honorário patronal 						 	        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nBaseHP := Min(nBInsHPPls + nBasInssFol + aImpMes[23], nTetoInss) - ( nBasInssFol + aImpMes[23] )
		nBaseHP := IIf(nBaseHP < 0, 0, nBaseHP)
		nInssHP := NoRound(nBaseHP * nPercHP,2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Calcula inss pessoa juridica       						   
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		nBaseJur := min(nBaseHP + nBInsPjPls + nBasInssFol + aImpMes[2], nTetoInss) - ( nBasInssFol + aImpMes[2] + nBaseHP )
		nBaseJur := IIf(nBaseJur < 0, 0, nBaseJur)
		nInssJur := NoRound(nBaseJur * nPercJur,2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Calcula inss pessoa fisica           					   
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		nBaseFis := min(nBaseHP + nBaseJur + nBInsPfPls + nBasInssFol + aImpMes[4], nTetoInss) - ( nBasInssFol + nBaseHP + nBaseJur + aImpMes[4] )
		nBaseFis := IIf(nBaseFis < 0, 0, nBaseFis)
		nInssFis := NoRound(nBaseFis * nPercFis,2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Calcula inss juridica filantropica      						   
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		nBaseJF := min(nBInsJFPls + nBaseHP + nBaseJur + nBaseFis + nBasInssFol + aImpMes[10], nTetoInss) - (nBaseHP + nBaseJur + nBaseFis + nBasInssFol + aImpMes[10])
		nBaseJF := IIf(nBaseJF < 0, 0, nBaseJF)
		nInssJF := NoRound(nBaseJF * nPercJF,2)

	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula inss total para deducao na base do ir                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos     	:= aScan(aVerbas,{ |x| x[1] == "064" } ) // valor inss
nDedFol 	:= if(nPos > 0,aVerbas[nPos,3],0)
nPos		:= aScan(aVerbas,{ |x| x[1] == "065" } ) // valor inss ferias
nDedFol  	+= if(nPos > 0,aVerbas[nPos,3],0)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta valor de Deducao do INSS na base de IRRF      	 	        ³
//³ aImpMes[03] = INSS PJ      						 	                ³
//³ aImpMes[05] = INSS PF      						 	                ³
//³ aImpMes[11] = INSS JF      						 	                ³
//³ aImpMes[22] = INSS HP      						 	                ³
//³ aImpMes[27] = INSS Base Unica      						 	                ³
//³ Se nao eh o ultimo calculo do mes considera, tambem, as provisoes   ³
//³ de INSS calculadas durante o mes:                                   ³
//³ aImpMes[08] = Prov INSS PJ     						 	            ³
//³ aImpMes[09] = Prov INSS PF     						 	            ³
//³ aImpMes[12] = Prov INSS JF    						 	            ³
//³ aImpMes[24] = Prov INSS HP    						 	            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDedInss := nDedFol + nInssJur + nInssFis + nInssJF + nInssHP + nInssUN //+ IIf(lUltCalc, 0, aImpMes[3] + aImpMes[5] + aImpMes[11] + aImpMes[22] + aImpMes[27] + aImpMes[8] + aImpMes[9] + aImpMes[12] + aImpMes[24] )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Tratamento para reduzir a base do imposto sobre o INSS, se configurado para isso. RC - 20100516
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if nDedInss > 0 .and. getNewPar("MV_INSIRF","") == "1" //aImpMes[27]
	nPos := ascan(aCompPag,{|x| x[3]== "198"})  // Base IR
	if nPos > 0
		aCompPag[nPos,2] := iif(aCompPag[nPos,2]-nDedInss > 0, aCompPag[nPos,2]-nDedInss, 0 )
	endIf
endIf

nPos := Ascan(aCompPag,{|x| x[3]== "167"})
If nPos > 0 .And. aCompPag[nPos,2] <> nBaseHP  // Base INSS HP
	aCompPag[nPos,2] := nBaseHP
EndIf

nPos := Ascan(aCompPag,{|x| x[3]== "182"})
if nPos > 0 .And. aCompPag[nPos,2] <> nBaseUN .And. nBaseUN > 0  // Base INSS Unica
	aCompPag[nPos,2] := nBaseUN
endif

nPos := Ascan(aCompPag,{|x| x[3]== "192"})
if nPos > 0 .And. aCompPag[nPos,2] <> nBaseFis  // Base INSS PF
	aCompPag[nPos,2] := nBaseFis
endif

nPos := Ascan(aCompPag,{|x| x[3]== "194"})
if nPos > 0 .And. aCompPag[nPos,2] <> nBaseJur  // Base INSS PJ
	aCompPag[nPos,2] := nBaseJur
endIf

nPos := Ascan(aCompPag,{|x| x[3]== "196"})
If nPos > 0 .And. aCompPag[nPos,2] <> nBaseJF  // Base INSS JF
	aCompPag[nPos,2] := nBaseJF
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava memoria de calculo                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lGraImp
	nSeq++
	cHistor := "Calculo Inss   Base Inss Folha/Outras Fontes: " + transform(nBasInssFol,PLPMONEY_G)
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
	nSeq++
	cHistor := "               Base Inss PJ...: " + transform(nBaseJur   ,PLPMONEY_G) + "   Inss PJ.....: " + transform(nInssJur,PLPMONEY_M) + space(3) + str(nPercJur * 100,2) + "%"
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
	nSeq++
	cHistor := "               Base Inss PF: " + transform(nBaseFis   ,PLPMONEY_G) + "   Inss PF/JF..: " + transform(nInssFis,PLPMONEY_M) + space(3) + str(nPercFis * 100,2) + "%"
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
	nSeq++
	cHistor := "               Base Inss JF: " + transform(nBaseJF   ,PLPMONEY_G) + "   Inss PF/JF..: " + transform(nInssJF,PLPMONEY_M) + space(3) + str(nPercFis * 100,2) + "%"
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
	nSeq++
	cHistor := "               Base Inss HP: " + transform(nBaseHP   ,PLPMONEY_G) + "   Inss PF/JF..: " + transform(nInssHP,PLPMONEY_M) + space(3) + str(nPercFis * 100,2) + "%"
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
	nSeq++
	cHistor := "               Vlr Inss Folha.: " + transform(nDedFol    ,PLPMONEY_M) + "   Deducao Inss: " + transform(nDedInss,PLPMONEY_M)
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula data de vencimento do titulo de INSS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dVencRea := F050VIMP("INSS",dDataBase,dDataBase,dDataBase)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ Verifica se deve gravar titulos referentes ao INSS                  ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cParcela	:= space(TamSx3("E2_PARCELA")[1])
cTipoTit	:= PADR(cTipoTit, TamSx3("E2_TIPO")[1])
nVlrSE2 	:= nInssFis + nInssJur + nInssJF + nInssHP + nInssUN + nInssUni

If lGraImp .and. nVlrSE2 > 0 .and. (lPgUni4 .or. lUltCalc) .and. nVlrSE2  >= GetMv("MV_VLRETIN") 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Grava titulo referente ao INSS                                      
//³                                                                     
//³Monta vetor com campos a serem gravados no SE2                      
//³Se estiver configurado para multiplos pagamentos com retenção direta de impostos   
//³o sistema irá verificar se houve retenção do INSS e gerar um título a pagar somente
//³do imposto. 																					
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	SE2->(dbSetOrder(1))
	SE2->(dbSeek(xFilial("SE2")+cPrefixo+cNumero+cParcela+cTipoTit+cCodForn+cLoja,.F.))

	nRecTiOr 	:= SE2->(Recno())
	cParcela	:= strzero(1,TamSx3("E2_PARCELA")[1])
	cTitPai	:= cPrefixo+cNumero+space(tamSx3("E2_PARCELA")[1])+cTipoTit+cCodForn+cLoja
 
	aCampos :={	{"E2_FILIAL"    	,xFilial("SE2")  	,nil},;
		{"E2_PREFIXO"   	,cPrefixo 		,Nil},;
		{"E2_NUM"	    	,cNumero 		,Nil},;
		{"E2_PARCELA"   	,cParcela		,Nil},;
		{"E2_TIPO"	    	,MVINSS         ,Nil},;
		{"E2_LOJA"	    	,cLojaLan       ,Nil},;
		{"E2_FORNECE"   	,cCodFInss		,Nil},;
		{"E2_NOMFOR"    	,posicione("SA2",1,xFilial("SA2")+cCodFInss,"A2_NREDUZ"),Nil},;
		{"E2_RATEIO"    	,'N'			,NIL},;
		{"E2_OCORREN"   	,'01'			,NIL},;
		{"E2_EMISSAO"   	,dDataBase      ,NIL},;
		{"E2_EMIS1"     	,dDataBase      ,NIL},;
		{"E2_VENCTO"    	,dVencRea       ,NIL},;
		{"E2_VENCREA"   	,dVencRea       ,NIL},;
		{"E2_VENCORI"   	,dVencRea       ,NIL},;
		{"E2_MOEDA"     	,01            	,NIL},;
		{"E2_PLLOTE"    	,cLote         	,NIL},;
		{"E2_PLOPELT"   	,cOpeLote       ,NIL},;
		{"E2_CODRDA"    	,cCodRda        ,NIL},;
		{"E2_ANOBASE"   	,cAno          	,NIL},;
		{"E2_MESBASE"   	,cMes           ,NIL},;
		{"E2_DESDOBR"   	,"N"           	,NIL},;
		{"E2_FLUXO"			,"S"           	,NIL},;
		{"E2_MULTNAT"		,"2"            ,NIL},;
		{"E2_PROJPMS"		,"2"            ,NIL},;
		{"E2_MODSPB"    	,"1"            ,NIL},;
		{"E2_FILORIG"   	,cFilAnt		,NIL},;
		{"E2_MDRTISS"   	,"1"            ,NIL},;
		{"E2_FRETISS"   	,"1"            ,NIL},;
		{"E2_APLVLMN"   	,"1"            ,NIL},;
		{"E2_DATAAGE"   	,dVencRea		,NIL},;
		{"E2_TITPAI"    	,cTitPai		,NIL},;
		{"E2_FORORI"		,cCodForn		,NIL},;
		{"E2_DIRF"      	,"1"            ,NIL},;
		{"E2_HIST"      	,"INSS RETIDO DO PRESTADOR" ,NIL},;
		{"E2_LOJORI" 		,cLoja			,NIL},;
		{"E2_ORIGEM"    	,"PLSMPAG"      ,NIL},;
		{"E2_VALOR"	   		,nVlrSE2		,Nil},;
		{"E2_SALDO"			,nVlrSE2		,Nil},;
		{"E2_VLCRUZ"	   	,nVlrSE2		,Nil},;
		{"E2_NATUREZ"   	,cNatuInss		,Nil},;
		{"E2_LA"       		," "           	,NIL},;
		{"E2_INSS"      	,0              ,NIL},;
		{"E2_ISS"       	,0              ,NIL},;
		{"E2_CSLL"      	,0             	,NIL},;
		{"E2_COFINS"    	,0             	,NIL},;
		{"E2_PIS"       	,0             	,NIL},;
		{"E2_IRRF"      	,0             	,NIL}}
				
	If  SE2->(FieldPos("E2_SEST")) > 0
		aadd(aCampos,{"E2_SEST" ,0 ,NIL})
	Endif

	If  BAU->(FieldPos("BAU_CODRET")) > 0
		aAdd(aCampos,{"E2_CODRET", BAU->BAU_CODRET  ,Nil})
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava SE2 - Contas a Pagar                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aImpostos	:= {0,0,0,0,0,0,0} // nValorIR,nValorCOF,nValorISS,nValorCSL,nValorPIS,nValorINS,nValorSES

	If !lPgUni4
		if !PLStoSE2(aCampos,,aImpostos,.f.,cCopCre,'PLSMPAG','',lUltCalc)
			return({0,0,.F.,"Erro ao gerar titulo de INSS"})
		endIf
	else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Gera titulo de INSS						   
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		if existUnico("SE2", xFilial("SE2")+cPrefixo+cNumero+cParcela+MVINSS+cCodFInss+cLojaLan, 'Titulo de INSS já existente na tabela SE2.', .T. )

			SE2->(RecLock("SE2",.t.))
			for nPos := 1 To Len(aCampos)
				&('SE2->'+AllTrim(aCampos[nPos,1])) := aCampos[nPos,2]
			next
			SE2->(msUnlock())
		else
			return({0,0,.F.,"Titulo de INSS náo foi gravado."})
		endIf
	endIf
// Gravar E2_VRETINS
	if !empty(cTitPai)
		if SE2->(dbSeek(xFilial("SE2")+cTitPai))
			SE2->(RecLock("SE2",.f.))
			SE2->E2_VRETINS 	+= nVlrSE2 // *RC- aImpMes[27])
			SE2->E2_INSS    	+= nVlrSE2 // *RC- aImpMes[27])
			SE2->(msUnLock())
		endIf
	endIf
endIf

If lGraImp .and. nVlrSE2 > 0 .and. nVlrSE2 >= GetMv("MV_VLRETIN")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava BMR - 183 Valor INSS Base Unica                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if  nInssUN > 0
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),IIf(lUltCalc .Or. GetNewPar("MV_PLPGUNI","1") <> "3", "183", "179"),nInssUN,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava BMR - 193 Valor INSS PF                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if  nInssFis > 0
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),IIf(lUltCalc .Or. GetNewPar("MV_PLPGUNI","1") <> "3", "193", "180"),nInssFis,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava BMR - 195 Valor INSS PJ                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if  nInssJur > 0
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),IIf(lUltCalc .Or. GetNewPar("MV_PLPGUNI","1") <> "3", "195", "179"),nInssJur,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava BMR - 197 Valor INSS Filantropico                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if  nInssJF > 0
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),IIf(lUltCalc .Or. GetNewPar("MV_PLPGUNI","1") <> "3", "197", "178"),nInssJF,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava BMR - 168 Valor INSS Honorário Patronal                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if  nInssHP > 0
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),IIf(lUltCalc .Or. GetNewPar("MV_PLPGUNI","1") <> "3", "168", "166"),nInssHP,"1",cAno,cMes}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	endIf
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     ³
//³ Calcula IRRF                                                        ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica qtd de dependentes para ir                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDepIr := PLSDEPIR(cCodRda,cAno,cMes)

dbSelectArea("BMR") // apenas para ter uma area selecionada, em funcao dos arquivos de trabalho utilizados
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica valor inss da folha                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos		:= aScan(aVerbas,{ |x| x[1] == "064" } ) // valor inss
nInssFol 	:= If(nPos > 0,aVerbas[nPos,3],0)
nPos     	:= aScan(aVerbas,{ |x| x[1] == "065" } ) // valor inss ferias
nInssFol	+= If(nPos > 0,aVerbas[nPos,3],0)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica base IR da folha                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos		:= aScan(aVerbas,{ |x| x[1] == "015" } )  // base ir folha
nBirFol  	:= If(nPos > 0,aVerbas[nPos,3],0)
nPos     	:= aScan(aVerbas,{ |x| x[1] == "010" } )  // base ir adiantamento
nBirFol  	+= If(nPos > 0,aVerbas[nPos,3],0)
nBirFol  	+= nInssFol
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica valor IRRF da folha                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos     	:= aScan(aVerbas,{ |x| x[1] == "066" } )  // valor ir folha
nVirFol  	:= If(nPos > 0,aVerbas[nPos,3],0)
nPos     	:= aScan(aVerbas,{ |x| x[1] == "012" } )  // valor ir adiantamento
nVirFol  	+= If(nPos > 0,aVerbas[nPos,3],0)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava memoria de calculo                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGraImp
	nSeq++
	cHistor := "Mes/Ano   Base Ir  B Ir Fol Ir Retido  Ir Folha  Ded Inss   Base Ir Dep     Irrf"
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
	nSeq++
	cHistor := "------- --------- --------- --------- --------- --------- --------- --- --------"
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula IR  												        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
for i := 1 to len(aIrrf)
	aArea := GetArea()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValBaseIr := 0
	nValIr     := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verifica se houve titulo gerado para este mes so nao entra neste if se parametro
	//³ for 2 e aIrrf[i,5] for igual a zero, todas as outra opcoes tem que deixar passar.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	if  !( aIrrf[i,5] == 0 .and. getNewPar("MV_PLPGUNI","1") == "2" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variavies    									        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aPd			:= {}
		dVencto	:= ctod("28/" + aIrrf[i,2] + "/" + aIrrf[i,1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega aPD com verbas referentes a inss, para efetuar o desconto   ³
		//³ do inss na base do ir no 1. mes que tem valor a pagar               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if  lFirst
			lFirst := .f.
				fMatriz(aCodFol[167,1],nDedInss+aImpMes[27],0,"  ",,"V","I",0," ",dVencto,.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ atualiza base ir com deducao do inss 
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				nPos := Ascan(aCompPag,{|x| x[3]== "198"})  // Base IR
				if nPos > 0 .and. aCompPag[nPos,2] > 0 .and. aCompPag[nPos,2] <> aIrrf[i,3]
					aIrrf[i,3] := aCompPag[nPos,2]
				endif
		else
			nBirFol  := 0
			nVirFol  := 0
			nDedInss := 0
		endif
		SRA->(DbSeek(xFilial("SRA")))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui base para IR no aPD							                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
	  	If !lGraImp
		    fMatriz(aCodFol[349,1],IIf(nBIrPls<=0,0,aIrrf[i,3])+aImpMes[6]+nBirFol+nDedInss+aImpMes[27],0,"  ",,"V","I",0," ",dVencto,.T.)
		Else
			fMatriz(aCodFol[349,1],aIrrf[i,3]+nBirFol+nDedInss+aImpMes[27],0,"  ",,"V","I",0," ",dVencto,.T.)
		EndIf    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carreg a Tabela de I.R.									     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if  !cargaIr(@aTabIr,Iif(Val(aIrrf[i,2]) = 12,StrZero(val(aIrrf[i,1])+1,4,0)+"01",aIrrf[i,1]+StrZero(Val(aIrrf[i,2])+1,2,0))) // rever esta alteracao ??? Sandro
			return({0,0,.f.,"Tabela de imposto de renda nao encontrada"})
		endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula IR  - aPD                         					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fCIr(aCodfol,aTabir,,dVencto,cFilProc,cDepIr,"M")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca valores IR calculados              					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValBaseIr	:= abs(fBuscaPd(aCodFol[015,1],"V"))
		nValIr		:= noround(abs(fBuscaPd(aCodFol[066,1],"V")) - aIrrf[i,4] - nVirFol,2)
		If cDepIr > '00' .and. lGraimp
			nRedDep     := noround(abs(fBuscaPd(aCodFol[059,1],"V")))
			//Atualiza BMR       
			//BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN                                                                         
			BMR->(DbSetOrder(1))
			iF BMR->(DbSeek(xFilial("BMR")+cCodOpe+cCodRda+cOpeLote+cAno+cMes+SUBS(cLote,7,4)+"198"))
				BMR->(Reclock("BMR",.F.))
				BMR->BMR_VLRPAG -= nRedDep
				BMR->(MsUnlock())			
			Endif
			aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"1A1",nRedDep,"3",StrZero(Year(dVencto),4),StrZero(Month(dVencto),2)}
			GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
			
		Endif
		// Se gera impostos e eh a primeira vez no loop e achou gravado IR Retido Outras Fontes
		If lGraImp .and. i == 1 
			cSql	:= "SELECT SUM(BMR_VLRPAG) AS VLRIRRET "
			cSql	+= "FROM "+RetSqlName('BMR')+" BMR "
			cSql	+= "WHERE BMR_FILIAL = '" + xFilial('BMR') + "' "
			cSql	+= "AND BMR_OPERDA = '" + PlsIntPad() + "' "
			cSql	+= "AND BMR_CODRDA = '" + cCodRda + "' "
			cSql	+= "AND BMR_OPELOT = '" + cOpeLote + "' "  
			If lBMR_ANOVCT .and. lBMR_MESVCT
				cSql	+= "AND BMR_ANOVCT = '" + StrZero(Year(dVencto),4) + "' "
				cSql	+= "AND BMR_MESVCT = '" + StrZero(Month(dVencto),2) + "' "
			Else
				cSql	+= "AND BMR_ANOLOT = '" + StrZero(Year(dVencto),4) + "' "
				cSql	+= "AND BMR_MESLOT = '" + StrZero(Month(dVencto),2) + "' "
			EndIf
			cSql	+= "AND BMR.BMR_CODLAN IN ('199','169') "
			cSql	+= "AND BMR.D_E_L_E_T_ = ' ' "  
  
			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB",.F.,.T.)
			TcSetField("TRB","VLRIRRET","N",nVlPrec,nVlDec)
			If !TRB->(Eof())
				nVrIRRet	+= TRB->VLRIRRET
			EndIf
			TRB->(dbCloseArea())
		EndIf
		
		If nValIr >= nVrIRRet
			nValIr   -= nVrIRRet
			nVrIRRet := 0
		Else
			nVrIRRet -= nValIr
			nValIr   := 0
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Grava titulo de IRRF                     					 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If nValIr < GetNewPar("MV_VLRETIR",0)
			nValIr := 0
		EndIf
		nVlrSE2 := noround(nValIr,2)
		
		If  lGraImp .and. nVlrSE2 >  0 .and. aIrrf[i,5] > 0 //.and. nVlrSE2 >= GetNewPar("MV_VLRETIR",0) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava titulo referente ao IR                                        ³
			//³ Posiciona no ultimo titulo                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE2->(dbGoTo(aIrrf[i,5]))
			
			nRecTiOr 	:= aIrrf[i,5]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula data de vencimento do titulo de IR                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBAU_CODRET
				cCodRet := BAU->BAU_CODRET
			Else
				cCodRet := ""
			EndIf
			
			dVencRea 	:= F050VImp("IRRF",SE2->E2_EMISSAO,SE2->E2_EMIS1,SE2->E2_VENCREA,cCodRet,"F")
			cParcela	:= strzero(1,TamSx3("E2_PARCELA")[1])
			cTitPai	:= cPrefixo+cNumero+space(tamSx3("E2_PARCELA")[1])+cTipoTit+cCodForn+cLoja	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta vetor com campos a serem gravados no SE2                      ³
			//³ Grava inicialmente com TIPO e NATUREZA gravado no NDF do fornecedor ³
			//³ porque se utilizar TIPO e NATUREZA de INSS ira gerar 2 titulos:     ³
			//³ um com valor zero e outro com o INSS calculado                      ³
			//³ Logo abaixo da funcao PLStoSE2 atualiza o TIPO e NATUREZA           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCampos :={}
			aAdd( aCampos, {"E2_FILIAL"    	,xFilial("SE2")	,NIL} )  
			aAdd( aCampos, {"E2_PREFIXO"   	,cPrefixo       	,NIL} )
			aAdd( aCampos, {"E2_NUM"	   			,cNumero        	,NIL} )
			aAdd( aCampos, {"E2_PARCELA"	  	,cParcela			,NIL} )
			aAdd( aCampos, {"E2_TIPO"	   		,MVTAXA         	,NIL} )
			aAdd( aCampos, {"E2_FORNECE"  		,cCodFIR			,NIL} )
			aAdd( aCampos, {"E2_NOMFOR"    	,posicione("SA2",1,xFilial("SA2")+cCodFIR,"A2_NREDUZ")	,NIL} )
			aAdd( aCampos, {"E2_LOJA"	   		,cLojaLan      	,NIL} )
			aAdd( aCampos, {"E2_EMISSAO"   	,dDataBase      	,NIL} )
			aAdd( aCampos, {"E2_EMIS1"     	,dDataBase      	,NIL} )
			aAdd( aCampos, {"E2_VENCTO"    	,dVencRea       	,NIL} )
			aAdd( aCampos, {"E2_VENCREA"   	,dVencRea       	,NIL} )
			aAdd( aCampos, {"E2_VENCORI"   	,dVencRea       	,NIL} )
			aAdd( aCampos, {"E2_MOEDA"     	,01            	,NIL} )
			aAdd( aCampos, {"E2_PLLOTE"    	,cLote          	,NIL} )
			aAdd( aCampos, {"E2_PLOPELT"   	,cOpeLote       	,NIL} )
			aAdd( aCampos, {"E2_CODRDA"    	,cCodRda        	,NIL} )
			aAdd( aCampos, {"E2_ANOBASE"   	,cAno          	,NIL} )
			aAdd( aCampos, {"E2_MESBASE"   	,cMes          	,NIL} )
			aAdd( aCampos, {"E2_DESDOBR"   	,"N"           	,NIL} )
			aAdd( aCampos, {"E2_DIRF"      	,"2"           	,NIL} )
			aAdd( aCampos, {"E2_HIST"			,"IR RETIDO DO PRESTADOR" ,NIL} )
			aAdd( aCampos, {"E2_FLUXO"			,"S"           	,NIL} )
			aAdd( aCampos, {"E2_MULTNAT"		,"2"           	,NIL} )
			aAdd( aCampos, {"E2_PROJPMS"		,"2"            ,NIL} )
			aAdd( aCampos, {"E2_MODSPB"			,"1"				,NIL} )
			aAdd( aCampos, {"E2_FILORIG"   	,cFilAnt			,NIL} )
			aAdd( aCampos, {"E2_MDRTISS"   	,"1"         	,NIL} )
			aAdd( aCampos, {"E2_FRETISS"   	,"1"         	,NIL} )
			aAdd( aCampos, {"E2_APLVLMN"   	,"1"        		,NIL} )
			aAdd( aCampos, {"E2_DATAAGE"   	,dVencRea    		,NIL} )
			aAdd( aCampos, {"E2_TITPAI"    	,cTitPai			,NIL} )
			aAdd( aCampos, {"E2_FORORI"			,cCodForn			,NIL} )
			aAdd( aCampos, {"E2_LOJORI" 		,cLoja				,NIL} )
			aAdd( aCampos, {"E2_ORIGEM"    	,"PLSMPAG"   		,NIL} )
			aAdd( aCampos, {"E2_VALOR"	    	,nVlrSE2     		,Nil} )
			aAdd( aCampos, {"E2_SALDO"	    	,nVlrSE2     		,Nil} )
			aAdd( aCampos, {"E2_VLCRUZ"	    	,nVlrSE2     		,Nil} )
			aAdd( aCampos, {"E2_NATUREZ" 		,cNatuIR 			,NIL} )
			aAdd( aCampos, {"E2_LA"      		,' '        		,NIL} )
			aAdd( aCampos, {"E2_INSS"      	,0          		,NIL} )
			aAdd( aCampos, {"E2_ISS"       	,0          		,NIL} )
			aAdd( aCampos, {"E2_CSLL"      	,0          		,NIL} )
			aAdd( aCampos, {"E2_COFINS"    	,0          		,NIL} )
			aAdd( aCampos, {"E2_PIS"       	,0          		,NIL} )
			aAdd( aCampos, {"E2_IRRF"      	,0          		,NIL} )
			aAdd( aCampos, {"E2_RATEIO"    	,"N"				,NIL} )
			aAdd( aCampos, {"E2_OCORREN"   	,"01"				,NIL} )
			aAdd( aCampos, {"E2_DIRF"   		,"1"				,NIL} )
			aAdd( aCampos, {"E2_CODRET"   		,cCodRet			,NIL} )
			
			If  SE2->(FieldPos("E2_SEST")) > 0
				aadd(aCampos,{"E2_SEST" ,0 ,NIL})
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta vetor com bases de calculos dos impostos                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aImpostos := {0,0,0,0,0,0,0} // nValorIR,nValorCOF,nValorISS,nValorCSL,nValorPIS,nValorINS,nValorSES
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava SE2 - Contas a Pagar                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !lPgUni4
				if !PLStoSE2(aCampos,,aImpostos,.f.,cCopCre,'PLSMPAG',cCondPag,lUltCalc)
					return({0,0,.F.,"Erro ao gerar titulo de IR"})
				endIf		
			else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera titulo de IR  						     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if existUnico("SE2", xFilial("SE2")+cPrefixo+cNumero+cParcela+MVTAXA+cCodFIr+cLojaLan, 'Titulo de IR já existente na tabela SE2.', .T. )
					
					SE2->(RecLock("SE2",.T.))
						for nPos := 1 To Len(aCampos)
							&('SE2->'+AllTrim(aCampos[nPos,1])) := aCampos[nPos,2]
						next
					SE2->(msUnlock())
				else
					return({0,0,.F.,"Titulo de IR náo foi gravado."})
				endIf
				
			endIf
			//grava E2_VRETIRF
			if !empty(cTitPai)
            	SE2->(DbSetorder(1))
				if SE2->(dbSeek(xFilial("SE2")+cTitPai))
					SE2->(RecLock("SE2",.F.))   
						SE2->E2_VRETIRF  := nVlrSE2
						SE2->E2_IRRF     := nVlrSE2
					SE2->(msUnLock())	
				endif
		 	endif 
		
			aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"199",nVlrSE2,"1",StrZero(Year(dVencto),4),StrZero(Month(dVencto),2)}
			GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava memoria de calculo                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nSeq++
			cHistor := aIrrf[i,2] + "/" + aIrrf[i,1] + space(1) + ;
						transform(aIrrf[i,3],PLPMONEY_M) + space(1) + ;
						transform(nBirFol   ,PLPMONEY_M) + space(1) + ;
						transform(aIrrf[i,4],PLPMONEY_M) + space(1) +;
					   transform(nVirFol   ,PLPMONEY_M) + space(1) + ;
						transform(nDedInss  ,PLPMONEY_M) + space(1) + ;
						transform(nValBaseIr,PLPMONEY_M) + space(1) + ;
						cDepIr + space(1) + ;
						transform(nVlrSE2    ,PLPMONEY_M)
			PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)	
		endif
		
	endif
	RestArea(aArea)
next

if lGraimp
	nSeq++
	cHistor := ""
	PLSHISGRV(cIdeRot,cCodCha,strzero(nSeq,4),cHistor,lHist)
Endif 
// Checa se foi calculado imposto durante a execução desta função 
If  (nBIrPls + nBInsPfPls + nBInsPjPls + nBInsJFPls + nBInsHPPls + nBInsUNPls + nScoOutEmp) > 0 .or. (lUltCalc .And. aImpMes[2]+aImpMes[4]+aImpMes[6]+aImpMes[23]+aImpMes[10]+aImpMes[26] > 0)
	lRet := .T.
endif

If  !lRet //.AND. lGraImp 
	cRet 	:= "Nenhum imposto a calcular"
	nValIr := 0
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da funcao               						         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAuxRetImp := nInssFis + nInssJur + nInssJF + nInssHP + nInssUN

if ( nAuxRetImp <= GetNewPar("MV_VLRETIN",0) )
	nAuxRetImp := 0
endIf

return({nValIr , nAuxRetImp, lRet , cRet })
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ fIndSEFIP ³ Autor ³ TOTVS				  ³ Data ³ 12.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Procura SEFIP												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fIndSEFIP(cCodEmp, cConEmp, cSubCon, cMatric, cCalcImp, aSEFIP)

Local nIndSEFIP

nIndSEFIP := aScan(aSEFIP, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == cCodEmp+cConEmp+cSubCon+cMatric+cCalcImp})
If nIndSEFIP == 0
	aAdd(aSEFIP, { cCodEmp, cConEmp, cSubCon, cMatric, cCalcImp, 0, 0, 0, 0 })
	nIndSEFIP := Len(aSEFIP)
EndIf

Return nIndSEFIP

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ PLSPGTMES ³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 03.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Acumula as bases e os impostos ja gerados no mes para um    ³±±
±±³           ³ determinado RDA e retorna um array com estes valores.       ³±±
±±³           ³                                                             ³±±
±±³           ³ array[1] = Inss Outras Empresas (Cod Lancto 170)            ³±±
±±³           ³ array[2] = Base INSS PJ         (Cod Lancto 194)            ³±±
±±³           ³ array[3] = INSS PJ              (Cod Lancto 195)            ³±±
±±³           ³ array[4] = Base INSS PF         (Cod Lancto 192)            ³±±
±±³           ³ array[5] = INSS PF              (Cod Lancto 193)            ³±±
±±³           ³ array[6] = Base IRRF            (Cod Lancto 198)            ³±±
±±³           ³ array[7] = IRRF                 (Cod Lancto 199)            ³±±
±±³           ³ array[8] = Prov Inss PJ / Unico	(Cod Lancto 179)          	³±±
±±³           ³ array[9] = Prov Inss PF        	(Cod Lancto 180)            ³±±
±±³           ³ array[10] = Base Inss JF      	(Cod Lancto 196 )    		³±±
±±³           ³ array[11] = Inss JF          	(Cod Lancto 197)            ³±±
±±³           ³ array[12] = Prov Inss JF        (Cod Lancto 178)            ³±±
±±³           ³ array[21] = Red. parcela IRRF PF(Cod Lancto 169)            ³±±
±±³           ³ array[22] = Inss Hon.Patronal   (Cod Lancto 168)            ³±±
±±³           ³ array[23] = Base INSS Hon.Patronal(Cod Lancto 167)          ³±±
±±³           ³ array[24] = Prov.INSS Hon.Patronal(Cod Lancto 166)          ³±±
±±³           ³ array[26] = Base INSS Unico     (Cod Lancto 182)            ³±±
±±³           ³ array[27] = INSS Unico          (Cod Lancto 183)            ³±±
±±³           ³                                                             ³±±
±±³           ³ Desta forma, e' possivel compor corretamente as bases dos   ³±±
±±³           ³ impostos e calcular quantos pagamentos forem necessarios,   ³±±
±±³           ³ no mes, para um mesmo RDA.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSPgtMes(cCodRda, cAno, cMes, cOpeRda, aTpCalc, cAnoVct, cMesVct, cCalcImp, lUltCalc )

Local cSQL
Local nInsOutEmp	:= 0
Local nBInsPJ		:= 0
Local nInssPJ		:= 0
Local nBInsBU		:= 0
Local nInssBU		:= 0
Local nBInsPF		:= 0
Local nInssPF		:= 0
Local nBInsJF		:= 0
Local nInssJF		:= 0
Local nBInsHP		:= 0
Local nInssHP		:= 0
Local nBIrrf		:= 0
Local nIrrf			:= 0
Local nProvPJ		:= 0
Local nProvPF		:= 0
Local nProvJF		:= 0
Local nProvHP		:= 0
Local nVez			:= 0
Local nBPIS			:= 0
Local nPIS			:= 0
Local nBCof			:= 0
Local nCof			:= 0
Local nBCsll		:= 0
Local nCsll			:= 0
Local nBIss			:= 0
Local nIss			:= 0  
Local nRedParIR		:= 0
Local nVlrProd		:= 0 

//Local cChave     := ''
Default cOpeRda		:= PlsIntPad()
Default aTpCalc		:= { .T., .T., .T. }
Default cAnoVct		:= cAno
Default cMesVct		:= cMes
Default cCalcImp	:= ''
Default lUltCalc	:= .F.

BAU->(dbSetOrder(1))
BAU->(dbSeek(xFilial("BAU")+cCodRDA,.F.))
cCalcImp	:= BAU->BAU_CALIMP

// Cria repetição para processamento duplo, analisando se a condição será pela emissão (.T.) ou pelo vencimento (.F.)
// aTpCalc[1]	- IRRF / ISS
// aTpCalc[2] 	- INSS
// aTpCalc[3] - Pis/Cofins/CSLL
For nVez := 1 to 2
	
	// Se primeira vez e nao houver impostos pela emissao, ou se segunda vez e nao houver impostos pelo vencimento, pula o processo
	// Se segunda vez e nao houver os campos para processar pelo vencimento, pula o processo
	If ( nVez == 1 .and. !aTpCalc[1] .and. !aTpCalc[2] .and. !aTpCalc[3]  ) .or. ( nVez == 2 .and. aTpCalc[1] .and. aTpCalc[2] .and. aTpCalc[3] ) .or.;
		( nVez == 2 .and. ( BMR->(FieldPos('BMR_ANOVCT'))==0 .or. BMR->(FieldPos('BMR_MESVCT'))==0  ) )
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta query                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := " SELECT BMR_ANOLOT, BMR_MESLOT, BMR_CODLAN, BMR_VLRPAG, BMR.R_E_C_N_O_  BMR_RECNO  "
	cSQL += "  FROM " + RetSQLName("BMR") + " BMR "
	cSQL += "  WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
	cSQL += "    AND BMR_OPERDA = '" + cOpeRda + "' "
	cSQL += "    AND BMR_CODRDA = '" + cCodRda + "' "
	cSQL += "    AND BMR_OPELOT = '" + PlsIntPad() + "' "
	If nVez == 1
		cSQL += "    AND BMR_ANOLOT = '" + cAno + "' "
		cSQL += "    AND BMR_MESLOT = '" + cMes + "' "
	Else
		cSQL += "    AND BMR_ANOVCT = '" + cAnoVct + "' "
		cSQL += "    AND BMR_MESVCT = '" + cMesVct + "' "
	EndIf
	
	cSQL += "    AND BMR.D_E_L_E_T_ = ' ' "
	If nVez == 1
		cSQL += " ORDER BY BMR_FILIAL, BMR_OPERDA, BMR_CODRDA, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT "
	Else
		cSQL += " ORDER BY BMR_FILIAL, BMR_OPERDA, BMR_CODRDA, BMR_OPELOT, BMR_ANOVCT, BMR_MESVCT, BMR_NUMLOT "
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa query                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	TcSetField("TRB","BMR_VLRPAG","N",nVlPrec,nVlDec)
	TcSetField("TRB","BMR_RECNO","N",16,0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa arquivo de trabalho                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While ! TRB->(Eof())
		// Se primeira vez e pela emissao, ou segunda vez e pelo vencimento, ou nao existem os campos pelo vencimento, executa o calculo do IRRF
		If ( nVez==1 .and. aTpCalc[1]) .or. ( nVez == 2 .and. !aTpCalc[1] )
			Do Case
				Case TRB->BMR_CODLAN == "198" ; nBIrrf  += 			Trb->BMR_VLRPAG  // base IRRF
				Case TRB->BMR_CODLAN == "199" ; nIrrf   += 			Trb->BMR_VLRPAG  // IRRF
				Case TRB->BMR_CODLAN == "184" ; nBIss   += 			Trb->BMR_VLRPAG  // base ISS
				Case TRB->BMR_CODLAN == "185" ; nIss    += 			Trb->BMR_VLRPAG  // ISS
		      	Case TRB->BMR_CODLAN == "169" ; nRedParIR   += 		Trb->BMR_VLRPAG  // Red. Parcela IRRF	
			EndCase
		Endif
		// Se primeira vez e pela emissao, ou segunda vez e pelo vencimento, ou nao existem os campos pelo vencimento, executa o calculo do INSS
		If ( nVez == 1 .and. aTpCalc[2] ) .or. ( nVez == 2 .and. !aTpCalc[2] )
			Do Case
			Case TRB->BMR_CODLAN == "166" ; nProvHP += 		Trb->BMR_VLRPAG  // Prov INSS Hon.Patronal
			Case TRB->BMR_CODLAN == "167" ; nBInsHP += 		Trb->BMR_VLRPAG  // base inss Hon.Patronal
			Case TRB->BMR_CODLAN == "168" ; nInssHP += 		Trb->BMR_VLRPAG  // inss Hon.Patronal
				Case TRB->BMR_CODLAN == "170" ; nInsOutEmp +=	Trb->BMR_VLRPAG  // sal contribuicao outras empresas
				Case TRB->BMR_CODLAN == "178" ; nProvJF += 		Trb->BMR_VLRPAG  // Prov INSS PJ Filantropico
				Case TRB->BMR_CODLAN == "179" ; nProvPJ += 		Trb->BMR_VLRPAG  // Prov INSS PJ
				Case TRB->BMR_CODLAN == "180" ; nProvPF += 		Trb->BMR_VLRPAG  // Prov INSS PF
			Case TRB->BMR_CODLAN == "182" ; nBInsBU += 		Trb->BMR_VLRPAG  // base inss (base única)
			Case TRB->BMR_CODLAN == "183" ; nInssBU += 		Trb->BMR_VLRPAG  // inss (base única)
				Case TRB->BMR_CODLAN == "192" ; nBInsPF += 		Trb->BMR_VLRPAG  // base inss PF
				Case TRB->BMR_CODLAN == "193" ; nInssPF += 		Trb->BMR_VLRPAG  // inss PF
				Case TRB->BMR_CODLAN == "194" ; nBInsPJ += 		Trb->BMR_VLRPAG  // base inss PJ
				Case TRB->BMR_CODLAN == "195" ; nInssPJ += 		Trb->BMR_VLRPAG  // inss PJ
				Case TRB->BMR_CODLAN == "196" ; nBInsJF += 		Trb->BMR_VLRPAG  // base inss PJ filantropico
				Case TRB->BMR_CODLAN == "197" ; nInssJF += 		Trb->BMR_VLRPAG  // inss PJ filantropico
			EndCase
		EndIf
		// Se primeira vez e pela emissao, ou segunda vez e pelo vencimento, ou nao existem os campos pelo vencimento, executa o calculo do INSS
		If ( nVez == 1 .and. aTpCalc[3] ) .or. ( nVez == 2 .and.  !aTpCalc[3] )
			Do Case
				Case TRB->BMR_CODLAN == "186" ; nBPIS  += Trb->BMR_VLRPAG  // base PIS
				Case TRB->BMR_CODLAN == "187" ; nPIS   += Trb->BMR_VLRPAG  // valor PIS
				Case TRB->BMR_CODLAN == "188" ; nBCof  += Trb->BMR_VLRPAG  // base Cofins
				Case TRB->BMR_CODLAN == "189" ; nCof   += Trb->BMR_VLRPAG  // valor Cofins
				Case TRB->BMR_CODLAN == "190" ; nBCsll += Trb->BMR_VLRPAG  // base CSLL
				Case TRB->BMR_CODLAN == "191" ; nCsll  += Trb->BMR_VLRPAG  // valor CSLL
			EndCase
		EndIf

		// Caso não seja gerado em pedido de compra fica zerado para seguir o processo normal de geração de financeiro ou folha	
		If cCalcImp == "1" .and. TRB->BMR_CODLAN == "101"  
			nVlrProd  += Trb->BMR_VLRPAG  // valor produção
		Endif	
		
		TRB->(DbSkip())
	EndDo
	TRB->(DbCloseArea())
Next

lUltCalc := IIf( cCalcImp == "1", .T., lUltCalc)		// Ativo para ultimo calculo sempre que for pedido de compra

Return( { nInsOutEmp, nBInsPJ, nInssPJ, nBInsPF, nInssPF, nBIrrf, nIrrf, nProvPJ, nProvPF, nBinsJF, nInssJF, nProvJF, nBPIS, nPIS, nBCof, nCof, nBCsll, nCsll, nBIss, nISS, nRedParIR, nInssHP, nBInsHP, nProvHP, nVlrProd, nBInsBU, nInssBU } )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ PLSB15_IMP³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 10.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Calcula o INSS PF e INSS PJ para cada registro do B15 e     ³±±
±±³           ³ grava os campos correspondentes. Tem como base os valores   ³±±
±±³           ³ encontrados no BMR e vai deduzindo o valor ate zerar.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSB15_IMP(cOpeLote, cAno, cMes, cCodRDA)
Local nINSSPJG	:= 0
Local nINSSPFG	:= 0
Local nINSSFTG	:= 0
Local nINSSHPG	:= 0
Local nINSSPJC	:= 0
Local nINSSPFC	:= 0
Local nINSSFTC	:= 0
Local nINSSHPC	:= 0
Local nPercJur 	:= GetNewPar('MV_PLINSPJ', 0.20)
Local nPercFis 	:= GetNewPar('MV_PLINSPF', 0.20)
Local nPercJFi 	:= GetNewPar('MV_PLINSFT', 0.20)
Local nPercHoP 	:= GetNewPar('MV_PLINSHP', 0.11)

// Verifica se utiliza base unica de INSS
If !cCodRDA == BAU->BAU_CODIGO
	BAU->(dbSetOrder(1))
	BAU->(dbSeek(xFilial('BAU')+cCodRDA,.F.))
EndIf

// Se base única no RDA, trata tudo como percentual do pessoa jurídica
If BAU->BAU_BASINS == '1'
	nPercFis := nPercJFi := nPercHoP := nPercJur
EndIf	

BMR->(DbSetOrder(1))
BMR->(DbSeek(xFilial("BMR")+cOpeLote+cCodRDA+cOpeLote+cAno+cMes,.F.))
Do While !BMR->(Eof()) .And. ;
	BMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT) == ;
	xFilial("BMR")+cOpeLote+cCodRDA+cOpeLote+cAno+cMes
	Do Case
		Case BMR->BMR_CODLAN $ "183,195"			// 183 - Valor INSS Base Única e 195 - Valor INSS PJ
			nINSSPJG  += BMR->BMR_VLRPAG
		Case BMR->BMR_CODLAN $ "193"				// 193 - Valor INSS PJ 
			nINSSPFG  += BMR->BMR_VLRPAG
		Case BMR->BMR_CODLAN $ "197"				// 193 - Valor INSS PJ Filantrópica 
			nINSSFTG  += BMR->BMR_VLRPAG
		Case BMR->BMR_CODLAN $ "168"				// 168 - Valor INSS Honorario Patronal 
			nINSSHPG  += BMR->BMR_VLRPAG
	EndCase
	BMR->(DbSkip())
EndDo

If nINSSPJG+nINSSPFG+nINSSFTG+nINSSHPG > 0

	B15->(DbSetOrder(2))
	B15->(DbSeek(xFilial("B15")+cOpeLote+cAno+cMes+cCodRDA,.F.))
	Do While !B15->(Eof()) .And. ;
		B15->(B15_FILIAL+B15_OPERDA+B15_ANOLOT+B15_MESLOT+B15_CODRDA) == ;
		xFilial("B15")+cOpeLote+cAno+cMes+cCodRDA
	
		nINSSPJC := Round(B15->B15_BASEPJ * nPercJur, 2)  
		nINSSPFC := Round(B15->B15_BASEPF * nPercFis, 2)
		nINSSFTC := Round(B15->B15_BASEJF * nPercJFi, 2)
		nINSSHPC := Round(B15->B15_BASEHP * nPercHoP, 2)

		nINSSPJG -= nINSSPJC          
		If nINSSPJG < 0
			nINSSPJC += nINSSPJG
			nINSSPJG := 0
		EndIf

		nINSSPFG -= nINSSPFC
		If nINSSPFG < 0
			nINSSPFC += nINSSPFG
			nINSSPFG := 0
		EndIf

		nINSSFTG -= nINSSFTC
		If nINSSFTG < 0
			nINSSFTC += nINSSFTG
			nINSSFTG := 0
		EndIf

		nINSSHPG -= nINSSHPC
		If nINSSHPG < 0
			nINSSHPC += nINSSHPG
			nINSSHPG := 0
		EndIf
		If nINSSPJC+nINSSPFC+nINSSFTC+nINSSHPC > 0
			RecLock("B15", .F.)
			B15->B15_INSSPJ := nINSSPJC
			B15->B15_INSSPF := nINSSPFC
			B15->B15_INSSJF := nINSSFTC
			B15->B15_INSSHP := nINSSHPC
			B15->(MsUnlock())
		EndIf
		B15->(DbSkip())
	EndDo

Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ PlsAjSEFIP ³ Autor ³ Sandro Hoffman Lopes ³ Data ³ 28.07.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Trata valores negativos que existirem no array "aSEFIP"     ³±±
±±³           ³ para evitar diferencas no calculo do INSS na tabela B15.    ³±±
±±³           ³ BOPS 104251.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PlsAjSEFIP(aSEFIP, nLin, nCol)

Local cChave, nValor, nInd

cChave := aSEFIP[nLin, 1]+aSEFIP[nLin, 2]+aSEFIP[nLin, 3]+aSEFIP[nLin, 4]
nValor := aSEFIP[nLin, nCol] * -1

For nInd := nLin - 1 To 1 Step -1
	If aSEFIP[nInd, nCol] >= nValor
		aSEFIP[nInd, nCol] -= nValor
		Exit
	ElseIf aSEFIP[nInd, nCol] < nValor
		nValor -= aSEFIP[nInd, nCol]
		aSEFIP[nInd, nCol] := 0
	EndIf
Next nInd
aSEFIP[nLin, nCol] := 0

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ PlsBGQLanc ³ Autor ³ TOTVS				  ³ Data ³ 12.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Trata BGQ												    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PlsBGQLanc(cCodLanc,cTipSer,nOrdBAU,nRecBAU,nOrdSA2,nRecSA2,aCritica,cAno,cMes,cAtivo,nVlrLanc,cDescCri)


BBB->(DbSetOrder(1))
If ! BBB->(DbSeek(xFilial("BBB")+cCodLanc,.F.)) .Or. BBB->BBB_TIPSER == cTipSer
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	aCritica := {"E",cDescCri,0}
	Return
Endif

BGQ->(RecLock("BGQ",.T.))
BGQ->BGQ_FILIAL := xFilial("BGQ")
BGQ->BGQ_CODSEQ := GETSX8NUM("BGQ","BGQ_CODSEQ")
BGQ->BGQ_CODIGO := BAU->BAU_CODIGO
BGQ->BGQ_NOME   := BAU->BAU_NOME
BGQ->BGQ_ANO    := cAno
BGQ->BGQ_MES    := cMes
BGQ->BGQ_CODLAN := BBB->BBB_CODSER
BGQ->BGQ_VALOR  := nVlrLanc
BGQ->BGQ_TIPO   := BBB->BBB_TIPSER
BGQ->BGQ_TIPOCT := BBB->BBB_TIPOCT
BGQ->BGQ_INCIR  := BBB->BBB_INCIR
BGQ->BGQ_INCINS := BBB->BBB_INCINS
BGQ->BGQ_INCPIS := BBB->BBB_INCPIS
BGQ->BGQ_INCCOF := BBB->BBB_INCCOF
BGQ->BGQ_INCCSL := BBB->BBB_INCCSL
BGQ->BGQ_VERBA  := BBB->BBB_VERBA
BGQ->BGQ_CODOPE := PlsIntPad()
BGQ->BGQ_CONMFT := BBB->BBB_CONMFT
BGQ->BGQ_OBS    := "GERADO PELA ROTINA DE LOTE PAGAMENTO"
BGQ->BGQ_LANAUT := "1"
BGQ->BGQ_OPELAU := BAU->BAU_CODOPE
BGQ->BGQ_NUMLAU := "" //Sera gravado logo abaixo quando o titulo for gerado...
BGQ->BGQ_INTERC := "0"
If BBB->(FieldPos("BBB_INCISS")) > 0 .AND. BGQ->(FieldPos("BGQ_INCISS")) > 0
	BGQ->BGQ_INCISS := BBB->BBB_INCISS
EndIf
If BGQ->(FieldPos("BGQ_ATIVO")) > 0
	BGQ->BGQ_Ativo := cAtivo
EndIf
BGQ->(msUnLock())
ConfirmSX8()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GravaBMR   ³ Autor ³ TOTVS		      ³ Data ³ 12.08.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao generica para gravar BMR						      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
Default lBMR_ANOVCT := BMR->(FieldPos('BMR_ANOVCT')) >0
Default lBMR_MESVCT := BMR->(FieldPos('BMR_MESVCT')) >0

If Len(aBMR)>0 .and. aBMR[8] > 0
	BMR->(RecLock("BMR",.T.))
	BMR->BMR_FILIAL := xFilial("BMR")
	BMR->BMR_OPERDA := aBMR[1]
	BMR->BMR_CODRDA := aBMR[2]
	BMR->BMR_OPELOT := aBMR[3]
	BMR->BMR_ANOLOT := aBMR[4]
	BMR->BMR_MESLOT := aBMR[5]
	BMR->BMR_NUMLOT := aBMR[6]
	BMR->BMR_CODLAN := aBMR[7]
	BMR->BMR_VLRPAG := aBMR[8]
	BMR->BMR_DEBCRE := aBMR[9]
	If lBMR_ANOVCT .and. lBMR_MESVCT
		If Len(aBMR[10])>0
			BMR->BMR_ANOVCT	:= aBMR[10]
			BMR->BMR_MESVCT	:= aBMR[11]
		EndIf
	EndIf
	
	//--Ponto de entrada para gravar campos de usuário na BMR
	If ExistBlock("PLGRBMR")
	   ExecBlock("PLGRBMR",.F.,.F.,{aBMR})
	Endif
					
	BMR->(msUnLock())
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlsNewRecG  ³ Autor ³ TOTVS		      ³ Data ³ 12.08.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao generica para gravar BMR						      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsNewRecG(cAlias, cChaveCab,cChaveBCI,cTipRec,cTipo,cLote,cOpeLote)

LOCAL lRet := .T.
LOCAL aAreaBCI 	:= BCI->(GetArea())
LOCAL aAreaBD5 	:= BD5->(GetArea())
LOCAL aAreaBD6 	:= BD6->(GetArea())
LOCAL aAreaBE4 	:= BE4->(GetArea())
LOCAL cCodOpe		:= ""
LOCAL cAnoAut		:= ""
LOCAL cMesAut		:= ""
LOCAL cNumAut		:= ""
LOCAL lBCI_CODGLO := BCI->(FieldPos("BCI_CODGLO")) > 0
Local aGlosa		:= {"", "", ""}

DEFAULT cAlias		:= ""
DEFAULT cChaveCab 	:= ""
DEFAULT cChaveBCI		:= ""
DEFAULT cTipRec		:= ""
DEFAULT cTipo			:= ""
DEFAULT cLote			:= ""
DEFAULT cOpeLote		:= ""


BCI->(DbSetOrder(1)) //BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC
BD5->(DbSetOrder(1)) //BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_SITUAC+BD5_FASE+dtos(BD5_DATPRO)+BD5_OPERDA+BD5_CODRDA
B4D->(DbSetOrder(5)) //B4D_FILIAL+B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT
B4E->(DbSetOrder(1)) //B4E_FILIAL+B4E_OPEMOV+B4E_ANOAUT+B4E_MESAUT+B4E_NUMAUT+B4E_SEQUEN
BE4->(DbSetOrder(13)) //BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_SITUAC+BE4_FASE
If BCI->(MsSeek(xFilial("BCI")+cChaveBCI))
	
	//Verifica se o Recurso já existe.
	If cAlias == "BCI"
		B4D->(DbSetOrder(5))
		cCodOpe	:= BCI->BCI_CODOPE
		cAnoAut	:= BCI->BCI_ANO
		cMesAut	:= BCI->BCI_MES
		cChaveB4D 	:= BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)
	ElseIf cAlias == "BD5"
		cCodOpe	:= IIf(Empty(BD5->BD5_OPEMOV),BD5->BD5_CODOPE,BD5->BD5_OPEMOV)
		cAnoAut	:= BD5->BD5_ANOAUT
		cMesAut	:= BD5->BD5_MESAUT
		cNumAut	:= BD5->BD5_NUMERO
		cChaveB4D 	:= BD5->(cCodOpe+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO)//cCodOpe+cAnoAut+cMesAut+cNumAut
	ElseIf cAlias == "BD6"
		cCodOpe	:= BD6->(BD6_CODOPE)
		cAnoAut	:= BD6->(BD6_ANOPAG)
		cMesAut	:= BD6->(BD6_MESPAG)
		cNumAut	:= BD6->(BD6_NUMERO)
		cChaveB4D 	:= BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)//cCodOpe+cAnoAut+cMesAut+cNumAut
	ElseIf cAlias == "BE4"
		cCodOpe	:= BE4->(BE4_CODOPE)
		cAnoAut	:= BE4->(BE4_ANOINT)
		cMesAut	:= BE4->(BE4_MESINT)
		cNumAut	:= BE4->(BE4_NUMINT)
		cChaveB4D 	:= BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)//cCodOpe+cAnoAut+cMesAut+cNumAut
	EndIf
	lInclui := !B4D->(MsSeek(xFilial("B4D")+cChaveB4D))
	//Evita ficar alterando a B4D sem necessidade quando a glosa for de itens.
	If cTipo == "1" .AND. lInclui/*cTipRec != "I" .OR. (cTipRec != "I" .AND. lInclui)*/
		B4D->(RecLock("B4D",lInclui))
		
		B4D->B4D_FILIAL := xFilial("B4D")
		
		//Dados da Guia de origem
		B4D->B4D_OPEMOV := cCodOpe
		B4D->B4D_CODLDP := &(cAlias+"->"+cAlias+"_CODLDP")
		B4D->B4D_CODPEG := &(cAlias+"->"+cAlias+"_CODPEG")
		B4D->B4D_ORIMOV := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_ORIMOV"))
		B4D->B4D_ANOAUT := cAnoAut 
		B4D->B4D_MESAUT := cMesAut
		If &(cAlias+"->(FieldPos('"+cAlias+"_NUMIMP'))") > 0
			B4D->B4D_GUIPRE := &(cAlias+"->"+cAlias+"_NUMIMP")
		Endif
		If &(cAlias+"->(FieldPos('"+cAlias+"_SENHA'))") > 0 .or. &(cAlias+"->(FieldPos('"+cAlias+"_SENEVO'))") > 0 
			B4D->B4D_SENHA := If(cAlias == 'BD6',&(cAlias+"->"+cAlias+"_SENEVO"),&(cAlias+"->"+cAlias+"_SENHA"))
			If Empty(B4D->B4D_SENHA) .and. cAlias == 'BD6'  
				BD5->(DbSetORder(1))
				BE4->(DbSetORder(1))          
				nRecBD5 := BD5->(Recno())
				nRecBE4 := BE4->(Recno())
				nOrdBD5 := BD5->(Indexord())
				nOrdBE4 := BD5->(Indexord())
				If BD5->(MsSeek(xFilial('BD5')+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))) 
					B4D->B4D_SENHA := BD5->BD5_SENHA
				Endif
				If BE4->(MsSeek(xFilial('BE4')+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))) 
					B4D->B4D_SENHA := BE4->BE4_SENHA
				Endif  
				BD5->(DbSetORder(nOrdBD5))  
				BE4->(DbSetORder(nOrdBE4))
				BD5->(DbGoTo(nRecBD5))  
				BE4->(DbGoTo(nRecBE4))  
			Endif
		Endif             
		
		B4D->B4D_ATROPE:= IIf(cAlias=="BCI","", &(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO") )	
		
		B4D->B4D_NUMAUT := IIf(cAlias=="BCI","",cNumAut)
		B4D->B4D_GUIREF := IIf(cTipRec == "P","",B4D->(B4D_ANOAUT+B4D_MESAUT+B4D_NUMAUT))
		B4D->B4D_CODRDA := &(cAlias+"->"+cAlias+"_CODRDA")
		B4D->B4D_NOMCON := &(cAlias+"->"+cAlias+"_NOMRDA")
		B4D->B4D_TIPGUI := &(cAlias+"->"+cAlias+"_TIPGUI")
		//Dados do Beneficiário
		B4D->B4D_OPEUSR := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_OPEUSR"))
		B4D->B4D_CODEMP := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_CODEMP"))
		B4D->B4D_CONEMP := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_CONEMP"))
		B4D->B4D_SUBCON := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_SUBCON"))
		B4D->B4D_VERCON := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_VERCON"))
		B4D->B4D_VERSUB := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_VERSUB"))
		B4D->B4D_MATRIC := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_MATRIC"))
		B4D->B4D_TIPREG := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_TIPREG"))
		B4D->B4D_DIGITO := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_DIGITO"))
		B4D->B4D_USUARI := B4D->(B4D_OPEUSR+B4D_CODEMP+B4D_MATRIC+B4D_TIPREG+B4D_DIGITO)
		B4D->B4D_NOMUSR := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_NOMUSR"))
		//Dados da Operadora
		B4D->B4D_REGANS := Posicione("BA0",1,xFilial("BA0")+&(cAlias+"->"+cAlias+"_CODOPE"),"BA0_SUSEP")
		B4D->B4D_NOMOPE := Posicione("BA0",1,xFilial("BA0")+&(cAlias+"->"+cAlias+"_CODOPE"),"BA0_NOMINT")
		//Dados do recurso de glosa
		B4D->B4D_SEQB4D := GETSX8NUM("B4D","B4D_SEQB4D")
		B4D->B4D_STATUS := "0"
		B4D->B4D_NGLOPE := cAnoAut+cMesAut+PLNUMAUT(B4D->B4D_OPEMOV,B4D->B4D_ANOAUT,B4D->B4D_MESAUT)//PlNewNAut("B4D",B4D->B4D_OPEMOV,B4D->B4D_ANOAUT,B4D->B4D_MESAUT,K_INCLUIR)
		B4D->B4D_OBJREC := IIf(cTipRec == "P","1","2")
		B4D->B4D_NUMLOT := IIf(cAlias=="BCI","",&(cAlias+"->"+cAlias+"_NUMLOT"))
		
		//Grava a Glosa
		cCodGlo := IIf(cAlias=="BD5" .OR. !lBCI_CODGLO,&(cAlias+"->"+cAlias+"_CODGLO"),BCI->BCI_CODGLO)
		
		If cAlias != "BCI"
			aGlosa := Pls498DesG(cCodGlo,cCodOpe,&(cAlias+"->"+cAlias+"_CODLDP"),&(cAlias+"->"+cAlias+"_CODPEG"),&(cAlias+"->"+cAlias+"_NUMERO"),&(cAlias+"->"+cAlias+"_ORIMOV"))//array de returno {cCodGlo, cDesGlo, cCdTerm}
		EndIf
	
		B4D->B4D_GLOPLS := aGlosa[1]
		B4D->B4D_DESGLO := aGlosa[2]
				
		If cAlias=="BD5"
			B4D->B4D_GLOPRT := "" 
			B4D->B4D_GLOGUI := aGlosa[3]
		Else
			B4D->B4D_GLOPRT := aGlosa[3]
			B4D->B4D_GLOGUI := ""
		EndIf
						
		B4D->B4D_DATSOL := dDataBase
		B4D->B4D_VLRGLO := IIf(cAlias=="BD6",,&(cAlias+"->"+cAlias+"_VLRGLO"))
		B4D->B4D_QTDIRP := 0
		B4D->B4D_OPELOT := cOpeLote
		B4D->B4D_NUMLOT := cLote
		
		B4D->(MsUnlock())
		ConfirmSX8()
	ElseIf cTipo == "0"
		If !lInclui
			B4D->(RecLock("B4D",.F.))
				B4D->(DbDelete())
			B4D->(MsUnlock())
		EndIf
	EndIf
	
	//Itens do recurso
	If cTipRec == "I"
		
		lInclui := !B4E->(MsSeek(xFilial("B4E")+BD6->(BD6_CODOPE+BD6_ANOPAG+BD6_MESPAG+BD6_NUMERO+BD6_SEQUEN)) )
		If cTipo == "0"
			If !lInclui
				B4E->(RecLock("B4E",.F.))
					B4E->(DbDelete())
				B4E->(MsUnlock())
			EndIf
		Else
			B4E->(RecLock("B4E",lInclui))
			
			B4E->B4E_FILIAL := xFilial("B4E")
			B4E->B4E_OPEMOV := BD6->BD6_CODOPE
			B4E->B4E_ANOAUT := BD6->BD6_ANOPAG
			B4E->B4E_MESAUT := BD6->BD6_MESPAG
			
			B4E->B4E_CODLDP := BD6->BD6_CODLDP
			B4E->B4E_CODPEG := BD6->BD6_CODPEG
			B4E->B4E_ORIMOV := BD6->BD6_ORIMOV
			
			B4E->B4E_NUMAUT := BD6->BD6_NUMERO
			B4E->B4E_SEQUEN := BD6->BD6_SEQUEN
			B4E->B4E_SEQB4D := B4D->B4D_SEQB4D
			B4E->B4E_DATPRO := BD6->BD6_DATPRO
			B4E->B4E_CODPAD := BD6->BD6_CODPAD
			B4E->B4E_CODPRO := BD6->BD6_CODPRO
			B4E->B4E_DESPRO := BD6->BD6_DESPRO
			B4E->B4E_GRAUPA := ""//BD6->(BD6_GRAUPA)
			aGlosa := Pls498DesG("",BD6->BD6_CODOPE,BD6->BD6_CODLDP,BD6->BD6_CODPEG,BD6->BD6_NUMERO,BD6->BD6_ORIMOV,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN)
			B4E->B4E_CODGLO := aGlosa[1]
			B4E->B4E_DESGLO := aGlosa[2]
			B4E->B4E_GLOTIS := aGlosa[3]
			B4E->B4E_VLRGLO := BD6->(BD6_VLRGLO)
			B4E->B4E_SLDREC := BD6->(BD6_VLRGLO)
			
			B4E->B4E_STATUS := "0"
			
			B4E->B4E_TIPGUI := B4D->B4D_TIPGUI
			
			B4E->(MsUnlock())
			
			B4D->(RecLock("B4D",.F.))
			
			B4D->B4D_VLRGLO += B4E->B4E_VLRGLO
			
			B4D->(MsUnlock())
		EndIf
	EndIf
	
EndIf

BCI->(RestArea(aAreaBCI))
BD5->(RestArea(aAreaBD5))
BD6->(RestArea(aAreaBD6))
BE4->(RestArea(aAreaBE4))

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlsNewRecG  ³ Autor ³ TOTVS		      ³ Data ³ 12.08.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao generica para gravar BMR						      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pls498DesG(cCodGlo,cCodOpe,cCodLdp,cCodPeg,cNumero,cOriMov,cCodPad,cCodPro,cSequen)

LOCAL cDesGlo		:= ""
LOCAL cDesTmp		:= ""
LOCAL aAreaBDX	:= GetArea("BDX")
LOCAL aAreaBCT	:= GetArea("BCT")
LOCAL nTotGlo		:= 0
LOCAL cCdTerm		:= ""

DEFAULT cCodGlo	:= ""
DEFAULT cCodOpe 	:= ""
DEFAULT cCodLdp 	:= ""
DEFAULT cCodPeg 	:= ""
DEFAULT cNumero 	:= ""
DEFAULT cOriMov 	:= ""
DEFAULT cCodPad 	:= ""
DEFAULT cCodPro 	:= ""
DEFAULT cSequen 	:= ""

If !Empty(cCodGlo)

	BCT->(DbSetOrder(1))//BCT_FILIAL+BCT_CODOPE+BCT_PROPRI+BCT_CODGLO
	If BCT->(MsSeek(xFilial("BCT")+cCodOpe+cCodGlo))
		cDesGlo := BCT->BCT_DESCRI
        cCdTerm := PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  cCodGlo )
       If Empty(cCdTerm)
       	cCdTerm := BCT->BCT_GLTISS
       Endif	
	EndIf
ElseIf !Empty(cCodLdp+cCodPeg+cNumero+cOriMov+cCodPad+cCodPro+cSequen)

	BDX->(DbSetOrder(1))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO
	If BDX->(MsSeek(xFilial("BDX")+cCodOpe+cCodLdp+cCodPeg+cNumero+cOriMov+cCodPad+cCodPro+cSequen))
		cCodGlo := BDX->BDX_CODGLO
		cDesGlo := BDX->BDX_DESGLO
		cCdTerm := PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  cCodGlo )                
		If !Empty(cCodPad+cCodPro+cSequen)
			While !BDX->(Eof()) .AND. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) ==;
										xFilial("BDX")+cCodOpe+cCodLdp+cCodPeg+cNumero+cOriMov+cCodPad+cCodPro+cSequen
					nTotGlo++
					cDesTmp += AllTrim(PadR(BDX->BDX_DESGLO,50)) + "/" 
				BDX->(DbSkip())
			EndDo
		Endif
		//Se tiver só uma glosa, mantem a descrição completa. senão concatena as que der...
		If nTotGlo > 1
			cDesGlo := cDesTmp
		EndIf
		
		If Empty(cCdTerm)
			If BCT->(MsSeek(xFilial("BCT")+cCodOpe+cCodGlo))
				cCdTerm := BCT->BCT_GLTISS
	       Endif	
		Endif
	EndIf
EndIf

RestArea(aAreaBDX)
RestArea(aAreaBCT)

Return {cCodGlo, cDesGlo, cCdTerm}
