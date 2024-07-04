#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFTEF.CH"

Function LOJA1948 ; Return                     

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������ͻ��
���Programa  �LJCDadosTransacaoCreditoParcelado �Autor�VENDAS CRM� Data �  29/10/09   ���
�������������������������������������������������������������������������������������͹��
���Desc.     �  Armazena as informacoes para realizacao de uma transacao              ��� 
���          �utilizando TEF.                                                         ���
�������������������������������������������������������������������������������������͹��
���Uso       � MP10                                                                   ���
�������������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������     
*/
Class LJCDadosTransacaoCreditoParcelado From LJADadosTransacaoCCCD 

	Data lFinanProp														//Identifica se o financiamento eh proprio
   	Data nParcela														//Numero de parcelas
	
	Method New()

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
Method New(nValor, 		nCupom, 	dData, 		cHora, ;
		  cFormaPagto, 	cDescPagto, cAdmFin, 	lCarManual, ;
		  nIdCartao, 	nParcela, 	lFinanProp,	lUltimaTrn,;
		  cRede) Class LJCDadosTransacaoCreditoParcelado 

	_Super:New(nValor, nCupom, dData, cHora, cFormaPagto, cDescPagto, cAdmFin, lCarManual, nIdCartao, _CREDITOPARCELADO, lUltimaTrn, cRede)

	Self:lFinanProp	:= lFinanProp
	Self:nParcela	:= nParcela

Return Self 