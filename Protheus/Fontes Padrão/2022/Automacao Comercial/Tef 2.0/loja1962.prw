#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH" 
#INCLUDE "LOJA1962.CH"


Function LOJA1962 ; Return  // "dummy" function - Internal Use

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCTransDiscado  �Autor�VENDAS CRM     � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar as informacoes comuns das          ��� 
���          �transacoes de tef.                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCTransDiscado
	  
	Data oDiscado 			// objeto  de comunicacao					
	
	Method New()
	Method TratarRet()
	Method TratPad()    
	Method CarregCup()
	Method TransCartao(oDadosTran, oTrans)
	Method TransCheque(oDadosTran, oTrans)	
	Method TransCancela(oDadosTran, oTrans)
    Method Confirmar()
    Method Desfazer()   
    Method RetornaAdm(cRede, cAdmin, cForma, nParcelas)  
    Method GeraVias(oCupom, nVias)

EndClass         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCTransClisitef.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto de comunicacao                                       ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(oDiscado) Class LJCTransDiscado

	Self:oDiscado := oDiscado

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TratarRet    �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata e cria os objetos de retorno para cada tipo de        ���
���          �operacao Discado                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com dados da transacao                               ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratarRet(oDadosTran) Class LJCTransDiscado
	                              
	Local nParcela	:= 1
		
	Do Case
	
		Case oDadosTran:nTipoTrans == _CREDITO .OR. ;
			 oDadosTran:nTipoTrans == _DEBITO .OR. ;
			 oDadosTran:nTipoTrans == _CREDITOPARCELADO .OR. ;
			 oDadosTran:nTipoTrans == _DEBITOPARCELADO .OR. ;
			 oDadosTran:nTipoTrans == _DEBITOPREDATADO   
			 
 	   		If ValType(oDadosTran:nParcela) == "N" .AND. oDadosTran:nParcela > 0  
         		nParcela := oDadosTran:nParcela
         	EndIf
			 
			 //Cria o objeto de retorno para cartao
			 oDadosTran:oRetorno := LJCRetTransacaoCCCD():New()
			 
			 //Alimenta os dados padrao do retorno
			 Self:TratPad(@oDadosTran) 
			                                        //Rede                          //Administradora               //Forma de Pagamento
			 oDadosTran:oRetorno:aAdmin := Self:RetornaAdm(Self:oDiscado:oRetGerenc:C010, Self:oDiscado:oRetGerenc:C040, oDadosTran:cFormaPgto, nParcela)
			 
			 If Len(oDadosTran:oRetorno:aAdmin) == 1
			 	oDadosTran:oRetorno:cAdmFin		:= oDadosTran:oRetorno:aAdmin[1, 7] //No TEF antigo a administradora � a rede  		 

			 Else
				oDadosTran:oRetorno:cAdmFin		:= IIF(Empty(Self:oDiscado:oRetGerenc:C040), Self:oDiscado:oRetGerenc:C010, Self:oDiscado:oRetGerenc:C040) //No TEF antigo a administradora � a rede  		 
			 EndIf
			 //Alimenta os dados especificos
			 oDadosTran:oRetorno:lJurosLoja 	:= Self:oDiscado:oRetGerenc:C011 == "11"
			 
		Case oDadosTran:nTipoTrans == _CHEQUE
		
			//Cria o objeto de retorno para cheque
			 oDadosTran:oRetorno := LJCRetTransacaoCH():New()
			 
			 //Alimenta os dados padrao do retorno
			 Self:TratPad(@oDadosTran)
			 
			 //Alimenta os dados especificos
			 oDadosTran:oRetorno:cAutentica := Self:oDiscado:oRetGerenc:C032  //Criar este campo
			 oDadosTran:oRetorno:nBanco		:= Val(Self:oDiscado:oRetGerenc:C033)
			 oDadosTran:oRetorno:nAgencia	:= Val(Self:oDiscado:oRetGerenc:C034)
		   	 oDadosTran:oRetorno:nC1 		:= Val(Self:oDiscado:oRetGerenc:C035)
		   	 oDadosTran:oRetorno:nConta		:= Val(Self:oDiscado:oRetGerenc:C036)
		   	 oDadosTran:oRetorno:nC2 		:= Val(Self:oDiscado:oRetGerenc:C037)
		   	 oDadosTran:oRetorno:nCheque	:= Val(Self:oDiscado:oRetGerenc:C038)
		   	 oDadosTran:oRetorno:nC3		:= Val(Self:oDiscado:oRetGerenc:C039)
		   	 oDadosTran:oRetorno:cCPFCGC	:= Val(Self:oDiscado:oRetGerenc:C007)   	
			 oDadosTran:oRetorno:nTipoDocCh	:= IIF(Self:oDiscado:oRetGerenc:C006 == "J", 1, 0)     
		
		OtherWise  
			
			//Cria o objeto de retorno para cartao
			 oDadosTran:oRetorno := LJCRetTransacaoCCCD():New()
			 
			 //Alimenta os dados padrao do retorno
			 Self:TratPad(@oDadosTran)					
	EndCase


Return oDadosTran

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TratPad      �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata o retorno padrao das transacoes SITEF		          ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com os dados da transacao                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratPad(oDadosTran) Class LJCTransDiscado
    
    Local nVias := Max(STFGetStat( "TEFVIAS" ),1) //Numero de Vias
	Local cTratVia := Self:CarregCup()    //Cupom
	Local nViaCliente := Round( (nVias - 2)/2, 0)  //Numero de Vias do cliente
	Local nViaCaixa :=  Int( (nVias-2)/2)  //Numero de vias do Caixa
	
	LjGrvLog(,"LOJA1962 - TratPad")
	LjGrvLog(,"LOJA1962 - nVias",nVias)
	LjGrvLog(,"LOJA1962 - cTratVia",cTratVia)
	LjGrvLog(,"LOJA1962 - nViaCliente",nViaCliente)
	LjGrvLog(,"LOJA1962 - nViaCaixa",nViaCaixa)
	
	If Val(Self:oDiscado:oRetGerenc:c710) > 0
		oDadosTran:oRetorno:oViaCliente	:= Self:oDiscado:oRetGerenc:o711
		LjGrvLog(,"LOJA1962 - Self:oDiscado:oRetGerenc:o711",Self:oDiscado:oRetGerenc:o711)
	ElseIf Val(Self:oDiscado:oRetGerenc:c712) > 0
		oDadosTran:oRetorno:oViaCliente	:= Self:oDiscado:oRetGerenc:o713
		LjGrvLog(,"LOJA1962 - Self:oDiscado:oRetGerenc:o713",Self:oDiscado:oRetGerenc:o713)
	Else
		oDadosTran:oRetorno:oViaCliente	:= Self:oDiscado:oRetGerenc:o029
		LjGrvLog(,"LOJA1962 - Self:oDiscado:oRetGerenc:o029 - 1",Self:oDiscado:oRetGerenc:o029)
	EndIf
	
	If Val(Self:oDiscado:oRetGerenc:c714) > 0
		oDadosTran:oRetorno:oViaCaixa	:= Self:oDiscado:oRetGerenc:o715
		LjGrvLog(,"LOJA1962 - Self:oDiscado:oRetGerenc:o715",Self:oDiscado:oRetGerenc:o715)
	Else
		If nVias > 1  
			oDadosTran:oRetorno:oViaCaixa	:= Self:oDiscado:oRetGerenc:o029
			LjGrvLog(,"LOJA1962 - Self:oDiscado:oRetGerenc:o029 - 2",Self:oDiscado:oRetGerenc:o029)
		EndIf
	Endif

		
	If nVias > 2 
		LjGrvLog(,"LOJA1962 - Duplica Vias")
		//M�todo para duplicador o n�mero de vias 
		Self:GeraVias(@oDadosTran:oRetorno:oViaCliente, nViaCliente)
		Self:GeraVias(@oDadosTran:oRetorno:oViaCaixa, nViaCaixa)
	EndIf


	//�����������������������������������������Ŀ
	//�Variavel c009 pode retornar 3 bits, ent�o�
	//� foi tratado essas 3 poss�bilidade       �
	//�������������������������������������������
	oDadosTran:oRetorno:lTransOK	:= IIf(	Self:oDiscado:oRetGerenc:c009 == '0' 	.OR. ;
											Self:oDiscado:oRetGerenc:c009 == '00'	.OR. ;
											Self:oDiscado:oRetGerenc:c009 == '000', .T., .F.)	
	
	oDadosTran:oRetorno:dData			:= Self:oDiscado:oRetGerenc:c022
	oDadosTran:oRetorno:cHora			:= Self:oDiscado:oRetGerenc:c023
	oDadosTran:oRetorno:cAutoriz		:= Self:oDiscado:oRetGerenc:c013				
	oDadosTran:oRetorno:cNsu			:= Self:oDiscado:oRetGerenc:c012				
	oDadosTran:oRetorno:cId		 		:= Self:oDiscado:oRetGerenc:c001				
	oDadosTran:oRetorno:cFinalizacao	:= Self:oDiscado:oRetGerenc:c027					

	oDadosTran:oRetorno:cViaCaixa	:= cTratVia
	oDadosTran:oRetorno:cViaCliente	:= cTratVia 
	oDadosTran:oRetorno:cRede 		:= Self:oDiscado:oRetGerenc:C010  
	oDadosTran:oRetorno:cNsuAutor   := Self:oDiscado:oRetGerenc:C013
	oDadosTran:oRetorno:cDocCanc    := Self:oDiscado:oRetGerenc:C025
	oDadosTran:oRetorno:dDataCanc   := Self:oDiscado:oRetGerenc:C026 
	
	LjGrvLog(,"LOJA1962 - oDadosTran:oRetorno:cViaCaixa recebe cTratVia",oDadosTran:oRetorno:cViaCaixa)
	LjGrvLog(,"LOJA1962 - oDadosTran:oRetorno:cViaCliente recebe cTratVia",oDadosTran:oRetorno:cViaCliente)
	
	oDadosTran:oRetorno:nParcs  := Val(Self:oDiscado:oRetGerenc:C018) 
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CarregCup    �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega o cupom do SITEF no objeto LJCList		          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarregCup() Class LJCTransDiscado
	
	Local cRet 	:= ''	// tratamento da varia�vel
	Local nCont	:= 0	// numerador		
	
	
	For nCont := 1 To Self:oDiscado:oRetGerenc:o029:Count()
		
		cRet += Self:oDiscado:oRetGerenc:o029:Elements(nCont) + CHR(10)
			
	Next

	//Tratamento para quando o elemento 029 n�o vier preenchido
	If Empty(cRet)
	
		For nCont := 1 To Self:oDiscado:oRetGerenc:o711:Count()
			cRet += Self:oDiscado:oRetGerenc:o711:Elements(nCont) + CHR(10)
		Next
	
		If Empty(cRet) 
			For nCont := 1 To Self:oDiscado:oRetGerenc:o713:Count()
				cRet += Self:oDiscado:oRetGerenc:o713:Elements(nCont) + CHR(10)
			Next	
		EndIf
	
		If Empty(cRet)
			For nCont := 1 To Self:oDiscado:oRetGerenc:o715:Count()
				cRet += Self:oDiscado:oRetGerenc:o715:Elements(nCont)
			Next	
		EndIf
		
	EndIf
	

Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Confirmar    �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirmar as operacoes pendentes.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com os dados da transacao                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Confirmar(oTransacao) Class LJCTransDiscado
	
	Local lRet 				:= .T.                            	// Retorno
	Local oArqDes			:= LJCArquivo():New(GetClientDir()+"ncncnf.001") 	// Objeto resp. p guarda resumo das trans
	Local nCount			:= 0								// contador
	Local aTransac			:=  {}								// Dados da Transacao	  
	Local oRetGerenc		:= NIL		  //Relatorio Gerencial
	
	aTransac := Self:oDiscado:LerArqPend(_DISCADO_PENDENTE)
		
	For nCount := 1 To Len(aTransac) 
			
		oRetGerenc     := LJCRetTransacaoCCCD():New()  

		oRetGerenc:cRede:= Upper(aTransac[nCount,1])
		oRetGerenc:cNsu := aTransac[nCount,2]
		oRetGerenc:cFinalizacao := aTransac[nCount,3]   
		
      	If Self:oDiscado:oConfig:Count() > 1
      		Self:oDiscado:oConfigAtual := Self:oDiscado:oConfig:ElementKey(Upper(aTransac[nCount,1]))
      	Else 
      		Self:oDiscado:oConfigAtual := Self:oDiscado:oConfig:Elements(1)
      	EndIf
		 
		Self:oDiscado:CriarCNF(oRetGerenc,.t., aTransac[nCount,5] )

	Next nCount
	
	If Len(aTransac) > 0
		FreeObj(oRetGerenc)
	EndIf
    
	If lRet
		If oArqDes:Existe()
			oArqDes:Apagar()
		EndIf
	EndIf    
	
	FreeObj(oArqDes)
	
	
Return lRet

/*���������������������������������������������������������������������������
���Programa  |Desfazer     �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Desfaz as operacoes pendentes.                    		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
���������������������������������������������������������������������������*/
Method Desfazer() Class LJCTransDiscado 
	Local lRet 				:= .T.                            	// Retorno
	Local oArqDes			:= LJCArquivo():New(GetClientDir()+"ncncnf.001") 	// Objeto resp. p guarda resumo das trans
	Local nCount			:= 0								// contador
	Local aTransac			:=  {}								// Dados da Transacao	  
	Local oDados			:= NIL	   //Objeto Dados
	Local oRetTran			:= NIL	   //Objeto de Retorno
	Local cOper				:= ""
	
	LjGrvLog( Nil, " Inicio da fun��o ")
	
	aTransac := Self:oDiscado:LerArqPend()
	
	aSort(aTransac,, , {|a, b| a[8] < b[8]} )
	LjGrvLog( Nil, " Conteudo de aTransac ",aTransac) 
	
	LjGrvLog( Nil, " Log do Objeto oDiscado : ", Self:oDiscado)

	For nCount := 1 To Len(aTransac) 
		
	      If aTransac[nCount, 8] == _DISCADO_PENDENTE
	      	If Self:oDiscado:oConfig:Count() > 1
	      		cOper := Upper(aTransac[nCount,1])
	      		Self:oDiscado:oConfigAtual := Self:oDiscado:oConfig:ElementKey(cOper)
	      	Else 
	      		Self:oDiscado:oConfigAtual := Self:oDiscado:oConfig:Elements(1)
	      	EndIf
	      	Self:oDiscado:CriarNcn(aTransac[nCount, 2], aTransac[nCount, 1], aTransac[nCount, 3],Val(aTransac[nCount,4])/100, .T., aTransac[nCount,5])
	      Else 
	         If aTransac[nCount, 8]$  _DISCADO_CONFIRMADA + "|" + _DISCADO_APROVADA +"|" + _DISCADO_CANCELADA 
	         	cOper := Upper(aTransac[nCount,1])
	         	Self:oDiscado:oConfigAtual := Self:oDiscado:oConfig:ElementKey(cOper)         	        
				oDados := LJCDadosTransacaoCNC():New(Val(aTransac[nCount,04])/100	, 0	, Date()	, Time()		, ;
		   												aTransac[nCount,13]		, aTransac[nCount,14]	, aTransac[nCount,16], aTransac[nCount,18] 	, ;
		   												aTransac[nCount,15]		, aTransac[nCount,17]	, aTransac[nCount,19], aTransac[nCount,11],;
		   												CtoD(Transform(aTransac[nCount,20],"99/99/9999")), aTransac[nCount,12]	, aTransac[nCount,02]	, aTransac[nCount,01]		, ;
		   												CtoD(Transform(aTransac[nCount,06],"99/99/9999")), aTransac[nCount,07])  
   			   
   					oRetTran := Self:TransCancela(oDados, ,aTransac[nCount, 09], .T.)	
   		
   		
				If oRetTran:oRetorno:lTransOk  
	     
	         		If oRetTran:oRetorno:oViaCaixa:Count() > 0  
	         			Self:oDiscado:CriarCNF(oRetTran:oRetorno,.t., oRetTran:oRetorno:c001) 
	         			
	         			STFMessage("TEFDiscado", "OK", ;
	         					   				STR0001 + CHR(13) + CHR(10) + 	; //"�ltima transa��o TEF foi cancelada"
	         					   				STR0002 + oRetTran:cRede + CHR(13) + CHR(10) + ;
	         					   				IIf(oRetTran:nValor == 0, "", "NSU: " + oRetTran:cNsu)	+ CHR(13) + CHR(10) + STR0003 + Transform(oRetTran:nValor, "@E 999,999,9999,999.99") )  //"Valor: "
						STFShowMessage("TEFDiscado")
		         			
	         		EndIf
	   			Else

	   				lRet := .F.
	   				Exit
	   				
	   			EndIf
	   			
	   			oDados := FreeObj(oDados)
	         EndIf
	      EndIf
	Next nCount  

    
	If lRet
		If oArqDes:Existe()  
			oArqDes:Apagar()
		EndIf
	EndIf 
	
	FreeObj(oArqDes)
	
	LjGrvLog( Nil, " Fim da fun��o ")	
Return lRet
                                                   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |TransCartao  �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza qualquer transacao de cartao              		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com dados da transacao                               ���
���          �EXPC2                                                       ���
���          �Transacao corrente                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TransCartao(oDadosTran, oTrans) Class LJCTransDiscado 
   	

	//���������������Ŀ
	//�Manda transacao�
	//�����������������
	Self:oDiscado:SetTrans(oDadosTran) 	
	Self:oDiscado:CriarCRT()

	//��������������������������������Ŀ
	//�Carrega os retorno do Gerenciador�
	//����������������������������������
	oDadosTran := Self:TratarRet(oDadosTran)
	oTrans:Add(oDadosTran:oRetorno:cNsu ,oDadosTran)

   	
Return oDadosTran   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |TransCheque  �Autor  �Vendas CRM       � Data �  22/01/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza qualquer transacao de cartao              		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com dados da transacao                               ���
���          �EXPC2                                                       ���
���          �Transacao corrente                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TransCheque(oDadosTran, oTrans) Class LJCTransDiscado 
	
	//���������������Ŀ
	//�Manda transacao�
	//�����������������
	Self:oDiscado:SetTrans(oDadosTran)  
		
	Self:oDiscado:CriarCHQ()

	//��������������������������������Ŀ
	//�Carrega os retorno do Gerenciado�
	//����������������������������������
	oDadosTran := Self:TratarRet(oDadosTran)
	oTrans:Add(oDadosTran:oRetorno:cNsu ,oDadosTran)   
	
Return oDadosTran 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |TransCancela �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza transa��o de cancelamento                    		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com dados da transacao                               ���
���          �EXPC2                                                       ���
���          �Transacao corrente                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TransCancela(oDadosTran, oTrans, cTransac, lAtivo) Class LJCTransDiscado 
   	

	//���������������Ŀ
	//�Manda transacao�
	//�����������������     
	DEFAULT cTransac := ""  
	DEFAULT lAtivo := .F.
	
	Self:oDiscado:SetTrans(oDadosTran) 	
	Self:oDiscado:CriarCNC(,cTransac, lAtivo)

	//��������������������������������Ŀ
	//�Carrega os retorno do Gerenciador�
	//����������������������������������
	oDadosTran := Self:TratarRet(oDadosTran)  
	
	If oTrans <> NIL
		oTrans:Add(oDadosTran:oRetorno:cNsu ,oDadosTran)
    EndIf
   	
Return oDadosTran    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �RetornaAdm�Autor  �Vendas Clientes     � Data �  25/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a Administradora Financeira, conforme codigo SiTEF  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RetornaAdm(cRede, cAdmin, cForma, nParcelas) Class LJCTransDiscado
	Local aRetorno := {}  //Retorno
	Local oTEF := STBGetTef() //Objeto TEF
	Local aAdmin :=  oTEF:Administradoras() //Array de administradoras
	Local nPos := 0 //Posicao
	
    If Empty(cAdmin)
    	cAdmin := cRede
    EndIf
	
	aSort(aAdmin, , , { |a, b| a[7] +  a[2] + StrZero(a[4], 4) + StrZero(a[5], 4) < b[7] +  b[2] + StrZero(b[4], 4) + StrZero(b[5], 4)} )
	
	If  ( nPos := aScan( aAdmin, { |a|  cAdmin $  a[7] .AND. a[2] == cForma} ) )  > 0   
		Do While nPos <= Len(aAdmin)  .AND. cAdmin $ aAdmin[nPos, 7] .AND. aAdmin[nPos, 2] == cForma .AND. aAdmin[nPos, 4]  <= nParcelas .AND. aAdmin[nPos, 5] >=  nParcelas
			aAdd( aRetorno, aClone( aAdmin[nPos] ))
			nPos++
		EndDo
	Else
		//ordena pela SAE descri��o    
		aSort(aAdmin, , , { |a, b| a[3] +  a[2] + StrZero(a[4], 4) + StrZero(a[5], 4) < b[3] +  b[2] + StrZero(b[4], 4) + StrZero(b[5], 4)} )
		
		If  ( nPos := aScan( aAdmin, { |a|  cAdmin $  a[3] .AND. a[2] == cForma} ) )  > 0   
			Do While nPos <= Len(aAdmin)  .AND. cAdmin $ aAdmin[nPos, 3] .AND. aAdmin[nPos, 2] == cForma .AND. aAdmin[nPos, 4]  <= nParcelas .AND. aAdmin[nPos, 5] >=  nParcelas
				aAdd( aRetorno, aClone( aAdmin[nPos] ))
				nPos++
			EndDo
		EndIf
	EndIf   
	
	

Return aRetorno    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GeraVias  �Autor  �Vendas Clientes     � Data �  27/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera as copias de vias do comprovante TEF                   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GeraVias(oCupom, nVias) Class LJCTransDiscado
	Local oClone := oCupom:Clonar() //Clone do cupom
	Local nI := 0 //total de Vias
	Local nCount := 0 //Linha do Cupom
	Local nLinhas := oClone:Count() //Linhas
	
	For nI := 1 to nVias    
		oCupom:ADD("")
		oCupom:ADD("") 
		oCupom:ADD("")
		For nCount := 1 To nLinhas
			If Valtype(oClone:Elements(nCount)) == "O"
				oCupom:ADD(oClone:Elements(nCount):Clonar())
			Else
				oCupom:ADD(oClone:Elements(nCount))
			EndIf
		Next
	Next
	
	oClone := FreeObj(oClone)
	
Return

  		
