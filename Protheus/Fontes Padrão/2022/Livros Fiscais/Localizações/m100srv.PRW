#include "SIGAWIN.CH"
#DEFINE _NOMEIMP   01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IVAFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M100SRV	³ Autor ³ Leonardo Ruben       ³ Data ³ 08.08.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO DO IMPOSTO SOBRE SERVICOS PARA PORTO RICO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Localizacoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M100SRV(cCalculo,nItem,aInfo)

Local lRet := .T.
Local cTipo, cEstFis, cCFO, cAgeRet, cCliFor, nAcmAno, nAcmAnt, cLoja
Local cCartRel := ""
Local cSrvPor := GetMv("MV_SRVPOR")

Local cAliasRot  := Alias()
Local cOrdemRot  := IndexOrd()

Local aItemINFO
Local nBase 	 := 1
Local nX         := 0
Local xRet,lXFis

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If !lXFis
	aItemINFO:=ParamIxb[1]
	xRet   := ParamIxb[2]
Else
	xRet:=0
Endif

If cModulo$'FAT|LOJA|FRT|TMK'
	cCliFor    := SA1->A1_COD
	cLoja      := SA1->A1_LOJA
	cTipo      := SA1->A1_TIPO
	cEstFis    := SA1->A1_EST
	cAgeRet    := SA1->A1_RECISS
Else
	cCliFor    := SA2->A2_COD
	cLoja      := SA2->A2_LOJA
	cTipo      := SA2->A2_TIPO
	cEstFis    := SA2->A2_EST
	cAgeRet    := SA2->A2_RECISS
	cCartRel   := SA2->A2_CARTREL
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca o CFO do Tes Correspondente - SF4³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
cCFO := Alltrim(SF4->F4_CF)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se e agente de retencao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (cAgeRet=="S" .or. cAgeRet == "1")  // sim

If lRet
	
	If !lXFis
		
		//Verifica na SFF se existe ZonFis correspondente para:
		// * Calculo de Imposto;
		// * Obtencao de Aliquota;
		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+xRet[1])
			cColBas := AllTrim(Str(SFB->FB_COLBAS))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acumulado no ano dos servicos do cli/for ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAcmAno := 0
			dbSelectArea("SF3")
			dbSetOrder(4)  // filial+cli/for+loja+nf+serie
			dbSeek( xFilial("SF3")+cCliFor+cLoja)
			While !Eof() .and. F3_FILIAL+F3_CLIEFOR+F3_LOJA = xFilial("SF3")+cCliFor+cLoja
				If Year( F3_ENTRADA) == Year( dDataBase) .and. F3_TIPOMOV $ "C" .And. Empty(F3_DTCANC)
					nAcmAno += F3_VALCONT
				EndIf
				dbSkip()
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acumulado dos itens anteriores  (aImps)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAcmAnt := 0
			For nX := 1 to Len( aImps)
				If aScan( aImps[nX][6] , { |x| x[1] == xRet[1] } ) > 0
					nAcmAnt += aImps[nX][3]
				EndIf
			Next
			//
			If nAcmAno + nAcmAnt + aItemINFO[_VLRTOTAL]+;
				aItemINFO[_FLETE] + aItemINFO[_GASTOS] > 1000
				xRet[_ALIQUOTA]  := ObtemAliq( cSrvPor, If(cCartRel=="1","T",If(cCartRel=="2","P","N")))
				If nAcmAno+nAcmAnt < 1000
					xRet[_BASECALC]  := nAcmAno+nAcmAnt+aItemINFO[_VLRTOTAL]+;
					aItemINFO[_FLETE]+aItemINFO[_GASTOS]-1000  //Base de calculo
				Else
					xRet[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS]  // Base de Cálculo
				EndIf
				xRet[_IMPUESTO]  := Round(xRet[_BASECALC] * ( xRet[_ALIQUOTA]/100) ,2)
			Endif
		Endif
		
		dbSelectArea( cAliasRot )
		dbSetOrder( cOrdemRot )
		
	Else
		
		xRet  := 0
		Do Case
			Case  cCalculo == "B"
				dbSelectArea("SFB")
				dbSetOrder(1)
				If dbSeek(xFilial("SFB")+ aInfo[1]    )
					cColBas := AllTrim(Str(SFB->FB_COLBAS))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Acumulado no ano dos servicos do cli/for ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nAcmAno := 0
					dbSelectArea("SF3")
					dbSetOrder(4)  // filial+cli/for+loja+nf+serie
					dbSeek( xFilial("SF3")+cCliFor+cLoja)
					While !Eof() .and. F3_FILIAL+F3_CLIEFOR+F3_LOJA = xFilial("SF3")+cCliFor+cLoja
						If Year( F3_ENTRADA) == Year( dDataBase) .and. F3_TIPOMOV $ "C" .And. Empty(F3_DTCANC)
							nAcmAno += F3_VALCONT
						EndIf
						dbSkip()
					Enddo
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificar os outros itens                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nAcmAno+=MaFisRet(,"NF_VALMERC")
				nBase:=MaFisRet(nItem,"IT_VALMERC")
				If nAcmAno + nBase > 1000
					If nAcmAno > 1000
						xRet  := nBase  //Base de calculo
					Else
						xRet  := nAcmAno+nBase-1000  //Base de calculo
					Endif
				Endif
			Case cCalculo == "A"
				cTipo :=  If(cCartRel=="1","T",If(cCartRel=="2","P","N"))
				nPos :=0
				cTaxa := ""
				nPos := At( cTipo, cSrvPor)
				While nPos < len(cSrvPor)
					nPos++
					If Substr(cSrvPor,nPos,1) $ "0123456789.,"
						cTaxa += Substr(cSrvPor,nPos,1)
					Else
						Exit
					EndIf
				Enddo
				xRet  := ( Val(cTaxa) )
			Case cCalculo == "V"
				xRet  := MaFisRet(nItem,"IT_BASEIV"+aInfo[2])*MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])/100
		EndCase
		
	EndIf
	
EndIf

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return xRet


Static Function ObtemAliq( cSrvPor, cTipo)
Local nPos :=0, cTaxa := ""
nPos := At( cTipo, cSrvPor)
While nPos < len(cSrvPor)
	nPos++
	If Substr(cSrvPor,nPos,1) $ "0123456789.,"
		cTaxa += Substr(cSrvPor,nPos,1)
	Else
		Exit
	EndIf
Enddo
Return( Val(cTaxa) )