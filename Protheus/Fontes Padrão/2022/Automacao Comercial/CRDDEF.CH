/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRDDEF    �Autor  �Fernando Machima    � Data �  16/06/05   ���
�������������������������������������������������������������������������͹��
���Descricao �DEFINES DO MODULO SIGACRD 								  ���
�������������������������������������������������������������������������͹��
���Uso       �MP8                                                         ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

// Valores dos tipos de transacao dos Contratos(ref. MAH_TRANS)
#DEFINE TRANS_OK		1
#DEFINE TRANS_PEND		2
#DEFINE TRANS_CANC		3
#DEFINE TRANS_DEV		4

// Valores dos status dos Contratos(ref. MAH_STATUS)
#DEFINE ST_OK		    1
#DEFINE ST_PEND	   		2
#DEFINE ST_LIB		    3
#DEFINE ST_REJ		    4
#DEFINE ST_CRED	 		5
#DEFINE ST_CANC	  		6

// Valores dos status dos Creditos dos clientes(ref. MA7_BLOQUE)
#DEFINE BLOQUEADO		1
#DEFINE DESBLOQ			2
#DEFINE REJEITADO      3
#DEFINE CREDIARIO		4
#DEFINE BLOQCONS		5        //Bloqueado pela consulta de credito(nao envia ao Crediario)

// Valores para venda forcada ou nao(ref. L1_FORCADA) 
#DEFINE FORCADA        1
#DEFINE NAOFORCADA		2
                                            
// Caracteres especiais que o WebService nao consegue ler e deve ser evitado.                                 
#DEFINE ESPECIAL1		CHR(129)	//"�"	
#DEFINE ESPECIAL2		CHR(141)	//"�"	
#DEFINE ESPECIAL3		CHR(143)	//"�"	
#DEFINE ESPECIAL4		CHR(144)	//"�"	
#DEFINE ESPECIAL5		CHR(157)	//"�"	

// Valores dos status do Vale Compra (Ref. MAV_STATUS)
#DEFINE ATIVO			1 
#DEFINE RECEBIDO		2
#DEFINE UTILIZADO		3
#DEFINE INATIVO	   		4 

// Devolucao/Exclusao de nota (Ref. as operacoes: Devolucao de mercadoria e Exclusao de Cupom Fiscal)
#DEFINE DEVOLUCAO		2
#DEFINE EXCLUSAO      	3		

//Liberacao do premio (Ref. MAZ_STATUS)
#DEFINE RESGATE			1
#DEFINE PAGAMENTO 		2
                                    

//Mensagens de Bloqueio que serao mostradas ao analista de credito
#DEFINE DTLIMNULA		1	//Bloqueia quando a data de limite de credito esta nula. Neste caso sempre sera bloqueada
#DEFINE DTLIMVENC   	2	//Bloqueia quando a data de limite de credito esta vencida
#DEFINE LIMINSUF		3	//Bloqueia quando o limite de credito e insuficiente para a compra
#DEFINE PASSAGEM		4 	//Bloqueia por passagem de risco, ou seja, quando o cliente volta na loja antes de x dias definido no parametro MV_NUMBLOQ

#DEFINE LIMEMISCF		10000 	//Valor Maximo do Cupom Fiscal


