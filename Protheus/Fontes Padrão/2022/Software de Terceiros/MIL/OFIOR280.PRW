#INCLUDE 'OFIOR280.CH'
#Include 'protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR280 ³ Autor ³ Wagner Xavier         ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Listagem do pre'-inventario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fernando J. ³23/09/98³06744A³Incluir informa‡”oes de LOTE, SUB-LOTE e  ³±±
±±³            ³        ³      ³NUMERO DE SERIE.                          ³±±
±±³Rodrigo Sart³14/10/98³06744A³Correcao alteracao anterior               ³±±
±±³Fernando J. ³07/12/98³18726 ³Incluir Perguta Impr.Lote/S.Lote e N.Serie³±±
±±³Cesar       ³30/03/99³XXXXXX³Manutencao na SetPrint()                  ³±±
±±³Fernando J. ³28/05/99³XXXXXX³Correcao no Salto de Linha quando Imp.Lote³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR280
//Local oReport
Local aArea := GetArea()
Private cImp := ""
//If FindFunction("TRepInUse") .and. TRepInUse()
//	oReport := ReportDef()
//	oReport:PrintDialog()
//Else
	FS_OFR280R3()
//EndIf
RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ Andre Luis Almeida    ³ Data ³ 17/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oCell
oReport := TReport():New("OFIOR280",STR0001,"OFR280",{|oReport| OFR280IMP(oReport)})

oSection1 := TRSection():New(oReport,OemToAnsi("Secao 1"),{"SB1","SB2"})
TRCell():New(oSection1,"B1_GRUPO"  ,"SB1")
TRCell():New(oSection1,"B1_CODITE" ,"SB1",,,20)
TRCell():New(oSection1,"B1_DESC"   ,"SB1",,,20)
TRCell():New(oSection1,"B1_UM"     ,"SB1",,,2)
TRCell():New(oSection1,"B2_LOCAL"  ,"SB2",,,2)

oSection2 := TRSection():New(oReport,OemToAnsi("Secao 2"),{"SB5","SB1"})
TRCell():New(oSection2,"",,"","@!",47,,{|| space(47) })
TRCell():New(oSection2,"B5_LOCALIZ","SB5",,,10)
TRCell():New(oSection2,"B1_COD"    ,"SB1",,,30)
TRCell():New(oSection2,"",,"","@!",148,,{|| substr(cImp,1,148) })

oSection3 := TRSection():New(oReport,OemToAnsi("Secao 3"),{"SB8"})
TRCell():New(oSection3,"B8_LOTECTL","SB8",,,10)
TRCell():New(oSection3,"",,"","@!",220,,{|| substr(cImp,1,220) })

Return oReport
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFR280IMP³ Autor ³ Andre Luis Almeida    ³ Data ³ 17/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Function OFR280IMP(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local lRastro    := .F.
Local lRastroS   := .F.
Local lCLocal    := .F.
Local lContinua  := .T.
Private lImpLote := .T.
Private lUsaLote := If(GetNewPar("MV_RASTRO","N")=="S",.T.,.F.)
PERGUNTE("OFR280",.F.)
cDet       := "[            ]  [          ]   [            ]  [          ]   [            ]  [          ]"
lImpLote   := If(MV_PAR13==1,.T.,.F.)
If !lImpLote
	cDet    := "[         ][     ] [         ][     ] [         ][     ]"
EndIf
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek( xFilial("SB1") + MV_PAR03 , .T. )
oReport:SetMeter(RecCount())
oSection1:Init()
oSection2:Init()
oSection3:Init()
Do While !Eof() .and. !oReport:Cancel() .and. lContinua .and. SB1->B1_FILIAL == xFilial("SB1") .and. SB1->B1_COD <= MV_PAR04
	oReport:IncMeter()
	If ( SB1->B1_TIPO < MV_PAR05 ) .or. ( SB1->B1_TIPO > MV_PAR06 )
		dbSelectArea("SB1")
		dbSkip()
		Loop
	EndIf
	If ( SB1->B1_GRUPO < MV_PAR07 ) .or. ( SB1->B1_GRUPO > MV_PAR08 )
		dbSelectArea("SB1")
		dbSkip()
		Loop
	EndIf
	If ( SB1->B1_DESC < MV_PAR09 ) .or. ( SB1->B1_DESC > MV_PAR10 )
		dbSelectArea("SB1")
		dbSkip()
		Loop
	EndIf
	dbSelectArea("SB2")
	dbSetOrder(1)
	If !dbSeek(xFilial("SB2")+SB1->B1_COD,.F.)
		dbSelectArea("SB1")
		dbSkip()
		Loop
	EndIf
	lRastro  := Rastro(SB1->B1_COD)
	lRastroS := Rastro(SB1->B1_COD, "S")
	lCLocal  := Localiza(SB1->B1_COD)
	Do While !Eof() .and. SB2->B2_FILIAL + SB2->B2_COD == xFilial("SB2") + SB1->B1_COD
		If ( !Empty(SB2->B2_DINVENT) .and. ( ( ( SB2->B2_DINVENT + SB1->B1_PERINV ) < MV_PAR11 ) .or. ( ( SB2->B2_DINVENT + SB1->B1_PERINV ) > MV_PAR12 ) ) )
			dbSelectArea("SB2")
			dbSkip()
			Loop
		EndIf
		If (SB2->B2_LOCAL < MV_PAR01) .or. (SB2->B2_LOCAL > MV_PAR02)
			dbSelectArea("SB2")
			dbSkip()
			Loop
		EndIf
		oSection1:PrintLine()
		cImp := cDet
		If lCLocal .and. lImpLote
			dbSelectArea("SBE")
			dbSetOrder(2)
         dbSeek(xFilial("SBE") + SB2->B2_LOCAL,.F.)
			dbSelectArea("SB5")
			dbSetOrder(1)
			dbSeek(xFilial("SB5") + SB1->B1_COD)
			dbSelectArea("SBF")
			dbSetOrder(2)
			dbSeek(xFilial("SBF") + SB1->B1_COD + SB2->B2_LOCAL,.F.)
			Do While !Eof() .and. xFilial("SBF") == SBF->BF_FILIAL .and. SB1->B1_COD + SB2->B2_LOCAL == SBF->BF_PRODUTO + SBF->BF_LOCAL
				oSection2:PrintLine()
				dbSelectArea("SBF")
           	dbSkip()
         EndDo
		ElseIf lRastro .and. lImpLote
			dbSelectArea("SB8")
			dbSetOrder(3)
			dbSeek(xFilial("SB8") + SB1->B1_COD + SB2->B2_LOCAL,.F.)
			Do While !Eof() .and. xFilial("SB8") == SB8->B8_FILIAL .and. SB8->B8_PRODUTO + SB8->B8_LOCAL == SB1->B1_COD + SB2->B2_LOCAL
				cImp := If(lRastroS,Left(SB8->B8_NUMLOTE,06),"")+" "+cDet		
				oSection3:PrintLine()
				dbSelectArea("SB8")
           	dbSkip()
			EndDo
		Else
			dbSelectArea("SBE")
			dbSetOrder(2)
         dbSeek(xFilial("SBE") + SB2->B2_LOCAL,.F.)
			dbSelectArea("SB5")
			dbSetOrder(1)
			dbSeek(xFilial("SB5") + SB1->B1_COD)
			oSection2:PrintLine()
		EndIf
		dbSelectArea("SB2")
     	dbSkip()
	EndDo
	dbSelectArea("SB1")
  	dbSkip()
EndDo
oSection1:Finish()
oSection2:Finish()
oSection3:Finish()
Return Nil
*/


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FS_OFR280R3()
Local Tamanho  
Local Titulo   := STR0001	// 'Listagem para Inventario'
Local cDesc1   := STR0002	// 'Este programa emite um relatorio que facilita a digitacao'
Local cDesc2   := STR0003	// 'das quantidades inventariadas.'
Local cDesc3   := STR0004	// "Ele e' emitido de acordo com os parametros informados."
Local cString  := 'SB1'
Local aOrd     := {OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008)}   //' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '
Local wnRel    := 'OFIOR280'
Private aReturn  := {OemToAnsi(STR0009), 1,OemToAnsi(STR0010), 2, 2, 1, '',1 }   //'Zebrado'###'Administracao'
Private nLastKey := 0
Private cPerg    := 'OFR280'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01     // Almox. de                                    ³
//³ MV_PAR02     // Almox. ate                                   ³
//³ MV_PAR03     // Produto de                                   ³
//³ MV_PAR04     // Produto ate                                  ³
//³ MV_PAR05     // tipo de                                      ³
//³ MV_PAR06     // tipo ate                                     ³
//³ MV_PAR07     // grupo de                                     ³
//³ MV_PAR08     // grupo ate                                    ³
//³ MV_PAR09     // descricao de                                 ³
//³ MV_PAR10     // descricao ate                                ³
//³ MV_PAR11     // data Selecao de                              ³
//³ MV_PAR12     // data Selecao ate                             ³
//³ MV_PAR13     // Imprime Lote/Sub-Lote e N£mero de S‚rie ?    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
Tamanho := If(MV_PAR13 == 1,'G','M')
wnRel:=SetPrint(cString,wnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)
If nLastKey == 27
	Set Filter to
	Return Nil
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter to
	Return Nil
Endif
RptStatus({|lEnd| C280Imp(aOrd,@lEnd,wnRel,cString,Titulo,Tamanho)},Titulo)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ C280IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 11.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR280			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C280Imp(aOrd,lEnd,wnRel,cString,Titulo,Tamanho)
Local cRodaTxt   := STR0011 // 'PRODUTO(S)'
Local nCntImpr   := 0
Local ntipo      := 0
Local lRastro    := .F.
Local lRastroS   := .F.
Local lCLocal    := .F.
Local cDet       := '[            ]  [          ]   [            ]  [          ]   [            ]  [          ]'
Private Li      := 80
Private m_pag   := 1
Private cCondicao  := ''
Private cCondicao1 := ''
Private lContinua  := .T.
Private lUsaLote   := If(GetMV('MV_RASTRO')=='S',.T.,.F.)
Private lImpLote   := If(MV_PAR13==1,.T.,.F.)
If !lImpLote
	cDet := '[         ][     ] [         ][     ] [         ][     ]'
EndIf
nTipo := If(aReturn[4]==1,15,18)
If Type('NewHead') # 'U'
	NewHead += ' (' + AllTrim(aOrd[aReturn[8]]) + ')'
Else
	Titulo += ' (' + AllTrim(aOrd[aReturn[8]]) + ')'
EndIf
If lImpLote
   Cabec1 := STR0012 //    "GRUP ITEM           TP DESCRICAO                 UM AMZ DESCRICAO ARMAZEM      ENDERECO        LOTE       SUB    NUMERO           ______1a. CONTAGEM______       ______2a. CONTAGEM______       ______3a. CONTAGEM______"
   Cabec2 := STR0013 //    "                                                               ALMOXARIFADO    FISICA                     LOTE   SERIE            QUANTIDADE      ETIQUETA       QUANTIDADE      ETIQUETA       QUANTIDADE      ETIQUETA" 
Else
	Cabec1 := STR0012 // 'CODIGO          TP GRUP DESCRICAO                      UM ALM LOCALIZACAO      __1a. CONTAGEM__  __2a. CONTAGEM__  __3a. CONTAGEM__ '
	Cabec2 := STR0013 // '                                                                               QUANTIDADE ETIQU. QUANTIDADE ETIQU. QUANTIDADE ETIQU.'
EndIf
dbSelectArea('SB2')
dbSetOrder(1)
dbSelectArea('SB8')
dbSetOrder(3)
dbSelectArea('SBF')
dbSetOrder(2)
dbSelectArea('SB1')
dbSetOrder(aReturn[8])
SetRegua(LastRec())
If aReturn[8] == 4
	dbSeek(cFilial + MV_PAR07, .T.)
	cCondicao := 'lContinua .and. !Eof() .and. B1_GRUPO <= MV_PAR08'
ElseIf aReturn[8] == 3
	dbSeek(cFilial + MV_PAR09, .T.)
	cCondicao := 'lContinua .and. !Eof() .and. B1_DESC <= MV_PAR10'
ElseIf aReturn[8] == 2
	dbSeek(cFilial + MV_PAR05, .T.)
	cCondicao := 'lContinua .and. !Eof() .and. B1_TIPO <= MV_PAR06'
Else
	dbSeek(cFilial + MV_PAR03, .T.)
	cCondicao := 'lContinua .and. !Eof() .and. B1_COD <= MV_PAR04'
Endif
Do While &(cCondicao) .and. B1_FILIAL == cFilial
	If lEnd
		@ pRow()+1, 001 PSAY STR0014 // 'CANCELADO PELO OPERADOR'
		Exit
	EndIf
	IncRegua()
	If !SB2->(dbSeek(xFilial('SB2') + SB1->B1_COD, .F.)) .or. ;
		(SB1->B1_COD < MV_PAR03) .or. (SB1->B1_COD > MV_PAR04) .or. ;
		(SB1->B1_TIPO < MV_PAR05) .or. (SB1->B1_TIPO > MV_PAR06) .or. ;
		(SB1->B1_DESC < MV_PAR09) .or. (SB1->B1_DESC > MV_PAR10) .or. ;
		(SB1->B1_GRUPO < MV_PAR07) .or. (SB1->B1_GRUPO > MV_PAR08)
		SB1->(dbSkip())
		Loop
	EndIf
	lRastro  := Rastro(SB1->B1_COD)
	lRastroS := Rastro(SB1->B1_COD, 'S')
	lCLocal  := Localiza(SB1->B1_COD)
	Do While !SB2->(Eof()) .and. ;
		SB2->B2_FILIAL + SB2->B2_COD == xFilial('SB2') + SB1->B1_COD
		If lEnd
			@ pRow()+1, 001 PSAY STR0014 // 'CANCELADO PELO OPERADOR'
			lContinua := .F.
			Exit
		EndIf
		If (!Empty(SB2->B2_DINVENT) .and. ;
			(((SB2->B2_DINVENT + SB1->B1_PERINV) < MV_PAR11) .or. ;
			((SB2->B2_DINVENT + SB1->B1_PERINV) > MV_PAR12)))
			SB2->(dbSkip())
			Loop
		EndIf
		If (SB2->B2_LOCAL < MV_PAR01) .or. (SB2->B2_LOCAL > MV_PAR02)
			SB2->(dbSkip())
			Loop
		EndIf
		If Li > 55
			Cabec(Titulo,Cabec1,Cabec2,wnRel,Tamanho,nTipo)
		EndIf
		nCntImpr++
		f280ImpDet()
		If lCLocal .and. lImpLote .and.;
			SBF->(dbSeek(xFilial('SBF') + SB1->B1_COD + SB2->B2_LOCAL, .F.))
         SBE->(dbSeek(xFilial('SBE') + SB2->B2_LOCAL, .F.))
         SB5->(dbSeek(xFilial('SB5') + SB1->B1_COD))
			Do While !SBF->(Eof()) .and. ;
				xFilial('SBF') + SB1->B1_COD + SB2->B2_LOCAL == SBF->BF_FILIAL + SBF->BF_PRODUTO + SBF->BF_LOCAL
				If Li > 55
					Cabec(Titulo,Cabec1,Cabec2,wnRel,Tamanho,nTipo)
					f280ImpDet()
				EndIf
            @ Li, pcol()+01 PSAY Left(FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ"), 10)
//            @ Li, pcol()+01 PSAY Left(SB1->B1_COD+space(30),30)            
            @ Li, pcol()+01 PSAY cDet
            Li++
           	SBF->(dbSkip())
         EndDo
		ElseIf lRastro .and. lImpLote .and.;
			SB8->(dbSeek(xFilial('SB8') + SB1->B1_COD + SB2->B2_LOCAL, .F.))
			cCondicao1 := 'SB8->B8_FILIAL + SB8->B8_PRODUTO + SB8->B8_LOCAL + SB8->B8_LOTECTL ' + If(lRastroS,'+ SB8->B8_NUMLOTE','')
			Do While !SB8->(Eof()) .and. ;
				xFilial('SB8') + SB1->B1_COD + SB2->B2_LOCAL + SB8->B8_LOTECTL + If(lRastroS,SB8->B8_NUMLOTE,'') == &(cCondicao1)
				If Li > 55
					Cabec(Titulo,Cabec1,Cabec2,wnRel,Tamanho,nTipo)
					f280ImpDet()
				EndIf
				@ Li, pcol()+01 PSAY Left(SB8->B8_LOTECTL,10)
				@ Li, pcol()+01 PSAY If(lRastroS,Left(SB8->B8_NUMLOTE,06),'')
				@ Li, pcol()+01 PSAY cDet
				Li++
				SB8->(dbSkip())
			EndDo
		Else
			If lImpLote
            SBE->(dbSeek(xFilial('SBE') + SB2->B2_LOCAL, .F.))
            SB5->(dbSeek(xFilial('SB5') + SB1->B1_COD))
            @ Li, pcol()+01 PSAY Left(FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ"), 10)
//            @ Li, pcol()+01 PSAY left(SB1->B1_COD+space(30),30)
				@ Li, pcol()+01 PSAY cDet
			Else
            SBE->(dbSeek(xFilial('SBE') + SB2->B2_LOCAL, .F.))
            SB5->(dbSeek(xFilial('SB5') + SB1->B1_COD))
            @ Li, pcol()+01 PSAY Left(FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ"), 10)
//            @ Li, pcol()+01 PSAY left(SB1->B1_COD+space(30),30)
				@ Li, pcol()+01 PSAY cDet
			EndIf
			Li++
		EndIf
		SB2->(dbSkip())
	EndDo
	SB1->(dbSkip())
EndDo
If Li # 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf
dbSelectArea(cString)
dbSetOrder(1)
Set Filter to
SB1->(dbSetOrder(1))
SB2->(dbSetOrder(1))
SB8->(dbSetOrder(1))
SBF->(dbSetOrder(1))
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnRel)
Endif
MS_FLUSH()
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f250ImpDet³ Autor ³ Fernando Joly Siquini ³ Data ³ 22.09.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ ImpressÆo do Detalhe com os Dados do Produto               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR280			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function f280ImpDet()
If lImpLote
    @ Li, 000       psay Left(SB1->B1_GRUPO  , 04)   
    @ li, pcol()+01 psay left(SB1->B1_CODITE , 27)   
    @ Li, pcol()+01 psay Left(SB1->B1_DESC   , 23)
    @ Li, pcol()+01 psay Left(SB1->B1_UM     , 02)
    @ Li, pcol()+01 psay Left(SB2->B2_LOCAL  , 02)
Else 
    @ Li, 000 psay Left(SB1->B1_GRUPO  , 04)   
    @ li, pcol()+01 psay left(SB1->B1_CODITE , 27)   
    @ Li, pcol()+01 psay Left(SB1->B1_DESC   , 23)
    @ Li, pcol()+01 psay Left(SB1->B1_UM     , 02)
    @ Li, pcol()+01 psay Left(SB2->B2_LOCAL  , 02)
EndIf
Return Nil
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////