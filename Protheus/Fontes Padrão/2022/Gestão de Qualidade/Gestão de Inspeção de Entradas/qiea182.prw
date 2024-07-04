#INCLUDE "PROTHEUS.CH"
#INCLUDE "QIEA182.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QIEA182  ³ Autor ³ Robson Ramiro A Olivei³ Data ³21/03/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Importacao de Entradas, a partir do arquivo QEP             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAAUTO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³14/05/01³META  ³Foi implementado na funcao QE200SKTE(), o ³±±
±±³            ³        ³      ³parametro Revisao do Produto.			  ³±±
±±³Paulo Emidio³18/05/01³META  ³ Ordenada a ordem dos parametros nas fun- ³±±
±±³            ³        ³      ³ coes a200CoIn() e a200SkLt().            ³±±
±±³Paulo Emidio³18/05/01³META  ³Implementada a funcao qAtuMatQie(), que   ³±±
±±³            ³        ³      ³substitui a QaImpEnt() e o rdmake QIEA181 ³±±
±±³            ³        ³      ³na integracao Materiais x QIE e Importacao³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QIEA182()   
Local aDadosImp := {}
Local aRetQie   := {}

dbSelectArea("QEP")
dbSetorder(1)
dbSeek(xFilial("QEP"))
While !Eof() .And. QEP_FILIAL == xFilial("QEP")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados referentes a Importacao Normal						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
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
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a integracao Materiais x Inspecao de Entradas		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetQie := qAtuMatQie(aDadosImp,If(QEP_EXCLUI=="S",2,1))
			
	dbSelectArea("QEP")
	dbSetOrder(1)	
	dbSkip() 
	
EndDo

Return Nil