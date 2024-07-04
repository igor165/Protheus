#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM036.CH"

/*/
�������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������Ŀ��
���Funcao    	� GPEM036    � Autor � Alessandro Santos       	                � Data � 30/05/2014 ���
���������������������������������������������������������������������������������������������������Ĵ��
���Descricao 	� Funcoes para eventos periodicos eSocial                   			            ���
���������������������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	� GPEM036()                                                    	  		            ���
���������������������������������������������������������������������������������������������������Ĵ��
���Parametros   � cCompete  - Competencia para geracao dos eventos         						    ���
���             � aArrayFil - Array com as filiais selecionadas em tela       						���
���             � lRetific  - Integracao retificadora                          						���
���             � cIndic13  - Integracao tipo de folha 13/Normal               						���
���������������������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               			            ���
���������������������������������������������������������������������������������������������������Ĵ��
���Analista     � Data     � FNC/Requisito  � Chamado �  Motivo da Alteracao                        ���
���������������������������������������������������������������������������������������������������Ĵ��
���Alessandro S.�30/05/2014�00000016375/2014�   TPSIC2�Inclusao da rotina para periodicos do eSocial���
���             �          �                �         �Evento: Abertura de Folha - S1100            ���
���Marcia Moura |10/07/2014|00000017984/2014|   TPVLRZ�Adicionado chamada para a rotina de abertura ���
���             �          �                �         �de Desoneracao S-1380                        ���
���Alessandro S.�14/07/2014�00000016351/2014�   TPSHOL�Adicionado tratamento para distinguir Logs de���
���             �          �                �         �Gravacao e Erro.                             ���
���Marcia Moura |18/07/2014|                |   TQAUEZ�Adicionado chamada para a rotina de S-1200   ���
���Marcia Moura |11/08/2014|00000014123/2014|   TPNBN5�Programa recompilado com as alteracoes soli- ���
���             |          |                |         �citadas pela rejeicao do SQA                 ���
���Marcia Moura |26/05/2014|DRHESOCP-104    |         �Refeita a geracao do evento S-1280           ���
���Oswaldo L    |05/06/2017|DRHESOCP-372    |         �Layout S1200 para e-social                   ���
���             |          |                |         �Aproveitamos para tratar Projeto SOYUZ e     ���
���             |          |                |         �ajust tela(tinha componentes desposicionados)���
���Oswaldo L    |12/06/2017|DRHESOCP-393    |         �Ajuste gera��o de log do processo S1200      ���
���Oswaldo L    |13/06/2017|DRHESOCP-400    |         �Incluido protecao no fonte de TSV (S2300)    ���
���             |          |                |         �Ajustado tratamento de Plano de Saude\Estabel���
���Oswaldo L    |12/06/2017|DRHESOCP-452    |         �Implementar S1210 para vers�o 12.1.17        ���
���Oswaldo L    |12/06/2017|DRHESOCP-348    |         �Ajustes na rotina do S1210 para              ���
���Oswaldo L    |22/06/2017|DRHESOCP-460    |         �Ajustes identificacao filial correta no seek ���
���             |          |                |         �da verba  (usar sempre PosSRV)               ���
���             |          |                |         �remover fun��o da V11: fVerX14Dec()          ���
���Oswaldo L    |28/07/2017|DRHESOCP-592\709|         �Ajustes pontuados em  testes integrados      ���
���Oswaldo L    |28/07/2017|DRHESOCP-755    |         �Merge e-social 11.80 e 12.1.17               ���
���Eduardo V    �11/08/2017�DRHESOCP-781    �         �Corre��es de erros apontadas a issue 592     ���
���Eduardo V    �04/09/2017�DRHESOCP-1037   �         �Inclus�o da Fun��o FrmTexto que � havia sido ���
���             �          �                �         �migrada da 11 para a 12                      ���
���Renan Borges �13/09/2017�DRHESOCP-1024   �         �Ajuste para n�o levar verbas com natureza de ���
���             �          �                �         �rubrica 1409, 4050, 4051, 1009 para funcion�-���
���             �          �                �         �rios na categoria bolsista e contribuinte in-���
���             �          �                �         �dividual e incluir campo TPDEP no evento     ���
���             �          �                �         �S-1200.                                      ���
���Marcos Cout  �12/10/2017�DRHESOCP-1388   �         �Realizada a cria��o da fun��o respons�vel por���
���             �          �                �         �enviar o evento S-1295 - Solicita��o de Tota_���
���             �          �                �         �liza��o para Pagamento em Conting�ncia       ���
���             �          �                �         �Realizada a cria��o da fun��o respons�vel por���
���             �          �                �         �enviar o evento S-1299 - Fechamento dos even_���
���             �          �                �         �tos Peri�dicos                               ���
���Marcos Cout  �20/10/2017�DRHESOCP-1565   �         �Realizada ajustes para layout 2.4 para a tag ���
���             �          �                �         �<codRubr> na gera��o da folha: Caso CATEFD   ���
���             �          �                �         �seja 'bolsista ou Contrib Individual', n�o   ���
���             �          �                �         �gravar verbas com INCCP '25, 26 e 51         ���
���Cecilia C    �01/11/2017�DRHESOCP-1805   �         �Ajuste na gera��o da compet�ncia do evento   ���
���             �          �                �         �S-1295.                                      ���
����������������������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������*/

Function GPEM036()
/* 
Efetuado quebra da gera��o dos eventos peri�dicos para os fontes abaixo:
* S-1200 -> GPEM036A
* S-1210 -> GPEM036B
* S-1280 -> GPEM036C
* S-1300 -> GPEM036D
* S-1295 -> GPEM036E
* S-1299 -> GPEM036F
*/
Return()

/* Migrado para GPEM036C */
Function fInt1280(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogs, aCheck)
Local lReturn := fNew1280(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, @aLogs, aCheck)
Return lReturn


/* Migrado para GPEM036A */
Function fEfd1200(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogs, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro)
Local lReturn := fNew1200(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, @aLogs, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro)	
Return lReturn


/* Migrado para GPEM036D */
Function fInt1300(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13,aLogs, aCheck)
Local lReturn := fNew1300(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, @aLogs, aCheck)	
Return lReturn


/* Migrado para GPEM036B */
Function fEfd1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogs, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro)
Local lReturn := fNew1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, @aLogs, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro)
Return lReturn


/* Migrado para GPEM036E */
Function fInt1295(cComp, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, aLogs, aFil)
Local lReturn := fNew1295(cComp, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, @aLogs, aFil)
Return lReturn


/* Migrado para GPEM036F */
Function fInt1299(cComp, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, aLogs, aFil)
Local lReturn := fNew1299(cComp, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, @aLogs, aFil)
Return lReturn


/* Migrado para GPEM036A */
Function FrmTexto(cTexto)
FormText(cTexto)
return


/* Migrado para GPEM036A */
Function fBuscaRes(cFilRes, cMatRes, cCompete, dDtRes, l1200, cTpRes, cPerResCmp, aResCompl )
Local lRet := fGetRes(cFilRes, cMatRes, cCompete, @dDtRes, l1200, @cTpRes, @cPerResCmp, @aResCompl)
Return lRet


/* Migrado para GPEM036F */
Function fDlgCompt()
Local cCompete	:= fDlgPer()
Return cCompete


/* Migrado para GPEM036A */
Function fTpAco(lPosiciona, cRotBkp, cCompete, cDataCor, cData, lGpm040)
Local cTipo := fGetTpAc(lPosiciona, cRotBkp, cCompete, @cDataCor, @cData, lGpm040)
Return cTipo


/* Migrado para GPEM036A */
Function fDscAc(lPosiciona, cRotBkp, cCompete, dDtEfeito, lGpm040)
Local cDesc := fGetDscAc(lPosiciona, cRotBkp, cCompete, @dDtEfeito, lGpm040)
Return cDesc


/* Migrado para GPEM034 */
Function fDiagVerbas(cCompete, aArrayFil, aLogs)
fDlgVb(cCompete, aArrayFil, @aLogs)
Return


/* Migrado para GPEM036B */
Function fBuscaRGE(cFilRGE, cMatRGE, cCompete)
Local aItensRGE	:= fGetRGE( cFilRGE, cMatRGE, cCompete)
Return( aItensRGE )
