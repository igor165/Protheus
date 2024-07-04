#INCLUDE "PROTHEUS.CH"        
#INCLUDE "MSOBJECT.CH"

Function LOJA1906D ; Return     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCCfgTefPayGo    �Autor  �VENDAS CRM  � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Carrega as configuracoes de TEF PayGo disponiveis para a  ��� 
���          �aplicacao.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCCfgTefPayGo

	Data cAppPath		// caminho da aplicacao
	Data cDirTx			// caminhos da envio
	Data cDirRx         // caminho de resposta
	Data lCCCD			// cartao de credito
	Data lCheque 		// chaque 
	Data oConFig        // configura��es   
	Data lInfAdm		//Informa a Administradora? 
	Data nVias			//Numero de Vias
	
	Method New()
	Method Carregar()
	Method Salvar()

EndClass                

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCCfgTefPayGo
 
	Self:cAppPath 	:= Space(200)
	Self:cDirTx 	:= Space(200)
	Self:cDirRx 	:= Space(200)
	Self:lCCCD		:= .F.
	Self:lCheque	:= .F.   
	Self:lInfAdm	:= .T.
	Self:nVias		:= 0

Return Self     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Carregar     �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega as configuracoes de TEF disponiveis.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Carregar(cAlias) Class LJCCfgTefPayGo
	
	Local lRet := .F.
	
	If Select(cAlias) > 0
		Self:cAppPath 	:= (cAlias)->MDG_PAYAPL
		Self:cDirTx 	:= AllTrim((cAlias)->MDG_PAYTX)
		Self:cDirRx 	:= AllTrim((cAlias)->MDG_PAYRX)
		Self:lCCCD		:= IIf((cAlias)->MDG_CARPAY=="1",.T.,.F.)
		Self:lCheque	:= IIf((cAlias)->MDG_CHQPAY=="1",.T.,.F.)
		lRet := .T.
	EndIf
	
	//���������������Ŀ
	//�Carrega cole��o�
	//�����������������
   	Self:oConFig := LJCConfiguracoesGer():New()	

	If	Self:lCCCD	.OR. Self:lCheque  
	    Self:nVias := STFGetStat( "TEFVIAS" ) 
		//�����Ŀ
		//�PAYGO�
		//�������
		oConFigGer := LJCConfiguracaoGer():New()
		oConFigGer:cAdmFin		:= 'PAYGO'
		oConFigGer:cDirTx		:= Self:cDirTx
		oConFigGer:cDirRx      	:= Self:cDirRx
		oConFigGer:cAplicacao  	:= Self:cAppPath
		oConFigGer:lCheque   	:= Self:lCheque
		Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)   		

    EndIf



Return lRet   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Salvar       �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Salva as configuracoes de TEF disponiveis.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Salvar(cAlias) Class LJCCfgTefPayGo

	Local lRet := .F.
		
	If Select(cAlias) > 0
		REPLACE  (cAlias)->MDG_PAYAPL	WITH Self:cAppPath 	
		REPLACE  (cAlias)->MDG_PAYTX	WITH Self:cDirTx 	
		REPLACE  (cAlias)->MDG_PAYRX	WITH Self:cDirRx 	
		REPLACE  (cAlias)->MDG_CARPAY	WITH IIf(Self:lCCCD,"1","2")		
		REPLACE  (cAlias)->MDG_CHQPAY	WITH IIf(Self:lCheque,"1","2")
		lRet := .T.
	EndIf

Return lRet