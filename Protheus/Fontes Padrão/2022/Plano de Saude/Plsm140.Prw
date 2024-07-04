
#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSM140  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 02/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do resumo de opcionais por vida                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSM140()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAPLS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsM140()

Local nOpca 		:= 0
Local aSays 		:= {}, aButtons := {}
Private cCadastro 	:= "Resumo de opcionais por Vida"
Private aOpcionais 	:= {} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Mes Base Movimento                               ³
//³ mv_par02 // Ano Base Movimento                               ³
//³ mv_par03 // Codigo da Operadora                              ³
//³ mv_par04 // Seleciona opcionais                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("PLM140",.f.)

AADD(aSays,"Efetua a geracao do resumo mensal de opcionais baseado nas definicoes informadas no")
AADD(aSays,"sub-contrato, familia e usuario.")

AADD(aButtons, { 5,.T.,{|| Pergunte("PLM140",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons,, 160 )

If mv_par04 = 2
	aOpcionais := {}
Endif

IF nOpca == 1
	Processa( { || Pls140Proc()},"Gerando resumo de opcionais - Mes " + mv_par01 +;
	"/" + mv_par02,"Processando ...")
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pls140Proc³ Autor ³ Wagner Mobile Costa   ³ Data ³ 02.07.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua leitura de sub-contrato, famila e usuarios          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Pls140Proc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pls140Proc()

Local cFiltro, cChave, nMin, nMax
Local aOpcBHS := {}, aOpcBF1 := {}, aOpcBF4 := {}
Local lPrimeiro := .T.
Local aTabPad := {}, nPos, nIdade
Local dDataFim := LastDay(Ctod("01/" + mv_par01 + "/" + mv_par02))
Local nIdadeIni := 0    
LOCAL nCont

DbSelectArea("BL9")		// Tabela de Idade Padrao
DbSetOrder(1)
DbSeek(xFilial("BL9"))
While ! Eof() .And. BL9_FILIAL = xFilial("BL9")
	Aadd(aTabPad, { nIdadeIni, BL9_IDADEF })
	nIdadeIni := BL9_IDADEF + 1
	DbSkip()
EndDo

DbSelectArea("BHS")
DbSetOrder(1)

cFiltro := 	"SELECT COUNT(*) CONTADOR FROM " +;
			RetSqlName("BQC") + " WHERE BQC_FILIAL = '" + xFilial("BQC") + "' AND "+;
			"BQC_CODINT = '" + mv_par03 + "' AND D_E_L_E_T_ <> '*'"
cFiltro := ChangeQuery(cFiltro)

DbSelectArea("BQC")
DbSetOrder(1)
		
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BQCQRY", .F., .T.)
ProcRegua(BQCQRY->CONTADOR)
BQCQRY->( DbCloseArea() )

cFiltro := 	"SELECT * FROM " +;
			RetSqlName("BQC") + " WHERE BQC_FILIAL = '" + xFilial("BQC") + "' AND "+;
			"BQC_CODINT = '" + mv_par03 + "' AND D_E_L_E_T_ <> '*'"
cFiltro := ChangeQuery(cFiltro)
		
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BQCQRY", .F., .T.)

While ! Eof()
	IncProc( "Lendo Sub-Contrato: " + BQCQRY->BQC_SUBCON + "/" + BQCQRY->BQC_VERSUB)
	aOpcBHS := {}  
	DbSelectArea("BHS")		// Opcionais do Sub-Contrato
	If DbSeek(	xFilial("BHS") + BQCQRY->BQC_CODIGO + BQCQRY->BQC_NUMCON +;
				BQCQRY->BQC_VERCON + BQCQRY->BQC_SUBCON + BQCQRY->BQC_VERSUB)
		While 	! Eof() .And. BHS_FILIAL = xFilial("BHS") .And.;
				BHS_CODINT + BHS_CODIGO = BQCQRY->BQC_CODIGO .And.;
				BHS_NUMCON = BQCQRY->BQC_NUMCON .And.;
				BHS_VERCON = BQCQRY->BQC_VERCON .And.;
				BHS_SUBCON = BQCQRY->BQC_SUBCON .And.;
				BHS_VERSUB = BQCQRY->BQC_VERSUB
			If 	(mv_par04 = 1 .Or. Pl140EhOpc(BHS->BHS_CODINT + BHS->BHS_CODPLA +;
				BHS->BHS_VERPLA)) .And.;
				(Len(aOpcionais) = 0 .Or.;
				 Ascan(aOpcionais, { |x| 	x[1] .And.;
											x[2] = BHS->BHS_CODPLA .And.;
											x[4] = BHS->BHS_VERPLA }) > 0)
				Aadd(aOpcBhs, { BHS->BHS_CODPLA, BHS->BHS_VERPLA })
			Endif
			DbSkip()
		EndDo
	Endif

	cFiltro := 	"SELECT * FROM " +;
				RetSqlName("BA3") + " WHERE BA3_FILIAL = '" + xFilial("BA3") + "' AND "+;
				"BA3_CODINT = '" + mv_par03 + "' AND " +;
				"BA3_CODEMP = '" + BQCQRY->BQC_CODEMP + "' AND " +;
				"BA3_CONEMP = '" + BQCQRY->BQC_NUMCON + "' AND " +;
				"BA3_VERCON = '" + BQCQRY->BQC_VERCON + "' AND " +;
				"BA3_SUBCON = '" + BQCQRY->BQC_SUBCON + "' AND " +;
				"BA3_VERSUB = '" + BQCQRY->BQC_VERSUB + "' AND " +;
				"D_E_L_E_T_ <> '*'"
	cFiltro := ChangeQuery(cFiltro)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BA3QRY", .F., .T.)

	While ! Eof()
		aOpcBF1 := {}  
		DbSelectArea("BF1")		// Opcionais da Familia
		If DbSeek(	xFilial("BF1") + BQCQRY->BQC_CODIGO + BA3QRY->BA3_MATRIC)
			While 	! Eof() .And. BF1_FILIAL = xFilial("BF1") .And.;
					BF1_CODINT + BF1_CODEMP = BQCQRY->BQC_CODIGO .And.;
					BF1_MATRIC = BA3QRY->BA3_MATRIC
				If 	(mv_par04 = 1 .Or. Pl140EhOpc(BF1->BF1_CODINT + BF1->BF1_CODPRO +;
					BF1->BF1_VERSAO)) .And.;
					(Len(aOpcionais) = 0 .Or.;
					Ascan(aOpcionais, { |x| 	x[1] .And.;
												x[2] = BF1->BF1_CODPRO .And.;
												x[4] = BF1->BF1_VERSAO} )) > 0
					If 	(Empty(BF1->BF1_MOTBLO) .Or.;
						(! Empty(BF1->BF1_MOTBLO) .And. BF1->BF1_DATBLO > dDataFim)) .And.;
						Ascan(aOpcBHS, { |x|	x[1] = BF1->BF1_CODPRO .And.;
												x[2] = BF1->BF1_VERSAO }) = 0
						Aadd(aOpcBF1, { BF1->BF1_CODPRO, BF1->BF1_VERSAO, .T. })
					ElseIf 	(! Empty(BF1->BF1_MOTBLO) .And. BF1->BF1_DATBLO <= dDataFim)
						Aadd(aOpcBF1, { BF1->BF1_CODPRO, BF1->BF1_VERSAO, .F. })
					Endif
				Endif
				DbSkip()
			EndDo
		Endif

		cFiltro := 	"SELECT * FROM " +;
					RetSqlName("BA1") + " WHERE BA1_FILIAL = '" + xFilial("BA1") + "' AND "+;
					"BA1_CODINT = '" + mv_par03 + "' AND " +;
					"BA1_CODEMP = '" + BQCQRY->BQC_CODEMP + "' AND " +;
					"BA1_CONEMP = '" + BQCQRY->BQC_NUMCON + "' AND " +;
					"BA1_VERCON = '" + BQCQRY->BQC_VERCON + "' AND " +;
					"BA1_SUBCON = '" + BQCQRY->BQC_SUBCON + "' AND " +;
					"BA1_VERSUB = '" + BQCQRY->BQC_VERSUB + "' AND " +;
					"BA1_MATRIC = '" + BA3QRY->BA3_MATRIC + "' AND " +;
					"BA1_DATINC <= '" + Dtos(dDataFim) + "' AND " +;
					"((BA1_MOTBLO = ' ') OR (BA1_MOTBLO <> '  ' AND BA1_DATBLO >= '" + Dtos(dDataFim) +;
					"')) AND D_E_L_E_T_ <> '*'"
		cFiltro := ChangeQuery(cFiltro)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BA1QRY", .F., .T.)
		TCSETFIELD("BA1QRY","BA1_DATNAS","D",8,0)

		While ! Eof()
			aOpcBF4 := {}  
			DbSelectArea("BF4")		// Opcionais do Usuario
			If DbSeek(	xFilial("BF4") + BQCQRY->BQC_CODIGO + BA1QRY->BA1_MATRIC +;
						BA1QRY->BA1_TIPREG)
				While 	! Eof() .And. BF4_FILIAL = xFilial("BF4") .And.;
						BF4_CODINT + BF4_CODEMP = BQCQRY->BQC_CODIGO .And.;
						BF4_MATRIC = BA1QRY->BA1_MATRIC .And.;
						BF4_TIPREG = BA1QRY->BA1_TIPREG
					If 	(mv_par04 = 1 .Or. Pl140EhOpc(BF4->BF4_CODINT + BF4->BF4_CODPRO +;
						BF4->BF4_VERSAO)) .And.;
						(Len(aOpcionais) = 0 .Or.;
						Ascan(aOpcionais, { |x| 	x[1] .And.;
													x[2] = BF4->BF4_CODPRO .And.;
													x[4] = BF4->BF4_VERSAO} )) > 0
						If 	(Empty(BF4->BF4_MOTBLO) .Or.;
							(! Empty(BF4->BF4_MOTBLO) .And. BF4->BF4_DATBLO > dDataFim)) .And.;
							Ascan(aOpcBHS, { |x| 	x[1] = BF4->BF4_CODPRO .And.;
													x[2] = BF4->BF4_VERSAO }) = 0 .And.;
							Ascan(aOpcBF1, { |x| 	x[1] = BF4->BF4_CODPRO .And.;
													x[2] = BF4->BF4_VERSAO }) = 0
							Aadd(aOpcBF4, { BF4->BF4_CODPRO, BF4->BF4_VERSAO, .T. })
						ElseIf 	(! Empty(BF4->BF4_MOTBLO) .And. BF4->BF4_DATBLO <= dDataFim)
							Aadd(aOpcBF4, { BF4->BF4_CODPRO, BF4->BF4_VERSAO, .F. })
						Endif
					Endif
					DbSkip()
				EndDo
			Endif
			
			If Len(aOpcBhs) = 0 .And. Len(aOpcBF1) = 0 .And. Len(aOpcBF4) = 0
				DbSelectArea("BA1QRY")
				DbSkip()
				Loop
			Endif
			
            nIdade := Calc_Idade(dDataFim, BA1QRY->BA1_DATNAS)
			nPos := Ascan(aTabPad, { |x| nIdade >= x[1] .And. nIdade <= x[2] })

            If nPos = 0
				DbSelectArea("BA1QRY")
				DbSkip()
				Loop
			Endif
			
			DbSelectArea("BPZ")
			
		    If lPrimeiro
				cFiltro := 	"SELECT MIN(R_E_C_N_O_) MINRECNO, " +;
							"MAX(R_E_C_N_O_) MAXRECNO FROM " + RetSqlName("BPZ") + " "+;
							"WHERE BPZ_FILIAL = '" + xFilial("BPZ") + "' AND "+;
							"BPZ_ANOMES = '" + mv_par02 + mv_par01 + "' AND BPZ_CODOPE = '" +;
							mv_par03 + "' AND D_E_L_E_T_ <> '*'"
				cFiltro := ChangeQuery(cFiltro)
		
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BPZQRY", .F., .T.)
				nMin := BPZQRY->MINRECNO
				nMax := BPZQRY->MAXRECNO
				BPZQRY->( DbCloseArea() )

  				cFiltro := "DELETE FROM " +	RetSqlName("BPZ") + " "
				cFiltro += "WHERE BPZ_FILIAL = '" + xFilial("BPZ") + "' AND "+;
				"BPZ_ANOMES = '" + mv_par02 + mv_par01 + "' AND BPZ_CODOPE = '" +;
				mv_par03 + "' AND D_E_L_E_T_ <> '*'"
		
				For nCont := nMin To nMax STEP 1024
					cChave := "AND R_E_C_N_O_>="+Str(nCont,10,0)+" AND R_E_C_N_O_<="+Str(nCont+1023,10,0)+""
					TcSqlExec(cFiltro+cChave)
				Next nCont
				lPrimeiro := .F.
		    Endif
				
			Grv140Bpz(aOpcBhs, aTabPad[nPos], aOpcBF1, aOpcBF4)
			Grv140Bpz(aOpcBF1, aTabPad[nPos])
			Grv140Bpz(aOpcBF4, aTabPad[nPos])

			DbSelectArea("BA1QRY")
			DbSkip()
		EndDo
		BA1QRY->( DbCloseArea() )
		
		DbSelectArea("BA3QRY")
		DbSkip()
	EndDo
	BA3QRY->( DbCloseArea() )
	
	DbSelectArea("BQCQRY")
	DbSkip()	
EndDo

BQCQRY->( DbCloseArea() )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Grv140Bpz  ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 03.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a tabela BPZ de acordo com os opcionais utilizados      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Grv140Bpz(aOpcionais, aTabPad, aOpcBF1, aOpcBF4)

Local nOpc, nPos, cTpMnt := ""

If BA1QRY->BA1_MOTBLO <> ' ' .And. Left(BA1QRY->BA1_DATBLO, 6) = mv_par02 + mv_par01
	cTpMnt := "3"		// Excluido
ElseIf Left(BA1QRY->BA1_DATTRA, 6) = mv_par02 + mv_par01
	cTpMnt := "2"		// Alterado
ElseIf Left(BA1QRY->BA1_DATINC, 6) = mv_par02 + mv_par01
	cTpMnt := "1"		// Incluido
Endif

DbSelectArea("BPZ")
For nOpc := 1 To Len(aOpcionais)
	If Len(aOpcionais[nOpc]) > 2 .And. ! aOpcionais[nOpc][3]
		Loop
	Endif
	
	If aOpcBF1 # Nil
		If (nPos := Ascan(aOpcBF1, {|x| 	x[1] = aOpcionais[nOpc][1] .And.;
											x[2] = aOpcionais[nOpc][2]} )) > 0 .And.;
			! aOpcBF1[nPos][3]
			Loop			
		Endif
	Endif

	If aOpcBF4 # Nil
		If (nPos := Ascan(aOpcBF4, {|x| 	x[1] = aOpcionais[nOpc][1] .And.;
											x[2] = aOpcionais[nOpc][2]} )) > 0 .And.;
			! aOpcBF4[nPos][3]
			Loop			
		Endif
	Endif

	If ! DbSeek(	xFilial("BPZ") + mv_par03 + BA1QRY->BA1_CODEMP +;
					BA1QRY->BA1_MATRIC + BA1QRY->BA1_TIPUSU + BA1QRY->BA1_TIPREG +;
					BA1QRY->BA1_DIGITO + mv_par02 + mv_par01 +;
	 				aOpcionais[nOpc][1] + aOpcionais[nOpc][2])
		RecLock("BPZ", .T.)
  		Replace BPZ_FILIAL With xFilial("BPZ"), BPZ_ANOMES With mv_par02 + mv_par01,;
  				BPZ_CODOPE With mv_par03,;
		  		BPZ_CODPLA With aOpcionais[nOpc][1],;
		  		BPZ_VERPLA With aOpcionais[nOpc][2],;
		  		BPZ_IDADEI With aTabPad[1],;
		  		BPZ_IDADEF With aTabPad[2],;
		  		BPZ_CODEMP With BA1QRY->BA1_CODEMP,;
				BPZ_MATRIC With BA1QRY->BA1_MATRIC,;
				BPZ_TIPUSU With BA1QRY->BA1_TIPUSU,;
				BPZ_TIPREG With BA1QRY->BA1_TIPREG,;
				BPZ_DIGITO With BA1QRY->BA1_DIGITO
    Else
		RecLock("BPZ", .F.)
	Endif
	
	Replace BPZ_TPMNT With cTpMnt
	MsUnLock()
Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlsC140Opc ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 03.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre caixa para selecao dos opcionais a serem gerados         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsC140Opc

Local oDlg, cFiltro
Local hOK  	:= LoadBitmap( GetResources(), "LBTIK" )
Local hNo	:= LoadBitmap( GetResources(), "LBNO" )
Local aOpc	:= AClone(aOpcionais)

If mv_par04 = 2
	Return
Endif

If Len(aOpcionais) = 0
	PlsL140Opc()
Endif	

If Len(aOpcionais) = 0
	Return
Endif

DEFINE MSDIALOG oDlg TITLE "Produtos Opcionais" FROM 000,000 TO 194,338 OF oMainWnd PIXEL

@ 005,006 	LISTBOX oOpcionais VAR cOpcionais ;
			FIELDS ;
			HEADER " ", "Grupo", "Descricao";
			SIZE 129,90 OF oDlg PIXEL ;
			ON DBLCLICK (aOpcionais[oOpcionais:nAt,1] := !(aOpcionais[oOpcionais:nAt,1]),;
						oOpcionais:Refresh())
			  
oOpcionais:SetArray(aOpcionais)
oOpcionais:bLine:= { || { If( aOpcionais[oOpcionais:nAt, 1], hOk, hNo ),;
						aOpcionais[oOpcionais:nAt, 2], aOpcionais[oOpcionais:nAt, 3] } }

oSBtn2 := SBUTTON():Create(oDlg)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "oSBtn2"
oSBtn2:nLeft := 278
oSBtn2:nTop := 12
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:bAction := { || oDlg:End() }
oSBtn2:nType := 1		// Ok

oSBtn3 := SBUTTON():Create(oDlg)
oSBtn3:cName := "oSBtn3"
oSBtn3:cCaption := "oSBtn3"
oSBtn3:nLeft := 280
oSBtn3:nTop := 59
oSBtn3:nWidth := 52
oSBtn3:nHeight := 22
oSBtn3:lShowHint := .F.
oSBtn3:lReadOnly := .F.
oSBtn3:Align := 0
oSBtn3:lVisibleControl := .T.
oSBtn3:bAction := { || oDlg:End(), aOpcionais := AClone(aOpc) }
oSBtn3:nType := 2

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlsL140Opc ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 04.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona opcionais a serem utilizados na selecao             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PlsL140Opc

cFiltro := 	"SELECT * FROM " +;
			RetSqlName("BI3") + " BI3, " + RetSqlName("BE5") + " BE5 " +;
			"WHERE BI3_FILIAL = '" + xFilial("BI3") + "' AND "+;
			"BI3_CODINT = '" + mv_par03 + "' AND BE5_FILIAL = '" +;
			xFilial("BE5") + "' AND BI3_GRUPO = BE5_CODGRU AND " +;
			"BE5_TIPO = '2' AND BI3.D_E_L_E_T_ <> '*' AND BE5.D_E_L_E_T_ <> '*'"
cFiltro := ChangeQuery(cFiltro)
		
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BI3QRY", .F., .T.)
While ! Eof()
	Aadd(aOpcionais, { .T., BI3_CODIGO, BI3_DESCRI, BI3_VERSAO })
	DbSkip()
EndDo
BI3QRY->( DbCloseArea() )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Pl140EhOpc ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 14.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna se um produto e um opcional                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Pl140EhOpc(cChave)

BI3->(DbSeek(xFilial("BI3") + cChave))
BE5->(DbSeek(xFilial("BE5") + BI3->BI3_GRUPO))


Return BE5->BE5_TIPO = '2'
