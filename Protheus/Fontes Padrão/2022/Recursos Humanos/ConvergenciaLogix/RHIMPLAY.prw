#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RHIMPGEN.CH"

/*/{Protheus.doc} RHImpLay
	Cria layouts para importação
@author Leandro Drumond
@since 13/07/2016
@version P12.1.7
@return Nil, Valor Nulo
@obs Defeito RHRH002-140
@obs Defeito RHRH002-143 | 15/12/2016
@obs Defeito RHRH002-148 | 26/01/2017
/*/
User Function RHImpLay(aColsIMP)
	Local aArea := (cAliasGen)->(GetArea())
	Local aHeader	:= {}
	Local aCols		:= {}
	Local aButtons	:= {}
	Local aModels	:= InfRhImp("",1)
	Local cTabRHIMP	:= ""
	Local cCpoDP	:= U_fLoadCpo(.F.)
	Local cTable	:= Space(3)
	Local cDesc		:= Space(20)
	Local cTabAux	:= Space(4)
	Local cDesc2	:= Space(20)
	Local cFile		:= Space(30)
	Local cFind		:= Space(30)
	Local cSequencia:= Space(3)
	Local nOpcA		:= -1
	Local oSize 	:= FwDefSize():New( .T.) 
	Local oDlgAux
	Local lDpAuto	:= .F.
	Local lWhenDP	:= .F.
	Local oSayH1
	Local nRow := nCol := 0
	Local nClrBack := 16777215
	Local bValTable := {||If (fAtuGet(cTable,@cDesc,@cTabAux,@cDesc2,@cFile,@aCols,@lDpAuto,@lWhenDP,cCpoDP,@cSequencia),(oGetImp:SetArray(aCols),oGetImp:Refresh(.T.)),.F.)}
	Local bValCombo := {||fAtuGet(cTable,@cDesc,@cTabAux,@cDesc2,@cFile,@aCols,@lDpAuto,@lWhenDP,cCpoDP,@cSequencia,cModelo),(oGetImp:SetArray(aCols),oGetImp:Refresh(.T.))}
	
	Private oSayH2
	
	Private cModelo	:= Space(7)
	
	/*Aumenta o espaço disponível da tela*/
	oSize:aWindSize[3] := (oMainWnd:nClientHeight * 0.99)	
	
	oSize:AddObject( "GETENC",100, 30, .F., .F. )
	oSize:AddObject( "GETIMP",100, 45, .T., .T. )
	oSize:AddObject( "HELPER",100, 20, .F., .F. )
	oSize:lLateral     := .F.  
	oSize:Process() // Dispara os calculos
	
	DEFINE MSDIALOG oDlgAux TITLE STR0030 From oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP ) OF oMainWnd PIXEL //"Manutenção de Layouts para Importação"	
		
		nRow := oSize:GetDimension("GETENC","LININI")+ 5
		
		oTable := TGet():New(nRow,nCol+5, {|u|if(PCount()==0,cTable,cTable := u)},,45,14,"@!",bValTable, 0, nClrBack,,.F.,,.T.,,.F.,;
		{|| Empty(cModelo)},.F.,.F.,,.F.,.F. ,"SX2PAD","cTable",,,,,,,OemToAnsi(STR0004),1)
		oTable:bGotFocus := {||U_fSetHelp(oSayH2,STR0132)}		
		
		oDesc := TGet():New( nRow, nCol+55, {|u|if(PCount()==0,cDesc,cDesc := u)},,110, 014, "@!",, 0, nClrBack,,.F.,,.T.,,;
		.F.,{|| (!Empty(cTable) .or. !Empty(cModelo)) },.F.,.F.,,.F.,.F. ,,"cDesc",,,,,,,OemToAnsi(STR0003),1)		
		oDesc:bGotFocus := {||U_fSetHelp(oSayH2,STR0133)}

		oTabAux := TGet():New(nRow,nCol+180, {|u|if(PCount()==0,cTabAux,cTabAux := u)},,45,14,"@!",{||If (fAtuRCB(cTable,cTabAux,@cDesc2,@cFile,@aCols,@lDpAuto,@lWhenDP,cCpoDP,@cSequencia),(oGetImp:SetArray(aCols),oGetImp:Refresh(.T.)),.F.)}, 0, nClrBack,,.F.,,.T.,,.F.,;
		{|| (cTable == "RCB")},.F.,.F.,,.F.,.F. ,"RCB","cTabAux",,,,,,,"Tab.Aux.",1)
		oTabAux:bGotFocus := {||U_fSetHelp(oSayH2,STR0132)}		
		
		oDesc2 := TGet():New( nRow, nCol+230, {|u|if(PCount()==0,cDesc2,cDesc2 := u)},,110, 014, "@!",, 0, nClrBack,,.F.,,.T.,,;
		.F.,{|| (cTable == "RCB") .and. !Empty(cTabAux) },.F.,.F.,,.F.,.F. ,,"cDesc2",,,,,,,"Desc.",1)		
		oDesc2:bGotFocus := {||U_fSetHelp(oSayH2,STR0133)}
		
		oCombo := TComboBox():New(nRow,nCol+350,{|u|if(PCount()>0,cModelo:=u,cModelo)};
		,aModels,75,40,,,bValCombo,,,,.T.,,,,{|| Empty(cTable) },,,,,'cModelo',OemToAnsi(STR0006),1)
		oCombo:bGotFocus := {||U_fSetHelp(oSayH2,STR0137 + CRLF + STR0138)}
		
		oFile := TGet():New( nRow, nCol+445, {|u|if(PCount()==0,cFile,cFile := u)},,110, 014, "@!",, 0, nClrBack,,.F.,,.T.,,;
		.F.,{|| (!Empty(cTable) .or. (!Empty(cModelo) .and. cModelo <> "RHIMP23")) },.F.,.F.,,.F.,.F. ,,"cFile",,,,,,,OemToAnsi(STR0124),1)
		oFile:bGotFocus := {||U_fSetHelp(oSayH2,STR0134)}		
		
		oFind  := TGet():New( (nRow*1.80), nCol+10, { | u | If( PCount() == 0, cFind, cFind := u ) },;
		,90, 014, "@!",{|| fFindGet(@oGetImp,cFind),.T.}, 0, nClrBack,,.F.,,.T.,,.F.,{|| (!Empty(cTable) .or. !Empty(cModelo)) },.F.,.F.,,.F.,.F. ,,"cFind",,,,,,,OemToAnsi(STR0031),1,,, OemToAnsi(STR0194))
		oFind:bGotFocus := {||U_fSetHelp(oSayH2,STR0135 + CRLF + STR0136)}

		oSequencia := TGet():New( nRow*1.80, nCol+140, { | u | If( PCount() == 0, cSequencia, cSequencia := u ) },,030, 014, "@!",, 0, nClrBack,,.F.,,.T.,,.F.,{|| (!Empty(cTable) .or. !Empty(cModelo))},.F.,.F.,,.F.,.F. ,,"cSequencia",,,,,,,OemToAnsi(STR0123),1)
		oSequencia:bGotFocus := {||U_fSetHelp(oSayH2,STR0139 + CRLF + STR0140)}
		
		oChkBox:= TCheckBox():New((nRow*2) ,nCol+230,STR0125,{||lDPAuto},oDlgAux,100,210,,{|| lDPAuto:=!lDPAuto },,,,,,.T.,,,{|| lWhenDP }) //"De-Para Automático?"
		oChkBox:bGotFocus := {||U_fSetHelp(oSayH2,STR0141 + CRLF + STR0142)}
		
		oTBtnBmp := TBtnBmp2():New((nRow*2)+70,nCol+650,25,25,'textjustify',,,,{||fGeraTXT(cTable,cModelo,cFile,oGetImp:aCols)},oDlgAux,OemToAnsi(STR0195),{||!Empty(cTable) .or. !Empty(cModelo)})
	
		aAdd( aHeader , { STR0021 , "CAMPO", "@!", 10, 0, "" , ,"C","",,,,}) 															//Campo
		aAdd( aHeader , { STR0032 , "TITULO", "@!", 12, 0, "" , ,"C","",,,,})  															//"Título"
		aAdd( aHeader , { STR0033 , "TIPO", "@!", 1, 0, "" , ,"C","",,,,}) 								 								//"Tipo"
		aAdd( aHeader , { STR0034 , "OBRIGAT", "@!", 1, 0, "" , ,"C","",,,,})								  							//"Obrigatório"
		aAdd( aHeader , { STR0035 , "POSICAO", "999", 3, 0, "" , ,"N",,,,,"Empty(cModelo) .and. U_fSetHelp(oSayH2,'" + STR0130 + "')" })//"Posição"
		aAdd( aHeader , { STR0037 , "FORMULA", "@!", 150, 0, "" , ,"C",,,,,"U_fSetHelp(oSayH2,'" + STR0131 + "')" })						//"Fórmula"
		
		oGetImp	 := MsNewGetDados():New(oSize:GetDimension("GETIMP","LININI")*1.5		,;	// 1  nTop
									 	oSize:GetDimension("GETIMP","COLINI") + 5	,;  // 2  nLelft
									 	oSize:GetDimension("GETIMP","LINEND") - 15	,;	// 3  nBottom
									 	oSize:GetDimension("GETIMP","COLEND") 		,;	// 4  nRright
									 	GD_UPDATE			 						,;  // 5  Controle do que podera ser realizado na GetDado - nstyle
										'u_VldRHLay()'						,;	// 6  Funcao para validar a edicao da linha - ulinhaOK
									 	.T.											,;	// 7  Funcao para validar todas os registros da GetDados - uTudoOK
	  								 	Nil											,;	// 8  cIniCPOS
									 	{"POSICAO","FORMULA"}						,;	// 9  aAlter
									 	0			  								,; 	// 10 nfreeze
									 	99999										,;  // 11 nMax
									 	Nil											,;	// 12 cFieldOK
									 	Nil											,;	// 13 usuperdel
									 	Nil											,;	// 14 udelOK
									 	@oDlgAux									,; 	// 15 Objeto de dialogo - oWnd
									 	@aHeader    								,;	// 16 Vetor com Colunas - AparHeader
									 	@aCols	 	    							)	// 17 Vetor com Header - AparCols
	
			bSet15 := { || nOpcA := 1 , aCols := oGetImp:aCols, (If(fGravaLayout(aCols,cDesc,cTable,cDesc2,cTabAux,cFile,@aColsIMP,lDpAuto,If(Empty(cTable),cModelo,""),cSequencia),oDlgAux:End(),Nil))}
			bSet24 := { || nOpcA := 0 , oDlgAux:End() }
						
			//Cria barra de Help inferior
			U_HelpFoot(@oSayH1,@oSayH2,oDlgAux,oSize,"HELPER")
			
			//Carrega informações sobre a rotina na barra de Help
			u_fSetHelp(oSayH1,STR0143 + CRLF + STR0144 + CRLF + STR0145 + CRLF + STR0146)
			
			//Carrega informações sobre o primeiro campo com foco (tabela)
			U_fSetHelp(oSayH2,STR0132)
			
	ACTIVATE Dialog oDlgAux ON INIT ( EnchoiceBar( oDlgAux , bSet15 , bSet24,,,,,,,.F.),U_fDescBar(oDlgAux,STR0030)) VALID U_EscPress(nOpcA)
	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} fGravaLayout
	Gravação dos layouts
@author Leandro Drumond
@since 13/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fGravaLayout(aCols,cDesc,cTable,cDesc2,cTabAux,cFile,aColsIMP,lDpAuto,cModelo,cSequencia)
Local aArea		:= GetArea()
Local aModels 	:= InfRhImp("",4)
Local cOrdem	:= "00"
Local cNameAux  := "%" + cArqGen + "%"
Local cAliasAux	:= GetNextAlias()
Local cCpoDP	:= U_fLoadCpo(.F.)
Local nPos		:= 0
Local lRet		:= .T.
Local cChave := ''

If !Empty(cModelo)
	nPos := (aScan(aModels,{|x| x[1] == cModelo}))
	cModelo := aModels[nPos,2]
EndIf

Begin Sequence
	If Empty(cTable) .and. Empty(cModelo)
		MsgAlert(STR0089) //"A tabela deve ser informada"
		lRet := .F.
		Break
	EndIf
	
	If Empty(cDesc)
		MsgAlert(STR0090) //"A descrição deve ser informada"
		lRet := .F.
		Break
	EndIf
	
	If Empty(cFile) .and. cModelo <> "RHIMP23" //RHIMP23 - Períodos, não possui arquivo TXT.
		MsgAlert(STR0091) //"O nome do arquivo deve ser informado"
		lRet := .F.
		Break
	Else
		If cModelo <> "RHIMP23" .and. At(".",cFile) == 0
			cFile := AllTrim(UPPER(cFile))+ ".TXT"
		EndIf
	EndIf		
	
	If Empty(cModelo) //Só valida a get se não for modelo (RHIMP)
		For nPos := 1 to Len(aCols)
			If aCols[nPos,4] == "S" .and. Empty(aCols[nPos,5]) .and. Empty(aCols[nPos,6])
				lRet := .F.
				MsgAlert(STR0093 + aCols[nPos,1] + STR0094) //"O campo " ### " é obrigatório e não possui posição ou fórmula definida."
				Exit
			EndIf
		Next nPos
	EndIf
	
	If !lRet
		Break
	EndIf
	
	DbSelectArea(cAliasGen)
		
	//Se já existir informações,atualiza
	If DbSeek(Padr(cTable,3)+Padr(cTabAux,4)+Padr(cModelo,7))
		BEGIN TRANSACTION
			For nPos := 1 to Len(aCols)
				cChave := Padr(cTable,3)+Padr(cTabAux,4)+Padr(cModelo,7) + aCols[nPos,1] 
				If(DbSeek(cChave))
					/*É preciso um while pois em alguns layouts o mesmo campo se repete.*/
					While ( !(Eof()) .And. (TABELA+TABAUX+MODELO+CAMPO == cChave))
						RecLock(cAliasGen,.F.)
						TIPO	  := aCols[nPos,3]
						POSICAO   := aCols[nPos,5]			
						DEPARA	  := If(lDpAuto .and. AllTrim(aCols[nPos,1]) $ cCpoDP,"1","2")
						FORMULA   := aCols[nPos,6]
						DESCRIC	  := cDesc
						ARQUIVO   := UPPER(cFile)
						MODELO	  := cModelo
						SEQUENCIA := cSequencia
						MsUnLock()						
						dbSkip()
					EndDo
				endIf
			Next nPos
		END TRANSACTION
		If ( !Empty(cModelo) .AND. ( nPos := (aScan(aColsIMP,{|x| AllTrim(x[6]) == cModelo}))) > 0) .OR.; //Se for leiaute por modelo
			( !Empty(cTabAux) .AND. ( nPos := (aScan(aColsIMP,{|x| AllTrim(x[4]) == cTabAux}))) > 0) .OR.; //Se for leiaute por Tab.Auxiliar
			( !Empty(cTable) .AND. ( nPos := (aScan(aColsIMP,{|x| AllTrim(x[4]) == cTable}))) > 0) //Se for leiaute por tabela
		
			aColsIMP[nPos,3] := If(!Empty(cDesc2), cDesc2, cDesc) //inclui a Descricao da Tab.Aux caso o leiaute for da Tab.Aux.
			aColsIMP[nPos,5] := UPPER(cFile)
			If aColsIMP[nPos,7] <> cSequencia
				aColsIMP[nPos,7] := cSequencia
				aSort(aColsIMP, , , {|x,y|x[7] < y[7]})
			EndIf			
		EndIf
	Else
		BeginSql alias cAliasAux
			SELECT MAX(CODIGO) AS MAXCOD
			FROM %exp:cNameAux% TMP
			WHERE TMP.%NotDel%
		EndSql
		
		If (cAliasAux)->(!Eof())
			cCodigo := Soma1((cAliasAux)->(MAXCOD))
		Else
			cCodigo := "000001"
		EndIf
		
		(cAliasAux)->(DbCloseArea())

		If cTable != "RCB"
			aAdd(aColsIMP,{.F.,cCodigo,cDesc,cTable,UPPER(cFile),cModelo,cSequencia})
		Else
			aAdd(aColsIMP,{.F.,cCodigo,cDesc2,cTabAux,UPPER(cFile),cModelo,cSequencia})
		EndIf
		
		/*Ou grava todos ou nenhum!*/
		BEGIN TRANSACTION			
			For nPos := 1 to Len(aCols)
				cOrdem := Soma1(cOrdem)
				RecLock(cAliasGen,.T.)
				CODIGO 	  := cCodigo
				DESCRIC	  := cDesc
				TABELA	  := cTable
				DESC2	:= cDesc2
				TABAUX	:= cTabAux
				CAMPO	  := aCols[nPos,1]
				ORDEM	  := cOrdem
				TIPO	  := aCols[nPos,3]
				POSICAO	  := aCols[nPos,5]
				DEPARA	  := If(lDpAuto .and. AllTrim(aCols[nPos,1]) $ cCpoDP,"1","2")
				FORMULA	  := aCols[nPos,6]
				ARQUIVO   := UPPER(cFile)
				MODELO    := cModelo
				SEQUENCIA := cSequencia
				If cTable == "RCB"
					CAMPOTAM	:= ACOLS[NPOS,7]
					CAMPODEC	:= ACOLS[NPOS,8]
				EndIf
				MsUnLock()
			Next nPos
		END TRANSACTION
		
		aSort(aColsIMP, , , {|x,y|x[7] < y[7]})
	EndIf
End Sequence

RestArea(aArea)

Return lRet

/*/{Protheus.doc} fFindGet
	Procura campo na getdados
@author Leandro Drumond
@since 20/07/2016
@version P12.1.7
@return aTable
/*/
Static Function fFindGet(oGetImp,cFind)
Local nX		:= 0
Local lAchou	:= .F.

If !Empty(cFind)
	cFind := AllTrim(UPPER(cFind))
	For nX := 1 to Len(oGetImp:aCols)
		If cFind $ AllTrim(UPPER(oGetImp:aCols[nX,1])) .or. cFind $ AllTrim(UPPER(oGetImp:aCols[nX,2])) .or. cFind $ AllTrim(UPPER(oGetImp:aCols[nX,6]))
			oGetImp:GoTo(nX)
			oGetImp:Refresh()
			lAchou := .T.
			Exit
		EndIf
	Next nX
	If !lAchou
		MsgInfo(STR0038) //"Nenhuma referência localizada."
	EndIf
EndIf

Return .T.

/*/{Protheus.doc} fAtuGet
	Atualiza getdados
@author Leandro Drumond
@since 13/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fAtuGet(cTable,cDesc,cTabAux,cDesc2,cFile,aCols,lDpAuto,lWhenDP,cCpoDP,cSequencia,cModelo,lSeq)
Local aArea		:= GetArea()
Local aCampos	:= {}
Local aAux		:= {}
Local cObrigat	:= ""
Local cNameAux  := "%" + cArqGen + "%"
Local cAliasAux	:= GetNextAlias()
Local cAliasMax := ""
Local cTitulo	:= ""
Local nPos		:= 1
Local nX
Local aModels 	:= InfRhImp("",4)

DEFAULT lSeq 	:= .T.

nPos  := 1
aCols := {}
cFile := Space(20)
cDesc := Space(20)
cTabAux := Space(4)
cDesc2 := Space(20)
cSequencia := Space(3)

lDpAuto := .F.
lWhenDP	:= .F.

If Empty(cTable) .and. Empty(cModelo)
	aAdd(aCols,{"","","","",0,"",0,0,.T.})
	Return .T.
EndIf

If !Empty(cModelo)
	nPos := (aScan(aModels,{|x| x[1] == cModelo}))
	cModelo := aModels[nPos,2]
EndIf

DbSelectArea("SX3")
DbSetOrder(2)

If !Empty(cTable)
	BeginSql alias cAliasAux
		SELECT * 
		FROM %exp:cNameAux% TMP
		WHERE TABELA = %exp:cTable% AND TMP.%NotDel% 
	 	    ORDER BY ORDEM
	EndSql
Else
	BeginSql alias cAliasAux
		SELECT * 
		FROM %exp:cNameAux% TMP
		WHERE MODELO = %exp:cModelo% AND TMP.%NotDel%
	 	    ORDER BY ORDEM
	EndSql
EndIf

If (cAliasAux)->(!Eof())
	cDesc := (cAliasAux)->DESCRIC
	aCampos := U_fGetCpoMod(cModelo)

	IF CTABLE != "RCB"
		cFile := (cAliasAux)->ARQUIVO
		cSequencia := (cAliasAux)->SEQUENCIA
		While (cAliasAux)->(!Eof())
			If SX3->(DbSeek((cAliasAux)->CAMPO))
				cTitulo := X3Titulo()
				cObrigat := If(X3Obrigat(CAMPO) .or. "FILIAL" $ CAMPO,"S","N")
			ElseIf "EMPRESA" $ AllTrim((cAliasAux)->CAMPO)
				cTitulo	:= STR0172
				cObrigat := "N"
			ElseIf "FILLER" $ AllTrim((cAliasAux)->CAMPO)
				cTitulo	:= ''
				cObrigat := "N"
			Else
				For nX := 1 to Len(aCampos)
					If ValType(aCampos[nX,1]) == "A"
						aAux := aClone(aCampos[nX])
					Else
						aAux := aClone(aCampos)
					EndIf
					If (nPos := (aScan(aAux,{|x| AllTrim((cAliasAux)->CAMPO) $ AllTrim(x[1])}))) > 0 .and. Len(aAux[nPos]) > 2
						cTitulo := aAux[nPos,3]
						cObrigat := aAux[nPos,5]
						Exit
					EndIf
				Next nX
			EndIf
			If (cAliasAux)->DEPARA == "1"
				lDpAuto := .T.
			EndIf
			If AllTrim((cAliasAux)->CAMPO) $ cCpoDP
				lWhenDP := .T.
			EndIf
			(cAliasAux)->(aAdd(aCols,{CAMPO,cTitulo,TIPO,cObrigat,POSICAO,FORMULA,0,0,.F.}))
			(cAliasAux)->(DbSkip())
		EndDo
	EndIf
Else
	If lSeq
		cAliasMax	:= GetNextAlias()
		BeginSql alias cAliasMax
			SELECT MAX(SEQUENCIA) AS MAXSEQ
			FROM %exp:cNameAux% TMP
			WHERE TMP.%NotDel%
		EndSql
		cSequencia := Soma1((cAliasMax)->MAXSEQ)  
		(cAliasMax)->(DbCloseArea())
	EndIf
	If Empty(cTable)
		cFile := InfRhImp(cModelo,2)
		cDesc := InfRhImp(cModelo,3)
		aCols := fCpoModel(cModelo,@lWhenDP,cCpoDP)
	Else
		DbSelectArea("SX2")
		If !dbSeek(cTable)
			aAdd(aCols,{"","","","",0,"",.T.})
			MsgStop(STR0126) //"Tabela não encontrada."
			Return(.F.)
		EndIf
		cDesc := X2NOME()

		IF CTABLE != "RCB"
			DbSelectArea("SX3")
			DbSetOrder(1)
			DbSeek(cTable)
			
			aAdd(aCols,{"EMPRESA",STR0172,"C","N",nPos,Space(50),0,0,.F.})
			
			While SX3->(!Eof() .and. X3_ARQUIVO == cTable)
				If SX3->X3_CONTEXT <> 'V'
					nPos++
					SX3->(aAdd(aCols,{X3_CAMPO,X3Titulo(),X3_TIPO,If(X3Obrigat(X3_CAMPO) .or. "FILIAL" $ X3_CAMPO,"S","N"),nPos,Space(50),0,0,.F.}))
					If AllTrim(SX3->X3_CAMPO) $ cCpoDP
						lWhenDP := .T.
					EndIf
				EndIf
				SX3->(DbSkip())
			EndDo
		ENDIF
	EndIf
EndIf

If Empty(aCols)
	aAdd(aCols,{"","","","",0,"",0,0,.T.})
EndIf

(cAliasAux)->(DbCloseArea())

RestArea(aArea)

Return .T.

Static Function fGeraTXT(cTable,cModelo,cFile,aCols)
Local aCampos	:= {}
Local aModels 	:= {}
Local cString	:= ""
Local cPath		:= GetTempPath()
Local nHandle
Local nX
Local nY
Local nPos

If Empty(cFile)
	cFile := "TESTE.TXT"
EndIf

cFile	:=	AllTrim(UPPER(cFile))
If At(".",cFile) == 0
	cFile += ".TXT"
EndIf

nHandle := 	MSFCREATE(cPath+cFile)

If FERROR() # 0 .Or. nHandle < 0
	Help("",1,"GPM600HAND")
	FClose(nHandle)
	Return Nil
EndIf

If !Empty(cModelo)
	aModels := InfRhImp("",4)
	nPos 	:= (aScan(aModels,{|x| x[1] == cModelo}))
	cModelo := aModels[nPos,2]
	
	aCampos := U_fGetCpoMod(cModelo)
	For nX := 1 to Len(aCampos)
		If Valtype(aCampos[nX,1]) == "A"
			aAux := aClone(aCampos[nX])
			For nY := 1 to Len(aAux)
				If !Empty(cString)
					cString += "|"
				EndIf
				cString += aAux[nY,1]
			Next nY
			For nY := 1 to nX //Imprime uma vezo cabeçalho e duas os itens
				FWrite(nHandle,cString + CRLF)
			Next nY
			cString := ""
		Else
			If !Empty(cString)
				cString += "|"
			EndIf
			cString += aCampos[nX,1]
		EndIf
	Next nX
	If !Empty(cString)
		For nX := 1 to 5 //Imprime 5 vezes a mesma linha
			FWrite(nHandle,cString + CRLF)
		Next nX
	EndIf
Else
	aAux := aClone(aCols)
	aSort(aAux, , , {|x,y|x[5] < y[5]})
	For nX := 1 to Len(aAux)
		If aAux[nX,5] == 0
			Loop
		EndIf
		If !Empty(cString)
			cString += "|"
		EndIf
		cString += AllTrim(aAux[nX,1])
	Next nX
	For nX := 1 to 5 //Imprime 5 vezes a mesma linha
		FWrite(nHandle,cString + CRLF)
	Next nX	
EndIf

FClose(nHandle)

ShellExecute('OPEN', cPath + cFile , '', '', 5)

Return Nil

User Function GenLayRH(aRet)
	Local aArea	:= 	GetArea()
	Local aModels	:= {}
	Local aColsMod	:= {}
	Local cDesc		:= ""
	Local cFile		:= ""
	Local cTabAux		:= ""
	Local cDesc2		:= ""
	Local nX		:= 0
	Default aRet := {}
	
	aModels := InfRhImp("",4)
	
	For nX := 1 to Len(aModels)
		fAtuGet("",@cDesc,@cTabAux,@cDesc2,@cFile,@aColsMod,,,"","",aModels[nX,1],.F.)
		fGravaLayout(aColsMod,cDesc,"","","",cFile,@aRet,.F.,aModels[nX,1],StrZero(nX,3))
	Next nX
	
	RestArea(aArea)
Return nil

/*/{Protheus.doc} InfRhImp
	Retorna dados dos modelos RHIMP
@author Leandro Drumond
@since 23/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function InfRhImp(cModelo,nTipo)
Local uRet

If nTipo == 1
	uRet := {}
	aAdd(uRet,"")
	aAdd(uRet,STR0064) //"Funções=RHIMP02"
	aAdd(uRet,STR0065) //"Centro de Custos=RHIMP03"
	aAdd(uRet,STR0066) //"Departamentos=RHIMP04"
	aAdd(uRet,STR0067) //"Sindicatos=RHIMP05"
	aAdd(uRet,STR0068) //"Verbas=RHIMP06"
	aAdd(uRet,STR0069) //"Turnos=RHIMP07"
	aAdd(uRet,STR0070) //"Funcionários=RHIMP08"
	aAdd(uRet,STR0071) //"Dependentes=RHIMP09"
	aAdd(uRet,STR0072) //"Ausências=RHIMP10"
	aAdd(uRet,STR0073) //"Histórico Salarial=RHIMP11"
	aAdd(uRet,STR0074) //"Folha de Pagamento=RHIMP12"
	aAdd(uRet,STR0075) //"Transferências=RHIMP13"
	aAdd(uRet,STR0076) //"Rescisões=RHIMP14"
	aAdd(uRet,STR0077) //"Férias=RHIMP15"
	aAdd(uRet,STR0078) //"13º Salário=RHIMP16"
	aAdd(uRet,STR0079) //"Horário Padrão=RHIMP17"
	aAdd(uRet,STR0080) //"Relógio de Ponto=RHIMP18"
	aAdd(uRet,STR0081) //"Crachás Provisórios=RHIMP19"
	aAdd(uRet,STR0083) //"Eventos=RHIMP21"
	aAdd(uRet,STR0082) //"Banco de Horas=RHIMP20"
	aAdd(uRet,STR0084) //"Item Contábil=RHIMP22"
	
//	aAdd(uRet,STR0085) //"Períodos=RHIMP23" // Não exibe Períodos, pois o mesmo é um layout em branco!

	aAdd(uRet,STR0086) //"Bancos=RHIMP24"
	aAdd(uRet,STR0087) //"Beneficários=RHIMP25"
	aAdd(uRet,STR0088) //"V.A/V.R.=RHIMP26"
	aAdd(uRet,STR0095) //"Plano de Saúde=RHIMP28"
ElseIf nTipo == 4
	uRet := {}
	aAdd(uRet,{STR0064,"RHIMP02"}) //"Funções=RHIMP02"
	aAdd(uRet,{STR0065,"RHIMP03"}) //"Centro de Custos=RHIMP03"
	aAdd(uRet,{STR0066,"RHIMP04"}) //"Departamentos=RHIMP04"
	aAdd(uRet,{STR0067,"RHIMP05"}) //"Sindicatos=RHIMP05"
	aAdd(uRet,{STR0068,"RHIMP06"}) //"Verbas=RHIMP06"
	aAdd(uRet,{STR0069,"RHIMP07"}) //"Turnos=RHIMP07"
	aAdd(uRet,{STR0070,"RHIMP08"}) //"Funcionários=RHIMP08"
	aAdd(uRet,{STR0071,"RHIMP09"}) //"Dependentes=RHIMP09"
	aAdd(uRet,{STR0072,"RHIMP10"}) //"Ausências=RHIMP10"
	aAdd(uRet,{STR0073,"RHIMP11"}) //"Histórico Salarial=RHIMP11"
	aAdd(uRet,{STR0074,"RHIMP12"}) //"Folha de Pagamento=RHIMP12"
	aAdd(uRet,{STR0075,"RHIMP13"}) //"Transferências=RHIMP13"
	aAdd(uRet,{STR0076,"RHIMP14"}) //"Rescisões=RHIMP14"
	aAdd(uRet,{STR0077,"RHIMP15"}) //"Férias=RHIMP15"
	aAdd(uRet,{STR0078,"RHIMP16"}) //"13º Salário=RHIMP16"
	aAdd(uRet,{STR0079,"RHIMP17"}) //"Horário Padrão=RHIMP17"
	aAdd(uRet,{STR0080,"RHIMP18"}) //"Relógio de Ponto=RHIMP18"
	aAdd(uRet,{STR0081,"RHIMP19"}) //"Crachás Provisórios=RHIMP19"
	aAdd(uRet,{STR0083,"RHIMP21"}) //"Eventos=RHIMP21"
	aAdd(uRet,{STR0082,"RHIMP20"}) //"Banco de Horas=RHIMP20"	
	aAdd(uRet,{STR0084,"RHIMP22"}) //"Item Contábil=RHIMP22"
	aAdd(uRet,{STR0085,"RHIMP23"}) //"Períodos=RHIMP23"
	aAdd(uRet,{STR0086,"RHIMP24"}) //"Bancos=RHIMP24"
	aAdd(uRet,{STR0087,"RHIMP25"}) //"Beneficários=RHIMP25"
	aAdd(uRet,{STR0088,"RHIMP26"}) //"V.A/V.R.=RHIMP26"
	aAdd(uRet,{STR0095,"RHIMP28"}) //"Plano de Saúde=RHIMP28"
Else
	Do Case 
		Case cModelo == "RHIMP02"
			uRet := If(nTipo==2,"cargo_logix.unl",STR0064) //"Funções"
		Case cModelo == "RHIMP03"
			uRet := If(nTipo==2,"ccusto_logix.unl",STR0065) //"Centro de Custos"
		Case cModelo == "RHIMP04"
			uRet := If(nTipo==2,"unidade_funcional_logix.unl",STR0066) //"Departamentos"
		Case cModelo == "RHIMP05"
			uRet := If(nTipo==2,"sindicato_logix.unl",STR0067) //"Sindicatos"
		Case cModelo == "RHIMP06"
			uRet := If(nTipo==2,"evento_logix.unl",STR0068) //"Verbas"
		Case cModelo == "RHIMP07"
			uRet := If(nTipo==2,"escala_logix.unl",STR0069) //"Turnos"
		Case cModelo == "RHIMP08"
			uRet := If(nTipo==2,"funcionario_logix.unl",STR0070) //"Funcionários"
		Case cModelo == "RHIMP09"
			uRet := If(nTipo==2,"dependente_logix.unl",STR0071) //"Dependentes"
		Case cModelo == "RHIMP10"
			uRet := If(nTipo==2,"afastamento_logix.unl",STR0072) //"Ausências"
		Case cModelo == "RHIMP11"
			uRet := If(nTipo==2,"historico_salarial_logix.unl",STR0073) //"Histórico Salarial"
		Case cModelo == "RHIMP12"
			uRet := If(nTipo==2,"folha_pagto_logix.unl",STR0074) //"Folha de Pagamento"
		Case cModelo == "RHIMP13"
			uRet := If(nTipo==2,"transferencias_logix.unl",STR0075) //"Transferências"
		Case cModelo == "RHIMP14"
			uRet := If(nTipo==2,"rescisao_logix.unl",STR0076) //"Rescisão"
		Case cModelo == "RHIMP15"
			uRet := If(nTipo==2,"ferias_logix.unl",STR0077) //"Férias"
		Case cModelo == "RHIMP16"
			uRet := If(nTipo==2,"13_salario_logix.unl",STR0078) //"13º Salário"
		Case cModelo == "RHIMP17"
			uRet := If(nTipo==2,"horarios_logix.unl",STR0079) //"Horário Padrão"
		Case cModelo == "RHIMP18"
			uRet := If(nTipo==2,"relogio_logix.unl",STR0080) //"Relógio de Ponto"
		Case cModelo == "RHIMP19"
			uRet := If(nTipo==2,"cracha_provisorio_logix.unl",STR0081) //"Crachás Provisórios"
		Case cModelo == "RHIMP20"
			uRet := If(nTipo==2,"banco_horas_logix.unl",STR0082) //"Banco de Horas"
		Case cModelo == "RHIMP21"
			uRet := If(nTipo==2,"ocorrencias_logix.unl",STR0083) //"Eventos"
		Case cModelo == "RHIMP22"
			uRet := If(nTipo==2,"area_linha_negocio_logix.unl",STR0084) //"Item Contábil"
		Case cModelo == "RHIMP23"
			uRet := If(nTipo==2,"",STR0085) //"Períodos"
		Case cModelo == "RHIMP24"
			uRet := If(nTipo==2,"banco_agencia_logix.unl",STR0086) //"Bancos"
		Case cModelo == "RHIMP25"
			uRet := If(nTipo==2,"pensionista_logix.unl",STR0087) //"Beneficiários"
		Case cModelo == "RHIMP26"
			uRet := If(nTipo==2,"alimentacao_logix.unl",STR0088) //"Vale Aliment./Refeição"
		Case cModelo == "RHIMP28"
			uRet := If(nTipo==2,"plano_saude_logix.unl",STR0095) //"Plano de Saúde"
	EndCase
EndIf

Return uRet

/*/{Protheus.doc} fCpoModel
	Carrega campos chave do modelo selecionado
@author Leandro Drumond
@since 26/07/2016
@version P12.1.7
@return Nil, Valor Nulo
/*/
Static Function fCpoModel(cModelo,lWhenDP,cCpoDP)
Local aRet		:= {}
Local aCampos	:= {}
Local aAux		:= {}
Local nPos		:= 0
Local nX		:= 0
Local nY		:= 0

DbSelectArea("SX3")
DbSetOrder(2)

aCampos := U_fGetCpoMod(cModelo)

For nX := 1 to Len(aCampos)
	If ValType(aCampos[nX,1]) == "A"
		aAux := aClone(aCampos[nX])
		nPos := 0
		For nY := 1 to Len(aAux)
			nPos++
			If "EMPRESA" $ aAux[nY,1] 
				aAdd(aRet,{"EMPRESA",STR0172,"C","N",nPos,Space(50),.F.})
			ElseIf "##" $ aAux[nY,1]
				aAdd(aRet,{StrTran(aAux[nY,1],"##",""),aAux[nY,3],aAux[nY,4],aAux[nY,5],nPos,Space(50),.F.})
			Else
				If AllTrim(aAux[nY,1]) $ cCpoDP
					lWhenDP := .T.
				EndIf				
				SX3->(DbSeek(aAux[nY,1]))
				SX3->(aAdd(aRet,{aAux[nY,1],X3Titulo(),X3_TIPO,If(X3Obrigat(X3_CAMPO),"S","N"),nPos,Space(50),.F.}))
			EndIf
		Next nY
	ElseIf "EMPRESA" $ aCampos[nX,1] 
		nPos++
		aAdd(aRet,{"EMPRESA",STR0172,"C","N",nPos,Space(50),.F.})
	ElseIf "##" $ aCampos[nX,1]
		nPos++
		aAdd(aRet,{StrTran(aCampos[nX,1],"##",""),aCampos[nX,3],aCampos[nX,4],aCampos[nX,5],nPos,Space(50),.F.})
	Else
		nPos++
		If AllTrim(aCampos[nX,1]) $ cCpoDP
			lWhenDP := .T.
		EndIf		
		SX3->(DbSeek(aCampos[nX,1]))
		SX3->(aAdd(aRet,{aCampos[nX,1],X3Titulo(),X3_TIPO,If(X3Obrigat(X3_CAMPO),"S","N"),nPos,Space(50),.F.}))
	EndIf
Next nX

Return aRet

/*/{Protheus.doc} VldRHLay
	uLinhaOk da MsNewGetDados dessa rotina.
@author philipe.pompeu
@since 15/12/2016
@version P12.1.15
@return ${return}, ${return_description}
/*/
User Function VldRHLay()
	Local lRet		:= .T.
	Local aRegistro := aCols[n]
	if(Empty(cModelo)) //Só valida para layouts dinâmicos(não os do Logix)		
		If !aTail(aRegistro) //Linha não esta deletada		
			/*Se for obrigatório ou for o campo EMPRESA e não tiver uma posição válida e a fórmula estiver vazia*/
			if((aRegistro[4] == 'S' .Or. AllTrim(aRegistro[1]) == 'EMPRESA') .And. (aRegistro[5] == 0 .And. Empty(aRegistro[6])))
				MsgAlert(OemToAnsi(STR0199))//Para todo campo obrigatório deve-se informar uma posição ou uma fórmula
				lRet := .F.			
			endIf		
		EndIf
	endIf	
Return lRet


/*/{Protheus.doc} fAtuRCB
	Função responsável pela manutenção dos leiautes das tabelas genéricas
@author esther.viveiro
@since 13/01/2017
@version P12.1.16
@param cTable, 	caracter, nome da tabela principal do leiaute em manutenção
@param cTabAux,	caracter, nome da tabela auxiliar do leiaute em manutenção
@param cDesc2,	caracter, descrição da tabela auxiliar
@param cFile,	caracter, nome do arquivo texto que será importado
@param aCols,	array, estrutura da tabela GPETABGEN a ser gravada
@param lDpAuto,	logic, definição de De/Para automatico
@param lWhenDP,	logic, validação do De/Para
@param cCpoDP,	caracter, campo para De/Para
@param cSequencia,	caracter, código de sequencia do leiaute em manutenção

@return logic, verdadeiro
/*/
Static Function fAtuRCB(cTable,cTabAux,cDesc2,cFile,aCols,lDpAuto,lWhenDP,cCpoDP,cSequencia)
Local aArea		:= GetArea()
Local aCampos	:= {}
Local aAux		:= {}
Local cObrigat	:= ""
Local cNameAux  := "%" + cArqGen + "%"
Local cAliasAux	:= GetNextAlias()
Local cAliasMax := ""
Local cTitulo	:= ""
Local nPos		:= 1
Local nX
Local aModels 	:= InfRhImp("",4)

DEFAULT lSeq 	:= .T.

nPos  := 1
aCols := {}
cFile := Space(20)
cDesc2 := Space(20)
cSequencia := Space(3)

lDpAuto := .F.
lWhenDP	:= .F.

If Empty(cTable) .and.  Empty(cTabAux) .and. Empty(cModelo)
	aAdd(aCols,{"","","","",0,"",0,0,.T.})
	Return .T.
EndIf

If !Empty(cModelo)
	nPos := (aScan(aModels,{|x| x[1] == cModelo}))
	cModelo := aModels[nPos,2]
EndIf

DbSelectArea("RCB")
DbSetOrder(1)

If !Empty(cTabAux)
	BeginSql alias cAliasAux
		SELECT * 
		FROM %exp:cNameAux% TMP
		WHERE TABAUX = %exp:cTabAux% AND TMP.%NotDel% 
	 	    ORDER BY ORDEM
	EndSql

	If (cAliasAux)->(!Eof())
		cFile := (cAliasAux)->ARQUIVO
		cDesc2 := (cAliasAux)->DESC2
		cSequencia := (cAliasAux)->SEQUENCIA
		aCampos := U_fGetCpoMod(cModelo)
		
		RCB->(DbSeek(xFilial("RCB")+(cAliasAux)->TABAUX))
		While (cAliasAux)->(!Eof())
			If RCB->RCB_CAMPOS == (cAliasAux)->CAMPO
				cTitulo := RCB->RCB_DESCPO
				cObrigat := If(!Empty(RCB->RCB_VALID) .AND. ("NAOVAZIO()" $ RCB->RCB_VALID),"S","N")
				RCB->(DBSKIP())
			ElseIf "EMPRESA" $ AllTrim((cAliasAux)->CAMPO)
				cTitulo	:= STR0172
				cObrigat := "N"
			ElseIf AllTrim((cAliasAux)->CAMPO) == ("RCC_FILIAL") .OR. AllTrim((cAliasAux)->CAMPO) == ("RCC_FIL")
				cTitulo	:= "FILIAL"
				cObrigat 	:= "N"
			ElseIf AllTrim((cAliasAux)->CAMPO) == "RCC_CHAVE"
				cTitulo	:= "ANO/MES"
				cObrigat 	:= "N"
			Else
				For nX := 1 to Len(aCampos)
					If ValType(aCampos[nX,1]) == "A"
						aAux := aClone(aCampos[nX])
					Else
						aAux := aClone(aCampos)
					EndIf
					If (nPos := (aScan(aAux,{|x| AllTrim((cAliasAux)->CAMPO) $ AllTrim(x[1])}))) > 0 .and. Len(aAux[nPos]) > 2
						cTitulo := aAux[nPos,3]
						cObrigat := aAux[nPos,5]
						Exit
					EndIf
				Next nX
			EndIf
			If (cAliasAux)->DEPARA == "1"
				lDpAuto := .T.
			EndIf
			If AllTrim((cAliasAux)->CAMPO) $ cCpoDP
				lWhenDP := .T.
			EndIf
			(cAliasAux)->(aAdd(aCols,{CAMPO,cTitulo,TIPO,cObrigat,POSICAO,FORMULA,CAMPOTAM,CAMPODEC,.F.}))
			(cAliasAux)->(DbSkip())
		EndDo
	Else
		If lSeq
			cAliasMax	:= GetNextAlias()
			BeginSql alias cAliasMax
				SELECT MAX(SEQUENCIA) AS MAXSEQ
				FROM %exp:cNameAux% TMP
				WHERE TMP.%NotDel%
			EndSql
			cSequencia := Soma1((cAliasMax)->MAXSEQ)  
			(cAliasMax)->(DbCloseArea())
		EndIf
		If !Empty(cTabAux)
			DbSelectArea("RCB")
			If !dbSeek(xFilial("RCB")+cTabAux)
				aAdd(aCols,{"","","","",0,"",0,0,.T.})
				MsgStop(STR0126) //"Tabela não encontrada."
				Return(.F.)
			EndIf
			cDesc2 := RCB->(RCB_DESC)
	
			DbSelectArea("RCB")
			DbSetOrder(1)
			DbSeek(xFilial("RCB")+cTabAux)
			
			aAdd(aCols,{"EMPRESA",STR0172,"C","N",nPos,Space(50),0,0,.F.})
			//inclusao de campos essenciais da RCC.
			nPos++
			aAdd(aCols,{"RCC_FILIAL","FILIAL","C","N",nPos,Space(50),0,0,.F.})
			nPos++
			aAdd(aCols,{"RCC_FIL","FILIAL","C","N",nPos,Space(50),0,0,.F.})
			nPos++
			aAdd(aCols,{"RCC_CHAVE","ANO/MES","C","N",nPos,Space(50),0,0,.F.})
			
			While RCB->(!Eof() .and. RCB_CODIGO == cTabAux)
				nPos++
				RCB->(aAdd(aCols,{RCB_CAMPOS,RCB_DESCPO,RCB_TIPO,If(!Empty(RCB_VALID) .AND. ("NAOVAZIO()" $ RCB_VALID),"S","N"),nPos,Space(50),RCB_TAMAN,RCB_DECIMA,.F.}))
				RCB->(DbSkip())
			EndDo			
		EndIf
	EndIf
	
	RCB->(DbCloseArea())
	(cAliasAux)->(DbCloseArea())
EndIf

If Empty(aCols)
	aAdd(aCols,{"","","","",0,"",0,0,.T.})
EndIf


RestArea(aArea)

RETURN .T.

