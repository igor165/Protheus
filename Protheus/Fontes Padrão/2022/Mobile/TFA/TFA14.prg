#INCLUDE "TFA14.ch"
#include "eADVPL.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CtrFaixa            �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Controle das Faixas de Codigo				 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CtrFaixa()
Local lAtu:= .F.
dbSelectArea("HA3")  
dbGoTop()
if Empty(HA3->A3_PEDINI)
	HA3->A3_PEDINI		:= "000001"
	lAtu:= .T.
Endif
if Empty(HA3->A3_PEDFIM)
	HA3->A3_PEDFIM		:= "999999"
	lAtu:= .T.
Endif
if Empty(HA3->A3_PROXPED)
	HA3->A3_PROXPED		:= "000001"
	lAtu:= .T.
Endif
if Empty(HA3->A3_CLIINI)
	HA3->A3_CLIINI		:= "000001"
	lAtu:= .T.
Endif
if Empty(HA3->A3_CLIFIM)
	HA3->A3_CLIFIM		:= "999999"
	lAtu:= .T.
Endif
if Empty(HA3->A3_PROXCLI)
	HA3->A3_PROXCLI		:= "000001"
	lAtu:= .T.
Endif 
if Val(HA3->A3_PROXCLI) < Val(HA3->A3_CLIINI)
	HA3->A3_PROXCLI		:= HA3->A3_CLIINI
Endif
if Val(HA3->A3_PROXPED) < Val(HA3->A3_PEDINI)
	HA3->A3_PROXPED		:= HA3->A3_PEDINI
Endif

if lAtu
	dbCommit()
Endif

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VrfPerm             �Autor: Fabio Garbin  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Verifica Permissao de Acesso no SFA atraves da Tabela Sync ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
/*Function VrfPerm()
Local dDtLimite
Local dDtAtual  := Date()  // Data Atual
Local dDtFirst  := Date()  // Data do Primeiro Acesso
Local lRet      := .F.     // Retorno da Funcao
Local nNumDia   := 0       // Total de Dias sem sincronizacao
Local nDiaSync  := 0       // Maximo de dias sem sincronismo

dbSelectArea("HCF")
dbSetOrder(1)
If dbSeek("MV_DTSYNC")
	nDiaSync := Val(HCF->CF_VALOR)
	If dbSeek("MV_LASTACC")
		dDtFirst   := StoD(HCF->CF_VALOR)
	Else
		dbAppend()
		HCF->CF_PARAM := "MV_LASTACC"
		HCF->CF_VALOR := DtoS(Date())
		dbCommit()
		dDtFirst   := Date()
	EndIf
	dDtLimite := dDtFirst + nDiaSync
	If dDtAtual <= dDtLimite
		lRet := .T.
	Else
		nNumDia := nDiaSync + (dDtAtual - dDtLimite)
		MsgStop("Acesso ao SFA n�o est� permitido. O sincronismo nao � realizado a " + Str(nNumDia,3,0) + " dia(s). Fa�a o sincronismo para ter acesso ao SFA.", "Acesso")
	EndIf
EndIf
Return lRet*/

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � OpenEmp             �Autor: Fabio Garbin  �   07/11/2002   ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Abre o arquivo de Empresa utilizado pelo SFA	 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function OpenEmp()
Local cTblEmp := "HEMP"
Local lRet    := .T.
Local cMsgRet := ""

// Abre Tabela de Empresa
If !File(cTblEmp)
//	cMsgRet := "Tabela de Empresa nao Existe !"
	lRet    := .F.
Else	
	lRet := dbUseArea( .T., "LOCAL", cTblEmp, "EMP", .T., .F. )
	dbSetIndex(cTblEmp + "1")
	dbGotop()
	cEmpresa := EMP->EMP_COD + "0"
EndIf

// Abre Tabela de Dicionarios
If !File("ADV_TBL") .Or. !File("ADV_IND")
	//cMsgRet := "Arquivos de ADV_TBL e ADV_IND nao existe."
	InitSync()
	lRet    := .F.
Else
	// Abre Arquivo ADV_TBL
	lRet := dbUseArea( .T., "LOCAL", "ADV_TBL", "ADVTBL", .T., .F. )
	dbSetIndex("SYNC_IDX")
	dbGotop()
	If lRet
		// Abre Arquivo ADV_TBL	
		lRet := dbUseArea( .T., "LOCAL", "ADV_IND", "ADVIND", .T., .F. )
		dbSetIndex("ADV_IND_IDX")
		dbGotop()   
		// Abre Arquivo de Tecnicos (AA1)
    	If lRet
			lRet := dbUseArea( .T., "LOCAL", "AA1" + cEmpresa, "AA1", .T., .F. )
			dbSetIndex("AA1" + cEmpresa + "1")
			dbGotop()
			If !lRet
				cMsgRet := 	STR0001 + cEmpresa + ")." //"Falha na abertura da tabela de tecnicos (AA1"
				lRet    := .F.
			EndIf
		Else
			cMsgRet := 	STR0002 //"Falha na abertura da tabela de indices (ADV_IND)."
			lRet    := .F.
		EndIf
	Else
		cMsgRet := 	STR0003 //"Falha na abertura da tabela de estruturas (ADV_TBL)."
		lRet    := .F.	
	EndIf
EndIf
If !Empty(cMsgRet)
	MsgStop(cMsgRet)
EndIf

Return lRet


Function InitSync(oSayFile, oMeterFiles, nMeterFiles)

dbCloseAll()

DoSync()

// Reabre as tabelas
If oSayFile <> Nil
	If OpenEmp()
		If OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
			HideControl(oSayFile)
			HideControl(oMeterFiles)	
		EndIf
	EndIf   
EndIf

Return Nil
