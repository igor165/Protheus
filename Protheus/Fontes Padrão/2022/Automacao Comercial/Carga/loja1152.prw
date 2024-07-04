#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1152.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1152() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCInitialLoadProgress            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe que representa o progresso de carregamento de carga.            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCInitialLoadProgress From FWSerialize
	Data oClient
	Data nStep
	Data oFilesProgress
	Data oTablesProgress
	Data oMessage
	Data lClientUpdated //define se o cliete esta atualizado ou nao
	
	Method New()	
	Method GetStepName()
	Method GetStepBMPName()


EndClass
                 	
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oClient: LJCInitialLoadClient do progresso.                            ���
���             � nStep: Verificar m�todo GetStepName()                                  ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/                 	
Method New( oClient, nStep ) Class LJCInitialLoadProgress
	Self:oClient			:= oClient
	Self:nStep			:= nStep
	Self:lClientUpdated	:= .F.
	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetStepName                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o nome do passo do progresso.                                     ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Nome do passo                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetStepName() Class LJCInitialLoadProgress
	Local cRet := STR0001 // "Desconhecido"

	Do Case
		Case Self:nStep == 1
			cRet := STR0002 // "Conectado"
		Case Self:nStep == 2
			cRet := STR0003 // "Iniciando"
		Case Self:nStep == 3
			cRet := STR0004 // "Baixando"
		Case Self:nStep == 4
			cRet := STR0005 // "Importando"
		Case Self:nStep == 5
			If Self:lClientUpdated
				cRet := STR0011
			Else
				cRet := STR0012
			EndIf
			/*If Self:oTablesProgress ==  Nil
				cRet := STR0006 // "Baixa completada"
			ElseIf Self:oFilesProgress == Nil
				cRet := STR0007 // "Importa��o completada"
			Else
				cRet := STR0008 // "Baixa e importa��o completada"	
			EndIf*/
		Case Self:nStep == -1
			cRet := STR0009 // "Erro"
		OtherWise
			cRet := STR0010 // "Sem informa��o"
	EndCase
Return cRet

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetStepBMPName                    � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o nome do BMP do passo do progresso.                              ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Nome do BMP do passo.                                            ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetStepBMPName() Class LJCInitialLoadProgress
	Local cRet := "BR_CINZA"

	Do Case
		Case Self:nStep == 1
			cRet := "BR_AZUL"
		Case Self:nStep == 2
			cRet := "BR_LARANJA"
		Case Self:nStep == 3
			cRet := "BR_AMARELO"
		Case Self:nStep == 4
			cRet := "BR_PINK"
		Case Self:nStep == 5
			If Self:lClientUpdated
				cRet := "BR_VERDE"
			Else
				cRet := "BR_VERMELHO"
			EndIf
		Case Self:nStep == -1
			cRet := "BR_VERMELHO"
		OtherWise
			cRet := "BR_CINZA"
	EndCase	
Return cRet

