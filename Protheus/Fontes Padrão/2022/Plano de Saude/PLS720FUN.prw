#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSA720.CH"

#DEFINE K_Cancel   8
#DEFINE K_Bloqueio 9
#DEFINE K_Desbloq  10

#DEFINE MUDFASGUIA "1"
#DEFINE MUDFASEPEG "2"
#DEFINE RETORNAFASE "3"

#DEFINE DIGITACAO 	"1"
#DEFINE CONFERENC 	"2"
#DEFINE PRONTA 		"3"
#DEFINE FATURADA 	"4"

#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"
#DEFINE G_ANEX_QUIM "07"
#DEFINE G_ANEX_RADI "08"
#DEFINE G_ANEX_OPME "09"
#DEFINE G_REC_GLOSA "10"
#DEFINE G_PROR_INTE "11"

#DEFINE __aCdCri032 {"540",STR0001} //"Erro controlado SIGAPLS."
#DEFINE __aCdCri049 {"020",STR0002} //"O valor contratato e diferente do valor informado/apresentado."
#DEFINE __aCdCri087 {"053",STR0004} //"A quantidade autorizada e diferente da quantidade apresentada/cobrada pela operadora destino."
#DEFINE __aCdCri088 {"054",STR0005} //"O usuario autorizado e diferente do usuario que esta sendo cobrado pela operadora destino."
#DEFINE __aCdCri089 {"055",STR0006} //"A Data/Hora autorizada e diferente da Data/Hora apresentada/cobrada pela operadora destino."
#DEFINE __aCdCri091 {"057",STR0007} //"Usuario importado invalido. Deve ser alterado o usuario para o correto ou glosada a nota."
#DEFINE __aCdCri099 {"063",STR0133} //"Participacao de servico informada invalida."
#DEFINE __aCdCri215 {"09B",STR0139} //"Participacao informada nao existe para este procedimento"
#DEFINE __aCdCri227 {"592",STR0142} //"Bloqueio da cobranca da PF, porque o pagamento sera feito diretamente a RDA"
#DEFINE __aCdCri233 {"596","Bloqueio em função de todas as unidades estarem bloqueadas"} 
#DEFINE __aCdCri09S {"09S","Quantidade de dias permitido para execução da guia foi ultrapassado"}
#DEFINE __aCdCri226 {"591",STR0013} //"Bloq. em funcao de glosa pagto" 
#DEFINE __aCdCri235 {"598","Bloqueio não definido no motivo de bloqueio"}

STATIC aCampBD7  := {'BD7_VLRBPF','BD7_VLRBPR','BD7_VLRGLO','BD7_VLRMAN','BD7_VLRPAG','BD7_VLRTPF'}
STATIC aCampBD6  := {'BD6_VLRBPF','BD6_VLRBPR','BD6_VLRGLO','BD6_VLRMAN','BD6_VLRPAG','BD6_VLRPF','BD6_VLRTPF'}
STATIC cconcateZ	:= IIF( AllTrim( TCGetDB() ) $ "ORACLE/DB2/POSTGRES" , '||', '+')
STATIC lTabCapAtu := FWAliasInDic("B97") .AND. FWAliasInDic("B94") .AND. FWAliasInDic("B9U")
STATIC lCapAtu2 := FWAliasInDic("B8P") .AND. B8P->(FieldPos("B8P_PERRED")) > 0 .AND. B8P->(FieldPos("B8P_CONREG")) > 0 
Static lMV_PLSUNI := GetNewPar("MV_PLSUNI", "0") == "1"
Static lCapAtu3 := B8O->(fieldPos("B8O_POSPAG")) > 0

/*/{Protheus.doc} vldDoppler
Tratamento para doppler (Abrir os lancamentos do doppler)
@type function
@author PLSTEAM
@since 26.12.16
@version 1.0
/*/
function dopplerBD7()
local cSequen   	:= BD6->BD6_SEQUEN
local cOldCodPro	:= BD6->BD6_CODPRO
local cChaveAnt		:= ""
local cChaveAntI	:= ""
local cMVPLSUNCD	:= getNewPar("MV_PLSUNCD","FIL")
local nPercCalc 	:= BD6->BD6_PRPRRL
local nVlrEvt		:= 0
local nVlrMAN		:= 0
local nVlrBPR		:= 0
local nAux			:= 0
local lCalcDop		:= .f.
local lFindBD6		:= .f.
local aAreaBD6  	:= BD6->(getArea())
local aAreaBD7  	:= {}
local aRegsSalv		:= {}
local aStrucBD7 	:= BD7->(DbStruct())
	
cChaveAnt := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQREL+BD6_CDPDRC+BD6_PROREL)
BD6->(dbSetOrder(1))//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO

BD7->(dbSetOrder(1))//BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
lCalcDop := BD7->( msSeek( xFilial("BD7") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) + "DOP" ) )

// Verifica se acha o procedimento relacionado
if lCalcDop
	
	cChaveAntI := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CDPDRC+BD6_PROREL)
	
	if BD6->( MsSeek(xFilial("BD6")+cChaveAnt) )
		lFindBD6 := .t.
	else
	
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Procedimento Relacionado não encontrado - ["+cChaveAnt+"]", 0, 0, {})
		
		BD6->(dbSetOrder(6))//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_CODPAD + BD6_CODPRO
		if BD6->( MsSeek(xFilial("BD6")+cChaveAntI) )
			
			lFindBD6 := .t.
			
		else

			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Procedimento Relacionado não encontrado - ["+cChaveAntI+"]", 0, 0, {})
			
			BD6->(restArea(aAreaBD6))
			
		endIf
		
	endIf
	
endIf

if lCalcDop .and. lFindBD6
	
	plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)
	
	if ! TRBBD7->(eof())
		
		nVlrEvt := 0.00
		
		while ! TRBBD7->(eof())
		
			BD7->( dbGoTo( TRBBD7->REC ) )
			
			if ! ( allTrim(BD7->BD7_CODUNM) $ cMVPLSUNCD )

				nVlrEvt += (BD7->BD7_VLRMAN * nPercCalc) / 100
				
				aAreaBD7	:= BD7->(getArea())
				aRegsSalv 	:= {}
				
				nVlrMAN := (BD7->BD7_VLRMAN * nPercCalc) / 100
				nVlrBPR := (BD7->BD7_VLRBPR * nPercCalc) / 100
				
				for nAux := 1 to len(aStrucBD7)
					aadd(aRegsSalv,{"BD7->" + aStrucBD7[nAux,1], &("BD7->" + aStrucBD7[nAux,1]) } )
				next
				
				//inclusao de novo BD7
				BD7->(recLock("BD7",.T.))
				
					for nAux := 1 to len(aRegsSalv)
						&(aRegsSalv[nAux,1]) := aRegsSalv[nAux,2]
					next
					
					BD7->BD7_FILIAL := xFilial("BD7")

					BD7->BD7_SEQUEN := cSequen
					BD7->BD7_CODPRO := cOldCodPro
					BD7->BD7_VLRBPR := nVlrBPR
					BD7->BD7_VLRMAN := nVlrMAN
					BD7->BD7_VLRPAG := BD7->BD7_VLRMAN
					BD7->BD7_CODOPE := BD6->BD6_CODOPE
					BD7->BD7_CODLDP := BD6->BD6_CODLDP
					BD7->BD7_CODPEG := BD6->BD6_CODPEG
					BD7->BD7_NUMERO := BD6->BD6_NUMERO
					BD7->BD7_ORIMOV := BD6->BD6_ORIMOV
					
				BD7->(msUnLock())
				
				BD7->(restArea(aAreaBD7))
				
			endIf
			
		TRBBD7->(dbSkip())
		endDo
		
	endIf
	
	TRBBD7->(dbCloseArea())
	
	BD6->(restArea(aAreaBD6))
	
	if BD7->( msSeek( xFilial("BD7") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) + "DOP" ) )
		
		BD7->(recLock("BD7",.F.))
			BD7->(DbDelete())
		BD7->(msUnLock())
				
	endIf
	
endIf
	
return

/*/{Protheus.doc} getTPCALC
Retorno o tipo de calculo de pagamento
@type function
@author PLSTEAM
@since 26.12.16
@version 1.0
/*/
function getTPCALC(cCodRda)
local aArea 	:= {}
local cTpCalc 	:= BAU->BAU_TPCALC

if cCodRda <> BAU->BAU_CODIGO

	aArea := BAU->(getArea())

	BAU->( dbSetOrder(1) ) //BAU_FILIAL+BAU_CODIGO
 	BAU->( msSeek( xFilial("BAU") + cCodRda ) )
 	
 	cTpCalc := BAU->BAU_TPCALC
 	
 	BAU->(restArea(aArea))
 	
endIf

if alltrim(BD6->BD6_CODPRO) == getNewPar("MV_PLPSPXM","99999994") .or. alltrim(BD6->BD6_CODPRO) == getNewPar("MV_PLPACPT","99999998")
	cTpCalc := "3"
endif

return(cTpCalc)

/*/{Protheus.doc} getValTPC
Retorna o valor correto base pagamento, acrescimo e desconto...
@type function
@author PLSTEAM
@since 26.12.16
@version 1.0
/*/
function getValTPC(nVlrBPR, nVlrApr, lRecGlo, lTaxa, lPldigPro)
local nVlrMAN := 0
local nVlrGlo := 0
local nTpCalc := BAU->BAU_TPCALC

default lRecGlo	:= .f. 
default lTaxa	:= .f.
default lPldigPro := .F.

if existBlock("PLSTPCAL")

	nTpCalc := execBlock("PLSTPCAL",.f.,.f.,{ nVlrBPR, nVlrApr, lRecGlo, lTaxa, nTpCalc, BD6->(recno()) } )
	
	if ! ( nTpCalc $ '1|2|3| ')
		nTpCalc := BAU->BAU_TPCALC
	endIf
	
endIf

if alltrim(BD6->BD6_CODPRO) == getNewPar("MV_PLPSPXM","99999994") .or. alltrim(BD6->BD6_CODPRO) == getNewPar("MV_PLPACPT","99999998")
	nTpCalc := "3"
endif

//neste ponto VLRAPR esta multiplicado pela quantidade
if nVlrApr > 0 .or. nTpCalc == "3"
	
	if lRecGlo
		
		nVlrMAN := nVlrApr
				
	//1=Menor Valor; 2=Valor Contratado; 3=Valor Apresentado	
	else
		
		if nTpCalc $ " , 1"
			
			if nVlrApr <= nVlrBPR
				nVlrMAN := nVlrApr
			else
				nVlrMAN := nVlrBPR
				nVlrGlo := nVlrApr - nVlrBPR	
			endIf
			
			//se o valor da glosa for menor que o definido no parametro paga o maior.
			if nVlrGlo <= getNewPar("MV_PLSDIFA", 0.00) .AND. !lPldigPro
				nVlrMAN := nVlrApr
				nVlrGlo := 0
			endIf
			
		elseIf nTpCalc $ "2"
			
			if nVlrApr > nVlrBPR 
				nVlrMAN := nVlrBPR
				nVlrGlo := nVlrApr - nVlrBPR
			else
				nVlrMAN := nVlrBPR
				nVlrGlo := 0
			endIf
			
			//se o valor da glosa for menor que o definido no parametro paga o maior.
			if nVlrGlo <= getNewPar("MV_PLSDIFA", 0.00) .AND. !lPldigPro
				nVlrMAN := nVlrBPR
				nVlrGlo := 0
			endIf
				
		elseIf nTpCalc $ "3"
			
			nVlrMAN := nVlrApr
			
		endIf

	endIf
	
else
	nVlrMAN	:= nVlrBPR
endIf	
				
return( { nVlrMAN, nVlrGlo } )

/*/{Protheus.doc} getACDE
Verifica se existe acrescimo ou decrescimo
@type function
@author PLSTEAM
@since 26.12.16
@version 1.0
/*/
function getACDE(nVlrMAN, nDesconto)
local nAcrescimo	:= 0
local nTTVlrDes		:= 0
local nValDes		:= 0

//Corpo clinico
BC1->(DbSetOrder(1))
If BC1->(MsSeek(xFilial("BC1")+BD6->(BD6_CODRDA+BD6_CODLOC+BD6_CODESP+BD7->BD7_CDPFPR))) .and. BC1->BC1_PERDES > 0
	
	nDesconto := BC1->BC1_PERDES
				
	if ( empty(BC1->BC1_DATBLO) .or. BC1->BC1_DATBLO > dDatPro)
		
		nValDes := ( ( nVlrMAN * nDesconto ) / 100 )
		
		nTTVlrDes 	+= nValDes
		nVlrMAN 	-= nValDes
		
	endIf
	
else

	if nDesconto > 0 
		
		nValDes := ( ( nVlrMAN * nDesconto ) / 100 )
		
		nTTVlrDes 	+= nValDes
		nVlrMAN		-= nValDes
		
	endIf
		
endIf

// Verifica se tem percentual de acrescimo p/ este corpo clinico...
if BC1->(MsSeek(xFilial("BC1")+BD6->(BD6_CODRDA+BD6_CODLOC+BD6_CODESP+BD7->BD7_CDPFPR))) .and. BC1->BC1_PERACR > 0
	
	nAcrescimo := BC1->BC1_PERACR

	if ( empty(BC1->BC1_DATBLO) .or. BC1->BC1_DATBLO > dDatPro)
		nVlrMAN += ( ( nVlrMAN * nAcrescimo ) / 100 )
	endIf
	
else
	nAcrescimo := 0
endIf	

//atualiza o desconto na bd6
if nTTVlrDes > 0

	BD6->(recLock("BD6",.F.))
		BD6->BD6_VLRDES := nTTVlrDes
	BD6->(msUnLock())

endIf

return( { nVlrMAN, nDesconto, nAcrescimo })

/*/{Protheus.doc} setDisBD7
distribuicao de valores de pagamento na BD7
@type function
@author PLSTEAM
@since 26.12.16
@version 1.0
/*/
static function setDisBD7(aAux, nVlrBPRBD6, nVlrMANBD6, nVlrGLOBD6, nVlrAPRBD6, nPrTxPag, nVlTxAPBD6, dDatPro, nDifUs, nVlrDifUs,;
						  nDesconto, nAcrescimo, aCri, lFlag, aMatTOTBD7, cLocalExec, nPerInss)
local nInd 			:= 0
local nforUnd		:= 0
local nVlrGLOBlo	:= 0
local nPercen		:= 0
local nVlrTx		:= 0
local cKeyAux		:= ""
local cCodUnd		:= ""
local aRetUnd		:= {}
local aRet			:= {}
local lAceitaVlApr 	:= getNewPar("MV_PLACEAP",.F.)  // Determina que sera aceito o valor apresentado e não o valor original para os itens de PTU CEMIG


local lBD7_VTXPCT 	:= BD7->(fieldPos("BD7_VTXPCT")) > 0
local lBD7_PRTXPG 	:= BD7->(fieldPos("BD7_PRTXPG")) > 0
local lBD7_VLRGTX 	:= BD7->(fieldPos("BD7_VLRGTX")) > 0
local lBD7_VLTXPG 	:= BD7->(fieldPos("BD7_VLTXPG")) > 0

local lBD7_PEINPT 	:= BD7->(fieldPos("BD7_PEINPT")) > 0
local lBD7_VLINPT 	:= BD7->(fieldPos("BD7_VLINPT")) > 0
local lBD7_GLINPT 	:= BD7->(fieldPos("BD7_GLINPT")) > 0
local lBD7_TIPEVE 	:= BD7->(fieldPos("BD7_TIPEVE")) > 0

for nInd := 1 to len(aAux[5])
			
	if empty(aAux[4])
	
		// Grava valor no bd7
		BD7->( recLock("BD7",.F.) )
		
		BD7->BD7_PERHES := aAux[17]
		
		//quando for importacao PTU e regra para pagar o apresentado
		if ! empty(BD6->BD6_SEQIMP) .and. BD7->BD7_VALORI > 0
			nPercen := PLGETPCEN(BD6->BD6_VALORI, BD7->BD7_VALORI)
		else
			nPercen := PLGETPCEN(nVlrBPRBD6, aAux[5,nInd,4])
		endIf	
		
		//e preciso pegar da nVlrMANBD6 pois pode ter valor apresentado
		BD7->BD7_PERCEN := nPercen
		BD7->BD7_VLRBPR := aAux[5,nInd,4]
		BD7->BD7_VLRMAN := ( nVlrMANBD6 * nPercen ) / 100  
		BD7->BD7_VLRGLO	:= ( nVlrGLOBD6 * nPercen ) / 100
		
		if BD7->BD7_BLOPAG == '1'
		
			PLSPOSGLO(PLSINTPAD(),BD7->BD7_MOTBLO,BD7->BD7_DESBLO,cLocalExec,"0")
			
			nVlrGLOBlo 		+= BD7->BD7_VLRMAN
		
			BD7->BD7_VLRGLO	+= BD7->BD7_VLRMAN 
			BD7->BD7_VLRMAN := 0
			
		endIf
		
		//se for PTU tenho que considerar a taxa apresentada
		if ! empty(BD6->BD6_SEQIMP)
			
			if BD7->BD7_VALORI == 0
				BD7->BD7_VALORI := ( nVlrAPRBD6 * nPercen ) / 100
			endIf

			if BD7->BD7_VLTXAP == 0	
				BD7->BD7_VLTXAP := ( nVlTxAPBD6 * nPercen ) / 100
			endIf
						
		else
		
			BD7->BD7_VALORI := ( nVlrAPRBD6 * nPercen ) / 100
			BD7->BD7_VLTXAP := ( BD7->BD7_VALORI * nPrTxPag ) / 100
			
		endIf
		
		// Esse  item se faz necessario devido que temos operadoras em que o analista de contas efetua acertos no valor apresentado vindo da importação do PTU CEMIG
		If lAceitaVlApr .and. ! empty(BD6->BD6_SEQIMP)
			BD7->BD7_VLRAPR := nVlrAPRBD6
			BD7->BD7_VALORI := ( nVlrAPRBD6 * nPercen ) / 100
		Else
			BD7->BD7_VLRAPR := ( BD7->BD7_VALORI / BD6->BD6_QTDPRO )
		Endif

		BD7->BD7_VLRAPR := If(lAceitaVlApr .and. ! empty(BD6->BD6_SEQIMP) , nVlrAPRBD6 ,( BD7->BD7_VALORI / BD6->BD6_QTDPRO ))
		
		//taxa calculada
		if lBD7_VLTXPG .and. lBD7_VLRGTX .and. lBD7_PRTXPG 
					
			BD7->BD7_PRTXPG := nPrTxPag
			
			BD7->BD7_VLTXPG := ( BD7->BD7_VLRMAN * nPrTxPag ) / 100
			BD7->BD7_VLRGTX := 0
			
			aRet 			:= getValTPC(BD7->BD7_VLTXPG, BD7->BD7_VLTXAP, BD7->BD7_TIPGUI == '10', .t.)
			nVlrTx			:= aRet[1]
			BD7->BD7_VLRGTX := aRet[2]
			
			if ! empty(BD6->BD6_SEQIMP)
				BD7->BD7_VLTXPG := nVlrTx
			endIf
			
			If nVlrGLOBlo > 0
				BD7->BD7_VLRGTX := ( nVlrGLOBlo * nPrTxPag ) / 100
			endIf	 
			
		endIf
		
		BD7->BD7_VLRPAG := BD7->BD7_VLRMAN + nVlrTx

		//inss patronal
		if  lBD7_PEINPT .and. lBD7_VLINPT .and. lBD7_GLINPT .and. nPerInss > 0 

			BD7->BD7_PEINPT := nPerInss
			BD7->BD7_GLINPT := ( ( BD7->BD7_VLRGLO + BD7->BD7_VLRGTX ) * nPerInss) / 100
			BD7->BD7_VLINPT := (BD7->BD7_VLRPAG * nPerInss) / 100

		endIf
		
		//valor contratado
		if lBD7_VTXPCT
			BD7->BD7_VTXPCT := (BD7->BD7_VLRBPR * nPrTxPag) / 100
		endIf

		BD7->BD7_DSCCLI := nDesconto
		BD7->BD7_ACCCLI := nAcrescimo
		
		BD7->BD7_REFTDE := aAux[5,nInd,1]
		BD7->BD7_ALIAUS := aAux[5,nInd,2]
		BD7->BD7_COEFUT := aAux[5,nInd,3]
		BD7->BD7_FATMUL := aAux[5,nInd,6]
		BD7->BD7_TIPCOE := aAux[5,nInd,7]
		
		BD7->BD7_FASE   := BD6->BD6_FASE
		BD7->BD7_SITUAC := BD6->BD6_SITUAC
		BD7->BD7_CODPAD := BD6->BD6_CODPAD
		BD7->BD7_CODPRO := BD6->BD6_CODPRO

		if lBD7_TIPEVE
			BD7->BD7_TIPEVE := if(BAU->BAU_COPCRE == "1","1","2")
		endIf
		
		if len(aAux[5,nInd]) >= 11
			BD7->BD7_UTHRES := aAux[5,nInd,11]
		endIf
		
		if nDifUs <> 1 .and. subStr(BD7->BD7_TIPCOE,1,3) == "U.S"
			
			BD7->BD7_USDIF  := nVlrDifUs
			BD7->BD7_VLRDIF := (BD7->BD7_REFTDE * nVlrDifUs) * BD7->BD7_FATMUL
			BD7->BD7_TPUSDF := iIf( nVlrDifUs > BD7->BD7_COEFUT, "2", "1" )
			
		endIf

		if len(aAux) > 13
			BD7->BD7_CONSFT := iIf( empty(aAux[14]),"0",aAux[14])
		endIf
		
		BD7->(MsUnLock())
		
		//guarda total do bd7 para posterior conferencia
		getTotBD7(aMatTOTBD7)
		
	endIf
			
next

return( nVlrGLOBlo )

/*/{Protheus.doc} PLGETPCEN
Retorna o Percentual do BD7
@type function
@author TOTVS
@since 13.02.18
@version 1.0
/*/
function PLGETPCEN(nBD6BPR,nBD7BPR)
local nPercen := ( nBD7BPR / nBD6BPR ) * 100

return(nPercen) 

/*/{Protheus.doc} PL720GPG
Calcula valor de pagamento
@type function
@author TOTVS
@since 13.02.03
@version 1.0
/*/
function PL720GPG(aAux, aUnidsVLD, cLocalExec, nPercHEsp, nPrTxPag, aCri, nDifUs, nVlrDifUs,;
				  aBDXSeAnGl, lBloPag, cTipoGuia, nPerInss,aRetBatat)
local nAux			:= 0
local nInd      	:= 0
local nRecBD7 		:= 0
local nPosUnd		:= 0

local nTTVlrBPR 	:= 0 
local nTTVlrGLO 	:= 0 
local nTTVlrAPR		:= 0
local nTTVlAPUN		:= 0
local nTTVlrMAN		:= 0
local nTTVlrPAG		:= 0
local nTTVlrGTX		:= 0
local nTTVlTxPG  	:= 0
local nTTVlTxAP  	:= 0

local nTTVlrGIP		:= 0
local nTTVlPeIP  	:= 0

local nVlrMANBD6 	:= 0
local nVlrGLOBD6 	:= 0
local nVlrGLOBlo	:= 0
local nVlrGLOB11	:= 0

local nVlrPRDA 		:= 0
local nVlrTx		:= 0
local nVlrGTx		:= 0

local cCodBlo 		:= ''
local cDesBlo 		:= ''

local nforUnd		:= 0
local nAcrescimo	:= 0
local nDesconto		:= 0
local nVlrBPRBD6	:= 0
local nQtdPro   	:= BD6->BD6_QTDPRO
local nVlrAPRBD6	:= iif(BD6->BD6_VALORI > 0, BD6->BD6_VALORI, BD6->BD6_VLRAPR * BD6->BD6_QTDPRO)
local nVlTxApBD6	:= BD6->BD6_VLTXAP
local cKeyAux   	:= ""
local cCodUnd		:= ""
local cMV_PLSTPGV	:= getNewPar("MV_PLSTPGV","")
local cMatCob   	:= BD6->BD6_MATCOB
local cNomCob   	:= BD6->BD6_NOMCOB
local dDatCob   	:= BD6->BD6_DATCOB
local cHorCob   	:= BD6->BD6_HORCOB
local cMatrUsr  	:= BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
local dDatPro   	:= BD6->BD6_DATPRO
local cHorPro   	:= BD6->BD6_HORPRO
local cNomUsr   	:= BD6->BD6_NOMUSR
local cMatAnt   	:= BD6->BD6_MATANT
local aRetUnd		:= {}
local aRetFx		:= {}
local aAreaBD6		:= {}
local aRet			:= {}
local aMatTOTBD7	:= {}
local lMV_PLSDTPG	:= getNewPar("MV_PLSDTPG",.f.)
local l500RPG 		:= isInCallStack("PLSA500RPG")
local l500RCP		:= isInCallStack("PLSA500RCP")
local lRet      	:= .t.
local lFlag     	:= .f.
local lGlosaApr		:= .t.
local lFoundBD7 	:= .f.
local lRecGlo		:= .f.
local lChkDopp		:= getNewPar('MV_PLCKDOP','0') == '1'
local lMVPLENGCO	:= getNewPar("MV_PLENGCO",.f.) 
local lUnlGlosa	  	:= getNewPar("MV_PLTPUNL",.f.) //Determina que mesmo for tipo de participação 'UNL' devemos Apresentar o Valor de Glosa para analise no Contas Medicas
local cMVPLSCAUX	:= getNewPar("MV_PLSCAUX","AUX")
local nTamCODUNM	:= BD7->( tamSX3("BD7_CODUNM")[1] )
Local lRevPgRDA 	:= BD6->BD6_PAGRDA == "1" .and. l500RPG 
local lPslUNL		:= .f.

local lBD6_PRTXPG 	:= BD6->(fieldPos("BD6_PRTXPG")) > 0
local lBD6_VLRGTX 	:= BD6->(fieldPos("BD6_VLRGTX")) > 0
local lBD6_VLTXPG 	:= BD6->(fieldPos("BD6_VLTXPG")) > 0
local lBD6_VLTXAP 	:= BD6->(fieldPos("BD6_VLTXAP")) > 0 .and. empty(BD6->BD6_SEQIMP)
local lBD6_PEINPT 	:= BD6->(fieldPos("BD6_PEINPT")) > 0
local lBD6_VLINPT 	:= BD6->(fieldPos("BD6_VLINPT")) > 0
local lBD6_GLINPT 	:= BD6->(fieldPos("BD6_GLINPT")) > 0

local lBD7_VLRGTX 	:= BD7->(fieldPos("BD7_VLRGTX")) > 0
local lBD7_VLTXPG 	:= BD7->(fieldPos("BD7_VLTXPG")) > 0
local lBD7_VLTXAP	:= BD7->(fieldPos("BD7_VLTXAP")) > 0
local lBD7_VLINPT 	:= BD7->(fieldPos("BD7_VLINPT")) > 0
local lBD7_GLINPT 	:= BD7->(fieldPos("BD7_GLINPT")) > 0

Local lUniApr		:= .f.
Local nxxx			:= 0
Local nyyy			:= 0
Local nSearch 		:= 0
Local aPreEstab		:= {.F.,0}
Local nDesPreEs		:= 0
Local lUnimed := GetNewPar("MV_PLSUNI", "0") == "1"
local lReapre       := iif(lUnimed,PlVerReap(BCI->BCI_CODOPE,RIGHT(BCI->BCI_LOTEDI,8)),.f.) //Verifica se é uma reapresentação

default nPercHEsp 	:= 0
default nPrTxPag  	:= 0
default nPerInss	:= 0
default nDifUs 		:= 1
default nVlrDifUs	:= 0
default aUnidsVLD	:= {}
default aCri      	:= {.t.,{}}
default aBDXSeAnGl  := {.f.,{}}
default lBloPag		:= .f.
Default cTipoGuia   := ""
DEFAULT aRetBatat := {}

if cTipoGuia == G_REC_GLOSA .OR. BD6->BD6_TIPGUI == G_REC_GLOSA
	lRecGlo := .t.
endIf

//bloqueio de pagamento pois todas as unidades estao bloqueadas
if lBloPag .and. BD6->BD6_BLOPAG != '1'

	PLSPOSGLO(PLSINTPAD(),__aCdCri233[1],__aCdCri233[2],cLocalExec,"1")
	
	BD6->(recLock("BD6",.f.))
		PLBLOPC('BD6', .t., __aCdCri233[1], PLSBCTDESC(), .t., .f.)
	BD6->(msUnLock())
	
endIf

// Desconto
aRetFx	:= retFxDes(BD6->BD6_OPERDA, BD6->BD6_CODRDA, nil, BD6->BD6_CODPLA, BD6->BD6_CODPAD,;
					BD6->BD6_CODPRO, BD6->BD6_VLRPAG, nil,BD6->BD6_CODLOC, dtos(BD6->BD6_DATPRO),;
					BD6->BD6_CODESP, BD7->BD7_CDPFPR)
					
if len(aRetFx) > 0

	BD6->(recLock("BD6",.f.))
		BD6->BD6_VLRDES := aRetFx[1]
		BD6->BD6_TABDES := aRetFx[2]
		BD6->BD6_PERDES := aRetFx[3]
	BD6->(msUnLock())
	
	nDesconto := BD6->BD6_PERDES
	
endIf	

if len(aAux) > 0
	
	for nAux := 1 to len(aAux)
	
		cCodUnd := aAux[nAux,1]
		cKeyAux := iIf( allTrim(cCodUnd) $ cMVPLSCAUX, aAux[nAux,15], "" )

		if aScan(aUnidsVLD, {|x| allTrim(x[1]) == allTrim(cCodUnd) .and. allTrim(x[2]) == allTrim(cKeyAux) }) > 0 .and. len(aAux[nAux,5]) > 0
			nVlrBPRBD6 += aAux[nAux,5,1,4]
		endIf
		
		If !lUniApr
			BD3->(dbSetOrder(1))
			If BD3->(MsSeek(xFilial("BD3") + cCodUnd))
				lUniApr := BD3->BD3_TIPVAL == '2'
			endIf
		EndIf
	next
	
	BD7->(dbSetOrder(1)) //BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
	
	//regra do valor maior menor 	
	aRet := getValTPC( round(nVlrBPRBD6,2), nVlrAPRBD6, lRecGlo)
	
	If lUniApr
		aRet[1] := nVlrAPRBD6
		aRet[2] := 0
	endIf	
	nVlrMANBD6 := aRet[1]
	nVlrGLOBD6 := aRet[2]

	//busca quantidade ou valor de glosa na B11
	aRet := getValB11(@aCri, cLocalExec, nVlrMANBD6)
	
	nVlrMANBD6 := aRet[1]
	nVlrGLOB11 := aRet[2]
	nVlrGLOBD6 += nVlrGLOB11
	
	//aplica desconto ou acrecimo
	aRet := getACDE(nVlrMANBD6,nDesconto)
	
	nVlrMANBD6 	:= aRet[1]
	nDesconto	:= aRet[2]
	nAcrescimo	:= aRet[3]


	//Regra para colocar o valor pago no desconto para guia de reapresentação
	if lReapre
		BD6->(recLock("BD6",.F.))
			BD6->BD6_PERDES := 100
			BD6->BD6_VLRDES := nVlrMANBD6
		BD6->(msUnLock())
		nVlrMANBD6 := 0
	endif

	//Verifica regra de contrato pré-estabelecido
	if lTabCapAtu
		aPreestab := plsAAA720(BD6->BD6_CODRDA ,cMatrUsr ,DdatPro, BD6->BD6_CODPAD, BD6->BD6_CODPRO, ,BD6->BD6_CODESP)
	endif
	
	If aPreestab[1]
		nDesPreEs := Round(nVlrMANBD6 *  aPreEstab[2] / 100, 2)

		BD6->(recLock("BD6",.F.))
			BD6->BD6_TABDES := "B8O"
			BD6->BD6_PERDES := aPreEstab[2]
			BD6->BD6_VLRDES += nDesPreEs
		BD6->(msUnLock())

		nVlrMANBD6 -= nDesPreEs
	endif

	//Faz o bloqueio gerar desconto e para não ter que gerar glosa para zerar o evento
	//Nos casos em que é por conta do desconto da NF de entrada
	if BD6->BD6_BLOPAG == '1' .AND. !(empty(BD6->BD6_NFE))
		BD6->(recLock("BD6",.F.))
			BD6->BD6_TABDES := "B19"
			BD6->BD6_PERDES := 100
			BD6->BD6_VLRDES := nVlrMANBD6
		BD6->(msUnLock())
		nVlrMANBD6 := 0
	endif

	nSearch := 0
	//Zera os valores dos eventos que tiverem crítica diferente da 020
	For nxxx := 1 To Len(aRetBatat)

		If empty(aRetBatat[nxxx][1]) .OR. AllTrim(aRetBatat[nxxx][1]) == "020"
			loop
		endIF
		If Len(aRetBatat[nxxx]) >= 8
			If AllTrim(aRetBatat[nxxx][8]) == BD6->BD6_SEQUEN
				nSearch := 1
			endIf
		elseif Len(aRetBatat[nxxx]) >= 7
			If Alltrim(aRetBatat[nxxx][6]) == BD6->BD6_CODPAD .AND. AllTrim(aRetBatat[nxxx][7]) == AllTrim(BD6->BD6_CODPRO)
				nSearch := 1
			endIf
		else
			loop //nunca deve cair aqui
		endIf

		If nSearch > 0
			nVlrGLOBD6 := Max(nVlrAPRBD6, nVlrMANBD6)
			nVlrMANBD6 := 0
			Exit
		endIf
	next

	for nAux := 1 to len(aAux)
		
		cCodUnd		:= aAux[nAux,1]
		cKeyAux 	:= iIf( allTrim(cCodUnd) $ cMVPLSCAUX, aAux[nAux,15], "" )
		
		//Verificar se existe UNL antes das demais checagens
		if (lUnlGlosa .and. !lPslUNL .and. (aScan(aUnidsVLD, {|x| allTrim(x[1]) == allTrim("UNL")}) > 0) ) 
			lPslUNL := .t.
			cCodUnd := "UNL"
		elseif (lUnlGlosa .and. lPslUNL) 
			loop
		endIf
		
		if (!lPslUNL .and. aScan(aUnidsVLD, {|x| allTrim(x[1]) == allTrim(cCodUnd) .and. allTrim(x[2]) == allTrim(cKeyAux) }) == 0)  
			
			If nAux == Len(aAux) .AND. !lFoundBD7
				If getNewPar("MV_PLCAAUX","1") == "3" .AND. aScan(aUnidsVLD, {|x| allTrim(x[1]) == allTrim(cMVPLSCAUX) }) > 0
					cCodUnd := cMVPLSCAUX
				else
					loop
				endIf
			else
				loop
			endIf

		endIf
		
		cCodUnd   := padr(cCodUnd, nTamCODUNM)
		lFoundBD7 := BD7->( msSeek( xFilial("BD6") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN + cCodUnd + cKeyAux ) ) )
		
		if lFoundBD7 .and. ( len(aAux[nAux,5]) == 0 .or. ! empty(aAux[nAux,4]) )
			
			BD7->(recLock("BD7",.f.))
				BD7->BD7_DESCRI := aAux[nAux,4]
			BD7->(msUnLock())
			
		elseIf lFoundBD7
		
			//distribuicao de valores no BD7
			nVlrGLOBlo += setDisBD7(aAux[nAux], nVlrBPRBD6, nVlrMANBD6, nVlrGLOBD6, nVlrAPRBD6, nPrTxPag, nVlTxApBD6, dDatPro, nDifUs, nVlrDifUs,;
					  			 	nDesconto, nAcrescimo, aCri, @lFlag, @aMatTOTBD7, cLocalExec, nPerInss )
		endIf
		
		if lFoundBD7
			
			// Determina que mesmo for tipo de participação 'UNL' devemos Apresentar o Valor de Glosa para analise no Contas Medicas
			if lUnlGlosa .and. PLSPOSGLO(PLSINTPAD(),__aCdCri215[1],__aCdCri215[2],cLocalExec)
				
				if aAux[nAux,1]  == "UNL"
		
					if PCLPGAUTO()
						aBDXSeAnGl[1] := .f.
						aadd(aBDXSeAnGl[2],{ __aCdCri215[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
					else
						aadd(aCri[2],{__aCdCri215[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})				
					endIf
					
					lFlag := .t.
					
				endIf	
				
			endIf
			
			//Bloqueio da cobranca da PF, porque o pagamento sera feito diretamente a RDA. (Revalorização do Pagamento)
			if lRevPgRDA

				BD7->(RecLock("BD7", .F.))

					nVlrPRDA := ( ( BD6->BD6_VLRTPF * BD7->BD7_PERCEN ) / 100 - BD7->BD7_VLRTAD )
					
					if l500RPG .and. l500RCP
						if BD7->BD7_VLRMAN >= nVlrPRDA
							BD7->BD7_VLRMAN -= nVlrPRDA	
						else
							BD7->BD7_VLRMAN := 0
						endIf
					endIf

					BD7->BD7_VLTXPG := ( BD7->BD7_VLRMAN * BD7->BD7_PRTXPG ) / 100
					
					aRet 			:= getValTPC(BD7->BD7_VLTXPG, BD7->BD7_VLTXAP, BD7->BD7_TIPGUI == '10', .t.)
					nVlrTx			:= aRet[1]
					nVlrGtx			:= aRet[2]

					BD7->BD7_VLRGTX := nVlrGtx

					if ( l500RPG .or. l500RCP )
						BD7->BD7_VLRGLO += nVlrPRDA
						nVlrGLOBlo += nVlrPRDA
					endif
							
					BD7->BD7_VLRPAG	:= BD7->BD7_VLRMAN + nVlrTx
					BD7->BD7_VLINPT := (BD7->BD7_VLRPAG * BD7->BD7_PEINPT) / 100
					BD7->BD7_GLINPT := ( ( BD7->BD7_VLRGLO + BD7->BD7_VLRGTX ) * BD7->BD7_PEINPT) / 100
				
				BD7->(MsUnLock())

			endIf		
				
		endIf
			
	next
	
	//se nao achou nenhuma composicao critica
	if ! lFoundBD7
		
		PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2],cLocalExec,"0")

		if PCLPGAUTO()
			aBDXSeAnGl[1] := .f.
			aadd(aBDXSeAnGl[2],{ __aCdCri032[1],allTrim(PLSBCTDESC()),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			aadd(aBDXSeAnGl[2],{""  ,"Nenhuma unidade encontrada na composição do evento" ,"","","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) 
		else
			aadd(aCri[2],{ __aCdCri032[1],allTrim(PLSBCTDESC()),,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			aadd(aCri[2],{""  ,"Nenhuma unidade encontrada na composição do evento" ,"","","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) 
		endIf	

		lFlag := .t.

	endIf
	
	//retira os valores que estao bloqueados
	nVlrMANBD6 -= nVlrGLOBlo
	nVlrGLOBD6 += nVlrGLOBlo 
	
	//verifica se o total do BD7 esta igual ao BD6 vai verificar o MAN,GLO e VLTXPG
	setAjuGUI(aMatTOTBD7, nPrTxPag, nPerInss, nVlrMANBD6, nVlrGLOBD6)

	if len(aMatTOTBD7) > 0
	
		nTTVlrBPR := aMatTOTBD7[2,2]
		nTTVlrMAN := aMatTOTBD7[3,2]
		nTTVlrGLO := aMatTOTBD7[4,2]
		nTTVlrPAG := aMatTOTBD7[5,2]
		
		if lBD7_VLTXAP
			nTTVlTxAP := aMatTOTBD7[11,2]
		endIf	
		
		if lBD7_VLRGTX .and. lBD7_VLTXPG
			nTTVlTxPG := aMatTOTBD7[12,2]
			nTTVlrGTX := aMatTOTBD7[13,2]
		endIf	
	
		if lBD7_VLINPT .and. lBD7_GLINPT
			nTTVlPeIP := aMatTOTBD7[14,2]
			nTTVlrGIP := aMatTOTBD7[15,2]
		endIf
		
		nTTVlAPUN := aMatTOTBD7[9,2]
		nTTVlrAPR := aMatTOTBD7[16,2]

		BD6->( recLock("BD6",.f.) )
		
			BD6->BD6_VLRBPR := nTTVlrBPR
			BD6->BD6_VLRMAN := nTTVlrMAN
			BD6->BD6_VLRGLO := nTTVlrGLO 
			BD6->BD6_VLRPAG := nTTVlrPAG 
			BD6->BD6_VALORI := nTTVlrAPR 
			BD6->BD6_VLRAPR := nTTVlAPUN 
			
			if lBD6_VLTXAP
				BD6->BD6_VLTXAP := nTTVlTxAP 
			endIf
			
			if lBD6_VLTXPG .and. lBD6_VLRGTX .and. lBD6_PRTXPG 
				BD6->BD6_PRTXPG := nPrTxPag
				BD6->BD6_VLTXPG := nTTVlTxPG 
				BD6->BD6_VLRGTX := nTTVlrGTX 
			endIf	
	
			if lBD6_VLINPT .and. lBD6_GLINPT .and. lBD6_PEINPT 
				BD6->BD6_PEINPT := nPerInss
				BD6->BD6_VLINPT := nTTVlPeIP 
				BD6->BD6_GLINPT := nTTVlrGIP 
			endIf

		BD6->(msUnLock())
		
	endIf		
	
endIf

//tratamento para procedimento doppler
if lChkDopp .and. ! empty(BD6->BD6_PROREL)
	dopplerBD7()
endIf	

// Veja se houve glosa...
if (nTTVlrGLO > 0 .OR. nTTVlrGTX > 0) .and. ( ( lMVPLENGCO .and. ! empty(BD6->BD6_SEQIMP) ) .or. ;
 ((nTTVlrMAN + nTTVlrGLO) > nTTVlrBPR) .or.(nTTVlrGTX > 0)) .and. ( ! lMV_PLSDTPG .or. BD6->BD6_LIBERA <> '1' )
	
	if PLSPOSGLO(PLSINTPAD(),__aCdCri049[1],__aCdCri049[2],cLocalExec) .and. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,__aCdCri049[1]} )
	
		//glosa automatico
		if ! empty(cMV_PLSTPGV)
			lGlosaApr := ( BR8->BR8_TPPROC $ cMV_PLSTPGV )
		endIf	
		
		if lGlosaApr
			
			aadd(aCri[2],{__aCdCri049[1],PLSBCTDESC()		,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			aadd(aCri[2],{""   ,STR0041                 	,str(nTTVlrBPR,17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Valor Contratado"
			aadd(aCri[2],{""   ,STR0042+" + "+STR0043     	,str( ( nTTVlrMAN + nTTVlrGLO ),17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Valor Informado/Apresentado"###"Valor Contratado (caso nao seja apresentado nenhum valor para o subitem)"
			aadd(aCri[2],{""   ,STR0044+"                  ",str(nTTVlrGLO - nVlrGLOB11,17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Diferenca"
			if nTTVlrGTX > 0
				aadd(aCri[2],{""   , "Glosa sobre taxa",str(nTTVlrGTX,17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			endif
			
			lFlag := .t.
			
		else
			
			//cria o bdx sem que a guia vá para anlaise de glosas
			aBDXSeAnGl[1] := .f.
			
			aadd(aBDXSeAnGl[2],{__aCdCri049[1],PLSBCTDESC()			,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			aadd(aBDXSeAnGl[2],{""   ,STR0041                 		,str(nTTVlrBPR,17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Valor Contratado"
			aadd(aBDXSeAnGl[2],{""   ,STR0042+" + "+STR0043   		,str(( nTTVlrMAN + nTTVlrGLO ),17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Valor Informado/Apresentado"###"Valor Contratado (caso nao seja apresentado nenhum valor para o subitem)"
			aadd(aBDXSeAnGl[2],{""   ,STR0044+"                  "  ,str( nTTVlrGLO - nVlrGLOB11,17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Diferenca"

			if nTTVlrGTX > 0
				aadd(aBDXSeAnGl[2],{""   , "Glosa sobre taxa",str(nTTVlrGTX,17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			endif

		endIf
		
	endIf
	
endIf

if ( ! empty(cMatCob) ) .and. ( ! cMatCob $ cMatrUsr + cMatAnt ) .and. ( PLSPOSGLO(PLSINTPAD(),__aCdCri088[1],__aCdCri088[2],clocalExec) .and. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,__aCdCri088[1]} ) )
	
	aadd(aCri[2],{__aCdCri088[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
	aadd(aCri[2],{""   ,STR0048                 ,cMatrUsr+" - "+cNomUsr,"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Usuario autorizado"
	
	if ! empty(cMatAnt)
		aadd(aCri[2],{""   ,STR0049+"    "                 ,cMatAnt,"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Matric. Antiga"
	endIf
	
	aadd(aCri[2],{""   ,STR0050     ,cMatCob+" - "+cNomCob,"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Usuario cobrado"
	
	lFlag := .t.
	
endIf

if ( ! empty(dDatCob) ) .and. ( dDatCob <> dDatPro ) .and. ( PLSPOSGLO(PLSINTPAD(),__aCdCri089[1],__aCdCri089[2],clocalExec,"0") .and. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,__aCdCri089[1]} ) )
	
	aadd(aCri[2],{__aCdCri089[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
	aadd(aCri[2],{""   ,STR0051                 ,dtoc(dDatPro),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Data autorizada"
	aadd(aCri[2],{""   ,STR0052     ,dtoc(dDatCob),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Data cobrada"
	
	lFlag := .t.
	
endIf

if ( ! empty(cHorCob) ) .and. ( cHorCob <> cHorPro ) .and. ( PLSPOSGLO(PLSINTPAD(),__aCdCri089[1],__aCdCri089[2],clocalExec,"0") .and. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,__aCdCri089[1]} ) )
	
	aadd(aCri[2],{__aCdCri089[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
	aadd(aCri[2],{""   ,STR0053                 ,cHorPro,"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Hora autorizada"
	aadd(aCri[2],{""   ,STR0054     ,cHorCob,"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Hora cobrada"
	
	lFlag := .t.
	
endIf

If ( BD6->BD6_QTDAPR > 0 ) .And. ( BD6->BD6_QTDAPR > nQtdPro ) .And. ( PLSPOSGLO(PLSINTPAD(),__aCdCri087[1],__aCdCri087[2],cLocalExec) .And. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,__aCdCri087[1]} ) )
	aadd(aCri[2],{__aCdCri087[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
	aadd(aCri[2],{""   ,STR0046                 ,str(nQtdPro,7,2),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Quantidade Contratada/Autorizada"
	aadd(aCri[2],{""   ,STR0047     ,str(BD6->BD6_QTDAPR,7,2),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Quantidade Informada/Cobrada"
	aadd(aCri[2],{""   ,STR0044+"                  "     ,str(BD6->BD6_QTDAPR-nQtdPro,7,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Diferenca"
	lFlag := .T.
Endif

// Ponto de Entrada para gerar/manipular BD7
if existBlock("PLGERBD7")
	execBlock("PLGERBD7",.f.,.f.,{ BD6->(recno()) } )
endIf

lRet := aCri[1]

//Houve pelo menos 1 critica...
if lFlag
	lRet := .f. 
endIf

//Somamos o valor do desconto do contrato pré-estabelecido aqui no final
//para os casos de coparticipação baseada no valor de pagamento serem calculados corretamente.
nTTVlrMAN += nDesPreEs
nTTVlrPAG += nDesPreEs

return( { lRet, aCri[2], nTTVlrPAG, nTTVlTxPG, nTTVlrMAN, nTTVlPeIP, nTTVlrGIP } ) 

/*/{Protheus.doc} PL720GCP
Grava a composicao da co-participacao
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PL720GCP(aAux, nPerCop, nValCop, nVlrBPF, nVlrPF, nVlrTPF, nVlrTAD, nPerTAD,;
				 nPrCbHEsp, cAliasEn, cPgNoAto, nPerMaj, aCobertPro, cFranquia,;
				 nSlvTotal, nSlvBase, nLimFra, nPerda, nSlvTx, nSlvPerc, cPdDrRDA, cCDTBRC,;
				 aUnidsVLD, aCalcEve, aComEveZ, lPacGenInt)				  
				  
local cCodUnd		:= ""
local cCodUndVLD	:= ""
local cCodUndTDE	:= ""
local cKeyAux      	:= ""
local cMVPLSCAUX	:= getNewPar("MV_PLSCAUX","AUX")
local nTamCODUNM	:= BD7->( tamSX3("BD7_CODUNM")[1] )
local nAux			:= 0
local nI			:= 0
local nPercen		:= 0
local nForUnd		:= 0
local nTTVlrTAD 	:= 0
local nTTVlrBPF 	:= 0
local nTTVlrTPF		:= 0
local nVlrPRDA		:= 0
local l500RCB 		:= isInCallStack("PLSA500RCB") 
local lModCTX      	:= getNewPar("MV_PLSMCTA","1") == "1"
local cMV_PLSCPA	:= getNewPar("MV_PLSCPA","PA") 
local cMV_PLSCAUX	:= getNewPar("MV_PLSCAUX","AUX")
local cMV_SIMB1		:= getNewPar("MV_SIMB1","R$")
local lRet         	:= .t.
local aRetUnd		:= {}
local aMatTOTBD7	:= {}
Local nPertot		:= 1
Local lUnimed		:= .T.
Local cCodempInt	:= GetNewPar("MV_PLSGEIN","0050") 
Local lPErcen		:= .T.

Local nUsEspInt	:= 0
Local cAlUSInt	:= ""
Local nPerPFInt	:= 0
Local nVlrPFInt	:= 0
Local nVlrTADInt	:= 0 
Local nVlrTPFInt	:= 0
Local nVlrBPFInt	:= 0
Local nAcuPFInt	:= 0
Local nAcuTxInt	:= 0
Local nAcuBPFint := 0
local aDadUsr	:= PLSGETUSR()
local lCopPag   := len(aDadUsr) >= 72 .and. aDadUsr[72] == "1"
Local lIntPagAto := .F.
Local aArBE4 := BE4->(getArea())
Local cGuiaInt := ""
local lChkDopp		:= getNewPar('MV_PLCKDOP','0') == '1'
Local lDOP := .F.
Local aDadPgtRDA := {}
Local nForPRDA	:= 1
Local nAuxPRDA	:= 0
Local nPosMaxPRDA := 0
local lAjustPRDA := .F.
Local nTotAjuPRDA := 0
local lVap :=  cAliasEn =="VAP"
Local ntotPrda	:= 0

default nValCop    	:= 0
default nPrCbHEsp  	:= 0
default aComEveZ	:= {}
default lPacGenInt := .F.

If BCI->BCI_TIPGUI == "05"
	cGuiaInt := BE4->BE4_GUIINT
else
	cGuiaInt := BD5->BD5_GUIINT
endIf

If !(empty(cGuiaInt))
	BE4->(dbsetOrder(1))
	If BE4->(MsSeek(xFilial("BE4") + cGuiaInt)) .AND. BE4->BE4_PAGATO == "1"
		lIntPagAto := .T.
	endIf
	restarea(aArBE4)
endIf

for nForUnd := 1 to len(aUnidsVLD)	
			
	BD7->( dbGoTo(aUnidsVLD[nForUnd,4]) )
			
	If lChkDopp .ANd. Alltrim(BD7->BD7_CODUNM) == "DOP"
		lDOP := .T.
	endIf
	
	cCodUndVLD 	:= padr(aUnidsVLD[nForUnd,1], nTamCODUNM)
	cCodUndTDE	:= iIf( len(aUnidsVLD[nForUnd]) > 2, iIf( cCodUndVLD $ cMVPLSCAUX, PLSCHMP(cCodUndVLD), allTrim(aUnidsVLD[nForUnd,3]) ) , "")
		
	cKeyAux 	:= allTrim(aUnidsVLD[nForUnd,2])
			
	nAux := aScan(aAux, {|x| allTrim(x[1]) == allTrim(cCodUndVLD) .and. IIF( alltrim(cMVPLSCAUX) == alltrim(cCodUndVLD), allTrim(x[15]) == allTrim(cKeyAux), .T.) } )
			
	if nAux == 0
		nAux := 1
	endIf

	nUsEspInt	:= 0
	cAlUSInt	:= 0
	nPerPFInt	:= 0
	nVlrPFInt	:= 0				
	nVlrTADInt	:= 0
	nVlrTPFInt	:= 0
	nPerPFInt	:= 0
	nVlrBPFInt	:= 0

	//Houve alguma falha na valorizacao deste subitem
	if ( len(aAux[nAux,5]) == 0 .or. ! empty(aAux[nAux,4]) ) 
		
		BD7->(recLock("BD7",.f.))
			BD7->BD7_DESERR := aAux[nAux,4]
		BD7->(msUnLock())
		
	else

		If (cAliasEn $ "BGH/BGI/B6I")
			nPerCop := 100
		endif

		If !lIntPagAto
			If cFranquia == "1" .OR. lCopPag
				nPercen := BD7->BD7_PERCEN / 100

			elseIf nPerCop > 0 .AND. !(Len(aAux) == 1) .AND. !lPacGenInt .AND. !lVap
				aRetUnd := PLSA720UND(cCodUndVLD, .T.)
								
				for nI := 1 to len(aRetUnd)
					
					cCodUndVLD 	:= aRetUnd[nI]
					cKeyAux := allTrim(aUnidsVLD[nForUnd,2])	
					nAux 		:= aScan(aAux, {|x| allTrim(x[1]) == allTrim(cCodUndVLD) .and. IIF( alltrim(cMVPLSCAUX) == alltrim(cCodUndVLD), allTrim(x[15]) == allTrim(cKeyAux), .T.) } )
					
					if nAux > 0 .AND. Len(aAux[nAux][5]) >= 1
						
						nUsEspInt	:= aAux[nAux][5][1][3]
						cAlUSInt	:= aAux[nAux][5][1][2]
						nPerPFInt	:= nPerCop
						nVlrPFInt	:= aAux[nAux][5][1][4] * nPerCop / 100				
						nVlrBPFInt	:= aAux[nAux][5][1][4]
						if lModCTX	
							nVlrTADInt := nVlrPFInt * nPerTAD / 100
						else
							nVlrTADInt := (nVlrPFInt / nVlrPF) * nVlrTad
						endif
						
						nVlrTPFInt	:= nVlrTADInt + nVlrPFInt
						nPerPFInt	:= round(nPerPFInt,2)
												
					endif
					
					if nAux > 0
						exit
					endIf
					
				next
				lPErcen := .F.
			elseif lPacGenInt
				nPercen := 1 / Len(aUnidsVLD)
				nPertot := nPercen * Len(aUnidsVLD)
			else

				nPercen := 1 / Len(aComEveZ)
				nPertot := nPercen * Len(aUnidsVLD)

			endIf
		else
			nVlrBPF := 0
			nVlrTAD := 0
			nVlrTPF := 0
			nVlrPF := 0
		endIf
		BD7->(recLock("BD7",.f.))

			BD7->BD7_CODUNC	:= cCodUnd
			BD7->BD7_PERPF  := nPerCop
			BD7->BD7_PRCHES := nPrCbHEsp
			if BD7->BD7_BLOPAG != "1" //Se bloqueado, não gera coparticipação
				If lPErcen
					BD7->BD7_VLRBPF := ( nVlrBPF * nPercen )
					BD7->BD7_VLRTAD := ( nVlrTAD * nPercen )
					BD7->BD7_VLRTPF := ( nVlrTPF * nPercen )
				else
					BD7->BD7_VLRBPF := nVlrBPFInt //nVlrBPF * nVlrTPFInt / nVlrTPF
					BD7->BD7_VLRTAD := nVlrTADInt
					BD7->BD7_VLRTPF := nVlrTPFInt 
				EndIf
			else
				nVlrBPFInt := 0
				nVlrTADInt := 0
				nVlrTPFInt := 0	
			endif
			if cPdDrRDA == "1"
								
				nVlrPRDA := ( BD7->BD7_VLRTPF - BD7->BD7_VLRTAD )
				ntotPrda += nVlrPRDA
				
				if ntotPrda > nVlrTPF
					nVlrPRDA -= ntotPrda - nVlrTPF
				endif
				
				if ! l500RCB 
					if BD7->BD7_VLRMAN >= nVlrPRDA
						BD7->BD7_VLRMAN -= nVlrPRDA	
					else
						BD7->BD7_VLRMAN := 0
					endIf
				endif

				BD7->BD7_VLTXPG := ( BD7->BD7_VLRMAN * BD7->BD7_PRTXPG ) / 100
				
				aRet 			:= getValTPC(BD7->BD7_VLTXPG, BD7->BD7_VLTXAP, BD7->BD7_TIPGUI == '10', .t.)
				nVlrTx			:= aRet[1]
				nVlrGtx			:= aRet[2]

				BD7->BD7_VLRGTX := nVlrGtx
						
				BD7->BD7_VLRPAG	:= BD7->BD7_VLRMAN + nVlrTx
				if ! l500RCB 
					BD7->BD7_VLRGLO += nVlrPRDA
				endif
				BD7->BD7_VLINPT := (BD7->BD7_VLRPAG * BD7->BD7_PEINPT) / 100
				BD7->BD7_GLINPT := ( ( BD7->BD7_VLRGLO + BD7->BD7_VLRGTX ) * BD7->BD7_PEINPT) / 100
				
				aadd(aDadPgtRDA,{BD7->(recno()),nVlrPRDA,BD7->BD7_ALIAUS == 'B4R',BD7->BD7_VLRPAG})
			endIf	
			
			If nAux > 0 .AND. Len(aAux[nAux][5]) >= 1
				BD7->BD7_RFTDEC := aAux[nAux,5,1,1]
				BD7->BD7_ALIPF  := aAux[nAux,5,1,2] 
				BD7->BD7_COEFPF := aAux[nAux,5,1,3]
				BD7->BD7_FTMTPF := aAux[nAux,5,1,6]
				BD7->BD7_TPCOPF := aAux[nAux,5,1,7]
				BD7->BD7_MAJORA := BD6->BD6_MAJORA
			endIf

			if nValCop > 0 .and. ! allTrim(cCodUnd) $ cMV_PLSCPA .and. ! allTrim(cCodUnd) $ cMV_PLSCAUX
					
				BD7->BD7_COEFPF := nValCop   
				BD7->BD7_TPCOPF := cMV_SIMB1
				
			endIf

			if BD7->BD7_BLOPAG == "1"
				BD7->BD7_COEFPF := 0
				BD7->BD7_TPCOPF := ""
			endif
		
		BD7->(msUnLock())
		if cPdDrRDA == "1" .AND. ! l500RCB .AND. nVlrPRDA > 0
			BD6->(RecLock("BD6", .F.))
				BD6->BD6_VLRGLO += nVlrPRDA
				If BD6->BD6_VLRGLO > BD6->BD6_VLRBPR
					BD6->BD6_VLRGLO := BD6->BD6_VLRBPR
				endIf
			BD6->(MsUnLock())
		endif
	endIf

	//Na última passagem do laço vamos ver quanto do valor de coparticipação ficou em uma composição
	//que foi paga na RDA e está cofigurada como exceção de pagamento (B4R) para sempre valorar zero
	//Também vamos pegar qual o maior valor de pagamento para fazer os ajustes nele.
	if Len(aDadPgtRDA) > 0 .AND. nForUnd == len(aUnidsVLD)
		lAjustPRDA := .F.
		nTotAjuPRDA := 0
		for nForPRDA := 1 To len(aDadPgtRDA)
			if nAuxPRDA < aDadPgtRDA[nForPRDA][4]
				nPosMaxPRDA := nForPRDA
				nAuxPRDA := aDadPgtRDA[nForPRDA][4]
			endif
			if aDadPgtRDA[nForPRDA][3]
				lAjustPRDA := .T.
				nTotAjuPRDA += aDadPgtRDA[nForPRDA][2]
			endif
		next
	endif

	getTotBD7(aMatTOTBD7)
	If !lPErcen
		nAcuPFInt	+= nVlrTPFInt
		nAcuTxInt	+= nVlrTADInt
		nAcuBPFint	+= nVlrBPFInt
	EndIf
next

if lAjustPRDA .AND. nPosMaxPRDA > 0
	//Aqui nós vamos transferir o valor da glosa gerada pelo pagamento na RDA dos BD7 com exceção de pagamento
	//para o BD7 com maior valor de pagamento
	for nForPRDA := 1 To len(aDadPgtRDA)
		if aDadPgtRDA[nForPRDA][3]
			BD7->(dbGoto(aDadPgtRDA[nForPRDA][1]))
			BD7->(RecLock("BD7",.F.))
				BD7->BD7_VLRGLO := 0
			BD7->(MsUnlock())
		elseif nForPRDA == nPosMaxPRDA
			BD7->(dbGoto(aDadPgtRDA[nForPRDA][1]))
			BD7->(RecLock("BD7",.F.))
				BD7->BD7_VLRBPR -= nTotAjuPRDA
				BD7->BD7_VLRPAG -= nTotAjuPRDA
				BD7->BD7_VLRMAN -= nTotAjuPRDA
				BD7->BD7_VLRGLO += nTotAjuPRDA
			BD7->(MsUnlock())
		endif
	next

	//Depois disso nós atualizamos o aMatTotBD7. Importante: A posição da glosa não é alterada, pois seu valor total
	//foi mantido, apenas foi alterada a parte distribuída em cada BD7.
	if !empty(aMatTOTBD7)
		aMatTOTBD7[2][2] -= nTotAjuPRDA //BPR
		aMatTOTBD7[3][2] -= nTotAjuPRDA //MAN
		aMatTOTBD7[5][2] -= nTotAjuPRDA //PAG
	endif
endif

if lCopPag .and. (nVlrBPF * nPerCop) / 100 != nAcuPFInt
	nAcuPFInt := (nVlrBPF * nPerCop) / 100
endif

//verifica se o total do BD7 esta igual ao BD6 e ajusta
setAjuGUI(aMatTOTBD7, nil, nil, nil, nil, IIF( lPErcen, nVlrBPF * nPertot, nAcuBPFint), IIF(lPErcen, nVlrTPF * nPertot, nAcuPFInt), IIF(lPErcen, nVlrTAD * nPertot, nAcuTxInt), cPdDrRDA )
nPertot		:= 0

if len(aMatTOTBD7) > 0
	
	nTTVlrBPF := aMatTOTBD7[6,2]
	nTTVlrTAD := aMatTOTBD7[7,2]
	nTTVlrTPF := aMatTOTBD7[8,2]
	
	BD6->(recLock("BD6",.f.))
	
		//1=Co-Participacao;2=Custo Operacional/VD
		BD6->BD6_TPPF 	:= iIf( ( nPerCop == 100 ) .or. ( nPerCop == 0 .and. BD6->BD6_MODCOB == "2" ), "2", "1" )
		BD6->BD6_CNTCOP := "1"
		BD6->BD6_MAJORA := nPerMaj
		BD6->BD6_CDTBRC := cCDTBRC
		BD6->BD6_ALIAPF := cAliasEn
		BD6->BD6_PAGATO := cPgNoAto
		
		// Atualiza os campos que indicam o nivel da critica ou da autorização.
		// Isso deve existir porque se for liberado pela autidoria, os campos devem conter o conteudo real sobre esses niveis.
		if valType(aCobertPro) == "A" .and.  len(aCobertPro) > 0 .and. aCobertPro[1]
			BD6->BD6_NIVAUT := aCobertPro[3]
			BD6->BD6_CHVNIV := aCobertPro[4]
		endIf
	
		if cFranquia == "1"
					
			if nPerCop > 0
				BD6->BD6_F_VLPF := (nSlvTotal / nPerCop) * 100
			endIf
			
			BD6->BD6_CONSFR := cFranquia
			BD6->BD6_F_VLOR := nSlvBase
			BD6->BD6_F_VFRA := nLimFra
			BD6->BD6_F_PPER := nPerda
			BD6->BD6_F_TXOR := nSlvTx
			BD6->BD6_F_TOOR := nSlvTotal
			BD6->BD6_F_POTX := nSlvPerc
			
		endIf
		
		BD6->BD6_PERTAD := nPerTAD
		BD6->BD6_VLRTAD := nTTVlrTAD

		// para casos em que utilizou duas linhas do nível de cop
		// e uma é valor fixo e outra é porcentagem
		if nValCop > 0 .and. nPerCop > 0
			nPerCop := 0
		endif
		
		BD6->BD6_PERCOP := IIF(cAliasEn $ "BGH/BGI/B6I", 100, nPerCop)
		BD6->BD6_VLRBPF := nTTVlrBPF
		BD6->BD6_VLRPF  := ( nTTVlrTPF - nTTVlrTAD )
		BD6->BD6_VLRTPF := nTTVlrTPF
		
		//Bloqueio da cobranca da PF, porque o pagamento sera feito diretamente a RDA
		if cPdDrRDA == "1"
		
	   		PLSPOSGLO(PLSINTPAD(),__aCdCri227[1],__aCdCri227[2],"1")
			PLBLOPC('BD6', .t., __aCdCri227[1], PLSBCTDESC(), .f., .t.)
			
			BD6->BD6_PAGRDA := cPdDrRDA
			BD6->BD6_VRPRDA := BD6->BD6_VLRPF

			BD6->BD6_VLRBPR := aMatTOTBD7[2,2]
			BD6->BD6_VLRMAN := aMatTOTBD7[3,2]
			BD6->BD6_VLRGLO := aMatTOTBD7[4,2] 
			BD6->BD6_VLRPAG := aMatTOTBD7[5,2] 			
			BD6->BD6_VLTXPG := aMatTOTBD7[12,2] 
			BD6->BD6_VLRGTX := aMatTOTBD7[13,2] 
			BD6->BD6_VLINPT := aMatTOTBD7[14,2] 
			BD6->BD6_GLINPT := aMatTOTBD7[15,2] 

		endIf
		
	BD6->(msUnLock())
		
endIf	

//este ponto de entrada precisa garantir a integridade dos valores entre BD6 e BD7
if existBlock("PLS720DOP")
	aRetDOP := execBlock("PLS720DOP",.f.,.f.,{lDOP,nVlrTPF,nVlrTAD,nVlrBPF})
	nVlrTPF	:= aRetDOP[1]
	nVlrTAD := aRetDOP[2]
	nVlrBPF := aRetDOP[3]
endIf

return(lRet)

/*/{Protheus.doc} PL720GMF
Grava a mudanca de fase
@type function
@author tuliocesar
@since 13.06.00
@version 1.0
/*/
function PL720GMF(cNextFase, cCpoFase, aCriticas, cAlias, cNumGuia, lValido, lPagAto)
local aArea 		:= getArea()
local aAreaBCI 		:= BCI->(getArea())
local aAreaBD6 		:= BD6->(getArea())
local nFor			:= 0
local nPos			:= 0
local nAux			:= 0
local cCodGlo		:= ''
local cCodPad		:= ''
local cCodPro		:= ''
local bCond			:= ''
local cSequen		:= ''
local cChavLib		:= ''
local cTipoGuia		:= (cAlias)->&( cAlias + "_TIPGUI" )
local cGuiOri		:= ''
local xFilBD7		:= xFilial("BD7")
local xFilBD6		:= xFilial("BD6")
local xFilBCT		:= xFilial("BCT")
local nBDX_VLRPAG 	:= 0
local nBDX_VLRMAN 	:= 0
local nBDX_VLRBPR 	:= 0
local nBDX_VLRAPR 	:= 0
local nBDX_VLRGLO 	:= 0
local nBDX_PERGLO 	:= 0
local nBDX_VLRGTX 	:= 0
local nBDX_PERGTX 	:= 0
local nBDX_VLTXPG	:= 0
local nBDX_VLTXAP	:= 0

local lBD7_DTCTBF 	:= BD7->(fieldPos("BD7_DTCTBF")) > 0
local lBD7_DTDIGI 	:= BD7->(fieldPos("BD7_DTDIGI")) > 0

default lValido:= .f.
default lPagAto:= .f.

// Inicia transacao...
begin Transaction
	
	// Atualiza a guia...
	dbSelectArea(cAlias)
	
	recLock(cAlias,.f.)
	
		if ! lPagAto .and. cTipoGuia == G_REEMBOLSO
			(cAlias)->&( cAlias + "_FASE" ) := PRONTA
		else
			(cAlias)->&( cAlias + "_FASE" ) := cNextFase
		endIf
		
		if cNextFase = PRONTA
			
			(cAlias)->&( cAlias + "_DTANAL" ) := dDataBase	//Data da mudanca de fase da guia
			
		endIf
		
	msUnLock()

	BD7->(dbSetOrder(1))
	BD6->(dbSetOrder(1))
	
	if BD6->( msSeek(xFilBD6 + cNumGuia ) )
		
		while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilBD6 + cNumGuia
			
			BD6->(recLock("BD6",.f.))
			
			BD6->BD6_FASE := cNextFase
			
			if cNextFase = PRONTA
			
				BD6->BD6_DTANAL := dDataBase
				
			endIf

			BD6->(msUnLock())
			
			plTRBBD7("TRBBD7", subStr(cNumGuia,1,4), subStr(cNumGuia,5,4), subStr(cNumGuia,9,8), subStr(cNumGuia,17,8), subStr(cNumGuia,25,1), BD6->BD6_SEQUEN)

			while ! TRBBD7->(eof())
			
				BD7->( dbGoTo( TRBBD7->REC ) )
				
				BD7->(recLock("BD7",.f.))
					
					BD7->BD7_FASE := cNextFase
					
					if cNextFase = PRONTA
						
						BD7->BD7_DTANAL := dDataBase
		
						if lBD7_DTDIGI .and. lBD7_DTCTBF .and. empty(BD7->BD7_DTCTBF)
							BD7->BD7_DTCTBF := iIf(empty(BD7->BD7_LAPRO),BD7->BD7_DTDIGI,date())	
						endIf
						
					endIf
				
				BD7->(msUnLock())
				
			TRBBD7->(dbSkip())
			endDo
			
			TRBBD7->(dbCloseArea())
			
			If ValType(aCriticas) == "A" 
				nPos := aScan(aCriticas,{|x| ! empty(x[1]) .and. allTrim(x[6]) + allTrim(x[7]) == allTrim(BD6->BD6_CODPAD) + allTrim(BD6->BD6_CODPRO) } )
			EndIf
			
			if nPos > 0
			
				BCT->(dbSetOrder(1))
				
				// atualiza as glosas sugeridas pelo sistema...
				for nFor := nPos to len(aCriticas)
					
					// Analisa cada procedimento com a respectiva glosa...
					cCodGlo := aCriticas[nFor,1]
					cCodPad := aCriticas[nFor,6]
					cCodPro := aCriticas[nFor,7]
					
					if empty(cCodGlo)
						loop
					endIf
					
					if len(aCriticas[nFor]) < 8
					
						bCond  := { || allTrim(cCodPad) + allTrim(cCodPro) == allTrim(BD6->BD6_CODPAD) + allTrim(BD6->BD6_CODPRO) }
						
					else
					
						cSequen := aCriticas[nFor,8]
						
						if ! empty(cSequen)
							bCond  := { || cSequen == BD6->BD6_SEQUEN }
						else
							bCond   := { || allTrim(cCodPad+cCodPro) == allTrim(BD6->(BD6_CODPAD+BD6_CODPRO)) }
						endIf
						
					endIf
					
					if eval(bCond)
						
						BCT->( msSeek(xFilBCT + BD6->BD6_CODOPE+cCodGlo) )
						
						// Vai alimentar o BDX. o valor de glosa ja esta calculado
						nBDX_VLRPAG 	:= 0
						nBDX_VLRMAN 	:= 0
						nBDX_VLRBPR 	:= 0
						nBDX_VLRAPR 	:= 0
						nBDX_VLRGLO 	:= 0
						nBDX_PERGLO 	:= 0
						nBDX_VLRGTX 	:= 0
						nBDX_PERGTX 	:= 0
						nBDX_VLTXPG		:= 0
						nBDX_VLTXAP		:= 0
						
						PL720GCR(aCriticas[nFor,4],cCodGlo,aCriticas,nFor,cAlias,cNumGuia,"1",;
								 @nBDX_VLRPAG,@nBDX_VLRMAN,@nBDX_VLRBPR,@nBDX_VLRAPR,@nBDX_VLRGLO,@nBDX_PERGLO,@nBDX_VLRGTX,@nBDX_PERGTX,@nBDX_VLTXPG,@nBDX_VLTXAP,;
								 lValido)
						
						nFor ++
						if nFor <= len(aCriticas) .and. empty(aCriticas[nFor,1])
							
							nFor2 := nFor
							while nFor2 <= len(aCriticas) .and. empty(aCriticas[nFor2,1])
								
								PL720GCR(aCriticas[nFor2,4],cCodGlo,aCriticas,nFor2,cAlias,cNumGuia,"2",;
									 	 nBDX_VLRPAG,nBDX_VLRMAN,nBDX_VLRBPR,nBDX_VLRAPR,nBDX_VLRGLO,nBDX_PERGLO,nBDX_VLRGTX,nBDX_PERGTX,nBDX_VLTXPG,nBDX_VLTXAP,;
										 lValido)
								nFor2 ++
								
							endDo
							
							nFor := --nFor2
						else
							nFor --
						endIf
						
					endIf
					
				next
				
			endIf
				
		BD6->( dbSkip() )
		endDo
		
	endIf
	
	BD6->(restArea(aAreaBD6))

	// Finaliza transacao...
	if existBlock("PLS720G1")
		execBlock("PLS720G1",.f.,.f.,{ cAlias, cNumGuia} )
	endIf
	
end transaction

restArea(aArea)
BCI->(restArea(aAreaBCI))

return

/*/{Protheus.doc} PL720GCR
Grava dados
@type function
@author tuliocesar
@since 13.06.00
@version 1.0
/*/
function PL720GCR(cNivel,cCodGlo,aCriticas,nFor,cAlias,cNumGuia,cTipReg,nBDX_VLRPAG,nBDX_VLRMAN,nBDX_VLRBPR,;
						 nBDX_VLRAPR,nBDX_VLRGLO,nBDX_PERGLO,nBDX_VLRGTX,nBDX_PERGTX,nBDX_VLTXPG,nBDX_VLTXAP,lValido)
local cChavePes 	:= ""
local cSQL 			:= ""
local nVlrApr 		:= 0
local nVlrTx		:= 0
local lGloAut		:= .f.
local aArea 		:= getArea()
local aRet			:= {}
local lBDX_VLTXPG   := BDX->(fieldPos("BDX_VLTXPG")) > 0
local lBDX_VLTXAP   := BDX->(fieldPos("BDX_VLTXAP")) > 0
local lBD6_VLRGTX   := BD6->(fieldPos("BD6_VLRGTX")) > 0
local lUsrGen		:= .f.

default lValido 	:= .f.

BDX->( dbSetOrder(2) )//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO+BDX_TIPREG+BDX_INFGLO

//verifica se tem glosa de valor e esta automatica
cChavePes 	:= cNumGuia + BD6->(BD6_CODPAD + BD6_CODPRO + BD6_SEQUEN) + __aCdCri049[1] + '1'
lGloAut 	:=  BDX->( msSeek(xFilial("BDX") + cChavePes) ) .and. BDX->BDX_TIPGLO == '3'

cChavePes := cNumGuia + BD6->(BD6_CODPAD + BD6_CODPRO + BD6_SEQUEN) + cCodGlo + cTipReg + allTrim(aCriticas[nFor,3])

if ! BDX->( msSeek(xFilial("BDX") + cChavePes) ) .or. ( len(aCriticas[nFor]) >= 9 .and. ! empty( aCriticas[nFor,9] ) )
	
	BDX->( recLock("BDX",.t.) )
	
		BDX->BDX_FILIAL 	:= xFilial("BDX")
		BDX->BDX_IMGSTA 	:= "BR_VERMELHO"

		BDX->BDX_CODOPE 	:= (cAlias)->&( cAlias + "_CODOPE" )
		BDX->BDX_CODLDP 	:= (cAlias)->&( cAlias + "_CODLDP" )
		BDX->BDX_CODPEG 	:= (cAlias)->&( cAlias + "_CODPEG" )
		BDX->BDX_NUMERO 	:= (cAlias)->&( cAlias + "_NUMERO" )
		BDX->BDX_ORIMOV 	:= BD6->BD6_ORIMOV
		BDX->BDX_NIVEL  	:= IIf( empty(cNivel) .AND. cTipReg == '1', '2', cNivel)

		BDX->BDX_SEQUEN 	:= BD6->BD6_SEQUEN
		BDX->BDX_CODPAD 	:= BD6->BD6_CODPAD
		BDX->BDX_CODPRO 	:= BD6->BD6_CODPRO
		BDX->BDX_DESPRO 	:= iIf( ! empty(BD6->BD6_DESPRO),BD6->BD6_DESPRO,BR8->(Posicione("BR8",1,xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO),"BR8_DESCRI")))

		BDX->BDX_CODGLO 	:= cCodGlo
		BDX->BDX_GLOSIS 	:= cCodGlo
		BDX->BDX_DESGLO 	:= aCriticas[nFor,2]
		BDX->BDX_INFGLO 	:= aCriticas[nFor,3]
		
		//1=Eletronica;2=Manual;3=Automatica
		BDX->BDX_TIPGLO 	:= iIf( len(aCriticas[nFor]) >= 12 .and. ! empty(aCriticas[nFor,12]), aCriticas[nFor,12], "1" )
		BDX->BDX_TIPREG 	:= cTipReg
		
		BDX->BDX_QTDPRO := BD6->BD6_QTDPRO
		BDX->BDX_DATPRO := BD6->BD6_DATPRO

		//1=Principal;2=Descritivos
		if cTipReg == "1"
		
			BDX->BDX_RESPAL := ""
			BDX->BDX_VLRBPR := BD6->BD6_VLRBPR
			BDX->BDX_VLRAPR := BD6->BD6_VALORI
			
			BDX->BDX_VLRPAG := BD6->BD6_VLRPAG
			BDX->BDX_VLRMAN := BD6->BD6_VLRMAN
			
			if ! lGloAut
				
				BDX->BDX_VLRGLO := IIF(BD6->BD6_VLRGLO >= BD6->BD6_VRPRDA, BD6->BD6_VLRGLO - BD6->BD6_VRPRDA, 0)
				BDX->BDX_PERGLO := ( BD6->BD6_VLRGLO / ( BD6->BD6_VLRMAN + BD6->BD6_VLRGLO ) ) * 100
				
				if lBD6_VLRGTX	
					BDX->BDX_PERGTX := ( BD6->BD6_VLRGTX / ( BD6->BD6_VLTXPG + BD6->BD6_VLRGTX ) ) * 100
					BDX->BDX_VLRGTX := getValTPC(BD6->BD6_VLTXPG, BD6->BD6_VLTXAP, nil, .T.)[02]
				endIf

			elseIf lBD6_VLRGTX .and. BD6->BD6_VLRGTX > 0
				
				BDX->BDX_PERGTX := ( BD6->BD6_VLRGTX / ( BD6->BD6_VLTXPG + BD6->BD6_VLRGTX ) ) * 100
				BDX->BDX_VLRGTX := getValTPC(BD6->BD6_VLTXPG, BD6->BD6_VLTXAP, nil, .T.)[02]			

			endIf
			
			// Será feito a conferência se já existe taxa glosada por estar duplicando o valor da taxa na análise de glosa.  
			if lBDX_VLTXPG
				If lBD6_VLRGTX
					BDX->BDX_VLTXPG := IIF(BDX->BDX_PERGTX == 100 .AND. BDX->BDX_VLRGTX > 0, 0, BD6->BD6_VLTXPG)
				Else
					BDX->BDX_VLTXPG := BD6->BD6_VLTXPG
				EndIf
			endIf	
				
			if lBDX_VLTXAP
				BDX->BDX_VLTXAP := BD6->BD6_VLTXAP
			endIf	

			BDX->BDX_VLRGL2 := BDX->BDX_VLRGLO
			BDX->BDX_PERGL2 := BDX->BDX_PERGLO

			BDX->BDX_ACAO 	:= ''
			BDX->BDX_ACAOTX := ''
			
			nBDX_VLRPAG 	:= BDX->BDX_VLRPAG
			nBDX_VLRMAN 	:= BDX->BDX_VLRMAN
			nBDX_VLRBPR 	:= BDX->BDX_VLRBPR
			nBDX_VLRAPR 	:= BDX->BDX_VLRAPR

			nBDX_VLRGLO 	:= BDX->BDX_VLRGLO
			nBDX_PERGLO 	:= BDX->BDX_PERGLO
			nBDX_PERGTX		:= BDX->BDX_PERGTX
			nBDX_VLRGTX 	:= BDX->BDX_VLRGTX
			
			if lBDX_VLTXPG .and. lBDX_VLTXAP
				nBDX_VLTXPG	:= BDX->BDX_VLTXPG
				nBDX_VLTXAP	:= BDX->BDX_VLTXAP
			endIf
				
		endIf
		
	BDX->(msUnLock())
	
elseIf BDX->( found() ) .and. cTipReg == "1"
	
	BDX->( recLock("BDX",.f.) )

		BDX->BDX_PERGLO := ( BD6->BD6_VLRGLO / ( BD6->BD6_VLRMAN + BD6->BD6_VLRGLO ) ) * 100
		BDX->BDX_VLRGLO := BD6->BD6_VLRGLO
		
		if lBD6_VLRGTX
			BDX->BDX_PERGTX := ( BD6->BD6_VLRGTX / ( BD6->BD6_VLTXPG + BD6->BD6_VLRGTX ) ) * 100
			BDX->BDX_VLRGTX := getValTPC(BD6->BD6_VLTXPG, BD6->BD6_VLTXAP, nil, .T.)[02]
		endIf	
		
		BDX->BDX_ACAO 	:= iIf(BDX->BDX_PERGLO == 100 .and. BDX->BDX_VLRGLO == 0, '2', iIf(BDX->BDX_PERGLO > 0, '1', '' ) )
		BDX->BDX_ACAOTX := iIf(BDX->BDX_PERGTX == 100 .and. BDX->BDX_VLRGTX == 0, '2', iIf(BDX->BDX_PERGTX > 0, '1', '' ) )

		if lBDX_VLTXPG .and. lBDX_VLTXAP
			BDX->BDX_VLTXPG := BD6->BD6_VLTXPG
			BDX->BDX_VLTXAP := BD6->BD6_VLTXAP
		endIf	
		
		BDX->BDX_VLRGL2 := BDX->BDX_VLRGLO
		BDX->BDX_PERGL2 := BDX->BDX_PERGLO
		
		BDX->BDX_VLRMAN := BD6->BD6_VLRMAN
		BDX->BDX_VLRPAG := BD6->BD6_VLRPAG
		
		nBDX_VLRPAG 	:= BDX->BDX_VLRPAG
		nBDX_VLRMAN 	:= BDX->BDX_VLRMAN
		nBDX_VLRBPR 	:= BDX->BDX_VLRBPR
		nBDX_VLRAPR 	:= BDX->BDX_VLRAPR

		nBDX_VLRGLO 	:= BDX->BDX_VLRGLO
		nBDX_PERGLO 	:= BDX->BDX_PERGLO
		nBDX_PERGTX 	:= BDX->BDX_PERGTX 
		nBDX_VLRGTX 	:= BDX->BDX_VLRGTX  
		
		if lBDX_VLTXPG .and. lBDX_VLTXAP
			nBDX_VLTXPG	:= BDX->BDX_VLTXPG
			nBDX_VLTXAP	:= BDX->BDX_VLTXAP
		endIf	
			
	BDX->(msUnLock())
	
endIf

restArea(aArea)

return

/*/{Protheus.doc} getTotBD6
Monta o total a ser atualizado no cabecalho da guia 
@type function
@author PLSTEAM
@since 06.01.17
@version 1.0
/*/
function getTotBD6(aMatTOTCAB)

if len(aMatTOTCAB) == 0
	aMatTOTCAB	:= {"","",0,0,0,0,0,0,0,0,0,0}
endIf

aMatTOTCAB[1]  := BD6->BD6_TIPGUI
aMatTOTCAB[2]  := BD6->BD6_CODOPE
aMatTOTCAB[3]  += BD6->BD6_VLRBPR
aMatTOTCAB[4]  += BD6->BD6_VLRMAN
aMatTOTCAB[5]  += BD6->BD6_VLRGLO
aMatTOTCAB[6]  += BD6->BD6_VLRPAG
aMatTOTCAB[7]  += BD6->BD6_VLRBPF
aMatTOTCAB[8]  += BD6->BD6_VLRPF
aMatTOTCAB[9]  += BD6->BD6_VLRTAD
aMatTOTCAB[10] += BD6->BD6_VLRTPF
aMatTOTCAB[11] += BD6->BD6_VALORI
aMatTOTCAB[12] += BD6->BD6_VLRAPR

return

/*/{Protheus.doc} setLimFra
limite de franquia
O tratamento abaixo é para ajustar os valores de coparticipação caso tenha sido informado o mesmo procedimento mais de uma vez na guia
Essa situação pode ocorrer em um xml por exemplo, onde o prestador pode enviar a cobrança de cada participação de um procedimento
separadamente, gerando mais de um BD6 para o mesmo evento, com isso pode ocorrer da coparticipação dos pedaços separados ficarem maior
Que o total da franquia, quando somados.
Se não tem limite de franquia, nem entra aqui
@type function
@author TOTVS
@since 27/12/16
@version 1.0
/*/
function setLimFra(nLimFra, nVlrTAD, nVlrBPF, nVlrTPF, nVlrPF, nTaxa)
local nVlrPFZZZ		:= 0
local nZZ			:= 0
local nRecZZZ		:= BD6->(recno()) //eventualmente vou passar no registro original, não irei considerar
local cChvZZZ		:= BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) //Chave de busca, vamos olhar a guia toda
local cChvDupZZZ	:= BD6->(BD6_CODPAD+BD6_CODPRO+ dtos(BD6_DATPRO)) //Chave de duplicidade, procedimento + data (vamos olhar na guia, então o beneficiário é sempre o mesmo
local lFoundZZZ		:= .f.
local aCmpBD7ZZ		:= {}
local aCmpwhilZ		:= {}
local aAreaZZZ 		:= BD6->(GetArea())
local aArea7ZZ 		:= BD7->(GetArea())

default nTaxa := 0

BD7->(dbSetOrder(1))
if BD7->(msSeek(xFilial("BD7") + cChvZZZ + BD6->BD6_SEQUEN))
	
	while !BD7->(eof()) .and. BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cChvZZZ + BD6->BD6_SEQUEN
		
		//Array com as participações do procedimento que estamos verificando
		aAdD(aCmpBD7ZZ, allTrim(BD7->BD7_CODUNM))
		
	BD7->(DbSkip())
	endDo
	
endIf

if BD6->(msSeek(xFilial("BD6") + cChvZZZ))
	
	while !BD6->(eof()) .and. cChvZZZ == BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
		
		aCmpwhilZ	:= {}
		lFoundZZZ	:= .f.
		
		if BD6->(recno()) <> nRecZZZ .and. BD6->(BD6_CODPAD+BD6_CODPRO + dtos(BD6_DATPRO)) == cChvDupZZZ
			
			if BD7->(msSeek(xFilial("BD7") + cChvZZZ + BD6->BD6_SEQUEN))
				
				while !BD7->(eof()) .and. BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cChvZZZ + BD6->BD6_SEQUEN
					
					//Array com as participações do outro procedimento encontrado
					aAdD(aCmpwhilZ, allTrim(BD7->BD7_CODUNM))
					
				BD7->(DbSkip())
				endDo
				
			endIf
			
		endIf
		
		//Se não achou ninguém, então nem faz essa parte
		if !(empty(aCmpWhilZ))
			
			for nZZ := 1 to len(aCmpWhilZ)
				
				//Se achar uma composição muda pra .t., pois não vai somar no VlrPFZZZ
				if aScan(aCmpBD7ZZ, aCmpWhilZ[nZZ]) > 0
					lFoundZZZ := .t.
					Exit
				endIf
				
			next
			
			lFoundZZZ := !(lFoundZZZ)
			
			//Se chegou aqui, somamos no total de coparticipação já apurado
			if lFoundZZZ
				nVlrPFZZZ += BD6->BD6_VLRPF
			endIf
			
		endIf
		
		BD6->(DbSkip())
	endDo
	
endIf

//retornamos pro registro certo
restArea(aArea7ZZ)
restArea(aAreaZZZ)

//Vai atingir/passar o limite de franquia a soma dos dois
if (nVlrPFZZZ + nVlrPF) > nLimFra
	
	//Se ainda não atingiu o limite, pomos a diferença aqui
	if nLimFra - nVlrPFZZZ > 0
		
		nVlrPF    := nLimFra - nVlrPFZZZ

		//Taxa administrativa sobre o valor liquido da coparticipacao
	   	if getNewPar("MV_PLSMCTA","1") == "1"
			nVlrTAD := Round(nVlrPF * nTaxa / 100, 2)
	   	endIf	
	   		
		//Este parametro visa o calculo da taxa independente da franquia,      
		//ou seja, cobra-se a taxa sobre o valor base + a franquia			 
	   	if nVlrTAD > 0 .and. getNewPar("MV_PLSFCFR","1") == "0"     
	   		nVlrTPF := nVlrPF + nVlrTAD
		else
			nVlrTPF := iif(nVlrPF + nVlrTAD > nLimFra, nLimFra, nVlrPF + nVlrTAD)
		endif
		
	//Se já ultrapassou o teto, zeramos
	else
		nVlrPF    := 0
		//Taxa administrativa sobre o valor liquido da coparticipacao
	   	if getNewPar("MV_PLSMCTA","1") == "1"
			nVlrTAD := Round(nVlrPF * nTaxa / 100, 2)
	   	endIf	
		nVlrTPF   := nVlrTAD
	endIf
	
endIf

return

/*/{Protheus.doc} setCOPBD6
ajusta a coparticipacao conforme aDadBD6
@type function
@author PLSTEAM
@since 20.02.06
@version 1.0
/*/
function setCOPBD6(aDadBD6, nValCopF, lCopPag)
local nX		:= 0
local nDif		:= 0
local nSoma		:= 0
local nValRed 	:= (nValCopF / len(aDadBD6))//valor redondo sem decimais
local nValDec 	:= (nValCopF - nValCopF) 	//valor das decimais
local nValFin 	:= nValRed + nValDec 		//calculo do valor com decimais
local nPerTAD 	:= 0		
local nPerCOP	:= 0	
local nVlrPF	:= 0	
local nVlrBPR	:= 0
local nRecBd7	:= 0	
local nPercen	:= 0	
local lModCTX   := getNewPar("MV_PLSMCTA","1") == "1"
local lValBruto	:= getNewPar("MV_PLCTXPG","1") == "1"

BD7->(dbSetOrder(1))//BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODUNM, BD7_NLANC

for nX := 1 to len(aDadBD6)

	if nX == len(aDadBD6)
		nValCopF := nValFin
	else
		nValCopF := nValRed
	endIf

	nPerTAD := aDadBD6[nX,8]
	nPerCOP := aDadBD6[nX,9]
	nVlrBPR	:= aDadBD6[nX,10]
	
	if BD7->(msSeek(xFilial("BD7")+aDadBD6[nX][1]+aDadBD6[nX][2]+aDadBD6[nX][3]+aDadBD6[nX][4]+aDadBD6[nX][5]+aDadBD6[nX][6]))
		
		while ! BD7->(eof()) .and. xFilial("BD7")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
								  xFilial("BD7")+aDadBD6[nX][1]+aDadBD6[nX][2]+aDadBD6[nX][3]+aDadBD6[nX][4]+aDadBD6[nX][5]+aDadBD6[nX][6]

			nPercen := PLGETPCEN(nVlrBPR, BD7->BD7_VLRBPR)
						
			BD7->(recLock("BD7",.f.))

			if lCopPag
				BD7->BD7_VLRBPF := iIf(lValBruto, BD7->BD7_VLRPAG, BD7->BD7_VLRMAN) 
			else
				BD7->BD7_VLRBPF := ( nValCopF * nPercen ) / 100
			endIf
			
			nVlrPF 			:= ( BD7->BD7_VLRBPF * nPerCOP ) / 100
			BD7->BD7_VLRTAD := ( iIf(lModCTX, nVlrPF, BD7->BD7_VLRBPF ) * nPerTAD ) / 100 
			BD7->BD7_VLRTPF := ( nVlrPF + BD7->BD7_VLRTAD )

			nRecBD7 := BD7->(recno())

			BD7->(msUnLock())
			
			nSoma += BD7->BD7_VLRBPF
			
		BD7->(dbSkip())
		endDo
		
		if nSoma <> nValCopF .and. nRecBD7 > 0 .and. !BD7->(eof())
			
			nDif := nValCopF - nSoma
			
			BD7->(dbGoto(nRecBD7))
			
			BD7->(recLock("BD7",.f.))
				BD7->BD7_VLRBPF := BD7->BD7_VLRTPF + nDif
			BD7->(msUnLock())
			
		endIf
		
		nSoma := 0
		
	endIf
	
next nX

return

/*/{Protheus.doc} getTotBD7
Monta o total a ser atualizado no cabecalho da guia 
@type function
@author PLSTEAM
@since 06.01.17
@version 1.0
/*/
function getTotBD7(aMatTOTBD7)
local lBD7_VLTXPG := BD7->(fieldPos("BD7_VLTXPG")) > 0
local lBD7_VLTXAP := BD7->(fieldPos("BD7_VLTXAP")) > 0
local lBD7_VLRGTX := BD7->(fieldPos("BD7_VLRGTX")) > 0
local lBD7_VLINPT := BD7->(fieldPos("BD7_VLINPT")) > 0
local lBD7_GLINPT := BD7->(fieldPos("BD7_GLINPT")) > 0

local lBloCob 	  := BD6->BD6_BLOCPA == '1'

//se esta vazia ou e somatorio de um outro BD6
if len(aMatTOTBD7) == 0 .or. aMatTOTBD7[1,1] <> BD6->(recno())

	aMatTOTBD7 := { {BD6->(recno()), BD7->(recno()) },;									//01
				 	{"VLRBPR", BD7->BD7_VLRBPR },;										//02
				 	{"VLRMAN", BD7->BD7_VLRMAN },;						//03
				 	{"VLRGLO", BD7->BD7_VLRGLO },;						//04
				 	{"VLRPAG", BD7->BD7_VLRPAG },;						//05
				 	{"VLRBPF", BD7->BD7_VLRBPF },;										//06
				 	{"VLRTAD", iif(lBloCob, 0,BD7->BD7_VLRTAD) },;						//07
				 	{"VLRTPF", iif(lBloCob, 0,BD7->BD7_VLRTPF) },;						//08
				 	{"VLRAPR", BD7->BD7_VLRAPR },;										//09
				 	{"PERCEN", BD7->BD7_PERCEN },;										//10
				 	{"VLTXAP", iif(lBD7_VLTXAP,BD7->BD7_VLTXAP,0) },;					//11
				 	{"VLTXPG", iif(lBD7_VLTXPG,BD7->BD7_VLTXPG,0) },;	//12
					{"VLRGTX", iif(lBD7_VLRGTX,BD7->BD7_VLRGTX,0) },;	//13
				 	{"VLINPT", iif(lBD7_VLINPT,BD7->BD7_VLINPT,0) },;					//14
					{"GLINPT", iif(lBD7_GLINPT,BD7->BD7_GLINPT,0) },;					//15
					{"VALORI", BD7->BD7_VALORI },;										//16
					{"RECNO" , BD7->(Recno()) } }

elseIf ! BD7->(eof())
	
	aMatTOTBD7[1,2]  := BD7->(recno())
	aMatTOTBD7[2,2]  += BD7->BD7_VLRBPR
	aMatTOTBD7[3,2]  += BD7->BD7_VLRMAN
	aMatTOTBD7[4,2]  += BD7->BD7_VLRGLO
	aMatTOTBD7[5,2]  += BD7->BD7_VLRPAG
	aMatTOTBD7[6,2]  += BD7->BD7_VLRBPF
	aMatTOTBD7[7,2]  += iif(lBloCob, 0, BD7->BD7_VLRTAD)
	aMatTOTBD7[8,2]  += iif(lBloCob, 0, BD7->BD7_VLRTPF)
	aMatTOTBD7[9,2]  += BD7->BD7_VLRAPR
	aMatTOTBD7[10,2] += BD7->BD7_PERCEN
	
	if lBD7_VLTXAP
		aMatTOTBD7[11,2] += BD7->BD7_VLTXAP
	endIf
		
	if lBD7_VLTXPG
		aMatTOTBD7[12,2] += BD7->BD7_VLTXPG
	endIf	
	
	if lBD7_VLRGTX
		aMatTOTBD7[13,2] += BD7->BD7_VLRGTX
	endIf

	if lBD7_VLINPT
		aMatTOTBD7[14,2] += BD7->BD7_VLINPT
	endIf

	if lBD7_GLINPT
		aMatTOTBD7[15,2] += BD7->BD7_GLINPT
	endIf
	
	aMatTOTBD7[16,2] += BD7->BD7_VALORI
	
	aadd(aMatTOTBD7[17], BD7->(recno()))
else

 	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'getTotBD7 - eof BD7', 0, 0, {})
 		
endIf

return

/*/{Protheus.doc} setAjuGUI
ajusta valores da guia
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function setAjuGUI(aMatTOTBD7, nPrTxPag, nPerInss, nVlrMANBD6, nVlrGLOBD6, nVlrBPFBD6, nVlrTPFBD6, nVlrTADBD6, cPdDrRDA)
local aArea 		:= BD7->(getArea())
local nI			:= 0
local nValorBD6		:= 0
local nPercen		:= 100 
local nValorBD7		:= 0
local nDif			:= 0
local nRecBD7		:= 0
local nValor		:= 0
local nVlrTx 		:= 0
local nVlrGTx 		:= 0
local aRet			:= {}
Local nNegativo		:= 0
Local nY			:= 1 

local lBD7_VLRGTX 	:= BD7->(fieldPos("BD7_VLRGTX")) > 0
local lBD7_VLTXPG 	:= BD7->(fieldPos("BD7_VLTXPG")) > 0
local lBD7_VLINPT 	:= BD7->(fieldPos("BD7_VLINPT")) > 0
local lBD7_GLINPT 	:= BD7->(fieldPos("BD7_GLINPT")) > 0

default nVlrMANBD6	:= 0
default nVlrGLOBD6	:= 0
default nPrTxPag	:= 0
default nPerInss	:= 0
default nVlrBPFBD6	:= 0
default nVlrTPFBD6	:= 0
default nVlrTADBD6	:= 0
default cPdDrRDA	:= ''

if len(aMatTOTBD7) > 0 .and. aMatTOTBD7[1,1] <> 0

	nRecBD7 := aMatTOTBD7[1,2]
	
	for nI := 2 to len(aMatTOTBD7)
		
		nValorBD7 := aMatTOTBD7[nI,2] 
		nValorBD6 := 0
		
		if ( ( nVlrMANBD6 + nVlrGLOBD6 + nVlrBPFBD6 + nVlrTPFBD6 + nVlrTADBD6 > 0 ) .and. aMatTOTBD7[nI,1] $ 'VLINPT' ) .or. ( cPdDrRDA == '1' .and. aMatTOTBD7[nI,1] $ 'VLRMAN|VLTXPG|VLRGTX|VLRPAG|VLINPT|GLINPT' ) 
			
			loop
			
		elseIf aMatTOTBD7[nI,1] $ 'VLTXPG' .and. nPrTxPag > 0 .and. (nVlrMANBD6 > 0 .or. BD6->BD6_VLTXAP > 0)
			
			nValorBD6 := round( ( ( nVlrMANBD6 * nPrTxPag ) / 100 ), PLGetDec('BD6_' + aMatTOTBD7[nI,1]))
			nValorBD6 := getValTPC(nValorBD6, BD6->BD6_VLTXAP, BD6->BD6_TIPGUI == '10', .t.)[1]

		elseIf aMatTOTBD7[nI,1] == 'VLRMAN' .and. nVlrMANBD6 > 0

			nValorBD6 := nVlrMANBD6

		elseIf aMatTOTBD7[nI,1] == 'VLRGLO' .and. nVlrGLOBD6 > 0

			nValorBD6 := nVlrGLOBD6

		elseIf aMatTOTBD7[nI,1] == 'VLRGTX' .and. nPrTxPag > 0 .and. (nVlrMANBD6 > 0 .or. BD6->BD6_VLTXAP > 0)

			nValorBD6 := aMatTOTBD7[nI,2]
			If nValorBD6 == 0 .ANd. nVlrGLOBD6 > 0
				nValorBD6 := round( ( ( nVlrGLOBD6 * nPrTxPag ) / 100 ), PLGetDec('BD6_' + aMatTOTBD7[nI,1]))
			endIf
			
		elseIf aMatTOTBD7[nI,1] == 'GLINPT' .and. nVlrGLOBD6 > 0

			nVlrGTx   := round( ( ( nVlrGLOBD6 * nPrTxPag ) / 100 ), PLGetDec('BD6_' + aMatTOTBD7[nI,1]))
			nValorBD6 := round( ( ( ( nVlrGLOBD6 + nVlrGTx )* nPerInss ) / 100 ), PLGetDec('BD6_' + aMatTOTBD7[nI,1]))
		
		elseIf aMatTOTBD7[nI,1] == 'PERCEN'
			
			if nValorBD7 > 0
				nValorBD6 := 100
			endIf	
			
		elseIf aMatTOTBD7[nI,1] $ 'VLRBPF' 

			If nVlrBPFBD6 > 0 //Olha essa condição aqui dentro pq se não ele entra no elsif do BD6 ali embaixo
				nValorBD6 := nVlrBPFBD6
			endIf
									
		elseIf aMatTOTBD7[nI,1] $ 'VLRTPF' 
			
			If nVlrTPFBD6 > 0 //Olha essa condição aqui dentro pq se não ele entra no elsif do BD6 ali embaixo
				nValorBD6 := nVlrTPFBD6
			endIf
			
		elseIf aMatTOTBD7[nI,1] $ 'VLRTAD' .and. nVlrTADBD6 > 0 
			
			nValorBD6 := nVlrTADBD6
		
		elseIf BD6->(fieldPos("BD6_" + aMatTOTBD7[nI,1]) > 0)
			
			nValorBD6 := &('BD6->BD6_' + aMatTOTBD7[nI,1])
			
		endIf
		
		if nValorBD6 > 0
		
			//minha base e sempre o BD6
			nDif := (nValorBD6 - nValorBD7)
				
			if nDif != 0
			
				BD7->(dbGoTo(nRecBD7))
				
				if ! BD7->(eof())
					
					BD7->(recLock("BD7",.f.))
					
						nValor := &('BD7->BD7_' + aMatTOTBD7[nI,1])
					
						//valor original sendo retirado do total
						aMatTOTBD7[nI,2] -= nValor
						
						//ajustado a diferenca
						nValor += nDif
						
						&('BD7->BD7_' + aMatTOTBD7[nI,1]) := nValor
						 
						//tratamento para campos especificos
						if aMatTOTBD7[nI,1] $ 'VLRMAN|VLTXPG' 
							
							//retira valor original
							aMatTOTBD7[5,2] -= BD7->BD7_VLRPAG
							
							//ajusta valor
							if  lBD7_VLTXPG
								
								aRet 	:= getValTPC(BD7->BD7_VLTXPG, BD7->BD7_VLTXAP, BD7->BD7_TIPGUI == '10', .t.)
								nVlrTx 	:= aRet[1]
								nVlrGTx := aRet[2]
								
								BD7->BD7_VLRPAG := BD7->BD7_VLRMAN + nVlrTx

							else
							
								BD7->BD7_VLRPAG := BD7->BD7_VLRMAN
								
							endIf	
							
							//soma valor correto ao total
							aMatTOTBD7[5,2] += BD7->BD7_VLRPAG
							
							//glosa da taxa
							if lBD7_VLRGTX
								
								//retira valor original
								aMatTOTBD7[13,2] -= BD7->BD7_VLRGTX
								
								//ajusta valor
								BD7->BD7_VLRGTX := nVlrGTx
								
								//soma valor correto ao total
								aMatTOTBD7[13,2] += BD7->BD7_VLRGTX
								
							endIf
							
							if lBD7_VLINPT .and. BD7->BD7_PEINPT > 0
								
								//retira valor original
								aMatTOTBD7[14,2] -= BD7->BD7_VLINPT

								BD7->BD7_VLINPT := (BD7->BD7_VLRPAG * BD7->BD7_PEINPT) / 100

								aMatTOTBD7[14,2] += BD7->BD7_VLINPT
							
							endIf
							
						elseIf aMatTOTBD7[nI,1] $ 'VLRGLO' 

							if lBD7_GLINPT .and. BD7->BD7_PEINPT > 0

								//retira valor original
								aMatTOTBD7[15,2] -= BD7->BD7_GLINPT

								BD7->BD7_GLINPT := ( ( BD7->BD7_VLRGLO + BD7->BD7_VLRGTX ) * BD7->BD7_PEINPT) / 100

								aMatTOTBD7[15,2] += BD7->BD7_GLINPT
							
							endIf
							
						elseIf aMatTOTBD7[nI,1] $ 'VLRTPF' .AND. nValor < 0
							
							nNegativo := nValor

						endIf
						
					BD7->(msUnLock())
					
				endIf	
				
				//soma valor correto ao total
				aMatTOTBD7[nI,2] += &('BD7->BD7_' + aMatTOTBD7[nI,1])
				
				If nNegativo < 0
					For nY := 2 To Len(aMatTOTBD7[17])
						BD7->(DbGoTo(aMatTOTBD7[17][nY]))
						BD7->(RecLock("BD7", .F.))
							BD7->BD7_VLRTPF := 0
							BD7->BD7_VLRBPF := 0
						BD7->(MsUnLock())
					Next
					BD7->(DbGoTo(nRecBD7))
					BD7->(RecLock("BD7", .F.))
						BD7->BD7_VLRTPF := nVlrTPFBD6
						BD7->BD7_VLRBPF := nVlrBPFBD6					
					BD7->(MsUnLock())
				EndIf
			endIf
			
		endIf		
		
	next

endIf

BD7->(restArea(aArea))
	
return


/*/{Protheus.doc} setRetSaldo
retorna o saldo da guia
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function setRetSaldo(cAlias, cTipoGuia, lIncre, cChavLib)
local aAreaBD6 := {}
local aRet			:= {}
local lHatAtv		:= GetNewPar("MV_PLSHAT","0") == "1" .and. FWAliasInDic("B2Z")
local ljaexec       := .F.
default cChavLib	:= ""

if  BD6->BD6_TIPGUI <> "05"
	ljaexec := PlsVrcExec() 
endif

if ! ljaexec   //Se já houve uma execução com o mesmo evento e beneficiario vinculado não faz novamente, estava tirando 2x o saldo
//Se e uma execucao com base em uma liberacao pega o numero da liberacao
if ! empty(BD6->BD6_NRLBOR)

	aAreaBD6 := BD6->(getArea())

	PLSAtuLib(BD6->BD6_NRLBOR,BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO,nil, cTipoGuia $ "05", cTipoGuia $ "06", nil, iIf(lIncre,BD6->BD6_QTDPRO, 0), BD6->BD6_DENREG, BD6->BD6_FADENT)
	
	BD6->(restArea(aAreaBD6))
		
endIf
if lHatAtv .and. cTipoGuia == G_SADT_ODON
	PLHATVLDP(cTipoGuia, BD5->BD5_CODOPE,  BD5->BD5_CODRDA, BD5->BD5_SENHA, cChavLib, BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO), BD6->BD6_CODPAD, BD6->BD6_CODPRO, ;
				.t., BD6->BD6_QTDPRO, iIf(lIncre,BD6->BD6_QTDPRO, 0))		
endIf
endif
return

/*/{Protheus.doc} getValB11
retorna glosa manual com valor
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function getValB11(aCri, cLocalExec, nVlrMANBD6)
local cChaveBD6 := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
local nVlrUNI	:= 0
local nVlrGLOB11:= 0

B11->( dbSetOrder(1) )
if B11->(msSeek(xFilial("B11")+cChaveBD6))
	
	nVlrUNI	:= (BD6->BD6_VLRMAN / BD6->BD6_QTDPRO)

	while !B11->( eof() ) .and. B11->(B11_FILIAL+B11_CODOPE+B11_CODLDP+B11_CODPEG+B11_NUMERO) == xFilial("B11") + cChaveBD6

		PLSPOSGLO(PLSINTPAD(),allTrim(B11->B11_CODGLO),allTrim(B11->B11_DESGLO),cLocalExec)
		
		aadd(aCri[2],{allTrim(B11->B11_CODGLO),allTrim(B11->B11_DESGLO),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,B11->B11_SEQUEN,allTrim(B11->B11_CODTPA),B11->B11_QTDGLO,B11->B11_VLRGLO,"2"} )
		aadd(aCri[2],{""   ,"Valor Glosa" ,str(B11->B11_VLRGLO,17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
		aadd(aCri[2],{""   ,"Qtd. Glosa"  ,str(B11->B11_QTDGLO,17,4),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
		
		if B11->B11_QTDGLO > 0
			nVlrGLOB11 += (nVlrUNI * B11->B11_QTDGLO)
		else
			nVlrGLOB11	+= B11->B11_VLRGLO
		endIf	
		
		if nVlrGLOB11 > nVlrMANBD6
			nVlrGLOB11 := nVlrMANBD6
			nVlrMANBD6 := 0
			exit
		endIf	
		
	B11->( dbSkip() )
	endDo
	
endIf
	
return( { (nVlrMANBD6 - nVlrGLOB11) , nVlrGLOB11 } )

/*/{Protheus.doc} SeekOldBDX

Analisa e recupera glosas anteriores na mudança de fase. Evitando que novas BDX sejam criadas desnecessariamente.

@author Rodrigo Morgon
@since 04/2017
@version P12
/*/
static Function SeekOldBDX(aDadosBDX)
local cQuery	:= ""
local nQtdOldBDX := 0

cQuery := "SELECT BDX_FILIAL, BDX_CODPAD, BDX_CODPRO, BDX_ACAO, BDX_SEQUEN, BDX_VLRBPR, "
cQuery += "BDX_CODGLO, BDX_NIVEL, " + RetSQLName("BDX")+".R_E_C_N_O_ AS RECNOBDX "
cQuery += "FROM "+RetSQLName("BDX")+" WHERE "
cQuery += "BDX_FILIAL = '"+xFilial("BDX")+"' AND "
cQuery += "BDX_CODOPE = '"+aDadosBDX[1]+"' AND "
cQuery += "BDX_CODLDP = '"+aDadosBDX[2]+"' AND "
cQuery += "BDX_CODPEG = '"+aDadosBDX[3]+"' AND "
cQuery += "BDX_NUMERO = '"+aDadosBDX[4]+"' AND "
cQuery += "BDX_CODPAD = '"+aDadosBDX[5]+"' AND "
cQuery += "BDX_CODPRO = '"+aDadosBDX[6]+"' AND "
cQuery += "BDX_SEQUEN = '"+aDadosBDX[7]+"' AND "
cQuery += "BDX_CODGLO = '"+aDadosBDX[8]+"' AND "
cQuery += "BDX_TIPGLO = '1'  AND "
cQuery += "BDX_REGREC <> 'S' AND "	//Que ainda não tenham sido recuperadas
cQuery += "BDX_ACAO   <> ' '  AND "	//Que tenham sido analisadas, isto é, que tenha ação
cQuery += "BDX_TIPREG <> '3' AND " //Impede que críticas de alerta (que não passam por análise) sejam recuperadas indevidamente
cQuery += "D_E_L_E_T_ = '*' "		//Já deletadas
cQuery += "ORDER BY BDX_CODPRO, R_E_C_N_O_ "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cQuery),"SEEKOLDBDX",.f.,.t.)
  	
if !SEEKOLDBDX->(eof())

	plsTField("SEEKOLDBDX",.f.,{ "BDX_VLRBPR","BDX_VLRBPR" } )

endIf

//Só busca valores deletados com ação diferente de vazio, logo, críticas que foram excluídas no retorno da fase
while !SEEKOLDBDX->(EoF())
	
	BDX->(DbGoTo(SEEKOLDBDX->RECNOBDX))
	
	//Se o valor de contrato do procedimento é o mesmo, continua com a recuperação
	if (aDadosBDX[9] == BDX->BDX_VLRBPR) .or. (BDX->BDX_VLRBPR == 0)
		
		//Recupera as glosas e descritivos anteriores
		if BDX->(Deleted())
		
			BDX->(RecLock("BDX",.F.))
				BDX->(dbRecall())
				BDX->BDX_REGREC := ""
			BDX->(MsUnLock())
			
			nQtdOldBDX++
		endIf
	endIf
		
	SEEKOLDBDX->(DbSkip())
endDo

SEEKOLDBDX->(dbCloseArea())

return nQtdOldBDX

/*/{Protheus.doc} PLGUITOT
Total da Guia
@type function
@author PLSTEAM
@since 06.11.2011
@version 1.0
/*/
function PLGUITOT(cAlias, cChaveGui, aMatTOT, lValTPC, cNextFase, lProcRev, lnewMudFas) 
local aAreaBD6 	  	:= {} 
local cCodOpe     	:= ""
local cTipoGuia  	:= ""
local lFoundBD7		:= .f.

local nQtdPro		:= 0
local nVlrAPR    	:= 0
local nVlrBPR    	:= 0
local nVlrMAN    	:= 0
local nVlrGLO    	:= 0
local nVlrPAG    	:= 0
local nVlTxPG   	:= 0
local nVlrGTX	  	:= 0

local nTVlrBPR    	:= 0
local nTVlrMAN    	:= 0
local nTVlrGLO    	:= 0
local nTVlrPAG    	:= 0
local nTVlTxPG   	:= 0
local nTVlrGTX	  	:= 0

local nVlrBPF		:= 0
local nVlrPF		:= 0
local nVlrTPF		:= 0
local nVlrTAD		:= 0

local nTVlrApr		:= 0
local nTVAprUnt		:= 0
local nTVlrBPF		:= 0
local nTVlrPF		:= 0
local nTVlrTPF		:= 0
local nTVlrTAD		:= 0

local lBD6_VLTXPG 	:= BD6->(fieldPos("BD6_VLTXPG")) > 0
local lBD6_VLRGTX 	:= BD6->(fieldPos("BD6_VLRGTX")) > 0

local lBD7_VLTXPG 	:= BD7->(fieldPos("BD7_VLTXPG")) > 0
local lBD7_VLRGTX 	:= BD7->(fieldPos("BD7_VLRGTX")) > 0
local lBD7_DTCTBF 	:= BD7->(fieldPos("BD7_DTCTBF")) > 0
local lBD7_DTDIGI 	:= BD7->(fieldPos("BD7_DTDIGI")) > 0

default aMatTOT		:= {}
default lValTPC		:= .t.
default cNextFase	:= ''
default lProcRev	:= .t.
default lnewMudFas	:= .F.

if len(aMatTOT) == 0
	
	aAreaBD6 := BD6->(getArea())
	
	BD6->(dbSetOrder(1)) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
	
	if BD6->( MsSeek( xFilial("BD6") + cChaveGui ) )
		
		cTipoGuia := BD6->BD6_TIPGUI
		cCodOpe   := BD6->BD6_CODOPE
		
		while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6") + cChaveGui
			
			nQtdPro	:= BD6->BD6_QTDPRO
			nVlrAPR := 0
			nVlrBPR := 0
			nVlrMAN := 0
			nVlrGLO := 0
			nVlrPAG := 0
			nVlTxPG := 0
			nVlrGTX := 0
			
			nVlrBPF	:= 0
			nVlrTAD	:= 0
			nVlrTPF	:= 0
			nTVlrPF	:= 0
			
			if lValTPC
			
				plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)
				
				lFoundBD7 := ! TRBBD7->(eof())
				
				while ! TRBBD7->(eof())
					
					BD7->( dbGoTo( TRBBD7->REC ) )
					
					nVlrAPR += BD7->BD7_VALORI
					nVlrBPR += BD7->BD7_VLRBPR
					nVlrMAN += BD7->BD7_VLRMAN
					nVlrGLO += BD7->BD7_VLRGLO
					nVlrPAG += BD7->BD7_VLRPAG
					
					if lBD7_VLTXPG
						nVlTxPG += BD7->BD7_VLTXPG
					endIf
					
					if lBD7_VLRGTX
						nVlrGTX += BD7->BD7_VLRGTX
					endIf
					
					//coparticipacao
					if BD6->BD6_BLOCPA != "1" .OR. BD6->BD6_PAGRDA == "1" 
						
						//Para situação em que houve pagamento na RDA, os valores tem que ir mesmo com o bloqueio, para fins de a informação constar
						nVlrBPF += BD7->BD7_VLRBPF
						nVlrTAD += BD7->BD7_VLRTAD
						nVlrTPF += BD7->BD7_VLRTPF
						nVlrPF  += (nVlrTPF - nVlrTAD)
						
					endIf
					
					nRecBD7 := TRBBD7->REC
					
					if ! empty(cNextFase) .and. ! lProcRev
						
						BD7->(recLock("BD7",.f.))
							
							BD7->BD7_FASE 	:= cNextFase
							BD7->BD7_DTANAL := dDataBase	
									
							if lBD7_DTDIGI .and. lBD7_DTCTBF .and. empty(BD7->BD7_DTCTBF)
								BD7->BD7_DTCTBF := iIf(empty(BD7->BD7_LAPRO), BD7->BD7_DTDIGI, date())	
							endIf
							
						BD7->(msUnLock())
						
					endIf	
					
				TRBBD7->(dbSkip())
				endDo
				
				TRBBD7->(dbCloseArea())
				
				if lFoundBD7
					
					//diferenca do bd7 para bd6 por conta do PERCEN devem ser ajustadas no ultimo BD7
					plBD7BD6d(nRecBD7, @nVlrGLO, @nVlrMAN, @nVlrPAG, @nVlTxPG, @nVlrGTX, @nVlrBPF, @nVlrTAD, @nVlrTPF)
					
					//apresentado
					nTVlrAPR	+= nVlrAPR
					nTVAprUnt	+= nVlrAPR / nQtdPro
					
					//pagamento
					nTVlrBPR	+= nVlrBPR
					nTVlrMAN	+= nVlrMAN
					nTVlrGLO	+= nVlrGLO
					nTVlrPAG	+= nVlrPAG
					nTVlTxPG	+= nVlTxPG
					nTVlrGTX	+= nVlrGTX
					
					//coparticipacao
					nTVlrBPF 	+= nVlrBPF
					nTVlrTAD	+= nVlrTAD
					nTVlrTPF	+= nVlrTPF
					nTVlrPF		+= (nVlrTPF - nVlrTAD)
					
				endIf
				
			else
			
				nTVlrAPR  += BD6->BD6_VALORI
				nTVAprUnt += BD6->BD6_VALORI / nQtdPro
				
				nTVlrBPR  += BD6->BD6_VLRBPR
				nTVlrMAN  += BD6->BD6_VLRMAN
				nTVlrGLO  += BD6->BD6_VLRGLO
				nTVlrPAG  += BD6->BD6_VLRPAG
				
				if lBD6_VLTXPG
					nTVlTxPG += BD6->BD6_VLTXPG
				endIf
				
				if lBD7_VLRGTX
					nTVlrGTX += BD6->BD6_VLRGTX
				endIf
				
				//coparticipacao
				if BD6->BD6_BLOCPA != "1"
					
					nTVlrBPF += BD6->BD6_VLRBPF
					nTVlrTAD += BD6->BD6_VLRTAD
					nTVlrTPF += BD6->BD6_VLRTPF
					nTVlrPF  += (nVlrTPF - nVlrTAD)
					
				endIf
					
			endIf
			
			if ! empty(cNextFase) .and. ! lProcRev
				
				BD6->(recLock("BD6",.f.))
					BD6->BD6_FASE 	:= cNextFase
					BD6->BD6_DTANAL := dDataBase	
				BD6->(msUnLock())
				
			endIf	
			
		BD6->(dbSkip())
		endDo
		
	endIf
	BD6->(restArea(aAreaBD6))
	
else

	cTipoGuia 	:= aMatTOT[1]
	cCodOpe   	:= aMatTOT[2]
	
	nTVlrBPR	:= aMatTOT[3]
	nTVlrMAN	:= aMatTOT[4]
	nTVlrGLO 	:= aMatTOT[5]
	nTVlrPAG 	:= aMatTOT[6]
	nTVlrBPF 	:= aMatTOT[7]
	nTVlrPF	 	:= aMatTOT[8]
	nVlrTAD	 	:= aMatTOT[9]
	nTVlrTPF 	:= aMatTOT[10]
	nTVlrAPR 	:= aMatTOT[11]
	nTVAprUnt	:= aMatTOT[12]

endIf

PLCABGTOT(cChaveGui, cTipoGuia) 
If !lnewMudFas
	PLPEGTOT()
EndIF

return

/*/{Protheus.doc} PLCABGTOT
Função responsável por totalizar os valores da guia baseada em query do banco de dados

@author PLSTEAM
@since 10/04/2017
@version P12
/*/
function PLCABGTOT(cChaveGui,cTipoGuia) 
local aAreaZ		:= {}
local aArea     	:= getArea()
local cAlias		:= 'BD5'
local lBD6Valori	:= BD6->(fieldPos("BD6_VALORI")) > 0
local nTamCODOPE	:= BD6->( tamSX3("BD6_CODOPE")[1] )
local nTamCODLDP	:= BD6->( tamSX3("BD6_CODLDP")[1] )
local nTamCODPEG	:= BD6->( tamSX3("BD6_CODPEG")[1] )
local nTamNUMERO	:= BD6->( tamSX3("BD6_NUMERO")[1] )
local nTamORIMOV	:= BD6->( tamSX3("BD6_ORIMOV")[1] )
local cCodOpe		:= subStr(cChaveGui,1,nTamCODOPE)
local cCodLdp		:= subStr(cChaveGui, nTamCODOPE + 1, nTamCODLDP)
local cCodPeg		:= subStr(cChaveGui, nTamCODOPE + nTamCODLDP + 1, nTamCODPEG)
local cNumero		:= subStr(cChaveGui, nTamCODOPE + nTamCODLDP + nTamCODPEG + 1, nTamNUMERO)
local cOriMov		:= subStr(cChaveGui, nTamCODOPE + nTamCODLDP + nTamCODPEG + nTamNUMERO + 1, nTamORIMOV)

if cTipoGuia $ G_ANEX_QUIM + "|" + G_ANEX_RADI + "|" + G_ANEX_OPME + "|" + G_PROR_INTE
	return
endIf

if cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER
	cAlias := 'BE4'
endIf	

cSql := "SELECT BD6.BD6_CODOPE, BD6.BD6_CODLDP, BD6.BD6_CODPEG, BD6.BD6_NUMERO, BD6.BD6_ORIMOV, "
cSql += "       SUM(BD6_VLRPAG) SOMAVLRPAG, SUM(BD6_VLRGLO) SOMAVLRGLO, SUM(BD6_VLRGTX) SOMAVLRGTX ,SUM(BD6_VLRMAN) SOMAVLRMAN, SUM(BD6_VLRBPR) SOMAVLRBPR, "
cSql += "       SUM(BD6_VLTXPG) SOMAVLTXPG, SUM(BD6_VLRPF)  SOMAVLRPF, SUM(BD6_VLRBPF) SOMAVLRBPF, SUM(BD6_VLRTPF) SOMAVLRTPF, "
cSql += "       SUM(BD6_VLRAPR) SOMAVLRAPR, SUM(BD6_VLRTAD) SOMAVLRTAD , SUM(BD6_VLTXAP) SOMAVLTXAP"

if lBD6Valori
	cSql += ", SUM(BD6_VALORI) SOMAVALORI "
endIf

cSql += "  FROM " + retSqlName("BD6") + " BD6 "
cSql += " WHERE BD6.BD6_FILIAL = '" + xFilial("BD6") + "' AND "
cSql += "       BD6.BD6_CODOPE = '" + cCodOpe + "' AND "
cSql += "       BD6.BD6_CODLDP = '" + cCodLdp + "' AND "
cSql += "       BD6.BD6_CODPEG = '" + cCodPeg + "' AND "
cSql += "       BD6.BD6_NUMERO = '" + cNumero + "' AND "
cSql += "       BD6.BD6_ORIMOV = '" + cOriMov + "' AND "
cSql += "       BD6.D_E_L_E_T_  = ' ' "
cSql += " GROUP BY BD6.BD6_CODOPE, BD6.BD6_CODLDP, BD6.BD6_CODPEG, BD6.BD6_NUMERO, BD6.BD6_ORIMOV "

dbUseArea(.t.,"TOPCONN",TCGENQRY(,,csql),"TrbTOTGUI",.f.,.t.)

if ! TrbTOTGUI->(eof())

	aAreaZ := (cAlias)->( getArea() )
	
	(cAlias)->(dbSetOrder(1))
	if (cAlias)->( msSeek( xFilial(cAlias) + cCodOpe + cCodLdp + cCodPeg + cNumero ) )
		
		&(cAlias)->( recLock(cAlias,.f.) )
			
		(cAlias)->&( cAlias + "_VLRBPR" ) := TrbTOTGUI->SOMAVLRBPR
		(cAlias)->&( cAlias + "_VLRMAN" ) := TrbTOTGUI->SOMAVLRMAN
		(cAlias)->&( cAlias + "_VLRGLO" ) := TrbTOTGUI->SOMAVLRGLO + TrbTOTGUI->SOMAVLRGTX
		(cAlias)->&( cAlias + "_VLRPAG" ) := TrbTOTGUI->SOMAVLRPAG
		(cAlias)->&( cAlias + "_VLRAPR" ) := TrbTOTGUI->SOMAVLRAPR + TrbTOTGUI->SOMAVLTXAP
		
		if lBD6Valori
			(cAlias)->&( cAlias + "_VALORI" ) := TrbTOTGUI->SOMAVALORI + TrbTOTGUI->SOMAVLTXAP
		endIf
		
		(cAlias)->&( cAlias + "_VLRBPF" ) := TrbTOTGUI->SOMAVLRBPF
		(cAlias)->&( cAlias + "_VLRTPF" ) := TrbTOTGUI->SOMAVLRTPF
		(cAlias)->&( cAlias + "_VLRPF" )  := TrbTOTGUI->SOMAVLRPF
		(cAlias)->&( cAlias + "_VLRTAD" ) := TrbTOTGUI->SOMAVLRTAD
		
		&(cAlias)->( msUnLock() )
		
	endif
	
	(cAlias)->( restArea(aAreaZ) )
	
endIf

TrbTOTGUI->(dbCloseArea())		
	
restArea(aArea)

return

/*/{Protheus.doc} PLPEGTOT
Função responsável por totalizar os valores da guia baseada em query do banco de dados
@param		aChave, 	array, 		Dados da chave da guia que será processada. O formato do array deve ser: {cCodOpe,cCodLDP,cCodPeg,cNumero,cOriMov}
@param		cTipoGuia, caracter, 	Tipo da guia em processamento
@param		lGravaCob, boolean, 	Indica se serão gravados dados de cobrança

@author PLSTEAM
@since 10/04/2017
@version P12
/*/
function PLPEGTOT()
local lBCI_VLRAPR := BCI->(fieldPos("BCI_VLRAPR")) > 0
local lBCI_VALORI := BCI->(fieldPos("BCI_VALORI")) > 0

//Query de busca dos valores da BD6 para gravação do cabeçalho (BD5/BE4)
cSql := " SELECT SUM(BD6_VLRPAG) SOMAVLRPAG, "
cSql += "        SUM(BD6_VLRGLO) SOMAVLRGLO, "
cSql += "        SUM(BD6_VLRAPR) SOMAVLRAPR, "
cSql += "        SUM(BD6_VALORI) SOMAAPRTOT, "
cSql += "        SUM(BD6_QTDPRO) SOMAQTDPRO,  "
cSql += "        SUM(BD6_VLRGTX) SOMAVLRGTX,  "
cSql += "        SUM(BD6_VLTXAP) SOMAVLTXAP,  "
cSql += "        COUNT(DISTINCT BD6_NUMERO) SOMAQTDDIG "
cSql += "  FROM " + retSqlName("BD6") + " BD6 "
cSql += " WHERE BD6.BD6_FILIAL = '" + xFilial("BD6") + "' "
cSql += "   AND BD6.BD6_CODOPE = '" + BCI->BCI_CODOPE + "' "
cSql += "   AND BD6.BD6_CODLDP = '" + BCI->BCI_CODLDP + "' "
cSql += "   AND BD6.BD6_CODPEG = '" + BCI->BCI_CODPEG + "' "
cSql += "   AND BD6.BD6_SITUAC <> '2' "
cSql += "   AND BD6.D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbTOTPEG",.f.,.t.)

if ! TrbTOTPEG->(eof())

	BCI->(recLock("BCI",.f.))
		BCI->BCI_VLRGUI := TrbTOTPEG->SOMAVLRPAG
		BCI->BCI_VLRGLO := TrbTOTPEG->SOMAVLRGLO + TrbTOTPEG->SOMAVLRGTX
		
		//apresentado unitario
		if lBCI_VLRAPR
			BCI->BCI_VLRAPR	:= TrbTOTPEG->SOMAVLRAPR + TrbTOTPEG->SOMAVLTXAP
		endIf
		
		//total apresentado
		if lBCI_VALORI
			BCI->BCI_VALORI	:= TrbTOTPEG->SOMAAPRTOT + TrbTOTPEG->SOMAVLTXAP
		endIf
			
		BCI->BCI_QTDEVE	:= TrbTOTPEG->SOMAQTDPRO
		BCI->BCI_QTDDIG	:= TrbTOTPEG->SOMAQTDDIG
	BCI->(msUnLock())
	
endIf

TrbTOTPEG->(dbCloseArea())

return

/*/{Protheus.doc} pBD7BD6DIF
Verifica a diferenca entre bd7 e bd6
@type function
@author PLSTEAM
@since 05.01.2017
@version 1.0
/*/
static function plBD7BD6d(nRecBD7, nVlrGLO, nVlrMAN, nVlrPAG, nVlTxPG, nVlrGTX, nVlrBPF, nVlrTAD, nVlrTPF)
local lBD6_VLTXPG 	:= BD6->(fieldPos("BD6_VLTXPG")) > 0
local lBD6_VLRGTX 	:= BD6->(fieldPos("BD6_VLRGTX")) > 0
local lBD7_VLTXPG 	:= BD7->(fieldPos("BD7_VLTXPG")) > 0
local lBD7_VLRGTX 	:= BD7->(fieldPos("BD7_VLRGTX")) > 0
local aArea			:= BD7->(getArea())

if nVlrGLO <> BD6->BD6_VLRGLO .or. nVlrMAN <> BD6->BD6_VLRMAN .or. nVlrPAG <> BD6->BD6_VLRPAG .or.;
   nVlrBPF <> BD6->BD6_VLRBPF .or. nVlrTAD <> BD6->BD6_VLRTAD .or. nVlrTPF <> BD6->BD6_VLRTPF

    //pagamento         
	nVlrGLO := (BD6->BD6_VLRGLO - nVlrGLO)
	nVlrMAN := (BD6->BD6_VLRMAN - nVlrMAN)
	nVlrPAG := (BD6->BD6_VLRPAG - nVlrPAG)
	
	if lBD6_VLTXPG
		nVlTxPG := (BD6->BD6_VLTXPG - nVlTxPG)
	endIf	

	if lBD6_VLRGTX
		nVlrGTX := (BD6->BD6_VLRGTX - nVlrGTX)
	endIf		

	//coparticipacao 
	nVlrBPF := (BD6->BD6_VLRBPF - nVlrBPF)
	nVlrTAD := (BD6->BD6_VLRTAD - nVlrTAD)
	nVlrTPF := (BD6->BD6_VLRTPF - nVlrTPF)
	
	BD7->(dbGoTo(nRecBD7))
	
	BD7->(recLock("BD7",.f.))
	
		BD7->BD7_VLRGLO += nVlrGLO	
		BD7->BD7_VLRMAN += nVlrMAN
		BD7->BD7_VLRPAG += nVlrPAG
		
		if lBD7_VLTXPG
			BD7->BD7_VLTXPG += nVlTxPG
		endIf	
		
		if lBD7_VLRGTX
			BD7->BD7_VLRGTX += nVlrGTX
		endIf
		
		BD7->BD7_VLRBPF	+= nVlrBPF
		BD7->BD7_VLRTAD	+= nVlrTAD
		BD7->BD7_VLRTPF	+= nVlrTPF
		
	BD7->(msUnLock())
	
endIf

BD7->(restArea(aArea))

return

/*/{Protheus.doc} retIntDAD
retorna dados sobre regime de internacao
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function retIntDAD(cTipoGuia,aDadUsr)
local aArea   	 := getArea()
local xRetInt 	 := {}
local cRegAte 	 := '1' 
local cRegInt 	 := ''
local cPadInt 	 := ''
local cPadCon 	 := ''
local cTipAte 	 := ''
local cFinAte 	 := ''
 
if ! ( cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER + "|" + G_HONORARIO + "|" + G_CONSULTA  )
	
	if empty( (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_GUIINT" ) )
		
		if aDadUsr[1]
			xRetInt := PLSUSRINTE(aDadUsr[2],(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_DATPRO" ), (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_HORPRO" ),.t.,.f.,BCL->BCL_ALIAS)
		endIf
		
		(BCL->BCL_ALIAS)->( recLock(BCL->BCL_ALIAS,.f.) )
		
		if valType(xRetInt) == "A" .and. len(xRetInt) > 0 .and. xRetInt[1] 
		
			(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_REGATE" ) := "1"
			(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_GUIINT" ) := xRetInt[2] + xRetInt[3] + xRetInt[4] + xRetInt[5]
			(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_GUIPRI" ) := xRetInt[7]
			
		elseIf valType(xRetInt) != "A" .and. xRetInt
			
			(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_REGATE" ) := '1'
				
		else
		
			(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_REGATE" ) := '2'	
			(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_GUIINT" ) := ''
				
		endIf
		
		(BCL->BCL_ALIAS)->(msUnLock())
		
	else
	
		(BCL->BCL_ALIAS)->(recLock(BCL->BCL_ALIAS,.f.))
			(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_REGATE" ) := "1"
		(BCL->BCL_ALIAS)->(msUnLock())
			
	endIf
	
elseIf ( cTipoGuia == G_HONORARIO )

	if empty( (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_REGATE" ) )
		
		(BCL->BCL_ALIAS)->(recLock(BCL->BCL_ALIAS,.f.))
		
			(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_REGATE") := "1"
			
		(BCL->BCL_ALIAS)->(msUnLock())
		
	endIf
		
//Guia de Consulta sempre será Ambulatorial		
elseIf ( cTipoGuia == G_CONSULTA )	
	(BCL->BCL_ALIAS)->(recLock(BCL->BCL_ALIAS,.f.))
		(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_REGATE") := "2"	
	(BCL->BCL_ALIAS)->(msUnLock())		
		
endIf

if (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_REGATE" ) ) > 0
	cRegAte := (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_REGATE" )
endIf

if (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_REGINT" ) ) > 0	
	cRegInt := (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_REGINT" )
endIf	

if (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_PADINT" ) ) > 0	
	cPadInt := (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_PADINT" )
endIf

if (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_PADCON" ) ) > 0	
	cPadCon := (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_PADCON" )
endIf

if (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_TIPATE" ) ) > 0	
	cTipAte := (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_TIPATE" )
endIf

if (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_TIPPAC" ) ) > 0	
	cFinAte := (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_TIPPAC" )
endIf

restArea(aArea)

return( { cRegAte, cRegInt, cPadInt, cPadCon, cTipAte, cFinAte } )		

/*/{Protheus.doc} PLBD6GRV
executa gravacao complementar na PLSA720GRV
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function PLBD6GRV(cAlias, nOpc, cTipoGuia, nPrTxPag, nPerInss, lAltUsr, cMatrCNova, cCodPla, cCodBlo, cDesBlo, cOpeOri, aDadUsr,;
				  cStatus, cCodPad, cCodPro, nQtdPro, cDente, cDesDen, cFace, cDesFac, nVlrApr, nCaseAlt)
local nFor			:= 0				  
local aCodTab 		:= {}
local aStrucTAB 	:= {}
local cHorCir 		:= ""
local dDatAna		:= stod("")
local cTipAdm 		:= ""
local cUrgEmer     	:= getNewPar("MV_PLSCDIU","4,5")
local lHorEspec 	:= getNewPar("MV_PLSHESP",.f.) 
local cCodAti 		:= ""
local cCodRda 		:= ""
local cCodLoc 		:= ""
local cCodInt 		:= ""
local cCodTab 		:= ""
local cHorFim		:= ""
local lFlag 		:= .t.
local nPerHE		:= 0

local lBD6_PEINPT	:= BD6->(fieldPos("BD6_PEINPT")) > 0
local lBD6_PRTXPG	:= BD6->(fieldPos("BD6_PRTXPG")) > 0
local lBD6_VLINPT	:= BD6->(fieldPos("BD6_VLINPT")) > 0
local lBD6_TPEVCT   := BD6->(fieldPos("BD6_TPEVCT")) > 0
local lBD6_VLTXAP 	:= BD6->(fieldPos("BD6_VLTXAP")) > 0 

default cStatus 	:= ""
default cCodPad 	:= ""
default cCodPro 	:= ""
default nQtdPro 	:= ""
default cDente 		:= ""
default cDesDen 	:= ""
default cFace 		:= ""
default cDesFac 	:= ""
default cMatrCNova 	:= ""
default cCodPla		:= ""
default cCodBlo		:= ''
default cDesBlo		:= ''
default cOpeOri		:= ''
default aDadUsr		:= PLSGETUSR()
default nVlrApr 	:= 0
default nCaseAlt	:= 0

do case 

	//alteracao completa do evento
	case nCaseAlt == 0

		if empty( cCodPad + cCodPro ) 
			cCodPad := BD6->BD6_CODPAD
			cCodPro := BD6->BD6_CODPRO
		endIf

		BR8->( msSeek( xFilial("BR8") + cCodPad + cCodPro ) )

		aCodTab := PLSRETTAB(	BD6->BD6_CODPAD,BD6->BD6_CODPRO,iIf(empty(BD6->BD6_DATPRO),(cAlias)->&( cAlias + "_DATPRO" ),BD6->BD6_DATPRO),;
								BD6->BD6_CODOPE,(cAlias)->&( cAlias + "_CODRDA" ),(cAlias)->&( cAlias + "_CODESP" ),"",(cAlias)->&( cAlias + "_CODLOC" ),;
								iIf(empty(BD6->BD6_DATPRO),(cAlias)->&( cAlias + "_DATPRO"),BD6->BD6_DATPRO),"1",BD6->BD6_OPEORI,cCodpla,"1","1",;
								nil,iIf( !empty(BAU->BAU_TIPPRE), BAU->BAU_TIPPRE, nil),nil,nil,(BD6->BD6_TIPGUI == G_REEMBOLSO))

		BD6->( recLock("BD6",.f.) )

		//campos comun do cabecalho no item
		PLESPACP(cAlias, 'BD6', .t.)

		aCpoNiv := PLSUpCpoNv(cCodPad,cCodPro,"BD6")

		//ver isso
		for nFor := 1 To len(aCpoNiv)
			&(aCpoNiv[nFor,1]) := (aCpoNiv[nFor,2])
		next

		if lAltUsr .and. ! empty(BD6->BD6_MATCOB)
			BD6->BD6_MATCOB := cMatrCNova
		endIf

		if aCodTab[1]
			BD6->BD6_CODTAB := aCodTab[3]
			BD6->BD6_ALIATB := aCodTab[4]
		endIf

		if empty(BD6->BD6_DATPRO)	
			cHorCir := (cAlias)->&(cAlias + "_HORPRO")
			dDatAna	:= (cAlias)->&(cAlias + "_DATPRO")
		else	
			cHorCir := BD6->BD6_HORPRO
			cHorFim := BD6->BD6_HORFIM
			dDatAna	:= BD6->BD6_DATPRO
		endIf

		cTipAdm := (cAlias)->&(cAlias + "_TIPADM") 

		lHorEspec := getNewPar("MV_PLSHESP",.f.) //conceito para pagar horario especial so para urgencia e emergencia

		BY5->(dbSetOrder(1)) //BY5_FILIAL, BY5_CODIGO, BY5_CODINT, BY5_CODHON, BY5_CODATI
		BF8->(dbSetOrder(1)) //BF8_FILIAL, BF8_CODINT, BF8_CODIGO
		BAS->(dbSetOrder(2))

		cCodAti := getNewPar("MV_PLSGHEP","001")

		cCodRda := (cAlias)->&(cAlias + "_CODRDA")
		cCodLoc := (cAlias)->&(cAlias + "_CODLOC")
		cCodInt := (cAlias)->&(cAlias + "_CODOPE")

		cCodTab := BD6->BD6_CODTAB

		lFlag := .t.
		if lHorEspec

			lFlag := .f.
			if allTrim(cTipAdm) $ allTrim(cUrgEmer)
				lFlag := .t.
			endIf

		endIf

		if lFlag .and. BY5->( msSeek( xFilial("BY5") + cCodRda + cCodInt + cCodTab))

			while BY5->BY5_CODIGO ==  cCodRda .and. BY5->BY5_CODINT == cCodInt .and. allTrim(BY5->BY5_CODHON) == allTrim(cCodTab)

				if  ( (dtos(dDatAna) >= dtos( BY5->BY5_VIGINI )) .or. empty( BY5->BY5_VIGINI )) .and. ( (dtos(dDatAna) <= dtos( BY5->BY5_VIGFIN )) .Or. empty( BY5->BY5_VIGFIN ))
					cCodAti	:= BY5->BY5_CODATI
					nPerHE	:= PLCALHE(cCodAti, dDatAna, cHorCir, cCodRda, cCodLoc,cHorFim)
					exit
				endIf
				
			BY5->(dbSkip())
			endDo
				
		elseIf lFlag .and. BF8->( msSeek( xFilial("BF8") + cCodInt + cCodTab ) ) .and. ! empty(BF8->BF8_CODATI)

			cCodAti	:= BF8->BF8_CODATI
			nPerHE	:= PLCALHE(cCodAti, dDatAna, cHorCir, cCodRda, cCodLoc,cHorFim)

		elseIf lFlag .and. BAS->( msSeek( xFilial("BAS") + cCodAti ) )

			nPerHE := PLCALHE(cCodAti, dDatAna, cHorCir, cCodRda, cCodLoc,cHorFim)

		else

			nPerHE := 0

		endIf

		if existBlock("PLSHRESP")
			nPerHE := execBlock("PLSHRESP",.f.,.f.,{ nPerHE,dDatAna,cHorCir,cCodTab,.f.,.f.,cCodPad,cCodPro,.f.} )
		endIf

		//Caso haja incidencia de H.E. registra a % no campo.
		BD6->BD6_PERHES := nPerHE

		if empty(BD6->BD6_VALORI)
			If BD6->BD6_TIPGUI <> "10"
				BD6->BD6_VALORI := BD6->BD6_VLRAPR * BD6->BD6_QTDPRO
			else
				BD6->BD6_VALORI := BD6->BD6_VLRAPR
			endIf
		endif

		if empty(BD6->BD6_LIBERA) 
			BD6->BD6_LIBERA := '0' 
		endIf

		if BD6->BD6_LIBERA == '1'
			BD6->BD6_SALDO := BD6->BD6_QTDPRO
		endIf
			
		BD6->BD6_MODCOB := iIf( len(aDadUsr) >= 48, aDadUsr[48], "")
		BD6->BD6_TIPUSR := iIf( len(aDadUsr) >= 90, aDadUsr[90], "")
		BD6->BD6_INTERC := iIf( len(aDadUsr) >= 91, aDadUsr[91], "0")
		BD6->BD6_TIPINT := iIf( len(aDadUsr) >= 43, aDadUsr[43], "")
		BD6->BD6_DESLOC := BD1->(posicione("BD1",1,xFilial("BD1") + BD6->(BD6_CODOPE + BD6_CODLOC) ,"BD1_DESLOC"))

		BD6->BD6_CODPLA := cCodPla
		BD6->BD6_OPEORI := cOpeOri

		//Nao Autorizado bloqueia o pagamento e a cobrança
		if ( BD6->BD6_STATUS <> '1' .and. ! empty(cCodBlo) )
			PLBLOPC('BD6', .t. , cCodBlo, cDesBlo)
		endIf	

		//se deu critica 057 de usuario genérico e eu já troquei o usuario, tem que limpar a critica
		if lAltUsr 
			
			if BD6->(FieldPos("BD6_MATCOB")) > 0 .And. ! Empty(BD6->BD6_MATCOB)
				
				BD6->BD6_MATCOB := cMatrCNova
				
				PLBLOPC('BD6', .f., __aCdCri091[1], nil, .t., .t., .f.)
				
			endIf
			
		endIf

		//tipo de servico
		if lBD6_TPEVCT
			BD6->BD6_TPEVCT := plTpServ(BD6->BD6_CODPAD, BD6->BD6_CODPRO, BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG), cAlias)
		endIf

		if lBD6_PRTXPG
			BD6->BD6_PRTXPG := nPrTxPag
		endIf

		if lBD6_PEINPT
			BD6->BD6_PEINPT := nPerInss
		endIf

		if empty(BD6->BD6_SEQIMP)
			
			if lBD6_VLTXAP
				BD6->BD6_VLTXAP := ( BD6->BD6_VALORI * nPrTxPag ) / 100
			endIf	

			if lBD6_VLINPT
			
				BD6->BD6_VLINPT := 0
			
				if nPerInss > 0 .and. BD6->BD6_VALORI > 0
					BD6->BD6_VLINPT := ( (BD6->BD6_VALORI + BD6->BD6_VLTXAP) * nPerInss) / 100
				endIf
					
			endIf
			
		endIf

		BD6->(msUnLock())

	//alteracao do valor apresentado 
	case nCaseAlt == 1	
		
		BD6->(recLock("BD6",.f.))

			BD6->BD6_VLRAPR := nVlrApr
			BD6->BD6_VALORI := ( BD6->BD6_VLRAPR * nQtdPro )

			if lBD6_VLTXAP
				BD6->BD6_VLTXAP := ( BD6->BD6_VALORI * nPrTxPag ) / 100
			endIf	

			if lBD6_VLINPT
			
				BD6->BD6_VLINPT := 0
			
				if nPerInss > 0 .and. BD6->BD6_VALORI > 0
					BD6->BD6_VLINPT := ( (BD6->BD6_VALORI + BD6->BD6_VLTXAP) * nPerInss) / 100
				endIf
					
			endIf

		BD6->(msUnLock())

endCase

return

/*/{Protheus.doc} PLBD7GRV
executa gravacao complementar na PLSA720GRV
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function PLBD7GRV(cAlias, nOpc, cTipoGuia, nPrTxPag, nPerInss, cCodpla, aMatCom, aPartic, lEvetAlterado, lAltUsr)
local nI			:= 0
local aMatTOTBD7	:= {}
local lHonor		:= len(aPartic) > 0
local lFoundBD7		:= .f.

local lBD7_PEINPT	:= BD7->(fieldPos("BD7_PEINPT")) > 0
local lBD7_VLINPT	:= BD7->(fieldPos("BD7_VLINPT")) > 0
local lBD7_DTDIGI   := BD7->(fieldPos("BD7_DTDIGI")) > 0

local lBD6_VLINPT	:= BD6->(fieldPos("BD6_VLINPT")) > 0
local lBD6_TPEVCT   := BD6->(fieldPos("BD6_TPEVCT")) > 0

default lEvetAlterado := .f.
default lAltUsr		  := .f.

BD7->( dbSetOrder(1) )
lFoundBD7 := BD7->( msSeek( xFilial("BD7") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + &( cAlias + "->" + cAlias + "_NUMERO" ) + &( cAlias + "->" + cAlias + "_ORIMOV" ) + BD6->BD6_SEQUEN) )

if nOpc == K_Incluir .and. ! lFoundBD7

	PLS720IBD7(BD6->BD6_PACOTE,BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
			   BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",;
			   BD6->BD6_SEQUEN,BD6->BD6_ORIMOV,BCL->BCL_TIPGUI,BD6->BD6_DATPRO,nil,nil,{},nil,nil,nil,cCodpla,aMatCom,aPartic,,lHonor)
			   
else

	if lFoundBD7
	
		plTRBBD7("TRBBD7", BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, &( cAlias + "->" + cAlias + "_NUMERO" ), &( cAlias + "->" + cAlias + "_ORIMOV" ), BD6->BD6_SEQUEN)

		while ! TRBBD7->(eof())
				
			BD7->( dbGoTo( TRBBD7->REC ) )
		
			BD7->(recLock("BD7",.f.))
	
			//campos comun do cabecalho no item
			PLESPACP('BD6', 'BD7')
			
			//se deu critica 057 de usuario genérico e eu já troquei o usuario, tem que limpar a critica
			if lAltUsr 
				PLBLOPC('BD7', .f., __aCdCri091[1])
			endIf
			
			if empty(BD7->BD7_DESESP)
				BD7->BD7_DESESP := BAQ->( posicione("BAQ",1, xFilial("BAQ") + BD7->(BD7_CODOPE+BD7_CODESP),"BAQ_DESCRI") )
			endIf
			
			if empty( BD7->BD7_LOCATE )
				BD7->BD7_LOCATE := BD6->(BD6_CODLOC+BD6_LOCAL)
			endIf
			
			if ! empty(BD6->BD6_DESBPG)
				BD7->BD7_DESBLO := BD6->BD6_DESBPG
			endIf	

			BD7->BD7_PRTXPG := nPrTxPag
	
			if lBD7_PEINPT
				BD7->BD7_PEINPT := nPerInss
			endIf
	
			if BD7->BD7_PERCEN > 0 
	
				if empty(BD6->BD6_SEQIMP)

					BD7->BD7_VALORI := ( BD6->BD6_VALORI * BD7->BD7_PERCEN ) / 100
					BD7->BD7_VLTXAP := ( BD7->BD7_VALORI * BD7->BD7_PRTXPG ) / 100

					BD7->BD7_VLRAPR := ( BD7->BD7_VALORI / BD6->BD6_QTDPRO )
					
				endIf
				
				if lBD7_VLINPT .and. lBD6_VLINPT
					BD7->BD7_VLINPT := ( ( BD7->BD7_VALORI + BD7->BD7_VLTXAP ) * BD7->BD7_PEINPT ) / 100
				endIf
					
			endIf	
			
			BD7->(msUnLock())
	
			//guarda total do bd7 para posterior conferencia
			if BD7->BD7_PERCEN > 0
				getTotBD7(aMatTOTBD7)
			endIf
			
		TRBBD7->(dbSkip())
		endDo
		
		TRBBD7->(dbCloseArea())
		
	endIf
	
endIf

//verifica se o total do BD7 esta igual ao BD6 e ajusta
if len(aMatTOTBD7) > 0
	setAjuGUI(aMatTOTBD7)
endIf

if existBlock("P720GRVG")
	execBlock("P720GRVG",.f.,.f.,{xFilial("BD7")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI->BCI_CODPEG+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")),nOpc,'2'})//de onde foi chamado o pto de entrada
endIf

return			

/*/{Protheus.doc} PLESPACP
espelha campos comuns do cabecalho no item
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function PLESPACP(cAliasCab, cAliasIte, lCab)
local nI			:= 0
local cFieldCab		:= ""
local cFieldIte		:= ""
local aStrucTAB 	:= (cAliasCab)->(dbStruct())
local cCmpNotVld 	:= cAliasIte + '_FILIAL, ' + cAliasIte + '_VIA   , ' + cAliasIte + '_PERVIA, '
Local cCmpNotEpy	:= ""
local xType			:= ""

default lCab := .f.

cCmpNotVld += PlRCpoNG(cAliasIte,lCab)

if cAliasIte == "BD7"
	cCmpNotEpy := "BD7_SIGLA"
endif

for nI := 1 to len(aStrucTAB)
	
	cFieldCab	:= aStrucTAB[nI,1]
	cFieldIte 	:= strTran(cFieldCab,cAliasCab,cAliasIte)
	xType		:= iIf( (cAliasIte)->(fieldPos(cFieldIte)) > 0 , valType((cAliasIte)->&(cFieldIte)), "")
	
	if !empty(xType) .and. xType == valType((cAliasCab)->&(cFieldCab)) .and. ( !( allTrim(cFieldIte) $ cCmpNotVld ) .or. ( xType <> 'N' .and. empty( (cAliasIte)->&(cFieldIte) ) ) ) ;
		.AND. ( !(cFieldIte $ cCmpNotEpy) .OR. (cFieldIte $ cCmpNotEpy .AND. empty( (cAliasIte)->&(cFieldIte) ) ) )
	
		(cAliasIte)->&(cFieldIte) := (cAliasCab)->&(cFieldCab)
		
	endIf
	
next

return

/*/{Protheus.doc} PlRCpoNG
Retorna os campos que nao devem ser gravados (REPLICADOS DE UMA TABELA PARA OUTRA)
@type function
@author PLSTEAM
@since 29.04.06
@version 1.0
/*/
function PlRCpoNG(cAlias,lCab)
local cRet := ""

default lCab := .f.

cRet := " _SENHA, _NOMEDI, _RDAEDI, _NRAOPE, _NRAEMP, _BLOPAG, _MOTBPG, _DESBPG, "
cRet += " _VLRAPR ,_VALOR, _VLRBPR, _VLRMAN, _VLRGLO, _VLRPAG, _VLRBPF, "
cRet += " _VLRTPF, _VLRPF, _VLRPAC, _VLRTAD, _VLRAPR, _VALORI, _VLTXAP, _VLINPT "

if lCab
	cRet += " ,_TIPINT, _TIPUSR, _INTERC "
endIf

if cAlias == 'BD7'
	if lMV_PLSUNI
		cRet += " ,_CODESP"
	endif
	cRet += " , _CODRDA, _REGPRE, _NOMRDA, _LOCATE, _CODLOC, _LOCAL, _DESLOC "
elseIf cAlias == 'BD6'
	cRet += " _GUIORI, _HORPRO, _DATPRO "
endIf

cRet := strTran(cRet, "_", cAlias + "_")

return cRet

/*/{Protheus.doc} PLS63DUP
retona duplicidade conforme usuario, data e hora da guia
@type function
@author PLSTEAM
@since 30.08.17
@version 1.0
/*/
function PLS63DUP(aCri, clocalExec, cCodOpe, cCodLdp, cCodPeg, cNumero, cCodRda)
local cSql 			:= ""
local cChave		:= ""
local cNameBD6 		:= BD6->(retSqlName('BD6'))
local cNameBD7 		:= BD7->(retSqlName('BD7'))
local cNameBR8		:= BR8->(retSqlName('BR8'))
local cCLNotIN  	:= "'" + PLSRETLDP(9) + "','" + PLSRETLDP(4) + "'" 
local cMV_PLSGCOM 	:= getNewPar('MV_PLSGCOM', "")
local lMV_PLSMDIT 	:= getNewPar('MV_PLSMDIT', .f.)
local cAUX			:= getNewPar("MV_PLSCAUX","AUX")
local lCrit063 	  	:= .t.
local nQtdUnm       := 0
local aUnmExc       := {}
local nQtdExc       := 0
local nValGlosa     := 0
if PLSPOSGLO(cCodOpe, __aCdCri099[1], __aCdCri099[2], clocalExec) 

	// Criado PE para possibilitar a customização da critica 063 ser ou nao
	// executado em situações de clientes especificos
	// Ex.: Cliente tem uma situação que uma sessão tem critica de periodicidade
	// que informa que pode ser executado apenas 2 x por dia, porém a critica 063
	// impede a utilização nesse formato
	if existBlock("PLS72063")
		lCrit063 := execBlock("PLS72063",.f.,.f.,{cCodOpe, cCodLdp, cCodPeg, cNumero, cCodRda})
	endIf
	
	if lCrit063
	
	   //Composição guia atual BD7 as BD71
		cSql := " SELECT BD71.R_E_C_N_O_ REC1, BD71.BD7_CODOPE, BD71.BD7_CODLDP, BD71.BD7_CODPEG, "
		cSql += "        BD71.BD7_NUMERO, BD71.BD7_ORIMOV, BD71.BD7_CODPAD, BD71.BD7_CODPRO, BD71.BD7_SEQUEN, "
		cSql += "        BD72.R_E_C_N_O_ REC2, BD61.BD6_SEQUEN, BD61.BD6_DESPRO, BD62.BD6_CODLDP ORILDP, "
		cSql += "        BD62.BD6_CODPEG ORIPEG, BD62.BD6_NUMERO ORINUM, BD72.BD7_CODUNM, "
		cSql += "        BD72.BD7_VLRPAG ORIVLRPAG, BD72.BD7_CODRDA ORIRDA, "
		cSql += "        BD72.BD7_LOCATE ORILOCATE, BD72.BD7_CODESP ORICODESP, " 
		cSql += "        BD71.BD7_VLRPAG ATUVLRPAG  " 
		cSql += "   FROM " + cNameBD7 + " BD71 "
		
		//Procedimentos guia atual BD6 as BD61
		cSql += " INNER JOIN " + cNameBD6 + " BD61 "
		cSql += "        ON BD61.BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += "       AND BD61.BD6_CODOPE = BD71.BD7_CODOPE "
		cSql += "       AND BD61.BD6_CODLDP = BD71.BD7_CODLDP "
		cSql += "       AND BD61.BD6_CODPEG = BD71.BD7_CODPEG "
		cSql += "       AND BD61.BD6_NUMERO = BD71.BD7_NUMERO "
		cSql += "       AND BD61.BD6_ORIMOV = BD71.BD7_ORIMOV "
		cSql += "       AND BD61.BD6_SEQUEN = BD71.BD7_SEQUEN "
		cSql += "       AND BD61.BD6_CODPAD = BD71.BD7_CODPAD "
		cSql += "       AND BD61.BD6_CODPRO = BD71.BD7_CODPRO "
		cSql += "       AND BD61.D_E_L_E_T_ = ' ' "	
		
		if ! empty(cMV_PLSGCOM) .and. ! lMV_PLSMDIT
		
			cSql += " INNER JOIN " + cNameBR8 + " BR8 "
			cSql += "        ON BR8.BR8_FILIAL  = '" + xFilial("BR8") + "' "
			cSql += "       AND BR8.BR8_CODPAD  = BD61.BD6_CODPAD "
			cSql += "       AND BR8.BR8_CODPSA  = BD61.BD6_CODPRO "
			cSql += "       AND BR8.BR8_TPPROC NOT IN ('" + strTran( allTrim(cMV_PLSGCOM),",","','")  + "') "
			cSql += "       AND BR8.D_E_L_E_T_ = ' ' "	
			
		endIf
		
		//Composição guia original BD7 as BD72
		cSql += " INNER JOIN " + cNameBD7 + " BD72 "
		cSql += "        ON BD72.BD7_FILIAL = '" + xFilial("BD7") + "' "
		cSql += "       AND BD72.BD7_OPEUSR = BD71.BD7_OPEUSR "
		cSql += "       AND BD72.BD7_CODEMP = BD71.BD7_CODEMP "
		cSql += "       AND BD72.BD7_MATRIC = BD71.BD7_MATRIC "
		cSql += "       AND BD72.BD7_TIPREG = BD71.BD7_TIPREG "
		cSql += "       AND BD72.BD7_CODPAD = BD71.BD7_CODPAD "
		cSql += "       AND BD72.BD7_CODPRO = BD71.BD7_CODPRO "
		cSql += "       AND BD72.R_E_C_N_O_ <> BD71.R_E_C_N_O_ "
		cSql += "       AND BD72.BD7_BLOPAG <> '1' "
		cSql += "       AND BD72.BD7_CODLDP NOT IN (" + cCLNotIN + ") "
		cSql += "       AND BD72.BD7_CODESP = BD71.BD7_CODESP "
		cSql += "       AND ( (BD72.BD7_CODUNM = '" + cAUX + "' AND BD72.BD7_CODTPA = BD71.BD7_CODTPA) OR "
		cSql += "              (BD72.BD7_CODUNM = BD71.BD7_CODUNM ) ) "	
		cSql += "       AND BD72.BD7_NLANC  = BD71.BD7_NLANC "
		cSql += "       AND BD72.D_E_L_E_T_ = ' ' "			
		
		//Procedimentos guia original BD6 as BD62
		cSql += " INNER JOIN " + cNameBD6 + " BD62 "
		cSql += "        ON BD62.BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += "       AND BD62.BD6_CODOPE = BD72.BD7_CODOPE "
		cSql += "       AND BD62.BD6_CODLDP = BD72.BD7_CODLDP "
		cSql += "       AND BD62.BD6_CODPEG = BD72.BD7_CODPEG "
		cSql += "       AND BD62.BD6_NUMERO = BD72.BD7_NUMERO "
		cSql += "       AND BD62.BD6_ORIMOV = BD72.BD7_ORIMOV "
		cSql += "       AND BD62.BD6_SEQUEN = BD72.BD7_SEQUEN "
		cSql += "       AND BD62.BD6_CODPAD = BD72.BD7_CODPAD "
		cSql += "       AND BD62.BD6_CODPRO = BD72.BD7_CODPRO "

		cSql += "       AND ( ( BD62.BD6_FASE IN ('3','4') "
		cSql += "       AND ( (  BD62.BD6_NUMERO <> BD71.BD7_NUMERO   AND "
		cSql += "                BD62.BD6_CODPEG = BD71.BD7_CODPEG )  OR  "
		cSql += "                ( BD62.BD6_NUMERO = BD71.BD7_NUMERO  AND "
		cSql += "                BD62.BD6_CODPEG <> BD71.BD7_CODPEG ) OR  " 
		cSql += "                ( BD62.BD6_NUMERO <> BD71.BD7_NUMERO AND " 
		cSql += "                BD62.BD6_CODPEG <> BD71.BD7_CODPEG ) ) ) "
		cSql += "       OR ( ( BD62.BD6_NUMERO = BD71.BD7_NUMERO AND      " 
		cSql += "                BD62.BD6_CODPEG = BD71.BD7_CODPEG ) ) )  "
		
		cSql += "       AND BD62.BD6_SITUAC <> '2' "	
		cSql += "		  AND BD62.BD6_LIBERA <> '1' "		
		cSql += "       AND BD62.D_E_L_E_T_ = ' '  "
		
		cSql += "       AND BD62.BD6_DATPRO = BD61.BD6_DATPRO "
		cSql += "       AND BD62.BD6_HORPRO = BD61.BD6_HORPRO "
		cSql += "       AND BD62.BD6_CODPAD = BD61.BD6_CODPAD "
		cSql += "       AND BD62.BD6_CODPRO = BD61.BD6_CODPRO "
		cSql += "       AND BD62.R_E_C_N_O_ <> BD61.R_E_C_N_O_ "

		cSql += "   WHERE BD71.BD7_FILIAL = '" + xFilial("BD7") + "' "
		cSql += "     AND BD71.BD7_CODOPE = '" + cCodOpe + "' "
		cSql += "     AND BD71.BD7_CODLDP = '" + cCodLdp + "' "
		cSql += "     AND BD71.BD7_CODPEG = '" + cCodPeg + "' "
		cSql += "     AND BD71.BD7_NUMERO = '" + cNumero + "' "
//		cSql += "     AND BD71.BD7_CODRDA = '" + cCodRda + "' "
		cSql += "     AND BD71.D_E_L_E_T_ = ' ' "	
			
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TR063",.f.,.t.)
		
		if !TR063->(eof())

         	//Verificamos a quantidade de registros.
         	//Caso seja apenas 1, e esse item esteja cadastrado na exceção de críticas da RDA da guia original, a crítica não deve ser apresentada.
         	nQtdUnm := Contar("TR063","!EoF()")
            
         	TR063->(DbGoTop())
            
			aCri[1] := .f.
			

			while ! TR063->(eof())
				
				//Se percentual é 0 e valor de pagamento também é 0, não foi paga a unidade.
				//Assim, devemos checar se está cadastrado como exceção da RDA da guia original para evitar críticas indevidas
				if TR063->ORIVLRPAG == 0
				    				    
				    aUnmExc := PLB4REXC(TR063->ORIRDA, TR063->BD7_CODPAD, TR063->BD7_CODPRO, TR063->ORILOCATE, TR063->ORICODESP, TR063->BD7_CODUNM)
				    
				    //Verificamos se a unidade está cadastrada como exceção
				    if len(aUnmExc) > 0 .and. aScan(aUnmExc, {|x| TR063->BD7_CODUNM $ x } ) > 0
				        						        
				        //Incrementa qtd item que não critica				        
				        nQtdExc++
				            
				        //Pula esse registro
                        TR063->(dbSkip())
                    
                        //Itera o while
                        Loop
				    endif
                
                //Caso estiver com valor zerado na guia atual, também não deve entrar na crítica pois foi bloqueado ou entrou em exceção para essa RDA.	    		    
				elseif TR063->ATUVLRPAG == 0
				
				    //Incrementa qtd item que não critica                       
                    nQtdExc++
				    
				    //Pula esse registro
                    TR063->(dbSkip())
                
                    //Itera o while
                    Loop	    
				endif
								
				if cChave <> TR063->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)
					
					cChave := TR063->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN)
					
					aadd(aCri[2],{__aCdCri099[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,TR063->BD7_CODPAD,TR063->BD7_CODPRO,TR063->BD6_SEQUEN,TR063->BD6_DESPRO})
					
				endIf	

				aadd(aCri[2],{""," Unidade [" + TR063->BD7_CODUNM + "] ja informada no protocolo: " + TR063->ORIPEG + " na guia: " + TR063->ORINUM ,"","","", TR063->BD7_CODPAD, TR063->BD7_CODPRO, TR063->BD6_SEQUEN,TR063->BD6_DESPRO})
				

			TR063->(dbSkip())
			endDo
			
			if nQtdExc == nQtdUnm
                aCri[1] := .T.
			endif
			
		endIf
		

		
		TR063->(dbCloseArea())
			
	endIf
	
endIf

return 

/*/{Protheus.doc} plTRBBD7
retorna trb do BD7
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function plTRBBD7(cTRBBD7, cCodOpe, cCodLdp, cCodPeg, cNumero, cOriMov, cSequen, cCodUnm, lBloPag)
local cRet := ""

default cCodPeg := "" 
default cCodLdp	:= ""
default cCodPeg := ""
default cNumero := ""
default cOriMov := ""
default cSequen := ""
default cCodUnm := ""
default lBloPag	:= .f.			
			
cSql := "SELECT R_E_C_N_O_ REC, BD7_BLOPAG BLOPAG FROM " + retSqlName("BD7")
cSql += " WHERE BD7_FILIAL = '" + xFilial("BD7")  + "' "

if ! empty(cCodOpe)
	cSql += "   AND BD7_CODOPE = '" + cCodOpe + "' "
endIf	

if ! empty(cCodLdp)
	cSql += "   AND BD7_CODLDP = '" + cCodLdp + "' "
endIf

if ! empty(cCodPeg)
	cSql += "   AND BD7_CODPEG = '" + cCodPeg + "' "
endIf
	
if ! empty(cNumero)
	cSql += "   AND BD7_NUMERO = '" + cNumero + "' "
endIf

if ! empty(cOriMov)
	cSql += "   AND BD7_ORIMOV = '" + cOriMov + "' "
endIf

if ! empty(cSequen)
	cSql += "   AND BD7_SEQUEN = '" + cSequen + "' "
endIf

if ! empty(cCodUnm)
	cSql += "   AND BD7_CODUNM = '" + cCodUnm + "' "
endIf

if lBloPag
	cSql += "   AND BD7_BLOPAG = '1' "
	cSql += "   AND BD7_MOTBLO <> ' ' "
endIf
	
cSql += "   AND D_E_L_E_T_ = ' ' "
cSql += " Order By BD7_BLOPAG DESC "
MPSysOpenQuery( csql, cTRBBD7 )

return

/*/{Protheus.doc} PLGQTDAPR
gatilho valor apresentado x qtdpro
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function PLGQTDAPR()
local nRet := M->BD6_QTDPRO * M->BD6_VLRAPR
return(nRet)

/*/{Protheus.doc} plChkBD4
verifica composicao do evento esta na bd4 unidade corrente ou relacionada
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function plChkBD4(cChave, cCodUnd, lVigi, dDatPro)
local aArea		:= BD4->(getArea())
local nI		:= 0
local lFoundBD4 := .f.
local lBD4Vigi	:= .f.
local aRetUnd	:= {}

default lVigi	:= .f. 
default dDatPro	:= ctod("")

BD4->( dbSetOrder(1) )//BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+DTOS(BD4_VIGINI)

lFoundBD4 := BD4->( msSeek( xFilial("BD4") + cChave + cCodUnd ) )

if lVigi .and. lFoundBD4
	
	lBD4Vigi := .f.
	
	while ! BD4->(eof()) .and. BD4->(BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO) == xFilial("BD4") + cChave + cCodUnd
	
		if PLSINTVAL("BD4","BD4_VIGINI","BD4_VIGFIM",dDatPro)
			lBD4Vigi := .t.
			exit
		endIf
		
	BD4->(DbSkip())
	endDo
	
endIf					

BD4->(restArea(aArea))

return( { lFoundBD4, lBD4Vigi } )

/*/{Protheus.doc} PLChkAux
Verifica se e uma unidade AUX
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function PLChkAux(cCodUnm)
local lRet := (cCodUnm $ "AUX|AUR")

if ! lRet
	M->BD7_NLANC := space( tamSX3("BD7_NLANC")[1] )
else
	lRet := empty(M->BD7_CODTPA)		
endIf

return(lRet)

/*/{Protheus.doc} PLBLOPC
Bloqueio e Desbloqueio do BD6 e BD7
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function PLBLOPC(cAlias, lBlo, cCodGlo, cDesGlo, lPg, lCb, lEnvCon, lForca)
local cTp 		:= iIf(lBlo,'1','0')
local lCobBlocked	:= .f.
local lPagBlocked	:= .f.

default cCodGlo	:= ''
default cDesGlo	:= ''
default lPg 	:= .t.
default lCb 	:= .t.
default lEnvCon := nil
default lForca 	:= .f. //Caso já possua um bloqueio esta variavel força substituir o código atual, exemplo OPME

if cAlias == 'BD6'
	
	if lBlo

		lCobBlocked := BD6->BD6_BLOCPA == '1' //Bloqueia pagamento
		lPagBlocked := BD6->BD6_BLOPAG == '1' //Bloqueia cobranca
	
	else
	
		lCobBlocked := BD6->BD6_BLOCPA == '1' .and. ( cCodGlo $ BD6->BD6_MOTBPF .or. empty(cCodGlo) )
		lPagBlocked := BD6->BD6_BLOPAG == '1' .and. ( cCodGlo $ BD6->BD6_MOTBPG .or. empty(cCodGlo) )
	
		if lCobBlocked .or. lPagBlocked
			cCodGlo := ''
			cDesGlo := ''
		endIf	
		
	endIf	 
	//Somente altera se ainda não está bloqueado, para não matar o bloqueio anterior
	if lPg .and. (!lPagBlocked .or. (lPagBlocked .and. (!lBlo .or. lForca)))	
		BD6->BD6_BLOPAG := cTp
		BD6->BD6_MOTBPG := cCodGlo
		BD6->BD6_DESBPG := cDesGlo
	endIf

	//Somente altera se ainda não está bloqueado, para não matar o bloqueio anterior
	if lCb .and. (!lCobBlocked .or. (lCobBlocked .and. (!lBlo .or. lForca)))
		BD6->BD6_BLOCPA := cTp
		BD6->BD6_MOTBPF	:= cCodGlo
		BD6->BD6_DESBPF := cDesGlo
	endIf
	
	if lEnvCon .and. (lPagBlocked .and. lCobBlocked)
	 	lEnvCon := .f.
	endIf	 
	
endIf	

if cAlias == 'BD7'
	
	if lBlo
		lPagBlocked := BD7->BD7_BLOPAG == '1'
	else
		lPagBlocked := BD7->BD7_BLOPAG == '1' .and. ( cCodGlo $ BD7->BD7_MOTBLO .or. empty(cCodGlo) )
	
		if lPagBlocked
			cCodGlo := ''
			cDesGlo := ''
		endIf	
	
	endIf	 
	
	if lPagBlocked .OR. (lBlo .AND. !lPagBlocked)
		BD7->BD7_BLOPAG := cTp
		BD7->BD7_MOTBLO := cCodGlo
		BD7->BD7_DESBLO := cDesGlo
	endIf
	
endIf	

if cAlias == 'BD6' .and. lEnvCon <> nil 
	
	BD6->BD6_ENVCON := iIf(lEnvCon,'1','0')
	
endIf

return

/*/{Protheus.doc} PLB4REXC
Retorna o range de execeções de composição que não seram cobrados.

@since 01/10/2015
@version P12
/*/
function PLB4REXC(cCodRda, cCodPad, cCodPro, cCodLoc, cCodEsp, cCodUnd)
local cSQL 		:= ""
local aUnidSaud	:= {}
local lAchou    := .f.

cSQL := " SELECT B4R_UNIDAD FROM " + retSqlName("B4R")
cSQL += "  WHERE B4R_FILIAL = '" + xFilial('B4R') + "' "
cSQL += "    AND B4R_CODRDA = '" + cCodRDA + "' "
cSQL += "    AND B4R_CPADDE " + cconcateZ + " B4R_CPRODE <= '" + cCodPad + cCodPro + "' "
cSQL += "    AND B4R_PADATE " + cconcateZ + " B4R_PROATE >= '" + cCodPad + cCodPro + "' "
cSQL += "    AND (B4R_CODLOC = '" + cCodLoc + "' OR B4R_CODLOC = ' ') "
cSQL += "    AND (B4R_CODESP = '" + cCodEsp + "' OR B4R_CODESP = ' ') "
cSQL += "    AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",TCGENQRY(,,cSql),"TRB4R",.f.,.t.)

while ! TRB4R->(eof())
	
	aadd(aUnidSaud,allTrim(TRB4R->B4R_UNIDAD))
	
TRB4R->(dbSkip())
endDo

TRB4R->(dbCloseArea())

return(aUnidSaud)

/*/{Protheus.doc} plGloUND
Seta glosa por unidade
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function plGloUND(cCodGlo, cDesGlo, cObs, lCopPag, nPercen, lGlosar, lFoundBD6, lTpapl)
local nVlrGlo 		:= 0  
local nVlrPF  		:= 0
local nVlrBPF		:= 0
local nVlrTad 		:= 0
local nVlrPagOld   	:= 0
local nVlrPagNew   	:= 0
local nValor		:= 0
local cAliasCab 	:= 0
local nRecno		:= 0
local nVlrTx		:= 0
local nVlrGtx		:= 0
local aMatTOTBD7	:= {}
local aRet			:= {}
local lBD6_VLTXPG	:= BD6->(fieldPos("BD6_VLTXPG")) > 0
local lBD6_VLRGTX	:= BD6->(fieldPos("BD6_VLRGTX")) > 0
local lBD6_VLINPT	:= BD6->(fieldPos("BD6_VLINPT")) > 0
local lBD6_GLINPT	:= BD6->(fieldPos("BD6_GLINPT")) > 0

local lBD7_VLTXPG	:= BD7->(fieldPos("BD7_VLTXPG")) > 0
local lBD7_VLRGTX	:= BD7->(fieldPos("BD7_VLRGTX")) > 0
local lBD7_VLINPT	:= BD7->(fieldPos("BD7_VLINPT")) > 0
local lBD7_GLINPT	:= BD7->(fieldPos("BD7_GLINPT")) > 0

default nPercen 	:= 100
default lGlosar		:= .f.
default lFoundBD6 	:= .f.
Default lTpapl	:= .F.

if lGlosar
	
	//posiciono no BD6 para verificar se o prestador ja nao apresentou o valor com reducao	
	if lFoundBD6 .or. BD6->( msSeek( xFilial("BD6") + BD7->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODPAD + BD7_CODPRO) ) )

		nVlrGlo := Round((BD7->BD7_VLRMAN * nPercen) / 100, 2) 
		nRecno	:= BD7->(recno())
			
		BD7->(recLock("BD7",.f.))
		
			BD7->BD7_REDCUS := '1'
		
			BD7->BD7_VLRGLO += nVlrGlo
			BD7->BD7_VLRMAN	-= nVlrGlo
			
			if lBD7_VLTXPG
				
				BD7->BD7_VLTXPG := ( BD7->BD7_VLRMAN * BD7->BD7_PRTXPG ) / 100
				
				aRet 			:= getValTPC(BD7->BD7_VLTXPG, BD7->BD7_VLTXAP, BD7->BD7_TIPGUI == '10', .t.)
				nVlrTx			:= aRet[1]
				nVlrGtx			:= aRet[2]
				
			endIf
				
			if lBD7_VLRGTX

				BD7->BD7_VLRGTX := nVlrGtx
				
			endIf
			
			nVlrPagOld 		:= BD7->BD7_VLRPAG 
			
			BD7->BD7_VLRPAG := BD7->BD7_VLRMAN + nVlrTx

			nVlrPagNew 		:= BD7->BD7_VLRPAG 

			if lBD7_VLINPT .and. lBD7_GLINPT .and. BD7->BD7_PEINPT > 0
				
				BD7->BD7_VLINPT := (BD7->BD7_VLRPAG * BD7->BD7_PEINPT) / 100
				BD7->BD7_GLINPT := ( ( BD7->BD7_VLRGLO + BD7->BD7_VLRGTX ) * BD7->BD7_PEINPT) / 100
				
			endIf	
			
			//coparticipacao
			if lCopPag
			
				nVlrBPF := (BD7->BD7_VLRBPF * nPercen) / 100
				nVlrPF  := (BD7->BD7_VLRTPF * nPercen) / 100
				nVlrTad := (BD7->BD7_VLRTAD * nPercen) / 100
				
				BD7->BD7_VLRBPF	-= nVlrBPF
				BD7->BD7_VLRTPF	-= nVlrPF
				BD7->BD7_VLRTAD	-= nVlrTad
				
			endIf
			
		BD7->(msUnLock())
		
		//atualizo o BD6 de acordo com o BD7
		BD6->(recLock("BD6",.f.))
		
			BD6->BD6_VLRGLO += nVlrGlo
			BD6->BD6_VLRMAN	-= nVlrGlo
	
			if lBD6_VLTXPG
				
				BD6->BD6_VLTXPG := ( BD6->BD6_VLRMAN * BD6->BD6_PRTXPG ) / 100
				
				aRet 			:= getValTPC(BD6->BD6_VLTXPG, BD6->BD6_VLTXAP, BD6->BD6_TIPGUI == '10', .t.)
				nVlrTx			:= aRet[1]
				nVlrGtx			:= aRet[2]
				
			endIf
				
			if lBD6_VLRGTX

				BD6->BD6_VLRGTX := nVlrGtx
					
			endIf	
	
			BD6->BD6_VLRPAG	:= BD6->BD6_VLRMAN + nVlrTx

			if lBD6_VLINPT .and. lBD6_GLINPT

				BD6->BD6_VLINPT := (BD6->BD6_VLRPAG * BD6->BD6_PEINPT) / 100
				BD6->BD6_GLINPT := ( ( BD6->BD6_VLRGLO + BD6->BD6_VLRGTX ) * BD6->BD6_PEINPT) / 100

			endIf	
			
			//coparticipacao
			if lCopPag
			
				BD6->BD6_VLRBPF	-= nVlrBPF
				BD6->BD6_VLRTPF	-= nVlrPF
				BD6->BD6_VLRPF	-= nVlrPF
				BD6->BD6_VLRTAD	-= nVlrTad
				
			endIf
			
		BD6->(msUnLock())
		
		plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)

		while ! TRBBD7->(eof())

			BD7->( dbGoTo( TRBBD7->REC ) )
			
			getTotBD7(aMatTOTBD7)
			
		TRBBD7->(dbSkip())	
		endDo
		
		if len(aMatTOTBD7) > 0	
			aMatTOTBD7[1,2] := nRecno
			setAjuGUI(aMatTOTBD7)
		endIf	
		
		// se houve alguma redução
		if nVlrGlo > 0 
		
			// crio a glosa do valor abatido no item
			BDX->(recLock("BDX",.t.))
				BDX->BDX_FILIAL := xFilial("BDX")
				BDX->BDX_IMGSTA := "BR_AMARELO"
				BDX->BDX_CODOPE := BD6->BD6_CODOPE
				BDX->BDX_CODLDP := BD6->BD6_CODLDP
				BDX->BDX_CODPEG := BD6->BD6_CODPEG
				BDX->BDX_NUMERO := BD6->BD6_NUMERO
				BDX->BDX_NIVEL  := "1"
				BDX->BDX_CODPAD := BD6->BD6_CODPAD
				BDX->BDX_CODPRO := BD6->BD6_CODPRO
				BDX->BDX_DESPRO := iIf( ! empty(BD6->BD6_DESPRO),BD6->BD6_DESPRO,BR8->(Posicione("BR8",1,xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO),"BR8_DESCRI")))
				BDX->BDX_SEQUEN := BD6->BD6_SEQUEN
				BDX->BDX_CODGLO := cCodGlo
				BDX->BDX_GLOSIS := cCodGlo
				BDX->BDX_DESGLO := cDesGlo
				BDX->BDX_INFGLO := ""
				BDX->BDX_TIPGLO := "3"
				BDX->BDX_ORIMOV := BD6->BD6_ORIMOV
				BDX->BDX_RESPAL := cObs
				BDX->BDX_TIPREG := '1' // Principal
				BDX->BDX_VLRPAG := BD6->BD6_VLRPAG
				BDX->BDX_VLRAPR := BD6->BD6_VALORI
				BDX->BDX_VLRMAN := BD6->BD6_VLRMAN
				BDX->BDX_VLRBPR := BD6->BD6_VLRBPR
				BDX->BDX_PERGLO := ( nVlrGlo / ( BD6->BD6_VLRMAN + BD6->BD6_VLRGLO ) ) * 100
				BDX->BDX_VLRGLO := nVlrGlo 
				BDX->BDX_ACAO 	:= '1'
				BDX->BDX_ACAOTX := '1'
		
				if BDX->(fieldPos("BDX_DATPRO")) > 0
					BDX->BDX_DATPRO := BD7->BD7_DATPRO
				endIf
				
			BDX->(msUnLock())
		
		endIf
		
		// Atualizo o cabecalho
		cAliasCab := PlRetAlias(BD6->BD6_CODOPE, BD6->BD6_TIPGUI)	 
		 
		if ! empty(cAliasCab)  
		
			(cAliasCab)->( dbSetOrder(1) )
			(cAliasCab)->( msSeek( xFilial(cAliasCab) + BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) ) )
			
			(cAliasCab)->( recLock(cAliasCab, .f.) )
				
				nValor := (cAliasCab)->&( cAliasCab + '_VLRGLO' )
				nValor += nVlrGlo
				(cAliasCab)->&( cAliasCab + '_VLRGLO' ) := nValor
				
				nValor := (cAliasCab)->&( cAliasCab + '_VLRMAN' )
				nValor -= nVlrGlo
				(cAliasCab)->&( cAliasCab + '_VLRMAN' ) := nValor
				
				nValor := (cAliasCab)->&( cAliasCab + '_VLRPAG' )
				nValor -= nVlrPagOld
				nValor += nVlrPagNew
				(cAliasCab)->&( cAliasCab + '_VLRPAG' ) := nValor
				 
				//coparticipação
				if lCopPag
				
					//valor contratado
					nValor := (cAliasCab)->&( cAliasCab + '_VLRBPF' )
					nValor -= nVlrBPF
					(cAliasCab)->&( cAliasCab + '_VLRBPF' ) := nValor

					//valor total da coparticipacao
					nValor := (cAliasCab)->&( cAliasCab + '_VLRTPF' )
					nValor -= nVlrPF
					(cAliasCab)->&( cAliasCab + '_VLRTPF' ) := nValor

					//valor da coparticipacao
					nValor := (cAliasCab)->&( cAliasCab + '_VLRPF' )
					nValor -= nVlrPF
					(cAliasCab)->&( cAliasCab + '_VLRPF' ) := nValor
	
					//valor da taxa
					nValor := (cAliasCab)->&( cAliasCab + '_VLRTAD' )
					nValor -= nVlrTad
					(cAliasCab)->&( cAliasCab + '_VLRTAD' ) := nValor
				
				endIf
				
			(cAliasCab)->( msUnLock() )
			
		endIf
		
	endIf
	
endIf	

return

/*/{Protheus.doc} plDigPro
coloca o evento e composicao do evento em digitacao ou pronta
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function plDigPro(cNextFase, __cBLODES, lDoppler, lProcRev, lCopPag, lGloAuto, aMatTOTBD7, nVlrPagBru,;
				  lBDX_FOUND, nBDX_VLRGLO, nBDX_VLRMAN, nBDX_VLTXPG, nBDX_VLRPAG, nBDX_VLRGTX, cBDX_ACAO,;
				  nBDX_PERGLO, cBDX_CODGLO, nTotGLMant)
local lModCTX     := getNewPar("MV_PLSMCTA","1") == "1"
local lValBruto	  := getNewPar("MV_PLCTXPG","1") == "1"
local lLmpCpo     := getNewPar("MV_PLLCRFA",.f.)
Local aCompGlo	:= {}
local nVlrAux	  := 0
Local lBloqueado := .F.
Local nTotBlo := 0

local lBD6_VLTXPG := BD6->(fieldPos("BD6_VLTXPG")) > 0
local lBD6_VLRGTX := BD6->(fieldPos("BD6_VLRGTX")) > 0
local lBD6_PEINPT := BD6->(fieldPos("BD6_PEINPT")) > 0
local lBD6_VLINPT := BD6->(fieldPos("BD6_VLINPT")) > 0
local lBD6_GLINPT := BD6->(fieldPos("BD6_GLINPT")) > 0

local lBD7_VLTXPG := BD7->(fieldPos("BD7_VLTXPG")) > 0
local lBD7_VLRGTX := BD7->(fieldPos("BD7_VLRGTX")) > 0
local lBD7_DTCTBF := BD7->(fieldPos("BD7_DTCTBF")) > 0
local lBD7_DTDIGI := BD7->(fieldPos("BD7_DTDIGI")) > 0
local lBD7_VLINPT := BD7->(fieldPos("BD7_VLINPT")) > 0
local lBD7_GLINPT := BD7->(fieldPos("BD7_GLINPT")) > 0
local lBD7_PRTXPG := BD7->(fieldPos("BD7_PRTXPG")) > 0

local lP500RCB 	  := isInCallStack("PLSA500RCB") //Revaloracao Cobramça
local lP500RPG 	  := isInCallStack("PLSA500RPG") //Revaloracao Pagamento
local lP500RCP 	  := isInCallStack("PLSA500RCP") //Revaloracao Cobranca e Pagamento
local lP500ACT 	  := isInCallStack("PLSA500ACT") //Analise de contas

default lGloAuto	:= .f.
default aMatTOTBD7	:= {}
default nVlrPagBru	:= 0
default lProcRev	:= .f.
default lCopPag		:= .f.
default lDoppler	:= .f.
default lBDX_FOUND	:= .f.
default nBDX_VLRGLO	:= 0
default nBDX_VLRMAN	:= 0
default nBDX_VLTXPG	:= 0
default nBDX_VLRPAG	:= 0
default nBDX_VLRGTX	:= 0
default cBDX_ACAO	 	:= "SEM_ACAO"
default nBDX_PERGLO	:= 0
default cBDX_CODGLO	:= ""
default nTotGLMant	:= 0

BD6->(recLock("BD6",.f.))

	BD6->BD6_FASE := cNextFase
	
	if cNextFase == PRONTA 
	
		if ! lProcRev
		
			//Data da mudanca de fase da guia
			BD6->BD6_DTANAL := dDataBase	
			
		endIf
			
		if lBDX_FOUND
					
			if lP500RPG .or. lP500RCP
				
				if cBDX_ACAO <> "SEM_ACAO"

					if cBDX_ACAO == "2" 
						if !(BD6->BD6_PAGRDA == "1" .and. (lP500RPG .or. lP500RCP))
							If BD6->BD6_VLRAPR > 0 //Caso houve valor apresentado no tempo da análise, irá prevalecer o valor da análise
								BD6->BD6_VLRMAN := nBDX_VLRMAN
								BD6->BD6_VLRGLO := 0
							else
								BD6->BD6_VLRGLO := 0
							endIf
						endif
					elseIf cBDX_ACAO == "1" .and. nBDX_PERGLO == 100
						
						BD6->BD6_VLRMAN := 0
						if BD6->BD6_PAGRDA == "1"
							BD6->BD6_VLRGLO += nBDX_VLRGLO
						else
							BD6->BD6_VLRGLO := nBDX_VLRGLO
						endif						

					elseIf cBDX_ACAO == "1" .and. allTrim(cBDX_CODGLO) == __aCdCri049[1]
						
						aCompGlo := getValTPC(BD6->BD6_VLRMAN, BD6->BD6_VALORI)

						BD6->BD6_VLRMAN := aCompGlo[1]
						BD6->BD6_VLRGLO := aCompGlo[2]

					else
						
						nVlrAux			:= getValTPC(BD6->BD6_VLRMAN, BD6->BD6_VALORI)[1]
						aCompGlo 		:= { nVlrAux, ( nVlrAux * nBDX_PERGLO ) / 100 }
						
						if BD6->BD6_PAGRDA == "1"
							BD6->BD6_VLRGLO += aCompGlo[2]
						else
							BD6->BD6_VLRGLO := aCompGlo[2]
						endif
						BD6->BD6_VLRMAN := aCompGlo[1] - aCompGlo[2]

					endIf

				else

					if nBDX_VLRGLO < BD6->BD6_VLRMAN
						BD6->BD6_VLRGLO	:= nBDX_VLRGLO
						BD6->BD6_VLRMAN	-= BD6->BD6_VLRGLO
					else
						BD6->BD6_VLRGLO	:= BD6->BD6_VLRMAN
						BD6->BD6_VLRMAN	:= 0
					endIf

				endIf
			
			else
				
				if (lGloAuto .and. ! getNewPar("MV_PLAGVT", .F.)) .or. BD6->BD6_PAGRDA == "1"
					if !(lP500RCB .and. BD6->BD6_PAGRDA == "1" .and. BD6->BD6_VLRGLO >= BD6->BD6_VRPRDA)
						BD6->BD6_VLRGLO	+= nBDX_VLRGLO
					endif
				else
					BD6->BD6_VLRGLO	:= nBDX_VLRGLO
				endIf				

				BD6->BD6_VLRMAN	:= nBDX_VLRMAN

			endIf
			
			if nTotGLMant > 0

				if (BD6->BD6_VLRMAN - nTotGLMant) < 0
					BD6->BD6_VLRGLO += BD6->BD6_VLRMAN
					BD6->BD6_VLRMAN := 0
				else
					BD6->BD6_VLRGLO += nTotGLMant
					BD6->BD6_VLRMAN -= nTotGLMant
			    endIf
			
			endIf
			
			BD6->BD6_VLTXPG	:= nBDX_VLTXPG 

			//paga pelo contratado ou apresentado
			if getTPCALC(BD6->BD6_CODRDA) $ '2|3' 
				BD6->BD6_VLRPAG	:= BD6->BD6_VLRMAN + BD6->BD6_VLTXPG
			else
				BD6->BD6_VLRPAG	:= BD6->BD6_VLRMAN + getValTPC(BD6->BD6_VLTXPG, BD6->BD6_VLTXAP, BD6->BD6_TIPGUI == '10', .t.,lBDX_FOUND)[1]
			endIf
			
			if lBD6_VLRGTX
				
				if lGloAuto .and. ! lP500ACT
			   		BD6->BD6_VLRGTX	+= nBDX_VLRGTX
			   	else
			   		BD6->BD6_VLRGTX	:= nBDX_VLRGTX
			   	endIf	
			   	
			endIf
			
			//inss patronal
			if lBD6_VLINPT .and. lBD6_GLINPT .and. lBD6_PEINPT .and. BD6->BD6_PEINPT > 0 

				BD6->BD6_VLINPT := (BD6->BD6_VLRPAG * BD6->BD6_PEINPT) / 100
				BD6->BD6_GLINPT := ( ( BD6->BD6_VLRGLO + BD6->BD6_VLRGTX ) * BD6->BD6_PEINPT) / 100
				
			endIf

			//guia com glosa total bloqueia a cobranca de coparticipacao
			if ! lCopPag .and. getNewPar("MV_PLSGCGP","0") == "1" .and. BD6->BD6_VLRPAG == 0  
				PLSPOSGLO(PLSINTPAD(),__aCdCri226[1],__aCdCri226[2],"1")
				PLBLOPC('BD6', .t., __aCdCri226[1], PLSBCTDESC(), .f., .t.)
			endIf
			
			//Cobra o que paga somente se for coparticipacao
			if  (BD6->BD6_TPPF == '1' .and. lCopPag) .or. (BD6->BD6_TPPF == '2' .and. lCopPag .and. getNewPar("MV_PLSGCGP","0") == "1" .and. BD6->BD6_VLRPAG == 0) /*Para os casos aonde eu glosei integral o item  e parametro ativado não pago coparticipacao*/

				BD6->BD6_VLRBPF := iIf( lValBruto, BD6->BD6_VLRPAG, BD6->BD6_VLRMAN )
				
				if (BD6->BD6_PERCOP > 0) 
					BD6->BD6_VLRPF 	:= ( BD6->BD6_VLRBPF * BD6->BD6_PERCOP ) / 100
				endIf

				BD6->BD6_VLRTAD	:= ( iIf(lModCTX, BD6->BD6_VLRPF, BD6->BD6_VLRBPF) * BD6->BD6_PERTAD ) / 100 
				BD6->BD6_VLRTPF := BD6->BD6_VLRPF + BD6->BD6_VLRTAD

				//se tem limite de franquia 
				if BD6->BD6_F_VFRA > 0 .and. BD6->BD6_VLRTPF > 0 .and. BD6->BD6_VLRTPF > BD6->BD6_F_VFRA 
					
					//guarda os valores originais
					nPerda := 100 - ( ( BD6->BD6_F_VFRA / BD6->BD6_VLRTPF ) * 100 ) 
					
					if BD6->BD6_PERCOP > 0
						BD6->BD6_F_VLPF := (BD6->BD6_VLRTPF / BD6->BD6_PERCOP) * 100
					endIf

					BD6->BD6_F_PPER	:= nPerda
					BD6->BD6_F_VLOR := BD6->BD6_VLRPF
					BD6->BD6_F_TXOR := BD6->BD6_VLRTAD
					BD6->BD6_F_TOOR := BD6->BD6_VLRTPF
					
					//aplica a perda da franquia nos valores de coparticipacao
				   	BD6->BD6_VLRPF  -= ( BD6->BD6_VLRPF * nPerda ) / 100
				   	 
				   	if BD6->BD6_VLRTAD > 0 .and. getNewPar("MV_PLSFCFR","1") == "1"
				   		BD6->BD6_VLRTAD -= ( BD6->BD6_VLRTAD * nPerda ) / 100
				   	endIf	
				   	
				   	//ajusta a diferenca de arredondamento 
					BD6->BD6_VLRTAD += (BD6->BD6_F_VFRA - (BD6->BD6_VLRPF + BD6->BD6_VLRTAD) )
				   	BD6->BD6_VLRTPF := BD6->BD6_VLRPF + BD6->BD6_VLRTAD
				   	 
				else
				
					BD6->BD6_F_VLPF := 0
					BD6->BD6_F_PPER	:= 0
					BD6->BD6_F_VLOR := 0
					BD6->BD6_F_TXOR := 0
					BD6->BD6_F_TOOR := 0
					
				endIf	
				
			endIf
										
		endIf
		
	elseIf cNextFase == DIGITACAO
		
		//Data da mudanca de fase da guia
		BD6->BD6_DTANAL := stod("")		

		//pagamento
		BD6->BD6_VLRBPR := 0
		BD6->BD6_VLRMAN := 0
		BD6->BD6_VLRGLO := 0
		BD6->BD6_VLRPAG := 0

		if lBD6_VLTXPG
			BD6->BD6_VLTXPG := 0
		endIf
		
		if BD6->BD6_VLRAPR == 0 
			BD6->BD6_VLTXAP := 0	
			BD6->BD6_VALORI := 0	
		endIf
		
		if lBD6_VLRGTX
			BD6->BD6_VLRGTX := 0
		endIf

		if lBD6_VLINPT .and. lBD6_PEINPT .and. ( BD6->BD6_PEINPT == 0 .or. BD6->BD6_VLRAPR == 0 ) 
			BD6->BD6_VLINPT := 0
		endIf	
		
		if lBD6_GLINPT
			BD6->BD6_GLINPT := 0
		endIf
		
		//coparticipacao					
		BD6->BD6_VLRBPF := 0
		BD6->BD6_VLRTPF := 0
		BD6->BD6_PERCOP := 0
		BD6->BD6_VLRPF  := 0
		BD6->BD6_PERTAD := 0
		BD6->BD6_VLRTAD := 0

		BD6->BD6_PERHES := 0
		BD6->BD6_TPPF   := ""
		BD6->BD6_ALIAPF := ""
		BD6->BD6_ALIATB := ""
		BD6->BD6_CODTAB	:= ""
		BD6->BD6_MAJORA := 0
		
		BD6->BD6_PERDES := 0
		BD6->BD6_VLRDES := 0
		BD6->BD6_TABDES := ""

		if BD6->BD6_TIPGUI != G_REC_GLOSA
			BD6->BD6_CHVNIV := ""
			BD6->BD6_NIVAUT := ""
			BD6->BD6_NIVCRI := ""
		endIf	
		
		BD6->BD6_CDTBRC := ""
				
		if BD6->BD6_PAGRDA == "1"
			BD6->BD6_BLOCPA := ""
			BD6->BD6_MOTBPF := ""	
			BD6->BD6_DESBPF := ""
		endIf
		
		BD6->BD6_PAGRDA := ""
		BD6->BD6_CONSFR := "0"
		BD6->BD6_VRPRDA := 0
		BD6->BD6_F_VLPF := 0
		BD6->BD6_F_VLOR := 0
		BD6->BD6_F_VFRA := 0
		BD6->BD6_F_PPER := 0
		BD6->BD6_F_TXOR := 0
		BD6->BD6_F_TOOR := 0
		BD6->BD6_F_POTX := 0
		BD6->BD6_CNTCOP := ""
		
		//Há esta regra na análise de glosa, como o sistema põe esse BLOCPA, nós temos que tirar no retorno de fase
		If getNewPar("MV_PLSGCGP","0") == "1" .AND. AllTrim(BD6->BD6_MOTBPF) == __aCdCri226[1]
			PLSPOSGLO(PLSINTPAD(),__aCdCri226[1],__aCdCri226[2],"1")
			PLBLOPC('BD6', .F., __aCdCri226[1], PLSBCTDESC(), .f., .t.)
		EndIf
		
		//desbloqueio pagamento e cobranca
		if lLmpCpo 
			PLBLOPC('BD6', .f., '', '', BD6->BD6_MOTBPG $ __cBLODES, BD6->BD6_MOTBPF $ __cBLODES)
		endIf
		
		// Ponto de Entrada retorno de fase
		if existBlock("PLRFASBD6")
			execBlock("PLRFASBD6",.f.,.f.,{ BD6->(recno()) } )
		endIf
	
	endIf	
	
BD6->(msUnLock())

plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)

nTotBlo := 0

while ! TRBBD7->(eof())

	BD7->( dbGoTo( TRBBD7->REC ) )
	
	BD7->(recLock("BD7",.f.))

		BD7->BD7_FASE := cNextFase

		if cNextFase == DIGITACAO

			if ! lDoppler
				
				//pagamento
				BD7->BD7_VLRBPR := 0
				BD7->BD7_VLRMAN := 0
				BD7->BD7_VLRGLO := 0
				BD7->BD7_VLRPAG := 0

				if lBD7_VLTXPG
					BD7->BD7_VLTXPG := 0
				endIf
				
				if BD6->BD6_VLRAPR == 0
					BD7->BD7_VLTXAP := 0	
					BD7->BD7_VALORI := 0	
				endIf
				
				BD7->BD7_VTXPCT := 0
				
				if lBD7_VLRGTX
					BD7->BD7_VLRGTX := 0
				endIf
				
				if lBD7_VLINPT .and. lBD6_VLINPT .and. ( BD6->BD6_PEINPT == 0 .or. BD6->BD6_VLRAPR == 0 )
					BD7->BD7_VLINPT := 0	
				endIf	

				if lBD7_GLINPT
					BD7->BD7_GLINPT := 0
				endIf
				
				//coparticipacao
				BD7->BD7_VLRBPF := 0
				BD7->BD7_VLRTPF := 0
				BD7->BD7_VLRTAD := 0
				BD7->BD7_COEFUT := 0
				BD7->BD7_COEFPF := 0
				BD7->BD7_PERPF  := 0
				BD7->BD7_ALIAUS := ""
				BD7->BD7_TPCOPF := ""
				BD7->BD7_ALIPF  := ""
				BD7->BD7_FTMTPF := 0
				
				//Data da mudanca de fase da guia
				BD7->BD7_DTANAL := stod("")
				
				BD7->BD7_PDCGAU := 0
				BD7->BD7_VLCGAN := 0
				BD7->BD7_USCGAN := 0
				BD7->BD7_PERHES := 0
				BD7->BD7_PRCHES := 0
				BD7->BD7_DESCRI := ""
				BD7->BD7_DESERR := ""
				BD7->BD7_RFTDEC := 0
				
				if BD7->BD7_REDCUS == '1'
					BD7->BD7_REDCUS := '0'
				endIf
				
				BD7->BD7_MAJORA := 0
				
				if lLmpCpo 
					PLBLOPC('BD7', .f., __cBLODES)
				endIf
				
			else
				BD7->(dbDelete())
			endIf
			
		elseIf cNextFase == PRONTA 

			lBloqueado := .F.

			If BD7->BD7_BLOPAG == '1' .AND. cBDX_ACAO <> '2'
				nTotBlo += BD7->BD7_VLRGLO
				lBloqueado := .T.
			endif

			if ! lProcRev

				//Data da mudanca de fase da guia
				BD7->BD7_DTANAL := dDataBase	
				
				if lBD7_DTDIGI .and. lBD7_DTCTBF .and. empty(BD7->BD7_DTCTBF)
					BD7->BD7_DTCTBF := iIf(empty(BD7->BD7_LAPRO), BD7->BD7_DTDIGI, date())	
				endIf
													
			endIf

			if !lBloqueado

				if ! empty(BD6->BD6_SEQIMP) .and. BD7->BD7_VALORI > 0
					nPercen := PLGETPCEN(BD6->BD6_VALORI - nTotBlo, BD7->BD7_VALORI)
				else
					nPercen := PLGETPCEN(BD6->BD6_VLRBPR - nTotBlo, BD7->BD7_VLRBPR)
				endIf	
				
				BD7->BD7_VLRGLO := ( (BD6->BD6_VLRGLO - nTotBlo) * nPercen ) / 100
				BD7->BD7_VLRMAN := ( (BD6->BD6_VLRMAN - nTotBlo) * nPercen ) / 100
				
				if lBD7_VLTXPG .and. lBD7_VLRGTX
					BD7->BD7_VLTXPG := ( BD6->BD6_VLTXPG * nPercen ) / 100
					BD7->BD7_VLRGTX := ( BD6->BD6_VLRGTX * nPercen ) / 100
				endIf	
				
				//paga pelo contratado ou apresentado lembrar sempre que aqui vem da analise de glosa e glosa manual 
				//por isso deve considerar o VLTXPG
				if getTPCALC(BD6->BD6_CODRDA) $ '2|3' 
					BD7->BD7_VLRPAG	:= BD7->BD7_VLRMAN + BD7->BD7_VLTXPG
				else
					BD7->BD7_VLRPAG := BD7->BD7_VLRMAN + getValTPC(BD7->BD7_VLTXPG, BD7->BD7_VLTXAP, BD7->BD7_TIPGUI == '10', .t.)[1]
				endIf
				
				//inss patronal
				if lBD7_VLINPT .and. lBD7_GLINPT 

					BD7->BD7_VLINPT := (BD7->BD7_VLRPAG * BD7->BD7_PEINPT) / 100
					BD7->BD7_GLINPT := ( ( BD7->BD7_VLRGLO + BD7->BD7_VLRGTX ) * BD7->BD7_PEINPT) / 100
					
				endIf
				
				nVlrPagBru += BD7->BD7_VLRPAG
				
				//coparticipacao cobra o que paga
				if BD6->BD6_TPPF == '1'
					
					if lCopPag
						BD7->BD7_VLRBPF := ( BD6->BD6_VLRBPF * nPercen ) / 100
					endIf
						
					BD7->BD7_VLRTAD := ( BD6->BD6_VLRTAD * nPercen) / 100 
					BD7->BD7_VLRTPF := ( BD6->BD6_VLRTPF * nPercen ) / 100 
					
				endIf
				
			endIf
		endif
	BD7->(msUnLock())
	
	//guarda total do bd7 para posterior conferencia
	if cNextFase == PRONTA 
		getTotBD7(aMatTOTBD7)
	endIf	
	
TRBBD7->(dbSkip())
endDo

TRBBD7->(dbCloseArea())

return
/*/{Protheus.doc} PLSVLIB
valida se e uma liberacao valida
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function PLSVLIB(cNumLib,dDatPro)
local lRet 	:= .t.
local aRet	:= {}
local lFound := .f.
default dDatPro  := dDataBase

BEA->(dbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
lFound := BEA->( msSeek( xFilial("BEA") + cNumLib ) )

if lFound .and. BEA->BEA_ORIGEM == "2" .and. BEA->BEA_STATUS $ '1|2'

	if BEA->BEA_VALSEN < dDatPro .and. PLSPOSGLO(BEA->BEA_OPEMOV,__aCdCri09S[1],__aCdCri09S[2],,,)

		aHisCri := {{__aCdCri09S[1],__aCdCri09S[2],""},;
					{"","Guia Liberação",BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)},;
					{"","Matricula do usuário",BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)},;
					{"","Nome do usuário",BEA->BEA_NOMUSR},;
					{"","Data do Vencimento:",dtoc(BEA->BEA_VALSEN)}}

		if ! PLSMOVCRI("1",{__aCdCri09S[1],__aCdCri09S[2],"",""},aHisCri,BCT->BCT_PERFOR=="1","",.F.)
			return .f.
		endIf

	endIf
	

elseIf lFound

	lRet := .f.
	
	msgAlert("Esta guia não pode ser executada", "Atenção")
	
else

	lRet := .f.
	
	help("",1,"PLNUMLIB")
	
endIf

if ! empty(M->BD5_GUIORI)
	M->BD5_GUIORI := ""
	M->BD5_SENHA  := ""
endIf	

if lRet .and. ! empty( allTrim(M->BD5_NRLBOR) )

	aRet := PLSCTLIB(allTrim(M->BD5_NRLBOR),.f.)
	
	M->BD5_GUIORI := aRet[1]
	M->BD5_SENHA  := aRet[2]
		 
endIf

return(lRet)

/*/{Protheus.doc} plGetLib
retorna o numero da pre-autorizacao
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function plGetLib(cTipoGuia, cChavLib)
local aAreaBE4 := {}
local cAlias 	:= iIf(cTipoGuia == G_RES_INTER,"BE4","BD5")

if cTipoGuia $ G_RES_INTER + '|' + G_HONORARIO

	cGuiInt := (cAlias)->&( cAlias + "_GUIINT" )
	
	if cTipoGuia == G_HONORARIO
		cChavLib := (cAlias)->&( cAlias + "_GUIPRI" )
	endIf
	
	if ! empty(cGuiInt)	.and. empty(cChavLib)
			
		aAreaBE4 := BE4->( getArea() )
		
		BE4->( dbSetOrder(1) )//BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE 
		if BE4->( msSeek( xFilial('BE4') + cGuiInt ) )
			cChavLib := BE4->( BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT )
		endIf	
		
		BE4->( restArea(aAreaBE4) )
			
	endIf

elseIf cTipoGuia == G_SADT_ODON .and. ! empty(BD6->BD6_NRLBOR) .and. ( empty(cChavLib) .or. allTrim(cChavLib) != allTrim(BD6->BD6_NRLBOR) )
	cChavLib := BD6->BD6_NRLBOR
endIf

return

/*/{Protheus.doc} PLDISBD7
distribui valor do bd6 no bd7

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function PLDISBD7(nVlrTotEve, nVlrUnid)
local nPercen 		:= 0
local nPrTxPag		:= 0

local lBD7_PEINPT 	:= BD7->(fieldPos("BD7_PEINPT")) > 0
local lBD7_VLINPT 	:= BD7->(fieldPos("BD7_VLINPT")) > 0

default nVlrTotEve 	:= 0
default nVlrUnid  	:= 0

BD7->(recLock("BD7",.f.))
	
	if nVlrTotEve > 0 .and. nVlrUnid > 0
		nPercen := PLGETPCEN(nVlrTotEve, nVlrUnid)
	else
		nPercen := BD7->BD7_PERCEN 	
	endIf	
	
	if BD7->BD7_PRTXPG == 0
		nPrTxPag := round( (BD6->BD6_VLTXAP / BD6->BD6_VALORI) * 100, PLGetDec('BD7_PRTXPG'))
	else
		nPrTxPag := BD7->BD7_PRTXPG
	endIf	
	
	BD7->BD7_PERCEN := nPercen
	BD7->BD7_VALORI := ( BD6->BD6_VALORI * nPercen ) / 100
	BD7->BD7_VLTXAP := ( BD7->BD7_VALORI * nPrTxPag ) / 100

	BD7->BD7_VLRAPR := ( BD7->BD7_VALORI / BD6->BD6_QTDPRO )

	//inss patronal
	if  lBD7_PEINPT .and. lBD7_VLINPT .and. BD7->BD7_PEINPT > 0 
		BD7->BD7_VLINPT := ( ( BD7->BD7_VALORI + BD7->BD7_VLTXAP ) * BD7->BD7_PEINPT ) / 100
	endIf

BD7->(msUnlock())

return	

/*/{Protheus.doc} PLS720fun
somente para checagem se esta no repositorio
@type function.
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function PLS720fun
return

/*/{Protheus.doc} P720ChPgCp
Verificação se as unidades de cobrança são iguais às unidades de pagamento
para tratamento de valoração de coparticipação quando a tabela de cobrança
tem composição diferente da tabela de pagamento
@type function
@author Oscar
@since 04/05/2018
@version 1.0
/*/
Function P720ChPgCp(aAux, aComEve)

Local lIgual	:= .T.
Local nFor		:= 1

If ! ( empTy(aComEve) ) .and. Len(aComEve) == Len(aAux)

	For nFor := 1 to Len(aComEve)

		If aScan(aAux, { |x| Alltrim(x[1]) == Alltrim(aComEve[nfor][1])}) == 0
			lIgual := .F.
			Exit
		endIf

	Next

else
	lIgual := .F.
endIf

return ! lIgual

/*/{Protheus.doc} getNivChk
Verifica se acha nivel valido para valorar coparticipacao
@type function
@author PLSTEAM
@since 14/11/2018
@version 1.0
/*/
function getNivChk(lGet, aDadUsr, cNivelAN, cChvNiv,lPacGenInt,aInfoPac)
local cNiveis	:= "BFG|BFE|BFD|BFC|BT7|BRV|BBK|BR8"
local aRetAux 	:= {}
Local aInfoProc := {}

Default lPacGenInt := .F.
Default aInfoPac := {}

if lGet .and. (! cNivelAN $ cNiveis .OR. lPacGenInt)

	aInfoProc := {BD6->BD6_DATPRO, BD6->BD6_CODPAD, BD6->BD6_CODPRO, BD6->BD6_QTDPRO, BD6->(recno())}

	If !empty(aInfoPac)
		aInfoProc := aclone(aInfoPac)
	endif
	aRetAux := PLSAUTP(	aInfoProc[1],;
						time(),;
						aInfoProc[2],;
						aInfoProc[3],;
						aInfoProc[4],;
						aDadUsr,;
						aInfoProc[5],;
						{},;
						"1",;
						.f.,; //10
						"",;
						.t.,;
						nil,;
						.f.,nil,nil,nil,nil,nil,nil /*20*/,nil,nil,nil,nil,nil,nil,nil,nil,;
						nil,nil/*30*/,nil,nil,.f.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
						nil,nil,nil,nil,nil,.f.,.f.,nil,nil,nil,nil,nil,nil,nil,nil,;
						nil,nil,nil,nil,nil,nil,nil,nil,.t.)

	if valType(aRetAux) == "A" .and. len(aRetAux) >= 4
		
		cNivelAN := aRetAux[3]
		cChvNiv  := aRetAux[4]

	endIf

else

	cNivelAN := iIf( ! empty(BD6->BD6_NIVAUT), BD6->BD6_NIVAUT, BD6->BD6_NIVCRI )
	cChvNiv  := BD6->BD6_CHVNIV

endIf	

return()

//Função para retornar se um profissional de saúde está vinculado à um cadastro de RDA (BAU)
function PLconvRDA7( cCodOpe, cCodLdp, ccodPEG, cNumero, cSequen, lAuto)

Local aAreaBAU := BAU->(GetArea())
Local aAreaBB0 := BB0->(getArea())
//Local aRet 	:= {.F., ""} //indica se achou uma RDA vinculada e qual o código dela
Local cSql := ""
Local lUnimed := GetNewPar("MV_PLSUNI", "0") == "1"
Local lRegraAtv := GetNewPar("MV_PL7RDA", .F.)

Default cCodOpe := PLSINTPAD()
Default cCodLdp := " "
default ccodPEG := " "
Default cNumero := " "
Default cSequen := " "
Default lAuto := .F.

If (lUnimed .AND. lRegraAtv) .OR. lAuto
	csql += " Select BD7.R_E_C_N_O_ D7REC, BAU_CODIGO AUCOD, BAU_NOME AUNOM from " + RetsqlName("BAU") + " BAU "
	cSql += " Inner Join " 
	cSql += retsqlName("BB0") + " BB0 "
	csql += " On "
	csql += " BB0_FILIAL = '" + xfilial("BB0") + "' AND "// BAU_FILIAL AND
	cSql += " BB0_CODIGO = BAU_CODBB0 AND "
	cSql += " BB0.D_E_L_E_T_ = ' ' "
	csql += " Inner Join "
	csql += RetSqlName("BD7") + " BD7 "
	cSql += " On "
	cSql += " BD7_FILIAL = '" + xfilial("BD7") + "' AND "
	cSql += " BD7_CODOPE = '" + cCodOpe + "' AND "
	csql += " BD7_CODLDP = '" + cCodLdp + "' AND "
	cSql += " BD7_CODPEG = '" + cCodPEG + "' AND "
	
	If !(empTy(cNumero)) //pode ser por PEG, daí não tem esse
		cSql += " BD7_NUMERO = '" + cNumero + "' AND "
	endIf
	
	If !(empTy(cSequen)) //pode ser por guia, daí não tem esse. aliás, vai demoarar um pouco pra ter esse
		csql += " BD7_SEQUEN = '" + cSequen + "' AND "
	endIf
	
	cSql += " BD7_CDPFPR = BB0_CODIGO AND "
	cSql += " BD7_CDPFPR <> ' ' AND "
	csql += " BD7_CODUNM NOT IN " + formatIn("COP|COR|UCO|FIL|DOP|CRR|INC|TCR|VDI|VMD|VMT|VTX", "|") + " AND "
	cSql += " BD7.D_E_L_E_T_ =  '  ' "
	cSql += " Where "
	cSql += " BAU_FILIAL = '" + Xfilial("BAU") + "' AND "
	cSql += " BAU_CODIGO <> BD7_CODRDA AND "
	cSql += " BAU_COPCRE = '1' AND "
	cSql += " BAU.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"BB0xBAU",.F.,.T.)
	
	while !(BB0xBAU->(EoF()))
		BD7->(dbGoTo(BB0xBAU->(D7REC)))
		BD7->(RecLock("BD7", .f.))
			BD7->BD7_CODRDA := BB0xBAU->AUCOD
			BD7->BD7_NOMRDA := BB0xBAU->AUNOM
		BD7->(MsUnLock())
		BB0xBAU->(dbskip())
	endDo
	BB0xBAU->(dbclosearea())
endIf
return //aRet

/*/{Protheus.doc} PlsVrcExec
Verifica se a execução ja foi feita no dia atual para o mesmo beneficiario na mesma guia
@type function
@autor Thiago
@since 29/10/2020
@version 1.0
/*/
function PlsVrcExec() 
local cSql := ""
local lret := .F.

if BD6->BD6_CODLDP == PLSRETLDP(2)
	cSql := "SELECT BE2_NUMAUT FROM " + RetSQLName("BE2")
	cSql += " WHERE BE2_FILIAL = '"   + xFilial("BE2") + "' AND "
	cSql += " BE2_NRLBOR  = '" + BD5->BD5_NRLBOR + "' AND "
	cSql += " BE2_MATRIC  = '" + BD6->BD6_MATRIC + "' AND "
	cSql += " BE2_OPEUSR  = '" + BD6->BD6_OPEUSR + "' AND "
	cSql += " BE2_CODEMP  = '" + BD6->BD6_CODEMP + "' AND "
	cSql += " BE2_TIPREG  = '" + BD6->BD6_TIPREG + "' AND "
	cSql += " BE2_CODPAD  = '" + BD6->BD6_CODPAD + "' AND "
	cSql += " BE2_CODPRO = '"  + BD6->BD6_CODPRO + "' AND "
	cSql += " BE2_DATPRO = '"  + DtoS(BD6->BD6_DATPRO) + "' AND "
	cSql += " BE2_CODRDA = '"  + BD6->BD6_CODRDA + "' AND "
	cSql += " D_E_L_E_T_ = ' ' "  

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"tmpbe2",.f.,.t.)
  	
	if ! tmpbe2->(eof())
		lret := .T.
	endIf

	tmpbe2->(dbclosearea())
endif	

return lret

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAAA720
Faz verificações de contrato pré-estabelecidos
A variável cIdcont é para ser passada por parâmetro para caso seja preciso
do Identificador do contrato usado (somente caso haja um retorno válido)
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
function plsAAA720(cCodRDA,cMatric,DdatPro,cCodPad,cCodPro,cIdCont,cCodEsp)

local aGrpVin := {}
local lRet := .T.
Local aCntVin := {}
Local nI := 1
Local nJ := 1
Local nReducao := 0
Local cCodInt := PLSINTPAD()
Local aB8P := {.F.,.F.,0}

Default cIdCont := ''
Default cCodEsp := ' '

B8O->(DbsetOrder(1))
B94->(DbSetOrder(2))
B9U->(dbsetOrder(2))
if lCapAtu2
	B8P->(dbsetOrder(1))
endif
//procura contrato
If lRet .AND. B8O->(MsSeek(xFilial("B8O") + cCodint + cCodRDA))
	While !(B8O->(EoF())) .AND. xFilial("B8O") + cCodint +cCodRDA == B8O->( B8O_FILIAL + B8O_CODINT + B8O_CODRDA )
		If VigVal(dDatPro)
			aadd(aCntVin, {B8O->B8O_IDCOPR,B8O->B8O_PERRED,B8O->B8O_ALLPRO,IIF(lCapAtu3, B8O->B8O_POSPAG == '1',.F.)})
		endif
		B8O->(DbSkip())
	EndDo
endIf

//Se não tem contrato vigente, já morreu aqui
lRet := !(empty(aCntVin))

If lRet
	lRet := .F.
	//procura os grupos vinculados ao contrato
	For nI := 1 To Len(aCntVin)
		aGrpVin := {}
		If B94->(MsSeek(xfilial("B94") + cCodRDa + aCntvin[nI][1]))
			While !(B94->(EoF())) .AND. xFilial("B94") + cCodRDa + aCntvin[nI][1] == B94->( B94_FILIAL + B94_CODRDA + B94_IDCOPR )
				If VerBloq(dDatPro)
					aadd(aGrpVin, B94->B94_CODGRU)
					lRet := .T.
				endIf
				B94->(dbskip())
			endDo
		endif
		aadd(aCntvin[nI], aGrpVin)
	next
endif

If lRet
	lRet := .F.
	//Verifica se o beneficiário estava em dos grupos.
	//sai no primeiro que achar
	For nI := 1 To Len(aCntVin)
		//A última posição do array sempre será um array com os grupos vinculados. Palavras chave Última e Sempre.
		For nJ := 1 To Len(aCntVin[nI][len(aCntVin[nI])])
			If B9U->(MsSeek(xFilial("B9U") + aCntVin[nI][len(aCntVin[nI])][nJ] + cMatric)) .AND. VerVig(dDatPro, aCntVin[nI][4])
				lRet := .T.
				nReducao := aCntVin[nI][2]
				if lCapAtu2 //Aqui vemos se tem percentual específico de redução no item
							//Se no contrato não tiver marcado considera todos procedimentos e falhar a busca do B8P, não vai considerar a regra
							//Se entrar B8P, somente trocase for informado o CONREG com Sim (1)
					aB8P := BuscaB8P(cCodint, cCodRda, aCntVin[nI][1], cCodPad, cCodPro, cCodEsp)
					if aB8P[1] .AND. aB8P[2]
						nReducao := aB8P[3]
					elseif aCntVin[nI][3] <> '1' //Se não considera todos eventos e não achou B8P, não vale
						lRet := .F.
						nReducao := 0
					endif
				endif
				if lRet
					exit
				endif
			endIf
		next
		If lRet
			cIdCont := aCntVin[nI][1]
			exit
		endIf
	next
endIf

//Fechamos essas áreas pra que não precise fechar o proc contas e abrir de novo pras mudanças do cadastro terem efeito
B8O->(dbclosearea())
B94->(dbclosearea())
B9U->(dbclosearea())
if lCapAtu2
	B8P->(dbclosearea())
endif

return {lRet,nReducao}

//-------------------------------------------------------------------
/*/{Protheus.doc} verBloq
Verifica se o vínculo estava vigente na data do evento
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
static function verBloq(dDatPro)
local lret := .F.

If empty(B94->B94_VIGFIM) .OR. B94->B94_VIGFIM > dDatPro
	lRet := .T.
endIf

If lRet .AND. !(B94->B94_VIGINI <= dDatPro)
	lRet := .F.
endIf

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vigval
valida vigência do contrato com a data do evento
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
static function vigVal(dDatPro)
Local lRet := .F.

If empty(B8O->(B8O_VIGFIM)) .OR. B8O->B8O_VIGFIM > dDatPro
	lRet := .T.
endIf

If lRet .AND. !(B8O->B8O_VIGINI <= dDatPro)
	lRet := .F.
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} verVig
Verifica se o beneficiário estava associado ao grupo na data do evento
@author Oscar Zanin
@since 03/2021
@version P12
/*/
//-------------------------------------------------------------------
static function verVig(dDatPro,lPosPago)
local lRet := .F.
Default lPosPago := .F.
/* Validação simples
If empty(B9U->B9U_VIGFIM) .OR. B9U->B9U_VIGFIM > dDatPro
	lRet := .T.
endIf

If lRet .AND. !(B9U->B9U_VIGINI <= dDatPro)
	lRet := .F.
endIf
*/
If B9U->B9U_VIGFIM == B9U->B9U_VIGINI .AND. !(empty(B9U->B9U_VIGINI))
	lRet := .f.
else
	If empty(B9U->B9U_VIGFIM) .OR. B9U->B9U_VIGFIM > dDatPro
		lRet := .T.
	endIf

	//Essa condição vê se não foi bloqueado depois da geração do crédito
	If !lRet .AND. B9U->B9U_VIGFIM <= dDatPro .AND. LastDay(B9U->B9U_DATBLQ) + 1 >= dDatPro
		lRet := .T.
	endIf

	if lPosPago
		If lRet .AND. ;
			(Firstday(B9U->B9U_VIGINI) >= dDatPro .OR. ; //Nessa condição a vigência inicia depois da data do evento
			(Firstday(B9U->B9U_VIGINI) <= dDatPro .AND. LastDay(B9U->B9U_DATINC) > LastDay(dDatPro) ) )
			lRet := .F.
		endIf
	else
		If lRet .AND. ;
			( ( Firstday(B9U->B9U_VIGINI) >= dDatPro .AND. LastDay(B9U->B9U_DATINC) + 1 <= dDatPro )  .OR.; //Nessa condição a vigência inicia depois da data do evento
			( FirstDay(B9U->B9U_VIGINI) <= dDatPro .AND. LastDay(B9U->B9U_DATINC) + 1 >= dDatPro ) ) //Nessa condição a inclusão foi depois de gerar o crédito
			lRet := .F.
		endIf
	endif
endif

return lRet

Static function BuscaB8P(cCodint, cCodRda, cIdCont, cCodPad, cCodPro, cCodEsp)

Local aRet := {.F., .F., 0}
Local cSql := ""

default cCodEsp := ' '

cSql += " Select B8P_PERRED, B8P_CONREG, B8P_CODESP from " + retSqlName("B8P")
cSql += " Where "
csql += " B8P_FILIAL = '" + xFilial("B8P") + "' AND "
cSql += " B8P_CODINT = '" + cCodInt + "' AND "
cSql += " B8P_CODRDA = '" + cCodRDA + "' AND "
cSql += " B8P_IDCOPR = '" + cIdCont + "' AND "
cSql += " B8P_CODPAD = '" + cCodPad + "' AND "
cSql += " B8P_CODPRO = '" + cCodPro + "' AND "
if B8P->(FieldPos("B8P_CODESP")) > 0
	cSql += "( B8P_CODESP = '" + cCodEsp + "' OR "
	cSql += " B8P_CODESP = ' ') AND "
endif
cSql += " D_E_L_E_T_ = ' ' "
cSql += " Order By B8P_CODESP DESC "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"B8PCHK",.f.,.t.)

if !(B8PCHK->(EoF()))
	aRet[1] := .T.
	if B8PCHK->B8P_CONREG == '1'
		aRet[2] := .T.
		aret[3] := B8PCHK->B8P_PERRED
	endif
endif

B8PCHK->(dbclosearea())
return aRet
