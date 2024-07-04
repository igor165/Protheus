#Include "TMKXMID.CH"
#Include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKXMID  � Autor � Michel Willian Mosca  � Data �17/11/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Middleware                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void TMKXMID(void)                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SMARTCTI                                      		      ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKXMID(aAuto,nOpcAuto)

Local aButtons := Nil

If !__lPyme
	aButtons := {{"GEOROTA",{|| TKMWSValid()},STR0010,STR0011}}	//"Teste do WebService de Comandos" #"Teste"
EndIf


//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0008)  //"Atualiza��o de cadastro dos Middlewares
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
AxCadastro("SK4",;
	cCadastro,;
	,;
	,;
	,;
	,;
	,;
	,;
	,;
	aAuto,;
	nOpcAuto,;
	aButtons,;
	{Nil,Nil,Nil,Nil,3})


Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TKMWSValid� Autor � MICHEL WILLIAN MOSCA  � Data �17/11/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de validacao da exclusao de MIDDLEWARE.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TKMIDValid(ExpC1,ExpN1)    		                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MP8                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function TKMWSValid()
Local lRet      := .T.        		//Retorno da funcao                                              
Local oSmartCTIWSCommand := NIL     //Objeto WebService de comandos          
Local RC                            //Retorno do m�todo WebService

//WSDLDbgLevel(3)

If SuperGetMV("MV_TMKWSVE",,"1") == "1"	// Vers�o do Webservice de Comandos
	oSmartCTIWSCommand	:= WSSmartCTIWSCommandService():New(AllTrim(M->K4_CMD_URL))
	oSmartCTIWSCommand:SystemStatus()
	RC := oSmartCTIWSCommand:nSystemStatusReturn	
Else
	oSmartCTIWSCommand	:= WSSmartCTIWSCommand():New(AllTrim(M->K4_CMD_URL))
	oSmartCTIWSCommand:SystemStatus()
	RC := oSmartCTIWSCommand:nReturn	
EndIf	



If RC == NIL	//Caso em que o WebService SmartCTIWSCommand nao foi encontrado
	MsgInfo(STR0012 + Chr(13) + Chr(10) +;//"Atencao!!"
	STR0013  + Chr(13) + Chr(10) + ; //"O WebService para envio de comandos configurado em URL Command n�o est� respondendo." 
	STR0014;	//"Verifique o endere�o e realize novamente o teste."
	,"")
Else
	MsgInfo(STR0015, "")	//"O WebService para envio de comandos est� correto."
EndIf  


Return(lRet)









