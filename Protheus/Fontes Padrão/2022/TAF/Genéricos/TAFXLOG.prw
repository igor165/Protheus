#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE QLABEL_AZUL_B "QLabel{ border-style:solid;border-color:#A0AAAE;border-bottom-width:3px;border-top-width:3px;background-color:#D6E4EA }"  
#DEFINE QLABEL_AZUL_C "QLabel{ border-style:solid;border-color:#A7B8BF;border-bottom-width:2px;background-color:#D6E4EA }" 
#DEFINE QLABEL_AZUL_D "QLabel{background-color:#D6E4EA;border-width:3px;border-color:#A7B8BF;color:#000000;}"	 				

//-------------------------------------------------------------------
/*/{Protheus.doc} TafXLog
Cria um log generico de processamento
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return cIdLog - Id do Log
/*/
//-------------------------------------------------------------------

Function TafXLog( cIdLog, cEvento, cTipo, cInfo, cPerApu )

	Local cTabLog	:= "V0K"
    Local aInfo     := {}
	Local cMsg		:= ""
	Local cPeriodo  := Iif( Type( "cPerAReinf" ) == "U", cPerApu, cPerAReinf )

	Default cIdLog	:= ""
	Default cEvento	:= ""
	Default cTipo	:= "INICIO"
	Default cInfo	:= ""
	Default cPerApu := ""

	If TAFAlsInDic("V0K")
		// ---------------- Indices ----------------------
		// 1 - V0K_FILIAL + V0K_PROCID
		// 2 - V0K_FILIAL + V0K_EVENTO + Dtos( V0K_DATA )
		// 3 - V0K_FILIAL + Dtos( V0K_DATA ) + V0K_EVENTO
		// -----------------------------------------------

		AADD(aInfo,"INICIO") // Inicio do Processamento
		AADD(aInfo,"FIM") // Final do Processamento
		AADD(aInfo,"ALERTA") // Alerta
		AADD(aInfo,"ERRO") // Erro 
		AADD(aInfo,"CANCEL") // Cancelado pelo usuario
		AADD(aInfo,"MENSAGEM") // Mensagem

		cTipo := Upper( cTipo )

		If cTipo == "INICIO" .Or. cTipo == "START" 
			cTipo 	:= "INICIO"
			cIdLog	:= GetNewID( cTabLog, cTabLog+"_PROCID")
			cMsg	:= "Inicio do processamento"	
		ElseIf cTipo == "FIM" .Or. cTipo == "END"
			cTipo 	:= "FIM"
			cMsg	:= "Fim do processamento"
		ElseIf cTipo == "MENSAGEM" .Or. cTipo == "MSG" .Or. cTipo == "INFO"
			cTipo	:= "MSG"
			cMsg	:= cInfo		
		ElseIf "ALERT" $ cTipo
			cTipo	:= "ALERTA"
			cMsg	:= "Alerta - " + cInfo
		ElseIf "ERRO" $ cTipo
			cTipo	:= "ERRO"
			cMsg	:= "Erro - " + cInfo
			if empty(cIdLog)
				cIdLog	:= GetNewID( cTabLog, cTabLog+"_PROCID")
			endif
		ElseIf "CANCEL" $ cTipo
			cTipo	:= "CANCEL"
			cMsg	:= "CANCEL - Cancelado pelo usuario "+ CRLF + cInfo
		EndIf

		DbSelectArea( "V0K" )
		V0K->(DbSetOrder( 1 ))
		RecLock( cTabLog , .T.)
			If TafColumnPos( "V0K_FILORI" ) 
				V0K->V0K_FILIAL	:= SM0->M0_CODFIL
				V0K->V0K_FILORI	:= xFilial(cTabLog)
			Else
				V0K->V0K_FILIAL	:= xFilial(cTabLog)
			EndIf
			V0K->V0K_PROCID	:= cIdLog
			V0K->V0K_SEQ	:= GetNewID( cTabLog, cTabLog+"_SEQ" , " AND "+cTabLog+"_PROCID = '"+cIdLog+"'")
			V0K->V0K_EVENTO	:= cEvento
			V0K->V0K_PERIOD	:= cPeriodo
			V0K->V0K_DATA	:= Date()
			V0K->V0K_HORA	:= Time()
			V0K->V0K_TIPO	:= cTipo
			V0K->V0K_ROTINA	:= FunName()
			V0K->V0K_USER	:= __cUserID
			V0K->V0K_INFO	:= cMsg
		
		MsUnlock()
	EndIf

Return( cIdLog )


//-------------------------------------------------------------------
/*/{Protheus.doc} TafXLogIni
Funcao que chama o inicio da TafXLog
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return cIdLog - Id do Log
/*/
//-------------------------------------------------------------------
Function TafXLogIni( cIdLog, cEvento, cPerApu  )
	Local cRet := ""
	cRet := TafXLog( , cEvento, "INICIO" ,, cPerApu )	
Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafXLogFim
Funcao que chama o fim da TafXLog
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return cIdLog - Id do Log
/*/
//-------------------------------------------------------------------
Function TafXLogFim( cIdLog, cEvento, cPerApu )
	Local cRet := ""
	cRet := TafXLog( cIdLog, cEvento, "FIM",,cPerApu  )	
Return( cRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} GetNewID
Funcao que COntrola os IDs da TafXLog, inclrementando o devido sequencial
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return cRet - Sequencial
/*/
//-------------------------------------------------------------------
Static Function GetNewID( cTabLog, cCpoId , cWhere , lSoma )
	Local cRet 		:= ""
	Local cQry 		:= ""
	Local aRes 		:= {}
	Local nTamCpo 	:= TamSx3(cCpoId)[01]

	Default cWhere	:= ""
	Default lSoma   := .T.
	
	cQry := "SELECT MAX( "+cCpoId+" ) FROM "+RetSqlName(cTabLog)
	cQry += " WHERE D_E_L_E_T_ <> '*' "
	cQry +=  cWhere
	
	aRes := TafQryArr( cQry)

	If !Empty(aRes)
		cRet := Padr(aRes[01][01],nTamCpo)
		If lSOma
			cRet := Soma1(cRet)
		EndIf	
	Else
		cRet := StrZero(1,nTamCpo)
	EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} XVisV0K
Funcao que gera uma visualização do detalhe do Log
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------
Function XVisV0K()
	Local oArea		   	:= FWLayer():New()
	Local aCoord		:= {0,0,550,1000}//FWGetDialogSize(oMainWnd)
	Local aTamObj		:= Array(4)
	Local oOk 			:= LoadBitmap(GetResources(),"LBOK")
	Local oNo 			:= LoadBitmap(GetResources(),"LBNO")
	Local nOpcA		  	:= 0
	Local bOk			:= {|| oMainDlg:End() }
	Local aButtons		:= {}
	Local aTamCpo		:= {}
	Local nA			:= 0
	Local nI			:= 0
	Local cNomDep		:= ""
	Local oFont		  	:= TFont():New("Arial",08,10,,.T.,,,,.T.)
	Local oCourier	  	:= TFont():New("Courier New",,-16,.T.,.T.,,,,.T.)
	Local oButt1,oButt2
	Local aSize     	:= {}
	Local aArea     	:= GetArea()
	Local aInfo     	:= {}
	Local aObjects  	:= {}
	Local aPosObj 		:= {}
	Local bChange   	:= {|| }
	Local aCols1    	:= {}
	Local aFields   	:= {}
	Local aField    	:= {}
	Local aFieldEdit	:= {}
	Local aCpoEnch  	:= {}
	Local aPos 	    	:= {012,005,200,600}
	Local aCpoH     	:= {}
	Local cDescView 	:= ""
	Local aCombo    	:= {}
	Local aPerg     	:= {}
	Local aParam    	:= Array(1)
	Local aView     	:= {}
	Local nLimit    	:= 9999
	Local oEnt1,oEnt2
	
	cCadastro := ""

	//resoluçao 1280 x 768
	aSize:= {0,0,608.5,270,1217,563,0}

	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	AADD(aObjects,{100,30,.T.,.F.})
	AADD(aObjects,{100,100,.T.,.T.})
	aPosObj := MsObjSize(aInfo, aObjects)

	aScreen   := GetScreenRes()
	aScreen[1]:= aScreen[1]-20
	aScreen[2]:= aScreen[2]-20

	aCoord[3] *= 0.95
	aCoord[4] *= 0.9

	oMainDlg := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],OemToAnsi(cCadastro),,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oArea:Init(oMainDlg,.F.)
	//Mapeamento da area
	oArea:AddLine("L01",100,.T.)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Colunas  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	oArea:AddCollumn("L01C01",90,.F.,"L01") //dados
	oArea:AddCollumn("L01C02",10,.F.,"L01") //botoes

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Paineis  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	oArea:AddWindow("L01C01","LIST","Detalhes",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oList	:= oArea:GetWinPanel("L01C01","LIST","L01")

	aInfo:= {}            
	aCol := { 002, 067, 135 }    
	cInfo := ""

	cDescUser := UsrFullName ( V0K->V0K_USER )
	         
	@ 002,aCol[01] SAY "Proc ID"		Pixel Of oList
	@ 002,aCol[02] SAY "Sequencia"		Pixel Of oList
	@ 032,aCol[01] SAY "Evento" 		Pixel Of oList
	@ 032,aCol[02] SAY "Período"		Pixel Of oList
	@ 062,aCol[01] SAY "Data"			Pixel Of oList
	@ 062,aCol[02] SAY "Hora"			Pixel Of oList
	@ 092,aCol[01] SAY "Tipo"			Pixel Of oList
	@ 092,aCol[02] SAY "Rotina"			Pixel Of oList
	@ 122,aCol[01] SAY "Usuário"		Pixel Of oList
	@ 122,aCol[02] SAY "Desc Usuário"	Pixel Of oList

	@ 010,aCol[01] MSGET oProcId 	VAR V0K->V0K_PROCID 	SIZE 060,08 Pixel Of oList READONLY
	@ 010,aCol[02] MSGET oSeq 		VAR V0K->V0K_SEQ 		SIZE 060,08 Pixel Of oList READONLY
	@ 040,aCol[01] MSGET oEvento 	VAR V0K->V0K_EVENTO 	SIZE 060,08 Pixel Of oList READONLY
	@ 040,aCol[02] MSGET oPeriod	VAR V0K->V0K_PERIOD 	SIZE 060,08 Pixel Of oList READONLY
	@ 070,aCol[01] MSGET oData  	VAR V0K->V0K_DATA	 	SIZE 060,08 Pixel Of oList READONLY
	@ 070,aCol[02] MSGET oHora  	VAR V0K->V0K_HORA	 	SIZE 060,08 Pixel Of oList READONLY
	@ 100,aCol[01] MSGET oTipo  	VAR V0K->V0K_TIPO	 	SIZE 060,08 Pixel Of oList READONLY
	@ 100,aCol[02] MSGET oRotina  	VAR V0K->V0K_ROTINA	 	SIZE 060,08 Pixel Of oList READONLY
	@ 130,aCol[01] MSGET oUser  	VAR V0K->V0K_USER	 	SIZE 060,08 Pixel Of oList READONLY
	@ 130,aCol[02] MSGET oDescUser 	VAR cDescUser		 	SIZE 060,08 Pixel Of oList READONLY

	@ 002,aCol[03] SAY "Mensagem" Pixel Of oList
	@ 010,aCol[03] GET oInfo VAR V0K->V0K_INFO MEMO SIZE 250,220 FONT oCourier Pixel Of oList READONLY

	oArea:AddWindow("L01C02","L01C02P01","Funções",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oAreaBut := oArea:GetWinPanel("L01C02","L01C02P01","L01")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 03-Botoes            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oButt1 := tButton():New(000,000,"&Ok"	,oAreaBut,bOk		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)

	oMainDlg:Activate(,,,.T.,/*valid*/,,/*On Init*/)
		
	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafViewLog
Funcao que gera uma visualização do Log
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return cRet - Sequencial
/*/
//-------------------------------------------------------------------
Function TafViewLog( cFilter , cEvento, cPeriodo )
	Local aAreaAnt  := GetArea()
	Local aCores	:= {}
	Private aRotina :=  {{ "Detalhe","XVisV0K", Recno() , 3}}

	Default cFilter 	:= ""
	Default cEvento 	:= ""
	Default cPeriodo	:= ""

	DbSelectArea("V0K")
	DbSetOrder(1)  

	AADD( aCores, {"AllTrim(V0K->V0K_TIPO)=='INICIO'"	,"DBG03"			} ) // Inicio do Processamento
	AADD( aCores, {"AllTrim(V0K->V0K_TIPO)=='ALERTA'"	,"UPDWARNING"		} ) // Alerta
	AADD( aCores, {"AllTrim(V0K->V0K_TIPO)=='MSG'"		,"UPDINFORMATION"	} ) // Mensagem
	AADD( aCores, {"AllTrim(V0K->V0K_TIPO)=='ERRO'"		,"DBG07"			} ) // Erro 
	AADD( aCores, {"AllTrim(V0K->V0K_TIPO)=='CANCEL'"	,"CANCEL"			} ) // Cancelado pelo usuario
	AADD( aCores, {"AllTrim(V0K->V0K_TIPO)=='FIM'"		,"OK"				} ) // Final do Processamento

	TafWndBrow(	0,; // 01
				0,; // 02
				500,; // 03
				880,; // 04
				"Log de Processamento - Apurações REINF",; // 05
				"V0K",; // 06
				,; // 07
				aRotina,; // 08
				/*"AllTrim(V0K->V0K_TIPO)=='INICIO'"*/,; // 09
				/*'xFilial("V0K")+"'+__BatchProc+'"'*/,; //10
				/*'xFilial("V0K")+"'+__BatchProc+'zzzzzzzzzzz"'*/,; // 11
				.T.,; // 12
				/*{{"OK","Avisos"},{"CANCEL","Erros de Processamento"}}*/,; // 13
				2,; // 14
				{{"Evento+Período",1},{"Período+Evento",2}},; // 15
				/*xFilial("V0K")+__BatchProc*/,; // 16
				,; // 17
				,; // 18 
				,; // 19
				,; // 20
				{|| XVisV0K() },; // 21
				,; // 22
				,; // 23
				,; // 24
				aCores,; // 25
				,; // 26
				,; // 27
				,; // 28
				,; // 29
				,; // 30
				,; // 31
				,; // 32
				cFilter,;
				cEvento,;
				cPeriodo) // 33

	RestArea(aAreaAnt)
	V0K->(DBCloseArea())  
Return          



//-------------------------------------------------------------------
/*/{Protheus.doc} TafWndBrow
Funcao que monta a interface de visualização do log.
Baseada na função "MaWndbrowse"
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return oBrowse
/*/
//-------------------------------------------------------------------
Function TafWndBrow(nLin1,;		//01
					nCol1,;		//02
					nLin2,;		//03
					nCol2,;		//04
					cTitle,;	//05
					uAlias,;	//06
					aCampos,;	//07
					aRotina,;	//08
					cFun,;		//09
					cTopFun,;	//10
					cBotFun,;	//11
					lCentered,;	//12
					aResource,;	//13
					nModelo,;	//14
					aPesqui,;	//15
					cSeek,;		//16
					lDic,;		//17
					lSavOrd,;	//18
					lParPad,;	//19
					lPesq,;		//20
					bViewReg,;	//21
					oBrowse,;	//22
					nFreeze,;	//23
					aHeadOrd,;	//24
					aCores,;	//25
					oPanelPai,;	//26
					aButtonTxt,;//27
					aButtonBar,;//28
					lMaximized,;//29
					lLegenda,;	//30
					lShowBar,;	//31
					cCondBtn,;	//32
					cFilter,; 	//33
					cEvento,;
					cPeriodo )

	Local oRes1
	Local oRes2
	Local cCodeBlock
	Local nButtonSize 	:= 45
	Local nButtonAlt	:= 16	
	Local nPosBT		:= 0
	Local cSavCad		:= ""
	LOCAL nMyWidth  	:= 1909 // oMainWnd:nClientWidth - 7 // 1909
	LOCAL nMyHeight 	:= 926 // oMainWnd:nClientHeight- 34 // 926
	Local bWhen     	:= {||.T.}
	Local nY			:= 0
	Local nX			:= 0
	Local cCond			:= ""
	Local oPanel 
	Local nIniBut		:= 1
	Private oWind

	DEFAULT bViewReg	:= {|| Nil }
	DEFAULT nModelo 	:= 3
	DEFAULT lDic    	:= .T.
	DEFAULT lSavOrd 	:= .T.
	DEFAULT lParPad 	:= .T. //Indica de se deve ser verificado se debvem enviarse os tres parametros padroes SEMPRE
	DEFAULT lPesq	 	:= .F. // Indica se deve incluir o botao pesquisar
	DEFAULT lMaximized 	:= .T.
	DEFAULT aRotina 	:= {}
	DEFAULT aButtonTxt 	:= {}
	DEFAULT aButtonBar 	:= {}
	DEFAULT lLegenda	:= .T.
	DEFAULT lShowBar	:= .T.
	DEFAULT cCondBtn	:= ""

	If Type( "cCadastro" ) <> "U"
		cSavCad := cCadastro
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define tamanho padrao da janela.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLin1 := IIF(nLin1!=Nil,nLin1,120)
	nCol1 := IIF(nCol1!=Nil,nCol1,83)
	nLin2 := IIF(nLin2!=Nil,nLin2,nMyHeight)
	nCol2 := IIF(nCol2!=Nil,nCol2,nMyWidth)

	If lDic
		dbSelectArea(uAlias)
		dbSeek(xFilial())
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o code block para visualizacao do registro            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For ny := 1 to Len(aRotina)
		If Len(aRotina[ny])==7 .And. aRotina[ny][7]
			cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oWind:End()}"
		Else
			cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oBrowse:SetFocus(),oBrowse:Refresh()}"
		EndIf
		If aRotina[ny][4] == 2 .AND. bViewReg == Nil
			bViewReg := &cCodeBlock
		EndIf
	Next

	If nModelo < 4
		If nModelo == 2

			oArea	   	:= FWLayer():New()
			aCoord		:= {0,0,550,1000}//FWGetDialogSize(oMainWnd)

			oWind := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],OemToAnsi(cTitle),,,,,CLR_BLACK,CLR_WHITE,,,.T.)
			oArea:Init(oWind,.F.)
			oArea:AddLine("L01",100,.T.)
			oArea:AddCollumn("L01C01",90,.F.,"L01") //dados
			oArea:AddCollumn("L01C02",10,.F.,"L01") //botoes

			oArea:AddWindow("L01C01","FILT","Filtro do Log",022,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oFIlt	:= oArea:GetWinPanel("L01C01","FILT","L01")

			oArea:AddWindow("L01C01","LIST","Detalhes",078,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oList	:= oArea:GetWinPanel("L01C01","LIST","L01")


			oArea:AddWindow("L01C02","L01C02P01","Funções",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
			oAreaBut := oArea:GetWinPanel("L01C02","L01C02P01","L01")

		Else
			DEFINE MSDIALOG oWind TITLE cTitle FROM nLin1,nCol1 TO nLin2,nCol2 Of oMainWnd PIXEL
		EndIf
	Endif

	If nModelo == 1

		oBrowse := TafMakeBrow(oWind,uAlias,{14, 2, ((nCol2-nCol1)/2)-2, ((nLin2-nLin1)/2-If(aResource==Nil,14,22))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nFreeze,aHeadOrd,aCores,cFilter)

		@ 0, 0 BITMAP oBmp RESNAME "TOOLBAR" oF oWind SIZE 600,20  NOBORDER WHEN .F. PIXEL 	

		If aResource != Nil
			@ ((nLin2-nLin1)/2-7),6 BITMAP oRes1 RESOURCE aResource[1][1] SIZE 8,8 Of oWind PIXEL NOBORDER
			@ ((nLin2-nLin1)/2-7),18 SAY aResource[1][2] Of oWind SIZE 60,9 PIXEL 
			@ ((nLin2-nLin1)/2-7),(((nCol2-nCol1)/2)/2)+5 BITMAP oRes2 RESOURCE aResource[2][1] SIZE 8,8 Of oWind PIXEL NOBORDER
			@ ((nLin2-nLin1)/2-7),(((nCol2-nCol1)/2)/2)+17 SAY aResource[2][2] Of oWind PIXEL 

		EndIf

		If lPesq
		TButton():New( 1, 3, "&"+"Pesquisar", oWind ,{||WndxPesqui(oBrowse,aPesqui,cSeek,lSavOrd)}, nButtonSize, 12,,, .F., .T., .F.,, .F.,,) //"Pesquisar"
		nIniBut	:= 0
		EndIf

		For ny := 1 to Len(aRotina)
			If (Len(aRotina[ny]) == 6)
				bWhen:= IIf(aRotina[ny][6],{||.T.},{||.F.})
			Else
				bWhen:= {||.T.}
			EndIf

			If Len(aRotina[ny])==7 .And. aRotina[ny][7]
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificacao de arquivo vazio.                           ³
				//³Dependendo da operação valida a existencia de registros.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRotina[ny][4] == 3 .Or. (cTopFun == Nil .Or. Empty(cTopFun) .Or. cBotFun == Nil .Or. Empty(cBotFun))
					cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And. "(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oWind:End()}"
				Else
					cCond := Alias()+"->(&("+Alias()+"->(IndexKey())) < '"+&(cBotFun)+"' .Or. &("+Alias()+"->(IndexKey())) >'"+&(cTopFun)+"')"
					cCodeBlock := "{||IIf("+ cCond +",Help(' ',1,'ARQVAZIO'),(WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And. "(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oWind:End()))}"
				EndIf

			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificacao de arquivo vazio.                           ³
				//³Dependendo da operação valida a existencia de registros.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRotina[ny][4] == 3 .Or. (cTopFun == Nil .Or. Empty(cTopFun) .Or. cBotFun == Nil .Or. Empty(cBotFun))
					cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And. "(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oBrowse:SetFocus(),oBrowse:Refresh()}"
				Else
					cCond := Alias()+"->(&("+Alias()+"->(IndexKey())) < '"+&(cBotFun)+"' .Or. &("+Alias()+"->(IndexKey())) >'"+&(cTopFun)+"')"
					cCodeBlock := "{||IIf("+ cCond +",Help(' ',1,'ARQVAZIO'),(WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And. "(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oBrowse:SetFocus(),oBrowse:Refresh()))}"
				EndIf
			EndIf
			
		TButton():New( 1, 3+((ny-nIniBut)*nButtonSize), aRotina[ny][1], oWind ,&cCodeBlock  , nButtonSize, nButtonAlt,,, .F., .T., .F.,, .F.,bWhen,)
		Next ny


	TButton():New( 1, 3+((Len(aRotina)+1-nIniBut)*nButtonSize), OemToAnsi("&Sair") , oWind ,{|| oWind:End()} , nButtonSize, 12,,, .F., .T., .F.,, .F.,, ) // "&Sair"

	ElseIf nModelo == 2

		oChk01		:= Nil
		oChk02		:= Nil
		oChk03		:= Nil
		lChk01		:= .T.
		lChk02		:= .T.
		lChk03		:= .T.
		lChk04		:= .F.

		If !Empty( cEvento )
			bCheck := {|| Iif(lChk04, lChk01 := .F.,.F.), cFilter := ProcFil( cEvento, cPeriodo, lChk01, lChk02, lChk03, lChk04 ), oBrowse:Refresh()}
		Else
			bCheck := {|| }
		EndIf
		oChk01 := TCheckBox():New(005,010,"Exibe Somente Evento "	+ cEvento +"."	,&("{|u|IIf (PCount()==0,lChk01,lChk01 := u)}"),oFIlt,100,210,,bCheck,,,,,,.T.,,,{|| .F.})
		oChk02 := TCheckBox():New(015,010,"Exibe Somente Período "	+ cPeriodo+"."	,&("{|u|IIf (PCount()==0,lChk02,lChk02 := u)}"),oFIlt,100,210,,bCheck,,,,,,.T.,,,)
		oChk03 := TCheckBox():New(025,010,"Exibe Último Mês Apurado."				,&("{|u|IIf (PCount()==0,lChk03,lChk03 := u)}"),oFIlt,100,210,,bCheck,,,,,,.T.,,,)
		oChk04 := TCheckBox():New(005,200,"Exibe Logs do Evento R-2098."			,&("{|u|IIf (PCount()==0,lChk04,lChk04 := u)}"),oFIlt,100,210,,bCheck,,,,,,.F.,,,)
		

		oBrowse := TafMakeBrow(oList,uAlias,{000,000, ((nCol2-nCol1)/2)-nButtonSize-4, ((nLin2-nLin1)/2-If(aResource==Nil,2,16))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nFreeze,aHeadOrd,aCores,cFilter)
		oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		cFilter := ProcFil( cEvento, cPeriodo, lChk01, lChk02, lChk03, lChk04 )

		If aResource != Nil
			@ ((nLin2-nLin1)/2-14),6 BITMAP oRes1 RESOURCE aResource[1][1] SIZE 12,12 Of oWind PIXEL NOBORDER
			@ ((nLin2-nLin1)/2-11),28 SAY aResource[1][2] Of oWind SIZE 60,9 PIXEL 
			@ ((nLin2-nLin1)/2-14),(((nCol2-nCol1)/2)/2)+6 BITMAP oRes2 RESOURCE aResource[2][1] SIZE 12,12 Of oWind PIXEL NOBORDER
			@ ((nLin2-nLin1)/2-11),(((nCol2-nCol1)/2)/2)+27 SAY aResource[2][2] Of oWind PIXEL 
		EndIf

		If lPesq
		
			nPosBT += nButtonAlt
			TButton():New( nPosBT, 0, "&"+"Pesquisar", oAreaBut ,{||WndxPesqui(oBrowse,aPesqui,cSeek,lSavOrd)}, oAreaBut:nClientWidth/2,nButtonAlt,,, .F., .T., .F.,, .F.,,) //"Pesquisar"
			nIniBut	:= 0
			nPosBT += nButtonAlt
		EndIf

		For ny := 1 to Len(aRotina)
			If (Len(aRotina[ny]) == 6)
				bWhen:= IIf(aRotina[ny][6],{||.T.},{||.F.})
			Else
				bWhen:= {||.T.}
			EndIf

			If Len(aRotina[ny])==7 .And. aRotina[ny][7]
			
				If aRotina[ny][4] == 3 .Or. (cTopFun == Nil .Or. Empty(cTopFun) .Or. cBotFun == Nil .Or. Empty(cBotFun))
					cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oWind:End()}"
				Else
					cCond := Alias()+"->(&("+Alias()+"->(IndexKey())) < '"+&(cBotFun)+"' .Or. &("+Alias()+"->(IndexKey())) >'"+&(cTopFun)+"')"
					cCodeBlock := "{||IIf("+ cCond +",Help(' ',1,'ARQVAZIO'),(WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oWind:End()))}"
				EndIf
			Else
				If aRotina[ny][4] == 3 .Or. (cTopFun == Nil .Or. Empty(cTopFun) .Or. cBotFun == Nil .Or. Empty(cBotFun))
					cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "","(Alias(),RecNo(),"+Str(ny)+")")+",oBrowse:SetFocus(),oBrowse:Refresh()}"
				Else
					If Empty(cCondBtn)
					cCond := Alias()+"->(&("+Alias()+"->(IndexKey())) < '"+&(cBotFun)+"' .Or. &("+Alias()+"->(IndexKey())) >'"+&(cTopFun)+"')"
					Else
						cCond := cCondBtn
					EndIf
					cCodeBlock := "{||IIf("+ cCond +",Help(' ',1,'ARQVAZIO'),(WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oBrowse:SetFocus(),oBrowse:Refresh()))}"
				EndIf
			EndIf
			
			TButton():New( nPosBT , 0 , aRotina[ny][1], oAreaBut ,&cCodeBlock  , oAreaBut:nClientWidth/2,nButtonAlt,,, .F., .T., .T.,, .F.,bWhen,)
			nPosBT += nButtonAlt
		Next ny

		TButton():New( nPosBT , 0, OemToAnsi("&Sair") , oAreaBut ,{|| oWind:End()} , oAreaBut:nClientWidth/2,nButtonAlt,,, .F., .T., .F.,, .F.,, ) // "&Sair"
		nPosBT += nButtonAlt
	
	ElseIf nModelo == 3
			oWind:lMaximized := .T.

			oBrowse := TafMakeBrow(oWind,uAlias,{2,nButtonSize+3, ((nCol2-nCol1)/2)-nButtonSize-4, ((nLin2-nLin1)/2-If(aResource==Nil,2,50))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nFreeze,aHeadOrd,aCores, cFilter)
			oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

			oPanel := TPanel():New(0,0,'',oWind, , .T., .T.,, ,40,30,.T.,.T. )
			oPanel:Align := CONTROL_ALIGN_BOTTOM

			If aResource != Nil
				@ 5,6 BITMAP oRes1 RESOURCE aResource[1][1] SIZE 8,8 Of oPanel PIXEL NOBORDER
				@ 5,18 SAY aResource[1][2] Of oPanel SIZE 60,9 PIXEL 
				@ 5,(((nCol2-nCol1)/2)/2)+5 BITMAP oRes2 RESOURCE aResource[2][1] SIZE 8,8 Of oPanel PIXEL NOBORDER
				@ 5,(((nCol2-nCol1)/2)/2)+17 SAY aResource[2][2] Of oPanel PIXEL 
			
			EndIf
			If lPesq	
			TButton():New( 17, 3, "&"+"Pesquisar", oPanel ,{||WndxPesqui(oBrowse,aPesqui,cSeek,lSavOrd)}, nButtonSize, 10,,, .F., .T., .F.,, .F.,,) //"Pesquisar"
			nIniBut	:= 0
			EndIf
		
		For ny := 1 to Len(aRotina)
			If (Len(aRotina[ny]) == 6)
				bWhen:= IIf(aRotina[ny][6],{||.T.},{||.F.})
			Else
				bWhen:= {||.T.}
			EndIf

			If Len(aRotina[ny])==7 .And. aRotina[ny][7]
			
				If aRotina[ny][4] == 3 .Or. (cTopFun == Nil .Or. Empty(cTopFun) .Or. cBotFun == Nil .Or. Empty(cBotFun))
					cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oWind:End()}"
				Else
					cCond := Alias()+"->(&("+Alias()+"->(IndexKey())) >= '"+&(cTopFun)+"' .And. &("+Alias()+"->(IndexKey())) <='"+&(cBotFun)+"')"
					cCodeBlock := "{||IIf(!"+ cCond +",Help(' ',1,'ARQVAZIO'),(WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oWind:End()))}"
				EndIf
			Else

				If aRotina[ny][4] == 3 .Or. (cTopFun == Nil .Or. Empty(cTopFun) .Or. cBotFun == Nil .Or. Empty(cBotFun))
					cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "","(Alias(),RecNo(),"+Str(ny)+")")+",oBrowse:SetFocus(),oBrowse:Refresh()}"
				Else
					cCond := Alias()+"->(&("+Alias()+"->(IndexKey())) < '"+&(cBotFun)+"' .Or. &("+Alias()+"->(IndexKey())) >'"+&(cTopFun)+"')"
					cCodeBlock := "{||IIf("+ cCond +",Help(' ',1,'ARQVAZIO'),(WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+")") + ",oBrowse:SetFocus(),oBrowse:Refresh()))}"
				EndIf
			EndIf
		
		TButton():New( 17, 3+((ny-nIniBut)*(nButtonSize+2)), aRotina[ny][1], oPanel ,&cCodeBlock  , nButtonSize, 10,,, .F., .T., .F.,, .F.,bWhen,)
		Next ny


	TButton():New( 17	, 3+((Len(aRotina)+1-nIniBut)*(nButtonSize+2)), OemToAnsi("&Sair") , oPanel ,{|| oWind:End()} , nButtonSize, 10,,, .F., .T., .F.,, .F.,, ) // "&Sair"

	//---------------------------------------------------------------------------------------------------
	ElseIf nModelo == 4  //Painel Financeiro
	//---------------------------------------------------------------------------------------------------
		oWind   := oPanelPai   	
		oBrowse := TafMakeBrow(oWind,uAlias,{2,nButtonSize+3, ((nCol2-nCol1)/2)-nButtonSize-4, ((nLin2-nLin1)/2-If(aResource==Nil,2,50))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nFreeze,aHeadOrd,aCores,cFilter)
		oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		If aResource != Nil
			@ 5,6 BITMAP oRes1 RESOURCE aResource[1][1] SIZE 8,8 Of oPanel PIXEL NOBORDER
			@ 5,18 SAY aResource[1][2] Of oPanel SIZE 60,9 PIXEL 
			@ 5,(((nCol2-nCol1)/2)/2)+5 BITMAP oRes2 RESOURCE aResource[2][1] SIZE 8,8 Of oPanel PIXEL NOBORDER
			@ 5,(((nCol2-nCol1)/2)/2)+17 SAY aResource[2][2] Of oPanel PIXEL 
		
		EndIf

		If lShowBar
			FaMyBar(oWind,NIL,NIL,aButtonBar,aButtonTxt,/*lIsEnchoice*/,/*lSplitBar*/,lLegenda )
		Endif

	EndIf

	If nModelo < 4  //nao há dialog para painel financeiro
		If lCentered
			ACTIVATE MSDIALOG oWind CENTERED ON INIT (oBrowse:Refresh())
		Else
			ACTIVATE MSDIALOG oWind ON INIT (oBrowse:Refresh())
		EndIf
	Endif

	If Type( "cCadastro" ) <> "U"
		cCadastro := cSavCad
	EndIf

Return( oBrowse )

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcFil
Funcao filtra a tabela de log
@author Roberto Souza
@since 22/03/2018
@version 1.0 

@aParam	

@return cIdLog - Id do Log
/*/
//------------------------------------------------------------------- 
Static Function ProcFil( cEvento, cPeriodo, lChk01, lChk02, lChk03, lChk04 )
	Local cFilter as character
	Local cLastID as character

	Default cEvento 	:= ""
	Default cPeriodo 	:= ""
 

	cLastID := GetNewID( "V0K", "V0K_PROCID" , " AND V0K_EVENTO = '"+AllTrim(cEvento)+"'", .F.)
	cFilter := " V0K_FILIAL == '"+xFilial("V0K")+"'"
	
	If !lChk04  
		If lChk01 .And. !Empty( cEvento )
			cFilter +=" .AND. V0K_EVENTO == '"+cEvento+"'"
		EndIf
		If lChk02 .And. !Empty( cPeriodo )
			cPeriodo := StrTran(StrTran(cPeriodo,"-",""),"/","")
			cFilter +=" .AND. V0K_PERIOD == '"+cPeriodo+"'"
		EndIf	
		If lChk03
			cFilter +=" .AND. V0K_PROCID == '"+cLastID+"'"
		EndIf	
	Else
		cFilter +=" .AND. V0K_EVENTO == 'R-2098'"
	EndIf

	DbSelectArea("V0K")
	SET FILTER TO V0K_FILIAL == xFilial("V0K")

	SET FILTER TO &(cFilter)
	V0K->( DbGoTop() )

Return( cFilter )
//-------------------------------------------------------------------
/*/{Protheus.doc} TafWndBrow
Funcao que monta o broese baseada em um arquivo.
Baseada na função "MaMakeBrow"
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return oBrowse
/*/
//-------------------------------------------------------------------
Function TafMakeBrow(oWndBrw,cAlias,aCoord,oBrow,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nBrFreeze,aHeadOrd,aCores, cFilter)

	Local oBrowse
	Local oEnable
	Local oDisable
	Local nAlias
	Local lUsado
	Local cField
	Local cExpr	:= "Empty("+If(cFun==Nil,"  ",cFun)+")"
	Local nZ	:= 0
	Local cBlockHead
	Local bBlockHead
	Local oRes

	DEFAULT lDic      :=.T.
	DEFAULT nBrFreeze := 0
	DEFAULT aCampos   :={}
	DEFAULT cBotFun   := '',cTopFun:= ''
	DEFAULT cFilter	  := ""	 	

	If aResource == Nil
		aResource:= {{ "LBTIK"," "},;
					{"DISABLE"," "}}
	EndIf                                   

	nBrFreeze:= If(Valtype(nBrFreeze) == "N",nBrFreeze,0)
	nAlias   := Select(cAlias)        

	dbSelectArea(cAlias)
	nAlias := Select()   

	If !Empty( cFilter )
		dbSelectArea(cAlias)
		(cAlias)->(DbSetOrder(1))
		Set Filter To &(cFilter)
		(cAlias)->(DbGoTop())	
	EndIf

	cField := IIF(Empty(cFilial),Nil,cAlias+"->"+PrefixoCpo(cAlias)+"_FILIAL")
	If !Empty(cTopFun)
		cField := IndexKey()
	EndIf
	cTopFun := IIF(cTopFun==Nil,xFilial(cAlias),&(cTopFun))
	cBotFun := IIF(cBotFun==Nil,xFilial(cAlias),&(cBotFun))

	oBrowse   := TcBrowse():New( aCoord[1], aCoord[2], aCoord[3], aCoord[4], , , , oWndBrw ,cField,cTopFun,cBotFun,,bViewReg,,,,,,, .F.,cAlias, .T.,, .F., , ,.f. )
	// Seta as ordens do cabecalho
	If aHeadOrd <> Nil .And. !Empty(aHeadOrd)
		cBlockHead := "{|oBrw,nCol| WndChgOrd(nCol,oBrw,aHeadOrd,cAlias),oBrowse:SetFocus(),oBrowse:Refresh()}"
		bBlockHead := &cBlockHead
		oBrowse:bHeaderClick := bBlockHead
	EndIf

	If !Empty(cFun)
	oEnable  := LoadBitmap( GetResources(), aResource[1][1] ) //"LBTIK"
	oDisable := LoadBitmap( GetResources(), aResource[2][1] ) //"DISABLE"
	oBrowse:AddColumn( TCColumn():New( "",{ || IF(&(cExpr),oEnable,oDisable)},,,, "LEFT", 10, .T., .F.,,,, .T., ))
	ElseIf ValType( aCores ) == 'A' .And. ! Empty( aCores )
		oBrowse:AddColumn( TCColumn():New( "", ;
		{|| oRes:=Nil, aEval(aCores,{|x| IF(&(x[1]),IF(oRes==Nil,oRes:=LoadBitmap(GetResources(),x[2]),""),"")} ), oRes },,,, "LEFT", 10, .T., .F.,,,, .T., ))
	EndIf
			
	If lDic
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek(cAlias)
		While !EOF() .And. (x3_arquivo == cAlias)
			IF Empty(aCampos)
				lUsado := X3_BROWSE == "S"
			Else
				lUsado := (Ascan(aCampos,AllTrim(X3_CAMPO))>0)
			Endif
			If lUsado
				If X3_CONTEXT <> "V"
					oBrowse:AddColumn( TCColumn():New( Trim(x3Titulo()), FieldWBlock( x3_campo, nAlias ),AllTrim(X3_PICTURE),,, if(X3_TIPO=="N","RIGHT","LEFT"), If(X3_TAMANHO>Len(X3_TITULO),3+(X3_TAMANHO*3.7),3+(LEN(X3_TITULO)*3.7)), .F., .F.,,,, .F., ) )
				EndIf
			Endif
			dbSkip()
		EndDo
		dbSelectArea(cAlias)
	Else
		For nz:=1 to Len(aCampos)
			oBrowse:AddColumn( TCColumn():New( Trim(aCampos[nz,3]), Iif(ValType(aCampos[nz,1]) == "B",aCampos[nz,1],FieldWBlock( aCampos[nz,1], nAlias )),AllTrim(aCampos[nz,2]),,,if(ValType(Trim(aCampos[nz,3]))=="N","RIGHT","LEFT"),If(aCampos[nz,4]>Len(aCampos[nz,3]),3+(aCampos[nz,4]*3.7),3+(LEN(aCampos[nz,3])*3.7)), .F., .F.,,,, .F., ) )
		Next nz
	EndIf
	If nBrFreeze > 0
		oBrowse:nFreeze:=nBrFreeze
	EndIf

	// Seta a 1a ordem do array
	If aHeadOrd <> Nil .And. !Empty(aHeadOrd)
		WndChgOrd(aHeadOrd[1][1],oBrowse,aHeadOrd,cAlias)
	EndIf

	oBrowse:Refresh()
	SysRefresh()

Return( oBrowse )


//-------------------------------------------------------------------
/*/{Protheus.doc} TafEndGRV
Funcao que grava os campos não usados.

@author Roberto Souza
@since 22/02/2018
@version 1.0 

@aParam	

@return
/*/
//-------------------------------------------------------------------
Function TafEndGRV( cIdAlias, cIDCpo, uInfo, nRecno, cEvent )
	Local aArea as array

	aArea := {}

	Default nRecno 	:= 0
	Default uInfo  	:= ""
	Default cEvent	:= ""

	If !Empty( cIdAlias ) 
		If nRecno > 0
			aArea := GetArea()
			DbSelectArea(cIdAlias)
			(cIdAlias)->(DbGoTo(nRecno))	
			RecLock( cIdAlias , .F.)
			if cEvent == "R2060"
				if cIdAlias == "V0S" //ESPELHO
					(cIdAlias)->V0S_PROCID := uInfo
				elseif cIdAlias == "C5M" //LEGADO
					(cIdAlias)->C5M_PROCID := uInfo
				elseif cIdAlias == "V48" //LEGADO
					(cIdAlias)->V48_PROCID := uInfo
				endif
			else
				(cIdAlias)->&(cIDCpo) := uInfo
			endif
			MsUnlock()	

			RestArea( aArea )	
		Else
			DbSelectArea(cIdAlias)
			RecLock( cIdAlias , .F.)
			if cEvent == "R2060"
				if cIdAlias == "V0S" //ESPELHO
					(cIdAlias)->V0S_PROCID := uInfo
				elseif cIdAlias == "C5M" //LEGADO
					(cIdAlias)->C5M_PROCID := uInfo
				elseif cIdAlias == "V48" //LEGADO
					(cIdAlias)->V48_PROCID := uInfo
				endif
			else
				(cIdAlias)->&(cIDCpo) := uInfo
			endif
			MsUnlock()	
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafRetEMsg
Funcao que retorna o erro de um model em formato de txt para exibição de logs.

@author Roberto Souza
@since 23/02/2018
@version 1.0 

@aParam	

@return
/*/
//-------------------------------------------------------------------
Function TafRetEMsg( oModel )
	Local cErro 	as character
	Local aErro   	as array
	Local nItem		as numeric

	cErro	 	:= ""
	aErro   	:= oModel:GetErrorMessage()
	nItem		:= 0

	If !Empty( aErro ) .And. Len( aErro ) >= 9

		cErro 	+= "Item.......................: " + '[' + cValToChar(nItem++) + ']' 			+ CRLF
		cErro 	+= "Id do formulário de origem.: " + '[' + AllTrim(AllToChar(aErro[1])) + ']' 	+ CRLF
		cErro 	+= "Id do campo de origem......: " + '[' + AllToChar(aErro[2]) + ']' 			+ CRLF
		cErro 	+= "Id do formulário de erro...: " + '[' + AllToChar(aErro[3]) + ']' 			+ CRLF
		cErro 	+= "Id do campo de erro........: " + '[' + AllToChar(aErro[4]) + ']' 			+ CRLF
		cErro 	+= "Id do erro.................: " + '[' + AllToChar(aErro[5]) + ']' 			+ CRLF
		cErro 	+= "Mensagem do erro...........: " + '[' + AllToChar(aErro[6]) + ']' 			+ CRLF
		cErro 	+= "Mensagem da solução........: " + '[' + AllToChar(aErro[7]) + ']' 			+ CRLF
		cErro 	+= "Valor atribuido............: " + '[' + AllToChar(aErro[8]) + ']' 			+ CRLF
		cErro 	+= "Valor anterior.............: " + '[' + AllToChar(aErro[9]) + ']' 			+ CRLF

	EndIf

Return( cErro )



Static Function TafLogFilt( cEvento , cPeriodo )
	Local oChk01		as object
	Local oChk02		as object
	Local oChk03		as object
	Local oSDtIni		as object
	Local oGDataIni		as object
	Local oSDtFim		as object
	Local oGDataFIm		as object
	Local nTop			as numeric
	Local nLeft			as numeric
	Local nBottom		as numeric
	Local nRight		as numeric
	Local nLin			as numeric
	Local nCol			as numeric
	Local nTamCol		as numeric
	Local nTipoEven		as numeric
	Local oSize			as object
	Local aItsSelc		as array
	Local aRetEvts		as array
	Local nX			as numeric
	Local cMsgBtt		as char
	Local cRadio1		as char
	Local cRadio2		as char
	Local nRadio		as numeric
	Local lDetal		as logical
	Local lOk			as logical
	Local lVirgula		as logical
	Local lChk01		as logical
	Local lChk02		as logical
	Local lChk03		as logical
	Local lChk04		as logical
	Local lExit			as logical
	Local cStatus		as char
	Local cRecNos		as char
	Local lEnd			as logical
	Local aEvtsSel		as array
	Local aIdsSel		as array
	Local cMsgRet		as char
	Local lMultEvt		as logical
	Local cMsgBtt		as char
	Local cMsgErr		as char
	Local cMsgTit		as char
	Local cEveDsc		as char
	Local aInfoTrab		as array
	Local dPerIni		as Date
	Local dPerFim		as Date

	Default cEvento := "R-1000"
	Default cPeriodo := "01/2018"

	oChk01		:= Nil
	oChk02		:= Nil
	oChk03		:= Nil
	oSDtIni 	:= Nil
	oGDataIni	:= Nil
	oSDtFim		:= Nil
	oGDataFIm	:= Nil
	nTop		:= 0
	nLeft		:= 0
	nBottom		:= 0
	nRight		:= 0
	nLin		:= 005
	nCol		:= 0
	nTamCol		:= 0
	nTipoEven	:= 0
	oSize		:= FwDefSize():New(.F.)
	aItsSelc	:= {}
	nX			:= 0
	cMsgBtt		:= ""
	cRadio1		:= ""
	cRadio2		:= ""
	nRadio		:= 1
	lDetal		:= .F.
	lOk			:= .F.
	lVirgula	:= .F.
	lChk01		:= .T.
	lChk02		:= .T.
	lChk03		:= .F.
	cStatus		:= ""
	cRecNos		:= ""
	lEnd		:= .T.
	aEvtsSel	:= {}
	aIdsSel		:= {}
	aRetEvts	:= {}
	cMsgRet		:= ""
	lMultEvt	:= .F.
	lExit		:= .F.
	cMsgBtt		:= ""
	cMsgErr		:= ""
	cMsgTit		:= ""
	cMsgPar		:= ""
	cEveDsc		:= ""
	aInfoTrab	:= {}
	dPerIni		:= Ctod("  /  /    ")
	dPerFim		:= Date()

	nTop    := oSize:aWindSize[1] - (oSize:aWindSize[1] * 0.73)
	nLeft   := oSize:aWindSize[2] - (oSize:aWindSize[2] * 0.70)
	nBottom := oSize:aWindSize[3] - (oSize:aWindSize[3] * 0.67)
	nRight  := oSize:aWindSize[4] - (oSize:aWindSize[4] * 0.70)

	Define MsDialog oDlgT Title "Filtros" From nTop,nLeft To nBottom,nRight  Pixel STYLE DS_MODALFRAME

	oPanel := TPanel():New(00,00,"",oDlgT,,.F.,.F.,,,10,20,.F.,.F.)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oPanel:setCSS(QLABEL_AZUL_D)

	cMsgTit := "Selecione o filtro do Log:"
	oSayTit := TSay():New(005,oPanel:NCLIENTWIDTH  * 0.02,{||cMsgTit},oPanel,,,,,,.T.,,,oPanel:NCLIENTWIDTH * 0.45,030,,,,,,.T.)
	oChk01 := TCheckBox():New(020,030,"Exibe Somente Evento " 	+ cEvento +"." 	,&("{|u|IIf (PCount()==0,lChk01,lChk01 := u)}"),oPanel,100,210,,,,,,,,.T.,,,{|| .F.})
	oChk02 := TCheckBox():New(035,030,"Exibe Somente Período "	+ cPeriodo+"."	,&("{|u|IIf (PCount()==0,lChk02,lChk02 := u)}"),oPanel,100,210,,,,,,,,.T.,,,)
	oChk03 := TCheckBox():New(050,030,"Exibe Último Mês Apurado."				,&("{|u|IIf (PCount()==0,lChk03,lChk03 := u)}"),oPanel,100,210,,,,,,,,.T.,,,)
	oChk04 := TCheckBox():New(020,200,"Exibe Log do Evento R-2098."				,&("{|u|IIf (PCount()==0,lChk04,lChk04 := u)}"),oPanel,100,210,,,,,,,,.T.,,,)

	Activate MsDialog oDlgT ON INIT (EnchoiceBar(oDlgT,{||lOk :=.T.,oDlgT:End()},{||oDlgT:End()},,,,,.F.,.F.,.F.,.T.,.F.))

Return()	