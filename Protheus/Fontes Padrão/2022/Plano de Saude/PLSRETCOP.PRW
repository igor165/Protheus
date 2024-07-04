 #INCLUDE "PLSMGER.CH"
 #INCLUDE "PROTHEUS.CH"
 #INCLUDE "TOPCONN.CH"                                     

STATIC __aNiveis  	:= {}
STATIC __cCdTbPd	:= ""
STATIC lPlsCalMaj 	:= findfunction("PlsCalMaj")
STATIC lPlReChvEst	:= findfunction("PlReChvEst")
STATIC lPLSA500ACT	:= findfunction("PLSA500ACT")
STATIC lPL001MOV	:= findfunction("PL001MOV") 
STATIC lPLSRTCP1  	:= existBlock("PLSRTCP1")
STATIC lPLSMBLF 	:= existBlock("PLSMBLF")
STATIC lPLSRETC2 	:= existBlock("PLSRETC2")
STATIC cconcateZ	:= IIF( AllTrim( TCGetDB() ) $ "ORACLE/DB2/POSTGRES" , '||', '+')
Static lExQDDT	:= Existblock("PLSQD6DT")
Static lExtQDCT	:= existBlock("PLSQD6CT")
Static lExtQDCP	:= existBlock("PLSQD6CP")
Static lcmpTNUMM := BA0->(FieldPos("BA0_REFICM")) > 0 .AND. BA0->(FieldPos("BA0_REFLCM")) > 0
Static lB86Blocop := B86->(fieldPos("B86_BLOCOP")) > 0
Static aOperaRS := {.F.,{}}

/*/{Protheus.doc} PLSCALCCOP
Calcula o valor da Participacao do Usuario
cPadInt - Apto ou enfermaria, conforme tabela de cadastro e atributo do produto
cPadCon - Padrao de conforto, conforme tabela de cadastro e atributo do produto
cRegAte - 1 = Internacao   2 = Ambulatorial                    
Retorno da Funcao                                          
1  => .t. ou .f. se foi calculado corretamente             
2  => Mensagem caso houver erro                                      
3  => Codigo da tabela especifica encontrada               
4  => Tipo de retorno:                                     
      1 = Tabela de Honorario especifica da co-participacao
      2 = Tabela de Honorario que foi passada como parametro         
5  => Percentual de co-participacao                  
6  => Valor quando for tabela especifica             
7  => Valor da taxa administrativa                   
8  => Parametro de retorno obsoleto                  
9  => Valor do participacao por evento               
10 => US usada para calculo do evento                
11 => Valor Base da Participacao Financeira          
12 => Valor da participacao financeira do usuario    

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSCALCCOP(cCodPad,cCodPro,cMes,cAno,cCodRDA,cEspec,cSubEsp,cCodLoc,nQtd,dDatPro,lVerPgAto,cObsoleto,; 
					nVlrEve,cGrpInt,aDadUsr,cPadInt,cPadCon,aQtdPer,cRegAte,nVlrApr,lVlrNoAto,lCompra,cHorPro,; 
					aRdas,cOpeRda,cTipPrefor,cProRel,nPrPrRl,aValAcu,cNivAut,cChvAut,dDatCir,cHorCir,cCid,aUnidsBlo,; 
					cTipoGuia,aCobAcu,nVlrAprPag,aVlBloq,cModCob,nVlrPagBru,nRegBD6,lCirurgico,nPerVia,cRegPag,; 
					cRegCob,nNOTUSED1,nNOTUSED2,aPacote,cChaveGui,cSequen,aRetCom,cRegInt,cFinAte,aVetPag,cChaveLib,; 
					lAuditoria,cDente,cFaces,lMudarFase,cHorPro6C,lAneste,nVlrPagLiq, cTipAdm,cChvEvento,cHrFim) 
local cCodEmp    	:= subStr(aDadUsr[2],atCodEmp[1],atCodEmp[2])          
local cCodInt    	:= subStr(aDadUsr[2],atCodOpe[1],atCodOpe[2])          
local cMatric    	:= subStr(aDadUsr[2],atMatric[1],atMatric[2])          
local cTipReg    	:= subStr(aDadUsr[2],atTipReg[1],atTipReg[2])          
local cCodPla    	:= aDadUsr[11]
local cVerPla    	:= aDadUsr[12]
local cConEmp    	:= aDadUsr[9]
local cVerCon    	:= aDadUsr[39]
local cSubCon    	:= aDadUsr[41]          
local cVerSub    	:= aDadUsr[42]  
local cOpeOri    	:= aDadUsr[45]
local cModPag    	:= aDadUsr[48]
local lInterc    	:= .f.
local nInd,nI,nY 	:= 1
local aRetCalc   	:= {}
local nPerCop    	:= 0
local nValCop    	:= 0
local nTaxa      	:= 0  
local nValUs     	:= 0
local nVlrTAD    	:= 0
local nVlrTBES    	:= 0
local nVlrTPF    	:= 0
local nVlrPag		:= 0
local cAlias     	:= ""
local cCodTabCop 	:= ""
local cAliasTbCp 	:= ""
local cMsg       	:= "Verifique as parametrizaçoes de cobrança" 
local cTipoTab   	:= ""
local nVlrBPF    	:= 0
local nVlrPF     	:= 0
local cPgNoAto      := ""
local cPgDrRDA      := ""
local cTipPre    	:= ""
local cMunAte    	:= ""                                          
local nRegBAU    	:= BAU->(recno())
local nOrdBAU    	:= BAU->(indexOrd())
local nRegBB8    	:= BB8->(recno())
local nOrdBB8    	:= BB8->(indexOrd())
local bRest      	:= { || BAU->(dbsetOrder(nOrdBAU)), BAU->(dbGoto(nRegBAU)), BB8->(dbsetOrder(nOrdBB8)), BB8->(dbGoto(nRegBB8)) }
local nfor          := 0                    
local cPLSREGANVE  	:= getNewPar("MV_PLSRADP","1")
local dDatAnalise   := ctod('')    
local nLimFra      	:= 0
local nSlvBase     	:= 0
local nSlvPerc     	:= 0
local nSlvTx       	:= 0
local nSlvtotal    	:= 0
local nPerda       	:= 0
local cFranquia    	:= "0"
local nSubItens     := 0
local nPercenSub    := 0
local lPagDif	   	:= .f.
local aRetPto       := {}
local aParPtoEnt    := {}
local nPerHorEsp  	:= 0
local cPreHEsp    	:= getNewPar("MV_PLSPHES","MED,ANE")
local aCalcAberto   := {}
local nforBanda1	:= 0
local nforBanda2  	:= 0
local nBandaRec		:= 0
local lFlagBd		:= .f.
local aRetInt		:= {}
local aRetCobLiq   	:= {}
local lAprPto      	:= .f.
local cTipPreBD7    := ""
local cConsFt      	:= "0"
local nFatMul      	:= 1
local lModCTX      	:= getNewPar("MV_PLSMCTA","1") == "1"
local nVlrMaPF	   	:= 0
local nDif		   	:= 0
local nSlvApr 	   	:= 0
local ntotAux	   	:= 0
local nPercen		:= 0	
local lExistia     	:= .f.
local lforcZer 		:= .f.
local lCopPag      	:= len(aDadUsr) >= 72 .and. aDadUsr[72] == "1" // indica que deve calcular a co-participacao com base no valor pago ao prestador
local nPosTimbre   	:= 0
local nVlrTimbre   	:= 0
local nPerMaj	   	:= 0
local nPosNI		:= 0
local nPosNY		:= 0
local nTTVlrPag		:= 0
local aSvRdas	   	:= {}
local aRetDad		:= {}
local lReembolso	:= .f. 
local lMntVApr      := .f.
local nZZ			:= 0
local laRDASdif		:= .f.
local nDecBAS	 	:= PLGetDec('BD7_VLRBPF')
Local cTabCop 		:= ""
Local cChvBT6		:= ""
Local aAreaBD6		:= BD6->(getArea())

default nVlrEve    	:= 0
default cRegAte    	:= "" 
default nVlrApr    	:= 0
default aQtdPer    	:= {}
default cPadInt    	:= ""
default cPadCon    	:= ""
default cCodPad    	:= ""
default cCodRDA    	:= ""
default cEspec     	:= ""
default cSubEsp    	:= ""
default cCodLoc    	:= ""
default lVerPgAto  	:= .f.
default cGrpInt    	:= ""
default lVlrNoAto  	:= .f.
default lCompra    	:= .f.
default cHorPro    	:= ""
default aRdas      	:= {}
default cOpeRda    	:= PLSINTPAD()
default cTipPrefor 	:= ""                                                                        
default cProRel    	:= ""
default nPrPrRl    	:= 0             
default aValAcu    	:= {}
default cNivAut    	:= ""
default cChvAut    	:= ""
default dDatCir    	:= dDatPro
default cHorCir    	:= cHorPro
default cCid       	:= ""
default aUnidsBlo  	:= {}
default cTipoGuia  	:= ""
default aCobAcu    	:= {}
default nVlrAprPag 	:= 0
default aVlBloq    	:= {}
default cModCob    	:= BA3->BA3_MODPAG
default nVlrPagLiq 	:= 0
default nVlrPagBru	:= 0
default nRegBD6    	:= 0
default lCirurgico 	:= .f.
default nPerVia    	:= 100
default cRegPag	 	:= ""
default cRegCob    	:= ""
default nQtd		:= 0
default nNOTUSED1   := 0
default nNOTUSED2   := 0
default aPacote	   	:= {0,0,{},""}
default cChaveGui  	:= ""
default cSequen    	:= ""
default aRetCom	   	:= {}
default cRegInt	   	:= ""
default cFinAte	   	:= ""
default aVetPag	   	:= {}
default cChaveLib  	:= {} 
default lAuditoria 	:= .f.
default cDente      := ""
default cFaces      := ""
default lMudarFase 	:= .t. // Criado para definir ser é uma mudança de fase(.t.) ou uma valorizaçõa (.f.)
default cHorPro6C  	:= cHorPro //Utilizada no PE PLSRETCP - Solicitacao Vale dos Sinos
default lAneste    	:= .f.
default cTipAdm		:= getNewPar("MV_PLSTPAA","9")
default cChvEvento  := ""
default cHrFim		:= ""

lReembolso	:= (cTipoGuia == '04')

if len(cCodPro) < len(BR8->BR8_CODPSA)
	cCodPro := padr(cCodPro,len(BR8->BR8_CODPSA))
endIf

if existBlock("PLSDATAN")
   	cPLSREGANVE := execBlock("PLSDATAN",.f.,.f.,{cTipoGuia,cPLSREGANVE})
endIf

//data do evento
if cPLSREGANVE == "1" 
   dDatAnalise := dDatPro
//data da mudanca de fase/valorizacao   
else 
   dDatAnalise := dDataBase                                                             
endIf             

//Busca o tipo de prestador e o municipio do local de atendimento...   
BAU->(dbsetOrder(1))
if BAU->(MsSeek(xFilial("BAU")+cCodRda))

   cTipPre := BAU->BAU_TIPPRE
   
   if cTipPre == getNewPar("MV_PLSTPIN","OPE") .and. ! empty(cTipPrefor)
      cTipPre := cTipPrefor
   endIf   
   
   //Busca o municipio do local de atendimento...                         
   BB8->(dbsetOrder(1))
   if BB8->(MsSeek(xFilial("BB8")+cCodRda+cCodInt+cCodLoc))
      cMunAte := BB8->BB8_CODMUN
   endIf
   
endIf
 
//alimento com espaco pois ela faz parte de chave de indices logo abaixo
if empty(cMunAte)
	cMunAte := space(tamsx3('BB8_CODMUN')[1])
endIf

aRetInt := PLINTERC("2",cCodRda,cOpeOri,cRegPag,cRegCob)
lInterc := aRetInt[1]

//Ponto de entrada para retornar o valor base da co-participacao / alterar o nivel de autorizacao
if existBlock("PLSCBVPG")

	aRetDad 	:= { cNivAut, xFilial(cNivAut), aDadUsr[37] + aDadUsr[11] + aDadUsr[12], cCodPad, cCodPro, aDadUsr[2], cChaveGui + cSequen, dDatPro, cCodInt , PLSGETRDA(), nQtd }

	aRetCobLiq 	:= execBlock("PLSCBVPG", .f., .f., { nVlrPagBru, nVlrApr, cCodPad, cCodPro, cTipPre, nQtd, aRetDad } )
	
	if aRetCobLiq[1]
	
		nVlrApr := aRetCobLiq[2]
		
		if len(aRetCobLiq) > 2
			cNivAut := aRetCobLiq[3]
			cChvAut := aRetCobLiq[4]
		endIf	
		
		lAprPto := .t.
		
		if nVlrApr > 0 
			nSlvApr	 := nVlrApr
			lMntVApr := .t.
		endIf
		
	endIf
	
endIf

//Tabela de Co-participacao
aVetTab    := PLSTABCOP(cCodPad,cCodPro,cCodInt,cCodRDA,cEspec,cSubEsp,cCodLoc,;
                        cObsoleto,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,cCodPla,;
                        cOpeOri,cVerPla,cGrpInt,cTipPre,cMunAte,lVerPgAto,lCompra,;
                        cMatric,cTipReg,dDatAnalise,cModPag,lInterc,cNivAut,cChvAut,;
                        "",cMes,cAno,dDatPro,cHorPro,cRegAte,cCid,nVlrApr,nQtd,aValAcu,;
                        aCobAcu,nRegBD6,aDadUsr,cFinAte,nil,lAuditoria,lMudarFase)

cCodTabCop := aVetTab[1]

//Tabela de honorario
if ! empty(cCodTabCop)
   cTipoTab   := "1" //Tabela de Honorarios Espefica de uma co-participacao
   cAliasTbCp := aVetTab[6]
else 
   cTipoTab   := "2" //Tabela de Honorarios do prestador...
   cAliasTbCp := ""
endIf   

nPerCop  := aVetTab[2]
nValCop  := aVetTab[3]
nTaxa    := aVetTab[4]
nValUs   := aVetTab[5]                                                      
cAlias   := aVetTab[6]
lExistia := aVetTab[7]
cPgNoAto := aVetTab[8]                                                  

//mesmo que esteja parametrizado para cobrar com base no pagamento,
//se o valor da co-participação esta em real ele será o valor da co-part
if lAprPto .and. nValCop > 0 .and. nPerCop == 0
	nVlrApr := nSlvApr 
	lAprPto := .f.
	lCopPag := .f.
endIf

if len(aVetTab) >= 9
   cPgDrRDA := aVetTab[9]
else
   cPgDrRDA := "0"
endIf                   

if len(aVetTab) >= 10

	//multiplica a franquia pela quantidade de eventos
	if 	getNewPar("MV_PLSMFQT","1") == "1"
	
   		nLimFra := aVetTab[10] * nQtd
   		
   	else
   	
   		nLimFra := aVetTab[10]
   		
   	endIf	
   
   if len(aVetTab) >= 11
   
   		lPagDif := aVetTab[11]
   		
   		if len(aVetTab) >= 12
	   		nVlrMaPF := aVetTab[12]
   		endIf
   		
   endIf
   
else
   nLimFra := 0
endIf
         
//valor apresentado para cobrar...
if ! lExistia .and. nVlrApr > 0 .and. ! lAprPto

   nPerCop    := if(cModCob <> "1",100,0)
   nValCop    := nVlrApr
   nTaxa      := 0
   nValUs     := 0
   cAlias     := "VAP"
   lExistia   := .t.
   cPgNoAto   := "0"
   cPgDrRDA   := "0"
   nLimFra    := 0
   
endIf

//Ponto de entrada para manipular dados de co-participacao...          
if existBlock("PLSRETCP")

   	aParPtoEnt := {nPerCop,nValCop,nTaxa,nValUs,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,cCodInt,cCodEmp,;
                  cMatric,cTipReg,cCodPla,cVerPla,cOpeOri,dDatPro,nQtd,cCodPad,cCodPro,cCodLoc,cCodRda,;
                  lCompra,cRegAte,cCodTabCop,lVerPgAto,nVlrEve,cTipPre,cNivAut,cChvAut,aRdas,aRetCom,cEspec,cDente,cFaces,cHorPro6C}

   	aRetPto    := execBlock("PLSRETCP",.f.,.f.,aParPtoEnt)

   	nPerCop    := aRetPto[1]
   	nValCop    := aRetPto[2]
   	nTaxa      := aRetPto[3]
   	nValUs     := aRetPto[4]
   	cAlias     := aRetPto[5]
   	lExistia   := aRetPto[6]
   	cPgNoAto   := aRetPto[7]
   	cPgDrRDA   := aRetPto[8]
   	nLimFra    := aRetPto[9]
   	lCompra    := aRetPto[10]
   	cRegAte    := aRetPto[11]
   	cCodTabCop := aRetPto[12]

   	if len(aRetPto) >= 13
      	aRdas := aRetPto[13]
   	endIf   
   
endIf

//Verifica coparticipoação no ato para internação
If cTipoGuia == "03"
	BA3->(dbsetOrder(1))
	If adadUsr[1] .AND. BA3->(MsSeek(xfilial("BA3")+Substr(aDadUsr[2],1,Len(adadUsr[2])-3)))

		If BA3->BA3_TIPOUS == "2"
			cChvBT6 := BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)
		endIf
		if BA3->(fieldPos("BA3_COPATO")) > 0 .AND. !(empty(BA3->BA3_COPATO)) //.T.//Seek no BA3 E Campo novo > 0
			cTabCop := BA3->BA3_COPATO
			caliAto := "BA3"
		elseif !(empty(cChvBT6)) .AND. BT6->(fieldPos("BT6_COPATO")) > 0
			BT6->(dbsetOrder(1))
			If BT6->(MsSeek(xfilial("BT6")+cChvBT6)) .AND. !(empty(BT6->BT6_COPATO))
				cTabCop := BT6->BT6_COPATO
				caliAto := "BT6"
			endIf
		endIf
	endIf
endIf

if ! lExistia .AND. empty(cTabCop)

	eval(bRest)
	return({.f.,cMsg})
	
elseIf lVerPgAto .and. ! lVlrNoAto .AND. empty(cTabCop)

	eval(bRest)
	return({.t.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,cPgNoAto,cPgDrRDA,0,.f.,0})
	
endIf       

cMsg := ""

//Salvo a aRda para tratamento futuro
if len(aSvRdas) == 0  
	aSvRdas := aClone(aRdas)
endIf
	
//irei analisar o aRdas e buscar a U.S especifica, caso existe para 
//cada rda do aRdas e atualizar seu conteudo para posterior calculo correto no PLSCALCEVE
//somente vai fazer de novo o TABCOP se tiver RDAs diferentes no aRDAs. Aqui analisamos o Array
//Se só houver uma RDA no array, não executa o PLSTABCOP
for nZZ := 1 to len(aRdas)
	if cCodRDA <> aRdas[nZZ][2] //Se uma for diferente, sai do laço
		laRDASdif := .t.
		Exit
	endIf
next

if laRDASdif

	for nfor := 1 to len(aRdas)
	
	   	aVetTab := PLSTABCOP(cCodPad,cCodPro,cCodInt,aRdas[nfor,2],aRdas[nfor,4],cSubEsp,aRdas[nfor,3],;
	                         cObsoleto,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,cCodPla,;
	                         cOpeOri,cVerPla,cGrpInt,aRdas[nfor,6],cMunAte,lVerPgAto,lCompra,;
	                         cMatric,cTipReg,dDatAnalise,cModPag,lInterc,cNivAut,cChvAut,aRdas[nfor,1],;
	                         cMes,cAno,dDatPro,cHorPro,cRegAte,cCid,nVlrApr,nQtd,aValAcu,aCobAcu,nRegBD6,;
	                         aDadUsr,cFinAte,nil,lAuditoria,lMudarFase)
	
	    if aVetTab[5] > 0
	       aRdas[nfor,5] := aVetTab[5]
	    endIf   
	    
	next   
endIf             
               	
//Ponto de entrada 
if lPLSRTCP1
   	aRdas := execBlock("PLSRTCP1",.f.,.f.,{aRdas,aDadUsr,cOpeRda,cTipPrefor,aSvRdas})
endIf   

//Calcula o valor do Evento caso ja nao tenha sido informado nao tenha 
//encontrado tabela no nivel de PF
if lCopPag //.and. nValUs == 0

	//Caso nao tenha o valor base de pagamento Ex.: Opcao Revalorizar Cobrança
	//Calculo a base do pagamento
	if len(aVetPag) == 0

		aVetPag := PLSCALCEVE(  cCodPad,cCodPro,cMes,cAno,cCodInt,cCodRDA,cEspec,cSubEsp,;
		                        cCodLoc,nQtd,dDatAnalise,cModPag,cPadInt,cRegAte,nVlrApr,;
		                        aDadUsr,cPadCon,{},nil,nil,nil,nil,cHorPro,aSvRdas,.f.,;
	                        	cProRel,nPrPrRl,aValAcu,lReembolso,dDatCir,cHorCir,aUnidsBlo,cTipoGuia,;
		                        lCompra,nVlrAprPag,aVlBloq,nil,lCirurgico,nPerVia,cRegPag,cRegCob,nQtd,;
		                        nQtd,aPacote,cChaveGui,cSequen,,,cRegInt,cFinAte,cChaveLib,,,,,cTipAdm,,lAneste,,,cHrFim)

	endIf
	
	//se deve considerar o valor de pagamento com taxa administrativa (Valor do apgamento com taxa ou sem)
	nVlrPag := iif( getNewPar("MV_PLCTXPG","1") == "1", nVlrPagBru, nVlrPagLiq )


	//Tratamento para cobrar coparticipação em caso da operadora fornecer a OPME ao prestador
	if nRegBD6 > 0
		BD6->(dbGoTo(nRegBD6)) 
	endif

	//Verifico se existe vinculo na B19, porcentagem de coparticipação e o valor de pagamento está zerado  
	B19->(dbSetOrder(2))	
	if B19->(msSeek(xFilial("B19")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN))) .and. nPercop > 0 .and.nVlrPag == 0

		//Capturo o valor contratado para o calculo da coparticipação
		cSqlNFE := " SELECT SUM(BD7_VLRBPR) BD7_VLRBPR"
		cSqlNFE += "   FROM " + retSqlName("BD7")
		cSqlNFE += "  WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
		cSqlNFE += "    AND BD7_CODOPE = '" + BD6->BD6_CODOPE + "' AND BD7_CODLDP = '" + BD6->BD6_CODLDP + "' "
		cSqlNFE += "    AND BD7_CODPEG = '" + BD6->BD6_CODPEG + "' AND BD7_NUMERO = '" + BD6->BD6_NUMERO + "' "
		cSqlNFE += "    AND BD7_ORIMOV = '" + BD6->BD6_ORIMOV + "' AND BD7_SEQUEN = '" + BD6->BD6_SEQUEN + "' "
		cSqlNFE += "    AND D_E_L_E_T_ = ' '"
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSqlNFE),"VLRB19",.f.,.t.)
		if ! VLRB19->(eof())
			nVlrPag := VLRB19->BD7_VLRBPR			
		endIf
		VLRB19->(dbCloseArea())
		
	endIf
	BD6->(restArea(aAreaBD6)) //Retorno para o registro BD6 antes do BD6->(dbGoTo(nRegBD6))
	
	//Informa o nivel onde foi encontrado o percentual de co-participacao
	if ! empty(cAliasTbCp) .or. nVlrPag <> aVetPag[2]
	
		for nI := 1 to len(aVetPag[1])
		
			for nY := 1 to len(aVetPag[1,nI,5])
			
				if ! empty(cAliasTbCp)
					aVetPag[1,nI,5,nY,2] := cAliasTbCp
				endIf
					                             
				//Atualiza o valor da co-participacao proporcional
				if nVlrPag <> aVetPag[2]
				
					nPercen 			 := ( aVetPag[1,nI,5,nY,4] / aVetPag[2] ) * 100
					aVetPag[1,nI,5,nY,4] := round( (nVlrPag * nPercen) / 100 , nDecBAS )
					
					nTTVlrPag += aVetPag[1,nI,5,nY,4]
					
					nPosNI := nI
					nPosNY := nY
					 
				endIf
					
			next
			
		next
		         
		aVetPag[2] := nVlrPag
		
		if nPosNI > 0 .and. nPosNY > 0	
			aVetPag[1,nPosNI,5,nPosNY,4] += (nVlrPag - nTTVlrPag)
		endIf	
		
	endIf
		
	//Composicao do pagamento e a propria composicao da base da co-participacao
	aRetCalc := aClone(aVetPag)
	
else          
  
	//cobrança
	aRetCalc := PLSCALCEVE(cCodPad,cCodPro,cMes,cAno,cCodInt,cCodRDA,cEspec,cSubEsp,; //8
	                        cCodLoc,nQtd,dDatAnalise,cModPag,cPadInt,cRegAte,nVlrApr,; //15
	                        aDadUsr,cPadCon,aQtdPer,cCodTabCop,cAliasTbCp,nValUs,; //21
	                        cAlias,cHorPro,aRdas,.t.,cProRel,nPrPrRl,aValAcu,lReembolso,; //29
	                        dDatCir,cHorCir,{},cTipoGuia,lCompra,nVlrAprPag,; //35
	                        aVlBloq,nil,lCirurgico,nPerVia,cRegPag,cRegCob,nQtd,; //42
	                        nQtd,aPacote,cChaveGui,cSequen,,,cRegInt,cFinAte,cChaveLib,,,, IIf(nValUs > 0, aclone(ardas), {}) ,cTipAdm,,lAneste,,cChvEvento,cHrFim) //60

endIf	                        

//URU
if cPaisLOC == "URU"

   nPosTimbre := ascan(aRetCalc[1],{ | x| x[1] == "TIM"})
   
   if nPosTimbre > 0
      nVlrTimbre  := aRetCalc[1,nPosTimbre,5,1,1]
      aRetCalc[2] := aRetCalc[2] - nVlrTimbre
   endIf
   
endIf
   
cConsFt := "0"
nFatMul := 1

nVlrTBES   := iif(cAlias =="VAP",0,aRetCalc[2])
nVlrEve    := nVlrTBES
nPerHorEsp := aRetCalc[5]

//Fator
if len(aRetCalc) >= 7
   cConsFT := aRetCalc[7]                    
endIf

if len(aRetCalc) >= 8
   nFatMul := aRetCalc[8]
endIf

//Neste ponto ele acha o valor base (VlrBPF) e o Valor da PF (VlrPF)
//Foi ADICIONADO nValCop==0  devidos aos casos onde a co-part e informada o seu valor o sistema não estava calculando
if nVlrApr > 0  .and. lMntVApr  .and. !(isInCallstack("PLSA001A") .or. isInCallStack("PLSA001"))
   nValCop := nVlrApr
endIf


//Casos de coparticipação com base no pagamento não deve entrara qui, pois o horário especial já foi calculado no plscalceve
//Caso de coparticipação com valor fixo não aplica horário especial
if nValCop > 0 .and. nPerHorEsp > 0 .and. ! lAprPto .AND. nPerCop > 0 .AND. !lCopPag

   cTipPreBD7 := cTipPre

   for nfor := 1 to len(aRdas)
   
       if aRdas[nfor,2] <> cCodRda
           cTipPreBD7 := aRdas[nfor,6]
           exit
       endIf
       
   next
                                  	
   //Somente se considerar horario especial...
   if ( BR8->BR8_ADCNOT == "1" ) .and. ( cTipPreBD7 $ cPreHEsp .or. PLAHESP(cTipPreBD7,cCodPad,cCodPro) ) 
      
      nValCop := nValCop + ( (nValCop * nPerHorEsp) / 100 )
      
   //nao tem mais horario
   else
   	  
      nPerHorEsp := 0 
      
   endIf

endIf

//Limpamos o campo que exibe a informação do percentual de hora especial, quando for co-particição fixa
if nValCop > 0 .and. nPerHorEsp > 0
	nPerHorEsp := 0    
endif

//quando e um valor fechado e for cbhpm e tiver banda tenho que recalcular aqui neste momento..
if nValCop > 0 .and. ! lAprPto

	lFlagBd := .f.
	
	if len(aRetCalc) >= 1
	
		aCalcAberto := aRetCalc[1]
		
		for nforBanda1 := 1 to len(aCalcAberto)
		
			for nforBanda2 := 1 to len(aCalcAberto[nforBanda1,5])
			
				if len(aCalcAberto[nforBanda1,5,nforBanda2]) >= 9
				
					if aCalcAberto[nforBanda1,5,nforBanda2,10] == "1"
					
						if len(aCalcAberto[nforBanda1,5,nforBanda2]) > 12
							nBandaRec := aCalcAberto[nforBanda1,5,nforBanda2,13]
						else
							nBandaRec := 0
						endIf
						
						if nBandaRec > 0
							Exit
						endIf
						
					endIf
					
				endIf
				
			next
			
			if lFlagBd
				Exit
			endIf
			
		next
		
	endIf
	
	if nBandaRec > 0 .AND. (nPerCop > 0 .OR. aRetCalc[4] $ "BGH/BGI")
		nValCop := (nValCop * nBandaRec) / 100
	endIf
	
	if cConsFt == "1"
		nValCop := nValCop * nFatMul
	endIf
	
	nVlrEve := nValCop * nQtd
	nVlrBPF := nValCop * nQtd
	nVlrPF  := nValCop * nQtd
	
	if nPerCop > 0 
		nVlrPF   += ( nVlrTBES * nPerCop ) / 100
	endIf
	
elseIf nValCop > 0 .and. lAprPto
	
	nVlrEve := nVlrTBES
	nVlrBPF := nValCop * nQtd
	
	if nPerCop > 0
		nVlrPF  := ( nVlrBPF * nPerCop ) / 100
	else
		nVlrPF  := nValCop * nQtd
	endIf
	
elseIf nPerCop > 0

	if nValUs > 0
		nVlrEve := nVlrTBES
	endIf
	
	if nValCop == 0
		nVlrBPF := nVlrEve 
	else
		nVlrBPF := nValCop * nQtd 
	endIf
	
	nVlrPF  := ( nVlrBPF * nPerCop ) / 100
	
elseIf nValUS > 0

	nVlrEve := nVlrTBES
	nVlrBPF := nVlrTBES
	nVlrPF  := nVlrTBES
	
endIf

//Adiciona o valor do Timbre (localizacao uruguai)                    
if cPaisLoc == "URU" .and. nVlrTimbre > 0
   nVlrEve += nVlrTimbre
   nVlrBPF += nVlrTimbre
   nVlrPF  += nVlrTimbre
endIf

//Trata a majoracao.
if lPlsCalMaj .and. ! empty(cCodRda) .and. ! empty(cCodInt) .and. ! empty(dDatPro)

	nPerMaj := PlsCalMaj(cCodRda, cCodInt, dDatPro, cTipoGuia)
	//Trata cabecalho
	if nPerMaj > 0
		nVlrBPF	:= nVlrBPF + ((nVlrBPF * nPerMaj) / 100)
		nVlrPF	:= nVlrPF  + ((nVlrPF  * nPerMaj) / 100)
		nVlrTPF := nVlrTPF + ((nVlrTPF * nPerMaj) / 100) 
	endIf
	
	//Trata os itens
	if nPerMaj > 0
	
		for nfor := 1 to len(aRetCalc[1])
		
	       for nInd := 1 to len(aRetCalc[1,nfor,5])
	       
	           aRetCalc[1,nfor,5,nInd,4] := aRetCalc[1,nfor,5,nInd,4] + ( ( aRetCalc[1,nfor,5,nInd,4] * nPerMaj ) / 100 )
	       
	           nTotAux += aRetCalc[1,nfor,5,nInd,4]
	           
	       next
	                  
	    next
	    
	    aRetCalc[2] := nTotAux
	    
	endIf
	   
endIf

//Ponto de Entrada
if lPLSMBLF  
  
   aParPtoEnt := {nPerCop,nValCop,nTaxa,nValUs,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,cCodInt,cCodEmp,;
                  cMatric,cTipReg,cCodPla,cVerPla,cOpeOri,dDatPro,nQtd,cCodPad,cCodPro,cCodLoc,cCodRda,;
                  lCompra,cRegAte,cCodTabCop,nVlrEve,cTipPre,nVlrTBES,nVlrBPF,nVlrTPF,nVlrPF,nVlrTAD,;
                  nSlvBase,nSlvPerc,nSlvTx,nSlvtotal,nPerda,cFranquia,nPerHorEsp,cNivAut,cChvAut,aRetCom}

   aRetPto := execBlock("PLSMBLF",.f.,.f.,aParPtoEnt)
   nVlrtPF := aRetPto[1]
   
endIf   

if nLimFra > 0 .and. nVlrPF > nLimFra 

   	nSlvBase  	:= nVlrPF
   	nSlvPerc  	:= nTaxa
   	nSlvTx    	:= nVlrTAD
   	nSlvtotal 	:= nVlrTPF
   
   	cFranquia 	:= "1"

   	nPerda    	:= 100 - ( nLimFra / nVlrPF ) * 100
   	 
   	nVlrPF  -= ( nVlrPF  * nPerda ) / 100   	   	      
       
   	if nVlrMaPF > 0 .and. lPagDif
   		nDif    := nVlrEve - (nVlrMaPF * nQtd)    
        nVlrPF  += nDif
      	nVlrTPF += nDif
   	endIf   
   
endIf

//Se existir trata a taxa de administracao...                          
if nTaxa > 0		   	
           
	//Taxa administrativa sobre o valor liquido da coparticipacao
   	if lModCTX
		nVlrTAD := Round(nVlrPF * nTaxa / 100, 2)
      
	//Taxa administrativa sobre a base da coparticipacao
   	else
		nVlrTAD := Round(nVlrBPF * nTaxa / 100, 2)
      
   	endIf
   	
   	//Pra caso a taxa fique negativa, zeramos
    if nVlrTAD < 0
    	nVlrTAD := 0
    endIf 
   	
   	//Este parametro visa o calculo da taxa independente da franquia,      
	//ou seja, cobra-se a taxa sobre o valor base + a franquia			 
   	if nVlrTAD > 0 .and. getNewPar("MV_PLSFCFR","1") == "0"
		nVlrTPF := nVlrTAD + nVlrPF
	else
   		If nLimFra > 0
			nVlrTPF := iif(nVlrTAD + nVlrPF > nLimFra, nLimFra, nVlrTAD + nVlrPF)
		else
			nVlrTPF := nVlrTAD + nVlrPF
		EndIf
	endif      
   
else
   nVlrTPF := nVlrPF
endIf

//Valor esta em real, devo colocar 
if nValCop > 0

   nSubItens   := len(aRetCalc[1])
   nPercenSub  := 100 / nSubItens
   
   if nSubItens == 0
	   nPerCop    := 0
	   nValCop    := 0
	   nTaxa      := 0
	   nValUs     := 0
	   lExistia   := .f.
	   cPgNoAto   := '0'
	   cPgDrRDA   := '0'
	   nLimFra    := 0
	   nVlrTBES	  := 0
	   nVlrBPF	  := 0
	   nVlrTPF	  := 0
	   nVlrPF	  := 0
	   nVlrTAD	  := 0
	   nSlvBase	  := 0
	   nSlvPerc	  := 0
	   nSlvTx	  := 0
	   nSlvtotal  := 0
	   nPerda	  := 0
	   cFranquia  := '0'
	   nPerHorEsp := 0
   else
       aRetCalc[2] := nVlrTPF
   	   aRetCalc[4] := cAlias
   	   
	   for nfor := 1 to len(aRetCalc[1])
	   
	       for nInd := 1 to len(aRetCalc[1,nfor,5])
	   
	           aRetCalc[1,nfor,5,nInd,1] := (nValCop * nPercenSub) / 100
	           aRetCalc[1,nfor,5,nInd,2] := cAlias
	           aRetCalc[1,nfor,5,nInd,4] := 0      
	           aRetCalc[1,nfor,5,nInd,5] := (nValCop * nPercenSub) / 100
	           aRetCalc[1,nfor,5,nInd,7] := getNewPar("MV_SIMB1","R$")
	   
	       next
	       
	   next
	       
	endIf

endIf
                               
//Ponto de entrada para manipular dados de co-participacao, depois q
//ja sei o valor do procedimento								    
if lPLSRETC2

   	aParPtoEnt := {nPerCop,nValCop,nTaxa,nValUs,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,cCodInt,cCodEmp,;
                  cMatric,cTipReg,cCodPla,cVerPla,cOpeOri,dDatPro,nQtd,cCodPad,cCodPro,cCodLoc,cCodRda,;
                  lCompra,cRegAte,cCodTabCop,nVlrEve,cTipPre,nVlrTBES,nVlrBPF,nVlrTPF,nVlrPF,nVlrTAD,;
                  nSlvBase,nSlvPerc,nSlvTx,nSlvtotal,nPerda,cFranquia,nPerHorEsp,cNivAut,cChvAut,aRetCom}

   	aRetPto    := execBlock("PLSRETC2",.f.,.f.,aParPtoEnt)
   	nPerCop    := aRetPto[1]
   	nValCop    := aRetPto[2]
   	nTaxa      := aRetPto[3]
   	nValUs     := aRetPto[4]                                                                     
   	cAlias     := aRetPto[5]
   	lExistia   := aRetPto[6]
   	cPgNoAto   := aRetPto[7]
   	cPgDrRDA   := aRetPto[8]
   	nLimFra    := aRetPto[9]
   	lCompra    := aRetPto[10]
   	cRegAte    := aRetPto[11]
   	cCodTabCop := aRetPto[12]
   
   	if len(aRetPto) >= 13
		nVlrTBES	:= aRetPto[13]
		nVlrBPF		:= aRetPto[14]
		nVlrTPF		:= aRetPto[15]
		nVlrPF		:= aRetPto[16]
		nVlrTAD		:= aRetPto[17]
    	nSlvBase	:= aRetPto[18]
     	nSlvPerc	:= aRetPto[19]
      	nSlvTx		:= aRetPto[20]
       	nSlvtotal	:= aRetPto[21]
        nPerda		:= aRetPto[22]
        cFranquia	:= aRetPto[23]    
        nPerHorEsp  := aRetPto[24]    
   endIf
   
endIf  
//se existe a co-participacao mas ela indica que nada deve ser cobrado
//isso normalmente ocorre quando se cadastra, por exemplo...
//quantidade ate 2 valor R$0,00.  
//quantidade ate 999 valor R$50,00.
lforcZer := nPerCop == 0 .and. nValCop == 0 .and. lExistia .and. ! empty(cAlias) .and. nValUS == 0

eval(bRest)

PLGetDec('BD6_PERHES')

//Verifica se a plcia regra de coaprt na internação no ato
If !(empty(cTabCop))
	BRT->(DbSetOrder(1))
	BRU->(DbSetOrder(1))
	If !(empTy(cTabCop)) .AND. BRT->(MsSeek(xFilial("BRT")+cTabCop))
		If BRT->BRT_VIGINI <= dDatabase .AND. (EmpTy(BRT->BRT_VIGFIM) .OR. BRT->BRT_VIGFIM >= dDatabase)
			If BRU->(MsSeek(xFilial("BRU")+cTabCop))
				lAtoInt := .T.
				lExistia := .T.
				nVlrTPF := BRU->BRU_VLRCOP
				cPgNoAto := "1"
				calias := caliAto
				M->BE4_PAGATO := "1"
				M->BEJ_VLCOMP := nVlrTPF
			EndIf
		EndIf
	EndIf
endIf

return({lExistia, cMsg, cCodTabCop, cTipoTab, round(nPerCop, PLGetDec('BD6_PERCOP') ), round(nVlrTBES,2), round(nTaxa, PLGetDec('BD6_PERTAD') ),;
		0, nValCop, nValUs, round(nVlrBPF,PLGetDec('BD6_VLRBPF')), round(nVlrTPF, PLGetDec('BD6_VLRTPF') ), round(nVlrPF, PLGetDec('BD6_VLRPF') ),;
	    round(nVlrTAD,PLGetDec('BD6_VLRTAD') ), cAlias, cPgNoAto, aRetCalc, cPgDrRDA, round(nLimFra, PLGetDec('BD6_F_VFRA') ),;
	    round(nSlvBase, PLGetDec('BD6_F_VLOR') ),round(nSlvPerc, PLGetDec('BD6_F_POTX') ), round(nSlvTx, PLGetDec('BD6_F_TXOR') ),;
	    round(nSlvtotal, PLGetDec('BD6_F_TOOR') ),round(nPerda, PLGetDec('BD6_F_PPER') ), cFranquia, round(nPerHorEsp, PLGetDec('BD6_PERHES') ),;
        lforcZer, lCopPag, nPerMaj})


/*/{Protheus.doc} PLSTABCOP
Pesquisa qual a tabela de co-participao e percentual ou valor
Calculo no retorno da funcao AnalQtdCO2
calcula o indice a ser aplicado por exemplo:         
suponha a parametrizacao                             
0-3    -> R$15,00                                    
4-9    -> R$25,00                                    
10-999 -> R$35,00                                    
e o usuraio digiou a qtd = 17 logo deve-se cobrar    
3*15,00 + 5*25,00 + 9*35,00						  	 
e nao 17*35,00

lVerPgAto 
.t. - Somente procuro "Som.Compra" Sim
.f. - Somente procuro "Som.Compra" Nao
lPagDif
o usuario paga a diferenca entre a cop-participacao e a franquia?
OBS.: em todos os niveis dessa funcao, deveria ser  
considerado a quantidade de co-participacao.     
   	
@version 	P12
@since		31.10.16
/*/							
function PLSTABCOP(cCodPad,cCodPro,cCodInt,cCodRDA,cEspec,cSubEsp,cCodLoc,cObsoleto,;
                   cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,cCodPla,cOpeOri,cVerPla,cGrpInt,cTipPre,cMunAte,;
                   lVerPgAto,lCompra,cMatric,cTipReg,dDatAnalise,cModPag,lInterc,cNivAut,cChvAut,cCodUnm,;
                   cMes,cAno,dDatPro,cHorPro,cRegAte,cCid,nVlrApr,nQtd,aValAcu,aCobAcu,nRegBD6,aDadUsr,cFinAte,;
                   lRecursivo,lAuditoria,lMudarFase)
local cSQL      := ""
local cQRY 		:= ""
local nNiveis  	:= 0
local nfor      := 1                 
local nAte      := 1
local cNameBT8 	:= BT8->(RetSQLName("BT8"))
local cNameBYK 	:= BYK->(RetSQLName("BYK"))
local cNameBHE 	:= BHE->(RetSQLName("BHE"))
local cNameBHD 	:= BHD->(RetSQLName("BHD"))
local cNameBB2 	:= BB2->(RetSQLName("BB2"))
local bCond2   	:= { |cAlias| &(cAlias+"->"+cAlias+"_SOMCOM") $ if(lCompra,"1","0 ") }
local bTrtVig	:= { |dDatPro,cAlias,lSql| PlRetVigCP(dDatPro,cAlias,lSql) }
local cCodTab   := ""                      
local nPerCop   := 0
local nValCop   := 0 
local nTaxa     := 0
local nValUS    := 0    
local cAlias    := ""   
local cPgNoAto  := ""
local cPgDrRDA  := ""
local lExistia  := .f.
local aRetFun   := {}
local lChkNvLoc := (getNewPar("MV_PLSCRLI","0") == "1")
local cDiaSem   := "" 
local nLimFra   := 0
local aFaiQtd   := {}
local cREGGOP   := ""
local cGRUOPE   := ""
local lPagDif	:= .f.
local nOrdBR8   := 0
local nRecBR8   := 0
local lFlag     := .f.
local aTmp      := {1,2,3,4,5}
local nAux      := 0
local nPos    	:= 0
local cCodPadProPP := ""
local nVlrMaPF 	:= 0
local lVig  	:= .t.
local lValZero 		:= getNewPar("MV_PLSVLZE",.f.)
local lReembolso	:= isInCallstack("PLSA001A") .or. isInCallStack("PLSA001")
local aPesqTab		:= Separa(getNewPar("MV_PLNVCP", "BOR,BVM,BVJ,BVF,BVC,BNZ,BLW,BLX,BGL,BHE,BGS,BHF,BHG,BS9,BYK,BGD,BHD,BB2,BCW,BHI,B86,BHJ,BHK,BSY,BHC,BWW"),",")
local lBS9_ANOMES 	:= BS9->( fieldPos("BS9_ANOMES") ) > 0 
local lBS9_VLRANT 	:= BS9->( fieldPos("BS9_VLRANT") ) > 0
local lNConsNIV		:= getNewPar("MV_PLSNNIV",.f.)
Local nQtdProc	:= 0

default cGrpInt   := ""
default cTipPre   := ""
default cMunAte   := ""
default lVerPgAto := .f.
default lCompra   := .f.
default lInterc   := .f.                                                            
default cNivAut   := ""
default cChvAut   := ""
default cCodUnm   := ""    
default cMes      := ""    
default cAno      := ""    
default dDatPro   := dDataBase
default cRegAte   := ""
default cCid      := ""
default nVlrApr   := 0
default nQtd      := 1
default aValAcu   := {}
default aCobAcu   := {}
default nRegBD6   := 0
default aDadUsr   := PLSGETUSR()
default cFinAte	  := ""
default lRecursivo:= .t.
default lAuditoria:= .f.
default lMudarFase:= .t. // Criado para definir ser é uma mudança de fase(.t.) ou uma valorizaçõa (.f.)

if __cCdTbPd <> cCodPad .or. len(__aNiveis) == 0
	__cCdTbPd := cCodPad
	__aNiveis := PLSESPNIV(cCodPad)
endIf	
nNiveis := (__aNiveis[1]+1)

if BR8->(BR8_CODPAD+BR8_CODPSA) != cCodPad+cCodPro
	BR8->(dbsetOrder(1))
	BR8->(msSeek(xFilial("BR8")+cCodPad+cCodPro))
endIf

              
/*
	// Familia / Usuario
	(BVM) - Usuario
	(BVJ) - Usuario X Grupo de Cobertura X Co-Participacao
	(BVF) - Familia
	(BVC) - Familia x Grupo de Cobertura X Co-Participacao

	// Subcontrato.
	(BLW) - Subcontrato X Procedimento X CID - Sem Vigencia
	(BLX) - Subcontrato X Procedimento X Especialidade
	(BHE) - Subcontrato X Produto X Procedimento
	(BGL) - Subcontrato X Municipio X Procedimento
	(BS9) - Subcontrato X Unidade - Nao existe tratamento
	(BGS) - Subcontrato X Tipo de Prestador
	(BHG) - Subcontrato X Produto
	(BHF) - Subcontrato X Grupo de Cobertura
	(BNX/BNZ) - Subcontrato X Co-Participacao X Horario
	(BOR) - Subcontrato x rede de atendimento x cobranca de co-participacao

	// Produto
	(BYK) - Produto X Propriedades por tipo de internacao
	(BGD) - Produto X Cobertura X Município
	(BB2/BHD) - Produto X Procedimento
	(BCW) - Produto X Tipo de Prestador
	(BHI) - Produto X Grupo de Cobertura
	(BHJ) - Produto
	(B86) - Produto x rede de atendimento x co-participacao

	// Grupo de cobertura.
	(BHK) - Grupo de Cobertura X Co	-Participacao
	(BGI) - Grupo de Operadora X Itens
	(BGH) - Grupo de Operadora
	(BHC) - Tabela Padrao
	(BWW) - Operadora X Co-Participacao Padrao
*/  
//1 - (BOR) - Subcontrato x rede de atendimento x cobranca de co-participacao 
if aScan(aPesqTab, "BOR") > 0

	BOR->(dbsetOrder(1))
	if ( ! lInterc .or. lChkNvLoc ) .and. BOR->(MsSeek(xFilial("BOR")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA))
	
		if BOR->BOR_BLOCOP == "1"
			lExistia := .f.
	      	cCodTab  := ""
    	  	nPerCop  := 0
	      	nValCop  := 0
    	  	cPgNoAto := ""
	      	nTaxa    := 0
    	  	nValUS   := 0
    	  	cAlias   := ""
	      	cPgDrRDA := ""
	      	
			return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})	      	
		endIf
		
	endIf
	
endIf

//B86 - Exceção.
//Nesse ponto busca se foi cadastrado a regra de bloqueio de coparticipação na B86, 
//pro cadastro de valor de coparticipação irá ser verificado no momento já existente
if lB86Blocop .AND. aScan(aPesqTab, "B86") > 0

	B86->(dbsetOrder(1))
	if ( ! lInterc .or. lChkNvLoc ) .and. B86->(MsSeek(xFilial("B86")+cCodInt+cCodPla+cVerPla+cCodRDA))
		
		while !B86->( eof() ) .and. B86->(B86_FILIAL+B86_CODINT+B86_CODPLA+B86_VERSAO+B86_CODRDA) == xFilial("B86")+cCodInt+cCodPla+cVerPla+cCodRDA
						
			//Se a vigencia estiver dentro do limite parametrizado...
			if PLSINTVAL("B86","B86_VIGDE","B86_VIGATE",dDatAnalise)
	
				if B86->B86_BLOCOP == "1"
					lExistia := .f.
					cCodTab  := ""
					nPerCop  := 0
					nValCop  := 0
					cPgNoAto := ""
					nTaxa    := 0
					nValUS   := 0
					cAlias   := ""
					cPgDrRDA := ""
					
					return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})	      	
				endIf
			endif
			B86->(dbskip())
		endDo
	endIf
	
endIf

//para tratar erro no calc Co-Part devido posicionamento Usuário. 
if len(aDadUsr) >= 64 .and. aDadUsr[8] == "2"
   cREGGOP    := aDadUsr[63]
   cGRUOPE    := aDadUsr[64]
else
	if BA3->BA3_TIPOUS == "2" 
	   cREGGOP  := BQC->BQC_REGGOP
	   cGRUOPE  := BQC->BQC_GRUOPE
	endIf   
endIf

cDiaSem := upper(subStr(PLSDIASEM(dDatPro),1,3))

//2 - (BGH) - Grupo de Operadora                       
//3 - (BGI) - Grupo de Operadora X Itens                
if lInterc .or. cREGGOP == "1"

   aRetFun := PLSGRUOPE("2", cOpeOri, dDatAnalise, nNiveis, __aNiveis, cCodPro, cModPag, cCodPad, cEspec,;
   						cCodUnm, cCodPla, nVlrApr, if(cREGGOP=="1",cGRUOPE,""), nil, lInterc, cFinAte, cCodRda, /*cRdaEdi*/, /*lRtBanda*/, /*lRetFil*/, /*lBusTx*/, cRegAte)

   if aRetFun[7]
      return(aRetFun)
   endIf

endIf

//4 - (BVM) - Usuario
if aScan(aPesqTab, "BVM") > 0 .and. ( ! lInterc .or. lChkNvLoc ) .and. ( cNivAut == "BFG" .or. lAuditoria .or. lNConsNIV )

	BVM->(dbsetOrder(1)) //BVM_FILIAL+BVM_CODINT+BVM_CODEMP+BVM_MATRIC+BVM_TIPREG+BVM_CODPAD+BVM_CODPSA+BVM_NIVEL
	
	if BVM->(FieldPos("BVM_TIPO")) > 0 .and. BVM->(FieldPos("BVM_QTD")) > 0 .and. BVM->(FieldPos("BVM_IDAINI")) > 0 .and. BVM->(FieldPos("BVM_IDAFIN")) > 0
		cSql := " SELECT BVM_SOMCOM, BVM_TIPO, BVM_PERCOP, BVM_VALCOP, BVM_FINATE, BVM_QTD, BVM_CODTAB, BVM_IDAINI, BVM_IDAFIN, "
		cSql += " BVM_PAGATO, BVM_TXADM, BVM_VALUS, BVM_LIMFRA, BVM_ANOMES, BVM_VLRANT, BVM_VIGDE, BVM_VIGATE FROM " + retSqlName("BVM")
		cSql += " WHERE " 
		cSql += " BVM_FILIAL = '" + xFilial("BVM") + "' "
		cSql += " AND BVM_CODINT = '" + cCodInt + "' "
		cSql += " AND BVM_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BVM_MATRIC = '" + cMatric + "' "
		cSql += " AND BVM_TIPREG = '" + cTipReg + "' "
		cSql += " AND BVM_CODPAD = '" + cCodPad + "' "
		cSql += " AND BVM_CODPSA = '" + cCodPro + "' "
		cSql += " AND ( '" + dtos(dDatAnalise) + "' >= BVM_VIGDE OR BVM_VIGDE  = '        ' ) "
		cSql += " AND ( '" + dtos(dDatAnalise) + "' <= BVM_VIGATE OR BVM_VIGATE = '        ' ) "
		cSql += " AND ( BVM_FINATE = ' ' OR RTRIM(LTRIM(BVM_FINATE)) = '"+allTrim(cFinAte)+"' ) "
		cSql += " AND ( BVM_TIPO = '3' OR BVM_TIPO = '"+cRegAte+"' ) "
		cSql += " AND D_E_L_E_T_ = ' ' "
		cSql += " ORDER BY BVM_FINATE DESC, BVM_QTD ASC "

		aFaiQtd := MonQtdCOP(cSql,"PLSTABCOP","BVM",,,,,lCompra,dDatPro,aDadUsr,cFinAte,;
			{ || PLSINTVAL("PLSTABCOP","BVM_VIGDE","BVM_VIGATE",dDatAnalise) },cRegAte)

		if len(aFaiQtd) > 0
			
			aForEsp := aClone(AnalQtdCO2(aFaiQtd,nfor,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,lMudarFase,"BVM"))
		
			for nAux := 1 to len(aForEsp)

				lExistia := .t.
				cCodTab  := aFaiQtd[ aForEsp[nAux][2] , 3 ]
				nPerCop  += 1 / nQtd *( aForEsp[nAux][1] * aFaiQtd[ aForEsp[nAux][2] ,4 ] )
				nValCop  += 1 / nQtd *( aForEsp[nAux][1] * aFaiQtd[ aForEsp[nAux][2] ,5 ] )
				cPgNoAto := aFaiQtd[ aForEsp[nAux][2] , 6 ]
				nTaxa    := aFaiQtd[ aForEsp[nAux][2] , 7 ]
				nValUS   := aFaiQtd[ aForEsp[nAux][2] , 8 ]
				cAlias   := "BVM"
				cPgDrRDA := aFaiQtd[ aForEsp[nAux][2] , 10]
				lPagDif  := aFaiQtd[ aForEsp[nAux][2] , 12]
				nVlrMaPF := aFaiQtd[ aForEsp[nAux][2] , 13]      
								
				if len(aFaiQtd[aForEsp[nAux][2]]) >= 14
					if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aForEsp[nAux][2], 14]
						nLimFra := aFaiQtd[aForEsp[nAux][2], 15]
					else
						nLimFra := aFaiQtd[aForEsp[nAux][2],9]
					endIf
				else
					nLimFra  := aFaiQtd[aForEsp[nAux][2],9]
				endIf
				
			next

			if lExistia
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF})
			endIf

		endif
	else
		//Se nao achou o procedimento explicitamente, pesquisa pelos niveis de estrutura de procedimento
		aRetFun := PLSVLDCP(__aNiveis,nNiveis,"BVM",cCodInt+cCodEmp+cMatric+cTipReg+cCodPad,cCodPro,;
							cCodPro,lVerPgAto,lCompra,"CODPSA","VALCOP",dDatPro,dDatAnalise,cFinAte,;
							{||PLSINTVAL("BVM",'BVM_VIGDE','BVM_VIGATE',dDatAnalise)})
		
		if aRetFun[1]
			cAlias  := "BVM"
			return(aRetFun[2])
		endIf

	endif

endIf

//5 - (BVJ) - Usuario X Grupo Cobertura X Co-Participacao
if aScan(aPesqTab, "BVJ") > 0 .and. ( ! lInterc .or. lChkNvLoc ) .and. (cNivAut == "BFE" .or. lAuditoria .or. lNConsNIV )
	
	BVJ->(dbsetOrder(1))//BVJ_FILIAL, BVJ_CODINT, BVJ_CODEMP, BVJ_MATRIC, BVJ_TIPREG, BVJ_CODGRU, BVJ_CODTAB

	if BVJ->(FieldPos("BVJ_IDAINI")) > 0 .and. BVJ->(FieldPos("BVJ_IDAFIN")) > 0
		cSql := " SELECT BVJ_TIPO, BVJ_PERCOP, BVJ_VALCOP, BVJ_FINATE, BVJ_QTD, BVJ_CODTAB, BVJ_IDAINI, BVJ_IDAFIN, "
		cSql += " BVJ_TXADM, BVJ_VALUS, BVJ_LIMFRA, BVJ_ANOMES, BVJ_VLRANT, BVJ_VIGDE, BVJ_VIGATE  FROM " + retSqlName("BVJ")
	else
		cSql := " SELECT BVJ_TIPO, BVJ_PERCOP, BVJ_VALCOP, BVJ_FINATE, BVJ_QTD, BVJ_CODTAB, "
		cSql += " BVJ_TXADM, BVJ_VALUS, BVJ_LIMFRA, BVJ_ANOMES, BVJ_VLRANT, BVJ_VIGDE, BVJ_VIGATE  FROM " + retSqlName("BVJ")
	endif

	cSql += " WHERE "
	cSql += " BVJ_FILIAL = '" + xFilial("BVJ") + "' "

	if lNConsNIV
		cSql += " AND BVJ_CODINT = '" + cCodInt + "' "
		cSql += " AND BVJ_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BVJ_MATRIC = '" + cMatric + "' "
		cSql += " AND BVJ_TIPREG = '" + cTipReg + "' "
		cSql += " AND BVJ_CODGRU = '" + RIGHT(allTrim(cChvAut) , 3 )  + "' "

	else
		cSql += " AND BVJ_CODINT = '" + SubStr(allTrim(cChvAut),1,4) + "' "
		cSql += " AND BVJ_CODEMP = '" + SubStr(allTrim(cChvAut),5,4) + "' "
		cSql += " AND BVJ_MATRIC = '" + SubStr(allTrim(cChvAut),9,6) + "' "
		cSql += " AND BVJ_TIPREG = '" + SubStr(allTrim(cChvAut),15,2) + "' "
		cSql += " AND BVJ_CODGRU = '" + SubStr(allTrim(cChvAut),17,3) + "' "
	endIf

	cSql += " AND ( '" + dtos(dDatAnalise) + "' >= BVJ_VIGDE OR BVJ_VIGDE  = '        ' ) "
	cSql += " AND ( '" + dtos(dDatAnalise) + "' <= BVJ_VIGATE OR BVJ_VIGATE = '        ' ) "
	cSql += " AND ( BVJ_FINATE = ' ' OR RTRIM(LTRIM(BVJ_FINATE)) = '"+allTrim(cFinAte)+"' ) "
	cSql += " AND ( BVJ_TIPO = '3' OR BVJ_TIPO = '"+cRegAte+"' ) "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY BVJ_FINATE DESC, BVJ_QTD ASC "

	aFaiQtd := MonQtdCOP(cSql,"PLSTABCOP","BVJ",,,,,lCompra,dDatPro,aDadUsr,cFinAte,;
		{ || PLSINTVAL("PLSTABCOP","BVJ_VIGDE","BVJ_VIGATE",dDatAnalise) },cRegAte)

	if len(aFaiQtd) > 0
		
		aForEsp := aClone(AnalQtdCO2(aFaiQtd,nfor,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,lMudarFase,"BVJ"))
	
		for nAux := 1 to len(aForEsp)

			lExistia := .t.
			cCodTab  := aFaiQtd[ aForEsp[nAux][2] , 3 ]
			nPerCop  += 1 / nQtd *( aForEsp[nAux][1] * aFaiQtd[ aForEsp[nAux][2] ,4 ] )
			nValCop  += 1 / nQtd *( aForEsp[nAux][1] * aFaiQtd[ aForEsp[nAux][2] ,5 ] )
			cPgNoAto := aFaiQtd[ aForEsp[nAux][2] , 6 ]
			nTaxa    := aFaiQtd[ aForEsp[nAux][2] , 7 ]
			nValUS   := aFaiQtd[ aForEsp[nAux][2] , 8 ]
			cAlias   := "BVJ"
			cPgDrRDA := aFaiQtd[ aForEsp[nAux][2] , 10]
			lPagDif  := aFaiQtd[ aForEsp[nAux][2] , 12]
			nVlrMaPF := aFaiQtd[ aForEsp[nAux][2] , 13]      
							
			if len(aFaiQtd[aForEsp[nAux][2]]) >= 14
				if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aForEsp[nAux][2], 14]
					nLimFra := aFaiQtd[aForEsp[nAux][2], 15]
				else
					nLimFra := aFaiQtd[aForEsp[nAux][2],9]
				endIf
			else
				nLimFra  := aFaiQtd[aForEsp[nAux][2],9]
			endIf
			
		next

		if lExistia
			return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF})
		endIf

	endif
	
endIf

//6 - (BVF) - Familia X Procedimentos                   
if aScan(aPesqTab, "BVF") > 0 .and. (! lInterc .or. lChkNvLoc)  .and. (cNivAut == "BFD" .or. lAuditoria .or. lNConsNIV )
	
	BVF->(dbsetOrder(1)) //BVF_FILIAL+BVF_CODINT+BVF_CODEMP+BVF_MATRIC+BVF_CODPAD+BVF_CODPSA+BVF_NIVEL
	if BVF->(FieldPos("BVF_TIPO")) > 0 .and. BVF->(FieldPos("BVF_QTD")) > 0
		cSql := " SELECT BVF_SOMCOM, BVF_TIPUSR, BVF_IDAINI, BVF_IDAFIN, BVF_PERCOP, BVF_TIPO, BVF_QTD, "
		cSql += " BVF_VALCOP, BVF_FINATE, BVF_CODTAB, BVF_PAGATO, BVF_TXADM, BVF_VALUS, BVF_LIMFRA, "
		cSql += " BVF_ANOMES, BVF_VLRANT, BVF_VIGINI, BVF_VIGFIN FROM " + retSqlName("BVF")
		cSql += " WHERE " 
		cSql += " BVF_FILIAL = '" + xFilial("BVF") + "' "
		cSql += " AND BVF_CODINT = '" + cCodInt + "' "
		cSql += " AND BVF_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BVF_MATRIC = '" + cMatric + "' "
		cSql += " AND BVF_CODPAD = '" + cCodPad + "' "
		cSql += " AND BVF_CODPSA = '" + cCodPro + "' "
		cSql += " AND ( '" + dtos(dDatAnalise) + "' >= BVF_VIGINI OR BVF_VIGINI  = '        ' ) "
		cSql += " AND ( '" + dtos(dDatAnalise) + "' <= BVF_VIGFIN OR BVF_VIGFIN = '        ' ) "
		cSql += " AND ( BVF_FINATE = ' ' OR RTRIM(LTRIM(BVF_FINATE)) = '"+allTrim(cFinAte)+"' ) "
		cSql += " AND ( BVF_TIPO = '3' OR BVF_TIPO = '"+cRegAte+"' ) "
		cSql += " AND D_E_L_E_T_ = ' ' "
		cSql += " ORDER BY BVF_FINATE DESC, BVF_QTD ASC "

		aFaiQtd := MonQtdCOP(cSql,"PLSTABCOP","BVF",,,,,lCompra,dDatPro,aDadUsr,cFinAte,;
			{ || PLSINTVAL("PLSTABCOP","BVF_VIGINI","BVF_VIGFIN",dDatAnalise) },cRegAte)

		if len(aFaiQtd) > 0
			
			aForEsp := aClone(AnalQtdCO2(aFaiQtd,nfor,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,lMudarFase,"BVF"))
		
			for nAux := 1 to len(aForEsp)

				lExistia := .t.
				cCodTab  := aFaiQtd[ aForEsp[nAux][2] , 3 ]
				nPerCop  += 1 / nQtd *( aForEsp[nAux][1] * aFaiQtd[ aForEsp[nAux][2] ,4 ] )
				nValCop  += 1 / nQtd *( aForEsp[nAux][1] * aFaiQtd[ aForEsp[nAux][2] ,5 ] )
				cPgNoAto := aFaiQtd[ aForEsp[nAux][2] , 6 ]
				nTaxa    := aFaiQtd[ aForEsp[nAux][2] , 7 ]
				nValUS   := aFaiQtd[ aForEsp[nAux][2] , 8 ]
				cAlias   := "BVF"
				cPgDrRDA := aFaiQtd[ aForEsp[nAux][2] , 10]
				lPagDif  := aFaiQtd[ aForEsp[nAux][2] , 12]
				nVlrMaPF := aFaiQtd[ aForEsp[nAux][2] , 13]      
								
				if len(aFaiQtd[aForEsp[nAux][2]]) >= 14
					if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aForEsp[nAux][2], 14]
						nLimFra := aFaiQtd[aForEsp[nAux][2], 15]
					else
						nLimFra := aFaiQtd[aForEsp[nAux][2],9]
					endIf
				else
					nLimFra  := aFaiQtd[aForEsp[nAux][2],9]
				endIf
				
			next

			if lExistia
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF})
			endIf

		endif
	else
		aRetFun := PLSVLDCP(__aNiveis,nNiveis,"BVF",cCodInt+cCodEmp+cMatric+cCodPad,cCodPro,cCodPro,lVerPgAto,;
						lCompra,"CODPSA","VALCOP",dDatPro,dDatAnalise,cFinAte,;
						{|| PLSINTVAL("BVF",'BVF_VIGINI','BVF_VIGFIN',dDatAnalise) })
	
		if aRetFun[1]
			return(aRetFun[2])
		endIf
	endif

endIf

//7 - (BVC) - Familia X Grupo de Cobertura              
if aScan(aPesqTab, "BVC") > 0 .and. ( ! lInterc .or. lChkNvLoc ) .and. (cNivAut == "BFC" .or. lAuditoria .or. lNConsNIV )

	BVC->(dbsetOrder(1)) //BVC_FILIAL, BVC_CODINT, BVC_CODEMP, BVC_MATRIC, BVC_CODGRU, BVC_CODTAB

	if BVC->(FieldPos("BVC_IDAINI")) > 0 .and. BVC->(FieldPos("BVC_IDAFIN")) > 0
		cSql := " SELECT BVC_SOMPRO, BVC_SOMCOM, BVC_TIPO, BVC_PERCOP, BVC_VALCOP, BVC_FINATE, BVC_QTD, BVC_IDAINI, BVC_IDAFIN, "
		cSql += " BVC_CODTAB, BVC_PAGATO, BVC_TXADM, BVC_VALUS, BVC_LIMFRA, BVC_PAGRDA, BVC_ANOMES, BVC_VLRANT, "
	else
		cSql := " SELECT BVC_SOMPRO, BVC_SOMCOM, BVC_TIPO, BVC_PERCOP, BVC_VALCOP, BVC_FINATE, BVC_QTD, "
		cSql += " BVC_CODTAB, BVC_PAGATO, BVC_TXADM, BVC_VALUS, BVC_LIMFRA, BVC_PAGRDA, BVC_ANOMES, BVC_VLRANT, "
	endif
	cSql += " BVC_VIGINI, BVC_VIGFIN FROM " + retSqlName("BVC")
	cSql += " WHERE " 
	cSql += " BVC_FILIAL = '" + xFilial("BVC") + "' "

	if lNConsNIV
		cSql += " AND BVC_CODINT = '" + cCodInt + "' "
		cSql += " AND BVC_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BVC_MATRIC = '" + cMatric + "' "
		cSql += " AND BVC_CODGRU = '" + RIGHT(allTrim(cChvAut) , 3 ) + "' "
	else
		cSql += " AND BVC_CODINT = '" + SubStr(allTrim(cChvAut),1,4) + "' "
		cSql += " AND BVC_CODEMP = '" + SubStr(allTrim(cChvAut),5,4) + "' "
		cSql += " AND BVC_MATRIC = '" + SubStr(allTrim(cChvAut),9,6) + "' "
		cSql += " AND BVC_CODGRU = '" + SubStr(allTrim(cChvAut),15,3) + "' "
	endIf

	cSql += " AND ( '" + dtos(dDatAnalise) + "' >= BVC_VIGINI OR BVC_VIGINI  = '        ' ) "
	cSql += " AND ( '" + dtos(dDatAnalise) + "' <= BVC_VIGFIN OR BVC_VIGFIN = '        ' ) "
	cSql += " AND ( BVC_FINATE = ' ' OR RTRIM(LTRIM(BVC_FINATE)) = '"+allTrim(cFinAte)+"' ) "
	cSQL += " AND ( BVC_TIPO = '3' OR BVC_TIPO = '"+cRegAte+"' ) "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY BVC_FINATE DESC, BVC_QTD ASC"
	
	aFaiQtd := MonQtdCOP(cSql,"PLSTABCOP","BVC",,,,,lCompra,dDatPro,aDadUsr,cFinAte,;
		{ || PLSINTVAL("PLSTABCOP","BVC_VIGINI","BVC_VIGFIN",dDatAnalise) },cRegAte)

	if len(aFaiQtd) > 0
		
		aForEsp := aClone(AnalQtdCO2(aFaiQtd,nfor,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,lMudarFase,"BVC"))
	
		for nAux := 1 to len(aForEsp)

			lExistia := .t.
			cCodTab  := aFaiQtd[ aForEsp[nAux][2] , 3 ]
			nPerCop  += 1 / nQtd *( aForEsp[nAux][1] * aFaiQtd[ aForEsp[nAux][2] ,4 ] )
			nValCop  += 1 / nQtd *( aForEsp[nAux][1] * aFaiQtd[ aForEsp[nAux][2] ,5 ] )
			cPgNoAto := aFaiQtd[ aForEsp[nAux][2] , 6 ]
			nTaxa    := aFaiQtd[ aForEsp[nAux][2] , 7 ]
			nValUS   := aFaiQtd[ aForEsp[nAux][2] , 8 ]
			cAlias   := "BVC"
			cPgDrRDA := aFaiQtd[ aForEsp[nAux][2] , 10]
			lPagDif  := aFaiQtd[ aForEsp[nAux][2] , 12]
			nVlrMaPF := aFaiQtd[ aForEsp[nAux][2] , 13]      
							
			if len(aFaiQtd[aForEsp[nAux][2]]) >= 14
				if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aForEsp[nAux][2], 14]
					nLimFra := aFaiQtd[aForEsp[nAux][2], 15]
				else
					nLimFra := aFaiQtd[aForEsp[nAux][2],9]
				endIf
			else
				nLimFra  := aFaiQtd[aForEsp[nAux][2],9]
			endIf
			
		next

		if lExistia
			return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF})
		endIf

	endif
		
endIf

//8 - (BNX/BNZ) - Subcontrato X Co-Participacao por Horario
if aScan(aPesqTab, "BNZ") > 0

	if ( ! lInterc .or. lChkNvLoc )
	
		BNX->(dbsetOrder(1))
		if BNX->(MsSeek(xFilial("BNX")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub))
			
			while ! BNX->(eof()) .and. BNX->(BNX_FILIAL+BNX_SUBCON) == xFilial("BNX")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub
				
				if 	( cDiaSem == "SEG" .and. BNX->BNX_SEG == "1" ) .or. ;
					( cDiaSem == "TER" .and. BNX->BNX_TER == "1" ) .or. ;
					( cDiaSem == "QUA" .and. BNX->BNX_QUA == "1" ) .or. ;
					( cDiaSem == "QUI" .and. BNX->BNX_QUI == "1" ) .or. ;
					( cDiaSem == "SEX" .and. BNX->BNX_SEX == "1" ) .or. ;
					( cDiaSem == "SAB" .and. BNX->BNX_SAB == "1" ) .or. ;
					( cDiaSem == "DOM" .and. BNX->BNX_DOM == "1" ) .or. ;
					( cDiaSem == "FER" .and. PLSFeriado(dDatPro, .t., cCodRDA, cCodLoc) )
					
					BNZ->(dbsetOrder(1))
					if BNZ->(MsSeek(xFilial("BNZ")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+BNX->BNX_SEQUEN))
						
						while ! BNZ->(eof()) .and. BNZ->(BNZ_FILIAL+BNZ_SUBCON+BNZ_SEQUEN) == xFilial("BNZ")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+BNX->BNX_SEQUEN
							
							if PLSINTVAL("BNZ",'BNZ_VIGINI','BNZ_VIGFIN',dDatAnalise)
								
								//Tratamento para Finalidade de atendimento          
								if !(empTy(BNZ->BNZ_FINATE)) .AND. allTrim(BNZ->BNZ_FINATE) <> allTrim(cFinAte)
									BNZ->(DbSkip())
									loop
								endIf
								
								if ( eval(bCond2,"BNZ") ) .and. ( ( BNZ->BNZ_PERCOP > 0 .or. lValZero ) .or. BNZ->BNZ_VLRCOP > 0 )
								
									if ( cHorPro >= BNZ->BNZ_HORINI .and. cHorPro <= BNZ->BNZ_HORFIN )
								
										if ( BNZ->BNZ_TIPO == "3" .or. BNZ->BNZ_TIPO == cRegAte )
											
											lExistia:= .t.
											cCodTab := subStr(BNZ->BNZ_CODTAB,5,3)
											nPerCop := BNZ->BNZ_PERCOP
											nValCop := BNZ->BNZ_VLRCOP
											nTaxa   := BNZ->BNZ_TXADM
											cPgNoAto:= BNZ->BNZ_PAGATO
											nValUS  := BNZ->BNZ_VALUS
											cPgDrRDA:= ""
											cAlias  := "BNZ"
											return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA})
											
										endIf
										
									endIf
									
								endIf
								
							endIf
							
						BNZ->( dbSkip() )
						endDo
						
					endIf
					
				endIf
				
			BNX->(DbSkip())
			endDo
			
		endIf
		
	endIf

endIf

//9 - (BLW) - Subcontrato Procedimento X Cid...
if aScan(aPesqTab, "BLW") > 0 .and. ( ! lInterc .or. lChkNvLoc )

	cSQL := " SELECT R_E_C_N_O_ REC "
	cSQL += "   FROM " + retSqlName("BLW") 
	cSQL += "  WHERE BLW_FILIAL = '" + xFilial("BLW") + "' AND "
	cSQL += "        BLW_CODINT = '" + cCodInt + "' AND "
	cSQL += "        BLW_CODIGO = '" + cCodEmp + "' AND "
	cSQL += "        BLW_NUMCON = '" + cConEmp + "' AND "
	cSQL += "        BLW_VERCON = '" + cVerCon + "' AND "
	cSQL += "        BLW_SUBCON = '" + cSubCon + "' AND "
	cSQL += "        BLW_VERSUB = '" + cVerSub + "' AND "
	cSQL += "        BLW_CODPRO = '" + cCodPla + "' AND "
	cSQL += "        BLW_VERPRO = '" + cVerPla + "' AND "
	cSQL += "        BLW_CODPAD = '" + cCodPad + "' AND "
	cSQL += "        BLW_CID    = '" + cCid    + "' AND "
	cSQL += "        (BLW_TIPO   = '" + cRegAte + "' OR "
	cSQL += "        BLW_TIPO   = '3') AND "
	cSQL +=  "D_E_L_E_T_ = ' ' "
	cSQL += "        ORDER BY BLW_TIPUSR DESC, BLW_GRAUPA DESC "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
		
	while !PLSAUTPDIR->( eof() )
		
		BLW->( dbGoTo( PLSAUTPDIR->(REC) ) )
	
		if PLSINTVAL("BLW",'BLW_VIGINI','BLW_VIGFIN',dDatAnalise)

			//Tratamento para Finalidade de atendimento
			if !(empTy(BLW->BLW_FINATE)) .AND. allTrim(BLW->BLW_FINATE) <> allTrim(cFinAte)
				PLSAUTPDIR->( dbSkip() )
				loop
			endIf
				
			lExistia := .t.
			cCodTab  := subStr(BLW->BLW_CODTAB,5,3)
			nPerCop  := BLW->BLW_PERCOP
			nValCop  := BLW->BLW_VLRCOP
			cPgNoAto := BLW->BLW_PAGATO
			nTaxa    := BLW->BLW_TXADM
			nValUS   := BLW->BLW_VALUS
			cAlias   := "BLW"
			cPgDrRDA := ""
	
			if subStr(dtos(dDatAnalise),1,6) < BLW->BLW_ANOMES
				nLimFra := BLW->BLW_VLRANT
			else
				nLimFra := BLW->BLW_LIMFRA
			endIf
			
			PLSAUTPDIR->( dbCloseArea() )
				
			return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
			
		endIf
		
	PLSAUTPDIR->( dbSkip() )
	endDo
	
	PLSAUTPDIR->( dbCloseArea() )

endIf

//10 - (BLX) - Subcontrato Procedimento X Especialidade  
if aScan(aPesqTab, "BLX") > 0 .and. ( ! lInterc .or. lChkNvLoc ) // Tratado e testado.
	
	cSQL := " SELECT R_E_C_N_O_ REC "
	cSQL += "   FROM " + retSqlName("BLX") 
	cSQL += "  WHERE BLX_FILIAL = '" + xFilial("BLX") + "' AND "
	cSQL += "        BLX_CODINT = '" + cCodInt + "' AND "
	cSQL += "        BLX_CODIGO = '" + cCodEmp + "' AND "
	cSQL += "        BLX_NUMCON = '" + cConEmp + "' AND "
	cSQL += "        BLX_VERCON = '" + cVerCon + "' AND "
	cSQL += "        BLX_SUBCON = '" + cSubCon + "' AND "
	cSQL += "        BLX_VERSUB = '" + cVerSub + "' AND "
	cSQL += "        BLX_CODPRO = '" + cCodPla + "' AND "
	cSQL += "        BLX_VERPRO = '" + cVerPla + "' AND "
	cSQL += "        BLX_CODPAD = '" + cCodPad + "' AND "
	cSQL += "        BLX_CODPSA = '" + cCodPro + "' AND "
	cSQL += "        BLX_CODESP = '" + cEspec  + "' AND "
	cSQL += "        (BLX_TIPO   = '" + cRegAte + "' OR "
	cSQL += "        BLX_TIPO   = '3') AND "
	cSQL += "        D_E_L_E_T_ = ' ' "
	cSQL += "        ORDER BY BLX_TIPUSR DESC, BLX_GRAUPA DESC, BLX_QTD ASC "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSAUTPDIR",.f.,.t.)

	If !(PLSAUTPDIR->( eof() ))
	
		lExistia := .F.
		lExitBLX := .F.
		nUltFx	  := 0
		nSomaPer := 0
		nsomaval := 0
		nQtdProc := QTDEveCop(1,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,lMudarFase,cEspec) //(nIndice,aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,lMudarFase)
		
		while !PLSAUTPDIR->( eof() )
			
			BLX->( dbGoTo( PLSAUTPDIR->(REC) ) )
			
			if PLSINTVAL("BLX",'BLX_VIGINI','BLX_VIGFIN',dDatAnalise)
	
				//Tratamento para Finalidade de atendimento          
				if !(empTy(BLX->BLX_FINATE)) .AND. allTrim(BLX->BLX_FINATE) <> allTrim(cFinAte)
					PLSAUTPDIR->( dbSkip() )
					loop
				endIf
				
				If nQtdProc > BLX->BLX_QTD
					PLSAUTPDIR->( dbSkip() )
					loop
				endIf
				//pode considerar valores zerados..... porque pode ser uma negativa de co-participacao
				lExistia := .t.
				
				if nQtdProc + nQtd <= BLX->BLX_QTD
					If nUltFx == 0
						nMultXZ  := nQtd
					else
						nMultXZ  := nQtd - ( nUltFx - nQtdProc )
					endIf
					cCodTab  := subStr(BLX->BLX_CODTAB,5,3)
					nSomaPer  += BLX->BLX_PERCOP * nMultXZ
					nsomaval  += BLX->BLX_VLRCOP * nMultXZ
					cPgNoAto := BLX->BLX_PAGATO
					nTaxa    := BLX->BLX_TXADM
					nValUS   := BLX->BLX_VALUS
					cAlias   := "BLX"
					cPgDrRDA := ""
					if subStr(dtos(dDatAnalise),1,6) < BLX->BLX_ANOMES
						nLimFra := BLX->BLX_VLRANT
					else
						nLimFra := BLX->BLX_LIMFRA
					endIf
					lExitBLX := .T.
				else
					nDifZ	:= BLX->BLX_QTD - nQtdProc
					ntotZ	:= nQtd - nDifZ
					//nSomaPer  := BLX->BLX_PERCOP * ntotZ
					//nsomaval  := BLX->BLX_VLRCOP * ntotZ
					nControl := ntotZ
					//PLSAUTPDIR->( dbSkip() )
					while !PLSAUTPDIR->( eof() ) .AND. nControl < nQtd
						BLX->( dbGoTo( PLSAUTPDIR->(REC) ) )
						if !PLSINTVAL("BLX",'BLX_VIGINI','BLX_VIGFIN',dDatAnalise)
							PLSAUTPDIR->( dbSkip() )
							loop
						EndIf
						
						if !(empTy(BLX->BLX_FINATE)) .AND. allTrim(BLX->BLX_FINATE) <> allTrim(cFinAte)
							PLSAUTPDIR->( dbSkip() )
							loop
						endIf
						
						if nQtdProc + nQtd <= BLX->BLX_QTD
							nDifZ	:= nQtd - nControl
							ntotZ	:= nDifZ
						else
							nDifZ	:= BLX->BLX_QTD - nQtdProc - nControl
							ntotZ	:= nQtd - nDifZ - nControl
						endif
						//nDifZ	:= BLX->BLX_QTD - nQtdProc - nControl
						//ntotZ	:= nQtd - nDifZ - nControl
						nSomaPer  += BLX->BLX_PERCOP * ntotZ
						nsomaval  += BLX->BLX_VLRCOP * ntotZ
						nControl  += ntotZ
						
						cCodTab  := subStr(BLX->BLX_CODTAB,5,3)
						cPgNoAto := BLX->BLX_PAGATO
						nTaxa    := BLX->BLX_TXADM
						nValUS   := BLX->BLX_VALUS
						
						if subStr(dtos(dDatAnalise),1,6) < BLX->BLX_ANOMES
							nLimFra := BLX->BLX_VLRANT
						else
							nLimFra := BLX->BLX_LIMFRA
						endIf
						
						If !(nControl < nQtd)
							PLSAUTPDIR->( dbSkip() )
						EndIf
					EndDo
					
					nUltFx	  := BLX->BLX_QTD
					//nPerCop  := nSomaPer / nQtd
					//nValCop  := nsomaval / nQtd

					cAlias   := "BLX"
					cPgDrRDA := ""
					
				EndIf
				
				nPerCop  := nSomaPer / nQtd
				nValCop  := nsomaval / nQtd

				If lExitBLX
					exit
				endIf
				//PLSAUTPDIR->( dbCloseArea() )
				
				//return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
			endIf
			
			PLSAUTPDIR->( dbSkip() )
		endDo
		PLSAUTPDIR->( dbCloseArea() )
		If lExistia
			return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
		endIf
	else
		PLSAUTPDIR->( dbCloseArea() )
	endIf

endIf

//11 - (BGL) - Subcontrato Municipio X Procedimento        
BGL->(dbsetOrder(1))//BGL_FILIAL, BGL_CODINT, BGL_CODIGO, BGL_NUMCON, BGL_VERCON, BGL_SUBCON, BGL_VERSUB, BGL_CODPRO, BGL_VERPRO, BGL_CODMUN, BGL_CODPAD, BGL_CDPROC

if aScan(aPesqTab, "BGL") > 0 .and. ( ! lInterc .or. lChkNvLoc )  // tratado - testado.

	cSQL := " SELECT R_E_C_N_O_ REC "
	cSQL += "   FROM " + retSqlName("BGL") 
	cSQL += "  WHERE BGL_FILIAL = '" + xFilial("BGL") + "' AND "
	cSQL += "        BGL_CODINT = '" + cCodInt + "' AND "
	cSQL += "        BGL_CODIGO = '" + cCodEmp + "' AND "
	cSQL += "        BGL_NUMCON = '" + cConEmp + "' AND "
	cSQL += "        BGL_VERCON = '" + cVerCon + "' AND "
	cSQL += "        BGL_SUBCON = '" + cSubCon + "' AND "
	cSQL += "        BGL_VERSUB = '" + cVerSub + "' AND "
	cSQL += "        BGL_CODPRO = '" + cCodPla + "' AND "
	cSQL += "        BGL_VERPRO = '" + cVerPla + "' AND "
	cSQL += "        BGL_CODMUN = '" + cMunAte + "' AND "
	cSQL += "        ( BGL_CODPAD = '" + cCodPad + "' OR "
	cSQL += "        BGL_CODPAD = '" + space(tamsx3("BGL_CODPAD")[1]) + "') AND "
	cSQL += "        (BGL_CDPROC = '" + cCodPro  + "' OR "
	cSQL += "        BGL_CDPROC = '" + space(tamsx3("BGL_CDPROC")[1])  + "') AND "
	cSQL += "        (BGL_TIPO   = '" + cRegAte + "' OR "
	cSQL += "        BGL_TIPO   = '3') AND "
	cSQL += "        D_E_L_E_T_ = ' ' "
	
	cSQL += "        ORDER BY BGL_TIPUSR DESC, BGL_GRAUPA DESC "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
		
	while !PLSAUTPDIR->( eof() )
		
		BGL->( dbGoTo( PLSAUTPDIR->(REC) ) )

		if PLSINTVAL("BGL",'BGL_VIGINI','BGL_VIGFIN',dDatAnalise)

			if !(empTy(BGL->BGL_FINATE)) .AND. allTrim(BGL->BGL_FINATE) <> allTrim(cFinAte)
				PLSAUTPDIR->(DbSkip())
				loop
			endIf
			
			if ( BGL->BGL_PERCOP > 0 .or. lValZero ) .or. BGL->BGL_VALCOP > 0						
					
				if nQtd <= BGL->BGL_QTD
  
					lExistia := .t.
					cCodTab  := subStr(BGL->BGL_CODTAB,5,3)
					nPerCop  := BGL->BGL_PERCOP
					nValCop  := BGL->BGL_VALCOP
					cPgNoAto := BGL->BGL_PAGATO
					nTaxa    := BGL->BGL_TXADM
					nValUS   := BGL->BGL_VALUS
					cAlias   := "BGL"
					cPgDrRDA := ""
				
					if subStr(dtos(dDatAnalise),1,6) < BGL->BGL_ANOMES
						nLimFra := BGL->BGL_VLRANT
					else
						nLimFra := BGL->BGL_LIMFRA
					endIf
					
					PLSAUTPDIR->( dbCloseArea() )
					
					return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
					
				endIf
				
			endIf
			
		endIf
		
	PLSAUTPDIR->(dbSkip())
	endDo
	
	PLSAUTPDIR->( dbCloseArea() )
	
endIf

//12 - (BHE) - Subcontrato X Produto X Procedimento       
if aScan(aPesqTab, "BHE") > 0 .and. (! lInterc .or. lChkNvLoc)

	cSQL := "SELECT BHE_QTD,BHE_LIMFRA,BHE_PAGATO, BT8_CODPSA, BHE_CODTAB, BHE_PERCOP, "
	cSQL += " BHE_PAGRDA,BHE_TIPUSR, BHE_FINATE, BHE_VIGINI, BHE_VIGFIN, BHE_ANOMES, BHE_VLRANT, "
   	cSQL += " BHE_VLRCOP, BHE_TXADM, BHE_VALUS, BHE_SOMCOM, BHE_TIPO, BHE_IDAINI, BHE_IDAFIN FROM "+cNameBHE+", "+cNameBT8
	cSQL += " WHERE "
	cSQL += "BHE_FILIAL = '"+xFilial("BHE")+"' AND "
	cSQL += "BHE_CODINT = '"+cCodInt+"' AND "
	cSQL += "BHE_CODIGO = '"+cCodEmp+"' AND "
	cSQL += "BHE_NUMCON = '"+cConEmp+"' AND "
	cSQL += "BHE_VERCON = '"+cVerCon+"' AND "
	cSQL += "BHE_SUBCON = '"+cSubCon+"' AND "
	cSQL += "BHE_VERSUB = '"+cVerSub+"' AND "
	cSQL += "BHE_CODPRO = '"+cCodPla+"' AND "
	cSQL += "BHE_VERPRO = '"+cVerPla+"' AND "
	cSQL += "BHE_CODPAD = '"+cCodPad+"' AND "
	cSQL += "BHE_CODPSA = BT8_CODPSA AND   "
	cSQL += cNameBHE+".D_E_L_E_T_ = ' ' AND "
	cSQL += "BT8_CODINT = BHE_CODINT AND "
	cSQL += "BT8_CODIGO = BHE_CODIGO AND "
	cSQL += "BT8_NUMCON = BHE_NUMCON AND "
	cSQL += "BT8_VERCON = BHE_VERCON AND "
	cSQL += "BT8_SUBCON = BHE_SUBCON AND "
	cSQL += "BT8_VERSUB = BHE_VERSUB AND "
	cSQL += "BT8_CODPSA = BHE_CODPSA AND "
	cSQL += "BT8_CODPAD = BHE_CODPAD AND "
	cSQL += "BT8_CODPRO = BHE_CODPRO AND "
	cSQL += "BT8_VERPRO = BHE_VERPRO AND "
	
	if lCompra
		cSQL += "BHE_SOMCOM = '1' AND "
	else
		cSQL += "BHE_SOMCOM <> '1' AND "
	endIf
	
	if ! empty(cGrpInt)
		cSQL += "( BHE_GRPINT = '"+cGrpInt+"' OR BHE_GRPINT = '"+Space(len(BHE->BHE_GRPINT))+"' ) AND "
	endIf
	
	cSQL += PLREQNI("BT8", "BT8_CODPSA", __aNiveis[2], allTrim(cCodPro))
	
	cSQL += "( BHE_TIPO = '3' OR BHE_TIPO = '"+cRegAte+"' ) AND "
	
	cSQL += cNameBT8+".D_E_L_E_T_ = ' '"
	     
	cSQL += " ORDER BY BT8_NIVEL DESC, BHE_TIPUSR DESC, BHE_GRAUPA DESC"
	
	//Verifico a quantidade para este nivel de copart        
	aFaiQtd := MonQtdCOP(cSQL,"PLSTABCOP","BHE",,,,,lCompra,dDatPro,aDadUsr,cFinAte,;
							{ || PLSINTVAL("PLSTABCOP","BHE_VIGINI","BHE_VIGFIN",dDatAnalise) },cRegAte)
	
	if len(aFaiQtd) > 0
		
		aforEsp := aClone(AnalQtdCO2(aFaiQtd,nfor,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,nil,lMudarFase,"BHF"))

		for nAux:= 1 to len(aforEsp)
		
			lExistia := .t.
			
			cCodTab  := aFaiQtd[ aforEsp[nAux][2] , 3 ]
			nPerCop  += 1/nQtd * ( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,4 ] )
			nValCop  += 1/nQtd * ( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,5 ] )
			cPgNoAto := aFaiQtd[ aforEsp[nAux][2] , 6 ]
			nTaxa    := aFaiQtd[ aforEsp[nAux][2] , 7 ]
			nValUS   := aFaiQtd[ aforEsp[nAux][2] , 8 ]
			cAlias   := "BHE"
			cPgDrRDA := ""
			
			// Franquia...
			if len(aFaiQtd[aforEsp[nAux][2]]) >= 14
				if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aforEsp[nAux][2], 14]
					nLimFra := aFaiQtd[aforEsp[nAux][2], 15]
				else
					nLimFra := aFaiQtd[aforEsp[nAux][2],9]
				endIf
			else
				nLimFra  := aFaiQtd[aforEsp[nAux][2],9]
			endIf
		next
		
		if lExistia
			return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
		endIf
		
	endIf

endIf

//13 - (BGS) - Subcontrato X Tipo de Prestador          
if aScan(aPesqTab, "BGS") > 0 .and. (! lInterc .or. lChkNvLoc)

	cSQL := " SELECT R_E_C_N_O_ REC "
	cSQL += "   FROM " + retSqlName("BGS") 
	cSQL += "  WHERE BGS_FILIAL = '" + xFilial("BGL") + "' AND "
	cSQL += "        BGS_CODINT = '" + cCodInt + "' AND "
	cSQL += "        BGS_CODIGO = '" + cCodEmp + "' AND "
	cSQL += "        BGS_NUMCON = '" + cConEmp + "' AND "
	cSQL += "        BGS_VERCON = '" + cVerCon + "' AND "
	cSQL += "        BGS_SUBCON = '" + cSubCon + "' AND "
	cSQL += "        BGS_VERSUB = '" + cVerSub + "' AND "
	cSQL += "        BGS_CODPRO = '" + cCodPla + "' AND "
	cSQL += "        BGS_VERPRO = '" + cVerPla + "' AND "
	cSQL += "        BGS_TIPPRE = '" + cTipPre + "' AND "
	cSQL += "        D_E_L_E_T_ = ' ' "
	cSQL += "        ORDER BY BGS_TIPUSR DESC, BGS_GRAUPA DESC "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSAUTPDIR",.f.,.t.)
	
	While !PLSAUTPDIR->( eof() )
		
		BGS->( dbGoTo( PLSAUTPDIR->(REC) ) )
			
		if PLSINTVAL("BGS",'BGS_VIGINI','BGS_VIGFIN',dDatAnalise)
		
			if ! empTy(BGS->BGS_TIPUSR) .and. BGS->BGS_TIPUSR <> aDadUsr[82]
				PLSAUTPDIR->(dbSkip())
				loop
			endIf

			// Tratamento da finalidade de atendimento
			if  ! empty(BGS->BGS_FINATE) .AND. allTrim(BGS->BGS_FINATE) <> allTrim(cFinAte)
				PLSAUTPDIR->(dbSkip())
				loop
			endIf
								
			if nQtd <= BGS->BGS_QTD
		
				if ( eval(bCond2,"BGS") ) .and. ( ( BGS->BGS_PERCOP > 0 .or. lValZero )  .or. BGS->BGS_VLRCOP > 0 ) .and. ( BGS->BGS_TIPO == "3" .or. BGS->BGS_TIPO == cRegAte )
					
					lExistia:= .t.
					cCodTab := subStr(BGS->BGS_CODTAB,5,3)
					nPerCop := BGS->BGS_PERCOP
					nValCop := BGS->BGS_VLRCOP
					nTaxa   := BGS->BGS_TXADM
					cPgNoAto:= BGS->BGS_PAGATO
					nValUS  := BGS->BGS_VALUS
					cAlias  := "BGS"
					cPgDrRDA:= ""
					
					if subStr(dtos(dDatAnalise),1,6) < BGS->BGS_ANOMES
						nLimFra := BGS->BGS_VLRANT
					else
						nLimFra := BGS->BGS_LIMFRA
					endIf
					
					PLSAUTPDIR->( dbCloseArea() )
					return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})

				endIf

			endIf

		endIf
			
	PLSAUTPDIR->(dbSkip())
	endDo

	PLSAUTPDIR->( dbCloseArea() )

endIf

//14 - (BHF) - Subcontrato X Grupo de Cobertura        
if aScan(aPesqTab, "BHF") > 0 .and. ( ! lInterc .or. lChkNvLoc ) .and. ( cNivAut == "BT7" .or. lAuditoria .or. lNConsNIV )

	BHF->(dbsetOrder(1))
	cSql := " SELECT R_E_C_N_O_ RECNO FROM " + retSqlName("BHF")
	cSql += " WHERE "
	cSql += " BHF_FILIAL = '" + xFilial("BHF") + "' "

	if lNConsNIV
		cSql += " AND BHF_CODINT = '" + cCodInt + "' "
		cSql += " AND BHF_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BHF_NUMCON = '" + cConEmp + "' "
		cSql += " AND BHF_VERCON = '" + cVerCon + "' "
		cSql += " AND BHF_SUBCON = '" + cSubCon + "' "
		cSql += " AND BHF_VERSUB = '" + cVerSub + "' "
		cSql += " AND BHF_CODPRO = '" + cCodPla + "' "
		cSql += " AND BHF_VERPRO = '" + cVerPla + "' "
		cSql += " AND BHF_CODGRU = '" + RIGHT(allTrim(cChvAut) , 3  )  + "' "
	else
		cSql += " AND BHF_CODINT = '" + SubStr(allTrim(cChvAut), 01, 04 ) + "' "
		cSql += " AND BHF_CODIGO = '" + SubStr(allTrim(cChvAut), 05, 04 ) + "' "
		cSql += " AND BHF_NUMCON = '" + SubStr(allTrim(cChvAut), 09, 12 ) + "' "
		cSql += " AND BHF_VERCON = '" + SubStr(allTrim(cChvAut), 21, 03 ) + "' "
		cSql += " AND BHF_SUBCON = '" + SubStr(allTrim(cChvAut), 24, 09 ) + "' "
		cSql += " AND BHF_VERSUB = '" + SubStr(allTrim(cChvAut), 33, 03 ) + "' "
		cSql += " AND BHF_CODPRO = '" + SubStr(allTrim(cChvAut), 36, 04 ) + "' "
		cSql += " AND BHF_VERPRO = '" + SubStr(allTrim(cChvAut), 40, 03 ) + "' "
		cSql += " AND BHF_CODGRU = '" + SubStr(allTrim(cChvAut), 43, 03 ) + "' "
	endif
	cSql += " AND ( '" + dtos(dDatAnalise) + "' >= BHF_VIGINI OR BHF_VIGINI  = '        ' ) "
	cSql += " AND ( '" + dtos(dDatAnalise) + "' <= BHF_VIGFIN OR BHF_VIGFIN = '        ' ) "
	cSql += " AND ( BHF_FINATE = ' ' OR RTRIM(LTRIM(BHF_FINATE)) = '"+allTrim(cFinAte)+"' ) "
	cSQL += " AND ( BHF_TIPO = '3' OR BHF_TIPO = '"+cRegAte+"' ) "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY BHF_FINATE DESC, BHF_QTD ASC "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSBHF",.f.,.t.)
	while ! PLSBHF->(eof())       
		BHF->(dbgoto(PLSBHF->RECNO)) 

		cChave := BHF->(BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB+BHF_CODPRO+BHF_VERPRO+BHF_CODGRU)

		// Novo paramentro cFinAte = Tratamento da finalidade de Atendimento.
		aFaiQtd := MonQtdCOP("","","BHF",.f.,;
						"'"+xFilial("BHF")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPla+cVerPla +BHF->BHF_CODGRU+"' == BHF->(BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB+BHF_CODPRO+BHF_VERPRO+BHF_CODGRU)",;
						'(BHF->BHF_SOMPRO == "1" .and. BR8->BR8_TPPROC $ "0,6") .or. BHF->BHF_SOMPRO <> "1" ',;
						{ || cChave == xFilial("BHF")+allTrim(cChvAut) },lCompra,dDatPro,aDadUsr,cFinAte,;
						{ || PLSINTVAL("BHF","BHF_VIGINI","BHF_VIGFIN",dDatAnalise) },cRegAte)

		if len(aFaiQtd) > 0

			aforEsp := AnalQtdCO2(aFaiQtd,1,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,nil,lMudarFase,"BHF")

			for nAux := 1 to len(aforEsp)

				lExistia := .t.
				cCodTab  := aFaiQtd[ aforEsp[nAux][2] , 3 ]
				nPerCop  += 1 / nQtd *( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,4 ] )
				nValCop  += 1 / nQtd *( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,5 ] )
				cPgNoAto := aFaiQtd[ aforEsp[nAux][2] , 6 ]
				nTaxa    := aFaiQtd[ aforEsp[nAux][2] , 7 ]
				nValUS   := aFaiQtd[ aforEsp[nAux][2] , 8 ]
				cAlias   := "BHF"
				cPgDrRDA := aFaiQtd[ aforEsp[nAux][2] , 10]
				lPagDif  := aFaiQtd[ aforEsp[nAux][2] , 12]
				nVlrMaPF := aFaiQtd[ aforEsp[nAux][2] , 13]      
								
				if len(aFaiQtd[aforEsp[nAux][2]]) >= 14
					
					if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aforEsp[nAux][2], 14]
						nLimFra := aFaiQtd[aforEsp[nAux][2], 15]
					else
						nLimFra := aFaiQtd[aforEsp[nAux][2],9]
					endIf
					
				else
					nLimFra  := aFaiQtd[aforEsp[nAux][2],9]
				endIf
				
			next

			if lExistia
				PLSBHF->(DBCloseArea())
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF})
			endIf

		endIf
		PLSBHF->(dbSkip())
	enddo
	PLSBHF->(DBCloseArea())
endIf

//15 - (BOR) - Subcontrato x rede de atendimento x cobranca de co-participacao 
if aScan(aPesqTab, "BOR") > 0 

	BOR->(dbsetOrder(1))
	if ( ! lInterc .or. lChkNvLoc ) .and. BOR->(MsSeek(xFilial("BOR")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA))
	
		if BOR->BOR_BLOCOP <> "1"
			
			while !BOR->( eof() ) .and. BOR->(BOR_CODINT+BOR_CODEMP+BOR_NUMCON+BOR_VERCON+BOR_SUBCON+BOR_VERSUB+BOR_CODCRE) == cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA
									
				//Se a vigencia estiver dentro do limite parametrizado...			     
				if PLSINTVAL("BOR","BOR_VIGDE","BOR_VIGATE",dDatAnalise)

					if ( eval(bCond2,"BOR") ) .and. ( ( BGS->BGS_PERCOP > 0 .or. lValZero )  .or. BGS->BGS_VLRCOP > 0 )
									
						// Tratamento da finalidade de atendimento
						if !(empTy(BOR->BOR_FINATE)) .AND. allTrim(BOR->BOR_FINATE) <> allTrim(cFinAte)
							BOR->(DbSkip())
							loop
						endIf				
				
						lExistia:= .t.
						cCodTab := subStr(BOR->BOR_CODTAB,5,3)
						nPerCop := BOR->BOR_PERCOP
						nValCop := BOR->BOR_VALCOP
						nTaxa   := BOR->BOR_TXADM
						cPgNoAto:= BOR->BOR_PAGATO
						nValUS  := BOR->BOR_VALUS
						cAlias  := "BOR"
						cPgDrRDA:= ""
						
						if BOR->( fieldPos("BOR_ANOMES") ) > 0 .and. BOR->( fieldPos("BOR_VLRANT") ) > 0
							
							if subStr(dtos(dDatAnalise),1,6) < BOR->BOR_ANOMES
								nLimFra := BOR->BOR_VLRANT
							else	
								nLimFra := BOR->BOR_LIMFRA
							endIf
							
						else
							nLimFra := BOR->BOR_LIMFRA
						endIf
						
						return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
					endIf
				endIf
				
			BOR->( dbSkip() )
			endDo
		endIf
	endIf

endIf

//16 - (BHG) - Subcontrato X Produto                    
if aScan(aPesqTab, "BHG") > 0 .and. (! lInterc .or. lChkNvLoc)

	// BHG->(dbsetOrder(1))//BHG_FILIAL, BHG_CODINT, BHG_CODIGO, BHG_NUMCON, BHG_VERCON, BHG_SUBCON, BHG_VERSUB, BHG_CODPRO, BHG_VERPRO

	cSql := " SELECT R_E_C_N_O_ RECNO FROM " + retSqlName("BHG")
	cSql += " WHERE "
	cSql += " BHG_FILIAL = '" + xFilial("BHG") + "' "
	cSql += " AND BHG_CODINT = '" + cCodInt + "' "
	cSql += " AND BHG_CODIGO = '" + cCodEmp + "' "
	cSql += " AND BHG_NUMCON = '" + cConEmp + "' "
	cSql += " AND BHG_VERCON = '" + cVerCon + "' "
	cSql += " AND BHG_SUBCON = '" + cSubCon + "' "
	cSql += " AND BHG_VERSUB = '" + cVerSub + "' "
	cSql += " AND BHG_CODPRO = '" + cCodPla + "' "
	cSql += " AND BHG_VERPRO = '" + cVerPla + "' "
	cSQL += " AND ( '" + dtos(dDatAnalise) + "' >= BHG_VIGINI OR BHG_VIGFIN  = ' ' ) "
	cSQL += " AND ( '" + dtos(dDatAnalise) + "' <= BHG_VIGFIN OR BHG_VIGFIN = ' ' ) "
	cSql += " AND ( BHG_FINATE = ' ' OR RTRIM(LTRIM(BHG_FINATE)) = '"+allTrim(cFinAte)+"' ) "
	cSQL += " AND ( BHG_TIPO = '3' OR BHG_TIPO = '"+cRegAte+"' ) "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY BHG_VIGINI "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"PLSBHG",.f.,.t.)
	
	while ! PLSBHG->(eof())

		BHG->(dbgoto(PLSBHG->RECNO))
																	
		if nQtd <= BHG->BHG_QTD
		
			if BHG->BHG_VERPRO <> cVerPla
				PLSBHG->(DbSkip())
				loop
			endIf
					
			// Tratamento para Finalidade de atendimento          
			if !(EmpTy(BHG->BHG_FINATE)) .AND.  allTrim(BHG->BHG_FINATE) <> allTrim(cFinAte)
				PLSBHG->(DbSkip())
				loop
			endIf

			//Tratamento para tipo de usuario                    
			if ! empty(BHG->BHG_TIPUSR) .and. len(aDadUsr) >= 82 .and. BHG->BHG_TIPUSR <> aDadUsr[82]
				PLSBHG->(DbSkip())
				loop
			endIf
			
			// Tratamento da regra de material e medicamento      
			lFlag := .t.
			//Se a co-participacao for cadastrada somente para     
			//procedimentos e o item nao for um procedimento nem   
			//verifico os percentuais						         
			if BHG->BHG_SOMPRO == "1" .and. !(BR8->BR8_TPPROC $ "0,6")
				lFlag := .f.
			endIf
			
			//Tratamento da regra de considera tab padrao        
			if  BHG->BHG_CONSTB == "1" .and. BR8->BR8_COBPAR <> "1"
				lFlag := .f.
			endIf
				
			if ( eval(bCond2,"BHG") ) .and. ( ( BHG->BHG_PERCOP > 0 .or. lValZero ) .or. BHG->BHG_VLRCOP > 0 ) .and. ( BHG->BHG_TIPO == "3" .or. BHG->BHG_TIPO == cRegAte ) .and. lFlag
					
				lExistia:= .t.
				cCodTab := subStr(BHG->BHG_CODTAB,5,3)
				nPerCop := BHG->BHG_PERCOP
				nValCop := BHG->BHG_VLRCOP
				nTaxa   := BHG->BHG_TXADM
				cPgNoAto:= BHG->BHG_PAGATO
				nValUS  := BHG->BHG_VALUS
				cAlias  := "BHG"
						
				if subStr(dtos(dDatAnalise),1,6) < BHG->BHG_ANOMES
					nLimFra := BHG->BHG_VLRANT
				else
					nLimFra := BHG->BHG_LIMFRA
				endIf
						
				cPgDrRDA:= BHG->BHG_PAGRDA
				
				PLSBHG->(dbCloseArea())
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
			endIf
		endIf
		
	PLSBHG->( dbSkip() )
	endDo

	PLSBHG->(dbCloseArea())
endIf

//17 - (BS9) - Subcontrato X Unidade			         
if aScan(aPesqTab, "BS9") > 0 .and. ( ! lInterc .or. lChkNvLoc )

	cSql := "SELECT BS9_CODTAB,BS9_PERCOP,BS9_VALCOP,BS9_TXADM,BS9_PAGATO,BS9_VALUS, "
	cSql += "       BS9_LIMFRA,BS9_VIGDE,BS9_VIGATE,BS9_FINATE "

	if lBS9_ANOMES .and. lBS9_VLRANT
		cSql += " ,BS9_ANOMES,BS9_VLRANT "
	endIf
	
	cSql += "  FROM " + retSqlName("BS9")
	cSql += " WHERE BS9_FILIAL = '" + xFilial("BS9") + "' "
	cSql += "   AND BS9_SUBCON = '" + cCodInt + cCodEmp + cConEmp + cVerCon + cSubCon + cVerSub + "' "
	cSql += "   AND BS9_CODUNI = '" + cCodUnm + "' "
	cSql += "   AND D_E_L_E_T_ = ' ' "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"TRBBS9",.f.,.t.)
  	
  	if !TRBBS9->(eof())
 		plsTField("TRBBS9",.f.,{ "BS9_VIGDE","BS9_VIGATE","BS9_PERCOP","BS9_VALCOP","BS9_TXADM","BS9_VALUS","BS9_VLRANT","BS9_LIMFRA" } )
 	endIf
 	
  	while !TRBBS9->( eof() )
	
		//Se a vigencia estiver dentro do limite parametrizado...			   
		if PLSINTVAL("TRBBS9","BS9_VIGDE","BS9_VIGATE",dDatAnalise)				
		
			if ( eval(bCond2,"BS9") ) .and. ( TRBBS9->BS9_PERCOP > 0 .or. lValZero )
				
				//Tratamento para Finalidade de atendimento          
				if !(empTy(TRBBS9->BS9_FINATE)) .AND. allTrim(TRBBS9->BS9_FINATE) <> allTrim(cFinAte)
					TRBBS9->(DbSkip())
					loop
				endIf		
		
				lExistia:= .t.
				cCodTab := subStr(TRBBS9->BS9_CODTAB,5,3)
				nPerCop := TRBBS9->BS9_PERCOP
				nValCop := TRBBS9->BS9_VALCOP
				nTaxa   := TRBBS9->BS9_TXADM
				cPgNoAto:= TRBBS9->BS9_PAGATO
				nValUS  := TRBBS9->BS9_VALUS
				cAlias  := "BS9"
				cPgDrRDA:= ""
		
				if lBS9_ANOMES .and. lBS9_VLRANT
					
					if subStr(dtos(dDatAnalise),1,6) < TRBBS9->BS9_ANOMES
						nLimFra := TRBBS9->BS9_VLRANT
					else
						nLimFra := TRBBS9->BS9_LIMFRA
					endIf
					
				else
					nLimFra := TRBBS9->BS9_LIMFRA
				endIf
			                     
				TRBBS9->( dbCloseArea() )
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
			endIf
		endIf
		
	TRBBS9->( dbSkip() )
	endDo
	
	TRBBS9->( dbCloseArea() )

endIf						

//18 - (BYK) - Produto X Propriedades p/ Grp de Internacao
if aScan(aPesqTab, "BYK") > 0 .and. (! lInterc .or. lChkNvLoc)

	//Se neste prod existe o conceito					 
	BQR->(dbsetOrder(2))
	if !empty(cGrpInt) .and. BQR->(MsSeek(xFilial("BQR")+cGrpInt))		
		
		//Verifico se para este grp de internacao existe a	 
		//algum procedimento relacionado						 
		for nfor := 1 to (nNiveis+2)
			
			if nfor == 1
				
				cChave  := xFilial("BYK")+cCodInt+cCodPla+cVerPla+cGrpInt+cCodPad+cCodPro
				
			elseIf nfor <= nNiveis
			
				cCodAux := subStr(cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])
				cChave  := xFilial("BYK")+cCodInt+cCodPla+cVerPla+cGrpInt+cCodPad+cCodAux
			
			elseIf nfor == (nNiveis+1)
			
				cChave  := xFilial("BYK")+cCodInt+cCodPla+cVerPla+cGrpInt+cCodPad+Space(len(cCodPro))
				                                                             
			elseIf nfor == (nNiveis+2)
			
				cChave  := xFilial("BYK")+cCodInt+cCodPla+cVerPla+cGrpInt+Space(len(cCodPad))+Space(len(cCodPro))					
				
			endIf
			
			BYK->(dbsetOrder(2))
			if BYK->(MsSeek(cChave))

				//crio o aFaiQtd via Seek					    		
				aFaiQtd := aClone(MonQtdCOP("","","BYK",.f.,;
											"'"+cChave+"' == BYK->(BYK_FILIAL+BYK_CODIGO+BYK_VERSAO+BYK_GRPINT+BYK_TIPINT+BYK_CODPAD+BYK_CODPSA)",;
											,,,dDatPro,aDadUsr,cFinAte,{ || PLSINTVAL("BYK","BYK_VIGDE","BYK_VIGATE",dDatAnalise) },cRegAte))
				
				if len(aFaiQtd) > 0
					
					aforEsp := aClone(AnalQtdCO2(aFaiQtd,nfor,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,nil,lMudarFase,"BYK"))
					
					for nAux:= 1 to len(aforEsp)
						lExistia := .t.
                             
						cCodTab  := aFaiQtd[ aforEsp[nAux][2] , 3 ]
						nPerCop  += 1/nQtd*( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,4 ] )
						nValCop  += 1/nQtd*( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,5 ] )
						cPgNoAto := aFaiQtd[ aforEsp[nAux][2] , 6 ]
						nTaxa    := aFaiQtd[ aforEsp[nAux][2] , 7 ]
						nValUS   := aFaiQtd[ aforEsp[nAux][2] , 8 ]
						cAlias   := "BYK"
						cPgDrRDA := ""
						
						// Franquia...
						if len(aFaiQtd[aforEsp[nAux][2]]) >= 14
							if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aforEsp[nAux][2], 14]
								nLimFra := aFaiQtd[aforEsp[nAux][2], 15]
							else
								nLimFra := aFaiQtd[aforEsp[nAux][2],9]
							endIf
						else
							nLimFra  := aFaiQtd[aforEsp[nAux][2],9]
						endIf
						
					next
					if lExistia
						return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
					endIf
				endIf
			endIf
			
		next
		
	endIf
	
	//Se neste prod existe o conceito					 
	BYK->(dbsetOrder(2))
	if BYK->(MsSeek(xFilial("BYK")+cCodInt+cCodPla+cVerPla+cGrpInt)) .and. !empty(cGrpInt)
		
		cSQL := "SELECT BYK_QTD,BYK_LIMFRA,BYK_PAGATO,BYK_CODTAB,BYK_PERCOP,BYK_PAGRDA, "
       	cSQL += " BYK_ANOMES, BYK_VLRANT, "
        cSQL += " BYK_TIPUSR, "
        cSQL += " BYK_FINATE, "
        
		cSQL += " BYK_VLRCOP,BYK_TXADM,BYK_VALUS,BYK_SOMCOM, BYK_TIPO, "
		cSQL += " BYK_IDAINI, BYK_IDAFIN FROM "+cNameBYK+" "
		cSQL += "WHERE BYK_FILIAL = '" + xFilial("BYK") + "' AND "
		cSQL += "BYK_CODIGO = '" + cCodInt+cCodPla + "' AND "
		cSQL += "BYK_VERSAO = '" + cVerPla + "' AND "
		cSQL += "BYK_GRPINT = '" + subStr(cGrpInt,1,1) + "' AND "
		cSQL += "BYK_TIPINT = '" + subStr(cGrpInt,2,2) + "' AND "
		cSQL += "BYK_CODPAD = '" + cCodPad + "' AND "
		
		cSQL += PLREQNI("BYK", "BYK_CODPSA", __aNiveis[2], allTrim(cCodPro))
		
		if lCompra
			cSQL += "BYK_SOMCOM = '1' AND "
		else
			cSQL += "BYK_SOMCOM <> '1' AND "
		endIf

		cSQL += cNameBYK+".D_E_L_E_T_ = ' ' AND "
		
		cSQL += "(BYK_CODDOE ='" + cCid + "'"
		cSQL += " OR (BYK_CDCD01='"+ subStr(cCid,1,aTmp[1]) +"' AND BYK_NIVCID = '1')      "
		cSQL += " OR (BYK_CDCD02='"+ subStr(cCid,1,aTmp[2]) +"' AND BYK_NIVCID = '2')      "
		cSQL += " OR (BYK_CDCD03='"+ subStr(cCid,1,aTmp[3]) +"' AND BYK_NIVCID = '3')      "
		cSQL += " OR (BYK_CDCD04='"+ subStr(cCid,1,aTmp[4]) +"' AND BYK_NIVCID = '4')      "
		cSQL += " OR (BYK_CDCD05='"+ subStr(cCid,1,aTmp[5]) +"' AND BYK_NIVCID = '5')) AND "
		
		cSQL += "( BYK_TIPO = '3' OR BYK_TIPO = '"+cRegAte+"' )"
		
		cSQL +=  " ORDER BY BYK_NIVEL DESC, BYK_QTD ASC "
		
		aFaiQtd := MonQtdCOP(cSQL,"PLSRETBYK","BYK",,,,,,dDatPro,aDadUsr,cFinAte,;
							{ || PLSINTVAL("PLSRETBYK","BYK_VIGDE","BYK_VIGATE",dDatAnalise) },cRegAte)
		
		if len(aFaiQtd) > 0
			
			aforEsp := AnalQtdCO2(aFaiQtd,nfor,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,nil,lMudarFase,"BYK")
			
			for nAux:= 1 to len(aforEsp)
			
				lExistia := .t.

				cCodTab  := aFaiQtd[ aforEsp[nAux][2] , 3 ]
				nPerCop  += 1/nQtd*( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,4 ] )
				nValCop  += 1/nQtd*( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,5 ] )
				cPgNoAto := aFaiQtd[ aforEsp[nAux][2] , 6 ]
				nTaxa    := aFaiQtd[ aforEsp[nAux][2] , 7 ]
				nValUS   := aFaiQtd[ aforEsp[nAux][2] , 8 ]
				cAlias   := "BYK"
				cPgDrRDA := ""

				// Franquia...
				if len(aFaiQtd[aforEsp[nAux][2]]) >= 14
					if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aforEsp[nAux][2], 14]
						nLimFra := aFaiQtd[aforEsp[nAux][2], 15]
					else
						nLimFra := aFaiQtd[aforEsp[nAux][2],9]
					endIf
				else
					nLimFra  := aFaiQtd[aforEsp[nAux][2],9]
				endIf
										
			next
			
			if lExistia
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
			endIf
			
		endIf

		cSQL := "SELECT BYK_QTD,BYK_LIMFRA,BYK_PAGATO,BYK_CODTAB,BYK_PERCOP,BYK_PAGRDA, "
		cSQL += " BYK_TIPUSR, "
        cSQL += " BYK_FINATE, "
               
		cSQL += "BYK_VLRCOP,BYK_TXADM,BYK_VALUS,BYK_SOMCOM, BYK_TIPO "
		cSQL += " BYK_IDAINI, BYK_IDAFIN FROM "+cNameBYK+" "
		cSQL += "WHERE BYK_FILIAL = '" + xFilial("BYK") + "' AND "
		cSQL += "BYK_CODIGO = '" + cCodInt+cCodPla + "' AND "
		cSQL += "BYK_VERSAO = '" + cVerPla + "' AND "
		cSQL += "BYK_GRPINT = '" + subStr(cGrpInt,1,1) + "' AND "
		cSQL += "BYK_TIPINT = '" + subStr(cGrpInt,2,2) + "' AND "
		cSQL += "BYK_CODPAD = '" + cCodPad + "' AND "
		
		cSQL += PLREQNI("BYK", "BYK_CODPSA", __aNiveis[2], allTrim(cCodPro))
		
		cSQL += "BYK_CODDOE = ' ' AND "
		
		if lCompra
			cSQL += "BYK_SOMCOM = '1' AND "
		else
			cSQL += "BYK_SOMCOM <> '1' AND "
		endIf
		cSQL += cNameBYK+".D_E_L_E_T_ = ' ' AND "
		
		cSQL += "( BYK_TIPO = '3' OR BYK_TIPO = '"+cRegAte+"' ) "
		
		cSQL +=  " ORDER BY BYK_NIVEL DESC, BYK_QTD ASC "
		
		aFaiQtd := MonQtdCOP(cSQL,"PLSRETBYK","BYK",,,,,,dDatPro,aDadUsr,cFinAte,;
							{ || PLSINTVAL("PLSRETBYK","BYK_VIGDE","BYK_VIGATE",dDatAnalise) },cRegAte)
		if len(aFaiQtd) > 0
			
			aforEsp := AnalQtdCO2(aFaiQtd,nfor,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,nil,lMudarFase,"BYK")
			
			for nAux:= 1 to len(aforEsp)
				lExistia := .t.

				cCodTab  := aFaiQtd[ aforEsp[nAux][2] , 3 ]
				nPerCop  += 1 / nQtd *( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,4 ] )
				nValCop  += 1 / nQtd *( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,5 ] )
				cPgNoAto := aFaiQtd[ aforEsp[nAux][2] , 6 ]
				nTaxa    := aFaiQtd[ aforEsp[nAux][2] , 7 ]
				nValUS   := aFaiQtd[ aforEsp[nAux][2] , 8 ]
				cAlias   := "BYK"
				cPgDrRDA := ""

				// Franquia...
				if len(aFaiQtd[aforEsp[nAux][2]]) >= 14
				
					if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aforEsp[nAux][2], 14]
						nLimFra := aFaiQtd[aforEsp[nAux][2], 15]
					else
						nLimFra := aFaiQtd[aforEsp[nAux][2],9]
					endIf
					
				else
					nLimFra  := aFaiQtd[aforEsp[nAux][2],9]
				endIf	
									
			next
			
			if lExistia
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
			endIf
			
		endIf
		
	endIf
	
endIf   

//19 - (BGD) - Produto X Cobertura X Município

if aScan(aPesqTab, "BGD") > 0 .and. (! lInterc .or. lChkNvLoc)

	BGD->(dbsetOrder(1))//BGD_FILIAL, BGD_CODIGO, BGD_VERSAO, BGD_CODMUN, BGD_CODPAD, BGD_CODPRO
	if BGD->(MsSeek(xFilial("BGD")+cCodInt+cCodPla+cVerPla+cMunAte+cCodPad+cCodPro))
		
		while ! BGD->(eof()) .and. BGD->(BGD_FILIAL+BGD_CODIGO+BGD_VERSAO+BGD_CODMUN+BGD_CODPAD+BGD_CODPRO) == xFilial("BGD")+cCodInt+cCodPla+cVerPla+cMunAte+cCodPad+cCodPro
			                                                                       
			if PLSINTVAL("BGD",'BGD_VIGINI','BGD_VIGFIN',dDatAnalise)
    	        
				if nQtd <= BGD->BGD_QTD
							
					if ( ( BGD->BGD_PERCOP > 0 .or. lValZero ) .or. BGD->BGD_VALCOP > 0 ) .and. ;
						( BGD->BGD_TIPO == "3" .or. BGD->BGD_TIPO == cRegAte )
									
						if !(empTy(BGD->BGD_FINATE)) .AND. allTrim(BGD->BGD_FINATE) <> allTrim(cFinAte)
							BGD->(DbSkip())
							loop
						endIf									
								
						lExistia:= .t.
						cCodTab := subStr(BGD->BGD_CODTAB,5,3)
						nPerCop := BGD->BGD_PERCOP
						nValCop := BGD->BGD_VALCOP
						nTaxa   := BGD->BGD_TXADM
						nValUS  := BGD->BGD_VALUS
						cPgNoAto:= BGD->BGD_PAGATO
						cAlias  := "BGD"
						cPgDrRDA:= ""
								
						return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA})
					endIf
					
				endIf
					
			endIf
			
		BGD->(dbSkip())
		endDo

	endIf 

endIf

//20 - (BGD) - Produto X Municipio                      

if aScan(aPesqTab, "BGD") > 0 .and. ! lInterc .or. lChkNvLoc     

	BGD->(dbsetOrder(1))
	if BGD->(MsSeek(xFilial("BGD")+cCodInt+cCodPla+cVerPla+cMunAte))
		while ! BGD->(eof()) .and. BGD->(BGD_FILIAL+BGD_CODIGO+BGD_VERSAO+BGD_CODMUN) == xFilial("BGD")+cCodInt+cCodPla+cVerPla+cMunAte
			
			if PLSINTVAL("BGD",'BGD_VIGINI','BGD_VIGFIN',dDatAnalise)
				if nQtd <= BGD->BGD_QTD
				
					if ( ( BGD->BGD_PERCOP > 0 .or. lValZero ) .or. BGD->BGD_VALCOP > 0 ) .and. ;
						( BGD->BGD_TIPO == "3" .or. BGD->BGD_TIPO == cRegAte )
						
						if !(empTy(BGD->BGD_FINATE)) .AND. allTrim(BGD->BGD_FINATE) <> allTrim(cFinAte)
							BGD->(DbSkip())
							loop
						endIf
						
						lExistia:= .t.
						cCodTab := subStr(BGD->BGD_CODTAB,5,3)
						nPerCop := BGD->BGD_PERCOP
						nValCop := BGD->BGD_VALCOP
						nTaxa   := BGD->BGD_TXADM
						nValUS  := BGD->BGD_VALUS
						cPgNoAto:= BGD->BGD_PAGATO
						cAlias  := "BGD"
						cPgDrRDA:= ""
						
						return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA})
					endIf
				endIf
			endIf
			BGD->(DbSkip())
		endDo
	endIf

endIf

//21 - (BB2/BHD) - Produto X Procedimento                     

if (aScan(aPesqTab, "BHD") > 0 .or. aScan(aPesqTab, "BB2") > 0) .and. (! lInterc .or. lChkNvLoc)

	nAte := if(empty(cGrpInt),1,2)
	for nFor := 1 to nAte
			
		cSQL := "SELECT BB2_CODPSA, BHD_PAGATO, BHD_CODTAB, BHD_PERCOP, BHD_VLRCOP, BHD_TXADM, BHD_VALUS, BHD_QTD, "
		cSQL += " BHD_PAGRDA,BHD_PAGDIF,BHD_LIMFRA,BHD_VLRATE,BHD_TIPUSR, BHD_FINATE, BHD_VIGDE, BHD_VIGATE,BHD_ANOMES, "
		cSQL += " BHD_VLRANT,BHD_SOMCOM, BHD_TIPO, BHD_IDAINI, BHD_IDAFIN "
		cSQL += " FROM " + cNameBHD + ", " + cNameBB2
		
		cSQL += " WHERE BHD_FILIAL = '"+xFilial("BHD")+"' AND "
		cSQL += " BHD_CODIGO = '"+cCodInt+cCodPla+"' AND "
		cSQL += " BHD_VERSAO = '"+cVerPla+"' AND "
		cSQL += " BHD_CODPAD = '"+cCodPad+"' AND "
		cSQL += " BHD_CODPSA = BB2_CODPSA AND   "
		cSQL += cNameBHD+".D_E_L_E_T_ = ' ' AND "
		cSQL += " BB2_CODIGO = BHD_CODIGO AND "
		
		//testa com o Grp de Internacao...
		if nFor == 1 
			
			if ! empty(cGrpInt)
				cSQL += "BHD_GRPINT = '" + cGrpInt + "' AND "
			else
				cSQL += "BHD_GRPINT = ' ' AND "
			endIf
			
		//teste sempre sem o grupo de cobertura
		else 
			cSQL += "BHD_GRPINT = ' ' AND "
		endIf
		
		cSQL += PLREQNI("BB2", "BB2_CODPSA", __aNiveis[2], allTrim(cCodPro))
		
		if lCompra
			cSQL += "BHD_SOMCOM = '1' AND "
		else
			cSQL += "BHD_SOMCOM <> '1' AND "
		endIf
		
		// Tratamento da vigencia								      
		cSQL += eval(bTrtVig,dDatPro,"BHD",.t.)
		
		cSQL += "( BHD_TIPO = '3' OR BHD_TIPO = '"+cRegAte+"' ) AND "
		
		cSQL += cNameBB2+".D_E_L_E_T_ = ' '"
		
		cSQL +=  " ORDER BY BB2_NIVEL DESC "
		
		aFaiQtd := MonQtdCOP(cSQL,"PLSTABCOP","BHD",,,,,lCompra,dDatPro,aDadUsr,cFinAte,;
								{ || PLSINTVAL("PLSTABCOP","BHD_VIGDE","BHD_VIGATE",dDatAnalise) },cRegAte)
		
		if len(aFaiQtd) > 0

			aforEsp := AnalQtdCO2(aFaiQtd,nfor,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,nil,lMudarFase,"BHD")

			for nAux:= 1 to len(aforEsp)
				lExistia := .t.
				
				//calcula o indice a ser aplicado por exemplo:      
				//suponha a parametrizacao                          
				//0-3    -> R$15,00                                 
				//4-9    -> R$25,00                                 
				//10-999 -> R$35,00                                 
				//e o usuraio digiou a qtd = 17 logo deve-se cobrar 
				//3*15,00 + 5*25,00 + 9*35,00						  
				//e nao 17*35,00   	                              
				
				cCodTab  := aFaiQtd[ aforEsp[nAux][2] , 3 ]
				nPerCop  += 1/nQtd*( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,4 ] )
				nValCop  += 1/nQtd*( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,5 ] )
				cPgNoAto := aFaiQtd[ aforEsp[nAux][2] , 6 ]
				nTaxa    := aFaiQtd[ aforEsp[nAux][2] , 7 ]
				nValUS   := aFaiQtd[ aforEsp[nAux][2] , 8 ]
				cAlias   := "BHD"

				cPgDrRDA := aFaiQtd[ aforEsp[nAux][2] , 10]
				lPagDif  := aFaiQtd[ aforEsp[nAux][2] , 12]
				nVlrMaPF := aFaiQtd[ aforEsp[nAux][2] , 13] 
				
				if len(aFaiQtd[aforEsp[nAux][2]]) >= 14
					if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aforEsp[nAux][2], 14]
						nLimFra := aFaiQtd[aforEsp[nAux][2], 15]
					else
						nLimFra := aFaiQtd[aforEsp[nAux][2],9]
					endIf
				else
					nLimFra  := aFaiQtd[aforEsp[nAux][2],9]
				endIf
			next

			if lExistia
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF})
			endIf
			
		endIf
		
	next

endIf

//22 - (BCW) - Produto X Tipo de Prestador              

if aScan(aPesqTab, "BCW") > 0 .and. (! lInterc .or. lChkNvLoc)

	BCW->(dbsetOrder(1))  //BCW_FILIAL, BCW_CODIGO, BCW_VERSAO, BCW_TIPPRE

	cSql := " SELECT BCW.R_E_C_N_O_ RECNO "
	cSql += "   FROM "+retSqlName("BCW") + " BCW "
	cSql += "   WHERE BCW_FILIAL = '" + xFilial("BCW") + "' "
	cSql += "    AND BCW_CODIGO = '" + cCodInt+cCodPla + "' "
	cSql += "    AND BCW_VERSAO = '" + cVerPla + "' "
	cSql += "    AND BCW_TIPPRE = '" + cTipPre + "' "
	cSql += "    AND ( '" +dtos(dDatAnalise) + "' >= BCW_VIGINI ) AND ( '" +dtos(dDatAnalise) + "' <= BCW_VIGFIN OR BCW_VIGFIN = '        ' ) "
	cSql += "    AND ( BCW_FINATE = ' ' OR ( RTRIM(LTRIM(BCW_FINATE)) = '"+allTrim(cFinAte)+"' )) "
	cSQL += "    AND ( BCW_TIPO = '3' OR BCW_TIPO = '"+cRegAte+"' ) "
	cSql += "    AND D_E_L_E_T_ =  ' ' "
	cSql += "    ORDER BY BCW_VIGINI "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSBCW",.f.,.t.)

	while ! PLSBCW->(eof())

		BCW->(dbgoto(PLSBCW->RECNO))
			
		if nQtd <= BCW->BCW_QTD
			
			if ( eval(bCond2,"BCW") ) .and. ( ( ( BCW->BCW_PERCOP > 0 .or. lValZero ) .or. BCW->BCW_VALCOP > 0 ) ) .and. ;
				( BCW->BCW_TIPO == "3" .or. BCW->BCW_TIPO == cRegAte )
				
				if !(empTy(BCW->BCW_FINATE)) .AND. allTrim(BCW->BCW_FINATE) <> allTrim(cFinAte)
					PLSBCW->(DbSkip())
					loop
				endIf
				
				lExistia:= .t.
				cCodTab := subStr(BCW->BCW_CODTAB,5,3)
				nPerCop := BCW->BCW_PERCOP
				nValCop := BCW->BCW_VALCOP
				nTaxa   := BCW->BCW_TXADM
				nValUS  := BCW->BCW_VALUS
				cPgNoAto:= BCW->BCW_PAGATO
				
				if subStr(dtos(dDatAnalise),1,6) < BCW->BCW_ANOMES
					nLimFra := BCW->BCW_VLRANT
				else
					nLimFra := BCW->BCW_LIMFRA
				endIf
				
				cPgDrRDA:= ""
				cAlias  := "BCW"
				
				PLSBCW->(dbCloseArea())
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
			endIf
		endIf
		PLSBCW->(dbSkip())
	endDo

	PLSBCW->(dbCloseArea())
endIf

//23 - (BHI) - Produto X Grupo de Cobertura...          
if aScan(aPesqTab, "BHI") > 0 .and. ( ! lInterc .or. lChkNvLoc ) .and. (cNivAut $ "BRV|BBK" .or. lAuditoria .or. lNConsNIV )

		lVig := .t.
	
		cSQL := "SELECT BHI_QTD,BHI_LIMFRA,BHI_PAGATO, BHI_CODTAB, BHI_PERCOP, "
		cSQL += " BHI_PAGRDA, BHI_TIPUSR, BHI_VIGDE, BHI_VIGATE, BHI_IDAINI, BHI_IDAFIN, "
		cSQL += " BHI_VLRCOP, BHI_TXADM, BHI_VALUS, BHI_SOMCOM, BHI_PAGDIF, BHI_VLRATE, BHI_ANOMES, BHI_VLRANT, BHI_FINATE, BHI_TIPO, BHI_SOMPRO FROM " + retSqlName("BHI") + " "
		cSQL += " WHERE BHI_FILIAL = '" + xFilial("BHI") + "' "
		
		If lNConsNIV
			cSQL += "   AND BHI_CODINT = '" + cCodInt + "' "
			cSQL += "   AND BHI_CODPLA = '" + cCodPla + "' "
			cSQL += "   AND BHI_VERSAO = '" + cVerPla + "' "
			cSQL += "   AND BHI_CODGRU = '" + RIGHT(allTrim(cChvAut) , 3 ) + "' "
		else
			cSQL += "   AND BHI_CODINT = '" + SubStr(allTrim(cChvAut), 01 , 4 ) + "' "
			cSQL += "   AND BHI_CODPLA = '" + SubStr(allTrim(cChvAut), 05 , 4 ) + "' "
			cSQL += "   AND BHI_VERSAO = '" + SubStr(allTrim(cChvAut), 09 , 3 ) + "' "
			cSQL += "   AND BHI_CODGRU = '" + SubStr(allTrim(cChvAut), 12,  3 ) + "' "
		endif
		
		if lCompra
			cSQL += " AND BHI_SOMCOM = '1' AND"
		else
			cSQL += " AND BHI_SOMCOM <> '1' AND "
		endIf
						
		cSQL += " ( BHI_TIPO = '3' OR BHI_TIPO = '"+cRegAte+"' ) "
		cSQL += " AND ( '" + dtos(dDatAnalise) + "' >= BHI_VIGDE OR BHI_VIGDE  = '        ' ) "
		cSQL += " AND ( '" + dtos(dDatAnalise) + "' <= BHI_VIGATE OR BHI_VIGATE = '        ' ) "
		cSQL += " AND ( BHI_FINATE = ' ' OR RTRIM(LTRIM(BHI_FINATE)) = '"+allTrim(cFinAte)+"' ) "
		cSQL += " AND D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY BHI_FINATE DESC, BHI_QTD ASC "

		if existBlock("PLSPFBHI")
		   cSQL := execBlock("PLSPFBHI",.f.,.f.,cSQL)
		endIf
		
		aFaiQtd := MonQtdCOP(cSQL,"PLSRETBHI","BHI",.t.,'.t.',,,;
							lCompra,dDatPro,aDadUsr,cFinAte,;
							{ || PLSINTVAL("PLSRETBHI","BHI_VIGDE","BHI_VIGATE",dDatAnalise) },cRegAte)
		
		if len(aFaiQtd) > 0
		
			aforEsp := AnalQtdCO2(aFaiQtd,1,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,nil,lMudarFase,"BHI")
			
			for nAux := 1 to len(aforEsp)
			
				lExistia := .t.
				cCodTab  := aFaiQtd[ aforEsp[nAux][2] , 3]
				
				//Para reembolso sempre roda o else
				if ! lReembolso 
	         	
	         	  	if BD6->BD6_CNTCOP <> "1"  
	         	    	nPerCop += 1/nQtd * ( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,4 ] ) 
	         	  	else
	         	    	nPerCop += BD6->BD6_PERCOP
	             	endIf
	             	
             	else
	        		nPerCop  += 1/nQtd * ( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,4 ] ) 
	         	endIf
	         	   
				nValCop  += 1/nQtd * ( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,5 ] )
				
				cPgNoAto := aFaiQtd[ aforEsp[nAux][2], 6 ]
				nTaxa    := aFaiQtd[ aforEsp[nAux][2], 7 ]
				nValUS   := aFaiQtd[ aforEsp[nAux][2], 8 ]
				
				cAlias   := "BHI"
				
				cPgDrRDA := aFaiQtd[ aforEsp[nAux][2], 10]
				lPagDif  := aFaiQtd[ aforEsp[nAux][2], 12]
				nVlrMaPF := aFaiQtd[ aforEsp[nAux][2], 13]
				
				if len(aFaiQtd[aforEsp[nAux][2]]) >= 14
					
					if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aforEsp[nAux][2], 14]
						nLimFra := aFaiQtd[aforEsp[nAux][2], 15]
					else
						nLimFra := aFaiQtd[aforEsp[nAux][2],9]
					endIf
					
				else
					nLimFra  := aFaiQtd[aforEsp[nAux][2],9]
				endIf
				
			next
			
			if lExistia
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF})
			endIf
			
		endIf

endIf
   
if aScan(aPesqTab, "B86") > 0

	B86->(dbsetOrder(1))
	if ( ! lInterc .or. lChkNvLoc ) .and. B86->(MsSeek(xFilial("B86")+cCodInt+cCodPla+cVerPla+cCodRDA))
		
		while !B86->( eof() ) .and. B86->(B86_FILIAL+B86_CODINT+B86_CODPLA+B86_VERSAO+B86_CODRDA) == xFilial("B86")+cCodInt+cCodPla+cVerPla+cCodRDA
			
			
			//Se a vigencia estiver dentro do limite parametrizado...			  
			
			if PLSINTVAL("B86","B86_VIGDE","B86_VIGATE",dDatAnalise)
			
				if ( eval(bCond2,"B86") ) .and. ( ( ( B86->B86_PERCOP > 0 .or. lValZero ) .or. B86->B86_VALCOP > 0 ) )

					if !(empTy(B86->B86_FINATE)) .AND. allTrim(B86->B86_FINATE) <> allTrim(cFinAte)
						B86->(DbSkip())
						loop
					endIf
									
					lExistia:= .t.
					cCodTab := subStr(B86->B86_CODTAB,5,3)
					nPerCop := B86->B86_PERCOP
					nValCop := B86->B86_VALCOP
					nTaxa   := B86->B86_TXADM
					cPgNoAto:= B86->B86_PAGATO
					nValUS  := B86->B86_VALUS
					cAlias  := "B86"
					cPgDrRDA:= ""
					
					if B86->( fieldPos("B86_ANOMES") ) > 0 .and. B86->( fieldPos("B86_VLRANT") ) > 0
					
						if subStr(dtos(dDatAnalise),1,6) < B86->B86_ANOMES
							nLimFra := B86->B86_VLRANT
						else    	
							nLimFra := B86->B86_LIMFRA
						endIf
					else
						nLimFra := B86->B86_LIMFRA
					endIf
					
					return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})	
				endIf
			endIf
			B86->( dbSkip() )			
		endDo
	endIf

endIf
			


//10 (BHJ) - Produto                               
if aScan(aPesqTab, "BHJ") > 0 .and. (! lInterc .or. lChkNvLoc)

	BHJ->(dbsetOrder(1))//BHJ_FILIAL, BHJ_CODINT, BHJ_CODPLA, BHJ_VERSAO
	if BHJ->(MsSeek(xFilial("BHJ")+cCodInt+cCodPla+cVerPla))
	
		aFaiQtd := MonQtdCOP("","","BHJ",.f.,'.t.',;
							'(BHF->BHF_SOMPRO == "1" .and. BR8->BR8_TPPROC $ "0,6, ") .or. BHF->BHF_SOMPRO <> "1" ',;
							{ || BHJ->(BHJ_FILIAL+BHJ_CODINT+BHJ_CODPLA+BHJ_VERSAO) == xFilial("BHJ")+cCodInt+cCodPla+cVerPla},;
							lCompra,dDatPro,aDadUsr,cFinAte,,cRegAte)
		
		if len(aFaiQtd) > 0
		
			aforEsp := AnalQtdCO2(aFaiQtd,1,__aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,nil,lMudarFase,"BHF")
		
			for nAux:= 1 to len(aforEsp)
		
				lExistia := .t.
		
				cCodTab  := aFaiQtd[ aforEsp[nAux][2] , 3 ]
				nPerCop  += 1/nQtd*( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,4 ] )
				nValCop  += 1/nQtd*( aforEsp[nAux][1] * aFaiQtd[ aforEsp[nAux][2] ,5 ] )
				cPgNoAto := aFaiQtd[ aforEsp[nAux][2] , 6 ]
				nTaxa    := aFaiQtd[ aforEsp[nAux][2] , 7 ]
				nValUS   := aFaiQtd[ aforEsp[nAux][2] , 8 ]
				cAlias   := "BHJ"
				cPgDrRDA := aFaiQtd[ aforEsp[nAux][2] , 10]
				lPagDif  := aFaiQtd[ aforEsp[nAux][2] , 12]
				nVlrMaPF := aFaiQtd[ aforEsp[nAux][2] , 13]
				
				if len(aFaiQtd[aforEsp[nAux][2]]) >= 14
					
					if subStr(dtos(dDatAnalise),1,6) < aFaiQtd[aforEsp[nAux][2], 14]
						nLimFra := aFaiQtd[aforEsp[nAux][2], 15]
					else
						nLimFra := aFaiQtd[aforEsp[nAux][2],9]
					endIf
					
				else
					nLimFra  := aFaiQtd[aforEsp[nAux][2],9]
				endIf
			next
			
			if lExistia
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF})
			endIf
			
		endIf
	endIf

endIf

//26 - (BHK) - Grupo de Cobertura X Co-Participacao...  
if aScan(aPesqTab, "BHK") > 0 .and. ( ! lInterc .or. lChkNvLoc ) .and. (cNivAut $ "BFE,BFC,BT7,BRV"  .or. lAuditoria .or. lNConsNIV )

	lVig := .t.
	
	BHK->(dbsetOrder(1))//BHK_FILIAL, BHK_CODINT, BHK_CODGRU, BHK_CODPAD, BHK_CODPSA
	cSql := " SELECT R_E_C_N_O_ RECNO FROM " + retSqlName("BHK")
	cSql += " WHERE "
	cSql += " BHK_FILIAL = '" + xFilial("BHK") + "' "
	cSql += " AND BHK_CODINT = '" + SubStr(allTrim(cChvAut),1,4) + "' "
	cSql += " AND BHK_CODGRU = '" + Right(allTrim(cChvAut),3) + "' "
	cSql += " AND BHK_CODPAD = '" + cCodpad + "' "
	cSql += " AND BHK_CODPSA = '" + cCodpro + "' "
	cSql += " AND ( '" + dtos(dDatAnalise) + "' >= BHK_VIGINI OR BHK_VIGINI  = '        ' ) "
	cSql += " AND ( '" + dtos(dDatAnalise) + "' <= BHK_VIGFIN OR BHK_VIGFIN = '        ' ) "
	cSql += " AND ( BHK_FINATE = ' ' OR RTRIM(LTRIM(BHK_FINATE)) = '"+allTrim(cFinAte)+"' ) "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY BHK_FINATE DESC, BHK_QTD ASC"
 
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSBHK",.f.,.t.)
	while ! PLSBHK->(eof())       
		BHK->(dbgoto(PLSBHK->RECNO)) 
		
		if nQtd <= BHK->BHK_QTD
					
			if ( eval(bCond2,"BHK") ) .and. ( ( ( BHK->BHK_PERCOP > 0 .or. lValZero ) .or. BHK->BHK_VLRCOP > 0 ) ).and. ( BHK->BHK_TIPO == "3" .or. BHK->BHK_TIPO == cRegAte )

				lExistia:= .t.
				cCodTab := subStr(BHK->BHK_CODTAB,5,3)
				nPerCop := BHK->BHK_PERCOP
				nValCop := BHK->BHK_VLRCOP
				nTaxa   := BHK->BHK_TXADM
				nValUS  := BHK->BHK_VALUS
				cPgNoAto:= BHK->BHK_PAGATO
						
				nLimFra := BHK->BHK_LIMFRA
						
				cAlias  := "BHK"

				PLSBHK->(DBCloseArea())
				return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF})
			endIf
		endIf
			
	PLSBHK->(dbSkip())
	endDo

	PLSBHK->(DBCloseArea())
endIf

//27 - (BSY) - local de atendimento                    
if aScan(aPesqTab, "BSY") > 0 .and. (! lInterc .or. lChkNvLoc)

   if ( BA3->BA3_TIPOUS == "1" .and. BI3->BI3_CPFM == "1" ) .or. ;
      ( BA3->BA3_TIPOUS == "2" .and. BT6->BT6_CPFM == "1" )   

      BSY->(dbsetOrder(1))
      if BSY->(MsSeek(xFilial("BSY")+cCodInt+cCodLoc))
       
         while ! BSY->(eof()) .and. BSY->(BSY_FILIAL+BSY_CODINT+BSY_CODLOC) == xFilial("BSY")+cCodInt+cCodLoc

               if ( eval(bCond2,"BSY") ) .and. ( BSY->BSY_TIPO == "3" .or. BSY->BSY_TIPO == cRegAte )
                           
                  lExistia:= .t.
                  
                  cCodTab := subStr(BSY->BSY_CODTAB,5,3)
                  nPerCop := BSY->BSY_PERCOP
                  nValCop := BSY->BSY_VLRCOP              
                  nTaxa   := BSY->BSY_TXADM
                  nValUS  := BSY->BSY_VALUS                              
                  cPgNoAto:= BSY->BSY_PAGATO
                  cPgDrRDA:= BSY->BSY_PAGRDA
                  
                  cAlias  := "BSY"                                       
                  return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA})
               endIf
               
         BSY->(DbSkip())
         endDo 
              
      endIf
   endIf   

endIf   

//28 - (BHC) - Tabela Padrao                           
if aScan(aPesqTab, "BHC") > 0 .and. (! lInterc .or. lChkNvLoc )

	BHC->(dbsetOrder(1))//BHC_FILIAL, BHC_CODPAD, BHC_CODPSA, BHC_TIPO
	
	if BHC->(MsSeek(xFilial("BHC")+cCodPad+cCodPro))
	
		while ! BHC->(eof()) .and. BHC->(BHC_FILIAL+BHC_CODPAD+BHC_CODPSA) == xFilial("BHC")+cCodPad+cCodPro
		
			if PLSINTVAL("BHC",'BHC_VIGINI','BHC_VIGFIN',dDatAnalise)
	
				if nQtd <= BHC->BHC_QTD
							
					if ( eval(bCond2,"BHC") ) .and. ( ( BHC->BHC_PERCOP > 0 .or. lValZero ) .or. BHC->BHC_VLRCOP > 0 ) .and. ( BHC->BHC_TIPO == "3" .or. BHC->BHC_TIPO == cRegAte )
								
						if !(empTy(BHC->BHC_FINATE)) .AND. allTrim(BHC->BHC_FINATE) <> allTrim(cFinAte)
							BHC->(DbSkip())
							loop
						endIf								
								
						lExistia:= .t.
						cCodTab := subStr(BHC->BHC_CODTAB,5,3)
						nPerCop := BHC->BHC_PERCOP
						nValCop := BHC->BHC_VLRCOP
						nTaxa   := BHC->BHC_TXADM
						nValUS  := BHC->BHC_VALUS
						cPgNoAto:= BHC->BHC_PAGATO
						cPgDrRDA:= BHC->BHC_PAGRDA
						cAlias  := "BHC"
								
						return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA})
					endIf
				endIf
			endIf
			
		BHC->(dbSkip())
		endDo
	endIf   

endIf

//29 - (BWW) - Operadora X Co-Part. Padrao             
if aScan(aPesqTab, "BWW") > 0 .and. (! lInterc .or. lChkNvLoc )

	lVig := .t.
	 
	BWW->(dbsetOrder(1))//BWW_FILIAL, BWW_CODINT, BWW_ANO, BWW_MES
	if BWW->(MsSeek(xFilial("BWW")+cCodInt+cAno+cMes))
	
		while ! BWW->(eof()) .and. BWW->(BWW_FILIAL+BWW_CODINT+BWW_ANO+BWW_MES) == xFilial("BWW")+cCodInt+cAno+cMes
			
			if PLSINTVAL("BWW",'BWW_VIGINI','BWW_VIGFIN',dDatAnalise)
				
				cQRY := " SELECT BWW_QTD, BWW_TIPO, BWW_CODTAB, BWW_PERCOP, BWW_VLRCOP, BWW_TXADM, BWW_PAGATO, BWW_VALUS,BWW_FINATE "
				cQRY += " FROM "+RetSQLName("BWW")+" WHERE "
				cQRY += " BWW_FILIAL = '"+xFilial("BWW")+"'"
				cQRY += " AND BWW_CODINT = '"+cCodInt+"' "
				cQRY += " AND BWW_ANO = '"+cAno+"' "
				cQRY += " AND BWW_MES = '"+cMes+"' "				
				cQRY += " AND BWW_VIGINI <> ' '"
				cQRY += " AND BWW_VIGINI <= '"+DtoS(dDatAnalise)+"' "
				cQRY += " AND (BWW_VIGFIN = ' '"
				cQRY += " OR BWW_VIGFIN >= '"+DtoS(dDatAnalise)+"') "
				cQRY += " AND D_E_L_E_T_ = ' '"
				cQRY += " ORDER BY BWW_QTD "
				
				if Select("TRBBWW") > 0
			        TRBBWW->( dbCloseArea())
			    endIf
				
				dbUseArea(.t.,"TOPCONN",TCGENQRY(,,cQRY),"TRBBWW",.f.,.t.)
				
				if TRBBWW->(!eof())
				
					while TRBBWW->(!eof())
				
						if nQtd <= TRBBWW->BWW_QTD
							
							if ( eval(bCond2,"BWW") ) .and. ( ( TRBBWW->BWW_PERCOP > 0 .or. lValZero ) .or. TRBBWW->BWW_VLRCOP > 0 ) .and. ( TRBBWW->BWW_TIPO == "3" .or. TRBBWW->BWW_TIPO == cRegAte )
								
								lExistia:= .t.                      
								
								if !(empTy(TRBBWW->BWW_FINATE)) .AND. allTrim(TRBBWW->BWW_FINATE) <> allTrim(cFinAte)
									TRBBWW->(DbSkip())
									loop
								endIf								
																
								cCodTab := subStr(TRBBWW->BWW_CODTAB,5,3)
								nPerCop := TRBBWW->BWW_PERCOP
								nValCop := TRBBWW->BWW_VLRCOP
								nTaxa   := TRBBWW->BWW_TXADM
								nValUS  := TRBBWW->BWW_VALUS
								cPgNoAto:= TRBBWW->BWW_PAGATO
								cPgDrRDA:= ""
								cAlias  := "BWW"
								
								TRBBWW->(dbCloseArea())
								return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA})
							endIf
							
							Exit
						endIf
					
					TRBBWW->(dbSkip())
					endDo

					TRBBWW->(dbCloseArea())
				endIf
				
			else
			
				if lVig
				
					while ! BWW->(eof()) .and. BWW->(BWW_FILIAL+BWW_CODINT+BWW_ANO+BWW_MES) == xFilial("BWW")+cCodInt+cAno+cMes
						
						if BWW->BWW_VIGINI  == CtoD(" / / ") .and. BWW->BWW_VIGFIN  == CtoD(" / / ")
						   lVig := .t.
						else
							lVig := .f.
							Exit
						endIf
						
					BWW->(dbSkip())
					endDo
					
				endIf
			
				if lVig .and. BWW->(MsSeek(xFilial("BWW")+cCodInt+cAno+cMes)) .and. ( eval(bCond2,"BWW") ) .and. ( ( BWW->BWW_PERCOP > 0 .or. lValZero ) .or. BWW->BWW_VLRCOP > 0 ) .and. ( BWW->BWW_TIPO == "3" .or. BWW->BWW_TIPO == cRegAte )
					
					if !(empTy(BWW->BWW_FINATE)) .AND. allTrim(BWW->BWW_FINATE) <> allTrim(cFinAte)
						BWW->(DbSkip())
						loop
					endIf	
													
					lExistia:= .t.
					cCodTab := subStr(BWW->BWW_CODTAB,5,3)
					nPerCop := BWW->BWW_PERCOP
					nValCop := BWW->BWW_VLRCOP
					nTaxa   := BWW->BWW_TXADM
					nValUS  := BWW->BWW_VALUS
					cPgNoAto:= BWW->BWW_PAGATO
					cPgDrRDA:= ""
					cAlias  := "BWW"
					
					return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA})
				endIf           
			endIf
				
			BWW->(DbSkip())
		endDo
	endIf

endIf

if getNewPar("MV_PLSCPRC","0") == "1" .and. lRecursivo
	// Se chegou ate aqui, eh porque nao achou nada pela finalidade de atendimento.
	// Entao executa a funcao recursivamente para encontrar pela finalidade em branco.
	aRet := {}
	aRet := PLSTABCOP(cCodPad,cCodPro,cCodInt,cCodRDA,cEspec,cSubEsp,cCodLoc,cObsoleto,;
                   		cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,cCodPla,cOpeOri,cVerPla,cGrpInt,cTipPre,cMunAte,;
                   		lVerPgAto,lCompra,cMatric,cTipReg,dDatAnalise,cModPag,lInterc,cNivAut,cChvAut,cCodUnm,;
                   		cMes,cAno,dDatPro,cHorPro,cRegAte,cCid,nVlrApr,nQtd,aValAcu,aCobAcu,nRegBD6,aDadUsr," ",.f.,lAuditoria)
 
 	// Testa contexto da variavel lExistia. Se for .t. é porque encontrou um nivel valido com finalidade de atendimento em branco.
 	if aRet[7]
		cCodTab := aRet[1]
		nPerCop := aRet[2]
		nValCop := aRet[3]
		nTaxa	:= aRet[4]
		nValUS	:= aRet[5]
		cAlias	:= aRet[6]
		lExistia:= aRet[7]
		cPgNoAto:= aRet[8]
		cPgDrRDA:= aRet[9]
		nLimFra	:= Iif(len(aRet) >= 10, aRet[10], 0)
		lPagDif	:= Iif(len(aRet) >= 11, aRet[11], .f.)
		nVlrMaPF:= Iif(len(aRet) >= 12, aRet[12], 0)
		
		return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra,lPagDif,nVlrMaPF}) 		
	endIf
endIf

//Testa o novo campo de co-partic. para mat/med relacionado ao proc. principal... 
if ! lCompra .and. len(aValAcu) > 0 .and.  !(BR8->BR8_TPPROC $ "0,6") .and. ! empty(BR8->BR8_TPPROC) .and. BR8->BR8_COBMDP == "1"

   nOrdBR8 := BR8->(indexOrd())
   nRecBR8 := BR8->(recno())
   
   lFlag := .f.
   
   BR8->(dbsetOrder(1))
   for nfor := 1 to len(aValAcu)
   
       if BR8->(msSeek(xFilial("BR8")+aValAcu[nfor,1]+aValAcu[nfor,2])) .and. BR8->BR8_COBMDP == "1" .and. (BR8->BR8_TPPROC == "0" .or. BR8->BR8_TPPROC == "6")
          cCodPadProPP := BR8->(BR8_CODPAD+BR8_CODPSA)															
          lFlag 	   := .t.
          Exit
       endIf
       
   next
   
   BR8->(dbsetOrder(nOrdBR8))
   BR8->(dbGoto(nRecBR8))

   if lFlag
   
      nPos := Ascan(aCobAcu,{|x| x[1]+x[2] == cCodPadProPP})
   
      if nPos == 0
         nPerCop := 100
      else
      
         if aCobAcu[nPos,3,1]
            nPerCop  := aCobAcu[nPos,3,5]
            nValCop  := aCobAcu[nPos,3,9]
            nTaxa    := aCobAcu[nPos,3,7]
            lExistia := .t.
            nLimFra  := aCobAcu[nPos,3,19]
         else
            nPerCop  := 0
            nValCop  := 0
            nTaxa    := 0
            lExistia := .f.
            nLimFra  := 0
         endIf   
         
      endIf
 
     if lExistia
         cCodTab  := ""
         nValUS   := 0
         cPgNoAto := "0"
         cPgDrRDA := ""
         cAlias   := "CMM"                                       
         return({cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra})
      endIf
         
   endIf   
endIf

return({"",0,0,0,0,"",.f.,""})

/*/
{Protheus.doc} PLSVLDCP
Realiza uma validacao generica de copartcipacao em qq nivel
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSVLDCP(__aNiveis,nNiveis,cAlias,cChaveAux,cChavePro,cCodPro,lVerPgAto,lCompra,cNameCpo,cNameVlr,dDatPro,dDatAnalise,cFinAte,bVldGen)
local nfor       
local cChave
local bChaveProc:= { || if(nfor == 1,cCodPro,subStr(cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])) }
local aRetGer   := {.f.,{"",0,0,0,0,"",.f.,""}}
local bRest     := { || if(!empty(cOldAlias),(DbSelectArea(cOldAlias),dbsetOrder(nOldOrdem),dbGoto(nOldrecno)),nil) }
local cOldAlias := Alias()
local nOldOrdem := indexOrd()
local nOldrecno := recno()
local cFilSeek  := xFilial(cAlias)
local lAchou    := .f.
local bCond1    := { || AnaDataCOP(dDatPro,cAlias) }
local bCond2    := { || &(cAlias+"->"+cAlias+"_SOMCOM") == if(lCompra,"1","0") }
local lExistia  := .f.
local cCodTab
local nPerCop
local nValCop
local nTaxa
local nValUS
local cPgNoAto
local cPgDrRDA  := ""                         
local lExistNiv := .T. //type(cAlias+"->"+cAlias+"_NIVEL") == "C"
local nOrdBR8
local nRecBR8
local nLimFra	:= 0
local lValZero  := getNewPar("MV_PLSVLZE",.f.)

default dDatPro 	:= dDataBase
default dDatAnalise := dDataBase
default cFinAte		:= ""       
default bVldGen 	:= { || .t. }

for nfor := 1 to nNiveis
	
	cChave := cFilSeek+cChaveAux+eval(bChaveProc)
	
	DbSelectArea(cAlias)
	dbsetOrder(nfor)
	MsSeek(cChave)
	
	if Found()
		DbSelectArea(cAlias)
		while cChave == subStr(&(IndexKey()),1,len(cChave))
			
			if nfor == 1
				lAchou := .t.
			else
				if lExistNiv
					lAchou := (__aNiveis[2,(nfor-1),3] == &(cAlias+"->"+cAlias+"_NIVEL"))
				else
					nOrdBR8 := BR8->(indexOrd())
					nRecBR8 := BR8->(recno())
					BR8->(dbsetOrder(1))
					BR8->(MsSeek(xFilial("BR8")+(&(cAlias+"->"+cAlias+"_CODPAD")+&(cAlias+"->"+cAlias+"_"+cNameCpo))))
					lAchou := __aNiveis[2,(nfor-1),3] == BR8->BR8_NIVEL
					
					BR8->(dbsetOrder(nOrdBR8))
					BR8->(dbGoto(nRecBR8))
				endIf
			endIf
			
			if lAchou

				if &(cAlias)->(fieldPos(cAlias+"_FINATE")) > 0 .and. !(empTy(&(cAlias+"->"+cAlias+"_FINATE"))) .AND. allTrim(&(cAlias+"->"+cAlias+"_FINATE")) <> allTrim(cFinAte)
					DbSkip()
					loop
				endIf
			
				if ( eval(bCond2) ) .and. ( eval(bCond1) ) .and. ( eval(bVldGen) ) .and.;
					( ( &(cAlias+"->"+cAlias+"_PERCOP") > 0 .or. lValZero ) .or. &(cAlias+"->"+cAlias+"_"+cNameVlr) > 0 )
					
					eval(bRest)
					lExistia:= .t.
					cCodTab := subStr(&(cAlias+"->"+cAlias+"_CODTAB"),5,3)
					nPerCop := &(cAlias+"->"+cAlias+"_PERCOP")
					nValCop := &(cAlias+"->"+cAlias+"_"+cNameVlr)
					nTaxa   := &(cAlias+"->"+cAlias+"_TXADM")
					nValUS  := &(cAlias+"->"+cAlias+"_VALUS")
					cPgNoAto:= &(cAlias+"->"+cAlias+"_PAGATO")
					
					if subStr(dtos(dDatAnalise),1,6) < &(cAlias+"->"+cAlias+"_ANOMES")
						nLimFra := &(cAlias+"->"+cAlias+"_VLRANT")
					else
						nLimFra := &(cAlias+"->"+cAlias+"_LIMFRA")
					endIf
					
					cPgDrRDA:= ""
					return({.t.,{cCodTab,nPerCop,nValCop,nTaxa,nValUS,cAlias,lExistia,cPgNoAto,cPgDrRDA,nLimFra}})
					
				endIf
				
			endIf
			
			DbSelectArea(cAlias)
			DbSkip()
			
		endDo
		
	endIf
	
next

return(aRetGer)

/*/
{Protheus.doc} PLSGRUOPE
Grupo operadora
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSGRUOPE(cTipo, cOpeOri, dDatAnalise, nNiveis, __aNiveis, cCodPro, cModPag, cCodPad, cEspec, cCodUnd, cCodPla,;
				   nVlrApr, cGruOpe, nValUS, lInterc, cFinAte, cCodRda, cRdaEdi, lRtBanda, lRetFil, lBusTx,cTipAte)
local nPerCop    := 0
local nValREA    := 0
local nTaxa      := 0
local nVlrFil	 := 0
local nBanda     := 0
local cCodSeq	 := ""
local cSeqRel    := ""
local cNvTxVld   := "0"
local cCodTab    := ""
local cPgNoAto   := ""
local cPgDrRDA   := ""
local cNivTax    := ""
local nOrdBA0    := BA0->(indexOrd())
local nRecBA0    := BA0->(recno())                                             
local bRest      := { || BA0->(dbGoto(nRecBA0)), BA0->(dbsetOrder(nOrdBA0)) }
local lOK        := .f.                                  
local lPesUnd    := .f. 
local aRetpto	 := {}
local aRetB7U    := {}
local aRet		 := { .f., { cCodTab, nPerCop, nValREA, nTaxa, 0, cNivTax, lOK, cPgNoAto, cPgDrRDA, 0, .f., nBanda, nVlrFil, cSeqRel, ctod(""), ctod("")} }
local cSql 		 := ""
Local lTipAte	 := BGH->( FieldPos("BGH_TIPATE") ) > 0
Local lBD4Found	 := .F.
Local cOperadora := PLSINTPAD()
Local aAreaBD4	 := BD4->(getArea())
Local lPLVTumm	 := Existblock("PLVTNUMM")
Local lvalidPE	 := .T.
local nDiasIn    := getNewPar("MV_PLSDRID",90) //Intercâmbio nacional (plano INTC)---> não cobrar taxa adm em atendimentos superiores a 90 dias
local nDiasInRS  := getNewPar("MV_PLSDRAM",120)//Intercambio estadual (plano INRS)---> não cobrar taxa adm em atendimentos superiores a 120 dias
local dData		 := date()
Local lRegraRS	 := .F.

default cCodPla  	:= ""
default nVlrApr  	:= 0
default cGruOpe  	:= ""
default nValUS   	:= 0
default lInterc	 	:= .t.
default cFinAte	 	:= ""
default cCodRda  	:= ""
default cRdaEdi  	:= ""
default lRtBanda	:= .f.
default lRetFil		:= .f.
default lBusTx		:= .f.
default cTipAte		:= ' '
lPesUnd := !empty(cCodUnd)                  

if empty(cGruOpe) .OR. cTipo == '1'
   BA0->(dbsetOrder(1))
   BA0->(MsSeek(xFilial("BA0")+cOpeOri))
   cGruOpe := BA0->BA0_GRUOPE
endIf   

lRegraRS := OpeIntEs(cOpeOri)

if existBlock("PLSGROPE")
   
   aRetPto := execBlock("PLSGROPE",.f.,.f.,{cTipo,cOpeOri,dDatAnalise,cCodPro,cCodPad,cCodPla,cGruOpe})
   
   if aRetPto[1]
      cGruOpe := aRetpto[2]
   endIf
   
endIf      

cSql := " SELECT BGH.R_E_C_N_O_ RECNO "
If lTipAte .AND. !(empty(ctipAte))
	cSql += " ,CASE WHEN BGH_TIPATE = ' ' THEN '3' ELSE BGH_TIPATE END TIPATE "
endIf
cSql += "   FROM "+retSqlName("BGH")+" BGH "
cSql += "  WHERE BGH_FILIAL = '" + xFilial("BGH") + "' "
cSql += "    AND BGH_GRUOPE = '" + cGruOpe + "' "
cSql += "    AND ( '" +dtos(dDatAnalise) + "' >= BGH_DATINI ) AND ( '" +dtos(dDatAnalise) + "' <= BGH_DATFIN OR BGH_DATFIN = '        ' ) "
cSql += "    AND ( BGH_FINATE = ' ' OR ( RTRIM(LTRIM(BGH_FINATE)) = '"+allTrim(cFinAte)+"' )) "
If lTipAte .AND. !(empty(ctipAte))
	cSql += " AND BGH_TIPATE IN ('3', ' ', '" + cTipAte + "' ) "
endIf
cSql += "    AND D_E_L_E_T_ =  ' ' "
If lTipAte .AND. !(empty(ctipAte))
	cSql += " Order By TIPATE "
endIf

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSGRUOPE",.f.,.t.)

while !PLSGRUOPE->( eof() ) 
	
	BGH->(dbgoto(PLSGRUOPE->RECNO))

	//Recebimento ou Pagamento
	nTaxa	  := iIf( cTipo == "2", BGH->BGH_VLRTRC, BGH->BGH_VLRTAX )
	nBanda 	  := iIf( cTipo == "2", BGH->BGH_BANDAR, BGH->BGH_BANDAP )
	cSeqRel   := BGH->BGH_SEQREL
	cCodSeq   := BGH->BGH_CODSEQ
	cNvTxVld  := BGH->BGH_NIVVAL
	nVlrFil   := BGH->BGH_VLRFIL
	cCodTab	  := iIf( cTipo == "2", BGH->BGH_TABREC, BGH->BGH_TABPAG )
	
	//tratamento para unidade FILME
	if lRetFil
		
		if nVlrFil > 0 
		
			lOK 	:= .t.
			cNivTax := "BGH"
			aRet[2] := { cCodTab, nPerCop, nValREA, nTaxa, nValUS, cNivTax, lOK, cPgNoAto, cPgDrRDA, 0, .f., nBanda, nVlrFil, cSeqRel }
	
		endIf

		exit

	endIf

	//nao e necessario entrar quando vem da PLSRETVFIL
	if ! lOK

		//nao e necessario entrar quando vem da PLSRTBANDA
		if ! lRtBanda

			//Agora procuro nos itens por PLANO/UNIDADE (BSX)... FILHA da BSM   
			if lPesUnd
					
				aRet := retGP("BSX", __aNiveis[2], nVlrApr, cFinAte, cTipo, cModPag, nBanda, cGruOpe, cCodSeq, cCodPad, cCodPro, cCodPla, cCodUnd, nil, nil ,nTaxa, cNvTxVld, lBusTx )

				if aRet[1]
					exit
				endIf
				
			endIf
				
			//Agora procuro nos itens por procedimentos (B7U)...  FILHA da BGI
			aRetB7U := VldPreB7S(cCodRda,cOpeOri,cRdaEdi)
					
			if aRetB7U[1]

				aRet := retGP("B7U", __aNiveis[2], nVlrApr, cFinAte, cTipo, cModPag, nBanda, cGruOpe, cCodSeq, cCodPad, cCodPro, nil, nil, aRetB7U[2], nil, nTaxa, cNvTxVld, lBusTx )
					
				if aRet[1]
					exit
				endIf

			endIf
				
			if lPesUnd
				
				//Agora procuro nos itens por UNIDADE (BMQ)... FILHA da BGI
				aRet := retGP("BMQ", __aNiveis[2], nVlrApr, cFinAte, cTipo, cModPag, nBanda, cGruOpe, cCodSeq, cCodPad, cCodPro, nil, cCodUnd, nil, nil ,nTaxa, cNvTxVld, lBusTx )
				
				if aRet[1]
					exit
				endIf
					
			endIf   

			//Agora procuro nos itens por especialidades (BMT)... FILHA da BGI
			aRet := retGP("BMT", __aNiveis[2], nVlrApr, cFinAte, cTipo, cModPag, nBanda, cGruOpe, cCodSeq, cCodPad, cCodPro, nil, nil, nil, cEspec, nTaxa, cNvTxVld, lBusTx )

			if aRet[1]
				exit
			endIf
				
			//Agora procuro nos itens por plano (BSM)...  FILHA da BGI     
			aRet := retGP("BSM", __aNiveis[2], nVlrApr, cFinAte, cTipo, cModPag, nBanda, cGruOpe, cCodSeq, cCodPad, cCodPro, cCodPla, nil, nil, nil ,nTaxa, cNvTxVld, lBusTx )

			if aRet[1]
				exit
			endIf

			//Agora procuro nos itens por procedimentos (BGI)... FILHA da BGH 
			aRet := retGP("BGI", __aNiveis[2], nVlrApr, cFinAte, cTipo, cModPag, nBanda, cGruOpe, cCodSeq, cCodPad, cCodPro, nil, nil, nil ,nil ,nTaxa, cNvTxVld, lBusTx, cCodTab )

			if aRet[1]
				exit
			endIf

		else
			aRet[2] := { cCodTab, nPerCop, nValREA, nTaxa, nValUS, cNivTax, lOK, cPgNoAto, cPgDrRDA, 0, .f., nBanda, nVlrFil, cSeqRel, BGH->BGH_DATINI, BGH->BGH_DATFIN }
		endIf	
		
		BD4->(dbSetOrder(1)) //BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+dtos(BD4_VIGINI)
		if BD4->( msSeek(xFilial("BD4") + cOperadora + iIf( cTipo == "2", BGH->BGH_TABREC, BGH->BGH_TABPAG ) + cCodPad + allTrim(cCodPro) ) )
			while ! BD4->(eof()) .and. BD4->( BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + allTrim(BD4_CODPRO) ) == xFilial("BD4") + cOperadora + iIf( cTipo == "2", BGH->BGH_TABREC, BGH->BGH_TABPAG ) + cCodPad + allTrim(cCodPro)
				if PLSINTVAL("BD4","BD4_VIGINI","BD4_VIGFIM",dDatAnalise)
					lBD4Found := .t.
					exit
				endIf
				BD4->(dbSkip())
			endDo
			If lBD4Found
				aRet[2] := { cCodTab, nPerCop, nValREA, nTaxa, nValUS, cNivTax, .T., cPgNoAto, cPgDrRDA, 0, .f., nBanda, nVlrFil, cSeqRel }
				exit
			endIf
		endIf

	endIf
	PLSGRUOPE->(DbSkip())
                     
enddo       

PLSGRUOPE->(dbCloseArea())
restarea(aAreaBD4)
eval(bRest)

//Cobranca, achei a taxa, entao o % e 100 e a taxa
if cTipo == "2" .and. ( nTaxa > 0 .or. ( nTaxa == 0 .and. cNvTxVld == "1" ) )

	lOK     := .t.
	nPerCop := 100
	if !aRet[1]
		aRet[2] := { cCodTab, nPerCop, nValREA, nTaxa, nValUS, cNivTax, lOK, cPgNoAto, cPgDrRDA, 0, .f., nBanda, nVlrFil, cSeqRel, BGH->BGH_DATINI, BGH->BGH_DATFIN }
	endif
endIf

// quando intercambio, Não cobrar taxa para  atendimentos superiores a 90 dias e para RS 120 dias.
if lInterc .and. (( dData - dDatAnalise) >  nDiasIn) .And. nTaxa > 0 .and. !lRegraRS
    aRet[2,4] := 0
elseif lInterc .and. (( dData - dDatAnalise) >  nDiasInRS) .and. nTaxa > 0 
	aRet[2,4] := 0
endif


return( aRet[2] )

/*/{Protheus.doc} retGP
verifica nivel de parametrizacao
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
static function retGP(cAlias, aNiveis, nVlrApr, cFinAte, cTipo, cModPag, nBanda, cGruOpe, cCodSeq,;
					  cCodPad, cCodPro, cCodPla, cCodUnd, cNivHos, cEspec, nTaxGruOpe, cNvTxVld, lBusTx, cCodTab)
local nPerCop  		:= 0
local nValREA		:= 0
local nValUS		:= 0
local nTaxa			:= 0
local cSql 			:= ""
local cPgNoAto 		:= "0"
local cPgDrRDA 		:= "0"
local cNivTax		:= "BGH"
local lOK			:= .f.
local aRet			:= {}

default nTaxGruOpe	:= 0
default cCodPla 	:= ""
default cCodUnd 	:= ""
default cNivHos		:= ""
default cEspec		:= ""
default lBusTx		:= .f.
default cCodTab  	:= ""

cSQL := " SELECT R_E_C_N_O_ REC "
cSQL += "   FROM " + retSqlName(cAlias) 
cSQL += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' AND "
cSQL += "        " + cAlias + "_GRUOPE = '" + cGruOpe + "' AND "
cSQL += "        " + cAlias + "_CODSEQ = '" + cCodSeq + "' AND "
cSQL += "        " + cAlias + "_CODPAD = '" + cCodPad + "' AND "

if ! empty(cCodPla)
	cSQL += "       " + cAlias + "_CODPLA = '" + cCodPla + "' AND "
endIf
	
if ! empty(cCodUnd)
	cSQL += "       " + cAlias + "_CODUNM = '" + cCodUnd + "' AND "
endIf

if ! empty(cNivHos)
	cSQL += "       " + cAlias + "_NIVHOS = '" + cNivHos + "' AND "
endIf

if ! empty(cEspec)
	cSQL += "       " + cAlias + "_CODESP = '" + cEspec + "' AND "
endIf

cSQL += PLREQNI(cAlias, cAlias + "_CODPRO", aNiveis, allTrim(cCodPro))

cSQL +=  " D_E_L_E_T_ = ' ' "

cSQL +=  " ORDER BY " + cAlias +"_NIVEL DESC "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TRVNIV",.f.,.t.)
	
if ! TRVNIV->(eof())

	(cAlias)->( dbGoto( TRVNIV->REC ) )
	
	//recebimento
	if cTipo == "2" 
		
		//Pre Pagamento
		if allTrim(cModPag) == "1" 
			
			//Valor Recebimento Pre-Pagamento
			if (cAlias)->(fieldPos( cAlias + "_VRRPP")) > 0 
			
				nValREA := (cAlias)->&( cAlias + "_VRRPP" )  

			endIf
			
			//U.S Recebimento Pre-Pagamento
			nValUS  := (cAlias)->&( cAlias + "_USRPP" ) 
			
		//Custo Operacional	
		else 
			
			//Valor Recebimento Pre-Pagamento
			if (cAlias)->(fieldPos( cAlias + "_VRRCO" )) > 0
			
				nValREA := (cAlias)->&( cAlias + "_VRRCO" )  

			endIf
			
			//U.S Recebimento Custo Operacional
			nValUS  := (cAlias)->&( cAlias + "_USRCO" )  
			
		endIf

		nTaxa := 0
		
		//valor da taxa para recebimento
		if (cAlias)->(fieldPos( cAlias + "_TXADPP") ) > 0 .and. (cAlias)->&( cAlias + "_TXADPP" ) > 0
		
			nTaxa 	:= (cAlias)->&( cAlias + "_TXADPP" )
			cNivTax := cAlias
		
		//verifica se e nivel valido se nao for retorna taxa da BGH
		elseIf ( (cAlias)->(fieldPos( cAlias + "_NVVLPP") ) > 0 .and. (cAlias)->&( cAlias + "_NVVLPP" ) <> "1" ) .or. ( (cAlias)->(fieldPos( cAlias + "_TXADPP") ) == 0 )
			
			nTaxa := nTaxGruOpe

		endIf

	else
	
		//Pre Pagamento
		if allTrim(cModPag) == "1" 
		
			if (cAlias)->(fieldPos( cAlias + "_VRPPP" ) ) > 0
			
				nValREA := (cAlias)->&( cAlias + "_VRPPP" )

			endIf

			nValUS  := (cAlias)->&( cAlias + "_USPPP" )
			
		//Custo Operacional
		else
			
			if (cAlias)->(fieldPos( cAlias + "_VRPCO" ) ) > 0
			
				nValREA := (cAlias)->&( cAlias + "_VRPCO" )
			
			endIf

			nValUS := (cAlias)->&( cAlias + "_USPCO" )
			
		endIf
		
		nTaxa := 0
		
		//valor da taxa para pagamento
		if (cAlias)->(fieldPos( cAlias + "_TXADCO" ) ) > 0 .and. (cAlias)->&( cAlias + "_TXADCO" ) > 0
			
			nTaxa 	:= (cAlias)->&( cAlias + "_TXADCO" )
			cNivTax := cAlias
		
		//verifica se e nivel valido se nao for retorna taxa da BGH
		elseIf ( (cAlias)->(fieldPos( cAlias + "_NVVLCO" ) ) > 0 .and. (cAlias)->&( cAlias + "_NVVLCO" ) <> "1" ) .or. (cAlias)->(fieldPos( cAlias + "_TXADCO" ) ) == 0	
			
			nTaxa := nTaxGruOpe

		endIf
		
	endIf
	
	if ( ! lBusTx .and. nValREA > 0 .or. nValUS > 0 ) .or. ( lBusTx .and. nTaxa > 0 )

		lOK     := .t.
		if nValREA > 0 .or. nValUS > 0 
			nPerCop := 0
		else
			nPerCop := 100
		endif
		cNivTax := cAlias

	endIf	

	//Recebimento cTipo == "2"
	if ! lOK .and. cTipo == "2" .and. ( nTaxa > 0 .or. ( nTaxa == 0 .and. cNvTxVld == "1" ) )
		lOK     := .t.
		if nValREA > 0 .or. nValUS > 0 
			nPerCop := 0
		else
			nPerCop := 100
		endif
	endIf
	
endIf

//A taxa deve permanecer sem alteracao caso nao seja um nivel valido
if ! lOK
	nTaxa := nTaxGruOpe
endIf	

aRet := { cCodTab, nPerCop, nValREA, nTaxa, nValUS, cNivTax, lOK, cPgNoAto, cPgDrRDA, 0, .f., nBanda, 0, "" } 

TRVNIV->( dbCloseArea())

return( { lOK, aRet } )				

/*/{Protheus.doc} AnalQtdCOP
Retorna a quantidade de vezes que um usuario realizou uprocedimento
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function AnalQtdCOP(aFaiQtd,nIndice,aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte)
local   aArea   := getArea()
local   cSQL    := "" 
local   cDatIni := subStr(dtos(dDatPro),1,4)+"0101"
local   nPos    := 0
local   cCodNiv := ""
local   nGravi  := 1
local   i 		:= 1
local   cRegPro := ""
local   aRetAux	:= {}
default nQtd    := 1     
default dDatPro := dDataBase
default nRegBD6 := 0
default cHorPro := ""
default cRegAte := ""

cSQL := "SELECT BD6_QTDPRO,BD6_DATPRO,BD6_HORPRO,BD6_ORIMOV FROM "+RetSQLName("BD6")+" WHERE "
cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
cSQL += "BD6_OPEUSR = '"+cCodInt+"' AND "
cSQL += "BD6_CODEMP = '"+cCodEmp+"' AND "
cSQL += "BD6_MATRIC = '"+cMatric+"' AND "
cSQL += "BD6_TIPREG = '"+cTipReg+"' AND "

if ! empty(cHorPro) .and. getNewPar("MV_PLSCHAQ","0") == "1"

	cSQL += "( ( BD6_DATPRO >= '"+cDatIni      +"' AND BD6_DATPRO < '"+dtos(dDatPro)+"' )   OR "
    cSQL += "  ( BD6_DATPRO  = '"+dtos(dDatPro)+"' AND BD6_HORPRO < '"+cHorPro      +"' ) ) AND "
    
else

	cSQL += "( BD6_DATPRO >= '"+cDatIni+"' AND BD6_DATPRO <= '"+dtos(dDatPro)+"' ) AND "
	
endIf

if ! lExtQDCT
   cSQL += "BD6_CODPAD = '"+cCodPad+"' AND "    
else
   cSQL += execBlock("PLSQD6CT",.f.,.f.,{cCodPad})
endIf   

if ! lExtQDCP

   if nIndice == 1
   
      cSQL += "BD6_CODPRO = '"+allTrim(cCodPro)+"' AND "
      
   else
      
      cSQL += "BD6_CDNV0"+StrZero(nIndice-1,1)+" = '"+subStr(cCodPro,aNiveis[2,(nIndice-1),1],aNiveis[2,(nIndice-1),2])+"' AND "
      cSQL += "BD6_NIVEL = '"+aNiveis[2,(nIndice-1),3]+"' AND "
      
   endIf
      
else
   
   if len(aNiveis) > 0 
   
   	   nNiveis := (aNiveis[1]+1)
	
	   while i <= len(aNiveis[2])
	
	     if val(aNiveis[2,i,3]) == nIndice
		    cCodNiv := aNiveis[2,i,4]
		    nGravi  := i  
	     endIf
	     
	     i++
		      
	   endDo
	   
   endIf
   
   cSQL += execBlock("PLSQD6CP",.f.,.f.,{BR8->BR8_NIVEL,nIndice,cCodNiv,nGravi,aNiveis,cCodPad,cCodPro})
      
endIf        

cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND " 

if lPlReChvEst 
	aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)   
 	cSQL     += aRetAux[1]
endIf

cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') ) AND "

if nRegBD6 > 0
   cSQL += "R_E_C_N_O_ <> "+allTrim(Str(nRegBD6))+" AND "
endIf   

cSQL += "D_E_L_E_T_ = ' '"

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"AnalQtdCOP",.f.,.t.)
  
if ! AnalQtdCOP->(eof())  
	plsTField("AnalQtdCOP",.f.,{ "BD6_QTDPRO" } )
endIf
                             
while ! AnalQtdCOP->(eof())
	
	if empty(cRegAte) .or. cRegAte == '3'
	
   		nQtd += AnalQtdCOP->BD6_QTDPRO
   		
   	else   
   		
   		if AnalQtdCOP->BD6_ORIMOV == "2"
   		   cRegPro := "1"
   		else   
   		   cRegPro := cRegAte 
   		endIf
   		
   		if cRegPro == cRegAte
   			nQtd += AnalQtdCOP->BD6_QTDPRO
   		endIf
   		
   	endIf
   	
	AnalQtdCOP->(DbSkip())
	
endDo

AnalQtdCOP->(dbCloseArea())
   
restArea(aArea)

nPos := Ascan(aFaiQtd, {|x| nQtd >= x[1] .and. nQtd <= x[2]} )

return(nPos)  

/*/{Protheus.doc} MonQtdCOP
Funcao generica que monta uma array com os intervalos de cp
Exemplo de parametrizacao 		                      
XXX_QTD                              XXX_PERCOP                                            
4.0                                  0.00             
9.0                                  25.0             
999.0                                50.0             
outra forma:                                          
5.0									 100.0			  
aqui ele entende q ate a quinta ele paga 100% depois 
disso ele paga 0%, mas esta analise eh feita no		 
AnalQtdCOP                                             
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function MonQtdCOP(cSQL,cTrab,cAlias,lQuery,cChave,cCondAdic,bCondic,lCompra,dDatPro,aDadUsr,cFinAte,bCondVig,cRegAte)
local aArea    := getArea()                                   
local nQtdFin  := 99
local nQtdIni  := 1
local aFaiQtd  := {}         
local cCpoCop  := ""
local dDtIni   := CtoD(" / / ")
local dDtFin   := CtoD(" / / ")
local lValZero := getNewPar("MV_PLSVLZE",.f.)
local lLoop    := .f.
local cCompra  := ""
local cSomCom  := ""
local nIdade   := 0
local nIdaIni  := 0
local nIdaFin  := 0
local cTipoRgAte := ""

default lQuery   := .t.         
default cChave   := ".t."                           
default cCondAdic:= ".t."                         
default bCondic  := { || .t. }
default lCompra  := .f.  
default dDatPro	 := CtoD("")  
default aDadUsr  := PLSGETUSR()
default cFinAte	 := ""
default bCondVig := {|| .t. }
default cRegAte  := ""

if !aDadUsr[1] .or. len(aDadUsr) < 82
    bCond3   := { || .t. }
endIf

if lQuery             

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),cTrab,.f.,.t.)
  
else
	cTrab := cAlias
endIf          

if cAlias $ "BHF,BVM,BVJ,BVC,BVF"
	cCpoCop := "VALCOP"
else
	cCpoCop := "VLRCOP"
endif

if ! &(cTrab)->(eof())  
	
	if lQuery                                    
		plsTField(cTrab, .t.)
	endIf
		
    while ! &(cTrab)->(eof()) .and. &(cChave) .and. eval(bCondic)
		
		//nao cobra co participacao para eventos diferentes de procedimento (ex: ortese, materiais, ...) e pacote quando ???_SOMPRO = 1 (Sim) (somente procedimento)
		if &(cTrab)->(FieldPos(cAlias+"_SOMPRO")) > 0 .And. &(cTrab+"->"+cAlias+"_SOMPRO") == "1" .and. !(BR8->BR8_TPPROC $ " ,0,6")
			lLoop := .t.
		endIf
	    
	    //se nao tenho a data do evento nao tem como verificar vigencia, verifica se tem vigencia e esta cumprida
	    if !lLoop .and. ( !empty(dDatPro) .and. !(AnaDataCOP(dDatPro,cAlias)) )
	    	lLoop := .t.
	    endIf
		
		//nao compra co participacao quando ???_SOMCOM = 1 (somente para compra)
		if &(cTrab)->(FieldPos(cAlias+"_SOMCOM")) > 0
			cSomCom := &(cTrab+"->"+cAlias+"_SOMCOM")
			cCompra := Iif(lCompra,"1","0")
		endif
		
	    if !lLoop .and. !(cSomCom == cCompra)
	    	lLoop := .t.
	    endIf

		//verifica se a co participacao se aplica ao tipo de usuario que esta sendo atendido
	    if !lLoop
	    
	    	if &(cTrab)->(FieldPos(cAlias+"_TIPUSR")) > 0 .and. !( &(cTrab+"->"+cAlias+"_TIPUSR") == aDadUsr[82] .or. empty(&(cTrab+"->"+cAlias+"_TIPUSR")) )
    	    	lLoop := .t.
    	    endIf
	    endIf

		//verifica se a co participacao se aplica ao regime de atendimento que esta sendo efetuado o atendimento
	    if !lLoop .and. &(cTrab)->(fieldPos(cAlias+"_TIPO" )) > 0
	    	
	    	cTipoRgAte := &(cTrab+"->"+cAlias+"_TIPO")
	    	
	    	if empty(cRegAte) .or. ( cTipoRgAte != '3' .and. cTipoRgAte != cRegAte )
    	    	lLoop := .t.
	    	endIf
	    endIf

		// verifica se a idade do beneficiario esta dentro da parametrizada
		if !lLoop .and. &(cTrab)->(fieldPos(cAlias+"_IDAINI" )) > 0 .and. &(cTrab)->(fieldPos(cAlias+"_IDAFIN" )) > 0;
			.and. !empty(aDadUsr[26])
			nIdade := Calc_Idade(dDatPro, aDadUsr[26])

			nIdaIni := &(cTrab+"->"+cAlias+"_IDAINI")
			nIdaFin := iif( &(cTrab+"->"+cAlias+"_IDAFIN") > 0, &(cTrab+"->"+cAlias+"_IDAFIN"), 999)

			if nIdade < nIdaIni .or. nIdade > nIdaFin
				lLoop := .t.
			endif
		endif

	    if !lLoop .and. !(eval(bCondVig))
	    	lLoop := .t.
	    endIf

		//verifica o percentual se for compra de procedimento	    
	    if !lLoop .and. (lCompra .and. !( ( &(cTrab+"->"+cAlias+"_PERCOP") > 0 .or. lValZero ) .or. iif ( &(cTrab)->(fieldPos(cAlias+"_"+cCpoCop)) > 0,; 	
	    										 &(cTrab+"->"+cAlias+"_"+cCpoCop) > 0 , "" )))
	    	lLoop := .t.
	    endIf
			      
		// Tratamento da finalidade de atendimento
		if !lLoop .and. &(cTrab)->(fieldPos(cAlias+"_FINATE")) > 0 .and. ( ! empty( &(cTrab+"->"+cAlias+"_FINATE") ) .and. allTrim( &(cTrab+"->"+cAlias+"_FINATE") ) <> allTrim(cFinAte) )
			lLoop := .t.
		endIf

    	if lLoop
    		&(cTrab)->(dbSkip())
    		lLoop := .f.
    		Loop
    	endIf

        if( &(cAlias)->(fieldPos(cAlias+"_QTD"))) > 0     
			nQtdFin := &(cTrab+"->"+cAlias+"_QTD")
		endif
		
		aadd(aFaiQtd,{	nQtdIni,;
						nQtdFin,;
						subStr(&(cTrab+"->"+cAlias+"_CODTAB"),5,3),;
						&(cTrab+"->"+cAlias+"_PERCOP"),;
						iif( &(cAlias)->(fieldPos(cAlias+"_"+cCpoCop)) > 0, &(cTrab+"->"+cAlias+"_"+cCpoCop), 0),;
						iif( &(cAlias)->(fieldPos(cAlias+"_PAGATO")) > 0, &(cTrab+"->"+cAlias+"_PAGATO"), ""),;
						&(cTrab+"->"+cAlias+"_TXADM"),;
						&(cTrab+"->"+cAlias+"_VALUS"),;
						&(cTrab+"->"+cAlias+"_LIMFRA"),;
						iif( &(cAlias)->(fieldPos(cAlias+"_PAGRDA")) > 0, &(cTrab+"->"+cAlias+"_PAGRDA"), "" ),;
						nQtdFin-nQtdIni+1,;
						iif( &(cAlias)->(fieldPos(cAlias+"_PAGDIF")) > 0,Iif(empty(&(cTrab+"->"+cAlias+"_PAGDIF")),.f.,&(cTrab+"->"+cAlias+"_PAGDIF") == '1'),.f.),;
						iif( &(cAlias)->(fieldPos(cAlias+"_VLRATE")) > 0 .and. &(cTrab)->(fieldPos(cAlias+"_PAGDIF")) > 0 .and. &(cTrab+"->"+cAlias+"_PAGDIF") == '1',&(cTrab+"->"+cAlias+"_VLRATE"),0),;
						iif( &(cAlias)->(fieldPos(cAlias+"_ANOMES")) > 0,&(cTrab+"->"+cAlias+"_ANOMES"),''),;
						iif( &(cAlias)->(fieldPos(cAlias+"_VLRANT")) > 0,&(cTrab+"->"+cAlias+"_VLRANT"),0),;
						dDtIni,;
						dDtFin,;
						cTipoRgAte}) //18
						
		if( &(cAlias)->(fieldPos(cAlias+"_QTD"))) > 0 
			nQtdIni := &(cTrab+"->"+cAlias+"_QTD") + 1
		else 
			nQtdIni := nQtdIni + 1
		endif
			
	&(cTrab)->(DbSkip())
	endDo                        

	lLoop := .f.
	
endIf

&(cTrab)->(dbCloseArea())       
restArea(aArea)

return (aFaiQtd)

/*/{Protheus.doc} AnaDataCOP
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
static function AnaDataCOP(dDatPro,cAlias)
local lRet := .f.
local dCpoDat1
local dCpoDat2

DbSelectArea(cAlias)
if fieldPos(cAlias+"_VIGDE") == 0 .or. fieldPos(cAlias+"_VIGATE") == 0
   lRet := .t.
elseIf fieldPos(cAlias+"_VIGINI") == 0 .or. fieldPos(cAlias+"_VIGFIN") == 0
   lRet := .t.
else
   dCpoDat1 := &(cAlias+"->"+cAlias+"_VIGDE")
   dCpoDat2 := &(cAlias+"->"+cAlias+"_VIGATE")
   
   if     empty(dCpoDat1) .and. empty(dCpoDat2)
          lRet := .t.
   elseIf dtos(dDatPro) >= dtos(dCpoDat1) .and. (dtos(dDatPro) <= dtos(dCpoDat2) .or. empty(dCpoDat2))
          lRet := .t.
   endIf
endIf

return(lRet)

/*/{Protheus.doc} AnalQtdCO2
No futuro a AnalQtdCOP tem q ser subs. por essa aqui
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function AnalQtdCO2(aFaiQtd,nIndice,aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,lMudarFase,cAliasNiv)
local   aArea   	:= getArea()
local   aAreaBE4   	:= BE4->(getArea())
local   cSQL    	:= "" 
local   cDatIni 	:= subStr(dtos(dDatPro),1,4)+"0101"
local   cDatFim 	:= subStr(dtos(dDatPro),1,4)+"1231"
local   nAux    	:= 0   
local   aRet    	:= {} 
local   aQtds   	:= {}  
local   aRetAux 	:= {}                                    
local   nQtdSol 	:= 0                                     
local   nfor		:= 0
local   cCodNiv 	:= ""
local   nGravi  	:= 1
local   i 			:= 1      
local   ntot 		:= 0
local   cRegPro 	:= ""                               
local   cFilBE4 	:= xFilial("BE4")
local   cMVPLCOPAC	:= getNewPar("MV_PLCOPAC","0")
local 	cMVPLSCHAQ	:= getNewPar("MV_PLSCHAQ","0")
local   nTamNiv     := 0
local   nTot2 		:= 0
local   lAmbos 		:= .f.
local	aTot		:= {}
local	nTotAux		:= 0

default nQtd    	:= 1              
default dDatPro 	:= dDataBase
default nRegBD6 	:= 0
default cHorPro 	:= ""
default cRegAte 	:= ""
default cGrpInt 	:= ""
default lMudarFase 	:= .t.
default cAliasNiv	:= ""

BE4->(dbsetOrder(1))
//Verifica se o usuario considera ano civil ou contratual para    
//para calculo de quantidades na co-participacao               
BA1->(dbsetOrder(2))//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGIto
if BA1->(msSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg)) .and. cMVPlCoPac == "1"    
	//Parâmetro com 1
	
	//Se ano posterior a inclusao, verifica se a data do procedimento (dia/mes)|  
	//é superior a data de inclusao. Se inferior, considera ano -1 , superior  |
	//considera ano vigente do evento                                       
    if (Val(subStr(DtoS(dDatPro),1,4)) - Val(subStr(DtoS(BA1->BA1_DATINC),1,4))) > 0                 
    	//Ano do evento maior que o ano da inclusão           

    	if dDatPro > Stod(cValtoChar(Val(subStr(DtoS(dDatPro),1,4)))+subStr(DtoS(BA1->BA1_DATINC),5,4) )
    		//Data do evento maior que o dia e mês da inclusão + ano do evento (não completou um ano)
            cDatIni := allTrim(subStr(DtoS(dDatPro),1,4) + subStr(DtoS(BA1->BA1_DATINC),5,4))
            //Ano do evento + (mes e dia) data de inclusão
	    else
	    	//Data do evento menor ou igual ao dia e mês da inclusão + ano do evento (beneficiário ha mais de 1 ano)
			cDatIni := cValtoChar(Val(subStr(DtoS(dDatPro),1,4))- 1)+subStr(DtoS(BA1->BA1_DATINC),5,4) 
			//ano do evento menos 1 + dia e mÊs da inclusão
		endIf
		
	//Mesmo ano da inclusao utiliza ano do evento		
	else
		//Ano do evento igual ao ano da inclusão
    	cDatIni := cValtoChar(Val(subStr(DtoS(dDatPro),1,4))) + subStr(DtoS(BA1->BA1_DATINC),5,4) 
    	//Ano do evento + data da inclusão
	endIf
	
	cDatFim := dtos((stod(cDatIni)+365)-1)
	//data fim é um ano somado à data inicial
endIf

If nIndice > 1
	nTamNiv:= Len(aNiveis[2])
EndIf

//Vetor de quantidades							
for nfor := 1 to len(aFaiQtd)
	if (aFaiQtd[nfor][18] == "3")
		lAmbos := .t.
	endif
	aadd(aQtds,{aFaiQtd[nfor][11],aFaiQtd[nfor][4],"",aFaiQtd[nfor][1],aFaiQtd[nfor][2],0,aFaiQtd[nfor][18] == "3"})
next     

//Seleciono  a quantidade de procedimentos que ja fez  |
cSQL := "SELECT R_E_C_N_O_,BD6_CNTCOP,BD6_DATPRO,BD6_HORPRO,BD6_QTDPRO,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_FASE,BD6_SEQUEN,BD6_PERCOP FROM "+RetSQLName("BD6")+" WHERE "
cSQL += "BD6_FILIAL = '" + xFilial("BD6") + "' AND "
cSQL += "BD6_OPEUSR = '" + cCodInt + "' AND "
cSQL += "BD6_CODEMP = '" + cCodEmp + "' AND "
cSQL += "BD6_MATRIC = '" + cMatric + "' AND "
cSQL += "BD6_TIPREG = '" + cTipReg + "' AND "

If lExQDDT
	cSql += execBlock("PLSQD6DT",.f.,.f.,{cDatIni, cDatFim, dDatPro})
elseif ! empty(cHorPro) .and. cMVPLSCHAQ == "1"
	cSQL += "( ( BD6_DATPRO >= '" + cDatIni      + "' AND BD6_DATPRO < '" + cDatFim + "' )   OR "
    cSQL += "  ( BD6_DATPRO  = '" + dtos(dDatPro)+ "' AND BD6_HORPRO < '" + cHorPro + "' ) ) AND "
else   
    
    // MUDANÇA DE FASE SEM ANALISE DE GLOSA
	if ! lPLSA500ACT 
		
	   	cSQL += " BD6_DATPRO BETWEEN  '" + cDatIni + "' AND '" + cDatFim + "' AND "
	   	
	else 
	  
		//³Devido a Guia estar em analise de glosa o sistema tem que enteder que ela perdeu a 
		//³sua ordem natural portanto, temos que analisar não somente as guias anteriores e sim³ 
		//³considerar ano civil ou contratual para  calculo de quantidades na co-participação 
		// por ano civil
		
		if cMVPLCOPAC == "0"			   
			
			cSQL += "( BD6_DATPRO >= '" + dtos(ctod("01/01/"+allTrim(str(Year(dDatPro))))) + "' AND BD6_DATPRO <= '" + dtos(ctod("31/12/"+allTrim(str(Year(dDatPro))))) + "' ) AND "
				
		// por data de inclusao do usuario
		else	      
	   	
	   	   cSQL += " BD6_DATPRO BETWEEN  '" + cDatIni + "' AND '" + cDatFim + "' AND "
		
		endIf	   
		   
	endIf
			
endIf

if ! lExtQDCT

   cSQL += "BD6_CODPAD = '" + cCodPad + "' AND "
       
else

   cSQL += execBlock("PLSQD6CT",.f.,.f.,{cCodPad})
   
endIf   

if ! lExtQDCP

   if nIndice == 1 .Or. ((nIndice-1) > nTamNiv)

      cSQL += "BD6_CODPRO = '" + allTrim(cCodPro) + "' AND "

   else

      cSQL += "BD6_CDNV0" + StrZero(nIndice-1,1) + " = '" + subStr(cCodPro,aNiveis[2,(nIndice-1),1],aNiveis[2,(nIndice-1),2])+"' AND "
      cSQL += "BD6_NIVEL = '" + aNiveis[2,(nIndice-1),3] + "' AND "

   endIf
      
else

   	if len(aNiveis) > 0 
  	
  	   	nNiveis := (aNiveis[1]+1)
	
	   	while i <= len(aNiveis[2])
	
		   if val(aNiveis[2,i,3]) == nIndice
			  cCodNiv := aNiveis[2,i,4]
			  nGravi  := i  
		   endIf
		   
		i++ 
	   	endDo
	   	
   endIf
   
   cSQL += execBlock("PLSQD6CP",.f.,.f.,{BR8->BR8_NIVEL,nIndice,cCodNiv,nGravi,aNiveis,cCodPad,cCodPro})
      
endIf   

//³O campo BD6_CNTCOP  foi criado devido no momento          
//³que esta passando pelo calculo da co-participação o campo 
//³BD6_FASE ainda nao foi preenchido e numa guia com varios  
//³procedimentos do mesmo não estava contando os itens anteriores³
//³da Guia.                                                  
if !lMudarFase
	cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4' ) AND BD6_CNTCOP = '1' AND "
else
	cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4' OR BD6_CNTCOP = '1' ) AND "	
endIf	

if lPlReChvEst
	aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)   
 	cSQL     += aRetAux[1]
endIf

cSQL += "( BD6_FASE <> '2' AND BD6_SITUAC = '1'  OR  BD6_SITUAC = '3' )  AND "
cSQL += "( BD6_ENVCON <> '1' OR BD6_BLOPAG <> '1' ) AND " 

if nRegBD6 > 0
   cSQL += "R_E_C_N_O_ <> " + allTrim(Str(nRegBD6)) + " AND "
endIf   

cSQL += "D_E_L_E_T_ = ' ' "  

//cSQL += "ORDER BY BD6_NUMERO,BD6_SEQUEN "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"AnalQtdCOP",.f.,.t.)

if !AnalQtdCOP->(eof())
	plsTField("AnalQtdCOP", .f.,{"BD6_QTDPRO","BD6_DATPRO"})
endIf	

while !AnalQtdCOP->(eof())
		
    if AnalQtdCOP->BD6_ORIMOV == "2"
       BE4->( msSeek( cFilBE4 + AnalQtdCOP->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ) )
    endIf

	if empty(cRegAte) .or. cRegAte == '3'
	
   		if AnalQtdCOP->BD6_ORIMOV <> "2"
   		   nTot += AnalQtdCOP->BD6_QTDPRO 
   		else
   		
   		   if empty(cGrpInt)
   		      ntot += AnalQtdCOP->BD6_QTDPRO 
   		   else
   		      
   		      if BE4->(BE4_GRPINT+BE4_TIPINT) == cGrpInt
    		     ntot += AnalQtdCOP->BD6_QTDPRO 
   		      endIf
   		      
   		   endIf
   		      
   		endIf
   		   
   	else   
   		
	 	if AnalQtdCOP->BD6_ORIMOV == "2"
	  		cRegPro := "1"
	  	else   
   			cRegPro := if(PLSUSRINTE(cCodInt+cCodEmp+cMatric+cTipReg,AnalQtdCOP->BD6_DATPRO,AnalQtdCOP->BD6_HORPRO,.f.,.t.)[1],"1","2") 
   		endIf
   		
   		if  cRegPro == cRegAte .or. lAmbos
   		    lRegDif := cRegPro == cRegAte
   		    if AnalQtdCOP->BD6_ORIMOV <> "2"
   		       iif(lRegDif,nTot += AnalQtdCOP->BD6_QTDPRO,nTot2 += AnalQtdCOP->BD6_QTDPRO)
   		    else
   		    
   		       if empty(cGrpInt)
   		          iif(lRegDif,nTot += AnalQtdCOP->BD6_QTDPRO,nTot2 += AnalQtdCOP->BD6_QTDPRO)
   		       else
   		    
   		          if BE4->(BE4_GRPINT+BE4_TIPINT) == cGrpInt
    		         iif(lRegDif,nTot += AnalQtdCOP->BD6_QTDPRO,nTot2 += AnalQtdCOP->BD6_QTDPRO) 
   		          endIf
   		          
   		       endIf
   		          
   		    endIf
   		       
   		endIf
   		
   	endIf
   	
AnalQtdCOP->(DbSkip())
endDo

//³Caso ja tenha informações de item com co-participação para    		
//³o usuario, verifico se essa informação se esta acompanhando a   		
//³a ordem estabelecida na BHI com os intervalos, esse tratamento  	 	   		
//³se dá para as guias que tiveram sua fase retornada ou recalculadas.	
/*AnalQtdCOP->(dbGotop())

if !AnalQtdCOP->(eof())
	nTot := VerInterCp(ntot,aQtds) // Verifico se a Guia esta dentro dos intervalos estabelecidos na BHI 
endIf
*/

//³Se a guia corrente estiver 100% glosada nao podemos contar³
//³pois não sabemos se será Glosada ou reconsiderada caso seja³
//³glosada não poderá sera contada.                      
if BD6->BD6_VLRGLO > 0 .and. BD6->BD6_VLRGLO == BD6->BD6_VLRMAN
	ntot := 0
	nTot2 := 0
endIf

//Vetor de quantidades atualizado (qtd-qtd realizada)  |
nAux := 0        
aadd(aTot,nTot)
aadd(aTot,nTot2)
for nfor := 1 to len(aQtds)
	  if aQtds[nFor,7]
		nTotAux := aTot[1] + aTot[2]
	  else
	  	nTotAux := aTot[1]
	  endif

      if nTotAux == 0
      	exit
      endIf
                        
      nAux += aQtds[nfor,1]
      
      if nAux >= nTotAux
      		aQtds[nfor,1] := nAux - nTotAux
      		exit
      else
      		aQtds[nfor,1] := 0 
      endIf
      
next

//Quantidade Solicitada							     
nQtdSol := nQtd                                           

//Essa array ja retorna as qtdes a serem realizadas 
//por nivel							 			
for nfor := 1 to len(aQtds)

	if aQtds[nfor,1] < nQtdSol .and. aQtds[nfor,1] != 0
		aadd(aRet,{aQtds[nfor,1],nfor})
		nQtdSol -= aQtds[nfor,1]
	elseIf aQtds[nfor,1] != 0
 		aadd(aRet,{nQtdSol,nfor})		
		exit
	endIf
	
next

AnalQtdCOP->(dbCloseArea())
	
BE4->(restArea(aAreaBE4))
restArea(aArea)

return(aRet)  

/*/{Protheus.doc} PlRetVigCP

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PlRetVigCP(dDatPro,cAlias,lSQL)
local aRet    := {.t.,""}
local dVigDe  := ctod('')
local dVigAte := ctod('')

if &(cAlias+"->(fieldPos('"+cAlias+"_VIGDE"+"'))") > 0 .and. &(cAlias+"->(fieldPos('"+cAlias+"_VIGATE"+"'))") > 0
	
	dVigDe := &(cAlias+"->"+cAlias+"_VIGDE")
	dVigAte:= &(cAlias+"->"+cAlias+"_VIGATE")
	
	if !lSQl .and. ( ( !empty(dVigDe) .and. !empty(dVigAte) .and. ((dDatPro < dVigDe) .or. (dDatPro > dVigAte))) .or. ;
					 ( !empty(dVigDe) .and. empty(dVigAte) .and. dDatPro < dVigDe  ) .or.;
					 ( empty(dVigDe)  .and. !empty(dVigAte) .and. dDatPro > dVigAte  ))
		
		aRet[1] := .f.
		
	elseIf lSql
		
		aRet[2] += " ( '"+dtos(dDatPro)+"' >= "+cAlias+"_VIGDE  OR "+cAlias+"_VIGDE = '        ' ) AND "
		aRet[2] += " ( '"+dtos(dDatPro)+"' <= "+cAlias+"_VIGATE OR "+cAlias+"_VIGATE = '        ' ) AND "
		
	endIf
	
endIf

if !lSQL
	return aRet[1]
else
	return aRet[2]
endIf

return 

/*/{Protheus.doc} VerInterCpºAutor
Verifico se a Guia esta dentro dos intervalos estabelecidosna BHI
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
static function VerInterCp(ntot,aQtds)
local nQtds		:= 0
local i			:= 0          
local lAnterBrc := .f.
local nPos		:= 0

while ! AnalQtdCOP->(eof())
 
    nPos := Ascan(aQtds,{|x| x[2] == (AnalQtdCOP->(BD6_PERCOP))})
    
    if nPos > 0
	
		aQtds[nPos][6] += AnalQtdCOP->(BD6_QTDPRO)
		     
	    if ((aQtds[nPos][5] - aQtds[nPos][4])+1) == aQtds[nPos][6]
	    	aQtds[nPos][3] := "S"
	    endIf
	    
    endIf
    	
AnalQtdCOP->(DbSkip())
endDo      

AnalQtdCOP->(dbGotop())
  
while ! AnalQtdCOP->(eof())
 
    lAnterBrc := .f.
    
    nPos := Ascan(aQtds,{|x| x[2] == (AnalQtdCOP->(BD6_PERCOP))})
    
    if nPos > 0 
	
	    for i := 1 to nPos
	    
            if aQtds[i][3] == ""
            
               lAnterBrc := .t. // HÁ FAIXAS ANTERIORES EM BRANCO E PRECISA SER PREECNHER RESPEITANDO O CADASTRO
               exit
               
            endIf
            
    	next i
    	
    endIf	

	if !lAnterBrc 
   		nQtds += AnalQtdCOP->(BD6_QTDPRO)  // conto somente os itens que nao foram calculados a co-participaçao
    endIf
    
AnalQtdCOP->(DbSkip())
endDo      

nTot := nQtds

return nTot
      
/*/{Protheus.doc} VldPreB7S
Verifica se vai verificar parametrizacao na B7S
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
static function VldPreB7S(cCodRda,cOpeOri,cRdaEdi)
local lRet       := .f.
local aAreaBAU   := BAU->(getArea())     
local aAreaBA0   := BA0->(getArea())
local aAreaBK6   := BK6->(getArea())  
local cCodNivHos := ""   
local cUFOpeOri  := ""  

default cCodRda  := ""
default cOpeOri  := ""
default cRdaEdi  := ""

//Analisando uma guia importadada via A500         
if !empty(cRdaEdi)

	BAU->(dbsetOrder(1))//BAU_FILIAL + BAU_CODIGO
	if BAU->(msSeek(xFilial("BAU") + cCodRda)) .and. !empty(BAU->BAU_CODOPE)

		BK6->(dbsetOrder(4))//BK6_FILIAL + BK6_CODEDI + BK6_OPEEDI 
		if BK6->(msSeek(xFilial("BK6") + cRdaEdi + BAU->BAU_CODOPE)) .and. !empty(BK6->BK6_HOSINT) 
			cCodNivHos := BK6->BK6_HOSINT	
		endIf

	endIf  

	BA0->(dbsetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	if BA0->(msSeek(xFilial("BA0")+BAU->BAU_CODOPE))
		cUFOpeOri := BA0->BA0_EST	            
	endIf

//Analisando uma guia de solicitacao intercambio   
else

	BAU->(dbsetOrder(1))//BAU_FILIAL + BAU_CODIGO
	if BAU->(msSeek(xFilial("BAU") + cCodRda)) .and. ! empty(BAU->BAU_HOSINT)
		cCodNivHos := BAU->BAU_HOSINT
	endIf
		
	BA0->(dbsetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	if BA0->(msSeek(xFilial("BA0") + cOpeOri))
		cUFOpeOri := BA0->BA0_EST	            
	endIf

endIf

//Verifica se a operadora anlisada pertence ao mesmo estado
if ! empty(cCodNivHos) .and. BA0->( msSeek( xFilial("BA0") + PlsIntPad() ) ) .and. BA0->BA0_EST == cUFOpeOri
	lRet := .t.
endIf  

restArea(aAreaBAU)    
restArea(aAreaBA0)
restArea(aAreaBK6)

return({lRet,cCodNivHos})


/*/{Protheus.doc} QTDEveCop

@type function
@author Oscar Zanin
@since 14/06/2019
@version 1.0
/*/
static function QTDEveCop(nIndice,aNiveis,cCodPad,cCodPro,dDatPro,cCodInt,cCodEmp,cMatric,cTipReg,nQtd,nRegBD6,cHorPro,cRegAte,cGrpInt,lMudarFase,cEspec)
local   aArea   	:= getArea()
local   aAreaBE4   	:= BE4->(getArea())
local   cSQL    	:= "" 
local   cDatIni 	:= subStr(dtos(dDatPro),1,4)+"0101"
local   cDatFim 	:= subStr(dtos(dDatPro),1,4)+"1231"
local   aRetAux 	:= {}                                    
local   cCodNiv 	:= ""
local   nGravi  	:= 1
local   i 			:= 1      
local   ntot 		:= 0
local   cRegPro 	:= ""                               
local   cFilBE4 	:= xFilial("BE4")
local   cMVPLCOPAC	:= getNewPar("MV_PLCOPAC","0")
local 	cMVPLSCHAQ	:= getNewPar("MV_PLSCHAQ","0")
local   nTamNiv     := 0

//default aFaiQtd	:= {}
default nIndice	:= 1
default nQtd    	:= 1              
default dDatPro 	:= dDataBase
default nRegBD6 	:= 0
default cHorPro 	:= ""
default cRegAte 	:= ""
default cGrpInt 	:= ""
default lMudarFase 	:= .t.
Default cEspec	:= ""

BE4->(dbsetOrder(1))
//Verifica se o usuario considera ano civil ou contratual para    
//para calculo de quantidades na co-participacao               
BA1->(dbsetOrder(2))//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGIto
if BA1->(msSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg)) .and. cMVPlCoPac == "1"    
	
	//Se ano posterior a inclusao, verifica se a data do procedimento (dia/mes)|  
	//é superior a data de inclusao. Se inferior, considera ano -1 , superior  |
	//considera ano vigente do evento                                       
    if (Val(subStr(DtoS(dDatPro),1,4)) - Val(subStr(DtoS(BA1->BA1_DATINC),1,4))) > 0                 

    	if dDatPro > Stod(cValtoChar(Val(subStr(DtoS(dDatPro),1,4)))+subStr(DtoS(BA1->BA1_DATINC),5,4) )
            cDatIni := allTrim(subStr(DtoS(dDatPro),1,4) + subStr(DtoS(BA1->BA1_DATINC),5,4))
	    else
			cDatIni := cValtoChar(Val(subStr(DtoS(dDatPro),1,4))- 1)+subStr(DtoS(BA1->BA1_DATINC),5,4) 
		endIf
	//Mesmo ano da inclusao utiliza ano do evento		
	else
    	cDatIni := cValtoChar(Val(subStr(DtoS(dDatPro),1,4))) + subStr(DtoS(BA1->BA1_DATINC),5,4) 
	endIf
	
	cDatFim := dtos((stod(cDatIni)+365)-1)
endIf

If nIndice > 1
	nTamNiv:= Len(aNiveis[2])
EndIf

//Seleciono  a quantidade de procedimentos que ja fez  |
cSQL := "SELECT R_E_C_N_O_,BD6_CNTCOP,BD6_DATPRO,BD6_HORPRO,BD6_QTDPRO,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_FASE,BD6_SEQUEN,BD6_PERCOP FROM "+RetSQLName("BD6")+" WHERE "
cSQL += "BD6_FILIAL = '" + xFilial("BD6") + "' AND "
cSQL += "BD6_OPEUSR = '" + cCodInt + "' AND "
cSQL += "BD6_CODEMP = '" + cCodEmp + "' AND "
cSQL += "BD6_MATRIC = '" + cMatric + "' AND "
cSQL += "BD6_TIPREG = '" + cTipReg + "' AND "
cSql += "BD6_CODESP = '" + cEspec + "' AND "

If lExQDDT
	cSql += execBlock("PLSQD6DT",.f.,.f.,{cDatIni, cDatFim, dDatPro})
elseif ! empty(cHorPro) .and. cMVPLSCHAQ == "1"
	cSQL += "( ( BD6_DATPRO >= '" + cDatIni      + "' AND BD6_DATPRO < '" + cDatFim + "' )   OR "
    cSQL += "  ( BD6_DATPRO  = '" + dtos(dDatPro)+ "' AND BD6_HORPRO < '" + cHorPro + "' ) ) AND "
else   
    // MUDANÇA DE FASE SEM ANALISE DE GLOSA
	if ! lPLSA500ACT 
		
	   	cSQL += " BD6_DATPRO BETWEEN  '" + cDatIni + "' AND '" + cDatFim + "' AND "
	else 
	  
		//³Devido a Guia estar em analise de glosa o sistema tem que enteder que ela perdeu a 
		//³sua ordem natural portanto, temos que analisar não somente as guias anteriores e sim³ 
		//³considerar ano civil ou contratual para  calculo de quantidades na co-participação 
		// por ano civil
		
		if cMVPLCOPAC == "0"			   
			
			cSQL += "( BD6_DATPRO >= '" + dtos(ctod("01/01/"+allTrim(str(Year(dDatPro))))) + "' AND BD6_DATPRO <= '" + dtos(ctod("31/12/"+allTrim(str(Year(dDatPro))))) + "' ) AND "
		// por data de inclusao do usuario
		else	      
	   	
	   	   cSQL += " BD6_DATPRO BETWEEN  '" + cDatIni + "' AND '" + cDatFim + "' AND "
		endIf	     
	endIf		
endIf

if ! lExtQDCT

   cSQL += "BD6_CODPAD = '" + cCodPad + "' AND "
else

   cSQL += execBlock("PLSQD6CT",.f.,.f.,{cCodPad})
endIf   

if ! lExtQDCP

   if nIndice == 1 .Or. ((nIndice-1) > nTamNiv)

      cSQL += "BD6_CODPRO = '" + allTrim(cCodPro) + "' AND "
   else

      cSQL += "BD6_CDNV0" + StrZero(nIndice-1,1) + " = '" + subStr(cCodPro,aNiveis[2,(nIndice-1),1],aNiveis[2,(nIndice-1),2])+"' AND "
      cSQL += "BD6_NIVEL = '" + aNiveis[2,(nIndice-1),3] + "' AND "
   endIf
else

   	if len(aNiveis) > 0 
  	
  	   	nNiveis := (aNiveis[1]+1)
	
	   	while i <= len(aNiveis[2])
	
		   if val(aNiveis[2,i,3]) == nIndice
			  cCodNiv := aNiveis[2,i,4]
			  nGravi  := i  
		   endIf
			i++ 
	   	endDo
   endIf
   
   cSQL += execBlock("PLSQD6CP",.f.,.f.,{BR8->BR8_NIVEL,nIndice,cCodNiv,nGravi,aNiveis,cCodPad,cCodPro})
      
endIf   

//³O campo BD6_CNTCOP  foi criado devido no momento          
//³que esta passando pelo calculo da co-participação o campo 
//³BD6_FASE ainda nao foi preenchido e numa guia com varios  
//³procedimentos do mesmo não estava contando os itens anteriores³
//³da Guia.                                                  
if !lMudarFase
	cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4' ) AND BD6_CNTCOP = '1' AND "
else
	cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4' OR BD6_CNTCOP = '1' ) AND "	
endIf	

if lPlReChvEst
	aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)   
 	cSQL     += aRetAux[1]
endIf

cSQL += "( BD6_FASE <> '2' AND BD6_SITUAC = '1'  OR  BD6_SITUAC = '3' )  AND "
cSQL += "( BD6_ENVCON <> '1' OR BD6_BLOPAG <> '1' ) AND " 

if nRegBD6 > 0
   cSQL += "R_E_C_N_O_ <> " + allTrim(Str(nRegBD6)) + " AND "
endIf   

cSQL += "D_E_L_E_T_ = ' ' "  

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"AnalQtdCOP",.f.,.t.)

if !AnalQtdCOP->(eof())
	plsTField("AnalQtdCOP", .f.,{"BD6_QTDPRO","BD6_DATPRO"})
endIf	

while !AnalQtdCOP->(eof())
		
    if AnalQtdCOP->BD6_ORIMOV == "2"
       BE4->( msSeek( cFilBE4 + AnalQtdCOP->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ) )
    endIf

	if empty(cRegAte) .or. cRegAte == '3'
	
   		if AnalQtdCOP->BD6_ORIMOV <> "2"
   		   nTot += AnalQtdCOP->BD6_QTDPRO 
   		else
   		
   		   if empty(cGrpInt)
   		      ntot += AnalQtdCOP->BD6_QTDPRO 
   		   else
   		      
   		      if BE4->(BE4_GRPINT+BE4_TIPINT) == cGrpInt
    		     ntot += AnalQtdCOP->BD6_QTDPRO 
   		      endIf
   		   endIf
   		endIf 
   	else   
   		
	 	if AnalQtdCOP->BD6_ORIMOV == "2"
	  		cRegPro := "1"
	  	else   
   			cRegPro := if(PLSUSRINTE(cCodInt+cCodEmp+cMatric+cTipReg,AnalQtdCOP->BD6_DATPRO,AnalQtdCOP->BD6_HORPRO,.f.,.t.)[1],"1","2") 
   		endIf
   		
   		if  cRegPro == cRegAte
   		    
   		    if AnalQtdCOP->BD6_ORIMOV <> "2"
   		       nTot += AnalQtdCOP->BD6_QTDPRO 
   		    else
   		    
   		       if empty(cGrpInt)
   		          ntot += AnalQtdCOP->BD6_QTDPRO 
   		       else
   		    
   		          if BE4->(BE4_GRPINT+BE4_TIPINT) == cGrpInt
    		         ntot += AnalQtdCOP->BD6_QTDPRO 
   		          endIf
   		       endIf
   		    endIf
   		endIf
   	endIf
	AnalQtdCOP->(DbSkip())
endDo

AnalQtdCOP->(dbCloseArea())
	
BE4->(restArea(aAreaBE4))
restArea(aArea)

return ntot 

//função para verificar se tanto a operadora origem do beneficiário, quanto a executora são do RS
//para aplicação da regra de tempo diferenciada para possibilidade de cobrança de taxa
static function OpeIntEs(cCodOpe)
Local lRet := .F.
Local cOpeSis := PLSINTPAD()

if cCodOpe <> cOpeSis

	//Carrega as operadoras, com esse if só processa a query uma vez
	if !aOperaRS[1]
		CargOpRS()
	endif

	if aOperaRS[1]
		lRet := aScan(aOperaRS[2], cCodOpe) > 0
	endif
endif

return lRet

//função para preencher o array de operadoras do estado RS
//para uso na verificação da regra da federação do RS
Static function CargOpRS()
local cSql := ''

cSql += " Select BA0_CODIDE, BA0_CODINT from " + RetsqlName("BA0")
cSql += " Where "
cSql += " BA0_FILIAL = '" + xfilial("BA0") + "' AND "
cSql += " BA0_EST = 'RS' AND "
cSql += " D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"CGOPERS",.f.,.t.)
aOperaRS[1] := .T.

While !(CGOPERS->(Eof()))
	Aadd(aOperaRS[2], CGOPERS->BA0_CODIDE + CGOPERS->BA0_CODINT)
	CGOPERS->(dbskip())
endDo

CGOPERS->(dbcloseArea())

return
