#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LJRECVER.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJRECVER  �Autor  �Danilo Calil        � Data �  24/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada que verifica se o E4_AGRACRS est� habili- ���
���          � tado, se o E4_LIMACRS tem informacao. Caso sim, modifica o ���
���          � aTitulos somente o valor com o acrescimo.                  ���
�������������������������������������������������������������������������͹��
���Parametros� ExpA1 - aTitulos de entrada pelo Paramixb  	              ���
�������������������������������������������������������������������������͹��
���Retorno   � ExpA1 - aTitulos alterado                                  ���
�������������������������������������������������������������������������͹��
���Uso       � FRONT LOJA - RECEBIMENTOS                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function LJRECVER()

Local aTitulo		:= Paramixb[1]							//Array com os titulos a receber do cliente
Local cMv1Dup		:= SuperGetMV("MV_1DUP")				//Como esta as sequencias das duplicatas
Local cF2FormPg		:= ""									//Forma de pagamento
Local nX			:= 0									//Contador de For
Local nI			:= 0
Local cAliasF2		:= "SF2"								//Alias SF2
Local cFilialSF2	:= ""									//Filial do SF2
Local aContrato		:= {}									//Contratos
Local oSvc													//WebService
Local aRetContr		:= {}									//Retorno do WebService
Local lRet			:= .F.									//Retorno do WebService

//    aTitulo           aContrato
//����������������Ŀ����������������Ŀ
//�2-  Prefixo     ��2-  Contrato    �
//�3-  NumTitulo   ��3-  Prefixo     �
//�4-  Parcela     ��4-  NumTitulo   �
//�5-  Vencimento  ��5-  Parcela     �
//�6-  Valor       ��6-  FilTit      �
//�7-  VlrMulta    ��7-  VlsAcres    �
//�8-  VlrJuros    ��8-  Cliente     �
//�9-  VlrDesconto ��9-  Loja        �
//�10- VlrRecebido ��10- Vencimento  �
//�11- Tipo        �������������������
//�12- Contrato    �                    
//�13- Cliente     �                    
//�14- Loja        �                     
//�15- FilTit      �                    
//�16- NumRecno    �
//�17- VlrAcres    �
//�18- Conceito    �
//������������������

If Len(aTitulo) > 0
	For nX := 1 To Len(aTitulo)
		If cMv1Dup == aTitulo[nX][4] 
			Aadd(	aContrato,{	.F., 				aTitulo[nX][12],	aTitulo[nX][2],		aTitulo[nX][3],;
								aTitulo[nX][4],		aTitulo[nX][15],	aTitulo[nX][17],	aTitulo[nX][13],;
								aTitulo[nX][14],	aTitulo[nX][5]})
		EndIf
		aTitulo[nX][10]	:= aTitulo[nX][6] + aTitulo[nX][17]
	Next nX
EndIf

If Len(aContrato) > 0
    
	//����������������������������Ŀ
	//� Cria o metodo WSANALISAREC �
	//������������������������������
	oSvc := WSANALISAREC():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autentica��o do Web Service
	oSvc :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/ANALISAREC.apw"	
	     
	//�������������������������������Ŀ
	//� Cria o array dentro do metodo �
	//���������������������������������
	oSvc:OWSAANALISE:OWSVERARRAY 					:= ANALISAREC_ARRAYOFWSANALISE():New()
	oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE 		:= Array( Len(aContrato) )

	//���������������������������������������������Ŀ
	//�Antes de chamar o metodo, atribui os valores �
	//�as propriedades (passagem de parametros)     �
	//�����������������������������������������������

	For nX := 1 To Len(aContrato)

		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX] := ANALISAREC_WSANALISE():New()
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:LMARCADO	:=	aContrato[nX][1]	
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CCONTRATO	:=	aContrato[nX][2]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CPREFIXO	:=	aContrato[nX][3]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CTITULO	:=	aContrato[nX][4]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CPARCELA	:=	aContrato[nX][5]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CFILIAL	:=	aContrato[nX][6]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:NVLRACR	:=	aContrato[nX][7]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CCLIENTE	:=	aContrato[nX][8]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CLOJA		:=	aContrato[nX][9]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:DVENCTO	:=	aContrato[nX][10]
	Next nX

	//"Aguarde...Verificando prazo..."
	LJMsgRun( STR0001,, { || lRet := oSvc:GETRECVER() } ) 
                                                                 
	If !lRet 
		cSvcError := GetWSCError()
		If Left(cSvcError,9) == "WSCERR048"					
			cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
			Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
		Else
			//"Sem comunica��o com o WebService!"+"Atencao"
			MsgStop(STR0002,STR0003)
		EndIf
	Else

		For nX := 1 to Len( oSvc:oWSGETRECVERRESULT:oWSWSRETANALISE )
			aAdd( aRetContr, { oSvc:oWSGETRECVERRESULT:oWSWSRETANALISE[nX]:LVERDADE, oSvc:oWSGETRECVERRESULT:oWSWSRETANALISE[nX]:CCONTRATO } )
		Next nX 
	Endif

	If Len(aRetContr) > 0
		For nX := 1 To Len(aRetContr)
			If aRetContr[nX][1]
				aEval( aTitulo,{|x| IIf(x[12] == aRetContr[nX][2],x[18] := .T.,"")})
			EndIf
		Next nX
	EndIf
EndIf	

Return(aTitulo)