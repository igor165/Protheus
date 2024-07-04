#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSPROSC  �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa solicitacao de carteirinha						  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PLSPROSC()
LOCAL cMatric  	:= paramixb[1] 
LOCAL cMotCar  	:= paramixb[2] 
LOCAL aRet 	  	:= {.T.,{}}
LOCAL lImp	  	:= .F.
LOCAL lWeb	  	:= .T.
LOCAL xResult 	:= {}  
LOCAL aRetv		:= {} 
	
aRetv := PLSA261INC(SubStr(cMatric,1,4),cMatric,Iif( !Empty(cMotCar),cMotCar,'5'),lImp,,lWeb) 

If !aRetv[1]
	aRet[2] := aRetv[3]
	aRet[1] := aRetv[1]
Else 
	xResult	:=	aRetv[3][2]
	aRet[2] := 	xResult
EndIf


//����������������������������������������������������������������
//� Fim da Funcao
//����������������������������������������������������������������
Return(aRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSPROBEN �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa registro de inclusao de beneficiario				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PLSPROBEN()	
LOCAL aDadBen := paramixb[1] 
LOCAL aRet 	  := {.T.,{}}
LOCAL nI   	  := 0          
LOCAL cCampo  := ""
LOCAL cValor  := ""
LOCAL xResult := {}
/*
Exemplo para devolver nao processado
AaDd( xResult, {"100","Processamento comproblema - 1"} )
AaDd( xResult, {"200","Processamento comproblema - 2"} )
AaDd( xResult, {"300","Processamento comproblema - 3"} )
AaDd( xResult, {"400","Processamento comproblema - 4"} )

aRet[2] := xResult;

Exemplo para devolver processado
*/
xResult := "Numero do protocolo [10101001]"
aRet[2] := xResult;
//����������������������������������������������������������������
//� Gravar registros
//����������������������������������������������������������������
For nI:=1 To Len(aDadBen)
	cCampo := aDadBen[nI,1]
	cValor := aDadBen[nI,2]
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Gravar na tabela espelho-> ["+cCampo+"] - ["+cValor+"]" , 0, 0, {})
Next
//����������������������������������������������������������������
//� Fim da Funcao
//����������������������������������������������������������������
Return(aRet)
