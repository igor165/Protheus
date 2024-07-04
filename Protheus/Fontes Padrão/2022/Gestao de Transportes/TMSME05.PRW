#Include "TMSME05.CH"   
#Include "PROTHEUS.CH"

#define CRLF Chr(13)+Chr(10)
#define I_SEQUEN    01
#define I_TIPO      02
#define I_CAMPO     03
#define I_LAYTAM    04
#define I_LAYDEC    05
#define I_POSICI    06
#define I_ALIAS     07
#define I_POSORD    08
#define I_POSCHV    09
#define I_REGRA     10
#define I_VALIDA    11
#define CP_ALIAS    01
#define CP_POSICI   02
#define CP_POSORD   03
#define CP_POSCHV   04
#define CP_COND     05
#define CP_OCOREG   06
#define CP_VALID    07
#define CP_I_ALIAS  01
#define CP_I_POSICI 02
#define CP_I_POSORD 03
#define CP_I_POSCHV 04
#define CP_I_REGRA  05
#define CP_I_CAMPO  06
#define CP_I_LAYTAM 07
#define CP_I_LAYDEC 08
#define CP_I_VALID  09

Static __aLayout 	:= {}
Static __aLayCp  	:= {}

Static lTMSEDIDOC 	:= ExistBlock("TMSEDIDOC")
Static lTMSEDIFIN 	:= ExistBlock("TMSEDIFIN")
Static lTMSEDIOCO 	:= ExistBlock("TMSEDIOCO")
Static lTMSEDIMAN 	:= ExistBlock("TMSEDIMAN")
Static lTMSEDIOTP 	:= ExistBlock("TMSEDIOTP")
Static lJobEDI05	:= IsBlind()   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSME05  ³ Autor ³ Eduardo de Souza      ³ Data ³ 23/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ EDI - Exportacao                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME05()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES - VIDE SOURCE SAFE                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSME05(nTipEnv,lPreFat)

Local cPerg      := ""
Local cIndex     := ""
Local cFiltro    := ""
Local cArqInd    := CriaTrab(,.F.)
Local cNomArq    := ""
Local aAreaDEC   := DEC->(GetArea())
Local cEdiSeqAnt := ""
Local lTME05GRV  := ExistBlock("TME05GRV")
Local lTME05PRC  := ExistBlock("TME05PRC")
Local lTMSEDIDR  := ExistBlock("TMSEDIDR")
Local lTMSME0501 := ExistBlock("TMSME0501")
Local lTME05FIM  := ExistBlock("TME05FIM")
Local lRet       := .F.
Local lAtivo     := .T.
Local lPerg      := .T.
Local cDirPE     := ""
Local cCadastro  := ""

Default lPreFat := .F.

Private lMsErroAuto  := .F.
Private cDirEnv      := GetMv("MV_EDIDIRE")
Private __cEDISeqArq := ""
Private __nEDISeqLin := 0
Private __nEDISeq    := 0
Private __aEDIEnv    := {}

If lJobEDI05
	If Empty(cDirEnv)				
		If !ExistDir(CurDir() + "EDI\")     
			MakeDir(CurDir() + "EDI\")
		EndIf
		cDirEnv := CurDir() + "EDI\"
	EndIf
Else
	cPerg := TMSME05PER(nTipEnv, @cCadastro)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica/Inclui barra no final do diretorio.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Right(cDirEnv,1) # "\"
	cDirEnv += "\"
EndIf

If lJobEDI05
	TMSLogMsg(,">> "+FunName()+" - "+cCadastro+" - Filial "+cFilAnt+" - "+Dtoc(Date())+" "+Time())
	TMSLogMsg(,cPerg)
ElseIf lPreFat
	Pergunte(cPerg,.F.)	
Else
	lPerg := Pergunte(cPerg,lPerg)	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPerg

	DbSelectArea("DEC")
	DbSetOrder(1) //DEC_FILIAL+DEC_CODCLI+DEC_LOJCLI

	cIndex	:= DEC->(IndexKey())

	cFiltro := 'DEC_FILIAL == "' + xFilial("DEC") + '" .And. '
	cFiltro += 'DEC_CODCLI + DEC_LOJCLI >= "' + mv_par01 + mv_par02 + '" .And. '
	cFiltro += 'DEC_CODCLI + DEC_LOJCLI <= "' + mv_par03 + mv_par04 + '" .And. '
	cFiltro += 'DEC_TIPENV == "' + AllTrim(Str(nTipEnv)) + '"'
	
	IndRegua("DEC",cArqInd,cIndex,,cFiltro,STR0006) //"Selecionando Registros..."
	
	DEC->(MsSeek(xFilial("DEC")))
	While DEC->(!Eof())	

		//-- Verifica se o Layout esta ativo
		lAtivo := .T.
		If DEC->DEC_STATUS <> "1" // Ativo
			lAtivo := .F.
		EndIf

		If lAtivo
			//-- Permite alterar diretorio onde serao gerados os arquivos de exportacao.
			If lTMSEDIDR
				cDirPE:= AllTrim(ExecBlock("TMSEDIDR",.F.,.F.,{DEC->DEC_CODCLI, DEC->DEC_LOJCLI, DEC->DEC_CODLAY}))
				If ValType(cDirPE) == "C" .And. !Empty(cDirPE) 
					cDirEnv:= cDirPE
				EndIf
			EndIf

			//-- sequencia do arquivo
			cEdiSeqAnt   := DEC->DEC_SEQARQ
			__cEDISeqArq := Soma1(DEC->DEC_SEQARQ)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida se o nome do Arquivo eh valido.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TMSME05Mac(DEC->DEC_NOMARQ,@cNomArq)

				//-- Ponto de Entrada antes da execucao do processamento.
				If lTME05GRV 
					ExecBlock("TME05GRV",.F.,.F.,{cNomArq})
				EndIf

				__nEDISeqLin := 1
				cNomArq      := Alltrim(cNomArq)

				If lJobEDI05
					BatchProcess(cCadastro, "" , "TMSME05" , { || lRet:= TMSME05Proc(DEC->DEC_CODLAY,cNomArq) } ) 
				Else
					Processa({|| lRet:= TMSME05Proc(DEC->DEC_CODLAY,cNomArq)})
				EndIf

				If lRet
					//-- Atualiza a Sequencia
					RecLock("DEC",.F.)
					DEC->DEC_SEQARQ := __cEDISeqArq
					MsUnlock()

					//-- Ponto de Entrada utilizado para atualizacao de dados apartir do DEC
					If lTMSME0501
						ExecBlock("TMSME0501",.F.,.F.)
					EndIf

				Else
					//-- Volta a Sequencia Anterior
					RecLock("DEC",.F.)
					DEC->DEC_SEQARQ := cEDISeqAnt
					MsUnlock()
				EndIf
			EndIf	
			
			//--Ponto de entrada após a geração do arquivo de EDI.
			If lTME05PRC
				ExecBlock("TME05PRC",.F.,.F.,{lRet,cDirEnv,cNomArq,DEC->DEC_CODCLI,DEC->DEC_LOJCLI,DEC->DEC_CODLAY,cPerg})
			EndIf
		EndIf
		DEC->(DbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga o Arquivo de Trabalho.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqInd += OrDbagExt()
	Delete File &(cArqInd)

	RetIndex ( "DEC" )
	RestArea ( aAreaDEC )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apresenta o Log na Tela.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMSErroAuto
		MostraErro(Iif(lJobEDI05,cDirEnv,))
	EndIf

EndIf

If lJobEDI05
	TMSLogMsg(,"<< "+FunName()+" - "+cCadastro+" - Filial "+cFilAnt+" - "+Dtoc(Date())+" "+Time())
EndIf

//Ponto de entrada no final da geração dos arquivos
If lTME05FIM
	ExecBlock("TME05FIM",.F.,.F.,{nTipEnv})
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSME05Proc³ Autor ³ Eduardo de Souza     ³ Data ³ 23/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exportacao para arquivos TXT                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME05Proc()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME05()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSME05Proc(cCodLay,cNomArq)

Local nCnt
Local aAreaDE0   := DE0->(GetArea())
Local aArea      := {}
Local aGrvLog    := {}
Local aAtuDatEdi := {}

Private nHand      := 0
Private cOldNArq   := ""
Private aCabecAnt  := {}
Private lApagaTxt  := .F.
Private lGrvLinTxt := .T.
Private cRegPrinc  := ""
Private lGrvLog    := GetMv("MV_EDILOG")
Private aPosCompl  := {}

DbSelectArea("DE0")
DbSetOrder(2) //DE0_FILIAL+DE0_CODLAY+DE0_IDTREG

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga Todos arquivos Textos referente ao Layout.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSME05Del(cCodLay,cNomArq)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Texto.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(LastRec())
MsSeek(xFilial("DE0")+cCodLay)
While DE0->(!Eof()) .And. !lApagaTxt .And. DE0->DE0_FILIAL + DE0->DE0_CODLAY == xFilial("DE0") + cCodLay

	aArea := DE0->(GetArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o registro eh Complemento (Filho).       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("DE0")
	DbSetOrder(4) //DE0_FILIAL+DE0_CODLAY+DE0_CODRCP
	If !MsSeek(xFilial("DE0")+cCodLay+DE0->DE0_CODREG)
		RestArea(aArea)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se faz parte dos registros complementares.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("DE8")
		DbSetOrder(2) //DE8_FILIAL+DE8_CODLAY+DE8_CODRCP+DE8_CODREG
		If MsSeek(xFilial("DE8")+DE0->DE0_CODLAY+DE0->DE0_CODREG)
			RestArea(aArea)
			DbSelectArea("DE0")
		    DbSkip()
		    Loop
		 EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Arquivo de Exportacao.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TMSME05Atu(cCodLay,DE0->DE0_CODREG,cNomArq,@aGrvLog,@aAtuDatEdi)
	EndIf

	RestArea(aArea)
	DbSelectArea("DE0")
	DbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza Arquivo Texto.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FClose(nHand)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga Todos arquivos Textos referente ao Layout.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApagaTxt
	TMSME05Del(cCodLay,cNomArq)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Data da geracao do arquvio de Exportacao.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCnt:= 1 To Len(aAtuDatEdi)

		cAlias := aAtuDatEdi[nCnt,1] // Alias do Registro
		(cAlias)->(DbGoto(aAtuDatEdi[nCnt,2])) // Posiciona no Registro para atualizacao da data de geracao

		RecLock(cAlias,.F.,.T.)
		&(aAtuDatEdi[nCnt,3]) := dDataBase
		MsUnlock()

	Next nCnt

	If lGrvLog
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Log de Exportacao.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TMSME05Log(aGrvLog)
	EndIf

EndIf

RestArea ( aAreaDE0 )

Return !lApagaTxt

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSME05Atu ³ Autor ³ Eduardo de Souza     ³ Data ³ 23/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza Arquivo de Exportacao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME05Atu()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSME05Atu(cCodLay,cCodReg,cNomArq,aGrvLog,aAtuDatEdi)

Local nReg      := 0
Local cAlias    := ""
Local cAlias2   := ""
Local lWhile    := .F.
Local cArqInd   := ""
Local cCond     := ""
Local aArea     := {}
Local aAreaDE0  := DE0->(GetArea())
Local aAreaDE8  := DE8->(GetArea())
Local nOcorren  := 0
Local lAtuDados := .F.
Local lValid    := .F.
Local lPula     := .T.
Local nCnt      := 0
Local cQuery    := ""

Local lQuery    := .F.
Local nRecno    := 0

Local lTMSQRY := ExistBlock("TME05QRY")
Local cQryAux := ""

Private __lEDIContCp := .F.
Private cAliasTRB := ""

While DE0->(!Eof()) .And. !lApagaTxt .And. DE0->DE0_FILIAL + DE0->DE0_CODLAY + DE0->DE0_CODREG == xFilial("DE0") + cCodLay + cCodReg

	IncProc()
	If DE0->DE0_STATUS == "1" //-- Ativo

		aArea  := {}
		nReg   := DE0->(Recno())
		cAlias := DE0->DE0_ALIAS
		lQuery := .F.

		If !Empty(cAlias)
			cAliasTRB := cAlias
			cQuery := StrTran(MsMM(DE0->DE0_CODQRY),chr(13)+chr(10)," ")
			if lTMSQRY
				cQryAux := ExecBlock("TME05QRY",.F.,.F.,cQuery)
				if !Empty(cQryAux) .AND. !Empty(cQuery)
					cQuery += " "+cQryAux
				endif
			endif
			//-- Verifica se foi preenchido o campo referente a query
			If !Empty(cQuery)
				lQuery := .T.
				If TMSME05Mac(cQuery,@cQuery)
					cQuery    := ChangeQuery(cQuery)
					cAliasTRB := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
					lWhile := (cAliasTRB)->(!Eof())
				Else
					//-- "Existe problema na query"
					AutoGRLog(cNomArq + " - " + STR0014 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Existe problema na query"
					lApagaTxt := .T.
					Exit
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida Alias                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lQuery
				aArea := (cAlias)->(GetArea())	
				cCond := DE0->DE0_COND
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no Registro.                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If DE0->DE0_POSICI == "1"
					DbSelectArea(cAlias)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se Existe a Ordem Selecionada.              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(IndexKey(Val(DE0->DE0_POSORD)))
						DbSetOrder(Val(DE0->DE0_POSORD))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se a chave esta preenchida.                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(AllTrim(DE0->DE0_POSCHV))
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Valida Chave                                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If TMSME05Mac(AllTrim(DE0->DE0_POSCHV))
								MsSeek(&(AllTrim(DE0->DE0_POSCHV)))
								lWhile := .T.
							EndIf
						EndIf
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta IndeRegua e Verifica se Existem Dados no Arquivo. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lWhile:= TMSME05Arq(cAlias,@cArqInd,cCond)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existem dados para gerar o arquivo texto.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cRegPrinc)
				cRegPrinc := DE0->DE0_CODREG
				If !lWhile
					lApagaTxt := .T.
				EndIf
			EndIf
		EndIf

		If lWhile
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso nao exista condicao ou query, Inicializa com True.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lQuery .Or. Empty(cCond)
				cCond := ".T."
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida Condicao                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TMSME05Mac(cCond)

				nOcorren:= 0

				If At("S",Upper(cAlias)) == 1 
					cAlias2	:= SUBSTR(cAlias,2) //-- Atribui a variavel cAlias2 o conteúdo "E1" ao invés de "SE1", pois é necessário para buscar os campos
				Else
					cAlias2 := cAlias
				EndIf

				DbSelectArea(cAliasTRB)
				While (cAliasTRB)->(!Eof()) .And. &(cCond) .And. !lApagaTxt

					IncProc()

					If !lQuery
						nRecno := (cAliasTRB)->(Recno())
						lValid := .F.
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se o campo estiver preenchido, valida os registros.  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(AllTrim(DE0->DE0_VALID))
							If !TMSME05Mac(AllTrim(DE0->DE0_VALID),@lValid)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Existe problema na Validacao do campo                ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								AutoGRLog(cNomArq + " - " + STR0012 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Existe problema na validacao configurado para o registro"
								lApagaTxt := .T.
								Loop
							EndIf
						Else
							lValid := .T.
						EndIf

						If !lValid
							DbSelectArea(cAliasTRB)
							DbSkip()
							Loop
						EndIf
					Else
						nRecno := (cAliasTRB)->R_E_C_N_O_
						(cAlias)->(DbGoto(nRecno))
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se o campo estiver preenchido, valida os registros.  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(AllTrim(DE0->DE0_VALID))
							If !TMSME05Mac(AllTrim(DE0->DE0_VALID),@lValid)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Existe problema na Validacao do campo                ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								AutoGRLog(cNomArq + " - " + STR0012 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Existe problema na validacao configurado para o registro"
								lApagaTxt := .T.
								Loop
							EndIf
						Else
							lValid := .T.
						EndIf

						If !lValid
							DbSelectArea(cAliasTRB)
							DbSkip()
							Loop
						EndIf
					EndIf

					lAtuDados:= .T.

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existe Quebra no Layout                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If DE0->DE0_OCOREG <> 0 .And. DE0->DE0_OCOREG == nOcorren

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica em qual arquivo sera gravado o layout.      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(DE0->DE0_NOMARQ) .And. AllTrim(DE0->DE0_NOMARQ) <> aCabecAnt[1]
							If nHand > 0
								FClose(nHand)
							EndIf
							If File(aCabecAnt[1])
								nHand:= FOpen(aCabecAnt[1],2) //-- Abre Arquivo
								FSeek(nHand,0,2)
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava no Arquivo Texto.                              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						fWrite(nHand,aCabecAnt[2])
						nOcorren:= -1
					EndIf

					nOcorren++ // Armazena o numero de ocorrencias, utilizado para quebra do layout.

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza Layout.                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If TMSME05Lay(@cNomArq)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso seja o Registro Principal, Atualiza Dados.      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cRegPrinc == DE0->DE0_CODREG

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso existir o campo Data de geracao do EDI, informa ³
							//³ a geracao do EDI para o registro principal.          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasTRB)->(FieldPos(cAlias2+"_DATEDI")) > 0
								If Empty(&(cAliasTRB+"->"+cAlias2+"_DATEDI"))
									Aadd(aAtuDatEdi,{ cAlias, nRecno, (cAlias+"->"+cAlias2+"_DATEDI") })
								EndIf
							ElseIf (cAliasTRB)->(FieldPos(cAlias2+"_DATAEDI")) > 0
								If Empty(&(cAliasTRB+"->"+cAlias2+"_DATAEDI"))
									Aadd(aAtuDatEdi,{ cAlias, nRecno, (cAlias+"->"+cAlias2+"_DATAEDI") })
								EndIf
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Armazena Log de Exportacao no Array                  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lGrvLog
								If aScan(aGrvLog, { |x| x[1] + x[2] + x[3] + AllTrim(Str(x[6])) == DEC->DEC_CODCLI + DEC->DEC_LOJCLI + DEC->DEC_CODLAY + AllTrim(Str(nRecno)) } ) == 0
									Aadd(aGrvLog,{DEC->DEC_CODCLI,DEC->DEC_LOJCLI,DEC->DEC_CODLAY,Left(StrTran(Time(),":",""),4),cAlias,nRecno})
								EndIf
							EndIf

						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se Continuacao do Complemento, nao pula para o prox. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						__lEDIContCp := .F.
						If Len(aPosCompl) > 0
							For nCnt := 1 To Len(aPosCompl)
								If aPosCompl[nCnt,3] > 0
									lPula := .F.
									__lEDIContCp := .T.
									Exit
								EndIf
							Next nCnt
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe composicao de registro (Filho).   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("DE0")
						DbSetOrder(1)
						If MsSeek(xFilial("DE0")+DE0->DE0_CODLAY+DE0->DE0_CODRCP)
							TMSME05Atu(cCodLay,DE0->DE0_CODREG,cNomArq,@aGrvLog,@aAtuDatEdi)
						EndIf
						DE0->(DbGoto(nReg))

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe registro complementares           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("DE8")
						DbSetOrder(1)
						If MsSeek(xFilial("DE8")+DE0->DE0_CODLAY+DE0->DE0_CODREG)
							While DE8->(!Eof()) .And. DE8->DE8_FILIAL + DE8->DE8_CODLAY + DE8->DE8_CODREG == xFilial("DE8") + DE0->DE0_CODLAY + DE0->DE0_CODREG
								DbSelectArea("DE0")
								DbSetOrder(1)
								If MsSeek(xFilial("DE0")+DE0->DE0_CODLAY+DE8->DE8_CODRCP)
									TMSME05Atu(cCodLay,DE0->DE0_CODREG,cNomArq,@aGrvLog,@aAtuDatEdi)
								EndIf
								DE0->(DbGoto(nReg))
								DE8->(DbSkip())
							EndDo
						EndIf
					EndIf

					If lPula
						DbSelectArea(cAliasTRB)
						DbSkip()
					EndIf
					lPula := .T.
				EndDo
				aPosCompl := {}
			EndIf
			If !lAtuDados .And. cRegPrinc == DE0->DE0_CODREG
				lApagaTxt:= .T.
			EndIf
			lWhile      := .F.
			__lEDIContCp:= .F.
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Layout.                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TMSME05Lay(@cNomArq)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe composicao de registro (Filho).   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("DE0")
				DbSetOrder(1)
				If MsSeek(xFilial("DE0")+DE0->DE0_CODLAY+DE0->DE0_CODRCP)
					TMSME05Atu(cCodLay,DE0->DE0_CODREG,cNomArq,@aGrvLog,@aAtuDatEdi)
				EndIf
				DE0->(DbGoto(nReg))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe registro complementares           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("DE8")
				DbSetOrder(1)
				If MsSeek(xFilial("DE8")+DE0->DE0_CODLAY+DE0->DE0_CODREG)
					While DE8->(!Eof()) .And. DE8->DE8_FILIAL + DE8->DE8_CODLAY + DE8->DE8_CODREG == xFilial("DE8") + DE0->DE0_CODLAY + DE0->DE0_CODREG
						DbSelectArea("DE0")
						DbSetOrder(1)
						If MsSeek(xFilial("DE0")+DE0->DE0_CODLAY+DE8->DE8_CODRCP)
							TMSME05Atu(cCodLay,DE0->DE0_CODREG,cNomArq,@aGrvLog,@aAtuDatEdi)
						EndIf
						DE8->(DbSkip())
					EndDo
				EndIf
				DE0->(DbGoto(nReg))
			EndIf

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga o Arquivo de Trabalho.                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQuery
			If ChkFile(cAliasTRB)
				(cAliasTRB)->(DbCloseArea())
			EndIf
		EndIf

		If !Empty(cAlias)
			If AliasInDic(cAlias)
				cArqInd += OrDbagExt()
				Delete File &(cArqInd)
				//-- Restaura a Area
				If Len(aArea) > 0
					RestArea( aArea  )
				EndIf
				//-- Restaura Indice
				If cAlias <> "SM0"
					RetIndex( cAlias )
				EndIf
			EndIf
		EndIf
	EndIf

	DbSelectArea("DE0")
	DbSetOrder(2)
	DE0->(DbSkip())

EndDo

RestArea (aAreaDE0)
RestArea (aAreaDE8)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSME05Lay³ Autor ³ Eduardo de Souza      ³ Data ³ 16/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza arquivo de exportacao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME05Lay()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSME05Lay(cNomArq)

Local nCnt
Local lValid    := .T.
Local cRegra    := ""
Local cLinTxt   := ""  
Local nOcorren  := 0
Local aArea     := {}
Local cCond     := ""
Local lValidDED := .T.
Local cAlias    := ""
Local nGoto     := 0
Local cPict     := ""
Local cQuery    := ""
Local cAliasTRB := "DE1"
Local nPosLay   := 0
Local nPosLayCp := 0
Local n1Cnt     := 0
Local n2Cnt     := 0
Local cARQTRB   := ""
Local lTMSEDIEX := ExistBlock("TMSEDIEX")
Local lCtresp   :=  DE0->(FieldPos('DE0_CTRESP')) > 0 

Private __xEDICont := ""

If (nPosLay := Ascan( __aLayOut, {|x| x[1] + x[2] == DE0->DE0_CODLAY + DE0->DE0_CODREG } )) == 0
	#IFDEF TOP
		cAliasTRB := GetNextAlias()
		cQuery := " SELECT "
		cQuery += "  DE1_CODLAY, DE1_CODREG, DE1_SEQUEN, DE1_TIPO , DE1_CAMPO , "
		cQuery += "  DE1_LAYTAM, DE1_LAYDEC, DE1_POSICI, DE1_ALIAS, DE1_POSORD, "
		cQuery += "  DE1_POSCHV, DE1_REGRA , DE1_VALID "
		cQuery += "  FROM " + RetSqlName("DE1")
		cQuery += "  WHERE DE1_FILIAL = '" + xFilial("DE1")  + "' "
		cQuery += "    AND DE1_CODLAY = '" + DE0->DE0_CODLAY + "' "
		cQuery += "    AND DE1_CODREG = '" + DE0->DE0_CODREG + "' "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY DE1_CODLAY, DE1_CODREG, DE1_SEQUEN "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
	#ELSE
		cQuery := " DE1->DE1_FILIAL == '" + xFilial("DE1")  + "' "
		cQuery += " AND DE1->DE1_CODLAY == '" + DE0->DE0_CODLAY + "' "
		cQuery += " AND DE1->DE1_CODREG == '" + DE0->DE0_CODREG + "' "
		cARQTRB := CriaTrab(NIL,.F.)
		IndRegua("DE1",cARQTRB,"DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN",,cQuery)
		DbGoTop()
	#ENDIF
	//-- Alimenta o array contendo informacoes do layout
	If (cAliasTRB)->(!Eof())
		//-- [01] - Codigo Layout
		//-- [02] - Codigo Registro
		Aadd( __aLayOut, {	(cAliasTRB)->DE1_CODLAY, (cAliasTRB)->DE1_CODREG, {} } )
		nPosLay := Len(__aLayOut)
		//-- [03][01] - Sequencia
		//-- [03][02] - Tipo
		//-- [03][03] - Campo
		//-- [03][04] - Tamanho LayOut
		//-- [03][05] - Decimal LayOut
		//-- [03][06] - Posiciona
		//-- [03][07] - Alias
		//-- [03][08] - Ordem 
		//-- [03][09] - Chave
		//-- [03][10] - Regra
		//-- [03][11] - Validacao
		While (cAliasTRB)->(!Eof())
			Aadd( __aLayOut[Len(__aLayOut),3], {	(cAliasTRB)->DE1_SEQUEN, ;
													(cAliasTRB)->DE1_TIPO  , ; 
													AllTrim((cAliasTRB)->DE1_CAMPO) , ;
													(cAliasTRB)->DE1_LAYTAM, ;
													(cAliasTRB)->DE1_LAYDEC, ;
													(cAliasTRB)->DE1_POSICI, ;
													(cAliasTRB)->DE1_ALIAS , ;
													Val((cAliasTRB)->DE1_POSORD)    , ;
													AllTrim((cAliasTRB)->DE1_POSCHV), ;
													AllTrim((cAliasTRB)->DE1_REGRA) , ;
													AllTrim((cAliasTRB)->DE1_VALID) } )
			(cAliasTRB)->(DbSkip())
		EndDo
	EndIf
	#IFDEF TOP
		(cAliasTRB)->(DbCloseArea())
	#ELSE
		DbClearFilter()
		RetIndex("DE1")
		DE1->(DbSetOrder(1))
		FErase( cARQTRB + OrdBagExt() )
	#ENDIF
EndIf

If Len(__aLayOut) > 0
	For n1Cnt := 1 To Len(__aLayOut[nPosLay,3])

		If lApagaTxt
			Exit
		EndIf

		cRegra := ""
		__xEDICont := ""
		aArea      := {}
		lValid     := .T.

		If __aLayOut[nPosLay,3,n1Cnt,I_TIPO] == "1" //-- Item de Layout

			If __aLayOut[nPosLay,3,n1Cnt,I_CAMPO] == "FILLER"
				cLinTxt+= Space(__aLayOut[nPosLay,3,n1Cnt,I_LAYTAM])  
			Else
				//-- Se Posiciona (Retorna o conteudo da Regra)
				If __aLayOut[nPosLay,3,n1Cnt,I_POSICI] == "1"
					If !Empty(__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])
						//-- Valida Alias
						If AliasInDic(__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])
							//-- Salva Area
							aArea  := (__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])->(GetArea())
							//-- Posiciona no Registro
							DbSelectArea(__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])
							//-- Verifica se Existe a Ordem Selecionada
							If !Empty(indexKey(__aLayOut[nPosLay,3,n1Cnt,I_POSORD]))
								DbSetOrder(__aLayOut[nPosLay,3,n1Cnt,I_POSORD])
								//-- Verifica se a chave esta preenchida
								If !Empty(__aLayOut[nPosLay,3,n1Cnt,I_POSCHV])
									//-- Valida Chave
									If TMSME05Mac(__aLayOut[nPosLay,3,n1Cnt,I_POSCHV])
										MsSeek(&(__aLayOut[nPosLay,3,n1Cnt,I_POSCHV]))
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				//-- Executa a Regra
				If !Empty(__aLayOut[nPosLay,3,n1Cnt,I_REGRA])
					//-- Valida Regra
					If !TMSME05Mac(__aLayOut[nPosLay,3,n1Cnt,I_REGRA],@cRegra)
						//-- Existe problema na Regra do campo
						AutoGRLog(cNomArq + " - " + STR0007 + " " +(__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])+"->"+(__aLayOut[nPosLay,3,n1Cnt,I_CAMPO])+" " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Existe problema na regra do campo" ### "configurado no registro:"
						lApagaTxt := .T.
						Exit
					EndIf
				Else
					//-- Se nao existir Regra (Retorna o Campo)
					If !Empty(__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])
						//-- Valida Alias
						If AliasInDic(__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])
							//-- Valida Campo
							If (__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])->(FieldPos(Alltrim(__aLayOut[nPosLay,3,n1Cnt,I_CAMPO]))) > 0
								cRegra:= (__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])->&(AllTrim(__aLayOut[nPosLay,3,n1Cnt,I_CAMPO]))
							EndIf
						EndIf
					EndIf
				EndIf

				//-- Restaura Area
				If Len(aArea) > 0
					RestArea ( aArea )
				EndIf

				If ValType(cRegra) == "U" // Indefinido
					cRegra     := ""
					__xEDICont := cRegra
				ElseIf ValType(cRegra) == "D" // Data
					cRegra     := DtoS(cRegra)
					__xEDICont := cRegra
				ElseIf ValType(cRegra) == "N" // Numerico
					__xEDICont := cRegra
					If At(".",AllTrim(Str(cRegra))) > 0
						cPict := Replicate("9",__aLayOut[nPosLay,3,n1Cnt,I_LAYTAM])+"."+Replicate("9",__aLayOut[nPosLay,3,n1Cnt,I_LAYDEC])
						cRegra:= AllTrim(TransForm(cRegra,cPict))
						cRegra:= StrZero(Val(StrTran(cRegra,".","")),__aLayOut[nPosLay,3,n1Cnt,I_LAYTAM])
					Else
						cRegra := AllTrim(Str(cRegra))
						cDec   := ""
						For nCnt:= 1 To __aLayOut[nPosLay,3,n1Cnt,I_LAYDEC]
							cDec+= "0"
						Next nCnt
						cRegra:= StrZero(Val(cRegra+cDec),__aLayOut[nPosLay,3,n1Cnt,I_LAYTAM])
					EndIf
				EndIf

				//-- Verifica se exise Validacao
				If !Empty(__aLayOut[nPosLay,3,n1Cnt,I_VALIDA])
					If !TMSME05Mac(__aLayOut[nPosLay,3,n1Cnt,I_VALIDA],@lValid)
						//-- Existe problema na Validacao do campo
						AutoGRLog(cNomArq + " - " + STR0008 + " " +(__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])+"->"+(__aLayOut[nPosLay,3,n1Cnt,I_CAMPO])+ " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Existe problema na validacao do campo" ### "configurado no registro:"
						lApagaTxt := .T.
						Exit
					EndIf
				EndIf

				If lValid
					If DE0->DE0_CTRTAM == "1" //-- Controla o Tamanho do Item de Layout						
				   		If lCtresp .and. DE0->DE0_CTRESP == "2"  // VALIDA SE CAMPO EXISTE	      	           		
	      	             	cLinTxt+= Left(StrTran(cRegra,CHR(13)+CHR(10),"")+Space(__aLayOut[nPosLay,3,n1Cnt,I_LAYTAM]),__aLayOut[nPosLay,3,n1Cnt,I_LAYTAM])
	      	             Else
	      	             	cLinTxt+= Left(StrTran(AllTrim(cRegra),CHR(13)+CHR(10),"")+Space(__aLayOut[nPosLay,3,n1Cnt,I_LAYTAM]),__aLayOut[nPosLay,3,n1Cnt,I_LAYTAM])							   
					   	Endif	
					Else //-- Nao Controla o Tamanho do Item de Layout
						If lCtresp .and. DE0->DE0_CTRESP == "2"  // VALIDA SE CAMPO EXISTE
							cLinTxt+= StrTran(cRegra,CHR(13)+CHR(10),"")
						Else
							cLinTxt+= StrTran(AllTrim(cRegra),CHR(13)+CHR(10),"")
						EndIf	
					EndIf
				Else
					//-- Existe problema na Validacao do campo
					AutoGRLog(STR0010 + " " + cNomArq + STR0011 + " " +(__aLayOut[nPosLay,3,n1Cnt,I_ALIAS])+"->"+(__aLayOut[nPosLay,3,n1Cnt,I_CAMPO])+ " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Nao sera gerado o arquivo" ### "porque, existem um ou mais dados que nao atingem a validacao do campo" ### "configurado no registro:"
					lApagaTxt := .T.
					Exit
				EndIf

			EndIf

		Else //-- Complemento de Layout / Complemento Condicional

			nOcorren := 0

			If (nPosLayCp := Ascan( __aLayCp, {|x| x[1] + x[2] + x[3] == __aLayOut[nPosLay,1] + __aLayOut[nPosLay,2] + __aLayOut[nPosLay,3,n1Cnt,I_SEQUEN] } )) == 0
				#IFDEF TOP
					cAliasTRB := GetNextAlias()
					cQuery := " SELECT "
					cQuery += "   DED_CODLAY, DED_CODREG, DED_SEQITE, "
					cQuery += "   DED_ALIAS , DED_POSICI, DED_POSORD, "
					cQuery += "   DED_POSCHV, DED_COND  , DED_OCOREG, "
					cQuery += "   DED_VALID , DEE_ALIAS , DEE_POSICI, "
					cQuery += "   DEE_POSORD, DEE_POSCHV, DEE_REGRA , "
					cQuery += "   DEE_CAMPO , DEE_LAYTAM, DEE_LAYDEC, "
					cQuery += "   DEE_VALID  "
					cQuery += "   FROM " + RetSqlName("DED") + " DED "
					cQuery += "   JOIN " + RetSqlName("DEE") + " DEE "
					cQuery += "     ON  DED.DED_FILIAL = '" + xFilial("DED") + "' "
					cQuery += "     AND DED.DED_CODLAY = '" + __aLayOut[nPosLay,1] + "' "
					cQuery += "     AND DED.DED_CODREG = '" + __aLayOut[nPosLay,2] + "' "
					cQuery += "     AND DED.DED_SEQITE = '" + __aLayOut[nPosLay,3,n1Cnt,I_SEQUEN] + "' "
					cQuery += "     AND DED.D_E_L_E_T_ = ' ' "
					cQuery += "     AND DEE.DEE_FILIAL = '" + xFilial("DEE") + "' "
					cQuery += "     AND DEE.DEE_CODLAY = DED.DED_CODLAY "
					cQuery += "     AND DEE.DEE_CODREG = DED.DED_CODREG "
					cQuery += "     AND DEE.DEE_SEQITE = DED.DED_SEQITE "
					cQuery += "     AND DEE.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DEE_CODLAY, DEE_CODREG, DEE_SEQITE "
					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
					//-- Alimenta o array contendo informacoes do layout
					If (cAliasTRB)->(!Eof())
						//-- [01] - Codigo Layout
						//-- [02] - Codigo Registro
						//-- [03] - Seq. Item
						Aadd( __aLayCp, { (cAliasTRB)->DED_CODLAY, (cAliasTRB)->DED_CODREG, (cAliasTRB)->DED_SEQITE, {}, {} } )
						nPosLayCp := Len(__aLayCp)
						//-- [04][01] - Alias
						//-- [04][02] - Posiciona
						//-- [04][03] - Ordem
						//-- [04][04] - Chave
						//-- [04][05] - Condicao
						//-- [04][06] - Ocorrencia
						//-- [04][07] - Valid
						Aadd( __aLayCp[Len(__aLayCp),4], (cAliasTRB)->DED_ALIAS  )
						Aadd( __aLayCp[Len(__aLayCp),4], (cAliasTRB)->DED_POSICI )
						Aadd( __aLayCp[Len(__aLayCp),4], Val((cAliasTRB)->DED_POSORD) )
						Aadd( __aLayCp[Len(__aLayCp),4], AllTrim((cAliasTRB)->DED_POSCHV) )
						Aadd( __aLayCp[Len(__aLayCp),4], AllTrim((cAliasTRB)->DED_COND) )
						Aadd( __aLayCp[Len(__aLayCp),4], (cAliasTRB)->DED_OCOREG )
						Aadd( __aLayCp[Len(__aLayCp),4], AllTrim((cAliasTRB)->DED_VALID) )
						//-- [05][01] - Alias
						//-- [05][02] - Posiciona
						//-- [05][03] - Ordem
						//-- [05][04] - Chave
						//-- [05][05] - Regra
						//-- [05][06] - Campo
						//-- [05][07] - Tamanho Layout
						//-- [05][08] - Decimal Layout
						//-- [05][09] - Validacao
						While (cAliasTRB)->(!Eof())
								Aadd( __aLayCp[Len(__aLayCp),5], {	(cAliasTRB)->DEE_ALIAS , (cAliasTRB)->DEE_POSICI, Val((cAliasTRB)->DEE_POSORD), ;
																	AllTrim((cAliasTRB)->DEE_POSCHV), Alltrim((cAliasTRB)->DEE_REGRA) , (cAliasTRB)->DEE_CAMPO , ;
																	(cAliasTRB)->DEE_LAYTAM, (cAliasTRB)->DEE_LAYDEC, AllTrim((cAliasTRB)->DEE_VALID) } )
							(cAliasTRB)->(DbSkip())
						EndDo
					EndIf
					(cAliasTRB)->(DbCloseArea())
				#ELSE
					DED->(DbSetOrder(1))
					If DED->(MsSeek(xFilial("DED")+__aLayOut[nPosLay,1]+__aLayOut[nPosLay,2]+__aLayOut[nPosLay,3,n1Cnt,I_SEQUEN]))
						//-- Alimenta o array contendo informacoes do layout
						//-- [01] - Codigo Layout
						//-- [02] - Codigo Registro
						//-- [03] - Seq. Item
						Aadd( __aLayCp, { DED->DED_CODLAY, DED->DED_CODREG, DED->DED_SEQITE, {}, {} } )
						nPosLayCp := Len(__aLayCp)
						//-- [04][01] - Alias
						//-- [04][02] - Posiciona
						//-- [04][03] - Ordem
						//-- [04][04] - Chave
						//-- [04][05] - Condicao
						//-- [04][06] - Ocorrencia
						//-- [04][07] - Valid
						Aadd( __aLayCp[Len(__aLayCp),4], DED->DED_ALIAS  )
						Aadd( __aLayCp[Len(__aLayCp),4], DED->DED_POSICI )
						Aadd( __aLayCp[Len(__aLayCp),4], Val(DED->DED_POSORD) )
						Aadd( __aLayCp[Len(__aLayCp),4], AllTrim(DED->DED_POSCHV) )
						Aadd( __aLayCp[Len(__aLayCp),4], AllTrim(DED->DED_COND) )
						Aadd( __aLayCp[Len(__aLayCp),4], DED->DED_OCOREG )
						Aadd( __aLayCp[Len(__aLayCp),4], AllTrim(DED->DED_VALID) )
						DEE->(DbSetOrder(1))
						If DEE->(MsSeek(xFilial("DEE")+__aLayOut[nPosLay,1]+__aLayOut[nPosLay,2]+__aLayOut[nPosLay,3,n1Cnt,I_SEQUEN]))
							While DEE->(!Eof()) .And. DEE->DEE_FILIAL + DEE->DEE_CODLAY + DEE->DEE_CODREG + DEE->DEE_SEQITE == xFilial("DEE")+__aLayOut[nPosLay,1]+__aLayOut[nPosLay,2]+__aLayOut[nPosLay,3,n1Cnt,I_SEQUEN]
								//-- [05][01] - Alias
								//-- [05][02] - Posiciona
								//-- [05][03] - Ordem
								//-- [05][04] - Chave
								//-- [05][05] - Regra
								//-- [05][06] - Campo
								//-- [05][07] - Tamanho Layout
								//-- [05][08] - Decimal Layout
								//-- [05][09] - Validacao
								Aadd( __aLayCp[Len(__aLayCp),5], {	DEE->DEE_ALIAS , ;
																	DEE->DEE_POSICI, ;
																	Val(DEE->DEE_POSORD)    , ;
																	AllTrim(DEE->DEE_POSCHV), ;
																	Alltrim(DEE->DEE_REGRA) , ;
																	DEE->DEE_CAMPO , ;
																	DEE->DEE_LAYTAM, ;
																	DEE->DEE_LAYDEC, ;
																	AllTrim(DEE->DEE_VALID) } )
								DEE->(DbSkip())
							EndDo
						EndIf
					EndIf
				#ENDIF
			EndIf

			If Len(__aLayCp) > 0
				//-- Verifica se posiciona
				If __aLayCp[nPosLayCp,4,CP_POSICI] == "1"
					//-- Valida Alias
					If AliasInDic(__aLayCp[nPosLayCp,4,CP_ALIAS])
						DbSelectArea(__aLayCp[nPosLayCp,4,CP_ALIAS])
						//-- Verifica se Existe a Ordem Selecionada
						If !Empty(IndexKey(__aLayCp[nPosLayCp,4,CP_POSORD]))
							dbSetOrder(__aLayCp[nPosLayCp,4,CP_POSORD])
							//-- Verifica se a chave esta preenchida
							If !Empty(__aLayCp[nPosLayCp,4,CP_POSCHV])
								//-- Valida Chave
								If TMSME05Mac(__aLayCp[nPosLayCp,4,CP_POSCHV])
									MsSeek(&(__aLayCp[nPosLayCp,4,CP_POSCHV]))
								EndIf
							EndIf
							cCond := __aLayCp[nPosLayCp,4,CP_COND]
							//-- Caso nao exista condicao, Inicializa com True
							If Empty(cCond)
								cCond := ".T."
							EndIf
							//-- Valida Condicao
							If TMSME05Mac(cCond)
								//-- Verifica se eh continuacao do Complemento
								If (nPos:= Ascan(aPosCompl, { |x| x[1] == __aLayCp[nPosLayCp,4,CP_ALIAS] } ) ) > 0
									If aPosCompl[nPos,3] > 0
										cAlias:= aPosCompl[nPos,1]
										nGoto := aPosCompl[nPos,3]
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Verifica se existem complementos que precisam ser    ³
										//³ atualizados antes do complemento atual.              ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										For nCnt:= nPos+1 To Len(aPosCompl)
											If aPosCompl[nCnt,3] > 0
												cAlias := aPosCompl[nCnt,1]
												nGoto  := aPosCompl[nPos,2] //-- Posicao Anterior do Alias Atual
												Exit
											EndIf
										Next nCnt

										DbGoto(nGoto)
										If cAlias == __aLayCp[nPosLayCp,4,CP_ALIAS]
											aPosCompl[nPos,3] := 0
										EndIf
									EndIf
								EndIf

								//-- Se condicao Verdadeira, Inicializa Ocorrencias
								If &(cCond)
									nOcorren := 1
								EndIf

								While !Eof() .And. &(cCond) .And. nOcorren <= __aLayCp[nPosLayCp,4,CP_OCOREG] .And. !lApagaTxt

									lValidDED := .F.

									//-- Se o campo estiver preenchido, valida os registros
									If !Empty(__aLayCp[nPosLayCp,4,CP_VALID])
										If !TMSME05Mac(__aLayCp[nPosLayCp,4,CP_VALID],@lValidDED)
											//-- Existe problema na Validacao do campo
											AutoGRLog(cNomArq + " - " + STR0013 + " " +AllTrim(__aLayCp[nPosLayCp,1])+"/"+__aLayCp[nPosLayCp,2]) // "Existe problema na validacao configurado para o complemento do registro"
											lApagaTxt := .T.
											Loop
										EndIf
									Else
										lValidDED := .T.
									EndIf

									If !lValidDED
										DbSelectArea(__aLayCp[nPosLayCp,4,CP_ALIAS])
										DbSkip()
										Loop
									EndIf

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Se for complemento do item, atualiza o arquivo texto, se for complemento      ³
									//³ condicional nao atualiza o arquivo, somente posiciona para utilizacao do Item.³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If __aLayOut[nPosLay,3,n1Cnt,I_TIPO] == "2"
										
										For n2Cnt := 1 To Len(__aLayCp[nPosLayCp,5])

											lValid     := .T.
											cRegra     := ""
											__xEDICont := ""
											aArea      := {}

											//-- Se Posiciona (Retorna o conteudo da Regra).
											If __aLayCp[nPosLayCp,5,n2Cnt,CP_I_POSICI] == "1"
												If !Empty(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])
													//-- Valida Alias
													If AliasInDic(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])
														aArea  := (__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])->(GetArea())
														//-- Posiciona no Registro
														DbSelectArea(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])
														//-- Verifica se Existe a Ordem Selecionada
														If !Empty(IndexKey(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_POSORD]))
															DbSetOrder(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_POSORD])
															//-- Verifica se a chave esta preenchida
															If !Empty(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_POSCHV])
																//-- Valida Chave
																If TMSME05Mac(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_POSCHV])
																	MsSeek(&(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_POSCHV]))
																EndIf
															EndIf
														EndIf
													EndIf
												EndIf
											EndIf
											//-- Executa a Regra
											If !Empty(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_REGRA])
												//-- Valida macro do campo Regra
												If !TMSME05Mac(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_REGRA],@cRegra)
													//-- Existe problema na Regra do campo
													AutoGRLog(cNomArq + " - " + STR0007 + " " +(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])+"->"+(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_CAMPO])+ " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Existe problema na regra do campo" ### "configurado no registro:"
													lApagaTxt := .T.
													Exit
												EndIf
											Else
												//-- Se nao existir Regra (Retorna o Campo)
												If !Empty(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])
													//-- Valida Alias
													If AliasInDic(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])
														//-- Valida Campo
														If (__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])->(FieldPos(Alltrim(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_CAMPO]))) > 0
																cRegra:= ((__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])->&(AllTrim(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_CAMPO])))
														EndIf
													EndIf
												EndIf
											EndIf
											//-- Restaura Area
											If Len(aArea) > 0
												RestArea ( aArea )
											EndIf

											If ValType(cRegra) == "U" // Indefinido
												cRegra     := ""
												__xEDICont := cRegra
											ElseIf ValType(cRegra) == "D" // Data
												cRegra     := DtoS(cRegra)
												__xEDICont := cRegra
											ElseIf ValType(cRegra) == "N" // Numerico
												__xEDICont := cRegra
												If At(".",AllTrim(Str(cRegra))) > 0
													cPict := Replicate("9",__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM])+"."+Replicate("9",__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYDEC])
													cRegra:= AllTrim(TransForm(cRegra,cPict))
													cRegra:= StrZero(Val(StrTran(cRegra,".","")),__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM])
												Else
													cRegra := AllTrim(Str(cRegra))
													cDec   := ""
													For nCnt:= 1 To __aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYDEC]
														cDec+= "0"
													Next nCnt
													cRegra:= StrZero(Val(cRegra+cDec),__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM])
												EndIf
											EndIf

											//-- Validacao
											If !Empty(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_VALID])
												//-- Valida macro do campo validacao
												If !TMSME05Mac(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_VALID],@lValid)
													//-- Existe problema na Validacao do campo                ³
													AutoGRLog(cNomArq + " - " + STR0008 + " " +(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])+"->"+(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_CAMPO])+ " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Existe problema na validacao do campo" ### "configurado no registro:"
													lApagaTxt := .T.
													Exit
												EndIf
											EndIf

											If lValid
												If DE0->DE0_CTRTAM == "1" //-- Controla o Tamanho do Item de Layout
	
													If lCtresp .and. DE0->DE0_CTRESP == "2" // VALIDA SE CAMPO EXISTE	      	           	   								
	      	             								cLinTxt+= Left(StrTran(cRegra,CHR(13)+CHR(10),"")+Space(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM]),__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM])	      	             														   	   								
					   					            Else
					   					                cLinTxt+= Left(StrTran(AllTrim(cRegra),CHR(13)+CHR(10),"")+Space(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM]),__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM])					   					                
					   								Endif
												Else //-- Nao Controla o Tamanho do Item de Layout
													If lCtresp .and. DE0->DE0_CTRESP == "2"  // VALIDA SE CAMPO EXISTE
							                           cLinTxt+= StrTran(cRegra,CHR(13)+CHR(10),"")
						                            Else
						                               cLinTxt+= StrTran(AllTrim(cRegra),CHR(13)+CHR(10),"")
						                            EndIf	
												EndIf
											Else
												//-- Existe problema na Validacao do campo
												AutoGRLog(STR0010 + " " + cNomArq + STR0011 + " " +(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])+"->"+(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_CAMPO]) + " " + STR0009 + " "+AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Nao sera gerado o arquivo" ### "porque, existem um ou mais dados que nao atingem a validacao do campo" ### "configurado no registro:"
												lApagaTxt := .T.
												Exit
											EndIf
										Next n2Cnt
									EndIf

									nPosAnt:= (__aLayCp[nPosLayCp,4,CP_ALIAS])->(Recno()) //-- Guarda a Posicao Atual

									DbSelectArea(__aLayCp[nPosLayCp,4,CP_ALIAS])
									DbSkip()
	
									//-- Se passou pela validacao, incrementa No. de ocorrencias
									If lValid 
										nOcorren++
									EndIf
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Se No. de Ocorrencias for maior que o definifo para que- ³
									//³ bra, guarda posicao atual e posiciona na posicao anterior³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If nOcorren > __aLayCp[nPosLayCp,4,CP_OCOREG]
										If &(cCond)
											If (nPos:= Ascan(aPosCompl, { |x| x[1] == __aLayCp[nPosLayCp,4,CP_ALIAS] } ) ) == 0
												Aadd( aPosCompl, { __aLayCp[nPosLayCp,4,CP_ALIAS], nPosAnt, (__aLayCp[nPosLayCp,4,CP_ALIAS])->(RecNo()) } )
											Else
												aPosCompl[nPos,2]:= nPosAnt
												aPosCompl[nPos,3]:= (__aLayCp[nPosLayCp,4,CP_ALIAS])->(RecNo())
											EndIf
										EndIf
										DbGoto(nPosAnt)
									EndIf
	
								EndDo
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Se nao existirem dados devido a validacao, nao grava no arquivo. ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If nOcorren == 1 // Compl. Condicional
									lGrvLinTxt:= .F.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				//-- Se for complemento do item, preenche o restante da ocorrencia conforme Regra
				If __aLayOut[nPosLay,3,n1Cnt,I_TIPO] == "2"

					//-- Inicializa a variavel, caso nao exista ocorrencias.
					If	nOcorren == 0
						nOcorren := 1
					EndIf

					While nOcorren <= __aLayCp[nPosLayCp,4,CP_OCOREG] .And. !lApagaTxt

						For n2Cnt := 1 To Len(__aLayCp[nPosLayCp,5])

							cRegra     := ""
							__xEDICont := ""
							lValid     := .T.

							If !Empty(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_REGRA])
								//-- Valida macro do campo regra
								If !TMSME05Mac(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_REGRA],@cRegra)
									//-- Existe problema na Regra do campo
									AutoGRLog(cNomArq + " - " + STR0007 + " " +(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])+"->"+(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_CAMPO]) + " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Existe problema na regra do campo" ### "configurado no registro:"
									lApagaTxt := .T.
									Exit
								EndIf
							EndIf

							//-- Validacao
							If !Empty(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_VALID])
								//-- Valida macro do campo validacao
								If !TMSME05Mac(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_VALID],@lValid)
									//-- Existe problema na Validacao do campo
									AutoGRLog(cNomArq + " - " + STR0008 + " " +(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])+"->"+(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_CAMPO]) + " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Existe problema na validacao do campo" ### "configurado no registro:"
									lApagaTxt := .T.
									Exit
								EndIf
							EndIf

							If lValid
								If ValType(cRegra) == "U"
									cRegra:= ""
								EndIf
								If DE0->DE0_CTRTAM == "1" //-- Controla o Tamanho do Item de Layout						
				   		          If lCtresp .and. DE0->DE0_CTRESP == "2"  // VALIDA SE CAMPO EXISTE	      	           		
	      	                    		cLinTxt+= Left(StrTran(cRegra,CHR(13)+CHR(10),"")+Space(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM]),__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM])
	      	                     Else	      	             	        
	      	             	        	cLinTxt+= Left(StrTran(AllTrim(cRegra),CHR(13)+CHR(10),"")+Space(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM]),__aLayCp[nPosLayCp,5,n2Cnt,CP_I_LAYTAM])							   
					   	          Endif	
					            Else //-- Nao Controla o Tamanho do Item de Layout
						          If lCtresp .and. DE0->DE0_CTRESP == "2"  // VALIDA SE CAMPO EXISTE
							         cLinTxt+= StrTran(cRegra,CHR(13)+CHR(10),"")
						          Else
							         cLinTxt+= StrTran(AllTrim(cRegra),CHR(13)+CHR(10),"")
						          EndIf	
					            EndIf
							Else
								//-- Existe problema na Validacao do campo
								AutoGRLog(STR0010 + " " + cNomArq + STR0011 + " " +(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_ALIAS])+"->"+(__aLayCp[nPosLayCp,5,n2Cnt,CP_I_CAMPO]) + " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Nao sera gerado o arquivo" ### "porque, existem um ou mais dados que nao atingem a validacao do campo" ### "configurado no registro:"
								lApagaTxt := .T.
								Exit
							EndIf
						Next n2Cnt
						If lValid
							nOcorren++
						EndIf
					EndDo
				EndIf
			EndIf
		EndIf
	Next n1Cnt
EndIf

If lGrvLinTxt .And. !lApagaTxt
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica em qual arquivo sera gravado o layout.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cOldNArq) .Or. (!Empty(DE0->DE0_NOMARQ) .And. AllTrim(DE0->DE0_NOMARQ) <> cOldNArq)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha arquivo corrente.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nHand > 0
			FClose(nHand)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o nome do arquivo esteja preenchido no Configu- ³
		//³ dor do Layout ele substituira o nome do arquivo digi-³
		//³ do na amarracao Cliente x Layout.                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(DE0->DE0_NOMARQ)
			cNomArq := AllTrim(DE0->DE0_NOMARQ)	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida se o nome do Arquivo eh valido.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TMSME05Mac(DE0->DE0_NOMARQ,@cNomArq)
				cNomArq := Alltrim(cNomArq)
			EndIf
		EndIf

		//-- Permite alterar nome do arquivo de exportacao.
		If lTMSEDIEX
			cNomArq := AllTrim(ExecBlock("TMSEDIEX",.F.,.F.,cNomArq))
		EndIf

		cOldNArq := cNomArq

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso Exista, Abre o arquivo, senao Cria um novo.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If File(cDirEnv+cNomArq)
			nHand:= FOpen(cDirEnv+cNomArq,2) //-- Abre Arquivo
			FSeek(nHand,0,2)
		Else
			nHand := FCreate(cDirEnv+cNomArq,,,.F.)//-- Cria Arquivo
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava no Arquivo Texto.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nHand > 0 
	    	fWrite(nHand,cLinTxt+CRLF)
	Endif     
	
	//-- Atualiza a Sequencia da Linha
	__nEDISeqLin++

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena Cabecalho do Layout, utilizado na Quebra    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(DE0->DE0_CODRCP)
		aCabecAnt := {}
		aAdd(aCabecAnt,cNomArq)
		aAdd(aCabecAnt,cLinTxt+CRLF)
	EndIf
EndIf
lGrvLinTxt := .T.

Return !lApagaTxt

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSME05Arq³ Autor ³ Eduardo de Souza      ³ Data ³ 15/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta IndeRegua e verifica se existem dados no Arquivo.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME05Arq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSME05Arq(cAlias,cArqInd,cCond)
Local cIndex   := ""
Local cFiltro  := ""
Local cQuery   := ""
Local lRet     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona ao Filtro a Condicao do Configurador de Layout. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCond)
	If !Empty(cQuery)
		cQuery := AllTrim(cCond)+' .And. '+AllTrim(cQuery)
	Else
		cQuery := cCond
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta IndRegua para o Arquivo Posicionado.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
cArqInd	:= CriaTrab(,.F.)
cIndex	:= (cAlias)->(IndexKey())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Filtro.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TMSME05Mac(cQuery)
	cFiltro :=  cQuery
Else
	cFiltro := ""
EndIf

IndRegua(cAlias,cArqInd,cIndex,,cFiltro,STR0003) //"Selecionando Registros..."
(cAlias)->(MsSeek(xFilial(cAlias)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o arquivo nao esta vazio.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAlias)->(!Eof())
	lRet := .T.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSME05Mac³ Autor ³ Eduardo de Souza      ³ Data ³ 30/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina verificadora da macro digitada.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME05Mac()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSME05Mac(cMacro,xResult)

Local bBlock := ErrorBlock()
Local bErro  := ErrorBlock( { |e| TMSME05Chk(e) } )

Private lRet:=.T.

If Empty(cMacro)
    Return .T.
Endif

Begin Sequence
xResult := &cMacro
End Sequence

ErrorBlock(bBlock)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSME05Chk³ Autor ³ Eduardo de Souza      ³ Data ³ 30/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina analizadora do erro.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME05Chk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSME05Chk(e)

If e:gencode > 0
	If IsBlind()
		TMSLogMsg("ERROR"," > "+FunName()+" - "+e:Description)
	Else
    	HELP(" ",1,"ERR_MSG",,e:Description,2,1) //"Erro de sintaxe"
	EndIf
    lRet:=.F.
Endif

Break

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSME05Del³ Autor ³ Eduardo de Souza      ³ Data ³ 04/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apaga Todos arquivos Textos referente ao Layout.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME05Del()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSME05Del(cCodLay,cNomArq)
Local lTMSEDIEX := ExistBlock("TMSEDIEX")

MsSeek(xFilial("DE0")+cCodLay)
While DE0->(!Eof()) .And. DE0->DE0_FILIAL + DE0->DE0_CODLAY == xFilial("DE0") + cCodLay

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o nome do arquivo esteja preenchido no Configu- ³
	//³ dor do Layout ele substituira o nome do arquivo digi-³
	//³ do na amarracao Cliente x Layout.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(DE0->DE0_NOMARQ)
		cNomArq := AllTrim(DE0->DE0_NOMARQ)	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se o nome do Arquivo eh valido.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TMSME05Mac(DE0->DE0_NOMARQ,@cNomArq)
			cNomArq := Alltrim(cNomArq)
		EndIf
	EndIf

	//-- Permite alterar nome do arquivo de exportacao.
	If lTMSEDIEX
		cNomArq := ExecBlock("TMSEDIEX",.F.,.F.,cNomArq)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga Arquivo Texto.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If File(cDirEnv+cNomArq)
		FErase(cDirEnv+cNomArq)
	EndIf

	DbSelectArea("DE0")
	DbSkip()
EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSME05Log³ Autor ³ Eduardo de Souza      ³ Data ³ 09/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Log de Exportacao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME05Log(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do Arquivo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSME05Log(aGrvLog)
Local nCnt  	:= 0
Local nCnt2 	:= 1
Local lTME05DE2	:= ExistBlock("TME05DE2")
Local aCposDE2	:= {} 

If Len(aGrvLog) > 0
	For nCnt:= 1 To Len(aGrvLog)
		Begin Transaction
			RecLock("DE2",.T.)
			DE2->DE2_FILIAL := xFilial("DE2")
			DE2->DE2_CODCLI := aGrvLog[nCnt,1]
			DE2->DE2_LOJCLI := aGrvLog[nCnt,2]
			DE2->DE2_CODLAY := aGrvLog[nCnt,3]
			DE2->DE2_DTALOG := dDataBase
			DE2->DE2_HORLOG := aGrvLog[nCnt,4]
			DE2->DE2_ALIAS  := aGrvLog[nCnt,5]
			DE2->DE2_RECNO  := aGrvLog[nCnt,6]
			//-- Permite gravar campos de usuario na tabela DE2 (EDI - Arquivo de Log)
			If lTME05DE2
				aCposDE2 := ExecBlock("TME05DE2",.F.,.F.)
				If ValType(aCposDE2) == "A"
					For nCnt2 := 1 To Len(aCposDE2)
						If	DE2->(FieldPos(aCposDE2[nCnt2,1]) > 0 )
							DE2->&(aCposDE2[nCnt2,1]) := aCposDE2[nCnt2,2]
						EndIf
					Next nCnt2
				EndIf
			EndIf
			MsUnlock()
		End Transaction
	Next nCnt
EndIf

Return

//-----------------------------------------------------------------------------------------------------------
/* EDI - Exportacao  - Retorna o código da pergunta conforme tipo de envio
@author  	Jefferson Tomaz de Lima
@version 	P12 12.1.23
@since 		01/03/2019
@return 	Código da pergunta*/
//-----------------------------------------------------------------------------------------------------------
Function TMSME05PER(nTipEnv, cCadastro)

Local cPerg := ""

Default nTipEnv := 0
Default cCadastro := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Pergunte a ser utilizado. Todos perguntes devem comecar ³
//³ com Cliente De / Loja De / Cliente Ate / Loja Ate, para verifica-  ³
//³ cao na amarracao Cliente x Layout.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipEnv == 1

	cPerg     := "TMME01"
	cCadastro := STR0001 // "EDI - Envio de Documentos"	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite selecionar o Pergunte do Usuario para Envio de Documentos. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMSEDIDOC
		cPerg := AllTrim(ExecBlock("TMSEDIDOC",.F.,.F.))
	EndIf

ElseIf nTipEnv == 2

	cPerg := "TMME02"
	cCadastro := STR0002 // "EDI - Envio de Financeiros"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite selecionar o Pergunte do Usuario para Envio de Financeiro. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMSEDIFIN
		cPerg := AllTrim(ExecBlock("TMSEDIFIN",.F.,.F.))
	EndIf

ElseIf nTipEnv == 3

	cPerg := "TMME03"
	cCadastro := STR0003 // "EDI - Envio de Ocorrencias"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite selecionar o Pergunte do Usuario para Envio de Ocorrencias.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMSEDIOCO
		cPerg := AllTrim(ExecBlock("TMSEDIOCO",.F.,.F.))
	EndIf

ElseIf nTipEnv == 4

	cPerg := "TMME04"
	cCadastro := STR0004 // "EDI - Envio de Manifestos"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite selecionar o Pergunte do Usuario para Envio de Manifestos. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMSEDIMAN
		cPerg := AllTrim(ExecBlock("TMSEDIMAN",.F.,.F.))
	EndIf

ElseIf nTipEnv == 5

	cPerg := "TMME05"
	cCadastro := STR0005 // "EDI - Envio de Outros Tipos de Layout"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite selecionar o Pergunte do Usuario para Envio de Outros Tipos. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMSEDIOTP
		cPerg := AllTrim(ExecBlock("TMSEDIOTP",.F.,.F.))
		If Empty(cPerg) .Or. ValType(cPerg) <> "C"
			cPerg := "TMME05"
		EndIf
	EndIf
EndIf

Return(cPerg)
