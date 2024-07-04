#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "GPER854.CH"
#INCLUDE "TOPCONN.CH"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ GPER854 ³ Autor ³Marcos Kato                      ³ Data ³ 16/12/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Relatório MINTRA										               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Francisoc Jr³08/02/2010³00025232010³Compatibilizar para Projeto Corporativo     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso     ³ Microsiga						                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GPER854()
Local cString		:= "SRA"
Local nomeProg 	:= "GPER854"
Local cPerg     	:= "GPER854"
Local cDesc1		:=STR0001//"Informe Trimestral Mintra"
Local cDesc2 		:=STR0002//"Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3 		:=STR0003//"usuario."
Local aArea			:= GetArea()
Local cTamanho		:="P"
Private oPrint
Private cTitulo 	:= STR0004//"Relatorio MINTRA"
Private aReturn 	:= {STR0005, 1,STR0006, 2, 1, 1, "",1 }//Zebrado#Administracao
Private oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.F.,.F.)
Private oArial12N	:= TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)
Private oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.F.,.F.)
Private cStartPath	:= GetSrvProfString("Startpath","")
Private nLin		:= 0 	,nCol		  	:= 0 		,nTrimest   := 0 	,nPag			:= 0
Private cAnoBase  := ""	,cPeriodo   := ""		,cTrimest	:= ""	,cRoteiro	:= "",cTurno  	  	:= "",cFilSra     := ""
Private cCC			:= ""	,cDepto     := ""		,cMat       := ""	,cNome     	:= "",cCateg      := "",cSit      := ""
Private cImDif	   := ""	,dDtIni     := 0		,dDtFin     := 0

Private aInfTriT	:= {}

DbSelectArea("SM0")
Dbseek(cEmpAnt+cFilAnt)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "GPER854"

wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif
//=======================================================================
//MV_PAR01 - PROCESSO
//MV_PAR02 - ANO
//MV_PAR03 - IMPRIME(1oTrimestre,2oTrimestre,3oTrimestre ou 4oTrimestre)
//MV_PAR04 - FILIAL
//MV_PAR05 - CENTRO DE CUSTO
//MV_PAR06 - DEPARTAMENTO 
//MV_PAR07 - MATRICULA
//MV_PAR08 - NOME     
//MV_PAR09 - SITUACAO
//MV_PAR10 - CATEGORIA 
//MV_PAR11 - IMPRIME TOTAL EMPREGADO
//MV_PAR12 - IMPRIME DETALHE POR SEXO
//MV_PAR13 - IMPRIME TOTAL POR DEPTO 
//MV_PAR14 - IMPRIME TOTAL GERAL POR DEPTO 
//MV_PAR15 - TURNO - MVPAR15   
//=======================================================================
cPeriodo:=MV_PAR01
cAnoBase:=MV_PAR02
nTrimest:=MV_PAR03
//cRoteiro:=MV_PAR04
cTurno  :=MV_PAR15  
cFilSra :=IIF(Len(AllTrim(MV_PAR04)) = 0,"",RANGESX1("RA_FILIAL",MV_PAR04))
cCC     :=IIF(EMPTY(MV_PAR05),"",RANGESX1("RA_CC"    ,MV_PAR05))
cDepto  :=IIF(EMPTY(MV_PAR06),"",RANGESX1("RA_DEPTO" ,MV_PAR06))
cMat    :=IIF(EMPTY(MV_PAR07),"",RANGESX1("RA_MAT"   ,MV_PAR07))
cNome   :=IIF(EMPTY(MV_PAR08),"",RANGESX1("RA_NOME"  ,MV_PAR08))

oPrint:= TMSPrinter():New( cTitulo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ha impressora ativa conectada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! oPrint:IsPrinterActive()
	oPrint:Setup()							//-- Escolhe a impressora
	If ! oPrint:IsPrinterActive()
		Help(" ",1,"NOPRINTGRA")			//-- Nao foi encontrada configuracao de impressora. ##Certifique-se de que as configurações da impressora estão corretas ou se há alguma impressora conectada.
		Return(Nil)
	Endif
Endif
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Modo de Impressao                                                           //
//oPrint:SetLandscape() - Impressao Paisagem                                  //
//oPrint:SetPortrait()  - Impressao Retrato                                   //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
oPrint:SetPortrait()

MsgRun(STR0008,STR0007, {||CursorWait(),RELHMES(),CursorArrow()})//"Processando Informe Trimestral"#"Aguarde..."

RestArea( aArea)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ RELHMES ³  Autor ³Marcos Kato              ³ Data ³ 16/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Contem todo o detalhe do relatorio Hora Mes Trimestral	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function RELHMES()
Local cQryHMes    	:= ""
Local nQtd			:= 0 ,nCont         := 0
Local aPeriodo		:= {},aPMesTri		:= {},aSMesTri		:= {},aTMesTri		:= {}
//==============================================================================================================================================
//====================================Processando relacao de horas por mes======================================================================
//==============================================================================================================================================
cCateg:="'"
For nCont:=1 To Len(Alltrim(MV_PAR10))
	cCateg+=Substr(MV_PAR10,nCont,1)+"','"
Next
cCateg:=Substr(cCateg,1,Len(cCateg)-2)

If Empty(cCateg)
	ccateg:="' '"
Endif  

cSit:="'"
For nCont:=1 To Len(trim(MV_PAR09))
	cSit+=Substr(MV_PAR09,nCont,1)+"','"
Next
cSit:=Substr(cSit,1,Len(cSit)-2)

If Empty(cSit)
	cSit:="' '"
Endif

cQryHMes:="SELECT RCF_ANO,RCF_MES,COUNT(RA_MAT) QTD,RCF_HRSDIA HORAS,RCF_DIATRA DIAS,COUNT(RA_MAT)*(RCF_HRSDIA*RCF_DIATRA) TOTAL "
cQryHMes+="FROM "+RetSqlName("SRA")+" SRA "
cQryHMes+="INNER JOIN "+RetSqlName("RCF")+" RCF ON "
cQryHMes+="RCF_PROCES=RA_PROCES "
cQryHMes+="AND RCF_ANO ='"+cAnoBase+"' "
If nTrimest==1//1° Trimestre
	cQryHMes+="AND RCF_MES BETWEEN '01' AND '03' "
	cTrimest:=STR0009//"1°TRIMESTRE"
	aadd(aPeriodo,{STR0013,STR0014,STR0015})//"JANEIRO","FEVEREIRO","MARCO"
	aadd(aPeriodo,{"01","02","03"})
ElseIf nTrimest==2//2° Trimestre
	cQryHMes+="AND RCF_MES BETWEEN '04' AND '06' "
	cTrimest:=STR0010//"2°TRIMESTRE"
	aadd(aPeriodo,{STR0016,STR0017,STR0018})//{"ABRIL","MAIO","JUNHO"})
	aadd(aPeriodo,{"04","05","06"})
ElseIf nTrimest==3//3° Trimestre
	cQryHMes+="AND RCF_MES BETWEEN '07' AND '09' "
	cTrimest:=STR0011//"3°TRIMESTRE"
	aadd(aPeriodo,{STR0019,STR0020,STR0021})//{"JULHO","AGOSTO","SETEMBRO"})
	aadd(aPeriodo,{"07","08","09"})
ElseIf nTrimest==4//4° Trimestre
	cQryHMes+="AND RCF_MES BETWEEN '10' AND '12' "
	cTrimest:=STR0012//"4°TRIMESTRE"
	aadd(aPeriodo,{STR0022,STR0023,STR0024})//{"OUTUBRO","NOVEMBRO","DEZEMBRO"})
	aadd(aPeriodo,{"10","11","12"})
Endif
//If !Empty(cRoteiro)
//	cQryHMes+="AND RCF_ROTEIR ='"+cRoteiro+"' "
//Endif
If !Empty(cTurno)
	cQryHMes+="AND RCF_TNOTRA ='"+cTurno+"' "
Else
	cQryHMes+="AND RCF_TNOTRA ='@@@' "//Generico
Endif
cQryHMes+="AND RCF.D_E_L_E_T_='' "
cQryHMes+="WHERE SRA.D_E_L_E_T_='' "
cQryHMes+="AND RA_PROCES ='"+cPeriodo+"' "
//cQryHMes+="AND RA_SITFOLH <>'D' "
If !Empty(cTurno)
	cQryHMes+="AND RA_TNOTRAB ='"+cTurno+"' "
Endif
If Len(Alltrim(cFilSra)) > 0 
	cQryHMes+="AND "+cFilSra
Endif
If !Empty(cCC)
	cQryHMes+="AND "+cCC
Endif	
If !Empty(cDepto)
	cQryHMes+="AND "+cDepto
Endif	
If !Empty(cMat)
	cQryHMes+="AND "+cMat
Endif	
If !Empty(cNome)
	cQryHMes+="AND "+cNome
Endif                                     
cQryHMes+="AND RA_SITFOLH IN ("+cSit+")
cQryHMes+="AND RA_CATFUNC IN ("+cCateg+") 
cQryHMes+="GROUP BY RCF_ANO,RCF_MES,RCF_HRSDIA,RCF_DIATRA "
cQryHMes:= ChangeQuery(cQryHMes)

If Select("TRBHMES")>0
	DbSelectArea("TRBHMES")
	TRBHMES->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryHMES),"TRBHMES",.F.,.T.)
If TRBHMES->(!Eof())
	Do While TRBHMES->(!Eof())
		If TRBHMES->RCF_MES$"01|04|07|10"//1° Mes do Trimestre
			aadd(aPMesTri,{TRBHMES->QTD,TRBHMES->HORAS,TRBHMES->DIAS,TRBHMES->TOTAL})
		ElseIf TRBHMES->RCF_MES$"02|05|08|11"//2° Mes do Trimestre
			aadd(aSMesTri,{TRBHMES->QTD,TRBHMES->HORAS,TRBHMES->DIAS,TRBHMES->TOTAL})
		ElseIf TRBHMES->RCF_MES$"03|06|09|12"//3° Mes do Trimestre
			aadd(aTMesTri,{TRBHMES->QTD,TRBHMES->HORAS,TRBHMES->DIAS,TRBHMES->TOTAL})
		Endif
		TRBHMES->(DbSkip())
	End
	
	If MV_PAR11==2
		nPag++
		nCol:=100
		oPrint:Line(100 ,nCol     ,100 ,2200)
		oPrint:Box(150  ,nCol     ,2900,2200)
		nCol+=100
		oPrint:Box(250  ,nCol     ,550 ,2100)
		oPrint:Say(350  ,nCol-100 ,PADC(STR0025,160)			    ,oArial14N)//"MINISTERIO DO TRABALHO"
		oPrint:Say(450  ,nCol-100 ,PADC(cTrimest+STR0026+cAnoBase+" ",160)  ,oArial14N)//"DO ANO DE "
		//========================================================================================================
		nLin:=650
		oPrint:Box(650  ,nCol     ,1000,2100)
		oPrint:Line(750 ,nCol     ,750  ,2100)
		oPrint:Line(750 ,nCol+500 ,1000 ,nCol+500)
		oPrint:Line(750 ,nCol+1000,1000 ,nCol+1000)
		oPrint:Line(750 ,nCol+1500,1000 ,nCol+1500)
		oPrint:Say(650  ,nCol-100 ,PADC(STR0027+aPeriodo[1][1]+" DE "+cAnoBase,140)      ,oArial14N)//"RELACAO DE HORAS MES"
		oPrint:Line(750 ,nCol     ,750  ,2100)
		oPrint:Say(750   ,nCol+020 ,STR0029,oArial12N)//"Nro. Empregado"
		oPrint:Say(750   ,nCol+520 ,STR0030,oArial12N)//"Nro. Hrs. Dia Trab."
		oPrint:Say(750   ,nCol+1020,STR0031,oArial12N)//"Nro. Dias por Mes"
		oPrint:Say(750   ,nCol+1520,STR0032,oArial12N)//"Nro. Total Horas"
		oPrint:Line(850 ,nCol     ,850  ,2100)
		nLin+=100
		For nQtd:=1 To Len(aPMesTri)
			oPrint:Say(nLin+150,nCol+200 ,Space(8-Len(Alltrim(Str(aPMesTri[nQtd][1]))))+Transform(aPMesTri[nQtd][1],"@E 99999")     ,oArial12N)//"Nro. Empregado"
			oPrint:Say(nLin+150,nCol+700 ,Space(8-Len(Alltrim(Str(aPMesTri[nQtd][2]))))+Transform(aPMesTri[nQtd][2],"@E 99,999")    ,oArial12N)//"Nro. Hrs. Dia Trab."
			oPrint:Say(nLin+150,nCol+1200,Space(8-Len(Alltrim(Str(aPMesTri[nQtd][3]))))+Transform(aPMesTri[nQtd][3],"@E 999")		,oArial12N)//"Nro. Dias por Mes"
			oPrint:Say(nLin+150,nCol+1600,Space(8-Len(Alltrim(Str(aPMesTri[nQtd][4]))))+Transform(aPMesTri[nQtd][4],"@E 9,999,999")	,oArial12N)//"Nro. Total Horas"
			nLin+=50
			If nQtd>1
				Exit
			Endif
		Next
		//========================================================================================================
		nLin:=1050
		oPrint:Box(1050   ,nCol     ,1400 ,2100)
		oPrint:Line(1150  ,nCol     ,1150 ,2100)
		oPrint:Line(1150  ,nCol+500 ,1400 ,nCol+500)
		oPrint:Line(1150  ,nCol+1000,1400 ,nCol+1000)
		oPrint:Line(1150  ,nCol+1500,1400 ,nCol+1500)
		oPrint:Say(1050   ,nCol-100 ,PADC(STR0027+aPeriodo[1][2]+STR0028+cAnoBase,140)      ,oArial14N)//"RELACAO DE HORAS MES"
		
		oPrint:Line(1150  ,nCol     ,1150 ,2100)
		oPrint:Say(1150   ,nCol+020 ,STR0029,oArial12N)//"Nro. Empregado"
		oPrint:Say(1150   ,nCol+520 ,STR0030,oArial12N)//"Nro. Hrs. Dia Trab."
		oPrint:Say(1150   ,nCol+1020,STR0031,oArial12N)//"Nro. Dias por Mes"
		oPrint:Say(1150   ,nCol+1520,STR0032,oArial12N)//"Nro. Total Horas"
		oPrint:Line(1250  ,nCol     ,1250 ,2100)
		nLin+=100
		For nQtd:=1 To Len(aSMesTri)
			oPrint:Say(nLin+150,nCol+200 ,Space(8-Len(Alltrim(Str(aSMesTri[nQtd][1]))))+Transform(aSMesTri[nQtd][1],"@E 99999")     ,oArial12N)//"Nro. Empregado"
			oPrint:Say(nLin+150,nCol+700 ,Space(8-Len(Alltrim(Str(aSMesTri[nQtd][2]))))+Transform(aSMesTri[nQtd][2],"@E 99,999")    ,oArial12N)//"Nro. Hrs. Dia Trab."
			oPrint:Say(nLin+150,nCol+1200,Space(8-Len(Alltrim(Str(aSMesTri[nQtd][3]))))+Transform(aSMesTri[nQtd][3],"@E 999")		,oArial12N)//"Nro. Dias por Mes"
			oPrint:Say(nLin+150,nCol+1600,Space(8-Len(Alltrim(Str(aSMesTri[nQtd][4]))))+Transform(aSMesTri[nQtd][4],"@E 9,999,999")	,oArial12N)//"Nro. Total Horas"
			nLin+=50
			If nQtd>1
				Exit
			Endif
		Next
		//========================================================================================================
		nLin:=1450
		oPrint:Box(1450   ,nCol     ,1800 ,2100)
		oPrint:Line(1550  ,nCol     ,1550 ,2100)
		oPrint:Line(1550  ,nCol+500 ,1800 ,nCol+500)
		oPrint:Line(1550  ,nCol+1000,1800 ,nCol+1000)
		oPrint:Line(1550  ,nCol+1500,1800 ,nCol+1500)
		oPrint:Say(1450   ,nCol-100,PADC(STR0027+aPeriodo[1][3]+STR0028+cAnoBase,140)      ,oArial14N)//"RELACAO DE HORAS MES"," DE "
		oPrint:Line(1550  ,nCol     ,1550 ,2100)
		oPrint:Say(1550   ,nCol+020 ,STR0029,oArial12N)//"Nro. Empregado"
		oPrint:Say(1550   ,nCol+520 ,STR0030,oArial12N)//"Nro. Hrs. Dia Trab."
		oPrint:Say(1550   ,nCol+1020,STR0031,oArial12N)//"Nro. Dias por Mes"
		oPrint:Say(1550   ,nCol+1520,STR0032,oArial12N)//"Nro. Total Horas"
		oPrint:Line(1650  ,nCol     ,1650 ,2100)
		nLin+=100
		For nQtd:=1 To Len(aTMesTri)
			oPrint:Say(nLin+150,nCol+200 ,Space(8-Len(Alltrim(Str(aTMesTri[nQtd][1]))))+Transform(aTMesTri[nQtd][1],"@E 99999")     ,oArial12N)//"Nro. Empregado"
			oPrint:Say(nLin+150,nCol+700 ,Space(8-Len(Alltrim(Str(aTMesTri[nQtd][2]))))+Transform(aTMesTri[nQtd][2],"@E 99,999")	,oArial12N)//"Nro. Hrs. Dia Trab."
			oPrint:Say(nLin+150,nCol+1200,Space(8-Len(Alltrim(Str(aTMesTri[nQtd][3]))))+Transform(aTMesTri[nQtd][3],"@E 999")		,oArial12N)//"Nro. Dias por Mes"
			oPrint:Say(nLin+150,nCol+1600,Space(8-Len(Alltrim(Str(aTMesTri[nQtd][4]))))+Transform(aTMesTri[nQtd][4],"@E 9,999,999")	,oArial12N)//"Nro. Total Horas"
			nLin+=50
			If nQtd>1
				Exit
			Endif
		Next
		oPrint:Line(3000 ,nCol-100,3000,2200)
		oPrint:Say(3050  ,2100,STR0055+Alltrim(Str(nPag)),oArial12N)//"Pagina: "
		oPrint:EndPage()
	Endif
	
	
	If Len(aPMesTri)>0
		MsgRun(STR0033+aPeriodo[1][1]+STR0034+cAnoBase+".",STR0007, {||CursorWait(),RELHMD(aPeriodo[2][1],aPeriodo[1][1]),CursorArrow()})//"Processando Mes de "," do Ano de ",Aguarde...
	Endif
	
	If Len(aSMesTri)>0
		MsgRun(STR0033+aPeriodo[1][2]+STR0034+cAnoBase+".",STR0007, {||CursorWait(),RELHMD(aPeriodo[2][2],aPeriodo[1][2]),CursorArrow()})//"Processando Mes de "," do Ano de ",Aguarde...
	Endif
	
	If Len(aTMesTri)>0
		MsgRun(STR0033+aPeriodo[1][3]+STR0034+cAnoBase+".",STR0007, {||CursorWait(),RELHMD(aPeriodo[2][3],aPeriodo[1][3]),CursorArrow()})//"Processando Mes de "," do Ano de ",Aguarde...
	Endif
	
	If Len(aInfTriT)>0 .And. MV_PAR14==2
		MsgRun(STR0035,STR0007, {||CursorWait(),TotGerDep(),CursorArrow()})//"Processando Totalizacao Trimestral por departamento..."//"Aguarde..."
	Endif
	If aReturn[5]==1
		MsgRun(STR0036,STR0007, {||CursorWait(),oPrint:Preview(),CursorArrow()})//Carregando#Aguarde...
	Else
		MsgRun(STR0037,STR0007, {||CursorWait(),oPrint:Print(),CursorArrow()})//Imprimindo#Aguarde...
	Endif
Else
	Alert(STR0038,STR0039)//"Nao foram encontardos dados de acordo com o parametro.","Atencao"
Endif
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ RELHMD ³  Autor ³Marcos Kato              ³ Data ³ 16/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Geracao da Informacao Trimestral e layout departamento   	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function RELHMD(cMesProc,cDescProc)
Local cQryHMD     	:= "",cDepart     	:= "",cDepCar     	:= "",cCodDep     	:= "",cDesDep     	:= "",cCodCar     	:= "",cDesCar     	:= ""
Local nQtd			:= 0 ,nTotDep       := 0 ,nSalCar       := 0
Local aInfTriM		:= {},aInfTriF		:= {},aInfTriD		:= {},aInfTriC		:= {}


cQryHMD:="SELECT RA_PRINOME NOME,RA_SECNOME SOBRENOME,RA_SEXO SEXO,RA_ADMISSA DTADMISSA,RA_CC CC, "
cQryHMD+="CTT_DESC01 DESCCC,RA_CARGO CARGO,COALESCE(Q3_DESCSUM,'"+STR0054+"') DESCCAR,RA_DEPTO DEPT,QB_DESCRIC DESCDEPT, "
cQryHMD+="CASE WHEN (SELECT MAX(R3_VALOR) FROM "+RetSqlName("SR3")+" WHERE SRA.RA_FILIAL=R3_FILIAL AND SRA.RA_MAT=R3_MAT "
cQryHMD+="AND SUBSTRING(R3_DATA,1,6)='"+cAnoBase+cMesProc+"' AND D_E_L_E_T_='' ) >0 THEN "
cQryHMD+="(SELECT MAX(R3_VALOR) FROM "+RetSqlName("SR3")+" WHERE SRA.RA_FILIAL=R3_FILIAL AND SRA.RA_MAT=R3_MAT "
cQryHMD+="AND SUBSTRING(R3_DATA,1,6)='"+cAnoBase+cMesProc+"' AND D_E_L_E_T_='' )ELSE RA_SALARIO END SALARIO "
cQryHMD+="FROM "+RetSqlName("SRA")+" SRA "
cQryHMD+="LEFT JOIN "+RetSqlName("SQ3")+" SQ3 ON "
cQryHMD+="RA_CARGO=Q3_CARGO "
cQryHMD+="AND SQ3.D_E_L_E_T_='' "
cQryHMD+="INNER JOIN "+RetSqlName("CTT")+" CTT ON "
cQryHMD+="RA_FILIAL=CTT_FILIAL "
cQryHMD+="AND RA_CC=CTT_CUSTO "
cQryHMD+="AND CTT.D_E_L_E_T_='' "
cQryHMD+="INNER JOIN "+RetSqlName("SQB")+" SQB ON "
cQryHMD+="RA_DEPTO=QB_DEPTO "
cQryHMD+="AND SQB.D_E_L_E_T_='' "
cQryHMD+="WHERE RA_SITFOLH<>'D' "
cQryHMD+="AND RA_PROCES ='"+cPeriodo+"' "
cQryHMD+="AND (RA_DEMISSA =' ' OR SUBSTRING(RA_DEMISSA,1,6) <= '"+cAnoBase+cMesProc+"') "
cQryHMD+="AND SRA.D_E_L_E_T_='' "
If !Empty(cTurno)
	cQryHMD+="AND RA_TNOTRAB ='"+cTurno+"' "
Endif
cQryHMD+="AND "+cFilSra
cQryHMD+="AND "+cCC
cQryHMD+="AND "+cDepto
cQryHMD+="AND "+cMat
cQryHMD+="AND "+cNome
cQryHMD+="AND RA_CATFUNC IN ("+cCateg+")
cQryHMD+="ORDER BY RA_SEXO "

cQryHMD:= ChangeQuery(cQryHMD)

If Select("TRBHMD")>0
	DbSelectArea("TRBHMD")
	TRBHMD->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryHMD),"TRBHMD",.F.,.T.)
If TRBHMD->(!Eof())
	Do While TRBHMD->(!Eof())
		If TRBHMD->SEXO=="M"
			aadd(aInfTriM,{TRBHMD->DESCCC,TRBHMD->NOME,TRBHMD->SOBRENOME,;
			Substr(TRBHMD->DTADMISSA,7,2)+"/"+Substr(TRBHMD->DTADMISSA,5,2)+"/"+Substr(TRBHMD->DTADMISSA,1,4),TRBHMD->SALARIO,TRBHMD->DESCCAR,;
			Alltrim(TRBHMD->DEPT),Alltrim(TRBHMD->DESCDEPT)})
		ElseIf TRBHMD->SEXO=="F"
			aadd(aInfTriF,{TRBHMD->DESCCC,TRBHMD->NOME,TRBHMD->SOBRENOME,;
			Substr(TRBHMD->DTADMISSA,7,2)+"/"+Substr(TRBHMD->DTADMISSA,5,2)+"/"+Substr(TRBHMD->DTADMISSA,1,4),TRBHMD->SALARIO,TRBHMD->DESCCAR,;
			Alltrim(TRBHMD->DEPT),Alltrim(TRBHMD->DESCDEPT)})
		Endif
		aadd(aInfTriD,{Alltrim(TRBHMD->DEPT),Alltrim(TRBHMD->DESCDEPT),Alltrim(TRBHMD->CARGO),Alltrim(TRBHMD->DESCCAR),TRBHMD->SALARIO,;
		TRBHMD->CC,TRBHMD->DESCCC})
		aadd(aInfTriT,{Alltrim(TRBHMD->DEPT),Alltrim(TRBHMD->DESCDEPT),Alltrim(TRBHMD->CARGO),Alltrim(TRBHMD->DESCCAR),TRBHMD->SALARIO,;
		TRBHMD->CC,TRBHMD->DESCCC})
		TRBHMD->(DbSkip())
	End
Endif

If MV_PAR12==2
	If Len(aInfTriF)>0
		oPrint:SetLandscape()
		oPrint:StartPage()
		nPag++
		nCol:=100
		oPrint:Line(100 ,nCol     ,100 ,2200)
		oPrint:Box(150  ,nCol     ,2900,2200)
		nLin:=350
		nCol+=100
		
		oPrint:Say(250  ,nCol	  ,STR0040+cDescProc+STR0026+cAnoBase    ,oArial14N)//"FUNCIONARIO DO SEXO FEMINININO DO MES DE "," DO ANO DE "
		cCCusto:=""
		DetFunc(aInfTriF)
		oPrint:Say(3050  ,2100,STR0055+Alltrim(Str(nPag)),oArial12N)//"Pagina: "
		oPrint:EndPage()
	Endif
	If Len(aInfTriM)>0
		oPrint:SetLandscape()
		oPrint:StartPage()
		nPag++
		nCol:=100
		oPrint:Line(100 ,nCol     ,100 ,2200)
		oPrint:Box(150  ,nCol     ,2900,2200)
		nLin:=350
		nCol+=100
		
		oPrint:Say(250  ,nCol	  ,STR0041+cDescProc+STR0026+cAnoBase  ,oArial14N)//"FUNCIONARIO DO SEXO MASCULINO DO MES DE "," DO ANO DE "
		DetFunc(aInfTriM)
		oPrint:Say(3050  ,2100,STR0055+Alltrim(Str(nPag)),oArial12N)//"Pagina: "
		oPrint:EndPage()
	Endif
Endif
If MV_PAR13==2
	If Len(aInfTriD)>0
		aSort(aInfTriD,,,{|x,y|x[1]+x[3]<y[1]+y[3]})//Ordem Cod.Depart. e Cod.cargo
		cDepCar:=Alltrim(aInfTriD[1][1])+Alltrim(aInfTriD[1][3])
		For nQtd:=1 To Len(aInfTriD)
			If cDepCar<>Alltrim(aInfTriD[nQtd][1])+Alltrim(aInfTriD[nQtd][3])
				aadd(aInfTriC,{cCodDep,cDesDep,cCodCar,cDesCar,nSalCar})
				nSalCar:=0
			Endif
			cCodDep:=aInfTriD[nQtd][1]
			cDesDep:=aInfTriD[nQtd][2]
			cCodCar:=aInfTriD[nQtd][3]
			cDesCar:=aInfTriD[nQtd][4]
			nSalCar+=aInfTriD[nQtd][5]
			cDepCar:=Alltrim(aInfTriD[nQtd][1])+Alltrim(aInfTriD[nQtd][3])
		Next
		aadd(aInfTriC,{cCodDep,cDesDep,cCodCar,cDesCar,nSalCar})
		aSort(aInfTriC,,,{|x,y|x[1]+x[3]<y[1]+y[3]})//Ordem Cod.Depart. e Cod.cargo
		oPrint:SetPortrait()
		oPrint:StartPage()
		nPag++
		nCol:=100
		oPrint:Line(100 ,nCol     ,100 ,2200)
		oPrint:Box(150  ,nCol     ,2900,2200)
		nCol+=100
		oPrint:Say(250  ,nCol	  ,STR0042+cDescProc+STR0026+cAnoBase ,oArial14N)//"FUNCIONARIO POR DEPARTAMENTO DO MES DE "," DO ANO DE "
		nLin:=350
		nLin+=100
		For nQtd:=1 To Len(aInfTriC)
			If nLin>2800
				nCol:=100
				oPrint:Line(100 ,nCol-100     ,100 ,2200)
				oPrint:Box(150  ,nCol-100     ,2900,2200)
				nCol+=100
				oPrint:Say(250  ,nCol	  	  ,STR0042+cDescProc+STR0026+cAnoBase ,oArial14N)//"FUNCIONARIO POR DEPARTAMENTO DO MES DE "," DO ANO DE "
				
				nLin:=350
				
			Endif
			If 	cDepart==aInfTriC[nQtd][1]
				oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
				oPrint:Line(nLin-50,nCol+1000,nLin+50,nCol+1000)
				oPrint:Say(nLin    ,nCol+020	  ,aInfTriC[nQtd][4]   ,oArial12N)//"CARGO"
				oPrint:Say(nLin    ,nCol+1500	  ,Space(14-Len(Alltrim(Str(aInfTriC[nQtd][5]))))+Transform(aInfTriC[nQtd][5],"@E 999,999,999.99"),oArial12N)//"SALARIO"
				nLin+=100
			Else
				If nQtd>1
					oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
					oPrint:Say(nLin ,nCol+020	  ,STR0043	,oArial14N)//"TOTAL GERAL"
					oPrint:Say(nLin ,nCol+1440	  ,Space(14-Len(Alltrim(Str(nTotDep))))+Transform(nTotDep,"@E 999,999,999.99"),oArial14N)
					nTotDep:=0
					nLin+=200
				Endif
				oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
				oPrint:Say(nLin  ,nCol+020	,STR0044		  ,oArial14N)//"DEPARTAMENTO"
				oPrint:Say(nLin  ,nCol+1020	,aInfTriC[nQtd][2],oArial12N)//"CARGO"
				nLin+=100
				oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
				oPrint:Line(nLin-50,nCol+1000,nLin+50,nCol+1000)
				oPrint:Say(nLin  ,nCol+020 	,STR0045,oArial14N)//"DEPARTAMENTO"
				oPrint:Say(nLin  ,nCol+1020	,STR0046,oArial14N)//"SALDO DE SALARIO"
				nlin+=100
				oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
				oPrint:Line(nLin-50,nCol+1000,nLin+50,nCol+1000)
				oPrint:Say(nLin  ,nCol+020	,aInfTriC[nQtd][4]   ,oArial12N)//"CARGO"
				oPrint:Say(nLin  ,nCol+1500	,Space(14-Len(Alltrim(Str(aInfTriC[nQtd][5]))))+Transform(aInfTriC[nQtd][5],"@E 999,999,999.99"),oArial12N)//"SALARIO"
				nLin+=100
			Endif
			cDepart:=aInfTriC[nQtd][1]
			nTotDep+=aInfTriC[nQtd][5]
		Next
		oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
		oPrint:Say(nLin ,nCol+020	  ,STR0043,oArial14N)//"TOTAL GERAL"
		oPrint:Say(nLin ,nCol+1440	  ,Space(14-Len(Alltrim(Str(nTotDep))))+Transform(nTotDep,"@E 999,999,999.99"),oArial14N)
		nTotDep:=0
		oPrint:Say(3050  ,2100,STR0055+Alltrim(Str(nPag)),oArial12N)//"Pagina: "
		oPrint:EndPage()
	Endif
Endif
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ DetFunc ³  Autor ³Marcos Kato              ³ Data ³ 16/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ layout da informacao trimestral funcionario           	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function DetFunc(aDadFunc)
Local cCCusto       :="",cDepFun	:=" "
Local nQtd			:=0 ,nTotCC		:=0

aSort(aDadFunc,,,{|x,y|x[1]+x[7]+x[6]+x[2]+x[3]<y[1]+y[7]+y[6]+y[2]+x[3]})
nLin+=100
cCCusto:=aDadFunc[1][1]
cDepFun:=aDadFunc[1][7]
oPrint:Say(nLin    ,nCol+020	  ,cCCusto,oArial14N)//"CENTRO DE CUSTO"
nLin+=100
oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
oPrint:Say(nLin ,nCol+020	  ,aDadFunc[1][8]	,oArial14N)//"DEPARTAMENTO"
nLin+=100

For nQtd:=1 To Len(aDadFunc)
	If nLin>2800
		oPrint:Say(3050  ,2100,STR0055+Alltrim(Str(nPag)),oArial12N)//"Pagina: "
		oPrint:EndPage()
		oPrint:Startpage()
		nPag++
		nCol:=100
		oPrint:Line(100 ,nCol     ,100 ,2200)
		oPrint:Box(150  ,nCol     ,2900,2200)
		nLin:=350
		nCol+=100
		oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
		oPrint:Line(nLin-50,620 ,nLin+50, 620)
		oPrint:Line(nLin-50,1020,nLin+50,1020)
		oPrint:Line(nLin-50,1240,nLin+50,1240)
		oPrint:Line(nLin-50,1560,nLin+50,1560)
		oPrint:Say(nLin ,nCol+020	  ,STR0047,oArial14N)//"SOBRENOME"
		oPrint:Say(nLin ,nCol+440	  ,STR0048,oArial14N)//"NOMES"
		oPrint:Say(nLin ,nCol+840	  ,STR0049,oArial14N)//"DT.ADMISSA"
		oPrint:Say(nLin ,nCol+1060	  ,STR0050,oArial14N)//"SALARIO"
		oPrint:Say(nLin ,nCol+1380	  ,STR0051,oArial14N)//"CARGO"
		nLin+=100
	Endif
	If 	cDepFun==aDadFunc[nQtd][7]
		oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
		oPrint:Line(nLin-50,620 ,nLin+50, 620)
		oPrint:Line(nLin-50,1020,nLin+50,1020)
		oPrint:Line(nLin-50,1240,nLin+50,1240)
		oPrint:Line(nLin-50,1560,nLin+50,1560)
		oPrint:Say(nLin    ,nCol+020	  ,Substr(aDadFunc[nQtd][3],1,15)	,oArial12N)//"SOBRENOMES"
		oPrint:Say(nLin    ,nCol+440	  ,Substr(aDadFunc[nQtd][2],1,15)   ,oArial12N)//"NOMES"
		oPrint:Say(nLin    ,nCol+840	  ,aDadFunc[nQtd][4]				,oArial12N) //"DT.ADMISSA"
		oPrint:Say(nLin    ,nCol+1060	  ,Space(14-Len(Alltrim(Str(aDadFunc[nQtd][5]))))+Transform(aDadFunc[nQtd][5],"@E 999,999,999.99"),oArial12N)//"SALARIO"
		oPrint:Say(nLin    ,nCol+1380	  ,Substr(aDadFunc[nQtd][6],1,20)    ,oArial12N)//"CARGO"
		nTotCC+=aDadFunc[nQtd][5]
	Else
		If nQtd>1
			oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
			oPrint:Say(nLin ,nCol+020	  ,STR0052	,oArial14N)//"TOTAL"
			oPrint:Say(nLin ,nCol+1500	  ,Transform(nTotCC,"@E 999,999,999.99"),oArial14N)
			nTotCC:=0
			nLin+=200
			If cCCusto<>aDadFunc[nQtd][1]
				oPrint:Say(nLin    ,nCol+020	  ,aDadFunc[nQtd][1],oArial14N)//"CENTRO DE CUSTO"
				nLin+=100
			Endif
		Endif
		oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
		oPrint:Say(nLin ,nCol+020	  ,aDadFunc[nQtd][8]	,oArial14N)//"DEPARTAMENTO"
		nLin+=100
		oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
		oPrint:Line(nLin-50,620 ,nLin+50, 620)
		oPrint:Line(nLin-50,1020,nLin+50,1020)
		oPrint:Line(nLin-50,1240,nLin+50,1240)
		oPrint:Line(nLin-50,1560,nLin+50,1560)
		
		oPrint:Say(nLin ,nCol+020	  ,STR0047,oArial14N)//"SOBRENOME"
		oPrint:Say(nLin ,nCol+440	  ,STR0048,oArial14N)//"NOMES"
		oPrint:Say(nLin ,nCol+840	  ,STR0049,oArial14N)//"DT.ADMISSA"
		oPrint:Say(nLin ,nCol+1060	  ,STR0050,oArial14N)//"SALARIO"
		oPrint:Say(nLin ,nCol+1380	  ,STR0051,oArial14N)//"CARGO"
		
		nLin+=100
		
		oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
		oPrint:Line(nLin-50,620 ,nLin+50, 620)
		oPrint:Line(nLin-50,1020,nLin+50,1020)
		oPrint:Line(nLin-50,1240,nLin+50,1240)
		oPrint:Line(nLin-50,1560,nLin+50,1560)
		oPrint:Say(nLin    ,nCol+020	  ,Substr(aDadFunc[nQtd][3],1,15)	,oArial12N)//"SOBRENOME"
		oPrint:Say(nLin    ,nCol+440	  ,Substr(aDadFunc[nQtd][2],1,15)   ,oArial12N)//"NOMES"
		oPrint:Say(nLin    ,nCol+840	  ,aDadFunc[nQtd][4]				,oArial12N) //"DT.ADMISSA"
		oPrint:Say(nLin    ,nCol+1060	  ,Space(14-Len(Alltrim(Str(aDadFunc[nQtd][5]))))+Transform(aDadFunc[nQtd][5],"@E 999,999,999.99"),oArial12N)//"SALARIO"
		oPrint:Say(nLin    ,nCol+1380	  ,Substr(aDadFunc[nQtd][6],1,20)    ,oArial12N)//"CARGO"
		nTotCC+=aDadFunc[nQtd][5]
	Endif
	nLin+=100
	cCCusto:=aDadFunc[nQtd][1]
	cDepFun:=aDadFunc[nQtd][7]
Next
oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
oPrint:Say(nLin ,nCol+020	  ,STR0052	,oArial14N)//"TOTAL"
oPrint:Say(nLin ,nCol+1500	  ,Transform(nTotCC,"@E 999,999,999.99"),oArial14N)
nTotCC:=0
nLin+=200
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ TotGerDep³ Autor ³Marcos Kato              ³ Data ³ 16/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Layout da informacao trimestral total departamento     	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/


Static Function TotGerDep()
Local nQtd			:= 0 ,nSalTri		:= 0 ,nTotTri       := 0
Local cDepTri		:= "",cTotTri		:= "",cCTriDep		:= "",cDTriDep		:= "",cCTriCar		:= "",cDTriCar		:= ""
Local aTotTriD		:= {}

If Len(aInfTriT)>0
	aSort(aInfTriT,,,{|x,y|x[1]+x[3]<y[1]+y[3]})//Ordem Cod.Depart. e Cod.cargo
	cDepTri:=Alltrim(aInfTriT[1][1])+Alltrim(aInfTriT[1][3])
	For nQtd:=1 To Len(aInfTriT)
		If cDepTri<>Alltrim(aInfTriT[nQtd][1])+Alltrim(aInfTriT[nQtd][3])
			aadd(aTotTriD,{cCTriDep,cDTriDep,cCTriCar,cDTriCar,nSalTri})
			nSalTri:=0
		Endif
		cCTriDep:=aInfTriT[nQtd][1]
		cDTriDep:=aInfTriT[nQtd][2]
		cCTriCar:=aInfTriT[nQtd][3]
		cDTriCar:=aInfTriT[nQtd][4]
		nSalTri+=aInfTriT[nQtd][5]
		cDepTri:=Alltrim(aInfTriT[nQtd][1])+Alltrim(aInfTriT[nQtd][3])
	Next
	aadd(aTotTriD,{cCTriDep,cDTriDep,cCTriCar,cDTriCar,nSalTri})
	aSort(aTotTriD,,,{|x,y|x[1]+x[3]<y[1]+y[3]})//Ordem Cod.Depart. e Cod.cargo

	oPrint:StartPage()
	nPag++
	nCol:=100
	oPrint:Line(100 ,nCol     ,100 ,2200)
	oPrint:Box(150  ,nCol     ,2900,2200)
	nCol+=100
	oPrint:Say(250  ,nCol	  ,STR0053+cTrimest+STR0026+cAnoBase ,oArial14N)//"TOTAL TRIMESTRAL POR DEPARTAMENTO DO "," DO ANO DE "
	nLin:=350
	nLin+=100
	For nQtd:=1 To Len(aTotTriD)
		If nLin>2800
			nCol:=100
			oPrint:Line(100 ,nCol-100     ,100 ,2200)
			oPrint:Box(150  ,nCol-100     ,2900,2200)
			nCol+=100
			oPrint:Say(250  ,nCol	  ,STR0053+cTrimest+STR0026+cAnoBase ,oArial14N)//"TOTAL TRIMESTRAL POR DEPARTAMENTO DO "," DO ANO DE "
			nLin:=350
		Endif
		If 	cDepTri==aTotTriD[nQtd][1]
			oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
			oPrint:Line(nLin-50,nCol+1000,nLin+50,nCol+1000)
			oPrint:Say(nLin    ,nCol+020	  ,aTotTriD[nQtd][4]   ,oArial12N)//"CARGO"
			oPrint:Say(nLin    ,nCol+1400	  ,Space(14-Len(Alltrim(Str(aTotTriD[nQtd][5]))))+Transform(aTotTriD[nQtd][5],"@E 999,999,999.99"),oArial12N)//"SALARIO"
			nLin+=100
		Else
			If nQtd>1
				oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
				oPrint:Say(nLin ,nCol+020	  ,STR0043			,oArial14N)//"TOTAL GERAL"
				oPrint:Say(nLin ,nCol+1340	  ,Space(14-Len(Alltrim(Str(nTotTri))))+Transform(nTotTri,"@E 999,999,999.99"),oArial14N)
				nTotTri:=0
				nLin+=200
			Endif
			oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
			oPrint:Say(nLin  ,nCol+020	,STR0044		 ,oArial14N)//"DEPARTAMENTO"
			oPrint:Say(nLin  ,nCol+1020	,aTotTriD[nQtd][2]   ,oArial12N)//"CARGO"
			nLin+=100
			oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
			oPrint:Line(nLin-50,nCol+1000,nLin+50,nCol+1000)
			oPrint:Say(nLin  ,nCol+020 	,STR0045,oArial14N)//"CARGO"
			oPrint:Say(nLin  ,nCol+1020	,STR0046,oArial14N)//"SALDO DE SALARIO"
			nlin+=100
			oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
			oPrint:Line(nLin-50,nCol+1000,nLin+50,nCol+1000)
			oPrint:Say(nLin  ,nCol+020	,aTotTriD[nQtd][4]   ,oArial12N)//"CARGO"
			oPrint:Say(nLin  ,nCol+1400	,Space(14-Len(Alltrim(Str(aTotTriD[nQtd][5]))))+Transform(aTotTriD[nQtd][5],"@E 999,999,999.99"),oArial12N)//"SALARIO"
			nLin+=100
		Endif
		cDepTri:=aTotTriD[nQtd][1]
		nTotTri+=aTotTriD[nQtd][5]
	Next
	oPrint:Box(nLin-50 ,nCol,nLin+50,2100)
	oPrint:Say(nLin ,nCol+020	  ,STR0043			,oArial14N)//"TOTAL GERAL"
	oPrint:Say(nLin ,nCol+1340	  ,Space(14-Len(Alltrim(Str(nTotTri))))+Transform(nTotTri,"@E 999,999,999.99"),oArial14N)
	nTotTri:=0
	oPrint:Say(3050  ,2100,STR0055+Alltrim(Str(nPag)),oArial12N)//"Pagina: "
	oPrint:EndPage()
Endif