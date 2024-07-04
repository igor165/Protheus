#INCLUDE "QDOA100.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QDOA100   ³ Autor ³ Newton R. Ghiraldelli   ³ Data ³ 18/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Follow-Up de Leitura de Documentos.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QDOA100()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGAQDO - Menu / Atualizacoes                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³ Programador ³Alteracao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³02/08/01³------³Aldo         ³ Habilitar/desabilitar Botao de Baixa qdo  ³±±
±±³        ³      ³             ³ a pendencia for pendente/baixada          ³±±
±±³16/08/01³------³Eduardo S.   ³ Substituicao de GetNewPar() por GetMv()   ³±±
±±³29/11/01³------³Eduardo S.   ³ Incluido o botao "Pesquisa" e "Cadastro Do³±±
±±³        ³      ³             ³ cto" e modificado o lay-out da tela.      ³±±
±±³04/01/02³------³Eduardo S.   ³ Alterado para visualizar docto tambem Html³±±
±±³04/04/02³ META ³Eduardo S.   ³ Alterado para Visualizar Docto com o Tipo ³±±
±±³        ³      ³             ³ de Editor definido no Cad. de Usuarios.   ³±±
±±³26/06/02³ META ³Eduardo S.   ³ Alterado para Visualizar Docto Externo.   ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOA100()

Local aData 	:= {}
Local nT			:= 0 
Local aQPath   := QDOPATH()
Local cQPathTrm:= aQPath[3]
Local cFiltro  := " "

Private Inclui := .f.
Private hOK    := LoadBitmap( GetResources(), "ENABLE" )
Private hNo    := LoadBitmap( GetResources(), "DISABLE" )
Private aQD1   := {}   
Private bQD1Line
Private oQD1
Private oWord
Private lTrat:= GetMv("MV_QDOQDG",.T.,.F.)

DbSelectArea("QDH")
DbSetOrder(1)
cFiltro := 'QDH_FILIAL == "'+xFilial("QDH")+'" .And. QDH_CANCEL <> "S" .And. QDH_OBSOL <> "S" .And. QDH_STATUS == "L  "'
Set Filter To &(cFiltro)

MsgRun( OemToAnsi(STR0001),OemToAnsi(STR0008),{ || QD100MtQD1() } ) // "Selecionando Documentos" ### "Aguarde..."

If Len( aQD1 ) > 0
   QD100MsDlg() 
Else 
   Help( " ", 1, "QDOCNTDCFL" )
Endif             

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
		QDRemDirHtm(AllTrim(aData[nT,1]))
   Endif
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD100MsDlg³ Autor ³ Newton R. Ghiraldelli   ³ Data ³ 18/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de Follow-Up de Leitura de Documentos.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD100MsDlg()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD100MsDlg()

Local oDlg
Local oImage1
Local oImage2
Local cQD1    := {}
Local aButtons:= {}

Private cCadastro   := OemToAnsi(STR0007) // "Cadastro de Documentos"
Private lSolicitacao:= .f.
Private aRotina     := {{" "," " ,0, 1 },{" "," " ,0, 2 }}  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0002) FROM 000,000 TO 385,625 OF oMainWnd PIXEL // "Follow-up de Leitura Documentos"

@ 012,003 SAY OemToAnsi(STR0003) OF oDlg PIXEL // " Documentos "
@ 020,003 LISTBOX oQD1 VAR cQD1 FIELDS;
           HEADER  " ",;
                   TitSX3("QD1_DOCTO")[1],;
                   TitSX3("QD1_RV")[1],;
                   TitSX3("QDH_TITULO")[1];
           SIZE    307, 150 OF oDlg PIXEL ;
           ON      DBLCLICK ( QD100BxPen( aQD1[oQD1:nAt, 7 ] ) );

oQD1:SetArray(aQD1)
oQD1:bLine := bQD1Line 
oQD1:Gotop()
oQD1:Refresh()
oQD1:cToolTip:= OemToAnsi(STR0011) //"Duplo click para abrir documento"	

@ 173,006 BITMAP oImage1 RESOURCE "ENABLE" SIZE 008,008 OF oDlg PIXEL			  
@ 173,015 SAY OemToAnsi(STR0004) SIZE 080,010 OF oDlg PIXEL  // "Leitura Realizada"

@ 182,006 BITMAP oImage2 RESOURCE "DISABLE" SIZE 008,008 OF oDlg PIXEL
@ 182,015 SAY OemToAnsi(STR0005) SIZE 080,010 OF oDlg PIXEL // "Leitura Pendente"

aButtons:= {{"PESQUISA"  ,{ || QDH->(AxPesqui()),QD100PQD1(),oQD1:Refresh()},OemToAnsi(STR0008)},;  // "Pesquisar"
				 {"RELATORIO" ,{ || QD100DlgV()},OemToAnsi(STR0009)}} // "Visualizar"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| If(aQD1[oQD1:nAt,1] == "P",QD100BxPen(aQD1[oQD1:nAt,7]),Help(" ",1,"QDOJABX")) },; //"Documento ja baixado anteriormente"
 																  {|| oDlg:End() },,aButtons ) CENTERED 

DbSelectArea("QDH")
Set Filter to

DbSelectArea("QD1")
Set Filter to

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD100BxPen³ Autor ³ Newton R. Ghiraldelli   ³ Data ³ 18/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Baixa leitura na tela de Follow-Up de Leitura de Documentos.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD100BxPen()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 - Numero do Registro                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA100 - QD100MsDlg                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD100BxPen(nReg)

Local ni       := 0
Local cChave   := ""
Local aUsrMat  := QA_USUARIO()
Local cMatFil  := aUsrMat[2]
Local cMatCod  := aUsrMat[3]
Local cMatDep  := aUsrMat[4]

Private bCampo := {|nCPO| Field( nCPO ) }

DbSelectArea("QD1")
DbGoto( nReg )

cChave := QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV

DbSelectArea( "QDH" )
DbSetOrder( 1 )

If QDH->( DbSeek( cChave ) )
   For ni := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next ni
	QdoDocCon()
	DbSelectArea( "QD1" )
	DbGoto( nReg )
	If QD1->QD1_PENDEN == "P"
		If !MsgYesNo( OemToAnsi(STR0012),OemToAnsi(STR0013) ) // "Confirma Baixa de Pendencia?" ### "Aten‡ao"
			Return .F.
		EndIf
		Begin Transaction
		If RecLock( "QD1", .f. )
			QD1->QD1_DTBAIX := dDataBase
			QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
			QD1->QD1_PENDEN := "B"
			QD1->QD1_LEUDOC := "S"
			QD1->QD1_FMATBX := cMatFil
			QD1->QD1_MATBX  := cMatCod
			QD1->QD1_DEPBX  := cMatDep
			QD1->( MsUnlock() )
		EndIf
		End Transaction
		aQD1[ oQD1:nAt, 1 ] :="B"
		bQD1Line := { || { If( Len( aQD1 ) > 0, If( aQD1[ oQD1:nAt, 1 ] =="B", hOk, hNo ),  Criavar( "QD1_PENDEN" ) ),;
		If( Len( aQD1 ) > 0, aQD1[ oQD1:nAt, 3 ], CriaVar("QD1_DOCTO" )),;
		If( Len( aQD1 ) > 0, aQD1[ oQD1:nAt, 4 ], CriaVar( "QD1_RV" )),;
		If( Len( aQD1 ) > 0, aQD1[ oQD1:nAt, 5 ], CriaVar( "QDH_TITULO" ))}}
	EndIf	
EndIf

oQD1:SetArray( aQD1 )
oQD1:bLine := bQD1Line
oQD1:Refresh()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD100MtQD1³ Autor ³ Newton R. Ghiraldelli   ³ Data ³ 18/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Carrega os lactos no array para a selecao de leitura.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD100MtQD1()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD100MtQD1()

Local aUsrMat   := QA_USUARIO()
Local cMatFil   := aUsrMat[2]
Local cMatCod   := aUsrMat[3]

DbSelectArea("QDH")            
DbSetOrder(3)
If DbSeek( xFilial("QDH")+"L  " )
	While !Eof() .and. QDH->QDH_FILIAL == xFilial("QDH") .and. QDH->QDH_STATUS == "L  "
		If QDH->QDH_OBSOL != "S" .and. QDH->QDH_CANCEL != "S"      
			DbSelectArea("QD1")
			DbSetorder(6)
			If DbSeek( cMatFil + cMatCod + QDH->QDH_DOCTO + "L  " )
				While !Eof() .and. QD1->QD1_FILMAT == cMatFil .and. QD1->QD1_MAT == cMatCod .and. QD1->QD1_DOCTO == QDH->QDH_DOCTO .and. QD1->QD1_TPPEND == "L  " 
					If QD1->QD1_TPDIST $ "1,3" .And. QD1->QD1_RV == QDH->QDH_RV
						Aadd( aQD1, { QD1->QD1_PENDEN, QD1->QD1_FILIAL, QD1->QD1_DOCTO, QD1->QD1_RV, QDH->QDH_TITULO, QD1->QD1_DTGERA, QD1->(Recno()), QD1->QD1_CHAVE } )
					Endif
               QD1->( DbSkip() )
				Enddo
			Endif   
		Endif
		DbSelectArea("QDH")
		QDH->( DbSkip() )
	Enddo
Endif

DbSelectArea( "QDH" )
DbSetOrder( 1 )

DbSelectArea( "QD1" )
DbSetOrder(1)

aQD1 := aSort( aQD1,,,{ |x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3] } ) 

bQD1Line := { || {	If( Len( aQD1 ) > 0, If( aQD1[ oQD1:nAt, 1 ] =="B", hOk, hNo ),  Criavar( "QD1_PENDEN" ) ),;
							If( Len( aQD1 ) > 0,     aQD1[ oQD1:nAt, 3 ],								CriaVar( "QD1_DOCTO" )  ),;
							If( Len( aQD1 ) > 0,     aQD1[ oQD1:nAt, 4 ],                    	CriaVar( "QD1_RV" )     ),;
							If( Len( aQD1 ) > 0,     aQD1[ oQD1:nAt, 5 ],                    	CriaVar( "QDH_TITULO" ) )}}

Return aQD1


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD100CadDoc³ Autor ³Eduardo de Souza         ³ Data ³ 28/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Abre cadastro de documento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD100CadDoc(ExpC1,ExpC2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Documento                                              ³±±
±±³          ³ExpC2 - Revisao do Docto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA100                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD100CadDoc(cDocto,cRv)

Local ni	   := 1

Private bCampo := {|nCPO| Field( nCPO ) }

DbSelectArea( "QDH" )
DbSetOrder( 1 )

If QDH->(DbSeek(xFilial("QDH")+cDocto+cRv))
	For ni := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next ni

	If QDH->QDH_OBSOL == "S"
		If ChkPsw(96)
			QD050Telas("QDH",QDH->(RecNo()),2)
		EndIf
	Else
		QD050Telas("QDH",QDH->(RecNo()),2)
	EndIf

EndIf	

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD100PQD1  ³ Autor ³ Eduardo de Souza   ³ Data ³ 28/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Posciona QD1 conforme Pesquisa                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD100PQD1()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA100                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD100PQD1()

If Ascan( aQD1,{ |x| x[8] == QDH->QDH_CHAVE }) > 0
	oQD1:nAt:= Ascan( aQD1,{ |x| x[8] == QDH->QDH_CHAVE })
Else
	oQD1:nAt:= 1
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QD100DlgV  ³ Autor ³ Eduardo de Souza   ³ Data ³ 20/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de Visualizacao de Docto e Cadastro da opcao Detalhes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD100DlgV() 									                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA100                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD100DlgV()

Local oDlgVis
Local oVisDoc
Local oBtn1
Local oBtn2
Local nVisDoc:= 1
Local cFiltro:= QDH->(DbFilter())

Private bCampo:= {|nCPO| Field( nCPO ) }

DEFINE MSDIALOG oDlgVis TITLE OemToAnsi(STR0009)+" ?" FROM 000, 000 TO 085, 342 PIXEL // "Visualizar"
	
@ 010,010 RADIO oVisDoc VAR nVisDoc ITEMS OemToAnsi(STR0006),OemToAnsi(STR0007); //"Documento" ### "Cadastro de Documentos"
				3D SIZE 070,010 OF oDlgVis PIXEL

DEFINE SBUTTON oBtn1 FROM 025, 105 TYPE 1 ENABLE OF oDlgVis;
			ACTION (QD100VisDc(nVisDoc),oDlgVis:End())
	
DEFINE SBUTTON oBtn2 FROM 025, 137 TYPE 2 ENABLE OF oDlgVis;
			ACTION  oDlgVis:End()
	
ACTIVATE MSDIALOG oDlgVis CENTERED	

DbSelectArea("QDH")
Set Filter To
Set Filter To &(cFiltro)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD100VisDc ³ Autor ³ Eduardo de Souza   ³ Data ³ 28/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualizacao de Docto e Cadastro na opcao detalhes        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD100VisDc(ExpN1)          				                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Escolha da Visualizacao (1-Docto/2-Cadastro)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA100                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD100VisDc(nVisDoc)

Local nOrdQD1:= QD1->(IndexOrd())
Local nPosQD1:= QD1->(Recno())

If QDH->(DbSeek(aQD1[oQD1:nAt,2]+aQD1[oQD1:nAt,3]+aQD1[oQD1:nAt,4]))
	If nVisDoc == 1
		If QDH->QDH_OBSOL == "S"
			If ChkPsw(96)
				QdoDocCon()
			EndIf
		Else
			QdoDocCon()
		EndIf
	Else
		If QDH->QDH_OBSOL == "S"
			If ChkPsw(96)
				QD050Telas("QDH",QDH->(Recno()),8)
			EndIf
		Else
			QD050Telas("QDH",QDH->(Recno()),8)
		EndIf
	EndIf
	QD1->(DbSetOrder(nOrdQD1))
	QD1->(DbGoTo(nPosQD1))    
EndIf

Return
