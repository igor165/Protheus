#INCLUDE "PROTHEUS.CH"     

Function LOJA1946 ; Return                

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJADadosTransacaoCCCD �Autor�VENDAS CRM� Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Armazena as informacoes para realizacao de uma transacao  ��� 
���          �utilizando TEF.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJADadosTransacaoCCCD From LJADadosTransacao
    
	Data cFormaPgto														//Codigo da forma
   	Data cDescPgto														//Descricao da forma
   	Data cAdmFin														//Administradora financeira
   	Data lCarManual												      	//Se a transacao vai ser com cartao digitado
   	Data nIdCartao														//Id do cartao
	
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
Method New(	nValor, 	nCupom, 	dData, 		cHora, ;
			cFormaPgto, cDescPgto, 	cAdmFin, 	lCarManual, ;
			nIdCartao, 	nTipoTrans,	lUltimaTrn,	cRede) Class LJADadosTransacaoCCCD 

	_Super:New(nValor, nCupom, dData, cHora, nTipoTrans, lUltimaTrn, cRede)
	
	Self:cFormaPgto:=  cFormaPgto
	Self:cDescPgto	:= cDescPgto
	Self:cAdmFin 	:= cAdmFin
	Self:lCarManual	:= lCarManual
	Self:nIdCartao	:= nIdCartao

Return Self 