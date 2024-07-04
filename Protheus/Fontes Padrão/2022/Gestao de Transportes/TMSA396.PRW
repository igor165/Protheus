#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSA396.CH'

//-------------------------------------------------------------------
/*TMSA396

Ajuste da tabela de Prazos por Regiao/Cliente - Campos DTD_TMEMBI/DTD_TMEMBF/DTD_TMTRAI/DTD_TMTRAF/DTD_TMDISI/DTD_TMDISF/DVN_TMCLII/DVN_TMCLIF

@author  Vicco
@since   22/11/2013
@version 1.0
*/
//-------------------------------------------------------------------

Function TMSA396()
Local bProcesso	:= {|oSelf| A396Proces( oSelf ) }
Local oTProcess

oTProces := tNewProcess():New( "TMSA396", STR0001, bProcesso, STR0002,,,,,,.T.,.T.) //"Ajuste das tabelas de Prazos Por Região/Cliente."###"Efetua ajuste do conteúdo dos campos ref. aos tempos das tabelas de prazos por regiões (DTD) /clientes (DVN) devido tamanho destes campos alterados para 7 caracteres."
oTProces:SaveLog(OemToAnsi(STR0003)) //"Aguarde..."

Return

//-------------------------------------------------------------------
/*A396Proces

Processamento do Ajuste

@author  Vicco
@since   22/11/2013
@version 1.0
*/
//-------------------------------------------------------------------

Static Function A396Proces( oSelf )
Local aArea 	:= GetArea()

TcInternal(5,"*OFF")
RptStatus({|| A396PrcAlt()}, STR0004, STR0005) //"Executando ajuste..."###"Preparando ajuste..."
TcInternal(5,"*ON")
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*A396PrcAlt

Rotina realiza o ajustes das tabelas DTD/DVN

@author  Vicco
@since   22/11/2013
@version 1.0
*/
//-------------------------------------------------------------------
Static Function A396PrcAlt()
Local nTamTmp  := TamSx3('DVN_TMCLII')[1] //-- Tamanho campos tempos

dbSelectArea("DTD")
DTD->(dbSetOrder(1))
DTD->(dbGoTop())
Do While DTD->(!Eof())
	RecLock("DTD", .F.)
	DTD->DTD_TMEMBI := StrZero(Val( DTD->DTD_TMEMBI ),nTamTmp)
	DTD->DTD_TMEMBF := StrZero(Val( DTD->DTD_TMEMBF ),nTamTmp)
	DTD->DTD_TMTRAI := StrZero(Val( DTD->DTD_TMTRAI ),nTamTmp)
	DTD->DTD_TMTRAF := StrZero(Val( DTD->DTD_TMTRAF ),nTamTmp)
	DTD->DTD_TMDISI := StrZero(Val( DTD->DTD_TMDISI ),nTamTmp)
	DTD->DTD_TMDISF := StrZero(Val( DTD->DTD_TMDISF ),nTamTmp)
	MsUnlock()
	DTD->(dbSkip())
EndDo

dbSelectArea("DVN")
DVN->(dbSetOrder(1))
DVN->(dbGoTop())
Do While DVN->(!Eof())
	RecLock("DVN", .F.)
	DVN->DVN_TMCLII := StrZero(Val( DVN->DVN_TMCLII ),nTamTmp)
	DVN->DVN_TMCLIF := StrZero(Val( DVN->DVN_TMCLIF ),nTamTmp)
	MsUnlock()
	DVN->(dbSkip())
EndDo

Return Nil

