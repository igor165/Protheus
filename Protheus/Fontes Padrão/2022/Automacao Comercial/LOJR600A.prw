#INCLUDE "Protheus.ch"
#INCLUDE "LOJR600A.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �LOJR600A   � Autor � Vendas Cliente       � Data � 24/01/11 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta cupom de relat�rio Gerencial. 						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1 - Produto											  ���
���          � cExp2 - Descri��o do produto							 	  ���
���          � cExp3 - Valor do Produto									  ���
���          � cExp4 - Numero de s�rie 									  ���
���          � cExp5 - Codigo do produto de garantia 					  ���
���          � cExp6 - Descri��o de garantia estendida			          ��� 
���          � cExp7 - Valor da Garantia estendida 						  ��� 
���          � cExp8 - Nome do Cliente 							          ��� 
�������������������������������������������������������������������������Ĵ��
���Uso		 � LOJA701D													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function LOJR600A(cCodProd,cDescProd,cVlrProd,cNumSerie,cCodGar,cDescriGar,cVlrGar,cNomeCli,nMoeda,lSFinanc,lPosPdv,cCPFCli)

Local cTexto		:= ""													// String de texto 
Local nRet			:= 0                                                	// N�mero de retorno
Local nCount		:= 0                                                	// Usado no La�o para imprimir os relat�rios 
Local cDtLocal		:= ""													// Local e data por extenso
Local lPOS			:= ExistFunc("STFIsPOS") .AND. STFIsPOS()				// Valida se � POS

Default  lSFinanc	:= .F.
Default  cCPFCli 	:= ""
Default  lPosPdv	:= .F.

//������������������������������������������������������������Ŀ
//�Texto que ser� impresso como Default no Relatorio Gerencial.�
//��������������������������������������������������������������
If !lSFinanc
	cTexto := Chr(10)+ STR0001 + Chr(10) + Chr(10)//"      CONTRATO DE GARANTIA ESTENDIDA"
	cTexto += STR0002 + Chr(10)//"Este � um comprovante de ades�o ao servi�o"
	cTexto += STR0003 + Chr(10) + Chr(10)//"de Garantia Estendida."
	cTexto += STR0004 + Chr(10)//"A Garantia Estendida s� ser� v�lida ap�s o fim"
	cTexto += STR0005 + Chr(10)//"da Garantia de Fabrica!"
	cTexto += STR0006 + Chr(10) + Chr(10)+Chr(10)//"--------------------------------------"
	cTexto += STR0007 + Chr(10) + Chr(10)//"Dados da Garantia:"
	cTexto += STR0008 + cCodProd + Chr(10)//"Produto: "
	cTexto += STR0009 + cDescProd + Chr(10)//"Descri��o: "
	cTexto += STR0010 + LTrim(cVlrProd) + Chr(10)//"Valor: "
	cTexto += STR0011 + cNumSerie + Chr(10) + Chr(10) + Chr(10) + Chr(10)//"N�mero de S�rie: "
	cTexto += STR0012 + cCodGar + Chr(10)//"C�digo da Garantia: "
	cTexto += STR0013 + cDescriGar + Chr(10)//"Descri��o da Garantia: "
	cTexto += STR0014 + LTrim(cVlrGar)+ Chr(10)+ Chr(10)+ Chr(10)+ Chr(10)//"Valor da Garantia: "
	cTexto += STR0015 + Chr(10)//"--------------------------------------"
	cTexto += STR0016 + Chr(10) + Chr(10) + Chr(10)//"      DECLARA��O DO CLIENTE"
	cTexto += STR0017 + RTrim(cNomeCli) + STR0018 + Chr(10)//"Eu, "###" declaro estar de acordo com as "
	cTexto += STR0019 + Chr(10)//"condi��es apresentadas neste certif�cado que"
	cTexto += STR0020 + Chr(10)//"me foi entregue na data de hoje,e reconhe�o que a car�ncia vai at� data final da garantia de fabrica."
	cTexto += STR0021 + Chr(10)//"E para que n�o haja d�vidas quanto a verdade deste fato firmo o"
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
	cTexto += STR0025 + Chr(10) //" TERMO DE AUTORIZA��O DE COBRAN�A DE PR�MIO DE SEGURO  "
	cTexto += "" + Chr(10)
	cTexto += STR0017 + SUBSTR(AllTrim(cNomeCli),1,30) + STR0026 + Chr(10) //#"Eu, " ##", inscrito no CPF/MF  "
	cTexto += STR0027 + cCPFCli + STR0028 + Chr(10) //#"sob o numero " ##", proponente do seguro "
	cTexto += SUBSTR(AllTrim(cDescriGar),1,26) + STR0029 + Chr(10) //", descrito na Proposta/Bilhete"
	cTexto += STR0030 + AllTrim(cCodGar) + STR0031 + Chr(10) //#"de Seguro n�mero " ##", autorizo que o paga_" 
	cTexto += STR0032 + Chr(10) //"mento do pr�mio de seguro seja realizado em conjunto com"
	cTexto += STR0033 + Chr(10) //"o pagamento do(s) produto(s)/servi�o(s) ora adquirido(s)"
	cTexto += "" + Chr(10)
	cTexto += "" + cDtLocal	 + Chr(10)	
	cTexto += "" + Chr(10)
	cTexto += STR0034 + Chr(10) //"           ________________________________             "
	cTexto += STR0035 + Chr(10) //"               (Assinatura do Segurado)                 "
	cTexto += "" 	  + Chr(10)
	cTexto += STR0036 + Chr(10) //"Notas:                                                  "
	cTexto += STR0037 + Chr(10) //"1) O segurado poder� desistir do seguro contratado no   "
	cTexto += STR0038 + Chr(10) //" prazo de 7 (sete) dias corridos a contar da assinatura " 
	cTexto += STR0039 + Chr(10) //" da proposta, no caso de contrata��o por ap�lice indivi-"
	cTexto += STR0040 + Chr(10) //" dual, ou da emiss�o de bilhete, no caso de contrata��o "
	cTexto += STR0041 + Chr(10) //" por bilhete, ou do efetivo pagamento do pr�mio, o que  "
	cTexto += STR0042 + Chr(10) //" ocorrer por �ltimo.                                    "
	cTexto += STR0043 + Chr(10) //"2) No caso de pagamento de pr�mio fracionado, conside-  " 
	cTexto += STR0044 + Chr(10) //" ra-se o pagamento da primeira parcela como o efetivo   "
	cTexto += STR0045 + Chr(10) //" pagamento.                                             "
	cTexto += "" 	  + Chr(10)
	 	
	cTexto += STR0046 + Chr(10) //"________________________________________________________"
	cTexto += "" 	  + Chr(10)
	cTexto += STR0047 + Chr(10) //"             CONTRATO DE SERVI�O FINANCEIRO             "
	cTexto += STR0048 + Chr(10) //" Este � um comprovante de ades�o ao Servi�o Financeiro  "
	cTexto += STR0049 + Chr(10) //"--------------------------------------------------------"
	cTexto += "" 	  + Chr(10)
	cTexto += STR0050 + Chr(10) //"Dados do Servi�o:                                       " 
	cTexto += STR0008 + cCodGar  + Chr(10)//"Produto: "
	cTexto += STR0009 + cDescriGar + Chr(10)//"Descri��o: "
	cTexto += STR0010 + LTrim(cVlrProd) + Chr(10)//"Valor: "
	cTexto += "" + Chr(10)
	cTexto += STR0049 + Chr(10) //"--------------------------------------------------------"
	cTexto += "                 " + AllTrim(STR0016) + "                  "	 + Chr(10)
	cTexto += "" + Chr(10)
	cTexto += STR0017 + SUBSTR(AllTrim(cNomeCli),1,28) + STR0018 + Chr(10) //#"Eu, " ##" declaro estar de acordo com as "	
	cTexto += STR0019 + Chr(10) //"condi��es apresentadas neste certif�cado que"
	cTexto += STR0051 + Chr(10) //"me foi entregue na data de hoje."
	cTexto += STR0021 + Chr(10) //"E para que n�o haja d�vidas quanto a verdade deste fato firmo o"
	cTexto += STR0022 + Chr(10) //"presente."
	cTexto += "" + Chr(10)
	cTexto += STR0034 + Chr(10) //"           ________________________________             "
	cTexto += STR0035 + Chr(10) //"               (Assinatura do Segurado)                 "
	cTexto += "" + Chr(10)
EndIf	

If !lPosPdv
	//�����������������������������������������Ŀ
	//�Verifica se existe cupom fiscal em aberto�
	//�������������������������������������������
	nRet := IFStatus( nHdlECF, '5')
	If nRet <> 7
		//������������������������������������������������Ŀ
		//�Imprime 2 vias do contrato de garantia estendida�
		//��������������������������������������������������
		For nCount:=1 To 2
			nRet := IfRelGer( nHdlECF, cTexto, 1 )
		Next nCount
		//��������������������������������������������������Ŀ
		//�se nRet n�o for = 0 a impress�o n�o foi realizada.�
		//����������������������������������������������������
		If nRet <> 0
			MsgAlert(STR0024)    //"Falha na impress�o, verifique se a impressora est� conectada!"
		EndIf
	EndIf
EndIf

Return cTexto
