#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "HEADERGD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMPGEN.CH"
#INCLUDE "FWLIBVERSION.CH"
/*DECLARACAO DAS VARIAVEIS ESTATICAS*/
Static lPdAuto := .F.
Static oHash
Static aDpAux  := {}
Static lRHIMPFIL
/*---------------------------------*/

/*/{Protheus.doc} RHIMPGEN
Rotina para importação genérica.
@author Leandro Drumond
@since 12/07/2016
@version P12.1.7
/*/
Main Function RHIMPGEN()
Public dDataBase 		:= Date()
Public cModulo			:= 'GPE'
Public nModulo			:= 07

DEFINE WINDOW oMainWnd FROM 01,01 TO 22,75 TITLE STR0001 COLOR CLR_BLACK,CLR_WHITE //"Importação de Tabelas"
oMainWnd:ReadClientCoors()

/*Configura ambiente inicial.*/
U_RHImpEnv()

Private cArqDP		:= RetArq("TOPCONN","GPETABDP",.T.) 
Private cArqGen		:= RetArq("TOPCONN","GPETABGEN",.T.)
Private cAliasDP		:= GetNextAlias()

//Cria tabela genérica para DE-PARA
fCriaTabDP(cArqDP,cAliasDP,.T.)

Private cAliasGen		:= GetNextAlias()

//Cria tabela generica para cadastro de layouts
fCriaTabGen(cArqGen,cAliasGen,.T.)

//Monta tela de gerenciamento das integrações	
ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( oMainWnd:Hide(), MontaTela(), oMainWnd:End()) 	//"Abortado pelo Operador"###'T?mino Normal'

RpcClearEnv()

Return Nil

/*/{Protheus.doc} MontaTela
	Monta tela para configuração das integrações
@author Leandro Drumond
@since 12/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function MontaTela()
Local aCols		:= {}
Local aHeader	:= {}
Local aButtons	:= {}
Local nOpcA		:= -1
Local oSize 	:= FwDefSize():New()
Local oGet
Local oDlg
Local bDblClick := { || ( aCols[oBrowse:nAt,1] := !aCols[oBrowse:nAt,1]) }

oSize:aMargins 	:= { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3
oSize:aWindSize[3] := (oMainWnd:nClientHeight * 0.99)		
oSize:lProp 	:= .F. 	// Proporcional
oSize:Process()			// Dispara os calculos

Private cDiretorio	:= ""

aCols   := fMntCols()

DEFINE MSDIALOG oDlg TITLE STR0001 From oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP ) OF oMainWnd PIXEL //"Importação de Tabelas"
	 
	DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aCols LINE BEGIN 1 OF oDlg
	ADD MARKCOLUMN oColumn DATA { || If(aCols[oBrowse:nAt,1],'LBOK','LBNO') } DOUBLECLICK bDblClick HEADERCLICK { || (aEval(aCols,{|x| x[1] := !x[1]}),oBrowse:Refresh(.T.)) } OF oBrowse

	ADD COLUMN oColumn DATA &('{ || aCols[oBrowse:At(),7] }') TITLE STR0123 SIZE 03 	DOUBLECLICK bDblClick ALIGN 1  OF oBrowse //"Sequência"
	ADD COLUMN oColumn DATA &('{ || aCols[oBrowse:At(),2] }') TITLE STR0002 SIZE 06 	DOUBLECLICK bDblClick ALIGN 1  OF oBrowse //"Layout"
	ADD COLUMN oColumn DATA &('{ || aCols[oBrowse:At(),3] }') TITLE STR0003 SIZE 20 	DOUBLECLICK bDblClick ALIGN 1  OF oBrowse //"Descrição"
	ADD COLUMN oColumn DATA &('{ || aCols[oBrowse:At(),4] }') TITLE STR0004 SIZE 03 	DOUBLECLICK bDblClick ALIGN 1 HEADERCLICK { || } OF oBrowse //"Tabela"
	ADD COLUMN oColumn DATA &('{ || aCols[oBrowse:At(),5] }') TITLE STR0005 SIZE 20 	DOUBLECLICK bDblClick ALIGN 1 HEADERCLICK { || }  OF oBrowse //"Arquivo"
	ADD COLUMN oColumn DATA &('{ || aCols[oBrowse:At(),6] }') TITLE STR0006 SIZE 07 	DOUBLECLICK bDblClick ALIGN 1 OF oBrowse //"Modelo"
	
	oBrowse:DisableReport()

	ACTIVATE FWBROWSE oBrowse
	
	aAdd(aButtons,{"IMPLAY"	,{||U_RHImpLay(@aCols),oBrowse:Refresh()},STR0007,STR0007}) //"Manutenção de Layouts"
	aAdd(aButtons,{"MANUTDP"	,{||U_RHIMPDP()},STR0008,STR0008}) //"Manut. De-Para"
	aAdd(aButtons,{"GERXML"	,{||fGeraXml(aCols),oBrowse:Refresh()},STR0097,STR0097}) //"Gerar XML"
	aAdd(aButtons,{"GERAPD"	,{||U_RHIMPSRV()},STR0098,STR0098}) //"Geração de Verbas (SRV)"
	
	bSet15 := { || nOpcA := 1 , If(fVldGet(aCols),(fProcImp(@aCols),oBrowse:Refresh()),Nil), Nil}
	bSet24 := { || nOpcA := 0 , oDlg:End() }
	
ACTIVATE Dialog oDlg ON INIT (EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons,,,,,.F. ),U_fDescBar(oDlg,STR0113))  VALID U_EscPress(nOpcA) 

Return Nil

/*/{Protheus.doc} fProcImp
	Inicia processo de importação
@author Leandro Drumond
@since 23/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fProcImp(aCols, lExec,oSelf)
Local aArea		:= GetArea()
Local aCampos	:= {}
Local aIndice	:= {}
Local aCpoDP	:= {}
Local aRelac	:= {}
Local aTitle	:= {}
Local aLog		:= {}
Local aFilErr	:= {}
Local aFuncErr	:= {}
Local bProcesso	:= {|oSelf| fProcImp(@aCols,.F.,oSelf)}
Local bErro		:= Nil
Local cArquivo	:= ""
Local cValor	:= ""
Local cNewValor	:= ""
Local cEmpTxt	:= ""
Local cFilTxt	:= ""
Local cTableAuto:= "SQB*SRA*SRV*SR6*SP3*SP2*CTT*CTD*SRB*SR8" //Tabelas que irão disparar EXECAUTO
Local cEmpAux	:= "XPTO@#"
Local cFilAux	:= "XPTO@#"
Local cEmpOld	:= cEmpAnt
Local cFilOld	:= cFilAnt
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local nSeqRCC	:= 0
Local nHandle	:= 0
Local nTam		:= 0
Local nTamMax 	:= 0
Local nLinha	:= 0
Local nNumLinhas:= 0
Local bFormula
Local aModulos	:= {}
Local nPosMod	:= 0
Local lFormErro := .F.
Local lNew 		:= .T.
Local nX2Modulo := 0

Private cAliasIMP 	:= ""
Private cTabAux		:= "" 
Private aGrvCpo		:= {}
Private aCpoAux		:= {}

DEFAULT lExec := .T.

If lExec
	//Pergunte("RHIMPGEN",.F.)
	TNewProcess():New( "" , STR0001 , bProcesso , STR0010 , "RHIMPGEN",,,,,.T.) //"Importação de Tabelas" ### "Esta rotina irá importar todos os layouts selecionados na tela anterior."
Else

	Pergunte("RHIMPGEN",.F.)
	
	//Ordena o aCols por sequencia.
	aSort(aCols, , , {|x,y|x[7] < y[7]})
	
	lVerExecAuto:= mv_par01 == 1 //Se deve executar ExecAuto
	lErroNoFim  := mv_par02 == 1 //Se deve processar tudo e parar apenas no final

	oHash := tHashMap():New()

 	aCpoDP	:= StrTokArr2(U_fLoadCpo(.F.),";",.T.)
	aRelac  := fLoadRelacDP(aCpoDP,aCols)

	nTam := 0
	
	For nX := 1 to Len(aCols)
		If aCols[nX,1]
			nTam++
		EndIf 
	Next nX

	oSelf:SetRegua1(nTam)
	oSelf:SaveLog( STR0001 + " - " + STR0011) //"Importação de Tabelas"##"Inicio do processamento"
	
	For nX := 1 to Len(aCols)
		If !aCols[nX,1]
			Loop
		EndIf
		
		aCols[nX,1] := .F. //Desmarca layout		
		/*Variável guarda inicio do processamento.*/
		cStart := Time()

		cArquivo := cDiretorio + aCols[nX,5]
		cModelo  := aCols[nX,6]
		cAliasIMP := aCols[nX,4]
		cTabAux := Space(4)
		
		oSelf:IncRegua1(STR0012 + " - " + If(Empty(cModelo),aCols[nX,4],cModelo) + " - " + aCols[nX,3]) //"Importando " ###
		
		aAdd(aTitle, aCols[nX,2] + " - " + aCols[nX,3])
		aAdd(aLog,{})
		
		If cModelo <> "RHIMP23" //Período não possui arquivo, apenas executa rotina do GPECONV para criação 
			If!File(cArquivo) 
				aAdd(aLog[Len(aLog)] , STR0013 + cArquivo) //"Arquivo não encontrado "
				Loop
			EndIf
			
			nHandle := FOpen(cArquivo, 68)
		EndIf
		
		//Executa RHIMP
		If !Empty(cModelo)			
			//Variaveis private necessarias para execução do RHIMP
			aInconsistencia := {}			
			lFirst	:= .T.			
			lStopOnErr  := .F.
			lPdAuto     := .F.
			aCpoAux 	:= {}
			
			DbSelectArea(cAliasGen)
			
			If DbSeek(Padr(cAliasIMP,3)+ cTabAux + Padr(cModelo,7))
				While (cAliasGen)->(!Eof() .and. MODELO == cModelo)
					If CAMPO <> '' .and. DEPARA == "1"
						aAdd(aCpoAux,{CAMPO,FORMULA})
						lPdAuto := .T.
					EndIf
					(cAliasGen)->(DbSkip())
				EndDo
			EndIf
			
			DbSelectArea("SRA")
			
			bErro := ErrorBlock( { |e| ImpError( e, @aLog ) } )
			
			Begin Sequence

				Eval({||&("U_"+cModelo+"('"+AllTrim(cArquivo)+"',aRelac,oSelf)")})
			
			End Sequence
			
			ErrorBlock(bErro)
			
			//Recria alias das tabelas temporárias se foram fechadas na montagem de ambiente do RHIMP
			If Select(cAliasGen) <= 0
				fCriaTabDP(cArqDP,cAliasDP,.F.)
				fCriaTabGen(cArqGen,cAliasGen,.F.)
			EndIf
			
			For nY := 1 to Len(aInconsistencia)
				aAdd(aLog[Len(aLog)] , aInconsistencia[nY])
			Next nY
			If cModelo <> "RHIMP23"
				FT_FUSE()
				FClose(nHandle)
			EndIf
			
			aTitle[Len(aTitle)]+= '. Total de Linhas: '+ cValToChar(nQtdLinhas)
			Loop
		EndIf
		
		If Len(aCols[nX,4]) > 3
			cAliasIMP := "RCB"
			cTabAux := aCols[nX,4]
			nSeqRCC := 0
		Else
			cAliasIMP := aCols[nX,4]
			cTabAux	:= SPACE(4)
		EndIf

		lExecAuto := .F.
		If lVerExecAuto .and. cAliasIMP $ cTableAuto
			lExecAuto := .T.		
		EndIf
	
		FT_FUSE(cArquivo)
		nNumLinhas := FT_FLASTREC()
		aTitle[Len(aTitle)]+= '. Total de Linhas: '+ cValToChar(nNumLinhas) 
				
		oSelf:SetRegua2(nNumLinhas)		
		FT_FGOTOP()
		
		DbSelectArea(cAliasGen)
		
		aCampos	:= {}		
		nTamMax := 0
		
		If DbSeek(cAliasIMP+cTabAux)
			While (cAliasGen)->(!Eof() .and. TABELA == cAliasIMP .and. AllTrim(TABAUX) == AllTrim(cTabAux))
				nPos := 0
				For nY := 1 to Len(aRelac)
					If (nPos := (aScan(aRelac[nY],{|x| AllTrim(x) == AllTrim(CAMPO)}))) > 0
						aAdd(aCampos,{CAMPO,POSICAO,FORMULA,DEPARA,aRelac[nY,1],TIPO,ORDEM,CAMPOTAM,CAMPODEC})
						Exit
					EndIf 
				Next nY
				If nPos == 0
					aAdd(aCampos,{CAMPO,POSICAO,FORMULA,DEPARA,"",TIPO,ORDEM,CAMPOTAM,CAMPODEC})
				EndIf
				
				If POSICAO > nTamMax
					nTamMax := POSICAO
				EndIf
				(cAliasGen)->(DbSkip())
			EndDo  
		EndIf
		
		aSort( aCampos ,,, { |x,y| x[3]+x[7] < y[3]+y[7] } )
		
		cAliasIMP := If(cAliasIMP == "RCB","RCC",cAliasIMP)

		If fwlibversion() >= "20190131"
			cX2Modulo := FWSX2Util():GetX2Module(cAliasIMP)
		Else
			DbSelectArea("SX2")
			DbSeek(cAliasIMP)
			cX2Modulo := SX2->X2_MODULO
		EndIf
	
		if(Empty(aModulos))
			aModulos := RetModName() 
		endIf		
		if((nPosMod := aScan(aModulos,{|x| x[1] == cX2Modulo})) > 0)
			/*Faz com que o sistema esteja sempre configurado no módulo do Alias,
			dessa forma todos os campos estarão visiveis.*/			
			SetModulo( aModulos[nPosMod,2] , Right(aModulos[nPosMod,2],3) )
		endIf
		
		dbSelectArea("SRA")
		SRA->(dbSetOrder(1))		
		
		DbSelectArea(cAliasIMP)
		DbSetOrder(GetIndex(aIndice))		
		
		nPosFilial := 0
		nPosEmp	   := 0
		cFilAux	   := "XPTO@#"
		cEmpAux	   := "XPTO@#"
		nLinha	   := 0
		lFormErro := .F.
		
		While !FT_FEOF()
			nLinha++			
			aSort( aCampos ,,, { |x,y| x[3]+x[7] < y[3]+y[7] } )
			oSelf:IncRegua2(OemToAnsi(STR0192) + ' ' + cValToChar(nLinha)+ '/' +  cValToChar(nNumLinhas))
				
			cBuffer := FT_FREADLN()		
			aLinha := {}
			aLinha := StrTokArr2(cBuffer,"|",.T.)
			
			If Len(aLinha) < nTamMax
				aAdd(aLog[Len(aLog)], STR0099 + AllTrim(Str(nLinha))) //"Arquivo possui menos colunas do que definido no layout. Linha: "
				FT_FSKIP()
				If lErroNoFim
					Loop
				Else
					Exit
				EndIf
			EndIf
			
			If nPosFilial == 0
				nPosFilial:= aScan(aCampos,{|x| "_FILIAL" $ x[1]})
				nPosEmp   := aScan(aCampos,{|x| "EMPRESA" $ x[1]})
			EndIf
			
			If !Empty(aCampos[nPosFilial,3])
				bErro := ErrorBlock( { |e| ImpError(e,@aLog,.T.,aCampos[nPosFilial]) } )
				Begin Sequence
					cFilTxt := &(aCampos[nPosFilial,3])
				Recover
					lFormErro := .T.
				End Sequence
				ErrorBlock(bErro)
			Else
				cFilTxt := aLinha[aCampos[nPosFilial,2]]
			EndIf
			
			If !Empty(aCampos[nPosEmp,3])
				bErro := ErrorBlock( { |e| ImpError(e,@aLog,.T.,aCampos[nPosEmp]) } )
				Begin Sequence
					cEmpTxt := &(aCampos[nPosEmp,3])
				Recover
					lFormErro := .T.					
				End Sequence
				ErrorBlock(bErro)
			Else
				cEmpTxt := aLinha[aCampos[nPosEmp,2]]
			EndIf
			
			if(lFormErro)
				Exit
			endIf
			
			If ( aScan(aFilErr, {|x| x[1]+x[2] == cEmpTxt+cFilTxt}) ) > 0
				FT_FSKIP()
				Loop
			EndIf
			
			If cFilTxt <> cFilAux .Or. cEmpTxt <> cEmpAux
				cFilAux := cFilTxt
				cFilAnt := fBuscaDP(cFilTxt,"FILIAL","2",.T.,.F.,cEmpTxt)
				If cEmpTxt <> cEmpAux
					cEmpAux := cEmpTxt
					cEmpAnt := fBuscaDP(cFilTxt,"FILIAL","2",.T.,.T.,cEmpTxt)
					SM0->(DbSetOrder(1))	//M0_CODIGO+M0_CODFIL	
					If SM0->(DbSeek(cEmpAnt + cFilAnt))						
						ConfEnv(cEmpAnt,cFilAnt)
					Else
						aAdd(aLog[Len(aLog)] , STR0014 + cEmpAnt + "/" + cFilAnt) //"Empresa/Filial não encontrada "
						FT_FSKIP()
						aAdd(aFilErr,{cEmpTxt,cFilTxt})
						Loop
					EndIf
				Else
					SM0->(DbSetOrder(1))	//M0_CODIGO+M0_CODFIL	
					If !(SM0->(DbSeek(cEmpAnt + cFilAnt)))
						aAdd(aLog[Len(aLog)] , STR0014 + cEmpAnt + "/" + cFilAnt) //"Empresa/Filial não encontrada "
						FT_FSKIP()
						aAdd(aFilErr,{cEmpTxt,cFilTxt})
						Loop
					EndIf
				EndIf
			EndIf
			
			aGrvCpo	:= {}
			
			For nY := 1 to Len(aCampos)
				cValor := "" 
				If "_FILIAL" $ aCampos[nY,1]
					cNewValor := cValor := xFilial(cAliasIMP,cFilAnt)
				Else
					If !Empty(aCampos[nY,3])
						bErro := ErrorBlock( { |e| ImpError(e,@aLog,.T.,aCampos[nY]) } )
						Begin Sequence
							bFormula := &("{|aCampos,aLinha,nPos|" + AllTrim(aCampos[nY,3]) + "}")
							cValor := Eval(bFormula,aCampos,aLinha,nY)
						Recover							
							aSize(aGrvCpo,0) /*Zera o vetor, dessa forma nada será gravado.*/
							lFormErro := .T.							
						End Sequence
						ErrorBlock(bErro)
											
						if(lFormErro)
							Exit
						endIf
					ElseIf !Empty(aCampos[nY,2])
						cValor := aLinha[aCampos[nY,2]] 
					EndIf
					If !Empty(aCampos[nY,5]) .and. !Empty(cValor)
						cNewValor := fBuscaDP(cValor,aCampos[nY,5],aCampos[nY,4],.F.,.F.,cFilTxt)
					Else
					 	cNewValor := cValor
					EndIf
					If "_MAT" $ aCampos[nY,1] .and. cAliasIMP <> "SRA" //Campo matrícula, posiciona no SRA
						If !(SRA->(DbSeek(xFilial("SRA",cFilAnt)+cNewValor)))
							If ( aScan(aFuncErr, {|x| x[1]+x[2]+x[3] == cEmpAnt+cFilAnt+cNewValor}) ) == 0
								aAdd(aLog[Len(aLog)] , STR0015 + cEmpAnt + "/" + cFilAnt + "/" + cNewValor) //"Funcionário não encontrado: " ###
								aAdd(aFuncErr,{cEmpAnt,cFilAnt,cNewValor})
							EndIf
							aGrvCpo	:= {}
							Exit
						EndIf
					EndIf
				EndIf
				If !Empty(cNewValor) .and. AllTrim(aCampos[nY,1]) <> "EMPRESA" 
					aAdd(aGrvCpo,{aCampos[nY,1], cNewValor,aCampos[nY,6]})
				EndIf
			Next nY
			
			If Empty(aGrvCpo)
				if(lFormErro)
					/*Sai do Loop do arquivo e vai pro próximo layout, 
					pois o layout contém formulas inválidas.*/
					Exit			
				endIf
			Else
				If cAliasIMP == "RCC" .AND. !Empty(cTabAux)
					fImpRCC(@aGrvCpo, aCampos, @nSeqRCC)
				EndIf				
				
				lNew := !((cAliasIMP)->(DbSeek(GetChave(aGrvCpo, aIndice))))
	
				If !lExecAuto
					RecLock(cAliasIMP, lNew)
					
					For nY := 1 to Len(aGrvCpo)
						If aGrvCpo[nY,3] == "D"							
							(cAliasIMP)->&(aGrvCpo[nY,1]) := IIF(ValType(aGrvCpo[nY,2]) == "D",aGrvCpo[nY,2],CtoD(aGrvCpo[nY,2])) 
						ElseIf aGrvCpo[nY,3] == "N"							
							(cAliasIMP)->&(aGrvCpo[nY,1]) := IIF(ValType(aGrvCpo[nY,2]) == "N",aGrvCpo[nY,2],Val(aGrvCpo[nY,2])) 
						Else
							(cAliasIMP)->&(aGrvCpo[nY,1]) := aGrvCpo[nY,2]
						EndIf
					Next nY
					
					MsUnLock()
				Else
					aAutoGrv := {}
					lMsErroAuto 	:= .F.
					
					For nY := 1 to Len(aGrvCpo)
						If aGrvCpo[nY,3] == "D"
							aAdd(aAutoGrv,{aGrvCpo[nY,1], CtoD(aGrvCpo[nY,2]), Nil})
						ElseIf aGrvCpo[nY,3] == "N"
							aAdd(aAutoGrv,{aGrvCpo[nY,1], Val(aGrvCpo[nY,2]), Nil})
						Else
							aAdd(aAutoGrv,{aGrvCpo[nY,1], aGrvCpo[nY,2], Nil})
						EndIf
					Next nY
					
					fExecAuto(aAutoGrv,lNew)
					
					If lMsErroAuto
						aLogAux := GetAutoGrLog()
						aEval(aLogAux,{|x|aAdd(aLog[Len(aLog)], x)})
						If !lErroNoFim
							Exit
						EndIf
					EndIf
					If Empty(FT_FREADLN()) //Se ocorreu desposicionamento, reposiciona no arquivo
						FT_FUSE(cArquivo)
					EndIf
				EndIf			
			EndIf			
			
			FT_FSKIP()
		EndDo
		FT_FUSE()
		FClose(nHandle)
	Next nX

	If cEmpOld + cFilOld <> cEmpAnt + cFilAnt //Retorna o posicionamento para a empresa inicial		
		ConfEnv(cEmpOld,cFilOld)
	EndIf
	
	oSelf:SaveLog( STR0001 +" - " + STR0016) //"Importação de Tabelas" "Fim do Processamento"
	
	oHash:Clean()
	FreeObj(oHash)
	lRHIMPFIL := Nil
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apresenta com Log de erros                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fMakeLog(aLog,aTitle,,,"RHLIBGEN",STR0018,"M","P",,.F.)  //"LOG de Ocorrencias"## - Integração de Tabelas"

	aTitle := {}
	aLog   := {}
	
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} fExecAuto
	Executa MsExecAuto de acordo com tabela selecionadas para importação
@author Leandro Drumond
@since 24/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fExecAuto(aAutoGrv,lNew)
Local aCab	:= {}	

Do Case
	Case cAliasIMP == "SQB"
		MSExecAuto({|x, y, z, w| CSAA100(x, y, z, w)},,, aAutoGrv, If(lNew,3,4))
	Case cAliasIMP == "SRA"
		MSExecAuto({|x, y, z, w| GPEA010(x, y, z, w)},,, aAutoGrv, If(lNew,3,4))
	Case cAliasIMP == "SRV"
		FWMVCRotAuto(FwLoadModel("GPEA040"),'SRV',If(lNew,3,4),{{'SRVMASTER',aAutoGrv}},.F.,.T.)
	Case cAliasIMP == "SR6"
		MsExecAuto({|x,y| GPEA080(x,y)},aAutoGrv,If(lNew,3,4))
	Case cAliasIMP == "SP3"
		MSExecAuto({|x,y| PONA020(x,y)},aAutoGrv,If(lNew,3,4))
	Case cAliasIMP == "SP2"
		MsExecAuto({|x,y| PONA090(x,y)},aAutoGrv,If(lNew,3,4))
	Case cAliasIMP == "CTT"
		MSExecAuto({|x,y| CTBA030(x,y)},aAutoGrv,If(lNew,3,4))
	Case cAliasIMP == "CTD"
		MSExecAuto({|x,y| CTBA040(x,y)},aAutoGrv,If(lNew,3,4))
	Case cAliasIMP == "SRB"	
		aCab := { {"RA_FILIAL", SRA->RA_FILIAL, Nil},{"RA_MAT"	, SRA->RA_MAT , Nil} }
		MSExecAuto({|x,y,w,z| GPEA020(x,y,w,z)},Nil,aCab,aAutoGrv,If(lNew,3,4))
	Case cAliasIMP == "SR8"
		aCab := { {"RA_FILIAL", SRA->RA_FILIAL, Nil},{"RA_MAT"	, SRA->RA_MAT , Nil} }
		MSExecAuto({|x,y,w,z| GPEA240(x,y,w,z)},Nil,aCab,aAutoGrv,If(lNew,3,4))
EndCase
 
Return Nil

/*/{Protheus.doc} fBuscaDP
	Busca informações do DE-PARA
@author Leandro Drumond
@since 18/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fBuscaDP(cValor,cField,cDPAuto,lFilial,lEmp,cPrefAux)
Local cRet		:= If(lFilial .and. lEmp, cPrefAux,cValor)
Local cTable	:= ""
Local lTabComp  := .F.
Local lAchou	:= .F.
Local nPipe		:= 0

//Recria alias das tabelas temporárias se foram fechadas na montagem de ambiente do RHIMP
If Select(cAliasGen) <= 0
	fCriaTabDP(cArqDP,cAliasDP,.F.)
	fCriaTabGen(cArqGen,cAliasGen,.F.)
EndIf

If lFilial
	If (cAliasDP)->(DbSeek("ALL" + Padr(cField,10) + cValor)) .and. AllTrim((cAliasDP)->EXTVAL) == AllTrim(cValor)
		nPipe := At("|", (cAliasDP)->INTVAL)
		If nPipe > 0
			If lEmp
				cRet := SubStr((cAliasDP)->INTVAL,1,nPipe-1)
			Else
				cRet := Padr(SubStr((cAliasDP)->INTVAL,nPipe+1),FWGETTAMFILIAL )
			EndIf
		ElseIf !lEmp
			cRet := Padr((cAliasDP)->INTVAL,FWGETTAMFILIAL )
		EndIf
		lAchou := .T.
	ElseIf (cAliasDP)->(DbSeek("ALL" + Padr(cField,10) + cPrefAux + "|" + cValor))
		nPipe := At("|", (cAliasDP)->INTVAL)
		If nPipe > 0
			If lEmp
				cRet := SubStr((cAliasDP)->INTVAL,1,nPipe-1)
			Else
				cRet := Padr(SubStr((cAliasDP)->INTVAL,nPipe+1),FWGETTAMFILIAL )
			EndIf
		ElseIf !lEmp
			cRet := Padr((cAliasDP)->INTVAL,FWGETTAMFILIAL )
		EndIf
		lAchou := .T.
	EndIf
Else
	cTable	:= FWTabPref(cField)	
	lTabComp := Empty(xFilial(cTable,cFilAnt))
	
	If lTabComp
		cPrefAux := ""
	EndIf	
	
	If ((cAliasDP)->(DbSeek(cTable + PADR(cField,10) + cValor)) .and. AllTrim((cAliasDP)->EXTVAL) == AllTrim(cValor));
		.Or. ((cAliasDP)->(DbSeek(cTable + PADR(cField,10) + cPrefAux + "|" + cValor)))
		nPipe := At("|", (cAliasDP)->INTVAL)
		If nPipe > 0
			cRet := Padr(SubStr((cAliasDP)->INTVAL,nPipe+1),TamSX3(cField)[1])
		Else
			cRet := Padr((cAliasDP)->INTVAL,TamSX3(cField)[1])
		EndIf
		lAchou := .T.
	EndIf
	
	If cRet == cValor .and. cDPAuto == "1" .and. !lAchou//Se não existir De-Para e for para criar automaticamente
		If (nPos := aScan(aDpAux,{|x| AllTrim(x[1]) == AllTrim(cPrefAux) + AllTrim(cField)})) > 0
			aDpAux[nPos,2] := Soma1(aDpAux[nPos,2])
			cRet := aDpAux[nPos,2]
		Else
			If AllTrim(cField) == "RV_COD"
				cAliasAux	:= GetNextAlias()
				BeginSql alias cAliasAux
					SELECT MAX(RV_COD) AS MAXCOD
					FROM %table:SRV% SRV
					WHERE RV_FILIAL = %xFilial:SRV% 
					AND SRV.%NotDel%
				EndSql
				
				If (cAliasAux)->(!Eof())
					cRet := Soma1((cAliasAux)->(MAXCOD))
				Else
					cRet := GETSX8NUM(cTable,cField)
					RollBackSX8()
				EndIf
				
				(cAliasAux)->(DbCloseArea())
			Else
				cRet := GETSX8NUM(cTable,cField)
				RollBackSX8()
			EndIf
			
			aAdd(aDpAux,{AllTrim(cPrefAux) + AllTrim(cField),cRet})
		EndIf
		
		RecLock(cAliasDP,.T.)
		(cAliasDP)->ALIAS  := cTable 
		(cAliasDP)->FIELD  := cField
		(cAliasDP)->EXTVAL := If(!Empty(cPrefAux),cPrefAux+"|","") + AllTrim(cValor)
		(cAliasDP)->INTVAL := If(!Empty(cPrefAux),cFilAnt+"|","") + AllTrim(cRet)
		MsUnLock()
	EndIf
EndIf

Return cRet

/*/{Protheus.doc} fLoadRelacDP
	Carregar campos "Relacionados"
@author Leandro Drumond
@since 18/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fLoadRelacDP(aCampos,aCols)
Local aRet		:= {}
Local aRelac	:= {}
Local cTable 	:= ""
Local cAliasIMP	:= ""
Local cNameAux  := "%" + cArqDP + "%"
Local cAliasAux	:= GetNextAlias() 
Local nX	 	:= 0
Local nY		:= 0
Local nPos		:= 0
Local lAchou 	:= .F.

BeginSql alias cAliasAux
	SELECT DISTINCT(FIELD) 
	FROM %exp:cNameAux% TMP
		WHERE TMP.%notDel% 
 	    ORDER BY FIELD
EndSql

While (cAliasAux)->(!Eof())
	If AllTrim((cAliasAux)->FIELD) == "FILIAL"
		(cAliasAux)->(DbSkip())
		Loop
	EndIf
	If (nPos := (aScan(aCampos,{|x| AllTrim(x) == AllTrim((cAliasAux)->FIELD)}))) == 0
		aAdd(aCampos,AllTrim((cAliasAux)->FIELD))
	EndIf
	(cAliasAux)->(DbSkip())
EndDo

(cAliasAux)->(DbCloseArea())

DbSelectArea(cAliasGen)

For nX:=1 to Len(aCols)
	If !aCols[nX,1]
		Loop
	EndIf
	
	cAliasIMP := Padr(aCols[nX,4],3)
	If DbSeek(cAliasIMP)
		While (cAliasGen)->(!Eof() .and. TABELA == cAliasIMP)
			If CAMPO <> '' .and. DEPARA == "1"
				lAchou := .F.
				If (nPos := (aScan(aCampos,{|x| AllTrim(x) == AllTrim((cAliasGen)->CAMPO)}))) > 0
					lAchou := .T.
					Exit
				EndIf 
				If !lAchou
					aAdd(aCampos,AllTrim(CAMPO))
				EndIf
			EndIf
			(cAliasGen)->(DbSkip())
		EndDo
	EndIf
Next nX

DbSelectArea("SX9")
DbSetOrder(1)

For nX := 1 to Len(aCampos)
	If Empty(aCampos[nX])
		Loop
	EndIf
	cField := Alltrim(aCampos[nX])
	cTable := FWTabPref(cField)
	aAdd(aRet,{cField})
	If SX9->(DbSeek(cTable))
		While AllTrim(SX9->X9_DOM) == cTable
			If AllTrim(SX9->X9_EXPDOM) == cField
				aAdd(aRet[Len(aRet)],AllTrim(SX9->X9_EXPCDOM))
				If (nPos := (aScan(aCampos,{|x| AllTrim(x) == AllTrim(SX9->X9_EXPCDOM)}))) > 0
					aCampos[nPos] := ""
				EndIf
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf
Next nX

Return aRet

/*/{Protheus.doc} fVldGet
	Valida marcações no browse
@author Leandro Drumond
@since 13/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fVldGet(aCols)
Local lRet		:= .T.
Local nX		:= 0

If Len(aCols) == 0
	lRet := .F.
	MsgAlert(STR0026) //"Nenhum layout foi definido para importação."
Else
	lRet := .F.
	For nX := 1 to Len(aCols)
		If aCols[nX,1]
			lRet := .T.
			Exit
		EndIf
	Next nX
	If !lRet
		MsgAlert(STR0027) //"Nenhum layout marcado para importação."
	EndIf 
EndIf

If lRet
	cDiretorio := cGetFile(".TXT", STR0028, , cDiretorio, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_LOCALFLOPPY + 128, .F.) //"Selecione o diretório contendo os arquivos para importação"
	If Empty(cDiretorio)
		MsgAlert(STR0029)
		lRet := .F.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} fMntCols
	Monta aCols para utilização no browse
@author Leandro Drumond
@since 12/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fMntCols()
Local aRet		:= {}
Local cNameAux  := "%" + cArqGen + "%"
Local cAliasAux	:= GetNextAlias()

BeginSql alias cAliasAux
	SELECT CODIGO, DESCRIC, TABELA, TABAUX, DESC2, ARQUIVO, MODELO, SEQUENCIA 
	FROM %exp:cNameAux% TMP
	WHERE TMP.%NotDel%
		GROUP BY CODIGO, DESCRIC, TABELA, TABAUX, DESC2, ARQUIVO, MODELO, SEQUENCIA
 	    ORDER BY SEQUENCIA
EndSql

While (cAliasAux)->(!Eof())
	If TABELA != 'RCB'
		aAdd(aRet,{.F.,CODIGO,DESCRIC,TABELA,ARQUIVO,MODELO,SEQUENCIA})
	Else
		aAdd(aRet,{.F.,CODIGO, DESC2, TABAUX,ARQUIVO,MODELO,SEQUENCIA})
	EndIf
	(cAliasAux)->(DbSkip())
EndDo

(cAliasAux)->(DbCloseArea())

//Cria modelos RHIMP - Carga Inicial
If Empty(aRet)	
	/*Gera layouts padrão dos RHIMP*/
	U_GenLayRH(@aRet)	
EndIf

Return aRet

/*/{Protheus.doc} fGetCpoMod
	Carrega todos os campos do modelo RHIMP. Essa função é utilizada nos RHIMPs para verificação do DE-PARA, 
	a estrutura e ordem dos campos só deve ser alteradase houver mudança no próprio RHIMP
@author Leandro Drumond
@since 14/09/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
User Function fGetCpoMod(cModelo)
Local aCampos 		:= {}

Do Case 
	Case cModelo == "RHIMP02"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"RJ_FILIAL",""})
		aAdd(aCampos,{"RJ_FUNCAO",""})
		aAdd(aCampos,{"RJ_DESC",""})
		aAdd(aCampos,{"RJ_CODCBO",""})
	Case cModelo == "RHIMP03"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"CTT_FILIAL",""})
		aAdd(aCampos,{"CTT_CUSTO",""})
		aAdd(aCampos,{"CTT_DESC01",""})
		aAdd(aCampos,{"CTT_BLOQ",""})
		aAdd(aCampos,{"CTT_NOME",""})
		aAdd(aCampos,{"CTT_ENDER",""})
		aAdd(aCampos,{"CTT_BAIRRO",""})
		aAdd(aCampos,{"CTT_CEP",""})
		aAdd(aCampos,{"CTT_MUNIC",""})
		aAdd(aCampos,{"CTT_ESTADO",""})
		aAdd(aCampos,{"CTT_TIPO",""})
		aAdd(aCampos,{"CTT_CEI",""})
		aAdd(aCampos,{"CTT_LOGRTP",""})
		aAdd(aCampos,{"CTT_TPLOT",""})
		aAdd(aCampos,{"CTT_TPINPR",""})
		aAdd(aCampos,{"CTT_NRINPR",""})
		aAdd(aCampos,{"CTT_CODMUN",""})
		aAdd(aCampos,{"CTT_TIPO2",""})
		aAdd(aCampos,{"CTT_LOGRNR",""})
		aAdd(aCampos,{"CTT_FPAS",""})
		aAdd(aCampos,{"CTT_CODTER",""})
		aAdd(aCampos,{"CTT_FAP",""})
		aAdd(aCampos,{"CTT_PERRAT",""})
	Case cModelo == "RHIMP04"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"QB_FILIAL",""})
		aAdd(aCampos,{"QB_DEPTO",""})
		aAdd(aCampos,{"QB_DESCRIC",""})
		aAdd(aCampos,{"QB_CC",""})
	Case cModelo == "RHIMP05"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"RCE_FILIAL",""})
		aAdd(aCampos,{"RCE_CODIGO",""})
		aAdd(aCampos,{"RCE_DESCRI",""})
		aAdd(aCampos,{"RCE_MUNIC",""})
		aAdd(aCampos,{"RCE_UF",""})
		aAdd(aCampos,{"RCE_MESDIS",""})
		aAdd(aCampos,{"RCE_DIADIS",""})
		aAdd(aCampos,{"RCE_PISO",""})
		aAdd(aCampos,{"RCE_ENDER",""})
		aAdd(aCampos,{"RCE_NUMER",""})
		aAdd(aCampos,{"RCE_COMPLE",""})
		aAdd(aCampos,{"RCE_BAIRRO",""})
		aAdd(aCampos,{"RCE_CEP",""})
		aAdd(aCampos,{"RCE_CGC",""})
		aAdd(aCampos,{"RCE_ENTSIN",""})
	Case cModelo == "RHIMP06"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"RV_FILIAL",""})
		aAdd(aCampos,{"RV_COD",""})
		aAdd(aCampos,{"RV_DESC",""})
		aAdd(aCampos,{"RV_TIPOCOD",""})
		aAdd(aCampos,{"RV_TIPO",""})
		aAdd(aCampos,{"RV_PERC",""}) 
		aAdd(aCampos,{"RV_LCTOP",""})
		aAdd(aCampos,{"RV_MED13",""})
		aAdd(aCampos,{"RV_MEDFER",""})
		aAdd(aCampos,{"RV_MEDAVI",""})
		aAdd(aCampos,{"RV_CODFOL",""})
		aAdd(aCampos,{"RV_INSS",""})
		aAdd(aCampos,{"RV_IR",""})
		aAdd(aCampos,{"RV_FGTS",""})
		aAdd(aCampos,{"RV_REF13",""})
		aAdd(aCampos,{"RV_REFFER",""})
		aAdd(aCampos,{"RV_ADIANTA",""})
		aAdd(aCampos,{"RV_PERICUL",""})
		aAdd(aCampos,{"RV_INSALUBR",""})
		aAdd(aCampos,{"RV_SINDICA",""})
		aAdd(aCampos,{"RV_SALFAMI",""})
		aAdd(aCampos,{"RV_DEDINSS",""})
		aAdd(aCampos,{"RV_RAIS",""})
		aAdd(aCampos,{"RV_DIRF",""})
		aAdd(aCampos,{"RV_NATUREZ",""})
		aAdd(aCampos,{"RV_DSRHE",""})
		aAdd(aCampos,{"FILLER1",""})
		aAdd(aCampos,{"FILLER2",""})
		aAdd(aCampos,{"FILLER3",""})
		aAdd(aCampos,{"RV_INCCP",""})
		aAdd(aCampos,{"RV_INCIRF",""})
		aAdd(aCampos,{"RV_INCFGTS",""})
		aAdd(aCampos,{"RV_INCSIND",""})
		aAdd(aCampos,{"RV_TPPROCP",""})
		aAdd(aCampos,{"RV_TPPIRRF",""})
		aAdd(aCampos,{"RV_TPPFGTS",""})
		aAdd(aCampos,{"RV_TPPSIND",""})
		aAdd(aCampos,{"RV_NRPROCP",""})
		aAdd(aCampos,{"RV_NRPIRRF",""})
		aAdd(aCampos,{"RV_NRPFGTS",""})
		aAdd(aCampos,{"RV_NRPSIND",""})
		aAdd(aCampos,{"RV_EXPROCP",""})
	Case cModelo == "RHIMP07"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"R6_FILIAL",""})
		aAdd(aCampos,{"R6_TURNO",""})
		aAdd(aCampos,{"R6_DESC",""})
		aAdd(aCampos,{"R6_HRNORMA",""})
		aAdd(aCampos,{"R6_TPJORN",""})
		aAdd(aCampos,{"R6_DTPJOR",""})
	Case cModelo == "RHIMP08"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"RA_FILIAL",""})
		aAdd(aCampos,{"RA_MAT",""})
		aAdd(aCampos,{"RA_CC",""})
		aAdd(aCampos,{"RA_NOME",""})
		aAdd(aCampos,{"RA_ITEM",""})
		aAdd(aCampos,{"RA_DEPTO",""})
		aAdd(aCampos,{"RA_CODFUNC",""})
		aAdd(aCampos,{"RA_ADMISSA",""})
		aAdd(aCampos,{"RA_OPCAO",""})
		aAdd(aCampos,{"RA_DEMISSA",""})
		aAdd(aCampos,{"RA_BCDEPSA",""})
		aAdd(aCampos,{"RA_CTDEPSA",""})
		aAdd(aCampos,{"RA_BCDPFGT",""})
		aAdd(aCampos,{"RA_CTDPFGT",""})
		aAdd(aCampos,{"RA_HRSMES",""})
		aAdd(aCampos,{"RA_HRSEMAN",""})
		aAdd(aCampos,{"RA_TNOTRAB",""})
		aAdd(aCampos,{"RA_PERCADT",""})
		aAdd(aCampos,{"RA_CATFUNC",""})
		aAdd(aCampos,{"RA_VIEMRAI",""})
		aAdd(aCampos,{"RA_DEPIR",""})
		aAdd(aCampos,{"RA_DEPSF",""})
		aAdd(aCampos,{"RA_NOMECMP",""})
		aAdd(aCampos,{"RA_SITFOLH",""})
		aAdd(aCampos,{"RA_PGCTSIN",""})
		aAdd(aCampos,{"RA_PERICUL",""})
		aAdd(aCampos,{"RA_INSMIN",""})
		aAdd(aCampos,{"RA_INSMED",""})
		aAdd(aCampos,{"RA_INSMAX",""})
		aAdd(aCampos,{"RA_TIPOADM",""})
		aAdd(aCampos,{"RA_CATEG",""})
		aAdd(aCampos,{"RA_TPCONTR",""})
		aAdd(aCampos,{"RA_OCORREN",""})
		aAdd(aCampos,{"RA_FICHA",""})
		aAdd(aCampos,{"RA_RESCRAI",""})
		aAdd(aCampos,{"RA_LOGRDSC",""})
		aAdd(aCampos,{"RA_COMPLEM",""})
		aAdd(aCampos,{"RA_CEP",""})
		aAdd(aCampos,{"RA_MUNICIP",""})
		aAdd(aCampos,{"RA_ESTADO",""})
		aAdd(aCampos,{"RA_BAIRRO",""})
		aAdd(aCampos,{"RA_TELEFON",""})
		aAdd(aCampos,{"RA_NASC",""})
		aAdd(aCampos,{"RA_NATURAL",""})
		aAdd(aCampos,{"RA_NACIONA",""})
		aAdd(aCampos,{"RA_CIC",""})
		aAdd(aCampos,{"RA_PIS",""})
		aAdd(aCampos,{"RA_TITULOE",""})
		aAdd(aCampos,{"RA_ZONASEC",""})
		aAdd(aCampos,{"RA_RESERVI",""})
		aAdd(aCampos,{"RA_RG",""})
		aAdd(aCampos,{"RA_RGORG",""})
		aAdd(aCampos,{"RA_RGUF",""})	
		aAdd(aCampos,{"RA_SEXO",""})
		aAdd(aCampos,{"RA_GRINRAI",""})
		aAdd(aCampos,{"RA_ESTCIVI",""})
		aAdd(aCampos,{"RA_SALARIO",""})
		aAdd(aCampos,{"RA_DTCPEXP",""})
		aAdd(aCampos,{"RA_DTRGEXP",""})
		aAdd(aCampos,{"RA_HABILIT",""})
		aAdd(aCampos,{"RA_NUMINSC",""})
		aAdd(aCampos,{"RA_NUMCP",""})
		aAdd(aCampos,{"RA_SERCP",""})
		aAdd(aCampos,{"RA_UFCP",""})
		aAdd(aCampos,{"RA_RACACOR",""})
		aAdd(aCampos,{"RA_EMAIL",""})
		aAdd(aCampos,{"RA_ANOCHEG",""})
		aAdd(aCampos,{"RA_DEFIFIS",""})
		aAdd(aCampos,{"RA_TPDEFFI",""})
		aAdd(aCampos,{"RA_SINDICA",""})
		aAdd(aCampos,{"RA_VCTOEXP",""})
		aAdd(aCampos,{"RA_VCTEXP2",""})	
		aAdd(aCampos,{"RA_PAI",""})
		aAdd(aCampos,{"RA_MAE",""})
		aAdd(aCampos,{"RA_FECREI",""})
		aAdd(aCampos,{"RA_DTVTEST",""})
		aAdd(aCampos,{"RA_CRACHA",""})
		aAdd(aCampos,{"RA_LOGRNUM",""})
		aAdd(aCampos,{"RA_LOGRTP",""})	
		aAdd(aCampos,{"RA_MATMIG",""})
		aAdd(aCampos,{"RA_NACIONC",""})
		aAdd(aCampos,{"RA_TPJORNA",""})
		aAdd(aCampos,{"RA_CODMUN",""})
		aAdd(aCampos,{"RA_CPAISOR",""})
		aAdd(aCampos,{"RA_CODMUNN",""})
		aAdd(aCampos,{"RA_DATCHEG",""})
		aAdd(aCampos,{"RA_DATNATU",""})
		aAdd(aCampos,{"RA_CASADBR",""})
		aAdd(aCampos,{"RA_FILHOBR",""})
		aAdd(aCampos,{"RA_PORTDEF",""})
		aAdd(aCampos,{"RA_NUMCELU",""})
		aAdd(aCampos,{"RA_EMAIL2",""})
		aAdd(aCampos,{"RA_CATEFD",""})
		aAdd(aCampos,{"RA_TPREINT",""})
		aAdd(aCampos,{"RA_NRPROC",""})
		aAdd(aCampos,{"RA_NRLEIAN",""})
		aAdd(aCampos,{"RA_DTEFRET",""})
		aAdd(aCampos,{"RA_DTEFRTN",""})
		aAdd(aCampos,{"RA_EAPOSEN",""})
		aAdd(aCampos,{"RA_DTVCCNH",""})
		aAdd(aCampos,{"RA_DTEMCNH",""})	
		aAdd(aCampos,{"##FILLER1##","","","C","N"})
		aAdd(aCampos,{"RA_UFCNH",""})
		aAdd(aCampos,{"RA_CATCNH",""})
		aAdd(aCampos,{"RA_RNE",""})
		aAdd(aCampos,{"RA_CLASEST",""})
		aAdd(aCampos,{"RA_RNEORG",""})
		aAdd(aCampos,{"RA_RNEDEXP",""})
		aAdd(aCampos,{"##FILLER2##","","","C","N"})
		aAdd(aCampos,{"RA_NUMRIC",""})
		aAdd(aCampos,{"RA_EMISRIC",""})
		aAdd(aCampos,{"RA_DEXPRIC",""})
		aAdd(aCampos,{"RA_CODIGO",""})
		aAdd(aCampos,{"RA_OCEMIS",""})
		aAdd(aCampos,{"RA_OCDTEXP",""})
		aAdd(aCampos,{"RA_OCDTVAL",""})		
	Case cModelo == "RHIMP09"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"RB_FILIAL",""})
		aAdd(aCampos,{"RB_MAT",""})
		aAdd(aCampos,{"RB_COD",""})
		aAdd(aCampos,{"RB_NOME",""})
		aAdd(aCampos,{"RB_DTNASC",""})
		aAdd(aCampos,{"RB_SEXO",""})
		aAdd(aCampos,{"RB_GRAUPAR",""})
		aAdd(aCampos,{"RB_TIPIR",""})
		aAdd(aCampos,{"RB_TIPSF",""})
		aAdd(aCampos,{"RB_LOCNASC",""})
		aAdd(aCampos,{"RB_CARTORI",""})
		aAdd(aCampos,{"RB_NREGCAR",""})
		aAdd(aCampos,{"RB_NUMLIVR",""})
		aAdd(aCampos,{"RB_NUMFOLH",""})
		aAdd(aCampos,{"RB_DTENTRA",""})
		aAdd(aCampos,{"RB_NUMAT",""})
		aAdd(aCampos,{"RB_CIC",""})
		aAdd(aCampos,{"RB_TPDEP",""})
	Case cModelo == "RHIMP10"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"R8_FILIAL",""})
		aAdd(aCampos,{"R8_MAT",""})
		aAdd(aCampos,{"R8_DATA",""})
		aAdd(aCampos,{"R8_TIPOAFA",""})
		aAdd(aCampos,{"R8_DATAINI",""})
		aAdd(aCampos,{"R8_DATAFIM",""})
		aAdd(aCampos,{"R8_CID",""})
		aAdd(aCampos,{"R8_SEQ",""})
		aAdd(aCampos,{"R8_CONTAFA",""})
		aAdd(aCampos,{"R8_DIASEMP",""})
		aAdd(aCampos,{"R8_DPAGAR",""})
		aAdd(aCampos,{"R8_TPEFD",""})
		aAdd(aCampos,{"R8_TIPOAT",""})
		aAdd(aCampos,{"R8_NMMED",""})
		aAdd(aCampos,{"R8_UFCRM",""})
		aAdd(aCampos,{"R8_CRMMED",""})
	Case cModelo == "RHIMP11"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"R3_FILIAL",""})
		aAdd(aCampos,{"R3_MAT",""})
		aAdd(aCampos,{"R3_DATA",""})
		aAdd(aCampos,{"R3_SEQ",""})
		aAdd(aCampos,{"R3_TIPO",""})
		aAdd(aCampos,{"R3_VALOR",""})
		aAdd(aCampos,{"R7_FUNCAO",""})
		aAdd(aCampos,{"R7_DESCFUN",""})
		aAdd(aCampos,{"R7_CATFUNC",""})
		aAdd(aCampos,{"R7_USUARIO",""})
	Case cModelo == "RHIMP12"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"RD_FILIAL",""})
		aAdd(aCampos,{"RD_MAT",""})
		aAdd(aCampos,{"RD_PD",""})
		aAdd(aCampos,{"RD_DATARQ",""})
		aAdd(aCampos,{"RD_CC",""})
		aAdd(aCampos,{"RD_TIPO1",""})
		aAdd(aCampos,{"RD_HORAS",""})
		aAdd(aCampos,{"RD_VALOR",""})
		aAdd(aCampos,{"RD_DATPGT",""})
		aAdd(aCampos,{"RD_DEPTO",""})
		aAdd(aCampos,{"RD_ITEM",""})
		aAdd(aCampos,{"RD_INSS",""})
		aAdd(aCampos,{"RD_IR",""})
		aAdd(aCampos,{"RD_FGTS",""})
		aAdd(aCampos,{"RD_TIPO2",""})
	Case cModelo == "RHIMP13"
		aAdd(aCampos,{"RE_DATA",""})
		aAdd(aCampos,{"RE_EMPD",""})
		aAdd(aCampos,{"RE_FILIALD",""})
		aAdd(aCampos,{"RE_MATD",""})
		aAdd(aCampos,{"RE_CCD",""})
		aAdd(aCampos,{"RE_EMPP",""})
		aAdd(aCampos,{"RE_FILIALP",""})
		aAdd(aCampos,{"RE_MATP",""})
		aAdd(aCampos,{"RE_CCP",""})
		aAdd(aCampos,{"RE_DEPTOD",""})
		aAdd(aCampos,{"RE_DEPTOP",""})
		aAdd(aCampos,{"RE_ITEMD",""})
		aAdd(aCampos,{"RE_ITEMP",""})
	Case cModelo == "RHIMP14"
		aCampos	:= {{},{},{}}
		aAdd(aCampos[1],{"##TIPO1##","",STR0173 + "'1' " + STR0174 ,"C","S"}) //TIPO de registro
		aAdd(aCampos[1],{"T1_EMPRESA",""})
		aAdd(aCampos[1],{"RG_FILIAL",""})
		aAdd(aCampos[1],{"RG_MAT",""})
		aAdd(aCampos[1],{"RG_TIPORES",""})
		aAdd(aCampos[1],{"RG_DATADEM",""})
		aAdd(aCampos[1],{"RG_DATAHOM",""})
		aAdd(aCampos[1],{"RG_DTAVISO",""})
		aAdd(aCampos[1],{"RG_DAVISO",""})
		aAdd(aCampos[1],{"RG_NORMAL",""})
		aAdd(aCampos[1],{"RG_DESCANS",""})
		aAdd(aCampos[1],{"RG_SALMES",""})
		aAdd(aCampos[1],{"RG_SALHORA",""})
		aAdd(aCampos[1],{"RG_SALDIA",""})
		aAdd(aCampos[1],{"RG_TPAVISO",""})
		aAdd(aCampos[1],{"RG_DFERVEN",""})
		aAdd(aCampos[1],{"RG_DFERPRO",""})
		aAdd(aCampos[1],{"RG_DTGERAR",""})
		
		aAdd(aCampos[2],{"##TIPO2##","",STR0173 + "'2' " + STR0174,"C","S"}) //TIPO de registro
		aAdd(aCampos[2],{"T2_EMPRESA",""})
		aAdd(aCampos[2],{"RD_FILIAL",""})
		aAdd(aCampos[2],{"RD_MAT",""})
		aAdd(aCampos[2],{"RD_PD",""})
		aAdd(aCampos[2],{"RD_DATARQ",""})
		aAdd(aCampos[2],{"RD_CC",""})
		aAdd(aCampos[2],{"RD_TIPO1",""})
		aAdd(aCampos[2],{"RD_HORAS",""})
		aAdd(aCampos[2],{"RD_VALOR",""})
		aAdd(aCampos[2],{"RD_DATPGT",""})		
		aAdd(aCampos[2],{"RD_DEPTO",""})
		aAdd(aCampos[2],{"RD_ITEM",""})
		aAdd(aCampos[2],{"RD_INSS",""})
		aAdd(aCampos[2],{"RD_IR",""})
		aAdd(aCampos[2],{"RD_FGTS",""})
		
		aAdd(aCampos[3],{"##TIPO2##","",STR0173 + "'2' " + STR0174,"C","S"}) //TIPO de registro
		aAdd(aCampos[3],{"T2_EMPRESA",""})
		aAdd(aCampos[3],{"RR_FILIAL",""})
		aAdd(aCampos[3],{"RR_MAT",""})//4
		aAdd(aCampos[3],{"RR_PD",""})
		aAdd(aCampos[3],{"FILLER",""})		
		aAdd(aCampos[3],{"RD_CC",""})//7		
		aAdd(aCampos[3],{"RR_TIPO1",""})		
		aAdd(aCampos[3],{"RR_HORAS",""})		
		aAdd(aCampos[3],{"RR_VALOR",""})		
		aAdd(aCampos[3],{"RR_DATA",""})			
		aAdd(aCampos[3],{"RR_DATAPAG",""})		
		aAdd(aCampos[3],{"FILLER",""})
		aAdd(aCampos[3],{"RR_ITEM",""})
			
	Case cModelo == "RHIMP15"
		aCampos := {{},{}}
		
		aAdd(aCampos[1],{"##TIPO1##","",STR0173 + "'1' " + STR0174,"C","S"}) //TIPO de registro
		aAdd(aCampos[1],{"T1_EMPRESA",""})
		aAdd(aCampos[1],{"RH_FILIAL",""})
		aAdd(aCampos[1],{"RH_MAT",""})
		aAdd(aCampos[1],{"RH_DATABAS",""})
		aAdd(aCampos[1],{"RH_DBASEAT",""})
		aAdd(aCampos[1],{"RH_DFALTAS",""})
		aAdd(aCampos[1],{"RH_DFERIAS",""})
		aAdd(aCampos[1],{"RH_DABONPE",""})
		aAdd(aCampos[1],{"RH_DATAINI",""})
		aAdd(aCampos[1],{"RH_DATAFIM",""})
		aAdd(aCampos[1],{"RH_TIPCAL",""})
		aAdd(aCampos[1],{"RH_PERC13S",""})
		aAdd(aCampos[1],{"RH_DIALREM",""})
		aAdd(aCampos[1],{"RH_DIALRE1",""})
		aAdd(aCampos[1],{"RH_SALMES",""})
		aAdd(aCampos[1],{"RH_SALDIA",""})
		aAdd(aCampos[1],{"RH_SALHRS",""})
		aAdd(aCampos[1],{"RH_DTRECIB",""})
		aAdd(aCampos[1],{"RH_DTAVISO",""})
		
		aAdd(aCampos[2],{"##TIPO2##","",STR0173 + "'2' " + STR0174,"C","S"}) //TIPO de registro
		aAdd(aCampos[2],{"T2_EMPRESA",""})
		aAdd(aCampos[2],{"RD_FILIAL",""})
		aAdd(aCampos[2],{"RD_MAT",""})
		aAdd(aCampos[2],{"RD_PD",""})
		aAdd(aCampos[2],{"RD_DATARQ",""})
		aAdd(aCampos[2],{"RD_CC",""})
		aAdd(aCampos[2],{"RD_TIPO1",""})
		aAdd(aCampos[2],{"RD_HORAS",""})
		aAdd(aCampos[2],{"RD_VALOR",""})
		aAdd(aCampos[2],{"RD_DATPGT",""})
		aAdd(aCampos[2],{"RR_DATAPAG",""})
		aAdd(aCampos[2],{"RD_DEPTO",""})
		aAdd(aCampos[2],{"RD_ITEM",""})
		aAdd(aCampos[2],{"RD_INSS",""})
		aAdd(aCampos[2],{"RD_IR",""})
		aAdd(aCampos[2],{"RD_FGTS",""})
	Case cModelo == "RHIMP16"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"RD_FILIAL",""})
		aAdd(aCampos,{"RD_MAT",""})
		aAdd(aCampos,{"RD_PD",""})
		aAdd(aCampos,{"RD_DATARQ",""})
		aAdd(aCampos,{"RD_CC",""})
		aAdd(aCampos,{"RD_TIPO1",""})
		aAdd(aCampos,{"RD_HORAS",""})
		aAdd(aCampos,{"RD_VALOR",""})
		aAdd(aCampos,{"RD_DATPGT",""})
		aAdd(aCampos,{"RD_DEPTO",""})
		aAdd(aCampos,{"RD_ITEM",""})
		aAdd(aCampos,{"RD_INSS",""})
		aAdd(aCampos,{"RD_IR",""})
		aAdd(aCampos,{"RD_FGTS",""})
		aAdd(aCampos,{"RD_TIPO2",""})
	Case cModelo == "RHIMP17"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"PJ_FILIAL",""})
		aAdd(aCampos,{"PJ_TURNO",""})
		aAdd(aCampos,{"PJ_DIA",""})
		aAdd(aCampos,{"PJ_SEMANA",""})
		aAdd(aCampos,{"PJ_TPDIA",""})
		aAdd(aCampos,{"PJ_ENTRA1",""})
		aAdd(aCampos,{"PJ_SAIDA1",""})
		aAdd(aCampos,{"PJ_ENTRA2",""})
		aAdd(aCampos,{"PJ_SAIDA2",""})
	Case cModelo == "RHIMP18"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"P0_FILIAL",""})
		aAdd(aCampos,{"P0_RELOGIO",""})
		aAdd(aCampos,{"P0_DESC",""})
		aAdd(aCampos,{"P0_CONTROL",""})
		aAdd(aCampos,{"P0_ARQUIVO",""})
		aAdd(aCampos,{"P0_REP",""})
		aAdd(aCampos,{"P0_CODINI",""})
		aAdd(aCampos,{"P0_CODFIM",""})
		aAdd(aCampos,{"P0_RELOINI",""})
		aAdd(aCampos,{"P0_RELOFIM",""})
		aAdd(aCampos,{"P0_DIAINI",""})
		aAdd(aCampos,{"P0_DIAFIM",""})
		aAdd(aCampos,{"P0_MESINI",""})
		aAdd(aCampos,{"P0_MESFIM",""})
		aAdd(aCampos,{"P0_ANOINI",""})
		aAdd(aCampos,{"P0_ANOFIM",""})
		aAdd(aCampos,{"P0_HORAINI",""})
		aAdd(aCampos,{"P0_HORAFIM",""})
		aAdd(aCampos,{"P0_MINUINI",""})
		aAdd(aCampos,{"P0_MINUFIM",""})
		aAdd(aCampos,{"P0_FUNCINI",""})
		aAdd(aCampos,{"P0_FUNCFIM",""})	
	Case cModelo == "RHIMP19"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"PE_FILIAL",""})
		aAdd(aCampos,{"PE_MATPROV",""})
		aAdd(aCampos,{"PE_MAT",""})
		aAdd(aCampos,{"PE_DATAINI",""})
		aAdd(aCampos,{"PE_DATAFIM",""})
	Case cModelo == "RHIMP20"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"PI_FILIAL",""})
		aAdd(aCampos,{"PI_MAT",""})
		aAdd(aCampos,{"PI_DATA",""})
		aAdd(aCampos,{"PI_PD",""})
		aAdd(aCampos,{"##FILLER##","","","C","N"})
		aAdd(aCampos,{"PI_CC",""})
		aAdd(aCampos,{"PI_QUANT",""})
		aAdd(aCampos,{"PI_DEPTO",""})
		aAdd(aCampos,{"PI_CODFUNC",""})
	Case cModelo == "RHIMP21"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"P9_FILIAL",""})
		aAdd(aCampos,{"P9_CODIGO",""})
		aAdd(aCampos,{"P9_DESC",""})
		aAdd(aCampos,{"P9_CODFOL",""})
		aAdd(aCampos,{"P9_TIPOCOD",""})
		aAdd(aCampos,{"P9_DESCDSR",""})
		aAdd(aCampos,{"P9_CLASEV",""})
		aAdd(aCampos,{"P9_BHORAS",""})	
	Case cModelo == "RHIMP22"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"CTD_FILIAL",""})
		aAdd(aCampos,{"CTD_ITEM",""})
		aAdd(aCampos,{"CTD_DESC01",""})	
	Case cModelo == "RHIMP24"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"A6_FILIAL",""})
		aAdd(aCampos,{"A6_COD",""})
		aAdd(aCampos,{"A6_NOME",""})
		aAdd(aCampos,{"A6_AGENCIA",""})
		aAdd(aCampos,{"A6_NOMEAGE",""})
		aAdd(aCampos,{"A6_NUMCON",""})
		aAdd(aCampos,{"A6_DVCTA",""})	
	Case cModelo == "RHIMP25"
		aAdd(aCampos,{"EMPRESA",""})
		aAdd(aCampos,{"RQ_FILIAL",""})
		aAdd(aCampos,{"RQ_MAT",""})
		aAdd(aCampos,{"RQ_NOME",""})
		aAdd(aCampos,{"RQ_CIC",""})
		aAdd(aCampos,{"RQ_NASC",""})
		aAdd(aCampos,{"RQ_BCDEPBE",""})
		aAdd(aCampos,{"##AGENCIA##","",STR0175,"C","S"})
		aAdd(aCampos,{"RQ_CTDEPBE",""})
		aAdd(aCampos,{"RQ_PERCENT",""})
		aAdd(aCampos,{"RQ_PERFGTS",""})
		aAdd(aCampos,{"RQ_DTINI",""})
		aAdd(aCampos,{"RQ_DTFIM",""})
		aAdd(aCampos,{"RQ_VALFIXO",""})
		aAdd(aCampos,{"RQ_VERBAS",""})
		aAdd(aCampos,{"RQ_VERBADT",""})
		aAdd(aCampos,{"RQ_VERBFOL",""})
		aAdd(aCampos,{"RQ_VERBFER",""})
		aAdd(aCampos,{"RQ_VERB131",""})
		aAdd(aCampos,{"RQ_VERB132",""})
		aAdd(aCampos,{"RQ_VERBPLR",""})
		aAdd(aCampos,{"RQ_VERBRRA",""})
	Case cModelo == "RHIMP26"
		aCampos := {{},{}}
		
		aAdd(aCampos[1],{"##TIPO1##","",STR0173 + "'1' " + STR0174,"C","S"}) //TIPO de registro
		aAdd(aCampos[1],{"RFO_CODIGO",""})
		aAdd(aCampos[1],{"RFO_TPVALE",""})
		aAdd(aCampos[1],{"RFO_DESCR",""})
		aAdd(aCampos[1],{"RFO_TPBEN",""})
		aAdd(aCampos[1],{"RFO_VALOR",""})
		aAdd(aCampos[1],{"RFO_PERC",""})
		
		aAdd(aCampos[2],{"##TIPO2##","",STR0173 + "'2' " + STR0174,"C","S"}) //TIPO de registro
		aAdd(aCampos[2],{"EMPRESA",""})
		aAdd(aCampos[2],{"R0_FILIAL",""})
		aAdd(aCampos[2],{"R0_MAT",""})
		aAdd(aCampos[2],{"R0_CODIGO",""})
		aAdd(aCampos[2],{"R0_TPVALE",""})
		aAdd(aCampos[2],{"R0_DIASPRO",""})
	Case cModelo == "RHIMP28"
		aCampos := {{},{},{}}
		
		aAdd(aCampos[1],{"##TIPO1##","",STR0173 + "'1' " + STR0174,"C","S"}) //TIPO de registro
		aAdd(aCampos[1],{"##CODIGO##","",STR0176,"C","S"})
		aAdd(aCampos[1],{"##NOME##","",STR0177,"C","S"})
		aAdd(aCampos[1],{"##CNPJ##","",STR0178,"C","S"})
		aAdd(aCampos[1],{"##ANS##","",STR0179,"C","S"})
		
		aAdd(aCampos[2],{"##TIPO2##","",STR0173 + "'2' " + STR0174,"C","S"}) //TIPO de registro
		aAdd(aCampos[2],{"##CODFOR##","",STR0176,"C","S"})
		aAdd(aCampos[2],{"##PLANO##","",STR0180,"C","S"})
		aAdd(aCampos[2],{"##DESC##","",STR0181,"C","S"})
		aAdd(aCampos[2],{"##TPPLANO##","",STR0182,"C","S"})
		aAdd(aCampos[2],{"##VALOR##","",STR0183,"N","S"})
		aAdd(aCampos[2],{"##TPASSIS##","",STR0184,"C","S"})
		aAdd(aCampos[2],{"##TPBENEF##","",STR0185,"C","S"})	
		aAdd(aCampos[2],{"##IDADE##","",STR0186,"N","S"})
		aAdd(aCampos[2],{"##VLRREF##","",STR0187,"N","S"})
		
		aAdd(aCampos[3],{"##TIPO3##","",STR0173 + "'3' " + STR0174,"C","S"}) //TIPO de registro
		aAdd(aCampos[3],{"EMPRESA",""})
		aAdd(aCampos[3],{"RHK_FILIAL",""})
		aAdd(aCampos[3],{"RHK_MAT",""})
		aAdd(aCampos[3],{"RHK_TPFORN",""})
		aAdd(aCampos[3],{"RHK_CODFOR",""})
		aAdd(aCampos[3],{"RHK_PLANO",""})
		aAdd(aCampos[3],{"RHK_PD",""})	
		aAdd(aCampos[3],{"RHL_CODIGO",""})
		aAdd(aCampos[3],{"RHM_NOME",""})
		aAdd(aCampos[3],{"RHM_DTNASC",""})
		aAdd(aCampos[3],{"RHM_CPF",""})
	
EndCase

Return aCampos

/*/{Protheus.doc} fCriaTabDP
	Cria tabela genérica para cadastro do DE-PARA
@author Leandro Drumond
@since 12/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fCriaTabDP(cArqAux,cAlias,lCria)

Local aStruct	:= {}
Local nX		:= 1
Local cRDD		:= "TOPCONN"

If lCria .and. !MsFile(cArqAux)
	aAdd(aStruct,{	'ALIAS'		,'C'	,3	,0 })
	aAdd(aStruct,{	'FIELD'		,'C'	,10	,0 })
	aAdd(aStruct,{	'EXTVAL'	,'C'	,70	,0 })
	aAdd(aStruct,{	'INTVAL'	,'C'	,136,0 })

	If MsCreate(cArqAux,aStruct,cRDD)
		DbUseArea(.T.,cRDD,cArqAux,cAlias,.T.,.F.)
		dbCreateIndex(cArqAux+"1","ALIAS+FIELD+EXTVAL",{|| &("ALIAS+FIELD+EXTVAL")})
		dbClearind()
		dbSetIndex( cArqAux+"1" )
	EndIf
Else
	DbUseArea(.T.,cRDD,cArqAux,cAlias,.T.,.F.)
	dbClearind()
	dbSetIndex( cArqAux+"1" )
EndIf

Return Nil

/*/{Protheus.doc} fCriaTabGen
	Cria tabela generica para cadastro de layouts
@author Leandro Drumond
@since 12/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fCriaTabGen(cArqAux,cAlias,lCria)

Local aStruct	:= {}
Local cRDD		:= "TOPCONN"

If lCria .and. !MsFile(cArqAux)
	aAdd(aStruct,{	'MARK'		,'C'	,2	,0 })
	aAdd(aStruct,{	'CODIGO'	,'C'	,6	,0 })
	aAdd(aStruct,{	'TIPO'		,'C'	,1	,0 })
	aAdd(aStruct,{	'DESCRIC'	,'C'	,20	,0 })
	aAdd(aStruct,{	'TABELA'	,'C'	,3	,0 })
	aAdd(aStruct,{	'DESC2'		,'C'	,20	,0 })
	aAdd(aStruct,{	'TABAUX'	,'C'	,4	,0 })
	aAdd(aStruct,{	'CAMPO'		,'C'	,10	,0 })
	aAdd(aStruct,{	'ORDEM'		,'C'	,2	,0 })
	aAdd(aStruct,{	'POSICAO'	,'N'	,3	,0 })
	aAdd(aStruct,{	'DEPARA'	,'C'	,1	,0 })
	aAdd(aStruct,{	'FORMULA'	,'C'	,150,0 })
	aAdd(aStruct,{	'ARQUIVO'	,'C'	,30 ,0 })
	aAdd(aStruct,{	'MODELO'	,'C'	,7  ,0 })
	aAdd(aStruct,{	'SEQUENCIA'	,'C'	,3  ,0 })
	aAdd(aStruct,{	'CAMPOTAM'	,'N'	,10  ,0 })
	aAdd(aStruct,{	'CAMPODEC'	,'N'	,10  ,0 })

	If MsCreate(cArqAux,aStruct,cRDD)
		DbUseArea(.T.,cRDD,cArqAux,cAlias,.T.,.F.)
		dbCreateIndex(cArqAux+"1","TABELA+TABAUX+MODELO+CAMPO+ORDEM",{|| &("TABELA+TABAUX+MODELO+CAMPO+ORDEM")})
		dbClearind()
		dbSetIndex( cArqAux+"1" )
	EndIf
Else
	DbUseArea(.T.,cRDD,cArqAux,cAlias,.T.,.F.)
	dbClearind()
	dbSetIndex( cArqAux+"1" )	
EndIf

Return Nil

/*/{Protheus.doc} Processo
	Obtem o código de processo padrão do funcionário
@author Leandro Drumond
@since 18/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
User Function Processo()
Local cRet		:= ""
Local cCatFunc	:= ""
Local cTipoPgt	:= ""
Local nPos		:= 0

If cAliasIMP == "SRA"
	If ( nPos := (aScan(aGrvCpo,{|x| AllTrim(x[1]) == "RA_CATFUNC"}))) > 0
		cCatFunc := aGrvCpo[nPos,2]
	EndIf
	If ( nPos := (aScan(aGrvCpo,{|x| AllTrim(x[1]) == "RA_TIPOPGT"}))) > 0
		cTipoPgt := aGrvCpo[nPos,2]
	EndIf	
	If cCatFunc $ "A*P" .AND. cTipoPgt == "M"
		cRet := "00003"
	ElseIf cCatFunc $ "A*P" .AND. cTipoPgt == "S"
		cRet := "00004"
	ElseIf cTipoPgt == "S"
		cRet := "00002"
	Else
		cRet := "00001"
	EndIf
Else
	cRet := SRA->RA_PROCES
EndIf

Return cRet

/*/{Protheus.doc} Periodo
	Obtem o código de periodo do lançamento
@author Leandro Drumond
@since 18/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
User Function Periodo()
Local cRet		:= ""
Local nPos		:= 0

If ( nPos := (aScan(aGrvCpo,{|x| AllTrim(x[1]) == PrefixoCpo( cAliasIMP )+"_DATARQ"}))) > 0
	cRet := aGrvCpo[nPos,2]
ElseIf ( nPos := (aScan(aGrvCpo,{|x| AllTrim(x[1]) == PrefixoCpo( cAliasIMP )+"_DATA"}))) > 0
	cRet := AnoMes(CtoD(aGrvCpo[nPos,2]))
ElseIf ( nPos := (aScan(aGrvCpo,{|x| AllTrim(x[1]) == PrefixoCpo( cAliasIMP )+"_DTREF"}))) > 0 .and. !Empty(aGrvCpo[nPos,2]) 
	cRet := AnoMes(CtoD(aGrvCpo[nPos,2]))
ElseIf ( nPos := (aScan(aGrvCpo,{|x| AllTrim(x[1]) == PrefixoCpo( cAliasIMP )+"_DATPGT"}))) > 0
	cRet := AnoMes(CtoD(aGrvCpo[nPos,2]))
EndIf

Return cRet

/*/{Protheus.doc} GetCpoDP
	Verifica se existe campo para o DE-PARA
@author Leandro Drumond
@since 27/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function GetCpoDP(aRelac,cCampo)
Local cRet		:= ""
Local nY		:= 0
Local nPos		:= 0

For nY := 1 to Len(aRelac)
	If (nPos := (aScan(aRelac[nY],{|x| AllTrim(x) == AllTrim(cCampo)}))) > 0
		cRet := aRelac[nY,1]
		Exit
	EndIf 
Next nY

Return cRet

/*/{Protheus.doc} GetCodDP
	Obtem o valor do DE-PARA
@author Leandro Drumond
@since 26/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
User Function GetCodDP(aRelac,cCampo,cValExt,cCpoDP,cPrefDP,lFilial,lEmp)
Local cRet		:= ""
Local cKey		:= ""
Local nY		:= 0
Local nPos		:= 0

DEFAULT cPrefDP := cFilAnt
DEFAULT lFilial := .F.
DEFAULT lEmp	:= .F.

If (nPos := (aScan(aCpoAux,{|x| AllTrim(x[1]) == AllTrim(cCampo)}))) > 0 .and. !Empty(aCpoAux[nPos,2])
	cRet := &(aCpoAux[nPos,2])
Else
	
	DEFAULT cCpoDP  := GetCpoDP(aRelac,cCampo)

	cKey := If(lFilial .and. lEmp, "EMPRESA",cCpoDP) + cPrefDp + cValExt
	
	If HMGet(oHash,cKey,@cRet)
		Return cRet[1,2]
	Else
		cRet := cValExt
	EndIf

	If !Empty(cCpoDP)
		cRet := fBuscaDP(cValExt,cCpoDP,If(lPdAuto .and. AllTrim(cCampo) == AllTrim(cCpoDP),"1","2"),lFilial,lEmp,cPrefDP)
		HMAdd(oHash,{cKey,cRet}) 
	EndIf
EndIf

Return cRet

/*/{Protheus.doc} ImpError
	Tratamento para não ocorrer error.log na tela
@author Leandro Drumond
@since -03/08/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function ImpError( e, aLog, lFormula,aField)
Local aErrorStack	:= {} 
Default lFormula := .F.
Default aField := {}

If e:GenCode > 0
	if(lFormula)
		aAdd(aLog[Len(aLog)] , OemToAnsi(STR0196)) /*Erro na execução de fórmulas no Layout*/
		aAdd(aLog[Len(aLog)] , OemToAnsi(STR0197) + ' -> ' + AllTrim(aField[1]) + '.')/*Campo com problema ->*/
		aAdd(aLog[Len(aLog)] , OemToAnsi(STR0198) + ' -> ' + Upper(AllTrim(e:Description)) + '.')/*Mensagem de erro ->*/			
	else
		aAdd(aLog[Len(aLog)] , STR0100) //"Ocorrência de erro na execução do modelo de importação. Verifique o arquivo."
		
		aErrorStack	:= Str2Arr( e:ErrorStack , Chr( 10 ) )		
		aEval( aErrorStack , { |X| aAdd(aLog[Len(aLog)], X) } )	
	endIf	
EndIf

If InTransact()
	DisarmTransaction()
EndIf

Break

Return Nil

/*/{Protheus.doc} fGeraXml
	Gera xml com a estrutura do layout, para preenchimento no excel
@author Leandro Drumond
@since -04/08/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fGeraXml(aCols)
Local aRow			:= {}
Local cTable 		:= ""
Local cModelo		:= ""
Local cTitle 		:= ""
Local cDesc			:= ""
Local cTamanho		:= ""
Local cCombo   		:= ""
Local cAliasAux		:= GetNextAlias()
Local cNameAux  	:= "%" + cArqGen + "%"
Local nX	 		:= 0
Local lRet	 		:= .T.
Local oExcel

If Len(aCols) == 0
	lRet := .F.
	MsgAlert(STR0026) //"Nenhum layout foi definido para importação."
Else
	lRet := .F.
	For nX := 1 to Len(aCols)
		If aCols[nX,1] 
			lRet := .T.
			Exit
		EndIf
	Next nX
	If !lRet
		MsgAlert(STR0101) //"Nenhum layout apto para geração de xml foi selecionado. Os layouts modelo RHIMP não são válidos"
		Return Nil
	EndIf 
EndIf

cDiretorio := cGetFile(".TXT", STR0102, , cDiretorio, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_LOCALFLOPPY + 128, .F.) //"Selecione onde serão gerados os arquivos xml"

If Empty(cDiretorio)
	MsgAlert(STR0103) //"Deve ser informado um diretório para geração dos arquivos"
	Return Nil
EndIf

DbSelectArea("SX3")
DbSetOrder(2)

For nX := 1 to Len(aCols)
	If !aCols[nX,1]
		Loop
	EndIf

	aCols[nX,1] := .F. //Desmarca layout

	cTable := aCols[nX,4]
	cModelo:= aCols[nX,6]
	cTitle := aCols[nX,3]
	
	If Empty(cTable) .and. Empty(cModelo)
		Loop
	EndIf	

	If !Empty(cTable)
		BeginSql alias cAliasAux
			SELECT TIPO, CAMPO, POSICAO 
			FROM %exp:cNameAux% TMP
			WHERE TABELA = %exp:cTable% AND TMP.%NotDel%
		 	    ORDER BY POSICAO
		EndSql
	Else
		BeginSql alias cAliasAux
			SELECT TIPO, CAMPO, POSICAO 
			FROM %exp:cNameAux% TMP
			WHERE MODELO = %exp:cModelo% AND TMP.%NotDel%
		 	    ORDER BY POSICAO
		EndSql
		cTable := cModelo
	EndIf	
	
	If (cAliasAux)->(!Eof())
		oExcel := FWMSEXCEL():New()
		oExcel:AddWorkSheet(cTable)
		oExcel:AddTable (cTable,cTitle)
		aRow := {}	
	
		While (cAliasAux)->(!Eof())
			If (cAliasAux)->CAMPO <> '' .and. (cAliasAux)->POSICAO <> 0
				If AllTrim((cAliasAux)->CAMPO) == "EMPRESA"
					cDesc	 := STR0172
					cTamanho := AllTrim(Str(Len(cEmpAnt)))
					cCombo   := ""
				Else
					SX3->(DbSeek((cAliasAux)->CAMPO))
					cDesc    := X3Titulo()
					cTamanho := AllTrim(Str(SX3->X3_TAMANHO)) + If((cAliasAux)->TIPO=="N","," + AllTrim(Str(SX3->X3_DECIMAL)),"")
					cCombo   := X3CBox() 
				EndIf
				(cAliasAux)->(oExcel:AddColumn(cTable,cTitle,AllTrim(CAMPO)+" ("+AllTrim(cDesc)+")",1,If(TIPO=="C",1,(If(TIPO=="D",4,2)))))
				(cAliasAux)->(aAdd(aRow,(If(!Empty(cCombo),cCombo,(If(TIPO=="D",STR0188,(If(TIPO=="C",STR0189 + cTamanho + ")",STR0190 + cTamanho + ")"))))))))
			EndIf
			(cAliasAux)->(DbSkip())
		EndDo
		oExcel:AddRow(cTable,cTitle,aRow)
		oExcel:Activate()
		oExcel:GetXMLFile(cDiretorio + cTable+".xml")
	EndIf
	(cAliasAux)->(DbCloseArea())
Next nX

Return Nil

/*/{Protheus.doc} RhImpFil
	Retorna existencia de DE-PARA de Filial
@author Leandro Drumond
@since -30/08/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
User Function RhImpFil()
	If lRHIMPFIL == Nil
		lRHIMPFIL := BuscaDPFil()
	EndIf
Return lRHIMPFIL

/*/{Protheus.doc} BuscaDPFil
	Verifica se existe DE-PARA de Filial
@author Leandro Drumond
@since -30/08/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function BuscaDPFil()
Local lRet 		:= .F.

If Select(cAliasDP) <= 0
	fCriaTabDP(cArqDP,cAliasDP,.F.)
EndIf

lRet := (cAliasDP)->(DbSeek("ALL" + Padr("FILIAL",10)))

Return lRet

/*/{Protheus.doc} fDescBar
	Cria descrição ao lado dos botões na Enchoice.
@author Leandro Drumond
@since 09/09/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
User Function fDescBar(oDlg,cString)
Local cStyle := "QFrame{ border-style:none }"
Local oFont  := TFont():New('Arial',,-18,,.T.)
Local oPanel
Local oSay

oPanel:= tPanelcss():New(01,01,,oDlg,,,,,,500,20)
oPanel:setCSS(cStyle)

 oSay := TSay():New(10,05,{||cString},oPanel,,oFont,,,,.T.,CLR_CYAN,,500,20)

Return Nil

/*/{Protheus.doc} EscPress
	Alternativa para não fechar a dialog quando pressionar ESC. Propriedade lEscClose não esta funcional, possível problema de LIB.
@author Leandro Drumond
@since 12/09/2016
@version P12.1.7
@return Lógico
/*/
User Function EscPress(nOpc)
Local lRet := .T.

If nOpc < 0
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} HelpFoot
	Monta as barras de help do rodapé da rotina
@author Leandro Drumond
@since 15/09/2016
@version P12.1.7
@return Nil
/*/
User Function HelpFoot(oSayH1,oSayH2,oDlg,oSize,cName)
	Local nRow := 0
	Local nCol := 0	
	Local nTop		:= 0
	Local nLeft	:= 0
	Local nHeight	:= 0
	Local nWidth	:= 0
	Local nRight := 0
	Local oFont  := TFont():New('Arial',,,,.T.)
	
	nTop 	:= oSize:GetDimension(cName,"LININI")
	nBotton:= oSize:GetDimension(cName,"LINEND")	
	nLeft	:= oSize:GetDimension(cName,"COLINI")	
	nRight	:= oSize:GetDimension(cName,"COLEND")	
	nHeight:= nBotton - 5
	nWidth := (oSize:aWindSize[4] / 2) * (oSize:GetDimension(cName,"XSIZE") / 200)
		
	oScrollH1 := TScrollArea():New(oDlg,nTop,nLeft,nHeight,nWidth - 3)	
	oScrollH2 := TScrollArea():New(oDlg,nTop,(nWidth + 2),nHeight,nWidth - 4)	
	
	oPanelH1  := TPanel():New(01,01,,oScrollH1,,.T.,,,,(nWidth - 3),nHeight * 2)	
	oPanelH2  := TPanel():New(01,01,,oScrollH2,,.T.,,,,(nWidth - 4),nHeight * 2)	
	
	oScrollH1:SetFrame( oPanelH1 )
	oScrollH2:SetFrame( oPanelH2 )
	
	oSayH1 := TSay():New(0,0,,oPanelH1,,oFont,,,,.T.,CLR_CYAN,,(nWidth - 3),nHeight * 2)
	oSayH1:lWordWrap = .T.
	
	oSayH2 := TSay():New(0,0,,oPanelH2,,oFont,,,,.T.,CLR_CYAN,,(nWidth - 4),nHeight * 2)
	oSayH2:lWordWrap = .T.
Return Nil

/*/{Protheus.doc} fSetHelp
	Seta o texto de help do segundo painel
@author Leandro Drumond
@since 15/09/2016
@version P1217
@return lógico, verdadeiro
/*/
User Function fSetHelp(oSay,cString,lDestaca,cCampo)

DEFAULT lDestaca := .F.
DEFAULT cCampo	 := ""

oSay:SetText(cString)

If lDestaca
	oSay:nClrText := CLR_RED
Else
	oSay:nClrText := CLR_BLACK
EndIf

If !Empty(cCampo)
	oSay:SetText(GetHlpSoluc(cCampo)[1])
EndIf

Return .T.

/*/{Protheus.doc} RHIMPTAB
	Ao invés de transformar as funções fCriaTabDP e fCriaTabGen em
	user functions, preferi criar apenas uma função.
@author philipe.pompeu
@since 25/11/2016
@version P11
@param lDePara, lógico, gera tabela de De/Para?
@param lLayouts, lógico, gera tabela de Layouts?
@return Nil, valor nulo
/*/
User Function RHIMPTAB(lDePara,lLayouts)
	Local aArea	:= 	GetArea()
	Default lDePara := .T.
	Default lLayouts:= .T.
	
	if(lDePara)
		fCriaTabDP(cArqDP,cAliasDP,.F.)		
	endIf
	
	if(lLayouts)		
		fCriaTabGen(cArqGen,cAliasGen,.F.)
	endIf
	
	RestArea(aArea)
Return nil

/*/{Protheus.doc} fImpRCC
	Função para tratamento da imporação de Manutenção de Tabelas.
	Trata cada campo do leiaute adaptando à estrutura da RCC.
@author esther.viveiro
@since 13/01/2017
@version P12.1.16
@param aGrvCpo, array, campos validados para gravação
@param aCampos, array, estrutura de campos do leiaute
@param nSeqRCC, number,numero da sequencia a ser gravada no campo RCC_SEQUEN
@return Nil, valor nulo
/*/
Static Function fImpRCC(aGrvCpo, aCampos, nSeqRCC)
	Local nPosGrv := 0
	Local nx		:= 0
	Local aGrvCpoAux	:= {}
	Local cContAux	:= ""
	Local cConteudo	:= ""
	
	aSort( aCampos ,,, { |x,y| x[7] < y[7] } )
	
 	nSeqRCC++
	nPosGrv := aScan(aGrvCpo,{|x| "RCC_FILIAL" $ x[1]})
	aAdd(aGrvCpoAux, {"RCC_FILIAL", aGrvCpo[nPosGrv,2],aGrvCpo[nPosGrv,3]})
	aAdd(aGrvCpoAux, {"RCC_CODIGO", cTabAux,"C"})
	aAdd(aGrvCpoAux, {"RCC_SEQUEN", PADL(cValtoChar(nSeqRCC), 3, "0"),"C"})
	
	For nx := 5 to Len(aCampos)
		nPosGrv:= aScan(aGrvCpo,{|x| aCampos[nx,1] == x[1]})
		cContAux:= If(nPosGrv > 0, aGrvCpo[nPosGrv,2],"")
		If aCampos[nx,6] == "N"
			cContAux:= Str(Val(cContAux),aCampos[nx,8],aCampos[nx,9])
		ElseIf aCampos[nx,6] == "D"
			cContAux:= DtoS(CtoD(cContAux))
		EndIf
		cContAux:= PADR(cContAux, aCampos[nx,8])
		cConteudo+= cContAux
	Next nx
	
	aAdd(aGrvCpoAux, {"RCC_CONTEU", cConteudo,"C"})
	
	aGrvCpo := aGrvCpoAux

Return Nil

/*/{Protheus.doc} GetIndex
	Retorna o índice da tabela atual
@author PHILIPE.POMPEU
@since 20/01/2017
@version P11
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*/
Static Function GetIndex(aIndice)
	Local cIndice	:= ""
	Local nOrdem := 0
	Local nI := 0
	Local cCampo := ''
	Local nInicio:= 0
	Local nFim:= 0
	Default aIndice := {}
	
	cIndice:= FWX2Unico(cAliasIMP)//SX2->X2_UNICO
	nOrdem := 0
		
	If !Empty(cIndice)
		DbSelectArea("SIX")
		DbSeek(cAliasIMP)
		While !Eof() .and. INDICE == cAliasIMP
			If AllTrim(cIndice) == AllTrim(CHAVE)
				nOrdem := Val(ORDEM)
			EndIf
			DbSkip()
		EndDo
	EndIf
		
	If Empty(nOrdem)
		DbSelectArea("SIX")
		DbSeek(cAliasIMP)
		cIndice := CHAVE
		nOrdem := RetOrder(cAliasIMP,cIndice)
	EndIf
	
	aIndice := StrTokArr2(cIndice,"+",.T.)	
	for nI:= 1 to Len(aIndice)
		cCampo := aIndice[nI]
		nInicio:= AT("(",cCampo)		 
		if(nInicio > 0)/*Exemplo: o campo DtoS(P8_DATA) deve ser retornado apenas P8_DATA etc.*/
			cCampo := SubStr(cCampo,nInicio + 1)
			
			aEval({')',','},{|x| nFim := AT(x,cCampo) , IIF(nFim > 0, cCampo := Left(cCampo,nFim - 1),)})
			
			aIndice[nI] := cCampo
		endIf
	next nI	
Return nOrdem

/*/{Protheus.doc} GetChave
	Baseado nos valores de aCampos e na composição de aIndice, retorna
	a chave de pesquisa.
@author PHILIPE.POMPEU
@since 20/01/2017
@version P11
@param aCampos, array, (Descrição do parâmetro)
@param aIndice, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetChave(aCampos, aIndice)
	Local cChave := ''
	Local nPos := 0
	Local nY := 0
	
	//Cria indice para macro execução baseado nas posições do array
	For nY := 1 to Len(aIndice)
		nPos := aScan(aCampos,{|x| AllTrim(x[1]) == AllTrim(aIndice[nY])})
		If nPos == 0
			cChave += Space(TAMSX3(aIndice[nY])[1])
		ElseIf aCampos[nPos,3] == "D"
			cChave += DtoS(CtoD(aCampos[nPos,2]))
		Else
			cChave += aCampos[nPos,2]
		EndIf 
	Next nY
	
Return cChave

/*/{Protheus.doc} ConfEnv
	Configura o ambiente.
@author philipe.pompeu
@since 20/01/2017
@version P11
@param cEmp, character, (Descrição do parâmetro)
@param cFil, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function ConfEnv(cEmp,cFil)
	Default cEmp := cEmpAnt
	Default cFil := cFilAnt
	
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(cEmp, cFil,,,,,)
	
	__cInternet := Nil
	
	aEval({'SX2','SX3','SX5','SX6'},{|x|CHKFILE(x)})
	
	//Recria alias das tabelas temporárias
	fCriaTabDP(cArqDP,cAliasDP,.F.)
	fCriaTabGen(cArqGen,cAliasGen,.F.)
Return nil