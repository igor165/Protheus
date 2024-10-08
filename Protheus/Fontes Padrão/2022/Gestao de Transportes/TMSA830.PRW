#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA830.CH"
Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Funcao   � TMSA830  � Autor � Eduardo de Souza      � Data � 19/09/03 ���
�������������������������������������������������������������������������Ĵ��
��� Descricao� Cadastro de Filiais Alianca                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSA830()
Private cCadastro := STR0001 //"Filial Alianca"

AxCadastro("DVL", cCadastro, "TMSA830Exc()")

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA830Exc� Autor � Eduardo de Souza      � Data � 19/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �  Valida se pode ser feito a exclusao                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA830Exc()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA830                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMSA830Exc()
Local aArquivos := {}
Local lRet      := .T.

Aadd(aArquivos,{"DTC", "DTC_FILIAL+DTC_FILDPC", DVL->DVL_FILIAL+DVL->DVL_FILALI })
Aadd(aArquivos,{"DTA", "DTA_FILIAL+DTA_FILDPC", DVL->DVL_FILIAL+DVL->DVL_FILALI })

MsgRun(STR0002,STR0003,{ || lRet := TmsA830Del(aArquivos) }) //"Validando Exclusao..."###"Aguarde..."

If !lRet
	Help(" ",1,"TMSA83001") //"Existe relacionamento para este registro, nao sera possivel a exclusao"
EndIf	

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA830Del� Autor � Eduardo de Souza      � Data � 22/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �  Verifica Relacionamento                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TmsA830Del()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA830                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TmsA830Del(aArquivos)
Local nCnt   := 0
Local cIndex := 0
Local lRet   := .T.

For nCnt := 1 To Len(aArquivos)

	DbSelectarea(aArquivos[nCnt,1])
	aArea := GetArea()

	cIndex  := CriaTrab(Nil,.F.)
	cKey    := aArquivos[nCnt,2]
	cFiltro := aArquivos[nCnt,2]+'=="'+aArquivos[nCnt,3]+'"'

	IndRegua( aArquivos[nCnt,1], cIndex, cKey,, cFiltro, STR0002 ) // "Validando Exclusao..."

	//-- Verifica se existem informacoes para o registro
	If !Eof()
		lRet := .F.
		Exit
	EndIf

	//-- Apaga os arquivos temporarios
	RetIndex(aArquivos[nCnt,1])
	DbClearFilter()
	cIndex += OrDbagExt()
	Delete File &(cIndex)

	RestArea( aArea )

Next nCnt

Return lRet
