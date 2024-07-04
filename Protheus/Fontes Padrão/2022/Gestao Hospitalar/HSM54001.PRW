#include "protheus.ch"
#include "topconn.ch"
#include "HSM54001.ch"

Static __aPosHor := {}
Static __aAgdTrf := {}
Static __nPosIns := 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSM24ETR  บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava Status "Em Atendimento" dos Itens do Plano de        บฑฑ
ฑฑบ          ณ tratamento.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSM24PTCLI()

// Grava Status (4-Em atendimento) dos itens do plano de tratamento (GTJ)
If Type("oGDPR") # "U" .AND. Type("nPRNumOrc") # "U" .AND. nPRNumOrc > 0// Caso nใo seja altera็ใo do atendimento
	//(#ALTERADO PONTO DE ENTRADA#) U_HSGStaGtj("4",,, oGDPR:aCols, nPRNumOrc, nPRIteOrc, oGDMM:aCols, nMMNumOrc, nMMIteOrc)
	HSGStaGtj("4",,, oGDPR:aCols, nPRNumOrc, nPRIteOrc, oGDMM:aCols, nMMNumOrc, nMMIteOrc)
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSM54Grv    บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava Dados no Agendamento.						          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSM54Grv(nOpcao,nGO4_CODPRO,nGO4_NUMORC,nGO4_ITEORC,nGebItem,nGebQtdMat,nGebNumOrc,NGEBITEORC,oGetGEB)//Leandro
Local nOpc       := nOpcao
Local nTDispMar  := Len(__aPosHor)
Local nDispDes   := 0
Local nPNaoGrv   := IIf(nOpc == 2 .And. Len(__aPosHor) > 0, __aPosHor[1], aScan(aOBJETOS[2][2]:aCols, {| aVet | aVet[nCodAge] == M->GM8_CODAGE}))
Local cGm8AgdPrc := aOBJETOS[1][2]:aCols[IIf(nTDispMar > 0, __aPosHor[1], nLastHour)][nCodAge]
Local cGaiSolici := HSA54Sol() // Inclui Solicita็ใo de Materiais

DbSelectArea("GM8")
RecLock("GM8", .F.)
GM8->GM8_SOLMAT := cGaiSolici
MsUnLock()

HSGStaGtj(iIf(nOpc == 3, "0", "3"), M->GM8_NUMORC, M->GM8_ITEORC, oGo4:aCols, nGo4_NumOrc, nGo4_IteOrc, oGetGeb:aCols, nGebNumOrc, nGebIteOrc)

DbSelectArea("GM8")

For nDispDes := 1 To nTDispMar
	If nPNaoGrv <> __aPosHor[nDispDes]
		nLastHour := __aPosHor[nDispDes]

		If     nOpc == 3 // 3-Cancelar
			M->GM8_CODAGE := aOBJETOS[1][2]:aCols[nLastHour][nCodAge]

		ElseIf nOpc == 4 // 4-Trasnferir
			M->GM8_CODAGE := IIf( LEN(__aAgdTrf) >= nDispDes, __aAgdTrf[nDispDes], __aAgdTrf[LEN(__aAgdTrf)])

		EndIf


		HSPM54Grv(nOpc)


		If nOpc == 2 .OR. nOpc == 4

			DbSelectArea("GM8")
			RecLock("GM8", .F.)
			GM8->GM8_AGDPRC := cGm8AgdPrc
			GM8->GM8_SOLMAT := cGaiSolici
			MsUnLock()
		EndIf
	EndIf
Next

__aPosHor := {}
__aAgdTrf := {}
__nPosIns := 0

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSM54Brw  บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega dados para Montagem do Browse.			          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSM54Brw(nOPcao, nFold, aCamp, aTaman, lRegAtu)
Local vRetBrw    := Nil
Local nPosIns    := IIf(nOpcao == 1, Len(aCamp) + 1, __nPosIns)
Local nMinVago   := 0

// 1-Montagem da TCBrowse Ocupacao e 1-Agenda -- Faz a Inclusใo da coluna Min. Vagos na array de ocupa็ใo
If     nOpcao == 1 .And. nFold == 1
	__nPosIns := nPosIns

	aSize(aCamp, nPosIns)
	aSize(aTaman, nPosIns)

	aCamp[nPosIns] := STR0001 //"Min.Vagos"
	aTaman[nPosIns] := 30

	vRetBrw := {aClone(aCamp), aClone(aTaman)}

	// 2-Filtro Sql dos registros da disponibilidade
ElseIf nOpcao == 2

	vRetBrw := 	"GM8.GM8_FILIAL = '" + cFilAtu       + "' AND " + ;
				"GM8.GM8_FILAGE = '" + cFilAgeAtu    + "' AND " + ;
				"GM8.GM8_CODCRM = '" + cCrmAtu       + "' AND " + ;
				"GM8.GM8_DATAGE = '" + cDatAgeAtu    + "' AND " + ;
				"GM8.GM8_AGDPRC = '" + M->GM8_AGDPRC + "' AND " + ;
				"GM8.GM8_STATUS IN ('" + cStatAtu      + "','8') " //Inclusao dos horarios transferidos na disponibilidade ( GM8_STATUS == '8')

	// 3-Na atualiza็ใo do array aAgenda e 1-Agenda -- Informa a quantidade de minutos vagos no array aAgenda
ElseIf nOpcao == 3 .And. nFold == 1
	aSize(aCamp, nPosIns)

	If GM6->GM6_CODDIS <> (cAliasGm8)->GM8_CODDIS
		HS_SeekRet("GM6", "'" + (cAliasGm8)->GM8_CODDIS + "'", 1, .F.)
	EndIf

	nMinVago := aCamp[3] * HS_Hor2Dec(GM6->GM6_INTMAR)

	aCamp[nPosIns] := StrZero(Int(nMinVago), 2) + ":" + StrZero((nMinVago - Int(nMinVago)) * 60, 2)

	// Somente nas op็๕es 3-Cancelar e 4-Trasnferir
	If aTaman == 3
		aAdd(__aPosHor, nLastHour)
	EndIf

	vRetBrw := aClone(aCamp)

	// 3-Na montagem do bLine do TCBrowse Ocupa็ใo
ElseIf nOpcao == 4
	If Len(aCamp) < nPosIns .And. nFold == 1 //1-Agenda
		aSize(aCamp, nPosIns)

		aCamp[nPosIns] := " "
	EndIf

	vRetBrw := aClone(aCamp)

	// Na montagem dos itens a serem transferidos
ElseIf nOpcao == 5
	vRetBrw := {}

	GM8->(DbSetOrder(12))
	GM8->(DBSeek(xFilial("GM8") + nFold))
	While GM8->(!Eof()) .And. GM8->GM8_FILIAL == xFilial("GM8") .And. GM8->GM8_AGDPRC == nFold

		aAdd(vRetBrw, {GM8->GM8_FILAGE, GM8->GM8_DATAGE, GM8->GM8_HORAGE, GM8->GM8_REGGER, GM8->GM8_NOMPAC, ;
		GM8->GM8_CODPLA, HS_IniPadr("GCM", 02, GM8->GM8_CODPLA, "GCM_DESPLA",, .F.), ;
		GM8->GM8_CODPRO, HS_IniPadr("GA7", 01, GM8->GM8_CODPRO, "GA7_DESC"  ,, .F.), ;
		GM8->GM8_CODCRM, HS_IniPadr("SRA", 11, GM8->GM8_CODCRM, "RA_NOME"   ,, .F.), ;
		GM8->GM8_MATRIC, GM8->GM8_CODSAL})

		aAdd(__aAgdTrf, GM8->GM8_CODAGE)

		GM8->(DbSkip())

	End
	// Posiciona no registro principal da multi-horarios
	GM8->(DbSetOrder(1))
	GM8->(DBSeek(xFilial("GM8") + nFold))

EndIf

Return(vRetBrw)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSM54Vld  บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida dados do Agendamento.						          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSM54Vld(OGETGEB)
Local lRet      := .T.
Local nTDispMar := 0
Local nDispBlq  := 0
Local nPosHor   := aOBJETOS[1][2]:oBrowse:nAt
Local dDtPrvChd := CToD(" ")
Local nItemVld  := 0
Local cDuraca	:= ""
Local dDtVIni	:= CTOD("")
Local dDtVFim	:= CTOD("")

If GA7->GA7_CODPRO <> M->GM8_CODPRO
	HS_SeekRet("GA7", "'" + M->GM8_CODPRO + "'", 1, .F.)
EndIf

If Hs_ExisDic({{"C","GM8_NUMORC"}},.F.)
	DbSelectArea("GT9")
	DbSetOrder(1)
	If DbSeek(xFilial("GT9") + M->GM8_NUMORC)
		dDtVIni := GT9->GT9_VIGINI
		dDtVFim := GT9->GT9_VIGFIN
	EndIf
EndIf
cDuraca	:= Iif(Empty(StrTran(M->GM8_DURACA, ":", "")), GA7->GA7_TEMPRO,M->GM8_DURACA)

If     !(lRet := FSVldPrevChd(oGetGEB:aCols, @dDtPrvChd))
	If !Empty(dDtPrvChd)
		HS_MsgInf(STR0002 + " " + AllTrim(M->GM8_CODPRO) + " " + STR0003 + " [" + DToC(dDtPrvChd) + "] " + STR0004 + ".", STR0005, STR0006)//"O procedimento " ### "possui materias com previsใo de chegada" ### "superior a data do agendamento" ### "Agendamento nใo permitido"  ### "Previsใo de Chegada"

	Else
		cMsgPrvChd := STR0002 + " " + AllTrim(M->GM8_CODPRO) + " " + STR0007 + ":" + Chr(13) + Chr(10)//"O procedimento " ### "possui materiais sem previsใo de chegada" ###

		For nItemVld := 1 To Len(oGetGEB:aCols)
			cMsgPrvChd += oGetGeb:aCols[nItemVld][nGebCodMat] + "-" + oGetGeb:aCols[nItemVld][nGebDescMa] + Chr(13) + Chr(10)
		Next

		cMsgPrvChd += STR0008 + " (GBI)" //"Favor ajustar o cadastro (GBI)"

		HS_MsgInf(cMsgPrvChd, STR0009, STR0006) // "Cadastro de Materiais" ### "Previsใo de Chegada"

	EndIf

ElseIf !EMpty(dDtVIni) .AND. !EMpty(dDtVFim) .AND. (aOBJETOS[nFldAtu,2]:aCols[nPosHor,nAgenda] < dDtVIni .OR. aOBJETOS[nFldAtu,2]:aCols[nPosHor,nAgenda] > dDtVFim)
	lRet := .F.
	HS_MsgInf(STR0010, STR0011, STR0012)	//"A Data do Agendamento esta fora da vigencia do tratamento!" ### "Atencao" ### "Marca o Horario na Agenda"
ElseIf !Empty(StrTran(cDuraca, ":", "")) .And. nFldAtu == 1
	lRet := (FSVldDurPrc(.T., nPosHor) .And. ;
	FSVldDisp(.T., @nTDispMar, nPosHor, cDuraca, IIf(Empty(StrTran(GA7->GA7_DURMIN, ":", "")), GM6->GM6_INTMAR, GA7->GA7_DURMIN), GM6->GM6_INTMAR))

	If lRet
		For nDispBlq := 1 To nTDispMar
			nPosHor++
			If !(lRet := FS_LByName("M29GM8"+aOBJETOS[nFldAtu,2]:aCols[nPosHor,nCodAge]))
				HS_MsgInf(STR0013, STR0011, STR0012)//"O horแrio selecionado estแ em uso por outro usuแrio", "Atencao", "Marca o Horario na Agenda"
				Exit
			EndIf
		Next
	EndIf

ElseIf !Empty(StrTran(cDuraca, ":", "")) .And. nFldAtu == 2
	if msgYesNo(STR0014 + " (" + cDuraca + ") " + STR0015 + "." + CHR(13) + chr(10) + ;
		STR0016 ,STR0017) //"Procedimento com dura็ใo" ### "incompatํvel com a disponibilidade" ### "Deseja agendar mesmo assim ?" ### "Confirmar encaixe"
		lRet := .T.
	else
		lRet := .F.
	endif

EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSM54DES  บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega dados do Agendamento.					          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSM54DES( aObjetos, nLastHour, nStatus, nLastFld, nLastDay)

Local nTDispMar := Len(__aPosHor)
Local nDispDes := 0

For nDispDes := 1 To nTDispMar
	nLastHour := __aPosHor[nDispDes]

	If aAgenda[nLastFld][2][nLastDay][nLastHour][nStatus] == "BR_LARANJA" //Status de Agendamento Marcado e Nao-Confirmado
		aAgenda[nLastFld,2,nLastDay,nLastHour,nStatus] := "BR_CINZA"
		aAgenda[nLastFld,2,nLastDay,nLastHour,nRegGer] := CriaVar("GM8_REGGER",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nMatric] := CriaVar("GM8_MATRIC",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nNomPac] := CriaVar("GM8_NOMPAC",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nCodPla] := CriaVar("GM8_CODPLA",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nDesPla] := CriaVar("GM8_DESPLA",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nSqCatP] := CriaVar("GM8_SQCATP",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nDsCatP] := CriaVar("GM8_DSCATP",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nCodPro] := CriaVar("GM8_CODPRO",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nDesPro] := CriaVar("GM8_DESPRO",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nCodSal] := CriaVar("GM8_CODSAL",.T.,,.F.)
		aAgenda[nLastFld,2,nLastDay,nLastHour,nNomSal] := CriaVar("GM8_NOMSAL",.T.,,.F.)
	EndIf

	//Verifica os dados gravados no aCols
	If (nLastFld == nFldAtu) .And. (nLastDay == aOBJETOS[nFldAtu,1]:nAt)
		If aOBJETOS[nLastFld,2]:aCols[nLastHour,nStatus] == "BR_LARANJA" //Status de Agendamento Marcado e Nao-Confirmado
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nStatus] := aAgenda[nLastFld][2][nLastDay][nLastHour][nStatus]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nRegGer] := aAgenda[nLastFld][2][nLastDay][nLastHour][nRegGer]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nMatric] := aAgenda[nLastFld][2][nLastDay][nLastHour][nMatric]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nNomPac] := aAgenda[nLastFld][2][nLastDay][nLastHour][nNomPac]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nCodPla] := aAgenda[nLastFld][2][nLastDay][nLastHour][nCodPla]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nDesPla] := aAgenda[nLastFld][2][nLastDay][nLastHour][nDesPla]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nSqCatP] := aAgenda[nLastFld][2][nLastDay][nLastHour][nSqCatP]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nDsCatP] := aAgenda[nLastFld][2][nLastDay][nLastHour][nDsCatP]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nCodPro] := aAgenda[nLastFld][2][nLastDay][nLastHour][nCodPro]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nDesPro] := aAgenda[nLastFld][2][nLastDay][nLastHour][nDesPro]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nCodSal] := aAgenda[nLastFld][2][nLastDay][nLastHour][nCodSal]
			aOBJETOS[nLastFld][2]:aCols[nLastHour][nNomSal] := aAgenda[nLastFld][2][nLastDay][nLastHour][nNomSal]
		EndIf
	EndIf

	FS_UByName("M29GM8" + aAgenda[nLastFld][2][nLastDay][nLastHour][nCodAge])
Next

__aPosHor := {}

If nTDispMar > 0
	aOBJETOS[nFldAtu,2]:oBrowse:Refresh()
EndIf
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSM54MAR บAutor  ณ Microsiga          บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca Selecao no Grid de dados do Agendamento.	          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSM54MAR(cEvento, aObjetos, nLastHour, nStatus, nLastFld, nLastDay)
Local nPosHor := aOBJETOS[nFldAtu][2]:oBrowse:nAt
Local nTDispMar := 0
Local nDispDes := 0
Local cDuraca	:= ""
Local nLinhas := aOBJETOS[nFldAtu][2]:oBrowse:nLen

__aPosHor := {}

If GA7->GA7_CODPRO <> M->GM8_CODPRO
	HS_SeekRet("GA7", "'" + M->GM8_CODPRO + "'", 1, .F.)
EndIf

cDuraca	:= Iif(Empty(StrTran(M->GM8_DURACA, ":", "")), GA7->GA7_TEMPRO,M->GM8_DURACA)

nTDispMar := IIf(Empty(StrTran(cDuraca, ":", "")) .Or. nFldAtu == 2, 0, (HS_Hor2Dec(cDuraca) / HS_Hor2Dec(GM6->GM6_INTMAR))-1)

If nTDispMar > 0
	aAdd(__aPosHor, nPosHor)
EndIf

For nDispDes := 1 To nTDispMar
	nPosHor++

	If (nPosHor <= nLinhas) .And. aOBJETOS[nFldAtu][2]:aCols[nPosHor][nStatus] $ "BR_CINZA/BR_BRANCO"
		aAdd(__aPosHor, nPosHor)

		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nStatus] := "BR_LARANJA"  //Status de Agendamento Marcado e Nao-Confirmado
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nRegGer] := M->GM8_REGGER //Prontuario
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nMatric] := M->GM8_MATRIC //Matricula do plano
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nNomPac] := M->GM8_NOMPAC //Nome do Paciente
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nCodPla] := M->GM8_CODPLA //Codigo do Plano
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nDesPla] := M->GM8_DESPLA //Descricao do Plano
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nSqCatP] := M->GM8_SQCATP // Sequencial da Categoria do Plano
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nDsCatP] := M->GM8_DSCATP // Descricao da Categoria do Plano
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nCodPro] := M->GM8_CODPRO //Codigo do procedimento
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nDesPro] := M->GM8_DESPRO //Descricao do Procedimento
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nCodSal] := M->GM8_CODSAL //Codigo da sala
		aOBJETOS[nFldAtu][2]:aCols[nPosHor][nNomSal] := M->GM8_NOMSAL //Descricao do sala
	EndIf
Next

If nTDispMar > 0
	aOBJETOS[nFldAtu][2]:oBrowse:Refresh()
EndIf
Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSVldDurPrc บAutorณ Microsiga          บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida dados do Agendamento.						          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSVldDurPrc(lMsgInf, nPosHor)
Local aOldArea := GetArea()
Local lRet := .T.
Local nTemProDec := 0, nIntMarDec := 0, nDurMinDec := 0
Local cDuraca := ""

If GA7->GA7_CODPRO <> M->GM8_CODPRO
	HS_SeekRet("GA7", "'" + M->GM8_CODPRO + "'", 1, .F.)
EndIf

cDuraca	:= Iif(Empty(StrTran(M->GM8_DURACA, ":", "")), GA7->GA7_TEMPRO,M->GM8_DURACA)

If !Empty(StrTran(cDuraca, ":", "")) .And. FSPosDisp(nPosHor)

	nIntMarDec := Val(Substr(GM6->GM6_INTMAR,1,2))+round(Val(Substr(GM6->GM6_INTMAR,4,2))/60,8)
	nTemProDec := Val(Substr(cDuraca,1,2))+round(Val(Substr(cDuraca,4,2))/60,8)
	NDurMinDec := Val(Substr(IIf(Empty(StrTran(GA7->GA7_DURMIN, ":", "")), GM6->GM6_INTMAR, GA7->GA7_DURMIN),1,2))+round(Val(Substr(IIf(Empty(StrTran(GA7->GA7_DURMIN, ":", "")), GM6->GM6_INTMAR, GA7->GA7_DURMIN),4,2))/60,8)

	If      !(lRet :=  Mod(nDurMinDec, nIntMarDec) >= 0 .AND. Mod(nDurMinDec, nIntMarDec) <= 0.000012 .And. lMsgInf .or. Mod(nDurMinDec, nIntMarDec) >= 0 .AND. Mod(nDurMinDec, nIntMarDec) <= 0.000012 .And. lMsgInf)
		HS_MsgInf(STR0018 + "(" + GA7->GA7_DURMIN + ") " + STR0019 + " (" + GM6->GM6_INTMAR + ").", STR0011, STR0018) //"Dura็ใo mํnima" ### "do procedimento incompatํvel com a disponibilidade" ### "Aten็ใo" ### "Dura็ใo Mํnima"

	ElseIf !(lRet := Mod(nTemProDec, nIntMarDec) >= 0 .AND. Mod(nTemProDec, nIntMarDec) <= 0.000012 .And. lMsgInf)
		HS_MsgInf(STR0020 + " (" + cDuraca + ") " + STR0019 + " (" + GM6->GM6_INTMAR + ").", STR0011, STR0021) //"Dura็ใo" ### "do procedimento incompatํvel com a disponibilidade" ### "Aten็ใo" ### "Dura็ใo do Procedimento"

	EndIf

EndIf

RestArea(aOldArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSVldDisp บAutor  ณ Microsiga          บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida dados do Agendamento.						          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function FSVldDisp(lMsgInf, nTDispMar, nPosHor, cGa7TemPro, cGa7DurMin, cGm6IntMar)
Local lRet     := .T.
Local cPHora   := ""
Local nTDMHMin := ((Val(Substr(cGa7DurMin,1,2))+round(Val(Substr(cGa7DurMin,4,2))/60,8)) / (Val(Substr(cGm6IntMar,1,2))+round(Val(Substr(cGm6IntMar,4,2))/60,8)))

nTDispMar := round(((Val(Substr(cGa7TemPro,1,2))+round(Val(Substr(cGa7TemPro,4,2))/60,8)) / (Val(Substr(cGm6IntMar,1,2))+round(Val(Substr(cGm6IntMar,4,2))/60,8))) - 1,4)

If !(lRet := ((Int(nTDispMar) == nTDispMar) .And. ;
	((nPosHor + nTDispMar) <= Len(aOBJETOS[nFldAtu][2]:aCols)) .And. ;
	(aScan(aOBJETOS[nFldAtu][2]:aCols, {| aDisps | !(aDisps[nStatus] $ "BR_CINZA/BR_LARANJA/BR_BRANCO")}, nPosHor, nTDispMar + 1) == 0)))

	//Caso nใo possua horarios disponiveis a partir do 1o. horario selecionado
	//procurar nos horarios anteriores do dia selecionado se existem vagas que
	//contemplem as parametriza็๕es do procedimento -- GA7_DURMIN e GA7_TEMPRO

	If (cPHora := FSAgdLivre(aOBJETOS[nFldAtu][2]:aCols, nTDispMar+1))[1]
		HS_MsgInf(STR0022 + " [" + cPHora[2] + "]", STR0011, STR0018) //"Nใo foram encontrados horarios suficientes para o agendamento, selecione o horario" ### "Aten็ใo" ### "Dura็ใo Mํnima"
		lRet := .F.

	ElseIf !lRet .And. ;
		(aOBJETOS[nFldAtu][2]:aCols[iIf(nPosHor == 1,2,nPosHor)-1][nStatus] <> "BR_CINZA") .And. ;
		(aScan(aOBJETOS[nFldAtu][2]:aCols, {| aDisps | !(aDisps[nStatus] $ "BR_CINZA/BR_LARANJA/BR_BRANCO")}, nPosHor, nTDMHMin) == 0)

		If (lRet := MsgYesNo(STR0023 + " [" + cGa7TemPro + "] " + STR0024, STR0011))  //"Este procedimento necessita de" ### "porem ้ possivel agendar usando a dura็ใo minima, confirma?" ###  "Aten็ใo"
			nTDispMar := aScan(aOBJETOS[nFldAtu][2]:aCols, {| aDisps | !(aDisps[nStatus] $ "BR_CINZA/BR_LARANJA/BR_BRANCO")}, nPosHor, nTDispMar + 1) - nPosHor
		EndIf

	ElseIf !lRet .And. lMsgInf
		HS_MsgInf(STR0025 + ".", STR0011, STR0018) //"Nใo foi encontrado horarios suficientes, selecione outra disponibilidade." ### "Aten็ใo" ### "Dura็ใo Mํnima"

	EndIf

EndIf
Return(lRet)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSPosDisp บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida dados do Agendamento.						          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FSPosDisp(nPosHor)
Local lRet := .T.

lRet := HS_SeekRet("GM8", "'" + aOBJETOS[nFldAtu][2]:aCols[nPosHor][nCodAge] + "'", 1, .F.) .And. ;
HS_SeekRet("GM6", "GM8->GM8_CODDIS", 1, .F.)

Return(lRet)

Static Function FS_LByName(cChave)
Local lRet := .F.

If lRet := LockByName(cChave, .T., .T., .F.)
	aAdd(aLocks, cChave)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_UByNameบAutor  ณ Microsiga          บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o item ja esta sendo editado.			          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_UByName(cChave)
Local nPos := 0

If UnLockByName(cChave, .T., .T., .F.)
	If (nPos := aScan(aLocks, {|x| x == cChave })) > 0
		aDel(aLocks, nPos)
		aSize(aLocks,Len(aLocks)-1)
	EndIf
EndIf

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSAgdLivreบAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FSAgdLivre(aDisps, nTDispMar)
Local nFor := 0, lRet := .F., nDLivre := 0, cPHora := "", nIniFor := 1

If oCalend:dDiaAtu == dDataBase
	nIniFor := aScan(aDisps, {| aHora | aHora[nHorAge] > Time()})
EndIf

For nFor := nIniFor To Len(aDisps)
	cPHora := IIf(nDLivre == 0, aDisps[nFor][nHorAge], cPHora)

	nDLivre := IIf(aDisps[nFor][nStatus] $ "BR_CINZA/BR_LARANJA/BR_BRANCO", nDLivre + 1, 0)

	If nDLivre == nTDispMar
		lRet := .T.
		Exit
	EndIf
Next
Return({lRet, cPHora})



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFSVldPrevChdบAutor  ณMicrosiga           บ Data ณ08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FSVldPrevChd(aItens, dDtPrvChd)
Local lRet      := .T.
Local nForItens := 0
Local cAliasOld := Alias(), aArea := GetArea()

// Elimina os itens sem codigo de materiais
While (nDelIte := aScan(aItens, {| aVet | Empty(aVet[nGebCodMat])})) > 0
	if len(aItens) > 1
		aDel(aItens, nDelIte)
		aSize(aItens, Len(aItens)-1)
	else
		exit
	endif
End

If Len(aItens) > 0 .and. (nDelIte := aScan(aItens, {| aVet | !Empty(aVet[nGebCodMat])})) > 0

	DbSelectArea("GBI")
	DbSetOrder(1)

	For nForItens := 1 To Len(aItens)

		If DbSeek(xFilial("GBI") + aItens[nForItens][nGebCodMat]) .And. IIf(!Empty(dDtPrvChd), dDtPrvChd > (dDataBase + GBI->GBI_PRVCHD), .T.)
			dDtPrvChd := (dDataBase + GBI->GBI_PRVCHD)
		EndIf

	Next

	lRet := IIf(Empty(dDtPrvChd), .F., oCalend:dDiaAtu > dDtPrvChd)
EndIf

RestArea(aArea)
DBSelectArea(cAliasOld)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSGStaGtj บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function HSGStaGtj(cGtjStatus, cGtjNumOrc, cGtjIteOrc, aPrcGtj, nPrcNumOrc, nPrcIteOrc, aMatGtj, nMatNumOrc, nMatIteOrc)
Local cAlias  	:= Alias()
Local nForIte 	:= 0
Local aGt9Orc 	:= {}
Local lExDtExec := Hs_ExisDic({{"C","GTJ_DTEXEC"}},.F.)

DbSelectArea("GTJ")
GTJ->( DbSetOrder(1) )

If cGtjNumOrc <> Nil .And. cGtjIteOrc <> Nil
	If DbSeek(xFilial("GTJ") + cGtjNumOrc + cGtjIteOrc)
		RecLock("GTJ", .F.)
		GTJ->GTJ_STATUS := cGtjStatus
		If lExDtExec
			GTJ->GTJ_DTEXEC := dDataBase
		EndIf
		GTJ->( MsUnLock() )
	EndIf
	aAdd(aGt9Orc, {cGtjNumOrc, cGtjIteOrc})
EndIf

For nForIte := 1 To Len(aPrcGtj)
	If DbSeek(xFilial("GTJ") + aPrcGtj[nForIte][nPrcNumOrc] + aPrcGtj[nForIte][nPrcIteOrc])
		RecLock("GTJ", .F.)
		GTJ->GTJ_STATUS := cGtjStatus
		If lExDtExec .and. cGtjStatus <> "3"
			If ValType("nPRDatDes") <> "U"
				GTJ->GTJ_DTEXEC :=	aPrcGtj[nForIte][nPRDatDes]
			Else
				GTJ->GTJ_DTEXEC := dDataBase
			EndIf
		EndIf
		GTJ->( MsUnLock() )
		aAdd(aGt9Orc, {aPrcGtj[nForIte][nPrcNumOrc], aPrcGtj[nForIte][nPrcIteOrc]})
	EndIf
Next

For nForIte := 1 To Len(aMatGtj)
	If DbSeek(xFilial("GTJ") + aMatGtj[nForIte][nMatNumOrc] + aMatGtj[nForIte][nMatIteOrc])
		RecLock("GTJ", .F.)
		GTJ->GTJ_STATUS := cGtjStatus
		If lExDtExec
			If ValType("nMMDatDes") <> "U"
				GTJ->GTJ_DTEXEC :=	aMatGtj[nForIte][nMMDatDes]
			Else
				GTJ->GTJ_DTEXEC := dDataBase
			EndIf
		EndIf
		GTJ->( MsUnLock() )
		aAdd(aGt9Orc, {aMatGtj[nForIte][nMatNumOrc], aMatGtj[nForIte][nMatIteOrc]})
	EndIf
Next

DbSelectArea("GT9")
GT9->( DbSetOrder(1) )

For nForIte := 1 To Len(aGt9Orc)
	If DbSeek(xFilial("GT9") + aGt9Orc[nForIte][1] + aGt9Orc[nForIte][2])
		RecLock("GT9", .F.)
		GT9->GT9_STATUS := IIf(FSTotAten(aGt9Orc[nForIte][1], aGt9Orc[nForIte][2]), "6", "5")

		GT9->( MsUnLock() )
	EndIf
Next

DbSelectArea(cAlias)
Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSTotAten บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function FSTotAten(cNumOrc, cIteOrc)
Local cAlias := Alias()
Local cSql   := ""

cSql := "SELECT Count(*) nQtdIte " + ;
"FROM " + RetSqlName("GTJ") + " GTJ " + ;
"WHERE GTJ.D_E_L_E_T_ <> '*' AND GTJ.GTJ_FILIAL = '" + xFilial("GTJ") + "' AND NOT GTJ.GTJ_STATUS IN ('1', '2', '4')"

cSql := ChangeQuery(cSql)

TCQuery cSql New Alias "GTJSTA"

lRet := GTJSTA->nQtdIte == 0

GTJSTA->(DBCloseArea())

DbSelectArea(cAlias)
Return(lRet)
