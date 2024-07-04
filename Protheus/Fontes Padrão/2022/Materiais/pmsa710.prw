#INCLUDE "PROTHEUS.CH"
#INCLUDE "PMSA710.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSA710   บAutor  ณGuilherme Santos    บ Data ณ  08/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Aprovacao de Pre-Apontamentos de Recursos                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPMS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSA710(aRotAuto,nCallOpcx,aGetCpos)
Local  aCores  := PmsAJKColor()
Local nCnt 	:= 0
Local oBrowse

PRIVATE cCadastro	:= STR0008 //"Gerenciamento de Projetos"
PRIVATE aRotina := MenuDef()

If PMSBLKINT()
	Return Nil
EndIf
						
If PmsChkAJK(.T.)
	If nCallOpcx <> Nil
		PMS710Dlg("AJK",AJK->(RecNo()),nCallOpcx,,,aGetCpos)
	Else
		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()
		// Defini็ใo da tabela do Browse
		oBrowse:SetAlias('AJK')
		// Defini็ใo da legenda
		For nCnt:= 1 To Len(aCores)
			oBrowse:AddLegend(aCores[nCnt,1] ,aCores[nCnt,2] ,aCores[nCnt,3])
		Next nCnt
		
		// Defini็ใo de filtro
		oBrowse:SetFilterDefault( 'AJK_FILIAL == "'+xFilial("AJK")+'" .AND. AJK_CTRRVS == "1"' )
		
		// Titulo da Browse
		oBrowse:SetDescription(cCadastro)
		// Opcionalmente pode ser desligado a exibi็ใo dos detalhes
		oBrowse:DisableDetails()
		// Ativa็ใo da Classe
		oBrowse:Activate()
	EndIf
EndIf
Return NIL
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSA710SelบAutor  ณGuilherme Santos    บ Data ณ  08/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Procura pelos dados informados nos parametros.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA710                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS710Sel(cAlias,nReg,nOpcx)
Local aItens	:= {}		//Itens do ListBox
Local aRecno	:= {}		//Guarda os Recnos dos Registros
Local cPerg		:= "PMA710"	//Pergunta no SX1
Local lAprova  := .F.
Local cMotivo  := ""

If Pergunte(cPerg, .T.)
	//aParam := {MV_PAR01 ,MV_PAR02 ,MV_PAR03 ,MV_PAR04 ,MV_PAR05 ,MV_PAR06}
	Processa( {|| A710Seek(@aItens, @aRecno) } )
	
	If Len(aItens) > 0
		If A710Select(@aItens, @aRecno ,@lAprova ,@cMotivo)
			Processa( {|| A710Gera(@aRecno ,lAprova ,cMotivo) } )
		EndIf
	Else
		Alert(STR0001, STR0002) //"Nใo existem dados para aprova็ใo. Verifique os parใmetros informados."###"Aten็ใo"
	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS710Dlg บAutor  ณReynaldo Miyashita  บ Data ณ  07/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ dialog de edicao.                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA710                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS710Dlg(cAlias,nRecNo,nOpcx,xRes1,xRes2,aGetCpos)
Local oDlg
Local nRecAJK
Local aCampos
Local aEditCampos 
Local lOk			:= .F.
Local lContinua		:= .T.
Local l710Visual    := .F.
Local l710Aprova	:= .F.
Local l710Rejeita	:= .F.
Local l710Estorna	:= .F.
Local nX			:= 0
Local dDataFec		:= MVUlmes()
Local nI		:= 0
Local cCampo	:= ""
Local cUser := Nil
Local cTemp	:= ""
Local nRecNo	:= 0
Local cQuery	:= ""


Private lMsErroAuto := .F.
PRIVATE nRecAlt		:= 0
PRIVATE l700        := .F.
PRIVATE nAt 		:= 0	

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case aRotina[nOpcx][4] == 2
		l710Visual  := .T.
	Case aRotina[nOpcx][4] == 5
		l710Aprova	:= .T.
		nRecAlt		:= AJK->(RecNo())
	Case aRotina[nOpcx][4] == 4
		l710Rejeita	:= .T.
		nRecAlt		:= AJK->(RecNo())
	Case aRotina[nOpcx][4] == 7
		l710Estorna	:= .T.
		nRecAlt		:= AJK->(RecNo())
EndCase

// carrega as variaveis de memoria
RegToMemory("AJK",.F.)

aEditCampos	:= {} 
aAdd(aEditCampos ,"AJK_MOTIVO" )

If ExistBlock("P710EdCpo")
	aEditCampos := ExecBlock("P710EdCpo" ,.F.,.F.,{aEditCampos})
EndIf
If l710Rejeita                     
	aAdd(aEditCampos ,"AJK_COD_ME1")
//	aAdd(aEditCampos ,"AJK_MOTIVO" )
EndIf

// tratamento do array aGetCpos com os campos Inicializados do AJK
If aGetCpos <> Nil
	aCampos	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AJK")
	While !Eof() .and. SX3->X3_ARQUIVO == "AJK"
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
	
	For nX := 1 to Len(aGetCpos)
		cCpo	:= "M->"+Trim(aGetCpos[nX][1])
		&cCpo	:= aGetCpos[nX][2]
	Next nX
	
EndIf

// verificar data do ultimo fechamento do Projeto
If lContinua .And. (l710Aprova .Or. l710Rejeita .Or. l710Estorna)
	AF8->(dbSetOrder(1))
	If AF8->(MsSeek(xFilial()+M->AJK_PROJET))
		If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(M->AJK_DATA))
			Aviso(STR0002 ,STR0003 + DTOC(AF8->AF8_ULMES) + STR0004,{STR0005},2) //"Operacao Invalida"###"Esta operacao nao podera ser efetuada pois este projeto ja esta fechado com data "###". Verifique o apontamento selecionado."###"Fechar"
			lContinua :=.F.
		EndIf
	EndIf
EndIf

If lContinua
	If !SoftLock("AJK")
		lContinua := .F.
	Else
		nRecAJK := AJK->(RecNo())
	Endif

	// verifica os direitos do usuario
	If l710Visual 
		If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 1, "APRPRE", AJK->AJK_REVISA, cUser, .F.)
			Aviso(STR0006,STR0007,{"Ok"},2) //"Usuแrio sem Permissใo."###"Usuแrio sem permissใo para executar a operacao selecionada. Verifique os direitos do usuแrio na estrutura deste projeto ou o projeto selecionado."
			lContinua	:=.F.
		EndIf
	Else
		If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 2, "APRPRE", AJK->AJK_REVISA, cUser, .F.)
			Aviso(STR0006,STR0007,{"Ok"},2) //"Usuแrio sem Permissใo."###"Usuแrio sem permissใo para executar a operacao selecionada. Verifique os direitos do usuแrio na estrutura deste projeto ou o projeto selecionado."
			lContinua	:=.F.
		EndIf
	EndIf
EndIf

If lContinua .AND. !l710Visual .AND. !l710Estorna .AND. (AJK->AJK_SITUAC $ "2;3" )
	Aviso(STR0002,STR0009,{"Ok"},2) //"Operacao Invalida"### //"Pre Apontamento, jแ foi aprovado/rejeitado. Verifique"
	lContinua := .F.
EndIf

If lContinua .AND. !l710Visual .AND. l710Estorna .AND. Empty(AJK->AJK_SITUAC)
	Aviso(STR0002,STR0025,{"Ok"},2) //"Operacao Invalida"### //"Op็ใo nใo disponํvel para pr้-apontamentos ainda nใo aprovados. Verifique"
	lContinua := .F.
EndIf

If lContinua
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd

	oEnch := MsMGet():New("AJK",AJK->(RecNo()),iIf(l710Visual,2,4),,,,aCampos,{,,(oDlg:nClientHeight - 4)/2,},aEditCampos,3,,,,oDlg)
	M->AJK_SLDHR := A700HrSld(M->AJK_PROJET,M->AJK_REVISA,M->AJK_TAREFA,M->AJK_RECURS)
	FATPDLogUser("PMS710DLG")
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf(a710VldDlg(l710Visual,l710Rejeita,oEnch,oDlg),(lOk:=.T.,oDlg:End()),lOk:=.F.)},{||oDlg:End()})

	If lOk .AND. (l710Aprova .OR. l710Rejeita .OR. l710Estorna)
	
		If l710Aprova
			aCampos	:= {}
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("AFU")
			While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "AFU"
				cCampo	:= Substr(AllTrim(SX3->X3_CAMPO), 4, Len(AllTrim(SX3->X3_CAMPO)) - 3)
				
				If AJK->(FieldPos("AJK" + cCampo)) >0
					If 	X3Uso(SX3->X3_USADO) .AND.;
						AllTrim(SX3->X3_CONTEXT) <> "V" .AND.;
						AllTrim(SX3->X3_CAMPO) <> "AFU_OBS"
						
						Aadd(aCampos, {	AllTrim(SX3->X3_CAMPO),;
										AJK->(&("AJK" + cCampo)),;
										NIL })
		
					ElseIf AllTrim(SX3->X3_CAMPO) == "AFU_OBS" .AND. !Empty(AJK->AJK_CODMEM)
						Aadd(aCampos, { "AFU_OBS",;
										MSMM(AJK->AJK_CODMEM),;
										NIL })
					EndIf
				EndIf
				SX3->(DbSkip())
			End
			Aadd(aCampos ,{"AFU_PREREC" ,"1" ,NIL})

        Else
        	
        	#IFDEF TOP
				Begin Transaction
			#ENDIF
	
			DbSelectArea("AJK")   
			RecLock("AJK" ,.F.)
			AJK->AJK_USRAPR := __cUserID
			If l710Aprova
				AJK->AJK_SITUAC := "2"
			ElseIf l710Rejeita
				AJK->AJK_SITUAC := "3"
			ElseIf l710Estorna
				AJK->AJK_SITUAC := ""
				
				cQuery	:= " Select R_E_C_N_O_ FROM "+ RetSqlName("AFU")
				cQuery	+= " WHERE AFU_FILIAL = '"+ xFilial("AFU") +"' AND "
				cQuery	+= " AFU_PROJET = '"+ AJK->AJK_PROJET +"' AND "
				cQuery	+= " AFU_REVISA = '"+ AJK->AJK_REVISA +"' AND "
				cQuery	+= " AFU_TAREFA = '"+ AJK->AJK_TAREFA +"' AND "
				cQuery	+= " AFU_RECURS = '"+ AJK->AJK_RECURS +"' AND "		
				cQuery	+= " AFU_DATA = '" + Dtos(AJK->AJK_DATA)+"' AND "
				cQuery	+= " AFU_HORAI = '" + AJK->AJK_HORAI +"' AND "
				cQuery	+= " AFU_HORAF = '" + AJK->AJK_HORAF +"' AND "
				cQuery	+= " AFU_HQUANT = '" + Str(AJK->AJK_HQUANT) +"' AND "
				cQuery	+= " D_E_L_E_T_ = '' "
			 
			 	cQuery 	:= ChangeQuery(cQuery)
				cTemp 	:= GetNextAlias()
				dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTemp, .T., .T.)
				
				nRecNo := (cTemp)->R_E_C_N_O_                                                                              
				Pms320Dlg("AFU",nRecNo,9,,,{},.T.,__cUserID,l710Estorna)
			EndIf
			MsUnLock()
		
			MSMM(NIL, TamSx3("AJK_MOTIVO")[1], NIL, M->AJK_MOTIVO, 1, NIL, NIL, "AJK", "AJK_CODME1")
		
			If ExistBlock("P710GrvCp")
				ExecBlock("P710GrvCp", .F.,.F.)
			EndIf
				
			#IFDEF TOP
				End Transaction
			#ENDIF

	    EndIf
	    
		If l710Aprova
			//Executa Rotina automatica
			lMsErroAuto := .F.
		
			MSExecAuto({|x,y| PMSA320(x,y)}, aCampos, 3) //Inclusao
			If lMsErroAuto
				#IFDEF TOP
					//DisarmTransaction()
					// exclui o registro na AJK
				#ENDIF
				MostraErro()
			Else

				#IFDEF TOP
					Begin Transaction
				#ENDIF

				DbSelectArea("AJK")
				RecLock("AJK" ,.F.)
					AJK->AJK_USRAPR := __cUserID
					If l710Aprova
						AJK->AJK_SITUAC := "2"
					ElseIf l710Rejeita
						AJK->AJK_SITUAC := "3"
					EndIf
				MsUnLock()

				MSMM(NIL, TamSx3("AJK_MOTIVO")[1], NIL, M->AJK_MOTIVO, 1, NIL, NIL, "AJK", "AJK_CODME1")

				If ExistBlock("P710GrvCp")
					ExecBlock("P710GrvCp", .F.,.F.)
				EndIf
						
				#IFDEF TOP
					End Transaction
				#ENDIF
				
			EndIf
		EndIf
	
		
	EndIf
	
EndIf

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa710VldDlgบAutor  ณReynaldo Miyashita  บ Data ณ  07/12/2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a dialog                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA710                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a710VldDlg(l710Visual,l710Rejeita,oEnch,oDlg)	
Local lOk := .T.
	If !l710Visual
		lOk := Obrigatorio(oEnch:aGets,oEnch:aTela) 
		If lOk .And. l710Rejeita .and. ( x3usado("AJK_MOTIVO") .and. Empty(M->AJK_MOTIVO))
			Aviso("Valida็ใo",STR0010,{"Ok"},2) //"Informe o motivo da rejei็ใo."
			lOk := .F.
		EndIf
	EndIf
	
	If lOk
		oDlg:End()
	EndIf
	
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA710Seek  บAutor  ณGuilherme Santos    บ Data ณ  08/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Procura pelos dados informados nos parametros.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA710                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A710Seek(aItens, aRecno)
Local cQuery	:= ""		//Query
Local lMark		:= .F.		//Traz itens desmarcados
Local aArea     := GetArea()
Local aAreaAF8  := AF8->(GetArea())
Local aAreaAJK  := AJK->(GetArea())

#IFDEF TOP
	DbSelectArea("AJK")

	If Select("TRB") > 0
		TRB->(dbCloseArea())
	EndIf

	cQuery := "SELECT AJK_FILIAL, " + CRLF
	cQuery += "       AJK_PROJET, " + CRLF
	cQuery += "       AJK_REVISA, " + CRLF
	cQuery += "       AJK_TAREFA, " + CRLF
	cQuery += "       AJK_RECURS, " + CRLF
	cQuery += "       AJK_DATA, " + CRLF
	cQuery += "       AJK_HORAI, " + CRLF
	cQuery += "       AJK_HORAF, " + CRLF
	cQuery += "       AJK_HQUANT, " + CRLF
	cQuery += "       AJK.R_E_C_N_O_ NREC " + CRLF
	cQuery += "FROM   " + RetSqlName("AJK") + " AJK, " + CRLF
	cQuery += "       " + RetSqlName("AF8") + " AF8 " + CRLF
	cQuery += "WHERE  AF8_FILIAL = '"+xFilial("AF8")+"' AND " + CRLF
	cQuery += "       AJK_FILIAL = '"+xFilial("AJK")+"' AND " + CRLF
	cQuery += "       AF8_PROJET = AJK_PROJET AND " + CRLF
	cQuery += "       AF8_REVISA = AJK_REVISA AND " + CRLF
	cQuery += "       AJK_CTRRVS = '1' AND " + CRLF
	cQuery += "       (AJK_SITUAC = '1' OR  AJK_SITUAC = ' ') AND " + CRLF
	cQuery += "       AJK_PROJET BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
	cQuery += "       AJK_RECURS BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND " + CRLF
	cQuery += "       AJK_DATA BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' AND " + CRLF
	cQuery += "       AF8.D_E_L_E_T_ = '' AND " + CRLF
	cQuery += "       AJK.D_E_L_E_T_ = '' " + CRLF

//	Memowrite("PMSA710.SQL", cQuery)
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(NIL, NIL, cQuery), "TRB", .F., .F.)

	ProcRegua(0)
	
	While !TRB->(Eof())
		IncProc()

		If PmsVldFase("AF8", TRB->AJK_PROJET, "89")
			If PmsChkUser(TRB->AJK_PROJET, TRB->AJK_TAREFA, NIL, "", 2, "APRPRE", TRB->AJK_REVISA, NIL, .F.)
				Aadd(aItens, {	lMark,;
								TRB->AJK_PROJET,;
								TRB->AJK_REVISA,;
								TRB->AJK_TAREFA,;
								TRB->AJK_RECURS,;
								StoD(TRB->AJK_DATA),;
								TRB->AJK_HORAI,;
								TRB->AJK_HORAF,;
								TRB->AJK_HQUANT } )

				Aadd(aRecno, {	TRB->NREC, lMark } )
			EndIf
		EndIf
		TRB->(DbSkip())
	End

	If Select("TRB") > 0
		TRB->(dbCloseArea())
	EndIf
#ELSE
	DbSelectArea("AF8")
	DbSetOrder(1)	//AF8_FILIAL, AF8_PROJET, AF8_DESCRI
	DbSeek(xFilial("AF8") + AllTrim(MV_PAR01))
	
	ProcRegua(0)

	If Empty(xFilial("AF8"))
		cFilAF8 := xFilial("AF8")
	EndIf

	While 	!AF8->(Eof()) .AND.;
			xFilial("AF8") == cFilAF8 .AND.;
			AF8->AF8_PROJET >= MV_PAR01 .AND.;
			AF8->AF8_PROJET <= MV_PAR02
		
		DbSelectArea("AJK")
		DbSetOrder(5)	//AJK_FILIAL, AJK_CTRRVS, AJK_PROJET, AJK_REVISA, AJK_DATA, AJK_RECURS
    	If DbSeek(xFilial("AJK") + "1" + AF8->AF8_PROJET + AF8->AF8_REVISA)
		
			While	!AJK->(Eof()) .AND.;
					AJK->AJK_FILIAL == xFilial("AJK") .AND.;
					AJK->AJK_CTRRVS == "1" .AND.;
			      	AF8->AF8_PROJET + AF8->AF8_REVISA == AJK->AJK_PROJET + AJK->AJK_REVISA
			      	
				IncProc()

		      	If 	AJK->AJK_RECURS >= MV_PAR03 .AND.;
		      		AJK->AJK_RECURS <= MV_PAR04 .AND.;
					AJK->AJK_DATA >= MV_PAR05 .AND.;
					AJK->AJK_DATA <= MV_PAR06 .AND. ;
					AJK->AJK_SITUAC = '1' 


					If PmsVldFase("AF8", AJK->AJK_PROJET, "89")
						If PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 2, "APRPRE", AJK->AJK_REVISA, NIL, .F.)
							Aadd(aItens, {	lMark,;
											AJK->AJK_PROJET,;
											AJK->AJK_REVISA,;
											AJK->AJK_TAREFA,;
											AJK->AJK_RECURS,;
											AJK->AJK_DATA,;
											AJK->AJK_HORAI,;
											AJK->AJK_HORAF,;
											AJK->AJK_HQUANT } )

							Aadd(aRecno, {	AJK->(Recno()), .F. } )
						EndIf
					EndIf
				EndIf
				
				AJK->(DbSkip())
			End
		EndIf
		AF8->(DbSkip())
	End
#ENDIF
RestArea(aAreaAJK)
RestArea(aAreaAF8)
RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA710SelectบAutor  ณGuilherme Santos    บ Data ณ  08/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abre a tela para Selecao dos Pre-Apontamentos que deverao  บฑฑ
ฑฑบ          ณ gerar Apontamentos                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA710                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A710Select(aItens, aRecno ,lAprova ,cMotivo)
Local cVar		:= NIL
Local cTitulo	:= STR0003 //"Aprova็ใo de Pre-Apontamentos"
Local lChk1		:= .F.
Local nOpca		:= 0
Local oChk1		:= NIL
Local oDlg		:= NIL
Local oLbx		:= NIL
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local lRet		:= .F.		//Retorno da Funcao
Local nI		:= 0

Local aCampos	:= {	{"AJK_PROJET"	,NIL },;	//Projeto
						{"AJK_REVISA"	,NIL },;	//Revisao
						{"AJK_TAREFA"	,NIL },;	//Tarefa
						{"AJK_RECURS"	,NIL },;	//Recurso
						{"AJK_DATA"		,NIL },;	//Data
						{"AJK_HORAI"	,NIL },;	//Hora Inicial
						{"AJK_HORAF"	,NIL },;	//Hora Final
						{"AJK_HQUANT"	,NIL }}		//Quantidade de Horas
Local cPict_HQUANT := x3Picture("AJK_HQUANT")

DbSelectArea("SX3")
DbSetOrder(2)
For nI := 1 to Len(aCampos)
	If DbSeek(aCampos[nI][1])
		aCampos[nI][2] := X3Titulo()
	EndIf
Next nI

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM C(0),C(0) TO C(240),C(700) PIXEL
   
	@ C(10),C(10) LISTBOX oLbx VAR cVar FIELDS HEADER ;
		Space(1),;													//CheckBox
		aCampos[Ascan( aCampos, {|x| x[1] == "AJK_PROJET"})][2],;	//Projeto
		aCampos[Ascan( aCampos, {|x| x[1] == "AJK_REVISA"})][2],;	//Revisao
		aCampos[Ascan( aCampos, {|x| x[1] == "AJK_TAREFA"})][2],;	//Tarefa
		aCampos[Ascan( aCampos, {|x| x[1] == "AJK_RECURS"})][2],;	//Recurso
		aCampos[Ascan( aCampos, {|x| x[1] == "AJK_DATA"})][2],;	//Data
		aCampos[Ascan( aCampos, {|x| x[1] == "AJK_HORAI"})][2],;	//Hora Inicial
		aCampos[Ascan( aCampos, {|x| x[1] == "AJK_HORAF"})][2],;	//Hora Final
		aCampos[Ascan( aCampos, {|x| x[1] == "AJK_HQUANT"})][2];	//Quantidade de Horas
	   SIZE C(330),C(095) OF oDlg PIXEL ON ;
	   dblClick(aItens[oLbx:nAt,1] := !aItens[oLbx:nAt,1], oLbx:Refresh(), aRecno[oLbx:nAt,2] := !aRecno[oLbx:nAt,2])

	oLbx:SetArray( aItens )
	oLbx:bLine := {|| {Iif(	aItens[oLbx:nAt,01], oOk, oNo),;
							aItens[oLbx:nAt,02],;
							aItens[oLbx:nAt,03],;
							aItens[oLbx:nAt,04],;
							aItens[oLbx:nAt,05],;
							aItens[oLbx:nAt,06],;
							aItens[oLbx:nAt,07],;
							aItens[oLbx:nAt,08],;
							Transform( aItens[oLbx:nAt,09] ,cPict_HQUANT)}}

	@ C(110),C(10) CHECKBOX oChk1 VAR lChk1 PROMPT STR0004 SIZE C(70),C(7) PIXEL OF oDlg ; //"Marca/Desmarca Todos"
	         ON CLICK( aEval( aItens, {|x| x[1] := lChk1 } ),oLbx:Refresh(), aEval( aRecno, {|x| x[2] := lChk1 } ))

	@ C(107),C(260) BUTTON oBtnAprov PROMPT STR0011 SIZE 32,11 PIXEL ACTION (	oDlg:End(), If(	 Ascan(aItens, {|x| x[1] == .T.}) == 0,; //"Aprova"
														Alert(STR0005, STR0002), {lAprova := .T. ,lRet := .T.})) //"Nenhum item selecionado"###"Atencao"
	@ C(107),C(290) BUTTON oBtnAprov PROMPT STR0012 SIZE 32,11 PIXEL ACTION (	oDlg:End(), If(	 Ascan(aItens, {|x| x[1] == .T.}) == 0,; //"Rejeita"
														Alert(STR0005, STR0002), iIf(DlgMot(@cMotivo) ,{lAprova := .F. ,lRet := .T.},.F.))) //"Nenhum item selecionado"###"Atencao"
	DEFINE SBUTTON FROM C(107),C(320) TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
															

	ACTIVATE MSDIALOG oDlg CENTER

Return lRet

Static Function DlgMot(cMotivo)
Local lRet := .F.
Local oMemo

Default cMotivo := ""

	DEFINE MSDIALOG oDlg TITLE STR0013 FROM 8,0 TO 30,78 OF oMainWnd //"Motivo da rejei็ใo dos pre apontamentos"
		@ 01,2 Say STR0014 of oDlg Pixel  //"Comentarios" //"Informe o motivo da rejei็ใo"
		@ 15,2 GET oMemo VAR cMotivo MEMO SIZE 306,100 PIXEL OF oDlg 

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf(!Empty(cMotivo) ,{lRet := .T.,oDlg:End()} ,.T.)},{||oDlg:End()}) CENTERED
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA710Gera  บAutor  ณGuilherme Santos    บ Data ณ  08/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao dos Apontamentos                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA710                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A710Gera(aRecno ,lAprova ,cMotivo)
Local nI		:= 0
Local aCampos	:= {}
Local cCampo	:= ""

Private lMsErroAuto := .F.

ProcRegua(0)
For nI := 1 to Len(aRecno)
	If aRecno[nI][2]
		DbSelectArea("AJK")
		DbGoTo(aRecno[nI][1])
		#IFDEF TOP
			Begin Transaction
		#ENDIF
		RecLock("AJK" ,.F.)
			AJK->AJK_USRAPR := __cUserID
			If lAprova
				AJK->AJK_SITUAC := "2"
			Else
				AJK->AJK_SITUAC := "3"
			EndIf
		MsUnLock()
		
		MSMM(NIL, TamSx3("AJK_MOTIVO")[1], NIL, cMotivo, 1, NIL, NIL, "AJK", "AJK_CODME1")
		
		#IFDEF TOP
			End Transaction
		#ENDIF
		
		aCampos	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AFU")
		While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "AFU"
			cCampo	:= Substr(AllTrim(SX3->X3_CAMPO), 4, Len(AllTrim(SX3->X3_CAMPO)) - 3)
			
			If AJK->(FieldPos("AJK" + cCampo)) >0
				If 	X3Uso(SX3->X3_USADO) .AND.;
					AllTrim(SX3->X3_CONTEXT) <> "V" .AND.;
					AllTrim(SX3->X3_CAMPO) <> "AFU_OBS"
					
					Aadd(aCampos, {	AllTrim(SX3->X3_CAMPO),;
									AJK->(&("AJK" + cCampo)),;
									NIL })
	
				ElseIf AllTrim(SX3->X3_CAMPO) == "AFU_OBS" .AND. !Empty(AJK->AJK_CODMEM)
					Aadd(aCampos, { "AFU_OBS",;
									MSMM(AJK->AJK_CODMEM),;
									NIL })
				EndIf
			EndIf
			SX3->(DbSkip())
		End
        
		Aadd(aCampos ,{"AFU_PREREC" ,"1" ,NIL})

		//Executa Rotina automatica
		lMsErroAuto := .F.

		If lAprova
			//Executa Rotina automatica
			lMsErroAuto := .F.
		
			MSExecAuto({|x,y| PMSA320(x,y)}, aCampos, 3) //Inclusao
			If lMsErroAuto
				#IFDEF TOP
					//DisarmTransaction()
					// exclui o registro na AJK
				#ENDIF
				MostraErro()
			EndIf
		EndIf

	EndIf
	IncProc()
Next nI

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()      ณ Autor ณ Norbert Waage Junior  ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolucao horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function C(nTam)
Local nHRes	:=	GetScreenRes()[1]	//Resolucao horizontal do monitor
Do Case
	Case nHRes == 640	//Resolucao 640x480
		nTam *= 0.8
	Case nHRes == 800	//Resolucao 800x600
		nTam *= 1
	OtherWise			//Resolucao 1024x768 e acima
		nTam *= 1.28
	End Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento para tema "Flat"ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
		nTam *= 0.90
	EndIf
Return Int(nTam)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPMSAJKColorณ Autor ณ Reynaldo Miyashita   ณ Data ณ 09-02-2001 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao que retorna a String de cores para utilizacao nos      ณฑฑ
ฑฑณ          ณBrowses dos apontamentos aprovados.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณPMSXFUN                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsAJKColor()
Local aRet := {}

	aAdd(aRet,{"AJK->AJK_SITUAC=='1' .OR. AJK->AJK_SITUAC==' '","BR_BRANCO",STR0015})	 //"Pendente"
	aAdd(aRet,{"AJK->AJK_SITUAC=='2'",'ENABLE'   ,STR0016})	 //"Aprovado"
	aAdd(aRet,{"AJK->AJK_SITUAC=='3'",'DISABLE'  ,STR0017})	 //"Rejeitado"

Return aRet

Static Function MenuDef()
Local aRotina 	:= {{ STR0018,"AxPesqui" , 0 , 1,,.F.},; //"Pesquisar"
					{ STR0019,"PMS710Dlg" , 0 , 2 },; //"Visualizar"
					{ STR0020,"PMS710Dlg" , 0 , 5 },; //"Aprovar"
					{ STR0021,"PMS710Dlg" , 0 , 4 },; //"Rejeitar"
					{ STR0022,"PMS710Sel" , 0 , 6 },; //"Sele็ใo"
					{ STR0023,"PMS710Leg" , 0 , 6 },; //"Legenda"
					{ STR0024,"PMS710Dlg" , 0 , 7 } } //"Estornar Aprov."
					
Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPMS710Legณ Autor ณwilker valladares       ณ Data ณ 07-05-2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Programa de Exibicao de Legendas                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS710Leg(cAlias,nReg,nOpcx)
Local aCores  := PmsAJKColor()
Local aLegenda:= {}
Local i       := 0

For i:= 1 To Len(aCores)
	Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
Next i

BrwLegenda(cCadastro,STR0023,aLegenda) //"Legenda"

Return(.T.)


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive