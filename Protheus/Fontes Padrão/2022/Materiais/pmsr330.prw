#INCLUDE "Protheus.ch"
#INCLUDE "pmsr330.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

//
#DEFINE DTINICIAL	     1
#DEFINE DTFINAL       2
#DEFINE PERIODO       3
#DEFINE PEDCOMPRA     4
#DEFINE DESPESAS      5
#DEFINE PEDVENDA      6
#DEFINE RECEITAS      7
#DEFINE SALDODIA      8
#DEFINE VARIACAODIA   9
#DEFINE SAIDASACUM    10 
#DEFINE ENTRADASACUM  11 
#DEFINE VARIACAOACUM  12 
#DEFINE SALDOACUM     13

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSR330   ºAutor  ³Paulo Carnelossi    º Data ³  29/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Conversao para Release 4                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSR330(aArrayFlx,aTotais, nPeriodo)
	Local oReport

	If PMSBLKINT()
		Return Nil
	EndIf

	oReport := ReportDef(aArrayFlx,aTotais, nPeriodo)

	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf	

	oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Paulo Carnelossi       ³ Data ³29/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(aArrayFlx,aTotais, nPeriodo)
Local cDesc1	:= STR0001 //"Este relatorio ira imprimir uma relacao de despesas da consulta gerencial solicitada considerando todas despesas (pedido de compra,autorizacao de entrega,nota fiscal de entrada,titulos a pagar e movimentos bancarios) vinculadas aos projetos."
Local cDesc2	:= "" 
Local cDesc3	:= ""
Local cPerg		:= "PMR330"  // Pergunta do Relatorio

Local aOrdem := {}
Local oReport
Local oPlanoGer

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport := TReport():New("PMSR330",STR0002, cPerg, ;   //"Consultas Gerenciais - Relecao de Despesas"
			{|oReport| ReportPrint(oReport, aArrayFlx, aTotais, MV_PAR03, MV_PAR02) },;
			cDesc1 )


If aArrayFlx != Nil
	oReport:ParamReadOnly()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//adiciona ordens do relatorio

oPlanoGer := TRSection():New(oReport,STR0018,{"AJ8"}, aOrdem /*{}*/, .F., .F.) //"Plano Gerencial"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oPlanoGer,	"AJ8_CODPLA"	,"AJ8",STR0012/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/) //"Codigo do Plano"
oPlanoGer:SetLineStyle()

oDetalhe := TRSection():New(oReport,STR0016,, aOrdem /*{}*/, .F., .F.) //"Despesas"

TRCell():New(oDetalhe,	"PERIODO"	,/*Alias*/,STR0010/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)
TRCell():New(oDetalhe,	"PEDCOMPRA"	,/*Alias*/,STR0015/*Titulo*/,"@E 99,999,999.99"/*Picture*/,17/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AFE_PROJET }*/)
TRCell():New(oDetalhe,	"DESPESAS"	,/*Alias*/,STR0016/*Titulo*/,"@E 99,999,999.99"/*Picture*/,17/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AF8_DESCRI }*/)
TRCell():New(oDetalhe,	"SAIDASACUM",/*Alias*/,STR0017/*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,17/*Tamanho*/,/*lPixel*/,/*{|| (cAliasAF8)->AF8_DESCRI }*/)
oDetalhe:SetHeaderPage()

Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintºAutor  ³Paulo Carnelossi   º Data ³  29/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Conversao para Release 4                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport, aArrayFlx, aTotais, nPeriodo, nDiasTot)

Local aArea		:= GetArea()
Local aHandle
Local aFluxo
Local nTotRec	:= 0
Local nTotDesp	:= 0
Local nSaldo	:= 0
Local nSaldoAcm	:= 0
Local nSaldoDia	:= 0
Local dDataInic		:= dDataBase
Local dDataTrab     := dDataInic
Local nReceitaIni   := 0
Local nDespesaIni   := 0
Local nDias         := 0
Local nQtdePer      := 0
Local aDias         := {1,7,10,15,30}
Local dData
Local nSaidasDia    := 0
Local nSaidasAcum   := 0
Local nEntradasAcum := 0
Local nEntradasDia  := 0
Local nRestPer      := 0
Local nQtdDias      := 0
Local nI			:= 0
Local nX			:= 0

nDias   := aDias[nPeriodo]

oReport:SetMeter(nDias*nDiasTot)

If aArrayFlx == Nil

	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf	

	aArrayFlx	:= {}
	dbSelectArea("AJ8")
	dbSetOrder(1)
	If dbSeek(xFilial("AJ8") + mv_par01)
		aHandle := PmsIniGFin(mv_par01,.T.)
		aFluxo	:= PmsRetGFin(aHandle,2,"!$TOTALGERAL$!") 
		If (nPeriodo <> 5)
			If nDiasTot < nDias
				nQtdePer := 0
				nRestPer := nDiasTot
				nDias    := nDiasTot
			Else
				nQtdePer := Int(nDiasTot / nDias)
				nRestPer := nDiasTot - (nQtdePer * nDias)
			Endif
		
			// Gera os registros para todas as datas do periodo, inclusive a database
			dDataTrab := dDataInic
			For nX := 1 To nQtdePer
				oReport:IncMeter()
				If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
					Aadd(aArrayFlx, {dDataTrab,(dDataTrab + nDias - 1),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0,0,0})
				Endif
		
				dDataTrab += nDias
			Next
			
			// calcula o restante do periodo, se houver
			If nRestPer > 0
				If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
					Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nRestPer),PMC100DescPer(dDataTrab, nRestPer),0,0,0,0,0,0,0,0,0,0})
				Endif
			EndIf
		
		Else
			nQtdDias := 0  
			dDataTrab:= dDataInic
			nMes     := Month(dDataTrab)		
			For dData:= dDataInic To dDataInic+nDiasTot
				oReport:IncMeter()
				If (nMes <> Month(dData))
					nQtdePer++
					nMes     := Month(dData)		
		      
					If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
						Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nQtdDias-1),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0,0,0})
		        dDataTrab+= nQtdDias
						nQtdDias:= 0
					EndIf
				EndIf
		
				nQtdDias++
			Next dData
			
			If (nQtdDias > 0)
					If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
						Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nQtdDias),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0,0,0})
					EndIf
			EndIf
		EndIf
		dDataTrab := dDataInic
				
		// calcula o valor inicial
		// dos pedidos de compra
		For nI := 1 To Len(aFluxo[1])
			oReport:IncMeter()
			If aFluxo[1,nI,1] < dDataTrab
				nDespesaIni += aFluxo[1, nI, 2]		
			EndIf
		Next
		
		// calcula a despesa inicial
		For nI := 1 To Len(aFluxo[2])
			
			oReport:IncMeter()
			// calcula a despesa ate o
			// o primeiro dia do periodo (exclusive)
			If aFluxo[2,nI,1] < dDataTrab
				nDespesaIni += aFluxo[2, nI, 2]		
			EndIf
		
		Next
		
		// calcula o valor inicial
		// dos pedidos de venda
		For nI := 1 To Len(aFluxo[4])
			oReport:IncMeter()
			If aFluxo[4,nI,1] < dDataTrab
				nReceitaIni += aFluxo[4, nI, 2]		
			EndIf
		Next
		                             
		// calcula a receita inicial
		For nI := 1 To Len(aFluxo[5])
			oReport:IncMeter()
			// calcula a receita ate o
			// o primeiro dia do periodo (exclusive)
			If aFluxo[5,nI,1] < dDataTrab
				nReceitaIni += aFluxo[5, nI, 2]		
			EndIf
		Next
		
		// calcula o saldo inicial
		nSaldo := aFluxo[6]-aFluxo[3]
		nSaldoAcm := nSaldo
		
		For nX := 1 To Len(aArrayFlx)
			oReport:IncMeter()
			nSaldoDia := 0

			// processa os pedidos de compra		
			For nI:= 1 To Len(aFluxo[1])
		    If (aFluxo[1,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[1,nI,1] <= aArrayFlx[nX,DTFINAL])
					aArrayFlx[nX,PEDCOMPRA] += aFluxo[1,nI,2]
					nTotDesp += aFluxo[1,nI,2]
					nSaldoAcm-= aFluxo[1,nI,2]
					nSaldoDia-= aFluxo[1,nI,2]
				EndIf                      
			Next nI

			// processa as despesas			
			For nI:= 1 To Len(aFluxo[2])
		    If (aFluxo[2,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[2,nI,1] <= aArrayFlx[nX,DTFINAL])
					aArrayFlx[nX,DESPESAS] += aFluxo[2,nI,2]
					nTotDesp += aFluxo[2,nI,2]
					nSaldoAcm-= aFluxo[2,nI,2]
					nSaldoDia-= aFluxo[2,nI,2]
				EndIf                      
			Next nI

			// processa os pedidos de venda			
			For nI:= 1 To Len(aFluxo[4])
		    If (aFluxo[4,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[4,nI,1] <= aArrayFlx[nX,DTFINAL])
					aArrayFlx[nX,PEDVENDA] += aFluxo[4,nI,2]
					nTotRec  += aFluxo[4,nI,2]
					nSaldoAcm+= aFluxo[4,nI,2]
					nSaldoDia+= aFluxo[4,nI,2]
				EndIf                      
			Next nI

			// processas as receitas		
			For nI:= 1 To Len(aFluxo[5])
		    If (aFluxo[5,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[5,nI,1] <= aArrayFlx[nX,DTFINAL])
					aArrayFlx[nX,RECEITAS] += aFluxo[5,nI,2]
					nTotRec  += aFluxo[5,nI,2]
					nSaldoAcm+= aFluxo[5,nI,2]
					nSaldoDia+= aFluxo[5,nI,2]
				EndIf                      
			Next nI
		
			nSaidasDia    := aArrayFlx[nX,PEDCOMPRA] +  aArrayFlx[nX,DESPESAS]
			nEntradasDia  := aArrayFlx[nX,PEDVENDA] +  aArrayFlx[nX,RECEITAS]
		  nSaidasAcum   += nSaidasDia
		  nEntradasAcum += nEntradasDia
		
			aArrayFlx[nX,SALDODIA]     := nSaldoDia
			aArrayFlx[nX,VARIACAODIA]  := (nSaidasDia/nEntradasDia) * 100
			aArrayFlx[nX,SAIDASACUM]   := nSaidasAcum
			aArrayFlx[nX,ENTRADASACUM] := nEntradasAcum
			aArrayFlx[nX,VARIACAOACUM] := (nSaidasAcum/nEntradasAcum) * 100
			aArrayFlx[nX,SALDOACUM]    := nSaldoAcm
		Next nX
        
		Pmr330_Imp(oReport, aArrayFlx, { nTotDesp, nTotRec, nSaldo, nSaldoAcm}, nPeriodo)

	EndIf
Else
	Pmr330_Imp(oReport, aArrayFlx, aTotais, nPeriodo)
EndIf



RestArea(aArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PMR330_Imp³ Autor ³ Edson Maricate               ³ Data ³18.04.2003³±±
±±³          ³          ³       ³ Paulo Carnelossi (R4)        ³      ³29/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Faz a Impressao do relatorio                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMR330_Imp(oReport, aArrayFlx, aTotais, nPeriodo)
Local aPeriodos := {	STR0005,; //"Diario"
						STR0006,; //"Semanal"
						STR0007,; //"Decendial"
						STR0008,; //"Quinzenal"
						STR0009} //"Mensal"
Local nX		:= 0
Local oPlanoGer := oReport:Section(1)
Local oDetalhe 	:= oReport:Section(2)

oDetalhe:Cell("PERIODO")	:SetBlock( {|| aArrayFlx[nx][PERIODO] })
oDetalhe:Cell("PEDCOMPRA")	:SetBlock( {|| aArrayFlx[nx][PEDCOMPRA] })
oDetalhe:Cell("DESPESAS")	:SetBlock( {|| aArrayFlx[nx][DESPESAS] })
oDetalhe:Cell("SAIDASACUM")	:SetBlock( {|| aArrayFlx[nx][SAIDASACUM] })
oDetalhe:Cell("PERIODO")	:SetTitle(oDetalhe:Cell("PERIODO"):Title()+CRLF+PadR(aPeriodos[nPeriodo], 11))

oPlanoGer:Init()
oPlanoGer:PrintLine()
oPlanoGer:Finish()

oReport:PrintText(STR0013, oReport:Row(), 10)  //"Saldo Inicial : "
oReport:PrintText(Transform(aTotais[3], "@E 99,999,999,999.99"), oReport:Row(), 250)

oReport:SkipLine()
oReport:PrintText(STR0014, oReport:Row(), 10)   //"Total a Pagar : "
oReport:PrintText(Transform(aTotais[1], "@E 99,999,999,999.99"), oReport:Row(), 250)

oReport:SkipLine()

oDetalhe:Init()

For nx := 1 to Len(aArrayFlx)

	oReport:IncMeter()
	oDetalhe:PrintLine()
	
Next

oDetalhe:Finish()

Return