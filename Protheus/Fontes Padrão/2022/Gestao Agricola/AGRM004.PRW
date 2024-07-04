#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRM004  º Autor ³ Ricardo Tomasi     º Data ³  18/11/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Efetiva movimentação de estoque dos produtos utilizados na º±±
±±º          ³ rotina de abastecimento ou manutenção.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsiga                                         º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AGRM004()
Private cPerg := 'AGRM04'


If .Not. Pergunte(cPerg,.T.)
	Return()
EndIf

Processa({|| fProcessa() },'Efetuando pagamento de Diaristas...')

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funçào    ³fProcessa ³ Autor ³ Ricardo Tomasi        ³ Data ³ 09/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Executa processamento da rotina...                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGRM004                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fProcessa()
Local aArea     := GetArea()
Local cFilNQF   := ''
Local lImpMDO   := .t.
Local nCntDia   := 0
Local nCntTot   := 0
Local nVlrPar   := 0
Local nVlrTot   := 0

If mv_par08 <> 1; mv_par09 := cFilial; mv_par10 := cFilial; EndIf
cFilNQF += "NQF_CODMDO >= '"+mv_par02+"' .And. NQF_CODMDO <= '"+mv_par03+"' .And. "
cFilNQF += "NQF_FAZ >= '"+mv_par04+"' .And. NQF_FAZ <= '"+mv_par05+"' .And. "
cFilNQF += "DTOS(NQF_DATA) >= '"+DTOS(mv_par06)+"' .And. DTOS(NQF_DATA) <= '"+DTOS(mv_par07)+"' .And. "
cFilNQF += "AllTrim(DTOS(NQF_DATACR)) == '' .And. "
If mv_par08==1
	cFilNQF += "NQF_FILIAL >= '"+mv_par09+"' .And. NQF_FILIAL <= '"+mv_par10+"'"
Else
	cFilNQF += "NQF_FILIAL == '"+xFilial('NQF')+"'"
EndIf
dbSelectArea('NQF')
dbSetOrder(1)
dbSetFilter( {|| &cFilNQF }, cFilNQF )
dbGotop()
While .Not. Eof()

	lImpMDO := .t.
	nCntDia := 0
	nVlrPar := 0
	NNA->(dbSeek(xFilial('NNA')+NQF->NQF_CODMDO))

	Do While .Not. Eof() .And. NQF->NQF_CODMDO == NNA->NNA_CODIGO

		NN1->(dbSeek(xFilial('NN1')+NQF->NQF_SAFRA))
		dbSelectArea('NN2')
		dbSetOrder(2)
		dbSeek(xFilial('NN2')+NQF->NQF_FAZ)
		dbSelectArea('NQF')
		NN9->(dbSeek(xFilial('NN9')+NQF->NQF_CODSRV))

		If RecLock('NQF',.f.)
			NQF->NQF_DATACR := dDataBase
			msUnLock()
		EndIf

		nCntDia += 1
		nCntTot += 1
		nVlrPar += NQF->NQF_VALOR
		nVlrTot += NQF->NQF_VALOR

		dbSelectArea('NQF')
		dbSkip()
	EndDo

	If nCntDia > 0

//		@nLin, 001 PSay PadL('Total de diarias: ('+Transform(nCntDia, '@E 999')+') ---> ',140)
//		@nLin, 144 PSay Transform(nVlrPar, '@E 999,999,999.99')

	EndIf

EndDo

If nCntTot > 0

//	@nLin, 001 PSay PadL('Total geral de diarias: ('+Transform(nCntTot, '@E 999')+') --------> ',140)
//	@nLin, 144 PSay Transform(nVlrTot, '@E 999,999,999.99')

EndIf

RestArea(aArea)
Return()

