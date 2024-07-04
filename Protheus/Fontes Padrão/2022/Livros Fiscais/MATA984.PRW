#Include "PROTHEUS.CH"
#Include "FILEIO.CH"
#Include "APWIZARD.CH"
#Include "MATA984.CH"

#DEFINE INCLUIR 1
#DEFINE ALTERAR 2

Static aRecnos := {} //Ira armazenar os RECNOS dos registros que serão alterados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA984  ³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Facilitador generico de atualizacao para cadastros.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. ou  .F.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias da tabela a ser processada.                 ³±±
±±³          ³cExpApFim -> Expressao a ser apresentado ao final da atuali-³±±
±±³          ³ zacao. Deve conter somente campos da tabela envolvida. Ex: ³±±
±±³          ³ 'B1_COD+" - "+B1_DESC'                                     ³±±
±±³          ³cCampos -> Campos permitidos para alteracao separados por   ³±±
±±³          ³ "/".                                                       ³±±
±±³          ³aTxtApre -> Texto de apresentacao inicial do assistente da  ³±±
±±³          ³ rotina. Deve ser no formato de array. Ex:                  ³±±
±±³          ³ aTxtApre	:=	{}                                            ³±±
±±³          ³ aAdd(aTxtApre, "1")                                        ³±±
±±³          ³ aAdd(aTxtApre, "2")                                        ³±±
±±³          ³ aAdd(aTxtApre, "3")                                        ³±±
±±³          ³ aAdd(aTxtApre, "4")                                        ³±±
±±³          ³cPosiciona -> Funcao de posicione que pode ser passada para ³±±
±±³          ³ apresentacao da mensagem de conclusao.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATA984(cAlias, cExpApFim, cCampos, aTxtApre,cPosiciona)
Local 	aArea 		:=	GetArea()
Local	lRet		:=	.F.
Local	nInd  		:=	0
Local	aPaineis	:=	{}
Local	cTitTabela	:=	""
Local	aList		:=	{}
Local	aList2		:=	{}
Local	cDescFiltro	:=	""
Local	nOpc		:=	INCLUIR
Local	cFil		:=	""
Local 	oWnd		:= GetWndDefault()
Local	oGetDad
Local	aResumo		:=	{"","","",""}
Local	lFim		:=	.F.
Local	oDescFiltro
Local	oFont
Local	oWizard
Local	oTree
Local	oTWBrow
Local	oMSSelect
Local	cMemo		:=	STR0056	//"Confira o resumo clicando em umas das opções à esquerda."
Local	oMemo
Local	cTexto		:=	STR0047+CRLF+CRLF	//"Relação de produtos processados."
Local	cFileLog	:=	""
Local	cFile		:=	""
Local 	cMask     	:= STR0048+" (*.TXT) |*.txt|"	//"Arquivos Texto"
Local	oDlgFinal
Local	cProcura	:=	Space(50)
Local	aTrb		:=	{}
Local	aCpos		:=	{}
Local	cMarca		:=	GetMark ()
Local	lInverte	:=	.F.
Local	c2Procura	:=	Space(50)
Local	o2Procura
Local	cCdBlock	:=	""
Local	aCampos		:=	{}
Local	aIndKey		:=	{}
Local	cDesc		:=	""
Local	lGerou		:=	.F.   
Local   oOk   	    := LoadBitmap( GetResources(), "LBOK")
Local   oNo	        := LoadBitmap( GetResources(), "LBNO")  

Private aAlterRot   := {}
Private	aColsWiz	:= {}
Private	aHeadWiz	:= {}

Private lMSErroAuto := .F.
Private cGetDB		:= TcGetDb()

Default	cExpApFim	:=	""
Default	cPosiciona	:=	""

cAlias	:=	Upper(cAlias)
 
If cAlias<>Nil .And. AliasIndic(cAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento da tabela a ser processada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitTabela 	:=	AllTrim(FWX2Nome(cAlias))
	aIndKey		:=	&("{'"+StrTran(AllTrim(FWX2Unico(cAlias)),"+","','")+"'}")
	aDel(aIndKey,1)
	aSize(aIndKey,Len(aIndKey)-1)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Verificacao dos campos permitidos passados por parametros, caso contrario, ³
	//³	  utilizo todos da tabela de referencia.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !Eof() .And. X3_ARQUIVO==cAlias
		If X3USO(X3_USADO) .And. !X3_CONTEXT=="V" .And. !X3_NIVEL > cNivel 		
			If (cCampos==Nil .Or. AllTrim(X3_CAMPO)+"/"$cCampos .Or. Empty(cCampos))
				aAdd(aList,{.F.,AllTrim(X3_CAMPO), AllTrim(RetTitle(X3_CAMPO))})
			EndIf
			aAdd(aList2,{AllTrim(X3_CAMPO),AllTrim(RetTitle(X3_CAMPO))})
		EndIf
		dbSkip()
	End
       
	If Len(aList)>0	//Somente quando exisirem campos validos.
		lRet		:=	.T.
		aSort(aList,,,{|x,y|x[1]<y[1]})
		aSort(aList2,,,{|x,y|x[1]<y[1]})
		
		aTrb	:=	MontTrb(1,aList2)
		aCpos 	:= 	{{"TRB_OK"  , 	"", OemToAnsi (STR0057),	""},;	//"Seleção"
				{"TRB_CMP1",		"", OemToAnsi (STR0058),  	""},;	//"Campo"
				{"TRB_CMP2", 		"", OemToAnsi (STR0059), 	""}}	//"Descrição"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Texto padrao caso nao seja passado por parametro.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTxtApre==Nil .Or. Len(aTxtApre)<>4
			aTxtApre	:=	{}
			aAdd(aTxtApre, STR0001)										//"Facilitador..."
			aAdd(aTxtApre, STR0002+AllTrim(cAlias)+" - "+cTitTabela)	//"Facilitador da tabela: "
			aAdd(aTxtApre, "")
			aAdd(aTxtApre, STR0003)										//"Este facilitador tem como objetivo, como o próprio nome diz, facilitar a manutenção das informações cadastrais de determinadas tabelas conforme critérios definidos na execução do assistente da rotina."
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao dos paineis de apresentacao da rotina, estes paineis sao ³
		//³  padroes, com textos padroes.                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesc	:=	STR0004						  						//"Ao selecionarmos um campo entre os apresentados abaixo, estaremos indicando que o mesmo será atualizado posteriormente conforme edição do quadro 4/5 deste assistente. Esta rotina destina-se a facilitar uma atualização em massa conforme filtros e quebras informados posteriormente."
		aAdd(aPaineis,{STR0005, STR0006, cDesc}) 						//"Informação a ser editada..."###"1/6 - Neste passo seleciona-se a informação que se deseja alterar no respectivo cadastro."
	
		cDesc	:=	STR0007						 						//"Ao selecionarmos um filtro para o processamento da rotina, estaremos indicando que os registros que satisfizerem a condição definida abaixo serão excluídas do montante e não sofrerão nenhuma atualização."
		aAdd(aPaineis,{STR0008, STR0009, cDesc}) 						//"Filtro..."###"2/6 - Neste passo é possível efetuar um filtro no referido cadastro de forma a restringir as alterações em critérios específicos."
		
		cDesc	:=	STR0010						  						//"Ao selecionarmos um campo neste passo, estamos indicando que a atualização deverá proceder pelo grupo selecionado, ou seja, se selecionarmos o campo B1_POSIPI, estaremos informando que todos os registros que possuírem o mesmo conteúdo no campo B1_POSIPI deverá receber a mesma atualização."
		aAdd(aPaineis,{STR0011, STR0012, cDesc})						//"Grupo..."###"3/6 - Neste passo podemos condicionar a atualização por um determinado grupo, ou seja, informações comuns para atualização em grupo."
	
		cDesc	:=	STR0013						   						//"Este quadro tem como objetivo permitir a manutenção das informações pré-configuradas anteriormente através da edição do browse."
		aAdd(aPaineis,{STR0014, STR0015, cDesc})						//"Edição..."###"4/6 - Neste passo podemos efetuar as atualizações das informações pré-configuradas anteriormente."
	
		cDesc	:=	STR0016+AllTrim(cAlias)+" - "+cTitTabela+STR0017	//"Este quadro tem como objetivo resumir o processamento que será efetuado na tabela ["###"] para que seja possível uma validação no processo antes de sua execução."
		aAdd(aPaineis,{STR0018, STR0019, cDesc})						//"Resumo..."###"5/6 - Neste passo podemos ou não confirmar as alterações conforme resumo apresentado antes de sua execução."
		
	
	
	
		Define FONT oFont NAME "Arial" SIZE 0, -11
		Define FONT oFontB NAME "Arial" SIZE 0, -11 BOLD
	
		Define WIZARD oWizard ;
			TITLE SubStr (aTxtApre[1], 1, 80);
			HEADER SubStr (aTxtApre[2], 1, 80);
			MESSAGE SubStr (aTxtApre[3], 1, 80);
			TEXT aTxtApre[4];
			NEXT {||  .T.};
			FINISH {|| .T.}
	
		For nInd := 1 To Len (aPaineis)
			CREATE PANEL oWizard  ;
				HEADER aPaineis[nInd][1];
				MESSAGE aPaineis[nInd][2];
				BACK {|| BkPainel(oWizard,oTree,@cMemo)} ;
				NEXT {|| ValPainel(oWizard,oTWBrow,cAlias,cFil,@oGetDad,@aResumo,cTitTabela,cDescFiltro,cMarca,@cCdBlock,@aCampos,oTree,@aIndKey)};
				FINISH {|| lFim := MSGYESNO(STR0038,STR0037)}	//"Confirma atualização em massa conforme apresentação no quadro de resumo ?"###"Atenção"
			
			If nInd==1
				TSay ():New (05, 05, &("{||aPaineis["+AllTrim(Str(nInd))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)

				@29,05 TO 132,282 LABEL STR0020 OF oWizard:oMPanel[nInd+1] PIXEL	//"Campo a ser editado"
				oTWBrow := TWBrowse():New(54,10,266,66 ,,{" ",STR0054,STR0055},{20,30,30},oWizard:oMPanel[nInd+1],,,,,,,,,,,,.F.,,.T.,,.F.,,,)	//"Campo"###"Descrição"
				oTWBrow:SetArray(aList)          
	            oTWBrow:bLine := {||{If(aList[oTWBrow:nAt,01],oOK,oNO),aList[oTWBrow:nAt,02],aList[oTWBrow:nAt,03]} }

			    // Troca a imagem no duplo click do mouse
			    oTWBrow:bLDblClick := {|| aList[oTWBrow:nAt][1] := !aList[oTWBrow:nAt][1],; 
		        oTWBrow:DrawSelect()}
	            
	            TSay ():New (40, 150, {||STR0050}, oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T.,,, 100, 10, .F., .F., .F., .F., .F.)	//"Pesquisar"
	            TGet ():New (38, 176, {|u| Iif(PCount()==0,cProcura,cProcura:=u)}, oWizard:oMPanel[nInd+1], 100, 9, "@!",{||Procura(1,oTWBrow,cProcura,aList)},,,,,, .T.)
				
			ElseIf nInd==2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Filtro para a selecao dos registros da entidade³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TSay ():New (05, 05, &("{||aPaineis["+AllTrim(Str(nInd))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)
				
				@40,05 TO 132,250 LABEL STR0021 OF oWizard:oMPanel[nInd+1] PIXEL	//"Filtro"
				@50,10 GET oDescFiltro VAR cDescFiltro MEMO SIZE 235,74 OF oWizard:oMPanel[nInd+1] PIXEL READONLY
				
				DEFINE SBUTTON FROM 44,255  TYPE 17 ENABLE OF oWizard:oMPanel[nInd+1] ACTION (cFil  := BuildExpr(cAlias,oWnd,cFil),;
						cDescFiltro := MontDescr(cAlias,cFil),;
						oDescFiltro:Refresh()) WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR)//Monta o filtro
			
			ElseIf nInd==3
				TSay ():New (05, 05, &("{||aPaineis["+AllTrim(Str(nInd))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)
				
				@35,05 TO 132,282 LABEL STR0022 OF oWizard:oMPanel[nInd+1] PIXEL	//"Grupo"
				oMSSelect	:=	MsSelect():New ("TRB", "TRB_OK",,aCpos, @lInverte, @cMarca, {60, 10, 126, 276},,,oWizard:oMPanel[nInd+1])
				oMSSelect:oBrowse:lHasMark 	:= 	.f.
				oMSSelect:oBrowse:lCanAllMark	:=	.f.

				TButton ():New (45, 10, OemToAnsi (STR0052), oWizard:oMPanel[nInd+1], {||Expande(@cMarca,aCpos,@lInverte,aList2,oFont)}, 30, 11,, /*oWizard:oMPanel[nInd+1]*/, .F., .T., .F.,, .F.,,, .F.)	//"Expandir"
				
				TSay ():New (46, 150, {||STR0050}, oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T.,,, 100, 10, .F., .F., .F., .F., .F.)	//"Pesquisar"
				o2Procura := TGet ():New (44, 176, {|u| Iif(PCount()==0,c2Procura,c2Procura:=u)}, oWizard:oMPanel[nInd+1], 100, 9, "@!",{||Procura(2,oMSSelect,c2Procura,aList2)},,,,,, .T.)
				
			ElseIf nInd==5
				TSay ():New (05, 05, &("{||aPaineis["+AllTrim(Str(nInd))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 30, .F., .F., .F., .F., .F.)
				
				@40,05 TO 132,282 LABEL STR0023 OF oWizard:oMPanel[nInd+1] PIXEL	//"Resumo"
				@ 50,120 GET oMemo VAR cMemo MEMO SIZE 156,77 OF oWizard:oMPanel[nInd+1] PIXEL READONLY
				
				oTree	:=	DbTree():New(50, 10, 127, 115, oWizard:oMPanel[nInd+1],,,.T.)
				oTree:AddItem(PadR(STR0023,20), "L1"+StrZero (0, 2, 0), 'FOLDER5','FOLDER6',,,1)	//"Resumo"
	
				oTree:TreeSeek("L1"+StrZero (0, 2, 0))
				oTree:AddItem (STR0020, "L2"+StrZero (1, 2, 0), 'PMSEDT3','PMSEDT3',,,2)	//"Cps à serem editados"
				oTree:AddItem (STR0021, "L2"+StrZero (2, 2, 0), 'PMSEDT3','PMSEDT3',,,2)	//"Filtro"
				oTree:AddItem (STR0022, "L2"+StrZero (3, 2, 0), 'PMSEDT3','PMSEDT3',,,2)	//"Grupo"
				
				oTree:lShowHint := .T.
				oTree:bLClicked := {|| MontClick(oTree, @cMemo, aResumo)}		
			EndIf
		Next (nInd)
		
		Activate WIZARD oWizard Centered
		
		If lFim
			//-- Processando atualização da tabela de cadastro.
			cFileLog := Criatrab(,.f.)+".LOG"
			Processa({|lEnd| lGerou := Atualiza(aCampos,oGetDad,cAlias,cFil,@cTexto,cExpApFim,cPosiciona,cCdBlock,aIndKey,cFileLog)},OemToAnsi(STR0045),OemToAnsi(STR0046),.F.) //"Atualização..."###"Processando atualização"

			If lGerou
				cTexto += CRLF
				cTexto += STR0061+cFileLog+"." //"Foi criado uma cópia do conteúdo apresentado na tela no diretório STARTPATH do sistema, arquivo "+cFileLog+"."
			Else
				cTexto += STR0029 //"Nenhum"
				cTexto += CRLF+CRLF
				cTexto += STR0062 //"STATUS: Atualização NÃO efetuada, pois NÃO HOUVE alteração."
			EndIf
			SaveLog(cFileLog,cTexto)

			DEFINE MSDIALOG oDlgFinal TITLE STR0051 From 3,0 to 340,417 PIXEL //"Atualizacao concluida."
			@ 5,5 GET oMemo VAR cTexto MEMO SIZE 200,145 OF oDlgFinal PIXEL READONLY
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont
			DEFINE SBUTTON FROM 153,175 TYPE  1 ACTION oDlgFinal:End() ENABLE OF oDlgFinal PIXEL //Apaga
			DEFINE SBUTTON FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlgFinal PIXEL //Salva e Apaga //"Salvar Como..."
			ACTIVATE MSDIALOG oDlgFinal CENTER
		EndIf
		MontTrb(2, aList2, aTrb)
		dbSelectArea(cAlias)
		dbGoTop()
	EndIf
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Expande  ³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de maximizacao do browse de selecao do agrupamento. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMarca -> Retorno da funcao GETMARK().                      ³±±
±±³          ³aCpos -> Campos do arquivo de trabalho para montagem do     ³±±
±±³          ³ browse.                                                    ³±±
±±³          ³lInverte -> Flag de selecao de registros do browse          ³±±
±±³          ³aList2 -> Array com todos os campos de usuario da tabela en-³±±
±±³          ³ volvida.                                                   ³±±
±±³          ³oFont -> Objeto de FONT padrao da rotina.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Expande (cMarca,aCpos,lInverte,aList2,oFont)
Local	oDlg
Local	lRet		:=	.T.
Local	oMSSelect
Local	cProcura	:=	Space(50)

DEFINE MSDIALOG oDlg FROM 0, 0 TO 480, 640 TITLE OemToAnsi (STR0022) PIXEL 	//"Grupo"
@ 4,5 TO 236,316 LABEL STR0022 OF oDlg PIXEL	//"Grupo"
oMSSelect	:=	MsSelect():New ("TRB", "TRB_OK",,aCpos, @lInverte, @cMarca, {30, 12, 230, 310},,,oDlg)
oMSSelect:oBrowse:lHasMark 		:= 	.f.
oMSSelect:oBrowse:lCanAllMark	:=	.f.

TButton ():New (15, 12, OemToAnsi (STR0053), oDlg, {||oDlg:End()}, 30, 11,, /*oDlg*/, .F., .T., .F.,, .F.,,, .F.)	//"Fechar"

TSay ():New (15, 185, {||STR0050}, oDlg,,oFont,.F.,.F.,.F., .T.,,, 100, 10, .F., .F., .F., .F., .F.)	//"Pesquisar"
TGet ():New (14, 211, {|u| Iif(PCount()==0,cProcura,cProcura:=u)}, oDlg, 100, 9, "@!",{||Procura(2,oMSSelect,cProcura,aList2)},,,,,, .T.)

ACTIVATE MSDIALOG oDlg CENTERED

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontTrb  ³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de criaca/exclusao do arquivo de trabalho utilizado  ³±±
±±³          ³ na montagem do browse de selecao do agrupamento.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpcao -> Opcao de chamada da funcao. 1=Cria/2=Exclui.      ³±±
±±³          ³aList2 -> Array com todos os campos de usuario da tabela en-³±±
±±³          ³ volvida.                                                   ³±±
±±³          ³aTrb -> Array com o arquivo de trabalho criado.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontTrb(nOpcao, aList2, aTrb)
Local	aStru	:=	{}
Local	cArq	:=	""
Local	nI		:=	0

Default	aTrb	:=	{}

If (nOpcao==1)
	aAdd(aStru,{"TRB_OK",	"C",	002,					0})
	aAdd(aStru,{"TRB_CMP1",	"C",	Len(SX3->X3_CAMPO),		0})
	aAdd(aStru,{"TRB_CMP2",	"C",	Len(SX3->X3_DESCRIC),	0})
	
	cArq	:=	CriaTrab(aStru)
	dbUseArea(.T., __LocalDriver, cArq, "TRB")
	IndRegua("TRB", cArq, "TRB_CMP1")
	
	aTrb	:=	{"TRB",cArq}
	
	For nI := 1 To Len(aList2)
		RecLock("TRB", .T.)
			TRB->TRB_CMP1	:=	aList2[nI,1]
			TRB->TRB_CMP2	:=	aList2[nI,2]
		MsUnLock()
	Next nI
	dbGoTop()
Else
	DbSelectArea (aTrb[1])
		(aTrb[1])->(DbCloseArea ())
	Ferase (aTrb[2]+GetDBExtension ())
	Ferase (aTrb[2]+OrdBagExt ())
EndIf

Return aTrb
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Procura  ³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de pesquisa nos assistentes de selecao de campos da  ³±±
±±³          ³ rotina.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpcao -> Opcao de chamada da funcao. 1=Primeiro assistente/³±±
±±³          ³ 2=Segundo assistente.                                      ³±±
±±³          ³ volvida.                                                   ³±±
±±³          ³oObj -> Objeto de pesquisa criado.                          ³±±
±±³          ³cProcura -> Conteudo de pesquisa digitado.                  ³±±
±±³          ³aList -> Array com os itens a pesquisar.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Procura(nOpcao,oObj,cProcura,aList) 
Local	lRet		:=	.T.
Local	nPos		:=	0

//Pesquiso pelo nome do campo
nPos	:=	aScan(aList,{|aX| AllTrim(cProcura)==Left(aX[2],Len(AllTrim(cProcura)))})

If nOpcao==1
	oObj:nAT := Iif(nPos==0,1,nPos)
	oObj:Refresh()
Else
	dbSelectArea("TRB")
	TRB->(dbSeek(AllTrim(cProcura)))
	oObj:oBrowse:Refresh()
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ValPainel³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao das trocas de paineis do wizard.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. ou  .F.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oWizard -> Objeto wizard.                                   ³±±
±±³          ³oTWBrow -> Objeto o Browse de selecao do campo a ser alterado³±±
±±³          ³cAlias -> Alias da tabela de referencia.                    ³±±
±±³          ³cFil -> Filtro selecionado no assistente da rotina.         ³±±
±±³          ³oGetDad -> Objeto getdados do browse de atualizacao da rotina³±±
±±³          ³aResumo -> Textos do resumo final apresentado antes de      ³±±
±±³          ³ iniciar a atualizacao.                                     ³±±
±±³          ³cTitTabela -> Titulo da tabela em processamento.            ³±±
±±³          ³cDescFiltro -> Descricao por extenso do filtro selecionado. ³±±
±±³          ³cMarca -> Retorno do GETMARK()                              ³±±
±±³          ³cCdBlock -> Codeblock de verificacao do produto para altera-³±±
±±³          ³ cao.                                                       ³±±
±±³          ³cCampo -> Nome do campo que podera ser atualizado.          ³±±
±±³          ³oTree -> Objeto do TREE apresentado no resumo do processamento³±±
±±³          ³aIndKey -> Campos chave da tabela baseado no indice caso nao³±±
±±³          ³ seja selecionado nenhum campo no agrupamento para edicao.  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValPainel(oWizard,oTWBrow,cAlias,cFil,oGetDad,aResumo,cTitTabela,cDescFiltro,cMarca,cCdBlock,aCampos,oTree,aIndKey)
Local	lRet	:=	.T.
Local	nI		:=	0 
Local   nX		:=	0 
Local   nHead	:=	0 

if oWizard:NPANEL==3
	IF Empty(cFil)
		MsgAlert(STR0065) // "Preencha o filtro."
		lRet := .F.
	ENDIF
ElseIf oWizard:NPANEL==4
	Processa({|lEnd| lRet := ProcWiz(oWizard,oTWBrow,cAlias,cFil,@oGetDad,cMarca,@cCdBlock,@aCampos,@aIndKey)},OemToAnsi(STR0045),OemToAnsi(STR0046),.F.) //"Atualização..."###"Processando atualização"
	If !lRet
		MsgAlert(STR0049)	//"Não foi encontrado registro(s) para posteriores atualizações. Verifique as configurações fornecidas no asssitente da rotina nos quadros anteriores."
	Else
		TRB->(dbGoTop())
	EndIf

ElseIf oWizard:NPANEL==5 .And. oGetDad<>Nil .And. Len(oGetDad:aCols)>0
	aResumo		:=	{"","","",""}
    
	aResumo[1]	+=	STR0056	//"Confira o resumo clicando em umas das opções à esquerda."
	
	aResumo[2]	+=	STR0025 //Os conteúdos inseridos nos campos  
	
	For nX:= 1 To Len(aCampos)
		nHead:= aScan(aheadwiz,{|aX| aX[2]==aAlterRot[nX]})
		aResumo[2]	+= oGetDad:aHeader[nHead,1]+", " //'"###"'
	Next nX

	aResumo[2]	+= STR0026+AllTrim(cAlias)+" - "+cTitTabela+STR0027  //(browse do quadro 4/5) serão gravados na tabela '"###"' (campos
   
	For nX:= 1 To Len(aCampos)
		nHead:= aScan(aheadwiz,{|aX| aX[2]==aAlterRot[nX]})
		aResumo[2]	+= oGetDad:aHeader[nHead-1,1]+", "	//'"###"'), 
	Next nX

	aResumo[2]	+= STR0028 //confirmando a alteração deste processo."

	If(Empty(cFil))
		aResumo[3]	+=	STR0029		//"Nenhum"
	Else
		aResumo[3]	+=	STR0030+AllTrim(cAlias)+" - "+cTitTabela+STR0031+AllTrim(cDescFiltro)+STR0032		//"Foi selecionado um filtro no assistente da rotina, indentificando que os registros da tabela '"###"' que satisfaçam a condição '"###"' NÃO deverão sofrer atualização durante o processamento da rotina."
	EndIf
	
	aResumo[4]	+=	STR0033+AllTrim(cAlias)+" - "+cTitTabela+STR0034	//"Neste processo de atualização temos um agrupamento de registros da tabela '"###"' por '"
	For nI := 1 To Len(oGetDad:aHeader)
		If !( STR0064 $ oGetDad:aHeader[nI,1])
			aResumo[4]	+=	StrTran(oGetDad:aHeader[nI,1]+", ",STR0063,"")//##############
		EndIf
	Next nI
	aResumo[4]	+=	STR0036	//este agrupamento será respeitado no momento da atualização, onde as informações editadas no quadro anterior (4/5) serão mantidas e atualizadas conforme agrupamento apresentado.

	oTree:TreeSeek("L1"+StrZero (0, 2, 0))
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Atualiza  ³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de atualizacao da tabela envolvida.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. ou  .F.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oWizard -> Objeto wizard.                                   ³±±
±±³          ³aList -> Array com campos validos para atualizacao.         ³±±
±±³          ³aList2 -> Array com todos os campos da tabela em questao.   ³±±
±±³          ³nList -> Posicao do listbox de campos a serem atualizados.  ³±±
±±³          ³cAlias -> Alias da tabela de referencia.                    ³±±
±±³          ³cFil -> Filtro selecionado no assistente da rotina.         ³±±
±±³          ³oGetDad -> Objeto getdados do browse de atualizacao da rotina³±±
±±³          ³cTexto -> Texto contendo o os registros atualizados.        ³±±
±±³          ³cExpApFim -> Expressao utilizada para montar o texto ao final³±±
±±³          ³ do processo de atualizacao.                                ³±±
±±³          ³aIndKey -> Campos chave da tabela baseado no indice caso nao³±±
±±³          ³ seja selecionado nenhum campo no agrupamento para edicao.  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Atualiza(aCampos,oGetDad,cAlias,cFil,cTexto,cExpApFim,cPosiciona,cCdBlock,aIndKey,cFileLog)

Local aAreaSX3		:= SX3->( GetArea() )
Local nPos			:= 0
Local lRet			:= .F.
Local aRotAut		:= {}
Local aArea			:= {}
Local aAreaAnt		:= {}
Local cAliasAnt		:= cAlias
Local nI			:= 0
Local cValor		:= ""
Local cValSeek		:= ""
Local cLinha		:= ""
Local nX			:= 0
Local nHead			:= 0
Local nAux			:= 0
Local aRotAut	    := {}
Local nRec			:= 0

aColsWiz	:=	oGetDad:aCols

DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))
aAreaAnt	:= (cAliasAnt)->(GetArea())

ProcRegua(Len(aRecnos))

For nRec := 1 to Len(aRecnos)
	(cAlias)->(DbGoto(aRecnos[nRec]))
	
	lMSErroAuto := .F.
	
	aArea := (GetArea())
	For nX:= 1 To Len(aCampos)

		nHead:= aScan(aheadwiz,{|aX| aX[2]==aAlterRot[nX]})

		If Len(aColsWiz)<>0 .And. (nPos := &(cCdBlock))<>0 .And.;
			aColsWiz[nPos,nHead]<>aColsWiz[nPos,nHead-1]

			lRet	:= .T.

			For nI := 1 To Len(aIndKey)
				aAdd(aRotAut,{aIndKey[nI], &(aIndKey[nI]), Nil})
			Next nI

			DbSelectArea("SX3")
			DbSetOrder(2)

			If dbSeek(aCampos[nX]) .And. SX3->X3_TIPO == "D" .and. VALTYPE(aColsWiz[nPos,nHead]) <> "D"
				cValor   := StoD(aColsWiz[nPos,nHead])
				cValSeek := (aColsWiz[nPos,nHead-1])
			Else
				cValor   := (aColsWiz[nPos,nHead])
				cValSeek := (aColsWiz[nPos,nHead-1])
			Endif

			nAux := aScan(aRotAut,{|z| z[1] == aCampos[nX]})
			If nAux > 0
				aRotAut[nAux][2] := cValor
				AADD(aRotAut[nAux],cValSeek)
			Else
				aAdd(aRotAut,{aCampos[nX], cValor, Nil})
			EndIf
		EndiF	
		RestArea(aArea)
	Next nX	
	If Len(aColsWiz)<>0 .and. nPos <> 0 .AND. aColsWiz[nPos,nHead]<>aColsWiz[nPos,nHead-1]
		dbSelectArea(cAlias)
		aArea := GetArea()
		If "SB1"==cAliasAnt
			MATA010(aRotAut,4)
		ElseIf "SA2"==cAliasAnt
			MATA020(aRotAut,4)
		ElseIf "SA1"==cAliasAnt
			MATA030(aRotAut,4)
		ElseIf "SF4"==cAliasAnt
			MATA080(aRotAut,4)
		ElseIf "SFM"==cAliasAnt
			MATA089(aRotAut,4)
		ElseIf "SE2"==cAliasAnt
			FINA050(aRotAut,,4)
		ElseIf "SE1"==cAliasAnt
			FINA040(aRotAut,4)	
		EndIf

		cLinha := ""

		dbSelectArea(cAlias)
		If !Empty(cExpApFim) .AND. nX==1
			cLinha += &(cExpApFim)
		EndIf

		If !Empty(cPosiciona)
			cLinha += " - "+&cPosiciona
		EndIf

		If lMsErroAuto
			cLinha += STR0060+NomeAutoLog()+STR0043 //" --> Não atualizado, verificar observação deste registro no arquivo "###" criado no diretório STARTPATH do sistema, geralmente SYSTEM ou SIGAADV."
			cLinha += CRLF
		ElseIf nX==1 .OR. cAliasAnt $ "SE2|SE1" 
			cLinha += STR0044 //" --> Atualização efetuada com sucesso."
			cLinha += CRLF
		EndIf

		//-- Tamanho limite da string = 1GB
		If Len(cTexto) + Len(cLinha) > 1000000
			SaveLog(cFileLog,cTexto)
			cTexto := ''
		EndIf
		cTexto += cLinha

		RestArea(aArea)
		aRotAut:= {}
	else
		loop
	ENDIF
	IncProc("Atualizando registro " + cValToChar(nRec) + " de " + cValToChar(Len(aRecnos)) + "...")

Next nRec

RestArea(aAreaSX3)
RestArea(aAreaAnt)

FwFreeArray(aRecnos)
aRecnos := {}

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BkPainel  ³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao validacao ao voltar o assistente da rotina. Utiliza- ³±±
±±³          ³ para zerar o variavel memo quando voltar no assistente.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. ou  .F.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oWizard -> Objeto wizard.                                   ³±±
±±³          ³oTree -> Objeto do TREE apresentado no resumo do processamento³±±
±±³          ³cMemo -> Variavel memo de help para cada selecao do tree.   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BkPainel(oWizard,oTree,cMemo)
Local	lRet	:=	.T.

If oWizard:NPANEL==6
	oTree:TreeSeek("L1"+StrZero (0, 2, 0))
	cMemo	:=	STR0056	//"Confira o resumo clicando em umas das opções à esquerda."
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcWiz   ³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de processamento as informacoes do assistente para   ³±±
±±³          ³ montar o browse de atualizacao dos campos.                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. ou  .F.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oWizard -> Objeto wizard.                                   ³±±
±±³          ³oTWBrow -> Objeto o Browse de selecao do campo a ser alterado³±±
±±³          ³cAlias -> Alias da tabela de referencia.                    ³±±
±±³          ³cFil -> Filtro selecionado no assistente da rotina.         ³±±
±±³          ³oGetDad -> Objeto getdados do browse de atualizacao da rotina³±±
±±³          ³cMarca -> Retorno do GETMARK()                              ³±±
±±³          ³aIndKey -> Campos chave da tabela baseado no indice caso nao³±±
±±³          ³ seja selecionado nenhum campo no agrupamento para edicao.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcWiz(oWizard,oTWBrow,cAlias,cFil,oGetDad,cMarca,cCdBlock,aCampos,aIndKey)
Local	lRet		:=	.F.
Local	nI			:=	1
Local	aAgrCmps	:=	{}
Local 	aAreaAnt	:=  {}
Local	cAliasAnt	:=	cAlias  
Local 	nX          := 0

If !Empty(aRecnos)
	FwFreeArray(aRecnos)
	aRecnos := {}
Endif	

aColsWiz	:=	{}
cCampo		:=	AllTrim(oTWBrow:AARRAY[oTWBrow:nAT,2])
cCdBlock	:=	"aScan(aColsWiz,{|aX| "

If Empty(aCampos)
	For nX:= 1 to Len(oTWBrow:AARRAY)   
		If oTWBrow:AARRAY[nX,1]
			aAdd(aCampos,oTWBrow:AARRAY[nX,2])                                  
		EndIf
	Next nX      
EndIf
	
TRB->(dbGoTop())
While !TRB->(Eof())
	If TRB->TRB_OK==cMarca
		aAdd (aAgrCmps,TRB->TRB_CMP1)
		cCdBlock	+=	"aX["+AllTrim(Str(nI++))+"]=="+AllTrim(TRB->TRB_CMP1)+".And."	
	EndIf
	TRB->(dbSkip())
End

If Len(aIndKey)==0
	aIndKey		:=	&("{'"+StrTran(AllTrim((cAlias)->(IndexKey())),"+","','")+"'}")
	aDel(aIndKey,1)
	aSize(aIndKey,Len(aIndKey)-1)
EndIf                            

If !Empty(aAgrCmps)
	 MontCode(aCampos,@cCdBlock,aAgrCmps,nI)
Else
	For nI := 1 To Len(aIndKey)
		cCdBlock	+=	"aX["+AllTrim(Str(nI))+"]=="+AllTrim(aIndKey[nI])+".And."
	Next nI	
	MontCode(aCampos,@cCdBlock,aAgrCmps,Len(aIndKey)+1)
	aAgrCmps	:=	aClone(aIndKey)
EndIf               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao que monta o ACOLS e AHEADER³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAlterRot:= ProcGetD(aAgrCmps,aCampos)   

aAreaAnt	:= (cAliasAnt)->(GetArea())
DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))

//Executa o filtro na tabela
If !Empty(cFil)
	(cAlias)->(DbSetFilter( {||&cFil}, cFil + " .And. " + SubStr(cAliasAnt,2,2) + "_FILIAL == '" +  xFilial(cAliasAnt) + "'" ))
EndIf
(cAlias)->(DBGoTop())

While !Eof() .And. xFilial(cAliasAnt)==&(SubStr(cAliasAnt,2,2)+"_FILIAL") .And. !Empty(aCampos)
	If !Empty(cFil) .And. (cAlias)->(&(cFil))
		lRet	:=	.T.
		Aadd(aRecnos,(cAlias)->(RECNO()))
		If Len(aColsWiz)==0 .Or. (nPos := &(cCdBlock))==0
			aAdd(aColsWiz,{})
			For nI := 1 To Len(aAgrCmps)
				aAdd(aTail(aColsWiz),&(aAgrCmps[nI]))
			Next nI
			For nX:= 1 To Len(aCampos)
				aAdd(aTail(aColsWiz),&(aCampos[nX]))
				aAdd(aTail(aColsWiz),&(aCampos[nX]))
			Next nX
			aAdd(aTail(aColsWiz),.F.)
		EndIf

	EndIf

	(cAlias)->(DbSkip())
	IncProc()
EndDo		  

If Empty(aCampos) 
	lRet	:=	.F.
EndIf

RestArea(aAreaAnt)

If !Empty(cFil)
	(cAlias)->(dbClearFilter())
EndIf

If lRet
	aSort(aColsWiz,,,{|x,y|x[1]<y[1]})
	oGetDad := MsNewGetDados():New(5,5,133,283,GD_UPDATE,"AllwaysTrue","AllwaysTrue",,aAlterRot,/*freeze*/,Len(aColsWiz),/*fieldok*/,/*superdel*/,/*delok*/,oWizard:oMPanel[oWizard:NPANEL+1],aHeadWiz,aColsWiz)
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcGetD  ³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de processamento as informacoes do assistente para   ³±±
±±³          ³ montar o browse de atualizacao dos campos.                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. ou  .F.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aAgrCmps -> Campos terao agrupamento no browse.             ³±±
±±³          ³cCampo -> Campo que deverah ser atualizado.                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcGetD(aAgrCmps,aCampos)
Local	nI		  := 0
Local   aAlterRot := {}
aHeadWiz	:=	{}

For nI := 1 To Len(aAgrCmps)
	dbSelectArea("SX3")
	dbSetOrder(2)
	MsSeek(aAgrCmps[nI])
	AADD(aHeadWiz,{TRIM(x3titulo()),;
		"TRB_CMP"+StrZero(nI,3),;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		".F.",;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_F3,;
		SX3->X3_CONTEXT,;
		SX3->X3_CBOX,;
		SX3->X3_RELACAO,;
		".T."})
Next nI

For nI:= 1 To Len(aCampos)

	MsSeek(aCampos[nI])
	AADD(aHeadWiz,{TRIM(x3titulo()+STR0063),;
		"TRB_ANT" + StrZero(nI,3),;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		".F.",;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_F3,;
		SX3->X3_CONTEXT,;
		SX3->X3_CBOX,;
		SX3->X3_RELACAO,;
		".T."})
	
	AADD(aHeadWiz,{TRIM(x3titulo())+STR0064,;
		"TRB_NV" + StrZero(nI,3),;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		".T.",;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_F3,;
		SX3->X3_CONTEXT,;
		SX3->X3_CBOX,;
		SX3->X3_RELACAO,;
		".T."})
	AADD(aAlterRot,	"TRB_NV" + StrZero(nI,3))     
Next nI

Return aAlterRot
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontClick ³ Autor ³ Gustavo G. Rueda      ³ Data ³ 22/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de apresentacao do resumo ao se clicar em uma das    ³±±
±±³          ³ opcoes do tree.                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. ou  .F.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oTree -> Objeto do TREE apresentado no resumo do processamento³±±
±±³          ³cMemo -> Variavel memo de help para cada selecao do tree.   ³±±
±±³          ³aResumo -> Textos do resumo final apresentado antes de      ³±±
±±³          ³ iniciar a atualizacao.                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontClick(oTree, cMemo, aResumo)
Local	lRet	:=	.T.

If ("L1"$oTree:GetCargo())
	cMemo	:=	""
	cMemo	+=	aResumo[1]
ElseIf ("L201"$oTree:GetCargo())
	cMemo	:=	""
	cMemo	+=	aResumo[2]
ElseIf ("L202"$oTree:GetCargo())
	cMemo	:=	""
	cMemo	+=	aResumo[3]
ElseIf ("L203"$oTree:GetCargo())
	cMemo	:=	""
	cMemo	+=	aResumo[4]	
EndIf
Return lRet            
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontCode   ºAutor  ³Leonardo Quintania    º Data ³13/01/2012º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡ao ³ Monta CodeBlock dos campos a serem modificados 			  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Facilitador                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontCode(aCampos,cCdBlock,aAgrCmps,nI)
Local nX
Local lRet:= .T.        

For nX:= 1 To Len(aCampos)
	If nX ==1
   		cCdBlock	+=	"aX["+AllTrim(Str(nI++))+"]=="+aCampos[nX]    
 	Else
 		++nI
 		cCdBlock	+=	"aX["+AllTrim(Str(nI++))+"]=="+aCampos[nX]  
 	EndIf    
  	If nX < Len(aCampos)
   		cCdBlock	+=	".And."
   	Else
   	   	cCdBlock	+=	"})"
   	EndIf    
 	
Next nX 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveLog

Grava os Dados da Execucao do LOG

@param	cFile      - Nome do arquivo de Log
		cTexto     - Conteudo do Log
@return	Nil
@author flavio.luiz
@since 06/03/2017
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function SaveLog(cFile,cTexto)
Local nHandle := 0
Local cMask   := "Arquivos Texto (*.TXT) |*.txt|"

Default cFile  := cGetFile(cMask,"")
Default cTexto := ""

If !File(cFile)  // Arquivo não existe
	// Cria o arquivo de log
	nHandle := FCreate(cFile,FC_NORMAL)
	FSeek(nHandle, 0)	// Posiciona no inicio do arquivo de log
Else	// Arquivo existe
	nHandle := FOpen(cFile,FO_READWRITE+FO_SHARED)
	FSeek(nHandle, 0, FS_END)	// Posiciona no fim do arquivo de log
EndIf
FWrite(nHandle,cTexto,Len(cTexto)) // Grava o conteudo da variavel no arquivo de log
FClose(nHandle) // Fecha o arquivo de log
Return

Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} GetQryFrom

Monta a expressão usada no Select das funções Atualiza() e ProcWiz()
Para adicionar o R_E_C_N_O_. Bancos ORACLE/DB2 não podem utilizar a expressão
 *, R_E_C_N_O_ RECNO por isso todos os campos são adicionados ao Select.

@sample	GetQryFrom('Oracle', {B1_FILIAL, B1_COD}) 

@param	cGetDB, Character, Nome do banco de dados
		aAliasFlds, Array, Campos da estrutura de dados do Alias em uso (DbStruct)
@return	cFromQuery, caracter, Expressão já tratada com '%' para ser usada no BeginSQL

@author	SQUAD CRM/Faturamento
@since	28/11/2017
@version 12.1.17
/*/ 
//------------------------------------------------------------------------------
Static Function GetQryFrom (cGetDB, aAliasFlds )
	Local cFromQuery:= ''
	Local nLoop		:= 0
	Local nLenFlds	:= 0 
	
	Default cGetDB	:= TcGetDb()
	Default aAliasFlds:= {}
	
	If  Upper(cGetDB) == 'ORACLE' .Or.  Upper(cGetDB) == 'DB2'
		nLenFlds  := Len( aAliasFlds )
		If nLenFlds > 0
			cFromQuery := aAliasFlds[1,1]
			If nLenFlds > 1 
				For nLoop := 2 to nLenFlds
					if aAliasFlds[nLoop,2] != "M"
						cFromQuery += ','+  aAliasFlds[nLoop, 1]
					EndIF
				Next
			EndIf
			cFromQuery += ', R_E_C_N_O_ RECNO '
			
		EndIf 
	Else
		cFromQuery := ' *, R_E_C_N_O_ RECNO '
	EndIf
	
	If !Empty( cFromQuery )
		cFromQuery := "%" + cFromQuery + "%"
	EndIf
Return cFromQuery
