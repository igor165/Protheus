#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA7006; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadosVenPer   �Autor  �Vendas Clientes     � Data �  15/10/2010 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular o movimento de venda perdida     	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCDadosVenPer

	Data nItem
	Data cMovi
	Data cMotivo
	Data cNumOrc
	Data cProd
	Data nQtde
	Data cJust
	Data lDisp
	Data dEnvio          
	Data lAtivo 
	Data cLoja
	Data cVend
	Data cCodcli
	Data dEmissao    
	
	Method New()

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data � 27/09/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDadosVenPer. 				          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
���          �  			      										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cMovi	,cMotivo,	cNumOrc,cProd,;
			nItem	,nQtde	,	cJust,	lDisp,;
			dEnvio	,cLoja,		cVend,	cCodcli,;
			dEmissao) Class LJCDadosVenPer

	Default cMovi	:= ""		// Codigo de movimento
	Default cMotivo	:= ""		// Codigo de motivo
	Default cNumOrc	:= ""		// Codigo de numero orcamento
	Default cProd	:= ""		// Codigo de produto
	Default nItem	:= 0  		// numero do item
	Default nQtde	:= 0		// quantidade	
	Default cJust	:= ""		// justificativa
	Default lDisp	:= .F.		// aviso de disponibilidade
	Default dEnvio	:= ""		// data de envio do aviso de disponibilidade
	Default cLoja	:= ""		// loja
 	Default cVend	:= ""		// vendedor
 	Default cCodcli := ""		// codigo do cliente 
 	Default dEmissao:= ""		// data de emissao do orcamento	 	
 	
	Self:cMovi		:= cMovi
	Self:cMotivo	:= cMotivo
	Self:cNumOrc	:= cNumOrc
	Self:cProd		:= cProd
	Self:nItem		:= nItem
	Self:nQtde		:= nQtde
	Self:cJust		:= cJust
	Self:lDisp		:= lDisp
	Self:dEnvio		:= dEnvio          
	Self:lAtivo		:= .T.  		
	Self:cLoja		:= cLoja
	Self:cVend 		:= cVend
	Self:cCodcli 	:= cCodcli
	Self:dEmissao 	:= dEmissao	                                                   

Return()                                                                            

