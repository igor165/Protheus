#INCLUDE "wndbrows.ch"
#INCLUDE "PROTHEUS.CH"
#Include "Folder.ch"
#Include "TcBrowse.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MaWndbrowse³ Autor ³ Edson Maricate       ³ Data ³ 15/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta um Browse contido em uma janela.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGA Advanced for Windows                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaWndBrowse(nLin1,;		//01
					 nCol1,;		//02
					 nLin2,;		//03
					 nCol2,;		//04
					 cTitle,;		//05
					 uAlias,;		//06
					 aCampos,;		//07
					 aRotina,;		//08
					 cFun,;			//09
					 cTopFun,;		//10
					 cBotFun,;		//11
					 lCentered,;	//12
					 aResource,;	//13
					 nModelo,;		//14
					 aPesqui,;		//15
					 cSeek,;		//16
					 lDic,;			//17
					 lSavOrd,;		//18
					 lParPad,;		//19
					 lPesq,;		//20
					 bViewReg,;		//21
					 oBrowse,;		//22
					 nFreeze,;		//23
					 aHeadOrd,;		//24
					 aCores,;		//25
					 oPanelPai,;	//26
					 aButtonTxt,;	//27
					 aButtonBar,;	//28
					 lMaximized,;	//29
					 lLegenda,;		//30
					 lShowBar,;		//31
					 cCondBtn )		//32

Local oRes1
Local oRes2
Local cCodeBlock
Local nButtonSize := 45
Local cSavCad	:= ""
LOCAL nMyWidth  := oMainWnd:nClientWidth - 7
LOCAL nMyHeight := oMainWnd:nClientHeight- 34
Local bWhen     := {||.T.}
Local nY		:= 0
Local nX		:= 0
Local cCond		:= ""
Local oPanel 
Local nIniBut	:= 1
Private oWind

DEFAULT bViewReg	:= {|| Nil }
DEFAULT nModelo 	:= 3
DEFAULT lDic    	:= .T.
DEFAULT lSavOrd 	:= .T.
DEFAULT lParPad 	:= .T. //Indica de se deve ser verificado se debvem enviarse os tres parametros padroes SEMPRE
DEFAULT lPesq	 	:= .T. // Indica se deve incluir o botao pesquisar
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
	DEFINE MSDIALOG oWind TITLE cTitle FROM nLin1,nCol1 TO nLin2,nCol2 Of oMainWnd PIXEL
Endif

If nModelo == 1

	oBrowse := MaMakeBrow(oWind,uAlias,{14, 2, ((nCol2-nCol1)/2)-2, ((nLin2-nLin1)/2-If(aResource==Nil,14,22))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nFreeze,aHeadOrd,aCores)

	@ 0, 0 BITMAP oBmp RESNAME "TOOLBAR" oF oWind SIZE 600,20  NOBORDER WHEN .F. PIXEL 	

	If aResource != Nil
		@ ((nLin2-nLin1)/2-7),6 BITMAP oRes1 RESOURCE aResource[1][1] SIZE 8,8 Of oWind PIXEL NOBORDER
		@ ((nLin2-nLin1)/2-7),18 SAY aResource[1][2] Of oWind SIZE 60,9 PIXEL 
		@ ((nLin2-nLin1)/2-7),(((nCol2-nCol1)/2)/2)+5 BITMAP oRes2 RESOURCE aResource[2][1] SIZE 8,8 Of oWind PIXEL NOBORDER
		@ ((nLin2-nLin1)/2-7),(((nCol2-nCol1)/2)/2)+17 SAY aResource[2][2] Of oWind PIXEL 

	EndIf

	If lPesq
	   TButton():New( 1, 3, "&"+STR0001, oWind ,{||WndxPesqui(oBrowse,aPesqui,cSeek,lSavOrd)}, nButtonSize, 12,,, .F., .T., .F.,, .F.,,) //"Pesquisar"
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
		
	   TButton():New( 1, 3+((ny-nIniBut)*nButtonSize), aRotina[ny][1], oWind ,&cCodeBlock  , nButtonSize, 12,,, .F., .T., .F.,, .F.,bWhen,)
	Next ny


   TButton():New( 1, 3+((Len(aRotina)+1-nIniBut)*nButtonSize), OemToAnsi(STR0002) , oWind ,{|| oWind:End()} , nButtonSize, 12,,, .F., .T., .F.,, .F.,, ) // "&Sair"

ElseIf nModelo == 2

	oBrowse := MaMakeBrow(oWind,uAlias,{2,nButtonSize+3, ((nCol2-nCol1)/2)-nButtonSize-4, ((nLin2-nLin1)/2-If(aResource==Nil,2,16))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nFreeze,aHeadOrd,aCores)

	If aResource != Nil
		@ ((nLin2-nLin1)/2-14),6 BITMAP oRes1 RESOURCE aResource[1][1] SIZE 12,12 Of oWind PIXEL NOBORDER
		@ ((nLin2-nLin1)/2-11),28 SAY aResource[1][2] Of oWind SIZE 60,9 PIXEL 
		@ ((nLin2-nLin1)/2-14),(((nCol2-nCol1)/2)/2)+6 BITMAP oRes2 RESOURCE aResource[2][1] SIZE 12,12 Of oWind PIXEL NOBORDER
		@ ((nLin2-nLin1)/2-11),(((nCol2-nCol1)/2)/2)+27 SAY aResource[2][2] Of oWind PIXEL 
	
	EndIf

   If lPesq
	   TButton():New( 2, 1, "&"+STR0001, oWind ,{||WndxPesqui(oBrowse,aPesqui,cSeek,lSavOrd)}, nButtonSize, 9,,, .F., .T., .F.,, .F.,,) //"Pesquisar"
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
				cCodeBlock := "{||IIf("+ cCond +",Help(' ',1,'ARQVAZIO'),(WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+Iif(!lParPad .And."(" $ aRotina[ny][2], "", "(Alias(),RecNo(),"+Str(ny)+",oBrowse)") + ",oBrowse:SetFocus(),oBrowse:Refresh()))}"
			EndIf
		EndIf
	
	   TButton():New( 2+((ny-nIniBut)*10) , 1 , aRotina[ny][1], oWind ,&cCodeBlock  , nButtonSize, 9,,, .F., .T., .T.,, .F.,bWhen,)
	Next ny

   TButton():New( 2+((Len(aRotina)+1-nIniBut)*10), 1, OemToAnsi(STR0002) , oWind ,{|| oWind:End()} , nButtonSize, 9,,, .F., .T., .F.,, .F.,, ) // "&Sair"

ElseIf nModelo == 3
		oWind:lMaximized := .T.

	    oBrowse := MaMakeBrow(oWind,uAlias,{2,nButtonSize+3, ((nCol2-nCol1)/2)-nButtonSize-4, ((nLin2-nLin1)/2-If(aResource==Nil,2,50))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nFreeze,aHeadOrd,aCores)
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
		   TButton():New( 17, 3, "&"+STR0001, oPanel ,{||WndxPesqui(oBrowse,aPesqui,cSeek,lSavOrd)}, nButtonSize, 10,,, .F., .T., .F.,, .F.,,) //"Pesquisar"
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


   TButton():New( 17	, 3+((Len(aRotina)+1-nIniBut)*(nButtonSize+2)), OemToAnsi(STR0002) , oPanel ,{|| oWind:End()} , nButtonSize, 10,,, .F., .T., .F.,, .F.,, ) // "&Sair"

//---------------------------------------------------------------------------------------------------
ElseIf nModelo == 4  //Painel Financeiro
//---------------------------------------------------------------------------------------------------
	oWind   := oPanelPai   	
	oBrowse := MaMakeBrow(oWind,uAlias,{2,nButtonSize+3, ((nCol2-nCol1)/2)-nButtonSize-4, ((nLin2-nLin1)/2-If(aResource==Nil,2,50))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nFreeze,aHeadOrd,aCores)
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
    If ExistBlock("MTWMB")
	 	ExecBlock("MTWMB",.F.,.F., {@oPanel,@nButtonSize})
    EndIf
   
	If lCentered
		ACTIVATE MSDIALOG oWind CENTERED ON INIT (oBrowse:Refresh())
	Else
		ACTIVATE MSDIALOG oWind ON INIT (oBrowse:Refresh())
	EndIf
Endif

If Type( "cCadastro" ) <> "U"
	cCadastro := cSavCad
EndIf

Return oBrowse


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MaMakeBrow ³ Autor ³ Edson Maricate       ³ Data ³ 15/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o browse no arquivo.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGA Advanced for Windows                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaMakeBrow(oWndBrw,cAlias,aCoord,oBrow,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg,nBrFreeze,aHeadOrd,aCores)

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
Local aOfuscLGPD	:= {}

DEFAULT lDic      :=.T.
DEFAULT nBrFreeze := 0
DEFAULT aCampos   :={}
DEFAULT cBotFun   := '',cTopFun:= ''

If aResource == Nil
	aResource:=	{{ "LBTIK"," "},;
				{"DISABLE"," "}}
EndIf                                   

nBrFreeze:= If(Valtype(nBrFreeze) == "N",nBrFreeze,0)
nAlias   := Select(cAlias)        

dbSelectArea(cAlias)
nAlias := Select()        

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
	aAdd(aOfuscLGPD, cAlias + "_FILIAL" ) //Array com campo
	While !EOF() .And. (x3_arquivo == cAlias)
		IF Empty(aCampos)
			lUsado := X3_BROWSE == "S"
		Else
			lUsado := (Ascan(aCampos,AllTrim(X3_CAMPO))>0)
		Endif
		If lUsado
			If X3_CONTEXT == "V"
				oBrowse:AddColumn( TCColumn():New( Trim(x3Titulo()), WndIniBrw(x3_campo,nAlias) ,AllTrim(X3_PICTURE),,, if(X3_TIPO=="N","RIGHT","LEFT"), If(X3_TAMANHO>Len(X3_TITULO),3+(X3_TAMANHO*3.7),3+(LEN(X3_TITULO)*3.7)), .F., .F.,,,, .F., ) )
			Else
				oBrowse:AddColumn( TCColumn():New( Trim(x3Titulo()), FieldWBlock( x3_campo, nAlias ),AllTrim(X3_PICTURE),,, if(X3_TIPO=="N","RIGHT","LEFT"), If(X3_TAMANHO>Len(X3_TITULO),3+(X3_TAMANHO*3.7),3+(LEN(X3_TITULO)*3.7)), .F., .F.,,,, .F., ) )
			EndIf

			aAdd(aOfuscLGPD, AllTrim(X3_CAMPO) ) //Array com campo
		Endif                                                 
		dbSkip()
	EndDo

		If FindFunction( "FwPDCanUse" ) .And. FwPDCanUse(.T.)
			oBrowse:aObfuscatedCols := FwProtectedDataUtil():SetObFuscatedFields(aOfuscLGPD)
		Endif

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
Return oBrowse

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WndIniBrw ³ Autor ³ Edson MAricate        ³ Data ³ 15/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa o browse                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ WndBrowse                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WndIniBrw(cCampo,cAlias)
Local aArea	:= GetArea()

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek(cCampo)
bBlock := &('{||'+X3_INIBRW+'}')


SX3->(dbSetOrder(1))
RestArea(aArea)
Return bBlock

Function WMudaCad(cTitle,cTexto)

cCadastro := cTitle +" - "+AllTrim(StrTran(cTexto,"&",""))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WndxPesqui³ Autor ³ Edson MAricate        ³ Data ³ 15/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa no arquivo.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ WndBrowse                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WndxPesqui(oBrowse,aPesqui,cSeek,lSaveOrd)
Local nSavOrder := Indexord()
Local oDlg
Local oCbx
Local cCampo	:= SPACE(40)
Local cOrd
Local lSeek		:= .F.
Local aCbx		:= {}
Local nX		:= 0
Local nRet		:= 0
Local oList := {}
Local aList := {}	
Local lPreview := .F.
Local lDetail := .F.
Local cAlias := Alias()
Local nOrd
Local lSeeAll := GetBrwSeeMode()
Local aPesqVar := {}
Local oPPreview
Local aScroll

DEFAULT lSaveOrd := .T.

If aPesqui<>Nil
	lSaveOrd := .F.
	For nx := 1 to Len(aPesqui)
		aPesqui[nx][1]	:=	Alltrim(aPesqui[nx][1])
		aAdd(aCbx,aPesqui[nx][1])
	Next
	DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0003 //"Pesquisa"
	
	@ 05,05 COMBOBOX oCBX VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont
	
	@ 22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL

	DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (nRet := 1,lSeek := .T., oDlg:End() )
	
	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()
	
	ACTIVATE MSDIALOG oDlg CENTERED

	If lSeek
		dbSetOrder(aPesqui[aScan(aCbx,Alltrim(cOrd))][2])		                        
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ a função de busca não esta preparada para efetuar um seek quando o ccampo contem data	³
		//³ e como os indices do contas a pagar que contem data são logo no inicio, fiz um 			³
		//³ tratamento especifico para as rotinas fina240 e fina241   							    ³
		//³   																						³
		//³ Marcelo Celi Marques - SIGA2964 														³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		// Inicio do tratamento
		If "DTOS(" $ Upper(Indexkey()) .And. FunName() $ "FINA240|FINA241"
		   cCampo := dTos(cTod(Substr(cCampo,1,8))) + Right(cCampo,Len(cCampo)-8)
		   cCampo := Alltrim(cCampo)
		Endif			
		// Fim do tratamento
		
		If dbSeek(cSeek+cCampo,.T.)
			nRet := Recno()
		EndIf
		
	EndIf
	If oBrowse!=Nil	
		oBrowse:Refresh()
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A opcao Retornar no MATA103 realiza o processo de forma exclusiva por filial, dessa forma e necessario ³
	//³ que a pesquisa tambem seja realizada de forma exclusiva, nao apresentando a coluna "filial".           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FWModeAccess(cAlias) == "C" .Or. FunName() $ "MATA103"
		SetBrwSeeAll(.F.)
	Else 
		SetBrwSeeAll(.T.)		
	EndIf
	
	nRet := AxPesqui()
	If oBrowse != Nil
		oBrowse:Refresh()
	EndIf
	
	SetBrwSeeAll(lSeeAll)			
EndIf

If lSaveOrd
	dbSetOrder(nSavOrder)
EndIf
Return nRet


Function WndChgOrd(nCol,oBrw,aHeadOrd,cAlias)
Local nPosOrd := aScan(aHeadOrd,{|x| x[1] == nCol })
Local nx

If nPosOrd > 0
	dbSelectArea(cAlias)
	dbSetOrder(aHeadOrd[nPosOrd][2])

	For nx := 1 to Len(aHeadOrd)
		cRes := If(nCol == aHeadOrd[nx,1],"COLDOWN","COLRIGHT")
		oBrw:SetHeaderImage(aHeadOrd[nx,1],cRes)
	Next
EndIf

Return
