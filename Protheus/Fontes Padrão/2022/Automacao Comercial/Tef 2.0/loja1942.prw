#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1942 ; Return                     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJADadosTransacao �Autor  �VENDAS CRM  � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Armazena as informacoes para realizacao de uma transacao    ��� 
���          �utilizando TEF.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJADadosTransacao

	Data nValor														//Valor da transacao
   	Data nCupom														//Numero de identificacao da transacao
   	Data dData														//Data da transacao
   	Data cHora														//Hora da transacao
	Data nTipoTrans													//Tipo da transacao utilizado o DEFTEF.CH 
	Data lUltimaTrn                                                 //Ultima transacao - Utilizada para o gerenciador Direcao
	Data cRede														//Rede da Transacao
	Data oRetorno													//Objeto do tipo LJATransacaoTef
	Data nParcela													//Numero de parcelas para vendas parceladas
	Data dDataVcto  												//Data da transacao de pre-datado	
	
	Method New()
	Method Retorno()

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
Method New(	nValor, 		nCupom, 		dData, cHora, ;
			nTipoTrans,		lUltimaTrn,		cRede) Class LJADadosTransacao 
			
			
	Default lUltimaTrn := .T. //Valida apenas para gerenciador Direcao
	
	Self:nValor		:= nValor
	Self:nCupom		:= nCupom
	Self:dData		:= dData
	Self:cHora		:= cHora
	Self:nTipoTrans	:= nTipoTrans
	Self:lUltimaTrn	:= lUltimaTrn   
	Self:oRetorno 	:= Nil   
	Self:cRede		:= cRede
	Self:nParcela	:= 0
	Self:dDataVcto	:=	CtoD("  /  /  ")          

Return Self 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Retorno      �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Obtem o retorno da classe.                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Retorno() Class LJADadosTransacao
Return Self:oRetorno 
