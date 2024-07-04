#INCLUDE "PROTHEUS.CH"
#INCLUDE "QDOC030.CH"
#INCLUDE "DBTREE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDOC030    ³ Autor ³ Eduardo de Souza   ³ Data ³ 23/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Lancamentos Pendentes                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDOC030()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ SIGAQDO - Controle de Documentos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³Programador³                 Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³02/04/02³ META ³Eduardo S. ³ Alterado devido novo conceito de utilizacao ³±±
±±³        ³      ³           ³ dos arquivos de Usuarios.                   ³±±
±±³21/10/02³ ---- ³Eduardo S. ³ Acerto para prever qualquer tipo pendencia. ³±±
±±³10/02/03³062308³Eduardo S. ³ Alterado para apresentar somente as penden- ³±±
±±³        ³      ³           ³ cias dos documentos da filial corrente.     ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOC030()

Local oDlg
Local oTreeUsr
Local oTreeDoc
Local oBtn1
Local oBtn2
Local nTree:= 1      
Local aARea:= GetArea()

Private aDocs     := {}
Private Inclui    := .F.
Private lEditPTree:= .T.
Private cChaveSeq := "0000"
Private cChaveTree:= ""
Private lTrat		:= GetMv("MV_QDOQDG",.T.,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega Array com Lancamentos Pendentes						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun(OemToAnsi(STR0019),OemToAnsi(STR0018),{|| QD30CarDocs()}) // "Carregando Lancamentos..." ### "Aguarde..."	

	QD1TRB->(DbGOTOP())
	IF QD1TRB->(Eof())
	    QD1TRB->(dbCloseArea()) 
	    QD1PTRB->(dbCloseArea())     
		msgAlert(STR0035)//"Nao existem pendencias!" 
		Return 
	Endif

	DEFINE MSDIALOG oDlg FROM 0,0 TO 425,630 PIXEL TITLE OemToAnsi(STR0001) // "Lancamentos Pendentes"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle para abertura da tela. Caso a Tela fique aberta por mais de 3 minutos ³
	//³ nao perca a conexao.														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PtInternal(9,"FALSE")

	@ 033,003 BUTTON oBtn1 PROMPT OemToAnsi(STR0016) SIZE 045,010 OF oDlg PIXEL ACTION (oTreeUsr:lVisible:=.T.,nTree:= 1,oTreeDoc:lVisible:=.F.) // "Lanc. Usuario"
	@ 033,048 BUTTON oBtn2 PROMPT OemToAnsi(STR0017) SIZE 045,010 OF oDlg PIXEL ACTION (oTreeUsr:lVisible:=.F.,nTree:= 2,oTreeDoc:lVisible:=.T.) // "Lanc. Tipo Pend."
	@ 033,093 BUTTON oBtn3 PROMPT OemToAnsi(STR0030) SIZE 045,010 OF oDlg PIXEL ACTION QDC030Pesq(If(nTree==1,@oTreeUsr,@oTreeDoc),nBtn:=1) // "Pesquisa"
	@ 033,139 BUTTON oBtn4 PROMPT OemToAnsi(STR0031) SIZE 048,010 OF oDlg PIXEL ACTION QDC030Pesq(If(nTree==1,@oTreeUsr,@oTreeDoc),nBtn:=2) // "Continua Pesquisa"

	oTreeUsr := DbTree():New(43, 3, 197, 315, oDlg,,,.T.)
	oTreeDoc := DbTree():New(43, 3, 197, 315, oDlg,,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta Objetos Tree                      						    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   MsgRun(OemToAnsi(STR0019),OemToAnsi(STR0018),{|| QD30MonTree(@oTreeUsr,@oTreeDoc)}) // "Carregando Lancamentos..." ### "Aguarde..."	

	oTreeDoc :lVisible:= .F.
	oTreeUsr :lVisible:= .T.

	DbSelectArea("QD1TRB")
    DbClosearea() 
	DbSelectArea("QD1PTRB")
    DbClosearea()        
    	RestArea(aArea)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ ||oDlg:End() },{ ||oDlg:End() }) CENTERED
	PtInternal(9,"TRUE")
 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD30CarDocs³ Autor ³ Eduardo de Souza    ³ Data ³ 24/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega Documentos no Array                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD30CarDocs()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION QD30CarDocs()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordenado por Usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
cQuery := " SELECT QD1.QD1_FILIAL,QD1.QD1_DOCTO,QD1.QD1_RV,QD1.QD1_TPPEND,QD1.QD1_FILMAT,QD1.QD1_MAT,QD1.QD1_DTGERA,QD1.R_E_C_N_O_,QDH.QDH_TITULO,QAA.QAA_APELID "
cQuery += " FROM " + RetSqlName("QD1")+" QD1 ,"+ RetSqlName("QDH")+" QDH ,"+ RetSqlName("QAA")+" QAA "
cQuery += " WHERE QD1.QD1_FILMAT = QAA.QAA_FILIAL AND QD1.QD1_MAT = QAA.QAA_MAT "
cQuery += " AND "+ QA_FilSitF(.T.,.T.) 
cQuery += " AND QAA.D_E_L_E_T_ <> '*'  "
cQuery += " AND QD1.QD1_PENDEN = 'P' AND QD1.D_E_L_E_T_ <> '*'"
cQuery += " AND QD1.QD1_FILIAL = QDH.QDH_FILIAL AND QD1.QD1_DOCTO = QDH.QDH_DOCTO AND QD1.QD1_RV = QDH.QDH_RV "
cQuery += " AND QDH.D_E_L_E_T_ <> '*' "			
	
If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 5,6,4,1,2,3"
Else
	cQuery += " ORDER BY " + SqlOrder("QD1_FILMAT+QD1_MAT+QD1_TPPEND+QD1_FILIAL+QD1_DOCTO+QD1_RV")
Endif
        cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD1TRB",.T.,.T.)		
TcSetField("QD1TRB","QD1_DTGERA","D",8,0)		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordenado por Tipo de Pendencias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
cQuery := " SELECT QD1.QD1_FILIAL,QD1.QD1_DOCTO,QD1.QD1_RV,QD1.QD1_TPPEND,QD1.QD1_FILMAT,QD1.QD1_MAT,QD1.QD1_DTGERA,QD1.R_E_C_N_O_,QDH.QDH_TITULO,QAA.QAA_APELID "
cQuery += " FROM " + RetSqlName("QD1")+" QD1 ,"+ RetSqlName("QDH")+" QDH,"+RetSqlName("QAA")+" QAA "
cQuery += " WHERE QD1.QD1_FILMAT = QAA.QAA_FILIAL AND QD1.QD1_MAT = QAA.QAA_MAT "
cQuery += " AND "+ QA_FilSitF(.T.,.T.) 
cQuery += " AND QAA.D_E_L_E_T_ <> '*'  "
cQuery += " AND QD1.QD1_PENDEN = 'P' AND QD1.D_E_L_E_T_ <> '*'"
cQuery += " AND QD1.QD1_FILIAL = QDH.QDH_FILIAL AND QD1.QD1_DOCTO = QDH.QDH_DOCTO AND QD1.QD1_RV = QDH.QDH_RV "
cQuery += " AND QDH.D_E_L_E_T_ <> '*' "			
	
If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 4,1,2,3,5,6"
Else
	cQuery += " ORDER BY " + SqlOrder("QD1_TPPEND+QD1_FILIAL+QD1_DOCTO+QD1_RV+QD1.QD1_FILMAT+QD1.QD1_MAT")
Endif
        cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD1PTRB",.T.,.T.)		
TcSetField("QD1PTRB","QD1_DTGERA","D",8,0)		              
    
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD30MonTree³ Autor ³ Eduardo de Souza ³ Data ³ 24/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Monta objeto Tree                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD30MonTree(ExpO1,ExpO2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpO1 - Objeto Tree Usuarios                            ³±±
±±³             ³ ExpO2 - Objeto Tree Tipo de Pendencia                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOC030                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD30MonTree(oTreeUsr,oTreeDoc)

Local oMenu
Local oMenu1
Local nSeqTree 	:= 0
Local cOldTpPen	:= " "
Local nCnt     	:= 0
Local cFilMat  	:= ""
Local cMatQAA  	:= ""
Local cDocto   	:= ""
Local cRv      	:= ""
Local cSx3Tit	:= RetTitle("QDH_TITULO")

DBSELECTAREA("QD1TRB")
QD1TRB->(DbGotop())
While !QD1TRB->(EOF())
	If cFilMat+cMatQAA <> QD1TRB->QD1_FILMAT+QD1TRB->QD1_MAT
		oTreeUsr:AddTree( Padr(QD1TRB->QD1_FILMAT+"-"+QD1TRB->QD1_MAT+" "+Alltrim(QD1TRB->QAA_APELID),100), .F., "BMPUSER",,,,"USR"+StrZero(QD1TRB->R_E_C_N_O_,7))
	EndIf
	
	If cOldTpPen <> QD1TRB->QD1_TPPEND                
		SX5->(DBSeek(xFilial("SX5")+"Q7"+QD1TRB->QD1_TPPEND))				
		oTreeUsr:AddTree( PADR(X5Descri(),100),.F., "POSCLI",,,, StrZero(nSeqTree++,10) ) 
		cOldTpPen:= QD1TRB->QD1_TPPEND
		oTreeUsr:AddTree(PADR(OemToAnsi(STR0011)+": "+AllTrim(QD1TRB->QD1_DOCTO)+" - "+OemToAnsi(STR0012)+": "+AllTrim(QD1TRB->QD1_RV)+" - "+OemToAnsi(STR0013)+": "+AllTrim(STR(dDataBase-QD1TRB->QD1_DTGERA)),100),.F.,"PMSDOC",,,,"QDO"+StrZero(QD1TRB->R_E_C_N_O_,7)) // "Documento" ### "Revisao" "Dias Pendentes"
		oTreeUsr:AddTreeItem(cSx3Tit+": "+AllTrim(QD1TRB->QDH_TITULO),"PMSDOC",,"QDO"+StrZero(QD1TRB->R_E_C_N_O_,7)) //Titulo
		oTreeUsr:EndTree()
	Else
		oTreeUsr:AddTree(PADR(OemToAnsi(STR0011)+": "+AllTrim(QD1TRB->QD1_DOCTO)+" - "+OemToAnsi(STR0012)+": "+AllTrim(QD1TRB->QD1_RV)+" - "+OemToAnsi(STR0013)+": "+AllTrim(STR(dDataBase-QD1TRB->QD1_DTGERA)),100),.F.,"PMSDOC",,,,"QDO"+StrZero(QD1TRB->R_E_C_N_O_,7)) // "Documento" ### "Revisao"
		oTreeUsr:AddTreeItem(cSx3Tit+": "+AllTrim(QD1TRB->QDH_TITULO),"PMSDOC",,"QDO"+StrZero(QD1TRB->R_E_C_N_O_,7)) //Titulo 
		oTreeUsr:EndTree()
	EndIf
	
	cFilMat:= QD1TRB->QD1_FILMAT
	cMatQAA:= QD1TRB->QD1_MAT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha Pasta Tipo de Pendencia          		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QD1TRB->(DbSkip())
	IF !QD1TRB->(EOF())
		If cOldTpPen <> QD1TRB->QD1_TPPEND .Or. QD1TRB->QD1_FILMAT+QD1TRB->QD1_MAT <> cFilMat+cMatQAA
			oTreeUsr:EndTree()
			cOldTpPen:= " "
		EndIf
	Else
		oTreeUsr:EndTree()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha Pasta Usuario     							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !QD1TRB->(EOF())
		If cFilMat+cMatQAA <> QD1TRB->QD1_FILMAT+QD1TRB->QD1_MAT
			oTreeUsr:EndTree()
		EndIf
	Else
		oTreeUsr:EndTree()
	EndIf   
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o menu de opcoes POPUP                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MENU oMenu POPUP
	MENUITEM OemToAnsi(STR0014) Action FActionQDO(1,oTreeUsr)	// "Cadastro"
	MENUITEM OemToAnsi(STR0011) Action FActionQDO(2,oTreeUsr)	// "Documento"
	MENUITEM OemToAnsi(STR0015) Action FActionQDO(3,oTreeUsr) 	// "Avisar Todos"
	MENUITEM OemToAnsi(STR0020) Action FActionQDO(4,oTreeUsr) 	// "Avisar"
ENDMENU

oTreeUsr:bRClicked:= { |o,x,y| QDAtivPopUp(o,x,y,oMenu,1) } // Posicao x,y em relação a Dialog
	       
aDocs:={}
    
DBSELECTAREA("QD1PTRB")
QD1PTRB->(DbGotop())  
cOldTpPen:= " "

While !QD1PTRB->(EOF())

	If cOldTpPen <> QD1PTRB->QD1_TPPEND
		SX5->(DBSeek(xFilial("SX5")+"Q7"+QD1PTRB->QD1_TPPEND))				
		oTreeDoc:AddTree( PADR(X5Descri(),100),.F., "BMPUSER",,,, StrZero(nSeqTree++,10) )
		cOldTpPen:= QD1PTRB->QD1_TPPEND
		
		oTreeDoc:AddTree( PADR(OemToAnsi(STR0011)+": "+AllTrim(QD1PTRB->QD1_DOCTO)+" - "+OemToAnsi(STR0012)+": "+AllTrim(QD1PTRB->QD1_RV)+" - "+OemToAnsi(STR0013)+": "+AllTrim(STR(dDataBase-QD1PTRB->QD1_DTGERA)),100),.F.,"PMSDOC",,,,"QDO"+StrZero(QD1PTRB->R_E_C_N_O_,7)) // "Documento" ### "Revisao" ### "Dias Pendentes"
		oTreeDoc:AddTreeItem(cSx3Tit+": "+AllTrim(QD1PTRB->QDH_TITULO),"PMSDOC",,"QDO"+StrZero(QD1PTRB->R_E_C_N_O_,7)) //Titulo
		oTreeDoc:AddTreeItem( PADR(QD1PTRB->QD1_FILMAT+"-"+QD1PTRB->QD1_MAT+" "+Alltrim(QD1PTRB->QAA_APELID),100),"BMPUSER",, "USR"+StrZero(QD1PTRB->R_E_C_N_O_,7))
	Else
		If QD1PTRB->QD1_TPPEND <> "L  " .And. QD1PTRB->QD1_TPPEND <> "I  "
			oTreeDoc:AddTree( PADR(OemToAnsi(STR0011)+": "+AllTrim(QD1PTRB->QD1_DOCTO)+" - "+OemToAnsi(STR0012)+": "+AllTrim(QD1PTRB->QD1_RV)+" - "+OemToAnsi(STR0013)+": "+AllTrim(STR(dDataBase-QD1PTRB->QD1_DTGERA)),100),.F.,"PMSDOC",,,,"QDO"+StrZero(QD1PTRB->R_E_C_N_O_,7)) // "Documento" ### "Revisao" ### "Dias Pendentes"
			oTreeDoc:AddTreeItem(cSx3Tit+": "+AllTrim(QD1PTRB->QDH_TITULO),"PMSDOC",,"QDO"+StrZero(QD1PTRB->R_E_C_N_O_,7)) //Titulo
			oTreeDoc:AddTreeItem( PADR(QD1PTRB->QD1_FILMAT+"-"+QD1PTRB->QD1_MAT+" "+Alltrim(QD1PTRB->QAA_APELID),100),"BMPUSER",, "USR"+StrZero(QD1PTRB->R_E_C_N_O_,7))
		Else
			If cDocto+cRv <> QD1PTRB->QD1_DOCTO+QD1PTRB->QD1_RV
				oTreeDoc:AddTree( PADR(OemToAnsi(STR0011)+": "+AllTrim(QD1PTRB->QD1_DOCTO)+" - "+OemToAnsi(STR0012)+": "+AllTrim(QD1PTRB->QD1_RV)+" - "+OemToAnsi(STR0013)+": "+AllTrim(STR(dDataBase-QD1PTRB->QD1_DTGERA)),100),.F.,"PMSDOC",,,,"QDO"+StrZero(QD1PTRB->R_E_C_N_O_,7)) // "Documento" ### "Revisao" ### "Dias Pendentes"
				oTreeDoc:AddTreeItem(cSx3Tit+": "+AllTrim(QD1PTRB->QDH_TITULO),"PMSDOC",,"QDO"+StrZero(QD1PTRB->R_E_C_N_O_,7)) //Titulo
				oTreeDoc:AddTreeItem( PADR(QD1PTRB->QD1_FILMAT+"-"+QD1PTRB->QD1_MAT+" "+Alltrim(QD1PTRB->QAA_APELID),100),"BMPUSER",, "USR"+StrZero(QD1PTRB->R_E_C_N_O_,7))
			Else
				oTreeDoc:AddTreeItem( PADR(QD1PTRB->QD1_FILMAT+"-"+QD1PTRB->QD1_MAT+" "+Alltrim(QD1PTRB->QAA_APELID),100),"BMPUSER",, "USR"+StrZero(QD1PTRB->R_E_C_N_O_,7))
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega Array para enviar e-mail       		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	AaDD(aDocs,{QD1PTRB->QD1_DOCTO,QD1PTRB->QD1_RV,QD1PTRB->QD1_TPPEND,QD1PTRB->QD1_FILMAT,QD1PTRB->QD1_MAT,QD1PTRB->QD1_DTGERA,QD1PTRB->R_E_C_N_O_,QD1PTRB->QD1_FILIAL,AllTrim(QD1PTRB->QDH_TITULO)})
	
	cDocto:= QD1PTRB->QD1_DOCTO
	cRv   := QD1PTRB->QD1_RV
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha Pasta Documento                    		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QD1PTRB->QD1_TPPEND <> "L  " .And. QD1PTRB->QD1_TPPEND <> "I  "
		oTreeDoc:EndTree()
		QD1PTRB->(DbSkip())				
	Else         
		QD1PTRB->(DbSkip())
		IF !QD1PTRB->(EOF())
			If cDocto+cRv <> QD1PTRB->QD1_DOCTO+QD1PTRB->QD1_RV
				oTreeDoc:EndTree()
			EndIf  
		Else
			oTreeDoc:EndTree()
		EndIf 
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha Pasta Tipo de Pendencia          		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !QD1PTRB->(EOF())
		If cOldTpPen <> QD1PTRB->QD1_TPPEND
			oTreeDoc:EndTree()
			cOldTpPen:= " "
		EndIf
	Else
		oTreeDoc:EndTree()
	EndIf		
Enddo
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o menu de opcoes POPUP                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MENU oMenu1 POPUP
	MENUITEM OemToAnsi(STR0014) Action FActionQDO(1,oTreeDoc)	// "Cadastro"
	MENUITEM OemToAnsi(STR0011) Action FActionQDO(2,oTreeDoc)	// "Documento"
	MENUITEM OemToAnsi(STR0015) Action FActionQDO(3,oTreeDoc) 	// "Avisar Todos"
	MENUITEM OemToAnsi(STR0020) Action FActionQDO(4,oTreeDoc) 	// "Avisar"
ENDMENU

oTreeDoc:bRClicked:= { |o,x,y| QDAtivPopUp(o,x,y,oMenu1,2) } // Posicao x,y em relação a Dialog

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDAtivPopUp³ Autor ³ Eduardo de Souza    ³ Data ³ 23/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para Ativar Pop-Up                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDAtivPopUp(oTree,nX,nY,oMenu)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto do Tree                                     ³±±
±±³          ³ ExpN1 - Numerico contendo as coordenadas da linha          ³±±
±±³          ³ ExpN2 - Numerico contendo as coordenadas da coluna         ³±±
±±³          ³ ExpO2 - Objeto do POPUP - Menu                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDAtivPopUp(oTree,nX,nY,oMenu,nMenu)

Local cCargo := oTree:GetCargo() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita todos os itens do menu                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AEval( oMenu:aItems, { |x| x:Disable() } ) 

//oMenu:aItems[1] "Cadastro"
//oMenu:aItems[2] "Documento"
//oMenu:aItems[3] "Avisar Todos"
//oMenu:aItems[4] "Avisar"

If Left( cCargo, 3 ) == "QDO"
	oMenu:aItems[1]:enable()	// "Cadastro"
	oMenu:aItems[2]:enable()	// "Documento"
	If nMenu == 2
		oMenu:aItems[3]:enable()
	EndIf
	
ElseIf Left( cCargo, 3 ) == "USR"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se usuario pode receber e-mail³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nReg := Val(SubStr(cCargo,4,7))
	DbSelectArea("QD1")
	DbGoTo(nReg)
	If QAA->(DbSeek(QD1->QD1_FILMAT+QD1->QD1_MAT))
		If !Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1" .And. QA_SitFolh()
			oMenu:aItems[4]:enable() // "Avisar"
		EndIf
	EndIf	
EndIf

oMenu:Activate(abs(nX-280),abs(nY-280),oTree) //nX, nY, oTree

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FActionQDO ³ Autor ³ Eduardo de Souza    ³ Data ³ 24/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para carregar os Cadastros \ Documentos \ Avisos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FActionQDO(nOpcao,oTree)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numerico contendo a opcao(1-Cad/2-Docto/3-Aviso)   ³±±
±±³          ³ ExpO1 - Objeto do Tree para poder pegar o numero do recno()³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FActionQDO(nOpcao,oTree)

Local cCargo:=oTree:GetCargo()
Local nReg := 0

Private aRotina  := { {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0} } //"Visualizar"
Private cCadastro:= OemToAnsi( STR0001 ) // "Lancamentos Pendentes"
Private bCampo   := { |nCPO| Field( nCPO ) }       
Private lSolicitacao	:= .f.

INCLUI := .F.

DbSelectArea("QDH")
DbSetOrder(1)

If Left( cCargo, 3 ) == "QDO" .Or. Left( cCargo, 3 ) == "USR"
	nReg := Val(SubStr(cCargo,4,7))
	DbSelectArea("QD1")
	DbGoTo(nReg)
	If QDH->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
		If nOpcao == 1 	// Cadastro
			QD050Telas("QDH",QDH->(RecNo()),8)
		ElseIf nOpcao == 2 // Documento
			QdoDocCon()
		EndIf
	EndIf
	If nOpcao == 3 .Or. nOpcao == 4 // Avisar
		QD30Aviso(oTree,nOpcao)
	Endif
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD30Aviso³ Autor ³ Eduardo de Souza      ³ Data ³ 24/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Envio de aviso para usuarios via e-mail                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD30Aviso(ExpO1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD30Aviso(oTree,nOpcao)

Local oDlg
Local oCorpo
Local cCorpo    := " "

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0021) FROM 000,000 TO 185,505 OF oMainWnd PIXEL // "Aviso"

@ 030,002 GET oCorpo VAR cCorpo MEMO NO VSCROLL SIZE 250,060 OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| QD30Mail(oTree,cCorpo,nOpcao),oDlg:End()},{|| oDlg:End()})

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD30Mail ³ Autor ³ Eduardo de Souza      ³ Data ³ 28/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Envia e-mail para os usuarios selecionados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD30Mail(ExpO1,ExpC1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto Tree                                        ³±±
±±³          ³ ExpC1 - Corpo do E-Mail                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD30Mail(oTree,cCorpo,nOpcao)

Local aUsrMail := {}
Local cAssunto := OemToAnsi(STR0022) // "Aviso de Pendencia"
Local cCargo   := oTree:GetCargo()
Local nReg     := 0
Local nOrdQAA  := QAA->(IndexOrd())
Local cApelido := ""
Local nCnt     := 0
Local cTpMail  := "1"
Local cFilDep  := xFilial("QAD")

Private aUsrMat:= QA_USUARIO()

QAA->(DbSetOrder(1))

If nOpcao == 3  //"Avisar Todos"
	
	nReg := Val(SubStr(cCargo,4,7))
	DbSelectArea("QD1")
	DbGoTo(nReg)	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordena Array Filial+Docto+Rv para agilizar o processo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Asort(aDocs,,,{|x,y| x[8]+x[1]+x[2] < y[8]+y[1]+y[2]})
	For nCnt:= 1 to Len(aDocs)
		If aDocs[nCnt,8]+aDocs[nCnt,1]+aDocs[nCnt,2] == QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV
			If QAA->(DbSeek(aDocs[nCnt,4]+aDocs[nCnt,5]))
				If !Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1" .And. QA_SitFolh()
					If !Empty(QAA->QAA_APELID)
						cApelido:= QAA->QAA_APELID
					Else
						cApelido:= QAA->QAA_NOME
					EndIf
					cTpMail:= QAA->QAA_TPMAIL
					If FWModeAccess("QAD")=="E"
						cFilDep:= QAA->QAA_FILIAL
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrega Array com usuarios que vao receber E-Mail³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QD30CarMail(@aUsrMail,cApelido,QAA->QAA_EMAIL,cAssunto,cCorpo,cTpMail,cFilDep)
				EndIf
			EndIf
		EndIf
		If aDocs[nCnt,8]+aDocs[nCnt,1]+aDocs[nCnt,2] > QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV
			Exit
		EndIf
	Next nCnt
	
	
ElseIF nOpcao == 4 //"Avisar"
	
	nReg := Val(SubStr(cCargo,4,7))
	DbSelectArea("QD1")
	DbGoTo(nReg)
	
	If QAA->(DbSeek(QD1->QD1_FILMAT+QD1->QD1_MAT))
		If !Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1" .And. QA_SitFolh()
			If !Empty(QAA->QAA_APELID)
				cApelido:= QAA->QAA_APELID
			Else
				cApelido:= QAA->QAA_NOME
			EndIf
			cTpMail:= QAA->QAA_TPMAIL
			If FWModeAccess("QAD")=="E"
				cFilDep:= QAA->QAA_FILIAL
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega Array com usuarios que vao receber E-Mail³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QD30CarMail(@aUsrMail,cApelido,QAA->QAA_EMAIL,cAssunto,cCorpo,cTpMail,cFilDep)
		EndIf
	EndIf
EndIf

IF Len(aUsrMail) > 0
	QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
Endif	

QAA->(DbSetOrder(nOrdQAA))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD30CarMail³ Autor ³Eduardo de Souza        ³ Data ³ 28/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega email                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD30CarMail(ExpA1,ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array Usuarios que vai receber E-Mail                 ³±±
±±³          ³ ExpC1 - Apelido do Usuario                                    ³±±
±±³          ³ ExpC2 - E-Mail do Usuario                                     ³±±
±±³          ³ ExpC3 - Assunto do E-Mail                                     ³±±
±±³          ³ ExpC4 - Corpo do E-Mail                                       ³±±
±±³          ³ ExpC5 - Tipo de Recebimento do email (1-Html/2-Texto)         ³±±
±±³          ³ ExpC6 - Filial do Departamento do Usuario                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOC030()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD30CarMail(aUsrMail,cApelido,cMail,cAssunto,cCorpo,cTpMail,cFilDep)

Local aMsg    := {}
Local cMsg    := " "               
Local cSubject:= " "
Local cAttach := " "
Local cMatFil := aUsrMat[2] // Filial do Usuario Logado
Local cMatCod := aUsrMat[3] // Matricula do Usuario Logado
Local cMatDep := aUsrMat[4] // Depto do Usuario Logado

cSubject:= cAssunto
If cTpMail == "1"
	cMsg:= '<html><title>'+OemToAnsi(STR0023)+'</title><body>' // "SIGAQDO - Controle de Documentos"
	cMsg+= '<table bordercolor=#0099cc height=29 cellspacing=1 width=645 bordercolorlight=#0099cc border=1>'
	cMsg+= ' <tr><td bordercolor=#0099cc bordercolorlight=#0099cc align=left width=606'
	cMsg+= '   bgcolor=#0099cc bordercolordark=#0099cc height=1>'
	cMsg+= '   <p align=center><font face="courier new" color=#ffffff size=4>'
	cMsg+= '   <b>'+OemToAnsi(STR0024)+'</b></font></p></td></tr>' // "ASSUNTO"
	cMsg+= ' <tr><td align=left width=606 height=32>'
	cMsg+= '   <p align=center>'+cAssunto+'</p></td></tr>'
	cMsg+='</table>'
	
	cMsg+= '<table bordercolor=#0099cc height=29 cellspacing=1 width=645 bordercolorlight=#0099cc border=1>'
	cMsg+= '  <tr><td colspan=6 bordercolor=#0099cc bordercolorlight=#0099cc align=left width=606'
	cMsg+= '   bgcolor=#0099cc bordercolordark=#0099cc height=1>'
	cMsg+= '   <p align=center><font face="courier new" color=#ffffff size=4>'
	cMsg+= '   <b>'+OemToAnsi(STR0025)+'</b></font></p></td></tr>' // "MENSAGEM"
	cMsg+= ' <tr><td align=left width=100% height=32>'+cCorpo+'</td></tr>'
	cMsg+= '</table>'
	
	cMsg+= '<br>'+OemToAnsi(STR0026)+'<br>'+Alltrim(QA_NUSR(cMatFil,cMatCod)) //"Atenciosamente"
	cMsg+= '  <br>'+Alltrim(QA_NDEPT(cMatDep,.T.,cFilDep))
Else
	cMsg:= cCorpo+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMsg+= OemToAnsi(STR0026)+CHR(13)+CHR(10) //"Atenciosamente"
	cMsg+= Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10)
	cMsg+= Alltrim(QA_NDEPT(cMatDep,.T.,cFilDep))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
EndIf

aMsg:=  {{cSubject,cMsg,cAttach}}

AADD(aUsrMail,{ AllTrim(cApelido),Trim(cMail),aMsg })

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDC030Pesq  ³ Autor ³ Eduardo de Souza    ³ Data ³ 28/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa Texto                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDC030Pesq(ExpO1,ExpN1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto do Tree                                     ³±±
±±³          ³ ExpN1 - Numero do Botao Pesquisar                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDC030Pesq(oTree,nBtn)

Local oDlgPesq
Local oBtn1
Local oBtn2
Local nOpcao    := 0
Local lAchou    := .F.

If nBtn == 1 // "Pesquisa Texto"
	lEditPTree := .T.		
Else         // "Proxima Pesquisa"
	lEditPTree := .F.
EndIf

If lEditPTree
	DEFINE MSDIALOG oDlgPesq FROM 0,0 TO 080,634 PIXEL TITLE OemToAnsi(STR0032)	// "Pesquisa Texto"

    cChaveTree := Padr(cChaveTree,100)
	@ 010,05 MSGET cChaveTree SIZE 310,08 OF oDlgPesq PIXEL

	DEFINE SBUTTON oBtn1 FROM 25,005 TYPE 1 PIXEL ENABLE OF oDlgPesq ACTION ( nOpcao:=1,oDlgPesq:End() )
	DEFINE SBUTTON oBtn2 FROM 25,035 TYPE 2 PIXEL ENABLE OF oDlgPesq ACTION ( nOpcao:=2,oDlgPesq:End() )

	ACTIVATE MSDIALOG oDlgPesq CENTERED
Endif

If (nOpcao == 1 .Or. nOpcao == 0) .And. !Empty(AllTrim(cChaveTree))
	cChaveTree := UPPER(AllTrim(cChaveTree))
	dbSelectArea(oTree:cArqTree)
	dbGoTop()	
	While !Eof()
		If cChaveTree $ UPPER(T_PROMPT)
			If (nOpcao == 0 .And. T_CARGO > cChaveSeq) .Or. nOpcao == 1
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				// Colocado duas vezes para posicionar na linha onde esta o texto
				// porque se buscar uma vez posiciona no Item pai.                
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				cChaveSeq := T_CARGO
				lAchou := .T.
				lEditPTree := .F.
				Exit
			Endif
		Endif
		dbSkip()
	Enddo
	If !lAchou
		If cChaveSeq <> "0000"
			lEditPTree := .T.
		Endif
		MsgAlert(OemToAnsi(STR0033+" '"+cChaveTree+"' "+STR0034))	// "Texto" ### "nao encontrado"
	Else
		lEditPTree := .F.
	Endif
Endif

Return Nil
