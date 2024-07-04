#include "protheus.ch"
#include "totvsbio.ch"
Static	nHnd := -1
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  � BioIsActive� Autor � PLS			         � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se esta ativo ou nao		                 		 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioIsActive()
If Type("__BioActive") <> "L"
	public __BioActive := .T.
EndIf
//������������������������������������������������������������������������Ŀ
//�verifica parametro primeiro											   �
//��������������������������������������������������������������������������
If ! SuperGetMv("MV_BIOCONF",,.F.)
	Return .t.
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return __BioActive
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioSetActive� Autor � PLS			         � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Ativa e desativa o dispositivo biometrico (somente na tread)	 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioSetActive(lActive)
__BioActive := lActive
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioVorCFingers� Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida caso exista ou cadastra as digitais					 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioVorCFingers(cAlias,cId)
Local aAreaBIO := BIO->(GetArea("BIO"))
Local lRet := .T.
Local aBio :={}

If ! BioIsActive()
  	Return .t.
EndIf
BIO->(DbSetOrder(1))
If BIO->(DbSeek(xFilial("BIO")+cAlias+Padr(cId,8)))
		If GetNewPar("MV_BIONEW",.F.)
			lRet := BioVldDigitalDbNew(cAlias,cId)
		Else
			lRet := BioVldFingerDB(cAlias,cId)
		EndIf
ElseIf GetNewPar("MV_BIONEW",.F.)
	If APMsgYesNo(STR0001,STR0002)//"N�o h� cadastro das digitais para consist�ncia, deseja cadastrar as digitais agora?" - "Aten��o"
		aBio := BioGetAllFingersNew(cAlias,cId)
		lRet := aBio[2]
	Else
	    lRet := .T.
	EndIf
Else
	If APMsgYesNo(STR0001,STR0002)//"N�o h� cadastro das digitais para consist�ncia, deseja cadastrar as digitais agora?" - "Aten��o"
		aBio := BioGetHandFingers(cAlias,cId)
		lRet := aBio[2]
	Else
	    	lRet := .F.
	EndIf
Endif

RestArea(aAreaBIO)
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return lRet
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioVldFingerDB� Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Validar digital comparando com cadastrado no banco 			 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioVldDigitalDbNew(cAlias,cId,lmsg)
Local aDigitais:={}
Local lRet := .f.
Local aAreaBIO := BIO->(GetArea("BIO"))
Default lmsg:= .t.
If ! BioIsActive()
	Return .t.
EndIf

aDigitais := CarDigitais(cId,cAlias)

If Len(aDigitais) == 0
	If lMsg
	  	MsgStop(STR0003)//"N�o Existem Digitais Cadastradas"
	  	RestArea(aAreaBIO)
	  	Return .F.
	EndIf
EndIf

RestArea(aAreaBIO)

nRet := BioChkDigitalNew(cAlias,cID,aDigitais)

If nRet == 0
	If lMsg
	  	If MsgYesNo(STR0004 + STR0034, STR0035)//"Digital n�o confere" -"Deseja recadastrar as digitais?" - "Valida��o de Biometria"
	  		If !BioGetAllFingersNew(cAlias,cID,aDigitais,.t.)[2]
	  			lRet := .f.
	  		EndIf
	  	Else
	  		lRet := .f.
	  	Endif
	EndIf
Else
	If lMsg .and. nRet == 1
  		Aviso( STR0025, STR0005 , {STR0006} )//"Digitais" - "Conferencia OK!" - "Ok"
  		lRet := .T.
	ElseIf nRet == 2
		If MsgYesNo(STR0036,STR0002) //"Deseja continuar sem validar a digital?" - "Aten��o"
			Return Desabilita()
		Else
			lRet := BioVldDigitalDbNew(cAlias,cId,lmsg)
		EndIf
	ElseIf nRet == 3
			lRet := BioVldDigitalDbNew(cAlias,cId,lmsg)
	Else
		lRet := .f.
	EndIf
End
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   ?
//��������������������������������������������������������������������������
Return lRet
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioVldFingerDB� Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Validar digital comparando com cadastrado no banco 			 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioVldFingerDB(cAlias,cId,lmsg)
Local aDigitais:={}
Local cD1
Local aAreaBIO := BIO->(GetArea("BIO"))
Default lmsg:= .t.
If ! BioIsActive()
	Return .t.
EndIf
If ! BioChkDLL()
	Return .f.
EndIf

aDigitais := CarDigitais(cId,cAlias)

If Len(aDigitais) == 0
	If lMsg
	  	MsgStop(STR0003)//"N�o Existem Digitais Cadastradas"
	  	RestArea(aAreaBIO)
	  	Return .F.
	EndIf
EndIf

RestArea(aAreaBIO)

cD1:=BioFGetFinger()
If AllDigit(SubStr(cD1,1,12))
	cD1:=SubStr(cD1,13)
EndIf


If "ERRO" $ cD1
   Return .f.
EndIf

nRet := BioChkFingers(cD1,aDigitais)

If nRet == 0
	If lMsg
	  	MsgStop(STR0004)//"Digital n�o confere"
	EndIf
   	Return .f.
End

If lMsg
  	Aviso( STR0025, STR0005 , {STR0006} )//"Digitais" - "Conferencia OK!" - "Ok"
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return .t.
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �CarDigitais   � Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega digitais de uma usuario								 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function CarDigitais(cId,cAlias)

LOCAL aDigitais := {}
Local nX := 1
BIO->(DbSetOrder(1))//BIO_FILIAL+BIO_ALIAS+BIO_ID+BIO_DIG
If BIO->(DbSeek(xFilial("BIO")+cAlias+Padr(cId,8)))

	While BIO->(! Eof() .And. BIO_FILIAL+BIO_ALIAS+BIO_ID == xFilial("BIO")+cAlias+Padr(cId,8))
		If GetNewPar("MV_BIONEW",.F.)
			If BIO->( FieldPos("BIO_DIG3") ) > 0  .And. BIO->( FieldPos("BIO_DIG4") ) > 0
					If Len(aDigitais) == 0 .OR. Len(aDigitais) == NIL
						aDigitais := Array(10)

						For nX:= 1 To Len(aDigitais)
							aDigitais[nX] := ""
						Next

					EndIf

					DO CASE
							CASE BIO->BIO_DIG = "01"
								aDigitais[1] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
							CASE BIO->BIO_DIG = "02"
								aDigitais[2] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
							CASE BIO->BIO_DIG = "03"
								aDigitais[3] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
							CASE BIO->BIO_DIG = "04"
								aDigitais[4] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
							CASE BIO->BIO_DIG = "05"
								aDigitais[5] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
							CASE BIO->BIO_DIG = "06"
								aDigitais[6] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
							CASE BIO->BIO_DIG = "07"
								aDigitais[7] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
							CASE BIO->BIO_DIG = "08"
								aDigitais[8] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
							CASE BIO->BIO_DIG = "09"
								aDigitais[9] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
							CASE BIO->BIO_DIG = "10"
								aDigitais[10] := AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
					ENDCASE
			Else
				aadd(aDigitais,AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG2))
				//aadd(aDigitais,AllTrim(BIO->BIO_DIG2))
			EndIf
		Else
			If BIO->( FieldPos("BIO_DIG3") ) > 0  .And. BIO->( FieldPos("BIO_DIG4") ) > 0
			   	aadd(aDigitais,AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19))
				aadd(aDigitais,AllTrim(BIO->BIO_DIG2)+AllTrim(BIO->BIO_DIG4)+AllTrim(BIO->BIO_DIG6)+AllTrim(BIO->BIO_DIG8)+AllTrim(BIO->BIO_DIG10)+AllTrim(BIO->BIO_DIG12)+AllTrim(BIO->BIO_DIG14)+AllTrim(BIO->BIO_DIG16)+AllTrim(BIO->BIO_DIG18)+AllTrim(BIO->BIO_DIG20))
			Else
				aadd(aDigitais,AllTrim(BIO->BIO_DIG1))
				aadd(aDigitais,AllTrim(BIO->BIO_DIG2))
			EndIf
		EndIf
		BIO->(DbSkip())
	End
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return(aDigitais)
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioFGetFinger � Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Leitura de digital utilizando form							 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioGetDigitalNew(cMsg)
Local cDigital, cDigiTemp 	:= ""
Local cURL
Local cTitle 	:= STR0007 //"Leitura de digital"
DEFAULT cMsg 	:= STR0008 //"Coloque a digital no dipositivo"

If GetNewPar("MV_BIOWERE","0")=='1'
	cURL := 'http://'+ GetClientIp() +':'+ GetNewPar("MV_BIOPORT","9000") +'/api/public/v1/captura/Capturar/1' //URL gerada a partir do dispositivo FingerTechWeb Nitgen
	cDigital :=  HttpGet(cUrl)

	If cDigital == NIL
			Alert(STR0047)//"Servi�o do dispositivo n�o est� iniciado. Verifique as configura��es do arquivo Configuracao.INI!"
			cDigital := ""
	Else
		cURL := 'http://'+ GetClientIp() +':'+ GetNewPar("MV_BIOPORT","9000") +'/api/public/v1/captura?Digital=' + AllTrim(cDigital)
		cDigiTemp := HttpGet(StrTran(cURL,'"',''))

		If AT("ExceptionMessage",cDigiTemp) > 0
				Alert(STR0037) //'Digital n�o posicionada ou dispositivo n�o ativado. Tente novamente...'
					BioGetDigitalNew()
		Else
			If cDigiTemp != '"OK"'
			Alert(STR0038) //"'Digitais inv�lidas. Tente novamente!"
				BioGetDigitalNew()
			EndIf
		EndIf
	EndIf
Else
	MsgInfo(STR0039, STR0025) // ""Parametros necess�rios desativados"" - Digitais

EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return cDigital
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioFGetFinger � Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Leitura de digital utilizando form							 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioFGetFinger(cMsg)
Local oDlg
Local cDigital 	:= ""
Local bAction	:= { || BioGetFinger() }
Local cTitle 	:= STR0007 //"Leitura de digital"
DEFAULT cMsg 	:= STR0008 //"Coloque a digital no dipositivo"

If GetNewPar("MV_BIOWERE","0")=='1'
	DEFINE MSDIALOG oDlg FROM 0,0 TO 195,223 TITLE OemToAnsi(cTitle) STYLE DS_MODALFRAME STATUS PIXEL
	@ 08,05 SAY oText VAR cMsg SIZE 80,30 OF oDlg FONT oDlg:oFont PIXEL

	@ 23,15 BITMAP oBmp SIZE 80,65 OF oDlg NOBORDER SCROLL PIXEL
	oBmp:Load('','hamster1.jpg')
	oBmp:LAUTOSIZE 		:= .t.
	oBmp:lStretch 			:= .t.
	oBmp:lTransparent 	:= .f.

	oDlg:bStart:= { || cDigital := Eval( bAction), oDlg:End() }
	ACTIVATE DIALOG oDlg CENTERED
Else
	cDigital := Eval(bAction)
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return cDigital
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioGetFinger  � Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Leitura de digital											 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioGetFinger()
Local cDigital := Iif( ( GetNewPar("MV_BIOWERE","0")=='1' .And. GetNewPar("MV_BIOVLDR","1")=='1' ) , "CAPTURAR"+Space(1024) , "ENROLL" + Space( 10000 - Len("ENROLL") ) )
LOCAL nRet,nPos,cRet

If BioChkDLL()

	If GetNewPar("MV_BIOVLDR","1") == "1"
		cDigital := "1|localhost|45678|600000|"
		nRet := ExeDLLRun3(nHnd, 2, @cDigital)
		cDigital := "2|0|bio_nitgen"
		nRet := ExeDLLRun3(nHnd, 2, @cDigital)
		cDigital := "3|0|0|ENROLL"
		nRet := ExeDLLRun3(nHnd, 2, @cDigital)
		nPos := At(Chr(0), cDigital)
		If nPos > 0
			cRet := SubStr(cDigital,1,nPos-1)
		EndIf
		cDigital := "4|0|0"
		nRet := ExeDLLRun3(nHnd, 2, @cDigital)
		cDigital := "9999|0"
		nRet := ExeDLLRun3(nHnd, 2, @cDigital)
		ExecInDllClose( nHnd )
		nHnd := -1
	ElseIf GetNewPar("MV_BIOVLDR","1") == "2" .And. GetNewPar("MV_BIOWERE","0") == '1'
		cDigital := "0|localhost|45678|600000|totvsbio_biotouch|ENROLL"
		nRet := ExeDLLRun3(nHnd, 2, @cDigital)
		nPos := At(Chr(0), cDigital)
		If nPos > 0
			cRet := SubStr(cDigital,1,nPos-1)
		EndIf
		ExecInDllClose( nHnd )
		nHnd := -1
	Else
		nRet := ExeDLLRun3(nHnd, 1, @cDigital)
		ExecInDllClose( nHnd )
		nHnd := -1
		nPos := At(Chr(0), cDigital)
		If nPos > 0
			cDigital := SubStr(cDigital,1,nPos-1)
		EndIf
		cRet := cDigital
	EndIf
Else
	cRet := "ERRO"
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return cRet
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioChkDLL	    � Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Checar se existe a DLL										 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioChkDLL(lMsg)
Local cValidador := GetNewPar("MV_BIOVLDR","1")
Local cName	:= ""
default lMsg := .t.

If nHnd <= 0
	If cValidador == '1'
		If GetNewPar("MV_BIOWERE","0") == '1'
			cName := "totvs_smart_agent_client.dll"
		Else
			cName := "bio_nitgen.dll"
		EndIf
	EndIf

	If cValidador == '2'
		If GetNewPar("MV_BIOWERE","0") == '1'
			cName := "totvs_smart_agent_client.dll"
		Else
			cName := "totvsbio_biotouch.dll"
		EndIf
	EndIf

	If cValidador == '3'
		cName := "totvsbio_digitalpersona.dll"
	EndIf

	If cValidador == '4'
		cName := "totvsbio_griaule.dll"
	EndIf

	nHnd := ExecInDLLOpen(cName)

	If nHnd = -1
		If lMsg
			If File(cName, 2)
				Alert(STR0033+": "+cName)//"Falha ao carregar DLL. Verifique atualiza��o da DLL"
			Else
				Alert(STR0009+": "+cName)//"ERRO - DLL n�o encontrada"
			EndIf
		Else
			If File(cName, 2)
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0033+": "+cName , 0, 0, {}) //"Falha ao carregar DLL. Verifique atualiza��o da DLL"
			Else
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0009+": "+cName , 0, 0, {}) //"ERRO - DLL n�o encontrada"
			EndIf
		EndIf
		Return .f.
	EndIf
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return .t.
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioChkFingers � Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o de digitais										 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioChkDigitalNew(cAlias,cID,aDigitais)
Local cBuffer := ""
Local lDigitalRet := .F.
Local cURL := ""
Local cDigitalRet := ""
Local aDedoInd := {}

Local nRetFunBio := 0
//Local nRet := 0


If Empty(aDigitais)
	Return(nRetFunBio)
EndIf

aDedoInd = BioGetAllFingersNew(cAlias,cID,aDigitais,.t.,"Match")

IF aDedoInd[3] != 0
	cBuffer := AllTrim(aDigitais[aDedoInd[3]])

	IF Empty(cBuffer)
		nRetFunBio := 2
		If MsgYesNo(STR0040,STR0035)//"O Dedo selecionado n�o possui digital registrada. Deseja registrar a digital agora?"-"Valida��o de Biometria"
			BioGetAllFingersNew(cAlias,cID,aDigitais,.t.)
		Else
			BioChkDigitalNew(cAlias,cID,aDigitais)
		EndIf
	Else
		If GetNewPar("MV_BIOVLDR","1") == "1"
				cURL := 'http://'+ GetClientIp() +':'+ GetNewPar("MV_BIOPORT","9000") +'/api/public/v1/captura?Digital=' + AllTrim(cBuffer)
				cDigitalRet := HttpGet(cURL)

				If cDigitalRet == NIL
					Alert(STR0047)//"Servi�o do dispositivo n�o est� iniciado. Verifique as configura��es do arquivo Configuracao.INI!"
					nRetFunBio := 4
				ElseIf AT("ExceptionMessage",cDigitalRet) > 0
					nRetFunBio := 3
					Alert(STR0041)//'Digital n�o posicionada ou dispositivo n�o ativado. Tente novamente...'
				Else
					lDigitalRet := IF((cDigitalRet == '"OK"'),.T.,.F.)

					If lDigitalRet //Retorno do Servi�o para Match da Digital
						nRetFunBio := 1
					EndIf
				EndIf
		Else
			Alert(STR0039)//"Parametros necess�rios desativados"
		EndIf
	EndIf
Else
	nRetFunBio := 2
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return(nRetFunBio)
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioChkFingers � Autor � PLS			     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o de digitais										 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioChkFingers(cDigital,aDigitais,lMsg)
Local cBuffer, cBuffer1 := ""
Local nX
Local nRetFunBio := 0
Local nRet := 0
DEFAULT lMsg := .T.

If Empty(aDigitais)
	Return(nRetFunBio)
EndIf

If GetNewPar("MV_BIOVLDR","1") == "1"

	If BioChkDLL(lMsg)

		cBuffer1 := "1|localhost|45678|600000|"
		nRet := ExeDLLRun3(nHnd, 2, @cBuffer1)
		cBuffer1 := "2|0|bio_nitgen"
		nRet := ExeDLLRun3(nHnd, 2, @cBuffer1)

		cBuffer1 := "3|0|0|MATCH" + Chr(1) + "Z" + Chr(1) + AllTrim(cDigital)

		For nX:=1 to len(aDigitais)

			cBuffer := cBuffer1 + Chr(1) + "Z" + Chr(1) + AllTrim(aDigitais[nX])

			nRet := ExeDLLRun3(nHnd, 2, @cBuffer)

			If "decode64" $ cBuffer .Or. "Erro na verificacao" $ cBuffer
				cBuffer := cBuffer1 + Chr(1) + "N" + Chr(1) + AllTrim(aDigitais[nX])
				nRet := ExeDLLRun3(nHnd, 2, @cBuffer)
			EndIf

			If nRet > 0 .And. SubStr(cBuffer,13,1)<>"0"
				Exit
			EndIf
		Next

		If SubStr(cBuffer,13,1)=="0" .or. nRet <= 0
			Return(nRetFunBio)
		EndIf
	Else
		Return(nRetFunBio)
	EndIf

	nRetFunBio :=Val(SubStr(cBuffer,13,1))

	If nHnd > -1
		cBuffer := "4|0|0"
		nRet := ExeDLLRun3(nHnd, 2, @cBuffer)
		cBuffer := "9999|0"
		nRet := ExeDLLRun3(nHnd, 2, @cBuffer)
		ExecInDllClose( nHnd )
		nHnd := -1
	EndIf
ElseIf GetNewPar("MV_BIOVLDR","1") == "2" .And. GetNewPar("MV_BIOWERE","0") == '1'
	If BioChkDLL(lMsg)

		For nX:=1 to len(aDigitais)
			cBuffer1 := "0|localhost|45678|600000|totvsbio_biotouch|MATCH"
			cBuffer1 += Chr(1) + "Z" + Chr(1) + AllTrim(cDigital)
			cBuffer := cBuffer1 + Chr(1) + "Z" + Chr(1) + AllTrim(aDigitais[nX])

			nRet := ExeDLLRun3(nHnd, 2, @cBuffer)

			If "ERRO" $ Upper(cBuffer)
				cBuffer1 := "0|localhost|45678|600000|totvsbio_biotouch|MATCH"
				cBuffer1 += Chr(1) + "N" + Chr(1) + AllTrim(cDigital)
				cBuffer := cBuffer1 + Chr(1) + "N" + Chr(1) + AllTrim(aDigitais[nX])
				nRet := ExeDLLRun3(nHnd, 2, @cBuffer)
			EndIf

			If nRet > 0 .And. SubStr(cBuffer,13,1)<>"0"
				Exit
			EndIf
		Next

		If SubStr(cBuffer,13,1)=="0" .or. nRet <= 0
			Return(nRetFunBio)
		EndIf
	Else
		Return(nRetFunBio)
	EndIf

	nRetFunBio := Val(SubStr(cBuffer,13,1))

	If nHnd > -1
		ExecInDllClose( nHnd )
		nHnd := -1
	EndIf
Else
	If BioChkDLL(lMsg)

		cBuffer1 := "MATCH" + Chr(1) + AllTrim(cDigital)

		For nX:=1 to len(aDigitais)

			cBuffer := cBuffer1 + Chr(1) + AllTrim(aDigitais[nX])

			nRet := ExeDLLRun3(nHnd, 1, @cBuffer)

			If nRet > 0 .And. Left(cBuffer,1)<>"0"
				Exit
			EndIf
		Next

		If Left(cBuffer,1)=="0" .or. nRet <= 0
			Return(nRetFunBio)
		EndIf
	Else
		Return(nRetFunBio)
	EndIf

	nRetFunBio :=Val(Alltrim(Left(cBuffer,1)))

	If nHnd > -1
		ExecInDllClose( nHnd )
		nHnd := -1
	EndIf
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return(nRetFunBio)
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioGetHandFingers � Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Leitura das digitais de todos os dedos m�os {{"",""},{"",""}.}���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioGetAllFingersNew(cAlias,cID,aDigitais,lAlt,cDlgTipo)
Local oDlg
Local bAction	:= { || BioGetFinger() }
Local oPanel,oPanel2,oBmp,oDedo1,oDedo2,oDedo3,oDedo4,oDedo5,oDedo6,oDedo7,oDedo8,oDedo9,oDedo10
Local lOk:=.f.
Local nX
Local aButtons := {}
Local nDedo := 0
Local lAtivo := .t.
Local bBotCon := {|| Desabilita(oDlg)}
Local bBotDel:= {|| DelDigitais(cAlias,cId,{oDedo1,oDedo2,oDedo3,oDedo4,oDedo5,oDedo6,oDedo7,oDedo8,oDedo9,oDedo10},aDigitais) }
Default lAlt = .T.

If cAlias <> NIL .and. cID <> NIL .and. aDigitais==NIL
	aDigitais := Array(10)
	For nX:= 1 to 10
		aDigitais[nX] := ""
	Next
	If Empty(cAlias) .or. Empty(cID)
		Return {aDigitais,lOk}
	EndIf

	If lAtivo:=BioIsActive()
		If !lAlt
			bBotCon:= {|| .T.}
			bBotDel:= {|| .T.}
		EndIf
		aadd(aButtons,{"nochecked",bBotDel,STR0010+cID,STR0011})//"Apaga todas as digitais do codigo " - "Deleta"
		aadd(aButtons,{"noconnect",bBotCon,STR0012,STR0013})//"Desabilita dipositivo biometrico " - "Desabilita"
	Else
		aadd(aButtons,{"pmsrela",{|| Habilita(oDlg)},STR0014,STR0015}) //"Habilita dipositivo biometrico " - "Habilita"
	EndIf
EndIf

DEFINE MSDIALOG oDlg FROM 0,0 TO 250,550 TITLE IF((cDlgTipo == "Match"),STR0007 + " - ",STR0016) + cID + STR0017 + IF(lAtivo,STR0018,STR0019) STYLE DS_MODALFRAME STATUS PIXEL //"Cadastro das digitais " - " - Dispositivo biometrico " - "habilitado" - "desabilitado"
oDlg:lEscClose := .F.

@00,00 MSPANEL oPanel2 SIZE 40,24 of oDlg
oPanel2:Align := CONTROL_ALIGN_LEFT

@00,00 MSPANEL oPanel SIZE 120,24 of oDlg
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

@ 0,0 BITMAP oBmp SIZE 80,60 OF oPanel NOBORDER SCROLL PIXEL
oBmp:Load('','biomaos.bmp')
oBmp:LAUTOSIZE 		:= .t.
oBmp:lStretch 		:= .f.
oBmp:lTransparent 	:= .F.

@ 22,05 BITMAP oDedo10 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo10,cAlias,cId, 10, oDlg)[1],(aDigitais[10] := CapturaDigitalNew(oDedo10,cAlias,cId, 0, NIL, "10"))[1]) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[10] == ""
	oDedo10:Load('','biobok.bmp')
Else
	oDedo10:Load('','biobokDB.bmp')
EndIf
oDedo10:LAUTOSIZE 		:= .t.
oDedo10:lStretch 		:= .f.
oDedo10:lTransparent 	:= .t.
@ 11,18 BITMAP oDedo9 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo9,cAlias,cId, 9, oDlg)[1],(aDigitais[9] := CapturaDigitalNew(oDedo9,cAlias,cId, 0, NIL, "09"))[1]) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[9] == ""
	oDedo9:Load('','biobok.bmp')
Else
	oDedo9:Load('','biobokDB.bmp')
EndIf
oDedo9:LAUTOSIZE 		:= .t.
oDedo9:lStretch 		:= .f.
oDedo9:lTransparent 	:= .t.
@ 07,32 BITMAP oDedo8 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo8,cAlias,cId, 8, oDlg)[1],(aDigitais[8] := CapturaDigitalNew(oDedo8,cAlias,cId, 0, NIL, "08"))) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[8] == ""
	oDedo8:Load('','biobok.bmp')
Else
	oDedo8:Load('','biobokDB.bmp')
EndIf
oDedo8:LAUTOSIZE 		:= .t.
oDedo8:lStretch 		:= .f.
oDedo8:lTransparent 	:= .t.
@ 11,46 BITMAP oDedo7 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo7,cAlias,cId, 7, oDlg)[1],(aDigitais[7] := CapturaDigitalNew(oDedo7,cAlias,cId, 0, NIL, "07"))[1]) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[7] == ""
	oDedo7:Load('','biobok.bmp')
Else
	oDedo7:Load('','biobokDB.bmp')
EndIf
oDedo7:LAUTOSIZE 		:= .t.
oDedo7:lStretch 		:= .f.
oDedo7:lTransparent 	:= .t.

@ 40,67 BITMAP oDedo6 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo6,cAlias,cId, 6, oDlg)[1],(aDigitais[6] := CapturaDigitalNew(oDedo6,cAlias,cId, 0, NIL, "06"))[1]) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[6] == ""
	oDedo6:Load('','biobok.bmp')
Else
	oDedo6:Load('','biobokDB.bmp')
EndIf
oDedo6:LAUTOSIZE 		:= .t.
oDedo6:lStretch 		:= .f.
oDedo6:lTransparent 	:= .t.
@ 40,80 BITMAP oDedo5 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo5,cAlias,cId, 5, oDlg)[1],(aDigitais[5] := CapturaDigitalNew(oDedo5,cAlias,cId, 0, NIL, "05"))[1]) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[5] == ""
	oDedo5:Load('','biobok.bmp')
Else
	oDedo5:Load('','biobokDB.bmp')
EndIf
oDedo5:LAUTOSIZE 		:= .t.
oDedo5:lStretch 		:= .f.
oDedo5:lTransparent 	:= .t.
@ 10,99 BITMAP oDedo4 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo4,cAlias,cId, 4, oDlg)[1],(aDigitais[4] := CapturaDigitalNew(oDedo4,cAlias,cId, 0, NIL, "04"))[1]) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[4] == ""
	oDedo4:Load('','biobok.bmp')
Else
	oDedo4:Load('','biobokDB.bmp')
EndIf
oDedo4:LAUTOSIZE 		:= .t.
oDedo4:lStretch 		:= .f.
oDedo4:lTransparent 	:= .t.
@ 05,114 BITMAP oDedo3 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo3,cAlias,cId, 3, oDlg)[1],(aDigitais[3] := CapturaDigitalNew(oDedo3,cAlias,cId, 0, NIL, "03"))[1]) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[3] == ""
	oDedo3:Load('','biobok.bmp')
Else
	oDedo3:Load('','biobokDB.bmp')
EndIf
oDedo3:LAUTOSIZE 		:= .t.
oDedo3:lStretch 		:= .f.
oDedo3:lTransparent 	:= .t.
@ 09,128 BITMAP oDedo2 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo2,cAlias,cId, 2, oDlg)[1],(aDigitais[2] := CapturaDigitalNew(oDedo2,cAlias,cId, 0, NIL, "02"))[1]) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[2] == ""
	oDedo2:Load('','biobok.bmp')
Else
	oDedo2:Load('','biobokDB.bmp')
EndIf
oDedo2:LAUTOSIZE 		:= .t.
oDedo2:lStretch 		:= .f.
oDedo2:lTransparent 	:= .t.
@ 19,141 BITMAP oDedo1 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK IF((cDlgTipo == "Match"),nDedo:= CapturaDigitalNew(oDedo1,cAlias,cId, 1, oDlg)[1],(aDigitais[1] := CapturaDigitalNew(oDedo1,cAlias,cId, 0, NIL, "01"))[1]) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[1] == ""
	oDedo1:Load('','biobok.bmp')
Else
	oDedo1:Load('','biobokDB.bmp')
EndIf
oDedo1:LAUTOSIZE 		:= .t.
oDedo1:lStretch 		:= .f.
oDedo1:lTransparent 	:= .t.
ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lOk:= .f.,oDlg:End() },{||lOk:= .f.,oDlg:End()},.f.,aButtons)

If ! lOk .And. cDlgTipo != "Match"
	aDigitais := Array(10)
	For nX:= 1 to 10
		aDigitais[nX] := ""
	Next
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   ?
//��������������������������������������������������������������������������
Return ({aClone(aDigitais),lOk, nDedo})
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �BioGetHandFingers � Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Leitura das digitais de todos os dedos m�os {{"",""},{"",""}.}���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function BioGetHandFingers(cAlias,cID,aDigitais,lAlt)
Local oDlg
Local bAction	:= { || BioGetFinger() }
Local oPanel,oPanel2,oBmp,oDedo1,oDedo2,oDedo3,oDedo4,oDedo5,oDedo6,oDedo7,oDedo8,oDedo9,oDedo10
Local lOk:=.f.
Local nX
Local aButtons := {}
Local lAtivo := .t.
Local bBotCon:= {|| Desabilita(oDlg)}
Local bBotDel:= {|| DelDigitais(cAlias,cId,{oDedo1,oDedo2,oDedo3,oDedo4,oDedo5,oDedo6,oDedo7,oDedo8,oDedo9,oDedo10},aDigitais) }
Default lAlt = .T.
If ! BioChkDLL()
	Return {{{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""}},lOk}
EndIf

If cAlias <> NIL .and. cID <> NIL .and. aDigitais==NIL
	aDigitais:={{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""}}
	If Empty(cAlias) .or. Empty(cID)
		Return {aDigitais,lOk}
	EndIf
   For nX:= 1 to 10
   	BIO->(DbSetOrder(1))
		If BIO->(DbSeek(xFilial("BIO")+cAlias+Padr(cId,8)+StrZero(nX,2)))
			If BIO->( FieldPos("BIO_DIG3") ) > 0  .And. BIO->( FieldPos("BIO_DIG4") ) > 0
				aDigitais[nX,1]:=AllTrim(BIO->BIO_DIG1)+AllTrim(BIO->BIO_DIG3)+AllTrim(BIO->BIO_DIG5)+AllTrim(BIO->BIO_DIG7)+AllTrim(BIO->BIO_DIG9)+AllTrim(BIO->BIO_DIG11)+AllTrim(BIO->BIO_DIG13)+AllTrim(BIO->BIO_DIG15)+AllTrim(BIO->BIO_DIG17)+AllTrim(BIO->BIO_DIG19)
				aDigitais[nX,2]:=AllTrim(BIO->BIO_DIG2)+AllTrim(BIO->BIO_DIG4)+AllTrim(BIO->BIO_DIG6)+AllTrim(BIO->BIO_DIG8)+AllTrim(BIO->BIO_DIG10)+AllTrim(BIO->BIO_DIG12)+AllTrim(BIO->BIO_DIG14)+AllTrim(BIO->BIO_DIG16)+AllTrim(BIO->BIO_DIG18)+AllTrim(BIO->BIO_DIG20)
			Else
				aDigitais[nX,1]:=AllTrim(BIO->BIO_DIG1)
				aDigitais[nX,2]:=AllTrim(BIO->BIO_DIG2)
			EndIf
		EndIf
   Next
	If lAtivo:=BioIsActive()
		If !lAlt
			bBotCon:= {|| .T.}
			bBotDel:= {|| .T.}
		EndIf
		aadd(aButtons,{"nochecked",bBotDel,STR0010+cID,STR0011})//"Apaga todas as digitais do codigo " - "Deleta"
		aadd(aButtons,{"noconnect",bBotCon,STR0012,STR0013})//"Desabilita dipositivo biometrico " - "Desabilita"
	Else
		aadd(aButtons,{"pmsrela",{|| Habilita(oDlg)},STR0014,STR0015}) //"Habilita dipositivo biometrico " - "Habilita"
	EndIf
Else
	DEFAULT aDigitais:={{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""}}
EndIf

DEFINE MSDIALOG oDlg FROM 0,0 TO 250,550 TITLE STR0016 + cID + STR0017 + IF(lAtivo,STR0018,STR0019) STYLE DS_MODALFRAME STATUS PIXEL //"Cadastro das digitais " - " - Dispositivo biometrico " - "habilitado" - "desabilitado"
oDlg:lEscClose := .F.

@00,00 MSPANEL oPanel2 SIZE 40,24 of oDlg
oPanel2:Align := CONTROL_ALIGN_LEFT

@00,00 MSPANEL oPanel SIZE 120,24 of oDlg
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

@ 0,0 BITMAP oBmp SIZE 80,60 OF oPanel NOBORDER SCROLL PIXEL
oBmp:Load('','biomaos.bmp')
oBmp:LAUTOSIZE 		:= .t.
oBmp:lStretch 		:= .f.
oBmp:lTransparent 	:= .F.

@ 22,05 BITMAP oDedo1 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[1] := Captura(oDedo1)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[1,1] == ""
	oDedo1:Load('','biobok.bmp')
Else
	oDedo1:Load('','biobokDB.bmp')
EndIf
oDedo1:LAUTOSIZE 		:= .t.
oDedo1:lStretch 		:= .f.
oDedo1:lTransparent 	:= .t.

@ 11,18 BITMAP oDedo2 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[2] := Captura(oDedo2)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[2,1] == ""
	oDedo2:Load('','biobok.bmp')
Else
	oDedo2:Load('','biobokDB.bmp')
EndIf
oDedo2:LAUTOSIZE 		:= .t.
oDedo2:lStretch 		:= .f.
oDedo2:lTransparent 	:= .t.

@ 07,32 BITMAP oDedo3 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[3] := Captura(oDedo3)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[3,1] == ""
	oDedo3:Load('','biobok.bmp')
Else
	oDedo3:Load('','biobokDB.bmp')
EndIf
oDedo3:LAUTOSIZE 		:= .t.
oDedo3:lStretch 		:= .f.
oDedo3:lTransparent 	:= .t.

@ 11,46 BITMAP oDedo4 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[4] := Captura(oDedo4)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[4,1] == ""
	oDedo4:Load('','biobok.bmp')
Else
	oDedo4:Load('','biobokDB.bmp')
EndIf
oDedo4:LAUTOSIZE 		:= .t.
oDedo4:lStretch 		:= .f.
oDedo4:lTransparent 	:= .t.

@ 40,67 BITMAP oDedo5 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[5] := Captura(oDedo5)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[5,1] == ""
	oDedo5:Load('','biobok.bmp')
Else
	oDedo5:Load('','biobokDB.bmp')
EndIf
oDedo5:LAUTOSIZE 		:= .t.
oDedo5:lStretch 		:= .f.
oDedo5:lTransparent 	:= .t.

@ 40,80 BITMAP oDedo6 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[6] := Captura(oDedo6)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[6,1] == ""
	oDedo6:Load('','biobok.bmp')
Else
	oDedo6:Load('','biobokDB.bmp')
EndIf
oDedo6:LAUTOSIZE 		:= .t.
oDedo6:lStretch 		:= .f.
oDedo6:lTransparent 	:= .t.

@ 10,99 BITMAP oDedo7 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[7] := Captura(oDedo7)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[7,1] == ""
	oDedo7:Load('','biobok.bmp')
Else
	oDedo7:Load('','biobokDB.bmp')
EndIf
oDedo7:LAUTOSIZE 		:= .t.
oDedo7:lStretch 		:= .f.
oDedo7:lTransparent 	:= .t.

@ 05,114 BITMAP oDedo8 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[8] := Captura(oDedo8)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[8,1] == ""
	oDedo8:Load('','biobok.bmp')
Else
	oDedo8:Load('','biobokDB.bmp')
EndIf
oDedo8:LAUTOSIZE 		:= .t.
oDedo8:lStretch 		:= .f.
oDedo8:lTransparent 	:= .t.

@ 09,128 BITMAP oDedo9 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[9] := Captura(oDedo9)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[9,1] == ""
	oDedo9:Load('','biobok.bmp')
Else
	oDedo9:Load('','biobokDB.bmp')
EndIf
oDedo9:LAUTOSIZE 		:= .t.
oDedo9:lStretch 		:= .f.
oDedo9:lTransparent 	:= .t.

@ 19,141 BITMAP oDedo10 SIZE 10,10 OF oPanel NOBORDER SCROLL PIXEL ON CLICK (aDigitais[10] := Captura(oDedo10)) WHEN Iif(lAlt,lAtivo,lAlt)
If aDigitais[10,1] == ""
	oDedo10:Load('','biobok.bmp')
Else
	oDedo10:Load('','biobokDB.bmp')
EndIf
oDedo10:LAUTOSIZE 		:= .t.
oDedo10:lStretch 		:= .f.
oDedo10:lTransparent 	:= .t.


ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lOk:=.t.,oDlg:End() },{||lOk:= .f.,oDlg:End()},.f.,aButtons)

If ! lOk
	aDigitais:={{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""}}
Else
	If cAlias<>NIL .and. cID<>NIL
		GrvDigitais(aDigitais,lAlt,cAlias,cId)
	EndIf
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return ({aClone(aDigitais),lOk})
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �GrvDigitais       � Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao da string biometrica								 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function GrvDigitais(aDigitais,lAlt,cAlias,cId,cDedo)
LOCAL nX 	 := 0
LOCAL lGrv   := .T.
DEFAULT cDedo:= ""

For nX:= 1 to Len(aDigitais)

	If Empty(aDigitais[nX,1])
		Loop
	EndIf

	aDigitais[nX,1] := AllTrim(aDigitais[nX,1])+Space(2000-Len(AllTrim(aDigitais[nX,1])))
	aDigitais[nX,2] := AllTrim(aDigitais[nX,2])+Space(2000-Len(AllTrim(aDigitais[nX,2])))

	If Empty(cDedo)
		cDedo := StrZero(nX,2)
	EndIf


	BIO->(DbSetOrder(1))//BIO_FILIAL + BIO_ALIAS + BIO_ID + BIO_DIG
	If lAlt

		If BIO->(DbSeek(xFilial("BIO") + cAlias + Padr(cId,8) + cDedo ) ) .And. lAlt
			BIO->(RecLock("BIO",.F.))
		Else
			BIO->(RecLock("BIO",.T.))
			BIO->BIO_FILIAL:= xFilial("BIO")
			BIO->BIO_ALIAS := cAlias
			BIO->BIO_ID    := Padr(cId,8)
			BIO->BIO_DIG   := cDedo
		EndIf

		If BIO->( FieldPos("BIO_DIG3") ) > 0  .And. BIO->( FieldPos("BIO_DIG4") ) > 0
			BIO->BIO_DIG1  := Substr(aDigitais[nX,1],1   ,200)
			BIO->BIO_DIG2  := Substr(aDigitais[nX,2],1   ,200)
			BIO->BIO_DIG3  := Substr(aDigitais[nX,1],201 ,200)
			BIO->BIO_DIG4  := Substr(aDigitais[nX,2],201 ,200)
			BIO->BIO_DIG5  := Substr(aDigitais[nX,1],401 ,200)
			BIO->BIO_DIG6  := Substr(aDigitais[nX,2],401 ,200)
			BIO->BIO_DIG7  := Substr(aDigitais[nX,1],601 ,200)
			BIO->BIO_DIG8  := Substr(aDigitais[nX,2],601 ,200)
			BIO->BIO_DIG9  := Substr(aDigitais[nX,1],801 ,200)
			BIO->BIO_DIG10 := Substr(aDigitais[nX,2],801 ,200)
			BIO->BIO_DIG11 := Substr(aDigitais[nX,1],1001,200)
			BIO->BIO_DIG12 := Substr(aDigitais[nX,2],1001,200)
			BIO->BIO_DIG13 := Substr(aDigitais[nX,1],1201,200)
			BIO->BIO_DIG14 := Substr(aDigitais[nX,2],1201,200)
			BIO->BIO_DIG15 := Substr(aDigitais[nX,1],1401,200)
			BIO->BIO_DIG16 := Substr(aDigitais[nX,2],1401,200)
			BIO->BIO_DIG17 := Substr(aDigitais[nX,1],1601,200)
			BIO->BIO_DIG18 := Substr(aDigitais[nX,2],1601,200)
			BIO->BIO_DIG19 := Substr(aDigitais[nX,1],1801,200)
			BIO->BIO_DIG20 := Substr(aDigitais[nX,2],1801,200)
		Else
			BIO->BIO_DIG1 := aDigitais[nX,1]
			BIO->BIO_DIG2 := aDigitais[nX,2]
		EndIF

		BIO->(MsUnLock())
	Else
		If !BIO->( DbSeek( xFilial("BIO")+ cAlias + Padr(cId,8) + cDedo ) )

			BIO->(RecLock("BIO",.T.))

			BIO->BIO_FILIAL:= xFilial("BIO")
			BIO->BIO_ALIAS := cAlias
			BIO->BIO_ID    := Padr(cId,8)
			BIO->BIO_DIG   := cDedo

			If BIO->( FieldPos("BIO_DIG3") ) > 0  .And. BIO->( FieldPos("BIO_DIG4") ) > 0
				BIO->BIO_DIG1  := Substr(aDigitais[nX,1],1   ,200)
				BIO->BIO_DIG2  := Substr(aDigitais[nX,2],1   ,200)
				BIO->BIO_DIG3  := Substr(aDigitais[nX,1],201 ,200)
				BIO->BIO_DIG4  := Substr(aDigitais[nX,2],201 ,200)
				BIO->BIO_DIG5  := Substr(aDigitais[nX,1],401 ,200)
				BIO->BIO_DIG6  := Substr(aDigitais[nX,2],401 ,200)
				BIO->BIO_DIG7  := Substr(aDigitais[nX,1],601 ,200)
				BIO->BIO_DIG8  := Substr(aDigitais[nX,2],601 ,200)
				BIO->BIO_DIG9  := Substr(aDigitais[nX,1],801 ,200)
				BIO->BIO_DIG10 := Substr(aDigitais[nX,2],801 ,200)
				BIO->BIO_DIG11 := Substr(aDigitais[nX,1],1001,200)
				BIO->BIO_DIG12 := Substr(aDigitais[nX,2],1001,200)
				BIO->BIO_DIG13 := Substr(aDigitais[nX,1],1201,200)
				BIO->BIO_DIG14 := Substr(aDigitais[nX,2],1201,200)
				BIO->BIO_DIG15 := Substr(aDigitais[nX,1],1401,200)
				BIO->BIO_DIG16 := Substr(aDigitais[nX,2],1401,200)
				BIO->BIO_DIG17 := Substr(aDigitais[nX,1],1601,200)
				BIO->BIO_DIG18 := Substr(aDigitais[nX,2],1601,200)
				BIO->BIO_DIG19 := Substr(aDigitais[nX,1],1801,200)
				BIO->BIO_DIG20 := Substr(aDigitais[nX,2],1801,200)
			Else
				BIO->BIO_DIG1 := aDigitais[nX,1]
				BIO->BIO_DIG2 := aDigitais[nX,2]
			Endif

			BIO->(MsUnLock())
		Else
			lGrv := .F.
		EndIf
	EndIf
	cDedo := ""
Next

//�����������������������������������������������������������������������Ŀ
//�Ponto de entrada apos a grava��o da tabela BIO para que seja poss�vel  �
//�identificar em qual momento a rotina est� gravando a informa��o        �
//�������������������������������������������������������������������������

If Existblock("PLSBIOGRV")
	Execblock("PLSBIOGRV",.F.,.F.)
EndIf


//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return(lGrv)
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �Habilita	        � Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Confirmacao													 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function Habilita(oDlg)
If ! ApMsgYesNo(STR0020,STR0002)//"Deseja habilitar a confer�ncia biometrica?"--"Aten��o"
	Return
EndIf
BioSetActive(.t.)
oDlg:End()
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �Desabilita        � Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Confirmacao													 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function Desabilita(oDlgAnt)
Local 	lRet :=.f.
Local 	oData
Local	oUsuario
Local	opassw
Local	cUsuario	:= SPACE(25)
Local	cpassw		:= SPACE(25)
Local 	oMainPanel
Local	oDlg
Local	aInfUser	:={}
Local cUsr			:= PLSRtCdUsr()
Local aVldOper	:= {}

If oDlgAnt != NIL
	If ! ApMsgYesNo(STR0021,STR0002)//"Deseja desabilitar a confer�ncia biometrica?"
		Return
	EndIf
EndIf

If oDlgAnt == NIL
	DbSelectArea("BX4")
		BX4->(DbSetOrder(1))

		If BX4->(MsSeek(xFilial("BX4")+cUsr)) .and. BX4->(FieldPos("BX4_ALTBIO")) > 0  .and. BX4->(FieldPos("BX4_CANBIO")) > 0
			nRecBx4  := BX4->(Recno())
			aVldOper := PlsVldOper(cUsr)
			If aVldOper[1]
				If BX4->(MsSeek(xFilial("BX4")+aVldOper[2])) .and. BX4->BX4_CANBIO = '1'
					lRet := .T.
				Else
				    Aviso(STR0025, STR0023 +UsrRetName(aVldOper[2])+ STR0042, {"Ok"} )
				EndIf
			EndIf
			BX4->(DbGoTo(nRecBx4))
		EndIf
Else
	DEFINE MSDIALOG oDlg TITLE STR0022   FROM 0,0 TO 100,200  PIXEL //"k��o"
		@00,00 MSPANEL oMainPanel SIZE 120,25 of oDLG
		oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT
		@ 06 , 10  	Say STR0023	PIXEL	of oMainPanel //"Usuario"
		@ 20 , 10  	Say STR0024 PIXEL of oMainPanel  //"Senha:"

		@ 06 , 40	MSGET oUsuario 	VAR cUsuario	 	SIZE 60,09	PIXEL of oMainPanel
		@ 20 , 40  	MSGET opassw		VAR cPassw		SIZE 60,09	PASSWORD VALID VldUser(cUsuario,cPassw) PIXEL of oMainPanel

		DEFINE SBUTTON FROM 35,26 TYPE 1 ACTION (lRet := .t.,oDlg:End()) ENABLE OF oDlg PIXEL
		DEFINE SBUTTON FROM 35,56 TYPE 2 ACTION (lRet := .f.,oDlg:End()) ENABLE OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTER
EndIf

If lRet .AND. oDlgAnt != NIL
	BioSetActive(.f.)
	oDlgAnt:End()
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return lRet
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �VldUser	        � Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida usuario												 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function VldUser(cUsuario,cPassw)
PswOrder(2)
PswSeek(cUsuario)
If ! PswName(cpassw)
	Aviso( STR0025  , STR0026, {STR0006} )//"Digitais" - "Senha Inv�lida"
	Return .f.
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return .t.
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �DelDigitais       � Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Deleta digitais												 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function DelDigitais(cAlias,cId,aBMPDedos,aDigitais)
Local nx
If ! ApMsgYesNo(STR0027+cID+"?",STR0002) //"Confirma a exclus�o de todas as digitais do codigo " --"Aten��o"
	Return
EndIf
BIO->(DbSetOrder(1))
While BIO->(DbSeek(xFilial("BIO")+cAlias+Padr(cId,8)))
	BIO->(RecLock("BIO",.F.))
	BIO->(DbDelete())
	BIO->(MsUnLock())
End
For nX:= 1 to Len(aBMPDedos)
	aBMPDedos[nX]:Load('','biobok.bmp')
Next
If GetNewPar("MV_BIONEW",.F.)
	aDigitais:={{""},{""},{""},{""},{""},{""},{""},{""},{""},{""}}
Else
	aDigitais:={{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""}}
EndIf
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �Captura	        � Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Captura														 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function CapturaDigitalNew(oDedo,cAlias,cId, nDedo, oDlg, cDedo)
Local cD1
Local aAllDig := {}
Local nRet := 0

If nDedo == 0
	cD1:=BioGetDigitalNew()
	If Len(cD1) > 0
			If cD1 == "null"
				Alert(STR0043)//"Digital n�o posicionada. Tente novamente!"
			Else
				If MsgYesNo(STR0044)//Confirmar registro de nova digital?'
					If GrvDigitais({{StrTran(cD1,'"',''),""}},.T.,cAlias,cId,cDedo)
						oDedo:Load('','biobnok.bmp')
						Aviso( STR0025, STR0045, {STR0006} )//"Digitais" - "Digital registrada com sucesso!" - "Ok"
					Else
						Alert(STR0046)//Erro ao registrar digital. Tente novamente!
					EndIf
				EndIf
			EndIf
	EndIf
	aAllDig := {cD1}
Else
	aAllDig := {nDedo}
	oDlg:End()
EndIF
Return aAllDig
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �Captura	        � Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Captura														 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function Captura(oDedo)
Local cD1
Local cD2
Local aAllDig := {}
Local nRet := 0

cD1:=BioFGetFinger()
If "ERRO" $ cD1
	Return {"",""}
EndIf

Sleep(1500)
cD2:=BioFGetFinger()
If "ERRO" $ cD2
   Return {"",""}
EndIf

If AllDigit(SubStr(cD1,1,12))
	cD1 := SubStr(cD1,13)
EndIf

If AllDigit(SubStr(cD2,1,12))
	cD2 := SubStr(cD2,13)
EndIf

If cD1 == cD2  // nao pode ser exatamente igual, caso seja eh fralde.
	Aviso( STR0025, STR0028, {STR0006} )//"Digital Inv�lida!"
	Return {"",""}
EndIf

aadd(aAllDig,cD1)
nRet :=BioChkFingers(cD2,aAllDig)

If nRet == 0
	Aviso( STR0025,STR0032, {STR0006} )//"A 1� 2 2� leitura na conferem. Por favor, tente novamente."
	Return {"",""}
EndIf

oDedo:Load('','biobnok.bmp')

Return {cD1,cD2}
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �TSTBio			� Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Teste														 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
User Function TSTBio()
Local aDigitais
aDigitais := BioGetHandFingers()
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �TstBio2			� Autor � PLS		     � Data � 10.12.2009 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Teste														 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
User Function TstBio2()
Local aDigitais := BioGetHandFingers()
Local cDedo
Local aAllDig := {}
Local nX
For nX:= 1 to Len(aDigitais)
	aadd(aAllDig,aDigitais[nX,1])
	aadd(aAllDig,aDigitais[nX,2])
Next
While .t.
   cDedo := BioFGetFinger()
   If "ERRO" $ cDedo
      Exit
	EndIf
   nRet :=BioChkFingers(cDedo,aAllDig)
   If nRet == 0
   	alert(STR0029)//"digital n�o confere"
	Else
		alert(STR0030)	   	//"conferencia ok"
	EndIf
	If ! msgyesno(STR0031,STR0006)//"Continua"
		Exit
	EndIf
End
//������������������������������������������������������������������������Ŀ
//�Fim da Funcao														   �
//��������������������������������������������������������������������������
Return

Static Function AllDigit(cVar)

Local lRet	:= .T.
Local nX	:= 0

For nX := 1 To Len(cVar)
	If ! IsDigit(SubStr(cVar,nX,1))
		lRet := .F.
		Exit
	EndIf
Next

Return lRet