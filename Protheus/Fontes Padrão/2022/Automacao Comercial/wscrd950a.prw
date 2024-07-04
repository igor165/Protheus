#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSCRD950A.CH"      

WSSTRUCT WScrdRetBX
	WSDATA Seleciona	AS Boolean
	WSDATA Saldo		AS Float
	WSDATA NumTitulo	AS String
	WSDATA DataCRD   	AS Date			
	WSDATA NumRecno		AS Integer
	WSDATA Saldo2		AS Float
	WSDATA MvMoeda     	AS String
	WSDATA Moeda     	AS Integer
	WSDATA Prefixo     	AS String
	WSDATA Parcela		AS String
	WSDATA Tipo     	AS String
ENDWSSTRUCT

WSSTRUCT WSCRDVABX
	WSDATA CRDPre1		AS Float
	WSDATA CRDPre2		AS String
	WSDATA CRDPre3		AS String
	WSDATA CRDPre4		AS String
	WSDATA CRDPre5		AS Float
	WSDATA CRDPre6		AS Float
	WSDATA CRDPre7		AS Float
ENDWSSTRUCT

WSSTRUCT WSCRDArrBX
	WSDATA VerArrBX AS ARRAY OF WSCRDVABX
ENDWSSTRUCT


WSSERVICE FRTCRDBX DESCRIPTION  STR0001 //"Servi�o de Resgate de Vale Compra"  

	WSDATA aCRDValeC	AS WSCRDArrBX
	WSDATA nCRDUsada 	AS Float
	WSDATA nUsado	 	AS Float 
	WSDATA cMotivo		AS String 	
	WSDATA nCRDGerada 	AS Float
	WSDATA cL1Doc 		AS String
	WSDATA cL1Serie 	AS String
	WSDATA cL1Oper 		AS String
	WSDATA dL1EmisNf	AS Date
	WSDATA cL1Cliente	AS String
	WSDATA cL1Loja		AS String
	WSDATA nL1Credit	AS Float
	WSDATA cSerEst		AS String
	WSDATA cCodVale  	AS String
	WSDATA nValor		AS Float
	WSDATA nTotPag 		AS Float
	WSDATA cOpc         AS String
	WSDATA nLinha 		AS Integer
	WSDATA nCRDGerRet	AS Float
	
	WSMETHOD FRTCRD02  DESCRIPTION STR0002 //"Metodo para realizar a baixa de Vale Compras"
ENDWSSERVICE

WSSERVICE DELCRDX DESCRIPTION  STR0003 //"Servi�o de delecao da CRD" 

	WSDATA cBxFilial	AS String
	WSDATA cBxDoc		AS String
	WSDATA cBxSerie		AS String
	WSDATA cBxCliente	AS String
	WSDATA cBxLoja		AS String
	WSDATA NADA 		AS Boolean
	
	WSMETHOD FRTDELCRD DESCRIPTION STR0004 //"Metodo para realizar a delecao da CRD"
ENDWSSERVICE



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 �FRTBXCRD  � Autor � Venda Clientes        � Data �22/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a baixa das CRDs selecionadas           			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - CRDs da venda        							  ���
���          � ExpN2 - CRD a baixar         							  ���
���          � ExpN3 - CRD a gerar          							  ���
���          � ExpC4 - Doc da venda         							  ���
���          � ExpC5 - Serie da venda       							  ���
���          � ExpC6 - Operador da venda    							  ���
���          � ExpD7 - Data de emissao      							  ���
���          � ExpC8 - Cliente da venda     							  ���
���          � ExpC9 - Loja da venda        							  ���
���          � ExpN10 - Credito utilizado    							  ���
���          � ExpC11 - Serie a gerar        							  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � .T.                   						              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FrontLoja												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//WSMETHOD FRTCRD02 WSRECEIVE aCRDValeC, cCodVale, nValor,  nTotPag, cOpc, nLinha WSSEND nCRDGerRet WSSERVICE  FRTCRDBX
WSMETHOD FRTCRD02 WSRECEIVE aCRDValeC, cL1Cliente, cL1Loja, nUsado, cL1Doc,	cL1Serie, cMotivo   WSSEND nCRDGerRet WSSERVICE  FRTCRDBX
																												 		
Local aVales	:= {}								//CRD selecionadas//
Local nX		:= 0								//Contador de For
conout("Baixa")
//��������������������
//�Recebe o aCRDValeC�
//��������������������
For nX := 1 to Len( ::aCRDValeC:VerArrBX )
	conout("Baixa1")
	AAdd( aVales, Array( 12 ))
	conout("add aVales 1 ")
	aVales[nX][1] := ::aCRDValeC:VerArrBX[nX]:CRDPRE1
	conout("add aVales 2 ")
	aVales[nX][2] := ::aCRDValeC:VerArrBX[nX]:CRDPRE2
	aVales[nX][3] := ::aCRDValeC:VerArrBX[nX]:CRDPRE3
	aVales[nX][4] := ::aCRDValeC:VerArrBX[nX]:CRDPRE4
	aVales[nX][5] := ::aCRDValeC:VerArrBX[nX]:CRDPRE5
	aVales[nX][6] := ::aCRDValeC:VerArrBX[nX]:CRDPRE6
	aVales[nX][7] := ::aCRDValeC:VerArrBX[nX]:CRDPRE7

	Crd240GrvMaz( "", aVales[nX][4] , cMotivo, "1" )

Next nX	

conout("Crd240FinRes")
Crd240FinRes(	cL1Cliente,	cL1Loja, aVales, nUsado,;
						cL1Doc,		cL1Serie )

Return(.T.)
