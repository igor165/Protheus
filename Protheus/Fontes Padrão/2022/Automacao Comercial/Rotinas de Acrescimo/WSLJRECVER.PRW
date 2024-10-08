#INCLUDE "PROTHEUS.CH"                  
#INCLUDE "APWEBSRV.CH"            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetRecVer �Autor  �Danilo Calil        � Data � 05/06/2006  ���
�������������������������������������������������������������������������͹��
���Desc.     �WS para executar as operacoes de recebimento	  			  ���
�������������������������������������������������������������������������͹��
���Uso       �Interfaces de Venda                                         ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSSTRUCT WSAnalise
	WSDATA Marcado 	AS Boolean
	WSDATA Contrato	AS String
	WSDATA Prefixo 	AS String
	WSDATA Titulo  	AS String
	WSDATA Parcela  AS String
	WSDATA Filial   AS String
	WSDATA VlrAcr 	AS Float
	WSDATA Cliente  AS String
	WSDATA Loja  	AS String
	WSDATA Vencto  	AS Date
ENDWSSTRUCT

WSSTRUCT WSNewArray
	WSDATA VerArray AS ARRAY OF WSAnalise
ENDWSSTRUCT

WSSTRUCT WSRetAnalise
	WSDATA Verdade 	AS Boolean
	WSDATA Contrato	AS String         
ENDWSSTRUCT
	
WSSERVICE AnalisaRec DESCRIPTION  "Servi�o de identifica��o de parcelas" 
	WSDATA aAnaliseRet		AS ARRAY OF WSRetAnalise
	WSDATA aAnalise	   		AS WSNewArray

	WSMETHOD GetRecVer DESCRIPTION "M�todo que consulta a condicao de pagamento"
ENDWSSERVICE

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetRecVer �Autor  �Danilo Calil        � Data � 05/06/2006  ���
�������������������������������������������������������������������������͹��
���Desc.     �WS para executar as operacoes de recebimento	  			  ���
�������������������������������������������������������������������������͹��
���Uso       �Interfaces de Venda                                         ���
�������������������������������������������������������������������������Ĵ��
��� Progr.   � Data     BOPS   Descricao								  ���
�������������������������������������������������������������������������Ĵ��
���Danilo Cal�04/07/06�102617�Realiza busca no SE1 antes de validar aVerOk���
���Danilo Cal�04/07/06�103046�Retirada busca no SE1                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

WSMETHOD GetRecVer WSRECEIVE aAnalise WSSEND aAnaliseRet WSSERVICE AnalisaRec
 
Local aRet		:= {}					//Retorno da funcao
Local aVerOk	:= {}					//Contratos a serem verificados
Local nX		:= 0					//Contador de Loop

For nX := 1 to Len( ::aAnalise:VerArray )
	AAdd( aVerOk, Array( 10 ))
	aVerOk[nX][1] := ::aAnalise:VerArray[nX]:Marcado
	aVerOk[nX][2] := ::aAnalise:VerArray[nX]:Contrato
	aVerOk[nX][3] := ::aAnalise:VerArray[nX]:Prefixo
	aVerOk[nX][4] := ::aAnalise:VerArray[nX]:Titulo
	aVerOk[nX][5] := ::aAnalise:VerArray[nX]:Parcela
	aVerOk[nX][6] := ::aAnalise:VerArray[nX]:Filial
	aVerOk[nX][7] := ::aAnalise:VerArray[nX]:VlrAcr
	aVerOk[nX][8] := ::aAnalise:VerArray[nX]:Cliente
	aVerOk[nX][9] := ::aAnalise:VerArray[nX]:Loja
	aVerOk[nX][10]:= ::aAnalise:VerArray[nX]:Vencto
Next nX	

aRet := WSLJRVERIF( aVerOk )

If Len(aRet) > 0                                     
	For nX := 1 To Len(aRet)    
		AAdd( ::aAnaliseRet, WSClassNew("WSRetAnalise") )	
		::aAnaliseRet[nX]:Verdade 	:= aRet[nX][1]
		::aAnaliseRet[nX]:Contrato	:= aRet[nX][2]
	Next nX
EndIf

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LjRVerif  �Autor  �Danilo Calil        � Data �  24/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao que marca os titulos que podem entrar no conceito   ���
���          � do cliente Dadalto. Marca a primeira posicao do aTitulos c/���
���          � .T.                                                        ���
�������������������������������������������������������������������������͹��
���Parametros� ExpA1 - Array com os titulos                               ���
�������������������������������������������������������������������������͹��
���Retorno   � ExpA1 - Array com os titulos alterados                     ���
�������������������������������������������������������������������������͹��
���Uso       � FRONT LOJA - RECEBIMENTOS                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function WsLJRVerif( aVerOk  )

Local aArea 		:= GetArea()							//GetArea
Local aAreaSX2 		:= SX2->(GetArea())					//Area do SE1
Local aAreaSF2 		:= SF2->(GetArea())					//Area do SE4
Local aAreaSE4 		:= SE4->(GetArea())					//Area do SE4
Local cF2FormPg		:= ""									//Forma de pagamento
Local nX			:= 0									//Contador de For
Local cAliasF2		:= "SF2"								//Alias SF2
Local cFilialSF2	:= ""									//Filial do SF2
Local lAchou 		:= .F.									//Controle de Loop do While
Local cMvFiliais	:= SuperGetMV("MV_FILACRS",,"01")   	//Filiais que trabalham com o conceito de acrescimo.
Local lUsaAcrsSp    := 	.F.									//Verifica usa conceito de acrescimo separado
Local lR5           := GetRpoRelease("R5")    				//Indica se o release e 11.5

If (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
	lUsaAcrsSp := .T.
Endif
For nX := 1 To Len(aVerOk)
	If aVerOk[nX][6] $ cMvFiliais .OR. lUsaAcrsSp
		DbSelectArea("SX2")
		DbSetOrder(1)
		MsSeek(cAliasF2)
		
		If FWModeAccess(FWX2Chave(),3) == "E"
			cFilialSF2 := aVerOk[nX][6] 
		Else
			cFilialSF2 := xFilial(cAliasF2)     
		EndIf
		//����������������������������������������������������Ŀ
		//�Verifica se eh o primeiro titulo e se trabalha com o�
		//�conceito de acrescimo.                              �
		//������������������������������������������������������
		If aVerOk[nX][7] > 0
		   	DbSelectArea("SF2")
			DbSetOrder(2) //F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE
			If MsSeek(	cFilialSF2 + aVerOk[nX][8] + aVerOk[nX][9] + aVerOk[nX][4] + ;
						aVerOk[nX][3])
			    While !EOF() .AND. cFilialSF2 + aVerOk[nX][8] + aVerOk[nX][9] + aVerOk[nX][4] ==;
					SF2->F2_FILIAL + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC .AND. !lAchou
					If SF2->F2_PREFIXO == aVerOk[nX][3]
						lAchou := .T.
					EndIf
				End
				If lAchou
					cF2FormPg := SF2->F2_COND
					DbSelectArea("SE4")
					DbSetOrder(1)//E4_FILIAL + E4_CODIGO					
					If MsSeek( xFilial("SE4") + cF2FormPg) //E4_FILIAL + E4_CODIGO
						If ((dDataBase + SE4->E4_LIMACRS) <= aVerOk[nX][10]) .AND. SE4->E4_LIMACRS > 0              
							aVerOk[nX][1] := .T.
						EndIf
					EndIf
		   		EndIf
		   	EndIf
		EndIf
	EndIf
Next nX
	
RestArea(aAreaSX2)
RestArea(aAreaSF2)
RestArea(aAreaSE4)
RestArea(aArea)

Return (aVerOk)
