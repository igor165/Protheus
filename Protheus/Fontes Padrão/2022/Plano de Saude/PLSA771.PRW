#INCLUDE "plsa771.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TCBROWSE.CH"
#Include "RwMake.ch"
#Include "MsOle.ch"

#Define CRLF	Chr(13) + Chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ PLSA771 ณ Autor ณ Michel Montoro         ณ Data ณ 01.03.13 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Rotina para gera็ใo de Aviso de Cobran็a e bloqueio de     ณฑฑฑ
ฑฑณ          ณ familias.                                                  ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณSintaxe   ณ PLSA771()                                                  ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Uso      ณ PLS                                                        ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Alteracoes desde sua construcao inicial.                              ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Data     ณ BOPS ณ Programador ณ Breve Descricao                       ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ          ณ      ณ             ณ                                       ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSA771()
Local cPerg := "PLA771"
Local aParam := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ajusta perguntas                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CriaSX1(cPerg,1)

If !Pergunte(cPerg,.T.)
	Return(.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Valida perguntas                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BG1->( dbSetorder(01) )
If (mv_par11 == 2) .AND. ( EMPTY(mv_par08) .OR. !BG1->(MsSeek(xFilial("BG1")+AllTrim(mv_par08))) )
	MsgAlert(STR0001) // "O parโmetro [Mot. Bloq. Financeiro] nใo existe !!!"
	Return(.F.)
Endif

If (mv_par11 == 2) .AND. (mv_par11 <= 0)
	MsgAlert(STR0002) // "O parโmetro [Dias Ap๓s Receb. Aviso] deve ser preenchido !!!"
	Return(.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros cadastrais                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aParam := { mv_par01,       mv_par02,     mv_par03,     mv_par04,    mv_par05,   mv_par06,;
           (mv_par07 == 1), mv_par08,     mv_par09,    mv_par10,   mv_par11}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Executa funcao que ira bloquear os contratos...                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Processa( {|| A771Acao(aParam) }, STR0003) // "Processando..."

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ A771Acaoณ Autor ณ Michel Montoro         ณ Data ณ 01.03.13 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Executa as a็๕es da rotina                                 ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A771Acao(aParam)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis dos parametros...                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Local nTpCont	:= aParam[01]
Local nTpAcao	:= aParam[01]
Local cIntDe	:= aParam[02]
Local cIntAte	:= aParam[03]
Local cGruDe	:= aParam[04]
Local cGruAte	:= aParam[05]
//Local cConDe	:= aParam[06]
//Local cConAte	:= aParam[07]
//Local cSubDe	:= aParam[08]
//Local cSubAte	:= aParam[09]
Local dRefFin	:= aParam[06]
Local lConsEmi	:= aParam[07]
Local cMotBloq  := aParam[08]
Local dDatBloq  := IIf(EMPTY(aParam[09]),dDataBase,aParam[09])
Local nDiasRec  := aParam[10]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis locais...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cInd      := CriaTrab(nil,.F.)
Local cOrdem    := ''
Local cFor      := ''
Local lBloqFam  := .F.
Local lRet      := .T.
Local nRecBA3   := BA3->( Recno() )
Local nRecBA1   := BA1->( Recno() )
Local aDadUsr   := {}
Local aPosFin   := {}
Local aRetFin   := {}
Local aLinMark  := {}
Local aBloque   := {}
Local aCabBA1   := {}
Local cCpoBrw   := ""
Local aCpoAdic  := {"","",""}
Local cSql      := ""
Local nI := 0
Local cAlias	:= GetNextAlias()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define ordem default no arquivo de contas a receber...              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRetFin := PLA771FIN(cIntDe,cIntAte,cGruDe,cGruAte,dRefFin)

If nTpAcao <> 3 // Qualquer op็ใo diferente de [Ajustar Datas]
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicia a verificacao das familias selecionadas...                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nI:= 1 To Len(aRetFin)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona na familia...                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !EMPTY(aRetFin[nI,03]) // Matricula nao vazia
			BA3->(DbSetOrder(1)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
			BA3->( dbSeek(xFilial("BA3")+aRetFin[nI,01]+aRetFin[nI,02]+aRetFin[nI,03]) )
		Else
			Loop
	  	//	BA3->(DbSetOrder(7)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_MATRIC
		//	BA3->( dbSeek(xFilial("BA3")+aRetFin[nI,01]+aRetFin[nI,02]+aRetFin[nI,07]+aRetFin[nI,08]+aRetFin[nI,09]+aRetFin[nI,10]) )
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ IncProc                                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IncProc( STR0004 + Transform((BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC), __cPictFam) ) // "Analisando familia - "
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona o grupo empresa...                                        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BA1->(DbSetOrder(2))
		BG9->(DbSeek(xFilial("BG9")+BA3->BA3_CODEMP))
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona o titular da familia...                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BA1->(DbSetOrder(2))
		BA1->( dbSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Monta matriz padrao com os dados do usuario...                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aDadUsr := {}
		aAdd(aDadUsr,aRetFin[nI,04])  // cCodCli
		aAdd(aDadUsr,aRetFin[nI,05])  // cLoja
		aAdd(aDadUsr,aRetFin[nI,06])  // cNivCob
		aAdd(aDadUsr,BA3->BA3_CONEMP) // cConEmp - aRetFin[nI,07]
		aAdd(aDadUsr,BA3->BA3_VERCON) // cVerCon - aRetFin[nI,08]
		aAdd(aDadUsr,BA3->BA3_SUBCON) // cSubCon - aRetFin[nI,09]
		aAdd(aDadUsr,BA3->BA3_VERSUB) // cVerSub - aRetFin[nI,10]
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Avalia a posicao financeira da familia usando funcao generica.      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aPosFin := PLSVLDFIN(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),dRefFin,'','','',Nil,Nil,Nil,aDadUsr)
		If !aPosFin[1]
			lBloqFam := .T.
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ A familia nao foi bloqueada, agora analiza regras individuais       ณ
		//ณ para ver se algum usuario sera bloqueado...                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lBloqFam
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Posiciona o titular da familia...                                   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BA1->( MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Para cada familia lida verifico a impressใo do Aviso de Cobranca... ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nTpAcao == 1		// Analisa e nao bloqueia
				If !( !lConsEmi .AND. !EMPTY(BA1_EMIAVC) )
					aAdd( aLinMark, { BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), ;
						BA1->BA1_CPFUSR,BA1->BA1_MATVID,BA1->BA1_NOMUSR,BA1->BA1_DATNAS, ;
						StrZero(VAL(aPosFin[2,2,3]),2),aPosFin[2,3,3],aPosFin[2,4,3],BA1->(Recno()),.F. } )
	
					aCpoAdic := {{aPosFin[2,2,2],"C"}, {aPosFin[2,3,2],"C"}, {aPosFin[2,4,2],"N"}}
				EndIf
			EndIf
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Bloqueio apenas para BA1_RECAVC preenchido - Dt Recebimento Aviso Cobranca   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nTpAcao == 2 // Efetua o bloqueio
				If !EMPTY(BA1->BA1_EMIAVC) .AND. !EMPTY(BA1->BA1_RECAVC) .AND. (dDatBloq >= (BA1->BA1_RECAVC + nDiasRec)) ;
	            .AND. EMPTY(BA1->BA1_MOTBLO) .AND. EMPTY(BA1->BA1_DATBLO)
					aAdd( aLinMark, { BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), ;
						BA1->BA1_CPFUSR,BA1->BA1_MATVID,BA1->BA1_NOMUSR,BA1->BA1_DATNAS,BA1->BA1_EMIAVC,BA1->BA1_RECAVC, ;
						StrZero(VAL(aPosFin[2,2,3]),2),aPosFin[2,3,3],aPosFin[2,4,3],BA1->(Recno()),.F. } )
					
					aCpoAdic := {{aPosFin[2,2,2],"C"}, {aPosFin[2,3,2],"C"}, {aPosFin[2,4,2],"N"}}
				EndIf
			EndIf
	
			If nTpAcao == 4 // Relat๓rio
				aAdd( aLinMark, { BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), ;
						BA1->BA1_CPFUSR,BA1->BA1_MATVID,BA1->BA1_NOMUSR,BA1->BA1_DATNAS,BA1->BA1_EMIAVC,BA1->BA1_RECAVC, ;
						StrZero(VAL(aPosFin[2,2,3]),2),aPosFin[2,3,3],aPosFin[2,4,3],BA1->(Recno()),.F. } )
			EndIf		
		EndIf
	
		lBloqFam := .F.	
	Next nI
Else
	
	// Caso selecionado a op็ใo Limpar as Datas, tratar de forma diferenciada.
	cSql := "SELECT BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO, " + CRLF	
	cSql += "BA1.BA1_CPFUSR, BA1.BA1_MATVID, BA1.BA1_NOMUSR, BA1.BA1_DATNAS, BA1.BA1_EMIAVC, BA1.BA1_RECAVC, BA1.R_E_C_N_O_ AS BA1RECNO " + CRLF
	cSql += "FROM "+ RetSqlName("BA1") +" BA1 " + CRLF
	cSql += "WHERE" + CRLF
	cSql += "	BA1.D_E_L_E_T_ = ' ' " + CRLF
	cSql += "	AND BA1.BA1_FILIAL  = '"+ xFilial("BA1") +"' " + CRLF
	cSql += "	AND (BA1_EMIAVC <> ' ' OR BA1_EMIAVC <> ' ') " + CRLF
	
	cSql := ChangeQuery(cSql)
	
	If Select(cAlias) > 0
		(cAlias)->( DBCloseArea() )
	EndIf
	DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , cAlias , .F. , .T. )
	
	DBSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	
	While (cAlias)->(!Eof())
	
		aAdd( aLinMark, { (cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), ;
			(cAlias)->BA1_CPFUSR,(cAlias)->BA1_MATVID,(cAlias)->BA1_NOMUSR,SToD((cAlias)->BA1_DATNAS),SToD((cAlias)->BA1_EMIAVC), ;
			SToD((cAlias)->BA1_RECAVC), (cAlias)->BA1RECNO,.F. } )
	
		(cAlias)->(dbSkip())		
	EndDo
	(cAlias)->(DBCloseArea())
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Daqui para baixo trata os resultados de aLinMark para cada Acao...  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Abre MarkBrowse para escolha da impressใo dos Avisos de Cobran็a... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTpAcao == 1	// Imprime Aviso de Cobran็a
	If Len(aLinMark) > 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Carrega tabela BA1                                                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cCpoBrw := "BA1_CPFUSR,BA1_MATVID,BA1_NOMUSR,BA1_DATNAS"
		Store Header "BA1" TO aCabBA1 For ( AllTrim(SX3->X3_CAMPO) $ cCpoBrw )
		aCabBA1 := fAddCBrw(aCabBA1,aCpoAdic,cCpoBrw)
		lRet := MarkBCob(aLinMark,aCabBA1,nTpAcao,020,015,040,015,490,175)
	Else
		MsgAlert(STR0005) // "Nใo encontrado inadimplentes pelo filtro selecionado !!!"
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Abre MarkBrowse para escolha dos usuแrios que serใo bloqueados  ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTpAcao == 2	// Efetua o bloqueio
	If Len(aLinMark) > 0
		aBloque := { cMotBloq, dDatBloq }
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Carrega tabela BA1                                                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cCpoBrw := "BA1_CPFUSR,BA1_MATVID,BA1_NOMUSR,BA1_DATNAS,BA1_EMIAVC,BA1_RECAVC"
		Store Header "BA1" TO aCabBA1 For ( AllTrim(SX3->X3_CAMPO) $ cCpoBrw )
		aCabBA1 := fAddCBrw(aCabBA1,aCpoAdic,cCpoBrw)
		lRet := MarkBCob(aLinMark,aCabBA1,nTpAcao,020,015,040,015,490,175,aBloque)
	Else
		MsgAlert(STR0005) // "Nใo encontrado inadimplentes pelo filtro selecionado !!!"
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Abre MarkBrowse para escolha dos usuแrios que serใo Limpos ...      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTpAcao == 3	// Ajustar Datas
	If Len(aLinMark) > 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Carrega tabela BA1                                                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cCpoBrw := "BA1_CPFUSR,BA1_MATVID,BA1_NOMUSR,BA1_DATNAS,BA1_EMIAVC,BA1_RECAVC"
		aCpoAdic := {}
		Store Header "BA1" TO aCabBA1 For ( AllTrim(SX3->X3_CAMPO) $ cCpoBrw )
		aCabBA1 := fAddCBrw(aCabBA1,aCpoAdic,cCpoBrw)
		lRet := MarkBCob(aLinMark,aCabBA1,nTpAcao,020,015,040,015,490,175)
	Else
		MsgAlert(STR0005) // "Nใo encontrado inadimplentes pelo filtro selecionado !!!"
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza dados em disco...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BA3->( DbCommitAll() )
BA3->( dbClearFilter() )
BA3->( dbGoto(nRecBA3) )
BA1->( DbCommitAll() )
BA1->( dbGoto(nRecBA1) )
BE7->( DbCommitAll())

If nTpAcao == 4 // Relat๓rios
	If ExistBlock("PL771REL")
		// Executa o rdmake de emissao do relatorio especifico
		ExecBlock("PL771REL", .F., .F., {} )
	Else
		PL771IMP(aLinMark)
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณfAddCBrw ณ Autor ณ Michel Montoro         ณ Data ณ 01.03.13 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Ajusta os campos que serใo apresentados no MarkBrowse      ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fAddCBrw(aCabBA1,aCpoAdic,cCpoBrw)

Local nFor 		:= 0
Local nTamIni	:= 0
Local aCabAux	:= {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Exclui campos do Browse nใo necessใrios...                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
For nFor := 1 To Len(aCabBA1)
	If aCabBA1[nFor,2] $ cCpoBrw
		aAdd( aCabAux,aCabBA1[nFor])
	EndIf
Next nFor 
aCabBA1 := aCabAux

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona campo no inํcio do Browse...                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCabAux := {}
aAdd( aCabAux, {STR0006,"","@!",17,00,"","€€€€€€€€€€€€€€ ","C",NIL,""}) // "Matrํcula"
For nFor := 1 To Len(aCabBA1)
	aAdd( aCabAux,aCabBA1[nFor])
Next nFor
aCabBA1 := aCabAux

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona campos no final do Browse...                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTamIni	:= Len(aCabBA1)
For nFor := 1 To Len(aCpoAdic)
	aAdd( aCabBA1, {"","","@!",30,00,"","€€€€€€€€€€€€€€ ","C",NIL,""})

	aCabBA1[nFor+nTamIni,01] := aCpoAdic[nFor,01]
	aCabBA1[nFor+nTamIni,04] := IIf(aCpoAdic[nFor,02] == "N",17,30)
	aCabBA1[nFor+nTamIni,05] := IIf(aCpoAdic[nFor,02] == "N",02,00)
	aCabBA1[nFor+nTamIni,08] := aCpoAdic[nFor,02]
Next nFor

Return(aCabBA1)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณMarkBCob ณ Autor ณ Michel Montoro         ณ Data ณ 01.03.13 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Apresenta o MarkBrowse                                     ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MarkBCob(aLinha,aCabecalho,nTpAcao,nCheLi,nCheCo,nPosLI,nPosCI,nPosCF,nPosLF,aBloque)

	Static objCENFUNLGP := CENFUNLGP():New()

Local nFor		:= 0
Local nOpca    	:= 0
Local nQtdSel	:= 0
Local bOK      	:= { || nOpca := 1, oDlg:End() }
Local bCancel  	:= { || nOpca := 0, oDlg:End() }
Local aSels		:= {}
Local lRet 		:= .T.
Local lCheck 	:= .T. 
Local bBlock
Local oCheck
Local oDlg
Local cTitulo	:= FunDesc() // "Aviso de Cobran็a"
LOCAL aCampos	:= {}

Default aBloque := {}

PRIVATE oLista 
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define dialogo...                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 030,020 TO 060 ,150 OF GetWndDefault()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Checkbox para marcar e desmarcar todos                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ nCheLi,nCheCo CHECKBOX oCheck VAR lCheck PROMPT STR0009 OF oDlg SIZE 100,8 // "Marca e Desmarca todos" 	
	oCheck:bChange := {|| MsAguarde( {|| MarcaLinha('',aLinha,lCheck),oLista:Refresh() } ) }   

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta o TcBrowse                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oLista := TcBrowse():New( nPosLI,nPosCI,nPosCF,nPosLF,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona o BitMap de marcado e desmarcado                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	add COLUMN To oLista BitMap Data { || LoadBitMap( GetResources(), Iif(!aLinha[oLista:nAt,Len(aLinha[oLista:nAt])] ,EVal({|| lCheck := .F.,"LBNO"}),"LBOK" ) )} Title "" WIDTH 015 NOHILITE
	aadd(aCampos , .F.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega o cabecalho                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nFor := 1 to Len(aCabecalho)
	     bBlock := "{ || aLinha[oLista:nAt, "+Str(nFor,4)+"] }"
	     bBlock := &bBlock
		 aadd(aCampos , aCabecalho[nFor,2])
	     oLista:AddColumn(TcColumn():New(aCabecalho[nFor,1],bBlock,aCabecalho[nFor,3],Nil,Nil,Nil,IiF(Len(aCabecalho[nFor,1]) > aCabecalho[nFor,4],Len(aCabecalho[nFor,1])*3.6,aCabecalho[nFor,4]*3.6),.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	Next

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oLista:aObfuscatedCols := aBls
	endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega os dados                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oLista:SetArray(aLinha)   

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Duploclick na linha                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    oLista:BLDBLCLICK := { || MarcaLinha(oLista:nAt,aLinha,lCheck) , oLista:Refresh() }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ativa a dialogo...                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTER

If nOpca = K_OK
	aSels := {}
	For nFor := 1 to Len(aLinha)	
		If aLinha[nFor,(Len(aCabecalho)+2)]	//LINHA MARCADA
			nQtdSel += 1
		EndIf
	Next nFor
	   
	If nQtdSel > 0	//Selecionada
		
		If nTpAcao == 1
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Impressใo dos Avisos de Cobran็a...                                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If MsgYesNo(AllTrim(Str(nQtdSel)) + "  " + STR0010) // "Carta(s) de Aviso(s) de Cobran็a serแ(ใo) gerado(s). Confirma ?"
				For nFor := 1 to Len(aLinha)				
					If aLinha[nFor,(Len(aCabecalho)+2)]	// Linha marcada
						aAdd(aSels,{aLinha[nFor,LEN(aLinha[nFor])-1],aCabecalho[06,01],aLinha[nFor,06],aCabecalho[07,01],aLinha[nFor,07],aCabecalho[08,01],aLinha[nFor,08]})
					EndIf
				Next nFor
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava o Registro...                                                      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				lRet := PL771Avis(aSels)
			Else
				RollBackSX8()
			EndIf
		
		ElseIf nTpAcao == 2	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Efetua o bloqueio...                                                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If MsgYesNo(AllTrim(Str(nQtdSel)) + "  " + STR0011) // "Famํlia/Usuแrio(s) serแ(ใo) Bloqueado(s). Confirma ?"
				For nFor := 1 to Len(aLinha)				
					If aLinha[nFor,(Len(aCabecalho)+2)]	// Linha marcada
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Bloqueia o Registro...                                                   ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						lRet := PL771Bloq(aLinha[nFor,LEN(aLinha[nFor])-1],	aBloque[01], aBloque[02])
					EndIf
				Next nFor

				MsgAlert(STR0012) // "Famํlia/Usuแrio(s) foram Bloqueado(s) !!!"

			Else
				RollBackSX8()
			EndIf
		ElseIf nTpAcao == 3	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Efetua a Limpeza das Datas...                                       ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If MsgYesNo(AllTrim(Str(nQtdSel)) + "  " + STR0018) // "Famํlia/Usuแrio(s) terแ(ใo) suas datas de emissใo e recebimento limpas. Confirma ?"
				For nFor := 1 to Len(aLinha)				
					If aLinha[nFor,(Len(aCabecalho)+2)]	// Linha marcada
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Limpeza das Datas...                                                     ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						lRet := PL771Limp(aLinha[nFor,LEN(aLinha[nFor])-1])
					EndIf
				Next nFor

				MsgAlert(STR0019) // "Datas de Emissใo e Recebimento foram alteradas !!!"

			Else
				RollBackSX8()
			EndIf				
		EndIf
	Else
		MsgAlert(STR0013) // "Nenhum registro foi selecionado !!!"
	EndIf

EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ CriaSX1 ณ Autor ณ Michel Montoro         ณ Data ณ 01.03.13 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ                                                            ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CriaSX1(cPerg,nTipo)

Local aRegs	:=	{}

If nTipo == 1

	aAdd(aRegs, { cPerg,"01","Operadora De                  ","","","mv_ch1","C",04,0,0,"G","        ","mv_par01","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B89PLS","N","",""})
	aAdd(aRegs, { cPerg,"02","Operadora Ate                 ","","","mv_ch2","C",04,0,0,"G","        ","mv_par02","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B89PLS","N","",""})
	aAdd(aRegs, { cPerg,"03","Grupo/Empresa De              ","","","mv_ch3","C",04,0,0,"G","        ","mv_par03","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7APLS","N","",""})
	aAdd(aRegs, { cPerg,"04","Grupo/Empresa Ate             ","","","mv_ch4","C",04,0,0,"G","        ","mv_par04","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7APLS","N","",""})
	aAdd(aRegs, { cPerg,"05","Data ref. Financeiro          ","","","mv_ch5","D",08,0,0,"G","        ","mv_par05","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})
	aAdd(aRegs, { cPerg,"06","Acao da Rotina de Aviso       ","","","mv_ch6","N",01,0,1,"C","        ","mv_par06","Gerar Aviso    ","","","","","Bloqueia       ","","","","","Limpar as Datas","","","","","Relat๓rio ","","","","","","","","","      ","N","",""})
	aAdd(aRegs, { cPerg,"07","Considera jแ Emitidos? (Aviso)","","","mv_ch7","N",01,0,0,"C","        ","mv_par07","Sim            ","","","","","Nao            ","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})	
	aAdd(aRegs, { cPerg,"08","Mot. Bloq. Financeiro (Bloq)  ","","","mv_ch8","C",03,0,0,"G","naovazio","mv_par08","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","BAEPLS","N","",""})
	aAdd(aRegs, { cPerg,"09","Data do Bloqueio (Bloq)       ","","","mv_ch9","D",08,0,0,"G","        ","mv_par09","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})
	aAdd(aRegs, { cPerg,"10","Dias Apos Receb. Aviso (Bloq) ","","","mv_cha","N",03,0,1,"G","        ","mv_par10","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})
	aAdd(aRegs, { cPerg,"11","Tipo de Relat๓rio (Relatorio) ","","","mv_chb","N",01,0,1,"C","        ","mv_par11","Anแlise Aviso  ","","","","","Apenas Emitidos","","","","","Emitido e Receb","","","","","          ","","","","","","","","","      ","N","",""})
//	aAdd(aRegs, { cPerg,"01","Tipo Contrato ?               ","","","mv_ch1","C",01,0,0,"C","        ","mv_par01","Somente Fisica ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","      ","N","",""})
//	aAdd(aRegs, { cPerg,"06","Contrato De                   ","","","mv_ch6","C",12,0,0,"G","        ","mv_par06","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7BPLS","N","",""})
//	aAdd(aRegs, { cPerg,"07","Contrato Ate                  ","","","mv_ch7","C",12,0,0,"G","        ","mv_par07","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7BPLS","N","",""})
//	aAdd(aRegs, { cPerg,"08","Sub-Contrato De               ","","","mv_ch8","C",09,0,0,"G","        ","mv_par08","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7CPLS","N","",""})
//	aAdd(aRegs, { cPerg,"09","Sub-Contrato Ate              ","","","mv_ch9","C",09,0,0,"G","        ","mv_par09","               ","","","","","               ","","","","","               ","","","","","          ","","","","","","","","","B7CPLS","N","",""})

ElseIf nTipo == 2

	aAdd(aRegs, { cPerg,"01","Tipo de Relat๓rio             ","","","mv_ch1","N",01,0,1,"C","        ","mv_par21","Anแlise Aviso","","","","","Apenas Emitidos","","","","","Emitido e Receb","","","","","","","","","","","","","","      ","N","",""})

EndIf

PlsVldPerg( aRegs )
    
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL771Bloq บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua os bloqueios da Familia/Usuแrio                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function PL771Bloq(nBA1Rec,cMotBloq,dDatBloq)
Local lRet := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica origem do bloqueio e posiciona o cadastro...               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BG1->( dbSetorder(01) )
BG1->( MsSeek(xFilial("BG1")+cMotBloq) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona o titular da familia...                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BA1->(DbGoTo(nBA1Rec))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona na familia...                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BA3->( dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Bloqueia o Registro...                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lRet := PL260BLOCO("BA3",BA3->(RecNo()),4,.T.,cMotBloq,dDatBloq,BG1->BG1_BLOFAT)

If ValType(lRet) == "U" // Se PL260BLOCO retornar nil, vira True
	lRet := .T.
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL771Limp บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Famํlia/Usuแrio(s) terแ(ใo) suas datas de emissใo e        บฑฑ
ฑฑบ          ณ recebimento limpas.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function PL771Limp(nBA1Rec)
Local lRet := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona o titular da familia...                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BA1->(DbGoTo(nBA1Rec))

BA1->(RecLock("BA1",.F.))
	BA1->BA1_EMIAVC := CToD("")
	BA1->BA1_RECAVC := CToD("")
BA1->( MsUnlock() )

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL771Avis บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao das Cartas de Aviso de Cobran็a - ANS            บฑฑ
ฑฑบ          ณ Via Microsoft Word                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function PL771Avis(aSels)
Local nI			:= 0

Local lCopy1		:= .F.
Local lCopy2		:= .F.
Local lProc			:= .F.
Local lCriaDir		:= .T.

Local cArqAgl		:= ""
Local cLinAux		:= ""
Local cMensag		:= ""
Local cPathTMP		:= ""
Local cPathArq		:= GetNewPar( "MV_PLDIDOT" , "\DOT" ) // Define o local de origem dos arquivos de modelo .DOT dentro da pasta system que serใo utilizados pelo SIGAPLS.

Private aWord		:= {}
Private hWord		:= Nil
Private nConDoc		:= 0
Private cArqDot		:= ""
Private cPathEst	:= GetNewPar( "MV_PLDIRAC" , "C:\TEMP_AVISO" ) // Path onde serao gravados os arquivos DOT na estacao de trabalho referentes ao Aviso de Cobranca.

If Empty(cPathArq)
	cPathArq := GetSrvProfString("StartPath", "")
Else
	If !(Substr(cPathArq,1,1) == "\" .OR. Substr(cPathArq,1,1) == "/")
		cPathTMP := GetSrvProfString("StartPath", "")
		cPathArq := IIF( Substr(cPathTMP,Len(cPathTMP),1) $ "\/", cPathTMP, cPathTMP+"\" ) + cPathArq
	EndIf
EndIf
cPathArq := IIF( Substr(cPathArq,Len(cPathArq),1) $ "\/", cPathArq, cPathArq+"\" )

If Empty(cPathEst)
	cPathEst := GetTempPath()
EndIf

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Inicia a Integracao com o Word                                          บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
cArqDot := "Aviso_Cobranca.dot"
cArqAgl	:= "Avisos_Cobranca.dot"

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Se nao for alterado via parametro procura o arquivo na pasta "system"   บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
cPathDot := cPathArq + cArqDot
cPathAgl := cPathArq + cArqAgl

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Verifica a Existencia dos Arquivos DOT no StartPath do Protheus         บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
If !File(cPathDot)
	Aviso( "Atencao" , "O arquivo de Configura็ใo:"+ CRLF + cPathDot + CRLF +"nao foi encontrado pelo Servidor!" , {"Fechar"} )
	Return()
EndIf

If !File(cPathAgl)
	Aviso( "Atencao" , "O arquivo de Configura็ใo:"+ CRLF + cPathAgl + CRLF +"nao foi encontrado pelo Servidor!" , {"Fechar"} )
	Return()
EndIf

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Verifica Path do Temporแrio para grava็ใo na Estacao de Trabalho        บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
If Substr(cPathEst,1,1) == "\" .OR. Substr(cPathEst,1,1) == "/"
	cMensag := "Nใo foi validado o diret๓rio temporแrio da Esta็ใo:"+CRLF+ cPathEst +CRLF+"Os arquivos temporแrios serใo gravados no diret๓rio:"+CRLF+GetTempPath()
	Aviso( "Atencao" , cMensag , {"Fechar"} )
	cPathEst := GetTempPath()
EndIf

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Verifica Path para Armazenamento na Estacao de Trabalho                 บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
MontaDir( cPathEst )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Se ja existir arquivos no local, apaga para a nova geracao              บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
If File( Lower( cPathEst + "\" + cArqDot ) )
	Ferase( Lower( cPathEst + "\" + cArqDot ) )
EndIf

If File( Lower( cPathEst + "\" + cArqAgl ) )
	Ferase( Lower( cPathEst + "\" + cArqAgl ) )
EndIf

If File( Lower( cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ) )
	Ferase( Lower( cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ) )
EndIf

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Faz a copia dos arquivos do Servidor para o Remote                      บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
lCopy1 := CpyS2T( cPathDot , cPathEst , .F. )
lCopy2 := CpyS2T( cPathAgl , cPathEst , .F. )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Verifica as Copias                                                      บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
If !lCopy1 .Or. !lCopy2
	Aviso( "Processamento Cancelado" , "Houve um problema com a c๓pia dos arquivos de configura็ao:" + CRLF + cPathDot + CRLF + cPathEst , {"Fechar"} )
	Return()
EndIf

Processa( {|| lProc := GeraWord(aSels)} , "Iniciando o processamento..." , "Aguarde" , .F. )

If lProc

	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Fecha os Documentos                                                     บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	For nI := 1 to nConDoc
		OLE_CloseFile( aWord[nConDoc] )
		OLE_CloseLink( aWord[nConDoc] )
	Next nI
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Cria Documento Unico para aglutinar os resultados                       บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	hWord := OLE_CreateLink()
	OLE_NewFile( hWord , cPathEst + "\" + cArqAgl )
	OLE_SetPropertie( hWord, oleWdVisible, .F. )
	
	OLE_SetDocumentVar(hWord , 'nQtArqs' , nConDoc )
	OLE_SetDocumentVar(hWord , 'nomeArquivo' , "\ImpCarta" )
	OLE_SetDocumentVar(hWord , 'pastaDocs' , cPathEst )
	
	OLE_UpdateFields( hWord )
	OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument )
	
	OLE_ExecuteMacro( hWord , "JuntaTudo" )
	OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument )
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Pergunta se imprime os resultados                                       บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	If MsgYesNo("Total de Cartas de Aviso: "+ AllTrim(Str(nConDoc)) +"."+ CRLF +" Deseja Imprimir o Arquivo ?")
		OLE_PrintFile( hWord , "PART" , 2 , nConDoc + 1 , 1 )
		Aviso( "Aten็ใo" , "Arquivo enviado para impressao..." , {"Ok"} )
	Endif
	
	OLE_CloseFile( hWord )		// Fecha ultimo arquivo
	OLE_CloseLink( hWord )		// Fecha link com Word
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Apaga os Arquivos Temporarios                                           บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	For nI := 1 to nConDoc
		If File( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
			FErase( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
		EndIf
	Next
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ	Exclui os Arquivos Temporarios apos a utilizacao.                       บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	If File( Lower( cPathEst + "\" + cArqDot ) )
		Ferase( Lower( cPathEst + "\" + cArqDot ) )
	EndIf
	
	If File( Lower( cPathEst + "\" + cArqAgl ) )
		Ferase( Lower( cPathEst + "\" + cArqAgl ) )
	EndIf
		
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraWord บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que gera a pagina a ser impressa atraves do modelo. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GeraWord(aSels)

Local cSql		:= ''
Local cAlias	:= GetNextAlias()
Local nFor		:= 0
Local lRetGrv	:= .T.

For nFor := 1 to Len(aSels)
	cSql := "SELECT" + CRLF
	
	cSql += "	BA1.BA1_NOMUSR AS BENEF," + CRLF
	cSql += "	BA1.BA1_CODINT AS OPERADORA," + CRLF
	cSql += "	BA1.BA1_CODINT || BA1.BA1_CODPLA || BA1.BA1_VERSAO AS PLANO," + CRLF
	cSql += "	BA3.BA3_CODINT || BA3.BA3_CODPLA || BA3.BA3_VERSAO AS PLANO2," + CRLF
	cSql += "	BA3.BA3_CODINT || BA3.BA3_CODEMP || BA3.BA3_MATRIC AS MATRIC," + CRLF
	cSql += "	BA1.BA1_MUNICI AS CIDADE," + CRLF
	cSql += "	BA1.BA1_ESTADO AS UF," + CRLF
	cSql += "	BA1.R_E_C_N_O_ AS BA1RECNO " + CRLF
	
	cSql += "FROM "+ RetSqlName("BA1") +" BA1 "
	
	cSql += "	INNER JOIN "+ RetSqlName("BA3") +" BA3" + CRLF
	cSql += "	ON    BA1.BA1_FILIAL    = BA3.BA3_FILIAL " + CRLF
	cSql += "	AND BA1.BA1_CODINT      = BA3.BA3_CODINT " + CRLF
	cSql += "	AND BA1.BA1_CODEMP      = BA3.BA3_CODEMP " + CRLF
	cSql += "	AND BA1.BA1_CONEMP      = BA3.BA3_CONEMP " + CRLF
	cSql += "	AND BA1.BA1_VERCON      = BA3.BA3_VERCON " + CRLF
	cSql += "	AND BA1.BA1_SUBCON      = BA3.BA3_SUBCON " + CRLF
	cSql += "	AND BA1.BA1_VERSUB      = BA3.BA3_VERSUB " + CRLF
	cSql += "	AND BA1.BA1_MATRIC      = BA3.BA3_MATRIC " + CRLF
	cSql += "	AND BA3.D_E_L_E_T_      = '' " + CRLF
	
	cSql += "WHERE" + CRLF
	cSql += "		BA1.D_E_L_E_T_ = ''" + CRLF
	cSql += "AND	BA1.BA1_FILIAL = '"+ xFilial("BA1") +"'" + CRLF
	cSql += "AND 	BA1.R_E_C_N_O_ = " + AllTrim(STR(aSels[nFor,01])) + CRLF
	
	cSql := ChangeQuery(cSql)
	
	//MemoWrite("\system_rbra_sql\Query_AvCob.sql",cSql)
	
	If Select(cAlias) > 0
		(cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , cAlias , .F. , .T. )
	
	DBSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	
	If (cAlias)->(Eof())
		
		(cAlias)->(DBCloseArea())
		Aviso( "Aten็ใo" , "Nใo foram encontrados dados para processar com essa parametriza็ใo" , {"Fechar"} )
		Return(.F.)
		
	Else
		
		While (cAlias)->(!Eof())
			
			CriaNovo()
			ZeraCar()
			lRetGrv := GravaCar( cAlias, aSels[Ascan(aSels, {|x| x[1] == (cAlias)->BA1RECNO})] )
			If lRetGrv 
				PL771GrEmi((cAlias)->BA1RECNO, dDataBase)
			EndIf
			OLE_CloseFile( aWord[nConDoc] )
			OLE_CloseLink( aWord[nConDoc] )
		
			(cAlias)->(dbSkip())
		EndDo
		
		(cAlias)->(DBCloseArea())
		
	EndIf
Next nFor

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaCar บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que grava os dados da Consulta na Carta.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GravaCar( cAlias, aFinan )

Local aDados	:= Array(15)
Local cPlano	:= AllTrim( Posicione("BI3",1,xFilial("BI3")+(cAlias)->PLANO,"BI3_DESCRI") )
Local cOper		:= AllTrim( Posicione("BA0",1,xFilial("BA0")+(cAlias)->OPERADORA,"BA0_NOMINT") )
Local cTelCen	:= GetNewPar( "MV_PLSRTCA" , "" )	// Define o Telefone da Central de Atendimento a ser utilizado na impressใo de cartas do SIGAPLS
Local cEmail	:= GetNewPar( "MV_PLSREMA" , "" )	// Define o E-Mail da Central de Atendimento a ser utilizado pelo m๓dulo SIGAPLS

If Empty(cAlias)
	Return()
EndIf

If EMPTY(cPlano) // Se nใo achar Plano no BA1, tento o BA3
	cPlano	:= AllTrim( Posicione("BI3",1,xFilial("BI3")+(cAlias)->PLANO2,"BI3_DESCRI") )
EndIf

aDados[01] := IIf( Empty((cAlias)->CIDADE)  	, AllTrim( SM0->M0_CIDENT )           , AllTrim((cAlias)->CIDADE) )
aDados[02] := IIf( Empty((cAlias)->UF)      	, AllTrim( SM0->M0_ESTENT )           , AllTrim((cAlias)->UF) )
aDados[03] := StrZero(Day(Date()),2) +" de "+ MesExtenso( Month(Date()))  +" de "+  Str(Year(Date()),4)
aDados[04] := IIf( Empty((cAlias)->BENEF)   	, "[Erro ao identificar o Nome]"       , AllTrim((cAlias)->BENEF) )
aDados[05] := IIf( Empty(cOper)              	, "[Erro ao identificar a Operadora]"  , AllTrim(cOper) )
aDados[06] := IIf( Empty(cPlano)	            , "[Erro ao identificar o Plano]"      , AllTrim(cPlano) )
aDados[07] := IIf( Empty((cAlias)->MATRIC)  	, "[Erro ao identificar a Matrํcula]"  , AllTrim((cAlias)->MATRIC) )
aDados[08] := IIf( Empty(cTelCen)            	, "0800-000.0000"                      , AllTrim(cTelCen) )
aDados[09] := IIf( Empty(cEmail)             	, "email@empresa.com.br"               , AllTrim(cEmail) )

aDados[10] := aFinan[03]
aDados[11] := aFinan[05]
aDados[12] := aFinan[07]
aDados[13] := aFinan[02]
aDados[14] := aFinan[04]
aDados[15] := aFinan[06]

OLE_SetDocumentVar( aWord[nConDoc], "CIDADE"		, aDados[01] )
OLE_SetDocumentVar( aWord[nConDoc], "UF"			, aDados[02] )
OLE_SetDocumentVar( aWord[nConDoc], "DATA"			, aDados[03] )
OLE_SetDocumentVar( aWord[nConDoc], "NOMEBENEF"		, aDados[04] )
OLE_SetDocumentVar( aWord[nConDoc], "NOMEOPER"		, aDados[05] )
OLE_SetDocumentVar( aWord[nConDoc], "PLANO"			, aDados[06] )
OLE_SetDocumentVar( aWord[nConDoc], "MATRICULA"		, aDados[07] )
OLE_SetDocumentVar( aWord[nConDoc], "TELCENTRAL"	, aDados[08] )
OLE_SetDocumentVar( aWord[nConDoc], "EMAIL"			, aDados[09] )

OLE_SetDocumentVar( aWord[nConDoc], "VALTIT1"		, aDados[10] )
OLE_SetDocumentVar( aWord[nConDoc], "VALTIT2"		, aDados[11] )
OLE_SetDocumentVar( aWord[nConDoc], "VALTIT3"		, aDados[12] )
OLE_SetDocumentVar( aWord[nConDoc], "INFOTIT1"		, aDados[13] )
OLE_SetDocumentVar( aWord[nConDoc], "INFOTIT2"		, aDados[14] )
OLE_SetDocumentVar( aWord[nConDoc], "INFOTIT3"		, aDados[15] )

OLE_UpdateFields( aWord[nConDoc] )

OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".DOC" ,,, .F. , oleWdFormatDocument )

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL771GrEmiบ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava a data de emissใo do Aviso de Cobran็a               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PL771GrEmi( nRecno, dDataEmis )

Local lRet := .F.
Local aAreaBA1	:= BA1->(GetArea())

DEFAULT dDataEmis := dDataBase

If nRecno > 0

	BA1->(DbGoTo(nRecno))
	
	BA1->(RecLock("BA1",.F.))
		BA1->BA1_EMIAVC := dDataBase
	BA1->( MsUnlock() )
	
	lRet := .T.
	
EndIf

BA1->(RestArea(aAreaBA1)) 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ZeraCar  บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Zera os controladores para geracao de nova Carta.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ZeraCar()

OLE_SetDocumentVar( aWord[nConDoc], "NOMEBENEF"	, "" )
OLE_SetDocumentVar( aWord[nConDoc], "NOMEOPER"	, "" )
OLE_SetDocumentVar( aWord[nConDoc], "PLANO"		, "" )
OLE_SetDocumentVar( aWord[nConDoc], "MATRICULA"	, "" )
OLE_SetDocumentVar( aWord[nConDoc], "VALTIT1"	, "" )
OLE_SetDocumentVar( aWord[nConDoc], "VALTIT2"	, "" )
OLE_SetDocumentVar( aWord[nConDoc], "VALTIT3"	, "" )
OLE_SetDocumentVar( aWord[nConDoc], "INFOTIT1"	, "" )
OLE_SetDocumentVar( aWord[nConDoc], "INFOTIT2"	, "" )
OLE_SetDocumentVar( aWord[nConDoc], "INFOTIT3"	, "" )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaNovo บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o novo arquivo para gravacao.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CriaNovo()

aAdd( aWord , 0 )
nConDoc++

aWord[nConDoc] := OLE_CreateLink()

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Cria o novo arquivo no Remote                                           บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_NewFile( aWord[nConDoc] , cPathEst + "\" + cArqDot )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Ajusta Propriedades do Arquivo                                          บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_SetPropertie( aWord[nConDoc] , oleWdVisible , .F. )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Salva o arquivo com o novo nome no Remote                               บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".doc" ,,, .F. , oleWdFormatDocument )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PL771IMP บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que ira imprimir o arquivo de LOG.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PL771IMP(aLinMark)
Local nTipo := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao de variaveis utilizadas no relatorio de emissao do LOG    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel    := "PLSA771"         // Nome do Arquivo utilizado no Spool
Local Titulo   := FunDesc()         // "Aviso de Cobran็a"
Local cDesc1   := STR0015           // "Este programa irแ emitir uma rela็ใo famํlias e usuแrios encontradas"
Local cDesc2   := STR0016           // "no arquivo que atendam as regras dos parametros informados e"
Local cDesc3   := STR0017           // "poderใo ser posteriormente bloqueados."
Local nomeprog := "PLSA771.PRW"     // nome do programa
Local cString  := ""                // Alias utilizado na Filtragem
Local lDic     := .F.               // Habilita/Desabilita Dicionario
Local lComp    := .F.               // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro  := .F.               // Habilita/Desabilita o Filtro

Private Tamanho := "M"              // P/M/G
Private Limite  := 132              // 80/132/220
Private aReturn := { "Zebrado",;    //[1] Reservado para Formulario
					 1,;                 //[2] Reservado para Nง de Vias
					 "Administra็ใo",;   //[3] Destinatario
 					 2,;                 //[4] Formato => 1-Comprimido 2-Normal	
					 2,;                 //[5] Midia   => 1-Disco 2-Impressora
					 1,;                 //[6] Porta ou Arquivo 1-LPT1... 4-COM1...
					 "",;                //[7] Expressao do Filtro
					 1 }                 //[8] Ordem a ser selecionada
                                    //[9]..[10]..[n] Campos a Processar (se houver)

Private m_pag   := 1                // Contador de Paginas
Private nLastKey:= 0                // Controla o cancelamento da SetPrint e SetDefault
Private cPergta := "PLA771"         // Pergunta do Relatorio
Private aOrdem  := {}               // Ordem do Relatorio

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ajusta perguntas                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CriaSX1(cPergta,1)

wnrel:=SetPrint(cString,wnrel,cPergta,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If  nLastKey == 27
	Return(.F.)
Endif
SetDefault(aReturn,cString)
If  nLastKey == 27
    Return(.F.)
Endif

Pergunte(cPergta, .F.)
nTipo     := mv_par11  // Tipo do Relat๓rio

RptStatus( {|lEnd| ImpLog(@lEnd,wnRel,cString,nomeprog,Titulo,aLinMark,nTipo) }, Titulo)
		
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpLog    บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que ira imprimir o arquivo de LOG.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpLog(lEnd,wnrel,cString,nomeprog,Titulo,aLinMark,nTipo)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao Do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nLi		:= 0			// Linha a ser impressa
Local nMax		:= 58			// Maximo de linhas suportada pelo relatorio
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape
Local cCabec1	:= "" 			// Label dos itens
Local cCabec2	:= "" 			// Label dos itens

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis especificas para este relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nI		:= 0			// Controle de laco

cCabec1 := "MATRอCULA          CPF          MATR.VIDA  NOME USUมRIO                     EMISSAO     RECTO COBR.  PARCS.  DIAS ATRASO   SLD. TOTAL"

SetRegua( Len(aLinMark) )

For nI := 1 To Len(aLinMark)
	
	IncRegua()
	
	If lEnd
		@Prow()+1,000 PSay "CANCELADO PELO OPERADOR..."
		Exit
	Endif
	If fRegraImp(nTipo,aLinMark[nI]) // Verifica se imprime linha conforme regra
		IncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	
		@ nLi,000 PSay aLinMark[nI,01]              // Matricula
		@ nLi,019 PSay aLinMark[nI,02]              // CPF
		@ nLi,032 PSay aLinMark[nI,03]              // Matricula Vida
		@ nLi,043 PSay SUBSTR(aLinMark[nI,04],1,31) // Nome Usuแrio
		//@ nLi,045 PSay aLinMark[nI,05]             // Data de Nascto
		@ nLi,076 PSay DToC(aLinMark[nI,06])        // Dt. Emissao Aviso Cobran็a
		@ nLi,088 PSay DToC(aLinMark[nI,07])        // Dt. Recebto Aviso Cobran็a
		@ nLi,103 PSay aLinMark[nI,08]              // Parcelas em Aberto
		@ nLi,113 PSay aLinMark[nI,09]              // Dias de Atraso
		@ nLi,119 PSay Transform(VAL(aLinMark[nI,10]), "@E 999,999,999.99") // Saldo Total das Parcelas
	EndIf
Next nI

If nLi == 0
	IncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi+1,000 PSay "Nใo hแ informa็๕es para imprimir este relat๓rio"
Endif

Roda(cbCont,cbText,Tamanho)

Set Device To Screen
If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIncLine   บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Incrementa o contador de linhas para impressใo nos relato_ บฑฑ
ฑฑบ          ณ rios e verifica se uma nova pagina sera iniciada.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nLi      - Numero da linha em que sera impresso            บฑฑ
ฑฑบ          ณ nInc     - Quantidade de linhas a serem incrementadas      บฑฑ
ฑฑบ          ณ nMax     - Numero maximo de linhas por pagina              บฑฑ
ฑฑบ          ณ Titulo   - Titulo do cabecalho do relatorio                บฑฑ
ฑฑบ          ณ cCabec1  - Primeira linha do lalbel do relatorio           บฑฑ
ฑฑบ          ณ cCabec2  - Segunda linha do label do relatorio             บฑฑ
ฑฑบ          ณ NomeProg - Nome do programa que sera impresso no cabecalho บฑฑ
ฑฑบ          ณ Tamanho  - Tamanho de colunas do relatorio                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncLine(	nLi,		nInc,		nMax,		Titulo,;
							cCabec1,	cCabec2,	NomeProg,	Tamanho)

Local nChrComp	:= IIF(aReturn[4]==1,15,18)		// Define se o caracter sera comprimido ou normal

nLi+=nInc
If nLi > nMax .or. nLi < 5
	nLi := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nChrComp)
	nLi++
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfRegraImp บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se imprime linha conforme regra.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fRegraImp(nRegra,aLinha)
Local lRet := .F.

nRegra := IIf(EMPTY(nRegra),1,nRegra)

If nRegra == 1
	lRet := .T.
ElseIf nRegra == 2
	lRet := IIf(!EMPTY(aLinha[06]) .AND. EMPTY(aLinha[07]), .T., .F.)
ElseIf nRegra == 3
	lRet := IIf(!EMPTY(aLinha[06]) .AND. !EMPTY(aLinha[07]), .T., .F.)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLA771FIN บ Autor ณ Michel Montoro     บ Data ณ 13/03/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se usuario tem movimentacao no financeiro em      บฑฑ
ฑฑบ          ณ atraso                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLA771FIN(cIntDe,cIntAte,cGruDe,cGruAte,dRefFin)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis da rotina...                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
LOCAL aRet := {}

LOCAL cCodCli   := ""
LOCAL cLoja     := ""
LOCAL cNivCob   := ""    
LOCAL cConEmp   := ""
LOCAL cVerCon   := ""
LOCAL cSubCon   := ""
LOCAL cVerSub   := ""
LOCAL _cChavNiC := ""
LOCAL _bChavTit := {|| }

Local cSql		:= ''
Local cAlias	:= GetNextAlias()
Local nFor		:= 0

cSql := "SELECT " + CRLF	
//cSql += "	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_VENCREA, SE1.E1_VENCORI, " + CRLF
cSql += "	SE1.E1_CODINT, SE1.E1_CODEMP, SE1.E1_MATRIC, SE1.E1_CONEMP, SE1.E1_VERCON, SE1.E1_SUBCON, SE1.E1_VERSUB, " + CRLF
cSql += "	SE1.E1_CLIENTE, SE1.E1_LOJA, BBT.BBT_NIVEL " + CRLF
cSql += "FROM "+ RetSqlName("SE1") +" SE1 " + CRLF

cSql += "	INNER JOIN "+ RetSqlName("BBT") +" BBT " + CRLF
cSql += "	ON    BBT.BBT_FILIAL	   = '"+ xFilial("BBT") +"' " + CRLF
cSql += "	AND BBT.BBT_CODOPE      = SE1.E1_CODINT " + CRLF
cSql += "	AND BBT.BBT_CODEMP      = SE1.E1_CODEMP " + CRLF
cSql += "	AND BBT.BBT_CONEMP      = SE1.E1_CONEMP " + CRLF
cSql += "	AND BBT.BBT_VERCON      = SE1.E1_VERCON " + CRLF
cSql += "	AND BBT.BBT_SUBCON      = SE1.E1_SUBCON " + CRLF
cSql += "	AND BBT.BBT_VERSUB      = SE1.E1_VERSUB " + CRLF
cSql += "	AND BBT.BBT_MATRIC      = SE1.E1_MATRIC " + CRLF
cSql += "	AND BBT.BBT_PREFIX      = SE1.E1_PREFIXO " + CRLF
cSql += "	AND BBT.BBT_NUMTIT      = SE1.E1_NUM " + CRLF
cSql += "	AND BBT.BBT_PARCEL      = SE1.E1_PARCELA " + CRLF
cSql += "	AND BBT.BBT_TIPTIT      = SE1.E1_TIPO " + CRLF
cSql += "	AND BBT.D_E_L_E_T_      = ' ' " + CRLF

cSql += "WHERE" + CRLF
cSql += "	SE1.D_E_L_E_T_ = ' ' " + CRLF
cSql += "	AND SE1.E1_FILIAL  = '"+ xFilial("SE1") +"' " + CRLF
cSql += "	AND SE1.E1_CODINT >= '" + cIntDe  + "' " + CRLF
cSql += "	AND SE1.E1_CODINT <= '" + cIntAte + "' " + CRLF
cSql += "	AND SE1.E1_CODEMP >= '" + cGruDe  + "' " + CRLF
cSql += "	AND SE1.E1_CODEMP <= '" + cGruAte + "' " + CRLF
cSql += "	AND SE1.E1_VENCREA < '" + DToS(dRefFin) + "' " + CRLF
cSql += "	AND SE1.E1_SALDO > 0 " + CRLF
cSql += "	AND SE1.E1_STATUS = 'A' " + CRLF
// Somente para Pessoa Fisica
cSql += "	AND SE1.E1_CONEMP = '"+ Space(TamSx3("E1_CONEMP")[1]) +"' " + CRLF
cSql += "	AND SE1.E1_VERCON = '"+ Space(TamSx3("E1_VERCON")[1]) +"' " + CRLF
cSql += "	AND SE1.E1_SUBCON = '"+ Space(TamSx3("E1_SUBCON")[1]) +"' " + CRLF
cSql += "	AND SE1.E1_VERSUB = '"+ Space(TamSx3("E1_VERSUB")[1]) +"' " + CRLF

cSql += "GROUP BY " + CRLF	
//cSql += "	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_VENCREA, SE1.E1_VENCORI, " + CRLF
cSql += "	SE1.E1_CODINT, SE1.E1_CODEMP, SE1.E1_MATRIC, SE1.E1_CONEMP, SE1.E1_VERCON, SE1.E1_SUBCON, SE1.E1_VERSUB, " + CRLF
cSql += "	SE1.E1_CLIENTE, SE1.E1_LOJA, BBT.BBT_NIVEL " + CRLF

cSql := ChangeQuery(cSql)

DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , cAlias , .F. , .T. )

DBSelectArea(cAlias)
(cAlias)->(DBGoTop())

While (cAlias)->(!Eof())
	aAdd(aRet,{ ;
		(cAlias)->E1_CODINT, ;
		(cAlias)->E1_CODEMP, ;
		(cAlias)->E1_MATRIC, ;
		(cAlias)->E1_CLIENTE, ;
		(cAlias)->E1_LOJA, ;
		(cAlias)->BBT_NIVEL, ;
		(cAlias)->E1_CONEMP, ;
		(cAlias)->E1_VERCON, ;
		(cAlias)->E1_SUBCON, ;
		(cAlias)->E1_VERSUB ;
	})

	(cAlias)->(dbSkip())
EndDo

Return(aRet) 
