#INCLUDE "PLSA510.CH"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#DEFINE TIPOS_COPARTICIPACAO BM1->BM1_CODTIP == "104" .Or. BM1->BM1_CODTIP == "116" .Or.;
BM1->BM1_CODTIP == "117" .Or. BM1->BM1_CODTIP == "123" .Or.;
BM1->BM1_CODTIP == "124" .Or. BM1->BM1_CODTIP == "125" .Or.;
BM1->BM1_CODTIP == "127" .Or. BM1->BM1_CODTIP == "137" .or.;
BM1->BM1_CODTIP == "138" .or. BM1->BM1_CODTIP == "139" .or.;
BM1->BM1_CODTIP == "140" .or. BM1->BM1_CODTIP == "141" .or.;
BM1->BM1_CODTIP == "142" .or. BM1->BM1_CODTIP == "143" .or.;
BM1->BM1_CODTIP == "144" .or. BM1->BM1_CODTIP == "145" .or.;
BM1->BM1_CODTIP == "147" .or. BM1->BM1_CODTIP == "148" .or.;
BM1->BM1_CODTIP == "149" .or. BM1->BM1_CODTIP == "150" .or.;
BM1->BM1_CODTIP == "151" .or. BM1->BM1_CODTIP == "152" .or.;
BM1->BM1_CODTIP == "153" .or. BM1->BM1_CODTIP == "154" .or.;
BM1->BM1_CODTIP == "155" .or. BM1->BM1_CODTIP == "156" .or.;
BM1->BM1_CODTIP == "157" .or. BM1->BM1_CODTIP == "158" .or.;
BM1->BM1_CODTIP == "159" .or. BM1->BM1_CODTIP == "160" .or.;
BM1->BM1_CODTIP == "161" .or. BM1->BM1_CODTIP == "162" .or.;
BM1->BM1_CODTIP == "163" .or. BM1->BM1_CODTIP == "164" .or.;
BM1->BM1_CODTIP == "165" .or. BM1->BM1_CODTIP == "166" .or.;
BM1->BM1_CODTIP == "167" .or. BM1->BM1_CODTIP == "168" .or.;
BM1->BM1_CODTIP == "169" .or. BM1->BM1_CODTIP == "170" .or.;
BM1->BM1_CODTIP == "171" .or. BM1->BM1_CODTIP == "172" .or.;
BM1->BM1_CODTIP == "173" .or. BM1->BM1_CODTIP == "174" .or.;
BM1->BM1_CODTIP == "175" .or. BM1->BM1_CODTIP == "176" .or.;
BM1->BM1_CODTIP == "177" .or. BM1->BM1_CODTIP == "182" .or.;
BM1->BM1_CODTIP == "183"

Static cCodDB 	    := PLSRETLADC()
Static lPlGrvBm1    := ExistBlock("PLGRVBM1")
Static __lBSQFields := BSQ->(FieldPos("BSQ_INCIR"))  > 0 .and. BSQ->(FieldPos("BSQ_REGCIR")) > 0 .and. BSQ->(FieldPos("BSQ_INCISS")) > 0 .and.;
	                   BSQ->(FieldPos("BSQ_REGCIS")) > 0 .and. BSQ->(FieldPos("BSQ_INCCON")) > 0 .and. BSQ->(FieldPos("BSQ_REGCCO")) > 0 .and.;
	                   BSQ->(FieldPos("BSQ_INCPIS")) > 0 .and. BSQ->(FieldPos("BSQ_REGCPI")) > 0 .and. BSQ->(FieldPos("BSQ_INCCSL")) > 0 .and.;
	                   BSQ->(FieldPos("BSQ_REGCCS")) > 0 .and. BSQ->(FieldPos("BSQ_INCINS")) > 0 .and. BSQ->(FieldPos("BSQ_REGCIN")) > 0
static __lBM1COB	:= BM1->(fieldPos('BM1_COBRET')) > 0 .and. BM1->(fieldPos('BM1_COBATU')) > 0 .and. BM1->(fieldPos('BM1_DIAUTI')) > 0
static lBM1_VERSIG  := BM1->(fieldPos("BM1_VERSIG")) > 0
static lBM1_AGFMTFU := BM1->(fieldPos("BM1_AGMTFU")) > 0 .and. BM1->(fieldPos("BM1_AGFTFU")) > 0
static lBM1_VALMES  := BM1->(fieldPos("BM1_VALMES")) > 0
static lBM1_ATOCOO  := BM1->(fieldPos("BM1_ATOCOO")) > 0
static lBM1_NUMPAR  := BM1->(fieldPos("BM1_NUMPAR")) > 0
static lBM1_IDAINI	:= BM1->(fieldPos("BM1_IDAINI")) > 0
static lBM1_IDAFIN	:= BM1->(fieldPos("BM1_IDAFIN")) > 0
static lBM1_TIPINT	:= BM1->(fieldPos("BM1_TIPINT")) > 0
static lBM1_VALDES  := BM1->(fieldPos("BM1_VALDES")) > 0
static lBM1_VALACR	:= BM1->(fieldPos("BM1_VALACR")) > 0
static lBM1_CODSEQ	:= BM1->(fieldPos("BM1_CODSEQ")) > 0
static lBM1_CVDPLA	:= BM1->(fieldPos("BM1_CODPLA")) > 0 .and. BM1->(fieldPos("BM1_VERPLA")) > 0 .and. BM1->(fieldPos("BM1_DESPLA")) > 0
static lBM1_CODTES	:= BM1->(fieldPos("BM1_CODTES")) > 0
static lBM1_CSTCP 	:= BM1->(fieldPos("BM1_CSTCOF")) > 0 .and. BM1->(fieldPos("BM1_CSTPIS")) > 0 
static lBM1_NATURE	:= BM1->(fieldPos("BM1_NATURE")) > 0
static lBM1_CODSB1	:= BM1->(fieldPos("BM1_CODSB1")) > 0
static __cFunName	:= funName()

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

/*/{Protheus.doc} PLGERREC
Gerar titulo para um contrato do plano de saude. 

@author  PLS TEAM
@version P12
@since   14.06.00
/*/
Function PLGERREC(  cPrefixo,; 		// 1
					cNumero,;		// 2
					_cChave,;		// 3
					cMes,;			// 4
					cAno,;			// 5
					dVencto,;		// 6
					cNumCob,;		// 7
					nValor,;		// 8
					cNossoN,;		// 9
					cCodCli,;		// 10
					cLoja,;			// 11
					cTipo,;			// 12
					aVlrCob,;		// 13
					_cNivel,;		// 14
					aMatBa3,;		// 15
					cGratuito,;		// 16
					lAberto,;		// 17
					nCobComple,;	// 18
					lInterC,;		// 19
					lConsiste,;		// 20
					cBanco,;		// 21
					cSitE1,;		// 22
					cNaturez,;		// 23
					cCusOpe,;		// 24
					cOrig,;  		// 25
					cTipoPag,; 		// 26 - Tipo de pagamento
					cPortado,;		// 27 - Portador
					cAgePor,;		// 28 - Agencia portador
					cCCPor,;		// 29 - Conta corrente portador
					cBcoCli,;		// 30 - Banco cliente
					cAgeCli,;		// 31 - Agencia cliente
					cCCCli,;		// 32 - Conta cliente
					dEmissao,;		// 33 - Data de Emissao.
					lCritica,;		// 34 - Critica, SIM ou NAO
					lContabiliza,;	// 35 - Liga ou desliga a contabilizacao on-line
					aRecnos,;		// 36 - Recnos 
					aRetAcu,; 		// 37 - Acumulado p proxima competencia
					nValAcu,;		// 38 - Valor acumulado.
					cCodInt,;		// 39 - Codigo da operadora.
					aEventosCb,;	// 40 - Eventos da cobranca
					aAcertos,;		// 41 - Eventos da cobranca por valores acumulado.
					aLanUsu,;		// 42 - Eventos da cobranca do usuario.
					nPLGERREC,;		// 43 - 
					aMatFree,;		// 44 -
					lNCC,;			// 45 - Define se e NCC
					xNotUsed,;		// 46 - Disponivel para uso
					lGerNumT,;		// 47 - Gera o proximo numero do titulo apos checagem de criticas
					cTTit,;			// 48 - Tipo usada na funcao plsa625MDA 
					cOTit,;			// 49 - Origem usada na funcao plsa625MDA 
					lPeriod,;       // 50 - Verifica se é Periodicidade
					nPeriod,;       // 51 - Numero de meses da Periodicidade      
					cTipCob,;       // 52 - Tipo de cobranca Ptu A500 / 1-NDC 2-Fatura 3-Ambos
					nPosIntTit,;    // 53 - Posicao titulo intercambio
                    aCredit,;       // 54 - Conteudo que sera gerado NCC para apuracao da base de impostos
					lRatImpost)		// 55 - Gravação do Rateio de Impostos

LOCAL nOrdSE1 		:= SE1->(indexOrd())
LOCAL nRecSE1 		:= SE1->(recno())
LOCAL nOrdBA3 		:= BA3->(indexOrd())
LOCAL nRecBA3 		:= BA3->(recno())
LOCAL bRest   		:= { || SE1->(dbSetOrder(nOrdSE1)), SE1->(dbGoTo(nRecSE1)) }
LOCAL bRestBA3 		:= { || BA3->(dbSetOrder(nOrdBA3)), BA3->(dbGoTo(nRecBA3)) }
LOCAL nI			:= 1
LOCAL nInd			:= 0
LOCAL nPosMat  		:= 0
LOCAL nPosLanc		:= 0
Local nCnt			:= 0
LOCAL nJurDir		:= 0
LOCAL nTaxDia		:= 0
Local nRegBBT		:= 0
Local nPos			:= 0
LOCAL nPosNpr		:= 0
Local nDecresc 		:= 0
LOCAL nSeq			:= 0 
LOCAL nVlrBDF		:= 0
Local nDias			:= superGetMv("MV_PLSDVEN", .f., 0)
LOCAL cSQL          := ""
Local cSeq			:= "000"
Local _cMatric 		:= ""
LOCAL cInterc		:= "0"
LOCAL cNumPar		:= "001"
LOCAL cTipInt 		:= ""
Local cOpeDes		:= ""
Local cRisco		:= ""
LOCAL cModPag   	:= ""
Local cMatUsu 		:= ""
LOCAL cAnoMesAnt	:= ""
LOCAL cIncPIS   	:= ""
LOCAL cBasPIS   	:= ""
LOCAL cIncIRRF  	:= ""
LOCAL cBasIRRF  	:= ""
LOCAL cIncCOFI  	:= ""
LOCAL cBasCOFI  	:= ""
LOCAL cIncISS   	:= ""
LOCAL cBasISS   	:= ""
LOCAL cIncCSLL  	:= ""
LOCAL cBasCSLL  	:= ""
LOCAL cIncINSS  	:= ""
LOCAL cBasINSSN 	:= ""
LOCAL cBasINSS1 	:= ""
LOCAL cAnoRef		:= ""
LOCAL cMesRef		:= ""
LOCAL cTipoSer		:= ""
LOCAL cChvSRC		:= ""
Local cPlsTip		:= superGetMv("MV_PLSTIP", .F., "DP ")
LOCAL lGerSE1		:= .T.
LOCAL lVldFIELD		:= BA1->( fieldPos("BA1_TXADOP") ) > 0 .And. BA1->( fieldPos("BA1_VLTXOP") ) > 0
LOCAL lGerNFBRA 	:= ( getNewPar("MV_PLSNFBR","0") == "1" .Or. cPaisLOC <> 'BRA' )
LOCAL aMatBA1		:= {}
LOCAL aNumTit		:= {}
LOCAL aRetPto		:= {}
LOCAL aMatNmPr		:= {}
Local aJuros		:= {}
LOCAL aVetAux		:= {}
LOCAL aAcuFun 		:= {}
LOCAL aFoCoPF		:= {}
LOCAL aVlrDebCre	:= {}
LOCAL aPL510BM1		:= {}
LOCAL aCritica 		:= {}
LOCAL aCpoSE1		:= {}
LOCAL aVlrLanc		:= {}
LOCAL aAuxMat  		:= {}                                      
LOCAL aBases		:= {0,0,0,0,0,0}
LOCAL aBasAx		:= {0,0,0,0,0,0}
LOCAL lDatPagto     := getNewPar("MV_PLSDTPG",.F.)
LOCAL aBanco        := {}
LOCAL lCusOpe		:= Iif(cCusOpe=='1',.T.,.F.)
LOCAL lCMALCO		:= getNewPar("MV_CMALCO",.T.)
LOCAL cOrigem 		:= "PLSA510"
LOCAL cNatRet		:= ""
LOCAL lBaixaCan		:= .F.
Local lDirf11 	    := .T. 
Local lFolha      	:= .F.
local lErro			:= .f.
Local lLoteInter	:= isInCallstack("PLSA628")
Local aRateioImp	:= {}
Local aRateioNCC	:= {}

DEFAULT nPLGERREC	:= 0
DEFAULT nValAcu		:= 0
DEFAULT  _cNivel 	:= "1"
DEFAULT cGratuito 	:= ""
DEFAULT cBanco		:= ''
DEFAULT cSitE1		:= '0'
DEFAULT cOrig 		:= ""
DEFAULT cTipoPag	:= ''
DEFAULT cPortado	:= ''
DEFAULT cAgePor		:= ''
DEFAULT cCCPor		:= ''
DEFAULT cBcoCli		:= ''
DEFAULT cAgeCli		:= ''
DEFAULT cCCCli		:= ''
DEFAULT cTTit		:= ""
DEFAULT cOTit		:= ""
DEFAULT cCodInt		:= PlsIntPad()
DEFAULT lAberto 	:= .T.
DEFAULT lConsiste 	:= .T.
DEFAULT	lInterC		:= .F.
DEFAULT lCritica	:= .T.
DEFAULT lContabiliza:= .F.
DEFAULT lNCC        := .F.
DEFAULT xNotUsed    := nil
DEFAULT lGerNumT	:= .F.
DEFAULT aRetAcu		:= {}
DEFAULT aRecnos		:= {}
DEFAULT aEventosCb	:= {}
DEFAULT aAcertos	:= {}
DEFAULT aLanUsu		:= {}
DEFAULT aMatFree	:= {}
DEFAULT aCredit     := {}
DEFAULT dEmissao	:= Ctod("")
DEFAULT lPeriod		:= .F.
DEFAULT nPeriod		:= 0
DEFAULT cTipCob     := ''
DEFAULT nPosIntTit  := 0 
DEFAULT lRatImpost  := .F. 

PRIVATE nIdaFai   	:= 0
PRIVATE lIntPos   	:= .F.

//Posiciono na familia correta...                                     
If aMatBa3 <> Nil .And. Len(aMatBa3) > 0
	BA3->( DbGoto( aMatBa3[ Len(aMatBa3) ] ) )
EndIf

_cMatric := BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC)

//Tratamento da forma de leitura da Participacao Financeira           
aFoCoPF := PLSRETFCPF(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
					  BA3->BA3_VERSUB,BA3->BA3_CODPLA,BA3->BA3_VERSAO,cTipo)
					  
If aFoCoPF[1] == "1" .OR. lLoteInter
	cAnoMesAnt := cAno+cMes
Else
	cAnoMesAnt := PLSDIMAM(cAno,cMes,"0")
EndIf                 
              
If aFoCoPF[2] == "3"
	lGerSE1 := .f.
	lFolha	:= .t.
EndIf           

//Posiciona no funcionario                                            
If ! lGerSE1
	
	SRA->( DbSetOrder(1) )
	
	If ( Empty(BA3->BA3_AGFTFU) .Or. Empty(BA3->BA3_AGMTFU) .Or. !SRA->( MsSeek(BA3->BA3_AGFTFU+BA3->BA3_AGMTFU) ) )
		A627RetCri(@aCritica, '21', nValor)
	EndIf       

	if  (Ascan(aVlrCob,{|x| AllTrim(x[71]) == ""}) > 0 .or. Ascan(aVlrCob,{|x| AllTrim(x[22]) == ""})>0) .And. aFoCoPF[2] == "3"  //cod. plano 
		A627RetCri(@aCritica, '28', 0)	
	Endif 	
	
EndIf

//Se o lote estiver zerado, eu não gero titulo na SE1...	     							    
If (nValor + nValAcu) == 0
	lGerSE1 := .f.
EndIf

// novo ponto de entrada para retornar natureza. Neste ponto é possivel enviar mais informações do que no PL627NAT, como
// por exemplo, se o titulo que esta sendo gerado é de custou ou pre-pagamento.
cNatRet := ""
If ExistBlock("PL510NAT")

	cNatRet := ExecBlock("PL510NAT",.F.,.F.,{cTipo,cNaturez,(cCodCli+cLoja),(BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO), _cNivel, cCusOpe})
	
	// Natureza customizada.
	If !Empty(cNatRet)
		cNaturez := cNatRet
	Endif

Endif

//Se nao houver natureza cadastrada no nivel de cobranca, pega padrao.
If Empty(cNaturez) .Or. Valtype(cNaturez) == "U"
	cNaturez := SuperGetMv("MV_PLSNAT", .F., "PLS")
EndIf

//Posiciono a natureza do titulo...                                   
If ! lGerNFBRA
	
	SED->( dbSetorder(01) )                    
	If ! SED->( MsSeek(xFilial("SED")+cNaturez) )
		A627RetCri(@aCritica, '14', nValor)
	EndIf

EndIf

//Trata data de vencimento...                                         
If Empty(dVencto)
	A627RetCri(@aCritica, '05', nValor)    
Endif

//Posiciona no produto...                                             
If ! lInterC
	
	BI3->(DbSetOrder(1))
	If ! BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
		A627RetCri(@aCritica, '11', nValor)
	Else
		cTipTit := If(Empty(BI3->BI3_TIPTIT), cPlsTip, BI3->BI3_TIPTIT)
	Endif

Else
	cTipTit := cPlsTip
EndIf   

//Conforme o tipo do ERP												
If lGerNFBRA
	cTipTit := MVNOTAFIS
EndIf          

//Tipo do Titulo NCC													
If lNCC
	cTipTit := MV_CRNEG
EndIf

//Tratamentos PESSOA JURIDICA...                                      
If cTipo == "2"
	
	//Posiciona o grupo empresa...                                             
	BG9->(DbSetOrder(1))
	If !BG9->(MsSeek(xFilial("BG9")+BA3->BA3_CODINT+BA3->BA3_CODEMP)) .And. lCritica
		A627RetCri(@aCritica, '13', nValor)
	Endif

	//Posiciona Contrato...                                                    
	BT5->(DbSetOrder(1))
	If ! BT5->(MsSeek(xFilial("BT5")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP)) .And. lCritica
		A627RetCri(@aCritica, '08', nValor)
	Endif

	//Tratamentos para intercambio...                               
	cInterc := Iif(Empty(BT5->BT5_INTERC),"0",BT5->BT5_INTERC)
	cTipInt := BT5->BT5_TIPOIN
	cOpeDes := BT5->BT5_OPEINT

	//Posiciona Subcontrato...                                           
	BQC->(DbSetOrder(1))
	If ! BQC->( MsSeek(xFilial("BQC") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)) ) .And. lCritica

		A627RetCri(@aCritica, '06', nValor)

	Endif

	//Posiciona produto da familia no subcontrato...  								  
	BT6->(DbSetOrder(1))
	If BT6->(MsSeek( xFilial("BT6")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB+BA3->BA3_CODPLA+BA3->BA3_VERSAO))

		lIntPos := .F.
		//Verifica se eh intercambio e nao eh pre-pagamento             
		if lInterc .and. BT6->BT6_MODPAG > "1"
			lIntPos := .T.
		endIf

		cModPag := BT6->BT6_MODPAG

	Endif

	//Trato gratuidade...                                                
	If cGratuito = "1" .and. lCritica
		A627RetCri(@aCritica, '04', nValor)
	Endif

//Tratamentos para PESSOA FISICA...                             
Elseif cTipo == "1"

	//Trato gratuidade...                                                
	BH5->(DbSetOrder(1))
	If BH5->(MsSeek(xFilial("BH5")+_cChave)) .and. lCritica

		If cAno+cMes >= BH5->(BH5_ANOINI+BH5_MESINI) .And. cAno+cMes <= BH5->(BH5_ANOFIM+BH5_MESFIM)
			A627RetCri(@aCritica, '04', nValor)
		Endif

	Endif
	
	//Trata cobranca de juros no mes seguinte...                    
	If BI3->BI3_COBJUR <> "1"
		nJurDir  := BI3->BI3_TAXDIA
		nTaxDia  := BI3->BI3_JURDIA
	Endif

	cModPag := BI3->BI3_MODPAG

Endif

//Tratamento para intercambio eventual...                       
If lInterc
	cInterc := '1'
Endif

//Posiciona no cliente...                                       
SA1->( DbSetOrder(1) )
If ! SA1->(MsSeek(xFilial("SA1")+cCodCli+cLoja))
	A627RetCri(@aCritica, '10', nValor)
Endif                                      

//Somente pega o prefixo para poder checar a critica abaixo			
If lGerNumT
	cPrefixo := PLSA625MDa(cAno,cMes,cTTit,cOTit,aMatBa3,_cNivel,_cChave,.T.,cCusOpe)[1]	
	cPrefixo := Eval({|| &cPrefixo })
EndIf	

//Consiste a data de emissao informada no lote de cobranca...	  
SE1->( dbSetorder(01) )
SE1->( msSeek(xFilial("SE1")+cPrefixo+Replicate("9",TamSX3("E1_NUM")[1]),.T.) )
SE1->( dbSkip(-1) )

If AllTrim(SE1->E1_PREFIXO) == AllTrim(cPrefixo) .And.	dEmissao < SE1->E1_EMISSAO .And.  GetNewPar('MV_PLSEMIS','1') =='1'
	A627RetCri(@aCritica, '22', nValor)
EndIf

//Se houve critica ate aqui, retorna imediatamente...           
If ExistBlock("PLS510AC")

	aRetPto := ExecBlock("PLS510AC",.F.,.F.,{_cNivel,_cChave,nValor,aCritica,cMes,cAno,cNumCob,aVlrCob,lGerSE1})
	
	nValor   := aRetPto[1]
	aCritica := aRetPto[2]
	aVlrCob  := aRetPto[3]
	
	If len(aRetPto) > 3 .And. Valtype(aRetPto[4]) == 'L'
		lGerSE1 := aRetPto[4]
	Endif 
	PLSLOGFAT("PLS510AC",1,.F.)

EndIf                                                                    

//Se tem critica retorna												
If Len(aCritica) > 0 .And. !aCritica[1][1] .And. aCritica[1][2] <>"26"
	Eval(bRest)
	Eval(bRestBA3)
	Return(aCritica)
EndIf    

//Gera o numero e o tipo do titulo...                      					
//Foi feito desta forma para que gere o numero do titulo apos tenha checado 	
//Todas as criticas - Evita de fazer lock no sx5 e sx6 para retornar o numero	
If lGerNumT 
	aNumTit  := PLSA625MDa(cAno,cMes,cTTit,cOTit,aMatBa3,_cNivel,_cChave,,cCusOpe)
	cPrefixo := aNumTit[1]
	cNumero  := aNumTit[2]
	cNossoN  := aNumTit[3]
EndIf	

//Ponto de entrada p/ retornar o Tipo do Título                 
If ExistBlock("PLS510TT")

	cTipTit := ExecBlock("PLS510TT",.F.,.F.,{cPrefixo,cNumero,cTipTit})
	PLSLOGFAT("PLS510TT",1,.F.)

EndIf

//Se os eventos de cobranca estiver em branco eu releio...      
If ValType(aEventosCb) == "U" 
	aEventosCb := aClone(SetEventos())
Endif
                     
If ValType(aAcertos) == "U" 
	aAcertos := aClone(SetEveAcu())
Endif

If ValType(aLanUsu) == "U" 
	aLanUsu := aClone(SetEveUsr())
Endif

//Atualiza arquivo de vias de boletos... Digo que foi emitida 1o. via.³
PLSUPT2BOL(_cMatric, dEmissao, 1, .T.)

If ! Empty(cBanco)
	SA6->(dbSetorder(01))
	SA6->( MsSeek(xFilial("SA6")+cBanco) )
ElseIf !Empty(cPortado+cAgePor+cCCPor)
	SA6->(dbSetorder(01))
	SA6->( MsSeek(xFilial("SA6")+cPortado+cAgePor+cCCPor) )
EndIf

Begin Transaction

//BBT																
nRegBBT := PLSGRVBBT(_cChave,_cNivel,cCodCli,cLoja,nValor,lCusOpe,lIntPos,cAno,cMes,cAnoMesAnt,;
					cPrefixo,cNumero,cTipTit,Subs(_cChave,1,4)+cNumCob,cInterc,cModPag,cTipInt,;
					cOpeDes,dEmissao)

//Grava historico do titulo...                                  
If _cNivel <= "5"

	If ExistBlock("PL510BM1")
		aPL510BM1 := Execblock("PL510BM1", .F., .F., aVlrCob)
		PLSLOGFAT("PL510BM1",1,.F.)
	EndIf

	//Grava acumulados para proxima competencia                     
	//O BK2 eh o espelho do BM1, mas soh que indica o acumulado		    
	PLSGRVBK2(aRetAcu,cAno,cMes,Subs(_cChave,1,4)+cNumCob,cPrefixo,cNumero,cTipTit)

	//For na matriz com valores											
	For nInd := 1 To Len(aVlrCob)

		//Regra de tipo de servico a ser gravado no BM1...              
		cTipoSer := ''
		
		If Len(aPL510BM1) > 0
		
			If (nPos := Ascan(aPL510BM1, { |x| x[1] == aVlrCob[nInd][3] .And. x[2] == aVlrCob[nInd][4]} )) <> 0
				cTipoSer := aPL510BM1[nPos][3]
			EndIf

		EndIf
		
		If Empty(cTipoSer)
			
			If (nPos := Ascan(aEventosCB, { |x| x[1] == aVlrCob[nInd][3] } )) <> 0
				cTipoSer := aEventosCB[nPos][19]
			EndIf

		EndIf

        //atualiza a matricula se mudar e retorna o risco
        cRisco := plsUsuRis(_cMatric, aVlrCob[nInd,7], @cMatUsu, cTipo)

		//Array com os totais de cada tipo de lancamento de faturamento...    
        if ! lNCC
		    PLSDCTIP(aVlrCob[nInd], cCodDB, cRisco, aVlrDebCre)
        endIf    

		//Array com os totais de cada tipo de lancamento de faturamento...    
		If (nPosLanc := Ascan(aVlrLanc, {|x| x[1] == aVlrCob[nInd,3] .and.;
											  x[3] == aVlrCob[nInd,4] .and.;
											  x[4] == cRisco })) == 0

			AaDd( aVlrLanc, {aVlrCob[nInd,3],;
							 aVlrCob[nInd,2],;
							 aVlrCob[nInd,4],;
							 cRisco} ) 

		Else
			aVlrLanc[nPosLanc][2] += aVlrCob[nInd,2]
		EndIf
		
		nPosMat := Ascan(aAuxMat, {|x| x[1] == Subs(cMatUsu,1,4)+Subs(cMatUsu,5,4)+Subs(cMatUsu,9,6)+Subs(cMatUsu,15,2) } )
		
		If nPosMat == 0
			AaDd(aAuxMat,{Subs(cMatUsu,1,4)+Subs(cMatUsu,5,4)+Subs(cMatUsu,9,6)+Subs(cMatUsu,15,2),"001"})
			nPosMat := Len(aAuxMat)
		Else
			aAuxMat[nPosMat,2] := StrZero(Val(aAuxMat[nPosMat,2])+1,3)
		EndIf

		//Obtem o numero da parcela do usuario...                       
		//Nao entra caso seja outros debitos/decritos para a empresa.			
		If ! Empty(cMatUsu) 
			
			//Para opcionais, deve-se considerar o codigo do produto.				
			If aVlrCob[nInd,3] == '102'
			
				nPosNpr := Ascan(aMatNmPr,{|x| 	x[1] == cMatUsu .and.;
												x[3] == aVlrCob[nInd,3] .and.;
												x[4] == aVlrCob[nInd,4] })

			Else
				nPosNpr := Ascan(aMatNmPr,{|x| 	x[1] == cMatUsu .and. x[3] == aVlrCob[nInd,3]})
			EndIf

			If nPosNpr == 0

				BM1->( dbSetorder(05) )
				If BM1->( MsSeek(xFilial("BM1")+cMatUsu) )

					cSql := " SELECT MAX(BM1_NUMPAR) MAXIMO FROM "+RetSqlName("BM1")+" "
					cSql += "  WHERE BM1_FILIAL = '"+xFilial("BM1")+"' "
					cSql += "    AND BM1_MATUSU = '"+cMatUsu+"' "
					cSql += "    AND BM1_CODTIP = '"+aVlrCob[nInd,3]+"' "

					//Para opcionais, deve-se considerar o codigo do produto.				
					If aVlrCob[nInd,3] == '102'
						cSql += "AND BM1_CODEVE = '"+aVlrCob[nInd,4]+"' "
					Endif

					cSql += "AND D_E_L_E_T_ = ' '"

					//Como se trata de uma QUERY simples e que roda em todos os bancos dados não precisamos utilizar ChangeQuery assim ganhando performance

					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"MAX",.F.,.T.) 
					
					If ! MAX->( Eof() )
						cNumPar := StrZero((Val(MAX->MAXIMO)+1),3)
					Else
						cNumPar := '001'
					Endif
					MAX->( dbCloseArea() )
				Else
					cNumPar := '001'
				Endif

				//Verifica se houve cobranca de mensalidade retroativa, caso haja, a parcela da 
				//mensalidade atual sera a 002, pois a mensalidade retroativa foi a 001.  
				If cNumPar == '001' .and. aVlrCob[nInd,3] == '101'

					If (nPosRet := Ascan(aVlrCob,{|x| 	x[7] == cMatUsu .and.;
														x[3] == '118' })) > 0
						cNumPar := '002'
					Endif

				Endif
				
				Aadd(aMatNmPr, {cMatUsu,;
								cNumPar,;
								aVlrCob[nInd,3],;
								Iif(aVlrCob[nInd,3] == '102', aVlrCob[nInd,3],'') })
				
				nPosNpr := Len(aMatNmPr)

			Endif

		Else
			cNumPar := '001'
		EndIf

		//Grava composicao da cobranca...                               
		cSeq := Soma1(cSeq)

		PLSGRVBM1(cMatUsu,_cChave,aVlrCob[nInd],cSeq,_cNivel,lPeriod,lCusOpe,lIntPos,cAno,cMes,cAnoMesAnt,cCodInt,cNumCob,;
				  cPrefixo,cNumero,cTipTit,cTipoSer,nPosNpr,aMatNmPr,cNumPar,cInterc,cTipInt,cNaturez)

		//Guardo a composicao da cobranca pois vou precisar dela la embaixo   
		//no momento de tratar os acumulados...                         
		PLSBM1COM(aAcertos,aVetAux,lGerSE1)

		//Usuario																
		PLSMATBA1(cMatUsu,Subs(_cChave,1,4)+cNumCob,lCusOpe,lIntPos,cAno,cMes,cAnoMesAnt,aVlrCob[nInd],lVldFIELD,aMatBA1)

		//Gravo como faturado as taxas de identificacao de usuario...   
		If BM1->BM1_CODTIP == "107" .And. !Empty(cMatUsu)

			If	Empty(cNumero) .Or. Empty(cPrefixo) .Or. Empty(cTipTit) .Or. Empty(cNumCob)
		 		PLSLOGFIL("PLSA510 linha 769. Numero do Titulo: " + cNumero + " Prefixo: "+cPrefixo+" Tipo: "+cTipTit+" Numero da Cobrança: "+cNumCob+"." ,"LOGLOTCART.LOG") 
		 		PLSLOGFIL("User: "+RetCodUsr()+" Data: "+ Time() + " Rotina Utilizada: " + FUNNAME() + "." ,"LOGLOTCART.LOG") 
            EndIf  
		
			cSQL := "UPDATE "+BED->(RetSQLName("BED"))+" SET "
			cSQL += "BED_ANMSFT = '"+cAno+cMes+"', BED_PREFIX = '" + cPrefixo + "', "
			cSQL += "BED_NUMTIT = '" + cNumero + "', BED_TIPTIT = '" + cTipTit + "', "
			cSQL += "BED_INTERC = '" + If(lInterC, "1", "0") + "', "
			cSQL += "BED_NUMCOB = '" + Subs(cMatUsu,1,4) + cNumCob + "', "
			cSQL += "BED_FATUR = '1' "
			cSQL += "WHERE BED_FILIAL = '"+xFilial("BED")+"' AND "
			cSQL += "BED_CODINT = '"+BM1->BM1_CODINT+"' AND "
			cSQL += "BED_CODEMP = '"+BM1->BM1_CODEMP+"' AND "
			cSQL += "BED_MATRIC = '"+BM1->BM1_MATRIC+"' AND "
			cSQL += "BED_TIPREG = '"+BM1->BM1_TIPREG+"' AND "
			cSQL += "BED_DIGITO = '"+BM1->BM1_DIGITO+"' AND "
			cSQL += "BED_NUMTIT = '      ' AND "
			cSQL += "(BED_FATUR = '1' or BED_FATUR  = '0') AND "
			cSQL += "BED_COBRAR = '1' AND D_E_L_E_T_ = ' '"
			TCSQLExec(cSQL)    

		//Verifico reembolso...  rotina antiga        						
		ElseIf BM1->BM1_CODTIP == "108"

			cChave := BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG)+cAno+cMes
			
			BKD->(DbSetOrder(4))
			If BKD->(MsSeek(xFilial("BKD")+cChave))
				
				While !BKD->(Eof()) .and. BKD->(BKD_FILIAL+BKD_CODINT+BKD_CODEMP+BKD_MATRIC+BKD_TIPREG+BKD_ANOBAS+BKD_MESBAS) == xFilial("BM1")+cChave
					
					If BKD->BKD_FORPAG == '0' .and. BKD->BKD_VLRREM > 0 .and. Empty(BKD->BKD_CHVSE1)
						
					BKD->(Reclock("BKD",.F.))
							BKD->BKD_CHVSE1 := BBT->(BBT_PREFIX+BBT_NUMTIT+BBT->BBT_PARCEL+BBT_TIPTIT)
							BKD->BKD_PLNUCO := BBT->BBT_NUMCOB
						BKD->(Msunlock())

					Endif

					BKD->(DbSkip())
				EndDo

			EndIf

			//Verifico reembolso...  rotina nova                          		
			cChave := BM1->(BM1_FILIAL+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG)+cAno+cMes
			B44->(DbSetOrder(2))
			If B44->(MsSeek(cChave))

				While !B44->(Eof()) .and. B44->(B44_FILIAL+B44_OPEUSR+B44_CODEMP+B44_MATRIC+B44_TIPREG+B44_ANOPAG+B44_MESPAG) == cChave

					If B44->B44_FORPAG == '0' .and. Empty(B44->(B44_PREFIX+B44_NUM+B44_PARCEL+B44_TIPO))
				
						// Verificar Reembolso CAMED
						If lDatPagto
					
							//Verifico se foi informado o banco								
							If B44->(FieldPos("B44_NROBCO")) > 0 
								aAdd(aBanco,B44->B44_NROBCO) //Numero Banco
								aAdd(aBanco,B44->B44_NROAGE) //Numero Agencia
								aAdd(aBanco,B44->B44_NROCTA) //Numero Conta
							Endif		

							BCI->(DbSetOrder(5))//BCI_FILIAL, BCI_OPERDA, BCI_CODRDA, BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, BCI_FASE, BCI_SITUAC    BCI_DATPAG
		   					If BCI->(MsSeek(xFilial("BCI")+B44->(B44_OPERDA+B44_CODRDA+B44_CODEMP+B44_CODLDP+B44_CODPEG))) .And. BCI->BCI_FASE <> "4"
								   
							 	 BD5->(DbSetOrder(1))//BD5_FILIAL, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_SITUAC, BD5_FASE, BD5_DATPRO, BD5_OPERDA, BD5_CODRDA
		   						If BD5->(MsSeek(xFilial("BD5")+BCI->(BCI_OPERDA+BCI_CODLDP+BCI_CODPEG) +B44->B44_NUMGUI+ BCI->(BCI_SITUAC+BCI_FASE))) 
			   						  				
		   							BD5->(Reclock("BD5",.F.))
	   									BD5->BD5_FASE := "4" // Faturado
		   							BD5->(MsUnlock())
			   							
									//Atualiza status	PEG	 											    
									PLSM190Pro( ,,,,,,,,,,,,.T.,BCI->(Recno()) )
										
									//Atualiza data de Processamento									    
									BXU->(dbsetOrder(3))//BXU_FILIAL+BXU_CODINT+DTOS(BXU_DATPAG)+BXU_REEMB
									If BXU->(MsSeek(xFilial("BXU")+BD5->BD5_CODOPE+dtos(BCI->BCI_DATPAG)+"1"))
									
							    	 	If Empty(BXU->BXU_DATPRO)
								    	 	BXU->(RecLock("BXU", .F.))
							              	BXU->BXU_DATPRO := dDataBase
								        	BXU->(MsUnlock())
										Endif
											
									Endif 
										
								Endif
									
							Endif
								
	   					Endif
						
						B44->(Reclock("B44",.F.))
							B44->B44_PREFIX := BBT->BBT_PREFIX
							B44->B44_NUM    := BBT->BBT_NUMTIT
							B44->B44_PARCEL := BBT->BBT_PARCEL
							B44->B44_TIPO   := BBT->BBT_TIPTIT
						B44->(Msunlock())

					EndIf

					B44->(DbSkip())
				EndDo

			EndIf
		
		//Gravo como faturado as vias de boleto...                      
		ElseIf BM1->BM1_CODTIP == "109"

			BEE->(DbSetOrder(1))
			If BEE->(MsSeek(xFilial("BEE")+Subs(cMatUsu,1,14)+"0"))

				While ! BEE->(Eof()) .And. BEE->(BEE_FILIAL+BEE_CODINT+BEE_CODEMP+BEE_MATRIC+BEE_FATUR) == xFilial("BEE")+Subs(cMatUsu,1,14)+"0"
					
					BEE->( RecLock("BEE", .F.) )
						BEE->BEE_FATUR 	:= '1'
						BEE->BEE_NUMCOB	:= BM1->BM1_PLNUCO
						BEE->BEE_INTERC := BM1->BM1_INTERC
						BEE->BEE_ANMSFT := Iif(!lCusOpe .And. !lIntPos,(cAno+cMes), cAnoMesAnt)
					BEE->( MsUnlock() )
					
					BEE->( DbSkip() )
				EndDo

			EndIf
		
		//Outros Debitos/Creditos							              
		ElseIf BM1->BM1_CODTIP $ cCodDB

			//Se tem a posicao 26													
			If Len(aVlrCob[nInd]) > 26
				
				//Se tem a posicao 27													
				If aVlrCob[nInd,27] > 0  
				
				   BSQ->( DbGoto(aVlrCob[nInd,27]) )
				   
				   PLSATUBSQ(cCodInt+cNumCob,cPrefixo,cNumero,cTipTit)
				
				//Inclui um lancamendo de deb/cre										
				Elseif aVlrcob[nInd,17] <> "BK2"
				 
					PLSGRVBSQ(cMatUsu,BM1->BM1_CONEMP,BM1->BM1_VERCON,BM1->BM1_SUBCON,;
					   			  BM1->BM1_VERSUB,BM1->BM1_ANO,BM1->BM1_MES,aVlrCob[nInd,3],aVlrCob[nInd,2],;
					   			  Subs(_cChave,1,4)+cNumCob,cPrefixo,cNumero,cTipTit,BG9->BG9_TIPO,_cNivel,BM1->BM1_CODEVE,;
					   			  aVlrCob[nInd,1])
				EndIf   
			//Se a posicao 26 nao existir											
/*			Else // Issofoi uma tratativa antiga agora existe sempre a poscição maior que 26

				If !Empty(cMatUsu)

					BSQ->(	dbSetorder(01) )
					If BSQ->( MsSeek(xFilial("BSQ")+aVlrCob[nInd,17]+cMatUsu+cAno+cMes) )
						PLSATUBSQ(cCodInt+cNumCob,cPrefixo,cNumero,cTipTit)
					EndIf
					
					If BA1->BA1_OUTLAN = "1"
						BA1->( RecLock("BA1", .F.) )
							BA1->BA1_OUTLAN := "0"
						BA1->(MsUnLock())
					EndIf
					
					BA3->(DbSetOrder(1))
					If 	BA3->(MsSeek(xFilial("BA3") + BM1->BM1_CODINT + BM1->BM1_CODEMP + BM1->BM1_MATRIC + BM1->BM1_CONEMP +;
										BM1->BM1_VERCON + BM1->BM1_SUBCON+BM1->BM1_VERSUB)) .And. BA3->BA3_OUTLAN = "1"
										
						BA3->( RecLock("BA3", .F.) )
							BA3->BA3_OUTLAN := "0"
						BA3->( MsUnLock() ) 
						
					EndIf

				Else

					If lInterc
						_cChave := AllTrim(BM1->BM1_CARGO)+BM1->(BM1_CODEMP+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB)
					Endif

					//nivel de subcontrato												
					BSQ->(	dbSetorder(04) )
					If BSQ->( MsSeek(xFilial("BSQ")+_cChave+cAno+cMes) )
						
						While !BSQ->( Eof() ) .And. BSQ->( BSQ_CODINT+BSQ_CODEMP+BSQ_CONEMP+BSQ_VERCON+BSQ_SUBCON+BSQ_VERSUB+BSQ_ANO+BSQ_MES ) == _cChave+cAno+cMes     
							PLSATUBSQ(cCodInt+cNumCob,cPrefixo,cNumero,cTipTit)
							BSQ->( dbSkip() )
						EndDo

					Else

						If SIX->(MsSeek("BSQ5"))

							//nivel de contrato													
							BSQ->(	dbSetorder(05) )
							If BSQ->( MsSeek(xFilial("BSQ")+_cChave+cAno+cMes) )
								
								While !BSQ->( Eof() ) .And. BSQ->( BSQ_CODINT+BSQ_CODEMP+BSQ_CONEMP+BSQ_VERCON+BSQ_ANO+BSQ_MES ) == _cChave+cAno+cMes
									PLSATUBSQ(cCodInt+cNumCob,cPrefixo,cNumero,cTipTit)
									BSQ->( DbSkip() )
								EndDo

							EndIf

						EndIf

					EndIf

				EndIf
*/
			EndIf

			BA3->( DbSetOrder(1) )
		EndIf

		//Pego o lancamento de usuario...                               
		//Este ponto de entrada tem 2 momentos, o primeiro eh quando eu estou 
		//apurando os valores o segundo eh qando eu estou gravando o BM1		
		//o que diferencia estes momentos eh o parametro de numero 10			
		//'1' - ESTOU APURANDO                                                
		//'2' - ESTOU GRAVANDO O BM1											
		If (nI := aScan(aLanUsu,{|x| x[1] == BM1->BM1_CODTIP })) > 0

			// A tabela BA3 ja esta posicionada não precisando reposcionar, assim ganhando performance.
			//Temos casos que debitos/creditos esta direto no subcontrato nivel 3, assim não tempo BM1_MATRIC
			aAreaBA3 	:= BA3->(GetArea())
			If ExistBlock(aLanUsu[nI,21])
				Execblock(aLanUsu[nI,21],.F.,.F.,{cMatUsu,cAno,cMes,BA3->BA3_FORPAG,{},nil,_cNivel,_cChave,aLanUsu,'2'})
			EndIf
			
			RestArea(aAreaBA3)

		EndIf

		//Marcando o custo operacional como faturado... BDH	          
		If TIPOS_COPARTICIPACAO

			If Len(aVlrCob[nInd]) > 26 .And. aVlrCob[nInd][27] > 0

				//nova funcao que alem de atualizar o bdh atualiza as notas e eventos. plsmctmd.prw  ³
				BDH->( DbGoto(aVlrCob[nInd][27]) )
				
		/*		If !FindFunction("PLSNOTXBDH") função antiga sempre vai existir                                              
				
					BDH->( RecLock("BDH",.F.) )
						BDH->BDH_STATUS := "0"
						BDH->BDH_OPEFAT := Substr(_cChave,1,4)
						BDH->BDH_NUMFAT := Subs(_cChave,1,4)+cNumCob
						BDH->BDH_PREFIX := cPrefixo
						BDH->BDH_NUMTIT := cNumero
						BDH->BDH_PARCEL := Space(TamSx3("E1_PARCELA")[1])
						BDH->BDH_TIPTIT := cTipTit
					BDH->( MsUnLock() )
					
				Else   */ 	
				    PLSNOTXBDH("0",Substr(_cChave,1,4),Subs(_cChave,1,4)+cNumCob,{cPrefixo,cNumero,Space(TamSx3("E1_PARCELA")[1]),cTipTit},lInterC,,cTipCob,nPosIntTit)
				//EndIf

			EndIf

		EndIf

		//³Tratamento do parcelamento.³
		DbSelectArea("BK2")

		cSQL := "UPDATE "+BK2->(RetSQLName("BK2"))+" SET BK2_LOTPAR = 'S', BK2_PLNUCO = '"+Subs(_cChave,1,4)+cNumCob+"' "
		cSQL += " WHERE "
		cSQL += "BK2_FILIAL = '"+xFilial("BK2")+"' AND "
		cSQL += "BK2_CODINT = '"+BM1->BM1_CODINT+"' AND "
		cSQL += "BK2_CODEMP = '"+BM1->BM1_CODEMP+"' AND "
		cSQL += "BK2_MATRIC = '"+BM1->BM1_MATRIC+"' AND "
		cSQL += "BK2_ANO 	<= '"+cAno+"' AND "
		cSQL += "BK2_MES	<= '"+cMes+"' AND "
		cSQL += "(BK2_SALDO	> 0 OR BK2_SALDO2	> 0) AND "
		cSQL += "BK2_PARCEL IN ('S','N') AND " // Indica que utiliza a rotina de parcelamento
		cSQL += "BK2_LOTPAR <> 'S' AND " // Indica se ja foi faturado
		cSQL += "D_E_L_E_T_ = ' '"
		TCSQLExec(cSQL)
	
	Next

    //como o credito NCC e apurado separadamente necessario verificar bases de impostos
    if ! lNCC

        for nInd := 1 to len(aCredit)
            
            //atualiza a matricula se mudar e retorna o risco
            cRisco := plsUsuRis(_cMatric, aCredit[nInd,7], @cMatUsu, cTipo)

            //Array com os totais de cada tipo de lancamento de faturamento de credito...    
            PLSDCTIP(aCredit[nInd], cCodDB, cRisco, aVlrDebCre)

        next	

    endIf

	BA1->( DbSetOrder(1) )

EndIf                       

PLSLOGFAT("COMPLEMENTO DA GRAVACAO",1,.F.)

//Apura todos os impostos da fatura... Usa funcao generica do ERP.    
For nCnt := 1 To Len(aEventosCB)

	//Nova apuracao de impostos com base no BSQ							
	If aEventosCB[nCnt][1] $ cCodDB .And. Len(aVlrDebCre) > 0

		For nI := 1 to Len(aVlrDebCre)
	
			If aEventosCB[nCnt][1] == aVlrDebCre[nI][1]

				//Apura base para o IRRF                                        
				If !Empty(aVlrDebCre[nI][3])
					cIncIRRF := aVlrDebCre[nI][3]
					cBasIRRF := aVlrDebCre[nI][4]
				Else
					cIncIRRF := aEventosCB[nCnt][4]
					cBasIRRF := aEventosCB[nCnt][6]
				Endif
					
				If cIncIRRF == '1'
					
					If PL510AIPT(aVlrDebCre[nI][1],aVlrDebCre[nI][2],aPL510BM1,'1')
					
						If aEventosCB[nCnt][3] == '1'
							aBases[1] += (aVlrDebCre[nI][16] * Iif(Empty(cBasIRRF), 1, Val(cBasIRRF)))
						Else
							aBases[1] -= (aVlrDebCre[nI][16] * Iif(Empty(cBasIRRF), 1, Val(cBasIRRF)))
						Endif
							
					Endif
						
				Endif

				//Apura base para o COFINS...                                   
				If ! Empty(aVlrDebCre[nI][7])
					cIncCOFI := aVlrDebCre[nI][7]
					cBasCOFI := aVlrDebCre[nI][8]
				Else
					cIncCOFI := aEventosCB[nCnt][9]
					cBasCOFI := aEventosCB[nCnt][10]
				Endif
					
				If cIncCOFI == '1'
					
					If PL510AIPT(aVlrDebCre[nI][1],aVlrDebCre[nI][2],aPL510BM1)
					
						If aEventosCB[nCnt][3] == '1'
							aBases[2] += (aVlrDebCre[nI][16] * Iif(Empty(cBasCOFI),1, Val(cBasCOFI)))
						Else
							aBases[2] -= (aVlrDebCre[nI][16] * Iif(Empty(cBasCOFI),1, Val(cBasCOFI)))
						Endif
							
					Endif
						
				Endif

				//Apura base para o ISS...                                      
				If ! Empty(aVlrDebCre[nI][5])
					cIncISS := aVlrDebCre[nI][5]
					cBasISS := aVlrDebCre[nI][6]
				Else
					cIncISS := aEventosCB[nCnt][7]
					cBasISS := aEventosCB[nCnt][8]
				Endif
					
				If cIncISS == "1"
					
					If PL510AIPT(aVlrDebCre[nI][1],aVlrDebCre[nI][2],aPL510BM1,'2')
						
						If aEventosCB[nCnt][3] == '1'
							aBases[3] += (aVlrDebCre[nI][16] * Iif(Empty(cBasISS),1, Val(cBasISS)))
						Else
							aBases[3] -= (aVlrDebCre[nI][16] * Iif(Empty(cBasISS),1, Val(cBasISS)))
						Endif
							
					Endif
						
				Endif

				//Apura base para o CSLL...                                     
				If ! Empty(aVlrDebCre[nI][10])
					cIncCSLL := aVlrDebCre[nI][10]
					cBasCSLL := aVlrDebCre[nI][11]
				Else
					cIncCSLL := aEventosCB[nCnt][13]
					cBasCSLL := aEventosCB[nCnt][14]
				Endif

				If cIncCSLL == '1'

					If  PL510AIPT(aVlrDebCre[nI][1],aVlrDebCre[nI][2],aPL510BM1)

						If aEventosCB[nCnt][3] == '1'
							aBases[4] += (aVlrDebCre[nI][16] * Iif(Empty(cBasCSLL), 1, Val(cBasCSLL)))
						Else
							aBases[4] -= (aVlrDebCre[nI][16] * Iif(Empty(cBasCSLL), 1, Val(cBasCSLL)))
						Endif
							
					Endif
						
				Endif

				cIncPIS := aEventosCB[nCnt][11]
				cBasPIS := aEventosCB[nCnt][12]

				//Apura base para o PIS...                                      
				If ! Empty(aVlrDebCre[nI][15])
					cIncPIS := aVlrDebCre[nI][15]
					cBasPIS := aVlrDebCre[nI][9]
				Endif
					
				If cIncPIS == '1'
					
					If PL510AIPT(aVlrDebCre[nI][1],aVlrDebCre[nI][2],aPL510BM1)
					
						If aEventosCB[nCnt][3] == '1'
							aBases[5] += (aVlrDebCre[nI][16] * Iif(Empty(cBasPIS),1, Val(cBasPIS)))
						Else
							aBases[5] -= (aVlrDebCre[nI][16] * Iif(Empty(cBasPIS),1, Val(cBasPIS)))
						Endif
							
					Endif
						
				Endif

				cIncINSS  := aEventosCB[nCnt][15]
				cBasINSSN := aEventosCB[nCnt][16]
				cBasINSS1 := aEventosCB[nCnt][17]
				
				//Apura base para o Inss...                                     
				If ! Empty(aVlrDebCre[nI][12])
					cIncINSS  := aVlrDebCre[nI][12]
					cBasINSSN := aVlrDebCre[nI][13]
					cBasINSS1 := aVlrDebCre[nI][14]
				Endif
					
				If cIncINSS == '1'
					
					If PL510AIPT(aVlrDebCre[nI][1],aVlrDebCre[nI][2],aPL510BM1,'3')
					
						If aEventosCB[nCnt][3] == '1'
							aBases[6] += (aVlrDebCre[nI][16] * Iif(Empty(cBasINSSN),1, Iif(aVlrDebCre[nI][17] $ '0, ',Val(cBasINSS1),Val(cBasINSSN)) ))
						Else
							aBases[6] -= (aVlrDebCre[nI][16] * Iif(Empty(cBasINSSN),1, Iif(aVlrDebCre[nI][17] $ '0, ',Val(cBasINSS1),Val(cBasINSSN)) ))
						Endif
							
					Endif
						
				Endif
					
			Endif
				
		Next

	Else              

		//Apura base para o IRRF                                        
		If aEventosCB[nCnt][4] == '1'

			aEval(aVlrLanc, { |x| Iif( (AllTrim(x[1]) == AllTrim(aEventosCB[nCnt][1]) .And. PL510AIPT(x[1],x[3],aPL510BM1,'1') ), aBasAx[1] += x[2], NIL)} )
			
			If aEventosCB[nCnt][3] == '1'
				aBases[1] += (aBasAx[1] * Iif( Empty(aEventosCB[nCnt][06]), 1, Val(aEventosCB[nCnt][06])))
			Else
				aBases[1] -= (aBasAx[1] * Iif(Empty(aEventosCB[nCnt][06]), 1, Val(aEventosCB[nCnt][06])))
			Endif       

		EndIf

		//Apura base para o COFINS...                                   
		If aEventosCB[nCnt][9] == '1'

			aEval(aVlrLanc, { |x|Iif((x[1] == aEventosCB[nCnt][1] .and. PL510AIPT(x[1],x[3],aPL510BM1)), aBasAx[2] += x[2], NIL)} )

			If aEventosCB[nCnt][3] == '1'
				aBases[2] += (aBasAx[2] * Iif(Empty(aEventosCB[nCnt][10]),1, Val(aEventosCB[nCnt][10])))
			Else
				aBases[2] -= (aBasAx[2] * Iif(Empty(aEventosCB[nCnt][10]),1, Val(aEventosCB[nCnt][10])))
			Endif
				
		Endif
			
		//Apura base para o ISS...                                      
		If aEventosCB[nCnt][7] == '1'

			aEval(aVlrLanc, { |x|Iif((x[1] == aEventosCB[nCnt][1] .and. PL510AIPT(x[1],x[3],aPL510BM1,'2')), aBasAx[3] += x[2], NIL)} )

			If aEventosCB[nCnt][3] == '1'
				aBases[3] += (aBasAx[3] * Iif(Empty(aEventosCB[nCnt][08]),1, Val(aEventosCB[nCnt][08])))
			Else
				aBases[3] -= (aBasAx[3] * Iif(Empty(aEventosCB[nCnt][08]),1, Val(aEventosCB[nCnt][08])))
			Endif
				
		Endif

		//Apura base para o CSLL...                                     
		If aEventosCB[nCnt][13] == '1'

			aEval(aVlrLanc, { |x|Iif((x[1] == aEventosCB[nCnt][1] .and. PL510AIPT(x[1],x[3],aPL510BM1)), aBasAx[4] += x[2], NIL)} )

			If aEventosCB[nCnt][3] == '1'
				aBases[4] += (aBasAx[4] * Iif(Empty(aEventosCB[nCnt][14]), 1, Val(aEventosCB[nCnt][14])))
			Else
				aBases[4] -= (aBasAx[4] * Iif(Empty(aEventosCB[nCnt][14]), 1, Val(aEventosCB[nCnt][14])))
			Endif
				
		Endif
			
		//Apura base para o PIS...                                      
		If aEventosCB[nCnt][11] == '1'

			aEval(aVlrLanc, { |x|Iif((x[1] == aEventosCB[nCnt][1] .and. PL510AIPT(x[1],x[3],aPL510BM1)), aBasAx[5] += x[2], NIL)} )

			If aEventosCB[nCnt][3] == '1'
				aBases[5] += (aBasAx[5] * Iif(Empty(aEventosCB[nCnt][12]),1, Val(aEventosCB[nCnt][12])))
			Else
				aBases[5] -= (aBasAx[5] * Iif(Empty(aEventosCB[nCnt][12]),1, Val(aEventosCB[nCnt][12])))
			Endif
				
		Endif

		//Apura base para o Inss...                                     
		If aEventosCB[nCnt][15] == '1'
			PL510INSS(aBases, aEventosCB[nCnt], aVlrLanc, aPL510BM1)
		Endif
			
	Endif
		
	aBasAx := {0,0,0,0,0,0}
	
Next

aBases[1] := Iif(aBases[1] < 0, 0, aBases[1])
aBases[2] := Iif(aBases[2] < 0, 0, aBases[2]) 
aBases[3] := Iif(aBases[3] < 0, 0, aBases[3])  
aBases[4] := Iif(aBases[4] < 0, 0, aBases[4])
aBases[5] := Iif(aBases[5] < 0, 0, aBases[5])
aBases[6] := Iif(aBases[6] < 0, 0, aBases[6])

Aadd(aCpoSE1, {'E1_PREFIXO', cPrefixo, nil} )
Aadd(aCpoSE1, {'E1_SERIE', cPrefixo, nil} )
Aadd(aCpoSE1, {'E1_NUM', cNumero, nil} )
Aadd(aCpoSE1, {'E1_PARCELA', '', nil} )
Aadd(aCpoSE1, {"E1_CLIENTE", cCodCli, nil} )
Aadd(aCpoSE1, {"E1_LOJA", cLoja, nil} )
Aadd(aCpoSE1, {"E1_NATUREZ", cNaturez, nil} )
Aadd(aCpoSE1, {"E1_TIPO", cTipTit, nil} )
Aadd(aCpoSE1, {"E1_EMISSAO", dEmissao, nil} )

//calcula novamente o vencimento										
if dVencto < dDataBase .And. ! lCusOpe
	dVencto := dDataBase + nDias
endIf

//Grava campos padroes do contas a receber...                   
Aadd(aCpoSE1, {'E1_VENCTO', dVencto, nil} )
Aadd(aCpoSE1, {'E1_VENCREA', dataValida(dVencto), nil} )
Aadd(aCpoSE1, {'E1_VALOR', nValor, nil} )
Aadd(aCpoSE1, {'E1_SALDO', nValor, nil} )

If ! lGerNFBRA
	Aadd(aCpoSE1, {'E1_BASEIRF', aBases[1], nil})
	aAdd(aCpoSE1, {"E1_BASECOF", aBases[2], Nil})
	aAdd(aCpoSE1, {"E1_BASEISS", aBases[3], Nil})
	aAdd(aCpoSE1, {"E1_BASECSL", aBases[4], Nil})
	aAdd(aCpoSE1, {"E1_BASEPIS", aBases[5], Nil})
	aAdd(aCpoSE1, {"E1_BASEINS", aBases[6], Nil})
endIf	     

if FunName() == "PLSA628"
	Aadd(aCpoSE1, {'E1_ANOBASE', Iif( ! lCusOpe .and. ! lIntPos, cAno, subs(cAnoMesAnt, 1, 4)), nil} )
	Aadd(aCpoSE1, {'E1_MESBASE', Iif( ! lCusOpe .and. ! lIntPos, cMes, subs(cAnoMesAnt, 5, 2)), nil} )
else
	Aadd(aCpoSE1, {'E1_ANOBASE', Iif( ! lCusOpe .and. ! lIntPos .or. ! lCMALCO, cAno, subs(cAnoMesAnt, 1, 4)), nil} )
	Aadd(aCpoSE1, {'E1_MESBASE', Iif( ! lCusOpe .and. ! lIntPos .or. ! lCMALCO, cMes, subs(cAnoMesAnt, 5, 2)), nil} )
endIf

//Grava campos de indentificacao contratual...                  
Aadd(aCpoSE1, {'E1_CODINT', Subs(_cChave,1,4), nil} )
Aadd(aCpoSE1, {'E1_CODEMP', Subs(_cChave,5,4), nil} )

If _cNivel == '2'

	Aadd(aCpoSE1, {'E1_CONEMP', Substr(_cChave,9,12), nil} )
	Aadd(aCpoSE1, {'E1_VERCON', Substr(_cChave,21,3), nil} )

ElseIf _cNivel == '3'

	Aadd(aCpoSE1, {'E1_CONEMP', Substr(_cChave,9,12), nil} )
	Aadd(aCpoSE1, {'E1_VERCON', Substr(_cChave,21,3), nil} )
	Aadd(aCpoSE1, {'E1_SUBCON', Substr(_cChave,24,9), nil} )
	Aadd(aCpoSE1, {'E1_VERSUB', Substr(_cChave,33,3), nil} )
	Aadd(aCpoSE1, {'E1_NUMCON', BQC->BQC_ANTCON, nil} )

	If Ascan(aVlrCob, {|x| x[3] == "186"}) > 0 .And. Len(aMatBa3) >= 4 // Familia relacionada ao Reembolso Patronal
		Aadd(aCpoSE1, {'E1_MATRIC', Substr(aMatBa3[4], 9, 6), Nil})
	EndIf

ElseIf _cNivel $ '4,5'

	Aadd(aCpoSE1, {'E1_MATRIC', Substr(_cChave,9,6), nil} )
	Aadd(aCpoSE1, {'E1_TIPREG', Substr(_cChave,15,2), nil} )
	Aadd(aCpoSE1, {'E1_CODCOR', BA3->BA3_CODVEN, nil} )

EndIf

If  SE1->(FieldPos("E1_PLORIG")) > 0
	Aadd(aCpoSE1, {'E1_PLORIG', cOrig, nil} )
Endif 

Aadd(aCpoSE1, {'E1_SDACRES', nCobComple, nil} )
Aadd(aCpoSE1, {'E1_NUMBCO', cNossoN, nil} )
Aadd(aCpoSE1, {'E1_PLNUCOB', Subs(_cChave,1,4)+cNumCob, nil})

If FunName() $ "PLSA094A,PLSA094B,PLSA094C,PLSA094D,PLSA790V"
	cOrigem := "PLSA090"	
EndIf

Aadd(aCpoSE1, {'E1_ORIGEM', cOrigem, nil} )
Aadd(aCpoSE1, {'E1_LA', "", nil} )
Aadd(aCpoSE1, {'E1_FORMREC', cTipoPag, nil} )
Aadd(aCpoSE1, {'E1_MULTNAT', "2", nil} )
//Verificar ou nao o limite de 5000 para Pis cofins Csll
// 1 = Verifica o valor minimo de retencao
// 2 = Nao verifica o valor minimo de retencao
Aadd(aCpoSE1, {'E1_APLVLMN', '2', nil} )

if ( ! empty(cBanco) .or. ! Empty(cPortado+cAgePor+cCCPor) ) .and. SA6->( found() )
	Aadd(aCpoSE1, {"E1_PORTADO", SA6->A6_COD, nil} )
	Aadd(aCpoSE1, {"E1_AGEDEP", SA6->A6_AGENCIA, nil} )
	Aadd(aCpoSE1, {"E1_CONTA", SA6->A6_NUMCON, nil} )
endIf

if len(aBanco) > 0
	Aadd(aCpoSE1, {'E1_BCOCLI', aBanco[1], nil} )
	Aadd(aCpoSE1, {'E1_AGECLI', aBanco[2], nil} )
	Aadd(aCpoSE1, {'E1_CTACLI', aBanco[3], nil} )
else
	Aadd(aCpoSE1, {'E1_BCOCLI', cBcoCli, nil} )
	Aadd(aCpoSE1, {'E1_AGECLI', cAgeCli, nil} )
	Aadd(aCpoSE1, {'E1_CTACLI', cCCCli, nil} )
endIf

//Grava o juros... 25/03/04                   
aJuros := PLSVJURFAM(Subs(_cMatric,9,6), _cNivel, cTipo)

If aJuros[1]
	Aadd(aCpoSE1, {"E1_VALJUR", aJuros[2], nil} )
	Aadd(aCpoSE1, {"E1_PORCJUR", aJuros[3], nil} )
endIf

//Novo modelo de gravacao do SE1, desenvolvida pelo Wagner Xavier...  
cAnoRef := cAno
cMesRef := strZero(val(cMes) - 1, 2)

If Val(cMesRef) <= 0
	cMesRef := "12"
	cAnoRef := strZero(val(cAno) - 1, 4)
EndIf   

//Gravacao do E1																		
If lGerSE1             
	
	//Gera nota/titulo																	
	lErro := PLSTOSE1(aCpoSE1, aBases, cMesRef, cAnoRef, cOrigem, lContabiliza, lCusOpe, aVlrCob,;
					  cPrefixo, cNumero, nPLGERREC, nPeriod, lNCC, aEventosCb, nil, @aCritica)

	if ! lErro

		//Esta nesta posicao porque o A040DUPREC grava o campo E1_SITUACA como '0' chumbado!! 
		//Nao pode ser removido																
		nVlrBDF := nValor
		
		If ! SE1->( eof() )

			SE1->( recLock("SE1", .F.) )
				SE1->E1_SITUACA := cSitE1
			SE1->(MsUnLock())    

			//Pega o valor apos a geracao do titulo para que o total no cabecalho fique correto	
			nVlrBDF := SE1->E1_VALOR

		EndIf

		// Titulo de valor irrisório. Providenia a baixa por cancelamento.
		If nValor <= 0.03 
			PL627BXCAN(.t.)
			lBaixaCan := .t.		                                               
		Endif
		
		PLSLOGFAT("GRAVACAO FINALIZADA DO TITULO",1,.F.)

	endIf	

EndIf

//Recupera a posicao do BBT na hora de sua gravacao...             
If nRegBBT > 0 .and. ! lErro

	BBT->( dbGoto(nRegBBT) )
	
    //Posiciono a natureza do titulo...                             
    SED->( dbSetorder(01) )
    SED->( MsSeek(xFilial("SED")+cNaturez) ) 

	//Atualiza o arquivo BBT com informacoes sobre os impostostos apurados...³
	BBT->( RecLock("BBT", .F.) )  

        If getNewPar('MV_PLSNFBR','0') == '0'
            BBT->BBT_BASIRR := aBases[1]
            BBT->BBT_BASISS := aBases[3]
            BBT->BBT_BASINS := aBases[6]
            BBT->BBT_BASCOF := aBases[2]
            BBT->BBT_BASCSL := aBases[4]
            BBT->BBT_BASPIS := aBases[5]
        Else	
            BBT->BBT_BASIRR := If(SE1->E1_IRRF > 0 ,SE1->E1_VLCRUZ,0)
            BBT->BBT_BASISS := If(SE1->E1_ISS > 0 ,SE1->E1_VLCRUZ,0)
            BBT->BBT_BASINS := SE1->E1_BASEINS
            BBT->BBT_BASCOF := SE1->E1_BASECOF
            BBT->BBT_BASCSL := SE1->E1_BASECSL
            BBT->BBT_BASPIS := SE1->E1_BASEPIS
		Endif    
			
        BBT->BBT_PERIRF	:= SED->ED_PERCIRF
        BBT->BBT_PERINS := SED->ED_PERCINS
        BBT->BBT_PERCSL := SED->ED_PERCCSL
        BBT->BBT_PERCOF := SED->ED_PERCCOF
        BBT->BBT_PERPIS := SED->ED_PERCPIS
        BBT->BBT_VENCTO := getdToVal(Day2Str(SE1->E1_VENCREA))
        BBT->BBT_PERISS := getMV("MV_ALIQISS")

    BBT->( MsUnlock() )

	//Métrica do PLS
	/*Atenção:
	1) Para a métrica funcionar com a classe FwMetrics, a lib deve estar na versão igual ou maior que 20200727;
	2) Além de verificar a versão da Lib, existe o parâmetro "secreto" MV_PHBMETR, que vai ficar ativo como default. Caso ocorra lentidão em 
	algum cliente em produção - visto que até 05/2021, nenhum cliente da base tem os requisitos para rodar a métrica e testar em produção - basta
	citar a criação deste parâmetro (Métrica PLS Ativa? 0 - Não / 1 - Sim) e colocar o valor como "0" (desligado).
	3) No futuro, vamos usar o FwCustomMetrics, mas demanda lib superior e outros requisitos...
	4) As variáveis estão declaradas como estáticas no fonte:*/
	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		
		FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_modelo-pagamento-de-reembolso_total", 1 }} )

	endif
	/* Fim das métricas */

Endif

if  ! lErro

	If cPaisLoc == "BRA" .And. ! IsInCallStack("PLSA090GRV")
		PLSREGRAMF(cAno,cMes,aVlrCob)
	Endif

	//Ponto de entrada apos a geracao de um titulo a receber pelo faturamento ³
	//Exemplos de Uso:                                                  
	//Alterar prefixo, conta contabil, natureza, etc...                 
	If ExistBlock("PLSGERTF")
		Execblock("PLSGERTF",.F.,.F.)
		PLSLOGFAT("PLSGERTF",1,.F.)
	Endif

	//Tratamento da geracao do lancamento na folha de pagamnto      
	If lfolha .And. SRC->(FieldPos("RC_PLNUCO"))  > 0 .And. PLSALIASEXI("B1T")

		//Vou acumular o total por funcionario + verba           				
		For nInd := 1 to Len(aVetAux)       

			if !lDirf11
				j := aScan(aAcuFun, {|x| x[3]+x[4] == aVetAux[nInd][6]+aVetAux[nInd][7] .And. x[5] == aVetAux[nInd][8] })
			Else
				j := aScan(aAcuFun, {|x| x[3]+x[4] == aVetAux[nInd][6]+aVetAux[nInd][7] .And. x[5] == aVetAux[nInd][8] .And. x[13] == aVetAux[nInd][13] .And. x[14] == aVetAux[nInd][14] .And. x[18] == aVlrCob[nInd][70] })			
			Endif

			If j  == 0
				
				AaDd(aAcuFun,{	aVetAux[nInd][4],;  //[1] VALOR
								aVetAux[nInd][5],;  //[2] TP LANC
								aVetAux[nInd][6],;  //[3] FILIAL FUN
								aVetAux[nInd][7],;  //[4] MATRIC FUN
								aVetAux[nInd][8],;  //[5] VERBA FOLHA
								aVetAux[nInd][1],;  //[6] CODINT
								aVetAux[nInd][2],;  //[7] CODEMP
								aVetAux[nInd][3],;  //[8] MATRIC
								aVetAux[nInd][9],;  //[9] ANO
								aVetAux[nInd][10],; //[10]MES
								aVetAux[nInd][12],; //[11]TIPREG
								aVetAux[nInd][11],; //[12]NUM COB
								aVetAux[nInd][13],; //[13]Tipo de usuário
								aVetAux[nInd][14],;	//[14]Tipo de lançamentoo GPE
								aVlrCob[nInd][67],; //[15] tipo do plano 
								aVlrCob[nInd][68],; //[16] tipo do fornecedor
								aVlrCob[nInd][69],; //[17]cod fornecedor    
								aVlrCob[nInd][70],; //[18] cod dependente   
								aVlrCob[nInd][71]}) //[19] cod do plano     
							
			Else
				aAcuFun[j][1] += aVetAux[nInd][4]
			Endif

		Next

		//Vou gravar la na folha							           			
		For nInd := 1 to Len(aAcuFun)
			
			If aAcuFun[nInd][1] > 0
				
				cCodB1T := GetSx8Num("B1T","B1T_CODSEQ")

				B1T->(RecLock("B1T",.T.))
					B1T->B1T_FILIAL := xFilial("B1T")
					B1T->B1T_CODSEQ := cCodB1T
					B1T->B1T_CODINT := aAcuFun[nInd][6]
					B1T->B1T_CODEMP := aAcuFun[nInd][7]
					B1T->B1T_MATRIC := aAcuFun[nInd][8]
					B1T->B1T_MES    := aAcuFun[nInd][10]
					B1T->B1T_ANO    := aAcuFun[nInd][9]
					B1T->B1T_VALOR  := aAcuFun[nInd][1]
					B1T->B1T_PLNUCO := aAcuFun[nInd][12]
					B1T->B1T_AGFTFU := aAcuFun[nInd][3]
					B1T->B1T_AGMTFU := aAcuFun[nInd][4]
					B1T->B1T_VERSIG := aAcuFun[nInd][5]
					B1T->B1T_CODBBT := BBT->BBT_CODIGO
					B1T->B1T_RGIMP  := '0'
				
				B1T->(MsUnLock())                    
				
				If ! ldirf11 // Não ha mas tratativa para dirf versao 11

				/*	SRC->(dbSetOrder(1))//RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ  			 
					
					If Empty(aAcuFun[nInd][5])
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "O lançamento ("+AllTrim(aAcuFun[nInd][2])+") está sem verba cadastrada.", 0, 0, {})
					EndIf
					
					cChvSRC := aAcuFun[nInd][3]+;
								AllTrim(aAcuFun[nInd][4])+;
								PadR(aAcuFun[nInd][5],Len(SRC->RC_PD))+;
								AllTrim(Posicione("SRA",1,aAcuFun[nInd][3]+aAcuFun[nInd][4],"RA_CC"))			
		
					nSeq := 0			

					//Procuro o registro na folha usando a filial do funcionário aAcuFun[nInd][3
					If SRC->(MsSeek(cChvSRC))

						While !SRC->(Eof()) .And. AllTrim(cChvSRC) == AllTrim(SRC->(RC_FILIAL+RC_MAT+RC_PD+RC_CC))
							nSeq ++
							SRC->(DbSkip())
						EndDo

					EndIf	
					
					SRC->(RecLock("SRC",.T.))
						SRC->RC_FILIAL := aAcuFun[nInd][3]
						SRC->RC_MAT    := aAcuFun[nInd][4]
						SRC->RC_PD     := aAcuFun[nInd][5]
						SRC->RC_TIPO1  := "V"
						SRC->RC_VALOR  := aAcuFun[nInd][1]
						SRC->RC_CC     := Posicione("SRA",1,aAcuFun[nInd][3]+aAcuFun[nInd][4],"RA_CC")
						SRC->RC_TIPO2  := "I"
						SRC->RC_PLNUCO := aAcuFun[nInd][12]
						If SRC->(FieldPos("RC_CODB1T")) > 0
							SRC->RC_CODB1T := cCodB1T
						Endif
						SRC->RC_SEQ    := Soma1(StrZero(nSeq,1))
					SRC->(MsUnLock())*/

				Else
					
					//RHR_FILIAL+   RHR_MAT+            RHR_COMPPG+RHR_ORIGEM+       RHR_CODIGO+         RHR_TPLAN     
					//+RHR_TPFORN+RHR_CODFOR+RHR_TPPLAN+RHR_PLANO+RHR_PD
					If !(RHR->(msSeek(aAcuFun[nInd][3]+aAcuFun[nInd][4]+(cAno+cMes)+aAcuFun[nInd][13]+aAcuFun[nInd][18]+aAcuFun[nInd][14]+;
									aAcuFun[nInd][16]+aAcuFun[nInd][17]+aAcuFun[nInd][15] +aAcuFun[nInd][19]+aAcuFun[nInd][5]))) .and. RHR->(FieldPos("RHR_PLNUCO")) > 0

						RHR->(RecLock("RHR",.T.)) 
							RHR->RHR_FILIAL:= aAcuFun[nInd][3]
							RHR->RHR_MAT   := aAcuFun[nInd][4]
							RHR->RHR_COMPPG:= cAno+cMes
							RHR->RHR_ORIGEM:= aAcuFun[nInd][13]
							RHR->RHR_CODIGO:= aAcuFun[nInd][18]
							RHR->RHR_TPLAN:=  aAcuFun[nInd][14]
							RHR->RHR_TPFORN:= aAcuFun[nInd][16]
							RHR->RHR_CODFOR:= aAcuFun[nInd][17]
							RHR->RHR_TPPLAN:= aAcuFun[nInd][15]
							RHR->RHR_PLANO := aAcuFun[nInd][19]
							RHR->RHR_PD    := aAcuFun[nInd][5]  
							RHR->RHR_VLRFUN:= aAcuFun[nInd][1]
							RHR->RHR_DATA  := ddatabase
							RHR->RHR_PLNUCO:= aAcuFun[nInd][12]
						RHR->(MsUnlock())			
				
					Else

						RHR->(RecLock("RHR",.F.))
							RHR->RHR_VLRFUN+= aAcuFun[nInd][1]
						RHR->(MsUnlock())	

					Endif
									
					//devo gerar RHO qdo se tratar de co-participaçao e reembolso
					If aAcuFun[nInd][14] <> "1" .and. RHO->(FieldPos("RHO_PLNUCO")) > 0

						RHO->(RecLock("RHO",.T.))
							RHO->RHO_FILIAL:= aAcuFun[nInd][3]
							RHO->RHO_MAT   := aAcuFun[nInd][4]
							RHO->RHO_COMPPG:= cAno+cMes
							RHO->RHO_ORIGEM:= aAcuFun[nInd][13]
							RHO->RHO_CODIGO:= aAcuFun[nInd][18]
							RHO->RHO_TPLAN:=  Iif(aAcuFun[nInd][14]=='2','1','2')
							RHO->RHO_TPFORN:= aAcuFun[nInd][16]
							RHO->RHO_CODFOR:= aAcuFun[nInd][17]
							RHO->RHO_PD    := aAcuFun[nInd][5]  
							RHO->RHO_VLRFUN:= aAcuFun[nInd][1]
							RHO->RHO_DTOCOR:= ddatabase
							RHO->RHO_PLNUCO:= aAcuFun[nInd][12]
						RHO->(MsUnlock())			
				
					Endif			
				Endif
				B1T->(ConfirmSX8())
			Endif
		Next
		PLSLOGFAT("LANCAMENTOS NA FOLHA",1,.F.)

	EndIf

endIf

// Geracao do titulo OK. Retorno positivo da funcao...                 
// Anota a critica de contrato gratuito no mes.
If lBaixaCan .and. ! lErro
	
	A627RetCri(@aCritica, '04', nValor)

Else

	If len(aCritica) == 0
		A627RetCri(@aCritica, '01', nVlrBDF, .t., aMatBA1)
	EndIf
	
Endif

End Transaction

// Rateio de Impostos e NCC
If !lErro .And. lRatImpost

	aRateioImp := PLRatImpLot(cCodInt,cNumCob)
	
	If Len(aRateioImp) > 0	
		PLGrvRateio(aRateioImp)
	EndIf

EndIf

//Restaura dados da area no arquivo de contratos...             
Eval(bRest)
Eval(bRestBA3)

Return(aCritica)

/*/{Protheus.doc} plsUsuRis
reposiciona o usuario se mudar e retorna o risco.
@author  PLS TEAM
@version P12
@since   26.01.19
/*/
function plsUsuRis(_cMatric, cMatric, cMatUsu, cTipo)
local cRisco    := ''
local _cCodInt	:= ''
local _cCodPro  := ''
local _cVerPro  := ''

//Quando muda o usuario eh necessario reposicionar o arquivo... 
if ! empty(cMatric)

    if cMatUsu <> cMatric

        cMatUsu := cMatric
        nBa1Rec := BA1->( recno() )
        
        BA1->( DbSetOrder(2) )//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
        if ! BA1->( MsSeek(xFilial("BA1") + cMatUsu) )
            BA1->( msGoto(nBa1Rec) )
        endIf

    endIf

else 
    cMatUsu := _cMatric
endIf	

//Obtem o risco do produto, para fins de calculo do INSS        
// Pessoa juridica...
If cTipo == '2'  
    
    If ! Empty(BA1->BA1_CODPLA)

        If BQC->( msSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMPN+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)) )
    
            If BT6->( msSeek(xFilial("BT6")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB+BA1->BA1_CODPLA+BA1->BA1_VERSAO)) )
                cRisco := BT6->BT6_RISCO
            EndIf

        EndIf

		_cCodInt := BA1->BA1_CODINT
        _cCodPro := BA1->BA1_CODPLA
        _cVerPro := BA1->BA1_VERSAO

    Else
        
        If BA3->( msSeek(xFilial("BA3")+BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC)) )
        
            If BQC->( msSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)) )
            
                If BT6->( msSeek(xFilial("BT6")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB+BA3->BA3_CODPLA+BA3->BA3_VERSAO)) )
                    cRisco := BT6->BT6_RISCO
                EndIf

            EndIf

        EndIf

		_cCodInt := BA3->BA3_CODINT
        _cCodPro := BA3->BA3_CODPLA
        _cVerPro := BA3->BA3_VERSAO

    EndIf

    //Se nao encontrar no produto do sub, vai ate o cadastro de produto saude...  
    If empty(cRisco)

        If BI3->( msSeek(xFilial("BI3") + _cCodInt + _cCodPro + _cVerPro ) )
            cRisco := BI3->BI3_RISCO
        EndIf

    EndIf
    
    If Empty(cRisco)
        cRisco := "0" // Pequeno risco onde nao for informado.
    EndIf

EndIf

return(cRisco)


/*/{Protheus.doc} PLS510JR
cobranca de juros no mes seguinte... 
Chamar essa funcao de dentro do ponto de entrada SACI008
que eh executado apos a baixa do titulo...
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLS510JR()
LOCAL nJuros  := 0
LOCAL cCodLan := ''
LOCAL __cNivel:= ''
LOCAL cSql    := ''
LOCAL lCobJur := .F.
LOCAL nCount  := 0
LOCAL lRet	  := .T.
LOCAL nRegSE5 := SE5->( Recno() ) // Salva recno do SE5.
LOCAL cChvNiv := ''
LOCAL aLastFat:= {}
Local cTipReg	:= GetNewPar("MV_PLTRTIT","00")
Local lAutomato := IsInCallstack("PLSA627051")


//Se for baixa por cancelamento nao calcula juros para o mes seguinte... 
If SE5->E5_MOTBX == GetNewPar("MV_PLMOTBC","CAN")
	Return(.F.)
Endif


//Pesquisa o codigo do tipo de deb/cred relacionado ao lanc. de faturamento de juros no mes seguinte..

cSql := "SELECT BSP_CODSER FROM "+RetSqlName("BSP")+" WHERE BSP_FILIAL = '"+xFilial("BSP")+"' "
cSql += "AND BSP_CODLAN = '111' "
cSql += "AND D_E_L_E_T_ = ' ' "
PlsQuery(cSql, "TRB510Jr")


//Conta os registros obtidos... permitido no maximo 1 registro...     ³

TRB510Jr->( dbEval({|| nCount ++ }) )


//Verifica se o retorno eh valido...                            

If nCount == 0
	TRB510Jr->(dbClosearea())
	Return()
	
Elseif nCount > 1
	If(!lAutomato,MsgAlert(STR0048),) //"Existe mais de um TIPO DE LANC. DE DEBITO/CREDITO relacionado ao codigo '111', referente a juros no mes seguinte, cadastrado no sistema! Nao foi gerado lancamento de debito referente a juros no mes seguinte."	 
	lRet := .F.
Else
	TRB510Jr->( dbGotop() )
	cCodLan	 := TRB510Jr->BSP_CODSER
	
Endif

If !( BSQ->( FieldPos("BSQ_PREORI") ) > 0 .and.;
	BSQ->( FieldPos("BSQ_NUMORI") ) > 0 .and.;
	BSQ->( FieldPos("BSQ_PARORI") ) > 0 .and.;
	BSQ->( FieldPos("BSQ_TIPORI") ) > 0 )
	
	If(!lAutomato,MsgAlert(STR0014),) //"Os campos nescessarios para o calculo dos juros devidos para o mes seguinte nao existem na base de dados! "
	//"Providenciar a criacao dos campos BSQ_PREFJR, BSQ_NUMTJR, BSQ_PARCJR, BSQ_TIPTJR."
	//"Nao foi gerado lancamento de debito referente a juros no mes seguinte."
	
	lRet := .F.
Endif

dbSelectarea("SIX")
If !SIX->( msSeek("BSQ5") )
	
	If(!lAutomato,MsgAlert(STR0015),) //"O indice numero 5 do arquivo BSQ nao existe na base de dados. Providenciar indice de ordem 5 com a seguinte "
	//"chave: BSQ_FILIAL + BSQ_PREORI + BSQ_NUMORI + BSQ_PARORI + BSQ_TIPORI."
	//"Nao foi gerado lancamento de debito referente a juros no mes seguinte.
	
	lRet := .F.
Endif

//Fecha area de trabalho temporaria...                          

TRB510Jr->(dbClosearea())

If !lRet
	Return(lRet)
Endif

//Calcula juros devidos e nao pagos...                          

nJuros := CalcJrDev(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)

//Tratamento caso o CalcJrDev retorne o nJuros nulo				

If nJuros == NIL
  nJuros := 0
EndIf

//Ponto de entrada que permite definir se deve, ou nao, gravar um debito para o mes seguinte referente 
//aos juros que nao foram pagos na baixa do titulo. Retornar .T. ou .F. - Sandro 15/02/2006            

If ExistBlock("PLS510GRJR") .And. nJuros > 0
	lCobJur := ExecBlock("PLS510GRJR",.F.,.F.,{ SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->(RecNo()),nJuros })
	
	If ValType(lCobJur) <> "L"
		lCobJur := .T.
	EndIf
	If ! lCobJur
		nJuros := 0 // Zero "nJuros" para que nao grave o Debito para o mes seguinte
	EndIf
	
	//LOG																		   
	
	PLSLOGFAT("PLS510GRJR",1,.F.)
EndIf

//Restaura a posicao original do SE5...                         

SE5->( dbGoto(nRegSE5) )

If nJuros > 0
	
	//Posiciona empresa...                                          
	
	BG9->( dbSetorder(01) )
	BG9->( msSeek(xFilial("BG9")+SE1->E1_CODINT+SE1->E1_CODEMP) )
	
	//Analisa pessoa fisica...                                      
	
	If BG9->BG9_TIPO == '1'
		BA3->( dbSetorder(01) )
		BA3->( msSeek(xFilial("BA3")+SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_MATRIC) )
		
		BA1->( dbSetorder(02) )
		BA1->( msSeek(xFilial("BA1")+SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_MATRIC+cTipReg) )
		
		//Posiciona Produto...                                          
		
		BI3->( dbSetorder(01) )
		BI3->( msSeek(xFilial("BI3")+BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO) )
		
		//Verifica se e permitido cobrar juros deste produto...         
		
		lCobJur := BI3->BI3_COBJUR == '1'
		
		
		//Monta a chave de pesquisa para o nivel de cobranca...         
		
		cChvNiv := BA3->( BA3_CODINT + BA3_CODEMP + BA3_MATRIC )
		
		__cNivel := '4'
		
		//Pessoa juridica, analisa o nivel de cobranca...               
		
	Else
		
		//Posiciona a familia... caso o nivel esteja nela, ja deixa posicionado 
		
		BA3->( dbSetorder(01) )
		BA3->( msSeek(xFilial("BA3")+SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_MATRIC) )
		
		BBT->( dbSetorder(07) )
		BBT->( msSeek(xFilial("BBT")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO) )
		
		__cNivel := BBT->BBT_NIVEL // Nivel de cobranca...
		lCobJur:= .F.
		
		If __cNivel == '1' // Empresa
			If BG9->( FieldPos("BG9_COBJUR") ) > 0
				BG9->( dbSetorder(01) )
				If BG9->( msSeek(xFilial("BG9")+SE1->E1_CODINT+SE1->E1_CODEMP) )
					lCobJur := BG9->BG9_COBJUR == '1'
				Endif
			Endif
			cChvNiv := SE1->E1_CODINT+SE1->E1_CODEMP
			
		Elseif __cNivel == '2' // Contrato
			If BT5->( FieldPos("BT5_COBJUR") ) > 0
				BT5->( dbSetorder(01) )
				If BT5->( msSeek(xFilial("BT5")+SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_CONEMP+SE1->E1_VERCON) )
					lCobJur := BT5->BT5_COBJUR == '1'
				Endif
			Endif
			cChvNiv := SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_CONEMP+SE1->E1_VERCON
			
		Elseif __cNivel == '3'  // Sub contrato
			If BQC->( FieldPos("BQC_COBJUR") ) > 0
				BQC->( dbSetorder(01) )
				If BQC->( msSeek(xFilial("BQC")+SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_CONEMP+;
					SE1->E1_VERCON+SE1->E1_SUBCON+SE1->E1_VERSUB) )
					lCobJur := BQC->BQC_COBJUR == '1'
				Endif
			Endif
			cChvNiv := SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_CONEMP+SE1->E1_VERCON+SE1->E1_SUBCON+SE1->E1_VERSUB
			
		Elseif __cNivel == '4'  // Familia
			
			//Se for pessoa juridica e o nivel de cob. estiver na familia, pega do prod. do sub. 
			
			If !BA3->( Eof() )
				BT6->( dbSetorder(01) )
				If BT6->( msSeek(xFilial("BT6")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+;
												 BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB+;
												 BA3->BA3_CODPLA+BA3->BA3_VERSAO) )
												 
					lCobJur := BT6->BT6_COBJUR == '1'
					
					BA1->( dbSetorder(02) )
					BA1->( msSeek(xFilial("BA1")+SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_MATRIC+cTipReg) )
				Endif
			Endif
			
			//Monta a chave de pesquisa para o nivel de cobranca...         
			
			cChvNiv := BA3->( BA3_CODINT + BA3_CODEMP + BA3_MATRIC )
			
		Endif
	Endif
	
	
	//Caso nao esteja parametrizado para cobrar, retorna...         
	
	If !lCobJur
		Return(.F.)
	Endif
	
	
	//Verifica qual o ultimo faturamento do nivel de cobranca...    
	
	aLastFat := PLLastFat(__cNivel,cChvNiv)
	
	
	//Cacula data para cobranca do juros devido...                  
	
	cProxMes := StrZero((Val(aLastFat[2])+1),2)
	cAno	 := aLastFat[1]
	
	If cProxMes > '12'
		cProxMes := '01'
		cAno	 := StrZero((Val(cAno)+1),4)
	Endif
	
	//Lanca um debito para o titular da familia...                  
	Begin Transaction
	
	BSQ->( Reclock("BSQ",.T.) )
	BSQ->BSQ_FILIAL := xFilial("BSQ")
	BSQ->BSQ_CODSEQ := GETSX8NUM("BSQ","BSQ_CODSEQ")
	If BG9->BG9_TIPO == '1' .OR. __cNivel == '4'
		BSQ->BSQ_USUARI := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
	Endif
	BSQ->BSQ_CODINT := SE1->E1_CODINT
	BSQ->BSQ_CODEMP := SE1->E1_CODEMP
	BSQ->BSQ_MATRIC := SE1->E1_MATRIC
	BSQ->BSQ_CONEMP := SE1->E1_CONEMP
	BSQ->BSQ_VERCON := SE1->E1_VERCON
	BSQ->BSQ_SUBCON := SE1->E1_SUBCON
	BSQ->BSQ_VERSUB := SE1->E1_VERSUB
	BSQ->BSQ_ANO	:= cAno
	BSQ->BSQ_MES	:= cProxMes
	BSQ->BSQ_CODLAN	:= cCodLan
	BSQ->BSQ_TIPO	:= '1'
	BSQ->BSQ_VALOR	:= nJuros
	
	BSQ->BSQ_PREORI := SE1->E1_PREFIXO
	BSQ->BSQ_NUMORI := SE1->E1_NUM
	BSQ->BSQ_PARORI := SE1->E1_PARCELA
	BSQ->BSQ_TIPORI := SE1->E1_TIPO
	BSQ->BSQ_SEQ	:= SE5->E5_SEQ
	
	BSQ->BSQ_TIPEMP := BG9->BG9_TIPO // Pessoa Fisica/Juridica
	BSQ->BSQ_AUTOMA := '1'
	BSQ->BSQ_COBNIV := __cNivel
	BSQ->( MsUnlock() )
	
	End Transaction

	ConfirmSx8()

	If ExistBlock("PLS510BS")
		ExecBlock("PLS510BS",.F.,.F.,{ SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->(RecNo()),BSQ->(RecNo())})
		PLSLOGFAT("PLS510BS",1,.F.)
	EndIf
EndIf

Return(.T.)

/*/{Protheus.doc} PLS510CJR
Cancela o debito gerado contra o nivel de cobranca, caso o
o movimento de origem seja cancelado no financeiro. 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLS510CJR()
LOCAL lRet := .T.

If !( BSQ->( FieldPos("BSQ_PREORI") ) > 0 .and.;
	BSQ->( FieldPos("BSQ_NUMORI") ) > 0 .and.;
	BSQ->( FieldPos("BSQ_PARORI") ) > 0 .and.;
	BSQ->( FieldPos("BSQ_TIPORI") ) > 0 )
	
	MsgAlert(STR0016) //"Os campos nescessarios para o estorno dos juros devidos para o mes seguinte nao existem na base de dados!
	//"Providenciar a criacao dos campos BSQ_PREORI, BSQ_NUMORI, BSQ_PARORI, BSQ_TIPORI."
	//"O lancamento de debito referente a juros no mes seguinte nao foi estornada."
	
	lRet := .F.
Endif

dbSelectarea("SIX")
If !SIX->( msSeek("BSQ5") )
	
	MsgAlert(STR0017) //"O indice numero 5 do arquivo BSQ nao existe na base de dados. Providenciar indice de ordem 5 com a seguinte "+;
	//"chave: BSQ_FILIAL + BSQ_PREORI + BSQ_NUMORI + BSQ_PARORI + BSQ_TIPORI."
	//"O lancamento de debito referente a juros no mes seguinte nao foi estornada.
	
	lRet := .F.
Endif

If lRet
	
	//Estorna lancamento de debito da familia, preciso do SE5 posicionado ³
	
	BSQ->( dbSetorder(05) )
	If BSQ->( msSeek(xFilial("BSQ")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE5->E5_SEQ) )
		If !Empty(BSQ->BSQ_NUMTIT)
			MsgAlert(STR0018) //"Este titulo gerou um debito referente a JUROS quando foi baixado e este debito ja foi faturado! O movimento de debito nao sera excluido."
		Else
			If ExistBlock("PLS510CN")
				ExecBlock("PLS510CN",.F.,.F.,{BSQ->(Recno()),SE1->(Recno())})
				
				//LOG																		   ³
				
				PLSLOGFAT("PLS510CN",1,.F.)
			EndIf
			BSQ->( RecLock("BSQ", .F.) )
			BSQ->( DbDelete() )
			BSQ->( msUnlock() )
		Endif
	Endif
Endif

Return(.T.)


/*/{Protheus.doc} PLSA510Cd
Retorna proximo codigo da sequencia de ttitulos 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLSA510Cd()
LOCAL nRet    := 0
LOCAL nOrdBBT := BBT->(IndexOrd())

BBT->(DbSetOrder(nOrdBBT))

nRet := GetSx8Num("BBT","BBT_CODIGO")

BBT->( ConfirmSx8() )

Return(nRet)

/*/{Protheus.doc} PL510AIPT
Analiza se devera gerar impostos para a combinacao de 
lancamento de faturamento x produto.
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Static Function PL510AIPT(cLanc, cProd, aPL510BM1,cImp)
LOCAL lRet := .T.
LOCAL nPos := 0

If Len(aPL510BM1) > 0 .And. (nPos := Ascan( aPL510BM1, {|x| x[1]== cLanc .and. x[2] == cProd} )) <> 0
	If cImp == '1'
		lRet := aPL510BM1[nPos][4][1]
	Elseif cImp == '2'
		lRet := aPL510BM1[nPos][5][1]
	Elseif cImp == '3'
		lRet := aPL510BM1[nPos][6][1]
	Else
		lRet := aPL510BM1[nPos][7][1]
	Endif
Endif

Return( lRet )

/*/{Protheus.doc} PL510INSS
Apura base do INSS de acordo com o risco. 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Static Function PL510INSS(aBases, aEventosCB, aVlrLanc, aPL510BM1)
LOCAL i

For i := 1 To Len(aVlrLanc)
	If aVlrLanc[i][1] == aEventosCB[1] .and. PL510AIPT(aVlrLanc[i][1],aVlrLanc[i][3],aPL510BM1,'3')
		If aEventosCB[3] == '1'
			aBases[6] += (aVlrLanc[i][2] * Iif(Empty(aEventosCB[16]),1, Iif(aVlrLanc[i][4] $ '0, ',Val(aEventosCB[17]),Val(aEventosCB[16])) ))
		Else
			aBases[6] -= (aVlrLanc[i][2] * Iif(Empty(aEventosCB[16]),1, Iif(aVlrLanc[i][4] $ '0, ',Val(aEventosCB[17]),Val(aEventosCB[16])) ))
		Endif
	Endif
Next

Return(NIL)

/*/{Protheus.doc} PLSGRVBSQ
Grava BSQ
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLSGRVBSQ(cMatUsu,cConEmp,cVerCon,cSubCon,cVerSub,cAno,cMes,cCodLan,nValor,;
					cNumCob,cPrefixo,cNumero,cTipTit,cTpEmp,cNivel,cCodPro,cTipo)
					
LOCAL nNumBSQ 	:= GETSX8NUM("BSQ","BSQ_CODSEQ")
DEFAULT cTipo 	:= BSP->( Posicione("BSP",1,xFilial("BSP")+cCodLan,"BSP_TIPSER") )
DEFAULT cCodPro	:= ""

//Conforma a gravacao												

BSQ->( ConfirmSx8() )

//Gravacao														

BSQ->( RecLock("BSQ",.T.) )
	BSQ->BSQ_FILIAL := xFilial("BSQ")
	BSQ->BSQ_CODSEQ := nNumBSQ
	BSQ->BSQ_USUARI := cMatUsu
	BSQ->BSQ_CODINT := Subs( cMatUsu,atCodOpe[1],atCodOpe[2] )
	BSQ->BSQ_CODEMP := Subs( cMatUsu,atCodEmp[1],atCodEmp[2] )
	BSQ->BSQ_CONEMP := cConEmp
	BSQ->BSQ_VERCON := cVerCon
	BSQ->BSQ_SUBCON := cSubCon
	BSQ->BSQ_VERSUB := cVerSub
	BSQ->BSQ_MATRIC := Subs( cMatUsu,atMatric[1],atMatric[2] )
	BSQ->BSQ_ANO    := cAno
	BSQ->BSQ_MES    := cMes
	BSQ->BSQ_CODLAN := cCodLan
	BSQ->BSQ_VALOR  := nValor
	BSQ->BSQ_TIPO   := cTipo
	BSQ->BSQ_NUMCOB := cNumCob
	BSQ->BSQ_PREFIX := cPrefixo
	BSQ->BSQ_NUMTIT := cNumero
	BSQ->BSQ_TIPTIT := cTipTit
	BSQ->BSQ_TIPEMP := cTpEmp
	BSQ->BSQ_AUTOMA := "X"
	BSQ->BSQ_COBNIV := cNivel
	If BSQ->( FieldPos("BSQ_CODPRO") ) > 0
		BSQ->BSQ_CODPRO := cCodPro
	EndIf	
BSQ->( MsUnLock() )

Return

/*/{Protheus.doc} PLSGRVBK2
Grava BK2												 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLSGRVBK2(aRetAux,cAno,cMes,cNumCob,cPrefixo,cNumero,cTipTit)
LOCAL nInd		:= 0
LOCAL nIndI		:= 0
LOCAL aRetAcu	:= {}


//Gravacao														

For nIndI := 1 To Len(aRetAux)
	
	aRetAcu := aClone(aRetAux[nIndI])
		
	If Len(aRetAcu) > 0
		
		For nInd := 1 To Len(aRetAcu)
			If Iif( Len(aRetAcu[nInd]) >= 44, !aRetAcu[nInd][44], .T. ) // Verifica o parcelamento
				BK2->(RecLock("BK2",.T.))
				BK2->BK2_FILIAL := xFilial("BK2")
				BK2->BK2_CODINT := subs(aRetAcu[nInd][07],1,4)
				BK2->BK2_CODEMP := subs(aRetAcu[nInd][07],5,4)
				BK2->BK2_MATRIC := subs(aRetAcu[nInd][07],9,6)
				BK2->BK2_TIPREG := subs(aRetAcu[nInd][07],15,2)
				BK2->BK2_DIGITO := subs(aRetAcu[nInd][07],17,1)
				BK2->BK2_ANO    := cAno
				BK2->BK2_MES    := cMes
				BK2->BK2_SALDO  := aRetAcu[nInd][24]
				BK2->BK2_SALDO2 := aRetAcu[nInd][25]
				BK2->BK2_PROPRI := subs(aRetAcu[nInd][3],1,1)
				BK2->BK2_CODLAN := subs(aRetAcu[nInd][3],2,2)
				BK2->BK2_PLNUCO := cNumCob
				BK2->BK2_PREFIX := cPrefixo
				BK2->BK2_NUMTIT := cNumero
				BK2->BK2_TIPTIT := cTipTit
				BK2->(MsUnLock())
			EndIf
		Next
			
	EndIf	
Next

//Limpa da Memoria												
aRetAux := {}

Return

/*/{Protheus.doc} PLSDCTIP
totais de cada tipo de lancamento de faturamento												 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLSDCTIP(aVlrCob, cCodDB, cRisco, aVlrDebCre)
default aVlrDebCre := {}

If __lBSQFields
	
	//Procura Lancamento												
	If aVlrCob[3] $ cCodDB
		
		If Len(aVlrCob) > 26 .And. aVlrCob[27] > 0
		
			BSQ->( msGoto(aVlrCob[27]) )

			AaDd( aVlrDebCre, {	aVlrCob[3],; 	 	//[1]
								aVlrCob[4],; 		//[2]
								BSQ->BSQ_INCIR ,;  	//[3]
								BSQ->BSQ_REGCIR,;  	//[4]
								BSQ->BSQ_INCISS,;  	//[5]
								BSQ->BSQ_REGCIS,;  	//[6]
								BSQ->BSQ_INCCON,;  	//[7]
								BSQ->BSQ_REGCCO,;  	//[8]
								BSQ->BSQ_REGCPI,;  	//[9]
								BSQ->BSQ_INCCSL,;  	//[10]
								BSQ->BSQ_REGCCS,;  	//[11]
								BSQ->BSQ_INCINS,;  	//[12]
								BSQ->BSQ_REGCIN,;  	//[13]
								BSQ->BSQ_REGCI1,;  	//[14]
								BSQ->BSQ_INCPIS,;  	//[15]
								BSQ->BSQ_VALOR ,;  	//[16]
								cRisco})           	//[17]
		EndIf

	EndIf

EndIf

return

/*/{Protheus.doc} PLSGRVBM1
Grava BM1												 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLSGRVBM1(cMatUsu,_cChave,aVlrCob,cSeq,_cNivel,lPeriod,lCusOpe,lIntPos,cAno,cMes,cAnoMesAnt,;
					cCodInt,cNumCob,cPrefixo,cNumero,cTipTit,cTipoSer,nPosNpr,aMatNmPr,cNumPar,cInterc,;
					cTipInt,cNaturez)       

local lCMALCO	:= getNewPar("MV_CMALCO", .t.)
local cConEmp	:= BA1->BA1_CONEMP
local cVerCon	:= BA1->BA1_VERCON
local cSubCon	:= BA1->BA1_SUBCON
local cVerSub	:= BA1->BA1_VERSUB
local aRetPe	:= {}
local nPercDias := 0
local nDiasUtil	:= 0
local lCobProRat:= .f.
local lCobRatRet:= .f.
local lCobRet	:= .f.

default cNaturez := " "	

if existBlock("PLCNTBM1")

	aRetPe 	:= execBlock("PLCNTBM1", .f., .f., aVlrCob)
	cConEmp := aRetPe[1]
	cVerCon := aRetPe[2]
	cSubCon := aRetPe[3]
	cVerSub := aRetPe[4]

	PLSLOGFAT("PLCNTBM1",1,.F.)

endIf

//Gravacao														
BM1->( recLock("BM1", .t.) )

	BM1->BM1_FILIAL := xFilial("BM1")
	BM1->BM1_CODINT := Iif( ! empty(cMatUsu), subs(cMatUsu, 1, 4), subs(_cChave, atCodOpe[1], atCodOpe[2]) )
	BM1->BM1_CODEMP := Iif( ! empty(cMatUsu), subs(cMatUsu, 5, 4), subs(_cChave, atCodEmp[1], atCodEmp[2]) )
	
	if len(aVlrCob) > 15 .and. valType(aVlrCob[16]) == "C"
		BM1->BM1_ALIAS := aVlrCob[16]
	endIf
	
	//Se o registro estiver vindo da BSQ ( Debitos / Creditos ), grava    
	//para o nivel de cobranca                                            
	if empty(cMatUsu)

		if _cNivel == '2'

			BM1->BM1_CONEMP := subStr(_cChave, 09, 12)
			BM1->BM1_VERCON := subStr(_cChave, 21, 03)

		elseIf _cNivel == '3'

			BM1->BM1_CONEMP := subStr(_cChave, 09, 12)
			BM1->BM1_VERCON := subStr(_cChave, 21, 03)
			BM1->BM1_SUBCON := subStr(_cChave, 24, 09)
			BM1->BM1_VERSUB := subStr(_cChave, 33, 03)

		endIf

	else
		
		BM1->BM1_CONEMP := cConEmp
		BM1->BM1_VERCON := cVerCon
		
		if BM1->BM1_ALIAS == "BSQ" .and. cPaisLoc == "BRA"

			if _cNivel > '2'
				BM1->BM1_SUBCON := cSubCon
				BM1->BM1_VERSUB := cVerSub
			endIf

			If Len(aVlrCob) >= 27 .And. ValType(aVlrCob[27]) == "N" // Recno da BSQ correspondente
				BSQ->(DBGoTo(aVlrCob[27]))
			EndIf

			if _cNivel > '3' .or. !Empty(BSQ->BSQ_USUARI)

				BM1->BM1_MATRIC := subs(cMatUsu, 9, 6)
				BM1->BM1_TIPREG := subs(cMatUsu, 15, 2)
				BM1->BM1_DIGITO := Iif( len(cMatUsu) > 16, right(cMatUsu,1), '')
				BM1->BM1_MATUSU := cMatUsu
				BM1->BM1_NOMUSR := PLNOMUSR(cMatUsu)
				BM1->BM1_SEXO   := BA1->BA1_SEXO
				BM1->BM1_GRAUPA := BA1->BA1_GRAUPA
				BM1->BM1_TIPUSU := BA1->BA1_TIPUSU

			endIf

		else
			
			BM1->BM1_SUBCON := cSubCon
			BM1->BM1_VERSUB := cVerSub
			BM1->BM1_MATRIC := Iif( ! empty(cMatUsu), subs(cMatUsu, 9, 6) , '')
			BM1->BM1_TIPREG := Iif( ! empty(cMatUsu), subs(cMatUsu, 15, 2), '')
			BM1->BM1_DIGITO := IIf( len(cMatUsu) > 16, right(cMatUsu,1), '')
			BM1->BM1_MATUSU := cMatUsu
			BM1->BM1_NOMUSR := PLNOMUSR(cMatUsu)
			BM1->BM1_SEXO   := BA1->BA1_SEXO
			BM1->BM1_GRAUPA := BA1->BA1_GRAUPA
			BM1->BM1_TIPUSU := BA1->BA1_TIPUSU

		endIf

	endIf

	//Campos Autogestao...                                     		
	if lBM1_VERSIG .and. len(aVlrCob) >= 22 
		BM1->BM1_VERSIG := Iif( valType(BM1->BM1_VERSIG) == valType(aVlrCob[22]), aVlrCob[22], "" )
	endIf
	
	if lBM1_AGFMTFU
	
		//Nesse momento as tabelas BA1/BA3 estão poscionadas não precisamos reposicionar (performance)
		//E para os casos onde o nivel da cobrança é no subcontrato e efetudo credito (BSQ) no subcontrato não terei matricula
	
		BM1->BM1_AGFTFU := BA3->BA3_AGFTFU
		BM1->BM1_AGMTFU := BA3->BA3_AGMTFU
	
	endIf
	
	if lBM1_VALMES .and. len(aVlrCob) >= 23
		BM1->BM1_VALMES := aVlrCob[23]
	endIf
	
	BM1->BM1_SEQ    := cSeq
	BM1->BM1_NIVCOB := _cNivel

	if __cFunName == "PLSA628"
		BM1->BM1_ANO := Iif( lPeriod, aVlrCob[59], Iif( ! lCusOpe .and. ! lIntPos, cAno, subs(cAnoMesAnt, 1, 4) ) )
		BM1->BM1_MES := Iif( lPeriod, aVlrCob[60], Iif( ! lCusOpe .and. ! lIntPos, cMes, subs(cAnoMesAnt, 5, 2) ) )
	else
		BM1->BM1_ANO := Iif( lPeriod, aVlrCob[59], Iif( ! lCusOpe .and. ! lIntPos .or. ! lCMALCO, cAno, subs(cAnoMesAnt, 1, 4) ) )
		BM1->BM1_MES := Iif( lPeriod, aVlrCob[60], Iif( ! lCusOpe .and. ! lIntPos .or. ! lCMALCO, cMes, subs(cAnoMesAnt, 5, 2) ) )
	endIf

	BM1->BM1_TIPO   := aVlrCob[1]
	BM1->BM1_VALOR  := aVlrCob[2]
	
	plsPRUSU(BA3->BA3_CODINT, .f., nil, nil, @lCobProRat, nil, @lCobRet, @lCobRatRet)

	if __lBM1COB .and. (! lCobProRat .or. ! lCobRatRet) .and. lCobRet

		nPercDias := plRPerPR(BA1->BA1_DATINC, nil, @nDiasUtil)
		
		//nao foi o mes cheio e nao a retroativa
		if nPercDias < 100 .and. aVlrCob[3] $ '101|118' //verificar nos niveis se prorat esta ligada
			BM1->BM1_COBRET := ( aVlrCob[2] * nPercDias ) / 100
			BM1->BM1_COBATU := ( aVlrCob[2] * (100 - nPercDias) ) / 100 
		endIf

		BM1->BM1_DIAUTI := nDiasUtil

	endIf

	BM1->BM1_CODTIP := aVlrCob[3]
	BM1->BM1_DESTIP := BFQ->(Posicione("BFQ",1,xFilial("BFQ")+BM1->BM1_CODINT+BM1->BM1_CODTIP,"BFQ_DESCRI"))
	BM1->BM1_CODEVE := aVlrCob[4]
	BM1->BM1_DESEVE := aVlrCob[5]
	
	if Len(aVlrCob) > 16 .and. ValType(aVlrCob[17]) == "C"
		BM1->BM1_ORIGEM := aVlrCob[17]
	endIf

	if Len(aVlrCob) > 17 .and. ValType(aVlrCob[18]) == "N" .and. aVlrCob[3] <> "199"
		BM1->BM1_BASEIR := aVlrCob[18]
	endIf
	
	BM1->BM1_PLNUCO := cCodInt + cNumCob
	BM1->BM1_LTOTAL := Iif(aVlrCob[9], "1", "0")
	BM1->BM1_CODFAI := aVlrCob[13]
	BM1->BM1_NIVFAI := aVlrCob[14]
	BM1->BM1_CARGO  := aVlrCob[6]
	BM1->BM1_PREFIX := cPrefixo
	BM1->BM1_NUMTIT := cNumero
	BM1->BM1_TIPTIT := cTipTit
	
	if lBM1_ATOCOO
		BM1->BM1_ATOCOO := cTipoSer
	endIf

	if lBM1_NUMPAR

		if nPosNpr > 0

			if ! empty(cMatUsu)
				BM1->BM1_NUMPAR := aMatNmPr[nPosNpr][2]
			else
				BM1->BM1_NUMPAR := cNumPar
			endIf

		else
			BM1->BM1_NUMPAR := cNumPar
		endIf

	endIf

	if lBM1_IDAINI
		BM1->BM1_IDAINI := aVlrCob[20]
	endIf

	if lBM1_IDAFIN
		BM1->BM1_IDAFIN := aVlrCob[21]
	endIf

	BM1->BM1_INTERC := cInterc

	if lBM1_TIPINT
		BM1->BM1_TIPINT := cTipInt
	endIf
	
	//Grava o valor do desconto ou acrescimo consedido.             
	if len(aVlrCob) > 28

		if lBM1_VALDES
			BM1->BM1_VALDES := aVlrCob[28]
		endIf

		if lBM1_VALACR
			BM1->BM1_VALACR := aVlrCob[29]
		endIf

	endIf

	if len(aVlrCob) >= 30

		If lBM1_CODSEQ
			BM1->BM1_CODSEQ := aVlrCob[30]
		endIf

	endIf

	if lBM1_CVDPLA 
		
		if len(aVlrCob) > 33
			BM1->BM1_CODPLA := aVlrCob[34]
			BM1->BM1_VERPLA := aVlrCob[35]
			BM1->BM1_DESPLA := aVlrCob[36]
		endIf

	endIf
	
	if len(aVlrCob) >= 38 .and. lBM1_CODTES
		
		BM1->BM1_CODTES := aVlrCob[38]
		        
		if lBM1_CSTCP 
			
			if SF4->( msSeek( xFilial('SF4') + aVlrCob[38] ) )   
				BM1->BM1_CSTCOF	:= SF4->F4_CSTCOF
				BM1->BM1_CSTPIS := SF4->F4_CSTPIS
			endIf	
		
		endIf
		
	endIf
	
	if lBM1_NATURE

		BM1->BM1_NATURE := cNaturez        

		if lBM1_CSTCP 
			
			if SED->( msSeek( xFilial('SED') + cNaturez ) )   
				BM1->BM1_CSTCOF	:= SED->ED_CSTCOF
				BM1->BM1_CSTPIS := SED->ED_CSTPIS
			endIf
				
		endIf
		
	endIf

	if len(aVlrCob) >= 37 .and. lBM1_CODSB1
		BM1->BM1_CODSB1 := aVlrCob[37]
	endIf
	
BM1->( msUnLock() )

//Recno															
if len(aVlrCob) >= 38
	aVlrCob[39] := BM1->( recno() )
endIf

//Ponto de entrada executado apos a gravacao do BM1.                  
if lPlGrvBm1 

	execBlock("PLGRVBM1", .f., .f., {})
	PLSLOGFAT("PLGRVBM1", 1, .f.)

endIf

return

/*/{Protheus.doc} PLSBM1COM
Tratar os acumulados													 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLSBM1COM(aAcertos,aVetAux,lGerSE1)
local TpUsu

//Checa															


If  BM1->(FieldPos("BM1_AGMTFU")) > 0  .And. BM1->(FieldPos("BM1_VERSIG")) > 0 .And.;
		BM1->(FieldPos("BM1_AGFTFU")) > 0  .And. BFQ->(FieldPos("BFQ_LANACE")) > 0 .And.  !lGerSE1
			
	IF BM1->BM1_TIPUSU == "A"
		TpUsu := "3"
	Else
		TpUsu := Iif(BM1->BM1_TIPUSU == GetNewPar("MV_PLCDTIT","T"),"1","2")
	Endif
	
		BM1->(AaDd(aVetAux, {  BM1_CODINT,;  //01
								BM1_CODEMP,;  //02
								BM1_MATRIC,;  //03
								BM1_VALOR,;   //04
								BM1_CODTIP,;  //05
								BM1_AGFTFU,;  //06
								BM1_AGMTFU,;  //07
								BM1_VERSIG,;  //08
								BM1_ANO,;     //09
								BM1_MES,;     //10
								BM1_PLNUCO,;  //11
								BM1_TIPREG,;  //12
								TpUsu,; //13							
								 BFQ->BFQ_TPLAN}) ) //14 

EndIf

Return

/*/{Protheus.doc} PLSMATBA1
tratar os acumulados														 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLSMATBA1(cMatUsu,cNumCob,lCusOpe,lIntPos,cAno,cMes,cAnoMesAnt,;
					aVlrCob,lVldFIELD,aMatBA1)
LOCAL nPos	:= 0		

//Checa															

If !Empty(cMatUsu) .And. !BA1->( Eof() )
	
	If (nPos := Ascan(aMatBA1, { |x| x[1] == BA1->( Recno() ) } ) ) == 0
		AaDd(aMatBA1,{	BA1->( Recno() ),;
						cNumCob,;
						Iif(!lCusOpe .And. !lIntPos,(cAno+cMes), cAnoMesAnt),;
						Iif( BM1->BM1_CODTIP == "103" ,aVlrCob[2],0),;
						Iif( BM1->BM1_CODTIP == "133" .And. lVldFIELD,aVlrCob[2],0) } )
	Else
		aMatBA1[nPos,4] := Iif(aMatBA1[nPos,4]==0 .And. BM1->BM1_CODTIP == "103" , aVlrCob[2] , aMatBA1[nPos,4] )
		aMatBA1[nPos,5] := Iif(aMatBA1[nPos,5]==0 .And. BM1->BM1_CODTIP == "133" .And. lVldFIELD , aVlrCob[2] , aMatBA1[nPos,5] )
	EndIf
EndIf

Return

/*/{Protheus.doc} PLSATUBSQ
Atualiza BSQ															 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLSATUBSQ(cNumCob,cPrefixo,cNumero,cTipTit)

//Atualiza														

BSQ->( RecLock("BSQ",.F.) )
	BSQ->BSQ_NUMCOB := cNumCob
	BSQ->BSQ_PREFIX := cPrefixo
	BSQ->BSQ_NUMTIT := cNumero
	BSQ->BSQ_TIPTIT := cTipTit
BSQ->( MsUnLock() )

Return

/*/{Protheus.doc} PLSGRVBBT
Grava BBT															 
@author  PLS TEAM
@version P12
@since   26.01.00
/*/
Function PLSGRVBBT(_cChave,_cNivel,cCodCli,cLoja,nValor,lCusOpe,lIntPos,cAno,cMes,cAnoMesAnt,;
				   cPrefixo,cNumero,cTipTit,cNumCob,cInterc,cModPag,cTipInt,;
				   cOpeDes,dEmissao)

LOCAL __cCodigo := GetSx8Num("BBT","BBT_CODIGO")
LOCAL lCMALCO := GetNewPar("MV_CMALCO", .T.)

//Gravacao														

BBT->( ConfirmSx8() )

//Grava Cabecalho do Historico...                               
BBT->( RecLock("BBT",.T.) )
	BBT->BBT_FILIAL := xFilial("BBT")
	BBT->BBT_CODIGO := __cCodigo
	BBT->BBT_CODOPE := Substr(_cChave,1,4)
	BBT->BBT_CODEMP := Substr(_cChave,5,4)
	
	If _cNivel == "2" //Nivel contrato
		BBT->BBT_CONEMP := Substr(_cChave,9,12)
		BBT->BBT_VERCON := Substr(_cChave,21,3)
	
	ElseIf _cNivel == "3"  //Nivel subcontrato
		BBT->BBT_CONEMP := Substr(_cChave,9,12)
		BBT->BBT_VERCON := Substr(_cChave,21,3)
		BBT->BBT_SUBCON := Substr(_cChave,24,9)
		BBT->BBT_VERSUB := Substr(_cChave,33,3)
	
	ElseIf _cNivel == "4" //nivel familia
		BBT->BBT_MATRIC := Substr(_cChave,9,6)
	
	ElseIf _cNivel == "5" //nivel usuario
		BBT->BBT_MATRIC := Substr(_cChave,9,6)
		BBT->BBT_TIPREG := Substr(_cChave,15,2)
	
	ElseIf _cNivel == "6" //nivel opcional
		BBT->BBT_MATRIC := Substr(_cChave,9,6)
		BBT->BBT_TIPREG := Substr(_cChave,15,2)
		BBT->BBT_CODPRO := Substr(_cChave,17,4)
	EndIf
	
	BBT->BBT_CLIFOR := cCodCli
	BBT->BBT_LOJA   := cLoja
	BBT->BBT_VALOR  := nValor
	BBT->BBT_NIVEL  := _cNivel
	
	//Se for custo, o ano / mes base e o mes anterior.				
	
	If FunName() == "PLSA628"
		BBT->BBT_ANOTIT := Iif(!lCusOpe .And. !lIntPos,cAno, Subs(cAnoMesAnt,1,4))
		BBT->BBT_MESTIT := Iif(!lCusOpe .And. !lIntPos,cMes, Subs(cAnoMesAnt,5,2))
	Else
		BBT->BBT_ANOTIT := Iif(!lCusOpe .And. !lIntPos .Or. !lCMALCO,cAno, Subs(cAnoMesAnt,1,4))
		BBT->BBT_MESTIT := Iif(!lCusOpe .And. !lIntPos .Or. !lCMALCO,cMes, Subs(cAnoMesAnt,5,2))
	EndIf
	
	BBT->BBT_PREFIX := cPrefixo
	BBT->BBT_NUMTIT := cNumero
	BBT->BBT_TIPTIT := cTipTit
		
	BBT->BBT_NUMCOB := cNumCob
	BBT->BBT_RECPAG := "0"
	BBT->BBT_CODPLA := BA3->BA3_CODPLA
	BBT->BBT_VERSAO := BA3->BA3_VERSAO
	BBT->BBT_INTERC := cInterc
	If BBT->( FieldPos("BBT_TPFTIN") ) > 0
		BBT->BBT_TPFTIN := Iif(lCusOpe,'1','0')
	Endif
	If BBT->( FieldPos("BBT_MODPAG") ) > 0
		BBT->BBT_MODPAG := cModPag
	Endif
	If BBT->( FieldPos("BBT_TIPINT") ) > 0
		BBT->BBT_TIPINT := cTipInt
	Endif
	If cInterc == '1'
		BBT->BBT_OPEDES := cOpeDes
	Endif
	If BBT->(FieldPos("BBT_AGMTFU")) > 0 .And. BBT->(FieldPos("BBT_AGFTFU")) > 0
		BBT->BBT_AGFTFU := BA3->BA3_AGFTFU
		BBT->BBT_AGMTFU := BA3->BA3_AGMTFU
	Endif
	If BBT->( FieldPos("BBT_DATEMI") ) > 0
		BBT->BBT_DATEMI := dEmissao
	Endif

BBT->(MsUnlock())

Return( BBT->( RecNo() ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLRatImpLot
Realizar o Rateio dos Impostos ao Gerar o Lote de Cobrança

@author  Vinicius.Queiros
@version Protheus 12
@since   29/10/2020
@Obs Caso o Recno não seja informado o Titulo (SE1) precisa esta 
     posicionado
/*/
//------------------------------------------------------------------- 
Static Function PLRatImpLot(cCodInt, cNumCob, nRecno)

	Local cQuery := ""
	Local nBusca := 0			
	Local nNx := 0
	Local aVlrBM1 := {}
	Local aRatImpost := {}
	Local aRateioImp := {}
	Local nRatIRF := 0
	Local nRatPIS := 0
	Local nRatCOFINS := 0
	Local nRatCSLL	:= 0
	Local nVlrIRF := 0
	Local nVlrPIS := 0
	Local nVlrCOFINS := 0
	Local nVlrCSLL := 0
	Local nValorTit := 0
	Local nIRF := 0
	Local nPIS := 0
	Local nCOFINS := 0
	Local nCSLL := 0
	Local aAreaSE1 := SE1->(GetArea())

	Default nRecno := 0

	If nRecno > 0
		SE1->(DbGoTo(nRecno))
	EndIf

	nValorTit	:= SE1->E1_VALOR
	nIRF		:= SE1->E1_IRRF
	nPIS		:= SE1->E1_PIS
	nCOFINS		:= SE1->E1_COFINS
	nCSLL		:= SE1->E1_CSLL

	cQuery := "SELECT BM1_VALOR, BM1_CODTIP FROM " + RetSQLName("BM1") + " BM1 "
	cQuery += " WHERE BM1_FILIAL = '" + xFilial("BM1") + "'"
	cQuery += "	  AND BM1.BM1_PLNUCO = '" + cCodInt + cNumCob + "'"
	cQuery += "	  AND BM1.BM1_PREFIX = '" + SE1->E1_PREFIXO 	 + "'"
	cQuery += "	  AND BM1.BM1_NUMTIT = '" + SE1->E1_NUM + "'"
	cQuery += "	  AND BM1.BM1_TIPTIT = '" + SE1->E1_TIPO + "'"
	cQuery += "	  AND BM1.BM1_PARCEL = '" + SE1->E1_PARCELA + "'"
	cQuery += "   AND BM1.D_E_L_E_T_= ' ' "
	cQuery += " ORDER BY BM1_CODTIP "

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),"TrbBM1",.F.,.T.)

	// Aglutina os Valores da BM1 por tipo de lançamento	        
	While !TrbBM1->(Eof())				
			nBusca := Ascan(aVlrBM1, {|x| x[1] == TrbBM1->BM1_CODTIP})

			If nBusca > 0
				aVlrBM1[nBusca][2] += TrbBM1->BM1_VALOR
			Else	
				aAdd(aVlrBM1,{ TrbBM1->BM1_CODTIP, TrbBM1->BM1_VALOR })
			EndIf

		TrbBM1->(DbSkip())		
	EndDo
	
	TrbBM1->(dbCloseArea())
	
	If Len(aVlrBM1) > 0
		
		For nNx := 1 To Len(aVlrBM1)
			// Efetua o rateio da proporção de cada Tipo de Lançamento x Valor total do Titulo
			nRateio := ((aVlrBM1[nNx][2] * 100) / nValorTit) / 100

			// Calcula o valor de rateio de cada imposto quando houver 
			If nIRF > 0
				nRatIRF := nRateio * nIRF
				aAdd(aRatImpost, { aVlrBM1[nNx][1], "IRF", Round(nRatIRF,2), aVlrBM1[nNx][2] } )	
				nVlrIRF += Round(nRatIRF,2)	 
			EndIf

			If nPIS > 0
				nRatPIS := nRateio * nPIS
				aAdd(aRatImpost, { aVlrBM1[nNx][1], "PIS", Round(nRatPIS,2), aVlrBM1[nNx][2] } )
				nVlrPIS += Round(nRatPIS,2)  				 	
			EndIf

			If nCOFINS > 0
				nRatCOFINS := nRateio * nCOFINS
				aAdd(aRatImpost, { aVlrBM1[nNx][1], "COFINS", Round(nRatCOFINS,2), aVlrBM1[nNx][2] } )  
				nVlrCOFINS += Round(nRatCOFINS,2)		
			EndIf

			If nCSLL > 0
				nRatCSLL := nRateio * nCSLL
				aAdd(aRatImpost, { aVlrBM1[nNx][1], "CSLL", Round(nRatCSLL,2), aVlrBM1[nNx][2] } )
				nVlrCSLL += Round(nRatCSLL,2) 		
			EndIf 

		Next nNx

		// Verifica o valor gravado do imposto com o valor total do imposto do título
		If nVlrIRF > 0
			nVlrIRF := nIRF - nVlrIRF
		EndIf

		If nVlrPIS > 0
			nVlrPIS := nPIS - nVlrPIS
		EndIf

		If nVlrCOFINS > 0
			nVlrCOFINS := nCOFINS - nVlrCOFINS
		EndIf

		If nVlrCSLL > 0
			nVlrCSLL := nCSLL - nVlrCSLL
		EndIf 

		// Quando houver diferença de centavos do rateio, adiciona/diminui do lançamento
		If Len(aRatImpost) > 0
			For nNx := 1 To Len(aRatImpost)
				Do Case
					Case aRatImpost[nNx][2] == "IRF" .And. nVlrIRF <> 0
						aRatImpost[nNx][3] += nVlrIRF
						nVlrIRF := 0

					Case aRatImpost[nNx][2] == "PIS" .And. nVlrPIS <> 0
						aRatImpost[nNx][3] += nVlrPIS
						nVlrPIS := 0

					Case aRatImpost[nNx][2] == "COFINS" .And. nVlrCOFINS <> 0
						aRatImpost[nNx][3] += nVlrCOFINS
						nVlrCOFINS := 0

					Case aRatImpost[nNx][2] == "CSLL" .And. nVlrCSLL <> 0
						aRatImpost[nNx][3] += nVlrCSLL
						nVlrCSLL := 0
				EndCase

				aAdd(aRateioImp, { cCodInt ,; 				// [1]  B6U_CODINT 
							   	   cNumCob ,; 				// [2]  B6U_NUMCOB	 
							   	   aRatImpost[nNx][1] ,; 	// [3]  B6U_CODTIP
							   	   SE1->E1_PREFIXO ,; 		// [4]  B6U_PREFIX	 
							       SE1->E1_NUM ,; 			// [5]  B6U_NUMTIT 
							       SE1->E1_TIPO ,; 			// [6]  B6U_TIPTIT	 
							       SE1->E1_PARCELA ,; 		// [7]  B6U_PARCEL		 
							       aRatImpost[nNx][2] ,;	// [8]  B6U_IMPOST			 
							       aRatImpost[nNx][3] ,;	// [9]  B6U_VALOR
								   aRatImpost[nNx][4] ,;	// [10] B6U_VALBAS
								   SE1->E1_EMISSAO ,;		// [11] B6U_DTEMIS
								   SE1->E1_CLIENTE ,;		// [12] B6U_CODIGO
								   SE1->E1_LOJA ,;			// [13] B6U_LOJA
								   SE1->E1_TIPO } ) 		// [14] B6U_TIPBAS
			Next nNx
		EndIf
	EndIf

	RestArea(aAreaSE1)

Return aRateioImp

//------------------------------------------------------------------- 
/*/{Protheus.doc} PLGrvRateio
Gravação da tabela de rateio

@author  Vinicius Queiros Teixeira
@since   29/01/2021
@version Protheus 12
/*/
//------------------------------------------------------------------- 
Function PLGrvRateio(aRateio)

	Local nX := 0
	Local lRetorno := .F.

	If Len(aRateio) > 0 .And. ChkFile("B6U") .And. PlsAliasExi("B6U")
		For nX := 1 To Len(aRateio)
			B6U->(Reclock("B6U",.T.))

			B6U->B6U_FILIAL := xFilial("B6U")
			B6U->B6U_CODINT := aRateio[nX][1] 
			B6U->B6U_NUMCOB := aRateio[nX][2] 
			B6U->B6U_CODTIP := aRateio[nX][3]
			B6U->B6U_PREFIX	:= aRateio[nX][4] 
			B6U->B6U_NUMTIT := aRateio[nX][5] 
			B6U->B6U_TIPTIT := aRateio[nX][6] 
			B6U->B6U_PARCEL := aRateio[nX][7] 
			B6U->B6U_IMPOST := aRateio[nX][8]
			B6U->B6U_VALOR := aRateio[nX][9]
			B6U->B6U_VALBAS	:= aRateio[nX][10]
			B6U->B6U_DTEMIS	:= aRateio[nX][11]
			B6U->B6U_CODIGO	:= aRateio[nX][12]
			B6U->B6U_LOJA := aRateio[nX][13]
			B6U->B6U_TIPBAS := aRateio[nX][14]
			If Len(aRateio[nX]) >= 15 
				B6U->B6U_SEQBAI := aRateio[nX][15]
			EndIf

			B6U->(MsUnLock())
		Next nX
		lRetorno := .T.
	EndIf
 
Return lRetorno