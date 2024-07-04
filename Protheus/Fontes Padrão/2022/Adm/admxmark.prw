#INCLUDE "PROTHEUS.CH"
#INCLUDE "ADMXMARK.CH" 
#Include "ApWizard.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADMXMARK  ºAutor  ³Microsiga           º Data ³  11/13/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcoes genericas para o SqlMark                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADM                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADMSQLMARKºAutor  ³ Evaldo V. Batista  º Data ³  10/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funçao que monta markbrowse no objeto passado              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADMXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ADMSQLMARK(cAlias, oFolder, aCpoBrw, cDesc, nOpc, cCond, lFilPad,cFilDe,cFilAte)
Local nTamCpo 		:= Len(SX3->X3_CAMPO)
Local aAreaSx3 		:= SX3->( GetArea() ) 
Local aAreaSix 		:= SIX->( GetArea() )                                 
Local aIndBox		:= {}
Local lMark			:= .F.
Local cGetMark		:= Space(80)
Local nPosMark 		:= 0
Local cNewAlias		:= ""
Local cFilExpr		:= ""
Local bFiltraBrw	:= {|| Nil}
Local nA			:= 0
Local cBCpo			:= ""
Local aHeaderTmp	:= {}
Local aFieldTmp		:= {}
Local oChkMark, oIndBox, oGetMark, nIndBox

DEFAULT lFilPad := .F.
DEFAULT cCond	:= ""
DEFAULT cFilDe	:= cFilAnt
DEFAULT cFilAte	:= cFilAnt

SX2->( dbSetOrder( 1 ) ) //ARQUIVO
If SX2->( dbSeek( cAlias, .F. ) ) 
	oFolder:AddItem( AllTrim(cDesc) ) 

	If ValType( aCpoBrw ) == 'A'
		SX3->( dbSetOrder( 2 ) ) //X3_CAMPO
		For nA := 1 To Len( aCpoBrw )                                                                     
			If SX3->( dbSeek( PadR(aCpoBrw[nA,1], nTamCpo), .F. ) ) 
				aCpoBrw[nA][3] := X3Titulo()
				aCpoBrw[nA][4] := AllTrim( SX3->X3_PICTURE ) 
				aAdd( aHeaderTmp, {TRIM(X3Titulo()),;
									SX3->X3_CAMPO,;
									SX3->X3_PICTURE,;
									SX3->X3_TAMANHO,;
									SX3->X3_DECIMAL,;
									SX3->X3_VALID,;
									SX3->X3_USADO,;
									SX3->X3_TIPO,;
									SX3->X3_ARQUIVO,;
									SX3->X3_CONTEXT} ) 
			Else
				aCpoBrw[nA][3] := " "
				aCpoBrw[nA][4] := " "
			EndIF
		Next nA                                                                                                
	EndIf
	
	nPosMark := aScan( aMarks, {|x| x[4] == cAlias } )
	If nPosMark == 0 
		Aadd(aPanels, Nil) 
		aPanels[Len(aPanels)] := TPanel():New(0,0,'',oFolder:aDialogs[Len(oFolder:aDialogs)],, .T., .T.,, ,30,30,.T.,.T. )
		aPanels[Len(aPanels)]:Align := CONTROL_ALIGN_TOP

		If nOpc <> 2 
			Aadd(aMarks, {Nil, cMarca, aCpoBrw, cAlias, {.F., 1, Space(80) } , cNewAlias := AdmMarkCrTab(cAlias, @aIndBox, aCpoBrw, nOpc, cCond, lFilPad ), Nil, {}, {} } )

			aMarks[Len(aMarks),1] := MsSelect():New(cNewAlias,aMarks[Len(aMarks),3][1,1],,aMarks[Len(aMarks),3],,aMarks[Len(aMarks),2],{1, 1, 90, 90},,,oFolder:aDialogs[Len(oFolder:aDialogs)],,)
			aMarks[Len(aMarks),1]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			
			aMarks[Len(aMarks),7] := SBUTTON():Create(oFolder:aDialogs[Len(oFolder:aDialogs)])
			aMarks[Len(aMarks),7]:cName := "fBtnFil"+AllTRim(Str(Len(aMarks)))
			aMarks[Len(aMarks),7]:cCaption := STR0001 //"Filtro"
			aMarks[Len(aMarks),7]:nLeft := 510
			aMarks[Len(aMarks),7]:nTop := 30
			aMarks[Len(aMarks),7]:nWidth := 52
			aMarks[Len(aMarks),7]:nHeight := 22
			aMarks[Len(aMarks),7]:lShowHint := .F.
			aMarks[Len(aMarks),7]:lReadOnly := .F.
			aMarks[Len(aMarks),7]:Align := 0
			aMarks[Len(aMarks),7]:lVisibleControl := .T.
			aMarks[Len(aMarks),7]:nType := 1
			aMarks[Len(aMarks),7]:bAction := {||	cFilExpr := BuildExpr(cAlias),; 
												ADMApFil(cNewAlias, cMarca, cFilExpr) } 
			oChkMark := TCHECKBOX():Create(aPanels[Len(aPanels)])
			oChkMark:cName 		:= "oChkMark"                                      
			oChkMark:cCaption 	:= STR0002 //'Selecionar Todos' 
			oChkMark:nLeft 		:= 05
			oChkMark:nTop 		:= 05
			oChkMark:nWidth 	:= 100
			oChkMark:nHeight 	:= 60
			oChkMark:lShowHint 	:= .F.
			oChkMark:lReadOnly 	:= .F.
			oChkMark:Align 		:= 0
			oChkMark:cVariable 	:= "lMark"
			oChkMark:bSetGet 	:= {|u| If(PCount()>0,lMark:=u,lMark) }
			oChkMark:bChange 	:= {|| ADMMkAll(cNewAlias, lMark, cMarca, cAlias) }
			oChkMark:lVisibleControl := .T.
			
			oIndBox := TCOMBOBOX():Create(aPanels[Len(aPanels)])
			oIndBox:cName 		:= "oIndBox"
			oIndBox:cCaption 	:= STR0003 //"Indice"
			oIndBox:nLeft 		:= 05
			oIndBox:nTop 		:= 30
			oIndBox:nWidth 		:= 200
			oIndBox:nHeight 	:= 21
			oIndBox:lShowHint 	:= .F.
			oIndBox:lReadOnly 	:= .F.
			oIndBox:Align 		:= 0
			oIndBox:cVariable 	:= "nIndBox"
			oIndBox:bSetGet 	:= {|u| If(PCount()>0,nIndBox:=u,nIndBox) }
			oIndBox:aItems 		:= aIndBox
			oIndBox:nAt 		:= 1                                                 
			oIndBox:bChange 	:= {|| (cNewAlias)->( dbSetOrder(oIndBox:nAt ) ) }
			oIndBox:lVisibleControl := .T.
			
			oGetMark := TGET():Create(aPanels[Len(aPanels)])
			oGetMark:cName 		:= "oGetMark"
			oGetMark:nLeft 		:= 220
			oGetMark:nTop 		:= 30
			oGetMark:nWidth 	:= 268
			oGetMark:nHeight 	:= 21
			oGetMark:lShowHint 	:= .F.
			oGetMark:lReadOnly 	:= .F.
			oGetMark:Align 		:= 0
			oGetMark:cVariable 	:= "cGetMark"                           
			oGetMark:bSetGet 	:= {|u| If(PCount()>0,cGetMark:=u,cGetMark) }
			oGetMark:lPassword 	:= .F.
			oGetMark:Picture 	:= "@!"
			oGetMark:lHasButton	:= .F.                                     
			oGetMark:bChange 	:= {|| (cNewAlias)->( dbSeek( xFilial(cNewAlias)+AllTrim(cGetMark), .T. ) ), aMarks[ aScan(aMarks, {|x| x[6] == cNewAlias}), 1]:oBrowse:Refresh()  }
			oGetMark:lVisibleControl := .T.
		Else
			aEval( aHeaderTmp, {|x| aAdd( aFieldTmp, x[1] ) } ) 
			Aadd(aMarks, {Nil, cMarca, aCpoBrw, cAlias, {.F., 1, Space(80) } , cNewAlias := AdmMarkCrTab(cAlias, @aIndBox, aCpoBrw, nOpc, cCond, lFilPad ), Nil, {}, aClone(aFieldTmp) } )

			oSayMsg := TSAY():Create(aPanels[Len(aPanels)])
			oSayMsg:cName := "oSayMsg"
			oSayMsg:cCaption := STR0004 //"Exibindo somente entidades selecionadas"
			oSayMsg:nLeft := 22
			oSayMsg:nTop := 18
			oSayMsg:nWidth := 361
			oSayMsg:nHeight := 17
			oSayMsg:lShowHint := .F.
			oSayMsg:lReadOnly := .F.
			oSayMsg:Align := 0
			oSayMsg:lVisibleControl := .T.
			oSayMsg:lWordWrap := .F.
			oSayMsg:lTransparent := .F.

			cBCpo 	:= "{|| {"
			aEval( aHeaderTmp, {|x| cBCpo += " "+cNewAlias+"->"+x[2]+","  } ) 
			cBCpo	:= Substr(cBCpo,1, Len(cBCpo)-1) + "} } "

			aMarks[Len(aMarks),1] := TWBrowse():New( 05,10,200,200,&(cBCpo),aMarks[Len(aMarks),9],,oFolder:aDialogs[Len(oFolder:aDialogs)],,,,,,,,,,,,.F.,cNewAlias,.T.,,.F.,,,)
			aMarks[Len(aMarks),1]:Align := CONTROL_ALIGN_ALLCLIENT

		EndIF
	Else
		cNewAlias := aMarks[nPosMark][6]
	EndIf                                                                                                 
	
EndIf

RestArea( aAreaSX3 )                                                                     
RestArea( aAreaSIX ) 

Return( cNewAlias )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AdmMarkCrTabºAutor³ Evaldo V. Batista  º Data ³  10/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de criacao de tabelas temporaria em banco de dados  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AdmMarkCrTab(cAlias, aIndBox, aCpoBrw, nOpc, cCond, lFilPad,cFilDe,cFilAte) 
Local nA		:= 	0
Local cIndKey	:= 	""
Local nIni,nPos	:= 	0
Local cNewAlias	:= 	""
Local aIndBoxK	:= 	{}
Local aCpoTab	:= 	{}
Local aCpoOri	:= 	(cAlias)->( dbStruct() ) 
Local cQuery	:= 	""
Local cCpo		:= 	""
Local cCampos	:=  ""
Local cFilConPad:= 	""
Local bFiltraBrw:= 	{|| Nil}
Local cPrefix 	:=	PrefixoCpo(cAlias)

While .T.
	cNewAlias := CriaTrab( , .F. )
	If !TCCanOpen(cNewAlias)
		Exit
	EndIf	
EndDo 

SXB->( dbSetOrder( 1 ) ) //XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA
IF SXB->(DbSeek(PADR(cAlias,Len(SXB->XB_ALIAS)," ")+"6"+"01")) .AND. !Empty(SXB->XB_CONTEM)
	cFilConPad := ALLTRIM(SXB->XB_CONTEM)
ENDIF

bBlock := ErrorBlock( { |e| ChecErro(e) } )
BEGIN SEQUENCE
	xResult := (cAlias)->&(cFilConPad)
RECOVER
	cFilConPad := ".T."
END SEQUENCE
ErrorBlock(bBlock)

aEval( aCpoBrw, {|x| aAdd( aCpoTab, {x[1], '', 0, 0 }  ) } ) 
For nA := 1 To Len(aCpoOri) 
	If aScan( aCpoTab, {|x| AllTrim(Upper(x[1])) == AllTrim(Upper(aCpoOri[nA,1])) } ) == 0
		aAdd( aCpoTab, {aCpoOri[nA,1], aCpoOri[nA,2], aCpoOri[nA,3], aCpoOri[nA,4] } ) 
	EndIf
Next nA

SIX->( dbSetOrder( 1 ) ) 
If SIX->( dbSeek( cAlias, .F. ) ) 
	While !SIX->( Eof() ) .and. SIX->INDICE == cAlias
		aAdd( aIndBox, SIX->DESCRICAO ) 
		aAdd( aIndBoxK, SIX->CHAVE ) 

		cIndKey := AllTrim( SIX->CHAVE ) 
		nIni 	:= 1
		If At( '+', cIndKey ) > 0
			While nIni < Len( cIndKey ) 
				nPos := At( '+', Substr( cIndKey, nIni) ) 
				If nPos == 0 
					nPos := Len(cIndKey)
				EndIf
				nIni += nPos
			EndDo
		EndIf
		SIX->( dbSkip() ) 
	EndDo
EndIf

For nA := 1 To Len(aCpoTab)
	cCampos += aCpoTab[nA][1] + ', '  
	If SX3->( dbSeek( aCpoTab[nA,1] ) ) 
		While !SX3->( Eof() ) .and.  SX3->X3_CAMPO = aCpoTab[nA,1]
			If AllTrim(SX3->X3_CAMPO) == aCpoTab[nA,1]
				cCpo += aCpoTab[nA][1] + ', '  
				aCpoTab[nA,2] := SX3->X3_TIPO
				aCpoTab[nA,3] := SX3->X3_TAMANHO
				aCpoTab[nA,4] := SX3->X3_DECIMAL
			EndIf
			SX3->( dbSkip() ) 
		EndDo
	ElseIf '_OK' $ aCpoTab[nA][1] 
		cCpo += " ' ', "
		aCpoTab[nA,2] := 'C'
		aCpoTab[nA,3] := 2
		aCpoTab[nA,4] := 0
	EndIf                                                                                                    
Next nA

MsErase(cNewAlias)
MsCreate(cNewAlias, aCpoTab, 'TOPCONN' ) 
dbUseArea( .T., 'TOPCONN', cNewAlias, cNewAlias, .T., .F. ) 
dbSelectArea( cNewAlias ) 
For nA := 1 To Len( aIndBoxK )
	INDEX ON &(aIndBoxK[nA]) TO (cNewAlias+StrZero(nA,2))
Next nA

(cNewAlias)->( dbClearIndex() ) 
For nA := 1 To Len( aIndBoxK ) 
	(cNewAlias)->( dbSetIndex(cNewAlias+StrZero(nA,2)) ) 
Next nA

(cNewAlias)->( dbSetOrder( 1 ) ) 
cQuery := "INSERT INTO " + cNewAlias + " ( " + cCampos + " D_E_L_E_T_, R_E_C_N_O_  ) " 
cQuery += "	SELECT " + cCpo + " D_E_L_E_T_, R_E_C_N_O_ "
cQuery += "	FROM " + RetSqlTab(cAlias) 
cQuery += "	WHERE D_E_L_E_T_ != '*' "
cQuery += "	AND "+cPrefix+"_FILIAL BETWEEN '"+xFilial(cAlias,cFilDe)+"' AND '"+xFilial(cAlias,cFilAte)+"' "
If (cAlias)->( FieldPos( cPrefix+"_CLASSE" ) ) > 0 
	cQuery += "	AND "+cPrefix+"_CLASSE = '2'"
EndIf
If nOpc == 2 .and. !Empty(cCond)
	cQuery += " AND "+aCpoTab[2,1]+" IN" + cCond
EndIf
If (nOpc == 2 .and. !Empty(cCond)) .or. nOpc <> 2
	If TcSqlExec( cQuery ) <> 0
		Help(" ",1,"ADMMNOTAB",, STR0005 + cAlias,1,0) //'Erro ao Criar Tabela Temporária! Alias: '
	EndIf
EndIf

If (nOpc == 4 .or. nOpc == 5) .and. !Empty(cCond)
	cQuery := "UPDATE " + cNewAlias 
	cQuery += "	SET "+If(SubStr(cAlias,1,1)=='S',SubStr(cAlias,2),cAlias)+"_OK = '"+cMarca+"'"
	cQuery += " WHERE "+aCpoTab[2,1]+" IN " + cCond
	If TcSqlExec( cQuery ) <> 0 
		Help(" ",1,"ADMMNOTAB",, STR0006 + cAlias,1,0) //'Erro ao aplicar seleção! Alias: '
	EndIf
EndIf

(cNewAlias)->( dbGoTop() ) 
TcRefresh(cNewAlias)
If lFilPad .and. !Empty( cFilConPad ) 
	TcSrvMap(cNewAlias)
	bFiltraBrw := {|x| If(x==Nil,FilBrowse(cNewAlias,@aIndexCab,@cFilConPad),{cFilConPad,"","","",aIndexCab}) }
	(cNewAlias)->( Eval(bFiltraBrw) ) 
	(cNewAlias)->( dbGoTop() ) 
	TcRefresh(cNewAlias)
Else
	(cNewAlias)->( dbClearFilter() ) 
EndIf

Return( cNewAlias ) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADMMkAll  ºAutor  ³ Evaldo V. Batista  º Data ³  10/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Marcacao de registros                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ADMMkAll(cNewAlias, lMark, cMarca, cAlias)
Local cQuery := ""
Local cCampo := If( Substr( cAlias, 1, 1 ) == 'S', SubsTr( cAlias, 2), cAlias ) + '_OK'
Local nPosTab:= (cNewAlias)->( Recno() ) 

cQuery := " UPDATE " + cNewAlias 
cQuery += " SET " + cCampo
cQuery += " = " + If( lMark, "'"+cMarca+"'", " '  ' " ) 
If TcSqlExec( cQuery ) == 0
	TcRefresh(cNewAlias) 
	(cNewAlias)->( dbGoTo( nPosTab ) ) 
	aMarks[aScan(aMarks, {|x| x[6]==cNewAlias}),1]:oBrowse:Refresh()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADMApFil  ºAutor  ³ Evaldo V. Batista  º Data ³  10/13/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Aplica filtro a tabela temporia                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ADMApFil(cNewAlias, cMarca, cFiltro) 
Local cCpo 			:= Substr( (cNewAlias)->( Field(1) ), 1, 3 ) 
Local bFiltraBrw 	:= {|| .T.}

If !Empty( cFiltro )    
	If Substr( cCpo, Len(cCpo)) == "_" 
		cCpo += "OK"
	Else
		cCpo += "_OK"
	EndIf
	(cNewAlias)->( dbClearFilter() ) 
	(cNewAlias)->( dbEval({|| RecLock(cNewAlias,.F.), FieldPut(FieldPos(cCpo),"  "), MsUnLock() }, {|| FieldGet(FieldPos(cCpo))==cMarca .and. !&(cFiltro) } ) )
	bFiltraBrw := {|x| If(x==Nil,FilBrowse(cNewAlias,@aIndexCab,@cFiltro),{cFiltro,"","","",aIndexCab}) }
	(cNewAlias)->( Eval(bFiltraBrw) ) 
Else
	(cNewAlias)->( dbClearFilter() ) 
EndIF
	
Return
 
