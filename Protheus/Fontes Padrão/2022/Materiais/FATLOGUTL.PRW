#Include 'Protheus.ch'


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FATLOGUTIL� Autor � Vendas e CRM          � Data � 28/01/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Para utiliza��o em rotinas que precisam de LOG p/ analise. ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qualquer rotina.                                           ���
���          � Para utiliza��o adicione o comando:                        ���
���          � Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL(), )             ���
���          � Qualquer rotina.                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametro � cObs - Uma observa��o a ser adicionada em cada linha de log���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FATLOGUTIL(cObs)
Local nLogFAT := SUPERGETMV('MV_LOGFAT',.F.,0)
Local nLogTEC := SUPERGETMV('MV_LOGTEC',.F.,0)
Local nLogTMK := SUPERGETMV('MV_LOGTMK',.F.,0)
Local nLogPMS := SUPERGETMV('MV_LOGPMS',.F.,0)
Local nLogSERV:= SUPERGETMV('MV_LOGSERV',.F.,0) //Independente de modulo
Local nExec	:= 0
DEFAULT cObs := ''


Do Case
	Case (cModulo=='FAT') .AND. nLogFAT > 0
		nExec := nLogFAT
	Case (cModulo=='TEC') .AND. nLogTEC > 0
		nExec := nLogTEC
	Case (cModulo=='TMK') .AND. nLogTMK > 0
		nExec := nLogTMK	
	Case (cModulo=='PMS') .AND. nLogPMS > 0
		nExec := nLogPMS				
	OtherWise
		Iif(nLogSERV > 0,nExec := nLogSERV,) 

EndCase


Do Case
	Case (nExec == 1)
		Conout("LOG SERVICOS-TOTVS THREAD: "+AllTrim(Str(ThreadID())) +" - "+DTOC(DATE())+" "+TIME() +" FUNCAO: "+PROCNAME(1)+" LINHA: "+AllTrim(STR(PROCLINE(1)))+" "+cObs)
	Case (nExec == 2)
		Conout("LOG SERVICOS-TOTVS THREAD: "+Str(ThreadID()) +" - n�o implementado.")
	Case (nExec == 3)
		Conout("LOG SERVICOS-TOTVS THREAD: "+Str(ThreadID()) +" - n�o implementado.")		
	OtherWise
		//Conout("FATLOGUTL-TOTVS THREAD: "+Str(ThreadID()) +" - n�o implementado.")

EndCase


Return

//Para utiliza��o deve se adicionar a linha abaixo nas rotinas a serem logadas.
//Iif(FindFunction('FATLOGUTIL'),FATLOGUTIL('teste'), )
