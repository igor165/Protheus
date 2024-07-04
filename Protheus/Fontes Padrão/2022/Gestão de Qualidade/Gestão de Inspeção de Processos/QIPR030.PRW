
#Include "QIPR030.CH"
#Include "PROTHEUS.CH"
#Include "REPORT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIPR030	³ Autor ³ Cleber Souza          ³ Data ³ 31/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Plano de Conferencia				     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ QIPR030()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPR030					                          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPR030()

Private cPerg := "QPR030"

If TRepInUse()
	oReport := ReportDef()
 	oReport:PrintDialog()
Else
	QIPR030R3()
EndIf   

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ReportDef  ºAutor  ³Cleber Souza        º Data ³  31/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definicoes do relatorio de Formulas R4.		              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIER280                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local cPrograma  	:= "QIPR030"
LOCAL cDesc1    	:= STR0001 //"Neste relat¢rio ser„o relacionados os produtos ao roteiro de opera‡Æo e "
LOCAL cDesc2	    := STR0002 //"ensaios respectivamente."
Local cTitulo		:= OemToAnsi(STR0003)	//"Plano de Conferencia"

DEFINE REPORT oReport NAME cPrograma TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)

DEFINE SECTION oSection1 OF oReport LINE STYLE PAGE BREAK TITLE TitSx3("QP6_PRODUT")[1] TABLES "QP6"
DEFINE CELL NAME "QP6_PRODUT"  OF oSection1 SIZE TamSx3("QP6_PRODUT")[1]+ TamSx3("QP6_REVI")[1]+4  TITLE  AllTrim(TitSx3("QP6_PRODUT")[1])+" - "+AllTrim(TitSx3("QP6_REVI")[1])+"........................" CELL BREAK 
DEFINE CELL NAME "QP6_DESCPO"  OF oSection1 SIZE TamSx3("QP6_DESCPO")[1]	TITLE  AllTrim(TitSx3("QP6_DESCPO")[1])+"................................"	 CELL BREAK 
DEFINE CELL NAME "A7_CLIENTE"  OF oSection1 SIZE TamSx3("A7_CLIENTE")[1]	TITLE  AllTrim(TitSx3("A7_CLIENTE")[1])+"................................."	 CELL BREAK 
DEFINE CELL NAME "QP6_APLIC"   OF oSection1 SIZE TamSx3("QP6_APLIC")[1]		TITLE  AllTrim(TitSx3("QP6_APLIC")[1])+"................................" CELL BREAK 
DEFINE CELL NAME "QP6_CROQUI"  OF oSection1 SIZE TamSx3("QP6_CROQUI")[1]	TITLE  AllTrim(TitSx3("QP6_CROQUI")[1])+"..................................." CELL BREAK 
DEFINE CELL NAME "cDatas"      OF oSection1 SIZE TamSx3("QP6_DTCAD")[1]+TamSx3("QP6_DTDES")[1]+TamSx3("QP6_RVDES")[1]   TITLE  AllTrim(TitSx3("QP6_DTCAD")[1])+"/"+AllTrim(TitSx3("QP6_DTDES")[1])+"/"+AllTrim(TitSx3("QP6_RVDES")[1])+"..." CELL BREAK 
DEFINE CELL NAME "QP6_DTINI"   OF oSection1 SIZE 10 						TITLE  AllTrim(TitSx3("QP6_DTINI")[1])+"............................." CELL BREAK 
DEFINE CELL NAME "QP6_DOCOBR"  OF oSection1 SIZE 5							TITLE  AllTrim(TitSx3("QP6_DOCOBR")[1])+"............................." CELL BREAK 

DEFINE SECTION oSection2 OF oReport LINE STYLE TITLE TitSx3("QP7_CODREC")[1] TABLES "QQK"
DEFINE CELL NAME "CODREC"  	   OF oSection2 SIZE 100   TITLE  Capital(Substr(OemToAnsi(STR0022),1,7))+"......" CELL BREAK 
DEFINE CELL NAME "QP7_OPERAC"  OF oSection2 SIZE 100   TITLE  AllTrim(TitSx3("QP7_OPERAC")[1])+"....." CELL BREAK 

DEFINE SECTION oSection3 OF oReport TITLE TitSx3("QP7_ENSAIO")[1] TABLES "QP7","QP8","QQ1"
DEFINE CELL NAME "QP7_ENSAIO"  OF oSection3 SIZE 40   TITLE  AllTrim(TitSx3("QP7_ENSAIO")[1]) 
DEFINE CELL NAME "QP7_LABOR"   OF oSection3 SIZE 10   TITLE  STR0011		//"Labor."	
DEFINE CELL NAME "QP7_UNIMED"  OF oSection3 SIZE 10   TITLE  STR0012		//"Un. Med."	
DEFINE CELL NAME "QP8_TEXTO"   OF oSection3 SIZE 39   TITLE  AllTrim(TitSx3("QP8_TEXTO")[1]) LINE BREAK	
DEFINE CELL NAME "QP7_NOMINA"  OF oSection3 SIZE 10   TITLE  STR0013		//"Nominal"	
DEFINE CELL NAME "QP7_LIE"     OF oSection3 SIZE TamSx3("QP7_LIE")[1]  	   TITLE  STR0014		//"L.I.E."	
DEFINE CELL NAME "QP7_LSE"     OF oSection3 SIZE TamSx3("QP7_LSE")[1]      TITLE  STR0015		//"L.S.E."	
DEFINE CELL NAME "QP7_PLAMO"   OF oSection3 SIZE TamSx3("QP7_PLAMO")[1]    TITLE  STR0016		//"Pl "	
DEFINE CELL NAME "QP7_NIVEL"   OF oSection3 SIZE TamSx3("QP7_NIVEL")[1]    TITLE  AllTrim(TitSx3("QP7_NIVEL")[1])
DEFINE CELL NAME "cGrpPrd"     OF oSection3 SIZE 5						    TITLE  STR0018		//"Grp/Prd""	
DEFINE CELL NAME "QQ1_INSTR"   OF oSection3 SIZE TamSx3("QQ1_INSTR")[1]    TITLE  AllTrim(TitSx3("QQ1_INSTR")[1]) 

DEFINE SECTION oSection4 OF oReport TITLE STR0021 //"Plano de Amostragem"	
DEFINE CELL NAME "cEnsPla"     OF oSection4 SIZE TamSx3("QP7_ENSAIO")[1]   TITLE  AllTrim(TitSx3("QP7_ENSAIO")[1]) 
DEFINE CELL NAME "cCodPla"     OF oSection4 SIZE 2   TITLE  STR0025 //"Codigo"
DEFINE CELL NAME "cPlano"      OF oSection4 SIZE 50  TITLE  STR0021	//"Plano de Amostragem"	

DEFINE SECTION oSection5 OF oReport LINE STYLE TITLE STR0023 //"Observacoes"
DEFINE CELL NAME "Observacao"  OF oSection5 SIZE 100   TITLE  STR0024 LINE BREAK	//"Observacoes"

Return(oReport) 		 	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor  ³Cleber Souza		 º Data ³  31/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao relatorio R4.                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIER280                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport)   
Local oTempTable   := NIL
Local oSection1    := oReport:Section(1)
Local oSection2    := oReport:Section(2)
Local oSection3    := oReport:Section(3)
Local oSection4    := oReport:Section(4)
Local oSection5    := oReport:Section(5)
LOCAL cTipoEns
LOCAL nIndex
LOCAL cDescEns 	:= Space(30)
LOCAL aEnsaios 	:= {}
LOCAL cCond			:= ""
LOCAL cNomArq 		:= ""
LOCAL nRecQP6		:= 0
LOCAL cEspecie		:= "QIPA010 "
LOCAL cRoteiro		:= ""
Local cArqTrb		:= CriaTrab("",.F.)
Local aTam			:= {}
Local aCampos		:= {}
Local nC            := 0
Local lImpEns       := .F. 
Local lPrimVez      := .F.
Local cTxtObs       := ""

Pergunte(cPerg,.F.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho para ordenar os ensaios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("QP6_PRODUT")	;AADD(aCampos,{"PRODUTO"	,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP6_REVI")	;AADD(aCampos,{"REVI"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_ENSAIO")	;AADD(aCampos,{"ENSAIO"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_METODO")	;AADD(aCampos,{"METODO"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_TIPO")	;AADD(aCampos,{"TIPO"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_UNIMED")	;AADD(aCampos,{"UNIMED"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_NOMINA")	;AADD(aCampos,{"NOMINA"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_LIE")		;AADD(aCampos,{"LIE"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_LSE")		;AADD(aCampos,{"LSE"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_NIVEL")	;AADD(aCampos,{"NIVEL"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_LABOR")	;AADD(aCampos,{"LABOR"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_SEQLAB")	;AADD(aCampos,{"SEQLAB"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_MINMAX")	;AADD(aCampos,{"MINMAX"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP8_TEXTO")	;AADD(aCampos,{"TEXTO"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("C2_VERIFI")	;AADD(aCampos,{"Ok"			,"N",aTam[1],aTam[2]   })
aTam:=TamSX3("QP7_CODREC")	;AADD(aCampos,{"CODREC"		,"C",aTam[1],aTam[2]   })
aTam:=TamSX3("QP7_OPERAC")	;AADD(aCampos,{"OPERAC"		,"C",aTam[1],aTam[2]   })
aTam:=TamSX3("QP7_PLAMO")	;AADD(aCampos,{"PLAMO"		,"C",aTam[1],aTam[2]   })
aTam:=TamSX3("QP7_DESPLA")	;AADD(aCampos,{"DESPLA"		,"C",aTam[1],aTam[2]   })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"PRODUTO"} )
oTempTable:Create()

QP6->(dbSetOrder(1))
QP6->(dbSeek(xFilial("QP6")+mv_par01))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QP6")
dbSetOrder(1)
cCond := "QP6->QP6_FILIAL == '"+xFilial("QP6")+"' .And. QP6->QP6_PRODUT	>= '" + mv_par01 + "'.And. "
cCond += "QP6->QP6_PRODUT	<= '" + mv_par02 + "'"
If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QP6")))
	cCond += " .And QP6->("+oReport:Section(1):GetAdvplExp("QP6")+")"
Endif
cChave := IndexKey()
cNomArq:= CriaTrab("",.F.)
IndRegua("QP6",cNomArq,cChave,,cCond,STR0006)	//"Selecionando Registros...."
nIndex := RetIndex("QP6")
dbSelectArea("QP6")
dbSetOrder(nIndex+1)
oReport:SetMeter(RecCount())
dbGoTop()
While !Eof() .And.	QP6_FILIAL == xFilial("QP6")
	
	If oReport:Cancel()
		Exit
	EndIf
	oReport:IncMeter()	
	
	nRecQP6 := QP6->(Recno())
	If QP6->QP6_REVI <> QA_UltRevEsp(QP6->QP6_PRODUT,IF(!Empty(mv_par11),mv_par11,dDataBase),.F.,,"QIP") 
		dbGoTo(nRecQP6)	
		dbSkip()
		Loop
	EndIf
	aEnsaios := {}

	oSection1:Init()
	oSection1:Cell("QP6_PRODUT"):SetValue(Alltrim(QP6->QP6_PRODUT) + " - " + QP6->QP6_REVI)
	oSection1:Cell("QP6_DESCPO"):SetValue(QP6->QP6_DESCPO)
	If !Empty(mv_par09)
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+mv_par09+mv_par10)
			oSection1:Cell("A7_CLIENTE"):Enable()
			oSection1:Cell("A7_CLIENTE"):SetValue(mv_par09 + " / " + mv_par10 + " - " + SA1->A1_NOME)
		EndIf
	Else
		oSection1:Cell("A7_CLIENTE"):Disable()
		oSection1:Cell("A7_CLIENTE"):SetValue(Space(5))
	EndIf
	oSection1:Cell("QP6_APLIC"):SetValue(QP6->QP6_APLIC)
	oSection1:Cell("QP6_CROQUI"):SetValue(QP6->QP6_CROQUI)
	oSection1:Cell("cDatas"):SetValue(DTOC(QP6->QP6_DTCAD)+" "+DTOC(QP6->QP6_DTDES)+" "+QP6->QP6_RVDES)
	oSection1:Cell("QP6_DTINI"):SetValue(QP6->QP6_DTINI)
	oSection1:Cell("QP6_DOCOBR"):SetValue(QP6->QP6_APLIC)
	If !Empty(QP6->QP6_DOCOBR)
		If QP6->QP6_DOCOBR=="S"
			oSection1:Cell("QP6_DOCOBR"):SetValue(OemToAnsi(STR0008))  //"Sim"
		Else	
			oSection1:Cell("QP6_DOCOBR"):SetValue(OemToAnsi(STR0009))  //"Nao"
		EndIf	
	Else
		oSection1:Cell("QP6_DOCOBR"):SetValue(Space(3)) 
	EndIF
	oSection1:PrintLine()
	oSection1:Finish()
	oReport:SkipLine()    

	cRoteiro	:= ""
	cOperac		:= ""
	dbSelectArea("QQK")
	dbSetOrder(1)
	dbSeek(xFilial("QQK")+QP6->QP6_PRODUT)
	While !Eof() .And. QQK_FILIAL 	== xFilial("QQK") .And. ;
		QQK_PRODUTO	== QP6->QP6_PRODUT
		
		If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QQK")))
			If !QQK->(&(oReport:Section(1):GetAdvplExp("QQK")))
				DbSkip()
				Loop
			Endif
		EndIf
		If QQK_CODIGO < mv_par03 .Or. QQK_CODIGO > mv_par04	
			dbSkip()
			Loop
		EndIf
		
		If 	QQK_OPERAC	< mv_par05	.Or.	QQK_OPERAC	> mv_par06
			dbSkip()
			Loop
		EndIf
		
		If QQK_REVIPRD	<> QP6->QP6_REVI
			dbSkip()
			Loop
		EndIf

		oSection2:Init()
		oSection2:Cell("CODREC"):SetValue(QQK->QQK_CODIGO)	
		oSection2:Cell("QP7_OPERAC"):SetValue(QQK->QQK_OPERAC + " - " + QQK->QQK_DESCRI)
		oSection2:PrintLine()		
        oSection2:Finish()
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria temporario com os ensaios do Produto					  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QP030GTrb(QP6->QP6_PRODUT,QP6->QP6_REVI,QQK->QQK_CODIGO,QQK->QQK_OPERAC,cArqTrb)
        lImpEns := .F.
        
		dbSelectArea("TRB")
		dbGoTop()
		While !EOF()
	        lImpEns := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe a amarracao do Produto x Cliente - QQ7     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(mv_par09)
				QQ7->(dbSetOrder(1))
				If 	!QQ7->(dbSeek(xFilial("QQ7")+ TRB->PRODUTO + mv_par09 + mv_par10 + ;
					TRB->LABOR + TRB->ENSAIO + TRB->CODREC + TRB->OPERAC))
					TRB->(dbSkip())
					Loop
				EndIf
			EndIf
			If cRoteiro <> QQK->QQK_CODIGO .Or. cOperac <> QQK->QQK_OPERAC  
	
				cRoteiro	:= QQK->QQK_CODIGO
				cOperac		:= QQK->QQK_OPERAC
	
				oSection3:Finish()
				oSection3:Init()
			EndIf

			QP7->(DBSetOrder(1))
			QP7->(DBSeek( xFilial("QP7") + TRB->PRODUTO + TRB->REVI + cRoteiro + cOperac + TRB->ENSAIO))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados dos ensaios 						   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QP1")
			IF dbSeek(xFilial("QP1")+TRB->ENSAIO)
				cDescEns := Substr(QP1->QP1_DESCPO,1,30)
				cTipoEns := QP1->QP1_TPCART
			EndIf

			If !Empty(TRB->DESPLA)
				Aadd(aEnsaios,{TRB->ENSAIO,cTipoEns,TRB->PLAMO,TRB->DESPLA})
			EndIf  
			
			oSection3:Cell("QP7_ENSAIO"):SetValue(TRB->ENSAIO + " " + cDescEns)
			oSection3:Cell("QP7_LABOR"):SetValue(TRB->LABOR)

			oSection3:Cell("QP7_UNIMED"):Enable()
			oSection3:Cell("QP7_NOMINA"):Enable()
			oSection3:Cell("QP7_LIE"):Enable()
			oSection3:Cell("QP7_LSE"):Enable()
			
			If cTipoEns <> "X"
				SAH->(dbSeek(xFilial("SAH")+TRB->UNIMED))
				oSection3:Cell("QP7_UNIMED"):SetValue(SAH->AH_UMRES)
				oSection3:Cell("QP8_TEXTO"):Disable()
				oSection3:Cell("QP8_TEXTO"):SetValue("")
				oSection3:Cell("QP7_NOMINA"):SetValue(AllTrim(TRB->NOMINA))
				If TRB->MINMAX == "1"
					oSection3:Cell("QP7_LIE"):SetValue(AllTrim(TRB->LIE))
					oSection3:Cell("QP7_LSE"):SetValue(AllTrim(TRB->LSE))
				ElseIf TRB->MINMAX == "2"
					oSection3:Cell("QP7_LIE"):SetValue(AllTrim(TRB->LIE))
					oSection3:Cell("QP7_LSE"):SetValue(">>>")
				ElseIf TRB->MINMAX == "3"
					oSection3:Cell("QP7_LIE"):SetValue("<<<")
					oSection3:Cell("QP7_LSE"):SetValue(AllTrim(TRB->LSE))
				EndIf
			Else
				oSection3:Cell("QP7_UNIMED"):Disable()
				oSection3:Cell("QP8_TEXTO"):Enable()
				oSection3:Cell("QP8_TEXTO"):SetValue(TRB->TEXTO)
				oSection3:Cell("QP7_NOMINA"):Disable()
				oSection3:Cell("QP7_LIE"):Disable()
				oSection3:Cell("QP7_LSE"):Disable()
			EndIf	
			oSection3:Cell("QP7_PLAMO"):SetValue(TRB->PLAMO)
			If !Empty(TRB->NIVEL)
				oSection3:Cell("QP7_NIVEL"):SetValue(Substr(TABELA("Q6",TRB->NIVEL),1,10))
			Else
				oSection3:Cell("QP7_NIVEL"):SetValue(Space(10))
			Endif
			oSection3:Cell("cGrpPrd"):SetValue(IIf(QQK->QQK_OPERGR=="S",STR0019,STR0020))  //"Grp"###"Prd"

			dbSelectArea("QQ1")
			dbSetOrder(1)
			If dbSeek(xFilial("QQ1")+TRB->PRODUTO+TRB->REVI+TRB->OPERAC+TRB->ENSAIO)
				lPrimVez := .T.
				While  !Eof() .And. xFilial("QQ1")==QQ1_FILIAL .And. ;
					QQ1->QQ1_PRODUT	== TRB->PRODUTO	.And.	;
					QQ1->QQ1_REVI	== TRB->REVI 	.And.	;
					QQ1->QQ1_OPERAC	== TRB->OPERAC	.And.	;
					QQ1->QQ1_ENSAIO	== TRB->ENSAIO
					If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QQ1")))
						If !QQ1->(&(oReport:Section(1):GetAdvplExp("QQ1")))
							dbSkip()
							Loop
						Endif
					EndIf

					If QQ1->QQ1_ROTEIR == TRB->CODREC
						oSection3:Cell("QQ1_INSTR"):SetValue(QQ1->QQ1_INSTR)
						oSection3:PrintLine()
							
						If lPrimVez
							oSection3:Cell("QP7_ENSAIO"):HIDE()
							oSection3:Cell("QP7_LABOR"):HIDE()
							oSection3:Cell("QP7_UNIMED"):HIDE()
							oSection3:Cell("QP7_NOMINA"):HIDE()
							oSection3:Cell("QP7_LIE"):HIDE()
							oSection3:Cell("QP7_LSE"):HIDE()
							oSection3:Cell("QP8_TEXTO"):HIDE()
							oSection3:Cell("QP7_PLAMO"):HIDE()
							oSection3:Cell("QP7_NIVEL"):HIDE()
							oSection3:Cell("cGrpPrd"):HIDE()
							
							lPrimVez := .F.
						EndIf
					EndIf
					
					dbSkip()
				EndDo
			Else
				oSection3:Cell("QQ1_INSTR"):SetValue("")
				oSection3:PrintLine()
			EndIf
			
			oSection3:Cell("QP7_ENSAIO"):SHOW()
			oSection3:Cell("QP7_LABOR"):SHOW()
			oSection3:Cell("QP7_UNIMED"):SHOW()
			oSection3:Cell("QP7_NOMINA"):SHOW()
			oSection3:Cell("QP7_LIE"):SHOW()
			oSection3:Cell("QP7_LSE"):SHOW()
			oSection3:Cell("QP8_TEXTO"):SHOW()
			oSection3:Cell("QP7_PLAMO"):SHOW()
			oSection3:Cell("QP7_NIVEL"):SHOW()
			oSection3:Cell("cGrpPrd"):SHOW() 
			
			
			dbSelectArea("TRB")	
			dbSkip()
		
		EndDo
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cabecalho do Plano de Amostragem³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aEnsaios) > 0	
			oSection4:init()	
			For nC := 1 To Len(aEnsaios)
				oSection4:Cell("cEnsPla"):SetValue(aEnsaios[nC,1])
				oSection4:Cell("cCodPla"):SetValue(aEnsaios[nC,3])
				oSection4:Cell("cPlano"):SetValue(aEnsaios[nC,4])
				oSection4:PrintLine()	
			Next nC
			oSection4:Finish()
		EndIf
		aEnsaios:={}
		
		//Imprime observacoes
		If lImpEns
			If mv_par08 == 1 
				cTxtObs := QA_RecTxt(QQK->QQK_CHAVE,cEspecie,00,,"QA2",{})
				If !Empty(cTxtObs)
					oSection5:init()	
					oSection5:Cell("Observacao"):SetValue(cTxtObs)  
					oSection5:PrintLine()
					oSection5:Finish()
				EndIf
			Endif
		EndIf
		dbSelectArea("QQK")
		dbSkip()
	EndDo
	dbSelectArea("QP6")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QP6")
RetIndex("QP6")
DbSetOrder(2)
Set Filter To
oTempTable:Delete()
dbSetOrder( 1 )
Ferase(cArqTrb+GetDBExtension())
Ferase(cArqTrb+OrdBagExt())

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIPR030	³ Autor ³ Marcelo Pimentel      ³ Data ³ 08.06.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Plano de Conferencia				     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ QIPR030()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Siga Quality - Celerina                            		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Pim.³26/03/01³------³Inclusao da impressao grafica no relatorio³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QIPR030R3()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Par„metros para a fun‡„o SetPrint () ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel 	:="QIPR030"
LOCAL cString	:="QP6"
LOCAL cDesc1	:=STR0001 //"Neste relat¢rio ser„o relacionados os produtos ao roteiro de opera‡Æo e "
LOCAL cDesc2	:=STR0002 //"ensaios respectivamente."
LOCAL cDesc3	:=""

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Par„metros para a fun‡„o Cabec()  ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cTitulo	:= OemToAnsi(STR0003)	//"Plano de Conferencia"
PRIVATE cRelatorio:= "QIPR030"
PRIVATE nTamanho	:= "M"
PRIVATE nPagina	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas pela fun‡„o SetDefault () ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn	:= {STR0004, 1,STR0005,  1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nLastKey	:= 0 , cPerg := "QPR030"                     

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros							  ³
//³ mv_par01			  // Do Produto								  ³
//³ mv_par02			  // At‚ Produto        					  ³
//³ mv_par03			  // Do Roteiro       						  ³
//³ mv_par04			  // At‚ Roteiro   							  ³
//³ mv_par05			  // Da Operacao     						  ³
//³ mv_par06			  // At‚ Operacao     						  ³
//³ mv_par07			  // Imprime roteiro sem ensaios associados?  ³	
//³ mv_par08			  // Imprime Observacao ?                     ³
//³ mv_par09			  // Cliente ?                    			  ³
//³ mv_par10			  // Loja ?                     			  ³
//³ mv_par11			  // Data de Vigencia                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT 					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,nTamanho)

If nLastKey = 27
	Set Filter To
	Return
EndIf
		
SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return 
EndIf
	
RptStatus({|lEnd| R030Imp(@lEnd,wnRel,cString)},cTitulo)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ R030Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³08/06/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relatorio.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIPR030                                         			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R030Imp(lEnd,wnrel,cString)
LOCAL cTipoEns
LOCAL nIndex
LOCAL CbCont
LOCAL cDescEns 	:= Space(30)
LOCAL aTexto		:= {}
LOCAL aEnsaios 	:= {}
LOCAL cCond			:= ""
LOCAL cNomArq 		:= ""
LOCAL nContLi		:= 0
LOCAL nRecQP6		:= 0
LOCAL cEspecie		:= "QIPA010 "
LOCAL cRoteiro		:= ""
Local cArqTrb		:=	CriaTrab("",.F.)
Local aTam			:= {}
Local aCampos		:= {}
Local nC            := 0
Local lImpEns       := .F.

Private Titulo 	 := cTitulo
Private Cabec1 	 := ""
Private Cabec2	 := ""
Private	nomeprog := "QIPR030"
Private cTamanho := "M"
Private nTipo	 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li 		:= 80
m_pag 	:= 1
cbtxt		:= Space(10)
cbcont	:= 00
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho para ordenar os ensaios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("QP6_PRODUT")	;AADD(aCampos,{"PRODUTO"	,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP6_REVI")	;AADD(aCampos,{"REVI"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_ENSAIO")	;AADD(aCampos,{"ENSAIO"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_METODO")	;AADD(aCampos,{"METODO"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_TIPO")	;AADD(aCampos,{"TIPO"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_UNIMED")	;AADD(aCampos,{"UNIMED"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_NOMINA")	;AADD(aCampos,{"NOMINA"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_LIE")		;AADD(aCampos,{"LIE"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_LSE")		;AADD(aCampos,{"LSE"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_NIVEL")	;AADD(aCampos,{"NIVEL"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_LABOR")	;AADD(aCampos,{"LABOR"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_SEQLAB")	;AADD(aCampos,{"SEQLAB"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP7_MINMAX")	;AADD(aCampos,{"MINMAX"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("QP8_TEXTO")	;AADD(aCampos,{"TEXTO"		,"C",aTam[1],aTam[2]	})
aTam:=TamSX3("C2_VERIFI")	;AADD(aCampos,{"Ok"			,"N",aTam[1],aTam[2]   })
aTam:=TamSX3("QP7_CODREC")	;AADD(aCampos,{"CODREC"		,"C",aTam[1],aTam[2]   })
aTam:=TamSX3("QP7_OPERAC")	;AADD(aCampos,{"OPERAC"		,"C",aTam[1],aTam[2]   })
aTam:=TamSX3("QP7_PLAMO")	;AADD(aCampos,{"PLAMO"		,"C",aTam[1],aTam[2]   })
aTam:=TamSX3("QP7_DESPLA")	;AADD(aCampos,{"DESPLA"		,"C",aTam[1],aTam[2]   })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"PRODUTO"} )
oTempTable:Create()

QP6->(dbSetOrder(1))
QP6->(dbSeek(xFilial("QP6")+mv_par01))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QP6")
dbSetOrder(1)
cCond := "QP6->QP6_FILIAL == '"+xFilial("QP6")+"' .And. QP6->QP6_PRODUT	>= '" + mv_par01 + "'.And. "
cCond += "QP6->QP6_PRODUT	<= '" + mv_par02 + "'"
cChave := IndexKey()
cNomArq:= CriaTrab("",.F.)
IndRegua("QP6",cNomArq,cChave,,cCond,STR0006)	//"Selecionando Registros...."
nIndex := RetIndex("QP6")
dbSelectArea("QP6")
dbSetOrder(nIndex+1)
SetRegua(RecCount())
dbGoTop()
While !Eof() .And.	QP6_FILIAL == xFilial("QP6")
	
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0007)  //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIF
	nRecQP6 := QP6->(Recno())
	If QP6->QP6_REVI <> QA_UltRevEsp(QP6->QP6_PRODUT,IF(!Empty(mv_par11),mv_par11,dDataBase),.F.,,"QIP") 
		dbGoTo(nRecQP6)	
		dbSkip()
		Loop
	EndIf
	IncRegua()
	aEnsaios := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ‚ nova pagina 									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados do Produto 											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ Li,001 PSAY AllTrim(TitSX3("QP6_PRODUT")[1])+" - "+;
	AllTrim(TitSX3("QP6_REVI")[1])+Replicate(".",38-(len(Alltrim(TitSx3("QP6_PRODUT")[1]))+;
	len(Alltrim(TitSx3("QP6_REVI")[1]))))+":"
	@ Li,044 PSAY QP6->QP6_PRODUT + " - " + QP6->QP6_REVI
	Li++
	@ Li,001 PSAY AllTrim(TitSX3("QP6_DESCPO")[1])+;
	REPLICATE(".",41-Len(AllTrim(TitSX3("QP6_DESCPO")[1])))+":"
	@ Li,044 PSAY QP6->QP6_DESCPO
	Li++
	
	If !Empty(mv_par09)
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+mv_par09+mv_par10)
			@Li,01 PSAY AllTrim(TitSX3("A7_CLIENTE")[1])+Replicate(".",41-Len(AllTrim(TitSX3("A7_CLIENTE")[1])))+":"
			@Li,44 PSAY mv_par09 + " / " + mv_par10 + " - " + SA1->A1_NOME
			Li++
		EndIf
	EndIf
	
	@ Li, 001 PSAY AllTrim(TitSX3("QP6_APLIC")[1])+Replicate(".",41-Len(AllTrim(TitSX3("QP6_APLIC")[1])))+":"
	@ Li, 044 PSAY QP6->QP6_APLIC
	Li++
	@ Li, 001 PSAY AllTrim(TitSX3("QP6_CROQUI")[1])+Replicate(".",41-Len(AllTrim(TitSX3("QP6_CROQUI")[1])))+":"
	@ Li, 044 PSAY QP6->QP6_CROQUI
	Li++
	@ Li, 001 PSAY AllTrim(TitSX3("QP6_DTCAD")[1])+"/"+AllTrim(TitSX3("QP6_DTDES")[1])+"/"+AllTrim(TitSX3("QP6_RVDES")[1])+"...:"
	@ Li, 044 PSAY QP6->QP6_DTCAD
	@ Li, 057 PSAY QP6->QP6_DTDES
	@ Li, 070 PSAY QP6->QP6_RVDES
	Li++
	@ Li, 001 PSAY AllTrim(TitSX3("QP6_DTINI")[1])+Replicate(".",41-Len(AllTrim(TitSX3("QP6_DTINI")[1])))+":"
	@ Li, 044 PSAY QP6->QP6_DTINI
	If !Empty(QP6->QP6_DOCOBR)
		Li++
		@ Li, 001 PSAY AllTrim(TitSX3("QP6_DOCOBR")[1])+Replicate(".",41-Len(AllTrim(TitSX3("QP6_DOCOBR")[1])))+":"
		@ Li, 044 PSAY Iif(QP6->QP6_DOCOBR=="S",OemToAnsi(STR0008),;   // "Sim"
		OemToAnsi(STR0009))	// "Nao"
	EndIf
	Li+= 2

	cRoteiro	:= ""
	cOperac		:= ""
	dbSelectArea("QQK")
	dbSetOrder(1)
	dbSeek(xFilial("QQK")+QP6->QP6_PRODUT)
	While !Eof() .And. QQK_FILIAL 	== xFilial("QQK") .And. ;
		QQK_PRODUTO	== QP6->QP6_PRODUT
		
		If QQK_CODIGO < mv_par03 .Or. QQK_CODIGO > mv_par04	
			dbSkip()
			Loop
		EndIf
		
		If 	QQK_OPERAC	< mv_par05	.Or.	QQK_OPERAC	> mv_par06
			dbSkip()
			Loop
		EndIf
		
		If QQK_REVIPRD	<> QP6->QP6_REVI
			dbSkip()
			Loop
		EndIf

		@ Li, 000 PSAY STR0022+ QQK->QQK_CODIGO		//"ROTEIRO  ==> "
		Li++
		If Li > 55
			Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo)
		Endif
		@ Li, 000 PSAY STR0010 + QQK->QQK_OPERAC + " - " + QQK->QQK_DESCRI		//"OPERACAO ==> "
		Li++
		@ Li, 000 PSAY Replicate("=",132)
		Li++
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria temporario com os ensaios do Produto					  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QP030GTrb(QP6->QP6_PRODUT,QP6->QP6_REVI,QQK->QQK_CODIGO,QQK->QQK_OPERAC,cArqTrb)
        lImpEns := .F.
        
		dbSelectArea("TRB")
		dbGoTop()
		SetRegua(RecCount())
		While !EOF()
			IncRegua()
	        lImpEns := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe a amarracao do Produto x Cliente - QQ7     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(mv_par09)
				QQ7->(dbSetOrder(1))
				If 	!QQ7->(dbSeek(xFilial("QQ7")+ TRB->PRODUTO + mv_par09 + mv_par10 + ;
					TRB->LABOR + TRB->ENSAIO + TRB->CODREC + TRB->OPERAC))
					TRB->(dbSkip())
					Loop
				EndIf
			EndIf

			If Li > 55
				Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo)
			Endif

			If cRoteiro <> QQK->QQK_CODIGO .Or. cOperac <> QQK->QQK_OPERAC  
	
				cRoteiro	:= QQK->QQK_CODIGO
				cOperac		:= QQK->QQK_OPERAC
	
				@ Li, 000 PSAY TitSX3("QP7_ENSAIO")[1]
				@ Li, 040 PSAY STR0011		//"Labor."	
				@ Li, 048 PSAY STR0012		//"Un. Med."
				@ Li, 059 PSAY STR0013		//"Nominal"
				@ Li, 069 PSAY STR0014		//"L.I.E."
				@ Li, 079 PSAY STR0015		//"L.S.E."
				@ Li, 088 PSAY STR0016		//"Pl "
				@ Li, 091 PSAY TitSX3("QP7_NIVEL")[1]
				@ Li, 104 PSAY STR0018		//"Grp/Prd"
				@ Li, 112 PSAY TitSX3("QQ1_INSTR")[1]
				Li++
				@ Li, 000 PSAY Replicate("=",132)
				Li++
			EndIf

			IncRegua()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados dos ensaios 						   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QP1")
			IF dbSeek(xFilial("QP1")+TRB->ENSAIO)
				cDescEns := Substr(QP1->QP1_DESCPO,1,30)
				cTipoEns := QP1->QP1_TPCART
			EndIf

			If !Empty(TRB->DESPLA)
				Aadd(aEnsaios,{TRB->ENSAIO,cTipoEns,TRB->PLAMO,TRB->DESPLA})
			EndIf
			@ Li, 000 PSAY TRB->ENSAIO + " " + cDescEns
			@ Li, 040 PSAY TRB->LABOR
			
			If cTipoEns <> "X"
				SAH->(dbSeek(xFilial("SAH")+TRB->UNIMED))
				@ Li, 048 PSAY SAH->AH_UMRES
				@ Li, 059 PSAY AllTrim(TRB->NOMINA)
				If TRB->MINMAX == "1"
					@ Li, 069 PSAY AllTrim(TRB->LIE)
					@ Li, 079 PSAY AllTrim(TRB->LSE)
				ElseIf TRB->MINMAX == "2"
					@ Li, 069 PSAY AllTrim(TRB->LIE)
					@ Li, 080 PSAY ">>>"
				ElseIf TRB->MINMAX == "3"
					@ Li, 070 PSAY "<<<"
					@ Li, 079 PSAY AllTrim(TRB->LSE)
				EndIf
			Else
				aTexto := {}
				Aadd(aTexto,Left(TRB->TEXTO,34))
				Aadd(aTexto,Subs(TRB->TEXTO,35,34))
				Aadd(aTexto,Subs(TRB->TEXTO,69))
				@ Li, 48 PSAY aTexto[1]
			EndIf	
			@ Li, 088 PSAY TRB->PLAMO
			If !Empty(TRB->NIVEL)    
				@ Li, 091 PSAY Substr(TABELA("Q6",TRB->NIVEL),1,10)
			Endif
			@ Li,104 PSAY If(QQK->QQK_OPERGR=="S",STR0019,STR0020)		//"Grp"###"Prd"

			dbSelectArea("QQ1")
			dbSetOrder(1)
			If dbSeek(xFilial("QQ1")+TRB->PRODUTO+TRB->REVI+TRB->OPERAC+TRB->ENSAIO)
				While  !Eof() .And. xFilial("QQ1")==QQ1_FILIAL .And. ;
					QQ1->QQ1_PRODUT	== TRB->PRODUTO	.And.	;
					QQ1->QQ1_REVI	== TRB->REVI 	.And.	;
					QQ1->QQ1_OPERAC	== TRB->OPERAC	.And.	;
					QQ1->QQ1_ENSAIO	== TRB->ENSAIO

					If QQ1->QQ1_ROTEIR == TRB->CODREC
						If cTipoEns == "X"
							nContLi++
							If !Empty(aTexto[2]) .And. nContLi==2
								@ Li,48 PSAY aTexto[2]
							ElseIf !Empty(aTexto[3]) .And. nContLi==3
								@ Li,48 PSAY aTexto[3]
							EndIf
						EndIf
						@Li, 117 PSAY QQ1->QQ1_INSTR
						Li++
					EndIf
					
					dbSkip()
				EndDo
			Else
				Li++
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime restante do aTexto 									 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTipoEns == "X" .And. nContLi < 2
				If !Empty (aTexto[2])
					@ Li, 048 PSAY aTexto[2]
					Li++
				EndIf
				If !Empty (aTexto[3])
					@ Li, 048 PSAY aTexto[3]
					Li++
				Endif
			EndIf
			aTexto 	:= {}
			nContLi	:= 0
		
			dbSelectArea("TRB")	
			dbSkip()
			If Li > 55
				Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo)
			Endif
		EndDo
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cabecalho do Plano de Amostragem³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aEnsaios) > 0	
			Li+=2
			@ Li, 000 PSAY AllTrim(TitSX3("QP7_ENSAIO")[1])
			@ Li, 009 PSAY STR0021		//"Plano de Amostragem"
			Li++
			@ Li, 000 PSAY Replicate("-",132)
			Li++
			If Li > 55
				Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo)
			Endif
			For nC := 1 To Len(aEnsaios)
				@ Li,000 PSAY aEnsaios[nC,1]
				@ Li,009 PSAY aEnsaios[nC,3]
				@ Li,011 PSAY Subs(aEnsaios[nC,4],1,110)
				Li++
				If Li > 55
					Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo)
				Endif
			Next
			aEnsaios:={}
			@ Li, 000 PSAY Replicate("-",132)
			Li++
			//Imprime observacoes
		EndIf
		aEnsaios:={}
		Li++
		//Imprime observacoes
		If lImpEns
			If mv_par08 == 1 
				Li++
				@ Li, 000 PSAY STR0023	//"Observacoes :"
				Li++
				//A impressao dessa observacao utilizada impressao justificada e foi alterada pelo Bops 85010
				dbSelectArea("QA2")
				dbSetOrder(1)
				If dbSeek(xFilial("QA2")+cEspecie+QQK->QQK_CHAVE)
					While ( !Eof() .And. QA2_FILIAL+QA2_ESPEC+QA2_CHAVE == ;
						xFilial("QA2")+cEspecie+QQK->QQK_CHAVE)
						@Li,000 PSAY StrTran(QA2_TEXTO, "\13\10", "")
						Li++
						If Li > 55
							Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo)
						Endif	
						dbSkip()
					EndDo
				EndIf
				@ Li, 000 PSAY Replicate("-",132)
				Li++
			Endif
			Li+=2
		EndIf
		dbSelectArea("QQK")
		dbSkip()
	EndDo
	dbSelectArea("QP6")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QP6")
RetIndex("QP6")
DbSetOrder(2)
Set Filter To
Ferase(cNomArq+OrdBagExt())
dbSetOrder( 1 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga os arquivos de trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbCloseArea()
Ferase(cArqTrb+GetDBExtension())
Ferase(cArqTrb+OrdBagExt())

If Li != 80
	roda(CbCont,cbtxt,"M")
EndIf

Set device to Screen

If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QP030GTrb ³ Autor ³ Marcelo Pimentel      ³ Data ³09/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera o arquivo de trabalho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Produto                                             ³±±
±±³          ³ExpC2 - Revisao                                             ³±±
±±³          ³ExpC3 - Arquivo de Trabalho                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QIPR030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FuncTion QP030GTrb(cProd,cRevi,cCodRec,cOperac,cArqTrb)

// Limpa arquivo trabalho
dbSelectArea("TRB")
Zap

// Monta ensaios do Produto atual	
dbSelectArea("QP7")
dbSetOrder(1)
If dbSeek(xFilial("QP7")+cProd+cRevi+cCodRec+cOperac)
	While !Eof() .And. xFilial("QP7") == QP7->QP7_FILIAL .And.;
		QP7->QP7_PRODUT+QP7->QP7_REVI+QP7->QP7_CODREC+QP7->QP7_OPERAC == cProd+cRevi+cCodRec+cOperac
		
		RecLock("TRB",.T.)
		PRODUTO	:= QP7->QP7_PRODUT
		REVI	:= QP7->QP7_REVI
		ENSAIO	:= QP7->QP7_ENSAIO
		METODO	:= QP7->QP7_METODO
		TIPO	:= QP7->QP7_TIPO
		UNIMED	:= QP7->QP7_UNIMED
		NOMINA	:= QP7->QP7_NOMINA
		LIE		:= QP7->QP7_LIE
		LSE		:= QP7->QP7_LSE
		NIVEL	:= QP7->QP7_NIVEL
		LABOR	:= QP7->QP7_LABOR
		SEQLAB	:= QP7->QP7_SEQLAB
		MINMAX	:= QP7->QP7_MINMAX
		CODREC	:= QP7->QP7_CODREC
		OPERAC	:= QP7->QP7_OPERAC
		PLAMO	:= QP7->QP7_PLAMO
		DESPLA	:= QP7->QP7_DESPLA
		MsUnlock()
		dbSelectArea("QP7")
		dbSkip()
	EndDo
Endif

dbSelectArea("QP8")
dbSetOrder(1)
If dbSeek(xFilial("QP8")+cProd+cRevi+cCodRec+cOperac)
	While !Eof() .And. xFilial("QP8") == QP8->QP8_FILIAL .And.;
		QP8->QP8_PRODUTO+QP8->QP8_REVI+QP8->QP8_CODREC+QP8->QP8_OPERAC == cProd+cRevi+cCodRec+cOperac
		RecLock("TRB",.T.)
		PRODUTO	:= QP8->QP8_PRODUTO
		REVI	:= QP8->QP8_REVI
		ENSAIO	:= QP8->QP8_ENSAIO
		METODO	:= QP8->QP8_METODO
		TIPO	:= QP8->QP8_TIPO
		TEXTO	:= QP8->QP8_TEXTO
		NIVEL	:= QP8->QP8_NIVEL
		LABOR	:= QP8->QP8_LABOR
		SEQLAB	:= QP8->QP8_SEQLAB
		CODREC	:= QP8->QP8_CODREC
		OPERAC	:= QP8->QP8_OPERAC
		PLAMO	:= QP8->QP8_PLAMO
		DESPLA	:= QP8->QP8_DESPLA
		MsUnlock()
		dbSelectArea("QP8")
		dbSkip()
	Enddo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Organiza o arquivo de trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//IndRegua("TRB",cArqTrb,"PRODUTO+REVI+LABOR+SEQLAB",,,STR0006)	//"Selecionando Registros...."
Return Nil
