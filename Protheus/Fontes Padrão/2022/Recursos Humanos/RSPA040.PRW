#INCLUDE "PROTHEUS.CH"
#INCLUDE "RSPA040.CH"
#INCLUDE "FOLDER.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSPA040  ³ Autor ³ Cristina Ogura        ³ Data ³ 18.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Montagem de Avaliacoes.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSPA040()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA040                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³29/07/14³TQENN4³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Renan Borges³08/07/15³TRTYGK³Criação da função fTotQues para que o sis-³±±
±±³            ³        ³      ³tema valide o total da pontuação para que ³±±
±±³            ³        ³      ³nao gere error.log no campo QG_NOTA       ³±± 
±±³Raquel Hager³06/06/16³TVGR01³Troca do uso de cFilial para xFilial.     ³±±
±±³            ³        ³      ³Uso de ponto nos métodos de posicionamento³±±
±±³            ³        ³      ³nas tabelas.                              ³±±
±±³Matheus M.  ³25/10/16³TVTFA0³Ajuste na exibição das avaliações.        ³±±
±±³Eduardo K.  ³05/04/17³MPRIMESP-9718³Ajuste no momento da exclusão para ³±±
±±³            ³        ³      ³deletar somente o registro posicionado.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPA040()
	Local cFiltra		:= ""			//Variavel para filtro 
	Local cFiltraSQQ	:= ""			//Variavel para filtro
	
	Private aIndFil		:= {}			//Variavel Para Filtro
	Private bFiltraBrw 	:= {|| Nil}	//Variavel para Filtro
	Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
	Private cCadastro := STR0006 //" Montagem das Avaliacoes"
	Private nTamItem	:= (TamSx3("QQ_ITEM")[1])

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SQQ")
	dbSetOrder(1)
	
	cFiltra 	:= CHKRH(FunName(),"SQQ","1")
	cFiltraSQQ 	:= "QQ_ITEM == '"+ STRZERO(1,nTamItem)+"'"                  

	If !Empty(cFiltra)
		cFiltraSQQ := cFiltraSQQ + ".And." + cFiltra
	EndIf
	
	bFiltraBrw 	:= {|| FilBrowse("SQQ",@aIndFil,@cFiltraSQQ) }
	Eval(bFiltraBrw)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE 						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SQQ")
	dbGoTop()
	
	MBrowse(NIL, NIL, NIL, NIL, "SQQ")
	       
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("SQQ",aIndFil)
	
	dbSelectArea("SQQ")
	dbSetOrder(1)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSP040Rot³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de controle dos dados das questoes e alternativas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSP040Rot(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo 								  ³±±
±±³ 		 ³ ExpN1 = Numero do registro								  ³±±
±±³ 		 ³ ExpN2 = Numero da opcao Selecionada						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RSP040Rot(cAlias1,nReg,nOpcx)
	Local bCampo	:= { |nCPO| Field(nCPO) }
	Local aSaveArea	:= GetArea()
	Local lGetd		:= .F.
	Local aPages	:= {}
	Local aTitles	:= {}
	Local nControl	:= 0
	Local oDlgFolder
	Local oTexto, oFont1
	Local aAlter	:= {}
	Local oFont
	Local nI		:= 0
	Local aColsRec	:= {}
	Local lRet	:= .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para Dimensionar Tela		                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
		
	Local aAdv1Size		:= {}
	Local aInfo1AdvSize	:= {}
	Local aObj1Size		:= {}	
	Local aObj1Coords 	:= {}
		
	Local aAdv2Size		:= {}
	Local aInfo2AdvSize	:= {}
	Local aObj2Size		:= {}	
	Local aObj2Coords 	:= {}
	Local nTamCols		:= If(nTamItem > 2, 999, 99)	//Número máximo de linhas permitidas no aCols do MsGetDados.	
	
	Private cTexto	:= ""
	Private l1Vez	:= .T.
	Private aCols	:= {}
	Private aHeader := {}
	Private aQual	:= {}
	Private nOpcao 	:= nOpcx
	Private oGet01, oQual
	Private aTela[0][0], aGets[0]
	Private cArqSQO	:= "" 
	Private nIndSQO	:= 1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("SQQ",aIndFil)
	aIndFil := {}
	dbGoto(nReg)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array contendo os campos que podem ser alterados pela GetDados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aAlter,"QQ_QUESTAO")
	
	dbSelectArea("SQQ")   
	dbSetOrder(1) 
	
	For nI := 1 To FCount()
		M->&(Eval(bCampo,nI)) := FieldGet(nI)
		lInit := .F.
	
		If ( nOpcao == 3 )		// inclusao
			If ( ExistIni(Eval(bCampo,nI)) )
				lInit := .T.
				M->&(Eval(bCampo,nI)) := InitPad(SX3->X3_RELACAO)
				If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
					M->&(Eval(bCampo,nI)) := Padr(M->&(Eval(bCampo,nI)),SX3->X3_TAMANHO)
				Endif
				If ( M->&(Eval(bCampo,nI)) == NIL )
					lInit := .F.
				EndIf
			EndIf
			If ( ! lInit )
				If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
					M->&(Eval(bCampo,nI)) := Space(Len(M->&(Eval(bCampo,nI))))
				ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "N" )
					M->&(Eval(bCampo,nI)) := 0
				ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "D" )
					M->&(Eval(bCampo,nI)) := Ctod("  /  /  ")
				ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "L" )
					M->&(Eval(bCampo,nI)) := .F.
				EndIf
			EndIf
		EndIf
	Next
	
	fTotQues(@lRet)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡Æo da GetDados 							 ³
	//³ *** Cadastro de Avaliacoes                			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A040Config("SQQ","QQ_FILIAL/QQ_TESTE/QQ_DESCRIC/QQ_DURACAO/QQ_TIPO/QQ_SRVCNT",@aColsRec)
	
	dbSelectArea("SQQ")
	SQQ->( DbSetOrder(1) )
	SQQ->( DbSeek( xFilial("SQQ") + M->QQ_TESTE ) ) //dbSeek(cFilial+M->QQ_TESTE)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura variaveis do Objeto Folder				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aTitles,OemtoAnsi(STR0008)) //"&Avaliacao"
	Aadd(aTitles,OemtoAnsi(STR0009)) //"&Questoes da Avaliacao"
	nControl++
	
	Aadd(aPages,"HEADER")
	Aadd(aPages,"DETAIL")
	nControl++
	
	If nOpcao # 2			// Visual - Controle da getdados
		lGetD :=.T.
	EndIf
	
	SETAPILHA()              
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	aAdv1Size    := MsAdvSize(.F.)//aClone(aObjSize[2])
	aInfo1AdvSize    := { 5 , 3 , aAdv1Size[3] , aAdv1Size[4] , 5 , 5 }
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
	aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords )
	
	aAdv2Size    := MsAdvSize(.F.)//aClone(aObjSize[2])
	aInfo2AdvSize    := { aAdv2Size[1] , aAdv2Size[2] , aAdv2Size[3] , aAdv2Size[4] , 5 , 5 }
	aAdd( aObj2Coords , { 050 , 000 , .T. , .T. } )
	aAdd( aObj2Coords , { 002 , 000 , .F. , .T. } )
	aAdd( aObj2Coords , { 050 , 000 , .T. , .T., .T. } )
	aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )
   
	DEFINE FONT oFont1 NAME "Arial Negrito" SIZE 0, -11
	DEFINE MSDIALOG oDlgFolder FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL
	
		@ aObjSize[1,1],aObjSize[1,2] SAY oTexto PROMPT cTexto		SIZE 300,7 OF oDlgFolder PIXEL
	   
	   	oFolder := TFolder():New(aObjSize[2,1],aObjSize[2,2],aTitles, aPages,oDlgFolder,,,, .T., .T.,aObjSize[2,3],aObjSize[2,4],)
		oFolder:bSetOption := {|nAtu| A040Muda(nAtu,oFolder:nOption,oTexto)}
	
		For nI := 1 to Len(oFolder:aDialogs)
			oFolder:aDialogs[nI]:oFont := oDlgFolder:oFont
		Next  
	
		PUBLIC nLastkey
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Folder 01								  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	Zero();MsMGet():New("SQQ",nReg,nOpcao,,,,,{aObj1Size[1,1],aObj1Size[1,2], aObj1Size[1,3]-75,aObj1Size[1,4]-15},,,,,,oFolder:aDialogs[1],,,.T.)
	   
		oGet01:= MSGetDados():New(aObj2Size[1,1],aObj2Size[1,2],aObj2Size[1,3]-55,aObj2Size[1,4]-15,nOpcao,"A040LinOk","A040TudOk","+QQ_ITEM",lGetD,aAlter, , , nTamCols, ,"A040Apaga",,,oFolder:aDialogs[2])	
		oGet01:oBrowse:bDelete := {|| A040Apaga() }
		oGet01:oBrowse:bChange := {|| A040Posiciona() }
		
		@ aObj2Size[3,1], aObj2Size[3,2] LISTBOX oQual FIELDS aQual HEADER STR0010 SIZE aObj2Size[3,3]-15,aObj2Size[3,4]-75 OF oFolder:aDialogs[2] PIXEL//"Avaliacao"
		oQual:SetArray(aQual)
		oQual:bLine := { ||  { aQual[oQual:nAt,1]} }
		 
	ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder, {|| IIf(oGet01:TudoOK() .and. A040Avalia(),(A040Grava(aColsRec),IIf( __lSX8,ConfirmSX8(),.T.),oDlgFolder:End()),.F.) },{|| IIf(__lSX8,RollBackSX8(),.T.),oDlgFolder:End()} )
	SETAPILHA()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga Filtro do Arquivo de Questoes. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If File(cArqSQO+OrdBagExt())	
		dbSelectArea("SQO")
		Set Filter To
		RetIndex("SQO")
		dbSetOrder(1)
		FErase (cArqSQO+OrdBagExt())	
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bFiltraBrw)
	dbGoto(nReg)
	
	RestArea(aSaveArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040Config³ Autor ³ Cristina Ogura       ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Configura os arrays da Getdados.          				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Config(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Alias selecionado								  ³±±
±±³          ³ ExpC2 := Campos que nao devem aparecer na Getdados		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A040Config(cAlias,cString,aColsRec)
	Local nUsado	:= 0
	Local nCnt		:= 0
	Local nPosItem	:= 0
	Local cItem		:= ""
	Local cQuestao	:= ""
	Local aSaveArea	:= GetArea()
	Local nI		:= 0
	Local nX		:= 0
	Local nDel		:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aheader										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	nUsado := 0
	While !EOF() .And. (x3_arquivo == cAlias)
		If cNivel >= x3_nivel .And. ;
			( ! Trim(SX3->X3_CAMPO) $ cString )
			nUsado++
			AADD(	aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal, x3_valid,;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
		EndIf
		dbSkip()
	End
	
	If nOpcao # 3	//# inclusao
		dbSelectArea("SQQ")
		dbSetOrder(1) 
	
		SQQ->( DbSeek(xFilial("SQQ") + M->QQ_TESTE) ) 
		
		While !EOF() .And. SQQ->(QQ_FILIAL+QQ_TESTE) == ;
								 xFilial("SQQ") + M->QQ_TESTE
			nCnt++
			dbSkip()
		EndDo	
	
		nCnt := IIF(nCnt=0,nCnt:=1,nCnt)
	
		If nOpcao == 2		//visual		
			aCols := Array(nCnt, Len(aHeader))
		Else
			aCols := Array(nCnt, Len(aHeader) + 1)
		EndIf	
		
		nCnt := 0
		dbSelectArea("SQQ")
		dbSetOrder(1) 
	
		dbSeek(xFilial("SQQ")+M->QQ_TESTE)
		While !EOF() .And. xFilial("SQQ")+M->QQ_TESTE ==;
								 SQQ->(QQ_FILIAL+QQ_TESTE)
			nCnt++
			nUsado:=0
			dbSelectArea("SX3")
			dbSeek( cAlias )
			While !EOF() .And. x3_arquivo == cAlias
				If cNivel >= x3_nivel .And.;
					( ! Trim(SX3->X3_CAMPO) $ cString )
					nUsado++
					If x3_context # "V"
						aCols[nCnt][nUsado] := &(cAlias+"->"+x3_campo)
					ElseIf x3_context == "V"
						aCols[nCnt][nUsado] := CriaVar(AllTrim(x3_campo))
					EndIf
				EndIf
				dbSkip()
			EndDo
	
			dbSelectArea("SQQ") 
			Aadd(aColsRec,Recno())
			
			dbSkip()
		End
		            
		nPosItem	:= GdFieldPos("QQ_ITEM")
		
		If nPosItem > 0
			aCols:= aSort(aCols,,,{|x,y| x[nPosItem] < y[nPosItem]})
		EndIf
	Else	
		aCols := Array(1, Len(aHeader) + 1)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Array de 1 elemento ³
	//³ vazio. Se inclus†o.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpcao==3) .Or. Empty(aCols[1][1])		//Inclusao ou arquivo vazio
		dbSelectArea("SX3")
		dbSeek(cAlias)
		nUsado:=0
		While !EOF() .And. (x3_arquivo == cAlias)
			If cNivel >= x3_nivel .And.;
				( ! Trim(SX3->X3_CAMPO) $ cString )
				nUsado++
				If x3_tipo == "C"
					If Trim(aHeader[nUsado][2]) == "QQ_ITEM"
						aCols[1][nUsado] := Repl("0",x3_tamanho-1)+"1"
					Else
						aCols[1][nUsado] := SPACE(x3_tamanho)
					EndIf	
				ElseIf x3_tipo == "N"
					aCols[1][nUsado] := 0
				ElseIf x3_tipo == "D"
					aCols[1][nUsado] := CTOD("  /  /  ")
				ElseIf x3_tipo == "M"
					aCols[1][nUsado] := ""
				Else
					aCols[1][nUsado] := .F.
				EndIf
				If x3_context == "V"
					aCols[1][nUsado] := CriaVar(allTrim(x3_campo))
				EndIf
			EndIf
			dbSkip()
		End		
	EndIf
	
	If nOpcao # 2	//# visual
		For nI:=1 To Len(aCols)
			aCols[nI][Len(aHeader)+1] := .F.
		Next nI	
	EndIf	
	
	If nOpcao # 3	// # inclusao
		A040ListBox(.F.)
	Else
		aQual:={}
		A040Monta(OemtoAnsi(STR0011),"XX") //"----------- Questoes do Avaliacao -----------"
		A040Monta(space(250),"XX")
	EndIf
	
	RestArea(aSaveArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A040Avalia³ Autor ³ Marcelo Faria         ³ Data ³ 19.05.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica restricoes					               		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Avalia()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040Avalia()

	//Verifica obrigatoriedade para o campo servidor de conteudo
	//quando for um tipo e-learning e existir integracao com 
	//EPM e AMS Datasul
	If nOpcao == 3 .OR.; // inclusao
	   nOpcao == 4       // alteracao

    	If M->QQ_TIPO == "REA"
			If SuperGetMv("MV_TRMINTG", NIL, .F.)			
		    	If empty(M->QQ_SRVCNT)
					Aviso(OemToAnsi(STR0014),OemToAnsi(STR0015), {"Ok"})	//O servidor de conteudo e obrigatorio, quando tipo de
					Return .F.												//avaliacao e de reacao e existe integracao com o EPM/AMS Datasul!"
				Endif	
			Endif
		Endif		

	EndIf


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040Grava³ Autor ³ Cristina Ogura        ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os arquivos SQQ		               				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Grava()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040Grava(aColsRec)
	Local nx		:= 0
	Local ny		:= 0
	Local cVar		:= ""
	Local lFound	:= .T.
	Local cIndCond	:= ""
	Local cArqNtx	:= ""
	Local nItem		:= 0 
	Local cMsg		:= ""
	
	If nOpcao == 2     // Visual
		Return(.T.)
	EndIf
	
	If nOpcao == 5
		// Avaliacao do curriculo
		dbSelectArea("SQR")
		cIndCond	:= "QR_FILIAL + QR_TESTE"
		cArqNtx		:= CriaTrab(Nil,.F.)
		IndRegua("SQR",cArqNtx,cIndCond,,,STR0012) //"Selecionando Registros..."
		dbGoTop()
		If dbSeek(xFilial("SQQ")+M->QQ_TESTE)
			Help("",1,"A040HATESTE")			// Este teste nao pode ser excluido pois existem
			Return .F.							// esses testes cadastrado nos candidatos ou esta
		EndIf									// agendado para algum candidato.         
		RetIndex("SQR")
		FErase(cArqNtx+OrdBagExt())
		Set Filter to
		
		// Agenda das Avaliacoes
		dbSelectArea("SQD")
	    cIndCond	:= "QD_FILIAL + QD_TESTE"
	    cArqNtx  	:= CriaTrab(Nil,.F.)
	    IndRegua("SQD",cArqNtx,cIndCond,,,STR0012) //"Selecionando Registros..."
		dbGoTop()
		If dbSeek(xFilial("SQQ")+M->QQ_TESTE)
			Help("",1,"A040HATESTE")			// Esta questao nao pode ser excluida pois
			Return .F.							// existem testes com esta questao
		EndIf									// Verifique os testes com esta questao.
		RetIndex("SQD")
		FErase(cArqNtx+OrdBagExt())
		Set Filter to
	EndIf
	
	If nOpcao == 3
		nItem := 0								// Inclusao
		For nx := 1 to Len(aCols)
			If !aCols[nx][Len(aCols[nx])]		// Deletado
				nItem++
				RecLock("SQQ",.T.)
					For ny := 1 to Len(aHeader)
						If aHeader[ny][10] # "V"
							cVar := Trim(aHeader[ny][2])
							Replace &cVar. With aCols[nx][ny]
						EndIf
					Next ny
					
					Replace QQ_FILIAL	With xFilial("SQQ")
					Replace QQ_TESTE 	With M->QQ_TESTE
					Replace QQ_DESCRIC 	With M->QQ_DESCRIC
					Replace QQ_DURACAO	With M->QQ_DURACAO
					Replace QQ_TIPO		With M->QQ_TIPO
					Replace QQ_AREA     WITH M->QQ_AREA
					Replace QQ_TOPICO   WITH M->QQ_TOPICO

					If Type("M->QQ_SRVCNT") # "U"
						Replace QQ_SRVCNT  With M->QQ_SRVCNT
					EndIf
					Replace QQ_ITEM 	With StrZero(nItem,nTamItem)
				MsUnlock()	
			EndIf	
		Next nx	
	 
		
	ElseIf nOpcao == 5 				// Exclusao	
		dbSelectArea("SQQ")	
		dbSetOrder(1) 
	
		dbSeek(xFilial("SQQ")+M->QQ_TESTE)
		While !Eof() .And. xFilial("SQQ")+M->QQ_TESTE ==;
					  SQQ->QQ_FILIAL+SQQ->QQ_TESTE
			RecLock("SQQ",.F.,.T.)
				dbDelete()
			MsUnlock()
			dbSkip()
		End
		
	ElseIf nOpcao == 4				// Alteracao 
	
		dbSelectArea("SQQ")
		dbSetOrder(1) 
	
		nItem := 0	
		For nx := 1 to Len(aCols)
			If nx <= Len(aColsRec)
				dbGoto(aColsRec[nx])
				RecLock("SQQ",.F.)
				//--Verifica se esta deletado
				If aCols[nx][Len(aCols[nx])] 
					If !FkDelete(@cMsg)
						Aviso(Nil,cMsg,{"OK"}) 
						MsUnlock()
						Return .T.
					EndIf
					Loop
				EndIf
	
				Replace QQ_FILIAL	With xFilial("SQQ")
				Replace QQ_TESTE 	With M->QQ_TESTE
				Replace QQ_DESCRIC	With M->QQ_DESCRIC	
				Replace QQ_DURACAO 	With M->QQ_DURACAO
				Replace QQ_TIPO 	With M->QQ_TIPO

				If Type("M->QQ_SRVCNT") # "U"
					Replace QQ_SRVCNT  With M->QQ_SRVCNT
				EndIf
									
			Else
				//--Verifica se Nao esta Deletado no aCols
				If !aCols[nx][Len(aCols[nx])]  
					RecLock("SQQ",.T.)
						
					Replace QQ_FILIAL	With xFilial("SQQ")
					Replace QQ_TESTE 	With M->QQ_TESTE
					Replace QQ_DESCRIC	With M->QQ_DESCRIC	
					Replace QQ_DURACAO 	With M->QQ_DURACAO
					Replace QQ_TIPO 	With M->QQ_TIPO
										
					If Type("M->QQ_SRVCNT") # "U"
						Replace QQ_SRVCNT  With M->QQ_SRVCNT
					EndIf
					
				Else
					Loop
				EndIf
			EndIf
				 
			For ny := 1 To Len(aHeader)
				If aHeader[ny][10] # "V"
					cVar	:= Trim(aHeader[ny][2])
					&cVar 	:= aCols[nx][ny]
				EndIf	
			Next ny
			nItem++
			Replace QQ_ITEM 	With StrZero(nItem,nTamItem)
			Replace QQ_AREA     WITH M->QQ_AREA
			Replace QQ_TOPICO   WITH M->QQ_TOPICO
						
			MsUnlock()
		Next nx
	
	EndIf

	RSPA040EPMInt(nOpcao)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040LinOk³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Critica a linha da getdados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040LinOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040LinOk()
	Local nPosQuestao	:= 0
	Local ny			:= 0
	
	If Len(aCols) > 0
		For ny = 1 to Len(aHeader)
			If (Trim(aHeader[ny][2]) == "QQ_ITEM"  .Or.;
				 Trim(aHeader[ny][2]) == "QQ_QUESTAO") .And.;
				 Empty(aCols[n][ny]) .And.;
				 !aCols[n][Len(aCols[n])]
				 Help(" ",1,"A040VAZIO")
				 Return .F.
			EndIf
		Next ny
		
		nPosQuestao := GdFieldPos("QQ_QUESTAO")
		If nPosQuestao > 0	
			dbSelectArea("SQO")	
			dbSetOrder(1) 	
	
			If	!dbSeek(xFilial("SQO")+aCols[n][nPosQuestao]) .And. !aCols[n][Len(aCols[n])]
				Help("",1,"A040NQUESTAO")
				Return .F.
			EndIf	
		EndIf
	Else
		Help("",1,"A040NPODE")
	EndIf	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040TudOk³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Critica todas as linhas e colunas da getdados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040TudOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040TudOk()
	Local ny	:= 0
	Local lRet	:= .T.
	
	If Len(aCols) > 0
		For ny = 1 to Len(aHeader)
			If (Trim(aHeader[ny][2]) == "QQ_ITEM"  .Or.;
				 Trim(aHeader[ny][2]) == "QQ_QUESTAO") .And.;
				 Empty(aCols[n][ny]) .And.;
				 !aCols[n][Len(aCols[n])]
				 Help(" ",1,"A040VAZIO")
				 Return .F.
			EndIf
		Next ny
		
	Else
		Help("",1,"A040NPODE")
	EndIf	
	
	fTotQues(@lRet)
	
Return .T.
            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040Questao³ Autor ³ Cristina Ogura      ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Toda inclusao de questao e' atualizado o listbox           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Questao()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040Questao()
	Local cQuestao		:= &(ReadVar())
	Local nPosQuestao	:= 0
	Local nPosArea		:= 0
	Local nPosTopico	:= 0
	Local ny			:= 0
	nPosQuestao	:= GdFieldPos("QQ_QUESTAO")   
	nPosArea 	:= GdFieldPos("QQ_AREA")   
	nPosTopico 	:= GdFieldPos("QQ_TOPICO")   
	
	//Retorna Filtro do SQO (Questoes)      
	dbSelectArea("SQO")
	dbSetOrder(1) 	
	
	For ny := 1 To Len(aCols)
		If cQuestao == aCols[ny][nPosQuestao] .And.;
			n # ny .And.;
			!aCols[ny][Len(aCols[ny])]
			Help("",1,"A040JAEXISTE")	
			Return .F.
		EndIf	
	Next ny
	
	If !aCols[n][Len(aCols[n])]  
		
		dbSelectArea("SQO")	
		dbSetOrder(1) 	
				
		If !dbSeek(xFilial("SQO")+cQuestao)
			Help("",1,"A040NQUESTAO")
			Return .F.
		EndIf
	EndIf
	
	aCols[n][nPosQuestao] := SQO->QO_QUESTAO
	aCols[n][nPosTopico]  := SQO->QO_TOPICO
	aCols[n][nPosArea]    := SQO->QO_AREA
	
	// Monta o ListBox com a nova atualizacao
	A040ListBox(.T.)
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040Monta³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a linha do listbox com tamanho de 250 caracteres     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Monta(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Linha a ser mostrada no listbox					  ³±±
±±³          ³ ExpC2 := Chave do array aQual - tem tamanho de C 2 		  ³±±
±±³          ³          pode ser "XX" - desprezar        				  ³±±
±±³          ³                    99  - Numero do item da questao		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040Monta(cString,cChave)
	Local nTam	:= Len(cString)
	Local nDif	:= 0
	
	nDif 	:= 250 - nTam 						//Tamanho do Listbox
	cString := cString + space(nDif)
	Aadd(aQual,{cString,cChave,Len(aQual)+1})
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040Muda ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controla a mudancao de Folder                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Muda(ExpN1,ExpN2,ExpO1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 := Folder destino                    				  ³±±
±±³          ³ ExpN2 := Folder origem                             		  ³±±
±±³          ³ ExpO1 := Objeto do texto                  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040Muda(nIndo,nEstou,oTexto)
	Local lRetChg 	:= .T.
	Local cForSQO	:= ""
	Local cCondSQO	:= ""
	
	If ( nEstou == 1 )
		lRetChg 	:= Obrigatorio(aGets,aTela)
		cTexto		:= STR0013+M->QQ_TESTE+" - " + M->QQ_DESCRIC //"Avaliacao: "
		oTexto:Refresh()
		If nOpcao # 3	// # inclusao
			A040ListBox(.F.)
		EndIf      
		     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga Filtro do Arquivo de Questoes. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If File(cArqSQO+OrdBagExt())	
			dbSelectArea("SQO")
			Set Filter To
			RetIndex("SQO")
			dbSetOrder(1)
			FErase (cArqSQO+OrdBagExt())	
			nIndSQO := 1
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra Questoes de acordo com o Tipo da Avaliacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SQO")
		dbSetOrder(1)
	
		dbGoTop()
		cCondSQO	:= "QO_FILIAL+QO_QUESTAO"
		If !Empty(M->QQ_TIPO)
			cForSQO	:= 'QO_TIPO == "'+ M->QQ_TIPO +'"'
		Else 
			cForSQO	:= ''
		Endif
	
		cArqSQO  := CriaTrab(NIL,.F.)
		IndRegua("SQO",cArqSQO,cCondSQO,,cForSQO,,.F.)		//"Selecionando Registros..."
		nIndSQO := RetIndex("SQO")  
		dbSetOrder(1)			
	EndIf
Return lRetChg


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040Apaga³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apaga do listbox as linhas deletadas na getdados (CTRL DEL)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Apaga()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040Apaga()
	If nOpcao == 2 .Or. nOpcao == 5			// Visual e exclui
		Return .T.
	EndIf
	
	aCols[n][Len(aCols[n])] := !aCols[n][Len(aCols[n])]
	oGet01:oBrowse:Refresh()
	
	A040ListBox(.T.)
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040Escreve³ Autor ³ Cristina Ogura      ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Escreve as linhas no listbox conforme a getdados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Escreve(ExpC1,ExpC2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Codigo do Item                    				  ³±±
±±³          ³ ExpC2 := Codigo da Questao                         		  ³±±
±±³          ³ ExpC3 := Codigo da Area                            		  ³±±
±±³          ³ ExpC4 := Codigo da Topico                          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040Escreve(cItem,cQuestao)
	Local nNum 		:= 96
	Local nLinha	:= 0
	Local cDescric	:= ""
	Local i			:= 0
	
	dbSelectArea("SQO")				// Questao
	dbSetOrder(1) 	
	dbSeek(xFilial("SQO")+cQuestao)
	
	cDescric:= Alltrim(SQO->QO_QUEST)
	nLinha  := MLCount(cDescric,79)
	For i := 1 to nLinha
		A040Monta(IIF(i==1,cItem+" - ",Space(len(cItem)+3))+Memoline(cDescric,79,i),cItem)
	Next i	
	
	If Empty(SQO->QO_ESCALA)
	
		dbSelectArea("SQP")	// Alternativa (SQP)
		dbSetOrder(1)
		dbSeek(xFilial("SQP")+cQuestao)
		While !Eof() .And. xFilial("SQP")+cQuestao ==;
							QP_FILIAL+QP_QUESTAO
			
			cDescric:= Alltrim(SQP->QP_DESCRIC)
			nLinha	:= MLCount(cDescric,79)					
			nNum++
			For i := 1 To nLinha
				A040Monta(Space(03)+IIF(i==1,"("+CHR(nNum)+")- ",Space(05))+Memoline(cDescric,79,i),cItem)
			Next i
			dbSkip()
		EndDo
	
	Else	
	
		dbSelectArea("RBL")	// Escala (RBL) 
		dbSetOrder(1)
		dbSeek(xFilial("RBL")+SQO->QO_ESCALA)
		While !Eof() .And. xFilial("RBL")+SQO->QO_ESCALA ==;
							RBL_FILIAL+RBL_ESCALA
			
			cDescric:= Alltrim(RBL->RBL_DESCRI)
			nLinha	:= MLCount(cDescric,79)					
			nNum++
			For i := 1 To nLinha
				A040Monta(Space(03)+IIF(i==1,"("+CHR(nNum)+")- ",Space(05))+Memoline(cDescric,79,i),cItem)
			Next i	
			dbSkip()
		EndDo
	EndIf
		
	A040Monta(space(250),"XX")
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040Listbox ³ Autor ³ Cristina Ogura     ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o listbox                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Listbox(ExpF1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpF1 := Flag que indica se deve ser posicionado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040ListBox(lFlag)
	Local nPosQuestao	:= 0
	Local ny			:= 0
	Local nCont			:= 0
	
	aQual:={}
	A040Monta(OemtoAnsi(STR0011),"XX") //"----------- Questoes do Avaliacao -----------"
	A040Monta(space(250),"XX")
	A040Monta(STR0013+M->QQ_TESTE+" - "+M->QQ_DESCRIC,"XX") //"Avaliacao: "
	A040Monta(space(250),"XX")
	
	nPosQuestao := GdFieldPos("QQ_QUESTAO")
	
	For ny=1 To Len(aCols)
		nCont++	
		If nOpcao == 2			// Visual
			A040Escreve(StrZero(ny,nTamItem),aCols[ny][nPosQuestao])
		Else	
			If !aCols[ny][Len(aCols[ny])]
				A040Escreve(StrZero(nCont,nTamItem),aCols[ny][nPosQuestao])
			EndIf	
		EndIf	
	Next ny
	
	// Atualiza o ListBox
	If lFlag
		A040Posiciona()
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040Posiciona ³ Autor ³ Cristina Ogura   ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona na linha do listbox conforme inclusao na getdados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Posiciona()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040Posiciona()
	Local nPos		:= 0
	Local nPosItem 	:= 0
	
	If ( Len(aCols) > 0 )
		nPosItem:= GdFieldPos("QQ_ITEM")
		nPos 	:= Ascan(aQual,{|x| x[2] == aCols[n][nPosItem]})
		
		If nPos > 0 
			oQual:SetArray(aQual)
			oQual:nAt := aQual[nPos][3]
			oQual:bLine := { ||  { aQual[oQual:nAt,1]} }
			oQual:Refresh()
			oGet01:Refresh()
		Else
			oQual:SetArray(aQual)
			oQual:nAt := 1
			oQual:bLine := { || {aQual[oQual:nAt,1]}}
			oQual:Refresh()
			oGet01:Refresh()
		EndIf
	EndIf
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040SQO		 ³ Autor ³ Emerson Grassi   ³ Data ³ 06/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra Pesquisa SQO (SXB)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040SQO()        		                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040SQO()
	If Type("M->QQ_TIPO") != "U" .And. !Empty(M->QQ_TIPO)
		Return (SQO->QO_TIPO == M->QQ_TIPO)
	EndIf
Return .T.


/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³27/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA040                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   
Static Function MenuDef()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa 	 ³
	//³ ----------- Elementos contidos por dimensao ------------	 ³
	//³ 1. Nome a aparecer no cabecalho 							 ³
	//³ 2. Nome da Rotina associada 								 ³
	//³ 3. Usado pela rotina										 ³
	//³ 4. Tipo de Transa‡„o a ser efetuada 						 ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados			 ³
	//³    2 - Simplesmente Mostra os Campos						 ³
	//³    3 - Inclui registros no Bancos de Dados					 ³
	//³    4 - Altera o registro corrente							 ³
	//³    5 - Remove o registro corrente do Banco de Dados 		 ³
	//³    6 - Alteracao sem inclusao de registro                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aRotina :=  {	{ STR0001,"PesqBrw",	0 ,1,,.F.},; //"Pesquisa"
                    	{ STR0002,"RSP040Rot",	0 ,2 },; //"Visual"
                    	{ STR0003,"RSP040Rot",	0 ,3 },; //"Inclui"
                    	{ STR0004,"RSP040Rot",	0 ,4 },; //"Altera"
                    	{ STR0005,"RSP040Rot",	0 ,5 }}  //"Exclui"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} TRMA060EPMInt

@author Rogerio Ribeiro
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RSPA040EPMInt(nOpcao)
	Local oWSAvaliacao, oAvaliacao, oWSAvReacao, oAvReacao
	Local nOldSet 		:= SetVarNameLen(255)
	Local cCodAva 		:= SQQ->QQ_TESTE
	Local cFilAva 		:= SQQ->QQ_FILIAL
	Local cEmp    		:= ""
	Local cUni    		:= ""
	Local cFil	  		:= ""
	Local cPai    		:= ""
	Local cFilho  		:= ""

	Local nTamLayEmp  	:= len(FWSM0Layout(cEmpAnt,1))
	Local nTamLayUni  	:= len(FWSM0Layout(cEmpAnt,2))
	Local nTamLayFil  	:= len(FWSM0Layout(cEmpAnt,3))
	
	DBSelectArea("SQQ")
	DBSetOrder(1)
	dbSeek(cFilAva+cCodAva)

	If SuperGetMv("MV_TRMINTG", NIL, .F.)			
		oAvaliacao:= AvaliacaoWSService_AvaliacaoWSHolder():New()				

		If nOpcao == 3 .OR.; // inclusao
		   nOpcao == 4       // alteracao
			oAvaliacao:cCodigo	 		:= ""
			oAvaliacao:cCdExterno 		:= SQQ->QQ_FILIAL+SQQ->QQ_TESTE
			oAvaliacao:cDescricao 		:= AllTrim(SQQ->QQ_DESCRIC)
			oAvaliacao:cNome	 		:= AllTrim(SQQ->QQ_DESCRIC)
			oAvaliacao:cDuracao 		:= AllTrim(Str(fTimeToMinutes(SQQ->QQ_DURACAO)))
			If SQQ->QQ_TIPO != "REA"
				oAvaliacao:cPesquisa	:= "n"
			Else	
				oAvaliacao:cPesquisa	:= "y"		
			EndIf		


			//-----------------------------------		
			// Prepara relacionamento com unidade
			If Empty(SQQ->QQ_FILIAL)
	           cPai   := FWCodEmp() + FWunitBusiness() 
			   cFilho := FWCodFil()	
			else
				//Captura Empresa
				cEmp := substr(SQQ->QQ_FILIAL, 1, nTamLayEmp)
				//Captura Unidade
				cUni := substr(SQQ->QQ_FILIAL, nTamLayEmp+1, nTamLayUni)
				//Captura Filial
				cFil := substr(SQQ->QQ_FILIAL, nTamLayEmp+nTamLayUni+1, nTamLayFil)
		        
		 		// Tratamento para Gestao de Empresas //
		 		
		 		If nTamLayEmp > 0 .Or. nTamLayUni > 0
			        //Identifica Pai-Filho para Filial SQ0
					If !Empty(cFil) .and. cFil <> Nil
						cPai   := cEmp+cUni
						cFilho := cEmp+cUni+cFil
					Else 
						If !Empty(cUni) .and. cUni <> Nil
							cPai   := cEmp
							cFilho := cEmp+cUni
						Else
							If !Empty(cEmp) .and. cEmp <> Nil
								cPai   := FWGrpCompany()
								cFilho := cEmp
							EndIf
						EndIf
					Endif
				Else
					cPai	 	:= FWGrpCompany()
		   			cFilho 		:= SQQ->QQ_FILIAL	
		        EndIf     
		    EndIf    
		
			oAvaliacao:oWSListaUnidade										:= AvaliacaoWSService_ListaUnidadeWSHolder():New()
			oAvaliacao:oWSListaUnidade:oWSUnidade							:= {}
	
			AAdd(oAvaliacao:oWSListaUnidade:oWSUnidade, AvaliacaoWSService_UnidadeWSHolder():New())
			oAvaliacao:oWSListaUnidade:oWSUnidade[1]:cCdUnidadePaiExterno	:= cPai
			oAvaliacao:oWSListaUnidade:oWSUnidade[1]:cCdUnidadeFilhoExterno	:= cFilho
			//---------------------------
	

			//---------------------------		
	        // Questoes da avaliacao
			//---------------------------        
			oAvaliacao:oWSListaQuestao:= AvaliacaoWSService_ListaQuestaoWSHolder():New()
			oAvaliacao:oWSListaQuestao:oWSQuestao:= {}	
			While !SQQ->(EOF()) .AND.;
					cFilAva == SQQ->QQ_FILIAL  .AND.;
					cCodAva == SQQ->QQ_TESTE
				
				oQuestao:= AvaliacaoWSService_QuestaoWSHolder():New()
				oQuestao:cCdExterno:= SQQ->QQ_FILIAL+SQQ->QQ_QUESTAO
	
				AAdd(oAvaliacao:oWSListaQuestao:oWSQuestao, oQuestao)
	
				SQQ->(DBSkip())
			EndDo
			//---------------------------
		
	
			oWSAvaliacao:= AMSWSNew("Avaliacao")
			If !oWSAvaliacao:insertAvaliacao(oAvaliacao)
				Alert("Nao foi possivel gravar a avaliacao!" + Chr(10) + Chr(13)+ GetWSCError())
			EndIF		
					
			SQQ->(DBSeek(cFilAva + cCodAva))
			
			If SQQ->QQ_TIPO == "REA"	
				oAvReacao:= AvaliacaoReacaoWSService_AvaliacaoReacaoWSHolder():New()					
				oAvReacao:cCdExterno 					:= SQQ->QQ_FILIAL+SQQ->QQ_TESTE
				oAvReacao:cUrl 							:= SQQ->QQ_FILIAL+AllTrim(SQQ->QQ_TESTE)
				oAvReacao:cTipoPesquisa 				:= "1"
				oAvReacao:cTitulo						:= AllTrim(SQQ->QQ_DESCRIC)
				oAvReacao:cCdServidorConteudoExterno 	:= AllTrim(SQQ->QQ_SRVCNT)
	
				oWSAvReacao:= EPMWSNew("AvaliacaoReacao")
				If !oWSAvReacao:insertAvaliacaoReacao(oAvReacao)
					Alert("Nao foi possivel gravar a avaliacao de reacao!" + Chr(10) + Chr(13)+ GetWSCError())
				EndIF		
			EndIf	
		
		ElseIf nOpcao == 5
				oWSAvaliacao:= AMSWSNew("Avaliacao")
				If !oWSAvaliacao:deleteAvaliacao( M->QQ_FILIAL+M->QQ_TESTE )
					Alert("Nao foi possivel excluir no EPM a avaliacao!" + Chr(10) + Chr(13)+ GetWSCError())
				EndIF		
						
				If M->QQ_TIPO == "REA"	
					oWSAvReacao:= EPMWSNew("AvaliacaoReacao")
					If !oWSAvReacao:deleteAvaliacaoReacao( M->QQ_FILIAL+M->QQ_TESTE )
						Alert("Nao foi possivel excluir no EPM a avaliacao de reacao!" + Chr(10) + Chr(13)+ GetWSCError())
					EndIF		
				EndIf
			Endif
		EndIf		
	
	SetVarNameLen(nOldSet)	
Return


Static Function fTimeToMinutes(cTime)
	Local nHours
	Local nMinutes
	Local nReturn
	
	ExtractTime(cTime, @nHours, @nMinutes)
	
	nReturn:= (nHours * 60) + nMinutes
Return nReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fTotQues³ Autor ³ Mariana Moraes        ³ Data ³ 02.03.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o valor total ultrapassa o tamanho do campo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fTotQues()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA040  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function fTotQues(lRet)

Local nLimValor	:= Val( Replicate( "9", ( TamSx3("QO_PONTOS")[1] - ( TamSx3("QO_PONTOS")[2] + 1 ) ) ) + "." + Replicate("9",TamSx3("QO_PONTOS")[2]))
Local nPontos 	:= 0
Local n			:= 0
 
dbSelectArea("SQO")
dbSetOrder(1)
For n := 1 to Len(aCols)
	If !aCols[n][Len(aCols[n])]
		If dbSeek(xFilial("SQO",cFilAnt)+aCols[n][2])
			nPontos+= SQO->QO_PONTOS
			If nPontos > nLimValor
				MsgAlert(STR0016)
				lRet := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next

Return lRet