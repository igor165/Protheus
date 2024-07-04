#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFTEF.CH"

Function LOJA1952 ; Return                     

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������ͻ��
���Programa  �LJCDadosTransacaoDebitoPreDatado  �Autor�VENDAS CRM� Data �  29/10/09   ���
�������������������������������������������������������������������������������������͹��
���Desc.     �  Armazena as informacoes para realizacao de uma transacao              ��� 
���          �utilizando TEF.                                                         ���
�������������������������������������������������������������������������������������͹��
���Uso       � MP10                                                                   ���
�������������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������     
*/
Class LJCDadosTransacaoDebitoPreDatado From LJADadosTransacaoCCCD 

	Data dDataVcto														//Data de vencimento

	Method New() Constructor 

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
Method New(nValor,		nCupom,		dData,		cHora,;
		   cFormaPagto, cDescPagto, cAdmFin, 	lCarManual, ;
		   nIdCartao, 	dDataVcto, 	lUltimaTrn, cRede) Class LJCDadosTransacaoDebitoPreDatado 

	_Super:New(nValor, nCupom, dData, cHora, cFormaPagto, cDescPagto, cAdmFin, lCarManual, nIdCartao, _DEBITOPREDATADO, lUltimaTrn, cRede)        
	
	Self:dDataVcto := dDataVcto

Return Self 