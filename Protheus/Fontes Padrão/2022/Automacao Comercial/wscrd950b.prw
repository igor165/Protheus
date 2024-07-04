#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSCRD950B.CH"

WSSTRUCT LSVC 
	WSDATA Valor 		AS Float 
	WSDATA Validade		AS Date
	WSDATA Ret 		    AS Boolean
ENDWSSTRUCT 

WSSTRUCT DadVale 
	WSDATA CodVale 		AS String 
	WSDATA Valor 		AS Float 
	WSDATA Validade		AS Date
	WSDATA Ret 		    AS Boolean
ENDWSSTRUCT

WSSTRUCT RECARRAY 
	WSDATA VERARRAY		AS Array of DadVale 
ENDWSSTRUCT


WSSERVICE FRTCRDPSVPG DESCRIPTION STR0003 //"Servi�o de Pesquisa e Atualiza��o de Status de Vale compra no Pagamento"
           						   	    
	WSDATA cVale	AS String  
	WSDATA CrdLSVC	AS Array of LSVC
	WSDATA Vales	AS RECARRAY	    
	WSDATA Ret		AS Boolean
	
	WSMETHOD CrdPSVcPg   DESCRIPTION STR0002 // "Retorno de pesquisa"  
	WSMETHOD CrdUpdMAV   DESCRIPTION STR0004 // "Atualiza Status do Vale Compra"                      

ENDWSSERVICE

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 �CrdPSVcPg � Autor � Venda Clientes        � Data �24/04/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Servico de Pesquisa de Vale compra no Pagamento.			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Codigo do Vale Compra.                             ���

�������������������������������������������������������������������������Ĵ��
���Retorno	 � ExpA1 - Dados do Vale Compra (nValor, dValidade).	      ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FrontLoja												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD CrdPSVcPg WSRECEIVE cVale WSSEND CrdLSVC WSSERVICE FRTCRDPSVPG

Local nValor		:= 0
Local dValidade
Local lRet 			:= .T.

AAdd(::CrdLSVC,WSClassNew("LSVC"))

lRet := Crd240ValidUsoVale( cVale, "2", @nValor, @dValidade )

::CrdLSVC[1]:Valor 		:= nValor 
::CrdLSVC[1]:Validade	:= dValidade
::CrdLSVC[1]:Ret 		:= lRet


Return(.T.)
//GERACAO PACOTE PAF-ECF 06/08/2010

//GERACAO PACOTE PAF-ECF 12/08/2010
           
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 � CrdUpdMAV� Autor � Venda Clientes        � Data �12/01/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza Status do Vale Compra.							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array com Vales Compra e seus respectivos dados.   ���
���			 � (cCodVale,nValor,dValidade)					              ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � ExpL1 -                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FrontLoja												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD CrdUpdMAV WSRECEIVE Vales WSSEND Ret WSSERVICE FRTCRDPSVPG

Local lRet 		:= .T. 
Local nX		:= 0
Local aVales	:= Array(Len(Vales:VERARRAY)) 

For nX:=1 To Len(Vales:VERARRAY)

	aVales[nX] := Array(04)
	
	aVales[nX][1] := Vales:VERARRAY[nX]:CodVale
	aVales[nX][2] := Vales:VERARRAY[nX]:Valor
	aVales[nX][3] := Vales:VERARRAY[nX]:Validade
	aVales[nX][4] := Vales:VERARRAY[nX]:Ret
Next nX

lRet := Crd240UpdMAV( aVales, "3",, .T. )	

Return(lRet)