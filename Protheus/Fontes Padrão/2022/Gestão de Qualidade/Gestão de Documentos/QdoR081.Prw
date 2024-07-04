#INCLUDE  "QDOR081.CH"
#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "Report.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOR081   ºAutor  ³Leandro Sabino      º Data ³  26/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao de listagem para Convocacao de Treinamento       º±±
±±º          ³ (Versao Relatorio Personalizavel)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QDOR081(lTreina)
Local oReport

If TRepInUse()
	Pergunte("QDR081",.F.) 
    oReport := ReportDef(lTreina)
    oReport:PrintDialog()
Else
	QDOR081R3()	// Executa versão anterior do fonte
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(lTreina)
Local cTitulo	:= OemToAnsi(STR0001) // "CONVOCACAO DE TREINAMENTO"
Local cDesc1 	:= OemToAnsi(STR0002) // "Este programa ira imprimir a convocacao de treinamento "
Local cDesc2 	:= OemToAnsi(STR0003) // "para todos os participantes selecionados, listando o local"
Local cDesc3 	:= OemToAnsi(STR0004) // "a data e o documento do treinamento."Local wnrel  := "QDOR020"
Local oSection1 
Local oSection2 
Local oSection3 

DEFINE REPORT oReport NAME "QDOR081" TITLE cTitulo PARAMETER "QDR081" ACTION {|oReport| PrintReport(oReport,lTreina)} DESCRIPTION (cDesc1+cDesc2+cDesc3)

DEFINE SECTION oSection1 OF oReport TABLES "QD8" TITLE OemToAnsi(STR0019)         
DEFINE CELL NAME "cAdm"   OF oSection1 ALIAS "QD8" TITLE TitSX3("QAA_NOME")[1]	SIZE 40 //BLOCK {||QA_NUSR((cAlias)->QD8_FILMAT,(cAlias)->QD8_MAT,.t.) }
DEFINE CELL NAME "cCargo" OF oSection1 ALIAS "QD8" TITLE OemToAnsi(STR0017)   	SIZE 20 //BLOCK {||QA_NFUNC((cAlias)->QD8_CARGO,.T.,cFilFunc) }
DEFINE CELL NAME "cSetor" OF oSection1 ALIAS "QD8" TITLE OemToAnsi(STR0018)  	SIZE 15 //BLOCK {||QA_NDEPT((cAlias)->QD8_DEPTO,.t.,(cAlias)->QD8_FILMAT)}
                                                          
DEFINE SECTION oSection2 OF oSection1 TABLES "QDA" TITLE OemToAnsi(STR0020)
DEFINE CELL NAME "cCONVOC" OF oSection2 ALIAS "QDA" TITLE OemToAnsi(STR0022) SIZE 120 BLOCK {||MSMM(QDA->QDA_CONVOC)} // "Descricao da Convocacao"
oSection2:Cell("cCONVOC"):SeTLineBREAK(.T.)

DEFINE SECTION oSection3 OF oSection2 TABLES "QDA","QDH" TITLE OemToAnsi(STR0021) // "Treinamento"
DEFINE CELL NAME "QDA_DOCTO"  OF oSection3 ALIAS "QDA"
DEFINE CELL NAME "QDA_RV"     OF oSection3 ALIAS "QDA"
DEFINE CELL NAME "QDH_TITULO" OF oSection3 ALIAS "QDH"
			
Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 26/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport,lTreina) 
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)
Local lAchouQda := .T.
Local aUsrMat  	:= QA_USUARIO()
Local cMatDep  	:= aUsrMat[4]
Local cMatFil  	:= aUsrMat[2]
Local cFilFunc 	:= xFilial("QAC")
Local cAlias	:= "QD8"
Local cOrder := ""

dbSelectArea("QDH")
dbSetOrder(1)

dbSelectArea("QDA")
dbSetOrder(1)

dbSelectArea("QD8")
dbSetOrder(1)

MakeSqlExpr(oReport:uParam)
oSection1:BeginQuery()

If	Upper(TcGetDb()) $ 'ORACLE'                          
  	 cORDER += "%1,2,3,4,5,6,7%"
Else
	 cORDER += "%QD8_FILIAL,QD8_ANO,QD8_NUMERO,QD8_FILMAT,QD8_DEPTO,QD8_CARGO,QD8_MAT%"
   	Endif

cAlias := GetNextAlias()

BeginSQL Alias cAlias

	SELECT QD8.QD8_FILIAL,QD8.QD8_ANO,QD8.QD8_NUMERO,QD8.QD8_FILMAT,QD8.QD8_DEPTO,QD8.QD8_CARGO,QD8.QD8_MAT,QD8.QD8_SELECA

	FROM %table:QD8% QD8

	WHERE	QD8_FILIAL = %xFilial:QD8% And 	
		    QD8_NUMERO >= %Exp:mv_par01% And QD8_NUMERO <= %Exp:mv_par02% And
		    QD8_ANO >= %Exp:mv_par03% And QD8_ANO <= %Exp:mv_par04% and 
 		    QD8.%notDel%
 		    
	ORDER BY %Exp:cOrder%
	
    EndSql
    
oSection1:EndQuery()
                      

//Criando filtro na tabela QAA para
//nao mais imprimir usuarios inativos
Qaxa010Fil()

While !oReport:Cancel() .And. (cAlias)->(!Eof())
	
	If QAA->(dbSeek((cAlias)->QD8_FILMAT+(cAlias)->QD8_MAT))	 
		If 	!lTreina 
			If QDA->(DbSeek(xFilial("QD8")+(cAlias)->QD8_ANO+(cAlias)->QD8_NUMERO))
				If QDA->QDA_DOCTO >= mv_par05 .And. QDA->QDA_DOCTO <= mv_par07 .And. QDA->QDA_RV >= mv_par06 .And.QDA->QDA_RV <= mv_par08
					lAchouQda := .T.
	
					If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QDA")))
						If !QDA->(&(oReport:Section(1):GetAdvplExp("QDA")))
							lAchouQda := .F.
						Endif
					Endif
				Else
					lAchouQda := .F.
				Endif
			Else
				lAchouQda := .F.
			Endif
		Endif
	
	   	If (cAlias)->QD8_SELECA == "S" .And. lAchouQda
	      	oSection1:Init()
			oSection1:Cell("cAdm"):SetValue({||QA_NUSR((cAlias)->QD8_FILMAT,(cAlias)->QD8_MAT,.t.)})
			oSection1:Cell("cCargo"):SetValue({||QA_NFUNC((cAlias)->QD8_CARGO,.T.,cFilFunc)})
			oSection1:Cell("cSetor"):SetValue({||QA_NDEPT((cAlias)->QD8_DEPTO,.t.,(cAlias)->QD8_FILMAT)})
	      	oSection1:PrintLine()
	   	
	      	oSection2:Init()
	      	oSection2:PrintLine()
	
			oReport:SkipLine(1)	      	
			
		  	If QDH->(DbSeek(xFilial("QDH")+QDA->QDA_DOCTO+QDA->QDA_RV))
	    	  	oSection3:Init()
		      	oSection3:PrintLine()
		  	EndIf
	
			oReport:SkipLine(1) 
			oReport:ThinLine()
			oReport:PrintText(OemToAnsi(STR0008)+Space(1)+QDA->QDA_NUMERO+"/"+QDA->QDA_ANO,oReport:Row(),025) // "TREINAMENTO:"
			oReport:SkipLine(1)	
			
			oReport:PrintText(OemToAnsi(STR0012)+Space(1)+DtoC(QDA->QDA_DTINIC)+" "+(Substr(QDA->QDA_HORAI,1,2)+":"+Substr(QDA->QDA_HORAI,3,2))+" "+OemToAnsi(STR0013)+" "+DTOC(QDA->QDA_DTFIM)+" "+(Substr(QDA->QDA_HORAF,1,2)+":"+Substr(QDA->QDA_HORAF,3,2)),oReport:Row(),025) // "PERIODO DE:" ### "A"
			oReport:SkipLine(1)	
			
			oReport:PrintText(OemToAnsi(STR0011)+Space(1)+QDA->QDA_LOCAL,oReport:Row(),025)  // "LOCAL:"
			oReport:SkipLine(1)	
			
			oReport:PrintText(OemToAnsi(STR0014)+Space(1)+QA_nDept(cMatDep,.t.,cMatFil),oReport:Row(),025)  // "DEPTO EMISSOR:"
			oReport:SkipLine(1)	
	
	      	If !Empty(QDA->QDA_OBS)
				oReport:PrintText(OemToAnsi(STR0015)+Space(1)+AllTrim(QDA->QDA_OBS),oReport:Row(),025) // "OBSERVACAO:"
				oReport:SkipLine(1)	
			EndIf
	
			oReport:ThinLine()
			oReport:SkipLine(1)	
	
	 	EndIf
	
	   	oSection1:SetPageBreak(.T.) 
   	EndIf
   	
   	(cAlias)->(DbSkip())
   	
   	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()
   
EndDo

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDOR081R3  ³ Autor ³Wagner Mobile Costa    ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressao de listagem para Convocacao de Treinamento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDOR081()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOR081R3()

Local cTitulo	:= OemToAnsi(STR0001) // "CONVOCACAO DE TREINAMENTO"
Local cDesc1 	:= OemToAnsi(STR0002) // "Este programa ira imprimir a convocacao de treinamento "
Local cDesc2 	:= OemToAnsi(STR0003) // "para todos os participantes selecionados, listando o local"
Local cDesc3 	:= OemToAnsi(STR0004) // "a data e o documento do treinamento."
Local cString	:= "QD8"
Local wnrel  	:= "QDOR081"
Local Tamanho	:= "P"      

Private cPerg	:= "QDR081"
Private aReturn := {OemToAnsi(STR0005),1,OemToAnsi(STR0006),2,2,1,"",1} // "Zebrado" ### "Administracao"
Private nLastKey:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                               ³
//³ mv_par01	// Codigo Treinamento de                               ³
//³ mv_par02	// Codigo Treinamento ate                              ³
//³ mv_par03	// Ano de                                              ³
//³ mv_par04	// Ano ate                                             ³
//³ mv_par05	// De  Documento                                       ³
//³ mv_par06	// Revisao                                             ³
//³ mv_par07	// Ate Documento                                       ³
//³ mv_par08	// Revisao                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ! Pergunte(cPerg,.T.)
	Return
Endif

wnrel := SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,Tamanho)

If nLastKey == 27
	Return
EndIf

SetDefault( aReturn, cString )

If nLastKey == 27
	Return
EndIf

RptStatus( { |lEnd| A080IDetCv(@lEnd,ctitulo,wnRel,Tamanho,;
			"QD8_FILIAL='"+xFilial("QD8")+"' .And. 	 QD8_NUMERO >= '" + mv_par01 + "' .And. " +;
			"QD8_NUMERO <= '" + mv_par02 + "' .And. " +;
			"QD8_ANO >= '" + mv_par03 + "' .And. " +;
			"QD8_ANO <= '" + mv_par04 + "'",;
		{ || 	QDA->QDA_DOCTO >= mv_par05 .And.;
			QDA->QDA_DOCTO <= mv_par07 .And.;
			QDA->QDA_RV >= mv_par06 .And.;
			QDA->QDA_RV <= mv_par08 .And.;
			If(! Empty(aReturn[7]), &(aReturn[7]), .T.) } ) },cTitulo)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ A080IDetCv ³ Autor ³Rodrigo de A. Sartorio ³ Data ³ 06/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Envia para funcao que faz a impressao do relatorio.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080IDetCv(ExpL1,ExpC1,ExpC2,ExpC3)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Cancela Relatorio                                    ³±±
±±³          ³ ExpC1 - Titulo do Relatorio                                  ³±±
±±³          ³ ExpC2 - Nome do Relatorio                                    ³±±
±±³          ³ ExpC3 - Tamanho do Relatorio                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA080                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A080IDetCv(lEnd,cTitulo,wnRel,Tamanho,cFiltro, bFilQda)

Local cCabec1  	:= OemToAnsi(STR0001) // "CONVOCACAO DE TREINAMENTO"
Local cCabec2  	:= ""
Local cbtxt    	:= SPACE(10)
Local cbcont   	:= 0
Local aUsrMat  	:= QA_USUARIO()
Local cMatFil  	:= aUsrMat[2]
Local cMatDep  	:= aUsrMat[4]
Local cFilFunc 	:= xFilial("QAC")
Local cAliasQry := "QD8"
Local lAchouQda := .T.
Local aTexConv	:= {}
Local nI		:= 1	
Local cQuery	:= ""
Local aARea		:=GetARea()

DEFAULT cFiltro	:= "QD8_FILIAL = '"+QDA->QDA_FILIAL+"' .AND. QD8_ANO ='"+QDA->QDA_ANO+"' .AND. QD8_NUMERO = '"+QDA->QDA_NUMERO+"'"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retirada do "." para compabilidade com linguagem SQL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While  AT(".",cFiltro) <> 0 
 	cFiltro:=STUFF(cFiltro,At(".",cFiltro),1,"")
Enddo           

cQuery :="SELECT QD8_FILIAL,QD8_ANO,QD8_NUMERO,QD8_FILMAT,QD8_DEPTO,QD8_CARGO,QD8_MAT,QD8_SELECA "
cQuery +="FROM " + RetSqlName("QD8")+" QD8 "
cQuery +="WHERE " 		       		         
cQuery += cFiltro +" AND "
cQuery +=" QD8.D_E_L_E_T_ <> '*' " 

If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1,2,3,4,5,6,7"
Else
	cQuery += " ORDER BY " + SqlOrder("QD8_FILIAL+QD8_ANO+QD8_NUMERO+QD8_FILMAT+QD8_DEPTO+QD8_CARGO+QD8_MAT")
Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQD8",.T.,.T.)
cAliasQry:="TMPQD8"

SetRegua(0)

QDH->(DbSetOrder(1))

Li    := 80
m_pag := 1

//Criando filtro na tabela QAA para
//nao mais imprimir usuarios inativos
Qaxa010Fil()

While (cAliasQry)->(!EOF())
	If QAA->(dbSeek((cAliasQry)->QD8_FILMAT+(cAliasQry)->QD8_MAT))
		If bFilQda <> Nil .And. (cAliasQry)->QD8_SELECA == "S"
	   		If 	QDA->(DbSeek(xFilial("QD8")+(cAliasQry)->QD8_ANO+;
	   			(cAliasQry)->QD8_NUMERO)) .And. Eval(bFilQda)     			
				lAchouQda := .T.
			Else
				lAchouQda := .F.
			Endif
		Endif
		
		IncRegua()
	   	If (cAliasQry)->QD8_SELECA == "S" .And. lAchouQda
	      	If lEnd
	         	li++
	         	@ PROW()+1,001 PSAY OemToAnsi(STR0007) // "CANCELADO PELO OPERADOR"
	         	Exit
	      	EndIf
	      	If Li > 58
	         	Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho)
	      	EndIf
	      	@ Li,000 PSay QA_NUSR((cAliasQry)->QD8_FILMAT,(cAliasQry)->QD8_MAT,.t.)
	      	Li++
			If FWModeAccess("QAC")=="E"  //!Empty(xFilial("QAC"))
				cFilFunc:= QD8->QD8_FILMAT
			EndIf          
	      	@ Li,000 PSay QA_NFUNC((cAliasQry)->QD8_CARGO,.T.,cFilFunc)
	      	Li++
	      	@Li,000 PSay QA_NDEPT((cAliasQry)->QD8_DEPTO,.t.,(cAliasQry)->QD8_FILMAT)
	      	Li++
	
		  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  	//³ Imprime texto da convocacao do treinamento          	   ³
		  	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  	aTexConv:=JustificaTXT(MSMM(QDA->QDA_CONVOC,80),80,.T.)	
	        For nI:=1 to Len(aTexConv)
		      	@ Li,000 PSay aTexConv[nI]
		      	Li++
		    Next  		  	
	      	Li++
	      	@ Li,000 PSay __PrtThinLine()
	      	Li++
	  	  	@ Li,000 PSay OemToAnsi(STR0009)+" "+QDA->QDA_DOCTO+" "+OemToAnsi(STR0010)+" "+QDA->QDA_RV // "DOCUMENTO:" ### "REVISAO:"
	      	Li++
		
		  	If QDH->(DbSeek(xFilial("QDH")+QDA->QDA_DOCTO+QDA->QDA_RV))
				If Len(AllTrim(QDH->QDH_TITULO)) > 70
					@ Li,011 PSay Substr(AllTrim(QDH->QDH_TITULO),1,50)
					Li++
					@ Li,011 PSay Substr(AllTrim(QDH->QDH_TITULO),51,50)
				Else
					@ Li,011 PSay AllTrim(QDH->QDH_TITULO)
				EndIf
				Li++
		  	EndIf
	      	Li++
	      	@ Li,000 PSay __PrtThinLine()
	      	Li++
	      	@ Li,000 PSay OemToAnsi(STR0008)+Space(1)+QDA->QDA_NUMERO+"/"+QDA->QDA_ANO // "TREINAMENTO:"
	      	Li++
	      	@ Li,000 PSay OemToAnsi(STR0012)+Space(1)+DtoC(QDA->QDA_DTINIC)+" "+(Substr(QDA->QDA_HORAI,1,2)+":"+Substr(QDA->QDA_HORAI,3,2))+" "+OemToAnsi(STR0013)+" "+DTOC(QDA->QDA_DTFIM)+" "+(Substr(QDA->QDA_HORAF,1,2)+":"+Substr(QDA->QDA_HORAF,3,2)) // "PERIODO DE:" ### "A"
	      	Li++
	      	@ Li,000 PSay OemToAnsi(STR0011)+Space(1)+QDA->QDA_LOCAL // "LOCAL:"
	      	Li++
	      	@ Li,000 PSay OemToAnsi(STR0014)+Space(1)+QA_nDept(cMatDep,.t.,cMatFil) // "DEPTO EMISSOR:"
	      	Li++		
	      	If !Empty(QDA->QDA_OBS)
	      	    Li++
				If Len(AllTrim(QDA->QDA_OBS)) > 65
		      		@ Li,000 PSay OemToAnsi(STR0015)+Space(1)+Substr(AllTrim(QDA->QDA_OBS),1,65) // "OBSERVACAO:"
		      		Li++
		      		@ Li,012 PSay Substr(AllTrim(QDA->QDA_OBS),66,65)
					If Len(AllTrim(QDA->QDA_OBS)) > 130				
						Li++
			      		@ Li,012 PSay Substr(AllTrim(QDA->QDA_OBS),131,65)
					EndIf
				Else
		      		@ Li,000 PSay OemToAnsi(STR0015)+Space(1)+QDA->QDA_OBS // "OBSERVACAO:"
				EndIf
	      		Li++
			EndIf
			Li++
		   	Roda( cbcont, cbtxt, "P" )
	      	Li:= 80
	   	EndIf
   	EndIF
   	(cAliasQry)->(DbSkip())
EndDo

Set Device To Screen

If aReturn[5] = 1
   Set Printer TO
   DbCommitAll()
   Ourspool( wnrel )
Endif

(cAliasQry)->(DbCLOSEAREA())										
                        
RestARea(aArea)	   									

MS_FLUSH()

Return .t.
