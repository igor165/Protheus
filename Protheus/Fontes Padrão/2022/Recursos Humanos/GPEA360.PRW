#INCLUDE "Protheus.ch"
#INCLUDE "GPEA360.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEA360  ³ Autor ³ Andreia dos Santos    ³ Data ³  27/11/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de PPP                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA360()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cecilia Ca.³ 15/05/15 ³TPPCSB³Incluido o fonte da 11 para a 12 e efetuada³±±
±±³            ³          ³      ³a limpeza.                                 ³±±
±±³WinstonCosta³ 02/01/19 ³DRHPAG-22991³Retirada do trecho que trata o AS/400³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA360

Local cFiltraSRA			//Variavel para filtro
Local aIndexSRA		:= {}	//Variavel Para Filtro

Private bFiltraBrw 	:= {|| Nil}				//Variavel para Filtro
Private nTamCc		:= TamSx3("Q3_CC")[1]

Private aRotina 	:= MenuDef() 			// ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cCadastro 	:= OemToAnsi(STR0004) 	//"Periodo Profissiografico"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltraRh := CHKRH("GPEA360","SRA","1")
bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SRA")
mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SRA",aIndexSRA)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GP360Gera³ Autor ³ Andreia dos Santos    ³ Data ³ 27/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o historico de salario/funcao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP360Gera()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function GP360Gera(cAlias,nReg,nOpc)
Local oDlg
Local nOpca		:= 0
Local aSays		:= {}
Local aButtons	:= {} //<== arrays locais de preferencia
Local aGetArea	:= GetArea()

Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F. , {"", ""} }) //[1] Acesso; [2]Ofusca
Local aFldOfusca:= {}
Local lOfuscaNom:= .F.
Local aMsg		:= aOfusca[3]

Private aGrava	:= 	{}
Private aLog	:=	{}
Private aTitle	:= 	{}
Private aTotRegs:= array(01)

Private cCadastro := OemtoAnsi(STR0005)//"Atualizacao Cargos/Funcoes dos funcionarios"

if aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
ENDIF

if lOfuscaNom
	Help(" ",1,aMsg[1],,aMsg[2],1,0)
else

	Pergunte("GPA360",.F.)

	AADD(aSays,OemToAnsi(STR0006) ) //"Este rotina gera as informacoes de cargos/funcoes, Centro de Custo "
	AADD(aSays,OemToAnsi(STR0007) ) //" de funcionarios num determinado periodo."
	AADD(aSays,OemToAnsi(STR0032) ) //"Nao serao gerados registros para Funcoes que nao tiverem Cargo relacionado."

	AADD(aButtons, { 5,.T.,{|| Pergunte("GPA360",.T. ) } } )
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(GP360CHk() .and. GP360Conf(),FechaBatch(),nOpca:=0) }} )
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )

	If nOpca == 1
		Processa({|lEnd| GP360Proces1()})	// Chamada do Processamento
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Organiza o array aGrava por Filial, Matricula e Data Inicial³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fOrganiza(@aGrava)

		Processa({|lEnd| GP360GrvRC6()})	// Chamada do Processamento
	EndIf

	fMakeLog(aLog,aTitle,,,"SE"+DTOS(mv_par07),STR0034,"G","P",,.F.) //Log de Ocorrencias - PPP
ENDIF

RestArea(aGetArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP360CHk  ºAutor  ³Microsiga           º Data ³  12/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o periodo esta preenchido.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GP360CHk()
lRet := .T.
If empty(mv_par07) .or. empty(mv_par08)
	Aviso(STR0013,STR0014,{"OK"}) //"Periodo nao preenchido"###"Preencha o periodo desejado"
	lRet := .F.
Endif

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao  ³GP360Proces1  ºAutor  ³Andreia dos Santos  º Data ³ 27/11/02  º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³Busca os dados e grava no RC6                                 º±±
±±º        ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³ AP6                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GP360Proces1()

Local cFilDe	:= 	Space(FWGETTAMFILIAL)
Local cFilAte	:= 	Space(FWGETTAMFILIAL)
Local cMatDe	:= 	""
Local cMatAte	:= 	""
Local cCCDe		:= 	""
Local cCCAte	:= 	""
Local dDataDe	:= 	ctod("")
Local dDataAte	:= 	cTod("")

Pergunte("GPA360",.F.)

// Variaveis da pergunte
cFilDe		:= mv_par01 //- Filial De
cFilAte		:= mv_par02 //- Filial Ate
cMatDe		:= mv_par03 //- Matricula de
cMatAte		:= mv_par04 //- Matricula Ate
cCCDe		:= mv_par05 //- Centro Custo De
cCCAte		:= mv_par06 //- Centro Custo Ate
dDataDe		:= mv_par07 //- Periodo De
dDataAte	:= mv_par08 //- Periodo Ate


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca os dados de Transferencia e Alteracao de cargos e guarda no array aGrava³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GP360LeArq(@aGrava,cFilDe,cFilAte,cMatDe,cMatAte,cCCDe,cCCAte,dDataDe,dDataAte)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao  ³GP360GrvRC6   ºAutor  ³Andreia dos Santos  º Data ³ 27/11/02  º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³Grava os dados no RC6                                         º±±
±±º        ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³ AP6                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GP360GrvRC6()
Local nX 		:= 1
Local lInclui	:= .T.
Local cCodCC	:= ""
Local cMatOLd	:= ""
Local dDtFinal	:= ctod("")
Local cCodGFIP	:= ""
Local aArea		:= {}
Local cAuxFil	:= ""
Local cFilSv	:= cFilAnt
Local lTypeCTT  := Type("CTT->CTT_OCORRE") # "U"

aFill(aTotRegs,0)

ProcRegua(len(aGrava))



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aGrava ³
//³[01] = Filial             ³
//³[02] = Matricula          ³
//³[03] = Data Inicio        ³
//³[04] = Data Fim           ³
//³[05] = Centro de Custo    ³
//³[06] = Codigo da Funcao   ³
//³[07] = Descricao da Funcao³
//³[08] = Codigo do Cargo    ³
//³[09] = Descricao do Cargo ³
//³[10] = Grava Reg.( T/F)   ³
//³[11] = Origem do Lanc.    ³
//³[12] = Cod. GFIP          ³
//³[13] = Foi transf. Filial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Grava no RC6 os dados armazenados em aGrava
ProcRegua(len(aGrava))

	For nx:=1 To Len(aGrava)

		SRA->(dbSetOrder(1))
		SRA->( dbSeek(aGrava[nx][1]+aGrava[nx][02])) //Filial+Matricula

		IncProc(STR0023 + substr(SRA->RA_NOME,1,20)) //"Gravando em RC6: "

		lInclui := RC6->(! dbSeek(aGrava[nx][01]+aGrava[nx][02]+dtos(aGrava[nx][03])))

		IF !(!lInclui  .and. RC6->RC6_ORIGEM == "I") //-- Nao altera lancamentos incluidos pelo usuario

			//-- Cargo inexistente
			IF  Empty(aGrava[nx][08])
				If aTotRegs[1]== 0
					cLog := STR0033 //"Nao tem cargo relacionado com a funcao    Fl/Matr.   Nome                            Dt.Inic.  Funcao"
					Aadd(aTitle,cLog)
					Aadd(aLog,{})
					aTotRegs[1] := len(aLog)
				EndIf

				If nX > 1 .and. (cMatOLd == aGrava[nX][2])
					Aadd(aLog[aTotRegs[1]],Space(85)+dtoc(aGrava[nx][03])+"  "+aGrava[nx][06]+"-"+aGrava[nx][07]+" "+aGrava[nx][05])
				Else
					Aadd(aLog[aTotRegs[1]],Space(42)+aGrava[nx][01]+"/"+aGrava[nx][02]+"  "+SRA->RA_NOME+"  "+dtoc(aGrava[nx][03])+"  "+aGrava[nx][06]+"-"+aGrava[nx][07]+" "+aGrava[nx][05] )
				EndIF
				cMatOld := aGrava[nX][2]
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca no SR9 o codigo GFIP	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SR9")
			dbSetOrder(1)

			cCodGFIP := SRA->RA_OCORREN
			If SR9->( dbSeek(aGrava[nx][01]+aGrava[nx][02]+"RA_OCORREN"))
				//----------------------------------------------------------------------------
				// Acertando o primeiro registro do historico de funcionario, devido o GPEA010
				// estar gravando incorretamente a data do primeiro registro. 24/08/07
				If Dtos(SR9->R9_DATA) <> Dtos(SRA->RA_ADMISSA)
					RecLock("SR9",.F.)
						SR9->R9_DATA	:= SRA->RA_ADMISSA
					MsUnlock()
				Endif
				While SR9->(!Eof()) .And. aGrava[nx][01]+aGrava[nx][02]+"RA_OCORREN" ==;
										SR9->R9_FILIAL+SR9->R9_MAT+SR9->R9_CAMPO

					If Dtos(SR9->R9_DATA) <= Dtos(dDtFinal)
						cCodGFIP := Alltrim(SR9->R9_DESC)
					EndIf

					//Caso seja o ultimo registro, pegue o CodGFIF do RA_OCORREN
					If Empty(dDtFinal)
						cCodGFIP := SRA->RA_OCORREN
					Endif
					dbSkip()
				EndDo
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao encontrar o cod.GFIP no cadastro de funcionarios.³
			//³procura no Centro de Custo                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If empty(cCodGFIP) .and. lTypeCTT
				aArea := GetArea()
				dbSelectArea("CTT")
				cAuxFil := aGrava[nx][01]

				If dbSeek(  xFilial('CTT',cAuxFil) + cCodCC )
					cCodGFIP := CTT->CTT_OCORRE
				Endif
				RestArea(aArea)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona na filial do funcionario para gravacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cFilAnt := aGrava[nx][01]


			RecLock("RC6",lInclui)
			RC6->RC6_FILIAL		:= aGrava[nx][01]
			RC6->RC6_MAT		:= aGrava[nx][02]
			RC6->RC6_DATAIN		:= aGrava[nx][03]

			If !Empty(aGrava[nx][04])
				RC6->RC6_DATAFI		:= aGrava[nx][04]
			Else
				RC6->RC6_DATAFI		:= SRA->RA_DEMISSA
			EndIf

			RC6->RC6_CC			:= aGrava[nx][05]
			RC6->RC6_CODFUN		:= aGrava[nx][06]
			RC6->RC6_DESCFU		:= aGrava[nx][07]

			RC6->RC6_CARGO		:= aGrava[nx][08]
			RC6->RC6_DESCCA		:= aGrava[nx][09]
			RC6->RC6_ORIGEM		:= aGrava[nx][11]
			RC6->RC6_GFIP			:= cCodGFIP

			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Volta a Filial de origem apos a gravacao.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cFilAnt := cFilSv
		Endif
	Next nX

dbSelectArea("SRA")
dbSetOrder(1)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GP360LeArqºAutor  ³Andreia dos Santos  º Data ³  29/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Le arquivos RC6,SR7 e SRE para montar o historico das      º±±
±±º          ³ funcoes/setores do funcionario                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA360                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GP360LeArq(aGrava,cFilDe,cFilAte,cMatDe,cMatAte,cCCDe,cCCAte,dDataDe,dDataAte)

Local cInicio	:=	""
Local cFim		:=	""
Local cIndCond	:=	""
Local cArqNtx	:=	""
Local nx		:= 	""
Local ny		:= 	""
Local cCodFunc 	:=	""
Local cDescFunc := 	""
Local cCargo	:= 	""
Local cDescCargo:=	""
Local cCodCC	:= 	""
Local nItem		:= 0
Local nPos		:= 0

LOCAL cQuery    := ""
LOCAL cAliasSR7 := ""
LOCAL cAliasSRE := ""
LOCAL cAliasRC6 := ""
Local aStru		:= {}      //Estrutura da Query
Local lQuery	:= .F.
Local dData		:= dDataDe
Local lTransf	:= .F.
Local dDtAnt	:= ctod("")
Local aTransf	:= {}
Local aTransfAll:= {}
Local aRet		:= {}
Local lExistMov	:= .F.
Local aCargos	:= {}
Local dDem  	:= Ctod('')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aGrava ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³[01] = Filial             ³
//³[02] = Matricula          ³
//³[03] = Data Inicio        ³
//³[04] = Data Fim           ³
//³[05] = Centro de Custo    ³
//³[06] = Codigo da Funcao   ³
//³[07] = Descricao da Funcao³
//³[08] = Codigo do Cargo    ³
//³[09] = Descricao do Cargo ³
//³[10] = Grava Reg.( T/F)   ³
//³[11] = Origem do Lanc.    ³
//³[12] = Cod. GFIP          ³
//³[13] = Foi Transf. Filial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


cAliasRC6 := "RC6"

lQuery := .T.

cAliasRC6 := "QRC6"
aStru := RC6->(dbStruct())

cQuery := "SELECT "
For nX := 1 To len(aStru)
	cQuery += aStru[ nX , 1 ] + ", "
Next nX
cQuery += "R_E_C_N_O_ RECNO "
cQuery += "  FROM " + RetSqlName("RC6")
cQuery += " WHERE RC6_FILIAL  between '" + cFilDe + "' AND '" + cFilAte + "'"
cQuery += "   AND RC6_MAT     between '" + cMatDe + "' AND '" + cMatAte + "'"
cQuery += "   AND RC6_DATAIN  between '" + dtos(dDataDe) + "' AND '" + dtos(dDataAte)+ "'"
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY RC6_FILIAL, RC6_MAT, RC6_DATAIN"

cQuery := ChangeQuery( cQuery )

If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cAliasRC6,.T.,.T.)
	For nX := 1 To Len(aStru)
		If ( aStru[nX][2] <> "C" )
			TcSetField(cAliasRC6,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
Else
	lQuery := .F.
	cAliasRC6 := "RC6"
	RC6->(dbSeek(cFilDe+cMatDe,.T. ))
Endif

cFim	:= cFilAte
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca no RC6 as informacoes de outras geracoes e/ou que foram incluidas manualmente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua((cAliasRC6)->(RecCount()))

While (cAliasRC6)->(!eof()) .and. (cAliasRC6)->RC6_FILIAL <= cFim

    SRA->(dbSetOrder(1))
	SRA->( dbSeek((cAliasRC6)->RC6_FILIAL+(cAliasRC6)->RC6_MAT))

	IncProc(STR0026+ substr(SRA->RA_NOME,1,20)) //"Lendo cadastro anterior: "

	If (cAliasRC6)->RC6_MAT < cMatDe .or. (cAliasRC6)->RC6_MAT > cMatAte
		(cAliasRC6)->(dbSkip())
		Loop
	EndIf

	If SRA->RA_CC < cCCDe .or. SRA->RA_CC > cCCAte
		(cAliasRC6)->(dbSkip())
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o registro foi gerado pelo sistema, e um outro registro equivalente³
	//³houver sido armazenado em aGrava, deleta o registro no RC6 para       ³
	//³gravar um novo.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasRC6)->RC6_ORIGEM == "I"
		aAdd(aGrava,{	(cAliasRC6)->RC6_FILIAL	,;	//Filial
						(cAliasRC6)->RC6_MAT	,;	//Matricula
						(cAliasRC6)->RC6_DATAIN	,;	//Data Inicio
						(cAliasRC6)->RC6_DATAFI	,;	//Data Fim
						(cAliasRC6)->RC6_CC		,;	//Centro de Custo
						(cAliasRC6)->RC6_CODFUN	,;	//Codigo da Funcao
						(cAliasRC6)->RC6_DESCFU	,;	//Descricao da Funcao
						(cAliasRC6)->RC6_CARGO	,;	//Codigo do Cargo
						(cAliasRC6)->RC6_DESCCA	,;	//Descricao do Cargo
						.T.						,; 	//Indica se vai gravar no arquivo ou nao
						(cAliasRC6)->RC6_ORIGEM	,;	//Indica se foi G=Gerado,  I= Informado
						(cAliasRC6)->RC6_GFIP	,;  //Codigo GFIP
						.F.						,;  //.T.=Transferido de outra filial; .F. = Nao transferido
						'RC6'					})
	 Endif

	If Ascan(aGrava,{|x| x[1]+x[2]+dtos(x[3]) == (cAliasRC6)->RC6_FILIAL+(cAliasRC6)->RC6_MAT+dtos((cAliasRC6)->RC6_DATAIN)}) > 0
		If lQuery
			nReg := RECNO
			dbSelectArea( "RC6" )
			dbGoTo( nReg )
		EndIf
		RecLock("RC6",.F.,.T.)
		RC6->(dbDelete())
    	MsUnlock()
    EndIF

	(cAliasRC6)->(dbSkip())
EndDo

If ( lQuery )
	dbSelectARea(cAliasRC6)
	dbCloseArea()
	dbSelectArea("RC6")
	lQuery := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca no SRA o cargo/funcao atual do funcionario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(SRA->(RecCount()))

dData:=Ctod('')

SRA->(dbSetOrder(1))
SRA->(dbSeek(cFilDe+cMatDe,.T. ))
While SRA->(!Eof()) .and. SRA->RA_FILIAL+SRA->RA_MAT >= cFilDe+cMatDe .and. ;
							SRA->RA_FILIAL+SRA->RA_MAT <= cFilAte+cMatAte

	IncProc(STR0027+ substr(SRA->RA_NOME,1,20)) //"Lendo dados atuais: "

	If SRA->RA_MAT < cMatDe .or. SRA->RA_MAT > cMatAte
		SRA->(dbSkip())
		Loop
	EndIf

	If SRA->RA_CC < cCCDe .or. SRA->RA_CC > cCCAte
		SRA->(dbSkip())
		Loop
	EndIf

	If SRA->RA_ADMISSA < dDataDe .or. SRA->RA_ADMISSA > dDataAte
		SRA->(dbSkip())
		Loop
	EndIf

	aRet		:= fPeriodos(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	If aRet == nil
		SRA->( dbSkip() )
		Loop
	EndIf
	aTransf 	:= aClone(aRet[1])
	aTransfAll 	:= aClone(aRet[2])


    If !Empty(aTransf)
		For nX:= 1 To Len(aTransf)

			If aTransf[nx,2,1]< dDataDe .or. aTransf[nx,2,2] > dDataAte
				Loop
			EndIf

            aCargos:= {}
			aCargos:= LeSR7(	aTransf[nx,5]	,;  //01 - Filial DE
							 	aTransf[nx,5]	,;	//02 - Filial ATE
							 	aTransf[nx,6]	,;	//03 - Mat DE
							 	aTransf[nx,6]	,; 	//04 - Mat ATE
							 	aTransf[nx,2,1]	,;	//05 - Data DE
							 	aTransf[nx,2,2]	,;	//06 - Data ATE
							 	aTransf[nx,7]	,;	//07 - CCusto  da Transferencia
							    aTransfAll		,;  //08 - Todas as transferencias do funcionario
							    aTransf[nX,8]   ;  //09 - Posicao da transferencia de origem do funcionario
						 	)

            IF !Empty(aCargos)
                For nY:=1 To len(aCargos)

                	If !Empty(aGrava) .And. nY == 1 .And. Empty(aGrava[Len(aGrava)][4])
                    	aGrava[Len(aGrava)][4]:= aCargos[nY,3] - 1
                	Endif

					aAdd(aGrava,{	aCargos[nY,1]		,;			//01 - Filial
									aCargos[nY,2]		,;			//02 - Matricula
									aCargos[nY,3]		,;			//03 - Data Inicio
									aCargos[nY,4]		,;		 	//04 - Data Fim
									aCargos[nY,5] 	,;			//05 - Centro de Custo
									aCargos[nY,6]		,;			//06 - Codigo da Funcao
									aCargos[nY,7]		,;			//07 - Descricao da Funcao
									aCargos[nY,8]		,;			//08 - Codigo do Cargo
									aCargos[nY,9]		,;			//09 - Descricao do Cargo
									.T.					,; 			//10 - Indica se vai gravar no arquivo ou nao
									"G"					,;			//11 - Indica se foi G=Gerado,  I= Informado
									""					,;		 	//12 - Codigo GFIP
									.F.					,;			//13 - .T.=Transferido de outra filial; .F. = Nao transferido
									'SR7'				})
				Next nY

            Else

		   		cCargo := fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)
				cCodCC := aTransf[nx,7]
				dbSelectArea("SQ3")
				dbSetOrder(1)
				If dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo+cCodCC) .Or. dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo)
		   	 		cDescCargo := SQ3->Q3_DESCSUM
		   		EndIf

            	aAdd(aGrava,{	SRA->RA_FILIAL		,;			//01 - Filial
								SRA->RA_MAT			,;			//02 - Matricula
								aTransf[nx,2,1]		,;			//03 - Data Inicio
								aTransf[nx,2,2]		,;		 	//04 - Data Fim
								cCodCC 				,;			//05 - Centro de Custo
								SRA->RA_CODFUNC		,;			//06 - Codigo da Funcao
								fDesc("SRJ",SRA->RA_CODFUNC,"RJ_DESC")	,;	//07 - Descricao da Funcao
								cCargo				,;			//08 - Codigo do Cargo
								cDescCargo			,;			//09 - Descricao do Cargo
								.T.					,; 			//10 - Indica se vai gravar no arquivo ou nao
								"G"					,;			//11 - Indica se foi G=Gerado,  I= Informado
								""					,;		 	//12 - Codigo GFIP
								.F.					,;			//13 - .T.=Transferido de outra filial; .F. = Nao transferido
								'SRA'				})
            Endif
		Next nX

    Else

    	aCargos	:= LeSR7(	SRA->RA_FILIAL,SRA->RA_FILIAL,SRA->RA_MAT, SRA->RA_MAT,dDataDe, Min(dDataAte,SRA->RA_DEMISSA), SRA->RA_CC)

        IF !Empty(aCargos)
            For nY:=1 To len(aCargos)
            	dDem	:= aCargos[nY,4]
                IF nY == Len(aCargos)
                	dDem:= SRA->RA_DEMISSA
                Endif
				aAdd(aGrava,{	aCargos[nY,1]		,;			//01 - Filial
								aCargos[nY,2]		,;			//02 - Matricula
								aCargos[nY,3]		,;			//03 - Data Inicio
								dDem				,;		 	//04 - Data Fim
								aCargos[nY,5] 	,;			//05 - Centro de Custo
								aCargos[nY,6]		,;			//06 - Codigo da Funcao
								aCargos[nY,7]		,;			//07 - Descricao da Funcao
								aCargos[nY,8]		,;			//08 - Codigo do Cargo
								aCargos[nY,9]		,;			//09 - Descricao do Cargo
								.T.					,; 			//10 - Indica se vai gravar no arquivo ou nao
								"G"					,;			//11 - Indica se foi G=Gerado,  I= Informado
								""					,;		 	//12 - Codigo GFIP
								.F.					,;			//13 - .T.=Transferido de outra filial; .F. = Nao transferido
								'SR7'				})
			Next nY
		Else
			cCodCC :=  SRA->RA_CC
			cCargo	:=	fGetCargo(SRA->RA_MAT, SRA->RA_FILIAL)
			cDescCargo := ""
			If SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo+cCodCC))
				cDescCargo := SQ3->Q3_DESCSUM
			ElseIf SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo+space(nTamCc)))
				cDescCargo := SQ3->Q3_DESCSUM
		   	EndIf

			dData:= SRA->RA_ADMISSA
			//-- Procura pela primeira transferencia 'Para'
			IF ( nPos:= Ascan(aGrava, {|x| ( ( x[1]+x[2] ) ==  SRA->(RA_FILIAL + RA_MAT) ) .AND. X[14] == 'SRE' }) ) > 0
			   //-- Caso exista uma transferencia 'De' anterior a primeira transferencia 'Para'
			   //-- significa que o funcionario foi admitido de fato nessa filial e, portanto, vale a data de admissao
			   //-- caso a transferencia 'Para' seja anterior a qualquer transferencia 'De'
			   //-- significa que ele veio de outra filial e, portanto, a data de admissao devera
			   //-- ser substituida pela data da transferencia
			   dData:= IF(	dDtAnt < aGrava[nPos, 3], dData, aGrava[nPos, 3] )
			Endif

			aAdd(aGrava,{	SRA->RA_FILIAL		,;			//Filial
							SRA->RA_MAT			,;			//Matricula
							dData				,;			//Data Inicio
							SRA->RA_DEMISSA		,;		 	//Data Fim
							cCodCC  			,;			//Centro de Custo
							SRA->RA_CODFUNC		,;			//Codigo da Funcao
							fDesc("SRJ",SRA->RA_CODFUNC,"RJ_DESC")	,;	//Descricao da Funcao
							cCargo				,;			//Codigo do Cargo
							cDescCargo			,;			//Descricao do Cargo
							.T.					,; 			//Indica se vai gravar no arquivo ou nao
							"G"					,;			//Indica se foi G=Gerado,  I= Informado
							""					,;		 	//Codigo GFIP
							.F.					,;			//.T.=Transferido de outra filial; .F. = Nao transferido
							'SRA'				})
		Endif
    Endif

	SRA->( dbSkip() )
EndDo

SRE->(RetIndex())

If File(cArqNtx+OrdBagExt())
   FERASE(cArqNtx+OrdBagExt())
Endif
SRE->( dbSetOrder(1))

RETURN .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GP360Rot ³ Autor ³ Andreia dos Santos    ³ Data ³ 27/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de inclusao/alteracao/Consulta dos periodos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpeA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function GP360Rot(cAlias,nReg,nOpc)
Local oGet
Local oLbx
Local oDlg
Local oFont
Local oGroup
Local cChave	:= ""
Local cNome		:= SRA->RA_NOME
Local nGrava	:= 0
Local aPerField := {"RC6_FILIAL","RC6_MAT"}
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aFldRot 		:= {'RA_NOME', 'RA_ADMISSA'}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca

Local lOfuscaNom	:= .F.
Local lOfuscaAdm	:= .F.
Local aFldOfusca 	:= {}

Local aNoFields 	:= 	{"RC6_FILIAL","RC6_MAT"}
Local bSeekWhile	:= {|| RC6->RC6_FILIAL + RC6->RC6_MAT }
Local nSRDOrd		:= RetOrdem( "RC6" , "RC6_FILIAL+RC6_MAT+DTOS(RC6_DATAIN)" )
Private nPosRec		:= 0

// Definicao dos arrays da getdados
Private aCols 		:= 	{}
Private aColsAnt	:=	{}
Private aHeader		:= 	{}
Private aGrvRC7 	:= 	{}
Private nUsado		:= 	0
//-- Variavel da mbrowse
Private cMat		:= SRA->RA_MAT
Private dDtInicio	:= CTOD("  /  /  ")
Private cAliasRC6	:= "RC6"
Private aColsRC6	:= {}

cCod 	:= SRA->RA_MAT
cDesc	:= SRA->RA_NOME
dDataIn	:= Dtos(SRA->RA_ADMISSA)

//Tratamento dados sensíveis
If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_ADMISSA" } ) > 0
		lOfuscaAdm := FwProtectedDataUtil():IsFieldInList( "RA_ADMISSA" )
	ENDIF

	cNome := If(lOfuscaNom,Replicate('*',15),OemToAnsi(SRA->RA_NOME))
	cDesc := cNome
	dDataIn := If(lOfuscaAdm,Replicate('*',10),Dtoc(SRA->RA_ADMISSA))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aCols da GetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := xFilial("RC6",SRA->RA_FILIAL)+cMat

nOpc := Iif(nOpc==3,2,nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva o acols para verificar posteriormente se houve alteracao nos dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasRC6)
FillGetDados(nOpc							,; //1-nOpc - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
			 cAliasRC6						,; //2-cAlias - area a ser utilizada;
			 nSRDOrd						,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			 xFilial(cAliasRC6,SRA->RA_FILIAL)+cCod		,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			 bSeekWhile						,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			 NIL							,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
			 aNoFields		   	    		,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
			 NIL							,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
			 NIL							,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
			 NIL							,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
			 NIL							)  //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}

//Carrega as variaveis no acols, quando for inclusao:
lRet	:= fCarAcolsA360(nOpc,cChave)
If !lRet
	Return
Endif
cGet := cCod + " - " + cDesc
aColsAnt := aClone( aCols)
aColsRC6 :=  aClone( aCols)

SETAPILHA()

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL
   	@ aObjSize[1,1] , aObjSize[1,2]      GROUP oGroup TO aObjSize[1,3] ,aObjSize[1,4]*0.10 LABEL OemToAnsi(STR0008) OF oDlg PIXEL	// "Matricula:"
	oGroup:oFont:= oFont
	@ aObjSize[1,1] , aObjSize[1,4]*0.11 GROUP oGroup TO aObjSize[1,3] ,aObjSize[1,4]*0.8 LABEL OemToAnsi(STR0009) OF oDlg PIXEL	// "Nome:"
	oGroup:oFont:= oFont
	@ aObjSize[1,1] , aObjSize[1,4]*0.81 GROUP oGroup TO aObjSize[1,3] ,aObjSize[1,4] LABEL OemToAnsi(STR0036) OF oDlg PIXEL	// "Admiss„o:"
	oGroup:oFont:= oFont

	@ aObjSize[1,1]+10 , aObjSize[1,2]+10      SAY StrZero(Val(SRA->RA_MAT),Len(SRA->RA_MAT))					SIZE 050,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+10 , aObjSize[1,4]*0.10+10 SAY If(lOfuscaNom,Replicate('*',15),OemToAnsi(SRA->RA_NOME))		SIZE 146,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+10 , aObjSize[1,4]*0.80+10 SAY If(lOfuscaAdm,Replicate('*',10),Dtoc(SRA->RA_ADMISSA))		SIZE 050,10 OF oDlg PIXEL FONT oFont

	oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpc,"GP360LOk","GP360TdOk","",If(nOpc=4,Nil,.T.),,1,,300,,,,,oDlg)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar	(oDlg,{|| If(oGet:TudoOk(),(nGrava:= 1,oDlg:End()),.F.) },;
   	   			{||nGrava:=0,oDlg:End()},,;
	   			{{"bmpincluir",{||If( oGet:TudoOk(),Gp360Expo(nOpc),.F.)},OeMToAnsi(STR0009),OemToAnsi(STR0037)} }) //"Exposicao a Riscos"#"Exp.Ag."

If 	nGrava == 1
	Begin Transaction
	    If nOpc <> 4
			GP360Grv(aCols)
		Else
			a360Dele()
		Endif
		EvalTrigger()
	End Transaction
EndIf

Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA360   ºAutor  ³Microsiga           º Data ³  12/19/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fCarAcolsA360(nOpc,cChave)
Local aSaveArea := GetArea()
Local cCargo	:= ""

If nOpc <> 4 .And. Len(aCols) = 1 .and. Empty(aCols[1][1])
    SRA->(dbSetOrder(1))
	SRA->( dbSeek( cChave ) )
	SR7->( dbSeek( cChave+ dtos(SRA->RA_ADMISSA)))

	nPosDataIni := GdFieldPos( "RC6_DATAIN" )
	nPosDataFim := GdFieldPos( "RC6_DATAFI" )
	nPosCC 		:= GdFieldPos( "RC6_CC" )
	nPosCodFun  := GdFieldPos( "RC6_CODFUN" )
	nPosDescFun := GdFieldPos( "RC6_DESCFU" )
	nPosCargo   := GdFieldPos( "RC6_CARGO" )
	nPosDescca  := GdFieldPos( "RC6_DESCCA" )
	nPosOrigem  := GdFieldPos( "RC6_ORIGEM" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Array do 1§ Elemento Vazio. Se Inclusao                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If nPosDataIni > 0
		aCols[1][nPosDataIni]	:= SRA->RA_ADMISSA
	Endif
	If nPosDataFim > 0
		aCols[1][nPosDataFim]	:= SRA->RA_DEMISSA
	EndIf
	If nPosCC > 0
		aCols[1][nPosCC]		:= SRA->RA_CC
	Endif
	If nPosCodFun > 0
		aCols[1][nPosCodFun]	:= SRA->RA_CODFUNC
	Endif
	If nPosDescFun > 0
		aCols[1][nPosDescFun]	:= fDesc("SRJ",SRA->RA_CodFunC,"RJ_DESC")
	Endif
	If nPosCargo > 0
		cCargo := aCols[1][nPosCargo] := fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)
	Endif
	If nPosDescca > 0
		If SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo+SRA->RA_CC))
			aCols[1][nPosDescca]	:= SQ3->Q3_DESCSUM
		ElseIf SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo))
			aCols[1][nPosDescca]	:= SQ3->Q3_DESCSUM
    	EndIf
	Endif
	If nPosOrigem > 0
		aCols[1][nPosOrigem]	:= "G"
	Endif
ElseIf nOpc = 4 .And. Len(aCols) = 1 .and. Empty(aCols[1][1])
		Help(" ",1,"A040SLANC")
		Return(.f.)
EndIf

nPosRec:=GdfieldPos("RC6_REC_WT")
If nOpc == 3
	aCols[1][nPosRec]:= 0
EndIf

RestArea(aSaveArea)
Return .T.




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gp360LOk  ³ Autor ³ Andreia dos Santos    ³ Data ³ 27/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de linha ok da getdados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GPEA360   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GP360LOk()
Local lRet 		:= .T.
Local nPosDtIni := 	GdFieldPos("RC6_DATAIN")
Local nX

If aCols[n,len(aHeader)+1]  = .F.

	For nx = 1 To Len(aHeader)
		If Empty(aCols[n,nx])
			If Trim(aHeader[nx,2]) == "RC6_DATAIN" .and. lRet
				AVISO(STR0015,STR0016,{'OK'},,STR0018)  //"Atencao"###"Informe a data Inicial do periodo"###"Data Invalida"
				lRet := .F.
				Exit
			Endif
			If Trim(aHeader[nx,2]) == "RC6_CC" .and. lRet
				Aviso(STR0015,STR0017,{'OK'},,STR0030) //"Atencao"//"Informe o Centro de Custo"###"Inconsistencia"
				lRet := .F.
				Exit
			Endif
		Endif

		If Trim(aHeader[nx,2]) == "RC6_DATAIN" .and. lRet .and.(aCols[n,nx] < SRA->RA_ADMISSA)
			AVISO(STR0015,STR0029,{'OK'},,STR0018)  //"Atencao"### ###"Data Invalida"
			lRet := .F.
			Exit
		Endif

		If Trim(aHeader[nx,2]) == "RC6_DATAFI" .and. lRet
			If !empty(aCols[n,nx]) .and. (aCols[n,nx] <  aCols[n,nPosDtIni]) // Data final nao pode ser menor que data inicial
		  		Aviso(STR0015,STR0019,{'OK'},,STR0018)  //"Atencao"###"A Data Final do Periodo nao pode ser inferior a Data Inicial"###"Data Invalida"
				lRet := .F.
				Exit
			EndIf
		Endif
	Next nx
	IF lRet
		lRet := GdCheckKey( { "RC6_CC" , "RC6_DATAIN"} , 4 )
	EndIF
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gp360TdOk ³ Autor ³ Mauricio MR           ³ Data ³ 08/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de consistencia de todas as linhas da getdados       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GPEA360   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GP360TdOk()
Local nX
Local nY
Local nZ
Local nLenaCols	:= Len(aCols)
Local nLenRC6Cls:= Len(aColsRC6)
Local nPosCC	:= GdFieldPos("RC6_CC")
Local nPosDtIni := GdFieldPos("RC6_DATAIN")
Local nPosDtFim := GdFieldPos("RC6_DATAFI")
Local nPosAtvDes:= GdFieldPos("RC6_ATVDES")
Local dDtIniX	:= ''
Local dDtFimX	:= ''
Local dDtIniY	:= ''
Local dDtFimY	:= ''
Local lRet		:= .T.
Local cErro		:= ''

//-- Bloco para tornar uma data (b) sempre maior que uma data de comparacao (a)
Local bMaiorData:= {|a,b| IF( Empty(b), a+1,  b ) }

//-- Corre Cada uma das linhas
For nX:=1 to nLenaCols
 	//-- Se estiver deletada despreza-a
	If ( GdDeleted(nX) )
	   Loop
	Endif


    dDtIniX	:= aCols[nX, nPosDtIni]
    dDtFimX := aCols[nX, nPosDtFim]

    //-- Corre as demais linhas
	For nY:=1 to nLenaCols
        //-- Se for a mesma linha que deu origem ao limite ou se estiver deletada despreza-a
	    If nX==nY .or. ( GdDeleted(nY) )
	    	Loop
	    Endif


	    dDtIniY	:= aCols[nY, nPosDtIni]
	    dDtFimY := aCols[nY, nPosDtFim]

	    //-- Nao permite mais de um periodo com data fim em branco
	    IF Empty(dDtFimX) .and. Empty(dDtFimY)
	     	 lRet:=.F.
	     	 cErro:= '(#001)'
             Exit
       	Endif

       	//-- Verifica se existe sobreposicao de periodos
		If 	 (dDtIniY <= dDtFimX) .and. Empty(dDtFimY)
             lRet:=.F.
	     	 cErro:= '(#002)'
             Exit
       	Endif

        //-- Verifica se existe sobreposicao de periodos
		If   ( ;
					( Eval( bMaiorData,dDtIniX, dDtFimY ) <  dDtIniX )  ) .or.;
					( dDtIniY > ( Eval( bMaiorData,dDtIniY, dDtFimX ) ) ;
			   )
       	Else
       	    lRet:= .F.
			cErro:= '(#003)'
       	    Exit
       	Endif


    Next nY

   	IF !lRet
        cHelp:= STR0045 //"Existe Sobreposicao de Periodos"
       	cHelp+=  CRLF //
	 	cHelp+=  cErro + CRLF //
       	MsgInfo( OemToAnsi(cHelp) + CRLF  )

        Exit
  	Endif

    IF nX <=nLenRC6Cls
	    //-- Corre as demais linhas
		For nZ:=1 to nLenRC6Cls
	        //-- Se for a mesma linha que deu origem ao limite
		    If nX==nZ
		    	Loop
		    Endif
	        IF ( aCols[nX, nPosCC] == aColsRC6[nZ, nPosCC] ) .and. ( aCols[nX, nPosDtini] == aColsRC6[nZ, nPosDtini] )
	           lRet:= .F.
	        	nZ	:= nLenRC6Cls
				nX	:= nLenaCols
				cErro:= '(#004)'
			 	cHelp:= STR0046 + CRLF //"Identificado relacionamento cruzado de periodos."
			 	cHelp+= STR0047 + CRLF //"Por exemplo, na linha 1 foi substituida a data inicial pela data inicial da linha 2 e vice-versa."
			 	cHelp+=  CRLF //
			 	cHelp+=  cErro + CRLF //
		       	MsgInfo( OemToAnsi(cHelp) + CRLF  )

	        Endif

	    Next nZ
    Endif

Next nX

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GP360Conf ºAutor  ³Microsiga           º Data ³  28/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Confirmacao de execucao da geracao dos dados                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Gp360Conf()
Return (MsgYesNo(OemToAnsi(STR0020),OemToAnsi(STR0015)))  //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Gp360Expo³ Autor ³ Andreia dos Santos    ³ Data ³ 27/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lancamento de exposicao a riscos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA360                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Gp360Expo(nOpc)
Local oGet2
Local oDlg
Local aColsRec	:= {}
Local aAuxCols	:= Aclone(aCols)
Local aAuxHeader:= Aclone(aHeader)
Local nAuxN		:= n
Local cFil 		:= xFilial("SRA")
Local cDescr	:= SRA->RA_NOME
Local cChave  	:= ""
Local cChvRC7	:= ""
Local nGrava	:= 0
Local nLenRC7   := 0
Local nPosDtIn 	:= GdFieldPos("RC6_DATAIN")
Local nPosDtFi 	:= GdFieldPos("RC6_DATAFI")
Local cAliasRC7	:= "RC7"

Local cCadastro := OemToAnsi(STR0009) //"Exposicao a Fatores Riscos"
Local nx		:= 0
Local nItem		:= 0

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local oFont
Local oGroup

Local aNoFields 	:= 	{"RC7_FILIAL","RC7_MAT","RC7_DATAFI","RC7_DATAIN"}
Local bSeekWhile	:= {|| RC7->RC7_FILIAL + RC7->RC7_MAT + Dtos(RC7->RC7_DATAIN) }
Local nRC7Ord		:= RetOrdem( "RC7" , "RC7_FILIAL+RC7_MAT+DTOS(RC7_DATAIN)+RC7_AGENTE" )
Local nCont			:= 0
Local nCont1 		:= 0
Local nCont2 		:= 0

LOCAL aFldRot  		:= {'RA_NOME'}
Local aOfusca  		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca
LOCAL aFldOfusca 	:= {}
lOCAL lOfuscaNom	:= .f.

Private nPosRec		:= 0

IF aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
ENDIF

aColsAnt := aClone(aColsRC6)

cCod 	:= SRA->RA_MAT
cDesc	:= SRA->RA_NOME
dDataIn	:= Dtos(RC6->RC6_DATAIN)

nOpc := Iif(nOpc==3,2,nOpc)
dbSelectArea(cAliasRC7)

If n <=len(aColsAnt)
   	dDtInicio := aColsAnt[n,nPosDtIn]
	cChvRC7 := xFilial("RC7",SRA->RA_FILIAL) + cMAT + dTos( dDtInicio )
Else
	dDtInicio 	:= aAuxCols[n,nPosDtIn]
	//-- Cria chave ficticia para somente montar o aHeader e o aCols
	cChvRC7 	:= '!!!!!'
EndIf

dDtFim 	:= Iif(nPosDtFi > 0, aAuxCols[n,nPosDtFi],"")

	cChave := xFilial("RC7",SRA->RA_FILIAL)+cMAT
	aHeader	:= {}
	aCols	:= {}
//-- Para lancamentos pre-existentes
nItem := Ascan(aGrvRC7,{|x| x[6] == nAuxN })
If nItem > 0
   aCols	:= aClone(aGrvRC7[nItem][4])
   aHeader  := aClone(aGrvRC7[nItem][5])
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva o acols para verificar posteriormente se houve alteracao nos dados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FillGetDados(nOpc							 	,; //1-nOpc - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				 cAliasRC7							,; //2-cAlias - area a ser utilizada;
				 nRC7Ord							,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cChvRC7							,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 bSeekWhile							,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				 NIL								,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields		   	    			,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				 NIL								,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				 NIL								,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				 NIL								,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL								)  //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}


	//Carrega as variaveis no acols, quando for inclusao:
	fCarAcolsRC7(nOpc,cChave)

	IF  RC7->(	dbSeek(xFilial(cAliasRC7,SRA->RA_FILIAL)+cCod+Dtos(dDtInicio) ) )
		cChvRC7 := RC7->RC7_FILIAL + cMAT + dTos( RC7->RC7_DATAIN )
		While RC7->(!Eof()) .And. RC7->( xFilial("RC7",SRA->RA_FILIAL)+RC7->RC7_Mat+dTos(RC7->RC7_DATAIN) == cChvRC7 )
			AADD(aColsRec, RC7->(Recno()))
			RC7->(dbSkip())
		Enddo
	Endif

Endif


cGet := cCod + " - " + cDesc

SETAPILHA()
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 010 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 050 , 050 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg FROM	8.5,1 TO 30,99 TITLE cCadastro OF oMainWnd

	@ 12 , 0    GROUP oGroup TO  29.12 , 37.6 	LABEL OemToAnsi(STR0008) OF oDlg PIXEL	// "Matricula:"
	oGroup:oFont:= oFont
	@ 12 , 39.6 GROUP oGroup TO 29.12 ,314.8	LABEL OemToAnsi(STR0035) OF oDlg PIXEL	// "Nome:"
	oGroup:oFont:= oFont
	@ 17.44 , 6 		SAY StrZero(Val(SRA->RA_MAT),Len(SRA->RA_MAT))	SIZE 050,10 OF oDlg PIXEL FONT oFont
	@ 17.44 , 51.48		SAY If(lOfuscaNom,Replicate('*',15),OemToAnsi(SRA->RA_NOME)) 	SIZE 146,10 OF oDlg PIXEL FONT oFont


	oGet2 := MSGetDados():New(32,0,152.064,384.12,nOpc,"Gp360Ok2","AlwaysTrue","",If(nOpc=4,Nil,.T.),,1,,300,,,,,oDlg)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar	(oDlg,{|| If(oGet2:TudoOk(),(nGrava:= 1,oDlg:End()),.F.) },;
										   		{|| nGrava:=0,oDlg:End()})
If 	nGrava == 1
	nItem := Ascan(aGrvRC7,{|x| x[6] == nAuxN})
	If nItem == 0
		Aadd(aGrvRC7, {cMat,dDtInicio,dDtFim,aClone(aCols),aHeader, nAuxN, aClone(aColsRec)})
	Else
	    aGrvRC7[nItem][4] 	  := Aclone(aCols)
	EndIf
EndIf

aCols 	:= Aclone(aAuxCols)
aHeader	:= Aclone(aAuxHeader)
n		:= nAuxN

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA360   ºAutor  ³Microsiga           º Data ³  12/20/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fCarAcolsRC7(nOpc,cChave)
Local aSaveArea 	:= GetArea()
Local nPosAgente 	:= 0
Local nPosNomeAg	:= 0

If nOpc <> 4 .And. Len(aCols) = 1 .and. Empty(aCols[1][1])
	nPosAgente 	:= GdFieldPos( "RC7_AGENTE" )
	nPosNomeAg	:= GdFieldPos( "RC7_NOMEAG" )

EndIf

RestArea(aSaveArea)

Return






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gp360Ok2  ³ Autor ³ Andreia dos Santos    ³ Data ³ 27/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de linha ok da getdados2                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GPEA360   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp360Ok2()
Local lRet		:= .T.
Local nX    	:= 1
Local nPosAgen 	:= GdFieldPos( "RC7_AGENTE"  , aHeader )
Local nPosInt 	:= GdFieldPos( "RC7_CONCEN"  , aHeader )
Local nPosCaep  := GdFieldPos( "RC7_CAEPI"   , aHeader )
Local nCont		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a linha esta deletado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[n,len(aHeader)+1]  = .F.

	For nx := 1 To Len(aHeader)
		If Empty(aCols[n,nx])
			If Trim(aHeader[nx,2]) == "RC7_AGENTE" .and. lRet
				AVISO(STR0015,STR0021,{'OK'})  //"Informe o codigo do Agente de Risco"###"Atencao"
				lRet := .F.
				Exit
			Endif
		Endif
	Next nx

	If Empty(aCols[n,nPosInt])
		AVISO(STR0015,STR0042,{'OK'})  //"Atencao"###"Informe a Intensidade."
		lRet := .F.
	Endif

	If Empty(aCols[n,nPosCaep])
		AVISO(STR0015,STR0044,{'OK'})  //"Atencao"###"Informe o numero do C.A. EPI"
		lRet := .F.
	Endif

Endif

For nCont:= 1 to Len(aCols)
	If nCont <> n
		If aCols[nCont,nPosAgen]+aCols[nCont,nPosInt]+aCols[nCont,nPosCaep] == aCols[n,nPosAgen]+aCols[n,nPosInt]+aCols[n,nPosCaep]
			AVISO(STR0015,STR0043,{'OK'})  //"Atencao"###"Já existe este agente e intensidade."
			lRet := .F.
			Exit
		Endif
	Endif
Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³A360DescCPO ºAutor³Andreia dos Santos  º Data ³  26/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Traz a Descricao do codigo em determinado cadastro         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cVar1  = Campo que recebera a descricao( sem o Alias)       º±±
±±º          ³lVar2  = Indica se o campo e visual ou nao                  º±±
±±º          ³cVar3  = Alias da tabela a ser pesquisada                   º±±
±±º          ³cVar4  = Chave de busca                                     º±±
±±º          ³cVar5  = Campo da tabela pesquisada que retornara a descri- º±±
±±º          ³         cao( sem o Alias ).                                º±±
±±º          ³cVar6  = Campo que esta sendo editado.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA360                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION A360DescCpo(cCampo,lVisual,cAlias,cCodigo,cCpoDesc,cCpoEdit )
Local cVar 		:= ""
Local lRet 		:= .F.
Local nBytes
Local nPoscCargo:= GdFieldPos("RC6_CARGO")
Local nPoscCC	:= GdFieldPos("RC6_CC")
Local cCC		:= ""
Local x			:= 1

lVisual := If( lVisual == nil,.F.,lVisual)

If !lVisual
	cVar := &(ReadVar())

	If cAlias =="SQ3"
		If cCpoEdit == "RC6_CC"
			cCC := cVar
		Else
			cCodigo	:= cVar
			cCC 	:= aCols[n][nPoscCC]
		EndIf
		For X := 1 to len(aHeader)

			If Trim(aHeader[x][2]) == cCampo   // campo da descricao
				If SQ3->( dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCodigo+cCC)) .or. SQ3->( dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCodigo))
					lRet 		:= .T.
					aCols[n][x]	:= &(cAlias+"->"+cCpoDesc)
				Endif
	    	EndIf
			If cCpoEdit == "RC6_CC"  .AND. Trim(aHeader[x][2]) == "RC6_DESCCA"
				lRet := .T.
				If SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+aCols[n][nPoscCargo]+cCC))
					aCols[n][x] := SQ3->Q3_DESCSUM
				ElseIf SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+aCols[n][nPoscCargo]+space(nTamCc)))
					aCols[n][x] := SQ3->Q3_DESCSUM
				Else
					aCols[n][x] := ""
				EndIf
			EndIf
	    Next X
	Else
		If (cAlias)->(dbSeek( cFilial + cVar))
			lRet := .T.
			For X := 1 to Len(aHeader)
				If Trim(aHeader[x][2]) == cCampo   // campo da descricao
					aCols[n][x] := &(cAlias+"->"+cCpoDesc)
				Endif
				If cCampo == "RC7_NOMEAG" .AND. Trim(aHeader[x][2]) == "RC7_TIPO"
					aCols[n][x] :=	(cAlias)->TMA_GRISCO
				ElseIf cCampo == "RC6_DESCFU" .AND. Trim(aHeader[x][2]) == "RC6_CARGO"
					aCols[n][x] :=	FDesc("SRJ",cVar,"SRJ->RJ_CARGO",30)
				ElseIf cCampo == "RC6_DESCFU"  .AND. Trim(aHeader[x][2]) == "RC6_DESCCA"
					If SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+aCols[n][nPoscCargo]+aCols[n][nPoscCC]))
						aCols[n][x] := SQ3->Q3_DESCSUM
					ElseIf SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+aCols[n][nPoscCargo]+space(nTamCc)))
						aCols[n][x] := SQ3->Q3_DESCSUM
					Else
						aCols[n][x] := STR0038 //"Nao cadastrado"
					EndIf
				EndIf
			Next x
		Endif
	EndIf
	Return ( lRet )
Else
	nBytes := 20

	If (cAlias)->(dbSeek( cFilial + cCodigo ))
		cRet := Left(&(cAlias+"->"+cCampo)+Space(nBytes),nBytes)
	Else
		cRet := Left(STR0038+Space(nBytes),nBytes)  //"Nao Cadastrado"
	Endif
	Return( cRet )

EndIf


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Gp360Grv   ³ Autor ³ Andreia dos Santos   ³ Data ³ 29/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza os arquivos de RC6 e RC7           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GpeA360   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp360Grv()

Local aAnterior := {}
Local aGetArea	:= GetArea()
Local aRC7Rec	:= {}
Local cCampo	:= ""
Local cChvRC7	:= ""
Local cDtRC7	:= ""
Local cMsgErr	:= ""
Local dAuxDtIn  := ctod("")
Local dAuxDtFi	:= ctod("")
Local dDataIAnt	:= Ctod("")
Local dDataFAnt	:= Ctod("")
Local aAuxRec	:= 0
Local aAuxCols 	:= {}
Local aAuxHeader:= {}
Local lAddRC6	:= .F.
Local lTudoIgual:= .F.
Local nTam 		:= Len(aCols)
Local nPosDtIn  := GdFieldPos("RC6_DATAIN")
Local nPosDtFi  := GdFieldPos("RC6_DATAFI")
Local nItem		:= 0
Local nY		:= 0
Local nx		:= 0
Local nt		:= 0
Local nLenRC7 	:= 0
Local nLenRec	:= 0
Local xConteudo := ""

aAnterior := {}

RC7->( dbSetOrder(1))

dbSelectArea("RC6")
dbSetOrder(1)
If RC6->(dbSeek(xFilial("RC6")+cMat))
	While RC6->(!Eof()) .And. xFilial("RC6")+cMat ==;
		RC6->RC6_FILIAL+RC6->RC6_MAT
		RC6->(Aadd(aAnterior, RecNo()))
		RC6->(dbSkip())
	EndDo
EndIf

For nx:=1 to nTam
    //-- Registros pre-existentes do Pai (RC6)
	If nx <= Len(aAnterior)
		MSGoto(aAnterior[nx])
		lAddRC6		:= .F.
		dDataIAnt	:= RC6->RC6_DATAIN
		dDataFAnt	:= RC6->RC6_DATAFI
	Else
		lAddRC6	:= .T.
		dDataIAnt		:=  aCols[nx][nPosDtIn]
	Endif

	//-- Procura o Filho (RC7)
	nItem := Ascan(aGrvRC7,{|x| x[6] == nX })

	//--Verifica se o Pai esta deletado
	If  aCols[nx][Len(aCols[nx])]

		//-- Se registro pre-existente
		IF !lAddRC6

			//-- Bloqueia registro Pai
			RC6->(RecLock("RC6", .F.))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se estiver deletado, exclui primeiro os registro do RC7 e depois³
			//³exclui os registros do RC6                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        //-- Ja carregou os filhos
	        IF nItem > 0
	        	nLenRec		:= Len( aGrvRC7[nItem][7] )
               //-- Existem registros filhos pre-existentes
               IF nLenRec > 0
	   		        //--Corre todos os filhos registros pre-existentes e deleta-os
					For nY:=nItem To nLenRec
				    	RC7->(MsGoto(aGrvRC7[nItem][7] [nY]))
						//-- Deleta o filho
						RC7->(RecLock("RC7",.F.))
						IF RC7->( !fkDelete( @cMsgErr ) )
							RC7->( RollBackDelTran( cMsgErr ) )
						EndIF
						RC7->(MsUnlock())
					Next nY
               Endif
	        Else
			  	RC7->(	dbSeek(xFilial("RC7") + cMat + dTos( RC6->RC6_DATAIN ) ) )
				cChvRC7 := RC7->RC7_FILIAL + cMAT + dTos( RC7->RC7_DATAIN )
				While RC7->(!Eof()) .And. RC7->( xFilial("RC7")+RC7->RC7_Mat+dTos(RC7->RC7_DATAIN) == cChvRC7 )

					//-- Deleta o filho
					RC7->(RecLock("RC7",.F.))
					IF RC7->( !fkDelete( @cMsgErr ) )
						RC7->( RollBackDelTran( cMsgErr ) )
					EndIF
					RC7->(MsUnlock())
					RC7->(dbSkip())
				Enddo
			Endif

	        //-- Deleta o Pai
			IF RC6->( !fkDelete( @cMsgErr ) )
				RC6->( RollBackDelTran( cMsgErr ) )
			EndIF
			RC6->(MsUnlock())
		Endif
		//-- Nao ha nada para deletar entao obtem o proximo
		Loop
	Endif


	//-- Bloqueia registro Pai
	RC6->(RecLock("RC6", lAddRC6))

	//Para novos registros Acrescenta campos chaves
	IF lAddRC6
		RC6->RC6_FILIAL	:=	xFilial("RC6")
		RC6->RC6_MAT	:=	cMat
	EndIf

	lTudoIgual	:= .T.

	For nt := 1 To Len(aHeader)
		If aHeader[nt][10] # "V"
			cCampo		:= Trim(aHeader[nt][2])
			xConteudo 	:= aCols[nx][nt]
			RC6->( &cCampo ) := xConteudo

			If cCampo == "RC6_DATAIN"
				dAuxDtIn := xConteudo
			ElseIf cCampo == "RC6_DATAFI"
				dAuxDtFi := xConteudo
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se algum campo foi alterado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If NX <= Len(aColsRC6)
				lTudoIgual := If( !lTudoIgual,lTudoIgual,(xConteudo == aColsRC6[nX][nt]))
			Else
				lTudoIgual := .F.
			Endif
		EndIf
	Next nt

	RC6->RC6_ORIGEM := If(lTudoIgual,RC6->RC6_ORIGEM,"I")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se tem algum registro no RC7, e se houver³
	//³atualiza a data inicial e final do periodo.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//-- Se acessou os agentes
	IF  nItem > 0
    	aAuxHeader  := aGrvRC7[nItem][5] 		//Header
   		aAuxCols	:= aGrvRC7[nItem][4] 		//aCols
   		nLenRec		:= Len( aGrvRC7[nItem][7] ) //Array com os numeros dos registros filhos pre-existentes
	    //-- Grava todos os filhos
	    nLenRC7	:= Len(aAuxCols)
        //-- Corre cada um dos filhos
		For nY:=1 To nLenRC7
			lAddRC7	:= .F.
    		IF nY <= nLenRec
			   RC7->( MsGoto( aGrvRC7[nItem][7] [nY]))
			   lAddRC7	:= .F.
			Else
			   lAddRC7	:= .T.
			Endif

	    	//-- Se nao estiver deletado
	    	If ! aAuxCols[ nY, Len( aAuxCols[nY] ) ]

				RC7->(RecLock("RC7", lAddRC7 ))

				If lAddRC7
					RC7->RC7_FILIAL	:=	xFilial("RC7")
					RC7->RC7_MAT	:=	cMat
				Endif

	            For nt := 1 To Len(aAuxHeader)
					If aAuxHeader[nt][10] # "V"
						cCampo	 := Trim(aAuxHeader[nt][2])
						xConteudo:= aAuxCols[nY][nt]
						RC7->( &cCampo ) := xConteudo
					EndIf
				Next nt
				RC7->RC7_DATAIN	:=	dAuxDtIn
				RC7->RC7_DATAFI	:= 	dAuxDtFi

	            RC7->(MsUnlock())
	        Else
	            //-- Pre-existe o filho entao deleta-o
	            IF !lAddRC7
		            //-- Deleta o filho
					RC7->(RecLock("RC7",.F.))
					IF RC7->( !fkDelete( @cMsgErr ) )
						RC7->( RollBackDelTran( cMsgErr ) )
					EndIF
					RC7->(MsUnlock())
	            Endif
	        Endif
		Next nY
	Else
		//-- Obtem os registros pre-existentes pela data original e regrava as datas alteradas
		IF RC7->(dbSeek(xFilial("RC7") + cMat + dTos( dDataIAnt) ) )
			cChvRC7 := RC7->RC7_FILIAL + cMAT + dTos( RC7->RC7_DATAIN )
			//-- Se as datas do periodo foram alteradas regrava-as
			If ( dDataIAnt <> dAuxDtIn ) .or. (dDataFAnt <> dAuxDtFi )
				//-- Como alteramos parte da chave, somente obtemos os numeros de registros para posterior
				//-- alteracao.
				aRC7Rec	:= {}
				While RC7->(!Eof()) .And. RC7->( xFilial("RC7")+RC7->RC7_Mat+dTos(RC7->RC7_DATAIN) == cChvRC7 )
					RC7->(AADD(aRC7Rec, REcno()))
					RC7->(dbSkip())
				Enddo

				//-- Altera campos chaves
				For nt:= 1 to Len(aRC7Rec)
				  	RC7->(MsGoto( aRC7Rec[nt]))

					RC7->(RecLock("RC7",.F.))
					RC7->RC7_DATAIN	:=	dAuxDtIn
					RC7->RC7_DATAFI	:= 	dAuxDtFi

					RC7->(MsUnlock())
				 Next nt
			Endif
		Endif
 	Endif

	RC6->(MsUnlock())

Next nx

RestArea(aGetArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³A360Dele  ºAutor  ³Microsiga           º Data ³  12/17/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclui o Historico do funcionario                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a360Dele()
Local cMat		:= SRA->RA_MAT
Local cChvRC7


RC6->( dbSeek(xFilial()+ cMat))
While RC6->( !EOF()) .and. RC6->RC6_FILIAL+RC6->RC6_MAT == xFilial()+cMat

	RC7->( dbSetOrder(1))
	RC7->(	dbSeek(xFilial("RC7") + cMat ))
	cChvRC7 := RC7->RC7_FILIAL + cMAT
	While RC7->(!Eof()) .And. xFilial("RC7")+RC7->RC7_Mat == cChvRC7
		RecLock("RC7",.F.)
		dbDelete()
		MsUnlock()
		RC7->(dbSkip())
	Enddo

	RecLock("RC6",.F.)
	dbDelete()
	MsUnlock()
	RC6->(dbSkip())
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fOrganiza ºAutor  ³Andreia dos Santos  º Data ³  19/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Organiza o array aGrava em ordem de filial,matricula e dt. º±±
±±º          ³inicial.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA360                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fOrganiza(aGrava)
MsgRun(STR0039,STR0040,{|| Asort( aGrava,,,{|x,y|x[1]+x[2]+dtos(x[3])<y[1]+y[2]+dtos(y[3])})}) //"Organizando Dados"##"Aguarde"

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fPeriodos  ³ Autor ³ Mauricio MR			³ Data ³ 06/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obtem os periodos de laboro para um funcionario			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GpeA360   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fPeriodos(cKeySRA, lcKeySRA)
Local aTransfAll
Local aPeriodos
Local aTemp
Local nX, nY, nPos, nAnt, nProx
Local cChave
Local dAdm
Local dDem
Local nCheck
Local aTransfInc	:= {}


DEFAULT lcKeySRA := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem todas as Transferencias							  	 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fTransf(   @aTransfAll , , .F. , .F. , .F. , .F. , .F. , .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta as transferencias ao um novo formato e para o ano base|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTemp 		:= aClone(aTransfAll)

aTransfAll	:= {}

nX:= 0
nPos:=0
Aeval(aTemp,{|x|;
						AADD(aTransfAll, {;
										   { x[01], x[08], x[03], x[09],'1', ++nX  	}, 	 { Nil, x[07]	}, x[07], Len(aTransfAll)+1	;  	//Emp + Fil + CCusto + Mat "DE"
										};
							),;
						AADD(aTransfAll, {;
										   { x[04], x[10], x[06], x[11], '2', ++nX 	}, 	 { x[07],Nil	}, x[07],	 Len(aTransfAll) ;	//Emp + Fil + CCusto + Mat "PARA"
										};
							);
			 };
	 )

Asort( aTransfAll ,,, { |x,y|    x[1,1] + x[1,2] + x[1,4]  + Dtos( x[3]) + Strzero(x[1,6],4) + x[1,5]  <  y[1,1] + y[1,2]+ y[1,4] + Dtos( y[3]) + Strzero(y[1,6],4) + Y[1,5]  } )  //	//Emp + Fil + Mat + Data Transf
For nCheck:= 1 to (Len(aTransfAll)-1) step 2
	if (aTransfAll[nCheck,3] > aTransfAll[nCheck+1,3])  // Transferência está incoerente.
		AADD(aTransfInc,aTransfAll[nCheck,1,4])
		return
	endif
Next
nX:=1
cChave:=''
aPeriodos:={}
Do While nX <= Len(aTransfAll)

   	cChave:= aTransfAll[nX,1,1] + aTransfAll[nX,1,2] + aTransfAll[nX,1,4]
   	dAdm:= IF(cKeySRA == cChave, SRA->RA_ADMISSA, Ctod(''))
   	dDem:= IF(cKeySRA == cChave, SRA->RA_DEMISSA, Ctod(''))
   	nY:=nX
   	Do While  nY <= Len(aTransfAll)
   	   IF aTransfAll[nY,1,1] + aTransfAll[nY,1,2] + aTransfAll[nY,1,4]  <> cChave
   	      Exit
   	   Endif

		//-- Trata 'DE'
   	   	//-- Se a primeira transferencia for 'DE' e primeiro elemento do array aTransf
   	   	//-- Trata-se da primeira saida do funcionario, logo a data da admissao eh o inicio do primeiro periodo
   	   	IF Empty(aTransfAll[nY,2,1] )
   	   		IF ( aTransfAll[nY,1,6] == 1 )

	   	   	   	aAdd( aPeriodos, { cChave, { dAdm, aTransfAll[nX,2,2]-1 }, aTransfAll[nY,3], ;
	   	   	   										aTransfAll[nY,1,1]	, aTransfAll[nY,1,2],   ;
	   	   	   										 aTransfAll[nY,1,4]	, aTransfAll[nY,1,3],;
	   	   	   										 aTransfAll[nY,4];
	   	   	   		} )
	   	   	Else

	   	   	     //-- Procura pelo 'PARA' correspondente
	   	   	     nAnt:= nY - 1
	   	   	    If 	(nAnt >0 ) .and. ( cChave == aTransfAll[nAnt,1,1] + aTransfAll[nAnt,1,2] + aTransfAll[nAnt,1,4] )

	   	   	        aPeriodos[Len(aPeriodos),2,1]:= aTransfAll[nAnt,2,1]-1
	   	   	        //-- Pula o 'PARA' que foi tratado nessa operacao

	   	   	        nY++
	   	   	    Else
	   	   	    	//-- 'DE' sem 'PARA' correspondente

	   	   	    	Alert('Error')
	   	   	    	nY:= Len(aTransfAll) + 1
	   	   	    	Exit
	   	   	    Endif
	   	   	 Endif
   	   	Else

   	   		//-- Trata 'PARA'
   	   		//-- Se for o ultimo elemento do aTransF nao tem 'DE' correspondente logo a data
   	   		//-- final sera a demissao ou em branco
   	   		IF ( aTransfAll[nY,1,6] ==  Len(aTransfAll))

	   	   	  	aAdd( aPeriodos, { cChave, { aTransfAll[nY,2,1], IF(!Empty(dDem), dDem ,dDem ) },;
	   	   	  										aTransfAll[nY,3]								,;
	   	   	   										aTransfAll[nY,1,1]	, aTransfAll[nY,1,2]		,;
	   	   	   										aTransfAll[nY,1,4]	, aTransfAll[nY,1,3]		,;
	   	   	   										aTransfAll[nY,4];
	   	   	   		} )
	   	   	Else


				aAdd( aPeriodos, { cChave, { aTransfAll[nY,2,1],  }, 	aTransfAll[nY,3]			,;
	   	   	   										aTransfAll[nY,1,1]	, aTransfAll[nY,1,2]		,;
	   	   	   										aTransfAll[nY,1,4]	, aTransfAll[nY,1,3]		,;
	   	   	   										aTransfAll[nY,4];
	   	   	   		} )
	   	   	    //-- Procura pelo 'DE' correspondente
	   	   	    nProx:= nY+1
	   	   	    If	(nProx <= Len(aTransfAll))   .and. ;
	   	   	    	(cChave == aTransfAll[nProx,1,1] + aTransfAll[nProx,1,2] + aTransfAll[nProx,1,4] )
	   	   	        aPeriodos[Len(aPeriodos),2,2]:= aTransfAll[nProx,2,2] -1
	   	   	        //-- Pula o 'DE' que foi tratado nessa operacao
	   	   	        nY++
	   	   	    Else
	   	   	    	//-- 'DE' sem 'PARA' correspondente
		   	   	    Alert('Error')
		   	   	    nY:= Len(aTransfAll) + 1
		   	   	    Exit
	   	   	    Endif

	   	   	Endif
   	   	Endif
   	    nY++
   	End While
   	nX:= nY

 End While

 IF lcKeySRA
    aTemp:=Aclone(aPeriodos)
    aPeriodos:={}
    Aeval(aTemp,{|x| IF(x[1]=cKeySRA, aAdd(aPeriodos,x),Nil) } )
 Endif
 return({aPeriodos, aTransfAll})


 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LeSR7      ³ Autor ³ Mauricio MR			³ Data ³ 08/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega cargos em Funcao dos periodos em o funcionario      ³±±
±±³          ³trabalhou.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GpeA360   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LeSR7(cFilDe, cFilAte, cMatDe, cMatAte, dDataDe, dDataAte, 	cCodCC, aTransfAll, nPosOrig)
Local cAliasSR7 := "SR7"

Local lQuery := .T.
Local cQuery
Local aStru

Local nX
Local cArqNtx	:= ''
Local aCargos   := {}


Local dDataFim	:= Ctod('')
Local dDtPrim	:= Ctod('')
Local cCodFunc 	:= ""
Local cDescFunc	:= ""
Local cCargo	:= ""
Local cDescCargo:= ""

Local cLastFil	:= ""
Local cLastMat	:= ""
Local cLastFun	:= ""
Local cLastDes	:= ""

Local lAtivo    := Empty(dDataAte)
dDataAte	:= If(lAtivo, dDataBase+1, dDataAte )

cAliasSR7 := "SR7"

lQuery := .T.

cAliasSR7 := "QSR7"

cQuery := "SELECT * "
cQuery += "  FROM " + RetSqlName("SR7")
cQuery += " WHERE R7_FILIAL  between '" + cFilDe  + "' AND '" + cFilAte + "'"
cQuery += "   AND R7_MAT     between '" + cMatDe  + "' AND '" + cMatAte + "'"
cQuery += "   AND R7_DATA    between '" + dtos(dDataDe) + "' AND '" + dtos(dDataAte)+ "'"
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY R7_FILIAL, R7_MAT, R7_DATA"

cQuery := ChangeQuery( cQuery )

aStru := SR7->(dbStruct())

If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cAliasSR7,.T.,.T.)
	For nX := 1 To Len(aStru)
		If ( aStru[nX][2] <> "C" )
			TcSetField(cAliasSR7,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
Else
	lQuery := .F.
	cAliasSR7 := "SR7"
	dbSelectArea("SR7")
	SR7->(dbSeek(cFilDe+cMatDe+dTos(dDatade),.T. ))
EndIf

cFim	:= cFilAte

ProcRegua((cAliasSR7)->(RecCount()))

SRE->(dbSetOrder(1) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca no arquivo de historico salarial, as alteracoes de cargo do funcionario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF (cAliasSR7)->(EOF())
    //-- Na ausencia de troca de cargo/funcao para o periodo vale da função antes da transferencia
	lSR7PrimVez(lQuery, @dDataDe, aTransfAll, @cCodFunc, @cDescFunc, @cCargo, @cDescCargo, aCargos, aTransfAll, nPosOrig)
	AADD(aCargos, {;
						cFilDE									,;	//01 - Filial
						cMatDE									,;	//02 - Matricula
						dDatade    							,;	//03 - Data Inicio
						NIL										,; 	//04 - Data Fim
						cCodCC									,;	//05 - Centro de Custo
						cCodFunc								,;	//06 - Codigo da Funcao
						cDescFunc								,;	//07 - Descricao da Funcao
						cCargo									,;	//08 - Codigo do Cargo
						cDescCargo								;	//09 - Descricao do Cargo
					};
		)
Else
	While (cAliasSR7)->(!EOF()) .And. (cAliasSR7)->R7_FILIAL <= cFim

		IncProc(STR0024 + substr(SRA->RA_NOME,1,20)) //"Lendo Historico Salarial: "

		If !lQuery
			If (cAliasSR7)->R7_DATA < dDataDe .or. (cAliasSR7)->R7_DATA > dDataAte
				(cAliasSR7)->(dbSkip())
				Loop
			EndIf

			If (cAliasSR7)->R7_MAT < cMatDe .or. (cAliasSR7)->R7_MAT > cMatAte
				(cAliasSR7)->(dbSkip())
				Loop
			EndIf
		Endif


	   	If !empty((cAliasSR7)->R7_CARGO)
	   		cCargo := (cAliasSR7)->R7_CARGO
	   		If !empty((cAliasSR7)->R7_DESCCAR)
	   			cDescCargo := (cAliasSR7)->R7_DESCCAR
			Else
				If SQ3->( dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo+cCodCC)) .or. SQ3->( dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo))
			 		cDescCargo := SQ3->Q3_DESCSUM
		   		EndIf
	   		EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o Codigo do cargo no SRJ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SRJ->( dbSeek(xFilial('SRJ',SRA->RA_FILIAL)+(cAliasSR7)->R7_FUNCAO))
			cCargo		:= fGetCargo((cAliasSR7)->R7_MAT	, (cAliasSR7)->R7_FILIAL)
			cCargo 		:= If(empty(cCargo),SRJ->RJ_CARGO,cCargo)
			cDescCargo 	:= ""
			If SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo+cCodCC))
				cDescCargo := SQ3->Q3_DESCSUM
			ElseIf SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo+space(nTamCc)))
				cDescCargo := SQ3->Q3_DESCSUM
		   	EndIf
		EndIf

		IF Empty(aCargos)
			AADD(aCargos, {;
								(cAliasSR7)->R7_FILIAL				,;	//01 - Filial
								(cAliasSR7)->R7_MAT					,;	//02 - Matricula
								(cAliasSR7)->R7_DATA				 	,;	//03 - Data Inicio
								NIL										,; 	//04 - Data Fim
								cCodCC									,;	//05 - Centro de Custo
								(cAliasSR7)->R7_FUNCAO				,;	//06 - Codigo da Funcao
								(cAliasSR7)->R7_DESCFUN				,;	//07 - Descricao da Funcao
								cCargo									,;	//08 - Codigo do Cargo
								cDescCargo								;	//09 - Descricao do Cargo
							};
				)
	    Else

	            //-- Finaliza o periodo anterior
	            IF 	Empty(aCargos[Len(aCargos)][4]) .AND. (cAliasSR7)->R7_FUNCAO != aCargos [Len(aCargos)] [6]
	                //-- Assume que o fim do periodo anterior deverá ser 1 dia antes do inicio do periodo corrente.
	                //-- Mas como as vezes o aumento/dissidio nao acompanha alteração de cargo/funcao/c.custo
	                //-- e pode ocorrer mais de um aumento na mesma data, obrigamos que pelo menos a data final para o periodo
	                //-- do aumento seja a data do aumento, de modo a evitar que seja geradas datas finais inferiores a
	                //-- data inicial.

		        	aCargos[Len(aCargos),4] := Max((cAliasSR7)->(Min(R7_DATA -1,dDataAte)) , 	aCargos[Len(aCargos),3])
	           	AADD(aCargos, {;
									(cAliasSR7)->R7_FILIAL					,;	//01 - Filial
									(cAliasSR7)->R7_MAT						,;	//02 - Matricula
									(cAliasSR7)->R7_DATA				 	,;	//03 - Data Inicio
									NIL										,; 	//04 - Data Fim
									cCodCC									,;	//05 - Centro de Custo
									(cAliasSR7)->R7_FUNCAO					,;	//06 - Codigo da Funcao
									(cAliasSR7)->R7_DESCFUN					,;	//07 - Descricao da Funcao
									cCargo									,;	//08 - Codigo do Cargo
									cDescCargo								;	//09 - Descricao do Cargo
								};
					)
				Endif
	    Endif

	    cLastFil	:= (cAliasSR7)->R7_FILIAL
		cLastMat	:= (cAliasSR7)->R7_MAT
		cLastFun	:= (cAliasSR7)->R7_FUNCAO
		cLastDes	:= (cAliasSR7)->R7_DESCFUN

		(cAliasSR7)->( dbSkip())

	EndDo
Endif

If !Empty(aCargos[Len(aCargos)][4]) .And. aCargos[Len(aCargos)][4] <> dDataAte
   	AADD(aCargos, {;
		cLastFil				   				,;	//01 - Filial
		cLastMat					   				,;	//02 - Matricula
		If(aCargos[Len(aCargos)][4]==aCargos[Len(aCargos)][3],aCargos[Len(aCargos)][4],aCargos[Len(aCargos)][4]+1)				 	,;	//03 - Data Inicio
		NIL										,; 	//04 - Data Fim
		cCodCC									,;	//05 - Centro de Custo
		cLastFun									,;	//06 - Codigo da Funcao
		cLastDes				   					,;	//07 - Descricao da Funcao
		cCargo									,;	//08 - Codigo do Cargo
		cDescCargo								;	//09 - Descricao do Cargo
   				};
		)
Endif

IF !Empty(aCargos)
 	//-- Finaliza o periodo anterior
    IF 	Empty(aCargos[Len(aCargos)][4])
        //-- Quando for a transferencia para a ultima posicao do funcionario (ultimo contrato ativo)
        //-- A Data ATE deve ter vindo vazia (nao foi demitido) ou preenchida (foi demitido)
        //-- A data final para o cargo deverá ser a data Até ou a Demissao
	   	If aCargos[Len(aCargos)][3] <> dDataDe
		   	IF lAtivo
		   		aCargos[Len(aCargos)] [4] := Min(dDataAte,SRA->RA_DEMISSA)
		   	Else
		   		aCargos[Len(aCargos)] [4] := dDataAte
		   	Endif
		 Endif
    Endif
Endif

If ( lQuery )
	dbSelectARea(cAliasSR7)
	dbCloseArea()
	dbSelectArea("SR7")
	lQuery := .F.
EndIf

SR7->(RetIndex())

If File(cArqNtx+OrdBagExt())
   FERASE(cArqNtx+OrdBagExt())
Endif
SR7->( dbSetOrder(1))

Return(aCargos)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lSR7PrimVez³ Autor ³ Mauricio MR			³ Data ³ 22/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega cargos/Funcao vigentes antes do inicio do periodo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GpeA360   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static function lSR7PrimVez(lQuery, dDataDe, aTransfAll, cCodFunc, cDescFunc, cCargo, cDescCargo, aCargos, aTransfAll, nPosOrig)
Local aArea		:= GetArea()
Local aSR7Area 	:= SR7->(GetArea())
Local nSR7Recno
Local cChave
Local nPos

Local lRet		:= .T.

IF ( aTransfAll <> Nil )//Primeira Vez
 	//-- Procura pelo elemento de origem do funcionario
 	nPos:= Ascan(aTransfAll,{|x| x[1,5]=='2' .and. x[4] == nPosOrig } )

 	cChave 	:= aTransfAll[nPos,1,2] + aTransfAll[nPos,1,4]
	IF !lQuery
	   nSR7Recno:= (cAliasSR7)->(Recno())
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca no SR7 a funcao que o funcionario exercia no momento da    ³
	//³transferencia. Utiliza a funcao da data mais proxima a data do   ³
	//³SRE.                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//- Procura por historico de Funcao/Cargo
	If SR7->( dbSeek(cChave))
		While SR7->(!EOF()) .and. SR7->R7_DATA  	<= dDataDe					.AND.;
									SR7->R7_FILIAL 	== aTransfAll[nPos,1,2]		.AND. ;
									SR7->R7_MAT   	== aTransfAll[nPos,1,4]
			cCodFunc 	:=	SR7->R7_FUNCAO
			cDescFunc 	:= 	SR7->R7_DESCFUN

			If !empty(SR7->R7_CARGO)
		   		cCargo := SR7->R7_CARGO
   			EndIf
   			cCargo	:=	If(empty(cCargo),fGetCargo(SR7->R7_MAT,	SR7->R7_FILIAL ),cCargo)
   			If !empty(SR7->R7_DESCCAR)
   				cDescCargo := SR7->R7_DESCCAR
   			EndIf
			SR7->(dbSkip())
		EndDo
	Else
	   //-- Se o funcionario nao apresenta historico de alteracao de Cargo/Funcao
	   //-- Assume do SRA
	   nSRARec:=SRA->(Recno())
	   	If SRA->( dbSeek(cChave))
	   	   cCodFunc:=SRA->RA_CODFUNC
	   	Endif
	   	SRA->(DbGoto(nSRARec))
	EndIf

 	If empty( cCargo )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o Codigo do cargo no SRJ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SRJ->( dbSeek(xFilial('SRJ',SRA->RA_FILIAL)+cCodFunc))
		cCargo 		:= SRJ->RJ_CARGO
	EndIf
	If empty(cDescCargo)
		If SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo+aTransfAll[nPos,1,3] ))
			cDescCargo := SQ3->Q3_DESCSUM
		ElseIf SQ3->(dbSeek(xFilial("SQ3",SRA->RA_FILIAL)+cCargo+space(nTamCc)))
			cDescCargo := SQ3->Q3_DESCSUM
 		EndIf
   	EndIf


	If !lQuery
  		(cAliasSR7)->(DbGoto(nSR7Recno))
  	Endif

Else
		IF !(SR7->( dbSeek(xFilial('SR7',SRA->RA_FILIAL)+SRA->RA_MAT)))
 			nSRARec:=SRA->(Recno())
	   	   		cCodFunc:=SRA->RA_CODFUNC
	   	   		SRJ->( dbSeek(xFilial('SRJ',SRA->RA_FILIAL)+cCodFunc))
 		   		cDescFunc:= SRJ->RJ_DESC
 		   		cCargo:=SRA->RA_CARGO
	   	   		SQ3->( dbSeek(xFilial('SQ3',SRA->RA_FILIAL)+cCargo))
		  		cDescCargo := SQ3->Q3_DESCSUM
		  		dDataDe:= SRA->RA_ADMISSA
	   		SRA->(DbGoto(nSRARec))
	    ENDIF
Endif

RestArea(aSR7Area)
RestArea(aArea)

Return (lRet)


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³07/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA360                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local aRotina :=	{	{ STR0001 	, "PesqBrw"		, 0 , 1,,.F.},;  	//"Pesquisar"
						{ STR0002 	, "GP360Gera"	, 0 , 3},;  	//"Gerar Dados"
						{ STR0003	, "GP360Rot"	, 0 , 4},;	 	//"Manutencao"
						{ STR0022	, "GP360Rot"	, 0	, 5},;		//"Excluir
    					{ STR0041   ,"gpLegend"     , 0 , 5 , ,.F.} } //"Legenda"
Return aRotina
