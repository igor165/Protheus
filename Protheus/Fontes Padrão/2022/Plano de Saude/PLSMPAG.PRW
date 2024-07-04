#include "PLSMGER.CH" 
#include "PLSMLIB.CH"
#include "TOPCONN.CH"
#include "PROTHEUS.CH"

#DEFINE PLPMONEY_G "@E 999,999,999,999.99"
#DEFINE PLPMONEY_M "@E 999,999.99"	

static __lOracle 	:= nil
static __aLancPagto := {}
Static objCENFUNLGP := CENFUNLGP():New()
static lPLLIMBD7	:= existblock("PLLIMBD7")
Static lBMR_SC7ITE := BMR->(FieldPos("BMR_SC7ITE")) > 0

/*/{Protheus.doc} PLSLDCRE
Retorna o saldo de um credenciado em um determinado mes
[1]      Operacao correta .F./.T.                              
[2]    - Vetor com Composicao do Pagamento                     
[2,1]  - 2(C)redito 1(D)ebito                                  
[2,2]  - Valor                                                 
[2,3]  - Codigo do Lancamento (C 03)                           
[2,4]  - Descricao Evento                                      
[2,7]  - Imagem p/ DbTree        

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
function PLSLDCRE(	cCodRDA,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,;
                  	cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,cCodForn,cLoja,aLancPagto,;
                  	cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,cCodDC,lCalcImp,;
                  	cCodNat,lGuiCob,lPgtDiv,lGerLot,lMudUs,nNewUs,nApUsDif,;
					lAtuGui,cOpeLote,cLote,dVencto,cExcPeg,cTipTitInt,nPosTitInt,cNoExcPeg,lAneste)

LOCAL nFor			:= 0	
LOCAL nVlrB_IR  	:= 0
LOCAL nVlrB_INPF	:= 0
LOCAL nVlrB_INPJ	:= 0
LOCAL nVlrB_INJF	:= 0
LOCAL nVlrB_INHP	:= 0
LOCAL nVlrB_PIS 	:= 0
LOCAL nVlrB_COF 	:= 0
LOCAL nVlrB_CSL 	:= 0
LOCAL nVlrB_ISS 	:= 0
LOCAL _nVlrAux  	:= 0
LOCAL nSaldo    	:= 0
LOCAL nSldGlo   	:= 0
LOCAL nTotDeb   	:= 0
LOCAL nTotCre		:= 0
LOCAL nTotal    	:= 0
LOCAL nVlrBD7		:= 0
LOCAL nVlrBD7PFI	:= 0
LOCAL nVlrBD7PJI	:= 0
LOCAL nVlrBD7JFI	:= 0
LOCAL nVlrBD7PHP	:= 0
LOCAL nVlrCreDIF	:= 0
LOCAL nVlrDebDIF	:= 0
Local nIndSEFIP		:= 0
Local nInd			:= 0
Local nVrIRRet 		:= 0
LOCAL nVlrRefTde	:= 0	//Odontologico
Local nVlrBD6Ato	:= 0  
Local nX			:= 0
Local nTot      	:= 0
Local nTotC     	:= 0
Local nTotD     	:= 0
LOCAL nVlrDescNf	:= 0
Local n				:= 0
LOCAL nVlrGlo  		:= 0   
LOCAL nVlrTx   		:= 0
LOCAL nVlrSer  		:= 0
LOCAL cRecBCI		:= 0
LOCAL nOrdBAU   	:= BAU->(IndexOrd())

Local cCodEmpAnt	:= ''
Local cMatricAnt	:= ''
LOCAL cSQL			:= ''
LOCAL cCodPlaAnt	:= ''
LOCAL cCCAnt		:= ''
LOCAL cTipUsrAnt	:= ''
LOCAL cCodLan		:= ''
LOCAL cDesLan		:= ''
LOCAL cDebCre		:= ''
LOCAL cImgTree		:= ''
LOCAL cVerba		:= ''
LOCAL cUso			:= ''
Local cOriLan		:= ''
Local nCntFor  		:= ''
Local cRefReg		:= ''
LOCAL cCdPeg		:= ''
Local cProduto		:= ''
Local cTes			:= ''
local cTbBD7		:= RetSQLName("BD7") 
local cTbBCI		:= RetSQLName("BCI")
local cTbBD6		:= RetSQLName("BD6")
LOCAL cProcDe  		:= AllTrim(MV_PAR33)
LOCAL cProcAte 		:= AllTrim(MV_PAR34)

LOCAL aArea			:= getArea()
local aRecBD7		:= {}
LOCAL aPropri		:= {}
LOCAL aRetProPri	:= {}
LOCAL aRetPad   	:= {.F., {}, {}, {}, {}, {}, {}, 0, .F., .F., 0, {}, 0, 0, 0, {}, 0, {}, .F., {}, {}} 
LOCAL aRetNiv1  	:= {}
LOCAL aRetNiv2  	:= {}
LOCAL aVerbasFol	:= {}
LOCAL aResumo   	:= {0}
Local aSEFIP    	:= {}
Local aUsDif    	:= {}
Local aVrPgtDiv 	:= {}
Local aRetAux  		:= {}
Local aRecBD6  		:= {}
Local aRet1A2		:= {}
Local aCaLimp4		:= {}
Local aBaseDif 		:= {0,0,0,0}//{PF,PJ,FL,HP} - para quando for diferenciar as bases de inss e gerar mais de um titulo por lote de pagamento para o prestador
Local aStruBD7 		:= BD7->(DbStruct())

LOCAL lPFCoop		:= .f.
LOCAL lINSS192		:= .f.
LOCAL lINSS182		:= .f.
LOCAL lClaINS   	:= ( BD7->(FieldPos("BD7_CLAINS")) > 0 )
Local lCposVld		:= (BBC->(FieldPos("BBC_VLDINI")) > 0 .And. BBC->(FieldPos("BBC_VLDFIM")) > 0)
Local lTemImp  		:= .F.
Local lGeraL   		:= .F.
Local lTemMvt  		:= .F.
LOCAL lObrPto  		:= .F.
local lB7R 			:= PLSALIASEX("B7R")
LOCAL lAtuGlo		:= .F.

LOCAL lPLMPACTA		:= Existblock("PLMPACTA")        
LOCAL lPLMPALAN 	:= Existblock("PLMPALAN")
LOCAL lPLSPAG01		:= ExistBlock("PLSPAG01")

Local lBD7_VLTXPG 	:= BD7->(FieldPos("BD7_VLTXPG")) > 0
Local lBD7_VLADSE 	:= BD7->(FieldPos("BD7_VLADSE")) > 0
Local lBD7_VLRGTX 	:= BD7->(FieldPos("BD7_VLRGTX")) > 0
Local lBD7_USDIF  	:= BD7->(FieldPos("BD7_USDIF"))  > 0
Local lBD7_VLRDIF 	:= BD7->(FieldPos("BD7_VLRDIF")) > 0
Local lBD7_TPUSDF 	:= BD7->(FieldPos("BD7_TPUSDF")) > 0 
Local lBBB_INCISS 	:= BBB->(FieldPos("BBB_INCISS")) > 0
Local lBGQ_INCISS 	:= BGQ->(FieldPos("BGQ_INCISS")) > 0
Local lBCE_INCISS 	:= BCE->(FieldPos("BCE_INCISS")) > 0
Local lBGQ_ATIVO  	:= BGQ->(FieldPos("BGQ_ATIVO")) > 0
Local lBBB_TIPOCT 	:= BBB->(FieldPos("BBB_TIPOCT")) > 0
local lBCI_PROCES 	:= BCI->(fieldPos("BCI_PROCES")) > 0
local lBD7_SEQIMP 	:= BD7->(fieldPos("BD7_SEQIMP")) > 0
local lBY6_VIGINI 	:= BY6->(FieldPos("BY6_VIGINI")) > 0 
local lBY6_VIGFIN 	:= BY6->(FieldPos("BY6_VIGFIN")) > 0
local lBLR_DESPRO 	:= BLR->(FieldPos("BLR_DESPRO")) > 0

LOCAL lVlrGlo 	  	:= ( Type("nValorGlo") <> "U" .and. nValorGlo > 0)
Local lAdd165	  	:= .F.
Local aPEGzero 		:= {}
local nVerPeg		:= 0

Local lStaTiSS	  	:= getNewPar("MV_STATISS",.F.)
Local lPagRda  	  	:= getNewPar("MV_PLPGRDA","0") == "1" //Incrementa na base do imposto, guias pagas diretamente na Rda
LOCAL cMVPLSRDAG  	:= getNewPar("MV_PLSRDAG","999999")
local cMV_PLATIOD 	:= getNewPar("MV_PLATIOD","0")
local lMV_PLFTGLI 	:= getNewPar("MV_PLFTGLI",.t.)
local cMV_PLPGLND 	:= getNewPar("MV_PLPGLND","")
Local cCdIRRet 	  	:= getNewPar("MV_PLCIRRT","")
local cCod170 	  	:= getNewPar("MV_PLSCIOE","")
local cCod198 	  	:= getNewPar("MV_PLCIRRF","")

local nBD6_PREFIX 	:= tamSx3("BD6_PREFIX")[1]
local nBD6_NUMTIT 	:= tamSx3("BD6_NUMTIT")[1]
local nBD6_PARCEL 	:= tamSx3("BD6_PARCEL")[1]
local nBD6_TIPTIT 	:= tamSx3("BD6_TIPTIT")[1]
local nBD7_OPELOT 	:= tamSx3("BD7_OPELOT")[1]
local nBD7_NUMLOT 	:= tamSx3("BD7_NUMLOT")[1]
local nBCE_OPELOT 	:= tamSx3("BCE_OPELOT")[1]
local nBCE_NUMLOT 	:= tamSx3("BCE_NUMLOT")[1]
local nBY6_VIGINI 	:= tamSx3("BY6_VIGINI")[1]
local nBBC_VLDFIM 	:= tamSx3("BBC_VLDFIM")[1]
local nBGQ_OPELOT 	:= tamSx3("BGQ_OPELOT")[1]
local nBGQ_NUMLOT 	:= tamSx3("BGQ_NUMLOT")[1]
local nBY6_VIGFIN 	:= tamSx3("BY6_VIGFIN")[1]

DEFAULT nNeWUs     	:= 0
DEFAULT nApUsDif   	:= 2
DEFAULT nPosTitInt 	:= 1   //Indica qual titulo de intercambio esta sendo gerado. '2' corresponde ao segundo tit de intercambio e nao considera os debitos e creditos                       
DEFAULT cCalcImp   	:= BAU->BAU_CALIMP
DEFAULT cCdEmpDeS  	:= ""
DEFAULT cCdEmpAteS 	:= ""
DEFAULT cExcessao  	:= ""
DEFAULT cLoteImp   	:= ""
DEFAULT cCodDC     	:= ""
DEFAULT cCodNat    	:= ""
DEFAULT cOpeLote   	:= ""
DEFAULT cLote	   	:= ""
DEFAULT cExcPeg	   	:= ""
DEFAULT cNoExcPeg	:= "" // Variavel criada para trazer somente as PEG´s não selecionadas. para tratamento de estouro em BD #CAIO MACIENTE
DEFAULT cTipTitInt 	:= "2"  //Indica o tipo de fatura de intercambio: 1-NDC / 2-Fatura /3-Ambos
DEFAULT cLocDigIn 	:= ""
DEFAULT cLocDigFi 	:= "" 
DEFAULT cCodOpe 	:= PlsIntPad()
DEFAULT lCalcImp   	:= .F.
DEFAULT lGuiCob    	:= .F.
DEFAULT lPgtDiv    	:= .F.
DEFAULT lGerLot    	:= .F.
DEFAULT lMudUs     	:= .F.
DEFAULT lAtuGui	   	:= .F.
DEFAULT lAneste 	:= .F.
DEFAULT dVencto	   	:= StoD("")                           
DEFAULT aLancPagto  := {}

// Se for a rda generica nao traz valor...                        
If cMVPLSRDAG == cCodRDA
	Return(aRetPad)
Endif

// Se nao veio a matriz de lancamentos de faturamento ele deve ser criada
aLancPagto := PLSMONLPGT(PLSINTPAD())

// Verifica se esta posicionado o BAU...                          
If BAU->BAU_CODIGO <> cCodRDA
	BAU->(DbSetOrder(1))
	BAU->(msSeek(xFilial("BAU")+cCodRDA,.F.))
	BAU->(DbSetOrder(nOrdBAU))
Endif

If ! empty(IIf(BAU->(FieldPos("BAU_BASINS")) > 0, BAU->BAU_BASINS, ""))

	If  BAU->BAU_TIPPE == "F" .and. BAU->BAU_BASINS == "0" // 0=Nao;1=Sim ==> Tipo Pessoa Fisica e Divide a Base do INSS (Base Unificada: 0 - Nao)
		lINSS192 := .T.
	Else
		lINSS182 := .T.
	EndIf

Else
	lINSS182 := .T.
EndIf

lPFCoop := IIF(BAU->BAU_TIPPE == "F" .and. BAU->BAU_COPCRE=='1', .T., .F.)

// Trata a obrigatoriedade de gerar protocolo web ou não.         
lObrPto := PLSOBRPRDA()

BCI->(dbSetOrder(13))

// Efetua for para navegar por todos os lancamentos...            
For nFor := 1 To Len(aLancPagto)
	
	// Monta variaveis para o lancamento de pagto atual...            
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

		//Busco a TES na tabela BLS caso exita os lançamentos
		If Len(aLancPagto[nFor,9])>0 
			
			cRefReg := iIf(BAU->BAU_TIPPE == 'F',"1","2")
			
			For n := 1 to Len(aLancPagto[nFor,9])
				
				If aLancPagto[nFor,9,n,1] == '2' .AND. aLancPagto[nFor,9,n,2] == cRefReg
					cTes:= aLancPagto[nFor,9,n,10]
					Exit
				Endif
			Next n
		Endif
	EndIf	
	
	// Testa se lancamento eh valido para esse tipo de integracao (pls ou folha)³
	If ! (cUso $ "3, " .Or. cUso == cCalcImp .Or. (cUso == "1" .and. cCalcImp $ "3,4")) .And. BAU->BAU_CALIMP == '3' 
		Loop
	Endif
	
	//cada lancamento deve atualizar essa variavel com o total
	nSaldo  := 0 
	
	//Lancamento de codigo 101 --<<<<< Producao Medica                    
	//Campo na RDA (BAU_PAGPRO). Pagar Producao S/N
	if cCodLan == "101" .and. BAU->BAU_PAGPRO <> "0" 
		
		cSQL := " SELECT BD7_CODPLA, BD7_CC, BD7_TIPUSR, BD7_CODEMP, BD7_MATRIC, BD7_VLRMAN, BD7_VLRPAG, BD7_VLRGLO, BD7_REFTDE, BD7_VLTXAP,"
		cSQL += "        BD7.R_E_C_N_O_ RECBD7, BD7_ANOPAG, BD7_MESPAG "

		if lBD7_VLADSE .and. lBD7_VLTXPG .and. lBD7_VLRGTX
        	cSQL += " ,BD7_VLADSE, BD7_VLTXPG, BD7_VLRGTX "
        endIf
        
		if lClaINS
			cSQL += " ,BD7_CLAINS "
		endIf
		
		//Indica se o tratamento odontologico esta ativo no ambiente Plano de Saude.
		if cMV_PLATIOD == '1' .and. lBD7_USDIF .and. lBD7_TPUSDF .and. lBD7_VLRDIF
			cSQL += " , BD7_VLRDIF, BD7_TPUSDF "
		endIf
		
		//Tratamento para incrementar na base do imposto, guias pagas diretamente na Rda 
		if lPagRda
			cSQL += ", BD6_PAGRDA ,BD6_VRPRDA, BD6.R_E_C_N_O_ BD6REC "
		endIf
		
		if lPgtDiv
			cSQL += ", BD6_CODTAB, BD6_CODPAD, BD6_CODPRO "
		endIf
		
	  	cSQL += " FROM " + cTbBD7 + " BD7, " + cTbBCI + " BCI "
	  	
	  	// pagar somente guias ja cobradas
	  	if  lGuiCob  .or. lPgtDiv .or. lPagRda 
			cSQL += ", " + cTbBD6 + " BD6"
	  	endIf
      
      	cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
      	cSQL += "       BD7_CODOPE = '" + cCodOpe + "' AND " 
	  	cSQL += "       BD7_CODLDP BETWEEN '" + cLocDigIn + "' AND '" + cLocDigFi + "' AND "

		if lObrPto
			cSql += "  BD7_CODLDP NOT IN( '" + PLSRETLDP(4) + "', '" + PLSRETLDP(9) + "' ) AND "
		else
			cSql += "  BD7_CODLDP NOT IN( '" + PLSRETLDP(4) + "' ) AND "
		endIf
      	
		//Tratamento para trazer o saldo posicionado por processo							  
      	if lBCI_PROCES
	      	
	      	if ! empty(cProcDe/*MV_PAR33*/) .or. ! empty(cProcAte/*MV_PAR34*/)
				
				if empty(cProcDe) .or. isAlpha(cProcAte)
				
					cSQL2 := " SELECT MIN(BCI_PROCES) AS PRCMEN, MAX(BCI_PROCES) AS PRCMAI "
					cSQL2 += "   FROM " + cTbBCI
					cSQL2 += "  WHERE BCI_FILIAL = '" + xFilial("BCI") + "' "
					cSQL2 += "    AND BCI_PROCES <> '' "
					cSQL2 += "    AND D_E_L_E_T_ = '' "
					
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL2),"TrbBCI",.F.,.T.)
					
					if ! empty(TRBBCI->PRCMEN)
						
						if empty(cProcDe) 
							cProcDe := TRBBCI->PRCMEN
						endIf
						
					endIf
	
					if isAlpha(cProcAte)
						cProcAte := TRBBCI->PRCMAI
					endIf 
					
				TrbBCI->(DbCloseArea())
				endIf
								
	      		if BCI->(msSeek(xFilial("BCI")+cCodOpe+cProcDe))
	      			
	      			if ! empty(cProcDe) .and. ! empty(cProcAte)
	      			
		     			while BCI->BCI_PROCES >= cProcDe .AND. BCI->BCI_PROCES <= cProcAte 
		      				
		      				if BCI->BCI_CODRDA == cCodRDA
			      				
			      				cRecBCI	:= BCI->(recno())
			      				BCI->(dbSkip())
			      				
			      				if BCI->BCI_CODRDA == cCodRDA
				      				BCI->(dbGoTo(cRecBCI))
				      				cCdPeg += BCI->BCI_CODPEG + ", "
			      				else
				      				BCI->(dbGoTo(cRecBCI))
				      				cCdPeg += BCI->BCI_CODPEG
			      				endIf
			      				
		    				endIf
		      				
		      			BCI->(dbSkip())
		      			endDo
		      			
		      			cSQL += " BD7_CODPEG IN(" + cCdPeg + ") AND " 
		      			
	      			endIf
	      			
	      		endIf
	      		
	      	else 
      			cSQL += " BD7_CODPEG BETWEEN '" + cCodPegIn + "' AND '" + cCodPegFi + "' AND "
	      	endIf

      	else
      		cSQL += " BD7_CODPEG BETWEEN '" + cCodPegIn + "' AND '" + cCodPegFi + "' AND "
      	endIf

      	cSQL += " BD7_NUMERO BETWEEN '" + cNumMovIn + "' AND '" + cNumMovFi + "' AND "
	  
		if ! empty(cCdEmpDeS) .or. ! empty(cCdEmpAteS)
			cSQL += " BD7_CODEMP BETWEEN '" + cCdEmpDeS + "' AND '" + cCdEmpAteS + "' AND "
		endIf
		
		if ! empty(cExcessao)
			cSQL += " NOT BD7_CODEMP IN " + montaExpFil(cExcessao, 4) + " AND "
		endIf
		
		// Tratamento para verificar as PEG não selecionadas e selecionadas para o tratamento na montagem da QUERY
		// a quantidade maior sai da query entrando a menor para não dar erro na execução da query.
		if len(cNoExcPeg) > len(cExcPeg) .and. ! empty(cExcPeg)
			
			cSQL += " NOT BD7_CODPEG IN " + formatIn(cExcPeg, ",")   + " AND "

		elseIf ! empty(cNoExcPeg)

			cSQL += " NOT BD7_CODPEG NOT IN " + formatIn(cNoExcPeg, ",") + " AND "

		endIf
	
  		cSQL += " BD7_SITUAC = '1' AND "

     	// item acima foi comentado devido que quando tiramos o saldo posicionado ainda não temo o numero do lote e quando geramos o lote nos temos o numero do lote em todo o BD7 ainda ele esta gravando  EBD7_FASE = '4'  ja sao eventos faturados.
        //cSQL += " ( BD7_FASE = '3' OR (BD7_FASE = '4' AND BD7_OPELOT = '" + space( nBD7_OPELOT ) + "' AND BD7_NUMLOT = '" + space( nBD7_NUMLOT ) + "' ) ) AND "
      	cSQL += " BD7_FASE = '3' AND "
		cSQL += " BD7_BLOPAG <> '1' AND "
      
      	if ! ( empty(dDatMvIni) .and. empty(dDatMvFin) )
       		cSQL += " BD7_DATPRO BETWEEN '" + dtos(dDatMvIni) + "' AND '" + dtos(dDatMvFin) + "' AND "
      	endIf 

		cSQL += " BD7_CODRDA = '" + cCodRDA + "' AND "

  		// Otimizacao oracle para usar indices
		cSQL += " ( BD7_ANOPAG < '" + cAno + "' OR ( BD7_ANOPAG = '" + cAno + "' AND BD7_MESPAG <= '" + cMes + "' ) ) AND "

		//Funcao generica que trata campos do estorno 			
		aRetAux  := PlReChvEst("BD7", .f., .t., .f., .t.)

		cSQL += aRetAux[1]	
		cSQL += " BD7.D_E_L_E_T_ = ' ' "
		
		// pagar somente guias ja cobradas
		If  lGuiCob .or. lPgtDiv .or. lPagRda
		
			cSQL += " AND BD6_FILIAL = BD7_FILIAL "
			cSQL += " AND BD6_CODOPE = BD7_CODOPE "
			cSQL += " AND BD6_CODLDP = BD7_CODLDP "
			cSQL += " AND BD6_CODPEG = BD7_CODPEG "
			cSQL += " AND BD6_NUMERO = BD7_NUMERO "
			cSQL += " AND BD6_ORIMOV = BD7_ORIMOV "
			cSQL += " AND BD6_SEQUEN = BD7_SEQUEN "
			cSQL += " AND BD6.D_E_L_E_T_ = ' ' "
			
			if lGuiCob
				cSQL += " AND BD6_PREFIX <> '" + space( nBD6_PREFIX ) + "' "
				cSQL += " AND BD6_NUMTIT <> '" + space( nBD6_NUMTIT ) + "' "
				cSQL += " AND BD6_PARCEL <> '" + space( nBD6_PARCEL ) + "' "
				cSQL += " AND BD6_TIPTIT <> '" + space( nBD6_TIPTIT ) + "' "
			endIf
			
		endIf
		
		cSQL += " AND BCI.BCI_FILIAL = '" + xFilial("BCI") + "' "
		cSQL += " AND BCI.BCI_CODOPE = BD7.BD7_CODOPE "
		cSQL += " AND BCI.BCI_CODLDP = BD7.BD7_CODLDP "
		cSQL += " AND BCI.BCI_CODPEG = BD7.BD7_CODPEG "	
		cSql += " AND BCI.D_E_L_E_T_ = ' ' "
		
		if lStaTiSS
			cSQL += " AND BCI.BCI_STTISS IN('3','4') "
		endIf	
		
		// Somente pega as guias de um determinado lote de importacao		  	
		if lBD7_SEQIMP
			
			if ! empty(cLoteImp) .or. lMV_PLFTGLI

				cSQL += " AND BD7_SEQIMP = '" + cLoteImp + "' "

			endIf
			
		endIf
		
		//Novo Ponto de entrada de Filtro para Cliente 						
		if lPLMPACTA
			cSQL += execblock("PLMPACTA", .f., .f., {cSQL, cCodRDA})
		endIf
		
		cSQL += " ORDER BY BD7_CODPLA, BD7_CC, BD7_TIPUSR, BD7_CODEMP, BD7_MATRIC "
		
		//Acessa a BD...                                                      
		dbUseArea(.t., "TOPCONN", TCGENQRY(,, cSQL ), "TrbMPG", .f., .t.)
		
		for nCntFor := 1 to len(aStruBD7)
			
			if ( aStruBD7[nCntFor,2] <> "C" )
				TcSetField("TrbMPG",aStruBD7[nCntFor,1],aStruBD7[nCntFor,2],aStruBD7[nCntFor,3],aStruBD7[nCntFor,4])
			endIf
			
		next nCntFor
		
		//Verifica se inclui recursos de glosa
		if lVlrGlo
			lAtuGlo := .t.
		endIf
		
		//Le todo o resultado para acumular valores...                        
		while ! TrbMPG->(eof())
		
			if TrbMPG->(BD7_ANOPAG + BD7_MESPAG) > cAno + cMes
				TrbMPG->(dbSkip())
				loop
			endIf
			
			//Acumula BD7 arredondando o valor em cada registro lido              
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
			
			while ! TrbMPG->(eof()) .and. TrbMPG->BD7_CODPLA == cCodPlaAnt .and.;
					TrbMPG->BD7_CC     == cCCAnt     .and. TrbMPG->BD7_TIPUSR == cTipUsrAnt .and.;
					TrbMPG->BD7_CODEMP == cCodEmpAnt .and. TrbMPG->BD7_MATRIC == cMatricAnt
				
				//tem que ter esta validacao novamente pois a validacao do primeiro while so checa a primeira linha.
				if TrbMPG->(BD7_ANOPAG + BD7_MESPAG) > cAno + cMes
					TrbMPG->(dbSkip())
					loop
				endIf
				
				//Alteracao na logica do sistema.                               
				//Se nao obtiver a classificacao correta, optara por classificar
				//em Pessoa Fisica, onde ha maior retencao de imposto, porem    
				//nao compromete a empresa por sonegacao. RC - 20100415.        
		  		if lClaINS .and. ! empty(TrbMPG->BD7_CLAINS)    
		  		
					//Pessoa Juridica                                              
					if TrbMPG->BD7_CLAINS == "2" .or. BAU->BAU_BASINS == '1'
					    
					    if cTipTitInt == "3"
							iIf(nPosTitInt == 1, nVlrBD7PJI += round(TrbMPG->BD7_VLRMAN,2), nVlrBD7PJI += round(TrbMPG->BD7_VLTXAP,2) )
						else   
							nVlrBD7PJI += round(TrbMPG->BD7_VLRPAG, 2) 
						endIf
						
						cTipUsrAnt := "2"
						aBaseDif[2] += round(TrbMPG->BD7_VLRPAG, 2)
						
					//Pessoa Juridica Filantropica                                 
					elseIf TrbMPG->BD7_CLAINS == "3"
									
						if cTipTitInt == "3"
							iIf(nPosTitInt == 1,nVlrBD7JFI += round(TrbMPG->BD7_VLRMAN,2), nVlrBD7JFI += round(TrbMPG->BD7_VLTXAP,2) )	
						else 
							nVlrBD7JFI += round(TrbMPG->BD7_VLRPAG, 2) 
						endIf
						
						cTipUsrAnt := "3"

						aBaseDif[3] += round(TrbMPG->BD7_VLRPAG, 2)
						
					//Honorario Patronal                                
					elseIf TrbMPG->BD7_CLAINS == "4"
								
						if cTipTitInt == "3"
							Iif(nPosTitInt == 1,nVlrBD7PHP += round(TrbMPG->BD7_VLRMAN,2), nVlrBD7PHP += round(TrbMPG->BD7_VLTXAP,2) )
						else
							nVlrBD7PHP += round(TrbMPG->BD7_VLRPAG, 2)
						endIf
						
						cTipUsrAnt := "4"

						aBaseDif[4] += round(TrbMPG->BD7_VLRPAG, 2)
						
					//Pessoa Física                                                
					else
			
						if cTipTitInt == "3"  
							iIf(nPosTitInt == 1,nVlrBD7PFI += round(TrbMPG->BD7_VLRMAN,2), nVlrBD7PFI += round(TrbMPG->BD7_VLTXAP,2))	
						else
							nVlrBD7PFI += round(TrbMPG->BD7_VLRPAG, 2)
						endIf
						
						cTipUsrAnt := "1"

						aBaseDif[1] += round(TrbMPG->BD7_VLRPAG, 2)
						
					endIf
					
				else 
				
					//Pessoa Juridica                                              
					if TrbMPG->BD7_TIPUSR == "2" .or. BAU->BAU_BASINS == '1'
			
						if cTipTitInt == "3"  
							Iif(nPosTitInt == 1,nVlrBD7PJI += round(TrbMPG->BD7_VLRMAN,2), nVlrBD7PJI += round(TrbMPG->BD7_VLTXAP,2))
						else  
							nVlrBD7PJI += round(TrbMPG->BD7_VLRPAG,2)
						endIf
						
						cTipUsrAnt := "2" 

						aBaseDif[2] += round(TrbMPG->BD7_VLRPAG,2)
						
					//Pessoa Juridica Filantropica                                 
					elseIf TrbMPG->BD7_TIPUSR == "3"
					   
						if cTipTitInt == "3" 
							Iif(nPosTitInt == 1,nVlrBD7JFI += round(TrbMPG->BD7_VLRMAN,2), nVlrBD7JFI += round(TrbMPG->BD7_VLTXAP,2) )
						else  
							nVlrBD7JFI += round(TrbMPG->BD7_VLRPAG,2) 
						endIf
						 
						cTipUsrAnt := "3"

						aBaseDif[3] += round(TrbMPG->BD7_VLRPAG,2)
						
					//Honorario Patronal                                
					elseIf TrbMPG->BD7_TIPUSR == "4"
								
						if cTipTitInt == "3"
							Iif(nPosTitInt == 1,nVlrBD7PHP += round(TrbMPG->BD7_VLRMAN,2), nVlrBD7PHP += round(TrbMPG->BD7_VLTXAP,2) )
						else
							nVlrBD7PHP += round(TrbMPG->BD7_VLRPAG,2)
						endIf
						
						cTipUsrAnt := "4"

						aBaseDif[4] += round(TrbMPG->BD7_VLRPAG,2)
						
					//Pessoa Física                                                
					else
					 
						if cTipTitInt == "3"
							Iif(nPosTitInt == 1,nVlrBD7PFI += round(TrbMPG->BD7_VLRMAN,2), nVlrBD7PFI += round(TrbMPG->BD7_VLTXAP,2) )
						else
							nVlrBD7PFI += round(TrbMPG->BD7_VLRPAG,2)
						endIf
						
						cTipUsrAnt := "1"

						aBaseDif[1] += round(TrbMPG->BD7_VLRPAG,2)
						
					endIf
					
				endIf    
				
				// Soma valores, se for intercambio A500 tipo 3-Ambos, diferencia servicos e taxas 
				if cTipTitInt == "3"
					iIf(nPosTitInt == 1, nVlrBD7 += round(TrbMPG->BD7_VLRMAN, 2), nVlrSer += round(TrbMPG->BD7_VLTXAP, 2) )					
				else
					nVlrBD7 += round(TrbMPG->BD7_VLRPAG, 2) 
				endIf  
					 
				//Se for lote de intercambio 3-Ambos, separa Glosas de Servico e Taxas                
				if cTipTitInt $ "1-2" .or. ! (lBD7_VLTXPG .and. lBD7_VLADSE .and. lBD7_VLRGTX)
				
					// Se for Tipo 1-2 ou não tiver os novos campos, trata o tipo 3 como tipo 2.
					nVlrGlo += round(TrbMPG->BD7_VLRGLO, 2) + round(TrbMPG->BD7_VLRGTX, 2) 	
					nSldGlo += round(TrbMPG->BD7_VLRGLO, 2) + round(TrbMPG->BD7_VLRGTX, 2)
					
					// Mandará a variável nVlrSer para o BAF_VLRGLO
					nVlrSer += round(TrbMPG->BD7_VLRGLO, 2) + round(TrbMPG->BD7_VLRGTX, 2) 	
					
				else
				
					// Se for Tipo 3 e tem os campos
					// Titulo de Serviços	-> cTipTitInt = 3 e nPosTitInt = 1 
					if nPosTitInt == 1		
					
						// Valor da Glosa é igual a glosa menos ADSE glosada ( adicional de servico apresentado _VLADSE menos pago _VLTXPG )
						nVlrGlo += round(TrbMPG->BD7_VLRGLO, 2) 
						nSldGlo += round(TrbMPG->BD7_VLRGLO, 2)
						
						// Mandará a variável nVlrSer para o BAF_VLRGLO e nVlrTx para o BAF_VLTXGL
						nVlrSer += round(TrbMPG->BD7_VLRGLO, 2)
						nVlrTx  += round(TrbMPG->BD7_VLRGTX, 2)
						
					// Titulo de Taxas		-> cTipTitInt = 3 e nPosTitInt = 2
					// Valor de Taxas pago _VLTXPG
					else
						nVlrSer += round(TrbMPG->BD7_VLRGLO, 2)							
						nVlrTx  += round(TrbMPG->BD7_VLTXPG, 2)
					endIf	
					
				endif	

				//Acumula o valor da REFTDE pra odontologico...                       
				//Indica se o tratamento odontologico esta ativo no ambiente Plano de Saude.
				if cMV_PLATIOD == '1' 
					nVlrRefTde += round(TrbMPG->BD7_REFTDE, 2)
				endIf
				
				if lPgtDiv
					
					nInd := aScan(aVrPgtDiv, { |x| x[1]+x[2]+x[3] == TrbMPG->BD6_CODTAB + TrbMPG->BD6_CODPAD + TrbMPG->BD6_CODPRO })
					
					if nInd == 0
						aadd(aVrPgtDiv, { TrbMPG->BD6_CODTAB, TrbMPG->BD6_CODPAD, TrbMPG->BD6_CODPRO, 0, "101" })
						nInd := len(aVrPgtDiv)
					endIf
					
					aVrPgtDiv[nInd, 4] += round(TrbMPG->BD7_VLRPAG, 2)
					
				endIf
				
				//Indica se o tratamento odontologico esta ativo no ambiente Plano de Saude.
				if lBD7_USDIF .and. lBD7_VLRDIF .and. lBD7_TPUSDF .and. nApUsDif == 1 .and. cMV_PLATIOD == '1'
					
					if TrbMPG->BD7_TPUSDF == "1"

						nVlrDebdif += round(TrbMPG->BD7_VLRPAG - TrbMPG->BD7_VLRDIF,2)

					elseIf TrbMPG->BD7_TPUSDF == "2"

						nVlrCredif += round(TrbMPG->BD7_VLRDIF - TrbMPG->BD7_VLRPAG,2)

					endIf
					
				endIf
				
				// Verifica se houve co-participacao paga diretamente na Rda para 
				// incrementar a base de impostos                             
				if lPagRda
					
					if ascan(aRecBD6,{|x| x[1] == TrbMPG->BD6REC}) == 0
						
						aadd(aRecBD6,{TrbMPG->BD6REC})
						
						nVlrBD6Ato += iIf(TrbMPG->BD6_PAGRDA == "1", round(TrbMPG->BD6_VRPRDA, 2), 0)

					endIf
					
				endIf

				aadd(aRecBD7, TrbMPG->(RECBD7) )	

			TrbMPG->(dbSkip())
			endDo
			
			//Acumula o saldo desse lancamento...                                 
			nSaldo  += nVlrBD7
			
			//Para cada linha do resultado analisa se sera base dos impostos...   
			aRetProPri := AnalisaImp(cCalcImp,cTipUsrAnt,aPropri,nVlrBD7 + iIf(cTipTitInt $ "1-2" .and. !Empty(cLoteImp),nSldGlo,0),;
									 @nVlrB_IR,@nVlrB_INPF,@nVlrB_INPJ,@nVlrB_INJF,@nVlrB_PIS,@nVlrB_COF,@nVlrB_CSL,;
									 aVerbasFol,nVlrBD7PFI,nVlrBD7PJI,nVlrBD7JFI,cCodEmpAnt,cMatricAnt,@aSEFIP,;
									 @nVlrB_ISS,lPagRda,nVlrBD6Ato,@nVlrB_INHP,@nVlrBD7PHP)
									
			nInd := aScan(aRetNiv2, { |x| x[3]+x[4]+x[5] == cCodLan + cCodPlaAnt + cCCAnt })
			
			if nInd == 0
			
				aadd(aRetNiv2,{	cDebCre,;
								nVlrBD7,;
								cCodLan,;
								cCodPlaAnt,;
								cCCAnt,;
								"",;
								"BD7",;
								cProduto,;
								cTes})
								
			else
				aRetNiv2[nInd, 2] += nVlrBD7
			endIf
			
		endDo
		TrbMPG->(DbCloseArea())
		
		//Inclui no vetor Composicao de Pagamento                             
		if ! empty(cLoteImp) .And. nVlrSer + nVlrTx + nVlrGlo > 0
			lTemMvt := .T.
		endIf 
		
		if nSaldo > 0
			
			lTemMvt := .T.
			nInd 	:= aScan(aRetNiv1, { |x| x[1]+x[3]+x[4] == cDebCre + cCodLan + cDesLan })
			
			if nInd == 0
			
				aadd(aRetNiv1,{	cDebCre,;
								nSaldo,;
								cCodLan,;
								cDesLan,;
								cImgTree})
			else
				aRetNiv1[nInd, 2] += nSaldo
			endIf
		else
			BCI->(dbsetOrder(1))
			for nVerPeg := 1 to Len(aRecBD7)
				BD7->(dbgoto(aRecBD7[nVerPeg]))
				If aScan(aPEGzero, BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG)) == 0
					aadd(aPEGzero, BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG) )
					If BCI->(MsSeek(xfilial("BCI") + aPEGzero[Len(aPEGzero)]))
						PLRTGUPEG(/*lInfAdic*/ .T., /*lExibeMsg*/ .F.)
					endif
				endif
			next
			aPEGzero := {}
		endIf
		
		If BAU->BAU_CALIMP == "4" .AND. nSaldo > 0
			aadd(aCaLimp4, {getVerbaGen(, , PLSINTPAD(), "101"), nSaldo, BAU->BAU_MATFUN})
		endIf
	endIf
	
	//Lancamento de codigo 102     --<<<<< Debitos mensais fixos          
	//Para pagar uma unica vez no mes ele testa se se2 do ano/mes ja exist
	If cCodLan $ "102" .And. lBBB_TIPOCT 
		
		cSQL := "SELECT BBC_CC AS CC, BBC_CODSER AS CODSER, BBC_VALOR, BBC_QTDCH, BBC_NROPGT "
		cSQL += "  FROM "+RetSQLName("BBC")
		cSQL += " WHERE BBC_FILIAL = '" + xFilial("BBC") + "' AND "
		cSQL += "       BBC_CODIGO = '" + cCodRDA + "' AND "
		cSQL += "       BBC_PROMED = '1' AND "
		cSQL += "       BBC_STATUS = '1' AND "
		cSQL += "       BBC_DEBCRE = '1' AND "

		If lCposVld
			cSQL += " '" + cAno + cMes + "01' >= BBC_VLDINI AND "
			cSQL += " ( ( '" + dtos( lastDay( ctod( "01/" + cMes + "/" + cAno ) ) ) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
		EndIf

		cSQL += " D_E_L_E_T_ = ' ' "
		
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
			
			//Lancado em Reais
			If TrbMPG->BBC_VALOR > 0 
				
				_nVlrAux := TrbMPG->BBC_VALOR

 			//Lancado em Qtd de CH
			ElseIf TrbMPG->BBC_QTDCH > 0
				
				//Estou criando esse M->BBC_QTDCH para reaproveitar a funcao PLSA755QTD que pega o valor baseado na qtd de ch
				M->BBC_QTDCH := 0
				PLSA755Qtd(cCodOpe,TrbMPG->BBC_QTDCH,cAno,cMes,cCodRDA,"M->BBC_QTDCH")
				_nVlrAux := M->BBC_QTDCH

			Endif
			
			// Apuracao das bases dos impostos...                             
			BBB->(msSeek(xFilial("BBB")+TrbMPG->CODSER,.F.))

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

			ElseIf BBB->BBB_INCINS == "1"
				If BAU->BAU_BASINS == '1' .or. BBB->BBB_TIPOCT == "2"
					nVlrB_INPJ -= _nVlrAux
				Else
					If BBB->BBB_TIPOCT == "3"
						nVlrB_INJF -= _nVlrAux
					ElseIf BBB->BBB_TIPOCT == "1"
						nVlrB_INPF -= _nVlrAux
					Else
						nVlrB_INHP -= _nVlrAux
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
			
			If allTrim(TrbMPG->CODSER) $ cMV_PLPGLND
			
				aadd(aRet1A2,{"3",;
								_nVlrAux,;
								"1A2",;
								"",;
								TrbMPG->CC,;
								TrbMPG->CODSER,;
								"BBC",;
								cProduto,;
								cTes})
											
			EndIf
			
			//Tratamento para que quando houver creditos para a RDA
			//esses creditos viram desconto no pedido de compra e  
			//na  nota fiscal de entrada                       
			nVlrDescNf += TrbMPG->BBC_VALOR	

			If TrbMPG->CODSER $ cCdIRRet
				nVrIRRet += TrbMPG->BBC_VALOR
			EndIf
	
			If BAU->BAU_CALIMP == "4"

				If EmpTy(cVerba) .AND. TrbMPG->BBC_VALOR > 0
			
					aadd(aCaLimp4, {getVerbaGen(, , PLSINTPAD(), "102"), TrbMPG->BBC_VALOR, BAU->BAU_MATFUN})
			
				elseIf TrbMPG->BBC_VALOR > 0
			
					aadd(aCaLimp4, {cVerba, TrbMPG->BBC_VALOR, BAU->BAU_MATFUN})
			
				endIf

			endIf

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
	
	// Lancamento de codigo 103     --<<<<< Creditos         mensais fixos
	// Para pagar uma unica vez no mes ele testa se se2 do ano/mes ja exist³
	If cCodLan $ "103" .And. lBBB_TIPOCT
	
		cSQL := "SELECT BBC_CC AS CC, BBC_CODSER AS CODSER, BBC_VALOR, BBC_QTDCH, BBC_NROPGT "
		cSQL += "  FROM " + RetSQLName("BBC")
		cSQL += "  WHERE BBC_FILIAL = '" + xFilial("BBC") + "' AND "
		cSQL += "        BBC_CODIGO = '" + cCodRDA + "' AND "
		cSQL += "        BBC_PROMED = '1' AND "
		cSQL += "        BBC_STATUS = '1' AND "
		cSQL += "        BBC_DEBCRE = '2' AND "		// Créditos
		
		If lCposVld // BOPS 98697
			cSQL += " '" + cAno + cMes + "01' >= BBC_VLDINI AND "
			cSQL += " ( ( '" + DtoS(LastDay(CtoD("01/"+cMes+"/"+cAno))) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
		EndIf
		
		cSQL += " D_E_L_E_T_ = ' ' "
	
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
			
			//Lancado em Reais
			If TrbMPG->BBC_VALOR > 0 
			
				_nVlrAux := TrbMPG->BBC_VALOR
			
			//Lancado em Qtd de CH
			ElseIf TrbMPG->BBC_QTDCH > 0 
			
				//Estou criando esse M->BBC_QTDCH para reaproveitar a funcao PLSA755QTD que pega o valor baseado na qtd de ch
				M->BBC_QTDCH := 0
				PLSA755Qtd(cCodOpe,TrbMPG->BBC_QTDCH,cAno,cMes,cCodRDA,"M->BBC_QTDCH")
				_nVlrAux := M->BBC_QTDCH

			Endif
			
			BBB->(msSeek(xFilial("BBB")+TrbMPG->CODSER,.F.))
			
			// Apuracao das bases dos impostos...                             
			
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

			ElseIf BBB->BBB_INCINS == "1"
				If BAU->BAU_BASINS == '1' .or. BBB->BBB_TIPOCT == "2"
					nVlrB_INPJ += _nVlrAux
					aBaseDif[2] += _nVlrAux
				Else
					If BBB->BBB_TIPOCT == "3"
						nVlrB_INJF += _nVlrAux
						aBaseDif[3] += _nVlrAux
					ElseIf BBB->BBB_TIPOCT == "1"
						nVlrB_INPF += _nVlrAux
						aBaseDif[1] += _nVlrAux
					Else
						nVlrB_INHP += _nVlrAux
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
		
			If BAU->BAU_CALIMP == "4"

				If EmpTy(BBB->BBB_VERBA) .AND. TrbMPG->BBC_VALOR > 0
					aadd(aCaLimp4, {getVerbaGen(, , PLSINTPAD(), "103"), TrbMPG->BBC_VALOR, BAU->BAU_MATFUN})
				elseIf TrbMPG->BBC_VALOR > 0
					aadd(aCaLimp4, {BBB->BBB_VERBA, TrbMPG->BBC_VALOR, BAU->BAU_MATFUN})
				endIf

			endIf

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
	
	// Lancamento de codigo 104 <<<<< Creditos Gerais                 
	If cCodLan == "104"

		cSQL := "SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR, BGQ_INCINS AS INCINS, "
		cSQL += "       BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL, "
		cSQL +=         IIf(lBGQ_INCISS, "BGQ_INCISS AS INCISS, ", "" )
		cSQL += "       BGQ_CODEMP, BGQ_CONEMP, BGQ_SUBCON, BGQ_MATRIC "
		
		cSQL += "  FROM " + RetSQLName("BGQ") 

		cSQL += " WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' AND "
		cSQL += "       BGQ_CODIGO = '" + cCodRDA+"' AND "
		cSQL += "      ( BGQ_ANO < '" + cAno + "' OR ( BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '"+ cMes +"' ) ) AND "
		
		If lBGQ_ATIVO 
			cSQL += " BGQ_ATIVO  <> '0' AND "
		endIf
		
		cSQL += " BGQ_TIPO   = '2' AND "
		cSQL += " BGQ_CODOPE = '" + cCodOpe + "'  AND "
		
		cSQL += " ( BGQ_OPELOT = '" + space( nBGQ_OPELOT ) + "' OR BGQ_OPELOT = '" + cOpelote + "' ) AND "
		cSQL += " ( BGQ_NUMLOT = '" + space( nBGQ_NUMLOT ) + "' OR BGQ_NUMLOT = '" + cLote + "' ) AND " 

		if !Empty(cLoteImp) .and. BGQ->(FieldPos("BGQ_SEQIMP"))
			cSQL += " BGQ_SEQIMP ='BRJ"+ alltrim(cLoteImp) +"' AND" 
		endif

		cSQL += " D_E_L_E_T_ = ' ' "
		
		If lPLMPALAN
			cSQL += Execblock("PLMPALAN",.f.,.f.,{})
		Endif
		
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
			
			// Apuracao das bases dos impostos...                             
			If  TrbMPG->INCINS == "1" .AND. BAU->BAU_TIPPE == "F"

				nIndSEFIP := fIndSEFIP(TrbMPG->BGQ_CODEMP, TrbMPG->BGQ_CONEMP, TrbMPG->BGQ_SUBCON, TrbMPG->BGQ_MATRIC, cCalcImp, @aSEFIP, TrbMPG->BGQ_VERBA)

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

			Elseif TrbMPG->INCINS == "1"
				If BAU->BAU_BASINS == '1' .or. TrbMPG->TIPOCT == "2"
					nVlrB_INPJ += TrbMPG->VALOR
				Else
					If TrbMPG->TIPOCT == "3"
						nVlrB_INJF += TrbMPG->VALOR
					ElseIf TrbMPG->TIPOCT == "1"
						nVlrB_INPF += TrbMPG->VALOR
					Else
						nVlrB_INHP += TrbMPG->VALOR
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
			
			
			If BAU->BAU_CALIMP == "4"

				If !EmpTy(TrbMPG->BGQ_VERBA) .AND. TrbMPG->VALOR > 0
					aadd(aCaLimp4, {TrbMPG->BGQ_VERBA, TrbMPG->VALOR, BAU->BAU_MATFUN})
				elseIf BBB->(msSeek(xFilial("BBB")+TrbMPG->CODLAN)) .AND. !(EmpTy(BBB->BBB_VERBA)) .AND. TrbMPG->VALOR > 0
					aadd(aCaLimp4, {BBB->BBB_VERBA, TrbMPG->VALOR, BAU->BAU_MATFUN})
				elseIf TrbMPG->VALOR > 0
					aadd(aCaLimp4, {getVerbaGen(, , PLSINTPAD(), "104"), TrbMPG->VALOR, BAU->BAU_MATFUN})
				endIf

			EndIf
			
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
	
	// Lancamento de codigo 105 <<<<< Debitos  Gerais                 
	If cCodLan == "105"

		cSQL := "SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR,BGQ_INCINS AS INCINS, "
		cSQL += "       BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL, "
		cSQL +=         IIf(lBGQ_INCISS, "BGQ_INCISS AS INCISS, ", "" )
		cSQL += "       BGQ_CODEMP, BGQ_CONEMP, BGQ_SUBCON, BGQ_MATRIC "
		cSQL += "  FROM " +RetSQLName("BGQ")
		cSQL += " WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' AND "
		cSQL += "       BGQ_CODIGO = '" + cCodRDA + "' AND "
		cSQL += "     ( BGQ_ANO < '" + cAno + "' OR ( BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '" + cMes + "' ) ) AND "
		
		If lBGQ_ATIVO 
			cSQL += " BGQ_ATIVO  <> '0' AND "
		EndIf

		cSQL += " BGQ_TIPO   = '1' AND "
		cSQL += " BGQ_CODOPE = '"  + cCodOpe + "' AND "
		
		cSQL += " ( BGQ_OPELOT = '" + space( nBGQ_OPELOT ) + "'  OR BGQ_OPELOT = '" + cOpelote + "' ) AND "
		cSQL += " ( BGQ_NUMLOT = '" + space( nBGQ_NUMLOT ) + "'  OR BGQ_NUMLOT = '" + cLote + "' ) AND "     


		if !Empty(cLoteImp) .and. BGQ->(FieldPos("BGQ_SEQIMP"))
			cSQL += " BGQ_SEQIMP ='BRJ"+ alltrim(cLoteImp) +"' AND" 
		endif

		cSQL += " D_E_L_E_T_ = ' ' "
		
		If lPLMPALAN
			cSQL += Execblock("PLMPALAN",.f.,.f.,{})
		Endif
		
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
			
			// Apuracao das bases dos impostos...                             
			If  TrbMPG->INCINS == "1" .AND. BAU->BAU_TIPPE == "F"				

				nIndSEFIP := fIndSEFIP(TrbMPG->BGQ_CODEMP, TrbMPG->BGQ_CONEMP, TrbMPG->BGQ_SUBCON, TrbMPG->BGQ_MATRIC, cCalcImp, @aSEFIP, TrbMPG->BGQ_VERBA)				

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

			Elseif TrbMPG->INCINS == "1"				
				If BAU->BAU_BASINS == '1' .or. TrbMPG->TIPOCT == "2"
					nVlrB_INPJ -= TrbMPG->VALOR		
				Else
					If TrbMPG->TIPOCT == "3"
						nVlrB_INJF -= TrbMPG->VALOR
					ElseIf TrbMPG->TIPOCT == "1"
						nVlrB_INPF -= TrbMPG->VALOR
					Else
						nVlrB_INHP -= TrbMPG->VALOR
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
			
			If TrbMPG->CODLAN $ cMV_PLPGLND
			
				aadd(aRet1A2,{	"3",;
								TrbMPG->VALOR,;
								"1A2",;
								"",;
								TrbMPG->CC,;
								TrbMPG->CODLAN,;
								"BGQ",;
								cProduto,;
								cTes})
											
			EndIf
			
			//Tratamento para que quando houver creditos para a RDA
			//esses creditos viram desconto no pedido de compra e  
			//na  nota fiscal de entrada                       
			nVlrDescNf += TrbMPG->VALOR
			
			If TrbMPG->CODLAN $ cCdIRRet
				nVrIRRet += TrbMPG->VALOR
			EndIf
			
			If BAU->BAU_CALIMP == "4"

				If !EmpTy(TrbMPG->BGQ_VERBA) .AND. TrbMPG->VALOR > 0
					aadd(aCaLimp4, {TrbMPG->BGQ_VERBA, TrbMPG->VALOR, BAU->BAU_MATFUN})
				elseIf BBB->(msSeek(xFilial("BBB")+TrbMPG->CODLAN)) .AND. !(EmpTy(BBB->BBB_VERBA)) .AND. TrbMPG->VALOR > 0
					aadd(aCaLimp4, {BBB->BBB_VERBA, TrbMPG->VALOR, BAU->BAU_MATFUN})
				elseIf TrbMPG->VALOR > 0
					aadd(aCaLimp4, {getVerbaGen(, , PLSINTPAD(), "105"), TrbMPG->VALOR, BAU->BAU_MATFUN})
				endIf

			EndIf
			
		TrbMPG->(DbSkip())
		Enddo
		
		TrbMPG->(DbCloseArea())
		
		If nTotDeb > 0

			lTemMvt := .T.
			nSaldo 	:= nTotDeb

			aadd(aRetNiv1,{	cDebCre,;
							nTotDeb,;
							cCodLan,;
							cDesLan,;
							cImgTree})
		Endif

	Endif
	
	// Lancamento de codigo 106 --<<<<< Apontamentos de producao medica   
	If cCodLan == "106"

		cSQL := " SELECT BCE_CC AS CC,BCE_VERBA, BCE_TIPOCT AS TIPOCT, BCE_CODPAG AS CODLAN, BCE_CC AS CC, BCE_VLRAPT AS VALOR,BCE_INCIR AS INCIR, "
		cSQL += "        BCE_INCINS AS INCINS, BCE_INCPIS AS INCPIS, BCE_INCCOF AS INCCOF, BCE_INCCSL AS INCCSL "
		cSQL +=          IIf(lBCE_INCISS, ", BCE_INCISS AS INCISS ", "" )
		
		cSQL += "   FROM " + RetSQLName("BCE")

		cSQL += "  WHERE BCE_FILIAL = '" + xFilial("BCE") + "' AND "
		cSQL += "        BCE_CODIGO = '" + cCodRDA + "' AND "
		cSQL += "        BCE_CODINT = '" + cCodOpe + "' AND "
		cSQL += "        BCE_ANOPAG = '" + cAno + "'  AND "
		cSQL += "        BCE_MESPAG = '" + cMes + "'  AND "
		cSQL += "        BCE_OPELOT = '" + space( nBCE_OPELOT ) + "' AND "
		cSQL += "        BCE_NUMLOT = '" + space( nBCE_NUMLOT ) + "'  AND "
		cSQL += "        D_E_L_E_T_ = ' '  "
		
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
			
			// Apuracao das bases dos impostos...                             
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
	
	// Lancamento de codigo 107 --<<<<< Faixa de Desconto				  
	If cCodLan == "107"

		If lBY6_VIGINI .and. lBY6_VIGFIN

			cSQL := " SELECT BY6_CODIGO,BY6_CODINT,BY6_FAIDE,BY6_FAIATE,BY6_PERDES, "
			cSQL += "        BY6_VIGINI, BY6_VIGFIN "
			
			cSQL += "  FROM " + RetSQLName("BY6")

			cSQL += " WHERE BY6_FILIAL = '" + xFilial("BY6") + "' AND "
			cSQL += "       BY6_CODIGO = '" + cCodRDA + "' AND "
			cSQL += "       BY6_CODINT = '" + cCodOpe + "' AND "
			cSQL += "       BY6_VIGINI <> '" + space(nBY6_VIGINI) + "' AND
			cSQL += "       BY6_VIGINI <= '" + dtos(dDataBase) + "' AND "
			cSQL += "     ( BY6_VIGFIN = '" + space(nBY6_VIGFIN) + "' OR BY6_VIGFIN >= '" + dtos(dDataBase) + "' ) AND "
			cSQL += "       D_E_L_E_T_ = ' '  "
			
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
				
					If BLR->(msSeek(xFilial("BLR")+TrbBY6->BY6_CODINT+aRetNiv2[nX][3]))
				
						If lBLR_DESPRO .and. BLR->BLR_DESPRO == '1' 

							If BLR->BLR_DEBCRE == '2' .And. aRetNiv2[nX][2] >= TrbBY6->BY6_FAIDE .And. aRetNiv2[nX][2] <= TrbBY6->BY6_FAIATE
								
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

	// Lancamento de codigo 167 --<<<<< Valor Base INSS Hon.Patronal  
	// Quando o calculo de impostos NAO eh pelo financeiro (pela folha)   
	If  cCodLan == "167" .And. BAU->BAU_TIPPE == 'F' .and. nVlrB_INHP > 0 .and. BAU->BAU_BASINS <> '1'
		
		nSaldo 	:= nVlrB_INHP
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_INHP,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	
	// Lancamento de codigo 170 <<<<< Sal Contrib Outras Empresas     
	If cCodLan == "170" 
		
		If BAU->BAU_CODIGO <> cCodRDA
			BAU->(DbSetOrder(1))
			BAU->(MsSeek(xFilial("BAU") + cCodRDA))
		endIf
		
		FJW->(DbSetOrder(1))
		
		If FJW->(Msseek(xfilial("FJW") + BAU->BAU_CODSA2)) //Verifica o cabeçalho da rotina de préva de INSS do financeiro
			
			csql := " Select FLX_BASE VALOR from " + RetSqlName("FLX") + " FLX "
			csql += " Where "
			cSql += " FLX_FILIAL = '" + xfilial("FLX") + "' AND "
			cSql += " FLX_FORNEC = '" + FJW->FJW_FORNEC + "' AND "
			cSql += " FLX_LOJA = '" + FJW->FJW_LOJA + "' AND "
			csql += " ( FLX_DTINI = ' ' OR FLX_DTINI <= '" + cAno + cMes + '01' + "') AND "
			cSql += " ( FLX_DTFIM = ' ' OR FLX_DTFIM >= '" + cAno + cMes + '28' + "') AND "
			cSql += " D_E_L_E_T_ = ' ' "
			
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBFLX",.F.,.T.)	
			nTotCre := 0
			
			While ! TRBFLX->(Eof())
				
				If ! PLMOVCRE(BAU->BAU_CODIGO,cAno,cMes,,"0",cCod170,cCodOpe,cOpeLote)
					TrbMPG->(DbSkip())
					Loop
				EndIf
				
				nTotCre += TRBFLX->VALOR
				
				aadd(aRetNiv2,{	"3",;
								TRBFLX->VALOR,;
								cCodLan,;
								"",;
								 "",;
								cCod170,;
								cOriLan,;
								cProduto,;
								cTes})
			
			TRBFLX->(DbSkip())
			Enddo
			
			If nTotCre > 0
			
				lTemMvt := .T.
				nSaldo 	:= nTotCre
				aadd(aRetNiv1,{	"3",;
								nTotCre,;
								cCodLan,;
								cDesLan,;
								cImgTree})
			Endif
								
			
			TRBFLX->(DbcloseArea())
		endIf

	Endif
	
	//Marca para criar o registro no BMR que irá sempre conter o total de rendimentos com incidência de INSS
	//Por questão de cálculo, o valor do lançamento 182 irá ter o valor do teto do salário de contribuição
	//do INSS, porém, no esocial, há a necessidade da informação do total
	If cCodLan == "165"
		lAdd165 := .T.
	EndIf
	
	// Lancamento de codigo 182 --<<<<< Valor Base INSS                    
	// Base total INSS quando for calculo de impostos pelo financeiro      
	// ou eh Pessoa Fisica Nao Cooperado e Base for Unificada                                   
	If cCodLan == "182" .And. /*BAU->BAU_TIPPE == 'F' .And.*/ (nVlrB_INPF + nVlrB_INPJ + nVlrB_INJF + nVlrB_INHP) > 0 .and. BAU->BAU_BASINS == '1'
		
		nSaldo := nVlrB_INPF + nVlrB_INPJ + nVlrB_INJF + nVlrB_INHP
		
		lTemMvt := .T.
		aadd(aRetNiv1,{	cDebCre,;
						nSaldo,;
						cCodLan,;
						cDesLan,;
						cImgTree})
		If lAdd165
		
			aadd(aRetNiv1,{	cDebCre,;
						nSaldo,;
						"165",;
						"Total Rendimentos Com Incidência INSS",;
						cImgTree})

		EndIf

	Endif
	
	// Lancamento de codigo 184 --<<<<< Valor Base ISS                
	If cCodLan == "184" .And. nVlrB_ISS > 0

		nSaldo 	:= nVlrB_ISS
		lTemMvt := .T.
	
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_ISS,;
						cCodLan,;
						cDesLan,;
						cImgTree})

	Endif
	
	// Lancamento de codigo 186 --<<<<< Valor Base PIS                
	If cCodLan == "186" .And. nVlrB_PIS > 0
		
		nSaldo 	:= nVlrB_PIS
		lTemMvt := .T.
		
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_PIS,;
						cCodLan,;
						cDesLan,;
						cImgTree})

	Endif
	
	// Lancamento de codigo 188 --<<<<< Valor Base COFINS             
	If cCodLan == "188" .And. nVlrB_COF > 0
		
		nSaldo 	:= nVlrB_COF
		lTemMvt := .T.
		
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_COF,;
						cCodLan,;
						cDesLan,;
						cImgTree})

	Endif
	
	// Lancamento de codigo 190 --<<<<< Valor Base CSLL               
	If cCodLan == "190" .And. nVlrB_CSL > 0
		
		nSaldo 	:= nVlrB_CSL
		lTemMvt := .T.
		
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_CSL,;
						cCodLan,;
						cDesLan,;
						cImgTree})

	Endif
	
	// Lancamento de codigo 192 --<<<<< Valor Base INSS PF            
	If cCodLan == "192" .And. BAU->BAU_TIPPE == 'F' .And. nVlrB_INPF > 0 .and. BAU->BAU_BASINS <> '1'
		
		nSaldo 	:= nVlrB_INPF
		lTemMvt := .T.
		
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_INPF,;
						cCodLan,;
						cDesLan,;
						cImgTree})

	Endif
	
	// Lancamento de codigo 194 --<<<<< Valor Base INSS PJ            
	If  cCodLan == "194" .And. BAU->BAU_TIPPE == 'F' .and. nVlrB_INPJ > 0 .And. BAU->BAU_BASINS <> '1'
		
		nSaldo 	:= nVlrB_INPJ
		lTemMvt := .T.
		
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_INPJ,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	
	// Lancamento de codigo 196 --<<<<< Valor Base INSS PJ Filantropico   
	If  cCodLan == "196" .And. BAU->BAU_TIPPE == 'F' .and. nVlrB_INJF > 0 .And. BAU->BAU_BASINS <> '1'
		
		nSaldo 	:= nVlrB_INJF
		lTemMvt := .T.
		
		aadd(aRetNiv1,{	cDebCre,;
						nVlrB_INJF,;
						cCodLan,;
						cDesLan,;
						cImgTree})
	Endif
	
	// Lancamento de codigo 198 --<<<<< Valor Base Imposto de Renda   
	If cCodLan == "198"
		
		cOriLan := "BGQ"

		cSQL := " SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR,BGQ_INCINS AS INCINS, "
		cSQL += "        BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL "
		cSQL += "   FROM " + RetSQLName("BGQ")
		cSQL += "  WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' AND "
		cSQL += "        BGQ_CODIGO = '" + cCodRDA + "' AND "
		cSQL += "        BGQ_ANO    = '" + cAno + "' AND "
		cSQL += "        BGQ_MES    = '" + cMes + "' AND "
		cSQL += "        BGQ_CODLAN = '" + allTrim(cCod198) + "' AND "
		cSQL += "        BGQ_TIPO   = '3' AND "
		cSQL += "        BGQ_CODOPE = '" + cCodOpe + "' AND "
		cSQL += "        BGQ_OPELOT = '" + space(nBGQ_OPELOT) + "' AND "
		cSQL += "        BGQ_NUMLOT = '" + space(nBGQ_NUMLOT) + "' AND "
		
		If lBGQ_ATIVO
			cSQL += " BGQ_ATIVO <> '0' AND "
		EndIf
		
		cSQL += " D_E_L_E_T_ = ' '  "
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMPG",.F.,.T.)	
		TCSETFIELD("TrbMPG","VALOR","N",nVlPrec,nVlDec)
		
		// Se nao encontrou em debitos/creditos variaveis o lancamento ref a  
		// "Sal Contrib INSS Outras Empresas" busca em debitos/creditos fixos.
		If TrbMPG->(Eof())

			TrbMPG->(DbCloseArea())

			cOriLan := "BBC"

			cSQL := " SELECT BBC_CODSER AS CODLAN, BBC_CC AS CC, BBC_VALOR AS VALOR, BBC_NROPGT "
			cSQL += "   FROM " + RetSQLName("BBC")
			cSQL += "  WHERE BBC_FILIAL = '" + xFilial("BBC") + "' AND "
			cSQL += "        BBC_CODIGO = '" + cCodRDA + "' AND "
			cSQL += "        BBC_PROMED = '1' AND "
			cSQL += "        BBC_STATUS = '1' AND "
			cSQL += "        BBC_CODSER = '" + allTrim(cCod198) + "' AND "
			cSQL += "        BBC_DEBCRE = '3' AND "

			If lCposVld
				cSQL += " '" + cAno + cMes + "01' >= BBC_VLDINI AND "
				cSQL += " ( ( '" + DtoS( LastDay( ctod( "01/" + cMes + "/" + cAno ) ) )  + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '" + space(nBBC_VLDFIM) + "' ) ) AND "
			EndIf

			cSQL += " D_E_L_E_T_ = ' ' "
			
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
	
	// Debitos Gerias - Pagamento Intercambio de Anestesista			
	If cCodLan == "104" .And. lAneste .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
		
		If lB7R
		
			cSQL := "SELECT SUM(B7R_VLRDIF) AS VALOR, SUM(B7R_VLRGLO) AS GLOSA, BRJ_CODIGO, BRJ_TPPAG "
			cSQL += "  FROM " + RetSQLName("B7R") + " B7R "

			cSql += " INNER JOIN " + RetSqlName("BRJ") + " BRJ "
			cSql += "  ON BRJ.BRJ_FILIAL = B7R.B7R_FILIAL "
			cSql += " AND BRJ.BRJ_CODIGO = B7R.B7R_CODBRJ "
			cSql += " AND BRJ.BRJ_CODIGO = '" + cLoteImp + "' "
			cSql += " AND BRJ.BRJ_OPEORI = '" + BAU->BAU_CODOPE + "' "
			cSql += " AND BRJ.BRJ_STATUS = '1' " // A Faturar
			cSql += " AND BRJ.BRJ_REGPRI = '1' "
			cSQL += " AND BRJ.D_E_L_E_T_ = ' ' "

			cSQL += " WHERE B7R_FILIAL = '" + xFilial("B7R") + "' AND "
			cSQL += "       B7R.D_E_L_E_T_ = ' ' "
			cSQL += " GROUP BY BRJ_CODIGO, BRJ_TPPAG "
		
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
	
	//  Monta totalizador da verba...                                 
	If ! Empty(cVerba)
		AnalisaVerbas(cVerba,aVerbasFol,nSaldo)
	Endif
	
	//  Monta total acumulado...                                      
	If	cDebCre == "1"
		nTotal -= nSaldo
	ElseIf cDebCre == "2"
		nTotal += nSaldo
	Endif
	
	// Inclui no vetor Composicao de Pagamento                        
	If  lPLSPAG01
		ExecBLock("PLSPAG01",.F.,.F.,{cCodRda,cAno,cMes,cCodLan,nSaldo,lGerLot})
	Endif
Next

// Verifica se existe imposto                                     
lTemImp := IIf((nVlrB_IR + nVlrB_INPF + nVlrB_INPJ + nVlrB_INJF + nVlrB_INHP + nVlrB_PIS + nVlrB_COF + nVlrB_CSL + nVlrB_ISS) > 0, .T., .F.)

// Caso nao tenha imposto, nem valor e tenha movimentacao ele ira gerar o lancamento 
// de credito de 1 centavo para que seja gerado o titulo e dado baixa na movimentacao
If nTotal == 0 .AND. !lTemImp .AND. lTemMvt
	lGeraL := .T.
Endif

aUsDif := { nVlrDebdif, nVlrCredif }

// Monta retorno padrao...                                        
aResumo[1] := nTotal

lGerRecglo := .F.

// Determina mesmo não havendo valor a pagar para a RDA e tem somente glosa devemos forçar para a mudança de flag para faturado para atender algumas empresas que controlam esse status
if nTotal <> 0 .or. lTemImp .or. lTemMvt .or. getNewPar("MV_PLFORGE", .f.)  									   
	
	aRetPad := { .t., aRetNiv1, aVerbasFol, aResumo, aRetNiv2, aSEFIP, aVrPgtDiv, nVrIRRet, lTemImp, lGeraL, nVlrRefTde, aUsDif, nVlrGlo, nVlrSer, nVlrTx, aBaseDif, nVlrDescNf, aRet1A2, lGerRecglo, aCaLimp4, aRecBD7 } //21 posicao final

elseIf cCalcImp $ '1,4'
	
	aRetPad := { .f., aRetNiv1, aVerbasFol, aResumo, aRetNiv2, aSEFIP, aVrPgtDiv, nVrIRRet, lTemImp, lGeraL, nVlrRefTde, aUsDif, nVlrGlo, nVlrSer, nVlrTx, aBaseDif, nVlrDescNf, aRet1A2, lGerRecglo, aCaLimp4, aRecBD7 }

endIf

RestArea(aArea)

Return(aRetPad)

/*/{Protheus.doc} PLGERCRE
Gerar titulo para um credenciado em um deterinado ano/mes

Parametros                                                          
cOpeRda  - Operadora da RDA (4 Digitos)                             
cCodRda  - Codigo da Rda (6 Digitos)                                
cCodForn - Codigo do Fornecedor (6 Digitos)                         
cLoja    - Loja (2 Digitos)                                         
cAno     - Ano Base do Saldo (4 Digitos)                            
cMes     - Mes Base do Saldo (2 Digitos)                            
dVencto  - Data do vencimento                                       
cPrefixo - Prefixo do Titulo                                        
cNumero  - Numero do Titulo                                         
cTipo    - Tipo do Titulo                                           
cHisTit  - Historico do Titulo (E2_HIST)                           
cOpeLote - Operadora do lote de pagamento                          
cLote    - Numero do lote de pagamento                             
cLoteImp - Indica se eh pagamento de um determinado lote apenas	   

Retorno em uma matriz na seguinte estrutura                         
"1"  - Titulo gerado com sucesso                                    
"?"  - Demais criticas que podem ser visualizadas abaixo            

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Function PLGERCRE(cOpeRda,cCodRda,cCodForn,cLoja,cAno,cMes,dVencto,cPrefixo,cNumero,cTipo,cHisTit,;
					cOpeLote,cLote,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,cCodPegFi,cNumMovIn,cNumMovFi,;
					cCodOpe,aLancPagto,cCdEmpDeS,cCdEmpAteS,cExcessao,lGerPagBlo,cLoteImp,cCodDC,lCalcImp,cCodNat,;
					lGuiCob,lUltCaLc,nApUsDif,lAtuGui,cExcPeg,cTipTitInt,nPosTitInt,lAneste)

LOCAL nOrdSA2 		:= SA2->(IndexOrd())
LOCAL nRecSA2 		:= SA2->(Recno())
LOCAL nOrdBAU 		:= BAU->(IndexOrd())
LOCAL nRecBAU 		:= BAU->(Recno())
LOCAL nOrdBA0 		:= BA0->(IndexOrd())
LOCAL nRecBA0 		:= BA0->(Recno())

LOCAL cSQL			:= ''
LOCAL cNaturez	 	:= ''
LOCAL cCalcImp		:= '' 
LOCAL cCondPag  	:= ""
LOCAL cTipoTit		:= ""
Local cCliente		:= ''
Local cLojaCli		:= ''
Local cCodEmp		:= ''
Local cConEmp		:= ''
Local cSubCon		:= ''
Local cMatric		:= ''
Local cCopCre		:= ''
local cChkSE2		:= ''
LOCAL cPagTot		:= ""
Local cLotPcPls   	:= ''
Local cSemana		:= ''
Local cChaveSem     := ""
Local cParcela		:= space(TamSx3("E2_PARCELA")[1])
LOCAL cCodCreGlo    := GetNewPar("MV_PLSCDCG","   ")
LOCAL cCodCreTit    := GetNewPar("MV_PLSCDCT","   ")
LOCAL cCodCreUdf    := GetNewPar("MV_PLSCUSD","903")
LOCAL cCodDebUdf    := GetNewPar("MV_PLSDUSD","904")
LOCAL cCodRestUdf   := GetNewPar("MV_PLSRUSD","905")
Local cNatPF		:= GetNewPar("MV_PLSNTPF",cNaturez)
Local cNatPJ		:= GetNewPar("MV_PLSNTPJ",cNaturez)
Local cNatFT		:= GetNewPar("MV_PLSNTFT",cNaturez)
Local cNatHP		:= GetNewPar("MV_PLSNTHP",cNaturez)
Local cPLNUME2		:= GetMV("MV_PLNUME2")
Local cCodUsr		:= RetCodUsr()

LOCAL nInsOutEmp 	:= 0
LOCAL nFor			:= 0
LOCAL nValorBIR  	:= 0
LOCAL nValorBISS	:= 0
LOCAL nValorBINS	:= 0
LOCAL nValorBCSL	:= 0
LOCAL nValorBCOF	:= 0
LOCAL nValorBPIS	:= 0
LOCAL nValorBSES	:= 0
LOCAL nValorBIN1 	:= 0
LOCAL nValorBIN2 	:= 0
LOCAL nValorBIN3 	:= 0
LOCAL nValorBIN4 	:= 0
LOCAL nPos			:= 0
LOCAL nVlrSE2	 	:= 0
LOCAL nVlrFATINT	:= 0
LOCAL nVlrFATNDC	:= 0
LOCAL nVlrFATFAT	:= 0
LOCAL nGlosaPag     := 0
Local nInd			:= 0
LOCAL nRecnoBGQ		:= 0
LOCAL nRecnoBRJ		:= 0
LOCAL nValDbBGQ     := 0
Local nValImp      	:= 0
Local nVlrImp      	:= 0 // Valor total dos Impostos para somar na NDF
local nVlrIR		:= 0
local nVlrDebVar	:= 0
Local i				:= 0
LOCAL nImp	  		:= 0
LOCAL nVrAcresc		:= 0
LOCAL nVrDecresc	:= 0
Local nVrIRRet		:= 0
LOCAL nDescC7		:= 0
LOCAL nTotDesc		:= 0
Local nForSE2		:= 0 //Contador para o For do SE2
Local nForSE2Lim	:= 0 //Limite para o For do SE2 para geração de títulos com naturezas distintas
Local nVez			:= 0
Local nPosINS		:= 2
Local nHNumPag		:= 0
Local nTenta		:= 0
Local nPrcSld   	:= 0
local nVlrRGB		:= 0
Local nCaLimp4		:= 1
Local nCont			:= 1

LOCAL aSaldo		:= {}
LOCAL aCritica   	:= {}
LOCAL aCompPag   	:= {}
LOCAL aCompPagD  	:= {}
LOCAL aCampos		:= {}
LOCAL aVerbasFol 	:= {}
LOCAL aVerbas    	:= {}
Local aSEFIP     	:= {}
Local aRetCli		:= {}
LOCAL aBasesImp		:= {}
LOCAL aImpostos		:= {}
Local aRetImp		:= {0,0,.F.,''}
Local aRecnoDP		:= {}
LOCAL aTpCalc 		:= {}
Local aBMR    		:= {}
LOCAL aImpMes		:= {}
LOCAL aRetVLRNF		:= {}
LOCAL aItens		:= {}                                                                     
Local aINSSE2		:= {}
Local aCopSld		:= {}

Local lHist 		:= .t.
LOCAL lOK        	:= .t.
LOCAL lAutonomo		:= .f.
LOCAL lPagInterc    := .f.
LOCAL lCriadoBGQAut := .f.
LOCAL lAtuaBRJPag   := .f.
LOCAL lSoINSS		:= .F.
LOCAL lINSS182		:= .F.
LOCAL lPgtoImp   	:= GetNewPar("MV_PLPGUNI","1") == "4"
Local lA1_CEINSS 	:= SA1->(FieldPos("A1_CEINSS"))  > 0
Local lBQC_CLAINS 	:= BQC->(FieldPos("BQC_CLAINS")) > 0
Local lBAU_BASINS 	:= BAU->(FieldPos("BAU_BASINS")) > 0
Local lBMR_ANOVCT	:= BMR->(FieldPos('BMR_ANOVCT')) >0
Local lBMR_MESVCT	:= BMR->(FieldPos('BMR_MESVCT')) >0
Local lBBB_INCISS 	:= BBB->(FieldPos("BBB_INCISS")) > 0
Local lBGQ_INCISS 	:= BGQ->(FieldPos("BGQ_INCISS")) > 0
Local lPLSPGSC7 	:= ExistBlock("PLSPGSC7")
Local lPLSPAG02		:= ExistBlock("PLSPAG02")
Local lContrRet 	:= !Empty(SE2->(FieldPos("E2_VRETPIS"))) .And. !Empty(SE2->(FieldPos("E2_VRETCOF"))) .And. ;
					   !Empty(SE2->(FieldPos("E2_VRETCSL"))) .And. !Empty(SE2->(FieldPos("E2_PRETPIS"))) .And. ;
					   !Empty(SE2->(FieldPos("E2_PRETCOF"))) .And. !Empty(SE2->(FieldPos("E2_PRETCSL")))

Local bCampo		:= {|x| FieldName(x) }
Local aTESPROD		:= {}
Local nO			:= 1
Local nSC7Ite 		:= 1
Local nTotPedido	:= 0
local cOrigem       :='PLSMPAG'


PRIVATE nValorPag	:= 0
DEFAULT cCdEmpDeS  	:= ""
DEFAULT cCdEmpAteS 	:= ""
DEFAULT cExcessao  	:= ""
DEFAULT lGerPagBlo 	:= .F.
DEFAULT cLoteImp   	:= ""
DEFAULT cCodDC     	:= ""
DEFAULT lCalcImp   	:= .F.
DEFAULT cCodNat    	:= ""
DEFAULT lGuiCob    	:= .F.
DEFAULT lUltCalc   	:= .F.
DEFAULT nApUsDif   	:= 2
DEFAULT lAtuGui	   	:= .F.
DEFAULT cExcPeg	   	:= ""
DEFAULT cTipTitInt 	:= "2"  //Indica o tipo de fatura de intercambio: 1-NDC / 2-Fatura /3-Ambos
DEFAULT nPosTitInt 	:= 1   //Indica numeracao do titulo que esta sendo gerado. (1-Todos os titulos / 2-Titulo 'Fatura' do A500 quando o lote e do tipo 3-Ambos)
Default lAneste		:= .F.
Private nMoeda     	:= 1    

// Trata o parametro caso esteja cadastrado e sem conteudo...          
cCodCreTit := Iif(len(cCodCreTit)==3, cCodCreTit, cCodCreTit + space(3-len(cCodCreTit) ) )

// Trata vencimento invalido...                                        
If Empty(dVencto)
	aCritica := {"2","Data de Vencimento Invalida",0}
	Return(aCritica)
Endif

// Verifica se existe o fornecedor informado...                        
SA2->(DbSetOrder(1))
If ! SA2->(msSeek(xFilial("SA2")+cCodForn+cLoja,.F.))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	
	aCritica := {"3","Fornecedor Invalido",0}
	Return(aCritica)
Endif

// Verifica se existe a rede de atendimento...                    
BAU->(DbSetOrder(1))
If ! BAU->(msSeek(xFilial("BAU")+cCodRda,.F.))
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	
	aCritica := {"4","Rede de Atendimento Invalida",0}
	Return(aCritica)
Endif
cCopCre := BAU->BAU_COPCRE

// Verifica se tem pagamento dividido e testa se ja foi processado..  
If BAU->BAU_MODPAG $ "2,3"
	BEQ->(DbSetOrder(1))
	If ! BEQ->(msSeek(xFilial("BEQ")+BAU->BAU_CODIGO+cAno+cMes,.F.))
		BAU->(DbSetOrder(nOrdBAU))
		BAU->(DbGoTo(nRecBAU))
		SA2->(DbSetOrder(nOrdSA2))
		SA2->(DbGoTo(nRecSA2))
		
		aCritica := {"5","deve ser executada a rotina gerar pagto dividido antes de efetuar o pagamento.",0}
		Return(aCritica)
	Endif
Endif

// Se a RDA estiver bloqueada trata se pode gerar ou nao...       
If ! Empty(BAU->BAU_CODBLO) .And. ! lGerPagBlo
	aCritica := {"6","RDA Bloqueada. Nao e possivel gerar pagamento.",0}
	Return(aCritica)
Endif

If !Empty(cLoteImp) .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
	
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
					
				If  BRJ->BRJ_TPPAG == "1" .And. !lAneste
					nVlrFATINT := BRJ->BRJ_VALOR
					nVlrFATNDC := BRJ->BRJ_VLRNDC
					nVlrFATFAT := BRJ->BRJ_VLRFAT
					lPagInterc := .T.					
				Endif

				cPagTot := BRJ->BRJ_TPPAG
				Exit
			EndIf
			BRJ->(DbSkip())
		EndDo
	Endif
Endif

// Verifica saldo...                                              
cCalcImp := IF(BAU->(FieldPos("BAU_CALIMP"))>0,BAU->BAU_CALIMP,"2")

aSaldo := PLSLDCRE(BAU->BAU_CODIGO,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,cCodPegIn,;
					cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,BAU->BAU_CODSA2,BAU->BAU_LOJSA2,aLancPagto,;
					cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,cCodDC,lCalcImp,cCodNat,lGuiCob,;
               		/*lPgtDiv*/,.T.,/*lMudUs*/,/*nNewUs*/,nApUsDif,lAtuGui,cOpeLote,cLote,dVencto,cExcPeg,cTipTitInt,nPosTitInt,,lAneste)
                   
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

// Busca bases e impostos ja calculados no mes para a RDA              			
// Este array sera usado no calculo dos impostos - implementacao feita 			
// para atender a necessidade de calcular mais de um pagamento no mes. 			
// Melhoria para atendimento a parametrizacao financeira e a Lei 10925 - RC 20100416..

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

// Caso nao tenha movimentacao e tambem nao tenha lancamentos de Cre- 
// dito de Provisao de INSS ou nao seja o Ultimo Calculo, gera critica.³
// aSaldo[1] => indica que tem saldo (positivo ou negativo)       
// aSaldo[9] => indica que base para impostos                     

								// Prov.Inss PJ + Prov.INSS PF + Prov.INSS JF + Prov.INSS HP
If ! aSaldo[1] .And. ! aSaldo[9] .And. (aImpMes[8]+aImpMes[9]+aImpMes[12]+aImpMes[24] == 0 .Or. ! lUltCalc)
	
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	
	// Quando Intercambio Não houver Pagto e glosar 100% a importação
	If lPagInterc .And. Empty(aSaldo[4])
		nValorPag:=0
	Elseif ! aSaldo[19]
		aCritica := {"D","Nao existem movimentacoes neste Ano/Mes",0}
		Return(aCritica)
	Endif
		// nInssPJ + nInssPF + nInssJF + nInssHP + nInssBU
Else
	
	// Caso nao tenha movimentacao mas tenha lancamentos de Credito de
	// Provisao de INSS, atualiza array com zero para evitar erro na linha
	// abaixo: "nValorPag := aSaldo[4,1]"                             
	
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

// Tratamento da natureza do titulo...                            
If  ! ExistBlock("PLNATESP")
	
	cNaturez := SA2->A2_NATUREZ

	If  Empty(cNaturez) .Or. ! Eval({|| SED->(DbSetOrder(1)), SED->(msSeek(xFilial("SED")+cNaturez,.F.)) })
		if empty(cCodNat)
			BAU->(DbSetOrder(nOrdBAU))
			BAU->(DbGoTo(nRecBAU))
			SA2->(DbSetOrder(nOrdSA2))
			SA2->(DbGoTo(nRecSA2))
			aCritica := {"9","Natureza do credenciado invalida",0}
			Return(aCritica)
		else
			cNaturez := cCodNat
		endif
	endif

Else
	
	cNaturez := ExecBLock("PLNATESP",.F.,.F.)
	
	If ValType(cNaturez) <> "C" .Or. ! Eval({|| SED->(DbSetOrder(1)), SED->(msSeek(xFilial("SED")+cNaturez,.F.)) })
		BAU->(DbSetOrder(nOrdBAU))
		BAU->(DbGoTo(nRecBAU))
		SA2->(DbSetOrder(nOrdSA2))
		SA2->(DbGoTo(nRecSA2))
		
		aCritica := {"A","Ponto de entrada PLNATESP invalido",0}
		Return(aCritica)
	Endif

Endif

// Verifica se a chave do titulo ja nao existe na base (seguranca)

SE2->(DbSetOrder(1))
If SE2->(msSeek(xFilial("SE2")+cPrefixo+cNumero+cParcela+cTipo+cCodForn+cLoja,.F.))
	
	BAU->(DbSetOrder(nOrdBAU))
	BAU->(DbGoTo(nRecBAU))
	SA2->(DbSetOrder(nOrdSA2))
	SA2->(DbGoTo(nRecSA2))
	
	aCritica := {"B","Prefixo+Numero+Parcela+Tipo+Fornecedor+Loja ja existe",0}

	Return(aCritica)

Endif

// Se for um pagamento de intercambio vou comparar a fatura com o saldo a pagar
If lPagInterc    

	If cCalcImp $ '2,3,4'		// Financeiro ou Folha-Financeiro  
		nGlosaPag := Iif(Len(aSaldo)>12,aSaldo[13],0)
	Else
		nGlosaPag := IIf(nVlrFATINT > nValorPag, nVlrFATINT-nValorPag, 0 )
	EndIf

Endif

// Se o valor de glosa for maior que zero, irei lancar um debito contra a rda...³
If nGlosaPag > 0		// Só terá valor se for intercâmbio

	BBB->(DbSetOrder(1))
	If ! BBB->(msSeek(xFilial("BBB")+cCodCreGlo,.F.)) .Or. BBB->BBB_TIPSER == "1"

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
		BLR->(msSeek(xFilial('BLR')+PlsIntPad()+'104',.F.))
		
		aCopSld := aClone(aSaldo[2])
		nInd 	:= aScan(aCopSld, { |x| x[3]+AllTrim(x[4])+AllTrim(x[5]) == '104'+AllTrim(BLR->BLR_DESCRI)+AllTrim(BLR->BLR_IMG) } )
		
		If nInd == 0
			aAdd( aSaldo[2], { BLR->BLR_DEBCRE,	nGlosaPag, '104', BLR->BLR_DESCRI, BLR->BLR_IMG, '104', "BGQ", '', ''} )
			aAdd( aSaldo[5], { BLR->BLR_DEBCRE,	nGlosaPag, '104', BLR->BLR_DESCRI, BLR->BLR_IMG, '104', "BGQ", '', ''} )
		Else
			aSaldo[2,nInd,2] += nGlosaPag
		EndIf

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

// Geração de Dedito/Credito para Us diferenciada                              .³
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

//Grava tabela B15 - BASES INSS PAGAMENTOS RDA'S - SEFIP                    
//Ordena Tabela aSEFIP por CODEMP / CONEMP / SUBCON / MATRIC / CALCIMP      
//aSEFIP:                                                                   
//1 - Codigo da Empresa/Grupo                                               
//2 - Contrato                                                              
//3 - SubContrato                                                           
//4 - Matricula Familia                                                     
//5 - Calcula Imposto: 1 ou 3 - Integracao com Folha de Pagamento           
//6 - Base INSS Pessoa Fisica                                               
//7 - Base INSS Pessoa Juridica                                             
//8 - Base INSS Juridica Filantropica                                       

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

	//Se CONEMP/SUBCON for diferente de "", foi gravado o BGQ        
	//Verifica nivel de cobranca do SubContrato/Contrato/Empresa e define
	//cliente/loja                                                   
	
	If !Empty(aSEFIP[nInd, 2]+aSEFIP[nInd, 3])
	
		If cCodEmp+cConEmp+cSubCon <> aSEFIP[nInd, 1]+aSEFIP[nInd, 2]+aSEFIP[nInd, 3]
	
			cCodEmp  := aSEFIP[nInd, 1]
			cConEmp  := aSEFIP[nInd, 2]
			cSubCon  := aSEFIP[nInd, 3]
			
			//Branca Cliente/Loja pois se nao encontrar SubContrato/Contra
			//to/Empresa ira considerar a propria OPERADORA como o TOMADOR
			
			cCliente := Space(6)
			cLojaCli := Space(2)
			
			// Posiciona BG9 - Grupo/Empresa
			BG9->(DbSetOrder(1))
			BG9->(msSeek(xFilial("BG9")+cCodOpe+cCodEmp,.F.))
			
			// Posiciona BT5 - Contrato
			BT5->(DbSetOrder(1))
			BT5->(msSeek(xFilial("BT5")+cCodOpe+cCodEmp+cConEmp,.F.))
			
			// Posiciona BQC - Sub-Contrato
			BQC->(DbSetOrder(1))
			BQC->(msSeek(xFilial("BQC")+cCodOpe+cCodEmp+cConEmp+BT5->BT5_VERSAO+cSubCon,.F.))
			
			If BQC->BQC_COBNIV == "1" .And.  ! Empty(BQC->BQC_CODCLI)
				cCliente := BQC->BQC_CODCLI
				cLojaCli := BQC->BQC_LOJA
			ElseIf BT5->BT5_COBNIV == "1" .And.  ! Empty(BT5->BT5_CODCLI)
				
				If BT5->BT5_INTERC == "1" .And. AllTrim(BT5->BT5_TIPOIN) == GetNewPar("MV_PLSCDIE","1")// Eventual
					BA0->(DbSetOrder(1))
					If BA0->(msSeek(xFilial("BA0")+cOpeOri,.F.)) .And. ! Empty(BA0->BA0_CODCLI)
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
			If SA1->(msSeek(xFilial("SA1")+cCliente+cLojaCli,.F.))
				
				//"Pessoa Fisica" ira considerar a propria Cooperativa como o TOMADOR
				//por isso branca Cliente/Loja (desde que nao possua CEI)        
				
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
	
	//Se CODEMP/MATRIC igual a "", branca Cliente/Loja para que seja con-
	//siderado o TOMADOR como a propria OPERADORA. Esses registros foram 
	//gravados a partir das tabelas BBC, BCE e, em alguns casos, do BGQ  
	//e nao foi possivel definir nivel de cobranca.                  
	
	ElseIf Empty(aSEFIP[nInd, 1]+aSEFIP[nInd, 4])
		cCliente := Space(6)
		cLojaCli := Space(2)
	Else
		
		//Se trocou CODEMP/MATRIC, posiciona arquivos e executa   
		//PLSRETNCB para retornar nivel de cobranca               
		
		If cCodEmp + cMatric <> aSEFIP[nInd, 1] + aSEFIP[nInd, 4]

			cCodEmp  := aSEFIP[nInd, 1]
			cMatric  := aSEFIP[nInd, 4]
			
			//Branca Cliente/Loja pois se nao encontrar usuario/familia,  
			//ira considerar a propria OPERADORA como o TOMADOR       
			
			cCliente := Space(6)
			cLojaCli := Space(2)

			// Posiciona BA1 - Usuario
			BA1->(DbSetOrder(1))
			If BA1->(msSeek(xFilial("BA1") + cCodOpe + cCodEmp + cMatric, .F. ) )

				// Posiciona BA3 - Familia
				BA3->(DbSetOrder(1))
				If BA3->(msSeek(xFilial("BA3")+cCodOpe+BA1->(BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB),.F.))
			
					// Posiciona BG9 - Grupo/Empresa
					BG9->(DbSetOrder(1))
					BG9->(msSeek(xFilial("BG9")+cCodOpe+BA1->BA1_CODEMP,.F.))

					// Posiciona BT5 - Contrato
					BT5->(DbSetOrder(1))
					BT5->(msSeek(xFilial("BT5")+cCodOpe+BA1->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON),.F.))
					
					// Posiciona BQC - Sub-Contrato
					BQC->(DbSetOrder(1))
					BQC->(msSeek(xFilial("BQC")+cCodOpe+BA1->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB),.F.))

					aRetCli := PLSRETNCB(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,BA1->BA1_OPEORI)

					If aRetCli[1]
						
						//"Pessoa Fisica" ira considerar a propria Cooperativa como o TOMADOR
						//por isso branca Cliente/Loja (desde que nao possua CEI)        
						
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
	If  !B15->(msSeek(xFilial("B15")+cCodOpe+cAno+cMes+SubStr(cLote, 7, 4)+cCodRDA+cCliente+cLojaCli,.F.))
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
	
	If B15->(FieldPos("B15_VERBA")) > 0
		B15->B15_VERBA := aSEFIP[nInd, 10]
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

// Abre a transacao...                                            
Begin Transaction

// Seleciona condicao de pagamento - odontologico					
If Len(aSaldo) >= 11 .and. GetNewPar("MV_PLATIOD","0") == '1'  //Indica se o tratamento odontologico esta ativo no ambiente Plano de Saude.
	
	cSQL := " SELECT BZ2_CPAGTO "
	cSQL += "   FROM " + RetSQLName("BZ2")
	cSQL += "  WHERE BZ2_FILIAL =  '" + xFilial("BZ2") + "' AND "
	cSQL += "        BZ2_CODIGO = '" + cCodRDA + "' AND "
	cSQL += "        BZ2_CODINT = '" + cCodOpe + "' AND "
	cSQL += Alltrim(Str(Round(aSaldo[11],0))) + " BETWEEN BZ2_FAIDE AND BZ2_FAIATE AND "
	cSQL += " D_E_L_E_T_ = ' '  "
	
	// Executa query                                                  
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBZ2",.F.,.T.)	 
	
	cCondPag := TrbBZ2->BZ2_CPAGTO
	
	TRBBZ2->(DbCloseArea())

EndIf

// Pagamento com calculo de impostos atraves do financeiro        
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
	
	// necessario para o financeiro nao considerar o e2_valor na base zero                 
	If cTipTitInt == "2"
		nVlrSE2	:= Iif(nVlrFatInt > 0,nVlrFatInt,IIf(nVlrSE2 > 0, nVlrSE2, 0) )
	ElseIf cTipTitInt == "3"		
		nVlrSE2 := Iif(nPosTitInt == 1, nVlrFATNDC, nVlrFATFAT )	 
	ElseIf cTipTitInt == "1"
		nVlrSE2	:= iif(nVlrSE2 < 0, 0, nVlrSE2 )
	EndIf  
	
	cNomForn := Posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ")

	//Com a nova versao do fina050 devemos informar as bases para que o mesmo no execauto faça os calaulos respeitando a natureza.³
	nValorBIR	:= Iif(nValorBIR  <= 0 , 0.001, nValorBIR)
	nValorBPIS	:= Iif(nValorBPIS <= 0 , 0.001, nValorBPIS)
	nValorBCOF	:= Iif(nValorBCOF <= 0 , 0.001, nValorBCOF)
	nValorBCSL	:= Iif(nValorBCSL <= 0 , 0.001, nValorBCSL)
	nValorBINS	:= Iif(nValorBINS <= 0 , 0.001, nValorBINS)
	nValorBISS	:= Iif(nValorBISS <= 0 , 0.001, nValorBISS)

	// se for pessoa juridica, ou se esta usando apenas uma natureza (nao diferencia as bases), ou eh PF mas ja nem tem base mais para a competencia
	// ou está configurado com base única de INSS
	If BAU->BAU_TIPPE == 'J' .or. (nForSE2Lim == 0 .and. nVlrSE2 > 0) .or. BAU->BAU_BASINS == '1' .or.; 
		( cNatPF == cNatPJ .and. cNatPJ == cNatFT .and. cNatFT == cNatHP ) 

		nForSE2Lim := 1

	EndIf
	
	// Define dados para inclusao via rotina automatica...                 
	aBasesImp 	:= {nValorBIR,nValorBCOF,nValorBISS,nValorBCSL,nValorBPIS,nValorBINS,nValorBSES, nVlrSE2}
	aINSSE2		:= { nValorBIN1, nValorBIN2, nValorBIN3, nValorBIN4 }

	SE2->(DbSetOrder(1))
	For nForSE2 := 1 TO nForSE2Lim
		
		If nVlrSE2 <= 0
			Exit
		EndIf
	
		If nForSE2 > 1

			If Empty(cNumero)
				cNumero  := cPLNUME2
            	cNumero  := Eval({|| &cNumero  })           	
            EndIf	

			cParcela := StrZero( nForSE2-1, Len(cParcela) )

			While SE2->(msSeek(xFilial("SE2")+cPrefixo+cNumero+cParcela+cTipo+cCodForn+cLoja,.F.)) .and. nTenta < 200
			
				cNumero := Soma1(cNumero)
			
				// Abre controle de semáforos da numeração do Titulo
				cChaveSem := "PLSMPAG"+cNumero+".SMF"
				nHNumPag  := PLSAbreSem(cChaveSem)

				While nHNumPag == 0
					cNumero  := Soma1(cNumero)	
					nHNumPag := PLSAbreSem(cChaveSem)
				EndDo

				nTenta ++ 
			EndDo
			
			If SE2->(Found())		
				aCritica := {"B","Prefixo+Numero+Parcela+Tipo+Fornecedor+Loja ja existe",0}
				disarmTransaction()
				Return(aCritica)
			EndIf
		EndIf
//1
//Z-0
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
		
		//Como ja estamos enviando para o financeiro as bases de 
		//calculo  dos impostos devemos deixar os campos abaixo por
		//ultimo devido a função do Fina050(FA050Nat2())      
		If nForSE2Lim > 1

			If aINSSE2[1] > 0 .and. nForSE2 == 1

				cNaturez 	:= GetNewPar("MV_PLSNTPF",cNaturez)
				aadd(aCampos,{"E2_BASEINS" , nValorBIN1, NIL})
				aINSSE2[1]	:= 0
				nPosINS		:= 1

			ElseIf aINSSE2[2] > 0 .and. nForSE2 == 2 

				cNaturez 	:= GetNewPar("MV_PLSNTPJ",cNaturez)
				aadd(aCampos,{"E2_BASEINS" , nValorBIN2, NIL})
				aINSSE2[2]	:= 0			
				nPosINS		:= 2

			ElseIf aINSSE2[3] > 0 .and. nForSE2 == 3

				cNaturez 	:= GetNewPar("MV_PLSNTFT",cNaturez)
				aadd(aCampos,{"E2_BASEINS" , nValorBIN3, NIL})
				aINSSE2[3]	:= 0			
				nPosINS		:= 3

			ElseIf aINSSE2[4] > 0 .and. nForSE2 == 4

				cNaturez 	:= GetNewPar("MV_PLSNTHP",cNaturez)
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
			
			aadd(aCampos,{"E2_BASEIRF"	,nValorBIR  ,NIL} )
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
		
		// Grava SE2 - Contas a Pagar                                     
		If ! PLStoSE2(aCampos,,aImpostos,.F.,cCopCre,'PLSMPAG',cCondPag,lUltCalc)
			disarmTransaction()
			Return {"F",STR0061,nVlrSE2}//"Erro na geração dos titulos no financeiro."
		EndIf
		
		// Utilizado para baixa/Compensacao caso tenha debitos
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
			if !empty(BGQ->BGQ_NUMTIT)
				BGQ->(RecLock("BGQ",.F.))
					BGQ->BGQ_PREFIX := cPrefixo			//SE2->E2_PREFIXO
					BGQ->BGQ_NUMTIT := cNumero			//SE2->E2_NUM
					BGQ->BGQ_PARCEL := cParcela			//SE2->E2_PARCELA
					BGQ->BGQ_TIPTIT := cTipo			//SE2->E2_TIPO
				BGQ->(MsUnLock())  
			endif
		Endif
		
		If lAtuaBRJPag 

			BRJ->(DbGoTo(nRecnoBRJ))

			BRJ->(RecLock("BRJ",.F.))
			
			If lAtuaBRJPag

				If BRJ->( FieldPos("BRJ_PREE2N") ) > 0 .AND. BRJ->( FieldPos("BRJ_NUME2N") ) > 0 .AND. BRJ->( FieldPos("BRJ_PARE2N") ) > 0 .AND. BRJ->( FieldPos("BRJ_TIPE2N") ) > 0 .AND. ((cTipTitInt == '3' .And. nPosTitInt == 1) .Or. cTipTitInt == '1')

					BRJ->BRJ_PREE2N := cPrefixo		//SE2->E2_PREFIXO
					BRJ->BRJ_NUME2N := cNumero		//SE2->E2_NUM
					BRJ->BRJ_PARE2N := cParcela		//SE2->E2_PARCELA
					BRJ->BRJ_TIPE2N := cTipo			//SE2->E2_TIPO      
					
					//Realizado tratamento para quando for tipo 3-Ambos, 	  
					//	gerar registro de Contestacao 	 					  				
									
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
				
				// Realizado tratamento para quando for tipo 3-Ambos, 	 
				//	gerar registro de Contestacao 	 					 				
								
				If cTipTitInt == "3" .AND. nPosTitInt == 1   
					BRJ->BRJ_STATUS := "1"								
				Else
					BRJ->BRJ_STATUS := "2"			// No caso se for somente NDC (Ele nao estava atualizando o Status no BRJ)
				EndIf
			Endif
			
			BRJ->(MsUnLock())

		Endif

		// Fecha controle de semáforos da numeração do Titulo
		If nHNumPag > 0
			PLSFechaSem(nHNumPag ,cChaveSem)	
		EndIf
		
	Next nForSE2

//b.	Prestador PF c/cálculo via GPE e geração via GPE: não irá gerar título e não irá gerar pedido de compra (receberá holerite)
ElseIf  cCalcImp == "4" 
//Pode parecer só mais um 'if, não faz nada', mas como tem um else lá embaixo, ele ficou aqui pras coisas continuarem caindo onde devem..

//c.Prestador PJ c/cálculo via FIN: não irá gerar título e irá gerar pedido de compra com base de impostos 
// (prestador emitirá NF conforme relatório fornecido via pedido de compra)
ElseIf  cCalcImp == "1" .and.  (BAU->BAU_TIPPE == 'J' .OR. GetNewPar("MV_PLPFFIN",.F.) == .T.) 

	If aSaldo[1]
		
		//Verificando o grupo de compras
		aGrupo := UsrGrComp(cCodUsr)

		If Len(aGrupo) > 0
			cGrupCom := aGrupo[1]
		Else	
			cGrupCom := ""
		Endif
		
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
		aTESPROD := {}

		For i:=1 to len(aSaldo[5])
			nPrcSld  := 0 
			//Acumulo os Debitos
			If aSaldo[5,i,1] == "1"
				nDescC7	+= aSaldo[5,i,2]
				Loop
			Elseif aSaldo[5,i,1] == "2"
				nPrcSld := aSaldo[5,i,2]
				nTotPedido += nPrcSld
			else//lançamentos do tipo Base não são considerados
				Loop
			EndIf

			cProduto := Iif(!Empty(aSaldo[5,i,8]),aSaldo[5,i,8],MV_PAR36)
			cTesAux := Iif(!Empty(aSaldo[5,i,9]),aSaldo[5,i,9],MV_PAR38)

			nTESProd := aScan(aTESPROD, {|x| x[1] == cProduto .AND. x[2] == cTesAux})
			If (EmpTy(aTESPROD)) .OR. nTESProd == 0
				aAdd(aItens,{	{"C7_ITEM"		,StrZero(Len(aItens) + 1,4),Nil},; //1
						{"C7_PRODUTO"	,cProduto			,Nil},;  //2
						{"C7_QUANT"		,1					,Nil},;  //3
						{"C7_PRECO"		,nPrcSld			,Nil},;  //4
						{"C7_TOTAL"		,nPrcSld			,Nil},;  //5
						{"C7_DATPRF"	,dDataBase			,Nil},;  //6
						{"C7_TES"		,cTesAux			,Nil},;  //7
						{"C7_FLUXO"		,"S"				,Nil},;  //8
						{"C7_LOCAL"		,"01"				,Nil},;  //9
						{"C7_ORIGEM"    ,"PLSMPAG"  		,nil},;  //10
						{"C7_CODRDA"	,cCodRda			,Nil},;  //11
						{"C7_LOTPLS"	,cLotPcPls			,Nil},;  //12
						{"C7_USER"		,cCodUsr			,Nil},;  //13
						{"C7_GRUPCOM"	,cGrupCom			,Nil},;  //14
						{"C7_FORNECE"	,cCodForn		    ,NiL},;  //15
						{"C7_PLOPELT"	,cOpeLote			,Nil}})  //16

				aadd(aTESPROD, { cProduto, cTesAux, Len(aItens), {aSaldo[5,i,3]} })
			else
				aItens[nTESProd][4][2] += nPrcSld
				aItens[nTESProd][5][2] += nPrcSld
				aadd(aTESPROD[nTESProd][4], aSaldo[5,i,3])
			endIf
		Next i
		nTESProd := 0
		nVlrDebVar := nDescC7
	
	Endif

// Pagamento com calculo de impostos atraves da integracao com a folha
// de forma automatica, sem ter que entrar no modulo SIGAGPE      

// cCalcImp == '3' OU ( cCalcImp == '1' .and. MV_PLPFFIN == .F.  .AND. BAU->BAU_TIPPE <> 'J' )
// ==> calcula pelo módulo GPE e gera títulos no módulo FIN
Else	 

	nForSE2Lim	:= 1		
	nVlrSE2 	:= nVlrDebVar := nVlrIr := nVlrImp := 0
	nValorBIR	:= nValorBINS := nValorBIN1 := nValorBIN2 := nValorBIN3 := nValorBIN4 := nInsOutEmp := 0
	
	for nImp := 1 to Len(aCompPag)
		nVlrSE2		+= iif(aCompPag[nImp,1]== "2", aCompPag[nImp,2], 0 )
		nVlrDebVar	+= iif(aCompPag[nImp,1]== "1", aCompPag[nImp,2], 0 )
	next
	
	// Verifica se deve calcular impostos                .            
	
	//1 - pagamento unico no mes 
	//3 - Varios pagamentos no Mes com provisao de INSS 
	//4 - Varios pagamentos no Mes sem provissao
//	if  GetNewPar("MV_PLPGUNI","1") $ "1,3,4"  
		
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
		
		// Se existe "Sal Contrib Out Empresas" ja gravado no BMR e nao encontrou no BGQ (CODLAN = 170),
		// atualiza variavel "nInsOutEmp" com o conteudo de aImpMes[1] = "Sal Contrib Out Empresas" 
		
		if aImpMes[1] > 0 .And. nInsOutEmp == 0
			nInsOutEmp := aImpMes[1]
		endIf
		
		// Retorna o valor dos impostos
		aRetImp := PLSINTGPE(.F.,cCodRda,cAno,cMes,aVerbas,cOpeLote,cLote,cNaturez,cCodForn,cLoja,cHisTit,/*nValorBIR*/,nValorBIN1,nValorBIN2,nInsOutEmp,lAutonomo,dVencto,aImpMes,lUltCalc,nVrIRRet,nValorBIN3,lPgtoImp,aCompPag,getNewPar("MV_PLPGUNI","1") == "4",cNumero,lHist,,nValorBIN4,nValorBINS)
//A posição 1 é o IR
//A posição 2 é o INSS
		// Atualiza valor da base do IR caso tenha atualizado na função PLSINTGPE 
		nPos     	:= Ascan(aCompPag,{|x| x[3]== "198"})  // Base IR
		nValorBIR 	:= If( nPos > 0, aCompPag[nPos,2], nValorBIR )
	
		// Aglutina impostos
		nVlrIr	:= aRetImp[1]
		nVlrImp	:= aRetImp[1]+aRetImp[2]
		
//	else
//		aRetImp := {0,0,.F.,''}
//	endIf
		
	if aRetImp[2] > 0 // INSS
		lSoINSS := .F.
	endIf     
	
	// necessario para o financeiro nao considerar o e2_valor na base zero                 
	nVlrSE2 := iif(nVlrSE2<0,0,nVlrSE2)
	
	// Guarda o tipo do titulo que deve ser considerado para geracao dos impostos
	cTipoTit := cTipo	
	
	//Z-0 - criação do título principal, traz a base de IR e INSS, mas somente desse título OK
	// Define dados para inclusao via rotina automatica...            
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
					{"E2_PLLOTE"  	,cLote          	,NIL},;
					{"E2_PLOPELT" 	,cOpeLote       	,NIL},;
					{"E2_CODRDA"  	,cCodRda        	,NIL},;
					{"E2_ANOBASE" 	,cAno           	,NIL},;
					{"E2_MESBASE" 	,cMes           	,NIL},;
					{"E2_DESDOBR"	,"N"				,NIL},;
					{"E2_DIRF" 		,"1"				,NIL},;
					{"E2_HIST" 		,cHisTit			,NIL},;
					{"E2_PARCIR"  	,strzero(1,TamSx3("E2_PARCIR")[1]),NIL},;
					{"E2_PARCINS" 	,strzero(1,TamSx3("E2_PARCINS")[1]),NIL},;
					{"E2_BASEIRF" 	,nValorBIR			,NIL},;
					{"E2_BASEPIS" 	,0					,NIL},;
					{"E2_BASECOF" 	,0					,NIL},;
					{"E2_BASECSL" 	,0					,NIL}}	

	if  SE2->(FieldPos("E2_BASEINS")) > 0 

		If cPaisLoc == "BRA" //.AND.  SA2->A2_CALCIRF == "2"	
			aadd(aCampos,{"E2_BASEINS", nValorBINS+nValorBIN1+nValorBIN2+nValorBIN3+nValorBIN4, NIL})
		else
			aadd(aCampos,{"E2_BASEINS", 0, NIL})
		EndIf

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
	
	//Como ja estamos enviando para o financeiro as bases de 
	//calculo  dos impostos devemos deixar os campos abaixo por     
	//ultimo devido a função do no Fina050(FA050Nat2())      
	
	aadd(aCampos,{"E2_NATUREZ" 	,cNaturez	,NIL})
	aadd(aCampos,{"E2_MOEDA" 	,01			,NIL})
	aadd(aCampos,{"E2_VALOR" 	,nVlrSE2 	,NIL})
	aadd(aCampos,{"E2_SALDO" 	,nVlrSE2 	,NIL})
	aadd(aCampos,{"E2_VLCRUZ" 	,nVlrSE2 	,NIL})
	aadd(aCampos,{"E2_INSS", aRetImp[2], NIL})
	aadd(aCampos,{"E2_IRRF", aRetImp[1], NIL})

	SED->( msSeek(xFilial("SED")+cNaturez) )
	If SED->ED_CALCIRF == 'S' .OR. SED->ED_CALCINS == 'S'
		disarmTransaction()
		return {"L","Natureza para P.F. nao deve calcular IR e INSS",nVlrSE2}//"Erro na geração dos titulos no financeiro."
	EndIf 
	
	// 1-nValorIR ,2-nValorCOF ,3-nValorISS ,4-nValorCSL ,5-nValorPIS ,6-nValorINS ,7-nValorSES
	aImpostos := {aRetImp[1],0,0,0,0,aRetImp[2],0}
	
	// Grava SE2 - Contas a Pagar                                     
	If nVlrSE2 > 0 .AND. !aSaldo[19]
	
		If !PLStoSE2(aCampos,,aImpostos,.F.,cCopCre,'PLSMPAG',cCondPag,lUltCalc)
			disarmTransaction()
			return {"F",STR0061,nVlrSE2}//"Erro na geração dos titulos no financeiro."
		EndIf
					
		// Utilizado para baixa/Compensacao caso tenha debitos
		Aadd(aRecnoDP, SE2->(recno()) )

	EndIf
	
	if lCriadoBGQAut

		BGQ->(DbGoTo(nRecnoBGQ))
		if !empty(BGQ->BGQ_NUMTIT)	
			BGQ->(RecLock("BGQ",.F.))
				BGQ->BGQ_PREFIX := SE2->E2_PREFIXO
				BGQ->BGQ_NUMTIT := SE2->E2_NUM
				BGQ->BGQ_PARCEL := SE2->E2_PARCELA
				BGQ->BGQ_TIPTIT := SE2->E2_TIPO
			BGQ->(MsUnLock())     
		endIf
	endIf
	
	if lAtuaBRJPag 

		BRJ->(DbGoTo(nRecnoBRJ))
		BRJ->(RecLock("BRJ",.F.))  		

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
			
			// Realizado tratamento para quando for tipo 3-Ambos, 	 
			//	gerar registro de Contestacao 	 					 				
				  
			if cTipTitInt == "3" .AND. nPosTitInt == 1	
				BRJ->BRJ_STATUS := "1"								
			else						
				BRJ->BRJ_STATUS := "2"
			endIf

		endIf

		BRJ->(MsUnLock())
	endIf

endif

// Grava BMR - Composicao do Pagamento                            
if  lOK

	nVlrImp := 0
	
	// So tem valor quando e pagamento pelo financeiro pois pela folha ainda nao registrou os impostos
	
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
		nVlrIr	+= nValImp
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
	
	// Financeiro e pela folha
	for nFor := 1 to len(aCompPag)
		If aCompPag[nFor,3] == "170"
			If !(Chk170(cCodOpe, cCodRda, cAno, cMes))
				Loop
			endIf
		endIf
		aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),aCompPag[nFor,3],aCompPag[nFor,2],aCompPag[nFor,1],IIf(aCompPag[nFor,3]$'182/192/194/196/167',cAno,StrZero(Year(dVencto),4)),IIf(aCompPag[nFor,3]$'182/192/194/196/167',cMes,StrZero(Month(dVencto),2))}
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)
	next
	
	If Len(aSaldo[18]) > 0
		For nFor := 1 To Len(aSaldo[18])
			aBMR:={cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),aSaldo[18][nFor][3],aSaldo[18][nFor][2],aSaldo[18][nFor][1],IIf(aSaldo[18][nFor][3]$'182/192/194/196/167',cAno,StrZero(Year(dVencto),4)),IIf(aSaldo[18][nFor][3]$'182/192/194/196/167',cMes,StrZero(Month(dVencto),2))}
			GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)	
		Next
	endIf
	
	// Grava BMS - Composicao do Pagamento p/ contabilidade           
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

//Integração PLS x GPE - Geração da RGB
If cCalcImp == "4" 

	For nCaLimp4 := 1 To Len(aSaldo[20])

		SRA->(dbSetOrder(1))
		SRA->(MsSeek(xFilial('SRA')+ aSaldo[20][nCaLimp4][3]))	

		cCusto 		:= SRA->RA_CC
		cProcesso 	:= SRA->RA_PROCES 
		aPerAtual	:= {}
		cRoteiro	:= "AUT"
		
		If Empty(cCusto)
			lOk := .F.
			aCritica := {"Z","Informar no Cadastro de Funcionários, o Centro de Custo do Prestador [ " + BAU->BAU_CODIGO + " ] ",0}
		EndIf	                                                                                  
		
		If Empty(cProcesso)
			lOk := .F.
			aCritica := {"Z","Informar no Cadastro de Funcionários, o Codigo do Processo, campo RA_PROCESS, do Prestador [ " + BAU->BAU_CODIGO + " ] ",0}
		Else
			
			// encontra o periodo e verifica se esta ativo 
			If fGetPerAtual(@aPerAtual, xFilial("RCH"), cProcesso, cRoteiro) 
		
				cPeriodo:= aPerAtual[1][1]
				cSemana	:= aPerAtual[1][2]
				dData 	:= aPerAtual[1][7] 

				// verifica se o período não se encontra bloqueado 
				If fVldAccess(SRA->RA_FILIAL, dData, cSemana,.F., cRoteiro, "3", "V") 
				
					nVlrRGB += aSaldo[20][nCaLimp4][2]

					nIndice:= RetOrder("RGB", "RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEMANA+RGB_SEQ")
				
					RGB->(DbSetOrder(nIndice))
				
					RegToMemory('RGB',.T.)		
					M->RGB_FILIAL := xFilial('RGB')             
					M->RGB_MAT    := aSaldo[20][nCaLimp4][3]
					M->RGB_PD     := aSaldo[20][nCaLimp4][1]
					M->RGB_CC     := cCusto
					M->RGB_TIPO1  := 'V'
					M->RGB_TIPO2  := 'G'
					M->RGB_VALOR  := aSaldo[20][nCaLimp4][2]
					M->RGB_PERIOD := cPeriodo 
					M->RGB_ROTEIR := cRoteiro
					M->RGB_PROCES := cProcesso
					M->RGB_SEMANA := cSemana 
					M->RGB_CODRDA := cCodRDA
					M->RGB_LOTPLS := cLote
					
					If RGB->(MsSeek(xFilial('RGB')+aSaldo[20][nCaLimp4][3]+aSaldo[20][nCaLimp4][1]+cCusto))
						If alltrim(RGB->RGB_LOTPLS) == alltrim(cLote)
							RecLock('RGB',.F.)
						elseIf Val(RGB->RGB_SEQ) < 9   //Tem validação no campo, só pode ir até 9
							M->RGB_SEQ := Soma1(RGB->RGB_SEQ)
							RecLock('RGB',.T.)
						else
							RecLock('RGB',.F.)
						endIf
					else
						RecLock('RGB',.T.)	
					EndIf    
										
					For nCont:= 1 To FCount()

					   	If 'RGB_VALOR' $ Field( nCont )
					      RGB->RGB_VALOR += M->RGB_VALOR
					  	Else
							FieldPut( nCont, M->&( Eval( bCampo,nCont ) ) )
						EndIf	

					Next 

					RGB->(MsUnLock())
					lOk := .T.
				Else
					lOk := .F.
					aCritica := {"Z","Período se encontra bloqueado",0}
				Endif
			
			Else
				lOk := .F.
				aCritica := {"Z","Período não está cadastrado ou já foi fechado",0}
			Endif
						
		Endif
	Next

endIf

if lOk .and. ! lAneste
	
	cChkSE2 := SE2->( E2_FILIAL+'|'+E2_PREFIXO+'|'+E2_NUM+'|'+E2_PARCELA+'|'+E2_TIPO+'|'+E2_FORNECE+'|'+E2_LOJA )
	
	//Aponta dados sobre o pagamento que acabou de ser feito... 
	PLSATUVINP( cLote, cOpeLote, cCodOpe, cLocDigIn, cLocDigFi, cCodPegIn, cCodPegFi, cNumMovIn, cNumMovFi,;
				dDatMvIni, dDatMvFin, cCodRDA, cAno, cMes, "1", dVencto, cCdEmpDeS, cCdEmpAteS, cExcessao,;
				cCodDC, lGuiCob, cLoteImp, lSoINSS, cExcPeg, iIf(cCalcImp $ "2,3", cChkSE2 ,nil), aSaldo[21])
				
endIf

//A geração do pedido de compra foi alterado para depois da função PLSATUVINP 
//pois estava travando outros usuarios ao utilizar nota fisca de entarda do modulo de compras.
//Gravacao do pedido de compra
If Len(aItens)>0 .And. nTotPedido > nDescC7

	If lPLSPGSC7
		aRetPtoEnt := ExecBlock("PLSPGSC7",.F.,.F.,{aCab,aItens,aSaldo,nDescC7})
		If Valtype(aRetPtoEnt) == "A"
			aCab		:= aRetPtoEnt[1]
			aItens		:= aRetPtoEnt[2]
			aSaldo		:= aRetPtoEnt[3]
			nVlrDebVar 	:= aRetPtoEnt[4]
		Endif
	Endif
				
	lMsHelpAuto := .T.
	lMsErroAuto := .F.
	
	MsExecAuto({|X,Y,Z,W| MATA120(X,Y,Z,W)},1, aCab, aItens, 3)
			
	SC7->(ConfirmSX8())

	If lMsErroAuto //SE HOUVE ERRO
		lOK:=.F.
		MostraErro()
		disarmtransaction()
		return {"F","Erro na geraçãodo pedido de compras",0}
	Endif
			
	// ATUALIZANDO O GRUPO DE COMPRAS
	If lOK .and. ! Empty(cGrupCom)
		SC7->(Reclock("SC7",.F.))
		SC7->C7_GRUPCOM := cGrupCom
		SC7->(MsUnlock())
	Endif

	If lBMR_SC7ITE
		If BMR->(IndexOrd()) <> 1
			BMR->(dbsetOrder(1))
		endIf
		For nSC7Ite := 1 To Len(aTESPROD)
		//aTESPROD
			//"BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN"
			For nO := 1 To Len(aTESPROD[nSC7ITE][4])
				If BMR->(MsSeek(xfilial("BMR") + cCodOpe + cCodRDA + cOpeLote + cLote + aTESPROD[nSC7ITE][4][nO]))
					BMR->(RecLock("BMR", .F.))
						BMR->BMR_SC7ITE := StrZero(aTESPROD[nSC7ITE][3], 4)
					BMR->(MsUnLock())
				endIf
			Next
		next
	endIf
Endif

//Atualizar A TABELA B15            
If (lUltCalc .and. GetNewPar("MV_PLPGUNI","1") == "3" ) .Or. GetNewPar("MV_PLPGUNI","1") $ "1,4"
	PLSB15_IMP(cOpeLote, cAno, cMes, cCodRDA)
EndIf

//Realizo a baixa do titulo principal e em seguida realizo a³
//geracao da NDF, quando o saldo do prestador for negativo.

//Z-0 Geração NDF aqui
If nVlrDebVar > 0 .AND. ( Empty(cLoteImp) .or. nPosTitInt < 2 ) 
	
	// Define dados para inclusao via rotina automatica...            
	aCampos :=	{	{"E2_FILIAL"	,xFilial("SE2")	,NIL},;
					{"E2_PREFIXO"	,cPrefixo       ,Nil},;
					{"E2_NUM"		,cNumero        ,Nil},;
					{"E2_PARCELA"	,cParcela       ,Nil},;
					{"E2_TIPO"		,"NDF"          ,Nil},;
					{"E2_FORNECE"	,cCodForn       ,Nil},;
					{"E2_LOJA"		,cLoja          ,Nil},;
					{"E2_NOMFOR" 	,posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"),Nil},;
					{"E2_EMISSAO"	,iif(AllTrim(cTipo)=="PA",dVencto,dDataBase)	,NIL},;
					{"E2_EMIS1"  	,iif(AllTrim(cTipo)=="PA",dVencto,dDataBase)	,NIL},;
					{"E2_VENCTO"	,dVencto        	,NIL},;
					{"E2_VENCREA"	,DataValida(dVencto),NIL},;
					{"E2_VENCORI" 	,dVencto        	,NIL},;
					{"E2_DECRESC" 	,0					,NIL},;
					{"E2_ACRESC"  	,0					,NIL},;
					{"E2_PLLOTE"  	,cLote          	,NIL},;
					{"E2_PLOPELT" 	,cOpeLote       	,NIL},;
					{"E2_CODRDA"  	,cCodRda        	,NIL},;
					{"E2_ANOBASE" 	,cAno           	,NIL},;
					{"E2_MESBASE" 	,cMes           	,NIL},;
					{"E2_INSS"   	,0 			      	,NIL},;
					{"E2_ISS"    	,0             		,NIL},;
					{"E2_CSLL"   	,0             		,NIL},;
					{"E2_COFINS" 	,0             		,NIL},;
					{"E2_PIS"    	,0             		,NIL},;
					{"E2_IRRF"   	,0					,NIL},;					
					{"E2_BASEIRF" 	,nVlrDebVar			,NIL},;
					{"E2_BASEPIS" 	,nVlrDebVar			,NIL},;
					{"E2_BASECOF" 	,nVlrDebVar			,NIL},;
					{"E2_BASECSL" 	,nVlrDebVar			,NIL}}

	// Compatibilização ao ultimo FINA050
	If  SE2->(FieldPos("E2_BASEINS")) > 0
		aadd(aCampos,{"E2_BASEINS", nVlrDebVar, NIL})
	EndIf
	If  SE2->(FieldPos("E2_BASEISS")) > 0
		aadd(aCampos,{"E2_BASEISS", nVlrDebVar, NIL})
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
	aadd(aCampos,{"E2_HIST" 	,cHisTit	,NIL})
	aadd(aCampos,{"E2_DATAAGE" 	,DataValida(dVencto)	,NIL})
	aadd(aCampos,{"E2_ORIGEM"	,"PLSMPAG"	,NIL})
	
	//Natureza
	If GetNewPar('MV_PLNATPF','1')=='1'
		cNaturez := GetNewPar('MV_PLNTNDF','')
		cNaturez += Space( TamSx3("E2_NATUREZ")[1] - Len(cNaturez) )
	endIf	

	//Como ja estamos enviando para o financeiro as bases de
	//calculo  dos impostos devemos deixar a natureza por   
	//ultimo devido a função do no Fina050(FA050Nat2()) 
	aadd(aCampos,{"E2_NATUREZ" 	,cNaturez	,NIL})
	aadd(aCampos,{"E2_MOEDA" 	,01	,NIL})
	aadd(aCampos,{"E2_VALOR" 	,nVlrDebVar	,NIL})
	aadd(aCampos,{"E2_SALDO" 	,nVlrDebVar	,NIL})
	aadd(aCampos,{"E2_VLCRUZ" 	,nVlrDebVar	,NIL})
	
	// 1-nValorIR ,2-nValorCOF ,3-nValorISS ,4-nValorCSL ,5-nValorPIS ,6-nValorINS ,7-nValorSES
	aImpostos := {0,0,0,0,0,0,0} 
	
	if B19->(fieldPos("B19_SEQIMP")) > 0
		B19->(DBSetOrder(4))
		if !empty(cLoteImp) .and. B19->(DbSeek(xFilial("B19") + "BRJ"+cLoteImp))
			cOrigem:="A500NF"
			B19->(dbclosearea())
		endif
	endif

	// Grava SE2 - Contas a Pagar                                     
	If !PLStoSE2(aCampos,,aImpostos,.t.,cCopCre,cOrigem,cCondPag,lUltCalc)
		disarmTransaction()
		return {"F",STR0061,nVlrSE2}//"Erro na geração dos titulos no financeiro."
	EndIf
	
	//atualiza o numero do titulos de NDF nos debitos
	cSql := " UPDATE " + retSQLName("BGQ")
	cSql += "    SET BGQ_PREFIX  = '" + SE2->E2_PREFIXO + "', "
	cSql += "        BGQ_NUMTIT  = '" + SE2->E2_NUM  	+ "', "
	cSql += "        BGQ_PARCEL  = '" + SE2->E2_PARCELA + "', "
	cSql += "   	 BGQ_TIPTIT  = '" + SE2->E2_TIPO    + "' "

	cSql += "   WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' "
	cSQL += "     AND BGQ_CODIGO = '" + cCodRDA + "' "
	cSQL += "     AND BGQ_CODOPE = '" + cCodOpe + "' "
	cSql += "     AND BGQ_OPELOT = '" + cOpeLote + "' "
	cSql += "     AND BGQ_NUMLOT = '" + cLote + "' "
	cSql += "     AND BGQ_TIPO   = '1' " //Débito
	cSQL += "     AND BGQ_ATIVO  <> '0' "
	cSql += "     AND BGQ_NUMTIT = '         ' "
	cSql += "     AND " + retSQLName("BGQ") + ".D_E_L_E_T_ = ' ' "

	if ( tcSqlExec( cSql ) ) < 0
		FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01',"Erro na execução do update PLSTITPF -> [ " + tcSqlERROR() + "]" , 0, 0, {})
	elseIf allTrim( TCGetDB() ) == "ORACLE"
		TCSQLExec("COMMIT")
	endIf


	// Compensacao automatica do titulo
	if empty(cLoteImp)
		for nVez := 1 to Len(aRecnoDP)
			PLNDF103(aRecnoDP[nVez])
		Next
	endif

EndIf

End Transaction

// Refaz dados salvos...                                          
SA2->(DbSetOrder(nOrdSA2))
SA2->(DbGoTo(nRecSA2))

BAU->(DbSetOrder(nOrdBAU))
BAU->(DbGoTo(nRecBAU))

// Monta retorno da funcao...                                     
If len(aCritica) == 0 .and. lOK 

    If nVlrSE2 > 0 .or. !GetNewPar("MV_PLFORGE",.F.) .or. nVlrDebVar > 0 .Or. nTotPedido > 0 .OR. nVlrRGB > 0

        If nVlrSE2 > 0
            aCritica := {"1","Titulo gerado com sucesso", nVlrSE2}
        elseif nVlrDebVar > 0
            aCritica := {"1","NDF gerado com sucesso", nVlrDebVar}
        elseif nTotPedido > 0
            aCritica := {"1","Pedido de compra gerado com sucesso", nTotPedido}
        elseIf nVlrRGB > 0
            aCritica := {"1","Lançamentos gerados na folha de pagamento", nVlrRGB}
        EndIf        

    Else
        aCritica := {"7","Nao houve saldo neste Ano/Mes",0}
    EndIf

Endif    

Aadd(aCritica,aSaldo)//04
Aadd(aCritica,nVlrDebVar+nVlrImp)//05
Aadd(aCritica,nVlrIr)//06

Return(aCritica)

/*/{Protheus.doc} PLSVALPAG
Retorna o valor de pagamento a uma rede de atendimento

@author  PLS TEAM
@version P12
@since   21.03.17
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
LOCAL bOK      := { || oDlg:End() }
LOCAL oGrupo
LOCAL nTotCre  := 0
LOCAL nTotDeb  := 0
LOCAL nTotal   := 0
LOCAL cTipo       := ""
LOCAL aButtons := { }
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
LOCAL aArea		  := GetArea()
LOCAL lAneste      	:= .F.
Local lPLSUni		:= GetNewPar("MV_PLSUNI", "0") == "1"
Local cTipTitInt	:= ""

DEFAULT cFunCha 	:= ""

//Nome da Enchoice
cCadastro := "Produção do Prestador - "+mv_par01+"/"+mv_par02


// Se a funcao chamadora for "PLSA470" (Botao "Saldo Posicionado"), nao
// chama tela de parametros e aproveita os parametros ja informados.   

If cFunCha == "PLSA470"  
	
	If !EMPTY(cProcDe) .OR. !EMPTY(cProcate)
		cAno       := mv_par01
	   	cMes       := mv_par02
		dDatMvIni  := mv_par06
		dDatMvFin  := mv_par07 
	   	cCodOpe    := mv_par14
	   	cLocDigIn  := space(TamSx3("BD7_CODLDP")[1])
	  	cLocDigFi  := "ZZZZ"
	  	cNumMovIn  := space(TamSx3("BD7_NUMERO")[1])
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
	
	// Busca dados dos parametros pelo usuario...                     
	
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

If !(empty(cLoteImp)) .AND. lPLSUni
	cTipTitInt := "2"
EndIf

// Executa funcao que retornara composicao de cobranca...         
cCalcImp := IF(BAU->(FieldPos("BAU_CALIMP"))>0,BAU->BAU_CALIMP,"2")

aValor := PLSLDCRE(BAU->BAU_CODIGO,cAno,cMes,dDatMvIni,dDatMvFin,cLocDigIn,cLocDigFi,;
					cCodPegIn,cCodPegFi,cNumMovIn,cNumMovFi,cCodOpe,BAU->BAU_CODSA2,;
					BAU->BAU_LOJSA2,/*aLancPagto*/,cCalcImp,cCdEmpDeS,cCdEmpAteS,cExcessao,cLoteImp,;
					cPagCod,.F.,cCodNat,lGuiCob,/*lPgtDiv*/,/*lGerLot*/,/*lMudUs*/,/*nNewUs*/,/*nApUsDif*/,/*lAtuGui*/,;
           			/*cOpeLote*/,/*cLote*/,/*dVencto*/,cExcPeg,cTipTitInt,,cNoExcPeg,lAneste)

// Trata uma possivel nao-conformidade na rotina...               
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

// Posiciona nos arquivos utilizados...                           

BA0->(DbSetOrder(1))
BA0->(msSeek(xFilial("BA0")+cCodOpe,.F.))

//Ponto de Entrada para permite acrescentar botoes na Tela Valor de Producao³

If (ExistBlock( "PLPGBUT" ) )
	aADDButtons:=ExecBlock("PLPGBUT",.F.,.F.)
	If ValType(aADDButtons) == "A"
		For i:=1 to Len(aADDButtons)
			AADD(aButtons,aADDButtons[i])
		Next i
	EndIf
Endif

// Monta dialogo com usuario...                                   

DEFINE MSDIALOG oDlg TITLE "Producao da Rede de Atendimento  -   "+cAno+" / "+cMes   FROM 007.2,010.3 TO 035.4,109.3 OF GetWndDefault()

// Define folder...                                               

@ 030,005 FOLDER oFolder SIZE 196,177 OF oDlg  PIXEL	PROMPTS	"Lancamentos de Pagamento","Verbas X Valores (Int. Folha)"

// Monta says...                                                  

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


// Monta objeto tree...                                           

oTree := DbTree():New(005,005,157,187,oFolder:aDialogs[1],nil,nil,.T.,nil)
oTree:BuildTrb(100, 2)
oTree:BeginUpdate()
oTree:SetEnable()

// Monta objeto tree...                                           

oTreeVerba := DbTree():New(005,005,157,187,oFolder:aDialogs[2],nil,nil,.T.,nil)
oTreeVerba:BuildTrb(100, 2)
oTreeVerba:BeginUpdate()
oTreeVerba:SetEnable()

// Monta dados da composicao de cobranca...                       

For nInd := 1 To Len(aValor[2])
	oTree:AddTree(aValor[2,nInd,3]+" - "+AllTrim(aValor[2,nInd,4]) + " - "+TransForm(aValor[2,nInd,2],PLPMONEY_G),nil,AllTrim(aValor[2,nInd,5]),AllTrim(aValor[2,nInd,5]),nil)
	oTree:EndTree()
Next
oTree:EndUpdate()

// Monta dados das verbas...                                      

For nInd := 1 To Len(aValor[3])
	oTreeVerba:AddTree(aValor[3,nInd,1]+" - "+aValor[3,nInd,3]+ " - "+TransForm(aValor[3,nInd,2],PLPMONEY_G),nil,"GROUP","GROUP",nil)
	oTreeVerba:EndTree()
Next
oTreeVerba:EndUpdate()

// Monta totalizadores...                                         

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

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()			

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bOK,.F.,aButtons)

Eval(bRest)
RestArea(aArea)

Return

/*/{Protheus.doc} PLSATUVINP
Aponta dados apos efetuar pagamento a uma RDA
@type function
@author PLSTEAM
@since 26.12.16
@version 1.0
/*/
function PLSATUVINP(cLote, cOpeLote, cCodOpe, cLocDigIn, cLocDigFi, cCodPegIn, cCodPegFi, cNumMovIn,;
					cNumMovFi, dDatMvIni, dDatMvFin, cCodRDA, cAno, cMes, cTipoUpt, dVencto, cCdEmpDeS,;
					cCdEmpAteS, cExcessao, cCodDC, lGuiCob, cLoteImp, lSoINSS, cExcPeg, cChkSE2, aRecBD7)
local cChaveGui    	:= ""
local cChaveAux		:= ""
local cChavePeg		:= ""
local cSQL			:= ""
local cNroPgt		:= ""
local cCod170		:= ""
local cAlias		:= ""
local nI			:= 0
local lObrPto  	   	:= .f.
local lINSSOutEmpBGQ:= .f.
local lBBB_INCISS 	:= BBB->(fieldPos("BBB_INCISS")) > 0
local lBGQ_INCISS 	:= BGQ->(fieldPos("BGQ_INCISS")) > 0
local lBD7_CHKSE2	:= BD7->(fieldPos("BD7_CHKSE2")) > 0
local lPLPABD7      := existblock("PLPAGBD7")
local lPLMPALAN 	:= existblock("PLMPALAN")
local lMV_PLSHAT	:= getNewPar("MV_PLSHAT","0") == "1"
local lCposVld	   	:= (BBC->(fieldPos("BBC_VLDINI")) > 0 .and. BBC->(fieldPos("BBC_VLDFIM")) > 0)
local aMatTIT       := {}
local aPegs		 	:= {}

default cCdEmpDeS  	:= ""
default cCdEmpAteS 	:= ""
default cExcessao  	:= ""
default cCodDC     	:= ""
default lGuiCob    	:= .F.
default lSoINSS    	:= .F.
default cLoteImp   	:= ""
default cCodRDA    	:= ""
default cExcPeg	   	:= ""
default cChkSE2		:= ""

//verifica qual banco de dados
getTpDB(@__lOracle)

if ! empty(cChkSE2)
    aMatTIT := strTokArr2( cChkSE2, "|" )
endIf

BBB->(dbSetOrder(1))//BBB_FILIAL+BBB_CODSER                                                                                                                                           
BAU->(dbSetOrder(1))//BAU_FILIAL+BAU_CODIGO                                                                                                                                           
BCI->(dbSetOrder(1))//BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC                                                                                                 
BD5->(dbSetOrder(4))//BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_FASE+BD5_SITUAC
BE4->(dbSetOrder(13))//BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_FASE+BE4_SITUAC

if  ! empty(cCodDC)

	cCodDC := allTrim(cCodDC)

	if  right(cCodDC,1) == ","
		cCodDC := left(cCodDC,len(cCodDC)-1)
	endIf

	cCodDC := "('" + strTran(cCodDC,",","','") + "')"

endIf

//Trata a obrigatoriedade de gerar protocolo web ou não.              
lObrPto := PLSOBRPRDA() 

//cTipoUpt "1" - Atualizar o Lote, "2" - Limpar o lote
if  cTipoUpt == "1"

	for nI := 1 to len(aRecBD7)

		BD7->( dbGoto(aRecBD7[nI]) )
		
		BD7->( recLock("BD7", .f.) )
			BD7->BD7_NUMLOT := cLote
			BD7->BD7_OPELOT := cOpeLote
			BD7->BD7_RECSIP := ""
			
			if lBD7_CHKSE2
				BD7->BD7_CHKSE2 := cChkSE2
			endIf
			
			BD7->BD7_FASE   := "4"
			BD7->BD7_DTGRCP := dVencto
			BD7->BD7_DTPAGT := dDataBase
		BD7->( msUnLock() )

		cChaveGui := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)
		
		if lPLPABD7
			execBlock("PLPAGBD7", .f., .f., { cChaveGui } )
		endIf
		
		if cChaveAux <> cChaveGui
			
			cChaveAux := cChaveGui

			cAlias := PLSRALCTM(BD7->BD7_TIPGUI)

			if aScan(aPegs, {|x| x[2] == BD7->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG)}) == 0
				aadd(aPegs, { cAlias, BD7->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG) } )
			endIf	
		
		endIf

	next

	if len(aPegs) > 0

		atualizaGuiaPagto(cTipoUpt, cCodRDA, cLote, cOpeLote, cCodOpe, __lOracle)
		
		for nI := 1 to len(aPegs)
			
			cAlias 	  := aPegs[nI, 1]
			cChavePeg := aPegs[nI, 2]
			
			//atualiza o status do peg verificando cabecalho da guia
			if  (cAlias)->( msSeek( xFilial(cAlias) + cChavePeg + '31' ) ) .or.;
				(cAlias)->( msSeek( xFilial(cAlias) + cChavePeg + '21' ) ) .or.;
				(cAlias)->( msSeek( xFilial(cAlias) + cChavePeg + '11' ) )

				loop

			endIf

			if BCI->( msSeek( xFilial("BCI") + cChavePeg ) )

				nRecBCIZ := BCI->(recno())

				BCI->(recLock("BCI",.f.)) 
					BCI->BCI_FASE := '4'
				BCI->(MsUnLock())
				
				//a integracao esta fazendo a mesma coisa na geracao e na exclusao do lote
				if nRecBCIZ > 0 .and. lMV_PLSHAT
					PLHATINTFAT(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
				endIf

			endIf
			
		next

	endIf

	//UPDATE BCE
	cSql := " UPDATE " + retSQLName("BCE")  
	cSql += "    SET BCE_NUMLOT = '" + cLote + "', " 
	cSql += "        BCE_OPELOT = '" + cOpeLote + "' "

	cSQL += "  WHERE BCE_FILIAL = '" + xFilial("BCE") + "' "

	if ! empty(cCodRDA)
		cSQL += " AND BCE_CODIGO = '" + cCodRDA + "' "
	endIf
	
	cSQL += " AND BCE_CODINT = '" + cCodOpe + "' "
	cSQL += " AND BCE_ANOPAG = '" + cAno + "' "
	cSQL += " AND BCE_MESPAG = '" + cMes + "' "
	cSQL += " AND BCE_OPELOT = '" + PlsIntPad() + "' "
	cSQL += " AND BCE_NUMLOT = '" + Space(TamSx3("BCE_NUMLOT")[1]) + "' "
	cSQL += " AND D_E_L_E_T_ = ' ' "

	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update PLSATUVINP -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update PLSATUVINP -> [ " + tcSqlERROR() + "]")

	elseIf __lOracle
		
		TCSQLExec("COMMIT")

	endIf
	
	// Verifica se houve Salario Contribuicao INSS Outras Empresas inFor- 
	// mado no BGQ - Debitos/Creditos Variaveis                       
	cCod170 := getNewPar("MV_PLSCIOE","")
	
	cSQL := " SELECT BGQ_CC AS CC, BGQ_VERBA, BGQ_TIPOCT AS TIPOCT, BGQ_CODLAN AS CODLAN, BGQ_VALOR AS VALOR,BGQ_INCIR AS INCIR,BGQ_INCINS AS INCINS, "
	cSQL += "        BGQ_INCPIS AS INCPIS,BGQ_INCCOF AS INCCOF, BGQ_INCCSL AS INCCSL "
	cSQL += "   FROM " + RetSQLName("BGQ")
	cSQL += "  WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' AND "
	cSQL += "        BGQ_CODOPE = '" + cCodOpe + "'  AND "
	
	if ! empty(cCodRDA)
		cSQL += " BGQ_CODIGO = '" + cCodRDA + "' AND "
	endIf
	
	if empty(cCod170)
		cSQL += " BGQ_TIPO = '3' AND "
	Else
		cSQL += " BGQ_CODLAN = '" + allTrim(cCod170) + "' AND "
	endIf
	
	if BGQ->(fieldPos("BGQ_ATIVO")) > 0
		cSQL += " BGQ_ATIVO  <> '0' AND "
	endIf
	
	cSQL += " ( (BGQ_OPELOT = '" + space( tamSx3("BGQ_OPELOT")[1] ) + "' AND "
	cSQL += "    BGQ_NUMLOT = '" + space( tamSx3("BGQ_NUMLOT")[1] ) + "') OR "
	cSQL += "   (BGQ_ANO    = '" + cAno + "' AND BGQ_MES = '" + cMes + "' ) ) AND "
	
	cSQL += " D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSQL),"TrbMPG",.F.,.T.)

	tcSetField("TrbMPG","VALOR","N",nVlPrec,nVlDec)

	lINSSOutEmpBGQ := .f.

	if ! TrbMPG->(eof())
		lINSSOutEmpBGQ := .t.
	endIf

	TrbMPG->(dbCloseArea())
	
	// Grava BBC-Deb/Cred Fixo em BGQ para ficar registrado o historico,  
	// pois o BBC pode ser alterado a qualquer momento                
	cSQL := " SELECT BBC_DEBCRE AS DEBCRE, BBC_CC AS CC, BBC_CODSER AS CODSER, BBC_VALOR, BBC_QTDCH, R_E_C_N_O_ BBC_RECNO, "
	cSQL += "        BBC_CODIGO AS CODRDA, BBC_NROPGT "
	cSQL += "   FROM " + RetSQLName("BBC")
	cSQL += "  WHERE BBC_FILIAL = '" + xFilial("BBC") + "' AND "
	
	if ! empty(cCodRDA)
		cSQL += " BBC_CODIGO = '" + cCodRDA + "' AND "
	endIf
	
	cSQL += " BBC_PROMED = '1' AND "
	cSQL += " BBC_STATUS = '1' AND "

	if lCposVld  
		cSQL += " '" + cAno + cMes + "01' >= BBC_VLDINI AND "
		cSQL += " ( ( '" + dtos( lastDay(ctod( "01/" + cMes + "/" + cAno ) ) ) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
	endIf
	
	if ! empty(cCodDC)
		cSQL += " BBC_CODSER IN " + cCodDC + " AND "
	endIf
	
	cSQL += " D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",tcGenQry(,, cSQL),"TrbMPG",.F.,.T.)

	tcSetField("TrbMPG","BBC_VALOR","N",nVlPrec,nVlDec)
	tcSetField("TrbMPG","BBC_QTDCH","N",nVlPrec,nVlDec)
	tcSetField("TrbMPG","BBC_RECNO","N",16,0)

	if lCposVld
		tcSetField("TrbMPG","BBC_VLDFIM","D",8,0)
		tcSetField("TrbMPG","BBC_VLDINI","D",8,0)
	endIf

	while ! TrbMPG->(eof())
	
		//Se o lancamento eh "Salario Contribuicao INSS Outras Empresas" e
		//encontrou tambem no BGQ (Debitos/Creditos variaveis), despreza.
		if (empty(cCod170) .and. TrbMPG->DEBCRE == "3" .and. lINSSOutEmpBGQ) .or. (! empty(cCod170) .and. TrbMPG->CODSER == cCod170 .and. lINSSOutEmpBGQ)
			TrbMPG->(dbSkip())
			Loop
		endIf
		
		if lSoINSS .and. TrbMPG->BBC_NROPGT <> "0"
			TrbMPG->(dbSkip())
			Loop
		endIf
		
		cNroPgt	:= Iif( empty(TrbMPG->BBC_NROPGT), '0', TrbMPG->BBC_NROPGT )

		if ! PLMOVCRE(cCodRDA,cAno,cMes,,cNroPgt,,cCodOpe,cOpeLote)
			TrbMPG->(dbSkip())
			Loop
		endIf

		//Posiciona tabelas                                                   
		BBC->(dbGoto(TrbMPG->BBC_RECNO))
		BBB->(msSeek(xFilial("BBB") + TrbMPG->CODSER, .f.) )

		// Calcula valor                                                       
		_nVlrAux := 0
		
		//Lancado em Reais
		if TrbMPG->BBC_VALOR > 0 
		
			_nVlrAux := TrbMPG->BBC_VALOR
		
		//Lancado em Qtd de CH
		elseIf TrbMPG->BBC_QTDCH > 0 
		
			//Estou criando esse M->BBC_QTDCH para reaproveitar a funcao PLSA755QTD que pega o valor baseado na qtd de ch
			M->BBC_QTDCH := 0
			
			PLSA755Qtd(cCodOpe,TrbMPG->BBC_QTDCH,cAno,cMes,cCodRDA,"M->BBC_QTDCH")
			
			_nVlrAux := M->BBC_QTDCH
			
		endIf

		//Grava BGQ-Deb/Cred Mensal para ficar como historico                
		BGQ->(RecLock("BGQ",.T.))
			BGQ->BGQ_FILIAL := xFilial("BGQ")
			BGQ->BGQ_CODSEQ := BGQ->(GETSX8NUM("BGQ","BGQ_CODSEQ"))
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

            if len(aMatTIT) > 0 .AND. BGQ->BGQ_TIPO <> "1"
                BGQ->BGQ_PREFIX := aMatTIT[2]	//SE2->E2_PREFIXO
                BGQ->BGQ_NUMTIT := aMatTIT[3]	//SE2->E2_NUM
                BGQ->BGQ_PARCEL := aMatTIT[4]	//SE2->E2_PARCELA
                BGQ->BGQ_TIPTIT := aMatTIT[5]	//SE2->E2_TIPO
            endIf

			BGQ->BGQ_LANAUT := "1"
			BGQ->BGQ_OPELAU := plsintpad()
			BGQ->BGQ_NUMLAU := "BBC"
			BGQ->BGQ_CC	  	:= BBC->BBC_CC
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
			BGQ->BGQ_INTERC	:= Iif(empty(cLoteImp),'0','1')
			
			if lBBB_INCISS .and. lBGQ_INCISS
				BGQ->BGQ_INCISS := BBB->BBB_INCISS
			endIf
			
		BGQ->(msUnLock())
		
		BGQ->(ConfirmSX8())
		
	TrbMPG->(dbSkip())
	endDo
	
	TrbMPG->(dbCloseArea())
	
	//UPDATE BGQ
	cSql := " UPDATE " + retSQLName("BGQ")  
	cSql += "    SET BGQ_NUMLOT = '" + cLote    + "', "
	cSql += "        BGQ_OPELOT = '" + cOpeLote + "' "    

	cSQL += "  WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' AND "
	
	if ! empty(cCodRDA)
		cSQL += " BGQ_CODIGO = '" + cCodRDA + "' AND "
	endIf

	cSQL += " ( BGQ_ANO < '" + cAno + "' OR (BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '" + cMes + "' ) ) AND "
		
	if BGQ->(fieldPos("BGQ_ATIVO")) > 0
		cSQL += " BGQ_ATIVO <> '0' AND "
	endIf
	
	cSQL += " BGQ_CODOPE = '" + cCodOpe + "' AND "
	cSQL += " BGQ_NUMLOT = '          ' AND "
	
	if  ! empty(cCodDC)
		cSQL += " BGQ_CODLAN IN " + cCodDC + " AND "
	endIf
	
	if ! empty(cCod170)
		cSQL += " NOT ( ( BGQ_CODLAN IN " + formatIn(cCod170, ",") + " OR BGQ_TIPO = '3' ) AND "
		cSQL += "       ( BGQ_ANO <> '" + cAno + "' AND BGQ_MES <> '" + cMes + "' ) ) AND " 
	else 	
		cSQL += " NOT ( BGQ_TIPO = '3' AND "
		cSQL += "       BGQ_ANO <> '" + cAno + "' AND BGQ_MES <> '" + cMes + "' ) AND " 
	endIf
	
	cSQL += " D_E_L_E_T_ = ' ' "

	if lPLMPALAN
		cSQL += execBlock("PLMPALAN", .f., .f., {})
	endIf

	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update PLSATUVINP -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update PLSATUVINP -> [ " + tcSqlERROR() + "]")

	elseIf __lOracle
		
		TCSQLExec("COMMIT")

	endIf

	if len(aMatTIT) > 0	
		//Faz a atualização de titulos a parte, pois em casos de desconto de mensalidade na produção preciso preencher o BGQ_NUMLOT mas não limpo o BGQ_NUMTIT
		cSql := " UPDATE " + retSQLName("BGQ")
		cSql += " SET BGQ_PREFIX = '" + aMatTIT[2] + "', "
    	cSql += "     BGQ_NUMTIT = '" + aMatTIT[3] + "', "
    	cSql += "     BGQ_PARCEL = '" + aMatTIT[4] + "', "
    	cSql += "     BGQ_TIPTIT = '" + aMatTIT[5] + "' "
		cSql += "   WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' "
		cSQL += "     AND BGQ_CODIGO = '" + cCodRDA + "' "
		cSQL += "     AND BGQ_CODOPE = '" + cCodOpe + "' "
		cSql += "     AND BGQ_OPELOT = '" + cOpeLote + "' "
		cSql += "     AND BGQ_NUMLOT = '" + cLote + "' "
		cSql += "     AND BGQ_TIPO   = '2' " //Crédito
		cSQL += "     AND BGQ_ATIVO  <> '0' "
		cSql += "     AND BGQ_NUMTIT = '         ' "
		cSql += "     AND " + retSQLName("BGQ") + ".D_E_L_E_T_ = ' ' "
		PLSCOMMIT(cSql)
	endIf	
// Limpar o Lote
elseIf cTipoUpt == "2"

	atualizaGuiaPagto(cTipoUpt, cCodRDA, IIF( Len(cLote) > 8, cLote, cano + cMes + cLote), cOpeLote, cCodOpe, __lOracle)

	//UPDATE BCE
	cSql := " UPDATE " + retSQLName("BCE")  
	cSql += "    SET BCE_NUMLOT = ' ', " 
	cSql += "        BCE_OPELOT = ' ' "

	cSQL += "  WHERE BCE_FILIAL = '" + xFilial("BCE") + "' "

	if ! empty(cCodRDA)
		cSQL += " AND BCE_CODIGO = '" + cCodRDA + "' "
	endIf
	
	cSQL += " AND BCE_CODINT = '" + cCodOpe + "' "
	cSQL += " AND BCE_ANOPAG = '" + cAno + "' "
	cSQL += " AND BCE_MESPAG = '" + cMes + "' "
	cSQL += " AND BCE_OPELOT = '" + cOpeLote + "' "
	cSQL += " AND BCE_NUMLOT = '" + cLote + "' "
	cSQL += " AND D_E_L_E_T_ = ' ' "

	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update PLSATUVINP -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update PLSATUVINP -> [ " + tcSqlERROR() + "]")

	elseIf __lOracle
		
		TCSQLExec("COMMIT")

	endIf

	//update BGQ
	cSql := " UPDATE " + retSQLName("BGQ") + " SET D_E_L_E_T_ = '*' "  

	if PLCHKRCD("BGQ")
		cSql += " ,R_E_C_D_E_L_ = R_E_C_N_O_"  
	endIf

	cSQL += " WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' AND "
	
	if ! empty(cCodRDA)
		cSQL += " BGQ_CODIGO = '" + cCodRDA + "' AND "
	endIf
	
	cSQL += "   BGQ_CODOPE = '" + cCodOpe + "'  AND "
	cSQL += "   BGQ_OPELOT = '" + cOpeLote + "' AND "
	cSQL += "   BGQ_NUMLOT = '" + cLote + "' AND  "
	cSQL += "   BGQ_LANAUT = '1'  AND "
	cSQL += "   BGQ_PREFIX = ' '  AND "
	cSQL += "   BGQ_NUMTIT = '         '  AND "
	cSQL += "   BGQ_TIPTIT = ' '  AND "
	cSQL += "   BGQ_INTERC <> '1' AND "
	cSQL += "   D_E_L_E_T_ = ' '  AND "
	
	if BGQ->(fieldPos("BGQ_ATIVO")) > 0
		cSQL += " BGQ_ATIVO  <> '0' "
	endIf

	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do delete PLSATUVINP -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do delete PLSATUVINP -> [ " + tcSqlERROR() + "]")

	elseIf __lOracle
		
		TCSQLExec("COMMIT")

	endIf
	
	//DELETE LANCAMENTO AUTOMATICO DE INTERCAMBIO
	cSql := " UPDATE " + retSQLName("BGQ") + " SET D_E_L_E_T_ = '*' "  

	if PLCHKRCD("BGQ")
		cSql += " ,R_E_C_D_E_L_ = R_E_C_N_O_"  
	endIf
	
	cSQL += " WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' AND "
	
	if ! empty(cCodRDA)
		cSQL += " BGQ_CODIGO = '" + cCodRDA + "' AND "
	endIf
	
	cSQL += "   BGQ_CODOPE = '" + cCodOpe + "' AND "
	cSQL += "   BGQ_OPELOT = '" + cOpeLote + "' AND "
	cSQL += "   BGQ_NUMLOT = '" + cLote + "' AND  "
	cSQL += "   BGQ_INTERC = '1' AND "
	cSQL += "   BGQ_NUMCOB = ' ' AND "
	cSQL += "   BGQ_LANAUT = '1' AND "
	cSQL += "   D_E_L_E_T_ = ' ' AND "
	
	if BGQ->(fieldPos("BGQ_ATIVO")) > 0
		cSQL += " BGQ_ATIVO  <> '0' "
	endIf
	
	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do delete PLSATUVINP -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do delete PLSATUVINP -> [ " + tcSqlERROR() + "]")

	elseIf __lOracle
		
		TCSQLExec("COMMIT")

	endIf
	
	//UPDATE BGQ
	cSql := " UPDATE " + retSQLName("BGQ")  
	cSql += "    SET BGQ_NUMLOT = ' ', "
	cSql += "        BGQ_OPELOT = ' ', "
    cSql += "        BGQ_PREFIX = ' ', "
    cSql += "        BGQ_NUMTIT = ' ', "
    cSql += "        BGQ_PARCEL = ' ', "
    cSql += "        BGQ_TIPTIT = ' ' "
	cWhere := " WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' AND "
	
	if ! empty(cCodRDA)
		cWhere += " BGQ_CODIGO = '" + cCodRDA + "' AND "
	endIf
	
	cWhere += "   BGQ_CODOPE = '" + cCodOpe  + "' AND "
	cWhere += "   BGQ_OPELOT = '" + cOpeLote + "' AND "
	cWhere += "   BGQ_NUMLOT = '" + cLote + "' AND "
	
	if BGQ->(fieldPos("BGQ_ATIVO")) > 0
		cWhere += " BGQ_ATIVO  <> '0' AND "
	endIf

	cWhere += " ( ( BGQ_LANAUT <> '1' ) OR ( BGQ_LANAUT = '1' AND BGQ_NMSQLA = '" + space( tamSx3("BGQ_NMSQLA")[1] ) + "' ) ) AND "
	cWhere += " D_E_L_E_T_ = ' ' "
	cWhere2 := " AND BGQ_OBS <> 'GERADO PELA ROTINA DE LOTE DE COBRANCA                                                              ' " 

	if ( tcSqlExec( cSql+cWhere+cWhere2 ) ) < 0

		PlGrvlog("Erro na execução do update PLSATUVINP -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update PLSATUVINP -> [ " + tcSqlERROR() + "]")

	elseIf __lOracle
		
		TCSQLExec("COMMIT")

	endIf

	// Na exclusão não limpa o titulo de gerado pelo lote de cobrança.
	cSql := " UPDATE " + retSQLName("BGQ")  
	cSql += "    SET BGQ_NUMLOT = ' ', "
	cSql += "        BGQ_OPELOT = ' ' "
	cWhere2 := " AND BGQ_OBS = 'GERADO PELA ROTINA DE LOTE DE COBRANCA                                                              ' " 
	PLSCOMMIT(cSql + cWhere + cWhere2)

endIf

return

/*/{Protheus.doc} PLSCRIABLR
Cria os codigos de lancamento de pagamento de sistema... 

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Function PLSCRIABLR(cCodOpe)
LOCAL nFor	  := 0
Local cCodBLR := ""

BLR->(DbSetOrder(1))

For nFor := 100 To 210

	// Pula lançamentos vagos para evitar pesquisa inutil, há um aviso na funçao de criaçao PLSINCBLR()
	If nFor == 111
		nFor := 165
	EndIf

	If nFor > 200
		If nFor == 201
			cCodBLR := "1A1"
		else
			Exit //cCodBLR := StrZero(nFor,3)
		EndIf
	else
		cCodBLR := StrZero(nFor,3)
	endIf

	If ! BLR->(msSeek(xFilial("BLR")+cCodOpe+cCodBLR,.F.))
		PLSINCBLR(StrZero(nFor,3),cCodOpe)
	Endif

Next

Return

/*/{Protheus.doc} PLSMONLPGT
Monta um array com os lancamento de pagto e propriedades

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Function PLSMONLPGT(cCodOpe)
LOCAL aPropri		:= {}
Local lBLR_CODPRO 	:= .f.
Local lBLR_TES 	  	:= .f.
Local lBLS_INCISS 	:= .f.
Local lBLS_TES 	  	:= .f.

if len(__aLancPagto) == 0
	
	lBLR_CODPRO := BLR->(FieldPos("BLR_CODPRO")) > 0
	lBLR_TES 	:= BLR->(FieldPos("BLR_TES"   )) > 0
	lBLS_INCISS := BLS->(FieldPos("BLS_INCISS")) > 0
	lBLS_TES 	:= BLS->(FieldPos("BLS_TES")) 	 > 0

	// Testa a existencia dos codigos de lancamentos de sistema (internos)
	PLSCRIABLR(cCodOpe)

	// Acessa arquivo principal (BLR)...                              
	BLR->(DbSetOrder(1))
	BLS->(DbSetOrder(1))
	If BLR->(msSeek(xFilial("BLR")+cCodOpe,.F.))

		While ! BLR->(Eof()) .And. BLR->(BLR_FILIAL+BLR_CODINT) == xFilial("BLR")+cCodOpe
			
			// Zera matriz com as propriedades do lancto atual...             
			aPropri := {}
			
			// Busca as propriedades...                                       
			If BLS->(msSeek(xFilial("BLS")+BLR->(BLR_CODINT+BLR_PROPRI+BLR_CODLAN),.F.))

				While ! BLS->(Eof()) .And. BLS->(BLS_FILIAL+BLS_CODINT+BLS_CODLAN) ==  xFilial("BLS")+BLR->(BLR_CODINT+BLR_PROPRI+BLR_CODLAN)
					
					// Adiciona as propriedades...                                    
					aadd(aPropri,{	BLS->BLS_CALIMP,;
									BLS->BLS_TIPOCT,;
									BLS->BLS_INCIR,;
									BLS->BLS_INCINS,;
									BLS->BLS_INCPIS,;
									BLS->BLS_INCCOF,;
									BLS->BLS_INCCSL,;
									IIf(lBLS_INCISS, BLS->BLS_INCISS, "1" ),;
									BLS->BLS_VERBA,;
									IIf(lBLS_TES, BLS->BLS_TES, "" ) })                                               
					
					// Acessa proxima propriedade...                                  
				BLS->(DbSkip())
				endDo

			endIf
			
			// Adiciona cod. lancamento mais propriedades...                  
			aadd(__aLancPagto,{	BLR->BLR_CODINT,;
								BLR->BLR_PROPRI,;
								BLR->BLR_CODLAN,;
								BLR->BLR_DESCRI,;
								BLR->BLR_SEQUEN,;
								BLR->BLR_DEBCRE,;
								allTrim(BLR->BLR_IMG),;
								BLR->BLR_CONTAB,;
								aPropri,;
								BLR->BLR_VERBA,;
								BLR->BLR_USO,;                                           
								IIf(lBLR_CODPRO, BLR->BLR_CODPRO, "" ),;
								IIf(lBLR_TES, BLR->BLR_TES, "" ) })
			
			// Acessa proximo lancto de pagto...                              
			BLR->(DbSkip())
		endDo

	endIf
	
endIf	

Return(__aLancPagto)

/*/{Protheus.doc} AnalisaImp
Analisa se uma determinada combinacao vai ter impostos ou nao

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
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

//Testa para o tipo de integracao e depois tipo de usuario...         
nPos := Ascan(aPropri,{|x| x[1] == cNewTpCalc .And. x[2] == cTipUsr })

If nPos == 0
	//Testa para o tipo de integracao e depois tipo de usuario indiferente
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
	
	
	//  Monta totalizador da verba...                                 
	
	AnalisaVerbas(cVerba,aVerbasFol,nValor)
Endif

Return

/*/{Protheus.doc} PLSINCBLR
Inclui os codigos do BLR (lancamento de pagamento) sobdemanda..

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Function PLSINCBLR(cCodigo,cCodOpe)
Local aParCBLR := {}

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
ElseIf cCodigo == "110"
	aParCBLR:={cCodOpe,"1","10","Adiantamentos","007","1","0","1","SALARIOS"}	

//ATENCAO:                                                             
//Se utilizar lancamentos de 107 a 165, deve-se modificar a PLSCRIABLR(),  
//funçao da chamada desta rotina, para que seja considerados os lancamentos.³
//RC - 20100416.                                                       
	
elseIf cCodigo == "165"
	aParCBLR:={cCodOpe,"1","65","Total Valores com Incidência INSS","982","1","0","3","DEPEDENTES"}
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
ElseIf cCodigo == "1A1"
	aParCBLR:={cCodOpe,"1","A1","Dependentes fim IR","00A","3","0","1","DEPEDENTES"}
Endif

If Len(aParCBLR) > 0
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

/*/{Protheus.doc} PLMOVCRE
Retorna se ja foi gerado titulo para um credenciado em um determinado Ano/Mes  

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Function PLMOVCRE(cCodRDA,cAno,cMes,lMsg,cNroPgt,cCodlan,cCodOpe,cOpeLote)
Local lReturn   := .T.
Local nOrdBAU   := BAU->(IndexOrd())
Local nRecBAU   := BAU->(Recno())
Local nPgtos    := 0
DEFAULT lMsg    := .F.
DEFAULT cNroPgt := "0"
DEFAULT cCodlan := ""
DEFAULT cCodOpe := PlsIntPad()
DEFAULT cOpeLote := PlsIntPad() 

If BAU->BAU_CODIGO <> cCodRDA
	BAU->(DbSetOrder(1))
	BAU->(msSeek(xFilial("BAU")+cCodRDA,.F.))
	BAU->(DbSetOrder(nOrdBAU))
Endif

BMR->(dbSetOrder(1))
// Se codigo 0 (zero) todos os Pagamentos deverao conter este lancamento de Debito/Credito Fixo senao, 
// conta qtos pagamentos ja foram efetuados para este lancamento
// BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN
If BMR->(msSeek(xFilial("BMR")+cCodOpe+cCodRDA+cOpeLote+cAno+cMes,.F.)) .and. cNroPgt <> "0" 
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
If allTrim(Str(nPgtos)) <> cNroPgt .and. !cNroPgt $ "0"
	lReturn := .F.
EndIf

If lMsg .And. !lReturn
	Help("",1,"PLMOVCRE")
Endif

BAU->(DbGoTo(nRecBAU))

Return(lReturn)

/*/{Protheus.doc} PLCANCRE
Cancelar geracao de titulos a pagar.   

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Function PLCANCRE()
LOCAL aCampos   := {}
LOCAL lOK       := .T.
LOCAL nOrdSE2   := SE2->(IndexOrd())
LOCAL nRecSE2   := SE2->(Recno())

// Monta Campos que serao gravados com valores pre-definidos no SE2...

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

if empty(SE2->E2_TITPAI) .or. SE2->E2_TIPO == 'INP' //Condição pra excluir o título do inss patronal vinculado, caso gerado.
	msExecAuto({|x,y,z| Fina050(x,y,z)},aCampos,K_Excluir,K_Excluir)
endIf

If lMsErroAuto
	MostraErro()
	lOK := .F.
Endif

SE2->(DbSetOrder(nOrdSE2))
SE2->(DbGoTo(nRecSE2))

Return({lOK})

/*/{Protheus.doc} AnalisaVerbas
Analisa a inclusao de valores nas verbas para a folha de pg  

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
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


/*/{Protheus.doc} AtualizaGuiaPagto
Atualiza Guia Pagamentos	

cTipo "1" Atualizar
      "0" Desatualizar

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
static function AtualizaGuiaPagto(cTipo, cCodRDA, cLote, cOpeLote, cCodOpe, lOracle)
local cFase	:= '4'
local cData	:= dtos(dDataBase)

if cTipo == '1'

	cSql := " UPDATE " + retSqlName("BD6")
	cSql += "    SET BD6_NUMLOT = '" + cLote    + "', " 
	cSql += "        BD6_OPELOT = '" + cOpeLote + "', "
	cSql += "        BD6_FASE   = '" + cFase 	+ "', "
	cSql += "        BD6_DTPAGT = '" + cData 	+ "' "

	cSql += " WHERE R_E_C_N_O_  IN (    SELECT DISTINCT BD6J.R_E_C_N_O_ "
	cSql += "                             FROM " + retSqlName("BD7") + " BD7 "
	
	cSql += "                            INNER JOIN " + retSqlName("BD6") + " BD6J "
	cSql += "                               ON BD6J.BD6_FILIAL = '" + xFilial("BD6") + "' "
	cSQL += "                              AND BD6J.BD6_CODOPE = BD7.BD7_CODOPE "
	cSQL += "                              AND BD6J.BD6_CODLDP = BD7.BD7_CODLDP "
	cSQL += "                              AND BD6J.BD6_CODPEG = BD7.BD7_CODPEG "
	cSQL += "                              AND BD6J.BD6_NUMERO = BD7.BD7_NUMERO "
	cSQL += "                              AND BD6J.BD6_ORIMOV = BD7.BD7_ORIMOV "
	cSQL += "                              AND BD6J.BD6_SEQUEN = BD7.BD7_SEQUEN "
	cSQL += "                              AND BD6J.D_E_L_E_T_ = ' ' "
	
	cSQL += "                            WHERE BD7.BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSQL += "                              AND BD7.BD7_CODOPE = '" + cCodOpe  + "' "
	cSQL += "                              AND BD7.BD7_OPELOT = '" + cOpeLote + "' "
	cSQL += "                              AND BD7.BD7_NUMLOT = '" + cLote    + "' "

	if ! empty(cCodRDA)
		cSQL += "                          AND BD7.BD7_CODRDA = '" + cCodRDA + "' "
	endIf	
	
	cSql += "                              AND BD7.D_E_L_E_T_ = ' ' ) "

	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]")

	elseIf lOracle
		
		TCSQLExec("COMMIT")

	endIf

	cSql := " UPDATE " + retSqlName("BD5")
	cSql += "    SET BD5_NUMLOT = '" + cLote    + "', " 
	cSql += "        BD5_OPELOT = '" + cOpeLote + "', "
	cSql += "        BD5_FASE   = '" + cFase 	+ "', "
	cSql += "        BD5_DTPAGT = '" + cData 	+ "' "

	cSql += " WHERE R_E_C_N_O_  IN (    SELECT DISTINCT BD5J.R_E_C_N_O_ "
	cSql += "                             FROM " + retSqlName("BD7") + " BD7 "
	
	cSql += "                            INNER JOIN " + retSqlName("BD5") + " BD5J "
	cSql += "                               ON BD5J.BD5_FILIAL = '" + xFilial("BD5") + "' "
	cSQL += "                              AND BD5J.BD5_CODOPE = BD7.BD7_CODOPE "
	cSQL += "                              AND BD5J.BD5_CODLDP = BD7.BD7_CODLDP "
	cSQL += "                              AND BD5J.BD5_CODPEG = BD7.BD7_CODPEG "
	cSQL += "                              AND BD5J.BD5_NUMERO = BD7.BD7_NUMERO "
	cSQL += "                              AND BD5J.BD5_SITUAC = BD7.BD7_SITUAC "
	cSQL += "                              AND BD5J.D_E_L_E_T_ = ' ' "
	
	cSQL += "                            WHERE BD7.BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSQL += "                              AND BD7.BD7_CODOPE = '" + cCodOpe  + "' "
	cSQL += "                              AND BD7.BD7_OPELOT = '" + cOpeLote + "' "
	cSQL += "                              AND BD7.BD7_NUMLOT = '" + cLote    + "' "

	if ! empty(cCodRDA)
		cSQL += "                          AND BD7.BD7_CODRDA = '" + cCodRDA + "' "
	endIf	
	
	cSql += "                              AND BD7.D_E_L_E_T_ = ' ' ) "

	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]")

	elseIf lOracle
		
		TCSQLExec("COMMIT")

	endIf

	cSql := " UPDATE " + retSqlName("BE4")
	cSql += "    SET BE4_NUMLOT = '" + cLote    + "', " 
	cSql += "        BE4_OPELOT = '" + cOpeLote + "', "
	cSql += "        BE4_FASE   = '" + cFase 	+ "', "
	cSql += "        BE4_DTPAGT = '" + cData 	+ "' "

	cSql += " WHERE R_E_C_N_O_  IN (    SELECT DISTINCT BE4J.R_E_C_N_O_ "
	cSql += "                             FROM " + retSqlName("BD7") + " BD7 "
	
	cSql += "                            INNER JOIN " + retSqlName("BE4") + " BE4J "
	cSql += "                               ON BE4J.BE4_FILIAL = '" + xFilial("BE4") + "' "
	cSQL += "                              AND BE4J.BE4_CODOPE = BD7.BD7_CODOPE "
	cSQL += "                              AND BE4J.BE4_CODLDP = BD7.BD7_CODLDP "
	cSQL += "                              AND BE4J.BE4_CODPEG = BD7.BD7_CODPEG "
	cSQL += "                              AND BE4J.BE4_NUMERO = BD7.BD7_NUMERO "
	cSQL += "                              AND BE4J.BE4_SITUAC = BD7.BD7_SITUAC "
	cSQL += "                              AND BE4J.D_E_L_E_T_ = ' ' "
	
	cSQL += "                            WHERE BD7.BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSQL += "                              AND BD7.BD7_CODOPE = '" + cCodOpe  + "' "
	cSQL += "                              AND BD7.BD7_OPELOT = '" + cOpeLote + "' "
	cSQL += "                              AND BD7.BD7_NUMLOT = '" + cLote    + "' "

	if ! empty(cCodRDA)
		cSQL += "                          AND BD7.BD7_CODRDA = '" + cCodRDA + "' "
	endIf	
	
	cSql += "                              AND BD7.D_E_L_E_T_ = ' ' ) "

	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]")

	elseIf lOracle
		
		TCSQLExec("COMMIT")

	endIf

elseIf cTipo == '2'	

	cSql := " UPDATE " + retSqlName("BCI")
	cSql += "    SET BCI_FASE   = '3' " 
	cSql += "  WHERE R_E_C_N_O_ IN (    SELECT DISTINCT BCIJ.R_E_C_N_O_ "
	cSql += "           				  FROM " + retSqlName("BD6") + " BD6 "

	cSql += "                            INNER JOIN " + retSqlName("BCI") + " BCIJ "
	cSql += "                               ON BCIJ.BCI_FILIAL = '" + xFilial("BCI") + "' "
	cSQL += "                              AND BCIJ.BCI_CODOPE = BD6.BD6_CODOPE "
	cSQL += "                              AND BCIJ.BCI_CODLDP = BD6.BD6_CODLDP "
	cSQL += "                              AND BCIJ.BCI_CODPEG = BD6.BD6_CODPEG "
	cSQL += "                              AND BCIJ.BCI_FASE   = '4' "
	cSql += "                              AND BCIJ.BCI_SITUAC = BD6.BD6_SITUAC "
	cSQL += "                              AND BCIJ.D_E_L_E_T_ = ' ' "

	cSQL += "                            WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
	cSQL += "                              AND BD6_CODOPE = '" + cCodOpe  + "' "
	cSQL += "                              AND BD6_OPELOT = '" + cOpeLote + "' "
	cSQL += "                              AND BD6_NUMLOT = '" + cLote    + "' "

	if ! empty(cCodRDA)
		cSQL += "                          AND BD6_CODRDA = '" + cCodRDA + "' "
	endIf	
	
	cSql += "                              AND BD6.D_E_L_E_T_ = ' ' )  "

	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]")

	elseIf lOracle
		
		tcSqlExec("COMMIT")

	endIf

	//UPDATE BD5
	cSql := " UPDATE " + retSqlName("BD5")
	cSql += "    SET BD5_NUMLOT = ' ', " 
	cSql += "        BD5_OPELOT = ' ', "
	cSql += "        BD5_DTPAGT = ' ', "
	cSql += "        BD5_FASE   = '3' "

	If lPLLIMBD7
		cSql += Execblock("PLLIMBD7",.F.,.F.,{"BD5"})
	endIf
	
	cSql += " WHERE R_E_C_N_O_  IN (    SELECT DISTINCT BD5J.R_E_C_N_O_ "
	cSql += "                             FROM " + retSqlName("BD7") + " BD7 "

	cSql += "                            INNER JOIN " + retSqlName("BD5") + " BD5J "
	cSql += "                               ON BD5J.BD5_FILIAL = '" + xFilial("BD5") + "' "
	cSQL += "                              AND BD5J.BD5_CODOPE = BD7.BD7_CODOPE "
	cSQL += "                              AND BD5J.BD5_CODLDP = BD7.BD7_CODLDP "
	cSQL += "                              AND BD5J.BD5_CODPEG = BD7.BD7_CODPEG "
	cSQL += "                              AND BD5J.BD5_NUMERO = BD7.BD7_NUMERO "
	cSQL += "                              AND BD5J.BD5_SITUAC = BD7.BD7_SITUAC "
	cSQL += "                              AND BD5J.D_E_L_E_T_ = ' ' "
	
	cSQL += "                            WHERE BD7.BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSQL += "                              AND BD7.BD7_CODOPE = '" + cCodOpe  + "' "
	cSQL += "                              AND BD7.BD7_OPELOT = '" + cOpeLote + "' "
	cSQL += "                              AND BD7.BD7_NUMLOT = '" + cLote    + "' "

	if ! empty(cCodRDA)
		cSQL += "                          AND BD7.BD7_CODRDA = '" + cCodRDA + "' "
	endIf

	cSql += "                              AND BD7.D_E_L_E_T_ = ' ' ) "

	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]")

	elseIf lOracle
		
		TCSQLExec("COMMIT")

	endIf

	//UPDATE BE4
	cSql := " UPDATE " + retSqlName("BE4")
	cSql += "    SET BE4_NUMLOT = ' ', " 
	cSql += "        BE4_OPELOT = ' ', "
	cSql += "        BE4_DTPAGT = ' ', "
	cSql += "        BE4_FASE   = '3' "

	If lPLLIMBD7
		cSql += Execblock("PLLIMBD7",.F.,.F.,{"BE4"})
	endIf
	
	cSql += " WHERE R_E_C_N_O_  IN (    SELECT DISTINCT BE4J.R_E_C_N_O_ "
	cSql += "                             FROM " + retSqlName("BD7") + " BD7 "

	cSql += "                            INNER JOIN " + retSqlName("BE4") + " BE4J "
	cSql += "                               ON BE4J.BE4_FILIAL = '" + xFilial("BE4") + "' "
	cSQL += "                              AND BE4J.BE4_CODOPE = BD7.BD7_CODOPE "
	cSQL += "                              AND BE4J.BE4_CODLDP = BD7.BD7_CODLDP "
	cSQL += "                              AND BE4J.BE4_CODPEG = BD7.BD7_CODPEG "
	cSQL += "                              AND BE4J.BE4_NUMERO = BD7.BD7_NUMERO "
	cSQL += "                              AND BE4J.BE4_SITUAC = BD7.BD7_SITUAC "
	cSQL += "                              AND BE4J.D_E_L_E_T_ = ' ' "
	
	cSQL += "                            WHERE BD7.BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSQL += "                              AND BD7.BD7_CODOPE = '" + cCodOpe  + "' "
	cSQL += "                              AND BD7.BD7_OPELOT = '" + cOpeLote + "' "
	cSQL += "                              AND BD7.BD7_NUMLOT = '" + cLote    + "' "
	
	if ! empty(cCodRDA)
		cSQL += "                          AND BD7.BD7_CODRDA = '" + cCodRDA + "' "
	endIf

	cSql += "                              AND BD7.D_E_L_E_T_ = ' ' ) "
		
	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]")

	elseIf lOracle
		
		TCSQLExec("COMMIT")

	endIf

	//UPDATE BD6
	cSql := " UPDATE " + retSQLName("BD6")  
	cSql += "    SET BD6_NUMLOT = ' ', " 
	cSql += "        BD6_OPELOT = ' ', "
	cSql += "        BD6_DTPAGT = ' ', "
	cSql += "        BD6_FASE   = '3' "
	
	If lPLLIMBD7
		cSql += Execblock("PLLIMBD7",.F.,.F.,{"BD6"})
	endIf
	
	cSQL += "  WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
	cSQL += "    AND BD6_CODOPE = '" + cCodOpe  + "' "
	cSQL += "    AND BD6_OPELOT = '" + cOpeLote + "' "
	cSQL += "    AND BD6_NUMLOT = '" + cLote + "' "
	
	if ! empty(cCodRDA)
		cSQL += "    AND BD6_CODRDA = '" + cCodRDA + "' "
	endIf

	cSQL += "    AND D_E_L_E_T_ = ' ' "
		
	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]")

	elseIf lOracle
		
		TCSQLExec("COMMIT")

	endIf
							
	//UPDATE BD7
	cSql := " UPDATE " + retSQLName("BD7")  
	cSql += "    SET BD7_NUMLOT = ' ', " 
	cSql += "        BD7_OPELOT = ' ', "
	cSql += "        BD7_DTGRCP = ' ', "
	cSql += "        BD7_DTPAGT = ' ', "
	cSql += "        BD7_FASE   = '3', "
	cSql += "        BD7_RECSIP = 'EXCLUI', "
	cSql += "        BD7_CHKSE2 = ' ' "
	
	If lPLLIMBD7
		cSql += Execblock("PLLIMBD7",.F.,.F.,{"BD7"})
	endIf
	
	cSQL += "  WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSQL += "    AND BD7_CODOPE = '" + cCodOpe  + "' "
	cSQL += "    AND BD7_OPELOT = '" + cOpeLote + "' "
	cSQL += "    AND BD7_NUMLOT = '" + cLote + "' "
	if ! empty(cCodRDA)
		cSQL += " AND BD7_CODRDA = '" + cCodRDA + "' "
	endIf

	cSQL += "    AND D_E_L_E_T_ = ' ' "
		
	if ( tcSqlExec( cSql ) ) < 0

		PlGrvlog("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]", 'PLSMPAG' , 1, .t., funName())
		userException("Erro na execução do update AtualizaGuiaPagto -> [ " + tcSqlERROR() + "]")

	elseIf lOracle
		
		TCSQLExec("COMMIT")

	endIf

endIf

return

/*/{Protheus.doc} MontaExpFil
Monta Expressao Filtro		

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Static Function MontaExpFil(cExcessao, nTam)
LOCAL nFor
LOCAL cRet := "("
LOCAL cAux := alltrim(cExcessao)

For nFor := 1 To Len(cAux) Step nTam
	cRet += "'" + subs(cAux, nFor, nTam) + "',"
	nFor ++
Next

cRet := subs(cRet,1,Len(cRet)-1)+")"

Return(cRet)

/*/{Protheus.doc} PLSDEPIR
Identifica o numero de dependentes para IR do prestador  	

@author  PLS TEAM
@version P12
@since   21.03.17
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
// Verifica se possui dependentes cadastrados na RDA e quantos incidem p/ IR³
If  BBE->(FieldPos("BBE_TIPDIR")) > 0
	BBE->(dbSetOrder(1))
	BBE->(msSeek(xFilial("BBE") + cCodRda,.F.))
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

// Se nao possui dependentes cadastrados na RDA, verifica no SRA       

If  ! lTemDep
	cChaRda   := BAU->BAU_MATFUN + BAU->BAU_FILFUN
	nTamChave := TamSX3("RA_MAT")[1]
	cChaveInd := "RA_MAT + RA_FILIAL"
	cChaveSRA := left(BAU->BAU_MATFUN+space(nTamChave),nTamChave) + BAU->BAU_FILFUN
	If (nOrdemSRA := RetOrdem("SRA",cChaveInd,.T.)) <> 0
		SRA->(dbSetOrder(nOrdemSRA))
		If  ! Empty(cChaveSRA) .and. SRA->(msSeek(cChaveSRA,.F.))
			cDepIr := SRA->RA_DEPIR
		Endif
	Endif
Endif
If  empty(cDepIr)
	cDepIr := "00"
Endif

// Fim da funcao                                                       

Return(cDepIr)


/*/{Protheus.doc} PLSINTGPE
Calcula impostos atraves da integracao com a folha  	

 Procedimentos:                                                 
 - Calcular pro-labore pela folha                               
 - Fazer os demais lancamento no PLS:                           
   . Plantonistas                                               
   . Demais debitos/creditos                                    
- Fazer o calculo da RDA pelo PLS                              
                                                                

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Function PLSINTGPE(lGraImp,cCodRda,cAno,cMes,aVerbas,cOpeLote,cLote,cObsoleto,cCodForn,cLoja,cHisTit,nBIrPls,nBInsPfPls,nBInsPjPls,nScoOutEmp,lAutonomo,dVenTit,aImpMes,lUltCalc,nVrIRRet,nBInsJFPls,lPgtoImp,aCompPag,lPgUni4,cNumero,lHist,cTipoTit,nBInsHPPls,nBInsUNPls)
Local nPercJur  	:= GetNewPar("MV_PLINSPJ",0.20) //0.20 – tipo numérico – Descrição: Perc. Inss para atendimento a pessoa jurídica
Local nPercFis  	:= GetNewPar("MV_PLINSPF",0.20) //0.20- tipo numérico - Descrição: Perc. Inss para atendimento a pessoa física

Local lRet			:= .F.
Local cRet          := ""
Local cChaveSRA
LOCAL nPos
LOCAL cChaveInd
local nBaseJur		:= 0
local nBaseFis		:= 0
local nBaseJF		:= 0
local nBaseHP		:= 0
Local nBaseUN		:= 0
Local nTamChave		:= 0
Local nValBaseIr	:= 0.00
Local nValIr		:= 0.00
Local nOrdemSRA		:= 0
Local cFilProc     	:= xFilial("SRA") //SM0->M0_CODFIL: alterado pois no SM0 o campo de Filial está com tamanho 12, sendo que nas demais tabelas, a Filial tem tamanho 8 ...
Local cDepIr       	:= "00"
Local cChaRda
Local nTetoInss
Local aBMR    		:= {}
Local aIrrf        	:= {}
Local nVlrSE2      	:= 0
Local i
Local lFirst       	:= .T.
Local nBirFol      	:= 0 // base irrf folha
Local nVirFol      	:= 0 // valor irrf folha
Local nInssFol     	:= 0 // valor inss folha
Local nInssFis		:= 0
Local nInssJur		:= 0
Local nInssJF		:= 0
Local nInssHP		:= 0
Local nInssUni		:= 0
Local dVencRea
Local nDedFol
Local dVencto
Local cAnoMesIrf    := ""
Local nAuxRetImp    := 0
Local aArea
Local cLojaLan		:= '00'
Local cCodFInss		:= allTrim(getNewPar("MV_FORINSS","INSS"))
Local cNatuInss		:= allTrim(&(getNewPar("MV_INSS","INSS")))
Local cCodFIR		:= allTrim(getNewPar("MV_UNIAO","UNIAO"))
Local cNatuIR		:= allTrim(&(getNewPar("MV_IRF",'IR')))
Local lBMR_ANOVCT 	:= BMR->(FieldPos('BMR_ANOVCT')) >0
Local lBMR_MESVCT 	:= BMR->(FieldPos('BMR_MESVCT')) >0
Local nTamCodFol	:= TamSX3("RV_CODFOL")[1] // verifica se foi aplicado o update na folha que passa para 4 o numero de caractere,
Local lTypecSem		:= .F.
Local cSql 			:= ""
Local nFol 			:= 1
Local aMatRC		:= {}
Local aMatRD		:= {}

Private nRedDep		:= 0

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
	BAU->(msSeek(xFilial('BAU')+cCodRDA,.F.))
EndIf
nPercFis	:= IIf( BAU->BAU_BASINS == '1', nPercJur, nPercFis )

cAnoMesIrf := substr(dtos(dVenTit),1,6)

// Posiciona BAU                                                  
If  BAU->BAU_CODIGO <> cCodRDA
	BAU->(DbSetOrder(1))
	If  ! BAU->(msSeek(xFilial("BAU")+cCodRDA,.F.))
		Return({0,0,.F.,"RDA nao encontrada"})
	Endif
Endif

cChaRda   := BAU->BAU_MATFUN + BAU->BAU_FILFUN
nTamChave := TamSX3("RA_MAT")[1]
cChaveInd := "RA_MAT + RA_FILIAL"
cChaveSRA := left(BAU->BAU_MATFUN+space(nTamChave),nTamChave) + BAU->BAU_FILFUN

// Valida parametros                                              
If  empty(cAno) .or. empty(cMes)
	msgStop("Mes/Ano invalido: " + cMes + "/" + cAno)
	Return({0,0,.F.,"Mes/Ano invalido"})
Endif

// Identifica verbas utilizadas                              	
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
//Z-2
// Inicializa o ambiente do GPE antes de calcular				
// Seta e Carrega os Mnemonicos.								

SetMnemonicos(NIL,NIL,.T.)

// Variaveis necessarias ao calculo e carga de tabelas.		

c__Roteiro	:= "FOL"											// Indica para as funcoes da folha que o

// calculo e do tipo "Folha de Pagamento"

// Carregando a  Tabela do INSS								

If  ! Car_inss(@aTInss,cAno+cMes)
	return({0,0,.F.,"Tabela de INSS nao encontrada"})
EndIf

// Carrega Variaveis Codigos da Folha							

if !FP_CODFOL(@aCodFol,cFilProc)
	return({0,0,.F.,"Ident. de calculo da Folha nao encontrados"})
endIf

// Verifica se foram cadastrados os identificadores para calculo
// do autonomo que presta servico a P.Fisica e Juridica.		 

// Pagto servicos prestados P.FISICA Ded INSS Base IR
if	empty(aCodFol[349,1]) .Or. empty(aCodFol[167,1]) 	   	 
	return({0,0,.F.,"Verbas nao encontradas - id. calculo: 349,167"})
endIf

// Verifica o fornecedor e natureza para INSS

SED->(dbSetOrder(1))//ED_FILIAL+ED_CODIGO
if !SED->(msSeek(xFilial("SED")+cNatuInss,.F.))
	return({0,0,.F.,"Natureza ["+cNatuInss+"] invalida"})
endIf

SA2->(DbSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA
if !SA2->(msSeek(xFilial("SA2")+cCodFInss + cLojaLan,.f.))
	return({0,0,.F.,"Fornecedor ["+cCodFInss+"] invalido"})
endif

// Verifica o fornecedor e natureza para IR
if !SED->(msSeek(xFilial("SED")+cNatuIR,.F.))
	return({0,0,.F.,"Natureza ["+cNatuIR+"] invalida"})
endIf

if !SA2->(msSeek(xFilial("SA2")+cCodFIr + cLojaLan,.f.))
	return({0,0,.F.,"Fornecedor ["+cCodFIr+"] invalido"})
endif

// Teto do recolhimento de INSS
nTetoInss := aTInss[Len(aTInss),1]

// Busca o funcionario atual em outros registros do cadastro
If (nOrdemSRA := RetOrdem("SRA",cChaveInd,.T.)) <> 0

	SRA->(dbSetOrder(nOrdemSRA))

	If !Empty(cChaveSRA) .and. SRA->(msSeek(cChaveSRA,.F.))		

		aFolMes := PLFOLMES(cAno+cMes)

		if aFolMes[1]

			cSql := " SELECT RC_PD, RC_VALOR, RC_MAT, RC_FILIAL FROM " + RetSqlName("SRC") + " SRC "
			cSql += " INNER JOIN " + RetSqlName("SRA") + " SRA "
			cSql += " ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
			cSql += " AND SRA.RA_MAT = '" + BAU->BAU_MATFUN + "' " //RC_MAT "
			cSql += " AND SRA.D_E_L_E_T_ = ' ' "
			cSql += " Inner Join " + RetSqlName("SRA") + " RA_TODO "
			cSql += " On "
			cSql += " RA_TODO.RA_CIC = SRA.RA_CIC AND "
			cSql += " (RA_TODO.RA_SITFOLH <> 'D' OR (RA_TODO.RA_SITFOLH = 'D' AND RA_TODO.RA_DEMISSA BETWEEN '" + cAno+cMes + "01' AND '" + cAno+cMes + "31' )) " 
			cSql += " AND RA_TODO.RA_MAT = RC_MAT "
			cSql += " AND RA_TODO.D_E_L_E_T_ = ' ' "
			cSql += " WHERE " //RC_FILIAL = '" + xFilial("SRA") + "' "
			cSql += " RC_MAT = RA_TODO.RA_MAT "//'" + SRA->RA_MAT + "' "
			cSql += " AND RC_LOTPLS = ' ' " //Não olha o que veio do PLS, vamos pegar o que já temos no BMR

			for nFol := 1 to len(aFolMes[2])
			
				if nFol == 1
					cSql += " AND ( "
				endif

				cSql += " ( RC_PERIODO = '" + aFolMes[2][nFol][1] + "' AND RC_SEMANA = '" + aFolMes[2][nFol][2] + "')"
				
				if nFol == len(aFolMes[2])
					cSql += " ) "
				else
					cSql += " OR "
				endif

			next

			cSql += " AND SRC.D_E_L_E_T_ = ' ' "

			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBSRC",.F.,.T.)

			While ! TRBSRC->(eof()) 
			    nPos := aScan(aVerbas,{|x| x[2]== TRBSRC->RC_PD})
			    If nPos > 0
				    aVerbas[nPos,3] += TRBSRC->RC_VALOR
					AADD(aMatRC, {TRBSRC->RC_PD, TRBSRC->RC_FILIAL + TRBSRC->RC_MAT, TRBSRC->RC_VALOR} )
			    Endif
			    TRBSRC->(dbskip())
			Enddo	

			TRBSRC->(dbclosearea())
		endif
			
		//Folha fechada - busca valores da folha no acumulados anuais  
		// Se for verba de INSS, soma direto no array de verbas
		// 064 valor inss
		// 065 valor inss ferias
		// 221 base inss prolabore e autonomo
		// 013 salario contribuicao ate limite
		// 288 sal contribuicao outras empresas
				
		cSqlINSS := " SELECT RD_PD, RD_VALOR, RD_DATPGT, RD_MAT, RD_FILIAL "		
		cSqlINSS += "   FROM " + RetSQLName("SRA") + " SRA "
		
		cSqlINSS += " INNER JOIN " + RetSQLName("SRD") + " SRD "
		cSqlINSS += "    ON RD_FILIAL = RA_FILIAL"						
		cSqlINSS += "   AND RD_MAT = RA_MAT"						
		cSqlINSS += "   AND RD_DATARQ = '" + cAno+cMes + "'  "		
		cSqlINSS += "   AND RD_LOTPLS =  ' ' " //não olhamos o do PLS				
		cSqlINSS += "   AND SRD.D_E_L_E_T_ = ' '  "
		
		cSqlINSS += " WHERE RA_CIC = '" + alltrim(BAU->BAU_CPFCGC) + "'"
		cSqlINSS += "   AND SRA.D_E_L_E_T_ = ' ' "
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlINSS),"TrbINSS",.F.,.T.)

		while !TrbINSS->(eof())
			nPos := ascan(aVerbas,{|x| x[2]== TrbINSS->RD_PD})
			if  nPos > 0		
				// 0064 - INSS
				// 0065 - INSS férias
				// 0221 - Base INSS Aut./Pró-Labore
				// 0013	- Sal Contr. Até Limite Base
				if  aVerbas[nPos,1] $ "0064,0065"
					aVerbas[nPos,3] += TrbINSS->RD_VALOR
					aVerbas[nPos,7] += TrbINSS->RD_VALOR
				elseif  aVerbas[nPos,1] $ "0221,0013"
						aVerbas[nPos,3] += TrbINSS->RD_VALOR
						aVerbas[nPos,7] += TrbINSS->RD_VALOR
				endIf

				//0288 - Salário de Contribuição INSS Outras Empresas
				if aVerbas[nPos,1] == "288"
					aVerbas[nPos,3] := TrbINSS->RD_VALOR
				endif 
			endif
			TrbINSS->(dbskip())  
		enddo
		TrbINSS->(dbclosearea())

		// Se for verba de IR, soma no array de verbas de IR - buscou no SRD-Acumulados Anuais
		// 0066 valor ir
		// 0015 base ir (ja com o inss abatido)
		//informações baseadas na tabela RCN - identificadores de cálculo
		cSqlIR := " SELECT RD_PD, RD_VALOR, RD_DATPGT, RD_FILIAL, RD_MAT "		
		cSqlIR += "   FROM " + RetSQLName("SRA") + " SRA "
		
		cSqlIR += " INNER JOIN " + RetSQLName("SRD") + " SRD "
		cSqlIR += "    ON RD_FILIAL = RA_FILIAL"						
		cSqlIR += "   AND RD_MAT    = RA_MAT"						
		cSqlIR += "   AND RD_DATPGT BETWEEN '" + cAnoMesIrf + "01' AND '" + cAnoMesIrf + "31' "			
		cSqlIR += "   AND RD_LOTPLS = ' ' " // Não considerar o PLS				
		cSqlIR += "   AND SRD.D_E_L_E_T_ = ' '  "
		
		cSqlIR += " INNER JOIN " + RetSQLName("SRV") + " SRV "
  		cSqlIR += "    ON RV_FILIAL = '" + xfilial("SRV") + "' "
  		cSqlIR += "   AND RV_COD    = RD_PD "
  		cSqlIR += "   AND RV_CODFOL IN ('0066','0015') "
  		cSqlIR += "   AND SRV.D_E_L_E_T_ = ' '
		
		cSqlIR += " WHERE RA_CIC = '" + alltrim(BAU->BAU_CPFCGC) + "'"
		cSqlIR += "   AND SRA.D_E_L_E_T_ = ' ' "
		
		cSqlIR += " ORDER BY RD_SEMANA DESC "
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlIR),"TrbIR",.F.,.T.)
		
		while !TrbIR->(eof())
			nPos := ascan(aVerbas,{|x| x[2]== TrbIR->RD_PD})
			if  nPos > 0							
				if aVerbas[nPos,1] $ "0066"				
					aVerbas[nPos,4] += TrbIR->RD_VALOR	
				elseif aVerbas[nPos,1] $ "0015"
					If aScan(aMatRC, { |x| x[1] == aVerbas[nPos,2] .AND. x[2] == TrbIR->(RD_FILIAL+RD_MAT) }) == 0
						If !(EmpTy(aMatRD))
							nXX :=	aScan(aMatRD, { |x| x[1] == nPos .AND. x[2] == TrbIR->(RD_FILIAL+RD_MAT) .AND. x[3] == aVerbas[nPos,2]})
							If nXX == 0
								aadd(aMatRD, {nPos, TrbIR->(RD_FILIAL+RD_MAT), aVerbas[nPos,2], TrbIR->RD_VALOR})
							elseif aMatRD[nXX][4] < TrbIR->RD_VALOR
								aMatRD[nXX][4] := TrbIR->RD_VALOR
							endIf
						else
							aadd(aMatRD, {nPos, TrbIR->(RD_FILIAL+RD_MAT), aVerbas[nPos,2], TrbIR->RD_VALOR})
						endIf
					endIf
				endif
			endif
			TrbIR->(dbskip())
		enddo					
		TrbIR->(dbclosearea())
		If !(EmpTy(aMatRd))
			For nPos := 1 To Len(aMatRD)
				aVerbas[aMatRD[nPos][1],4] += aMatRD[nPos][4]
			next
		endIf
		// Soma IR no array de verbas              
		// Se teve IR no SRC-Folha do Mes, pega ele
		// Se nao, pega do SRD-Acumulados Anuais   
		//Soma ambos, pois pode ter tanto SRC, quanto SRD
		For nPos := 1 to len(aVerbas)
			aVerbas[nPos,6] += aVerbas[nPos,5]
			aVerbas[nPos,6] += aVerbas[nPos,4]
			aVerbas[nPos,4] := 0
			aVerbas[nPos,5] := 0
		Next
	EndIf
Endif

// Se houve movimentacao com incidencia para impostos ou eh o ultimo  
// calculo e ja havia bases de impostos gravadas no BMR           
// aImpMes[02] = Base INSS PJ                                     
// aImpMes[04] = Base INSS PF                                     
// aImpMes[23] = Base INSS HP                                     
// aImpMes[06] = Base IRRF                                        
// aImpMes[10] = Base IRRF JF                                     

if  (nBIrPls + nBInsPfPls + nBInsPjPls + nBInsJFPls + nBInsHPPls + nBInsUNPls + nScoOutEmp) > 0 .or. (lUltCalc .And. aImpMes[2]+aImpMes[4]+aImpMes[6]+aImpMes[23]+aImpMes[10]+aImpMes[26] > 0)
	lRet := .T.
endif

// aImpMes[6] = Base IRRF                                         
// aImpMes[7] = IRRF                                                
// aImpMes[21] = Valor descontado da parcela do IRRF (MV_PLCIRRT) 

aadd(aIrrf,{StrZero(Year(dVenTit),4),StrZero(Month(dVenTit),2),nBIrPls+aImpMes[6]+aImpMes[27],aImpMes[7]+aImpMes[21],0}) //está somando o desconto do INSS na base de IR

// Zera a base de Imposto de Renda para as RDA's que nao deverao calcular o imposto - BOPS 97434
lBAU_CALIRF := BAU->(FieldPos("BAU_CALIRF")) > 0

for nPos := 1 to len(aIrrf)
	// Nao calcula IR
	if lBAU_CALIRF .and. BAU->BAU_CALIRF == "0"
		aIrrf[nPos, 3] := 0
	endIf
next

//                                                                
// Calcula inss                                                   
//                                                                
// Inicializa variaveis para montagem da base e desconto   	   
nBasInssFol := 0 // sal contribuicao inss outras empresas

// Sal Contribuicao inss outras empresas                          
// Somente procura na folha se nao foi lancado no PLS             

If  nScoOutEmp == 0
	nPos := aScan(aVerbas,{ |x| x[1] == "288" } )
	If  nPos > 0
		nScoOutEmp := aVerbas[nPos,3]
	Endif
Endif
nBasInssFol += nScoOutEmp

// Base inss pro-labore                                           

nPos		:= aScan(aVerbas,{ |x| x[1] == "221" } ) // base inss pro-labore/autonomo
nBasInssFol += If(nPos > 0,aVerbas[nPos,3],0)
nPos		:= aScan(aVerbas,{ |x| x[1] == "013" } ) // salario contribuicao ate limite
nBasInssFol += If(nPos > 0,aVerbas[nPos,3],0)

nBaseHP := nBaseJur := nBaseFis := nBaseJF := nBaseUN := 0
nInssHP := nInssJur := nInssFis := nInssJF := nInssUN := 0

// Calcula inss base unificada     						 	   		
nBaseUN := Min(nBInsUNPls + nBasInssFol + aImpMes[26] + aimpMes[1], nTetoInss) - ( nBasInssFol + aImpMes[26] + aimpMes[1])
nBaseUN := IIf(nBaseUN < 0, 0, nBaseUN)
nInssUN := Round((nBaseUN * nPercJur) ,2)	
nInssUN := IIF( nInssUN < 0 , 0, nInssUN)
// Zera variáveis de INSS separados por serviço
nBaseHP := nBaseJur := nBaseFis := nBaseJF := 0
nInssHP := nInssJur := nInssFis := nInssJF := 0

// Calcula inss total para deducao na base do ir                  

nPos     	:= aScan(aVerbas,{ |x| x[1] == "064" } ) // valor inss
nDedFol 	:= if(nPos > 0,aVerbas[nPos,3],0) + if(nPos > 0,aVerbas[nPos,6],0)
nPos		:= aScan(aVerbas,{ |x| x[1] == "065" } ) // valor inss ferias
nDedFol  	+= if(nPos > 0,aVerbas[nPos,3],0) + if(nPos > 0,aVerbas[nPos,6],0)

//nInssUN -= nDedFol
//If nInssUN < 0
//	nInssUN := 0
//endIf

// Monta valor de Deducao do INSS na base de IRRF      	 	   
// aImpMes[03] = INSS PJ      						 	           
// aImpMes[05] = INSS PF      						 	           
// aImpMes[11] = INSS JF      						 	           
// aImpMes[22] = INSS HP      						 	           
// aImpMes[27] = INSS Base Unica      						 	           
// Se nao eh o ultimo calculo do mes considera, tambem, as provisoes  
// de INSS calculadas durante o mes:                              
// aImpMes[08] = Prov INSS PJ     						 	       
// aImpMes[09] = Prov INSS PF     						 	       
// aImpMes[12] = Prov INSS JF    						 	       
// aImpMes[24] = Prov INSS HP    						 	       

nDedInss := nDedFol + nInssJur + nInssFis + nInssJF + nInssHP + nInssUN //+ IIf(lUltCalc, 0, aImpMes[3] + aImpMes[5] + aImpMes[11] + aImpMes[22] + aImpMes[27] + aImpMes[8] + aImpMes[9] + aImpMes[12] + aImpMes[24] )

// Tratamento para reduzir a base do imposto sobre o INSS, se configurado para isso. RC - 20100516

if nDedInss > 0 .and. getNewPar("MV_INSIRF","") == "1" //aImpMes[27]
	nPos := ascan(aCompPag,{|x| x[3]== "198"})  // Base IR
	if nPos > 0
		aCompPag[nPos,2] := iif(aCompPag[nPos,2]-nDedInss+nDedFol > 0, aCompPag[nPos,2]-nDedInss+nDedFol, 0 )
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

// Calcula data de vencimento do titulo de INSS                   
dVencRea := F050VIMP("INSS",dDataBase,dDataBase,dDataBase)

//                                                                
// Verifica se deve gravar titulos referentes ao INSS             
//                                                                

cParcela := space(TamSx3("E2_PARCELA")[1])
cTipoTit := PADR(cTipoTit, TamSx3("E2_TIPO")[1]) 

nVlrSE2 := nInssFis + nInssJur + nInssJF + nInssHP + nInssUN + nInssUni

//                                                                
// Calcula IRRF                                                   
//                                                                

// Identifica qtd de dependentes para ir                          

cDepIr := PLSDEPIR(cCodRda,cAno,cMes)

dbSelectArea("BMR") // apenas para ter uma area selecionada, em funcao dos arquivos de trabalho utilizados

// Identifica valor inss da folha                                 

nPos		:= aScan(aVerbas,{ |x| x[1] == "064" } ) // valor inss
nInssFol 	:= If(nPos > 0,aVerbas[nPos,6],0) + If(nPos > 0,aVerbas[nPos,3],0)
nPos     	:= aScan(aVerbas,{ |x| x[1] == "065" } ) // valor inss ferias
nInssFol	+= If(nPos > 0,aVerbas[nPos,6],0) + If(nPos > 0,aVerbas[nPos,3],0)

// Identifica base IR da folha                                    

nPos		:= aScan(aVerbas,{ |x| x[1] == "015" } )  // base ir folha
nBirFol  	:= If(nPos > 0,aVerbas[nPos,6],0) + If(nPos > 0,aVerbas[nPos,3],0)
nPos     	:= aScan(aVerbas,{ |x| x[1] == "010" } )  // base ir adiantamento
nBirFol  	+= If(nPos > 0,aVerbas[nPos,6],0) + If(nPos > 0,aVerbas[nPos,3],0)
nBirFol  	+= nInssFol

// Identifica valor IRRF da folha                                 

nPos     	:= aScan(aVerbas,{ |x| x[1] == "066" } )  // valor ir folha
nVirFol  	:= If(nPos > 0,aVerbas[nPos,6],0) + If(nPos > 0,aVerbas[nPos,3],0)
nPos     	:= aScan(aVerbas,{ |x| x[1] == "012" } )  // valor ir adiantamento
nVirFol  	+= If(nPos > 0,aVerbas[nPos,6],0) + If(nPos > 0,aVerbas[nPos,3],0)

// Calcula IR  												   

for i := 1 to len(aIrrf)

	aArea := GetArea()
	
	// Inicializa variaveis                                           
	
	nValBaseIr := 0
	nValIr     := 0
	
	// Verifica se houve titulo gerado para este mes so nao entra neste if se parametro
	// for 2 e aIrrf[i,5] for igual a zero, todas as outra opcoes tem que deixar passar.

	// Inicializa variavies    									   
	
	aPd			:= {}
	dVencto	:= ctod("28/" + aIrrf[i,2] + "/" + aIrrf[i,1])
	
	// Carrega aPD com verbas referentes a inss, para efetuar o desconto  
	// do inss na base do ir no 1. mes que tem valor a pagar          
	
	if  lFirst
		lFirst := .f.
		fMatriz(aCodFol[167,1],nDedInss+aImpMes[27],0,"  ",,"V","I",0," ",dVencto,.T.)
		
		// atualiza base ir com deducao do inss 
		
		nPos := Ascan(aCompPag,{|x| x[3]== "198"})  // Base IR
		if nPos > 0 //.and. aCompPag[nPos,2] > 0 .and. aCompPag[nPos,2] <> aIrrf[i,3]
			aIrrf[i,3] := aCompPag[nPos,2]
		endif
	else
		nBirFol  := 0
		nVirFol  := 0
		nDedInss := 0
	endif

	
	// Inclui base para IR no aPD							           
	fMatriz(aCodFol[349,1],aIrrf[i,3]+nBirFol + (nDedInss-nDedFol) +aImpMes[6]+aImpMes[27]-aimpMes[28] ,0,"  ",,"V","I",0," ",dVencto,.T.)	//O INSS da folha já interferiu na base Ir da folha, por isso só o INSS do PLS entra na soma

	// Carreg a Tabela de I.R.									
	
	If 	!cargaIr(@aTabIr,aIrrf[i,1]+aIrrf[i,2])
		return({0,0,.f.,"Tabela de imposto de renda nao encontrada"})
	endif
	
	// Calcula IR  - aPD                         					
	
	If !(lTypecSem)
		If Type("cSemana") == "C"
			lTypecSem := .T.
		EndIf
	endIf

	If lTypecSem .AND. empTy(cSemana) //Variável utilizada no GPE para apuração da base de cálculo, é importante ter o [" "] se não for setada pelas rotinas de lá
		cSemana := " "
	endIf

	If cDepIr > '00'
					
		//O mesmo dependente só pode ser abatido uma vez da base pro IR
		//vamos buscar o quanto já foi deduzido pra não abater o mesmo dependente a cada lote gerado
		cSql := " SELECT 1 "
		cSql += "   FROM " + RetSqlName("BMR") + " BMR "
		cSql += "  WHERE BMR_FILIAL = '" + xFilial('BMR') + "' "
		cSql += "    AND BMR_OPERDA = '" + PlsIntPad() + "' "
		cSql += "    AND BMR_CODRDA = '" + cCodRda + "' "
		cSql += "    AND BMR_OPELOT = '" + cOpeLote + "' "  
		If lBMR_ANOVCT .and. lBMR_MESVCT
			cSql += "AND BMR_ANOVCT = '" + StrZero(Year(dVencto),4) + "' "
			cSql += "AND BMR_MESVCT = '" + StrZero(Month(dVencto),2) + "' "
		Else
			cSql += "AND BMR_ANOLOT = '" + StrZero(Year(dVencto),4) + "' "
			cSql += "AND BMR_MESLOT = '" + StrZero(Month(dVencto),2) + "' "
		EndIf
		cSql += "AND BMR.BMR_CODLAN = '1A1' "
		cSql += "AND BMR.D_E_L_E_T_ = ' ' " 

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB",.F.,.T.)

		If !TRB->(Eof())
			cDepIr  := "00"
		EndIf
		TRB->(dbCloseArea())
		
	Endif

	fCIr(aCodfol,aTabir,,dVencto,cFilProc,cDepIr,"M")		
	
	// Busca valores IR calculados              					
	
	nValBaseIr	:= abs(fBuscaPd(aCodFol[015,1],"V"))
	nValIr		:= noround(abs(fBuscaPd(aCodFol[066,1],"V")) - aIrrf[i,4] - nVirFol,2)
	
	If nValIr >= nVrIRRet
		nValIr   -= nVrIRRet
		nVrIRRet := 0
	Else
		nVrIRRet -= nValIr
		nValIr   := 0
	EndIf
	
	// Grava titulo de IRRF                     					 
	If nValIr < GetNewPar("MV_VLRETIR",0)
		nValIr := 0
	EndIf

	iF Val(cDepIr) > 0 .AND. nValIr > 0
		nRedDep := noround(abs(fBuscaPd(aCodFol[059,1],"V")))
		
		aBMR := {cCodOpe,cCodRda,cOpeLote,cAno,cMes,SUBS(cLote,7,4),"1A1",nRedDep,"3",StrZero(Year(dVencto),4),StrZero(Month(dVencto),2)}
		
		GravaBMR(aBMR,lBMR_ANOVCT,lBMR_MESVCT)

	Endif

	nVlrSE2 := noround(nValIr,2)
			
	RestArea(aArea)
next

// Checa se foi calculado imposto durante a execução desta função 
If  (nBIrPls + nBInsPfPls + nBInsPjPls + nBInsJFPls + nBInsHPPls + nBInsUNPls + nScoOutEmp) > 0 .or. (lUltCalc .And. aImpMes[2]+aImpMes[4]+aImpMes[6]+aImpMes[23]+aImpMes[10]+aImpMes[26] > 0)
	lRet := .T.
endif

If  ! lRet .and. lGraImp 
	cRet	:= "Nenhum imposto a calcular"
	nValIr 	:= 0
Endif

// Fim da funcao               						    

nAuxRetImp := nInssFis + nInssJur + nInssJF + nInssHP + nInssUN

if ( nAuxRetImp <= GetNewPar("MV_VLRETIN",0) )
	nAuxRetImp := 0
endIf

return({nValIr , nAuxRetImp, lRet , cRet })

/*/{Protheus.doc} fIndSEFIP
Procura SEFIP	
@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Static Function fIndSEFIP(cCodEmp, cConEmp, cSubCon, cMatric, cCalcImp, aSEFIP, cVerba)

Local nIndSEFIP

DEFAULT cVerba := ""

nIndSEFIP := aScan(aSEFIP, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == cCodEmp+cConEmp+cSubCon+cMatric+cCalcImp})
If nIndSEFIP == 0
	aAdd(aSEFIP, { cCodEmp, cConEmp, cSubCon, cMatric, cCalcImp, 0, 0, 0, 0 , cVerba})
	nIndSEFIP := Len(aSEFIP)
EndIf

Return nIndSEFIP


/*/{Protheus.doc} PLSPgtMes
Acumula as bases e os impostos ja gerados no mes para um determinado RDA e retorna um array com estes valores.

array[1] = Inss Outras Empresas (Cod Lancto 170)   
array[2] = Base INSS PJ         (Cod Lancto 194)   
array[3] = INSS PJ              (Cod Lancto 195)   
array[4] = Base INSS PF         (Cod Lancto 192)   
array[5] = INSS PF              (Cod Lancto 193)   
array[6] = Base IRRF            (Cod Lancto 198)   
array[7] = IRRF                 (Cod Lancto 199)   
array[8] = Prov Inss PJ / Unico	(Cod Lancto 179)       
array[9] = Prov Inss PF        	(Cod Lancto 180)   
array[10] = Base Inss JF      	(Cod Lancto 196 )    	
array[11] = Inss JF          	(Cod Lancto 197)   
array[12] = Prov Inss JF        (Cod Lancto 178)   
array[21] = Red. parcela IRRF PF(Cod Lancto 169)   
array[22] = Inss Hon.Patronal   (Cod Lancto 168)   
array[23] = Base INSS Hon.Patronal(Cod Lancto 167) 
array[24] = Prov.INSS Hon.Patronal(Cod Lancto 166) 
array[26] = Base INSS Unico     (Cod Lancto 182)   
array[27] = INSS Unico          (Cod Lancto 183)   

array[28] = Dependentes (cod 1A1)

Desta forma, e' possivel compor corretamente as bases dos  
impostos e calcular quantos pagamentos forem necessarios,  
no mes, para um mesmo RDA.                         

@author  PLS TEAM
@version P12
@since   21.03.17
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
Local nDependente 	:= 0

//Local cChave     := ''
Default cOpeRda		:= PlsIntPad()
Default aTpCalc		:= { .T., .T., .T. }
Default cAnoVct		:= cAno
Default cMesVct		:= cMes
Default cCalcImp	:= ''
Default lUltCalc	:= .F.

BAU->(dbSetOrder(1))
BAU->(msSeek(xFilial("BAU")+cCodRDA,.F.))
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
	
	// Monta query                                                    
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
		
	// Executa query                                                  
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	TcSetField("TRB","BMR_VLRPAG","N",nVlPrec,nVlDec)
	TcSetField("TRB","BMR_RECNO","N",16,0)
	
	// Processa arquivo de trabalho                                   
	
	Do While ! TRB->(Eof())

		// Se primeira vez e pela emissao, ou segunda vez e pelo vencimento, ou nao existem os campos pelo vencimento, executa o calculo do IRRF
		If ( nVez==1 .and. aTpCalc[1]) .or. ( nVez == 2 .and. !aTpCalc[1] )
			Do Case
				Case TRB->BMR_CODLAN == "198" ; nBIrrf  += 			Trb->BMR_VLRPAG  // base IRRF
				Case TRB->BMR_CODLAN == "199" ; nIrrf   += 			Trb->BMR_VLRPAG  // IRRF
				Case TRB->BMR_CODLAN == "184" ; nBIss   += 			Trb->BMR_VLRPAG  // base ISS
				Case TRB->BMR_CODLAN == "185" ; nIss    += 			Trb->BMR_VLRPAG  // ISS
		      	Case TRB->BMR_CODLAN == "169" ; nRedParIR   += 		Trb->BMR_VLRPAG  // Red. Parcela IRRF	
				Case TRB->BMR_CODLAN == "1A1" ; nDependente   += 		Trb->BMR_VLRPAG  // Red. Parcela IRRF	
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

Return( { nInsOutEmp, nBInsPJ, nInssPJ, nBInsPF, nInssPF, nBIrrf, nIrrf, nProvPJ, nProvPF, nBinsJF/*10*/, nInssJF, nProvJF, nBPIS, nPIS, nBCof, nCof, nBCsll, nCsll, nBIss, nISS/*20*/, nRedParIR, nInssHP, nBInsHP, nProvHP, nVlrProd, nBInsBU, nInssBU, nDependente } )

/*/{Protheus.doc} PLSPgtMes
Calcula o INSS PF e INSS PJ para cada registro do B15 e
       grava os campos correspondentes. Tem como base os valores  
       encontrados no BMR e vai deduzindo o valor ate zerar.                   

@author  PLS TEAM
@version P12
@since   21.03.17
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
	BAU->(msSeek(xFilial('BAU')+cCodRDA,.F.))
EndIf

// Se base única no RDA, trata tudo como percentual do pessoa jurídica
If BAU->BAU_BASINS == '1'
	nPercFis := nPercJFi := nPercHoP := nPercJur
EndIf	

BMR->(DbSetOrder(1))
BMR->(msSeek(xFilial("BMR")+cOpeLote+cCodRDA+cOpeLote+cAno+cMes,.F.))

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
	B15->(msSeek(xFilial("B15")+cOpeLote+cAno+cMes+cCodRDA,.F.))

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

			B15->(RecLock("B15", .F.))
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


/*/{Protheus.doc} PlsAjSEFIP
Trata valores negativos que existirem no array "aSEFIP"
       para evitar diferencas no calculo do INSS na tabela B15.   
       BOPS 104251.                

@author  PLS TEAM
@version P12
@since   21.03.17
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

/*/{Protheus.doc} PlsBGQLanc
Trata BGQ              

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Static Function PlsBGQLanc(cCodLanc,cTipSer,nOrdBAU,nRecBAU,nOrdSA2,nRecSA2,aCritica,cAno,cMes,cAtivo,nVlrLanc,cDescCri)


BBB->(DbSetOrder(1))
If ! BBB->(msSeek(xFilial("BBB")+cCodLanc,.F.)) .Or. BBB->BBB_TIPSER == cTipSer
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


/*/{Protheus.doc} GravaBMR
Funcao generica para gravar BMR	
@author  PLS TEAM
@version P12
@since   21.03.17
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


/*/{Protheus.doc} Pls498DesG
Função para trazer o código e descrição das Glosas no padrão TISS 
@author  PLS TEAM
@version P12
@since   21.03.17
/*/
Function Pls498DesG(cCodGlo,cCodOpe,cCodLdp,cCodPeg,cNumero,cOriMov,cCodPad,cCodPro,cSequen,nFlagRet)

LOCAL cDesGlo		:= ""
LOCAL cDesTmp		:= ""
LOCAL aAreaBDX		:= BDX->(GetArea())
LOCAL aAreaBCT		:= BCT->(GetArea())
LOCAL nTotGlo		:= 0
LOCAL cCdTerm		:= ""
LOCAL cCdGlTiss		:= ""
LOCAL aCodGloTis	:= {}

DEFAULT cCodGlo		:= ""
DEFAULT cCodOpe 	:= ""
DEFAULT cCodLdp 	:= ""
DEFAULT cCodPeg 	:= ""
DEFAULT cNumero 	:= ""
DEFAULT cOriMov 	:= ""
DEFAULT cCodPad 	:= ""
DEFAULT cCodPro 	:= ""
DEFAULT cSequen 	:= ""
DEFAULT nFlagRet	:= 0 //Flag criada para cambiar o processo -> 0 = Retorno Antigo / 1 = Retorno antigo com códigos de Glosa conforme Terminologi TISS (tabela 38) / 2 = Processo igual ao '=1' com retorno em array de códigos de glosas

If !Empty(cCodGlo)

	BCT->(DbSetOrder(1))//BCT_FILIAL+BCT_CODOPE+BCT_PROPRI+BCT_CODGLO
	If BCT->(MsSeek(xFilial("BCT")+cCodOpe+cCodGlo))
		
		if nFlagRet > 0 
			cDesGlo := BCT->BCT_DESTIS
        endif
		if empty(cDesGlo) .or. nFlagRet == 0 
			cDesGlo := BCT->BCT_DESCRI
		endif
			
		cCdTerm := PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  cCodGlo )
    	If Empty(cCdTerm)
			cCdTerm := BCT->BCT_GLTISS
    	Endif
		aAdd(aCodGloTis,cCdTerm)
	EndIf
ElseIf !Empty(cCodLdp+cCodPeg+cNumero+cOriMov+cCodPad+cCodPro+cSequen)

	BDX->(DbSetOrder(1))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO
	If BDX->(MsSeek(xFilial("BDX")+cCodOpe+cCodLdp+cCodPeg+cNumero+cOriMov+cCodPad+cCodPro+cSequen))
		
		cCodGlo := BDX->BDX_CODGLO
		cDesGlo := AllTrim(PadR(BDX->BDX_DESGLO,50))
		cCdTerm := PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  cCodGlo )

		If nFlagRet > 0 .and. BCT->(MsSeek(xFilial("BCT")+cCodOpe+cCodGlo))
			if nFlagRet == 3
				cDesGlo :=  AllTrim(BCT->BCT_DESTIS)
			else
				cDesGlo :=  AllTrim(PadR(BCT->BCT_DESTIS,50))
			endif
		Endif
		
		If !Empty(cCodPad+cCodPro+cSequen)
			While !BDX->(Eof()) .AND. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) ==;
										xFilial("BDX")+cCodOpe+cCodLdp+cCodPeg+cNumero+cOriMov+cCodPad+cCodPro+cSequen				
				If !Empty(BDX->BDX_NIVEL) .and. BDX->BDX_ACAO != "2" .and. BDX->BDX_ACAOTX != "2"
					nTotGlo++
					cDesTmp := ""
					//Pego o Código TISS da glosa
					cCdGlTiss := PLSGETVINC("BTU_CDTERM", "BCT", .F., "38",  BDX->BDX_CODGLO )
					cDesTmp += cCdGlTiss + " - "					
					//Pego a descrição TISS
					If BCT->(MsSeek(xFilial("BCT")+cCodOpe+BDX->BDX_CODGLO)) .and. !empty(AllTrim(BCT->BCT_DESTIS))
						cDesTmp += alltrim(BCT->BCT_DESTIS)
					Else
						cDesTmp += alltrim(BDX->BDX_DESGLO)
					Endif
					if nFlagRet <> 3					
						cDesTmp += AllTrim(PadR(cDesTmp,50)) + " / "
					endif
					aAdd(aCodGloTis,cDesTmp)
					
				Endif	
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

If nFlagRet <= 1
	Return {cCodGlo, cDesGlo, cCdTerm}
Else
	Return aCodGloTis
Endif

/*/{Protheus.doc} PLFOLMES
Função para substituir o parâmetro MV_FOLMES, que foi descontinuado
@type function
@author PLS TEAM
@since 16/07/2018
@version 1.0
/*/
Function PLFOLMES(cANOMES, DDATAREF)
Local aPerAber  := {}
Local aPerFech  := {}
Local cPeriodo  := ""
Local cNrPagto  := ""
Local cAno      := ""
Local cMes      := ""
Local xDtRef	:= nil
Local dDtRef	:= SToD("")
Local lPerAtual	:= .F.

Default DDATAREF := Nil

If !Empty(cANOMES)
    cAno := SubStr(cANOMES,1,4)
    cMes := SubStr(cANOMES,5,2)
Else
	xDtRef := Iif(DDATAREF == NIL, DDATABASE, DDATAREF)
	dDtRef := AnoMes(xDtRef)
	cAno := SubStr(dDtRef,1,4)
	cMes := SubStr(dDtRef,5,2)
EndIf

FRETPERCOMP(cMes , cAno , NIL , SRA->RA_PROCES, NIL, @aPerAber, @aPerFech)

Asort( aPerAber,,, { |x,y| x[1] + x[2] < y[1] + y[2] } )
Asort( aPerFech,,, { |x,y| x[1] + x[2] < y[1] + y[2] } )

If !Empty(aPerAber)
	cPeriodo := aPerAber[1,1]
	cNrPagto := aPerAber[1,2]
	lPerAtual := .T.
ElseIf !Empty(aPerFech)
	cPeriodo := aPerFech[1,1]
	cNrPagto := aPerFech[1,2]
EndIf

Return {lPerAtual,aPerAber}


/*/{Protheus.doc} getVerbaGen

@type function
@author Oscar
@since 02/05/2019
@version 1.0
/*/
static function getVerbaGen(cAliasBMR, cTpUsr, cCodOpe, cCodLan)
local cTipCalc	:= ""
local cVerba	:= ""
default cTpUsr 	:= ""

if BLS->(msseek(xfilial("BLS") + cCodOpe + cCodLan))		

	cTipCalc := "1"
	
	while !BLS->(eof()) .and. alltrim(cCodLan) == alltrim(BLS->BLS_CODLAN) 
		if cTipCalc == BLS->BLS_CALIMP .and. (empty(cTpUsr) .or. (!empty(cTpUsr) .and. cTpUsr == BLS->BLS_TIPOCT))
			cVerba	:= BLS->BLS_VERBA
			exit
		endif
		BLS->(dbskip())
	enddo
endif

if empty(cVerba) .and. BLR->(msseek(xfilial("BLR") + cCodOpe + cCodLan)) .and. !empty(BLR->BLR_VERBA)
	cVerba	:= BLR->BLR_VERBA
endif

return cVerba

static function Chk170(cCodOpe, cCodRda, cAno, cMes)

Local lRet := .T.
Local cSql := ""

cSql += " Select count(1) TEM from " + RetsqlName("BMR") + " BMR "
cSql += " Where "
cSql += " BMR_FILIAL = '" + xfilial("BMR") + "' "
cSql += " AND BMR_OPERDA = '" + cCodOpe + "' "
cSql += " AND BMR_CODRDA = '" + cCodRda + "' "
cSql += " AND BMR_ANOLOT = '" + cAno + "' "
cSql += " AND BMR_MESLOT = '" + cMes + "' "
cSql += " AND BMR_CODLAN = '170' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB170",.F.,.T.)

If TRB170->TEM > 0
	lret := .F.
endIf

TRB170->(dbcloseArea())
return lRet
