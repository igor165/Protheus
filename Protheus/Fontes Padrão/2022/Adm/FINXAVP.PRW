#Include "PROTHEUS.CH"
#Include "FINXAVP.CH"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine cores do checkณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE	COR_MARCA		"LBOK"
#DEFINE	COR_NAOMARCA	"LBNO"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do array para controle do processamento MultThreadณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE ARQUIVO		 		1
#DEFINE MARCA		 	  		2
#DEFINE QTD_REGISTROS		3

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFlag de processamento escrito no arquivo de controle ณ
//ณde threads                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE OK		 		"OK"
#DEFINE ERRO		 	"ERRO"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES de Tipos de Metodos de AVPณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE	TAXA_INFORMADA			01
#DEFINE	FORMULA					02
#DEFINE	INDICE_FINANCEIRO		03

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES Posi็๕es do array de respostasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE PROCESSO			01
#DEFINE DATA_PROC			02
#DEFINE VALOR_DE			03
#DEFINE VALOR_ATE			04
#DEFINE VENCTO_DE			05
#DEFINE VENCTO_ATE			06
#DEFINE EMISSAO_DE          07
#DEFINE EMISSAO_ATE			08
#DEFINE NATUREZA_DE			09
#DEFINE NATUREZA_ATE		10
#DEFINE PORTADOR_DE			11
#DEFINE PORTADOR_ATE		12
#DEFINE CLIENTE_DE			13
#DEFINE LOJA_DE				14
#DEFINE CLIENTE_ATE			15
#DEFINE LOJA_ATE	  		16
#DEFINE METODO		  		17

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES DE CONTEUDO DOS DADOS DO AVPณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE	D_TAXA_INFORMADA			01
#DEFINE	D_PERIODO_TAXA				02
#DEFINE	D_FORMULA					03
#DEFINE	D_INDICE_FINANCEIRO			04

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES DE CONTEUDO DOS TIPOS DE PERIODOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE	P_DIARIO        			"1"
#DEFINE	P_MENSAL      				"2"
#DEFINE	P_TRIMESTRAL				"3"
#DEFINE	P_SEMESTRAL         		"4"
#DEFINE	P_ANUAL         			"5"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ FCalcAVP ณ Autor ณ Mauricio Pequim Jr.   ณ Data ณ 16/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Rotina de calculo de ajuste a valor presente (AVP)         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ FCalcAVP(ExpC1,ExpC2,ExpN3,ExpD4,ExpD5,ExpN6,ExpC7,ExpC8)  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01=Codigo do Processo AVP                              ณฑฑ
ฑฑณ          ณ ExpC02=Tipo Processo (C,A,B,R)				                 ณฑฑ
ฑฑณ          ณ 			[C] - Constituicao						              ณฑฑ
ฑฑณ          ณ 			[A] - Ajuste/Apropriacao				              ณฑฑ
ฑฑณ          ณ 			[B] - Baixa         						              ณฑฑ
ฑฑณ          ณ 			[R] - Realizado   						              ณฑฑ
ฑฑณ          ณ ExpC03=Alias do arquivo a ser posicionado                  ณฑฑ
ฑฑณ          ณ ExpN04=Recno do registro a ser posicionado                 ณฑฑ
ฑฑณ          ณ ExpD05=Dada de inicio para calculo do AVP 	              ณฑฑ
ฑฑณ          ณ ExpD06=Dada de inicio para calculo do AVP 	              ณฑฑ
ฑฑณ          ณ ExpN07=Taxa AVP		                                      ณฑฑ
ฑฑณ          ณ ExpC08=Formula AVP                                         ณฑฑ
ฑฑณ          ณ ExpC09=Codigo do Indice (tabela de Indices)	              ณฑฑ
ฑฑณ          ณ ExpN10=Valor do Indice				                          ณฑฑ
ฑฑณ          ณ ExpC11=Periodicidade da Taxa		                          ณฑฑ
ฑฑณ          ณ ExpD12=Data do processo				                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FCalcAVP(cProcess,cTipoProc,cAlias,nRecno,nTaxa,cFormula,cCodInd,nValInd,cPeriodo,dDtProc,nValVP,nValAVP,cCritica)

Local lRet := .F.
Local nDias := 1			//Diario
Local nDiasAVP := 0
Local nValAvpAnt := 0
Local dDataINI	:= dDatabase
Local nDecimais := TamSX3("FIN_VLRAVP")[2]
Local aAreaFIN := {}

DEFAULT cProcess	:= ""
DEFAULT cTipoProc	:= ""
DEFAULT cAlias		:= ""
DEFAULT nRecno		:= 0
DEFAULT nTaxa		:= 0
DEFAULT cFormula	:= ""
DEFAULT cPeriodo	:= "1"
DEFAULT dDtProc	:= dDataBase
DEFAULT cCodInd	:= ""
DEFAULT nValInd	:= 0
DEFAULT cCritica	:= " "

IF !Empty(cProcess)	.and. ;
	!Empty(cTipoProc)	.and.	;
	!Empty(cAlias)		.and.	;
	nRecno > 0			.and.	;
	( !( nTaxa == 0) .or. !Empty(cFormula) )
	
	//Posiciono o alias para buscar o valor original do titulo
	If cAlias == "SE1"
		SE1->(dbGoto(nRecno))
		nValTit 		:= SE1->E1_VALOR
		nValAvpAnt	:= SE1->E1_VALOR
		dDataFin		:= SE1->E1_VENCTO
		dDataIni		:= SE1->E1_EMISSAO
		
		
		//Se nao for constituicao
		//Posiciono o arquivo de Valor Presente - CR (FIM)
		//A Variacao neste caso sera calculada pela diferenca entre
		//Valor Presente Atual - Valor Presente Anterior.
		//No caso de constituicao, nao havera o calculo de ajuste, mas de constituicao
		If cTipoProc != "C"
			//Caso seja informada um processo de Ajuste, mas nao tenha sido feita a Constituicao,
			//este processo serแ tranformado em Constituicao,
			FIN->(dbSetOrder(2))
			If FIN->(MsSeek(xFilial("FIN")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA+"A"))) 
				aAreaFIN := FIN->( GetArea() )		
				cSeqFIN:= FNxtAvpSeq("FIN",SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA,.F.) //ฺltima sequ๊ncia utilizada .F.
				FIN->(dbSetOrder(1))
				If FIN->(MsSeek(xFilial("FIN")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA+cSeqFIN)))	// Se for processo de Ajuste AVP = Valor presente na data de processo - Valor AVP anterior
																														// Valor AVP anterior  = ฺltima sequ๊ncia registra na FIN
					nValTit		:= FIN->FIN_BASE
					nValAVPAnt 	:= FIN->FIN_VLRAVP
					dDataIni	:= If(dDtProc > SE1->E1_VENCTO, SE1->E1_VENCTO, dDtProc )
					dDataFin	:= SE1->E1_VENCTO
				EndIf
				RestArea(aAreaFIN)
			Else
				cTipoProc := "C"
				dDataFin		:= SE1->E1_VENCTO
				dDataIni		:= SE1->E1_EMISSAO
			Endif
		Endif
	Else
		SE2->(dbGoto(nRecno))
		nValTit		:= SE2->E2_VALOR
		nValAvpAnt	:= SE2->E2_VALOR
		dDataFin		:= SE2->E2_VENCTO
		dDataIni		:= SE2->E2_EMISSAO
		
		//Se nao for constituicao
		//Posiciono o arquivo de Valor Presente - CP (FIP)
		//A Variacao neste caso sera calculada pela diferenca entre
		//Valor Presente Atual - Valor Presente Anterior.
		//No caso de constituicao, nao havera o calculo de ajuste, mas de constituicao
		If cTipoProc != "C"
			FIQ->(dbSetOrder(2))
			If FIQ->(MsSeek(xFilial("FIQ")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA+"A")))
				nValTit		:= FIQ->FIQ_BASE
				nValAvpAnt	:= FIQ->FIQ_VLRAVP
				dDataIni		:= If(dDtProc > SE2->E2_VENCTO, SE2->E2_VENCTO , dDtProc )
				dDataFin		:= SE2->E2_VENCTO
			Else
				cTipoProc	:= "C"
				dDataFin		:= SE2->E2_VENCTO
				dDataIni		:= SE2->E2_EMISSAO
			Endif
		Endif
	Endif
	
	//Conversao da Taxa do periodo inicial para dias
	If !( nTaxa == 0)
		
		DO CASE
			CASE cPeriodo = "1"	//Diario
				nDias := 1
			CASE cPeriodo = "2"	//Mensal
				nDias := 30
			CASE cPeriodo = "3"	//Trimestra
				nDias := 90
			CASE cPeriodo = "4"	//Semestral
				nDias := 180
			CASE cPeriodo = "5"	//Anual
				nDias := 365
			OTHERWISE
				nDias := 0
		ENDCASE
		
		//Converto a Taxa informada para taxa diaria
		nIndDia := (1+(nTaxa/100))**(1/nDias) //Taxa equivalente
		
		//Calculo o numero de dias para AVP
		nDiasAvp := (dDataFin - dDataIni)
		
		//Valor Presente
		nValVP	:= nValTit / (nIndDia**nDiasAVP)
		
		//Valor do Ajuste Valor Presente
		//Se for Constituicao AVP = Valor do titulo - Valor presente na data de emissao
		//Se for processo de Ajuste AVP = Valor presente na data de processo - Valor AVP anterior (FIM ou FIP)
		If cTipoProc == "C"
			nValAVP	:= nValTit - nValVP
		Else
			nValAVP	:= nValVP - nValAvpAnt
		Endif
		
		nValAvp := Round(NoRound(nValAVP,nDecimais+1),nDecimais)
		
		lRet := .T.
		
		//Conversao a valor presente por formula
	ElseIf !Empty(cFormula)
		
		//Valor Presente
		//Valido a formula
		cCritica := " "
		bBlock := ErrorBlock( { |e| ChecErro(e,@cCritica) } )
		BEGIN SEQUENCE
		xResult := Formula(cFormula)
		RECOVER
		xResult := 0
		END SEQUENCE
		ErrorBlock(bBlock)
		
		If Valtype(xResult) = "N" .and. xResult > 0
			//Valor do Ajuste a Valor Presente
			nValVP	:= xResult
			//Valor do Ajuste Valor Presente
			//Se for Constituicao AVP = Valor do titulo - Valor presente na data de emissao
			//Se for processo de Ajuste AVP = Valor presente na data de processo - Valor AVP anterior (FIM ou FIP)
			If cTipoProc == "C"
				nValAVP	:= nValTit - nValVP
			Else
				nValAVP	:= nValVP - nValAvpAnt
			Endif
			
			nValAvp := Round(NoRound(nValAVP,nDecimais+1),nDecimais)
			
			lRet		:= .T.
			
		Else
			nValVP	:= 0
			nValAVP	:= 0
			lRet		:= .F.
		Endif
	Endif
	
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ FGRVAVPMOV ณ Autor ณ Mauricio Pequim Jr. ณ Data ณ 16/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Rotina de calculo de ajuste a valor presente (AVP)         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ FGRVAVPMOV(ExpC01,ExpC02,ExpC03,ExpN04,ExpC05,ExpC06,ExpN07ณฑฑ
ฑฑณ          ณ            ExpC08,ExpD09,ExpN10,ExpC11,ExpC12,)            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01=Codigo do Processo AVP                              ณฑฑ
ฑฑณ          ณ ExpC02=Tipo Processo (C,A,B,R)				                 ณฑฑ
ฑฑณ          ณ 			[C] - Constituicao						              ณฑฑ
ฑฑณ          ณ 			[A] - Ajuste/Apropriacao				              ณฑฑ
ฑฑณ          ณ 			[B] - Baixa         						              ณฑฑ
ฑฑณ          ณ 			[R] - Realizado   						              ณฑฑ
ฑฑณ          ณ ExpC03=Alias do arquivo a ser posicionado                  ณฑฑ
ฑฑณ          ณ ExpN04=Taxa AVP		                                      ณฑฑ
ฑฑณ          ณ ExpC05=Formula AVP                                         ณฑฑ
ฑฑณ          ณ ExpC06=Codigo do Indice (tabela de Indices)	              ณฑฑ
ฑฑณ          ณ ExpN07=Valor do Indice				                          ณฑฑ
ฑฑณ          ณ ExpC08=Periodicidade da Taxa		                          ณฑฑ
ฑฑณ          ณ ExpD09=Data do processo				                          ณฑฑ
ฑฑณ          ณ ExpN10=Valor do AVP					                          ณฑฑ
ฑฑณ          ณ ExpC11=Item do Processo				                          ณฑฑ
ฑฑณ          ณ ExpC12=Critica do Processo			                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FGRVAVPMOV(cProcess,cTipoProc,cAliasMov,nTaxa,cFormula,cCodInd,nValInd,cPeriodo,dDtProc,nValAVP,cIdMov,cCritica,cSeqBx)
Local nRecno := 0
Local aArea	 := GetARea()

DEFAULT cCritica := SPACE(1)
DEFAULT cSeqBx   := SPACE(IIf(cAliasMov =="FIP",TamSX3("FIP_SEQBX")[1],TamSX3("FIS_SEQBX")[1]))

//---------------------------------------------------------------------------------
//Contas a Pagar
//---------------------------------------------------------------------------------
If cAliasMov =="FIP"
	RecLock("FIP",.T.)
	FIP_FILIAL	:= xFilial("FIP")
	FIP_PROC	:= cProcess
	FIP_IDMOV	:= cIdMov
	FIP_PREFIX	:= SE1->E1_PREFIXO
	FIP_NUM		:= SE1->E1_NUM
	FIP_PARCEL	:= SE1->E1_PARCELA
	FIP_TIPO	:= SE1->E1_TIPO
	FIP_CLIENT	:= SE1->E1_CLIENTE
	FIP_LOJA	:= SE1->E1_LOJA
	FIP_TIPAVP	:= cTipoProc
	FIP_DTAVP	:= dDtProc
	FIP_VLRAVP	:= nValAVP
	FIP_TAXAVP	:= nTaxa
	FIP_FORMUL	:= cFormula
	FIP_CODIND	:= cCodInd
	FIP_VLRIND	:= nValInd
	FIP_PERIOD	:= cPeriodo
	FIP_CRITIC	:= cCritica
	FIP_STATUS	:= "S"
	FIP_SEQBX	:= cSeqBx
	MsUnLock()
	nRecno := FIP->(Recno())
Else
	RecLock("FIS",.T.)
	FIS_FILIAL	:= xFilial("FIS")
	FIS_PROC		:= cProcess
	FIS_IDMOV	:= cIdMov
	FIS_PREFIX	:= SE2->E2_PREFIXO
	FIS_NUM		:= SE2->E2_NUM
	FIS_PARCEL	:= SE2->E2_PARCELA
	FIS_TIPO	:= SE2->E2_TIPO
	FIS_FORNEC	:= SE2->E2_FORNECE
	FIS_LOJA	:= SE2->E2_LOJA
	FIS_TIPAVP	:= cTipoProc
	FIS_DTAVP	:= dDtProc
	FIS_VLRAVP	:= nValAVP
	FIS_TAXAVP	:= nTaxa
	FIS_FORMUL	:= cFormula
	FIS_CODIND	:= cCodInd
	FIS_VLRIND	:= nValInd
	FIS_PERIOD	:= cPeriodo
	FIS_CRITIC	:= cCritica
	FIS_STATUS	:= "S"
	FIS_SEQBX	:= cSeqBx
	MsUnLock()
	nRecno := FIS->(Recno())
Endif

RestArea(aArea)
Return nRecno


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ FGRVAVPTIT ณ Autor ณ Mauricio Pequim Jr. ณ Data ณ 16/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Rotina de Gravacao do registro de AVP							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ FGRVAVPTIT(ExpC1,ExpN2)                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01=Alias do arquivo de Movimentos AVP                  ณฑฑ
ฑฑณ          ณ ExpN02=Recno do movimento do AVP   			                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿1฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FGRVAVPTIT(cAliasMov,nRecnoMov)

Local aCampos	:= {}
Local cSeq		:= StrZero(0,tamSx3("FIQ_SEQ")[1])
Local cSeq2		:= StrZero(0,tamSx3("FIQ_SEQ")[1])
Local cSeqFIP	:= StrZero(0,tamSx3("FIP_SEQ")[1])
Local nX		:= 0
Local nAAprop	:= 0
Local nRecno	:= 0

If cAliasMov =="FIP"
	
	//---------------------------------------------------------------------------------
	//Contas a RECEBER
	//---------------------------------------------------------------------------------
	
	//Posiciono a tabela de movimento
	FIP->(dbGoto(nRecnoMov))
	
	If FIP->FIP_TIPAVP == "C" //Constituicao
		
		SE1->(dbSetOrder(2))
		SE1->(MsSeek(xFilial("SE1")+FIP->(FIP_CLIENT+FIP_LOJA+FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO)))
		
		cSeqFIP := FNxtAvpSeq("FIN",FIP->FIP_PREFIX,FIP->FIP_NUM,FIP->FIP_PARCEL,FIP->FIP_TIPO,FIP->FIP_CLIENT,FIP->FIP_LOJA)
		
		//Gravo o novo registro AVP do titulo
		RecLock("FIN",.T.)
		FIN_FILIAL	:= xFilial("FIN")
		FIN_PREFIX	:= FIP->FIP_PREFIX
		FIN_NUM		:= FIP->FIP_NUM
		FIN_PARCEL	:= FIP->FIP_PARCEL
		FIN_TIPO	:= FIP->FIP_TIPO
		FIN_CLIENT	:= FIP->FIP_CLIENT
		FIN_LOJA	:= FIP->FIP_LOJA
		FIN_STATUS	:= "A"		//AVP Ativo
		FIN_DTAVP	:= SE1->E1_EMISSAO
		FIN_TIPAVP	:= FIP->FIP_TIPAVP
		FIN_TAXAVP	:= FIP->FIP_TAXAVP
		FIN_FORMUL	:= FIP->FIP_FORMUL
		FIN_CODIND	:= FIP->FIP_CODIND
		FIN_VLRAVP	:= SE1->E1_VALOR - FIP->FIP_VLRAVP //Valor do titulo ajustado para a data da emissao
		FIN_PERIOD	:= FIP->FIP_PERIOD
		FIN_BASE	:= SE1->E1_VALOR
		FIN_SEQ		:= cSeqFIP
		MsUnLock()
		
	ElseIf FIP->FIP_TIPAVP $ "A#R" 	//Ajuste ou Realizacao
		
		//Procuro o registro AVP ativo do titulo
		FIN->(dbSetOrder(2))
		IF !FIN->(MsSeek(xFilial("FIN")+FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA+"A")))
			FIN->(MsSeek(xFilial("FIN")+FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA+"R")))
		ENDIF
		
		RecLock("FIN",.F.)
		FIN_DTAVP	:= FIP->FIP_DTAVP
		FIN_VLRAVP	+= FIP->FIP_VLRAVP //Valor do titulo ajustado para a data de ajuste
		MsUnLock()
		
		//Verifico se houve a realizacao por apropriacao
		If FIN->FIN_BASE <= FIN->FIN_VLRAVP
			RecLock("FIN",.F.)
			FIN_VLRAVP := FIN->FIN_BASE
			FIN_STATUS := "R"		//AVP Realizado Completamente
			MsUnLock()
		Endif
		
	ElseIf FIP->FIP_TIPAVP $ "B" 	//Baixa
		
		//Procuro o registro AVP ativo do titulo
		FIN->(dbSetOrder(2))
		IF !FIN->(MsSeek(xFilial("FIN")+FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA+"A")))
			FIN->(MsSeek(xFilial("FIN")+FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA+"R")))
		ENDIF
		
		//Prosiciono o registro do titulo
		SE1->(dbSetOrder(2))
		SE1->(MsSeek(xFilial("SE1")+FIP->(FIP_CLIENT+FIP_LOJA+FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO)))
		
		//Gravo o ajuste do valor
		RecLock("FIN")
		If FIN->FIN_VLRAVP >= FIN->FIN_BASE
			FIN->FIN_VLRAVP := FIN->FIN_BASE
			FIN->FIN_STATUS := "R"		//AVP Realizado Completamente
		Else
			FIN->FIN_STATUS :=  "B"		//AVP Realizado Parcialmente
		Endif
		MsUnlock()
		
		If FIN->FIN_STATUS == "B"
			cSeq := FIN->FIN_SEQ
			nAAprop := FIN->(FIN_BASE - FIN_VLRAVP)
			
			// Carrega em aCampos o conteudo dos campos do FIQ
			For nX := 1 To fCount()
				Aadd(aCampos, {FieldName(nX), FieldGet(nX)})
			Next
			
			cSeqFIP := FNxtAvpSeq("FIN",FIP->FIP_PREFIX,FIP->FIP_NUM,FIP->FIP_PARCEL,FIP->FIP_TIPO,FIP->FIP_CLIENT,FIP->FIP_LOJA)		
			
			RecLock("FIN",.T.)
			// Descarrega aCampos no FIM para que todos os campos preenchidos no registro realizado parcialmente
			// sejam replicados ao novo registro de AVP do titulo
			For nX := 1 To fCount()
				If !Empty(aCampos[nX][2])
					FieldPut(nX,aCampos[nX][2])
				Endif
			Next
			FIN->FIN_BASE		-= FIP->FIP_VLRAVP
			FIN->FIN_VLRAVP		:= FIN->FIN_BASE - nAAprop
			FIN->FIN_STATUS		:= "A"		//AVP Ativo
			FIN->FIN_SEQ		:= cSeqFIP
			
			MsUnlock()
		Endif
	Endif
	
	//Atualizo o Status como Efetivado
	RecLock("FIP", .F.)
	FIP->FIP_STATUS 	:= "E"
	FIP->FIP_SEQ 		:= FIN->FIN_SEQ
	MsUnLock()
	nRecno := FIN->(Recno())
	
Else
	
	//---------------------------------------------------------------------------------
	//Contas a PAGAR
	//---------------------------------------------------------------------------------
	
	//Posiciono a tabela de movimento
	FIS->(dbGoto(nRecnoMov))
	
	If FIS->FIS_TIPAVP == "C" //Constituicao
		
		SE2->(dbSetOrder(6))
		SE2->(MsSeek(xFilial("SE2")+FIS->(FIS_FORNEC+FIS_LOJA+FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO)))
		
		//Gravo o novo registro AVP do titulo
		RecLock("FIQ",.T.)
		FIQ_FILIAL	:= xFilial("FIQ")
		FIQ_PREFIX	:= FIS->FIS_PREFIX
		FIQ_NUM		:= FIS->FIS_NUM
		FIQ_PARCEL	:= FIS->FIS_PARCEL
		FIQ_TIPO		:= FIS->FIS_TIPO
		FIQ_FORNEC	:= FIS->FIS_FORNEC
		FIQ_LOJA		:= FIS->FIS_LOJA
		FIQ_STATUS	:= "A"		//AVP Ativo
		FIQ_DTAVP	:= SE2->E2_EMISSAO
		FIQ_TIPAVP	:= FIS->FIS_TIPAVP
		FIQ_TAXAVP	:= FIS->FIS_TAXAVP
		FIQ_FORMUL	:= FIS->FIS_FORMUL
		FIQ_CODIND	:= FIS->FIS_CODIND
		FIQ_VLRAVP	:= SE2->E2_VALOR - FIS->FIS_VLRAVP //Valor do titulo ajustado para a data da emissao
		FIQ_PERIOD	:= FIS->FIS_PERIOD
		FIQ_BASE		:= SE2->E2_VALOR
		FIQ_SEQ		:= FNxtAvpSeq("FIQ",FIQ_PREFIX,FIQ_NUM,FIQ_PARCEL,FIQ_TIPO,FIQ_FORNEC,FIQ_LOJA)
		MsUnLock()
		
	ElseIf FIS->FIS_TIPAVP $ "A#R" 	//Ajuste ou Realizacao
		
		//Procuro o registro AVP ativo do titulo
		FIQ->(dbSetOrder(2))
		IF !FIQ->(MsSeek(xFilial("FIQ")+FIS->(FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA+"A")))
			FIQ->(MsSeek(xFilial("FIQ")+FIS->(FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA+"R")))
		ENDIF
		
		RecLock("FIQ",.F.)
		FIQ_DTAVP	:= FIS->FIS_DTAVP
		FIQ_VLRAVP	+= FIS->FIS_VLRAVP //Valor do titulo ajustado para a data de ajuste
		MsUnLock()
		
		//Verifico se houve a realizacao por apropriacao
		//Isto ocorre quand?o
		If FIQ->FIQ_BASE <= FIQ->FIQ_VLRAVP
			RecLock("FIQ",.F.)
			FIQ_VLRAVP := FIQ->FIQ_BASE
			FIQ_STATUS := "R"		//AVP Realizado Completamente
			MsUnLock()
		Endif
		
	ElseIf FIS->FIS_TIPAVP $ "B" 	//Baixa
		
		//Procuro o registro AVP ativo do titulo
		FIQ->(dbSetOrder(2))
		IF !FIQ->(MsSeek(xFilial("FIQ")+FIS->(FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA+"A")))
			FIQ->(MsSeek(xFilial("FIQ")+FIS->(FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA+"R")))
		ENDIF
		
		//Prosiciono o registro do titulo
		SE2->(dbSetOrder(6))
		SE2->(MsSeek(xFilial("SE2")+FIS->(FIS_FORNEC+FIS_LOJA+FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO)))
		//Gravo o ajuste do valor
		RecLock("FIQ")
		If FIQ->FIQ_VLRAVP >= FIQ->FIQ_BASE
			FIQ->FIQ_VLRAVP := FIQ->FIQ_BASE
			FIQ->FIQ_STATUS := "R"		//AVP Realizado Completamente
		Else
			FIQ_STATUS := "B"		//AVP Realizado Parcialmente
		Endif
		MsUnlock()
		
		If FIQ->FIQ_STATUS == "B"
			cSeq := FIQ->FIQ_SEQ
			nAAprop := FIQ->(FIQ_BASE - FIQ_VLRAVP)
			
			// Carrega em aCampos o conteudo dos campos do FIQ
			For nX := 1 To fCount()
				Aadd(aCampos, {FieldName(nX), FieldGet(nX)})
			Next
			
			cSeq2 :=  FNxtAvpSeq("FIQ",FIQ_PREFIX,FIQ_NUM,FIQ_PARCEL,FIQ_TIPO,FIQ_FORNEC,FIQ_LOJA)
			
			RecLock("FIQ",.T.)
			// Descarrega aCampos no FIM para que todos os campos preenchidos no registro realizado parcialmente
			// sejam replicados ao novo registro de AVP do titulo
			For nX := 1 To fCount()
				If !Empty(aCampos[nX][2])
					FieldPut(nX,aCampos[nX][2])
				Endif
			Next
			FIQ->FIQ_BASE		-= FIS->FIS_VLRAVP
			FIQ->FIQ_VLRAVP	:= FIQ->FIQ_BASE - nAAprop
			
			FIQ->FIQ_STATUS	:= "A"		//AVP Ativo
			FIQ->FIQ_SEQ		:= cSeq2 
			
			MsUnlock()
		Endif
	Endif
	
	//Atualizo o Status como Efetivado
	RecLock("FIS", .F.)
	FIS->FIS_STATUS 	:= "E"
	FIS->FIS_SEQ 		:= FIQ->FIQ_SEQ
	MsUnLock()
	nRecno := FIQ->(Recno())
	
Endif

Return nRecno


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ChecErro ณ Autor ณ Mauricio Pequim Jr	  ณ Data ณ 21/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Rotina analizadora do erro                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION ChecErro(e,cCritica)

IF e:gencode > 0
	//   HELP(" ",1,"ERR_FORM",,e:Description,3,1)
	cCritica := e:Description
	lRet:=.F.
Endif
BREAK

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFavpefet  บAutor  ณMicrosiga           บ Data ณ  12/23/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de efetivacao dos processos de AVP                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                       	                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FAvpEfet(cAliasMov,nRecnoMov)

Local cProcess 	:= ""
Local cAliasAvp	:= If(cAliasMov == "FIP","FIN","FIQ")
Local dDtProc	:= CTOD("")
Local dDtAtuAvp := CTOD("")
Local cCritica 	:= " "
Local lJaConst 	:= .F.
Local cChaveTit := ""
Local cTipoProc := ""
Local cChaveAVP := ""
Local nRecno	:= 0
Local aArea		:= GetArea()

//Posiciono a tabela de movimentos
(cAliasMov)->(dbGoto(nRecnoMov))

//Obtenho dados para a Efetivacao
cProcess	 := If(cAliasMov == "FIP", FIP->FIP_PROC , FIS->FIS_PROC )
cTipoProc := If(cAliasMov == "FIP", FIP->FIP_TIPAVP , FIS->FIS_TIPAVP )
cChaveAVP := If(cAliasMov == "FIP", FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA),;
FIS->(FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA) )

cChaveTit := If(cAliasMov == "FIP", FIP->(FIP_CLIENT+FIP_LOJA+FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO),;
FIS->(FIS_FORNEC+FIS_LOJA+FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO) )

//Posiciono o cadastro de titulos
If cAliasMov == "FIP
	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(dbSetOrder(2))
	SE1->(MsSeek(xFilial("SE1")+cChaveTit))
Else
	//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	SE2->(dbSetOrder(6))
	SE2->(MsSeek(xFilial("SE2")+cChaveTit))
Endif

//Data do processamento
//Se Constituicao - Data de emissao do titulo
//Se outro processo - Data do Movimento
IF cTipoProc == "C"
	dDtProc	 := If(cAliasMov == "FIP", SE1->E1_EMISSAO , SE2->E2_EMISSAO )
Else
	dDtProc	 := If(cAliasMov == "FIP", FIP->FIP_DTAVP , FIS->FIS_DTAVP )
Endif


//Verifico se jแ existe AVP posterior ao processo que esta sendo efetivado
(cAliasAvp)->(dbSetOrder(2))
If (cAliasAvp)->(MsSeek(xFilial(cAliasAvp)+cChaveAvp+"A"))
	
	dDtAtuAvp := If (cAliasAvp == "FIN", FIN->FIN_DTAVP, FIQ->FIQ_DTAVP)
	//Se o movimento AVP for de Constituicao e ja exista registro AVP para o titulo (tabelas FIM ou FIP)
	lJaConst	 := If (cTipoProc == "C", .T., .F.)
Endif

//Se existir AVP efetivado com data posterior, gravo critica
//Mas nao atualizo o AVP do titulo
If dDtAtuAvp > dDtProc .or. lJaConst
	cCritica := STR0003 // "Movimento nao efetivado por existir processo de AVP com data igual ou posterior ou constituicao ja efetuada"
	RecLock(cAliasMov)
	If cAliasMov == "FIP"
		FIP->FIP_CRITIC := cCritica
	Else
		FIS->FIS_CRITIC   := cCritica
	EndIf
	MsUnlock()
	cCritica := " "
Else
	//Grava Efetivacao do AVP
	nRecno := FGRVAVPTIT(cAliasMov,nRecnoMov)
Endif


RestArea(aArea)
Return nRecno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetAVPComboบAutor  ณAlvaro Camillo Neto บ Data ณ  22/12/09  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o array do combo do campo                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940 e FINA950                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetAVPCombo(cCampo )
Local aCombo 	:= {}
Local cCombo 	:= {}
Local aArea	 	:= GetArea()
Local aAreaSX3 := SX3->(GetArea())

SX3->(dbSetOrder(2))
If SX3->(MsSeek(cCampo))
	cCombo := SX3->( X3CBox() )
	aCombo := STRTOKARR ( cCombo , ';' )
EndIf

RestArea(aAreaSX3)
RestArea(aArea)
Return aCombo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinAVPInvG บAutor  ณAlvaro Camillo Neto บ Data ณ22/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInverte a marca็ใo da getdados                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940 e FINA950                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinAVPInvG(oGet)
Local nX	:= 0
Local nPosMarca	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))== 'CHECKBOL' })

If nPosMarca > 0
	For nX := 1 to Len(oGet:aCols)
		If oGet:aCols[nX,nPosMarca] == COR_NAOMARCA
			oGet:aCols[nX,nPosMarca]:= COR_MARCA
		Else
			oGet:aCols[nX,nPosMarca]:= COR_NAOMARCA
		EndIf
	Next nX
EndIf

oGet:oBrowse:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinAVPMTodG บAutor  ณAlvaro Camillo Neto บ Data ณ22/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos os registros da getdados                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940 e FINA950                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinAVPMTodG(oGet)
Local nX	:= 0
Local nPosMarca	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='CHECKBOL'})

If nPosMarca > 0
	For nX := 1 to Len(oGet:aCols)
		If oGet:aCols[nX,nPosMarca] == COR_NAOMARCA
			oGet:aCols[nX,nPosMarca]:= COR_MARCA
		EndIf
	Next nX
EndIf
oGet:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinAVPTInf  บAutor  ณAlvaro Camillo Neto บ Data ณ22/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche todos os campos com a taxa informada e o periodo   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940 E FINA950                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinAVPTInf(oGet,nTxInfor,cPeriod,cCpoTx,cCpoPer)
Local nX				:= 0
Local nPosTXInfor		:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==cCpoTx})
Local nPosTXPeriod	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==cCpoPer})
Local nPosMarca		:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='CHECKBOL'})
Local lAplicTodos		:= .F.

If nPosTXInfor > 0 .And. nPosTXPeriod > 0
	lAplicTodos := MsgNoYes(STR0001,STR0002) //"Deseja aplicar a todos os registros?"##"Aten็ใo"
	
	For nX := 1 to Len(oGet:aCols)
		If !lAplicTodos
			If nPosMarca > 0
				If oGet:aCols[nX,nPosMarca] == COR_NAOMARCA
					Loop
				EndIf
			EndIf
		EndIf
		
		oGet:aCols[nX,nPosTXInfor]:= nTxInfor
		oGet:aCols[nX,nPosTXPeriod]:= cPeriod
	Next nX
EndIf
oGet:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinAVPTFor  บAutor  ณAlvaro Camillo Neto บ Data ณ22/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche todos os campos com a formula informada            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940 E FINA950                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinAVPTFor(oGet,cFormula,cCpoForm)
Local nX				:= 0
Local nPosFormula := aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==cCpoForm})

If nPosFormula > 0
	If MsgNoYes(STR0001,STR0002) //"Deseja aplicar a todos os registros?"##"Aten็ใo"
		For nX := 1 to Len(oGet:aCols)
			oGet:aCols[nX,nPosFormula]:= cFormula
		Next nX
	EndIf
EndIf
oGet:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinAVPTInd  บAutor  ณAlvaro Camillo Neto บ Data ณ22/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche todos os campos com o Indice Informado             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940 e FINA950                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinAVPTInd(oGet,cIndice,cCpoInd)
Local nX				:= 0
Local nPosIndice := aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==cCpoInd})

If nPosIndice > 0
	If MsgNoYes(STR0001,STR0002) //"Deseja aplicar a todos os registros?"##"Aten็ใo"
		For nX := 1 to Len(oGet:aCols)
			oGet:aCols[nX,nPosIndice]:= cIndice
		Next nX
	EndIf
EndIf

oGet:oBrowse:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinAVPTOK บAutor  ณAlvaro Camillo Neto บ Data ณ  09/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a GetDados de contstiuicao de AVP                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINXAVP                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinAVPTOK(oGet,aRetPer,aDadosPer,cCpoTx,cCpoPer,cCpoForm,cCpoInd)
Local lRet 			:= .T.
Local nX	   		:= 0
Local nCont			:= 0
Local aCols	  		:= oGet:aCols
Local nPosIndice 	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==cCpoInd})
Local nPosFormula 	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==cCpoForm})
Local nPosTXInfor 	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==cCpoTx})
Local nPosTXPeriod 	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==cCpoPer})
Local nPosMarca		:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='CHECKBOL'})
Local dDataProc		:= aRetPer[DATA_PROC]
Local aValidInd		:= {}

For nX := 1 to Len(aCols)
	If nPosMarca > 0 .And. aCols[nX][nPosMarca] == COR_MARCA
		
		If lRet .And. nPosIndice > 0 .And. Empty(aCols[nX][nPosIndice])
			lRet := .F.
			Help(" ",1,"FINAVPNOIND",,STR0004 + cValToChar(nX) ,1,0) //"Nใo hแ indice cadastrado na linha "
		EndIf
		
		// Valida se o indice informado encontra-se bloqueado no cadastro
		If lRet .And. nPosIndice > 0 .And. !Empty(aCols[nX][nPosIndice])
			
			FIT->(DbSetOrder(1))
			FIT->(DbSeek(xFilial("FIT")+aCols[nX][nPosIndice]))
			IF FIT->FIT_BLOQ == "1"
				lRet := .F.
				Help(" ",1,"FINAVPBLIND",,STR0018 +": "+ cValToChar(nX) ,1,0) //"O indice informado encontra-se bloqueado."
			ENDIF
		EndIf
		
		// Valida a existencia de um indice para o perํodo de calculo
		// Em fun็ใo da performance verifica primeiro se o indice jแ nใo foi validado anteriormente.
		If lRet .And. nPosIndice > 0 .And. aScan(aValidInd,{|cIndice|  cIndice == aCols[nX][nPosIndice]}) == 0
			
			// A valida็ใo define a condi็ใo de aceite da taxa em fun็ใo da periodicidade do indice
			lRet := .F.
			
			FIT->(DbSetOrder(1))
			FIT->(DbSeek(xFilial("FIT")+aCols[nX][nPosIndice]))
			
			FIU->(DbSetOrder(1))
			FIU->(DbSeek(xFilial("FIT")+aCols[nX][nPosIndice]+DTOS(aRetPer[DATA_PROC]),.F.))
			
			IF FIU->FIU_CODIND != aCols[nX][nPosIndice]
				WHILE FinAVPDTV(dDataProc,aRetPer[DATA_PROC],FIT->FIT_PERIOD)
					dDataProc--
					IF FIU->(DbSeek(xFilial("FIT")+aCols[nX][nPosIndice]+DTOS(dDataProc),.F.))
						Exit
					ENDIF
				END
			ENDIF
			
			IF FIU->FIU_CODIND == aCols[nX][nPosIndice]
				lRet := FinAVPDTV(FIU->FIU_DATA,aRetPer[DATA_PROC],FIT->FIT_PERIOD)
			ENDIF
			
			IF !lRet
				Help(" ",1,"FINAVPIND",,STR0017,1,0) //"Nใo hแ taxa para o indice especificado no perํodo."
			Else
				aAdd(aValidInd,aCols[nX][nPosIndice])
			Endif
			
		EndIf
		
		If lRet .And. nPosFormula > 0 .And. Empty(aCols[nX][nPosFormula])
			lRet := .F.
			Help(" ",1,"FINAVPNOFOR",,STR0005 + cValToChar(nX) ,1,0)//"Nใo hแ f๓rmula cadastrada na linha "
		EndIf
		
		If lRet .And. nPosTXInfor > 0 .And. Empty(aCols[nX][nPosTXInfor])
			lRet := .F.
			Help(" ",1,"FINAVPNOTX",,STR0006 + cValToChar(nX) ,1,0)//"Nใo hแ taxa cadastrada na linha "
		EndIf
		
		If lRet .And. nPosTXPeriod > 0 .And. Empty(aCols[nX][nPosTXPeriod])
			lRet := .F.
			Help(" ",1,"FINAVPNOPER",,STR0007 + cValToChar(nX) ,1,0)//"Nใo hแ periodo cadastrado na linha "
		EndIf
		
		If lRet
			nCont++
		Else
			Exit
		EndIf
		
	EndIf
	
Next nX

If lRet .And. nCont == 0
	Help(" ",1,"FINAVPNOMAR",,STR0008,1,0) //"Nใo hแ registros marcados "
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinAVPDTVบAutor ณArnaldo Raymundo Jr.บ Data ณ  26/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida da data de processamento em rela็ใo ao periodo.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINXAVP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FinAVPDTV(dDataProc,dRetProc,cPeriodo)
Local lRet := .F.

IF		cPeriodo == P_DIARIO .AND. 	dDataProc == dRetProc
	lRet := .T.
ELSEIF 	cPeriodo == P_MENSAL .AND. 	Month(dDataProc) == Month(dRetProc) .AND.;
	Year(dDataProc) == Year(dRetProc)
	lRet := .T.
ELSEIF 	cPeriodo == P_TRIMESTRAL .AND. 	Month(dRetProc) >= 	Month(dDataProc) .AND.;
	Month(dRetProc) <= 	Month(dDataProc)+2 .AND.;
	Year(dDataProc) == Year(dRetProc)
	lRet := .T.
ELSEIF 	cPeriodo == P_SEMESTRAL .AND. 	Month(dRetProc) >= 	Month(dDataProc) .AND.;
	Month(dRetProc) <= 	Month(dDataProc)+5 .AND.;
	Year(dDataProc) == Year(dRetProc)
	lRet := .T.
ELSEIF 	cPeriodo == P_ANUAL .AND. 		Year(dDataProc) == Year(dRetProc)
	lRet := .T.
ENDIF


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinAVPIDOKบAutor ณARNALDO RAYMUNDO JR.บ Data ณ  30/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o indice estแ apto para utilizacao              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออIออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINXAVP                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinAVPIDOK(cIndice,aRetPer)
Local lRet 			:= .T.
Local dDataProc		:= aRetPer[DATA_PROC]

If !Empty(cIndice)
	FIT->(DbSetOrder(1))
	FIT->(DbSeek(xFilial("FIT")+cIndice))
	
	// Valida se o indice estแ bloqueado
	IF FIT->FIT_BLOQ == "1"
		lRet := .F.
		Help(" ",1,"FINAVPBLIND",,STR0018,1,0) //"O indice informado encontra-se bloqueado."
	ENDIF
	
	// Valida a existencia de um indice para o perํodo de calculo
	If lRet .And. aRetPer[METODO] == INDICE_FINANCEIRO
		
		// A valida็ใo define a condi็ใo de aceite da taxa em fun็ใo da periodicidade do indice
		lRet := .F.
		
		FIU->(DbSetOrder(1))
		FIU->(DbSeek(xFilial("FIT")+cIndice+DTOS(aRetPer[DATA_PROC]),.F.))
		
		IF FIU->FIU_CODIND != cIndice
			WHILE FinAVPDTV(dDataProc,aRetPer[DATA_PROC],FIT->FIT_PERIOD)
				dDataProc--
				IF FIU->(DbSeek(xFilial("FIT")+cIndice+DTOS(dDataProc),.F.))
					Exit
				ENDIF
			END
		ENDIF
		
		IF FIU->FIU_CODIND == cIndice
			lRet := FinAVPDTV(FIU->FIU_DATA,aRetPer[DATA_PROC],FIT->FIT_PERIOD)
		ENDIF
		
		IF !lRet
			Help(" ",1,"FINAVPIND",,STR0017,1,0) //"Nใo hแ taxa para o indice especificado no perํodo."
		Endif
	Endif
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAVPFlagTabบAutor ณAlvaro Camillo Neto บ Data ณ  22/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o Update dos campos de flag setando quais registros บฑฑ
ฑฑบ          ณcada thread irแ processar.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FAVPFlagTab(cTabMult,aProcs,cCpoFlag,cCpoCond)
Local aArea		:= GetArea()
Local nX			:= 0
Local nCount	:= 0
Local cChave	:= ""
Local cCompar	:= ""

// Campos que serใo utilizados para definir a condi็ใo de divisใo dos registros
// Enquanto a expressใo estiver na tabela esse conjunto ficara com a mesma marca.
Default cCpoCond := ''

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDescobre o Recno Mแximo e Minimo de cada ณ
//ณintervalo                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
(cTabMult)->(dbGoTop())
If (cTabMult)->(!EOF())
	For nX := 1 to Len(aProcs)
		nCount  := 0
		If !Empty(cCpoCond)
			cChave := ALLTRIM((cTabMult)->&(cCpoCond))
		EndIf
		
		While (cTabMult)->(!EOF())
			If !Empty(cCpoCond)
				cCompar := (cTabMult)->&(cCpoCond)
			EndIf
			nCount++
			If ( nCount <= aProcs[nX][QTD_REGISTROS] .Or. ( !Empty( cCpoCond ) .AND. cChave == ALLTRIM( cCompar ) ) )
				RecLock(cTabMult,.F.)
				(cTabMult)->&(cCpoFlag) := aProcs[nX][MARCA]
				MsUnlock()
			Else
				RecLock(cTabMult,.F.)
				(cTabMult)->&(cCpoFlag) := aProcs[nX + 1][MARCA]
				MsUnlock()
				Exit
			EndIf
			(cTabMult)->(dbSkip())
		End
	Next nX
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAVPMonitorบAutorณAlvaro Camillo Neto บ Data ณ  22/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsavel por monitorar as threads de processamen บฑฑ
ฑฑบ          ณ to                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FAVPMonitor(aProcs)
Local lRet			:= .T.
Local nX			:= 0
Local aConcluido	:= {}
Local nHandle		:= 0
Local cMsg			:= ""

While .T.
	For nX := 1 to Len(aProcs)
		nHandle := FAVPLock(aProcs[nX][ARQUIVO])
		If  nHandle >= 0
			fClose(nHandle)
			If aScan(aConcluido,{|aItem| aItem[3] == aProcs[nX][MARCA]} ) == 0
				AADD(aConcluido, { nHandle, aProcs[nX][ARQUIVO], aProcs[nX][MARCA]})
			EndIf
		EndIf
	Next nX
	
	If Len(aConcluido) >= Len(aProcs)
		Exit
	EndIF
	Sleep(5000)
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se todas a threads foram processadas corretamenteณ
//ณlibera o recurso e apaga o arquivo                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aConcluido)
	FT_FUse(aConcluido[nX][2])
	FT_FGoTop()
	cMsg := FT_FReadLn()
	FT_FUse()
	fErase(aConcluido[nX][2])
	If lRet .And. ALLTRIM(cMsg) != OK
		lRet := .F.
	EndIf
Next nX

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFAVPLock  ณ Autor ณAlvaro Camillo Neto    ณ Data ณ 03/02/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณCria arquivo para travar processos e garantir que sao unicosณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณFINA940                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function FAVPLock(cFile)
Local nHJob := 0
If File(cFile)
	nHJob := FOPEN(cFile,2)
Else
	nHJob := FCREATE(cFile)
EndIf
Return nHJob

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFAVPUnLockณ Autor ณAlvaro Camillo Neto    ณ Data ณ 03/02/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณEncerra a trava                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณFINA940                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function FAVPUnLock(nHandle,lOk)
Local cMsg := IIF(lOk,OK,ERRO)
FWRITE(nHandle,cMsg)
FCLOSE(nHandle)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAVPNextAliasบAutorณAlvaro Camillo Neto บ Data ณ  14/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProte็ใo para retornar o pr๓ximo alias disponivel no Banco  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FAVPNextAlias()
Local cNextAlias := ""
Local aArea := GetArea()

While .T.
	cNextAlias := GetNextAlias()
	If !TCCanOpen(cNextAlias) .And. Select(cNextAlias) == 0
		Exit
	EndIf
EndDo

RestArea(aArea)
Return cNextAlias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAVPSelJobบAutor  ณAlvaro Camillo Neto บ Data ณ  28/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona os dados para o Job de tratamento Multithread    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FAVPSelJob(cTabMaster,aStructTab,cCpoFlag,cMarca)
Local cTabJob	 := FAVPNextAlias()
Local cQuery	 := ""
Local nX			 := 0

cQuery += " SELECT "
For nX := 1 to Len(aStructTab)
	cQuery += " "+aStructTab[nX][1]+"  ,"
Next nX
cQuery := Left(cQuery,Len(cQuery)-1)
cQuery +=" FROM "+cTabMaster+ " "
cQuery +=" WHERE " + cCpoFlag + " = '"+cMarca+"'"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTabJob, .F., .T.)

For nX := 1 to Len(aStructTab)
	If aStructTab[nX][2] <> "C"
		TcSetField(cTabJob ,aStructTab[nX][1],aStructTab[nX][2],aStructTab[nX][3],aStructTab[nX][4])
	EndIf
Next nX
(cTabJob)->(dbGotop())

Return cTabJob

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAVPPrepProcบAutorณAlvaro Camillo Neto บ Data ณ  28/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrepara as informacoes para o processamento multithread     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FAVPPrepProc(nNumProc,cTabTemp,nTotalReg,cCpoFlag,cRaizNome,cCpoCond)
Local aProcs 		:= Array(nNumProc)
Local nX		 		:= 0
Local cDirSem  	:= "\Semaforo\"
Local cNomeArq		:= ""
Local cMarca  		:= ""
Local nRegAProc	:= 0 // Registros a processar
Local nRegJProc	:= 0 // Total de registros jแ processados

Default cCpoCond := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria a pasta do semaforo caso nใo existaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !ExistDir(cDirSem)
	MontaDir(cDirSem)
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o calculos das quantidades de registrosณ
//ณque cada thread irแ processar e                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aProcs)
	cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX) + '.lck'
	cMarca		:= GetMark()
	nRegAProc	:= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
	nRegJProc	+= nRegAProc
	aProcs[nX]	:= {cNomeArq ,cMarca,nRegAProc }
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o Update dos campos de flag setando quais registrosณ
//ณcada thread irแ processar.                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FAVPFlagTab(cTabTemp,aProcs,cCpoFlag,cCpoCond)

Return aProcs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinRetInd บAutor  ณAlvaro Camillo Neto บ Data ณ  28/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Indice financeiro ou o ultimo indice disponivel  บฑฑ
ฑฑบ          ณ at้ a data                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinRetInd(cCodInd,dDataProc)
Local nIndice 	:= 0
Local aArea		:= GetArea()
Local cQuery	:= ""
Local dDataConv:= StoD("")
Local cTab		:= FAVPNextAlias()

If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf
cQuery := " SELECT MAX(FIU_DATA) FIU_DATA FROM " + RetSQLTab("FIU")+ " WHERE "
cQuery += " FIU_CODIND = '" +cCodInd+"' AND"
cQuery += " FIU_DATA <= '" + DtoS(dDataProc) +"' AND "
cQuery += RetSQLCond("FIU")
cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab )
TCSetField(cTab, "FIU_DATA" ,"D", 8, 0 )
If (cTab)->(!EOF())
	dDataConv := (cTab)->FIU_DATA
	If FIU->(MsSeek( xFilial("FIU") + cCodInd + dToS(dDataConv)  ))
		nIndice := FIU->FIU_INDICE
	Endif
EndIf
(cTab)->(dbCloseArea())

RestArea(aArea)
Return nIndice



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAVPEST   บAutor  ณMicrosiga           บ Data ณ  12/23/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de estorno dos processos de AVP  		              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                       	                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FAvpEst(cAliasMov,nRecnoMov)

Local cProcess := ""
Local dDtProc	:= CTOD("")
Local cChaveTit := ""
Local cTipoProc := ""
Local cChaveAVP := ""
Local nRecno	 := 0
Local aArea		 := GetArea()

//Posiciono a tabela de movimentos
(cAliasMov)->(dbGoto(nRecnoMov))

//Obtenho dados para a Efetivacao
cProcess	 := If(cAliasMov == "FIP", FIP->FIP_PROC , FIS->FIS_PROC )
cTipoProc := If(cAliasMov == "FIP", FIP->FIP_TIPAVP , FIS->FIS_TIPAVP )
cChaveAVP := If(cAliasMov == "FIP", FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA),;
FIS->(FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA) )

cChaveTit := If(cAliasMov == "FIP", FIP->(FIP_CLIENT+FIP_LOJA+FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO),;
FIS->(FIS_FORNEC+FIS_LOJA+FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO) )

//Posiciono o cadastro de titulos
If cAliasMov == "FIP
	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(dbSetOrder(2))
	SE1->(MsSeek(xFilial("SE1")+cChaveTit))
Else
	//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	SE2->(dbSetOrder(6))
	SE2->(MsSeek(xFilial("SE2")+cChaveTit))
Endif

//Data do processamento
//Se Constituicao - Data de emissao do titulo
//Se outro processo - Data do Movimento
IF cTipoProc == "C"
	dDtProc	 := If(cAliasMov == "FIP", SE1->E1_EMISSAO , SE2->E2_EMISSAO )
Else
	dDtProc	 := If(cAliasMov == "FIP", FIP->FIP_DTAVP , FIS->FIS_DTAVP )
Endif

//Grava Estorno do AVP
nRecno := FGRVAVPEST(cAliasMov,nRecnoMov)

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ FGRVAVPEST ณ Autor ณ Mauricio Pequim Jr. ณ Data ณ 16/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Rotina de Gravacao do registro de AVP							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ FGRVAVPEST(ExpC1,ExpN2)                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC01=Alias do arquivo de Movimentos AVP                  ณฑฑ
ฑฑณ          ณ ExpN02=Recno do movimento do AVP   			                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FGRVAVPEST(cAliasMov,nRecnoMov)

Local cSeq		:= StrZero(0,tamSx3("FIQ_SEQ")[1])
Local nRecno	:= 0
Local nAEstornar := 0

If cAliasMov == "FIP"
	
	//---------------------------------------------------------------------------------
	//Contas a RECEBER
	//---------------------------------------------------------------------------------
	
	//Posiciono a tabela de movimento
	FIP->(dbGoto(nRecnoMov))
	
	If FIP->FIP_TIPAVP == "C" //Constituicao
		
		FIN->(dbSetOrder(1))
		If FIN->(MsSeek(xFilial("FIN")+FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA+FIP_SEQ))) .and. ;
			FIN->FIN_STATUS == "A"
			
			//Gravo a informacao de estorno do registro AVP do titulo
			RecLock("FIN",.F.)
			FIN_STATUS	:= "X"		//AVP estornado
			MsUnLock()
		Endif
		
	ElseIf FIP->FIP_TIPAVP $ "A#R" 	//Ajuste ou Realizacao
		
		//Procuro o registro AVP ativo do titulo
		FIN->(dbSetOrder(1))
		If FIN->(MsSeek(xFilial("FIN")+FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA+FIP_SEQ)))
			
			RecLock("FIN",.F.)
			FIN->FIN_VLRAVP	-= FIP->FIP_VLRAVP //Valor do titulo ajustado para a data de ajuste
			FIN->FIN_STATUS := "A"		//AVP Realizado Completamente
			MsUnLock()
			
		Endif
		
	ElseIf FIP->FIP_TIPAVP $ "B" 	//Baixa
		
		//Procuro o registro AVP ativo do titulo
		FIN->(dbSetOrder(1))
		If FIN->(MsSeek(xFilial("FIN")+FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA+FIP_SEQ))) .and. ;
			FIN->FIN_STATUS != "X"
			
			If FIN->FIN_STATUS == "A"
				cSeq := FIN->FIN_SEQ
				nAEstornar := FIN->FIN_VLRAVP
				
				// Registra o estorno no
				RecLock("FIN",.F.)
				FIN->FIN_STATUS := "X"		//AVP Realizado Completamente
				MsUnlock()
				
			Endif
		Endif
		
	Endif
	
	//Atualizo o Status como Efetivado
	RecLock("FIP", .F.)
	FIP->FIP_STATUS 	:= "X"
	MsUnLock()
	
Else
	
	//---------------------------------------------------------------------------------
	//Contas a PAGAR
	//---------------------------------------------------------------------------------
	
	//Posiciono a tabela de movimento
	FIS->(dbGoto(nRecnoMov))
	
	If FIS->FIS_TIPAVP == "C" //Constituicao
		
		FIQ->(dbSetOrder(1))
		If FIQ->(MsSeek(xFilial("FIQ")+FIS->(FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA+FIS_SEQ))) .and. ;
			FIQ->FIQ_STATUS == "A"
			
			//Gravo a informacao de estorno do registro AVP do titulo
			RecLock("FIQ",.F.)
			FIQ_STATUS	:= "X"		//AVP estornado
			MsUnLock()
		Endif
		
	ElseIf FIS->FIS_TIPAVP $ "A#R" 	//Ajuste ou Realizacao
		
		//Procuro o registro AVP ativo do titulo
		FIQ->(dbSetOrder(1))
		If FIQ->(MsSeek(xFilial("FIQ")+FIS->(FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA+FIS_SEQ)))
			
			RecLock("FIQ",.F.)
			FIQ->FIQ_VLRAVP	-= FIS->FIS_VLRAVP //Valor do titulo ajustado para a data de ajuste
			FIQ->FIQ_STATUS := "A"		//AVP Realizado Completamente
			MsUnLock()
			
		Endif
		
	ElseIf FIS->FIS_TIPAVP $ "B" 	//Baixa
		
		//Procuro o registro AVP ativo do titulo
		FIQ->(dbSetOrder(1))
		If FIQ->(MsSeek(xFilial("FIQ")+FIS->(FIS_PREFIX+FIS_NUM+FIS_PARCEL+FIS_TIPO+FIS_FORNEC+FIS_LOJA+FIS_SEQ))) .and. ;
			FIQ->FIQ_STATUS != "X"
			
			If FIQ->FIQ_STATUS == "A"
				cSeq := FIQ->FIQ_SEQ
				nAEstornar := FIQ->FIQ_VLRAVP
				
				// Registra o estorno no
				RecLock("FIQ",.F.)
				FIQ->FIQ_STATUS := "X"		//AVP Realizado Completamente
				MsUnlock()
				
			Endif
		Endif
		
	Endif
	
	//Atualizo o Status como Efetivado
	RecLock("FIS", .F.)
	FIS->FIS_STATUS 	:= "X"
	MsUnLock()
	
Endif

Return nRecno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFNXTAVPSEQบAutor  ณMicrosiga           บ Data ณ  07/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Acha nova sequencia de AVP                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                              	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FNxtAvpSeq(cAliasAVP,cPrefixo,cNum,cParc,cTipo,cCLiFor,cLoja,lNextSeq)

Local cAliasQry := ""
Local cQuery := ""
Local cNextSeq := ""
Local nTamSeq	:= TamSx3("FIN_SEQ")[1]
Local aArea		:= GetArea()

Default lNextSeq := .T.

cAliasQry := FAVPNextAlias()

If cAliasAVP == "FIN"
	
	cQuery := " SELECT "
	cQuery += " 	MAX(FIN_SEQ) FINMAXSEQ  "
	cQuery += " FROM "  + RetSQLTab("FIN") + " WHERE "
	cQuery += " 		FIN_PREFIX = '"	+ cPrefixo	+ "' AND "
	cQuery += " 		FIN_NUM = '" 		+ cNum		+ "' AND "
	cQuery += " 		FIN_PARCEL = '" 	+ cParc		+ "' AND "
	cQuery += " 		FIN_TIPO = '"		+ cTipo		+ "' AND "
	cQuery += " 		FIN_CLIENT = '"	+ cCliFor	+ "' AND "
	cQuery += " 		FIN_LOJA	= '"		+ cLoja		+ "' AND "
	cQuery += RetSqlCond("FIN")
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry )
	
	TcSetField(cAliasQry ,"FINMAXSEQ","C",nTamSeq,0)
	
	If !Empty((cAliasQry)->FINMAXSEQ) .And. (cAliasQry)->(!Eof())
		cNextSeq := (cAliasQry)->FINMAXSEQ
	Endif
	
	dbSelectArea(cAliasQry)
	dbCloseArea()
	
Else
	
	cQuery := " SELECT "
	cQuery += " 	MAX(FIQ_SEQ) FIQMAXSEQ  "
	cQuery += " FROM "  + RetSQLTab("FIQ") + " WHERE "
	cQuery += " 		FIQ_PREFIX = '"	+ cPrefixo	+ "' AND "
	cQuery += " 		FIQ_NUM = '" 		+ cNum		+ "' AND "
	cQuery += " 		FIQ_PARCEL = '" 	+ cParc		+ "' AND "
	cQuery += " 		FIQ_TIPO = '"		+ cTipo		+ "' AND "
	cQuery += " 		FIQ_FORNEC = '"	+ cCliFor	+ "' AND "
	cQuery += " 		FIQ_LOJA	= '"		+ cLoja		+ "' AND "
	cQuery += RetSqlCond("FIQ")
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry )
	
	TcSetField(cAliasQry ,"FIQMAXSEQ","C",nTamSeq,0)
	
	If !Empty((cAliasQry)->FIQMAXSEQ) .And. (cAliasQry)->(!Eof())
		cNextSeq := (cAliasQry)->FIQMAXSEQ
	Endif
	
	dbSelectArea(cAliasQry)
	dbCloseArea()
	
Endif

If Empty(cNextSeq)
	cNextSeq := STRZERO(1,nTamSeq)
Else
	If lNextSeq
		cNextSeq := Soma1(cNextSeq,nTamSeq)
	EndIf	
EndIf

RestArea(aArea)

Return cNextSeq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAVPValTitบAutor  ณOrizio              บ Data ณ  22/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe movimento de AVP para determinado tituloบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC01=Alias do arquivo de Movimentos AVP                  บฑฑ
ฑฑบ          ณ ExpN02=Recno do SE5                	                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FAVPValTit( cAlias, nRecSE5, cPrefixo, cNumero, cParc, cTipo, cCliFor, cLoja, cSeq, lAutomat )
Local aArea	  		:= GetArea()
Local aAreaSE5		:= SE5->( GetArea() )
Local cIdTit  		:= ""
Local lAlerta		:= .F.
Local lAVPEst       := .F.
Local lRet			:= .T.
Local lUtilAVP		:= .T.

Default cAlias		:= ""
Default cPrefixo	:= ""
Default cNumero	    := ""
Default cParc		:= ""
Default cTipo		:= ""
Default cCliFor	    := ""
Default cLoja		:= ""
Default cSeq		:= ""
Default lAutomat    := .F.
Default nRecSE5	:= 0 //nRecSE5 > 0 = Baixa / nRecSE5 == 0 = Exclusao de documento

If lUtilAVP
	If nRecSE5 > 0
		SE5->( DbGoTo( nRecSE5 ) )
		
		cPrefixo	:= SE5->E5_PREFIXO
		cNumero		:= SE5->E5_NUMERO
		cParc		:= SE5->E5_PARCELA
		cTipo		:= SE5->E5_TIPO
		cCliFor		:= SE5->E5_CLIFOR
		cLoja		:= SE5->E5_LOJA
		cSeq		:= SE5->E5_SEQ
	EndIf
	
	If cAlias == "SE1"
		DbSelectArea( "FIP" )
		FIP->( DbSetOrder( 3 ) )
		If FIP->( DbSeek( xFilial( "FIP" ) + cPrefixo + cNumero + cParc + cTipo + cCliFor + cLoja + cSeq ) )

			lAlerta := .T.
            lAVPEst := IIF( FIP->FIP_STATUS=="X" , .T., .F.)
			cPadrao := IIF( nRecSE5 <= 0 , "5B5" , "5B7" )
			
			cIdTit	:= STR0010 + cPrefixo + CRLF
			cIdTit	+= STR0011 + cNumero + CRLF
			cIdTit	+= STR0012 + cParc + CRLF
			cIdTit	+= STR0013 + cTipo + CRLF
			cIdTit	+= STR0014 + cCliFor + CRLF
			cIdTit	+= STR0015 + cLoja
		EndIf
	ElseIf cAlias == "SE2"
		DbSelectArea( "FIS" )
		FIS->( DbSetOrder( 3 ) )
		If FIS->( DbSeek( xFilial( "FIS" ) + cPrefixo + cNumero + cParc + cTipo + cCliFor + cLoja + cSeq ) )
			
            lAlerta := .T.
            lAVPEst := IIF( FIS->FIS_STATUS=="X" , .T., .F.)
			cPadrao := IIF( nRecSE5 <= 0 , "5B6" , "5B8" )
			
			cIdTit	:= STR0010 + cPrefixo + CRLF
			cIdTit	+= STR0011 + cNumero + CRLF
			cIdTit	+= STR0012 + cParc + CRLF
			cIdTit	+= STR0013 + cTipo + CRLF
			cIdTit	+= STR0016 + cCliFor + CRLF
			cIdTit	+= STR0015 + cLoja
		EndIf
	EndIf
	
	If lAlerta .AND. !VerPadrao(cPadrao)

        If lAVPEst
            If !lAutomat
                If !(MSGYESNO(STR0020+CHR(10)+CHR(13)+STR0021, STR0002)) //"Existem movimentos de AVP estornados para esse tํtulo." #"Deseja realmente prosseguir com a exclusใo?"	
                    lRet := .F.
                Endif
            Endif
        Else
            Help( " ", 1, "FINAVPBX",, STR0009 + CRLF + cIdTit, 1, 1 ,,,,,, {STR0019}) //"Existem movimentos de AVP. Efetuar ajuste contแbil ou estorno do processo de AVP."
	    	lRet := .F.
	    EndIf
    Endif
	
EndIf

RestArea( aAreaSE5 )
RestArea( aArea )

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAVPCTBExcบAutor  ณAlvaro Camillo Neto บ Data ณ  02/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a contabilizacao do estorno do AVP                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FAVPCTBExc( cAlias,nHdlPrv,cRotina,cLote,nRecSE5, cPrefixo, cNumero, cParc, cTipo, cCliFor, cLoja, cSeq )
Local aArea	  		:= GetArea()
Local aAreaSE5		:= SE5->( GetArea() )
Local lUtilAVP		:= .T.
Local nTotalAVP	:= 0

Default cAlias		:= ""
Default cPrefixo	:= ""
Default cNumero	:= ""
Default cParc		:= ""
Default cTipo		:= ""
Default cCliFor	:= ""
Default cLoja		:= ""
Default cSeq		:= ""
Default nRecSE5	:= 0 //nRecSE5 > 0 = Baixa / nRecSE5 == 0 = Exclusao de documento
Default nHdlPrv	:= 0
Default cRotina   := ""
Default cLote     := ""

If lUtilAVP .And. nHdlPrv
	If nRecSE5 > 0
		SE5->( DbGoTo( nRecSE5 ) )
		cPrefixo	:= SE5->E5_PREFIXO
		cNumero	:= SE5->E5_NUMERO
		cParc		:= SE5->E5_PARCELA
		cTipo		:= SE5->E5_TIPO
		cCliFor	:= SE5->E5_CLIFOR
		cLoja		:= SE5->E5_LOJA
		cSeq		:= SE5->E5_SEQ
	EndIf
	
	If cAlias == "SE1"
		cPadrao := IIF( nRecSE5 <= 0 , "5B5" , "5B7" )
		DbSelectArea( "FIP" )
		FIP->( DbSetOrder( 3 ) )
		FIP->( DbSeek( xFilial( "FIP" ) + cPrefixo + cNumero + cParc + cTipo + cCliFor + cLoja + cSeq ) )
	ElseIf cAlias == "SE2"
		cPadrao := IIF( nRecSE5 <= 0 , "5B6" , "5B8" )
		DbSelectArea( "FIS" )
		FIS->( DbSetOrder( 3 ) )
		FIS->( DbSeek( xFilial( "FIS" ) + cPrefixo + cNumero + cParc + cTipo + cCliFor + cLoja + cSeq ) )
	EndIf
	
	If VerPadrao(cPadrao)
		nTotalAVP += DetProva(nHdlPrv,cPadrao,cRotina,cLote)
	EndIf
	
EndIf

RestArea( aAreaSE5 )
RestArea( aArea )

Return nTotalAVP
