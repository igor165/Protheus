#INCLUDE "MSOLE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "QDOA090.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QDOA090   ³ Autor ³Newton Rogerio Ghiraldelli³ Data ³ 04/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Faz a importacao de documentos para dentro do sistema.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QDOA090                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGAQDO - Generico                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³ Programador ³Alteracao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³28/02/02³013760³ Eduardo S.  ³Acerto na Gravacao para validar Diretorios. ³±±
±±³27/03/02³ META ³ Eduardo S.  ³Alterado para utilizar o novo conceito de   ³±±
±±³        ³      ³             ³arquivos de Usuarios do Quality.            ³±±
±±³22/03/02³ ---- ³ Eduardo S.  ³Acerto para apresentar somente os usuarios  ³±±
±±³        ³      ³             ³da filial selecionada.                      ³±±
±±³08/01/03³ ---- ³ Eduardo S.  ³ Alterado para permitir pesquisar usuarios  ³±±
±±³        ³      ³             ³ de outras filiais.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOA090()

Local oBtn1
Local oDlg
Local oArquivo
Local oCodDocto
Local oRevisao
Local oTitulo
Local oScroll
Local oQAAMat
Local oQAANom
Local oTpCod
Local oTpDes
Local aUsrMat := QA_USUARIO()
Local lApelido:= aUsrMat[1]
Local oQAAFil
Local cF3	  := GetNewPar("MV_QA090F3","")		//Consulta Padrao do campo Documento
Local aButtons := {}

Private cRevisao := Space( TamSx3("QDH_RV")[1] )
Private cArquivo := Space( TamSx3("QDH_NOMDOC")[1] )
Private cCodDocto:= Space( TamSX3("QDH_DOCTO")[1] )
Private cTitulo  := Space( TamSX3("QDH_TITULO")[1] )
Private cQAAMat  := Space( TamSX3("QAA_MAT")[1] )
Private cQAANom  := Space( TamSX3("QAA_NOME")[1] )
Private cTpDes   := Space( TamSX3("QD2_DESCTP")[1] )
Private cTpCod   := Space( TamSX3("QD2_CODTP")[1] )
Private	Inclui   := .t.
Private cFilMat  := xFilial("QAA")
Private nQaConPad:= 4

If !lApelido
	Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
	Return .f.
Endif

IF QDOChkRmt() //Checa se o Remote e Linux
	Return .f.
Endif

DbSelectArea("QAA")
DbSetOrder(1)

DbSelectArea("QDH")
DbSetOrder(1)

DbSelectArea("QD2")
DbSetOrder(1)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 000,000 TO 330,595 OF oMainWnd PIXEL // "Importa‡„o de Arquivo Documento"
oScroll := TScrollBox():new(oDlg,035,003,075,293,.T.,.T.,.T.)

@ 006, 003 SAY OemToAnsi( STR0003 ) SIZE 060,010 COLOR CLR_HBLUE OF oScroll PIXEL //"Nome do Documento"
@ 005, 054 MSGET oArquivo  VAR cArquivo  PICTURE "@!" SIZE 200,007 OF oScroll PIXEL

DEFINE SBUTTON oBtn1 FROM 003,258 TYPE 4 ENABLE OF oScroll ACTION cArquivo := QD090VArq("*.Doc","*.Docx") 
oBtn1:cToolTip := OemToAnsi( STR0004 ) // "Abre arquivo documento (*.doc)"

@ 018, 003 SAY OemToAnsi( STR0006 ) SIZE 060,007 COLOR CLR_HBLUE OF oScroll PIXEL //"Documento"
@ 017, 054 MSGET oCodDocto VAR cCodDocto F3 "QDH" VALID QD090VAL(cCodDocto,@cRevisao,oRevisao)	SIZE 070,007 OF oScroll PIXEL

@ 018, 130 SAY OemToAnsi( STR0007 ) SIZE 025,007 COLOR CLR_HBLUE OF oScroll PIXEL //"Revis„o"
@ 017, 155 MSGET oRevisao VAR cRevisao PICTURE "999" VALID QD090VAL(cCodDocto,@cRevisao,oRevisao) SIZE 015,007 OF oScroll PIXEL

@ 030, 003 SAY OemToAnsi( STR0008 ) SIZE 060,007 COLOR CLR_HBLUE OF oScroll PIXEL //"T¡tulo Documento"
@ 029, 054 MSGET oTitulo VAR cTitulo SIZE 231,007 OF oScroll PIXEL

@ 043, 003 SAY OemToAnsi(STR0009) COLOR CLR_HBLUE OF oScroll PIXEL //" Digitador "
@ 042, 054 MSGET oQAAFil VAR cFilMat F3 "SM0" SIZE 047,007 OF oScroll PIXEL;
				VALID QA_CHKFIL(cFilMat,@cFilMat)
@ 042, 103 MSGET oQAAMat VAR cQAAMat F3 "QDE" PICTURE '@!' SIZE 045,007 OF oScroll PIXEL;
				VALID QD090ValQAA(@oQAANom,cFilMat)
@ 042, 150 MSGET oQAANom VAR cQAANom PICTURE '@!' SIZE 135,007 OF oScroll PIXEL
oQAANom:lReadOnly:= .T.

@ 057, 003 SAY OemToAnsi(STR0012) COLOR CLR_HBLUE OF oScroll PIXEL //" Tipo de Documento "
@ 056, 054 MSGET oTpCod VAR cTpCod F3 "QD2" PICTURE '@!' SIZE 025,007 OF oScroll PIXEL;
				VALID QD090ValQD2(@oTpDes)
@ 056, 089 MSGET oTpDes VAR cTpDes PICTURE '@!' SIZE 116,007 OF oScroll PIXEL
oTpDes:lReadOnly:= .T.

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {||QD090GrImp(cFilMat),oQAANom:Refresh(),oTpDes:Refresh()},{||oDlg:End()}),oArquivo:SetFocus(.t.)) CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD090VArq³ Autor ³Cicero Odilio Cruz        ³ Data ³ 05/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a extencao do arquivo a ser anexado( Devido a erro na  ³±±
±±³          ³ cGetFile )                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD090VArq()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA090()                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD090VArq(cExt,cExt2)
Local cFile := " "
cFile := cGetFile("*.Doc|*.doc|*.Docx|*.docx",,0,,.T.,49)      
// Analiso a extensao do arquivo anexado para garantir apenas arquivos *.Doc
If (Upper(Right(cExt,3)) != Upper(Right(Alltrim(cFile),3)) .and. Upper(Right(cExt2,4)) != Upper(Right(Alltrim(cFile),4)) )
	MsgInfo(STR0021)
	cFile:= " "
EndIf
Return cFile

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD090GrImp³ Autor ³Newton Rogerio Ghiraldelli³ Data ³ 04/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Grava o arquivo documento importado dentro do sistema          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD090GrImp()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA090()                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD090GrImpr(cFilMat)

Local aQPath   := QDOPATH()
Local aUsrMat  := QA_USUARIO()
Local cQPath   := aQPath[1] // Diretorio que contem os .CEL
Local cStrTrab := ""
Local cUltRev  := ""
Local lCopiou  := .F.
Local nC
Local nI

Private bCampo   := {|nCPO| Field( nCPO ) }
Private cFileCEL := "000001"+SubStr(StrZero(Year(dDataBase),4),3,2)+".CEL"
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private cMatFil  := aUsrMat[2]

If	Empty(cArquivo) .Or. Empty(cCodDocto) .Or. Empty(cRevisao) .Or. ;
	Empty(cTitulo) .Or.	Empty(cQAAMat) .Or. Empty(cTpCod)
	Help(" ",1,"QD090COBRI")  // Campos obrigatorios
	Return .f.
EndIf

If !FreeForUse("DOC",xFilial("QDH")+cCodDocto+cRevisao)
	Return .F.
EndIf

If !File( cArquivo )
	MsgAlert( OemToAnsi( STR0015 ), OemToAnsi( STR0016 ) ) // "Arquivo documento n„o existe no diret¢rio especificado." ### "Aten‡„o"
	Return .f.
EndIf

If !ChkDocto(xFilial("QDH"),cCodDocto,cRevisao)
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³verifica se existe revisao e se esta pendente  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QDH->(DbSetOrder(6)) //Revisao invertida
If QDH->(DbSeek(xFilial("QDH")+cCodDocto))  
	cStrTrab := QDH->QDH_STATUS
	cUltRev	 := QDH->QDH_RV
	If cStrTrab != "L  " .Or. (cStrTrab == "L  " .And. QDH->QDH_CANCEL = 'S')
		Help( " ", 1, "QDA090DRVA" ) //"Ja existe uma revisao Pendente para este Documento.Não será possivel a Importação.
		Return .f.
	EndIf
	IF cUltRev > cRevisao                
		Help( " ", 1, "QD050DOCEX" )  //"Documento ja existe, para Gerar Revisao escolha a opcao no Menu"
		Return .f.
	Endif
EndIf
QDH->(DbSetOrder(1)) 

//Posiciona Arquivos
QAA->(DbSeek(cFilMat+cQAAMat))
QD2->(DbSeek(xFilial("QD2")+cTpCod))

nC := 1
M->QDH_DOCTO := cCodDocto
M->QDH_RV    := cRevisao

If ExistBlock("QDOAP33")
	IF !ExecBlock("QDOAP33",.F.,.F.)
	     Return .f.
	Endif     
Endif

While File( cQPath + cFileCEL )
	cFileCEL := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 ) + SubStr(StrZero(year(dDataBase),4),3,2)+".CEL"
Enddo

ProcessaDoc( { || QD090IpDoc(@lCopiou) } )

If lCopiou
	DbSelectArea("QDH")
	Begin Transaction

		For nI:= 1 To FCount()
			M->&(Eval(bCampo,nI)):= FieldGet(nI)
			lInit := .F.
			If ExistIni(Eval(bCampo,nI))
				lInit := .T.
				M->&(Eval(bCampo,nI)):= InitPad(GetSx3Cache(Eval(bCampo,nI),"X3_RELACAO"))
				If ValType(M->&(Eval(bCampo,nI))) == "C"
					M->&(Eval(bCampo,nI)):= Padr(M->&(Eval(bCampo,nI)),GetSx3Cache(Eval(bCampo,nI),"X3_TAMANHO"))
				EndIf
				If M->&(Eval(bCampo,nI)) == NIL
					lInit := .F.
				EndIf
			EndIf
			If !lInit
				If ValType(M->&(Eval(bCampo,nI))) == "C"
					M->&(Eval(bCampo,nI)):= Space(Len(M->&(Eval(bCampo,nI))))
				ElseIf ValType(M->&(Eval(bCampo,nI))) == "N"
					M->&(Eval(bCampo,nI)):= 0
				ElseIf ValType(M->&(Eval(bCampo,nI))) == "D"
					M->&(Eval(bCampo,nI)):= Ctod("  /  /  ", "DDMMYY")
				ElseIf ValType(M->&(Eval(bCampo,nI))) == "L"
					M->&(Eval(bCampo,nI)):= .F.
				EndIf
			EndIf
   		Next nI

	If RecLock("QDH",.T.)
		
		For nI := 1 TO FCount()
			FieldPut( nI, M->&( Eval( bCampo, nI ) ) )
		Next nI
		
		QDH->QDH_FILIAL := xFilial("QDH")
		QDH->QDH_DOCTO  := cCodDocto
		QDH->QDH_RV     := cRevisao
		QDH->QDH_REVINV := INVERTE(cRevisao) //Revisao Invertida
		QDH->QDH_TITULO := cTitulo
		QDH->QDH_CODTP  := QD2->QD2_CODTP
		QDH->QDH_FILDEP := QD2->QD2_FILDEP
		QDH->QDH_DEPTOD := QD2->QD2_DEPTO
		QDH->QDH_DTCAD  := dDatabase
		QDH->QDH_OBSOL  := "N"
		QDH->QDH_CANCEL := "N"
		QDH->QDH_STATUS := "D"
		QDH->QDH_FILMAT := QAA->QAA_FILIAL
		QDH->QDH_MAT    := QAA->QAA_MAT
		QDH->QDH_DEPTOE := QAA->QAA_CC
		QDH->QDH_HORCAD := Left(Time(),5)
		QDH->QDH_NOMDOC := cFileCEL
		QDH->QDH_DTOIE  :="I"
		QDH->( MsUnlock() )
		For nC := 1 To QDH->( FCount() )
			cCampo      := Upper( AllTrim( QDH->( FieldName( nC ) ) ) )
			M->&cCampo. := QDH->( FieldGet( FieldPos( cCampo ) ) )
		Next
	Endif

	//INCLUSÃO DOS RESPONSÁVEIS DO TIPO DO DOCUMENTO - INICIO
	Private aHedDoc := {}
	Private aQD0Doc := {}
	Private lAltDoc := .T.
	QDO050CARR(3, .F.)
	QD050GRFL({"QD0"}, 3)//Incluir
	//INCLUSÃO DOS RESPONSÁVEIS DO TIPO DO DOCUMENTO - FIM
	
	QD050GrDst(.f.,QAA->QAA_FILIAL,QAA->QAA_CC,QAA->QAA_MAT,,QAA->QAA_TPRCBT,1,,3 )
	
	QD110GrLog(.T.,OemtoAnsi(STR0010),"U",1, cMatFil,cMatCod,QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_TPRCBT) //"Importa‡„o de documento"

	End Transaction
	
	MsgInfo( OemToAnsi(STR0005), OemToAnsi(STR0002) ) // "Importa‡„o finalizada com sucesso." ### "Aviso"
	
	If ExistBlock("QDOAVMAIL")                                    
		ExecBlock("QDOAVMAIL",.F.,.F.)
	Endif
	cRevisao := "000"
	cArquivo := Space( TamSx3("QDH_NOMDOC")[1] )
	cCodDocto:= Space( TamSx3("QDH_DOCTO")[1] )
	cTitulo  := Space( TamSx3("QDH_TITULO")[1] )
	cQAAMat  := Space( TamSX3("QAA_MAT")[1] )
	cTpCod   := Space( TamSX3("QD2_CODTP")[1] )
	cQAANom  := Space( TamSX3("QAA_NOME")[1] )
	cTpDes   := Space( TamSX3("QD2_DESCTP")[1] )
EndIf

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD090IpDoc³ Autor ³Newton Rogerio Ghiraldelli³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Faz a importacao do documento atraves de OLE                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD090IpDoc(ExpL1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 - Verfica se copiou do Terminal para o Servidor          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA090()                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD090IpDoc(lCopiou)

Local cFileTrm := ""
Local aQPath    := QDOPATH()
Local cQPath    := aQPath[1]
Local cQPathTrm := aQPath[3]
Local oWord
Local cMvSalvaDoc := GETMV("MV_QSAVEDC",.F.,1) // 1-Padrao Salva como DOC
Local cMvSave   := IIf( GetMV("MV_QSAVPSW",.F.,"1") == "1","CELEWIN400","" ) // "Verifica se insere senha ou nao
Local nTrm		:= 1 
Local lExist700	   := ExistBlock( "QDOM700" )

Private cEdit   := Alltrim( GetMV( "MV_QDTIPED" ) )
Private cEditor := "TMsOleWord97" //ultima versão

RegProcDoc( 04 )

If lExist700
	ExecBlock( "QDOM700", .f., .f., { cEdit, cEditor } )
EndIf

cFileTrm := ""
For nTrm:= Len(cArquivo) to 1 STEP -1
	If SubStr(cArquivo,nTrm,1) == "\"
		Exit
	Endif
	cFileTrm := SubStr(cArquivo,nTrm,1)+cFileTrm
Next
If At(":",cArquivo) == 0
	CpyS2T(cArquivo,cQPathTrm,.T.)
Else
	__CopyFile(cArquivo,cQPathTrm+cFileTrm)
Endif
If File(cQPathTrm+cFileTrm)
	IncProcDoc( STR0017 ) // "Criando link de comunica‡„o com o editor"
	oWord:=OLE_CreateLink( cEditor )
	IncProcDoc( STR0014 ) // "Abrindo documento a ser importado"
	OLE_OpenFile( oWord, cQPathTrm+cFileTrm, .f., cMvSave, cMvSave )
	IncProcDoc( STR0013 ) // "Salvando no formato Quality"
	If cMvSalvaDoc == 1
		OLE_SaveAsFile( oWord, ( cQPathTrm + cFileCel ), cMvSave, cMvSave, .f., oleWdFormatDocument )
	Else
		OLE_SaveAsFile( oWord, ( cQPathTrm + cFileCel ), cMvSave, cMvSave, .f., oleWdFormatRTF )
	Endif
	OLE_SetProperty( oWord, oleWdPrintBack, .f. )
	OLE_Closefile( oWord )
	IncProcDoc( STR0011 ) // "Fechando links de comunica‡„o"
	OLE_CloseLink( oWord )
	
	If CpyT2S(cQPathTrm+cFileCel,cQPath,.T.)
		lCopiou:= .T.
	Else
		lCopiou:= .F.
	EndIf			

	If File(cQPathTrm+cFileCel)
		FErase(cQPathTrm+cFileCel)
	Endif
	If File(cQPathTrm+cFileTrm)
		FErase(cQPathTrm+cFileTrm)
	Endif
Endif

Return nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD090ValQD2³ Autor ³Eduardo de Souza         ³ Data ³ 11/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica Tipo de Documento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD090ValQD2()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA090()                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD090ValQD2(oTpDes)

Local lRet:= .t.

If !Empty(cTpCod)
	cTpDes:= QDXFNANTPD(cTpcod)
	If Empty(cTpDes)
		Help(" ",1,"QD050TDNE") // Tipo de Documento nao existe
		lRet:= .f.
	Else
		oTpDes:Refresh()
	EndIf
Else
	cTpDes:= " "
	oTpDes:Refresh()
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD090ValQAA³ Autor ³Eduardo de Souza         ³ Data ³ 11/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica Funcionario                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD090ValQAA()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA090()                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD090ValQAA(oQAANom,cFilMat)

Local lRet:= .t.

If !Empty(cQAAMat)
	cQAANom:= QA_NUSR(cFilMat,cQAAMat)
	If Empty(cQAANom)
		Help(" ",1,"QD050FNE") // Funcionario nao Existe
		lRet:= .f.
	Else
		oQAANom:Refresh()
	EndIf
Else
	cQAANom:= " "
	oQAANom:Refresh()
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD090VAL  ³ Autor ³Cicero Cruz              ³ Data ³ 19/02/08 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o codigo do docuemnto esta  na  memória           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA090()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD090VAL(cCodDocto, cRevisao, oRevisao)	
// Iif(!FreeForUse("DOC",xFilial("QDH")+cCodDocto),.F.,.T.)
Local lRet:= .T.
Local lTemLetra := .F.
Local nX := 0
Local cRev := AllTrim(cRevisao)

If !Empty(cRev) 
    nX := 1
	While nX <= Len(cRev)
		If !IsDigit(Substr(cRev,nX,1))
			lTemLetra := .T.
			Exit
		EndIf
		nX ++			
	EndDo
	If !lTemLetra
		cRevisao := STRZERO(Val(cRev),TamSX3("QDH_RV")[1],0)
		oRevisao:Refresh()                                      
	EndIf
	If !FreeForUse("DOC",xFilial("QDH")+cCodDocto+cRevisao)
		lRet := .F.
	EndIf

	If lRet
		lRet := QDXVLREV(cRevisao)
	EndIf
EndIf

Return lRet
