#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM036.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    	³ GPEM036    ³ Autor ³ Alessandro Santos       	                ³ Data ³ 30/05/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	³ Funcoes para eventos periodicos eSocial                   			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ GPEM036()                                                    	  		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros   ³ cCompete  - Competencia para geracao dos eventos         						    ³±±
±±³             ³ aArrayFil - Array com as filiais selecionadas em tela       						³±±
±±³             ³ lRetific  - Integracao retificadora                          						³±±
±±³             ³ cIndic13  - Integracao tipo de folha 13/Normal               						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alessandro S.³30/05/2014³00000016375/2014³   TPSIC2³Inclusao da rotina para periodicos do eSocial³±±
±±³             ³          ³                ³         ³Evento: Abertura de Folha - S1100            ³±±
±±³Marcia Moura |10/07/2014|00000017984/2014|   TPVLRZ³Adicionado chamada para a rotina de abertura ³±±
±±³             ³          ³                ³         ³de Desoneracao S-1380                        ³±±
±±³Alessandro S.³14/07/2014³00000016351/2014³   TPSHOL³Adicionado tratamento para distinguir Logs de³±±
±±³             ³          ³                ³         ³Gravacao e Erro.                             ³±±
±±³Marcia Moura |18/07/2014|                |   TQAUEZ³Adicionado chamada para a rotina de S-1200   ³±±
±±³Marcia Moura |11/08/2014|00000014123/2014|   TPNBN5³Programa recompilado com as alteracoes soli- ³±±
±±³             |          |                |         ³citadas pela rejeicao do SQA                 ³±±
±±³Marcia Moura |26/05/2014|DRHESOCP-104    |         ³Refeita a geracao do evento S-1280           ³±±
±±³Oswaldo L    |05/06/2017|DRHESOCP-372    |         ³Layout S1200 para e-social                   ³±±
±±³             |          |                |         ³Aproveitamos para tratar Projeto SOYUZ e     ³±±
±±³             |          |                |         ³ajust tela(tinha componentes desposicionados)³±±
±±³Oswaldo L    |12/06/2017|DRHESOCP-393    |         ³Ajuste geração de log do processo S1200      ³±±
±±³Oswaldo L    |13/06/2017|DRHESOCP-400    |         ³Incluido protecao no fonte de TSV (S2300)    ³±±
±±³             |          |                |         ³Ajustado tratamento de Plano de Saude\Estabel³±±
±±³Oswaldo L    |12/06/2017|DRHESOCP-452    |         ³Implementar S1210 para versão 12.1.17        ³±±
±±³Oswaldo L    |12/06/2017|DRHESOCP-348    |         ³Ajustes na rotina do S1210 para              ³±±
±±³Oswaldo L    |22/06/2017|DRHESOCP-460    |         ³Ajustes identificacao filial correta no seek ³±±
±±³             |          |                |         ³da verba  (usar sempre PosSRV)               ³±±
±±³             |          |                |         ³remover função da V11: fVerX14Dec()          ³±±
±±³Oswaldo L    |28/07/2017|DRHESOCP-592\709|         ³Ajustes pontuados em  testes integrados      ³±±
±±³Oswaldo L    |28/07/2017|DRHESOCP-755    |         ³Merge e-social 11.80 e 12.1.17               ³±±
±±³Eduardo V    ³11/08/2017³DRHESOCP-781    ³         ³Correções de erros apontadas a issue 592     ³±±
±±³Eduardo V    ³04/09/2017³DRHESOCP-1037   ³         ³Inclusão da Função FrmTexto que ñ havia sido ³±±
±±³             ³          ³                ³         ³migrada da 11 para a 12                      ³±±
±±³Renan Borges ³13/09/2017³DRHESOCP-1024   ³         ³Ajuste para não levar verbas com natureza de ³±±
±±³             ³          ³                ³         ³rubrica 1409, 4050, 4051, 1009 para funcioná-³±±
±±³             ³          ³                ³         ³rios na categoria bolsista e contribuinte in-³±±
±±³             ³          ³                ³         ³dividual e incluir campo TPDEP no evento     ³±±
±±³             ³          ³                ³         ³S-1200.                                      ³±±
±±³Marcos Cout  ³12/10/2017³DRHESOCP-1388   ³         ³Realizada a criação da função responsável por³±±
±±³             ³          ³                ³         ³enviar o evento S-1295 - Solicitação de Tota_³±±
±±³             ³          ³                ³         ³lização para Pagamento em Contingência       ³±±
±±³             ³          ³                ³         ³Realizada a criação da função responsável por³±±
±±³             ³          ³                ³         ³enviar o evento S-1299 - Fechamento dos even_³±±
±±³             ³          ³                ³         ³tos Periódicos                               ³±±
±±³Marcos Cout  ³20/10/2017³DRHESOCP-1565   ³         ³Realizada ajustes para layout 2.4 para a tag ³±±
±±³             ³          ³                ³         ³<codRubr> na geração da folha: Caso CATEFD   ³±±
±±³             ³          ³                ³         ³seja 'bolsista ou Contrib Individual', não   ³±±
±±³             ³          ³                ³         ³gravar verbas com INCCP '25, 26 e 51         ³±±
±±³Cecilia C    ³01/11/2017³DRHESOCP-1805   ³         ³Ajuste na geração da competência do evento   ³±±
±±³             ³          ³                ³         ³S-1295.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPEM036()
/* 
Efetuado quebra da geração dos eventos periódicos para os fontes abaixo:
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
