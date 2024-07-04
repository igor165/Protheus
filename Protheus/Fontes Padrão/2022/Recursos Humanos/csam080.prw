#INCLUDE "CSAM080.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CSAM080  ³ Autor ³ Cristina Ogura        ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza aumento programado do funcionario.                ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³18/07/14³TPZVUR³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Esther V.   ³07/06/16³TVFY37³Incluida validacao de acesso de usuario.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAM080()
Local nOpca := 0
Local oDlg
Local aRegs:={}
Local aSays:={ }, aButtons:= { } //<== arrays locais de preferencia

Private cCadastro := OemtoAnsi(STR0001)//"Atualizacao salarios dos funcionarios"

Pergunte("CSM080",.F.)

AADD(aSays,OemToAnsi(STR0002) ) //"Este programa atualiza o salario dos funcionarios conforme o aumento programado"
AADD(aButtons, { 5,.T.,{|| Pergunte("CSM080",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(Cs080OK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Processa({|lEnd| Cs080Processa()})	// Chamada do Processamento
EndIf

dbSelectArea("RB7")
dbSetOrder(1)
dbGotop()

Return Nil
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs080Processa ³ Autor ³ Cristina Ogura   ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs080Processa()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs080Processa()
Local cAcessaRB7:= &("{ || " + ChkRH(FunName(),"RB7","2") + "}")
Local cFilDe, cFilAte
Local cMatDe, cMatAte
Local cCCDe, cCCAte
Local cFuncDe, cFuncAte
Local dPerDe, dPerAte
Local cInicio, cFim
Local cFil
Local cDescCar 	:= ""
Local nPosDt		:= 0
Local nPosTp		:= 0
Local nR7SeqTam
Local lAchouAlt		:= .T.
Local aR7AllRecs	:= {}
Local nSalAnt  		:= 0
Local lGpAltSal		:= ExistBlock( "GPALTSAL" )
Local cDeAum		:= ""
Local cAteAum		:= ""
Local lAtuDiss		:= .F.
Local lTSREP		:= SuperGetMv( "MV_TSREP" , NIL , .F. )
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lOfusca		:= Len(aFldRel) > 0
Private oObjREP		:= Nil

// mv_par01		- Filial De
// mv_par02		- Filial Ate
// mv_par03		- Matricula De
// mv_par04		- Matricula Ate
// mv_par05		- Centro Custo De
// mv_par06		- Centro Custo Ate
// mv_par07		- Funcao De
// mv_par08		- Funcao Ate
// mv_par07		- Periodo De
// mv_par08		- Periodo Ate

Pergunte("CSM080",.F.)

// Variaveis da pergunte
cFilDe	:= mv_par01
cFilAte	:= mv_par02
cMatDe	:= mv_par03
cMatAte	:= mv_par04
cCCDe	:= mv_par05
cCCAte	:= mv_par06
cFuncDe	:= mv_par07
cFuncAte:= mv_par08
dPerDe	:= mv_par09
dPerAte	:= mv_par10
cDeAum	:= mv_par11
cAteAum	:= mv_par12
lAtuDiss:= mv_par13

// Validando os dados da pergunte
If 	Empty(dPerDe) .Or. Empty(dPerAte)
	Help("",1,"CS080DATA")		//Data do periodo em branco
	Return Nil
EndIf

If 	dPerDe > dPerAte
	Help("",1,"CS080MAIOR")		//Data do periodo de esta maior que a data do periodo ate
	Return Nil
EndIf

	If FindFunction("SPFilterOff")       // verifica se existe a função
		SPFilterOff( { "SR3", "SR7" } )           //desabilita o filtro da tabela
	EndIf
// Filial De
cInicio	:="RB7->RB7_FILIAL"
cFim	:= cFilAte

If lTSREP
	oObjREP := PTSREPOBJ():New()
EndIF

dbSelectArea("RB7")
dbSetOrder(1)
cFil := If(xFilial("RB7") == Space(FWGETTAMFILIAL),xFilial("RB7"),cFilDe)

dbSeek(cFil,.T.)
dbGoTop()
ProcRegua(RecCount())

While RB7->(!Eof()) .And. &cInicio <= cFim

	If 	RB7->RB7_MAT < cMatDe 	.Or.;
		RB7->RB7_MAT > cMatAte	.Or.;
		RB7->RB7_DATALT < dPerDe .Or.;
		RB7->RB7_DATALT > dPerAte .Or.;
		RB7->RB7_TPALT < cDeAum .Or.;
		RB7->RB7_TPALT > cAteAum .Or.;
		RB7->RB7_ATUALI == "S"
		RB7->(dbSkip())
		Loop
	EndIf

	If !( RB7->RB7_FILIAL $ fValidFil() )
	    RB7->(dbSkip())
	   	Loop
	EndIf

	If !Eval(cAcessaRB7)
		dbSkip()
		Loop
	EndIf

	dbSelectArea("SRA")
	dbSetOrder(1)
	If dbSeek(RB7->RB7_FILIAL+RB7->RB7_MAT)

		If 	SRA->RA_SITFOLH == "D" .Or.;
		   	SRA->RA_CC < cCCDe		.Or.;
			SRA->RA_CC > cCCAte		.Or.;
			SRA->RA_CODFUNC < cFuncDe .Or.;
			SRA->RA_CODFUNC > cFuncAte .Or.;
			SRA->RA_SALARIO > RB7->RB7_SALARI   //Se salario atual for maior que salario programado, nao faz o reajuste.
			dbSelectArea("RB7")
			dbSkip()
			Loop
		EndIf

		IncProc(SRA->RA_FILIAL+SRA->RA_MAT+"-"+ If(lOfusca, Replicate('*',15), SRA->RA_NOME) )

		// Busca descricao da funcao do funcionario
		cFun 	:= DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL)
		cDescCar:= ""
		If SQ3->( dbSeek(xFilial("SQ3")+SRA->RA_CARGO+SRA->RA_CC)) .or. SQ3->( dbSeek(xFilial("SQ3")+SRA->RA_CARGO))
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
			SR7->R7_USUARIO  := STR0003		//"Sistema"
	   		If SR7->( Type("R7_CARGO") ) # "U"
			   	SR7->R7_CARGO   := SRA->RA_CARGO
		   	EndIf
			If SR7->( Type("R7_DESCCAR") ) # "U"
				SR7->R7_DESCCAR	:= cDescCar
			EndIf
			If SR7->( Type("R7_SEQ") ) # "U" .And. ValType(nR7SeqTam) == "N"
				SR7->R7_SEQ		:= Strzero( 1, nR7SeqTam )
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
			If SR3->( Type("R3_ANTEAUM") ) # "U"
				SR3->R3_ANTEAUM := SRA->RA_ANTEAUM
			EndIf
			If SR3->( Type("R3_SEQ") ) # "U"
				SR3->R3_SEQ		:= SR7->R7_SEQ
			EndIf
			MsUnLock()
	    EndIf

		// Atualizando SR7 - Alteracao Salarial
		dbSelectArea("SR7")
		If 	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Dtos(RB7->RB7_DATALT) + RB7->RB7_TPALT)
			RecLock("SR7",.F.,.T.)
		Else
			RecLock("SR7",.T.,.T.)
			lAchouAlt := .F.
		EndIf

		// Busca descricao da funcao do funcionario
		cFun := DescFun(RB7->RB7_FUNCAO,SRA->RA_FILIAL)

		SR7->R7_FILIAL   := SRA->RA_FILIAL
		SR7->R7_MAT      := SRA->RA_MAT
		SR7->R7_DATA     := RB7->RB7_DATALT
		SR7->R7_TIPO     := RB7->RB7_TPALT
		SR7->R7_FUNCAO   := RB7->RB7_FUNCAO
		SR7->R7_DESCFUN  := cFun
		SR7->R7_TIPOPGT  := SRA->RA_TIPOPGT
		SR7->R7_CATFUNC  := RB7->RB7_CATEG
		//SR7->R7_USUARIO  := SubStr(cUsuario,7,15)
		SR7->R7_USUARIO  := cUserName
	   	If SR7->( Type("R7_CARGO") ) # "U"
	   		If RB7->( Type("RB7_CARGO") ) # "U" .and. !Empty(RB7->RB7_CARGO)
			   	SR7->R7_CARGO   := RB7->RB7_CARGO
			   	cDescCar:= ""
				If SQ3->( dbSeek(xFilial("SQ3")+RB7->RB7_CARGO+SRA->RA_CC)) .or. SQ3->( dbSeek(xFilial("SQ3")+RB7->RB7_CARGO))
					cDescCar := SQ3->Q3_DESCSUM 		//Atualiza descricao do cargo
			   	EndIf
	   		Else
			   	SR7->R7_CARGO   := SRA->RA_CARGO
			EndIf
	   	EndIf
		If SR7->( Type("R7_DESCCAR") ) # "U"
			SR7->R7_DESCCAR	:= cDescCar
		EndIf
		If SR7->( Type("R7_SEQ") ) # "U"

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
		MsUnLock()

		// Atualizando SR3 - Alteracao Salarial
		dbSelectArea("SR3")
		If 	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Dtos(RB7->RB7_DATALT) + RB7->RB7_TPALT )
			RecLock("SR3",.F.,.T.)
		Else
			RecLock("SR3",.T.,.T.)
		EndIf
		SR3->R3_FILIAL	:= SRA->RA_FILIAL
		SR3->R3_MAT  	:= SRA->RA_MAT
		SR3->R3_DATA  	:= RB7->RB7_DATALT
		SR3->R3_PD 		:= "000"
		SR3->R3_DESCPD	:= STR0004				//"SALARIO BASE"
		SR3->R3_VALOR	:= RB7->RB7_SALARI
		SR3->R3_TIPO	:= RB7->RB7_TPALT
		If SR3->( Type("R3_ANTEAUM") ) # "U"
			SR3->R3_ANTEAUM	:= If( lAtuDiss == 1, RB7->RB7_SALARI, SRA->RA_ANTEAUM )
		EndIf
		If SR3->( Type("R3_SEQ") ) # "U"
			SR3->R3_SEQ		:= SR7->R7_SEQ
		EndIf
		MsUnLock()

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Ponto de Entrada para atualizar tabela personalizada        ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If lGpAltSal
        	Execblock("GPALTSAL",.F.,.F.,)
		Endif

		nSalAnt := SRA->RA_SALARIO//armazena salario anterior ao reajuste
		// Atualizando SRA
		dbSelectArea("SRA" )
		RecLock("SRA",.F.)
			Replace SRA->RA_SALARIO	With RB7->RB7_SALARI
			Replace SRA->RA_CATFUNC	With RB7->RB7_CATEG
			Replace SRA->RA_CODFUNC	With RB7->RB7_FUNCAO

	   		If RB7->( Type("RB7_CARGO") ) # "U" .and. !Empty(RB7->RB7_CARGO)
   				Replace SRA->RA_CARGO	With RB7->RB7_CARGO
			EndIf

			If lAtuDiss == 1
				Replace SRA->RA_ANTEAUM	With RB7->RB7_SALARI
			EndIf
		MsUnlock()

		dbSelectArea("RB7")
		RecLock("RB7",.F.)
			Replace RB7->RB7_ATUALI		With "S"
			Replace RB7->RB7_DTPROC		With dDataBase
		MsUnlock()

		// Ponto-de-Entrada para Gravação Log Alteração
		If ExistBLock("CSA080GRV")
			ExecBlock("CSA080GRV",.F.,.F., {nSalAnt} )
		EndIf

    	If lTSREP

			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Executa o WebServices TSA - Usuario 					       ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If oObjREP:WSUser( 3 )
				oObjRep:WSUpdRHExp( "SRA" )
			Endif

    	EndIF

	EndIf

	dbSelectArea("RB7")
	dbSetOrder(1)
	dbSkip()
EndDo

If FindFunction("SPFilterOff")       // verifica se existe a função
   	SPFilterOff(  { "SR3", "SR7" } ,  .F.  )    //ativa o filtro
EndIf

Return Nil

Return .T.

Static Function Cs080Ok()
Return (MsgYesNo(OemToAnsi(STR0005),OemToAnsi(STR0006))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"