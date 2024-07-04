#INCLUDE "PROTHEUS.CH"
#INCLUDE "QDOA170.CH"
#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QDOA170   ³ Autor ³ Eduardo de Souza        ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ SigaQdo Viewer                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QDOA170()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQDO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³ Programador ³Alteracao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina := {{ OemToAnsi(STR0002),"QD170Pesq" ,0 ,1},;      // "Pesquisar"
	              { OemToAnsi(STR0003),"QD170Visu" ,0 ,2},;      // "Visualizar"
                  { OemToAnsi(STR0004),"QD170Baixa",0 ,7},;      // "Baixar"
                  { OemToAnsi(STR0005),"QD170Legen",0 ,7,,.F.},; // "Legenda"
                  { OemToAnsi(STR0017),"QD170Filtr",0 ,7}}       // "Filtro"

If ExistBlock("QDO170BROW")
	ExecBlock("QDO170BROW", .F., .F.)	
Endif

Return aRotina

Function QDOA170()

Local aUsrMat := QA_USUARIO()

Private aRotina      := MenuDef()
Private cCadastro    := OemToAnsi(STR0001) //"Controle de Documentos - Viewer"
Private cMatCod      := aUsrMat[3]
Private cMatDep      := aUsrMat[4]
Private cMatFil      := aUsrMat[2]
Private cRetFil      := ""
Private Inclui       := .F.
Private lChk         := .F.
Private lPendBai     := .F.
Private lSolicitacao := .F.
Private lTrat        := GetMv("MV_QDOQDG",.T.,.F.)
Private nOrd         := 1
Private nOrdPesq     := 1
Private oBrowse      := Nil
Private oTempTable   := .F.

SetKey(VK_F12,{|| QD170Filtr()})

If ExistBlock("QDO170Fil")
    cRetFil := ExecBlock("QDO170Fil", .F., .F.)
    If ValType(cRetFil) == 'C'
        QD170CTRB()
    EndIf
EndIf

LjMsgRun(OemToAnsi(STR0010),OemToAnsi(STR0011),{|| QD170MBrow() }) // "Selecionando Documentos" ### "Aguarde..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o arquivo Temporario     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable:Delete()

DbSelectArea("QD1")
QD1->(DbSetOrder(1))
Set Filter To

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD170MBrow³ Autor ³ Eduardo de Souza      ³ Data ³ 02/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria Browser                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD170MBrow()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD170MBrow()
Local aFields := {}
Local aIndex  := {}
Local aSeek   := {}

QD170CTRB()

Aadd(aFields,{OemToAnsi(STR0013),"TRB_DOCTO" ,TamSx3("QDH_DOCTO")[3] ,TamSx3("QDH_DOCTO")[1] ,TamSx3("QDH_DOCTO")[2] ,"@!"}) // "Documento"
Aadd(aFields,{OemToAnsi(STR0014),"TRB_RV"    ,TamSx3("QDH_RV")[3]    ,TamSx3("QDH_RV")[1]    ,TamSx3("QDH_RV")[2]    ,"@!"}) // "Revisao"
Aadd(aFields,{OemToAnsi(STR0015),"TRB_TITULO",TamSx3("QDH_TITULO")[3],TamSx3("QDH_TITULO")[1],TamSx3("QDH_TITULO")[2],"@!"}) // "Titulo"
Aadd(aFields,{OemToAnsi(STR0016),"TRB_CODTP" ,TamSx3("QDH_CODTP")[3] ,TamSx3("QDH_CODTP")[1] ,TamSx3("QDH_CODTP")[2] ,"@!"}) // "Tipo Docto"

DbSelectArea("QDH")
QDH->(DbSetOrder(1))

DbSelectArea("TRB")
TRB->(dbGoTop())

Aadd( aSeek, { STR0013+" + "+STR0014				, { {"","C",16,0,STR0013,,},{"","C",03,0,STR0014,,     					 }},1 } )
Aadd( aSeek, { STR0012+" + "+STR0013+" + "+STR0014	, { {"","C",01,0,STR0012,,},{"","C",16,0,STR0013,,},{"","C",03,0,STR0014,,}},2 } )
Aadd( aSeek, { STR0018								, { {"","C",06,0,STR0016,,   	   		            						 }},3 } )

Aadd( aIndex, "TRB_DOCTO+TRB_RV" )
Aadd( aIndex, "TRB_PENDEN+TRB_DOCTO+TRB_RV" )
Aadd( aIndex, "TRB_CODTP" )

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("TRB")
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetTemporary(.T.)
oBrowse:SetSeek(,aSeek)
oBrowse:SetFields(aFields)
oBrowse:SetDescription(cCadastro)
oBrowse:SetUseFilter(.F.)

oBrowse:AddLegend( "TRB_PENDEN =='B'", "GREEN", STR0006 ) // "Leitura Baixada"
oBrowse:AddLegend( "TRB_PENDEN =='P'", "RED",   STR0007 ) // "Leitura Pendente"

oBrowse:SetFilterDefault("Alltrim(TRB_CODTP) <> ' '")
oBrowse:aFilterDefault := {} // Remove os filtros padroes criados com base nas legendas

oBrowse:Activate()


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD170CTRB ³ Autor ³ Eduardo de Souza      ³ Data ³ 02/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria a estrutura temporaria do arquivo de trabalho         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD170CTRB()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD170CTRB(cFilAdc)
Local aCampos := {}
Local aTam    := {}
Local cQuery  := ""

Default cFilAdc := ""

If Select('TRB') > 0 
	TRB->(dbCloseArea())
Endif

aTam:= TamSX3("QDH_FILIAL")
Aadd(aCampos,{"TRB_FILIAL","C",aTam[1],aTam[2]})

aTam:= TamSX3("QDH_DOCTO")
Aadd(aCampos,{"TRB_DOCTO","C",aTam[1],aTam[2]})

aTam:= TamSX3("QDH_RV")
Aadd(aCampos,{"TRB_RV","C",aTam[1],aTam[2]})

aTam:= TamSX3("QDH_TITULO")
Aadd(aCampos,{"TRB_TITULO","C",aTam[1],aTam[2]})

aTam:= TamSX3("QDH_CODTP")
Aadd(aCampos,{"TRB_CODTP","C",aTam[1],aTam[2]})

aTam:= TamSX3("QD1_PENDEN")
Aadd(aCampos,{"TRB_PENDEN","C",aTam[1],aTam[2]})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_DOCTO","TRB_RV"} )
oTempTable:AddIndex("indice2", {"TRB_PENDEN","TRB_DOCTO","TRB_RV"} )
oTempTable:AddIndex("indice3", {"TRB_CODTP"} )
oTempTable:Create()

DbSetOrder(1)
DbGotop()

cQuery := "SELECT QDH.QDH_FILIAL,QDH.QDH_DOCTO,QDH.QDH_RV,QDH.QDH_TITULO,QDH.QDH_CODTP,QD1.QD1_PENDEN"
cQuery += "  FROM " + RetSqlName("QD1")+" QD1, "
cQuery +=         RetSqlName("QDH") + " QDH "
cQuery += " WHERE QD1.QD1_FILMAT = '"  +cMatFil+"' "
cQuery += "   AND QD1.QD1_MAT = '"     +cMatCod+"' "
cQuery += "   AND QD1.QD1_TPPEND = 'L  ' AND QD1.QD1_SIT <> 'I' "
cQuery += "   AND ( QD1.QD1_TPDIST = '1' OR QD1.QD1_TPDIST = '3' ) "
cQuery += "   AND QD1.D_E_L_E_T_ <> '*' " 
cQuery += "   AND ((QDH.QDH_OBSOL <> 'S' AND QDH.QDH_DTVIG <= '"+Dtos(dDataBase)+"' AND QDH.QDH_FUTURA <> 'G') OR (QDH.QDH_OBSOL = 'S' AND QDH.QDH_DTLIM >= '"+Dtos(dDataBase)+"')) "
cQuery += "   AND (QDH.QDH_CANCEL <> 'S' OR (QDH.QDH_CANCEL = 'S' AND QDH.QDH_STATUS <> 'L  ')) "
cQuery += "   AND QDH.QDH_STATUS = 'L  ' "
cQuery += "   AND QDH.QDH_FILIAL = QD1.QD1_FILIAL "
cQuery += "   AND QDH.QDH_DOCTO = QD1.QD1_DOCTO "
cQuery += "   AND QDH.QDH_RV = QD1.QD1_RV "
cQuery += "   AND QDH.D_E_L_E_T_ <> '*' "

If !Empty(cFilAdc)
	cQuery += "AND "+cFilAdc
Endif

If !Empty(cRetFil)
	cQuery += "AND "+cRetFil
Endif

cQuery += " ORDER BY " + SqlOrder("QD1_PENDEN+QDH_DOCTO+QDH_RV")
		
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QDH_TRB', .F., .T.)

DbSelectArea("QDH_TRB")
DbGotop()
While ("QDH_TRB")->(!Eof())
	RecLock("TRB",.T.)
	TRB->TRB_FILIAL := ("QDH_TRB")->QDH_FILIAL
	TRB->TRB_DOCTO  := ("QDH_TRB")->QDH_DOCTO
	TRB->TRB_RV     := ("QDH_TRB")->QDH_RV
	TRB->TRB_TITULO := ("QDH_TRB")->QDH_TITULO
	TRB->TRB_CODTP  := ("QDH_TRB")->QDH_CODTP
	TRB->TRB_PENDEN := ("QDH_TRB")->QD1_PENDEN
	TRB->(MsUnLock())
	QDH_TRB->(DbSkip())
EndDo
QDH_TRB->(dbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD170Pesq ³ Autor ³ Eduardo de Souza      ³ Data ³ 03/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa no arquivo temporario                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD170Pesq()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD170Pesq()
Local aOrd   := { OemToAnsi(STR0013)+" + "+OemToAnsi(STR0014),;// "Documento" ### Revisao"
				  OemToAnsi(STR0012)+" + "+OemToAnsi(STR0013)+" + "+OemToAnsi(STR0014),; // "Status da Pendencia" ### "Documento" ### "Revisao"
				  OemToAnsi(STR0018)}  // "Tipo de Documento"
Local cOrd   := " "
Local cTexto := Space(20)
Local nOpcao := 0
Local oBtn1  := NIL
Local oBtn2  := NIL
Local oDlg   := NIL
Local oOrd   := NIL

DEFINE MSDIALOG oDlg FROM 000,000 TO 100,490 PIXEL TITLE OemToAnsi(STR0002) // "Pesquisar"

@ 005,005 COMBOBOX oOrd VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg ON CHANGE (nOrdPesq:= oOrd:nAt)

@ 022,005 MSGET cTexto SIZE 206,010 OF oDlg PIXEL

DEFINE SBUTTON oBtn1 FROM 005,215 TYPE 1 PIXEL ENABLE OF oDlg ACTION ( nOpcao:=1,oDlg:End() )

DEFINE SBUTTON oBtn2 FROM 020,215 TYPE 2 PIXEL ENABLE OF oDlg ACTION oDlg:End()

oOrd:nAt:= nOrdPesq

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1
	If TRB->(IndexOrd()) <> nOrdPesq
		TRB->(DbSetOrder(nOrdPesq))
	EndIf
	If !Empty(AllTrim(cTexto))
		TRB->(DbSeek(RTrim(cTexto)))
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD170Visu  ³ Autor ³ Eduardo de Souza   ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualizacao de Docto e Cadastro na opcao detalhes        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD170Visu()                 				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA170                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD170Visu()

If QDH->(MSSEEK(TRB->TRB_FILIAL+TRB->TRB_DOCTO+TRB->TRB_RV))
	QD050Telas("QDH",QDH->(Recno()),2)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD170Baixa³ Autor ³ Eduardo de Souza        ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Baixa Pendencia de Leitura                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD170Baixa()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA170                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD170Baixa()

If TRB->TRB_PENDEN == "P"
	If QDH->(MSSEEK(TRB->TRB_FILIAL+TRB->TRB_DOCTO+TRB->TRB_RV))
		lPendBai:= .T.
		If QD050Telas( "QDH",QDH->(Recno()),2,lPendBai) == 1
			RecLock("TRB",.F.)
			TRB->TRB_PENDEN:= "B"
			MsUnlock()
		EndIf		
		lPendBai:= .F.
	EndIf
Else
	Help(" ",1,"QDOJABX") // "Documento ja baixado anteriormente"
	Return .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD170Filtr ³ Autor ³ Eduardo de Souza   ³ Data ³ 04/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Filtra Lancamentos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD170Filtr()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA170                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD170Filtr()
Local cFilAux := TRB->(DbFilter())
Local cFiltro := ""
Local lChkAux := lChk
Local lRet	  := .F.
Local nOrdAux := nOrd

DbSelectArea("TRB")

If ValType(oBrowse) != "U"
	lRet := Pergunte("QDOA170",.T.)
EndIF

If lRet
	If !Empty(mv_par01)
		cFiltro += " QDH.QDH_DOCTO >= '"+mv_par01+"' "
	Endif

	If !Empty(mv_par02)
		If !Empty(cFiltro)
			cFiltro += " AND "
		EndIf

		cFiltro += " QDH.QDH_DOCTO <= '"+mv_par02+"' "
	Endif

	If !Empty(mv_par03)
		If !Empty(cFiltro)
			cFiltro += " AND "
		EndIf

		cFiltro += " QDH.QDH_RV >= '"+mv_par03+"' "
	Endif

	If !Empty(mv_par04)
		If !Empty(cFiltro)
			cFiltro += " AND "
		EndIf

		cFiltro += " QDH.QDH_RV <= '"+mv_par04+"' "
	Endif

	If !Empty(mv_par05)
		If !Empty(cFiltro)
			cFiltro += " AND "
		EndIf

		cFiltro+= " QDH.QDH_CODTP = '"+mv_par05+"'"
	EndIf

	If mv_par06 == 1
		If !Empty(cFiltro)
			cFiltro += " AND "
		EndIf
		cFiltro += " QD1.QD1_PENDEN = 'P'"
	EndIf

	QD170CTRB(cFiltro)
	TRB->(DbGotop())

	If Type("oBrowse") <> "U"
		oBrowse:Refresh()
	EndIF

	If TRB->(Eof()) .And. TRB->(Bof())
		Help(" ",1,"QD170NFILT") // "Nao existem dados para o filtro selecionado."
		lChk:= lChkAux
		nOrd:= nOrdAux
		oBrowse:SetFilterDefault(cFilAux)
		QD170CTRB()
		TRB->(DbGotop())		
	EndIf
EndIF

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD170Legen ³ Autor ³ Eduardo de Souza   ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Legenda do Browser                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD170Legen()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA170                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD170Legen()

Local aLegenda := {{"ENABLE" , OemtoAnsi(STR0006)},;// "Leitura Baixa"
				   {"DISABLE", OemtoAnsi(STR0007)}}	// "Leitura Pendente"

BrwLegenda(cCadastro,OemToAnsi(STR0005),aLegenda) // "Legenda"

Return
