#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RHIMPGEN.CH'

/*/{Protheus.doc} RHIMPDP
	Efetua manutenção na tabela de DE-PARA;
@author Leandro Drumond
@since 14/07/2016
@version P12.1.7
@return Nil, Valor Nulo
@obs Defeito RHRH002-140
/*/
User Function RHIMPDP()
	Local aAreas		:= {GetArea()}
	Local aHeader	:= {}
	Local aButtons	:= {}
	Local aTable	:= {}
	Local aCols		:= {}
	Local cFind		:= Space(20)
	Local nOpcA		:= -1
	Local oSize 	:= FwDefSize():New(.T.)
	Local oGetDP 
	Local oDlgAux
	Local oSayH1
	Local bSetBuscar := { | u | If( PCount() == 0, cFind, cFind := u ) }
	Local bSetTable := {|u|if(PCount()>0,cTable:=u,cTable)}
	Local bVldBuscar := {|| fFindDP(@oGetDP,cFind,.F.),.T.}
	Local bVldTable := {||If(fFindDP(@oGetDP,cTable,.T.,aColsAnt,aCols),(cFind := Space(20),.T.), .F.)}
	Local nCol := nRow := 0
	Private oSayH2
	Private aColsAnt 	:= {}
	Private cTable		:= ""
	
	UpdCols(@aTable,@aCols)
	
	aColsAnt:= aClone(aCols)
	cTable:= If(!Empty(aTable),aTable[1],"")
	
	/*Aumenta o espaço disponível da tela*/
	oSize:aWindSize[3] := (oMainWnd:nClientHeight * 0.99)
	oSize:AddObject( "GETENC",100, 30, .F., .F. )
	oSize:AddObject( "GETDADOS",100, 45, .T., .T. )
	oSize:AddObject( "HELPER",100, 20, .F., .F. ) 
	
	oSize:lLateral     := .F.  
	oSize:Process() // Dispara os calculos
	
	DEFINE MSDIALOG oDlgAux TITLE STR0019 From oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP ) OF oMainWnd PIXEL //"Manutenção de DE-PARA" ### " de Filiais"
		
		nRow := oSize:GetDimension("GETENC","LININI")
		nCol := oSize:GetDimension("GETENC","COLINI") + 5
		oTable := TComboBox():New(nRow,nCol,bSetTable,aTable,70,60,,,bVldTable,,,,.T.,,,,{|| .T. },,,,,'cTable',OemToAnsi(STR0004),1)	
		oTable:bGotFocus := {||U_fSetHelp(oSayH2,STR0147)}
		
		nRow := oSize:GetDimension("GETENC","LININI")
		nCol := oSize:GetDimension("GETENC","COLINI") + 80	
		oFind  := TGet():New( nRow, nCol,bSetBuscar,,200, 14, "@!",bVldBuscar, 0, 16777215,,.F.,,.T.,,.F.,{||.T.},;
		.F.,.F.,,.F.,.F. ,,"cFind",,,,,,,OemToAnsi(STR0031),1,,, OemToAnsi(STR0194))	
		  
		oFind:bGotFocus := {||U_fSetHelp(oSayH2,STR0135 + CRLF + STR0152)}
	
		
		aAdd( aHeader , { STR0021	, "CAMPO" , "@!", 010, 0, "" , ,"C",,,,"IIF(AllTrim(cTable)=='FILIAL' .And. Len(aTable) > 1,'FILIAL','')",/*"Empty(aCols[n,1]) .and. */"U_fSetHelp(oSayH2,'" + STR0153 + "')"}) 		//"Campo"
		aAdd( aHeader , { STR0022 	, "EXTVAL", "@!", 070, 0, "" , ,"C",,,,,"U_fSetHelp(oSayH2,'" + STR0154 + " " + STR0155 + "')" })  																//"Chave Externa"
		aAdd( aHeader , { STR0023 	, "INTVAL", "@!", 136, 0, "" , ,"C",,,,,"U_fSetHelp(oSayH2,'" + STR0156 + " " + STR0155 + "')" })  																//"Chave Interna"
		
		oGetDP	 := MsNewGetDados():New(oSize:GetDimension("GETDADOS","LININI")			,;	// 1  nTop
									 	oSize:GetDimension("GETDADOS","COLINI") + 5		,;  // 2  nLelft
									 	oSize:GetDimension("GETDADOS","LINEND"),;	// 3  nBottom
									 	oSize:GetDimension("GETDADOS","COLEND") 		,;	// 4  nRright
									 	GD_UPDATE+GD_DELETE+GD_INSERT				 	,;  // 5  Controle do que podera ser realizado na GetDado - nstyle
										'u_fVldGetDPlOK()'								,;	// 6  Funcao para validar a edicao da linha - ulinhaOK
									 	.T.												,;	// 7  Funcao para validar todas os registros da GetDados - uTudoOK
	  								 	Nil												,;	// 8  cIniCPOS
									 	{"CAMPO","EXTVAL","INTVAL"}						,;	// 9  aAlter
									 	0			  									,; 	// 10 nfreeze
									 	9999999999999									,;  // 11 nMax
									 	Nil												,;	// 12 cFieldOK
									 	Nil												,;	// 13 usuperdel
									 	Nil												,;	// 14 udelOK
									 	@oDlgAux										,; 	// 15 Objeto de dialogo - oWnd
									 	@aHeader    									,;	// 16 Vetor com Colunas - AparHeader
									 	@aCols	 )											// 17 Vetor com Header - AparCols
									 	
			aAdd(aButtons,{"GERARESC",{||fMntDPEsp(oSayH2)},STR0112,STR0112}) //"De-Para Especificos"
			
			aAdd(aButtons,{"EXPCSV",{||ImpOrExp()},STR0200,STR0200})
			aAdd(aButtons,{"IMPCSV",{||ImpOrExp(.T.),UpdCols(aTable,aCols,oGetDP,oTable,aColsAnt)},STR0201,STR0201})
	
			bSet15 := { || nOpcA := 1 , aCols := oGetDP:aCols, (If(fVldGetDPtOK(aCols) .and. fGravaDP(aCols),oDlgAux:End(),Nil))}
			bSet24 := { || nOpcA := 0 , oDlgAux:End() }
			
			//Cria barra de Help inferior
			U_HelpFoot(@oSayH1,@oSayH2,oDlgAux,oSize,"HELPER")
			
			//Carrega informações sobre a rotina na barra de Help
			u_fSetHelp(oSayH1,STR0148 + CRLF + STR0149 + CRLF + STR0150 + CRLF + STR0151)
			
			//Carrega informações sobre o primeiro campo com foco (tabela)
			U_fSetHelp(oSayH2,STR0147)
			
	ACTIVATE DIALOG oDlgAux ON INIT ( EnchoiceBar( oDlgAux , bSet15 , bSet24 , NIL , aButtons,,,,,.F. ),U_fDescBar(oDlgAux,STR0019)) VALID U_EscPress(nOpcA)
	
	aEval(aAreas,{|x|RestArea(x)})
Return

/*/{Protheus.doc} fFindDP
	Localiza e filtra itens da get de DE-PARA
@author Leandro Drumond
@since 18/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fFindDP(oGetDP,cChave,lFiltra,aColsAnt)
	Local aColsAux	:= oGetDP:aCols
	Local nX		:= 0
	Local nY		:= 0
	Local cKeAux	:= ""
	Local lAchou	:= .F.
	
	If  lFiltra .and. !ArrayCompare(aColsAux,aColsAnt) //Se foi feita alguma alteração, informa que as perderá se não salvar
		If !MsgYesNo(STR0171) //"Ocorreram alterações na GRID, se mudar de tabela as alterações serão perdidas. Prosseguir?"
			Return(.F.)
		EndIf
	EndIf
	
	If lFiltra
		aColsAnt 	 := aClone(fLoadDP(cChave))
		oGetDP:aCols := aClone(aColsAnt)
		oGetDP:GoTo(1)
	Else
		If !Empty(cChave)
			cChave := AllTrim(UPPER(cChave))
			For nX := 1 to Len(oGetDP:aCols)
				If !Empty(oGetDP:aCols[nX][1])
					nAte := Len(oGetDP:aCols[nX]) - 1
					For nY := 1 to nAte
						If cChave $ AllTrim(UPPER(oGetDP:aCols[nX,nY]))
							lAchou := .T.
							oGetDP:GoTo(nX)
							Exit
						EndIf
					Next nY
					If lAchou
						Exit
					EndIf
				EndIf
			Next nX
			If !lAchou
				MsgInfo(STR0038) //"Nenhuma referência localizada."
			EndIf
		EndIf
	EndIf
	
	oGetDP:Refresh()

Return .T.
/*/{Protheus.doc} fLoadDP
	Carrega os itens existentes da tabela de DE-PARA
@author Leandro Drumond
@since 14/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fLoadDP(cTable)
	Local aRet		:= {}
	Local cNameAux  := "%" + cArqDP + "%"
	Local cAliasAux	:= GetNextAlias()
	Local cWhere	:= "%%"
	Local lFilial	:= .F.
	
	If !Empty(cTable)
		If(cTable) == "FILIAL"
			lFilial := .T.
			cWhere := "% AND ALIAS = 'ALL' %"
		Else
			cWhere := "% AND ALIAS = '" + cTable + "' %"
		EndIf
	EndIf
	
	BeginSql alias cAliasAux
		SELECT ALIAS, FIELD, EXTVAL, INTVAL 
		FROM %exp:cNameAux% TMP
			WHERE TMP.%notDel%  
			%exp:cWhere%
	 	    ORDER BY ALIAS, FIELD
	EndSql
	
	While (cAliasAux)->(!Eof())
		If (ALIAS == "ALL" .and. !lFilial) .or. (ALIAS <> "ALL" .and. lFilial) 
			(cAliasAux)->(DbSkip())
			Loop
		EndIf
		aAdd(aRet,{AllTrim(FIELD),EXTVAL,INTVAL,.F.})
		(cAliasAux)->(DbSkip())
	EndDo
	
	(cAliasAux)->(DbCloseArea())
Return aRet

/*/{Protheus.doc} fLoadTabs
	Localiza todas as tabelas que possuam DE-PARA cadastrado
@author Leandro Drumond
@since 16/09/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fLoadTabs()
	Local aRet 		:= {}
	Local cAliasAux	:= GetNextAlias()
	Local cNameAux  := "%" + cArqDP + "%"
	
	BeginSql alias cAliasAux
		SELECT DISTINCT(ALIAS) 
		FROM %exp:cNameAux% TMP
			WHERE TMP.%notDel%  
	 	    ORDER BY ALIAS
	EndSql
	
	While (cAliasAux)->(!Eof())
		If (ALIAS == "ALL")
			aAdd(aRet, "FILIAL")
			(cAliasAux)->(DbSkip())
			Loop
		EndIf
		aAdd(aRet,ALIAS)
		(cAliasAux)->(DbSkip())
	EndDo
	
	(cAliasAux)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} fMntDPEsp
	Montagem de tela para definição de DE-PARA especifico
@author Leandro Drumond
@since -30/08/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fMntDPEsp(oSay)
	Local aSvKeys	:= GetKeys()
	Local nOpcRec	:= 1.00
	Local bSet15	:= { || lOpcOk := .T.	, RestKeys( aSvKeys , .T. ) , oDlgAux:End() }
	Local bSet24	:= { || nOpcRec := 0	, RestKeys( aSvKeys , .T. ) , oDlgAux:End() }
	Local lOpcOk	:= .F.
	
	Local oRadio
	Local oDlgAux
	Local oSize 		:= FwDefSize():New( .T.)
	Local nCol := nRow := 0
	
	oSize:AddObject( "GETDADOS",400, 180, .F., .F. ) 
	oSize:lLateral     := .F.  
	oSize:Process() // Dispara os calculos
	
	nRow := oSize:GetDimension("GETDADOS","LININI")
	nCol := oSize:GetDimension("GETDADOS","COLINI")
	
	DEFINE MSDIALOG oDlgAux TITLE STR0115  From nRow,nCol TO oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND") PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP ) OF oMainWnd PIXEL //"Selecione a opção desejada"
		
		nRow += 15
		nCol += 10		
		oRadio := TRadMenu():New(nRow,nCol,{STR0116,STR0117,STR0118},{|u|Iif (PCount()==0,nOpcRec,nOpcRec:=u)},oDlgAux,,{|| U_fSetHelp(oSay,If(nOpcRec == 1, STR0157, (If(nOpcRec == 2,STR0158,STR0159 ))))},,,,,,115,10)
		
		U_fSetHelp(oSay,STR0157)
	
	ACTIVATE DIALOG oDlgAux CENTERED ON INIT EnchoiceBar( oDlgAux , bSet15 , bSet24,,,,,,,.F. )
	
	RestKeys( aSvKeys , .T. )
	
	If !( lOpcOk )
		nOpcRec := 0
	Else
		If nOpcRec == 1
			fGeraDpEsp("S043","","SRG","RG_TIPORES","TIPORESC") //Em consulta de manutenção de tabela deve ser informado o campo principal para o DE-PARA
		ElseIf nOpcRec == 2
			fGeraDpEsp("SX5","41","SR3","R3_TIPO")
		Else
			fGeraDpEsp("RCM","","SR8","R8_TIPOAFA")
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} fVldGetDPtOK
	Valida getdados da manutenção de DE-PARA (TudoOk)
@author Leandro Drumond
@since 14/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fVldGetDPtOK(aCols)
	Local lRet		:= .F.
	Local nX		:= 0
	
	For nX := 1 to Len(aCols)
		If !aCols[nX,4] //Linha não esta deletada
			lRet := .T.
			If Empty(aCols[nX,1]) .or. Empty(aCols[nX,2]) .or. Empty(aCols[nX,3])
				MsgAlert(STR0024) //"Todos os campos devem ser preenchidos."
				Return(.F.)
			EndIf
		EndIf
	Next nX
	
	If !lRet .and. Empty(aColsAnt)
		MsgAlert(STR0025) //"Nenhum registro informado."
	Else
		lRet := .T.
	EndIf
Return lRet

/*/{Protheus.doc} fGravaDP
	Efetua gravação dos itens do DE-PARA
@author Leandro Drumond
@since 14/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fGravaDP(aCols)
	Local aArea	:= GetArea()
	Local nX		:= 0
	Local cTable	:= ""
	Local cField	:= ""
	Local lIsDeleted := .F.
	
	DbSelectArea(cAliasDP)
		
	For nX := 1 to Len(aCols)
		cField := Padr(If(AllTrim(aCols[nX,1]) == "FILIAL","FILIAL",aCols[nX,1]),10)
		cTable	:= Padr(If(AllTrim(cField) == "FILIAL","ALL",FWTabPref(AllTrim(cField))),3)
		lIsDeleted := aCols[nX,4]
		
		If lIsDeleted .and. !Empty(aCols[nX,1]) .and. !Empty(aCols[nX,2])
			If DbSeek(cTable+cField+RTrim(aCols[nX,2]))
				RecLock(cAliasDP,.F.)
				DbDelete()
				MsUnLock()
			EndIf
		Else
			If nX <= Len(aColsAnt)
				If !ArrayCompare(aCols,aColsAnt,nX) //Se houver diferença, atualiza					
					DbSeek(cTable+ Padr(aColsAnt[nX,1],10)+ AllTrim(aColsAnt[nX,2]))					
					RecLock(cAliasDP,.F.)
				Else
					Loop
				EndIf
			Else
				RecLock(cAliasDP,.T.)
			EndIf
			//Grava campos
			ALIAS 	:= cTable
			FIELD	:= cField
			EXTVAL 	:= aCols[nX,2]
			INTVAL 	:= aCols[nX,3]
			MsUnLock()
		EndIf
	Next nX
	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} fVldGetDPlOK 
	Valida getdados da manutenção de DE-PARA (LinhaOk)
@author Leandro Drumond
@since 14/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
User Function fVldGetDPlOK()
	Local lRet		:= .T.	
	If !aCols[n,4] //Linha não esta deletada
		If Empty(aCols[n,1]) .or. Empty(aCols[n,2]) .or. Empty(aCols[n,3])
			MsgAlert(STR0024) //"Todos os campos devem ser preenchidos."
			lRet := .F.			
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} fGeraDpEsp
	Geração automática de DE-PARA especifico
@author Leandro Drumond
@since -29/08/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fGeraDpEsp(cTable,cChave,cAliasAux,cCampo,cCpoRet)
	Local aArea			:= GetArea()
	Local aCabec		:= {}
	Local aHeader		:= {}
	Local aCols			:= {}
	Local cTitulo		:= STR0119 //"De-Para Especifico"
	Local lGeraDP		:= .F.
	Local lGeraDPNull	:= .F.
	Local nX			:= 0
	Local nY			:= 0
	Local nPosInt		:= 2
	Local nOpcA			:= -1
	Local nTipo			:= 0
	Local oSize 		:= FwDefSize():New( .T.)
	Local oGetRCC 
	Local oDlgAux
	Local oSayH1
	Local oSayH2
	
	Private aSXBCols   	:= {}
	Private aSXBHeader 	:= {}
	Private cFilRCB  	:= xFilial("RCB")
	Private cFilRCC  	:= xFilial("RCC")
	Private lPesqComp 	:= .F.
	Private nUsado  	:= 0
	
	DEFAULT cCpoRet 	:= ""
	
	If Len(cTable) == 4 //Manutenção de Tabela - RCB/RCC
		
		dbSelectArea("RCB")
		dbSetOrder(1)
		
		dbSeek(cFilRCB+cTable,.F.)
		cDescRCC := Alltrim(RCB_DESC)
		
		dbSelectArea("RCC")
		dbSetOrder(1)
		
		fMontaHeaderRCC( "S043", cCpoRet )
		MontaColsRCC( "S043", cCpoRet)
		
		cTitulo += " - " + STR0116//Tipos de Rescisão
		
		nTipo := 1
		
	ElseIf cTable == "SX5" //Tabelas genéricas SX5
		DbSelectArea(cTable)
		If!DbSeek(xFilial(cTable)+cChave)
			MsgAlert(STR0127) //"Não existem dados cadastrados no sistema. Efetue o cadastramento antes de executar o DE-PARA"
			Return Nil
		EndIf
		aAdd( aSXBHeader , { STR0169 , "CHAVE" , "@!", 10, 0, "" , ,"C","", }) 		//"Chave"
		aAdd( aSXBHeader , { STR0003, "DESC"  , "@!", 60, 0, "" , ,"C","", }) 	 	//"Descrição"
		While SX5->(!Eof() .and. X5_TABELA == cChave)
			aAdd(aSXBCols, {SX5->X5_CHAVE, SX5->X5_DESCRI,.F.})
			SX5->(DbSkip())
		EndDo
		
		cTitulo += " - " + STR0117 //"Tipos de Alteração Salarial"
		
		nTipo := 2
	Else
		If cTable == "RCM"
			DbSelectARea("RCM")
			If !DbSeek(xFilial("RCM"))
				RstaCodFol()				
				MsAguarde( {||fCargaRCM(.T.)} , STR0128) //"Gerando Tipos de Afastamento Padrão"
			EndIf
			If !DbSeek(xFilial("RCM"))
				MsgAlert(STR0129) //"Nenhum tipo de afastamento foi criado"
				Return
			EndIf
		EndIf
		
		cTitulo += " - " + STR0118 //"Tipos de Afastamentos"
		
		aSXBHeader := GdMontaHeader(,,,cTable)
		aSXBCols   := (cTable)->( GdMontaCols(	@aSXBHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
							   	  				Nil				,;	//02 -> Numero de Campos em Uso
										  		Nil				,;	//03 -> [@]Array com os Campos Virtuais
										 		Nil				,;	//04 -> [@]Array com os Campos Visuais
										 		cTable			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
										  		Nil				,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
										  		Nil				,;	//07 -> [@]Array unidimensional contendo os Recnos
									  			cTable			,;	//08 -> Alias do Arquivo Pai
									  			xFilial(cTable)	;	//09 -> Chave para o Posicionamento no Alias Filho
									  		))
		nTipo := 3
		
	EndIf
	
	aAdd( aHeader , { "DE-PARA"	, "DEPARA", "@!", 10, 0, "" , ,"C","", }) 		//"De-Para"
	
	For nX := 1 to Len(aSXBHeader)
		aAdd(aHeader,aSXBHeader[nX])
		If !Empty(cCpoRet) .and. AllTrim(UPPER(aSXBHeader[nX][2])) == cCpoRet 
			nPosInt := nX+1
		EndIf 
	Next nX
	
	aCols := {}
	
	For nX := 1 to Len(aSXBCols)
		aAdd(aCols,Array(Len(aSXBCols[nX])+1))
		aCols[nX,1] := Space(10)
		For nY := 1 to Len(aSXBCols[nX])
			aCols[nX,nY+1] := aSXBCols[nX,nY]
		Next nY
	Next nX
	
	oSize:AddObject( "GETDADOS",100, 80, .T., .T. )
	oSize:AddObject( "HELPER",100, 20, .F., .F. ) 
	oSize:lLateral     := .F.  
	oSize:Process() // Dispara os calculos
	
	DEFINE MSDIALOG oDlgAux TITLE cTitulo From oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP ) OF oMainWnd PIXEL //"De-Para Especifico"
	
		oGetRCC	 := MsNewGetDados():New(oSize:GetDimension("GETDADOS","LININI")			,;	// 1  nTop
									 	oSize:GetDimension("GETDADOS","COLINI")	+ 5		,;  // 2  nLelft
									 	oSize:GetDimension("GETDADOS","LINEND") - 15	,;	// 3  nBottom
									 	oSize:GetDimension("GETDADOS","COLEND") 		,;	// 4  nRright
									 	GD_UPDATE			 	,;  // 5  Controle do que podera ser realizado na GetDado - nstyle
										.T.						,;	// 6  Funcao para validar a edicao da linha - ulinhaOK
									 	.T.						,;	// 7  Funcao para validar todas os registros da GetDados - uTudoOK
	  								 	Nil						,;	// 8  cIniCPOS
									 	{"DEPARA"}				,;	// 9  aAlter
									 	0			  			,; 	// 10 nfreeze
									 	99999					,;  // 11 nMax
									 	Nil						,;	// 12 cFieldOK
									 	Nil						,;	// 13 usuperdel
									 	Nil						,;	// 14 udelOK
									 	@oDlgAux				,; 	// 15 Objeto de dialogo - oWnd
									 	@aHeader    			,;	// 16 Vetor com Colunas - AparHeader
									 	@aCols		    		)	// 17 Vetor com Header - AparCols
	
			bSet15 := { || nOpcA := 1 , aCols := oGetRCC:aCols, (If(fGrvTabAux(aCols,cAliasAux,cCampo,nPosInt),oDlgAux:End(),Nil))}
			bSet24 := { || nOpcA := 0 , oDlgAux:End() }
			
			//Cria barra de Help inferior
			U_HelpFoot(@oSayH1,@oSayH2,oDlgAux,oSize,"HELPER")
			
			//Carrega informações sobre a rotina na barra de Help
			u_fSetHelp(oSayH1,If(nTipo == 1,STR0157 + CRLF + STR0160 + CRLF + STR0161,(If(nTipo == 2, STR0158 + CRLF + STR0160 + CRLF + STR0162,STR0159 + CRLF + STR0160 + CRLF + STR0163))))
			
			//Carrega informações sobre o primeiro campo com foco
			U_fSetHelp(oSayH2,STR0164)
	
	ACTIVATE Dialog oDlgAux ON INIT ( EnchoiceBar( oDlgAux , bSet15 , bSet24,,,,,,,.F. ),U_fDescBar(oDlgAux,cTitulo)) VALID U_EscPress(nOpcA)
	
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} fGrvTabAux
	Grava os registros DE-PARA informado
@author Leandro Drumond
@since -29/08/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fGrvTabAux(aCols,cTable,cCampo,nPosInt)
	Local lRet		:= MsgYesNo(STR0120) //"Apenas os registros com DE-PARA informado serão gravados. Confirma?"
	Local nX		:= 0
	
	If lRet
		//GRAVA OS REGISTROS DO DE-PARA
		For nX := 1 to Len(aCols)
			If !Empty(aCols[nX,1])
				RecLock(cAliasDP,.T.)
				(cAliasDP)->ALIAS  := cTable 
				(cAliasDP)->FIELD  := cCampo
				(cAliasDP)->EXTVAL := AllTrim(aCols[nX,1])
				(cAliasDP)->INTVAL := AllTrim(aCols[nX,nPosInt])
				MsUnLock()		
			EndIf 
		Next nX
	EndIf
Return lRet

/*/{Protheus.doc} fLoadCpo
	Carrega combo com os campos permitidos para o DE-PARA
@author Leandro Drumond
@since 14/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
User Function fLoadCpo(lIndice)
	Local cRet	:= "1=PJ_DIA;2=Q3_CARGO;3=QB_DEPTO;4=R6_TURNO;5=RA_MAT;6=RB6_FAIXA;7=RB6_NIVEL;8=RB6_TABELA;9=RBR_TABELA;A=RCE_CODIGO;B=RJ_FUNCAO;C=RV_COD;D=CTT_CUSTO;E=P9_CODIGO"
	
	DEFAULT lIndice := .T.
	
	If !lIndice
		cRet	:= "PJ_DIA;Q3_CARGO;QB_DEPTO;R6_TURNO;RA_MAT;RB6_FAIXA;RB6_NIVEL;RB6_TABELA;RBR_TABELA;RCE_CODIGO;RJ_FUNCAO;RV_COD;CTT_CUSTO;P9_CODIGO"
	EndIf
Return cRet

/*/{Protheus.doc} ImpOrExp
	Importa/Exporta um arquivo CSV baseado na tabela
@author PHILIPE.POMPEU
@since 17/01/2017
@version P11
@param lImport, booleano, é importação?
/*/
Static Function ImpOrExp(lImport)
	Default lImport := .F.	
	if(lImport)
		FWMsgRun( , {|x|ImportaCSV(x)}, STR0201, STR0202 )
	else	
		FWMsgRun( , {|x|ExportaCSV(x)}, STR0200, STR0202 )
	endIf
Return nil

/*/{Protheus.doc} ImportaCSV
	Importa um arquido delimitado por ponto-e-virgula
@author philipe.pompeu
@since 17/01/2017
@version P11
@param oSay, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function ImportaCSV(oSay)
	Local cArquivo := ''
	Local nHandle := 0
	Local aLinha := {}
	Local cField := ''
	Local cTable := ''
	Local lIsNew := .T.
	Local cValExt:=''
	Local cStart := ''
		
	if (getArquivo(@cArquivo))
		
		if(File(cArquivo))
			FT_FUSE(cArquivo)			
			FT_FGOTOP()			
			FT_FSKIP()//Pula primeira linha que é o cabeçalho!
			cStart := Time()
			
			WHILE (!FT_FEOF())				
				aLinha := StrTokArr2(FT_FREADLN(),";",.T.)				
				cField := PadR(aLinha[1],10)				
				cTable	:= IIF(cField == PadR('FILIAL',10),'ALL',PadR(FwTabPref(AllTrim(cField)),3))
				
				oSay:SetText(STR0203 + ' ' + cTable + ' '+ STR0204 +' ' + ElapTime(cStart,Time()))
				
				cValExt:= AllTrim(aLinha[2]) 
				
				lIsNew := !((cAliasDP)->(dbSeek(cTable + cField  + cValExt)))
				RecLock(cAliasDP,lIsNew)
				
				if(lIsNew)					
					(cAliasDP)->ALIAS 	:= cTable
					(cAliasDP)->FIELD		:= cField
					(cAliasDP)->EXTVAL 	:= cValExt
				endIf
				(cAliasDP)->INTVAL := aLinha[3]	
									
				(cAliasDP)->(MsUnlock())
				FT_FSKIP()
			EndDo			
			FT_FUSE()//Libera o arquivo.			
		endIf
	endIf
Return

/*/{Protheus.doc} ExportaCSV
	Exporta o cadastro de De/Para para um arquivo delimitado por ponto-e-virgula
@author philipe.pompeu
@since 17/01/2017
@version P11
@param oSay, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function ExportaCSV(oSay)
	Local aAreas	:= {(cAliasDP)->(GetArea()),GetArea()}
	Local nHandle := 0
	Local cTabela	  := ''
	Local cStart := ''
	Local nTotal := 0
	Local cArquivo := ''
	
	(cAliasDP)->(dbGoTop())
	while ( (cAliasDP)->(!Eof()) )
		nTotal++
		
		if(nTotal > 0)
			Exit
		endIf
		
		(cAliasDP)->(dbSkip())
	End
	
	if(nTotal <= 0)
		MsgAlert(STR0205)//Não há registros a serem exportados.
		Return
	endIf
		
	if (getArquivo(@cArquivo))		
		if(File(cArquivo))
			nHandle := FOpen(cArquivo,2)
		else		
			nHandle := FCreate(cArquivo)
			FWrite(nHandle,"CAMPO;DE;PARA;" + CRLF)
		endIf
						
		(cAliasDP)->(dbSetOrder(1))
		(cAliasDP)->(dbGoTop())
		cStart := Time()		
		while ( (cAliasDP)->(!Eof()) )		
			cTabela := AllTrim((cAliasDP)->ALIAS)
			oSay:SetText(STR0203 + ' ' + cTabela + ' '+ STR0204 +' ' + ElapTime(cStart,Time()))			
			
			FWrite(nHandle,(cAliasDP)->(FIELD+';'+ EXTVAL +';'+ INTVAL +';') + CRLF)
			(cAliasDP)->(dbSkip())
		EndDo	
		FClose(nHandle)
		
		/*Arquivo gerado com sucesso...*/
		MsgAlert(STR0206 + ' ['+ Upper(cArquivo) + '] '+ STR0207)
	endIf	
	
	aEval(aAreas,{|x|RestArea(x)})	
Return nil

Static Function getArquivo(cArquivo)
	Local cDiretorio := ''	
	Local lResult := .F.
	
	cDiretorio := cGetFile(".TXT", STR0102, , cDiretorio, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_LOCALFLOPPY + 128, .F.) //"Selecione onde serão gerados os arquivos CSV"
	if!(Empty(cDiretorio))
		cArquivo := cDiretorio + 'depara.csv'
		lResult := .T.
	endIf	
Return lResult

Static Function UpdCols(aTable,aCols,oGet,oTable,aColsAnt)
	Default aTable:= {}
	Default aCols	:= {}
				
	aTable	:= fLoadTabs()	
	aCols	:= fLoadDP(If(!Empty(aTable),aTable[1],""))
	
	if(oGet != Nil)
		oGet:SetArray(aCols)
		oGet:Refresh()		
	endIf
	if(oTable != Nil)
		aColsAnt := aClone(aCols)
		oTable:SetItems(aTable)	
	endIf
Return nil
