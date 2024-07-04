#INCLUDE "PROTHEUS.CH"        
#INCLUDE "MSOBJECT.CH"

Function LOJA1906E ; Return     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCCfgTefDirecao    �Autor  �VENDAS CRM  � Data �  29/10/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Carrega as configuracoes de TEF Direcao disponiveis para a��� 
���          �aplicacao.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCCfgTefDirecao

	Data cAppPath		// caminho da aplicacao
	Data cDirTx			// caminhos da envio
	Data cDirRx         // caminho de resposta
	Data lCCCD			// cartao de credito
	Data lCheque 		// chaque 
	Data oConFig        // configura��es  
	Data lInfAdm		//
	Data nVias			//Numero de vias
	
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
Method New() Class LJCCfgTefDirecao
 
	Self:cAppPath 	:= Space(200)
	Self:cDirTx 	:= Space(200)
	Self:cDirRx 	:= Space(200)
	Self:lCCCD		:= .F.
	Self:lCheque	:= .F.   
	Self:lInfAdm	:= .T.

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
Method Carregar(cAlias) Class LJCCfgTefDirecao
	
	Local lRet := .F.
	
	If Select(cAlias) > 0
		Self:cAppPath 	:= (cAlias)->MDG_DIRAPL
		Self:cDirTx 	:= AllTrim((cAlias)->MDG_DIRTX)
		Self:cDirRx 	:= AllTrim((cAlias)->MDG_DIRRX)
		Self:lCCCD		:= IIf((cAlias)->MDG_CARDIR=="1",.T.,.F.)
		Self:lCheque	:= IIf((cAlias)->MDG_CHQDIR=="1",.T.,.F.)
		lRet := .T.
	EndIf
	
	//���������������Ŀ
	//�Carrega cole��o�
	//�����������������
   	Self:oConFig := LJCConfiguracoesGer():New()	

	If	Self:lCCCD	.OR. Self:lCheque
		Self:nVias := STFGetStat( "TEFVIAS" )    
		//�����Ŀ
		//�DIRECAO�
		//�������
		oConFigGer := LJCConfiguracaoGer():New()
		oConFigGer:cAdmFin		:= 'DIRECAO'
		oConFigGer:cDirTx		:= Self:cDirTx
		oConFigGer:cDirRx      	:= Self:cDirRx
		oConFigGer:cAplicacao  	:= Self:cAppPath
		oConFigGer:lCheque   	:= Self:lCheque
		Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)
		
/*		//�����Ŀ
		//�DIRECAO�
		//�������
		oConFigGer := LJCConfiguracaoGer():New()
		oConFigGer:cAdmFin		:= 'AMEX'
		oConFigGer:cDirTx		:= Self:cDirTx
		oConFigGer:cDirRx      	:= Self:cDirRx
		oConFigGer:cAplicacao  	:= Self:cAppPath
		oConFigGer:lCheque   	:= Self:lCheque
		Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)
		
		//�����Ŀ
		//�DIRECAO�
		//�������
		oConFigGer := LJCConfiguracaoGer():New()
		oConFigGer:cAdmFin		:= 'CIELO'
		oConFigGer:cDirTx		:= Self:cDirTx
		oConFigGer:cDirRx      	:= Self:cDirRx
		oConFigGer:cAplicacao  	:= Self:cAppPath
		oConFigGer:lCheque   	:= Self:lCheque
		Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)
				
		//�����Ŀ
		//�DIRECAO�
		//�������
		oConFigGer := LJCConfiguracaoGer():New()
		oConFigGer:cAdmFin		:= 'VISANET'
		oConFigGer:cDirTx		:= Self:cDirTx
		oConFigGer:cDirRx      	:= Self:cDirRx
		oConFigGer:cAplicacao  	:= Self:cAppPath
		oConFigGer:lCheque   	:= Self:lCheque
		Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)		*/

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
Method Salvar(cAlias) Class LJCCfgTefDirecao

	Local lRet := .F.
		
	If Select(cAlias) > 0
		REPLACE  (cAlias)->MDG_DIRAPL	WITH Self:cAppPath 	
		REPLACE  (cAlias)->MDG_DIRTX	WITH Self:cDirTx 	
		REPLACE  (cAlias)->MDG_DIRRX	WITH Self:cDirRx 	
		REPLACE  (cAlias)->MDG_CARDIR	WITH IIf(Self:lCCCD,"1","2")		
		REPLACE  (cAlias)->MDG_CHQDIR	WITH IIf(Self:lCheque,"1","2")
		lRet := .T.
	EndIf

Return lRet