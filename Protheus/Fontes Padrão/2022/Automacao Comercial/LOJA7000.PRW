#include "Protheus.ch"
#include "LOJA7000.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA7000  �Autor  �VENDAS CRM          � Data �  10/05/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Motivo de desconto                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA7000

	AxCadastro( "MDT", STR0001, Nil, Nil, 	;
				 Nil, Nil, Nil, Nil, 	 	;
				 {|| LJ7000Integ() }  	    ) // "MOTIVO DE DESCONTO"

Return
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � LJ7000Integ � Autor � Vendas cliente      � Data � 21/03/11 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Responsavel em enviar os dados do cadastro de Motivo de     ���
���			 � desconto para integracao								       ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Cadastro de Motivo de desconto                              ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/ 
Function LJ7000Integ()

	Local cTipo 		:= ""											//Como os dados serao integrados no processo offline    
	Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
	Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline
	
	//Verifica se o ambiente esta em off-line
	If lAmbOffLn   
	
		//Instancia o objeto LJCProcessoOffLine
		oProcessOff := LJCProcessoOffLine():New("034")
		
		//Determina o tipo de operacao 
		If INCLUI
			cTipo := "INSERT"
		ElseIf ALTERA
			cTipo := "UPDATE"
		Else
			cTipo := "DELETE"
			
			//Considera os registros deletados
			SET DELETED OFF
		EndIf
			    
		If !Empty(cTipo)
			//Insere os dados do processo (registro da tabela)
			oProcessOff:Inserir("MDT", xFilial("MDT") + MDT_CODIGO, 1, cTipo)	
				
			//Processa os dados 
			oProcessOff:Processar()	
		EndIf
		
		//Desconsidera os registros deletados
		SET DELETED ON
	EndIf
	
Return (Nil)         

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � J7MovInt    � Autor � Vendas cliente      � Data � 21/03/11 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Responsavel em enviar os dados da movimentacao do motivo    ���
���			 � de desconto integracao								       ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Movimento de Motivo de desconto                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/ 
Function LJ7MovInt()

Local cTipo 		:= ""											//Como os dados serao integrados no processo offline    
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline
Local lEnviaDado	:= .F.                                          // Verifica se existe o Indice 4 e s� envia se houver este indice
Local cContIndice	:= ""	//Conteudo do �ndice Selecionado
Local nIndice		:= 0	//�ndice encontrado
	
	//Verifica se o ambiente esta em off-line
	If lAmbOffLn     
	
		SIX->(DbSetOrder(1))
		If SIX->(DbSeek("MDU4"))  // Verifica se o UPDLOJ89 foi aplicado, pesquisa o Indice 4 da Tabela MDU
			If AllTrim( SIX->CHAVE )  == "MDU_FILIAL+MDU_DOC+MDU_SERIE+MDU_PRODUT"
				cContIndice := xFilial("MDU") + MDU_DOC + MDU_SERIE + MDU_PRODUT
				nIndice		:= 4
				lEnviaDado	:= .T.
			EndIf
		EndIf        
		
		If !lEnviaDado           //Se UPDLOJ89 n�o foi aplicado, deve-se seguir com um �ndice que j� vem cadastrado qdo o UPDLOJ41 � aplicado
			cContIndice	:= xFilial("MDU") + MDU_DOC + MDU_SERIE
			nIndice		:= 2
		EndIf
			
		//Instancia o objeto LJCProcessoOffLine
		oProcessOff := LJCProcessoOffLine():New("035")
		
		//Determina o tipo de operacao 
		cTipo := "INSERT"
			    
		If !Empty(cTipo)
			//Insere os dados do processo (registro da tabela)
			oProcessOff:Inserir("MDU", cContIndice , nIndice , cTipo)	
				
			//Processa os dados 
			oProcessOff:Processar()	
		EndIf
		
	EndIf
	
Return (Nil)  

