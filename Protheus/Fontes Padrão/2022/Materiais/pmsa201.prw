#include "PMSA201.ch"
#include "protheus.ch"
#INCLUDE "FWADAPTEREAI.CH"

Static aHeaderEDT
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA201  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutecao de EDT do Projeto                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA201(nCallOpcx,aGetCpos,cNivTrf,lRefresh,xAutoAFC,xAutoAFP)
Local nRecAF9
Local lAutoExec := xAutoAFC <> Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a interface.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

PRIVATE cCadastro := STR0001 //"Estrutura de Decomposicao do Trabalho"
PRIVATE aRotina   := MenuDef()
PRIVATE aMemos    := {{"AFC_CODMEM","AFC_OBS"}}
Private	aAutoAFC
Private	aAutoAFP
Private lEDTRest := .F.
Default lRefresh := .T.

If PMSBLKINT(lAutoExec)
	Return Nil
EndIf

If AMIIn(44)
	If nCallOpcx == Nil
		mBrowse(6,1,22,75,"AF9")

	ElseIf lAutoExec

		PRIVATE lPMS201Auto := .T.
		aAutoAFC := xAutoAFC
		aAutoAFP := xAutoAFP
		
		Default aAutoAFC := {}
		Default aAutoAFP := {}

		If Ascan(aAutoAFC,{|x|Alltrim(x[1]) == 'NEW_AFC_EDT'})>0 .and. nCallOpcx==10
			PMSALTTRF("AFC",aAutoAFC)
		Else
			MBrowseAuto(nCallOpcx,Aclone(aAutoAFC),"AFC")
		Endif

	Else
		cNivTrf := StrZero(Val(cNivTrf) + 1, TamSX3("AFC_NIVEL")[1])
		nRecAF9 := PMS201Dlg("AF9",AF9->(RecNo()),nCallOpcx,,,aGetCpos,cNivTrf,@lRefresh)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a interface.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestInter()
Return nRecAF9


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS201Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Tarefas de Projetos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS201Dlg(cAlias,nReg,nOpcx,xreserv,yreserv,aGetCpos,cNivTrf,lRefresh)

Local l201Inclui	:= .F.
Local l201Visual	:= .F.
Local l201Altera	:= .F.
Local l201Exclui	:= .F.
Local lContinua		:= .T.
Local lOk			:= .F.
Local cMVPMSPRJEXC := SuperGetMv("MV_PMSPEXC",.T.,"1") //1-Visualiza,2-Pergunta,3-Não Pergunta

Local aSize			:= {}
Local aObjects		:= {}
Local aInfo         := {}
Local aPosObj       := {}

Local aCampos

Local aRecAFC	:= {}
Local aRecAFP	:= {}
Local aRecAJ5	:= {}
Local aRecAJ6	:= {}
Local aSavN		:= {1,1,1,1}
Local aButtons      := {}
Local aTitles	:= { 	STR0009,; //'Tarefas' 
						STR0010} //"Eventos"
//						STR0011 ,; //"Relac.Tarefas"
//						STR0012} //"Relac EDT"
Local aAreaAF9  := AF9->(GetArea())
Local aAreaAFP  := AFP->(GetArea())

Local nPosCpo
Local cCpo
Local nRecAFC

Local oDlg
Local oEnch
Local oGD[4]

Local oFolder
Local nx := 0
Local ny := 0
Local ni := 0

Local cExcEdtPms := GetNewPar("MV_PMSTEXC",,"S")
Local cAlias1 := GetNextAlias()

PRIVATE aHeaderSV	:= {{},{},{},{}}
PRIVATE aColsSV		:= {{},{},{},{}}

If IsAuto()
	Private aHEADER := {}
	Private aCOLS   := {}
	
	DEFAULT aAutoAFP := {}
	RegToMemory("AFC", .T.)
	RegToMemory("AFD", .T.)
	RegToMemory("AF9", .T.)
EndIf

DEFAULT cNivTrf := "001"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case                              
	Case aRotina[nOpcx][4] == 2
		l201Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l201Inclui	:= .T.
		Inclui := .T.
		Altera := .F.
	Case aRotina[nOpcx][4] == 4
		l201Altera	:= .T.
		Inclui := .F.
		Altera := .T.
	Case aRotina[nOpcx][4] == 5
		l201Exclui	:= .T.
		l201Visual	:= .T.
EndCase

If l201Inclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o evento de Inclusao na Fase atual.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PmsVldFase("AF8",AF8->AF8_PROJET,"16")
		lContinua := .F.
	EndIf
EndIf

If l201Altera
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario na EnchoiceBar                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PM201BUT" )
		If ValType( aUsButtons := ExecBlock( "PM201BUT", .F., .F. ) ) == "A"
			AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o evento de Alteracao na Fase atual.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PmsVldFase("AF8",AFC->AFC_PROJET,"17")
		lContinua := .F.
	EndIf
EndIf

If l201Exclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o evento de Exclusao no Fase atual.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PmsVldFase("AF8",AFC->AFC_PROJET,"13")
		lContinua := .F.
	EndIf 
	
	If lContinua .And. (cExcEdtPms == "N") 
      
    	// Funcao que varre toda a estrutura abaixo da EDT a ser Excluida, buscando algum apontamento
		If VrfAppEdt( AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDT )

			Aviso(STR0013,STR0014,{STR0015},2) //"Atencao"###"Existem apontamentos para esta EDT, portanto nao pode ser excluida!"###"Fechar"
			lContinua := .F.
		
		EndIf
	EndIf
EndIf                      

If l201Exclui .And. ExistBlock("PMA201EX")
	lContinua := ExecBlock("PMA201EX",.F.,.F.)
EndIf


If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as variaveis de memoria AFC                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("AFC",l201Inclui)
	If l201Inclui
		M->AFC_NIVEL := cNivTrf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compatibilizacao com o PMSA203 ( Eventos ) - Nao retirar     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("AF9",.T.)
	M->AF9_START	:= AFC->AFC_START
	M->AF9_FINISH	:= AFC->AFC_FINISH
	M->AF9_TPMEDI	:= "10"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento do array aGetCpos com os campos Inicializados do AFC    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aGetCpos <> Nil
		aCampos	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AFC")
		While !Eof() .and. SX3->X3_ARQUIVO == "AFC"
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
				If nPosCpo > 0
					If aGetCpos[nPosCpo][3]
						aAdd(aCampos,AllTrim(X3_CAMPO))
					EndIf
				Else
					aAdd(aCampos,AllTrim(X3_CAMPO))
				EndIf
			EndIf
			dbSkip()
		End
		For nx := 1 to Len(aGetCpos)
			cCpo	:= "M->"+Trim(aGetCpos[nx][1])
			&cCpo	:= aGetCpos[nx][2]
		Next nx
	EndIf
	
	//
	// Se for uma exclusao pela rotina automatica ou exclusão rápida.
	// Deve completar o array aAutoAFC com os variaveis de memoria dos 
	// campos do registro atual da tabela AFC
	//
	If l201Exclui .AND. (IsAuto() .OR. cMVPMSPRJEXC!= "1")
	
		If ValType(aAutoAFC) != "A"
			aAutoAFC := {}
		EndIf
		
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AFC")
		While !Eof() .and. SX3->X3_ARQUIVO == "AFC"
			If x3_context != "V" .and. X3USO(x3_usado) .AND. cNivel >= x3_nivel
			
				cCpo := "M->"+Trim(X3_CAMPO)
				
				If (nPosCpo	:= aScan(aAutoAFC ,{|x|x[1]==Alltrim(X3_CAMPO)})) > 0
					aAutoAFC[nPosCPO,02] := &cCpo
				Else
					aAdd(aAutoAFC,{Alltrim(X3_CAMPO),&cCpo,.F.})
				EndIf
			EndIf
			dbSkip()
		EndDo
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeaderAF9                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AF9")
	While !EOF() .And. (x3_arquivo == "AF9")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[1],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeaderAFP                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AFP")
	While !EOF() .And. (x3_arquivo == "AFP")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[2],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader AJ5                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AJ5")
	While !EOF() .And. (x3_arquivo == "AJ5")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[3],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader AJ6                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AJ6")
	While !EOF() .And. (x3_arquivo == "AJ6")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[4],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End


	If !l201Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trava o registro do AFC - Alteracao,Visualizacao       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l201Altera.Or.l201Exclui
			If !SoftLock("AFC")
				lContinua := .F.
			Else
				nRecAFC := AFC->(RecNo())
			Endif
		EndIf  
	EndIf
	
	
	If !l201Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aColsAF9                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF9")
		dbSetOrder(2)
		dbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
		While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI==xFilial("AF9")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT.And.lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava o registro do AF9 - Alteracao,Exclusao           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l201Altera.Or.l201Exclui
				If !SoftLock("AF9")
					lContinua := .F.
				Else
					aAdd(aRecAFC,RecNo())
				Endif
			EndIf
			aADD(aColsSV[1],Array(Len(aHeaderSV[1])+1))
			For ny := 1 to Len(aHeaderSV[1])
				If ( aHeaderSV[1][ny][10] != "V")
					aColsSV[1][Len(aColsSV[1])][ny] := FieldGet(FieldPos(aHeaderSV[1][ny][2]))
				Else
					aColsSV[1][Len(aColsSV[1])][ny] := CriaVar(aHeaderSV[1][ny][2])
				EndIf
				aColsSV[1][Len(aColsSV[1])][Len(aHeaderSV[1])+1] := .F.
			Next ny
			dbSelectArea("AF9")
			dbSkip()
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aColsAF9            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aColsSV[1])
		aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
		For ny := 1 to Len(aHeaderSV[1])
			If Trim(aHeaderSV[1][ny][2]) == "AF9_ITEM"
				aColsSV[1][1][ny] 	:= "01"
			Else
				aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
			EndIf
			aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
		Next ny
	EndIf	
	
	If !l201Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aColsAFP                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFP")
		dbSetOrder(2)
		dbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
		While !Eof() .And. AFP->AFP_FILIAL+AFP->AFP_PROJET+AFP->AFP_REVISA+AFP->AFP_EDT==xFilial("AFC")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT.And.lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava o registro do AFP - Alteracao,Exclusao           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l201Altera.Or.l201Exclui
				If !SoftLock("AFP")
					lContinua := .F.
				Else
					aAdd(aRecAFP,RecNo())
				Endif
			EndIf
			aADD(aColsSV[2],Array(Len(aHeaderSV[2])+1))
			For ny := 1 to Len(aHeaderSV[2])
				If ( aHeaderSV[2][ny][10] != "V")
					aColsSV[2][Len(aColsSV[2])][ny] := FieldGet(FieldPos(aHeaderSV[2][ny][2]))
				Else
					aColsSV[2][Len(aColsSV[2])][ny] := CriaVar(aHeaderSV[2][ny][2])
				EndIf
				aColsSV[2][Len(aColsSV[2])][Len(aHeaderSV[2])+1] := .F.
			Next ny
			dbSelectArea("AFP")
			dbSkip()    
		EndDo
	EndIf
	If Empty(aColsSV[2])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aColsAFP            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
		For ny := 1 to Len(aHeaderSV[2])
			If Trim(aHeaderSV[2][ny][2]) == "AFP_ITEM"
				aColsSV[2][1][ny] 	:= "01"
			Else
				aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
			EndIf
			aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
		Next ny
	EndIf	

	If !l201Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aCols AJ5                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AJ5")
		dbSetOrder(1)
		dbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
		While !Eof() .And. AJ5->AJ5_FILIAL+AJ5->AJ5_PROJET+AJ5->AJ5_REVISA+AJ5->AJ5_EDT==xFilial("AJ5")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT.And.lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava o registro do AJ5 - Alteracao,Exclusao           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l201Altera.Or.l201Exclui
				If !SoftLock("AJ5")
					lContinua := .F.
				Else
					aAdd(aRecAJ5,RecNo())
				Endif
			EndIf
			aADD(aColsSV[3],Array(Len(aHeaderSV[3])+1))
			For ny := 1 to Len(aHeaderSV[3])
				If ( aHeaderSV[3][ny][10] != "V")
					aColsSV[3][Len(aColsSV[3])][ny] := FieldGet(FieldPos(aHeaderSV[3][ny][2]))
				Else
					aColsSV[3][Len(aColsSV[3])][ny] := CriaVar(aHeaderSV[3][ny][2])
				EndIf
				aColsSV[3][Len(aColsSV[3])][Len(aHeaderSV[3])+1] := .F.
			Next ny
			dbSelectArea("AJ5")
			dbSkip()    
		EndDo
	EndIf
	If Empty(aColsSV[3])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols AJ5           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aColsSV[3],Array(Len(aHeaderSV[3])+1))
		For ny := 1 to Len(aHeaderSV[3])
			If Trim(aHeaderSV[3][ny][2]) == "AJ5_ITEM"
				aColsSV[3][1][ny] 	:= "01"
			Else
				aColsSV[3][1][ny] := CriaVar(aHeaderSV[3][ny][2])
			EndIf
			aColsSV[3][1][Len(aHeaderSV[3])+1] := .F.
		Next ny
	EndIf	

	If !l201Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aCols AJ6                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AJ6")
		dbSetOrder(1)
		dbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
		While !Eof() .And. AJ6->AJ6_FILIAL+AJ6->AJ6_PROJET+AJ6->AJ6_REVISA+AJ6->AJ6_EDT==xFilial("AJ6")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT.And.lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava o registro do AJ5 - Alteracao,Exclusao           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l201Altera.Or.l201Exclui
				If !SoftLock("AJ6")
					lContinua := .F.
				Else
					aAdd(aRecAJ6,RecNo())
				Endif
			EndIf
			aADD(aColsSV[4],Array(Len(aHeaderSV[4])+1))
			For ny := 1 to Len(aHeaderSV[4])
				If ( aHeaderSV[4][ny][10] != "V")
					aColsSV[4][Len(aColsSV[4])][ny] := FieldGet(FieldPos(aHeaderSV[4][ny][2]))
				Else
					aColsSV[4][Len(aColsSV[4])][ny] := CriaVar(aHeaderSV[4][ny][2])
				EndIf
				aColsSV[4][Len(aColsSV[4])][Len(aHeaderSV[4])+1] := .F.
			Next ny
			dbSelectArea("AJ6")
			dbSkip()
		EndDo
	EndIf
	If Empty(aColsSV[4])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols AJ6           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aColsSV[4],Array(Len(aHeaderSV[4])+1))
		For ny := 1 to Len(aHeaderSV[4])
			If Trim(aHeaderSV[4][ny][2]) == "AJ6_ITEM"
				aColsSV[4][1][ny] 	:= "01"
			Else
				aColsSV[4][1][ny] := CriaVar(aHeaderSV[4][ny][2])
			EndIf
			aColsSV[4][1][Len(aHeaderSV[4])+1] := .F.
		Next ny
	EndIf	

	If lContinua
		//
		// através de rotina automatica
		//
		If IsAuto()
			Private aGets := {}
			Private aTela := {}
	  
			If EnchAuto(cAlias,aAutoAFC,{|| Obrigatorio(aGets,aTela)},nOpcX) .And.;
				Eval({|| aHeader:=aClone(aHeaderSV[2]), aCols := aClone(aColsSV[2]), .T.}) .And. MsGetDAuto(aAutoAFP,"A201GD2LinOK",{|| A201GD2TudOk() },aAutoAFP,aRotina[nOpcX][4]) .And. Eval({|| aColsSV[2] := aClone(aCols), .T.})
				lOk := .T.                                        
			EndIf
			
		//
		// exclusão rapida
		//
		ElseIf l201Exclui .AND. cMVPMSPRJEXC$ "2µ3"
		
			If EnchAuto(cAlias,aAutoAFC,{|| Obrigatorio(aGets,aTela)},nOpcX)
				lOk := .T.
				If cMVPMSPRJEXC=="2" .AND. Aviso(STR0024,STR0025,{STR0026,STR0027},1) == 2 // "Excluir EDT"/ "Excluir a EDT e suas respectivas EDTs e tarefas?"/ Confirma / Cancela
					lOk := .F.
	            EndIf
			EndIf
			
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz o calculo automatico de dimensoes de objetos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSize := MsAdvSize(,.F.,400)
			aObjects := {} 
			
			AAdd( aObjects, { 100, 100 , .T., .F. } )
			AAdd( aObjects, { 100, 100 , .T., .T. } )
			
			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
			aPosObj := MsObjSize( aInfo, aObjects )
			
			DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+aRotina[nOpcx,01] From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
			
				oEnch := MsMGet():New("AFC",AFC->(RecNo()),nOpcx,,,,,aPosObj[1],aCampos,3,,,,oDlg,,,,,,.T.)
			
				oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{},oDlg,,,, .T., .T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
				oFolder:bSetOption:={|nFolder| A201SetOption(nFolder,oFolder:nOption,@aCols,@aHeader,@aColsSV,@aHeaderSV,@aSavN,@oGD) }
				For ni := 1 to Len(oFolder:aDialogs)
					DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
				Next	
			
				oFolder:aDialogs[1]:oFont := oDlg:oFont
				aHeader		:= aClone(aHeaderSV[1])
				aCols		:= aClone(aColsSV[1])
				oGD[1]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,2,"A201GD1LinOk","A201GD1TudOK",,.F.,,1,,300,,,,,oFolder:aDialogs[1])
				oGD[1]:oBrowse:bDrawSelect	:= {|| A201SVCols(@aHeaderSV,@aColsSV,@aSavN,1)}
	
				oFolder:aDialogs[2]:oFont := oDlg:oFont
				aHeader		:= aClone(aHeaderSV[2])
				aCols		:= aClone(aColsSV[2])
				oGD[2]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A201GD2LinOk","A201GD2TudOK","+AFP_ITEM",.T.,,1,,300,,,,,oFolder:aDialogs[2])
				oGD[2]:oBrowse:bDrawSelect	:= {|| A201SVCols(@aHeaderSV,@aColsSV,@aSavN,2)}
				oGD[2]:oBrowse:lDisablePaint := .T.
	
//				oFolder:aDialogs[3]:oFont := oDlg:oFont
//				aHeader		:= aClone(aHeaderSV[3])
//				aCols		:= aClone(aColsSV[3])
//				oGD[3]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A201GD3LinOk","A201GD3TudOK","+AJ5_ITEM",.F.,,1,,300,,,,,oFolder:aDialogs[3])
//				oGD[3]:oBrowse:bDrawSelect	:= {|| A201SVCols(@aHeaderSV,@aColsSV,@aSavN,3)}
//				oGD[3]:oBrowse:lDisablePaint := .T.

//				oFolder:aDialogs[4]:oFont := oDlg:oFont
//				aHeader		:= aClone(aHeaderSV[4])
//				aCols		:= aClone(aColsSV[4])
//				oGD[4]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A201GD4LinOk","A201GD4TudOK","+AJ6_ITEM",.F.,,1,,300,,,,,oFolder:aDialogs[4])
//				oGD[4]:oBrowse:bDrawSelect	:= {|| A201SVCols(@aHeaderSV,@aColsSV,@aSavN,4)}
//				oGD[4]:oBrowse:lDisablePaint := .T.
	
				aHeader		:= aClone(aHeaderSV[1])
				aCols		:= aClone(aColsSV[1])
	
				aButtons := AddToExcel(aButtons,{	{"ENCHOICE",cCadastro,oEnch:aGets,oEnch:aTela},;
																{"GETDADOS",aTitles[1],aHeaderSV[1],aColsSV[1]},;
																{"GETDADOS",aTitles[2],aHeaderSV[2],aColsSV[2]} } )
			
	
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||If(	Obrigatorio(oEnch:aGets,oEnch:aTela).And.;
																			AGDTudok(aSavN,aColsSV,aHeaderSV,1,oFolder).And.;
																			AGDTudok(aSavN,aColsSV,aHeaderSV,2,oFolder);
																			,(lOk:=.T.,oDlg:End()),Nil)},{||oDlg:End()},,aButtons)
		EndIf
	EndIf	
EndIf

// Nao aplicar refresh na visualizacao do projeto (arvore/planilha)
lRefresh := .F.

If lOk .And. (l201Inclui .Or. l201Altera .Or. l201Exclui)
	// Aplicar refresh na visualizacao do projeto (arvore/planilha)
	lRefresh := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe o ponto de entrada para a permissao ou bloqueio³
	//³da exclusao da EDT.                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l201Exclui
		If ExistBlock("PMA201DEL")
			If !ExecBlock("PMA201DEL",.F.,.F.)
				RestArea(aAreaAF9)
				RestArea(aAreaAFP)
				Return(nRecAFC)
			EndIf
		EndIf
	EndIf

	Begin Transaction
		PMS201Grava(l201Exclui,aHeaderSV,aColsSV,@nRecAFC,@aRecAFP,aRecAJ5,aRecAJ6)
    End Transaction
EndIf

If ExistBlock("PMA201SA")
	ExecBlock("PMA201SA", .T., .T., {lOk, nOpcx})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()

PMS200Rev()             

RestArea(aAreaAF9)
RestArea(aAreaAFP)      

Return nRecAFC

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201SetOption³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA201                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A201SetOption(nFolder,nOldFolder,aCols,aHeader,aColsSV,aHeaderSV,aSavN,oGD)
           
If nOldFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nOldFolder])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva o conteudo da GetDados se existir              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsSV[nOldFolder]		:= aClone(aCols)
	aHeaderSV[nOldFolder]	:= aClone(aHeader)
	aSavN[nOldFolder]		:= n
	oGD[nOldFolder]:oBrowse:lDisablePaint	:= .T.
EndIf

If nFolder!=Nil.And.nFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nFolder])
	oGD[nFolder]:oBrowse:lDisablePaint	:= .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o conteudo da GetDados se existir           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols	:= aClone(aColsSV[nFolder])
	aHeader := aClone(aHeaderSV[nFolder])
	n		:= aSavN[nFolder]
	oGD[nFolder]:oBrowse:Refresh()
EndIf


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201GD1TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 2.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA201                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A201GD1TudOk()
Local nx := 0
Local nPosTarefa	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF9_TAREFA"})
Local nSavN	:= n
Local lRet	:= .T.

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosTarefa])
		If !A201GD1LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

If lRet == .T.
	If ExistBlock("PMA201OK")
		lRet := ExecBlock("PMA201OK", .F., .F.)
	EndIf
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201GD1LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 1.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA201                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A201GD1LinOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet := MaCheckCols(aHeader,aCols,n)


Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201GD2LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 2.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA201                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A201GD2LinOk()

Local lRet		:= .T.
Local nPosUso	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_USO"})
Local nPosPrv	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_DTPREV"})
Local nPosCli	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_CLIENT"})
Local nPosLoj	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_LOJA"})
Local nPosVlr	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_VALOR"})
Local nPosCnd	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_COND"})
Local nPosNum	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_NUM"})
Local nPosPref	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_PREFIX"})
Local nPosNat	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_NATURE"})
Local nPosPerc	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_PERC"})
Local nPosTit 	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_GERTIT"})
Local nPosPrv2	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_GERPRV"})

If !aCols[n][Len(aCols[n])]
	If Empty(aCols[n][nPosUso]) .Or. Empty(aCols[n][nPosPrv]) .Or.  Empty(aCols[n][nPosPerc])
		HELP("   ",1,"OBRIGAT2")
		lRet := .F.
	EndIf

	If lRet .And. !Empty(aCols[n][nPosCli])
		If Empty(aCols[n][nPosLoj]) .Or. Empty(aCols[n][nPosVlr]) .Or. Empty(aCols[n][nPosCnd]);
		.Or. ((Empty(aCols[n][nPosNum]) .Or. Empty(aCols[n][nPosPref])) .And. (aCols[n][nPosTit] == "1" ;
		.Or. aCols[n][nPosPrv2] <> "3")).Or. Empty(aCols[n][nPosNat])
			HELP("   ",1,"OBRIGAT2")
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201GD2TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 2.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA201                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A201GD2TudOk()
Local nx := 0
Local nPosUso	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_USO"})
Local nSavN		:= n
Local lRet		:= .T.

For nx := 1 to Len(aColsSV[2])
	n	:= nx
	If !Empty(aColsSV[2][n][nPosUso])
		If !A201GD2LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	  
// VALIDAÇÃO DA RESTRIÇÃO DA EDT, DISTRIBUINDO PARA AS TAREFAS E EDTS FILHAS
If (M->AFC_RESTRI<>"3") .and. !(Empty(M->AFC_DTREST) .and. Empty(M->AFC_HRREST))
	Do case
		Case M->AFC_RESTRI == "1"
			lRet := AtuTrfbyEdt(M->AFC_PROJET ,M->AFC_REVISA,M->AFC_EDT, 1) // Nao iniciar antes de 
		Case M->AFC_RESTRI == "2"
			lRet := AtuTrfbyEdt(M->AFC_PROJET ,M->AFC_REVISA,M->AFC_EDT, 2) // Nao terminar depois de
	EndCase
EndIf

n	:= nSavN

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS201Grava³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a gravacao do Projeto.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA201                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS201Grava(lDeleta,aHeaderSV,aColsSV,nRecAFC,aRecAFP,aRecAJ5,aRecAJ6)

Local lAltera	:= (nRecAFC!=Nil)
Local bCampo 	:= {|n| FieldName(n) }
Local nPosEvent := aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AFP_DESCRI"})
Local nPosPrd3	:= aScan(aHeaderSV[3],{|x|AllTrim(x[2])=="AJ5_PREDEC"})
Local nPosPrd4	:= aScan(aHeaderSV[4],{|x|AllTrim(x[2])=="AJ6_PREDEC"})
Local nx
Local nCntFor,nCntFor2
Local lAtuBDI	:= Type("M->AFC_BDITAR") <> "U"         
Local lRestricao := iif(Type("lEDTRest")=="U",.F., lEDTRest)

If !lDeleta
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o arquivo de de Tarefas do Projeto             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAltera
		AFC->(dbGoto(nRecAFC))
		lAtuBDI	:= lAtuBDI.And. (M->AFC_BDITAR <> AFC->AFC_BDITAR)
		RecLock("AFC",.F.)
	Else
		RecLock("AFC",.T.)
	EndIf                

	If lRestricao // Caso .T. é sinal que os seguintes campos da EDT ja foram atualizados
		For nx := 1 TO FCount()
			If !( (EVAL(bCampo,nx)) $ "AFC_START/AFC_FINISH/AFC_HORAI/AFC_HORAF/AFC_HDURAC/AFC_HUTEIS")
				FieldPut(nx,M->&(EVAL(bCampo,nx)))
			Endif
		Next nx                
	Else
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx                
	Endif

	AFC->AFC_FILIAL := xFilial("AFC")
	MsUnlock()	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Integracao protheus X tin	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If FindFunction( "GETROTINTEG" ) .and. FindFunction("FwHasEAI") .and. FWHasEAI("PMSA201",.T.,,.T.)
		FwIntegDef( 'PMSA201' )
	Endif	
	MSMM(,TamSx3("AFC_OBS")[1],,M->AFC_OBS,1,,,"AFC","AFC_CODMEM")	
	nRecAFC	:= AFC->(RecNo())
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava arquivo AFP (Eventos Marco)                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFP")
	For nCntFor := 1 to Len(aColsSV[2])
		If !aColsSV[2][nCntFor][Len(aHeaderSV[2])+1]
			If !Empty(aColsSV[2][nCntFor][nPosEvent])
				If nCntFor <= Len(aRecAFP)
					dbGoto(aRecAFP[nCntFor])
					RecLock("AFP",.F.)
					PMSAvalAFP("AFP",3,2)
				Else
					RecLock("AFP",.T.)
				EndIf
				For nCntFor2 := 1 To Len(aHeaderSV[2])
			      If ( aHeaderSV[2][nCntFor2][10] != "V" )
						AFP->(FieldPut(FieldPos(aHeaderSV[2][nCntFor2][2]),aColsSV[2][nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AFP->AFP_FILIAL	:= xFilial("AFP")
				AFP->AFP_PROJET	:= AFC->AFC_PROJET
				AFP->AFP_REVISA	:= AFC->AFC_REVISA
				AFP->AFP_EDT	:= AFC->AFC_EDT
				MsUnlock()
				PMSAvalAFP("AFP",1,2)
			EndIf
		Else
			If nCntFor <= Len(aRecAFP)
				dbGoto(aRecAFP[nCntFor])
				RecLock("AFP",.F.,.T.)
				PMSAvalAFP("AFP",3,2)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	Next nCntFor

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava arquivo AJ5                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJ5")
	For nCntFor := 1 to Len(aColsSV[3])
		If !aColsSV[3][nCntFor][Len(aHeaderSV[3])+1]
			If !Empty(aColsSV[3][nCntFor][nPosPrd3])
				If nCntFor <= Len(aRecAJ5)
					dbGoto(aRecAJ5[nCntFor])
					RecLock("AJ5",.F.)
				Else
					RecLock("AJ5",.T.)
				EndIf
				For nCntFor2 := 1 To Len(aHeaderSV[3])
			      If ( aHeaderSV[3][nCntFor2][10] != "V" )
						AJ5->(FieldPut(FieldPos(aHeaderSV[3][nCntFor2][2]),aColsSV[3][nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AJ5->AJ5_FILIAL	:= xFilial("AJ5")
				AJ5->AJ5_PROJET	:= AFC->AFC_PROJET
				AJ5->AJ5_REVISA	:= AFC->AFC_REVISA
				AJ5->AJ5_EDT	:= AFC->AFC_EDT
				MsUnlock()
			EndIf
		Else
			If nCntFor <= Len(aRecAJ5)
				dbGoto(aRecAJ5[nCntFor])
				RecLock("AJ5",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	Next nCntFor
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava arquivo AJ6                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AJ6")
	For nCntFor := 1 to Len(aColsSV[4])
		If !aColsSV[4][nCntFor][Len(aHeaderSV[4])+1]
			If !Empty(aColsSV[4][nCntFor][nPosPrd4])
				If nCntFor <= Len(aRecAJ6)
					dbGoto(aRecAJ6[nCntFor])
					RecLock("AJ6",.F.)
				Else
					RecLock("AJ6",.T.)
				EndIf
				For nCntFor2 := 1 To Len(aHeaderSV[4])
			      If ( aHeaderSV[4][nCntFor2][10] != "V" )
						AJ6->(FieldPut(FieldPos(aHeaderSV[4][nCntFor2][2]),aColsSV[4][nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AJ6->AJ6_FILIAL	:= xFilial("AJ6")
				AJ6->AJ6_PROJET	:= AFC->AFC_PROJET
				AJ6->AJ6_REVISA	:= AFC->AFC_REVISA
				AJ6->AJ6_EDT	:= AFC->AFC_EDT
				MsUnlock()
			EndIf
		Else
			If nCntFor <= Len(aRecAJ6)
				dbGoto(aRecAJ6[nCntFor])
				RecLock("AJ6",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	Next nCntFor
	If lAtuBDI
		aAreaAFC:=AFC->(GetArea())
		aEdts	:=	{}
		AtuBdiTarefas(@aEDTS)                       
		RestArea(aAreaAFC)
		aSort(aEDTS,,,{|x,y| x[1]>y[1]})				
		DbSelectArea('AF9')
		DbSetOrder(2)
		For nX := 1 To Len(aEDTS)
			If DbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+aEDTS[nX,2])			
				While !EOF() .And. xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+aEDTS[nX,2] == AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI
					If AF9->AF9_BDI == 0 
						RecLock('AF9')
						Replace AF9_VALBDI	With AF9->AF9_CUSTO * AFC->AFC_BDITAR/100
						MsUnLock()										
					Endif			
					PmsAvalTrf("AF9",1,,.F.)
					DbSelectArea('AF9')
					DbSkip()          
				Enddo	
			Endif
		Next nX
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Integracao protheus X tin	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If FindFunction( "GETROTINTEG" ) .and. FindFunction("FwHasEAI") .and. FWHasEAI("PMSA201",.T.,,.T.)
		FwIntegDef( 'PMSA201' )
	Endif	
	MaDelAFC(,,,nRecAFC)
EndIf

Return 



Function A201SVCols(aHeaderSV,aColsSV,aSavN,nGetDados)

If nGetDados <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nGetDados])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva o conteudo da GetDados se existir              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsSV[nGetDados]		:= aClone(aCols)
	aHeaderSV[nGetDados]	:= aClone(aHeader)
	aSavN[nGetDados]		:= n
	
	aCols			:= aColsSV[nGetDados]
	aHeader			:= aHeaderSV[nGetDados]
	n      			:= aSavN[nGetDados]
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AGDTudOk³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao auxiliar utilizada pela EnchoiceBar para executar a   ³±±
±±³          ³ TudOk da GetDados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Validacao TudOk da Getdados                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AGDTudok(aSavN,aColsSV,aHeaderSV,nGetDados,oFolder)
Local aSavCols		:= aClone(aCols)
Local aSavHeader	:= aClone(aHeader)
Local nSavN			:= n

Eval(oFolder:bSetOption)

aCols	:= aClone(aColsSV[nGetDados])
aHeader	:= aClone(aHeaderSV[nGetDados])
n		:= aSavN[nGetDados]

Do Case
	Case nGetDados == 1
		lRet := A201GD1Tudok()
	Case nGetDados == 2
		lRet := A201GD2Tudok()
	Case nGetDados == 3
		lRet := A201GD3Tudok()
	Case nGetDados == 4
		lRet := A201GD4Tudok()
EndCase


aCols	:= aClone(aSavCols)
aHeader	:= aClone(aSavHeader)
n		:= nSavN

Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS201VCAL³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao do Calendario utilizado na EDT            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA201.                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS201VCAL()

Local aArea		:= GetArea()

If !Empty(M->AFC_START) .And. !Empty(M->AFC_FINISH)
	M->AFC_HDURAC := PmsHrsItvl(M->AFC_START,M->AFC_HORAI,M->AFC_FINISH,M->AFC_HORAF,M->AFC_CALEND,M->AFC_PROJET)
EndIf

RestArea(aArea)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201GD1FieldOk³ Autor ³ Edson Maricate    ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao dos campos da GetDados.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA201.                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A201GD1FieldOk()

Local lRet	:= .T.
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AFP_ITEM"})
Local aArea		:= GetArea()
Local aAreaAFP	:= AFP->(GetArea())

If Inclui
	lRet := PmsVldFase("AF8",M->AFC_PROJET,"21")
ElseIf Altera
	AFP->(dbSetOrder(1))
	If AFP->(dbSeek(xFilial()+M->AFC_PROJET+M->AFC_REVISA+M->AFC_EDT+aCols[n][nPosItem]))
		lRet := PmsVldFase("AF8",M->AFC_PROJET,"22")
	Else
		lRet := PmsVldFase("AF8",M->AFC_PROJET,"21")
	EndIf
EndIf

RestArea(aAreaAFP)
RestArea(aArea)
Return lRet

Function Pms201PRED()

return .T.

Function Pms201PRDE()

return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201GD3LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 3.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA201                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A201GD3LinOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet 		:= MaCheckCols(aHeader,aCols,n)
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AJ5_ITEM"})

If !(aCols[n][Len(aHeader)+1])
	If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
		lRet := PmsVldFase("AF8",M->AFC_PROJET,"33")
	ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
		AJ5->(dbSetOrder(1))
	  	If AJ5->(dbSeek(xFilial()+M->AFC_PROJET+M->AFC_REVISA+M->AFC_EDT+aCols[n][nPosItem]))
			lRet := PmsVldFase("AF8",M->AFC_PROJET,"34")
		Else
			lRet := PmsVldFase("AF8",M->AFC_PROJET,"33")
		EndIf
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201GD3TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 3.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA201                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A201GD3TudOk()
Local nx := 0
Local nPosPredec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AJ5_PREDEC"})
Local nSavN	:= n
Local lRet	:= .T.

For nx := 1 to Len(aCols)
	n	:= nx
	If !(aCols[n][Len(aHeader)+1]) .And. !Empty(aCols[n][nPosPredec])
		If !A201GD3LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201GD4LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 4.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA201                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A201GD4LinOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet 		:= MaCheckCols(aHeader,aCols,n)
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AJ6_ITEM"})

If !(aCols[n][Len(aHeader)+1])
	If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
		lRet := PmsVldFase("AF8",M->AFC_PROJET,"33")
	ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
		AJ6->(dbSetOrder(1))
	  	If AJ6->(dbSeek(xFilial()+M->AFC_PROJET+M->AFC_REVISA+M->AFC_EDT+aCols[n][nPosItem]))
			lRet := PmsVldFase("AF8",M->AFC_PROJET,"34")
		Else
			lRet := PmsVldFase("AF8",M->AFC_PROJET,"33")
		EndIf
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A201GD4TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 4.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA201                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A201GD4TudOk()
Local nx := 0
Local nPosPredec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AJ6_PREDEC"})
Local nSavN	:= n
Local lRet	:= .T.

For nx := 1 to Len(aCols)
	n	:= nx
	If !(aCols[n][Len(aHeader)+1]) .And. !Empty(aCols[n][nPosPredec])
		If !A201GD4LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS201Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Tarefas de Projetos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS201Vis(aHeaderSV,aColsSV,lDados)
Local nY
Default lDados	:=	.T.

If aHeaderEDT == Nil
	aHeaderEDT	:=	{}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeaderAF9                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AF9")
	While !EOF() .And. (x3_arquivo == "AF9")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[1],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeaderAFP                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AFP")
	While !EOF() .And. (x3_arquivo == "AFP")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[2],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End                              
	AAdd(aHeaderEDT,aHeaderSV[1])
	AAdd(aHeaderEDT,aHeaderSV[2])
Else
	aHeaderSV	:=	aClone(aHeaderEDT)
Endif	
If lDados
	aColsSV[1]:=	{}	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem do aColsAF9                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AF9")
	dbSetOrder(2)
	dbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
	While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI==xFilial("AF9")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT
		aADD(aColsSV[1],Array(Len(aHeaderSV[1])+1))
		For ny := 1 to Len(aHeaderSV[1])
			If ( aHeaderSV[1][ny][10] != "V")
				aColsSV[1][Len(aColsSV[1])][ny] := FieldGet(FieldPos(aHeaderSV[1][ny][2]))
			Else
				aColsSV[1][Len(aColsSV[1])][ny] := CriaVar(aHeaderSV[1][ny][2])
			EndIf
			aColsSV[1][Len(aColsSV[1])][Len(aHeaderSV[1])+1] := .F.
		Next ny
		dbSelectArea("AF9")
		dbSkip()
	EndDo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a montagem de uma linha em branco no aColsAF9            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aColsSV[1])
	aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
	For ny := 1 to Len(aHeaderSV[1])
		If Trim(aHeaderSV[1][ny][2]) == "AF9_ITEM"
			aColsSV[1][1][ny] 	:= "01"
		Else
			aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
		EndIf
		aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
	Next ny
EndIf	
If lDados
	aColsSV[2]:=	{}	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem do aColsAFP                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AFP")
	dbSetOrder(2)
	dbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
	While !Eof() .And. AFP->AFP_FILIAL+AFP->AFP_PROJET+AFP->AFP_REVISA+AFP->AFP_EDT==xFilial("AFC")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT
		aADD(aColsSV[2],Array(Len(aHeaderSV[2])+1))
		For ny := 1 to Len(aHeaderSV[2])
			If ( aHeaderSV[2][ny][10] != "V")
				aColsSV[2][Len(aColsSV[2])][ny] := FieldGet(FieldPos(aHeaderSV[2][ny][2]))
			Else
				aColsSV[2][Len(aColsSV[2])][ny] := CriaVar(aHeaderSV[2][ny][2])
			EndIf
			aColsSV[2][Len(aColsSV[2])][Len(aHeaderSV[2])+1] := .F.
		Next ny
		dbSelectArea("AFP")
		dbSkip()    
	EndDo
Endif
If Empty(aColsSV[2])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aColsAFP            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
	For ny := 1 to Len(aHeaderSV[2])
		If Trim(aHeaderSV[2][ny][2]) == "AFP_ITEM"
			aColsSV[2][1][ny] 	:= "01"
		Else
			aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
		EndIf
		aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
	Next ny
EndIf	

Return 

Static Function AtuBDITarefas(aEDTSPai)
Local aAreaAFC	:=	{}
Local cEdtAtu	:=	AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT
AAdd(aEDTSPAI,{AFC_NIVEL,AFC->AFC_EDT})
AFC->(dBsEToRDER(2))     
AFC->(DbSeek(xFilial()+cEdtAtu))
While !AFC->(Eof()) .And. xFilial('AFC')==AFC->AFC_FILIAL.And. cEdtAtu	==	AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI
	If AFC->AFC_BDITAR == 0   
		aAreaAFC	:=	AFC->(GetArea())
		AtuBDITarefas(@aEDTSPai)
		RestArea(aAreaAFC)
	Endif	   
	AFC->(DbSkip())
Enddo						
                                                   
Return                                             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA201VldPrd ºAutor  ³Clovis Magenta	  º Data ³  30/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao parecida com a PMS203DINI e PMS203DFIM para 		  º±±
±±º          ³ inclusao de EDT, onde iremos validar os relacionamentos    º±±
±±º          ³ das tarefas filhas quando simulamos as novas datas.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ pmsxfuna - AtuTrfbyEdt()		                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA201VldPrd(cTipo , aNovasDts, cAlias, nPosBase)

Local aArea 	:= GetArea()
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFD := AFD->(GetArea())
Local nDuracao := AF9->AF9_HDURAC
Local cHorai	:= ""
Local cHoraf   := ""
Local dStart
Local dFinish
Local aAuxPred 	:= {}
Local lPosFldAFD 	:= .F.
Local lRet			:= .T.
Local lMsg 			:= !IsAuto()

DEFAULT nPosBase  := 0
DEFAULT cTipo  	:= "I"
DEFAULT aNovasDts := {}
DEFAULT cAlias 	:= "AF9"
	/* 
	// Ordem do array aNovasDts //
	1 - Alias -> "AF9"
	2 - Codigo Tarefa/EDT 	- AF9_TAREFA
	3 - Dt. Prev. Inicio 	- AF9_START
	4 - Hr. Prev. Inicio 	- AF9_HORAI
	5 - Dt. Prev. Termino	- AF9_FINISH
	6 - Hr. Prev. Termino 	- AF9_HORAF
	7 - Hrs Duração 			- AF9_HDURAC
	8 - Hrs Uteis 				- AF9_HUTEIS
	9 - Nivel 					- AF9_NIVEL
	10 - Dt. Real. Inicio 	- AF9_DTATUI
	11 - Dt. Real. Termino 	- AF9_DTATUF
	12 - Recno 					- AF9->(RECNO())
	*/
                       
If cAlias == "AF9"

	If (nPosBase := aScan(aNovasDts,{|x|x[1]+x[2] == "AF9" + AF9->AF9_TAREFA }) ) > 0
		dStart   := aNovasDts[nPosBase][3]
		dFinish 	:= aNovasDts[nPosBase][5]
		cHorai	:= aNovasDts[nPosBase][4]
		cHoraf   := aNovasDts[nPosBase][6]
	Else             
		dStart	:= AF9->AF9_START
		dFinish 	:= AF9->AF9_FINISH
		cHorai	:= AF9->AF9_HORAI
		cHoraf   := AF9->AF9_HORAF
	EndIf	
	
	If cTipo == "F" // FIM
	
		dbSelectArea("AFD")
		dbSetOrder(1) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
		MsSeek(xFilial("AFD")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA))
		While AFD->(!EOF()) .and. (AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)==AFD->(AFD_PROJET+AFD_REVISA+AFD_TAREFA) )
		
			AF9->(dbSetOrder(1))
			AF9->(dbSeek(xFilial("AF9")+AF9->AF9_PROJET+AF9->AF9_REVISA+AFD->AFD_PREDEC) )
			Do Case
				Case AFD->AFD_TIPO == "1"             
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dStart < aAuxPred[1] .Or.(dStart == aAuxPred[1] .And. cHorai < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0020 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "Data Inicial invalida. Verifique os relacionamentos da Tarefa "// "Problema Relacional" // "OK"
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "2"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dStart < aAuxPred[1] .Or. (dStart == aAuxPred[1] .And. cHorai < aAuxPred[2])
						If lMsg				
							Aviso(STR0013,STR0020 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" //"Data Inicial invalida. Verifique os relacionamentos da Tarefa " // "Problema Relacional" // "OK"
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "3"
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dFinish < aAuxPred[1] .Or. (dFinish ==	 aAuxPred[1] .And. cHoraf < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0021 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "Data Final invalida. Verifique os relacionamentos da Tarefa "// "Problema Relacional" // "OK"
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "4"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dFinish < aAuxPred[1] .Or.(dFinish == aAuxPred[1] .And. cHoraf < aAuxPred[2])                       
						If lMsg
							Aviso(STR0013,STR0021 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" //"Data Final invalida. Verifique os relacionamentos da Tarefa " // "Problema Relacional" // "OK"
						Endif
						lRet := .F.
						Exit
					EndIf
			EndCase
	
			RestArea(aAreaAF9)      
			dbSelectArea("AFD")
			AFD->(DbSkip())
		EndDo
		
	Else // cTipo == "I" // INICIO
	
		dbSelectArea("AFD")
		dbSetOrder(1) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
		MsSeek(xFilial("AFD")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA))
		While AFD->(!EOF()) .and. (AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)==AFD->(AFD_PROJET+AFD_REVISA+AFD_TAREFA) )
		
			Do Case
				Case AFD->AFD_TIPO == "1"
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dStart < aAuxPred[1] .Or.(dStart == aAuxPred[1] .And. cHorai < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0020 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" //"Data Inicial invalida. Verifique os relacionamentos da Tarefa " // "Problema Relacional" // "OK"
						EndIf
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "2"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dStart < aAuxPred[1] .Or. (dStart == aAuxPred[1] .And. cHorai < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0020 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" //"Data Inicial invalida. Verifique os relacionamentos da Tarefa " // "Problema Relacional" // "OK"
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "3"
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dFinish < aAuxPred[1] .Or. (dFinish == aAuxPred[1] .And. cHoraf < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0021 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "Data Final invalida. Verifique os relacionamentos da Tarefa "// "Problema Relacional" // "OK"
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "4"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dFinish < aAuxPred[1] .Or.(dFinish == aAuxPred[1] .And. cHoraf < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0021 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "Data Final invalida. Verifique os relacionamentos da Tarefa "// "Problema Relacional" // "OK"
						endif
						lRet := .F.
						Exit
					EndIf
			EndCase   
			RestArea(aAreaAF9) 
			dbSelectArea("AFD")
			AFD->(DbSkip())
			
		EndDo
		
	Endif
	
Else // IF CALIAS == AFC

	If nPosBase==0 .and. (nPosBase := aScan(aNovasDts,{|x|x[1]+x[2] == "AFC" + AFC->AFC_EDT }) ) > 0
		dStart   := aNovasDts[nPosBase][3]
		dFinish 	:= aNovasDts[nPosBase][5]
		cHorai	:= aNovasDts[nPosBase][4]
		cHoraf   := aNovasDts[nPosBase][6]
	Else             
		dStart	:= AFC->AFC_START
		dFinish 	:= AFC->AFC_FINISH
		cHorai	:= AFC->AFC_HORAI
		cHoraf   := AFC->AFC_HORAF
	EndIf	

	If cTipo == "F" // FIM
	
		dbSelectArea("AJ4")
		dbSetOrder(2) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC
		MsSeek(xFilial("AJ4")+AFC->(AFC_PROJET+AFC_REVISA+AFC_EDT))
		While AJ4->(!EOF()) .and. (AFC->(AFC_PROJET+AFC_REVISA+AFC_EDT)==AJ4->(AJ4_PROJET+AJ4_REVISA+AJ4_PREDEC) )
		
			AF9->(dbSetOrder(1))
			AF9->(dbSeek(xFilial("AF9")+AFC->AFC_PROJET+AFC->AFC_REVISA+AJ4->AJ4_TAREFA) ) // seleciona a tarefa sucessora
			Do Case
				Case AJ4->AJ4_TIPO == "1"             
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dStart < aAuxPred[1] .Or.(dStart == aAuxPred[1] .And. cHorai < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0020 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "OK" //"Data Inicial invalida. Verifique os relacionamentos da Tarefa " //"Problema Relacional" 
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "2"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dStart < aAuxPred[1] .Or. (dStart == aAuxPred[1] .And. cHorai < aAuxPred[2])
						If lMsg				
							Aviso(STR0013,STR0020 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "OK" // "Data Inicial invalida. Verifique os relacionamentos da Tarefa " //"Problema Relacional" 
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "3"
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dFinish < aAuxPred[1] .Or. (dFinish ==	 aAuxPred[1] .And. cHoraf < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0021 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "OK" //"Data Final invalida. Verifique os relacionamentos da Tarefa " // "Problema Relacional" 
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "4"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dFinish < aAuxPred[1] .Or.(dFinish == aAuxPred[1] .And. cHoraf < aAuxPred[2])                       
						If lMsg
							Aviso(STR0013,STR0021 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023) // "Atencao" // "OK" // "Data Final invalida. Verifique os relacionamentos da Tarefa " // "Problema Relacional" 
						Endif
						lRet := .F.
						Exit
					EndIf
			EndCase
	
			RestArea(aAreaAF9)      
			dbSelectArea("AFD")
			AFD->(DbSkip())
		EndDo
		
	Else
	
		dbSelectArea("AFD")
		dbSetOrder(1) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
		MsSeek(xFilial("AFD")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA))
		While AFD->(!EOF()) .and. (AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)==AFD->(AFD_PROJET+AFD_REVISA+AFD_TAREFA) )
		
			Do Case
				Case AFD->AFD_TIPO == "1"
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dStart < aAuxPred[1] .Or.(dStart == aAuxPred[1] .And. cHorai < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0020 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "OK" // "Data Inicial invalida. Verifique os relacionamentos da Tarefa " // "Problema Relacional" 
						EndIf
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "2"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dStart < aAuxPred[1] .Or. (dStart == aAuxPred[1] .And. cHorai < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0020 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "Data Inicial invalida. Verifique os relacionamentos da Tarefa " // "OK" // "Problema Relacional"
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "3"
					aAuxPred:= PMSADDHrs(AF9->AF9_FINISH,AF9->AF9_HORAF,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dFinish < aAuxPred[1] .Or. (dFinish == aAuxPred[1] .And. cHoraf < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0021 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023) // "Atencao" // "OK" // "Data Final invalida. Verifique os relacionamentos da Tarefa " // "Problema Relacional" 
						Endif
						lRet := .F.
						Exit
					EndIf
				Case AFD->AFD_TIPO == "4"
					aAuxPred:= PMSADDHrs(AF9->AF9_START,AF9->AF9_HORAI,AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					If dFinish < aAuxPred[1] .Or.(dFinish == aAuxPred[1] .And. cHoraf < aAuxPred[2])
						If lMsg
							Aviso(STR0013,STR0021 +aNovasDts[nPosBase][2]+ " .",{STR0022},1,STR0023 ) // "Atencao" // "OK" // "Data Final invalida. Verifique os relacionamentos da Tarefa " // "Problema Relacional" 
						endif
						lRet := .F.
						Exit
					EndIf
			EndCase   
			RestArea(aAreaAF9) 
			dbSelectArea("AFD")
			AFD->(DbSkip())
			
		EndDo
		
	Endif

EndIf


RestArea(aAreaAFD)
RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return lRet

//funcao que simula as novas datas das predecessoras de tras para frente.                      
                             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PA201BakPrd ºAutor  ³Clovis Magenta    º Data ³  01/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funçao que simula as novas datas das tarefas predecessoras º±±
±±º          ³ de trás para frente, por causa da restricao da EDT Pai     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSXFUNA - AtuTrfbyEdt()                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PA201BakPrd(cProjeto,cRevisa,cTarefa,lAtuEDT, aAtuEDT,lReprParc, aBaseDados, nPosBase)
Local aArea    := GetArea()
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFD := AFD->(GetArea())
Local aAuxRet  := {}
Local nRecAF9  := 0
Local nHDurac  := 0
Local cHrRest	:= ""
Local cCalend  := ""
Local cRestricao := ""
Local dDataRest
Local dStart	:= CToD("01/01/1980")
Local cHoraI	:= "00:00"
Local lOk      := .T.

DEFAULT cProjeto	 := ""
DEFAULT cRevisa  	 := ""
DEFAULT cTarefa  	 := ""
DEFAULT aAtuEDT    := {}
DEFAULT aBaseDados := {}
DEFAULT lReprParc  := .F.

dbSelectArea("AF9")
dbSetOrder(1)
MsSeek(xFilial("AF9")+cProjeto+cRevisa+cTarefa)
nRecAF9		:= RecNo()
cCalend		:= AF9->AF9_CALEND
nHDurac		:= AF9->AF9_HDURAC
cRestricao 	:= AF9->AF9_RESTRI
dDataRest  	:= AF9->AF9_DTREST
cHrRest    	:= AF9->AF9_HRREST
	
If ( Empty(AF9->AF9_DTATUI) .Or. lReprParc ) .And. Empty(AF9->AF9_DTATUF) .And. (AF9->AF9_PRIORI < 1000)
	dbSelectArea("AFD")
	dbSetOrder(1) //AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
	MsSeek(xFilial("AFD")+cProjeto+cRevisa+cTarefa)
	While (!Eof() .And. xFilial("AFD")+cProjeto+cRevisa+cTarefa==;
		AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA) .and. lOk
		
		AF9->(DbSeek(xFilial("AF9") + AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC))
		                                                   
/* Array aBaseDados
START  3
HORAI  4 
FINISH 5
HORAF  6
HDURAC 7
*/
		Do Case
			Case AFD->AFD_TIPO=="1" //Fim no Inicio           
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase][5],aBaseDados[nPosBase][6],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase][3],aBaseDados[nPosBase][4],cCalend,nHDurac,AF9->AF9_PROJET,Nil)

				EndIf
			Case AFD->AFD_TIPO=="2" //Inicio no Inicio
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase][3],aBaseDados[nPosBase][4],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskF(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskF(aBaseDados[nPosBase][3],aBaseDados[nPosBase][4],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="3" //Fim no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase][5],aBaseDados[nPosBase][6],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase][5],aBaseDados[nPosBase][6],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
			Case AFD->AFD_TIPO=="4" //Inicio no Fim
				If !Empty(AFD->AFD_HRETAR)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Aplica o retardo na predecessora de acordo com o calendario do PROJETO   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAuxRet := PMSADDHrs(aBaseDados[nPosBase][3],aBaseDados[nPosBase][4],AF8->AF8_CALEND,AFD->AFD_HRETAR,AF9->AF9_PROJET,Nil)
					aAuxRet := PMSDTaskI(aAuxRet[1],aAuxRet[2],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				Else
					aAuxRet := PMSDTaskI(aBaseDados[nPosBase][3],aBaseDados[nPosBase][4],cCalend,nHDurac,AF9->AF9_PROJET,Nil)
				EndIf
		EndCase  
		
		If  (aAuxRet[1]==dStart.And.SubStr(aAuxRet[2],1,2)+SubStr(aAuxRet[2],4,2)>SubStr(cHoraI,1,2)+SubStr(cHoraI,4,2)).Or.;
			(aAuxRet[1] > dStart)
  			aAdd(aBaseDados,{"AF9",AF9->AF9_TAREFA,aAuxRet[1],aAuxRet[2],aAuxRet[3],aAuxRet[4],AF9->AF9_HDURAC,AF9->AF9_HUTEIS,AF9->AF9_NIVEL,AF9->AF9_DTATUI,AF9->AF9_DTATUF, AF9->(RECNO())})
			nPosBase := aScan(aBaseDados,{|x|x[1]+x[2] == "AF9" + AF9->AF9_TAREFA })

			If aScan(aAtuEDT,AF9->AF9_EDTPAI) <= 0
				aAdd(aAtuEDT,AF9->AF9_EDTPAI)
			EndIf

		EndIf

		If ( lOk := PA203VldRes(aBaseDados, nPosBase, .F.) )
			PA201BakPrd(cProjeto,cRevisa,AF9->AF9_TAREFA,lAtuEDT, @aAtuEDT,lReprParc, @aBaseDados, nPosBase)
		Else
			Aviso(STR0013,STR0016 +Alltrim(AF9->AF9_TAREFA)+ STR0017,{STR0018},1,STR0019) // "Atencao" // // "A Data/Hora simuladas da Tarefa " + " inconsistente com a sua restrição." // "OK" //"Restrição conflitante!"
		Endif
		
		AFD->(dbSkip())
	EndDo
Endif

RestArea(aAreaAFD)
RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)


Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³30/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
								{ STR0003,"PMS201Dlg", 0 , 2},; //"Visualizar"
								{ STR0004,   "PMS201Dlg", 0 , 3},; //"Incluir"
								{ STR0005,   "PMS201Dlg", 0 , 4},; //"Alterar"
								{ STR0006,   "PMS201Dlg", 0 , 5},; //"Excluir"
								{ STR0007,"MSDOCUMENT",0,4 }} //"Conhecimento"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IsAuto    ºAutor  ³Bruno Sobieski      º Data ³  04-25-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se estamos dentro da MsExecAuto                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA203                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IsAuto()
Return Type("lPMS201Auto") == "L" .And. lPMS201Auto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³INTEGDEF  ºAutor  ³Wilson de Godoi      º Data ³ 07/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para a interação com EAI                             º±±
±±º          ³envio e recebimento                                         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function IntegDef( cXml, nType, cTypeMsg )  
		Local aRet := {}
		aRet:= PMSI201( cXml, nType, cTypeMsg )
Return aRet