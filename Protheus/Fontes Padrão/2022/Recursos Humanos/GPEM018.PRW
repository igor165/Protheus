#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM018.CH"

Static lGp120INC := ExistBlock("GP120INC")
Static lTemCCT
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ GPEM018  ณ Autor ณ Leandro Drumond            ณ Data   ณ31/07/2013ณฑฑ
ฑฑณฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Fechamento de periodo de beneficios.                  	         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ GPEM018(nTipFec)                   	                             ณฑฑ
ฑฑณฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Mensal                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ   Data ณ   FNC     ณ  Motivo da Alteracao                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRaquel Hagerณ17/01/13ณM12RH01    ณ Unificacao da Folha. Beneficios Fase 2.    ณฑฑ
ฑฑณM. Silveira ณ03/02/15ณTRJKR6     ณAjuste na funcao Gpm18FecPS para pesquisar  ณฑฑ
ฑฑณ            ณ        ณ           ณcorretamente os registros de co-Participacaoณฑฑ
ฑฑณJoao Balbinoณ14/04/16ณTUXQEL     ณAjuste na funcao Gpm18FecBen para zerar o   ณฑฑ
ฑฑณ            ณ        ณ           ณcampo R0_DPROPIN                            ณฑฑ
ฑฑณRenan Borgesณ17/05/16ณTVDGZ6     ณAjuste para proporcionalizar insalubridade  ณฑฑ
ฑฑณ            ณ        ณ           ณcorretamente quando a base de calculo for   ณฑฑ
ฑฑณ            ณ        ณ           ณpor salแrio mํnimo.                         ณฑฑ
ฑฑณJoใo Balbinoณ02/06/16ณTVFHEK     ณAjuste para considerar a filail indicada no ณฑฑ
ฑฑณ            ณ        ณ           ณperiodo selecionado                         ณฑฑ
ฑฑณEduardo K.  ณ03/03/17ณMPRIMESP   ณAjuste para considerar a filial indicada no ณฑฑ
ฑฑณ            ณ        ณ129        ณperiodo selecionado quando a unidade de neg.ณฑฑ
ฑฑณ            ณ        ณ           ณestiver desabilitada.                       ณฑฑ
ฑฑ|Claudinei S.|10/04/17|DRHPAG-43/ |Ajuste em Gpm18FecBen() para nใo gerar regs.|ฑฑ
ฑฑ|            |        |DRHPAG-629 |na tabela RG2 em caso de funcionแrios       |ฑฑ
ฑฑ|            |        |           |demitidos que nใo receberam vales no m๊s.   |ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/
Function GPEM018(nTipFec)

GPEM120()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao	 ณGp018VldPar   ณ Autor ณ Leandro Drumond     ณ Data ณ01/08/13ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณValidar campos digitados no pergunte (SX1)				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ 		                                   					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Valid pergunte     			                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Function Gp018VldPar(cProcesso,cRoteiro,cPeriodo,cSemana)

Local aPerAtual	:= {}
Local cFilRCH
Local cTipoRot  := fGetTipoRot( cRoteiro )
Local lRet 		:= .T.

DEFAULT cProcesso := ""
DEFAULT cRoteiro  := ""
DEFAULT cPeriodo  := ""
DEFAULT cSemana   := ""

Begin Sequence

	If Empty(cProcesso)
		MsgInfo( STR0015 , STR0014 ) // "Selecione um processo." ## "Atencao"
		lRet := .F.
		Break
	EndIf

	If Empty(cRoteiro)
		MsgInfo( STR0016 , STR0014 ) // "Selecione um roteiro." ## "Atencao"
		lRet := .F.
		Break
	EndIf

	If FunName() == "GP131CALC"  //Vale transporte, refeicao, alimentacao
		If cTipoRot $ '8*D*E'
			MsgInfo( STR0017 , STR0014 ) // "Disponํvel apenas o roteiro de vale transporte para fechamento" ## "Atencao"
			lRet := .F.
			Break
		EndIf
	EndIf

	If FunName() == "GPEA001" //Plano de Saude
		If cTipoRot <> 'C'
			MsgInfo( STR0025 , STR0014 ) // "Disponํvel apenas o roteiro de vale alimenta็ใo para fechamento" ## "Atencao"
			lRet := .F.
			Break
		EndIf
	EndIf

	If Empty(cPeriodo)
		If !fGetPerAtual( @aPerAtual, , cProcesso, cRoteiro )
			MsgInfo( STR0008 , STR0014 ) // "Perํodo selecionado jแ esta fechado!" ## "Atencao"
			Return(.F.)
		Else
			SetMVValue("GPEM018","MV_PAR01",cProcesso)
			SetMVValue("GPEM018","MV_PAR02",cRoteiro)
			SetMVValue("GPEM018","MV_PAR03",aPerAtual[1,1])
			SetMVValue("GPEM018","MV_PAR04",aPerAtual[1,2])
			cPeriodo	:= aPerAtual[1,1]
			cSemana		:= aPerAtual[1,2]
			Pergunte("GPEM018",.F.)
		EndIf
	EndIf

	cFilRCH	:= xFilial("RCH")

	DbSelectArea("RCH")
	RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" ) ) )

	If !(RCH->( dbSeek( cFilRCH + cProcesso + cRoteiro + cPeriodo + cSemana, .F. ) ))
		If Empty(cPeriodo)
			MsgInfo( STR0020 , STR0014 ) // "Nenhum Roteiro Cadastrado com este Processo!" ## "Atencao"
		Else
			MsgInfo( STR0021 , STR0014 ) // "Nenhum Roteiro Cadastrado com este Periodo!" ## "Atencao"
		EndIf
		lRet := .F.
		Break
	EndIf

	If !Empty(RCH->RCH_DTFECH)
		MsgInfo( STR0022 , STR0014 ) // "Perํodo selecionado jแ esta fechado!" ## "Atencao"
		lRet := .F.
		Break
	EndIf

End Sequence

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณfBuscaDtPg     บAutor  ณClaudinei Soaresบ Data ณ 25/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณBusca a data de pagamento de uma verba na SRC,              บฑฑ
ฑฑบ          ณPrimeira ocorrencia                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fBuscaDtPg(cAnoMes,cNumPag)

Local aArea		:= GetArea()
Local dDtPag	:= CtoD("//")
Local lRet		:= .F.

If !Empty(SRA->RA_DEMISSA) .and. AnoMes(SRA->RA_DEMISSA) == cAnoMes
	DbSelectArea("SRG")
	DbSetOrder(1)
	If DbSeeK(SRA->RA_FILIAL + SRA->RA_MAT)
		dDtPag := SRG->RG_DATAHOM
		lRet := .T.
	EndIf
EndIf

If !lRet
	lRet := fPosPeriodo( xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cAnoMes, cNumPag, If(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar()))
	If !lRet
		lRet := fPosPeriodo( xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cAnoMes, cNumPag,  fGetCalcRot("C") )
	EndIf

	If lRet
		dDtPag	:= RCH->RCH_DTPAGO
	EndIf
EndIf

RestArea(aArea)

Return(dDtPag)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpm18FecBenบAutor  ณLeandro Drumond    บ Data ณ  16/10/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMove dados do calculo de VR, VT e VA para historico         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Gpm18FecBen(cAliasSRA,cProcesso,cPeriodo,cRoteiro,cNumPag,cAnoMes,cTipCal,aLog,cTemMov)

Local lRet		:= .T.
Local lNovo		:= NovoCalcBEN()
Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel	:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lOfusca	:= Len(aFldRel) > 0
Local cTpRG2Ped	:= GetSx3Cache("RG2_PEDIDO", "X3_TIPO")

DEFAULT lTemCCT	:= SR0->(ColumnPos("R0_CODCCT")) > 0

If aOfusca[2] .And. IsInCallStack("Gpm120Thread")
	GetGlbVars("lOfuscaJob", lOfusca)
EndIf

If (SR0->(DbSeek((cAliasSRA)->(RA_FILIAL + RA_MAT)+cTipCal))) .And. (!Empty(SR0->R0_QDIACAL) .OR. !Empty(SR0->R0_VALCAL) .OR. Empty((cAliasSRA)->(RA_DEMISSA)))

	While SR0->(!Eof() .and. R0_FILIAL+R0_MAT+R0_TPVALE == (cAliasSRA)->(RA_FILIAL + RA_MAT) + cTipCal)
		cTemMov := "S"

		If lNovo
			cSeek := (cAliasSRA)->RA_FILIAL+SR0->R0_NROPED+cPeriodo+cNumPag+cRoteiro +(cAliasSRA)->RA_MAT+cTipCal+SR0->R0_CODIGO
			//Se usa calculo novo fecha apenas o perํodo selecionado para fechamento.
			If !(SR0->R0_PERIOD + SR0->R0_NROPGT == cPeriodo + cNumPag)
				SR0->(DbSkip())
				Loop
			EndIf
		Else
			cSeek := (cAliasSRA)->(RA_FILIAL + RA_MAT)+cTipCal+SR0->R0_CODIGO+cPeriodo+cNumPag+cRoteiro
		EndIf

		If RG2->(DbSeek(cSeek))
			aAdd( aLog[1], (cAliasSRA)->RA_FILIAL + "  " + (cAliasSRA)->RA_MAT + "-" + If(lOfusca, Replicate('*',15), (cAliasSRA)->RA_NOME) )
			lRet := .F.
			Exit
		Else
			RG2->( RecLock( "RG2" , .T. ) )
		EndIf

		RG2->RG2_FILIAL	:= SR0->R0_FILIAL
		RG2->RG2_MAT   	:= SR0->R0_MAT
		RG2->RG2_PERIOD	:= cPeriodo
		RG2->RG2_NROPGT	:= cNumPag
		RG2->RG2_TPVALE	:= SR0->R0_TPVALE
		RG2->RG2_CODIGO	:= SR0->R0_CODIGO
		RG2->RG2_ANOMES	:= cAnoMes
		RG2->RG2_ROTEIR	:= cRoteiro
		If lNovo
			RG2->RG2_TPBEN	:= SR0->R0_TPBEN
			RG2->RG2_PEDIDO	:= If( cTpRG2Ped == "C", SR0->R0_PEDIDO, Val(SR0->R0_PEDIDO) )
			RG2->RG2_NROPED := SR0->R0_NROPED
			RG2->RG2_VALFIX := SR0->R0_QVALFIX
			RG2->RG2_VALSEG := SR0->R0_QVALSEG
			RG2->RG2_VALTER := SR0->R0_QVALTER
			RG2->RG2_VALQUA := SR0->R0_QVALQUA
			RG2->RG2_VALQUI := SR0->R0_QVALQUI
			RG2->RG2_VALSEX := SR0->R0_QVALSEX
			RG2->RG2_VALSAB := SR0->R0_QVALSAB
			RG2->RG2_VALDOM := SR0->R0_QVALDOM
		Else
			RG2->RG2_PEDIDO	:= If( cTpRG2Ped == "C", "1", 1 )
			If cTipCal == "0"
				RG2->RG2_TPBEN	:= PosAlias( "SRN" , SR0->R0_CODIGO , xFilial("SRN") , "RN_TPBEN" , 1 )
			Else
				RG2->RG2_TPBEN	:= PosAlias( "RFO" , SR0->R0_TPVALE+SR0->R0_CODIGO , xFilial("RFO") , "RFO_TPBEN" , 1 )
			EndIf
		EndIf
		RG2->RG2_DIAPRO	:= SR0->R0_DIASPRO
		RG2->RG2_DIACAL	:= SR0->R0_QDIACAL
		RG2->RG2_VALCAL	:= SR0->R0_VALCAL
		RG2->RG2_CUSUNI	:= SR0->R0_VLRVALE
		RG2->RG2_CUSFUN	:= SR0->R0_VLRFUNC
		RG2->RG2_CUSEMP	:= SR0->R0_VLREMP
		If cTipCal == "0"
			RG2->RG2_PERC	:= 0
		Else
		    RG2->RG2_PERC	:= PosAlias( "RFO" , SR0->R0_TPVALE+SR0->R0_CODIGO , xFilial("RFO") , "RFO_PERC" , 1 )
		EndIf
		RG2->RG2_SALBSE	:= SR0->R0_SALBASE
		RG2->RG2_CC		:= SR0->R0_CC
		RG2->RG2_DIADIF	:= SR0->R0_QDIADIF
		RG2->RG2_VALDIF	:= SR0->R0_VALDIF
		RG2->RG2_CUNIDF	:= SR0->R0_CUNIDF
		RG2->RG2_CFUNDF	:= SR0->R0_CFUNDF
		RG2->RG2_CEMPDF	:= SR0->R0_CEMPDF

		RG2->RG2_VTDUTE	:= SR0->R0_QDIAINF
		RG2->RG2_VTDNUT	:= SR0->R0_QDNUTIL
		RG2->RG2_DUTILM	:= SR0->R0_DUTILM
		RG2->RG2_DNUTIM	:= SR0->R0_DNUTIM
		RG2->RG2_FALTAS	:= SR0->R0_FALTAS
		RG2->RG2_FERIAS	:= SR0->R0_FERIAS
		RG2->RG2_AFAST	:= SR0->R0_AFAST

		If SR0->(ColumnPos("R0_SLDANT")) > 0 .and. SR0->(ColumnPos("R0_VALORI"))
			RG2->RG2_SLDANT	:= SR0->R0_SLDANT
			RG2->RG2_VALORI	:= SR0->R0_VALORI
		EndIf

		If lTemCCT
			RG2->RG2_CODCCT	:= SR0->R0_CODCCT
		EndIf

		RG2->( MsUnlock() )

		If lNovo
			If SM7->(DbSeek(SR0->(R0_FILIAL+R0_MAT+R0_CODIGO+R0_TPVALE))) //M7_FILIAL+M7_MAT+M7_CODIGO+M7_TPVALE
				RecLock("SM7",.F.)
				SM7->M7_DPROPIN := 0
				SM7->(MsUnLock())
			EndIf
			//deleta itens do beneficio - SR0
			SR0->( RecLock( "SR0" , .F. ) )
			SR0->(dbDelete())
			SR0->(MsUnLock())
		Else
			//Limpa itens do beneficio - SR0
			SR0->( RecLock( "SR0" , .F. ) )
			SR0->R0_DIASPRO	:= 0
			SR0->R0_DUTILM	:= 0
			SR0->R0_DNUTIM	:= 0
			SR0->R0_SALBASE	:= 0
			SR0->R0_CC		:= ""
			SR0->R0_FALTAS 	:= 0
			SR0->R0_FERIAS 	:= 0
			SR0->R0_AFAST 	:= 0
			SR0->R0_QDIADIF	:= 0
			SR0->R0_VALDIF 	:= 0
			SR0->R0_CUNIDF 	:= 0
			SR0->R0_CFUNDF	:= 0
			SR0->R0_CEMPDF	:= 0
			SR0->R0_QDIACAL	:= 0
			SR0->R0_VALCAL 	:= 0
			SR0->R0_VLRVALE	:= 0
			SR0->R0_VLRFUNC	:= 0
			SR0->R0_VLREMP 	:= 0
			SR0->R0_DPROPIN := 0
			If SR0->(ColumnPos("R0_SLDANT")) > 0 .and. SR0->(ColumnPos("R0_VALORI"))
				SR0->R0_SLDANT := 0
				SR0->R0_VALORI := 0
			EndIf
			MsUnLock()
		EndIf

		SR0->(DbSkip())

	EndDo

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpm18FecPS บAutor  ณLeandro Drumond    บ Data ณ  16/10/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMove dados do calculo do Plano de Saude para historico      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Gpm18FecPS(cAliasSRA,cFilAux,aCodFol,cAnoMes,cProcesso,cRoteiro,cPeriodo,cNumPag,aStruRHO,aStruRHP,aStruRHR,aStruRHS,cTemMov,lThread)

Local aArea			:= GetArea()
Local aRecnos		:= {}
Local cField 		:= ""
Local cDestField 	:= ""
Local cKey			:= ""
Local dDtPag 		:= CtoD("")
Local lCampos		:= .F.
Local lExclui		:= .T.
Local lPerOri		:= .F.
Local lRet   		:= .T.
Local lSaldo		:= .F.
Local lTemTet		:= .F.
Local lTetCop		:= .F.
Local nCont 		:= 0
Local nT	 		:= 0
Local nExistFld		:= 0
Local nLinha		:= 0
Local nLinTab		:= 0
Local nTamSind 		:= TamSX3("RA_SINDICA")[1]
Local nTetCop 		:= 0
Local nTotDesc 		:= 0
Local nTotSaldo		:= 0
Local nVlrFunc		:= 0
Local lExcPlano		:= .F.
Local cAliasPLA
Local lNovo 		:= .F.
Local nRecno		:= 0

DEFAULT lThread 	:= .F.

If cPaisLoc == "BRA"
	dbSelectArea("RCE")
	dbSelectArea("RHO")	
	lPerOri		:= RHO->( ColumnPos( "RHO_PERORI" ) ) > 0
	lSaldo		:= RHO->( ColumnPos( "RHO_SALDO" ) ) > 0
	lTetCop		:= RCE->( ColumnPos( "RCE_TETCOP" ) ) > 0
	lCampos		:= (lPerOri .And. lSaldo .And. lTetCop)
	nTetCop 	:= IIf( lCampos, fDesc("RCE", SRA->RA_SINDICA, "RCE_TETCOP", NIL, SRA->RA_FILIAL), 0 )
	lTemTet		:= (lCampos .And. nTetCop > 0)
	If lCampos .And. nTetCop == 0
		If RHO->( DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT ) )
			While RHO->( !Eof() ) .And. RHO->RHO_FILIAL + RHO->RHO_MAT == (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT
				If RHO->RHO_COMPPG == cAnoMes .Or. (lPerOri .And. RHO->RHO_PERORI == "2")
					If RHO->RHO_TPLAN == "1" .And. lCampos .And. !Empty(RHO->RHO_SALDO)
						nTotSaldo += RHO->RHO_SALDO
					EndIf
				EndIf
				RHO->( DbSkip() )
			EndDo
		EndIf
		If nTotSaldo > 0 .And.;
			( ( nLinha := fPosTab( "S148", SRA->RA_SINDICA, "=", 4, nTotSaldo, "<=", 5, Nil, Nil, @nLinTab, .T., SRA->RA_FILIAL, Nil, Nil, Nil, Nil, {1, 2, 3, 4, 5} ) ) > 0 .Or.;
			( nLinha := fPosTab( "S148", Space(nTamSind), "=", 4, nTotSaldo, "<=", 5, Nil, Nil, @nLinTab, .T., SRA->RA_FILIAL, Nil, Nil, Nil, Nil, {1, 2, 3, 4, 5} ) ) > 0 )
			nTetCop 	:= fTabela("S148", nLinha, 6, Nil, SRA->RA_FILIAL)//TETO
			lTemTet		:= (lCampos .And. nTetCop > 0)
		EndIf
	EndIf
EndIf

DbSelectArea( "RHO" )

If DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT )

	While !Eof() .and. RHO->(RHO_FILIAL + RHO_MAT) == (cAliasSRA)->(RA_FILIAL + RA_MAT)
		If RHO->RHO_COMPPG == cAnoMes .Or. (lPerOri .And. RHO->RHO_PERORI == "2")
			cTemMov := "S"

			nVlrFunc := RHO->RHO_VLRFUN
			If RHO->RHO_TPLAN == "1" .And. lTemTet .And. !Empty(RHO->RHO_SALDO)
				nVlrFunc := RHO->RHO_SALDO
				If nTotDesc >= nTetCop
					lExclui  := .F.
					nVlrFunc := 0
					aAdd( aRecnos, RHO->( Recno() ) )
				Else
					nVlrFunc := Min( nTetCop - nTotDesc, RHO->RHO_SALDO )
					lExclui  := (nVlrFunc == RHO->RHO_SALDO)
				EndIf
				nTotDesc += nVlrFunc
			EndIf
			
			//Busca a data de pagamento da folha do funcionario
			If Empty(dDtPag)
				dDtPag 	 := fBuscaDtPg(cAnoMes,cNumPag)
			EndIf

			//utilizado query por que nใo tem indice, apos cria็ใo do indice na 12.1.17, trocar pelo seek
			cAliasPLA := GetNextAlias()
			BeginSql alias cAliasPLA
				SELECT RHP_PD, R_E_C_N_O_ AS RECNO
				FROM %table:RHP% RHP
				WHERE RHP.RHP_FILIAL = %exp:RHO->RHO_FILIAL%
				AND RHP.RHP_MAT    = %exp:RHO->RHO_MAT%
				AND RHP.RHP_TPFORN = %exp:RHO->RHO_TPFORN%
				AND RHP.RHP_CODFOR = %exp:RHO->RHO_CODFOR%
				AND RHP.RHP_ORIGEM = %exp:RHO->RHO_ORIGEM%
				AND RHP.RHP_PD	   = %exp:RHO->RHO_PD%
				AND RHP.RHP_COMPPG = %exp:RHO->RHO_COMPPG%
				AND RHP.RHP_CODIGO = %exp:RHO->RHO_CODIGO%
				AND RHP.RHP_DTOCOR = %exp:RHO->RHO_DTOCOR%
				AND RHP.RHP_TPLAN  = %exp:RHO->RHO_TPLAN%
				AND RHP.%notDel%
			EndSql

			If !(lNovo := (cAliasPLA)->(eof()))
				nRecno := (cAliasPLA)->RECNO
			EndIf
			(cAliasPLA)->(dbCloseArea())

			If nRecno > 0
				RHP->(DbGoto(nRecno))
			EndIf
			RHP->( RecLock( "RHP" ,  lNovo ) )

			
			If Empty( RHP->RHP_DATPGT )
				RHP->RHP_DATPGT:= dDtPag
			Endif

			For nT := 1 To Len( aStruRHO )
				cField := aStruRHO[nT, 1]
				cDestField 	:= "RHP" + Substr(cField, At("_", cField) )
				nExistFld 	:= aScan( aStruRHP, { |x| x[1] == cDestField }  )
				If nExistFld > 0
					If lTemTet .And. cDestField == "RHP_VLRFUN"
						RHP->RHP_VLRFUN := nVlrFunc
					Else
						RHP->( &cDestField ) := RHO->( &cField )
					EndIf
				EndIf
			Next nT
			
			If lCampos
				RHP->RHP_SALDO	-= nVlrFunc
			EndIf
			
			RHP->(MsUnlock())

			DbSelectArea( "RHO" )
			If RHO->( RecLock( "RHO" , .F. ) )
				If lExclui .Or. RHO->RHO_TPLAN == "2"
					dbDelete()				
				Else
					aAdd( aRecnos, RHO->( Recno() ) )
					RHO->RHO_SALDO	-= nVlrFunc
				EndIf
			EndIf
			MsUnlock()
		EndIf
		DbSkip()
	EndDo

EndIf

For nCont := 1 To Len( aRecnos )
	RHO->( dbGoto(aRecnos[nCont]) )
	If RHO->( RecLock( "RHO" , .F. ) )
		RHO->RHO_COMPPG	:= SomaMesAno(RHO->RHO_COMPPG)
		RHO->RHO_PERORI	:= "2"
		RHO->( MsUnlock() )
	EndIf
Next nCont

DbSelectArea( "RHR" )

If DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cAnoMes, .F. )
	//Busca a data de pagamento da folha do funcionario
	If Empty(dDtPag)
		dDtPag 	 := fBuscaDtPg(cAnoMes,cNumPag)
	EndIf

	While !Eof() .and. RHR->(RHR_FILIAL + RHR_MAT + RHR_COMPPG) == (cAliasSRA)->(RA_FILIAL + RA_MAT) + cAnoMes
		cTemMov := "S"
		If RHR->RHR_TPLAN == "1"
			DbSelectArea( "RHS" )

			cKey := RHR->(RHR_FILIAL+RHR_MAT+RHR_COMPPG+RHR_ORIGEM+RHR_CODIGO+RHR_TPLAN+RHR_TPFORN+RHR_CODFOR+RHR_TPPLAN+RHR_PLANO+RHR_PD )

			If lThread
		   		If !LockByName(cKey)
		   			RHR->(DbSkip())
		   			Loop
		   		EndIf
		   	EndIf

			If DbSeek( cKey )
				RHS->( RecLock( "RHS" , .F. ) )
			Else
				RHS->( RecLock( "RHS" , .T. ) )
			EndIf

			If Empty( RHS->RHS_DATPGT )
				RHS->RHS_DATPGT:= dDtPag
			Endif

			For nT := 1 To Len( aStruRHR )
				cField := aStruRHR[nT, 1]
				cDestField 	:= "RHS" + Substr(cField, At("_", cField) )
				nExistFld 	:= aScan( aStruRHS, { |x| x[1] == cDestField }  )
				If nExistFld > 0
					RHS->( &cDestField ) := RHR->( &cField )
				EndIf
			Next nT
			MsUnlock()

			If lThread
				UnLockByName(cKey)
	   		EndIf
		EndIf

		DbSelectArea( "RHR" )
		RHO->( RecLock( "RHR" , .F. ) )
		dbDelete()
		MsUnlock()
		DbSkip()
	EndDo
EndIf

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Apos o Fechamento verifica se ha plano de saude com Periodo Final	ณ
ณ IGUAL OU MENOR que o cAnoMes  para encerrar o plano do titular,   ณ
ณ seus dependentes e agregados.										ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
DbSelectArea( "RHK" )
If DbSeek(  (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT, .F. )
	While RHK->(! Eof() ) .and. RHK->( RHK_FILIAL + RHK_MAT ) == (cAliasSRA)->( RA_FILIAL + RA_MAT )
      lExcPlano	:= .F.
		If ! Empty( RHK->RHK_PERFIM ) .and. Right(RHK->RHK_PERFIM,4) + Left(RHK->RHK_PERFIM,2) <= cAnoMes
			DbSelectArea( "RHN" )

			cKey := RHK->RHK_FILIAL+RHK->RHK_MAT+DtoS(dDataBase)

			If lThread
		   		If !LockByName(cKey)
		   			RHK->(DbSkip())
		   			Loop
		   		EndIf
		   	EndIf

			RecLock( "RHN", .T. )
			RHN->RHN_FILIAL 	:= RHK->RHK_FILIAL
			RHN->RHN_MAT		:= RHK->RHK_MAT
			RHN->RHN_DATA		:= dDataBase
			RHN->RHN_OPERAC	:= "2"				// 1=Alteracao;2=Exclusao
			RHN->RHN_ORIGEM	:= "1"				// 1=Titular;2=Dependente;3=Agregado
			RHN->RHN_TPALT	:= "04"			// 01=Fornecedor;02=Tipo do Plano;03=Plano;04=Vigencia;05=Outros
			RHN->RHN_TPFORN	:= RHK->RHK_TPFORN
			RHN->RHN_CODFOR	:= RHK->RHK_CODFOR
			RHN->RHN_TPPLAN	:= RHK->RHK_TPPLAN
			RHN->RHN_PLANO	:= RHK->RHK_PLANO
			RHN->RHN_PD		:= RHK->RHK_PD
			RHN->RHN_PDDAGR	:= RHK->RHK_PDDAGR
			RHN->RHN_PERINI	:= RHK->RHK_PERINI
			RHN->RHN_PERFIM	:= RHK->RHK_PERFIM
			RHN->RHN_DATFIM	:= RHK->RHK_DATFIM
	   		RHN->( MsUnlock() )
			lExcPlano := .T.

			If lThread
				UnLockByName(cKey)
			EndIf
		EndIf

		DbSelectArea( "RHL" )
		If DbSeek(  RHK->( RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR ), .F. )
			While RHL->(!Eof()) .and. RHL->(RHL_FILIAL+RHL_MAT+RHL_TPFORN+RHL_CODFOR) == RHK->(RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR)
				If !(Empty( RHL->RHL_PERFIM )) .and. (Right(RHL->RHL_PERFIM,4) + Left(RHL->RHL_PERFIM,2) <= cAnoMes	)
					DbSelectArea( "RHN" )

					cKey := RHL->RHL_FILIAL+RHL->RHL_MAT+RHL->RHL_CODIGO+RHL->RHL_TPFORN+RHL->RHL_CODFORN+RHL->RHL_TPPLAN

					If lThread
				   		If !LockByName(cKey)
				   			RHL->(DbSkip())
				   			Loop
				   		EndIf
				   	EndIf

					RecLock( "RHN", .T. )
					RHN->RHN_FILIAL 	:= RHL->RHL_FILIAL
					RHN->RHN_MAT		:= RHL->RHL_MAT
					RHN->RHN_DATA		:= dDataBase
					RHN->RHN_OPERAC	:= "2"				// 1=Alteracao;2=Exclusao
					RHN->RHN_ORIGEM	:= "2"				// 1=Titular;2=Dependente;3=Agregado
					RHN->RHN_TPALT	:= "04"				// 01=Fornecedor;02=Tipo do Plano;03=Plano;04=Vigencia;05=Outros
					RHN->RHN_CODIGO	:= RHL->RHL_CODIGO
					RHN->RHN_TPFORN	:= RHL->RHL_TPFORN
					RHN->RHN_CODFOR	:= RHL->RHL_CODFORN
					RHN->RHN_TPPLAN	:= RHL->RHL_TPPLAN
					RHN->RHN_PLANO	:= RHL->RHL_PLANO
					RHN->RHN_PD		:= RHK->RHK_PD
					RHN->RHN_PDDAGR	:= RHK->RHK_PDDAGR
					RHN->RHN_PERINI	:= RHL->RHL_PERINI
					RHN->RHN_PERFIM	:= RHL->RHL_PERFIM
					RHN->RHN_DATFIM	:= RHL->RHL_DATFIM
					RHN->( MsUnlock() )

					// Exclui o plano de saude do DEPENDENTE
					DbSelectArea( "RHL" )
					RHL->( RecLock( "RHL" , .F. ) )
					RHL->( dbDelete() )
					RHL->( MsUnlock() )

					If lThread
						UnLockByName(cKey)
					EndIf
				EndIf
				RHL->( DbSkip() )
			EndDo
      EndIf

		DbSelectArea( "RHM" )
		If DbSeek(  RHK->( RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR ), .F. )
			While RHM->(!Eof()) .and. RHM->(RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR) == RHK->(RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR)
				If !(Empty( RHM->RHM_PERFIM )) .and. (Right(RHM->RHM_PERFIM,4) + left(RHM->RHM_PERFIM,2) <= cAnoMes )

					cKey := RHM->RHM_FILIAL+RHM->RHM_MAT+RHM->RHM_CODIGO+RHM->RHM_TPFORN+RHM->RHM_CODFOR+RHM->RHM_TPPLAN

					If lThread
				   		If !LockByName(cKey)
				   			RHM->(DbSkip())
				   			Loop
				   		EndIf
				   	EndIf

					DbSelectArea( "RHN" )
					RecLock( "RHN", .T. )
					RHN->RHN_FILIAL 	:= RHM->RHM_FILIAL
					RHN->RHN_MAT		:= RHM->RHM_MAT
					RHN->RHN_DATA		:= dDataBase
					RHN->RHN_OPERAC		:= "2"				// 1=Alteracao;2=Exclusao
					RHN->RHN_ORIGEM		:= "3"				// 1=Titular;2=Dependente;3=Agregado
					RHN->RHN_TPALT		:= "04"				// 01=Fornecedor;02=Tipo do Plano;03=Plano;04=Vigencia;05=Outros
					RHN->RHN_CODIGO		:= RHM->RHM_CODIGO
					RHN->RHN_NOME		:= RHM->RHM_NOME
					RHN->RHN_TPFORN		:= RHM->RHM_TPFORN
					RHN->RHN_CODFOR		:= RHM->RHM_CODFOR
					RHN->RHN_TPPLAN		:= RHM->RHM_TPPLAN
					RHN->RHN_PLANO		:= RHM->RHM_PLANO
					RHN->RHN_PD			:= RHK->RHK_PD
					RHN->RHN_PDDAGR		:= RHK->RHK_PDDAGR
					RHN->RHN_PERINI		:= RHM->RHM_PERINI
					RHN->RHN_PERFIM		:= RHM->RHM_PERFIM
					RHN->RHN_DATFIM		:= RHM->RHM_DATFIM
					RHN->( MsUnlock() )

					If lThread
						UnLockByName(cKey)
					EndIf

					// Exclui o plano de saude do AGREGADO
					DbSelectArea( "RHM" )
					RHM->( RecLock( "RHM" , .F. ) )
					RHM->( dbDelete() )
					RHM->( MsUnlock() )
            	EndIf
            	RHM->( DbSkip() )
			EndDo
   		EndIf

      	If lExcPlano
			// Depois de Validar e Excluir SE EXISTIREM os planos de saude dos Dep./Agreg.,
			// Exclui o plano de saude do TITULAR
			DbSelectArea( "RHK" )
			RHK->( RecLock( "RHK" , .F. ) )
			RHK->( dbDelete() )
			RHK->( MsUnlock() )
		EndIf
		RHK->( DbSkip() )
	EndDo
EndIf

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpm18FecPR บAutor  ณLeandro Drumond    บ Data ณ  16/10/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMove dados do calculo do PLR para historico      			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Gpm18FecPR(cAliasSRA,cAnoMes,cProcesso,cRoteiro,cPeriodo,cNumPag,aSRCFields,aSRDFields, aSindPLR,cTemMov)
Local dDataAux 	:= StoD(cAnoMes + "01")
Local lRet 		:= .T.
Local nCposSRD	:= 0
Local nPosCpo	:= 0
Local nCount	:= 0

If (SRC->(DbSeek((cAliasSRA)->(RA_FILIAL + RA_MAT)+cProcesso+cRoteiro+cPeriodo+cNumPag)))
	If ( aScan( aSindPLR, { |x| x[1]+x[2] == xFilial("RCE")+(cAliasSRA)->RA_SINDICA }  ) ) == 0
		aAdd( aSindPLR , { xFilial("RCE") , (cAliasSRA)->RA_SINDICA , (cAliasSRA)->RA_MAT } )
	EndIf

	While SRC->(!Eof() .and. RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA == (cAliasSRA)->(RA_FILIAL + RA_MAT) + cProcesso+cRoteiro+cPeriodo+cNumPag )

		cTemMov := "S"

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Totaliza qtde de funcionarios que tiveram movimento          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nCount = 0
   			nCount ++
	   		nTotFunc ++
	   	EndIf

		If SRD->(dbSeek( SRC->(RC_FILIAL + RC_MAT + RC_CC + cAnoMes + RC_PD + RC_SEQ + RC_PERIODO + RC_SEMANA + RC_ROTEIR)))
			RecLock("SRD",.F.,.T.)
		Else
			RecLock("SRD",.T.)
		EndIf

		For nCposSRD := 1 To Len(aSRDFields)
			If ( nPosCpo := aScan( aSRCFields, { |x| Substr( x[1], 4, Len(x[1]) - 3 ) == Substr( aSRDFields[nCposSRD,1], 4, Len(aSRDFields[nCposSRD,1]) - 3 ) } ) ) > 0
				SRD->&( aSRDFields[nCposSRD,1] ) := SRC->&( aSRCFields[nPosCpo,1] )
			Else
				Do Case
					Case aSRDFields[nCposSRD,1] == "RD_DATARQ"
						SRD->RD_DATARQ	:= cAnoMes
					Case aSRDFields[nCposSRD,1] == "RD_DATPGT"
						SRD->RD_DATPGT	:= If( Empty( SRC->RC_DATA ), StoD( cAnoMes + StrZero( F_ULTDIA(dDataAux), 2 )  ), SRC->RC_DATA )
					Case aSRDFields[nCposSRD,1] == "RD_MES"
						SRD->RD_MES		:= SubStr(cAnoMes,5,2)
					Case aSRDFields[nCposSRD,1] == "RD_STATUS"
						SRD->RD_STATUS	:= "A"
					Case aSRDFields[nCposSRD,1] == "RD_INSS"
						SRD->RD_INSS	:= PosSrv( SRC->RC_PD, SRC->RC_FILIAL, "RV_INSS" )
					Case aSRDFields[nCposSRD,1] == "RD_IR"
						SRD->RD_IR		:= PosSrv( SRC->RC_PD, SRC->RC_FILIAL, "RV_IR" )
					Case aSRDFields[nCposSRD,1] == "RD_FGTS"
						SRD->RD_FGTS	:= PosSrv( SRC->RC_PD, SRC->RC_FILIAL, "RV_FGTS" )
				EndCase
			EndIf
		Next nCposSRD

		SRV->( DbSeek(xFilial("SRV")+SRC->RC_PD ) )

		If SRV->RV_TIPOCOD == "1"
			nTotProvLiq += SRC->RC_VALOR
		ElseIf SRV->RV_TIPOCOD == "2"
			nTotDescLiq += SRC->RC_VALOR
		ElseIf SRV->RV_TIPOCOD == "3"				// Total Base provento
			nTotBsProv 	+= SRC->RC_VALOR
		ElseIf SRV->RV_TIPOCOD == "4"				// Base Desconto
			nTotBsDesc	+= SRC->RC_VALOR
		EndIf

		nTotEmp += SRC->RC_VALOR //Soma ao total da empresa
		nTotRegs++ 	// Total de Registros processados

		//--Ponto de Entrada para gravar campos do usuario
		If lGp120inc
			EXECBLOCK("GP120INC",.F.,.F.)
		Endif

		SRD->( MsUnlock() )

		SRC->(DbSkip())
	EndDO

EndIf

fLimpaRGB((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cProcesso,cPeriodo,cNumPag,cRoteiro)
fLimpaSRC((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cProcesso,cPeriodo,cNumPag,cRoteiro)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpm18FecOB บAutor  ณLeandro Drumond    บ Data ณ  22/02/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMove dados do calculo de OUT para historico      			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Gpm18FecOB(cAliasSRA,cProcesso,cRoteiro,cPeriodo,cNumPag,aRIQFields,aRIRFields,cTemMov,lThread)

Local aVerbas	:= {"RIQ->RIQ_PD","RIQ->RIQ_PD1","RIQ->RIQ_PD2"}
Local aValAux	:= {"RIQ->RIQ_VALBEN","RIQ->RIQ_VLRFUN","RIQ->RIQ_VLREMP"}
Local cKey		:= ""
Local lRet 		:= .T.
Local nCposRIR	:= 0
Local nPosCpo	:= 0
Local nCount	:= 0
Local nX		:= 0

DEFAULT lThread := .F.

DbSelectArea("RIR")
DbSetOrder(1)

DbSelectArea("RIQ")
DbSetOrder(1) //RIQ_FILIAL+RIQ_MAT+RIQ_PROCES+RIQ_ROTEIR+RIQ_PERIOD+RIQ_NUMPAG+RIQ_TPBENE

If (RIQ->(DbSeek((cAliasSRA)->(RA_FILIAL + RA_MAT)+cProcesso+cRoteiro+cPeriodo+cNumPag)))

	While RIQ->(!Eof() .and. RIQ_FILIAL+RIQ_MAT+RIQ_PROCES+RIQ_ROTEIR+RIQ_PERIOD+RIQ_NUMPAG == (cAliasSRA)->(RA_FILIAL + RA_MAT) + cProcesso+cRoteiro+cPeriodo+cNumPag )

		cTemMov := "S"

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Totaliza qtde de funcionarios que tiveram movimento          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nCount = 0
   			nCount ++
	   		nTotFunc ++
	   	EndIf

	   	cKey := RIQ->(RIQ_FILIAL + RIQ_MAT + RIQ_PROCES + RIQ_ROTEIR + RIQ_PERIOD + RIQ_NUMPAG + RIQ_TPBENE )

		If lThread
	   		If !LockByName(cKey)
	   			RIQ->(DbSkip())
	   			Loop
	   		EndIf
	   	EndIf

		If RIR->(dbSeek( cKey ))
			RecLock("RIR",.F.,.T.)
		Else
			RecLock("RIR",.T.)
		EndIf

		For nCposRIR := 1 To Len(aRIRFields)
			If ( nPosCpo := aScan( aRIQFields, { |x| Substr( x[1], 4, Len(x[1]) - 3 ) == Substr( aRIRFields[nCposRIR,1], 4, Len(aRIRFields[nCposRIR,1]) - 3 ) } ) ) > 0
				RIR->&( aRIRFields[nCposRIR,1] ) := RIQ->&( aRIQFields[nPosCpo,1] )
			EndIf
		Next nCposRIR

		For nX := 1 to Len(aVerbas)

			If Empty(&(aVerbas[nX])) .or. &(aValAux[nX]) == 0
				Loop
			EndIf

			SRV->( DbSeek(xFilial("SRV")+&(aVerbas[nX]) ) )

			If SRV->RV_TIPOCOD == "1"
				nTotProvLiq += &(aValAux[nX])
			ElseIf SRV->RV_TIPOCOD == "2"
				nTotDescLiq += &(aValAux[nX])
			ElseIf SRV->RV_TIPOCOD == "3"				// Total Base provento
				nTotBsProv 	+= &(aValAux[nX])
			ElseIf SRV->RV_TIPOCOD == "4"				// Base Desconto
				nTotBsDesc	+= &(aValAux[nX])
			EndIf

			nTotEmp += &(aValAux[nX]) //Soma ao total da empresa
		Next nX

		nTotRegs++ 	// Total de Registros processados

		RIR->( MsUnlock() )

		If lThread
	   		UnLockByName(cKey)
	   	EndIf

		RIQ->(DbSkip())
	EndDo
EndIf

fLimpaRIQ((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT,cProcesso,cPeriodo,cNumPag,cRoteiro)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLimpaRGB  บAutor  ณLeandro Drumond    บ Data ณ  16/10/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLimpa incidencias							      			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLimpaRGB(cFil,cMat,cProcesso,cPeriodo,cNumPag,cRoteiro)

Local cQuery := ""

cQuery := "DELETE FROM " + RetSqlName("RGB") + " "
cQuery += "WHERE RGB_FILIAL='" + cFil + "' AND "
cQuery += "RGB_PROCES='" + cProcesso + "' AND "
cQuery += "RGB_PERIOD='" + cPeriodo + "' AND "
cQuery += "RGB_SEMANA='" + cNumPag + "' AND "
cQuery += "RGB_ROTEIR='" + cRoteiro + "' AND "
cQuery += "RGB_MAT='" + cMat + "' "

TcSqlExec( cQuery )

TcRefresh( InitSqlName("RGB") )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLimpaSRC  บAutor  ณLeandro Drumond    บ Data ณ  17/10/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLimpa registros da SRC					      			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLimpaSRC(cFil, cMat, cProc, cPer, cSem, cRot)

Local cAliasSRC	:= InitSqlName("SRC")
Local cQuery 	:= ""

cQuery := "DELETE FROM " + cAliasSRC + " "
cQuery += "WHERE RC_FILIAL  = '" + cFil + "'"
cQuery += "  AND RC_MAT     = '" + cMat + "'"
cQuery += "  AND RC_PROCES  = '" + cProc + "'"
cQuery += "  AND RC_PERIODO = '" + cPer  + "'"
cQuery += "  AND RC_SEMANA  = '" + cSem  + "'"
cQuery += "  AND RC_ROTEIR  = '" + cRot  + "'"

TcSqlExec(cQuery)
TcRefresh(cAliasSRC)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLimpaRIQ  บAutor  ณLeandro Drumond    บ Data ณ  22/02/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLimpa incidencias							      			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLimpaRIQ(cFil,cMat,cProcesso,cPeriodo,cNumPag,cRoteiro)

Local cQuery := ""

cQuery := "DELETE FROM " + RetSqlName("RIQ") + " "
cQuery += "WHERE RIQ_FILIAL='" + cFil + "' AND "
cQuery += "RIQ_PROCES='" + cProcesso + "' AND "
cQuery += "RIQ_PERIOD='" + cPeriodo + "' AND "
cQuery += "RIQ_NUMPAG='" + cNumPag + "' AND "
cQuery += "RIQ_ROTEIR='" + cRoteiro + "' AND "
cQuery += "RIQ_MAT='" + cMat + "' "

TcSqlExec( cQuery )

TcRefresh( InitSqlName("RIQ") )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFBusParcPLRบAutor  ณLeandro Drumond    บ Data ณ  20/06/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca quantidade de parcelas de PLR pagas	      			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FBusParcPLR(cMat,cAno)
Local cAliasPLR := GetNextAlias()
Local cWhere	:= ""
Local cDataAux	:= cAno+"0101"
Local nRet		:= 0

cWhere += "%"
cWhere += " SRD.RD_PROCES = '" + cProcesso + "' AND "
cWhere += " SRD.RD_ROTEIR = '" + cRoteiro + "' AND "
cWhere += " SRD.RD_DTREF = '" + cDataAux + "' "
cWhere += "%"

//Obtem quantidade de registro para a regua de processamento
BeginSql alias cAliasPLR
	SELECT Count(DISTINCT(RD_DATPGT)) AS NUMREG
	FROM %table:SRD% SRD
	WHERE %exp:cWhere% AND
	SRD.%notDel%
EndSql

If (cAliasPLR)->(!Eof())
	nRet := (cAliasPLR)->NUMREG
EndIf

( cAliasPLR )->( dbCloseArea() )

Return nRet
