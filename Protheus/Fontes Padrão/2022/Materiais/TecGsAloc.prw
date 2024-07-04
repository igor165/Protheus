#include 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "tecgsaloc.ch"

#DEFINE LEGAGENDA	01
#DEFINE LEGSTATUS	02
#DEFINE GRUPO		03
#DEFINE DATREF		04
#DEFINE DATAAG		05
#DEFINE DIASEM		06
#DEFINE HORINI		07
#DEFINE HORFIM		08
#DEFINE CODTEC		09
#DEFINE NOMTEC		10
#DEFINE TIPO		11
#DEFINE ATENDIDA	12
#DEFINE CODABB		13
#DEFINE TURNO		14
#DEFINE SEQ			15
#DEFINE ITEM		16
#DEFINE KEYTGY		17
#DEFINE ITTGY		18
#DEFINE EXSABB		19
#DEFINE HORASTRAB   20
#DEFINE DALOFIM     21
#DEFINE ARRTDV      22
#DEFINE DESCCONF    23

#DEFINE TAMANHO		23

//------------------------------------------------------------------------------
/*/{Protheus.doc} GsAloc

@description Classe utilizada para alocações do Gestão de Serviços.
Pode ser utilizada da seguinte maneira:

1) Definir os parâmetros de alocação (atendente, período, escala, posto, etc...)
		oObj := GsAloc():New()
		oObj:defFil( cFilAnt ) // ou qualquer outra filial
		oObj:defEscala( TDW_COD )
		oObj:defPosto( TFF_COD )
		oObj:defTec( AA1_CODTEC )
		oObj:defGrupo( TGY_GRUPO )
		oObj:defConfal( TGY_CODTDX ) // ou TGZ_CODTDX
		oObj:defDate(DATA_INICIAL , DATA_FINAL)
		oObj:defSeq( PJ_SEMANA )
		oObj:defTpAlo( TCU_COD )
		oObj:defCob( .F. ) //ou .T. se for uma cobertura. O valor Default é .F.
		oObj:defGeHor( { {TGY_ENTRA1,TGY_SAIDA1} , {TGY_ENTRA2,TGY_SAIDA2} , {TGY_ENTRA3,TGY_SAIDA3} , {TGY_ENTRA4,TGY_SAIDA4} } )

2) Validar as informações inseridas:
    If oObj:vldData()
        [...]
    Else
        //É possível verificar se algum erro ocorreu utilizando o método defMessage:
        MsgAlert(oObj:defMessage())
    EndIf

3) Projetar as agendas
    oObj:ProjAloc()

    //É possível recuperar o retorno da Projeção com o método oObj:getProj()
    //É possível verificar informações relevantes sobre a projeção em oObj:defMessage()
    //É possível definir se a classe gera agendas para dias com conflitos utilizado oObj:alocaConflitos()
    //É possível verificar se o atendente possui Restrições de bloqueio utilizando oObj:temBloqueio()
    //É possível verificar se o atendente possui Restrições de aviso utilizando oObj:temAviso()

4) Gravar as agendas
    oObj:GravaAloc()
    //Apenas neste momento a classe gera/atualiza a tabela TGY

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------

class GsAloc
    
    data lCobertura	AS LOGICAL
    data lHasConfl AS LOGICAL
    data lInactive AS LOGICAL
    data lAlocConf AS LOGICAL
    data lRestrBlq AS LOGICAL
    data lRestrAvs AS LOGICAL
    data lAlocInter AS LOGICAL

    data dDtIni AS DATE
    data dDtFim AS DATE

    data recConfAloc AS NUMBER
    data nGrupo AS NUMBER

    data aPosFlds AS ARRAY
    data aHorFlex AS ARRAY
    data aABBsRTDel AS ARRAY

    data cFilAloc AS CHARACTER
    data cEscala AS CHARACTER
    data cProxFe AS CHARACTER
    data cCodLim AS CHARACTER
    data cPosto AS CHARACTER
    data cCodTec AS CHARACTER
    data cSeq AS CHARACTER
    data cConfal AS CHARACTER
    data cTpAlo AS CHARACTER
    data cMessage AS CHARACTER
    data cLastSeq AS CHARACTER
    data cCodTurno AS CHARACTER
    data cCodRota AS CHARACTER
    data cItRota AS CHARACTER
    data cAtdFlex AS CHARACTER

    method new() constructor
    method projAloc()
    method gravaAloc()
    method updateTGY()
    method getProj()
    method getLastSeq()
    method destroy()
    method getConfl()
    method isActive()
    method deActivate()
    method insertTGY()
    method alocaConflitos()
    method apagaRT()
    method temBloqueio()
    method temAviso()
    method PermAlocarInter()
    method vldData()
    method updateTGZ()
    method insertTGZ()

    method defCob()
    method defRec()
    method defEscala()
    method defPosto()
    method defSeq()
    method defTpAlo()
    method defTec()
    method defGrupo()
    method defConfal()
    method defGeHor()
    method defDate()
    method defFil()
    method defMessage()
    method defProxFe()
    method defTurno()
    method defRota()
    method defItemRt()
    method defAtdFlx()
    method defCodLim()
endclass
//------------------------------------------------------------------------------
/*/{Protheus.doc} new

@description Construtor da classe GsAloc

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method new() class GsAloc
    ::cFilAloc := cFilAnt
    ::recConfAloc := 0
    ::lCobertura := .F.
    ::lAlocConf := .F.
    ::lHasConfl := .F.
    ::lInactive := .F.
    ::lRestrBlq := .F.
    ::lRestrAvs := .F.
    ::lAlocInter := .T.
    ::cLastSeq := ""
    ::cCodLim  := ""
    ::cProxFe := "3"
    ::aPosFlds := {}
    ::aABBsRTDel := {}
    ::aHorFlex := {;
                  {"",""},;
                  {"",""},;
                  {"",""},;
                  {"",""};
                }
return
//------------------------------------------------------------------------------
/*/{Protheus.doc} temBloqueio

@description Retorna se a alocação possui alguma Restrição de bloqueio (.T. se possuir)

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method temBloqueio() class GsAloc

return ::lRestrBlq
//------------------------------------------------------------------------------
/*/{Protheus.doc} temAviso

@description Retorna se a alocação possui alguma Restrição de Aviso (.T. se possuir)

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method temAviso() class GsAloc

return ::lRestrAvs
//------------------------------------------------------------------------------
/*/{Protheus.doc} PermAlocarInter

@description Método utilizado para contratação de intermitentes. Retorna .F. se 
o atendente não possuir convocação no período e portanto não pode ser alocado

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method PermAlocarInter() class GsAloc

return ::lAlocInter
//------------------------------------------------------------------------------
/*/{Protheus.doc} getProj

@description Retorna em formato de Array a projeção da alocação do atendente.
O array será no seguinte formato:
[x]
    [x][1] - Legenda da Agenda, que pode ser: BR_VERMELHO = Agenda Gerada (alocação anterior a Dt.Ultalo do Posto)
                                                BR_AMARELO = Agenda Atendida
                                                BR_VERDE = Agenda Não Gerada (será convertida em uma ABB após o GravAloc)
                                                BR_LARANJA = Agenda com Manutenção (inclusive H.E. planejada)
                                                BR_PRETO = Conflito de Alocação (ABB em outro posto, conflitos de GPE, etc...)
                                                BR_PINK = Agenda Reserva Técnica 
                                                            (indica que o atendente tem uma reserva técnica em outro posto no mesmo dia/horário)
    [x][2] - Legenda Status para o tipo do dia, que pode ser:
                                                BR_VERDE = Trabalhado
                                                BR_AMARELO = Compensado
                                                BR_AZUL = DSR
                                                BR_LARANJA = Hora Extra
                                                BR_PRETO = Intervalo
                                                BR_VERMELHO = Não Trabalhado
    [x][3] - Grupo - Mesmo valor que definido em ::defGrupo()        
    [x][4] - Dt.Referência - Data de referência que será inserida na TDV. Valor [CALEND_POS_DATA_APO] da CriaCalend
    [x][5] - Data da Agenda, posição [CALEND_POS_DATA] da CriaCalend
    [x][6] - Dia da Semana. Mesmo valor que [x][5], porém dentro de um DiaSemana()
    [x][7] - Horário Inicial do atendimento (ABB_HRINI)
    [x][8] - Horário final do atendimento (ABB_HRFIM)
    [x][9] - Código do atendente (AA1_CODTEC)
    [x][10] - Nome do atendente (AA1_NOMTEC)
    [x][11] - Tipo do dia. Mesmo valor que a posição [x][2], mas em formato CHAR (S=Trabalhado;C=Compensado;D=D.S.R.;E=Hora Extra;I=Intervalo;N=Nao Trabalhado)
    [x][12] - Se a agenda já está atendida (ABB_ATENDE). Retorno da função At330AVerABB.
    [x][13] - Código da ABB caso encontre ABBs na função At330AVerABB
    [x][14] - Turno da Agenda. Posição [CALEND_POS_TURNO] da CriaCalend
    [x][15] - Sequência da Agenda. Posição [CALEND_POS_SEQ_TURNO] da CriaCalend
    [x][16] - Item. Mantido por compatibilidade. Legado da tela TECA330A
    [x][17] - Chave da TGY, cEscala + ::defConfal() + cCodTFF
    [x][18] - Item da TGY (TGY->TGY_ITEM)
    [x][19] - Existe ABB. Retorna '1' se existe outra ABB neste dia/horário e '2' caso não exista
    [x][20] - Quantidade de horas trabalhadas (por exemplo, para uma agenda das 08:00 as 12:00, aqui receberá o valor 4 (INT))
    [x][21] - Data final da Alocação, caso a agenda "vire" o dia
    [x][22] - Array da TDV, que se baseia no cadastro de Tabelas de Horário (verificar getInfoTDV)
    [x][23] - Descrição do conflito. Nova posição criada nessa classe que retorna o motivo do conflito

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method getProj() class GsAloc

return ::aPosFlds
//------------------------------------------------------------------------------
/*/{Protheus.doc} getConfl

@description Retorna a propriedade ::lHasConfl, que é alterada para .T. caso qualquer dia possua algum conflito
de agenda. Esta propriedade não é alterada para .T. em caso de RESTRIÇÃO para Local / Cliente ou em caso de alocação
de intermitente fora do período de convocação. Existem outros métodos para estas situações

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method getConfl() class GsAloc

return ::lHasConfl
//------------------------------------------------------------------------------
/*/{Protheus.doc} defRec

@description Define o RECNO da TGY ou TGZ que está sendo processada. Método para uso interno apenas.

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defRec(nRecno) class GsAloc
    If VALTYPE(nRecno) == 'N'
        ::recConfAloc := nRecno
    Endif
return ::recConfAloc
//------------------------------------------------------------------------------
/*/{Protheus.doc} defFil

@description Define ou retorna a Filial que a alocação ocorrerá.

Todos os métodos "def" podem ser executados de duas formas:
defFil() <-- retorna o valor apenas
defFil( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defFil(cFilAloc) class GsAloc
    If VALTYPE(cFilAloc) == 'C'
        ::cFilAloc := cFilAloc
    EndIf
Return ::cFilAloc
//------------------------------------------------------------------------------
/*/{Protheus.doc} defEscala

@description Define ou retorna a Escala que a alocação ocorrerá.

Todos os métodos "def" podem ser executados de duas formas:
defEscala() <-- retorna o valor apenas
defEscala( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defEscala(cSetValue) class GsAloc
    If VALTYPE(cSetValue) == 'C'
        ::cEscala := cSetValue
    Endif
return ::cEscala
//------------------------------------------------------------------------------
/*/{Protheus.doc} defProxFe

@description Define ou retorna a Configuralção de Trabalhar ou não no próximo feriado

Todos os métodos "def" podem ser executados de duas formas:
defEscala() <-- retorna o valor apenas
defEscala( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	21/11/2020
/*/
//------------------------------------------------------------------------------
method defProxFe(cSetValue) class GsAloc
    If VALTYPE(cSetValue) == 'C'
        ::cProxFe := cSetValue
    Endif
return  ::cProxFe
//------------------------------------------------------------------------------
/*/{Protheus.doc} defTpAlo

@description Define ou retorna o tipo de alocação (TCU_COD).

Todos os métodos "def" podem ser executados de duas formas:
defTpAlo() <-- retorna o valor apenas
defTpAlo( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defTpAlo(cSetValue) class GsAloc
    If VALTYPE(cSetValue) == 'C'
        ::cTpAlo := cSetValue
    Endif
return ::cTpAlo
//------------------------------------------------------------------------------
/*/{Protheus.doc} defConfal

@description Define ou retorna a configuração de alocação (TGY_CODTDX/TGZ_CODTDX)

Todos os métodos "def" podem ser executados de duas formas:
defConfal() <-- retorna o valor apenas
defConfal( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defConfal(cSetValue) class GsAloc
    If VALTYPE(cSetValue) == 'C'
        ::cConfal := cSetValue
    Endif
Return ::cConfal
//------------------------------------------------------------------------------
/*/{Protheus.doc} defPosto

@description Define ou retorna o posto (TFF_COD)

Todos os métodos "def" podem ser executados de duas formas:
defPosto() <-- retorna o valor apenas
defPosto( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defPosto(cSetValue) class GsAloc
    If VALTYPE(cSetValue) == 'C'
        ::cPosto := cSetValue
    Endif
return ::cPosto
//------------------------------------------------------------------------------
/*/{Protheus.doc} defDate

@description Define ou retorna o período de alocação. Deve ser informado em dois parãmetros, 1º Data Inicial e 2º Data Final
O retorno é em formato de Array
x[1] = dDtIni
x[2] = dDtFim

Todos os métodos "def" podem ser executados de duas formas:
defDate() <-- retorna o valor apenas
defDate( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defDate(dDtIni,dDtFim) class GsAloc
    If VALTYPE(dDtIni) == 'D' .AND. VALTYPE(dDtFim) == 'D'
        ::dDtIni := dDtIni
        ::dDtFim := dDtFim
    EndIf
return {::dDtIni,::dDtFim}
//------------------------------------------------------------------------------
/*/{Protheus.doc} defSeq

@description Define ou retorna a sequência do turno.

Todos os métodos "def" podem ser executados de duas formas:
defSeq() <-- retorna o valor apenas
defSeq( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defSeq(cValue) class GsAloc
    If VALTYPE(cValue) == 'C'
        ::cSeq := cValue
    EndIf
return ::cSeq
//------------------------------------------------------------------------------
/*/{Protheus.doc} defCob

@description Define se é uma alocação por Cobertura (.T.) ou Efetivo (.F.)

Todos os métodos "def" podem ser executados de duas formas:
defCob() <-- retorna o valor apenas
defCob( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defCob(lSet) class GsAloc
    If VALTYPE(lSet) == 'L'
        ::lCobertura := lSet
    EndIf
Return ::lCobertura
//------------------------------------------------------------------------------
/*/{Protheus.doc} defCodLim

@description Define ou retorna o codigo de Limite de Marcacoes (TFF_CODLIM).

Todos os métodos "def" podem ser executados de duas formas:
defCodLim() <-- retorna o valor apenas
defCodLim( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	TECA
@since	09/09/2022
/*/
//------------------------------------------------------------------------------
method defCodLim(cSetValue) class GsAloc
    If VALTYPE(cSetValue) == 'C'
        ::cCodLim := cSetValue
    Endif
return  ::cCodLim
//------------------------------------------------------------------------------
/*/{Protheus.doc} alocaConflitos

@description Indica se a classe vai gerar ABBs em dias com conflito de alocação.
.T. = Aloca em dias com conflito
.F. = Não aloca em dias com conflitos

Todos os métodos "def" podem ser executados de duas formas:
alocaConflitos() <-- retorna o valor apenas
alocaConflitos( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method alocaConflitos(lSet) class GsAloc
    If VALTYPE(lSet) == 'L'
        ::lAlocConf := lSet
    EndIf
Return ::lAlocConf
//------------------------------------------------------------------------------
/*/{Protheus.doc} defTec

@description Define ou retorna o Código do Atendente

Todos os métodos "def" podem ser executados de duas formas:
defTec() <-- retorna o valor apenas
defTec( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defTec(cSet) class GsAloc
    If VALTYPE(cSet) == 'C'
        ::cCodTec := cSet
    EndIf
Return ::cCodTec
//------------------------------------------------------------------------------
/*/{Protheus.doc} defTurno

@description Define ou retorna o turno do Atendente

Todos os métodos "def" podem ser executados de duas formas:
defTurno() <-- retorna o valor apenas
defTurno( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defTurno(cSet) class GsAloc
    If VALTYPE(cSet) == 'C'
        ::cCodTurno := cSet
    EndIf
Return ::cCodTurno
//------------------------------------------------------------------------------
/*/{Protheus.doc} defGrupo

@description Define ou retorna o Grupo (TGY_GRUPO / TGZ_GRUPO)

Todos os métodos "def" podem ser executados de duas formas:
defGrupo() <-- retorna o valor apenas
defGrupo( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defGrupo(nSetValue) class GsAloc
    If VALTYPE(nSetValue) == 'N'
        ::nGrupo := nSetValue
    EndIf
Return ::nGrupo
//------------------------------------------------------------------------------
/*/{Protheus.doc} defGeHor

@description Define ou retorna os horários flexíveis. Deve ser informado no seguinte formato:

x[1]
    x[1][1] = TGY_ENTRA1
    x[1][2] = TGY_SAIDA1
    x[2][1] = TGY_ENTRA2
    x[2][2] = TGY_SAIDA2
    x[3][1] = TGY_ENTRA3
    x[3][2] = TGY_SAIDA3
    x[4][1] = TGY_ENTRA4
    x[4][2] = TGY_SAIDA4

Todos os métodos "def" podem ser executados de duas formas:
defGeHor() <-- retorna o valor apenas
defGeHor( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defGeHor(aSetValue) class GsAloc
    If VALTYPE(aSetValue) == 'A'
        ::aHorFlex := ACLONE(aSetValue)
    EndIf
Return ::aHorFlex
//------------------------------------------------------------------------------
/*/{Protheus.doc} defRota

@description Define ou retorna o código da rota de cobertura

Todos os métodos "def" podem ser executados de duas formas:
defTurno() <-- retorna o valor apenas
defTurno( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defRota(cSet) class GsAloc
    If VALTYPE(cSet) == 'C'
        ::cCodRota := cSet
    EndIf
Return ::cCodRota
//------------------------------------------------------------------------------
/*/{Protheus.doc} defItemRt

@description Define ou retorna o código do item da rota de cobertura

Todos os métodos "def" podem ser executados de duas formas:
defTurno() <-- retorna o valor apenas
defTurno( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defItemRt(cSet) class GsAloc
    If VALTYPE(cSet) == 'C'
        ::cItRota := cSet
    EndIf
Return ::cItRota
//------------------------------------------------------------------------------
/*/{Protheus.doc} defItemRt

@description Define ou retorna o código do item da rota de cobertura

Todos os métodos "def" podem ser executados de duas formas:
defTurno() <-- retorna o valor apenas
defTurno( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defAtdFlx(cSet) class GsAloc
    If VALTYPE(cSet) == 'C'
        ::cAtdFlex := cSet
    EndIf
Return ::cAtdFlex
//------------------------------------------------------------------------------
/*/{Protheus.doc} defMessage

@description Define ou retorna a informação sobre a alocação.

Todos os métodos "def" podem ser executados de duas formas:
defMessage() <-- retorna o valor apenas
defMessage( paramX ) <-- retorna o valor paramX e altera o retorno do método para paramX

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method defMessage(cSetValue) class GsAloc
    If VALTYPE(cSetValue) == 'C'
        ::cMessage := cSetValue
    EndIf
Return ::cMessage
//------------------------------------------------------------------------------
/*/{Protheus.doc} deActivate

@description Desativa a classe. Ela não Gera nem grava mais agendas.

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method deActivate() class GsAloc

Return (::lInactive := .T.)
//------------------------------------------------------------------------------
/*/{Protheus.doc} isActive

@description Verifica se a classe está Ativa (.T.) ou não (.F.)

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method isActive() class GsAloc

Return !(::lInactive)
//------------------------------------------------------------------------------
/*/{Protheus.doc} projAloc

@description Projeta a agenda. Realiza as chamadas ao CriaCalend, PNMTAB e processa conflitos

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method projAloc() class GsAloc
    Local cEscala := ""
    Local cCalend := ""
    Local cTurno := ""
    Local cSeq := ""
    Local cOldSeq := ""
    Local cCodTFF := ""
    Local nGrupo := "" 
    Local cCodTec := ""
    Local cKeyTGY := ""
    Local cItem := ""
    Local cNotIdcFal := ""
    Local cMsgRestr := ""
    Local cCdFunc := ""
    Local cFunFil := ""
    Local cCodTFL
    Local cMsgTPCONTR := ""
    Local cFilBkp := cFilAnt
    Local cFilTFF
    Local aTabPadrao := {}
    Local aTabCalend := {}
    Local aAbbAtend := {}
    Local aCalend := {}
    Local aNewAtend := {}
    Local aAteABB := {}
    Local aAtend := {}
    Local aHorFlex := {}
    Local aFieldsQry := {'AA1_FILIAL','AA1_CODTEC','AA1_NOMTEC','ABB_DTINI','ABB_HRINI','ABB_DTFIM',;
						'ABB_HRFIM','RA_SITFOLH','RA_ADMISSA','RA_DEMISSA','RF_DATAINI','RF_DFEPRO1','RF_DATINI2',;
						'RF_DFEPRO2','RF_DATINI3','RF_DFEPRO3','R8_DATAINI','R8_DATAFIM',;
						"DTINI", "DTFIM", 'HRINI' ,"HRFIM", "ATIVO", "DTREF"}
    Local aArrConfl := {}
    Local aArrDem := {}
    Local aArrAdi := {}
    Local aArrAfast := {}
    Local aArrDFer := {}
    Local aArrDFer2 := {}
    Local aArrDFer3 := {}
    Local aAux := {}
    Local aAux2 := {}
    Local aAux3 := {}
    Local aAuxAgenda := {}
    Local aAuxDT := {}
    Local aRtApagar := {}
    Local aRestrTW2 := {}
    Local aPeriodo := {}
    Local aExcecoes := {}
    Local nJ := 0
    Local nZ := 0
    Local nC := 0
    Local nX := 0
    Local nY := 0
    Local nItem := 0
    Local nTXBDtIni := 0
    Local nTXBDtFim := 0
    Local nLastPos := 0
    Local nHrIniAge := 0
    Local nHrFimAge := 0
    Local nPos := 0
    Local nPosdIni := 0
    Local nPosdFim := 0
    Local nPosHrIni := 0
    Local nPosHrFim := 0
    Local nHrIni := 0
    Local nHrFim := 0
    Local nPosDTRef := 0
    Local dUltAloc := CtoD("")
    Local dDtCnfIni := CtoD("")
    Local dDtCnfFim := CtoD("")
    Local dDtAlIni := CtoD("")
    Local dDtAlFim := CtoD("")
    Local dMenorDt := CtoD("")
    Local dDtBaseRT := CtoD("")
    Local lGsGeHor := SuperGetMV('MV_GSGEHOR',,.F.) .AND. (TGY->( ColumnPos('TGY_ENTRA1')) > 0 )
    Local lGSVERHR := SuperGetMV("MV_GSVERHR",,.F.)
    Local lRestrRH := .F.
    Local lProcessa := .T.
    Local lAterouSeq := .F.
    Local lDelAllRTs := .T.
    Local lRestricao := .F.
    Local lLegRT
    Local lPNMTABC	:= FindFunction("U_PNMSESC") .AND. FindFunction("U_PNMSCAL")
    Local lTecPnm	:= FindFunction( "TecExecPNM" ) .AND. TecExecPNM()
    Local lResRHTXB	:= TableInDic("TXB")
    Local lExcecao  := .F.
    Local lRplFer   := .F. 
    Local lPNMRwExc := FindFunction("U_PNMRwExc")
    Local lTecExec  := lTecPnm .AND.  ExistFunc("TecRwExec")
    Local aCfgCobRt := {}
    Local cAtendFlx := ""
    Local cTpRota   := ""
    Local cCodLim   := ""
    Local lCodLim   := TFF->( ColumnPos('TFF_CODLIM') ) > 0

    cFilAnt := ::defFil()

    If ::isActive()
		
		::lAlocInter := .T.

		cEscala := ::defEscala()
		cCodTFF := ::defPosto()
		cSeq := ::defSeq()
		cOldSeq := cSeq
		cCodTec := ::defTec()
		nGrupo := ::defGrupo()
        cCodLim := ::defCodLim()
        If ::defCob() //Rota de Cobertura
            aCfgCobRt := TecRotaCb(::defRota(),::defItemRt())
            cAtendFlx := ::defAtdFlx()
            cTpRota   := POSICIONE("TW0",1,xFilial("TW0") + ::defRota(), "TW0_TIPO" )
        Endif
		cKeyTGY := cEscala + ::defConfal() + cCodTFF
		cFilTFF := xFilial( "TFF", cFilAnt )
		cCodTFL := POSICIONE("TFF",1,xFilial("TFF")+cCodTFF,"TFF_CODPAI")
		cCdFunc := POSICIONE("AA1",1,xFilial("AA1")+cCodTec,"AA1_CDFUNC")
		cFunFil := POSICIONE("AA1",1,xFilial("AA1")+cCodTec,"AA1_FUNFIL")
		aExcecoes := TecLdExce(cEscala)
		lRplFer := TDW->( ColumnPos('TDW_RPLFER')) > 0 .And. (Posicione("TDW",1,xFilial("TDW") + cEscala , "TDW_RPLFER") == "1")

        If !(::defCob()) //Efetivo
            If ::defRec(SeekTGY(cCodTec, cCodTFF, cEscala, ::defConfal(), nGrupo)) > 0
                TGY->(DbGoTo(::defRec()))
                cItem := TGY->TGY_ITEM
                dUltAloc := TGY->TGY_ULTALO
                If TGY->TGY_ULTALO < ::defDate()[2]
                    ::defMessage(STR0018 + " ("+dToC(TGY->TGY_ULTALO) + " -> " + dToc(::defDate()[2]) + ")") //"Novo periodo de alocação"
                EndIf
            Else
                cItem := GetItemTGY(cCodTFF,cEscala, nGrupo, ::defConfal()) 
                ::defMessage(STR0019) //"Novo efetivo no posto"
            EndIf
        Else //Rota de Cobertura
            If ::defRec(SeekTGZ(cCodTec, cCodTFF, cEscala, ::defConfal(), nGrupo, ::defRota())) > 0
                TGZ->(DbGoTo(::defRec()))
                cItem := TGZ->TGZ_ITEM
                dUltAloc := TGZ->TGZ_DTFIM
                If TGZ->TGZ_DTFIM < ::defDate()[2]
                    ::defMessage(STR0018 + " ("+dToC(TGZ->TGZ_DTFIM) + " -> " + dToc(::defDate()[2]) + ")") //"Novo periodo de alocação"
                EndIf
            Else
                cItem := GetItemTGZ(cCodTFF,cEscala, ::defConfal())
                ::defMessage(STR0039) //"Nova cobertura no posto"
            EndIf
        Endif

        //Verifica se alterou o codigo de limite de marcacao do posto que atendente tem agenda
        If lCodLim .And. FindFunction("At190QryAge")
            cCodLim := POSICIONE("TFF",1,xFilial("TFF")+cCodTFF,"TFF_CODLIM")
            If cCodLim <> ::defCodLim()
                If At190QryAge(.T.,cCodTFF)
                    ::defMessage(STR0043) //"Alteração do Limite de Marcação na aba de Recursos Humanos do Orçamento de Serviços afetará a agenda do atendente."
                EndIf
            EndIf
        EndIf

		//Verifica as restrições TW2 			
		aRestrTW2 := TxRestrTW2(cCodTec,;
								::defDate()[1],;
								::defDate()[2],;
								POSICIONE("TFL",1,xFilial("TFL") + cCodTFL,"TFL_LOCAL"))
		
		//Se existir monta as mensagens.
		For nX := 1 to Len(aRestrTW2)
			If aRestrTW2[nx,4] == "2" //Bloqueio
				If !lRestricao
					lRestricao := .T.
					::lRestrBlq := .T.
					cMsgRestr := STR0001 //"Atendente com restrição (bloqueio) para os dias: "
				EndIf
				If nX != 1
					cMsgRestr += " | "
				EndIf
				cMsgRestr += dToc(aRestrTW2[nx,2])
				cMsgRestr += STR0002 //" à "
				If !EMPTY(aRestrTW2[nx,3])
					cMsgRestr += dToc(aRestrTW2[nx,3])
				Else
					cMsgRestr += STR0003 //"indeterminado"
				EndIf
			Endif
		Next nX
		If !lRestricao
			For nX := 1 to Len(aRestrTW2)
				If aRestrTW2[nx,4] == "1" //Aviso
					If !lRestricao
						lRestricao := .T.
						::lRestrAvs := .T.
						cMsgRestr := STR0004 //"Atendente com restrição (aviso) para os dias: "
					EndIf
					If nX != 1
						cMsgRestr += " | "
					EndIf
					cMsgRestr += dToc(aRestrTW2[nx,2])
					cMsgRestr += STR0002 //" à "
					If !EMPTY(aRestrTW2[nx,3])
						cMsgRestr += dToc(aRestrTW2[nx,3])
					Else
						cMsgRestr += STR0003 //"indeterminado"
					EndIf
				Endif
			Next nX
		EndIf
		If lRestricao
			::defMessage(cMsgRestr)
		EndIf

		If !Empty(cCdFunc) .AND. SuperGetMV("MV_GSXINT",,"2") == "2"
			DbSelectArea("SRA")
			SRA->(DbSetOrder(1))
			If SRA->(DbSeek(cFunFil+cCdFunc))
				If SRA->RA_TPCONTR == "3"
					aPeriodo := Tec190QPer(cCdFunc, cCodTec, ::defDate()[1], ::defDate()[2], cFunFil)
					If Empty(aPeriodo)
						::defMessage(STR0005) //"Não é possivel fazer alocação do funcionario do tipo intermitente que não possui convocação para o período"
						::lAlocInter := .F.
					Else
						If !EMPTY(::defMessage())
							::defMessage( ::defMessage() + ". " + STR0006) //"Contrato de trabalho intermitente: "
						Else
							::defMessage(STR0006) //"Contrato de trabalho intermitente: "
						EndIf
						For nX := 1 To LEN(aPeriodo)
							If nX != 1
								cMsgTPCONTR += " | "
							EndIf
							cMsgTPCONTR += dToc(aPeriodo[nx,2])
							cMsgTPCONTR += STR0002 //" à "
							cMsgTPCONTR += dToc(aPeriodo[nx,3])
						Next nX
					EndIf
				EndIf
			EndIf
		EndIf

		IF lGsGeHor .AND. !EMPTY(STRTRAN(::defGeHor()[1][1],':'))
			aHorFlex := {;
							{::defGeHor()[1][1],::defGeHor()[1][2]},;
							{::defGeHor()[2][1],::defGeHor()[2][2]},;
							{::defGeHor()[3][1],::defGeHor()[3][2]},;
							{::defGeHor()[4][1],::defGeHor()[4][2]};
						}
		EndIf

        If !(::defCob())
            cTurno := POSICIONE("TDX", 1, xFilial("TDX") + ::defConfal(), "TDX_TURNO")
        Else
            cTurno := ::defTurno()   
        Endif

		cCalend := Posicione("TFF",1, xFilial("TFF") + cCodTFF, "TFF_CALEND")

        If !(::defCob()) //Efetivo
            aAteABB := At330AVerABB( ::defDate()[1], ::defDate()[2], cCodTFF, cFilTFF, cCodTec, @cNotIdcFal, .T., ::defConfal())
        Else
            aAteABB := At330AVerABB( ::defDate()[1], ::defDate()[2], cCodTFF, cFilTFF, cCodTec, @cNotIdcFal, .F., ::defConfal(), ::defItemRt() )
        Endif

		ChkCfltAlc(::defDate()[1], ::defDate()[2], cCodTec, /*cHoraIni*/, /*cHoraFim*/, .F., @aFieldsQry,;
						@aArrConfl, @aArrDem, @aArrAfast, @aArrDFer, @aArrDFer2, @aArrDFer3,;
						cNotIdcFal, .T.,/*cFilABB*/,/*dDtRef*/,/*cIdcFal*/,@aArrAdi)
		
		If !EMPTY(aAteABB)
			aAuxAgenda := ACLONE(aAteABB)
			ASORT(aAuxAgenda,,, { |x, y| x[1] < y[1] } )
			If ::defDate()[1] <= aAuxAgenda[1][1] .AND. ::defDate()[2] > aAuxAgenda[LEN(aAuxAgenda)][1]
				For nY := 1 To LEN(aAuxAgenda)
					If ::defDate()[1] <= STOD(aAuxAgenda[nY][11][1])
						cSeq := aAuxAgenda[1][8]
						lAterouSeq := .T.
						Exit
					EndIf
				Next nY
			EndIf
		EndIf

		If lPNMTABC
			U_PNMSEsc(cEscala) // informar escala
			U_PNMSCal(cCalend) // informar calendario     
		ElseIf lTecPnm
			TecPNMSEsc( cEscala )
			TecPNMSCal( cCalend )
		EndIf 

		TecAtProc({0,::defProxFe()})

		lRetCalend := CriaCalend(   ::defDate()[1]  ,;    //01 -> Data Inicial do Periodo
									::defDate()[2]  ,;    //02 -> Data Final do Periodo
									cTurno          ,;    //03 -> Turno Para a Montagem do Calendario
									cSeq            ,;    //04 -> Sequencia Inicial para a Montagem Calendario
									@aTabPadrao     ,;    //05 -> Array Tabela de Horario Padrao
									@aTabCalend     ,;    //06 -> Array com o Calendario de Marcacoes  
									xFilial("SR6")  ,;    //07 -> Filial para a Montagem da Tabela de Horario
									Nil, Nil )

		::defProxFe( TecAtProc()[2] )
		TecLmpAtPr()

		If lPNMTABC
			U_PNMSEsc(Nil) // Limpar as variaveis estaticas
			U_PNMSCal(Nil) 
		ElseIf lTecPnm
			TecPNMSEsc(Nil)
			TecPNMSCal(Nil)
		EndIf
		If lAterouSeq
			cSeq := cOldSeq
		EndIf
		For nJ :=1 To Len(aTabCalend) Step 2
			If aTabCalend[nJ][04] == "1E" // [CALEND_POS_TIPO_MARC]
				aAbbAtend := At330AAbb(aTabCalend[nJ][48], aAteABB, cCodTec) // [CALEND_POS_DATA_APO]
				aCalend   := At330ACal(aTabCalend, nJ)

				If lPNMRwExc
					lExcecao := Len(U_PNMRwExc(aTabCalend[nJ], aExcecoes, , lRplFer)) >  0
				ElseIf lTecExec
					lExcecao := Len(TecRwExec(aTabCalend[nJ], aExcecoes, , lRplFer)) >  0
				EndIf

                aNewAtend := At330aGtIA(aAbbAtend, aCalend, /*aAteEfe*/, cTurno, cSeq, cKeyTGY, aHorFlex, nGrupo,;
                                cCodTec, cItem, dUltAloc, lExcecao, ::defDate()[1], ::defDate()[2], aCfgCobRt, cAtendFlx, cTpRota ) //getInfoAtend

				For nZ := 1 To Len(aNewAtend)
					nItem++
					aAdd(aAtend, aNewAtend[nZ])	
					aAtend[Len(aAtend)][15] := nItem
				Next nZ

			EndIf
		Next nJ

		aSort( aAtend, Nil, Nil, { |x,y| DtoS(x[2])+DtoS(x[14][1][2])+x[4]+x[5]<DtoS(y[2])+DtoS(y[14][1][2])+y[4]+y[5] } )

		If lResRHTXB
			nTXBDtIni := AScan(aFieldsQry,{|e| e == 'TXB_DTINI'})
			nTXBDtFim := AScan(aFieldsQry,{|e| e == 'TXB_DTFIM'})
		Endif

		nPosdIni := AScan(aFieldsQry,{|e| e == 'DTINI'})
		nPosdFim := AScan(aFieldsQry,{|e| e == 'DTFIM'})
		nPosHrIni := AScan(aFieldsQry,{|e| e == 'HRINI'})
		nPosHrFim := AScan(aFieldsQry,{|e| e == 'HRFIM'})
		nPosDTRef := AScan(aFieldsQry,{|e| e == 'DTREF'})
		For nJ := 1 To LEN(aAtend)
			aAux := Array(TAMANHO)
			lRestrRH := .F.
			lLegRT := .F.
			aAux[DESCCONF] := ""
			If !(::PermAlocarInter())
				Loop
			EndIf
			If !Empty(aPeriodo)
				nPos := Ascan(aPeriodo,{ |x| AllTrim(x[4]) == AllTrim(aAtend[nJ,06]) .AND. x[2] <= aAtend[nJ,16] .And.  aAtend[nJ,2] <= x[3] } )
				If nPos <= 0
					Loop
				EndIf
			EndIf
			If !lRestrRH .And. Len(aArrDFer) > 0  
				nPos := Ascan(aArrDFer,{|x| Alltrim(x[1]) == Alltrim(aAtend[nJ,06]) .AND. aAtend[nJ,16] >= x[2] .And. aAtend[nJ,16] <= x[3] } )
				If (lRestrRH :=  nPos > 0)
					aAux[DESCCONF] := STR0007 //"1ª férias programadas"
					::lHasConfl := .T.
				EndIf
			EndIf
			
			If !lRestrRH .And. Len(aArrDFer2) > 0  
				nPos := Ascan(aArrDFer2,{|x| Alltrim(x[1]) == Alltrim(aAtend[nJ,06]) .AND. aAtend[nJ,16] >= x[2] .And. aAtend[nJ,16] <= x[3] } )
				If (lRestrRH :=  nPos > 0)
					aAux[DESCCONF] := STR0008 //"2ª férias programadas"
					::lHasConfl := .T.
				EndIf
			EndIf  
			
			If !lRestrRH .And. Len(aArrDFer3) > 0  
				nPos := Ascan(aArrDFer3,{|x| Alltrim(x[1]) == Alltrim(aAtend[nJ,06]) .AND. aAtend[nJ,16] >= x[2] .And. aAtend[nJ,16] <= x[3] } )
				If (lRestrRH := nPos > 0)
					aAux[DESCCONF] := STR0009 //"3ª férias programadas"
					::lHasConfl := .T.
				EndIf
			EndIf
			
			 If !lRestrRH .And. Len(aArrAdi) > 0  
				nPos := Ascan(aArrAdi,{|x| Alltrim(x[1]) == Alltrim(aAtend[nJ,06]) .AND.  aAtend[nJ,16] <= x[2] } )
				If (lRestrRH := nPos > 0)
					aAux[DESCCONF] := STR0038 //"funcionário sem data de Admissão"
					::lHasConfl := .T.
				EndIf
			EndIf
			
			If !lRestrRH .And. Len(aArrDem) > 0  
				nPos := Ascan(aArrDem,{|x| Alltrim(x[1]) == Alltrim(aAtend[nJ,06]) .AND.  aAtend[nJ,16] >= x[2] } )
				If (lRestrRH := nPos > 0)
					aAux[DESCCONF] := STR0010 //"funcionário demitido"
					::lHasConfl := .T.
				EndIf
			EndIf
			
			If !lRestrRH .And. Len(aArrAfast) > 0  
				nPos := Ascan(aArrAfast,{|x| Alltrim(x[1]) == Alltrim(aAtend[nJ,06]) .AND. aAtend[nJ,16] >= x[2] .And. (aAtend[nJ,16] <= x[3] .OR. Empty(x[3]) ) } )
				If (lRestrRH := nPos > 0)
					aAux[DESCCONF] := STR0011 //"funcionário ausente"
					::lHasConfl := .T.
				EndIf
			EndIf

			If !lRestrRH .And. Len(aArrConfl) > 0 .And. lResRHTXB
				nPos := Ascan(aArrConfl,{|x| Alltrim(x[2]) == Alltrim(aAtend[nJ,06]) .AND.;
							!Empty(x[nTXBDtIni]) .AND. aAtend[nJ,16] >= sTod(x[nTXBDtIni]) .And.;
							( Empty(x[nTXBDtFim]) .Or. aAtend[nJ,16] <= sTod(x[nTXBDtFim]) ) } )
				If (lRestrRH := nPos > 0)
					aAux[DESCCONF] := STR0012 //"restrição RH"
					::lHasConfl := .T.
				EndIf
			EndIf

			If !lRestrRH .And. Len(aArrConfl) > 0
				nLastPos := 0
				lProcessa := .T.
				Do While lProcessa
					nLastPos++
					nPos := Ascan(aArrConfl,{|x| Alltrim(x[2]) == Alltrim(aAtend[nJ,06]) .And.;
							(aAtend[nJ,2] == x[nPosdIni] .Or.  aAtend[nJ,2] == x[nPosdFim] )}, nLastPos )
					nLastPos := nPos
					If nPos > 0
						lRestrRH := .T.
						If LEN(aArrConfl[nPos]) >= 26 .AND. !Empty(aArrConfl[nPos][25]) .AND. aArrConfl[nPos][26] == '1'
							aAux[EXSABB] := "2"
							aAux[DESCCONF] := STR0013 //"atendente em Reserva Técnica"
							lProcessa := .F.
							lLegRT := .T.
							For nC := 1 To Len(aArrConfl)
								If Alltrim(aArrConfl[nC][2]) == Alltrim(aAtend[nJ,06]) .And. (aAtend[nJ,16] == aArrConfl[nC][nPosdIni] .OR.;
										aAtend[nJ,16] == aArrConfl[nC][nPosdFim] )
									
									If EMPTY(aRtApagar) .OR. ASCAN(aRtApagar, {|a| a[4] == aArrConfl[nC][4] .AND.;
																			  a[18] == aArrConfl[nC][18] .AND.;
																			  a[19] == aArrConfl[nC][19] .AND.;
																			  a[20] == aArrConfl[nC][20] .AND.;
																			  a[21] == aArrConfl[nC][21] .AND.;
																			  a[2] == aArrConfl[nC][2] } ) == 0
										AADD(aRtApagar, aArrConfl[nC])
									EndIf
								EndIf
							Next nC
							Exit
						Else
							aAux[EXSABB] := "1"
							aAux[DESCCONF] := STR0014 //"Agenda em outro posto"
						EndIf
						//Agenda não atendida
						If ( Empty(aAtend[nJ,10]) .OR. aAtend[nJ,11] <> '1') .AND.  ;
								aAux[EXSABB] == "1" .And. (Upper(AllTrim(aAtend[nJ,04])) <> "FOLGA" .And.;
								Upper(AllTrim(aAtend[nJ,05])) <> "FOLGA")
							nHrIniAge := VAL(AtJustNum(aAtend[nJ,04]))
							nHrFimAge := VAL(AtJustNum(aAtend[nJ,05]))	
							nHrIni := VAL(AtJustNum(aArrConfl[nPos,nPosHrIni]))
							nHrFim := VAL(AtJustNum(aArrConfl[nPos,nPosHrFim]))
							dDtCnfIni := aArrConfl[nPos,nPosdIni]
							dDtCnfFim := aArrConfl[nPos,nPosdFim]
							dDtAlIni := aAtend[nJ,2]
							dDtAlFim := aAtend[nJ,2] + IIF(nHrIniAge >= nHrFimAge, 1,0)
							dMenorDt := CtoD("")
							aAuxDT := {dDtCnfIni,dDtCnfFim,dDtAlIni,dDtAlFim}
							For nC := 1 To LEN(aAuxDT)
								If EMPTY(dMenorDt) .OR. dMenorDt > aAuxDT[nC]
									dMenorDt := aAuxDT[nC]
								EndIf
							Next nC

							nHrIni += 2400 * (dDtCnfIni - dMenorDt)
							nHrFim += 2400 * (dDtCnfFim - dMenorDt)
							nHrIniAge += 2400 * (dDtAlIni - dMenorDt)
							nHrFimAge += 2400 * (dDtAlFim - dMenorDt)
							
							If nHrIniAge >= nHrIni .AND. nHrIniAge <= nHrFim
								aAux[EXSABB] := "1"
								aAux[DESCCONF] := STR0014 //"Agenda em outro posto"
								lProcessa := .F.
							ElseIf nHrFimAge >= nHrIni .AND. nHrFimAge <= nHrFim
								aAux[EXSABB] := "1"
								aAux[DESCCONF] := STR0014 //"Agenda em outro posto"
								lProcessa := .F.
							ElseIf nHrIniAge <= nHrIni .AND. nHrFimAge >= nHrFim
								aAux[EXSABB] := "1"
								aAux[DESCCONF] := STR0014 //"Agenda em outro posto"
								lProcessa := .F.
							ElseIf nHrIniAge >= nHrIni .AND. nHrFimAge <= nHrFim
								aAux[EXSABB] := "1"
								aAux[DESCCONF] := STR0014 //"Agenda em outro posto"
								lProcessa := .F.
							Else
								lRestrRH := .F.
								aAux[EXSABB] := "2"
								aAux[DESCCONF] := ""
							EndIf

							If !lGSVERHR .AND. !lRestrRH
								If Ascan(aArrConfl,{|x| Alltrim(x[2]) == Alltrim(aAtend[nJ,06]) .And. (aAtend[nJ,16] == x[nPosDTREF] )}, nLastPos )
									aAux[EXSABB] := "1"
									aAux[DESCCONF] := STR0014 //"Agenda em outro posto"
									lProcessa := .F.
								EndIf
							EndIf
						Else
							If (Upper(AllTrim(aAtend[nJ,04])) == "FOLGA" .And. Upper(AllTrim(aAtend[nJ,05])) == "FOLGA")
								lRestrRH := .F.
								aAux[EXSABB] := "2"
								aAux[DESCCONF] := ""
							EndIf
							lProcessa := .F.					
						EndIf				
					Else		
						aAux[EXSABB] := "2"
						lProcessa := .F.
					EndIf
				End 
			Else			
				aAux[EXSABB] := "2"
			EndIf

			If aAux[EXSABB] == "1"
				::lHasConfl := .T.  
			EndIf
			If !EMPTY(aRestrTW2)
				If Ascan(aRestrTW2,{|x| Alltrim(x[1]) == Alltrim(aAtend[nJ,06]) .And.;
							aAtend[nJ,16] >= x[2] .And.;
							( Empty(x[3]) .Or. aAtend[nJ,16] <= x[3] ) .And. x[4] == "2" } ) > 0
					Loop
				EndIf
			EndIf
			aAux[LEGAGENDA] := At330ACLgA( !Empty(aAtend[nJ,10]), aAtend[nJ,11], (aAtend[nJ,19]=="1"), lRestrRH, lLegRT  ) //ZZX_SITABB
			aAux[LEGSTATUS] := At330ACLgS(aAtend[nJ,8]) //ZZX_SITALO
			aAux[GRUPO] := aAtend[nJ,01]
			aAux[DATREF] := aAtend[nJ,16]
			aAux[DATAAG] := aAtend[nJ,02]
			aAux[DIASEM] := aAtend[nJ,03]
			aAux[HORINI] := aAtend[nJ,04]
			aAux[HORFIM] := aAtend[nJ,05]
			aAux[CODTEC] := aAtend[nJ,06]
			aAux[NOMTEC] := aAtend[nJ,07]
			aAux[TIPO] := aAtend[nJ,08]
			aAux[ATENDIDA] := aAtend[nJ,11]
			aAux[CODABB] := aAtend[nJ,10]
			aAux[TURNO] := aAtend[nJ,12]
			aAux[SEQ] := aAtend[nJ,13]
			aAux[ITEM] := aAtend[nJ,15]
			aAux[KEYTGY] := aAtend[nJ,17]
			aAux[ITTGY] := aAtend[nJ,18]
			aAux[DALOFIM] := IIF( HoraToInt(aAux[HORFIM]) < HoraToInt(aAux[HORINI]),aAux[DATAAG]+1, aAux[DATAAG])
			aAux[HORASTRAB] := SubtHoras( aAux[DATAAG], aAux[HORINI],aAux[DALOFIM], aAux[HORFIM])
			aAux[ARRTDV] := aCLONE(aAtend[nJ,14,1])
			Aadd(::aPosFlds,ACLONE(aAux))
		Next nJ

		If !EMPTY(aRtApagar)
			For nC := 1 To Len(aRtApagar)
				aAux2 := getAbbInfo(aRtApagar[nC][2],;
											  aRtApagar[nC][18],;
											  aRtApagar[nC][19],;
											  aRtApagar[nC][20],;
											  aRtApagar[nC][21],;
											  aRtApagar[nC][25])
				For nZ := 1 To LEN(aAux2)
					AADD(::aABBsRTDel, aAux2[nZ])
				Next nZ
			Next nC
			If LEN(::aABBsRTDel) > 0 .AND. TCU->(ColumnPos("TCU_RESFTR")) > 0
				aAux2 := TxConfTCU(aRtApagar[1][25],{"TCU_RESFTR"})
				If Len(aAux2) > 0 .And. (!Empty(aAux2[1][1]) .And. aAux2[1][1] = "TCU_RESFTR")
					If aAux2[1][2] = "1" //"1=Sim;2=Não"
						lDelAllRTs := .F.
					EndIf
				EndIf
			EndIf
			If lDelAllRTs
				aAux2 := {}
				For nC := 1 To Len(::aABBsRTDel)
					dDtBaseRT := CtoD("")
					If EMPTY(aAux2) .OR. ASCAN(aAux2, {|a| a[1] == ::aABBsRTDel[nC][4] .AND.;
														   a[2] == ::aABBsRTDel[nC][3] .AND.;
														   a[3] == ::aABBsRTDel[nC][2] .AND.;
														   a[4] == ::aABBsRTDel[nC][6] .AND.;
														   a[5] == ::aABBsRTDel[nC][8] .AND.;
														   a[6] == ::aABBsRTDel[nC][9] .AND.;
														   a[7] == ::aABBsRTDel[nC][10]}) == 0
						aEval(::aABBsRTDel, {|x| IIF(x[11] > dDtBaseRT, dDtBaseRT := x[11] ,nil) } )
						AADD(aAux2, {::aABBsRTDel[nC][4],;
									::aABBsRTDel[nC][3],;
									::aABBsRTDel[nC][2],;
									::aABBsRTDel[nC][6],;
									::aABBsRTDel[nC][8],;
									::aABBsRTDel[nC][9],;
									::aABBsRTDel[nC][10],;
									dDtBaseRT})
					EndIf
				Next nC
				For nC := 1 To Len(aAux2)
					aAux3 := getAllAbbs(aAux2[nC][1],;
										aAux2[nC][2],;
										aAux2[nC][3],;
										aAux2[nC][4],;
										aAux2[nC][5],;
										aAux2[nC][6],;
										aAux2[nC][7],;
										aAux2[nC][8])
					For nZ := 1 To LEN(aAux3)
						IF ASCAN(::aABBsRTDel, {|a| a[12] == aAux3[nZ][12]}) == 0
							AADD(::aABBsRTDel, aAux3[nZ])
						EndIf
					Next nZ
				Next nC
			EndIf
		EndIf
    EndIf

    cFilAnt := cFilBkp

return (::aPosFlds)
//------------------------------------------------------------------------------
/*/{Protheus.doc} gravaAloc

@description Grava a agenda. Gera a ABB e a TDV

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method gravaAloc( lInsert ) class GsAloc
    Local nx
    Local nTotHor := 0
    Local nRecTar := 0
    Local nRecTN6 := 0  
    Local lResTec := .F.
    Local lGravou := .F.
    Local lNewMdt	:= .F.
    Local cLocal := ""
    Local cSql := ""
    Local cAliasQry := ""
    Local cCodTFF := ""
    Local cIdCFal := ""
    Local cTipoMv := ""
    Local cCodTec := ""
    Local cCdFunc := ""
    Local cFuncao := ""
    Local cCargo := ""
    Local cEscala := ""
    Local cQueryTN5	:= ""
    Local cFilBkp := cFilAnt
    Local aIteABQ := {}
    Local aGravar := {}
    Local aInserted := {}
    Local aAtdXCalen := {}
    Local aAloTDV := {}
    Local aDiasTrab := {}
    Local aFeriados := {}
    Local lAlocMtFil	:= .F.
    Local cFilSRA		:= ""
    Local aTN5			:= {}
    Local aTN6			:= {}
    Local lGsMDTFil 	:= ExistBlock("GsMDTFil")
    Local cItmRota      := ""
    Local cAtdFlex      := ""
    Local cDefConFal    := ""
    Local lPostoLib     := .F.
    Local nGrupo        := 0
    Local cCodLim       := ""
    Default lInsert := .T.

    cFilAnt := ::defFil()

    If ::isActive()
        If !lInsert .OR. (!(::defCob()) .And. ::insertTGY()) .Or. ((::defCob()) .And. ::insertTGZ())
            If !(::defCob()) //Efetivo
                TGY->(DbGoTo(::defRec()))
            Else
                TGZ->(DbGoTo(::defRec()))
                cAtdFlex := ::defAtdFlx()
            Endif
            cCodTFF := ::defPosto()
            cTipoMv := ::defTpAlo()
            cCodTec := ::defTec()
            cEscala := ::defEscala()
            cCodLim := ::defCodLim()
            cDefConFal := ::defConfal()
            nGrupo     := ::defGrupo()

            lPostoLib := TecPostoLib(::defFil(),cTipoMv)

            DbSelectArea("TFF")
            TFF->(DbSetOrder(1))
            If TFF->(dbSeek(xFilial("TFF")+cCodTFF))
                cLocal := TFF->TFF_LOCAL
                cFuncao := TFF->TFF_FUNCAO
                cCargo := TFF->TFF_CARGO
                // Atualiza codigo de limite de marcacoes
                If TFF->( ColumnPos('TFF_CODLIM') ) > 0
                    If cCodLim<>TFF->TFF_CODLIM
                        TFF->(RecLock("TFF", .F.))
                        TFF->TFF_CODLIM := cCodLim
                        TFF->( MsUnlock() )
                    EndIf
                EndIf
            Endif

            DbSelectArea("AA1")
            AA1->(DbSetOrder(1))
            If AA1->(dbSeek(xFilial("AA1")+cCodTec))
                cCdFunc := AA1->AA1_CDFUNC
                cFilSRA := AA1->AA1_FUNFIL
            Endif

			If cFilSRA != cFilAnt
				lAlocMtFil := .T.
			EndIf

			For nX := 1 To LEN(::aPosFlds)
                If ::defCob()
                    cItmRota := ::cItRota
                Endif
				If nX == 1
					dbSelectArea("ABQ")
					ABQ->(dbSetOrder(3))

					dbSelectArea("ABS")
					ABS->(dbSetOrder(1))

					If ABS->(dbSeek(xFilial("ABS")+cLocal)) .And. ABS->ABS_RESTEC == "1"
						lResTec := .T.
					EndIf
				EndIf

				If !("FOLGA" $ ::aPosFlds[nX][HORINI]) .AND. !("FOLGA" $ ::aPosFlds[nX][HORFIM])
					If lResTec .OR. (::aPosFlds[nX][LEGAGENDA] != "BR_VERMELHO" .AND. ::aPosFlds[nX][LEGAGENDA] != "BR_LARANJA" .AND. (::aPosFlds[nX][LEGAGENDA] != "BR_PRETO" .OR. ::alocaConflitos()))
						If EMPTY(aIteABQ)
							cSql := "SELECT ABQ.ABQ_CONTRT, ABQ.ABQ_ITEM, ABQ.ABQ_ORIGEM "
							cSql += " FROM " + RetSqlName("ABQ") + " ABQ "
							cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF "
							cSql += " ON TFF.TFF_COD = ABQ.ABQ_CODTFF "
							cSql += " AND TFF.D_E_L_E_T_ = ' ' "
							cSql += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
							cSql += " AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF "
							cSql += " AND TFF.TFF_PRODUT = ABQ.ABQ_PRODUT "
							cSql += " AND TFF.TFF_LOCAL = ABQ.ABQ_LOCAL "
							cSql += " AND TFF.TFF_FUNCAO = ABQ.ABQ_FUNCAO "
							cSql += " WHERE "
							cSql += " TFF.TFF_COD = '" + cCodTFF + "' "
							cSql += " AND ABQ.D_E_L_E_T_ = ' ' "
							cSql += " AND ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' "
							cSql := ChangeQuery(cSql)
							cAliasQry := GetNextAlias()
							dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
							If !(cAliasQry)->(EOF())
								aIteABQ := {(cAliasQry)->ABQ_CONTRT,;
											(cAliasQry)->ABQ_ITEM,;
											(cAliasQry)->ABQ_ORIGEM}
								cIdCFal := aIteABQ[1] + aIteABQ[2] + aIteABQ[3]
							EndIf
							(cAliasQry)->(DbCloseArea())
						Endif
						If Len(aIteABQ) > 0
							nTotHor += ::aPosFlds[nX][HORASTRAB]
							AADD(aGravar, ::aPosFlds[nX])
						EndIf
					Endif
				EndIf
			Next nX

			If Len(aGravar) > 0 
				For nX := 1 To LEN(aGravar)
					AADD(aAtdXCalen, {aGravar[nX][CODTEC],;
										aGravar[nX][NOMTEC],;
										cCdFunc,;
										aGravar[nX][TURNO],;
										cFuncao,;
										cCargo,;
										cIdCFal,;
										"","",;
										{{aGravar[nX][DATAAG],;
										TxRtDiaSem(aGravar[nX][DATAAG]),;
										Alltrim(aGravar[nX][HORINI]),;
										Alltrim(aGravar[nX][HORFIM]),;
										aGravar[nX][HORASTRAB],;
										aGravar[nX][SEQ]}},;
										{},;
										cLocal})

					If aGravar[nX][TIPO] == "E"
						aGravar[nX][ARRTDV][10] := "N"
					ElseIf aGravar[nX][TIPO] == "I"
						aGravar[nX][ARRTDV][10] := "S"
					Endif

					AADD(aAloTDV, {aGravar[nX][CODTEC],;
									aGravar[nX][DATAAG],;
									Alltrim(aGravar[nX][HORINI]),;
									aGravar[nX][DALOFIM],;
									AllTrim(aGravar[nX][HORFIM]),;
									{aGravar[nX][ARRTDV]};
									})
				Next nX
				Begin Transaction
					::apagaRT()
				At330GvAlo(aAtdXCalen,"CN9",cTipoMv,.F.,@aInserted,.F.,.F.,.F.,,cItmRota,lPostoLib)
					TxSaldoCfg( cIdCFal, nTotHor, .F. )
					For nX := 1 TO LEN(aAloTDV)
						aAloTDV[nX,6,1,1] := aInserted[ASCAN(aInserted,;
														{|a| a[3] == aAloTDV[nX][1] .AND.;
														a[7] == aAloTDV[nX][2] .AND.;
														a[4] == aAloTDV[nX][3] .AND.;
														a[8] == aAloTDV[nX][4] .AND.;
														a[5] == aAloTDV[nX][5]})][2]
					Next nX
					At330AUpTDV(.F., aAloTDV, @aInserted, .T. )
				If lInsert
					If !(::defCob())
						::updateTGY()
					Else
						If Len(aInserted) > 0
							::updateTGZ()
						Endif
					Endif
					EndIf
					For nX := 1 To LEN(aAloTDV)
						If LEN(aAloTDV[nX]) >= 6 .AND. VALTYPE(aAloTDV[nX][6]) == 'A'
							If VALTYPE(aAloTDV[nX][6]) == 'A' .AND. !EMPTY(aAloTDV[nX][6])
								If VALTYPE(aAloTDV[nX][6][1]) == 'A' .AND. LEN(aAloTDV[nX][6][1]) >= 23
									If !EMPTY(aAloTDV[nX][6][1][15])
										AADD(aFeriados, ACLONE(aAloTDV[nX]))
									EndIf
								EndIf
							EndIf
						EndIf
					Next nX
					If TableInDic("TXH") .AND. FindFunction("At58gGera") .And. !lPostoLib
						At58gGera(aInserted,cEscala,cCodTFF,aFeriados,,cDefConFal,,,nGrupo)
					EndIf
					lGravou := .T.
					For nX := 1 TO LEN(aAloTDV)
						If ASCAN(aDiasTrab, aAloTDV[nX][6][1][2]) == 0
							AADD(aDiasTrab, aAloTDV[nX][6][1][2])
						EndIf
					Next nX

					//  GRAVA TN6 
					If TecMdtGS()	//	Integração entre o SIGAMDT x SIGATEC
						If !Empty(cCdFunc) .And. TFF->(DbSeek(xFilial("TFF") + cCodTFF)) .And. TFF->TFF_RISCO == "1"
							cQueryTN5 := GetNextAlias()
							BeginSql Alias cQueryTN5
								SELECT R_E_C_N_O_ TN5RECNO
								FROM   %Table:TN5%
								WHERE  TN5_FILIAL = %exp:xFilial('TN5')%
								AND    TN5_LOCAL  = %exp:TFF->TFF_LOCAL%
								AND    TN5_POSTO  = %exp:TFF->TFF_FUNCAO% 
								AND    %NotDel%
							EndSql
							nRecTar := (cQueryTN5)->TN5RECNO
							(cQueryTN5)->(DbCloseArea())
							If nRecTar > 0
								TGY->(DbGoTo(::defRec()))
								TN5->(DbGoTo(nRecTar)) 
								If lAlocMtFil .And. lGsMDTFil
									aAdd(aTN5,{"TN5_FILIAL",cFilSRA})
									aAdd(aTN5,{"TN5_NOMTAR",TFF->TFF_LOCAL + " - " + TFF->TFF_FUNCAO})
									aAdd(aTN5,{"TN5_LOCAL",TFF->TFF_LOCAL})
									aAdd(aTN5,{"TN5_POSTO",TFF->TFF_FUNCAO})	

									aAdd(aTN6,{"TN6_FILIAL",cFilSRA})
									aAdd(aTN6,{"TN6_MAT",cCdFunc})
									aAdd(aTN6,{"TN6_DTINIC",TGY->TGY_DTINI})
									aAdd(aTN6,{"TN6_DTTERM",TGY->TGY_ULTALO})

									ExecBlock("GsMDTFil",.F.,.F.,{aTN5, aTN6} )
								ElseIf !lAlocMtFil 
									If !At190dTN6(xFilial("TN6"),TN5->TN5_CODTAR,cCdFunc,dToS(TGY->TGY_DTINI),@nRecTN6)
										lNewMdt := .T.		
									Else 
										If nRecTN6 > 0
											TN6->(DbGoTo(nRecTN6))
										EndIf
									Endif	
									RecLock("TN6", lNewMdt)
									If lNewMdt
										TN6->TN6_FILIAL	:= xFilial("TN6")
										TN6->TN6_CODTAR	:= TN5->TN5_CODTAR
										TN6->TN6_MAT    := cCdFunc
									Endif
									TN6->TN6_DTINIC	:= TGY->TGY_DTINI
									TN6->TN6_DTTERM	:= TGY->TGY_ULTALO
									TN6->(MsUnLock())
								EndIf    
							Endif
						Endif
					EndiF

					If LEN(aDiasTrab) == 1
						::defMessage(cValToChar(LEN(aDiasTrab)) + STR0015) //" dia de trabalho inserido"
					Else
						::defMessage(cValToChar(LEN(aDiasTrab)) + STR0016) //" dias de trabalho inseridos"
					EndIf
				End Transaction	
			Else
				::defMessage(STR0017) //"Nenhuma agenda inserida"
			EndIf
		EndIf
	EndIf

    cFilAnt := cFilBkp

return lGravou
//------------------------------------------------------------------------------
/*/{Protheus.doc} destroy

@description "Limpa" todas as propriedades e apaga os dados na memória relacionados a classe

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method destroy() class GsAloc
    ::lCobertura := .F.
    ::lHasConfl := .F.
    ::dDtIni := CTOD("")
    ::dDtFim := CTOD("")
    ::recConfAloc := 0
    ::defFil(cFilAnt)
    ASIZE(::aPosFlds,1)
    ::aPosFlds := {}
    ::aHorFlex := {;
                {"",""},;
                {"",""},;
                {"",""},;
                {"",""};
            }
return
//------------------------------------------------------------------------------
/*/{Protheus.doc} getLastSeq

@description Retorna o 

@author	boiani
@since	04/05/2020
/*/
//------------------------------------------------------------------------------
method getLastSeq() class GsAloc

return ::cLastSeq
//------------------------------------------------------------------------------
/*/{Protheus.doc} updateTGY

@description Atualiza a data da última alocação e sequência da TGY, após gerar as agendas (gravaaloc)

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method updateTGY() class GsAloc
    Local dUltDatRef := STOD("")
    Local cTurno := ""
    Local cSeq := ""
    Local cFilBkp := cFilAnt
    Local nTamPosFl := LEN(::aPosFlds)
    Local nSeq := 0
    Local nPosSeq := 0
    Local nX
    Local aSeqs := {}
    Local aUltAloc := {}

    cFilAnt := ::defFil()
    
    For nX := 1 To nTamPosFl
        If EMPTY(aUltAloc)
            If (::aPosFlds[nX][LEGAGENDA] == "BR_VERDE" .OR. (::aPosFlds[nX][LEGAGENDA] == "BR_PRETO" .AND. ::alocaConflitos())) .AND.;
                     ::aPosFlds[nX][TIPO] $ "S|E"
                aUltAloc := Array(6)
                aUltAloc[1] := ::aPosFlds[nX][KEYTGY]
                aUltAloc[2] := ::aPosFlds[nX][DATREF]
                aUltAloc[3] := ::aPosFlds[nX][SEQ]
                aUltAloc[4] := ::aPosFlds[nX][ITTGY]
                aUltAloc[5] := ::aPosFlds[nX][GRUPO]
                aUltALoc[6] := ::aPosFlds[nX][ITEM]
            EndIf
        ElseIf (::aPosFlds[nX][DATREF] > aUltALoc[2])
            aUltALoc[2] := ::aPosFlds[nX][DATREF]
            If !Empty(::aPosFlds[nX][SEQ])
                aUltALoc[3] := ::aPosFlds[nX][SEQ]
            EndIf
            aUltALoc[6] := ::aPosFlds[nX][ITEM]
        EndIf
    Next nX
    If !EMPTY(aUltALoc)
        cTurno := ::aPosFlds[nTamPosFl][TURNO]
        If EMPTY(aUltALoc[3]) //Sequência
            cSeq := ::aPosFlds[nTamPosFl][SEQ]
            For nX := nTamPosFl To 1 Step -1
                If dUltDatRef != ::aPosFlds[nX][DATREF] .AND. Dow(::aPosFlds[nX][DATREF]) == 2//considera nova sequencia toda segunda-feira
                    nSeq++
                EndIf

                If ::aPosFlds[nX][HORINI] != "FOLGA" .AND.  ::aPosFlds[nX][HORFIM] != "FOLGA"	
                    cSeq := ::aPosFlds[nX][SEQ]
                    Exit
                EndIf

                dUltDatRef := ::aPosFlds[nX][DATREF]
            Next nX
            //Busca sequencia posterior conforme nSeq
            If nSeq > 0
                AADD(aSeqs, {cTurno, At580GtSeq(cTurno)})
                nPosSeq := 1
                aUltALoc[3] := At330aGtSq(aSeqs[nPosSeq][2],cSeq,nSeq, .T.)	
            Else
                aUltALoc[3] := cSeq			
            EndIf
        EndIf
        If Dow(aUltALoc[2]) == 1
            AADD(aSeqs, {cTurno, At580GtSeq(cTurno)})
            nPosSeq := 1
            aUltALoc[3] := At330aGtSq(aSeqs[nPosSeq][2],aUltALoc[3], 1, .T. )//Recupera proxima Sequencia
        EndIf

        TGY->(DbGoTo(::recConfAloc))
        TGY->(RecLock("TGY", .F.))
        TGY->TGY_SEQ := aUltALoc[3]		//-- Sequencia
        TGY->TGY_ULTALO	:= aUltALoc[2]	//-- Dt da Ultima Alocação
        TGY->( MsUnlock() )
        ::cLastSeq := aUltALoc[3]
    EndIf
    cFilAnt := cFilBkp
return
//------------------------------------------------------------------------------
/*/{Protheus.doc} updateTGZ

@description Atualiza a data da última alocação e sequência da TGZ, após gerar as agendas (gravaaloc)

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method updateTGZ() class GsAloc
    Local dUltDatRef := STOD("")
    Local cTurno := ""
    Local cSeq := ""
    Local cFilBkp := cFilAnt
    Local nTamPosFl := LEN(::aPosFlds)
    Local nSeq := 0
    Local nPosSeq := 0
    Local nX
    Local aSeqs := {}
    Local aUltAloc := {}

    cFilAnt := ::defFil()
    
    For nX := 1 To nTamPosFl
        If EMPTY(aUltAloc)
            If (::aPosFlds[nX][LEGAGENDA] == "BR_VERDE" .OR. (::aPosFlds[nX][LEGAGENDA] == "BR_PRETO" .AND. ::alocaConflitos())) .AND.;
                     ::aPosFlds[nX][TIPO] $ "S|E"
                aUltAloc := Array(6)
                aUltAloc[1] := ::aPosFlds[nX][KEYTGY]
                aUltAloc[2] := ::aPosFlds[nX][DATREF]
                aUltAloc[3] := ::aPosFlds[nX][SEQ]
                aUltAloc[4] := ::aPosFlds[nX][ITTGY]
                aUltAloc[5] := ::aPosFlds[nX][GRUPO]
                aUltALoc[6] := ::aPosFlds[nX][ITEM]
            EndIf
        ElseIf (::aPosFlds[nX][DATREF] > aUltALoc[2])
            aUltALoc[2] := ::aPosFlds[nX][DATREF]
            If !Empty(::aPosFlds[nX][SEQ])
                aUltALoc[3] := ::aPosFlds[nX][SEQ]
            EndIf
            aUltALoc[6] := ::aPosFlds[nX][ITEM]
        EndIf
    Next nX
    If !EMPTY(aUltALoc)
        cTurno := ::aPosFlds[nTamPosFl][TURNO]
        If EMPTY(aUltALoc[3]) //Sequência
            cSeq := ::aPosFlds[nTamPosFl][SEQ]
            For nX := nTamPosFl To 1 Step -1
                If dUltDatRef != ::aPosFlds[nX][DATREF] .AND. Dow(::aPosFlds[nX][DATREF]) == 2//considera nova sequencia toda segunda-feira
                    nSeq++
                EndIf

                If ::aPosFlds[nX][HORINI] != "FOLGA" .AND.  ::aPosFlds[nX][HORFIM] != "FOLGA"	
                    cSeq := ::aPosFlds[nX][SEQ]
                    Exit
                EndIf

                dUltDatRef := ::aPosFlds[nX][DATREF]
            Next nX
            //Busca sequencia posterior conforme nSeq
            If nSeq > 0
                AADD(aSeqs, {cTurno, At580GtSeq(cTurno)})
                nPosSeq := 1
                aUltALoc[3] := At330aGtSq(aSeqs[nPosSeq][2],cSeq,nSeq, .T.)
            Else
                aUltALoc[3] := cSeq
            EndIf
        EndIf
        If Dow(aUltALoc[2]) == 1
            AADD(aSeqs, {cTurno, At580GtSeq(cTurno)})
            nPosSeq := 1
            aUltALoc[3] := At330aGtSq(aSeqs[nPosSeq][2],aUltALoc[3], 1, .T. )//Recupera proxima Sequencia
        EndIf

        TGZ->(DbGoTo(::recConfAloc))
        TGZ->(RecLock("TGZ", .F.))
        TGZ->TGZ_SEQ := aUltALoc[3]		//-- Sequencia
        TGZ->TGZ_DTFIM := aUltALoc[2]	//-- Dt da Ultima Alocação
        If !Empty(::cCodRota)
            TGZ->TGZ_CODTW0 := ::cCodRota	//-- Dt da Ultima Alocação
        Endif
        TGZ->( MsUnlock() )
        ::cLastSeq := aUltALoc[3]
    EndIf
    cFilAnt := cFilBkp
return
//------------------------------------------------------------------------------
/*/{Protheus.doc} SeekTGY

@description Retorna o RECNO de uma TGY de acordo com os parâmetros

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
Static Function SeekTGY(cCodTec, cCodTFF, cEscala, cConfal, nGrupo)
Local nRet := 0
Local cSql := ""
Local aTDXeGRUP := {}
Local aTDX := {}
Local aGrupo := {}
Local aOthers := {}
Local cAliasQry

cSql += " SELECT TGY.R_E_C_N_O_ REC, TGY.TGY_CODTDX, TGY.TGY_GRUPO "
cSql += " FROM " + RetSqlName( "TGY" ) + " TGY "
cSql += " WHERE TGY.D_E_L_E_T_ = ' ' AND "
cSql += " TGY.TGY_ATEND = '" + cCodTec + "' AND "
cSql += " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND "
cSql += " TGY.TGY_CODTFF = '" + cCodTFF + "' AND "
cSql += " TGY.TGY_ESCALA = '" + cEscala + "' AND "
cSql += " TGY.TGY_GRUPO = " + CValToChar(nGrupo) + " 

cSql := ChangeQuery(cSql)
cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

While !(cAliasQry)->(EOF())
    
    If (cAliasQry)->TGY_CODTDX == cConfal .AND. (cAliasQry)->TGY_GRUPO == nGrupo
        AADD(aTDXeGRUP, (cAliasQry)->REC)
    ElseIf (cAliasQry)->TGY_CODTDX == cConfal
        AADD(aTDX, (cAliasQry)->REC)
    ElseIf (cAliasQry)->TGY_GRUPO == nGrupo
        AADD(aGrupo, (cAliasQry)->REC)
    Else
        AADD(aOthers, (cAliasQry)->REC)
    EndIf

    (cAliasQry)->(DbSkip())
End

(cAliasQry)->(DbCloseArea())

If !EMPTY(aTDXeGRUP)
    nRet := aTDXeGRUP[1]
ElseIf !EMPTY(aTDX)
    nRet := aTDX[1]
ElseIf !EMPTY(aGrupo)
    nRet := aGrupo[1]
ElseIf !EMPTY(aOthers)
    nRet := aOthers[1]
EndIf

Return nRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} SeekTGZ

@description Retorna o RECNO de uma TGZ de acordo com os parâmetros

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
Static Function SeekTGZ(cCodTec, cCodTFF, cEscala, cConfal, nGrupo, cCodRota)
Local nRet := 0
Local cSql := ""
Local aTDXeGRUP := {}
Local aTDX := {}
Local aGrupo := {}
Local aOthers := {}
Local cAliasQry

cSql += " SELECT TGZ.R_E_C_N_O_ REC, TGZ.TGZ_CODTDX, TGZ.TGZ_GRUPO "
cSql += " FROM " + RetSqlName( "TGZ" ) + " TGZ "
cSql += " WHERE TGZ.D_E_L_E_T_ = ' ' AND "
cSql += " TGZ.TGZ_ATEND = '" + cCodTec + "' AND "
cSql += " TGZ.TGZ_FILIAL = '" + xFilial("TGZ") + "' AND "
cSql += " TGZ.TGZ_CODTFF = '" + cCodTFF + "' AND "
cSql += " TGZ.TGZ_ESCALA = '" + cEscala + "' AND "
cSql += " TGZ.TGZ_CODTW0 = '" + cCodRota + "' "

cSql := ChangeQuery(cSql)
cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

While !(cAliasQry)->(EOF())
    
    If (cAliasQry)->TGZ_CODTDX == cConfal .AND. (cAliasQry)->TGZ_GRUPO == nGrupo
        AADD(aTDXeGRUP, (cAliasQry)->REC)
    ElseIf (cAliasQry)->TGZ_CODTDX == cConfal
        AADD(aTDX, (cAliasQry)->REC)
    ElseIf (cAliasQry)->TGZ_GRUPO == nGrupo
        AADD(aGrupo, (cAliasQry)->REC)
    Else
        AADD(aOthers, (cAliasQry)->REC)
    EndIf

    (cAliasQry)->(DbSkip())
End

(cAliasQry)->(DbCloseArea())

If !EMPTY(aTDXeGRUP)
    nRet := aTDXeGRUP[1]
ElseIf !EMPTY(aTDX)
    nRet := aTDX[1]
ElseIf !EMPTY(aGrupo)
    nRet := aGrupo[1]
ElseIf !EMPTY(aOthers)
    nRet := aOthers[1]
EndIf

Return nRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetItemTGY

@description Retorna o próximo TGY_ITEM de acordo com os parâmetros

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
Static Function GetItemTGY(cCodTFF, cEscala, nGrupo, cConfal)
Local cRet := REPLICATE("0",TamSX3("TGY_ITEM")[1])
Local cSql := ""
Local cAliasQry

cSql += " SELECT MAX(TGY.TGY_ITEM) ITEM "
cSql += " FROM " + RetSqlName( "TGY" ) + " TGY "
cSql += " WHERE TGY.D_E_L_E_T_ = ' ' AND "
cSql += " TGY.TGY_CODTFF = '" + cCodTFF + "' AND "
cSql += " TGY.TGY_ESCALA = '" + cEscala + "' AND "
cSql += " TGY.TGY_CODTDX = '" + cConfal + "' AND "
cSql += " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND "
cSql += " TGY.TGY_GRUPO = " + CValToChar(nGrupo) + "  

cSql := ChangeQuery(cSql)
cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

If !(cAliasQry)->(EOF())
    cRet := STRZERO((cAliasQry)->(ITEM), TamSX3("TGY_ITEM")[1], 0)
EndIf

(cAliasQry)->(DbCloseArea())

Return (Soma1(cRet))
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetItemTGZ

@description Retorna o próximo TGZ_ITEM de acordo com os parâmetros

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
Static Function GetItemTGZ(cCodTFF, cEscala, cConfal)
Local cRet := REPLICATE("0",TamSX3("TGZ_ITEM")[1])
Local cSql := ""
Local cAliasQry

cSql += " SELECT MAX(TGZ.TGZ_ITEM) ITEM "
cSql += " FROM " + RetSqlName( "TGZ" ) + " TGZ "
cSql += " WHERE TGZ.D_E_L_E_T_ = ' ' AND "
cSql += " TGZ.TGZ_CODTFF = '" + cCodTFF + "' AND "
cSql += " TGZ.TGZ_ESCALA = '" + cEscala + "' AND "
cSql += " TGZ.TGZ_CODTDX = '" + cConfal + "' AND "
cSql += " TGZ.TGZ_FILIAL = '" + xFilial("TGZ") + "' "

cSql := ChangeQuery(cSql)
cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

If !(cAliasQry)->(EOF())
    cRet := STRZERO((cAliasQry)->(ITEM), TamSX3("TGZ_ITEM")[1], 0)
EndIf

(cAliasQry)->(DbCloseArea())

Return (Soma1(cRet))
//------------------------------------------------------------------------------
/*/{Protheus.doc} insertTGY

@description Insere/Atualiza a TGY ao alocar. Diferente do método updateTGY, essa classe
instancia o TECA580E e executa suas validações

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method insertTGY() class GsAloc
    Local lRet := .T.
    Local oMdlOLD := FwModelActive()
    Local oMdl580e
    Local oMdlAux1
    Local oMdlAux2
    Local nC
    Local nX
    Local lHasTGY := (::defRec() > 0)
    Local lFlex := TecXHasEdH() .AND. VldEscala(0, ::defEscala(), ::defPosto(), .F.)
    Local cError := ""
    Local cVldGrupo := ""
    At580EGHor(lFlex)
    TFF->(DbSeek(xFilial("TFF")+::defPosto()))
    If Empty(TFF->TFF_ESCALA) .AND. !Empty(::defEscala())
        TFF->(RecLock("TFF", .F.))
            TFF->TFF_ESCALA := ::defEscala()		//-- Sequencia
        TFF->( MsUnlock() )
    EndIf
    oMdl580e := FwLoadModel("TECA580E")
    oMdl580e:SetOperation(MODEL_OPERATION_UPDATE)
    lRet := lRet .AND. oMdl580e:Activate()
    oMdlAux1 := oMdl580e:GetModel("TDXDETAIL")
    oMdlAux2 := oMdl580e:GetModel("TGYDETAIL")

    If lRet
        lRet := .F.
        For nX := 1 to oMdlAux1:Length()
            oMdlAux1:GoLine(nX)

            If oMdlAux1:GetValue("TDX_CODTDW") == ::defEscala() .AND.; 	
                    oMdlAux1:GetValue("TDX_COD") == ::defConfal()

                If !lHasTGY
                    oMdlAux2:GoLine(oMdlAux2:Length())
                Else
                    lRet := oMdlAux2:SeekLine({ {"TGY_ATEND", ::defTec() } })
                EndIf

                If !lHasTGY .AND. !Empty(oMdlAux2:GetValue("TGY_ATEND"))
                    oMdlAux2:AddLine()
                Endif

                If Empty(oMdlAux2:GetValue("TGY_ATEND")) .OR. lHasTGY
                    If !lHasTGY
                        lRet := oMdlAux2:LoadValue("TGY_ATEND", ::defTec())
                        lRet := lRet .AND. oMdlAux2:LoadValue("TGY_SEQ", ::defSeq())
                        lRet := lRet .AND. oMdlAux2:SetValue("TGY_DTINI", ::defDate()[1])
                        lRet := lRet .AND. oMdlAux2:LoadValue("TGY_TURNO", ALLTRIM(POSICIONE("AA1",1,XFILIAL("AA1") + ::defTec(),"AA1_TURNO")))
                        lRet := lRet .AND. oMdlAux2:LoadValue("TGY_ITEM", TecXMxTGYI(::defEscala(), ::defConfal(), ::defPosto()))
                    EndIf
                    If !(At580EVlGr("TGYDETAIL","TGY_GRUPO", .F., @cVldGrupo, ::defGrupo()))
                        lRet := .F.
                        cError := cVldGrupo
                    EndIf
                    If lHasTGY
                        If FindFunction("At190dDtPj")
                            At190dDtPj({xFilial("TGY")+(::defEscala() + ::defConfal() + ::defPosto())+oMdlAux2:GetValue("TGY_ITEM"),;
                            ::defDate()[1],;
                            ::defDate()[2],;
                            ::defGrupo(),;
                            ::defTec()})
                        Endif
                    EndIf
                    lRet := lRet .AND. oMdlAux2:SetValue("TGY_GRUPO", ::defGrupo())
                    lRet := lRet .AND. oMdlAux2:SetValue("TGY_TIPALO", ::defTpAlo())
                    If TGY->( ColumnPos("TGY_PROXFE")) > 0
                        lRet := lRet .AND. oMdlAux2:LoadValue("TGY_PROXFE", ::defProxFe())
                    EndIf
                    If !lHasTGY .OR. oMdlAux2:GetValue("TGY_ULTALO") < ::defDate()[2]
                        lRet := lRet .AND. oMdlAux2:SetValue("TGY_DTFIM", ::defDate()[2])
                    EndIf
                    If lFlex
                        For nC := 1 to Len(::defGeHor())
                            If At580eWhen(Str(nC, 1))
                                lRet := lRet .AND. oMdlAux2:SetValue(("TGY_ENTRA"+cValToChar(nC)), ::defGeHor()[nC][1])
                                lRet := lRet .AND. oMdlAux2:SetValue(("TGY_SAIDA"+cValToChar(nC)), ::defGeHor()[nC][2])
                            EndIf
                        Next nC
                    EndIf
                    Exit
                Endif
            EndIf
        Next nX
        If (lRet := lRet .AND. oMdl580e:VldData() .And. oMdl580e:CommitData())
            oMdl580e:DeActivate()
            oMdl580e:Destroy()
            If !lHasTGY
                ::defRec(SeekTGY(::defTec(), ::defPosto(), ::defEscala(), ::defConfal(), ::defGrupo()))
            EndIf
        ElseIf oMdl580e:HasErrorMessage()
            lRet := .F.
            If !EMPTY(STRTRAN(Alltrim(oMdl580e:GetErrorMessage()[6]), CRLF))
                cError += STRTRAN(Alltrim(oMdl580e:GetErrorMessage()[6]), CRLF)
            EndIf
            If !EMPTY(STRTRAN(Alltrim(oMdl580e:GetErrorMessage()[7]), CRLF))
                If !EMPTY(cError)
                    cError += " / "
                EndIF
                cError += STRTRAN(Alltrim(oMdl580e:GetErrorMessage()[7]), CRLF)
            EndIf
        EndIf
        If !EMPTY(cError)
            ::defMessage(cError)
        EndIF
    EndIf
    At580BClHs()
    At580EGHor(.F.)
    If FindFunction("At190dDtPj")
        At190dDtPj(,.T.)
    EndIf
    FwModelActive(oMdlOLD)
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} insertTGZ

@description Insere/Atualiza a TGZ ao alocar. Diferente do método updateTGZ, essa classe
instancia o TECA580E e executa suas validações

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method insertTGZ() class GsAloc
    Local lRet := .T.
    Local oMdlOLD := FwModelActive()
    Local oMdl580e
    Local oMdlAux1
    Local oMdlAux2
    Local nX
    Local lHasTGZ := (::defRec() > 0)
    Local lFlex := TecXHasEdH() .AND. VldEscala(0, ::defEscala(), ::defPosto(), .F.)
    Local cError := ""
    Local cVldGrupo := ""
 
    At580EGHor(lFlex)
    TFF->(DbSeek(xFilial("TFF")+::defPosto()))
    oMdl580e := FwLoadModel("TECA580E")
    oMdl580e:SetOperation(MODEL_OPERATION_UPDATE)
    lRet := lRet .AND. oMdl580e:Activate()
    If lRet
        At580VdFolder({2})
        oMdlAux1 := oMdl580e:GetModel("TGXDETAIL")
        oMdlAux2 := oMdl580e:GetModel("TGZDETAIL")
        lRet := .F.
        For nX := 1 to oMdlAux1:Length()
            oMdlAux1:GoLine(nX)

            If oMdlAux1:GetValue("TGX_CODTDW") == ::defEscala() .AND.; 	
                    oMdlAux1:GetValue("TGX_COD") == ::defConfal()

                If !lHasTGZ
                    oMdlAux2:GoLine(oMdlAux2:Length())
                Else
                    lRet := oMdlAux2:SeekLine({ {"TGZ_ATEND", ::defTec() } })
                EndIf

                If !lHasTGZ .AND. !Empty(oMdlAux2:GetValue("TGZ_ATEND"))
                    oMdlAux2:AddLine()
                Endif

                If Empty(oMdlAux2:GetValue("TGZ_ATEND")) .OR. lHasTGZ
                    If !lHasTGZ
                        lRet := oMdlAux2:LoadValue("TGZ_ATEND", ::defTec())
                        lRet := lRet .AND. oMdlAux2:LoadValue("TGZ_SEQ", ::defSeq())
                        lRet := lRet .AND. oMdlAux2:SetValue("TGZ_DTINI", ::defDate()[1])
                        lRet := lRet .AND. oMdlAux2:LoadValue("TGZ_TURNO", ALLTRIM(POSICIONE("AA1",1,XFILIAL("AA1") + ::defTec(),"AA1_TURNO")))
                        lRet := lRet .AND. oMdlAux2:LoadValue("TGZ_ITEM", TecXMxTGZI(::defEscala(), ::defConfal(), ::defPosto()))
                        If !Empty(::defRota())
                            lRet := lRet .AND. oMdlAux2:LoadValue("TGZ_CODTW0", ::defRota())
                        Endif
                    EndIf
                    If !(At580EVlGr("TGZDETAIL","TGZ_GRUPO", .F., @cVldGrupo, ::defGrupo()))
                        lRet := .F.
                        cError := cVldGrupo
                    EndIf
                    If lHasTGZ
                        If FindFunction("At190dDtPj")
                            At190dDtPj({xFilial("TGZ")+(::defEscala() + ::defConfal() + ::defPosto())+oMdlAux2:GetValue("TGZ_ITEM"),;
                            ::defDate()[1],;
                            ::defDate()[2],;
                            ::defGrupo(),;
                            ::defTec()})
                        Endif
                    EndIf
                    lRet := lRet .AND. oMdlAux2:SetValue("TGZ_GRUPO", ::defGrupo())
                    If !lHasTGZ .OR. oMdlAux2:GetValue("TGZ_DTFIM") < ::defDate()[2]
                        lRet := lRet .AND. oMdlAux2:SetValue("TGZ_DTFIM", ::defDate()[2])
                    EndIf
                    Exit
                Endif
            EndIf
        Next nX
        If (lRet := lRet .AND. oMdl580e:VldData() .And. oMdl580e:CommitData())
            oMdl580e:DeActivate()
            oMdl580e:Destroy()
            If !lHasTGZ
                ::defRec(SeekTGZ(::defTec(), ::defPosto(), ::defEscala(), ::defConfal(), ::defGrupo(), ::defRota() ))
            EndIf
        ElseIf oMdl580e:HasErrorMessage()
            lRet := .F.
            If !EMPTY(STRTRAN(Alltrim(oMdl580e:GetErrorMessage()[6]), CRLF))
                cError += STRTRAN(Alltrim(oMdl580e:GetErrorMessage()[6]), CRLF)
            EndIf
            If !EMPTY(STRTRAN(Alltrim(oMdl580e:GetErrorMessage()[7]), CRLF))
                If !EMPTY(cError)
                    cError += " / "
                EndIF
                cError += STRTRAN(Alltrim(oMdl580e:GetErrorMessage()[7]), CRLF)
            EndIf
        EndIf
        If !EMPTY(cError)
            ::defMessage(cError)
        EndIF
    EndIf
    At580BClHs()
    At580EGHor(.F.)
    If FindFunction("At190dDtPj")
        At190dDtPj(,.T.)
    EndIf
    FwModelActive(oMdlOLD)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} getAbbInfo

@description Busca agendas de RT

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
Static Function getAbbInfo(cCodTec,dDtIni,dDtFim,cHorIni,cHorFim,cTpMv)
Local aRet := {}
Local cSql := ""
Local cAliasQry

cSql := " SELECT ABB.ABB_CODIGO, ABB.ABB_FILIAL, ABB.ABB_CODTEC, ABB.ABB_IDCFAL, ABB.ABB_DTINI, "
cSql += " ABB.ABB_HRINI, ABB.ABB_DTFIM, ABB.ABB_HRFIM, ABB.ABB_ATENDE, ABB.ABB_CHEGOU, TDV.TDV_DTREF, ABB.R_E_C_N_O_ REC "
cSql += " FROM " + RetSqlName("ABB") + " ABB "
cSql += " INNER JOIN " + RetSqlName("TDV") + " TDV "
cSql += " ON " + FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.) + " "
cSql += " AND TDV.D_E_L_E_T_ = ' ' "
cSql += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
cSql += " WHERE "
cSql += " ABB.D_E_L_E_T_ = ' ' AND "
cSql += " ABB.ABB_CODTEC = '" + cCodTec + "' AND "
cSql += " ABB.ABB_DTINI = '" + DTOS(dDtIni) + "' AND "
cSql += " ABB.ABB_DTFIM = '" + DTOS(dDtFim) + "' AND "
cSql += " ABB.ABB_HRINI = '" + cHorIni + "' AND "
cSql += " ABB.ABB_HRFIM = '" + cHorFim + "' AND "
cSql += " ABB.ABB_TIPOMV = '" + cTpMv + "' "
If !(SuperGetMV("MV_GSMSFIL",,.F.) .AND. At680Perm(NIL, __cUserId, "043", .T.))
    cSql += " AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
EndIf
cSql := ChangeQuery(cSql)
cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
While !(cAliasQry)->(EOF())
    AADD(aRet, {;
        (cAliasQry)->ABB_CODIGO,;
        (cAliasQry)->ABB_FILIAL,;
        (cAliasQry)->ABB_CODTEC,;
        (cAliasQry)->ABB_IDCFAL,;
        SToD((cAliasQry)->ABB_DTINI),;
        (cAliasQry)->ABB_HRINI,;
        SToD((cAliasQry)->ABB_DTFIM),;
        (cAliasQry)->ABB_HRFIM,;
        (cAliasQry)->ABB_ATENDE,;
        (cAliasQry)->ABB_CHEGOU,;
        SToD((cAliasQry)->TDV_DTREF),;
        (cAliasQry)->REC;
    })
    (cAliasQry)->(dbSkip())
End
(cAliasQry)->(dbCloseArea())
Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} getAllAbbs

@description Busca agendas de RT baseando-se em outras agendas de RT

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
Static Function getAllAbbs(cIdcFal, cCodTec, cFilABB, cHrIni, cHrFim, cAtende, cChegou, dMenorDt)
Local aRet := {}
Local cSql := ""
Local cAliasQry

cSql := " SELECT ABB.ABB_CODIGO, ABB.ABB_FILIAL, ABB.ABB_CODTEC, ABB.ABB_IDCFAL, ABB.ABB_DTINI, "
cSql += " ABB.ABB_HRINI, ABB.ABB_DTFIM, ABB.ABB_HRFIM, ABB.ABB_ATENDE, ABB.ABB_CHEGOU, TDV.TDV_DTREF, ABB.R_E_C_N_O_ REC "
cSql += " FROM " + RetSqlName("ABB") + " ABB "
cSql += " INNER JOIN " + RetSqlName("TDV") + " TDV "
cSql += " ON " + FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.) + " "
cSql += " AND TDV.D_E_L_E_T_ = ' ' "
cSql += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
cSql += " WHERE "
cSql += " ABB.D_E_L_E_T_ = ' ' AND "
cSql += " ABB.ABB_CODTEC = '" + cCodTec + "' AND "
cSql += " ABB.ABB_HRINI = '" + cHrIni + "' AND "
cSql += " ABB.ABB_HRFIM = '" + cHrFim + "' AND "
cSql += " ABB.ABB_IDCFAL = '" + cIdcFal + "' AND "
cSql += " ABB.ABB_FILIAL = '" + cFilABB + "' AND "
cSql += " ABB.ABB_ATENDE = '" + cAtende + "' AND "
cSql += " ABB.ABB_CHEGOU = '" + cChegou + "' AND "
cSql += " ABB.ABB_DTINI > '" + DTOS(dMenorDt) + "' "

cSql := ChangeQuery(cSql)
cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
While !(cAliasQry)->(EOF())
    AADD(aRet, {;
        (cAliasQry)->ABB_CODIGO,;
        (cAliasQry)->ABB_FILIAL,;
        (cAliasQry)->ABB_CODTEC,;
        (cAliasQry)->ABB_IDCFAL,;
        SToD((cAliasQry)->ABB_DTINI),;
        (cAliasQry)->ABB_HRINI,;
        SToD((cAliasQry)->ABB_DTFIM),;
        (cAliasQry)->ABB_HRFIM,;
        (cAliasQry)->ABB_ATENDE,;
        (cAliasQry)->ABB_CHEGOU,;
        SToD((cAliasQry)->TDV_DTREF),;
        (cAliasQry)->REC;
    })
    (cAliasQry)->(dbSkip())
End
(cAliasQry)->(dbCloseArea())
Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} apagaRT

@description Apaga as agendas de RT ao Gravar a alocação

@author	boiani
@since	16/04/2020
/*/
//------------------------------------------------------------------------------
method apagaRT() class GsAloc

If !Empty(::aABBsRTDel)
    at190dELoc(ACLONE(::aABBsRTDel), .F.,.F.,.T.,.T.)
    ASIZE(::aABBsRTDel,1)
    ::aABBsRTDel := ARRAY(1)
EndIf

return
//------------------------------------------------------------------------------
/*/{Protheus.doc} vldData

@description Valida se será possível realizar a projeção das agendas

@author	boiani
@since	27/04/2020
/*/
//------------------------------------------------------------------------------
method vldData() class GsAloc
Local lRet      := .T.
Local dDtIniPosto
Local dDtFimPosto
Local dDtEnce   := CToD("")
Local lEnceDT	:= FindFunction("TecEncDtFt") .AND. TecEncDtFt() 


If lRet .And. !((FindFunction("U_PNMSESC") .And. FindFunction("U_PNMSCAL")) .OR. ( FindFunction( "TecExecPNM" ) .AND. TecExecPNM() ))
    ::defMessage(STR0020)
    //"Funcionalidade de alocação de atendente integrada com o Gestão de Escalas não disponivel. Necessário aplicar as configurações do RH (PNMTABC01) ou ativar o parametro 'MV_GSPNMTA'"
	lRet := .F.
EndIf

If lRet .And. !At680Perm(NIL, __cUserId, "039", .T.)
	::defMessage(STR0021) //"Usuário sem permissão de projetar agenda (TECA680)"
	lRet := .F.
EndIf

If lRet .And. EMPTY(::defTec())
    ::defMessage(STR0022) //"Código do atendente não preenchido. Por favor, preencha o código do atendente. Utilize o método defTec() para definir o código do atendente"
	lRet := .F.
EndIf

If lRet .And. Posicione("AA1",1,xFilial("AA1", ::defFil())+::defTec(),"AA1_ALOCA") == '2'
    ::defMessage(STR0023) //"Atendente não está disponível para alocação, realize manutenção no cadastro de Atendentes no campo AA1_ALOCA."
	lRet := .F.
EndIf

If lRet .And. EMPTY(::defEscala())
    ::defMessage(STR0024) //"O código da Escala não foi informado. Utilize o método defEscala() para defini-lo."
    lRet := .F.
EndIf

If lRet .And. EMPTY(::defPosto())
    ::defMessage(STR0025) //"O código do Posto não foi informado. Utilize o método defPosto() para defini-lo."
    lRet := .F.
EndIf

If lRet .And. EMPTY(::defGrupo())
    ::defMessage(STR0026) //"O código do Grupo não foi informado. Utilize o método defGrupo() para defini-lo."
    lRet := .F.
EndIf

If lRet .And. EMPTY(::defConfal())
    ::defMessage(STR0027) //"O código da Configuração de Alocação não foi informado. Utilize o método defConfal() para defini-lo. (TGY_CODTDX ou TGZ_CODTDX)"
    lRet := .F.
EndIf

If lRet .And. EMPTY(::defSeq())
    ::defMessage(STR0028) //"O código da Sequência não foi informado. Utilize o método defSeq() para defini-lo."
    lRet := .F.
EndIf

If lRet .And. EMPTY(::defTpAlo())
    ::defMessage(STR0029) //"O código do Tipo de Alocação não foi informado. Utilize o método defTpAlo() para defini-lo."
    lRet := .F.
EndIf

dDtIniPosto := POSICIONE("TFF",1,xFilial("TFF",::defFil())+::defPosto(),"TFF_PERINI")
dDtFimPosto := POSICIONE("TFF",1,xFilial("TFF",::defFil())+::defPosto(),"TFF_PERFIM")
cEscala := POSICIONE("TFF",1,xFilial("TFF",::defFil())+::defPosto(),"TFF_ESCALA")
    
If lRet .And. FindFunction('TecABBPRHR') .AND. TecABBPRHR()
    If TecConvHr(POSICIONE("TFF",1,xFilial("TFF",::defFil())+::defPosto(),"TFF_QTDHRS")) > 0
        ::defMessage(STR0030) //"Alocação por horas não disponível no método."
        lRet := .F.
    EndIf
EndIf

If lRet .And. (EMPTY(::dDtIni) .OR. EMPTY(::dDtFim) .OR. ::dDtIni > ::dDtFim)
    ::defMessage(STR0031) //"A data de início deve ser menor ou igual a data de término."
    lRet := .F.
EndIf

If lEnceDT
    dDtEnce := POSICIONE("TFF",1,xFilial("TFF",::defFil())+::defPosto(),"TFF_DTENCE")
    If lRet .And. Posicione("TFF",1,xFilial("TFF",::defFil())+::defPosto(),"TFF_ENCE") == '1';
       .AND. (dDtIniPosto >= dDtEnce .OR. dDtFimPosto >= dDtEnce) 		
        ::defMessage(STR0041+DToC(dDtEnce)+STR0042) //"Não é possível gerar nova(s) agenda(s), pois o posto possui encerramento para o dia " ## ". Com isso não é possível gerar agenda após essa data."
        lRet := .F.
    EndIf
Else
    If lRet .And. Posicione("TFF",1,xFilial("TFF",::defFil())+::defPosto(),"TFF_ENCE") == '1'
        ::defMessage(STR0032) //"Posto encerrado. Não é possível gerar novas agendas."
        lRet := .F.
    EndIf
EndIf

If lRet .And. EMPTY(dDtIniPosto) .OR. EMPTY(dDtFimPosto)
    ::defMessage(STR0033) //"Não foi possível localizar o Período Inicial (TFF_PERINI) ou o Período Final (TFF_PERFIM) do posto"
    lRet := .F.
EndIf

If lRet .And. (::dDtIni < dDtIniPosto .OR. ::dDtFim > dDtFimPosto)
    ::defMessage(STR0034 + DtoC(dDtIniPosto) + STR0035 + DtoC(dDtFimPosto) + STR0036)
    //"O período de alocação estipulado no posto inicia-se em " ## " e encerra-se em " ## ". Não é possível projetar agenda fora deste período."
    lRet := .F.
EndIf

If EMPTY(cEscala) .OR. cEscala != ::defEscala()
    ::defMessage(STR0037) //"A escala informada difere da escala do posto."
    lRet := .F.
EndIf

If lRet .And. TecBHasGvg() .And. Posicione("TFF",1,xFilial("TFF",::defFil())+::defPosto(),"TFF_GERVAG") == '2'
    ::defMessage(STR0040) //"Não é possivel selecionar Postos que não geram vaga operacional"
    lRet := .F.
EndIf

return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecRotaCb

@description Seleciona os dias e os horários trabalhados para o rotista

@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Static Function TecRotaCb(cCodTW0,cCodTW1)
Local cAliasTGW := GetNextAlias()
Local aRetCobRt := {}
Local nPos      := 0

BeginSql Alias cAliasTGW
    SELECT
        TDX.TDX_TURNO,
        TDX.TDX_SEQTUR,
        TGW.TGW_DIASEM,
        TGW.TGW_HORINI, 
        TGW.TGW_HORFIM,
        TGW.TGW_COBTIP
    FROM
        %table:TW1% TW1
    INNER JOIN %table:TW0% TW0 ON 
        TW0.TW0_FILIAL = %xFilial:TW0% AND
        TW0.TW0_COD    = TW1.TW1_CODTW0 AND
        TW0.%NotDel%	
    INNER JOIN %table:TFF% TFF ON 
        TFF.TFF_FILIAL = TW1.TW1_FILTFF AND
        TFF.TFF_COD    = TW1.TW1_CODTFF AND
        TFF.%NotDel%
    INNER JOIN %table:TDW% TDW ON 
        TDW.TDW_FILIAL = %xFilial:TDW% AND
        TDW.TDW_COD    = TFF.TFF_ESCALA AND
        TDW.%NotDel%
    INNER JOIN %table:TDX% TDX ON
        TDX.TDX_FILIAL = %xFilial:TDX% AND
        TDX.TDX_CODTDW = TDW.TDW_COD   AND
        TDX.TDX_TURNO  = TW1.TW1_TURNO AND
        TDX.%NotDel%	
    INNER JOIN %table:TGX% TGX ON
        TGX.TGX_FILIAL = %xFilial:TGX%  AND
        TGX.TGX_CODTDW = TDX.TDX_CODTDW AND
        TGX.TGX_TIPO = TW0.TW0_TIPO AND
        TGX.%NotDel%
    INNER JOIN %table:TGW% TGW ON
        TGW.TGW_FILIAL = %xFilial:TGW% AND
        TGW.TGW_EFETDX = TDX.TDX_COD   AND
		TGW.TGW_COBTDX = TGX.TGX_ITEM  AND
        TGW.%NotDel%
    WHERE 
        TW1.TW1_FILIAL = %xFilial:TW1% AND
        TW1.TW1_CODTW0 = %Exp:cCodTW0% AND
        TW1.TW1_COD    = %Exp:cCodTW1% AND
        TW1.%NotDel%
    ORDER BY TDX_CODTDW,TDX_TURNO,TDX_SEQTUR,TGW.TGW_DIASEM
EndSql

While (cAliasTGW)->(!Eof())
	nPos := aScan( aRetCobRt, { |x| x[1] == (cAliasTGW)->TDX_TURNO .And. x[2] == (cAliasTGW)->TDX_SEQTUR } )
	If nPos == 0
        aAdd( aRetCobRt, { (cAliasTGW)->TDX_TURNO , (cAliasTGW)->TDX_SEQTUR , {} } )        
        nPos := Len(aRetCobRt)
    Endif
    If nPos > 0
        aAdd( aRetCobRt[nPos,3], { (cAliasTGW)->TGW_COBTIP,;
                                   (cAliasTGW)->TGW_DIASEM,;
                                   TecGsHrRt((cAliasTGW)->TGW_COBTIP,"TGW_HORINI",cCodTW0+cCodTW1,(cAliasTGW)->TGW_HORINI),;
                                   TecGsHrRt((cAliasTGW)->TGW_COBTIP,"TGW_HORFIM",cCodTW0+cCodTW1,(cAliasTGW)->TGW_HORFIM)} )
    Endif
    (cAliasTGW)->(dbSkip())
EndDo

(cAliasTGW)->(DbCloseArea())
Return aRetCobRt

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecRotaCb

@description Seleciona os dias e os horários trabalhados para o rotista

@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Static Function TecGsHrRt(cCobTip,cCamp,cChavTW1,nHrRota)
Local nRetHr := nHrRota
If cCobTip $ "2|3"
    DbSelectArea("TW1")
    TW1->(DbSetOrder(1))
    If TW1->(MsSeek(xFilial("TW1")+cChavTW1))
        If cCamp == "TGW_HORINI" .And. !Empty(TW1->TW1_HORINI)
            nRetHr := TW1->TW1_HORINI
        Elseif cCamp == "TGW_HORFIM" .And. !Empty(TW1->TW1_HORFIM)
            nRetHr := TW1->TW1_HORFIM
        Endif
    Endif
Endif
Return nRetHr
