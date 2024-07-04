#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "QDOXFUN.CH"

Static __cEmpAnt
Static __cFilAnt 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOXFUN  ³ Autor ³ Newton Rogerio        ³ Data ³ 19/05/00    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotinas genericas do modulo de Documentos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Eduardo S. ³22/01/02³ xxxx ³ Alterado a funcao fQdoTpMail() para enviar  ³±±
±±³            ³        ³      ³ email Html/Texto.                           ³±±
±±³ Eduardo S. ³27/02/02³ META ³ Alterado para gerar Aviso de Docto Vencido e³±±
±±³            ³        ³      ³ Incluido a funcao QDXGVAVISO().             ³±±
±±³ Eduardo S. ³28/02/02³ xxxx ³ Incluido no retorno da funcao QDOPATH()o con³±±
±±³            ³        ³      ³ teudo do parametro "MV_QPATHWH".            ³±±
±±³ Eduardo S. ³05/03/02³ xxxx ³ Incluido a funcao QDUltRvDoc() para retornar³±±
±±³            ³        ³      ³ a ultima revisao do Documento.              ³±±
±±³ Eduardo S. ³15/03/02³ META ³ Otimizacao, Melhoria e alterado os arquivos ³±±
±±³            ³        ³      ³ SRA para QAA / CTT para QAD / SRJ para QAC. ³±±
±±³ Eduardo S. ³19/03/02³ xxxx ³ Incluido a funcao QA_CHKMAN para verificar a³±±
±±³            ³        ³      ³ existencia da Pasta/Manual.                 ³±±
±±³ Eduardo S. ³10/04/02³ xxxx ³ Incluido na funcao fQdoTpMail() a opcao de  ³±±
±±³            ³        ³      ³ email para responsaveis com Doctos Baixados ³±±
±±³            ³        ³      ³ por outro responsavel na baixa Aleatoria.   ³±±
±±³ Eduardo S. ³26/04/02³ Melh.³ Melhoria e Otimizacao na rotina que checa a ³±±
±±³            ³        ³      ³ validade - Inclusao de Query.               ³±±
±±³ Eduardo S. ³13/05/02³ Melh.³ Alterado a funcao fQdoTpMail() para enviar  ³±±
±±³            ³        ³      ³ email tambem para Ausencia Temporaria.      ³±±
±±³ Eduardo S. ³20/05/02³ META ³ Alterado para atualizar os lanc. de Ausencia³±±
±±³            ³        ³      ³ Temporaria na Inicializacao do Modulo.      ³±±
±±³ Eduardo S. ³28/06/02³ META ³ Alteracao na Funcao QDXFNCkSRv() para gerar ³±±
±±³            ³        ³      ³ revisao corretamente para Docto Externo.    ³±±
±±³ Eduardo S. ³18/07/02³ META ³ Incluido a funcao QA_QUALITY / QC_QUALITY e ³±±
±±³            ³        ³      ³ QD_QUALITY util. na integracao c/ SIGAGPE.  ³±±
±±³ Eduardo S. ³21/08/02³ ---- ³ Acerto para gravar a empresa/filial origem  ³±±
±±³            ³        ³      ³ na funcao QA_QUALITY/QC_QUALITY/QD_QUALITY. ³±±
±±³ Eduardo S. ³02/09/02³059419³ Acerto para gerar sequencia automatica de   ³±±
±±³            ³        ³      ³ Documento de conforme o cad. tipo de docto. ³±±
±±³ Eduardo S. ³25/09/02³060298³ Acerto na geracao de nova revisao para atua-³±±
±±³            ³        ³      ³ lizar tambem a tabela QA4.                  ³±±
±±³ Eduardo S. ³23/10/02³060642³ Alterado para sugerir o proximo numero da re³±±
±±³            ³        ³      ³ visao com a qtde de posicoes da rev vigente.³±±
±±³ Eduardo S. ³03/12/02³ ---- ³ Alterado para listar os textos (QA2) apartir³±±
±±³            ³        ³      ³ da funcao QA_RecTxt().                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDXFNPrMsg³ Autor ³Newton Rogerio            ³ Data ³ 19/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Monta Tela de Processamento para Multiplas mensagens.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QDXFNPrMsg( bAction, cTitle, cMsg, lAbort )                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³bAction : Funcao a ser executada                               ³±±
±±³          ³cTitle  : Titulo da janela                                     ³±±
±±³          ³cMsg    : Mensagem do processamento a ser realizado            ³±±
±±³          ³lAbort  : Indica se tera opcao de cancelar o processamento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAQDO - Generico                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNPrMsg( bAction, cTitle, cMsg, lAbort )

Local oDlg


Local lEnd   := .f.
Local nVal   := 0

Private oBmp
Private nBmp := 1
Private nAtual

Default lAbort  := .f.
Default bAction := { || nil }
Default cMsg    := OemToAnsi( STR0001 ) // "Processando"
Default cTitle  := OemToAnsi( STR0002 ) // "Aguarde..."

DEFINE MSDIALOG oDlg FROM 000,000 TO 095,310 TITLE OemToAnsi(cTitle) STYLE DS_MODALFRAME STATUS PIXEL

@ 005,020 SAY oNome VAR OemToAnsi(cMsg) FONT oDlg:oFont SIZE 140,010 OF oDlg PIXEL

@ 015,003 METER oMeter VAR nVal SIZE 150,010 TOTAL 10 OF oDlg PIXEL

oDlg:bStart := {||Eval(bAction,@lEnd),lEnd:= .T.,oDlg:End()}
nBmp:= 1

ACTIVATE DIALOG oDlg VALID lEnd CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDXFNPrReg³ Autor ³Newton Rogerio Ghiraldelli³ Data ³   /  /   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNPrReg(nTotal)

oMeter:nTotal := nTotal
nAtual := 0

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDXFNInPrc³ Autor ³Newton Rogerio Ghiraldelli³ Data ³   /  /   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNInPrc(cMsg)

oMeter:Set(++nAtual)
oNome :SetText(OemToAnsi(cMsg))
SysRefresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDXFNANTPD³ Autor ³ Aldo Marini Junior       ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gatilho para preencher a descricao do Tipo de Documento.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXFNANTPD(ExpC1,ExpC2,ExpL1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Tipo de Documento                           ³±±
±±³          ³ ExpL1 - Gatilho                                               ³±±
±±³          ³ ExpC2 - Filial do Tipo de Documento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO - Generico                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNANTPD(cCodTP,lGatilho,cFilCod)

Default lGatilho:= .T.
Default cFilCod := xFilial("QD2")

If !Inclui .Or. lGatilho
	QD2->(DbSeek(cFilCod+cCodTP))
	Return(QD2->QD2_DESCTP)
Else
	Return(Space(Len(QD2->QD2_DESCTP)))
EndIf

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDXFNANASS³ Autor ³ Aldo Marini Junior       ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gatilho para preencher a descricao do Assunto.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXFNANASS(ExpC1,ExpC2,ExpL1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Assunto                                     ³±±
±±³          ³ ExpL1 - Gatilho                                               ³±±
±±³          ³ ExpC2 - Filial do Assunto                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAQDO - Generico                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNANASS(cCodAss,lGatilho,cFilCod)

Default lGatilho:= .T.
Default cFilCod := xFilial("QD3")

If !Inclui .Or. lGatilho
	QD3->(DbSeek(cFilCod+cCodAss))
	Return(QD3->QD3_DESCAS)
Else
	Return(Space(Len(QD3->QD3_DESCAS)))
EndIf

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDXFNANMAN³ Autor ³ Aldo Marini Junior       ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gatilho para preencher a descricao da Pasta.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXFNANMAN(ExpC1,ExpL1,ExpC2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Codigo da Pasta                                       ³±±
±±³          ³ ExpL1 = Indica se e gatilho                                   ³±±
±±³          ³ ExpC2 = Filial da Pastailho                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAQDO - Generico                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNANMAN(cCodPst,lGatilho,cFilCod)

Local cArea := Alias()

Default lGatilho:= .T.
Default cFilCod := xFilial("QDC")

//If FWModeAccess("QDC") == "C" //Empty(xFilial("QDC"))
//	cFilCod := Space(FWSizeFilial())//Space(2)
//Endif

If !Inclui .Or. lGatilho
	DbSelectArea("QDC")
	DbSetOrder(1)
	IF FWModeAccess("QDC",3) == "E"
		QDC->(DbSeek(cFilCod+cCodPst))
	else
		QDC->(DbSeek(PadR("",FWSizeFilial())+cCodPst))
	Endif
	
	Return(QDC->QDC_DESC)
Else
	DbSelectArea(cArea)
	Return(Space(Len(QDC->QDC_DESC)))
EndIf

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QA_CHKMAN³ Autor ³ Eduardo de Souza      ³ Data ³ 19/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validar o C.Custo do Depto/Usuario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA_CHKMAN(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Filial                                   ³±±
±±³          ³ ExpC2 - Codigo da Pasta / Manual                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_CHKMAN(cFilCod,cPasta)

Local cArea := Alias()
Local lRet  :=.T.                      

Default cFilCod:= xFilial("QDC")                  

If QDC->(!DbSeek(cFilCod+cPasta))
	Help(" ",1,"QD050PNE")	// "Pasta nao Cadastrada"
	lRet:= .F.
EndIf
                     
IF lRet 
	IF QDC->QDC_STATUS=="2"	//INATIVO     
		Help(" ",1,"QD050PNE",,OemToAnsi(STR0207),1 )	// "Pasta nao Cadastrada"                        		 //"Pasta Inativa!            "
		lRet:= .F.                                                                                              
	Endif	
Endif

DbSelectArea(cArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QA_NSIT  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 24.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher a descricao do Status Docto Tab. Q7 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA_NSIT(ExpC1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Status                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_NSIT(cStatus)

Default cStatus:= QDH->QDH_STATUS

If !Empty(QDH->QDH_DTVIG) .And. dDatabase < QDH->QDH_DTVIG .And. cStatus == "L  "
	cStatus := " "
EndIf

If	SX5->(DbSeek(xFilial("SX5")+"Q7"+cStatus))
	Return(OemToAnsi(Left(X5Descri(),50)))
Else
	Return(Space(50))
EndIf

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDO_SEQDOC³ Autor ³ Aldo Marini Junior    ³ Data ³ 24.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Numero Sequencial                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO_SEQDOC(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tipo de Sequencia (REF/CRI/LOG)                    ³±±
±±³          ³ ExpN1 - Tamanho do numero                                  ³±±
±±³          ³ ExpN2 - Tipo de Numero (Numerico/Caracter)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO_SEQDOC(cTipo,nTam,cNum)

Return (STRZERO(VAL(QA_SEQU(M->QDH_DOCTO+M->QDH_RV+cTipo,nTam,cNum,M->QDH_FILIAL)),nTam))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDO_SEQ  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 24.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Sequencia do Documento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDO_SEQ(ExpC1,ExpN1,ExpN2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tipo de Sequencia (REF/CRI/LOG)                    ³±±
±±³          ³ ExpN1 - Tamanho do numero                                  ³±±
±±³          ³ ExpN2 - Tipo de Numero (Numerico/Caracter)                 ³±±
±±³          ³ ExpC2 - Filial                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO_SEQ(cTipo,nTam,cNum,cFilCod)

Return (STRZERO(VAL(QA_SEQU(cTipo,nTam,cNum,cFilCod)),nTam))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CHKDOCTO ³ Autor ³ Aldo Marini Junior    ³ Data ³ 26.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se Documento Existe                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CHKDOCTO(ExpC1,ExpC2,ExpC3)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Filial                                   ³±±
±±³          ³ ExpC2 - Codigo do Documento                                ³±±
±±³          ³ ExpC3 - Codigo da Revisao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CHKDOCTO(cFilCod,cDocto,cRv)

If QDH->(DbSeek(cFilCod+cDocto+cRv))
	Help(" ",1,"QD050DOCJE")	// Documento ja existe
	Return .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QA_CHKCC ³ Autor ³ Aldo Marini Junior    ³ Data ³ 05.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validar o C.Custo do Depto/Usuario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA_CHKCC(ExpC1,ExpC2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Filial                                   ³±±
±±³          ³ ExpC2 - Codigo do Departamento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_CHKCC(cFilCod,cCCusto)
Local aArea := GetArea()
Local lRet  :=.T.

Default cFilCod:= xFilial("QAD")

cFilCod := xFilial("QAD",cFilCod)


DbSelectArea("QAD")
DbSetOrder(1)
If QAD->(!DbSeek(cFilCod+cCCusto))
	Help(" ",1,"QD050CCNE")	// C.Custo/Depto nao Existe
	lRet:= .F.
EndIf


RestArea(aArea)
Return lRet

/*/{Protheus.doc} QAC_CHKCC
	Valida o campo cargo
	@type  Function
	@author celio.pereira
	@since 04/08/2022
	@version 12.1.33
	@param cFilCod, cCCusto
	@return lRet
	/*/
Function QA_CHKCAR(cFilCod,cCCusto)
Local aArea := GetArea()
Local lRet  :=.T.

Default cFilCod:= xFilial("QAC")

cFilCod := xFilial("QAC",cFilCod)



DbSelectArea("QAC")
DbSetOrder(1)
If QAC->(!DbSeek(cFilCod+cCCusto))
	Help(,,STR0257,,STR0258,1,0)
	lRet:= .F.
EndIf

RestArea(aArea)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fNivResp ³ Autor ³ Aldo Marini Junior    ³ Data ³ 10/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecionar os Niveis de Responsabilidades do Doctos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fNivResp()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fNivResp()

Local cTitulo  := OemToAnsi(STR0003)   //"N¡veis de Responsabilidades"
Local cMvPar   := ""
Local cMvRet   := ""
Local cMvParDef:= ""
Local cAlias   := Alias()
Local aSx5     := {}
Local nX

Private aNiv:={}

cMvPar:= &(Alltrim(ReadVar())) // Carrega Nome da Variavel do Get em Questao
cMvRet:= Alltrim(ReadVar())     // Iguala Nome da Variavel ao Nome variavel de Retorno

aSx5 := FWGetSX5("00Q7")
If !Empty(aSx5) .And. cFilial == aSx5[1][1]
	cTitulo := Alltrim(Left(aSx5[1][4],30))
EndIf

aSx5 := FWGetSX5("Q7")
If !Empty(aSx5)
	For nX := 1 To Len(aSx5)
		If SubStr(aSx5[nX][3],2,1) <> "C" .And. cFilial == aSx5[nX][1]
			Aadd(aNiv,Alltrim(aSx5[nX][4]))
			cMvParDef+= Left(aSx5[nX][3],1)
		EndIf
	Next nX
Else
	Help(" ",1,"QDXNIVDEF") // Estou usando Niveis Default, nao achei tabela
	aNiv:={OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009)} //"Digita‡„o" ### "Elabora‡„o" ### "Revis„o" ### "Aprova‡„o" ### "Homologa‡„o" ### "Distribui‡„o"
	MvParDef:= "DERAHDT"
EndIf

F_opcdoc(@cMvPar,cTitulo,aNiv,cMvParDef,12,49) // Chama funcao F_opcdoc
&cMvRet := cMvpar // Devolve Resultado

DbSelectArea(cAlias)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ F_opcdoc ³ Autor ³ Ze Maria              ³ Data ³ 14/12/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecionar Opcoes dentro de um Achoice                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F_opcdoc(ExpC1,ExpC2,ExpA1,ExpC3,ExpN1,ExpN2)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Variavel de Retorno                                ³±±
±±³          ³ ExpC2 - Titulo da Janela                                   ³±±
±±³          ³ ExpA1 - Opcoes de Escolha (Array de Opcoes)                ³±±
±±³          ³ ExpC3 - String de Opcoes para Retorno                      ³±±
±±³          ³ ExpN1 - Linha - Superior Esquerdo                          ³±±
±±³          ³ ExpN2 - Coluna - Superior Esquerdo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function F_opcdoc(cVarRet,cTitulo,aOpcoes,cOpcoes,nLin1,nCol1)

Local oDlg
Local oListbox
Local nFor       := 0

Local cRet       := cVarRet
Local aListBox   := {}

Local nOpcao     := ""


Local oOk        := LoaDbitmap(GetResources(),"LBOK")
Local oNo        := LoaDbitmap(GetResources(),"LBNO")

nLin1 := 0.5
nCol1 := 002

For nFor := 1 to Len(aOpcoes)
	Aadd(aListBox,{.F.,aOpcoes[nFor]})
	If Subs(cOpcoes,nFor,1) $ cVarRet
		aListBox[Len(aListBox),1] := .T.
	EndIf
Next nFor

DEFINE MSDIALOG oDlg FROM 005,005 TO 016,050 TITLE OemToAnsi(STR0010) // "Escolha Padrao"

@ nLin1,nCol1 LISTBOX oListBox  NOSCROLL ;
					FIELDS HEADER " ",OemToAnsi(cTitulo);
					SIZE 150,57 ;
					ON DbLCLICK (aListBox[oListBox:nat,1]:= !aListBox[oListBox:nat,1] ,oListBox:Refresh())

oListBox:SetArray(aListBox)
oListBox:bLine := { || {If(aListBox[oListBox:nAt,1],oOk,oNo),aListBox[oListBox:nAt,2]}}

DEFINE SBUTTON FROM 065,112   TYPE 1 ACTION (nOpcao:= 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 065,139.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1
	cRet := ""
	For nFor := 1 To Len(aListBox)
		cRet += If(aListBox[nFor,1],Subs(cOpcoes,nFor,1),"*")
	Next
EndIf

cVarRet := cRet

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QA_CHKNIV³ Autor ³ Aldo Marini Junior    ³ Data ³ 15.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VerIfica o Usuario p/ ver esta habilitado a ser responsavel³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA_CHKNIV(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao do Registro                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_CHKNIV(nItem, cFilCod, lVAcols)

Local lRet := .T.
Local nPos0:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) = "QD0_AUT" 	})
Local nPos1:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) = "QD0_FILMAT" })
Local nPos2:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) = "QD0_MAT" })

Default cFilCod := xFilial("QDD")
Default lVAcols := .F.

If QDD->(DbSeek(cFilCod+M->QDH_CODTP))
	While QDD->(!Eof()) .And. cFilCod+M->QDH_CODTP == QDD->QDD_FILIAL+QDD->QDD_CODTP
		If QDD->QDD_AUT == aCols[nItem,nPos0]
			lRet:=.F.
			If QDD->QDD_FILA+QDD->QDD_DEPTOA+QDD->QDD_CARGOA == QA_VerUsr(aCols[nItem,nPos2], nItem, lVAcols)
				lRet:=.T.
				Exit
			EndIf
		EndIf
		QDD->(DbSkip())
	Enddo
EndIf

If !lRet
	Help(" ",1,"QDFUNCNP") 	// Funcionario nao tem permissao p/ responsavel
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QA_VerUsr ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 10/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Chave a ser comparada                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_VerUsr(cCodUsr, nItem, lVAcols)
Local cRet   := ""
Local aArea  := GetArea()
Local nPos1:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) = "QD0_FILMAT" })

cRet := aCols[nItem,nPos1]+QAA->QAA_CC+QAA->QAA_CODFUN

If lVAcols
	DbSelectArea("QAA")
	DbSetOrder(1) 
	If DbSeek(aCols[nItem,nPos1]+cCodUsr)
		cRet := aCols[nItem,nPos1]+QAA->QAA_CC+QAA->QAA_CODFUN
	EndIf 
Endif

RestArea(aArea)
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QA_GRAVCPS³ Autor ³ Aldo Marini Junior    ³ Data ³ 17/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Gravacao dos Campos do aHeader                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA_GRAVCPS(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numero atual do registro (linha do Acols)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_GRAVCPS(nReg)

Local nF     := 0
Local nItem  := 0
Local cCampo := ""
Local cAlias := Alias()
Local cArqCpo:= ""

For nF := 1 TO FCOUNT()
	cCampo:= UPPER(ALLTRIM(FieldName(nF)))
	nItem := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == cCampo })
	If nItem > 0
		cArqCpo := cAlias+"->"+cCampo
		&( cArqCpo ) := aCols[nReg,nItem]
	EndIf
Next nF

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FTLIMITE ³ Autor ³ Aldo Marini Junior    ³ Data ³ 10/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de VerIficacao do Tempo Limite(Responsavel)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FTLIMITE(ExpC1,ExpD1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Documento (Filial+Docto+Rv                         ³±±
±±³          ³ ExpD1 - Data                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FTLIMITE(cCodigo,dData)

Local nDias:= 0

If QD0->(DbSeek(cCodigo))
	While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == cCodigo
		If QD0->QD0_FILMAT+QD0->QD0_DEPTO+QD0->QD0_MAT+QD0_AUT == QD1->QD1_FILMAT+QD1->QD1_DEPTO+QD1->QD1_MAT+SubStr(QD1->QD1_TPPEND,1,1)
			nDias := QD0->QD0_TLIM
			Exit
		EndIf
		QD0->(DbSkip())
	Enddo
EndIf

Return DTOC(If(nDias > 0,dData+nDias,CTOD("","DDMMYY")))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD050CkTpC³ Autor ³ Aldo Marini Junior    ³ Data ³ 19.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o Tipo de Documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD050CkTpC(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Tipo de Documento                        ³±±
±±³          ³ ExpC2 - Descricao do Tipo de Documento                     ³±±
±±³          ³ ExpC3 - Filial do Tipo de Documento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050CkTpC(cTpCod,cTpDes,cFilCod)

Default cFilCod:= xFilial("QD2")

If Empty(cTpCod)
	Return .T.
EndIf

If QD2->(!DbSeek(cFilCod+cTpCod))
	Help(" ",1,"QD050TDNE")	// Tipo de Documento nao existe
	Return .F.
EndIf

cTpDes:= QDXFNANTPD(cTpCod,.F.)

oMsGet:Refresh()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QD050CkCAs³ Autor ³ Aldo Marini Junior    ³ Data ³ 19.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o Codigo do Assunto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD050CkCAs(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Assunto                                  ³±±
±±³          ³ ExpC2 - Descricao do Assunto                               ³±±
±±³          ³ ExpC3 - Filial do Assunto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD050CkCAs(cCodAss,cDesAss,cFilCod)

If Empty(cCodAss)
	Return .T.
EndIf

If QD3->(!DbSeek(cFilCod+cCodAss))
	Help(" ",1,"QD050CANE")	// Codigo de Assunto nao existe
	Return .F.
EndIf

cDesAss:= QDXFNANASS(cCodAss,.F.)
oMsGet:Refresh()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ChkDepto ³ Autor ³ Aldo Marini Junior    ³ Data ³ 14.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o C.Custo/Depto                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChkDepto(ExpN1,ExpC1,ExpC2,ExpC3,ExpC4)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao do Registro (Acols)                        ³±±
±±³          ³ ExpC1 - Codigo Centro de Custo                             ³±±
±±³          ³ ExpC2 - Filial Centro de Custo                             ³±±
±±³          ³ ExpC3 - Nome Centro de Custo                               ³±±
±±³          ³ ExpC4 - Chave                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ChkDepto(nItem,cDepto,cFilCod,cNDepto,cChave)

Local lQAAchou	:= .F.

Default cChave := M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
Default cFilCod:= xFilial("QAD")

If Empty(cDepto)
	Return .T.
EndIf

If QAD->(!DbSeek(cFilCod+cDepto))
	Help(" ",1,"QD050CCNE")	// Depto nao Existe
	Return .F.
EndIf

cNDepto := QA_NDEPT(cDepto,.T.,cFilCod)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Destinatario for Tipo Pasta e se existe Responsavel pelo C.Custo/Depto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nItem == 2 .And. (Empty(QAD->QAD_FILMAT) .Or. Empty(QAD->QAD_MAT))
	Help(" ",1,"QD050CCNER")	// Nao existe responsavel para este Depto
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se o depto ja foi cadastrado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QDJ->(DbSeek(cChave+If(nItem == 1,"D","P")+cFilCod+cDepto))
	If nItem == 1
		Help(" ",1,"QD050DJE") 	// Depto ja cadastrado
	Else
		Help(" ",1,"QD050PJE")	// Pasta/Depto ja cadastrada
	EndIf
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se existe pastas cadastradas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nItem == 2	// Pastas
	If QDC->(!DbSeek(cFilCod))
		Help(" ",1,"QD050PNE")	// Nao existe Pastas cadastradas
		Return .F.
	EndIf
EndIf

If nItem == 1 // Usuarios
	QAA->(DbSetOrder(2))
	QAA->(DbSeek(cFilCod+cDepto))
	While !QAA->(Eof()) .And. QAA->QAA_FILIAL+QAA->QAA_CC == cFilCod+cDepto
		If QAA->QAA_TPRCBT <> "4" .And. QA_SitFolh()
			lQAAchou := .T.
			Exit
		Endif
		QAA->(dbSkip())
	Enddo
	If !lQAAchou
		Help(" ",1,"QD050NEUSR")	// Nao existe Usuario p/ esse C Custo
		Return .F.
	Endif
Endif

If QAD->QAD_STATUS == "2" // Inativo
	Help(" ",1,"QD050CCINA")	// Centro de Custo/Depto Inativos
	Return .F.
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDXFNCkRes³ Autor ³ Aldo Marini Junior    ³ Data ³ 24.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida os Responsaveis                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXFNCkRes(ExpA1,ExpL1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo os niveis                           ³±±
±±³          ³ ExpL1 - Identifica a Chamada QD0                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNCkRes(aNiveis,lQD0)

Local lRet := .F.
Local nInd := 0
Local nIt  := 0

Default aNiveis:= {}
Default lQD0   := .T.

If M->QDH_STATUS == "L  " .Or. Empty(nQD0Aut) //Proteção variavel nQD0Aut
	Return .T.
Endif

If lQD0
	For nInd := 1 To Len(aQD0Doc)
		If aQD0Doc[nInd,Len(aHedDoc[1])+1] == .F.
			If (nIt := Ascan(aNiveis,{|X| X[1] == aQD0Doc[nInd,nQD0Aut]})) > 0
				aNiveis[nIt,2]++
			Else
				Aadd(aNiveis,{aQD0Doc[nInd,nQD0Aut],1})
			EndIf
		EndIf
	Next nInd
EndIf

If Len(aNiveis) > 0
	lRet:= .T.
	If QD5->(DbSeek(xFilial("QD5")+M->QDH_CODTP))
		While QD5->(!Eof()) .And. M->QDH_FILIAL + M->QDH_CODTP == QD5->QD5_FILIAL + QD5->QD5_CODTP .And. lRet
			If (nIt:= Ascan(aNiveis,{ |X| X[1] == QD5->QD5_AUT })) > 0
				If aNiveis[nIt,2] < QD5->QD5_NMIN
					lRet:= .F.
					Loop
				EndIf
			Else
				lRet:= .F.
				Loop
			EndIf
			QD5->(DbSkip())
		Enddo
		If !lRet
			If QD5->QD5_AUT == "E"			// Elaborador
				MsgAlert(OemToAnsi(STR0012+" "+Str(QD5->QD5_NMIN,2)),OemToAnsi(STR0011))        // "O n£mero m¡nimo de Elaboradores ‚"  ### "Aviso"
			ElseIf QD5->QD5_AUT == "R"		// Revisor
				MsgAlert(OemToAnsi(STR0013+" "+Str(QD5->QD5_NMIN,2)),OemToAnsi(STR0011))        // "O n£mero m¡nimo de Revisores ‚"  ### "Aviso"
			ElseIf QD5->QD5_AUT == "A" 		// Aprovador
				MsgAlert(OemToAnsi(STR0014+" "+Str(QD5->QD5_NMIN,2)),OemToAnsi(STR0011))        // "O n£mero m¡nimo de Aprovadores ‚"  ### "Aviso"
			ElseIf QD5->QD5_AUT == "H" 		// Homologador
				MsgAlert(OemToAnsi(STR0015+" "+Str(QD5->QD5_NMIN,2)),OemToAnsi(STR0011))        // "O n£mero m¡nimo de Homologadores ‚"  ### "Aviso"
			EndIf
		EndIf
	EndIf
Else
	MsgAlert(OemToAnsi(STR0016),OemToAnsi(STR0017)) //"Faltam Respons veis do Documento." ### "Respons veis"
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QDXFNDsDtr ³ Autor ³ Aldo Marini Junior   ³ Data ³ 11/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a Descricao do Tipo de Recebimento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXFNDsDtr(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tipo de Recebimento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNDsDtr(cTipo)

Local aDescR:=	{{1,OemToAnsi(STR0018)},; // "Eletr“nicas"
					 {2,OemToAnsi(STR0019)},; // "Papel"
					 {3,OemToAnsi(STR0020)},; // "Ambos"
					 {4,OemToAnsi(STR0021)}}  // "N„o Recebe"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada que Monta Array com outras tipos de Copias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					 
If ExistBlock("QDOAP21")
	aDescR:=ExecBlock("QDOAP21",.F.,.F.,aDescR)	
Endif					 

If Val(cTipo) == 0
	If Inclui
		Return(Space(11))
	Else
		Return(aDescR[4,2])
	EndIf
Else
	Return(aDescR[Val(cTipo),2])
EndIf

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CHKSEQDOC  ³ Autor ³ Aldo Marini Junior   ³ Data ³ 06/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Proximo Numero do Docto e Rv                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CHKSEQDOC()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO - Nao Funciona no Gatilho                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CHKSEQDOC()
Local aAreaQDH  := {}
Local cCodigo   := ""
Local cFiltro   := ""
Local cTextoAux := ""
Local nCt       := 0

If GETMV("MV_QNSEQDC") == "S"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Numero sequencial do documento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QD2->(DbSeek(xFilial("QD2")+M->QDH_CODTP))		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso sigla seja branco nao executado a numeracao automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If QD2->QD2_QSEQ == 0
			Return .T.
		EndIf
	
		cCodigo  := ALLTRIM(QD2->QD2_SIGLA)					
		cTextoAux:= cCodigo+StrZero(1,QD2->QD2_QSEQ)
		
		aAreaQDH := QDH->(GetArea())
		DbSelectArea("QDH")
		DbSetOrder(1)
		Set Filter to
		nCt:= 1

		FreeUsedCode()
		Help := .T.	// Nao apresentar Help MayUse

		While ValDocto(cTextoAux)
			cTextoAux:= cCodigo+StrZero(nCt++,QD2->QD2_QSEQ)
			Help := .T.	// Nao apresentar Help MayUse
		Enddo
		
		Help := .F.	// Habilito o help novamente
		M->QDH_DOCTO := PADR(cTextoAux,TamSX3( "QDH_DOCTO" )[1])
		M->QDH_RV    := "000"	
		M->QDH_REVINV:=INVERTE(M->QDH_RV)
		cFiltro := Qd050Filtro()
		Set Filter to &(cFiltro)
		RestArea(aAreaQDH)
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QDXFNCkSRv ³ Autor ³  Newton R. Ghiraldelli ³ Data ³ 15/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Proximo numero da Revisao e duplica os dados do     ³±±
±±³          ³ Docto para a proxima revisao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXFNCkSRV(ExpC1,ExpN1,ExpN2,ExpL1,ExpC2)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 - Alias do arquivo QA2                                  ³±±
±±³          ³ ExpN1 - Numero da Opcao do Cadastro                           ³±±
±±³          ³ ExpN2 - Numero do Registro do Alias()                         ³±±
±±³          ³ ExpL1 - Expressao Logica definindo procura de Responsavel     ³±±
±±³          ³ ExpC2 - Indica a especie de procura ( Docto ou Solicitacao )  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAQDO - Generico                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNCkSRv(cAlias,nOpc,nReg,lChkResp,cEsp)

Local aQPath   := QDOPATH()
Local cQPath	:= aQPath[1] // Diretorio que contem os .CEL
Local nC       := 0
Local nI       := 0
Local nRegArq  := 0
Local lRespRv  := .F.
Local cCodAut  := ""
Local cCampo   := ""
Local cAreaG   := ""
Local cTexto   := ""
Local cArqCpo  := ""
Local cExpFilt := ""
Local aArquivos:= {}
Local aUsrMat  := QA_USUARIO()
Local cMatFil  := aUsrMat[2]
Local cMatCod  := aUsrMat[3]
Local cMatDep  := aUsrMat[4]
LocaL cQa4Chave:= ""
Local lRevFut  := .F.
Local cQdgDepto:= ""	// Departamento correto para o QDG
Local nCpo
Local nCont                                   
Local lDelRev  := GetMv("MV_QDLHREV")=="S"  // "S" / "N"
Local lDupExt  := GETMV("MV_QDUPEXT")=="1"  //1=SIM ; 2=NAO Duplica o Documento externo na Revisao.                                                               
Local aTipoTxt :={"OBJ     ","TXT     ","COM     ","REV     ","SUM     ","CRI     ","CRT     ","ITA     ","RED     "} 
Local nLoATxt                 
Local lMvQdoRevd:= GetMv("MV_QDOREVD",.F.,"2") == "1" //1=SIM ; 2=NAO Denife se o Digitador pode Gerar Revisao.
Local nDias    	:= GetMV("MV_QDIALIM")
Local dDtAten   := CTOD(SPACE(8))     
Local cHist		:= ""
Local cTxAVenc	:= ""
Local nPosFlag  
Local lQdReva   := GetMv("MV_QDREVAL",.F.,"1")=="1" //Define o Uso da Rotina de Revalidacao 1=SIM 2=NAO 
Local cQuery	:= ""
Local aARea		:= {}
Local nOrdQd1 	:= QD1->(IndexOrd())
Local nOrdQAA	:= 0
Local nOrdeQD0  := 0
Local nPosAUT	:= 0
Local nPosFILMAT:= 0
Local nPosCC	:= 0 
Local nPosMAT	:= 0
Local nPosORDEM := 0
Local nOrdQD0	:= 0
Local nPosHead	:= 0
Local cOrdQD0	:= ""
Local lMvQgint	:= GetMV("MV_QGINT",.F.,"N") == "S"
Local lMsg		:= .F.
Local nRQD0ini
Local nRegQD0
Local cCod      := ""
Local cChaveAnt :=QDH->QDH_CHAVE
Local lQDOALTMR := ExistBlock("QDOALTMR")
Local cFiltro	:= ""
Local cQRetDest:= GetMV("MV_QDODEST",.F.,"1")
Local lQDOA050M := Existblock("QDOA050M")
Local lQDOAP16  := ExistBlock("QDOAP16")
Local aStruQD0  := FWFormStruct(3, "QD0")[3]
Local nX

Private cRv    := M->QDH_RV
Private aDoctos:= {}
Private lSAD   := If(cEsp == NIL,.F.,If(AllTrim(cEsp) == "SAD",.T.,.F.))


Default cEsp    := ""
Default lChkResp:= .T. 
 
If Type("lQdBlorv") == "U"
	Private lQdBlorv:= GetMv("MV_QDBLORV",.F.,"2")=="1" //1=SIM ; 2=NAO Define o Bloqueio do botao Gera Revisao quando a Solicitacoes pendentes 
Endif                   

If Empty(M->QDH_DOCTO)
	Return .f.
Endif

DbSelectArea("QDH")
QDH->(DbSetOrder(1))
Set Filter to

If !QDH->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO))
	M->QDH_RV    := "000"
	M->QDH_REVINV:=INVERTE(M->QDH_RV)
	QD050ApAll()
	Return Inclui
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria vetor com todas as ocorrencias (revisoes) do documento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !QDH->( Eof() ) .And. QDH->QDH_FILIAL + QDH->QDH_DOCTO == M->QDH_FILIAL + M->QDH_DOCTO
	Aadd(aDoctos,{QDH->QDH_OBSOL,QDH->QDH_STATUS,QDH->QDH_RV,QDH->QDH_CHAVE,QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV,QDH->QDH_CANCEL})
	QDH->(DbSkip())
Enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena o Array por ordem de Revisao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDoctos:= aSort(aDoctos,,,{ |x,y| Val(x[3]) < Val(y[3]) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura pelas ocorrencias das revisoes obsoletas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nC := Len(aDoctos) To 1 STEP -1

// Volta a numeracao caso obsoleto e em leitura ou cancelado

	If aDoctos[nC,1] == "S" .And. (aDoctos[nC,2] $ "L  " .OR. aDoctos[nC,6] = "S")
		nC++
		Exit
	Endif
Next nC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura pela ultima revisao e se a mesma nao for leitura ou for obsoleta nao permite gerar nova revisao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nC < 1 .Or. nC > Len(aDoctos)
	nC := Len(aDoctos)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura pela ultima revisao e se a mesma nao for leitura ou for obsoleta nao permite gerar nova revisao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QDH->(DbSeek(aDoctos[Len(aDoctos),5]))
If QDH->QDH_FUTURA $ "G,R"
	lRevFut := .T.
Endif

If 	! QDH->QDH_STATUS $ "L  " .Or. QDH->QDH_OBSOL == "S" .or.;
	QDH->QDH_CANCEL == "S" .Or. lRevFut
	Help( " ", 1, "QD050NGRV" ) // Nao pode gerar Revisao se nao for Status de leitura, Modificacao em Andamento ou Obsoleto.
	// Filtra os Doctos cancelados e obsoletos
	cExpFilt := Qd050Filtro()
	Set Filter To &(cExpFilt)
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra os Doctos cancelados e obsoletos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cExpFilt:= Qd050Filtro()
Set Filter To &(cExpFilt)
QDH->(DbSeek(aDoctos[nC,5]))

cOLD_DOCTO := QDH->QDH_DOCTO
cOLD_RV    := QDH->QDH_RV
cOLD_DATA  := QDH->QDH_DTLIM
cCodAut    := " "
lRespRv    := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se usuario faz parte dos responsanveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lChkResp
	DBSelectArea("QD0")
	QD0->(DbSetOrder(1))
	If QD0->(DbSeek(QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV))
		nRQD0ini:=QD0->(Recno())
		While QD0->(!Eof()) .And. QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV == QD0->QD0_FILIAL + QD0->QD0_DOCTO + QD0->QD0_RV
			If !QA_SitAuDP(QD0->QD0_FILMAT,QD0->QD0_MAT,QD0->QD0_AUT)
				If QD0->QD0_FILMAT + QD0->QD0_MAT == cMatFil + cMatCod .and. QD0->QD0_FLAG <> "I"
					cCodAut:= QD0->QD0_AUT		 
		   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se Responsavel pode Gerar Revisao ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If QD5->(DbSeek(xFilial("QD5") + QDH->QDH_CODTP + QD0->QD0_AUT))
						If QD5->QD5_GREV == "S"
							lRespRv := .T.
							Exit
						Endif
					Endif
				EndIf 
			Else
				DbSelectArea("QAF")
				DbSetOrder(1) 

				DbSelectArea("QAE")
				DbSetOrder(2)
				cFiltro := 'QAE_FILIAL == "'+xFilial("QAE")+'"'
				cFiltro += ' .And. QAE_STATUS == "1" .And. QAE_MODULO == '+AllTrim(Str(nModulo))
				cFiltro += ' .And. DtoS(QAE->QAE_DTINIC) <= "'+DtoS(dDataBase)+'" .And. DtoS(QAE->QAE_DTPREV) >= "'+DtoS(dDataBase)+'"'
				Set Filter To &(cFiltro)

				If QAE->(DbSeek(QD0->QD0_FILMAT+QD0->QD0_MAT+"1"))
					While QAE->(!Eof())
						If QAF->(DbSeek(xFilial("QAE")+QAE->QAE_ANO+QAE->QAE_NUMERO+PADR(QD0->QD0_AUT,TAMSX3("QAF_TPPEND")[1])+cMatFil+cMatCod))						
							cCodAut:= QD0->QD0_AUT		 
				   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se Responsavel pode Gerar Revisao ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If QD5->(DbSeek(xFilial("QD5") + QDH->QDH_CODTP + QD0->QD0_AUT))
								If QD5->QD5_GREV == "S"
									lRespRv := .T.
									Exit
								Endif
							Endif
						EndIf
						QAE->(DbSkip())
					EndDo
				EndIf
			EndIf
			QD0->(DbSkip())
		Enddo
		nRegQD0:=QD0->(Recno())   
		QD0->(DbGoto(nRQd0ini))
		While QD0->(!Eof()) .And. QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV == QD0->QD0_FILIAL + QD0->QD0_DOCTO + QD0->QD0_RV
			If QD0->QD0_FILMAT + QD0->QD0_MAT == cMatFil + cMatCod
				If lMvQgint
					DbSelectArea("QAA")
					DbSetOrder(6)

   					If QAA->(DbSeek(TRIM(UPPER(SubStr(cUsuario,7,15)))))
	   					If QAA->QAA_TPUSR == "1"
	   						IF QD0->QD0_DEPTO <> cMatDep
	   						   lmsg:= .T.
	   						Else
	   							lmsg:= .F.   
	   						Endif
						Endif
					Endif

   				Endif
			EndIf
			QD0->(DbSkip())
		Enddo
		If lMsg
			MessageDlg(STR0210,,3)//"O usuário logado está como funcionário e foi transferido de departamento mas não teve as pendências transferidas, não poderá gerar revisão"
	    	Return( .F. )
	  	Else
	  		QD0->(DBGOTO(nRegQD0))
	  	Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Permite o Digitador Gerar Revisao Conf.parametro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF (Empty( cCodAut ) .Or. !lRespRv) .AND.  lMvQdoRevd
		QD1->(DbSetOrder(2))
		IF QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+"D  "))
			While QD1->(!Eof()) .And. QD1->QD1_DOCTO == M->QDH_DOCTO .And. QD1->QD1_RV == M->QDH_RV
				IF QD1->QD1_FILMAT+QD1->QD1_MAT == cMatFil+cMatCod .And. QD1->QD1_SIT <> "I"
					cCodAut:= "D"
					lRespRv:= .T.
					Exit
				Endif
				QD1->(DbSkip())
			EndDo
		Endif 
		QD1->(DbSetOrder(nOrdQd1))
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processo de Revalidacao do Documento Vencido    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If lQdReva .AND. !EMPTY(QDH->QDH_DTLIM) .AND. !lSAD //tem Data Limite e Nao e Solicitacao de Revisao

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a Existencia do Aviso de VEN (DOC VENCIDO) Pois e um Usuario nao Autorizado para ³
		//³Gerar Revisao e esse aviso garante a existencia de uma Ausencia Temporaria 				 ³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If Empty(cCodAut) .Or. !lRespRv
			QDS->(DbSetOrder(1))
			If !QDS->(DbSeek(cMatFil+cMatCod+"P"+"VEN"+QDH->QDH_DOCTO+QDH->QDH_RV))
				MsgAlert(OemToAnsi(STR0022),OemToAnsi(STR0023)) // "Usu rio n„o autorizado a gerar revis„o"  ### "Aten‡„o"
				Return( .F. )							 
            Endif			
		Endif
				
		IF (dDatabase >= QDH->QDH_DTLIM)
			cTxAVenc:=OemToAnsi(STR0173)  //"Documento está com a data de validade vencida! Gera revalidação?"
		ElseIF (dDatabase+nDias >= QDH->QDH_DTLIM)
			cTxAVenc:=OemToAnsi(STR0174)+Alltrim(Str(QDH->QDH_DTLIM-dDatabase))+OemToAnsi(STR0175)  //"Documento à vencer em "###" dias! Gera revalidação?"
		Endif		
				       
		If cTxAVenc!=""
			If MsgYesNo(OemtoAnsi(cTxAVenc),OemToAnsi(STR0023))  //"Atenção"
				dDtAten:= QDH->QDH_DTLIM
				// Monta a tela de datas de validade
				If lQDOA050M
					Execblock ("QDOA050M",.F.,.F.)
				Endif
				If !QDXDtVig()
					MsgAlert(OemtoAnsi(STR0176),OemToAnsi(STR0023))  //"Revalidação cancelada!"###"Atenção"
					Return( .F. )
				EndIf
				cHist:=OemtoAnsi(STR0177)+cMatFil+"-"+Alltrim(cMatCod)+" "+Alltrim(QA_NUSR(cMatFil,cMatCod))+" "+OemtoAnsi(STR0178)+DTOC(DdataBase)+OemtoAnsi(STR0179)+DTOC(dDtAten)+OemtoAnsi( STR0180)+DTOC(M->QDH_DTLIM)   //"Fil-Usr: "###"Revalidado: "###" Dt Validade Anterior: "###" Dt Revalidação:"
								
				IF QDXREDTxt(QDH->QDH_DOCTO+" "+QDH->QDH_RV,QDH->QDH_CHAVE,cHist)
					Begin Transaction
					Reclock("QDH",.F.)
					QDH->QDH_DTLIM 	:=	M->QDH_DTLIM
					MsUnlock()
					FKCOMMIT()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Baixa o Aviso de Documento Vencido         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QDS->(DbSetOrder(2))
					If QDS->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+"VEN"))						
						While QDS->(!Eof()) .AND. QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV+Alltrim(QDS->QDS_TPPEND) == QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+"VEN"
							IF QDS->QDS_PENDEN=="P"
								RecLock("QDS",.F.)
								QDS->QDS_PENDEN := "B"
								QDS->QDS_DTBAIX:= dDataBase
								QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
								QDS->QDS_FMATBX := cMatFil
								QDS->QDS_MATBX  := cMatCod
								QDS->QDS_DEPBX  := cMatDep
								MsUnlock()
								FKCOMMIT()
							Endif
							QDS->(DbSkip())
						Enddo
					EndIf            
					End Transaction
					MsgAlert(OemtoAnsi(STR0181),OemToAnsi(STR0182)) //"A Revalidação foi efetuada com sucesso!"###"Informe"
				Else
					MsgAlert(OemtoAnsi(STR0176),OemToAnsi(STR0023))  //"Revalidação cancelada!"###"Atenção"
				Endif    
				DbSelectArea("QDH")				
				Return( .F. )
			Endif

		EndIf		
	Endif    
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processo de Bloqueio do Gera Revisao quando ha Solicitacoes Pendentes   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	IF lQdBlorv
		aARea:= GetArea()
		cQuery:= "SELECT QDP.QDP_PENDEN "
		cQuery+= "FROM " + RetSqlName("QDP")+" QDP "
		cQuery+= "WHERE QDP.QDP_FILIAL = '"+ M->QDH_FILIAL +"' AND "
		cQuery+= "QDP.QDP_DTOORI = '"+M->QDH_DOCTO+"' AND  "
		cQuery+= "QDP.QDP_RV = '"+M->QDH_RV+"' AND "
		cQuery+= "QDP.QDP_PENDEN = 'P' AND "
		cQuery+= "QDP.D_E_L_E_T_ <> '*' "
		cQuery+= "ORDER BY " + SqlOrder("QDP_FILIAL+QDP_DTOORI+QDP_RV")
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN",TCGenQry(,,cQuery),'QDP_TRB',.F.,.T.)
			
		DbSelectArea("QDP_TRB")
		QDP_TRB->(DbGotop())
		IF  QDP_TRB->(!EOF())
			MsgAlert(OemToAnsi(STR0088)+CHR(13)+CHR(10)+OemToAnsi(STR0022),OemToAnsi(STR0023)) // Existe pendencia de  Solicitacao de Alteracao neste Documento." ### "Usu rio n„o autorizado a gerar revis„o"  ### "Aten‡„o"					
			DbCloseArea()         									
			RestArea(aARea)			 
			Return( .F. )								
		Endif
		DbCloseArea()         									
		RestArea(aARea)				
   Endif                       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao do usuario 					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCodAut) .Or. !lRespRv
		MsgAlert(OemToAnsi(STR0022),OemToAnsi(STR0023)) // "Usu rio n„o autorizado a gerar revis„o"  ### "Aten‡„o"
		Return( .f. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Confirmacao da Geracao da Revisao      	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If nOpc <> 6
		If !MsgYesNo(OemToAnsi(STR0024),OemToAnsi(STR0023)) // "Documento j  distribuido. Gera nova revis„o?" ### "Aten‡„o"
			Return .F.		
		EndIf
	EndIf
	If lQDOA050M
		Execblock ("QDOA050M",.F.,.F.)
	Endif
Endif

lGeraRev := .T.
DbSelectArea( "QDH" )
For nI := 1 TO FCount()
	M->&(Eval(bCampo,nI)) := FieldGet(nI)
Next nI

M->QDH_RV     	:= aDoctos[Len(aDoctos),3]
M->QDH_DTIMPL 	:= CTOD("  /  /  ","DDMMYY")
M->QDH_DTVIG  	:= CTOD("  /  /  ","DDMMYY")
M->QDH_DTLIM  	:= CTOD("  /  /  ","DDMMYY")
M->QDH_RV     	:= QDXFNNrRev(M->QDH_RV)
M->QDH_DESCAS	:= QDXFNANASS(M->QDH_CODASS,.T.)
M->QDH_DESCTP	:= QDXFNANTPD(M->QDH_CODTP,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a Alteracao do Depto Distribuidor atraves do Tipo de Documento ³
//³	e acresenta usuarios do Depto Atual.								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF QD2->(DbSeek(M->QDH_FILIAL+M->QDH_CODTP))
	IF M->QDH_FILDEP != QD2->QD2_FILDEP .OR. M->QDH_DEPTOD != QD2->QD2_DEPTO
		nPosFil	:= GdFieldPos("QDZ_FILMAT",aHedDoc[4])
		nPosCC 	:= GdFieldPos("QDZ_DEPTO" ,aHedDoc[4])
		nPosMat := GdFieldPos("QDZ_MAT"   ,aHedDoc[4])
		
		For nC:=1 To Len(aQDZDOC)
			IF aQDZDOC[nC,nPosFil]==M->QDH_FILDEP .AND. aQDZDOC[nC,nPosCC]==M->QDH_DEPTOD
				aQDZDOC[nC,Len(aQDZDOC[nC])]:=.T. //Deleta Usuario do Depto Anterior
			Endif
		Next
		M->QDH_FILDEP	:= QD2->QD2_FILDEP
		M->QDH_DEPTOD	:= QD2->QD2_DEPTO
		
		QAA->(DbSetOrder(2))
		IF QAA->(DbSeek(M->QDH_FILDEP+M->QDH_DEPTOD))
			While QAA->(!Eof()) .And. QAA->QAA_FILIAL+QAA->QAA_CC == M->QDH_FILDEP+M->QDH_DEPTOD
				If QA_SitFolh() .And. QAA->QAA_DISTSN == "1"
					IF Ascan(aQDZDOC,{|X| X[nPosFil]==QAA->QAA_FILIAL .AND. X[nPosMat]==QAA->QAA_MAT .AND. X[nPosCC]==QAA->QAA_CC }) == 0
						AADD(aQDZDOC,{M->QDH_FILDEP,M->QDH_DEPTOD,QAA->QAA_MAT,QAA->QAA_NOME,"2","",0,.F.})
					Endif
				Endif
				QAA->(DbSkip())
			Enddo
		Endif
	Endif
Endif
	
M->QDH_NDEPTO	:= QA_NDEPT(M->QDH_DEPTOD,.T.,M->QDH_FILDEP)
M->QDH_FILMAT	:= cMatFil
M->QDH_MAT   	:= cMatCod
M->QDH_DEPTOE	:= cMatDep
M->QDH_DTCAD 	:= dDataBase
M->QDH_HORCAD	:= SubStr(TIME(),1,5)
M->QDH_STATUS	:= "D  "
M->QDH_SITUAC	:= QA_NSIT(M->QDH_STATUS)
M->QDH_OBSOL 	:= "N"
M->QDH_DTVIG 	:= CTOD("  /  /  " ,"DDMMYY")
M->QDH_REVINV	:= INVERTE(M->QDH_RV)

QD050ApAll("OBJ,TXT,COM,REV,SUM,ITA,RED") 

If M->QDH_DTOIE == "I"
	cTexto := STRZERO(VAL(QA_SEQU("QDH",6,"N")),6)+SubStr(StrZero(year(dDataBase),4),3,2)+".CEL"
	While File(cQPath+cTexto)
		cTexto := STRZERO(VAL(QA_SEQU("QDH",6,"N")),6)+SubStr(StrZero(year(dDataBase),4),3,2)+".CEL"
	Enddo
	If lQDOAP16
		ExecBlock("QDOAP16",.F.,.F.,{cTexto,cQPath})
	Else
		_CopyFile(cQPath+AllTrim(M->QDH_NOMDOC),cQPath+cTexto)
	EndIf
	M->QDH_NOMDOC := Alltrim(cTexto)

ElseIf M->QDH_DTOIE == "E"       
	// Cancelamento OU duplica externo
	If nOpc == 6 .OR. lDupExt
		If At("DOCEXT",AllTrim(M->QDH_NOMDOC)) > 0
			M->QDH_NOMDOC:= "DOCEXT"+Alltrim(Str(Day(Date())))+Alltrim(Str(Month(Date())))+Alltrim(Str(Year(Date())))
	   	Else
		   	cTexto := StrZero(Val(QA_SEQU("DOCEXT",6,"N")),6)+SubStr(StrZero(year(dDataBase),4),3,2)
		   	While File(cQPath+cTexto)
				cTexto:= StrZero(Val(QA_SEQU("DOCEXT",6,"N")),6)+SubStr(StrZero(year(dDataBase),4),3,2)
		   	EndDo
		 	cTexto:= cTexto+SubStr(AllTrim(M->QDH_NOMDOC),QDOCLExt(AllTrim(M->QDH_NOMDOC)))
			If lQDOAP16
				ExecBlock("QDOAP16",.F.,.F.,{cTexto,cQPath})
			Else
				__CopyFile(cQPath+AllTrim(M->QDH_NOMDOC),cQPath+cTexto)
			EndIf
			M->QDH_NOMDOC := Alltrim(cTexto)
		EndIf
	Else
		M->QDH_NOMDOC:= CRIAVAR("QDH_NOMDOC",.F.)
	EndIf
EndIf

lRefresh:= .T.

cCod    := M->QDH_DOCTO+"  RV:"+M->QDH_RV
cChave  := M->QDH_FILIAL+cCod
cChave  := QA_CvKey( cChave, "QDH", 2, "QDP", 2, .T., {"OBJ","TXT","COM","REV","SUM","CRI","CRT","ITA","RED"} )

M->QDH_CHAVE := cChave

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deleta as Informacoes revisao atual dos textos QA2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FOR nI:=1 To Len(aTipoTxt)		
	IF Alltrim(aTipoTxt[nI])=="CRI"
		QD4->(DbSetOrder(1))
	   	IF QD4->(DbSEEK(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
			While QD4->(!EOF()) .AND. QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV == QD4->QD4_FILIAL+QD4->QD4_DOCTO+QD4->QD4_RV		   	
				nLoATxt:=ASCAN(aTxtREsul,{|X| x[1]==aTipoTxt[nI] .AND. X[2]==QD4->QD4_CHAVE})
				IF nLoATxt!=0		
					Adel(aTxtREsul,nLoATxt)
					ASIZE(aTXTResul,Len(aTxtREsul)-1)                                       					
    			Endif
			    QD4->(DbSkip())
			Enddo	
		Endif
	ElseIF Alltrim(aTipoTxt[nI])=="RED"
		nLoATxt:=ASCAN(aTxtREsul,{|X| x[1]==aTipoTxt[nI] .AND. X[2]==QDH->QDH_CHAVE})
		While nLoATxt!=0			
			Adel(aTxtREsul,nLoATxt)
			ASIZE(aTXTResul,Len(aTxtREsul)-1)                                       
			nLoATxt:=ASCAN(aTxtREsul,{|X| x[1]==aTipoTxt[nI] .AND. X[2]==QDH->QDH_CHAVE})
    	Enddo
   	ElseIF Alltrim(aTipoTxt[nI])=="REV" .AND. lDelRev  .AND. lQdoAltMr
   		nLoATxt:=ASCAN(aTxtREsul,{|X| x[1]==aTipoTxt[nI] .AND. X[2]==cChaveAnt})   //Efetuado alteração devido a utilização do PE QDOALMTR
	    IF nLoATxt!=0
   			aTxtREsul[nLoATxt,2]:=M->QDH_CHAVE   		
   			aTxtREsul[nLoATxt,4] :=cChave	     
   		    aTxtREsul[nLoATxt,7] := cEsp                                          	   	 
		Endif                                         	   	 
	ElseIF Alltrim(aTipoTxt[nI])=="REV" .AND. lDelRev
   		nLoATxt:=ASCAN(aTxtREsul,{|X| x[1]==aTipoTxt[nI] .AND. X[2]==QDH->QDH_CHAVE})
	    IF nLoATxt!=0
			Adel(aTxtREsul,nLoATxt)
			ASIZE(aTXTResul,Len(aTxtREsul)-1)                                          	   	 
		Endif	
   	Else
   		nLoATxt:=ASCAN(aTxtREsul,{|X| x[1]==aTipoTxt[nI] .AND. X[2]==cChaveAnt})
   		IF nLoATxt!=0
   			aTxtREsul[nLoATxt,2]:=M->QDH_CHAVE   		
   			aTxtREsul[nLoATxt,4] :=cChave	
   		    aTxtREsul[nLoATxt,7] := cEsp 
   		Endif   			    	
	Endif	
NEXT nI	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para alteracao dos textos (Objetivo,Sumario, etc ) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQDOALTMR
 	aTxtREsul:=aClone(ExecBlock("QDOALTMR",.F.,.F.,{aTxtREsul}))
Endif   


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre Texto para digitar o Motivo da Revisao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSAD
	QD050EdTxt("REV",3)
Endif   

If lQDOA050M
	Execblock ("QDOA050M",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destinos     						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Array aQDJDoc
//1 - QDJ->QDJ_FILIAL
//2 - QDJ->QDJ_DOCTO
//3 - QDJ->QDJ_RV
//4 - QDJ->QDJ_FILMAT
//5 - QDJ->QDJ_DEPTO
//6 - QDJ->QDJ_TIPO,

//9 -Array aQDjDoc
// 1 - QDG->QDG_FILIAL
// 2 - QDG->QDG_DOCTO
// 3 - QDG->QDG_RV
// 4 - QDG->QDG_FILMAT
// 5 - QDG->QDG_DEPTO
// 6 - QDG->QDG_MAT
// 7 - QDG->QDG_NCOP,
// 8 - QDG->QDG_TPRCBT
// 9 - QDG->QDG_RECEB
//10 - QDG->QDG_TIPO
//11 - QDG->QDG_CODMAN
//12 - QDG->QDG_SIT,
If cQRetDest == "2"
	aQDJDoc	:= {}
endif
For nC:= 1 To Len(aQDJDoc)
	aQDJDoc[nC,1]	:= M->QDH_FILIAL
	aQDJDoc[nC,2]	:= M->QDH_DOCTO
	aQDJDoc[nC,3]	:= M->QDH_RV
	For nI:= 1 To Len(aQDJDoc[nC,9])
		aQDJDoc[nC,9,nI,1]:= M->QDH_FILIAL
		aQDJDoc[nC,9,nI,2]:= M->QDH_DOCTO
		aQDJDoc[nC,9,nI,3]:= M->QDH_RV
	Next nI	
Next nC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Responsaveis  (Limpa T)			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosFlag:=GdFieldPos("QD0_FLAG",aHedDoc[1])
For nC:= 1 To Len(aQD0Doc)
	aQD0Doc[nC,nPosFlag]:= " "
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Completa a matriz de responsaveis (QD0) com QDD³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QDD->(DbSeek(M->QDH_FILIAL+M->QDH_CODTP))
	nPosAUT		:= GdFieldPos("QD0_AUT"		,aHedDoc[1])
	nPosFILMAT	:= GdFieldPos("QD0_FILMAT"	,aHedDoc[1])
	nPosCC		:= GdFieldPos("QD0_DEPTO" 	,aHedDoc[1])
	nPosMAT		:= GdFieldPos("QD0_MAT"	 	,aHedDoc[1])
	nPosORDEM 	:= GdFieldPos("QD0_ORDEM" 	,aHedDoc[1])
	
	nOrdQAA	:= QAA->(IndexOrd())
	nOrdeQD0:= QD0->(IndexOrd())
	QAA->(DbSetOrder(2))
	QD0->(DbSetOrder(2))
	While QDD->(!Eof()) .And. QDD->QDD_FILIAL+QDD->QDD_CODTP == M->QDH_FILIAL+M->QDH_CODTP
		If QDD->QDD_GREV=="1" .AND. QAA->(DbSeek(QDD->QDD_FILA+QDD->QDD_DEPTOA))
			While QAA->(!Eof()) .And. QAA->QAA_FILIAL+QAA->QAA_CC == QDD->QDD_FILA+QDD->QDD_DEPTOA
				If QAA->QAA_CODFUN == QDD->QDD_CARGOA .And. Qa_SitFolh()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se existe na revisao nova³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Ascan(aQD0Doc,{|x| x[nPosAUT]+x[nPosFILMAT]+x[nPosCC]+x[nPosMAT]==QDD->QDD_AUT+QAA->QAA_FILIAL+QAA->QAA_CC+QAA->QAA_MAT } ) == 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se existe na revisao antiga e nao flag Inativo³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						IF QD0->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+QDD->QDD_AUT+QAA->QAA_FILIAL+QAA->QAA_CC+QAA->QAA_MAT))
							IF QD0->QD0_FLAG == "I"
								QAA->(DbSkip())
								Loop
							Endif
						Endif
						cOrdQD0 := ""
						If aScan(aQD0Doc,{|x|x[nPosAUT]==QDD->QDD_AUT}) != 0
							For nC := 1 to Len(aQD0Doc)
								If aQD0Doc[nC,nPosAut] == QDD->QDD_AUT
									cOrdQD0:= IF(aQD0Doc[nC,nPosORDEM]>cOrdQD0,aQD0Doc[nC,nPosORDEM],cOrdQD0)
								EndIf
							Next
						EndIf
						aAdd(aQD0Doc,ARRAY(Len(aHedDoc[1])+1))
						nOrdQD0 := If(cOrdQD0 == "",1,Val(cOrdQD0)+1)
						
						For nX := 1 To Len(aStruQD0)
							If cNivel >= GetSx3Cache(aStruQD0[nX, 1], "X3_NIVEL") .and. !ASCAN({"QD0_FILIAL","QD0_DOCTO","QD0_RV"},{|x| x == Trim(aStruQD0[nX, 1])}) > 0
								nPosHead := Ascan(aHedDoc[1],{|X| Upper(Alltrim(X[2])) == Alltrim( aStruQD0[nX, 1] )})
								If GetSx3Cache(aStruQD0[nX, 1], "X3_CONTEXT") == "V"
									If Upper( Alltrim( aStruQD0[nX, 1] ) ) == "QD0_NOME"
										aQD0Doc[Len(aQD0Doc),nPosHead] := Padr( QAA->QAA_NOME, 40 )
									Else
										aQD0Doc[Len(aQD0Doc),nPosHead] := CriaVar(AllTrim(aStruQD0[nX, 1]))
									EndIf
								Else
									DO Case
										Case Upper( Alltrim( aStruQD0[nX, 1] ) ) == "QD0_AUT"
											aQD0Doc[Len(aQD0Doc),nPosHead] := QDD->QDD_AUT
										Case Upper( Alltrim( aStruQD0[nX, 1] ) ) == "QD0_ORDEM"
											aQD0Doc[Len(aQD0Doc),nPosHead] := StrZero(nOrdQD0,2)
										Case Upper( Alltrim( aStruQD0[nX, 1] ) ) == "QD0_FILMAT"
											aQD0Doc[Len(aQD0Doc),nPosHead] := QAA->QAA_FILIAL
										Case Upper( Alltrim( aStruQD0[nX, 1] ) ) == "QD0_MAT"
											aQD0Doc[Len(aQD0Doc),nPosHead] := QAA->QAA_MAT
										Case Upper( Alltrim( aStruQD0[nX, 1] ) ) == "QD0_DEPTO"
											aQD0Doc[Len(aQD0Doc),nPosHead] := QAA->QAA_CC
										OtherWise
											aQD0Doc[Len(aQD0Doc),nPosHead] := CriaVar(AllTrim(aStruQD0[nX, 1]))
									EndCase
								EndIf
							EndIf
						Next nX
						aQD0Doc[Len(aQD0Doc),Len(aHedDoc[1])+1] := .F.
						
					Endif
				EndIf
				QAA->(DbSkip())
			Enddo
		EndIf
		QDD->(DbSkip())
	Enddo
	QAA->(DbSetOrder(nOrdQAA))
	QD0->(DbSetOrder(nOrdeQD0))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Organizar o Responsaveis ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nC := 1 to Len( aQD0Doc )
		If aQD0Doc[nC][nPosAUT] == "E"
			aQD0Doc[nC][nPosAUT] := "1"
		ElseIf aQD0Doc[nC][nPosAUT] == "R"
			aQD0Doc[nC][nPosAUT] := "2"
		ElseIf aQD0Doc[nC][nPosAUT] == "A"
			aQD0Doc[nC][nPosAUT] := "3"
		ElseIf aQD0Doc[nC][nPosAUT] == "H"
			aQD0Doc[nC][nPosAUT] := "4"
		EndIf
	Next
	aQD0Doc := aSort( aQD0Doc, , , { |x,y| x[nPosAUT] + x[nPosORDEM] < y[nPosAUT] + y[nPosORDEM] } )
	For nC :=1 to Len( aQD0Doc )
		If aQD0Doc[nC][nPosAUT] == "1"
			aQD0Doc[nC][nPosAUT] := "E"
		ElseIf aQD0Doc[nC][nPosAUT] == "2"
			aQD0Doc[nC][nPosAUT] := "R"
		ElseIf aQD0Doc[nC][nPosAUT] == "3"
			aQD0Doc[nC][nPosAUT] := "A"
		ElseIf aQD0Doc[nC][nPosAUT] == "4"
			aQD0Doc[nC][nPosAUT] := "H"
		EndIf
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recriar a Ordem para corrigir GAP ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOrdQD0 := 1
	cOrdQD0 := ""
	For nC := 1 to Len(aQD0Doc)
		IF cOrdQD0 == aQD0Doc[nC,nPosAut]
			nOrdQD0++
			aQD0Doc[nC,nPosORDEM]:= StrZero(nOrdQD0,2)
		Else
			nOrdQD0 := 1
			cOrdQD0	:= aQD0Doc[nC,nPosAut]
			aQD0Doc[nC,nPosORDEM]:= StrZero(nOrdQD0,2)
		Endif
	Next
	
EndIf

lRevisao := .T.

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ F050COPTXT ³ Autor ³ Aldo Marini Junior   ³ Data ³ 08/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Duplica os Textos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F050COPTXT(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Chave de Ligacao Anterior                           ³±±
±±³          ³ ExpC2 - Nova Chave de Ligacao                               ³±±
±±³          ³ ExpC3 - Tipo do Texto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function F050COPTXT(cChave,cNewChave,cEspecie)
Local nCpo

DbSelectArea("QA2")
DbSetOrder(1)
If QA2->(DbSeek(M->QDH_FILIAL+cEspecie+cChave))
	While QA2->(!Eof()) .and. QA2->QA2_FILIAL+QA2->QA2_ESPEC+QA2->QA2_CHAVE == M->QDH_FILIAL+cEspecie+cChave
		nRegTxt:= Recno()
		For nCpo:= 1 to FCount()
			cCampo:= Upper(Alltrim(FieldName(nCpo)))
			&("M->"+cCampo):= FieldGet(nCpo)
		Next nCpo
	
		If RecLock("QA2",.T.)
			For nCpo:= 1 to FCount()
				cCampo:= Upper(Alltrim(FieldName(nCpo)))
				&("QA2->"+cCampo):= &("M->"+cCampo)
			Next nCpo
			QA2->QA2_CHAVE := cNewChave
			MsUnlock()
			FKCOMMIT()
		Endif
		QA2->(DbGoTo(nRegTxt))
		QA2->(DbSkip())
	Enddo
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSelecpar ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 15/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecionar os parametros do relatorio                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSelecpar                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR040/QDOR050                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fSelecpar()

Local	oDlg
Local	oListbox
Local 	oOk    	:= LoaDbitmap( GetResources(), "LBOK" )
Local 	oNo    	:= LoaDbitmap( GetResources(), "LBNO" )
Local 	cTitulo	:= OemToAnsi(STR0025) // "Situa‡„o do Documento"
Local 	cMvpar 	:= &(ReadVar()) // Carrega Nome da Variavel do Get em Questao
Local	cMvret 	:= ReadVar() // Iguala Nome da Variavel ao Nome variavel de Retorno
Local	nOpcao 	:= 0
Local 	aNiv	:= {}
Local 	cAlias 	:= Alias()
Local 	nFor
Local 	cFilSX5 := xFilial('SX5')
Local 	aSx5

Aadd(aNiv,{If("O  " $ cMvpar,.T.,.F.),OemToAnsi(STR0026),"O  "}) // "Todos"

aSx5 := FWGetSX5("Q7")
If !Empty(aSx5)
	For nFor := 1 To Len(aSx5)
		If !Empty(aSx5[nFor][3]) .And. cFilSX5 == aSx5[nFor][1]
			If Substr(aSx5[nFor][3],1,3) $ cMvpar
				Aadd(aNiv,{.T.,Alltrim(aSx5[nFor][4]),Substr(aSx5[nFor][3],1,3)})
			Else
				Aadd(aNiv,{.F.,Alltrim(aSx5[nFor][4]),Substr(aSx5[nFor][3],1,3)})
			Endif
		EndIf
	Next nFor
Else
	Help(" ",1,"QDOR050SIT")		// Parametro Default
	AADD(aNiv,{If("D  "$cMvpar,.T.,.F.),OemToAnsi(STR0004),"D  "}) //"Digita‡„o"
	AADD(aNiv,{If("E  "$cMvpar,.T.,.F.),OemToAnsi(STR0005),"E  "}) //"Elabora‡„o"
	AADD(aNiv,{If("R  "$cMvpar,.T.,.F.),OemToAnsi(STR0006),"R  "}) //"Revis„o"
	AADD(aNiv,{If("A  "$cMvpar,.T.,.F.),OemToAnsi(STR0007),"A  "}) //"Aprova‡„o"
	AADD(aNiv,{If("H  "$cMvpar,.T.,.F.),OemToAnsi(STR0008),"H  "}) //"Homologa‡„o"
	AADD(aNiv,{If("I  "$cMvpar,.T.,.F.),OemToAnsi(STR0009),"I  "}) //"Distribui‡„o"
	AADD(aNiv,{If("L  "$cMvpar,.T.,.F.),OemToAnsi(STR0103),"L  "}) //"Leitura"
EndIf

nLin1 := 0.5
nCol1 := 002

DEFINE MSDIALOG oDlg FROM 005,005 TO 016,050 TITLE OemToAnsi(STR0010) //"Escolha Padr„o"

@ nLin1,nCol1 LISTBOX oListBox  NOSCROLL ;
					FIELDS HEADER " ",OemToAnsi(cTitulo) ;
					SIZE 150,057;
					ON DbLCLICK fSelecCli(@oListBox,@aNiv)

oListBox:SetArray(aNiv)
oListBox:bLine := { || {If(aNiv[oListBox:nAt,1],oOk,oNo),aNiv[oListBox:nAt,2]}}

DEFINE SBUTTON FROM 065,112   TYPE 1 ACTION (nOpcao:= 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 065,139.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1
	cMvpar:= ""
	For nFor := 1 TO Len(aNiv)
		cMvpar += If(aNiv[nFor,1],aNiv[nFor,3],"***")
	Next nFor
EndIf

&cMvRet := cMvpar // Devolve Resultado

DbSelectArea(cAlias) // Retorna Alias

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSelecCli ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 15/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tratar o click da pergunte                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSelecCli                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSelecCli(oListBox,aNiv)

Local nI:= 0

aNiv[oListBox:nat,1]:= !aNiv[oListBox:nat,1]

If oListBox:nAt == 1	 // Todos
	For nI:= 2 To Len(aNiv)
		aNiv[nI,1] := aNiv[1,1]
	Next nI
Else
	If !aNiv[oListBox:nat,1]
		aNiv[1,1]:= .F.
	EndIf
EndIf

oListBox:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ChkMat   ³ Autor ³ Aldo Marini Junior    ³ Data ³ 17.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o Usuario/Pasta                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChkMat(ExpC1,ExpC2,ExpC3,ExpC4,ExpN1,ExpX5)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Usuario                                  ³±±
±±³          ³ ExpC2 - Matricula do Usuario                               ³±±
±±³          ³ ExpC3 - Usuario                                            ³±±
±±³          ³ ExpC4 - Codigo Departamento                                ³±±
±±³          ³ ExpN1 - Tipo (Departamento/Pasta)                          ³±±
±±³          ³ ExpC5 - Descricao Departamento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ChkMat(cFilMat,cCodMat,cUsuario,cDepto,nTipo,cNDepto)

Local cArea := Alias()
Local nOrdem:= IndexOrd()
Local cChave:= ""

Default nTipo:= 1

DbSelectArea("QAA")
DbSetOrder(1)

DbSelectArea("QDG")
DbSetOrder(1)

DbSelectArea("QDC")
DbSetOrder(1)

If Empty(cCodMat)
	Return .F.
EndIf

If nTipo == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Departamento                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave:=QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+"D"+cFilMat
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe o Funcionario/usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QAA->(!DbSeek(cFilMat+cCodMat))
		Help(" ",1,"QD050FNE")	// Funcionario nao Existe
		DbSelectArea(cArea)
		DbSetOrder(nOrdem)
		Return .F.
	EndIf
	cUsuario := QA_NUSR(cFilMat,cCodMat,.T.)
	cDepto   := QAA->QAA_CC
	cNDepto  := QA_NDEPT(cDepto,.T.,cFilMat)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VerIfica se o Usuario ja foi cadastrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QDG->(DbSeek(cChave+cDepto+cCodMat))
		Help(" ",1,"QD050FJE") 	// Usuario ja cadastrado
		DbSelectArea(cArea)
		DbSetOrder(nOrdem)
		Return .F.
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pasta                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChave:=QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+"P"+cFilMat	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe o Funcionario/usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QDC->(!DbSeek(cFilMat+cCodMat))
		Help(" ",1,"QD050PNE")	// Pasta nao Existe
		DbSelectArea(cArea)
		DbSetOrder(nOrdem)
		Return .F.
	EndIf
	cUsuario := QDXFNANMAN(cCodMat,.T.,cFilMat)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VerIfica se o Usuario ja foi cadastrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDG->(DbSetOrder(2))
	If QDG->(DbSeek(cChave+cDepto+cCodMat))
		Help(" ",1,"QD050PJE") // Pasta ja cadastrada
		DbSelectArea(cArea)
		DbSetOrder(nOrdem)
		Return .F.
	EndIf	
EndIf

DbSelectArea(cArea)
DbSetOrder(nOrdem)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FAliasF3  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 15.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche o Alias para F3                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FAliasF3(nItem)

If nItem == 2
	Return("QDC")
Else
	Return("QAA")
EndIf

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TrasUltRv ³ Autor ³ Yale Amorim Sousa     ³ Data ³ 20.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima revisao do documento, conforme os para-   ³±±
±±³          ³ metros solicitados.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TrasUltRv(ExpC1,ExpC2,ExpC3,ExpL1,ExpC4)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Documento                                ³±±
±±³          ³ ExpC2 - Situacao do Documento:(L*)eitura,(D)igitacao,..    ³±±
±±³          ³ ExpC3 - Documento Obsoleto: (S/N*)                         ³±±
±±³          ³ ExpL1 - Ficar Posicionado no documento: .T. ou .F.*        ³±±
±±³          ³ ExpC4 - Filial do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrazUltRv(cCodDoc,cStatus,cObsoleto,lPos,cFilCod)

Local cRev   := Space(3)
Local nRecNo := QDH->(RecNo())
Local cAlias := Alias()

Default cCodDoc  := " "
Default cStatus  := "L  "
Default cObsoleto:= "N"
Default lPos     := .F.
Default cFilCod  := xFilial("QDH")

If Empty(cCodDoc)
	DbSelectArea(cAlias)
	Return cRev
EndIf

cStatus  := Left(AllTrim(Upper(cStatus))+Space(3),3)
cObsoleto:= Left(AllTrim(Upper(cObsoleto))+Space(1),1)

If QDH->(DbSeek(cFilCod+cCodDoc))
	While QDH->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO == cFilCod+cCodDoc
		If QDH->QDH_STATUS == cStatus .And. QDH->QDH_OBSOL == cObsoleto
			cRev := QDH->QDH_RV
		EndIf
		QDH->(DbSkip())
	EndDo
EndIf

If !lPos
	QDH->(DbGoto(nRecNo))   // Retorna a posicao anterior.
EndIf

DbselectArea(cAlias)

Return cRev

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ChkUltRv  ³ Autor ³ Yale Amorim Sousa     ³ Data ³ 20.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna .t. se existe revisao do documento, conforme os    ³±±
±±³          ³ parametros solicitados estiverem ok e .f. caso contrario.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChkUltRv(ExpC1,ExpC2,ExpC3,ExpL1)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Documento                                ³±±
±±³          ³ ExpC2 - Situacao do Documento:(L)eitura,(D)igitacao,..     ³±±
±±³          ³ ExpC3 - Documento Obsoleto: (S/N)                          ³±±
±±³          ³ ExpL1 - Ficar Posicionado no documento: .T. ou .F.         ³±±
±±³          ³ ExpC4 - Filial do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ChkUltRv(cCodDoc,cStatus,cObsoleto,lPos,cFilCod)

Local lRev  := .F.
Local nRecNo:= QDH->(RecNo())

Default cCodDoc  := " "
Default cStatus  := "L  "
Default cObsoleto:= "N"
Default lPos     := .F.
Default cFilCod  := xFilial("QDH")

If Empty(cCodDoc)
	Help(" ",1,"QD050TDNE")	// Tipo de Documento nao existe
	Return lRev
EndIf

cStatus  := Left(AllTrim(Upper(cStatus))+Space(3),3)
cObsoleto:= Left(AllTrim(Upper(cObsoleto))+Space(1),1)

If QDH->(DbSeek(cFilCod+cCodDoc))
	While QDH->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO == cFilCod+cCodDoc
		If QDH->QDH_STATUS == cStatus .And. QDH->QDH_OBSOL == cObsoleto
			lRev := .T.
		EndIf
		QDH->(DbSkip())
	EndDo
EndIf

If !lPos
	QDH->(DbGoto(nRecNo))   // Retorna a posicao anterior.
EndIf

Return lRev

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QA_NDEPTOS³ Autor ³ Yale Amorim           ³ Data ³ 17.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os nomes dos departamentos envolvidos na           ³±±
±±³          ³ distribuicao de um determinado documento.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA_NDEPTOS(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Revisao do Documento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_NDEPTOS(cFilCod,cDocto,cRev)

Local cDeptos := " "
Local cDepto  := " "
Local cFilMat := Space(FWSizeFilial())
Local nRegQDH := QDH->(RecNo())
Local nRegQDG := QDG->(Recno())

Default cFilCod:= M->QDH_FILIAL
Default cDocto := M->QDH_DOCTO
Default cRev   := M->QDH_RV

QDH->(DbSeek(cFilCod+cDocto+cRev))
If QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV == cFilCod + cDocto + cRev
	QDG->(DbSeek(cFilCod + cDocto + cRev))
	While !QDG->(Eof()) .And. QDG->QDG_FILIAL + QDG->QDG_DOCTO + QDG->QDG_RV == cFilCod + cDocto + cRev
		If !(QDG->QDG_FILMAT + QDG->QDG_DEPTO == cFilMat + cDepto)
			If !Empty(cFilMat + cDepto)
				cDeptos += ", "
			EndIf
			cDeptos += AllTrim(QA_NDEPT(QDG->QDG_DEPTO,.T.,QDG->QDG_FILMAT))
			cFilMat := QDG->QDG_FILMAT
			cDepto  := QDG->QDG_DEPTO
		EndIf
		QDG->( DbSkip() )
	EndDo
EndIf

QDH->(DbGoTo(nRegQDH))
QDG->(DbGoTo(nRegQDG))

Return cDeptos

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFieldGet³ Autor ³ Yale Amorim           ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem o conteudo de um elemento do array, baseado na posi- ³±±
±±³          ³ cao relativa ao campo do arquivo.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AFieldGet(ExpA1,ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com a seguite estrutura:                     ³±±
±±³          ³          { { "campo","conteudo" },... }                    ³±±
±±³          ³ ExpC1 - Nome do campo do arquivo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AFieldGet(aArray,cField)

Local nPos := AFieldPos(aArray,cField)

Return If(nPos > 0,aArray[nPos,2],CriaVar(cField))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFieldPos³ Autor ³ Yale Amorim           ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem o conteudo de um elemento do array, baseado na posi- ³±±
±±³          ³ cao relativa ao campo do arquivo.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AFieldGet(ExpA1,ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com a seguite estrutura:                     ³±±
±±³          ³          { { "campo","conteudo" },... }                    ³±±
±±³          ³ ExpC1 - Nome do campo do arquivo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AFieldPos(aArray,cField)

Return If(Len(aArray) > 0,Ascan(aArray,{ |x| AllTrim(x[1]) == AllTrim(Upper(cField))}),0)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFieldPut³ Autor ³ Yale Amorim           ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem o conteudo de um elemento do array, baseado na posi- ³±±
±±³          ³ cao relativa ao campo do arquivo.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AFieldPut(ExpA1,ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com a seguite estrutura:                     ³±±
±±³          ³          { { "campo","conteudo" },... }                    ³±±
±±³          ³ ExpC1 - Nome do campo do arquivo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AFieldPut(aArray,cField,uValue)

Local nPos:= AFieldPos(aArray,cField)

If nPos > 0
	aArray[nPos,2]:= uValue
EndIf

Return aArray

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ChkApelido³ Autor ³ Yale Amorim           ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se ja existe algum apelido cadastrado.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChkApelido(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Apelido do Usuario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ChkApelido(cApelido)

Local lRet     := .F.
Local nRecNo   := QAA->(RecNo())
Local nOldOrder:= QAA->(IndexOrd())

If !Empty(cApelido)
	QAA->(DbSetOrder(6))
	lRet:= QAA->(DbSeek(cApelido))
	QAA->(DbSetOrder(nOldOrder))
	QAA->(DbGoTo(nRecNo))
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CheckEmpty³ Autor ³ Yale Amorim           ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o alias mensionado esta com base dado vazio.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CheckEmpty(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do Arquivo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDbEmpty( cAlias )

Local lRet     := .T.
Local cAliasOld:= Alias()

DbSelectArea(cAlias)
DbGoTop()
lRet:= (Eof() .And. Bof())

DbSelectArea(cAliasOld)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QChkMatPen³ Autor ³ Yale Amorim           ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe pendencia em aberto(P) para o usuario   ³±±
±±³          ³ corrente para o respectivo documento posicionado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QChkMatPen(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,ExpC8)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Revisao do Documento                               ³±±
±±³          ³ ExpC4 - Status do Documento                                ³±±
±±³          ³ ExpC5 - Filial do Usuario                                  ³±±
±±³          ³ ExpC6 - Matricula do Usuario                               ³±±
±±³          ³ ExpC7 - Departamento do Usuario                            ³±±
±±³          ³ ExpC8 - Pendente/Baixado (P/B)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QChkMatPend(cFilCod,cDocto,cRv,cStatus,cFilMat,cMat,cDepto,cPenden)

Local nOrder := QD1->(IndexOrd())
Local nRecNo := QD1->(RecNo())
Local lRet   := .F.
Local cChave := ""
Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]
Local cMatDep:= aUsrMat[4]

Default cFilCod:= QDH->QDH_FILIAL
Default cDocto := QDH->QDH_DOCTO
Default cRv    := QDH->QDH_RV
Default cDepto := cMatDep
Default cFilMat:= cMatFil
Default cMat   := cMatCod
Default cPenden:= "P"
Default cStatus:= QDH->QDH_STATUS

cChave := cFilCod + cDocto + cRv + cDepto + cFilMat + cMat

If !(QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT == cChave )
	QD1->(DbSetOrder(1))
	QD1->(DbSeek(cChave))
EndIf

While !QD1->(Eof()) .And. QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + ;
									 QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT == cChave

	If QD1->QD1_PENDEN == cPenden .And. QD1->QD1_TPPEND == cStatus
		lRet := .T.
		Exit
	EndIf
	QD1->(DbSkip())
EndDo

QD1->(DbSetOrder(nOrder))
QD1->(DbGoTo(nRecNo))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QChkMatDig³ Autor ³ Yale Amorim           ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o usuario corrente é o digitador do documento.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QChkMatDig(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Revisao do Documento                               ³±±
±±³          ³ ExpC4 - Filial do Usuario                                  ³±±
±±³          ³ ExpC5 - Matricula do Usuario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QChkMatDig(cFilCod,cDocto,cRv,cFilMat,cMat)

Local nOrder := QDH->(IndexOrd())
Local nRecNo := QDH->(RecNo())
Local lRet   := .T.
Local cChave := ""
Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]

Default cFilCod:= QDH->QDH_FILIAL
Default cDocto := QDH->QDH_DOCTO
Default cRv    := QDH->QDH_RV
Default cFilMat:= cMatFil
Default cMat   := cMatCod

cChave := cFilCod + cDocto + cRv

QDH->(DbSetOrder(1))
If !(QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV <> cChave)
	lRet := QDH->(DbSeek(cChave))
EndIf

If lRet
	cChave := cFilMat + cMat
	lRet := (QDH->QDH_FILMAT + QDH->QDH_MAT == cChave)
EndIf

QDH->( DbSetOrder( nOrder ) )
QDH->( DbGoTo( nRecNo ) )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QChkMatElab³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o usuario é o elaborador do documento.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QChkMatElab(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Revisao do Documento                               ³±±
±±³          ³ ExpC4 - Filial do Usuario                                  ³±±
±±³          ³ ExpC5 - Matricula do Usuario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QChkMatElab(cFilCod,cDocto,cRv,cFilMat,cMat,cDepto)

Local nRecNo := QD0->(RecNo())
Local lRet   := .F.
Local cChave := ""
Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]
Local cMatDep:= aUsrMat[4]

Default cFilCod:= QDH->QDH_FILIAL
Default cDocto := QDH->QDH_DOCTO
Default cRv    := QDH->QDH_RV
Default cFilMat:= cMatFil
Default cMat   := cMatCod
Default cDepto := cMatDep

cChave := cFilCod +cDocto + cRv + "E"

If QD0->(DbSeek(cChave))
	While !QD0->(Eof()) .And. QD0->QD0_FILIAL + QD0->QD0_DOCTO + QD0->QD0_RV + QD0->QD0_AUT == cChave
		If QD0->QD0_FILMAT + QD0->QD0_MAT + QD0->QD0_DEPTO == cFilMat + cMat + cDepto
			lRet := .T.
			Exit
		EndIf
		QD0->(DbSkip())
	EndDo
EndIf

QD0->(DbGoTo(nRecNo))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMatBxPen ³ Autor ³ Yale Amorim           ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa pendencia do usuario corrente ou especificado.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QChkMatPen(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,ExpC8 ³±±
±±³          ³            ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Revisao do Documento                               ³±±
±±³          ³ ExpC4 - Status do Documento                                ³±±
±±³          ³ ExpC5 - Filial do Usuario                                  ³±±
±±³          ³ ExpC6 - Matricula do Usuario                               ³±±
±±³          ³ ExpC7 - Departamento do Usuario                            ³±±
±±³          ³ ExpC8 - Aprova                                             ³±±
±±³          ³ ExpL1 - Todos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QMatBxPend(cFilCod,cDocto,cRv,cStatus,cFilMat,cMat,cDepto,cAprova,lTodos)

Local nOrder := QD1->(IndexOrd())
Local nRecNo := QD1->(RecNo())
Local lRet   := .F.
Local cChave := ""
Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]
Local cMatDep:= aUsrMat[4]

Default cFilCod:= QDH->QDH_FILIAL
Default cDocto := QDH->QDH_DOCTO
Default cRv    := QDH->QDH_RV
Default cFilMat:= cMatFil
Default cMat   := cMatCod
Default cDepto := cMatDep
Default cStatus:= QDH->QDH_STATUS
Default cAprova:= "N"
Default lTodos := .F.

cChave := cFilCod + cDocto + cRv + cDepto + cFilMat + cMat

If !(QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT == cChave)
	QD1->(DbSetOrder(1))
	QD1->(DbSeek(cChave))
EndIf

While !QD1->(Eof()) .And. QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + ;
								 	 QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT == cChave

	If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == cStatus
		lRet := .T.
		BEGIN TRANSACTION
			If !RecLock("QD1",.F.)
				lRet := .F.
				Break
			EndIf
			QD1->QD1_PENDEN := "B"
			QD1->QD1_APROVA := cAprova
			QD1->QD1_DTBAIX := dDataBase
			QD1->QD1_HRBAIX := SubStr(Time(),1,5)
			QD1->QD1_FMATBX := cMatFil
			QD1->QD1_MATBX  := cMatCod
			QD1->QD1_DEPBX  := cMatDep
		END TRANSACTION
		If !lTodos .Or. !lRet
			Exit
		EndIf
	EndIf
	QD1->(DbSkip())
Enddo

QD1->(DbSetOrder(nOrder))
QD1->(DbGoTo(nRecNo))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMsgDtLim ³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa a data de validade de uma determinada revisao de     ³±±
±±³          ³ documento e avisa ao elaborador que esta preste a vencer.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMsgDtLim()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QMsgDtLim(dDataUsar)

Local aQPath   	:= QDOPATH()
Local cQPathTrm	:= aQPath[3]
Local nDias    	:= GetMV("MV_QDIALIM")
Local nCDto	   	:= 0
Local cMsg	   	:= " "
Local cAlias   	:= ""
Local cIndex   	:= ""
Local dDtLim   	:= dDataBase
Local cAliasAtu	:= Alias()
Local nOrdemAtu	:= IndexOrd()
Local lRemotp:= GetRemoteType() == 2   //Checa se o Remote e Linux 
Local cDrive := ""
Local cLinCmd:= ""

Default nDias  	:= 0
If ((nHandle:= FCREATE(cQPathTrm + "LIMITE.TXT", FC_NORMAL)) == -1)
	If((nHandle:= MakeDir(cQPathTrm)) <> 0)
		MsgStop(OemToAnsi(STR0102)) //"Impossivel Criar Diretorio"
		Return
	Else
		nHandle:= FCREATE(cQPathTrm + "LIMITE.TXT", FC_NORMAL)
	EndIf
EndIf
cMsg:= OemToAnsi(STR0029) //"Rela‡„o de Documentos por prazo de validade"
FWRITE(nHandle,cMsg)
FWRITE(nHandle,chr(13)+chr(10))
cMsg:= OemToAnsi(STR0030) + DtoC(dDataUsar) //"Data Corrente: "
FWRITE(nHandle,cMsg)
FWRITE(nHandle,chr(13)+chr(10))
cMsg:= OemToAnsi(STR0031) + AllTrim(Str(nDias)) //"Limite de dias: "
FWRITE(nHandle,cMsg)
FWRITE(nHandle,chr(13)+chr(10))
FWRITE(nHandle,chr(13)+chr(10))
FWRITE(nHandle,chr(13)+chr(10))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra Documentos para mostrar documentos validados ou a vencer³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndex:= QDFilDtLim(nDias,dDataUsar)
cAlias:= Alias()
(cAlias)->(DbGotop())
cMsg:= OemToAnsi(STR0039) //"Documentos com data de validade vencidas:"
FWRITE(nHandle,cMsg )
FWRITE(nHandle,chr(13)+chr(10))
FWRITE(nHandle,chr(13)+chr(10))
nCDto:= 0	
If cAlias == "QDH_TRB"
	dDtLim:= STOD((cAlias)->QDH_DTLIM)
Else
	dDtLim:= (cAlias)->QDH_DTLIM
EndIf

While (cAlias)->(!Eof()) .And. dDtLim <= dDataUsar
	nCDto ++
	cMsg:= OemToAnsi(STR0033) + Alltrim((cAlias)->QDH_DOCTO) // "Documento:      "
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
	cMsg:= OemToAnsi(STR0034) + Alltrim((cAlias)->QDH_RV) //        "Revis„o:        "
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
	cMsg:= OemToAnsi(STR0035) + DTOC(dDtLim) // "Data limite:    "
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
	cMsg:= OemToAnsi(STR0040) + AllTrim(Str(dDataUsar-dDtLim)) // "Dias vencidos: "
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
	FWRITE(nHandle,chr(13)+chr(10))
   	(cAlias)->(DbSkip())
	If cAlias == "QDH_TRB"
		dDtLim:= STOD((cAlias)->QDH_DTLIM)
	Else
		dDtLim:= (cAlias)->QDH_DTLIM
	EndIf
EndDo

If nCDto == 0
	cMsg:= OemToAnsi(STR0041) //"N„o h  documentos com data de validade vencidas"
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
EndIf

FWRITE(nHandle,chr(13)+chr(10))
FWRITE(nHandle,chr(13)+chr(10))
cMsg:= OemToansi(STR0032) //"Documentos com data de validade a vencer:"
FWRITE(nHandle,cMsg )
FWRITE(nHandle,chr(13)+chr(10))
FWRITE(nHandle,chr(13)+chr(10))

nCDto:=0
While (cAlias)->(!Eof()) .And. (dDataUsar+nDias) >= dDtLim
	nCDto ++
	cMsg := OemToAnsi(STR0033) + Alltrim((cAlias)->QDH_DOCTO) // "Documento:      "
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
	cMsg:= OemToAnsi(STR0034) + Alltrim((cAlias)->QDH_RV) // "Revisao:        "
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
	cMsg:= OemToAnsi(STR0035) + DTOC(dDtLim) // "Data limite:    "
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
	cMsg:= OemToAnsi(STR0036) + AllTrim(Str(dDtLim-dDataUsar)) // "Dias a vencer    "
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
	FWRITE(nHandle,chr(13)+chr(10))
	(cAlias)->(DbSkip())
	If cAlias == "QDH_TRB"
		dDtLim:= STOD((cAlias)->QDH_DTLIM)
	Else
		dDtLim:= (cAlias)->QDH_DTLIM
	EndIf
EndDo

If nCDto == 0
	cMsg:= OemToAnsi(STR0037) +" "+ AllTrim(Str(nDias))+" "+ OemToAnsi(STR0038) // "N„o h  documentos com data de validade a vencer nos pr¢ximos " ### " dias "
	FWRITE(nHandle,cMsg)
	FWRITE(nHandle,chr(13)+chr(10))
EndIf
FCLOSE(nHandle)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indices de trabalho                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAlias == "QDH_TRB"
	(cAlias)->(DbCloseArea())
EndIf
If cAlias == "TRAB"
	(cAlias)->(dbCloseArea())
EndIf
Ferase(cIndex+OrDbagExt())                  
Ferase(cIndex+GetDBExtension())

If VerSenha(93)	
	If lRemotp //remote linux                  		
		SplitPath(cQPathTrm,@cDrive,)
        cLinCmd:=QA_EXTQLX("limite.txt")+" "+STUFF(cQPathTrm,AT(cDrive,cQPathTrm),Len(cDrive),"")+"limite.txt"
	Else       //remote windows
		cLinCmd:="NOTEPAD "+cQPathTrm+"LIMITE.TXT"
	Endif	       	                               
	WinExec(cLinCmd)
Endif
                                                                           
DbSelectArea("QDH")
Set Filter To

DbSelectArea(cAliasAtu)
DbSetOrder(nOrdemAtu)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QChkMatAce³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se o usuario tem acesso a consulta de documentos     ³±±
±±³          ³ CANCELADOS,OBSOLETOS,VENCIDOS e a DISTRIBUICAO.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QChkMatAce(ExpC1,ExpC2,ExpC3,ExpC4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Revisao do Documento                               ³±±
±±³          ³ ExpC4 - Status do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QChkMatAce(cFilCod,cDocto,cRv,cStatus)

Local nOrder:= QDH->(IndexOrd())
Local nRecNo:= QDH->(RecNo())
Local lRet  := .F.
Local cChave:= ""

QDH->(DbSetOrder(1))

Default cFilCod:= QDH->QDH_FILIAL
Default cDocto := QDH->QDH_DOCTO
Default cRv    := QDH->QDH_RV

cChave := cFilCod + cDocto + cRv

If QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV <> cChave
	lRet := QDH->(DbSeek(cChave))
EndIf

If lRet
	If QDH->QDH_STATUS == "I  "			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o usuario tera permissao para distribui-lo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If VerSenha(92)	 
	    	lRet := .T.
	    Endif	
	ElseIf QDH->QDH_CANCEL == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o usuario tem acesso ao documento cancelado..³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If VerSenha(93)	 
	    	lRet := .T.
	    Endif	
	
	ElseIf QDH->QDH_OBSOL == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o usuario tem acesso ao documento obsoleto...³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		If VerSenha(96)	 
	    	lRet := .T.
	    Endif	

	ElseIf QDH->QDH_DTLIM < dDatabase
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o usuario tem acesso ao documento vencido... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
		If VerSenha(98)	 
	    	lRet := .T.
	    Endif	
	EndIf
EndIf

QDH->( DbSetOrder( nOrder ) )
QDH->( DbGoTo( nRecNo ) )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QChkMatImp³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se o usuario tem acesso a impressao de documentos    ³±±
±±³          ³ CANCELADOS,OBSOLETOS e VENCIDOS.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QChkMatImp(ExpC1,ExpC2,ExpC3,ExpC4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Revisao do Documento                               ³±±
±±³          ³ ExpC4 - Status do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QChkMatImp(cFilCod,cDocto,cRv,cStatus)

Local nOrder:= QDH->(IndexOrd())
Local nRecNo:= QDH->(RecNo())
Local lRet  := .T.
Local cChave:= ""

QDH->(DbSetOrder(1))

Default cFilCod:= QDH->QDH_FILIAL
Default cDocto := QDH->QDH_DOCTO
Default cRv    := QDH->QDH_RV

cChave := cFilCod + cDocto + cRv

If QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV <> cChave
	lRet:= QDH->(DbSeek(cChave))
EndIf

If lRet
	If QDH->QDH_CANCEL == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o usuario tem acesso a impressao do documento cancelado...³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If VerSenha(94)	 
	    	lRet := .T.
	    Endif	

	ElseIf QDH->QDH_OBSOL == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o usuario tem acesso a impressao do documento obsoleto... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If VerSenha(97)	 
	    	lRet := .T.
	    Endif	

	ElseIf QDH->QDH_DTLIM < dDatabase
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o usuario tem acesso ao documento vencido...              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		If VerSenha(99)	 
	    	lRet := .T.
	    Endif	
	EndIf
	QDH->(DbSetOrder(nOrder))
	QDH->(DbGoTo(nRecNo))
EndIf
	
Return lRet
	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QChkMatReat³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se o usuario tem acesso a reativacao de documento    ³±±
±±³          ³ CANCELADOS.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QChkMatReat(ExpC1,ExpC2,ExpC3,ExpC4)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Revisao do Documento                               ³±±
±±³          ³ ExpC4 - Status do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QChkMatReat(cFilCod,cDocto,cRv,cStatus)

Local nOrder:= QDH->(IndexOrd())
Local nRecNo:= QDH->(RecNo())
Local lRet  := .T.
Local cChave:= ""

Default cFilCod:= QDH->QDH_FILIAL
Default cDocto := QDH->QDH_DOCTO
Default cRv    := QDH->QDH_RV

QDH->(DbSetOrder(1))

cChave := cFilCod + cDocto + cRv

If QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV <> cChave
	lRet:= QDH->(DbSeek(cChave))
EndiF

If lRet
	If QDH->QDH_CANCEL == "S"	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o usuario tem acesso a reativacao de documento cancelado...³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If VerSenha(95)	 
	    	lRet := .T.
	    Endif	
	Else		
		Help(" ",1,"QDNEDCANC") // Este documento nao encontra-se cancelado.
		lRet := .F.
	EndIf
EndIf

QDH->(DbSetOrder(nOrder))
QDH->(DbGoTo(nRecNo))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMakeCel  ³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria um novo arquivo.Cel no diretorio especificado pelo    ³±±
±±³          ³ parametro MV_QPATHW via configurador.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMakeCel(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QMakeCel(no)

Local aQPath  := QDOPATH()
Local cQPath  := aQPath[1]	// Diretorio que contem os .CEL
Local cFileCel:= ""

Default no:= 1

cFileCel:= STRZERO(VAL(QA_SEQU("QDH",6,"N")),6)
cFileCel+= SubStr(StrZero(Year(dDataBase),4),3,2)
cFileCel+= ".CEL"

While File(cQPath + cFileCel)
	cFileCel:= STRZERO(VAL(QA_SEQU("QDH",6,"N")),6)
	cFileCel+= SubStr(StrZero(Year(dDataBase),4),3,2)
	cFileCel+= ".CEL"
Enddo

Return cFileCel

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QCopyCel  ³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia (duplica) um arquivo.Cel para um outro arquivo.Cel   ³±±
±±³          ³ no diretorio especificado pelo parametro MV_QPATHW         ³±±
±±³          ³ via configurador, retornando o nome do novo arquivo caso   ³±±
±±³          ³ tenha tido sucesso ou NIL caso contrario.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QCopyCel(ExpC1,ExpC2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - .CEL De                                            ³±±
±±³          ³ ExpC2 - .CEL Para                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QCopyCel( cSource,cTarget )

Local aQPath := QDOPATH()
Local cQPath := aQPath[1]	// Diretorio que contem os .CEL

If cSource == NIL
	Return NIL
EndIf
cSource := AllTrim(cSource)

If cTarget == NIL
	cTarget := QMakeCel()
EndIf
cTarget := AllTrim(cTarget)

_CopyFile(cQPath+cSource,cQPath+cTarget)

Return If(File(cQPath + cTarget),cTarget,NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QEraseCel ³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apaga o arquivo.Cel no diretorio especificado pelo         ³±±
±±³          ³ parametro MV_QPATHW via configurador, retornando .T.       ³±±
±±³          ³ caso tenha sucesso ou .F. caso contrario.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QEraseCel(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do .CEL                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QEraseCel(cFile)

Local aQPath := QDOPATH()
Local cQPath := aQPath[1]	// Diretorio que contem os .CEL

If Empty(cFile:= If(cFile == NIL,"",cFile))
	Return .F.
Else
	If File(cQPath+AllTrim(cFile))
		FErase(cQPath+AllTrim(cFile))
	EndIf
EndIf

Return !File(cQPath+cFile)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDXFNObRep ³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem os Responsaveis de um determinado documento, de      ³±±
±±³          ³ acordo com o tipo de responsabilidade solicitada.          ³±±
±±³          ³ E-Elaborador; R-Revisor; A-Aprovador; H-Homologador        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXFNObRep(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tipo de Responsabilidade                           ³±±
±±³          ³ ExpC2 - Filial do Documento                                ³±±
±±³          ³ ExpC3 - Documento                                          ³±±
±±³          ³ ExpC4 - Revisao do Documento                               ³±±
±±³          ³ ExpC5 - Status do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNObRep(cTpResp,cFilCod,cDocto,cRv,cStatus)

Local nQD0RecNo:= QD0->(RecNo())
Local lRet     := .T.
Local cChave   := ""
Local aResps   := {}

Default cFilCod:= QDH->QDH_FILIAL
Default cDocto := QDH->QDH_DOCTO
Default cRv    := QDH->QDH_RV

QDH->(DbSetOrder(1))

cTpResp:= If(cTpResp == NIL,"D",Left(Upper(cTpResp+Space(1)),1))
cChave := cFilCod + cDocto + cRv

If cTpResp == "D"
	If QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV <> cChave
		lRet:= QDH->(DbSeek(cChave))
	EndIf
	If lRet
		Aadd(aResps,{QDH->QDH_FILMAT,QDH->QDH_MAT,""})
	EndIf
	QDH->( DbSetOrder( nOrder ) )
	QDH->( DbGoTo( nRecNo ) )
Else
	If QD0->(DbSeek(cChave+cTpResp))
		While !QD0->(Eof()) .And. QD0->QD0_FILIAL + QD0->QD0_DOCTO + QD0->QD0_RV + QD0->QD0_AUT == cChave + cTpResp
			Aadd(aResps,{QD0->QD0_FILMAT,QD0->QD0_MAT,QD0->QD0_DEPTO})
			QD0->( DbSkip() )
		End
		QD0->( DbGoTo( nQD0Recno ) )
	Else
		Aadd(aResps,{" "," "," "})
	EndIf
EndIf

Return aResps

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QCreateTmp ³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria arquivo Temporario                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QCreateTmp(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QCreateTmp( cAlias,cKey,cFilter,cMens,cFileTmp )

Return CriaTemp( cAlias,cKey,cFilter,cMens,cFileTmp )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QEraseTmp  ³ Autor ³ Yale Amorim          ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apaga arquivo Temporario                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QEraseTmp(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QEraseTmp( cFileTmp,cAlias )

Return ApagaTemp( cFileTmp, cAlias )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QCreateSeq³ Autor ³ Yale Amorim          ³ Data ³ 18/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria um numero sequencial indepente do arquivo de documento³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QCreateSeq(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tipo de Sequencia (REF/CRI/LOG)                    ³±±
±±³          ³ ExpN1 - Tamanho do numero                                  ³±±
±±³          ³ ExpN2 - Tipo de Numero (Numerico/Caracter)                 ³±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QCreateSeq(cTipo,nTam,cNum)

Return (STRZERO(VAL(QA_SEQU(cTipo,nTam,cNum)),nTam))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QCodSol   ³ Autor ³Newton R. Ghiraldelli ³ Data ³ 24/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera codigo para solitacoes                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QCodSol()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QCodSol()

Local cZeros:= Space(06)
Local nTam  := 0
Local nTem  := 0
Local nFim  := 0

Private Codigo:= " "

cZeros:= "000000"
nTem  := Len(QAA->QAA_MAT)
nTam  := Len(Alltrim(QAA->QAA_MAT))
nFim  := nTem - nTam
Codigo:= Subs(Subs(cZeros,1,nFim)			+;
	Alltrim(QAA->QAA_MAT),1,6)    			+;
	Subs(Str(Year(MsDate())),3,2)			+;
	Subs(StrZero(Month(MsDate())),2,2)	+;
	Subs(StrZero(Day(MsDate())),2,2)		+;
	Subs( Time(),1,2) 							+;
	Subs( Time(),4,2) 							+;
	Subs( Time(),7,2)

Return(Codigo)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDXFNNrRev³ Autor ³Newton Rogerio Ghiralde   ³ Data ³  / /  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Tela de escolha de proxima revisao.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXFNPrMsg(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nRv - Numero da revisao atual                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNNrRev(nRv)

Local cProxNum:= Space(03)

If Empty(M->QDH_RV)
	cProxNum := "000"
Else
	cProxNum := STRZERO(VAL(LEFT(M->QDH_RV,3))+1,3)
Endif

Return (cProxNum)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QA_NSitSol³ Autor ³Programacao Quality    ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna a descricao da situacao da Solicitacao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA_NSitSol(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 - Situacao da Solicitacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_NSitSol(cSitSol)

Default cSitSol:= QDP->QDP_SITSOL

If	SX5->(DbSeek(xFilial("SX5")+"Q8"+cSitSol))
	Return(OemToAnsi(Left(X5Descri(),20)))
Else
	Return(Space(20))
EndIf

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDXFNDesFn³ Autor ³Newton Rogerio Ghiralde³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna a descricao da funcao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXFNDesFn(ExpC1,ExpC2,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 - Codigo da Funcao                                   ³±±
±±³          ³ ExpC2 - Flial do cadastro de funcoes                       ³±±
±±³          ³ ExpN1 - Quantidade de caracteres a ser utilizado para msg  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXFNDesFn(cCodigo,cFilCod,nBytes)

Local cRet:= ""

Default cFilCod:= xFilial("QAC")

If nBytes == NIL .Or. nBytes > 20
	nBytes:= 20
EndIf

If QAC->(DbSeek(cFilCod+cCodigo))
	cRet:= Left(QAC->QAC_DESC+Space(nBytes),nBytes)
Else
	cRet:= Left(OemToAnsi(STR0045)+Space(nBytes),nBytes)  // "** N„o Cadastrado **"
Endif

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQDO_USR ³ Autor ³ Aldo Marini Junior    ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VerIfica pendencia dos Documentos de acordo com o Usuario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQDO_USR()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FQDO_USR()

Local lItem   := .f.


Local aPends  := {}
lOCAL aAvisos := {}
Local cApelido:= TRIM(UPPER(cUserName))

If Empty(cApelido)
	Return
Endif
DbSelectArea("QAA")
DbSetOrder(6)

If QAA->(DbSeek(cApelido))
	If ! QA_SitFolh()
		PswBlock(cApelido)
		MsgAlert(OemToAnsi(STR0046)+chr(13)+; //"Este usu rio encontra-se inativo e n„o pode ter acesso ao sistema de controle de documentos."
		OemToAnsi(STR0047),; //"Seu login ser  bloqueado para evitar problemas de inconsistˆncia na base de dados."
		OemToAnsi(STR0023))  //"Aten‡„o"
		Final(STR0048) //"Usuario Bloqueado"
	Endif
Else
	If cApelido <> OemToAnsi(STR0049) //"Administrador"
		Return
	Endif
EndIf

QAA->(DbSetOrder(1))

If Len(cUsuario) < 150
	cUsuario+= Space(150 - Len(cUsuario))
EndIf

//Ponto de Entrada para trocar ou nao a data utilizada.   dDataBase ou Date()                           
If ExistBlock("QDODATAV")                                    
	dDataUsar := ExecBlock("QDODATAV",.F.,.F.)
Else
	dDataUsar := dDataBase
Endif 
if !(IsPlugin()) //Verifica se o programa foi iniciado pelo SmartClient ActiveX, se sim não executa os msgrun que causa erro no explorer
	MsgRun(OemToAnsi(STR0155),OemToAnsi(STR0002),{|| QDX040Atu()}) //"Atualizando Lancamentos de Ausencia Temporaria..." ### "Aguarde..."
	MsgRun(OemToAnsi(STR0241),OemToAnsi(STR0002),{|| QDXVGFUT(dDataUsar)}) //"Atualizando documentos com vigência futura..." ### "Aguarde..."
	MsgRun(OemToAnsi(STR0051),OemToAnsi(STR0002),{|| QMsgDtLim(dDataUsar)}) //"Gerando documento de validades" ### "Aguarde..."
	MsgRun(OemToAnsi(STR0203),OemToAnsi(STR0002),{|| QDXAvLim(dDataUsar) }) //"Gerando Avisos de validades" ###  "Aguarde..." 
	MsgRun(OemToAnsi(STR0053),OemToAnsi(STR0002),{|| QD030LePen(@aPends,,,@aAvisos)})	// "Selecionando Pendencias..." ### "Aguarde"
else
	QDX040Atu()
	QDXVGFUT(dDataUsar)
    QMsgDtLim(dDataUsar)
    QDXAvLim(dDataUsar)
    QD030LePen(@aPends,,,@aAvisos)
endif
If Len(aPends) > 1 .Or. (Len(aPends) == 1 .And. aPends[1,9] <> -1)
	lItem := MsgYesNo(OemToAnsi(StrTran(STR0052,"%n",StrZero( Len( aPends ),3))),OemToAnsi(STR0023)) //"Existem %n Pendˆncias para vocˆ. Deseja Selecion -las agora?" ### "Aten‡„o"
ElseIf Len(aAvisos) > 1 .Or. (Len(aAvisos) == 1 .And. aAvisos[1,6] <> -1)
	lItem := MsgYesNo(OemToAnsi(STR0146),OemToAnsi(STR0023)) //"Existem avisos para vocˆ. Deseja Selecion -las agora?" ### "Aten‡„o"
EndIf

If lItem 
	QDOA030(aPends,aAvisos)
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQDOTPMAIL  ³ Autor ³ Alexandre Mauricio  ³ Data ³ 9/8/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia eMail para o Usuario Comunicando as Pendencias       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQdotpMail(ExpA1,ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,³±±
±±³          ³ ExpC8,ExpC9,ExpC10,ExpA2,ExpC11,ExpD1)                     ³±±
±±³          ³                                                            ³±±
±±³          ³ Pontos de Entradas Existentes:                             ³±±
±±³          ³ QdoaMail.Prw - Ponto de Entrada de Ausencia Temporaria     ³±±
±±³          ³ QdobMail.Prw - Ponto de Entrada de Tranferencia			  ³±±
±±³          ³ QdodMail.Prw - Ponto de Entrada de Distribuicao            ³±±
±±³          ³ QdofMail.Prw - Ponto de Entrada de Referencias             ³±±
±±³          ³ QdoiMail.Prw - Ponto de Entrada de Solicitacao Novos Doctos³±±
±±³          ³ QdorMail.Prw - Ponto de Entrada de Pendencias              ³±±
±±³          ³ QdosMail.Prw - Ponto de Entrada de Solicitacao de Alteracao³±±
±±³          ³ QdotMail.Prw - Ponto de Entrada de Treinamento             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1  - Retorna todos os dados referente aos emails       ³±±
±±³          ³ ExpC1  - Codigo do Documento                               ³±±
±±³          ³ ExpC2  -  Numero da Revisao do Documento                   ³±±
±±³          ³ ExpC3  -  Titulo do Documento                              ³±±
±±³          ³ ExpC4  -  eMail do Responsavel                             ³±±
±±³          ³ ExpC5  -  Status do Documento                              ³±±
±±³          ³ ExpC6  -  Codigo da Filial                                 ³±±
±±³          ³ ExpC7  -  Nome do Usuario                                  ³±±
±±³          ³ ExpC8  -  Codigo do Usuario                                ³±±
±±³          ³ ExpC9  -  Arquivo anexado no email                         ³±±
±±³          ³ ExpC10 -  Descricao do Documento - Solicitacao             ³±±
±±³          ³ ExpA2  -  Qualquer tipo de dados - Complementares          ³±±
±±³          ³ ExpC11 -  Tipo do Documento                                ³±±
±±³          ³ ExpD1  -  Data de Vigencia                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FQdoTpMail(aUsrMail,cDocto,cRv,cTitulo,cMail,cStatus,cFilMat,cApelido,cCodMat,cAttach,cDescr,aDiv,cTpDocto,dDtVig,aMail)
Local cMsg		:= ""
Local cSubject	:= ""
Local cHora		:= SubStr(Time(),1,5)
Local aMsg		:= {}
Local cPEntr   := "" // define qual ponto de entrada deve ser executado
Local nQAARecno:= QAA->(Recno())
Local nQAAOrd	:= QAA->(IndexOrd())
Local nOrdQD0  := QD0->(IndexOrd())
Local nPosQD0  := QD0->(Recno())
Local nOrdQDB  := QDB->(IndexOrd())
Local nPosQDB  := QDB->(Recno())
Local aUsrMat  := QA_USUARIO()
Local cMatFil  := aUsrMat[2]
Local cMatCod  := aUsrMat[3]
Local cMatDep  := aUsrMat[4]
Local cOldAut  := ""
Local cMotRev  := ""
Local cObjetivo:= ""
Local cSumario := ""
Local cStatSol := ""
Local cMotRepr := ""
Local cRazSol  := ""
Local cTpMail  := "1"
Local aQd0Ord  := {}
Local nCt
Local cSvFilAnt := cFilAnt
Local lTroFil   := .F.       
Local cDescFil  := ""  
Local lQDHFil   := FWModeAccess("QDH") == "C" //Empty(xFilial("QDH"))

Default cAttach := ""
Default cDescr  := ""
Default cCodMat := ""
Default cTpDocto:= ""
Default dDtVig  := CToD("  \  \  ")
Default aDiv	:= {}
Default aMail	:= {}
QAA->(DbGoto(nQAARecno))
cTpMail:= QAA->QAA_TPMAIL
QD0->(DbSetOrder(1))

If  cFilAnt <> QDH->QDH_FILIAL .AND. FWModeAccess("QDH") == "E" //!Empty(AllTrim(xFilial("QDH"))) //Mudo a Variavel publica de Memória como na SuperGetMV
	cFilAnt  := QDH->QDH_FILIAL
	lTroFil  := .T. 
EndIf

nRegAnt := SM0->( Recno() )
If SM0->( DbSeek( cEmpAnt + QDH->QDH_FILIAL ) )
   cDescFil := SM0->M0_NOMECOM
EndIf
SM0->( DbGoTo( nRegAnt ) )

If cStatus $ "D  ,E  ,R  ,A  ,H  ,I  ,L  ,EC "
	cSubject := Trim(cDocto)+"-"+Trim(cRv)+"-"+Trim(cTitulo)+" - "+DTOC(dDataBase)+" - "+cHora
	If cTpMail == "1"
		cMsg:= '<html><title>SIGAQDO</title><body>'
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+= '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
		cMsg+= '    borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
		cMsg+= '    <p align="center"><FONT face="Courier New" color="#ffffff" size="4">'
		cMsg+= '    <b>'+OemToAnsi(STR0111)+'</b></font></p></td></tr>' // "MENSAGEM"
        
		If lQDHFil  
		
			If cDescr == "C" // "Distribuicao de Documento Cancelado"
				cMsg+= '  <tr><td align="left" width="606" height="32"><p align="center">'+OemToAnsi(STR0145)+'</p></td></tr>' // "Existe um Cancelamento de Documento"
			ElseIf cDescr == "BX" // Pendencia Baixada por outro responsavel
				cMsg+= '  <tr><td align="left" width="606" height="32"><p align="center">'+OemToAnsi(STR0028)+" "+ AllTrim(Qa_nSit(cStatus))+" "+OemToAnsi(STR0042)+'</p></td></tr>' // "A pendencia de " ### "foi baixada por outro responsavel, favor desconsiderar a pendencia."
			Else
				cMsg+= '  <tr><td align="left" width="606" height="32"><p align="center">'+OemToAnsi(STR0081)+" "+ AllTrim(Qa_nSit(cStatus))+" "+iif(cStatus=="I  ",OemToAnsi(STR0091),OemToAnsi(STR0082))+'</p></td></tr>' // "Existe pendencia de " ### " neste Documento, favor baixar rapidamente"
			EndIf
	
        Else    
        
			If cDescr == "C" // "Distribuicao de Documento Cancelado"
				cMsg+= '  <tr><td align="left" width="606" height="32"><p align="center">'+OemToAnsi(STR0145) // "Existe um Cancelamento de Documento"
			ElseIf cDescr == "BX" // Pendencia Baixada por outro responsavel
				cMsg+= '  <tr><td align="left" width="606" height="32"><p align="center">'+OemToAnsi(STR0028)+" "+ AllTrim(Qa_nSit(cStatus))+" "+OemToAnsi(STR0042) // "A pendencia de " ### "foi baixada por outro responsavel, favor desconsiderar a pendencia."
			Else
				cMsg+= ' <tr><td align="left" width="606" height="32"><p align="center">'+OemToAnsi(STR0081)+" "+ AllTrim(Qa_nSit(cStatus))+" "+iif(cStatus=="I  ",OemToAnsi(STR0091),OemToAnsi(STR0082))// "Existe pendencia de " ### " neste Documento, favor baixar rapidamente"
			EndIf
	
			If FWModeAccess("QDH")=="E" //!Empty(Alltrim(xFilial("QDH")))			
				cMsg+= ' <br><b>'+'Obs:'+'</b> '+STR0240+cFilAnt+" - "+cDescFil 
			EndIf
			
			cMsg+= ' </p></td></tr>'
	
		EndIf

		cMsg+= '</table><br>'
					
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+= '  <tr><td align="left" width="480" height="32"><b>'+OemToAnsi(STR0113)+'</b><br>'+cDocto // "Documento"
		cMsg+= '  </td><td align="left" width="080" height="32"><b>'+OemToAnsi(STR0114)+'</b><br>'+cRv+'</td></tr>' // "Revisao"
		cMsg+= '  <tr><td align="left" width="480" height="32"><b>'+OemToAnsi(STR0115)+'</b><br>'+QDXFNANTPD(cTpDocto) // "Tipo de Documento"
		cMsg+= '  </td><td align="left" width="080" height="32"><b>'+OemToAnsi(STR0116)+'</b><br>'+DToC(dDtVig) // "Dt Vigencia"
		cMsg+= '  </td></tr><tr><td colspan="4" align="left" width="480" height="32"><b>'+OemToAnsi(STR0124)+'</b><br>'+cTitulo+'</td></tr>'  // "Titulo"
		cMsg+= '</table>'
		
		If QA2->(DbSeek(xFilial("QA2")+"OBJ     "+QDH->QDH_CHAVE))
			cObjetivo:= QA_Rectxt(QDH->QDH_CHAVE,"OBJ     ")
			cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
			cMsg+= '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
			cMsg+= '    borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
			cMsg+= '    <p align="center"><FONT face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0127)+'</b></td></tr>' // "Obetivo"
			cMsg+= '  <tr><td align="left" width="645" height="32">'+cObjetivo+'</td></tr>'
			cMsg+= '</table>'
		EndIf
		If QA2->(DbSeek(xFilial("QA2")+"SUM     "+QDH->QDH_CHAVE))
			cSumario:= QA_Rectxt(QDH->QDH_CHAVE,"SUM     ")
			cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
			cMsg+= '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
			cMsg+= '    borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
			cMsg+= '    <p align="center"><FONT face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0128)+'</b></td></tr>' // "Obetivo"
			cMsg+= '    <tr><td align="left" width="645" height="32">'+cSumario+'</td></tr>'
			cMsg+= '</table>'
		EndIf
		If QA2->(DbSeek(xFilial("QA2")+"REV     "+QDH->QDH_CHAVE))
			cMotRev:= QA_Rectxt(QDH->QDH_CHAVE,"REV     ")
			cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
			cMsg+= '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
			cMsg+= '    borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
			cMsg+= '    <p align="center"><FONT face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0129)+'</b></td></tr>' // "Obetivo"
			cMsg+= '    <tr><td align="left" width="645" height="32">'+cMotRev+'</td></tr>'
			cMsg+= '</table>'
		EndIf
		
		If QD0->(DbSeek(xFilial("QD0")+cDocto+cRv))
			cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1><tr>'
			aQd0Ord:={}
			While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == xFilial("QD0")+cDocto+cRv
			    IF QD0->QD0_FLAG <> 'I'
					AADD(aQd0Ord,{QD0->QD0_AUT,Alltrim(QA_NUSR(QD0->QD0_FILMAT,QD0->QD0_MAT))}) 
     			Endif
				QD0->(DbSkip())
			EndDo	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Organiza a Matriz de Responsabilidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF LEN(aQd0Ord) > 0
				For nCt := 1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "E"
						aQd0Ord[nCt][1] := "1"
					ElseIf aQd0Ord[nCt][1] == "R"
						aQd0Ord[nCt][1] := "2"
					ElseIf aQd0Ord[nCt][1] == "A"
						aQd0Ord[nCt][1] := "3"
					ElseIf aQd0Ord[nCt][1] == "H"
						aQd0Ord[nCt][1] := "4"
					EndIf
				Next
				aQd0Ord := aSort( aQd0Ord, , , { |x,y| x[1] < y[1]} )
				For nCt :=1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "1"
						aQd0Ord[nCt][1] := "E"
					ElseIf aQd0Ord[nCt][1] == "2"
						aQd0Ord[nCt][1] := "R"
					ElseIf aQd0Ord[nCt][1] == "3"
						aQd0Ord[nCt][1] := "A"
					ElseIf aQd0Ord[nCt][1] == "4"
						aQd0Ord[nCt][1] := "H"
					EndIf
				Next					
			Endif	

        	For nCt:=1 To Len(aQd0Ord) 
				If aQd0Ord[nCt,1] == "E"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>' +OemToAnsi(STR0117)+'</b><br>'+aQd0Ord[nCt,2] // "Elaboradores"
						cOldAut:= "E"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "R"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>'+OemToAnsi(STR0118)+'</b><br>'+aQd0Ord[nCt,2] // "Revisor"
						cOldAut:= "R"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "A"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>'+OemToAnsi(STR0119)+'</b><br>'+aQd0Ord[nCt,2] // "Aprovador"
						cOldAut:= "A"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "H"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>'+OemToAnsi(STR0204)+'</b><br>'+aQd0Ord[nCt,2]   //"Homologador"
						cOldAut:= "H"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				EndIf        	        
			Next            		
			cMsg+= '</tr></table><br><br>'
		EndIf
		
		cMsg+= OemToAnsi(STR0083)+'<br>'+Alltrim(QA_NUSR(cMatFil,cMatCod)) //"Atenciosamente"
		cMsg+= '<br>'+Alltrim(QA_NDEPT(cMatDep))
		cMsg+= '<br><p><font size="2"><em>'+OemToAnsi(STR0084)+'</em></font></p></body></html>' // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	Else
		If cDescr == "C" // "Distribuicao de Documento Cancelado"
			cMsg+= OemToAnsi(STR0145)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Existe um Cancelamento de Documento"
		ElseIf cDescr == "BX" // Pendencia Baixada por outro responsavel
			cMsg+= OemToAnsi(STR0028)+" "+ AllTrim(Qa_nSit(cStatus))+" "+OemToAnsi(STR0042)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "A pendencia de " ### "neste documento foi baixada por outro responsavel, favor desconsiderar a pendencia."
		Else
			cMsg+= OemToAnsi(STR0081)+" "+ AllTrim(Qa_nSit(cStatus))+" "+iif(cStatus=="I  ",OemToAnsi(STR0091),OemToAnsi(STR0082))+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Favor Gerar Revisao do Documento que consta na Referencia"
		EndIf
		cMsg+= OemToAnsi(STR0113)+": "+cDocto+"  -  " // "Documento"
		cMsg+= OemToAnsi(STR0114)+": "+cRv+"  -  "+OemToAnsi(STR0116)+": "+DToC(dDtVig)+CHR(13)+CHR(10) // "Revisao" ### "Dt Vigencia"
		cMsg+= OemToAnsi(STR0115)+": "+QDXFNANTPD(cTpDocto)+CHR(13)+CHR(10) // "Tipo de Documento"
		cMsg+= OemToAnsi(STR0124)+": "+cTitulo+CHR(13)+CHR(10)+CHR(13)+CHR(10)  // "Titulo"
		
		If QA2->(DbSeek(xFilial("QA2")+"OBJ     "+QDH->QDH_CHAVE))
			cObjetivo:= QA_Rectxt(QDH->QDH_CHAVE,"OBJ     ")
			cMsg+= Upper(OemToAnsi(STR0127))+CHR(13)+CHR(10) // "Objetivo"
			cMsg+= cObjetivo+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		EndIf
		If QA2->(DbSeek(xFilial("QA2")+"SUM     "+QDH->QDH_CHAVE))
			cSumario:= QA_Rectxt(QDH->QDH_CHAVE,"SUM     ")
			cMsg+= Upper(OemToAnsi(STR0128))+CHR(13)+CHR(10) // "Sumario"
			cMsg+= cSumario+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		EndIf
		If QA2->(DbSeek(xFilial("QA2")+"REV     "+QDH->QDH_CHAVE))
			cMotRev:= QA_Rectxt(QDH->QDH_CHAVE,"REV     ")
			cMsg+= Upper(OemToAnsi(STR0129))+CHR(13)+CHR(10) // "Motivo da Revisao"
			cMsg+= cMotRev+CHR(13)+CHR(10)
		EndIf
		
		If QD0->(DbSeek(xFilial("QD0")+cDocto+cRv))
			aQd0Ord:={}
			While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == xFilial("QD0")+cDocto+cRv
			    IF QD0->QD0_FLAG <> 'I'
					AADD(aQd0Ord,{QD0->QD0_AUT,Alltrim(QA_NUSR(QD0->QD0_FILMAT,QD0->QD0_MAT))}) 
     			Endif
				QD0->(DbSkip())
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Organiza a Matriz de Responsabilidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF LEN(aQd0Ord) > 0
				For nCt := 1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "E"
						aQd0Ord[nCt][1] := "1"
					ElseIf aQd0Ord[nCt][1] == "R"
						aQd0Ord[nCt][1] := "2"
					ElseIf aQd0Ord[nCt][1] == "A"
						aQd0Ord[nCt][1] := "3"
					ElseIf aQd0Ord[nCt][1] == "H"
						aQd0Ord[nCt][1] := "4"
					EndIf
				Next
				aQd0Ord := aSort( aQd0Ord, , , { |x,y| x[1] < y[1]} )
				For nCt :=1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "1"
						aQd0Ord[nCt][1] := "E"
					ElseIf aQd0Ord[nCt][1] == "2"
						aQd0Ord[nCt][1] := "R"
					ElseIf aQd0Ord[nCt][1] == "3"
						aQd0Ord[nCt][1] := "A"
					ElseIf aQd0Ord[nCt][1] == "4"
						aQd0Ord[nCt][1] := "H"
					EndIf
				Next					
			Endif	

        	For nCt:=1 To Len(aQd0Ord) 			
				If aQd0Ord[nCt,1] == "E"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= CHR(13)+CHR(10)+Upper(OemToAnsi(STR0117))+CHR(13)+CHR(10)
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10) // "Elaboradores"
						cOldAut:= "E"
					Else
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10)
					EndIf
				ElseIf aQd0Ord[nCt,1] == "R"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= CHR(13)+CHR(10)+Upper(OemToAnsi(STR0118))+CHR(13)+CHR(10)
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10) // "Revisores"
						cOldAut:= "R"
					Else
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10)
					EndIf
				ElseIf aQd0Ord[nCt,1] == "A"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= CHR(13)+CHR(10)+Upper(OemToAnsi(STR0119))+CHR(13)+CHR(10)
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10) // "Aprovadores"
						cOldAut:= "A"
					Else
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10)
					EndIf
				ElseIf aQd0Ord[nCt,1] == "H"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= CHR(13)+CHR(10)+Upper(OemToAnsi(STR0204))+CHR(13)+CHR(10)  //"Homologador"
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10) 
						cOldAut:= "H"
					Else
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10)
					EndIf
	
				EndIf				
			Next
			cMsg+= CHR(13)+CHR(10)+CHR(13)+CHR(10)
		EndIf
		
		cMsg+= +CHR(13)+CHR(10)+OemToAnsi(STR0083)+CHR(13)+CHR(10) //"Atenciosamente"
		cMsg+= Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10)
		cMsg+= Alltrim(QA_NDEPT(cMatDep))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg+= OemToAnsi(STR0084) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	EndIf
	aMsg		:=  { { cSubject,cMsg,cAttach } }
	cPEntr   := "R"
	If cStatus == "L  " .or. cStatus == "I  " // Leitura // Distribuicao
		cPentr := "D" // distribuicao do Documento paras Leitura
	EndIf
	
ElseIf SubStr(cStatus,1,3) == "SID" // Solicitacao de Novos Documentos
	
	cSubject := Trim(aDiv[1][1]) +" - "+ Trim(OemToAnsi(STR0104))+" - "+DTOC(dDataBase)+" - "+cHora // "Solicitacao de Inclusao de Documento"
	If cTpMail == "1"
		cMsg:='<html><title>sigaqdo</title><body>'
		cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
		cMsg+=' <tr><td bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606"'
		cMsg+='   bgcolor="#0099cc" bordercolordark="#0099cc" height="1">'
		cMsg+='   <p align="center"><font face="courier new" color="#ffffff" size="4">'
		cMsg+='   <b>'+OemToAnsi(STR0111)+'</b></font></p></td></tr>' // "MENSAGEM"
		cMsg+=' <tr><td align="left" width="606" height="32">'
		If cStatus == "SID3" .Or. cStatus == "SID4"
			cMsg+='<p align="center">'+OemToAnsi(STR0105)+'</p></td></tr>' // "Existe pendencia de Solicitacao de Novo Documento."
		ElseIf cStatus == "SID5"
			cMsg+='<p align="center">'+OemToAnsi(STR0106)+'</p></td></tr>' // "Cancelada a Pendencia de Solicitacao de Novo Documento."
		ElseIf cStatus == "SID6"
			cMsg+='<p align="center">'+OemToAnsi(STR0108)+'</p></td></tr>' // "Baixada a Pendencia de Solicitacao de Novo Documento."
		EndIf
		cMsg+='</table><br>'
		
		cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
		cMsg+=' <tr><td colspan="3" bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606" bgcolor="#0099cc" bordercolordark="#0099cc" height="1">'
		cMsg+='   <p align="center"><font face="courier new" color="#ffffff" size="4">'
		cMsg+='   <b>'+OemToAnsi(STR0104)+'</b></font></p></td></tr>' // "Solicitacao de Inclusao de Documentos"
		cMsg+=' <tr><td align="left" width="15%" height="32"><b>'+OemToAnsi(STR0107)+'</b><br>'+aDiv[1][1]+'</td>' // "Solicitacao"
		cMsg+='   <td align="left" width="70%" height="32"><b>'+OemToAnsi(STR0123)+'</b><br>'+cDescr+'</td>' // "Descricao"
		cMsg+='   <td align="left" width="15%" height="32"><b>'+OemToAnsi(STR0130)+'</b><br>'+aDiv[1][2]+'</td></tr>' // "Data"
		cMsg+='</table>'
		
		cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
		cMsg+=' <tr><td align="left" width="50%" height="32"><b>'+OemToAnsi(STR0131)+'</b><br>'+Alltrim(QA_NUSR(cMatFil,cMatCod))+'</td>' // "Solicitante"
		cMsg+='   <td align="left" width="50%" height="32"><b>'+OemToAnsi(STR0132)+'</b><br>'+Alltrim(QA_NDEPT(cMatDep))+'</td></tr>' // "Departamento"
		cMsg+='</table>'
		
		If QA2->(DbSeek(xFilial("QA2")+"SID     "+QDP->QDP_CHAVE))
			cRazSol:= QA_Rectxt(QDP->QDP_CHAVE,"SID     ")
			cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
			cMsg+='  <tr><td colspan="3" bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606" '
			cMsg+='    bgcolor="#0099cc" bordercolordark="#0099cc" height="1">'
			cMsg+='    <p align="center"><font face="courier new" color="#ffffff" size="4">'
			cMsg+='    <b>'+OemToAnsi(STR0133)+'</b></font></p></td></tr>' // "Razao da Solicitacao"
			cMsg+='<tr><td align="left" width="100%" height="32">'+cRazSol+'</td></tr>'
			cMsg+='</table>'
		EndIf
		
		If QDP->(DbSeek(xFilial("QDP")+""+""+aDiv[1][1]))
			If QDP->QDP_PENDEN == "B"
				If QDP->QDP_SITSOL == "E"
					cStatSol:= OemToAnsi(STR0138)
				ElseIf QDP->QDP_SITSOL == "A"
					cStatSol:= OemToAnsi(STR0139)
				ElseIf QDP->QDP_SITSOL == "R"
					cStatSol:= OemToAnsi(STR0140)
				EndIf
				cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
				cMsg+='  <tr><td align="left" width="85%" height="32"><b>'+OemToAnsi(STR0134)+'</b><br>'+Alltrim(QA_NUSR(aDiv[1][3],aDiv[1][4]))+'</td>' // "Responsavel pela Baixa"
				cMsg+='    <td align="left" width="15%" height="32"><b>'+OemToAnsi(STR0135)+'</b><br>'+aDiv[1][5]+'</td></tr>' // "Data Baixa"
				cMsg+='  <tr><td align="left" width="85%" height="32"><b>'+OemToAnsi(STR0132)+'</b><br>'+Alltrim(QA_NDEPT(aDiv[1][6]))+'</td>' // "Departamento"
				cMsg+='    <td align="left" width="15%" height="32"><b>'+OemToAnsi(STR0136)+'</b><br>'+cStatSol+'</td></tr>' // "Status"
				cMsg+='</table>'
			EndIf
			If QDP->QDP_SITSOL == "R"
				cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
				cMsg+='  <tr><td colspan="3" bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606"'
				cMsg+='    bgcolor="#0099cc" bordercolordark="#0099cc" height="1">'
				cMsg+='    <p align="center"><font face="courier new" color="#ffffff" size="4">'
				cMsg+='    <b>'+OemToAnsi(STR0137)+'</b></font></p></td></tr>'
				If QA2->(DbSeek(xFilial("QA2")+"QD052MOT"+QDP->QDP_CHAVE))
					cMotRepr:= QA_Rectxt(QDP->QDP_CHAVE,"QD052MOT")
					cMsg+='  <tr><td align="left" width="100%" height="32">'+cMotRepr+'</td></tr>' // "Motivo da Reprovacao"
				EndIf
				cMsg+='</table>'
			EndIf
		EndIf
		cMsg+= OemToAnsi(STR0083)+'<br>'+Alltrim(QA_NUSR(cMatFil,cMatCod)) //"Atenciosamente"
		cMsg+= '<br>'+Alltrim(QA_NDEPT(cMatDep))
		cMsg+= '<br><p><font size="2"><em>'+OemToAnsi(STR0084)+'</em></font></p></body></html>' // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	Else
		If cStatus == "SID3" .Or. cStatus == "SID4"
			cMsg+= OemToAnsi(STR0105)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Existe pendencia de Solicitacao de Novo Documento."
		ElseIf cStatus == "SID5"
			cMsg+= OemToAnsi(STR0106)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Cancelada a Pendencia de Solicitacao de Novo Documento."
		ElseIf cStatus == "SID6"
			cMsg+= OemToAnsi(STR0108)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Baixada a Pendencia de Solicitacao de Novo Documento."
		EndIf
		cMsg+= OemToAnsi(STR0107)+": "+aDiv[1][1]+" - "+OemToAnsi(STR0123)+": "+cDescr+" - "+OemToAnsi(STR0130)+": "+aDiv[1][2]+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Solicitacao" ### "Descricao" ### "Data"
		cMsg+= OemToAnsi(STR0131)+": "+Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10) // "Solicitante"
		cMsg+= OemToAnsi(STR0132)+": "+Alltrim(QA_NDEPT(cMatDep))+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Departamento"
		If QA2->(DbSeek(xFilial("QA2")+"SID     "+QDP->QDP_CHAVE))
			cRazSol:= QA_Rectxt(QDP->QDP_CHAVE,"SID     ")
			cMsg+= Upper(OemToAnsi(STR0133))+CHR(13)+CHR(10) // "Razao da Solicitacao"
			cMsg+=cRazSol+CHR(13)+CHR(10)
		EndIf
		
		If QDP->(DbSeek(xFilial("QDP")+""+""+aDiv[1][1]))
			If QDP->QDP_PENDEN == "B"
				If QDP->QDP_SITSOL == "E"
					cStatSol:= OemToAnsi(STR0138)
				ElseIf QDP->QDP_SITSOL == "A"
					cStatSol:= OemToAnsi(STR0139)
				ElseIf QDP->QDP_SITSOL == "R"
					cStatSol:= OemToAnsi(STR0140)
				EndIf
				cMsg+= CHR(13)+CHR(10)
				cMsg+= OemToAnsi(STR0134)+": "+Alltrim(QA_NUSR(aDiv[1][3],aDiv[1][4]))+" - " // "Responsavel pela Baixa"
				cMsg+= OemToAnsi(STR0135)+": "+aDiv[1][5]+CHR(13)+CHR(10) // "Data Baixa"
				cMsg+= OemToAnsi(STR0132)+": "+Alltrim(QA_NDEPT(aDiv[1][6]))+CHR(13)+CHR(10) // "Departamento"
				cMsg+= OemToAnsi(STR0136)+": "+cStatSol+CHR(13)+CHR(10) // "Status"
			EndIf
			If QDP->QDP_SITSOL == "R"
				cMsg+= CHR(13)+CHR(10)+Upper(OemToAnsi(STR0137))+CHR(13)+CHR(10) // "Motivo da Reprovacao"
				If QA2->(DbSeek(xFilial("QA2")+"QD052MOT"+QDP->QDP_CHAVE))
					cMotRepr:= QA_Rectxt(QDP->QDP_CHAVE,"QD052MOT")
					cMsg+= cMotRepr+CHR(13)+CHR(10)
				EndIf
			EndIf
		EndIf
		cMsg+= CHR(13)+CHR(10)+OemToAnsi(STR0083)+CHR(13)+CHR(10) //"Atenciosamente"
		cMsg+= Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10)
		cMsg+= Alltrim(QA_NDEPT(cMatDep))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg+= OemToAnsi(STR0084) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	EndIf
	
	aMsg	:=  { { cSubject,cMsg,cAttach } }
	cPEntr:= "I"
	
ElseIf SubStr(cStatus,1,3) == "SAD" // Solicitacao de Alteracao de Documentos
	cSubject := Trim(cDocto) +" - "+Trim(cRv)+" - "+Trim(OemToAnsi(STR0085))+" - "+DTOC(dDataBase)+" - "+cHora // "Solicitacao de Alteracao do Documento"
	If cTpMail == "1"
		cMsg:='<html><title>sigaqdo</title><body>'
		cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
		cMsg+=' <tr><td bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606"'
		cMsg+='   bgcolor="#0099cc" bordercolordark="#0099cc" height="1">'
		cMsg+='   <p align="center"><font face="courier new" color="#ffffff" size="4">'
		cMsg+='   <b>'+OemToAnsi(STR0111)+'</b></font></p></td></tr>' // "MENSAGEM"
		cMsg+=' <tr><td align="left" width="606" height="32">'
		If cStatus == "SAD3" .Or. cStatus == "SAD4"
			cMsg+='<p align="center">'+OemToAnsi(STR0088)+'</p></td></tr>' // Existe pendencia de  Solicitacao de Alteracao neste Documento."
		ElseIf cStatus == "SAD5"
			cMsg+='<p align="center">'+OemToAnsi(STR0109)+'</p></td></tr>' // "Cancelada a Pendencia de Solicitacao de Alteracao neste Documento."
		ElseIf cStatus == "SAD6"
			cMsg+='<p align="center">'+OemToAnsi(STR0110)+'</p></td></tr>' // "Baixada a Pendencia de Solicitacao de Alteracao neste Documento."
		EndIf
		cMsg+='</table><br>'
		
		cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
		cMsg+=' <tr><td colspan="3" bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606" bgcolor="#0099cc" bordercolordark="#0099cc" height="1">'
		cMsg+='   <p align="center"><font face="courier new" color="#ffffff" size="4">'
		cMsg+='   <b>'+OemToAnsi(STR0085)+'</b></font></p></td></tr>' // "Solicitacao de Alteracao de Documentos"
		cMsg+=' <tr><td align="left" width="22%" height="32"><b>'+OemToAnsi(STR0107)+'</b><br>'+aDiv[1][1]+'</td>' // "Solicitacao"
		cMsg+='   <td align="left" width="68%" height="32"><b>'+OemToAnsi(STR0123)+'</b><br>'+cDescr+'</td>' // "Descricao"
		cMsg+='   <td align="left" width="15%" height="32"><b>'+OemToAnsi(STR0130)+'</b><br>'+aDiv[1][2]+'</td></tr>' // "Data"
		cMsg+='</table>'
		
		cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
		cMsg+=' <tr><td align="left" width="50%" height="32"><b>'+OemToAnsi(STR0131)+'</b><br>'+Alltrim(QA_NUSR(cMatFil,cMatCod))+'</td>' // "Solicitante"
		cMsg+='   <td align="left" width="50%" height="32"><b>'+OemToAnsi(STR0132)+'</b><br>'+Alltrim(QA_NDEPT(cMatDep))+'</td></tr>' // "Departamento"
		cMsg+='</table>'
		
		cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
		cMsg+=' <tr><td valign="top" width="22%" height="32"><b>'+OemToAnsi(STR0113)+'</b><br>'+cDocto+'</td>' // "Documento"
		cMsg+='   <td valign="top" width="10%" height="32"><b>'+OemToAnsi(STR0114)+'</b><br>'+cRv+'</td>' // "Revisao"
		cMsg+='   <td valign="top" width=68% height="32"><b>'+OemToAnsi(STR0124)+'</b><br>'+cTitulo+'</td></tr>' // "Titulo"
		cMsg+='</table>'
		
		If QD0->(DbSeek(xFilial("QD0")+cDocto+cRv))
			cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1><tr>'
			aQd0Ord:={}
			While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == xFilial("QD0")+cDocto+cRv
			    IF QD0->QD0_FLAG <> 'I'
					AADD(aQd0Ord,{QD0->QD0_AUT,Alltrim(QA_NUSR(QD0->QD0_FILMAT,QD0->QD0_MAT))}) 
     			Endif
				QD0->(DbSkip())
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Organiza a Matriz de Responsabilidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF LEN(aQd0Ord) > 0
				For nCt := 1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "E"
						aQd0Ord[nCt][1] := "1"
					ElseIf aQd0Ord[nCt][1] == "R"
						aQd0Ord[nCt][1] := "2"
					ElseIf aQd0Ord[nCt][1] == "A"
						aQd0Ord[nCt][1] := "3"
					ElseIf aQd0Ord[nCt][1] == "H"
						aQd0Ord[nCt][1] := "4"
					EndIf
				Next
				aQd0Ord := aSort( aQd0Ord, , , { |x,y| x[1] < y[1]} )
				For nCt :=1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "1"
						aQd0Ord[nCt][1] := "E"
					ElseIf aQd0Ord[nCt][1] == "2"
						aQd0Ord[nCt][1] := "R"
					ElseIf aQd0Ord[nCt][1] == "3"
						aQd0Ord[nCt][1] := "A"
					ElseIf aQd0Ord[nCt][1] == "4"
						aQd0Ord[nCt][1] := "H"
					EndIf
				Next					
			Endif	

        	For nCt:=1 To Len(aQd0Ord) 
				If aQd0Ord[nCt,1] == "E"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="34%" height="32"><b>' +OemToAnsi(STR0117)+'</b><br>'+aQd0Ord[nCt,2] // "Elaboradores"
						cOldAut:= "E"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "R"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="34%" height="32"><b>'+OemToAnsi(STR0118)+'</b><br>'+aQd0Ord[nCt,2] // "Revisores"
						cOldAut:= "R"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "A"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="32%" height="32"><b>'+OemToAnsi(STR0119)+'</b><br>'+aQd0Ord[nCt,2] // "Aprovadores"
						cOldAut:= "A"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "H"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="32%" height="32"><b>'+OemToAnsi(STR0204)+'</b><br>'+aQd0Ord[nCt,2]   //"Homologador"
						cOldAut:= "H"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				EndIf
			Next	
			cMsg+= '</tr></table>'
		EndIf
		
		If QA2->(DbSeek(xFilial("QA2")+"SAD     "+QDP->QDP_CHAVE))
			cRazSol:= QA_Rectxt(QDP->QDP_CHAVE,"SAD     ")
			cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
			cMsg+='  <tr><td colspan="3" bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606" '
			cMsg+='    bgcolor="#0099cc" bordercolordark="#0099cc" height="1">'
			cMsg+='    <p align="center"><font face="courier new" color="#ffffff" size="4">'
			cMsg+='    <b>'+OemToAnsi(STR0133)+'</b></font></p></td></tr>' // "Razao da Solicitacao"
			cMsg+='<tr><td align="left" width="100%" height="32">'+cRazSol+'</td></tr>'
			cMsg+='</table>'
		EndIf
		
		If QDP->(DbSeek(xFilial("QDP")+cDocto+cRv+aDiv[1][1]))
			If QDP->QDP_PENDEN == "B"
				If QDP->QDP_SITSOL == "E"
					cStatSol:= OemToAnsi(STR0138)
				ElseIf QDP->QDP_SITSOL == "A"
					cStatSol:= OemToAnsi(STR0139)
				ElseIf QDP->QDP_SITSOL == "R"
					cStatSol:= OemToAnsi(STR0140)
				EndIf
				cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
				cMsg+='  <tr><td align="left" width="85%" height="32"><b>'+OemToAnsi(STR0134)+'</b><br>'+Alltrim(QA_NUSR(aDiv[1][3],aDiv[1][4]))+'</td>' // "Responsavel pela Baixa"
				cMsg+='    <td align="left" width="15%" height="32"><b>'+OemToAnsi(STR0135)+'</b><br>'+aDiv[1][5]+'</td></tr>' // "Data Baixa"
				cMsg+='  <tr><td align="left" width="85%" height="32"><b>'+OemToAnsi(STR0132)+'</b><br>'+Alltrim(QA_NDEPT(aDiv[1][6]))+'</td>' // "Departamento"
				cMsg+='    <td align="left" width="15%" height="32"><b>'+OemToAnsi(STR0136)+'</b><br>'+cStatSol+'</td></tr>' // "Status"
				cMsg+='</table>'
			EndIf
			If QDP->QDP_SITSOL == "R"
				cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
				cMsg+='  <tr><td colspan="3" bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606"'
				cMsg+='    bgcolor="#0099cc" bordercolordark="#0099cc" height="1">'
				cMsg+='    <p align="center"><font face="courier new" color="#ffffff" size="4">'
				cMsg+='    <b>'+OemToAnsi(STR0137)+'</b></font></p></td></tr>'
				If QA2->(DbSeek(xFilial("QA2")+"QD052MOT"+QDP->QDP_CHAVE))
					cMotRepr:= QA_Rectxt(QDP->QDP_CHAVE,"QD052MOT")
					cMsg+='  <tr><td align="left" width="100%" height="32">'+cMotRepr+'</td></tr>' // "Motivo da Reprovacao"
				EndIf
				cMsg+='</table>'
			EndIf
		EndIf
		cMsg+= '<br>'+OemToAnsi(STR0083)+'<br>'+Alltrim(QA_NUSR(cMatFil,cMatCod)) //"Atenciosamente"
		cMsg+= '  <br>'+Alltrim(QA_NDEPT(cMatDep))
		cMsg+= '  <br><p><font size="2"><em>'+OemToAnsi(STR0084)+'</em></font></p></body></html>' // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	Else
		If cStatus == "SAD3" .Or. cStatus == "SAD4"
			cMsg:= OemToAnsi(STR0088)+CHR(13)+CHR(10) // Existe pendencia de  Solicitacao de Alteracao neste Documento."
		ElseIf cStatus == "SAD5"
			cMsg:= OemToAnsi(STR0109)+CHR(13)+CHR(10) // "Cancelada a Pendencia de Solicitacao de Alteracao neste Documento."
		ElseIf cStatus == "SAD6"
			cMsg:= OemToAnsi(STR0110)+CHR(13)+CHR(10) // "Baixada a Pendencia de Solicitacao de Alteracao neste Documento."
		EndIf
		cMsg+= CHR(13)+CHR(10)+OemToAnsi(STR0107)+": "+aDiv[1][1]+"  -  " // "Solicitacao"
		cMsg+= OemToAnsi(STR0130)+": "+aDiv[1][2]+CHR(13)+CHR(10) // "Data"
		cMsg+= OemToAnsi(STR0123)+": "+cDescr+CHR(13)+CHR(10) // "Descricao"
		cMsg+= OemToAnsi(STR0113)+": "+cDocto+"  -  " // "Documento"
		cMsg+= OemToAnsi(STR0114)+": "+cRv+CHR(13)+CHR(10) // "Revisao"
		cMsg+= OemToAnsi(STR0124)+": "+cTitulo+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Titulo"
		
		cMsg+= OemToAnsi(STR0131)+": "+Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10) // "Solicitante"
		cMsg+= OemToAnsi(STR0132)+": "+Alltrim(QA_NDEPT(cMatDep))+CHR(13)+CHR(10) // "Departamento"
		
		If QD0->(DbSeek(xFilial("QD0")+cDocto+cRv))
			aQd0Ord:={}
			While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == xFilial("QD0")+cDocto+cRv
			    IF QD0->QD0_FLAG <> 'I'
					AADD(aQd0Ord,{QD0->QD0_AUT,Alltrim(QA_NUSR(QD0->QD0_FILMAT,QD0->QD0_MAT))}) 
     			Endif					
				QD0->(DbSkip())
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Organiza a Matriz de Responsabilidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF LEN(aQd0Ord) > 0
				For nCt := 1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "E"
						aQd0Ord[nCt][1] := "1"
					ElseIf aQd0Ord[nCt][1] == "R"
						aQd0Ord[nCt][1] := "2"
					ElseIf aQd0Ord[nCt][1] == "A"
						aQd0Ord[nCt][1] := "3"
					ElseIf aQd0Ord[nCt][1] == "H"
						aQd0Ord[nCt][1] := "4"
					EndIf
				Next
				aQd0Ord := aSort( aQd0Ord, , , { |x,y| x[1] < y[1]} )
				For nCt :=1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "1"
						aQd0Ord[nCt][1] := "E"
					ElseIf aQd0Ord[nCt][1] == "2"
						aQd0Ord[nCt][1] := "R"
					ElseIf aQd0Ord[nCt][1] == "3"
						aQd0Ord[nCt][1] := "A"
					ElseIf aQd0Ord[nCt][1] == "4"
						aQd0Ord[nCt][1] := "H"
					EndIf
				Next					
			Endif	

        	For nCt:=1 To Len(aQd0Ord) 
				If aQd0Ord[nCt,1] == "E"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= CHR(13)+CHR(10)
						cMsg+= OemToAnsi(STR0117)+CHR(13)+CHR(10)+aQd0Ord[nCt,2]+CHR(13)+CHR(10) // "Elaboradores"
						cOldAut:= "E"
					Else
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10)
					EndIf
				ElseIf aQd0Ord[nCt,1] == "R"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= CHR(13)+CHR(10)
						cMsg+= OemToAnsi(STR0118)+CHR(13)+CHR(10)+aQd0Ord[nCt,2]+CHR(13)+CHR(10) // "Revisores"
						cOldAut:= "R"
					Else
						cMsg+=  aQd0Ord[nCt,2]+CHR(13)+CHR(10)
					EndIf
				ElseIf aQd0Ord[nCt,1] == "A"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= CHR(13)+CHR(10)
						cMsg+= OemToAnsi(STR0119)+CHR(13)+CHR(10)+aQd0Ord[nCt,2]+CHR(13)+CHR(10) // "Aprovadores"
						cOldAut:= "A"
					Else
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10)
					EndIf
				ElseIf aQd0Ord[nCt,1] == "H"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= CHR(13)+CHR(10)
						cMsg+= OemToAnsi(STR0204)+CHR(13)+CHR(10)+aQd0Ord[nCt,2]+CHR(13)+CHR(10)  //"Homologador"
						cOldAut:= "H"
					Else
						cMsg+= aQd0Ord[nCt,2]+CHR(13)+CHR(10)
					EndIf
				EndIf
			Next
			cMsg+= CHR(13)+CHR(10)
		EndIf
		
		If QA2->(DbSeek(xFilial("QA2")+"SAD     "+QDP->QDP_CHAVE))
			cRazSol:= QA_Rectxt(QDP->QDP_CHAVE,"SAD     ")
			cMsg+= Upper(OemToAnsi(STR0133))+CHR(13)+CHR(10) // "Razao da Solicitacao"
			cMsg+= cRazSol+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		EndIf
		
		If QDP->(DbSeek(xFilial("QDP")+cDocto+cRv+aDiv[1][1]))
			If QDP->QDP_PENDEN == "B"
				If QDP->QDP_SITSOL == "E"
					cStatSol:= OemToAnsi(STR0138)
				ElseIf QDP->QDP_SITSOL == "A"
					cStatSol:= OemToAnsi(STR0139)
				ElseIf QDP->QDP_SITSOL == "R"
					cStatSol:= OemToAnsi(STR0140)
				EndIf
				cMsg+= OemToAnsi(STR0134)+": "+Alltrim(QA_NUSR(aDiv[1][3],aDiv[1][4]))+"  -  " // "Responsavel pela Baixa"
				cMsg+= OemToAnsi(STR0135)+": "+aDiv[1][5]+CHR(13)+CHR(10) // "Data Baixa"
				cMsg+= OemToAnsi(STR0132)+": "+Alltrim(QA_NDEPT(aDiv[1][6]))+CHR(13)+CHR(10) // "Departamento"
				cMsg+= OemToAnsi(STR0136)+": "+cStatSol+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Status"
			EndIf
			If QDP->QDP_SITSOL == "R"
				cMsg+= Upper(OemToAnsi(STR0137))+CHR(13)+CHR(10)
				If QA2->(DbSeek(xFilial("QA2")+"QD052MOT"+QDP->QDP_CHAVE))
					cMotRepr:= QA_Rectxt(QDP->QDP_CHAVE,"QD052MOT")
					cMsg+= cMotRepr+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Motivo da Reprovacao"
				EndIf
			EndIf
		EndIf
		cMsg+= OemToAnsi(STR0083)+CHR(13)+CHR(10) //"Atenciosamente"
		cMsg+= Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10)
		cMsg+= Alltrim(QA_NDEPT(cMatDep))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg+= OemToAnsi(STR0084) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	EndIf
	
	aMsg	:=  { { cSubject,cMsg,cAttach } }
	cPEntr:= "S"
	
ElseIf cStatus == "TI" .or. cStatus == "TD" // Apenas para Agendamento de Treinamento - Inclusao / Delecao
	cSubject:= If(cStatus=="TI",OemToAnsi(STR0092),OemToAnsi(STR0095)) // "Aviso de Treinamento" ### "Aviso de Cancelamento de Treinamento   "
	If cTpMail == "1"
		cMsg:='<html><title>SIGAQDO</title><body>'
		cMsg+='<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+='  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
		cMsg+='  borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
		cMsg+='  <p align="center"><FONT face="Courier New" color="#ffffff" size="4">'
		cMsg+='  <b>'+OemToAnsi(STR0111)+'</b></font></p></td></tr><tr><td align="left" width="606" height="32">' // "MENSAGEM"
		If cStatus == "TI"
			cMsg+='  <p align="center">'+OemToAnsi(STR0093)+'</p></td></tr>' // Existe um agendamento de treinamento "
		Else
			cMsg+='  <p align="center">'+OemToAnsi(STR0094)+'</p></td></tr>' // "Foi cancelado o Treinamento do dia "
		EndIf
		cMsg+= '</table><br>'
		
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+= '  <tr><td align="left" width="480" height="32"><b>'+OemToAnsi(STR0113)+'</b><br>'+cDocto // "Documento"
		cMsg+= '  </td><td align="left" width="080" height="32"><b>'+OemToAnsi(STR0114)+'</b><br>'+cRv+'</td></tr>' // "Revisao"
		cMsg+= '  <tr><td align="left" width="480" height="32"><b>'+OemToAnsi(STR0115)+'</b><br>'+QDXFNANTPD(cTpDocto) // "Tipo de Documento"
		cMsg+= '  </td><td align="left" width="080" height="32"><b>'+OemToAnsi(STR0116)+'</b><br>'+DToC(dDtVig) // "Dt Vigencia"
		cMsg+= '  </td></tr><tr><td colspan="4" align="left" width="480" height="32"><b>'+OemToAnsi(STR0124)+'</b><br>'+cTitulo+'</td></tr>' // "Titulo"
		cMsg+= '</table>'
		If QD0->(DbSeek(xFilial("QD0")+cDocto+cRv))
			cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1><tr>'
			aQd0Ord:={}
			While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == xFilial("QD0")+cDocto+cRv
			    IF QD0->QD0_FLAG <> 'I'
					AADD(aQd0Ord,{QD0->QD0_AUT,Alltrim(QA_NUSR(QD0->QD0_FILMAT,QD0->QD0_MAT))}) 
     			Endif								
				QD0->(DbSkip())
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Organiza a Matriz de Responsabilidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF LEN(aQd0Ord) > 0
				For nCt := 1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "E"
						aQd0Ord[nCt][1] := "1"
					ElseIf aQd0Ord[nCt][1] == "R"
						aQd0Ord[nCt][1] := "2"
					ElseIf aQd0Ord[nCt][1] == "A"
						aQd0Ord[nCt][1] := "3"
					ElseIf aQd0Ord[nCt][1] == "H"
						aQd0Ord[nCt][1] := "4"
					EndIf
				Next
				aQd0Ord := aSort( aQd0Ord, , , { |x,y| x[1] < y[1]} )
				For nCt :=1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "1"
						aQd0Ord[nCt][1] := "E"
					ElseIf aQd0Ord[nCt][1] == "2"
						aQd0Ord[nCt][1] := "R"
					ElseIf aQd0Ord[nCt][1] == "3"
						aQd0Ord[nCt][1] := "A"
					ElseIf aQd0Ord[nCt][1] == "4"
						aQd0Ord[nCt][1] := "H"
					EndIf
				Next					
			Endif	

        	For nCt:=1 To Len(aQd0Ord) 
				If aQd0Ord[nCt,1] == "E"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>' +OemToAnsi(STR0117)+'</b><br>'+aQd0Ord[nCt,2] // "Elaboradores"
						cOldAut:= "E"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "R"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>'+OemToAnsi(STR0118)+'</b><br>'+aQd0Ord[nCt,2] // "Revisores"
						cOldAut:= "R"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "A"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>'+OemToAnsi(STR0119)+'</b><br>'+aQd0Ord[nCt,2] // "Aprovadores"
						cOldAut:= "A"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "H"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>'+OemToAnsi(STR0204)+'</b><br>'+aQd0Ord[nCt,2]   //"Homologador"
						cOldAut:= "H"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf					
				EndIf                   
			Next
			cMsg+= '</tr></table><br>'
		EndIf
		
		cMsg+='<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+='  <tr><td colspan="6" borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
		cMsg+='    borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
		cMsg+='    <p align="center"><FONT face="Courier New" color="#ffffff" size="4"><b>'+Upper(OemToAnsi(STR0141))+'</b></td></tr>' // "TREINAMENTO"
		cMsg+='  <tr><td align="left" width="16%"><b>'+OemToAnsi(STR0141)+'</b><br>'+aDiv[1][7]+'</td>' // "Treinamento"
		cMsg+='    <td align="left" width="16%" height="32"><b>'+OemToAnsi(STR0142)+'</b><br>'+aDiv[1][8]+'</td>' // "Ano"
		cMsg+='    <td align="left" width="16%" height="32"><b>'+OemToAnsi(STR0096)+'</b><br>'+aDiv[1][1]+'</td>' // "Dt Inicio"
		cMsg+='    <td align="left" width="16%" height="32"><b>'+OemToAnsi(STR0097)+'</b><br>'+aDiv[1][2]+'</td>' // "Dt Fim"
		cMsg+='    <td align="left" width="16%" height="32"><b>'+OemToAnsi(STR0098)+'</b><br>'+Transform(aDiv[1][5],"@R 99:99")+'</td>' // "Hora Inicio"
		cMsg+='    <td align="left" width="16%" height="32"><b>'+OemToAnsi(STR0099)+'</b><br>'+Transform(aDiv[1][6],"@R 99:99")+'</td></tr>' // "Hora Fim"
		cMsg+='  <tr><td colspan="6" align="left" width="100%" height="32"><b>'+OemToAnsi(STR0100)+'</b><br>'+aDiv[1][3]+'</td></tr>' // "Local"
		If !Empty(aDiv[1][4])
			cMsg+='  <tr><td colspan="6" align="left" width="100%" height="32"><b>'+OemToAnsi(STR0101)+'</b><br>'+aDiv[1][4]+'</td></tr>' // "Observacoes"
		EndIf
		cMsg+='</table>'
		
		If !Empty(aDiv[1][10]) .Or. !Empty(aDiv[1][12]) .Or. !Empty(aDiv[1][14])
			cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
			cMsg+=' <tr>'
			If !Empty(aDiv[1][10])
				cMsg+='  <td align="left" width="33%" height="32"><b>'+OemToAnsi(STR0143)+'</b><br>'+Alltrim(QA_NUSR(aDiv[1][9],aDiv[1][10]))+'</td>' // "Instrutor"
			EndIf
			If !Empty(aDiv[1][12])
				cMsg+='  <td align="left" width="33%" height="32"><b>'+OemToAnsi(STR0143)+'</b><br>'+Alltrim(QA_NUSR(aDiv[1][11],aDiv[1][12]))+'</td>' // "Instrutor"
			EndIf
			If !Empty(aDiv[1][14])
				cMsg+='  <td align="left" width="33%" height="32"><b>'+OemToAnsi(STR0143)+'</b><br>'+Alltrim(QA_NUSR(aDiv[1][13],aDiv[1][14]))+'</td>' // "Instrutor"
			EndIf
			cMsg+=' </tr>'
			cMsg+='</table>'
		EndIf
		
		If !Empty(MSMM(aDiv[1][15]))
			cMsg+='<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
			cMsg+='  <tr><td colspan="6" bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606" '
			cMsg+='    bgcolor="#0099cc" bordercolordark="#0099cc" height="1">'
			cMsg+='    <p align="center"><font face="courier new" color="#ffffff" size="4">'
			cMsg+='    <b>'+OemToAnsi(STR0144)+'</b></font></p></td></tr>' // "Texto da Convocacao"
			cMsg+='  <tr><td align="left" width="100%" height="32">'+MSMM(aDiv[1][15])+'</td></tr>'
			cMsg+='</table>'
		EndIf
		cMsg+= '  <br><p><font size="2"><em>'+OemToAnsi(STR0084)+'</em></font></p></body></html>' // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	Else
		If cStatus == "TI"
			cMsg:= OemToAnsi(STR0093)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Existe um agendamento de treinamento "
		Else
			cMsg:= OemToAnsi(STR0094)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Foi cancelado o Treinamento do dia "
		EndIf
		cMsg+= OemToAnsi(STR0113)+": "+cDocto+"  -  " // "Documento"
		cMsg+= OemToAnsi(STR0114)+": "+cRv+CHR(13)+CHR(10) // "Revisao"
		cMsg+= OemToAnsi(STR0115)+": "+QDXFNANTPD(cTpDocto)+"  -  " // "Tipo de Documento"
		cMsg+= OemToAnsi(STR0116)+": "+DToC(dDtVig)+CHR(13)+CHR(10) // "Dt Vigencia"
		cMsg+= OemToAnsi(STR0124)+": "+cTitulo+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Titulo"
		
		cMsg+= OemToAnsi(STR0141)+": "+aDiv[1][7]+"  -  " // "Treinamento"
		cMsg+= OemToAnsi(STR0142)+": "+aDiv[1][8]+CHR(13)+CHR(10) // "Ano"
		cMsg+= OemToAnsi(STR0096)+": "+aDiv[1][1]+"  -  " // "Dt Inicio"
		cMsg+= OemToAnsi(STR0097)+": "+aDiv[1][2]+"  -  " // "Dt Fim"
		cMsg+= OemToAnsi(STR0098)+": "+Transform(aDiv[1][5],"@R 99:99")+" -  " // "Hora Inicio"
		cMsg+= OemToAnsi(STR0099)+": "+Transform(aDiv[1][6],"@R 99:99")+CHR(13)+CHR(10) // "Hora Fim"
		cMsg+= OemToAnsi(STR0100)+": "+aDiv[1][3]+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Local"
		If !Empty(aDiv[1][4])
			cMsg+= OemToAnsi(STR0101)+": "+aDiv[1][4]+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Observacoes"
		EndIf
		
		If !Empty(aDiv[1][10]) .Or. !Empty(aDiv[1][12]) .Or. !Empty(aDiv[1][14])
			If !Empty(aDiv[1][10])
				cMsg+= OemToAnsi(STR0143)+": "+Alltrim(QA_NUSR(aDiv[1][9],aDiv[1][10]))+CHR(13)+CHR(10) // "Instrutor"
			EndIf
			If !Empty(aDiv[1][12])
				cMsg+= OemToAnsi(STR0143)+": "+Alltrim(QA_NUSR(aDiv[1][11],aDiv[1][12]))+CHR(13)+CHR(10) // "Instrutor"
			EndIf
			If !Empty(aDiv[1][14])
				cMsg+= OemToAnsi(STR0143)+": "+Alltrim(QA_NUSR(aDiv[1][13],aDiv[1][14]))+CHR(13)+CHR(10) // "Instrutor"
			EndIf
			cMsg+= CHR(13)+CHR(10)
		EndIf
		
		If !Empty(MSMM(aDiv[1][15]))
			cMsg+= Upper(OemToAnsi(STR0144))+CHR(13)+CHR(10) // "Texto da Convocacao"
			cMsg+= MSMM(aDiv[1][15])+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		EndIf		
		cMsg+= OemToAnsi(STR0084) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	EndIf
	
	aMsg	:=  { { cSubject,cMsg,cAttach } }
	cPEntr:= "T" // ponto de Entrada de Treinamento
	
Elseif cStatus == "REF"
	cSubject:= Trim(cDocto)+"-"+Trim(cRv)+"-"+Trim(cTitulo)+" - "+DTOC(dDataBase)+" - "+cHora
	If cTpMail == "1"
		cMsg:= '<html><title>SIGAQDO</title><body>'
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+= '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
		cMsg+= '  borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
		cMsg+= '  <p align="center"><FONT face="Courier New" color="#ffffff" size="4">'
		cMsg+= '  <b>'+OemToAnsi(STR0111)+'</b></font></p></td></tr><tr><td align="left" width="606" height="32">' // "MENSAGEM"
		cMsg+= '  <p align="center">'+OemToAnsi(STR0112)+'</p></td></tr>' // "Favor Gerar Revisao do Documento que consta na Referencia"
		cMsg+= '</table><br>'
		
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+= '  <tr><td align="left" width="480" height="32"><b>'+OemToAnsi(STR0113)+'</b><br>'+cDocto // "Documento"
		cMsg+= '  </td><td align="left" width="080" height="32"><b>'+OemToAnsi(STR0114)+'</b><br>'+cRv+'</td></tr>' // "Revisao"
		cMsg+= '  <tr><td align="left" width="480" height="32"><b>'+OemToAnsi(STR0115)+'</b><br>'+QDXFNANTPD(cTpDocto) // "Tipo de Documento"
		cMsg+= '  </td><td align="left" width="080" height="32"><b>'+OemToAnsi(STR0116)+'</b><br>'+DToC(dDtVig) // "Dt Vigencia"
		cMsg+= '  </td></tr><tr><td colspan="4" align="left" width="480" height="32"><b>'+OemToAnsi(STR0124)+'</b><br>'+cTitulo+'</td></tr>' // "Titulo"
		cMsg+= '</table>'
		If QD0->(DbSeek(xFilial("QD0")+cDocto+cRv))
			cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1><tr>'
			aQd0Ord:={}
			While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == xFilial("QD0")+cDocto+cRv
			    IF QD0->QD0_FLAG <> 'I'
					AADD(aQd0Ord,{QD0->QD0_AUT,Alltrim(QA_NUSR(QD0->QD0_FILMAT,QD0->QD0_MAT))}) 
     			Endif											
				QD0->(DbSkip())
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Organiza a Matriz de Responsabilidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF LEN(aQd0Ord) > 0
				For nCt := 1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "E"
						aQd0Ord[nCt][1] := "1"
					ElseIf aQd0Ord[nCt][1] == "R"
						aQd0Ord[nCt][1] := "2"
					ElseIf aQd0Ord[nCt][1] == "A"
						aQd0Ord[nCt][1] := "3"
					ElseIf aQd0Ord[nCt][1] == "H"
						aQd0Ord[nCt][1] := "4"
					EndIf
				Next
				aQd0Ord := aSort( aQd0Ord, , , { |x,y| x[1] < y[1]} )
				For nCt :=1 to Len( aQd0Ord )
					If aQd0Ord[nCt][1] == "1"
						aQd0Ord[nCt][1] := "E"
					ElseIf aQd0Ord[nCt][1] == "2"
						aQd0Ord[nCt][1] := "R"
					ElseIf aQd0Ord[nCt][1] == "3"
						aQd0Ord[nCt][1] := "A"
					ElseIf aQd0Ord[nCt][1] == "4"
						aQd0Ord[nCt][1] := "H"
					EndIf
				Next					
			Endif	

        	For nCt:=1 To Len(aQd0Ord) 
				If aQd0Ord[nCt,1] == "E"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>' +OemToAnsi(STR0117)+'</b><br>'+aQd0Ord[nCt,2] // "Elaboradores"
						cOldAut:= "E"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "R"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>'+OemToAnsi(STR0118)+'</b><br>'+aQd0Ord[nCt,2] // "Revisores"
						cOldAut:= "R"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "A"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>'+OemToAnsi(STR0119)+'</b><br>'+aQd0Ord[nCt,2] // "Aprovadores"
						cOldAut:= "A"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf
				ElseIf aQd0Ord[nCt,1] == "H"
					If cOldAut <> aQd0Ord[nCt,1]
						cMsg+= '<td valign="top" width="480" height="32"><b>'+OemToAnsi(STR0204)+'</b><br>'+aQd0Ord[nCt,2]  //"Homologador"
						cOldAut:= "H"
					Else
						cMsg+= '<br>'+aQd0Ord[nCt,2]
					EndIf					
				EndIf         
			Next
			cMsg+= '</tr></table><br>'
		EndIf
		
		cMsg+= '<br>'
		cMsg+= OemToAnsi(STR0083)+'<br>'+Alltrim(QA_NUSR(cMatFil,cMatCod)) //"Atenciosamente"
		cMsg+= '  <br>'+Alltrim(QA_NDEPT(cMatDep))
		cMsg+= '  <br><p><font size="2"><em>'+OemToAnsi(STR0084)+'</em></font></p></body></html>' // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	Else
		cMsg+= OemToAnsi(STR0112)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Favor Gerar Revisao do Documento que consta na Referencia"
		cMsg+= OemToAnsi(STR0113)+": "+cDocto+"  -  " // "Documento"
		cMsg+= OemToAnsi(STR0114)+": "+cRv+CHR(13)+CHR(10) // "Revisao"
		cMsg+= OemToAnsi(STR0115)+": "+QDXFNANTPD(cTpDocto) // "Tipo de Documento"
		cMsg+= OemToAnsi(STR0116)+": "+DToC(dDtVig)+CHR(13)+CHR(10) // "Dt Vigencia"
		cMsg+= OemToAnsi(STR0124)+": "+cTitulo+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Titulo"
		
		cMsg+= OemToAnsi(STR0083)+CHR(13)+CHR(10)//"Atenciosamente"
		cMsg+= Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10)
		cMsg+= Alltrim(QA_NDEPT(cMatDep))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg+= OemToAnsi(STR0084) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	EndIf
	aMsg:= { { cSubject,cMsg,cAttach } }
	cPEntr   := "F" // Referencias

ElseIf cStatus == "TMP"
	cSubject:= Trim(aDiv[1][1])+" / "+Trim(aDiv[1][2])+" - "+DTOC(dDataBase)+" - "+cHora
	If cTpMail == "1"
		cMsg:= '<html><title>SIGAQDO</title><body>'
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+= '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
		cMsg+= '  borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
		cMsg+= '  <p align="center"><FONT face="Courier New" color="#ffffff" size="4">'
		cMsg+= '  <b>'+OemToAnsi(STR0111)+'</b></font></p></td></tr><tr><td align="left" width="606" height="32">' // "MENSAGEM"
		cMsg+= '  <p align="center">'+OemToAnsi(STR0147)+'</p></td></tr>' // "Usuario Ausente Temporariamente indicou-o como substituto para baixa de pendencias."
		cMsg+= '</table><br>'
		
		cMsg+= '<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
		cMsg+= '  <tr><td bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606" bgcolor="#0099cc" bordercolordark="#0099cc" colspan="4" height="1">'
        cMsg+= '    <p align=center><font face="courier new" color="#ffffff" size="4"><b>'+OemToAnsi(STR0148)+'</b></font></p></td></tr>' // "AUSENCIA TEMPORARIA"
		cMsg+= '  <tr><td align="left" width="25%"><strong>'+OemToAnsi(STR0150)+'</strong><br>'+aDiv[1,1]+'</td>' // "Ano"
		cMsg+= '      <td align="left" width="25%" height="32"><b>'+OemToAnsi(STR0149)+'</b><br>'+aDiv[1,2]+'</td>' // "Ausencia"
		cMsg+= '      <td align="left" width="25%" height="32"><b>'+OemToAnsi(STR0151)+'</b><br>'+aDiv[1,3]+'</td>' // "Dt Inicio"
		cMsg+= '      <td align="left" width="25%" height="32"><b>'+OemToAnsi(STR0152)+'</b><br>'+aDiv[1,4]+'</td>' // "Dt Prevista Fim"
		cMsg+= '  <tr><td align="left" width="50%" colspan="2" height="32"><b>'+OemToAnsi(STR0153)+'</b><br>'+Alltrim(QA_NUSR(cFilMat,cCodMat))+'</td>' // "Usuario Ausente"
		cMsg+= '      <td align="left" width="50%" colspan="2" height="32"><b>'+OemToAnsi(STR0132)+'</b><br>'+Alltrim(QA_NDEPT(aDiv[1,6]))+'</td>' // "Departamento"
		cMsg+= '  <tr><td align="left" width="100%" colspan="4" height="32"><b>'+OemToAnsi(STR0154)+'</b><br>'+aDiv[1,5]+'</td></tr></table><br>' // "Motivo"
		
		If len(aMail) > 0
          //Corpo das pendencias
		  cMsg+= '<table bordercolor="#0099cc" height="29" cellspacing="1" width="645" bordercolorlight="#0099cc" border=1>'
		  cMsg+= '  <tr><td bordercolor="#0099cc" bordercolorlight="#0099cc" align="left" width="606" bgcolor="#0099cc" bordercolordark="#0099cc" colspan="4" height="1">'
          cMsg+= '    <p align=center><font face="courier new" color="#ffffff" size="4"><b>'+OemToAnsi(STR0206)+'</b></font></p></td></tr>' //"LISTA DE  DOCUMENTO(S)"
		  cMsg+= '  <tr><td align="left" width="35%"><strong>'+OemToAnsi(STR0113)+'</td>' //DOCUMENTO
		  cMsg+= '      <td align="left" width="25%" height="32"><b>'+OemToAnsi(STR0114)+'</td>'//REVISAO  
		  cMsg+= '      <td align="left" width="25%" height="32"><b>'+OemToAnsi(STR0205)+'</td>'//TIPO     	

		  For nCt:=1 To Len(aMail)  
			cMsg+= '<tr><td align="left" width="35%" height="32">'+'<br>'+aMail[nCt,1]+'</td>' // "Doc"
			cMsg+= '    <td align="left" width="25%" height="32">'+'<br>'+aMail[nCt,2]+'</td>' // "Revisao"
			cMsg+= '    <td align="left" width="25%" height="32">'+'<br>'+aMail[nCt,3]+'</td>' // "Tipo de pendencia"
		  Next		   	
        Endif

		cMsg+= '</tr></table><br>' //fechando a tabela
		cMsg+= '<br>'
		cMsg+= '  <br><p><font size="2"><em>'+OemToAnsi(STR0084)+'</em></font></p></body></html>' // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	Else
		cMsg+= OemToAnsi(STR0147)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Usuario Ausente Temporariamente indicou-o como substituto para baixa de pendencias."
		cMsg+= OemToAnsi(STR0150)+": "+aDiv[1,1]+" - "+OemToAnsi(STR0149)+": "+aDiv[1,2]+CHR(13)+CHR(10) // "Ano" ### "Ausencia"
		cMsg+= OemToAnsi(STR0151)+": "+aDiv[1,3]+CHR(13)+CHR(10) // "Dt Inicio"
		cMsg+= OemToAnsi(STR0152)+": "+aDiv[1,4]+CHR(13)+CHR(10) // "Dt Prevista Fim"		
		cMsg+= OemToAnsi(STR0153)+": "+Alltrim(QA_NUSR(cFilMat,cCodMat))+CHR(13)+CHR(10) // "Usuario Ausente"
		cMsg+= OemToAnsi(STR0132)+": "+Alltrim(QA_NDEPT(aDiv[1,6]))+CHR(13)+CHR(10) // "Departamento"
		cMsg+= OemToAnsi(STR0154)+": "+aDiv[1,5]+CHR(13)+CHR(10) // "Motivo"
		
		If len(aMail) > 0
		  cMsg+= OemToAnsi(STR0206)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "LISTA DE  DOCUMENTO(S)"		  
		  For nCt:=1 To Len(aMail)  
			cMsg+= CHR(13)+CHR(10) 
			cMsg+= OemToAnsi(STR0113)+": "+aMail[1,1]+CHR(13)+CHR(10) // "Documento"
			cMsg+= OemToAnsi(STR0114)+": "+aMail[1,2]+CHR(13)+CHR(10) // "Revisao"		
			cMsg+= OemToAnsi(STR0205)+": "+aMail[1,3]+CHR(13)+CHR(10) // "Tipo Pend."
		  Next		   	
		  cMsg+= CHR(13)+CHR(10)+CHR(13)+CHR(10) 		
        Endif

		cMsg+= OemToAnsi(STR0084) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"		
	EndIf

	aMsg:= { { cSubject,cMsg,cAttach } }
	cPEntr:= "A" // Ausencia Temporaria

ElseIf cStatus == "TRF"
	cSubject:= OemToAnsi(STR0172)+" - "+DTOC(dDataBase)+" - "+cHora
	If cTpMail == "1"
		cMsg:= '<html><title>SIGAQDO</title><body>'
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+= '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
		cMsg+= '  borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
		cMsg+= '  <p align="center"><FONT face="Courier New" color="#ffffff" size="4">'
		cMsg+= '  <b>'+OemToAnsi(STR0111)+'</b></font></p></td></tr><tr><td align="left" width="606" height="32">' // "MENSAGEM"
		cMsg+= '  <p align="center">'+OemToAnsi(STR0170)+OemToAnsi(STR0171)+'</p></td></tr>' //"Podem existir pendências de transferência de documento. Favor baixar rapidamente e/ou consultar o relatório de transferências. "
		cMsg+= '</table><br>'
					
		cMsg+= '<br>'
		cMsg+= OemToAnsi(STR0083)+'<br>'+Alltrim(QA_NUSR(cMatFil,cMatCod)) //"Atenciosamente"
		cMsg+= '  <br>'+Alltrim(QA_NDEPT(cMatDep))
		cMsg+= '  <br><p><font size="2"><em>'+OemToAnsi(STR0084)+'</em></font></p></body></html>' // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	Else
		cMsg+= OemToAnsi(STR0170)+CHR(13)+CHR(10)  //"Podem existir pendências de transferência de documento. Favor baixar rapidamente e/ou "
		cMsg+= OemToAnsi(STR0171)+CHR(13)+CHR(10)+CHR(13)+CHR(10)  
		
		cMsg+= OemToAnsi(STR0083)+CHR(13)+CHR(10)//"Atenciosamente"
		cMsg+= Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10)
		cMsg+= Alltrim(QA_NDEPT(cMatDep))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg+= OemToAnsi(STR0084) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"		
	EndIf
	aMsg:= { { cSubject,cMsg,cAttach } }
	cPEntr:= "B" // Tranferencia
Elseif cStatus == "VEN"
	cSubject:= Trim(cDocto)+"-"+Trim(cRv)+"-"+Trim(cTitulo)+" - "+DTOC(dDataBase)+" - "+cHora
	If cTpMail == "1"
		cMsg:= '<html><title>SIGAQDO</title><body>'
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+= '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
		cMsg+= '  borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
		cMsg+= '  <p align="center"><FONT face="Courier New" color="#ffffff" size="4">'
		cMsg+= '  <b>'+OemToAnsi(STR0111)+'</b></font></p></td></tr><tr><td align="left" width="606" height="32">' // "MENSAGEM"
		cMsg+= '  <p align="center">'+OemToAnsi(STR0183)+'</p></td></tr>'  //"Documento Vencido/à Vencer"
		cMsg+= '</table><br>'		
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMsg+= '  <tr><td align="left" width="480" height="32"><b>'+OemToAnsi(STR0113)+'</b><br>'+cDocto // "Documento"
		cMsg+= '  </td><td align="left" width="080" height="32"><b>'+OemToAnsi(STR0114)+'</b><br>'+cRv+'</td></tr>' // "Revisao"
		cMsg+= '  <tr><td align="left" width="480" height="32"><b>'+OemToAnsi(STR0115)+'</b><br>'+Posicione("QD2",1,cTpDocto,"QD2_DESCTP") // "Tipo de Documento"
		cMsg+= '  </td><td align="left" width="080" height="32"><b>'+OemToAnsi(TitSx3("QDH_DTLIM")[1])+'</b><br>'+DToC(dDtVig) //Validade
		cMsg+= '  </td></tr><tr><td colspan="4" align="left" width="480" height="32"><b>'+OemToAnsi(STR0124)+'</b><br>'+cTitulo+'</td></tr>' // "Titulo"
		cMsg+= '</table>'		
		cMsg+= '<br>'
		cMsg+= '  <br><p><font size="2"><em>'+OemToAnsi(STR0084)+'</em></font></p></body></html>' // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	Else
		cMsg+= OemToAnsi(STR0183)+CHR(13)+CHR(10)+CHR(13)+CHR(10)   //"Documento Vencido/à Vencer"
		cMsg+= OemToAnsi(STR0113)+": "+cDocto+"  -  " // "Documento"
		cMsg+= OemToAnsi(STR0114)+": "+cRv+CHR(13)+CHR(10) // "Revisao"
		cMsg+= OemToAnsi(STR0115)+": "+Posicione("QD2",1,cTpDocto,"QD2_DESCTP") // "Tipo de Documento"
		cMsg+= OemToAnsi(TitSx3("QDH_DTLIM")[1])+": "+DToC(dDtVig)+CHR(13)+CHR(10) // "Validade"
		cMsg+= OemToAnsi(STR0124)+": "+cTitulo+CHR(13)+CHR(10)+CHR(13)+CHR(10) // "Titulo"		
		cMsg+= OemToAnsi(STR0084) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO - Controle de Documentos"
	EndIf
	aMsg:= { { cSubject,cMsg,cAttach } }
	cPEntr   := "V" // VENCIDOS

EndIf

If lTroFil
	cFilAnt := cSvFilAnt 
	lTroFil := .F.
EndIf
// ponto de entrada - permite a alteracao do conteudo aMsg
If ExistBlock( "QDO"+cPEntr+"MAIL" )
	aMsg := ExecBlock( "QDO"+cPEntr+"MAIL", .f., .f., {aMsg} )
Endif
aadd(aUsrMail,{ AllTrim(cApelido),Trim(cMail),aMsg })

QAA->(DbSetOrder(nQAAOrd))
QAA->(DbGoTo(nQAARecno))
QD0->(DbSetOrder(nOrdQD0))
QD0->(DbGoto(nPosQD0))
QDB->(DbSetOrder(nOrdQDB))
QDB->(DbGoto(nPosQDB))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDOPATH  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 03/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna um array com dados dos Paths utilizados no sistema ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOPATH()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOPATH()

Local cQPath    := QA_TRABAR(Alltrim( GetMV( "MV_QPATHW"  )))
Local cQPathD   := QA_TRABAR(Alltrim( GetMV( "MV_QPATHWD" )))
Local cQPathHtm := QA_TRABAR(Alltrim( GetMV( "MV_QPATHWH" )))
Local cQPathTrm := Alltrim( GetMV( "MV_QPATHWT" ))
Local cTextoD   := Alltrim( GetMV( "MV_QDDOTPD" ))
Local cPathView := Alltrim( GetMv( "MV_QDPVIEW" ))
Local cUsaView  := AllTrim( GetMv( "MV_QDVIEW"  ))
Local cQPathDir 
Local cBarRmt	:=IIF(GetRemoteType() == 2	,"/","\")   //Checa se o Remote e Linux    
Local cBarSrv	:=IIF(ISSRVUNIX()			,"/","\")   //Checa se o Server e Linux    
Local nRmtType	:= GETREMOTETYPE()

cQPathDir:= "protheus_tmp"+cBarRmt

If UPPER(cQPathTrm) == "GETTEMPPATH()"
    If  nRmtType == 1 .OR. nRmtType == 5
		cQPathTrm := &(cQPathTrm)
	Else
		cQPathTrm := "L:/tmp"
	EndIf

	If Right( cQPathTrm, 1 ) # cBarRmt
	   cQPathTrm  += cBarRmt
	Endif                      
		
	cQPathTrm := cQPathTrm+cQPathDir
	MakeDir(cQPathTrm)
Else
	If Right( cQPathTrm, 1 ) # cBarRmt
   		cQPathTrm  += cBarRmt
	Endif             
Endif

If Right( cQPath,  1 ) # cBarSrv
   cQPath  += cBarSrv
Endif
If Right( cQPathD, 1 ) # cBarSrv
   cQPathD += cBarSrv
Endif
If Right( cQPathHtm, 1 ) # cBarSrv
   cQPathHtm  += cBarSrv
Endif    
If cUsaView == "S"
	If Right( cPathView, 1 ) # cBarRmt
	   cPathView  += cBarRmt
	Endif
Endif	

aPatchs := {cQPath,cQPathD,cQPathTrm,cTextoD,cQPathHtm,cPathView,cUsaView,cQPathDir}

If ExistBlock("QDOPATHD")
	aPatchs := ExecBlock("QDOPATHD",.F.,.F.,{aPatchs})
Endif

Return aPatchs

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDOWord    ³ Autor ³ Eduardo de Souza ³ Data ³ 06/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Verifica se usuario possui Word                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDOWord()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ Generico                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOWord()

Local oWord
Local cEditor:= "TMsOleWord97"
Local cRet   := "0"

CursorWait()
oWord := OLE_CreateLink(cEditor)

If oWord <> "-1"
	cRet:= "1" // Exite Word
Else
	cRet:= "2" // Nao existe Word
EndIf

oWord := OLE_CloseLink(oWord)
CursorArrow()

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDXGvAviso ³ Autor ³ Eduardo de Souza ³ Data ³ 22/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Grava Aviso                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDXGvAviso(ExpC1,ExpC2,ExpX3,ExpX4,ExpC5,ExpC6,ExpC7)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpC1 - Tipo de Aviso                                   ³±±
±±³             ³ ExpC2 - Filial do Usuario                               ³±±
±±³             ³ ExpC3 - Matricula do Usuario                            ³±±
±±³             ³ ExpC4 - Departamento do Usuario                         ³±±
±±³             ³ ExpC5 - Documento                                       ³±±
±±³             ³ ExpC6 - Revisao do Documento                            ³±±
±±³             ³ ExpC7 - Chave de Ligacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ SIGAQDO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXGvAviso(cTpPend,cFilUsr,cMatUsr,cDepUsr,cDocto,cRv,cChave,cFilDoc,cDocRef,cRvRef)

Local aArea	 := GetArea()
Local nOrdQAA:= QAA->(IndexOrd())
Local nPosQAA:= QAA->(Recno())
Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]
Local cMatDep:= aUsrMat[4]
Local dHoraGe:= SubStr(Time(),1,5)
Local cGerAvi:=IF(GETMV("MV_QDOGEAV",.F.,"1")=="1",.T.,.F.)                                  
Local cFilAvi
Local cQuery := ""
Default cFilDoc:= xFilial("QDS")

cFilAvi:=IF(FWModeAccess("QDS") == "C",xFilial("QDS"),cFilDoc)

//Ponto de Entrada para trocar ou nao a data utilizada.   dDataBase ou Date()                           
If ExistBlock("QDODATAV")                                    
	dDataUsar := ExecBlock("QDODATAV",.F.,.F.)
Else
	dDataUsar := dDataBase
Endif

cQuery := " SELECT * FROM " + RetSqlName("QDS")+" QDS "
cQuery += " WHERE QDS.QDS_FILIAL = '"+cFilAvi+"'"
If cDocto <> NIL
	cQuery += " AND QDS.QDS_DOCTO = '"+cDocto+"'"
	cQuery += " AND QDS.QDS_RV = '"+cRv+"'"
Endif
cQuery += " AND QDS.QDS_TPPEND = '"+cTpPend+"'"
cQuery += " AND QDS.QDS_FILMAT = '"+cFilUsr+"'"
cQuery += " AND QDS.QDS_MAT = '"+cMatUsr+"'"
cQuery += " AND QDS.QDS_DEPTO = '"+cDepUsr+"'"
cQuery += " AND QDS.QDS_DTGERA = '"+DtoS(dDataUsar)+"'"
//cQuery += " AND QDS.QDS_HRGERA = '"+dHoraGe+"'"
If cChave <> Nil
	cQuery += " AND QDS.QDS_CHAVE = '"+cChave+"'"
Endif

cQuery := ChangeQuery(cQuery)
			
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QDSTRB",.T.,.T.)

IF QDSTRB->(Eof()) .And. cGerAvi 
		RecLock("QDS",.T.)
		QDS->QDS_FILIAL:= cFilAvi
		QDS->QDS_DTGERA:= dDataUsar
		QDS->QDS_HRGERA:= dHoraGe
		QDS->QDS_TPPEND:= cTpPend
		QDS->QDS_PENDEN:= "P"              
		QDS->QDS_FILMAT:= cFilUsr
		QDS->QDS_MAT   := cMatUsr
		QDS->QDS_DEPTO := cDepUsr
		QDS->QDS_FMATBX:= cMatFil
		QDS->QDS_MATBX := cMatCod
		QDS->QDS_DEPBX := cMatDep
		If cDocto <> NIL
			QDS->QDS_DOCTO:= cDocto
			QDS->QDS_RV   := cRv
		EndIf
		If cChave <> Nil
			QDS->QDS_CHAVE:= cChave
		EndIf 
		IF cDocRef<>Nil .AND. cRvRef<>Nil                 	
			QDS->QDS_DOCREF:= cDocRef
			QDS->QDS_RVREF := cRvRef
		Endif		
		QDS->(MsUnlock())
		FKCOMMIT()
ENDIF

QDSTRB->(DBCLOSEAREA())
QAA->(DbSetOrder(nOrdQAA))
QAA->(DbGoto(nPosQAA))
restarea (aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDUltRvDoc ³ Autor ³ Eduardo de Souza    ³ Data ³ 04/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna a Ultima Revisao Vigente do Documento              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDUltRvDoc(ExpC1,ExpC2)    				                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Documento                                          ³±±
±±³          ³ ExpC2 - Revisao do Documento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDUltRvDoc(cDocto,lGatilho)
Local cRv		:= ""  
Local cIndQDH	:= QDH->(IndexOrd())
DEFAULT lGatilho:= .T.

If Type("INCLUI") == "U"
	Private Inclui := .F.
Endif                     

If !Inclui .Or. lGatilho
    QDH->(DbSetOrder(6)) //Revisao invertida
	If QDH->(DbSeek(xFilial("QDH")+cDocto))
		While QDH->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO == xFilial("QDH")+cDocto
			If QDH->QDH_STATUS == "L  "
				cRv:= QDH->QDH_RV
				Exit
			EndIf
			QDH->(DbSkip())
		EndDo
	EndIf 
	QDH->(DbSetOrder(cIndQDH))
EndIf

Return(cRv)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao   ³ QDFilDtLim³ Autor ³ Eduardo de Souza     ³ Data ³ 25/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao³ Filtra Data Limite para geracao das Validades              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ QDFilDtLim()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDFilDtLim(nDias,dDataUsar)

Local cQuery := ""
Local cIndex := CriaTrab(Nil,.F.)
Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]
Local cMatDep:= aUsrMat[4]

cQuery:= "SELECT QDH.QDH_FILIAL,QDH.QDH_DOCTO,QDH.QDH_RV,QDH.QDH_STATUS,"
cQuery+= "QDH.QDH_DTLIM,QDH.QDH_OBSOL,QDH.QDH_CANCEL,QDH.R_E_C_N_O_ RECNO,QD0.QD0_FILIAL,QD0.QD0_DOCTO,QD0.QD0_RV,"
cQuery+= "QD0.QD0_AUT,QD0.QD0_FILMAT,QD0.QD0_MAT,QD0.QD0_DEPTO"
cQuery+= " FROM " + RetSqlName("QDH")+" QDH, "
cQuery+= RetSqlName("QD0")+" QD0 "
cQuery+= "WHERE QDH.QDH_STATUS = 'L  ' AND QDH.QDH_DTLIM <> '        ' AND "
cQuery+= "QDH.QDH_OBSOL <> 'S' AND QDH.QDH_CANCEL <> 'S' AND QDH.D_E_L_E_T_ <> '*' AND "
cQuery+= "('"+DTOS(dDataUsar+nDias)+"' >= QDH.QDH_DTLIM OR QDH.QDH_DTLIM < '"+DTOS(dDataUsar)+"') AND "
cQuery+= "QD0.QD0_FILIAL = QDH.QDH_FILIAL AND "
cQuery+= "QD0.QD0_DOCTO = QDH.QDH_DOCTO AND QD0.QD0_RV = QDH.QDH_RV AND "
cQuery+= "QD0.QD0_AUT = 'E' AND QD0.QD0_FILMAT = '"+cMatFil+"' AND "
cQuery+= "QD0.QD0_MAT = '"+cMatCod+"' AND QD0.QD0_DEPTO = '"+cMatDep+"' AND QD0.D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY " + SqlOrder("QDH_DTLIM")

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN",TCGenQry(,,cQuery),'QDH_TRB',.F.,.T.)
DbSelectArea("QDH_TRB")

Return cIndex

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QA_QUALITY ³ Autor ³ Eduardo de Souza    ³ Data ³ 11/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza arquivo de Usuarios utilizado pela progr. Quality.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA_QUALITY()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA010.PRW,GPEXFUN1.PRW,TRMA100.PRW                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA_QUALITY()
Local aAreaGPE   := GetArea()
Local aAreaQAA   := {}
Local aQAARela   := {}
Local aStruQAA   := {}
Local aUsers     := FWSFALLUSERS() //https://tdn.totvs.com/display/PROT/FWSFALLUSERS
Local cEmpUsr    := cEmpAnt
Local cFilSx2    := SX2->(DbFilter())
Local cFilUsr    := cFilAnt
Local cIntGPE    := GetMv("MV_QGINT",.F.,"N")
Local cModoCTT   := ""
Local cModoQAA   := ""
Local cModoQAC   := ""
Local cModoQAD   := ""
Local cModoSRJ   := ""
Local cPriFil    := ""
Local cQAA       := "QAA"
Local cQAC       := "QAC"
Local cQAD       := "QAD"
Local cTitApeli  := AllTrim(GetSx3Cache("RA_APELIDO",'X3_TITULO'))
Local lExistLogi := Ascan(aUsers,{|x| AllTrim(x[3]) == AllTrim(SRA->RA_APELIDO)}) > 0 //Validar se existe um usuário no configurador com este login. Se não existir no configurador, deixar o campo QAA_LOGIN em branco.
Local lGrvQAA    := .T.
Local lOpenQaa   := .F.
Local lOpenQaC   := .F.
Local lOpenQaD   := .F.
Local lQDOGRQAA  := ExistBlock("QDOGRQAA")
Local lQGRVQAAF  := ExistBlock("QGRVQAAF")
Local lQXQAMAIL  := ExistBlock("QXQAMAIL")
Local lRet	     := .T.
Local Ni	     := 0
Local nX         := 0

Static lExibiuHlp := .F.

__cFilAnt := cFilAnt
__cEmpAnt := cEmpAnt

If cIntGPE == "S"
	
	dbSelectArea("SX2")
	DbClearFilter()
	DbSetOrder(1)

	cModoQAA:= FWModeAccess("QAA", 3)
	cModoQAC:= FWModeAccess("QAC", 3)
	cModoQAD:= FWModeAccess("QAD", 3)
	cModoSRJ:= FWModeAccess("SRJ", 3)
	cModoCTT:= FWModeAccess("CTT", 3)

	DbSelectArea("QAJ")
	DbSetOrder(1)
	If QAJ->(DbSeek(xFilial("QAJ")+cEmpAnt+cFilAnt))
		cEmpUsr:= QAJ->QAJ_EMPPAR
		cFilUsr:= QAJ->QAJ_FILPAR
	Else   
		DbSelectArea("QAJ")
		DbCloseArea()		
	EndIf
	
	cPriFil := QXPOSFIL(cEmpAnt)
	
	If cEmpAnt <> cEmpUsr
		IF !fAbrEmpresa("QAA",1,cEmpUsr,cFilUsr,@cModoQAA)
			MsgAlert(OemToAnsi(STR0160)+" QAA",OemToAnsi(STR0023)) //  ### "Atencao" //"Nao foi possivel encontrar o arquivo"
			lRet:= .F.
		Else
			cQAA    := "QUAQAA"
			lOpenQaa:= .T.
		Endif
		IF lRet
			IF !fAbrEmpresa("QAC",1,cEmpUsr,cFilUsr,@cModoQAC)
				MsgAlert(OemToAnsi(STR0160)+" QAC",OemToAnsi(STR0023)) //  ### "Atencao" //"Nao foi possivel encontrar o arquivo"
				lRet:= .F.
			Else
				cQAC    := "QUAQAC"
				lOpenQac:= .T.
			Endif
			IF lRet
				IF !fAbrEmpresa("QAD",1,cEmpUsr,cFilUsr,@cModoQAD)
					MsgAlert(OemToAnsi(STR0160)+" QAD",OemToAnsi(STR0023)) //  ### "Atencao" //"Nao foi possivel encontrar o arquivo"
					lRet:= .F.
				Else
					cQAD    := "QUAQAD"
					lOpenQaD:= .T.
				Endif
			Endif
		Endif
	Endif
	IF lRet .And. (cModoQAC <> cModoSRJ .OR. cModoQAD <> cModoCTT)
		Help( "", 1, "QA_QUALITY",,OemToAnsi(STR0192)+Chr(13)+OemToAnsi(STR0193),1)   //"Existe incompatibilidade de compartilhamento entre as tabelas QAC-SRJ ou QAD-CTT."###"Contactar o Administrador do Sistema"
		lRet:= .F.
	Endif

	If lRet 
		If Empty(SRA->RA_APELIDO) 
			If FunName() == 'GPEA010'
				lExibiuHlp 	:= .F. //Se o QA_QUALITY estiver sendo executado no cadastro de funcionários, deverá sempre mostrar o Help.
			EndIf
			If !lExibiuHlp
				Help("", 1, cTitApeli, NIL, STR0251 + cTitApeli + STR0252, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0253 + cTitApeli + STR0254})
										//"O campo " ### "(RA_APELIDO) é obrigatório quando a integração entre Quality e SIGAGPE esta ligada." ### "Informe o campo " ### "(RA_APELIDO) no cadastro de Funcionários(GPEA010) para que este usuário seja integrado no Quality."
			EndIf
			lExibiuHlp 	:= .T.
			lRet 		:= .F.
		Else
			aAreaQAA := QAA->(GetArea())
			DbSelectArea("QAA")
			QAA->(DbSetOrder(1))//QAA_FILIAL+QAA_MAT
			If QAA->(DbSeek(cFilUsr+cEmpAnt+cFilAnt+SRA->RA_MAT))
				/* Se o apelido da SRA que esta sendo alterado é diferente do que já existe na QAA 
				busca na QAA se este já não esta sendo usado para outro usuário */
				IF PADR(SRA->RA_APELIDO,25) <> PADR(QAA->QAA_LOGIN,25)
					QAA->(DbSetOrder(6))//QAA_LOGIN
					If QAA->(DbSeek(PADR(SRA->RA_APELIDO,25)))
						If cFilUsr+cEmpAnt+cFilAnt+SRA->RA_MAT <> QAA->QAA_MAT //Se o login localizado for de uma matricula diferente
							Help("", 1, cTitApeli, NIL, STR0255, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0253 + cTitApeli + STR0256})
													//"Já existe um usuário cadastrado com este apelido." ### "Informe o campo " ### "(RA_APELIDO) no cadastro de Funcionários(GPEA010) com um conteúdo diferente para que este usuário seja integrado no Quality."
							lRet := .F.
						Endif
					Endif
				ENDIF
			Else //Inclusão
				QAA->(DbSetOrder(6))//QAA_LOGIN
				If QAA->(DbSeek(PADR(SRA->RA_APELIDO,25)))
					Help("", 1, cTitApeli, NIL, STR0255, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0253 + cTitApeli + STR0256})
													//"Já existe um usuário cadastrado com este apelido." ### "Informe o campo " ### "(RA_APELIDO) no cadastro de Funcionários(GPEA010) com um conteúdo diferente para que este usuário seja integrado no Quality."
					lRet := .F.
				Endif
			EndIf
			QAA->(DbCloseArea())
			RestArea(aAreaQAA)
		EndIf
	EndIf
	
	IF lRet     
		aStruQAA := FWFormStruct(3, cQAA)[3]
		For nX := 1 TO Len(aStruQAA) 
		   	IF GetSx3Cache(aStruQAA[nX, 1], "X3_CONTEXT") != "V" .AND. !Empty(GetSx3Cache(aStruQAA[nX, 1], "X3_RELACAO"))
		   		AADD(aQAARela,{aStruQAA[nX, 1], GetSx3Cache(aStruQAA[nX, 1], "X3_RELACAO")}) 	   		
    	    Endif
		Next nX
		
		Begin Transaction
			DbSelectArea(cQAA)
			DbSetOrder(1)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava Funcionario na Empresa/Filial.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If DbSeek(cFilUsr+cEmpAnt+cFilAnt+SRA->RA_MAT)
				
				nArQAA := QAA->(Recno())
				If lQDOGRQAA
					If ValType(lGrvQAA := ExecBlock("QDOGRQAA",.F.,.F.)) != "L"
						lGrvQAA := .T.
					EndIf
					
					dbSelectArea("QAA")
					QAA->(dbGoTo(nArQAA))
				EndIf	            

				If lGrvQAA
					RecLock(cQAA,.F.)
					(cQAA)->QAA_TPUSR := "1"
					(cQAA)->QAA_NOME  := SRA->RA_NOME
					(cQAA)->QAA_APELID:= SRA->RA_APELIDO
					(cQAA)->QAA_INICIO:= SRA->RA_ADMISSA
					(cQAA)->QAA_FIM   := SRA->RA_DEMISSA
					IF lQXQAMAIL
						IF ExecBlock("QXQAMAIL",.F.,.F.)
							(cQAA)->QAA_RECMAI:= If(SRA->RA_RECMAIL == "S","1","2")
							(cQAA)->QAA_TPMAIL:= SRA->RA_TPMAIL	
							(cQAA)->QAA_EMAIL := SRA->RA_EMAIL
						Endif
					Else
						(cQAA)->QAA_RECMAI:= If(SRA->RA_RECMAIL == "S","1","2")
						(cQAA)->QAA_TPMAIL:= SRA->RA_TPMAIL
						(cQAA)->QAA_EMAIL := SRA->RA_EMAIL
					Endif				
					(cQAA)->QAA_STATUS:= If(SRA->RA_SITFOLH == "D","2","1")

					//Validar se existe um usuário no configurador com este login(Apelido). Se não existir no configurador, deixar o campo QAA_LOGIN em branco.					
					If Empty((cQAA)->QAA_LOGIN)
						(cQAA)->QAA_LOGIN  := IIf(lExistLogi, SRA->RA_APELIDO, Criavar("QAA_LOGIN"))
					Else
						(cQAA)->QAA_APELID := (cQAA)->QAA_LOGIN
					EndIF

					If cModoQAC == "C"
						(cQAA)->QAA_CODFUN:= cEmpAnt+cPriFil+SRA->RA_CODFUNC
					Else
						(cQAA)->QAA_CODFUN:= cEmpAnt+cFilAnt+SRA->RA_CODFUNC
					Endif
					For Ni:=1 TO Len(aQAARela)
						IF Empty((cQAA)->(FieldGet(FieldPos(aQAARela[Ni,1]))))
						    cCampo:=(cQAA)+"->"+aQAARela[Ni,1]
	
							&(cCampo):=InitPad(aQAARela[Ni,2])
	                    Endif
					Next                     
					
					MsUnlock()
					FKCOMMIT()
				EndIf
			Else //Inclusão

				If lQDOGRQAA
					If ValType(lGrvQAA := ExecBlock("QDOGRQAA",.F.,.F.)) != "L"
						lGrvQAA := .T.
					EndIf
					
					dbSelectArea("QAA")
				EndIf	

				If lGrvQAA
					RecLock(cQAA,.T.)
					(cQAA)->QAA_FILIAL:= cFilUsr
					(cQAA)->QAA_TPUSR := "1"
					(cQAA)->QAA_MAT   := cEmpAnt+cFilAnt+SRA->RA_MAT
					(cQAA)->QAA_NOME  := SRA->RA_NOME
					(cQAA)->QAA_APELID:= SRA->RA_APELIDO
					(cQAA)->QAA_INICIO:= SRA->RA_ADMISSA
					(cQAA)->QAA_FIM   := SRA->RA_DEMISSA
					(cQAA)->QAA_RECMAI:= If(SRA->RA_RECMAIL == "S","1","2")
					(cQAA)->QAA_TPMAIL:= SRA->RA_TPMAIL
					(cQAA)->QAA_EMAIL := SRA->RA_EMAIL
					
					//Validar se existe um usuário no configurador com este login(Apelido). Se não existir no configurador, deixar o campo QAA_LOGIN em branco.
					(cQAA)->QAA_LOGIN := IIf(lExistLogi, SRA->RA_APELIDO, Criavar("QAA_LOGIN"))
					
					(cQAA)->QAA_STATUS:= If(SRA->RA_SITFOLH == "D","2","1")
					
					If cModoQAD == "C"
						(cQAA)->QAA_CC    := cEmpAnt+cPriFil+SRA->RA_CC
					Else
						(cQAA)->QAA_CC    := cEmpAnt+cFilAnt+SRA->RA_CC
					Endif
					If cModoQAC == "C"
						(cQAA)->QAA_CODFUN:= cEmpAnt+cPriFil+SRA->RA_CODFUNC
					Else
						(cQAA)->QAA_CODFUN:= cEmpAnt+cFilAnt+SRA->RA_CODFUNC
					Endif
					For Ni:=1 TO Len(aQAARela)
						IF Empty((cQAA)->(FieldGet(FieldPos(aQAARela[Ni,1]))))
						    cCampo:=(cQAA)+"->"+aQAARela[Ni,1]
							&(cCampo):=InitPad(aQAARela[Ni,2])
	                    Endif
					Next				
	
					MsUnlock()
					FKCOMMIT()
				EndIf
			EndIf
		End Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o PE apos a gravacao do Funcionario                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQGRVQAAF
			ExecBlock("QGRVQAAF",.F.,.F.)
		EndIf	
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finaliza Arquivos e Indices temporarios da Empresa Destino. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOpenQaa
		fFecEmpresa( cQAA )
	Else
		DbSelectArea(cQAA)
		DbCloseArea()         		
	EndIf
	
	If lOpenQaC
		fFecEmpresa( cQAC )
	Else
		DbSelectArea(cQAC)
		DbCloseArea()         				
	EndIf
	
	If lOpenQaD
		fFecEmpresa( cQAD )
	Else
		DbSelectArea(cQAD)
		DbCloseArea()         				
	EndIf

	dbSelectArea("SX2")
	Set Filter To &(cFilSx2)

EndIf

cFilAnt := __cFilAnt
cEmpAnt := __cEmpAnt

RestARea(aAreaGPE)

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QC_QUALITY ³ Autor ³ Eduardo de Souza    ³ Data ³ 16/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza arquivo de funcoes utilizado pela prog. Quality.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QC_QUALITY()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGA QUALITY                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QC_QUALITY()

Local cIntGPE := GetMv("MV_QGINT",.F.,"N")
Local cEmpFun := cEmpAnt
Local cFilFun := cFilAnt
Local cQAC    := "QAC"
Local cModoQAC:= ""
Local cFuncao := ""
Local lOpenQac:= .F.
Local cPriFil := ""
Local cFilSx2 := SX2->(DbFilter())
Local cModoSRJ:= ""
Local lRet	  := .T.
Local aAreaGPE:= GetArea()
Local cCodCARGO  := ""
Local cDescCARGO := ""


__cFilAnt := cFilAnt
__cEmpAnt := cEmpAnt

If cIntGPE == "S"
	
	dbSelectArea("SQ3")  // Acrescenta para gravacaoo do cargo no tabela QAC - Adilson 11/11/2009
	DbSetOrder(1)

	dbSelectArea("SX2")
	Set Filter To
	DbSetOrder(1)
	
	cModoQAC:= FWModeAccess("QAC", 3)
	cModoSRJ:= FWModeAccess("SRJ", 3)
	cModoCTT:= FWModeAccess("CTT", 3)
	
	DbSelectArea("QAJ")
	DbSetOrder(1)
	If QAJ->(DbSeek(xFilial("QAJ")+cEmpAnt+cFilAnt))
		cEmpFun:= QAJ->QAJ_EMPPAR
		cFilFun:= QAJ->QAJ_FILPAR
	Else
		DbSelectArea("QAJ")
		DbCloseArea()		
	EndIf
	
	cPriFil := QXPOSFIL(cEmpAnt)
	
	If cEmpAnt <> cEmpFun
		IF !fAbrEmpresa("QAC",1,cEmpFun,cFilFun,@cModoQAC)
			MsgAlert(OemToAnsi(STR0160+" QAC"),OemToAnsi(STR0023)) //  ### "Atencao" //"Nao foi possivel encontrar o arquivo"
			lRet:= .F.
		Else
			cQAC    := "QUAQAC"
			lOpenQac:= .T.
		Endif
	EndIf
	
	If lRet .AND. cModoQAC <> cModoSRJ
		Help( "", 1, "QC_QUALITY",,OemToAnsi(STR0194)+CHR(13)+OemToAnsi(STR0193),1)   //"Existe incompatibilidade de compartilhamento entre as tabelas QAC-SRJ."###"Contactar o Administrador do Sistema"
		lRet:= .F.
	Endif
	
	If lRet
		DbSelectArea(cQAC)
		DbSetOrder(1)
		
		If TAMSX3("QAC_FUNCAO")[1] == 8		// Limitar o codigo gerado ao tamanho do campo
			If cModoQAC == "C"
				cFuncao:= cEmpAnt+cPriFil+Right(SRJ->RJ_FUNCAO, 4)
			Else
				cFuncao:= cEmpAnt+cFilAnt+Right(SRJ->RJ_FUNCAO, 4)
			Endif
		Else
			If cModoQAC == "C"
				cFuncao:= cEmpAnt+cPriFil+SRJ->RJ_FUNCAO
			Else
				cFuncao:= cEmpAnt+cFilAnt+SRJ->RJ_FUNCAO
			Endif
		Endif
		
		If cModoQAC == "C"
			cFilFun:= xFilial(cQAC)
		EndIf
		
        lExistFunc := DbSeek(cFilFun+cFuncao) 
        cCodCARGO := SRJ->RJ_CARGO          // Codigo do cargo                             data 11/11/2009
		If SQ3->(dbSeek(cFilFun+cCodCARGO))    // Tabela RH - cargos - order 1/ filial+cargo  data 11/11/2009
	   		cDescCARGO := SQ3->Q3_DESCSUM        // Descricao do cargo                          data 11/11/2009
	   	Endif	

		Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava Funcao na Empresa/Filial Destino.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExistFunc
			RecLock(cQAC,.F.)
			(cQAC)->QAC_DESC  := SRJ->RJ_DESC
			If !Empty(cCodCARGO)
				If cModoQAC == "C"  
					cCodCARGO:= cEmpAnt+cPriFil+cCodCARGO
				Else
					cCodCARGO:= cEmpAnt+cFilAnt+cCodCARGO
				Endif				
			Endif				
			(cQAC)->QAC_CARGO := cCodCARGO  	// Adilson Soeiro - Gravacao do Cod. Cargo   data 11/11/2009
			(cQAC)->QAC_DESCCG:= cDescCARGO		// Adilson Soeiro - Gravação da Descr Cargo  data 11/11/2009
			MsUnlock()
			FKCOMMIT()
		Else
			RecLock(cQAC,.T.)
			(cQAC)->QAC_FILIAL:= cFilFun
			(cQAC)->QAC_DESC  := SRJ->RJ_DESC
			(cQAC)->QAC_FUNCAO:= cFuncao
			If !Empty(cCodCARGO)
				If cModoQAC == "C"  
					cCodCARGO:= cEmpAnt+cPriFil+cCodCARGO
				Else
					cCodCARGO:= cEmpAnt+cFilAnt+cCodCARGO
				Endif				
			Endif				
			(cQAC)->QAC_CARGO := cCodCARGO  	// Adilson Soeiro - Gravacao do Cod. Cargo   data 11/11/2009
			(cQAC)->QAC_DESCCG:= cDescCARGO		// Adilson Soeiro - Gravação da Descr Cargo  data 11/11/2009
			MsUnlock()
			FKCOMMIT()
		EndIf
		End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o PE apos a gravacao da Funcao/Cargo               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("QGRVQACF")
			ExecBlock("QGRVQACF",.F.,.F.)
		EndIf	
	Endif

	If lOpenQac
		fFecEmpresa( cQAC )
	Else
		DbSelectArea(cQAC)
		DbCloseArea()		
	EndIf

	dbSelectArea("SX2")
	Set Filter To &(cFilSx2)

EndIf



cFilAnt := __cFilAnt
cEmpAnt := __cEmpAnt

RestARea(aAreaGPE)

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD_QUALITY ³ Autor ³ Eduardo de Souza    ³ Data ³ 16/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza arquivo de Departamentos utilizado pelo Quality.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD_QUALITY()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGA QUALITY                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD_QUALITY()

Local cIntGPE := GetMv("MV_QGINT",.F.,"N")
Local cEmpDep := cEmpAnt
Local cFilDep := cFilAnt
Local cQAD    := "QAD"
Local cIndQad := ""
Local cModoQAD:= ""
Local cDepto  := ""
Local lOpenQad:= .F.
Local cPriFil := ""
Local cFilSx2 := SX2->(DbFilter())
Local cModoCTT:= ""
Local lRet	  := .T.
Local aAreaGPE:= GetArea()

__cFilAnt := cFilAnt
__cEmpAnt := cEmpAnt


If cIntGPE == "S"
	
	dbSelectArea("SX2")
	Set Filter To
	DbSetOrder(1)
	
	cModoQAD:= FWModeAccess("QAD", 3)
	cModoCTT:= FWModeAccess("CTT", 3)
	
	DbSelectArea("QAJ")
	DbSetOrder(1)
	If QAJ->(DbSeek(xFilial("QAJ")+cEmpAnt+cFilAnt))
		cEmpDep:= QAJ->QAJ_EMPPAR
		cFilDep:= QAJ->QAJ_FILPAR
    Else
		DbSelectArea("QAJ")
		DbCloseArea()			
	EndIf
	
	cPriFil := QXPOSFIL(cEmpAnt)
	
	If cEmpAnt <> cEmpDep
		IF !fAbrEmpresa("QAD",1,cEmpDep,cFilDep,@cModoQAD)
			MsgAlert(OemToAnsi(STR0160+" QAD"),OemToAnsi(STR0023)) //  ### "Atencao" //"Nao foi possivel encontrar o arquivo"
			lRet:= .F.
		Else
			cQAD    := "QUAQAD"
			lOpenQaD:= .T.
		Endif
	Endif
	
	IF lRet .And.  cModoQAD <> cModoCTT
		Help( "", 1, "QD_QUALITY",,OemToAnsi(STR0195)+CHR(13)+OemToAnsi(STR0193),1)  //"### //"Existe incompatibilidade de compartilhamento entre as tabelas QAD-CTT."###"Contactar o Administrador do Sistema"
		lRet:= .F.
	Endif
	
	IF lRet
		DbSelectArea(cQAD)
		DbSetOrder(1)
		
		If cModoQAD == "C"
			cDepto:= cEmpAnt+cPriFil+Substr(CTT->CTT_CUSTO,1,TamSX3("QAD_CUSTO")[1])
		Else
			cDepto:= cEmpAnt+cFilAnt+Substr(CTT->CTT_CUSTO,1,TamSX3("QAD_CUSTO")[1])
		Endif
		
		If cModoQAD == "C"
			cFilDep:= xFilial(cQAD)
		EndIf
		
		Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava Funcao na Empresa/Filial Destino.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DbSeek(cFilDep+cDepto)
			RecLock(cQAD,.F.)
			(cQAD)->QAD_DESC  := Substr(CTT->CTT_DESC01,1,TamSX3("CTT_DESC01")[1])
			(cQAD)->QAD_STATUS:= If(CTT->CTT_BLOQ == "1","2","1")
			MsUnlock()
			FKCOMMIT()
		Else
			RecLock(cQAD,.T.)
			(cQAD)->QAD_FILIAL:= cFilDep
			(cQAD)->QAD_CUSTO := cDepto
			(cQAD)->QAD_DESC  := Substr(CTT->CTT_DESC01,1,TamSX3("CTT_DESC01")[1])
			(cQAD)->QAD_STATUS:= If(CTT->CTT_BLOQ == "1","2","1")
			MsUnlock()
			FKCOMMIT()
		EndIf
		End Transaction
	Endif

	If lOpenQad
		fFecEmpresa( cQAD )
	Else
		DbSelectArea(cQAD)
		DbCloseArea()			
	EndIf
	
	dbSelectArea("SX2")
	Set Filter To &(cFilSx2)

EndIf


cFilAnt := __cFilAnt
cEmpAnt := __cEmpAnt

RestARea(aAreaGPE)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOLOAD   ºAutor  ³Telso Carneiro	     º Data ³  01/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada das funcoes necessarias para inicializacao do      º±±
±±º          ³ modulo SIGAQDO                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Inicializacao do Modulo SIGAQDO                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QDOLOAD()

Local aMsgErro    := {}
Local lQ050Mail   := .T.
Local oQLTManager
Local oDocControl 

dbSelectArea("QDZ")
If FindClass("QLTQueryManager")
	oQLTManager := QLTQueryManager():New()
	If oQLTManager:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "QDO")
		//STR0248 - "Validando Configurações do ambiente SIGAQDO."
		//STR0247 - "Aguarde..."
		MsgRun( STR0248, STR0247, {|| ValidQDO(oQLTManager, @aMsgErro) } )

		If Len(aMsgErro) > 0
			oQLTManager:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "QDO", aMsgErro)
		EndIf
	EndIf
EndIf

//Valida os campos de Depto
fValdTAM()

If Existblock("Q050LOAD")
	Execblock ("Q050LOAD",.F.,.F.)
Else
	If Existblock("Q050MAIL")
		lQ050Mail := Execblock ("Q050MAIL",.F.,.F.)
	Endif
	If GetMV("MV_QDOAVEM") == "1" .AND. lQ050Mail
		QDOAVMAIL()
	Endif
Endif   

If Existblock("Q050LOAD")
	Execblock ("Q050LOAD",.F.,.F.)
Else
	QA_TRAVUSR()  //Verificacao de Usuario Ativo
	FQDO_USR()    //Pendencias e geracao do limite.txt  
Endif

If GetMv("MV_QALOGIX") == "1" //Caso haja integracao com o Logix e exista alias QNB - verifica se tem inconsistencias nos WebServices
	If ChkFile("QNB")
		If GetMV("MV_QMLOGIX",.T.,"1") == "1" //Define se mostra a tela de inconsistencia 
		QXMSLOGIX()
		Endif
	Endif	
Endif	
 
//Valida os requisitos técnicos para leitura em PDF.
IF FindClass(Upper("QDODocumentControl"))
    oDocControl := QDODocumentControl():New() 
    oDocControl:validaInconsistenciaImplantacao()
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOAVMAIL  ³ Autor ³ Rodrigo Gomes       ³ Data ³ 28/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia E-mail para usuarios com pendencias no formato HTML  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOAVMAIL()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOAVMAIL()

Local dDtFlag    := GetMv("MV_QUDQDO") // Flag contendo o ultimo dia de envio de e-mail  
Local aUsrMat    := QNCUSUARIO()
Local aUsuarios  := {}
Local cMensag    := ""
Local cTVenc     := ""
Local cDesCod    := ""
Local cMsg       := ""
Local cSubject   := ""
Local cDescQD1   := ""
Local nIndQD1    := 0
Local cKey       := ""
Local cFiltro    := "" 
Local cFilUsr    := "" // Filial do usuario
Local cMatUsr    := "" // Matricula do usuario
Local aMail      := {} // Corpo do E-mail
Local nDiaFlag   := SuperVal(GetMv("MV_QUDQDON",.F.,"0")) // Define o Periodo em dias de envio de e-mail do MV_QUDQDO
Local aAreaAnt	 := GetArea()
Local aAreaSX6	 := SX6->(GetArea())  
Local lQDOMSGPD  := ExistBlock( "QDOMSGPD" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-¿
//³aMail  ==>  aMail[x][1] --> Codigo            ³
//³            aMail[x][2] --> Revisao           ³
//³            aMail[x][3] --> Descricao         ³
//³            aMail[x][4] --> Data de Geracao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ù

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se os usuarios ja receberam E-mail hoje.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(dDtFlag) .And. ((CToD(dDtFlag)+nDiaFlag) >= dDataBase)
	Return( Nil )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-¿
//³Filtra o Arquivo QD1 - Documentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ù
cIndQD1 := CriaTrab(NIL,.F.)
dbSelectArea("QD1")
cKey := "QD1_FILMAT+QD1_MAT+QD1_FILIAL+QD1_DOCTO+QD1_RV"

cFiltro := "QD1_PENDEN == 'P' "

IndRegua("QD1",cIndQD1,cKey,,cFiltro,STR0163) //"Selecionando Registro no QD1..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o indice temporario QD1 e posiciona no primeiro registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndQD1 := RetIndex("QD1")
dbSetOrder(nIndQD1 + 1)
dbGoTop() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no cadastro de usuarios para pegar os dados futuramente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QAA")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--------------¿
//³Pega todas os Documentos de todos os usuarios PENDENTES.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--------------Ù
While QD1->(!Eof())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o Array com os dados do E-mail.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMail := {}
	
	// Pega o novo usuario
	cFilUsr := QD1->QD1_FILMAT
	cMatUsr := QD1->QD1_MAT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a validacao do usuario para que o usuario receba e-mail devera ³
	//³ser: Ativo, Recebe  E-mail, e o campo EMAIL nao estiver vazio      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QAA->(DbSeek(cFilUsr + cMatUsr ))
		If QAA->QAA_RECMAI == "1" .And. QAA->QAA_STATUS == "1"  .And. !Empty(QAA->QAA_EMAIL)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ------¿
			//³Pega os dados de cada usuario e envia o E-mail com os dados dos Documentos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ------Ù
			While QD1->( !Eof() .And. QD1->QD1_FILMAT + QD1->QD1_MAT == cFilUsr + cMatUsr )
				cDescQD1 := AllTrim(Tabela("Q7", QD1->QD1_TPPEND, .F.))
				DbSelectarea ("QDH")
				QDH->(DbSetOrder(1))
				If QDH->(DbSeek(xFilial("QDH")+QD1->QD1_DOCTO + QD1->QD1_RV))
					If Empty(QDH->QDH_DTLIM) .Or. (QDH->QDH_DTLIM - dDatabase) > 0 
						AADD(aMail,{QD1->QD1_DOCTO, QD1->QD1_RV, Left(cDescQD1,50), QD1->QD1_DTGERA})
					Endif
				Endif
				QD1->( dbSkip() )
			EndDo
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso esse usuario tenha alguma pendencia Vencida ou a          ³
	//³vencer a rotina envia E-mail no formato que o usuario cadastrou³
	//³contendo as pendencias								          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aMail) > 0
		
		cSubject := STR0164 //"Lancamentos Pendentes"
		cMensag  := STR0165 //"Existe(m) lancamento(s) pendente(s), favor baixar rapidamente"
	    cTVenc   := STR0166 //"Documentos"
	    cDesCod  := STR0167 //"Doctos"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o Corpo do E-mail no Formato HTML ou Texto.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg := QNCMAILVCT(2,aMail,Val(QAA->QAA_TPMAIL),cMensag,cTVenc,cDesCod) 

		cAttach := ""
		aMsg:={{cSubject + Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5) , cMsg, cAttach } }
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ExecBlock responsavel pela alteracao do Layout do E-mail³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lQDOMSGPD
			aMsg := ExecBlock( "QDOMSGPD", .f., .f. )
		Endif
		
		AADD(aUsuarios, {QAA->QAA_LOGIN, QAA->QAA_EMAIL, aMsg} )
	Else
		QD1->( dbSkip() )
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia E-mail para cada usuario com as pendencias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aUsuarios) > 0	
	QaEnvMail(aUsuarios,,,,aUsrMat[5],"1")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivos tempor rios e os indices	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("QD1")
If file(cIndQD1+OrdBagExt())
	Ferase(cIndQD1+OrdBagExt())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona o Flag no SX6, indicando que ja enviou E-mail hoje³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÙ
dDtFlag := Iif(Empty(dDtFlag),"01/01/04",dDtFlag)
dbSelectArea("SX6")                              
SX6->(DbGoTop())
If GetMV("MV_QUDQDO", .T.) .And. CToD(dDtFlag) < dDataBase
	PutMv("MV_QUDQDO",DtoC(dDatabase))
EndIf

RestArea(aAreaSX6)
RestArea(aAreaAnt)

Return( Nil )
                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD2FndDOT ºAutor  ³Telso Carneiro      º Data ³  02/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valid do campos QD2_MODELO                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SX3                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QD2FndDot(cDot)
Local lRet:=.T.
Local aQPath   := QDOPATH()
Local cQPathTrm:= aQPath[2]          

IF !Empty(cDot)
	IF !FILE(cQPathTrm+Alltrim(cDot))
		If (TamSx3("QD2_MODELO")[1]) == 12
			If !FILE(cQPathTrm+Alltrim(cDot) + "X")
		       lRet:=.F.
			   Help( " ", 1, "QD_DOTNEXT" )
			Endif       
		Else
			lRet:=.F.
			Help( " ", 1, "QD_DOTNEXT" )		
		Endif
	Endif	
Endif	

Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QXPOSFIL   ³ Autor ³ Eduardo de Souza   ³ Data ³ 21/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Retorna a primeira filial da empresa logada               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QXPOSFIL()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QUALITY                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QXPOSFIL(cEmpCod)
Local nPosSM0 := 0                

Local nFilAtu := 0

Default cEmpCod:= cEmpAnt

DbSelectArea("SM0")
DbSetOrder(1)
nPosSM0:= Recno()

If SM0->(DbSeek(cEmpCod))
	nFilAtu := FWCodFil() //SM0->M0_CODFIL
Endif
SM0->(DbGoto(nPosSM0))

Return nFilAtu

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QDXDtVig    ³ Autor ³ Telso Carneiro             ³ Data ³19/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a tela de data de distribuicao, vigencia e validade         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDXDtVig()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOxfun                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXDtVig()
            	
Local oDlg
Local oDtVig
Local oDtImpl
Local oQtdDias
Local oDtAtLim
Local oDtLim 
Local dDtVig  := QDH->QDH_DTVIG
Local dDtImpl := QDH->QDH_DTIMPL
Local dDtAtLIm:= QDH->QDH_DTLIM
Local dDtLim  := CToD( "  /  /  ","DDMMYY" )
Local nQtdDias:= 1
Local nOpc1   := 0       

QD2->(DbSeek(xFilial("QD2")+QDH->QDH_CODTP))
If (nQtdDias:= QD2->QD2_QDIASV) > 0
	dDtLim := (dDataBase+QD2->QD2_QDIASV)
EndIf

DEFINE MSDIALOG oDlg FROM 000,000 TO 220,205 TITLE OemToAnsi(STR0184) PIXEL   //"Revalidação"

@ 001,004 TO 85,100 OF oDlg PIXEL

@ 010,010 SAY OemToAnsi(STR0185) SIZE 70,10 OF oDlg PIXEL   //"Dt Vigˆncia"
@ 025,010 SAY OemToAnsi(STR0186) SIZE 70,10 OF oDlg PIXEL   //"Dt Implantação"
@ 040,010 SAY OemToAnsi(STR0187) SIZE 70,10 OF oDlg PIXEL    //"Dt Validade"
@ 055,010 SAY OemToAnsi(STR0188) SIZE 70,10 OF oDlg PIXEL   //"Dias Validade"
@ 070,010 SAY OemToAnsi(STR0189) SIZE 70,10 OF oDlg PIXEL  //"Dt Revalidação"

@ 010,055 	MSGET oDtVig VAR dDtVig PICTURE "@D" SIZE 043,008 OF oDlg PIXEL	WHEN .F.

@ 025,055 	MSGET oDtImpl VAR dDtImpl	PICTURE "@D" SIZE 043,008 OF oDlg PIXEL WHEN .F.

@ 040,055 	MSGET oDtAtLim VAR dDtAtLIm	PICTURE "@D" SIZE 043,008 OF oDlg PIXEL WHEN .F.

@ 055,055 	MSGET oQtdDias VAR nQtdDias PICTURE "9999" SIZE 027,008 OF oDlg PIXEL;
           	VALID If(nQtdDias >= 0,;
           	(dDtLim:= If(nQtdDias > 0,dDAtabase+nQtdDias,CToD("  /  /  ","DDMMYY")),oDtLim:Refresh()),.F.)

@ 070,055 	MSGET oDtLim VAR dDtLim PICTURE	"@D" SIZE 043,008 OF oDlg PIXEL ;
			VALID dDtAtLIm < dDtLim 		
			
DEFINE SBUTTON FROM 90,35 TYPE 1 ENABLE OF oDlg ACTION (nOpc1:=1,oDlg:End())
DEFINE SBUTTON FROM 90,65 TYPE 2 ENABLE OF oDlg	ACTION oDlg:End()

ACTIVATE	MSDIALOG oDlg CENTERED

If nOpc1 == 1
	M->QDH_DTLIM := dDtLim
	If Existblock("QD050REV")
		Execblock("QD050REV",.F.,.F.,{dDtVig,dDtImpl,dDtAtLIm,nQtdDias,dDtLim})
	Endif
EndIf

Return If(nOpc1 == 1,.T.,.F.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDXREdTxt  ³Autor ³ Programacao Quality³ Data ³19/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Textos do Documento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QDXREdTxt(ExpC1,ExpN2,ExpC3,ExpC4)					     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Codigo+Revisao do Documento                      ³±±
±±³           ³ ExpC2 - Chave do Documento                               ³±±
±±³           ³ ExpC3 - Datas da Revalidacao para criar Historico        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDXFNCkSRv                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDXREDTxt(cCod,cChaveQDH,cHist)

Local cEspecie := "RED     "
Local cChave   := cChaveQDH
Local nTamLin  := TamSX3( "QA2_TEXTO" )[1]
Local axTextos 		:= {}
Local lRet     		:= .F.
Local oFontMet   	:= TFont():New("Courier New",6,0)
Local oFontDialog	:= TFont():New("Arial",6,15,,.T.)
Local oDlg
Local oTexto
Local oNewTexto
Local cTexto 		:= ""
Local cNewTexto		:= ""
Local nOpcA 		:= 0
Local nPos			:= 0
Local cAliasQA2 	:= "QA2"    
Local nLi			:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera Texto ja' existente (nLi e' a linha atual da getdados)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTexto := QA_RecTxt( cChave, cEspecie, nLi, nTamLin, cAliasQA2, axtextos)

DEFINE MSDIALOG oDlg FROM 62,100 TO 460,610 TITLE OemtoAnsi( STR0190 )  PIXEL FONT oFontDialog  //" Revalidação"

@ 003, 004 TO 027, 250 LABEL OemtoAnsi( STR0113 )   OF oDlg PIXEL //"Documento"
@ 040, 004 TO 180, 250	OF oDlg PIXEL

@ 013, 010 MSGET cCod WHEN .F. SIZE 185, 010 OF oDlg PIXEL

@ 035, 010 SAY OemtoAnsi( STR0191 )   OF oDlg PIXEL  //"Historico da Revalidação"
	
@ 045, 010 GET oTexto VAR cTexto MEMO READONLY NO VSCROLL SIZE 238, 051 OF oDlg PIXEL	
oTexto:SetFont(oFontMet)

@ 105, 010 SAY OemtoAnsi( STR0190 )  OF oDlg PIXEL  //" Revalidação"

@ 115, 010 GET oNewTexto VAR cNewTexto MEMO NO VSCROLL SIZE 238, 051 OF oDlg PIXEL	
oNewTexto:SetFont(oFontMet)
oNewTexto:Setfocus()
	
DEFINE SBUTTON FROM 185,190 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 185,220 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg
	
ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
    IF Empty(cTexto)             
		cTexto:= cHist+Chr(13)+" "+cNewTexto
	Else
		cTexto:= cTexto+Chr(13)+" "+cHist+Chr(13)+" "+cNewTexto	
	Endif
	Aadd(axTextos, { nLi, cTexto } )

	QA_GrvTxt( cChave, cEspecie, 1, @axtextos )
	lRet:=.T.
EndIf

Return (lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDXAvLim  ³ Autor ³ Programacao Quality  ³ Data ³21/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa a data de validade de uma determinada revisao de     ³±±
±±³          ³ documento e avisa ao responsavel que esta vencido/a vencer.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXAvLim()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FQDO_USR()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXAvLim(dDataUsar)

Local nDias    	:= GetMV("MV_QDIALIM")
Local cAlias   	:= ""
Local aAliasAtu	:= GetArea()
Local cQuery 	:= ""
Local cIndex 	:= CriaTrab(Nil,.F.)
Local aUsrMail	:= {}
Local aUsrMat   := QA_USUARIO()
Local cFilQD2	:= ""
Local aUsrAuse	:= {}
Local cFilMat	:= ""
Local cMat		:= ""
Local cRecmai	:= ""
Local cEmail	:= ""
Local cApelid	:= "" 
Local dDtFlag   := GetMv("MV_QUDAVEN",.F.,"") // Flag contendo o ultimo dia de Aviso de Vencimento  
Local lDtQDXAV  := GetMv("MV_QDXAVLI",.F.,"2")=="1" // Define se gera a verificacao por data do Aviso de Vencimento
Local nRegSx6	:= SX6->(Recno())

Default nDias  	:= 0


IF lDtQDXAV
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se os usuarios ja receberam Avisos hoje.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(dDtFlag) .And. CToD(dDtFlag) >= dDataUsar
		Return( Nil )
    Else
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona o Flag no SX6, indicando que ja enviou Avisos hoje³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---ÄÄÙ
		dbSelectArea("SX6")
		If dbSeek(xFilial("SX6")+"MV_QUDAVEN")
			PutMv("MV_QUDAVEN",DtoC(dDataUsar))
		EndIf
		dbGoto(nRegSx6)		
	EndIf
Endif	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra Documentos para mostrar documentos validados ou a vencer³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SELECT DO QDH COM A DATA LIMITE VENCIDA CONFORME PARAMETRO    ³
//³ VERIFICACANDO O QD0 E QD5 COM USUARIOS COM PERMISSAO		 ³
//³ DE GERAR REVISAO                  					         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
cQuery:= "SELECT QDH.QDH_FILIAL, QDH.QDH_DOCTO,QDH.QDH_RV,QDH.QDH_TITULO,QDH.QDH_CODTP,QDH.QDH_DTLIM,QD0.QD0_FILMAT,QD0.QD0_MAT,QD0.QD0_DEPTO, "
cQuery+= "QD0.QD0_AUT, QAA.QAA_RECMAI, QAA.QAA_APELID, QAA.QAA_EMAIL "
cQuery+= "FROM " + RetSqlName("QDH")+" QDH,"+ RetSqlName("QD0")+" QD0,"+RetSqlName("QD5")+" QD5,"+RetSqlName("QAA")+" QAA "
cQuery+= "WHERE QDH.QDH_STATUS = 'L  ' AND QDH.QDH_DTLIM <> '        ' AND "
cQuery+= "QDH.QDH_OBSOL <> 'S' AND QDH.QDH_CANCEL <> 'S' AND "
cQuery+= "('"+DTOS(dDataUsar+nDias)+"' >= QDH.QDH_DTLIM OR QDH.QDH_DTLIM < '"+DTOS(dDataUsar)+"') AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SubSelect para garantir nao ha revisao do QDH em andamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
cQuery += "QDH.QDH_RV = ( SELECT  MAX(QDH2.QDH_RV) FROM "+RetSqlName("QDH") +" QDH2"  
		cQuery += " WHERE QDH2.QDH_FILIAL = QDH.QDH_FILIAL 
		cQuery += " AND QDH2.QDH_DOCTO =  QDH.QDH_DOCTO "
		cQuery += " AND QDH2.QDH_CANCEL <> 'S' 
		cQuery += " AND QDH2.QDH_OBSOL <> 'S' "
		cQuery += "	AND QDH2.D_E_L_E_T_ <> '*') AND "

cQuery+= "QDH.D_E_L_E_T_ <> '*' AND "
cQuery+= "QD0.QD0_FILIAL = QDH.QDH_FILIAL AND "
cQuery+= "QD0.QD0_DOCTO = QDH.QDH_DOCTO AND QD0.QD0_RV = QDH.QDH_RV AND QD0.QD0_FLAG <> 'I' AND "
cQuery+= "QD0.D_E_L_E_T_ <> '*'  AND "
cQuery+= "QD5.QD5_AUT = QD0.QD0_AUT AND QD5.QD5_CODTP = QDH.QDH_CODTP AND QD5.QD5_GREV='S' AND "
cQuery+= "QD5.D_E_L_E_T_ <> '*' AND "	
cQuery+= "QAA.QAA_FILIAL = QD0.QD0_FILMAT AND QAA.QAA_MAT = QD0.QD0_MAT AND "
cQuery+= QA_FilSitF(.T.,.T.) +" AND "
cQuery+= "QAA.D_E_L_E_T_ <> '*' "	
cQuery+= " ORDER BY " + SqlOrder("QDH_FILIAL+QDH_DOCTO+QDH_RV+QDH_DTLIM+QD0_FILMAT+QD0_MAT")

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TCGenQry(,,cQuery),'QDH_TRB',.F.,.T.)

TcSetField("QDH_TRB","QDH_DTLIM","D")

DbSelectArea("QDH_TRB")

cAlias:= Alias()
(cAlias)->(DbGotop())

While !Eof()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localiza Usuario Destino da Ausencia Temporaria³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aUsrAuse:=QDXLocAuse((cAlias)->QD0_FILMAT,(cAlias)->QD0_MAT,Alltrim((cAlias)->QD0_AUT))
	IF Len(aUsrAuse) > 0
		QAA->(DbSetOrder(1))
		QAA->(DbSeek(aUsrAuse[1]+aUsrAuse[2]))
		IF QA_SITFOLH()
			cFilmat := QAA->QAA_FILIAL
			cMat	:= QAA->QAA_MAT
			cRecmai	:= QAA->QAA_RECMAI
			cEmail	:= QAA->QAA_EMAIL
			cApelid := QAA->QAA_APELID
		Else
			(cAlias)->(DbSkip())				
			Loop
		Endif		
	Else
		cFilmat	:=(cAlias)->QD0_FILMAT
		cMat	:=(cAlias)->QD0_MAT
		cRecmai	:=(cAlias)->QAA_RECMAI
		cEmail	:=(cAlias)->QAA_EMAIL
		cApelid	:=(cAlias)->QAA_APELID
	Endif
		
	QDS->(DbSetOrder(1))
	If !QDS->(DbSeek(cFilmat+cMat+"P"+"VEN"+(cAlias)->QDH_DOCTO+(cAlias)->QDH_RV))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava Aviso de Documento Vencido                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QDXGvAviso("VEN",cFilmat,cMat,(cAlias)->QD0_DEPTO,(cAlias)->QDH_DOCTO,(cAlias)->QDH_RV,,(cAlias)->QDH_FILIAL)
		IF cRecmai=="1" .AND. !EMPTY(cEmail)
			cFilQD2:=IF(FWModeAccess("QD2") == "C",xFilial("QD2"),(cAlias)->QDH_FILIAL)
			FQdoTpMail(@aUsrMail,(cAlias)->QDH_DOCTO,(cAlias)->QDH_RV,(cAlias)->QDH_TITULO,cEmail,"VEN",,cApelid,cMat,,,,cFilQD2+(cAlias)->QDH_CODTP,(cAlias)->QDH_DTLIM)
		Endif
	EndIf
	
	(cAlias)->(DbSkip())
EndDo

IF Len(aUsrMail) > 0
	QaEnvMail(aUsrMail,,,,aUsrMat[5],"1")
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indices de trabalho                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAlias == "QDH_TRB"
	(cAlias)->(DbCloseArea())
EndIf
If cAlias == "TRAB"
	(cAlias)->(dbCloseArea())
EndIf
Ferase(cIndex+OrDbagExt())
Ferase(cIndex+GetDBExtension())

RestARea(aAliasAtu)
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDXLocAuse ³ Autor ³ Programacao Quality  ³ Data ³26/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indifica e Localiza o Responsavel Atual na Ausencia Tempora³±±
±±³			 ³ ria 													  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXLocAuse(FILIAL,MAT,TIPO RESPONSABILIDADE)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDXAvLim()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDXLocAuse(cFilmat,cMat,cTpRes)
Local lRet:= {}

QAF->(DbSetOrder(1))    //QAF_FILIAL+QAF_ANO+QAF_NUMERO+QAF_TPPEND+QAF_FILMAT+QAF_MAT
QAE->(DbSetOrder(2))    //QAE_FILMAT+QAE_MAT+QAE_STATUS+QAE_ANO+QAE_NUMERO
IF QAE->(DbSeek(cFilmat+cMat+"1"))
	If QAF->(DbSeek(QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO+Alltrim(cTpRes)))
		AADD(lRet,QAF->QAF_FILMAT)
		AADD(lRet,QAF->QAF_MAT   )
	Endif
Endif

Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QT_QUALITY ³ Autor ³ Telso Carneiro      ³ Data ³23/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza arquivo de Usuarios utilizado pela progr. Quality.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QT_QUALITY()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA180                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QT_QUALITY(cFilDe,cEmpDe,cMatDe,cCcDe,cFilAte,cEmpAte,cMatAte,cCcuAte,dDataTra)

Local cIntGPE 	:= GetMv("MV_QGINT",.F.,"N")
Local cEmpUsr 	:= ""
Local cFilUsr 	:= ""
Local cQAA	  	:= "QAA"
Local cQAC    	:= "QAC"
Local cQAD    	:= "QAD"
Local cQAAD   	:= "QAA"
Local cQAJ    	:= "QAJ"
Local cModoQAA	:= ""
Local cModoQAC	:= ""
Local cModoQAD	:= ""
Local cModoQAJ	:= ""
Local lOpenQaa	:= .F.
Local lOpenDQaa	:=.F.
Local lOpenQaC	:= .F.
Local lOpenQaD	:= .F.
Local cPriFil 	:= ""
Local cFilSx2 	:= SX2->(DbFilter())
Local cModoSRJ	:= ""
Local cModoCTT	:= ""
Local lRet	  	:= .T.
Local aAreaGPE	:= GetArea()
Local lDifFil 	:= .F.
Local lDifEmp 	:= .F.
Local lDifCC  	:= .F.
Local cFilQAJ 	:= ""
Local aUSRQAA 	:= {}
Local cEmpUsrD	:= ""
Local cFilUsrD	:= ""
Local cMail		:= GETMV("MV_QGEMAIL",.F.,"")
Local cSubject	:= ""
Local cMsg		:= ""
Local aUsrMail	:= {}
Local cApelido  := TRIM(UPPER(cUserName))
Local NI		:= 0
Local lOpenQaB	:= .F.
Local lOpenSrJ	:= .F.
Local lOpenCTT  := .F.
Local cModoQAB	:= ""
Local cQAB	  	:= "QAB"
Local cSRJ	  	:= "SRJ"
Local cCTT	  	:= "CTT"


__cFilAnt := cFilAnt
__cEmpAnt := cEmpAnt

IF CINTGPE == "S"
	
	DbSelectArea("SX2")
	DbClearFilter()
	DbSetOrder(1)
	
	cModoQAA:= FWModeAccess("QAA", 3)
	cModoQAC:= FWModeAccess("QAC", 3)
	cModoQAD:= FWModeAccess("QAD", 3)
	cModoSRJ:= FWModeAccess("SRJ", 3)
	cModoCTT:= FWModeAccess("CTT", 3)
	cModoQAB:= FWModeAccess("QAB", 3)
	
	lDifFil := cFilDe != cFilAte  //Trans Empresa
	lDifMat := cMatDe != cMatAte  //Trans Matricula
	lDifEmp	:= cEmpDe != cEmpAte  //Trans Empresa
	lDifCC	:= cCcDe  != cCcuAte  //Trans CC
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ABRE QAA PARA INATIVAR FUNCIONARIO NA EMPRESA/FILIAL.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEmpUsrD := cEmpDe   //DE
	cFilUsrD := cFilDe
	
	cEmpUsr  := cEmpAte  //PARA
	cFilUsr  := cFilAte
	
	DbSelectArea("QAJ")
	DbSetOrder(1)
	IF QAJ->(DbSeek(XFILIAL("QAJ")+cEmpUsrD+cFilUsrD))
		cEmpUsrD := QAJ->QAJ_EMPPAR //DE
		cFilUsrD := QAJ->QAJ_FILPAR
	Endif
	
	IF cEmpAnt <> cEmpUsrD
		IF !fAbrEmpresa("QAA",1,cEmpUsrD,cFilUsrD,@cModoQAA,"D")
			MsgAlert(OemToAnsi(STR0160)+" QAA",OemToAnsi(STR0023)) //  ### "Atencao" //"Nao foi possivel encontrar o arquivo"
			lRet:= .F.
		Else
			cQAAD    := "DQUAQAA"
			lOpenDQaa:= .T.
		Endif
	Endif
	
	IF lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ABRE QAA PARA ATIVAR O NOVO CODIGO DO FUNCIONARIO NA EMPRESA/FILIAL.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cPriFil := QXPOSFIL(cEmpUsrD)
		
		DbSelectArea("QAJ")
		DbSetOrder(1)
		IF QAJ->(DbSeek(XFILIAL("QAJ")+cEmpUsr+cFilUsr))
			cEmpUsr := QAJ->QAJ_EMPPAR
			cFilUsr := QAJ->QAJ_FILPAR
		Endif
		
		IF cEmpAnt <> cEmpUsr
			IF !fAbrEmpresa("QAJ",1,cEmpUsr,cFilUsr,@cModoQAJ)
				MSGALERT(OemToAnsi(STR0160)+ " QAJ",OemToAnsi(STR0023)) //  ### "ATENCAO" //"Nao foi possivel encontrar o arquivo"
				lRet:= .F.
			Else
				cQAJ    := "QUAQAJ"
				lOpenQaJ:= .T.
			Endif
			
			DbSelectArea(cQAJ)
			DbSetOrder(1)
			IF cMODOQAJ == "C"
				cFilQAJ:= Space(FWSizeFilial()) //"  "
			Else
				cFilQAJ:=cFilUsr
			Endif
			IF DbSeek(cFilQAJ+cEmpUsr+cFilUsr)
				cEmpUsr := (cQAJ)->QAJ_EMPPAR
				cFilUsr := (cQAJ)->QAJ_FILPAR
			Endif
			
			IF !fAbrEmpresa("QAA",1,cEmpUsr,cFilUsr,@cModoQAA)
				MSGALERT(OemToAnsi(STR0160)+ " QAA",OemToAnsi(STR0023)) // ### "ATENCAO" //"Nao foi possivel encontrar o arquivo"
				lRet:= .F.
			Else
				cQAA    := "QUAQAA"
				lOpenQaa:= .T.
			Endif
			
			IF !fAbrEmpresa("QAC",1,cEmpUsr,cFilUsr,@cModoQAC)
				MSGALERT(OemToAnsi(STR0160)+ " QAC",OemToAnsi(STR0023)) //  ### "ATENCAO" //"Nao foi possivel encontrar o arquivo"
				lRet:= .F.
			Else
				cQAC    := "QUAQAC"
				lOpenQaC:= .T.
			Endif
			IF !fAbrEmpresa("QAD",1,cEmpUsr,cFilUsr,@cModoQAD)
				MSGALERT(OemToAnsi(STR0160)+ " QAD",OemToAnsi(STR0023)) //  ### "ATENCAO" //"Nao foi possivel encontrar o arquivo"
				lRet:= .F.
			Else
				cQAD    := "QUAQAD"
				lOpenQaD:= .T.
			Endif
			
			IF !fAbrEmpresa("QAB",1,cEmpUsr,cFilUsr,@cModoQAB)
				MSGALERT(OemToAnsi(STR0160)+ " QAB",OemToAnsi(STR0023)) //  ### "ATENCAO" //"Nao foi possivel encontrar o arquivo"
				lRet:= .F.
			Else
				cQAB    := "QUAQAB"
				lOpenQaB:= .T.
			Endif
			
			IF !fAbrEmpresa("CTT",1,cEmpUsr,cFilUsr,@cModoCTT)
				MSGALERT(OemToAnsi(STR0160)+ " CTT",OemToAnsi(STR0023)) //  ### "ATENCAO" //"Nao foi possivel encontrar o arquivo"
				lRet:= .F.
			Else
				cCTT    := "QUACTT"
				lOpenCTT:= .T.
			Endif
			
			IF !fAbrEmpresa("SRJ",1,cEmpUsr,cFilUsr,@cModoSRJ)
				MSGALERT(OemToAnsi(STR0160)+ " SRJ",OemToAnsi(STR0023)) //  ### "ATENCAO" //"Nao foi possivel encontrar o arquivo"
				lRet:= .F.
			Else
				cSRJ    := "QUASRJ"
				lOpenSrJ:= .T.
			Endif
			
		Endif
	Endif
	
	IF (cModoQAC <> cModoSRJ .OR. cModoQAD <> cModoCTT)
		HELP( "", 1, "QT_QUALITY",,OemToAnsi(STR0192)+CHR(13)+OemToAnsi(STR0193),1)   //"EXISTE INCOMPATIBILIDADE DE COMPARTILHAMENTO ENTRE AS TABELAS QAC-SRJ OU QAD-CTT."###"CONTACTAR O ADMINISTRADOR DO SISTEMA"
		lRet:= .F.
	Endif
	
	If lOpenSrJ
		fFecEmpresa( cSRJ )
	EndIf
	
	If lOpenCTT
		fFecEmpresa( cCTT )
	EndIf
	
	IF lRet
		
		Begin Transaction
			DbSelectArea(cQAB)
			DbSetOrder(1)
			RecLock(cQAB,.T.)
			(cQAB)->QAB_FILIAL	:=	xFilial("QAB")
			(cQAB)->QAB_FILD	:=	cFilUsrD
			(cQAB)->QAB_MATD	:=	cEmpDe+cFilDe+cMatDe
			IF cModoQAD == "C"
				(cQAB)->QAB_CCD:= cEmpDe+cPriFil+cCcDe
			Else
				(cQAB)->QAB_CCD:=	cEmpDe+cFilDe+cCcDe
			Endif
			(cQAB)->QAB_FILP	:=  cFilUsr      // PREVER QAJ
			(cQAB)->QAB_MATP	:=	cEmpAte+cFilAte+cMatAte
			(cQAB)->QAB_DATA	:= 	dDataTra
			IF cModoQAD == "C"
				(cQAB)->QAB_CCP:= cEmpAte+cPriFil+cCcuAte
			Else
				(cQAB)->QAB_CCP:= cEmpAte+cFilAte+cCcuAte
			Endif
			(cQAB)->QAB_EMPD	:= cEmpUsrD
			(cQAB)->QAB_EMPP	:= cEmpUsr   // PREVER QAJ
			MsUnlock()
			FKCOMMIT()
			
			DO Case
				Case lDifFil .OR. lDifEmp .OR. lDifMat
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³INATIVA FUNCIONARIO NA EMPRESA/FILIAL.   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea(cQAAD)
					DbSetOrder(1)
					
					IF DbSeek((cQAB)->QAB_FILD+(cQAB)->QAB_MATD )
						For NI:=1 TO (cQAAD)->(Fcount())
							AADD(aUSRQAA,(cQAAD)->(FIELDGET(NI)))
						Next
						If lDifEmp .or. lDifFil // Somente grava o Inativo se houver movimentacao entre empresas.
							RecLock(cQAAD,.F.)
							(cQAAD)->QAA_LOGIN := ""
							(cQAAD)->QAA_APELID:= ""
							IF EMPTY((cQAAD)->QAA_FIM) .OR. (cQAAD)->QAA_STATUS== "1"
								(cQAAD)->QAA_FIM   := (cQAB)->QAB_DATA
								(cQAAD)->QAA_STATUS:= "2" //INATIVO
							Endif
							MsUnlock()
							FKCOMMIT()
						Endif	
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³  ATIVA FUNCIONARIO NA EMPRESA/FILIAL.   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF Len(aUSRQAA) > 0
						DbSelectArea(cQAA)
						DbSetOrder(1)
						
						If lDifEmp .or. lDifFil
							IF DbSeek((cQAB)->QAB_FILP+(cQAB)->QAB_MATP )
								RecLock(cQAA,.F.)
							Else
								RecLock(cQAA,.T.)
							Endif
						Else
							IF DbSeek((cQAB)->QAB_FILP+(cQAB)->QAB_MATD )
								RecLock(cQAA,.F.)
							Else
								RecLock(cQAA,.T.)
							Endif						
						Endif	
						
						For NI:=1 TO (cQAA)->(Fcount())
							cCampo:=Alltrim(Fieldname(NI))
							DO Case
								Case cCampo=="QAA_FILIAL"
									(cQAA)->QAA_FILIAL:= (cQAB)->QAB_FILP
								Case cCampo=="QAA_MAT"
									(cQAA)->QAA_MAT   := (cQAB)->QAB_MATP
								Case cCampo=="QAA_INICIO"
									(cQAA)->QAA_INICIO:= (cQAB)->QAB_DATA
								Case cCampo=="QAA_CODFUN"
									IF cModoQAC == "C"
										(cQAA)->QAA_CODFUN:= cEmpAte+cPriFil+SUBSTR(aUSRQAA[NI],5)
									Else
										(cQAA)->QAA_CODFUN:= cEmpAte+cFilAte+SUBSTR(aUSRQAA[NI],5)
									Endif
								Case cCampo=="QAA_CC"
									(cQAA)->QAA_CC:= (cQAB)->QAB_CCP
								Case cCampo=="QAA_FIM"
									(cQAA)->QAA_FIM := CTOD(SPACE(8))
								Case cCampo=="QAA_STATUS"
									(cQAA)->QAA_STATUS:= "1" //ATIVO
								Case cCampo=="QAA_TPUSR"
									(cQAA)->QAA_TPUSR := "1" //Funcionario
								Otherwise
									(cQAA)->(FieldPut(NI,aUSRQAA[NI]))
							EndCase
						Next
						MsUnlock()
						FKCOMMIT()
					Endif
					
				Case lDifCC
					DbSelectArea(cQAA)
					DbSetOrder(1)
					
					IF DbSeek((cQAB)->QAB_FILP+(cQAB)->QAB_MATP )
						RecLock(cQAA,.F.)
						(cQAA)->QAA_CC  := (cQAB)->QAB_CCP
						MsUnlock()
						FKCOMMIT()
						DbSelectArea("QD1")
						QD1->( DbSetOrder(3) )
						If QD1->( DBSEEK(cFilDe + cEmpde+cFilDE+cMatDe + "P" ) )                                                                                                      
							messagedlg(STR0211,,3)//"Foi alterado o centro de custo e há integração como o QDO, deverá transferir as pendências do SIGAQDO"
						Endif
					Endif
			EndCase
			
		End Transaction
		
		dbSelectArea(cQAB)
		IF !Empty(cMail)
			cSubject:= OemToAnsi(STR0196)+DTOC(dDataBase)+" - "+Subs(Time(),1,5) //"Tranferência de Funcionário "
			cMsg+= OemToAnsi(STR0197)+CHR(13)+CHR(10)+CHR(13)+CHR(10)  //"Foi realizado uma Transferência do Funcionário pelo módulo SIGAGPE"
			cMsg+= OemToAnsi(STR0198)+CHR(13)+CHR(10)+CHR(13)+CHR(10)  //"Verifique, se caso houver necessidade, Transfira as pendências nos módulos do SIGA-QUALITY"
			cMsg+= OemToAnsi(STR0199)+AllTrim(QA_CHKFIL((cQAB)->QAB_FILD,,.T.,cEmpDe))+" "+OemToAnsi(TitSx3("QAB_MATD")[1])+": "+(cQAB)->QAB_MATD+"  "+OemToAnsi(TitSx3("QAB_CCD")[1])+": "+(cQAB)->QAB_CCD+CHR(13)+CHR(10)+CHR(13)+CHR(10)  //"De:   "
			cMsg+= OemToAnsi(STR0200)+AllTrim(QA_CHKFIL((cQAB)->QAB_FILP,,.T.,cEmpAte))+" "+OemToAnsi(TitSx3("QAB_MATP")[1])+": "+(cQAB)->QAB_MATP+"  "+OemToAnsi(TitSx3("QAB_CCP")[1])+": "+(cQAB)->QAB_CCP+CHR(13)+CHR(10)+CHR(13)+CHR(10)  //"Para: "
			
			cMsg+= OemToAnsi(STR0083)+CHR(13)+CHR(10)//"Atenciosamente"
			cMsg+= Alltrim(cApelido)+CHR(13)+CHR(10)
			cMsg+= OemToAnsi(STR0201)  //"Mensagem gerada Automaticamente pelo SIGAGPE - Integração com o SIGA-QUALITY"
			
			aadd(aUsrMail,{ "",Trim(cMail), { { cSubject,cMsg,""   } } })
			
		Endif
		
	ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finaliza Arquivos e Indices temporarios da Empresa Destino. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lOpenDQaa
		fFecEmpresa( cQAAD )
	EndIf
	
	If lOpenQaa
		fFecEmpresa( cQAA )
	Else
		DbSelectArea(cQAA)
		DbCloseArea()
	EndIf
	
	If lOpenQaC
		fFecEmpresa( cQAC )
	Else
		DbSelectArea(cQAC)
		DbCloseArea()
	EndIf
	
	If lOpenQaD
		fFecEmpresa( cQAD )
	Else
		DbSelectArea(cQAD)
		DbCloseArea()
	EndIf
	
	If lOpenQaB
		fFecEmpresa( cQAB )
	Else
		DbSelectArea(cQAB)
		DbCloseArea()
	EndIf
	
	DbSelectArea("QAJ")
	DbCloseArea()
	
	dbSelectArea("SX2")
	Set Filter To &(cFilSx2)
	
Endif

cFilAnt := __cFilAnt
cEmpAnt := __cEmpAnt

IF LEN(aUsrMail)>0
	QaEnvMail(aUsrMail,,,,"","1")
Endif	

RestARea(aAreaGPE)

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fAbrEmpresa	  ³ Autor ³Wilson de Godoy        ³ Data ³03/01/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Abre o Arquivo da Outra Empresa                        			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cAlias - Alias do Arquivo a Ser Aberto							³
³          ³ nOrdem - Ordem do Indice              							³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fAbrEmpresa(cAlias,nOrdem,cEmpAte,cFilAte,cModo,cDif)
Local lRet
//Local cSaveE := cEmpAnt, cSaveF := cFilAnt

Default cDif := ""

IF ( lRet := MyEmpOpenFile(cDif+"QUA"+cAlias,cAlias,nOrdem,.t.,cEmpAte,@cModo) )
	dbSelectArea( cDif+"QUA"+cAlias )
Else
	MsgAlert( OemToAnsi( STR0160+" "+ cAlias )  )	//  //"Nao foi possivel encontrar o arquivo"
EndIF

Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fFecEmpresa	  ³ Autor ³Wilson de Godoy        ³ Data ³03/01/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Fecha o Arquivo da Outra Empresa                        		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cAlias - Alias do Arquivo a Ser Fechado						³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fFecEmpresa( cAlias )

IF Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIF

Return( .T. )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³MyEmpOpenFile ³ Autor ³Wilson de Godoy        ³ Data ³03/01/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Abre Arquivo de Outra Empresa                         			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³x1 - Alias com o Qual o Arquivo Sera Aberto                  	³
³          ³x2 - Alias do Arquivo Para Pesquisa e Comparacao                ³
³          ³x3 - Ordem do Arquivo a Ser Aberto                              ³
³          ³x4 - .T. Abre e .F. Fecha                                       ³
³          ³x5 - Empresa                                                    ³
³          ³x6 - Modo de Acesso (Passar por Referencia)                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MyEmpOpenFile(x1,x2,x3,x4,x5,x6)
Local cSavE := cEmpAnt, cSavF := cFilAnt, xRet
cEmpAnt := __cEmpAnt
cFilAnt := __cFilAnt
xRet	:= EmpOpenFile(@x1,@x2,@x3,@x4,@x5,@x6)
cEmpAnt := cSavE
cFilAnt := cSavF

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QA_VLUSA  ºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consistencias necessarias para tratamento de validacao de   º±±
±±º          ³usuarios - ambiente de Qualidade (QIE,QDO,QMT,PPAP,ICE,QNC  º±±
±±º          ³QAD,QIP).                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QA_VLUSA(cFilDee,cMatPara,cEmprAt)
Local lRetorno := .T.
Local cIndQArq := ""
Local aArea := GetArea()

cMatPara := cEmprAt+cFilDee+cMatPara

If ChkFile("QAD")
	dbSelectArea("QAD")              
	dbSetOrder(2)
	If dbSeek(cFilDee+cMatPara)
		lRetorno := .F.
	Endif
Endif

If ChkFile("QAE")
	If lRetorno
		dbSelectArea("QAE")
		dbSetOrder(2)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif
Endif

If ChkFile("QAF")
	If lRetorno
		dbSelectArea("QAF")
		dbSetOrder(2)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QI2")
	If lRetorno
		dbSelectArea("QI2") 
		dbSetOrder(4)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	


	If lRetorno
		dbSelectArea("QI2") 
		dbSetOrder(6)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QI3")
	If lRetorno
		dbSelectArea("QI3") 
		dbSetOrder(3)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif            

If ChkFile("QI4")
	If lRetorno
		dbSelectArea("QI4") 
		dbSetOrder(2)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QI5")
	If lRetorno
		dbSelectArea("QI5") 
		dbSetOrder(2)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif
If ChkFile("QIE")
	If lRetorno
		dbSelectArea("QIE") 
		dbSetOrder(2)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QIF")
	If lRetorno
		dbSelectArea("QIF") 
		dbSetOrder(2)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QD1")
	If lRetorno
		dbSelectArea("QD1")
		dbSetOrder(3)
		If dbSeek(cFildee+cMatPara)
			lRetorno := .F.
		Endif
	Endif
Endif
If ChkFile("QDG")
	If lRetorno
		dbSelectArea("QDG")
		dbSetOrder(8)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QDS")
	If lRetorno
		dbSelectArea("QDS")
		dbSetOrder(1)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QF2")
	If lRetorno
		dbSelectArea("QF2")
		dbSetOrder(3)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QF3")
	If lRetorno
		dbSelectArea("QF3")
		dbSetOrder(4)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QIG")
	If lRetorno
		dbSelectArea("QIG") 
		dbSetOrder(2)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QAG")
	If lRetorno
		
		cIndQArq := CriaTrab(NIL,.F.)
		
		dbSelectArea("QAG")
		
		cKey := "QAG_FILMAT+QAG_MAT"
		cFiltro := "QAG->QAG_FILMAT+QAG->QAG_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QAG",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QAG..."
		If QAG->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif	
Endif

If ChkFile("QD0")
	If lRetorno
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QD0")
		
		cKey := "QD0_FILMAT+QD0_MAT"
		cFiltro := "QD0->QD0_FILMAT+QD0->QD0_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QD0",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QD0..."
		If QD0->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif	
Endif

If ChkFile("QD1")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QD1")
	
		cKey := "QD1_FMATBX+QD1_MATBX"
		cFiltro := "QD1->QD1_FMATBX+QD1->QD1_MATBX == '"+cFildee+cMatPara+"'"
	
		IndRegua("QD1",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QD1..."
		If QD1->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QD4")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QD4")
	
		cKey := "QD4_FILMAT+QD4_MAT"
		cFiltro := "QD4->QD4_FILMAT+QD4->QD4_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QD4",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QD4..."
		If QD4->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QD4")
	
		cKey := "QD4_FMATBX+QD4_MATBX"
		cFiltro := "QD4->QD4_FMATBX+QD4->QD4_MATBX == '"+cFildee+cMatPara+"'"
	
		IndRegua("QD4",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QD4..."
		If QD4->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QD7")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QD7")
	
		cKey := "QD7_FILMAT+QD7_MAT"
		cFiltro := "QD7->QD7_FILMAT+QD7->QD7_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QD7",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QD7..."
		If QD7->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QD8")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QD8")
	
		cKey := "QD8_FILMAT+QD8_MAT"
		cFiltro := "QD8->QD8_FILMAT+QD8->QD8_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QD8",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QD8..."
		If QD8->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QD9")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QD9")
	
		cKey := "QD9_FILMAT+QD9_MAT"
		cFiltro := "QD9->QD9_FILMAT+QD9->QD9_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QD9",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QD9..."
		If QD9->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDA")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDA")
	
		cKey := "QDA_FILF1+QDA_MAT1"
		cFiltro := "QDA->QDA_FILF1+QDA->QDA_MAT1 == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDA",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDA..."
		If QDA->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDA")
	
		cKey := "QDA_FILF2+QDA_MAT2"
		cFiltro := "QDA->QDA_FILF2+QDA->QDA_MAT2 == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDA",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDA..."
		If QDA->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDA")
	
		cKey := "QDA_FILF3+QDA_MAT3"
		cFiltro := "QDA->QDA_FILF3+QDA->QDA_MAT3 == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDA",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDA..."
		If QDA->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
	
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDE")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDE")
	
		cKey := "QDE_FILSOL+QDE_MATSOL"
		cFiltro := "QDE->QDE_FILSOL+QDE->QDE_MATSOL == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDE",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDE..."
		If QDE->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif

	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDE")
	
		cKey := "QDE_FILDES+QDE_MATDES"
		cFiltro := "QDE->QDE_FILDES+QDE->QDE_MATDES == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDE",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDE..."
		If QDE->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDE")
	
		cKey := "QDE_FILDES+QDE_MATDES"
		cFiltro := "QDE->QDE_FILDES+QDE->QDE_MATDES == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDE",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDE..."
		If QDE->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDF")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDF")
	
		cKey := "QDF_FILANT+QDF_MATANT"
		cFiltro := "QDF->QDF_FILANT+QDF->QDF_MATANT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDF",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDF..."
		If QDF->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
	
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDF")
	
		cKey := "QDF_FILNOV+QDF_MATNOV"
		cFiltro := "QDF->QDF_FILNOV+QDF->QDF_MATNOV == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDF",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDF..."
		If QDF->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDF")
	
		cKey := "QDF_FILOP+QDF_MATOP"
		cFiltro := "QDF->QDF_FILOP+QDF->QDF_MATOP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDF",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDF..."
		If QDF->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDH")

	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDH")
	
		cKey := "QDH_FILMAT+QDH_MAT"
		cFiltro := "QDH->QDH_FILMAT+QDH->QDH_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDH",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDH..."
		If QDH->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDN")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDN")
	
		cKey := "QDN_FILMAT+QDN_MAT"
		cFiltro := "QDN->QDN_FILMAT+QDN->QDN_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDN",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDN..."
		If QDN->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDP")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDP")
	
		cKey := "QDP_FILMAT+QDP_MAT"
		cFiltro := "QDP->QDP_FILMAT+QDP->QDP_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDP",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDP..."
		If QDP->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDP")
	
		cKey := "QDP_FILMAT+QDP_MAT"
		cFiltro := "QDP->QDP_FMATBX+QDP->QDP_MATBX == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDP",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDP..."
		If QDP->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDR")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDR")
	
		cKey := "QDR_FILRES+QDR_MATRES"
		cFiltro := "QDR->QDR_FILRES+QDR->QDR_MATRES == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDR",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDR..."
		If QDR->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDR")
	
		cKey := "QDR_FILDE+QDR_MATDE"
		cFiltro := "QDR->QDR_FILDE+QDR->QDR_MATDE == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDR",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDR..."
		If QDR->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDR")
	
		cKey := "QDR_FILPAR+QDR_MATPAR"
		cFiltro := "QDR->QDR_FILPAR+QDR->QDR_MATPAR == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDR",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDR..."
		If QDR->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDS")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDS")
	
		cKey := "QDS_FMATBX+QDS_MATBX"
		cFiltro := "QDS->QDS_FMATBX+QDS->QDS_MATBX == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDS",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDS..."
		If QDS->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDU")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDU")
	
		cKey := "QDU_FILMAT+QDU_MAT"
		cFiltro := "QDU->QDU_FILMAT+QDU->QDU_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDU",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDU..."
		If QDU->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDU")
	
		cKey := "QDU_FMATBX+QDU_MATBX"
		cFiltro := "QDU->QDU_FMATBX+QDU->QDU_MATBX == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDU",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDU..."
		If QDU->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QDZ")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QDZ")
	
		cKey := "QDZ_FILMAT+QDZ_MAT"
		cFiltro := "QDZ->QDZ_FILMAT+QDZ->QDZ_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QDZ",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QDZ..."
		If QDZ->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif          

If ChkFile("QF7")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QF7")
	
		cKey := "QF7_FILMAT+QF7_MAT"
		cFiltro := "QF7->QF7_FILMAT+QF7->QF7_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QF7",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QF7..."
		If QF7->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QIG")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QIG")
	
		cKey := "QIG_FILRES+QIG_MATRES"
		cFiltro := "QIG->QIG_FILRES+QIG->QIG_MATRES == '"+cFildee+cMatPara+"'"
	
		IndRegua("QIG",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QIG..."
		If QIG->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
		dbSelectArea("QIG") 
		dbSetOrder(1)
		If dbSeek(cFilDee+cMatPara)
			lRetorno := .F.
		Endif	
	Endif	
Endif

If ChkFile("QKE")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKE")
	
		cKey := "QKE_FILMAT+QKE_MAT"
		cFiltro := "QKE->QKE_FILMAT+QKE->QKE_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKE",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKE..."
		If QKE->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKI")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKI")
	
		cKey := "QKI_FILMAT+QKI_MAT"
		cFiltro := "QKI->QKI_FILMAT+QKI->QKI_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKI",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKI..."
		If QKI->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKP")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKP")
	
		cKey := "QKP_FILMAT+QKP_MAT"
		cFiltro := "QKP->QKP_FILMAT+QKP->QKP_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKP",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKP..."
		If QKP->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QQJ")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QQJ")
	
		cKey := "QQJ_FILMAT+QQJ_MAT"
		cFiltro := "QQJ->QQJ_FILMAT+QQJ->QQJ_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QQJ",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QQJ..."
		If QQJ->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QUA")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QUA")
	
		cKey := "QUA_FILMAT+QUA_MAT"
		cFiltro := "QUA->QUA_FILMAT+QUA->QUA_MAT == '"+cFildee+cMatPara+"'"
	
		IndRegua("QUA",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QUA..."
		If QUA->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif
If ChkFile("QUN")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QUN")
	
		cKey := "QUN_FILRES+QUN_MATRES"
		cFiltro := "QUN->QUN_FILRES+QUN->QUN_MATRES == '"+cFildee+cMatPara+"'"
	
		IndRegua("QUN",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QUN..."
		If QUN->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QUN")
	
		cKey := "QUN_FILDE+QUN_MATDE"
		cFiltro := "QUN->QUN_FILDE+QUN->QUN_MATDE == '"+cFildee+cMatPara+"'"
	
		IndRegua("QUN",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QUN..."
		If QUN->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QUN")
	
		cKey := "QUN_FILPAR+QUN_MATPAR"
		cFiltro := "QUN->QUN_FILPAR+QUN->QUN_MATPAR == '"+cFildee+cMatPara+"'"
	
		IndRegua("QUN",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QUN..."
		If QUN->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QE5")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QE5")
	
		cKey := "QE5_FILRES+QE5_RESPON"
		cFiltro := "QE5->QE5_FILRES+QE5->QE5_RESPON == '"+cFildee+cMatPara+"'"
	
		IndRegua("QE5",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QE5..."
		If QE5->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QEK")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QEK")
	
		cKey := "QEK_FILMAT+QEK_SOLIC"
		cFiltro := "QEK->QEK_FILMAT+QEK->QEK_SOLIC == '"+cFildee+cMatPara+"'"
	
		IndRegua("QEK",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QEK..."
		If QEK->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKG")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKG")
	
		cKey := "QKG_FILRES+QKG_RESP"
		cFiltro := "QKG->QKG_FILRES+QKG->QKG_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKG",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKG..."
		If QKG->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKQ")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKQ")
	
		cKey := "QKQ_FILRES+QKQ_RESP"
		cFiltro := "QKQ->QKQ_FILRES+QKQ->QKQ_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKQ",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKQ..."
		If QKG->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKR")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKR")
	
		cKey := "QKR_FILRES+QKR_RESP"
		cFiltro := "QKR->QKR_FILRES+QKR->QKR_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKR",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKR..."
		If QKR->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKT")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKT")
	
		cKey := "QKT_FILRES+QKT_RESP"
		cFiltro := "QKT->QKT_FILRES+QKT->QKT_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKT",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKT..."
		If QKT->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKU")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKU")
	
		cKey := "QKU_FILRES+QKU_RESP"
		cFiltro := "QKU->QKU_FILRES+QKU->QKU_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKU",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKU..."
		If QKU->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKV")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKV")
	
		cKey := "QKV_FILRES+QKV_RESP"
		cFiltro := "QKV->QKV_FILRES+QKV->QKV_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKV",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKV..."
		If QKV->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKW")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKW")
	
		cKey := "QKW_FILRES+QKW_RESP"
		cFiltro := "QKW->QKW_FILRES+QKW->QKW_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKW",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKW..."
		If QKW->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKX")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKX")
	
		cKey := "QKX_FILRES+QKX_RESP"
		cFiltro := "QKX->QKX_FILRES+QKX->QKX_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKX",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKX..."
		If QKX->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QKY")

	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKY")
	
		cKey := "QKY_FILRES+QKY_RESP1"
		cFiltro := "QKY->QKY_FILRES+QKY->QKY_RESP1 == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKY",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKY..."
		If QKY->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif


	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKY")
	
		cKey := "QKY_FILRES+QKY_RESP2"
		cFiltro := "QKY->QKY_FILRES+QKY->QKY_RESP2 == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKY",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKY..."
		If QKY->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
	
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QKY")
	
		cKey := "QKY_FILRES+QKY_RESP3"
		cFiltro := "QKY->QKY_FILRES+QKY->QKY_RESP3 == '"+cFildee+cMatPara+"'"
	
		IndRegua("QKY",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QKY..."
		If QKY->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif          

If ChkFile("QM2")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QM2")
	
		cKey := "QM2_FILRES+QM2_RESP"
		cFiltro := "QM2->QM2_FILRES+QM2->QM2_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QM2",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QM2..."
		If QM2->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QM6")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QM6")
	
		cKey := "QM6_FILRES+QM6_RESP"
		cFiltro := "QM6->QM6_FILRES+QM6->QM6_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QM6",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QM6..."
		If QM6->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QMD")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QMD")
	
		cKey := "QMD_FILRES+QMD_RESP"
		cFiltro := "QMD->QMD_FILRES+QMD->QMD_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QMD",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QMD..."
		If QMD->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QME")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QME")
	
		cKey := "QME_FILRES+QME_RESP"
		cFiltro := "QME->QME_FILRES+QME->QME_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QME",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QME..."
		If QME->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QMU")

	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QMU")
	
		cKey := "QMU_FILRES+QMU_RESP"
		cFiltro := "QMU->QMU_FILRES+QMU->QMU_RESP == '"+cFildee+cMatPara+"'"
	
		IndRegua("QMU",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QMU..."
		If QMU->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif

If ChkFile("QP5")
	If lRetorno
	
		cIndQArq := CriaTrab(NIL,.F.)
	
		dbSelectArea("QP5")
	
		cKey := "QP5_FILMAT+QP5_RESPON"
		cFiltro := "QP5->QP5_FILMAT+QP5->QP5_RESPON == '"+cFildee+cMatPara+"'"
	
		IndRegua("QP5",cIndQArq,cKey,,cFiltro,STR0208+Alias()) //"Selecionando Registro no QP5..."
		If QP5->(!Eof())
			If dbSeek(cFilDee+cMatPara)
				lRetorno := .F.
			Endif	
		Endif
		Set Filter to
		cIndQArq += OrDbagExt()
		Delete File &(cIndQArq)
	Endif
Endif
//Caso tenha pelo menos uma movimentacao no ambiente de Qualidade, nao permite a transferencia de codigo de usuario...
If !lRetorno .and. !Empty(cMatAte)
	MsgInfo(OemToAnsi(STR0208)+Alltrim(cMatAte)+OemToAnsi(STR0209)) //"Nao e possivel realizar a transferencia para o codigo: . Existe(m) movimento(s) no ambiente Quality para esta matricula!"
	lRetorno := .F.
Endif

RestArea(aArea)

Return lRetorno  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOXFUN   ºAutor  ³Renata Cavalcante   º Data ³  03/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação para exclusão do Departamento no Quality          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Validação para exclusão do Departamento no Quality         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QVALDELCC(cCusto)  
Local aSaveArea	:= GetArea()
Local lRet		:= .T.   
Local cMsg		:=STR0212//"Devido a integração com o Quality não poderá excluir pois o departamento está sendo utilizado no(s) cadastro(s): "

               
dbSelectArea("QAA")	//Verifico o cadastro de usuários
DbSetOrder(2)		
If MsSeek(xFilial("QAA")+cEmpAnt+cFilAnt+cCusto)
	lRet	:= .F.            
	cMsg+= STR0213 //"Usuário    "
EndIf 
dbSelectArea("QDT")	//Verifico a tabela de Amarração Pastas X Departamentos
DbSetOrder(1)		
If MsSeek(xFilial("QAD")+cEmpAnt+cFilAnt+cCusto)
	lRet	:= .F.            
	cMsg+= STR0214//"Pastas    "
EndIf 
   
DbSelectArea("QM2") // Verifico o cadastro de instrumentos

cArquivo := CriaTrab(,.F.)
cChave := "QM2_FILIAL+QM2_DEPTO"
IndRegua("QM2",cArquivo,cChave,,)
DbSelectArea("QM2")
nIndex := RetIndex("QM2")

DbSetOrder(nIndex+1)
If MsSeek(xFilial("QM2")+cEmpAnt+cFilAnt+cCusto)
	lRet	:= .F.            
	cMsg+= STR0215//"Instrumentos    "
EndIf 
FErase(cArquivo+OrdBagExt())
	

DbSelectArea("QML") // Verifico a movimentação do Metrologia
cArquivo := CriaTrab(,.F.)
cChave := "QML_FILIAL+QML_DEPTO"
IndRegua("QML",cArquivo,cChave,,)
DbSelectArea("QML")
nIndex := RetIndex("QML")
DbSetOrder(nIndex+1)
If MsSeek(xFilial("QML")+cEmpAnt+cFilAnt+cCusto)
	lRet	:= .F.            
	cMsg+= STR0216//"Movimentações do Metrologia"
EndIf 
   

FErase(cArquivo+OrdBagExt())

If !lRet
	MessageDlg(cMsg)
Endif
RestArea(aSaveArea)                                      	

Return(lRet)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    | QDXVLREV  ³ Autor ³ Paulo Fco. Cruz Neto ³ Data ³ 29/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao para impossibilitar o preenchimento do caracter  ³±±
±±³          ³ "-" em campos de revisão do QDO.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXVLREV(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Revisao do documento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QDOA050 e QDOA090                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QDXVLREV(cRevisao)
Local lRet		 := .T.
Default cRevisao := ""

If ValType(cRevisao) == "U"
	cRevisao = ""
EndIf

lRet := If (At("-",cRevisao) > 0,.F.,.T.)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    | QDXVGFUT  ³ Autor ³ Paulo Fco. Cruz Neto ³ Data ³ 01/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua a passagem de vigencia para documentos com vigencia ³±±
±±³          ³ futura.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDXVGFUT(ExpD1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpD1 = Data base para filtrar os documentos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QDOA050 e QDOA090                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QDXVGFUT(dDataUsar)

Local cQuery  := ""
Local cAlias  := CriaTrab(Nil,.F.)
Local nDiasT  := GetMV("MV_QDIATR")

cQuery := "SELECT QDH.QDH_FILIAL,QDH.QDH_DOCTO,QDH.QDH_RV,QDH.QDH_STATUS,"
cQuery += "QDH.QDH_DTLIM,QDH.QDH_OBSOL,QDH.QDH_CANCEL,QDH.QDH_FUTURA,QDH.R_E_C_N_O_ RECNO "
cQuery += "FROM " + RetSqlName("QDH") + " QDH "
cQuery += "WHERE QDH.QDH_STATUS = 'L  ' AND QDH.QDH_FUTURA = 'R' AND "
cQuery += "QDH.QDH_DTLIM <> '        ' AND QDH.QDH_DTLIM < '" + DtoS(dDataUsar + nDiasT) + "' AND "
cQuery += "QDH.QDH_OBSOL <> 'S' AND QDH.QDH_CANCEL <> 'S' AND QDH.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY " + SqlOrder("QDH_DTLIM")

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)

DbSelectArea(cAlias)
(cAlias)->(DbGotop())
While (cAlias)->(!Eof())
	QDH->(DbGoto((cAlias)->RECNO))
	If 	QDH->QDH_FUTURA = "R" .And. QDH->QDH_DTLIM - nDiasT < dDataUsar
		RecLock("QDH",.F.)
		QDH->QDH_FUTURA := " "
		QDH->QDH_OBSOL  := "S"
		QDH->(MsUnlock())
		FKCOMMIT()
		QDH->(DbSkip())
		If QDH->QDH_FUTURA = "G"
			RecLock("QDH",.F.)
			QDH->QDH_FUTURA := " "
			QDH->(MsUnlock())
			FKCOMMIT()
		Endif
		
	   	(cAlias)->(DbSkip())
		Loop
	Endif
	(cAlias)->(DbSkip())
EndDo
(cAlias)->(dbCloseArea())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOXFUN   ºAutor  ³Renata Cavalcante   º Data ³  03/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação para exclusão de Usuários no Quality              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Validação para exclusão de Usuários no Quality             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QVALDELUSU(cUsr)  
Local aSaveArea	:= GetArea()
Local lRet		:= .T.   
Local cMsg		:=STR0217 //"Devido a integração com o Quality não poderá excluir pois o Usuário está sendo utilizado "

               
DbSelectArea("QPR") 

cArquivo := CriaTrab(,.F.)
cChave := "QPR_FILIAL+QPR_ENSR"
IndRegua("QPR",cArquivo,cChave,,)
DbSelectArea("QPR")
nIndex := RetIndex("QPR")

DbSetOrder(nIndex+1)
If MsSeek(xFilial("QPR")+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0218)//"nos Resultados do Inspeção de Processos"
	RestArea(aSaveArea) 
	Return(.F.)
EndIf 
FErase(cArquivo+OrdBagExt())

DbSelectArea("QER") 
cArquivo := CriaTrab(,.F.)
cChave := "QER_FILIAL+QER_ENSR"
IndRegua("QER",cArquivo,cChave,,)
DbSelectArea("QER")
nIndex := RetIndex("QER")

DbSetOrder(nIndex+1)
If MsSeek(xFilial("QER")+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0219)//"nos Resultados do Inspeção de Entradas"
	RestArea(aSaveArea) 
	Return(.F.)          
EndIf 
FErase(cArquivo+OrdBagExt())  

DbSelectArea("QM2") // Verifico o cadastro de instrumentos

cArquivo := CriaTrab(,.F.)
cChave := "QM2_FILRES+QM2_RESP"
IndRegua("QM2",cArquivo,cChave,,)
DbSelectArea("QM2")
nIndex := RetIndex("QM2")

DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0220)//"no Cadastro de Instrumentos"
	RestArea(aSaveArea) 
	Return(.F.)  
EndIf 
FErase(cArquivo+OrdBagExt())

	
DbSelectArea("QM6") // Verifico o cadastro de instrumentos

cArquivo := CriaTrab(,.F.)
cChave := "QM6_FILRES+QM6_RESP"
IndRegua("QM6",cArquivo,cChave,,)
DbSelectArea("QM6")
nIndex := RetIndex("QM6")

DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0221)//"na Calibração de Instrumentos"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())
	

DbSelectArea("QM4") // Verifico a movimentação do Metrologia
cArquivo := CriaTrab(,.F.)
cChave := "QM4_FILIAL+QM4_RESP"
IndRegua("QM4",cArquivo,cChave,,)
DbSelectArea("QM4")
nIndex := RetIndex("QM4")
DbSetOrder(nIndex+1)
If MsSeek(xFilial("QM4")+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0222)//"na Repetibilidade e Reprodutibilidade"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())

DbSelectArea("QME")
cArquivo := CriaTrab(,.F.)
cChave := "QME_FILIAL+QME_RESP"
IndRegua("QME",cArquivo,cChave,,)
DbSelectArea("QME")
nIndex := RetIndex("QME")
DbSetOrder(nIndex+1)
If MsSeek(xFilial("QME")+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0223)//"nas Manutenções do Metrologia"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())        

DbSelectArea("QMU") 
cArquivo := CriaTrab(,.F.)
cChave := "QMU_FILIAL+QMU_RESP"
IndRegua("QMU",cArquivo,cChave,,)
DbSelectArea("QMU")
nIndex := RetIndex("QMU")
DbSetOrder(nIndex+1)
If MsSeek(xFilial("QMU")+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0224)//"no MSA"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())   

DbSelectArea("QD0") 
cArquivo := CriaTrab(,.F.)
cChave := "QD0_FILMAT+QD0_MAT"
IndRegua("QD0",cArquivo,cChave,,)
DbSelectArea("QD0")
nIndex := RetIndex("QD0")
DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0225)//"no cadastro de Responsáveis do Controle de Documentos"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())         

dbSelectArea("QD1")	//Verifico o cadastro de usuários
DbSetOrder(3)		
If MsSeek(xFilial("QD1")+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0226)//"na Distruição por usuário do Controle de Documentos"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 

DbSelectArea("QDD") 
cArquivo := CriaTrab(,.F.)
cChave := "QDD_FILA+QDD_AUT"
IndRegua("QDD",cArquivo,cChave,,)
DbSelectArea("QDD")
nIndex := RetIndex("QDD")
DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0227)//"no cadastro de Responsáveis por tipo de Documento"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())                  

DbSelectArea("QDG") 
cArquivo := CriaTrab(,.F.)
cChave := "QDG_FILMAT+QDG_MAT"
IndRegua("QDG",cArquivo,cChave,,)
DbSelectArea("QDG")
nIndex := RetIndex("QDG")
DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0228)//"nos Destinatários do Controle de Documentos"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())       

DbSelectArea("QUB") 
cArquivo := CriaTrab(,.F.)
cChave := "QUB_FILMAT+QUB_AUDLID"
IndRegua("QUB",cArquivo,cChave,,)
DbSelectArea("QUB")
nIndex := RetIndex("QUB")
DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0229)//"nas Auditorias"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())   

DbSelectArea("QUH") 
cArquivo := CriaTrab(,.F.)
cChave := "QUH_FILMAT+QUH_CODAUD"
IndRegua("QUH",cArquivo,cChave,,)
DbSelectArea("QUH")
nIndex := RetIndex("QUH")
DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0230)//"nas Áreas Auditadas"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())        


dbSelectArea("QI2")	
DbSetOrder(4)		
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0232)//"nas Não Conformidades"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf                                  

dbSelectArea("QI3")	
DbSetOrder(3)		
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0233)//"nos Planos de Ações"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf   
    
dbSelectArea("QI5")
DbSetOrder(2)		
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0234)//"nas Etapas dos Planos de Ações"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf                             

DbSelectArea("QKG") 
cArquivo := CriaTrab(,.F.)
cChave := "QKG_FILRES+QKG_RESP"
IndRegua("QKG",cArquivo,cChave,,)
DbSelectArea("QKG")
nIndex := RetIndex("QKG")
DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0235)//"nos Cronogramas do PPAP"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())      

dbSelectArea("QKP")	
DbSetOrder(2)		
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0236)//"nas Etapas dos Cronogramas do PPAP"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf                      

DbSelectArea("QKI") 
cArquivo := CriaTrab(,.F.)
cChave := "QKI_FILMAT+QKI_MAT"
IndRegua("QKI",cArquivo,cChave,,)
DbSelectArea("QKI")
nIndex := RetIndex("QKI")
DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0237)//"no Certif. Submissão"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt()) 

DbSelectArea("QKE") 
cArquivo := CriaTrab(,.F.)
cChave := "QKE_FILMAT+QKE_MAT"
IndRegua("QKE",cArquivo,cChave,,)
DbSelectArea("QKE")
nIndex := RetIndex("QKE")
DbSetOrder(nIndex+1)
If MsSeek(cFilAnt+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0238)//"na Equipe Multifuncional"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf 
FErase(cArquivo+OrdBagExt())      
     
dbSelectArea("IC2")	
DbSetOrder(2)		
If MsSeek(xFilial("IC2")+cEmpAnt+cFilAnt+cUsr)
	Messagedlg(cMsg+STR0239)//"no Comitê do ICE"
	RestArea(aSaveArea) 
	Return(.F.)     
EndIf                

RestArea(aSaveArea)                                      	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOUpdConjºAutor  ³Denis Martins       º Data ³  03/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza compatibilizacao de Gestao Corporativa na integracaoº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CONFIGURADOR                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QDOUpdFConj()
Local aFields := {}

If FINDFUNCTION( 'QLTFieldRH' )

	aFields := QLTFieldRH()

EndIf

Return aFields


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VerifDel  º Autor ³ Rafael Duram Santos º Data ³ 18.08.2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o registro da tabela QDH existe mas foi deletadoº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Static Function VerifDel(cDoc)

Local lRetorno := .F.

aARea:= GetArea()
cQuery := "SELECT DISTINCT QDH.QDH_FILIAL, QDH.QDH_DOCTO FROM "+RetSqlName("QDH")+" QDH "
cQuery += "WHERE QDH.QDH_FILIAL = '"+M->QDH_FILIAL+"' AND QDH.QDH_DOCTO = '"+cDoc+"'"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TCGenQry(,,cQuery),'QDH_VDEL',.F.,.T.)
			
DbSelectArea("QDH_VDEL")
QDH_VDEL->(DbGotop())
If QDH_VDEL->(!EOF())
	lRetorno := .T.
Endif
DbCloseArea()         									
RestArea(aARea)				
		
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FilPesqQDD º Autor ³ Rafael Duram Santos º Data ³ 30.05.2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Filial correta para consulta padrao de 		      º±±
±±º		      ³ Departamento (QDD) de acordo com o campo que aciona o SXB.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Function FilPesqQDD()

Local cRotina := Alltrim(FunName())
Local cCampo  := ""	
Local nPos

Static cRetQDD

If !Empty(ReadVar())
	If cRotina == 'QAXA010'
		cRetQDD := cCcFilial
	Elseif cRotina == 'QDOA020'
		cCampo := ReadVar()
		If cCampo == 'M->QDD_DEPTOA' .Or. cCampo == 'M->QDD_CARGOA'
		    nPos := aScan(aHeader, { |x| AllTrim(x[2]) == "QDD_FILA" })
		    cRetQDD := aCols[n][nPos]  //Valor do campo Filial 
		Elseif cCampo == 'M->QD2_DEPTO'
			cRetQDD := M->QD2_FILDEP
		Endif	
	Elseif cRotina == 'QDOA040'
		If FWModeAccess("QDC",3) == "C" //1=Empresa, 2=Unidade de Negócio e 3=Filial
            cRetQDD := xFilial("QAD")
        Else
            cRetQDD := xFilial("QAD", M->QDT_FILDEP)
        EndIf
	Elseif cRotina == 'QNCA040'
		cCampo := ReadVar()
		If  cCampo == 'M->QI2_ORIDEP'
			cRetQDD := M->QI2_FILORI
		Elseif cCampo == 'M->QI2_DESDEP'
			cRetQDD := M->QI2_FILDEP
		Endif
	Elseif IsInCallStack("QDOA053")
		cRetQDD := cFilDept
	Elseif cRotina == 'QDOA110'
		cRetQDD := cFildep	
	Else
		cRetQDD := xFilial('QAD')
	Endif
EndIf

Return cRetQDD

/*/{Protheus.doc} fValdTAM
Função que valida se os campos de departamentos estão com os tamanhos corretos e sugere aplicar o diferencial
@type  Static Function
@author user
@since 24/08/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function fValdTAM()

Local nX        := 0 
Local lRetSX3   := .F.
Local lRetSXG   := .F.
Local cTamanho  := FWSizeFilial()-2 // Tamanho da filial - 2 digitos em branco
Local cTexto    := STR0242+Chr(13)+Chr(10)
Local aFields   := FWSX3Util():GetAllGroupFields("146") // Retorna o campos que estão vinculados ao grupo de campo
Local aTamField := {"QAA_CC","QAB_CCD","QAB_CCP","QAD_CUSTO","QD0_DEPTO","QD1_DEPTO","QD1_DEPBX","QD2_DEPTO",;
					"QD2_MODELO","QD4_DEPBX","QD8_DEPTO","QDD_DEPTOA","QDG_DEPTO","QDH_DEPTOD","QDH_DEPTOE",;
					"QDJ_DEPTO","QDL_DEPTO","QDM_DEPTO","QDN_DEPTO","QDP_DEPTO","QDP_DEPBX","QDR_DEPRES","QDR_DEPDE",;
					"QDR_DEPPAR","QDS_DEPTO","QDS_DEPBX","QDT_DEPTO","QDU_DEPTO","QDU_DEPBX","QDZ_DEPTO"}

// Verificar se algum campo de Departamento no Qualidade está menor que o tamanho fixo 20 caracteres + o tamanho da filial
For nX := 1 To Len(aTamField)			
	If FWTamSX3(aTamField[nX])[1] < 20 + cTamanho
		lRetSX3 := .T.	
		cTexto += STR0243 + " "+cValToChar(20 + cTamanho)
		Exit
	Endif
Next nX

// Verificar se algum campo relacionado com o grupo de campos 146 - Departamento
For nX := 1 To Len(aTamField)			
	If (aScan(aFields,{|x| x == aTamField[nX]} )) > 0
		lRetSXG := .T.	
		cTexto += Chr(13)+Chr(10)+STR0244
		Exit
	Endif
Next nX

If lRetSX3 .Or. lRetSXG

	cTexto += Chr(13)+Chr(10)+Chr(13)+Chr(10)+STR0245

	//Foi identificada duas divergências no dicionário: //- Os campos de Departamento estão menores que 26. //- O grupo de Campos 146 foi descontinuado mas permanece ativo nos campos de Departamento. //Perante estas incositências aconselhamos que seja aplicado o diferencial para equalizar o dicionário e evitar futuros erros de cadastros, gostaria de atualizar neste momento ?
	If MsgYesNo(cTexto, STR0246)
        ShellExecute( "Open", "https://suporte.totvs.com/portal/p/10098/download?e=970140", "", "", 1 )
    EndIf	
Endif

Return NIL

/*/{Protheus.doc} SXBFilQDH
Retorna Se Deve Exibir ou Não o Registro da QDH na Consulta Padrão (QDT,...)
@author brunno.costa
@since 24/08/2021
@return lExibe, lógico, indica se exibe o registro posicionado da QDH na consulta padrão
/*/
Function SXBFilQDH()
	Local lExibe      := .T.
	Static cRotiXBQDH := Nil

	If cRotiXBQDH == Nil
		cRotiXBQDH := Alltrim(FunName())
	EndIf

	If cRotiXBQDH == 'QDOA080'
		lExibe := QDH->(QDH_CANCEL<>"S".AND.QDH_OBSOL<>"S")
	Else
		lExibe := QDH->(QDH_CANCEL<>"S".AND.QDH_OBSOL<>"S".AND.QDH_STATUS=="L  ")
	Endif

Return lExibe

/*/{Protheus.doc} ValidQDO
Validações Padrões do Ambiente SIGAQDO
@since 22/02/2022
@version P12.1.37
@param 01 - oQLTManager, objeto, instancia da classe QLTQueryManager
@param 02 - aMsgErro   , array , array com as mensagens de erro para arquivamento no log
/*/
Static Function ValidQDO(oQLTManager, aMsgErro)

	Local lHelpQADQDC := .F.
	Local nTamEmp     := 0
	Local nTamFil     := 0
	Local nTamUnid    := 0

	oQLTManager:ValidaMesmosCompartilhamentos({'QDH','QD0','QD1','QD2','QD4','QD5','QD6','QD7','QD8','QD9','QDA','QDB','QDD','QDE','QDF','QDG','QDJ','QDL','QDM','QDN','QDP','QDR','QDS','QDU','QDZ','QAG','QAH','QAI'}, "QDH", .T.)
	oQLTManager:ValidaCompartilhamentoEspecifico("QAA", "E", "E", "E", .T.)
	oQLTManager:ValidaCompartilhamentoEspecifico("QAB", "E", "E", "E", .T.)
	oQLTManager:RetornaTamanhosLayout(@nTamEmp, @nTamUnid, @nTamFil)
	aMsgErro := oQLTManager:aMsgErro

	If nTamFil > 0 .AND. FWModeAccess("QAD", 3) == "C"
		If FWModeAccess("QDC", 3) == "E"
			lHelpQADQDC := .T.
		EndIf
	EndIf

	If nTamUnid > 0 .AND. !lHelpQADQDC .AND. FWModeAccess("QAD", 2) == "C"
		If FWModeAccess("QDC", 2) == "E"
			lHelpQADQDC := .T.
		EndIf
	EndIf

	If nTamEmp > 0 .AND. !lHelpQADQDC .AND. FWModeAccess("QAD", 1) == "C"
		If FWModeAccess("QDC", 1) == "E"
			lHelpQADQDC := .T.
		EndIf
	EndIf

	If lHelpQADQDC
		//STR0001 - Atenção
		//STR0249 - Quando a situação da tabela “QAD” (Departamentos/Setor) estiver Compartilhada a tabela “QDC” (Cadastros de Pastas) não pode estar em modo exclusivo.
		//STR0250 - Solicite apoio do departamento de TI e ajuste a configuração de compartilhamento da tabela.
		Help(NIL, NIL, STR0001, NIL, STR0249, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0250})
	EndIf

Return

/*/{Protheus.doc} ValDocto
Valida o código do documento 
@author rafael.hesse
@since 20/06/2022
@version P12.1.33
@param 01 - cTextoAux, Caracter, contém o código do documento a ser validado.
@return lRet, lógico, indica se está válido ou não.
/*/
Function ValDocto(cTextoAux)
Local lRet     := .F.

	If !QDH->(DbSeek(M->QDH_FILIAL+cTextoAux)) .AND. !VerifDel(cTextoAux)
		If !FreeForUse("QDH",M->QDH_FILIAL+PADR(cTextoAux,TamSX3( "QDH_DOCTO" )[1])+"000",.F.)
			lRet := .T.
		EndIf
	else
		lRet := .T.
	EndIf

Return( lRet )
