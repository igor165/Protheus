#include "CDAA050.ch"
#include "protheus.ch"
#include "Fileio.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CDAA050  ³ Autor ³ Cristiano G. Cunha    ³ Data ³ 08/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de envio de dados para o MS-Word em modo texto.   ³±±
±±³          ³ Para ser utilizado na emissao do contrato.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACDA - Controle de Direitos Autorais                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CDAA050
//Define Variaveis
Local nOpca := 0
Local cCadastro := STR0001 //"Gera arquivo do contrato"
Local oDlg

PRIVATE aDicion  := {}
PRIVATE aBancos  := {}
PRIVATE aCampos  := {}
PRIVATE aSays    := {}
PRIVATE aButtons := {}

//Salva a Interface
SaveInter()

If AMIIn(45)

	nFile := 1
	
	PUBLIC aCamp[0]
	dbSelectArea("SX2")
	dbSeek("AH1")
	MontDicio(1,"AH1",nFile)
	CD050Dicio()
	Pergunte("CDA050",.F.)

	AADD(aSays,STR0002) //"Este programa tem como objetivo gerar dados em arquivo   "
	AADD(aSays,STR0003) //"para ser utilizados na emissao do contrato pelo software "
	AADD(aSays,STR0004) //"MS-Word ou similar.                                      "
	
	AADD(aButtons, { 5,.T.,{|| Pergunte("CDA050",.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, FechaBatch() } } )
	AADD(aButtons, { 2,.T.,{|| nOpca:= 2, FechaBatch() }} )
	
	//Monta a tela de processamento
	FormBatch(cCadastro,aSays,aButtons)
	
	If nOpcA == 1
		Processa({|lEnd| CD050Processa(oDlg)},STR0005,STR0006,.F.) //"Geracao do arquivo do contrato"###"Gerando arquivo do contrato..."
	EndIf
EndIf

//Restaura a Interface
RestInter()

If nOpca == 2
	Return (.F.)
Else
	Return (.T.)
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CD050Processa³ Autor ³ Cristiano G. Cunha ³ Data ³ 08/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do arquivo texto p/ MS-Word.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CDAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CD050Processa(oDlg)

Local cNomArq	:= ""
Local cDirDocs:= "/system/"
Local cAlias  := Alias()
Local cCrlf	:= Chr(13) + Chr(10)
Local cLnHead	:= ""
Local cLnItem	:= ""

Local aCpoAH2	:= {}

Local lRet		:= .T.

Local nJ		:= 0
Local nI		:= 0
Local nInd		:= 0
Local nCol		:= 0
Local nWrite	:= 0
Local nHandle	:= 0

aCamp   := aClone(aCampos)
aCampos := {}
aCampo2 := {}

dbSelectArea("AH2")
dbSetOrder(2)
dbSelectArea("AH1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(AH1->(RecCount())+AH2->(RecCount())+Len(aCamp)+Len(aDicion))

For nI := 1 To Len(aCamp)

	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera somente campos com "x" de selecionado.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMarcado := IIf(aCamp[nI][3],"x"," ")
	If cMarcado == "x"
		For nJ := 1 To Len(aDicion)
			If AllTrim(aDicion[nJ][2]) == AllTrim(aCamp[nI][1])

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Substitui caracteres "./- " por "_" no nome de campo.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cTitCampo := ""     // Titulo do Campo
				cTitCampo := aDicion[nJ][2]
				Aadd(aCampos,{cTitCampo,aDicion[nJ][4],Val(aDicion[nJ][5]),aDicion[nJ][7]})
				Aadd(aCampo2,AllTrim(aDicion[nJ][2]))
				Exit
			EndIf
		Next nJ
	EndIf
Next nI

For nInd := 2 to 10   && cria 10 campos do mesmo
	For nCol := 1 to Len(aCpoAH2)
		cTitCampo := Substr(aCpoAH2[nCol][1],1,8) + StrZero(nInd,2)
		Aadd(aCampos,{cTitCampo,aCpoAH2[nCol][2],aCpoAH2[nCol][3],aCpoAH2[nCol][4]})
		Aadd(aCampo2,aCpoAH2[nCol][5])
	Next
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona indice de contrato                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AH1")
dbSetOrder(3)

dbSelectArea("AH2")

cContrato := ""

AH1->( DbSeek( xFilial("AH1") + mv_par01, .T. ) )

// Cria arquivo de trabalho com o indice.
cNomArq := UPPER(AllTrim(mv_par09))

If File( cDirDocs + cNomArq + ".CSV" )
	If FErase( cDirDocs + cNomArq + ".CSV") == 0
		nHandle := FCreate( cDirDocs + cNomArq + ".CSV")
	EndIf
Else
	nHandle := FCreate( cDirDocs + cNomArq + ".CSV")
EndIf

If nHandle > 0
	
	FClose( nHandle )
	nHandle := FOpen( cNomArq + ".CSV", FO_READWRITE + FO_SHARED )
	
	If nHandle > 0
		cLnHead:= ""
		For nI := 1 To Len(aCampos)
			If nI == Len(aCampos)
				cQuebra := ""
			Else
				cQuebra := ";"
			EndIf
			cLnHead += aCampos[nI][1] + cQuebra
		Next nI
		
		nWrite := FWrite( nHandle, cLnHead + cCrlf )
		
		If nWrite <= 0
			lRet := .F.
			AVISO( STR0008, STR0016 + cNomArq + ".CSV", {"Ok"}, 1 )
		EndIf
	Else
		lRet := .F.
		AVISO( STR0008, STR0015 + cNomArq + ".CSV", {"Ok"}, 1 )
	EndIf
	
	While AH1->(!Eof()) .AND. AH1->AH1_FILIAL == xFilial("AH1") .AND. AH1->AH1_CONTRA <= MV_PAR02 .AND. lRet
	
		If AH1->AH1_SEQCON < mv_par03 .OR. AH1->AH1_SEQCON > mv_par04 .OR. ;
			AH1->AH1_PRODUT < mv_par05 .OR. AH1->AH1_PRODUT > mv_par06 .OR. ;
			AH1->AH1_FORNEC < mv_par07 .OR. AH1->AH1_FORNEC > mv_par08 .OR. ;
			AH1->AH1_CONTRA == cContrato
	
			IncProc()
			dbSelectArea("AH1")
			dbSkip()
			Loop
		EndIf
		
		SA2->(dbSeek(xFilial("SA2")+AH1->AH1_FORNEC+AH1->AH1_LOJAFO))
		SB1->(dbSeek(xFilial("SB1")+AH1->AH1_PRODUT))
		
		cContrato := AH1->AH1_CONTRA
		
		DbSeek( xFilial("AH2") + AH1->AH1_CONTRA + AH1->AH1_SEQCON + AH1->AH1_PRODUT + AH1->AH1_FORNEC + AH1->AH1_LOJAFO )
		
		cLnItem := ""
		
		For nI := 1 To Len(aCampos)
			If nI == Len(aCampos)
				cQuebra := ""
			Else
				cQuebra := ";"
			EndIf
			If At("_",aCampo2[nI]) == 3
				cCampo := "S" + Substr(aCampo2[nI],1,2) + "->" + aCampo2[nI]
			Else
				cCampo := Substr(aCampo2[nI],1,3) + "->" + aCampo2[nI]
			EndIf
			
			If ValType(&cCampo) == "D" // Trata campos data
				cLnItem += DToC(&cCampo) + cQuebra
				
			ElseIf ValType(&cCampo) == "N" // Trata campos numericos
				cLnItem += CValToChar( &cCampo ) + cQuebra
				
			ElseIf ValType(&cCampo) == "C" // Trata campos caracter
				cLnItem += &cCampo + cQuebra
				
			ElseIf ValType(&cCampo) == "L" // Trata campos caracter
				If &cCampo
					cLnItem += ".T." + cQuebra
				Else
					cLnItem += ".F." + cQuebra
				EndIf
			EndIf
			
		Next nI
		
		nWrite := FWrite( nHandle, cLnItem + cCrlf )
		
		If nWrite <= 0
			AVISO( STR0008, STR0017 + cNomArq + ".CSV", {"Ok"}, 1 )
			lRet := .F.
			Exit
		EndIf
		
		dbSelectArea("AH1")
		AH1->( DbSkip() )
	EndDo
	
	FClose( nHandle )
	
	// Cria arquivo com ultima posicao do dicionario de contrato.
	If lRet
		AVISO( STR0008, STR0018 + cNomArq + ".CSV" + STR0019, {"Ok"}, 1 )//"Arquivo " " gerado com sucesso."
	
		aStruDic := {}
		Aadd( aStruDic, { "TITULO" , "C", 12, 0 } )
		Aadd( aStruDic, { "CAMPO"  , "C", 10, 0 } )
		Aadd( aStruDic, { "USADO"  , "L",  1, 0 } )
		Aadd( aStruDic, { "TIPO"   , "C",  1, 0 } )
		Aadd( aStruDic, { "TAMANHO", "C",  3, 0 } )
		Aadd( aStruDic, { "PICTURE", "C", 21, 0 } )
		Aadd( aStruDic, { "DECIMAL", "N",  1, 0 } )
		Aadd( aStruDic, { "ORDEM"  , "C",  3, 0 } )
		
		If File("DICIONAR.CSV")
			If FErase("DICIONAR.CSV") == 0
				nHandle := FCreate( "DICIONAR.CSV" )
			EndIf
		Else
			nHandle := FCreate( "DICIONAR.CSV" )
		EndIf
		
		If nHandle > 0
		
			FClose( nHandle )
			nHandle := FOpen( "DICIONAR.CSV", FO_READWRITE + FO_SHARED )
			If nHandle > 0 .AND. lRet
				cLnHead := "TITULO;CAMPO;USADO;TIPO;TAMANHO;PICTURE;DECIMAL;ORDEM"
				nWrite := FWrite( nHandle, cLnHead + cCrlf )
				If nWrite > 0
					For nI := 1 To Len(aDicion)
						IncProc()
						
						cLnItem := ""
						cLnItem += aDicion[nI][1] + ";"
						cLnItem += aDicion[nI][2] + ";"
						cLnItem += If( aDicion[nI][3], ".T.;", ".F.;" )
						cLnItem += aDicion[nI][4] + ";"
						cLnItem += CValToChar( aDicion[nI][5] ) + ";"
						cLnItem += aDicion[nI][6] + ";"
						cLnItem += CValToChar( aDicion[nI][7] ) + ";"
						cLnItem += aDicion[nI][8]
						
						nWrite := FWrite( nHandle, cLnItem + cCrlf )
						
						If nWrite <= 0
							lRet := .F.
							AVISO( STR0008, STR0017 + "DICIONAR.CSV", {"Ok"}, 1 )//"Houve erro na gravação dos Itens do arquivo "
							Exit
						EndIf
					Next nI
					
					FClose( nHandle )
					
					If lRet
						AVISO( STR0008, STR0018 + "DICIONAR.CSV" + STR0019, {"Ok"}, 1 )//"Arquivo " " gerado com sucesso."
					EndIf
				Else
					lRet := .F.
					AVISO( STR0008, STR0016 + "DICIONAR.CSV", {"Ok"}, 1 )//"Houve erro na gravação do Cabeçalho do arquivo "	
				EndIf
			Else
				lRet := .F.
				AVISO( STR0008, STR0015 + "DICIONAR.CSV", {"Ok"}, 1 )//"Houve erro na abertura do arquivo "
			EndIf
		Else
			lRet := .F.
			AVISO( STR0008, STR0014 + "DICIONAR.CSV", {"Ok"}, 1 )//"Houve erro na criação do arquivo "
		EndIf
	EndIf
	
	dbCloseArea()
	
	dbSelectArea( cAlias )
Else
	lRet := .F.
	AVISO( STR0008, STR0014 + cNomArq + ".CSV", {"Ok"}, 1 )//
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ CD050Ok  ³ Autor ³ Cristiano G. Cunha    ³ Data ³ 08/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Mensagem de OK antes de executar o processamento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CDAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CD050Ok()

Return (MsgYesNo(STR0007,STR0008)) //"Confirma geracao do arq. texto ?"###"Aten‡„o"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontDicio³ Autor ³ Cristiano G. Cunha    ³ Data ³ 08/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta dicionario de dados para consulta                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CDAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MontDicio(nFile,cAlias,nSel,cTitulo)

Local nI		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aDicion[nFile][1] := cAlias        // Alias do Arquivo           ³
//³ aDicion[nFile][2] := 1             // Ordem de Indexacao         ³
//³ aDicion[nFile][3] := ""            // Campos Totalizadores       ³
//³ aDicion[nFile][4] := ""            // Relacoes                   ³
//³ aDicion[nFile][5] := {6,2,21,78}   // Posicoes Iniciais          ³
//³ aDicion[nFile][6] := 1             // Posicao Relativa do Cursor ³
//³ aDicion[nFile][7] := ""            // Filtro                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SX3")
dbSeek("AH1")
i := 0
While !Eof() .And. (X3_ARQUIVO == cAlias)
	IF X3_NIVEL > cNivel .OR. X3_CONTEXT == "V" 
		dbSkip()
		Loop
	EndIf

	i++

	IF Type("aDicion[i][3]") = "U"
		AADD(aDicion,{X3_TITULO,X3_CAMPO,IIf(!X3USO(X3_USADO),.F.,.T.),X3_TIPO,STR(X3_TAMANHO,3),X3_PICTURE,X3_DECIMAL,StrZero(i,3)})
	EndIf
	dbSkip()
End

dbSeek("AH2")
While !Eof() .And. (X3_ARQUIVO == "AH2")
	IF X3_NIVEL > cNivel .OR. X3_CONTEXT == "V" ;
		.Or. AllTrim(X3_CAMPO) $ "AH2_FILIAL|AH2_PRODUT|AH2_FORNEC|AH2_LOJAFO"
		dbSkip()
		Loop
	EndIf

	i++

	IF Type("aDicion[i][3]") = "U"
		AADD(aDicion,{X3_TITULO,X3_CAMPO,IIf(!X3USO(X3_USADO),.F.,.T.),X3_TIPO,STR(X3_TAMANHO,3),X3_PICTURE,X3_DECIMAL,StrZero(i,3) })
	EndIf
	dbSkip()
End

dbSeek("SB1")
While !Eof() .And. (X3_ARQUIVO == "SB1")
	IF X3_NIVEL > cNivel .OR. X3_CONTEXT == "V"
		dbSkip()
		Loop
	EndIf

	i++

	IF Type("aDicion[i][3]") = "U"
		AADD(aDicion,{X3_TITULO,X3_CAMPO,IIf(!X3USO(X3_USADO),.F.,.T.),X3_TIPO,STR(X3_TAMANHO,3),X3_PICTURE,X3_DECIMAL,StrZero(i,3)})
	EndIf
	dbSkip()
End

dbSeek("SA2")
While !Eof() .And. (X3_ARQUIVO == "SA2")
	IF X3_NIVEL > cNivel .OR. X3_CONTEXT == "V"
		dbSkip()
		Loop
	EndIf

	i++

	IF Type("aDicion[i][3]") = "U"
		AADD(aDicion,{X3_TITULO,X3_CAMPO,IIf(!X3USO(X3_USADO),.F.,.T.),X3_TIPO,STR(X3_TAMANHO,3),X3_PICTURE,X3_DECIMAL,StrZero(i,3)})
	EndIf
	dbSkip()
End

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CD050Dicio³ Autor ³ Cristiano G. Cunha    ³ Data ³ 08/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Dicionario em Windows.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CDAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CD050Dicio()
Local nNew
Local cBkp      := "01"
Local cAlias    := Alias()
Local i
Local lOk       :=.F.
Local oOk       := LoadBitmap( GetResources(), "LBOK" )
Local oNo       := LoadBitmap( GetResources(), "LBNO" )
Local oDlg
Local oUso
Local oUsado
Local oOrdem

DEFINE MSDIALOG oDlg FROM 153,5 TO 328,361 TITLE STR0009 PIXEL //"Selecione os Campos"
	aCampos := {}
	For i := 1 To Len(aDicion)
		Aadd(aCampos,{aDicion[i][2],;      // Campo
						aDicion[i][1],;    // Titulo
						aDicion[i][3],;    // Usado
						StrZero(i,3) ,;    // Ordem
						aDicion[i][5],;    // Tamanho
						aDicion[i][6],;    // Picture
						aDicion[i][4],;    // Tipo
						aDicion[i][7]})    // Decimal
	Next

	oUso := TWBrowse():New(6,10,91,79,,{"","",""},,oDlg,,,,{|| (oOrdem:SetText(aCampos[oUso:nAt,4]),oUsado:SetOption(If(aCampos[oUso:nAt,3],1,2)),oOrdem:Enable())},{|nRow,nCol,nFlags|(aCampos[oUso:nAt,3] := !aCampos[oUso:nAt,3],oUsado:SetOption(If(aCampos[oUso:nAt,3],1,2)))},,,,,,,.F.,,.T.,,.F.,,.F.,!.F.)

	oUso:SetArray(aCampos)
	oUso:bLine := {||{If(aCampos[oUso:nAt,3],oOk,oNo),aCampos[oUso:nAt,4],aCampos[oUso:nAt,2]}}

	@  8,106 SAY STR0010 SIZE 53,7  OF oDlg PIXEL //"&Ordem:"
	@ 18,106 GET oOrdem VAR aCampos[oUso:nAt,4] OF oDlg SIZE 60,10 VALID (lOk := (Val(aCampos[oUso:nAt,4]) > 0 .And. Val(aCampos[oUso:nAt,4]) <= 999 ),nNew := Val(aCampos[oUso:nAt,4]),If(lOk,aCampos := CD050SortO(aCampos,cBkp,aCampos[oUso:nAt,4]),.F.),If(lOk,oUso:Refresh(),.F.),If(lOk,oUso:Skip(nNew-Val(cBkp)),lOk),If(lOk,SetFocus(oUso:hWnd),.F.),lOk) PICTURE "999" PIXEL
	oOrdem:Disable()
	oOrdem:bGotFocus := {|| cBkp := aCampos[oUso:nAt,4]}

	@ 42,106 SAY STR0011  SIZE 53,7  OF oDlg PIXEL //"Campo em Uso:"
	nUsado := If(aCampos[oUso:nAt,3],1,2)

	@ 41.5,143 RADIO oUsado VAR nUsado 3D SIZE 30,10 PROMPT STR0012,STR0013 OF oDlg ON CHANGE (aCampos[oUso:nAt,3] := If(nUsado == 1,.T.,.F.),oUso:Refresh(.F.)) PIXEL //"Sim"###"Nao"
	SetFocus(oUso:hWnd)

	DEFINE SBUTTON FROM 70, 115 TYPE 1 ENABLE OF oDlg ACTION (lOk := .T.,IF(lOk,oDlg:End(),Nil))
	DEFINE SBUTTON FROM 70, 145 TYPE 2 ENABLE OF oDlg ACTION (lOk := .F.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

Return (lOk)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CD050SortO³ Autor ³ Cristiano G. Cunha    ³ Data ³ 08/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordenacao de campos, por alteracao da ordem pelo usuario   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CDAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CD050SortO(aCampo,cOld,cNew)

Local cTmp
Local i

If cOld == cNew
    Return (aCampo)
EndIf

If Val(cNew) > Len(aCampo)
	cTmp := aCampo[Len(aCampo),4]
	cNew := StrZero(Len(aCampo),3)+"A"
	aCampo[Len(aCampo),4] := cNew
Else
	cTmp := aCampo[Val(cNew),4]
	If Val(cNew) > Val(cOld)
		aCampo[Val(cNew),4] := cNew
		aCampo[Val(cOld),4] := cNew+"A"
	Else
		aCampo[Val(cNew),4] := cNew+"A"
		aCampo[Val(cOld),4] := cNew
	EndIf
EndIf

aCampo := aSort(aCampo,,,{|x,y| x[4] < y[4]})

For i:= 1 to Len(aCampo)
    aCampo[i,4] := StrZero(i,3)
Next

Return (aCampo)
