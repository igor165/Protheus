#INCLUDE "QDOR043.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOR043   ºAutor  ³Leandro Sabino      º Data ³  03/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Relatorio de Lista de Documentos                 º±±
±±º          ³ (Versao Relatorio Personalizavel)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QDOR043()
Local oReport

If TRepInUse()
	Pergunte("QDR042",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QDOR043R3()	// Executa versão anterior do fonte
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 03/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR043                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cTitulo:= OemToAnsi(STR0001) // "LISTA DE DOCUMENTO X DEPARTAMENTOS"
Local cDesc1 := OemToAnsi(STR0002) // "Este programa ir  imprimir uma rela‡„o dos documentos, com "
Local cDesc2 := OemToAnsi(STR0003) // "a quantidade de copias distribuidas com os respectitivos"
Local cDesc3 := OemToAnsi(STR0004) // "departamentos recebedores."
Local aUsrMat  	:= QA_USUARIO()
Local cMatDep  	:= aUsrMat[4]
Local cMatFil  	:= aUsrMat[2]
Local cFilFunc 	:= xFilial("QAC")
Local cAliasQry := "QD8"
Local oSection1 

DEFINE REPORT oReport NAME "QDOR043" TITLE cTitulo PARAMETER "QDR042" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2+cDesc3)

DEFINE SECTION oSection1 OF oReport TABLES "QDH" TITLE OemToAnsi(STR0012)
DEFINE CELL NAME "QDH_DOCTO"  OF oSection1 ALIAS "QDH" SIZE 18 
DEFINE CELL NAME "QDH_RV"     OF oSection1 ALIAS "QDH" 
DEFINE CELL NAME "QDH_TITULO" OF oSection1 ALIAS "QDH" SIZE 88 PICTURE "" LINE BREAK
DEFINE CELL NAME "cNCopia"    OF oSection1 ALIAS "  " TITLE OemToAnsi(STR0010)  SIZE 04 //"Copias"
DEFINE CELL NAME "cDepto"     OF oSection1 ALIAS "  " TITLE OemToAnsi(STR0011)  SIZE 48 //"Departamento"
DEFINE CELL NAME "nCopDepto"  OF oSection1 ALIAS "  " TITLE OemToAnsi(STR0013) SIZE 16 //"Copias/Depto"

Return oReport
                             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 03/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR043                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport) 
Local oSection1 := oReport:Section(1)
Local cFiltro   := ""
Local nCopia  	:= 0
Local nI      	:= 0
Local nP      	:= 0
Local lList   	:= .T.
Local aDeptos 	:= {}
Local nCopDepto  
Local nUlt      := 1

DbSelectArea("QDH")
DbSetOrder(1)

DbSelectArea("QDG")
DbSetOrder(1)

DbSelectArea("QAD")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Imprime Documento Interno/Externo/Ambos  						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01	== 2
	cFiltro:= 'QDH_DTOIE == "I" .AND.'
Elseif mv_par01 == 3
	cFiltro:= 'QDH_DTOIE == "E" .AND.'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Impressao de Doc. sera Vigente/Obsoleto/Cancelado/Todos-Cancelado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par02	== 1   // Vigente
	cFiltro+='QDH_CANCEL<>"S".And. QDH_OBSOL<>"S".And.QDH_STATUS = "L  "'
Elseif mv_par02 == 2   // Obsoleto
	cFiltro+='QDH_CANCEL <> "S" .And. QDH_OBSOL == "S"'
Elseif mv_par02 == 3   // Cancelado
	cFiltro+='QDH_CANCEL == "S"'
ElseIf mv_par02 == 4   // Todas Revisoes
	cFiltro+='QDH_CANCEL <> "S"'
EndIf

oSection1:SetFilter(cFiltro)

QDH->(dbGoTop())

oSection1:Init()

While !oReport:Cancel() .And. QDH->(!Eof()) .And. QDH->QDH_FILIAL == xFilial( "QDH" )

	lList  :=.T.
	cDepto := " "
	nCopia := 0

	If QDG->(DbSeek(xFilial("QDG")+QDH->QDH_DOCTO+QDH->QDH_RV))
		aDeptos := {}          
		nCopDepto := 0
 	    nUlt      := 1
		
		While QDG->(!Eof()) .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == xFilial("QDG")+QDH->QDH_DOCTO+QDH->QDH_RV
			If QDG->QDG_SIT <> "I" .And. QDG->QDG_TPRCBT <> "4"
				nCopia := nCopia + QDG->QDG_NCOP
				nCopDepto := QDG->QDG_NCOP
			Endif
			If( nP := Ascan( aDeptos, {|x| x[1] == QDG->QDG_DEPTO} ) ) == 0
				If Empty(AllTrim(xFilial("QAD")))
					QAD->(DbSeek(xFilial("QAD")+QDG->QDG_DEPTO))
				Else
					QAD->(DbSeek(QDG->QDG_FILMAT+QDG->QDG_DEPTO))
				EndIf
				Aadd( aDeptos, { QDG->QDG_DEPTO,QAD->QAD_DESC,StrZero(nCopDepto,4)})				
				nUlt := len(aDeptos)
			Else
				nUlt := Ascan( aDeptos, {|x| x[1] == QDG->QDG_DEPTO} )
				
				aDeptos[nUlt,3]:= If(Val(aDeptos[nUlt,3]) > 0, StrZero(Val(aDeptos[nUlt,3])+nCopDepto,4) ,StrZero(nCopDepto,4))				
			Endif
			cDoc := QDG->QDG_DOCTO
			QDG->(DbSkip())
			If aDeptos[nUlt,1] <> QDG->QDG_DEPTO .or. cDoc <> QDG->QDG_DOCTO
				nCopDepto := 0	
			Endif
		EndDo
	Endif
   
    oSection1:Cell("cNCopia"):SetValue(StrZero(nCopia,4))

	If Len( aDeptos ) > 0
		For nI:= 1 to Len( aDeptos ) 
			If nI=1 
				oSection1:Cell("cNCopia"):Show()
				oSection1:Cell("QDH_DOCTO"):Show()
				oSection1:Cell("QDH_RV"):Show()
				oSection1:Cell("QDH_TITULO"):Show()
			Else
				oSection1:Cell("cNCopia"):Hide()
				oSection1:Cell("QDH_DOCTO"):Hide()
				oSection1:Cell("QDH_RV"):Hide()
				oSection1:Cell("QDH_TITULO"):Hide()
			Endif
			oSection1:Cell("cDepto"):SetValue(aDeptos[nI,1]+" - "+aDeptos[nI,2])							
			oSection1:Cell("nCopDepto"):SetValue(aDeptos[nI,3])
			oSection1:PrintLine()
		Next nI
	Else
		oSection1:Cell("cDepto"):Hide()
		oSection1:PrintLine()
	EndIf
	oReport:SkipLine(1) 
	oReport:ThinLine()
	
   	QDH->(DbSkip())

EndDo

oSection1:Finish()

Return NIL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QDOR043R3  ³ Autor ³Newton Rogerio Ghiraldelli³ Data ³ 27/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Relatorio de Lista de Documentos X Depto                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QDOR043()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Siga Quality ( Controle de Documentos )                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data   ³ BOPS ³ Programador ³Alteracao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³19/02/02 ³ META ³ Eduardo S.  ³ Melhoria e Otimizacao no Programa.         ³±±
±±³28/03/02 ³ META ³ Eduardo S.  ³ Acerto na posicao dos Departamentos.       ³±±
±±³27/08/02 ³059536³ Eduardo S.  ³ Acertado para listar corretamento o numero ³±±
±±³         ³      ³             ³ de copias distribuidas.                    ³±±
±±³04/10/02 ³060400³ Eduardo S.  ³ Alterado para prever depto com 20 posicoes ³±±
±±³11/02/03 ³062580³ Eduardo S.  ³ Acerto para filtrar corretamente os doctos ³±±
±±³         ³      ³             ³ quando utilizada a opcao filtro padrao.	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOR043R3()

Local cTitulo:= OemToAnsi(STR0001) // "LISTA DE DOCUMENTO X DEPARTAMENTOS"
Local cDesc1 := OemToAnsi(STR0002) // "Este programa ir  imprimir uma rela‡„o dos documentos, com "
Local cDesc2 := OemToAnsi(STR0003) // "a quantidade de copias distribuidas com os respectitivos"
Local cDesc3 := OemToAnsi(STR0004) // "departamentos recebedores."
Local cString:= "QDH"
Local wnrel  := "QDOR043"
Local Tamanho:= "G"

Private cPerg   := "QDR042"
Private aReturn := {OemToAnsi(STR0005),1,OemToAnsi(STR0006),1,2,1,"",1} //"Zebrado" ### "Administra‡„o"
Private nLastKey:= 0
Private Inclui  := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                               ³
//³ mv_par01	// Documento (Ambos/Interno/Externo)                    ³
//³ mv_par02	// Impr. Documento (Vigente/Cancelado/Obsoleto/Ambos)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.f.)

wnrel :=SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd|QDOR043Imp(@lEnd,cTitulo,wnRel,Tamanho)},cTitulo)

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QDOR043Imp³ Autor ³Newton Rogerio Ghiraldelli³ Data ³ 27/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Imprime o Relatorio de Lista de Documentos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOR043Imp(ExpL1,ExpC1,ExpC2,ExpC3)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOR043                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDOR043Imp(lEnd,cTitulo,wnRel,Tamanho)

Local cCabec1 := ""
Local cCabec2 := ""
Local cDepto  := ""
Local cbtxt   := Space(10)
Local cCopia  := Space(4)
Local nTipo   := GetMV( "MV_COMP" )
Local cbcont  := 0
Local nCopia  := 0
Local nI      := 0
Local nP      := 0
Local lList   := .t.
Local aDeptos := {}
Local cFiltro := ""
Local cIndex1 := CriaTrab(Nil,.F.)
Local nCopDepto  
Local nUlt      := 1

Private Limite := 132

cCabec1:= OemToAnsi(STR0008)// "DOCUMENTO         REV  TITULO                                                     COPIAS DEPARTAMENTOS                                    COPIAS/DEPTO"
cCabec2:= " "

li     := 80
m_pag  := 1

QDH->(DbSetOrder(1))
QDG->(DbSetOrder(1)) 
QAD->(DbSetOrder(1)) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Imprime Documento Interno/Externo/Ambos  						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01	== 2
	cFiltro:= 'QDH_DTOIE == "I" .AND.'
Elseif mv_par01 == 3
	cFiltro:= 'QDH_DTOIE == "E" .AND.'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Impressao de Doc. sera Vigente/Obsoleto/Cancelado/Todos-Cancelado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par02	== 1   // Vigente
	cFiltro+='QDH_CANCEL<>"S".And. QDH_OBSOL<>"S".And.QDH_STATUS = "L  "'
Elseif mv_par02 == 2   // Obsoleto
	cFiltro+='QDH_CANCEL <> "S" .And. QDH_OBSOL == "S"'
Elseif mv_par02 == 3   // Cancelado
	cFiltro+='QDH_CANCEL == "S"'
ElseIf mv_par02 == 4   // Todas Revisoes
	cFiltro+='QDH_CANCEL <> "S"'
EndIf

If ! Empty(aReturn[7])	// Filtro de Usuario
	cFiltro += " .And. (" + aReturn[7] + ")"
Endif

IndRegua("QDH",cIndex1,QDH->(IndexKey()),,cFiltro,STR0009)	//"Selecionando Registros.."

If QDH->(DbSeek(xFilial("QDH")))
	SetRegua(LastRec())	
	While QDH->(!Eof()) .And. QDH->QDH_FILIAL == xFilial("QDH")
		IncRegua()
		lList  :=.t.
		cDepto := " "
		nCopia := 0
		If QDG->(DbSeek(xFilial("QDG")+QDH->QDH_DOCTO+QDH->QDH_RV))
			aDeptos := {}          
			nCopDepto := 0
			nUlt      := 1
			While QDG->(!Eof()) .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == xFilial("QDG")+QDH->QDH_DOCTO+QDH->QDH_RV
				If QDG->QDG_SIT <> "I" .And. QDG->QDG_TPRCBT <> "4"
					nCopia := nCopia + QDG->QDG_NCOP
					nCopDepto := QDG->QDG_NCOP
				Endif
				If( nP := Ascan( aDeptos, {|x| x[1] == QDG->QDG_DEPTO})) == 0
					If Empty(AllTrim(xFilial("QAD")))
						QAD->(DbSeek(xFilial("QAD")+QDG->QDG_DEPTO))
					Else
						QAD->(DbSeek(QDG->QDG_FILMAT+QDG->QDG_DEPTO))
					EndIf
					Aadd( aDeptos, { QDG->QDG_DEPTO,QAD->QAD_DESC,StrZero(nCopDepto,4)})				
					nUlt := len(aDeptos)				
				Else
					nUlt := Ascan( aDeptos, {|x| x[1] == QDG->QDG_DEPTO} )
				
					aDeptos[nUlt,3]:= If(Val(aDeptos[nUlt,3]) > 0, StrZero(Val(aDeptos[nUlt,3])+nCopDepto,4) ,StrZero(nCopDepto,4))							
				Endif
				cDoc := QDG->QDG_DOCTO
				QDG->(DbSkip())
				If aDeptos[nUlt,1] <> QDG->QDG_DEPTO .or. cDoc <> QDG->QDG_DOCTO
					nCopDepto := 0	
				Endif
			EndDo
		Endif
		cCopia := StrZero(nCopia,4)
		If lList
			If lEnd
				Li++
				@ PROW()+1,001 PSAY OemToAnsi(STR0007) //"CANCELADO PELO OPERADOR"
				Exit
			Endif
		EndIf
		If Li > 58
			Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
		EndIf
		@ Li,000 pSay Replicate("-", 150)
		Li ++
		@ Li,000 PSay Substr(Alltrim(QDH->QDH_DOCTO),1,16)
		@ Li,018 PSay Substr(Alltrim(QDH->QDH_RV),1,3)
		@ Li,023 PSay Substr(Alltrim(QDH->QDH_TITULO),1,58)
		@ Li,083 PSay Substr(Alltrim(cCopia),1,4)
		
		If Len( aDeptos ) > 0
			For nI:= 1 to Len( aDeptos ) STEP 2              
				@ Li,089 PSay Substr(Alltrim(aDeptos[nI,1]),1,20) 
				@ Li,105 PSay ("-")  
				@ Li,107 PSay Substr(Alltrim(aDeptos[nI,2]),1,25)
				@ Li,145 PSay Substr(Alltrim(aDeptos[nI,3]),1,4)

				If nI+1 <= Len(aDeptos)
					Li ++
					If Len(AllTrim(QDH->QDH_TITULO)) > 58 .And. nI+1 == 2
						@ Li,023 PSay Substr(Alltrim(QDH->QDH_TITULO),59)
					EndIf
					@ Li,089 PSay Substr(Alltrim(aDeptos[nI+1,1]),1,20)
					@ Li,105 PSay ("-")  
					@ Li,107 PSay Substr(Alltrim(aDeptos[nI+1,2]),1,25)			
					@ Li,145 PSay Substr(Alltrim(aDeptos[nI+1,3]),1,4)
				Endif			
				Li ++
				If Len(AllTrim(QDH->QDH_TITULO)) > 58 .And. Len(aDeptos) ==1
					@ Li,023 PSay Substr(Alltrim(QDH->QDH_TITULO),59)
					Li++
				EndIf
				If Li > 58
					Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
				Endif
			Next nI
		EndIf
		QDH->(DbSkip())
	EndDo

Endif

If Li != 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

Set Device To Screen

RetIndex("QDH")
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indices de trabalho        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

If aReturn[5] = 1
	Set Printer TO
	DbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return .T.
