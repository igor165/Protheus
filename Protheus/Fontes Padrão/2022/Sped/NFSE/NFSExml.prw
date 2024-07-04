#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fisa022.ch" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NfdsXml   ³ Autor ³ Roberto Souza         ³ Data ³21/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exemplo de geracao da Nota Fiscal Digital de Serviços       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Xml para envio                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tipo da NF                                           ³±±
±±³          ³       [0] Entrada                                          ³±±
±±³          ³       [1] Saida                                            ³±±
±±³          ³ExpC2: Serie da NF                                          ³±±
±±³          ³ExpC3: Numero da nota fiscal                                ³±±
±±³          ³ExpC4: Codigo do cliente ou fornecedor                      ³±±
±±³          ³ExpC5: Loja do cliente ou fornecedor                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³24/11/10  ³ Vitor Felipe  ³ Incluido geracao de arquivo XML modelo 102 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
			//STR0282 "Fonte não compilado"
			//STR0283 "Problema:Fonte de geração da nota fiscal de serviço eletrônica não compilado. "
			//STR0284 "Solução: Acesse o portal do cliente, baixe o rdmake e compile em seu ambiente."
		autoNfseMsg( "*** Fonte nao compilado ****", .F. )
		autoNfseMsg( " Problema:Fonte de geracao da nota fiscal de servico eletronica nao compilado. ", .F. )
		autoNfseMsg( " Solucao: Acesse o portal do cliente, baixe o rdmake e compile em seu ambiente. ", .F. )
	EndIf

Return(aRetorno)