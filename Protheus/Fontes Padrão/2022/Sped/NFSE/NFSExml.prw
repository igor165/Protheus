#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fisa022.ch" 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �NfdsXml   � Autor � Roberto Souza         � Data �21/05/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Exemplo de geracao da Nota Fiscal Digital de Servi�os       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Xml para envio                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Tipo da NF                                           ���
���          �       [0] Entrada                                          ���
���          �       [1] Saida                                            ���
���          �ExpC2: Serie da NF                                          ���
���          �ExpC3: Numero da nota fiscal                                ���
���          �ExpC4: Codigo do cliente ou fornecedor                      ���
���          �ExpC5: Loja do cliente ou fornecedor                        ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���24/11/10  � Vitor Felipe  � Incluido geracao de arquivo XML modelo 102 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function NFSEXml(cCodMun,cTipo,dDtEmiss,cSerie,cNota,cClieFor,cLoja,cMotCancela,cFuncExec,aAIDF,aTitIssRet,cCodCanc)
	local	aRetorno		:= {"",""}
	local	aDados   		:= {}

	default cMotCancela	:= ""
	default cFuncExec		:= ""
	default dDtEmiss		:= date()
	default aAIDF			:= {""}
	default aTitIssRet	:= {}
	default cCodCanc	:= ""

	aAdd(aDados,cCodMun )
	aAdd(aDados,cTipo   )
	aAdd(aDados,dDtEmiss)
	aAdd(aDados,cSerie  )
	aAdd(aDados,cNota   )
	aAdd(aDados,cClieFor)
	aAdd(aDados,cLoja   )
	aAdd(aDados,cMotCancela)
	aAdd(aDados,aTitIssRet)
	aAdd(aDados,cCodCanc)

	If Empty(cFuncExec)
		cFuncExec := getRDMakeNFSe(cCodMun,cTipo)
	EndIf

	If tssHasRdm(cFuncExec)
		If cFuncExec == "nfseXMLEnv"		
			//aRetorno :=  ExecBlock(cFuncExec,.F.,.F.,{cTipo, dDtEmiss, cSerie, cNota, cClieFor, cLoja, cMotCancela, aAIDF}) (Antiga chamada)
			aRetorno := tssExecRdm(cFuncExec,.T.,{cTipo, dDtEmiss, cSerie, cNota, cClieFor, cLoja, cMotCancela, aAIDF, cCodcanc})
		ElseIf !Empty(cFuncExec)
			//aRetorno 	:= ExecBlock(cFuncExec,.F.,.F.,aDados) (Antiga chamada)
			aRetorno := tssExecRdm(cFuncExec,.T.,aDados)
		EndIf
	Else
		Help(NIL, NIL,STR0282, NIL, STR0283, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0284})
			//STR0282 "Fonte n�o compilado"
			//STR0283 "Problema:Fonte de gera��o da nota fiscal de servi�o eletr�nica n�o compilado. "
			//STR0284 "Solu��o: Acesse o portal do cliente, baixe o rdmake e compile em seu ambiente."
		autoNfseMsg( "*** Fonte nao compilado ****", .F. )
		autoNfseMsg( " Problema:Fonte de geracao da nota fiscal de servico eletronica nao compilado. ", .F. )
		autoNfseMsg( " Solucao: Acesse o portal do cliente, baixe o rdmake e compile em seu ambiente. ", .F. )
	EndIf

Return(aRetorno)