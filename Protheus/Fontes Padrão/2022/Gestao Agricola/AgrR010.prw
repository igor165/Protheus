#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRR010  º Autor ³ Ricardo Tomasi     º Data ³  19/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para impressão de previsão de produção.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cliente Microsiga                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function AGRR010()

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Previsão de Produção."
Local titulo         := "Previsão de Produção"
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local aOrd           := {'Talhão'}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "AGRR010" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private cPerg        := "AGR010"
Private wnrel        := "AGRR010" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString      := "NN3"

dbSelectArea("NN3")
dbSetOrder(1)


Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  24/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local cUM     := ''
Local cUMOri  := ''
Local nMedPro := 0
Local nTotFHa := 0
Local nTotFaz := 0
Local nTotGHa := 0
Local nTotGer := 0
Local nCont   := 0

dbSelectArea('NN1')
dbSetOrder(1)
If Empty(AllTrim(MV_PAR01))
	dbGotop()
Else
	dbSeek(xFilial('NN1')+MV_PAR01)
EndIf

dbSelectArea('SB1')
dbSetOrder(1)
dbSeek(xFilial('SB1')+NN1->NN1_CODPRO)
If B1_UM == MV_PAR06
	cUMOri  := B1_UM
	cUM     := B1_UM
Else
	cUMOri  := B1_UM
	cUM     := MV_PAR06
EndIf

dbSelectArea('NN2')
dbSetOrder(2)
If Empty(AllTrim(MV_PAR02))
	dbGoTop()
Else
	dbSeek(xFilial('NN2')+MV_PAR02)
EndIf

While .Not. Eof() .And. NN2_CODIGO >= MV_PAR02 .And. NN2_CODIGO <= MV_PAR03

	Cabec1 := PadR('Safra: '+NN1->NN1_ANO+'-'+NN1->NN1_SEQ,15)+PadR('Produto: '+NN1->NN1_DESPRO,50)+PadR('Unid. Med.: '+cUM,15)
	Cabec2 := 'Talhão Variedade        Qt.Ha.  Med/Ha.  Produção Total  Dt.Plan.  Dt.Colh.  Cl.'

//          1         2         3         4         5         6         7
//01234567890123456789012345678901234567890123456789012345678901234567890123456789
//Talhão Variedade        Qt.Ha.  Med/Ha.  Produção Total  Dt.Plan.  Dt.Colh.  Cl.
//  XX---XXXXXXXXXXXXXXX--XXX.XX--XXX,XXX--XXX,XXX,XXX.XX--XX/XX/XX--XX/XX/XX--XXX
//                    XXX,XXX.XX           XXX,XXX,XXX.XX

	If lAbortPrint
		@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > 55
		If nLin > 55 .And. nLin < 80
			Roda()
		EndIf
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif

	dbSelectArea('NN3')
	dbSetOrder(1)
	dbSeek(NN2->NN2_CODFIL+MV_PAR01+NN2->NN2_CODIGO+IIf(Empty(AllTrim(MV_PAR04)),'',MV_PAR04))

	While .Not. Eof() .And. NN3_SAFRA==MV_PAR01 .And. NN3_FAZ>=NN2->NN2_CODIGO .And.;
	NN3_FAZ<=NN2->NN2_CODIGO .And. NN3_TALHAO>=MV_PAR04 .And. NN3_TALHAO<=MV_PAR05
	
		dbSelectArea('NN4')
		dbSetOrder(1)
		dbSeek(NN2->NN2_CODFIL+NN3->NN3_SAFRA+NN3->NN3_FAZ+NN3->NN3_TALHAO)
		While .Not. Eof() .And. NN4_SAFRA+NN4_FAZ+NN4_TALHAO==NN3->NN3_SAFRA+NN3->NN3_FAZ+NN3->NN3_TALHAO

			If MV_PAR07 = 1
				nLin  += 1
				nCont += 1
				If nCont == 1
					@ nLin, 02 PSay NN4_TALHAO
				EndIf
				@ nLin, 07 PSay Left(NN4_DESVAR,15)
				@ nLin, 24 PSay Transform(NN4_HECTAR,'@E 999.99')
			EndIf
			If cUMOri == MV_PAR06
				nMedPro := NN4_MEDPRO
				cUM     := cUMOri
			Else
				nMedPro := AgrX001(cUMOri,MV_PAR06,NN4_MEDPRO)
				cUM     := MV_PAR06
			EndIf
			If MV_PAR07 = 1
				@ nLin, 32 PSay Transform(nMedPro,'@E 999,999')
				@ nLin, 41 PSay Transform(NN4_HECTAR*nMedPro,'@E 999,999,999.99')
				@ nLin, 57 PSay DToC(NN4_DTPLAN)
				@ nLin, 67 PSay DToC(NN4_DTPLAN+NN4_CICLO1)
				@ nLin, 77 PSay Transform(NN4_CICLO1,'@E 999')
			EndIf
			nTotFHa += NN4_HECTAR
			nTotFaz += (NN4_HECTAR*nMedPro)

			If nLin > 55
				If nLin > 55 .And. nLin < 80
					Roda()
				EndIf
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif

			dbSelectArea('NN4')
			dbSkip()
		EndDo

		nCont := 0
		dbSelectArea('NN3')
		dbSkip()
	EndDo
	
	nLin += 1
	@ nLin, 00 PSay Left(NN2->NN2_NOME,20)
	@ nLin, 20 PSay Transform(nTotFHa,'@E 999,999.99')
	@ nLin, 41 PSay Transform(nTotFaz,'@E 999,999,999.99')
	nTotGHa += nTotFHa
	nTotGer += nTotFaz
	nTotFHa := 0
	nTotFaz := 0
	nLin += 1

	dbSelectArea('NN2')
	dbSkip()
EndDo

nLin += 2
@ nLin, 00 PSay Left('*** Total Geral --> ',25)
@ nLin, 20 PSay Transform(nTotGHa,'@E 999,999.99')
@ nLin, 41 PSay Transform(nTotGer,'@E 999,999,999.99')

Roda()

Set Device To Screen

If aReturn[5]==1
	dbCommitAll()
	Set Printer To
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

