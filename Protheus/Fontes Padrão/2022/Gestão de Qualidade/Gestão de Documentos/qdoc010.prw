#INCLUDE "QDOC010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

/*�������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QDOC010   � Autor �Newton R. Ghiraldelli    � Data � 14/02/2000 ���
�����������������������������������������������������������������������������Ĵ��
���Descri�ao �Pesquisa de Localizadores/Texto em Documentos                   ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe	 �QDOC010                                                         ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���  Data  � BOPS � Programador �Alteracao                                    ���
�����������������������������������������������������������������������������Ĵ��
���16/08/01�------�Eduardo S.   � Substituicao de GetNewPar() por GetMv()     ���
���27/11/01�------�Eduardo S.   � Acerto para tambem buscar textos no titulo  ���
���        �      �             � do Docto. Acerto para buscar mais de uma pa-���
���        �      �             � lavra por pesq. Modificado o Lay-out da Tela���
���04/01/02�------�Eduardo S.   � Alterado para visualizar docto em Html.     ���
���28/06/02� META �Eduardo S.   � Alterado para visualizar Docto externo.     ���
���19/07/02�016803�Eduardo S.   � Incluido a opcao "Pesquisa Obsoleto".       ���
���05/09/02� ---- �Eduardo S.   � Acerto no posicionamento da tela quando nao ���
���        �      �             � encontrado documentos.                      ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function QDOC010()

Local oChk01
Local oChk02
Local oChk03
Local oChk04
Local oChk05
Local oPesq
Local oBtn01
Local oDoc
Local cDoc 
Local oBtnCadDoc
Local oBtnVisDoc
Local bDocLine
Local aData 	    := {}
Local aDoc          := {}
Local nT			:= 0
Local aQPath   		:= QDOPATH()
Local cQPathTrm		:= aQPath[3]

Local oFilDe
Local oFilPa
Local aSize		:= MsAdvSize()
Local aObjects  := {{ 100, 100, .T., .T., .T. }}
Local aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 4, 4 } 
Local aPosObj	:= MsObjSize( aInfo, aObjects, .T. , .T. )
Local oPanel
Local aPreConfig:= {}
Local lCxAlta	:= .F.

Private oDlg
Private oWord

Private nRad01      := 1
Private lChk01      := .f.
Private lChk02      := .f.
Private lChk03      := .f.
Private lChk04      := .f.
Private lChk05      := .f.
Private Inclui      := .f.
Private cPesq       := Space( aSize[4]-80 )
Private cCadastro   := OemToAnsi(STR0014) // "Cadastro de Documentos"
Private lSolicitacao:= .f.
Private aRotina     := {{ " "," ",0, 1},{ " "," ",0, 2}}  
Private aQDHfil  	:= QDC010QDHF()     
Private cFilDe		:= IF(Len(aQDHfil) > 0, aQDHfil[1]    ,"  ")
Private cFilPa		:= IF(Len(aQDHfil) > 0, Atail(aQDHfil),"zz")
Private lTrat		:= GetMv("MV_QDOQDG",.T.,.F.)

DEFINE MSDIALOG oDlg FROM aSize[7],000 TO aSize[6],aSize[5] TITLE OemToAnsi(STR0001) PIXEL OF oMainWnd // "Pesquisa"

@ 00,00 MSPANEL oPanel PROMPT "" SIZE 003,100 OF oDlg
oPanel:Align := CONTROL_ALIGN_TOP

If Existblock("QDC10PRE")
	aPreConfig := Execblock("QDC10PRE",.F.,.F.,{lChk01,lChk02,lChk03,lChk05,nRad01,lChk04,lCxAlta})
	lChk01 := aPreConfig[1]
	lChk02 := aPreConfig[2]
	lChk03 := aPreConfig[3]
	lChk05 := aPreConfig[4]
	nRad01 := aPreConfig[5]
	lChk04 := aPreConfig[6]
	lCxAlta:= aPreConfig[7]	
Endif

@ 004,005 TO 057,102 PROMPT OemToAnsi( STR0005 ) OF oPanel PIXEL //"Selecao"
@ 011,010 CHECKBOX oChk01 VAR lChk01 PROMPT OemToAnsi( STR0006 ) SIZE 80,10 OF oPanel PIXEL //"Pesquisar Localizadores"
@ 022,010 CHECKBOX oChk02 VAR lChk02 PROMPT OemToAnsi( STR0007 ) SIZE 80,10 OF oPanel PIXEL //"Pesquisar em Campos Texto"
@ 033,010 CHECKBOX oChk03 VAR lChk03 PROMPT OemToAnsi( STR0013 ) SIZE 80,10 OF oPanel PIXEL //"Pesquisar em Titulos"
@ 044,010 CHECKBOX oChk05 VAR lChk05 PROMPT OemToAnsi( STR0025 ) SIZE 80,10 OF oPanel PIXEL //"Pesquisar em Codigo"

@ 004,107 TO 057,204 PROMPT OemToAnsi( STR0002 ) OF oPanel PIXEL //"Criterio"
@ 011,112 RADIO oRad01 VAR nRad01 SIZE 80,11 OF oPanel PIXEL ;
          ITEMS OemToAnsi( STR0003 ),; //"Documentos Finalizados"
                OemToAnsi( STR0004 )  //"Todos os Documentos"    

@ 033,112 CHECKBOX oChk04 VAR lChk04 PROMPT OemToAnsi(STR0020) SIZE 80,10 OF oPanel PIXEL //"Pesquisa Obsoleto"
oChk04:bChange:={|| IF(ChkPsw(96),"",(lChk04:=.F.,oChk04:Refresh(),oChk04:disable())) }

@ 060,005 TO 085,aSize[4]+195 PROMPT OemToAnsi(STR0008 ) COLOR CLR_HRED OF oPanel PIXEL //"Palavra a ser Pesquisada- Para palavras separe com ; (Ponto e Virgula) para Grupos : (Dois Pontos)"
@ 068,010 MSGET oPesq VAR cPesq PICTURE Iif(lCxAlta,"@!","") SIZE aSize[4]+180,10 OF oPanel PIXEL

@ 090,005 SAY OemToAnsi(STR0015) COLOR CLR_HRED OF oPanel PIXEL // "Documentos Encontrados"

@ 088,155 BUTTON oBtnCadDoc PROMPT OemToAnsi(STR0016) SIZE 055, 012 PIXEL OF oPanel; // "Cadastro Docto"
					ACTION IF(Len(aDoc) > 1 .Or. (Len(aDoc) == 1 .And. !Empty(aDoc[1,2])),QDC01CadDoc(aDoc[oDoc:nAt,1],aDoc[oDoc:nAt,2],aDoc[oDoc:nAt,3]),Help(" ",1,"QDOCTXTNEX")) 
	
@ 088,210 BUTTON oBtnVisDoc PROMPT OemToAnsi(STR0017) SIZE 055, 012 PIXEL OF oPanel; // "Visualiza Docto"
					ACTION IF(Len(aDoc) > 1 .Or. (Len(aDoc) == 1 .And. !Empty(aDoc[1,2])),QDC010Vis(aDoc[oDoc:nAt,1],aDoc[oDoc:nAt,2],aDoc[oDoc:nAt,3]),Help(" ",1,"QDOCTXTNEX"))

IF Len(aQDHfil) > 0 //QDH (EXCLUSIVO)
                                                                                      
	@ 004,275 BUTTON oBtn01 PROMPT OemToAnsi(STR0018) SIZE 045, 012 PIXEL OF oPanel; // "Pesquisa"
					ACTION (QDC01PsTxt(aDoc),oDoc:SetArray(aDoc),oDoc:bLine:= bDocLine,oDoc:Refresh())
    
	@ 004,211 TO 046,260 PROMPT OemToAnsi( aLLTRIM(TitSX3("QDH_FILIAL")[1]) ) OF oPanel PIXEL 
	@ 015,215 SAY OemToAnsi(STR0021) SIZE 18,8 OF oPanel PIXEL		 //"De: "
	@ 015,228 MSGET oFilDe VAR cFilDe F3 "SM0" VALID QA_CHKFIL(cFilDe) .AND. (AsCAN(aQDHfil,cFilDe)!=0) PICTURE "@!" SIZE 18,8 OF oPanel PIXEL	
	
	@ 030,215 SAY OemToAnsi(STR0022) SIZE 18,8 OF oPanel PIXEL		 //"At�:"
	@ 030,228 MSGET oFilPa VAR cFilPa F3 "SM0" VALID QA_CHKFIL(cFilPa) .AND. (cFilPa >= cFilDe) .AND. (AsCAN(aQDHfil,cFilPa)!=0) PICTURE "@!" SIZE 18,8 OF oPanel PIXEL	
	
	@ 114,003 LISTBOX oDoc VAR cDoc FIELDS;
	            HEADER  TitSX3("QDH_FILIAL")[1],;
	            		TitSX3("QDH_DOCTO")[1],;
	                    TitSX3("QDH_RV")[1],;
	                    TitSX3("QDH_TITULO")[1];
	            SIZE    263,076 OF oDlg PIXEL ;
	            ON      DBLCLICK IF(Len(aDoc) > 1 .Or. (Len(aDoc) == 1 .And. !Empty(aDoc[1,2])),QDC010VisDc(aDoc[oDoc:nAt,1],aDoc[oDoc:nAt,2],aDoc[oDoc:nAt,3]),Help(" ",1,"QDOCTXTNEX"))
	                                                         
	bDocLine := { || {	If( Len( aDoc ) > 0, QDC10FIL(aDoc[ oDoc:nAt, 1 ]), SPACE(TamSx3( "QDH_FILIAL"  )[1])),;
						If( Len( aDoc ) > 0, aDoc[ oDoc:nAt, 2 ], SPACE(TamSx3( "QDH_DOCTO"  )[1])),;
						If( Len( aDoc ) > 0, aDoc[ oDoc:nAt, 3 ], SPACE(TamSx3( "QDH_RV"     )[1])),;
						If( Len( aDoc ) > 0, aDoc[ oDoc:nAt, 4 ], SPACE(TamSx3( "QDH_TITULO" )[1]))}}

Else  //QDH (COMPARTILHADO)	     

	@ 004,211 BUTTON oBtn01 PROMPT OemToAnsi(STR0018) SIZE 045, 012 PIXEL OF oPanel; // "Pesquisa"
					ACTION (QDC01PsTxt(aDoc),oDoc:SetArray(aDoc),oDoc:bLine:= bDocLine,oDoc:Refresh())

	@ 114,003 LISTBOX oDoc VAR cDoc FIELDS;
	            HEADER  TitSX3("QDH_DOCTO")[1],;
	                    TitSX3("QDH_RV")[1],;
	                    TitSX3("QDH_TITULO")[1];
	            SIZE    263,076 OF oDlg PIXEL ;  
	            ON      DBLCLICK IF(Len(aDoc) > 1 .Or. (Len(aDoc) == 1 .And. !Empty(aDoc[1,2])),QDC010VisDc(aDoc[oDoc:nAt,1],aDoc[oDoc:nAt,2],aDoc[oDoc:nAt,3]),Help(" ",1,"QDOCTXTNEX"))
	                                                         
	bDocLine := { || {	If( Len( aDoc ) > 0, aDoc[ oDoc:nAt, 2 ], SPACE(TamSx3( "QDH_DOCTO"  )[1])),;
						If( Len( aDoc ) > 0, aDoc[ oDoc:nAt, 3 ], SPACE(TamSx3( "QDH_RV"     )[1])),;
						If( Len( aDoc ) > 0, aDoc[ oDoc:nAt, 4 ], SPACE(TamSx3( "QDH_TITULO" )[1]))}}
Endif

oDoc:SetArray( aDoc )
oDoc:bLine    := bDocLine
oDoc:cToolTip := OemToAnsi( STR0012 ) //"Duplo click para abrir documento"	
oDoc:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg 	CENTERED ON INIT EnchoiceBar (oDlg, { || oDlg:End() }, { || oDlg:End() } )

If Type("oWord") <> "U"
	If !Empty(oWord) .And. oWord <> "-1"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
	Endif
Endif

aData  := DIRECTORY(cQPathTrm+"*.CEL")
For nT:= 1 to Len(aData)
	If File(cQPathTrm+AllTrim(aData[nT,1]))
		FErase(cQPathTrm+AllTrim(aData[nT,1]))
	Endif
Next
aData  := DIRECTORY(cQPathTrm+"*.DOT")
For nT:= 1 to Len(aData)
	If File(cQPathTrm+AllTrim(aData[nT,1]))
		FErase(cQPathTrm+AllTrim(aData[nT,1]))
	Endif
Next
aData  := DIRECTORY(cQPathTrm+"*.HTM")
For nT:= 1 to Len(aData)
	If File(cQPathTrm+AllTrim(aData[nT,1]))
		QDRemDirHtm(AllTrim(aData[nT,1]),.F.)
   Endif
Next

Return

/*�������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QDC01PsTxt� Autor �Newton R. Ghiraldelli    � Data � 14/02/2000 ���
�����������������������������������������������������������������������������Ĵ��
���Descri�ao �Realiza a Pesquisa de Localizadores/Texto em Documentos         ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe	 �QDC01PsTxt()                                                    ���
�����������������������������������������������������������������������������Ĵ��
���Uso		 �Siga Quality ( Generico )                                       ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function QDC01PsTxt(aDoc)

Local aPesq    := {}
Local aQA2     := {}
Local cExpFilt := " "
Local cFiltro  := ""
Local cFuncao  := ""
Local cPescAux := ""
Local cQuery   := ""
Local cTexAnd  := ""
Local cTexto   := ""
Local cTxtQA2  := ""
Local cTxtQA6  := ""
Local cTxtQDH  := ""
Local i        := 0
Local nC       := 0
Local nCarr    := 0
Local nPCarr   := 0
Local oExec    := Nil

aDoc  := {}

CursorWait()

//��������������������������������������������������Ŀ
//� Pesquisa por Localizadores, em Titulos e Codigos �
//����������������������������������������������������
cFuncao := Iif(FindFunction( "QAStrToASC" ), "QAStrToASC", "FwQtToChr")
cPescAux:= StrTran(&cFuncao.(Alltrim(cPesq)),"'",'')

If lChk01 .Or. lChk02 .Or. lChk03 .Or. lChk05
	cQuery :=" SELECT QDH_FILIAL,QDH_DOCTO,QDH_RV,QDH_TITULO "
	cQuery += " FROM " + RetSqlName("QDH")
	cQuery += " WHERE QDH_FILIAL >= '" + cFilDe + "' AND QDH_FILIAL <= '" + cFilPa + "' AND "
	If Right(AllTrim(cPescAux),1) <> ";"
		cTexto:= AllTrim(cPescAux)+";"
	Else
		cTexto:= Alltrim(cPescAux)
	EndIf
	If !Empty(cTexto)
		// Porta a string para um vetor quebrando por ";"
		While At(";",AllTrim(cTexto)) <> 0
			aAdd(aPesq,Substr(AllTrim(cTexto),1,At(";",AllTrim(cTexto))-1))
			cTexto := Substr(AllTrim(cTexto),At(";",AllTrim(cTexto))+1)	
		EndDo
		// Converte ":" para "%"
		For i := 1 To Len(aPesq)
			If At(":",AllTrim(aPesq[i])) <> 0
				aPesq[i] := (StrTran(aPesq[i],':','%'))
			EndIf
		Next
		cQuery += " ( "
		If lChk01
			cQuery += " QDH_FILIAL||QDH_DOCTO||QDH_RV IN ("
			cQuery += " SELECT QD6_FILIAL||QD6_DOCTO||QD6_RV"
			cQuery += " FROM " + RetSqlName("QD6") + " WHERE"
			For i := 1 To Len(aPesq)
				cQuery += " QD6_CHAVE LIKE '%"  + aPesq[i] + "%' OR "
			Next
			cQuery := SubStr(cQuery,1,Len(cQuery)-4)+" AND D_E_L_E_T_ <> '*' ) OR "
		EndIf
		If lChk02
			cQuery += " QDH_CHAVE IN ("
			cQuery += " SELECT DISTINCT QA2_CHAVE"
			cQuery += " FROM " + RetSqlName("QA2")
			cQuery += " WHERE QA2_ESPEC IN ('OBJ     ','REV     ','SUM     ','TXT     ','COM     ','CRI     ','RED     ') AND ("
			For i := 1 To Len(aPesq)
				cQuery += " QA2_TEXTO LIKE '%"  + aPesq[i] + "%' OR "
			Next
			cQuery := SubStr(cQuery,1,Len(cQuery)-4)+" )) OR "
		EndIf
		If lChk03
			For i := 1 To Len(aPesq)
				cQuery += " QDH_TITULO LIKE '%" + aPesq[i] + "%' OR "
			Next
		EndIf
		If lChk05
			For i := 1 To Len(aPesq)
				cQuery += " QDH_DOCTO LIKE '%"  + aPesq[i] + "%' OR "
			Next
		EndIf				
		cQuery := SubStr(cQuery,1,Len(cQuery)-4)+" ) AND"
	EndIf

	cQuery += " QDH_CANCEL <> 'S' AND"
	cQuery += If (nRad01 == 1," QDH_STATUS = 'L  ' AND","")
	cQuery += If (!lChk04	 ," QDH_OBSOL <> 'S' AND"	,"")

	cQuery += " D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)

	While TMP->(!Eof())
		If aScan( aDoc, { |x| x[1] == TMP->QDH_FILIAL .And. x[2] == TMP->QDH_DOCTO .And. x[3] == TMP->QDH_RV } ) == 0
			aAdd( aDoc, { TMP->QDH_FILIAL, TMP->QDH_DOCTO, TMP->QDH_RV, TMP->QDH_TITULO } )
		EndIf
		TMP->(DbSkip())
	EndDo

	DbCloseArea()

EndIf
	

If Len( aDoc ) > 0
	aDoc := aSort( aDoc,,,{ |x,y| x[2] + x[3] < y[2] + y[3] } ) 
Else
	Help(" ",1,"QDOCTXTNEX")
	aDoc := {}
End               

DbSelectArea("QDH")
DbClearFilter()

CursorArrow()

Return

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QDC010VisDc� Autor �Newton R. Ghiraldelli    � Data � 14/02/00 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao � Abre o documento selecionado na tela de Resultado da Pesquisa.���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QDC010VisDc(ExpC1,ExpC2)                                      ���
����������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Documento                                             ���
���          � ExpC2 - Revisao do Documento                                  ���
����������������������������������������������������������������������������Ĵ��
���Uso		 � QDOC010                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function QDC010VisDc(cFiDoc,cDocto,cRv)

Local nI     := 0   

Private bCampo:= {|nCPO| Field( nCPO ) }

DbSelectArea("QDH")
DbSetOrder(1)

If QDH->(DbSeek(cFiDoc+cDocto+cRv))
   For ni := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next ni
Endif

If !QD050LiDoc()
   Help(" ",1,"QDOCDCNDSP")
   Return .F.
Endif

If QDH->QDH_OBSOL == "S"
	If ChkPsw(96)
		QdoDocCon()
	EndIf
ElseIf AllTrim(QDH->QDH_STATUS) == "L" .AND. QDH->QDH_DTLIM < dDataBase  .AND. !Empty(QDH->QDH_DTLIM) .AND. !VerSenha(98)
	MsgAlert(OemToAnsi(STR0023),OemToAnsi(STR0024))   
	Return .F.
Else
	QdoDocCon()
EndIf

Return .T.

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QDC010Vis  � Autor �Adalberto Mendes Neto    � Data � 07/11/07 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao � Abre o documento selecionado na tela de Resultado da Pesquisa.���
���          � Esta funcao serve apenas para o Botao VISUALIZA DOCTO         ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QDC010Vis(ExpC1,ExpC2)                                        ���
����������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Documento                                             ���
���          � ExpC2 - Revisao do Documento                                  ���
����������������������������������������������������������������������������Ĵ��
���Uso		 � QDOC010                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function QDC010Vis(cFiDoc,cDocto,cRv)

Local nI     := 0   

Private bCampo:= {|nCPO| Field( nCPO ) }

DbSelectArea("QDH")
DbSetOrder(1)

If QDH->(DbSeek(cFiDoc+cDocto+cRv))
   For ni := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next ni
Endif

If !QD050LiD()
   Help(" ",1,"QDOCDCNDSP")
   Return .F.
Endif

If QDH->QDH_OBSOL == "S"
	If ChkPsw(96)
		QdoDocCon()
	EndIf
ElseIf AllTrim(QDH->QDH_STATUS) == "L" .AND. QDH->QDH_DTLIM < dDataBase .AND. !VerSenha(98) .And. !Empty(QDH->QDH_DTLIM)
	MsgAlert(OemToAnsi(STR0023),OemToAnsi(STR0024))   
	Return .F.
Else
	QdoDocCon()
EndIf

Return .T.
/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QDC01CadDoc� Autor �Eduardo de Souza         � Data � 26/11/01 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao �Abre o documento selecionado na tela de Resultado da Pesquisa  ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 �QDC01CadDoc(ExpC1,ExpC2,ExpC3)                                 ���
����������������������������������������������������������������������������Ĵ��
���Parametro �Nao tem                                                        ���
����������������������������������������������������������������������������Ĵ��
���Uso		 �QDOC010                                                        ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function QDC01CadDoc(cFiDoc,cDocto,cRv)

Local cExpFilt := ""
Local ni

Private bCampo := {|nCPO| Field( nCPO ) }

DbSelectArea( "QDH" )
DbSetOrder( 1 )

If QDH->(DbSeek(cFiDoc+cDocto+cRv))

	For ni := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next ni

	If QDH->QDH_OBSOL == "S"
		If ChkPsw(96)
			QD050Telas("QDH",QDH->(RecNo()),8)
		EndIf
	Else
		QD050Telas("QDH",QDH->(RecNo()),8)
	EndIf

   DbSelectArea("QDH")
   DbSetorder( 1 )
	If nRad01 == 1
	   cExpFilt := "QDH_STATUS == 'L  '"
	   SET FILTER TO &(cExpFilt)
	Else
	   Set Filter To
	Endif

EndIf	

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QDC010QDHF�Autor  �Telso Carneiro      � Data �  03/08/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pesquisa as filiais do QDH para facilitar a pesquisa do     ���
���          �usuario                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � QDOC010                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QDC010QDHF()
Local aAux	 :={}
Local cCtrFil:=""
Local cFilSx2:= SX2->(DbFilter())
Local aArea	 := GetArea()

cModoQDH:= FWModeAccess("QDH",3)

IF cModoQDH =="E" 

cQuery :="SELECT DISTINCT QDH.QDH_FILIAL "
cQuery +="FROM " + RetSqlName("QDH")+" QDH "
cQuery +="WHERE "
cQuery +=" QDH.D_E_L_E_T_ <> '*' "

If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1"
Else
	cQuery += " ORDER BY " + SqlOrder("QDH_FILIAL")
Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQDH",.T.,.T.)

DbGotop()
While TMPQDH->(!Eof())
	AADD(aAux,TMPQDH->QDH_FILIAL)	
	TMPQDH->(DbSkip())
Enddo
TMPQDH->(DbCLOSEAREA())
                    
Endif


RestARea(aArea)
Return(aAux)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QDC10FIL  �Autor  �Telso Carneiro      � Data �  04/08/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Localiza o Nome da Filial para os ListBox                  ���
���			 �															  ���
�������������������������������������������������������������������������͹��
���Sintaxe	 �QDC10FIL(Filial )                          				  ���
�������������������������������������������������������������������������͹��
���Uso       �  oDoc:bLine              								  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QDC10FIL(cCodFil)
local aArea   := GetArea()
Local nPosSM0 := 1
Local cFilAtu :=""  

DbSelectArea("SM0")
DbSetOrder(1)
nPosSM0:= Recno()

If SM0->(DbSeek(cEmpAnt+cCodFil))
	cFilAtu := cCodFil+"-"+SM0->M0_FILIAL
Endif
SM0->(DbGoto(nPosSM0))

RestArea(aArea)

Return(cFilAtu)
