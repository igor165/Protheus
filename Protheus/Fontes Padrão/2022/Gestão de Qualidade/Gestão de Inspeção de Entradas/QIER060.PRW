
#Include "Qier060.ch"
#Include "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIER060  ³ Autor ³ Cleber Souza          ³ Data ³ 11/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lead-Time (Modelo R4)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIER060()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQie                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIER060()

Local oReport	
Private cAliasQEK  :="QEK"

oReport := ReportDef()
oReport:PrintDialog()  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³Cleber Souza        º Data ³  14/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de definição das Sections 				          º±±
±±º          ³ (Relatorio Personalizado)                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIER060                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local cPrograma  :="QIER060"
Local cDesc1     :=STR0001	//"Neste relat¢rio ser„o impressos os lead-times referentes …s Entradas"
Local cDesc2     :=STR0002	//"dos Produtos/Fornecedores."
Local cTitulo    :=STR0003  //Lead Time    
Local cPerg      :="QER060"  
Local nSizeFor   := TamSx3("QEK_FORNEC")[1]+TamSx3("QEK_LOJFOR")[1]+TamSx3("A2_NOME")[1]
Local nSizePro   := TamSx3("QEK_PRODUT")[1]+TamSx3("QE6_DESCPO")[1]
Local nSizeDH    := TamSx3("QEK_DTENTR")[1]+TamSx3("QEK_HRENTR")[1]+4

DEFINE REPORT oReport NAME cPrograma TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)
oReport:SetLandscape(.F.) 

DEFINE SECTION oSection1 OF oReport TABLES "QEK" TITLE  TITSX3("QEK_FORNEC")[1]
DEFINE CELL NAME "QEK_FORNEC"     OF oSection1 ALIAS "QEK" BLOCK {|| Alltrim(&((cAliasQEK)+"->QEK_FORNEC"))+"/"+Alltrim(&((cAliasQEK)+"->QEK_LOJFOR"))+" - "+ ;
(IIF(&((cAliasQEK)+"->QEK_TIPONF")=='N',POSICIONE("SA2",1,xFilial("SA2")+&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR"),"A2_NOME"),POSICIONE("SA1",1,xFilial("SA1")+&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR"),"A1_NOME")))} SIZE nSizeFor
DEFINE CELL NAME "QEK_PRODUT"     OF oSection1 ALIAS "QEK" BLOCK {|| Alltrim(&((cAliasQEK)+"->QEK_PRODUT"))+" - "+POSICIONE("QE6",3,xFilial("QE6")+&((cAliasQEK)+"->QEK_PRODUT")+&((cAliasQEK)+"->QEK_REVI"),"QE6_DESCPO")} SIZE nSizePro

DEFINE SECTION oSection2 OF oSection1 TABLES "QEK","QEL" TITLE TITSX3("QEL_LABOR")[1]
DEFINE CELL NAME "QEK_DTENTR"     OF oSection2 ALIAS "QEK" BLOCK {|| DTOC(&((cAliasQEK)+"->QEK_DTENTR"))+" - "+&((cAliasQEK)+"->QEK_HRENTR") } SIZE nSizeDH
DEFINE CELL NAME "QEK_LOTE"       OF oSection2 ALIAS "QEK" BLOCK{|| &((cAliasQEK)+"->QEK_LOTE")}
DEFINE CELL NAME "QEL_LABOR"      OF oSection2 ALIAS "QEL" BLOCK {|| QEL->QEL_LABOR }
DEFINE CELL NAME "QEL_DTENLA"     OF oSection2 ALIAS "QEL" BLOCK {|| IIf(!Empty(QEL->QEL_DTENLA),Dtoc(QEL->QEL_DTENLA) +"-"+QEL->QEL_HRENLA,"-.-") } SIZE nSizeDH
DEFINE CELL NAME "QEL_DTLAUD"     OF oSection2 ALIAS "QEL" BLOCK {|| IIf(!Empty(QEL->QEL_DTLAUD),Dtoc(QEL->QEL_DTLAUD) +"-"+QEL->QEL_HRLAUD,"-.-") } SIZE nSizeDH
DEFINE CELL NAME "QEL_DTDILA"     OF oSection2 ALIAS "QEL" BLOCK {|| IIf(!Empty(QEL->QEL_DTDILA),Dtoc(QEL->QEL_DTDILA) +"-"+QEL->QEL_HRDILA,"-.-") } SIZE nSizeDH
DEFINE CELL NAME "cLtTrans"       OF oSection2 ALIAS NIL TITLE STR0014    	SIZE TamSx3("QEL_HRDILA")[1] +2  //"Lt.Trans"   
DEFINE CELL NAME "cLtLaudo"       OF oSection2 ALIAS NIL TITLE STR0015    	SIZE TamSx3("QEL_HRDILA")[1] +1  //"Lt.Laudo"    
DEFINE CELL NAME "cLtTotal"       OF oSection2 ALIAS NIL TITLE STR0016    	SIZE TamSx3("QEL_HRDILA")[1] +1  //"Lt.Total"
DEFINE CELL NAME "cLtDisp"        OF oSection2 ALIAS NIL TITLE STR0017    	SIZE TamSx3("QEL_HRDILA")[1] +1  //"Lt.Disp."
DEFINE CELL NAME "cLeadTime"      OF oSection2 ALIAS NIL TITLE STR0003    	SIZE TamSx3("QEL_HRDILA")[1] +1  //"Lead-Time"

DEFINE SECTION oSection3 OF oReport TABLES "QEK" TITLE STR0019
DEFINE CELL NAME "GERAL"           OF oSection3 ALIAS NIL TITLE STR0019     SIZE TamSx3("QEL_HRDILA")[1] +1 //"GERAL"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
DEFINE CELL NAME "TRANSITO"        OF oSection3 ALIAS NIL TITLE STR0029     SIZE TamSx3("QEL_HRDILA")[1] +1 //"TOTAL TRANSITO"
DEFINE CELL NAME "LAUDO"           OF oSection3 ALIAS NIL TITLE STR0030     SIZE TamSx3("QEL_HRDILA")[1] +1 //"TOTAL LAUDO"
DEFINE CELL NAME "TOTAL"           OF oSection3 ALIAS NIL TITLE STR0031     SIZE TamSx3("QEL_HRDILA")[1] +1 //"TOTAL GERAL"
DEFINE CELL NAME "LABORATORIO"     OF oSection3 ALIAS NIL TITLE STR0032    	SIZE TamSx3("QEL_HRDILA")[1] +1 //"TOTAL LABORATORIO"
DEFINE CELL NAME "DISPONIBILIDADE" OF oSection3 ALIAS NIL TITLE STR0033		SIZE TamSx3("QEL_HRDILA")[1] +1 //"TOTAL DISPONIBILIDADE"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReport ºAutor  ³Cleber Souza      º Data ³  14/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de processamento do relatorio de Lead Time          º±±
±±º          ³ (Relatorio Personalizado)                                  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto oReport									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ QIER060                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport)

Local cCondQEK   := ""
Local cPerg      :="QER060"  
Local oSection1  :=oReport:Section(1)
Local oSection2  :=oReport:Section(1):Section(1) 
Local oSection3  :=oReport:Section(2)
Local nDiaUtil   :=0
Local nTotHora   :=0
Local nTTot      :=0
Local nCTot      :=0  
Local nCLaudo    :=0
Local nTLaudo    :=0  
Local aCalcMed   :={}
Local nPos       :=0
Local nTDis      :=0
Local nCDis      :=0 
Local nTTran     :=0
Local nCTran     :=0 
Local cFornec    := ""
Local cLojFor    := ""
Local cProdut    := ""  
Local nTotMed1   := 0
Local nTotMed2   := 0
Local nTotMed3   := 0
Local nTotMed4   := 0
Local nTotMed5   := 0
Local nTLabor    := 0
Local nCLabor    := 0 
Local nC         := 0 
Local lRoda      := .F.
  
Pergunte(cPerg,.F.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona a Origem da Entrada							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    

If mv_par08 == 1                                            
	cCond := "% AND (QEK.QEK_TIPONF = 'N' OR QEK.QEK_TIPONF = ' ') %"
ElseIf mv_par08 == 2
	cCond := "% AND QEK.QEK_TIPONF = 'B' %"
ElseIf mv_par08 == 3          
	cCond := "% AND QEK.QEK_TIPONF = 'D' %"
    EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	MakeSqlExpr(oReport:uParam) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:BeginQuery()	

cAliasQEK := GetNextAlias()  

BeginSql Alias cAliasQEK                   

SELECT QEK.*
 	FROM %table:QEK% QEK 	
	WHERE QEK.QEK_FILIAL = %xFilial:QEK% AND 
		  QEK.QEK_FORNEC BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
		  QEK.QEK_PRODUT BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND
		  QEK.QEK_DTENTR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	      QEK.%notDel%
	      %Exp:cCond%		                
 		ORDER BY QEK.QEK_FORNEC,QEK.QEK_LOJFOR,QEK.QEK_PRODUT,QEK_NTFISC, QEK_SERINF, QEK_ITEMNF, QEK_TIPONF, QEK_DTENTR, QEK_LOTE
EndSql   

oSection1:EndQuery()	
     
While !&(cAliasQEK)->(Eof()) 
    
	oReport:IncMeter()	

	If oReport:Cancel()
		Exit
	EndIf
    
	oReport:PrintText(STR0006+Dtoc(mv_par01)+STR0007+Dtoc(mv_par02),oReport:Row(),010) //"Periodo : "###" a "
	oReport:SkipLine()	
	If mv_par07 == 2
		oReport:PrintText(STR0008,oReport:Row(),010)	//"Entradas em Transito"
		oReport:SkipLine()
	ElseIf mv_par07 == 3
		oReport:PrintText(STR0009,oReport:Row(),010)	//"Entradas em Laboratorio"	
		oReport:SkipLine()
	ElseIf mv_par07 == 4
		oReport:PrintText(STR0010,oReport:Row(),010)	//"Entradas com Laudo"
		oReport:SkipLine()
	EndIf

	oSection2:Cell("cLtTrans"):Hide()   
	oSection2:Cell("cLtLaudo"):Hide() 
	oSection2:Cell("cLtTotal"):Hide() 
	oSection2:Cell("cLtDisp"):Hide() 
	oSection2:Cell("cLeadTime"):Hide() 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona em Registros de outros arquivos                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if QEK->QEK_TIPONF == 'N'
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR")))
	Else
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR")))
	Endif
	QE6->(dbSetOrder(1))
	QE6->(dbSeek(xFilial("QE6")+&((cAliasQEK)+"->QEK_PRODUT")+Inverte(&((cAliasQEK)+"->QEK_REVI"))))
	dbSelectArea("QEK")   
	
	oSection2:Init()
	CabecR4(@oSection2)
	             
    dbSelectArea("QEL")
    dbSetOrder(3)
    If dbSeek(xFilial("QEL")+&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR")+&((cAliasQEK)+"->QEK_PRODUT")+;
			&((cAliasQEK)+"->QEK_NTFISC")+&((cAliasQEK)+"->QEK_SERINF")+&((cAliasQEK)+"->QEK_ITEMNF")+&((cAliasQEK)+"->QEK_TIPONF")+;
    		Dtos(&((cAliasQEK)+"->QEK_DTENTR"))+&((cAliasQEK)+"->QEK_LOTE"))  
    		
    	While !QEL->(Eof()) .And. xFilial("QEL") == QEL->QEL_FILIAL .And. ;
			QEL->QEL_FORNEC+QEL->QEL_LOJFOR+QEL->QEL_PRODUT+QEL->QEL_NISERI+QEK->QEK_TIPONF+Dtos(QEL->QEL_DTENTR)+;
			QEL->QEL_LOTE == +&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR")+&((cAliasQEK)+"->QEK_PRODUT")+;
			&((cAliasQEK)+"->QEK_NTFISC")+&((cAliasQEK)+"->QEK_SERINF")+&((cAliasQEK)+"->QEK_ITEMNF")+&((cAliasQEK)+"->QEK_TIPONF")+;
    		Dtos(&((cAliasQEK)+"->QEK_DTENTR"))+&((cAliasQEK)+"->QEK_LOTE")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Entradas em Laborat¢rio                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par07 == 3
				If Dtos(QEL->QEL_DTENLA) == Space(Len(Dtos(QEL_DTENLA))) .AND.;
			   	   Dtos(QEL_DTLAUD)<>Space(Len(Dtos(QEL_DTLAUD)))
					QEL->(dbSkip())
					Loop
				EndIF	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Com Laudo                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf mv_par07 == 4
				If QEL_LABOR <> Space(Len(QEL_LABOR)) .AND.;
				   Dtos(QEL_DTENLA) == Space(Len(Dtos(QEL_DTENLA))) .AND.;
				   Dtos(QEL_DTLAUD) == Space(Len(Dtos(QEL_DTLAUD)))
					QEL->(dbSkip())
					Loop
            	EndIF
            EndIF

			//Se nao houver Laudo definido
			If Empty(QEL->QEL_LAUDO) .AND. Empty(QEL->QEL_LABOR)
				QEL->(dbSkip())
				Loop
			EndIf 	
        	
        	If mv_par07 == 1
				
                If cFornec+cLojFor+cProdut <>&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR")+&((cAliasQEK)+"->QEK_PRODUT") 
					cFornec := &((cAliasQEK)+"->QEK_FORNEC") 
					cLojFor := &((cAliasQEK)+"->QEK_LOJFOR")
					cProdut := &((cAliasQEK)+"->QEK_PRODUT")
					oSection1:Init()
					oSection1:PrintLine()    
				EndIF
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Todos                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF !Empty(QEL->QEL_DTLAUD)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ C lculo do Lead-Time Laudo                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nDiaUtil:=If(QEL->QEL_DTLAUD <> QEL->QEL_DTENLA,DiaUtil(QEL->QEL_DTENLA,QEL->QEL_DTLAUD),0)
					nTotHora:=Q060CalHor(nDiaUtil,QEL->QEL_HRLAUD,QEL->QEL_HRENLA)
					oSection2:Cell("cLtLaudo"):SetValue(Alltrim(nTotHora))
					oSection2:Cell("cLtLaudo"):Show()
					nTLaudo+=CalcMin(nTotHora)
					nCLaudo++
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula hora p/ Calculo da M‚dia                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SuperVal(nTotHora) > 0
						QEA->(dbSetOrder(1))
						If QEA->(dbSeek(xFilial("QEA")+&((cAliasQEK)+"->QEK_GRUPO")+&((cAliasQEK)+"->QEK_PRODUT")))
							nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO} )
							If nPos <> 0
								aCalcMed[nPos,3] += CalcMin(nTotHora)
								aCalcMed[nPos,9] := aCalcMed[nPos,9]+1
							Else
								Aadd(aCalcMed,{QEK->QEK_GRUPO,0,CalcMin(nTotHora),0,0,0,0,0,1,0,0})
							Endif
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ C lculo do Lead-Time Total                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nDiaUtil:=If(QEL->QEL_DTLAUD <> &((cAliasQEK)+"->QEK_DTENTR"),DiaUtil(&((cAliasQEK)+"->QEK_DTENTR"),QEL->QEL_DTLAUD),0)
					nTotHora:=Q060CalHor(nDiaUtil,QEL->QEL_HRLAUD,&((cAliasQEK)+"->QEK_HRENTR"))
					oSection2:Cell("cLtTotal"):SetValue(Alltrim(nTotHora))
					oSection2:Cell("cLtTotal"):Show()
					nTTot+=CalcMin(nTotHora)
					nCTot++
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula hora p/ Calculo da M‚dia                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SuperVal(nTotHora) > 0				
						QEA->(dbSetOrder(1))
						If QEA->(dbSeek(xFilial("QEA")+&((cAliasQEK)+"->QEK_GRUPO")+&((cAliasQEK)+"->QEK_PRODUT")))
							nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO} )
							If nPos <> 0
								aCalcMed[nPos,4] += CalcMin(nTotHora)
								aCalcMed[nPos,7] := aCalcMed[nPos,7]+1
							Else
								Aadd(aCalcMed,{QEK->QEK_GRUPO,0,0,CalcMin(nTotHora),0,0,1,0,0,0,0})
							Endif
						EndIf
					EndIf	
				Else
					If Empty(QEL->QEL_DTENLA)				
						nDiaUtil:= If(dDataBase <> QEK->QEK_DTENTR,DiaUtil(QEK->QEK_DTENTR,dDataBase),0)
						nTotHora:= Q060CalHor(nDiaUtil,Left(time(),5),QEK->QEK_HRENTR)
					Else
						nDiaUtil:=If(dDataBase <> QEL->QEL_DTENLA,DiaUtil(QEL->QEL_DTENLA,dDataBase),0)
						nTotHora:=Q060CalHor(nDiaUtil,Left(Time(),5),QEL->QEL_HRENLA)
					EndIf
					oSection2:Cell("cLtTrans"):SetValue(Alltrim(nTotHora))
					oSection2:Cell("cLtTrans"):Show()
					nTTran+=CalcMin(nTotHora)
					nCTran++
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula hora p/ Calculo da M‚dia                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SuperVal(nTotHora) > 0
						QEA->(dbSetOrder(1))
						If QEA->(dbSeek(xFilial("QEA")+QEK->QEK_GRUPO+QEK->QEK_PRODUT))
							nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO})
							If nPos <> 0
								aCalcMed[nPos,2] += CalcMin(nTotHora)
								aCalcMed[nPos,6] := aCalcMed[nPos,6]+1
							Else
								Aadd(aCalcMed,{QEK->QEK_GRUPO,CalcMin(nTotHora),0,0,0,1,0,0,0,0,0})
							EndIf
						EndIf
					EndIf
				EndIf	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ C lculo do Lead-Time Disponibilidade                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(QEL->QEL_DTDILA)
					nDiaUtil:=If(QEL->QEL_DTDILA <> QEL->QEL_DTLAUD,DiaUtil(QEL->QEL_DTLAUD,QEL->QEL_DTDILA),0)
					nTotHora:=Q060CalHor(nDiaUtil,QEL->QEL_HRDILA,QEL->QEL_HRLAUD)
					oSection2:Cell("cLtDisp"):SetValue(Alltrim(nTotHora))
					oSection2:Show()
					nTDis+=CalcMin(nTotHora)
					nCDis++
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula hora p/ Calculo da M‚dia                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SuperVal(nTotHora) > 0
						QEA->(dbSetOrder(1))
						If QEA->(dbSeek(xFilial("QEA")+QEK->QEK_GRUPO+QEK->QEK_PRODUT))
							nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO})
							If nPos <> 0
								aCalcMed[nPos,5] += CalcMin(nTotHora)
								aCalcMed[nPos,8] := aCalcMed[nPos,8]+1
							Else
								Aadd(aCalcMed,{QEK->QEK_GRUPO,0,0,0,CalcMin(nTotHora),0,0,1,0,0,0})
							Endif
						EndIf
					EndIf
				EndIf	
				oSection2:PrintLine()

			ElseIf mv_par07 == 3
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Em Laborat¢rio                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(QEL->QEL_DTENLA) .And. Empty(QEL->QEL_DTLAUD)
				    
			        If cFornec+cLojFor+cProdut <>&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR")+&((cAliasQEK)+"->QEK_PRODUT") 
						cFornec := &((cAliasQEK)+"->QEK_FORNEC") 
						cLojFor := &((cAliasQEK)+"->QEK_LOJFOR")
						cProdut := &((cAliasQEK)+"->QEK_PRODUT")
						oSection1:Init()
						oSection1:PrintLine()    
					EndIF

					nDiaUtil:= If(dDataBase <> QEL->QEL_DTENLA,DiaUtil(QEL->QEL_DTENLA,dDataBase),0)
					nTotHora:= Q060CalHor(nDiaUtil,Left(time(),5),QEL->QEL_HRENLA)
					oSection2:Cell("cLeadTime"):SetValue(Alltrim(nTotHora))
					oSection2:Cell("cLeadTime"):Show()
					nTLabor+=CalcMin(nTotHora)
					nCLabor++
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula hora p/ Calculo da M‚dia                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SuperVal(nTotHora) > 0			
						QEA->(dbSetOrder(1))
						If QEA->(dbSeek(xFilial("QEA")+QEK->QEK_GRUPO+QEK->QEK_PRODUT))
							nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO})
							If nPos <> 0
								aCalcMed[nPos,10] += CalcMin(nTotHora)
								aCalcMed[nPos,11] := aCalcMed[nPos,11]+1
							Else
								Aadd(aCalcMed,{QEK->QEK_GRUPO,0,0,0,0,0,0,0,0,CalcMin(nTotHora),1})
							Endif
						EndIf
					EndIf
					oSection2:PrintLine()
				EndIf
					
			ElseIf mv_par07 == 4
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Com Laudo                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(QEL->QEL_LABOR) .And. !Empty(QEL->QEL_DTENLA) .And. !Empty(QEL->QEL_DTLAUD)
				
				    If cFornec+cLojFor+cProdut <>&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR")+&((cAliasQEK)+"->QEK_PRODUT") 
						cFornec := &((cAliasQEK)+"->QEK_FORNEC") 
						cLojFor := &((cAliasQEK)+"->QEK_LOJFOR")
						cProdut := &((cAliasQEK)+"->QEK_PRODUT")
						oSection1:Init()
						oSection1:PrintLine()    
					EndIF
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ C lculo do Lead-Time Laudo                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nDiaUtil:=If(QEL->QEL_DTLAUD <> QEL->QEL_DTENLA,DiaUtil(QEL->QEL_DTENLA,QEL->QEL_DTLAUD),0)
					nTotHora:=Q060CalHor(nDiaUtil,QEL->QEL_HRLAUD,QEL->QEL_HRENLA)
					oSection2:Cell("cLtLaudo"):SetValue(Alltrim(nTotHora))
					oSection2:Cell("cLtLaudo"):Show()
					nTLaudo+=CalcMin(nTotHora)
					nCLaudo++
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula hora p/ Calculo da M‚dia                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SuperVal(nTotHora) > 0			
						QEA->(dbSetOrder(1))
						If QEA->(dbSeek(xFilial("QEA")+QEK->QEK_GRUPO+QEK->QEK_PRODUT))
							nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO})
							If nPos <> 0
								aCalcMed[nPos,3] += CalcMin(nTotHora)
								aCalcMed[nPos,9] := aCalcMed[nPos,9]+1
							Else
								Aadd(aCalcMed,{QEK->QEK_GRUPO,0,CalcMin(nTotHora),0,0,0,0,0,1,0,0})
							Endif
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ C lculo do Lead-Time Total                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nDiaUtil:=If(QEL->QEL_DTLAUD <> QEK->QEK_DTENTR,DiaUtil(QEK->QEK_DTENTR,QEL->QEL_DTLAUD),0)
					nTotHora:=Q060CalHor(nDiaUtil,QEL->QEL_HRLAUD,QEK->QEK_HRENTR)
					oSection2:Cell("cLtTotal"):SetValue(Alltrim(nTotHora))
					oSection2:Cell("cLtTotal"):Show()
					nTTot+=CalcMin(nTotHora)
					nCTot++
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula hora p/ Calculo da M‚dia                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SuperVal(nTotHora) > 0
						QEA->(dbSetOrder(1))
						If QEA->(dbSeek(xFilial("QEA")+QEK->QEK_GRUPO+QEK->QEK_PRODUT))
							nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO})
							If nPos <> 0
								aCalcMed[nPos,4] += CalcMin(nTotHora)
								aCalcMed[nPos,7] := aCalcMed[nPos,7]+1
							Else
								Aadd(aCalcMed,{QEK->QEK_GRUPO,0,0,CalcMin(nTotHora),0,0,1,0,0,0,0})
							Endif
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ C lculo do Lead-Time Disponibilidade                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(QEL->QEL_DTDILA)
						nDiaUtil:=If(QEL->QEL_DTDILA <> QEL->QEL_DTLAUD,DiaUtil(QEL->QEL_DTLAUD,QEL->QEL_DTDILA),0)
						nTotHora:=Q060CalHor(nDiaUtil,QEL->QEL_HRDILA,QEL->QEL_HRLAUD)
						oSection2:Cell("cLtDisp"):SetValue(Alltrim(nTotHora))
						oSection2:Cell("cLtDisp"):Show()
						nTDis+=CalcMin(nTotHora)
						nCDis++
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Acumula hora p/ Calculo da M‚dia                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SuperVal(nTotHora) > 0
							QEA->(dbSetOrder(1))
							If QEA->(dbSeek(xFilial("QEA")+QEK->QEK_GRUPO+QEK->QEK_PRODUT))
								nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO})
								If nPos <> 0
									aCalcMed[nPos,5] += CalcMin(nTotHora)
									aCalcMed[nPos,8] := aCalcMed[nPos,8]+1
								Else
									Aadd(aCalcMed,{QEK->QEK_GRUPO,0,0,0,CalcMin(nTotHora),0,0,1,0,0,0})
								Endif
							EndIf
						EndIf
					EndIf
					oSection2:PrintLine()
				EndIf
			EndIf
			lRoda    := .T.
        	QEL->(dbSkip())    
        EndDO                    
	Else 
		If mv_par07 == 1		//Todos
			If Empty(QEL->QEL_DTENLA)	// em Transito
			
                If cFornec+cLojFor+cProdut <>&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR")+&((cAliasQEK)+"->QEK_PRODUT") 
					cFornec := &((cAliasQEK)+"->QEK_FORNEC") 
					cLojFor := &((cAliasQEK)+"->QEK_LOJFOR")
					cProdut := &((cAliasQEK)+"->QEK_PRODUT")
					oSection1:Init()
					oSection1:PrintLine()    
				EndIF
			
				nDiaUtil:= If(dDataBase <> &((cAliasQEK)+"->QEK_DTENTR"),DiaUtil(&((cAliasQEK)+"->QEK_DTENTR"),dDataBase),0)
				nTotHora:= Q060CalHor(nDiaUtil,Left(time(),5),&((cAliasQEK)+"->QEK_HRENTR"))
				oSection2:Cell("cLtTrans"):SetValue(Alltrim(nTotHora))
				oSection2:Cell("cLtTrans"):Show()
				nTTran+=CalcMin(nTotHora)
				nCTran++
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acumula hora p/ Calculo da M‚dia                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SuperVal(nTotHora) > 0
					QEA->(dbSetOrder(1))
					If QEA->(dbSeek(xFilial("QEA")+&((cAliasQEK)+"->QEK_GRUPO")+&((cAliasQEK)+"->QEK_PRODUT")))
						nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO})
						If nPos <> 0
							aCalcMed[nPos,2] += CalcMin(nTotHora)
							aCalcMed[nPos,6] := aCalcMed[nPos,6]+1
						Else
							Aadd(aCalcMed,{&((cAliasQEK)+"->QEK_GRUPO"),CalcMin(nTotHora),0,0,0,1,0,0,0,0,0})
						EndIf
					EndIf
				EndIf
				oSection2:PrintLine()    
			EndIf
		ElseIf mv_par07 == 2 	//Em Trƒnsito
			If QEL->(Eof())	// Nao tem laudo nem data entr. laboratorio

                If cFornec+cLojFor+cProdut <>&((cAliasQEK)+"->QEK_FORNEC")+&((cAliasQEK)+"->QEK_LOJFOR")+&((cAliasQEK)+"->QEK_PRODUT") 
					cFornec := &((cAliasQEK)+"->QEK_FORNEC") 
					cLojFor := &((cAliasQEK)+"->QEK_LOJFOR")
					cProdut := &((cAliasQEK)+"->QEK_PRODUT")
					oSection1:Init()
					oSection1:PrintLine()    
				EndIF

				nDiaUtil:= If(dDataBase <> &((cAliasQEK)+"->QEK_DTENTR"),DiaUtil(&((cAliasQEK)+"->QEK_DTENTR"),dDataBase),0)
				nTotHora:= Q060CalHor(nDiaUtil,Left(time(),5),&((cAliasQEK)+"->QEK_HRENTR"))
				oSection2:Cell("cLeadTime"):SetValue(Alltrim(nTotHora))
				oSection2:Cell("cLeadTime"):Show()
				nTTran+=CalcMin(nTotHora)
				nCTran++
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acumula hora p/ Calculo da M‚dia                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SuperVal(nTotHora) > 0
					QEA->(dbSetOrder(1))
					If QEA->(dbSeek(xFilial("QEA")+&((cAliasQEK)+"->QEK_GRUPO")+&((cAliasQEK)+"->QEK_PRODUT")))
						nPos := AsCan( aCalcMed,{ |x| x[1] == QEA->QEA_GRUPO})
						If nPos <> 0
							aCalcMed[nPos,2] += CalcMin(nTotHora)
							aCalcMed[nPos,6] := aCalcMed[nPos,6]+1
						Else
							Aadd(aCalcMed,{&((cAliasQEK)+"->QEK_GRUPO"),CalcMin(nTotHora),0,0,0,1,0,0,0,0,0})
						Endif
					EndIf
				EndIf
				lRoda:=.T.
				oSection2:PrintLine()    
			EndIf
		EndIf
	EndIF
	&(cAliasQEK)->(dbSkip()) 
	oSection1:Finish()  
	oSection2:Finish()  
EndDo 

oSection3:Init()
//Transito
nTotMed1 := nTTran / nCTran
nInt	 := Int(nTotMed1 / 60 )
nDec	 := Mod(nTotMed1 , 60 )
nTotMed1 := Str(nInt,6)+":"+StrZero(nDec,2)
oSection3:Cell("TRANSITO"):SetValue(Alltrim(nTotMed1))
	
//Laudo
nTotMed2 := nTLaudo / nCLaudo
nInt	 := Int(nTotMed2 / 60 )
nDec	 := Mod(nTotMed2 , 60 )
nTotMed2 := Str(nInt,6)+":"+StrZero(nDec,2)
oSection3:Cell("LAUDO"):SetValue(Alltrim(nTotMed2))

//Total
nTotMed3 := nTTot / nCTot
nInt	 := Int(nTotMed3 / 60 )
nDec	 := Mod(nTotMed3 , 60 )
nTotMed3 := Str(nInt,6)+":"+StrZero(nDec,2)
oSection3:Cell("TOTAL"):SetValue(Alltrim(nTotMed3))
	
//Disponibilidade	
nTotMed4 := nTDis / nCDis
nInt	 := Int(nTotMed4 / 60 )
nDec	 := Mod(nTotMed4 , 60 )
nTotMed4 := Str(nInt,6)+":"+StrZero(nDec,2)
oSection3:Cell("DISPONIBILIDADE"):SetValue(Alltrim(nTotMed4))

//Laboratorio
nTotMed5 := nTLabor / nCLabor
nInt	 := Int(nTotMed5 / 60 )
nDec	 := Mod(nTotMed5 , 60 )
nTotMed5 := Str(nInt,6)+":"+StrZero(nDec,2)
oSection3:Cell("LABORATORIO"):SetValue(Alltrim(nTotMed5))

If lRoda	
	If mv_par07 == 1
		oSection3:Cell("TRANSITO"):Enable()
		oSection3:Cell("LAUDO"):Enable()
		oSection3:Cell("TOTAL"):Enable()
		oSection3:Cell("DISPONIBILIDADE"):Enable()
		oSection3:Cell("LABORATORIO"):Disable()
	ElseIf mv_par07 == 2
		oSection3:Cell("TRANSITO"):Enable()
		oSection3:Cell("LAUDO"):Disable()
		oSection3:Cell("TOTAL"):Disable()
		oSection3:Cell("DISPONIBILIDADE"):Disable()
		oSection3:Cell("LABORATORIO"):Disable()
	ElseIf mv_par07 == 3
		oSection3:Cell("TRANSITO"):Disable()
		oSection3:Cell("LAUDO"):Disable()
		oSection3:Cell("TOTAL"):Disable()
		oSection3:Cell("DISPONIBILIDADE"):Disable()
		oSection3:Cell("LABORATORIO"):Enable()
	ElseIf mv_par07 == 4
		oSection3:Cell("TRANSITO"):Disable()
		oSection3:Cell("LAUDO"):Enable()
		oSection3:Cell("TOTAL"):Enable()
		oSection3:Cell("DISPONIBILIDADE"):Enable()
		oSection3:Cell("LABORATORIO"):Disable()
	EndIf
	oSection3:PrintLine()    

	If mv_par07 == 1
		oReport:SkipLine()
		oReport:PrintText(STR0020,oReport:Row(),002) //"Lead-Time Transito: tempo decor. desde a Entrada ou Data Entrada em Laboratorio ate' hoje."
		oReport:SkipLine()
		oReport:PrintText(STR0021,oReport:Row(),002) //"Lead-Time Laudo ..: tempo decorrido desde a Entrada ate' a Saida do Laboratorio."
		oReport:SkipLine()
		oReport:PrintText(STR0022,oReport:Row(),002) //"Lead-Time Total ..: tempo decorrido desde a Entrada do Produto ate' a Saida Laboratorio."
		oReport:SkipLine()
		oReport:PrintText(STR0023,oReport:Row(),002) //"Lead-Time Disp. ..: tempo decor. desde Saida Laboratorio ate' Disponibilizacao Laudo."
	ElseIf mv_par07 == 2
		oReport:SkipLine()
		oReport:PrintText(STR0024,oReport:Row(),002) //"Lead-Time Transito: tempo decor. desde a Entrada do Produto ate' a data de hoje."
	ElseIf mv_par07 == 3
		oReport:SkipLine()
		oReport:PrintText(STR0025,oReport:Row(),002) //"Lead-Time: tempo decorrido desde a Entrada Laboratorio ate' a data de hoje."
	ElseIf mv_par07 == 4
		oReport:SkipLine()
		oReport:PrintText(STR0021,oReport:Row(),002) //"Lead-Time Laudo ..: tempo decorrido desde a Entrada ate' a Saida do Laboratorio."
		oReport:SkipLine()
		oReport:PrintText(STR0022,oReport:Row(),002) //"Lead-Time Total ..: tempo decorrido desde a Entrada do Produto ate' a Saida Laboratorio."
		oReport:SkipLine()
		oReport:PrintText(STR0023,oReport:Row(),002) //"Lead-Time Disp. ..: tempo decor. desde Saida Laboratorio ate' Disponibilizacao Laudo."
	EndIf
Endif

oSection3:Finish()  
oReport:EndPage(.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CabecR4   ºAutor  ³Cleber Souza		 º Data ³  07/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina define as colunas que serão apresentadas de acordo  º±±
±±º          ³ com as opções do relatorio definidas pelo usuário.         º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto oSection2 do relatorio					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ QIER060                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CabecR4(oSection2)

If mv_par07 == 1
	oSection2:Cell("QEK_DTENTR"):Enable()
	oSection2:Cell("QEK_LOTE"):Enable()
	oSection2:Cell("QEL_LABOR"):Enable()
	oSection2:Cell("QEL_DTENLA"):Enable()
	oSection2:Cell("QEL_DTLAUD"):Enable()
	oSection2:Cell("QEL_DTDILA"):Enable()
	oSection2:Cell("cLtTrans"):Enable()
	oSection2:Cell("cLtLaudo"):Enable()
	oSection2:Cell("cLtTotal"):Enable()
	oSection2:Cell("cLtDisp"):Enable()
	oSection2:Cell("cLeadTime"):DISABLE()
ElseIf mv_par07 == 2
	oSection2:Cell("QEK_DTENTR"):Enable()
	oSection2:Cell("QEK_LOTE"):Enable()
	oSection2:Cell("QEL_LABOR"):DISABLE()
	oSection2:Cell("QEL_DTENLA"):DISABLE()
	oSection2:Cell("QEL_DTLAUD"):DISABLE()
	oSection2:Cell("QEL_DTDILA"):DISABLE()
	oSection2:Cell("cLtTrans"):DISABLE()
	oSection2:Cell("cLtLaudo"):DISABLE()
	oSection2:Cell("cLtTotal"):DISABLE()
	oSection2:Cell("cLtDisp"):DISABLE()
	oSection2:Cell("cLeadTime"):Enable()
ElseIf mv_par07 == 3
	oSection2:Cell("QEK_DTENTR"):Enable()
	oSection2:Cell("QEK_LOTE"):Enable()
	oSection2:Cell("QEL_LABOR"):Enable()
	oSection2:Cell("QEL_DTENLA"):Enable()
	oSection2:Cell("QEL_DTLAUD"):DISABLE()
	oSection2:Cell("QEL_DTDILA"):DISABLE()
	oSection2:Cell("cLtTrans"):DISABLE()
	oSection2:Cell("cLtLaudo"):DISABLE()
	oSection2:Cell("cLtTotal"):DISABLE()
	oSection2:Cell("cLtDisp"):DISABLE()
	oSection2:Cell("cLeadTime"):Enable()
ElseIf mv_par07 == 4
	oSection2:Cell("QEK_DTENTR"):Enable()
	oSection2:Cell("QEK_LOTE"):Enable()
	oSection2:Cell("QEL_LABOR"):Enable()
	oSection2:Cell("QEL_DTENLA"):Enable()
	oSection2:Cell("QEL_DTLAUD"):Enable()
	oSection2:Cell("QEL_DTDILA"):Enable()
	oSection2:Cell("cLtTrans"):DISABLE()
	oSection2:Cell("cLtLaudo"):Enable()
	oSection2:Cell("cLtTotal"):Enable()
	oSection2:Cell("cLtDisp"):Enable()
	oSection2:Cell("cLeadTime"):DISABLE()
EndIF	

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DiaUtil   ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o numero de dias uteis no per¡odo                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DiaUtil()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion DiaUtil(dDtEntr,dDtSai)
Local nDia:=0,nDat:=0,nC,dDt

nDat := dDtSai-dDtEntr

If nDat > 1
	dDtEntr:= dDtEntr-1
EndIf	

For nC := 1 To nDat
	dDt:= DataValida(dDtEntr+nC,.T.)
	If dDt <> dDtEntr+nC
		Loop
	ElseIf dDt <= dDtSai
		nDia++
	EndIf	
Next nC
Return(nDia)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q060CalHor³ Autor ³ Marcelo Pimentel      ³ Data ³ 06.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o numero de horas - Lead-Time                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Q060CalHor()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Q060CalHor(nDia,nHr,nHrLab)
Local nRest:=0,nLabor:=0,nVar:=0,nInt,nDec

nRest := (Val(Subs(nHr,1,2)) * 60) + Val(Subs(nHr,4,2))
nLabor:= (Val(Subs(nHrLab,1,2)) * 60) + Val(Subs(nHrLab,4,2))
If nDia == 0	 								// Se for no Mesmo dia
	nVar := nRest - nLabor
Else
	nVar := ((nDia - 1) * 24 * 60 ) + ((24 * 60) - nLabor) + nRest
EndIf
nInt := Abs(Int(nVar / 60))
nDec := Abs(Mod(nVar , 60))
Return(Str(nInt,6)+":"+StrZero(nDec,2))
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CalcMin   ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna em Minutos - Lead-Time                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CalcMin()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcMin(nHr)
Local nLabor :=0,nPosic:=0

nPosic:=At(":",AllTrim(nHr))
nLabor:= Abs((Val(Left(AllTrim(nHr),nPosic-1)) * 60) + Val(Right(nHr,2)))
Return(nLabor)
