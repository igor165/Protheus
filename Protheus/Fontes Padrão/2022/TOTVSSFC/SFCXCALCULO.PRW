#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include "TOTVS.CH" 
#INCLUDE "SFCXCALCULO.CH" 
#INCLUDE "AP5MAIL.CH"                             

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXGERENCIAL
Função chamada pela consulta gerencial. Verifica a funcionalidade
utilizada e chamada a função correspondente. Retorna um array que
possui dois arrays, sendo:
	1 - array com os dados das métricas
	2 - array com os detalhes

@param  	nil

@sample		aRetorno := SFCXGERENCIAL()

@return		aRetorno

@author Samantha Preima
@since 16/03/2011
@version 1.0
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCXGERENCIAL( aFiltro )
Private vCodigo     := ""
Private vDescricao  := ""
Private aDados      := {}
Private cCodPai     := ""
Private aDetalhe    := {}
Private lGerencial  := .T.

Private cFunction   := aFiltro[1][1][2]
Private CDESINI     := aFiltro[2][1][2]
Private CDESFIM     := aFiltro[2][1][3]
Private CDARPOINI   := aFiltro[2][2][2]
Private CDARPOFIM   := aFiltro[2][2][3]
Private CDCETRINI   := aFiltro[2][3][2]
Private CDCETRFIM   := aFiltro[2][3][3]
Private CDMQINI     := aFiltro[2][4][2]
Private CDMQFIM     := aFiltro[2][4][3]
Private NRORPOINI   := aFiltro[2][5][2]
Private NRORPOFIM   := aFiltro[2][5][3]
Private IDATINI     := PadR("",10)
Private IDATFIM     := PadR("",10, "Z")
Private IDATQOINI   := PadR("",5)		
Private IDATQOFIM   := PadR("",5, "Z")	
Private CDLIPOINI   := aFiltro[2][6][2]
Private CDLIPOFIM   := aFiltro[2][6][3]
Private CDUSPLINI   := aFiltro[2][7][2]
Private CDUSPLFIM   := aFiltro[2][7][3]
Private CDGRPOINI   := aFiltro[2][8][2]
Private CDGRPOFIM   := aFiltro[2][8][3]
Private CDOEINI     := aFiltro[2][9][2]
Private CDOEFIM     := aFiltro[2][9][3]
Private CDUNNGINI   := aFiltro[2][10][2]
Private CDUNNGFIM   := aFiltro[2][10][3]
Private CDGEINI     := aFiltro[2][11][2]
Private CDGEFIM     := aFiltro[2][11][3]
Private CDFAINI     := aFiltro[2][12][2]
Private CDFAFIM     := aFiltro[2][12][3]
Private CDACINI     := aFiltro[2][13][2]
Private CDACFIM     := aFiltro[2][13][3]
Private CDREINI     := aFiltro[2][14][2]
Private CDREFIM     := aFiltro[2][14][3]
Private CDDPINI     := aFiltro[2][15][2]
Private CDDPFIM     := aFiltro[2][15][3]
Private CDFEINI     := aFiltro[2][16][2]
Private CDFEFIM     := aFiltro[2][16][3]
Private NMSIFBINI   := aFiltro[2][17][2]
Private NMSIFBFIM   := aFiltro[2][17][3]
Private NRPDINI     := aFiltro[2][18][2]                    	
Private NRPDFIM     := aFiltro[2][18][3]
Private NRTNINI     := aFiltro[2][19][2]
Private NRTNFIM     := aFiltro[2][19][3]
Private DTRPINI     := aFiltro[2][20][2]
Private DTRPFIM     := aFiltro[2][20][3]
Private DTORDEMINI  := aFiltro[2][21][2] 
Private DTORDEMFIM  := aFiltro[2][21][3]
Private DTIMCINI    := aFiltro[2][22][2]
Private DTIMCFIM    := aFiltro[2][22][3]
Private DTFMTINI    := aFiltro[2][23][2]
Private DTFMTFIM    := aFiltro[2][23][3]
Private CDSPINI     := aFiltro[2][24][2]
Private CDSPFIM     := aFiltro[2][24][3]
Private CDRFINI     := aFiltro[2][25][2]
Private CDRFFIM     := aFiltro[2][25][3]
Private LTPREP      := { aFiltro[3][1][2][1][2], aFiltro[3][1][2][2][2], aFiltro[3][1][2][3][2] } 
Private LTPPAR      := { aFiltro[3][2][2][1][2], aFiltro[3][2][2][2][2] }
Private LTPMOTPAR   := { aFiltro[3][3][2][1][2], aFiltro[3][3][2][2][2], aFiltro[3][3][2][3][2], aFiltro[3][3][2][4][2] }  
Private LCONSIND    := { aFiltro[3][4][2][1][2], aFiltro[3][4][2][2][2], aFiltro[3][4][2][3][2], aFiltro[3][4][2][4][2] }
Private LSITORD     := {	aFiltro[3][5][2][1][2], aFiltro[3][5][2][2][2], aFiltro[3][5][2][3][2], aFiltro[3][5][2][4][2], ;
							aFiltro[3][5][2][5][2], aFiltro[3][5][2][6][2], aFiltro[3][5][2][7][2], aFiltro[3][5][2][8][2] }
Private cQntApont   := aFiltro[3][6][2][1] 						   		
Private LTPORDEM    := {	aFiltro[3][7][2][1][2], aFiltro[3][7][2][2][2], aFiltro[3][7][2][3][2], aFiltro[3][7][2][4][2], ;
							aFiltro[3][7][2][5][2], aFiltro[3][7][2][6][2], aFiltro[3][7][2][7][2], aFiltro[3][7][2][8][2], aFiltro[3][7][2][9][2] } 
Private aMetrRef	:= { 	aFiltro[4][1][2][1][2], aFiltro[4][1][2][2][2], aFiltro[4][1][2][3][2], aFiltro[4][1][2][4][2], ;
						  	aFiltro[4][1][2][5][2], aFiltro[4][1][2][6][2], aFiltro[4][1][2][7][2], aFiltro[4][1][2][8][2], ;
							aFiltro[4][1][2][9][2], aFiltro[4][1][2][10][2], aFiltro[4][1][2][11][2] }   
Private aMetrPar 	:= { 	aFiltro[4][2][2][1][2], aFiltro[4][2][2][2][2], aFiltro[4][2][2][3][2], aFiltro[4][2][2][4][2], ;
							aFiltro[4][2][2][5][2], aFiltro[4][2][2][6][2], aFiltro[4][2][2][7][2], aFiltro[4][2][2][8][2], aFiltro[4][2][2][9][2] }	
Private aMetrApo 	:= { 	aFiltro[4][3][2][1][2], aFiltro[4][3][2][2][2], aFiltro[4][3][2][3][2], aFiltro[4][3][2][4][2],;
						 	aFiltro[4][3][2][5][2], aFiltro[4][3][2][6][2], aFiltro[4][3][2][7][2], aFiltro[4][3][2][8][2],;
						 	aFiltro[4][3][2][9][2], aFiltro[4][3][2][10][2] }
Private aMetrInd 	:= { 	aFiltro[4][4][2][1][2], aFiltro[4][4][2][2][2], aFiltro[4][4][2][3][2], aFiltro[4][4][2][4][2],;
						 	aFiltro[4][4][2][5][2], aFiltro[4][4][2][6][2], aFiltro[4][4][2][7][2], aFiltro[4][4][2][8][2],;
						 	aFiltro[4][4][2][9][2], aFiltro[4][4][2][10][2], aFiltro[4][4][2][11][2], aFiltro[4][4][2][12][2],;
						 	aFiltro[4][4][2][13][2], aFiltro[4][4][2][14][2], aFiltro[4][4][2][15][2], aFiltro[4][4][2][16][2],;
						 	aFiltro[4][4][2][17][2], aFiltro[4][4][2][18][2], aFiltro[4][4][2][19][2], aFiltro[4][4][2][20][2],;
						 	aFiltro[4][4][2][21][2], aFiltro[4][4][2][22][2], aFiltro[4][4][2][23][2], aFiltro[4][4][2][24][2] }
						 	
Do Case
	Case cFunction == '1' // Refugo/Retrabalho
		SFCXRefRet()
	Case cFunction == '2' // Parada
		SFCXParada()
	Case cFunction == '3' // Apontamento de Produção
		SFCXProduc()
	Case cFunction == '4' // Indicadores
		SFCXIndic()		
End Case

Return {aDados,aDetalhe} 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXMETA

@param  	cMeta		Meta a ser realizado o cálculo
			cMaquina	Máquina da meta
			dIni		Data início do período
			dFim		Data fim Período
			cRefer		Hora referência
			lSetup		Considera preparação nos indicadores de eficiência
			lExtra		Considera tempo extra como disponível
			lParada		Considera parada que altera eficiência
			lRefugo		Considera fator refugo
			nTipo		Tipo da meta (1-Diária,2-Semanal,3-Mensal)

@sample		

@return		

@author Samantha Preima
@since 05/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCXMETA(cMeta,cID,cMaquina,dIni,dFim,cRefer,lSetup,lExtra,lParada,lRefugo,lMail,nTipo)
Local dNow		   := date()
Local cNow		   := time()
Local nI		   := 0
Local nI2		   := 0
Local nQtdSeq      := 0
Local nQtdMeta     := 0
Local nTempoMeta   := 0
Local nSeqProd     := 0
Local aArea        := GetArea()
Local aAreaCY5     := CY5->(GetArea())
Local cAviso       := ''
Local nValor       := 0
Local aCampos      := {}
Local cAssunto     := ""
Local cMensagem    := ""
Local nEmail 	   := 0
Local lConnect	   := .T.
Private vCodigo	   := ""
Private vDescricao := ""
Private aDados     := {}
Private cCodPai    := ""
Private aDetalhe   := {}
Private aMeta      := {}
Private HRREFER    := cRefer
Private DTRPINI    := dIni
Private DTRPFIM    := dFim
Private CDESINI    := PadR("",TamSX3("CYA_CDES")[1])
Private CDESFIM    := PadR("",TamSX3("CYA_CDES")[1], "Z")
Private CDARPOINI  := PadR("",TamSX3("CYA_CDARPO")[1])
Private CDARPOFIM  := PadR("",TamSX3("CYA_CDARPO")[1], "Z")
Private CDCETRINI  := PadR("",TamSX3("CYI_CDCETR")[1])
Private CDCETRFIM  := PadR("",TamSX3("CYI_CDCETR")[1], "Z")
Private CDMQINI    := cMaquina
Private CDMQFIM    := cMaquina
Private CDGRPOINI  := PadR("",TamSX3("CYH_CDRC")[1])
Private CDGRPOFIM  := PadR("",TamSX3("CYH_CDRC")[1], "Z")
Private CDOEINI    := CDGRPOINI
Private CDOEFIM    := CDGRPOFIM
Private CDFEINI    := CDGRPOINI
Private CDFEFIM    := CDGRPOFIM
Private CDSPINI    := PadR("",TamSX3("CYN_CDSP")[1])
Private CDSPFIM    := PadR("",TamSX3("CYN_CDSP")[1], "Z")
Private NRTNINI    := PadR("",TamSX3("CYR_NRTN")[1])
Private NRTNFIM    := PadR("",TamSX3("CYR_NRTN")[1], "9")
Private CDRFINI    := PadR("",TamSX3("CYO_CDRF")[1])
Private CDRFFIM    := PadR("",TamSX3("CYO_CDRF")[1], "Z")
Private NRORPOINI  := PadR("",TamSX3("CYQ_NRORPO")[1])
Private NRORPOFIM  := PadR("",TamSX3("CYQ_NRORPO")[1], "Z")
Private IDATINI    := PadR("",TamSX3("CYY_IDAT")[1])
Private IDATFIM    := PadR("",TamSX3("CYY_IDAT")[1], "Z")
Private IDATQOINI  := PadR("",TamSX3("CYY_IDATQO")[1])
Private IDATQOFIM  := PadR("",TamSX3("CYY_IDATQO")[1], "Z")
Private LCONSIND   := array(4)
Private LTPPAR     := array(2)
Private LTPMOTPAR  := array(4)
Private cFunction  := "5" // Indicadores via meta
Private aFieldsSel := { {STR0001, "CDMQ"} } // "04 Máquina"
Private IDMETA     := cID

LCONSIND[1]  := lParada
LCONSIND[2]  := lRefugo
LCONSIND[3]  := lExtra
LCONSIND[4]  := lSetup
LTPPAR[1]    := .T.
LTPPAR[2]    := .T.
LTPMOTPAR[1] := .T.
LTPMOTPAR[2] := .T.
LTPMOTPAR[3] := .T.
LTPMOTPAR[4] := .T.

dbSelectArea('CY5')
CY5->(dbSetOrder(2))
CY5->(dbGoTop())
CY5->(dbSeek(xFilial('CY5')+cID))

IF CY5->CY5_NRTN != '0'
	NRTNINI := CY5->CY5_NRTN
	NRTNFIM := CY5->CY5_NRTN
Endif

SFCXIndic()

// Ordena os apontamentos, para calcular os valores de sequencia
aSort( aDetalhe,,, { | x, y | VAL(x[71] + DTOS(x[74]) + ALLTRIM(STR(SFCXHourToSeg(x[75])))) < VAL(y[71] + DTOS(y[74]) + ALLTRIM(STR(SFCXHourToSeg(y[75])))) } )

// Salvar histórico da meta
For nI := 1 to Len(aMeta)
	dbSelectArea('CY4')
	CY4->(dbSetOrder(1))
	CY4->(dbGoTop())
	if CY4->(dbSeek(xFilial('CY4')+cID+aMeta[nI][2]+DTOS(dFim)+cRefer))
		RecLock('CY4',.F.)
		CY4->(dbDelete())
		MsUnLock()
	Endif
	
	RecLock('CY4',.T.)
	
	nSeqProd := 0
	
	// Buscar se nas sequencias anteriores houve produção
   	For nI2 := 1 to nI
   		if Len(aDetalhe) >= nI2 .AND.;
   		   aDetalhe[nI2][71] == '1' .AND.; // Apontamento de Produção
		   aDetalhe[nI2][4] == aMeta[nI][12] .AND.; // Ordem de Produção
		   aDetalhe[nI2][6] == aMeta[nI][13] .AND.; // ID Operação
		   aDetalhe[nI2][7] == aMeta[nI][14]		// ID Split
			nSeqProd += aDetalhe[nI2][19]
		Endif
   	Next
   	
   	nQtdSeq	+= MIN(aMeta[nI][16],nSeqProd)
	
	nQtdMeta        += aMeta[nI][16]
	nTempoMeta      += aMeta[nI][15]
	CY4->CY4_FILIAL := xFilial('CY4')
	CY4->CY4_IDMEPO := aMeta[nI][1]
	CY4->CY4_NRSQME := aMeta[nI][2]
	CY4->CY4_DTRE   := dFim
	CY4->CY4_HRRE   := cRefer
	CY4->CY4_CDMQ   := aMeta[nI][5]
	CY4->CY4_DTBGAT := aMeta[nI][6]
	CY4->CY4_HRBGAT := aMeta[nI][7]
	CY4->CY4_DTEDAT := aMeta[nI][8]
	CY4->CY4_HREDAT := aMeta[nI][9]
	CY4->CY4_TPMV   := aMeta[nI][10]
	CY4->CY4_CDAC   := aMeta[nI][11]
	CY4->CY4_NRORPO := aMeta[nI][12]
	CY4->CY4_IDAT   := aMeta[nI][13]
	CY4->CY4_IDATQO := aMeta[nI][14]
	CY4->CY4_QTTEPL := aMeta[nI][15]
	CY4->CY4_QTPLAT := aMeta[nI][16]
	CY4->CY4_QTPLUN := aMeta[nI][17]
	CY4->CY4_NRTN   := aMeta[nI][18]
	
	MsUnLock()
Next

// Eliminar o registro existente de Métricas Indicadores
dbSelectArea('CZ4')
CZ4->(dbSetOrder(1))
CZ4->(dbGoTop())
if CZ4->(dbSeek(xFilial('CZ4')+cID+DTOS(dFim)+cRefer))
	RecLock('CZ4',.F.)
	CZ4->(dbDelete())
	MsUnLock()
Endif

// Salvar informações de Métricas Indicadores
if Len(aDados) > 0
	RecLock('CZ4',.T.)
	
	CZ4->CZ4_FILIAL := xFilial('CZ4')
	CZ4->CZ4_QTME   := nQtdMeta					// Quantidade Meta
	CZ4->CZ4_QTTEME := nTempoMeta				// Tempo Meta
	CZ4->CZ4_QTVM   := aDados[1][49]			// Volume
	CZ4->CZ4_QTMIX  := aDados[1][50]   			// Mix
	CZ4->CZ4_QTSQ   := nQtdSeq					// Sequencia
	CZ4->CZ4_VLBTSV := CZ4->CZ4_QTVM / CZ4->CZ4_QTME * 100							// % Volume
	CZ4->CZ4_VLBTSM := CZ4->CZ4_QTMIX / MIN(CZ4->CZ4_QTME,CZ4->CZ4_QTVM) * 100		// % Mix
	CZ4->CZ4_VLBTSS := CZ4->CZ4_QTSQ / CZ4->CZ4_QTMIX * 100 						// % Sequencia
	CZ4->CZ4_VLBTS  := CZ4->CZ4_VLBTSV * CZ4->CZ4_VLBTSM * CZ4->CZ4_VLBTSS / 10000	// BTS
	CZ4->CZ4_IDMEPO := cID						// Meta Produção
	CZ4->CZ4_DTRE   := dFim			   			// Data de referencia
	CZ4->CZ4_HRRE   := cRefer		   			// Hora de referencia
	CZ4->CZ4_LGSUEF	:= lSetup		   			// Se foi utilizado parâmetro: Considera Preparação nos indicadores de eficiência
	CZ4->CZ4_LGDIEX	:= lExtra		   			// Se foi utilizado parâmetro: Considera tempo extra como disponível
	CZ4->CZ4_LGSPEF	:= lParada		   			// Se foi utilizado parâmetro: Considera parada que altera eficiência
	CZ4->CZ4_LGPNRF	:= lRefugo		   			// Se foi utilizado parâmetro: Considera fator refugo
	CZ4->CZ4_DTVF	:= dNow						// Data de execução
	CZ4->CZ4_HRVF	:= cNow						// Hora de execução
	CZ4->CZ4_DTBGME	:= dIni			   			// Data de inicio do calculo
	CZ4->CZ4_DTEDME	:= dFim			   			// Data de fim do calculo - é a data informada em tela
	CZ4->CZ4_CDMQ   := cMaquina		   			// Máquina
	CZ4->CZ4_CDUNVM := aDados[1][67]   			// Unidade Capacidade
	CZ4->CZ4_QTRPRY	:= aDados[1][8]	   			// Quant. Produção Real
	CZ4->CZ4_QTRFPL	:= aDados[1][9]				// Quant. Refugo Previsto
	CZ4->CZ4_QTRFRY	:= aDados[1][10]			// Quant. Refugo Real
	CZ4->CZ4_VLPNRF	:= aDados[1][11]			// % Variação Refugo
	CZ4->CZ4_QTRTPL	:= aDados[1][12]			// Quant. Retrabalho Previsto
	CZ4->CZ4_QTRTRY	:= aDados[1][13]			// Quant. Retrabalho Real
	CZ4->CZ4_VLPNRT	:= aDados[1][14]			// % Variação Retrabalho
	CZ4->CZ4_NRSP	:= aDados[1][15]   			// Número Paradas
	CZ4->CZ4_NRSPPL	:= aDados[1][16]   			// Número Paradas Programadas
	CZ4->CZ4_VLRFPL	:= Round(aDados[1][9]  / aDados[1][8] * 100, 2) // % Refugo Previsto
	CZ4->CZ4_VLRFRY	:= Round(aDados[1][10] / aDados[1][8] * 100, 2)	// % Refugo Real
	CZ4->CZ4_VLRTPL	:= Round(aDados[1][12] / aDados[1][8] * 100, 2)	// % Retrabalho Previsto
	CZ4->CZ4_VLRTRY	:= Round(aDados[1][13] / aDados[1][8] * 100, 2)	// % Retrabalho Real
	CZ4->CZ4_NRSPRY	:= aDados[1][17]			// Número Programadas Realizadas
	CZ4->CZ4_NRSPAI	:= aDados[1][18]			// Número Não Programadas
	CZ4->CZ4_QTPL	:= aDados[1][19]			// Horas Planejadas
	CZ4->CZ4_QTPLRY := aDados[1][60]   			// Horas Planejadas Reais - usado para cálculo de % Programado e % Não Programado
	CZ4->CZ4_QTPLAI	:= aDados[1][20]   			// Horas Não Planejadas
	CZ4->CZ4_QTSPTT	:= aDados[1][21]   			// Hora Parada Total
	CZ4->CZ4_VLPL	:= aDados[1][22]   			// % Programado
	CZ4->CZ4_VLAI	:= aDados[1][23]   			// % Não Programado
	CZ4->CZ4_NRTTRP	:= aDados[1][24]			// Número Apontamentos
	CZ4->CZ4_QTSUPA	:= aDados[1][25]   			// Horas Preparapa Padrão
	CZ4->CZ4_QTATPA	:= aDados[1][26]			// Horas Operação Padrão
	CZ4->CZ4_QTSURY	:= aDados[1][27]   			// Horas Preparação Real
	CZ4->CZ4_QTATRY	:= aDados[1][28]   			// Horas Operação Real
	CZ4->CZ4_QTTEUT	:= aDados[1][29]			// Horas Normais
	CZ4->CZ4_QTTEEX	:= aDados[1][30]			// Horas Extras
	CZ4->CZ4_VLQL	:= aDados[1][31]			// % Qualidade
	CZ4->CZ4_VLQLRY	:= aDados[1][32]			// % Qualidade Real
	CZ4->CZ4_VLEF	:= aDados[1][33]			// % Eficiência
	CZ4->CZ4_QTVMPL	:= aDados[1][34]   			// Horas Capacidade Projeto
	CZ4->CZ4_QTVMEV	:= aDados[1][35]   			// Horas Capacidade Efetiva
	CZ4->CZ4_QTVMRY	:= aDados[1][36]			// Horas Capacidade Real
	CZ4->CZ4_VLDIPL	:= aDados[1][37]			// Disponibilidade Planejada
	CZ4->CZ4_VLDIRY	:= Round(aDados[1][38],2)	// Disponibilidade Real
	CZ4->CZ4_VLUT	:= Round(aDados[1][39],2)	// % Utilização
	CZ4->CZ4_QTTELZ	:= Round(aDados[1][40],2)	// Horas Sem Apontamento
	CZ4->CZ4_QTSPSU	:= aDados[1][41]			// Horas Paradas Preparação
	CZ4->CZ4_QTSPPL	:= aDados[1][42]			// Horas Paradas Programadas
	CZ4->CZ4_VLSP	:= Round(aDados[1][43],2)	// DownTime
	CZ4->CZ4_VLNEE	:= Round(aDados[1][44],2)	// % Eficiência Líquida - NEE
	CZ4->CZ4_VLOEE	:= Round(aDados[1][45],2)	// % Eficiência Geral - OEE
	CZ4->CZ4_VLTEEP	:= Round(aDados[1][46],2)	// % Produtividade - TEEP
	CZ4->CZ4_VLTK	:= aDados[1][47]			// Takt Time
	CZ4->CZ4_QTTESP	:= aDados[1][56]			// Horas Paradas
	CZ4->CZ4_QTSPEF	:= aDados[1][57]			// Horas Paradas Alteram Eficiência
	CZ4->CZ4_QTRP	:= aDados[1][58]			// Quant. Processada
	CZ4->CZ4_VLLZ	:= ROUND((aDados[1][36] - aDados[1][27] - aDados[1][28]) / aDados[1][36] * 100,2)	// % Ociosidade
	CZ4->CZ4_VLSPEX := aDados[1][61]			// Tempo Extra Parada
	CZ4->CZ4_VLSPUT := aDados[1][62]			// Tempo Útil Parada
	CZ4->CZ4_QTRPPL := aDados[1][68]			// Quantidade Planejada
	CZ4->CZ4_CDCETR := Posicione("CYB",,xFilial("CYB")+cMaquina,"CYB_CDCETR")	
	
	aDados[1][52] := CZ4->CZ4_VLBTSV // % Volume
	aDados[1][53] := CZ4->CZ4_VLBTSM // % Mix
	aDados[1][54] := CZ4->CZ4_VLBTSS // % Sequencia 
	aDados[1][55] := CZ4->CZ4_VLBTS  // Atendimento BTS
	aDados[1][48] := CZ4->CZ4_IDMEPO // Meta Produção
	
	dbSelectArea('CYI')
	CYI->(dbSetOrder(1))
	CYI->(dbGoTop())
	CYI->(dbSeek(xFilial('CYI')+CZ4->CZ4_CDCETR))
	
	CZ4->CZ4_CDARPO := CYI->CYI_CDARPO
	CZ4->CZ4_CDES   := Posicione("CYA",,xFilial("CYA")+CZ4->CZ4_CDARPO,"CYA_CDES")

	// Verificar faixa para alerta/email de informações	
	if lMail
		dbSelectArea('CY8')
		CY8->(dbSetOrder(1))
		CY8->(dbGoTop())
		if CY8->(dbSeek(xFilial('CY8')+cID))
			
			// Realiza conexão com o servidor SMTP de e-mail
			CONNECT SMTP SERVER GetMV("MV_RELSERV") ACCOUNT GetMV("MV_RELACNT") PASSWORD GetMV("MV_RELPSW") RESULT lConnect
	
			While CY8->(!EOF()) .AND. CY8->CY8_IDMEPO == cID
	
				if CY8->CY8_DTVDBG <= dFim .AND. CY8->CY8_DTVDED >= dFim
					              
					dbSelectArea('CYJ')
					CYJ->(dbSetOrder(1))
					CYJ->(dbGoTop())
					if CYJ->(dbSeek(xFilial('CYJ')+CY8->CY8_CDIN))
						Do Case
							Case CYJ->CYJ_TPIN == '01' // Qualidade
								nValor := CZ4->CZ4_VLQL
							Case CYJ->CYJ_TPIN == '02' // Qualidade Real
								nValor := CZ4->CZ4_VLQLRY
							Case CYJ->CYJ_TPIN == '03' // Eficiencia
								nValor := CZ4->CZ4_VLEF
							Case CYJ->CYJ_TPIN == '04' // Utilização
								nValor := CZ4->CZ4_VLUT
							Case CYJ->CYJ_TPIN == '05' // Disp Real
								nValor := CZ4->CZ4_VLDIRY
							Case CYJ->CYJ_TPIN == '06' // Disp Planejada
								nValor := CZ4->CZ4_VLDIPL
							Case CYJ->CYJ_TPIN == '07' // NEE
								nValor := CZ4->CZ4_VLNEE
							Case CYJ->CYJ_TPIN == '08' // OEE
								nValor := CZ4->CZ4_VLOEE
							Case CYJ->CYJ_TPIN == '09' // TEEP
								nValor := CZ4->CZ4_VLTEEP
							Case CYJ->CYJ_TPIN == '10' // BTS_V
								nValor := CZ4->CZ4_VLDIRY
							Case CYJ->CYJ_TPIN == '11' // BTS_M
								nValor := CZ4->CZ4_VLBTSM
							Case CYJ->CYJ_TPIN == '12' // BTS_S
								nValor := CZ4->CZ4_VLBTSS
							Case CYJ->CYJ_TPIN == '13' // BTS
								nValor := CZ4->CZ4_VLBTS
							Case CYJ->CYJ_TPIN == '14' // TK
								nValor := CZ4->CZ4_VLTK
							Case CYJ->CYJ_TPIN == '15' // Específico
								cNomeFun := CYJ->CYJ_DSFUEY
					   			If !Empty( cNomeFun )					   			
					   				nValor := SFCXCALFUN(cNomeFun, aDados)
								Else
									nValor := 0
								Endif                                               
						End Case
						
						aCampos := SFXARRACZ4()
						
						For nI := 1 to Len(aCampos)
							AADD(aCampos[nI], &("CZ4->CZ4_" + Substr(aCampos[nI][2],2,Len(aCampos[nI][2]) - 2)))
						Next
							
						IF nValor < CYJ->CYJ_VLEDMI // Crítico
					   		cAssunto  := SFCXTraduc(CYJ->CYJ_DSSIMI, aCampos)
							cMensagem := SFCXTraduc(CYJ->CYJ_DSMSMI, aCampos)
							If CYJ->CYJ_TPMSMI == '1' // Email
								if lMail .And. lConnect
									If !Empty(CYJ->CYJ_DSSIMI) .OR. !Empty(CYJ->CYJ_DSMSMI) .AND. !Empty(CYI->CYI_DSELUS)
										SFCEnvMail(CYI->CYI_DSELUS, cAssunto, cMensagem, .F.)
									Endif
								Endif
								nEmail++
							ElseIf CYJ->CYJ_TPMSMI == '2' // Aviso
								SFCXGeraArquivo( { cAssunto, cMensagem } )
							Endif
						ElseIf nValor < CYJ->CYJ_VLEDXA // Regular
							cAssunto  := SFCXTraduc(CYJ->CYJ_DSSIXA, aCampos)
							cMensagem := SFCXTraduc(CYJ->CYJ_DSMSXA, aCampos)
							If CYJ->CYJ_TPMSXA == '1' // Email
								if lMail .And. lConnect
									If !Empty(CYJ->CYJ_DSSIXA) .OR. !Empty(CYJ->CYJ_DSMSXA) .AND. !Empty(CYI->CYI_DSELUS)
										SFCEnvMail(CYI->CYI_DSELUS, cAssunto, cMensagem, .F.)
									Endif
								Endif
								nEmail++
							ElseIf CYJ->CYJ_TPMSXA == '2' // Aviso
								SFCXGeraArquivo( { cAssunto, cMensagem } )
							Endif
						Else // Bom
							cAssunto  := SFCXTraduc(CYJ->CYJ_DSSIMX, aCampos)
							cMensagem := SFCXTraduc(CYJ->CYJ_DSMSMX, aCampos)
							if CYJ->CYJ_TPMSMX == '1' // Email
								if lMail .And. lConnect
									if !Empty(CYJ->CYJ_DSSIMX) .OR. !Empty(CYJ->CYJ_DSMSMX) .AND. !Empty(CYI->CYI_DSELUS)
										SFCEnvMail(CYI->CYI_DSELUS, cAssunto, cMensagem, .F.)
									Endif
								Endif 
								nEmail++
							ElseIf CYJ->CYJ_TPMSMX == '2' // Aviso
								SFCXGeraArquivo( { cAssunto, cMensagem } )
							Endif
						Endif
					Endif
				Endif
				
				CY8->(dbSkip())
			End  
			DISCONNECT SMTP SERVER
			If lConnect != .T. .And. nEMail > 0
				MsgAlert( STR0008 ) // 'Falha na conexão com servidor'
			EndIf
		Endif
	Endif
			
	MsUnLock()
Endif

// Eliminar o registro existente de Detalhes Indicadores
dbSelectArea('CZ5')
CZ5->(dbSetOrder(1))
CZ5->(dbGoTop())
if CZ5->(dbSeek(xFilial('CZ5')+cID+DTOS(dFim)+cRefer))
	While CZ5->(!EOF()) .AND. CZ5->CZ5_IDMEPO == cID .AND. CZ5->CZ5_DTRE == dFim .AND. CZ5->CZ5_HRRE == cRefer
		RecLock('CZ5',.F.)
		CZ5->(dbDelete())
		MsUnLock()
		
		CZ5->(dbSkip())
	End
Endif

// Salvar informações de Detalhes Indicadores
For nI := 1 to Len(aDetalhe)

	DbSelectArea('CZ5')
	RecLock('CZ5',.T.)
	
	CZ5->CZ5_FILIAL := xFilial('CZ5')
	CZ5->CZ5_IDMEPO := cID
	CZ5->CZ5_DTRE   := dFim
	CZ5->CZ5_HRRE   := cRefer
	CZ5->CZ5_NRSQ   := STRZERO(nI, 5)
	CZ5->CZ5_CDES   := aDetalhe[nI][3]		// Estabelecimento
	CZ5->CZ5_NRORPO := aDetalhe[nI][4]		// Ordem de Produção
	CZ5->CZ5_CDUNNG := aDetalhe[nI][5]		// Unidade de Negócio
	CZ5->CZ5_IDAT   := aDetalhe[nI][6]		// ID Operação
	CZ5->CZ5_IDATQO := aDetalhe[nI][7]		// Split
	CZ5->CZ5_NRSQRP := aDetalhe[nI][8]		// Seq Reporte
	CZ5->CZ5_CDRF   := aDetalhe[nI][9]		// Motivo Refugo
	CZ5->CZ5_CDARPO := aDetalhe[nI][10]		// Área de Produção
	CZ5->CZ5_CDCETR := aDetalhe[nI][11]		// Centro de Trabalho
	CZ5->CZ5_CDAC   := aDetalhe[nI][12] 	// Item
	CZ5->CZ5_CDRT   := aDetalhe[nI][13]		// Roteiro
	CZ5->CZ5_CDAT   := aDetalhe[nI][14]		// Operação
	CZ5->CZ5_CDFA   := aDetalhe[nI][15]		// Família
	CZ5->CZ5_CDGE   := aDetalhe[nI][16]		// Grupo de Estoque
	CZ5->CZ5_TPORPO := aDetalhe[nI][17]		// Tipo de Ordem de Produção
	CZ5->CZ5_QTRP   := aDetalhe[nI][18]		// Quant Reportada
	CZ5->CZ5_QTAP   := aDetalhe[nI][19]		// Quant Aprovada
	CZ5->CZ5_QTRT   := aDetalhe[nI][20]		// Quant Retrabalhada
	CZ5->CZ5_QTRF   := aDetalhe[nI][21] 	// Quant Refugada
	CZ5->CZ5_DTBGSU := aDetalhe[nI][22]		// Data Início Preparação
	CZ5->CZ5_HRBGSU := aDetalhe[nI][23]		// Data Início Preparação
	CZ5->CZ5_DTEDSU := aDetalhe[nI][24] 	// Data Fim Preparação
	CZ5->CZ5_HREDSU := aDetalhe[nI][25]		// Hora Fim Preparação
	CZ5->CZ5_DTBG   := aDetalhe[nI][72]		// Data Início
	CZ5->CZ5_HRBG   := aDetalhe[nI][73]		// Hora Iníco
	CZ5->CZ5_DTED   := aDetalhe[nI][74]		// Data Fim
	CZ5->CZ5_HRED   := aDetalhe[nI][75]		// Hora Fim
	CZ5->CZ5_HRTEAT := aDetalhe[nI][30]		// Tempo Operação
	CZ5->CZ5_HRMOD  := aDetalhe[nI][31]		// Tempo MOB
	CZ5->CZ5_HRTEEX := aDetalhe[nI][32]		// Tempo Extra
	CZ5->CZ5_HRTESP := aDetalhe[nI][33]		// Tempo Parada
	CZ5->CZ5_CDOE   := aDetalhe[nI][34]		// Operador
	CZ5->CZ5_CDGR   := aDetalhe[nI][35]		// Equipe
	CZ5->CZ5_CDTN   := aDetalhe[nI][36]		// Modelo Turno
	CZ5->CZ5_NRTN   := aDetalhe[nI][37]     // Turno
	CZ5->CZ5_CDUSRP := aDetalhe[nI][38]									// Usuário
	CZ5->CZ5_LGLBCQ := if(Empty(aDetalhe[nI][82]),.F.,aDetalhe[nI][39])	// Liberado CQ
	CZ5->CZ5_LGATED := aDetalhe[nI][40]		// Operação Final
	CZ5->CZ5_NRBGCN := aDetalhe[nI][41]		// Início Contador
	CZ5->CZ5_NREDCN := aDetalhe[nI][42]		// Fim Contador
	CZ5->CZ5_TPSP   := aDetalhe[nI][43]		// Tipo Parada
	CZ5->CZ5_CDMQ   := aDetalhe[nI][44]		// Máquina
	CZ5->CZ5_CDSP   := aDetalhe[nI][45]		// Parada
	CZ5->CZ5_DTRP   := aDetalhe[nI][50]		// Data Reporte
	CZ5->CZ5_HRRP   := aDetalhe[nI][51]		// Hora Reporte
	CZ5->CZ5_QTTEUT := aDetalhe[nI][52]		// Tempo Útil
	CZ5->CZ5_NRSQSP := aDetalhe[nI][54]     // Manutenção Programada
	CZ5->CZ5_IDSPTT := aDetalhe[nI][55]		// ID Parada Geral
	CZ5->CZ5_NRORMN := aDetalhe[nI][56]		// Ordem de Manutenção
	CZ5->CZ5_DTBGPL := aDetalhe[nI][57]		// Data Início Programado
	CZ5->CZ5_HRBGPL := aDetalhe[nI][58]		// Hora Início Programado
	CZ5->CZ5_DTEDPL := aDetalhe[nI][59]		// Data Fim Programado
	CZ5->CZ5_HREDPL := aDetalhe[nI][60]		// Hora Fim Programado
	CZ5->CZ5_QTTEPL := aDetalhe[nI][61]		// Tempo Programado
	CZ5->CZ5_QTTEEX := aDetalhe[nI][62]		// Tempo Extra
	CZ5->CZ5_LGMN   := if(Empty(aDetalhe[nI][82]),.F.,aDetalhe[nI][63])	// Manutenção Ativa
	CZ5->CZ5_HRSUPA := aDetalhe[nI][64]		// Horas Preparação Padrão
	CZ5->CZ5_HRATPA := aDetalhe[nI][65]     // Tempo Padrão em segundos
	CZ5->CZ5_HRSU   := aDetalhe[nI][66]		// Tempo Preparação
	CZ5->CZ5_HRSUAT := aDetalhe[nI][53]		// Tempo Operação Preparação
	CZ5->CZ5_VLQL   := aDetalhe[nI][67]		// Qualidade
	CZ5->CZ5_VLQLRY := aDetalhe[nI][68]		// Qualidade Real
	CZ5->CZ5_VLEF   := aDetalhe[nI][69]		// Eficiência
	CZ5->CZ5_CDRE   := aDetalhe[nI][70]		// Referência
	CZ5->CZ5_TPMV   := aDetalhe[nI][71]		// Tipo Movimento
	CZ5->CZ5_CDUNVM := aDetalhe[nI][76]		// Unidade Capacidade
	CZ5->CZ5_QTTEDI := aDetalhe[nI][77]		// Disponibilidade Horas
	CZ5->CZ5_QTDIVM := aDetalhe[nI][78]		// Disponibilidade Capacidade
	CZ5->CZ5_QTVMAT := aDetalhe[nI][79]		// Capacidade Operação
	CZ5->CZ5_NRCNAT := aDetalhe[nI][80]		// Nr Unidades Operação
	CZ5->CZ5_QTRPEV := aDetalhe[nI][81]		// Quant Processada
	CZ5->CZ5_LGEF   := if(Empty(aDetalhe[nI][82]),.F.,aDetalhe[nI][82])	// Altera Eficiência
	CZ5->CZ5_LGSPPL := if(Empty(aDetalhe[nI][82]),.F.,aDetalhe[nI][83])	// Parada Programada
	CZ5->CZ5_QTSPPL := aDetalhe[nI][84]		// Qt Parada Programada
	CZ5->CZ5_QTSPPU := aDetalhe[nI][85]		// Qt Parada Programa Útil
	CZ5->CZ5_QTSPRY := aDetalhe[nI][86]		// Qt Parada Real
	CZ5->CZ5_QTSPRU := aDetalhe[nI][87]		// Qt Parada Real Útil
	CZ5->CZ5_QTSPEF := aDetalhe[nI][88]		// Qt Parada Altera Eficiência
	CZ5->CZ5_QTSPAI := aDetalhe[nI][89]		// Qt Parada Não Altera Eficiência
	CZ5->CZ5_QTVMMQ := aDetalhe[nI][90]		// Capacidade Máquina
	CZ5->CZ5_CDFEPO := aDetalhe[nI][98]		// Ferramenta
	CZ5->CZ5_NRSQME := aDetalhe[nI][99]		// Sequencia Meta
	CZ5->CZ5_QTRPPL := aDetalhe[nI][100] 	// Quantidade prevista split
	CZ5->CZ5_CDLIPO := aDetalhe[nI][101] 	// Linha de Produção
	CZ5->CZ5_CDUSPL := aDetalhe[nI][102] 	// Planejador
	CZ5->CZ5_CDDP   := aDetalhe[nI][103] 	// Depósito
	CZ5->CZ5_VLPNRY := aDetalhe[nI][104] 	// % Avanço
	CZ5->CZ5_DSNRTN := Posicione("CYF",,xFilial("CYF")+aDetalhe[nI][37],"CYF_DSTN") // Descrição número turno

	MsUnLock()
Next

RestArea(aArea)
RestArea(aAreaCY5)

Return nil

Static Function SFCXCALFUN(cNomeFun, aDados)
Local nValor := 0
Local aParam 

if ExistBlock( AllTrim( cNomeFun ) ) 
	aParam := AClone( aDados )
	nValor := ExecBlock(  cNomeFun, .F., .F., aParam )
Endif

Return nValor

//-------------------------------------------------------------------
//-------------------Início Refugo/Retrabalho------------------------
//-------------------------------------------------------------------
Static Function SFCXRefRet()
Local nI		  := 0
Local nNivelOld	  := 0

SFCXProduc()

// Quando for motivo refugo, ele e todos os valores abaixo deverão tem o valor acima
For nI := 1 to Len(aDados)

	IF aDados[nI][1] == 1  // Zera valor
		nNivelOld := 0
	Endif

	if aDados[nI][7] == 21 // Motivo Refugo/Retrabalho
		aDados[nI][8] := aDados[nI - 1][8]
		nNivelOld 	  := aDados[nI][1]
	Endif
	
	if nNivelOld < aDados[nI][1] .AND. nNivelOld != 0
		aDados[nI][8] := aDados[nI - 1][8]
	Endif
Next

Return nil

//-------------------------------------------------------------------
//--------------Monta Array de detalhes------------------------------
//-------------------------------------------------------------------
Static Function SFCXDRefRet(cTipo,dReferencia) // 1-Produção/2-MOB/3-Ferramenta/4-Refugo
Local aLinha   := Array(110)
Local aArea    := GetArea()
Local aAreaCY9 := CY9->(GetArea())
Local nI	   := 0
Local deRelac  := 0

// Relacionamento
For nI := 1 to Len(aFieldsSel)
	if nI == 1
		aLinha[1] := ''
	Endif
		
	aLinha[1] += SFCXVRR(cTipo,substr(aFieldsSel[nI][1],1,2),dReferencia) + '.'
Next

aLinha[2]  := cTipo				// Tipo de Registro
aLinha[3]  := (cAliasCYB)->CYA_CDES		// Estabelecimento
aLinha[4]  := (cAliasCYB)->CYV_NRORPO	// Ordem Produção
aLinha[5]  := (cAliasCYB)->CYQ_CDUNNG	// Unidade Negócio
aLinha[6]  := (cAliasCYB)->CYV_IDAT		// Número Operação
aLinha[7]  := (cAliasCYB)->CYV_IDATQO	// Split
aLinha[8]  := (cAliasCYB)->CYV_NRSQRP	// Sequência Reporte
aLinha[9]  := if(cTipo=='4',(cAliasCY0)->CY0_CDRF,'')	// Motivo
aLinha[10] := (cAliasCYB)->CYI_CDARPO	// Área de Produção
aLinha[11] := (cAliasCYB)->CYY_CDCETR	// Centro de Trabalho
aLinha[12] := (cAliasCYB)->CYV_CDACRP	// Item
aLinha[13] := CY9->CY9_CDRT		// Roteiro
aLinha[14] := CY9->CY9_CDAT		// Operação
aLinha[15] := (cAliasCYB)->CZ3_CDFA		// Família
aLinha[16] := (cAliasCYB)->CZ3_CDGR		// Grupo de Estoque
aLinha[17] := (cAliasCYB)->CYQ_TPORPO	// Tipo de Ordem
aLinha[18] := if(cTipo=='1',(cAliasCYB)->CYV_QTATRP,0)	// Quant Reportada
aLinha[19] := if(cTipo=='1',(cAliasCYB)->CYV_QTATAP,0)	// Quant Aprovada
aLinha[20] := if(cTipo=='4',(cAliasCY0)->CY0_QTRT,0)	// Quant Retrabalhada
aLinha[21] := if(cTipo=='4',(cAliasCY0)->CY0_QTRF,0)	// Quant Refugada
aLinha[22] := STOD((cAliasCYB)->CYY_DTBGSU)	// Início Preparação
aLinha[23] := (cAliasCYB)->CYY_HRBGSU	// Hora Início Preparação
aLinha[24] := STOD((cAliasCYB)->CYY_DTEDSU)	// Fim Preparação
aLinha[25] := (cAliasCYB)->CYY_HREDSU	// Hora Fim Preparação
aLinha[26] := STOD(if(cTipo=='2',(cAliasCYW)->CYW_DTBGRP,(cAliasCYB)->CYV_DTRPBG))	// Início Reporte
aLinha[27] := if(cTipo=='2',(cAliasCYW)->CYW_HRBGRP,(cAliasCYB)->CYV_HRRPBG)	// Hora Início Reporte
aLinha[28] := STOD(if(cTipo=='2',(cAliasCYW)->CYW_DTEDRP,(cAliasCYB)->CYV_DTRPED))	// Fim Reporte
aLinha[29] := if(cTipo=='2',(cAliasCYW)->CYW_HREDRP,(cAliasCYB)->CYV_HRRPED)	// Hora Fim Reporte
aLinha[30] := (cAliasCYB)->CYV_QTTERP / 3600	// Tempo Operação
aLinha[31] := (cAliasCYB)->CYV_QTTEOE / 3600	// Tempo MOD
aLinha[32] := (cAliasCYB)->CYV_QTTEEX / 3600	// Tempo Extra
aLinha[33] := (cAliasCYB)->CYV_QTTESP / 3600	// Tempo Parada
aLinha[34] := if(cTipo=='2',(cAliasCYW)->CYW_CDOE,'') 	// Operador
aLinha[35] := if(cTipo=='2',(cAliasCYW)->CYW_CDGROE,'')						   		// Equipe Produção
aLinha[36] := (cAliasCYB)->CYV_CDTN		// Modelo Turno
aLinha[37] := (cAliasCYB)->CYV_NRTN		// Turno Produção
aLinha[38] := (cAliasCYB)->CYV_CDUSRP	// Nome Usuário
aLinha[39] := if((cAliasCYB)->CYV_LGLBCQ=='T',.T.,.F.)	// Liberado CQ
aLinha[40] := CY9->CY9_LGATED 	// Operação Final
aLinha[41] := (cAliasCYB)->CYV_NRBG		// Início Contador
aLinha[42] := (cAliasCYB)->CYV_NRED 	// Fim Contador
aLinha[44] := (cAliasCYB)->CYV_CDMQ 	// Máquina
aLinha[101] := (cAliasCYB)->CYQ_CDLIPO  // Linha de Produção
aLinha[102] := (cAliasCYB)->CYQ_CDUSPL  // Planejador
aLinha[103] := (cAliasCYB)->CYQ_CDDP    // Depósito
aLinha[104] := (cAliasCYB)->CYV_VLPNRY  // % Avanço
aLinha[105] := if((cAliasCYB)->CYY_LGCERP=='T',.T.,.F.) // Reportado
aLinha[106] := (cAliasCYB)->CYV_TPGGF //Tipo GGF
aLinha[107] := (cAliasCYB)->CYV_TPMOD // Tipo MOB
aLinha[108] := (cAliasCYB)->CYV_TPRF // Tipo Refugo
aLinha[109] := (cAliasCYB)->CYQ_TPRPOR // Tipo Apontamento
aLinha[110] := (cAliasCYB)->CYV_NRRPOG // Seq Origem
	
// Quantifica Apontamento
if cQntApont != '1'
	deRelac := (cAliasCYB)->CYY_QTAT / (cAliasCYB)->CYQ_QTOR
	
	Do Case
		Case cQntApont == '2' // Peso Bruto
			aLinha[18] := aLinha[18] * (cAliasCYB)->CZ3_VLPSBR * deRelac	// Quant Reportada
			aLinha[19] := aLinha[19] * (cAliasCYB)->CZ3_VLPSBR * deRelac	// Quant Aprovada
			aLinha[20] := aLinha[20] * (cAliasCYB)->CZ3_VLPSBR * deRelac	// Quant Retrabalhada
			aLinha[21] := aLinha[21] * (cAliasCYB)->CZ3_VLPSBR * deRelac	// Quant Refugada
		Case cQntApont == '3' // Peso Líquido
			aLinha[18] := aLinha[18] * (cAliasCYB)->CZ3_VLPSLQ * deRelac	// Quant Reportada
			aLinha[19] := aLinha[19] * (cAliasCYB)->CZ3_VLPSLQ * deRelac	// Quant Aprovada
			aLinha[20] := aLinha[20] * (cAliasCYB)->CZ3_VLPSLQ * deRelac	// Quant Retrabalhada
			aLinha[21] := aLinha[21] * (cAliasCYB)->CZ3_VLPSLQ * deRelac	// Quant Refugada
		Case cQntApont == '4' // Unidade Capacidade
			aLinha[18] := aLinha[18] * (cAliasCYB)->CYY_QTVMAT / (cAliasCYB)->CYY_QTAT	// Quant Reportada
			aLinha[19] := aLinha[19] * (cAliasCYB)->CYY_QTVMAT / (cAliasCYB)->CYY_QTAT	// Quant Aprovada
			aLinha[20] := aLinha[20] * (cAliasCYB)->CYY_QTVMAT / (cAliasCYB)->CYY_QTAT	// Quant Retrabalhada
			aLinha[21] := aLinha[21] * (cAliasCYB)->CYY_QTVMAT / (cAliasCYB)->CYY_QTAT	// Quant Refugada
	End Case
Endif

If cTipo == '3'
	aLinha[98] := (cAliasCZ0)->CZ0_CDFE
EndIf
		
AADD(aDetalhe,aLinha)

RestArea(aAreaCY9)
RestArea(aArea)

Return aDetalhe

//-------------------------------------------------------------------
//----------Retorna valor da dimensão para formar chave--------------
//-------------------------------------------------------------------
Static Function SFCXVRR(cTipo,cDimensao,dReferencia)
Local cValor := ''

Do Case
	Case cDimensao == "01" // Estabelecimento
		cValor := (cAliasCYB)->CYA_CDES
	Case cDimensao == "02" // Área de Produção
		cValor := (cAliasCYB)->CYI_CDARPO
	Case cDimensao == "03" // Centro de Trabalho
		cValor := (cAliasCYB)->CYB_CDCETR
	Case cDimensao == "04" // Máquina
		cValor := (cAliasCYB)->CYB_CDMQ
	Case cDimensao == "05" // Linha de Produção
		cValor := (cAliasCYB)->CYQ_CDLIPO
	Case cDimensao == "06" // Planejador
		cValor := (cAliasCYB)->CYQ_CDUSPL
	Case cDimensao == "07" // Equipe
		cValor := if(cTipo=='2',(cAliasCYW)->CYW_CDGROE,PadR("",20))
	Case cDimensao == "08" // Operador
		cValor := if(cTipo=='2',(cAliasCYW)->CYW_CDOE,PadR("",20))
	Case cDimensao == "09" // Item
		cValor := (cAliasCYB)->CYQ_CDAC
	Case cDimensao == "10" // Referência
		cValor := (cAliasCYB)->CYQ_CDRE
	Case cDimensao == "11" // Operação
		cValor := CY9->CY9_DSAT
	Case cDimensao == "12" // Família
		cValor := (cAliasCYB)->CZ3_CDFA
	Case cDimensao == "13" // Grupo de Estoque
		cValor := (cAliasCYB)->CZ3_CDGR
	Case cDimensao == "14" // Cliente
		cValor := (cAliasCYB)->CYQ_NMSIFB
	Case cDimensao == "15" // Pedido
		cValor := (cAliasCYB)->CYQ_CDPD
	Case cDimensao == "16" // Ferramenta
		cValor := if(cTipo=='3',(cAliasCZ0)->CZ0_CDFE,PadR("",20))
	Case cDimensao == "17" // Turno
		cValor := CYM->CYM_CDTN
	Case cDimensao == "18" // Período Mensal
		cValor := ALLTRIM(STR(YEAR(dReferencia))) + "/" + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0")
	Case cDimensao == "19" // Período Semanal
		cValor := ALLTRIM(STR(year(dReferencia))) + "/" + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0") + "/" + SFCXWeekMonth(dReferencia)
	Case cDimensao == "21" // Refugo
		cValor := if(cTipo=='4',(cAliasCY0)->CY0_CDRF,PadR("",8))
	Case cDimensao == "22" // Depósito
		cValor := (cAliasCYB)->CYQ_CDDP
	Case cDimensao == "24" // Tipo de Ordem
		cValor := (cAliasCYB)->CYQ_TPORPO
End Case
	
Return cValor
     
//-------------------------------------------------------------------
//-------------------------Calcula métricas--------------------------
//-------------------------------------------------------------------
Static Function SFCXSeqReR(nValor)

// Producao Real
aDados[nValor][8] += aDetalhe[Len(aDetalhe)][18]

// Refugo Previsto
aDados[nValor][9] += aDetalhe[Len(aDetalhe)][18] * CYY->CYY_VLPNRF / 100

// Refugo Real
aDados[nValor][10] += aDetalhe[Len(aDetalhe)][21]
	
// % Variação Refugo
aDados[nValor][11] := SFCXPercVar(aDados[nValor][9],aDados[nValor][10],aDados[nValor][11])
	
// Retrabalho Previsto
aDados[nValor][12] += aDetalhe[Len(aDetalhe)][18] * CYY->CYY_VLPNRT / 100

// Retrabalho Real
aDados[nValor][13] += aDetalhe[Len(aDetalhe)][20]

// % Variação Retrabalho
aDados[nValor][14] := SFCXPercVar(aDados[nValor][12],aDados[nValor][13],aDados[nValor][14]) 

Return nil
//-------------------------------------------------------------------
//---------------------Fim Refugo/Retrabalho-------------------------
//-------------------------------------------------------------------

//-------------------------------------------------------------------
//---------------------------Início Parada---------------------------
//-------------------------------------------------------------------
Static Function SFCXParada()
Local aArea       := GetArea()
Local aAreaCYB    := CYB->(GetArea())
Local aAreaCYI    := CYI->(GetArea())
Local aAreaCYA    := CYA->(GetArea())
Local aRetorno	  := {}
Private cValRefIni := ''
Private cValRefFim := ''
Private cTipoReg   := '5' // 1-Produção, 2-MOB, 3-Ferramenta, 4-Refugo/Retrabalho, 5-Parada, 6-Recursos
Private cAliasCYB  := GetNextAlias()
Default lAutoMacao := .F.

IF !lAutoMacao
	aDados   := {}
	aDetalhe := {}
ENDIF

BeginSql Alias cAliasCYB
   	
	SELECT * FROM %Table:CYB% CYB
		INNER JOIN %Table:CYI% CYI ON CYI.CYI_FILIAL = %xFilial:CYI% AND
			                          CYI.CYI_CDCETR = CYB.CYB_CDCETR
		INNER JOIN %Table:CYA% CYA ON CYA.CYA_FILIAL = %xFilial:CYA% AND
			                          CYA.CYA_CDARPO = CYI.CYI_CDARPO
		WHERE CYB.CYB_FILIAL=%xFilial:CYB% AND 
			  CYB.CYB_CDMQ>=%Exp:CDMQINI% AND
			  CYB.CYB_CDMQ<=%Exp:CDMQFIM% AND
			  CYB.CYB_CDCETR>=%Exp:CDCETRINI% AND
			  CYB.CYB_CDCETR<=%Exp:CDCETRFIM% AND
			  CYI.CYI_CDARPO>=%Exp:CDARPOINI% AND 
			  CYI.CYI_CDARPO<=%Exp:CDARPOFIM% AND
		      CYA.CYA_CDES>=%Exp:CDESINI% AND
		      CYA.CYA_CDES<=%Exp:CDESFIM% AND
			  CYB.%NotDel% AND
			  CYI.%NotDel% AND
			  CYA.%NotDel% 
EndSql

While (cAliasCYB)->(!EOF())
				   
	aRetorno := SFCXRetCalen() // retorna num array: data inicio, hora inicio, data fim, hora fim
	
	cValRefIni := DTOS(aRetorno[1]) + '.' + STR(SFCXHourToSeg(aRetorno[2]))
	cValRefFim := DTOS(aRetorno[3]) + '.' + STR(SFCXHourToSeg(aRetorno[4]))
   			   				
	// filtra as paradas programadas efetivadas e não programadas, relacionadas à máquina
	SFCXParCYX()
	
	// filtra os apontamentos de parada programada para a máquina (os que não foram efetivados)
	SFCXParCZ2()
	
	(cAliasCYB)->(dbSkip())
End

(cAliasCYB)->(dbCloseArea())

RestArea(aAreaCYB)
RestArea(aAreaCYI)
RestArea(aAreaCYA)
RestArea(aArea)

Return nil 

//-------------------------------------------------------------------
//---------------Monta Array de detalhes-----------------------------
//-------------------------------------------------------------------
Static Function SFCXDParada(cTipoParada,dReferencia) // TIPO = 1-Não Programada 2-Programada e Realizada 3-Programada e Não realizada  
Local aLinha   := Array(110)
Local nI	   := 0

// Relacionamento
For nI := 1 to Len(aFieldsSel)
	if nI == 1
		aLinha[1] := ''
	Endif
	
	aLinha[1] += SFCXVPA(substr(aFieldsSel[nI][1],1,2),dReferencia) + '.'
Next

aLinha[43] := x3Combo('CYX_TPSP',(cAliasCYX)->CYX_TPSP)	// Tipo Parada
aLinha[3]  := (cAliasCYB)->CYA_CDES	 	// Estabelecimento
aLinha[10] := (cAliasCYB)->CYI_CDARPO	// Área de Produção
aLinha[11] := (cAliasCYB)->CYI_CDCETR	// Área de Produção
aLinha[44] := (cAliasCYB)->CYB_CDMQ		// Máquina
aLinha[45] := if(cTipoParada=='3',(cAliasCZ2)->CZ2_CDSP,(cAliasCYX)->CYX_CDSP)	// Parada
aLinha[35] := if(cTipoParada!='3',(cAliasCYX)->CYX_CDGROE,'')			// Equipe de Produção
aLinha[46] := if(cTipoParada!='3',STOD((cAliasCYX)->CYX_DTBGSP),'')		// Data Início Parada
aLinha[47] := if(cTipoParada!='3',(cAliasCYX)->CYX_HRBGSP,'')			// Hora Início Parada
aLinha[48] := if(cTipoParada!='3',STOD((cAliasCYX)->CYX_DTEDSP),'')		// Data Fim Parada
aLinha[49] := if(cTipoParada!='3',(cAliasCYX)->CYX_HREDSP,'')			// Hora Fim Parada
aLinha[50] := if(cTipoParada!='3',(cAliasCYX)->CYX_DTRP,'')				// Data Reporte
aLinha[51] := if(cTipoParada!='3',(cAliasCYX)->CYX_HRRP,'')				// Hora Reporte
aLinha[38] := if(cTipoParada!='3',(cAliasCYX)->CYX_CDUSRP,'')			// Usuário Reporte
aLinha[52] := if(cTipoParada!='3',(cAliasCYX)->CYX_QTTEUT / 3600,0)		// Tempo Útil
aLinha[32] := if(cTipoParada!='3',(cAliasCYX)->CYX_QTTEEX / 3600,0)		// Tempo Extra
aLinha[54] := if(cTipoParada!='3',(cAliasCYX)->CYX_NRSQSP,'')			// Manutenção Programada
aLinha[55] := if(cTipoParada!='3',(cAliasCYX)->CYX_IDSPTT,'')			// Parada Geral

IF cTipoParada == '1'
	aLinha[34] := (cAliasCYX)->CYX_CDOE		// Operador
	aLinha[35] := (cAliasCYX)->CYX_CDGROE	// Equipe
	aLinha[36] := (cAliasCYX)->CYX_CDTN		// Modelo Turno
	aLinha[37] := (cAliasCYX)->CYX_NRTN		// Turno Produção
	aLinha[63] := .F.				// Manutenção Ativa
	aLinha[83] := .F.
	aLinha[8]  := (cAliasCYX)->CYX_NRSQRP   // Apontamento relacionado - somente quando for preparação estará preenchido
ElseIf cTipoParada == '2'
	aLinha[34] := ''						// Operador
	aLinha[35] := ''						// Equipe
	aLinha[36] := CZ2->CZ2_CDTN				// Modelo Turno
	aLinha[37] := CZ2->CZ2_NRTN				// Turno Produção
	aLinha[56] := CZ2->CZ2_NRORMN   		// Nr Ordem Manutenção	
	aLinha[57] := CZ2->CZ2_DTBGPL			// Início Programado
	aLinha[58] := CZ2->CZ2_HRBGPL			// Hora Início Programado
	aLinha[59] := CZ2->CZ2_DTEDPL			// Fim Programado
	aLinha[60] := CZ2->CZ2_HREDPL			// Hora Fim Programado
	aLinha[61] := CZ2->CZ2_QTTEMQ / 3600	// Tempo Programado
	aLinha[62] := CZ2->CZ2_QTTEEX / 3600	// Extra Programado
	aLinha[63] := if(CZ2->CZ2_LGMN,.T.,.F.) // Manutenção Ativa
	aLinha[83] := .T.
Else
   	aLinha[34] := ''						// Operador
	aLinha[35] := ''						// Equipe
	aLinha[36] := (cAliasCZ2)->CZ2_CDTN				// Modelo Turno
	aLinha[37] := (cAliasCZ2)->CZ2_NRTN				// Turno Produção
	aLinha[56] := (cAliasCZ2)->CZ2_NRORMN   		// Nr Ordem Manutenção	
	aLinha[57] := STOD((cAliasCZ2)->CZ2_DTBGPL)		// Início Programado
	aLinha[58] := (cAliasCZ2)->CZ2_HRBGPL			// Hora Início Programado
	aLinha[59] := STOD((cAliasCZ2)->CZ2_DTEDPL)		// Fim Programado
	aLinha[60] := (cAliasCZ2)->CZ2_HREDPL			// Hora Fim Programado
	aLinha[61] := (cAliasCZ2)->CZ2_QTTEMQ / 3600	// Tempo Programado
	aLinha[62] := (cAliasCZ2)->CZ2_QTTEEX / 3600	// Extra Programado
	aLinha[63] := if((cAliasCZ2)->CZ2_LGMN=='T',.T.,.F.) // Manutenção Ativa
	aLinha[83] := .T.
Endif
		
AADD(aDetalhe,aLinha)

Return aDetalhe

//-------------------------------------------------------------------
//----------Retorna valor da dimensão para formar chave--------------
//-------------------------------------------------------------------
Static Function SFCXVPA(cDimensao,dReferencia)
Local cValor := ''

Do Case
	Case cDimensao == "01" // Estabelecimento
		cValor := (cAliasCYB)->CYA_CDES
	Case cDimensao == "02" // Área de Produção
		cValor := (cAliasCYB)->CYI_CDARPO
	Case cDimensao == "03" // Centro de Trabalho
		cValor := (cAliasCYB)->CYB_CDCETR
	Case cDimensao == "04" // Máquina
		cValor := (cAliasCYB)->CYB_CDMQ
	Case cDimensao == "07" // Equipe
		cValor := (cAliasCYX)->CYX_CDGROE
	Case cDimensao == "08" // Operador
		cValor := (cAliasCYX)->CYX_CDOE
	Case cDimensao == "17" // Turno
		cValor := CYM->CYM_CDTN
	Case cDimensao == "18" // Período Mensal
		cValor := ALLTRIM(STR(YEAR(dReferencia))) + "/" + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0")
	Case cDimensao == "19" // Período Semanal
		cValor := ALLTRIM(STR(year(dReferencia))) + '/' + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0") + "/" + SFCXWeekMonth(dReferencia)
	Case cDimensao == "20" // Motivo Parada
		cValor := (cAliasCYX)->CYN_CDSP
End Case
	
Return cValor

//-------------------------------------------------------------------
//-------------------------Calcula métricas--------------------------
//-------------------------------------------------------------------
Static Function SFCXSeqPar(nValor)

/* Número de Paradas */
if cTipoParada == '1' .OR. cTipoParada == '2'
	aDados[nValor][15] += 1
Endif

/* Paradas Programadas */
if cTipoParada == '3'
	aDados[nValor][16] += 1
Endif

/* Paradas Programadas Realizadas*/
if cTipoParada == '2'
	aDados[nValor][17] += 1
Endif

if cTipoParada == '1'
	aDados[nValor][18] += 1
Endif

/* Parada Programada - horas planejadas */
aDados[nValor][19] += if(cTipoParada=='2',(CZ2->CZ2_QTTEMQ + CZ2->CZ2_QTTEEX) / 3600,0)

/* Produção Horas Não Planejadas */
aDados[nValor][20] += IF(cTipoParada=='1' .AND. Empty((cAliasCYX)->CYX_NRSQRP),((cAliasCYX)->CYX_QTTEUT + (cAliasCYX)->CYX_QTTEEX) / 3600,0)

/* Produção Tempo Total Parada */
aDados[nValor][21] += IF(cTipoParada!='3' .AND. Empty((cAliasCYX)->CYX_NRSQRP),((cAliasCYX)->CYX_QTTEUT + (cAliasCYX)->CYX_QTTEEX) / 3600,0)

/* Produção Percentual Programado */
if cTipoParada=='2'
	// Horas Planejadas Reais
	aDados[nValor][60] += (cAliasCYX)->CYX_QTTEUT + (cAliasCYX)->CYX_QTTEEX / 3600
Endif

aDados[nValor][22] += if(aDados[nValor][60]==0,0,aDados[nValor][60] / aDados[nValor][19] * 100)

/* Produção Percentual Não Programdo */
aDados[nValor][23] := aDados[nValor][20] / IF(aDados[nValor][21]==0,1,aDados[nValor][21]) * 100

// Tempo Extra Parada
aDados[nValor][61] += aDetalhe[Len(aDetalhe)][32]

// Tempo Útil Parada
aDados[nValor][62] += aDetalhe[Len(aDetalhe)][52]

Return nil

//-------------------------------------------------------------------
//-----------------------------Fim Parada----------------------------
//-------------------------------------------------------------------

//-------------------------------------------------------------------
//--------------------------Início Produção-------------------------- 
//------------------------------------------------------------------- 
Static Function SFCXProduc()
Local aArea       := GetArea()
Local aAreaCYB    := CYB->(GetArea())
Local aAreaCYI    := CYI->(GetArea())
Local aAreaCYA    := CYA->(GetArea())
Local aAreaCYV    := CYV->(GetArea())
Local aAreaCYY    := CYY->(GetArea())
Local aAreaCYQ    := CYQ->(GetArea())
Local aAreaCZ3    := CZ3->(GetArea())
Local aAreaCYM    := CYM->(GetArea())
Local aAreaCY0    := CY0->(GetArea())
Local aAreaCYW    := CYW->(GetArea())
Local aAreaCZ0    := CZ0->(GetArea())
Local cValRefIni  := ''
Local cValRefFim  := ''
Local cValCYVIni  := ''
Local cValCYVFim  := ''
Local aRetorno    := {}
Local nI		  := 0
Local dReferencia := DATE()
Private cTipoReg  := '1' // 1-Produção, 2-MOB, 3-Ferramenta, 4-Refugo/Retrabalho 
Private cAliasCYB := GetNextAlias()
Private cAliasCYW := GetNextAlias()
Private cAliasCZ0 := GetNextAlias()
Private cAliasCY0 := GetNextAlias()
Default lAutoMacao := .F.

IF !lAutoMacao
	aDados      := {}						
	aDetalhe    := {}
ENDIF 

BeginSql Alias cAliasCYB
   	
	SELECT * FROM %Table:CYB% CYB
		INNER JOIN %Table:CYI% CYI ON CYI.CYI_FILIAL = %xFilial:CYI% AND
			                          CYI.CYI_CDCETR = CYB.CYB_CDCETR
		INNER JOIN %Table:CYA% CYA ON CYA.CYA_FILIAL = %xFilial:CYA% AND
			                          CYA.CYA_CDARPO = CYI.CYI_CDARPO
		INNER JOIN %Table:CYV% CYV ON CYV.CYV_FILIAL = %xFilial:CYV% AND
									  CYV.CYV_CDMQ   = CYB.CYB_CDMQ
	    INNER JOIN %Table:CYY% CYY ON CYY.CYY_FILIAL = %xFilial:CYY% AND
									  CYY.CYY_NRORPO = CYV.CYV_NRORPO AND
									  CYY.CYY_IDAT   = CYV.CYV_IDAT AND
									  CYY.CYY_IDATQO = CYV.CYV_IDATQO
		INNER JOIN %Table:CYQ% CYQ ON CYQ.CYQ_FILIAL = %xFilial:CYQ% AND 
									  CYQ.CYQ_NRORPO = CYV.CYV_NRORPO
		INNER JOIN %Table:CZ3% CZ3 ON CZ3.CZ3_FILIAL = %xFilial:CZ3% AND 
									  CZ3.CZ3_CDAC   = CYQ.CYQ_CDAC
		WHERE CYB.CYB_FILIAL=%xFilial:CYB% AND 
			  CYB.CYB_CDMQ>=%Exp:CDMQINI% AND
			  CYB.CYB_CDMQ<=%Exp:CDMQFIM% AND
			  CYB.CYB_CDCETR>=%Exp:CDCETRINI% AND
			  CYB.CYB_CDCETR<=%Exp:CDCETRFIM% AND
			  CYI.CYI_CDARPO>=%Exp:CDARPOINI% AND 
			  CYI.CYI_CDARPO<=%Exp:CDARPOFIM% AND
		      CYA.CYA_CDES>=%Exp:CDESINI% AND
		      CYA.CYA_CDES<=%Exp:CDESFIM% AND
		      CYV.CYV_LGRPEO='F' AND
		      CYV.CYV_NRORPO>=%Exp:NRORPOINI% AND
		      CYV.CYV_NRORPO<=%Exp:NRORPOFIM% AND
		      CYV.CYV_NRTN>=%Exp:NRTNINI% AND
		      CYV.CYV_NRTN<=%Exp:NRTNFIM% AND
		      CYQ.CYQ_CDLIPO>=%Exp:CDLIPOINI% AND
		      CYQ.CYQ_CDLIPO<=%Exp:CDLIPOFIM% AND
		      CYQ.CYQ_CDUSPL>=%Exp:CDUSPLINI% AND
		      CYQ.CYQ_CDUSPL<=%Exp:CDUSPLFIM% AND
		      CYQ.CYQ_CDAC>=%Exp:CDACINI% AND
		      CYQ.CYQ_CDAC<=%Exp:CDACFIM% AND
		      CYQ.CYQ_CDRE>=%Exp:CDREINI% AND
		      CYQ.CYQ_CDRE<=%Exp:CDREFIM% AND
		      CYQ.CYQ_CDDP>=%Exp:CDDPINI% AND
		      CYQ.CYQ_CDDP<=%Exp:CDDPFIM% AND
		      CYQ.CYQ_NMSIFB>=%Exp:NMSIFBINI% AND
		      CYQ.CYQ_NMSIFB<=%Exp:NMSIFBFIM% AND
		      CYQ.CYQ_CDPD>=%Exp:NRPDINI% AND
		      CYQ.CYQ_CDPD<=%Exp:NRPDFIM% AND
		      CYQ.CYQ_CDGE>=%Exp:CDGEINI% AND
		      CYQ.CYQ_CDGE<=%Exp:CDGEFIM% AND
		      CZ3.CZ3_CDFA>=%Exp:CDFAINI% AND
		      CZ3.CZ3_CDFA<=%Exp:CDFAFIM% AND
		      CYB.%NotDel% AND
			  CYI.%NotDel% AND
			  CYA.%NotDel% AND
			  CYV.%NotDel% AND
			  CYY.%NotDel% AND
			  CYQ.%NotDel% AND
			  CZ3.%NotDel%
EndSql

While (cAliasCYB)->(!EOF())

	if (cAliasCYB)->CYV_TPSTRP <> '1'
	
		if Empty((cAliasCYB)->CYY_DTIMC) .OR.;
		   ((cAliasCYB)->CYY_DTIMC >= DTOS(DTIMCINI) .AND.;
		    (cAliasCYB)->CYY_DTIMC <= DTOS(DTIMCFIM) .AND.;
		    (cAliasCYB)->CYY_DTFMT >= DTOS(DTFMTINI) .AND.;
		    (cAliasCYB)->CYY_DTFMT <= DTOS(DTFMTFIM))
				   
			aRetorno := SFCXRetCalen() // retorna num array: data inicio, hora inicio, data fim, hora fim
			
			cValRefIni := DTOS(aRetorno[1]) + '.' + ALLTRIM(STR(SFCXHourToSeg(aRetorno[2])))
			cValRefFim := DTOS(aRetorno[3]) + '.' + ALLTRIM(STR(SFCXHourToSeg(aRetorno[4])))
			
			cValCYVIni := (cAliasCYB)->CYV_DTRPBG + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCYB)->CYV_HRRPBG)))
			cValCYVFim := (cAliasCYB)->CYV_DTRPED + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCYB)->CYV_HRRPED)))
		
			IF (cValCYVIni >= cValRefIni .AND. cValCYVIni <  cValRefFim) .OR.;
			   (cValCYVFim >  cValRefIni .AND. cValCYVFim <= cValRefFim) .OR.;
			   (cValCYVIni <= cValRefIni .AND. cValCYVFim >= cValRefFim)
			   
			   IF LSITORD[VAL((cAliasCYB)->CYQ_TPSTOR)] .AND.; // Estado Ordem
			      LTPORDEM[VAL((cAliasCYB)->CYQ_TPORPO)] .AND.; // Tipo Ordem
			      LTPREP[VAL((cAliasCYB)->CYQ_TPRPOR)] // Tipo Reporte
									 
					dbSelectArea("CY9")
					CY9->(dbSetOrder(1))
					CY9->(dbGoTop())
					CY9->(dbSeek(xFilial('CY9')+(cAliasCYB)->CYV_NRORPO+(cAliasCYB)->CYV_IDAT))
				
					dbSelectArea("CYM") 
					CYM->(dbSetOrder(1))
					CYM->(dbSeek(xFilial("CYM")+(cAliasCYB)->CYV_CDTN))
					
					dReferencia := STOD((cAliasCYB)->CYV_DTRPBG)
					cTipoReg    := '1'
					cCodPai 	:= ""
					
					// Registros de Apontamento de Produção
					if cFunction == '1'
						SFCXDRefRet(cTipoReg,dReferencia)
					Else
						SFCXDProduc(cTipoReg,dReferencia)
					Endif
											
					For nI := 1 to Len(aFieldsSel)
						SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CYV')
						SFCXSequencia(nI,aFieldsSel[nI][1])
					Next
					// Fim
					
					// Registros de Apontamento de MOB
					BeginSql Alias cAliasCYW
		   	
						SELECT * FROM %Table:CYW% CYW
							WHERE CYW.CYW_FILIAL=%xFilial:CYW% AND
								  CYW.CYW_NRSQRP=%Exp:(cAliasCYB)->CYV_NRSQRP% AND
								  CYW.CYW_CDOE>=%Exp:CDOEINI% AND
								  CYW.CYW_CDOE<=%Exp:CDOEFIM% AND
								  CYW.CYW_CDGROE>=%Exp:CDGRPOINI% AND
								  CYW.CYW_CDGROE<=%Exp:CDGRPOFIM% AND
								  CYW.%NotDel%
		     		EndSql
		     		
		     		While (cAliasCYW)->(!EOF())
					    
						cTipoReg := '2'
						cCodPai  := ""
							   
						if cFunction == '1'
							SFCXDRefRet(cTipoReg,dReferencia)
						Else
							SFCXDProduc(cTipoReg,dReferencia)
						Endif
							
						For nI := 1 to Len(aFieldsSel)
							SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CYW')
							SFCXSequencia(nI,aFieldsSel[nI][1])
						Next
						
						(cAliasCYW)->(dbSkip())
					End
					
					(cAliasCYW)->(dbCloseArea())
					// Fim
											
					// Registros de Apontamento de Ferramenta
					BeginSql Alias cAliasCZ0
		   	
						SELECT * FROM %Table:CZ0% CZ0
							WHERE CZ0.CZ0_FILIAL=%xFilial:CZ0% AND
								  CZ0.CZ0_NRSQRP=%Exp:(cAliasCYB)->CYV_NRSQRP% AND
								  CZ0.CZ0_CDFE>=%Exp:CDFEINI% AND
								  CZ0.CZ0_CDFE<=%Exp:CDFEFIM% AND
								  CZ0.%NotDel%
		     		EndSql
		     		
		     		While (cAliasCZ0)->(!EOF())
		     		
		     			cTipoReg := '3'
						cCodPai  := ""
								
						if cFunction == '1'
							SFCXDRefRet(cTipoReg,dReferencia)
						Else
							SFCXDProduc(cTipoReg,dReferencia)
						Endif
								
						For nI := 1 to Len(aFieldsSel)
							SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CZ0')
							SFCXSequencia(nI,aFieldsSel[nI][1])
						Next
						
						(cAliasCZ0)->(dbSkip())
					End
					
					(cAliasCZ0)->(dbCloseArea())
					// Fim
											
					// Registros de Apontamento de Refugo
					BeginSql Alias cAliasCY0
		   	
						SELECT * FROM %Table:CY0% CY0
							WHERE CY0.CY0_FILIAL=%xFilial:CY0% AND
								  CY0.CY0_NRSQRP=%Exp:(cAliasCYB)->CYV_NRSQRP% AND
								  CY0.CY0_CDRF>=%Exp:CDRFINI% AND
								  CY0.CY0_CDRF<=%Exp:CDRFFIM% AND
								  CY0.%NotDel%
		     		EndSql
		     		
		     		While (cAliasCY0)->(!EOF())
							
						cTipoReg := '4'
						cCodPai  := ""
								
						if cFunction == '1'
							SFCXDRefRet(cTipoReg,dReferencia)
						Else
							SFCXDProduc(cTipoReg,dReferencia)
						Endif 
								
						For nI := 1 to Len(aFieldsSel)
							SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CY0')
							SFCXSequencia(nI,aFieldsSel[nI][1])
						Next
						
						(cAliasCY0)->(dbSkip())
					End
					
					(cAliasCY0)->(dbCloseArea())
					// Fim
				Endif
			Endif
		Endif
	EndIF
		
	(cAliasCYB)->(dbSkip())
End 

(cAliasCYB)->(dbCloseArea())

RestArea(aAreaCYB)
RestArea(aAreaCYI)
RestArea(aAreaCYA)
RestArea(aAreaCYV)
RestArea(aAreaCYY)
RestArea(aAreaCY0)
RestArea(aAreaCYQ)
RestArea(aAreaCZ3)
RestArea(aAreaCYM)
RestArea(aAreaCYW)
RestArea(aAreaCZ0)
RestArea(aArea)        
	
Return nil

//-------------------------------------------------------------------
//------------------Detalhes----------------------------------------- 			
//-------------------------------------------------------------------
Static Function SFCXDProduc(cTipo, dReferencia) // TIPO = 1-Produção 2-MOB 3-Ferramenta 4-Refugo/Retrabalho
Local aLinha   	   	 := Array(110)
Local aArea    	     := GetArea()
Local aAreaCY9 		 := CY9->(GetArea())
Local aAreaCYX 		 := CYX->(GetArea())
Local nTempoPadOper  := 0
Local nTempoPadSetup := 0
Local nEficiencia    := 0
Local nQualidade     := 0
Local nQualiReal     := 0
Local nI			 := 0
Local nTempoSetup	 := 0 
Local lConsidSetup   := .T.

dbSelectArea("CYX")
CYX->(dbSetOrder(1))
CYX->(dbGoTop())
lConsidSetup := CYX->(dbSeek(xFilial('CYX')+(cAliasCYB)->CYY_CDMQ+(cAliasCYB)->CYY_DTBGSU+(cAliasCYB)->CYY_HRBGSU))

// Relacionamento
For nI := 1 to Len(aFieldsSel)
	if nI == 1
		aLinha[1] := ''
	Endif
	
	aLinha[1] += SFCXVPR(cTipo,substr(aFieldsSel[nI][1],1,2),dReferencia) + '.'
Next

// Tipo de Registro
aLinha[2]  := cTipo
aLinha[3]  := (cAliasCYB)->CYA_CDES		// Estabelecimento
aLinha[4]  := (cAliasCYB)->CYV_NRORPO	// Ordem Produção
aLinha[5]  := (cAliasCYB)->CYQ_CDUNNG	// Unidade Negócio
aLinha[6]  := (cAliasCYB)->CYV_IDAT		// Número Operação
aLinha[7]  := (cAliasCYB)->CYV_IDATQO	// Split
aLinha[8]  := (cAliasCYB)->CYV_NRSQRP	// Sequência Reporte
aLinha[9]  := if(lConsidSetup,CYX->CYX_CDSP,'')	// Motivo Preparação
aLinha[10] := (cAliasCYB)->CYI_CDARPO	// Área de Produção
aLinha[11] := (cAliasCYB)->CYB_CDCETR	// Centro de Trabalho
aLinha[44] := (cAliasCYB)->CYB_CDMQ		// Máquina
aLinha[12] := (cAliasCYB)->CYV_CDACRP	// Item
aLinha[13] := CY9->CY9_CDRT		// Roteiro
aLinha[14] := CY9->CY9_CDAT		// Operação
aLinha[15] := (cAliasCYB)->CZ3_CDFA		// Família
aLinha[16] := (cAliasCYB)->CZ3_CDGR		// Grupo de Estoque
aLinha[17] := (cAliasCYB)->CYQ_TPORPO	// Tipo de Ordem
aLinha[18] := if(cTipo=='1',(cAliasCYB)->CYV_QTATRP,0)		// Quant Reportada
aLinha[19] := if(cTipo=='1',(cAliasCYB)->CYV_QTATAP,0)  	// Quant Aprovada
aLinha[20] := if(cTipo=='4',(cAliasCY0)->CY0_QTRT,0)	   	// Quant Retrabalhada
aLinha[21] := if(cTipo=='4',(cAliasCY0)->CY0_QTRF,0)	   	// Quant Refugada
aLinha[22] := IF(lConsidSetup,STOD((cAliasCYB)->CYY_DTBGSU),CTOD('01/01/0001'))	// Início Preparação
aLinha[23] := IF(lConsidSetup,(cAliasCYB)->CYY_HRBGSU,'')					// Hora Início Preparação
aLinha[24] := IF(lConsidSetup,STOD((cAliasCYB)->CYY_DTEDSU),CTOD('01/01/0001'))	// Fim Preparação
aLinha[25] := IF(lConsidSetup,(cAliasCYB)->CYY_HREDSU,'')					// Hora Fim Preparação
If cTipo == '2'
	aLinha[26] := STOD((cAliasCYW)->CYW_DTBGRP)// Início Reporte
	aLinha[27] := (cAliasCYW)->CYW_HRBGRP	// Hora Início Reporte
	aLinha[28] := STOD((cAliasCYW)->CYW_DTEDRP)	// Fim Reporte
	aLinha[29] := (cAliasCYW)->CYW_HREDRP	// Hora Fim Reporte
Else
	aLinha[26] := STOD((cAliasCYB)->CYV_DTRPBG)	// Início Reporte
	aLinha[27] := (cAliasCYB)->CYV_HRRPBG	// Hora Início Reporte
	aLinha[28] := STOD((cAliasCYB)->CYV_DTRPED)	// Fim Reporte
	aLinha[29] := (cAliasCYB)->CYV_HRRPED	// Hora Fim Reporte
EndIf

if cTipo == '1'

	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CY9')+(cAliasCYB)->CYV_NRORPO+(cAliasCYB)->CYV_IDAT+(cAliasCYB)->CYV_IDATQO))

	nTempoPadSetup := IF(lConsidSetup,(cAliasCYB)->CYY_QTPASU / 3600,0)
	nTempoPadOper  := SFCA314OPER((cAliasCYB)->CYB_CDCETR,(cAliasCYB)->CYV_NRORPO,(cAliasCYB)->CYV_IDAT,(cAliasCYB)->CYY_QTAT,2,(cAliasCYB)->CYY_CDFE)
	nTempoSetup    := IF(lConsidSetup,(cAliasCYB)->CYY_QTTESU / 3600,0)
	
	nTempoPadOper := (nTempoPadOper[1] / (cAliasCYB)->CYY_QTAT) * (cAliasCYB)->CYV_QTATRP
	nTempoPadOper := Round(nTempoPadOper / 3600,4)
	
	if (cAliasCYB)->CYV_QTATRP == 0 
		nQualidade := 100
		nQualiReal := 100		
	Else
		nQualidade := (cAliasCYB)->CYV_QTATAP / (cAliasCYB)->CYV_QTATRP * 100
		nQualiReal := ((cAliasCYB)->CYV_QTATAP - (cAliasCYB)->CYV_QTATRT) / (cAliasCYB)->CYV_QTATRP * 100
	Endif
	
	if (cAliasCYB)->CYV_QTTERP == 0 
		nEficiencia := 100
	Else
		if LCONSIND[4] // Preparação altera Eficiencia
			nEficiencia := (nTempoPadOper + nTempoPadSetup) / (((cAliasCYB)->CYV_QTTERP / 3600) + nTempoSetup) * 100
		Else
			nEficiencia := nTempoPadOper / ((cAliasCYB)->CYV_QTTERP / 3600) * 100
		Endif		
	Endif
ElseIf cTipo == '3'
	aLinha[98] := (cAliasCZ0)->CZ0_CDFE
Endif

aLinha[64] := nTempoPadSetup   					   		// Tempo Padrão Preparação
aLinha[65] := nTempoPadOper	   					   		// Tempo Padrão Operação
aLinha[66] := nTempoSetup	   					   		// Tempo Preparação
aLinha[30] := if(cTipo=='1',(cAliasCYB)->CYV_QTTERP / 3600,0)	// Tempo Operação
aLinha[31] := if(cTipo=='1',(cAliasCYB)->CYV_QTTEOE / 3600,0)	// Tempo MOD
aLinha[32] := if(cTipo=='1',(cAliasCYB)->CYV_QTTEEX / 3600,0)	// Tempo Extra
aLinha[33] := if(cTipo=='1',(cAliasCYB)->CYV_QTTESP / 3600,0)	// Tempo Parada	
aLinha[67] := Round(nQualidade,2)						// Qualidade
aLinha[68] := Round(nQualiReal,2)						// Qualidade Real
aLinha[69] := Round(nEficiencia,2)		  		   		// Eficiência
aLinha[34] := if(cTipo=='2',(cAliasCYW)->CYW_CDOE,'')			// Operador
aLinha[35] := if(cTipo=='2',(cAliasCYW)->CYW_CDGROE,'')			// Equipe Produção
aLinha[36] := (cAliasCYB)->CYV_CDTN		// Modelo Turno
aLinha[37] := (cAliasCYB)->CYV_NRTN	   	// Turno Produção
aLinha[38] := (cAliasCYB)->CYV_CDUSRP	// Nome Usuário
aLinha[39] := if((cAliasCYB)->CYV_LGLBCQ=='T',.T.,.F.) // Liberado CQ
aLinha[40] := CY9->CY9_LGATED	// Operação Final
aLinha[41] := (cAliasCYB)->CYV_NRBG 	// Início Contador
aLinha[42] := (cAliasCYB)->CYV_NRED		// Fim Contador
aLinha[101] := (cAliasCYB)->CYQ_CDLIPO  // Linha de Produção
aLinha[102] := (cAliasCYB)->CYQ_CDUSPL  // Planejador
aLinha[103] := (cAliasCYB)->CYQ_CDDP    // Depósito
aLinha[104] := (cAliasCYB)->CYV_VLPNRY  // % Avanço
aLinha[105] := if((cAliasCYB)->CYY_LGCERP=='T',.T.,.F.) // Reportado
aLinha[106] := (cAliasCYB)->CYV_TPGGF //Tipo GGF
aLinha[107] := (cAliasCYB)->CYV_TPMOD // Tipo MOB
aLinha[108] := (cAliasCYB)->CYV_TPRF // Tipo Refugo
aLinha[109] := (cAliasCYB)->CYQ_TPRPOR // Tipo Apontamento
aLinha[110] := (cAliasCYB)->CYV_NRRPOG // Seq Origem
				   
AADD(aDetalhe,aLinha)

RestArea(aAreaCY9)
RestArea(aAreaCYX)
RestArea(aArea)

Return aDetalhe

//-------------------------------------------------------------------
//----------Retorna valor da dimensão para formar chave--------------
//-------------------------------------------------------------------
Static Function SFCXVPR(cTipo,cDimensao,dReferencia)
Local cValor := ''

Do Case
	Case cDimensao == "01" // Estabelecimento
		cValor := (cAliasCYB)->CYA_CDES
	Case cDimensao == "02" // Área de Produção
		cValor := (cAliasCYB)->CYI_CDARPO
	Case cDimensao == "03" // Centro de Trabalho
		cValor := (cAliasCYB)->CYB_CDCETR
	Case cDimensao == "04" // Máquina
		cValor := (cAliasCYB)->CYB_CDMQ
	Case cDimensao == "05" // Linha de Produção
		cValor := (cAliasCYB)->CYQ_CDLIPO
	Case cDimensao == "06" // Planejador
		cValor := (cAliasCYB)->CYQ_CDUSPL
	Case cDimensao == "07" // Equipe
		cValor := if(cTipo=='2',(cAliasCYW)->CYW_CDGROE,PadR("",20))
	Case cDimensao == "08" // Operador
		cValor := if(cTipo=='2',(cAliasCYW)->CYW_CDOE,PadR("",20))
	Case cDimensao == "09" // Item
		cValor := (cAliasCYB)->CYQ_CDAC
	Case cDimensao == "11" // Operação
		cValor := CY9->CY9_DSAT
	Case cDimensao == "12" // Família
		cValor := (cAliasCYB)->CZ3_CDFA
	Case cDimensao == "13" // Grupo de Estoque
		cValor := (cAliasCYB)->CZ3_CDGR
	Case cDimensao == "14" // Cliente
		cValor := (cAliasCYB)->CYQ_NMSIFB
	Case cDimensao == "15" // Pedido
		cValor := (cAliasCYB)->CYQ_CDPD
	Case cDimensao == "16" // Ferramenta
		cValor := if(cTipo=='3',(cAliasCZ0)->CZ0_CDFE,PadR("",20))
	Case cDimensao == "17" // Turno
		cValor := CYM->CYM_CDTN
	Case cDimensao == "18" // Período Mensal
		cValor := ALLTRIM(STR(YEAR(dReferencia))) + "/" + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0")
	Case cDimensao == "19" // Período Semanal
		cValor := ALLTRIM(STR(year(dReferencia))) + '/' + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0") + "/" + SFCXWeekMonth(dReferencia)
	Case cDimensao == "22" // Depósito
		cValor := (cAliasCYB)->CYQ_CDDP
	Case cDimensao == "24" // Tipo de Ordem
		cValor := (cAliasCYB)->CYQ_TPORPO
End Case
	
Return cValor

//-------------------------------------------------------------------
//-------------------------Calcula métricas--------------------------
//-------------------------------------------------------------------
Static Function SFCXSeqPro(nValor)

// Produção Real
aDados[nValor][8] += aDetalhe[Len(aDetalhe)][18]

// Retrabalho Real
aDados[nValor][12] += aDetalhe[Len(aDetalhe)][20]

// Refugo Real
aDados[nValor][10] += aDetalhe[Len(aDetalhe)][21]
           
/* Número Apontamentos */
aDados[nValor][24] += if(aDetalhe[Len(aDetalhe)][18] != 0 .OR. aDetalhe[Len(aDetalhe)][19] != 0,1,0)

/* Tempo Preparação Padrão */
aDados[nValor][25] += aDetalhe[Len(aDetalhe)][64]

/* Tempo Operação Padrão */
aDados[nValor][26] += aDetalhe[Len(aDetalhe)][65]

/* Tempo Preparação Real */
aDados[nValor][27] += aDetalhe[Len(aDetalhe)][66]

/* Tempo Operação Real */
aDados[nValor][28] += aDetalhe[Len(aDetalhe)][30]

/* Horas Normais */
aDados[nValor][29] += aDetalhe[Len(aDetalhe)][30] - aDetalhe[Len(aDetalhe)][32] + aDetalhe[Len(aDetalhe)][66]

/* Horas Extras */
aDados[nValor][30] += aDetalhe[Len(aDetalhe)][32]

/* Qualidade */
aDados[nValor][31] := IF(aDados[nValor][8]==0,100,(aDados[nValor][8] - aDados[nValor][10]) / aDados[nValor][8] * 100)

/* Qualidade Real*/
aDados[nValor][32] := IF(aDados[nValor][8]==0,100,(aDados[nValor][8] - aDados[nValor][10] - aDados[nValor][12]) / aDados[nValor][8] * 100)

/* Eficiência */
if aDados[nValor][26] == 0
	aDados[nValor][33] := 100
Else
	if LCONSIND[4] // Preparação altera Eficiencia
		aDados[nValor][33] := (aDados[nValor][26] + aDados[nValor][25]) / (aDados[nValor][28] + aDados[nValor][27]) * 100
	Else
		aDados[nValor][33] := aDados[nValor][26] / aDados[nValor][28] * 100
	Endif
Endif

if LCONSIND[2]
	aDados[nValor][33] := aDados[nValor][33] * aDados[nValor][31] / 100
Endif

Return nil

//-------------------------------------------------------------------
//--------------------------Fim Produção-----------------------------
//-------------------------------------------------------------------

//-------------------------------------------------------------------
//------------------------Início Indicadores-------------------------
//------------------------------------------------------------------- 
Static Function SFCXIndic()
Local aArea    := GetArea()
Local aAreaCYB := CYB->(GetArea())
Local aAreaCYI := CYI->(GetArea())
Local aAreaCYA := CYA->(GetArea())
Local aAreaCYV := CYV->(GetArea()) 
Local aAreaCYZ := CYZ->(GetArea()) 
Local aAreaCYR := CYR->(GetArea()) 
Local aAreaCYW := CYW->(GetArea()) 
Local aAreaCY0 := CY0->(GetArea())
Local aAreaCZ0 := CZ0->(GetArea()) 
Local nI	   := 0
Local cValCYVIni := ''
Local cValCYVFim := ''
Local dAux       := date()
Local cCDTN      := ''
Local nQtdProd   := 0
Local dReferencia := date()
Private cAliasCYB := GetNextAlias()
Private cAliasCYV := GetNextAlias()
Private cAliasCYW := GetNextAlias()
Private cAliasCY0 := GetNextAlias()
Private cAliasCZ0 := GetNextAlias()

Private cValRefIni  := ''
Private cValRefFim  := '' 
Private SEQMETA     := ''
Private nTipoParada := 1 // 1-Não Programada 2-Programada e Realizada 3-Programada e Não realizada 
Private cTipoReg    := '1' // 1-Produção, 2-MOB, 3-Ferramenta, 4-Refugo/Retrabalho, 5-Parada, 6-Recursos

BeginSql Alias cAliasCYB
   	
	SELECT * FROM %Table:CYB% CYB
		INNER JOIN %Table:CYI% CYI ON CYI.CYI_FILIAL = %xFilial:CYI% AND
			                          CYI.CYI_CDCETR = CYB.CYB_CDCETR
		INNER JOIN %Table:CYA% CYA ON CYA.CYA_FILIAL = %xFilial:CYA% AND
			                          CYA.CYA_CDARPO = CYI.CYI_CDARPO
		WHERE CYB.CYB_FILIAL=%xFilial:CYB% AND 
			  CYB.CYB_CDMQ>=%Exp:CDMQINI% AND
			  CYB.CYB_CDMQ<=%Exp:CDMQFIM% AND
			  CYB.CYB_CDCETR>=%Exp:CDCETRINI% AND
			  CYB.CYB_CDCETR<=%Exp:CDCETRFIM% AND
			  CYI.CYI_CDARPO>=%Exp:CDARPOINI% AND 
			  CYI.CYI_CDARPO<=%Exp:CDARPOFIM% AND
		      CYA.CYA_CDES>=%Exp:CDESINI% AND
		      CYA.CYA_CDES<=%Exp:CDESFIM% AND
			  CYB.%NotDel% AND
			  CYI.%NotDel% AND
			  CYA.%NotDel% 
EndSql

While (cAliasCYB)->(!EOF())
	        
	aRetorno := SFCXRetCalen() // retorna num array: data inicio, hora inicio, data fim, hora fim, calendario
	
	IF cFunction == '4'
		cValRefIni := DTOS(aRetorno[1]) + '.' + ALLTRIM(STR(SFCXHourToSeg(aRetorno[2])))
		cValRefFim := DTOS(aRetorno[3]) + '.' + ALLTRIM(STR(SFCXHourToSeg(aRetorno[4])))
	Else 
		cValRefIni := DTOS(aRetorno[1]) + '.' + ALLTRIM(STR(SFCXHourToSeg(aRetorno[2])))
		cValRefFim := DTOS(DTRPFIM) + '.' + ALLTRIM(STR(SFCXHourToSeg(HRREFER)))
	Endif
	
	// --------------- Início Capacidade
	dbSelectArea("CYZ")
	CYZ->(dbSetOrder(1))
	CYZ->(dbGoTop())
	
	For dAux := DTRPINI to DTRPFIM
		cCDTN := SFCTurnoMaq((cAliasCYB)->CYB_CDMQ, dAux)
		
		if CYZ->(dbSeek(xFilial('CYZ')+aRetorno[5]+DTOS(dAux))) .AND. CYZ->CYZ_TPDY == '1'
			dbSelectArea("CYR")
			CYR->(dbSetOrder(2))
			CYR->(dbGoTop())
			CYR->(dbSeek(xFilial('CYR')+cCDTN+ALLTRIM(STR(DOW(dAux)))))
			
			While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == ALLTRIM(STR(DOW(dAux)))
			
				if CYR->CYR_TPTE == '1'
					SFCXDIndicadores('1',dAux)

					cTipoReg := '6'
					cCodPai  := ""

					For nI := 1 to Len(aFieldsSel)
						SFCXBuscaValor(aFieldsSel[nI][1],dAux,'CYR')
						SFCXSequencia(nI,aFieldsSel[nI][1])
					Next
				Endif
				
				CYR->(dbSkip())
			End
		Endif
	Next			
	// ------------------ Fim Capacidade
        		           
	// --------------- Início Reportes
	if cFunction == '5'
       	dbSelectArea("CYS")
		CYS->(dbSetOrder(1))
		CYS->(dbGoTop())
		CYS->(dbSeek(xFilial('CYS')))
		
		if Len(aDados) > 0
			aDados[1][67] := (cAliasCYB)->CYI_CDUNVM
		Endif
	Endif
        
	IF cFunction == '4' .OR.; // Indicadores via Gerencial
	  (cFunction == '5' .AND. !CYS->(dbSeek(xFilial('CYS')+IDMETA))) // Indicadores via cálculo de meta
	  
		BeginSql Alias cAliasCYV
   	
			SELECT * FROM %Table:CYV% CYV
				WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND 
					  CYV.CYV_CDMQ=%Exp:(cAliasCYB)->CYB_CDMQ% AND
					  CYV.CYV_LGRPEO='F' AND
					  CYV.CYV_NRTN>=%Exp:NRTNINI% AND
					  CYV.CYV_NRTN<=%Exp:NRTNFIM% AND
					  CYV.%NotDel% 
		EndSql
		
		While (cAliasCYV)->(!EOF())
		
			if (cAliasCYV)->CYV_TPSTRP <> '1'
		
				cValCYVIni := (cAliasCYV)->CYV_DTRPBG + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCYV)->CYV_HRRPBG)))
				cValCYVFim := (cAliasCYV)->CYV_DTRPED + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCYV)->CYV_HRRPED)))
				
				if (cValCYVIni >= cValRefIni .AND. cValCYVIni <  cValRefFim) .OR.;
				   (cValCYVFim >  cValRefIni .AND. cValCYVFim <= cValRefFim) .OR.;
				   (cValCYVIni <= cValRefIni .AND. cValCYVFim >= cValRefFim)
					
					dReferencia := STOD((cAliasCYV)->CYV_DTRPBG)
					cTipoReg    := '1'
					cCodPai     := ""
						
					// Registros de Apontamento de Produção
					SFCXDIndicadores('2',dReferencia,cTipoReg)
											
					For nI := 1 to Len(aFieldsSel)
						SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CYV')
						SFCXSequencia(nI,aFieldsSel[nI][1])
					Next
					// Fim
					                                    
					// Registros de Apontamento de MOB    
					BeginSql Alias cAliasCYW
	   	
						SELECT * FROM %Table:CYW% CYW
							WHERE CYW.CYW_FILIAL=%xFilial:CYW% AND 
								  CYW.CYW_NRSQRP=%Exp:(cAliasCYV)->CYV_NRSQRP% AND
								  CYW.CYW_CDOE>=%Exp:CDOEINI% AND
								  CYW.CYW_CDOE<=%Exp:CDOEFIM% AND
								  CYW.CYW_CDGROE>=%Exp:CDGRPOINI% AND
								  CYW.CYW_CDGROE<=%Exp:CDGRPOFIM% AND
								  CYW.%NotDel% 
					EndSql
					
					While (cAliasCYW)->(!EOF())
						cTipoReg := '2'
						cCodPai  := ""
								
						SFCXDIndicadores('2',dReferencia,cTipoReg)
								
						For nI := 1 to Len(aFieldsSel)
							SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CYW')
							SFCXSequencia(nI,aFieldsSel[nI][1])
						Next
						
						(cAliasCYW)->(dbSkip())
					End
					
					(cAliasCYW)->(dbCloseArea())
					// Fim
												
					// Registros de Apontamento de Ferramenta				
					BeginSql Alias cAliasCZ0
	   	
						SELECT * FROM %Table:CZ0% CZ0
							WHERE CZ0.CZ0_FILIAL=%xFilial:CZ0% AND 
								  CZ0.CZ0_NRSQRP=%Exp:(cAliasCYV)->CYV_NRSQRP% AND
								  CZ0.CZ0_CDFE>=%Exp:CDFEINI% AND
								  CZ0.CZ0_CDFE<=%Exp:CDFEFIM% AND
								  CZ0.%NotDel% 
					EndSql
					
					While (cAliasCZ0)->(!EOF())
						cTipoReg := '3'
						cCodPai  := ""
								
						SFCXDIndicadores('2',dReferencia,cTipoReg)
								
						For nI := 1 to Len(aFieldsSel)
							SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CZ0')
							SFCXSequencia(nI,aFieldsSel[nI][1])
						Next
						
						(cAliasCZ0)->(dbSkip())
					End
					
					(cAliasCZ0)->(dbCloseArea())
					// Fim
												
					// Registros de Apontamento de Refugo
					BeginSql Alias cAliasCY0
	   	
						SELECT * FROM %Table:CY0% CY0
							WHERE CY0.CY0_FILIAL=%xFilial:CY0% AND 
								  CY0.CY0_NRSQRP=%Exp:(cAliasCYV)->CYV_NRSQRP% AND
								  CY0.CY0_CDRF>=%Exp:CDRFINI% AND
								  CY0.CY0_CDRF<=%Exp:CDRFFIM% AND
								  CY0.%NotDel% 
					EndSql
					
					While (cAliasCY0)->(!EOF())
						cTipoReg := '4'
						cCodPai  := ""
								
						SFCXDIndicadores('2',dReferencia,cTipoReg)
							
						For nI := 1 to Len(aFieldsSel)
							SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CY0')
							SFCXSequencia(nI,aFieldsSel[nI][1])
						Next
						
						(cAliasCY0)->(dbSkip())
					End
					
					(cAliasCY0)->(dbCloseArea())
					// Fim
					
				Endif
			Endif
			
			(cAliasCYV)->(dbSkip())
		End
		
		(cAliasCYV)->(dbCloseArea())
	Else // Indicadores via cálculo da meta
  		While CYS->(!EOF()) .AND. CYS->CYS_IDMEPO == IDMETA
			
			SEQMETA := CYS->CYS_NRSQME
			
			if CYS->CYS_NRTN != '0'
				NRTNINI := CYS->CYS_NRTN
				NRTNFIM := CYS->CYS_NRTN
			Else
				NRTNINI := PadR("",5)
				NRTNFIM := PadR("",5, "9")
			Endif
			
			nQtdProd := 0
			
			BeginSql Alias cAliasCYV
   	
				SELECT * FROM %Table:CYV% CYV
					WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND 
						  CYV.CYV_CDMQ=%Exp:(cAliasCYB)->CYB_CDMQ% AND
						  CYV.CYV_LGRPEO='F' AND
						  CYV.CYV_NRORPO=%Exp:CYS->CYS_NRORPO% AND
						  CYV.CYV_IDAT=%Exp:CYS->CYS_IDAT% AND
						  CYV.CYV_IDATQO=%Exp:CYS->CYS_IDATQO% AND
						  CYV.CYV_NRTN>=%Exp:NRTNINI% AND
						  CYV.CYV_NRTN<=%Exp:NRTNFIM% AND
						  CYV.%NotDel% 
			EndSql
			
			While (cAliasCYV)->(!EOF())
			
				if (cAliasCYV)->CYV_TPSTRP <> '1'			
									  
					cValCYVIni := (cAliasCYV)->CYV_DTRPBG + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCYV)->CYV_HRRPBG)))
					cValCYVFim := (cAliasCYV)->CYV_DTRPED + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCYV)->CYV_HRRPED)))
				
					if (cValCYVIni >= cValRefIni .AND. cValCYVIni <  cValRefFim) .OR.;
					   (cValCYVFim >  cValRefIni .AND. cValCYVFim <= cValRefFim) .OR.;
					   (cValCYVIni <= cValRefIni .AND. cValCYVFim >= cValRefFim)
				
						dReferencia := STOD((cAliasCYV)->CYV_DTRPBG)
						cTipoReg    := '1'
						cCodPai     := ""
					
						// Registros de Apontamento de Produção
						SFCXDIndicadores('2',dReferencia,cTipoReg)
												
						For nI := 1 to Len(aFieldsSel)
							SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CYV')
							SFCXSequencia(nI,aFieldsSel[nI][1])
						Next
						// Fim
						
						nQtdProd += (cAliasCYV)->CYV_QTATAP										
						                                    
						// Registros de Apontamento de MOB    
						BeginSql Alias cAliasCYW
	   	
							SELECT * FROM %Table:CYW% CYW
								WHERE CYW.CYW_FILIAL=%xFilial:CYW% AND 
									  CYW.CYW_NRSQRP=%Exp:(cAliasCYV)->CYV_NRSQRP% AND
									  CYW.CYW_CDOE>=%Exp:CDOEINI% AND
									  CYW.CYW_CDOE<=%Exp:CDOEFIM% AND
									  CYW.CYW_CDGROE>=%Exp:CDGRPOINI% AND
									  CYW.CYW_CDGROE<=%Exp:CDGRPOFIM% AND
									  CYW.%NotDel% 
						EndSql
						
						While (cAliasCYW)->(!EOF())
							cTipoReg := '2'
							cCodPai  := ""
									
							SFCXDIndicadores('2',dReferencia,cTipoReg)
									
							For nI := 1 to Len(aFieldsSel)
								SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CYW')
								SFCXSequencia(nI,aFieldsSel[nI][1])
							Next
							
							(cAliasCYW)->(dbSkip())
						End
						
						(cAliasCYW)->(dbCloseArea())
						// Fim
													
						// Registros de Apontamento de Ferramenta
						BeginSql Alias cAliasCZ0
	   	
							SELECT * FROM %Table:CZ0% CZ0
								WHERE CZ0.CZ0_FILIAL=%xFilial:CZ0% AND 
									  CZ0.CZ0_NRSQRP=%Exp:(cAliasCYV)->CYV_NRSQRP% AND
									  CZ0.CZ0_CDFE>=%Exp:CDFEINI% AND
									  CZ0.CZ0_CDFE<=%Exp:CDFEFIM% AND
									  CZ0.%NotDel% 
						EndSql
						
						While (cAliasCZ0)->(!EOF())
							cTipoReg := '3'
							cCodPai  := ""
									
							SFCXDIndicadores('2',dReferencia,cTipoReg)
									
							For nI := 1 to Len(aFieldsSel)
								SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CZ0')
								SFCXSequencia(nI,aFieldsSel[nI][1])
							Next
												
							(cAliasCZ0)->(dbSkip())
						End
						
						(cAliasCZ0)->(dbCloseArea())
						// Fim
														
						// Registros de Apontamento de Refugo
						BeginSql Alias cAliasCY0
	   	
							SELECT * FROM %Table:CY0% CY0
								WHERE CY0.CY0_FILIAL=%xFilial:CY0% AND 
									  CY0.CY0_NRSQRP=%Exp:(cAliasCYV)->CYV_NRSQRP% AND
									  CY0.CY0_CDRF>=%Exp:CDRFINI% AND
									  CY0.CY0_CDRF<=%Exp:CDRFFIM% AND
									  CY0.%NotDel% 
						EndSql
						
						While (cAliasCY0)->(!EOF())
							cTipoReg := '4'
							cCodPai  := ""
									
							SFCXDIndicadores('2',dReferencia,cTipoReg)
							
							For nI := 1 to Len(aFieldsSel)
								SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CY0')
								SFCXSequencia(nI,aFieldsSel[nI][1])
							Next
							
							(cAliasCY0)->(dbSkip())
						End
						
						(cAliasCY0)->(dbCloseArea())
						// Fim
					Endif
				Endif
				
				(cAliasCYV)->(dbSkip())
			End
			
			(cAliasCYV)->(dbCloseArea())
			
			if Len(aDados) > 0
				aDados[1][50] += MIN(nQtdProd,CYS->CYS_QTPLAT)
				aDados[1][49] += nQtdProd
			Endif
			
			aadd(aMeta,{CYS->CYS_IDMEPO,CYS->CYS_NRSQME,DTRPINI,HRREFER,CYS->CYS_CDMQ,CYS->CYS_DTBGRE,CYS->CYS_HRBGAT,CYS->CYS_DTEDRE,CYS->CYS_HREDAT,;
						CYS->CYS_TPMV,CYS->CYS_CDAC,CYS->CYS_NRORPO,CYS->CYS_IDAT,CYS->CYS_IDATQO,CYS->CYS_QTTEPL,CYS->CYS_QTPLAT,CYS->CYS_QTPLUN,CYS->CYS_NRTN})

			CYS->(dbSkip())
		End			 
	Endif
	// ------------------ Fim Reportes
	
	// ---------------- Início Paradas
	cTipoReg := '5'
	
	SFCXParCYX() // Programadas efetivadas e não programadas
	SFCXParCZ2() // Programadas não efetivadas
	// ---------------- Fim Paradas
		
	(cAliasCYB)->(dbSkip())
End

(cAliasCYB)->(dbCloseArea())

RestArea(aAreaCYB)
RestArea(aAreaCYI)
RestArea(aAreaCYA)
RestArea(aAreaCYV)
RestArea(aAreaCY0)
RestArea(aAreaCYZ)
RestArea(aAreaCYR)
RestArea(aAreaCYW)
RestArea(aAreaCZ0)
RestArea(aArea)
	
Return nil

//-------------------------------------------------------------------
// nTipo    - 1=Recurso; 2=Reporte; 3=Parada
// nSubTipo - Quanto tipo == 2: 1=Produção; 2=MOB; 3=Ferramenta; 4=Refugo/Retrabalho
//			  Quanto tipo == 3: 1=Não Programada; 2=Programada Efetivada; 3=Programada
//-------------------------------------------------------------------
Static Function SFCXDIndicadores(cTipo,dReferencia,cSubTipo) 
Local aLinha   		 := Array(110)
Local aArea    		 := GetArea()
Local aAreaCY9 		 := CY9->(GetArea())
Local aAreaCYY 		 := CYY->(GetArea())
Local aAreaCYX 		 := CYX->(GetArea())
Local nPercQualidade := 0
Local nQualidadeReal := 0
Local nEficiencia 	 := 0
Local nTempoPadOper  := 0
Local nTempoSetup    := 0
Local nTempoPadSetup := 0
Local lConsidSetup   := .T.
Local nI			 := 0
Default lAutoMacao   := .F.

// Tipo de registro deste array, varia entre os valores: 
// 1=Produção; 2=MOB; 3=Ferramenta; 4=Refugo/Retrabalho; 5=Parada; 6=Parada Programada; 7=Preparação; 8=Capacidade 

// 01 Relacionamento
For nI := 1 to Len(aFieldsSel)
	if nI == 1
		aLinha[1] := ''
	Endif
	
	aLinha[1] += SFCXVIND(cTipo,cSubTipo,substr(aFieldsSel[nI][1],1,2),dReferencia) + '.'
Next

IF !lAutoMacao
	aLinha[3]  := (cAliasCYB)->CYA_CDES		// Estabelecimento
	aLinha[10] := (cAliasCYB)->CYI_CDARPO	// Área de Produção
	aLinha[11] := (cAliasCYB)->CYB_CDCETR	// Centro de Trabalho
	aLinha[44] := (cAliasCYB)->CYB_CDMQ		// Máquina

	// Capacidade Máquina
	aLinha[90] := (cAliasCYB)->CYB_QTVMMQ   
	IF Empty(aLinha[90]) .OR. aLinha[90] == 0
		aLinha[90] := 1
	Endif
ENDIF

if cTipo == '1' // Recurso
	aLinha[71] := '8'				   		// Tipo Registro
	aLinha[72] := dReferencia				// Data Início
	aLinha[73] := CYR->CYR_HRBG				// Hora Início
	aLinha[74] := dReferencia				// Data Fim
	aLinha[75] := CYR->CYR_HRED				// Hora Fim
	aLinha[76] := (cAliasCYB)->CYI_CDUNVM
	aLinha[77] := SFCA311VTP(CYR->CYR_CDTN, CYR->CYR_NRDYWK, CYR->CYR_HRBG, CYR->CYR_HRED, 0, 0)[1]
	aLinha[78] := (aLinha[77] / 3600) * if(Empty(aLinha[76]),1,aLinha[90]) 	// Hora Disponibilidade Capacidade
	aLinha[36] := CYR->CYR_CDTN
	aLinha[37] := CYR->CYR_NRTN
	
	For nI := 64 to 69
		aLinha[nI] := 0	
	Next
	
	For nI := 79 to 89
		aLinha[nI] := 0	
	Next
	
	aLinha[18] := 0
	aLinha[19] := 0
	aLinha[20] := 0
	aLinha[21] := 0
	aLinha[30] := 0
	aLinha[31] := 0
	aLinha[32] := 0
	aLinha[33] := 0
	aLinha[45] := ''
	aLinha[52] := 0	
		
ElseIf cTipo == '2' // Reportes

	dbSelectArea("CYQ")
	CYQ->(dbSetOrder(1))
	CYQ->(dbGoTop())
	CYQ->(dbSeek(xFilial('CYQ')+(cAliasCYV)->CYV_NRORPO))

	dbSelectArea("CY9")
	CY9->(dbSetOrder(1))
	CY9->(dbGoTop())
	CY9->(dbSeek(xFilial('CY9')+(cAliasCYV)->CYV_NRORPO+(cAliasCYV)->CYV_IDAT))
	
	dbSelectArea("CYY")
	CYY->(dbSetOrder(1))
	CYY->(dbGoTop())
	CYY->(dbSeek(xFilial('CYY')+(cAliasCYV)->CYV_NRORPO+(cAliasCYV)->CYV_IDAT+(cAliasCYV)->CYV_IDATQO))
	
	dbSelectArea("CYX")
	CYX->(dbSetOrder(1))
	CYX->(dbGoTop())
	lConsidSetup := CYX->(dbSeek(xFilial('CYX')+CYY->CYY_CDMQ+DTOS(CYY->CYY_DTBGSU)+CYY->CYY_HRBGSU))
    
	aLinha[71] := cSubTipo			// Tipo Registro
	aLinha[4]  := (cAliasCYV)->CYV_NRORPO	// Ordem Produção
	aLinha[6]  := (cAliasCYV)->CYV_IDAT		// Número Operação
	aLinha[7]  := (cAliasCYV)->CYV_IDATQO	// Split
	aLinha[8]  := (cAliasCYV)->CYV_NRSQRP	// Sequência Reporte
	aLinha[9]  := if(cSubTipo=='4',(cAliasCY0)->CY0_CDRF,'')
	aLinha[12] := (cAliasCYV)->CYV_CDACRP	// Item
	aLinha[70] := CYQ->CYQ_CDRE		// Referência
	aLinha[13] := CY9->CY9_CDRT		// Roteiro
	aLinha[14] := CY9->CY9_CDAT		// Operação
	aLinha[15] := CZ3->CZ3_CDFA		// Família
	aLinha[16] := CZ3->CZ3_CDGR		// Grupo de Estoque
	aLinha[17] := CYQ->CYQ_TPORPO	// Tipo Ordem
	aLinha[18] := if(cSubTipo=='1',(cAliasCYV)->CYV_QTATRP,0)	// Quant Reportada
	aLinha[19] := if(cSubTipo=='1',(cAliasCYV)->CYV_QTATAP,0)	// Quant Aprovada
	aLinha[21] := if(cSubTipo=='4',(cAliasCY0)->CY0_QTRF,0)		// Quant Refugada
	aLinha[20] := if(cSubTipo=='4',(cAliasCY0)->CY0_QTRT,0)		// Quant Retrabalhada
	aLinha[22] := if(lConsidSetup,CYY->CYY_DTBGSU,CTOD('01/01/0001'))	// Início Preparação
	aLinha[23] := if(lConsidSetup,CYY->CYY_HRBGSU,'')  					// Hora Início Preparação
	aLinha[24] := if(lConsidSetup,CYY->CYY_DTEDSU,CTOD('01/01/0001'))	// Fim Preparação
	aLinha[25] := if(lConsidSetup,CYY->CYY_HREDSU,'')					// Hora Fim Preparação
	aLinha[34] := if(cSubTipo=='2',(cAliasCYW)->CYW_CDOE,'')	// Operador
	aLinha[35] := if(cSubTipo=='2',(cAliasCYW)->CYW_CDGROE,'')	// Equipe Produção
	aLinha[36] := (cAliasCYV)->CYV_CDTN     // Modelo Turno
	aLinha[37] := (cAliasCYV)->CYV_NRTN		// Turno	
	aLinha[41] := (cAliasCYV)->CYV_NRBG 	// Início Contador
	aLinha[42] := (cAliasCYV)->CYV_NRED		// Fim Contador
	aLinha[72] := IIF(!lAutoMacao, STOD((cAliasCYV)->CYV_DTRPBG),"")	// Data Início
	aLinha[73] := (cAliasCYV)->CYV_HRRPBG	// Hora Início
	aLinha[74] := IIF(!lAutoMacao, STOD((cAliasCYV)->CYV_DTRPED),"")	// Data Fim
	aLinha[75] := (cAliasCYV)->CYV_HRRPED	// Hora Fim
	aLinha[76] := (cAliasCYB)->CYI_CDUNVM	// Unidade Capacidade
	aLinha[101] := CYQ->CYQ_CDLIPO  // Linha de Produção
	aLinha[102] := CYQ->CYQ_CDUSPL  // Planejador
	aLinha[103] := CYQ->CYQ_CDDP    // Depósito
	aLinha[104] := (cAliasCYV)->CYV_VLPNRY  // % Avanço
	aLinha[105] := CYY->CYY_LGCERP // Reportado
	aLinha[106] := (cAliasCYV)->CYV_TPGGF //Tipo GGF
	aLinha[107] := (cAliasCYV)->CYV_TPMOD // Tipo MOB
	aLinha[108] := (cAliasCYV)->CYV_TPRF // Tipo Refugo
	aLinha[109] := CYQ->CYQ_TPRPOR // Tipo Apontamento
	aLinha[110] := (cAliasCYV)->CYV_NRRPOG // Seq Origem
	if cSubTipo == '1'
		nPercQualidade := Round(IF((cAliasCYV)->CYV_QTATRP==0,0,(cAliasCYV)->CYV_QTATAP / (cAliasCYV)->CYV_QTATRP * 100),4)
		nQualidadeReal := Round(IF((cAliasCYV)->CYV_QTATRP==0,0,((cAliasCYV)->CYV_QTATAP - (cAliasCYV)->CYV_QTATRT) / (cAliasCYV)->CYV_QTATRP * 100),4)
		nTempoPadOper  := SFCA314OPER(CY9->CY9_CDCETR,(cAliasCYV)->CYV_NRORPO,(cAliasCYV)->CYV_IDAT,CYY->CYY_QTAT,2,CYY->CYY_CDFE)
		
		if cFunction == '5'
			aLinha[99]  := SEQMETA			// Sequencia Meta
			aLinha[100] := (cAliasCYV)->CYV_QTTERP / (nTempoPadOper[1] / CYY->CYY_QTAT)					
		Endif
		
		nTempoPadOper := (nTempoPadOper[1] / CYY->CYY_QTAT) * (cAliasCYV)->CYV_QTATRP
		nTempoPadOper := Round(nTempoPadOper / 3600,4)
		
		if lConsidSetup
			nTempoSetup    := Round((CYX->CYX_QTTEUT + IF(LCONSIND[3],CYX->CYX_QTTEEX,0)) / 3600,4)
			nTempoPadSetup := Round(CYY->CYY_QTPASU / 3600,4)
		Endif
	Endif
	
	aLinha[67] := nPercQualidade			// Qualidade 		
	aLinha[68] := nQualidadeReal			// Qualidade Real
	aLinha[66] := if(cSubTipo=='1',nTempoSetup,0)						// Tempo Preparação
	aLinha[30] := if(cSubTipo=='1',Round((cAliasCYV)->CYV_QTTERP / 3600,4),0)   			// Tempo Operação
	aLinha[32] := if(cSubTipo=='1',Round((cAliasCYV)->CYV_QTTEEX / 3600,4),0)  			// Tempo Extra
	aLinha[33] := if(cSubTipo=='1',Round((cAliasCYV)->CYV_QTTESP / 3600,4),0)   			// Tempo Parada
	aLinha[64] := if(cSubTipo=='1',nTempoPadSetup,0)					// Tempo Padrão Preparação
	aLinha[65] := if(cSubTipo=='1',nTempoPadOper,0)						// Tempo Padrão Operação		
	aLinha[53] := if(cSubTipo=='1',IF(LCONSIND[4],CY9->CY9_QTTESU,0),0)	// Tempo Operação Preparação
	
	if cSubTipo == '1' .AND. (cAliasCYV)->CYV_QTATRP > 0
		if LCONSIND[4] // Preparação altera Eficiencia
			nEficiencia := (aLinha[65] + aLinha[64]) / (aLinha[30] + aLinha[66])
		Else
			nEficiencia := aLinha[65] / aLinha[30]
		Endif		
		
		nEficiencia := Round((nEficiencia * if(LCONSIND[2],nPercQualidade / 100,1)) * 100,4)
	Endif
	
	aLinha[69] := nEficiencia		// Eficiência
	aLinha[79] := CYY->CYY_QTVMAT	// Capacidade Operação
	aLinha[80] := CYY->CYY_QTAT		// Número Unidade Operação
	aLinha[81] := CYV->CYV_QTATRP / CYY->CYY_QTAT * CYY->CYY_QTVMAT	// Quantidade Processada	
	aLinha[98] := if(cSubTipo=='3',(cAliasCZ0)->CZ0_CDFE,'')				// Ferramenta
	
	For nI := 82 to 89
		aLinha[nI] := 0	
	Next
	
	aLinha[77] := 0	
	aLinha[78] := 0	
	aLinha[79] := 0
	aLinha[45] := ''	

Else // Parada

	aLinha[34] := if(cSubTipo!='3',(cAliasCYX)->CYX_CDOE,'')	// Operador
	aLinha[35] := if(cSubTipo!='3',(cAliasCYX)->CYX_CDGROE,'')	// Equipe Produção
	aLinha[36] := if(cSubTipo!='3',(cAliasCYX)->CYX_CDTN,'')	// Modelo Turno
	aLinha[37] := if(cSubTipo!='3',(cAliasCYX)->CYX_NRTN,'')	// Turno
	aLinha[71] := IF(!Empty((cAliasCYX)->CYX_NRSQRP),'7',if(cSubTipo=='3','6','5'))	// Tipo Registro
	aLinha[72] := STOD(if(cSubTipo!='3',(cAliasCYX)->CYX_DTBGSP,(cAliasCZ2)->CZ2_DTBGPL))	// Data Início
	aLinha[73] := if(cSubTipo!='3',(cAliasCYX)->CYX_HRBGSP,(cAliasCZ2)->CZ2_HRBGPL)			// Hora Início
	aLinha[74] := STOD(if(cSubTipo!='3',(cAliasCYX)->CYX_DTEDSP,(cAliasCZ2)->CZ2_DTEDPL))	// Data Fim
	aLinha[75] := if(cSubTipo!='3',(cAliasCYX)->CYX_HREDSP,(cAliasCZ2)->CZ2_HREDPL)   		// Hora Fim
	aLinha[45] := if(cSubTipo!='3',(cAliasCYX)->CYX_CDSP,(cAliasCZ2)->CZ2_CDSP)				// Parada
	aLinha[82] := if((cAliasCYX)->CYN_LGEF=='T',.T.,.F.)									// Altera Eficiência
	aLinha[83] := if(cSubTipo=='1',.F.,.T.)									// Parada Programada	
	aLinha[84] := if(cSubTipo=='3',Round(((cAliasCZ2)->CZ2_QTTEMQ + (cAliasCZ2)->CZ2_QTTEEX) / 3600,4),0)	// Quant Parada Programada
	aLinha[85] := if(cSubTipo=='3',Round((cAliasCZ2)->CZ2_QTTEMQ / 3600,4),0)				   		// Quant Parada Programada Útil
	aLinha[86] := if(cSubTipo!='3',Round(((cAliasCYX)->CYX_QTTEUT + (cAliasCYX)->CYX_QTTEEX) / 3600,4),0)	// Quant Parada Real
	aLinha[87] := if(cSubTipo!='3',Round((cAliasCYX)->CYX_QTTEUT / 3600,4),0)	// Quant Parada Real Útil
	aLinha[88] := IF((cAliasCYX)->CYN_LGEF=='T',Round((cAliasCYX)->CYX_QTTEUT / 3600,4),0)	// Quant Parada Altera Eficiência
	aLinha[89] := IF((cAliasCYX)->CYN_LGEF=='T',0,Round((cAliasCYX)->CYX_QTTEUT / 3600,4))	// Quant Parada não Altera Eficiência
	aLinha[98] := if(cSubTipo!='3',(cAliasCYX)->CYX_CDFEPO,'') 			// Ferramenta
	aLinha[32] := if(cSubTipo!='3',Round((cAliasCYX)->CYX_QTTEEX / 3600,4),0)
	aLinha[52] := if(cSubTipo!='3',Round((cAliasCYX)->CYX_QTTEUT / 3600,4),0)
	
	// Zera as informações
	aLinha[18] := 0
	aLinha[19] := 0
	aLinha[20] := 0
	aLinha[21] := 0
	aLinha[30] := 0
	aLinha[31] := 0
	//aLinha[32] := 0
	aLinha[33] := 0
	//aLinha[52] := 0 
	aLinha[64] := 0
	aLinha[65] := 0
	aLinha[66] := 0
	aLinha[67] := 0
	aLinha[68] := 0
	aLinha[69] := 0
	aLinha[77] := 0
	aLinha[78] := 0
	aLinha[79] := 0
	aLinha[70] := ''
	aLinha[81] := 0
Endif

AADD(aDetalhe,aLinha)

RestArea(aAreaCY9)
RestArea(aAreaCYY)
RestArea(aAreaCYX)
RestArea(aArea)

Return nil

//-------------------------------------------------------------------
//-----------------------Carrega métricas----------------------------
//-------------------------------------------------------------------
Static Function SFCXSeqInd(nValor)
Local nAux  := 0

//----------Refugos e Retrabalhos----------
if aDetalhe[Len(aDetalhe)][71] == '1' .OR.;
   aDetalhe[Len(aDetalhe)][71] == '4'
	SFCXSeqReR(nValor)
Endif
//-------------------Fim------------------- 

//-----------------Paradas-----------------
if aDetalhe[Len(aDetalhe)][71] == '5' .OR.;
   aDetalhe[Len(aDetalhe)][71] == '6' .OR.;
   aDetalhe[Len(aDetalhe)][71] == '7'
	SFCXSeqPar(nValor)
Endif
//-------------------Fim------------------- 

//-----------------Produção----------------
aDados[nValor][24] += if(aDetalhe[Len(aDetalhe)][18] != 0 .OR. aDetalhe[Len(aDetalhe)][19] != 0,1,0)
//-------------------Fim------------------- 

nAux := if(Empty(aDetalhe[Len(aDetalhe)][78]),0,aDetalhe[Len(aDetalhe)][78])

// Quantidade Planejada
aDados[nValor][68] += CYY->CYY_QTAT

/* Capacidade de Projeto */
aDados[nValor][34] += nAux 

/* Capacidade Efetiva */
aDados[nValor][35] += nAux

/* Capacidade Real */
aDados[nValor][36] += nAux

if aDetalhe[Len(aDetalhe)][71] != '5' .OR.;
   aDetalhe[Len(aDetalhe)][71] != '7'

	if LCONSIND[3]  .AND.;
	  (aDetalhe[Len(aDetalhe)][32] > 0 .OR. aDetalhe[Len(aDetalhe)][86] - aDetalhe[Len(aDetalhe)][87] > 0)

		nAux := (aDetalhe[Len(aDetalhe)][32] + aDetalhe[Len(aDetalhe)][86] - aDetalhe[Len(aDetalhe)][87]) * if(Empty(aDetalhe[Len(aDetalhe)][76]),1,aDetalhe[Len(aDetalhe)][90])
	
		aDados[nValor][34] += nAux
		aDados[nValor][35] += nAux
		aDados[nValor][36] += nAux
	Endif
Endif

if aDetalhe[Len(aDetalhe)][71] == '5' .OR. aDetalhe[Len(aDetalhe)][71] == '6'

	aDados[nValor][35] -= if(aDetalhe[Len(aDetalhe)][82],0,aDetalhe[Len(aDetalhe)][85]) * if(Empty(aDetalhe[Len(aDetalhe)][76]),1,aDetalhe[Len(aDetalhe)][90])
	aDados[nValor][36] -= if(aDetalhe[Len(aDetalhe)][82],0,aDetalhe[Len(aDetalhe)][89]) * if(Empty(aDetalhe[Len(aDetalhe)][76]),1,aDetalhe[Len(aDetalhe)][90])
	
	// Horas Paradas
	aDados[nValor][56] += if(LCONSIND[3],aDetalhe[Len(aDetalhe)][86],aDetalhe[Len(aDetalhe)][87])
	
	// Paradas Alteram Eficiência
	aDados[nValor][57] += aDetalhe[Len(aDetalhe)][88]
		
	/*Parada Programada*/
	aDados[nValor][42] += if(LCONSIND[3],aDetalhe[Len(aDetalhe)][84],aDetalhe[Len(aDetalhe)][85])
		
	// Tempo Parada Preparação
	if (cAliasCYB)->CYB_LGSU == 'F' .AND. (cAliasCYX)->CYN_LGSU == 'T'
		aDados[nValor][41] += if(LCONSIND[3],aDetalhe[Len(aDetalhe)][86],aDetalhe[Len(aDetalhe)][87])
	Endif
Endif

/* Disponibilidade Planejada */
aDados[nValor][37] := Round(if(aDados[nValor][34]>0,aDados[nValor][35] / aDados[nValor][34] * 100,0),4)

/* Disponibilidade Real */
aDados[nValor][38] := Round(if(aDados[nValor][34]>0,aDados[nValor][36] / aDados[nValor][34] * 100,0),4)

/* Tempo Preparação Padrao */
aDados[nValor][25] += aDetalhe[Len(aDetalhe)][64]

/* Tempo Operação Padrão */
aDados[nValor][26] += aDetalhe[Len(aDetalhe)][65]

/* Tempo Preparação Real */
aDados[nValor][27] += aDetalhe[Len(aDetalhe)][66]

/* Tempo Operacao Real */
if aDetalhe[Len(aDetalhe)][71] != '5' .OR.;
   aDetalhe[Len(aDetalhe)][71] != '7'
	aDados[nValor][28] += aDetalhe[Len(aDetalhe)][30] + aDetalhe[Len(aDetalhe)][32]
Endif

/* Horas Normais */ 
aDados[nValor][29] += aDetalhe[Len(aDetalhe)][30] + aDetalhe[Len(aDetalhe)][66]

// Horas Extras
if aDetalhe[Len(aDetalhe)][71] != '5' .OR.;
   aDetalhe[Len(aDetalhe)][71] != '7'
	aDados[nValor][30] += aDetalhe[Len(aDetalhe)][32]
Endif

// Tempo Total Parada
aDados[nValor][21] += aDetalhe[Len(aDetalhe)][33]

// Quantidade Processada
aDados[nValor][58] += aDetalhe[Len(aDetalhe)][81]
 
/* Qualidade, Qualidade Real, Eficiencia */
if aDados[nValor][8] > 0
	aDados[nValor][31] := Round((aDados[nValor][8] - aDados[nValor][10]) / aDados[nValor][8] * 100,4)
	aDados[nValor][32] := Round((aDados[nValor][8] - aDados[nValor][10] - aDados[nValor][13]) / aDados[nValor][8] * 100,4)
		
	if LCONSIND[4] //Considera no Indicador: Considera Preparação nos Indicadores de Eficiência
		aDados[nValor][33] := (aDados[nValor][26] + aDados[nValor][25]) / (aDados[nValor][27] + aDados[nValor][28] + IF(LCONSIND[1],aDados[nValor][57],0)) // % Eficiência
	Else
		aDados[nValor][33] := aDados[nValor][26] / (aDados[nValor][28] + IF(LCONSIND[1],aDados[nValor][57],0)) // % Eficiência
	Endif
		
	aDados[nValor][33] := Round(aDados[nValor][33] * if(LCONSIND[2],aDados[nValor][31] / 100,1) * 100,4) // % Eficiência
Endif

/* Utilização */
if aDados[nValor][36] > 0
	if Empty(aDetalhe[Len(aDetalhe)][76])
		aDados[nValor][39] := Round((aDados[nValor][29] - aDados[nValor][27] + if(LCONSIND[3],aDados[nValor][30],0)) / ROUND(aDados[nValor][36],2) * 100,4)
	Else
		aDados[nValor][39] := Round(aDados[nValor][58] / aDados[nValor][36] * 100,4)
	Endif
Endif

/* NEE */
aDados[nValor][44] := Round(aDados[nValor][33] * aDados[nValor][32] / 100,4)

/* OEE */
aDados[nValor][45] := Round(aDados[nValor][33] * aDados[nValor][32] * aDados[nValor][38] / 10000,4)
		
/* TEEP */
aDados[nValor][46] := Round(aDados[nValor][33] * aDados[nValor][32] * aDados[nValor][39] * aDados[nValor][38] / 1000000,4)

/* Horas sem Apontamento */
aDados[nValor][40] := aDados[nValor][34] - (aDados[nValor][29] + aDados[nValor][30] + aDados[nValor][56]) + aDados[nValor][41]

/* DownTime */
aDados[nValor][43] := Round(IF(aDados[nValor][34]>0,(aDados[nValor][34] - aDados[nValor][36]) / aDados[nValor][34] * 100,0),4)

/* Takt Time */
aDados[nValor][47] := IF(aDados[nValor][8]==0,0,aDados[nValor][36] * 60 / aDados[nValor][8])

Return nil

//-------------------------------------------------------------------
//----------Retorna valor da dimensão para formar chave--------------
//-------------------------------------------------------------------
Static Function SFCXVIND(cTipo,cSubTipo,cDimensao,dReferencia)
Local cValor := ''

Do Case
	Case cDimensao == "01" // Estabelecimento
		cValor := (cAliasCYB)->CYA_CDES
	Case cDimensao == "02" // Área de Produção
		cValor := (cAliasCYB)->CYI_CDARPO
	Case cDimensao == "03" // Centro de Trabalho
		cValor := (cAliasCYB)->CYB_CDCETR
	Case cDimensao == "04" // Máquina
		cValor := (cAliasCYB)->CYB_CDMQ
	Case cDimensao == "07" // Equipe
		if cTipo == '2' .AND. cSubTipo == '2'
			cValor := (cAliasCYW)->CYW_CDGROE
		Elseif cTipo == '3' .AND. cSubTipo != '3'
			cValor := (cAliasCYX)->CYX_CDGROE
		Else
			cValor := PadR("",20)
		Endif
	Case cDimensao == "08" // Operador
		if cTipo == '2' .AND. cSubTipo == '2'
			cValor := (cAliasCYW)->CYW_CDOE
		Elseif cTipo == '3' .AND. cSubTipo != '3'
			cValor := (cAliasCYX)->CYX_CDOE
		Else
			cValor := PadR("",20)
		Endif
	Case cDimensao == "17" // Turno
		cValor := CYM->CYM_CDTN
	Case cDimensao == "18" // Período Mensal
		cValor := ALLTRIM(STR(YEAR(dReferencia))) + "/" + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0")
	Case cDimensao == "19" // Período Semanal
		cValor := ALLTRIM(STR(year(dReferencia))) + '/' + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0") + "/" + SFCXWeekMonth(dReferencia)
	Case cDimensao == "25" // Unidade Capacidade
		cValor := (cAliasCYB)->CYI_CDUNVM
	Case cDimensao == "26" // Período Diário
		cValor := ALLTRIM(STR(YEAR(dReferencia))) + ALLTRIM(STR(MONTH(dReferencia))) + ALLTRIM(STR(MONTH(dReferencia)))
End Case
	
Return cValor

//-------------------------------------------------------------------
//----------------------Outras Funcionalidades-----------------------
//-------------------------------------------------------------------

//-------------------------------------------------------------------
// Gera array para os detalhes
//-------------------------------------------------------------------
Static Function SFCXBuscaValor(cDimensao,dReferencia,cTabela)
Local cTipo   := substr(cDimensao,1,2)
Local nReg    := 0

vCodigo    := ""
vDescricao := ""

Do Case 
	Case cTipo == '01' // Estabelecimento - Não tem cadastro
		nReg := CZ3->(Recno())
	
		vCodigo    := (cAliasCYB)->CYA_CDES
		vDescricao := ALLTRIM((cAliasCYB)->CYA_CDES) + ' - ' + Posicione("CZ3",2,xFilial("CZ3")+(cAliasCYB)->CYA_CDES,'CZ3_DSES')
		
		CZ3->(dbGoTo(  nReg ))
	Case cTipo == '02' // Área de Produção
		vCodigo    := (cAliasCYB)->CYA_CDARPO
		vDescricao := ALLTRIM((cAliasCYB)->CYA_CDARPO) + ' - ' + (cAliasCYB)->CYA_DSARPO
	Case cTipo == '03' // Centro de Trabalho
		vCodigo    := (cAliasCYB)->CYI_CDCETR
		vDescricao := ALLTRIM((cAliasCYB)->CYI_CDCETR) + ' - ' + (cAliasCYB)->CYI_DSCETR
	Case cTipo == '04' // Máquina
		vCodigo    := (cAliasCYB)->CYB_CDMQ
		vDescricao := ALLTRIM((cAliasCYB)->CYB_CDMQ) + ' - ' + (cAliasCYB)->CYB_DSMQ
	Case cTipo == '05' // Linha de Produção - Não tem cadastro
		vCodigo    := (cAliasCYB)->CYQ_CDLIPO
		vDescricao := ALLTRIM((cAliasCYB)->CYQ_CDLIPO) + ' - ' + (cAliasCYB)->CYQ_DSLI
	Case cTipo == '06' // Planejador - Não tem cadastro
		vCodigo    := (cAliasCYB)->CYQ_CDUSPL
		vDescricao := ALLTRIM((cAliasCYB)->CYQ_CDUSPL) 
	Case cTipo == '07' // Equipe Produção
		IF cFunction == '2' // Parada
			vCodigo    := (cAliasCYX)->CYX_CDGROE
			vDescricao := ALLTRIM((cAliasCYX)->CYX_CDGROE) + ' - ' + Posicione("CYH",1,xFilial("CYH")+'3'+(cAliasCYX)->CYX_CDGROE,'CYH_NMRC')
		Else		
			if cTabela == 'CYW'
				vCodigo    := (cAliasCYW)->CYW_CDGROE
				vDescricao := ALLTRIM((cAliasCYW)->CYW_CDGROE) + ' - ' + Posicione("CYH",2,xFilial("CYH")+(cAliasCYW)->CYW_IDGROE,'CYH_NMRC')
			ElseIF cTabela == 'CYX'
				vCodigo    := (cAliasCYX)->CYX_CDGROE
				vDescricao := ALLTRIM((cAliasCYX)->CYX_CDGROE) + ' - ' + Posicione("CYH",1,xFilial("CYH")+'3'+(cAliasCYX)->CYX_CDGROE,'CYH_NMRC')
			Endif
		Endif
	Case cTipo == '08' // Operador
		if cFunction == '2' // Parada
			vCodigo    := (cAliasCYX)->CYX_CDOE
			vDescricao := ALLTRIM((cAliasCYX)->CYX_CDOE) + ' - ' + Posicione("CYH",1,xFilial("CYH")+'1'+(cAliasCYX)->CYX_CDOE,'CYH_NMRC')
		Else		
			if cTabela == 'CYW'
				vCodigo    := (cAliasCYW)->CYW_CDOE
				vDescricao := ALLTRIM((cAliasCYW)->CYW_CDOE) + ' - ' + Posicione("CYH",2,xFilial("CYH")+(cAliasCYW)->CYW_IDOE,'CYH_NMRC')
			ElseIF cTabela == 'CYX'
				vCodigo    := (cAliasCYX)->CYX_CDOE
				vDescricao := ALLTRIM((cAliasCYX)->CYX_CDOE) + ' - ' + Posicione("CYH",1,xFilial("CYH")+'1'+(cAliasCYX)->CYX_CDOE,'CYH_NMRC')
			Endif
		Endif
	Case cTipo == '09' // Item
		vCodigo    := (cAliasCYB)->CZ3_CDAC
		vDescricao := ALLTRIM((cAliasCYB)->CZ3_CDAC) + ' - ' + (cAliasCYB)->CZ3_DSAC
	Case cTipo == '10' // Referência - Não tem cadastro
		vCodigo    := (cAliasCYB)->CYQ_CDRE
		vDescricao := ALLTRIM((cAliasCYB)->CYQ_CDRE) + ' - ' + (cAliasCYB)->CYQ_CDRE
	Case cTipo == '11'  // Operação
		vCodigo    := CY9->CY9_DSAT
		vDescricao := CY9->CY9_DSAT
	Case cTipo == '12' // Família
		vCodigo    := (cAliasCYB)->CZ3_CDFA
		vDescricao := ALLTRIM((cAliasCYB)->CZ3_CDFA) + ' - ' + Posicione("CY6",1,xFilial("CY6")+(cAliasCYB)->CZ3_CDFA,'CY6_DSFA')		
	Case cTipo == '13' // Grupo de Estoque
		vCodigo    := (cAliasCYB)->CZ3_CDGR
		vDescricao := ALLTRIM((cAliasCYB)->CZ3_CDGR) + ' - ' + Posicione("CY7",1,xFilial("CY7")+(cAliasCYB)->CZ3_CDGR,'CY7_DSGE')		
	Case cTipo == '14' // Cliente - Não tem cadastro
		vCodigo    := (cAliasCYB)->CYQ_NMSIFB
		vDescricao := ALLTRIM((cAliasCYB)->CYQ_NMSIFB) + ' - ' + (cAliasCYB)->CYQ_NMSIFB
	Case cTipo == '15' // Pedido - Não tem cadastro
		IF !Empty(CYQ->CYQ_NMSIFB) 
			vCodigo    := ALLTRIM((cAliasCYB)->CYQ_CDPD) + ' - ' + (cAliasCYB)->CYQ_NMSIFB
			vDescricao := ALLTRIM((cAliasCYB)->CYQ_NMSIFB) + ' - ' + (cAliasCYB)->CYQ_CDPD
		Endif
	Case cTipo == '16' // Ferramenta
		IF cFunction == '2' // Parada
			vCodigo    := (cAliasCYX)->CYX_CDFEPO
			vDescricao := ALLTRIM((cAliasCYX)->CYX_CDFEPO) + ' - ' + Posicione("CYH",1,xFilial("CYH")+'2'+(cAliasCYX)->CYX_CDFEPO,'CYH_NMRC')
		Else
			if cTabela == 'CZ0'
				vCodigo    := (cAliasCZ0)->CZ0_CDFE
				vDescricao := ALLTRIM((cAliasCZ0)->CZ0_CDFE) + ' - ' + Posicione("CYH",2,xFilial("CYH")+(cAliasCZ0)->CZ0_IDFE,'CYH_NMRC')
			Endif
		Endif		
	Case cTipo == '17' // Turno
		vCodigo    := CYM->CYM_CDTN
		vDescricao := ALLTRIM(CYM->CYM_CDTN) + ' - ' + CYM->CYM_DSTN
	Case cTipo == '18' // Período Mensal
		vCodigo    := ALLTRIM(STR(YEAR(dReferencia))) + "/" + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0")
		vDescricao := ALLTRIM(STR(YEAR(dReferencia))) + "/" + SFCXMeses(MONTH(dReferencia))
	Case cTipo == '19' // Período Semanal
		vCodigo    := ALLTRIM(STR(year(dReferencia))) + '/' + PadL(ALLTRIM(STR(MONTH(dReferencia))),2,"0") + "/" + SFCXWeekMonth(dReferencia)
		vDescricao := ALLTRIM(STR(year(dReferencia))) + '/' + SFCXMeses(MONTH(dReferencia)) + "/" + SFCXWeekMonth(dReferencia)
	Case cTipo == '20' // Motivo Parada
		vCodigo    := (cAliasCYX)->CYN_CDSP
		vDescricao := ALLTRIM((cAliasCYX)->CYN_CDSP) + ' - ' + (cAliasCYX)->CYN_DSSP
	Case cTipo == '21' // Motivo Refugo
		if CTabela == 'CY0'
			vCodigo    := (cAliasCY0)->CY0_CDRF
			vDescricao := ALLTRIM((cAliasCY0)->CY0_CDRF) + ' - ' + Posicione("CYO",,xFilial("CYO")+(cAliasCY0)->CY0_CDRF,'CYO_DSRF')
		Endif
	Case cTipo == '22' // Depósito
		vCodigo    := (cAliasCYB)->CYQ_CDDP
		vDescricao := ALLTRIM((cAliasCYB)->CYQ_CDDP) + ' - ' + Posicione("CZX",,xFilial("CZX")+(cAliasCYB)->CYQ_CDDP,'CZX_DSDP')		
	Case cTipo == '24' // Tipo de Ordem
		vCodigo    := (cAliasCYB)->CYQ_TPORPO
		vDescricao := ALLTRIM((cAliasCYB)->CYQ_TPORPO) + ' - '+ x3combo('CYQ_TPORPO',(cAliasCYB)->CYQ_TPORPO)
	Case cTipo == '25' // Unidade Capacidade
		vCodigo    := (cAliasCYB)->CYI_CDUNVM
		vDescricao := ALLTRIM((cAliasCYB)->CYI_CDUNVM)
	Case cTipo == '26' // Período Diário
		vCodigo    := ALLTRIM(STR(YEAR(dReferencia))) + ALLTRIM(STR(MONTH(dReferencia))) + ALLTRIM(STR(MONTH(dReferencia)))
		vDescricao := DTOC(dReferencia)		
End Case

Return nil

//-------------------------------------------------------------------
// Gera array para métricas
//-------------------------------------------------------------------
Static Function SFCXSequencia(nNivel,cRegistro)
Local cValor   := if(Empty(cCodPai),vCodigo,cCodPai + '.' + vCodigo)
Local bSeek    := {|x| x[3] == cValor}
Local nI	   := 0

Private aLinha := Array(70) // Array para salvar os valores de metas

if !Empty(vCodigo)

	nResult := ASCAN(aDados,bSeek)

	if nResult == 0 
		aLinha[1]  := nNivel
		aLinha[2]  := .F.
		aLinha[3]  := cValor
		aLinha[4]  := substr(cRegistro,3)
		aLinha[5]  := vCodigo
		aLinha[6]  := vDescricao
		aLinha[7]  := VAL(substr(cRegistro,1,2))
		
		AADD(aDados,aLinha)
		
		nResult := Len(aDados)
		
		For nI := 8 to 70
			aDados[nResult][nI] := 0
		Next
	Endif
	
	cCodPai := cValor
    
	IF cFunction == '1' // Refugo/Retrabalho
		SFCXSeqReR(nResult,substr(cRegistro,1,2))
	Elseif cFunction == '2' // Parada
		SFCXSeqPar(nResult)
	Elseif cFunction == '3' // Reportes
		SFCXSeqPro(nResult)
	Else // Indicadores
		SFCXSeqInd(nResult)
	Endif
	
Endif

Return aDados

//-------------------------------------------------------------------
// Verifica em qual semana se encontra a data passada como parâmetro
//-------------------------------------------------------------------
Static Function SFCXWeekMonth(dRefer)
Local nAux    := 0
Local cSemana := ''
	
nAux := (DOW(dRefer - (DAY(dRefer) - 1)) + DAY(dRefer)) / 7

IF nAux <= 1
	cSemana := STR0002 //'Semana 1'
ElseIf nAux <= 2
	cSemana := STR0003 //'Semana 2'
ElseIf nAux <= 3
	cSemana := STR0004 //'Semana 3'
ElseIf nAux <= 4
	cSemana := STR0005 //'Semana 4'
ElseIf nAux <= 5
	cSemana := STR0006 //'Semana 5'
Else	
	cSemana := STR0007 //'Semana 6'
Endif

Return cSemana

//-------------------------------------------------------------------
// Retorna mês
//-------------------------------------------------------------------
Static Function SFCXMeses(nMes)
Local cMes := ''

Do Case
	Case nMes == 1
		cMes := STR0009
	Case nMes == 2
		cMes := STR0010
	Case nMes == 3
		cMes := STR0011
	Case nMes == 4
		cMes := STR0012
	Case nMes == 5
		cMes := STR0013
	Case nMes == 6
		cMes := STR0014
	Case nMes == 7
		cMes := STR0015
	Case nMes == 8     
		cMes := STR0016
	Case nMes == 9
		cMes := STR0017
	Case nMes == 10
		cMes := STR0018
	Case nMes == 11
		cMes := STR0019
	Case nMes == 12
		cMes := STR0020
End Case

Return ALLTRIM(cMes)

//-------------------------------------------------------------------
// Realiza a busca e a filtragem dos paradas programas efetivadas e as não programadas
//-------------------------------------------------------------------
Static Function SFCXParCYX()
Local aArea         := GetArea()
Local aAreaCYX      := CYX->(GetArea())
Local aAreaCYN      := CYN->(GetArea())
Local aAreaCZ2      := CZ2->(GetArea())
Local aAreaCYM      := CYM->(GetArea())
Local nI		    := 0
Local dReferencia   := date()
Local cValCYXIni	:= ''
Local cValCYXFim	:= ''
Private cTipoParada := '1' // 1-Não Programada 2-Programada e Realizada 3-Programada e Não realizada 
Private nPlanReal   := 0
Private cAliasCYX   := GetNextAlias()

BeginSql Alias cAliasCYX
   	
	SELECT * FROM %Table:CYX% CYX
		INNER JOIN %Table:CYN% CYN ON CYN.CYN_FILIAL = %xFilial:CYN% AND
									  CYN.CYN_CDSP   = CYX.CYX_CDSP
		WHERE CYX.CYX_FILIAL=%xFilial:CYX% AND 
			  CYX.CYX_CDMQ=%Exp:(cAliasCYB)->CYB_CDMQ% AND
		   	  CYX.CYX_CDSP>=%Exp:CDSPINI% AND
			  CYX.CYX_CDSP<=%Exp:CDSPFIM% AND
			  CYX.CYX_NRTN>=%Exp:NRTNINI% AND
			  CYX.CYX_NRTN<=%Exp:NRTNFIM% AND
		      CYX.CYX_CDGROE>=%Exp:CDGRPOINI% AND
		      CYX.CYX_CDGROE<=%Exp:CDGRPOFIM% AND
		      CYX.CYX_CDOE>=%Exp:CDOEINI% AND
		      CYX.CYX_CDOE<=%Exp:CDOEFIM% AND
		     (CYN.CYN_LGEF=%Exp:LTPMOTPAR[1]% OR
		      CYN.CYN_LGSU=%Exp:LTPMOTPAR[4]% OR
		      CYN.CYN_LGSS=%Exp:LTPMOTPAR[2]% OR
		      CYN.CYN_LGELEQ=%Exp:LTPMOTPAR[3]%) AND
			  CYX.%NotDel%
EndSql

While (cAliasCYX)->(!EOF())

	cValCYXIni := (cAliasCYX)->CYX_DTBGSP + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCYX)->CYX_HRBGSP)))
	cValCYXFim := (cAliasCYX)->CYX_DTEDSP + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCYX)->CYX_HREDSP)))
   
	// filtra pelas datas de apontamento e pelo motivo de parada
	IF LTPPAR[val((cAliasCYX)->CYX_TPSP)] .AND. ; // Parada Programada/Não Programada
	   cValCYXFim >= cValRefIni .AND. cValCYXIni < cValRefFim
		   
		dbSelectArea("CYM") 
		CYM->(dbSetOrder(1))
		CYM->(dbSeek(xFilial("CYM")+(cAliasCYX)->CYX_CDTN))
	      
		if (cAliasCYX)->CYX_TPSP == '2'
	       	cTipoParada := '2'
        	
		    dbSelectArea('CZ2')
			CZ2->(dbSetOrder(1))
			CZ2->(dbSeek(xFilial('CZ2')+(cAliasCYX)->CYX_CDMQ+(cAliasCYX)->CYX_NRSQSP))
		Else
			cTipoParada := '1'
		Endif
        
	    dReferencia := IF((cAliasCYX)->CYX_TPSP=='1',STOD((cAliasCYX)->CYX_DTBGSP),CZ2->CZ2_DTBGPL)
		cCodPai     := ""					
	    
	    if cFunction == '2'    
			SFCXDParada(cTipoParada,dReferencia)
		Else
			SFCXDIndicadores('3',dReferencia,cTipoParada)
		Endif
		
		For nI := 1 to Len(aFieldsSel)
			SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CYX')
			SFCXSequencia(nI,aFieldsSel[nI][1])
		Next
	Endif
	(cAliasCYX)->(dbSkip())
End

(cAliasCYX)->(dbCloseArea())

RestArea(aAreaCZ2)
RestArea(aAreaCYM)
RestArea(aAreaCYX)
RestArea(aAreaCYN)
RestArea(aArea)

Return nil

//-------------------------------------------------------------------
// Realiza a busca e a filtragem dos paradas não efetivadas
//-------------------------------------------------------------------
Static Function SFCXParCZ2()
Local aArea         := GetArea()
Local aAreaCYX      := CYX->(GetArea())
Local aAreaCYN      := CYN->(GetArea())
Local aAreaCYM      := CYM->(GetArea())
Local aAreaCZ2      := CZ2->(GetArea())
Local nI		    := 0
Local dReferencia   := date()
Local cValCZ2Ini	:= ''
Local cValCZ2Fim	:= ''
Private cTipoParada := '3' // 1-Não Programada 2-Programada e Realizada 3-Programada e Não realizada 
Private nPlanReal   := 0
Private cAliasCZ2   := GetNextAlias()

BeginSql Alias cAliasCZ2
   	
	SELECT * FROM %Table:CZ2% CZ2
		INNER JOIN %Table:CYN% CYN ON CYN.CYN_FILIAL = %xFilial:CYN% AND
									  CYN.CYN_CDSP = CZ2.CZ2_CDSP
		WHERE CZ2.CZ2_FILIAL=%xFilial:CZ2% AND 
			  CZ2.CZ2_CDMQ=%Exp:(cAliasCYB)->CYB_CDMQ% AND
		   	  CZ2.CZ2_CDSP>=%Exp:CDSPINI% AND
			  CZ2.CZ2_CDSP<=%Exp:CDSPFIM% AND
			  CZ2.CZ2_NRTN>=%Exp:NRTNINI% AND
			  CZ2.CZ2_NRTN<=%Exp:NRTNFIM% AND
		     (CYN.CYN_LGSU=%Exp:LTPMOTPAR[4]% OR
		      CYN.CYN_LGSS=%Exp:LTPMOTPAR[2]% OR
		      CYN.CYN_LGELEQ=%Exp:LTPMOTPAR[3]%) AND
			  CZ2.%NotDel%
EndSql

While (cAliasCZ2)->(!EOF())

	cValCZ2Ini := (cAliasCZ2)->CZ2_DTBGPL + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCZ2)->CZ2_HRBGPL)))
	cValCZ2Fim := (cAliasCZ2)->CZ2_DTEDPL + '.' + ALLTRIM(STR(SFCXHourToSeg((cAliasCZ2)->CZ2_HREDPL)))
	
	// filtra pelas datas de parada programa e pelo motivo de parada
	if cValCZ2Ini < cValRefIni .AND. cValCZ2Fim >= cValRefFim
				 
		// utilizará somente as paradas programas não efetivadas, pois as efetivadas já foram buscadas
		dbSelectArea("CYX")
		CYX->(dbSetOrder(5))
		CYX->(dbGoTop())
		IF !CYX->(dbSeek(xFilial('CYX')+(cAliasCYB)->CYB_CDMQ+(cAliasCZ2)->CZ2_NRSQSP))
			
			dbSelectArea("CYM") 
			CYM->(dbSetOrder(1))
			CYM->(dbSeek(xFilial("CYM")+(cAliasCZ2)->CZ2_CDTN))
		
			dReferencia := STOD((cAliasCZ2)->CZ2_DTBGPL)
			cCodPai     := ""
		     
		    if cFunction == '2'
		    	SFCXDParada('3',dReferencia)
		    Else
		    	SFCXDIndicadores('3',dReferencia,'3')
		    Endif
				
			For nI := 1 to Len(aFieldsSel)
				SFCXBuscaValor(aFieldsSel[nI][1],dReferencia,'CYX')
				SFCXSequencia(nI,aFieldsSel[nI][1])
			Next
        Endif
    Endif
	
	(cAliasCZ2)->(dbSkip())
End

(cAliasCZ2)->(dbCloseArea())

RestArea(aAreaCZ2)
RestArea(aAreaCYX)
RestArea(aAreaCYM)
RestArea(aAreaCYN)
RestArea(aArea)
				
Return nil

//-------------------------------------------------------------------
// Calcula data e hora de início e fim de acordo com faixa de data informadas
//-------------------------------------------------------------------
Static Function SFCXRetCalen()
Local cCDCL    := ''
Local cCDTN    := ''
Local dInicio  := DTRPINI
Local cInicio  := '23:59:59'
Local dFim     := DTRPFIM
Local cFim     := '23:59:59'
Local dAux     := DTRPFIM + 1
Local aArea    := GetArea()
Local aAreaCYZ := CYZ->(GetArea())
Local aAreaCYR := CYR->(GetArea())
                                        
cCDCL := SFCCalendario((cAliasCYB)->CYB_CDMQ)

// Verifica data/hora de início
cCDTN := SFCTurnoMaq((cAliasCYB)->CYB_CDMQ, DTRPINI)

dbSelectArea("CYZ")
CYZ->(dbSetOrder(1))
CYZ->(dbGoTop())
if CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(DTRPINI)))
	if CYZ->CYZ_TPDY == '1'
		dbSelectArea("CYR")
		CYR->(dbSetOrder(2))
		CYR->(dbGoTop())
		if CYR->(dbSeek(xFilial('CYR')+cCDTN+ALLTRIM(STR(DOW(DTRPINI)))))
	
			While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == ALLTRIM(STR(DOW(DTRPINI)))
				if cInicio > CYR->CYR_HRBG
					cInicio := CYR->CYR_HRBG
				Endif 
				CYR->(dbSkip())
			End
		Else
			cInicio := '00:00:00'
		Endif
	Else
		cInicio := '00:00:00'
	Endif
Else
	cInicio := '00:00:00'
Endif

// Verifica data/hora fim
cCDTN := SFCTurnoMaq((cAliasCYB)->CYB_CDMQ, dAux)

dbSelectArea("CYZ")
CYZ->(dbSetOrder(1))
CYZ->(dbGoTop())

While .T.
	if CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dAux)))
		if CYZ->CYZ_TPDY == '1'
			dbSelectArea("CYR")
			CYR->(dbSetOrder(2))
			CYR->(dbGoTop())
			if CYR->(dbSeek(xFilial('CYR')+cCDTN+ALLTRIM(STR(DOW(dAux)))))
		
				While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == ALLTRIM(STR(DOW(dAux)))
					if cFim > CYR->CYR_HRBG
						cFim := CYR->CYR_HRBG
					Endif 
					CYR->(dbSkip())
				End
				
				cFim := SFCXSegToHour(SFCXHourToSeg(CYR->CYR_HRBG) - 1)
				
				Exit
			Else
				cFim := '23:59:59'
				Exit
			Endif
		Endif
	Else
		cFim := '23:59:59'
		Exit
	Endif

	dAux++
End

dFim := dAux

RestArea(aAreaCYR)
RestArea(aAreaCYZ)
RestArea(aArea)

Return {dInicio,cInicio,dFim,cFim,cCDCL}

//-------------------------------------------------------------------
// Calcular o percentual de variação, de acordo com os valores passados como parâmetro
//-------------------------------------------------------------------
Static Function SFCXPercVar(nPrevisto,nReal,nResult)

if nPrevisto > 0
	nResult := ((nReal / nPrevisto) - 1) * 100
Else
	nResult := if(nReal != 0, 100, 0)
Endif

Return nResult
