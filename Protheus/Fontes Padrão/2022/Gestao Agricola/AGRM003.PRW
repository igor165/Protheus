#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRM003  º Autor ³ Ricardo Tomasi     º Data ³  18/11/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Efetiva movimentação de estoque dos produtos utilizados na º±±
±±º          ³ rotina de abastecimento ou manutenção.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsiga                                         º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AGRM003()
Private cPerg := 'AGRM03'


If .Not. Pergunte(cPerg,.T.)
	Return()
EndIf

Processa({|| fProcessa() },'Gerando movimentação de estoque')

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funçào    ³fProcessa ³ Autor ³ Ricardo Tomasi        ³ Data ³ 09/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Executa processamento da rotina...                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGRM003                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fProcessa()
Local aMata240 := Array(0,0)
Local cFilNQD  := ''
Local nX       := 0
Local nZ       := 0

Private lMsErroAuto := .f.

dbSelectArea('NQD')
dbSetOrder(1)

cFilNQD := "DTOS(NQD_DATA) >= '"+DTOS(mv_par01)+"' .And. DTOS(NQD_DATA) <= '"+DTOS(mv_par02)+"' .And. "
cFilNQD += "NQD_LOCAL >= '"+mv_par04+"' .And. NQD_LOCAL <= '"+mv_par05+"' .And. "
cFilNQD += "NQD_TIPO $ '"+IIf(mv_par03=1,'A',IIf(mv_par03=2,'M','A#M'))+"' .And. "
cFilNQD += "AllTrim(NQD_CODPRO) <> '' .And. AllTrim(NQD_GEREST) <> 'S' .And. "
//Considera Filias
If mv_par06==1
	cFilNQD += "NQD_FILIAL >= '"+mv_par07+"' .And. NQD_FILIAL <= '"+mv_par08+"'"
Else
	cFilNQD += "NQD_FILIAL == '"+xFilial('NQD')+"'"
EndIf
dbSetFilter( {|| &cFilNQD }, cFilNQD )
ProcRegua(0)
dbGotop()

While .Not. Eof()

	nZ++
	aAdd(aMata240, {})

	//Posiciona Tabela de Produtos
	dbSelectArea('SB1')
	dbSetOrder(1)
	dbSeek(xFilial('SB1')+NQD->NQD_CODPRO)

	//Pega TM para movimentação
	dbSelectArea('SF5')
	dbSetOrder(1)
	If dbSeek(xFilial('SF5')+mv_par09)
		If SF5->F5_VAL=='S'
			aAdd(aMata240[nZ], {'D3_CUSTO1',NQD->NQD_CUSTO,Nil})
		EndIf
	Else
		Alert('TM para movimentação, não informada!')
		Return()
	EndIf

	aAdd(aMata240[nZ], {'D3_TM'     ,SF5->F5_CODIGO  ,Nil})
	aAdd(aMata240[nZ], {'D3_COD'    ,SB1->B1_COD     ,Nil})
	aAdd(aMata240[nZ], {'D3_UM'     ,SB1->B1_UM      ,Nil})
	aAdd(aMata240[nZ], {'D3_QUANT'  ,NQD->NQD_QTDPRO ,Nil})
	aAdd(aMata240[nZ], {'D3_LOCAL'  ,NQD->NQD_LOCAL  ,Nil})
	aAdd(aMata240[nZ], {'D3_EMISSAO',NQD->NQD_DATA   ,Nil})
	aAdd(aMata240[nZ], {'D3_DOC'    ,''              ,Nil})
	aAdd(aMata240[nZ], {'D3_CONTA'  ,NQD->NQD_CONTA ,Nil})
	aAdd(aMata240[nZ], {'D3_CC'     ,NQD->NQD_CC    ,Nil})
	aAdd(aMata240[nZ], {'D3_CLVL'   ,NQD->NQD_CLVL  ,Nil})
	aAdd(aMata240[nZ], {'D3_ITEMCTA',NQD->NQD_ITEMCT,Nil})

	dbSelectArea('NQD')
	If RecLock('NQD',.f.)
		NQD->NQD_GEREST := 'S'
		msUnLock()
	EndIf
	dbSkip()
	IncProc()
EndDo

For nX := 1 to Len(aMata240)

	MSExecAuto({|x,y| mata240(x,y)},aMata240[nX],3)

	If lMsErroAuto
		DisarmTransaction()
		Mostraerro()
		Return()
	EndIf

Next nX

Return()

