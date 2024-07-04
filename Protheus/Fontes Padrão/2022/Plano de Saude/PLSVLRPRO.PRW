#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"       	
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PLSVLRPRO.CH"

STATIC __aNiveis  	 	:= {}
STATIC __cCdTbPd	 	:= ""
STATIC __aCompo 	 	:= {}
STATIC __XbRetTabPre 	:= {| cCampo,cCodInt,cCodPad,cCodPro,;
							  dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nPorteOri,cAlias,cCodEsp,cCodUnd,lCobCoPart | PLVLTBPR(cCampo,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nPorteOri,cAlias,cCodEsp,cCodUnd, lCobCoPart)}
STATIC __aHorEsp	 	:= {}
STATIC __cCodAti	 	:= ""

STATIC cMVPLSCHMP	 	:= getNewPar("MV_PLSCHMP","HM,PPM,HMR")
STATIC cMVPLSCHMA	 	:= getNewPar("MV_PLSCHMA","PA,PAP,PAR")
STATIC cMVPLSUNPR    	:= getNewPar("MV_PLSUNPR","")  

STATIC UID_RETTAB 		:= 'PLSRETTAB'
STATIC UID_COMEVE 		:= 'PLSCOMEVE'
STATIC UID_CALEVE 		:= 'PLSCALCEVE'

Static lPLSRTBND			:= existBlock("PLSRTBND")
Static cMeMorial	:= ""

/*/{Protheus.doc} PLSCALCEVE
Calcula o valor do evento
cPadInt - Apto ou enfermaria, conforme tabela de cadastro e atributo do produto
cPadCon - Padrao de conforto, conforme tabela de cadastro e atributo do produto
cRegAte - 1=Internacao   2=Ambulatorial                    
Retorno da Funcao                                                
1 - Conteudo do vetor aRet:                                      
1  => Unidade de Medida que foi calculada                    
2  => Unidade de Valor em que a Unidade de Medida foi calculada  
3  => .t. ou .f. se foi calculado corretamente               
4  => Mensagem caso nao tenha sido calculado corretamente    
5  => Valor calculado                                        
6  => Codigo da Mensagem(Glosa)                              
2  => Valor total do evento                                      

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSCALCEVE(cCodPad,    /*01*/ cCodPro,     /*02*/ cMes,        /*03*/ cAno,        /*04*/ cCodInt,     /*05*/ ; 
                    cCodRDA,    /*06*/ cCodEsp,     /*07*/ cSubEsp,     /*08*/ cCodLoc,     /*09*/ nQtd,        /*10*/ ;
                    dDatPro,    /*11*/ cModPag,     /*12*/ cPadInt,     /*13*/ cRegAte,     /*14*/ nVlrApr,     /*15*/ ; 
                	aDadUsr,    /*16*/ cPadCon,     /*17*/ aQtdPer,     /*18*/ cCodTabHon,  /*19*/ cAliasTabH,  /*20*/ ;
                	nUS,        /*21*/ cAlUS,       /*22*/ cHorPro,     /*23*/ aRdas,       /*24*/ lCobCoPart,  /*25*/ ;
                    cProRel,    /*26*/ nPrPrRl,     /*27*/ aValAcu,     /*28*/ lReembolso,  /*29*/ dDatCir,     /*30*/ ;
                    cHorCir,    /*31*/ aUnidsBlo,   /*32*/ cTipoGuia,   /*33*/ lCompra,     /*34*/ nVlrAprPag,  /*35*/ ;
                    aVlBloq,    /*36*/ cTipPre,     /*37*/ lCirurgico,  /*38*/ nPerVia,     /*39*/ cRegPag,     /*40*/ ;
                    cRegCob,    /*41*/ nNOTUSED1,   /*42*/ nNOTUSED2,   /*43*/ aPacote,     /*44*/ cChaveGui,   /*45*/ ;
                    cSequen,    /*46*/ lCompara,    /*47*/ cUnCompara,  /*48*/ cRegInt,     /*49*/ cFinAte,     /*50*/ ;
                    cChaveLib,  /*51*/ cUFAte,      /*52*/ cMunAte,     /*53*/ lCalcTX,     /*54*/ aRdaAux,     /*55*/ ;
                    cTipAdm,    /*56*/ aComEve,     /*57*/ lAneste,     /*58*/ cRdaEdi,     /*59*/ cChvEvento,  /*60*/ ;
					cHrFim      /*61*/) 

local nOrdBAU    		:= BAU->(indexOrd())
local nRecBAU    		:= BAU->(recno())
local bRest      		:= {|| BAU->(dbSetOrder(nOrdBAU)), BAU->(dbGoTo(nRecBAU)) }
local nInd       		:= 1
local nfor       		:= 1
local nI         		:= 1
local nFatMul    		:= 1
local nFatSlv			:= 0
local nPos       		:= 0
local nVlrTot    		:= 0
local nAux       		:= 0
local nVlrPacote 		:= 0
local nVlrQtd1   		:= 0
local nQtdPer    		:= 0
local nVlrAcu    		:= 0
local nVlrAcuTot 		:= 0
local nPerHorEsp 		:= 0
local nUSREA	 		:= 0
local nPosRDA 	 		:= 0
local cRdmake    		:= ""
local cCodTab    		:= ""
local cAliasTab  		:= "" 
local cCodRDAREA 		:= ""
local cCodLocREA 		:= ""
local cCodEspREA 		:= ""
local cAlRea     		:= ""   
local cPLSREGANVE		:= getNewPar("MV_PLSRADP","1")
local cCodPla 			:= iIf(len(aDadUsr)>=11,aDadUsr[11],"")
local cVrProduto 		:= iIf(len(aDadUsr)>=12,aDadUsr[12],"")
local nCatHos      		:= 0
local nPrTxPag     		:= 0
local nPerInss     		:= 0
local nQtdAux  	 		:= 0	
local nNiveis			:= 0
local cTrbTpPre         := ""
local cConsFt      		:= "0"
local cConsBd      		:= ""
local cPorteMed    		:= ""
local cREGGOP			:= ""
local cGRUOPE  			:= ""
local cUndsNegC			:= ""
local cConsViA		 	:= ""
local cCodUnd           := ""
local cRefTDE			:= ""
local cConsHES			:= "0"
local cPreHEsp     		:= getNewPar("MV_PLSPHES","MED,ANE")
local lHorEspec    		:= getNewPar("MV_PLSHESP",.f.) //conceito para pagar horario especial so para urgencia e emergencia 
local cUrgEmer     		:= getNewPar("MV_PLSCDIU ","1,2")  
local cMV_PLSCAUX		:= getNewPar("MV_PLSCAUX","AUX")
local lOk		   		:= .f.
local lCobQtdPer   		:= .t.
local lSaida			:= .f.
local lDoppler     		:= .f.
local lFlag 			:= .t.
local lReturn			:= .f.
local dDatAnalise  		:= ctod("")
local aRet       		:= {}
local aRetExp    		:= {}
local aRetPtEn     		:= {}
local aRetFatM          := {}
local aRetUnd        	:= {}
local aVetAux      		:= {} 
local aVetTab			:= {}
local aRetAux			:= {}
local nPosRAux 			:= 0
local nUnMdRS 			:= 0
local cCodEmp           := subStr(iIf(len(aDadUsr) >= 02,aDadUsr[02],""),5,4) 
local nUNRS				:= 0
local nDecBAS			:= 0
local lPLSFATMP         := existBlock("PLSFATMP")
local lPLMUDQTD         := existBlock("PLMUDQTD")
local lGHash			:= .f.
local lChkFM			:= .f.
Local cMeMotot			:= ""

default nVlrApr    		:= 0
default nUS        		:= 0
default nPrPrRl    		:= 0             
default nVlrAprPag 		:= 0
default nPerVia    		:= 100
default nNOTUSED1 		:= 0
default nNOTUSED2  		:= 0
default cPadInt    		:= ""
default cPadCon    		:= ""
default cRegAte    		:= "1"
default cCodTabHon 		:= ""
default cAliasTabH 		:= ""
default cAlUS      		:= ""
default cHorPro    		:= ""
default cProRel    		:= ""
default cTipoGuia  		:= ""
default cTipPre	 		:= ""
default cRegPag	 		:= ""
default cRegCob	 		:= ""
default cChaveGui		:= ""
default cSequen  		:= ""
default cUnCompara 		:= ""                
default cRegInt			:= ""
default cFinAte			:= ""
default cChaveLib  		:= ""
default cUFAte			:= ""
default cMunAte			:= ""
default cHorCir    		:= cHorPro
default dDatCir    		:= dDatPro
default aDadUsr    		:= {}
default aQtdPer    		:= {}
default aRdas      		:= {}                              
default aValAcu    		:= {}
default aUnidsBlo  		:= {}
default aVlBloq    		:= {}
default aPacote	 		:= {0,0,{},""}
default lCobCoPart 		:= .f. //Pagamento
default lReembolso 		:= .f.
default lCompra    		:= .f.
default lCirurgico 		:= .f.
default lCompara 		:= .f.
default lCalcTX			:= .t.
default aRdaAux		    := {}
default cTipAdm		 	:= ""
default aComEve		    := {}	// 	Caso esse array venha preenchi é devido o  MV_PLCAAUX esta com valor 3 para tratamento de distribuicao de auxiliares nos procedimentos
default lAneste         := .f.	//	Desativado na versão 9.1 do PTU Batch
default cRdaEdi         := ""
default cChvEvento      := ""
default cHrFim			:= ""

nDecBAS := iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'), PLGetDec('BD7_VLRBPF'))

if ! lGHash
	
	if existBlock("PLSDATAN")
	   cPLSREGANVE := execBlock("PLSDATAN",.f.,.f.,{cTipoGuia,cPLSREGANVE})
	endIf 
	
	if existBlock("PLSFIATE")
	   cFinAte := execBlock("PLSFIATE",.f.,.f.,{cFinAte})
	endIf
	
	//data do evento
	if cPLSREGANVE == "1" 
	
	   dDatAnalise := dDatPro
	   
	   if empty(dDatPro)
	      dDatAnalise := dDataBase
	   endIf
	   
	//data da mudanca de fase/valorizacao 
	else 
	   dDatAnalise := dDataBase
	endIf  
	   
	//Posiciona na RDA...                                    
	BAU->(dbSetOrder(1))
	BAU->(msSeek(xFilial("BAU")+cCodRda))
	
	cTipPre := BAU->BAU_TIPPRE
	nCatHos := BAU->BAU_CATHOS
	
	if empty(cCodTabHon)
	
	   //Busca a tabela de pagamento para este prestador...                   
	   aVetTab := PLSRETTAB(cCodPad,cCodPro,dDatAnalise,cCodInt,cCodRDA,cCodEsp,cSubEsp,;
	   						cCodLoc,dDatPro,iIf(!lCobCoPart,"1","2"),iIf(len(aDadUsr) >= 45, aDadUsr[45],""),cCodPla,;
	   						nil,"2",aDadUsr,cTipPre,cRegPag,cRegCob,lReembolso,nil,nil,cRegAte,cFinAte,nil,nil,nil,cCodEmp,cAno,cMes)
	
	   //Verifica se houve algum erro na pesquisa de Tabela de Honorario      
	   if ! aVetTab[1]
	      
	      aadd(aRet,{"","",aVetTab[1],aVetTab[2],{},aVetTab[5],cCodPad,cCodPro})
	      
	      aRetAux := { aRet, nVlrTot,"","",0,0,"",0 } 
	      lReturn := .t.
	      
	   endIf
	   
	   cCodTab   := aVetTab[3]
	   cAliasTab := aVetTab[4]
	   
	else
	   cCodTab   := cCodTabHon
	   cAliasTab := cAliasTabH
	endIf   
	
	if ! lReturn
	
		//Busca a composicao de pagamento para este procedimento...
		// Caso esse array venha preenchi é devido o  MV_PLCAAUX esta com valor 3 para tratamento de distribuicao de auxiliares nos procedimentos            
		if len(aComEve) == 0 
			aComEve  := PLSCOMEVE(cCodTab,cCodPad,cCodPro,cCodInt,dDatPro,cTipoGuia,nil,lCobCoPart,cCodRDA,cCodEsp,cSubEsp,cCodLoc,'1',,lAneste, aVetTab)
		endIf	
		
		if lCompara
		
			aComEveRel := PLSCOMEVE(cCodTab,cCodPad,cProRel,cCodInt,dDatPro,cTipoGuia,nil,lCobCoPart,cCodRDA,cCodEsp,cSubEsp,cCodLoc,'1',,lAneste, aVetTab)
		
		 	for nInd := 1 to len(aComEveRel) 
		 	
				nPos := aScan(aComEve,{|x| x[1] + strZero(x[3],2) == aComEveRel[nInd,1] + strZero(aComEveRel[nInd,3],2)})
				
				if aComEveRel[nInd,1] $ cUnCompara .and. nPos == 0
				
					aadd(aComEve, aComEveRel[nInd])
					aadd(aRdas,{aComEveRel[nInd,1],cCodRDA,cCodLoc,cCodEsp,0,cTipPre,0,0,iIf(allTrim(aComEveRel[nInd,1]) $ cMV_PLSCAUX,strZero(aComEveRel[nInd,3],2),"")})
					
				endIf
					
		 	next
		
		endIf
		
		//Verifica se existe composicao para o procedimento      
		if len(aComEve) == 0
		
		   PLSPOSGLO(PLSINTPAD(),__aCdCri028[1],__aCdCri028[2])
		   cMsg    := __aCdCri028[1]+" - "+PLSBCTDESC()
		   lRet    := .f.
		   
		   aadd(aRet,{"","",lRet,cMsg,{},__aCdCri028[1],cCodPad,cCodPro})
		   
		   aRetAux := { aRet,nVlrTot,"","",0,0,"",0 }
		   lReturn := .t.
		   
		endIf               
		
		if ! lReturn
		
			for nInd := 1 to len(aComEve)
				
				cCodUnd 	:= allTrim(aComEve[nInd,1])
				cRdmake 	:= allTrim(aComEve[nInd,6])
				cConsFt 	:= aComEve[nInd,9]
				cConsHES	:= aComEve[nInd,10]
				cConsBd   	:= aComEve[nInd,11]
				cPorteMed 	:= aComEve[nInd,12]
				cConsVia 	:= Iif( len(aComEve[nInd]) >= 14, aComEve[nInd,14], '')
				lSaida  	:= .f.
				
				aRetUnd := PLSA720UND(cCodUnd)
			
				aadd(aRetUnd,cCodUnd)

				if cConsFt == "1"
					
					BAG->(dbSetOrder(1))
					if BAG->(msSeek(xFilial("BAG") + cTipPre)) .and. BAG->BAG_CONSFT == "0"
						cConsFt := "0" //nao
					endIf
					
				endIf

				if ! lSaida
					
					//Trabalhando com unidades bloqueadas
					if  aScan(aUnidsBlo,{ |x| eval( {|x| aVetAux := x, .t.}, x) .and. aScan(aRetUnd, {|y| iIf( allTrim(y) <> "AUX", allTrim(y) == allTrim(aVetAux[1]) , allTrim(y) == allTrim(aVetAux[1]) .and. val(aVetAux[2]) == aComEve[nInd,3] ) } ) > 0  }) > 0
						lSaida := .t.
					endIf
					
				endIf
				
				//Executa a funcao de cada unidade de medida para calcular o valor do procedimento 
				//Essa funcao vai sempre retornar:                                                 
				//1- Verificacao se a unidade de medida foi calculada corretamente.                
				//    Conteudo: .t. ou .f.                                                          
				//2- Mensagem que deveria emitir caso o calculo nao for feito corretamente.        
				//    Conteudo: Mensagem(string) a ser exibida.                                     
				//3- Um vetor contendo as seguintes informacoes:                                   
				//   Valor calculado da unidade de medida. Conteudo: Valor(numerico)               
				//    Alias em que a informacao foi encontrada. Conteudo: Alias do arquivo(string)  
				//    Numero do Auxiliar, caso a unidade seja AUX. Conteudo: Num. Auxiliar(numerico)
				//4- Codigo da mensagem(Glosa).                                                    
				//   Conteudo: 01,02,03 (string)     
				                                              
				if ! empty(cRdmake)
			
					nPosRDA := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(aComEve[nInd,1]) })
					
					//aqui eh o tratamento para valorar os auxiliares agora no novo conceito da 		 
					//Guia de Honorario Individual, aqui o sistema esta buscando o Honorario com base  
					//em outra guia que ele encontrou o valor de referencia - variavel nPosRAux		 		
					nPosRAux := 0
					
					if len(aRdaAux) > 0
						nPosRAux := aScan(aRdaAux,{ |x| allTrim(x[1]) == allTrim(aComEve[nInd,1]) })
					endIf
					
					if nPosRDA == 0
						nPosRDA := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(PLSA720VND(aComEve[nInd,1])) })
					endIf
					
					if nPosRAux > 0

						cCodRDAREA := aRdaAux[nPosRAux,2]
						cCodLocREA := aRdaAux[nPosRAux,3]
						cCodEspREA := aRdaAux[nPosRAux,4]
						
						if nUS > 0 .and. aRdaAux[nPosRAux,5] == 0 
						
							//na cobranca pode haver na aRdas u.s especificas por unidade
							//que tem maior prioridade que a u.s do nivel da co-part que foi
							//encontrado.exemplo: no bhj tem 100% a 0,3 so que p CLI e mais
							//forte a 0,4
							//lembrete-A nUS quando e pagamento sempre vem zerado... so
							//existe esse conceito de vir pro plsvlrpro a u.s sugerido
							//sem ser aRdas para COBRAR...
							nUSREA := nUS
							cAlRea := cAlUs
							
						else
							nUSREA  := aRdaAux[nPosRAux,5]
							cAlRea	:= cAlUs
						endIf	
						
					else
					
						if nPosRDA == 0
						
							cCodRDAREA := cCodRDA
							cCodLocREA := cCodLoc
							cCodEspREA := cCodEsp
							nUSREA     := nUS
							cAlRea     := cAlUS
							
						else
						
							cCodRDAREA := aRdas[nPosRDA,2]
							cCodLocREA := aRdas[nPosRDA,3]
							cCodEspREA := aRdas[nPosRDA,4]

							if nUS > 0 
								nUSREA  := aRdas[nPosRDA,5]
								cAlRea	:= cAlUs
							endIf
							
						endIf
						
					endIf

					if ! empty(cCodRDAREA)
						
						BAU->(dbSetOrder(1))
						if BAU->( msSeek(xFilial("BAU") + cCodRDAREA ) )
							cTipPre := BAU->BAU_TIPPRE
						endIf	

					endIf

					//se considera o fator ou nao
					if cConsFt == "1" 

						if ! lChkFM
							lChkFM	:= .t.
							nFatSlv := PLSRFatM(cPadInt, cPadCon, cCodInt)
						endIf	
						
						nFatMul := nFatSlv

						//Nova implementacao... verificar se no produto x tipo   
						//de prestador tem fator diferente...                    
						BMD->(dbSetOrder(1))
						if BMD->(msSeek(xFilial("BMD") + cCodInt + cCodPla + cVrProduto + cTipPre))
					
							//Nova implementacao... vou verificar se existe vigencia para o regst. 
							lOk := .f.
							while !BMD->(eof()) .and. !lOk .and. BMD->(BMD_CODIGO+BMD_VERSAO+BMD_TIPPRE) == cCodInt+cCodPla+cVrProduto+cTipPre
						
								//Vou pegar a data de vigencia q se encaixa no intervalo definido      
								//Se ele entrar eh porque achou o intrevalo, e acaba o loop			 
								
								if (empty(BMD->BMD_VIGDE) .or. BMD->BMD_VIGDE <= dDatAnalise) .and. (empty(BMD->BMD_VIGATE) .or. BMD->BMD_VIGATE >= dDatAnalise)
									
									//1=Regime Internacao;2=Regime Ambulatorial;3=Ambos										
									if ( BMD->BMD_CONFMT $ "3, " .or. allTrim(BMD->BMD_CONFMT) == allTrim(cRegAte) ) .and. BMD->BMD_FATMUL > 0
										nFatMul := BMD->BMD_FATMUL
									endIf
									
									lOk := .t.
								endIf
								
							BMD->(dbSkip())
							endDo
							
						endIf
						
						//Nova implementacao... verificar se no produto x tipo x procedimento  
						//de prestador tem fator diferente...                                  
						BME->(dbSetOrder(1))
						if BME->(msSeek(xFilial("BME") + cCodInt + cCodPla + cVrProduto + cTipPre + cCodPad + cCodPro))
							
							lOk := .f.
							while !BME->(eof()) .and. !lOk .and. BME->(BME_CODIGO+BME_VERSAO+BME_TIPPRE+BME_CODPAD+BME_CODPSA) == cCodInt+cCodPla+cVrProduto+cTipPre+cCodPad+cCodPro
				
								//Vou pegar a data de vigencia q se encaixa no intervalo definido
								//Se ele entrar eh porque achou o intrevalo, e acaba o loop			 
								if (empty(BME->BME_VIGDE)  .or. BME->BME_VIGDE  <= dDatAnalise) .and. (empty(BME->BME_VIGATE) .or. BME->BME_VIGATE >= dDatAnalise)
				
									//1=Regime Internacao;2=Regime Ambulatorial;3=Ambos											 
									if ( BME->BME_CONFMT $ "3, " .or. allTrim(BME->BME_CONFMT) == allTrim(cRegAte) ) .and. BME->BME_FATMUL > 0
										nFatMul := BME->BME_FATMUL
									endIf
									
									lOk := .t.
								endIf
								
							BME->(dbSkip())
							endDo
							
						endIf
						
						aRetFatM := PLFATM(cCodPad,cCodPro,cCodInt,cCodRDA,cCodEsp,cCodLoc,nQtd,cPadInt,cRegAte,aDadUsr,cPadCon,;
			            	        	   lCobCoPart,dDatCir,cHorCir,cTipoGuia,lCompra,cConsFt,cCodPla,cVrProduto,nFatMul,cCodTab)
			
			        	if ValType(aRetFatM) == "A" .and. len(aRetFatM) > 0  
							nFatMul := aRetFatM[1]
						endIf	

						//SOLICITACAO DE INTERNACAO E RESUMO - tratamento para regime 
						//Regime de atendimento que não comporta fator multiplicador     
						if ! empty(cRegInt) .and. nFatMul > 1 .and. allTrim(cRegInt) $ allTrim( getNewPar("MV_FTREGI","@") )
							nFatMul := 1
						endIf	

					endIf	

					if lPLSFATMP
			
						aRetFatM := execBlock("PLSFATMP",.f.,.f.,{cCodPad,cCodPro,cCodInt,cCodRDA,cCodEsp,cCodLoc,;
																	nQtd,cPadInt,cRegAte,aDadUsr,cPadCon,;
																	lCobCoPart,dDatCir,cHorCir,cTipoGuia,;
																	lCompra,cConsFt,cCodPla,cVrProduto,nFatMul,cCodTab})
						if ValType(aRetFatM) == "N"
							nFatMul := aRetFatM
						else
							nFatMul := aRetFatM[1]
							cConsFt := aRetFatM[2]
						endIf
						
					endIf
					
					//tratamento para via de acesso
					if lPLMUDQTD
						nQtdAux := execBlock("PLMUDQTD",.f.,.f.,{nQtd,aComEve[nInd,1],lCirurgico,aRdas,nPosRDA,cConsViA})
					else
						
						if lCirurgico .and. cConsVia $ " |1"
							
							//percentual da via de acesso no BD7
							if nPosRDA != 0 .and. len(aRdas[nPosRDA]) >= 8 .and. aRdas[nPosRDA,8] > 0 

								nQtdAux := ( aRdas[nPosRDA,8] / 100 ) * nQtd

							else
								
								//percentual da via de acesso no BD6
								if nPerVia > 0
									nQtdAux := (nPerVia / 100) * nQtd 
								else
									nQtdAux := nQtd
								endIf
								
							endIf
							
						else
							nQtdAux := nQtd
						endIf
						
					endIf
					
					if ! lDoppler
						lDoppler := aComEve[nInd,1] == "DOP"
					endIf
					cMemorial := ""
					aRetExp   := {}
					aRetExp   := execBlock(cRdmake,.f.,.f.,{nQtdAux,	/*01*/ aComEve[nInd,3], /*02*/ aRet,		/*03*/ dDatAnalise,	/*04*/ cCodRDARea, 		/*05*/;
															cCodInt, 	/*06*/ cCodLocRea, 		/*07*/ cCodTab,		/*08*/ cCodPad,		/*09*/ cCodPro, 		/*10*/;
															cMes,		/*11*/ cAno,			/*12*/ cCodEspRea, 	/*13*/ cSubEsp,		/*14*/ cModPag,			/*15*/;
															{},			/*16*/ nVlrApr,			/*17*/ cTipPre,		/*18*/ aDadUsr,		/*19*/ nFatMul,			/*20*/;
															cConsFt,	/*21*/ nUSREA,			/*22*/ cAlRea,		/*23*/ cCodRda,		/*24*/ lCobCoPart,		/*25*/;
															cProRel,	/*26*/ nPrPrRl,			/*27*/ aValAcu,		/*28*/ cPadInt,		/*29*/ cRegAte,			/*30*/;
															cPadCon,	/*31*/ aQtdPer,			/*32*/ cHorPro,		/*33*/ aRdas,		/*34*/ aComEve[nInd,1],	/*35*/;
															lReembolso,	/*36*/ nCatHos,			/*37*/ cConsBd,		/*38*/ cPorteMed,	/*39*/ dDatPro,			/*40*/;
															nVlrAprPag,	/*41*/ aVlBloq,			/*42*/ aComEve,		/*43*/ cRegPag,		/*44*/ cRegCob,			/*45*/;
															aPacote,	/*46*/ cFinAte,			/*47*/ cUFAte,		/*48*/ cMunAte,		/*49*/ cRdaEdi,			/*50*/;
															cChvEvento  /*51*/ })
				
					//Valor de referencia original da TDE.
					cRefTDE := aComEve[nInd,3]
					
					cMeMotot += cMemorial + CRLF

					//Se o valor de referencia foi diferenciado na tabela de preço, utiliza ela.
					if len(aRetExp[3]) > 0 .and. len(aRetExp[3][1]) > 11
					
						if aRetExp[3][1][12] > 0
							cRefTDE := aRetExp[3][1][12]
						endIf
						
					endIf
					
					aadd(aRet,{	aComEve[nInd,1], 	/*01*/ aComEve[nInd,7], /*02*/ aRetExp[1],		/*03*/ aRetExp[2],	/*04*/ aRetExp[3],		/*05*/;
								aRetExp[4],			/*06*/ cCodPad,			/*07*/ cCodPro,			/*08*/ cRefTDE,		/*09*/ aComEve[nInd,10],/*10*/;
								aComEve[nInd,11],	/*11*/ aComEve[nInd,12],/*12*/ aComEve[nInd,13],/*13*/ cConsFt,		/*14*/ aComEve[nInd,16],/*15*/;
								aComEve[nInd,18],	/*16*/ 0,				/*17*/ aComEve[nInd,8] 	/*18*/})
								
					If lSaida
						aRet[Len(aRet)][3] := .T.
						aRet[Len(aRet)][4] := ""
						aRet[Len(aRet)][5] := {{0, "B4R", 0, 0, 0, 0, "Ex.Pg", 0, 0, "", "0"}}
						aRet[Len(aRet)][6] := ""
					EndIf
					
					for nfor := 1 to len(aRetExp[3])
					
						if aRetExp[1]
							nVlrTot += aRetExp[3,nFor,4]
						endIf
						
					next
			
				else
				
					PLSPOSGLO(PLSINTPAD(),__aCdCri046[1],__aCdCri046[2])
					
					cMsg    := PLSBCTDESC()
					cCodCri := __aCdCri046[1]
					
					aadd(aRet,{aComEve[nInd,1],aComEve[nInd,7],.f.,cCodCri+" - "+cMsg,{},cCodCri,cCodPad,cCodPro})
					
				endIf
				
			next
			
			nOrdUnMd 	:= 0 //Variavel ira receber o indice do aRet que possui composicao valorizada em reais
			nContDel 	:= 0 //Quantidade de registros deletados
			nUNRS 	 	:= 0
			
			If !lCobCoPart
				PLGRVBX6(, , ,cMeMotot)
			endIf

			//Valorizacao parametrizada no BC0
			if cAliasTab == "BC0"
			
				//Percorro o aRet para procurar unidades de medidas em reais (R$)
				for nUnMdRS := 1 to len(aRet)		
				
					aUNRS := strTokArr(getNewPar("MV_PLSUNRS","HMR") , ',')
				
					for nUNRS := 1 to len(aUNRS)
				
						//Verifico se eh a unidade de medida em reais e se esta no nivel BC0		
						if aRet[nUnMdRS,1] == aUNRS[nUNRS] .and. ValType(aRet[nUnMdRS,5,1]) == "A" .and. allTrim(aRet[nUnMdRS,5,1,2]) == cAliasTab .and. aRet[nUnMdRS,5,1,3] == 0
							
							//Guardo o indice do aRet que tem o HMR a ser preservado
							nOrdUnMd := nUnMdRS
							exit
							
						endIf
						
					next 
					
				next nUnMdRS
			
				//Percorro mais uma vez para deletar 
				for nUnMdRS := 1 to len(aRet)
					
					//Se estou no HMR ou ele nao existe
					if nUnMdRS == nOrdUnMd .or. nOrdUnMd == 0
						
						loop

					//Se tem HMR mas nao estou nele deleto						
					else
						aDel(aRet,nUnMdRS)
						nContDel++
					endIf
					
				next nUnMdRS
				
				//ajusto o tamanho do aRet
				aSize(aRet,len(aRet) - nContDel)
			
			endIf
			
			//Buscar taxa administrativa na operadora para PTU ou da rede de atendimento 
			if ! lCobCoPart .and. ! lDoppler .and. lCalcTX
				
				//retorna o valor da taxa administrativa
				nPrTxPag := PLSTXADM(cTipPre,cCodPad,cCodPro,cCodEsp,nVlrApr,nUsrea,cFinate,cCodRda,cRdaEdi,aDadUsr,dDatAnalise,cRegAte)
			
				if nPrTxPag > 0
			   	     
			    	for nInd := 1 to len(aRet)
			    	
			        	for nPos := 1 to len(aRet[nInd,5])
			        	
			            	if len(aRet[nInd,5,nPos]) >= 8
			                	 aRet[nInd,5,nPos,8] := aRet[nInd,5,nPos,4]
			              	endIf
			              	
			          	next
			          	    
			      	next
			      	                 
			   	endIf
					   
			endIf
			
			//retorna o percentual do inss patronal
			nPerInss := plsPeInPt()
			
			//Aqui valorizo o caso de quando e lancado por pacote (valores fechados p/ o procedimento inteiro)    
			for nInd := 1 to len(aRet)
			
			    for nPos := 1 to len(aRet[nInd,5])
			    
			        if aRet[nInd,5,nPos,5] > 0 .and. nVlrPacote == 0
			
			            nVlrPacote := aRet[nInd,5,nPos,5]
			        	exit
			        endIf
			        
			    next
			           
			    if nVlrPacote > 0
			       exit
			    endIf
			       
			next        
			                              
			//Aqui e calculado o valor do conceito qtd x percentual...                                            
			if lCobCoPart
			   lCobQtdPer := getNewPar("MV_PLSARQC","1") == "1" //Cobranca 
			else
			   lCobQtdPer := .t. //Pagamento 
			endIf   
			                               
			if existBlock("PLSQTPER")
				lCobQtdPer := execBlock("PLSQTPER",.f.,.f.,{cCodPad,cCodPro,aQtdPer,nQtd,cCodRDA,cCodLoc,cCodEsp,lCobCoPart,xFilial("BD6")+cChaveGui,lCobQtdPer})
			endIf                                                            
			
			if lCobQtdPer .and. len(aQtdPer) == 0 .and. !empty(cChaveGui) .and. !empty(cSequen)
			   	aQtdPer := PlMonQtPer(cSequen,cCodPad,cCodPro,nQtd,.f.,xFilial("BD6")+cChaveGui,dDatPro)
			endIf
			
			if lCobQtdPer .and. len(aQtdPer) > 0   
			                                 
			   aeval(aQtdPer,{|x| nQtdPer := nQtdPer + iIf(x[3] > 0,1,0) })
			   
			   //Aqui e calculado o valor do conceito qtd x percentual...                                            
			   if nQtdPer > 0
			   
			      cUndsNegC := getNewPar("MV_PLSUDCQ","")
			      
			      for nInd := 1 to len(aRet)
			      
			          for nPos := 1 to len(aRet[nInd,5])
			              
			              //Se o subitem for um da lista e for um pagamento vou pagar o valor integral ou seja
			              //o valor unitario do item x a quantidade (ex: R$ 100,00 * qtd 3)
			              if allTrim(aRet[nInd,1]) $ cUndsNegC
			               
			                 nVlrAcuTot += aRet[nInd,5,nPos,4]
			                 
			              else   
			
			                 nVlrQtd1 := aRet[nInd,5,nPos,4] / nQtd
			                 nVlrAcu  := 0
			           
			                 for nAux := 1 to len(aQtdPer)
			                 
			                     if aQtdPer[nAux,3] > 0
			                      
			                        //credito
			                        if aQtdPer[nAux,1] == "1"
			                         
			                           nVlrAcu += nVlrQtd1 + (nVlrQtd1 - ( (nVlrQtd1 * aQtdPer[nAux,3]) / 100) )
			                           
			                       	//debito
			                        else 
			                        
			                           nVlrAcu += (nVlrQtd1 * aQtdPer[nAux,3]) / 100
			                           
			                        endIf
			                           
			                     endIf
			                        
			                 next
			                 
			                 aRet[nInd,5,nPos,4] := round(nVlrAcu, nDecBAS)
			                 
			                 nVlrAcuTot += round(nVlrAcu, nDecBAS)
			                 
			              endIf
			                 
			          next    
			          
			      next
			                               
			      nVlrTot := nVlrAcuTot
			      
			   endIf  
			    
			endIf
			
			//Calcula o conceito de horario especial
			if cConsHES == "1"
			
				lFlag := .t.
			
				//conceito para pagar horario especial so para urgencia e emergencia
				if lHorEspec
					lFlag := .f.
				 	if allTrim(cTipAdm) $ allTrim(cUrgEmer)
				 		lFlag := .t.
				 	endIf	
				endIf
			
				BY5->(dbSetOrder(1)) //BY5_FILIAL+BY5_CODIGO+BY5_CODINT+BY5_CODHON+BY5_CODATI
				BF8->(dbSetOrder(1)) //BF8_FILIAL+BF8_CODINT+BF8_CODIGO
				BAS->(dbSetOrder(2)) //BAS_FILIAL+BAS_CODATI
			
				cCodAti := getNewPar("MV_PLSGHEP","001")
			
				if lFlag .and. BY5->(msSeek(xFilial("BY5")+cCodRda+cCodInt+cCodTab))
					
					while !BY5->(eof()) .and. BY5->BY5_CODIGO ==  cCodRda .and. BY5->BY5_CODINT == cCodInt .and. BY5->BY5_CODHON == cCodTab

						if PLSINTVAL("BY5","BY5_VIGINI","BY5_VIGFIN",dDatAnalise)
				
							cCodAti		:= BY5->BY5_CODATI
							nPerHorEsp	:= PLCALHE(cCodAti,dDatCir,cHorCir,cCodRda,cCodLoc,cHrFim)
							
							if nPerHorEsp > 0
								exit
							endIf

						endIf
					
					BY5->(dbSkip())
					endDo
					
				elseIf lFlag .and. BF8->(msSeek(xFilial("BF8")+cCodInt+cCodTab)) .and. !empty(BF8->BF8_CODATI)
					
					cCodAti		:= BF8->BF8_CODATI
					nPerHorEsp	:= PLCALHE(cCodAti,dDatCir,cHorCir,cCodRda,cCodLoc,cHrFim)
					
				elseIf lFlag .and. BAS->(msSeek(xFilial("BAS")+cCodAti))
				
					nPerHorEsp	:= PLCALHE(cCodAti,dDatCir,cHorCir,cCodRDA,cCodLoc,cHrFim)
					
				else
					nPerHorEsp	:= 0
				endIf
				
				if existBlock("PLSHRESP")
					nPerHorEsp := execBlock("PLSHRESP",.f.,.f.,{nPerHorEsp,dDatCir,cHorCir,cCodTab,lCobCoPart,lCompra,cCodPad,cCodPro,lReembolso})
				endIf
			
				//Caso haja horario especial atualiza os valores...                                                   
				if nPerHorEsp > 0
			
					nVlrAcuTot := 0
					nVlrAcu    := 0
					cTrbTpPre  := ""
			
					for nInd := 1 to len(aRet)
			
						nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(aRet[nInd,1])})
						
						if nPos == 0
							nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(PLSA720VND(aRet[nInd,1]))})
						endIf
			
						if nPos > 0
							cTrbTpPre := aRdas[nPos,6]
						else
							cTrbTpPre := cTipPre
							//isso nao e o ideal, o que acontece e que pode haver tabelas (bf8) diferente p pagar e receber
							//so que elas podem ter unidades diferentes para o mesmo procedimento
							//exemplo eu pago pela 001 que e HM e cobro pela 018 que e HMR
							//ai se falhar o aScan acima que e o caso eu nao consigo apurar o horario especial p cobrar
							//o else implementado resolve mais nao e o ideal, o ideal e o sistema sempre entender a estrutura
							//da TDE com base na sua real unidade. No protheus 9 vamos ter o BD7_CODUNM para PAGAR e um
							//outro campo p receber.
						endIf

						//verifica se a unidade na BD3 aceita horario especial aRet[nInd,16]
						//Classe Rda x Procedimentos
						if  aRet[nInd,16] .and. ( cTrbTpPre $ cPreHEsp .or. PLAHESP(cTrbTpPre,cCodPad,cCodPro) ) 
						
							for nPos := 1 to len(aRet[nInd,5])
						
								nVlrAcu := aRet[nInd,5,nPos,4] + round( ( ( aRet[nInd,5,nPos,4] * nPerHorEsp) / 100 ), nDecBAS )
						
								aRet[nInd,5,nPos,4] := nVlrAcu
						
								if  len(aRet[nInd,5,nPos]) >= 11 .and. ValType(aRet[nInd,5,nPos,11]) == 'C'
								
									aRet[nInd,5,nPos,11] := '1'
									aRet[nInd,17] 		 := nPerHorEsp
								
								endIf
							
								nVlrAcuTot += nVlrAcu
							
							next
						
						else
					
							for nPos := 1 to len(aRet[nInd,5])
								nVlrAcuTot += aRet[nInd,5,nPos,4]
							next
						
						endIf

					next
				
					nVlrTot := nVlrAcuTot
				
				endIf
			
			endIf
			
			//Ponto de Entrada para manipular o aRet...                                                           
			if existBlock("PLCALCEV")
			
			    aRetPtEn := execBlock("PLCALCEV",.f.,.f.,{ lCobCoPart,lCompra,nVlrTot,aRet,cCodInt,aRdas,cCodPad,cCodPro,cCodPla,nQtd,dDatPro,aDadUsr,nVlrApr,cChaveLib })
				nVlrTot  := round(aRetPtEn[1], nDecBAS)                                   
				aRet	 := aRetPtEn[2]
				
			endIf
			
			//Restaura areas...
			eval(bRest)
			
		endIf
		
	endIf	
	
	if ! lReturn
		aRetAux := { aRet, nVlrTot, cCodTab, cAliasTab, nPerHorEsp, nPrTxPag, cConsFt, nFatMul, nPerInss }
	endIf
		
endIf

return(aRetAux)



/*/{Protheus.doc} PLSCALRCC
Retorna o valor em real convertido em CH 

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSCALRCC(paramixb)
local nRef         	:= paramixb[2]
local cCodInt      	:= paramixb[6]
local cMes         	:= paramixb[11]
local cAno         	:= paramixb[12]

local nQtdCHConver 	:= 0
local cMsg         	:= ""
local cCodCri      	:= ""
local lOK          	:= .t.
local aRetRCC		:= {}
local aRet         	:= {}

BFM->(dbSetOrder(1))
if BFM->( msSeek( xFilial("BFM") + cCodInt + cAno + cMes ) ) .and. BFM->BFM_VALRDA > 0

   nQtdCHConver := nRef / BFM->BFM_VALRDA
   paramixb[2]  := nQtdCHConver
   aRet 		:= PLSRETUSNV(paramixb)

else
	
	PLSPOSGLO( PLSINTPAD() , __aCdCri237[1] , __aCdCri237[2] )
	cCodCri := __aCdCri237[1]
	cMsg    := cCodCri +" - "+ PLSBCTDESC()
   	
 	aadd(aRetRCC, { 0, "", 0, 0, 0, 0, "", 0, 0, "0", '0', 0, 0, 0, 0 } )

	aRet := { lOK, cMsg, cCodCri, aRetRCC }

endIf

return(aRet)

/*/{Protheus.doc} PLSRETVIN
Retorna o valor da incidencia  

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETVIN(paramixb)
local nFatMul := paramixb[20]
local aRetRea := {}
local cAlias  := "BD4"
local cMsg    := ""
local cCodCri := ""
local lOk     := .t.

if nFatMul > 0
	
	lOk := .t.
	aadd(aRetRea, { 0, cAlias, 0, 0, 0, nFatMul, "", 0, 0, "0", '0', 0, 0, 0, 0 })

else

	lOk := .f.
	aadd(aRetRea, { 0, "", 0, 0, 0, 0, "", 0, 0, "0", '0', 0, 0, 0, 0 } )

	PLSPOSGLO( PLSINTPAD() , __aCdCri238[1] , __aCdCri238[2] )
	cCodCri := __aCdCri238[1]
	cMsg    := cCodCri +" - "+ PLSBCTDESC()

endIf

return( { lOK, cMsg, cCodCri, aRetRea } )

/*/{Protheus.doc} PLSRETCRR
Retorna o valor do CRR   

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETCRR(paramixb)
local nFatMul := paramixb[20]
local aRdas	  := paramixb[34]
local cCodUnd := paramixb[35]
local aRetRea := {}
local cAlias  := "BD4"
local cMsg    := ""
local cCodCri := ""
local lOk     := .t.

nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(cCodUnd) })		
if nPos > 0
	nFatMul := iIf( len(aRdas[nPos])>= 10,iIf(aRdas[nPos,10] <> "0",nFatMul,1) ,nFatMul	)
endIf	

aadd(aRetRea, { 0, cAlias, 0, 0, 0, nFatMul, "", 0, 0, "0", '0', 0, 0, 0, 0 } )

return( { lOK, cMsg, cCodCri, aRetRea } )

/*/{Protheus.doc} PLSCHMP
Funcao que Retorna o Porte Principal para Valorizacao dos auxiliares.

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSCHMP( cCodUnd )
local cRet := ""

default cCodUnd	:= "AUX"

//Portes Medicos
if cCodUnd == "AUX" 

	cRet := cMVPLSCHMP

//Portes Anestesicos
elseIf cCodUnd == "AUA" 

	cRet := cMVPLSCHMA
	
endIf

return(cRet)

/*/{Protheus.doc} PLSRETVCRN
Retorna o valor da CRR  

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETVCRN(paramixb)
local nFatMul 	:= paramixb[20]
local aRdas	  	:= paramixb[34]
local cCodUnd 	:= paramixb[35]

local cAlias  	:= "BD4"
local cMsg    	:= ""
local cCodCri 	:= ""
local lOk     	:= .t.
local aRetRea 	:= {}

nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(cCodUnd) })
if nPos > 0
	nFatMul := iIf( len(aRdas[nPos]) >= 10, iIf(aRdas[nPos,10] <> "0", nFatMul, 1) , nFatMul )
endIf	

if nFatMul > 0
	
	lOk := .t.
	
	aadd(aRetRea, { 0, cAlias, 0, 0, 0, nFatMul, "", 0, 0, "0", '0', 0, 0, 0, 0 })

else

	lOk := .f.
	
	PLSPOSGLO( PLSINTPAD() , __aCdCri238[1] , __aCdCri238[2] )
	cCodCri := __aCdCri238[1]
	cMsg    := cCodCri +" - "+ PLSBCTDESC()

	aadd(aRetRea, { 0, "", 0, 0, 0, 0, "", 0, 0, "0", '0', 0, 0, 0, 0 } )

endIf

return( { lOK, cMsg, cCodCri, aRetRea } )

/*/{Protheus.doc} PLSRETTAUX
Retorna a tabela de auxiliarea para uma TDE. 

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETTAUX(paramixb)
local nRef			:= paramixb[2]
local aRet			:= paramixb[3] 
local cCodInt		:= paramixb[6]
local cCodTab		:= paramixb[8]
local nFatMul		:= paramixb[20]
local lCobCoPart	:= paramixb[25]
local nPrPrRl  		:= paramixb[27] 
local cCodUnd		:= paramixb[35]
local aVlBloq		:= paramixb[42]

local nValorHM		:= 0
local nVlrAux		:= 0
local nVlrAuxCal	:= 0
local nInd			:= 0
local nFor			:= 0
local nDecREF		:= iIf( ! lCobCoPart, PLGetDec('BD7_REFTDE'), PLGetDec('BD7_RFTDEC'))
local nDecCOF		:= iIf( ! lCobCoPart, PLGetDec('BD7_COEFUT'), PLGetDec('BD7_COEFPF'))
local nDecBAS		:= iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'), PLGetDec('BD7_VLRBPF'))
local cAlias		:= ""
local cMsg			:= ""
local cCodCri		:= ""
local cDataCom		:= ""
local cMVPLCAAua	:= getNewPar("MV_PLCAAUA","1") //Determina o tipo de calculo para os auxiliares anestesistas. 	1-por unidade de saúde configurado. 2-pelo total de procedimentos executados.
local cMVPLCAAux	:= getNewPar("MV_PLCAAUX","1") //Determina o tipo de calculo para os auxiliares médicos. 		1-por unidade de saúde configurado. 2-pelo total de procedimentos executados.
local lMVPLINAUA	:= getNewPar("MV_PLINAUA",.f.) //Determina a regra que permite a inclusão e configuração de mais de um Auxiliar Anestesista.
local cMV_PLSCAUX	:= getNewPar("MV_PLSCAUX","AUX")
local lOK			:= .f.
local aRetAux		:= {}
local nAuxVlrApr 	:= paramixb[17]

cMeMorial += " Unidade: " + cCodUnd + CRLF + "Função: PLSRETAUX" + CRLF

BP1->(dbSetOrder(1))
if BP1->( msSeek( xFilial("BP1") + cCodInt + cCodTab + cCodUnd ) ) .and. !( cCodUnd == "AUA" .and. ! lMVPLINAUA .and. nRef > 1 )

	while ! BP1->(eof()) .and. BP1->( BP1_FILIAL + BP1_CODINT + BP1_CODTAB + BP1_CODFUN ) == xFilial("BP1") + cCodInt + cCodTab + cCodUnd

		if nRef == BP1->BP1_NUMAUX
			nVlrAux	:= BP1->BP1_PERCAX
		endIf

		if nVlrAux > 0 
			lOK		:= .t.
			cAlias	:= "BP1"
			cMeMorial += " Percentual: " + alltrim(str(nVlrAux)) + CRLF
			exit
		endIf

	BP1->(dbSkip())
	endDo
   
endIf

if lOK
        
	for nInd := 1 to len(aRet)
      	
		// Se for Aux Anestesista e configurado "2" via parametro, calculo pelo total de procedimentos executados.
		if cCodUnd == "AUA" .and. cMVPLCAAua == "2"
			
			for nfor := 1 to len(aRet[nInd,5])
			
				if !( allTrim(aRet[nInd,1]) $ cMV_PLSCAUX )
					nValorHM += aRet[nInd,5,nFor,4]
				endIf
				
			next nFor

		// Se for Aux Medico e configurado "2" via parametro, calculo pelo total de procedimentos executados.			
		elseIf cCodUnd == "AUX" .and. cMVPLCAAux $ "2,3"

			for nfor := 1 to len(aRet[nInd,5])
			
				if allTrim(aRet[nInd,1]) $ allTrim( PLSCHMP( cCodUnd ) ) //.or. (cMVPLCAAux == "3" .and. nAuxVlrApr > 0) 
			  		nValorHM += aRet[nInd,5,nFor,4] 
	            endIf
	            
			next nFor
			
		elseIf allTrim(aRet[nInd,1]) $ allTrim( PLSCHMP( cCodUnd ) )
       
			for nfor := 1 to len(aRet[nInd,5])
				nValorHM += aRet[nInd,5,nFor,4]
			next nFor	
					
			exit
			
		endIf
       
	next nInd

	if nValorHM == 0 .and. len(aVlBloq) >= 1
   
		aVlBloq := aClone(aVlBloq)[1]
      
		for nInd := 1 to len(aVlBloq)
      
	   		if allTrim(aVlBloq[nInd,1]) $ allTrim( PLSCHMP( cCodUnd ) )
          
				for nfor := 1 to len(aVlBloq[nInd,5])
				
					if len(aVlBloq[nInd]) >= 17 .and. aVlBloq[nInd,5,nFor,11] == '1' .and. aVlBloq[nInd,17] > 0
				
				   		nValorHM += aVlBloq[nInd,5,nFor,4] / ( 1 + ( aVlBloq[nInd,17] / 100 ) )
				
					else
				
						nValorHM += aVlBloq[nInd,5,nFor,4]
				
					endIf
					
				next nFor
				
        	  	exit
		
			endIf
			
		next nInd
		
	endIf
	
	if nValorHM == 0
		lOk := .f.
	endIf  

endIf

if lOk
	cMeMorial += " Base de cálculo: " + alltrim(str(nValorHM)) + CRLF

 	nVlrAuxCal := ( ( nValorHM * nVlrAux ) / 100 )
	
	cMeMorial += " Valor da unidade: " + alltrim(str(nVlrAuxCal)) + CRLF

	// Aplica percentual de aumento ou redução
	if allTrim(cCodUnd) $ allTrim(cMVPLSUNPR) .and. nPrPrRl <> 0
		nVlrAuxCal := nVlrAuxCal + ( ( nVlrAuxCal * nPrPrRl ) / 100 )
	endIf

	aadd( aRetAux, { round( ( nVlrAux / 100 ) , nDecCOF ), cAlias, round( nValorHM , nDecBAS ), round( nVlrAuxCal, nDecBAS ), round( nVlrAuxCal, nDecBAS ), nFatMul, "% PM", 0, 0, "0", '0', 0, 0, 0, 0 } )

else

	cMeMorial += " Base de cálculo: " + alltrim(str(0)) + CRLF

	PLSPOSGLO( PLSINTPAD() , __aCdCri037[1] , __aCdCri037[2] )
	cCodCri := __aCdCri037[1]
	cMsg    := cCodCri +" - "+ PLSBCTDESC()
   	
 	aadd(aRetAux, { 0, "", 0, 0, 0, 0, "", 0, 0, "0", '0', 0, 0, 0, 0 } )

endIf

//Ponto de Entrada para manipular os valores de AUX                                                          
if existBlock("PLMANIAUX")
	cMeMorial += " Executada regra customizada PLMANIAUX " + CRLF
    aRetAux := execBlock("PLMANIAUX",.f.,.f.,{ aRetAux })
endIf

return( { lOK, cMsg, cCodCri, aRetAux } )

/*/{Protheus.doc} PLSCOMEVE
Busca a composicao do evento da TDE
Retorno da Funcao                                                    
1 => Codigo da unidade de medida de saude                            
2 => Ordem de prioridade da unidade de medida                        
3 => Valor da unidade                                                
4 => Valor medio                                                     
5 => Percentual acima                                                
6 => Expressao ADVPL para calcular o procedimento                    
7 => Unidade de Medida(CH, M2, PA, ...)     
lRetCoC (retorna composicao convertida) - indica se a composicao a ser retornada deve ser a da tabela de conversao

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSCOMEVE(cCodTab,cCodPad,cCodPro,cCodInt,dDatPro,cTipoGuia,lRetCoC,lCobCoPart,cCodRDA,cCodEsp,cSubEsp,;
				   cCodLoc,cOrigem,aPartic,lAneste,aVetTab,lRegPtu,cFinAte,cCodPla)
local aAreaBR8		:= BR8->(getArea())
                         
local aRet        	:= {}
local nfor        	:= 0
local cConsFat    	:= ""
local cConsBd     	:= ""  
local cBloqPag	  	:= ""
local dDatAnalise   := ctod("")                                      
local cConsHES      := ""
local cCodUnmNeg  	:= getNewPar("MV_PLSUNDS","INC")         
local cPLSREGANVE 	:= getNewPar("MV_PLSRADP","1")
local cPorteMed   	:= ""
local aParPtoEnt  	:= {}    
local nValRef	  	:= 0
local cCodAux 	  	:= ""
local cChave      	:= ""
local cConsViA    	:= ""            
local nPos          := 0
local nValRefBDN	:= 0
local nPerPro 		:= 0
local lFoundBDN		:= .f.
local lConsHE		:= .t.
local lBD4Found		:= .f.
local lUnm			:= .f.
local cCodTpa		:= ""
local cCodTiss		:= ""
local cAliasTB    	:= ""	
local aDadUsr		:= PLSGETUSR()
local aRetTab       := {}
local aUnmAUA		:= {}                            
local lMV_PLSCZDP	:= getNewPar("MV_PLSCZDP",.f.)
local cMV_PLSCAUX	:= getNewPar("MV_PLSCAUX","AUX")
local lMVPLPGPAN 	:= getNewPar("MV_PLPGPAN",.f.)
local lUnimeds   	:= getNewPar("MV_PLSUNI","0") == "1"

local cHashCHV		:= ""
local lGHash		:= .f.

default dDatPro    	:= dDataBase
default cTipoGuia  	:= ""
default lRetCoC    	:= .f.
default lAneste     := .f. //	Desativado na versão 9.1 do PTU Batch
default lCobCoPart 	:= .t.
default cCodRDA	   	:= ""
default cCodEsp	   	:= ""
default cSubEsp	   	:= ""
default cCodLoc    	:= ""
default cOrigem    	:= '0'
default aPartic     := {}
default aVetTab		:= {}
default lRegPtu		:= .F.
default cFinAte		:= ""
default cCodPla		:= ""

cCodLoc := subStr(cCodLoc,1,3)

if empty(cCodTab) .and. empty(aVetTab)
	
	if ! empty(cCodRda) .and. BAU->BAU_CODIGO <> cCodRda
		BAU->( dbSetOrder(1))
		BAU->( msSeek(xFilial("BAU") + cCodRda ) )
	endIf	

	aRetTab := PLSRETTAB(cCodPad,cCodPro,dDatPro,cCodInt,cCodRda,cCodEsp,cSubEsp,cCodLoc,;
 					 	 dDatPro,"1",cCodInt,cCodPla,"1","1",nil,;
 					 	 iIf( ! empty(BAU->BAU_TIPPRE),BAU->BAU_TIPPRE,nil),nil,nil,(cTipoGuia=='04'),nil,nil,nil,cFinAte)
 					 
 	cCodTab := aRetTab[3]
 	cAliasTB:= aRetTab[4]
     					 
elseIf ! empty(aVetTab)

	cCodTab 	:= aVetTab[3]
	cAliasTB 	:= aVetTab[4]
	
endIf

cHashCHV := md5( UID_COMEVE + allTrim(cCodTab) + allTrim(cCodPad) + allTrim(cCodPro) + allTrim(cCodInt), 2 )
lGHash	 := PLGetGD(UID_COMEVE, cHashCHV, @aRet)

if ! lGHash
	
	if existBlock("PLSDATAN")
	   cPLSREGANVE := execBlock("PLSDATAN",.f.,.f.,{cTipoGuia,cPLSREGANVE})
	endIf
	
	if cPLSREGANVE == "1" //data do evento
	
	   dDatAnalise := dDatPro
	
	   if empty(dDatPro)
	      dDatAnalise := dDataBase
	   endIf
	   
	//data da mudanca de fase/valorizacao      
	else 
	   dDatAnalise := dDataBase
	endIf   
	
	//Composicao da TDE                                                            
	BD4->(dbSetOrder(1)) //BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+dtos(BD4_VIGINI)
	if BD4->( msSeek(xFilial("BD4") + cCodInt + cCodTab + cCodPad + allTrim(cCodPro) ) )
		   
	   while ! BD4->(eof()) .and. BD4->( BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + allTrim(BD4_CODPRO) ) == xFilial("BD4") + cCodInt + cCodTab + cCodPad + allTrim(cCodPro)
	
			if PLSINTVAL("BD4","BD4_VIGINI","BD4_VIGFIM",dDatAnalise)
			
				lBD4Found := .t.
				
	        	exit
	        	
	     	endIf
	     	
	   BD4->(dbSkip())
	   endDo
	   
	else
		// Esse item se faz necessario devido as Unimeds terem tabelas diferenciandas para medicamentos, materiais e etc.
		//entao é preciso varrer a bd4 para encontrar a composição. 
		If ! BD4->(MsSeek(xFilial("BD4")+cCodInt+cCodTab+cCodPad + AllTrim(cCodPro))) .And. lUnimeds
			
			BD4->(DbSetOrder(2))
			if BD4->(MsSeek(xFilial("BD4") + allTrim(cCodPro)))
				
				While ! BD4->(Eof()) .And. BD4->(BD4_FILIAL+AllTrim(BD4_CODPRO)) == xFilial("BD4")+AllTrim(cCodPro)
					
					If BD4->BD4_CDPADP == cCodPad .And. PLSINTVAL("BD4","BD4_VIGINI","BD4_VIGFIM",dDatAnalise)
						cCodTab 	:= Subs(BD4->BD4_CODTAB,5,3)
						lBD4Found 	:= .t.	
						Exit
					Endif
					
				BD4->(DbSkip())
				endDo
				
			endIf
				
		endIf	
			
	endIf
	
	//Retorna os dados da tabela de conversao.	                                     
	if lBD4Found 
		
		if lRetCoC
		
			//Se existir tabela de conversao pego a composicao da tabela de conversao
			//na verdade eu somente posiciono no procedimento referente na nova tabela
			BF8->(dbSetOrder(1))
			if BF8->(msSeek(xFilial("BF8") + cCodInt + cCodTab)) .and. ! empty(BF8->BF8_TABCON)
	
				BD4->(dbSetOrder(1)) //BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+dtos(BD4_VIGINI)                             
				if BD4->(msSeek(xFilial("BD4") + cCodInt + BF8->BF8_TABCON + cCodPad + cCodPro ) )
					cCodTab := BF8->BF8_TABCON
				endIf
				
	 		endIf
	 		
	 	endIf
	 	
	 	BR8->(dbSetOrder(1))
	    BD3->(dbSetOrder(1))
		BDN->(dbSetOrder(1))
	 	
	   	while ! BD4->(eof()) .and. xFilial("BD4") + cCodInt + cCodTab + cCodPad + allTrim(cCodPro) == BD4->(BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+allTrim(BD4_CODPRO))
	   
	         if (BD4->BD4_CODIGO $ cCodUnmNeg) 
	            BD4->(dbSkip())
	            loop
	         endIf 
	         
			 cCodTpa  := BD4->BD4_CODTPA
	   	 	 cConsFat := BD4->BD4_CONSFT
	   	     
	         //A TDE agora e por vigencia...
	         if PLSINTVAL("BD4","BD4_VIGINI","BD4_VIGFIM",dDatAnalise) .Or. lRegPtu
	
	            if BD3->(msSeek(xFilial("BD3")+BD4->BD4_CODIGO))
	         
				   	if empty(cConsFat)
						cConsFat := BD3->BD3_CONSFT
		           	endIf   
	               
	                cConsBd  := BD3->BD3_CONSBD
	                cBloqPag := BD3->BD3_PAGBLO
	
					//Verifica se a Unidade de Medida Considera Calculo de Horario Especial	
					if !( BD3->BD3_CONSHE == "1" )
						lConsHE := .f.
					else
						lConsHE := .t.
					endIf
				
	                cPorteMed := BD4->BD4_PORMED
	                cConsViA  := BD3->BD3_CONSVA
	               
	               	if BR8->(msSeek(xFilial("BR8")+BD4->(BD4_CDPADP+BD4_CODPRO)))
	               
	                  	cConsHES := BR8->BR8_ADCNOT
	                  
	                  	if BR8->BR8_CONSFT == "0" //Nao e para considerar fat.multiplicacao..
	                    	cConsFat := "0"
	                  	endIf   
	                  	
	               	else
	                  	cConsHES := "0" 
	               	endIf
	               
	               	if cOrigem == '1'
	               
					   	cChaveBDN  := xFilial("BDN") + cCodRda + cCodInt + cCodLoc + cCodEsp + cCodTab + cCodPad + cCodPro + BD4->BD4_CODIGO
	
	 	                if BDN->( msSeek(cChaveBDN) )
	 	                
					      	nValRef	  := BDN->BDN_REF

							//MV_PLSCZDP = Considera Zero na Diferenciacao do Valor do Procedimento.
							lFoundBDN := lMV_PLSCZDP
							
					   	endIf
					   	
			       	endIf       
			       
			       	if nValRef == 0 .and. ! lFoundBDN 
						nValRef 	:= BD4->BD4_VALREF
						lFoundBDN 	:= .f.
			       	endIf
	         		
	                nPerPro := BD4->BD4_PERPRO
	                  
	               	if !( allTrim(BD4->BD4_CODIGO) $ cMV_PLSCAUX )
	               
						aadd( aRet , {	BD4->BD4_CODIGO					,;	//01
										PLSBD3ORDEM(BD3->BD3_ORDEM)		,;	//02
										nValRef							,;	//03
										BD4->BD4_VLMED					,;	//04
										BD4->BD4_PERACI					,;	//05
										BD3->BD3_RDMAKE					,;	//06
										allTrim(BD3->BD3_UNIDAD)		,;	//07
										BD3->BD3_TIPVAL					,;	//08
										cConsFat						,;	//09
										cConsHES						,;	//10
										cConsBd							,;	//11
										cPorteMed						,;	//12
										cBloqPag						,;	//13
										cConsViA						,;	//14
										cCodTab							,;	//15
										cCodTpa							,;	//16
										cCodTiss						,;	//17
										lConsHE							,;	//18 - Validacao da Aplicacao do HE na Unidade de Medida
										nPerPro							,;	//19
										BD4->BD4_VIGINI					,;	//20
										BD4->BD4_VIGFIM                 ,;  //21
										cAliasTB } )                        //22 Especificacao dos elementos do array no cabecalho da funcao
	               
	               	else
	               
	                   nValRefBDN := BD4->BD4_VALREF
	                   
	                   if lFoundBDN
							nValRefBDN := NoRound(nValRef)
	                   endIf
	
	                   // Se a regra para anestesista for para apenas 1 profissional, altera nValRefBDN						
	                   if allTrim(BD4->BD4_CODIGO) == "AUA" .and. !getNewPar("MV_PLINAUA",.f.)
							nValRefBDN := 1
	                   endIf
	
	                   //Se for auxiliar faz 1 lancto de acordo com a qtd...                          
	                   for nfor := 1 to nValRefBDN      
	
		                    //Ajuste para colocar a participacao correta
	                    	if BD4->BD4_CODIGO = "AUX"  
		                        cCodTpa := allTrim( strZero(nFor, 2) )
		                    endIf 
	                       
							aadd( aRet , {	BD4->BD4_CODIGO					,;//01
											PLSBD3ORDEM(BD3->BD3_ORDEM)		,;//02
											nFor							,;//03
											BD4->BD4_VLMED					,;//04
											BD4->BD4_PERACI					,;//05
											BD3->BD3_RDMAKE					,;//06
											allTrim(BD3->BD3_UNIDAD)		,;//07
											BD3->BD3_TIPVAL					,;//08
											cConsFat						,;//09
											cConsHES						,;//10
											cConsBd							,;//11
											cPorteMed						,;//12
											cBloqPag						,;//13
											cConsViA						,;//14
											cCodTab							,;//15
											cCodTpa							,;//16
											cCodTiss						,;//17
											lConsHE							,;//18 - Validacao da Aplicacao do HE na Unidade de Medida
											nPerPro							,;//19
											BD4->BD4_VIGINI					,;//20
											BD4->BD4_VIGFIM					,;//21
											cAliasTB } ) 					  //22 - Especificacao dos elementos do array no cabecalho da funcao
		               next
		               
					   nValRefBDN := 0 
			 		   lFoundBDN  := .f.
			 		   
	               	endIf
	                                  
					aVigAtu := {"BD4",BD4->BD4_VIGINI, BD4->BD4_VIGFIM }
	            endIf
	            
	         endIf   
	         
	   nValRef := 0 
	       
	   BD4->(dbSkip())
	   endDo
	   
	   BR8->(restArea(aAreaBR8))
	   
	endIf
	
	//regra 4 cbhpm - inclui unidade PAP caso nao exista na composicao do evento
	if lMVPLPGPAN .and. len(aPartic) > 0
	
		lUnm := .f.
	
		if valtype(aPartic[1,len(aPartic[1])]) == "A" .and. aScan(aPartic[1,len(aPartic[1])],{|x| x == getNewPar("MV_PLUNMAN","PAP")}) > 0 .or. aScan(aRet,{|x| x[1] == getNewPar("MV_PLUNMAN","PAP")}) > 0
			lUnm := .t.
		endIf
		
		if ! lUnm			
	
			aUnmAUA := PLUNMAUA(cCodInt,cCodTab,getNewPar("MV_PLUNMAN","PAP"),getNewPar("MV_PLSQPOR","3"),dDatPro,len(aRet[1]))
			
			if len(aUnmAUA) > 0
				aadd(aRet,aUnmAUA)
			endIf
			
		endIf	
		
	endIf
	
	//ATENCAO:
	//O aRet retornado deve estar na order do BD4. Se for uma ordem diferente do BD7, caso
	//ocorra ajuste de valor (arredondamento) o mesmo pode ser feito em unidade diferente 
	//podendo ocorrer da base da coparticipacao ficar diferente.
	//Coloca os componentes do Evento em ordem de prioridade
	aRet := aSort(aRet,,,{|x,y| x[2] < y[2]})
	
	//Ponto de entrada para manipular regras da composicao do evento 
	if existBlock("PLSCOMEV")
	   aParPtoEnt 	:= {aRet,cCodTab,cCodPad,cCodPro,dDatPro,cCodRDA,cTipoGuia,aPartic}
	   aRet       	:= execBlock("PLSCOMEV",.f.,.f.,aParPtoEnt)
	endIf
	
	PLSetGD(UID_COMEVE, cHashCHV, aRet)
	
endIf

return(aRet)

/*/{Protheus.doc} PLSRETTAB
Busca a tabela de pagamento de uma rda
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETTAB(cCodPad,cCodPro,dDatAnalise,cCodInt,cCodRDA,cCodEsp,cSubEsp,cCodLoc,;
				   dDatPro,cTipo,cOpeOri,cCodProduto,cModExec,cAcao,aDadUsr,cTipPre,;
				   cRegPag,cRegCob,lReembolso,cUFAte,cMunAte,cRegAte,cFinAte,lObsoleto,lweb,;
				   cTipAte,cCodEmp,cAno,cMes)
local cCodTab 	 	:= ""
local lOk     	 	:= .t.
local cMsg    	 	:= ""
local cAlias  	 	:= ""
local cCodCri 	 	:= ""
local aRetFun		:= {}
local lInterc    	:= .f.
local cCodOpeInt 	:= ""
local aRetInt    	:= {}
local cREGGOP    	:= ""
local cGRUOPE    	:= ""
local nNiveis    	:= 0
local nForBE9    	:= 1
local nForBC0	 	:= 1
local cCodAux    	:= ""
local aOrdensNiv 	:= {} 
local nFor		 	:= 0
local __XaRetTabPre	:= {.f.,{}}
local cTabPre 	 	:= ""
local cSlvTab 	 	:= ""
local cSlvAli	 	:= ""
local lTabEsp 	 	:= .f.
local nTab		 	:= 0
local aTabs		 	:= {}
local nBmb		 	:= 0
local aCodTab    	:= {}
local aRtTab		:= {}
local lFoundBB8		:= .f.
local aVigAtu		:= {}	
local cCodPla    	:= ""
local cNameBE9		:= BE9->(retSqlName("BE9"))
local cNameBC0		:= BC0->(retSqlName("BC0"))
local lPLBC0SQL     := existBlock("PLBC0SQL")
local lCobCoPart    := .f.
Local lTipAte		:= BGH->( FieldPos("BGH_TIPATE") ) > 0

default cOpeOri    	:= PLSINTPAD()
default cTipo      	:= "1" //1 Pagar 2 Receber
default cCodProduto	:= ""
default dDatPro    	:= dDatAnalise
default cModExec   	:= "1"
default cAcao      	:= "1"
default aDadUsr    	:= {}                    
default cTipPre    	:= ""                    
default cRegPag		:= ""
default cRegCob		:= ""
default lReembolso 	:= .f.
default cUFAte     	:= ""
default cMunAte    	:= ""
default cRegAte		:= ""
default cFinAte		:= ""
default lObsoleto	:= .f.
default lWeb		:= .f.
default cTipAte   	:= ""
default cCodEmp     := ""  
default cAno        := ""
default cMes        := ""

BMB->(dbSetOrder(1))

// Monta matriz de apoio __aNiveis...
if __cCdTbPd <> cCodPad .or. len(__aNiveis) == 0
	__cCdTbPd := cCodPad
	__aNiveis := PLSESPNIV(cCodPad)
endIf
	
nNiveis := (__aNiveis[1]+1)

if len(aDadUsr) == 0
	aDadUsr := PlsGetUsr()
endIf    

if empty(cRegAte) .and. len(aDadUsr) > 0 .and. aDadUsr[1]
	cRegAte := iIf( len(aDadUsr) >= 92 , aDadUsr[92], cRegAte )
endIf	

cCodLoc := subStr(cCodLoc,1,3)
cCodPla := iIf( len(aDadUsr) >= 11,aDadUsr[11], "")

if existBlock("PLSFIATE")
	cFinAte := execBlock("PLSFIATE",.f.,.f.,{cFinAte})
endIf

BB8->(dbSetOrder(1))
lFoundBB8 := SeekBB8E(cCodRDA,cCodInt,cCodLoc)

if lFoundBB8
	cUFAte	:= iIf(empty(cUFAte),BB8->BB8_EST,cUFAte)
	cMunAte := iIf(empty(cMunAte),BB8->BB8_CODMUN,cMunAte)
endIf

//Se for reembolso busco as tabelas para reembolso	 
if lReembolso

	//Ordem de pesquisa:
	//Municipio         
	//Estado     
	//Tabela de vinculo TDES (B7T) x Operadora        
	//Operadora
	aOrdensNiv := { "B13", "B12", "B7T", "BA0" }
	
	//Este P.E. permite alterar a ordem de pesquisa.
	
	if existBlock("PLSTABPA")
		aOrdensNiv := execBlock("PLSTABPA",.f.,.f.,{aOrdensNiv,lReembolso})                                         
	endIf
	
	// Realiza a busca
	for nfor := 1 to len(aOrdensNiv)
		
		if aOrdensNiv[nFor] == "B13" .and. empty(cCodTab)
		
			// Verifico pelo campo de Estado e Municipio de Atendimento	    
			if !empty(cUFAte) .and. !empty(cMunAte)
			
				// Depois localiza o municipio com vigencia ativa.
				B13->(dbSetOrder(1)) //B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN+B13_CODTAB+B13_SEQUEN
				if B13->(msSeek(xFilial("B13")+cCodInt+cUFAte+cMunAte))
				
					while !B13->( eof() ) .and. B13->(B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN) == xFilial("B13")+cCodInt+cUFAte+cMunAte
													
						if PLSINTVAL("B13","B13_VIGDE","B13_VIGATE",dDatAnalise)
											
							if ! empty(B13->B13_CODTAB)
							
								if PLCHRETB(cCodPro, B13->B13_CODTAB)
									
									cCodTab := subStr(B13->B13_CODTAB,5,3)
									
								endIf
								
							else
							
								// Trata amarração com a nova tabela de preço.
								if empty(cCodTab) .and. ! empty(B13->B13_TABPRE)
								
									__XaRetTabPre := PLVLTBPR(B13->B13_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B13',cCodEsp,nil, lCobCoPart)
									
									if __XaRetTabPre[1]
										
										cCodTab := __XaRetTabPre[2][7]
										
										if empty(cCodTab) .or. ! PLCHRETB(cCodPro, cCodTab)
											
											cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
												
										endIf
										
									endIf
									
								endIf
								
							endIf
							
							if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, B13->B13_VIGDE, B13->B13_VIGATE)
								exit
							endIf
							
						endIf
						
					B13->( dbSkip() )
					endDo
					
				endIf
									
			endIf
			
		elseIf aOrdensNiv[nFor] == "B12" .and. empty(cCodTab)
		
			if ! empty(cUFAte)
			
				B12->(dbSetOrder(1)) //B12_FILIAL, B12_CODINT, B12_CODEST
				if B12->(msSeek(xFilial("B12")+cCodInt+cUFAte)) //cTabPes
			
					while !B12->( eof() ) .and. B12->(B12_FILIAL+B12_CODINT+B12_CODEST) == xFilial("B12")+cCodInt+cUFAte
			
						if PLSINTVAL("B12","B12_VIGDE","B12_VIGATE",dDatAnalise)					
			
							if ! empty(B12->B12_CODTAB)
			
								if PLCHRETB(cCodPro, B12->B12_CODTAB)
									
									cCodTab := subStr(B12->B12_CODTAB,5,3)
									
								endIf
								
							elseIf empty(cCodTab) .and. ! empty(B12->B12_TABPRE)
								
								__XaRetTabPre := PLVLTBPR(B12->B12_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B12',cCodEsp,nil, lCobCoPart)
								
								if __XaRetTabPre[1]
									
									cCodTab := __XaRetTabPre[2][7]
									
									if empty(cCodTab) .or. ! PLCHRETB(cCodPro, cCodTab)
										
										cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
											
									endIf
									
								endIf
								
							endIf
							
							if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, B12->B12_VIGDE, B12->B12_VIGATE)
								exit
							endIf
							
						endIf
						
					B12->( dbSkip() )
					endDo
					
				endIf
			endIf
			
		elseIf aOrdensNiv[nFor] == "BA0" .and. empty(cCodTab)
		
			BA0->(dbSetOrder(1))
			if BA0->(msSeek(xFilial("BA0")+cCodInt)) .and. ! empty(BA0->BA0_TBRFRE)
				
				if PLCHRETB(cCodPro, cCodInt + BA0->BA0_TBRFRE)

					cCodTab := BA0->BA0_TBRFRE
					
				endIf
				
				PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu)
				
			endIf
			
		elseIf  aOrdensNiv[nFor] == "B7T" .and. empty(cCodTab)
		
			B7T->(dbSetOrder(1))
			if B7T->(msSeek(xFilial("B7T") + cCodInt + cCodPad))
			
				while B7T->(!eof()) .and. xFilial("B7T")+cCodInt+cCodPad == B7T->(B7T_FILIAL+B7T_CODINT+B7T_CODPAD)
				
					if ! empty(B7T->B7T_TABREE)
				
						if PLCHRETB(cCodPro, cCodInt + B7T->B7T_TABREE)
				
							cCodTab := B7T->B7T_TABREE
							
						endIf
						
						if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu)
							exit
						endIf
											
					endIf
					
				B7T->(dbSkip())
				endDo
				
			endIf
			
		endIf 
		
		if ! empty(cCodTab)
			exit
		endIf
		
	next
	
else
			
	if empty(cCodTab)

	//Ordem de pesquisa: 
	//Vigencias do Grupo Operadora 
	//Loc. de Atend. X Espec. X Produto X Proced. 
	//local de Atendimento X Especialidade X Produto
	//Loc. de Atend. X Espec. X Proc. Aut. 
	//local de Atendimento 
	//Operad x Tp Prest x Pagto 
	//RDA x Tabelas de Preços 
	//RDA x Local x Tabela de Preþos 
	//Operadora x Tdes Pagto e Recto 
	//RDA X Planos 
	//Rda X Tabela de Preço 
	//Estado X Municipio X TDE 
	//Estado X TDE 
	//Operadora x Tdes Pagto e Recto
	//Operadoras de Saúde 
	
	aOrdensNiv := { "BGH", "BE9", "BBI", "BC0", "BB8", "BMB", "BC5", "B24", "B30", "B29", "B13", "B12", "B85", "BH0", "BA0" }
		
		//* = Permite Parametrização de tabela de valorização
		//Este P.E. permite alterar a ordem de pesquisa.
		if existBlock("PLSTABPA")
			aOrdensNiv := execBlock("PLSTABPA",.f.,.f.,{aOrdensNiv,lReembolso,lObsoleto})
		endIf
		
		if len(aDadUsr) == 0
			aDadUsr := PlsGetUsr()
		endIf	
		
		if len(aDadUsr) >= 45
			cOpeOri := aDadUsr[45]     
		endIf
	
		aRetInt    := PLINTERC(cTipo,cCodRda,cOpeOri,cRegPag,cRegCob)
		lInterc    := aRetInt[1]
		cCodOpeInt := aRetInt[2]
	
		// Realiza a busca
		for nfor := 1 to len(aOrdensNiv)    
			
			if aOrdensNiv[nFor] == "BGH" .and. empty(cCodTab)	
				
				if len(aDadUsr) >= 63
					cREGGOP := aDadUsr[63]
					cGRUOPE := aDadUsr[64]
				endIf
				
				//Verifica se e intercambio atraves de rotina generica
				//Se for intercambio pega do grupo de operadora...
				
				if lInterc .or. cREGGOP == "1"
				
					if ! empty(cCodOpeInt) .and. BA0->(BA0_CODIDE+BA0_CODINT) <> cCodOpeInt
						BA0->(dbSetOrder(1))
						BA0->(msSeek(xFilial("BA0")+cCodOpeInt))
					endIf
			
					if cTipo == "1" .OR. cREGGOP <> "1"
						cGRUOPE := BA0->BA0_GRUOPE
					endIf   

					cPlsCpea 	:= getnewPar("MV_PLSCPEA", "" )

					cSql := " SELECT BGH.R_E_C_N_O_ RECNO"
					If lTipAte
						cSql += " ,CASE WHEN BGH_TIPATE = ' ' THEN '3' ELSE BGH_TIPATE END TIPATE "
					endIf
					cSql += " FROM "+retSqlName("BGH")+" BGH "   
					cSql += " INNER JOIN "+retSqlName("BD4")+" BD4  "
					cSql += " ON BD4_FILIAL = '"+xFilial("BD4")+"' "

					if cTipo == "1"
						cSql +="   AND SUBSTRING(BD4_CODTAB,5,3) = BGH_TABPAG "
					elseIf cTipo == "2"
						cSql +="   AND SUBSTRING(BD4_CODTAB,5,3) = BGH_TABREC  "
					endif
					
					cSql +="   AND BD4_CDPADP = '"+cCodPad+"' "
					cSql +="   AND BD4_CODPRO = '"+cCodPro+"' "
					cSql +="   AND BD4.D_E_L_E_T_ = ' ' "

					cSql +="  WHERE BGH_FILIAL = '"+xFilial("BGH")+"' "
					cSql +=" 	AND BGH_GRUOPE = '"+cGRUOPE+"' "
					
					If lTipAte
						cSql += " AND BGH_TIPATE IN ('3', ' ', '" + cRegAte + "' ) "
					endIf

					if cTipo == "1" 
						cSql +=" 	AND BGH_TABPAG <> ' ' "
					elseIf cTipo == "2" 
						cSql +=" 	AND BGH_TABREC <> ' ' "
					endif   
					cSql +=" 	AND ( '" +dtos(dDatAnalise) + "' >= BGH_DATINI ) AND ( '" +dtos(dDatAnalise) + "' <= BGH_DATFIN OR BGH_DATFIN = '        ' )  "
					cSql +=" 	AND BGH.D_E_L_E_T_ =  ' '  "

					If lTipAte
						cSql += " Order By TIPATE "
					endIf

					cSql := PLSConSQL(cSql)
					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"RETTAB",.f.,.t.)

					while ! RETTAB->(eof())

						BGH->(dbgoto(RETTAB->RECNO))
				
						if cTipo == "1" .and. lInterc
							
							cCodTab := BGH->BGH_TABPAG
							
						elseIf cTipo == "2" .and. (cOpeOri <> PLSINTPAD() .OR. subStr(aDadUsr[2], 5, 4) == cPlsCpea ) 
							
							cCodTab := BGH->BGH_TABREC
							
						endIf
		
						if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, BGH->BGH_DATINI, BGH->BGH_DATFIN)
							exit
						endIf
							
						RETTAB->(dbSkip())
					endDo

					RETTAB->(dbCloseArea())
				endIf    
						
			elseIf aOrdensNiv[nFor] == "BE9" .and. empty(cCodTab)
				
				//Verifico no nivel de Loc. de Atend. X Espec. X Produto X Proced.     
				cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBE9 + " WHERE "
				cSQL += "BE9_FILIAL = '" + xFilial("BE9") + "' AND "
				cSQL += "BE9_CODIGO = '" + cCodRDA + "' AND "
				cSQL += "BE9_CODINT = '" + cCodInt + "' AND "
				cSQL += "BE9_CODLOC = '" + cCodLoc + "' AND "
				cSQL += "BE9_CODESP = '" + cCodEsp  + "' AND "
				cSQL += "BE9_CODPLA = '" + cCodProduto + "' AND "
				cSQL += "BE9_CODPAD = '" + cCodPad + "' AND "
				cSQL += "BE9_CODTAB <> ' ' AND "
				
				cSQL += PLREQNI("BE9", "BE9_CODPRO", __aNiveis[2], cCodPro)
				
				cSQL += "( '" + dtos(dDatAnalise) + "' >= BE9_VIGDE  OR BE9_VIGDE  = ' ' ) AND "
				cSQL += "( '" + dtos(dDatAnalise) + "' <= BE9_VIGATE OR BE9_VIGATE = ' ' ) AND "
				
				cSQL +=  cNameBE9 + ".D_E_L_E_T_ = ' ' "
				
				cSQL +=  " ORDER BY BE9_NIVEL DESC "
				
				dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSAUTPDIR",.f.,.t.)

				if ! PLSAUTPDIR->(eof())
				
					BE9->(dbGoTo(PLSAUTPDIR->(REC)))
					
					cCodTab := BE9->BE9_CODTAB
					
					PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, BE9->BE9_VIGDE, BE9->BE9_VIGATE)
					
				endIf
				
				PLSAUTPDIR->(dbCloseArea())
			
			elseIf aOrdensNiv[nFor] == "BBI" .and. empty(cCodTab) // testado - ok.

				BBI->(dbSetOrder(1))
				if BBI->(msSeek(xFilial("BBI")+cCodRDA+cCodInt+cCodLoc+cCodEsp+cCodProduto))
	
					while !BBI->( eof() ) .and. BBI->BBI_CODIGO+BBI->BBI_CODINT+BBI->BBI_CODLOC+BBI->BBI_CODESP+BBI->BBI_CODPRO == cCodRDA+cCodInt+cCodLoc+cCodEsp+cCodProduto
					
						// Faz a analize da vigencia.
						if BBI->BBI_ATIVO <> "0" .and. PLSINTVAL("BBI","BBI_VIGDE","BBI_VIGATE",dDatAnalise)
						
							if ! empty(BBI->BBI_CODTAB)
							
								cCodTab := subStr(BBI->BBI_CODTAB,5,3)
								
							else
								
								// Trata amarração com a nova tabela de preço.
								if empty(cCodTab) .and. !empty(BBI->BBI_TABPRE)

									__XaRetTabPre := PLVLTBPR(BBI->BBI_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BBI',cCodEsp,nil, lCobCoPart)
									
									if __XaRetTabPre[1]
									
										cCodTab := __XaRetTabPre[2][7]
										
										if empty(cCodTab)
											cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
										endIf
										
									endIf
									
								endIf
								
							endIf
							
							if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, BBI->BBI_VIGDE, BBI->BBI_VIGATE)
								exit
							endIf	
							
						endIf
						
					BBI->( dbSkip() )
					endDo
					
				endIf
				
			elseIf aOrdensNiv[nFor] == "BC0" .and. empty(cCodTab)

				//Verifico no nivel de Loc. de Atend. X Espec. X Proc. Aut.     		 
				cSQL := "SELECT BC0_CODTAB,BC0_BANDA,BC0_VALREA,BC0_PERDES,BC0_NIVEL,BC0_FORMUL,BC0_VALCH,BC0_EXPRES,BC0_VIGDE,BC0_VIGATE FROM " + cNameBC0 + " WHERE "
				cSQL += "BC0_FILIAL = '" + xFilial("BC0") + "' AND "
				cSQL += "BC0_CODIGO = '" + cCodRDA + "' AND "
				cSQL += "BC0_CODINT = '" + cCodInt + "' AND "
				cSQL += "BC0_CODLOC = '" + cCodLoc + "' AND "
				cSQL += "BC0_CODESP = '" + cCodEsp  + "' AND "
				cSQL += "BC0_CODPAD = '" + cCodPad + "' AND "
				cSQL += "BC0_CODTAB <> ' ' AND "
				
				cSQL += PLREQNI("BC0", "BC0_CODOPC", __aNiveis[2], allTrim(cCodPro))
				
				cSQL += "( '" + dtos(dDatAnalise) + "' >= BC0_VIGDE  OR BC0_VIGDE  = ' ' ) AND "
				cSQL += "( '" + dtos(dDatAnalise) + "' <= BC0_VIGATE OR BC0_VIGATE = ' ' ) AND "
				cSQL += "( BC0_DATBLO = ' ' OR BC0_DATBLO > '" + dtos(dDatAnalise) + "' ) AND "
				cSql += "( (BC0_FORMUL = '1' AND (BC0_VALREA > 0 OR BC0_VALCH > 0 OR BC0_BANDA > 0 OR BC0_UCO > 0)) OR "
				cSql += "(BC0_FORMUL = '2' AND BC0_EXPRES <> ' ') ) AND "
				cSQL +=  cNameBC0 + ".D_E_L_E_T_ = ' ' "
				
				cSQL +=  " ORDER BY BC0_NIVEL DESC "
				
				if lPLBC0SQL
					cSQL := execBlock("PLBC0SQL",.f.,.f.,{cSQL,cCodRda,cCodInt,cCodLoc,cCodEsp,cSubEsp,cCodPro,cCodPad})
				endIf
				
				dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSAUTPDIR",.f.,.t.)
				
				if ! PLSAUTPDIR->(eof())
				
					cCodTab := PLSAUTPDIR->BC0_CODTAB
					nBanda  := PLSAUTPDIR->BC0_BANDA

					PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, PLSAUTPDIR->BC0_VIGDE, PLSAUTPDIR->BC0_VIGATE)
				
				endIf
				
				PLSAUTPDIR->(dbCloseArea())
				
			elseIf aOrdensNiv[nFor] == "BB8" .and. empty(cCodTab)

				//Verifico no nivel de local de Atendimento
				if lFoundBB8 .and. ! empty(BB8->BB8_CODTAB)
				
					cCodTab := BB8->BB8_CODTAB
					
					PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu)
					
				endIf
				
			elseIf aOrdensNiv[nFor] == "BMB" .and. empty(cCodTab)
	
				for nBmb := 1 to 2  
					
					// Primeiro tenta achar parametrização para o tipo de prestador corrente.
					// Se não achar, tenta achar parametrização generica.
					if nBmb == 1
						cAuxTipPre := cTipPre
					else
						cAuxTipPre := space(TamSX3("BMB_TIPPRE")[1])
					endIf
					
					if BMB->(msSeek(xFilial("BMB")+cCodInt+cAuxTipPre))
						
						while !BMB->( eof() ) .and. BMB->BMB_CODINT + BMB->BMB_TIPPRE == cCodInt+cAuxTipPre
							
								// Faz a analize da vigencia.					
							if PLSINTVAL("BMB","BMB_VIGDE","BMB_VIGATE",dDatAnalise)
								
								if ! empty(BMB->BMB_CODTAB)
									
									cCodTab := BMB->BMB_CODTAB
									
								elseIf ! empty(BMB->BMB_TABPRE)
										
									__XaRetTabPre := PLVLTBPR(BMB->BMB_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BMB',cCodEsp,nil, lCobCoPart)
									
									if __XaRetTabPre[1]
									
										cCodTab := __XaRetTabPre[2][7]
										
										if empty(cCodTab)
											cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
										endIf
										
									endIf
										
								endIf
								
								if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, BMB->BMB_VIGDE, BMB->BMB_VIGATE)
									exit
								endIf
									
							endIf
							
						BMB->( dbSkip() )
						endDo
						
					endIf
					
					if !empty(cCodTab) 
						exit
					endIf
				next
				
			elseIf aOrdensNiv[nFor] == "BH0" .and. empty(cCodTab)
				
				BH0->(dbSetOrder(1))
				
				if BH0->(msSeek(xFilial("BH0")+cCodInt+cCodPad))
				
					while ! BH0->(eof()) .and. xFilial("BH0")+cCodInt+cCodPad == BH0->(BH0_FILIAL+BH0_CODINT+BH0_CODPAD) 				

						if cTipo == "1"
							cCodTab := BH0->BH0_TABPAG
						else
							cCodTab := BH0->BH0_TABREC
						endIf
						
						// Verificacao necessaria pois na importacao do PTU a rotina pega uma tabela errada caso nao tenha composicao na tabela da BGH
						BD4->(dbSetOrder(1)) //BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+dtos(BD4_VIGINI)
						if !BD4->( msSeek(xFilial("BD4") + cCodInt + cCodTab + cCodPad + allTrim(cCodPro) ) )
							cCodTab := ""
						endif
						
						if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu)
							exit
						endIf
						
					BH0->(dbSkip())
					endDo
					
				endIf
				
			elseIf aOrdensNiv[nFor] == "BA0" .and. empty(cCodTab)
			
				BA0->(dbSetOrder(1))
				if BA0->(msSeek(xFilial("BA0")+cCodInt)) .and. ! empty(BA0->BA0_CODTAB)
				
					cCodTab := BA0->BA0_CODTAB
					
					PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu)
					
				endIf
				
			elseIf aOrdensNiv[nFor] == "B12" .and. empty(cCodTab)
				
				// Verifico pelo campo de Estado de Atendimento
				if !empty(cUFAte)
				
					B12->(dbSetOrder(1)) //B12_FILIAL, B12_CODINT, B12_CODEST
					if B12->(msSeek(xFilial("B12")+cCodInt+cUFAte))
						
						while !B12->( eof() ) .and. B12->(B12_FILIAL+B12_CODINT+B12_CODEST) == xFilial("B12")+cCodInt+cUFAte
						
							if PLSINTVAL("B12","B12_VIGDE","B12_VIGATE",dDatAnalise)									
								
								if ! empty(B12->B12_CODTAB)
								
									cCodTab := subStr(B12->B12_CODTAB,5,3)
									
								elseIf ! empty(B12->B12_TABPRE)
										
									__XaRetTabPre := PLVLTBPR(B12->B12_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B12',cCodEsp,nil, lCobCoPart)                  
									
									if __XaRetTabPre[1]
									
										cCodTab := __XaRetTabPre[2][7]
										
										if empty(cCodTab)
											cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
										endIf
										
									endIf
									
								endIf
		
								if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, B12->B12_VIGDE, B12->B12_VIGATE)
									exit
								endIf
								
							endIf   
							
						B12->( dbSkip() )
						endDo
						
					endIf
					
				endIf
				
			elseIf aOrdensNiv[nFor] == "B13" .and. empty(cCodTab)
				
				// Verifico pelo campo de Estado e Municipio de Atendimento	    
				if !empty(cUFAte) .and. !empty(cMunAte)
				
					// Depois localiza o municipio com vigencia ativa.
					B13->(dbSetOrder(1)) //B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN+B13_CODTAB+B13_SEQUEN
					
					if B13->(msSeek(xFilial("B13")+cCodInt+cUFAte+cMunAte))
					
						while !B13->( eof() ) .and. B13->(B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN) == xFilial("B13")+cCodInt+cUFAte+cMunAte
														
							if PLSINTVAL("B13","B13_VIGDE","B13_VIGATE",dDatAnalise)								
								
								if ! empty(B13->B13_CODTAB)
									
									cCodTab := subStr(B13->B13_CODTAB,5,3)
									
								elseIf ! empty(B13->B13_TABPRE)
										
									__XaRetTabPre := PLVLTBPR(B13->B13_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B13',cCodEsp,nil, lCobCoPart)
									
									if __XaRetTabPre[1]
									
										cCodTab := __XaRetTabPre[2][7]
										
										if empty(cCodTab)
											cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
										endIf
										
									endIf
									
								endIf
					
								if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, B13->B13_VIGDE, B13->B13_VIGATE)
									exit
								endIf
											
							endIf
							
						B13->( dbSkip() )
						endDo
						
					endIf
					
					if ! empty(cCodTab)
						exit
					endIf
					
				endIf	
								
			elseIf aOrdensNiv[nFor] == "B30" .and. empty(cCodTab)

				//Verifico no nivel de local de Atendimento X Especialidade X Produto
				B30->(dbSetOrder(1))
				if B30->(msSeek(xFilial("B30")+cCodRDA+cCodInt+cCodProduto))
				
					while !B30->( eof() ) .and. B30->B30_CODIGO+B30->B30_CODINT+B30->B30_CODPRO == cCodRDA+cCodInt+cCodProduto
					
						// Faz a analize da vigencia.					
						if PLSINTVAL("B30","B30_VIGDE","B30_VIGATE",dDatAnalise)
							
							if ! empty(B30->B30_CODTAB)
							
								cCodTab := subStr(B30->B30_CODTAB,5,3)
								
							elseIf ! empty(B30->B30_TABPRE)
									
								__XaRetTabPre := PLVLTBPR(B30->B30_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B30',cCodEsp,nil, lCobCoPart)
								
								if __XaRetTabPre[1]
								
									cCodTab := __XaRetTabPre[2][7]
									
									if empty(cCodTab)
										cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
									endIf
									
								endIf
									
							endIf
							
							if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, B30->B30_VIGDE, B30->B30_VIGATE)
								exit
							endIf
							
						endIf
						
					B30->( dbSkip() )
					endDo
						
				endIf
				
			elseIf aOrdensNiv[nFor] == "BC5" .and. empty(cCodTab)
				
				// Redefine as variaveis de controle
				cTabPre := ""
				lTabEsp := .f.
				
				// Verifica se existe tabela de preço no local de atendimento. Esse codigo se refere a tabela de preço X RDA BC5.
				if  lFoundBB8 .and. ! empty(BB8->BB8_TABPRE)
					cTabPre := BB8->BB8_TABPRE
					lTabEsp := .t.
				endIf
				
				// Verifica se existe tabela de preço especifica para esta RDA.
				cSql := " SELECT BC5.R_E_C_N_O_ RECNO "
				cSql += "   FROM "+retSqlName("BC5")+" BC5 "
				cSql += "  WHERE BC5_FILIAL = '" + xFilial("BC5") + "' "
				cSql += "    AND BC5_CODINT = '" + cCodInt + "' "
				cSql += "    AND BC5_CODRDA = '" + cCodRda + "' "
				cSql += "    AND BC5_TABPRE = '" + cTabPre + "' "
				cSql += "    AND ( '" +dtos(dDatAnalise) + "' >= BC5_DATINI ) AND ( '" +dtos(dDatAnalise) + "' <= BC5_DATFIM OR BC5_DATFIM = '        ' ) "
				cSql += "    AND D_E_L_E_T_ =  ' ' "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"RETTAB",.f.,.t.) 

				// Processa as vigencias.
				while ! RETTAB->(eof())
					
					BC5->(dbgoto(RETTAB->RECNO))

					if ( lTabEsp .and. cTabPre == BC5->BC5_TABPRE ) .or. ( ! lTabEsp )
					
						if ! empty(BC5->BC5_TABPRE)
							
							__XaRetTabPre := PLVLTBPR(BC5->BC5_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BC5',cCodEsp,nil, lCobCoPart)
							
							if __XaRetTabPre[1]
							
								cCodTab	:= __XaRetTabPre[2][7]
								
								if empty(cCodTab)
									cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
								endIf
								
							endIf

							if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, BC5->BC5_DATINI, BC5->BC5_DATFIM)
								exit
							endIf
							
						endIf						
						
					endif
				
					RETTAB->( dbSkip() )
				enddo
			
				RETTAB->(dbCloseArea())
				
			elseIf aOrdensNiv[nFor] == "B24" .and. empty(cCodTab)
				
				// Obtem as tabelas de preço disponiveis para este prestador na tabela B24 - Somente as que estiveram com vigencia em aberto.
				aTabs := aClone(SeekB24(cCodRDA,cCodInt,cCodLoc,dDatAnalise))
				
				// Processa todas as tabelas de preço do prestador.
				for nTab := 1 to len(aTabs)
				
					if ! empty(aTabs[nTab])
						
						__XaRetTabPre := PLVLTBPR(aTabs[nTab],cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B24',cCodEsp,nil, lCobCoPart)
						
						if __XaRetTabPre[1]
						
							cCodTab := __XaRetTabPre[2][7]
							
							if empty(cCodTab)
								cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
							endIf
							
						endIf
						
						if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, B24->B24_VIGINI, B24->B24_VIGFIN)
							exit
						endIf
						
					endIf
					
				next
					
			elseIf aOrdensNiv[nFor] == "B29" .and. empty(cCodTab)
				
				// Obtem as tabelas de preço disponiveis para este prestador na tabela B24 - Somente as que estiveram com vigencia em aberto.
				B29->(dbSetOrder(1))
				if B29->(msSeek(xFilial("B29")+cCodRDA+cCodInt))
				
					while !B29->( eof() ) .and. B29->(B29_CODIGO+B29_CODINT) == cCodRDA+cCodInt
					
						if PLSINTVAL("B29","B29_VIGINI","B29_VIGFIN",dDatAnalise)
	
							if ! empty(B29->B29_TABPRE)
								
								__XaRetTabPre := PLVLTBPR(B29->B29_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B29',cCodEsp,nil, lCobCoPart)
								
								if __XaRetTabPre[1]
								
									cCodTab := __XaRetTabPre[2][7]
									
									if empty(cCodTab)
										cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
									endIf
									
								endIf
								
								if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, B29->B29_VIGINI, B29->B29_VIGFIN)
									exit
								endIf	
								
							endIf
							
						endIf
						
					B29->( dbSkip() )
					endDo
					
				endIf
							
			elseIf aOrdensNiv[nFor] == "B85" .and. empty(cCodTab)
				
				//Verifico no nivel de local de RDA x Associacao.						
				B62->(dbSetOrder(1))
				if B62->( msSeek(xFilial("B62") + cCodRDA + cCodInt))
				
					while ! B62->( eof() ) .and. B62->(B62_CODIGO + B62_CODINT) == cCodRDA + cCodInt
					
						// Faz a analize da vigencia.
						if PLSINTVAL("B62","B62_DTVGIN","B62_DTVGF",dDatAnalise)
					
							B85->( dbSetOrder(01) )
							if B85->( msSeek(xFilial("B85") + B62->B62_ASSCLA) )
					
								while !B85->( eof() ) .and. B85->(B85_CODASS+B85_CLASSE) == B62->B62_ASSCLA
									
									if PLSINTVAL("B85","B85_VIGINI","B85_VIGFIN",dDatAnalise)
										
										if ! empty(B85->B85_TABPRE)
											
											__XaRetTabPre := PLVLTBPR(B85->B85_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B85',cCodEsp,nil, lCobCoPart)
											
											if __XaRetTabPre[1] 
											
												cCodTab := __XaRetTabPre[2][7]
												
												if empty(cCodTab)
													cCodTab := PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
												endIf
												
											endIf
											
											if PLSRTPTP(aOrdensNiv[nFor], cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, B85->B85_VIGINI, B85->B85_VIGFIN)
												exit
											endIf	
											
										endIf
										
									endIf
									
								B85->( dbSkip() )
								endDo
								
								if !empty(cCodTab)
									exit
								endIf
								
							endIf
							
						endIf
						
					B62->( dbSkip() )
					endDo
					
				endIf
				
			endIf
			
			//Verifica se encontrou a Tabela e se o procedimento existe para a tabela encontrada.
			if ! empty(cCodTab)
				
				if PLSVLDBA8(cCodInt,cCodPad,cCodPro,@cCodTab,@cAlias, @lOk,aCodTab,dDatAnalise)
					exit
				endIf
				
			endIf	
			
		next
		
	endIf

	if ! empty(cSlvTab) .and. empty(cCodTab) .and. cTipo == "1"
	
		if ! BD4->(msSeek(xFilial("BD4") + cCodInt + cSlvTab + cCodPad + allTrim(cCodPro)))
		
			BD4->(dbSetOrder(2))
			BD4->(msSeek(xFilial("BD4") + allTrim(cCodPro)))	
			
			while ! BD4->(eof()) .and. BD4->BD4_FILIAL + allTrim(BD4->BD4_CODPRO) == xFilial("BD4") + allTrim(cCodPro)
			
				if BD4->BD4_CDPADP == cCodPad .and. PLSINTVAL("BD4","BD4_VIGINI","BD4_VIGFIM",dDatAnalise)
															
					cCodTab := subStr(BD4->BD4_CODTAB,5,3)
													
					if PLSRTPTP("BD4", cCodTab, @cAlias, @lOk, @cSlvTab, @cSlvAli, @aVigAtu, BD4->BD4_VIGINI, BD4->BD4_VIGFIM)
						exit
					endIf
						
				endIf
				
			BD4->(dbSkip())
			endDo
						
			if ! empty(cCodTab)
				BD4->(dbSetOrder(1))
				BD4->(msSeek(xFilial("BD4")+cCodInt+cCodTab+cCodPad+allTrim(cCodPro)))
			endIf
			
		endIf
			
	endIf
			
endIf

//Favor nao mexer aqui, consultar o daher antes 22/04/2012
//O sistema sempre tem q considerar alguma tabela valida se ela existir, tem q manter o legado da 10
//Pois a funcao que pega a composicao d evento busca outra TDE se o evento nao estiver nela
if ! empty(cSlvTab) .and. empty(cCodTab)
	cCodTab := cSlvTab
	cAlias  := cSlvAli
endIf

if existBlock("PLSRTTAB")

	aRetFun := execBlock("PLSRTTAB",.f.,.f.,{cCodTab,cAlias,cCodPad,cCodPro,dDatAnalise,cCodInt,cCodRDA,cCodEsp,cSubEsp,cCodLoc,;
												dDatPro,cTipo,cOpeOri,cCodProduto,cModExec,cAcao,lReembolso, ctipAte})
	cCodTab := aRetFun[1]
	cAlias  := aRetFun[2]
	
endIf

if empty(cCodTab) .and. !lWeb  
	
	PLSPOSGLO(PLSINTPAD(),__aCdCri059[1],__aCdCri059[2])
	
	cCodCri	:= __aCdCri059[1]
	cMsg		:= cCodCri+" - "+PLSBCTDESC()
	lOk		:= .f.
	
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',cMsg , 0, 0, {})
	
endIf

aRtTab := {lOk,cMsg,cCodTab,cAlias,cCodCri,__XaRetTabPre,aVigAtu}

return(aRtTab)
 
/*/{Protheus.doc} PLSRETUSNV
Retorna a U.S de um prestador e o nivel em que ela se encontra

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETUSNV(paramixb,lPorteAnestesico,lObsoleto,nPorteOri,lBanda)
local nQtd       	:= paramixb[1]
local nRef       	:= paramixb[2]
local dDatAnalise	:= paramixb[4]
local cCodRDA    	:= paramixb[5]
local cCodInt    	:= paramixb[6]         
local cCodEmp    	:= iIf(len(paramixb[19])>0, subStr(paramixb[19,2],atCodEmp[1],atCodEmp[2]), "")
local cCodTab    	:= paramixb[8]
local cCodLoc    	:= subStr(paramixb[7],1,3)
local cCodPad    	:= paramixb[9]
local cCodPro    	:= paramixb[10]
local cMes       	:= paramixb[11]
local cAno       	:= paramixb[12]
local cCodEsp     	:= paramixb[13]
local cSubEsp    	:= paramixb[14]
local cModPag    	:= paramixb[15]
local nVlrApr    	:= paramixb[17]     
local cTipPre    	:= paramixb[18]
local aDadUsr    	:= aClone(paramixb[19])
local cOpeUsr    	:= iIf(len(paramixb[19])>0,subStr(paramixb[19,2],atCodOpe[1],atCodOpe[2]),"")
local cTipoUsr   	:= iIf(len(paramixb[19])>0,paramixb[19,8],"")
local cConEmp    	:= iIf(len(paramixb[19])>0,paramixb[19,9],"")
local cCodPla 		:= iIf(len(paramixb[19])>0,paramixb[19,11],"")
local cVrProduto 	:= iIf(len(paramixb[19])>0,paramixb[19,12],"")
local cVerCon    	:= iIf(len(paramixb[19])>0,paramixb[19,39],"")
local cSubCon    	:= iIf(len(paramixb[19])>0,paramixb[19,41],"")
local cVerSub    	:= iIf(len(paramixb[19])>0,paramixb[19,42],"")
local cOpeOri    	:= iIf(len(paramixb[19])>0,paramixb[19,45],"")
local cREGGOP    	:= iIf(len(paramixb[19])>0,paramixb[19,63],"")
local cGRUOPE    	:= iIf(len(paramixb[19])>0,paramixb[19,64],"")
local nFatMul    	:= paramixb[20]
local cConsFt    	:= paramixb[21]
local nUSEspec   	:= paramixb[22]
local cAlEspec   	:= paramixb[23]
local cCodRDAReal	:= paramixb[24]
local lCobCoPart 	:= paramixb[25] 
local nPrPrRl  		:= paramixb[27] 
local cPadInt    	:= paramixb[29]                                     
local cRegAte  	 	:= paramixb[30]                                     
local aRdas		 	:= paramixb[34]
local cCodUnd    	:= paramixb[35]
local lReembolso 	:= paramixb[36]
local cConsBd   	:= paramixb[38]
local cPorteMed  	:= paramixb[39]
local dDatPro	 	:= paramixb[40]
local cRegPag	 	:= paramixb[44]                                         
local cRegCob	 	:= paramixb[45]                                         
local aPacote	 	:= paramixb[46]
local cFinAte	 	:= paramixb[47]
local cUFAte	 	:= paramixb[48]                                     
local cMunAte	 	:= paramixb[49]
local cRdaEdi       := iIf(len(paramixb) > 49,paramixb[50],"")
local cChvEvento    := iIf(len(paramixb) > 50,paramixb[51],"")

local nNiveis    	:= 0     
local nAliEspec  	:= 0
local nAliAtual  	:= 0
local nForNiv	 	:= 0
local nForBE9    	:= 1      
local nFor       	:= 1
local nR		 	:= 1
local nVlrUS       	:= 0
local nValDef	 	:= 0
local nVlrRea    	:= 0
local nValorPMed 	:= 0
local nBanda     	:= 0
local nDesconto  	:= 0
local nAcrescimo 	:= 0
local nBmb 		 	:= 0
local nTab		 	:= 0
local nRefUS		:= 0
local nDecREF		:= iIf( ! lCobCoPart, PLGetDec('BD7_REFTDE'),PLGetDec('BD7_RFTDEC'))
local nDecCOF		:= iIf( ! lCobCoPart, PLGetDec('BD7_COEFUT'),PLGetDec('BD7_COEFPF'))
local nDecBAS		:= iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'),PLGetDec('BD7_VLRBPF'))
local cNameBC0   	:= BC0->(retSqlName("BC0"))
local cNameBBM   	:= BBM->(retSqlName("BBM"))
local cNameBME   	:= BME->(retSqlName("BME"))
local cNameBMG   	:= BMG->(retSqlName("BMG"))
local cNameBE9	 	:= BE9->(retSqlName("BE9"))
local cNameBMC	 	:= BMC->(retSqlName("BMC"))
local cNameBS0	 	:= BS0->(retSqlName("BS0"))
local cTabPre		:= ""
local cAlias     	:= ""
local cDesUni		:= ""
local cMsg       	:= ""                                                                      
local cCodCri	 	:= ""  
local cOpeInt	 	:= ""
local cChave	 	:= ""
local cCodAux    	:= ""
local cAuxTipPre 	:= ""
local cTabVlr	 	:= ""
local cCodEstAux 	:= ""
local cCodMunAux	:= ""
local cTipo		 	:= iIf( ! lCobCoPart, "1", "2")
local aTabs		 	:= {}
local aNvCopartZ 	:= {}
local aRetTabPre 	:= {}
local aRegs		 	:= {} 
local aRetFun    	:= {}                        
local aOrdensNiv 	:= {}
local aRetAux	 	:= {}           
local aRetPtoEnt 	:= {}
local aRetInt	 	:= {}
local aRetUS     	:= {}                                                                    
local aRETUSNV	 	:= {}
local aVigAtu    	:= {} //array que vai guardar a dataDe e dataAte referemte a vigencia do nivel que achar o valor
local aPlRdaPgt    := {} //Array para retorno do ponto de entrada "PLRDAPGT"
local __XaRetTabPre	:= { .f., {} }
local dVigIni	 	:= ctod("")
local dVigFim	 	:= ctod("")
local lChkNvLoc  	:= (getNewPar("MV_PLSCRLI","0") == "1")
local lOK        	:= .f.
local lCoUSEs    	:= .t.        
local lFoundBE9  	:= .f.  
local lFoundBB8	 	:= .f.                                       
local lContinua  	:= .t.      
local lUndCop	 	:= .f.
local lInterc    	:= .f.
local lPorteMed  	:= ! empty(cPorteMed)
local lCosRefCH     := (getNewPar("MV_PLSPPUS","0") == "1") //Se considera a referencia do CH SIM ou NAO
local lZeraTudo  	:= (getNewPar("MV_PLSGUI0","0") == "1")	// Rever este conceito.
local lMV_PLUSPPM	:= getNewPar("MV_PLUSPPM",.f.) 			// Valora PPM conforme tabela de PRECO Nova considerando US x QtdUS
local lPLSBE9SK     := existBlock("PLSBE9SK")
local lPLESPBC0     := existBlock("PLESPBC0")
local lPLBC0SQL     := existBlock("PLBC0SQL")
local lPLVLBMC      := existBlock("PLVLBMC")
local lPLRDAPGT     := existBlock("PLRDAPGT")
local lPLSFIATE     := existBlock("PLSFIATE")
local lPLSONVPC     := existBlock("PLSONVPC")
local lPLSALTUV     := existBlock("PLSALTUV")
local lPLSVLRPM     := existBlock("PLSVLRPM")
Local lOkAD			:= .F.
Local nMeMorial		:= 0

default nPorteOri		 := 0
default	lPorteAnestesico := .f.                           
default lObsoleto		 := .f.
default lBanda   		 := .f.

if !lBanda
	cMeMorial += " Unidade: " + cCodUnd + CRLF + " Função: PLSRETCH " + CRLF

	cMeMorial += IIF(lPorteMed," Cálculo com base em Porte " + CRLF , " Cálculo com base em valor de US " + CRLF )
else
	cMeMorial += " Banda " + CRLF
endIf
if __cCdTbPd <> cCodPad .or. len(__aNiveis) == 0
	__cCdTbPd := cCodPad
	__aNiveis := PLSESPNIV(cCodPad)
endIf	
nNiveis := (__aNiveis[1]+1)

if lPLSFIATE
   cFinAte := execBlock("PLSFIATE",.f.,.f.,{cFinAte})
endIf

// Tratamento diferenciado para a unidade COP quando for valorizado pela tabela de preço.
// A valorização desta unidade da AMB deve considerar as referencias da UCO.
lUndCop := ( allTrim(cCodUnd) == "COP" ) 

//calculo Valor * referencia * US nao vale para unidade PAP
if allTrim(cCodUnd) == "PAP"
	lCosRefCH := .f.
endIf

if lPLRDAPGT    
    aPlRdaPgt := execBlock("PLRDAPGT",.f.,.f.,{cCodInt,cCodRDAReal,cCodLoc,cCodEsp,cCodRDA,cSubEsp,cCodTab,cCodPad,lReembolso,cCodUnd,cTipPre})
    
    cCodRda := Iif(valtype(aPlRdaPgt) == "A" ,aPlRdaPgt[1],aPlRdaPgt)
    
    If valtype(aPlRdaPgt) == "A".And. len (aPlRdaPgt) > 1
        cCodLoc := aPlRdaPgt[2]
        cCodEsp := aPlRdaPgt[3]
        cTipPre := aPlRdaPgt[4]
    Endif
endIf

//Verifica se e intercambio atraves de rotina generica
aRetInt    := PLINTERC(cTipo,cCodRda,cOpeOri,cRegPag,cRegCob)
lInterc    := aRetInt[1]
cOpeInt    := aRetInt[2]
cTipPre    := aRetInt[3]

If !lBanda
	cMeMorial += IIF( lInterc, "Atendimento de intercâmbio" + CRLF, "")
endIf
BB8->(dbSetOrder(1))
lFoundBB8 := SeekBB8E(cCodRDA,cCodInt,cCodLoc)

/* 

[GRUPO DE OPERADORA]                                            
BGH - Grupo de Operadora                                        
                                                                
[OPERADORA DE SAUDE]                                            
BMC - Operadora X Tipo de Prestador X Procedimento X U.S        
BMB - Operadora X Tipo de Prestador X U.S                       
BFM - Operadora X Valores mensais de U.s                        
                                                                
[SUBCONTRATO]                                                   
BS9 - Subcontrato X Produto X Tipo de Prestador X Proc. X Und X U.S 
BMG - Subcontrato X Produto X Tipo de Prestador X Procedimento X U.S
BMF - Subcontrato X Produto X Tipo de Prestador X U.S           
BMH - Subcontrato X Param. Pag. Prestador                          
BMI - Subcontrato X Param. Pag. Prestador X Procedimento           
BMM - Subcontrato X Param. Pag. Especialidade                      
BML - Subcontrato X Param. Pag. Especialidade X Procedimento       
                                                                
[PRODUTO]                                                       
BME - Produto X Tipo de Prestador X Procedimento X U.S          
BMD - Produto X Tipo de Prestador X U.S                         
BS0 - Produto X X Und X U.S                                     
                                                                
[REDE DE ATENDIMENTO]                                           
BE9 - RDA X local Atend X Especialidade X Planos X Procedimentos... 
BBI - RDA X local Atend X Especialidade X Planos...             
BC0 - RDA X local Atend X Especialidade X Procedimentos         
BCK - RDA X local Atend X U.S por Unidade                       
BC6 - RDA X Tab Precos (Itens)                                  
BC5 - RDA X Tab Precos (Cabecalho)                              
BAX - RDA X local Atend X Especialidade                         
BB8 - RDA X local Atend                                         

[ESPECIALIDADE]                                                 
BBM - Especialidade X Procedimentos                             
BAQ - Especialidade                                             

===> Niveis que permitem parametrização da tabela de valorização.

BS0 - Produto X Und X U.S                        		
BBI - RDA X local Atend X Especialidade X Planos...		
BMB - Operadora X Tipo de Prestador X U.S				

B24 - RDA X Tab Preços Generica							
B29 - Tabela de preço

B12 - Estados X Municipios (Estado)		
B13 - Estados X Municipios (Municipio)	
B30 - RDA X Planos						
B85 - Associacao X Classe X Tabela de Preco
*/

//Pagamento
if ! lCobCoPart 

     if cTipPre <> getNewPar("MV_PLSTPIN","OPE")

        aOrdensNiv := { "BGH","BMI","BMH","BE9","BBI","BC0","BCK","BC6","BC5","BS9","BAX","BB8","BMG",;
        				"BMF","BMM","BML","BBM","BAQ","BME","BMD","BS0","BMC","BMB","BHF","B24","B30","B13","B12","B85","B29","BFM"}

     else

        aOrdensNiv := { "BC0","BGH","BMI","BMH","BE9","BBI","BCK","BC6","BC5","BS9","BAX","BB8","BMG",;
        				"BMF","BMM","BML","BBM","BAQ","BME","BMD","BS0","BMC","BMB","BHF","B24","B30","B13","B12","B85","B29","BFM"}

     endIf   				 

//Recebimento	     
else              
     aOrdensNiv := { "BGH","BE9","BBI","BC6","BC5","BS9","BS0","BHF","B30","B29","BFM" }
endIf

if lPLSONVPC

	aOrdensNiv := execBlock("PLSONVPC",.f.,.f.,{aOrdensNiv,lCobCoPart,cCodRda,cOpeOri,"1"})
	cMeMorial += " Executada regra customizada PLSNVOPC " + CRLF
	// Garante que o BFM sempre vai estar presente no array.
	if ! lZeraTudo
	
		if ValType(aOrdensNiv) == "A"
	
			if (nPosNiv := aScan(aOrdensNiv, "BFM")) == 0
				aadd(aOrdensNiv, "BFM")
			endIf
		
		else
			aOrdensNiv := {"BFM"}
		
		endIf
		
	endIf
	
endIf
cMeMorial += " Níveis considerados: " + CRLF
for nMeMorial := 1 to Len(aOrdensNiv)
	cMeMorial += " - " + aOrdensNiv[nMeMorial] + IIF(Len(aOrdensNiv) == nMeMorial, CRLF, " ")
next

for nForNiv := 1 to len(aOrdensNiv)
	
	if aOrdensNiv[nForNiv] == "BGH" .and. lInterc .or. (cREGGOP=="1" .AND. cTipo == "2")//( lInterc .or. (cREGGOP=="1" .AND. cTipo == "2") )
		
		aRetFun := PLSGRUOPE(cTipo, cOpeInt, dDatAnalise, nNiveis, __aNiveis, cCodPro,;
							 cModPag, cCodPad, cCodEsp, cCodUnd, cCodPla, nVlrApr,;
							 cGRUOPE, nil, lInterc, cFinate, cCodRda, cRdaEdi,,,,cRegAte)
		
		if aRetFun[7]
			
			nVlrRea := aRetFun[3]
			
			//USP pagamento ou USR de Recebimento
			nVlrUS	:= aRetFun[5]
			nBanda 	:= aRetFun[12]
			
			if len(aRetFun) >= 16
				dVigIni := aRetFun[15]
				dVigFim := aRetFun[16]
			endIf	

			//somente quando vem da PLSRTBANDA - lBanda  
			if lBanda
				lOK := ( nBanda > 0 )
			elseIf (nVlrUS > 0 .or. nVlrRea > 0 ) .or. (lPorteMed .and. nBanda > 0 )
				lOK := .t.
			endIf

			if lOk 
				cAlias  := aRetFun[6]
				aVigAtu := { cAlias, dVigIni ,dVigFim }
			endIf
			
		endIf
			
	elseIf aOrdensNiv[nForNiv] == "B29" .and. ( ! lInterc .or. lChkNvLoc )
		
		B29->(dbSetOrder(1))//B29_FILIAL+B29_CODIGO+B29_CODINT+B29_TABPRE
		if B29->(msSeek(xFilial("B29")+cCodRDA+cCodInt))

			while !B29->( eof() ) .and. B29->B29_CODIGO+B29->B29_CODINT == cCodRDA+cCodInt

				// Faz a analize da vigencia.
				if PLSINTVAL("B29","B29_VIGINI","B29_VIGFIN",dDatAnalise)

					// Trata amarração com a nova tabela de preço/valorização.
					if ! empty(B29->B29_TABPRE)

						__XaRetTabPre := PLVLTBPR(B29->B29_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nPorteOri,'B29',cCodEsp,cCodUnd, lCobCoPart)//PLVLTBPR(B29->B29_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nPorteOri,'B29',cCodEsp,cCodUnd, lCobCoPart)
						
						if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
			  			 			@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, B29->B29_VIGINI, B29->B29_VIGFIN,@lOkAD) .OR. lOkAD
							exit

						endIf
							
					endIf
					
				endIf
									
			B29->( dbSkip() )
			endDo
			
		endIf   
		
	elseIf aOrdensNiv[nForNiv] == "B85" .and. ( ! lInterc .or. lChkNvLoc )
		
		//Verifico no nivel de local de RDA x Associacao.						
		B62->(dbSetOrder(1))
		if B62->(msSeek(xFilial("B62")+cCodRDA+cCodInt))

			while !B62->( eof() ) .and. B62->B62_CODIGO+B62->B62_CODINT == cCodRDA+cCodInt
			
				// Faz a analize da vigencia.
				if PLSINTVAL("B62","B62_DTVGIN","B62_DTVGF",dDatAnalise)
				
					B85->( dbSetOrder(01) )
					if B85->( msSeek(xFilial("B85")+B62->B62_ASSCLA) )

						while !B85->( eof() ) .and. B85->(B85_CODASS+B85_CLASSE) == B62->B62_ASSCLA

							// Faz a analize da vigencia.
							if PLSINTVAL("B85","B85_VIGINI","B85_VIGFIN",dDatAnalise)

								// Tratamento da nova amarração com a tabela de preço/valorização.
								if !empty(B85->B85_TABPRE)

									__XaRetTabPre := PLVLTBPR(B85->B85_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B85',cCodEsp,cCodUnd, lCobCoPart)

									if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
			  			 			 			@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, B85->B85_VIGINI, B85->B85_VIGFIN, @lOkAD) .OR. lOkAD

										exit

									endIf
									
         						endIf
         						
         					endIf
         					
	                	B85->( dbSkip() )
	             		endDo
	             	
	             	endIf
	             
	         	endIf
	                 
			 	if lOk
					exit
			 	endIf
			 			            
	        B62->( dbSkip() )
			endDo
			
		endIf
		 
	elseIf aOrdensNiv[nForNiv] == "B30" .and. ( ! lInterc .or. lChkNvLoc )

		//Verifico no nivel de local de Atendimento X Especialidade X Produto
		B30->(dbSetOrder(1))
		if B30->(msSeek(xFilial("B30")+cCodRDA+cCodInt+cCodPla+cVrProduto))
			
			// Trata amarração com a nova tabela de preço.
			while !B30->( eof() ) .and. B30->B30_CODIGO+B30->B30_CODINT+B30->B30_CODPRO+B30->B30_VERSAO == cCodRDA+cCodInt+cCodPla+cVrProduto
			
				// Faz a analize da vigencia.					
				if PLSINTVAL("B30","B30_VIGDE","B30_VIGATE",dDatAnalise)			

					// Trata amarração com a nova tabela de preço/valorizacao.
					cTabVlr := iIf(!lCobCoPart, B30->B30_TABPRE, B30->B30_TABREC)
				
					if ! empty(cTabVlr)
						
						__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B30',cCodEsp,cCodUnd, lCobCoPart)
						
						if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
									@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, B30->B30_VIGDE, B30->B30_VIGATE, @lOkAD) .OR. lOkAD

							exit
							
						endIf	
						
					else
					
						nVlrUS 	  := iIf(! lCobCoPart, B30->B30_VALCH, B30->B30_USRECT )
						nVlrRea   := 0
						nBanda 	  := B30->B30_BANDA
						
						//somente quando vem da PLSRTBANDA - lBanda  
						if lBanda 
							lOk := ( nBanda > 0 )
						elseIf nVlrUS > 0  .or. (lPorteMed .and. nBanda > 0 )
							lOK := .t.
						endIf

						if lOk	
							cAlias 	:= "B30"
							aVigAtu	:= { cAlias, B30->B30_VIGDE ,B30->B30_VIGATE }
							exit
						endIf

					endIf
					
				endIf
				
			B30->( dbSkip() )
			endDo	
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] == "BC6" .and. ( ! lInterc .or. lChkNvLoc )
		
		aRetTabPre := PLSTABPRE(cCodInt,cCodRda,cCodPad,cCodPro,dDatAnalise,cPadInt,cCodPla,cOpeOri,cCodLoc,lCobCoPart,cRegAte,cFinAte,cCodTab,lReembolso,cModPag, nRef, lBanda, @lOkAD)

		lOkAD := lOkAD .AND. lPorteMed .AND. !lBanda //regra válida somente pra porte

		if len(aRetTabPre) > 0 .and. aRetTabPre[1]

			nVlrUS     	:= aRetTabPre[2,1]
			nVlrRea     := aRetTabPre[2,2]
			nBanda 	  	:= iIf( ! lCobCoPart, aRetTabPre[2,4], aRetTabPre[2,3] ) 
			nDesconto 	:= aRetTabPre[2,5]
			nAcrescimo	:= aRetTabPre[2,6]
			nRef		:= aRetTabPre[2,7]

			//somente quando vem da PLSRTBANDA - lBanda  
			if lBanda 
				lOk := ( nBanda > 0 )				
			elseIf (nVlrUS > 0 .or. nVlrRea > 0) .or. (lPorteMed .and. nBanda > 0 )
				lOK := .t.
			endIf

			if lOk				
				cAlias	:= aRetTabPre[3]
				aVigAtu	:= { cAlias, aRetTabPre[4][2] ,aRetTabPre[4][3] }				
			endIf
		elseIf lOkAD
			nDesconto 	:= aRetTabPre[2,5]
			nAcrescimo	:= aRetTabPre[2,6]
		endIf
		
	elseIf aOrdensNiv[nForNiv] == "BC5" .and. ( ! lInterc .or. lChkNvLoc )
			
		// Redefine as variaveis de controle
		cTabPre := ""
		lTabEsp := .f.
		
		// Verifica se existe tabela de preço no local de atendimento. Esse codigo se refere a tabela de preço X RDA BC5.
		if  lFoundBB8 .and. ! empty(BB8->BB8_TABPRE)
			cTabPre := BB8->BB8_TABPRE
			lTabEsp := .t.
		endIf

		// Verifica se existe tabela de preço especifica para esta RDA.
		BC5->(dbSetOrder(1))
		if BC5->( msSeek(xFilial("BC5") + cCodInt + cCodRda) )

			// Processa as vigencias.
			while ! BC5->(eof()) .and. BC5->(BC5_FILIAL+BC5_CODINT+BC5_CODRDA) == xFilial("BC5")+cCodInt+cCodRda

				// Faz a analize da vigencia.
				if PLSINTVAL("BC5","BC5_DATINI","BC5_DATFIM",dDatAnalise)

					// Trata amarração com a nova tabela de preço/valorizacao.
					cTabVlr := iIf(!lCobCoPart, BC5->BC5_TABPRE, BC5->BC5_TABREC)

					// Testa regra de tabela especifica.
					if ! empty(cTabVlr) .and. ( ( lTabEsp .and. cTabPre == cTabVlr ) .or. ( ! lTabEsp ) )
					
						__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nPorteOri,'BC5',cCodEsp,cCodUnd, lCobCoPart)
						
						if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
									@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, BC5->BC5_DATINI, BC5->BC5_DATFIM, @lOkAD) .OR. lOkAD
							
							exit
							
						endIf	
						
					else
					
						// Us Pagar Pre-Pag - Us Receber Pre-Pag  								
						nVlrUS := iIf(! lCobCoPart, BC5->BC5_VPPP, BC5->BC5_VRPP )	

						if allTrim(cModPag) != "1"
							nVlrUS := iIf(! lCobCoPart, BC5->BC5_VPCO, BC5->BC5_VRCO )	
						endIf
								
						nVlrRea		:= 0
						nBanda 	  	:= iIf( ! lCobCoPart, BC5->BC5_BANDAP, BC5->BC5_BANDAR ) 
						nDesconto 	:= 0
						nAcrescimo	:= 0

						//somente quando vem da PLSRTBANDA - lBanda  
						if lBanda 
							lOk := ( nBanda > 0 )
						elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
							lOK := .t.
						endIf

						if lOk							
							cAlias 	:= "BC5"
							aVigAtu	:= { cAlias, BC5->BC5_DATINI, BC5->BC5_DATFIM }
							exit							
						endIf

					endIf
					
				endIf
				
			BC5->( dbSkip() )
			endDo
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] == "BME" .and. ( ! lInterc .or. lChkNvLoc )

		cSQL := "SELECT BME_NIVEL,BME_VALUS, BME_VALUSA, BME_DATDE, BME_VLRPAG, BME_VLRPGA, BME_BANDA "
		cSQL += "  FROM " + cNameBME + " WHERE "
		cSQL += "BME_FILIAL = '" + xFilial("BME") + "' AND "
		cSQL += "BME_CODIGO = '" + cCodInt + cCodPla + "' AND "
		cSQL += "BME_VERSAO = '" + cVrProduto + "' AND "
		cSQL += "BME_TIPPRE = '" + cTipPre + "' AND "
		
		cSQL += PLREQNI("BME", "BME_CODPSA", __aNiveis[2], allTrim(cCodPro))
		
		cSQL += "( '" + dtos(dDatAnalise) + "' >= BME_VIGDE  OR BME_VIGDE  = ' ' ) AND "
		cSQL += "( '" + dtos(dDatAnalise) + "' <= BME_VIGATE OR BME_VIGATE = ' ' ) AND "
		cSQL +=  cNameBME + ".D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BME_NIVEL DESC, BME_DATDE DESC "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
		
		if ! PLSAUTPDIR->(eof())
		
			plsTField("PLSAUTPDIR",.f.,{ "BME_DATDE","BME_VALUS","BME_VLRPAG","BME_BANDA","BME_VALUSA","BME_VLRPGA" } )
			
			if empty(PLSAUTPDIR->BME_DATDE) .or. dtos(dDatAnalise) >= dtos(PLSAUTPDIR->BME_DATDE)
				nVlrUS 	:= PLSAUTPDIR->BME_VALUS
				nVlrRea := PLSAUTPDIR->BME_VLRPAG
			else
				nVlrUS 	:= PLSAUTPDIR->BME_VALUSA
				nVlrRea := PLSAUTPDIR->BME_VLRPGA
			endIf
			
			nBanda 	  	:= PLSAUTPDIR->BME_BANDA

			//somente quando vem da PLSRTBANDA - lBanda  
			if lBanda 
				lOk := ( nBanda > 0 )
			elseIf (nVlrUS > 0 .or. nVlrRea > 0) .or. (lPorteMed .and. nBanda > 0 )
				lOK := .t.
			endIf

			if lOk	
				
				cAlias    := "BME"
				aVigAtu	  := {cAlias, PLSAUTPDIR->BME_DATDE, dVigFim }

			endIf

		endIf
		
		PLSAUTPDIR->(dbCloseArea())
		
	elseIf aOrdensNiv[nForNiv] == "B12" .and. ( ! lInterc .or. lChkNvLoc ) .and. lFoundBB8
		
		// Se for reembolso, utiliza o estado/municipio informado na guia.
		if lReembolso
		
			cCodEstAux := iIf(empty(cUFAte),BB8->BB8_EST,cUFAte)
			
		// Se não for reembolso, utiliza o esta/municipio do local de atendimento da RDA.
		else
			cCodEstAux := BB8->BB8_EST
		endIf
			
		B12->(dbSetOrder(1)) //B12_FILIAL, B12_CODINT, B12_CODEST
		
		if B12->(msSeek(xFilial("B12")+cCodInt+cCodEstAux))
		
			while !B12->( eof() ) .and. B12->(B12_FILIAL+B12_CODINT+B12_CODEST) == xFilial("B12")+cCodInt+cCodEstAux
			
				if PLSINTVAL("B12","B12_VIGDE","B12_VIGATE",dDatAnalise)									
					
					// Trata amarração com a nova tabela de preço.
					if !empty(B12->B12_TABPRE)
					
						__XaRetTabPre := PLVLTBPR(B12->B12_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nPorteOri,'B12',cCodEsp,cCodUnd, lCobCoPart)
					
						if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
									@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, B12->B12_VIGDE, B12->B12_VIGATE, @lOkAD) .OR. lOkAD
					
							exit
					
						endIf
							
					endIf
					
				endIf
				
			B12->( dbSkip() )
			endDo
			
		endIf

	elseIf aOrdensNiv[nForNiv] == "B13" .and. ( ! lInterc .or. lChkNvLoc ) .and. lFoundBB8
		
		// Se for reembolso, utiliza o estado/municipio informado na guia.
		if lReembolso
		
			cCodEstAux := iIf(empty(cUFAte),BB8->BB8_EST,cUFAte)
			cCodMunAux := iIf(empty(cMunAte),BB8->BB8_CODMUN,cMunAte)
			
		// Se não for reembolso, utiliza o esta/municipio do local de atendimento da RDA.
		else
			
			cCodEstAux := BB8->BB8_EST
			cCodMunAux := BB8->BB8_CODMUN
			
		endIf
		
		B13->(dbSetOrder(1)) //B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN+B13_CODTAB+B13_SEQUEN
		if B13->(msSeek(xFilial("B13")+cCodInt+cCodEstAux+cCodMunAux))
		
			while !B13->( eof() ) .and. B13->(B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN) == xFilial("B13")+cCodInt+cCodEstAux+cCodMunAux
			
				if PLSINTVAL("B13","B13_VIGDE","B13_VIGATE",dDatAnalise)
				
					// Trata amarração com a nova tabela de preço.
					if !empty(B13->B13_TABPRE)
					
						__XaRetTabPre := PLVLTBPR(B13->B13_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B13',cCodEsp,cCodUnd, lCobCoPart)
			
						if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
									@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, B13->B13_VIGDE, B13->B13_VIGATE, @lOkAD) .OR. lOkAD
					
							exit
					
						endIf
						
					endIf
					
				endIf
		
			B13->( dbSkip() )
			endDo
			
		endIf

	elseIf aOrdensNiv[nForNiv] == "BC0" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso

		//Ponto de Entrada para alterar o codigo da especialidade no nivel BC0
		if lPLESPBC0
			cCodEsp := execBlock("PLESPBC0",.f.,.f.,{cCodPad,cCodPro,cCodInt,cCodRDA,cCodEsp,cSubEsp,cCodLoc,dDatPro,lCobCoPart,lReembolso,cTipPre})
		endIf			
		
		cSQL := "SELECT BC0_BANDA,BC0_PERACR,BC0_VALREA,BC0_PERDES,BC0_NIVEL,BC0_FORMUL,BC0_VALCH,BC0_EXPRES,BC0_VIGDE,BC0_VIGATE FROM "+cNameBC0+" WHERE "
		cSQL += "BC0_FILIAL = '" + xFilial("BC0") + "' AND "
		cSQL += "BC0_CODIGO = '" + cCodRDA + "' AND "
		cSQL += "BC0_CODINT = '" + cCodInt + "' AND "
		cSQL += "BC0_CODLOC = '" + cCodLoc + "' AND "
		cSQL += "BC0_CODESP = '" + cCodEsp + "' AND "

		cSubEsp := iIf(!empty(cSubEsp), cSubEsp, " ")

		cSQL += "BC0_CODSUB = '" + cSubEsp + "' AND "    
		cSQL += "BC0_CODPAD = '" + cCodPad + "' AND "
		
		cSQL += PLREQNI("BC0", "BC0_CODOPC", __aNiveis[2], allTrim(cCodPro))
		
		cSQL += "( '" + dtos(dDatAnalise) + "' >= BC0_VIGDE  OR BC0_VIGDE  = ' ' ) AND "
		cSQL += "( '" + dtos(dDatAnalise) + "' <= BC0_VIGATE OR BC0_VIGATE = ' ' ) AND "
		cSQL += "( BC0_DATBLO = ' '  OR BC0_DATBLO > '" + dtos(dDatAnalise) + "' ) AND "

		cSQL +=  cNameBC0 + ".D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BC0_NIVEL DESC "
		
		if lPLBC0SQL
			cSQL := execBlock("PLBC0SQL",.f.,.f.,{cSQL,cCodRda,cCodInt,cCodLoc,cCodEsp,cSubEsp,cCodPro,cCodPad})
		endIf

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
		
		if ! PLSAUTPDIR->(eof())
			
			plsTField("PLSAUTPDIR",.f.,{ "BC0_BANDA","BC0_VALCH","BC0_VALREA","BC0_PERDES","BC0_PERACR","BC0_VIGDE","BC0_VIGATE" } )
			
			if PLSAUTPDIR->BC0_FORMUL == "1"
				
				nBanda 	  	:= PLSAUTPDIR->BC0_BANDA
				nVlrUS    	:= PLSAUTPDIR->BC0_VALCH
				nVlrRea   	:= PLSAUTPDIR->BC0_VALREA
				nDesconto 	:= PLSAUTPDIR->BC0_PERDES
				nAcrescimo 	:= PLSAUTPDIR->BC0_PERACR

			elseIf PLSAUTPDIR->BC0_FORMUL == "2"
			
				//Verifico a consistencia da expressao                 
				aCop := PLSParAna(PLSAUTPDIR->BC0_EXPRES)
				
				//Se nao tiver nenhum problema com a expressao, calculo o valor da US 
				if empty(aCop[1])
					
					nVlrUS    	:= &(PLSAUTPDIR->BC0_EXPRES)
					nBanda 	  	:= PLSAUTPDIR->BC0_BANDA
					nDesconto 	:= PLSAUTPDIR->BC0_PERDES
					nAcrescimo 	:= PLSAUTPDIR->BC0_PERACR
					
					if valType(nVlrUS) <> "N"
						nVlrUS  := 0
					endIf
					
				else
					
					lOK     := .f.
					lRet    := .f.
					
					PLSPOSGLO(PLSINTPAD(),__aCdCri029[1],__aCdCri029[2])
					
					cMsg    := PLSBCTDESC()
					cCodCri := __aCdCri029[1]

				endIf
				
			endIf

			//somente quando vem da PLSRTBANDA - lBanda  
			if lBanda 
				lOk := ( nBanda > 0 )
			elseIf (nVlrUS > 0 .or. nVlrRea > 0) .or. (lPorteMed .and. nBanda > 0 )
				lOK := .t.
			endIf

			if lOk	

				cAlias  := "BC0"
				aVigAtu	:= {cAlias, PLSAUTPDIR->BC0_VIGDE, PLSAUTPDIR->BC0_VIGATE}
			elseIf !lBanda .AND. lPorteMed .AND. nDesconto + nAcrescimo > 0
				lOkAD := .T.
			endIf

		endIf
			
		PLSAUTPDIR->(dbCloseArea())
	
	elseIf aOrdensNiv[nForNiv] == "BE9" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso
		
		cSQL := "SELECT R_E_C_N_O_ REC FROM "+cNameBE9+" WHERE "
		cSQL += "BE9_FILIAL = '" + xFilial("BE9") + "' AND "
		cSQL += "BE9_CODIGO = '" + cCodRDA + "' AND "
		cSQL += "BE9_CODINT = '" + cCodInt + "' AND "
		cSQL += "BE9_CODLOC = '" + cCodLoc + "' AND "
		cSQL += "BE9_CODESP = '" + cCodEsp  + "' AND "
		cSQL += "BE9_CODPLA = '" + cCodPla + "' AND "
		cSQL += "BE9_CODPAD = '" + cCodPad + "' AND "
		
		cSQL += PLREQNI("BE9", "BE9_CODPRO", __aNiveis[2], cCodPro)
		
		cSQL += "( '" + dtos(dDatAnalise) + "' >= BE9_VIGDE  OR BE9_VIGDE  = ' ' ) AND "
		cSQL += "( '" + dtos(dDatAnalise) + "' <= BE9_VIGATE OR BE9_VIGATE = ' ' ) AND "
		cSQL +=  cNameBE9 + ".D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BE9_NIVEL DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)

		if ! PLSAUTPDIR->(eof())
			BE9->(dbGoTo(PLSAUTPDIR->(REC)))
			lFoundBE9 := .t.
		else
			
			if lPLSBE9SK
				execBlock("PLSBE9SK",.f.,.f.,{cCodRda,cCodInt,cCodLoc,cCodEsp,cCodPla,cCodPad,cCodAux,nForBE9})
			endIf
			
		endIf
		
		PLSAUTPDIR->(dbCloseArea())
				
		if lFoundBE9 .and. BE9->BE9_ATIVO <> "0"	
		
			if ! lCobCoPart
				
				If BE9->BE9_VALCH > 0 .OR. BE9->BE9_VALREA > 0
					nVlrUS  	:= BE9->BE9_VALCH
					nVlrRea 	:= BE9->BE9_VALREA
					nBanda  	:= BE9->BE9_BANDA
					nDesconto 	:= BE9->BE9_PERDES
					nAcrescimo	:= BE9->BE9_PERACR
				EndIf
			else
				If BE9->BE9_USRECT > 0 .OR. BE9->BE9_VLRECT > 0
					nVlrUS 	:= BE9->BE9_USRECT
					nVlrRea 	:= BE9->BE9_VLRECT
					nBanda 	:= BE9->BE9_BANDA
					nDesconto 	:= BE9->BE9_PERDES
					nAcrescimo	:= BE9->BE9_PERACR
				EndIf
			endIf

		endIf

		//somente quando vem da PLSRTBANDA - lBanda  
		if lBanda 
			lOK := ( nBanda > 0 )
		elseIf (nVlrUS > 0 .or. nVlrRea > 0) .or. (lPorteMed .and. nBanda > 0 )
			lOK := .t.
		endIf

		if lOk

			cAlias  := "BE9"
			aVigAtu := { cAlias, BE9->BE9_VIGDE, BE9->BE9_VIGATE}
		elseIf !lBanda .AND. lPorteMed .AND. nDesconto + nAcrescimo > 0
			lOkAD := .T.
		endIf

	elseIf aOrdensNiv[nForNiv] == "BBI" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso

		BBI->(dbSetOrder(1))
		if BBI->(msSeek(xFilial("BBI")+cCodRda+cCodInt+cCodLoc+cCodEsp+cCodPla))
			
			while !BBI->( eof() ) .and. BBI->BBI_CODIGO+BBI->BBI_CODINT+BBI->BBI_CODLOC+BBI->BBI_CODESP+BBI->BBI_CODPRO == cCodRDA+cCodInt+cCodLoc+cCodEsp+cCodPla

				// Verifica se a parametrização esta ativa e se esta vigente.
				if BBI->BBI_ATIVO <> "0" .and. PLSINTVAL("BBI","BBI_VIGDE","BBI_VIGATE",dDatAnalise)
					
					// Trata amarração com a nova tabela de preço/valorizacao.
					cTabVlr := iIf(!lCobCoPart, BBI->BBI_TABPRE, BBI->BBI_TABREC)
							
					if ! empty(cTabVlr)
						
						__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BBI',cCodEsp,cCodUnd, lCobCoPart)
						
						if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
									@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, BS9->BS9_VIGDE, BS9->BS9_VIGATE, @lOkAD) .OR. lOkAD
							
							exit
							
						endIf	
						
					else
					
						nVlrUS 	  := Iif(! lCobCoPart, BBI->BBI_VALCH, BBI->BBI_USRECT )
						nVlrRea  := 0
						nBanda 	  := BBI->BBI_BANDA

						dVigIni := BBI->BBI_VIGDE
						dVigFim := BBI->BBI_VIGATE
						
						//somente quando vem da PLSRTBANDA - lBanda  
						if lBanda 
							lOk := ( nBanda > 0 )
						elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
							lOK := .t.
						endIf

						if lOk	

							cAlias  := "BBI"
							aVigAtu := { cAlias, dVigIni, dVigFim }

							exit

						endIf	

					endIf
					
				endIf                      

			BBI->( dbSkip() )
			endDo
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] == "BBM" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso
		
		nFor := 1
		
		cSQL := "SELECT BBM_NIVEL, BBM_VALCH, BBM_VALREA, BBM_PERDES, BBM_PERACR, BBM_BANDA, BBM_DATVAL "
		cSQL += "FROM "+cNameBBM+" WHERE "
		cSQL += "BBM_FILIAL = '"+xFilial("BBM")+"' AND "
		cSQL += "BBM_CODINT = '"+cCodInt+"' AND "
		cSQL += "BBM_CODESP = '"+cCodEsp+"' AND "
		cSQL += "BBM_CODPAD = '"+cCodPad+"' AND "
		
		cSQL += PLREQNI("BBM", "BBM_CODPSA", __aNiveis[2], allTrim(cCodPro))

		cSQL += "BBM_ATIVO = '1' AND "
		cSQL += "(BBM_DATVAL = ' ' OR '" + dtos(dDatAnalise) + "' <= BBM_DATVAL) AND "
		
		cSQL +=  cNameBBM + ".D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BBM_NIVEL DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
			
		if ! PLSAUTPDIR->(eof())

			plsTField("PLSAUTPDIR",.f.,{ "BBM_DATVAL","BBM_VALCH","BBM_VALCH","BBM_PERDES","BBM_PERACR","BBM_BANDA","BBM_VALREA"  } )
		
			nVlrUS 		:= PLSAUTPDIR->BBM_VALCH
			nVlrRea 	:= PLSAUTPDIR->BBM_VALREA
			nBanda 	  	:= PLSAUTPDIR->BBM_BANDA

			nDesconto 	:= PLSAUTPDIR->BBM_PERDES
			nAcrescimo 	:= PLSAUTPDIR->BBM_PERACR

			//somente quando vem da PLSRTBANDA - lBanda  
			if lBanda 
				lOk := ( nBanda > 0 )
			elseIf (nVlrUS > 0 .or. nVlrRea > 0) .or. (lPorteMed .and. nBanda > 0 )
				lOK := .t.
			endIf

			if lOk	

				cAlias  := "BBM"
				aVigAtu := {cAlias, PLSAUTPDIR->BBM_DATVAL, dVigFim}
			elseIf !lBanda .AND. lPorteMed .AND. nDesconto + nAcrescimo > 0
				lOkAD := .T.
			endIf

		endIf
		
		PLSAUTPDIR->(dbCloseArea())
		
	elseIf aOrdensNiv[nForNiv] == "BS0" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso
			
		cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBS0 + " WHERE "
		cSQL += "BS0_FILIAL = '" + xFilial("BS0") + "' AND "
		cSQL += "BS0_CODPRO = '" + cCodInt+cCodPla + "' AND "
		cSQL += "BS0_CODPAD = '" + cCodPad + "' AND "
		cSQL += "BS0_CODUNI = '" + cCodUnd + "' AND "
		
		cSQL += PLREQNI("BS0", "BS0_CODPSA", __aNiveis[2], allTrim(cCodPro))

		cSQL += "( '"+dtos(dDatAnalise)+"' >= BS0_VIGDE  OR BS0_VIGDE = ' ' ) AND "
		cSQL += "( '"+dtos(dDatAnalise)+"' <= BS0_VIGATE OR BS0_VIGATE = ' ' ) AND "
		
		cSQL +=  cNameBS0 + ".D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BS0_NIVEL DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
		
		lFlag := .f.
		
		if ! PLSAUTPDIR->(eof())
			
			lFlag := .t.
			BS0->(dbGoTo(PLSAUTPDIR->(REC)))
				
		endIf	
		
		PLSAUTPDIR->(dbCloseArea())
		
		if lFlag
		
			// Trata amarração com a nova tabela de preço/valorizacao.
			cTabVlr := iIf(!lCobCoPart, BS0->BS0_TABPRE, BS0->BS0_TABREC)
			
			if ! empty(cTabVlr)

				__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BS0',cCodEsp,cCodUnd, lCobCoPart)
				
				PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
							@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, BS0->BS0_VIGDE, BS0->BS0_VIGATE, @lOkAD)
				
				if lBanda 
					lOk := ( nBanda > 0 )
				endif
			else
			
				nVlrUS 	 := iIf( ! lCobCoPart, BS0->BS0_USPAG, BS0->BS0_USREC )
				nVlrRea := 0

				//somente quando vem da PLSRTBANDA - lBanda  
				if lBanda 
					lOk := ( nBanda > 0 )
				elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
					lOK := .t.
				endIf

				if lOk	

					nUSEspec  := nVlrUS //quando so parametriza us ela fica mais forte que todas...
					cAlias    := "BS0"
					aVigAtu	  := { cAlias, BS0->BS0_VIGDE, BS0->BS0_VIGATE }

				endIf 

			endIf

		endIf
		
		//Tratamento da diferenciacao da us por produto X unidade			   
		lFlag := .f.

		if ! lOK .and. getNewPar("MV_PLBS0UM","1") == "1" 
			
			cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBS0 + " WHERE "
			cSQL += "BS0_FILIAL = '" + xFilial("BS0") + "' AND "
			cSQL += "BS0_CODPRO = '" + cCodInt + cCodPla + "' AND "
			cSQL += "BS0_CODUNI = '" + cCodUnd + "' AND "

			cSQL += "( '"+dtos(dDatAnalise)+"' >= BS0_VIGDE  OR BS0_VIGDE = ' ' ) AND "
			cSQL += "( '"+dtos(dDatAnalise)+"' <= BS0_VIGATE OR BS0_VIGATE = ' ' ) AND "
			
			cSQL +=  cNameBS0 + ".D_E_L_E_T_ = ' ' "
			
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
			
			lFlag := .f.
		
			if ! PLSAUTPDIR->(eof())
				
				lFlag := .t.
				BS0->(dbGoTo(PLSAUTPDIR->(REC)))
					
			endIf	
			
			PLSAUTPDIR->(dbCloseArea())
			
			if lFlag
			
				// Trata amarração com a nova tabela de preço/valorizacao.
				cTabVlr := iIf(!lCobCoPart, BS0->BS0_TABPRE, BS0->BS0_TABREC)

				if ! empty(cTabVlr)

					__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BS0',cCodEsp,cCodUnd, lCobCoPart)

					PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
								@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, BS0->BS0_VIGDE, BS0->BS0_VIGATE, @lOkAD)

					if lBanda 
						lOk := ( nBanda > 0 )
					endif								
					
				else
					
					nVlrUS 	 := iIf( ! lCobCoPart, BS0->BS0_USPAG, BS0->BS0_USREC )
					nVlrRea := 0

					//somente quando vem da PLSRTBANDA - lBanda  
					if lBanda 
						lOk := ( nBanda > 0 )
					elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
						lOK := .t.
					endIf

					if lOk	

						nUSEspec  := nVlrUS //quando so parametriza us ela fica mais forte que todas...
						cAlias    := "BS0"
						aVigAtu	  := { cAlias, BS0->BS0_VIGDE, BS0->BS0_VIGATE }

					endIf
	
				endIf
				
			endIf
			
		endIf

	elseIf aOrdensNiv[nForNiv] == "B24" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso
		
		// Obtem as tabelas de preço disponiveis para este prestador na tabela B24 - Somente as que estiveram com vigencia em aberto.
		aTabs := aClone(SeekB24(cCodRDA,cCodInt,cCodLoc,dDatAnalise))

		// Processa todas as tabelas de preço do prestador.
		for nTab := 1 to len(aTabs)                        

			// Trata amarração com a nova tabela de preço/valorizacao.
			if ! empty(aTabs[nTab]) 
				
				__XaRetTabPre := PLVLTBPR(aTabs[nTab],cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B24',cCodEsp,cCodUnd, lCobCoPart)
				
				if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
							@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, B24->B24_VIGINI, B24->B24_VIGFIN, @lOkAD) .OR. lOkAD
			
					exit

				endIf
				
			endIf   
							
		next
		
	elseIf aOrdensNiv[nForNiv] == "BMG" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso .and. cTipoUsr == "2"
		
		cSQL := "SELECT BMG_BANDA,BMG_NIVEL,BMG_VALUS, BMG_VALUSA, BMG_DATDE, BMG_VLRPAG "
		cSQL += "  FROM " + cNameBMG + " WHERE "
		cSQL += "BMG_FILIAL = '" + xFilial("BMG") + "' AND "
		cSQL += "BMG_CODINT = '" + cCodInt + "' AND "
		cSQL += "BMG_CODEMP = '" + cCodEmp + "' AND "
		cSQL += "BMG_NUMCON = '" + cConEmp + "' AND "
		cSQL += "BMG_VERCON = '" + cVerCon + "' AND "
		cSQL += "BMG_SUBCON = '" + cSubCon + "' AND "
		cSQL += "BMG_VERSUB = '" + cVerSub + "' AND "
		cSQL += "BMG_TIPPRE = '" + cTipPre + "' AND "
		cSQL += "BMG_CODPAD = '" + cCodPad + "' AND "
		
		cSQL += "( '" + dtos(dDatAnalise) + "' >= BMG_DATDE OR BMG_DATDE = ' ' ) AND "

		cSQL += PLREQNI("BMG", "BMG_CODPSA", __aNiveis[2], allTrim(cCodPro))
		
		cSQL += cNameBMG + ".D_E_L_E_T_ = ' ' "

		cSQL +=  " ORDER BY BMG_NIVEL DESC, BMG_DATDE DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
		
		if ! PLSAUTPDIR->(eof())
		
			plsTField("PLSAUTPDIR",.f.,{ "BMG_DATDE","BMG_VALUS","BMG_VLRPAG","BMG_BANDA"  } )

			nVlrUS 	  := PLSAUTPDIR->BMG_VALUS
			nVlrRea   := PLSAUTPDIR->BMG_VLRPAG
			nBanda 	  := PLSAUTPDIR->BMG_BANDA

			//somente quando vem da PLSRTBANDA - lBanda  
			if lBanda 
				lOk := ( nBanda > 0 )
			elseIf (nVlrUS > 0 .or. nVlrRea > 0) .or. (lPorteMed .and. nBanda > 0 )
				lOK := .t.
			endIf

			if lOk	

				cAlias    := "BMG"
				aVigAtu	  := {cAlias, PLSAUTPDIR->BMG_DATDE, dVigFim}

			endIf

		endIf
		
		PLSAUTPDIR->(dbCloseArea())
		
	elseIf aOrdensNiv[nForNiv] $ "BMI" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso .and. cTipoUsr == "2"

		BMI->(dbSetOrder(1))
		if BMI->(msSeek(xFilial("BMI")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA+cCodPad+cCodPro))
							
			aRegs := {}
			
			while !BMI->(eof()) .and. xFilial("BMI")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA+cCodPad+cCodPro ==  BMI->(BMI_FILIAL+BMI_CODINT+BMI_CODEMP+BMI_NUMCON+BMI_VERCON+BMI_SUBCON+BMI_VERSUB+BMI_CODRDA+BMI_CODPAD+BMI_CODPSA)
				
				aadd(aRegs,{BMI->(recno()),BMI->(BMI_DATDE)})

			BMI->(dbSkip())
			endDo
			
			//Ordeno pelo DATDE maior ou seja vai pegar o de vigencia mais nova primeiro
			aRegs := aSort(aRegs,,,{|x,y| x[2] >= y[2] }) 
			
			for nR := 1 to len(aRegs)
					
				BMI->(dbGoTo(aRegs[nR][1]))
				
				if empty(BMI->BMI_DATDE) .or. dtos(dDatAnalise) >= dtos(BMI->BMI_DATDE)
					nVlrUS := BMI->BMI_VALUS
				else
					nVlrUS := BMI->BMI_VALUSA
				endIf
				
				nVlrRea := BMI->BMI_VLRPAG
				nBanda 	:= BMI->BMI_BANDA

				//somente quando vem da PLSRTBANDA - lBanda  
				if lBanda 
					lOk := ( nBanda > 0 )
				elseIf (nVlrUS > 0 .or. nVlrRea > 0) .or. (lPorteMed .and. nBanda > 0 )
					lOK := .t.
				endIf

				if lOk	

					cAlias    := "BMI"
					aVigAtu	  := {cAlias,BMI->BMI_DATDE, dVigFim}

					exit

				endIf

			next
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BMM" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso .and. cTipoUsr == "2"
		
		BMM->(dbSetOrder(1)) //BMM_FILIAL+BMM_CODINT+BMM_CODEMP+BMM_NUMCON+BMM_VERCON+BMM_SUBCON+BMM_VERSUB+BMM_CODESP+BMM_CODPAD+BMM_CODPSA+BMM_NIVEL
		
		if BMM->(msSeek(xFilial("BMM")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodEsp+cCodPad+cCodPro))
			
			aRegs := {}
			
			while !BMM->(eof()) .and.  xFilial("BMM")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodEsp+cCodPad+cCodPro == BMM->(BMM_FILIAL+BMM_CODINT+BMM_CODEMP+BMM_NUMCON+BMM_VERCON+BMM_SUBCON+BMM_VERSUB+BMM_CODESP+BMM_CODPAD+BMM_CODPSA)
				
				aadd(aRegs,{BMM->(recno()), BMM->(BMM_DATDE)})                                          
			
			BMM->(dbSkip())
			endDo
												
			//Ordeno pelo DATDE maior ou seja vai pegar o de vigencia mais nova primeiro
			aRegs := aSort(aRegs,,,{|x,y| x[2] >= y[2] }) 
			
			for nR := 1 to len(aRegs)	 
			
				BMM->(dbGoTo(aRegs[nR][1]))  
				
				if empty(BMM->BMM_DATDE) .or. dtos(dDatAnalise) >= dtos(BMM->BMM_DATDE)
					nVlrUS := BMM->BMM_VALUS
				else
					nVlrUS := BMM->BMM_VALUSA
				endIf
				
				nVlrRea := BMM->BMM_VLRPAG
				nBanda 	:= BMM->BMM_BANDA

				//somente quando vem da PLSRTBANDA - lBanda  
				if lBanda 
					lOk := ( nBanda > 0 )
				elseIf (nVlrUS > 0 .or. nVlrRea > 0) .or. (lPorteMed .and. nBanda > 0 )
					lOK := .t.
				endIf

				if lOk	

					cAlias    := "BMM"
					aVigAtu	  := {cAlias, BMM->BMM_DATDE, dVigFim}

					exit

				endIf

			next
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BS9" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso .and. cTipoUsr == "2"
		
		cSql := "SELECT R_E_C_N_O_ REC FROM " + retSqlName("BS9") 
		cSql += " WHERE BS9_FILIAL = '" + xFilial("BS9") + "' "
		cSql += "   AND BS9_SUBCON = '" + cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub + "' "
		cSql += "   AND BS9_CODUNI = '" + cCodUnd + "' "
		cSql += "   AND D_E_L_E_T_ = ' ' "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSAUTPDIR",.f.,.t.)
		
		while !PLSAUTPDIR->( eof() )

			BS9->( dbGoTo( PLSAUTPDIR->(REC) ) )
			
			//Se a vigencia estiver dentro do limite parametrizado...			 
			if PLSINTVAL("BS9","BS9_VIGDE","BS9_VIGATE",dDatAnalise)				
				
				if ! empty(BS9->BS9_TABPRE)
				
					__XaRetTabPre := PLVLTBPR(BS9->BS9_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BS9',cCodEsp,cCodUnd, lCobCoPart)
				
					if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
								@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, BS9->BS9_VIGDE, BS9->BS9_VIGATE, @lOkAD) .OR. lOkAD
						
						exit
						
					endIf	
					
				else

					nVlrUS 	 := iIf( ! lCobCoPart, BS9->BS9_USPAG, BS9->BS9_USREC )
					nVlrRea := 0

					//somente quando vem da PLSRTBANDA - lBanda  
					if lBanda 
						lOk := ( nBanda > 0 )
					elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
						lOK := .t.
					endIf

					if lOk	

						nUSEspec  := nVlrUS
						cAlias    := "BS9"
						aVigAtu	  := { cAlias, BS9->BS9_VIGDE, BS9->BS9_VIGATE }
						
						exit

					endIf

				endIf
				
			endIf
									
		PLSAUTPDIR->( dbSkip() )
		endDo
		
		PLSAUTPDIR->( dbCloseArea() )

	elseIf aOrdensNiv[nForNiv] $ "BCK" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lPorteMed .and. ! lReembolso
		
		BCK->(dbSetOrder(1)) //BCK_FILIAL+BCK_CODIGO+BCK_CODINT+BCK_CODLOC+BCK_CODUNI
		if BCK->(msSeek(xFilial("BCK")+cCodRda+cCodInt+cCodLoc+cCodUnd))
		
			while ! BCK->(eof()) .and. BCK->(BCK_FILIAL+BCK_CODIGO+BCK_CODINT+BCK_CODLOC+BCK_CODUNI) == xFilial("BCK")+cCodRda+cCodInt+cCodLoc+cCodUnd
				
				if PLSINTVAL("BCK","BCK_VIGINI","BCK_VIGFIN",dDatAnalise)

					nVlrUS := BCK->BCK_US

					if nVlrUS > 0
						
						lOk     := .t.
						cAlias  := "BCK"
						aVigAtu	:= {cAlias, BCK->BCK_VIGINI, BCK->BCK_VIGFIN}

						exit

					endIf	

				endIf
				
			BCK->(dbSkip())
			endDo

		endIf

	elseIf aOrdensNiv[nForNiv] $ "BAX" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso

		BAX->(dbSetOrder(1))
		
		cSubEsp := iIf(!empty(cSubEsp), cSubEsp, "")
		
		if BAX->(msSeek(xFilial("BAX")+cCodRDA+cCodInt+cCodLoc+cCodEsp+cSubEsp))
			
			nBanda := BAX->BAX_BANDA			

			if BAX->BAX_FORMUL == "1"
			
				nVlrUS  := BAX->BAX_VALCH
				
			elseIf BAX->BAX_FORMUL == "2"
				
				//Verifico a consistencia da expressao            
				aCop := {}
				aCop := PLSParAna(BAX->BAX_EXPRES)
				
				//Se nao tiver nenhum problema com a expressao, calculo o valor da US 
				
				if empty(aCop[1])
					
					nVlrUS := &(BAX->BAX_EXPRES)
					
					if ValType(nVlrUS) <> "N"
						nVlrUS 	:= 0
					endIf
					
				else
					
					PLSPOSGLO(PLSINTPAD(),__aCdCri030[1],__aCdCri030[2])

					lRet 	:= .f.
					cMsg    := PLSBCTDESC()
					cCodCri := __aCdCri030[1]
					
				endIf
				
			endIf

			if lBanda 
				lOk := ( nBanda > 0 )
			elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
				lOK := .t.
			endIf
			
			// Alimenta o alias caso encontre parametrizacao no BAX.
			if lOk
				
				cAlias 	:= "BAX"
				aVigAtu	:= {cAlias, BAX->BAX_VIGDE, dVigFim}

			endIf

		endIf 

	elseIf aOrdensNiv[nForNiv] $ "BAQ" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso
		
		BAQ->(dbSetOrder(1))
		if BAQ->(msSeek(xFilial("BAQ") + cCodInt + cCodEsp))
			
			nVlrUS  := BAQ->BAQ_VALCH
			nBanda 	:= BAQ->BAQ_BANDA

			if lBanda
				lOk := ( nBanda > 0 )
			elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
				lOK := .t.
			endIf

			if lOK
					 
				cAlias 	:= "BAQ"
				aVigAtu	:= {cAlias, dVigIni, dVigFim}

			endIf	

		endIf 
		
	elseIf aOrdensNiv[nForNiv] $ "BMD" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso
		
		BMD->(dbSetOrder(1))
		if BMD->(msSeek(xFilial("BMD")+cCodInt+cCodPla+cVrProduto+cTipPre))
			
			while !BMD->(eof()) .and. BMD->(BMD_CODIGO+BMD_VERSAO+BMD_TIPPRE) == cCodInt+cCodPla+cVrProduto+cTipPre
				
				//Vou pegar a data de vigencia q se encaixa no intervalo definido    
				//Se ele entrar eh porque achou o intrevalo, e acaba o loop		
		
				if PLSINTVAL("BMD","BMD_VIGDE","BMD_VIGATE",dDatAnalise)
		
					if empty(BMD->BMD_DATDE) .or. dtos(dDatAnalise) >= dtos(BMD->BMD_DATDE)
						nVlrUS := BMD->BMD_VALUS
					else
						nVlrUS := BMD->BMD_VALUSA
					endIf

					nBanda 	:= BMD->BMD_BANDA

					if lBanda 
						lOk := ( nBanda > 0 )
					elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
						lOK := .t.
					endIf

					if lOk	
						cAlias    := "BMD"
						aVigAtu	  := { cAlias, BMD->BMD_DATDE, BMD->BMD_VIGATE }
						exit
					endIf

				endIf
				
			BMD->(dbSkip())
			endDo
				
		endIf
		
    elseIf aOrdensNiv[nForNiv] $ "BHF" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lPorteMed .and. ! lReembolso
    
		BHF->(dbSetOrder(1)) //BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB
		
		if empty(cChvEvento)
			cChvEvento := Alltrim(BD6->BD6_CHVNIV)
		endIf

		if BHF->( msSeek( xFilial("BHF")+allTrim(cChvEvento)) )
			
			while !BHF->(eof()) .and. xFilial("BHF")+allTrim(cChvEvento) == BHF->(BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB+BHF_CODPRO+BHF_VERPRO+BHF_CODGRU)                     

				//Vou pegar a data de vigencia q se encaixa no intervalo definido    
				//Se ele entrar eh porque achou o intrevalo, e acaba o loop		
		
				if PLSINTVAL("BHF","BHF_VIGINI","BHF_VIGFIN",dDatAnalise)
					
					nVlrUS := BHF->BHF_VALUS	
					if nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
	
						lOk    := .t.
						cAlias := "BHF"
						aVigAtu:= { cAlias, dVigIni ,dVigFim }
	
						exit
	
					endIf	
				endif
				
			BHF->(dbSkip())
			endDo
			
		endIf
               
	elseIf aOrdensNiv[nForNiv] $ "BB8" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso .and. lFoundBB8

		if BB8->BB8_FORMUL == "1"
		
			nVlrUS  := BB8->BB8_VALCH
			nBanda 	:= BB8->BB8_BANDA

		elseIf BB8->BB8_FORMUL == "2"
			
			//Verifico a consistencia da expressao            
			
			aCop := {}
			aCop := PLSParAna(BB8->BB8_EXPRES)
			
			//Se nao tiver nenhum problema com a expressao, calculo o valor da US 
			if empty(aCop[1])
				
				nVlrUS  := &(BB8->BB8_EXPRES)
				nBanda 	:= BB8->BB8_BANDA
				
				if ValType(nVlrUS) <> "N"
					nVlrUS  := 0
				endIf

			else
				
				PLSPOSGLO(PLSINTPAD(),__aCdCri031[1],__aCdCri031[2])
				
				lRet 	:= .f.
				cMsg    := PLSBCTDESC()
				cCodCri := __aCdCri031[1]
				
			endIf
			
		endIf

		if lBanda 
			lOk := ( nBanda > 0 )
		elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
			lOK := .t.
		endIf
		
		if lOK

			cAlias  := "BB8"
			aVigAtu	:= {cAlias, BB8->BB8_VIGUS, dVigFim}

		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BMF" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso .and. cTipoUsr == "2"
		
		BMF->(dbSetOrder(1))
		if BMF->(msSeek(xFilial("BMF")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cTipPre))
			
			aRegs := {}
			while !BMF->(eof()) .and. xFilial("BMF")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cTipPre == BMF->(BMF_FILIAL+BMF_CODINT + BMF_CODEMP + BMF_NUMCON + BMF_VERCON + BMF_SUBCON + BMF_VERSUB + BMF_TIPPRE)
				
				aadd(aRegs,{ BMF->(recno()), BMF->(BMF_DATDE) })

			BMF->(dbSkip())
			endDo   
												
			//Ordeno pelo DATDE maior ou seja vai pegar o de vigencia mais nova primeiro
			aRegs := aSort(aRegs,,,{|x,y| x[2] >= y[2] }) 
			
			for nR := 1 to len(aRegs)	 
			
				BMF->(dbGoTo(aRegs[nR][1]))
				
				if empty(BMF->BMF_DATDE) .or. dtos(dDatAnalise) >= dtos(BMF->BMF_DATDE)
					nVlrUS := BMF->BMF_VALUS
				else
					nVlrUS := BMF->BMF_VALUSA
				endIf
				
				nBanda 	:= BMF->BMF_BANDA

				if lBanda 
					lOk := ( nBanda > 0 )
				elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
					lOK := .t.
				endIf

				if lOk
					
					cAlias    := "BMF"
					aVigAtu	  := {cAlias,BMF->BMF_DATDE, dVigFim}
					exit

				endIf	 

			next

		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BMH" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso .and. cTipoUsr == "2"
			
		BMH->(dbSetOrder(1)) //BMH_FILIAL + BMH_CODINT + BMH_CODEMP + BMH_NUMCON + BMH_VERCON + BMH_SUBCON + BMH_VERSUB + BMH_CODRDA
		if BMH->(msSeek(xFilial("BMH")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA))
			
			aRegs := {}
			
			while !BMH->(eof()) .and. xFilial("BMH")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA == BMH->(BMH_FILIAL+BMH_CODINT+BMH_CODEMP+BMH_NUMCON+BMH_VERCON+BMH_SUBCON+BMH_VERSUB+BMH_CODRDA)
					
					aadd(aRegs,{BMH->(recno()),BMH->(BMH_DATDE)})      

			BMH->(dbSkip())  
			endDo               
			
			//Ordeno pelo DATDE maior ou seja vai pegar o de vigencia mais nova primeiro
			aRegs := aSort(aRegs,,,{|x,y| x[2] >= y[2] }) 
			
			for nR := 1 to len(aRegs)	 
				
				BMH->(dbGoTo(aRegs[nR][1]))  
				
				if empty(BMH->BMH_DATDE) .or. dtos(dDatAnalise) >= dtos(BMH->BMH_DATDE)
					nVlrUS := BMH->BMH_VALUS
				else
					nVlrUS := BMH->BMH_VALUSA
				endIf
				
				nBanda 	:= BMH->BMH_BANDA

				if lBanda 
					lOk := ( nBanda > 0 )
				elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
					lOK := .t.
				endIf

				if lOk
					
					cAlias    := "BMH"
					aVigAtu	  := {cAlias,BMH->BMH_DATDE, dVigFim}

					exit

				endIf		   

			next

		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BML" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso .and. cTipoUsr == "2"
		
		BML->(dbSetOrder(1)) //BML_FILIAL + BML_CODINT + BML_CODEMP + BML_NUMCON + BML_VERCON + BML_SUBCON + BML_VERSUB + BML_CODESP
		if BML->(msSeek(xFilial("BML")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodEsp))
			
			aRegs := {}
			
			while !BML->(eof()) .and. xFilial("BML")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodEsp == BML->(BML_FILIAL+BML_CODINT+BML_CODEMP+BML_NUMCON+BML_VERCON+BML_SUBCON+BML_VERSUB+BML_CODESP)
				
				aadd(aRegs,{BML->(recno()),BML->(BML_DATDE)})                                          

			BML->(dbSkip())
			endDo	
			
			//Ordeno pelo DATDE maior ou seja vai pegar o de vigencia mais nova primeiro
			aRegs := aSort(aRegs,,,{|x,y| x[2] >= y[2] }) 
				
			for nR := 1 to len(aRegs)	 
				
				BML->(dbGoTo(aRegs[nR][1]))
				
				if  empty(BML->BML_DATDE) .or. dtos(dDatAnalise) >= dtos(BML->BML_DATDE)
					nVlrUS := BML->BML_VALUS
				else
					nVlrUS := BML->BML_VALUSA
				endIf

				nBanda 	:= BML->BML_BANDA

				if lBanda 
					lOk := ( nBanda > 0 )
				elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
					lOK := .t.
				endIf

				if lOk

					cAlias    := "BML"
					aVigAtu	  := {cAlias,BML->BML_DATDE, dVigFim}

					exit

				endIf	  

			next
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BFM" .and. ( ! lInterc .or. lChkNvLoc ) .and. ( ! lReembolso .or. ( lReembolso .and. nUSEspec == 0 ) )
    
		BFM->(dbSetOrder(1))      

		//Parametro criado para cachoeiro la eles usam o parametro == "1" 	   
		//Ele pega a competencia da data de analise							   
		if getNewPar("MV_PLRDBFM","0") == "1"
			
			aRetAux  := PLSXVLDCAL(dDatAnalise, PLSINTPAD(), .t., cCodPad, cCodPro, nil, cCodRDA, lReembolso)

			if len(aRetAux) >= 4
				cDataCom := aRetAux[4] + aRetAux[5]
			endIf
			
		else
			cDataCom := cAno + cMes
		endIf               
		
		if BFM->(msSeek(xFilial("BFM") + cCodInt + cDataCom)) 
			
			if lReembolso
				
				nVlrUS := BFM->BFM_VALREM

			else	

				nVlrUS := BFM->BFM_VALRDA

				if allTrim(cCodUnd) == "COP"
					nVlrUS := BFM->BFM_VALCOP
				endIf

				nBanda 	:= BFM->BFM_BANDA

			endIf
			
		endIf

		if lBanda 
			lOk := ( nBanda > 0 )
		elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
			lOK := .t.
		endIf

		if lOk
			
			cAlias 		:= "BFM"
			aVigAtu		:= { cAlias, dVigIni ,dVigFim }

			exit

		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BMC" .and. ( ( ! lInterc .or. lChkNvLoc ) .or. ( lReembolso .and. nUSEspec == 0 ) .or. lPLVLBMC )
		
		if ( ! lInterc .or. lChkNvLoc ) .or. ( lReembolso .and. nUSEspec == 0 )
			
			cSQL := "SELECT BMC_NIVEL,BMC_VALUS, BMC_VALUSA, BMC_DATDE, BMC_VLRPAG, BMC_TABPRE, "
			cSQL += "       BMC_VIGDE, BMC_VIGATE , BMC_VLUSRE, BMC_VLRPGA, BMC_BANDA "
			cSQL += "  FROM " + cNameBMC + " WHERE "
			cSQL += "BMC_FILIAL = '" + xFilial("BMC") + "' AND "
			cSQL += "BMC_CODINT = '" + cCodInt + "' AND "
			cSQL += "BMC_TIPPRE = '" + cTipPre + "' AND "
			cSQL += "BMC_CODPAD = '" + cCodPad + "' AND "
			
			cSQL += PLREQNI("BMC", "BMC_CODPSA", __aNiveis[2], allTrim(cCodPro))

			cSQL += "( '" + dtos(dDatAnalise) + "' >= BMC_VIGDE  OR BMC_VIGDE = ' ' ) AND "
			cSQL += "( '" + dtos(dDatAnalise) + "' <= BMC_VIGATE OR BMC_VIGATE = ' ' ) AND "
			
			cSQL +=  cNameBMC + ".D_E_L_E_T_ = ' ' "
			
			cSQL +=  " ORDER BY BMC_NIVEL DESC "
	
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
			
			if ! PLSAUTPDIR->(eof())
		
				plsTField("PLSAUTPDIR",.f.,{ "BMC_VIGDE","BMC_VIGATE","BMC_DATDE","BMC_VALUS","BMC_VLRPAG","BMC_BANDA","BMC_VLRPGA","BMC_VALUSA","BMC_VLUSRE" } )

				//Se a vigencia estiver dentro do limite parametrizado...	
				if PLSINTVAL("PLSAUTPDIR","BMC_VIGDE","BMC_VIGATE",dDatAnalise)
				
					//Se o campo APOS DATA não tiver preenchido vou pegar os valores 	
					//padroes, ao contrario verifico a data do campo com a data base da  
					//analise                                                            
					//Tratamento da nova amarração com a tabela de preço/valorização.
					if ! empty(PLSAUTPDIR->BMC_TABPRE)
					
						__XaRetTabPre := PLVLTBPR(PLSAUTPDIR->BMC_TABPRE, cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BMC',cCodEsp,cCodUnd, lCobCoPart)
					
						PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
									@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, PLSAUTPDIR->BMC_VIGDE, PLSAUTPDIR->BMC_VIGATE, @lOkAD)
														
						if lBanda 
							lOk := ( nBanda > 0 )
						endif
					else
									
						if lReembolso

							nVlrUS := PLSAUTPDIR->BMC_VLUSRE             

						else	 

							if empty(PLSAUTPDIR->BMC_DATDE) .or. dtos(dDatAnalise) >= dtos(PLSAUTPDIR->BMC_DATDE)
								nVlrUS 	:= PLSAUTPDIR->BMC_VALUS
								nVlrRea := PLSAUTPDIR->BMC_VLRPAG	
							else
								nVlrUS 	:= PLSAUTPDIR->BMC_VALUSA
								nVlrRea := PLSAUTPDIR->BMC_VLRPGA
							endIf
							
							nBanda 	:= PLSAUTPDIR->BMC_BANDA

						endIf
						
						//somente quando vem da PLSRTBANDA - lBanda  
						if lBanda 
							lOk := ( nBanda > 0 )
						elseIf (nVlrUS > 0 .or. nVlrRea > 0) .or. (lPorteMed .and. nBanda > 0 )
							lOK := .t.
						endIf

						if lOk	

							cAlias    := "BMC"
							aVigAtu	  := { cAlias, PLSAUTPDIR->BMC_VIGDE, PLSAUTPDIR->BMC_VIGATE }

						endIf

					endIf
						
				endIf
			
			endIf
			
			PLSAUTPDIR->(dbCloseArea())
			
		elseIf lPLVLBMC

			aRetBMC := execBlock("PLVLBMC",.f.,.f.,{lInterc,lChkNvLoc,lReembolso,nNiveis,cCodInt,cTipPre,cCodPro,;
													__aNiveis,dDatAnalise,cNameBMC,lOk})
			
			nVlrUS    := aRetBMC[1]
			cAlias    := aRetBMC[2]
			lOk       := aRetBMC[3]
			nVlrRea   := aRetBMC[4]
			
		endIf

	elseIf aOrdensNiv[nForNiv] $ "BMB" .and. ( ( ! lInterc .or. lChkNvLoc ) .or. ( lReembolso .and. nUSEspec == 0 ) )

		BMB->(dbSetOrder(1))

		for nBmb := 1 to 2  
			
			// Primeiro tenta achar parametrização para o tipo de prestador corrente.
			// Se não achar, tenta achar parametrização generica.
			if nBmb == 1
				cAuxTipPre := cTipPre
			else
				cAuxTipPre := space(TamSX3("BMB_TIPPRE")[1])
			endIf
			
			if BMB->(msSeek(xFilial("BMB")+cCodInt+cAuxTipPre))
				
				// Se encontrar na primeira passada, nao permite a segunda passada.
				lContinua := .f.
				
				//Vou varrer o BMB ate encontrar uma vigencia que me atenda 		
				while BMB->(!eof()) .and. BMB->(BMB_CODINT+BMB_TIPPRE) == cCodInt+cAuxTipPre
					
					//Se a vigencia estiver dentro do limite parametrizado...			 
					if PLSINTVAL("BMB","BMB_VIGDE","BMB_VIGATE",dDatAnalise)
						
						//Se o campo APOS DATA não tiver preenchido vou pegar os valores 	
						//padroes, ao contrario verifico a data do campo com a data base da  
						//analise                                                            
						
						// Tratamento da nova amarração com a tabela de preço/valorização.
						if ! empty(BMB->BMB_TABPRE)
						
							__XaRetTabPre := PLVLTBPR(BMB->BMB_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BMB',cCodEsp,cCodUnd, lCobCoPart)
							
							if PLSRTPUS(__XaRetTabPre, lUndCop, lPorteMed, lPorteAnestesico, lBanda, lCobCoPart, cModPag, aOrdensNiv[nForNiv], cCodUnd, @cAlias, @lOk, @nUSEspec, @nVlrUS, @nVlrRea,;
										@nBanda, @nRef, @nAcrescimo, @nDesconto, @cCodTab, @cPorteMed, @aVigAtu, BMB->BMB_VIGDE, BMB->BMB_VIGATE, @lOkAD) .OR. lOkAD
								
								exit
								
							endIf	
							
						else
						
							if lReembolso
							
								nVlrUS := BMB->BMB_VLUSRE
								
							else
							
								if empty(BMB->BMB_DATDE) .or. dtos(dDatAnalise) >= dtos(BMB->BMB_DATDE)
									
									nVlrUS := BMB->BMB_VALUS
									
									//Custo Operacional
									if allTrim(cModPag) != "1" 
										nVlrUS := BMB->BMB_VLUSCO
									endIf

								else

									nVlrUS := BMB->BMB_VALUSA
									
									//Custo Operacional
									if allTrim(cModPag) != "1" 
										nVlrUS := BMB->BMB_VLUACO
									endIf
									
								endIf
								
								nBanda 	:= BMB->BMB_BANDA

							endIf

							nVlrRea := 0

							//somente quando vem da PLSRTBANDA - lBanda  
							if lBanda 
								lOk := ( nBanda > 0 )
							elseIf nVlrUS > 0 .or. (lPorteMed .and. nBanda > 0 )
								lOK := .t.
							endIf
							
							if lOk	

								cAlias    := "BMB"
								aVigAtu	  := { cAlias, BMB->BMB_VIGDE, BMB->BMB_VIGATE }

								exit

							endIf	  

						endIf
						
					endIf
					
				BMB->(dbSkip())
				endDo 
					
			endIf
			
			if lOK
				exit
			endIf
			
		next
		
    endIf 
	
	if lOk .OR. lOkAD
		exit
	endIf

next

If lOk .OR. lOkAD
	cMeMorial += "Nível utilizado: " + cAlias + CRLF
	If !lBanda
		cMeMorial += " Valor de US parametrizado: " + alltrim(Str(nVlrUS)) + CRLF
		cMeMorial += " Valor em real parametrizado: " + alltrim(Str(nVlrRea)) + CRLF
		If lPorteMed
			cMeMorial += " Porte médico parametrizado: " + cPorteMed + CRLF
		endIf
	else
		cMeMorial += " Percentual da banda: " + alltrim(Str(nBanda)) + CRLF
	endIf
endIf

if lPLSALTUV

	aRetPtoEnt 	:= execBlock("PLSALTUV",.f.,.f.,{nVlrUS,cAlias,lOK,nVlrRea,cCodRda,cCodInt,cCodLoc,cCodEsp,cRegAte,lCobCoPart,cCodPro,cCodUnd,dDatAnalise,cCodPad,nBanda})
	nVlrUS    	:= aRetPtoEnt[1]
	nVlrRea 	:= aRetPtoEnt[2]
	cAlias  	:= aRetPtoEnt[3]

	if len(aRetPtoEnt) >= 4
		lCoUSEs := aRetPtoEnt[4]
	else
		lCoUSEs := .t.
	endIf
	
	if len(aRetPtoEnt) >= 6
		nBanda 	:= iIf(! lCobCoPart, aRetPtoEnt[5], aRetPtoEnt[6])
	endIf

	if ! lOK .and. (nVlrUS > 0 .or. nVlrRea > 0)
		lOK := .t.
	endIf
	cMeMorial += "Executada regra customzada PLSALTUV" + CRLF
	cMeMorial += " Valores Após regra aplicada: " + CRLF
	cMeMorial += "Nível utilizado: " + cAlias + CRLF
	If !lBanda
		cMeMorial += " Valor de US: " + alltrim(Str(nVlrUS)) + CRLF
		cMeMorial += " Valor em real: " + alltrim(Str(nVlrRea)) + CRLF
	else
		cMeMorial += " Percentual da banda: " + alltrim(Str(nBanda)) + CRLF
	endIf
endIf

//Ponto de entrada para manipular o valor do Porte
if lPLSVLRPM
	aRetPtoEnt := execBlock("PLSVLRPM",.f.,.f.,{ aDadUsr, cPorteMed, nVlrUS, cAlias, lOK, nVlrRea, cCodRda, cCodInt, cCodLoc, cCodEsp, cRegAte, lCobCoPart, cCodPro, cCodUnd, dDatAnalise, cCodPad, cCodTab })
	cPorteMed  := aRetPtoEnt[1]
	If !lBanda .AND. lPorteMed
		cMeMorial += "Executada regra customzada PLSVLRPM" + CRLF
		cMeMorial += " Valores Após regra aplicada: " + CRLF
		cMeMorial += " Porte médico: " + cPorteMed + CRLF
	endIf
endIf

//nRefUs sera atualizado somente quando o parametro lCosRefCH estiver ligado
nRefUS := nRef

//Porte Medico
if lPorteMed 

	//caso onde queira variar o porte com base na valoracao nova Valor do folder US. Valor da US B28_VALOR x Referencia B23_QTDUS
	if lMV_PLUSPPM .and. lOk .and. nVlrUS > 0
		
		nValDef	:= nVlrUS
		nVlrUS  := ( nVlrUS * nRef ) 
	
	//Atencao: parametro lCosRefCH desligado e parametro lMV_PLUSPPM desligado olha niveis da valoracao nova desnecessariamente.
	//Se o parametro lCosRefCH estiver ligado vale o nivel onde encontrar US
	//Se desligado vale o nivel onde encontrar valor valoracao antiga
	//Se achou US mais nao achou valor pega o valor do porte para fazer o calculo Valor * Referencia * US do nivel
	elseIf nVlrRea == 0

		BW4->(dbSetOrder(1))
		if BW4->( msSeek( xFilial("BW4") + cCodInt + cCodTab + cPorteMed ) )
			
			while allTrim(BW4->BW4_CODOPE) == allTrim(cCodInt) .and. allTrim(BW4->BW4_CODTAB) == allTrim(cCodTab) .and. allTrim(BW4->BW4_PORTE) == allTrim(cPorteMed)
				
				if PLSINTVAL('BW4','BW4_VIGINI','BW4_VIGFIN',dDatAnalise)
					nValorPMed := BW4->BW4_VLRREA
				endIf
				
				if nValorPMed > 0

					//vale o nivel de US ou Valor
					if ! lOk
						cAlias  := "BW4"
						aVigAtu	:= { cAlias, BW4->BW4_VIGINI, BW4->BW4_VIGFIN }
					endIf	

					lOK := .t.
					If !lBanda
						cMeMorial += " Valor do porte: " + alltrim(str(nValorPMed)) + CRLF
					endIf
					exit

				endIf

			BW4->(dbSkip())
			endDo

			// Multiplica o valor pela referencia. A referencia pode ter vindo da TDE ou da Tabela de Preco.
			if allTrim(cCodUnd) != "PAP" 

				// possibilidade de incluir a US no calculo do valor do PORTE. lCosRefCH ligado
				if lCosRefCH .and. nVlrUS > 0 
					
					nRefUS := nVlrUS
					nVlrUS := ( ( nValorPMed * nRef ) * nVlrUS )

				else

					nVlrUS := ( nValorPMed * nRef ) 

				endIf	

			else
				nVlrUS  := nValorPMed
			endIf

			nValDef	:= nValorPMed

		endIf

	else
		If !lBanda
			cMeMorial += " Valor definido em real: " + alltrim(str(nVlrRea)) + CRLF
		endIf
		nVlrUS  := nVlrRea
		nValDef	:= nVlrRea	

	endIf

	cDesUni	:= "P.Med"

//nao e porte medico
else
	
	if nUSEspec > 0 .and. lCoUSEs

		//Se for reembolso.....
		if ! lOK .and. lReembolso
		
			nVlrUS  := nUSEspec
			cAlias  := "REM"
			lOk     := .t.
			
		endIf

		//Caso em que a US é de copart (nível BGH por exemplo) precisa sobreescrever o menos específico
		if ! empty(cAlEspec) .and. lCobCoPart
			
			aNvCopartZ := Separa(getNewPar("MV_PLNVCP", "BOR,BVM,BVJ,BVF,BVC,BNZ,BLW,BLX,BGL,BHE,BGS,BHF,BGH,BS9,BYK,BGD,BHD,BB2,BCW,BHI,B86,BHJ,BHK,BSY,BHC,BWW"),",")
			nAliEspec  := aScan(aNvCopartZ, cAlEspec)
			nAliAtual  := aScan(aNvCopartZ, cAlias)
			
			//Se a Us Específica for mais específica, sobreescreve
			//Como a BC5 não é uma tabela de cooparticipação, caso seja ela não sobreescreve 
			if (nAliEspec > 0 .and. (nAliEspec <= nAliAtual .or. nAliAtual == 0)	) .and. cAlias <> "BC5"
				nVlrUS 	:= nUSEspec
				cAlias	:= cAlEspec
				lOK 	:= .t.
			endIf

		endIf

	endIf	

	//pacote								
	if len(aPacote) >= 4 .and. aPacote[2] > 0
		
		nRef 	:= aPacote[2]
		cAlias	:= iIf( ! empty(aPacote[4]), aPacote[4], "B43" )
		lOK 	:= .t.
		
	endIf
	
	if nVlrUS > 0
		
		nValDef := nVlrUS
		nVlrUS  := (nVlrUS * nRef)   
	
		cDesUni := "U.S"
		If !lBanda
			cMeMorial += " Valor da US: " + AllTrim(str(nValDef)) + CRLF
			cMeMorial += " Referência x Valor da US: " + Alltrim(str(nVlrUS)) + CRLF
		endIf
	elseIf nVlrRea > 0

		nValDef	:= nVlrRea
		nVlrUS 	:= nVlrRea

		cDesUni := "Valor (U.S)"
		If !lBanda
			cMeMorial += " Valor definido em real: " + allTrim(str(nVlrRea)) + CRLF
		endIf
	endIf

endIf

if lOk

	// Aplica percentual de aumento ou redução
	if allTrim(cCodUnd) $ allTrim(cMVPLSUNPR) .and. nPrPrRl <> 0
		nVlrUS := nVlrUS + ( ( nVlrUS * nPrPrRl ) / 100 )
	endIf

	if cConsFt == "1"
		
		nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(cCodUnd) })
		
		if nPos > 0
			nFatMul := iIf( len(aRdas[nPos])>= 10,iIf(aRdas[nPos,10] <> "0",nFatMul,1) ,nFatMul	)
		endIf
		If !lBanda
			cMeMorial += " Fator multiplicador: " + alltrim(str(nFatMul)) + CRLF
		endIf
		nVlrUS := nVlrUS * nFatMul
		If !lBanda
			cMeMorial += " Valor x por fator : " + alltrim(str(nVlrUS)) + CRLF
		endIf
	endIf

	if cConsBd == "1" 

		if !lBanda
					
			nBanda := PLSRTBANDA(cCodInt,cAno,cMes,lCobCoPart,lInterc,cOpeInt,dDatAnalise,nNiveis,__aNiveis,cCodPro,;
								 cModPag,cCodPad,cCodEsp,cCodUnd,cCodPla,nVlrApr,if(cREGGOP=="1",cGRUOPE,""),nUSEspec,paramixb,cFinAte)
							
		endIf
		
		if nBanda > 0
		//	If !lBanda
		//		cMeMorial += " Percentual da banda: " + AllTrim(str(nBanda)) + CRLF
		//	endIf	
			nVlrUS := ( nVlrUS * nBanda ) / 100
			If !lBanda
				cMeMorial += " Valor x Banda: " + allTrim(str(nVlrUS)) + CRLF	
			endIf
		endIf

	endIf

	if nDesconto > 0
		If !lBanda
			cMeMorial += " Percentual de desconto: " + alltrim(str(nDesconto)) + CRLF	
		endIf
		nVlrUS := ( nVlrUS - ( nVlrUS * nDesconto ) / 100)
		If !lBanda
			cMeMorial += " valor aplicado desconto: " + AllTrim(str(nVlrUS)) + CRLF	
		endIf
	endIf

	if nAcrescimo > 0
		If !lBanda
			cMeMorial += " Percentual da Acréscimo: " + AllTrim(str(nAcrescimo)) + CRLF
		endIf	
		nVlrUS := ( nVlrUS + ( nVlrUS * nAcrescimo ) / 100)
		If !lBanda
			cMeMorial += " valor aplicado acréscimo: " + AllTrim(str(nVlrUS)) + CRLF	
		endIf
	endIf
	If !lBanda
		cMeMorial += "O valor da unidade é: " + AllTrim(str( round(nVlrUS, nDecBAS))) + CRLF	
	endIf
	aadd(aRetUS, { round(nRef, nDecREF ), cAlias, round(nValDef, nDecCOF ), round(nVlrUS, nDecBAS ) * nQtd , round(nVlrUS, nDecBAS ) * nQtd, nFatMul, cDesUni, 0, iIf(! lCobCoPart, nBanda, 0), cConsBd, '0', nRefUS, iIf(! lCobCoPart, 0, nBanda), nDesconto, nAcrescimo })
	
endIf

aRETUSNV := { lOK, cMsg, cCodCri, aRetUS, round(nVlrUS, nDecBAS ) * nQtd, aVigAtu }
	
return( aClone(aRETUSNV) )


/*/{Protheus.doc} PLSRETVPA
Retorna o porte anestesico.

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETVPA(paramixb, lObsoleto)
local nQtd       	:= paramixb[1]
local nRef       	:= paramixb[2] //Esta referencia e o Porte
local aRet       	:= paramixb[3]
local dDatAnalise	:= paramixb[4]                                                        
local cCodRDA    	:= paramixb[5]
local cCodInt    	:= paramixb[6]
local cCodLoc    	:= subStr(paramixb[7],1,3)
local cCodTab    	:= paramixb[8]
local cCodPad    	:= paramixb[9]
local cCodPro    	:= paramixb[10]
local cMes       	:= paramixb[11]
local cAno       	:= paramixb[12]
local cCodEsp     	:= paramixb[13]
local cModPag    	:= paramixb[15]
local nVlrApr    	:= paramixb[17]                                                 
local cTipPre    	:= paramixb[18]  
local aDadUsr    	:= iIf(len(paramixb[19])>0, paramixb[19], "")
local cCodEmp    	:= iIf(len(paramixb[19])>0, subStr(paramixb[19,2],atCodEmp[1],atCodEmp[2]), "")
local cTipoUsr   	:= iIf(len(paramixb[19])>0, paramixb[19,8], "")
local cConEmp    	:= iIf(len(paramixb[19])>0, paramixb[19,9], "")
local cCodPla    	:= iIf(len(paramixb[19])>0, paramixb[19][11], "")
local cVersao    	:= iIf(len(paramixb[19])>0, paramixb[19][12], "")
local cVerCon    	:= iIf(len(paramixb[19])>0, paramixb[19,39], "")
local cSubCon    	:= iIf(len(paramixb[19])>0, paramixb[19,41], "")
local cVerSub    	:= iIf(len(paramixb[19])>0, paramixb[19,42], "")   
local cOpeOri    	:= iIf(len(paramixb[19])>0, paramixb[19,45], "")
local cREGGOP    	:= iIf(len(paramixb[19])>0, paramixb[19,63], "")
local cGRUOPE    	:= iIf(len(paramixb[19])>0, paramixb[19,64], "")
local nFatMul    	:= paramixb[20]
local cConsFt    	:= paramixb[21]
local nUSEspec   	:= paramixb[22]
local lCobCoPart 	:= paramixb[25]    
local nPrPrRl		:= paramixb[27]                                             
local cPadInt    	:= paramixb[29]                                     
local cRegAte  	 	:= paramixb[30]
local aRdas 	 	:= paramixb[34]
local cCodUnd    	:= paramixb[35]
local lReembolso 	:= paramixb[36]
local cConsBd    	:= paramixb[38]
local cPorteMed  	:= paramixb[39]
local aVlBloq    	:= paramixb[42]
local cRegPag 	 	:= paramixb[44]                                                
local cRegCob	 	:= paramixb[45]
local cFinAte  	 	:= paramixb[47]

local nVlrCOEF     	:= 0
local nVlrPARea  	:= 0
local nVlrPAAcu  	:= 0
local nBanda     	:= 0
local nNiveis   	:= 0     
local nBmb		 	:= 0
local nFor		 	:= 0
local nTab		 	:= 0
local nForNiv 	 	:= 0                   
local nPos		 	:= 0
local nRetUS		:= 0
local nDecREF		:= iIf( ! lCobCoPart, PLGetDec('BD7_REFTDE'), PLGetDec('BD7_RFTDEC'))
local nDecCOF		:= iIf( ! lCobCoPart, PLGetDec('BD7_COEFUT'), PLGetDec('BD7_COEFPF'))
local nDecBAS		:= iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'), PLGetDec('BD7_VLRBPF'))
local nDecSEP		:= PLGetDec('BKF_SEQPOR')
local cCodPla 		:= if(len(aDadUsr)>=11,aDadUsr[11],"")
local cVrProduto 	:= if(len(aDadUsr)>=12,aDadUsr[12],"")
local cAlias     	:= ""
local cSQL			:= ""
local cMsg			:= ""
local cCodCri		:= ""
local cOpeInt      	:= ""              
local cNameBS0	 	:= BS0->(retSqlName("BS0"))
local cNameBMC	 	:= BMC->(retSqlName("BMC"))
local lOK        	:= .f.     
local lInterc    	:= .f.
local lFoundBB8		:= .f.
local lZeraTudo  	:= (getNewPar("MV_PLSGUI0","0") == "1")	// Rever este conceito.
local aRetPA     	:= {}
local aRetInt    	:= {}
local aTabs		 	:= {}
local aRetPto		:= {}
local aRetFunc		:= {}
local __XaRetTabPre	:= {.f.,{}}
local aRetAux	 	:= {}
local aVigAtu		:= {}
local dVigIni	 	:= ctod("")
local dVigFim	 	:= ctod("")
Local nR			:= 0
local lChkNvLoc  	:= (getNewPar("MV_PLSCRLI","0") == "1")
local lPLSBE9SK     := existBlock("PLSBE9SK")
Local nVlrPARea	    := 0
Local nvlrUs		:= 0 
Local lFoundBE9  	:= .f. 
local lPorBKF 		:= .t.
Local nAcrescimo	:= 0
Local nDesconto		:= 0

default lObsoleto 	:= .f.

if __cCdTbPd <> cCodPad .or. len(__aNiveis) == 0
	__cCdTbPd := cCodPad
	__aNiveis := PLSESPNIV(cCodPad)
endIf	

nNiveis := (__aNiveis[1]+1)
                   
nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(cCodUnd) }) 

if (nPos > 0) .and. (nPos <= len(aRdas))
	nFatMul := iIf( len(aRdas[nPos])>= 10,iIf(aRdas[nPos,10]<>"0",nFatMul,1) ,nFatMul	)
endIf	

if existBlock("PLSFIATE")
   cFinAte := execBlock("PLSFIATE",.f.,.f.,{cFinAte})
endIf

//Se for porte anestesico com porte de procedimento medico
if ! empty(cPorteMed)
	
	//TODO - 20/09/2018 - implementar variacao somente da sequencia do PORTE ANESTESICO
	//ta tabela de preco nova e sempre necessario informar a tabela de preco.
	aRetFunc := PLSRETUSNV(paramixb, .t., nil, nRef)

else
	
	//Verifica se e intercambio atraves de rotina generica
	aRetInt := PLINTERC( iIf( ! lCobCoPart, "1", "2"), cCodRda, cOpeOri, cRegPag, cRegCob)
	lInterc := aRetInt[1]
	cOpeInt := aRetInt[2]
	
	BB8->(dbSetOrder(1))
	lFoundBB8 := SeekBB8E(cCodRDA,cCodInt,cCodLoc)
	
	/*
	tratamento do porte anestesico nos niveis que tratam tabela de preço / valorizacao.
	===> Niveis que permitem parametrização da tabela de valorização.
	
	BS0 - Produto X Und X U.S
	BBI - RDA X local Atend X Especialidade X Planos...
	BMB - Operadora X Tipo de Prestador X U.S
	
	B24 - RDA X Tab Preços Generica
	BC5 - RDA X Tab Precos (Cabecalho)
	B29 - Tabela de preços
	
	B85 - Associacao X Classe X Tabela de Preco
	B12 - Estados X Municipios (Estado)
	B13 - Estados X Municipios (Municipio)
	B30 - RDA X Planos
	*/
	
	aOrdensNiv := { "BCK","BMH","BE9","BBI","BC6","BC5","BS9","BS0","BMC","BMB","B24","B30","B13","B12","B85","B29" }
	
	if existBlock("PLSONVPC")
		aOrdensNiv := execBlock("PLSONVPC",.f.,.f.,{aOrdensNiv,lCobCoPart,cCodRda,cOpeOri,"2"})
	endIf
	
	for nForNiv := 1 to len(aOrdensNiv)

		__XaRetTabPre	:= {.f.,{}} //Reinicia a cada passagem do loop para que só esteja preenchido quando sair se foi montado no nível que deu Ok.
		
		if aOrdensNiv[nForNiv] $ "BBI" .and. ! lInterc

			BBI->(dbSetOrder(1))
			if BBI->(msSeek(xFilial("BBI")+cCodRda+cCodInt+cCodLoc+cCodEsp+cCodPla))
				
				while !BBI->( eof() ) .and. BBI->BBI_CODIGO+BBI->BBI_CODINT+BBI->BBI_CODLOC+BBI->BBI_CODESP+BBI->BBI_CODPRO == cCodRDA+cCodInt+cCodLoc+cCodEsp+cCodPla
					
					// Verifica se a parametrização esta ativa e se esta vigente.
					if BBI->BBI_ATIVO <> "0" .and. PLSINTVAL("BBI","BBI_VIGDE","BBI_VIGATE",dDatAnalise)
						
						// Trata amarração com a nova tabela de preço/valorizacao.
						cTabVlr := iIf(!lCobCoPart, BBI->BBI_TABPRE, BBI->BBI_TABREC)

						if !empty(cTabVlr)

							__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'BBI',cCodEsp,cCodUnd,lCobCoPart)
							
							if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, BBI->BBI_VIGDE, BBI->BBI_VIGATE)
								
								exit								
								
							endIf
						else

							If !lCobCoPart
								nRetUS := BBI->BBI_VALCH
							Else
								nRetUS := BBI->BBI_USRECT
							Endif
								
							if nRetUS > 0
								
								lOk       := .t.
								cAlias    := "BBI"
								aVigAtu	  := { cAlias, BBI->BBI_VIGDE, BBI->BBI_VIGATE }
								
							endIf

						endIf
						
					endIf
					
				BBI->( dbSkip() )
				endDo
			endIf
						
		elseIf aOrdensNiv[nForNiv] $ "BCK"
			
			BCK->(dbSetOrder(1)) //BCK_FILIAL+BCK_CODIGO+BCK_CODINT+BCK_CODLOC+BCK_CODUNI                               
			if BCK->( msSeek( xFilial("BCK") + cCodRda + cCodInt + cCodLoc + cCodUnd ) )
			
			 	while ! BCK->(eof()) .and. BCK->(BCK_FILIAL+BCK_CODIGO+BCK_CODINT+BCK_CODLOC+BCK_CODUNI) == xFilial("BCK") + cCodRda + cCodInt + cCodLoc + cCodUnd
	      	
	      	   		if PLSINTVAL("BCK","BCK_VIGINI","BCK_VIGFIN",dDatAnalise)
						
						nRetUS := BCK->BCK_US

						if nRetUS > 0
							
							lOk       := .t.
							cAlias    := "BCK"
							aVigAtu	  := { cAlias, BCK->BCK_VIGINI, BCK->BCK_VIGFIN }
							
							exit

						endIf

					endIf
						
      			BCK->(dbSkip())                                   	 
  		 		endDo
  		 		    
			endIf

		elseIf aOrdensNiv[nForNiv] == "BC6"
			
			aRetTabPre := PLSTABPRE(cCodInt,cCodRda,cCodPad,cCodPro,dDatAnalise,cPadInt,cCodPla,cOpeOri,cCodLoc,lCobCoPart,cRegAte,cFinAte,cCodTab,lReembolso,cModPag, nRef, .F.)

			if len(aRetTabPre) > 0 .and. aRetTabPre[1]

				nVlrUS     	:= aRetTabPre[2,1]
				nVlrPARea     := aRetTabPre[2,2]

				If (nVlrUS > 0 .or. nVlrPARea > 0)
					lOK := .t.
				endIf

				if lOk				
					cAlias	:= aRetTabPre[3]
					aVigAtu	:= { cAlias, aRetTabPre[4][2] ,aRetTabPre[4][3] }				
				endIf
			endIf

		elseIf aOrdensNiv[nForNiv] $ "BC5"
		
			// Redefine as variaveis de controle
			cTabPre := ""
			lTabEsp := .f.
			
			// Verifica se existe tabela de preço no local de atendimento. Esse codigo se refere a tabela de preço X RDA BC5.
			if  lFoundBB8 .and. ! empty(BB8->BB8_TABPRE)
				cTabPre := BB8->BB8_TABPRE
				lTabEsp := .t.
			endIf
			
			// Verifica se existe tabela de preço especifica para esta RDA.
			BC5->(dbSetOrder(1))
			if BC5->( msSeek(xFilial("BC5")+cCodInt+cCodRda) )
				
				// Processa as vigencias.
				while ! BC5->(eof()) .and. BC5->(BC5_FILIAL+BC5_CODINT+BC5_CODRDA) == xFilial("BC5")+cCodInt+cCodRda
					
					// Testa regra de tabela especifica.
					if ( lTabEsp .and. cTabPre == BC5->BC5_TABPRE ) .or. ( ! lTabEsp )
						
						// Faz a analize da vigencia.
						if PLSINTVAL("BC5","BC5_DATINI","BC5_DATFIM",dDatAnalise)
				
							// Trata amarração com a nova tabela de preço/valorizacao.
							cTabVlr := iIf(!lCobCoPart, BC5->BC5_TABPRE, BC5->BC5_TABREC)

							if !empty(cTabVlr)

								__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'BC5',cCodEsp,cCodUnd, lCobCoPart)

								if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, BC5->BC5_DATINI, BC5->BC5_DATFIM)
									
									exit								
									
								endIf

							endIf
							
						endIf
						
					endIf
					
				BC5->( dbSkip() )
				endDo
				
			endIf
			
		elseIf aOrdensNiv[nForNiv] $ "BS0"
			
			cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBS0 + " WHERE "
			cSQL += "BS0_FILIAL = '" + xFilial("BS0") + "' AND "
			cSQL += "BS0_CODPRO = '" + cCodInt + cCodPla + "' AND "
			cSQL += "BS0_CODPAD = '" + cCodPad + "' AND "
			cSQL += "BS0_CODUNI = '" + cCodUnd + "' AND "
			
			cSQL += PLREQNI("BS0", "BS0_CODPSA", __aNiveis[2], allTrim(cCodPro))

			cSQL += "( '"+dtos(dDatAnalise)+"' >= BS0_VIGDE  OR BS0_VIGDE = ' ' ) AND "
			cSQL += "( '"+dtos(dDatAnalise)+"' <= BS0_VIGATE OR BS0_VIGATE = ' ' ) AND "
			
			cSQL +=  cNameBS0 + ".D_E_L_E_T_ = ' ' "
			
			cSQL +=  " ORDER BY BS0_NIVEL DESC "
			
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
			
			lFlag := .f.
			
			if ! PLSAUTPDIR->(eof())
				
				lFlag := .t.
				BS0->(dbGoTo(PLSAUTPDIR->(REC)))
					
			endIf	
			
			PLSAUTPDIR->(dbCloseArea())
					
			if lFlag
			
				// Trata amarração com a nova tabela de preço/valorizacao.
				cTabVlr := iIf(!lCobCoPart, BS0->BS0_TABPRE, BS0->BS0_TABREC)
				
				if !empty(cTabVlr)

					__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'BS0',cCodEsp,cCodUnd, lCobCoPart)

					PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, BS0->BS0_VIGDE, BS0->BS0_VIGATE)

				endIf
				
			endIf
			
			//Tratamento da diferenciacao da us por produto X unidade			   
			lFlag := .f.

			if getNewPar("MV_PLBS0UM","1") == "1"

				cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBS0 + " WHERE "
				cSQL += "BS0_FILIAL = '" + xFilial("BS0") + "' AND "
				cSQL += "BS0_CODPRO = '" + cCodInt + cCodPla + "' AND "
				cSQL += "BS0_CODUNI = '" + cCodUnd + "' AND "
				
				cSQL += "( '"+dtos(dDatAnalise)+"' >= BS0_VIGDE  OR BS0_VIGDE = ' ' ) AND "
				cSQL += "( '"+dtos(dDatAnalise)+"' <= BS0_VIGATE OR BS0_VIGATE = ' ' ) AND "
				
				cSQL +=  cNameBS0 + ".D_E_L_E_T_ = ' ' "
				
				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
				
				lFlag := .f.
				
				if ! PLSAUTPDIR->(eof())
					
					lFlag := .t.
					BS0->(dbGoTo(PLSAUTPDIR->(REC)))
						
				endIf	
				
				PLSAUTPDIR->(dbCloseArea())
				
				if lFlag

					// Trata amarração com a nova tabela de preço/valorizacao.
					cTabVlr := iIf(!lCobCoPart, BS0->BS0_TABPRE, BS0->BS0_TABREC)
					
					if ! empty(cTabVlr)

						__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'BS0',cCodEsp,cCodUnd, lCobCoPart)

						PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, BS0->BS0_VIGDE, BS0->BS0_VIGATE)

					endIf
					
				endIf
				
			endIf
			
		elseIf aOrdensNiv[nForNiv] $ "B30"

			if B30->(msSeek(xFilial("B30")+cCodRda+cCodInt+cCodPla+cVersao))

				while !B30->( eof() ) .and. B30->B30_CODIGO+B30->B30_CODINT+B30->B30_CODPRO+B30->B30_VERSAO == cCodRda+cCodInt+cCodPla+cVersao
					
					// Verifica se a parametrização esta ativa e se esta vigente.
					if B30->B30_ATIVO <> "0" .and. PLSINTVAL("B30","B30_VIGDE","B30_VIGATE",dDatAnalise)
						
						// Trata amarração com a nova tabela de preço/valorizacao.
						cTabVlr := iIf(!lCobCoPart, B30->B30_TABPRE, B30->B30_TABREC)
						
						if ! empty(cTabVlr)

							__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'B30',cCodEsp,cCodUnd, lCobCoPart)

							if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, B30->B30_VIGDE, B30->B30_VIGATE)
									
								exit
									
							endIf	
							
						endIf
						
					endIf
					
				B30->( dbSkip() )
				endDo
				
			endIf
			     
		elseIf aOrdensNiv[nForNiv] $ "BMC" .and. ! lCobCoPart
		
			if ! lOk .and. nfor <= nNiveis
				
				cSQL := "SELECT BMC_NIVEL,BMC_VALUS, BMC_VALUSA, BMC_DATDE, BMC_VLRPAG, BMC_TABPRE, "
				cSQL += "       BMC_VIGDE, BMC_VIGATE, BMC_VLUSRE, BMC_VLRPGA, BMC_BANDA "
				cSQL += " FROM " + cNameBMC + " WHERE "
				
				cSQL += "BMC_FILIAL = '"+xFilial("BMC")+"' AND "
				cSQL += "BMC_CODINT = '"+cCodInt+"' AND "
				cSQL += "BMC_TIPPRE = '"+cTipPre+"' AND "
				cSQL += "BMC_CODPAD = '" + cCodPad + "' AND "
				
				cSQL += PLREQNI("BMC", "BMC_CODPSA", __aNiveis[2], allTrim(cCodPro))
				
				cSQL += "( '" + dtos(dDatAnalise) + "' >= BMC_VIGDE  OR BMC_VIGDE = ' ' ) AND "
				cSQL += "( '" + dtos(dDatAnalise) + "' <= BMC_VIGATE OR BMC_VIGATE = ' ' ) AND "
				
				cSQL +=  cNameBMC + ".D_E_L_E_T_ = ' ' "
				
				cSQL +=  " ORDER BY BMC_NIVEL DESC "
				
				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
					
				if ! PLSAUTPDIR->(eof())

					plsTField("PLSAUTPDIR",.f.,{ "BMC_VIGDE","BMC_VIGATE" } )

					//Se a vigencia estiver dentro do limite parametrizado...			   
					if PLSINTVAL("PLSAUTPDIR","BMC_VIGDE","BMC_VIGATE",dDatAnalise)

						//Se o campo APOS DATA não tiver preenchido vou pegar os valores 	  
						//padroes, ao contrario verifico a data do campo com a data base da    
						//analise                                                              
						// Tratamento da nova amarração com a tabela de preço/valorização.
						if ! empty(PLSAUTPDIR->BMC_TABPRE)
							
							__XaRetTabPre := PLVLTBPR(PLSAUTPDIR->BMC_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'BMC',cCodEsp,cCodUnd,lCobCoPart)
							
							PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, PLSAUTPDIR->BMC_VIGDE, PLSAUTPDIR->BMC_VIGATE)
							
						endIf
						
					endIf
					
				endIf
				
				PLSAUTPDIR->(dbCloseArea())
			endIf

		elseIf aOrdensNiv[nForNiv] $ "BMB" .and. ! lCobCoPart
		
			for nBmb := 1 to 2
				// Primeiro tenta achar parametrização para o tipo de prestador corrente.
				// Se não achar, tenta achar parametrização generica.
				if nBmb == 1
					cAuxTipPre := cTipPre
				else
					cAuxTipPre := space(TamSX3("BMB_TIPPRE")[1])
				endIf
				
				if BMB->(msSeek(xFilial("BMB")+cCodInt+cAuxTipPre))
				
					while !BMB->( eof() ) .and. BMB->BMB_CODINT + BMB->BMB_TIPPRE == cCodInt+cAuxTipPre
						
						// Faz a analize da vigencia.
						if PLSINTVAL("BMB","BMB_VIGDE","BMB_VIGATE",dDatAnalise)
						
							if ! empty(BMB->BMB_TABPRE)
							
								__XaRetTabPre := PLVLTBPR(BMB->BMB_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'BMB',cCodEsp,cCodUnd, lCobCoPart)
							
								if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, BMB->BMB_VIGDE, BMB->BMB_VIGATE)
									
									exit
									
								endIf	

							endIf
							
						endIf
						
					BMB->( dbSkip() )
					endDo
					
				endIf
				
				if lOk
					exit
				endIf
																			
			next
			
		elseIf aOrdensNiv[nForNiv] $ "B29" .and. ! lCobCoPart
			
			// Obtem as tabelas de preço disponiveis para este prestador na tabela B29 - Somente as que estiveram com vigencia em aberto.
			B29->(dbSetOrder(1))
			if B29->(msSeek(xFilial("B29")+cCodRDA+cCodInt))
			
				while !B29->( eof() ) .and. B29->B29_CODIGO+B29->B29_CODINT == cCodRDA+cCodInt
			
					// Faz a analize da vigencia.
					if PLSINTVAL("B29","B29_VIGINI","B29_VIGFIN",dDatAnalise)
			
						// Trata amarração com a nova tabela de preço/valorização.
						if ! empty(B29->B29_TABPRE)
						
							__XaRetTabPre := PLVLTBPR(B29->B29_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'B29',cCodEsp,cCodUnd, lCobCoPart)
						
							if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, B29->B29_VIGINI, B29->B29_VIGFIN)
									
								exit
									
							endIf	

						endIf
						
					endIf
					
				B29->( dbSkip() )
				endDo
				
			endIf			                             
			
		elseIf aOrdensNiv[nForNiv] $ "B24" .and. ! lCobCoPart
			
			// Obtem as tabelas de preço disponiveis para este prestador na tabela B24 - Somente as que estiveram com vigencia em aberto.
			aTabs := aClone(SeekB24(cCodRDA,cCodInt,cCodLoc,dDatAnalise))
			
			// Processa todas as tabelas de preço do prestador.
			for nTab := 1 to len(aTabs)
			
				// Trata amarração com a nova tabela de preço/valorização.
				if ! empty(aTabs[nTab])
			
					__XaRetTabPre := PLVLTBPR(aTabs[nTab],cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'B24',cCodEsp,cCodUnd, lCobCoPart)
			
					if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, B24->B24_VIGINI, B24->B24_VIGFIN)
									
						exit
									
					endIf	

				endIf
				
			next
			
		elseIf aOrdensNiv[nForNiv] $ "B85" .and. ! lCobCoPart
			
			//Verifico no nivel de local de RDA x Associacao.						
			B62->(dbSetOrder(1))
			if B62->(msSeek(xFilial("B62")+cCodRDA+cCodInt))
				
				while !B62->( eof() ) .and. B62->B62_CODIGO+B62->B62_CODINT == cCodRDA+cCodInt
					
					// Faz a analize da vigencia.
					if PLSINTVAL("B62","B62_DTVGIN","B62_DTVGF",dDatAnalise)
						
						B85->( dbSetOrder(01) )
						
						if B85->( msSeek(xFilial("B85")+B62->B62_ASSCLA) )
							
							while !B85->( eof() ) .and. B85->(B85_CODASS+B85_CLASSE) == B62->B62_ASSCLA
							
								if PLSINTVAL("B85","B85_VIGINI","B85_VIGFIN",dDatAnalise)

									if !empty(B85->B85_TABPRE)

										__XaRetTabPre := PLVLTBPR(B85->B85_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'B85',cCodEsp,cCodUnd, lCobCoPart)

										if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, B85->B85_VIGINI, B85->B85_VIGFIN)
									
											exit	
									
										endIf	

									endIf
									
								endIf

							B85->( dbSkip() )
							endDo
							
						endIf
						
					endIf
					
					if lOk
						exit
					endIf
					
				B62->( dbSkip() )
				endDo
				
			endIf                                                                         
			
		elseIf aOrdensNiv[nForNiv] $ "B12" .and. ! lCobCoPart .and. lFoundBB8

			B12->(dbSetOrder(1))
			
			if B12->(msSeek(xFilial("B12")+cCodInt+BB8->BB8_EST))
	
				while !B12->( eof() ) .and. B12->(B12_FILIAL+B12_CODINT+B12_CODEST) == xFilial("B12")+cCodInt+BB8->BB8_EST
					
					if PLSINTVAL("B12","B12_VIGDE","B12_VIGATE",dDatAnalise)														
						
						// Trata amarração com a nova tabela de preço.
						if ! empty(B12->B12_TABPRE)
					
							__XaRetTabPre := PLVLTBPR(B12->B12_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'B12',cCodEsp,cCodUnd, lCobCoPart)
								
							if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, B12->B12_VIGDE, B12->B12_VIGATE)
							
								exit
							
							endIf	

						endIf
						
					endIf
					
				B12->( dbSkip() )
				endDo
					
			endIf
			
		elseIf aOrdensNiv[nForNiv] $ "B13" .and. ! lCobCoPart .and. lFoundBB8
			
			// Depois localiza o municipio com vigencia ativa.
			B13->(dbSetOrder(1)) //B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN+B13_CODTAB+B13_SEQUEN
			
			if B13->(msSeek(xFilial("B13")+cCodInt+BB8->(BB8_EST+BB8_CODMUN)))
			
				while !B13->( eof() ) .and. B13->(B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN) == xFilial("B13")+cCodInt+BB8->(BB8_EST+BB8_CODMUN)
											
					if PLSINTVAL("B13","B13_VIGDE","B13_VIGATE",dDatAnalise)																
						
						// Trata amarração com a nova tabela de preço.
						if ! empty(B13->B13_TABPRE)
						
							__XaRetTabPre := PLVLTBPR(B13->B13_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'B13',cCodEsp,cCodUnd, lCobCoPart)
							
							if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, B13->B13_VIGDE, B13->B13_VIGATE)
							
								exit
							
							endIf	

						endIf
						
					endIf

				B13->( dbSkip() )
				endDo
				
			endIf

		elseIf aOrdensNiv[nForNiv] $ "BS9" .and. ! lReembolso .and. cTipoUsr == "2"

			cSql := "SELECT BS9_VIGDE,BS9_VIGATE,BS9_TABPRE FROM "+retSqlName("BS9")+" WHERE BS9_FILIAL = '"+xFilial("BS9")+"' "
			cSql += "AND BS9_SUBCON = '"+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+"' "
			cSql += "AND BS9_CODUNI = '"+cCodUnd+"' "
			cSql += "AND D_E_L_E_T_ = ' ' "
			
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TRBBS9",.f.,.t.)
			
			if ! TRBBS9->(eof())
				plsTField("TRBBS9",.f.,{ "BS9_VIGDE","BS9_VIGATE" } )
			endIf
		
			while !TRBBS9->( eof() )
				
				if PLSINTVAL("TRBBS9","BS9_VIGDE","BS9_VIGATE",dDatAnalise)				
				
					if ! empty(TRBBS9->BS9_TABPRE)
				
						__XaRetTabPre := PLVLTBPR(TRBBS9->BS9_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nRef,'BS9',cCodEsp,cCodUnd, lCobCoPart)
						
						if PLSRTPPA(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nRef, @nVlrPARea, @nBanda, @aVigAtu, TRBBS9->BS9_VIGDE, TRBBS9->BS9_VIGATE)
							
							exit	
							
						endIf	

					endIf
					
				endIf
				
			TRBBS9->( dbSkip() )
			endDo
			
			TRBBS9->( dbCloseArea() )
		
		elseIf aOrdensNiv[nForNiv] $ "BMH" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso .and. cTipoUsr == "2"
				
			BMH->(dbSetOrder(1)) //BMH_FILIAL + BMH_CODINT + BMH_CODEMP + BMH_NUMCON + BMH_VERCON + BMH_SUBCON + BMH_VERSUB + BMH_CODRDA
			if BMH->(msSeek(xFilial("BMH")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA))
				
				aRegs := {}
				
				while !BMH->(eof()) .and. xFilial("BMH")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA == BMH->(BMH_FILIAL+BMH_CODINT+BMH_CODEMP+BMH_NUMCON+BMH_VERCON+BMH_SUBCON+BMH_VERSUB+BMH_CODRDA)
					aadd(aRegs,{BMH->(recno()),BMH->(BMH_DATDE)})
					BMH->(dbSkip())  
				endDo               
				
				//Ordeno pelo DATDE maior ou seja vai pegar o de vigencia mais nova primeiro
				aRegs := aSort(aRegs,,,{|x,y| x[2] >= y[2] }) 
				
				for nR := 1 to len(aRegs)	 
					
					BMH->(dbGoTo(aRegs[nR][1]))  
					
					if empty(BMH->BMH_DATDE) .or. dtos(dDatAnalise) >= dtos(BMH->BMH_DATDE)
						nVlrUS := BMH->BMH_VALUS
					else
						nVlrUS := BMH->BMH_VALUSA
					endIf
	
					If nVlrUS > 0 .AND. empty(cPorteMed)
						lOK := .t.
					endIf
	
					if lOk
						cAlias    := "BMH"
						aVigAtu	  := {cAlias,BMH->BMH_DATDE, dVigFim}
						exit
					endIf
				next
			endIf
		elseIf aOrdensNiv[nForNiv] == "BE9" .and. ( ! lInterc .or. lChkNvLoc ) .and. ! lReembolso
		
			cSQL := "SELECT R_E_C_N_O_ REC FROM "+ RetSqlName("BE9") +" WHERE "
			cSQL += "BE9_FILIAL = '" + xFilial("BE9") + "' AND "
			cSQL += "BE9_CODIGO = '" + cCodRDA + "' AND "
			cSQL += "BE9_CODINT = '" + cCodInt + "' AND "
			cSQL += "BE9_CODLOC = '" + cCodLoc + "' AND "
			cSQL += "BE9_CODESP = '" + cCodEsp  + "' AND "
			cSQL += "BE9_CODPLA = '" + cCodPla + "' AND "
			cSQL += "BE9_CODPAD = '" + cCodPad + "' AND "
			
			cSQL += PLREQNI("BE9", "BE9_CODPRO", __aNiveis[2], cCodPro)
			
			cSQL += "( '" + dtos(dDatAnalise) + "' >= BE9_VIGDE  OR BE9_VIGDE  = ' ' ) AND "
			cSQL += "( '" + dtos(dDatAnalise) + "' <= BE9_VIGATE OR BE9_VIGATE = ' ' ) AND "
			cSQL +=  RetSqlName("BE9") + ".D_E_L_E_T_ = ' ' "
			
			cSQL +=  " ORDER BY BE9_NIVEL DESC "
			
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
	
			if ! PLSAUTPDIR->(eof())
				BE9->(dbGoTo(PLSAUTPDIR->(REC)))
				lFoundBE9 := .t.
			else
				if lPLSBE9SK
					execBlock("PLSBE9SK",.f.,.f.,{cCodRda,cCodInt,cCodLoc,cCodEsp,cCodPla,cCodPad,cCodAux,nForBE9})
				endIf
			endIf
			
			PLSAUTPDIR->(dbCloseArea())
					
			if lFoundBE9 .and. BE9->BE9_ATIVO <> "0"	
				if ! lCobCoPart
					If BE9->BE9_VALCH > 0 .OR. BE9->BE9_VALREA > 0
						nVlrUS  	:= BE9->BE9_VALCH
						nVlrPARea 	:= BE9->BE9_VALREA
					EndIf
				else
					If BE9->BE9_USRECT > 0 .OR. BE9->BE9_VLRECT > 0
						nVlrUS 	:= BE9->BE9_USRECT
						nVlrPARea 	:= BE9->BE9_VLRECT
					EndIf
				endIf
			endIf
	
			//somente quando vem da PLSRTBANDA - lBanda  
			If (nVlrUS > 0 .or. nVlrPARea > 0)
				lOK := .t.
			endIf
	
			if lOk
				cAlias  := "BE9"
				aVigAtu := { cAlias, BE9->BE9_VIGDE, BE9->BE9_VIGATE}
			endIf
		endIf
		
		if lOk
			exit
		endIf
		
	next

	// validamos se foi encontrado tabela de porte(B28) vinculada, caso positivo não entra no if da BKF abaixo	
	if len(__XaRetTabPre[2]) > 0
		if len(__XaRetTabPre[2,25]) > 0 // posição 25 é um array (_aTabVlrPA) com valores da tabela B28, preenchido pela PLVLRETB
			lPorBKF := .F.
		endif
		nAcrescimo := __XaRetTabPre[2][33]
		nDesconto  := __XaRetTabPre[2][34]
	endif
 
	//BKF - Porte Anestesico...                       
	if nRef > 0 .and. lPorBKF
 
		cSQL := "SELECT BKF_COEFIC, BKF_VLRREA, BKF_VIGINI, BKF_VIGFIN "
		cSQL += "  FROM " + retSqlName("BKF")+" WHERE "
		cSQL += "  BKF_FILIAL = '" + xFilial("BKF") + "' AND "
		cSQL += "  BKF_CODINT = '" + cCodInt + "' AND "
		cSQL += "  BKF_CODTAB = '" + cCodTab + "' AND "
		cSQL += "  BKF_SEQPOR = "  + str(nRef, 13, nDecSEP) + " AND "
		cSQL += "  D_E_L_E_T_ = ' ' "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLstrbPA",.f.,.t.)
					
		if PLstrbPA->(eof())
			lOK := .f.
		else
			
			plsTField("PLstrbPA",.f.,{ "BKF_VIGINI","BKF_VIGFIN" } )

			while !PLstrbPA->(eof())

				if PLSINTVAL("PLstrbPA",'BKF_VIGINI','BKF_VIGFIN',dDatAnalise)
					
					nVlrCOEF  := PLstrbPA->BKF_COEFIC
					If nVlrPARea == 0
						nVlrPARea := PLstrbPA->BKF_VLRREA
					endIf
					aVigAtu	  := { cAlias, PLstrbPA->BKF_VIGINI, PLstrbPA->BKF_VIGFIN }
					
				endIf
				
				if nVlrCOEF > 0 .or. nVlrPARea > 0

					cAlias	:= iIf(lOk, cAlias, 'BKF')
					lOk 	:= .t.

					exit

				endIf

			PLstrbPA->( dbSkip() )
			endDo

		endIf
	
		PLstrbPA->(dbCloseArea())
	elseif ! lCobCoPart .and. lZeraTudo
		lOk       := .f.
		aVigAtu	  := { cAlias, dVigIni, dVigFim}
	endIf	
	
	//Realiza o calculo...                            
	if lOk

		//se nao retornou valor faz o calculo coeficiente BCK ou BKF * o valor da US (PLSRETPA)
		if nVlrPARea == 0
			
			//Retorna US para calculo do valor do porte.
			If nRetUS == 0
				nRetUS 		:= PLSRETPA(cCodInt,cAno,cMes,aRet,cCodEmp,cCodRDA,cCodLoc,cCodPla,cVrProduto,cCodEsp,aVlBloq,paramixb)
			EndIf
			nVlrPARea 	:= nVlrCOEF * nRetUS
			nVlrCOEF 	:= round(nVlrCOEF, nDecCOF )
		else

			nVlrCOEF := round(nVlrPARea, nDecBAS )	

		endIf

		if nVlrPARea > 0
			
			if cConsFt == "1"
				nVlrPARea := nVlrPARea * nFatMul
			endIf
			
			if cConsBd == "1" //.and. ( ! empty(cPorteMed) .OR. lPLSRTBND )

				if nBanda == 0

					nBanda := PLSRTBANDA(cCodInt,cAno,cMes,lCobCoPart,lInterc,cOpeInt,dDatAnalise,nNiveis,__aNiveis,cCodPro,;
										cModPag,cCodPad,cCodEsp,cCodUnd,cCodPla,nVlrApr,if(cREGGOP=="1",cGRUOPE,""),nUSEspec,nil,cFinAte)

				endIf
	
				if nBanda > 0 
					nVlrPARea := ( nVlrPARea * nBanda ) / 100
				endIf

			endIf

			if nDesconto > 0
				nVlrPARea := ( nVlrPARea - ( nVlrPARea * nDesconto ) / 100 )
			endIf

			//Aplica o acrescimo se ele existir								
			if nAcrescimo > 0
				nVlrPARea := ( nVlrPARea + ( nVlrPARea * nAcrescimo ) / 100 )
			endIf

			// Aplica percentual de aumento ou redução
			if allTrim(cCodUnd) $ allTrim(cMVPLSUNPR) .and. nPrPrRl <> 0
				nVlrPARea := nVlrPARea + ( ( nVlrPARea * nPrPrRl ) / 100 )
			endIf
			 
			If nRetUS > 0 
				aadd(aRetPA,{  nVlrCOEF, cAlias, round(nRetUS, nDecREF ), round(nVlrPARea, nDecBAS ) * nQtd, round(nVlrPARea, nDecBAS ) * nQtd, nFatMul, "Vlr.PA", 0, nBanda, cConsBd, '0', nRetUS, 0, 0, 0 })
			Else
				aadd(aRetPA,{  nVlrCOEF, cAlias, round(nRef, nDecREF ), round(nVlrPARea, nDecBAS ) * nQtd, round(nVlrPARea, nDecBAS ) * nQtd, nFatMul, "Vlr.PA", 0, nBanda, cConsBd, '0', nRetUS, 0, 0, 0 })
			EndIf

			if lOK .and. len(aRetPA) > 0 .and. existBlock("PLSVLRPA")
				
				aRetPto := execBlock("PLSVLRPA",.f.,.f.,{aRetPA[1,4],nBanda,cConsBd,cAno,cMes,lCobCoPart,dDatAnalise,cCodPro,cCodPad,cCodEsp,;
														cCodUnd,cCodPla,cCodRDA,cCodLoc,cCodTab,cCodInt,nRef,aRetPA,cOpeOri,cConsFt,cCodInt,;
														aRet,cCodEmp,cVrProduto,aVlBloq,nFatMul,nQtd,lOK,cAlias,cMsg})
				
				if aRetPto[1]
				
					//aqui eu soh mudo o valor base
					aRetPA[1,4] := aRetPto[2]
				
					if len(aRetPto) >= 3 .and. valtype(aRetPto[3]) == 'A'
				
						lOK		:= aRetPto[3][1]
						cAlias 	:= aRetPto[3][2]
						aRetPA 	:= aClone(aRetPto[3,4])

					endIf
					
				endIf
				
			endIf
		
		else

			lOk := .f.

		endIf

	endIf
	
	if existBlock("PLCVLRPA") 
		
		if len(aRetPA) == 0
			pParam1 := 0
			pParam2 := {}			
		else
			pParam1 := aRetPA[1,4]
			pParam2 := aRetPA		
		endIf
		
		aRetPto := execBlock("PLCVLRPA",.f.,.f.,{	pParam1,nBanda,cConsBd,cAno,cMes,lCobCoPart,dDatAnalise,cCodPro,cCodPad,cCodEsp,;
													cCodUnd,cCodPla,cCodRDA,cCodLoc,cCodTab,cCodInt,nRef,pParam2,cOpeOri,cConsFt,cCodInt,;
													aRet,cCodEmp,cVrProduto,aVlBloq,nFatMul,nQtd,lOK,cAlias,cMsg})
		
		if aRetPto[1]
			
			if len(aRetPA) <> 0
				aRetPA[1,4] := aRetPto[2]
			endIf

			if len(aRetPto) >= 3 .and. valtype(aRetPto[3]) == 'A'
				
				lOK		:= aRetPto[3][1]
				cAlias 	:= aRetPto[3][2]
				aRetPA 	:= aClone(aRetPto[3,4])
				
			endIf
						
		endIf
				
	endIf

	if ! lOk

		PLSPOSGLO(PLSINTPAD(),__aCdCri036[1],__aCdCri036[2])
		
		aRetPA	:= {}
		cCodCri := __aCdCri036[1]
		cMsg    := cCodCri + " - " + PLSBCTDESC()
	
		aadd(aRetPA, { 0, "", 0, 0, 0, 0, "", 0, 0, "0", '0', 0, 0, 0, 0 } )

	endIf

	aRetFunc := { lOK, cMsg, cCodCri, aRetPA, aVigAtu }
	
endIf   

return(aRetFunc)

/*/{Protheus.doc} PLSRETVFIL
Retorna o valor do filme 

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETVFIL(paramixb,lObsoleto)
local nQtd       := paramixb[1]
local nRef       := paramixb[2]
local dDatAnalise:= paramixb[4]   
local cCodRDA    := paramixb[5]
local cCodInt    := paramixb[6]
local cCodLoc    := subStr(paramixb[7],1,3)                  
local cCodTab    := paramixb[8]
local cCodPad    := paramixb[9]
local cCodPro    := paramixb[10]
local cMes       := paramixb[11]
local cAno       := paramixb[12]
local cCodEsp    := paramixb[13]
local cModPag	 := paramixb[15]
local nVlrApr	 := paramixb[17]
local cTipPre    := paramixb[18]  
local cCodEmp    := iIf(len(paramixb[19])>0, subStr(paramixb[19,2],atCodEmp[1],atCodEmp[2]), "")
local cTipoUsr   := iIf(len(paramixb[19])>0, paramixb[19,8], "")
local cConEmp    := iIf(len(paramixb[19])>0, paramixb[19,9], "")
local cCodPla    := iIf(len(paramixb[19])>0, paramixb[19,11], "")
local cVersao    := iIf(len(paramixb[19])>0, paramixb[19][12], "")
local cVerCon    := iIf(len(paramixb[19])>0, paramixb[19,39], "")
local cSubCon    := iIf(len(paramixb[19])>0, paramixb[19,41], "")
local cVerSub    := iIf(len(paramixb[19])>0, paramixb[19,42], "")
local cOpeOri	 := iIf(len(paramixb[19])>0, paramixb[19,45], "")
local cREGGOP    := iIf(len(paramixb[19])>0, paramixb[19,63], "")
local cGRUOPE    := iIf(len(paramixb[19])>0, paramixb[19,64], "")
local nFatMul    := paramixb[20]
local cConsFt    := paramixb[21]
local nUSEspec	 := paramixb[22]
local lCobCoPart := paramixb[25]   
local nPrPrRl	 := paramixb[27]
local cRegAte	 := paramixb[30]                                             
local cCodUnd    := paramixb[35]
local lReembolso := paramixb[36]
local cConsBd    := paramixb[38]  
local cRegPag	 := paramixb[44]                                             
local cRegCob	 := paramixb[45]                                             
local cFinAte  	 := paramixb[47]
local cRdaEdi    := iIf(len(paramixb) > 49,paramixb[50],"")

local nVlrFil    := 0
local nDesconto  := 0
local nAcrescimo := 0
local nForBE9    := 1
local nForBC0	 := 0
local nNiveis    := 0                                        
local nVlrFilCalc:= 0
local nBmb 		 := 0
local nfor 		 := 0
local nForNiv 	 := 0
local nBanda	 := 0
local nTab		 := 0
local aTabs		 := 0
local nDecREF	 := iIf( ! lCobCoPart, PLGetDec('BD7_REFTDE'), PLGetDec('BD7_RFTDEC'))
local nDecCOF	 := iIf( ! lCobCoPart, PLGetDec('BD7_COEFUT'), PLGetDec('BD7_COEFPF'))
local nDecBAS	 := iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'), PLGetDec('BD7_VLRBPF'))
local cChave     := ''                             
local cSQL 	     := ''
local cCodCri	 := ''
local cMsg       := ''                         
local cAlias     := ''
local cCodAux    := ""
local cOpeInt    := ""
local cSeqRel	 := ""
local cTabVlr 	 := ""
local cTabPre 	 := ""
local cAuxTipPre := ""
local cNameBS0	 := BS0->(retSqlName("BS0"))
local cNameBC0	 := BC0->(retSqlName("BC0"))
local cNameBE9	 := BE9->(retSqlName("BE9"))
local cNameBMC	 := BMC->(retSqlName("BMC"))
local lInterc    := .f.
local lOK        := .f.
local lFound 	 := .f.
local lTabEsp 	 := .f.
local lFoundBB8	 := .f.
local lFoundTab  := .f.         
local lZeraTudo  := (getNewPar("MV_PLSGUI0","0") == "1") // Rever este conceito.
local lDesAcre   := (getNewPar("MV_PLSDEAC","0") == "1")
local aRetFil    := {}
local aRetInt    := {}
local aOrdensNiv := {}
local __XaRetTabPre	:= {.f.,{}}
local aVigAtu	 := {}
local dVigIni	 := ctod("")
local dVigFim	 := ctod("")

default lObsoleto := .f.

if __cCdTbPd <> cCodPad .or. len(__aNiveis) == 0
	__cCdTbPd := cCodPad
	__aNiveis := PLSESPNIV(cCodPad)
endIf

nNiveis := (__aNiveis[1]+1)

if existBlock("PLSFIATE")
   cFinAte := execBlock("PLSFIATE",.f.,.f.,{cFinAte})
endIf

//procura por desconto ou acrescimo
if lDesAcre
	
	//procura por desconto/acrescimo na rda x local x especialidade x procedimento...												
	//Tratamento Grupo,Subitem,Item...								
	cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBC0 + " WHERE "
	cSQL += "BC0_FILIAL = '" + xFilial("BC0") + "' AND "
	cSQL += "BC0_CODIGO = '" + cCodRDA + "' AND "
	cSQL += "BC0_CODINT = '" + cCodInt + "' AND "
	cSQL += "BC0_CODLOC = '" + cCodLoc + "' AND "
	cSQL += "BC0_CODESP = '" + cCodEsp + "' AND "
	cSQL += "BC0_CODPAD = '" + cCodPad + "' AND "

	cSQL += PLREQNI("BC0", "BC0_CODOPC", __aNiveis[2], allTrim(cCodPro))
	
	cSQL += "( '" + dtos(dDatAnalise) + "' >= BC0_VIGDE  OR BC0_VIGDE  = ' ' ) AND "
	cSQL += "( '" + dtos(dDatAnalise) + "' <= BC0_VIGATE OR BC0_VIGATE = ' ' ) AND "
	cSQL += "( BC0_DATBLO = ' '  OR BC0_DATBLO > '" + dtos(dDatAnalise) + "' ) AND "

	cSQL += "D_E_L_E_T_ = ' ' "

	cSQL +=  " ORDER BY BC0_NIVEL DESC "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)

	if ! PLSAUTPDIR->(eof())

		lFound := .t.
		BC0->(dbGoTo(PLSAUTPDIR->(REC)))
		
	endIf

	PLSAUTPDIR->(dbCloseArea())

	if lFound
		nDesconto  := BC0->BC0_PERDES            
		nAcrescimo := BC0->BC0_PERACR
	endIf

	if existBlock("PLBC0FIL")
		aBC0Fil    := execBlock("PLBC0FIL",.f.,.f.,{cCodRda,cCodInt,cCodLoc,cCodEsp,cCodPla,cCodPad,cCodPro,nDesconto,nAcrescimo})
		nDesconto  := aBC0Fil[1]
		nAcrescimo := aBC0Fil[2]
	endIf   

	if ( nDesconto + nAcrescimo ) == 0

		cSQL := " SELECT R_E_C_N_O_ REC "
		cSQL += "   FROM " + cNameBE9 + " WHERE "
		cSQL += " BE9_FILIAL = '" + xFilial("BE9") + "' AND "
		cSQL += " BE9_CODIGO = '" + cCodRDA + "' AND "
		cSQL += " BE9_CODINT = '" + cCodInt + "' AND "
		cSQL += " BE9_CODLOC = '" + cCodLoc + "' AND "
		cSQL += " BE9_CODESP = '" + cCodEsp  + "' AND "
		cSQL += " BE9_CODPLA = '" + cCodPla + "' AND "
		cSQL += " BE9_CODPAD = '" + cCodPad + "' AND "

		cSQL += PLREQNI("BE9", "BE9_CODPRO", __aNiveis[2], allTrim(cCodPro))

		cSQL += " ( '" + dtos(dDatAnalise) + "' >= BE9_VIGDE  OR BE9_VIGDE  = ' ' ) AND "
		cSQL += " ( '" + dtos(dDatAnalise) + "' <= BE9_VIGATE OR BE9_VIGATE = ' ' ) AND "
		cSQL += " D_E_L_E_T_ = ' ' "

		cSQL +=  " ORDER BY BE9_NIVEL DESC "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)

		if ! PLSAUTPDIR->(eof()) 
			lFound 	:= .t.
			BE9->(dbGoTo(PLSAUTPDIR->(REC)))
		else

			if existBlock("PLSBE9SK")
				
				if execBlock("PLSBE9SK",.f.,.f.,{cCodRda,cCodInt,cCodLoc,cCodEsp,cCodPla,cCodPad,cCodAux,nForBE9})
					lFound := .t.
				endIf
				
			endIf
			
		endIf

		PLSAUTPDIR->(dbCloseArea())

		if lFound
			nAcrescimo 	:= BE9->BE9_PERACR
			nDesconto 	:= BE9->BE9_PERDES            
		endIf                               
				
		if existBlock("PLBE9FIL")
			aBE9Fil    := execBlock("PLBE9FIL",.f.,.f.,{cCodRda,cCodInt,cCodLoc,cCodEsp,cCodPla,cCodPad,cCodPro,nDesconto,nAcrescimo})
			nDesconto  := aBE9Fil[1]
			nAcrescimo := aBE9Fil[2]
		endIf           

	endIf	     

endIf	             

/* 
01 - Grupo de Operadora  (BGH)
02 - Subcontrato x filme (BG6)
03 - RDA X local X Filme (BPI)
04 - Produto X Filme (BF5)
05 - Filme (BP8)

tratamento do filme nos niveis que tratam tabela de preço / valorizacao.
===> Niveis que permitem parametrização da tabela de valorização.

BS0 - Produto X Und X U.S                        
BBI - RDA X local Atend X Especialidade X Planos...
BMB - Operadora X Tipo de Prestador X U.S

B24 - RDA X Tab Preços Generica			
BC5 - RDA X Tab Precos (Cabecalho)      

B85 - Associacao X Classe X Tabela de Preco
B12 - Estados X Municipios (Estado)		
B13 - Estados X Municipios (Municipio)	
B30 - RDA X Planos						
*/

lFoundTab := .f.

// Tripla proteção.
if !lOk .and. nVlrFil == 0 .and. nVlrFilCalc == 0 

	aRetInt := PLINTERC( iIf( ! lCobCoPart, "1", "2"), cCodRda, cOpeOri, cRegPag, cRegCob)
	lInterc := aRetInt[1]
	cOpeInt := aRetInt[2]

	BB8->(dbSetOrder(1))
	lFoundBB8 := SeekBB8E(cCodRDA,cCodInt,cCodLoc)

	//Para intercambio adiciona o Alias BGH
	if ( lInterc .or. cRegGop == "1" )			
		aOrdensNiv := {"BGH","BG6","BPI","BF5","BBI","BC5","BS9","BS0","BMC","BMB","B24","B30","B13","B12","B85","B29"}
	else	
		aOrdensNiv := {"BG6","BPI","BF5","BBI","BC5","BS9","BS0","BMC","BMB","B24","B30","B13","B12","B85","B29"}
	endIf	
	
	if existBlock("PLSONVPC")
		aOrdensNiv := execBlock("PLSONVPC",.f.,.f.,{aOrdensNiv,lCobCoPart,cCodRda,cOpeOri,"2"})
	endIf

	for nForNiv := 1 to len(aOrdensNiv)
                                         
		if aOrdensNiv[nForNiv] $ "BGH" .and. ( lInterc .or. (cRegGop == "1" .AND. iIf( ! lCobCoPart, "1", "2") == '2' ) )
			
			//Pagamento FILME
			aRetFun := PLSGRUOPE(iIf( ! lCobCoPart, "1", "2"),cOpeInt, dDatAnalise, nNiveis, __aNiveis, cCodPro, cModPag, cCodPad, cCodEsp,;
								 cCodUnd, cCodPla, nVlrApr, cGRUOPE, nUSEspec,;
								 lInterc, cFinAte, cCodRda, cRdaEdi, nil, .t., /*lBusTx*/, cRegAte)

			cSeqRel := iIf( len(aRetFun)>13 , aRetFun[14] , "" )

			if len(aRetFun) >= 13 .and. aRetFun[13] > 0
	
				lOk 	:= .t.
				cAlias  := "BGH"
				nVlrFil := aRetFun[13]
				
				if len(aRetFun) >= 16
					dVigIni := aRetFun[15]
					dVigFim := aRetFun[16]
				endIf	
		
			endIf

		elseIf aOrdensNiv[nForNiv] $ "BBI" .and. ! lInterc
		
			BBI->(dbSetOrder(1))
			if BBI->(msSeek(xFilial("BBI")+cCodRda+cCodInt+cCodLoc+cCodEsp+cCodPla))
			
				while !BBI->( eof() ) .and. BBI->BBI_CODIGO+BBI->BBI_CODINT+BBI->BBI_CODLOC+BBI->BBI_CODESP+BBI->BBI_CODPRO == cCodRDA+cCodInt+cCodLoc+cCodEsp+cCodPla
					
					// Verifica se a parametrização esta ativa e se esta vigente.
					if BBI->BBI_ATIVO <> "0" .and. PLSINTVAL("BBI","BBI_VIGDE","BBI_VIGATE",dDatAnalise)
						
						// Trata amarração com a nova tabela de preço/valorizacao.
 						cTabVlr := iIf(!lCobCoPart, BBI->BBI_TABPRE, BBI->BBI_TABREC)
						
						if ! empty(cTabVlr)
						
							__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BBI',cCodEsp,cCodUnd, lCobCoPart)
							
							if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, BBI->BBI_VIGDE, BBI->BBI_VIGATE)
								
								exit
								
							endIf
							
						endIf
						
					endIf                      
					
				BBI->( dbSkip() )
				endDo
				
			endIf
			
		elseIf aOrdensNiv[nForNiv] $ "BPI"
		
			BPI->(dbSetOrder(1))
		   	if BPI->(msSeek(xFilial("BPI")+cCodRda+cCodInt+cCodLoc))
   
	      		while ! BPI->( eof() ) .and. BPI->(BPI_FILIAL+BPI_CODIGO+BPI_CODINT+BPI_CODLOC) == xFilial("BPI")+cCodRda+cCodInt+cCodLoc
    	  
        		    if PLSINTVAL("BPI","BPI_VIGDE","BPI_VIGATE",dDatAnalise)
               
					 	cSeqRel := BPI->BPI_SEQREL
	    		       	nVlrFil := BPI->BPI_VLRFIL
	
						if nVlrFil <> 0
							
							lOK 	:= .t.
			   				cAlias  := "BPI"
							dVigIni := BPI->BPI_VIGDE
							dVigFim := BPI->BPI_VIGATE

			            	exit
						endIf
						
            		endIf   

				BPI->( dbSkip() )
     			endDo
     			
   			endIf

		elseIf aOrdensNiv[nForNiv] $ "BCK"
		
			BCK->(dbSetOrder(1)) //BCK_FILIAL+BCK_CODIGO+BCK_CODINT+BCK_CODLOC+BCK_CODUNI
			if BCK->(msSeek(xFilial("BCK")+cCodRda+cCodInt+cCodLoc+cCodUnd))
				
				while ! BCK->( eof() ) .and. BCK->(BCK_FILIAL+BCK_CODIGO+BCK_CODINT+BCK_CODLOC+BCK_CODUNI) == xFilial("BCK")+cCodRda+cCodInt+cCodLoc+cCodUnd
		
					if PLSINTVAL("BCK","BCK_VIGINI","BCK_VIGFIN",dDatAnalise)
						
						nVlrFil := BCK->BCK_US
			
					   	if nVlrFil <> 0

							lOk     := .t.
							cAlias  := "BCK"
							dVigIni := BCK->BCK_VIGINI
							dVigFim := BCK->BCK_VIGFIN

							exit
						endIf
						
					endIf
					
				BCK->( dbSkip() )
				endDo
				
			endIf

		elseIf aOrdensNiv[nForNiv] $ "BF5"
			
			//[04] - Produto X Filme (BF5)                         
			BF5->(dbSetOrder(1))
			if BF5->(msSeek(xFilial("BF5")+cCodInt+cCodPla))
		
				while ! BF5->( eof() ) .and. BF5->(BF5_FILIAL+BF5_CODINT+BF5_CODPRO) == xFilial("BF5")+cCodInt+cCodPla
		
					if PLSINTVAL("BF5","BF5_VIGDE","BF5_VIGATE",dDatAnalise)
			
						cSeqRel := BF5->BF5_SEQREL
						
						if !lCobCoPart
							nVlrFil := BF5->BF5_VLRFIL
						else
							nVlrFil := BF5->BF5_VLRFRC
						endIf
			
					   	if nVlrFil <> 0

					   		lOK   	:= .t.
			            	cAlias  := "BF5"
							dVigIni := BF5->BF5_VIGDE
							dVigFim := BF5->BF5_VIGATE

			            	exit
		            	endIf
		            		
					endIf
					
				BF5->( dbSkip() )
				endDo
				
			endIf

		elseIf aOrdensNiv[nForNiv] $ "BC5"
			
			// Redefine as variaveis de controle
			cTabPre := ""
			lTabEsp := .f.
			
			// Verifica se existe tabela de preço no local de atendimento. Esse codigo se refere a tabela de preço X RDA BC5.
			if  lFoundBB8 .and. ! empty(BB8->BB8_TABPRE)
				cTabPre := BB8->BB8_TABPRE
				lTabEsp := .t.
			endIf
			
			// Verifica se existe tabela de preço especifica para esta RDA.
			BC5->(dbSetOrder(1))
			if BC5->( msSeek(xFilial("BC5") + cCodInt + cCodRda) )
				
				// Processa as vigencias.
				while ! BC5->(eof()) .and. BC5->(BC5_FILIAL+BC5_CODINT+BC5_CODRDA) == xFilial("BC5")+cCodInt+cCodRda
					
					// Testa regra de tabela especifica.
					if ( lTabEsp .and. cTabPre == BC5->BC5_TABPRE ) .or. ( ! lTabEsp )
						
						// Faz a analize da vigencia.
						if PLSINTVAL("BC5","BC5_DATINI","BC5_DATFIM",dDatAnalise)
							
							cTabVlr := iIf(!lCobCoPart, BC5->BC5_TABPRE, BC5->BC5_TABREC)
							
							if ! empty(cTabVlr)
							
								__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BC5',cCodEsp,cCodUnd, lCobCoPart)
								
								if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, BC5->BC5_DATINI, BC5->BC5_DATFIM)
									
									exit
									
								endIf
								
							endIf
							
						endIf
						
					endIf
					
				BC5->( dbSkip() )
				endDo
				
			endIf                                           
			
		elseIf aOrdensNiv[nForNiv] $ "BS0"
			
			cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBS0 + " WHERE "
			cSQL += "BS0_FILIAL = '" + xFilial("BS0") + "' AND "
			cSQL += "BS0_CODPRO = '" + cCodInt+cCodPla + "' AND "
			cSQL += "BS0_CODPAD = '" + cCodPad + "' AND "
			cSQL += "BS0_CODUNI = '" + cCodUnd + "' AND "
			
			cSQL += PLREQNI("BS0", "BS0_CODPSA", __aNiveis[2], allTrim(cCodPro))

			cSQL += "( '" + dtos(dDatAnalise) + "' >= BS0_VIGDE  OR BS0_VIGDE = ' ' ) AND "
			cSQL += "( '" + dtos(dDatAnalise) + "' <= BS0_VIGATE OR BS0_VIGATE = ' ' ) AND "
			
			cSQL +=  cNameBS0 + ".D_E_L_E_T_ = ' ' "
			
			cSQL +=  " ORDER BY BS0_NIVEL DESC "
			
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
			
			lFlag := .f.
			
			if ! PLSAUTPDIR->(eof())
				
				lFlag := .t.
				BS0->(dbGoTo(PLSAUTPDIR->(REC)))
					
			endIf	
			
			PLSAUTPDIR->(dbCloseArea())
					
			if lFlag
				
				cTabVlr := iIf(!lCobCoPart, BS0->BS0_TABPRE, BS0->BS0_TABREC)
				
				if ! empty(cTabVlr)
					
					__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BS0',cCodEsp,cCodUnd, lCobCoPart)
					
					PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, BS0->BS0_VIGDE, BS0->BS0_VIGATE)

				endIf
				
			endIf
			
			//Tratamento da diferenciacao da us por produto X unidade			     
			lFlag := .f.
			
			if getNewPar("MV_PLBS0UM","1") == "1"
			
				cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBS0 + " WHERE "
				cSQL += "BS0_FILIAL = '" + xFilial("BS0") + "' AND "
				cSQL += "BS0_CODPRO = '" + cCodInt+cCodPla + "' AND "
				cSQL += "BS0_CODUNI = '" + cCodUnd + "' AND "
				
				cSQL += "( '"+dtos(dDatAnalise)+"' >= BS0_VIGDE  OR BS0_VIGDE = ' ' ) AND "
				cSQL += "( '"+dtos(dDatAnalise)+"' <= BS0_VIGATE OR BS0_VIGATE = ' ' ) AND "
				
				cSQL +=  cNameBS0 + ".D_E_L_E_T_ = ' ' "
				
				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
				
				lFlag := .f.
				
				if ! PLSAUTPDIR->(eof())
					
					lFlag := .t.
					BS0->(dbGoTo(PLSAUTPDIR->(REC)))
						
				endIf	
				
				PLSAUTPDIR->(dbCloseArea())
				
				if lFlag
					
					cTabVlr := iIf(!lCobCoPart, BS0->BS0_TABPRE, BS0->BS0_TABREC)
					
					if ! empty(cTabVlr)
						
						__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BS0',cCodEsp,cCodUnd, lCobCoPart)

						PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, BS0->BS0_VIGDE, BS0->BS0_VIGATE)

					endIf
					
				endIf
				
			endIf
			
		elseIf aOrdensNiv[nForNiv] $ "B30"
			
			if B30->(msSeek(xFilial("B30")+cCodRda+cCodInt+cCodPla+cVersao))
			
				while !B30->( eof() ) .and. B30->B30_CODIGO+B30->B30_CODINT+B30->B30_CODPRO+B30->B30_VERSAO == cCodRda+cCodInt+cCodPla+cVersao
					
					// Verifica se a parametrização esta ativa e se esta vigente.
					if B30->B30_ATIVO <> "0" .and. PLSINTVAL("B30","B30_VIGDE","B30_VIGATE",dDatAnalise)
						
						cTabVlr := iIf(!lCobCoPart, B30->B30_TABPRE, B30->B30_TABREC)
						
						if ! empty(cTabVlr)
							
							__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B30',cCodEsp,cCodUnd, lCobCoPart)
							
							if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, B30->B30_VIGDE, B30->B30_VIGATE)
									
								exit
								
							endIf
							
						endIf
						
					endIf
					
				B30->( dbSkip() )
				endDo
				
			endIf

		elseIf aOrdensNiv[nForNiv] $ "BMC" .and. ! lCobCoPart
			
			cSQL := "SELECT BMC_NIVEL,BMC_VALUS, BMC_VALUSA, BMC_DATDE, BMC_VLRPAG, BMC_TABPRE, BMC_VIGDE, BMC_VIGATE, "
			cSQL += "       BMC_VLUSRE, BMC_VLRPGA, BMC_BANDA "
			cSQL += "  FROM " + cNameBMC + " WHERE "
			cSQL += "BMC_FILIAL = '" + xFilial("BMC") + "' AND "
			cSQL += "BMC_CODINT = '" + cCodInt + "' AND "
			cSQL += "BMC_TIPPRE = '" + cTipPre + "' AND "
			cSQL += "BMC_CODPAD = '" + cCodPad + "' AND "
			
			cSQL += PLREQNI("BMC", "BMC_CODPSA", __aNiveis[2], allTrim(cCodPro))
			
			cSQL += "( '" + dtos(dDatAnalise) + "' >= BMC_VIGDE  OR BMC_VIGDE = ' ' ) AND "
			cSQL += "( '" + dtos(dDatAnalise) + "' <= BMC_VIGATE OR BMC_VIGATE = ' ' ) AND "
			
			cSQL +=  cNameBMC + ".D_E_L_E_T_ = ' ' "
			
			cSQL +=  " ORDER BY BMC_NIVEL DESC "
			
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
				
			if !PLSAUTPDIR->(eof())
			
				plsTField("PLSAUTPDIR",.f.,{ "BMC_VIGDE","BMC_VIGATE" } )

				//Se a vigencia estiver dentro do limite parametrizado...			   
				if PLSINTVAL("PLSAUTPDIR","BMC_VIGDE","BMC_VIGATE",dDatAnalise)
					
					// Se o campo APOS DATA não tiver preenchido vou pegar os valores 	  
					// padroes, ao contrario verifico a data do campo com a data base da    
					// analise                                                              
					// Tratamento da nova amarração com a tabela de preço/valorização.
					if ! empty(PLSAUTPDIR->BMC_TABPRE)
						
						__XaRetTabPre := PLVLTBPR(PLSAUTPDIR->BMC_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BMC',cCodEsp,cCodUnd, lCobCoPart)
						
						PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, PLSAUTPDIR->BMC_VIGDE, PLSAUTPDIR->BMC_VIGATE)
						
					endIf
					
				endIf   
				
			endIf
			
			PLSAUTPDIR->(dbCloseArea())

		elseIf aOrdensNiv[nForNiv] $ "BMB" .and. ! lCobCoPart
		
			for nBmb := 1 to 2
			
				// Primeiro tenta achar parametrização para o tipo de prestador corrente.
				// Se não achar, tenta achar parametrização generica.
				if nBmb == 1
					cAuxTipPre := cTipPre
				else
					cAuxTipPre := space(TamSX3("BMB_TIPPRE")[1])
				endIf
				
				if BMB->(msSeek(xFilial("BMB")+cCodInt+cAuxTipPre))
				
					while !BMB->( eof() ) .and. BMB->BMB_CODINT + BMB->BMB_TIPPRE == cCodInt+cAuxTipPre
						
						// Faz a analize da vigencia.
						if PLSINTVAL("BMB","BMB_VIGDE","BMB_VIGATE",dDatAnalise)
						
							if !empty(BMB->BMB_TABPRE)
								
								__XaRetTabPre := PLVLTBPR(BMB->BMB_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BMB',cCodEsp,cCodUnd, lCobCoPart)
								
								if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef,  @aVigAtu, BMB->BMB_VIGDE, BMB->BMB_VIGATE)
									
									exit
								
								endIf
								
							endIf
							
						endIf
						
					BMB->( dbSkip() )
					endDo
					
				endIf                                                                                  
				
				if lOk
					exit
				endIf
				
			next
			
		elseIf aOrdensNiv[nForNiv] $ "B29" .and. ! lCobCoPart
			
			// Obtem as tabelas de preço disponiveis para este prestador na tabela B29 - Somente as que estiveram com vigencia em aberto.
			B29->(dbSetOrder(1))
			if B29->(msSeek(xFilial("B29")+cCodRDA+cCodInt))
			
				while !B29->( eof() ) .and. B29->B29_CODIGO+B29->B29_CODINT == cCodRDA+cCodInt
					
					// Faz a analize da vigencia.
					if PLSINTVAL("B29","B29_VIGINI","B29_VIGFIN",dDatAnalise)

						// Trata amarração com a nova tabela de preço/valorização.
						if ! empty(B29->B29_TABPRE)
							
							__XaRetTabPre := PLVLTBPR(B29->B29_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B29',cCodEsp,cCodUnd, lCobCoPart)

							if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, B29->B29_VIGINI, B29->B29_VIGFIN)
									
								exit
								
							endIf

						endIf
						
					endIf

				B29->( dbSkip() )
				endDo
				
			endIf
						
		elseIf aOrdensNiv[nForNiv] $ "B24" .and. ! lCobCoPart
			
			// Obtem as tabelas de preço disponiveis para este prestador na tabela B24 - Somente as que estiveram com vigencia em aberto.
			aTabs := aClone(SeekB24(cCodRDA,cCodInt,cCodLoc,dDatAnalise))
			
			for nTab := 1 to len(aTabs)
				
				if ! empty(aTabs[nTab])
				
					__XaRetTabPre := PLVLTBPR(aTabs[nTab],cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B24',cCodEsp,cCodUnd, lCobCoPart)
					
					if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef,  @aVigAtu, B24->B24_VIGINI, B24->B24_VIGFIN)
									
						exit
								
					endIf
					
				endIf
				
			next
			
		elseIf aOrdensNiv[nForNiv] $ "B85" .and. ! lCobCoPart

			//Verifico no nivel de local de RDA x Associacao.						
			B62->(dbSetOrder(1))
			if B62->(msSeek(xFilial("B62")+cCodRDA+cCodInt))
				
				while !B62->( eof() ) .and. B62->B62_CODIGO+B62->B62_CODINT == cCodRDA+cCodInt
					
					// Faz a analize da vigencia.
					if PLSINTVAL("B62","B62_DTVGIN","B62_DTVGF",dDatAnalise)
						
						B85->( dbSetOrder(01) )
						
						if B85->( msSeek(xFilial("B85")+B62->B62_ASSCLA) )
							
							while !B85->( eof() ) .and. B85->(B85_CODASS+B85_CLASSE) == B62->B62_ASSCLA
						
								// Faz a analize da vigencia.
								if PLSINTVAL("B85","B85_VIGINI","B85_VIGFIN",dDatAnalise)
						
									// Tratamento da nova amarração com a tabela de preço/valorização.
									if ! empty(B85->B85_TABPRE)
						
										__XaRetTabPre := PLVLTBPR(B85->B85_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B85',cCodEsp,cCodUnd,lCobCoPart)

										if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, B85->B85_VIGINI, B85->B85_VIGFIN)
									
											exit
								
										endIf
										
									endIf
									
								endIf        
								
							B85->( dbSkip() )
							endDo
							
						endIf
						
					endIf

					if lOk
						exit
					endIf
					
				B62->( dbSkip() )
				endDo
				
			endIf
		
		elseIf aOrdensNiv[nForNiv] $ "B12" .and. ! lCobCoPart .and. lFoundBB8
			
			B12->(dbSetOrder(1))
			
			if B12->(msSeek(xFilial("B12")+cCodInt+BB8->BB8_EST))
				
				while !B12->( eof() ) .and. B12->(B12_FILIAL+B12_CODINT+B12_CODEST) == xFilial("B12")+cCodInt+BB8->BB8_EST
				
					if PLSINTVAL("B12","B12_VIGDE","B12_VIGATE",dDatAnalise)														
				
						if ! empty(B12->B12_TABPRE)

							__XaRetTabPre := PLVLTBPR(B12->B12_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B12',cCodEsp,cCodUnd, lCobCoPart)
								
							if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, B12->B12_VIGDE, B12->B12_VIGATE)
							
								exit
						
							endIf
							
						endIf
						
					endIf
						
				B12->( dbSkip() )
				endDo
				
			endIf
			
		elseIf aOrdensNiv[nForNiv] $ "B13" .and. ! lCobCoPart .and. lFoundBB8
			
			// Depois localiza o municipio com vigencia ativa.
			B13->(dbSetOrder(1)) //B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN+B13_CODTAB+B13_SEQUEN
			
			if B13->(msSeek(xFilial("B13")+cCodInt+BB8->(BB8_EST+BB8_CODMUN)) )
			
				while !B13->( eof() ) .and. B13->(B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN) == xFilial("B13")+cCodInt+BB8->(BB8_EST+BB8_CODMUN)
										
					if PLSINTVAL("B13","B13_VIGDE","B13_VIGATE",dDatAnalise)	
																								
						// Trata amarração com a nova tabela de preço.
						if ! empty(B13->B13_TABPRE)
						
							__XaRetTabPre := PLVLTBPR(B13->B13_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B13',cCodEsp,cCodUnd, lCobCoPart)
							
							if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, B13->B13_VIGDE, B13->B13_VIGATE)
							
								exit
						
							endIf
							
						endIf
						
					endIf
					
				B13->( dbSkip() )
				endDo
				
			endIf
			
		elseIf aOrdensNiv[nForNiv] $ "BS9" .and. ! lCobCoPart .and. ! lReembolso .and. cTipoUsr == "2"

			cSql := "SELECT BS9_VIGDE,BS9_VIGATE,BS9_TABPRE FROM "+retSqlName("BS9")+" WHERE BS9_FILIAL = '"+xFilial("BS9")+"' "
			cSql += "AND BS9_SUBCON = '"+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+"' "
			cSql += "AND BS9_CODUNI = '"+cCodUnd+"' "
			cSql += "AND D_E_L_E_T_ = ' ' "
			
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TRBBS9",.f.,.t.)
			
			if !TRBBS9->(eof())
				plsTField("TRBBS9",.f.,{ "BS9_VIGDE","BS9_VIGATE" } )
			endIf
		
			while !TRBBS9->( eof() )
				
				//Se a vigencia estiver dentro do limite parametrizado...			   
				if PLSINTVAL("TRBBS9","BS9_VIGDE","BS9_VIGATE",dDatAnalise)	
							
					if  ! empty(TRBBS9->BS9_TABPRE)
					
						__XaRetTabPre := PLVLTBPR(TRBBS9->BS9_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BS9',cCodEsp,cCodUnd, lCobCoPart)
					
						if PLSRTPFI(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nVlrFil, @nBanda, @nRef, @aVigAtu, TRBBS9->BS9_VIGDE, TRBBS9->BS9_VIGATE)
							
							exit
						
						endIf
						
					endIf
					
				endIf

			TRBBS9->( dbSkip() )
			endDo
			
			TRBBS9->( dbCloseArea() )

		elseIf aOrdensNiv[nForNiv] $ "BG6" .and. cTipoUsr == "2"

			BG6->(dbSetOrder(1))
			if BG6->(msSeek(xFilial("BG6")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub))
		
				while ! BG6->( eof() ) .and. BG6->(BG6_FILIAL+BG6_CODINT+BG6_CODEMP+BG6_NUMCON+BG6_VERCON+BG6_SUBCON+BG6_VERSUB) == xFilial("BG6")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub
			
		            if PLSINTVAL("BG6","BG6_DATINI","BG6_DATFIN",dDatAnalise)
				
						cSeqRel := BG6->BG6_SEQREL
				
						if !lCobCoPart
							nVlrFil := BG6->BG6_VALFIL
						else
							nVlrFil := BG6->BG6_VLRREC
						endIf
				
						if nVlrFil > 0
							
							lOK 	:= .t.
							cAlias  := "BG6"
							dVigIni := BG6->BG6_DATINI
							dVigFim := BG6->BG6_DATFIN

							exit

						endIf
						
					endIf
			
				BG6->( dbSkip() )
				endDo
				
			endIf
	
		endIf
		
		if lOk
			exit
		endIf
		
	next
	
endIf

//Se nao encontrar tabela de preço e valor de filme em lugar nenhum, busca na tabela de filme. 
//Este é o nivel mais generico para filme (BP8)
if ! lOK

	if ( ! lCobCoPart .and. ! lZeraTudo) .or. lCobCoPart
	
		cSQL := "SELECT BP8_VLRFIL,BP8_VLRREC,BP8_VIGDE,BP8_VIGATE FROM "+retSqlName("BP8")+" WHERE "
		cSQL += "BP8_FILIAL = '"+xFilial("BP8")+"' AND "
		cSQL += "BP8_CODINT = '"+cCodInt+"' AND "
		
		if !empty(cSeqRel)
			cSQL += " BP8_SEQFIL = '"+cSeqRel+"' AND "
		else
			cSQL += " ( ('" + dtos( dDatAnalise ) + "' BETWEEN BP8_VIGDE AND BP8_VIGATE) OR BP8_VIGATE = ' ')  AND "
		endIf
		
		cSQL += " D_E_L_E_T_ = ' ' "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLstrbM2",.f.,.t.)
					
		if !PLstrbM2->( eof() )
			
			plsTField("PLstrbM2",.f.,{ "BP8_VLRFIL","BP8_VLRREC","BP8_VIGDE","BP8_VIGATE" } )
			
			nVlrFil := iIf(!lCobCoPart, PLstrbM2->BP8_VLRFIL, PLstrbM2->BP8_VLRREC )
			
			if nVlrFil <> 0
				lOK     	:= .t.
				cAlias  	:= "BP8"
				aVigAtu		:= { cAlias, PLstrbM2->BP8_VIGDE, PLstrbM2->BP8_VIGATE }
			endIf
			
		endIf
		
		PLstrbM2->( dbCloseArea() )
	endIf

endIf

if lOK
	
	nVlrFilCalc := nVlrFil * nRef

	if nDesconto > 0
		nVlrFilCalc := nVlrFilCalc - ( ( nVlrFilCalc * nDesconto ) / 100 )
	endIf

	if nAcrescimo > 0
		nVlrFilCalc := nVlrFilCalc + ( ( nVlrFilCalc * nAcrescimo ) / 100 )
	endIf

	// Calcula o filme utilizando a formula padrao da funcao PLSRETVFIL().
	if cConsFt == "1" .and. nFatMul > 1
		nVlrFilCalc := nVlrFilCalc * nFatMul
	endIf
	
	// Aplica a banda.
	// cConsBd = Considera Banda ? - Este parametro vem do cadastro de unidades de medida de saude (BD3).
	if cConsBd == "1" .and. nBanda > 0
		nVlrFilCalc := (nVlrFilCalc * nBanda) / 100
	endIf

	// Aplica percentual de aumento ou redução
	if cCodUnd $ cMVPLSUNPR .and. nPrPrRl <> 0
		nVlrFilCalc := nVlrFilCalc + ( ( nVlrFilCalc * nPrPrRl ) / 100 )
	endIf

	// Calcula o filme utilizando a formula padrao da funcao PLSRETVFIL().
	nVlrFilCalc := round( nVlrFilCalc, nDecBAS ) * nQtd 

endIf	

if existBlock("PLSALTM2")
   
   aRetPtoEnt := execBlock("PLSALTM2",.f.,.f.,{nRef,cAlias,lOK,nVlrFil,nVlrFilCalc,cCodRda,cCodInt,cCodLoc,cCodEsp,;
   												cRegAte,lCobCoPart,cCodPro,cCodUnd,dDatAnalise,cCodPad,nQtd,lReembolso,nFatMul,cConsFt})

   nVlrFilCalc	:= aRetPtoEnt[1]
   nVlrFil		:= aRetPtoEnt[2]   
   cAlias  		:= aRetPtoEnt[3]
   
   if ! lOK .and. ( nVlrFil > 0 .or. nVlrFilCalc > 0)
   		lOK := .t.
   endIf
   
endIf

//[Nao achou em nivel nenhum...                        
if ! lOK

   PLSPOSGLO(PLSINTPAD(),__aCdCri030[1],__aCdCri030[2])

   cCodCri 	:= __aCdCri030[1]
   cMsg    	:= cCodCri+" - "+PLSBCTDESC()
   lOK 		:= .f.
   
   aadd(aRetFil, { 0, "", 0, 0, 0, 0, "", 0, 0, "0", '0', 0, 0, 0, 0 } )

else

	aadd(aRetFil, { round(nRef, nDecREF ) ,cAlias, round(nVlrFil, nDecCOF ), round(nVlrFilCalc, nDecBAS ), round(nVlrFilCalc, nDecBAS ), nFatMul, "Vr.Fil", 0, 0, "0", '0', nRef, 0, nDesconto, nAcrescimo})

endIf   

return( { lOK, cMsg, cCodCri, aRetFil, aVigAtu } )

/*/{Protheus.doc} PLSRETVREA
Retorna o valor em real

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETVREA(paramixb,lObsoleto)
local nQtd       	:= paramixb[1]
local nRef       	:= paramixb[2]
local dDatAnalise	:= paramixb[4]
local cCodRDA    	:= paramixb[5]
local cCodInt    	:= paramixb[6]
local cCodLoc    	:= subStr(paramixb[7],1,3)
local cCodTab    	:= paramixb[8]
local cCodPad    	:= paramixb[9]
local cCodPro    	:= paramixb[10]
local cMes          := paramixb[11]
local cAno          := paramixb[12]
local cCodEsp     	:= paramixb[13]
local cModPag    	:= paramixb[15]
local nVlrApr    	:= paramixb[17]
local cTipPre    	:= paramixb[18]
local cCodEmp    	:= iIf(len(paramixb[19])>0, subStr(paramixb[19,2],5,4), "")
local cConEmp    	:= iIf(len(paramixb[19])>0, paramixb[19,9], "")
local cCodPla    	:= iIf(len(paramixb[19])>0, paramixb[19,11], "")
local cVerCon    	:= iIf(len(paramixb[19])>0, paramixb[19,39], "")
local cSubCon    	:= iIf(len(paramixb[19])>0,paramixb[19,41], "")
local cVerSub    	:= iIf(len(paramixb[19])>0, paramixb[19,42], "")
local cOpeOri    	:= iIf(len(paramixb[19])>0, paramixb[19,45], "")
local nFatMul    	:= paramixb[20]
local cConsFt    	:= paramixb[21]
local lCobCoPart 	:= paramixb[25]
local nPrPrRl		:= paramixb[27]
local cPadInt    	:= paramixb[29]
local cRegAte    	:= paramixb[30]
local aRdas      	:= paramixb[34]
local cCodUnd    	:= paramixb[35]
local lReembolso  	:= paramixb[36]
local cPorteMed  	:= paramixb[39]
local nVlrAprPag 	:= paramixb[41]
local aComEve   	:= paramixb[43]
local cRegPag		:= paramixb[44]
local cRegCob		:= paramixb[45]
local aPacote	  	:= paramixb[46]
local cFinAte	  	:= iIf(len(paramixb) >= 47,paramixb[47],"")
local cRdaEdi       := iIf(len(paramixb) > 49,paramixb[50],"")

local nI			:= 0
local nNiveis    	:= 0
local nValRef	  	:= 0
local nPos			:= 0
local nPrTxPag		:= 0
local nForBE9   	:= 1
local nForBC0   	:= 1
local nForNiv		:= 1
local nDesconto 	:= 0
local nAcrescimo	:= 0
local nBanda 		:= 0
local nDecREF		:= iIf( ! lCobCoPart, PLGetDec('BD7_REFTDE'), PLGetDec('BD7_RFTDEC'))
local nDecCOF		:= iIf( ! lCobCoPart, PLGetDec('BD7_COEFUT'), PLGetDec('BD7_COEFPF'))
local nDecBAS		:= iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'), PLGetDec('BD7_VLRBPF'))

local cNameBE9  	:= BE9->(retSqlName("BE9"))
local cNameBC0  	:= BC0->(retSqlName("BC0"))
local cNameBMG		:= BMG->(retSqlName("BMG"))
local cNameBMC		:= BMC->(retSqlName("BMC"))
local cNameBME		:= BME->(retSqlName("BME"))
local cAlias     	:= ""
local cMsg       	:= ""
local cCodCri    	:= ""
local cOpeInt		:= ''
local cTabPre		:= ""
local cTabVlr		:= ""
local cTipo      	:= iIf( ! lCobCoPart, "1", "2")
local lOk        	:= .f.
local lInterc		:= .f.
local lInformada	:= .f.
local lFoundBB8		:= .f.
local lTabEsp		:= .f.
local lPorteMed  	:= ! empty(cPorteMed)
local dVigIni	 	:= ctod("")
local dVigFim	 	:= ctod("")
local aRetGruOpe 	:= {}
local aRetRea    	:= {}
local aRetTabPre	:= {}
local aRetPtoEnt 	:= {}
local aRetInt		:= {}
local aVigAtu		:= {}
local aReturn		:= {}
local aRetTabZ	    := {}
local aOrdensNiv	:= {}
local __XaRetTabPre	:= {.f.,{}}
Local lPLSREA01	:= existBlock("PLSREA01")
Local nTab	:= 0
Local lOkAD := .F.

default lObsoleto	:= .f.

cMemorial	+= "Unidade: " + cCodUnd + CRLF + "Função de cálculo: PLSRETREA " + CRLF

if __cCdTbPd <> cCodPad .or. len(__aNiveis) == 0
	__cCdTbPd := cCodPad
	__aNiveis := PLSESPNIV(cCodPad)
endIf	

nNiveis := (__aNiveis[1]+1)

if len(aReturn) >= 5 .and. len(aReturn[5]) > 0
	
	//Se a data da analise nao estiver dentro da vigencia encontrada enteriormente, preciso calcular de novo
	if ! ( 	( empty(aReturn[5][2]) .or.  aReturn[5][2] <= dDatAnalise) .and.;  	//dataDe
			( empty(aReturn[5][3]) .or.  aReturn[5][3] >= dDatAnalise) )		//dataAte
	
		aReturn := {}
		
	endIf
	
else
	aReturn	:= {}
endIf
	
//Vou precisar da vigencia da composicao caso o nivel seja o BD4
if (nPcCodUnd :=  aScan(aComEve,{|x| allTrim(x[1]) == allTrim(cCodUnd) }) ) > 0

	dVigIni := aComEve[nPcCodUnd][20]
	dVigFim := aComEve[nPcCodUnd][21]
	
endIf

nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(cCodUnd) })
 
if nPos > 0
	
	nFatMul := iIf( len(aRdas[nPos])>= 10,iIf(aRdas[nPos,10]<>"0",nFatMul,1) ,nFatMul	)
	
elseIf nFatMul == 0
	
	nFatMul := 1
	
endIf

aRetInt := PLINTERC(cTipo, cCodRda, cOpeOri, cRegPag, cRegCob)
lInterc := aRetInt[1]
cOpeInt := aRetInt[2]

//Z-0 : If lInterc -> marca que foi considerado intercâmbio
cMemorial += IIF(lInterc, "- Atendimento de intercâmbio" + CRLF, "")

//Se for pagamento e o valor apresentado padrao do bd6 for zero,     
//procurar tambem no aRdas que agora tambem tem o valor apresentado do 
//BD7                                                                

if nVlrApr == 0
	
	nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(cCodUnd) })
	
	if nPos == 0
		nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(PLSA720VND(cCodUnd)) })
	endIf
	
	if nPos > 0
		
		if len(aRdas[nPos]) >= 7 .and. aRdas[nPos,7] > 0
			
			if ! lCobCoPart
				nVlrApr 	:= aRdas[nPos,7] //Valor apresentado do BD7 (BD7_VLRAPR)
			else
				nVlrAprPag 	:= aRdas[nPos,7] //Valor apresentado do BD7 (BD7_VLRAPR)
			endIf
			
		endIf
		
	endIf
	
endIf

//Z-0 marcar o valor apresentado

lInformada := PLMFORCA(cCodUnd,nVlrApr,lInterc,cTipPre,nVlrAprPag,lCobCoPart,cOpeOri,cCodPad,cCodPro,cCodEmp,cCodLoc,cAno,cMes,aRetTabZ) // Diz se eh informada ou calculada.

//Z-0 If lInformada, modo de cálculo informada, ou calculada
cMemorial += IIf(lInformada, "- Modo de cálculo: Informada" + CRLF, "- Modo de Cálculo: Calculada" + CRLF)

//Se for uma unidade informada, for uma cobranca de CO e o valor     
//apresentado para cobranca for zero porem existe valor apr          
//de pagamento este sera o valor base de cobranca...                 
if lInformada .and. lCobCoPart .and. nVlrApr == 0 .and. nVlrAprPag > 0
	nVlrApr := nVlrAprPag
endIf

cMeMorial += "- Valor Apresentado: " + Alltrim(Str(nvlrapr)) + CRLF

if lInformada

	//Antes de tudo eu valorizo o pacote								
	if len(aPacote) >= 4 .and. aPacote[1] > 0
		
		nRef 	:= aPacote[1]
		cAlias	:= iIf( ! empty(aPacote[4]), aPacote[4], "B43" )
		aVigAtu	:= { cAlias, dVigIni, dVigFim }
		lOK		:= .t.

	elseIf nVlrApr > 0
		
		nRef 	:= nVlrApr
		cAlias 	:= "VAP"
		lOK  	:= .t.

	endIf
	If lOk 
		cMemorial += "- Referência: " + Alltrim(Str(nRef)) + CRLF
		cMeMorial += "- Alias: " + cAlias + CRLF
	endIf
else

	//Antes de tudo eu valorizo o pacote
	if len(aPacote) >= 4 .and. aPacote[1] > 0
		
		nRef 	:= aPacote[1]
		cAlias	:= iIf( ! empty(aPacote[4]), aPacote[4], "B43" )
		aVigAtu	:= { cAlias, dVigIni, dVigFim }
		lOK 	:= .t.
		
	endIf
	
	if ! lOK

		aOrdensNiv := {"BGH","BE9","BC0","BC6","BC5","BMG","BME","BMC","B24","B29"}
		
		if existBlock("PLSONVPC")
			aOrdensNiv := execBlock("PLSONVPC",.f.,.f.,{aOrdensNiv,lCobCoPart,cCodRda,cOpeOri,"2"})
		endIf

		for nForNiv := 1 to len(aOrdensNiv)

			if aOrdensNiv[nForNiv] $ "BGH" .and. lInterc
				
				aRetGruOpe := PLSGRUOPE(cTipo, cOpeInt, dDatAnalise, nNiveis, __aNiveis, cCodPro, cModPag, cCodPad, cCodEsp,;
										cCodUnd, cCodPla, nVlrApr, nil, nil, lInterc, cFinAte, cCodRda, cRdaEdi,,,,cRegAte)
				
				if aRetGruOpe[7] .and. aRetGruOpe[3] > 0
					
					lOK 	:= .t.

					nRef 	:= aRetGruOpe[3]
					cAlias 	:= aRetGruOpe[6]

					if len(aRetGruOpe) >= 16
						dVigIni := aRetGruOpe[15]
						dVigFim := aRetGruOpe[16]
					endIf	

					aVigAtu	:= { cAlias, dVigIni, dVigFim }
					
				endIf

			elseIf aOrdensNiv[nForNiv] $ "BE9"
			
				cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBE9 + " WHERE "
				cSQL += "BE9_FILIAL = '"+xFilial("BE9")+"' AND "
				cSQL += "BE9_CODIGO = '"+cCodRdA+"' AND "
				cSQL += "BE9_CODINT = '"+cCodInt+"' AND "
				cSQL += "BE9_CODLOC = '"+cCodLoc+"' AND "
				cSQL += "BE9_CODESP = '"+cCodEsp+"' AND "
				cSQL += "BE9_CODPLA = '"+cCodPla+"' AND "
				cSQL += "BE9_CODPAD = '"+cCodPad+"' AND "
				
				cSQL += PLREQNI("BE9", "BE9_CODPRO", __aNiveis[2], allTrim(cCodPro))

				cSQL += "( '"+dtos(dDatAnalise)+"' >= BE9_VIGDE  OR BE9_VIGDE = ' ' ) AND "
				cSQL += "( '"+dtos(dDatAnalise)+"' <= BE9_VIGATE OR BE9_VIGATE = ' ' ) AND "
				
				cSQL +=  cNameBE9+".D_E_L_E_T_ = ' ' "
				
				cSQL +=  " ORDER BY BE9_NIVEL DESC "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
					
				if ! PLSAUTPDIR->(eof())
					
					BE9->(dbGoTo(PLSAUTPDIR->(REC)))
					
					nRef 		:= iIf(!lCobCoPart, BE9->BE9_VALREA, BE9->BE9_VLRECT)
					nDesconto 	:= BE9->BE9_PERDES
					nAcrescimo 	:= BE9->BE9_PERACR
					
					if lPLSREA01
					
						aRetREA01 := execBlock("PLSREA01",.f.,.f.,{aComEve,nRef,cCodUnd})
						nRef      := aRetREA01[1]
						
					endIf

					if nRef > 0
					
						lOK 	:= .t.
						cAlias	:= "BE9"
						aVigAtu	:= { cAlias, BE9->BE9_VIGDE, BE9->BE9_VIGATE }
					
					elseIf nDesconto + nAcrescimo > 0
						lOkAD := .T.
					endIf
					
				endIf
				
				PLSAUTPDIR->(dbCloseArea())

			elseIf aOrdensNiv[nForNiv] $ "BC6"				
				
				aRetTabPre := PLSTABPRE(/*01*/cCodInt, 		/*02*/ cCodRda,   	/*03*/cCodPad,; 
										/*04*/cCodPro, 		/*05*/dDatAnalise,	/*06*/cPadInt,; 
										/*07*/cCodPla, 		/*07*/cOpeOri, 		/*08*/cCodLoc,;
										/*09*/lCobCoPart,	/*10*/cRegAte, 		/*11*/cFinAte,; 
										/*12*/cCodTab, 		/*13*/lReembolso,	/*14*/cModPag,;
										/*15*/nRef , .F., @lOkAD)
											
				if len(aRetTabPre) > 0 .and. aRetTabPre[1]
					
					nRef 		:= aRetTabPre[2,2]
					nDesconto 	:= aRetTabPre[2,5]
					nAcrescimo	:= aRetTabPre[2,6]

					if nRef > 0
						
						lOK     := .t.
						cAlias  := aRetTabPre[3]
						aVigAtu	:= { cAlias, aRetTabPre[4][2] ,aRetTabPre[4][3] }
						
					endIf
				elseIf lOkAD
					nDesconto 	:= aRetTabPre[2,5]
					nAcrescimo	:= aRetTabPre[2,6]
				endIf
			
			elseIf aOrdensNiv[nForNiv] $ "BC5"
					
				// Redefine as variaveis de controle
				cTabPre := ""
				lTabEsp := .f.
				
				BB8->(dbSetOrder(1))
				lFoundBB8 := SeekBB8E(cCodRDA,cCodInt,cCodLoc)

				// Verifica se existe tabela de preço no local de atendimento. Esse codigo se refere a tabela de preço X RDA BC5.
				if  lFoundBB8 .and. ! empty(BB8->BB8_TABPRE)
					cTabPre := BB8->BB8_TABPRE
					lTabEsp := .t.
				endIf

				// Verifica se existe tabela de preço especifica para esta RDA.
				BC5->(dbSetOrder(1))
				if BC5->( msSeek(xFilial("BC5") + cCodInt + cCodRda) )

					// Processa as vigencias.
					while ! BC5->(eof()) .and. BC5->(BC5_FILIAL+BC5_CODINT+BC5_CODRDA) == xFilial("BC5") + cCodInt + cCodRda

						// Testa regra de tabela especifica.
						if ( lTabEsp .and. cTabPre == BC5->BC5_TABPRE ) .or. ( ! lTabEsp )
							
							// Faz a analize da vigencia.
							if PLSINTVAL("BC5","BC5_DATINI","BC5_DATFIM",dDatAnalise)

								// Trata amarração com a nova tabela de preço/valorizacao.
								cTabVlr := iIf(!lCobCoPart, BC5->BC5_TABPRE, BC5->BC5_TABREC)
								
								if ! empty(cTabVlr)
								
									__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BC5',cCodEsp,cCodUnd, lCobCoPart)
									
									if PLRTPREA(__XaRetTabPre, "BC5", @cAlias, cModPag, lCobCoPart, @lOk, @nRef, @nDesconto, @nAcrescimo, @aVigAtu, BC5->BC5_DATINI, BC5->BC5_DATFIM, @lOkAD) .OR. lOKAD
											
										exit
										
									endIf
									
								else

									// Us Pagar Pre-Pag  - Us Receber Pre-Pag
									nRef := iIf(! lCobCoPart, BC5->BC5_VPPP, BC5->BC5_VRPP ) 	

									//pre-pagamento
									if allTrim(cModPag) != "1"
										
										// Us Pagar custo - Us Receber custo
										nRef := iIf(! lCobCoPart, BC5->BC5_VPCO, BC5->BC5_VRCO ) 	
																			
									endIf
									
									dVigIni := BC5->BC5_DATINI
									dVigFim := BC5->BC5_DATFIM

									if nRef > 0
							
										lOk 	:= .t.
										cAlias 	:= "BC5"
										aVigAtu	:= { cAlias, dVigIni, dVigFim }
										
										exit
										
									endIf

								endIf

							endIf
							
						endIf
						
					BC5->( dbSkip() )
					endDo
					
				endIf

			elseIf aOrdensNiv[nForNiv] $ "B24"
		
				// Obtem as tabelas de preço disponiveis para este prestador na tabela B24 - Somente as que estiveram com vigencia em aberto.
				aTabs := aClone(SeekB24(cCodRDA,cCodInt,cCodLoc,dDatAnalise))
				// Processa todas as tabelas de preço do prestador.
				for nTab := 1 to len(aTabs)
					// Trata amarração com a nova tabela de preço/valorização.
					if !empty(aTabs[nTab])
						__XaRetTabPre := PLVLTBPR(aTabs[nTab],cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B24',cCodEsp,cCodUnd, lCobCoPart)
						If PLRTPREA(__XaRetTabPre, "B24", @cAlias, cModPag, lCobCoPart, @lOk, @nRef, @nDesconto, @nAcrescimo, @aVigAtu, B24->B24_VIGINI, B24->B24_VIGFIN, @lOkAD) .OR. lOKAD		
							exit
						endIf	
					endIf
				next
			
			elseIf aOrdensNiv[nForNiv] $ "B29"
			
				B29->(dbSetOrder(1))
				if B29->(msSeek(xFilial("B29")+cCodRda+cCodInt))
				
					while ! B29->( eof() ) .and. B29->(B29_CODIGO+B29_CODINT) == cCodRda+cCodInt
						
						// Faz a analize da vigencia.
						if PLSINTVAL("B29","B29_VIGINI","B29_VIGFIN",dDatAnalise)
							
							// Trata amarração com a nova tabela de preço/valorização.
							if ! empty(B29->B29_TABPRE)
								
								__XaRetTabPre := PLVLTBPR(B29->B29_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B29',cCodEsp,cCodUnd, lCobCoPart)
								
								if PLRTPREA(__XaRetTabPre, "B29", @cAlias, cModPag, lCobCoPart, @lOk, @nRef, @nDesconto, @nAcrescimo, @aVigAtu, B29->B29_VIGINI, B29->B29_VIGFIN, @lOkAD) .OR. lOKAD
										
									exit
									
								endIf
								
							endIf
							
						endIf
						
					B29->( dbSkip() )
					endDo

				endIf
			elseIf aOrdensNiv[nForNiv] $ "BME" .and. ! lCobCoPart 
				cSQL := "SELECT BME_NIVEL,BME_VALUS, BME_VALUSA, BME_DATDE, BME_VLRPAG, "
				cSQL += "       BME_VIGDE, BME_VIGATE, BME_VLRPGA, BME_BANDA "
				cSQL += " FROM " + cNameBME + " WHERE "
				cSQL += "BME_FILIAL = '" + xFilial("BME") + "' AND "
				cSQL += "BME_CODIGO = '" + cCodInt + cCodPla + "' AND "
				cSQL += "BME_TIPPRE = '" + cTipPre + "' AND "
				cSQL += "BME_CODPAD = '" + cCodPad + "' AND "				
				cSQL += PLREQNI("BME", "BME_CODPSA", __aNiveis[2], allTrim(cCodPro))
				cSQL += "( '" + dtos(dDatAnalise) + "' >= BME_VIGDE  OR BME_VIGDE  = ' ' ) AND "
				cSQL += "( '" + dtos(dDatAnalise) + "' <= BME_VIGATE OR BME_VIGATE = ' ' ) AND "				
				cSQL +=  cNameBME + ".D_E_L_E_T_ = ' ' "
				
				cSQL +=  " ORDER BY BME_NIVEL DESC "
				
				dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSAUTPDIR",.f.,.t.)
				
				if !PLSAUTPDIR->(eof())

					plsTField("PLSAUTPDIR",.f.,{ "BME_VIGDE","BME_VIGATE","BME_DATDE","BME_VLRPAG","BME_VLRPGA" } )
					
					// Se a vigencia estiver dentro do limite parametrizado...			   
					if PLSINTVAL( "PLSAUTPDIR","BME_VIGDE","BME_VIGATE",dDatAnalise)

						if empty(PLSAUTPDIR->BME_DATDE) .or. dtos(dDatAnalise) >= dtos(PLSAUTPDIR->BME_DATDE)
							nRef := PLSAUTPDIR->BME_VLRPAG
						else
							nRef := PLSAUTPDIR->BME_VLRPGA
						endIf
						
						dVigIni 	:= PLSAUTPDIR->BME_VIGDE
						dVigFim 	:= PLSAUTPDIR->BME_VIGATE
							
						if nRef > 0
							lOk       := .t.
							cAlias    := "BME"
							aVigAtu	  := { cAlias, dVigIni ,dVigFim }
						endIf	
						
					endIf
					
				endIf
				
				PLSAUTPDIR->(dbCloseArea())

			elseIf aOrdensNiv[nForNiv] $ "BMC" .and. ! lCobCoPart 
			
				cSQL := "SELECT BMC_NIVEL,BMC_VALUS, BMC_VALUSA, BMC_DATDE, BMC_VLRPAG, BMC_TABPRE, "
				cSQL += "       BMC_VIGDE, BMC_VIGATE, BMC_VLRPGA, BMC_BANDA, BMC_PERDES, BMC_PERACR "
				cSQL += " FROM " + cNameBMC + " WHERE "
				cSQL += "BMC_FILIAL = '" + xFilial("BMC") + "' AND "
				cSQL += "BMC_CODINT = '" + cCodInt + "' AND "
				cSQL += "BMC_TIPPRE = '" + cTipPre + "' AND "
				cSQL += "BMC_CODPAD = '" + cCodPad + "' AND "
				
				cSQL += PLREQNI("BMC", "BMC_CODPSA", __aNiveis[2], allTrim(cCodPro))

				cSQL += "( '" + dtos(dDatAnalise) + "' >= BMC_VIGDE  OR BMC_VIGDE  = ' ' ) AND "
				cSQL += "( '" + dtos(dDatAnalise) + "' <= BMC_VIGATE OR BMC_VIGATE = ' ' ) AND "
				
				cSQL +=  cNameBMC + ".D_E_L_E_T_ = ' ' "
				
				cSQL +=  " ORDER BY BMC_NIVEL DESC "
				
				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
				
				if !PLSAUTPDIR->(eof())

					plsTField("PLSAUTPDIR",.f.,{ "BMC_VIGDE","BMC_VIGATE","BMC_DATDE","BMC_VLRPAG","BMC_VLRPGA","BMC_PERDES","BMC_PERACR" } )
					
					// Se a vigencia estiver dentro do limite parametrizado...			   
					if PLSINTVAL( "PLSAUTPDIR","BMC_VIGDE","BMC_VIGATE",dDatAnalise)
						
						// Tratamento da nova amarração com a tabela de preço/valorização.
						if ! empty(PLSAUTPDIR->BMC_TABPRE)
							
							__XaRetTabPre := PLVLTBPR(PLSAUTPDIR->BMC_TABPRE, cCodInt, cCodPad, cCodPro, dDatAnalise, cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BMC',cCodEsp,cCodUnd, lCobCoPart)
							
							PLRTPREA(__XaRetTabPre, "BMC", @cAlias, cModPag, lCobCoPart, @lOk, @nRef, @nDesconto, @nAcrescimo, @aVigAtu, PLSAUTPDIR->BMC_VIGDE, PLSAUTPDIR->BMC_VIGATE, @lOkAD)
							
						else 

							if empty(PLSAUTPDIR->BMC_DATDE) .or. dtos(dDatAnalise) >= dtos(PLSAUTPDIR->BMC_DATDE)
								nRef := PLSAUTPDIR->BMC_VLRPAG
							else
								nRef := PLSAUTPDIR->BMC_VLRPGA
							endIf

							// Desconto - Acrescimo
							nDesconto  	:= PLSAUTPDIR->BMC_PERDES
							nAcrescimo 	:= PLSAUTPDIR->BMC_PERACR
							
							dVigIni 	:= PLSAUTPDIR->BMC_VIGDE
							dVigFim 	:= PLSAUTPDIR->BMC_VIGATE
							
							if nRef > 0
								lOk       := .t.
								cAlias    := "BMC"
								aVigAtu	  := { cAlias, dVigIni ,dVigFim }
							elseIf nDesconto + nAcrescimo > 0
								lOkAD := .T.
							endIf	

						endIf
						
					endIf
					
				endIf
				
				PLSAUTPDIR->(dbCloseArea())
			
			elseIf aOrdensNiv[nForNiv] $ "BMG" .and. ! lCobCoPart 
			
				cSQL := "SELECT BMG_BANDA,BMG_NIVEL,BMG_VALUS, BMG_VALUSA, BMG_DATDE, BMG_VLRPAG, BMG_VLRPGA"
				cSQL += "  FROM " + cNameBMG + " WHERE "
				cSQL += "BMG_FILIAL = '"+xFilial("BMG")+"' AND "
				cSQL += "BMG_CODINT = '"+cCodInt+"' AND "
				cSQL += "BMG_CODEMP = '"+cCodEmp+"' AND "
				cSQL += "BMG_NUMCON = '"+cConEmp+"' AND "
				cSQL += "BMG_VERCON = '"+cVerCon+"' AND "
				cSQL += "BMG_SUBCON = '"+cSubCon+"' AND "
				cSQL += "BMG_VERSUB = '"+cVerSub+"' AND "
				cSQL += "BMG_TIPPRE = '"+cTipPre+"' AND "
				cSQL += "BMG_CODPAD = '"+cCodPad+"' AND "
				
				cSQL += PLREQNI("BMG", "BMG_CODPSA", __aNiveis[2], allTrim(cCodPro))
				
				cSQL += cNameBMG + ".D_E_L_E_T_ = ' ' "
				
				cSQL +=  " ORDER BY BMG_NIVEL DESC, BMG_DATDE DESC "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSAUTPDIR",.f.,.t.)

				if ! PLSAUTPDIR->(eof())
					
					plsTField("PLSAUTPDIR",.f.,{ "BMG_DATDE","BMG_VALUS","BMG_VALUS","BMG_VALUSA","BMG_VLRPAG","BMG_BANDA","BMG_VLRPGA" } )
					
					if empty(PLSAUTPDIR->BMG_DATDE) .or. dtos(dDatAnalise) >= dtos(PLSAUTPDIR->BMG_DATDE)
						
						nRef := PLSAUTPDIR->BMG_VLRPAG
							
					else
						
						nRef := PLSAUTPDIR->BMG_VLRPGA
							
					endIf
					
					if nRef > 0
						
						lOk       := .t.
						cAlias    := "BMG"
						aVigAtu	  := { cAlias, PLSAUTPDIR->BMG_DATDE, ctod("") }
						
					endIf

				endIf
				
				PLSAUTPDIR->(dbCloseArea())

			elseIf aOrdensNiv[nForNiv] $ "BC0" .and. ! lCobCoPart
				
				cSQL := "SELECT R_E_C_N_O_ REC FROM "+cNameBC0+" WHERE "
				cSQL += "BC0_FILIAL = '"+xFilial("BC0")+"' AND "
				cSQL += "BC0_CODIGO = '"+cCodRdA+"' AND "
				cSQL += "BC0_CODINT = '"+cCodInt+"' AND "
				cSQL += "BC0_CODLOC = '"+cCodLoc+"' AND "
				cSQL += "BC0_CODESP = '"+cCodEsp+"' AND "
				cSQL += "BC0_CODTAB = '"+cCodTab+"' AND "
				cSQL += "BC0_CODPAD = '"+cCodPad+"' AND "
				
				cSQL += PLREQNI("BC0", "BC0_CODOPC", __aNiveis[2], allTrim(cCodPro))

				cSQL += "( '"+dtos(dDatAnalise)+"' >= BC0_VIGDE  OR BC0_VIGDE = ' ' ) AND "
				cSQL += "( '"+dtos(dDatAnalise)+"' <= BC0_VIGATE OR BC0_VIGATE = ' ' ) AND "
				cSQL += "(BC0_DATBLO = ' '  OR BC0_DATBLO > '"+dtos(dDatAnalise)+"' ) AND "
				cSql += "( (BC0_FORMUL = '1' AND (BC0_VALREA > 0 OR BC0_VALCH > 0 OR BC0_BANDA > 0 OR BC0_UCO > 0 OR BC0_PERACR > 0 OR BC0_PERDES > 0)) OR "
				cSql += "(BC0_FORMUL = '2' AND BC0_EXPRES <> ' ') ) AND "
				cSQL +=  cNameBC0+".D_E_L_E_T_ = ' ' "
				
				cSQL +=  " ORDER BY BC0_NIVEL DESC "
				
				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
				
				if ! PLSAUTPDIR->(eof())
					
					BC0->(dbGoTo(PLSAUTPDIR->(REC)))

					nRef		:= BC0->BC0_VALREA
					nDesconto 	:= BC0->BC0_PERDES
					nAcrescimo 	:= BC0->BC0_PERACR
					
					if nRef > 0
				
						lOK 	:= .t.
						cAlias 	:= "BC0"
						aVigAtu	:= {cAlias, BC0->BC0_VIGATE, BC0->BC0_VIGATE }
					elseIf nDesconto + nAcrescimo > 0
						lOkAD := .T.
					endIf
						
				endIf
				
				PLSAUTPDIR->(dbCloseArea())
			
			endIf
			
			if lOk .OR. lOkAD
				//Z-0 : Nesse ponto pegamos o alias que originou o valor
				cMemorial += "- Referência: "  + Alltrim(Str(nRef)) + CRLF
				cMeMorial += "- Alias: " + cAlias + CRLF
				exit
			endIf

		next

	endIf

	if existBlock("PLSALTRE")
		//Z-0 : marca que passou pela regra específica
		aRetPtoEnt := execBlock("PLSALTRE",.f.,.f.,{nRef,cAlias,lOK,lInformada,cCodRda,cCodInt,cCodLoc,cCodEsp,cRegAte,lCobCoPart,cCodPro,cCodUnd,dDatAnalise,cCodPad})
		
		nRef    := aRetPtoEnt[1]
		cAlias  := aRetPtoEnt[2]
		
		if ! lOK .and. nRef > 0
			
			lOK 	:= .t.
			aVigAtu	:= {cAlias, dVigIni, dVigFim }
			
		endIf
		//Z-0 : marca como ficou 
		cMeMorial += " Valores após aplicação da regra customizada [ PLSALTRE ] " + CRLF
		cMemorial += "- Referência: " + Alltrim(Str(nRef)) + CRLF
		cMeMorial += "- Alias: " + cAlias + CRLF
	endIf
	
endIf

//Busco o valor de referencia da BD4
if ! lOk .and. (nRef > 0 .OR. paramixb[2] > 0)
	If nRef == 0
		nRef := paramixb[2]
	endIf
	lOK		:= .t.
	cAlias	:= "BD4"
	
	aVigAtu	:= { cAlias, dVigIni, dVigFim }
	//Z-0 : marca o nível BD4
	cMemorial += "- Referência: "  + Alltrim(Str(nRef)) + CRLF
	cMeMorial += "- Alias: " + cAlias + CRLF
endIf

if lOk 

	nValRef := nRef

	// Aplica percentual de aumento ou redução
	if allTrim(cCodUnd) $ allTrim(cMVPLSUNPR) .and. nPrPrRl <> 0
		nRef := nRef + ( ( nRef * nPrPrRl ) / 100 )
	endIf
	
	if cConsFt == "1"
		nRef := round( (nRef * nFatMul), nDecBAS )
		cMeMorial += " Aplicação do fator multiplicador " + CRLF
		cMeMorial += "- Fator: " + Alltrim(str(nFatMul)) + CRLF
		cMemorial += "Valor acumulado da referência: " + Alltrim(Str(nRef)) + CRLF
	endIf

	//Aplica o desconto se ele existir								
	if nDesconto > 0
		nRef := ( nRef - ( nRef * nDesconto ) / 100 )
		cMeMorial += " Aplicação do Desconto " + CRLF
		cMeMorial += "- Percentual do desconto: " + Alltrim(Str(nDesconto)) + CRLF
		cMemorial += "Valor acumulado da referência: " + Alltrim(Str(nRef)) + CRLF
	endIf

	//Aplica o acrescimo se ele existir								
	if nAcrescimo > 0
		nRef := ( nRef + ( nRef * nAcrescimo ) / 100 )
		cMeMorial += " Aplicação do Acréscimo " + CRLF
		cMeMorial += "- Percentual do acréscimo: " + Alltrim(Str(nDesconto)) + CRLF
		cMeMorial += "Valor acumulado da referência: " + Alltrim(Str(nRef)) + CRLF
	endIf

endIf

cMemorial += " O valor de pagamento da unidade é: " + AllTrim(str(nRef))

aadd(aRetRea,{ 1, cAlias, round(nValRef, nDecCOF ), round( nRef * nQtd, nDecBAS ), round( nRef * nQtd, nDecBAS ), nFatMul, getNewPar("MV_SIMB1","R$"), 0, 0, "0", '0', 1, 0, nDesconto, nAcrescimo})

aReturn := { lOK, cMsg, cCodCri, aRetRea, aVigAtu }

return(aClone(aReturn))

/*/{Protheus.doc} PLSRETTCR
Retorna o tempo cirurgico  

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETTCR(paramixb)
local nQtd       	:= paramixb[1]
Local nRef			:= paramixb[2]
local dDatAnalise 	:= paramixb[4]
local cCodRDA    	:= paramixb[5]
local cCodInt    	:= paramixb[6]
local cCodLoc    	:= subStr(paramixb[7],1,3)
local cCodTab    	:= paramixb[8]
local cCodPad		:= paramixb[9]
local cCodPro    	:= paramixb[10]
local cCodEsp     	:= paramixb[13]
local cModPag    	:= paramixb[15]
local cCodEmp    	:= iIf(len(paramixb[19])>0, subStr(paramixb[19,2],atCodEmp[1],atCodEmp[2]), "")
local cCodPla 		:= iIf(len(paramixb[19])>0, paramixb[19,11], "")
local cOpeOri    	:= iIf(len(paramixb[19])>0, paramixb[19,45], "")
local nFatMul    	:= paramixb[20]
local cConsFt    	:= paramixb[21]
local lCobCoPart 	:= paramixb[25]
local nPrPrRl		:= paramixb[27]      
local aValAcu 		:= paramixb[28]
local cPadInt    	:= paramixb[29]
local cRegAte    	:= paramixb[30]                              
local cHorPro    	:= paramixb[33]       
local aRdas	  	 	:= paramixb[34]
local cCodUnd 	 	:= paramixb[35]
local lReembolso 	:= paramixb[36]
local nCatHos    	:= paramixb[37]
local dDatPro    	:= paramixb[40]
local cFinAte	  	:= iIf(len(paramixb) >= 47,paramixb[47],"")

local nVlrTCRea  	:= 0
local nVlrTCAcu  	:= 0
local nPorteCir  	:= 0
local nFor			:= 0
local nForBE9    	:= 1
local nForNiv		:= 1
local nNiveis    	:= 0     
local nDesconto 	:= 0
local nAcrescimo	:= 0
local nOrdBR8    	:= BR8->(indexOrd())
local nRecBR8    	:= BR8->(recno())
local nDecCOF		:= iIf( ! lCobCoPart, PLGetDec('BD7_COEFUT'), PLGetDec('BD7_COEFPF'))
local nDecBAS		:= iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'), PLGetDec('BD7_VLRBPF'))
local cSQL			:= ''
local cMsg			:= ''
local cCodCri		:= ''
local cCodProPrin	:= ""
local cCodPadPrin	:= ""
local cAlias     	:= ""
local cCodAux    	:= ""
local cTabPre 		:= ""
local cTabVlr		:= ""
local cEmpNaoCons	:= getNewPar("MV_PLSENCT","")
local cNameBE9   	:= BE9->(retSqlName("BE9"))
local lOK           := .f.
local lFoundBE9  	:= .f.    
local lTabEsp 		:= .f.
local lFoundBB8 	:= .f.
local aRetTC     	:= {}
local aRetTabPre	:= {}
local aVigAtu		:= {}
local aOrdensNiv	:= {}
local __XaRetTabPre	:= {.f.,{}}
local dVigIni	 	:= ctod("")
local dVigFim	 	:= ctod("")

if __cCdTbPd <> cCodPad .or. len(__aNiveis) == 0
	__cCdTbPd := cCodPad
	__aNiveis := PLSESPNIV(cCodPad)
endIf	

nNiveis := (__aNiveis[1]+1)

nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(cCodUnd) })		

if nPos > 0
	nFatMul := iIf( len(aRdas[nPos])>= 10,iIf(aRdas[nPos,10]<>"0",nFatMul,1) ,nFatMul	)
endIf	

if ( len(aValAcu) > 0 )  .and. ( ! cCodEmp $ cEmpNaoCons ) 

   BR8->(dbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN

   for nfor := 1 to len(aValAcu)

       cCodProPrin := aValAcu[nFor,2]
       cCodPadPrin := aValAcu[nFor,1]
       
       if dtos(aValAcu[nFor,4]) + aValAcu[nFor,5] == dtos(dDatpro) + cHorPro
          
          if BR8->(msSeek(xFilial("BR8") + cCodPadPrin + cCodProPrin ) ) .and. BR8->BR8_TMPCIR > nPorteCir
             nPorteCir := BR8->BR8_TMPCIR
          endIf
             
       endIf
          
   next
   
   BR8->(dbSetOrder(nOrdBR8))
   BR8->(dbGoTo(nRecBR8))
   
endIf   

aOrdensNiv := {"BTM","BE9","BC0","BC6","BC5"}

if existBlock("PLSONVPC")
	aOrdensNiv := execBlock("PLSONVPC",.f.,.f.,{aOrdensNiv,lCobCoPart,cCodRda,cOpeOri,"2"})
endIf

for nForNiv := 1 to len(aOrdensNiv)

	if aOrdensNiv[nForNiv] $ "BTM" .and. nCatHos > 0 .and. nPorteCir > 0

		cSQL := "SELECT BTM_COEFIC, BTM_VLRREA FROM " + retSqlName("BTM") + " WHERE "
		cSQL += "BTM_FILIAL = '" + xFilial("BTM") + "' AND "
		cSQL += "BTM_CODINT = '" + cCodInt + "' AND "
		cSQL += "BTM_CODTAB = '" + cCodTab + "' AND "
		cSQL += "BTM_CATHOS = '" + allTrim(str(nCatHos)) + "' AND "
		cSQL += "BTM_SEQPOR = " +  allTrim(str(nPorteCir)) + " AND "
		cSQL += "D_E_L_E_T_ = ' ' "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTRBTC",.f.,.t.)
		
		if PLSTRBTC->(eof())
			lOK := .f.
		else
			
			plsTField("PLSTRBTC",.f.,{ "BTM_VLRREA" } )

			nVlrTCRea := PLSTRBTC->BTM_VLRREA
			
			if nVlrTCRea > 0 
				lOk       := .t.
				cAlias    := "BTM"
				aVigAtu	  := { cAlias, dVigIni, dVigFim }
			endIf

		endIf

		PLSTRBTC->(dbCloseArea())
		
	elseIf aOrdensNiv[nForNiv] $ "BE9"

		if ! lFoundBE9
		
			cSQL := "SELECT R_E_C_N_O_ REC FROM "+cNameBE9+" WHERE "
			cSQL += "BE9_FILIAL = '" + xFilial("BE9") + "' AND "
			cSQL += "BE9_CODIGO = '" + cCodRDA + "' AND "
			cSQL += "BE9_CODINT = '" + cCodInt + "' AND "
			cSQL += "BE9_CODLOC = '" + cCodLoc + "' AND "
			cSQL += "BE9_CODESP = '" + cCodEsp  + "' AND "
			cSQL += "BE9_CODPLA = '" + cCodPla + "' AND "
			cSQL += "BE9_CODPAD = '" + cCodPad + "' AND "
				
			cSQL += PLREQNI("BE9", "BE9_CODPRO", __aNiveis[2], allTrim(cCodPro))
				
			cSQL += "( '" + dtos(dDatAnalise)+"' >= BE9_VIGDE  OR BE9_VIGDE  = ' ' ) AND "
			cSQL += "( '" + dtos(dDatAnalise)+"' <= BE9_VIGATE OR BE9_VIGATE = ' ' ) AND "
				
			cSQL +=  cNameBE9 + ".D_E_L_E_T_ = ' ' "
			
			cSQL +=  " ORDER BY BE9_NIVEL DESC "
				
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
				
			if ! PLSAUTPDIR->(eof())                           
				BE9->(dbGoTo(PLSAUTPDIR->(REC)))
				lFoundBE9 := .t.
			else
				if existBlock("PLSBE9SK")
					execBlock("PLSBE9SK",.f.,.f.,{cCodRda,cCodInt,cCodLoc,cCodEsp,cCodPla,cCodPad,cCodAux,nForBE9})
				endIf  
					
			endIf
			PLSAUTPDIR->(dbCloseArea())

		endIf
				
		if lFoundBE9 .and. BE9->BE9_ATIVO <> "0" 
			nVlrTCRea := iIf(! lCobCoPart, BE9->BE9_VALREA, BE9->BE9_VLRECT )
		endIf
		
		if nVlrTCRea > 0 
			lOK		:= .t.
			cAlias	:= "BE9"
			aVigAtu	:= { cAlias, BE9->BE9_VIGDE, BE9->BE9_VIGATE }
		endIf

	elseIf aOrdensNiv[nForNiv] $ "BC0"

		BC0->(dbSetOrder(2))
		if BC0->(msSeek(xFilial("BC0")+cCodRda+cCodInt+cCodLoc+cCodEsp+cCodPad+cCodPro))

			while !BC0->(eof()) .and. !lOK .and. BC0->(BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODPAD+BC0_CODOPC) == xFilial("BC0")+cCodRda+cCodInt+cCodLoc+cCodEsp+cCodPad+cCodPro 
				
				//Somente seto o flag se a data estiver na vigencia definida		
											
				if (empty(BC0->BC0_VIGDE)  .or. BC0->BC0_VIGDE  <= dDatAnalise) .and. (empty(BC0->BC0_VIGATE) .or. BC0->BC0_VIGATE >= dDatAnalise) 
					
					if empty(BC0->BC0_DATBLO) .or. BC0->BC0_DATBLO > dDatAnalise
						nVlrTCRea := BC0->BC0_VALREA	
					endIf

					if nVlrTCRea > 0
						lOK     := .t.
						cAlias  := "BC0"
						aVigAtu	:= { cAlias, BC0->BC0_VIGDE, BC0->BC0_VIGATEE }
					endIf	
					
				endIf   
				
				if lOk
					exit
				endIf

			BC0->(dbSkip())
			endDo
					
		endIf 

	elseIf aOrdensNiv[nForNiv] $ "BC6"

		aRetTabPre := PLSTABPRE(/*01*/cCodInt, 		/*02*/ cCodRda,   	/*03*/cCodPad,; 
								/*04*/cCodPro, 		/*05*/dDatPro,		/*06*/cPadInt,; 
								/*07*/cCodPla, 		/*07*/cOpeOri, 		/*08*/cCodLoc,;
								/*09*/lCobCoPart,	/*10*/cRegAte, 		/*11*/cFinAte,; 
								/*12*/cCodTab, 		/*13*/lReembolso,	/*14*/cModPag,;
								/*15*/nRef )

		if len(aRetTabPre) > 0 .and. aRetTabPre[1]
			
			nVlrTCRea 	:= aRetTabPre[2,2]
			nDesconto 	:= aRetTabPre[2,5]
			nAcrescimo	:= aRetTabPre[2,6]
			
			if nVlrTCRea > 0
				
				lOK     := .t.
				cAlias  := aRetTabPre[3]
				aVigAtu	:= { cAlias, aRetTabPre[4][2] ,aRetTabPre[4][3] }
				
			endIf
			
		endIf
	
	elseIf aOrdensNiv[nForNiv] $ "BC5"
		
		// Redefine as variaveis de controle
		cTabPre := ""
		lTabEsp := .f.
		
		BB8->(dbSetOrder(1))
		lFoundBB8 := SeekBB8E(cCodRDA,cCodInt,cCodLoc)

		// Verifica se existe tabela de preço no local de atendimento. Esse codigo se refere a tabela de preço X RDA BC5.
		if  lFoundBB8 .and. ! empty(BB8->BB8_TABPRE)
			cTabPre := BB8->BB8_TABPRE
			lTabEsp := .t.
		endIf

		// Verifica se existe tabela de preço especifica para esta RDA.
		BC5->(dbSetOrder(1))
		if BC5->( msSeek(xFilial("BC5") + cCodInt + cCodRda) )

			// Processa as vigencias.
			while ! BC5->(eof()) .and. BC5->(BC5_FILIAL+BC5_CODINT+BC5_CODRDA) == xFilial("BC5") + cCodInt + cCodRda

				// Testa regra de tabela especifica.
				if ( lTabEsp .and. cTabPre == BC5->BC5_TABPRE ) .or. ( ! lTabEsp )
					
					// Faz a analize da vigencia.
					if PLSINTVAL("BC5","BC5_DATINI","BC5_DATFIM",dDatAnalise)

						// Trata amarração com a nova tabela de preço/valorizacao.
						cTabVlr := iIf(!lCobCoPart, BC5->BC5_TABPRE, BC5->BC5_TABREC)
						
						if ! empty(cTabVlr)
						
							__XaRetTabPre := PLVLTBPR(cTabVlr, cCodInt,cCodPad,cCodPro,dDatPro,cRegAte,cFinAte,cCodTab,.f.,nil,'BC5',cCodEsp,cCodUnd, lCobCoPart)
							
							if PLRTPREA(__XaRetTabPre, "BC5", @cAlias, cModPag, lCobCoPart, @lOk, @nVlrTCRea, @nDesconto, @nAcrescimo, @aVigAtu, BC5->BC5_DATINI, BC5->BC5_DATFIM)
									
								exit
								
							endIf

						else
						
							// Us Pagar Pre-Pag - Us Receber Pre-Pag
							nVlrTCRea := iIf( ! lCobCoPart, BC5->BC5_VPPP, BC5->BC5_VRPP ) 	
							
							if allTrim(cModPag) != "1"
								
								// Us Pagar custo - Us Receber custo
								nVlrTCRea := iIf( ! lCobCoPart, BC5->BC5_VPCO, BC5->BC5_VRCO ) 	
																	
							endIf
							
							dVigIni := BC5->BC5_DATINI
							dVigFim := BC5->BC5_DATFIM

						endIf

						if nVlrTCRea > 0
			
							lOk 	:= .t.
							cAlias 	:= "BC5"
							aVigAtu	:= { cAlias, dVigIni, dVigFim }
							
							exit
							
						endIf

					endIf
					
				endIf
				
			BC5->( dbSkip() )
			endDo

		endIf	

	endIf
	
	if lOk
		exit
	endIf

next

if lOk

	nVlrTCAcu := nVlrTCRea
   
   	if cConsFt == "1"
		nVlrTCAcu := ( nVlrTCAcu * nFatMul )
   	endIf   
   
	// Aplica percentual de aumento ou redução
	if allTrim(cCodUnd) $ allTrim(cMVPLSUNPR) .and. nPrPrRl <> 0
		nVlrTCAcu := nVlrTCAcu + ( ( nVlrTCAcu * nPrPrRl ) / 100 )
	endIf

endIf

if ! lOK

   	PLSPOSGLO(PLSINTPAD(),__aCdCri063[1],__aCdCri063[2])

   	cCodCri := __aCdCri063[1]
   	cMsg    := cCodCri+" - "+PLSBCTDESC()

	aadd(aRetTC, { 0, "", 0, 0, 0, 0, "", 0, 0, "0", '0', 0, 0, 0, 0 } )
 
else

   aadd(aRetTC, { 1, cAlias, round(nVlrTCRea, nDecCOF ), round(nVlrTCAcu, nDecBAS ) * nQtd, round(nVlrTCAcu, nDecBAS ) * nQtd, nFatMul, "Tmp Cirurgico", 0, 0, "0", "0", 0, 0, 0, 0} )
   
endIf          

return( { lOK, cMsg, cCodCri, aRetTC, aVigAtu } )

/*/{Protheus.doc} PLSCALDP
Calcula o Doppler 

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRETCDP

local cCodPad  		:= paramixb[9]
local nFatMul  		:= paramixb[20]
local lCobCoPart 	:= paramixb[25]
local cProRel  		:= paramixb[26] 
local nPrPrRl  		:= paramixb[27] 
local aValAcu  		:= paramixb[28]                                     
local aRdas    		:= paramixb[34]                                     
local cCodUnd  		:= paramixb[35]

local nPos      	:= 0
local nValInt  		:= 0         
local nValCalc 		:= 0
local nAux			:= 0
local nFor			:= 0
local nDecCOF		:= iIf( ! lCobCoPart, PLGetDec('BD7_COEFUT'), PLGetDec('BD7_COEFPF'))
local nDecBAS		:= iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'), PLGetDec('BD7_VLRBPF'))
local cAlias   		:= "BD4"
local cMsg    		:= ""
local cCodCri 		:= ""
local cMVPLSUNCD 	:= getNewPar("MV_PLSUNCD","FIL")
local lOk     		:= .t.
local aRetDOP  		:= {}
local aAux			:= {}

nPos := aScan(aRdas,{ |x| allTrim(x[1]) == allTrim(cCodUnd) })	
	
if nPos > 0
	nFatMul := iIf( len(aRdas[nPos]) >= 10, iIf( aRdas[nPos,10] <> "0", nFatMul, 1 ) ,nFatMul	)
endIf

nPos := aScan(aValAcu,{ |x| x[1] + x[2] == cCodPad + cProRel })

//veio o valor acumulado... e achei ele p o procedimento atual...
if nPos > 0 
	
	aAux := aClone(aValAcu[nPos,3][1])

	for nAux := 1 to len(aAux) 
	
		if ! ( allTrim(aAux[nAux,1]) $ cMVPLSUNCD )
	
			for nfor := 1 to len(aAux[nAux,5])
				nValInt += aAux[nAux,5,nFor,4]
			next
				
		endIf
		
	next

endIf

nValCalc := nValInt

// Aplica percentual de aumento ou redução
if nPrPrRl <> 0
	nValCalc := nValCalc + ( ( nValCalc * nPrPrRl ) / 100 )
endIf		

if nValInt > 0
	
	lOk := .t.
	aadd(aRetDOP, { 1, cAlias, round(nValInt, nDecCOF ), round(nValCalc, nDecBAS ), round(nValCalc, nDecBAS ), nFatMul, "%", 0, 0, "0", '0', 0, 0, 0, 0 })

else

	lOk := .f.

	PLSPOSGLO( PLSINTPAD() , __aCdCri239[1] , __aCdCri239[2] )
	cCodCri := __aCdCri239[1]
	cMsg    := cCodCri +" - "+ PLSBCTDESC()
	
	aadd(aRetDOP, { 0, "", 0, 0, 0, 0, "", 0, 0, "0", '0', 0, 0, 0, 0 } )

endIf

return( { lOK, cMsg, cCodCri, aRetDOP } )

/*/{Protheus.doc} PLSTABPRE
Retorna o valor de um evento baseado na tab de preco BC6

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSTABPRE(	/*01*/cCodInt, 		/*02*/ cCodRda,    	/*03*/cCodPad,; 
					/*04*/cCodPro, 		/*05*/dDatAnalise,	/*06*/cPadInt,; 
					/*07*/cCodPla, 		/*08*/cOpeOri, 	  	/*09*/cCodLoc,;
					/*10*/lCobCoPart,	/*11*/cRegAte, 		/*12*/cFinAte,; 
					/*13*/cCodTab, 		/*14*/lReembolso, 	/*15*/cModPag,;
					/*16*/nRef , 		/*17*/lBanda,		/*18*/lOkAD)
						
local nNiveis 		:= 0
local nVlrUS		:= 0
local nVlrRea		:= 0
local nPos	  		:= 0
local nNivel        := 0

local nRecno  		:= 0
local nBanRe  		:= 0
local nBanPa  		:= 0
local nUCO	  		:= 0
local nDesconto		:= 0
local nAcrescimo	:= 0
local lRet			:= .f.
local cSQL    		:= ""
local cAlias		:= ""
local cNivel        := ""
local aDados  		:= {}
local aRetFun 		:= { .f., {} }
Local aRetPE			:= {}
Local aVigAtu			:= {}

default cPadInt    	:= ""
default dDatAnalise	:= dDataBase
default cCodPla 	:= ""
default cOpeOri	   	:= ""
default cCodLoc		:= ""
default cRegAte		:= ""
default cFinAte		:= ""
default cCodTab		:= ""
default cModPag		:= ""
default lReembolso	:= .f.
default lCobCoPart  := .f.
default nRef		:= 0
default lBanda		:= .F.
default lOkAD		:= .F.

if __cCdTbPd <> cCodPad .or. len(__aNiveis) == 0
	__cCdTbPd := cCodPad
	__aNiveis := PLSESPNIV(cCodPad)
endIf	
nNiveis := (__aNiveis[1]+1)

if existBlock("PLSFIATE")
   cFinAte := execBlock("PLSFIATE",.f.,.f.,{cFinAte})
endIf

aDados := {}
	
if ! existBlock('PLSSELBC6')
	cSQL := "SELECT BC6_CODACO,BC6_CODPLA,BC6_CODOPE, BC6_NIVEL, R_E_C_N_O_ REG "
else 
	cSQL := execBlock('PLSSELBC6',.f.,.f.,{cSql})
endIf      

cSQL += "FROM " + retSqlName("BC6") + " WHERE "
cSQL += "BC6_FILIAL = '" + xFilial("BC6") + "' AND "
cSQL += "BC6_CODINT = '" + cCodInt + "' AND "
cSQL += "BC6_CODRDA = '" + cCodRDA + "' AND "
cSQL += "BC6_CODPAD = '" + cCodPad + "' AND "

cSQL += PLREQNI("BC6", "BC6_CODPRO", __aNiveis[2], allTrim(cCodPro))

cSQL += " ( "
cSQL += " ( '"+dtos(dDatAnalise)+"' >= BC6_VIGINI ) AND "
cSQL += " ( ( '"+dtos(dDatAnalise)+"' <= BC6_VIGFIM OR BC6_VIGFIM = ' ' ) OR ( BC6_VIGINI = ' ' AND BC6_VIGFIM = ' ' ) ) "
cSQL += " ) AND " 

if existBlock('PLSQRYBC6')
	cSQL += execBlock('PLSQRYBC6',.f.,.f.)			
endIf 

cSQL += "D_E_L_E_T_ = ' ' "		

cSQL +=  " ORDER BY BC6_NIVEL DESC, BC6_CODACO,BC6_CODPLA ASC "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTABPRE",.f.,.t.)

if ! PLSTABPRE->(eof())

	while ! PLSTABPRE->(eof()) 	
	
		aadd(aDados,{ allTrim(PLSTABPRE->BC6_CODACO), allTrim(PLSTABPRE->BC6_CODPLA), PLSTABPRE->REG, allTrim(PLSTABPRE->BC6_CODOPE), allTrim(PLSTABPRE->BC6_NIVEL) })
	
	PLSTABPRE->(dbskip())
	enddo	

endIf
PLSTABPRE->(dbCloseArea())

if len(aDados) > 0

	nNivel := ( __aNiveis[1] +1 )

	while nNivel > 0
		
		// utilizamos variavel auxiliar cNivel na comparacao do aScan, pois o BC6_NIVEL vem como string no aDados
		cNivel := allTrim( str( nNivel ))

		//Plano (preenchido) e Acomodacao (preenchido) e Cod Operadora (preenchido)|
		nPos := aScan(aDados,{|x| allTrim(x[1]) == allTrim(cPadInt) .and. allTrim(x[2]) == allTrim(cCodPla) .and. allTrim(x[4]) == allTrim(cOpeOri) .and. allTrim(x[5]) == allTrim(cNivel) })

		//Plano (preenchido) e Acomodacao (branco) e Cod Operadora (preenchido)	 
		if nPos == 0
			
			nPos := aScan(aDados,{|x| empty(x[1]) .and. allTrim(x[2]) == allTrim(cCodPla) .and. allTrim(x[4]) == allTrim(cOpeOri) .and. allTrim(x[5]) == allTrim(cNivel) })
			
			//Plano (branco) e Acomodacao (preenchido) e Cod Operadora (preenchido)  
			if nPos == 0
			
				nPos := aScan(aDados,{|x| allTrim(x[1]) == allTrim(cPadInt) .and. empty(x[2]) .and. allTrim(x[4]) == allTrim(cOpeOri) .and. allTrim(x[5]) == allTrim(cNivel) })
			
				//Plano (preenchido) e Acomodacao (preenchido) Cod Operadora (branco)    
				if nPos == 0
					
					nPos := aScan(aDados,{|x| allTrim(x[1]) == allTrim(cPadInt) .and. allTrim(x[2]) == allTrim(cCodPla) .and. empty(x[4]) .and. allTrim(x[5]) == allTrim(cNivel) })
					
					//Plano (preenchido) e Acomodacao (branco) Cod Operadora (branco)        
					if nPos == 0
					
						nPos := aScan(aDados,{|x| empty(x[1]) .and. allTrim(x[2]) == allTrim(cCodPla) .and. empty(x[4]) .and. allTrim(x[5]) == allTrim(cNivel) })
						
						//Plano (branco) e Acomodacao (preenchido) Cod Operadora (branco)        
						if nPos == 0
							
							nPos := aScan(aDados,{|x| allTrim(x[1]) == allTrim(cPadInt) .and. empty(x[2]) .and. empty(x[4]) .and. allTrim(x[5]) == allTrim(cNivel) })

							//Plano (branco) e Acomodacao (branco) Cod Operadora (preenchido)        
							if nPos == 0
								
								nPos := aScan(aDados,{|x| empty(x[2]) .and. empty(x[1]) .and. allTrim(x[4]) == allTrim(cOpeOri) .and. allTrim(x[5]) == allTrim(cNivel) })
								
								//Plano (branco) e Acomodacao (branco) Cod Operadora (branco)            
								if nPos == 0

									nPos := aScan(aDados,{|x| empty(x[1]) .and. empty(x[2]) .and. empty(x[4]) .and. allTrim(x[5]) == allTrim(cNivel) })
									
								endIf
								
							endIf
							
						endIf
						
					endIf
					
				endIf
				
			endIf
			
		endIf

		if nPos > 0
			nRecno := aDados[nPos,3]
			exit
		endIf

		nNivel--
	
	enddo

endIf

if nRecno > 0

	BC6->(dbGoTo(nRecno))

	//Pre-Pagamento
	if allTrim(cModPag) == "1"

		//pagamento 
		if ! lCobCoPart
			
			nVlrUS 	:= BC6->BC6_USPPP
			nVlrRea := BC6->BC6_VRPPP
			nDesconto 	:= BC6->BC6_PERDES
			nAcrescimo 	:= BC6->BC6_PERACR
		else

			nVlrUS 	:= BC6->BC6_USRPP
			nVlrRea := BC6->BC6_VRRPP
			nDesconto 	:= BC6->BC6_PERDES
			nAcrescimo 	:= BC6->BC6_PERACR
		endIf

	else
		
		if ! lCobCoPart

			nVlrUS 	:= BC6->BC6_USPCO
			nVlrRea := BC6->BC6_VRPCO
			nDesconto 	:= BC6->BC6_PERDES
			nAcrescimo 	:= BC6->BC6_PERACR
		else
			
			nVlrUS  := BC6->BC6_USRCO
			nVlrRea := BC6->BC6_VRRCO
			nDesconto 	:= BC6->BC6_PERDES
			nAcrescimo 	:= BC6->BC6_PERACR
		endIf

	endIf
	
	nBanRe  	:= BC6->BC6_BANDAR
	nBanPa  	:= BC6->BC6_BANDAP

	nUCO		:= BC6->BC6_UCO
	
	lOkAD := nDesconto + nAcrescimo > 0

	if (!lBanda .AND. (nVlrUS > 0 .or. nVlrRea > 0 .or. nUCO > 0 .OR. lOkAD) ) .OR. (lBanda .AND. IIF(lCobCoPart, nBanRe > 0, nBanPa > 0))

		lRet 	:= (!lBanda .AND. (nVlrUS > 0 .or. nVlrRea > 0 .or. nUCO > 0) ) .OR. (lBanda .AND. IIF(lCobCoPart, nBanRe > 0, nBanPa > 0))//.t.
		cAlias 	:= "BC6"
		aVigAtu	:= {cAlias, BC6->BC6_VIGINI, BC6->BC6_VIGFIM}
		aRetFun := {lRet, { nVlrUS, nVlrRea, nBanRe, nBanPa, nDesconto, nAcrescimo, nRef, nUCO, 0 }, cAlias, aVigAtu }

	endIf	
	
endIf
                  
// Tratamento personalizado para a tabela de preço.
if existBlock("PLSTBRDA")
	//Inicializa variáveis do ponto de entrada
	nUSPCO := 0
	nVRPCO := 0
	nUSRCO := 0
	nVRRCO := 0
	nUSPPP := 0
	nVRPPP := 0
	nUSRPP := 0
	nVRRPP := 0
	
	//Preenche conforme a situação atual as variáveis devidas
	If allTrim(cModPag) == "1"
		If ! lCobCoPart
			nUSPPP := BC6->BC6_USPPP
			nVRPPP := BC6->BC6_VRPPP
		Else
			nUSRPP := BC6->BC6_USRPP
			nVRRPP := BC6->BC6_VRRPP
		endIf
	else
		If ! lCobCoPart
			nUSPCO := BC6->BC6_USPCO
			nVRPCO := BC6->BC6_VRPCO
		else
			nUSRCO := BC6->BC6_USRCO
			nVRRCO := BC6->BC6_VRRCO
		EndIf
	EndIf
	
	aRetPE := execBlock("PLSTBRDA",.f.,.f.,{cCodInt,cCodRda,BC6->BC6_CODTAB,cCodPad,cCodPro,dDatAnalise,cPadInt,cCodPla,cOpeOri,cCodLoc,nUSPCO,nVRPCO,nUSRCO,nVRRCO,nUSPPP,nVRPPP,nUSRPP,nVRRPP,nBanRe,nBanPa,nDesconto,nAcrescimo,cAlias,lReembolso,nRef,cRegAte})		      
	
	if allTrim(cModPag) == "1"
		
		if ! lCobCoPart
			nVlrUS  := aRetPE[2,5]
			nVlrRea := aRetPE[2,6]
		else
			nUSRPP  := aRetPE[2,7]
			nVlrRea := aRetPE[2,8]
		endIf

	else

		if ! lCobCoPart
			nVlrUS  := aRetPE[2,1]
			nVlrRea := aRetPE[2,2]
		else
			nVlrUS  := aRetPE[2,3]
			nVlrRea := aRetPE[2,4]
		endIf

	endIf
	
	nBanRe		:= aRetPE[2,9]
	nBanPa		:= aRetPE[2,10]
	nDesconto	:= aRetPE[2,11]
	nAcrescimo	:= aRetPE[2,12]
	nRef		:= aRetPE[2,13]
	nUCO		:= aRetPE[2,14]

	lRet		:= aRetPE[1]
	
	If Len(aRetPE) > 2 .AND. !(empTy(aRetPE[3]))
		cAlias		:= aRetPE[3]
	endIf
	
	If Len(aRetPE) > 3 .AND. !(empTy(aRetPE[4]))
		aVigAtu	:= aRetPE[4]
	elseIf empTy(aVigAtu)
		aVigAtu	:= {}
	endIf
	
	//Se o array de vigência for vazio ou menor que 3, iremos retornar o P.E. como inválido, pois indica que não temos data inicial/final de vigência.
	if (empty(aVigAtu) .or. len(aVigAtu) < 3) 
		lRet := .f. 
	endif	
	aRetFun 	:= { lRet, { nVlrUS, nVlrRea, nBanRe, nBanPa, nDesconto, nAcrescimo, nRef, nUCO, 0 }, cAlias, aVigAtu}

endIf

return(aRetFun)     

/*/{Protheus.doc} PLSCALUCO
Calcula Unidade de Custo Operacional UCO 
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSCALUCO(paramixb,lObsoleto)
local nQtd       := paramixb[1]
local nRef       := paramixb[2]
local dDatAnalise:= paramixb[4]                                                      
local cCodRDA    := paramixb[5]
local cCodLoc    := subStr(paramixb[7],1,3)
local cCodInt    := paramixb[6]         
local cCodTab    := paramixb[8] 
local cCodPad    := paramixb[9]
local cCodPro    := paramixb[10]
local cMes       := paramixb[11]
local cAno       := paramixb[12]
local cCodEsp    := paramixb[13]
local cSubEsp    := paramixb[14]
local cModPag    := paramixb[15]
local nVlrApr    := paramixb[17]                                                 
local cTipPre    := paramixb[18]
local cCodEmp    := iIf(len(paramixb[19])>0, subStr(paramixb[19][2],atCodEmp[1],atCodEmp[2]),"")
local cTipoUsr   := iIf(len(paramixb[19])>0, paramixb[19][8], "")
local cConEmp    := iIf(len(paramixb[19])>0, paramixb[19][9], "")
local cCodPla    := iIf(len(paramixb[19])>0, paramixb[19][11], "")
local cVersao    := iIf(len(paramixb[19])>0, paramixb[19][12], "")
local cVerCon    := iIf(len(paramixb[19])>0, paramixb[19][39], "")
local cSubCon    := iIf(len(paramixb[19])>0, paramixb[19][41], "")
local cVerSub    := iIf(len(paramixb[19])>0, paramixb[19][42], "")
local cOpeOri    := iIf(len(paramixb[19])>0, paramixb[19][45], "")
local cREGGOP    := iIf(len(paramixb[19])>0, paramixb[19][63], "")
local cGRUOPE    := iIf(len(paramixb[19])>0, paramixb[19][64], "")
local nUSEspec   := paramixb[22]
local lCobCoPart := paramixb[25]  
local nPrPrRl	 := paramixb[27]    
local cPadInt    := paramixb[29]
local cRegAte  	 := paramixb[30]                                     
local aRdas		 := paramixb[34]  
local cCodUnd    := paramixb[35]                              
local lReembolso := paramixb[36]
local cConsBd    := paramixb[38]                 
local dDatPro	 := paramixb[40]
local cRegPag	 := paramixb[44]
local cRegCob	 := paramixb[45]
local cFinAte    := iIf(len(paramixb)>= 47,paramixb[47],"")

local nBanda     	:= 0
local nUCO       	:= 0
local nFatMul    	:= 1
local nVlr       	:= 0
local nNiveis    	:= 0     
local nValDef	 	:= 0
local nForBE9    	:= 1
local nFor       	:= 0 
local nForNiv	 	:= 0
local nBmb		 	:= 0
local nTab		 	:= 0
local nDecREF	 	:= iIf( ! lCobCoPart, PLGetDec('BD7_REFTDE'), PLGetDec('BD7_RFTDEC'))
local nDecCOF	 	:= iIf( ! lCobCoPart, PLGetDec('BD7_COEFUT'), PLGetDec('BD7_COEFPF'))
local nDecBAS	 	:= iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'), PLGetDec('BD7_VLRBPF'))
local cMsg		 	:= ''
local cCodCri    	:= ''
local cAlias     	:= ""
local cOpeInt    	:= ''                                                       
local cTabVlr	 	:= ""
local cTabPre 	 	:= ""
local cNameBS0	 	:= BS0->(retSqlName("BS0"))
local dVigIni	 	:= ctod("")
local dVigFim	 	:= ctod("")
local lOK        	:= .f.
local lInterc	 	:= .f.
local lFoundBB8	 	:= .f.
local lTabEsp 	 	:= .f.

local lZeroUCO 	 	:= getNewPar("MV_PLZEUCO",.f.)
local lZeraTudo	 	:= (getNewPar("MV_PLSGUI0","0") == "1")	// Rever este conceito.
local aRet		 	:= {}
local aRetInt	 	:= {}
local aOrdensNiv  	:= {}
local aVigAtu		:= {}
local __XaRetTabPre	:= {.f.,{}}
local aTabs			:= {}
local aRetUCO     	:= {}
local aRETUCONV		:= {}

default lObsoleto	:= .f.

cMeMorial += "Unidade: " + cCodUnd + CRLF + "Função de cálculo: PLSRETUCO " + CRLF

if __cCdTbPd <> cCodPad .or. len(__aNiveis) == 0
	__cCdTbPd := cCodPad
	__aNiveis := PLSESPNIV(cCodPad)
endIf	
nNiveis := (__aNiveis[1]+1)

aRetInt := PLINTERC( iIf( ! lCobCoPart, "1", "2"), cCodRda, cOpeOri, cRegPag, cRegCob )
lInterc := aRetInt[1]
cOpeInt := aRetInt[2]  

If lInterc
	cMeMorial += "Atendimento de intercâmbio" + CRLF
endIf

BE9->(dbSetOrder(1))
BBI->(dbSetOrder(1))
BC6->(dbSetOrder(1))
BC5->(dbSetOrder(1))
BAX->(dbSetOrder(1))
BB8->(dbSetOrder(1))  
BAQ->(dbSetOrder(1))
BMF->(dbSetOrder(1))
BMI->(dbSetOrder(1))
BMH->(dbSetOrder(1))
BMM->(dbSetOrder(1))
BML->(dbSetOrder(1))
BMD->(dbSetOrder(1))
BMB->(dbSetOrder(1))

/*                                                               
===> Niveis que permitem parametrização da tabela de valorização.

BS0 - Produto X Und X U.S                        	
BBI - RDA X local Atend X Especialidade X Planos...	
BMB - Operadora X Tipo de Prestador X U.S			

B24 - RDA X Tab Preços Generica						
BC5 - RDA X Tab Precos (Cabecalho)                  

B85 - Associacao X Classe X Tabela de Preco
B12 - Estados X Municipios (Estado)		
B13 - Estados X Municipios (Municipio)	
B30 - RDA X Planos						
*/

aOrdensNiv := { "BC0","BMI","BMH","BE9","BBI","BC6","BC5","BS9","BAX","BB8","BMG","BMF",;
        		"BMM","BML","BBM","BAQ","BME","BMD","BS0","BMC","BMB","B24","B30","B13","B12","B85","B29","BFM" }    
    		  
if existBlock("PLSONVPC")

	aOrdensNiv := execBlock("PLSONVPC",.f.,.f.,{aOrdensNiv,lCobCoPart,cCodRda,cOpeOri,"3"})
	
	if ! lZeraTudo
	
		if ValType(aOrdensNiv) == "A"

			if (nPosNiv := aScan(aOrdensNiv, "BFM")) == 0
				aadd(aOrdensNiv, "BFM")
			endIf

		else
			aOrdensNiv := {"BFM"}
		endIf
			
	endIf
	
endIf

BB8->(dbSetOrder(1))
lFoundBB8 := SeekBB8E(cCodRDA,cCodInt,cCodLoc)

for nForNiv := 1 to len(aOrdensNiv)
	
	if aOrdensNiv[nForNiv] == "BE9"
		
		cSQL := " SELECT R_E_C_N_O_ REC, BE9_UCO, BE9_BANDA, BE9_VIGDE, BE9_VIGATE "
		cSQL += "   FROM " + retSqlName("BE9") + " WHERE "
		cSQL += " BE9_FILIAL = '" + xFilial("BE9") + "' AND "
		cSQL += " BE9_CODIGO = '" + cCodRDA + "' AND "
		cSQL += " BE9_CODINT = '" + cCodInt + "' AND "
		cSQL += " BE9_CODLOC = '" + cCodLoc + "' AND "
		cSQL += " BE9_CODESP = '" + cCodEsp  + "' AND "
		cSQL += " BE9_CODPLA = '" + cCodPla + "' AND "
		cSQL += " BE9_CODPAD = '" + cCodPad + "' AND "
		cSQL += " BE9_UCO > 0 AND "
		
		cSQL += PLREQNI("BE9", "BE9_CODPRO", __aNiveis[2], allTrim(cCodPro))
		
		cSQL += " ( '" + dtos(dDatAnalise) + "' >= BE9_VIGDE  OR BE9_VIGDE  = ' ' ) AND "
		cSQL += " ( '" + dtos(dDatAnalise) + "' <= BE9_VIGATE OR BE9_VIGATE = ' ' ) AND "
		cSQL += " D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BE9_NIVEL DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
		
		if ! PLSAUTPDIR->(eof()) 

	 		plsTField("PLSAUTPDIR",.f.,{ "BE9_UCO","BE9_BANDA", "BE9_VIGATE","BE9_VIGATE" } )

			nUCO 	:= PLSAUTPDIR->BE9_UCO
			nBanda	:= PLSAUTPDIR->BE9_BANDA

			PLSRTPUC( {.t.}, "BE9", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, PLSAUTPDIR->BE9_VIGATE, PLSAUTPDIR->BE9_VIGATE )
				
		endIf
		
		PLSAUTPDIR->(dbCloseArea())
		                             
	elseIf aOrdensNiv[nForNiv] $ "BBI"
	
		//BBI_FILIAL, BBI_CODIGO, BBI_CODINT, BBI_CODLOC, BBI_CODESP, BBI_CODPRO, BBI_VERSAO
		if BBI->(msSeek(xFilial("BBI")+cCodRda+cCodInt+cCodLoc+cCodEsp+cCodPla+cVersao)) 
	
			while !BBI->( eof() ) .and. BBI->(BBI_CODIGO + BBI_CODINT + BBI_CODLOC + BBI_CODESP + BBI_CODPRO + BBI_VERSAO) == cCodRda+cCodInt+cCodLoc+cCodEsp+cCodPla+cVersao
                                          
				// Verifica se a parametrização esta ativa e se esta vigente.
				if BBI->BBI_ATIVO <> "0" .and. PLSINTVAL("BBI","BBI_VIGDE","BBI_VIGATE",dDatAnalise)
						
					// Trata amarração com a nova tabela de preço/valorizacao.
					cTabVlr := iIf(!lCobCoPart, BBI->BBI_TABPRE, BBI->BBI_TABREC)
								
					if ! empty(cTabVlr)
						
						__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BBI',cCodEsp,cCodUnd, lCobCoPart)
						
						if PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BBI->BBI_VIGDE, BBI->BBI_VIGATE)
								
							exit
								
						endIf
						
					else				

						// Executa regra do modo antigo.
						nUCO 	:= BBI->BBI_UCO
						nBanda 	:= BBI->BBI_BANDA
						dVigIni := BBI->BBI_VIGDE
						dVigFim := BBI->BBI_VIGATE							

						if PLSRTPUC( {.t.}, "BBI", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, dVigIni, dVigFim )
							
							exit
									
						endIf				
						
					endIf
					
				endIf
				
			BBI->( dbSkip() )
			endDo
			
	  	endIf
	  	
	elseIf aOrdensNiv[nForNiv] $ "B30"
		
		if B30->(msSeek(xFilial("B30")+cCodRda+cCodInt+cCodPla+cVersao)) 
		
			while !B30->( eof() ) .and. B30->B30_CODIGO+B30->B30_CODINT+B30->B30_CODPRO+B30->B30_VERSAO == cCodRda+cCodInt+cCodPla+cVersao
                                          
				// Verifica se a parametrização esta ativa e se esta vigente.
				if B30->B30_ATIVO <> "0" .and. PLSINTVAL("B30","B30_VIGDE","B30_VIGATE",dDatAnalise)
						
					// Trata amarração com a nova tabela de preço/valorizacao.
					cTabVlr := iIf(!lCobCoPart, B30->B30_TABPRE, B30->B30_TABREC)
								
					if !empty(cTabVlr)
					
						__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B30',cCodEsp,cCodUnd, lCobCoPart)
						
						if PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, B30->B30_VIGDE, B30->B30_VIGATE)
								
							exit
								
						endIf
						
					else			
						
						// Executa regra do modo antigo.
						nUCO 	:= B30->B30_UCO
						nBanda	:= B30->B30_BANDA
						dVigIni := B30->B30_VIGDE
						dVigFim := B30->B30_VIGATE							
						
						if PLSRTPUC( {.t.}, "B30", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, dVigIni, dVigFim )
							
							exit
									
						endIf				
					
					endIf
					
				endIf

			B30->( dbSkip() )
			endDo
			
	  	endIf
	  	
	elseIf aOrdensNiv[nForNiv] $ "BC0"
	
		cSQL := "SELECT BC0_UCO,BC0_PERACR, BC0_VALREA, BC0_BANDA, BC0_PERDES,BC0_NIVEL,BC0_FORMUL,BC0_VALCH,BC0_EXPRES, BC0_VIGDE, BC0_VIGATE "
		cSQL += "FROM "+retSqlName("BC0")
		cSQL += " WHERE "
		cSQL += "BC0_FILIAL = '"+xFilial("BC0")+"' AND "
		cSQL += "BC0_CODIGO = '"+cCodRDA+"' AND "
		cSQL += "BC0_CODINT = '"+cCodInt+"' AND "
		cSQL += "BC0_CODLOC = '"+cCodLoc+"' AND "
		cSQL += "BC0_CODESP = '"+cCodEsp+"' AND "
		
		cSubEsp := iIf(! empty(cSubEsp), cSubEsp, " ")
		
		cSQL += "BC0_CODSUB = '" + cSubEsp + "' AND "
		
		cSQL += PLREQNI("BC0", "BC0_CODOPC", __aNiveis[2], allTrim(cCodPro))
		
		cSQL += "( '"+dtos(dDatAnalise)+"' >= BC0_VIGDE  OR BC0_VIGDE  = ' ' ) AND "
		cSQL += "( '"+dtos(dDatAnalise)+"' <= BC0_VIGATE OR BC0_VIGATE = ' ' ) AND "
   		cSQL += "( BC0_DATBLO = ' '  OR BC0_DATBLO > '"+dtos(dDatAnalise)+"' ) AND "
		
		cSQL +=  " D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BC0_NIVEL DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
	  	
		if ! PLSAUTPDIR->(eof()) 

			plsTField("PLSAUTPDIR",.f.,{ "BC0_UCO", "BC0_BANDA", "BC0_VIGDE","BC0_VIGATE" } )
			
			nUCO 	:= PLSAUTPDIR->BC0_UCO
			nBanda	:= PLSAUTPDIR->BC0_BANDA
			
			PLSRTPUC( {.t.}, "BC0", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, PLSAUTPDIR->BC0_VIGDE, PLSAUTPDIR->BC0_VIGATE )
			
		endIf
		
		PLSAUTPDIR->(dbCloseArea())
	
	elseIf aOrdensNiv[nForNiv] $ "BC6"
		
		aRetTabPre := PLSTABPRE(cCodInt,cCodRda,cCodPad,cCodPro,dDatAnalise,cPadInt,cCodPla,cOpeOri,cCodLoc,lCobCoPart,cRegAte,cFinAte,cCodTab,lReembolso,cModPag, nRef)
		
		If Len(aRetTabPre) > 0 .AND. aRetTabPre[1]		
			
			lOk := .T.
			cAlias := aRetTabPre[3]
			nUCO := aRetTabPre[2][8]
			nBanda := IIF(lCobCoPart, aRetTabPre[2][3], aRetTabPre[2][4])
			nRef := aRetTabPre[2][7]
			aVigAtu := aclone(aRetTabPre[4])
			
			PLSRTPUC( {.t.}, "BC6", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, aVigAtu[2], aVigAtu[3] )
		endIf

	elseIf aOrdensNiv[nForNiv] $ "BC5"
	
		// Redefine as variaveis de controle
		cTabPre := ""
		lTabEsp := .f.
		
		// Verifica se existe tabela de preço no local de atendimento. Esse codigo se refere a tabela de preço X RDA BC5.
		if  lFoundBB8 .and. ! empty(BB8->BB8_TABPRE)
			cTabPre := BB8->BB8_TABPRE
			lTabEsp := .t.
		endIf
		
		// Verifica se existe tabela de preço especifica para esta RDA.
		BC5->(dbSetOrder(1))
		if BC5->( msSeek(xFilial("BC5") + cCodInt + cCodRda) )
			
			// Processa as vigencias.
			while ! BC5->(eof()) .and. BC5->(BC5_FILIAL+BC5_CODINT+BC5_CODRDA) == xFilial("BC5")+cCodInt+cCodRda
				
				// Testa regra de tabela especifica.
				if ( lTabEsp .and. cTabPre == BC5->BC5_TABPRE ) .or. ( ! lTabEsp )
					
					// Faz a analize da vigencia.
					if PLSINTVAL("BC5","BC5_DATINI","BC5_DATFIM",dDatAnalise)
						
						// Trata amarração com a nova tabela de preço/valorizacao.
						cTabVlr := iIf(!lCobCoPart, BC5->BC5_TABPRE, BC5->BC5_TABREC)
						
						if !empty(cTabVlr)
						
							__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BC5',cCodEsp,cCodUnd, lCobCoPart)
							
							if PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BC5->BC5_DATINI, BC5->BC5_DATFIM)
								
								exit
								
							endIf
							
						else
						
							nUCO	:= BC5->BC5_UCO
							nBanda	:= iIf( ! lCobCoPart, BC5->BC5_BANDAP, BC5->BC5_BANDAR)

							if PLSRTPUC( {.t.}, "BC5", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BC5->BC5_DATINI, BC5->BC5_DATFIM )
								
								exit	
									
							endIf			
							
						endIf
						
					endIf
					
				endIf
				
			BC5->( dbSkip() )
			endDo
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BAX"
	
		//BAX_FILIAL, BAX_CODIGO, BAX_CODINT, BAX_CODLOC, BAX_CODESP, BAX_CODSUB
		cSubEsp := iIf(!empty(cSubEsp), cSubEsp, "")
	
		if BAX->(msSeek(xFilial("BAX") + cCodRda + cCodInt + cCodLoc + cCodEsp + cSubEsp))

			nUCO 	:= BAX->BAX_UCO
			nBanda 	:= BAX->BAX_BANDA
			
			PLSRTPUC( {.t.}, "BAX", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BAX->BAX_VIGDE, dVigFim )

		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BB8"
		
		if BB8->(msSeek(xFilial("BB8")+cCodRda+cCodInt+cCodLoc))
			
			nUCO 	:= BB8->BB8_UCO
			nBanda 	:= BB8->BB8_BANDA
			
			PLSRTPUC( {.t.}, "BB8", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, dVigIni, dVigFim )
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BBM"
	
		cSQL := "SELECT BBM_NIVEL,BBM_VALCH,BBM_VALREA,BBM_PERDES,BBM_PERACR, BBM_UCO, BBM_BANDA, BBM_DATVAL "
		cSQL += " FROM " + retSqlName("BBM")
		cSQL += " WHERE BBM_FILIAL = '" + xFilial("BBM") + "' AND "
		cSQL += "       BBM_CODINT = '" + cCodInt + "' AND "
		cSQL += "       BBM_CODESP = '" + cCodEsp  + "' AND "
		cSQL += "       BBM_CODPAD = '" + cCodPad + "' AND "
		
		cSQL += PLREQNI("BBM", "BBM_CODPSA", __aNiveis[2], allTrim(cCodPro))
		
        cSQL += " BBM_ATIVO = '1' AND "
        cSQL += " (BBM_DATVAL = ' ' OR '" + dtos(dDataBase) + "' <= BBM_DATVAL) AND "
		
		cSQL += " D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BBM_NIVEL DESC "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
		
		if ! PLSAUTPDIR->(eof()) 
		
			plsTField("PLSAUTPDIR",.f.,{ "BBM_UCO","BBM_BANDA", "BBM_DATVAL" } )
			 
			nUCO 	:= PLSAUTPDIR->BBM_UCO
			nBanda 	:= PLSAUTPDIR->BBM_BANDA
			
			PLSRTPUC( {.t.}, "BBM", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, dVigIni, PLSAUTPDIR->BBM_DATVAL)
							
		endIf
			
		PLSAUTPDIR->(dbCloseArea())
		
	elseIf aOrdensNiv[nForNiv] $ "BAQ"
	
		//BAQ_FILIAL, BAQ_CODINT, BAQ_CODESP
		if BAQ->(msSeek(xFilial("BAQ")+cCodInt+cCodEsp))
			
			nUCO 	:= BAQ->BAQ_UCO
			nBanda 	:= BAQ->BAQ_BANDA
			
			PLSRTPUC( {.t.}, "BAQ", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, dVigIni, dVigFim)

		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BMF"
	
		if BMF->(msSeek(xFilial("BMF")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cTipPre))
			
			nUCO 	:= BMF->BMF_UCO
			nBanda	:= BMF->BMF_BANDA

			PLSRTPUC( {.t.}, "BMF", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, dVigIni, dVigFim )
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BMI"
	
		if BMI->(msSeek(xFilial("BMI")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRda+cCodPad+cCodPro))
			
			nUCO 	:= BMI->BMI_UCO
			nBanda 	:= BMI->BMI_BANDA
			
			PLSRTPUC( {.t.}, "BMI", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BMI->BMI_DATDE, dVigFim )
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BMH"
	
		if BMH->(msSeek(xFilial("BMH")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRda))

			nUCO 	:= BMH->BMH_UCO
			nBanda	:= BMH->BMH_BANDA
			
			PLSRTPUC( {.t.}, "BMH", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BMH->BMH_DATDE, dVigFim )
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BMM"

		if BMM->(msSeek(xFilial("BMM")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodEsp+cCodPad+cCodPro))

			nUCO 	:= BMM->BMM_UCO
			nBanda 	:= BMM->BMM_BANDA
			
			PLSRTPUC( {.t.}, "BMM", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BMM->BMM_DATDE, dVigFim)

		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BML"
	
		if BML->(msSeek(xFilial("BML")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodEsp))

			nUCO 	:= BML->BML_UCO
			nBanda	:= BML->BML_BANDA
			
			PLSRTPUC( {.t.}, "BML", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BML->BML_DATDE, dVigFim)
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BME"
	
		cSQL := "SELECT BME_NIVEL,BME_VALUS, BME_VALUSA, BME_DATDE, BME_VLRPAG, BME_UCO,BME_VIGDE, BME_VIGATE, BME_VLRPGA, BME_BANDA "
		cSQL += " FROM "+retSqlName("BME")
		cSQL += " WHERE "
		
		cSQL += "BME_FILIAL = '"+xFilial("BME")+"' AND "
		cSQL += "BME_CODIGO = '"+cCodInt+cCodPla+"' AND "
		cSQL += "BME_VERSAO = '"+cVersao+"' AND "
		cSQL += "BME_TIPPRE = '"+cTipPre+"' AND "
		cSQL += "BME_CODPAD = '" + allTrim(cCodPad) + "' AND "
		
		cSQL += PLREQNI("BME", "BME_CODPSA", __aNiveis[2], allTrim(cCodPro))
		
		cSQL += "( '"+dtos(dDatAnalise)+"' >= BME_VIGDE  OR BME_VIGDE = ' ' ) AND "
		cSQL += "( '"+dtos(dDatAnalise)+"' <= BME_VIGATE OR BME_VIGATE = ' ' ) AND "
		cSQL += " D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BME_NIVEL DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)

		if ! PLSAUTPDIR->(eof()) 

			plsTField("PLSAUTPDIR",.f.,{ "BME_UCO","BME_BANDA","BME_VIGDE","BME_VIGATE" } )					
			
			nUCO 	:= PLSAUTPDIR->BME_UCO
			nBanda 	:= PLSAUTPDIR->BME_BANDA
			
			PLSRTPUC( {.t.}, "BME", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, PLSAUTPDIR->BME_VIGDE, PLSAUTPDIR->BME_VIGATE)
			
		endIf
		
		PLSAUTPDIR->(dbCloseArea())
		
	elseIf aOrdensNiv[nForNiv] $ "BMD"
	
		if BMD->( msSeek(xFilial("BMD")+cCodInt+cCodPla+cVersao+cTipPre) )

			nUCO 	:= BMD->BMD_UCO
			nBanda 	:= BMD->BMD_BANDA
						
			PLSRTPUC( {.t.}, "BMD", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BMD->BMD_DATDE, dVigFim )
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BMC" 
		
		cSQL := "SELECT BMC_NIVEL,BMC_VALUS, BMC_VALUSA, BMC_DATDE, BMC_VLRPAG, BMC_UCO, BMC_TABPRE, "
		cSQL += "       BMC_VIGDE, BMC_VIGATE, BMC_VLUSRE, BMC_VLRPGA, BMC_BANDA "
		cSQL += " FROM " + retSqlName("BMC")
		cSQL += " WHERE "
		cSQL += "BMC_FILIAL = '" + xFilial("BMC") + "' AND "
		cSQL += "BMC_CODINT = '" + cCodInt + "' AND "
		cSQL += "BMC_TIPPRE = '" + cTipPre + "' AND "
		cSQL += "BMC_CODPAD = '" + allTrim(cCodPad) + "' AND "
		
		cSQL += PLREQNI("BMC", "BMC_CODPSA", __aNiveis[2], allTrim(cCodPro))
		
		cSQL += "( '" + dtos(dDatAnalise) + "' >= BMC_VIGDE  OR BMC_VIGDE = ' ' ) AND "
		cSQL += "( '" + dtos(dDatAnalise) + "' <= BMC_VIGATE OR BMC_VIGATE = ' ' ) AND "
		
		cSQL += " D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BMC_NIVEL DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSAUTPDIR",.f.,.t.)

		if ! PLSAUTPDIR->(eof()) 

			plsTField("PLSAUTPDIR",.f.,{ "BMC_UCO", "BMC_BANDA", "BMC_VIGDE","BMC_VIGATE" } )					

			//Se a vigencia estiver dentro do limite parametrizado...			   
			if PLSINTVAL("PLSAUTPDIR","BMC_VIGDE","BMC_VIGATE",dDatAnalise)

				//Se o campo APOS DATA não tiver preenchido vou pegar os valores 	  
				//padroes, ao contrario verifico a data do campo com a data base da   
				//analise                                                              
				// Tratamento da nova amarração com a tabela de preço/valorização.
				if ! empty(PLSAUTPDIR->BMC_TABPRE)
				
					__XaRetTabPre := PLVLTBPR(PLSAUTPDIR->BMC_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BMC',cCodEsp,cCodUnd, lCobCoPart)
		 
					PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, PLSAUTPDIR->BMC_VIGDE, PLSAUTPDIR->BMC_VIGATE)
		            
		    	else
		    		
		    		nUCO 	:= PLSAUTPDIR->BMC_UCO
		    		nBanda 	:= PLSAUTPDIR->BMC_BANDA
					
					PLSRTPUC( {.t.}, "BMC", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, PLSAUTPDIR->BMC_VIGDE, PLSAUTPDIR->BMC_VIGATE)
					
		   		endIf
		   		
        	endIf
        	
			
		endIf
		
		PLSAUTPDIR->(dbCloseArea())
		
	elseIf aOrdensNiv[nForNiv] $ "BMG" .and. cTipoUsr == "2"
	
		cSQL := "SELECT BMG_UCO,BMG_VLRPGA, BMG_NIVEL, BMG_BANDA, BMG_VALUS, BMG_VALUSA, BMG_DATDE, BMG_VLRPAG "
		cSQL += " FROM "+retSqlName("BMG")
		cSQL += " WHERE "
		cSQL += "BMG_FILIAL = '"+xFilial("BMG")+"' AND "
		cSQL += "BMG_CODINT = '"+cCodInt+"' AND "
		cSQL += "BMG_CODEMP = '"+cCodEmp+"' AND "
		cSQL += "BMG_NUMCON = '"+cConEmp+"' AND "
		cSQL += "BMG_VERCON = '"+cVerCon+"' AND "
		cSQL += "BMG_SUBCON = '"+cSubCon+"' AND "
		cSQL += "BMG_VERSUB = '"+cVerSub+"' AND "
		cSQL += "BMG_TIPPRE = '"+cTipPre+"' AND "
		cSQL += "BMG_CODPAD = '"+cCodPad+"' AND "
		
		cSQL += PLREQNI("BMG", "BMG_CODPSA", __aNiveis[2], allTrim(cCodPro))
		
		cSQL += " D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BMG_NIVEL DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)

		if ! PLSAUTPDIR->(eof()) 

			plsTField("PLSAUTPDIR",.f.,{ "BMG_UCO","BMG_BANDA", "BMG_DATDE" } )
			
			nUCO 	:= PLSAUTPDIR->BMG_UCO
			nBanda 	:= PLSAUTPDIR->BMG_BANDA
			
			PLSRTPUC( {.t.}, "BMG", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu,PLSAUTPDIR->BMG_DATDE, ctod(""))
			
		endIf
		
		PLSAUTPDIR->(dbCloseArea())
		
	elseIf aOrdensNiv[nForNiv] $ "BS9" .and. cTipoUsr == "2" .and. ! lReembolso

		cSql := "SELECT BS9_VIGDE,BS9_VIGATE,BS9_TABPRE FROM " + retSqlName("BS9") + " WHERE BS9_FILIAL = '"+xFilial("BS9")+"' "
		cSql += "AND BS9_SUBCON = '" + cCodInt + cCodEmp + cConEmp + cVerCon + cSubCon + cVerSub + "' "
		cSql += "AND BS9_CODUNI = '" + cCodUnd + "' "
		cSql += "AND D_E_L_E_T_ = ' ' "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TRBBS9",.f.,.t.)
		
		if !TRBBS9->(eof())
			plsTField("TRBBS9",.f.,{ "BS9_VIGDE","BS9_VIGATE" } )
		endIf
		
		while ! TRBBS9->( eof() )

			//Se a vigencia estiver dentro do limite parametrizado...			 
			if PLSINTVAL("TRBBS9","BS9_VIGDE","BS9_VIGATE",dDatAnalise)	
						
				if ! empty(TRBBS9->BS9_TABPRE)
				
					__XaRetTabPre := PLVLTBPR(TRBBS9->BS9_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BS9',cCodEsp,cCodUnd, lCobCoPart)
					
					if PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, TRBBS9->BS9_VIGDE, TRBBS9->BS9_VIGATE)
						
						exit
						
					endIf
					
				endIf
				
			endIf
			
		TRBBS9->( dbSkip() )
		endDo
		
		TRBBS9->( dbCloseArea() )

	elseIf aOrdensNiv[nForNiv] $ "BMB" .and. ! lCobCoPart
		
		for nBmb := 1 to 2  

			// Primeiro tenta achar parametrização para o tipo de prestador corrente.
			// Se não achar, tenta achar parametrização generica.
			if nBmb == 1
				cAuxTipPre := cTipPre
			else
				cAuxTipPre := space(TamSX3("BMB_TIPPRE")[1])
			endIf
				
			if BMB->(msSeek(xFilial("BMB") + cCodInt + cAuxTipPre))
			
				while !BMB->( eof() ) .and. BMB->( BMB_CODINT + BMB_TIPPRE ) == cCodInt + cAuxTipPre
					
					// Faz a analize da vigencia.					
					if PLSINTVAL("BMB","BMB_VIGDE","BMB_VIGATE",dDatAnalise)

						if ! empty(BMB->BMB_TABPRE)
						
							__XaRetTabPre := PLVLTBPR(BMB->BMB_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BMB',cCodEsp,cCodUnd, lCobCoPart)
							
							PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BMB->BMB_VIGDE, BMB->BMB_VIGATE)
							
						else		
								
							nUCO 	:= BMB->BMB_UCO
							nBanda 	:= BMB->BMB_BANDA
							
							PLSRTPUC( {.t.}, "BMB", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BMB->BMB_VIGDE, BMB->BMB_VIGATE )

						endIf
						
					endIf
    				
    				if lOk
    					exit
    				endIf
    					
				BMB->( dbSkip() )    				
				endDo
				
			endIf
			
	    	if lOk
    			exit
    		endIf
			
		next
				
	elseIf aOrdensNiv[nForNiv] $ "B29" .and. ! lCobCoPart
	
		// Obtem as tabelas de preço disponiveis para este prestador na tabela B29 - Somente as que estiveram com vigencia em aberto.
		B29->(dbSetOrder(1))
		if B29->(msSeek(xFilial("B29")+cCodRDA+cCodInt))
		
			while !B29->( eof() ) .and. B29->B29_CODIGO+B29->B29_CODINT == cCodRDA+cCodInt
			
				// Faz a analize da vigencia.
				if PLSINTVAL("B29","B29_VIGINI","B29_VIGFIN",dDatAnalise)
				
					// Trata amarração com a nova tabela de preço/valorização.
					if ! empty(B29->B29_TABPRE)
					
						__XaRetTabPre := PLVLTBPR(B29->B29_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B29',cCodEsp,cCodUnd, lCobCoPart)
						
						if PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, B29->B29_VIGINI, B29->B29_VIGFIN)
							
							exit
							
						endIf	
						
					endIf
					
				endIf
				
			B29->( dbSkip() )
			endDo
			
		endIf
						
	elseIf aOrdensNiv[nForNiv] $ "B24" .and. ! lCobCoPart
		
		// Obtem as tabelas de preço disponiveis para este prestador na tabela B24 - Somente as que estiveram com vigencia em aberto.
		aTabs := aClone(SeekB24(cCodRDA,cCodInt,cCodLoc,dDatAnalise))
		
		// Processa todas as tabelas de preço do prestador.
		for nTab := 1 to len(aTabs)

			// Trata amarração com a nova tabela de preço/valorização.
			if !empty(aTabs[nTab])

				__XaRetTabPre := PLVLTBPR(aTabs[nTab],cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B24',cCodEsp,cCodUnd, lCobCoPart)
	
				if PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, B24->B24_VIGINI, B24->B24_VIGFIN)
							
					exit
							
				endIf	
				
			endIf
			
		next
        
	elseIf aOrdensNiv[nForNiv] $ "B85" .and. ! lCobCoPart
	
		//Verifico no nivel de local de RDA x Associacao.
		B62->(dbSetOrder(1))
		if B62->(msSeek(xFilial("B62") + cCodRDA + cCodInt))
			
			while !B62->( eof() ) .and. B62->B62_CODIGO+B62->B62_CODINT == cCodRDA + cCodInt
				
				// Faz a analize da vigencia.
				if PLSINTVAL("B62","B62_DTVGIN","B62_DTVGF",dDatAnalise)
					
					B85->( dbSetOrder(01) )
					
					if B85->( msSeek(xFilial("B85")+B62->B62_ASSCLA) )
						
						while !B85->( eof() ) .and. B85->(B85_CODASS+B85_CLASSE) == B62->B62_ASSCLA
							
							// Faz a analize da vigencia.
							if PLSINTVAL("B85","B85_VIGINI","B85_VIGFIN",dDatAnalise)
								 
								 if ! empty(B85->B85_TABPRE)
								
									__XaRetTabPre := PLVLTBPR(B85->B85_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B85',cCodEsp,cCodUnd, lCobCoPart)

									if PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, B85->B85_VIGINI, B85->B85_VIGFIN)
							
										exit
							
									endIf	

								endIf	
								
							endIf
							
						B85->( dbSkip() )
						endDo
						
					endIf
					
				endIf
				
				if lOk
					exit
				endIf
				
			B62->( dbSkip() )
			endDo
			
		endIf
		    
	elseIf aOrdensNiv[nForNiv] $ "BS0" .and. ! lCobCoPart
		
		//Tratamento da diferenciacao da UCO p/ produto X procedimento X unidade|
		cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBS0 + " WHERE "
		cSQL += "BS0_FILIAL = '" + xFilial("BS0") + "' AND "
		cSQL += "BS0_CODPRO = '" + cCodInt+cCodPla + "' AND "
		cSQL += "BS0_CODPAD = '" + cCodPad + "' AND "
		cSQL += "BS0_CODUNI = '" + cCodUnd + "' AND "
		
		cSQL += PLREQNI("BS0", "BS0_CODPSA", __aNiveis[2], allTrim(cCodPro))

		cSQL += "( '"+dtos(dDatAnalise)+"' >= BS0_VIGDE  OR BS0_VIGDE = ' ' ) AND "
		cSQL += "( '"+dtos(dDatAnalise)+"' <= BS0_VIGATE OR BS0_VIGATE = ' ' ) AND "
		
		cSQL +=  cNameBS0 + ".D_E_L_E_T_ = ' ' "
		
		cSQL +=  " ORDER BY BS0_NIVEL DESC "
		
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSAUTPDIR",.f.,.t.)
		
		lFlag := .f.
		
		if ! PLSAUTPDIR->(eof())
			
			lFlag := .t.
			BS0->(dbGoTo(PLSAUTPDIR->(REC)))
				
		endIf	
		
		PLSAUTPDIR->(dbCloseArea())
				
		if lFlag
			
			// Trata amarração com a nova tabela de preço/valorizacao.
			cTabVlr := iIf(!lCobCoPart, BS0->BS0_TABPRE, BS0->BS0_TABREC)
			
			if ! empty(cTabVlr)
			
				__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BS0',cCodEsp,cCodUnd, lCobCoPart)
			
				PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BS0->BS0_VIGDE, BS0->BS0_VIGATE)

    		endIf									

		endIf
		
		//Tratamento da diferenciacao da us por produto X unidade			     
		lFlag := .f.
		
		if getNewPar("MV_PLBS0UM","1") == "1" 
		
			cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBS0 + " WHERE "
			cSQL += "BS0_FILIAL = '" + xFilial("BS0") + "' AND "
			cSQL += "BS0_CODPRO = '" + cCodInt+cCodPla + "' AND "
			cSQL += "BS0_CODUNI = '" + cCodUnd + "' AND "
			
			cSQL += "( '"+dtos(dDatAnalise)+"' >= BS0_VIGDE  OR BS0_VIGDE = ' ' ) AND "
			cSQL += "( '"+dtos(dDatAnalise)+"' <= BS0_VIGATE OR BS0_VIGATE = ' ' ) AND "
			
			cSQL +=  cNameBS0 + ".D_E_L_E_T_ = ' ' "
			
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
			
			lFlag := .f.
			
			if ! PLSAUTPDIR->(eof())
				
				lFlag := .t.
				BS0->(dbGoTo(PLSAUTPDIR->(REC)))
					
			endIf	
			
			PLSAUTPDIR->(dbCloseArea())
			
			if lFlag
				
				// Trata amarração com a nova tabela de preço/valorizacao.
				cTabVlr := iIf(!lCobCoPart, BS0->BS0_TABPRE, BS0->BS0_TABREC)

				if ! empty(cTabVlr)
				
					__XaRetTabPre := PLVLTBPR(cTabVlr,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'BS0',cCodEsp,cCodUnd, lCobCoPart)
				
					PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, BS0->BS0_VIGDE, BS0->BS0_VIGATE)
					
	    		endIf
	    											
			endIf
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "B12" .and. ! lCobCoPart .and. lFoundBB8

		B12->(dbSetOrder(1)) //B12_FILIAL, B12_CODINT, B12_CODEST
		
		if B12->(msSeek(xFilial("B12")+cCodInt+BB8->BB8_EST))
			
			while !B12->( eof() ) .and. B12->(B12_FILIAL+B12_CODINT+B12_CODEST) == xFilial("B12")+cCodInt+BB8->BB8_EST
				
				if PLSINTVAL("B12","B12_VIGDE","B12_VIGATE",dDatAnalise)
				
					// Trata amarração com a nova tabela de preço.
					if !empty(B12->B12_TABPRE)
						
						__XaRetTabPre := PLVLTBPR(B12->B12_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B12',cCodEsp,cCodUnd, lCobCoPart)
						
						if PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, B12->B12_VIGDE, B12->B12_VIGATE)
						
							exit
						
						endIf	

					endIf
					
				endIf
				
			B12->( dbSkip() )
			endDo
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "B13" .and. ! lCobCoPart .and. lFoundBB8

		B13->(dbSetOrder(1)) //B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN+B13_CODTAB+B13_SEQUEN
		
		if B13->(msSeek(xFilial("B13")+cCodInt+BB8->(BB8_EST+BB8_CODMUN)) )
		
			while !B13->( eof() ) .and. B13->(B13_FILIAL+B13_CODINT+B13_CODEST+B13_CODMUN) == xFilial("B13")+cCodInt+BB8->(BB8_EST+BB8_CODMUN)
													
				if PLSINTVAL("B13","B13_VIGDE","B13_VIGATE",dDatAnalise)	
					
					// Trata amarração com a nova tabela de preço.
					if ! empty(B13->B13_TABPRE)
				
						__XaRetTabPre := PLVLTBPR(B13->B13_TABPRE,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nil,'B13',cCodEsp,cCodUnd, lCobCoPart)
				
						if PLSRTPUC(__XaRetTabPre, aOrdensNiv[nForNiv], @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, B13->B13_VIGDE, B13->B13_VIGATE)
						
							exit
						
						endIf	
						
					endIf
					
				endIf	 
				
			B13->( dbSkip() )
			endDo
			
		endIf
		
	elseIf aOrdensNiv[nForNiv] $ "BFM" .and. ! lInterc
	
		BFM->(dbSetOrder(1)) //BFM_FILIAL+BFM_CODINT+BFM_ANO+BFM_MES
		if BFM->(msSeek(xFilial("BFM") + cCodInt + cAno + cMes))

		   	nUCO	:= BFM->BFM_UCO
		   	nBanda 	:= BFM->BFM_BANDA
					
			PLSRTPUC( {.t.}, "BFM", @cAlias, @lOk, @nUCO, @nBanda, @nRef, @aVigAtu, stod(cAno + cMes + "01"), lastDate( stod(cAno + cMes+"01") ) )
		
		endIf
		
   	endIf
    
	if lOk
		cMeMorial += "- Alias: " + calias + CRLF
		cMeMorial += "- Valor UCO: " + AllTrim(str(nUCO)) + CRLF
		cMeMorial += "- Referência: " + AllTrim(Str(nRef)) + CRLF
		exit
	endIf
	
next nForNiv

if lOK 
	
	nValDef := nUCO

	if ! lZeroUCO

		nVlr := (nValDef * nRef)

		// Aplica percentual de aumento ou redução
		if allTrim(cCodUnd) $ allTrim(cMVPLSUNPR) .and. nPrPrRl <> 0
			nVlr := nVlr + ( ( nVlr * nPrPrRl ) / 100 )
		endIf

		// Banda
		if cConsBd == "1" .and. lOK

			if nBanda == 0

				nBanda := PLSRTBANDA(cCodInt,cAno,cMes,lCobCoPart,lInterc,cOpeInt,dDatAnalise,nNiveis,__aNiveis,cCodPro,;
									cModPag,cCodPad,cCodEsp,cCodUnd,cCodPla,nVlrApr,iIf(cRegGop == "1",cGruOpe,""),;
									nUseSpec,paramixb,cFinAte)
			endIf

			if nBanda > 0
				cMeMorial += "- Banda: " + AllTrim(Str(nBanda)) + "%" + CRLF
				nVlr := (nVlr * nBanda) / 100
			endIf	

		endIf   

		if nVlr == 0
			lOk := .f.
		endIf

	endIf

endIf

if lOK
	cMeMorial += "Valor da Unidade: " + AllTrim(Str(nVlr)) + CRLF
   	aadd(aRetUCO,{ round(nRef, nDecREF ), cAlias, round(nValDef, nDecCOF ), round(nVlr, nDecBAS ) * nQtd, round(nVlr, nDecBAS ) * nQtd, nFatMul, "UCO", 0, nBanda, cConsBd, '0', nRef, 0, 0, 0})
   
endIf

aRETUCONV := { lOK, cMsg, cCodCri, aRetUCO, round(nVlr, nDecBAS ) * nQtd, aVigAtu }
	
return( aClone(aRETUCONV) )

/*/{Protheus.doc} PLSRTBANDA
Retorna a banda de calculo para a CBHPM 
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRTBANDA(cCodOpe, cAno, cMes, lCobCoPart, lInterc, cOpeInt, dDatAnalise, nNiveis, aNiveis, cCodPro, cModPag,;
					cCodPad, cCodEsp, cCodUnd, cCodPla, nVlrApr, cGRUOPE, nUSEspec, aParam, cFinAte)
local nBanda   	:= 0
local aArea		:= getArea()
local cTipo    	:= iIf( ! lCobCoPart, "1", "2")
local cAlias	:= ""
local aRetFun	:= {}           
local aBanda   	:= {}
Local lUnimed	:= GetNewPar("MV_PLSUNI", "0") == "1"

default aParam 	:= {}
default cFinAte	:= ""

If lUnimed .AND. (lInterc .or. (!empty(cGRUOPE) .AND. cTipo == '2'))   
   //pegado somente a banda
   aRetFun := PLSGRUOPE(cTipo, cOpeInt, dDatAnalise, nNiveis, aNiveis, cCodPro, cModPag, cCodPad, cCodEsp, cCodUnd,;
   						cCodPla, nVlrApr, cGRUOPE, nUSEspec, lInterc, cFinAte, nil, /*cRdaEdi*/, .T., /*lRetFil*/, /*lBusTx*/, IIF(Len(aParam) >= 30, aParam[30], nil))

   if len(aRetFun) >= 12
      nBanda := aRetFun[12]
      cAlias := aRetFun[06]
   endIf 
 
elseif len(aParam) > 0

	aBanda := PLSRETUSNV(aParam, nil, .f., nil, .t.)
	 
	if aBanda[1] .and. len(aBanda[4]) > 0 .and. aBanda[4][1][9] > 0  
		nBanda := aBanda[4][1][9] 
	    cAlias := aBanda[4][1][2]
	endIf
endIf

if nBanda == 0 .and. BFM->(msSeek(xFilial("BFM") + cCodOpe + cAno + cMes)) .and. BFM->BFM_BANDA > 0 .and. cTipo <> "2"
   nBanda	:= BFM->BFM_BANDA
   cAlias	:= "BFM"
endIf   

restArea(aArea)

if lPLSRTBND

   nBanda := execBlock("PLSRTBND",.f.,.f.,{nBanda,cAlias,cCodOpe,cAno,cMes,lCobCoPart,lInterc,cOpeInt,dDatAnalise,nNiveis,aNiveis,cCodPro,cModPag,cCodPad,cCodEsp,;
                                           cCodUnd,cCodPla,nVlrApr,cGRUOPE,nUSEspec})

endIf

return(nBanda)
    
/*/{Protheus.doc} PLSCALINS
Retorna o total do instrumentador
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSCALINS(paramixb)
local aRet      := paramixb[3] 
local cCodInt   := paramixb[6]         
local cMes      := paramixb[11]
local cAno      := paramixb[12]
local nFatMul   := paramixb[20]
local lCobCoPart:= paramixb[25]  

local nDecREF	:= iIf( ! lCobCoPart, PLGetDec('BD7_REFTDE'), PLGetDec('BD7_RFTDEC'))
local nDecBAS 	:= iIf( ! lCobCoPart, PLGetDec('BD7_VLRBPR'), PLGetDec('BD7_VLRBPF'))
local nVlr      := 0
local nValorHM	:= 0
local nInd		:= 1
local nFor		:= 1
local cMsg		:= ''
local cCodCri   := ''	
local cAlias   	:= ""
local lOK      	:= .f.
local aRetUS    := {}
local aPerIns	:= {}

aPerIns := PLRTINS(cCodInt,cAno,cMes)

for nInd := 1 to len(aRet)

	if allTrim(aRet[nInd,1]) $ allTrim( PLSCHMP() )
	
 		for nFor := 1 to len(aRet[nInd,5])
   			nValorHM += aRet[nInd,5,nFor,4]
 		next 
 		   
 		exit
 		
	endIf
	
next 

if aPerIns[1] > 0 .and. nValorHM > 0

   lOK    := .t.    
   nVlr   := round( ( aPerIns[1] / 100 ) * nValorHM, nDecBAS)
   cAlias := aPerIns[2]
   
endIf   

if lOK
	
   aadd(aRetUS, { round( ( aPerIns[1] / 100 ), nDecREF), cAlias, nValorHM, nVlr, nVlr, nFatMul, "INS", 0, 0, '0', '0', 0, 0, 0, 0 } )

endIf

return( { lOK, cMsg, cCodCri, aRetUS, nVlr } )

/*/{Protheus.doc} PLSBD3ORDEM
Funcao para tratar o campo "BD3_ORDEM" de acordo com o tipo  ±±
definido no dicionario de dados. Esta funcao foi criada para ±±
que fosse possivel manter o funcionamento do sistema nos ±±
clientes que possuem o sistema em producao, pois o tipo deste±±
campo foi alterado de "numerico" para "caracter".        ±±
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSBD3ORDEM(cCampo, nTam, cOper, __ContCpo)
local __Ret

default cCampo    := BD3->BD3_ORDEM
default nTam      := TamSX3("BD3_ORDEM")[1]
default cOper     := "1"
default __ContCpo := 0
               
if cOper == "1"

	if ValType(cCampo) == "N"
		__Ret := strZero(cCampo, nTam, 0)
	elseIf ValType(cCampo) == "C"
		__Ret := cCampo
	endIf
	
else

	if ValType(cCampo) == "N"   
	 
		if ValType(__ContCpo) == "N"
			__Ret := __ContCpo
		else
			__Ret := val(__ContCpo)
		endIf
		
	elseIf ValType(cCampo) == "C"
	
		if ValType(__ContCpo) == "N"
			__Ret := strZero(__ContCpo, nTam, 0)
		else
			__Ret := __ContCpo
		endIf
		
	endIf
	
endIf

return __Ret

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSDISTAUX   ºAutor  ³Microsiga        º Data ³  06/09/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento para os casos em que há dois ou mais procedimentos º±±
±±º          ³cirurgicos na mesma Guia Devemos pegar o procedimento de maiorº±±
±±º          ³valor e verificar a quantidade de AUX  e aplicar aos outros   º±±   
±±º          ³procedimentos	que tenham menos AUX, para atender as regras da º±±
±±º          ³ CBHPM item 5.2.(CAPESSESP)								    º±±   
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                   	    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ //Aplica regra para guias que vieram de XML
Function PLSDISTAUX(cChvBD6,aCompTmp,aDadUsr,aAuxCBHPM)
Local aAreaBD6 		:= BD6->(GetArea())
Local aAreaBD7 		:= BD7->(GetArea())
Local aPrcsCir 		:= {.F.,{}} //Procedimentos cirurgicos encontrados
Local nCompTmp 		:= 0 //Indice para percorrer o array da composicao
Local nRecBD6  		:= 0 //Primeiro registro do BD6 encontrado
Local nPosEve  		:= 0 //Posicao do evento
Local nPosBD7   	:= 0
Local cUniAux		:= GetNewPar("MV_PLSCAUX","AUX")
Local nPosCBHPM		:= 0
Local nNumGuiZ		:= 0
Local nSequenZ		:= 0
Local aMaiorPorte	:= {} //O procedimento de maior porte pode estar esparramado em guias pelo PEG... cada uma com uma composição..
Local nI			:= 1
Local aColsPEG		:= {}
Local lUsouRegra	:= .F.

Private aTrbBD7 	:= {}
Private aCols   	:= {}
Private aHeader 	:= {}
Default aCompTmp 	:= {} //Composicao do procedimento
Default aDadUsr		:= {}
Default aAuxCBHPM	:= {}


dbSelectArea("BR8")
BR8->(dbSetOrder(1))
dbSelectArea("BD6")
BD6->(dbSetOrder(1))
BD6->(msSeek(cChvBD6))
nRecBD6 := BD6->(Recno())

If Len(aAuxCBHPM) > 0 .and. Len(aAuxCBHPM[1]) > 0

	nPosCBHPM := aScan(aAuxCBHPM, {|x| x[1] == BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO) .AND. x[2] == BD6->BD6_DATPRO})
	
	If nPosCBHPM > 0
	
		For nI := 1 To Len(aAuxCBHPM)
			If aAuxCBHPM[nI][1] == aAuxCBHPM[nPosCBHPM][1] .AND. aAuxCBHPM[nI][2] == aAuxCBHPM[nPosCBHPM][2] .AND. aAuxCBHPM[nI][5] == aAuxCBHPM[nPosCBHPM][5]
				Aadd(aMaiorPorte, nI)
			EndIf
		Next
		aPrcsCir := aClone(aAuxCBHPM[nPosCBHPM][3])
		aCompTmp := aClone(aAuxCBHPM[nPosCBHPM][4])
	
	EndIf
EndIf

//BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
BP1->(DbSetOrder(1))
If Len(aPrcsCir[2]) > 0
	
	aPrcsCir[1] := .T. //Indicao de que a guia possui eventos cirurgico com AUX
 	aSort(aPrcsCir[2],,,{|x,y| AllTrim(Str(Len(x[6])))+AllTrim(x[5]) < AllTrim(Str(Len(y[6])))+AllTrim(y[5])})//Ordeno os eventos pelo porte e qtde de auxiliares
	nPosEve := Len(aPrcsCir[2]) //Posicao do evento com maior porte e qtde de auxiliares
	If EmpTy(aCompTmp)
		aCompTmp := PLSCOMEVE(aPrcsCir[2,nPosEve,6,1,4],aPrcsCir[2,nPosEve,1],aPrcsCir[2,nPosEve,2],aPrcsCir[2,nPosEve,3],aPrcsCir[2,nPosEve,4])//Carrego a composicao do evento
	EndIf	
	
	If !(Empty(aMaiorPorte))

		BD7->(dbSetOrder(2))//BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_CODUNM+BD7_NLANC
		Store Header "BD7" TO aHeader For .T.

		For nI := 1 To Len(aMaiorPorte)
		
			//BD6->(dbGoTo(aPrcsCir[2,nPosEve,7]))  // posiciono no evento que tem o maior numero de auxiliares
			BD6->(DbGoTo(aAuxCBHPM[aMaiorPorte[nI]][3][2,1,7]))
			BD7->( msSeek( BD6->( BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+aPrcsCir[2,nPosEve,1]+aPrcsCir[2,nPosEve,2]+cUniAux)))//Posiciona no evento de maior porte e qtde de auxiliares
			cChvBD7 := BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_SEQUEN+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO)
			
			Store COLS "BD7" TO aCols FROM aHeader VETTRAB aTrbBD7 While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_SEQUEN+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) == cChvBD7 ;
			for BD7->BD7_CODUNM == cUniAux
			If Len(aCols) > 0
				AAdd(aColsPEG, aCols)
			EndIf
	
		Next
	
	EndIf	
	//Tratamento para que o pagamento dos auxiliares seja somente o que esta vindo no arquivo xml, caso a composição não tenha AUX abaixo o sistema ira pegar a composição UNL
	// e transformar em AUX de acordo com BD7_CODTPA que foi preenchido na importação do XNL (CEMIG).
	for nI := 1 To Len(aColsPEG)
		aCols	  := aClone(aColsPEG[nI])
		aColsBkp := aClone(aCols)
		nCodPro  := aScan(aHeader,{|x| x[2] == "BD7_CODPRO"})
		nNlanc   := aScan(aHeader,{|x| x[2] == "BD7_NLANC "})
		nSequen  := aScan(aHeader,{|x| x[2] == "BD7_SEQUEN"})
		nAnoPag  := aScan(aHeader,{|x| x[2] == "BD7_ANOPAG"})
		nMesPag  := aScan(aHeader,{|x| x[2] == "BD7_MESPAG"})
		nNumGuiZ := aScan(aHeader,{|x| x[2] == "BD7_NUMERO"})
		nSequenZ := aScan(aHeader,{|x| x[2] == "BD7_SEQUEN"})
		nCoefUti := aScan(aHeader,{|x| x[2] == "BD7_COEFUT"})
		nVlrMan  := aScan(aHeader,{|x| x[2] == "BD7_VLRMAN"})   
		nVlrPag  := aScan(aHeader,{|x| x[2] == "BD7_VLRPAG"})   
		nVlrBpr  := aScan(aHeader,{|x| x[2] == "BD7_VLRBPR"})   
		nAliasUs := aScan(aHeader,{|x| x[2] == "BD7_ALIAUS"})   
		nCodTpa  := aScan(aHeader,{|x| x[2] == "BD7_CODTPA"})   
		nVlrApr  := aScan(aHeader,{|x| x[2] == "BD7_VLRAPR"})   
		nCodUnm  := aScan(aHeader,{|x| x[2] == "BD7_CODUNM"})
		
		BD6->(dbSeek(cChvBD6))//vou para o primeiro procedimento da guia
		While !BD6->(Eof()) .And. cChvBD6 == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
			
			If BR8->(MsSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO))) .And. BR8->BR8_TIPEVE == "2" //Evento cirurgico
				
				aCols := aClone(aColsBkp)
				
				For nCompTmp := 1 TO Len(aCompTmp)//Vou percorrer a composicao do procedimento de maior porte
					
					If aCompTmp[nCompTmp,1] != cUniAux//Se nao for auxiliar ja descarto
						Loop
					EndIf
					
					cSqlBD7 := "SELECT R_E_C_N_O_ FROM " + RetSqlName("BD7") + " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
					cSqlBD7 += "BD7_CODOPE = '" + BD6->BD6_CODOPE + "' AND BD7_CODLDP = '" + BD6->BD6_CODLDP + "' AND "
					cSqlBD7 += "BD7_CODPEG = '" + BD6->BD6_CODPEG + "' AND  BD7_NUMERO = '" + BD6->BD6_NUMERO + "' AND "
					cSqlBD7 += "BD7_ORIMOV = '" + BD6->BD6_ORIMOV + "' AND BD7_CODPAD = '" + BD6->BD6_CODPAD + "' AND "
					cSqlBD7 += "BD7_CODPRO = '" + BD6->BD6_CODPRO + "' AND "
					cSqlBD7 += "( BD7_CODUNM = 'UNL' AND BD7_NLANC =  '" + StrZero(aCompTmp[nCompTmp,3],2) + "' ) AND  "
					cSqlBD7 += "D_E_L_E_T_ = ' '"
					
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBD7),"TRBBD7",.F.,.T.)
					nPosBD7 := aScan(aCols,{|x| x[nNlanc] == StrZero(aCompTmp[nCompTmp,3],2)})//Encontro posicao do auxiliar no acols
					
					While !TRBBD7->(Eof()) //.And. nPosBD7 > 0//Se nao encontrou BD7 para esse auxiliar, vou gravar BD7
						BD7->(DbGoTo(TRBBD7->(R_E_C_N_O_)))
							
						BD7->(RecLock("BD7", .F.))
						BD7->BD7_CODUNM := aCompTmp[nCompTmp,1]
						BD7->BD7_NLANC  := StrZero(aCompTmp[nCompTmp,3],2)
						BD7->(MsUnLock())
							
						TRBBD7->(dbSkip())
						lUsouRegra := .T.
					Enddo
					
					TRBBD7->(dbCloseArea())
					
				Next nCompTmp
	
			Else
				aCols := {}
			EndIf
			BD6->(dbSkip())		
		EndDo
	Next
EndIf

RestArea(aAreaBD6)
RestArea(aAreaBD7)

Return({aCompTmp, Iif(nPosEve > 0,aPrcsCir[2,nPosEve,1],""), Iif(nPosEve > 0,aPrcsCir[2,nPosEve,2],""), lUsouRegra})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLEQUAAUX ºAutor  ³Totvs           	 º Data ³  15/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao equaliza a composicao do evento a ser valoriza º±±
±±º          ³ do com o evento de referencia                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLEQUAAUX(aCompRef,cCodPadRef,cCodProRef,aComEve,cCodPad,cCodPro)
Local nEveRef := 0 //Indice do evento referencia

For nEveRef := 1 To Len(aCompRef)

	If aCompRef[nEveRef,1] != "AUX" //So me interessa os auxiliares
		Loop
	EndIf
	If aScan(aComEve,{|x| x[1] == aCompRef[nEveRef,1] .And. x[3] == aCompRef[nEveRef,3]}) == 0
		aAdd(aComEve,aCompRef[nEveRef])
	EndIf

Next nEveRef

Return
