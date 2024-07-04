#include "PROTHEUS.CH"
#Include "CTBLPGL.CH"

STATIC lAnoAnt		:= .F.
STATIC lAnoAntEnt	:= .F.
STATIC lEbitda		:= .F.



// 17/08/2009 -- Filial com mais de 2 caracteres

//Tradu็ใo PTG

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณCTBLPGL   ณAutor  ณEduardo Nunes Cirqueira ณ Data ณ  21/12/06 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Programa contendo todas as fun็๕es atribuidas ao parametro  	บฑฑ
ฑฑบ          ณ ONLOAD dos Paineis de Gestao 								บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 9                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtCmpEntGer ณAutor  ณEduardo Nunes Cirqueira ณ Data ณ  12/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama a funcao CtbPlGerCm() para calcular o saldo de todas as    บฑฑ
ฑฑบ          ณ Entidades da Visao Gerencial informada. Esse saldo sera          บฑฑ
ฑฑบ          ณ referente a todos os periodos do calendario que estiverem dentro บฑฑ
ฑฑบ          ณ do intervalo de datas informado.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CtCmpEntGer(oPanel)	//	Ctb Comparativo de Entidade Gerencial


Local oMeter,oText,oDlg,lEnd

Local aSaveArea		:= GetArea()
Local aMeses		:= {}
Local aPeriodos
Local aSetOfBook
Local aResult		:= {}
Local aAux
Local aRetPainel

Local dDataIni
Local dDataFim

Local lImpAntLP
Local lVlrZerado

Local cTpComp
Local cMoeda
Local cCalend
Local cSaldo

Local nCont
Local nEntid
Local nIniValor
Local nTamVal		:= TAMSX3("CT2_VALOR")[1]
Local nDecimais
Local nDivide		:= 1
Local nCor			:= CLR_HBLUE
Local nMesAnt

If lAnoAnt							// Se for Comparativo considerando o mesmo periodo em Anos Anteriores
	Pergunte( "CTBPGL020",.F. )
ElseIf lEbitda						// Se for Evolucao de EBITDA
	Pergunte( "CTBPGL040",.F. )	
Else								//	Se for Comparativo Mes a Mes
	Pergunte( "CTBPGL010",.F. )
EndIf

// Parametros dos grupos CTBPGL010, CTBPGL020 e CTBPGL040
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros					  	      	ณ
//ณ mv_par01				// Data Inicial              	          	ณ
//ณ mv_par02				// Data Final                             	ณ
//ณ mv_par03				// Cod. Visao Gerencial                   	ณ
//ณ mv_par04				// Exibe Entidades? Sintet/Analit/Ambas 	ณ
//ณ mv_par05				// Exibir Saldos Zerados?                  	ณ
//ณ mv_par06				// Moeda?          			     	      	ณ
//ณ mv_par07				// Calendario?			 					ณ
//ณ mv_par08				// Tipo de Saldo?							ณ
//ณ mv_par09				// Divide por ?                   		 	ณ
//ณ mv_par10				// Posicao Ant. L/P? Sim / Nao         	 	ณ
//ณ mv_par11				// Data Lucros/Perdas?                 	 	ณ
//ณ mv_par12				// Comparar? Mov. Periodo/Saldo Acumulado	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

// Somente para o grupo CTBPGL040 - Painel Ebitda
//ณ mv_par13				// Descricao do Painel? 					ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


dDataIni	:= mv_par01
dDataFim	:= mv_par02
aSetOfBook	:= {"","","",0,mv_par03,"","","",1,""}
lImpSint	:= (mv_par04<>2)
lVlrZerado	:= (mv_par05==1)
cMoeda		:= mv_par06
cCalend		:= AllTrim(mv_par07)
cSaldo		:= mv_par08
lImpAntLP	:= (mv_par10==1)
dDataLP		:= mv_par11
cTpComp		:= If(mv_par12==1,"M","S" )	//	Comparativo : "M"ovimento ou "S"aldo Acumulado

aPeriodos := CtbPeriodos( cMoeda,dDataIni,dDataFim,.T.,.F.,cCalend )

For nCont := 1 to Len(aPeriodos)
	// Se a data do periodo do calendario esta dentro do intervalo de datas informado nas perguntas
	If aPeriodos[nCont][1] >= dDataIni .And. aPeriodos[nCont][2] <= dDataFim
		AADD( aMeses,{ StrZero(Len(aMeses)+1,2), aPeriodos[nCont][1], aPeriodos[nCont][2] } )
	EndIf
Next

If Len( aMeses ) == 0
	Return {}	
EndIf

If lAnoAnt	//	Se for Comparativo considerando o mesmo periodo em anos anteriores

	// Ordena aMeses pelo Mes + Ano do periodo, para exibir no painel os mesmos periodos juntos
	// Ex.: 01/05 e 01/06; 02/05 e 02/06, etc...
	aSort( aMeses ,,,{|x,y|	 StrZero( Month(x[2]),2 ) + StrZero( Year(x[2]),4 ) < ;
                             StrZero( Month(y[2]),2 ) + StrZero( Year(y[2]),4 ) } )
EndIf

If mv_par09 == 2
	nDivide := 100			//	Divide por cem
ElseIf mv_par09 == 3
	nDivide := 1000			//	Divide por mil
ElseIf mv_par09 == 4
	nDivide := 1000000		//  Divide por milhao
EndIf	


//
// Conteudo de aResult:
//
// - aResult[1]					: Codigo da Entidade Gerencial
// - aResult[2]					: Descricao da Entidade Gerencial
// - aResult[3]					: .T. para Sintetica; .F. para Analitica
// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
//

CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
          
aRetPainel := {}

nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

For nEntid := 1 to Len( aResult[1] )
	//
	// Conteudo de aRetPainel:
	// aRetPainel := { Entidade, {Data Inicial do Periodo - Data Final do Periodo, Saldo, Cor do Saldo} }
	//
	If lEbitda
		If !aResult[3,nEntid] //Somente sinteticas
			Loop
		EndIf
	EndIf
	
	aAux := {}
    For nIniValor := 4 to Len( aResult )
		// Dividindo o valor pelo indice informado na pergunta "Divide por"
    	If nDivide > 1
			aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
    	EndIf

		// Se for Comparativo de Anos Anteriores, alternar a cor dos valores entre Azul e Vermelho
    	If lAnoAnt
    		If nIniValor == 4	//	Se for o primeiro elemento de aAux, inicia com Azul
    			nMesAnt := Month( aMeses[nIniValor-3,2] )
    			nCor    := CLR_HBLUE
    		Else
    			If Month( aMeses[nIniValor-3,2] ) <> nMesAnt	//	Se mudou o mes, mudar a cor
	    			nMesAnt := Month( aMeses[nIniValor-3,2] )
    				If nCor == CLR_HBLUE
    					nCor := CLR_HRED
    				Else
    					nCor := CLR_HBLUE
    				EndIf
    			EndIf
    		EndIf
    	EndIf

		If lEbitda		//	Painel de EBITDA			
			Aadd( aRetPainel,{ DtoC(aMeses[nIniValor-3,2]) + " - " + DtoC(aMeses[nIniValor-3,3]),;
    	                  ValorCTB(aResult[nIniValor,nEntid],,,nTamVal,nDecimais,.T.,"",,,,,,,,.F.) , nCor , } )    	                 

		Else
			Aadd( aAux,{ DtoC(aMeses[nIniValor-3,2]) + " - " + DtoC(aMeses[nIniValor-3,3]),;
    	                  ValorCTB(aResult[nIniValor,nEntid],,,nTamVal,nDecimais,.T.,"",,,,,,,,.F.) , nCor , } )
		EndIf
	Next

	If !lEbitda
		Aadd( aRetPainel, {Trim(aResult[1,nEntid])+" - "+aResult[2,nEntid],aAux} )	//	Codigo da Entidade + Descricao, Saldos
	EndIf
Next

RestArea(aSaveArea)

Return aRetPainel



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCtCmp2EntGer ณAutor  ณEduardo Nunes Cirqueira ณ Data ณ  12/01/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama a funcao CtCmpEntGer() para calcular o saldo de todas as   บฑฑ
ฑฑบ          ณ Entidades da Visao Gerencial informada. A variavel "lAnoAnt"     บฑฑ
ฑฑบ          ณ indicara que trata-se do Painel Comparativo de Saldos de Entida- บฑฑ
ฑฑบ          ณ des Gerenciais com mesmo Periodo em Anos Anteriores.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtCmpAnoAnt()	//	Ctb Comparativo de Saldos de Entidades Gerenciais para Anos Anteriores

lAnoAnt	:= .T.	//	Indica que trata-se do painel para Saldos Comparativos de Anos Anteriores

Return CtCmpEntGer()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtCmpSldEntณAutor  ณEduardo Nunes Cirqueira ณ Data ณ  22/02/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula o saldo de todas as entidades informadas. Esse saldo    บฑฑ
ฑฑบ          ณ sera referente a todos os periodos do calendario que estiverem  บฑฑ
ฑฑบ          ณ dentro do intervalo de datas informado.                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtCmpSldEnt()	//	Ctb Comparativo de Saldo de Entidade
            
Local aSaveArea		:= GetArea()
Local aSetOfBook	:= {""}
Local aSaldoIni		:= {}
Local aSaldoFim		:= {}
Local aEntid
Local aPeriodos
Local aMeses		:= {}
Local aAux
Local aRetPainel	:= {}

Local dDataIni, dDataFim

Local cContaIni, cContaFim
Local cMoeda
Local cCalend
Local cTpSald
Local cEntid
Local cEntIni, cEntFim
Local cCampo

Local lSint
Local lSoSint
Local lMovPeriodo

Local nTamVal		:= TAMSX3("CT2_VALOR")[1]
Local nCont
Local nDecimais
Local nSaldo
Local nDivide		:= 1
Local nEntid
Local nCor			:= CLR_HBLUE
Local nMesAnt

If ! lAnoAntEnt
	Pergunte( "CTBPGL030",.F. )
Else
	Pergunte( "CTBPGL060",.F. )
EndIf

// Parametros dos grupos CTBPGL030 e CTBPGL060
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros					  	      	ณ
//ณ mv_par01				// Data Inicial								ณ
//ณ mv_par02				// Data Final                          		ณ
//ณ mv_par03				// Conta Inicial                       		ณ
//ณ mv_par04				// Conta Final   					   		ณ
//ณ mv_par05				// C.C. Inicial         		       		ณ
//ณ mv_par06				// C.C. Final   					   		ณ
//ณ mv_par07				// Item Inicial                        		ณ
//ณ mv_par08				// Item Final   					  		ณ
//ณ mv_par09				// Classe de Valor Inicial             		ณ
//ณ mv_par10				// Classe de Valor Final			   		ณ
//ณ mv_par11				// Exibe Contas? Sintet/Analit/Ambas 		ณ
//ณ mv_par12				// Moeda?          			     	   		ณ
//ณ mv_par13				// Calendario?			 					ณ
//ณ mv_par14				// Tipo de Saldo?							ณ
//ณ mv_par15				// Divide por ?                   		 	ณ
//ณ mv_par16				// Posicao Ant. L/P? Sim / Nao         	 	ณ
//ณ mv_par17				// Data Lucros/Perdas?                 	 	ณ
//ณ mv_par18 				// Comparar? Mov. Periodo/Saldo Acumulado	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dDataIni	:= mv_par01
dDataFim	:= mv_par02
cContaIni	:= mv_par03
cContaFim	:= mv_par04
lSint		:= (mv_par11<>2)
lSoSint		:= (mv_par11==1)
cMoeda		:= mv_par12
cCalend		:= AllTrim(mv_par13)
cTpSald		:= mv_par14
lMovPeriodo	:= (mv_par18==1)


aPeriodos := CtbPeriodos( cMoeda,dDataIni,dDataFim,.T.,.F.,cCalend )

For nCont := 1 to Len(aPeriodos)
	// Se a data do periodo esta dentro do intervalo de datas
	If aPeriodos[nCont][1] >= dDataIni .And. aPeriodos[nCont][2] <= dDataFim
		AADD( aMeses,{ StrZero(Len(aMeses)+1,2), aPeriodos[nCont][1], aPeriodos[nCont][2] } )
	EndIf
Next

If Len( aMeses ) == 0
	Return {}	
EndIf

If	lAnoAntEnt	//	Indica que trata-se do painel para Comparativos de Saldos de Entidades para Anos Anteriores

	// Ordena aMeses pelo Mes + Ano do periodo, para exibir no painel os mesmos periodos juntos
	// Ex.: 01/05 e 01/06; 02/05 e 02/06, etc...
	aSort( aMeses ,,,{|x,y|	 StrZero( Month(x[2]),2 ) + StrZero( Year(x[2]),4 ) < ;
                             StrZero( Month(y[2]),2 ) + StrZero( Year(y[2]),4 ) } )
EndIf


If mv_par15 == 2	//	Pergunta "Divide por ?"
	nDivide := 100			//	Divide por cem
ElseIf mv_par15 == 3
	nDivide := 1000			//	Divide por mil
ElseIf mv_par15 == 4
	nDivide := 1000000		//  Divide por milhao
EndIf	

nDecimais  := DecimalCTB( aSetOfBook,cMoeda )


// Calcula o saldo das CONTAS do intervalo
dbSelectArea("CT1")
dbSetOrder(1)
MsSeek( xFilial()+cContaIni,.T. )

While ! CT1->(Eof()) .And. CT1->CT1_FILIAL == xFilial("CT1") .And. CT1->CT1_CONTA <= cContaFim

	If ( !lSint  .And. CT1->CT1_CLASSE == "1" ) .Or.;	//Se nao deve considerar Sinteticas e a conta e Sintetica, ou
       ( lSoSint .And. CT1->CT1_CLASSE == "2" )		//Se deve considerar somente Sinteticas e a conta nao e Sintetica
		CT1->( DbSkip() )
		Loop
	EndIf
	
	aAux := {}

	For nCont := 1 to Len( aMeses )
		nSaldo := MovConta(	AllTrim(CT1->CT1_CONTA),aMeses[nCont,2]/*Data Inicial*/,aMeses[nCont,3]/*Data Final*/,cMoeda,;
							cTpSald,If(lMovPeriodo,3,4),If(CT1->CT1_CLASSE=="1",1,0)/*1=Sintetica*/,;
							(mv_par16==1)/*Anterior LP*/,mv_par17/*Data LP*/ )

		If nDivide > 1
			nSaldo := (nSaldo / nDivide)
		EndIf

		// Se for Comparativo de Anos Anteriores, alternar a cor dos valores entre Azul e Vermelho
    	If lAnoAntEnt
    		If nCont == 1	//	Se for o primeiro elemento de aAux, inicia com Azul
    			nMesAnt := Month( aMeses[nCont,2] )
    			nCor    := CLR_HBLUE
    		Else
    			If Month( aMeses[nCont,2] ) <> nMesAnt	//	Se mudou o mes, mudar a cor
	    			nMesAnt := Month( aMeses[nCont,2] )
    				If nCor == CLR_HBLUE
    					nCor := CLR_HRED
    				Else
    					nCor := CLR_HBLUE
    				EndIf
    			EndIf
    		EndIf
    	EndIf

		Aadd( aAux,{ DtoC(aMeses[nCont,2]) + " - " + DtoC(aMeses[nCont,3]),;
                      ValorCTB(nSaldo,,,nTamVal,nDecimais,.T.,"",,,,,,,,.F.) , nCor , } )
	Next

	Aadd( aRetPainel, {AllTrim(CT1->CT1_CONTA)+" - "+AllTrim(CT1->CT1_DESC01),aAux} )	//	Codigo da Entidade + Descricao, Saldos
	
	CT1->( DbSkip() )
EndDo


// Calcula o saldo das Entidades de Custo informadas nos parametros
aEntid := { "CTT", "CTD","CTH" }

For nEntid := 1 to Len( aEntid )

	cEntid := aEntid[nEntid]

	If cEntid == "CTT"
		cEntIni := mv_par05		//	Centro Custo Inicial
		cEntFim := mv_par06		//	Centro Custo Final
		cCampo	:= "CTT_CUSTO"

	ElseIf cEntid == "CTD"
		cEntIni := mv_par07		//	Item Contabil Inicial
		cEntFim := mv_par08		//	Item Contabil Final
		cCampo	:= "CTD_ITEM"

	Else
		cEntIni := mv_par09		//	Classe Valor Inicial
		cEntFim := mv_par10		//	Classe Valor Final
		cCampo	:= "CTH_CLVL"
	EndIf


	dbSelectArea(cEntid)
	dbSetOrder(1)
	MsSeek( xFilial()+cEntIni,.T. )

	//
	// "Varrendo" as entidades de custo para calcular o seu saldo
	//
	While ! (cEntid)->(Eof()) .And. (cEntid)->&(cEntid+"_FILIAL") == xFilial(cEntid) .And. (cEntid)->&(cCampo) <= cEntFim

		If (cEntid)->&(cEntid+"_CLASSE") == "1"	//	Se for Entidade Sintetica
			(cEntid)->( DbSkip() )
			Loop
		EndIf            
		
		aAux := {}

		For nCont := 1 to Len( aMeses )
			aSaldoIni := SaldoCTU( cEntid,(cEntid)->&(cCampo),aMeses[nCont,2]/*Data Inicial*/,cMoeda,cTpSald,"",(mv_par16==1)/*Anterior LP*/,mv_par17/*Data LP*/ )
			aSaldoFim := SaldoCTU( cEntid,(cEntid)->&(cCampo),aMeses[nCont,3]/*Data Final*/  ,cMoeda,cTpSald,"",(mv_par16==1)/*Anterior LP*/,mv_par17/*Data LP*/ )

			If lMovPeriodo
				nDebito		:= aSaldoFim[4] - aSaldoIni[7]
				nCredito	:= aSaldoFim[5] - aSaldoIni[8]
			EndIf

			nSaldo := If( lMovPeriodo, nDebito-nCredito, aSaldoFim[1] )	//	Saldo

			If nDivide > 1
				nSaldo := (nSaldo / nDivide)
			EndIf
		
			// Se for Comparativo de Anos Anteriores, alternar a cor dos valores entre Azul e Vermelho
	    	If lAnoAntEnt
	    		If nCont == 1	//	Se for o primeiro elemento de aAux, inicia com Azul
	    			nMesAnt := Month( aMeses[nCont,2] )
	    			nCor    := CLR_HBLUE
	    		Else
	    			If Month( aMeses[nCont,2] ) <> nMesAnt	//	Se mudou o mes, mudar a cor
		    			nMesAnt := Month( aMeses[nCont,2] )
	    				If nCor == CLR_HBLUE
	    					nCor := CLR_HRED
	    				Else
	    					nCor := CLR_HBLUE
	    				EndIf
	    			EndIf
	    		EndIf
	    	EndIf

			Aadd( aAux,{ DtoC(aMeses[nCont,2]) + " - " + DtoC(aMeses[nCont,3]),;
    	                  ValorCTB(nSaldo,,,nTamVal,nDecimais,.T.,"",,,,,,,,.F.) , nCor , } )
		Next

		Aadd( aRetPainel, {	AllTrim( (cEntid)->&(cCampo) )+ " - " + 	/*Codigo da Entidade*/;
							AllTrim( (cEntid)->&(cEntid+"_DESC01") )	/*Descricao*/,;
							aAux} )									//	Saldos

		(cEntid)->( DbSkip() )
	EndDo

Next


RestArea(aSaveArea)

Return aRetPainel


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCtEbitda     ณAutor  ณEduardo Nunes Cirqueira ณ Data ณ  28/02/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama a funcao CtCmpEntGer() para calcular o saldo de todas as   บฑฑ
ฑฑบ          ณ Entidades da Visao Gerencial informada. A Visao Gerencial do     บฑฑ
ฑฑบ          ณ EBITDA deve conter apenas uma Entidade Gerencial.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtEbitda(oPanel)		//	Ctb EBITDA

lEbitda	:= .T.	//	Indica que trata-se do painel para EBITDA

Return CtCmpEntGer(oPanel)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCtPreLan     ณAutor  ณEduardo Nunes Cirqueira ณ Data ณ  01/03/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Encontrar a quantidade e o valor de pre-lan็amentos por moeda.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtPreLan()		//	Ctb Pre-Lan็amentos por Moeda

Local aSaveArea		:= GetArea()
Local aMoeda		:= {}
Local aRetPainel	:= {}
Local aAux			:= {}

Local dDataIni, dDataFim

Local nTamVal		:= TAMSX3("CT2_VALOR")[1]
Local nDivide		:= 1
Local nMoeda
Local nValor

Local cQuery
Local cQtde


Pergunte( "CTBPGL050",.F. )
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros					  	      	ณ
//ณ mv_par01				// Data Inicial								ณ
//ณ mv_par02				// Data Final                          		ณ
//ณ mv_par03				// Divide por ?                   		 	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dDataIni	:= mv_par01
dDataFim	:= mv_par02

If mv_par03 == 2			//	Pergunta "Divide por ?"
	nDivide := 100			//	Divide por cem
ElseIf mv_par03 == 3
	nDivide := 1000			//	Divide por mil
ElseIf mv_par03 == 4
	nDivide := 1000000		//	Divide por milhao
EndIf


//
//	Pegando todas as moedas
//
// 	Conteudo de aMoeda:
//		- aMoeda[1] = Codigo    da Moeda
//		- aMoeda[2] = Descricao da Moeda
//		- aMoeda[3] = Qtd. Casas Decimais da Moeda
//
If ChkFile("CTO")

	CTO->( DbGoTop() )
	DbSeek( xFilial("CTO") )
	While ! CTO->(Eof()) .And. xFilial("CTO") == CTO->CTO_FILIAL
		Aadd( aMoeda,{CTO->CTO_MOEDA, AllTrim(CTO->CTO_DESC), CTO->CTO_DECIM} )
		CTO->( DbSkip() )
	EndDo

	//
	// Buscando no CT2 os Pre-Lan็amentos de cada moeda
	//
	If ChkFile("CT2")
		For nMoeda := 1 to Len( aMoeda )
			cQuery := " SELECT COUNT(CT2_VALOR) QTDE, SUM(CT2_VALOR) VALOR "
			cQuery += " 	FROM "+RetSqlName("CT2")
			cQuery += " 	WHERE	CT2_FILIAL		= '" + xFilial("CT2")   + "' AND "
			cQuery += " 			CT2_DATA  BETWEEN '" + DTOS(dDataIni)   + "' AND '" + DTOS(dDataFim) + "' AND "
			cQuery += " 			CT2_MOEDLC		= '" + aMoeda[nMoeda,1] + "' AND "
			cQuery += "				CT2_TPSALD		= '9' AND "
			cQuery += " 			D_E_L_E_T_      = '' "

			cQuery := ChangeQuery(cQuery)

			If Select("TRBTMP") > 0
				TRBTMP->( DbCloseArea() )
			Endif

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

			cQtde  := AllTrim( Transform( TRBTMP->QTDE,"@E 999,999,999,999" ) )
			nValor := TRBTMP->VALOR

			If nDivide > 1
				nValor := (nValor / nDivide)
			EndIf

			Aadd( aAux,{ aMoeda[nMoeda,1]+"-"+aMoeda[nMoeda,2],;
			             cQtde,;
						 ValorCTB(nValor,,,nTamVal,aMoeda[nMoeda,3]/*Qtd.Decimais*/,.T.,"",,,,,,,,.F.) , CLR_HBLUE , } )

			If Select("TRBTMP") > 0
				TRBTMP->( DbCloseArea() )
			Endif

		Next

		aRetPainel	:= { NIL	/*Bloco de Codigo*/,;
						 {STR0011/*"Moeda"*/,STR0012/*"Quantidade"*/,STR0013/*"Total"*/} /*Cabecalho*/,;
						 aAux /*Itens*/ }
	EndIf
EndIf

RestArea(aSaveArea)

Return aRetPainel



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCtCmpEntAnt  ณAutor  ณEduardo Nunes Cirqueira ณ Data ณ  05/03/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama a funcao CtCmpSldEnt() para calcular o saldo de todas as   บฑฑ
ฑฑบ          ณ Entidades informadas. A variavel "lAnoAntEnt" indicara que       บฑฑ
ฑฑบ          ณ trata-se do Painel Comparativo de Saldos de Entidades com mesmo  บฑฑ
ฑฑบ          ณ Periodo em Anos Anteriores.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtCmpEntAnt()	//	Ctb Comparativo de Saldos de Entidades para Anos Anteriores

lAnoAntEnt := .T.	//	Indica que trata-se do painel para Comparativos de Saldos de Entidades para Anos Anteriores

Return CtCmpSldEnt()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtPrzMed  ณAutor  ณPaulo Carnelossi          ณ Data ณ  14/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama a funcao CtbPlGerCm() para calcular o saldo de todas as    บฑฑ
ฑฑบ          ณ Entidades da Visao Gerencial informada. Esse saldo sera          บฑฑ
ฑฑบ          ณ referente a todos os periodos do calendario que estiverem dentro บฑฑ
ฑฑบ          ณ do intervalo de datas informado.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CtbPrzMed()

Local oMeter,oText,oDlg,lEnd

Local aSaveArea		:= GetArea()
Local aMeses		:= {}
Local aPeriodos
Local aSetOfBook
Local aResult		:= {}
Local aRetPainel	:= {}

Local dDataIni
Local dDataFim

Local lImpAntLP
Local lVlrZerado

Local cTpComp
Local cMoeda
Local cCalend
Local cSaldo

Local nCont
Local nEntid
Local nIniValor
Local nDivide		:= 1

Local nY, nX, lContinua := .T., nDias, cConta, nSint, aMesAux
Local aParEstoque := {}, nPrzMedEst, nSldMedEst, nCustoVendas 
Local aParCobranca := {}, nPrzMedCob, nSldMedCob, nReceitas, nDevolAbat
Local aParPagto := {}, nPrzMedPag, nSldMedPag, nCompras

Pergunte( "CTBPGL080",.F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros					  	      	ณ
//ณ mv_par01				// Data Inicial              	          	ณ
//ณ mv_par02				// Data Final                             	ณ
//ณ mv_par03 				// Exibir Saldos Zerados?                  	ณ
//ณ mv_par04 				// Moeda?          			     	      	ณ
//ณ mv_par05 				// Calendario?			 					ณ
//ณ mv_par06 				// Tipo de Saldo?							ณ
//ณ mv_par07 				// Divide por ?                   		 	ณ
//ณ mv_par08 				// Posicao Ant. L/P? Sim / Nao         	 	ณ
//ณ mv_par09 				// Data Lucros/Perdas?                 	 	ณ
//ณ mv_par10 				// Considerar? Mov. Periodo/Saldo Acumulado	ณ
//| mv_par11				// Estoque              (Conta)				|
//| mv_par12				// Custo Vendas         (Conta)				|
//| mv_par13				// Duplic. a Receber    (Conta)				|
//| mv_par14				// Receita Oper.Bruta   (Conta)				|
//| mv_par15				// Devol. e Abatimentos (Conta)				|
//| mv_par16				// Fornecedores         (Conta)				|
//| mv_par17				// Compras Brutas       (Conta)				|
//| mv_par18				// Estoque              (Visao Ger)			|
//| mv_par19				// Custo Vendas         (Visao Ger)			|
//| mv_par20				// Duplic. a Receber    (Visao Ger)			|
//| mv_par21				// Receita Oper.Bruta   (Visao Ger)			|
//| mv_par22				// Devol. e Abatimentos (Visao Ger)			|
//| mv_par23				// Fornecedores         (Visao Ger)			|
//| mv_par24				// Compras Brutas       (Visao Ger)	     	|
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dDataIni	:= mv_par01
dDataFim	:= mv_par02
lImpSint	:= .T.
lVlrZerado	:= (mv_par03==1)
cMoeda		:= mv_par04
cCalend		:= AllTrim(mv_par05)
cSaldo		:= mv_par06
lImpAntLP	:= (mv_par08==1)
dDataLP		:= mv_par09
cTpComp		:= If(mv_par10==1,"M","S" )	//	Considerar : "M"ovimento ou "S"aldo Acumulado

aPeriodos := CtbPeriodos( cMoeda,dDataIni,dDataFim,.T.,.F.,cCalend )

For nCont := 1 to Len(aPeriodos)
	// Se a data do periodo do calendario esta dentro do intervalo de datas informado nas perguntas
	If aPeriodos[nCont][1] >= dDataIni .And. aPeriodos[nCont][2] <= dDataFim
		AADD( aMeses,{ StrZero(Len(aMeses)+1,2), aPeriodos[nCont][1], aPeriodos[nCont][2] } )
	EndIf
Next

If Len( aMeses ) == 0
	Return {}	
EndIf

If mv_par07 == 2
	nDivide := 100			//	Divide por cem
ElseIf mv_par07 == 3
	nDivide := 1000			//	Divide por mil
ElseIf mv_par07 == 4
	nDivide := 1000000		//  Divide por milhao
EndIf	

dbSelectArea("CT1")
dbSetOrder(1)
dbSelectArea("CTS")
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPrazo Medio de Estoque ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Valida se conta ou Visao foi preenchida 
// Parametros 11 / 18 ---> Estoque
//            12 / 19 ---> Custo das Vendas

aParEstoque := {}
nPrzMedEst 	:= 0
nSldMedEst 	:= 0

If Empty(mv_par11) .And. Empty(mv_par18)
	lContinua := .F.
ElseIf Empty(mv_par12) .And. Empty(mv_par19)
	lContinua := .F.
Else
	//CONTA OU VISAO DE ESTOQUE
	If ! Empty(mv_par11) //procura no plano de contas conta de Estoque
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par11, Len(CT1->CT1_CONTA))))
			aAdd(aParEstoque, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Estoque
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par18, Len(CTS->CTS_CODPLA))))
			aAdd(aParEstoque, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO DE CUSTO DE VENDAS
	If lContinua .And. ! Empty(mv_par12) //procura no plano de contas conta de Custo de Vendas
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par12, Len(CT1->CT1_CONTA))))
			aAdd(aParEstoque, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Custo de Vendas
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par19, Len(CTS->CTS_CODPLA))))
			aAdd(aParEstoque, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf

If Len(aParEstoque) != 2 //sao 2 contas Estoque e Custo de Vendas
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0002, Str(0,2),CLR_HRED,  } )  //"Prz.Med.Estq.Nao Calculado"

Else

	For nX := 1 TO Len(aParEstoque)

		If aParEstoque[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParEstoque[nX,2])
			nSint := aParEstoque[nX,3]

		    If nX == 1 //Saldo Medio dos Estoques (Conta)

   				nSldMedEst 	:= 0

		    	//buscar saldo inicial do estoque
			    nSldMedEst 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedEst := nSldMedEst / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedEst 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedEst 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedEst := nSldMedEst / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

		    	//Saldo Custo de Vendas (Conta)
				nCustoVendas := 0
			    If nDivide > 1
				    nCustoVendas += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nCustoVendas += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial
			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio dos Estoque
				aResult := {}
				nSldMedEst 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParEstoque[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedEst += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedEst += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedEst := nSldMedEst / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else // Custo das Vendas
		
				aResult := {}
				nCustoVendas := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParEstoque[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
			
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nCustoVendas += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nCustoVendas += aResult[Len(aResult),nEntid]
					EndIf
				EndIf	
								
			EndIf
			
		EndIf
		
	Next
	
	// Calcula o Prazo Medio dos Estoques
	// Prazo Medio de Estoque = Saldo Medio dos Estoques / ( Custo das Vendas / n Dias )
	// n Dias => Data Final - Data Inicial
	
	nDias := dDataFim - dDataIni
	If nDias > 0
		nPrzMedEst := nSldMedEst / ( nCustoVendas / nDias )
		aAdd(aRetPainel, { STR0003, Str(nPrzMedEst, 3),CLR_HBLUE,  } )  //"Prazo Medio de Estoque"
	Else
		aAdd(aRetPainel, { STR0002, Str(0,2),CLR_HRED,  } )  //"Prz.Med.Estq.Nao Calculado"
	EndIf	

EndIf

//TERMINO DO PRAZO MEDIO DE ESTOQUE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPRAZO MEDIO DE COBRANCAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lContinua := .T.

//Valida se conta ou Visao foi preenchida 
// Parametros 13 / 20 ---> Duplicatas a Receber
//            14 / 21 ---> Receita Operacional Bruta
//            15 / 22 ---> Devolucao e Abatimentos

aParCobranca 	:= {}
nPrzMedCob 		:= 0
nSldMedCob 		:= 0

If Empty(mv_par13) .And. Empty(mv_par20)
	lContinua := .F.
ElseIf Empty(mv_par14) .And. Empty(mv_par21)
	lContinua := .F.
ElseIf Empty(mv_par15) .And. Empty(mv_par22)
	lContinua := .F.
Else
	//CONTA OU VISAO --> DUPLICATAS A RECEBER
	If ! Empty(mv_par13) //procura no plano de contas conta de duplicatas a receber
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par13, Len(CT1->CT1_CONTA))))
			aAdd(aParCobranca, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de duplicatas a receber
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par20, Len(CTS->CTS_CODPLA))))
			aAdd(aParCobranca, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO --> RECEITA OPERACIONAL BRUTA
	If lContinua .And. ! Empty(mv_par14) //procura no plano de contas
										 // receita operacional bruta
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par14, Len(CT1->CT1_CONTA))))
			aAdd(aParCobranca, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao --> RECEITA OPERACIONAL BRUTA
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par21, Len(CTS->CTS_CODPLA))))
			aAdd(aParCobranca, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO --> DEVOLUCOES E ABATIMENTOS
	If lContinua .And. ! Empty(mv_par15) //procura no plano de contas
										 // devolucoes e abatimentos
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par15, Len(CT1->CT1_CONTA))))
			aAdd(aParCobranca, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao --> DEVOLUCOES E ABATIMENTOS
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par22, Len(CTS->CTS_CODPLA))))
			aAdd(aParCobranca, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf

EndIf

If Len(aParCobranca) != 3   //sao 3 contas - Duplicatas a Receber
	lContinua := .F.        //               receita operacional bruta
EndIf                       //                devolucoes e abatimentos
			
If ! lContinua		

	aAdd(aRetPainel, { STR0004, Str(0,2),CLR_HRED,  } )  //"Prz.Med.Cobr.Nao Calculado"

Else

	For nX := 1 TO Len(aParCobranca)

		If aParCobranca[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParCobranca[nX,2])
			nSint := aParCobranca[nX,3]

		    If nX == 1 //Saldo Medio das duplicatas a receber

   				nSldMedCob 	:= 0

		    	//buscar saldo inicial das duplicatas a receber
			    nSldMedCob 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedCob := nSldMedCob / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedCob 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedCob 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedCob := nSldMedCob / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

				If nX == 2    	//Receita Operacional Bruta
					nReceitas := 0
				    If nDivide > 1
					    nReceitas += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
					Else
					    nReceitas += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    EndIf
				Else             //devolucao e abatimentos
					nDevolAbat := 0
				    If nDivide > 1
					    nDevolAbat += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
					Else
					    nDevolAbat += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    EndIf
				EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio de duplicatas a receber
				aResult := {}
				nSldMedCob 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParCobranca[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedCob += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedCob += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedCob := nSldMedCob / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else 

		    	If nX == 2 // Custo das Receitas Oper. Brutas e Devol.e Abatimentos
		
					aResult := {}
					nReceitas := 0
					
					// Conteudo de aResult:
					//
					// - aResult[1]					: Codigo da Entidade Gerencial
					// - aResult[2]					: Descricao da Entidade Gerencial
					// - aResult[3]					: .T. para Sintetica; .F. para Analitica
					// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
					//
					aSetOfBook	:= {"","","",0,aParCobranca[nX,2],"","","",1,""}
					CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				
				    //aqui aplica o fator de divisao
					For nEntid := 1 to Len( aResult[1] )
					    If nDivide > 1
						   	For nIniValor := 4 to Len( aResult )
								// Dividindo o valor pelo indice informado na pergunta "Divide por"
								aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
				    		Next
				    	EndIf	
					Next
	
					If cTpComp == "M"
						//aqui soma para compor o saldo dos periodos
						For nEntid := 1 to Len( aResult[1] )
						   	For nIniValor := 4 to Len( aResult )
								nReceitas += aResult[nIniValor,nEntid]
			    			Next
						Next
	                Else
	                	nEntid := 1
						If Len(aResult) >= 4  //considera sempre o ultimo saldo
							nReceitas += aResult[Len(aResult),nEntid]
						EndIf
					EndIf
				
				Else

                    //Visao --> Devolucoes e Abatimentos
					aResult := {}
					nDevolAbat := 0
					
					// Conteudo de aResult:
					//
					// - aResult[1]					: Codigo da Entidade Gerencial
					// - aResult[2]					: Descricao da Entidade Gerencial
					// - aResult[3]					: .T. para Sintetica; .F. para Analitica
					// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
					//
					aSetOfBook	:= {"","","",0,aParCobranca[nX,2],"","","",1,""}
					CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				
				    //aqui aplica o fator de divisao
					For nEntid := 1 to Len( aResult[1] )
					    If nDivide > 1
						   	For nIniValor := 4 to Len( aResult )
								// Dividindo o valor pelo indice informado na pergunta "Divide por"
								aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
				    		Next
				    	EndIf	
					Next
	
					If cTpComp == "M"
						//aqui soma para compor o saldo dos periodos
						For nEntid := 1 to Len( aResult[1] )
						   	For nIniValor := 4 to Len( aResult )
								nDevolAbat += aResult[nIniValor,nEntid]
			    			Next
						Next
	                Else
	                	nEntid := 1
						If Len(aResult) >= 4  //considera sempre o ultimo saldo
							nDevolAbat += aResult[Len(aResult),nEntid]
						EndIf
					EndIf
				
				EndIf

			EndIf
				
		EndIf
		
	Next
	
	// Calcula o Prazo Medio de Cobranca
	// Prazo Medio de Cobranca = Saldo Medio das Duplicatas a Receber
	//                           -------------------------------------------------------
	//                           ( ( Receitas Op.Bruta - Devol.Abatimentos)  / n Dias )
	// n Dias => Data Final - Data Inicial

	nDias := dDataFim - dDataIni
	If nDias > 0
		nPrzMedCob := nSldMedCob / ( (nReceitas - nDevolAbat) / nDias )
		aAdd(aRetPainel, { STR0005, Str(nPrzMedCob, 3),CLR_HBLUE,  } )  //"Prazo Medio de Cobranca"
	Else
		aAdd(aRetPainel, { STR0004, Str(0,2),CLR_HRED,  } )  //"Prz.Med.Cobr.Nao Calculado"
	EndIf	

EndIf

//TERMINO DO PRAZO MEDIO DE COBRANCA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPRAZO MEDIO DE PAGAMENTO DOS FORNECEDORES ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lContinua := .T.

//Valida se conta ou Visao foi preenchida 
// Parametros 16 / 23 ---> Fornecedores
//            17 / 24 ---> Compras Brutas

aParPagto 	:= {}
nPrzMedPag 	:= 0
nSldMedPag 	:= 0

If Empty(mv_par16) .And. Empty(mv_par23)
	lContinua := .F.
ElseIf Empty(mv_par17) .And. Empty(mv_par24)
	lContinua := .F.
Else
	//CONTA OU VISAO --> FORNECEDORES
	If ! Empty(mv_par16) //procura no plano de contas - fornecedores
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par16, Len(CT1->CT1_CONTA))))
			aAdd(aParPagto, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao - fornecedores
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par23, Len(CTS->CTS_CODPLA))))
			aAdd(aParPagto, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO --> COMPRAS BRUTA
	If lContinua .And. ! Empty(mv_par17) //procura no plano de contas - compras bruta
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par17, Len(CT1->CT1_CONTA))))
			aAdd(aParPagto, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao --> COMPRAS BRUTA
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par24, Len(CTS->CTS_CODPLA))))
			aAdd(aParPagto, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf

EndIf

If Len(aParPagto) != 2   //sao 2 contas - Fornecedores / Compras Bruta
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0006, Str(0,2),CLR_HRED,  } )  //"Prz.Med.Pag.Forn.Nao Calcul."

Else

	For nX := 1 TO Len(aParPagto)

		If aParPagto[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParPagto[nX,2])
			nSint := aParPagto[nX,3]

		    If nX == 1 //Saldo Medio dos fornecedores

   				nSldMedPag 	:= 0

		    	//buscar saldo inicial da conta fornecedores
			    nSldMedPag 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedPag := nSldMedPag / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedPag 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedPag 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedPag := nSldMedPag / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

				//Compras Bruta
				nCompras := 0
				If nDivide > 1
					nCompras += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nCompras += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio de Fornecedores
				aResult := {}
				nSldMedPag 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParPagto[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedPag += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedPag += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedPag := nSldMedPag / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else 

		    	// Compras Bruta
				aResult := {}
				nCompras := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParPagto[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
		
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nCompras += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nCompras += aResult[Len(aResult),nEntid]
					EndIf
				EndIf

			EndIf
				
		EndIf
		
	Next
	
	// Calcula o Prazo Medio de Pagamento aos Fornecedores
	// Prazo Medio de Cobranca = Saldo Medio dos Fornecedores [Ctas a Pagar]
	//                           -------------------------------------------
	//                           ( Compras Bruta  / n Dias )
	// n Dias => Data Final - Data Inicial

	nDias := dDataFim - dDataIni
	If nDias > 0
		nPrzMedPag := nSldMedPag / ( nCompras / nDias )
		aAdd(aRetPainel, { STR0007, Str(nPrzMedPag, 3),CLR_HBLUE,  } )  //"Prazo Medio Pagto.Fornecedores"
	Else
		aAdd(aRetPainel, { STR0006, Str(0,2),CLR_HRED,  } )  //"Prz.Med.Pag.Forn.Nao Calc."
	EndIf	

EndIf

//TERMINO DO PRAZO MEDIO DE PAGAMENTO AOS FORNECEDORES

RestArea(aSaveArea)

Return aRetPainel


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ CtIndPat    ณAutor  ณEduardo Nunes Cirqueira ณ Data ณ  12/03/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtIndPat()		//	Ctb Indice de Estrutura Patrimonial

Local oMeter,oText,oDlg,lEnd

Local aSaveArea		:= GetArea()
Local aResult
Local aRetPainel
Local aConta

Local dData
Local dDataLP

Local lImpAntLP
Local lContinua		:= .T.

Local cMoeda
Local cTpSaldo
Local cConta

Local nX
Local nSint
Local nDivide		:= 1
Local nEntid
Local nIniValor
Local nCapital
Local nCompEndiv
Local nEndivGer
Local nImobCap
Local nImobRec


Pergunte( "CTBPGL070",.F. )
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros					  	      	ณ
//ณ mv_par01				// Data para pegar os saldos   	          	ณ
//ณ mv_par02				// Pas. Circulante (Conta)			        ณ
//ณ mv_par03				// Exig. L. Prazo  (Conta)              	ณ
//ณ mv_par04				// Patr. Liquido   (Conta)             	    ณ
//ณ mv_par05				// At. Total       (Conta)                  ณ
//ณ mv_par06				// At. Permanente  (Conta)               	ณ
//ณ mv_par07				// Pas. Circulante (Visใo Ger.)         	ณ
//ณ mv_par08				// Exig. L. Prazo  (Visao Ger.)          	ณ
//ณ mv_par09				// Patr. Liquido   (Visใo Ger.)         	ณ
//ณ mv_par10				// At. Total       (Visใo Ger.)          	ณ
//ณ mv_par11				// At. Permanente  (Visใo Ger.)          	ณ
//ณ mv_par12				// Moeda?          			     	      	ณ
//ณ mv_par13				// Tipo de Saldo?							ณ
//ณ mv_par14				// Divide por ?                   		 	ณ
//ณ mv_par15				// Posicao Ant. L/P? Sim / Nao         	 	ณ
//ณ mv_par16				// Data Lucros/Perdas?                 	 	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dData		:= mv_par01
cMoeda		:= mv_par12
cTpSaldo	:= mv_par13
lImpAntLP	:= (mv_par15==1)
dDataLP		:= mv_par16

If mv_par14 == 2
	nDivide := 100			//	Divide por cem
ElseIf mv_par14 == 3
	nDivide := 1000			//	Divide por mil
ElseIf mv_par14 == 4
	nDivide := 1000000		//  Divide por milhao
EndIf

dbSelectArea("CT1")
dbSetOrder(1)

dbSelectArea("CTS")
dbSetOrder(1)

//
// Valida se Conta ou Visao foi preenchida
//
lContinua	:=	( !Empty(mv_par02) .Or. !Empty(mv_par07) ) .And.;
				( !Empty(mv_par03) .Or. !Empty(mv_par08) ) .And.;
				( !Empty(mv_par04) .Or. !Empty(mv_par09) ) .And.;
				( !Empty(mv_par05) .Or. !Empty(mv_par10) ) .And.;
				( !Empty(mv_par06) .Or. !Empty(mv_par11) ) 

aRetPainel 	:= {}
aConta		:= {}

//
// Valida se a Conta e/ou a Visao existem no respectivo cadastro
//
If lContinua
	ExisteConta( mv_par02,mv_par07,@lContinua,@aConta )		//	Conta ou Visao do Passivo Circulante
	ExisteConta( mv_par03,mv_par08,@lContinua,@aConta )		//	Conta ou Visao do Exigivel a Longo Prazo
	ExisteConta( mv_par04,mv_par09,@lContinua,@aConta )		//	Conta ou Visao do Patrimonio Liquido
	ExisteConta( mv_par05,mv_par10,@lContinua,@aConta )		//	Conta ou Visao do Ativo Total
	ExisteConta( mv_par06,mv_par11,@lContinua,@aConta )		//	Conta ou Visao do Ativo Permanente

	lContinua := ( Len(aConta) == 5 )	//	sao 5 contas
    
	If lContinua
	
		For nX := 1 to Len(aConta)
	
			If aConta[nX, 1] == 1	//	Conta Contabil
	
				cConta	:= Alltrim(aConta[nX,2])
				nSint	:= aConta[nX,3]
	
		    	// Buscar Saldo da Conta
			    aConta[nX,4] +=	 MovConta(cConta,dData,dData,cMoeda,cTpSaldo,4,nSint,lImpAntLP,dDataLP)
	
			    If nDivide > 1
			    	aConta[nX,4] /= nDivide
			    EndIf
	
			Else	//	Visao Gerencial
			
				aResult := {}
	
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes ao(s) periodo(s)
				//
				aSetOfBook	:= {"","","",0,aConta[nX,2],"","","",1,""}
	
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dData,dData,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,;
				            .T./*Valor Zerado*/,.F.,,.T.,Nil,.T./*Cons.Sintetica*/,"S"/*Saldo Acumulado*/,.T.,@aResult,cTpSaldo )
	
				// "Joga" o saldo da conta em aConta
				For nEntid := 1 to Len( aResult[1] )
					For nIniValor := 4 to Len( aResult )
						// Aplica o fator de divisao
					    If nDivide > 1
							aResult[nIniValor,nEntid] /= nDivide
						EndIf
						aConta[nX,4] += aResult[nIniValor,nEntid]
			    	Next
				Next
	
	        EndIf
		Next
	
		//
		// Calculando os Indices propriamente ditos da Estrutura Patrimonial, onde:
		//
		//	aConta[1,4] = Saldo do Passivo Circulante
		//	aConta[2,4] = Saldo do Exigivel a Longo Prazo
		//	aConta[3,4] = Saldo do Patrimonio Liquido
		//	aConta[4,4] = Saldo do Ativo Total
		//	aConta[5,4] = Saldo do Ativo Permanente
		//
	
		// Capital de Terceiros / Capital Proprio	-> Formula: ( Passivo Circulante + Exig Longo Prazo ) / Patr Liquido
		nCapital	:= ( aConta[1,4] + aConta[2,4] ) / aConta[3,4]
	
		// Composicao do Endividamento 				-> Formula: Passivo Circulante / ( Passivo Circulante + Exig Longo Prazo )
		nCompEndiv	:= aConta[1,4] / ( aConta[1,4] + aConta[2,4] )
	
		// Endividamento Geral 						-> Formula: ( Passivo Circulante + Exig a Longo Prazo ) / Ativo Total
		nEndivGer	:= ( aConta[1,4] + aConta[2,4] ) / aConta[4,4]
	
		// Imobilizacao do Capital Proprio			-> Formula: Ativo Permanete / Patr Liquido
		nImobCap	:= aConta[5,4] / aConta[3,4]
	
		// Imobilizacao dos Recursos Permanentes	-> Formula: Ativo Permanete / ( Exig Longo Prazo + Patr Liquido )
		nImobRec	:= aConta[5,4] / ( aConta[2,4] + aConta[3,4] )
	
		aAdd(aRetPainel, { STR0014 /*"Capital Terceiros / Proprio"*/, Transf( nCapital  , "@E 999,999.99" ), CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0015 /*"Composicao do Endividamento"*/, Transf( nCompEndiv, "@E 999,999.99" ), CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0016 /*"Endividamento Geral"        */, Transf( nEndivGer , "@E 999,999.99" ), CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0017 /*"Imobiliz. Capital Proprio"  */, Transf( nImobCap  , "@E 999,999.99" ), CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0018 /*"Imobiliz. Rec. Permanentes" */, Transf( nImobRec  , "@E 999,999.99" ), CLR_HBLUE, } )
    EndIf

EndIf

RestArea(aSaveArea)

Return aRetPainel


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ ExisteConta บAutor  ณ Eduardo Nunes Cirqueira บ Data ณ 19/03/07 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a conta existe no CT1 ou se a visao existe no CTS.  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cConta    = Codigo da Conta Contabil                            บฑฑ
ฑฑบ          ณ cVisao    = Codigo da Visapo Gerencial                          บฑฑ
ฑฑบ          ณ lContinua = Se o conta/visao for encontrada, atualiza para .T.  บฑฑ
ฑฑบ          ณ aConta    = Matriz alimentada com dados sobre a conta/visao     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. se encontrou a conta/visao                                  บฑฑ
ฑฑบ          ณ .F. se nao encontrou                                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExisteConta( cConta,cVisao,lContinua,aConta )

Local aSaveArea := GetArea()

DEFAULT cConta    := ""
DEFAULT cVisao    := ""
DEFAULT lContinua := .T.
DEFAULT aConta    := {}

If lContinua
	If ! Empty(cConta)	//	Procura a Conta Contabil
		If CT1->(dbSeek(xFilial("CT1")+PadR(cConta, Len(CT1->CT1_CONTA))))
			aAdd( aConta, { 1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0), 0} )
		Else
			lContinua := .F.
		EndIf
	
	Else	//	Procura a Visao Gerencial
		If CTS->(dbSeek(xFilial("CTS")+PadR(cVisao, Len(CTS->CTS_CODPLA))))
			aAdd(aConta, { 2, CTS->CTS_CODPLA, NIL, 0 })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf
	
RestArea(aSaveArea)

Return lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbGiros  ณAutor  ณPaulo Carnelossi          ณ Data ณ  23/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama a funcao CtbPlGerCm() para calcular o saldo de todas as    บฑฑ
ฑฑบ          ณ Entidades da Visao Gerencial informada. Esse saldo sera          บฑฑ
ฑฑบ          ณ referente a todos os periodos do calendario que estiverem dentro บฑฑ
ฑฑบ          ณ do intervalo de datas informado.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CtbGiros()

Local oMeter,oText,oDlg,lEnd

Local aSaveArea		:= GetArea()
Local aMeses		:= {}
Local aPeriodos
Local aSetOfBook
Local aResult		:= {}
Local aRetPainel

Local dDataIni
Local dDataFim

Local lImpAntLP
Local lVlrZerado

Local cTpComp
Local cMoeda
Local cCalend
Local cSaldo

Local nCont
Local nEntid
Local nIniValor
Local nDecimais
Local nDivide		:= 1

Local nY, nX, lContinua := .T., nDias, cConta, nSint, aMesAux
Local aParEstoque 	:= {}, nGiroEst		, nSldMedEst	, nCustoVendas 
Local aParCobranca 	:= {}, nGiroCob		, nSldMedCob	, nReceitas		, nDevolAbat
Local aParAtivoCirc := {}, nGiroCirc	, nSldMedCirc	, nRecOperLiq
Local aParAtFixo 	:= {}, nGiroATF		, nSldMedATF
Local aParAtvOper 	:= {}, nGiroAtOp	, nSldMedAtOp
Local aParAtvTotal 	:= {}, nGiroAtTotal	, nSldMedTotal

Pergunte( "CTBPGL090",.F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros					  	      	ณ
//ณ mv_par01				// Data Inicial              	          	ณ
//ณ mv_par02				// Data Final                             	ณ
//ณ mv_par03 				// Exibir Saldos Zerados?                  	ณ
//ณ mv_par04 				// Moeda?          			     	      	ณ
//ณ mv_par05 				// Calendario?			 					ณ
//ณ mv_par06 				// Tipo de Saldo?							ณ
//ณ mv_par07 				// Divide por ?                   		 	ณ
//ณ mv_par08 				// Posicao Ant. L/P? Sim / Nao         	 	ณ
//ณ mv_par09 				// Data Lucros/Perdas?                 	 	ณ
//ณ mv_par10 				// Considerar? Mov. Periodo/Saldo Acumulado	ณ
//| mv_par11				// Estoque              (Conta)				|
//| mv_par12				// Custo Vendas         (Conta)				|
//| mv_par13				// Duplic. a Receber    (Conta)				|
//| mv_par14				// Receita Oper.Bruta   (Conta)				|
//| mv_par15				// Devol. e Abatimentos (Conta)				|
//| mv_par16				// Rec.Oper.Liquida     (Conta)				|
//| mv_par17				// Ativo Circulante     (Conta)				|
//| mv_par18				// Ativo Fixo           (Conta)				|
//| mv_par19				// Ativo Operacional    (Conta)				|
//| mv_par20				// Ativo Total          (Conta)				|
//| mv_par21				// Estoque              (Visao Ger)			|
//| mv_par22				// Custo Vendas         (Visao Ger)			|
//| mv_par23				// Duplic. a Receber    (Visao Ger)			|
//| mv_par24				// Receita Oper.Bruta   (Visao Ger)			|
//| mv_par25				// Devol. e Abatimentos (Visao Ger)			|
//| mv_par26				// Rec.Oper.Liquida     (Visao Ger)			|
//| mv_par27				// Ativo Circulante     (Visao Ger)	     	|
//| mv_par28				// Ativo Fixo           (Visao Ger)	     	|
//| mv_par29				// Ativo Operacional    (Visao Ger)	     	|
//| mv_par30				// Ativo Total          (Visao Ger)	     	|
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dDataIni	:= mv_par01
dDataFim	:= mv_par02
lImpSint	:= .T.
lVlrZerado	:= (mv_par03==1)
cMoeda		:= mv_par04
cCalend		:= AllTrim(mv_par05)
cSaldo		:= mv_par06
lImpAntLP	:= (mv_par08==1)
dDataLP		:= mv_par09
cTpComp		:= If(mv_par10==1,"M","S" )	//	Considerar : "M"ovimento ou "S"aldo Acumulado

aPeriodos := CtbPeriodos( cMoeda,dDataIni,dDataFim,.T.,.F.,cCalend )

For nCont := 1 to Len(aPeriodos)
	// Se a data do periodo do calendario esta dentro do intervalo de datas informado nas perguntas
	If aPeriodos[nCont][1] >= dDataIni .And. aPeriodos[nCont][2] <= dDataFim
		AADD( aMeses,{ StrZero(Len(aMeses)+1,2), aPeriodos[nCont][1], aPeriodos[nCont][2] } )
	EndIf
Next

If Len( aMeses ) == 0
	Return {}	
EndIf

If mv_par07 == 2
	nDivide := 100			//	Divide por cem
ElseIf mv_par07 == 3
	nDivide := 1000			//	Divide por mil
ElseIf mv_par07 == 4
	nDivide := 1000000		//  Divide por milhao
EndIf	

dbSelectArea("CT1")
dbSetOrder(1)
dbSelectArea("CTS")
dbSetOrder(1)

//--------------------------------------------------------------------------------//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGiro de Estoques       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Valida se conta ou Visao foi preenchida 
// Parametros 11 / 21 ---> Estoque
//            12 / 22 ---> Custo das Vendas

aRetPainel 	:= {}
aParEstoque := {}
nGiroEst 	:= 0
nSldMedEst 	:= 0

If Empty(mv_par11) .And. Empty(mv_par21)
	lContinua := .F.
ElseIf Empty(mv_par12) .And. Empty(mv_par22)
	lContinua := .F.
Else
	//CONTA OU VISAO DE ESTOQUE
	If ! Empty(mv_par11) //procura no plano de contas conta de Estoque
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par11, Len(CT1->CT1_CONTA))))
			aAdd(aParEstoque, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Estoque
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par21, Len(CTS->CTS_CODPLA))))
			aAdd(aParEstoque, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO DE CUSTO DE VENDAS
	If lContinua .And. ! Empty(mv_par12) //procura no plano de contas conta de Custo de Vendas
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par12, Len(CT1->CT1_CONTA))))
			aAdd(aParEstoque, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Custo de Vendas
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par22, Len(CTS->CTS_CODPLA))))
			aAdd(aParEstoque, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf

If Len(aParEstoque) != 2 //sao 2 contas Estoque e Custo de Vendas
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0019, Str(0,2),CLR_HRED,  } )  // "Giro do Estoque Nao Calculado"

Else

	For nX := 1 TO Len(aParEstoque)

		If aParEstoque[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParEstoque[nX,2])
			nSint := aParEstoque[nX,3]

		    If nX == 1 //Saldo Medio dos Estoques (Conta)

   				nSldMedEst 	:= 0

		    	//buscar saldo inicial do estoque
			    nSldMedEst 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedEst := nSldMedEst / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedEst 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedEst 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedEst := nSldMedEst / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

		    	//Saldo Custo de Vendas (Conta)
				nCustoVendas := 0
			    If nDivide > 1
				    nCustoVendas += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nCustoVendas += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial
			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio dos Estoque
				aResult := {}
				nSldMedEst 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParEstoque[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedEst += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedEst += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedEst := nSldMedEst / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else // Custo das Vendas
		
				aResult := {}
				nCustoVendas := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParEstoque[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
			
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nCustoVendas += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nCustoVendas += aResult[Len(aResult),nEntid]
					EndIf
				EndIf	
								
			EndIf
			
		EndIf
		
	Next
	
	// Calcula o Giro dos Estoques
	// Giro dos Estoques = ( Custo das Vendas / Saldo Medio do Estoque )
	// n Dias => Data Final - Data Inicial
	
	nDias := dDataFim - dDataIni
	If nDias > 0 .And. nSldMedEst <> 0
		nGiroEst := nCustoVendas / nSldMedEst
		aAdd(aRetPainel, { STR0020, Str(nGiroEst, 3),CLR_HBLUE,  } )  //"Giro de Estoques"
	Else
		aAdd(aRetPainel, { STR0019, Str(0,2),CLR_HRED,  } )  //"Giro do Estoque Nao Calculado"
	EndIf	

EndIf

//TERMINO DO GIRO DOS ESTOQUES

//--------------------------------------------------------------------------------//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGIRO DUPLICATAS A RECEBER ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lContinua := .T.

//Valida se conta ou Visao foi preenchida 
// Parametros 13 / 23 ---> Duplicatas a Receber
//            14 / 24 ---> Receita Operacional Bruta
//            15 / 25 ---> Devolucao e Abatimentos

aParCobranca 	:= {}
nGiroCob 		:= 0
nSldMedCob 		:= 0

If Empty(mv_par13) .And. Empty(mv_par23)
	lContinua := .F.
ElseIf Empty(mv_par14) .And. Empty(mv_par24)
	lContinua := .F.
ElseIf Empty(mv_par15) .And. Empty(mv_par25)
	lContinua := .F.
Else
	//CONTA OU VISAO --> DUPLICATAS A RECEBER
	If ! Empty(mv_par13) //procura no plano de contas conta de duplicatas a receber
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par13, Len(CT1->CT1_CONTA))))
			aAdd(aParCobranca, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de duplicatas a receber
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par23, Len(CTS->CTS_CODPLA))))
			aAdd(aParCobranca, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO --> RECEITA OPERACIONAL BRUTA
	If lContinua .And. ! Empty(mv_par14) //procura no plano de contas
										 // receita operacional bruta
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par14, Len(CT1->CT1_CONTA))))
			aAdd(aParCobranca, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao --> RECEITA OPERACIONAL BRUTA
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par24, Len(CTS->CTS_CODPLA))))
			aAdd(aParCobranca, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO --> DEVOLUCOES E ABATIMENTOS
	If lContinua .And. ! Empty(mv_par15) //procura no plano de contas
										 // devolucoes e abatimentos
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par15, Len(CT1->CT1_CONTA))))
			aAdd(aParCobranca, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao --> DEVOLUCOES E ABATIMENTOS
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par25, Len(CTS->CTS_CODPLA))))
			aAdd(aParCobranca, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf

EndIf

If Len(aParCobranca) != 3   //sao 3 contas - Duplicatas a Receber
	lContinua := .F.        //               receita operacional bruta
EndIf                       //                devolucoes e abatimentos
			
If ! lContinua		

	aAdd(aRetPainel, { STR0021, Str(0,2),CLR_HRED,  } )  //"Giro Dupl.Receber Nao Calcul."

Else

	For nX := 1 TO Len(aParCobranca)

		If aParCobranca[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParCobranca[nX,2])
			nSint := aParCobranca[nX,3]

		    If nX == 1 //Saldo Medio das duplicatas a receber

   				nSldMedCob 	:= 0

		    	//buscar saldo inicial das duplicatas a receber
			    nSldMedCob 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedCob := nSldMedCob / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedCob 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedCob 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedCob := nSldMedCob / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

				If nX == 2    	//Receita Operacional Bruta
					nReceitas := 0
				    If nDivide > 1
					    nReceitas += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
					Else
					    nReceitas += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    EndIf
				Else             //devolucao e abatimentos
					nDevolAbat := 0
				    If nDivide > 1
					    nDevolAbat += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
					Else
					    nDevolAbat += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    EndIf
				EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio de duplicatas a receber
				aResult := {}
				nSldMedCob 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParCobranca[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedCob += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedCob += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedCob := nSldMedCob / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else 

		    	If nX == 2 // Custo das Receitas Oper. Brutas e Devol.e Abatimentos
		
					aResult := {}
					nReceitas := 0
					
					// Conteudo de aResult:
					//
					// - aResult[1]					: Codigo da Entidade Gerencial
					// - aResult[2]					: Descricao da Entidade Gerencial
					// - aResult[3]					: .T. para Sintetica; .F. para Analitica
					// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
					//
					aSetOfBook	:= {"","","",0,aParCobranca[nX,2],"","","",1,""}
					CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
					nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
				
				    //aqui aplica o fator de divisao
					For nEntid := 1 to Len( aResult[1] )
					    If nDivide > 1
						   	For nIniValor := 4 to Len( aResult )
								// Dividindo o valor pelo indice informado na pergunta "Divide por"
								aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
				    		Next
				    	EndIf	
					Next
	
					If cTpComp == "M"
						//aqui soma para compor o saldo dos periodos
						For nEntid := 1 to Len( aResult[1] )
						   	For nIniValor := 4 to Len( aResult )
								nReceitas += aResult[nIniValor,nEntid]
			    			Next
						Next
	                Else
                       	nEntid := 1
						If Len(aResult) >= 4  //considera sempre o ultimo saldo
							nReceitas += aResult[Len(aResult),nEntid]
						EndIf
					EndIf
				
				Else

                    //Visao --> Devolucoes e Abatimentos
					aResult := {}
					nDevolAbat := 0
					
					// Conteudo de aResult:
					//
					// - aResult[1]					: Codigo da Entidade Gerencial
					// - aResult[2]					: Descricao da Entidade Gerencial
					// - aResult[3]					: .T. para Sintetica; .F. para Analitica
					// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
					//
					aSetOfBook	:= {"","","",0,aParCobranca[nX,2],"","","",1,""}
					CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
					nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
				
				    //aqui aplica o fator de divisao
					For nEntid := 1 to Len( aResult[1] )
					    If nDivide > 1
						   	For nIniValor := 4 to Len( aResult )
								// Dividindo o valor pelo indice informado na pergunta "Divide por"
								aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
				    		Next
				    	EndIf	
					Next
	
					If cTpComp == "M"
						//aqui soma para compor o saldo dos periodos
						For nEntid := 1 to Len( aResult[1] )
						   	For nIniValor := 4 to Len( aResult )
								nDevolAbat += aResult[nIniValor,nEntid]
			    			Next
						Next
	                Else
	                	nEntid := 1
						If Len(aResult) >= 4  //considera sempre o ultimo saldo
							nDevolAbat += aResult[Len(aResult),nEntid]
						EndIf
					EndIf
				
				EndIf

			EndIf
				
		EndIf
		
	Next
	
	// Calcula o Giro das Duplicatas a Receber
	// Giro das Duplicatas a Receber = Receita Brutas de Vendas a Prazo
	//                                 ------------------------------------
	//                                 Saldo Medio das Duplicatas a Receber

	If nSldMedCob <> 0
		nGiroCob := ( (nReceitas - nDevolAbat) / nSldMedCob )
		aAdd(aRetPainel, { STR0022, Str(nGiroCob, 3),CLR_HBLUE,  } )  //"Giro de Duplicatas a Receber"
	Else
		aAdd(aRetPainel, { STR0021, Str(0,2),CLR_HRED,  } )  //"Giro Dupl.Receber Nao Calcul."
	EndIf	

EndIf

//TERMINO DO GIRO DAS DUPLICATAS A RECEBER

//--------------------------------------------------------------------------------//
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGiro do Ativo Circulante   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Valida se conta ou Visao foi preenchida 
// Parametros 16 / 26 ---> Receita Operacional Liquida
//            17 / 27 ---> Ativo Circulante

aParAtivoCirc 	:= {}
nGiroCirc 		:= 0
nSldMedCirc 	:= 0
nRecOperLiq 	:= 0

If Empty(mv_par16) .And. Empty(mv_par26)
	lContinua := .F.
ElseIf Empty(mv_par17) .And. Empty(mv_par27)
	lContinua := .F.
Else
	//CONTA OU VISAO DE ATIVO CIRCULANTE
	If ! Empty(mv_par17) //procura no plano de contas conta de Ativo Circulante
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par17, Len(CT1->CT1_CONTA))))
			aAdd(aParAtivoCirc, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Ativo Circulante
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par27, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtivoCirc, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO DE RECEITA OPERACIONAL LIQUIDA
	If lContinua .And. ! Empty(mv_par16) //procura no plano de contas conta de Custo de Receita Operacional Liquida
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par16, Len(CT1->CT1_CONTA))))
			aAdd(aParAtivoCirc, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Custo de Vendas
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par26, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtivoCirc, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf

If Len(aParAtivoCirc) != 2 //sao 2 contas Rec.Oper.Liquida e Ativo Circulante
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0023, Str(0,2),CLR_HRED,  } )  //"Giro Ativo Circul.Nao Calculado"

Else

	For nX := 1 TO Len(aParAtivoCirc)

		If aParAtivoCirc[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParAtivoCirc[nX,2])
			nSint := aParAtivoCirc[nX,3]

		    If nX == 1 //Saldo Medio do Ativo Circulante (Conta)

   				nSldMedCirc 	:= 0

		    	//buscar saldo inicial do Ativo Circulante
			    nSldMedCirc 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedCirc := nSldMedCirc / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedCirc 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedCirc 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedCirc := nSldMedCirc / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

		    	//Saldo Receita Operacional Liquida (Conta)
				nRecOperLiq := 0
			    If nDivide > 1
				    nRecOperLiq += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nRecOperLiq += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio do Ativo Circulante
				aResult := {}
				nSldMedCirc 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParAtivoCirc[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedCirc += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedCirc += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedCirc := nSldMedCirc / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else // Receita Operacional Liquida
		
				aResult := {}
				nRecOperLiq := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParAtivoCirc[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
			
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nRecOperLiq += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nRecOperLiq += aResult[Len(aResult),nEntid]
					EndIf
				EndIf	
								
			EndIf
			
		EndIf
		
	Next
	
	// Calcula o Giro do Ativo Circulante
	// Giro do Ativo Circulante =  Receita Operacional Liquida
	//                            -----------------------------------
	//                             Saldo Medio do Ativo Circulante
	
	If nSldMedCirc <> 0
		nGiroCirc := nRecOperLiq / nSldMedCirc
		aAdd(aRetPainel, { STR0024, Str(nGiroCirc, 3),CLR_HBLUE,  } )  //"Giro do Ativo Circulante"
	Else
		aAdd(aRetPainel, { STR0023, Str(0,2),CLR_HRED,  } )  //"Giro Ativo Circul.Nao Calculado"
	EndIf	

EndIf

//TERMINO DO GIRO DO ATIVO CIRCULANTE

//--------------------------------------------------------------------------------//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGiro do Ativo Fixo   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Valida se conta ou Visao foi preenchida 
// Parametros 16 / 26 ---> Receita Operacional Liquida
//            18 / 28 ---> Ativo Fixo

aParAtFixo 		:= {}
nGiroATF 		:= 0
nSldMedATF 	:= 0
nRecOperLiq 	:= 0

If Empty(mv_par16) .And. Empty(mv_par26)
	lContinua := .F.
ElseIf Empty(mv_par18) .And. Empty(mv_par28)
	lContinua := .F.
Else
	//CONTA OU VISAO DE ATIVO FIXO
	If ! Empty(mv_par18) //procura no plano de contas conta de Ativo Fixo
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par18, Len(CT1->CT1_CONTA))))
			aAdd(aParAtFixo, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Ativo Fixo
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par28, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtFixo, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO DE RECEITA OPERACIONAL LIQUIDA
	If lContinua .And. ! Empty(mv_par16) //procura no plano de contas conta de Custo de Receita Operacional Liquida
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par16, Len(CT1->CT1_CONTA))))
			aAdd(aParAtFixo, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Custo de Vendas
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par26, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtFixo, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf

If Len(aParAtFixo) != 2 //sao 2 contas Rec.Oper.Liquida e Ativo Fixo
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0025, Str(0,2),CLR_HRED,  } )  //"Giro Ativo Fixo Nao Calculado"

Else

	For nX := 1 TO Len(aParAtFixo)

		If aParAtFixo[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParAtFixo[nX,2])
			nSint := aParAtFixo[nX,3]

		    If nX == 1 //Saldo Medio do Ativo Fixo (Conta)

   				nSldMedATF 	:= 0

		    	//buscar saldo inicial do Ativo Fixo
			    nSldMedATF 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedATF := nSldMedATF / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedATF 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedATF 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedATF := nSldMedATF / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

		    	//Saldo Receita Operacional Liquida (Conta)
				nRecOperLiq := 0
			    If nDivide > 1
				    nRecOperLiq += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nRecOperLiq += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio do Ativo Fixo
				aResult := {}
				nSldMedATF 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParAtFixo[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedATF += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedATF += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedATF := nSldMedATF / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else // Receita Operacional Liquida
		
				aResult := {}
				nRecOperLiq := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParAtFixo[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
			
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nRecOperLiq += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nRecOperLiq += aResult[Len(aResult),nEntid]
					EndIf
				EndIf	
								
			EndIf
			
		EndIf
		
	Next
	
	// Calcula o Giro do Ativo Fixo
	// Giro do Ativo Fixo =  Receita Operacional Liquida
	//                      -----------------------------------
	//                        Saldo Medio do Ativo Fixo
	
	If nSldMedATF <> 0
		nGiroATF := nRecOperLiq / nSldMedATF
		aAdd(aRetPainel, { STR0026, Str(nGiroATF, 3),CLR_HBLUE,  } )  //"Giro do Ativo Fixo"
	Else
		aAdd(aRetPainel, { STR0025, Str(0,2),CLR_HRED,  } )  //"Giro Ativo Fixo Nao Calculado"
	EndIf	

EndIf

//TERMINO DO GIRO DO ATIVO FIXO

//--------------------------------------------------------------------------------//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGiro do Ativo Operacional   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Valida se conta ou Visao foi preenchida 
// Parametros 16 / 26 ---> Receita Operacional Liquida
//            19 / 29 ---> Ativo Operacional

aParAtvOper 		:= {}
nGiroAtOp 		:= 0
nSldMedAtOp 	:= 0
nRecOperLiq 	:= 0

If Empty(mv_par16) .And. Empty(mv_par26)
	lContinua := .F.
ElseIf Empty(mv_par19) .And. Empty(mv_par29)
	lContinua := .F.
Else
	//CONTA OU VISAO DE ATIVO OPERACIONAL
	If ! Empty(mv_par19) //procura no plano de contas conta de Ativo Operacional
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par19, Len(CT1->CT1_CONTA))))
			aAdd(aParAtvOper, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Ativo Operacional
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par29, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtvOper, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO DE RECEITA OPERACIONAL LIQUIDA
	If lContinua .And. ! Empty(mv_par16) //procura no plano de contas conta de Custo de Receita Operacional Liquida
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par16, Len(CT1->CT1_CONTA))))
			aAdd(aParAtvOper, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Custo de Vendas
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par26, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtvOper, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf

If Len(aParAtvOper) != 2 //sao 2 contas Rec.Oper.Liquida e Ativo Operacional
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0027, Str(0,2),CLR_HRED,  } )  //"Giro At.Operacional Nao Calc."

Else

	For nX := 1 TO Len(aParAtvOper)

		If aParAtvOper[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParAtvOper[nX,2])
			nSint := aParAtvOper[nX,3]

		    If nX == 1 //Saldo Medio do Ativo Operacional (Conta)

   				nSldMedAtOp 	:= 0

		    	//buscar saldo inicial do Ativo Operacional
			    nSldMedAtOp 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedAtOp := nSldMedAtOp / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedAtOp 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedAtOp 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedAtOp := nSldMedAtOp / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

		    	//Saldo Receita Operacional Liquida (Conta)
				nRecOperLiq := 0
			    If nDivide > 1
				    nRecOperLiq += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nRecOperLiq += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio do Ativo Operacional
				aResult := {}
				nSldMedAtOp 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParAtvOper[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedAtOp += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedAtOp += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedAtOp := nSldMedAtOp / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else // Receita Operacional Liquida
		
				aResult := {}
				nRecOperLiq := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParAtvOper[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
			
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nRecOperLiq += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nRecOperLiq += aResult[Len(aResult),nEntid]
					EndIf
				EndIf	
								
			EndIf
			
		EndIf
		
	Next
	
	// Calcula o Giro do Ativo Operacional
	// Giro do Ativo Operacional =  Receita Operacional Liquida
	//                             -----------------------------------
	//                              Saldo Medio do Ativo Operacional
	
	If nSldMedAtOp <> 0
		nGiroAtOp := nRecOperLiq / nSldMedAtOp
		aAdd(aRetPainel, { STR0028, Str(nGiroAtOp, 3),CLR_HBLUE,  } )  //"Giro do Ativo Operacional"
	Else
		aAdd(aRetPainel, { STR0027, Str(0,2),CLR_HRED,  } )  //"Giro At.Operacional Nao Calc."
	EndIf	

EndIf

//TERMINO DO GIRO DO ATIVO OPERACIONAL

//--------------------------------------------------------------------------------//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGiro do Investimento Total  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Valida se conta ou Visao foi preenchida 
// Parametros 16 / 26 ---> Receita Operacional Liquida
//            20 / 30 ---> Ativo Total

aParAtvTotal 	:= {}
nGiroAtTotal 	:= 0
nSldMedTotal 	:= 0
nRecOperLiq 	:= 0

If Empty(mv_par16) .And. Empty(mv_par26)
	lContinua := .F.
ElseIf Empty(mv_par20) .And. Empty(mv_par30)
	lContinua := .F.
Else
	//CONTA OU VISAO DE ATIVO TOTAL
	If ! Empty(mv_par20) //procura no plano de contas conta de Ativo Total
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par20, Len(CT1->CT1_CONTA))))
			aAdd(aParAtvTotal, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Ativo Total
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par30, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtvTotal, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO DE RECEITA OPERACIONAL LIQUIDA
	If lContinua .And. ! Empty(mv_par16) //procura no plano de contas conta de Receita Operacional Liquida
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par16, Len(CT1->CT1_CONTA))))
			aAdd(aParAtvTotal, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Rec.Oper.Liquida
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par26, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtvTotal, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf

If Len(aParAtvTotal) != 2 //sao 2 contas Rec.Oper.Liquida e Ativo Total
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0029, Str(0,2),CLR_HRED,  } )  //"Giro Ativo Total Nao Calc."

Else

	For nX := 1 TO Len(aParAtvTotal)

		If aParAtvTotal[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParAtvTotal[nX,2])
			nSint := aParAtvTotal[nX,3]

		    If nX == 1 //Saldo Medio do Ativo Total (Conta)

   				nSldMedTotal 	:= 0

		    	//buscar saldo inicial do Ativo Total
			    nSldMedTotal 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedTotal := nSldMedTotal / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedTotal 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedTotal 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedTotal := nSldMedTotal / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

		    	//Saldo Receita Operacional Liquida (Conta)
				nRecOperLiq := 0
			    If nDivide > 1
				    nRecOperLiq += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nRecOperLiq += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio do Ativo Total
				aResult := {}
				nSldMedTotal 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParAtvTotal[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedTotal += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedTotal += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedTotal := nSldMedTotal / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else // Receita Operacional Liquida
		
				aResult := {}
				nRecOperLiq := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParAtvTotal[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
			
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nRecOperLiq += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nRecOperLiq += aResult[Len(aResult),nEntid]
					EndIf
				EndIf	
								
			EndIf
			
		EndIf
		
	Next
	
	// Calcula o Giro do Investimento Total
	// Giro do Investimento Total =   Receita Operacional Liquida
	//                               -----------------------------------
	//                                Saldo Medio do Ativo Total
	
	If nSldMedTotal <> 0
		nGiroAtTotal := nRecOperLiq / nSldMedTotal
		aAdd(aRetPainel, { STR0030, Str(nGiroAtTotal, 3),CLR_HBLUE,  } )  //"Giro do Investimento Total"
	Else
		aAdd(aRetPainel, { STR0029, Str(0,2),CLR_HRED,  } )  //"Giro At.Total Nao Calc."
	EndIf	

EndIf

//TERMINO DO GIRO DO INVESTIMENTO TOTAL

//--------------------------------------------------------------------------------//

RestArea(aSaveArea)

Return aRetPainel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ CtRentab    ณAutor  ณDaniel Tadashi Batori   ณ Data ณ  28/03/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao chamada pelo painel online para mostrar as                บฑฑ
ฑฑบ          | Margens de Rentabilidade                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtRentab()		//	Painel de Margens de Rentabilidade

Local oMeter,oText,oDlg,lEnd

Local aSaveArea  := GetArea()
Local aResult
Local aRetPainel := {}
Local aConta     := {}

Local dData
Local dDataLP

Local lImpAntLP
Local lContinua  := .T.

Local cMoeda
Local cTpSaldo
Local cConta

Local nX
Local nSint
Local nEntid
Local nIniValor
Local nMargBruta
Local nMargOper
Local nMargLiqu
Local nMarkGlob

Pergunte( "CTBPGL100",.F. )
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros                       ณ
//ณ mv_par01         // Data para pegar os saldos              ณ
//ณ mv_par02         // Lucro Bruto (Conta)                    ณ
//ณ mv_par03         // Lucro Operacional (Conta)              ณ
//ณ mv_par04         // Lucro Lํquido (Conta)                  ณ
//ณ mv_par05         // Receita Operacional (Conta)            ณ
//ณ mv_par06         // Custo das Vendas (Conta)               ณ
//ณ mv_par07         // Lucro Bruto (Visใo Ger.)               ณ
//ณ mv_par08         // Lucro Operacional (Visao Ger.)         ณ
//ณ mv_par09         // Lucro Liquido (Visใo Ger.)             ณ
//ณ mv_par10         // Receita Operacional (Visใo Ger.)       ณ
//ณ mv_par11         // Custo das Vendas (Visใo Ger.)          ณ
//ณ mv_par12         // Moeda?                                 ณ
//ณ mv_par13         // Tipo de Saldo?                         ณ
//ณ mv_par14         // Posicao Ant. L/P? Sim / Nao            ณ
//ณ mv_par15         // Data Lucros/Perdas?                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dData     := mv_par01
cMoeda    := mv_par12
cTpSaldo  := mv_par13
lImpAntLP := (mv_par14==1)
dDataLP   := mv_par15

dbSelectArea("CT1")
dbSetOrder(1)

dbSelectArea("CTS")
dbSetOrder(1)

//
// Valida se Conta ou Visao foi preenchida
//
lContinua	:=	( !Empty(mv_par02) .Or. !Empty(mv_par07) ) .And.;
				( !Empty(mv_par03) .Or. !Empty(mv_par08) ) .And.;
				( !Empty(mv_par04) .Or. !Empty(mv_par09) ) .And.;
				( !Empty(mv_par05) .Or. !Empty(mv_par10) ) .And.;
				( !Empty(mv_par06) .Or. !Empty(mv_par11) ) .And.;
				!Empty(cMoeda)

//
// Valida se a Conta e/ou a Visao existem no respectivo cadastro
//
If lContinua
	ExisteConta( mv_par02,mv_par07,@lContinua,@aConta )		//	Conta ou Visao do Lucro Bruto
	ExisteConta( mv_par03,mv_par08,@lContinua,@aConta )		//	Conta ou Visao do Lucro Operacional
	ExisteConta( mv_par04,mv_par09,@lContinua,@aConta )		//	Conta ou Visao do Lucro Liquido
	ExisteConta( mv_par05,mv_par10,@lContinua,@aConta )		//	Conta ou Visao do Receita Operacional
	ExisteConta( mv_par06,mv_par11,@lContinua,@aConta )		//	Conta ou Visao do Custo das Vendas

	lContinua := ( Len(aConta) == 5 )	//	sao 5 contas
    
	If lContinua
	
		For nX := 1 to Len(aConta)
	
			If aConta[nX, 1] == 1	//	Conta Contabil
	
				cConta := Alltrim(aConta[nX,2])
				nSint  := aConta[nX,3]
	
		    	// Buscar Saldo da Conta
				aConta[nX,4] += MovConta(cConta,dData,dData,cMoeda,cTpSaldo,4,nSint,lImpAntLP,dDataLP)
	
			Else	//	Visao Gerencial
			
				aResult := {}
	
				// Conteudo de aResult:
				// - aResult[1]                : Codigo da Entidade Gerencial
				// - aResult[2]                : Descricao da Entidade Gerencial
				// - aResult[3]                : .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n] : Valores referentes ao(s) periodo(s)
				//
				aSetOfBook	:= {"","","",0,aConta[nX,2],"","","",1,""}
	
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dData,dData,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,;
				            .T./*Valor Zerado*/,.F.,,.T.,Nil,.T./*Cons.Sintetica*/,"S"/*Saldo Acumulado*/,.T.,@aResult,cTpSaldo )
	
				// "Joga" o saldo da conta em aConta
				For nEntid := 1 to Len( aResult[1] )
					For nIniValor := 4 to Len( aResult )
						aConta[nX,4] += aResult[nIniValor,nEntid]
			    	Next
				Next
	
	        EndIf
		Next
	
		// Calculando
		//	aConta[1,4] = Conta ou Visao do Lucro Bruto
		//	aConta[2,4] = Conta ou Visao do Lucro Operacional
		//	aConta[3,4] = Conta ou Visao do Lucro Liquido
		//	aConta[4,4] = Conta ou Visao do Receita Operacional
		//	aConta[5,4] = Conta ou Visao do Custo das Vendas
		//
	
		// Margem Bruta       -> Formula: ( Lucro Bruto / Receita Operacional Liquida )
		nMargBruta := aConta[1,4] / aConta[4,4]
	
		// Margem Operacional -> Formula: ( Lucro Operacional / Receita Operacional Liquida )
		nMargOper  := aConta[2,4] / aConta[4,4]
	
		// Margem Liquida     -> Formula: ( Lucro Liquido / Receita Operacional Liquida )
		nMargLiqu  := aConta[3,4] / aConta[4,4]
	
		// Mark-up Global     -> Formula: ( Lucro Bruto / Custo das Vendas )
		nMarkGlob  := aConta[1,4] / aConta[5,4]

		aAdd(aRetPainel, { STR0031 /*"Margem Bruta"*/      , Transf( nMargBruta, "@E 999,999.99" ), CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0032 /*"Margem Operacional"*/, Transf( nMargOper , "@E 999,999.99" ), CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0033 /*"Margem Liquida" */   , Transf( nMargLiqu , "@E 999,999.99" ), CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0034 /*"Mark-up Global"  */  , Transf( nMarkGlob , "@E 999,999.99" ), CLR_HBLUE, } )

	Else
		aAdd(aRetPainel, { STR0035 /*"Verifique os parametros"*/, "0", CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0036 /*"informados"*/             , "0", CLR_HBLUE, } )
	EndIf
Else
	aAdd(aRetPainel, { STR0035 /*"Verifique os parametros "*/, "0", CLR_HBLUE, } )
	aAdd(aRetPainel, { STR0036 /*"informados"*/              , "0", CLR_HBLUE, } )
EndIf

RestArea(aSaveArea)

Return aRetPainel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ CtSolv      ณAutor  ณDaniel Tadashi Batori   ณ Data ณ  29/03/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao chamada pelo painel online para mostrar os                บฑฑ
ฑฑบ          | Indices de Solvencia                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtSolv()		//	Painel de Indices de Solvencia

Local oMeter,oText,oDlg,lEnd

Local aSaveArea  := GetArea()
Local aResult
Local aRetPainel := {}
Local aConta     := {}

Local dData
Local dDataLP

Local lImpAntLP
Local lContinua  := .T.

Local cMoeda
Local cTpSaldo
Local cConta

Local nX
Local nSint
Local nEntid
Local nIniValor
Local nLiqGeral
Local nLiqCorr
Local nLiqSeca

Pergunte( "CTBPGL120",.F. )
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros                       ณ
//ณ mv_par01         // Data para pegar os saldos              ณ
//ณ mv_par02         // At. Circulante (Conta)                 ณ
//ณ mv_par03         // Pas. Circulante (Conta)                ณ
//ณ mv_par04         // Realiz. Longo Prazo (Conta)            ณ
//ณ mv_par05         // Exig. Longo Prazo (Conta)              ณ
//ณ mv_par06         // Estoque (Conta)                        ณ
//ณ mv_par07         // Desp. Ex. Seguinte (Conta)             ณ
//ณ mv_par08         // At. Circulante (Visao Ger.)            ณ
//ณ mv_par09         // Pas. Circulante (Visao Ger.)           ณ
//ณ mv_par10         // Realiz. Longo Prazo (Visao Ger.)       ณ
//ณ mv_par11         // Exig. Longo Prazo (Visao Ger.)         ณ
//ณ mv_par12         // Estoque (Visao Ger.)                   ณ
//ณ mv_par13         // Desp. Ex. Seguinte (Visao Ger.)        ณ
//ณ mv_par14         // Moeda?                                 ณ
//ณ mv_par15         // Tipo de Saldo?                         ณ
//ณ mv_par16         // Posicao Ant. L/P? Sim / Nao            ณ
//ณ mv_par17         // Data Lucros/Perdas?                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dData     := mv_par01
cMoeda    := mv_par14
cTpSaldo  := mv_par15
lImpAntLP := (mv_par16==1)
dDataLP   := mv_par17

dbSelectArea("CT1")
dbSetOrder(1)

dbSelectArea("CTS")
dbSetOrder(1)

//
// Valida se Conta ou Visao foi preenchida
//
lContinua	:=	( !Empty(mv_par02) .Or. !Empty(mv_par08) ) .And.;
				( !Empty(mv_par03) .Or. !Empty(mv_par09) ) .And.;
				( !Empty(mv_par04) .Or. !Empty(mv_par10) ) .And.;
				( !Empty(mv_par05) .Or. !Empty(mv_par11) ) .And.;
				( !Empty(mv_par06) .Or. !Empty(mv_par12) ) .And.;
				( !Empty(mv_par07) .Or. !Empty(mv_par13) ) .And.;
				!Empty(cMoeda)

//
// Valida se a Conta e/ou a Visao existem no respectivo cadastro
//
If lContinua
	ExisteConta( mv_par02,mv_par08,@lContinua,@aConta )		//	Conta ou Visao do At. Circulante
	ExisteConta( mv_par03,mv_par09,@lContinua,@aConta )		//	Conta ou Visao do Pas. Circulante
	ExisteConta( mv_par04,mv_par10,@lContinua,@aConta )		//	Conta ou Visao do Realiz. Longo Prazo
	ExisteConta( mv_par05,mv_par11,@lContinua,@aConta )		//	Conta ou Visao do Exig. Longo Prazo
	ExisteConta( mv_par06,mv_par12,@lContinua,@aConta )		//	Conta ou Visao do Estoque
	ExisteConta( mv_par07,mv_par13,@lContinua,@aConta )		//	Conta ou Visao do Desp. Ex. Seguinte

	lContinua := ( Len(aConta) == 6 )	//	sao 6 contas
    
	If lContinua
	
		For nX := 1 to Len(aConta)
	
			If aConta[nX, 1] == 1	//	Conta Contabil
	
				cConta := Alltrim(aConta[nX,2])
				nSint  := aConta[nX,3]
	
		    	// Buscar Saldo da Conta
				aConta[nX,4] += MovConta(cConta,dData,dData,cMoeda,cTpSaldo,4,nSint,lImpAntLP,dDataLP)
	
			Else	//	Visao Gerencial
			
				aResult := {}
	
				// Conteudo de aResult:
				// - aResult[1]                : Codigo da Entidade Gerencial
				// - aResult[2]                : Descricao da Entidade Gerencial
				// - aResult[3]                : .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n] : Valores referentes ao(s) periodo(s)
				//
				aSetOfBook	:= {"","","",0,aConta[nX,2],"","","",1,""}
	
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dData,dData,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,;
				            .T./*Valor Zerado*/,.F.,,.T.,Nil,.T./*Cons.Sintetica*/,"S"/*Saldo Acumulado*/,.T.,@aResult,cTpSaldo )
	
				// "Joga" o saldo da conta em aConta
				For nEntid := 1 to Len( aResult[1] )
					For nIniValor := 4 to Len( aResult )
						aConta[nX,4] += aResult[nIniValor,nEntid]
			    	Next
				Next
	
	        EndIf
		Next
	
		// Calculando
		//	aConta[1,4] = Conta ou Visao do At. Circulante
		//	aConta[2,4] = Conta ou Visao do Pas. Circulante
		//	aConta[3,4] = Conta ou Visao do Realiz. Longo Prazo
		//	aConta[4,4] = Conta ou Visao do Exig. Longo Prazo
		//	aConta[5,4] = Conta ou Visao do Estoque
		//	aConta[6,4] = Conta ou Visao do Desp. Ex. Seguinte
		//
	
		// Liquidez Geral    -> Formula: ( (At. Circulante+Realiz. Longo Prazo) / (Pas. Circulante+Exig. Longo Prazo) )
		nLiqGeral := (aConta[1,4]+aConta[3,4]) / (aConta[2,4]+aConta[4,4])
	
		// Liquidez Corrente -> Formula: ( At. Circulante / Pas. Circulante )
		nLiqCorr  := aConta[1,4] / aConta[2,4]
	
		// Liquidez Seca     -> Formula: ( (At. Circulante-Estoque-Desp. Ex. Seguinte) / Pas. Circulante )
		nLiqSeca  := (aConta[1,4]-aConta[5,4]-aConta[6,4]) / aConta[2,4]
	

		aAdd(aRetPainel, { STR0037 /*"Liquidez Geral"*/   , Transf( nLiqGeral, "@E 999,999.99" ), CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0038 /*"Liquidez Corrente"*/, Transf( nLiqCorr , "@E 999,999.99" ), CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0039 /*"Liquidez Seca" */   , Transf( nLiqSeca , "@E 999,999.99" ), CLR_HBLUE, } )

	Else
		aAdd(aRetPainel, { STR0035 /*"Verifique os parametros"*/, "0", CLR_HBLUE, } )
		aAdd(aRetPainel, { STR0036 /*"informados"*/             , "0", CLR_HBLUE, } )
	EndIf
Else
	aAdd(aRetPainel, { STR0035 /*"Verifique os parametros "*/, "0", CLR_HBLUE, } )
	aAdd(aRetPainel, { STR0036 /*"informados"*/              , "0", CLR_HBLUE, } )
EndIf

RestArea(aSaveArea)

Return aRetPainel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbTxRetorno  ณAutor  ณPaulo Carnelossi      ณ Data ณ  23/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama a funcao CtbPlGerCm() para calcular o saldo de todas as    บฑฑ
ฑฑบ          ณ Entidades da Visao Gerencial informada. Esse saldo sera          บฑฑ
ฑฑบ          ณ referente a todos os periodos do calendario que estiverem dentro บฑฑ
ฑฑบ          ณ do intervalo de datas informado.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROTHEUS 9                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CtbTxRetorno()

Local oMeter,oText,oDlg,lEnd

Local aSaveArea		:= GetArea()
Local aMeses		:= {}
Local aPeriodos
Local aSetOfBook
Local aResult		:= {}
Local aRetPainel

Local dDataIni
Local dDataFim

Local lImpAntLP
Local lVlrZerado

Local cTpComp
Local cMoeda
Local cCalend
Local cSaldo

Local nCont
Local nEntid
Local nIniValor
Local nDecimais
Local nDivide		:= 1

Local nY, nX, lContinua := .T., cConta, nSint, aMesAux
Local aParAtvOper 	:= {}, nTxRetAtOp	, nSldMedAtOp	, nLucroOper
Local aParAtvTotal 	:= {}, nGiroAtTotal	, nSldMedTotal
Local aParPatrimLiq 	:= {}, nRetPatrLiq, nSldMedPatrLiq

Pergunte( "CTBPGL110",.F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros					  	      	ณ
//ณ mv_par01				// Data Inicial              	          	ณ
//ณ mv_par02				// Data Final                             	ณ
//ณ mv_par03 				// Exibir Saldos Zerados?                  	ณ
//ณ mv_par04 				// Moeda?          			     	      	ณ
//ณ mv_par05 				// Calendario?			 					ณ
//ณ mv_par06 				// Tipo de Saldo?							ณ
//ณ mv_par07 				// Divide por ?                   		 	ณ
//ณ mv_par08 				// Posicao Ant. L/P? Sim / Nao         	 	ณ
//ณ mv_par09 				// Data Lucros/Perdas?                 	 	ณ
//ณ mv_par10 				// Considerar? Mov. Periodo/Saldo Acumulado	ณ
//| mv_par11				// Ativo Total          (Conta)				|
//| mv_par12				// Ativo Operacional    (Conta)				|
//| mv_par13				// Patrimonio Liquido   (Conta)				|
//| mv_par14				// Lucro Operacional    (Conta)				|
//| mv_par15				// Lucro Liquido        (Conta)				|
//| mv_par16				// Ativo Total          (Visao Ger)			|
//| mv_par17				// Ativo Operacional    (Visao Ger)			|
//| mv_par18				// Patrimonio Liquido   (Visao Ger)			|
//| mv_par19				// Lucro Operacional    (Visao Ger)			|
//| mv_par20				// Lucro Liquido        (Visao Ger)			|
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dDataIni	:= mv_par01
dDataFim	:= mv_par02
lImpSint	:= .T.
lVlrZerado	:= (mv_par03==1)
cMoeda		:= mv_par04
cCalend		:= AllTrim(mv_par05)
cSaldo		:= mv_par06
lImpAntLP	:= (mv_par08==1)
dDataLP		:= mv_par09
cTpComp		:= If(mv_par10==1,"M","S" )	//	Considerar : "M"ovimento ou "S"aldo Acumulado

aPeriodos := CtbPeriodos( cMoeda,dDataIni,dDataFim,.T.,.F.,cCalend )

For nCont := 1 to Len(aPeriodos)
	// Se a data do periodo do calendario esta dentro do intervalo de datas informado nas perguntas
	If aPeriodos[nCont][1] >= dDataIni .And. aPeriodos[nCont][2] <= dDataFim
		AADD( aMeses,{ StrZero(Len(aMeses)+1,2), aPeriodos[nCont][1], aPeriodos[nCont][2] } )
	EndIf
Next

If Len( aMeses ) == 0
	Return {}	
EndIf

If mv_par07 == 2
	nDivide := 100			//	Divide por cem
ElseIf mv_par07 == 3
	nDivide := 1000			//	Divide por mil
ElseIf mv_par07 == 4
	nDivide := 1000000		//  Divide por milhao
EndIf	

dbSelectArea("CT1")
dbSetOrder(1)
dbSelectArea("CTS")
dbSetOrder(1)

aRetPainel := {}

//--------------------------------------------------------------------------------//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorno do Ativo Operacional ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Valida se conta ou Visao foi preenchida 
// Parametros 12 / 17 ---> Ativo Operacional
//            14 / 19 ---> Lucro Operacional

aParAtvOper 	:= {}
nTxRetAtOp 		:= 0
nSldMedAtOp 	:= 0
nLucroOper 	:= 0
lContinua := .T.

If Empty(mv_par14) .And. Empty(mv_par19)
	lContinua := .F.
ElseIf Empty(mv_par12) .And. Empty(mv_par17)
	lContinua := .F.
Else
	//CONTA OU VISAO DE ATIVO OPERACIONAL
	If ! Empty(mv_par12) //procura no plano de contas conta de Ativo Operacional
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par12, Len(CT1->CT1_CONTA))))
			aAdd(aParAtvOper, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Ativo Operacional
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par17, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtvOper, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO DE LUCRO OPERACIONAL
	If lContinua .And. ! Empty(mv_par14) //procura no plano de contas conta de Lucro Operacional
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par14, Len(CT1->CT1_CONTA))))
			aAdd(aParAtvOper, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Lucro Operacional
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par19, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtvOper, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf

If Len(aParAtvOper) != 2 //sao 2 Lucro Operacional e Ativo Operacional
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0040, Str(0,2),CLR_HRED,  } )  //"Ret. s/At.Operacional Nao Calc."

Else

	For nX := 1 TO Len(aParAtvOper)

		If aParAtvOper[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParAtvOper[nX,2])
			nSint := aParAtvOper[nX,3]

		    If nX == 1 //Saldo Medio do Ativo Operacional (Conta)

   				nSldMedAtOp 	:= 0

		    	//buscar saldo inicial do Ativo Operacional
			    nSldMedAtOp 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedAtOp := nSldMedAtOp / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedAtOp 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedAtOp 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedAtOp := nSldMedAtOp / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

		    	//Saldo Lucro Operacional (Conta)
				nLucroOper := 0
			    If nDivide > 1
				    nLucroOper += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nLucroOper += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio do Ativo Operacional
				aResult := {}
				nSldMedAtOp 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParAtvOper[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedAtOp += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedAtOp += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedAtOp := nSldMedAtOp / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else // Lucro Operacional
		
				aResult := {}
				nLucroOper := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParAtvOper[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
			
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nLucroOper += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nLucroOper += aResult[Len(aResult),nEntid]
					EndIf
				EndIf	
								
			EndIf
			
		EndIf
		
	Next
	
	// Calcula o Retorno sobre o Ativo Operacional
	// Retorno sobre o Ativo Operacional =  	Lucro Operacional
	//                             			-----------------------------------
	//                              			Saldo Medio do Ativo Operacional
	
	If nSldMedAtOp <> 0
		nTxRetAtOp := nLucroOper / nSldMedAtOp
		aAdd(aRetPainel, { STR0041, Str(nTxRetAtOp, 3),CLR_HBLUE,  } )  //"Retorno s/ Ativo Operacional"
	Else
		aAdd(aRetPainel, { STR0040, Str(0,2),CLR_HRED,  } ) //"Ret. s/At.Operacional Nao Calc."
	EndIf	

EndIf

//TERMINO RETORNO SOBRE O ATIVO OPERACIONAL

//--------------------------------------------------------------------------------//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorno Sobre o Investimento Total  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Valida se conta ou Visao foi preenchida 
// Parametros 11 / 16 ---> Ativo Total
//            15 / 20 ---> Lucro Liquido

aParAtvTotal 	:= {}
nGiroAtTotal 	:= 0
nSldMedTotal 	:= 0
nLucroLiq 	:= 0
lContinua := .T.

If Empty(mv_par11) .And. Empty(mv_par16)
	lContinua := .F.
ElseIf Empty(mv_par15) .And. Empty(mv_par20)
	lContinua := .F.
Else
	//CONTA OU VISAO DE ATIVO TOTAL
	If ! Empty(mv_par11) //procura no plano de contas conta de Ativo Total
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par11, Len(CT1->CT1_CONTA))))
			aAdd(aParAtvTotal, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Ativo Total
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par16, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtvTotal, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO DE LUCRO LIQUIDO
	If lContinua .And. ! Empty(mv_par15) //procura no plano de contas conta de Lucro Liquido
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par15, Len(CT1->CT1_CONTA))))
			aAdd(aParAtvTotal, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Lucro Liquido
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par20, Len(CTS->CTS_CODPLA))))
			aAdd(aParAtvTotal, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf

If Len(aParAtvTotal) != 2 //sao 2 contas Ativo Total e Lucro Liquido
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0042, Str(0,2),CLR_HRED,  } )   //"Ret.s/Invest.Total Nao Calc."

Else

	For nX := 1 TO Len(aParAtvTotal)

		If aParAtvTotal[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParAtvTotal[nX,2])
			nSint := aParAtvTotal[nX,3]

		    If nX == 1 //Saldo Medio do Ativo Total (Conta)

   				nSldMedTotal 	:= 0

		    	//buscar saldo inicial do Ativo Total
			    nSldMedTotal 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedTotal := nSldMedTotal / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedTotal 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedTotal 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedTotal := nSldMedTotal / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

		    	//Saldo Lucro Liquido (Conta)
				nLucroLiq := 0
			    If nDivide > 1
				    nLucroLiq += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nLucroLiq += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio do Ativo Total
				aResult := {}
				nSldMedTotal 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParAtvTotal[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedTotal += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedTotal += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedTotal := nSldMedTotal / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else 
		    	// Visao Lucro Liquido
		
				aResult := {}
				nLucroLiq := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParAtvTotal[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
			
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nLucroLiq += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nLucroLiq += aResult[Len(aResult),nEntid]
					EndIf
				EndIf	
								
			EndIf
			
		EndIf
		
	Next
	
	// Calcula o Retorno do Investimento Total
	// Retorno sobre o investimento total =      Lucro Liquido
	//                               		-----------------------------------
	//                                			Saldo Medio do Ativo Total
	
	If nSldMedTotal <> 0
		nGiroAtTotal := nLucroLiq / nSldMedTotal
		aAdd(aRetPainel, { STR0043, Str(nGiroAtTotal, 3),CLR_HBLUE,  } )  //"Retorno s/Investimento Total"
	Else
		aAdd(aRetPainel, { STR0042, Str(0,2),CLR_HRED,  } )  //"Ret.s/Invest.Total Nao Calc."
	EndIf	

EndIf

//TERMINO DO RETORNO SOBRE INVESTIMENTO TOTAL

//--------------------------------------------------------------------------------//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorno sobre o Capital Proprio ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Valida se conta ou Visao foi preenchida 
// Parametros 13 / 18 ---> Patrimonio Liquido
//            15 / 20 ---> Lucro Liquido

aParPatrimLiq 	:= {}
nRetPatrLiq 	:= 0
nSldMedPatrLiq 	:= 0
nLucroLiq 	:= 0
lContinua := .T.

If Empty(mv_par13) .And. Empty(mv_par18)
	lContinua := .F.
ElseIf Empty(mv_par15) .And. Empty(mv_par20)
	lContinua := .F.
Else
	//CONTA OU VISAO DE PATRIMONIO LIQUIDO
	If ! Empty(mv_par13) //procura no plano de contas conta de Patrimonio Liquido
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par13, Len(CT1->CT1_CONTA))))
			aAdd(aParPatrimLiq, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Patrimonio Liquido
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par18, Len(CTS->CTS_CODPLA))))
			aAdd(aParPatrimLiq, {2, CTS->CTS_CODPLA, NIL})
		Else
			lContinua := .F.
		EndIf
	EndIf

	//CONTA OU VISAO DE LUCRO LIQUIDO
	If lContinua .And. ! Empty(mv_par15) //procura no plano de contas conta de Lucro Liquido
		If CT1->(dbSeek(xFilial("CT1")+PadR(mv_par15, Len(CT1->CT1_CONTA))))
			aAdd(aParPatrimLiq, {1, CT1->CT1_CONTA, If(CT1->CT1_CLASSE=="1",1,0)})
		Else
			lContinua := .F.
		EndIf
	Else   //procura na visao gerencial a visao de Lucro Liquido
		If CTS->(dbSeek(xFilial("CTS")+PadR(mv_par20, Len(CTS->CTS_CODPLA))))
			aAdd(aParPatrimLiq, {2, CTS->CTS_CODPLA, NIL })
		Else
			lContinua := .F.
		EndIf
	EndIf
EndIf

If Len(aParPatrimLiq) != 2 //sao 2 contas Patrimonio Liquido e Lucro Liquido
	lContinua := .F.
EndIf
			
If ! lContinua		

	aAdd(aRetPainel, { STR0044, Str(0,2),CLR_HRED,  } )    //"Ret.s/Capital Proprio Nao Calc."

Else

	For nX := 1 TO Len(aParPatrimLiq)

		If aParPatrimLiq[nX, 1] == 1  //por conta

			//Para buscar saldo de conta do plano de contas
			cConta := Alltrim(aParPatrimLiq[nX,2])
			nSint := aParPatrimLiq[nX,3]

		    If nX == 1 //Saldo Medio do Ativo Total (Conta)

   				nSldMedPatrLiq 	:= 0

		    	//buscar saldo inicial do Patrimonio Liquido
			    nSldMedPatrLiq 	+= MovConta(cConta,FirstDay(dDataIni-1),dDataIni-1,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    
			    If nDivide > 1
			    	nSldMedPatrLiq := nSldMedPatrLiq / nDivide
			    EndIf
			    
			    If nDivide > 1
				    For nY := 1 TO Len(aMeses)
					    nSldMedPatrLiq 	+= (MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				    Next
				Else
				    For nY := 1 TO Len(aMeses)
					    nSldMedPatrLiq 	+= MovConta(cConta,aMeses[nY, 2],aMeses[nY, 3],cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
				    Next
			    EndIf
			    
			    //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedPatrLiq := nSldMedPatrLiq / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		    
		    Else

		    	//Saldo Lucro Liquido (Conta)
				nLucroLiq := 0
			    If nDivide > 1
				    nLucroLiq += (MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP) / nDivide )
				Else
				    nLucroLiq += MovConta(cConta,dDAtaIni,dDataFim,cMoeda,cSaldo,If(cTpComp=="M",3,4),nSint,lImpAntLP,dDataLP)
			    EndIf
		    	
		    EndIf
		    
		Else //por visao gerencial

			//Para buscar saldo da visao gerencial
			If nX == 1 //Saldo Medio do Patrimonio Liquido
				aResult := {}
				nSldMedPatrLiq 	:= 0
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
		        //saldo inicial = dDataIni - 1
				aSetOfBook	:= {"","","",0,aParPatrimLiq[nX,2],"","","",1,""}
				aMesAux := { { "01", FirstDay(dDataIni-1), dDataIni-1 } }
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,FirstDay(dDataIni-1),dDataIni-1,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMesAux,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )

				//aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo inicial
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedPatrLiq += aResult[nIniValor,nEntid]
		    		Next
				Next
		
				//agora pega os saldos dos periodos do calendario
				aResult := {}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )

			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next
				
				//aqui soma para compor o saldo dos periodos seguintes
				For nEntid := 1 to Len( aResult[1] )
				   	For nIniValor := 4 to Len( aResult )
						nSldMedPatrLiq += aResult[nIniValor,nEntid]
		    		Next
				Next
		
		        //apos acumular o valor divide pela qtde de periodos envolvidos
				nSldMedPatrLiq := nSldMedPatrLiq / (Len(aMeses)+1)   //+1 refere-se ao saldo inicial
		
		    Else 
		    	// Visao Lucro Liquido
		
				aResult := {}
				nLucroLiq := 0
				
				// Conteudo de aResult:
				//
				// - aResult[1]					: Codigo da Entidade Gerencial
				// - aResult[2]					: Descricao da Entidade Gerencial
				// - aResult[3]					: .T. para Sintetica; .F. para Analitica
				// - aResult[4] ate aResult[n]	: Valores referentes aos periodos do calendario
				//
				aSetOfBook	:= {"","","",0,aParPatrimLiq[nX,2],"","","",1,""}
				CtbPlGerCm( oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"","",lImpAntLP,dDataLP,lVlrZerado,.F.,,.T.,aMeses,lImpSint,cTpComp,.T.,@aResult,cSaldo )
				nDecimais  := DecimalCTB( aSetOfBook,cMoeda )
			
			    //aqui aplica o fator de divisao
				For nEntid := 1 to Len( aResult[1] )
				    If nDivide > 1
					   	For nIniValor := 4 to Len( aResult )
							// Dividindo o valor pelo indice informado na pergunta "Divide por"
							aResult[nIniValor,nEntid] := aResult[nIniValor,nEntid] / nDivide
			    		Next
			    	EndIf	
				Next

				If cTpComp == "M"
					//aqui soma para compor o saldo dos periodos
					For nEntid := 1 to Len( aResult[1] )
					   	For nIniValor := 4 to Len( aResult )
							nLucroLiq += aResult[nIniValor,nEntid]
		    			Next
					Next
                Else
                	nEntid := 1
					If Len(aResult) >= 4  //considera sempre o ultimo saldo
						nLucroLiq += aResult[Len(aResult),nEntid]
					EndIf
				EndIf	
								
			EndIf
			
		EndIf
		
	Next
	
	// Calcula o Retorno sobre o Capital Proprio
	// Retorno sobre o capital proprio =                 Lucro Liquido
	//                               		-----------------------------------------
	//                                			Saldo Medio do Patrimonio Liquido
	
	If nSldMedPatrLiq <> 0
		nRetPatrLiq := nLucroLiq / nSldMedPatrLiq
		aAdd(aRetPainel, { STR0045, Str(nRetPatrLiq, 3),CLR_HBLUE,  } )  //"Retorno s/ Capital Proprio"
	Else
		aAdd(aRetPainel, { STR0044, Str(0,2),CLR_HRED,  } )  //"Ret.s/Capital Proprio Nao Calc."
	EndIf	

EndIf

//TERMINO DO RETORNO SOBRE CAPITAL PROPRIO
//-----------------------------------------------------------------------------------//

RestArea(aSaveArea)

Return aRetPainel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณCTBHelpPainelบAutor  ณPaulo Carnelossi   บ Data ณ 30/03/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณHelp resumido dos paineis de gestao do modulo SIGACTB       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CTBHelpPainel(cProgPainel)
Local cRetHelp := ""

If 		Upper(cProgPainel) == Upper("CtCmpEntGer")
	cRethelp += STR0046+CRLF  //"Este painel exibe comparativo de saldos de contas gerenciais"
	cRethelp += STR0047+CRLF  //"com meses anteriores"
	
ElseIf 	Upper(cProgPainel) == Upper("CtCmpAnoAnt")
	cRethelp += STR0048+CRLF  //"Este painel exibe comparativo de saldos de contas gerenciais com "
	cRethelp += STR0049+CRLF

ElseIf 	Upper(cProgPainel) == Upper("CtCmpSldEnt")
	cRethelp += STR0050  //"Este painel exibe comparativo de saldos de entidades com meses anteriores"

ElseIf 	Upper(cProgPainel) == Upper("CtEbitda")
	cRethelp += STR0051+CRLF+CRLF  //"Este painel exibe evolu็ใo mensal Ebitda"
	cRethelp += STR0052+CRLF  //"O valor do Ebitda estarแ representado pelo valor de  uma visใo  gerencial  que"
	cRethelp += STR0053+CRLF  //"deverแ ser informada. O usuแrio deverแ informar todos os parโmetros necessแrios"
	cRethelp += STR0054+CRLF  //"para obter o valor desejado (intervalo de datas, calendario, moeda, etc.)"

ElseIf 	Upper(cProgPainel) == Upper("CtPreLan")
	cRethelp += STR0055+CRLF  //"Este painel exibe quantidade e valor de pr้-lan็amentos (por moeda)"

ElseIf 	Upper(cProgPainel) == Upper("CtCmpEntAnt")
	cRethelp += STR0056+CRLF  //"Este painel exibe Comparativo de saldos de entidades com mesmo perํodo anos anteriores"

ElseIf 	Upper(cProgPainel) == Upper("CtIndPat")
	cRethelp += STR0057+CRLF   //"Painel de ํndices de estrutura patrimonial(Capital de terceiros / "
	cRethelp += STR0058+CRLF  //"Capital Pr๓prio, composi็ใo do endividamento, endividamento geral,"
	cRethelp += STR0059+CRLF  //" imobiliza็ใo do capital pr๓prio, imobiliza็ใo dos recursos permanentes)"
	cRethelp += STR0060+CRLF  //"Os ํndices de estrutura patrimonial sใo calculados em base aos valores"
	cRethelp += STR0061+CRLF  //"listados abaixo. Cada um deles serแ informado em um parโmetro que pode"
	cRethelp += STR0062+CRLF  //"ser uma conta do plano de contas (sint้tica ou analํtica) ou uma visใo"
	cRethelp += STR0063+CRLF  //"gerencial, para os valores que nใo possam ser representados unicamente"
	cRethelp += STR0064+CRLF  //"por uma conta:"
	cRethelp += STR0065+CRLF  //"A) Passivo Circulante"
	cRethelp += STR0066+CRLF  //"B) Exigํvel a longo prazo"
	cRethelp += STR0067+CRLF  //"C) Patrim๔nio Liquido"
	cRethelp += STR0068+CRLF  //"D) Ativo Total"
	cRethelp += STR0069+CRLF  //"E) Ativo Permanente"
	cRethelp += STR0070+CRLF  //"Detalhe dos ํndices:"
	cRethelp += STR0071+CRLF  //"Capital de terceiros/Capital Pr๓prio = (A+B)/C"
	cRethelp += STR0072+CRLF  //"Composi็ใo do endividamento = A/(A+B)"
	cRethelp += STR0073+CRLF  //"Endividamento geral = (A+B)/D"
	cRethelp += STR0074+CRLF  //"Imobiliza็ใo do capital pr๓prio = E/C"
	cRethelp += STR0075+CRLF  //"Imobiliza็ใo dos recursos permanentes = E/(B+C)"

ElseIf 	Upper(cProgPainel) == Upper("CtbPrzMed")
	cRethelp += STR0076+CRLF  //"Painel de ํndices de prazos m้dios (prazo m้dio de estocagem, prazo m้dio "
	cRethelp += STR0077+CRLF  //"de cobran็a, prazo m้dio de pagamento dos fornecedores)."
	cRethelp += STR0078+CRLF  //"Os ํndices de rota็ใo dos prazos m้dios sใo calculados em base aos valores "
	cRethelp += STR0079+CRLF  //"listados abaixo. Cada um deles serแ informado em um parโmetro que pode ser "
	cRethelp += STR0080+CRLF  //"uma conta do plano de contas (sint้tica ou analํtica) ou uma visใo gerencial,"
	cRethelp += STR0081+CRLF  //"para os valores que nใo possam ser representados unicamente por uma conta:"
	cRethelp += STR0082+CRLF  //"A) Custo das vendas"
	cRethelp += STR0083+CRLF  //"B) Estoques"
	cRethelp += STR0084+CRLF  //"C) Receita operacional bruta"
	cRethelp += STR0085+CRLF  //"D) Devolu็๕es e abatimentos"
	cRethelp += STR0086+CRLF  //"E) Duplicatas a receber"
	cRethelp += STR0087+CRLF  //"F) Saldo de Fornecedores"
	cRethelp += STR0088+CRLF  //"G) Compras brutas"
	cRethelp += STR0089+CRLF  //"Detalhe dos ํndices:"
	cRethelp += STR0090+CRLF  //"Prazo m้dio de estocagem (em dias) = "
	cRethelp += STR0091+CRLF  //"                 ((Saldo m้dio mensal do perํodo de B)*Dias do perํodo)/A"
	cRethelp += CRLF                     
	cRethelp += STR0092+CRLF  //"Prazo m้dio de cobran็a (em dias) = "
	cRethelp += STR0093+CRLF  //"                 ((Saldo m้dio mensal do perํodo de E)*Dias do perํodo)/(C-D)"
	cRethelp += CRLF
	cRethelp += STR0094+CRLF  //"Prazo m้dio de pagamento a fornecedores (em dias) = "
	cRethelp += STR0095+CRLF  //"                 ((Saldo m้dio mensal do perํodo de F)*Dias do perํodo)/G"

ElseIf 	Upper(cProgPainel) == Upper("CtbGiros")
	cRethelp += STR0096+CRLF  //"Painel de ํndices de rota็ใo dos recursos (giros dos estoques, giro das "
	cRethelp += STR0097+CRLF  //"duplicatas a receber, giro do ativo circulante, giro do ativo fixo, giro"
	cRethelp += STR0098+CRLF  //" do ativo operacional,giro do investimento total)."
	cRethelp += STR0099+CRLF  //"Os ํndices de rota็ใo dos recursos sใo calculados em base aos valores"
	cRethelp += STR0100+CRLF  //"listados abaixo. Cada um deles serแ informado em um parโmetro que pode"
	cRethelp += STR0101+CRLF  //"ser uma conta do plano de contas (sint้tica ou analํtica) ou uma visใo"
	cRethelp += STR0102+CRLF  //"gerencial, para os valores que nใo possam ser representados unicamente "
	cRethelp += STR0103+CRLF  //"por uma conta."
	cRethelp += STR0104+CRLF  //"A) Custo das vendas"
	cRethelp += STR0105+CRLF  //"B) Estoques"
	cRethelp += STR0106+CRLF  //"C) Receita operacional bruta"
	cRethelp += STR0107+CRLF  //"D) Devolu็๕es e abatimentos"
	cRethelp += STR0108+CRLF  //"E) Duplicatas a receber"
	cRethelp += STR0109+CRLF  //"F) Receita operacional liquida"
	cRethelp += STR0110+CRLF  //"G) Imobilizado"
	cRethelp += STR0111+CRLF  //"H) Ativo operacional"
	cRethelp += STR0112+CRLF  //"I) Ativo total"
	cRethelp += STR0113+CRLF  //"J) Ativo circulante"
	cRethelp += STR0114+CRLF  //"Detalhe dos ํndices:"
	cRethelp += STR0115+CRLF  //"Giro dos estoques totais = A/(Saldo m้dio mensal do perํodo de B)"
	cRethelp += STR0116+CRLF  //"Giro das duplicatas a receber = (C - D)/ (Saldo m้dio mensal do perํodo de E)"
	cRethelp += STR0117+CRLF  //"Giro do ativo circulante = F/(Saldo m้dio mensal do perํodo de J)"
	cRethelp += STR0118+CRLF  //"Giro do ativo fixo = F/(Saldo m้dio mensal do perํodo de G)"
	cRethelp += STR0119+CRLF  //"Giro do ativo operacional = F/(Saldo m้dio mensal do perํodo de H)"
	cRethelp += STR0120+CRLF  //"Giro do investimento total = F/(Saldo m้dio mensal do perํodo de I)"

ElseIf 	Upper(cProgPainel) == Upper("CtRentab")
	cRethelp += STR0121+CRLF  //"Painel de margens de rentabilidade (Margem bruta, margem operacional,"
	cRethelp += STR0122+CRLF //" margem liquida, mark-up global)."
	cRethelp += STR0123+CRLF  //"As margens de rentabilidade sใo calculadas em base aos valores listados"
	cRethelp += STR0124+CRLF  //"abaixo. Cada um deles serแ informado em um parโmetro que pode ser uma "
	cRethelp += STR0125+CRLF  //"conta do plano de contas (sint้tica ou analํtica) ou uma visใo gerencial,"
	cRethelp += STR0126+CRLF  //" para os valores que nใo possam ser representados unicamente por uma conta:"
	cRethelp += STR0127+CRLF  //"A) Custo das vendas"
	cRethelp += STR0128+CRLF  //"B) Lucro Bruto"
	cRethelp += STR0129+CRLF  //"C) Receita operacional liquida"
	cRethelp += STR0130+CRLF  //"D) Lucro operacional"
	cRethelp += STR0131+CRLF  //"E) Lucro liquido"
	cRethelp += STR0132+CRLF  //"Detalhe dos ํndices:"
	cRethelp += STR0133+CRLF  //"Margem bruta = B/C"
	cRethelp += STR0134+CRLF  //"Margem operacional = D/C"
	cRethelp += STR0135+CRLF  //"Margem liquida = E/C"
	cRethelp += STR0136+CRLF  //"Mark-up global= B/A"

ElseIf 	Upper(cProgPainel) == Upper("CtSolv")
	cRethelp += STR0137+CRLF  //"Painel de ํndices de solv๊ncia (Liquidez geral, liquidez corrente, liquidez seca)"
	cRethelp += STR0138+CRLF  //"Os ํndices de solv๊ncia sใo calculados em base aos valores listados abaixo. Cada "
	cRethelp += STR0139+CRLF  //"um deles serแ informado em um parโmetro que pode ser uma conta do plano de contas "
	cRethelp += STR0140+CRLF  //"(sint้tica ou analํtica) ou uma visใo gerencial, para os valores que nใo possam ser "
	cRethelp += STR0141+CRLF  //"representados unicamente por uma conta:"
	cRethelp += STR0142+CRLF  //"A) Ativo Circulante"
	cRethelp += STR0143+CRLF  //"B) Realizแvel a longo prazo"
	cRethelp += STR0144+CRLF  //"C) Passivo Circulante"
	cRethelp += STR0145+CRLF  //"D) Exigํvel a longo prazo"
	cRethelp += STR0146+CRLF  //"E) Estoques"
	cRethelp += STR0147+CRLF  //"F) Despesas exercํcio seguinte"
	cRethelp += STR0148+CRLF  //"Detalhe dos ํndices:"
	cRethelp += STR0149+CRLF  //"Liquidez geral = (A+B)/(C+D)"
	cRethelp += STR0150+CRLF  //"Liquidez corrente = A/C"
	cRethelp += STR0151+CRLF  //"Liquidez seca = (A-B-F)/C"

ElseIf 	Upper(cProgPainel) == Upper("CtbTxRetorno")
	cRethelp += STR0152+CRLF  //"Painel de taxas de retorno(retorno sobre o ativo operacional, retorno sobre"
	cRethelp += STR0153+CRLF  //"o investimento total, retorno sobre o capital  pr๓prio)."
	cRethelp += STR0154+CRLF  //"As taxas de retorno sใo calculadas em base aos valores listados abaixo. "
	cRethelp += STR0155+CRLF  //"Cada um deles serแ informado em um parโmetro que pode ser uma conta do plano"
	cRethelp += STR0156+CRLF  //"de contas (sint้tica ou analํtica) ou uma visใo gerencial, para os valores"
	cRethelp += STR0157+CRLF  //"que nใo possam ser representados unicamente por uma conta:"
	cRethelp += STR0158+CRLF  //"A) Ativo total"
	cRethelp += STR0159+CRLF  //"B) Ativo operacional"
	cRethelp += STR0160+CRLF  //"C) Patrim๔nio liquido"
	cRethelp += STR0161+CRLF  //"D) Lucro operacional"
	cRethelp += STR0162+CRLF  //"E) Lucro liquido"
	cRethelp += STR0163+CRLF  //"Detalhe dos ํndices:"
	cRethelp += STR0164+CRLF  //"Retorno sobre o ativo operacional = D/(Saldo m้dio mensal do perํodo de B)"
	cRethelp += STR0165+CRLF  //"Retorno sobre o investimento total = E/(Saldo m้dio mensal do perํodo de A)"
	cRethelp += STR0166+CRLF  //"Retorno sobre o capital pr๓prio = E/(Saldo m้dio mensal do perํodo de C)"

Else
	cRethelp += STR0167+CRLF  //"Este painel exibe as informacoes conforme os parametros"+CRLF+CRLF //"Este painel exibe as informacoes conforme os parametros"
	cRethelp += STR0168+CRLF //"informados."+CRLF

EndIf

Return(cRetHelp)
