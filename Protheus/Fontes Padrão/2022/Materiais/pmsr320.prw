#INCLUDE "Protheus.ch"
#INCLUDE "pmsr320.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

#DEFINE DTINICIAL			1
#DEFINE DTFINAL				2
#DEFINE PERIODO 			3
#DEFINE PEDCOMPRA			4
#DEFINE DESPESAS			5
#DEFINE PEDVENDA			6
#DEFINE RECEITAS  			7
#DEFINE SALDODIA			8
#DEFINE VARIACAODIA   		9
#DEFINE SAIDASACUM  		10 
#DEFINE ENTRADASACUM  		11 
#DEFINE VARIACAOACUM   		12 
#DEFINE SALDOACUM     		13 

//-------------------------------RELEASE 4---------------------------------------//
Function PMSR320(aArrayFlx,aTotais, nPeriodo)
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

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Paulo Carnelossi    � Data �  18/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Release 4                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportDef(aArrayFlx,aTotais, nPeriodo)
Local cPerg		:= "PMR320"
Local cDesc1   := STR0001 //"Este relatorio ira imprimir a relacao de receitas da consulta gerencial solicitada considerando todas receitas (pedido de venda,titulos a receber e movimentacao bancaria) vinculadas aos projetos."
Local cDesc2   := "" 
Local cDesc3   := ""

Local oReport
Local oConsGerProj
Local oFluxo
Local nX

Local aOrdem  := {}

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������

oReport := TReport():New("PMSR320",STR0002, cPerg, ;
			{|oReport| ReportPrint(oReport, aArrayFlx, aTotais, MV_PAR03, MV_PAR02)},;
			cDesc1 )
//STR0002 //"Consultas Gerenciais - Relecao de Receitas"

If aArrayFlx!=Nil
	oReport:ParamReadOnly()
EndIf

oConsGerProj := TRSection():New(oReport, STR0018, { "AJ8" }, aOrdem /*{}*/, .F., .F.) //"Codigo do Plano"
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oConsGerProj,	"AJ8_CODPLA"	,"AJ8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
oConsGerProj:SetLineStyle()

//-------------------------------------------------------------
oFluxo := TRSection():New(oReport, STR0019, , /*{aOrdem}*/, .F., .F.) //"Consultas Gerenciais - Rela��o de Receitas"
TRCell():New(oFluxo, "PERIODO"			,""	,STR0008/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)  //"Periodo"
TRCell():New(oFluxo, "VALOR_PREV_PV"	,""	,STR0015/*Titulo*/,"@E 99,999,999.99"/*Picture*/,13/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Vlr. Prev PV"
TRCell():New(oFluxo, "VALOR_RECEITAS"	,""	,STR0016/*Titulo*/,"@E 99,999,999.99"/*Picture*/,13/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Vlr. Receitas"
TRCell():New(oFluxo, "ENTRADAS_ACUM"	,""	,STR0017/*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,17/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Entradas Acum."

oFluxo:SetHeaderPage()

Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint �Autor  �Paulo Carnelossi    � Data � 18/08/06  ���
�������������������������������������������������������������������������͹��
���Desc.     �Release 4                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportPrint(oReport, aArrayFlx, aTotais, nPeriodo, nDiasTot)
Local oConsGerProj 	:= oReport:Section(1)

Local aArea			:= GetArea()
Local aHandle
Local aFluxo
Local nTotRec		:= 0
Local nTotDesp		:= 0
Local nSaldo		:= 0
Local nSaldoAcm		:= 0
Local nSaldoDia		:= 0
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
Local nI	 		:= 0
Local nX 			:= 0

oReport:SetPortrait()
nDias   := aDias[nPeriodo]

oReport:SetMeter(Max(100,AJ8->(LastRec())))

If aArrayFlx == Nil
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
        
		Pmr320_Imp(oReport, aArrayFlx, {nTotDesp,nTotRec,nSaldo,nSaldoAcm}, nPeriodo)
		
	EndIf
Else
	Pmr320_Imp(oReport, aArrayFlx, aTotais, nPeriodo)
EndIf


RestArea(aArea)
Return
/*/
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  �PMR320_Imp� Autor � Edson Maricate               � Data �18.04.2003���
���          �          � Autor � Paulo Carnelossi (R4)        � Data �18.08.2006���
��������������������������������������������������������������������������������Ĵ��
���Descricao �Faz a Impressao do relatorio                                       ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
/*/
Function PMR320_Imp(oReport, aArrayFlx, aTotais, nPeriodo)
Local oConsGerProj 	:= oReport:Section(1)
Local oFluxo  		:= oReport:Section(2)

Local aPeriodos := {	STR0003,; //"Diario"
						STR0004,; //"Semanal"
						STR0005,; //"Decendial"
						STR0006,; //"Quinzenal"
						STR0007} //"Mensal"
Local nX 		:= 0

oFluxo:Cell("PERIODO"):SetTitle(STR0008 +CRLF+ PadR(aPeriodos[nPeriodo], 11))
oFluxo:Cell("PERIODO"):SetBlock({|| aArrayFlx[nx][PERIODO] })
oFluxo:Cell("VALOR_PREV_PV"):SetBlock({|| aArrayFlx[nx][PEDVENDA] })
oFluxo:Cell("VALOR_RECEITAS"):SetBlock({|| aArrayFlx[nx][RECEITAS] })
oFluxo:Cell("ENTRADAS_ACUM"):SetBlock({|| aArrayFlx[nx][ENTRADASACUM] })

oConsGerProj:Init()
oConsGerProj:PrintLine()
oConsGerProj:Finish()

oReport:PrintText(STR0011, oReport:Row(), 10) //"Saldo Inicial : "
oReport:PrintText(Transform(aTotais[3],"@E 99,999,999,999.99"), oReport:Row(), 300)
oReport:SkipLine()

oReport:PrintText(STR0012, oReport:Row(), 10) //"Total a Receber : "
oReport:PrintText(Transform(aTotais[2],"@E 99,999,999,999.99"), oReport:Row(), 300)
oReport:SkipLine()

oFluxo:Init()
For nx := 1 to Len(aArrayFlx)
	oReport:IncMeter()
	oFluxo:PrintLine()	
Next
oFluxo:Finish()

Return