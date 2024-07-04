#INCLUDE "PROTHEUS.CH"
#INCLUDE "CSAM020.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CSAM020  ³ Autor ³ Cristina Ogura        ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza as referencias das graduacoes dos funcionarios    ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³18/07/14³TPZVUR³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAM020()
Local nOpca 	:= 0
Local oDlg
Local aRegs		:= {}
Local aSays		:= {}
Local aButtons	:= {} //<== arrays locais de preferencia

Private cCadastro	:= OemtoAnsi(STR0001)//"Atualizacao das referencias dos funcionarios"
Private cFilDe		:= ""
Private cFilAte		:= ""
Private cGrupoDe	:= ""
Private cGrupoAte	:= ""
Private cCargoDe	:= ""
Private cCargoAte 	:= ""
Private cFuncaoDe 	:= ""
Private cFuncaoAte 	:= ""
Private cCCDe		:= ""
Private cCCAte		:= ""
Private cMatDe		:= ""
Private cMatAte		:= ""
Private dPerDe		:= CtoD("")
Private dPerAte		:= CtoD("")

Pergunte("CSM020",.F.)

AADD(aSays,OemToAnsi(STR0002) ) //"Este programa atualiza as graduacoes dos funcionarios conforme suas Referencias."
AADD(aSays,"")
AADD(aSays,OemToAnsi(STR0007) ) //"Importante:  o Valor de Referência de Graduação deverá estar com a mesma quantidade de caracteres aceitos conforme cadastrado na referência dos Fatores de Avaliação do Grupo!"
AADD(aSays,OemToAnsi(STR0008) ) //"Importante:  o Valor de Referência de Graduação deverá estar com a mesma quantidade de caracteres aceitos conforme cadastrado na referência dos Fatores de Avaliação do Grupo!"
AADD(aSays,OemToAnsi(STR0009) ) //"Importante:  o Valor de Referência de Graduação deverá estar com a mesma quantidade de caracteres aceitos conforme cadastrado na referência dos Fatores de Avaliação do Grupo!"

AADD(aButtons, { 5,.T.,{|| Pergunte("CSM020",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(Cs020OK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Processa({|lEnd| Cs020Processa()})	// Chamada do Processamento
EndIf

dbSelectArea("RAF")
dbSetOrder(1)
dbGotop()

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs020Processa ³ Autor ³ Cristina Ogura   ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs020Processa()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs020Processa()
Local aRegs 	:={}
Local cInicio	:= ""
Local cFim		:= ""
Local cFil 		:= ""
Local cGrupo 	:= ""
Local cCargo	:= ""
Local cFator	:= ""
Local cGrau 	:= ""
Local cPontos	:= ""
Local cGraduac	:= ""
Local nVlRefer	:= 0
Local nTpCarr	:= 0
Local cAcessaRAF:= &("{ || " + ChkRH(FunName(),"RAF","2") + "}")
Local cAcessaSRA:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")
Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel	:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lOfusca	:= Len(aFldRel) > 0

Local lRADtAdMan:= If(SRA->(ColumnPos("RA_DTADMAN")) > 0, .T., .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na pergunte                                 ³
//³ MV_PAR01				// Filial De                             ³
//³ MV_PAR02				// Filial Ate                            ³
//³ MV_PAR03				// Grupo De                              ³
//³ MV_PAR04				// Grupo Ate                             ³
//³ MV_PAR05				// Cargo De                              ³
//³ MV_PAR06				// Cargo Ate                             ³
//³ MV_PAR07				// Funcao De                             ³
//³ MV_PAR08				// Funcao Ate                            ³
//³ MV_PAR09				// Centro de Custo De                    ³
//³ MV_PAR10				// Centro de Custo Ate                   ³
//³ MV_PAR11				// Matricula De                          ³
//³ MV_PAR12				// Matricula Ate                         ³
//³ MV_PAR13				// Periodo De                            ³
//³ MV_PAR14				// Periodo Ate                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilDe		:= If(!Empty(MV_PAR01),MV_PAR01, Space(FWGETTAMFILIAL))
cFilAte		:= If(!Empty(MV_PAR02),MV_PAR02, Replicate("Z", FWGETTAMFILIAL))
cGrupoDe	:= If(!Empty(MV_PAR03),MV_PAR03, Space(GetSx3Cache("QN_GRUPO", "X3_TAMANHO" )) )
cGrupoAte	:= If(!Empty(MV_PAR04),MV_PAR04, Replicate("Z", GetSx3Cache("QN_GRUPO", "X3_TAMANHO" )) )
cCargoDe	:= If(!Empty(MV_PAR05),MV_PAR05, Space(GetSx3Cache("RA_CARGO", "X3_TAMANHO" )) )
cCargoAte	:= If(!Empty(MV_PAR06),MV_PAR06, Replicate("Z", GetSx3Cache("RA_CARGO", "X3_TAMANHO" )) )
cFuncaoDe	:= If(!Empty(MV_PAR07),MV_PAR07, Space(GetSx3Cache("RA_CODFUNC", "X3_TAMANHO" )) )
cFuncaoAte	:= If(!Empty(MV_PAR08),MV_PAR08, Replicate("Z", GetSx3Cache("RA_CODFUNC", "X3_TAMANHO" )) )
cCCDe		:= If(!Empty(MV_PAR09),MV_PAR09, Space(GetSx3Cache("RA_CC", "X3_TAMANHO" )) )
cCCAte		:= If(!Empty(MV_PAR10),MV_PAR10, Replicate("Z", GetSx3Cache("RA_CC", "X3_TAMANHO" )) )
cMatDe		:= If(!Empty(MV_PAR11),MV_PAR11, Space(GetSx3Cache("RA_MAT", "X3_TAMANHO" )) )
cMatAte		:= If(!Empty(MV_PAR12),MV_PAR12, Replicate("Z", GetSx3Cache("RA_MAT", "X3_TAMANHO" )) )
dPerDe		:= If(!Empty(MV_PAR13),MV_PAR13, CtoD("01/01/00"))
dPerAte		:= If(!Empty(MV_PAR14),MV_PAR14, CtoD("31/12/00"))


// Verifico as data referentes ao periodo
If dPerDe > dPerAte .Or. Empty(dPerDe) .Or. Empty(dPerAte)
	Help("",1,"Cs020DtPer")		// Verifique as data de Periodo
	Return
EndIf

// Filial De
cInicio	:="RAF->RAF_FILIAL+RAF->RAF_MAT+DTOS(RAF->RAF_DTINI)"
cFim	:= cFilAte+cMatAte+DTOS(dPerAte)

// Filial De
dbSelectArea("RAF")
dbSetOrder(1)
cFil := xFilial("RAF", cFilDe)

dbSeek(cFil+cMatDe+DtoS(dPerDe),.T.)

ProcRegua(RAF->(RecCount()))

While !Eof() .And. &cInicio <= cFim

	cFil	:= ""
	cCargo 	:= ""
	cGrupo 	:= ""
	cGrau	:= ""
	cFator 	:= RAF->RAF_FATOR
	nVlRefer:= RAF->RAF_REFER

	If !Eval(cAcessaRAF)
		dbSkip()
		Loop
	EndIf

	If 	RAF->RAF_MAT 	< cMatDe 	.Or.;
		RAF->RAF_MAT 	> cMatAte 	.Or.;
		RAF->RAF_DTINI	< dPerDe 	.Or.;
		RAF->RAF_DTFIM	> dPerAte
		dbSkip()
		Loop
	EndIf

	dbSelectArea("SRA")
	dbSetOrder(1)
	If	!dbSeek(RAF->RAF_FILIAL+RAF->RAF_MAT)
		dbSelectArea("RAF")
		dbSetOrder(1)
		dbSkip()
		Loop
	EndIf

	If !Eval(cAcessaSRA)
		dbSkip()
		Loop
	EndIf

	If	SRA->RA_SITFOLH == "D" 		.Or.;
	    SRA->RA_CODFUNC < cFuncaoDe 	.Or.;
	    SRA->RA_CODFUNC > cFuncaoAte 	.Or.;
	    SRA->RA_CC < cCCDe 				.Or.;
	    SRA->RA_CC > cCCAte

	    dbSelectArea("RAF")
	    dbSetOrder(1)
	    dbSkip()
	    Loop
	EndIf

    cCargo := fGetCargo(SRA->RA_MAT)

	// Busca o grupo e o cargo do funcionario
	FMontaFator(SRA->RA_FILIAL,SRA->RA_CODFUNC,@cCargo,SRA->RA_MAT,@cGrupo,,,SRA->RA_CC)

	If 	cCargo < cCargoDe 	.Or.;
		cCargo > cCargoAte 	.Or.;
		cGrupo < cGrupoDe 	.Or.;
		cGrupo > cGrupoAte

		dbSelectArea("RAF")
		dbSetOrder(1)
		dbSkip()
		Loop
	EndIf

	IncProc(SRA->RA_FILIAL+SRA->RA_MAT+"-"+ If(lOfusca, Replicate('*',15), SRA->RA_NOME) )

	// Verifico se o fator possui identificador no SQ1, pois somente os fatores com IDENT devem ser gerados
	cFil := xFilial("SQ1", SRA->RA_FILIAL)

	dbSelectArea("SQ1")
	dbSetOrder(1)
	If !dbSeek(cFil+cGrupo+cFator)
		dbSelectArea("RAF")
		dbSetOrder(1)
		dbSkip()
		Loop
	EndIf

	//	Tempo de Carreira
	If SQ1->Q1_IDENT == "001"
		If lRADtAdMan
			nVlRefer := Round((dDataBase - SRA->RA_DTADMAN)/365,0)
		Else
			nVlRefer := Round((dDataBase - SRA->RA_ADMISSA)/365,0)
		EndIf
	EndIf

	// Verifico o grau do valor de referencia
	cFil := xFilial("SQN", SRA->RA_FILIAL)

	dbSelectArea("SQN")
	dbSetOrder(1)
	dbSeek(cFil+cGrupo+cFator)
	While !Eof() .And. cFil+cGrupo+cFator == SQN->QN_FILIAL+SQN->QN_GRUPO+SQN->QN_FATOR

		If 	nVlRefer >= Val(SQN->QN_DE)	.And.;
			nVlRefer <= Val(SQN->QN_ATE)
			cGrau := SQN->QN_GRAU
			Exit
		EndIf
		dbSkip()
	EndDo

	//	Pontuacao do Fator/Grau
	dbSelectArea("SQ2")
	dbSetOrder(1)
	dbSeek(cFil+cGrupo+cFator+cGrau)
	cPontos := SQ2->Q2_PONTOSI

	// Atualizando SQ8 - Graduacao do Funcionario
	cFil := xFilial("SQ8", SRA->RA_FILIAL)

	dbSelectArea("SQ8")
	If 	dbSeek(cFil+SRA->RA_MAT+cFator)
		RecLock("SQ8",.F.)
	Else
		RecLock("SQ8",.T.)
			SQ8->Q8_FILIAL	:= cFil
			SQ8->Q8_MAT		:= SRA->RA_MAT
        	SQ8->Q8_FATOR	:= cFator
	EndIf

	If !Empty(cGrau)
		SQ8->Q8_GRAU	:= cGrau
		SQ8->Q8_PONTOS	:= cPontos

		// Grau de Escolaridade
		cGraduac := Left(Str(nVlRefer,2),2)

		If SQ1->Q1_IDENT == "002" .And. ExistCpo("SX5","26"+cGraduac)
			RecLock("SRA",.F.)
		    	SRA->RA_GRINRAI := cGraduac
		 	SRA->( MsUnlock() )
		EndIf
	EndIf

	SQ8->( MsUnLock() )

	dbSelectArea("RAF")
	dbSetOrder(1)
	dbSkip()

EndDo

Static Function Cs020Ok()
Return (MsgYesNo(OemToAnsi(STR0005),OemToAnsi(STR0006))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"
