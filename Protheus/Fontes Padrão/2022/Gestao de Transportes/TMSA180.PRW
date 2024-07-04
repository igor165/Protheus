#INCLUDE "Tmsa180.ch"
#include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA180  ³ Autor ³ Patricia A. Salomao   ³ Data ³13.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Coleta automatica                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA180( lTmsJob, lEnd )

Local aAreaAnt	:= GetArea()
Local aAreaDUE	:= {}
Local aDayStr	:= { 'DUE_COLDOM', 'DUE_COLSEG', 'DUE_COLTER', 'DUE_COLQUA', 'DUE_COLQUI', 'DUE_COLSEX', 'DUE_COLSAB' }
Local cCdrOri	:= GetMv('MV_CDRORI')
Local cCondicao := ''
Local cIndDUE	:= ''
Local cSeek		:= ''
Local lRet		:= .F.
Local nIndDUE	:= 0
Local nCntFor	:= 0
Local lNaoGera	:= .F.
Local cFilOld   := cFilAnt
Local cCdrOld  := cCdrOri
Local nSizeFil := 2

//-- Pontos de entrada
Local lTmsA1801 := ExistBlock( 'TMSA1801' )		//-- Permite filtrar os contratos
Local lTm180Fim := ExistBlock( 'TM180FIM' )
Local lTMA180FIL := ExistBlock( 'TMA180FIL' )

Local aContrat  := {}
Local aVetNeg   := {}
Local nCntFor1  := 0
Local nCntCont  := 0
Local cTipFre   := ""
Local aConAux   :={}
Local lPerfil   := .F.
Local nDiaSem   := Dow(dDataBase)
Local cLockName := "DT5" + cFilAnt

Private aPedido:= {}
Private Inclui	:= .T.

DEFAULT lTmsJob:= .F.
DEFAULT lEnd	:= .F.

aHeader := {}
aCols   := {}

If Empty(cCdrOri)
	Help("",1,"TMSA05009")  //-- O Parametro MV_CDRORI esta vazio
	Return .F.
EndIf
cCondicao += 'DUE_FILIAL == "'+xFilial("DUE")+'" .And. '
cCondicao += '!Empty(DUE_CODCLI) .And. !Empty(DUE_LOJCLI) .And. '
cCondicao += 'DUE_TIPCOL == "2"'

If	lTmsA1801
	cCondicao := ExecBlock('TMSA1801',.F.,.F.,cCondicao)
EndIf

DbSelectArea('DUE')
DbSetOrder( 1 )
cIndDUE := CriaTrab( Nil, .F. )
IndRegua('DUE', cIndDUE, IndexKey(), , cCondicao,STR0001 , !lTmsJob )  //'Selecionando Registros...'
nIndDUE := RetIndex('DUE')
DbSetOrder( nIndDUE + 1 )

If !lTmsJob
	ProcRegua( DUE->( RecCount() ) )
EndIf

aHeader := ApBuildHeader("DUM")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria a Trava com o Nome 'DT5'. Se algum usuario estiver incluindo Tabelas de     ³
//³ Coleta automatica, a rotina de 'Gera Coleta automatica' nao podera ser executada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LockByName(cLockName,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a rotina de 'Gera Coleta automatica' estiver sendo executada, nao sera permitida  ³
//³ a inclusao Coleta automatica                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LockByName(cLockName,.T.,.F.)
	Help("",1,"TMSA18001") //--A Inclusao de Coleta automatica nao podera ser efetuada, pois existe outro usuario gerando Coleta automatica
	UnLockByName(cLockName,.T.,.F.) //-- Libera Lock
	Return( .F. )
EndIf

DUE->( DbGoTop() )
While	DUE->( ! Eof() .And. ! lEnd )

	If lTMA180FIL
		nSizeFil := FWSizeFilial()

		cRetPE:= ExecBlock('TMA180FIL',.F.,.F.,DUE->DUE_CDRSOL)
		If !Empty(cRetPE) .And. Valtype(cRetPE) == "C"
			cFilAnt:= Substr(cRetPE,1,nSizeFil)

			If Len(AllTrim(cRetPE)) > nSizeFil
				cCdrOri:= Substr(cRetPE ,(nSizeFil+1),Len(DUE->DUE_CDRSOL))
			EndIf
		EndIf
	EndIf

	If !lTmsJob
		IncProc()
	EndIf

	//-- Nao permite incluir mais de uma Coleta por dia do mesmo solicitante
	//-- Mapa do vetor aVetNeg
	//-- 01 - Contrato
	//-- 02 - Codigo da Negociacao
	//-- 03 - Servico
	aConAux:= {}
	lPerfil:= .F.
    aVetNeg := {}
    For nCntCont := 0 to 2	// utilizado para verificar os 3 tipos de contrato do cliente: cif/fob; cif e fob
        aContrat := TMSContrat(DUE->DUE_CODCLI, DUE->DUE_LOJCLI,,,,cTipFre,,,,,,,,,,,,,,,,)
        If !Empty(aContrat)
            DDA->(DbSetOrder(1))
            DDA->(DbSeek(xFilial("DDA") + aContrat[1,1]))
            While DDA->(!Eof()) .And. DDA->DDA_NCONTR == aContrat[1,1]
                If !Empty(SubStr(DDA->DDA_DIACOL,nDiaSem,1))
                    Aadd(aVetNeg,{aContrat[1,1],DDA->DDA_CODNEG,DDA->DDA_SERVIC})
                Else
                    if DUE->&(aDayStr[Dow(dDatabase)]) == '1'
                        Aadd(aConAux,{aContrat[1,1],"",""})
                    EndIf
                endIf

                DDA->(DbSkip())
            EndDo
        Else
            Aadd(aVetNeg,{"","",""})
        EndIf
        cTipFre := cValtoChar( nCntCont )
    Next nCntCont

    If Len(aVetNeg) == 0 .And. Len(aConAux) > 0

        aVetNeg := aConAux

        lPerfil:= .T.

    endif

	For nCntFor1 := 1 To Len(aVetNeg)
		lNaoGera := .F.
		DT5->(dbSetOrder(2))
		if !lPerfil
			If DT5->(dbSeek(xFilial("DT5")+DUE->DUE_CODSOL+DTOS(dDataBase)+aVetNeg[nCntFor1,2]+aVetNeg[nCntFor1,3] ))
				Do While !Eof() .And. DT5->(DT5_FILIAL+DT5_CODSOL+DTOS(DT5_DATSOL) ) + DT5->(DT5_CODNEG + DT5_SERVIC) == ;
						DUE->(xFilial('DT5')+DUE_CODSOL+DTOS(dDataBase) ) + aVetNeg[nCntFor1,2] + aVetNeg[nCntFor1,3]
				    If DT5->DT5_STATUS == '9'
				       DT5->(dbSkip())
			    	   Loop
				    EndIf
				    lNaoGera := .T.
				    Exit
				EndDo
			EndIf
		else
			If DT5->(dbSeek(xFilial("DT5")+DUE->DUE_CODSOL+DTOS(dDataBase) ))
				Do While !Eof() .And. DT5->(DT5_FILIAL+DT5_CODSOL+DTOS(DT5_DATSOL) ) == ;
						DUE->(xFilial('DT5')+DUE_CODSOL+DTOS(dDataBase) )
				    If DT5->DT5_STATUS == '9'
				       DT5->(dbSkip())
			    	   Loop
				    EndIf
				    lNaoGera := .T.
				    Exit
				EndDo
			EndIf
		endif

		If !lNaoGera .AND. !Empty(aVetNeg[nCntFor1,1])
			lRet := .T.

			aAreaDUE := DUE->( GetArea() )

			//-- Grava status da solicitacao de frete
			RegToMemory('DT5',.T.)

			RestArea( aAreaDUE )

			If !(TMSA460PrvCol()) // Calcula a data/hora de previsao de coleta.
				Exit
			EndIf

			M->DT5_TIPCOL 	:= StrZero( 2, Len( DUE->DUE_TIPCOL ) )
			M->DT5_DDD	  	:= DUE->DUE_DDD
			M->DT5_TEL		:= DUE->DUE_TEL
			M->DT5_CODSOL	:= DUE->DUE_CODSOL
			M->DT5_CDRORI 	:= cCdrOri
			M->DT5_TIPTRA 	:= DUE->DUE_TIPTRA
			M->DT5_NCONTR := aVetNeg[nCntFor1,1]
			M->DT5_CODNEG := aVetNeg[nCntFor1,2]
			M->DT5_SERVIC := aVetNeg[nCntFor1,3]
			M->DT5_TIPFRE := "1"
			M->DT5_CLIDEV := DUE->DUE_CODCLI
			M->DT5_LOJDEV := DUE->DUE_LOJCLI

			aCols	:= {}
			DVJ->(DbSetOrder(1))
			DVJ->(MsSeek(cSeek := xFilial('DVJ')+DUE->DUE_CODSOL))
			While DVJ->( ! Eof() .And. DVJ->DVJ_FILIAL+DVJ->DVJ_CODSOL == cSeek )
				//-- Inserir uma linha em branco no aCols
				AAdd(aCols,Array(Len(aHeader)+1))
				For nCntFor := 1 To Len(aHeader)
					aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
				Next
				aCols[Len(aCols),Len(aHeader)+1] := .F.
				//-- Inserir no aCols os Produtos informados no Cadastro de Solicitantes
				GdFieldPut('DUM_ITEM'	,StrZero(Len(aCols),Len(DUM->DUM_ITEM)),Len(aCols))
				GdFieldPut('DUM_CODPRO'	,DVJ->DVJ_CODPRO,Len(aCols))
				GdFieldPut('DUM_CODEMB'	,DVJ->DVJ_CODEMB,Len(aCols))
				DVJ->(dbSkip())
			EndDo

			//-- Rotina de gravacao da solicitacao de coleta.
			TmsA460Grava( 3, .T. )

			RestArea( aAreaDUE )
		EndIf
	Next nCntFor1

	If lTMA180FIL
		cFilAnt := cFilOld
		cCdrOri := cCdrOld
	EndIf

	DUE->( DbSkip() )
EndDo

If lTMA180FIL
	cFilAnt := cFilOld
	cCdrOri := cCdrOld
EndIf

If	File( cIndDUE + OrdBagExt() )
	DbSelectArea('DUE')
	DbClearFilter()
	Ferase( cIndDUE + OrdBagExt() )
EndIf
RetIndex('DUE')

If	lTmsJob
	If	lRet
		TMSLogMsg(, STR0002) //'Ordens de Coleta geradas com sucesso ...'
	Else
		TMSLogMsg(, STR0003) //'Nao foi gerada nenhuma Ordem de Coleta ...'
	EndIf
Else
	If	lRet
		Aviso( STR0004,STR0002,{'Ok'})  //'Atencao'###'Ordens de Coleta geradas com sucesso ...'
	Else
		Aviso( STR0004,STR0003,{'Ok'})
		//Aviso( STR0004,STR0009 + STR0010,{'Ok'}) //"A partir da versão / release 12.1.17 a geração de solicitação de coletas automáticas deve ser configurada no contrato do cliente, permitindo realizar programações diferentes, por serviços."
	EndIf
EndIf

If lTm180Fim
	ExecBlock('TM180FIM',.F.,.F.)
EndIf

UnLockByName(cLockName,.T.,.F.) //-- Libera Lock
RestArea( aAreaAnt )
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA180A ³ Autor ³Patricia A. Salomao    ³ Data ³13.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Coleta automatica - Chamado do menu do sistema TMS         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA180A()

Local aSays			:= {}
Local aButtons		:= {}
Local lRet			:= .T.

Private cCadastro	:= STR0005 //'Coleta Automatica'

Aadd( aSays, STR0006 )  //'Este programa tem como objetivo, gerar ordens de coleta baseando-se no Tipo de'
Aadd( aSays, STR0007 )  //'Coleta e nos dias informados na pasta ( Coleta ) no cadastro de Solicitantes.'

Aadd( aButtons, { 1, .T., {|o| lRet := TmsA180Prc(), o:oWnd:End() } } )
Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )

FormBatch( cCadastro, aSays, aButtons )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA180Prc³ Autor ³ Patricia A. Salomao   ³ Data ³13.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o processamento da rotina                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA180Prc()

Local lRet	:= .T.

Processa( {|lEnd| lRet := TmsA180( .F., @lEnd ) }, cCadastro, STR0008 , .T. )  //'Aguarde...'

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA180B ³ Autor ³ Patricia A. Salomao   ³ Data ³13.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Coleta automatica - Chamado via JOB                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA180B()

Return( TmsA180( .T. ) )
