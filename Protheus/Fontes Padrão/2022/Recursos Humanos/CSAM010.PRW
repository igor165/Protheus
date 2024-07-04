#INCLUDE "CSAM010.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CSAM010  ³ Autor ³ Cristina Ogura        ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o salario do funcionario conforme Tabela Salarial ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³10/07/14³TPZVUR³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Nivia Ferrei³03/09/15³PCREQ-³Produtizacao projeto GFP na release 12.   ³±±
±±³            ³        ³5350  ³                                          ³±±
±±³Marcos  Pere³03/11/15³PCREQ-³Ajuste na QUERYSR3() para retornar ao     ³±±
±±³            ³        ³5350  ³alias anterior (PCDEF-79708)              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function CSAM010()
Local nOpca := 0
Local oDlg
Local aRegs:={}
Local aSays:={ }, aButtons:= { } //<== arrays locais de preferencia
Local lCs010FimPe := ExistBlock( "Cs010FimPe" )//variavel para PE Cs010FimPe

Private cCadastro := OemtoAnsi(STR0001)//"Atualizacao salarios dos funcionarios"

Private nPerCom   := SuperGetMv("MV_VDFDCOM",,0)
Private lGestPubl := if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)	//Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP

Pergunte("CSM010",.F.)

AADD(aSays,OemToAnsi(STR0002) ) //"Este programa atualiza o salario dos funcionarios conforme a Tabela Salarial."
AADD(aButtons, { 5,.T.,{|| Pergunte("CSM010",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(Cs010OK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Processa({|lEnd| Cs010Processa()})	// Chamada do Processamento
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada para adicionar informacoes complementares |
		//³ apos processamento de gravacao.                            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCs010FimPe
			ExecBlock( "Cs010FimPe", .F., .F. )
		EndIf
EndIf

dbSelectArea("RB6")
dbSetOrder(1)
dbGotop()

Return Nil
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs010Processa ³ Autor ³ Cristina Ogura   ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs010Processa()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs010Processa()
Local nPosDt		:= 0
Local nPosTp		:= 0
Local nR7SeqTam
Local lAchouAlt		:= .T.
Local aR7AllRecs	:= {}
Local cInicio	:= ""
Local cFim		:= ""
Local cTabela	:= ""
Local cNivDe	:= ""
Local cNivAte	:= ""
Local cFilDe	:= ""
Local cFilAte	:= ""
Local cClasseDe	:= ""
Local cClasseAte:= ""
Local cTipAum	:= ""
Local dDatAum	:= cTod("")
Local nAtuDiss	:= 0
Local cFun		:= ""
Local nNovoSal	:= 0
Local cAcessaSRA:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")
Local aLog		:= {}
Local aTitle	:= {}
Local cLog		:= ""
Local lFirst	:= .T.
Local cFil		:= ""
Local cDescCar 	:= ""
Local lExistBlockSal:=ExistBlock("CSASAL1")
Local lAplicada := .F.
Local nRegRBR	:= 0

Local lComissionado := nil
Local lMesmaTab     := nil
Local lMesmoNFX     := nil
Local nNovoSalAux   := 0

Local lR7Cargo 		:= If(SR7->(ColumnPos("R7_CARGO")) > 0, .T., .F.)
Local lR7Desccar	:= If(SR7->(ColumnPos("R7_DESCCAR")) > 0, .T., .F.)
Local lR7Seq		:= If(SR7->(ColumnPos("R7_SEQ")) > 0, .T., .F.)
Local lR3Anteaum	:= If(SR3->(ColumnPos("R3_ANTEAUM")) > 0, .T., .F.)
Local lR3Seq		:= If(SR3->(ColumnPos("R3_SEQ")) > 0, .T., .F.)
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lOfusca		:= Len(aFldRel) > 0

Private DDATATAB

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na pergunte                                 ³
//³ mv_par01				// Tabela Salarial                       ³
//³ mv_par02				// Nivel da Tabela De                    ³
//³ mv_par03				// Nivel da Tabela Ate                   ³
//³ mv_par04				// Filial De                             ³
//³ mv_par05				// Filial Ate                            ³
//³ mv_par06				// Tipo Aumento                          ³
//³ mv_par07				// Data Aumento                          ³
//³ mv_par08				// Atualiza Sal. Dissidio 1-SIM 2-NAO    ³
//³ mv_par09				// Classe Salarial De					 ³
//³ mv_par10				// Classe Salarial Ate					 ³
//³ mv_par11				// Data da Tabela Salarial				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTabela		:= If(!Empty(mv_par01),mv_par01,"  ")
cNivDe		:= If(!Empty(mv_par02),mv_par02,"  ")
cNivAte		:= If(!Empty(mv_par03),mv_par03,"99")
cFilDe		:= If(!Empty(mv_par04),mv_par04,Space(FWGETTAMFILIAL))
cFilAte 	:= If(!Empty(mv_par05),mv_par05,Replicate("Z",FWGETTAMFILIAL))
cTipAum 	:= If(!Empty(mv_par06),mv_par06,0)
dDatAum		:= If(!Empty(mv_par07),mv_par07,dDataBase)
nAtuDiss	:= If(!Empty(mv_par08),mv_par08,2)
cClasseDe	:= If(!Empty(mv_par09),mv_par09,"   ")
cClasseAte	:= If(!Empty(mv_par10),mv_par10,"999")
dDataTab	:= If(!Empty(mv_par11),mv_par11,CTOD("//"))

If 	Empty(cTabela)
	Help("",1,"CS010NOTAB")	//Defina a tabela salarial nos parametros.
	Return Nil
EndIf

If Empty(dDatAum) .Or. Empty(cTipAum)
	Help("",1,"CS010NOAUM")		//Defina dados do Aumento nos parametros.
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica tipo de Tabela Salarial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFil := xFilial("RBR",xFilial("SRA"))
dbSelectArea("RBR")
dbSetOrder(1)
If dbSeek(cFil+cTabela+DTOS(dDataTab))
	If RBR->RBR_TIPOVL != 1 .and. RBR->RBR_TIPOVL != 3	// Nao for Valores Exatos
		Aviso(OemToAnsi(STR0006),OemToAnsi(STR0008),{"Ok"},,OemToAnsi(STR0009))	//"Atencao"#"O reajuste salarial atraves de Tabela, so' pode ser utilizado em tabela com valores Exatos."#"Tabela por Faixa"
		Return Nil
	EndIf

	lAplicada 	:= .T.
	nRegRBR		:= RBR->(RECNO())

EndIf

// Filial De
cInicio	:="SRA->RA_FILIAL"
cFim	:= cFilAte

// Filial De
dbSelectArea("SRA")
dbSetOrder(1)
dbSeek(cFilDe,.T.)

ProcRegua(SRA->(RecCount()))

While !Eof() .And. &cInicio <= cFim

	lComissionado := .F.
	lMesmaTab     := .F.
	lMesmoNFX	  := .F.

	cRaTabela  := SRA->RA_TABELA
	cRaTabNive := SRA->RA_TABNIVE
	cRaTabFaix := SRA->RA_TABFAIX
	nSalario   := SRA->RA_SALARIO

	If 	SRA->RA_SITFOLH == "D" 	.Or.;
		SRA->RA_TABELA # cTabela 	.Or.;
		SRA->RA_TABNIVE < cNivDe 	.Or.;
		SRA->RA_TABNIVE > cNivAte

		//Se Gestao de Folha Publica - SIGAGFP e
		//Se processando alteracao p/tabela do cargo efetivo de quem está em comissionamento
		If lGestPubl .And. SRA->RA_CATFUNC $ '3,1'

			//Busca a ultima SR3/SR7
			QUERYSR3()//Query de dados SR3->(dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Dtos(dDatAum) + cTipAum ))

			//Sendo a condicao verdadeira, alimenta lComissionado com .T. para determinar que estará
			//processamento a tabela de seu cargo do efetivo
			If TRBSR3->R3_TABELA  == cTabela .and. TRBSR3->R3_TABNIVE >= cNivDe .and. TRBSR3->R3_TABNIVE <=  cNivAte
				lComissionado := .T.
			Else
				SRA->(dbSkip())
				Loop
			EndIf
		Else
			SRA->(dbSkip())
			Loop
		EndIf

	EndIf

	If  lGestPubl .AND. SRA->RA_REGIME == '2' //Se Gestao de Folha Publica - SIGAGFP

		If !lComissionado
			QUERYSR3()//query SR3->(dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Dtos(dDatAum) + cTipAum ))
		EndIf

		//Se Categoria de Efetivo em Comissionamento
		If SRA->RA_CATFUNC $ '3,1'

		    //Verifica se as tabelas de seus cargos Efetivo e Comissionado é a mesma, para que ambos os subsídios sejam processados no mesmo momento.
			If TRBSR3->R3_TABELA  == TRBSR3->R3_CTABELA  .and. TRBSR3->R3_TABELA  == SRA->RA_TABELA
				lMesmaTab := .t.
				//Verifica se o Nivel e Faixa tambem sao os mesmos, para que utilize o mesmo subsidio novo para ambos os cargos
				If 	TRBSR3->R3_TABNIVE == TRBSR3->R3_CTABNIV .and. ;
					TRBSR3->R3_TABFAIX == TRBSR3->R3_CTABFAI .and. ;
					TRBSR3->R3_TABNIVE == SRA->RA_TABNIVE 	 .and. ;
					TRBSR3->R3_TABFAIX == SRA->RA_TABFAIX
					lMesmoNFX := .t.
				EndIf
			EndIf
		Endif
	EndIf


	If 	!Eval(cAcessaSRA)
		SRA->(dbSkip())
		Loop
	EndIf

	IncProc(SRA->RA_FILIAL+SRA->RA_MAT+"-"+ If(lOfusca, Replicate('*',15), SRA->RA_NOME) )

	// Busca descricao da funcao do funcionario
	cFun := DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL)

	// Busca o novo salario na Tabela Salarial
	If lExistBlockSal
		nNovoSal:=ExecBlock("CSASAL1",.F.,.F.,{cClasseDe, cClasseATe})

	Else

		If  lGestPubl .AND. SRA->RA_REGIME == '2' //Se Gestao de Folha Publica - SIGAGFP

			//Define o novo salario do cargo efetivo
			If lComissionado //Esta processando a tabela do cargo efetivo que esta na SR3
				nNovoSal := FBuscaTab(SRA->RA_FILIAL,TRBSR3->R3_TABELA,TRBSR3->R3_TABNIVE,TRBSR3->R3_TABFAIX,cClasseDe, cClasseATe)
				nSalario := SRA->RA_SUBCARR
			Else 		    //Esta processando a tabela que esta no SRA
				nNovoSal := FBuscaTab(SRA->RA_FILIAL,cRaTabela,cRaTabNive,cRaTabFaix,cClasseDe, cClasseATe)
			EndIf

		Else
			nNovoSal := FBuscaTab(SRA->RA_FILIAL,cRaTabela,cRaTabNive,cRaTabFaix,cClasseDe, cClasseATe)
		EndIf

	EndIf

	// Verifica se novo salario nao e' menor que salario anterior
	If nNovoSal < nSalario

		If lFirst
			cLog := STR0007	//"Funcionarios nao sofreram reajuste salarial devido novo valor ser inferior ao salario atual."
			Aadd(aTitle,cLog)
			Aadd(aLog,{})
			lFirst := .F.
		Endif

		cLog := SRA->RA_MAT +" - "+ If(lOfusca, Replicate('*',30), SRA->RA_NOME) + " Salario atual: "+Str(nSalario,12,2) + " Novo Salario: "+Str(nNovoSal,12,2)

		Aadd(aLog[1],cLog)

		dbSelectArea("SRA")
		dbSetOrder(1)
		dbSkip()
		Loop
	EndIf
	cDescCar := ""
	If SQ3->( dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+SRA->RA_CARGO+SRA->RA_CC)) .or. SQ3->( dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+SRA->RA_CARGO))
		cDescCar := SQ3->Q3_DESCSUM
	EndIf
	fSeqHistSal( @aR7AllRecs, @nR7SeqTam ) //Funcao para preenchimento dos campos R7_SEQ e R3_SEQ

	// Verifica Ja Teve Alteracao Se Nao Grava Anterior Na Primeira
	dbSelectArea("SR7")
	If !dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
		// Grava o Salario Anterior Quando Nao Existir Alteracao (SR7)
		RecLock("SR7",.T.,.T.)
		SR7->R7_FILIAL   := SRA->RA_FILIAL
		SR7->R7_MAT      := SRA->RA_MAT
		SR7->R7_DATA     := SRA->RA_ADMISSA
		SR7->R7_TIPO     := "001"
		SR7->R7_FUNCAO   := SRA->RA_CODFUNC
		SR7->R7_DESCFUN  := cFun
		SR7->R7_TIPOPGT  := SRA->RA_TIPOPGT
		SR7->R7_CATFUNC  := SRA->RA_CATFUNC
		If lR7Cargo
			SR7->R7_CARGO   := SRA->RA_CARGO
		EndIf
		If lR7Desccar
			SR7->R7_DESCCAR	:= cDescCar
		EndIf
		If lR7Seq .And. ValType(nR7SeqTam) == "N"
				SR7->R7_SEQ		:= Strzero( 1, nR7SeqTam )
		EndIf

		SR7->R7_USUARIO  := STR0003		//"Sistema"

		If  lGestPubl .AND. SRA->RA_REGIME == '2' //Se Gestao de Folha Publica - SIGAGFP
			SR7->R7_EFUNCAO	:=	SRA->RA_CODFUNC
			SR7->R7_EDESCFU	:=	cFun
			SR7->R7_ECAFUNC	:=	SRA->RA_CATFUNC
			SR7->R7_ECARGO	:=	SRA->RA_CARGO
			SR7->R7_EDESCCA	:=	cDescCar
		EndIf
		MsUnLock()

		// Grava o Salario Anterior Quando Nao Existir Alteracao (SR3)
		dbSelectArea("SR3")
		RecLock("SR3",.T.,.T.)
			SR3->R3_FILIAL   := SRA->RA_FILIAL
			SR3->R3_MAT      := SRA->RA_MAT
			SR3->R3_DATA     := SRA->RA_ADMISSA
			SR3->R3_PD       := "000"
			SR3->R3_DESCPD   := STR0004			//"SALARIO BASE"
			SR3->R3_VALOR    := SRA->RA_SALARIO
			SR3->R3_TIPO     := "001"
			If lR3Anteaum
				SR3->R3_ANTEAUM := SRA->RA_ANTEAUM
			EndIf
			If lR3Seq
				SR3->R3_SEQ		:= SR7->R7_SEQ
			EndIf

		If  lGestPubl .AND. SRA->RA_REGIME == '2' //Se Gestao de Folha Publica - SIGAGFP
			SR3->R3_ANTEAUM 	:= SRA->RA_SALARIO
			SR3->R3_TABELA   	:= SRA->RA_TABELA
			SR3->R3_TABNIVE 	:= SRA->RA_TABNIVE
			SR3->R3_TABFAIX 	:= SRA->RA_TABFAIX
			SR3->R3_CTABELA 	:= SRA->RA_TABELA
			SR3->R3_CTABNIV  	:= SRA->RA_TABNIVE
			SR3->R3_CTABFAI  	:= SRA->RA_TABFAIX
			SR3->R3_CSALAR		:= SRA->RA_SALARIO
		EndIf
		MsUnLock()
    EndIf

	// Atualizando SR7 - Alteracao Salarial
	dbSelectArea( "SR7" )
	If 	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Dtos(dDatAum) + cTipAum )
		RecLock("SR7",.F.,.T.)
	Else
		RecLock("SR7",.T.,.T.)
		lAchouAlt  := .F.
	EndIf

	SR7->R7_FILIAL   := SRA->RA_FILIAL
	SR7->R7_MAT      := SRA->RA_MAT
	SR7->R7_DATA     := If(dDatAum < SRA->RA_ADMISSA, SRA->RA_ADMISSA, dDatAum)
	SR7->R7_TIPO     := cTipAum
	SR7->R7_FUNCAO   := SRA->RA_CODFUNC
	SR7->R7_DESCFUN  := cFun
	SR7->R7_TIPOPGT  := SRA->RA_TIPOPGT
	SR7->R7_CATFUNC  := SRA->RA_CATFUNC
   	If lR7Cargo
	   	SR7->R7_CARGO   := SRA->RA_CARGO
   	EndIf
	If lR7Desccar
		SR7->R7_DESCCAR	:= cDescCar
	EndIf
	//SR7->R7_USUARIO  := SubStr(cUsuario,7,15)
	SR7->R7_USUARIO  := cUserName
	If lR7Seq

		If Len( aR7AllRecs ) > 0 .And. ( ( nPosDt := aScan( aR7AllRecs, { |x| x[ 1 ] == SR7->R7_DATA } ) ) > 0 ) //Existe alteracao salarial para a data informada

			If lAchouAlt //Mesmo tipo de aumento, entao localiza seq. e substitui

				nPosTp 	:= aScan( aR7AllRecs[ nPosDt, 2 ], { |x| x[ 2 ] == SR7->R7_TIPO } ) //Localiza registro do mesmo tipo de aumento
				SR7->R7_SEQ	:= aR7AllRecs[ nPosDt, 2, nPosTp, 3 ]
			Else //Tipo de aumento diferente, entao atualiza seq. como sendo a ultima

				aSort( @aR7AllRecs[ nPosDt, 2 ], , , { | x, y | x[ 3 ] < y[ 3 ] } )
				SR7->R7_SEQ	:= StrZero( Val( Soma1( aR7AllRecs[ nPosDt, 2, Len( aR7AllRecs[ nPosDt, 2 ] ), 3 ] ) ), nR7SeqTam )
			EndIf
		Else //Nao existem quaisquer alteracoes salariais p/ a data informada, logo eh a primeira seq.

			If( ValType(nR7SeqTam) == "N", SR7->R7_SEQ := StrZero( 1, nR7SeqTam ), )
		EndIf
	EndIf

	If  lGestPubl .AND. SRA->RA_REGIME == '2' //Se Gestao de Folha Publica - SIGAGFP
		If empty(TRBSR7->R7_EFUNCAO)
			SR7->R7_EFUNCAO	:=	SRA->RA_CODFUNC
			SR7->R7_EDESCFU	:=	cFun
			SR7->R7_ECAFUNC	:=	SRA->RA_CATFUNC
			SR7->R7_ECARGO	:=	SRA->RA_CARGO
			SR7->R7_EDESCCA	:=	cDescCar
		Else
			SR7->R7_EFUNCAO	:=	TRBSR7->R7_EFUNCAO
			SR7->R7_EDESCFU	:=	TRBSR7->R7_EDESCFU
			SR7->R7_ECAFUNC	:=	TRBSR7->R7_ECAFUNC
			SR7->R7_ECARGO	:=	TRBSR7->R7_ECARGO
			SR7->R7_EDESCCA	:=	TRBSR7->R7_EDESCCA
		EndIf
	Endif
	MsUnLock()

	// Atualizando SR3 - Alteracao Salarial
	dbSelectArea( "SR3" )
	If 	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Dtos(dDatAum) + cTipAum )
		RecLock("SR3",.F.,.T.)
	Else
		RecLock("SR3",.T.,.T.)
	EndIf
	SR3->R3_FILIAL   := SRA->RA_FILIAL
	SR3->R3_MAT      := SRA->RA_MAT
	SR3->R3_DATA     := If(dDatAum < SRA->RA_ADMISSA, SRA->RA_ADMISSA, dDatAum)
	SR3->R3_PD       := "000"
	SR3->R3_TIPO     := cTipAum

	If  lR3Seq
		SR3->R3_SEQ		:= SR7->R7_SEQ
	EndIf

	If 	lGestPubl .AND. SRA->RA_REGIME == '2' //Se Gestao de Folha Publica - SIGAGFP

		//Se executando aumento para tabela do Efetivo em servidor que está comissionado no momento,
		// atualiza campos de efetivo com o novo salario e campo do comissionado com o valor do ultimo SR3
		If lComissionado
			SR3->R3_VALOR  		:= nNovoSal
			SR3->R3_ANTEAUM 	:= nNovoSal
			SR3->R3_CSALAR		:= TRBSR3->R3_CSALAR

		//Se servidor efetivo em comissionamento, que esta executando aumento para o cargo efetivo (lComissionado=.f.),
		// atualiza campos de efetivo com o valor do ultimo SR3 e campo do comissionado com o novo salario
		ElseIf SRA->RA_CATFUNC $ '3,1'
			SR3->R3_VALOR  		:= TRBSR3->R3_VALOR
			SR3->R3_ANTEAUM 	:= TRBSR3->R3_ANTEAUM
			SR3->R3_CSALAR		:= nNovoSal
			//Se efetivo e comissionado utilizam a mesma tabela,
			If lMesmaTab
				//Se alem de usar a mesma tabela, usa tambem mesmo nivel e faixa
				// atualiza campos de efetivo com o novo salario
				If lMesmoNFX
					SR3->R3_VALOR  		:= nNovoSal
					SR3->R3_ANTEAUM 	:= nNovoSal
				//Se mesma tabela, porem com nivel ou faixa diferente,
				// busca o novo salario para nivel/faixa e atualiza campos do efetivo com o novo valor encontrado
				Else
					nNovoSalAux 		:= FBuscaTab(SRA->RA_FILIAL,TRBSR3->R3_TABELA,TRBSR3->R3_TABNIVE,TRBSR3->R3_TABFAIX,cClasseDe, cClasseATe)
					SR3->R3_VALOR  		:= nNovoSalAux
					SR3->R3_ANTEAUM 	:= SR3->R3_VALOR
				EndIf
			EndIf
		//Demais servidores, atualiza efetivo e comissionado com o novo valor
		//Mesmo quem não eh comissionado, os campos de comissionados na SR3 e SR7 repetem os valores de efetivo, ficando em branco
		//os campos de comissionado referente ao percentual e tipo de diferenca de comissionamento
		Else
			SR3->R3_VALOR  		:= nNovoSal
			SR3->R3_ANTEAUM 	:= nNovoSal
			SR3->R3_CSALAR		:= nNovoSal
		EndIf
		SR3->R3_TABELA 	:= if(!empty(TRBSR3->R3_TABELA),TRBSR3->R3_TABELA,SRA->RA_TABELA)
		SR3->R3_TABNIVE	:= if(!empty(TRBSR3->R3_TABNIVE),TRBSR3->R3_TABNIVE,SRA->RA_TABNIVE)
		SR3->R3_TABFAIX	:= if(!empty(TRBSR3->R3_TABFAIX),TRBSR3->R3_TABFAIX,SRA->RA_TABFAIX)
		SR3->R3_CTABELA	:= if(!empty(TRBSR3->R3_CTABELA),TRBSR3->R3_CTABELA,SRA->RA_TABELA)
		SR3->R3_CTABNIV	:= if(!empty(TRBSR3->R3_CTABNIV),TRBSR3->R3_CTABNIV,SRA->RA_TABNIVE)
		SR3->R3_CTABFAI	:= if(!empty(TRBSR3->R3_CTABFAI),TRBSR3->R3_CTABFAI,SRA->RA_TABFAIX)
		SR3->R3_TPSBCOM	:= if(!empty(TRBSR3->R3_TPSBCOM),TRBSR3->R3_TPSBCOM,SRA->RA_TPSBCOM)
		SR3->R3_PERCCOM	:= if(!empty(TRBSR3->R3_PERCCOM),TRBSR3->R3_PERCCOM,if(SR3->R3_TPSBCOM<>'2',0,nPerCom))
		SR3->R3_DESCPD 	:= STR0011		//"SUBSIDIO BASE"

	Else
		SR3->R3_VALOR 	:= nNovoSal
		SR3->R3_DESCPD  := STR0004		//"SALARIO BASE"
		If lR3Anteaum
			SR3->R3_ANTEAUM	:= If(  nAtuDiss == 1, nNovoSal, SRA->RA_ANTEAUM )
		EndIf

	EndIf
	MsUnLock()

	// Atualizando SRA
	dbSelectArea( "SRA" )
	RecLock( "SRA" , .F. )

	If  lGestPubl .AND. SRA->RA_REGIME == '2' //Se Gestao de Folha Publica - SIGAGFP
		If  lComissionado
			Replace SRA->RA_SUBCARR With nNovoSal
		ElseIf SRA->RA_CATFUNC $ '3,1'
			Replace SRA->RA_SALARIO With nNovoSal
			If  lMesmaTab
				If  lMesmoNFX
					Replace SRA->RA_SUBCARR With nNovoSal
				Else
					Replace SRA->RA_SUBCARR With nNovoSalAux
				EndIf
			Endif
		Else
			Replace SRA->RA_SUBCARR With nNovoSal
			Replace SRA->RA_SALARIO With nNovoSal
		EndIf
	Else
		Replace SRA->RA_SALARIO With nNovoSal
	Endif

	If 	nAtuDiss == 1
		If  lGestPubl .AND. SRA->RA_REGIME == '2'
			Replace SRA->RA_ANTEAUM With SRA->RA_SALARIO
		Else
			Replace SRA->RA_ANTEAUM With nNovoSal
		Endif
	EndIf
	MsUnlock()

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSkip()

EndDo

If lAplicada

	dbSelectArea("RBR")
	//Atualiza campo APLICADA
	RBR->( MsGoto( nRegRBR ) )
	Reclock("RBR",.F.)
	RBR->RBR_APLIC := "1"
	MsUnlock()

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama rotina de Log de Ocorrencias. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fMakeLog(aLog,aTitle,"CSM010")

If Select("TRBSR3") > 0
	TRBSR3->( dbCloseArea())
EndIf
If Select("TRBSR7") > 0
	TRBSR7->( dbCloseArea())
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FBuscaTab ³ Autor ³ R.H. - Marcos Stiefano³ Data ³ 27/06/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca na tabela o salario do funcionario                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FBuscaTab(cFil,cTabela,cNivel,cFaixa)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FBuscaTab(cFil,cTabela,cNivel,cFaixa,cClasseDe,cClasseAte)
Local aSaveArea := GetArea()
Local nNovoSal	:= 0

cFil := xFilial("RB6", cFil)
dbSelectArea("RB6")
dbSetOrder(3)
If dbSeek(cFil+cTabela+DTOS(dDataTab)+cNivel+cFaixa)
	While !EoF() .And. RB6->RB6_FILIAL+RB6->RB6_TABELA+dtos(RB6->RB6_DTREF)+RB6->RB6_NIVEL+RB6->RB6_FAIXA == ;
						cFil+cTabela+DTOS(dDataTab)+cNivel+cFaixa
		If RB6->RB6_CLASSE >= cClasseDe .And. RB6->RB6_CLASSE <= cClasseAte
			nNovoSal := RB6->RB6_VALOR
		EndIf
		dbskip()
	EndDo
EndIf

RestArea(aSaveArea)

Return nNovoSal

Static Function Cs010Ok()
Return (MsgYesNo(OemToAnsi(STR0005),OemToAnsi(STR0006))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"



/*
-------------------------------------------------------------
Query com as informações da SR3 para atender gestão publica
-------------------------------------------------------------*/
Static Function QUERYSR3()
Local cQuery  	:= ""
Local aArea		:= getarea()

If Select("TRBSR3") > 0
	TRBSR3->( dbCloseArea())
EndIf

cQuery += " SELECT * "
cQuery += " FROM "
cQuery += + RetSqlName("SR3") +  " SR3 "
cQuery += " WHERE "
cQuery += " SR3.R3_FILIAL = '"+SRA->RA_FILIAL+ "' AND "
cQuery += " SR3.R3_MAT = '"+SRA->RA_MAT+ "' AND "
cQuery += " SR3.D_E_L_E_T_ = ' ' AND "
cQuery += " SR3.R3_DATA <= '"+dTos(dDataTab)+"' "
cQuery += " Order by R3_DATA DESC ,R3_SEQ DESC "
cQuery = ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSR3",.T.,.T.)

If Select("TRBSR7") > 0
	TRBSR7->( dbCloseArea())
EndIf

cQuery := " SELECT * "
cQuery += " FROM "
cQuery += + RetSqlName("SR7") +  " SR7 "
cQuery += " WHERE "
cQuery += " SR7.R7_FILIAL = '"+SRA->RA_FILIAL+ "' AND "
cQuery += " SR7.R7_MAT = '"+SRA->RA_MAT+ "' AND "
cQuery += " SR7.D_E_L_E_T_ = ' ' AND "
cQuery += " SR7.R7_DATA <= '"+dTos(dDataTab)+"' "
cQuery += " Order by R7_DATA DESC ,R7_SEQ DESC "
cQuery = ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSR7",.T.,.T.)

RestArea(aArea)

Return
