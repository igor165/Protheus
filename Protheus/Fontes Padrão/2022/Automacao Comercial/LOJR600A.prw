#INCLUDE "Protheus.ch"
#INCLUDE "LOJR600A.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LOJR600A   ³ Autor ³ Vendas Cliente       ³ Data ³ 24/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta cupom de relatório Gerencial. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Produto											  ³±±
±±³          ³ cExp2 - Descrição do produto							 	  ³±±
±±³          ³ cExp3 - Valor do Produto									  ³±±
±±³          ³ cExp4 - Numero de série 									  ³±±
±±³          ³ cExp5 - Codigo do produto de garantia 					  ³±±
±±³          ³ cExp6 - Descrição de garantia estendida			          ³±± 
±±³          ³ cExp7 - Valor da Garantia estendida 						  ³±± 
±±³          ³ cExp8 - Nome do Cliente 							          ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA701D													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function LOJR600A(cCodProd,cDescProd,cVlrProd,cNumSerie,cCodGar,cDescriGar,cVlrGar,cNomeCli,nMoeda,lSFinanc,lPosPdv,cCPFCli)

Local cTexto		:= ""													// String de texto 
Local nRet			:= 0                                                	// Número de retorno
Local nCount		:= 0                                                	// Usado no Laço para imprimir os relatórios 
Local cDtLocal		:= ""													// Local e data por extenso
Local lPOS			:= ExistFunc("STFIsPOS") .AND. STFIsPOS()				// Valida se é POS

Default  lSFinanc	:= .F.
Default  cCPFCli 	:= ""
Default  lPosPdv	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Texto que será impresso como Default no Relatorio Gerencial.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSFinanc
	cTexto := Chr(10)+ STR0001 + Chr(10) + Chr(10)//"      CONTRATO DE GARANTIA ESTENDIDA"
	cTexto += STR0002 + Chr(10)//"Este é um comprovante de adesão ao serviço"
	cTexto += STR0003 + Chr(10) + Chr(10)//"de Garantia Estendida."
	cTexto += STR0004 + Chr(10)//"A Garantia Estendida só será válida após o fim"
	cTexto += STR0005 + Chr(10)//"da Garantia de Fabrica!"
	cTexto += STR0006 + Chr(10) + Chr(10)+Chr(10)//"--------------------------------------"
	cTexto += STR0007 + Chr(10) + Chr(10)//"Dados da Garantia:"
	cTexto += STR0008 + cCodProd + Chr(10)//"Produto: "
	cTexto += STR0009 + cDescProd + Chr(10)//"Descrição: "
	cTexto += STR0010 + LTrim(cVlrProd) + Chr(10)//"Valor: "
	cTexto += STR0011 + cNumSerie + Chr(10) + Chr(10) + Chr(10) + Chr(10)//"Número de Série: "
	cTexto += STR0012 + cCodGar + Chr(10)//"Código da Garantia: "
	cTexto += STR0013 + cDescriGar + Chr(10)//"Descrição da Garantia: "
	cTexto += STR0014 + LTrim(cVlrGar)+ Chr(10)+ Chr(10)+ Chr(10)+ Chr(10)//"Valor da Garantia: "
	cTexto += STR0015 + Chr(10)//"--------------------------------------"
	cTexto += STR0016 + Chr(10) + Chr(10) + Chr(10)//"      DECLARAÇÃO DO CLIENTE"
	cTexto += STR0017 + RTrim(cNomeCli) + STR0018 + Chr(10)//"Eu, "###" declaro estar de acordo com as "
	cTexto += STR0019 + Chr(10)//"condições apresentadas neste certifícado que"
	cTexto += STR0020 + Chr(10)//"me foi entregue na data de hoje,e reconheço que a carência vai até data final da garantia de fabrica."
	cTexto += STR0021 + Chr(10)//"E para que não haja dúvidas quanto a verdade deste fato firmo o"
	cTexto += STR0022 + Chr(10)+ Chr(10)+ Chr(10)+ Chr(10)+ Chr(10)+ Chr(10)//"presente."
	cTexto += STR0023 + Chr(10)+ Chr(10)//"______________________"
	cTexto += cNomeCli+ Chr(10)+ Chr(10)+ Chr(10)//
Else
	If lPOS 
		cCPFCli := POSICIONE("SA1", 1, xFilial("SA1") + STDGPBasket( "SL1" , "L1_CLIENTE" ) + STDGPBasket( "SL1" , "L1_LOJA" ), "A1_CGC")
	ElseIf EMPTY (cCPFCli)
		cCPFCli := SA1->A1_CGC
	EndIf
	cCPFCli  := Alltrim(Transform(cCPFCli,"@R 999.999.999-99"))	
	cDtLocal := AllTrim(SM0->M0_CIDENT)+", "+MesExtenso(Month(dDataBase))+" "+AllTrim(Str(Day(dDataBase)))+" de "+AllTrim(Str(Year(dDataBase)))
	
	cTexto := "" + Chr(10)
	cTexto += STR0025 + Chr(10) //" TERMO DE AUTORIZAÇÃO DE COBRANÇA DE PRÊMIO DE SEGURO  "
	cTexto += "" + Chr(10)
	cTexto += STR0017 + SUBSTR(AllTrim(cNomeCli),1,30) + STR0026 + Chr(10) //#"Eu, " ##", inscrito no CPF/MF  "
	cTexto += STR0027 + cCPFCli + STR0028 + Chr(10) //#"sob o numero " ##", proponente do seguro "
	cTexto += SUBSTR(AllTrim(cDescriGar),1,26) + STR0029 + Chr(10) //", descrito na Proposta/Bilhete"
	cTexto += STR0030 + AllTrim(cCodGar) + STR0031 + Chr(10) //#"de Seguro número " ##", autorizo que o paga_" 
	cTexto += STR0032 + Chr(10) //"mento do prêmio de seguro seja realizado em conjunto com"
	cTexto += STR0033 + Chr(10) //"o pagamento do(s) produto(s)/serviço(s) ora adquirido(s)"
	cTexto += "" + Chr(10)
	cTexto += "" + cDtLocal	 + Chr(10)	
	cTexto += "" + Chr(10)
	cTexto += STR0034 + Chr(10) //"           ________________________________             "
	cTexto += STR0035 + Chr(10) //"               (Assinatura do Segurado)                 "
	cTexto += "" 	  + Chr(10)
	cTexto += STR0036 + Chr(10) //"Notas:                                                  "
	cTexto += STR0037 + Chr(10) //"1) O segurado poderá desistir do seguro contratado no   "
	cTexto += STR0038 + Chr(10) //" prazo de 7 (sete) dias corridos a contar da assinatura " 
	cTexto += STR0039 + Chr(10) //" da proposta, no caso de contratação por apólice indivi-"
	cTexto += STR0040 + Chr(10) //" dual, ou da emissão de bilhete, no caso de contratação "
	cTexto += STR0041 + Chr(10) //" por bilhete, ou do efetivo pagamento do prêmio, o que  "
	cTexto += STR0042 + Chr(10) //" ocorrer por último.                                    "
	cTexto += STR0043 + Chr(10) //"2) No caso de pagamento de prêmio fracionado, conside-  " 
	cTexto += STR0044 + Chr(10) //" ra-se o pagamento da primeira parcela como o efetivo   "
	cTexto += STR0045 + Chr(10) //" pagamento.                                             "
	cTexto += "" 	  + Chr(10)
	 	
	cTexto += STR0046 + Chr(10) //"________________________________________________________"
	cTexto += "" 	  + Chr(10)
	cTexto += STR0047 + Chr(10) //"             CONTRATO DE SERVIÇO FINANCEIRO             "
	cTexto += STR0048 + Chr(10) //" Este é um comprovante de adesão ao Serviço Financeiro  "
	cTexto += STR0049 + Chr(10) //"--------------------------------------------------------"
	cTexto += "" 	  + Chr(10)
	cTexto += STR0050 + Chr(10) //"Dados do Serviço:                                       " 
	cTexto += STR0008 + cCodGar  + Chr(10)//"Produto: "
	cTexto += STR0009 + cDescriGar + Chr(10)//"Descrição: "
	cTexto += STR0010 + LTrim(cVlrProd) + Chr(10)//"Valor: "
	cTexto += "" + Chr(10)
	cTexto += STR0049 + Chr(10) //"--------------------------------------------------------"
	cTexto += "                 " + AllTrim(STR0016) + "                  "	 + Chr(10)
	cTexto += "" + Chr(10)
	cTexto += STR0017 + SUBSTR(AllTrim(cNomeCli),1,28) + STR0018 + Chr(10) //#"Eu, " ##" declaro estar de acordo com as "	
	cTexto += STR0019 + Chr(10) //"condições apresentadas neste certifícado que"
	cTexto += STR0051 + Chr(10) //"me foi entregue na data de hoje."
	cTexto += STR0021 + Chr(10) //"E para que não haja dúvidas quanto a verdade deste fato firmo o"
	cTexto += STR0022 + Chr(10) //"presente."
	cTexto += "" + Chr(10)
	cTexto += STR0034 + Chr(10) //"           ________________________________             "
	cTexto += STR0035 + Chr(10) //"               (Assinatura do Segurado)                 "
	cTexto += "" + Chr(10)
EndIf	

If !lPosPdv
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe cupom fiscal em aberto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRet := IFStatus( nHdlECF, '5')
	If nRet <> 7
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime 2 vias do contrato de garantia estendida³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCount:=1 To 2
			nRet := IfRelGer( nHdlECF, cTexto, 1 )
		Next nCount
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³se nRet não for = 0 a impressão não foi realizada.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nRet <> 0
			MsgAlert(STR0024)    //"Falha na impressão, verifique se a impressora está conectada!"
		EndIf
	EndIf
EndIf

Return cTexto
