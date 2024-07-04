#include "plstose1.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

static __cCondPag := ''
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

/*/{Protheus.doc} PlsToSe1
Gera titulos a partir de uma cobranca     
o array aCampos deve ser enviado para este funcao contendo o nome do campo e seu respectivo conteudo.
é fundamental que seja enviado a numeracao do titulo, vencto, filial, valor e saldo, natureza, cliente, loja
também deve ser enviado os campos referentes aos impostos (iss, inss, cofins, pis, csll) com valores iguais a zero (0),
para que a rotina crie as variavies que a integracao com o financeiro possa efetuar os calculos
é fundamental também que o controle de transacao esteja entre a chamada da rotina (begin, chamada, end) para que todas as gravacoes
estejam controladas pela transacao.
esta funcao espera o SED (natureza) e o SA1 (Clientes) já posicionado pela rotina chamadora

o array aBases deverá conter os valores para a base dos impostos - passar na ordem cfe abaixo
Abaixo exemplo dos campos obrigatorios a serem passados

@author  PLS TEAM
@version P12
@since   25/05/04
/*/
function PLSTOSE1(aCampos, aBases, cMesRef, cAnoRef, cOrigem, lContabiliza, lCusOpe, aVlrCob, cPrefixo, cNumero,;
				  nPLGERREC, nPeriod, lNCC, aEventosCb, lPosSE1Ger, aCritica)
local nX				:= 0
local nFor				:= 0
local nPos				:= 0
local nPTotal			:= 0
local nPBasImp1			:= 0
local nPDesconto		:= 0
local nBasImp1			:= 0	
local nRecSe1 			:= 0
local nCalAcrs			:= 0
local nArredPrcLis		:= 0
local nValor			:= 0
local nTamSerie			:= tamSX3("F2_SERIE")[1]
local cCodLanCredito 	:= ""
local cCodLanDebito 	:= "" 
local cCodLancamento	:= ""
local cNumNFS			:= ""
local cSerieNFS			:= ""
local cClieFor		    := ""
local cLoja			    := ""
local cItem			    := ""
local cNivel			:= "" 
local cNatureza			:= ""
local cDoc				:= ""
local cCampos			:= ""
local cSerOri		    := ""
local cNumORI		    := ""
local cTextoSF2			:= ""
local cMsgErr			:= "Não Informado"				
local lErro				:= .f.
local lCredito			:= .f.
local lBXComp			:= .f.
local lNoFiscal         := .f.
local lMostraCtb		:= .f.
local lAglutCtb         := .f.
local lCtbOnLine        := .f.
local lCtbCusto         := .f.
local lReajusta			:= .f.
local lAtuSA7			:= .f.
local lECF				:= .f.
local lGerNFBRA			:= ( (getNewPar("MV_PLSNFBR","0") == "1".and. ! lNCC) .or. cPaisLOC <> 'BRA' )
local lTitDesc			:= getNewPar("MV_PLSDCOP",.f.)
local lPgtAto           := .f.
local dDatEmis          := cToD("")
local bFilSD2     		:= NIL
local bSD2     			:= NIL
local bSF2     			:= NIL
local bTTS     			:= NIL
local bFiscalSF2		:= NIL
local bFiscalSD2        := NIL
local bFatSE1           := NIL
local aArea 			:= getArea()
local aItemSD2			:= {}
local aSD2_BM1 			:= {}
local aRetDes			:= {}
local aRetFind			:= {}
local aCliente			:= {} 
local aErro				:= {}
local aStruSF2			:= {}
local aStruSD2			:= {}
local aSF2				:= {}
local aDocOri			:= {}
local aItemOri			:= {}
local aItemOriC			:= {}
local lComp             := .F.
local lGerNcc			:= GetNewPar("MV_PLGENCC","0") == "1"  // Modelo antigo de gerar ncc o credito e descontado no valor total da nota
local lNewRec			:= .T.
local nValorBGQ			:= 0
local cSql              := ''
local lCalcImpostNF 	:= .F.

default nPLGERREC  		:= 0
default nPeriod         := 0
default cPrefixo        := ""
default cNumero         := ""
default cOrigem    		:= "PLSTOSE1"
default aVlrCob 		:= {}
default aEventosCb		:= {}
default aCritica		:= nil
default lContabiliza 	:= .f.
default lNCC			:= .f.
default lCusOpe       	:= .t.
default lPosSE1Ger      := .f.

private nVlRetPis  		:= 0
private nVlRetCof  		:= 0
private nVlRetCsl  		:= 0
private NVLORIPIS  		:= 0
private NVLORICOF  		:= 0
private NVLORICSL  		:= 0 
private nIndexSE1 		:= ""
private cIndexSE1 		:= ""
private cModRetPIS 		:= getNewPar( "MV_RT10925", "1" )
private lF040Auto  		:= .f.
private aDadosRef 		:= Array(7)
private aDadosRet 		:= Array(7)
private aDadosImp 		:= Array(3) 

private lMsErroAuto 	:= .f.
private lMsHelpAuto		:= .t.
private lAutoErrNofile	:= .t.

//campos que seram atualizados apos geracao da nota fiscal
cCampos := 'E1_ANOBASE|E1_MESBASE|E1_CODINT|E1_CODEMP|E1_CONEMP|E1_VERCON|E1_SUBCON|E1_VERSUB|E1_NUMCON|'
cCampos += 'E1_MATRIC|E1_TIPREG|E1_CODCOR|E1_PLORIG|E1_NUMBCO|E1_PLNUCOB|E1_ORIGEM|E1_LA|E1_FORMREC|E1_MULTNAT|'
cCampos += 'E1_APLVLMN|E1_PORTADO|E1_AGEDEP|E1_CONTA|E1_BCOCLI|E1_AGECLI|E1_CTACLI|E1_VALJUR|E1_PORCJUR|'
cCampos += 'E1_VENCTO|E1_VENCREA|E1_NATUREZ'

//Inicia os arrays de  impostos do zero                   
aFill(aDadosRef,0)
aFill(aDadosRet,0)
aFill(aDadosImp,0)

//Gravacao do titulo ou notafiscal							
if ! lGerNFBRA 

	nPos := aScan(aCampos,{|x| x[1] == "E1_PREFIXO"}) 

    if aCampos[nPos][2] == "CPP"

		if existBlock('PLSALTCPP')
			aCampos := execBlock('PLSALTCPP',.f.,.f., { aCampos } )	
		endIf

	endIf

	msExecAuto({|x,y| Fina040(x,y)}, aCampos, 3) //Inclusao
	
	if lMsErroAuto

		SE1->( rollBackSX8() )
		disarmTransaction()

		lErro := .t.

		if aCritica <> NIL

			aErro := getAutoGrLog()

			varInfo('Erro FINA040', aErro)

			for nX := 1 to len(aErro)

				if 'INVALIDO' $ upper(aErro[nX]) .or. 'AJUDA' $ upper(aErro[nX])

					if cMsgErr == "Não Informado"
						cMsgErr := ""
					endIf

					cMsgErr += aErro[nX]

				endIf	

			next

			A627RetCri(@aCritica, '29', 0, nil, {}, cMsgErr)

		else
			mostraErro()
		endIf	
	
	else
		SE1->(confirmSx8())
		nRecSe1 := SE1->(recno())
	endIf

else

	SB1->( dbSetOrder(1) ) //B1_FILIAL+B1_COD                                                                                                                                                
	SF4->( dbSetOrder(1) ) //F4_FILIAL+F4_CODIGO                                                                                                                                             
	
   	aStruSF2 := SF2->(dbStruct())
	   
	//Campos do SF2															   
	for nFor := 1 to len(aStruSF2)

		if aStruSF2[nFor][2] $ "C/M"
			aadd(aSF2,"")
		elseIf aStruSF2[nFor][2] == "N"
			aadd(aSF2,0)
		elseIf aStruSF2[nFor][2] == "D"
			aadd(aSF2,cToD("  /  /  "))
		elseIf aStruSF2[nFor][2] == "L"
			aadd(aSF2,.f.)
		endIf

	next nFor

	aStruSD2 	 := SD2->(dbStruct())
	
	nPTotal      := aScan(aStruSD2,{|x| allTrim(x[1]) == "D2_TOTAL"})
	nPDesconto   := aScan(aStruSD2,{|x| allTrim(x[1]) == "D2_DESCON"})
	nPBasImp1    := aScan(aStruSD2,{|x| allTrim(x[1]) == "D2_BASIMP1"})

	cDoc	     := eval({ || nPos := aScan(aCampos,{|x| allTrim(x[1]) == "E1_NUM"}),     iIf(nPos > 0, aCampos[nPos,2], "") } )
	cCliefor     := eval({ || nPos := aScan(aCampos,{|x| allTrim(x[1]) == "E1_CLIENTE"}), iIf(nPos > 0, aCampos[nPos,2], "") } )
	cLoja        := eval({ || nPos := aScan(aCampos,{|x| allTrim(x[1]) == "E1_LOJA"}),    iIf(nPos > 0, aCampos[nPos,2], "") } )
	cNatureza  	 := eval({ || nPos := aScan(aCampos,{|x| allTrim(x[1]) == "E1_NATUREZ"}), iIf(nPos > 0, aCampos[nPos,2], "") } ) 
	dDatEmis     := eval({ || nPos := aScan(aCampos,{|x| allTrim(x[1]) == "E1_EMISSAO"}), iIf(nPos > 0, aCampos[nPos,2], "") } )
	nValor       := eval({ || nPos := aScan(aCampos,{|x| allTrim(x[1]) == "E1_VALOR"}),   iIf(nPos > 0, aCampos[nPos,2], "") } )

	cSerieNFS    := cPrefixo + Space(nTamSerie - len(cPrefixo))
	cItem        := strZero(0, len(SD2->D2_ITEM))

	//Posiciona no cliente...
	if cCliefor <> SA1->A1_COD   

		SA1->( dbSetOrder(1) )
		if ! SA1->(MsSeek(xFilial("SA1") + cCliefor + cLoja))
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "SA1 - nao encontrado plstose1" , 0, 0, {})
		endIf

	endIf

	if empty(__cCondPag)
		If !plCodPag()
			FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "SE4 - nao encontrado plstose1" , 0, 0, {})

		Endif
	endIf	 

	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_FILIAL"})]  	:= xFilial("SD2")
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_TIPO"})]    	:= "N"
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_DOC"})]     	:= cDoc
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_EMISSAO"})] 	:= dDatEmis
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_CLIENT"})]  	:= cClieFor
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_CLIENTE"})]  	:= cClieFor
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_LOJA"})]  	:= cLoja
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_LOJENT"})]  	:= cLoja
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_ESPECIE"})] 	:= A460Especie(cPrefixo)
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_COND"})]      := __cCondPag
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_DTDIGIT"})] 	:= dDataBase
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_EST"})]     	:= SA1->A1_EST
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_FORMUL"})]  	:= "S"
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_SERIE"})]  	:= cSerieNFS
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_VALMERC"})]  	:= nValor
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_VALBRUT"})]  	:= nValor

	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_TIPOCLI"})] 	:= SA1->A1_TIPO
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_HORA"})]    	:= subStr(time(),1,5)
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_TIPODOC"})] 	:= "01"
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_MOEDA"})]  	:= 1
	aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_TXMOEDA"})] 	:= 1
	
	if SF2->(fieldPos("F2_XPERIOD")) > 0
		aSF2[aScan(aStruSF2,{|x| allTrim(x[1]) == "F2_XPERIOD"})] := strZero(nPeriod,2)
	endIf	

	//Esta ordenacao se faz necessaria para lancamento de credito ao debito  
	//Somente se existir lancamento de Debito								   
	aVlrCob := aSort(aVlrCob,,, { |x, y| x[1] > y[1] } )

	//Inicia o processo de aglutinacao e montagem da matriz para criacao do SD2 
	For nFor := 1 To Len(aVlrCob)
		
        lCredito := ( aVlrCob[nFor,1] == '2' )		
		
        //Esta aglutinacao se refere somente a procura de um Credito para um Debito  
		If lCredito
			aRetFind := PLSCRTODE(aVlrCob,aVlrCob[nFor],Iif(nPeriod > 0,.T.,.F.))
			If aRetFind[1] <> 0
				AaDd( aRetDes, aRetFind  )
				Loop
			EndIf	
			aVlrCob[nFor,40] := aVlrCob[nFor,2]
		EndIf
		
        //Aglutina os Creditos e depois os Debitos								   
		PLAGLUSD2(aItemOri,aVlrCob[nFor],lNCC,aSD2_BM1,aRetDes,aDocOri,@cItem,aStruSD2,;
					  aCampos,cPrefixo,cClieFor,cLoja,dDatEmis,lGerNFBRA,SA1->A1_EST)
	Next                                        

	//Inclui os lancamentos de Creditos ja aglutinados com os lancamentos de Debito
	For	nFor:=1 To Len(aItemOriC)
		AaDd(aItemOri,aItemOriC[nFor])
	Next              
	aItemOriC := NIL
	//Base																	   
	If cPaisLOC == "URU"
		aEval( aItemOri,{|x| ( x[nPBasImp1] := ( x[nPTotal] - x[nPDesconto] ) ), nBasImp1 += x[nPBasImp1] } )
	EndIf
	//P.E criado para alteração dos campos na SE2 antes da integração com SIGAFAT																	   
	If ExistBlock("PLSITEMO")
	   aItemOri := ExecBlock("PLSITEMO",.F.,.F.,{aItemOri,aBases,aStruSD2})
	Endif
	
	//SF2	
	cTextoSF2  += ' MaFisAlt("NF_NATUREZA" , cNatureza, , , , , , .f. /*lRecal*/) '
	bFiscalSF2 := &( '{||' + cTextoSF2 + '}' )
	
	cNumNFS	:= MaNfs2Nfs(cSerOri,;
						cNumORI,;
						cClieFor,;
						cLoja,;
						cSerieNFS,;
						lMostraCtb,;
						lAglutCtb,;
						lCtbOnLine,;
						lCtbCusto,;
						lReajusta,;
						nCalAcrs,;
						nArredPrcLis,;
						lAtuSA7,;
						lECF,;
						bFilSD2,;
						bSD2,;
						bSF2,;
						bTTS,;
						aDocOri,;
						aItemOri,;
						aSF2,;
						lNoFiscal,;
						bFiscalSF2,;
						bFiscalSD2,;
						bFatSE1,;
						cNumero)

	if ! SE1->( eof() )

		//Salva posicao SE1                                                          
		nRecSe1 := SE1->( recno() )

		SE1->(dbSetorder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
		SF2->(dbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
		SD2->(dbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		if SE1->(mSseek(Xfilial("SE1") + cClieFor + cLoja + cSerieNFS + cNumero ) )
			
			// Situação onde o imposto não é cobrado na geração da Nota Fiscal (MATA461)
			If lGerNFBRA .And. Empty(SE1->E1_NATUREZ) .And. GetNewPar("MV_1DUPNAT", "") <> "SA1->A1_NATUREZ"
				lCalcImpostNF := .T.
			EndIf
		
			while ! SE1->( eof() ) .and. alltrim( SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM ) ) == alltrim( cClieFor + cLoja + cSerieNFS + cNumero )
		
				SE1->( reclock("SE1", .f.) )

					for nFor := 1 to len(aCampos)

						if aCampos[nFor, 1] $ cCampos
							&('SE1->' + aCampos[nFor, 1]) := aCampos[nFor, 2]					
						endIf	

					next

				SE1->(msUnLock())	
				
				//Atualiza campos do BM1 com dados do SD2 e SF2                              
				if SF2->( msSeek( xFilial("SF2") + SE1->(E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA) ) )

					for nFor := 1 to len(aSD2_BM1)
				
						if SD2->( msSeek( xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + aSD2_BM1[nFor,3] + aSD2_BM1[nFor,1] ) )  )
					
							for nX := 1 to len(aSD2_BM1[nFor,2])					
				
								BM1->( dbGoto(aSD2_BM1[nFor,2,nX]) )
				
								if ! BM1->( eof() ) 
									
									BM1->(recLock("BM1",.f.))
										BM1->BM1_DOCSF2 := SF2->F2_DOC
										BM1->BM1_SERSF2 := SF2->F2_SERIE
										BM1->BM1_ITESD2 := SD2->D2_ITEM
										BM1->BM1_SEQSD2 := SD2->D2_NUMSEQ
									BM1->(msUnLock())                    

								else 
									FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "BM1 - recno nao encontrado - aSD2_BM1[nFor,2,nX] (PLSTOSE1)" , 0, 0, {})
								endIf	

							next

						endIf

					next

				else

					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "SF2 NAO ENCONTRADO" , 0, 0, {})
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "SE1       -> ["+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)+"]" , 0, 0, {})
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "VARIAVEIS -> ["+cNumero+cSerieNFS+cClieFor+cLoja+"]" , 0, 0, {})
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "cNumNFS   -> ["+cNumNFS+"]" , 0, 0, {})

				endIf

				SE1->( dbSkip() )
			Enddo	

		Else
		
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "SE1 EM EOF" , 0, 0, {})
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "VARIAVEIS -> ["+cNumero+"-"+cSerieNFS+"-"+cClieFor+"-"+cLoja+"]" , 0, 0, {})

		EndIf
			
	endIf		

endIf

//Calcula impostos                                                           
if ! lErro .and. nRecSe1 > 0

	SE1->( dbGoto(nRecSe1) ) 

	If lCalcImpostNF
		If SF2->(MsSeek(xFilial("SF2")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)))

			PLCalcImpNF(aBases, cOrigem)

		EndIf
	Endif

	PLSLOGFAT("DADOS DA NOTA/TITULO GERADO", 1, .f.)
		
	//verifica se tem titulo a ser compensado ncc com saldo restante anterior ou a criada neste momento.
	if BG9->(fieldPos("BG9_COMAUT")) > 0
		
		aCliente := PLS770NIV(BA3->BA3_CODINT, BA3->BA3_CODEMP, BA3->BA3_MATRIC, iIf(BA3->BA3_TIPOUS == "1", "F", "J"),;
							BA3->BA3_CONEMP, BA3->BA3_VERCON, BA3->BA3_SUBCON, BA3->BA3_VERSUB, 1)
		
		cNivel := aCliente[1][18] 
			
		// Empresa
		if cNivel == "1" 
			
			BG9->(dbSetOrder(1))
			BG9->(msSeek(xFilial("BA3") + BA3->BA3_CODINT+BA3->BA3_CODEMP))
				
			lBXComp := ( BG9->BG9_COMAUT == "1" )
			
			//Nivel contrato
		ElseIf cNivel == "2" 
				
			BT5->(dbSetOrder(1))
			BT5->(msSeek(xFilial("BA3") + BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON))
			lBXComp := ( BT5->BT5_COMAUT == "1" )
			
			//Nivel subcontrato
		ElseIf cNivel == "3"  
				
			BQC->(dbSetOrder(1))
			BQC->(msSeek(xFilial("BA3") + BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB))
			lBXComp := ( BQC->BQC_COMAUT == "1" )

			//Nivel familia
		ElseIf cNivel == "4" 

			lBXComp := ( BA3->BA3_COMAUT == "1" )

		EndIf

		if lBXComp
			lComp := PLTITBXCR() 
		EndIf	

	Endif	
	
endIf

SE1->( dbGoto(nRecSe1) ) 

//Chama ponto de entrada para usuario poder atualizar campos no SE1          
if  existBlock("PLSE1GRV") 

    if ! lGerNFBRA .or. ( lGerNFBRA .And. ! SF2->( eof() ) )
		    
		execBlock("PLSE1GRV",.f.,.f.,{ lComp, nRecSe1, aBases } )
		
		SE1->( dbGoto(nRecSe1) )
		
	    PLSLOGFAT("PLSE1GRV",1,.f.)

	endIf

endIf

if lTitDesc .and. type("M->BE1_QUACOB") == "C" .And. M->BE1_QUACOB == "1"
   lPgtAto := .t.
endIf

//Verifica se o desconto do plano deve ser feito na producao medica,         
//para o caso dos medicos/secretarias que tem plano de saude                 
if  BA3->(fieldPos("BA3_CODRDA")) > 0 .and. ! lPgtAto .And. ! empty(BA3->BA3_CODRDA) .and.;
	( ( lCusOpe .and. '2' $ getNewPar("MV_PLSMDCB","1,2") ) .or.; 	// Autorizado desconto do custo.
	  ( ! lCusOpe .and. '1' $ getNewPar("MV_PLSMDCB","1,2") ) )	 	// Autorizado desconto de tudo.

	cCodLanCredito := GetLancDebFamilia()
	cCodLanDebito := GetLancCredFamilia()
		
	// Verifica qual lançamento será utilizado
	If IsInCallStack("PL99BProRt") .And. lNCC // Lançamento de Credito (Pro-Rata) - Cancelamento RN412
		cCodLancamento := cCodLanCredito
	Else	
		cCodLancamento := cCodLanDebito
	EndIf
	
	BAU->(dbSetOrder(1))
	if !Empty(cCodLancamento) .And. BAU->(msSeek(xFilial("BAU")+BA3->BA3_CODRDA))
			
		//Inicializa variaveis                                                       
		cNumTit   	:= SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA
		dBaixa    	:= SE1->E1_EMISSAO
		cTipo     	:= SE1->E1_TIPO
		cNsNum    	:= " "
		dDataCred 	:= SE1->E1_EMISSAO
		nDespes   	:= 0
		nDescont  	:= 0
		nValRec   	:= SE1->E1_SALDO
		nJuros    	:= 0
		nMulta    	:= 0
		nCM       	:= 0
		nAcresc   	:= 0
		nDescresc 	:= 0
		nTotAbat  	:= 0
		cLoteFin  	:= ""
		cMarca    	:= ""
		cMotBx    	:= "DAC"
		cHist070  	:= ""
		cBanco    	:= ""
		cAgencia  	:= ""
		cConta    	:= ""
		nValEstrang := 0
			
        //Baixa titulo por cancelamento no Contas a Receber                                           
		fA070Grv(lContabiliza, .f., lContabiliza, cNsNum, .f., SE1->E1_EMISSAO, .f., "", "")

		//Se o saldo for zerado, atualizo o status da Guia
		if SE1->E1_SALDO == 0
			PLSTitStat()
		endIf

		//Esse item se faz necessario devido que estamos no meio da geração dos titulos de debito e credito vindo no While do PLSA627.
		//Precisamos abater do BGQ os debitos dos creditos para que não ocorra lançamentos indevidos.
		//A ideia é que se ja temos o lançameto ja criado na BGQ efetuamos somente o debito ou credito no valor liquido
		cSql := " SELECT BGQ_VALOR, BGQ_VALOR FROM " + retSqlName("BGQ")
		cSql += " WHERE BGQ_FILIAL = '"+xFilial("BGQ")+"' "
		cSql += " AND BGQ_CODOPE = '"+BA3->BA3_CODINT+"' "
		cSql += " AND BGQ_CODIGO = '"+BA3->BA3_CODRDA+"' "
		cSql += " AND BGQ_ANO = '"+cAnoref+"' "
		cSql += " AND BGQ_MES = '"+cMesRef+"' "
		cSql += " AND BGQ_PREFIX = '"+SE1->E1_PREFIXO+"' "
		cSql += " AND BGQ_NUMTIT = '"+SE1->E1_NUM+"' "
		cSql += " AND BGQ_PARCEL = '"+SE1->E1_PARCELA+"' "
		cSql += " AND D_E_L_E_T_ = ' ' "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB",.T.,.F.)
		If !TRB->(Eof())
			lNewRec := .F.
			nValorBGQ := Abs(If(lNCC, TRB->BGQ_VALOR-SE1->E1_VALLIQ, TRB->BGQ_VALOR+SE1->E1_VALLIQ))

			If lNCC .And. TRB->BGQ_VALOR < SE1->E1_VALLIQ
				cCodLancamento := cCodLanCredito
			EndIF
		Else
			nValorBGQ := SE1->E1_VALLIQ		
		Endif

		TRB->( dbCloseArea())

		//Posiciona BBB-Tipo Lancamento Debito/Credito                        
		If BBB->BBB_CODSER <> cCodLancamento
			BBB->(dbSetOrder(1))
			BBB->(msSeek(xFilial("BBB")+cCodLancamento))
		EndIf

		// Grava BGQ-Deb/Cred Mensal com o valor do titulo                     
		BGQ->(recLock("BGQ",lNewRec))
		BGQ->BGQ_FILIAL := xFilial("BGQ")
		BGQ->BGQ_CODSEQ := getSx8Num("BGQ","BGQ_CODSEQ")
		BGQ->BGQ_CODIGO := BA3->BA3_CODRDA
		BGQ->BGQ_NOME   := BAU->BAU_NOME
		BGQ->BGQ_ANO    := cAnoref
		BGQ->BGQ_MES    := cMesRef
		BGQ->BGQ_CODLAN := BBB->BBB_CODSER
		BGQ->BGQ_VALOR  := nValorBGQ
		BGQ->BGQ_TIPO   := BBB->BBB_TIPSER
		BGQ->BGQ_TIPOCT := BBB->BBB_TIPOCT
		BGQ->BGQ_INCIR  := BBB->BBB_INCIR
		BGQ->BGQ_INCINS := BBB->BBB_INCINS
		BGQ->BGQ_INCPIS := BBB->BBB_INCPIS
		BGQ->BGQ_INCCOF := BBB->BBB_INCCOF
		BGQ->BGQ_INCCSL := BBB->BBB_INCCSL
		BGQ->BGQ_VERBA  := BBB->BBB_VERBA
		BGQ->BGQ_CODOPE := plsIntPad()
		BGQ->BGQ_CONMFT := BBB->BBB_CONMFT
		BGQ->BGQ_OBS    := STR0001 //"GERADO PELA ROTINA DE LOTE DE COBRANCA"
		BGQ->BGQ_LANAUT := "1"
		BGQ->BGQ_OPELAU := SE1->E1_CODINT
		BGQ->BGQ_PREFIX := SE1->E1_PREFIXO
		BGQ->BGQ_NUMTIT := SE1->E1_NUM
		BGQ->BGQ_PARCEL := SE1->E1_PARCELA
		BGQ->BGQ_TIPTIT := iif(lNewRec,SE1->E1_TIPO,BGQ->BGQ_TIPTIT)
		BGQ->BGQ_INTERC := "0"
		BGQ->(msUnLock())

		confirmSx8()
			
        //Chama ponto de entrada para usuario poder atualizar campos no BGQ          
		if  existBlock("PLBGQGRV")
			execBlock("PLBGQGRV",.f.,.f.)
		endIf

	endIf

	PLSLOGFAT("COMPLEMENTOS APOS GRAVACAO DO TITULO/NF",1,.f.)
	
endIf

restArea(aArea)

//Posiciona no SE1 gerado                                                    
if lPosSE1Ger	
	SE1->( dbGoto(nRecSe1) )                
endIf

return(lErro)

/*/{Protheus.doc} plCodPag
retorna condicao de pagamento avista	

@author  PLS TEAM
@version P12
@since   29/04/10
/*/
static function plCodPag
local cCondPag := ''
local cCondAux := ''
local lRet	   := .F.

// tratamento para condição de pagamento
SE4->(dbSetOrder(1))
SE4->(dbGoTop())
SE4->(DBSeek(xFilial("SE4")))

while ! SE4->(eof()) .And. xFilial("SE4") == SE4->E4_FILIAL

	cCondAux := SE4->E4_CODIGO

	if allTrim(SE4->E4_COND) == '0' .And. !Empty(SE4->E4_CODIGO) .And. SE4->E4_TIPO == '1'
		cCondPag := SE4->E4_CODIGO
		lRet:= .T.
		exit
	endIf

SE4->(dbSkip())
endDo   

if empty(cCondPag)
	
	cCondPag := soma1(cCondAux)

	SE4->(recLock("SE4",.t.))
		SE4->E4_FILIAL := xFilial("SE4")
		SE4->E4_CODIGO := cCondPag
		SE4->E4_TIPO   := "1"
		SE4->E4_COND   := "0"
		SE4->E4_DESCRI := "AVISTA"
	SE4->(msUnLock())

endIf

__cCondPag := cCondPag

return(lRet)

/*/{Protheus.doc} PLAGLUSD2
Aglutina itens para o sd2 nf	

@author  PLS TEAM
@version P12
@since   29/04/10
/*/

Function PLAGLUSD2(aMatSD2,aVlrCob,lNCC,aSD2_BM1,aRetDes,aDocOri,cItem,aStruSD2,;
					aCampos,cPrefixo,cClieFor,cLoja,dDatEmis,lGerNFBRA,cEstado)
LOCAL nI		:= 0
LOCAL nX		:= 0
LOCAL _nPos 	:= 0
LOCAL nPosD		:= 0                                                                                    
LOCAL nPos		:= 0
LOCAL nValorItem:= 0
LOCAL nAnaAglu	:= 0                                                  
LOCAL nIteNota	:= 0
LOCAL bAglut	:= ""
LOCAL cCodProSB1:= ""
LOCAL cCodTES	:= ""
LOCAL lCredito	:= .F.
LOCAL lAglutina := Iif(cPaisLOC != "BRA",.T., ((BQC->(FieldPos("BQC_AGLUT")) > 0 .And. BQC->BQC_AGLUT == "1").OR.(BA3->BA3_COBNIV=='1'.And.BA3->(FieldPos("BA3_AGLUT")) > 0 .And. BA3->BA3_AGLUT == "1")))
LOCAL nPFilial  := aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_FILIAL"})
LOCAL nPItem    := aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ITEM"})
LOCAL nPCod 	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_COD"})
LOCAL nPPrcVen	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRCVEN"})
LOCAL nPTES		:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TES"})
LOCAL nPQuant   := aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_QUANT"})
LOCAL nPTotal	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TOTAL"})
LOCAL nPUM		:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_UM"})
LOCAL nPCliente	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CLIENTE"})
LOCAL nPLoja	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOJA"})
LOCAL nPEmis	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_EMISSAO"})
LOCAL nPTipo	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TIPO"})
LOCAL nPEspecie	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ESPECIE"})
LOCAL nPTipoDOC	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TIPODOC"})
LOCAL nPDesconto:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DESCON"})
LOCAL nPDesc	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DESC"})
LOCAL nPLocal	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOCAL"})
LOCAL nPGrupo	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_GRUPO"})
LOCAL nPTP		:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TP"})
LOCAL nPPrUnit	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRUNIT"})
LOCAL nPDtDigi	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DTDIGIT"})
LOCAL nPFormul	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_FORMUL"})
LOCAL nPValBrut	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALBRUT"})
LOCAL nPDescrip	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DESCRIP"})
LOCAL nPBasImp1	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASIMP1"})
LOCAL nCodInt	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CODINT"})
LOCAL nCodEmp	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CODEMP"})
LOCAL nConEmp	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CONEMP"})
LOCAL nVerCon	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VERCON"})
LOCAL nSubCon	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SUBCON"})
LOCAL nVerSub	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VERSUB"})
LOCAL nConta	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CONTA"})
LOCAL nLocal	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOCAL"})
LOCAL nGrupo	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_GRUPO"})
LOCAL nCodISS	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CODISS"})
LOCAL nBasIRR	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASEIRR"})
LOCAL nPEstado	:= aScan(aStruSD2,{|x| AllTrim(x[1]) == "D2_EST"})
LOCAL cCodInt   := Eval({ || nPos := ascan(aCampos,{|x| x[1] == 'E1_CODINT'}), If(nPos>0,aCampos[nPos,2],"") })
LOCAL cCodEmp   := Eval({ || nPos := ascan(aCampos,{|x| x[1] == 'E1_CODEMP'}), If(nPos>0,aCampos[nPos,2],"") })
LOCAL cConEmp   := Eval({ || nPos := ascan(aCampos,{|x| x[1] == 'E1_CONEMP'}), If(nPos>0,aCampos[nPos,2],"") })
LOCAL cVerCon   := Eval({ || nPos := ascan(aCampos,{|x| x[1] == 'E1_VERCON'}), If(nPos>0,aCampos[nPos,2],"") })
LOCAL cSubCon   := Eval({ || nPos := ascan(aCampos,{|x| x[1] == 'E1_SUBCON'}), If(nPos>0,aCampos[nPos,2],"") })
LOCAL cVerSub   := Eval({ || nPos := ascan(aCampos,{|x| x[1] == 'E1_VERSUB'}), If(nPos>0,aCampos[nPos,2],"") })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for lancamento de credito e o MV_PLGENCC for 0						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lCredito := ( aVlrCob[1] == '2' ) .And. ( GetNewPar("MV_PLGENCC","0") <> "1" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valores																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValorItem 	:= aVlrCob[2]
cCodProSB1 	:= aVlrCob[37]
cCodTES    	:= aVlrCob[38]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Neste ponto esta funcao esta aglutinando os lancamentos da nota		   ³
//³ Aqui os itens da nota ja estao definidos (nao tem lancamento de debito)³
//³ exceto se o parametro MV_PLGENCC for igual a "0"					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
bAglut := PLSRETAGL(aVlrCob,'aMatSD2','cCodProSB1','cCodTES','nValorItem',,;
					'nPPrcVen','nPTES','nPCod',,aStruSD2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o bloco de codigo para aglutinacao.								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAnaAglu := Eval(&bAglut)                                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aglutina ou gera um novo registro										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAglutina .And. nAnaAglu > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aglutina valores														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMatSD2[nAnaAglu][nPQuant]   	+= 1
	aMatSD2[nAnaAglu][nPTotal] 		+= Iif( aVlrCob[1] == "1" .Or. lNCC,aVlrCob[2],-aVlrCob[2] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recalcula o Preco Unitario de acordo com Quantidade e Total.			   ³
	//³ Utiliza função de arredondamento que trata o parâmetro MV_ARREFAT para a   ³
	//³ gravacao da tabela SD2											       	   ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	aMatSD2[nAnaAglu][nPPrcVen] 	:= A410Arred(aMatSD2[nAnaAglu][nPTotal]/aMatSD2[nAnaAglu][nPQuant],"D2_PRCVEN")   
	aMatSD2[nAnaAglu][nPDesconto]	+= Iif( Len(aVlrCob)>39,aVlrCob[40],0 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Iniciar pesquisa de relacionamento sd2 com bm1							   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nPos := Ascan( aSD2_BM1 , {|x| x[1] == aMatSD2[nAnaAglu,nPItem]} )
	If _nPos > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Relacionamento do debito com SD2										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AaDd( aSD2_BM1[_nPos,2],aVlrCob[39] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Relacionamento do credito com SD2										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While ( nPosD := Ascan( aRetDes,{ |x| x[1] == aVlrCob[39] }, (nPosD+1) ) ) > 0
			AaDd( aSD2_BM1[_nPos,2],aRetDes[nPosD,2] )
			aRetDes[nPosD,1] := 0
		EndDo
	EndIf
Else
	cItem := Soma1(cItem)
	AaDd( aDocOri, 0 )
	AaDd( aMatSD2,{} )
	nIteNota := Len(aMatSD2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza campos															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aStruSD2)
		If aStruSD2[nX][2]$"C/M"
			AaDd(aMatSD2[nIteNota],"")
		ElseIf aStruSD2[nX][2]=="D"
			AaDd(aMatSD2[nIteNota],CToD(""))
		ElseIf aStruSD2[nX][2]=="N"
			AaDd(aMatSD2[nIteNota],0)
		ElseIf aStruSD2[nX][2]=="L"
			AaDd(aMatSD2[nIteNota],.T.)
		EndIf
	Next nX
	
	If !SB1->( DbSeek(xFilial("SB1")+aVlrCob[37]) )
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "SB1 - nao encontrado plstose1" , 0, 0, {})
	EndIf
	
	aMatSD2[nIteNota][nPFilial]		:= xFilial("SD2")
	aMatSD2[nIteNota][nPItem]		:= cItem
	aMatSD2[nIteNota][nPCod]		:= aVlrCob[37]
	aMatSD2[nIteNota][nPQuant]		:= 1
	

	aMatSD2[nIteNota][nPPrcVen]		:= Iif( aVlrCob[1] == "1" .Or. lNCC,aVlrCob[2],-aVlrCob[2] )
	aMatSD2[nIteNota][nPPrUnit]		:= aMatSD2[nIteNota][nPPrcVen]
	aMatSD2[nIteNota][nPDesconto]	:= Iif( Len(aVlrCob)>39 ,aVlrCob[40], 0)
	
	aMatSD2[nIteNota][nPTotal]		:= aMatSD2[nIteNota][nPPrcVen]
	aMatSD2[nIteNota][nPTES]		:= aVlrCob[38]
	aMatSD2[nIteNota][nPUM]			:= SB1->B1_UM
	aMatSD2[nIteNota][nConta]		:= SB1->B1_CONTA
	aMatSD2[nIteNota][nLocal]		:= SB1->B1_LOCPAD
	aMatSD2[nIteNota][nGrupo]		:= SB1->B1_GRUPO
	aMatSD2[nIteNota][nCodISS]		:= SB1->B1_CODISS
	aMatSD2[nIteNota][nPCliente]	:= cClieFor
	aMatSD2[nIteNota][nPLoja]   	:= cLoja
	aMatSD2[nIteNota][nPEmis]   	:= dDatEmis
	aMatSD2[nIteNota][nPEstado]   	:= cEstado
	aMatSD2[nIteNota][nPTipo]   	:= "N"
    If nCodInt>0 .And. nCodEmp>0 .And. nConEmp>0 .And. nVerCon>0 .And.nSubCon>0 .And. nVerSub>0 
	   aMatSD2[nIteNota][nCodInt]   	:= cCodInt
	   aMatSD2[nIteNota][nCodEmp]   	:= cCodEmp
	   aMatSD2[nIteNota][nConEmp]   	:= cConEmp
	   aMatSD2[nIteNota][nVerCon]   	:= cVerCon
	   aMatSD2[nIteNota][nSubCon]   	:= cSubCon
	   aMatSD2[nIteNota][nVerSub]   	:= cVerSub
	Endif
	aMatSD2[nIteNota][nPTipoDoc]	:= "01"
	aMatSD2[nIteNota][nPDtDigi]		:= dDataBase
	aMatSD2[nIteNota][nPFormul]		:= "S"
	
	If lGerNFBRA .And. nPEspecie > 0
		aMatSD2[nIteNota][nPEspecie]	:= A460Especie(cPrefixo)
	EndIf
	If nPDescrip > 0
		aMatSD2[nIteNota][nPDescrip]	:= SB1->B1_DESC
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao de novos campos no SD2 com base no ponto de entrada PL627AGL	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ExistBlock("PL627AGL") .And. Len(aVlrCob) > 63 .And. Len(aVlrCob[64]) > 0
		aAuxAGL	:= aVlrCob[64]
		For nI:=1 To Len(aAuxAGL)
			If (nPosAGL := aScan( aStruSD2,{|x| AllTrim(x[1]) == AllTrim(aAuxAGL[nI,2]) } ) ) > 0
				aMatSD2[nIteNota,nPosAGL] := aAuxAGL[nI,1]
			Endif
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ LOG																		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PLSLOGFAT("PL627AGL",1,.F.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Relacionamento do debito com SD2										   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AaDd(aSD2_BM1,{cItem,{aVlrCob[39]},aVlrCob[37]})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Relacionamento do credito com SD2										   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ( nPosD := Ascan( aRetDes,{ |x| x[1] == aVlrCob[39] }, (nPosD+1) ) ) > 0
		AaDd( aSD2_BM1[Len(aSD2_BM1),2],aRetDes[nPosD,2] )
		aRetDes[nPosD,1] := 0
	EndDo
	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Funcao															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/{Protheus.doc} PLTITBXCR

Baixa/Estorno titulo NCC 
@author  PLSTEAM
@version P12
@since   04/08/19
/*/
function PLTITBXCR(lEstorno,lExcluir) 
local lRet := .f.
local __lOracle := .f.	
local cSql := ""
local nSaldo := 0
local aRecTIT := {}
local aRecNCC := {}
local aParam := { .f., .f., .f., .f., .f., .f. }
local aRetorno := {}
local aRecSE1 := {}
local aEstorno := {}
local i:=0
local aRecBkp :={}

local nRotina	

default lEstorno := .f.
default lExcluir := .f.

private lMsErroAuto 	:= .f.
private lMsHelpAuto		:= .t.
private lAutoErrNofile	:= .t.

getTpDB(@__lOracle)

if ! lEstorno 

	cSql := " SELECT SE1.R_E_C_N_O_ SE1REC, E1_TIPO, E1_SALDO "
	cSql += "   FROM " + retSqlName("SE1") + " SE1 "
	cSql += "  WHERE SE1.E1_FILIAL  = '" + xFilial('SE1')  + "' " 
	cSql += "    AND SE1.E1_CLIENTE = '" + SE1->E1_CLIENTE + "' "
	cSql += "    AND SE1.E1_LOJA    = '" + SE1->E1_LOJA    + "' "
	cSql += "    AND SE1.E1_PREFIXO = '" + SE1->E1_PREFIXO + "' "
	cSql += "    AND SE1.E1_CODINT  = '" + SE1->E1_CODINT  + "' "
	cSql += "    AND SE1.E1_CODEMP  = '" + SE1->E1_CODEMP  + "' "
	cSql += "    AND SE1.E1_SITUACA NOT IN " + formatIn( strTran( FN022LSTCB(2), '', ' ' ) , '|') //Lista das situacoes de cobranca (EM PROTESTO)

	if __lOracle
		cSql += " AND TRIM(E1_TITPAI) IS NULL "
		cSql += " AND SE1.E1_ANOBASE || SE1.E1_MESBASE <= '" + SE1->(E1_ANOBASE+E1_MESBASE) + "' "
	else
		cSql += " AND E1_TITPAI = ' ' "
		cSql += " AND SE1.E1_ANOBASE + SE1.E1_MESBASE <= '" + SE1->(E1_ANOBASE+E1_MESBASE) + "' "
	endIf	

	cSql += "    AND SE1.E1_SALDO > 0 "
	cSql += "    AND SE1.D_E_L_E_T_ = ' ' "

	cSql += "   AND EXISTS (SELECT 1 "
	cSql += "   		      FROM " + retSqlName("SE1") + " NCC "
	cSql += "   	  	     WHERE NCC.E1_FILIAL  = '" + xFilial('SE1')  + "' " 
	cSql += "   		       AND NCC.E1_CLIENTE = '" + SE1->E1_CLIENTE + "' "
	cSql += "   		       AND NCC.E1_LOJA    = '" + SE1->E1_LOJA    + "' "
	cSql += "   		       AND NCC.E1_PREFIXO = '" + SE1->E1_PREFIXO + "' "
	cSql += "   		       AND NCC.E1_TIPO	  = '" + MV_CRNEG + "' "
	if __lOracle
		cSql += "              AND NCC.E1_ANOBASE || NCC.E1_MESBASE >= '" + SE1->(E1_ANOBASE+E1_MESBASE) + "' "
	else
		cSql += "              AND NCC.E1_ANOBASE + NCC.E1_MESBASE  >= '" + SE1->(E1_ANOBASE+E1_MESBASE) + "' "
	endIf	
	cSql += "   		       AND NCC.E1_SALDO > 0 "
	cSql += "   		       AND NCC.D_E_L_E_T_ = ' ') "  

	if existBlock('PLRDBXCR')
		cSql := execBlock('PLRDBXCR', .f., .f., { cSql } )	
	endIf

	MPSysOpenQuery(cSql, "TRBSE1")

	while ! TRBSE1->(eof())
		
		if TRBSE1->E1_TIPO == MV_CRNEG
			aadd(aRecNCC, TRBSE1->SE1REC)
		else
			
			aadd(aRecTIT, TRBSE1->SE1REC)

			nSaldo += TRBSE1->E1_SALDO

		endIf	

	TRBSE1->(dbSkip())
	endDo

	TRBSE1->(dbClosearea())

	if len(aRecNCC) > 0 .and. len(aRecTIT) > 0
		lRet := maIntBxCR( 3, aRecTIT, /*aBaixa*/, aRecNCC, /*aLiquidacao*/, aParam,;
						/*bBlock*/,/*aEstorno*/,/*aSE1Dados*/,/*aNewSE1*/, nSaldo, /*aCpoUser*/,;
						/*aNCC_RAvlr*/, /*nSomaCheq*/, /*nTaxaCM*/, /*aTxMoeda*/, /*lConsdAbat*/, /*lRetLoja*/,;
						/*cProcComp*/ )

		if lRet .And. lHabMetric .and. lLibSupFw .and. lVrsAppSw 
			FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_utilizacao-de-ncc_total", 1 }} )
		endif
	endIf

else

	nRecSE1 := SE1->(recno())

	lRet := .t.

	nRotina := IIF(lExcluir, 4, 5)
	//Fina330 - 4 - Excluir/5 - Estorno, .T. - Automatico
	
	If nRotina == 4
		if exc9NXtit()
			MSExecAuto({|x, y| Fina330(x, y)}, nRotina, .t.)
		endif
		if lMsErroAuto
			mostraErro()
			lRet := .f.
		endIf

	Else
		aRetorno := RecnoTitComp(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA)		
		If Len(aRetorno) > 0
			aRecSE1 := aRetorno[1]
			aEstorno := aRetorno[2]

			For  i:=1 to Len(aRecSE1)
				
				//Esse item se faz necessario para  quando ter 1 titulo principal e varios creditos e debitos.
				// a função maIntBxCR só aceita titulo a titulo.
				aRecBkp:={}
				aadd(aRecBkp, aRecSE1[i])
				lRet := maIntBxCR( 3, aRecBkp,,,, {.T.,.F.,.F.,.F.,.F.,.F.},, aEstorno[i])

				if lRet .And. lHabMetric .and. lLibSupFw .and. lVrsAppSw 
					FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_utilizacao-de-ncc_total", 1 }} )
				endif
			Next i	
		EndIf
	EndIf

	SE1->(msGoTo(nRecSE1))

endIf	

return lRet


/*/{Protheus.doc} PLSCRTODE

Procura lancamento de Credito para um Debito
@author  PLSTEAM
@version P12
@since   01/01/2010
/*/
Function PLSCRTODE(aVlrCob,aDes,lPeriod)
LOCAL nY 	  := 0
LOCAL nP	  := 0
LOCAL nPos	  := 0
LOCAL nReDBM1 := 0
LOCAL bChkPos := ""
LOCAL nValor  := aDes[2]
LOCAL cCodEve := aDes[4]
LOCAL cMatric := aDes[7]
LOCAL cCodPla := aDes[34]
LOCAL cProdut := aDes[37]
LOCAL cTes 	  := aDes[38]
LOCAL nReCBM1 := aDes[39] //Recno BM1
LOCAL aAuxAGL := aDes[64] //Novos campos para checagem Deb/Cred PL627AGL
LOCAL cAno    := aDes[59]
LOCAL cMes    := aDes[60]
LOCAL lBusca  := .T.
Local lfirst 	:= .F. 
DEFAULT lPeriod := .F.

// CodeBlock de checagem Default	
bChkPos := " {|| Ascan( aVlrCob,{ |x| x[1] == '1'     .And. "
If !Empty(cMatric)
	bChkPos += 						" x[7] == cMatric .And. "
EndIf	
If lPeriod
	bChkPos += 						" x[59] == cAno .And. "
	bChkPos += 						" x[60] == cMes .And. "
EndIf	
bChkPos += 							" x[37] == cProdut .And. "
bChkPos += 							" x[38] == cTes "

// Se considera ou nao o valor liquido na regra de aglutinacao
If GetNewPar("MV_PLSVLDI","0") == "1"
	bChkPos += " .And. ( abs(x[2])-abs(x[40]) ) >= abs(nValor) "
EndIf	

// Inclui os campos referente ao PL627AGL
For nY := 1 to Len(aAuxAGL)
	// Somente os validos para checagem
	If aAuxAGL[nY,3] 
		If ValType(aAuxAGL[nY,1]) == "C"          
			bChkPos     += " .And. x[64," + cValToChar(nY) + ",1] == '" + aAuxAGL[nY,1] +  "' "
		ElseIf ValType(aAuxAGL[nY,1]) == "N"
			bChkPos     += " .And. abs(x[64," + cValToChar(nY) + ",1]) == abs(" + cValToChar(aAuxAGL[nY,1]) +  ") "
		ElseIf ValType(aAuxAGL[nY,1]) == "D"
			bChkPos     += " .And. DTOS(x[64," + cValToChar(nY) + ",1]) == '" + DTOS(aAuxAGL[nY,1]) +  "' "
		EndIf
	EndIf
Next                                            		

// Fechamento do CodeBlock			
bChkPos += "}) }"

// While para procura do debito referente a um credito
// O nivel mais alto e o debito propriamente dito

While .T.                                                      
	
	
	// Executa codeblock				
	nPos := Eval(&bChkPos)

	// Se achou atualiza o desconto e pega o recno do bm1 correspondente
	If nPos > 0  
		If nValor > aVlrCob[nPos,2]
			aVlrCob[nPos,40] += aVlrCob[nPos,2]
			nValor-= aVlrCob[nPos,2]     
		    If !lfirst 
				nP := rAt('}) }',Upper(bChkPos))-1
		    	If nP > -1
					bChkPos := SubStr(bChkPos,1,nP) + " .And. ( abs(x[40])= 0) }) } "
				EndIf 
				lfirst := .T.			
			Endif
			If nValor = 0
				exit
			Else
				loop  
			Endif
					
							
		Else
			aVlrCob[nPos,40] += nValor 
			nReDBM1 := aVlrCob[nPos,39]
			Exit
		Endif	
	
	// Se nao achou na primeira chave vai retirar a ultima posicao de checagem e continuar 
	Else          
		
		// Verifica pais
		If cPaisLoc == "URU"

			// Por definicao do mit - 44 - N13 nao deve procurar ate o nivel mais baixo que e
			// o lancamento de debito propriamente dito
			Exit
		EndIf
		
		// Se entrou aqui e porque nao tinha pelo menos um lancamento de debito
		If nP == -1
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Não foi possivel fazer o lancamento do desconto para nenhum debito." , 0, 0, {})
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "cMatric    - ["+cMatric+"]" , 0, 0, {})
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "cCodEveOri - ["+cCodEve+"]" , 0, 0, {})
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "cCodPla    - ["+cCodPla+"]" , 0, 0, {})
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "cProdut    - ["+cProdut+"]" , 0, 0, {})
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "cTes       - ["+cTes+"]" , 0, 0, {})
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "nValor     - ["+cValToChar(nValor)+"]" , 0, 0, {})
		  	Exit
		EndIf

		// Retira o ultimo .AND. do codeblock para proxima pesquisa
	    nP := rAt('.AND.',Upper(bChkPos))-1
	    If nP > -1
			bChkPos := SubStr(bChkPos,1,nP) + "}) }"
		EndIf 
    EndIf    
	
	// Somente para garantir que nao vai ficar infinitamento no loop
	If Empty(bChkPos) .Or. rAt('ASCAN(',Upper(bChkPos)) == 0
    	Exit
    EndIf	
EndDo   

// Retorno da funcao
Return( {nReDBM1 , nReCBM1} )

/*/{Protheus.doc} PLSRETSE1

Retorna Recno do título compensado
para estorno da compensação
@author  V.Alves
@version P12
@since   02/07/2021
/*/
Static Function RecnoTitComp(cPrefixo,cNum,cParcela)

	Local cQuery
	Local cAliasTemp := ""
	Local aRetorno := {}
	Local aEstorno := {}
	Local aRecnoSE1 := {}
	Local aAreaSE1 := SE1->(GetArea())

	cQuery := " SELECT SE1.R_E_C_N_O_ RecnoE1, SE5.E5_DOCUMEN, SE5.E5_SEQ FROM " + RetSQLName("SE1") + " SE1 "
	cQuery += " INNER JOIN " + RetSqlName("SE5") + " SE5 "
	cQuery += " ON SE5.E5_FILIAL = SE1.E1_FILIAL  "
	cQuery += " AND SE5.E5_PREFIXO = SE1.E1_PREFIXO  "
	cQuery += " AND SE5.E5_NUMERO = SE1.E1_NUM "
	cQuery += " AND SE5.E5_PARCELA = SE1.E1_PARCELA "
	cQuery += " AND SE5.E5_TIPODOC  = 'CP' "
	cQuery += " AND SE5.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SE1.E1_FILIAL = '"  + xFilial("SE1") + "' "
	cQuery += "   AND SE1.E1_PREFIXO = '" + cPrefixo + "' "
	cQuery += "   AND SE1.E1_NUM = '"     + cNum + "' "
	cQuery += "   AND SE1.E1_PARCELA = '" + cParcela + "' "
	cQuery += "   AND SE1.E1_TIPO IN ('"     +  MVDUPLIC + "') "// Monto o array do titulo principal, e caso exibir NCC do titilo principal monto o array de estorno.
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "

    cAliasTemp := GetNextAlias()
	dbUseArea(.T.,"TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)

	While !((cAliasTemp)->(Eof()))

		aAdd(aRecnoSE1,(cAliasTemp)->RecnoE1)
		aAdd(aEstorno, {{(cAliasTemp)->E5_DOCUMEN},(cAliasTemp)->E5_SEQ})

		(cAliasTemp)->(DbSkip())
	Enddo

	(cAliasTemp)->(dbCloseArea())

	If Len(aRecnoSE1) > 0 .And. Len(aEstorno) > 0
		aRetorno := {aRecnoSE1,aEstorno}
	EndIf
	RestArea(aAreaSE1)

Return aRetorno


//------------------------------------------------------------------- 
/*/{Protheus.doc} PLCalcImpNF
Realiza o calculo dos impostos da Nota fiscal

@author Vinicius Queiros Teixeira / Robson Nayland
@since 21/12/2021
@version Protheus 12
@Obs 
Obrigatório que o Titulo (SE1) e a Nota fiscal de saida (SF2) 
estejam posicionadas antes de chamada da função
/*/
//------------------------------------------------------------------- 
Function PLCalcImpNF(aBases, cOrigem)

	Local nINSSVlrMinino := GetNewPar("MV_VLRETIN", 25)
	Local nCOFINSVlrMinino := GetNewPar("MV_VRETCOF", 10)
	Local nPISVlrMinino := GetNewPar("MV_VRETPIS", 10)
	Local nIRRFVlrMinino := GetNewPar("MV_VLRETIR", 10)
	Local nCSLLVlrMinino := GetNewPar("MV_VRETCSL", 10)
	Local nISSVlrMinino := GetNewPar("MV_VRETISS", 0)
	Local lAbatimentoISS := GetNewPar("MV_TPABISS", "1") == "2"

	Default aBases := Array(6)
	Default cOrigem := "PLSTOSE1"

	// Inicializa variaveis de memoria do título posicionado para calculo dos impostos
	RegToMemory('SE1', .F.)

	M->E1_INSS := 0
	M->E1_COFINS := 0 
	M->E1_PIS := 0
	M->E1_IRRF := 0 
	M->E1_CSLL := 0 
	M->E1_ISS := 0
	M->E1_VRETIRF := 0 
	M->E1_BASEIRF := SF2->F2_BASEIRR 		
	M->E1_VALOR := SE1->E1_VALOR
	M->E1_TIPO 	:= SE1->E1_TIPO

	// Variaveis publicas
	aGets := {}
	lAltera := .F.
	lInclui := .T. 
	INCLUI := .T.
	ALTERA := .F.
				
	aBases[1] := SF2->F2_BASEIRR
	aBases[2] := SF2->F2_BASCOFI
	aBases[3] := SF2->F2_BASEISS
	aBases[4] := SF2->F2_BASCSLL
	aBases[5] := SF2->F2_BASPIS
	aBases[6] := SF2->F2_BASEINS
				
	// Calcula os Impostos nas Variaveis M-> de Acordo com a Natureza e Cliente
	fa040natur(aBases)

	SE1->(RecLock("SE1", .F.))

		SE1->E1_INSS := IIf(M->E1_INSS >= nINSSVlrMinino, M->E1_INSS, SE1->E1_INSS)
		SE1->E1_COFINS := IIf(M->E1_COFINS >= nCOFINSVlrMinino, M->E1_COFINS, SE1->E1_COFINS)
		SE1->E1_PIS := IIf(M->E1_PIS >= nPISVlrMinino, M->E1_PIS, SE1->E1_PIS)
		SE1->E1_IRRF := IIf(M->E1_IRRF >= nIRRFVlrMinino, M->E1_IRRF, SE1->E1_IRRF)
		SE1->E1_CSLL := IIf(M->E1_CSLL >= nCSLLVlrMinino, M->E1_CSLL, SE1->E1_CSLL)
		SE1->E1_ISS := IIf(M->E1_ISS >= nISSVlrMinino, M->E1_ISS, SE1->E1_ISS)
		SE1->E1_VRETIRF := M->E1_VRETIRF
		SE1->E1_BASEIRF := M->E1_BASEIRF

	SE1->(MsUnLock())

	SF2->(RecLock("SF2", .F.))

		SF2->F2_VALINSS := SE1->E1_INSS
		SF2->F2_VALCOFI := SE1->E1_COFINS
		SF2->F2_VALPIS  := SE1->E1_PIS
		SF2->F2_VALCSLL := SE1->E1_CSLL
		SF2->F2_VALISS 	:= SE1->E1_ISS
		SF2->F2_VALIRRF := SE1->E1_IRRF
		
	SF2->(MsUnLock())

	// Gera os Títulos dos Impostos
	If M->(E1_IRRF + E1_ISS + E1_INSS + E1_PIS + E1_CSLL + E1_COFINS) > 0
		a040duprec(cOrigem, Nil, Nil, Nil, lAbatimentoISS, Nil, Nil, Nil, .T.)
	EndIf

Return

//Função para verificar se há CT2 para o título que vai ser excluído referente ao LP 9NX
static function exc9NXtit()

Local lRet := .F.
Local cSql2 := ""
Local dDataLanc := stod( "" )
Local cLote := ""
Local cSubLote := ""
Local cDoc := ""
Local aCab := {}
Local aItens := {}
Local nOpc := 5
Local lPostgree := Alltrim(UPPER(TcGetDB())) $ "POSTGRES"
Local cRecORI := iif(lPostgree, "CAST(CV3_RECORI AS INTEGER)", "CV3_RECORI")
Local cRecDes := iif(lPostgree, "CAST(CV3_RECDES AS INTEGER)", "CV3_RECDES")

private lMsErroAuto := .f.

cSql2 := " Select DISTINCT "
cSql2 += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC "
cSql2 += " from " + retSqlName("CT2") + " CT2 "
cSql2 += " Inner Join " + RetSqlName("FK7") + " FK7 "
cSql2 += " On "
cSql2 += " FK7_FILIAL = '" + xfilial("FK7") + "' AND "
csql2 += " FK7_ALIAS = 'SE1' AND "
cSql2 += " FK7_CHAVE = '" + SE1->E1_FILIAL + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA + "' AND "
cSql2 += " FK7.D_E_L_E_T_ = ' ' "        
cSql2 += " Inner Join " + retSqlName("FK1") + " FK1 "
cSql2 += " On "
cSql2 += " FK1_FILIAL = '" + xfilial("FK2") + "' AND "
cSql2 += " FK1_IDDOC = FK7.FK7_IDDOC AND "
cSql2 += " FK1.D_E_L_E_T_ = ' ' "
cSql2 += " Inner Join " + RetSqlName("CV3") + " CV3 "
cSql2 += " On "
cSql2 += " CV3_FILIAL = '" + xfilial("CV3") + "' AND "
cSql2 += " CV3_TABORI = 'FK1' AND "
cSql2 += cRecORI + " = FK1.R_E_C_N_O_ AND "
cSql2 += cRecDes + " = CT2.R_E_C_N_O_ AND "
cSql2 += " CV3.D_E_L_E_T_ = ' ' "
cSql2 += " Where "
cSql2 += " CT2_FILIAL = '" + xfilial('CT2') + "' AND "
cSql2 += " CT2_LP IN ('9NX') AND " //Se precisar outros LPS que a origem é a FK1, inclua nesse IN
cSql2 += " CT2.D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql2),"EXCTBE1",.f.,.t.)

while !EXCTBE1->(eof())
	dDataLanc 	:= stod( EXCTBE1->CT2_DATA )
	cLote		:= EXCTBE1->CT2_LOTE
	cSubLote	:= EXCTBE1->CT2_SBLOTE
	cDoc		:= EXCTBE1->CT2_DOC

	aCab := {}

	aadd(aCab, {'DDATALANC', dDataLanc , nil})
	aadd(aCab, {'CLOTE', 	 cLote, nil})
	aadd(aCab, {'CSUBLOTE',  cSubLote, nil})
	aadd(aCab, {'CDOC', 	 cDoc, nil})

	msExecAuto({|x, y, z| CTBA102(x, y, z)}, aCab, aItens, nOpc)

	if lMsErroAuto
		mostraErro()
		Exit
	endif
	EXCTBE1->(dbSkip())
endDo

EXCTBE1->(dbCloseArea())

if !lMsErroAuto
	lRet := .T.
endif

return lRet


//------------------------------------------------------------------- 
/*/{Protheus.doc} GetLancDebFamilia
Retorna o Lançamento de Debito da Familia posicionada

@author Vinicius Queiros Teixeira
@since 24/03/2021
@version Protheus 12
/*/
//------------------------------------------------------------------- 
Static Function GetLancDebFamilia()

	Local cLancamento := ""

	If BA3->(FieldPos("BA3_CODCRE")) > 0
		cLancamento := BA3->BA3_CODCRE
	EndIf
		
	If Empty(cLancamento)
		cLancamento := AllTrim(GetNewPar("MV_PLCDPRT", ""))
	EndIf

Return cLancamento


//------------------------------------------------------------------- 
/*/{Protheus.doc} GetLancCredFamilia
Retorna o Lançamento de Crédito da Familia posicionada

@author Vinicius Queiros Teixeira
@since 24/03/2021
@version Protheus 12
/*/
//------------------------------------------------------------------- 
Static Function GetLancCredFamilia()

	Local cLancamento := ""

	If BA3->(FieldPos("BA3_CODLAN")) > 0
		cLancamento := BA3->BA3_CODLAN
	EndIf
		
	If Empty(cLancamento)
		cLancamento := AllTrim(GetNewPar("MV_PLCDESC", ""))
	EndIf

Return cLancamento