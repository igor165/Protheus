#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSCRD950.CH"
      
WSSTRUCT WScrdRetAberto
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

WSSTRUCT WSCRDItens
	WSDATA A		AS Boolean
	WSDATA B		AS Float
	WSDATA C		AS String
	WSDATA D   		AS String
	WSDATA E		AS String
	WSDATA F		AS String
	WSDATA G     	AS String
	WSDATA H     	AS String
	WSDATA I     	AS String
	WSDATA J		AS String
	WSDATA L     	AS String
	WSDATA M     	AS String
ENDWSSTRUCT

WSSTRUCT WSCRDArray
	WSDATA VerArray AS ARRAY OF WSCRDItens
ENDWSSTRUCT


WSSERVICE FRTBAIXACRD DESCRIPTION  STR0001 // "Servi�o de baixa da CRD"  

	WSDATA aCRDItens	AS WSCRDArray
	WSDATA nCRDUsada 	AS Float
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
	
	WSMETHOD FRTBXCRD DESCRIPTION STR0002 //"Metodo para realizar a baixa da CRD"
ENDWSSERVICE

WSSERVICE DELCRD DESCRIPTION  STR0003 //"Servi�o de delecao da CRD" 

	WSDATA cBxFilial	AS String
	WSDATA cBxDoc		AS String
	WSDATA cBxSerie		AS String
	WSDATA cBxCliente	AS String
	WSDATA cBxLoja		AS String
	WSDATA NADA 		AS Boolean
	
	WSMETHOD FRTDELCRD DESCRIPTION STR0004 // "Metodo para realizar a delecao da CRD"
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
WSMETHOD FRTBXcrd WSRECEIVE aCRDItens, cCodVale, nValor,  nTotPag, cOpc, nLinha WSSEND nCRDGerRet WSSERVICE FRTBAIXACRD




Local aVetor	:= {}								//CRD selecionadas//
Local nX		:= 0								//Contador de For
Local lRet		:= .T.
Local cMensagem := "0"
//��������������������
//�Recebe o aCRDitens�
//��������������������
For nX := 1 to Len( ::aCRDItens:VerArray )
	AAdd( aVetor, Array( 12 ))
	aVetor[nX][1] := ::aCRDItens:VerArray[nX]:A
	aVetor[nX][2] := ::aCRDItens:VerArray[nX]:B
	aVetor[nX][3] := ::aCRDItens:VerArray[nX]:C
	aVetor[nX][4] := ::aCRDItens:VerArray[nX]:D
	aVetor[nX][5] := ::aCRDItens:VerArray[nX]:E
	aVetor[nX][6] := ::aCRDItens:VerArray[nX]:F
	aVetor[nX][7] := ::aCRDItens:VerArray[nX]:G
	aVetor[nX][8] := ::aCRDItens:VerArray[nX]:H
	aVetor[nX][9] := ::aCRDItens:VerArray[nX]:I
	aVetor[nX][10]:= ::aCRDItens:VerArray[nX]:j
	aVetor[nX][11]:= ::aCRDItens:VerArray[nX]:L
	aVetor[nX][12]:= ::aCRDItens:VerArray[nX]:M
Next nX	


lRet := Crd240PesqVale( cCodVale, nValor, aVetor, nTotPag, cOpc, nLinha, @cMensagem, .F.)

::nCRDGerRet := Val(cMensagem)


Return(.T.)
