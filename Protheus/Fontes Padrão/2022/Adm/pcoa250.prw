#INCLUDE "pcoa250.ch"
#INCLUDE "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PCOA250  � Autor � Paulo Carnelossi      � Data � 10/04/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Relatorios Modulo SIGAPCO                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function PCOA250()

A250Pop_ALH()

AxCadastro("ALH",STR0001, "PCOA250DEL()")  //"Cadastro de Relatorios"

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA250DEL� Autor � Paulo Carnelossi      � Data �10/04/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de validacao de exclusao de Relatorios               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 -> Validacao OK                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � PCOA250                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA250DEL()

Return .T.

Static Function A250Pop_ALH()
Local aRelat := {}, nX
//planilha
aAdd(aRelat,{"PCOR010",STR0002 ,"PCR010", "(aPerg)"}) //"Planilha Resumida"
aAdd(aRelat,{"PCOR045",STR0003,"PCR015", "(aPerg)"}) //"Planilha Detalhada"
aAdd(aRelat,{"PCOR050",STR0004,"PCR010", "(aPerg)"}) //"Totalizadores da Planilha"
aAdd(aRelat,{"PCOR211",STR0005,"PCR211", "(,,,,aPerg)"}) //"Comparacao entre Versoes da Planilha"

//movimentos
aAdd(aRelat,{"PCOR400",STR0006,"PCR400", "(aPerg)"}) //"Relatorio de Movimentos"

//Cubos Gerenciais
aAdd(aRelat,{"PCOR330",STR0007,"PCR330", "(aPerg)"}) //"Cubos - Movimentos"
aAdd(aRelat,{"PCOR310",STR0008,"PCR310", "(aPerg)"}) //"Cubos - Demonstrativo de Saldos"
aAdd(aRelat,{"PCOR300",STR0009,"PCR300", "(aPerg)"}) //"Cubos - Balancete"
aAdd(aRelat,{"PCOR320",STR0010,"PCR320", "(aPerg)"}) //"Cubos - Demonstrativo por Periodo"

//Cubos Gerenciais Comparativos
aAdd(aRelat,{"PCOR510",STR0011,"PCR510", "(aPerg)"}) //"Cubos Comparativos - Demonstrativo de Saldos"
aAdd(aRelat,{"PCOR500",STR0012,"PCR500", "(aPerg)"}) //"Cubos Comparativos - Balancete"
aAdd(aRelat,{"PCOR520",STR0013,"PCR520", "(aPerg)"}) //"Cubos Comparativos - Demonstrativo por Periodo"
aAdd(aRelat,{"PCOR530",STR0014,"PCR520", "(aPerg)"}) //"Cubos Comparativos - Dem.Resumido por Periodo"

//Visoes
aAdd(aRelat,{"PCOR030",STR0015 ,"PCR030", "(,aPerg)"}) //"Visao - Estrutura Resumida"
aAdd(aRelat,{"PCOR055",STR0016,"PCR035", "(,aPerg)"}) //"Visao - Estrutura Completa"
aAdd(aRelat,{"PCOR060",STR0017,"PCR030", "(,aPerg)"}) //"Totalizadores da Visao"

dbSelectArea("ALH")
dbSetOrder(01)

For nX := 1 TO Len(aRelat)
	If !dbSeek(xFilial("ALH")+aRelat[nX,1])
		RecLock("ALH", .T.)
		ALH->ALH_FILIAL := xFilial("ALH")
		ALH->ALH_PRGREL := aRelat[nX,1]
		ALH->ALH_TITREL := aRelat[nX,2]
		ALH->ALH_GRPERG := aRelat[nX,3]
		ALH->ALH_PRGPAR := aRelat[nX,4]
		MsUnLock()
	EndIf	
Next

Return