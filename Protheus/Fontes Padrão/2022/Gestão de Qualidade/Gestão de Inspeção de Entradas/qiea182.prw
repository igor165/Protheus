#INCLUDE "PROTHEUS.CH"
#INCLUDE "QIEA182.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QIEA182  � Autor � Robson Ramiro A Olivei� Data �21/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descricao �Importacao de Entradas, a partir do arquivo QEP             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAUTO                                                   ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�14/05/01�META  �Foi implementado na funcao QE200SKTE(), o ���
���            �        �      �parametro Revisao do Produto.			  ���
���Paulo Emidio�18/05/01�META  � Ordenada a ordem dos parametros nas fun- ���
���            �        �      � coes a200CoIn() e a200SkLt().            ���
���Paulo Emidio�18/05/01�META  �Implementada a funcao qAtuMatQie(), que   ���
���            �        �      �substitui a QaImpEnt() e o rdmake QIEA181 ���
���            �        �      �na integracao Materiais x QIE e Importacao���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QIEA182()   
Local aDadosImp := {}
Local aRetQie   := {}

dbSelectArea("QEP")
dbSetorder(1)
dbSeek(xFilial("QEP"))
While !Eof() .And. QEP_FILIAL == xFilial("QEP")

	//��������������������������������������������������������������Ŀ
	//� Dados referentes a Importacao Normal						 �
	//����������������������������������������������������������������
	
	aDadosImp := {QEP_NTFISC,;			  //Numero da Nota Fiscal 	 		
		QEP_SERINF,;  			 		  //Serie da Nota Fiscal           	
		QEP_TIPONF,;  					  //Tipo da Nota Fiscal   		 	
		QEP_DTNFIS,; 		      		  //Data de Emissao da Nota Fiscal   
		QEP_DTENTR,; 		      		  //Data de Entrada da Nota Fiscal   
		QEP_TIPDOC,; 	  				  //Tipo de Documento
		Space(TamSx3("D1_ITEM")[1]),;   //Item da Nota Fiscal			
		Space(TamSx3("D1_REMITO")[1]),; //Numero do Remito (Localizacoes)  
		QEP_PEDIDO,; 		  			  //Numero do Pedido de Compra       
		Space(TamSx3("D1_ITEMPC")[1]),; //Item do Pedido de Compra         
		QEP_FORNEC,; 		  			  //Codigo Fornecedor/Cliente        
		QEP_LOJFOR,; 		  			  //Loja Fornecedor/Cliente          
		AllTrim(QEP_DOCENT),; 			  //Numero do Lote do Fornecedor (Doc de Entrada)     
		QEP_SOLIC,; 			  		  //Codigo do Solicitante            
		QEP_PRODUT,; 			  		  //Codigo do Produto                
		Space(TamSx3("D1_LOCAL")[1]),;  //Local Origem    				  
		SubStr(QEP_LOTE,1,10),;		  //Numero do Lote             	
		SubStr(QEP_LOTE,11,6),; 		  //Sequencia do Sub-Lote         
		Space(TamSx3("D1_NUMSEQ")[1]),; //Numero Sequencial             
		QEP_CERFOR,; 		  			  //Numero do CQ					
		Val(QEP_TAMLOT),; 		  		  //Quantidade             		
		QEP_PRECO,; 			  		  //Preco             			
		QEP_DIASAT,;			 		  //Dias de atraso		
		" ",;							  //TES
		QEP_ORIGEM,; 		 		  	  //Origem						
		QEP_IMPORT,; 					  //Origem Importacao TXT
		QEP_LOTORI}						  //Quantidade do Lote original
			
	//��������������������������������������������������������������Ŀ
	//� Realiza a integracao Materiais x Inspecao de Entradas		 �
	//����������������������������������������������������������������
	aRetQie := qAtuMatQie(aDadosImp,If(QEP_EXCLUI=="S",2,1))
			
	dbSelectArea("QEP")
	dbSetOrder(1)	
	dbSkip() 
	
EndDo

Return Nil