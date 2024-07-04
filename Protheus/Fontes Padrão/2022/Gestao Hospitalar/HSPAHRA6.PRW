#INCLUDE "HSPAHRA6.ch"
#include "rwmake.ch"
#include "TopConn.ch"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRA6  ºAutor³ANTONIO CARLOS/Marceloº Data ³  18/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELATORIO DA AGENDA AMBULATORIAL OU CIRURGICA              º±±
±±º          ³ ESTATISTICA DAS MARCACOES HORARIA NO PERIODO.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs:      ³ Convertido para relatorios personalizaveis                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPRA6AM()
 cAlias:="GM8"
 HSPAHRA6("GM8")
Return()

Function HSPRA6CI()
 cAlias:="GMJ"
 HSPAHRA6("GMJ")
Return() 

/***********************************/
Static Function HSPAHRA6(cAlias)
 Local oReport
 Private lTmpR4:=.F.
 If FindFunction("TRepInUse") .And. TRepInUse() 
  Private aRegistros := {}
  Private Limite := 132
  Private vTotal:=0
  Private oTempTRB
  IIF(cAlias=="GM8",pergunte("HSRA6A",.F.),pergunte("HSRA6C",.F.))
  oReport := ReportDef() 
  oReport:PrintDialog()
  
  if( select( "TMPR4" ) > 0 )
  	oTempTRB:Delete()
  endIf
 ELSE  
  HSPAHRA6R3(cAlias)  
 EndIF    

Return( Nil )     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Marcelo Jose          ³ Data ³ 18/08/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4
 Local oCell
 Local vTotGer:=0

 oReport := TReport():New((IIF(cAlias=="GM8","HSPRA6AM","HSPRA6CI")),HS_MontCabe(STR0008 + (IIF(cAlias=="GM8",STR0022,STR0023)),MV_PAR03,MV_PAR04),(IIF(cAlias=="GM8","HSRA6A","HSRA6C")),{|oReport| RA6IMP(oReport)}, STR0001 + STR0002 + STR0003)  
  //###"Estat. das Marcacoes" ###"Ambulat.  ###"Cirurgicas"  ###"Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

 oReport:SetPortrait()          
 oSection1:=TRSection():New(oReport,STR0008,{"TMPR4"})  //"Estat. das Marcacoes"
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderBreak(.T.) 
 oSection1:SetNoFilter({"TMPR4"})
 oCell := TRCell():New(oSection1,"cUSUARIO" ,"TMPR4",STR0032,,20)             //"Usuário"
 oCell := TRCell():New(oSection1,"cTIPO"    ,"TMPR4",STR0033 ,""      ,10)    //"tipo: "
 oCell := TRCell():New(oSection1,"nQTDANT7" ,"TMPR4",STR0034  ,"999.99",05)   //"Antes"
 oCell := TRCell():New(oSection1,"nQTDATE7" ,"TMPR4","07:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE8" ,"TMPR4","08:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE9" ,"TMPR4","09:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE10","TMPR4","10:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE11","TMPR4","11:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE12","TMPR4","12:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE13","TMPR4","13:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE14","TMPR4","14:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE15","TMPR4","15:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE16","TMPR4","16:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE17","TMPR4","17:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE18","TMPR4","18:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDATE19","TMPR4","19:00"  ,"999.99",05)
 oCell := TRCell():New(oSection1,"nQTDAPO19","TMPR4",STR0035  ,"999.99",05)  //"Após "
 oCell := TRCell():New(oSection1,"nQTDTOTAL","TMPR4",STR0036  ,"999.99",05)  //"Total"

 oBreak := TRBreak():New(oSection1,oSection1:Cell("cUSUARIO"),"",.T.) 
 
 Return( oReport )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RA6Imp    ³ Autor ³ Marcelo Jose          ³ Data ³ 18/09/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RA6IMP(oReport)

Local oSection1 := oReport:Section(1)
Local aCampos   := {}
Local nInt      := 1                   
Local nPos      := 1
Local nCol      := 1  
Local nContaR   := 0
Local nResQ     := 0
Local nResP     := 0

If cAlias="GM8"
 BeginSql alias "QRYRA6"
	  SELECT GM8_FILAGE AS FILAGE, GM8_CODUSU AS CODUSU, GM8_HORCAD AS HORCAD
    FROM %table:GM8% GM8
  WHERE GM8_FILIAL = %xFilial:GM8% AND GM8.%notDel%
    AND GM8_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
    AND GM8_DATCAD BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)% 
    AND GM8_STATUS IN (%Exp:'1'%, %Exp:'3'%, %Exp:'4'%, %Exp:'5'%, %Exp:'6'%) 
  ORDER BY GM8_FILAGE, GM8_CODUSU
 EndSql
else
 BeginSql alias "QRYRA6"
  SELECT GMJ_FILAGE AS FILAGE, GMJ_CODUSU AS CODUSU, GMJ_HORCAD AS HORCAD
    FROM %table:GMJ% GMJ
  WHERE GMJ_FILIAL = %xFilial:GMJ% AND GMJ.%notDel%
    AND GMJ_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
    AND GMJ_DATCAD BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)% 
    AND GMJ_STATUS IN (%Exp:'1'%, %Exp:'3'%, %Exp:'4'%, %Exp:'5'%, %Exp:'6'%) 
  ORDER BY GMJ_FILAGE, GMJ_CODUSU
 EndSql
endif
      
While ("QRYRA6")->(!Eof())

 cNomUsu := QRYRA6->CODUSU

 nPos := 	aScan(aRegistros, {| aVet | aVet[1] == QRYRA6->FILAGE .And. aVet[2] == QRYRA6->CODUSU .And. aVet[19] == STR0037 } ) //"Qtde"
 	
	If nPos == 0
		aAdd(aRegistros, {QRYRA6->FILAGE, QRYRA6->CODUSU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,STR0037,1}) // quantidade //"Qtde"
		aAdd(aRegistros, {QRYRA6->FILAGE, QRYRA6->CODUSU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,"(%) ",2}) // percentual
		nPos := len(aRegistros) - 1
 Endif
 
	nHora := VAL(SUBSTR(QRYRA6->HORCAD,1,2))              
	
 // monta a linha de quantidades
	If nHora < 07                                   
		aRegistros [nPos][03]++         // Antes das 07:00 Hs.
 ElseIf nHora > 19                               
 	aRegistros [nPos][17]++         // APOS AS 19:00 Hs.
 Else
 	aRegistros [nPos][nHora-3]++   // entre 07:00 e 19:00
 Endif
 
 aRegistros [nPos][18]++         // total

	DbSkip()

EndDo  

 // monta a linha de percentual
FOR nPos := 1 to Len(aRegistros)step 2
  FOR nCol := 3 to 17                               
		aRegistros [nPos+1][nCol] :=  ( aRegistros[nPos][nCol]  / aRegistros[nPos][18] ) * 100    // Antes das 07:00 Hs.
  NEXT nCol
  aRegistros [nPos+1][18]   := aRegistros[nPos][18]  // usado para o Asort
NEXT nPos

If MV_PAR05 == 1
	aSort(aRegistros,,,{|x,y| x[1] + x[2] + Str(x[20]) < y[1] + y[2] + Str(y[20]) } ) //Classificado por Filial e Nome
Else
	aSort(aRegistros,,,{|x,y| x[1] + Str(x[18]) + x[2] + Str(x[20]) < y[1] + Str(y[18])  + y[2] + Str(y[20]) } ) //Classificado por Filial e pela Quantidade Total em ordem decrescente.
Endif

aAdd(aRegistros, {"", STR0038, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,STR0037,1}) // quantidade //"RESUMO ======> "###"Qtde"
aAdd(aRegistros, {"", "               ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,"(%) ",2}) // percentual
                  
// PARA SOMAR OS TOTAIS DE QUANTIDADES
nContaR:= Len(aRegistros) - 2
nResQ  := Len(aRegistros) - 1
nResP  := Len(aRegistros)
FOR nPos := 1 to nContaR step 2
  FOR nCol := 3 to 18
		aRegistros [nResQ][nCol] := aRegistros [nResQ][nCol] +  aRegistros[nPos][nCol]
  NEXT nCol
NEXT nPos
                                      
// PARA CALCULAR O TOTAL DE PERCENTUAIS
FOR nCol := 3 to 17                               
 aRegistros [nResP][nCol] := ( aRegistros [nResQ][nCol] /  aRegistros[nResQ][18] ) * 100
NEXT
		             
DbCloseArea()

// CRIA OS CAMPOS DA TABELA TEMPORARIA
aAdd(aCampos, {"CFILAGE" , "C",20,0})
aAdd(aCampos, {"CUSUARIO" , "C",20,0})
aAdd(aCampos, {"nQtdAnt7" , "N", 6,2})
aAdd(aCampos, {"nQtdAte7" , "N", 6,2})
aAdd(aCampos, {"nQtdAte8" , "N", 6,2})
aAdd(aCampos, {"nQtdAte9" , "N", 6,2})
aAdd(aCampos, {"nQtdAte10", "N", 6,2})
aAdd(aCampos, {"nQtdAte11", "N", 6,2})
aAdd(aCampos, {"nQtdAte12", "N", 6,2})
aAdd(aCampos, {"nQtdAte13", "N", 6,2})
aAdd(aCampos, {"nQtdAte14", "N", 6,2})
aAdd(aCampos, {"nQtdAte15", "N", 6,2})
aAdd(aCampos, {"nQtdAte16", "N", 6,2})
aAdd(aCampos, {"nQtdAte17", "N", 6,2})
aAdd(aCampos, {"nQtdAte18", "N", 6,2})
aAdd(aCampos, {"nQtdAte19", "N", 6,2})
aAdd(aCampos, {"nQtdApo19", "N", 6,2})
aAdd(aCampos, {"nQtdTotal", "N", 6,2})
aAdd(aCampos, {"cTipo"    , "C", 4,0})

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TMPR4" )
oTempTRB:SetFields( aCampos )
oTempTRB:AddIndex( "INDTRB",{ "CFILAGE","CUSUARIO" } )

if( select( "TMPR4" ) > 0 )
	TMPR4->( dbCloseArea() )
endIf

oTempTRB:Create()

For nInt := 1 to Len(aRegistros)
 RecLock("TMPR4", .T.)
 TMPR4->CFILAGE   := aRegistros[nInt,01] 
 TMPR4->CUSUARIO  := aRegistros[nInt,02] 
 TMPR4->nQtdAnt7  := aRegistros[nInt,03] 
 TMPR4->nQtdAte7  := aRegistros[nInt,04]
 TMPR4->nQtdAte8  := aRegistros[nInt,05]
 TMPR4->nQtdAte9  := aRegistros[nInt,06]
 TMPR4->nQtdAte10 := aRegistros[nInt,07]
 TMPR4->nQtdAte11 := aRegistros[nInt,08]
 TMPR4->nQtdAte12 := aRegistros[nInt,09]
 TMPR4->nQtdAte13 := aRegistros[nInt,10]
 TMPR4->nQtdAte14 := aRegistros[nInt,11]
 TMPR4->nQtdAte15 := aRegistros[nInt,12]
 TMPR4->nQtdAte16 := aRegistros[nInt,13]
 TMPR4->nQtdAte17 := aRegistros[nInt,14]
 TMPR4->nQtdAte18 := aRegistros[nInt,15]
 TMPR4->nQtdAte19 := aRegistros[nInt,16]
 TMPR4->nQtdApo19 := aRegistros[nInt,17]
 TMPR4->nQtdTotal := aRegistros[nInt,18] 
 TMPR4->cTipo     := aRegistros[nInt,19]  
 MsUnlock()
Next
DbGotop()     

oReport:SetMeter(("TMPR4")->(LastRec()))
oSection1:Print()

lTmpR4:=.T.
Return( NIL )
/*************************************************************************************************************/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRA6R3º Autor ³ GILSON DA SILVA    º Data ³Janeiro/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELATORIO DA AGENDA AMBULATORIAL OU CIRURGICA              º±±
±±º          ³ ESTATISTICA DAS MARCACOES HORARIA NO PERIODO.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
 
Static Function HSPAHRA6R3(cAlias)
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local aOrd           := {}
 Local aArea          := GetArea()

 Private Cabec1       := STR0006 //"Usuario               Antes  07:00  08:00  09:00  10:00  11:00  12:00  13:00  14:00  15:00  16:00  17:00  18:00  19:00   Apos  Total"
 Private Cabec2       := ""
 Private Titulo       := STR0003 //"Estatistica das Marcacoes Horarias no Periodo"
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := FunName()
 Private nTipo        := 15
 Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private m_pag        := 01
 Private wnrel        := "HSPAHRA6"
 Private cString      := ""
 Private aRegistros   := {}
 Private aVetor       := {}
 Private nLin         := 80
 Private nQtFil       := 0
 Private cFilAge_De   := ""
 Private cFilAge_Ate  := ""
 Private dDatCad_De   := ""
 Private dDatCad_Ate  := ""
 Private nOrdRel      := 0
 Private nGrafico     := 0

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ PARAMETROS                                                         ³
 //³ MV_PAR01	Da Filial                                                 ³ 
 //³ MV_PAR02	Ate a Filial                                              ³
 //³ MV_PAR03 Data Inicial das Marcacoes                                ³
 //³ MV_PAR04	Data Final das Marcacoes                                  ³
 //³ MV_PAR05	Ordem de Impressao  1=Nome    2= Quantidade Decrescente   ³
 //³ MV_PAR06	Grafico  1=Nao  2=Sim                                     ³
 //| MV_PAR07 Impressora ?                                              |
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 cPerg := IIF(cAlias=="GM8", "HSRA6A", "HSRA6C")   
 If !Pergunte(cPerg, .T.)
  Return()
 Endif

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 cFilAge_De   := mv_par01
 cFilAge_Ate  := mv_par02
 dDatCad_De   := mv_par03
 dDatCad_Ate  := mv_par04
 nOrdRel      := mv_par05
 nGrafico     := mv_par06

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta a interface padrao com o usuario...                           ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 If nLastKey == 27
 	Return()
 Endif

 SetDefault(aReturn,cString)
 If nLastKey == 27
 	Return()
 Endif

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 RptStatus({|| RunReport(cAlias, Cabec1, Cabec2, Titulo) }, Titulo)

 RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Gilson da Silva    º Data ³Janeiro/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(cAlias)
 Local cPref       := cAlias + "." + PrefixoCpo(cAlias)  
 Local cNomUsu     := ""                                     
 Local lRet        := .T.                                   
 Local nInt        := 0                                     
 Local nTotal      := 0                                      
 Local nPos        := 0
 Local nCont       := 0
 Local cFilAge     := ""
 Local nCtaFor     := 0
 Local cSQL        := ""
 Local nHora       := ""
 
 Titulo := STR0008 + IIF(cAlias=="GM8", STR0022, STR0023) + ;
           STR0024 + Dtoc(mv_par03)+STR0009+Dtoc(mv_par04)
 
 cSQL   := "SELECT " + cPref+"_FILAGE AS FILAGE, " + cPref+"_CODUSU AS CODUSU, " + cPref+"_HORCAD AS HORCAD "
 cSQL   += "FROM " + RetSQLName(cAlias) + " " + cAlias
 cSQL   += " WHERE "
 cSQL   += cPref+"_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + "." + "D_E_L_E_T_ <> '*' AND "
 cSQL   += cPref+"_FILAGE BETWEEN '" + cFilAge_De + "' AND '" + cFilAge_Ate + "' AND "
 cSQL   += cPref+"_DATCAD BETWEEN '" + DTOS(dDatCad_De) + "' AND '" + DTOS(dDatCad_Ate) + "' AND " 
 cSQL   += cPref+"_STATUS IN ('1', '3', '4', '5', '6') "
 cSQL   += "ORDER BY " + cPref+"_FILAGE, " + cPref+"_CODUSU"
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0021, STR0024, STR0025) //"Nenhum dado foi encontrado para a selecao efetuada."###"Atenção"###"Verifique a seleção"
  DbCloseArea()
  Return()
 Endif 

 SetRegua(1000)
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Carrega o vetor aRegistros com todos os dados a serem impressos.    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 While !EOF()
	
 	cNomUsu := QRY->CODUSU
 	nPos := aScan(aRegistros, { |x| x[1]+x[2] == QRY->FILAGE+QRY->CODUSU })
 	
 	If nPos == 0
 		aAdd(aRegistros, {QRY->FILAGE, QRY->CODUSU, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
 		nCont++
 		nPos := len(aRegistros)
 	Endif
 	nHora := VAL(SUBSTR(QRY->HORCAD,1,2))
 	If nHora < 07                                   //Antes das 07:00 Hs.
 		aRegistros [nPos][03]++
	 ElseIf nHora > 19                               //APOS AS 19:00 Hs.
	 	aRegistros [nPos][17]++
	 Else
	 	aRegistros [nPos][nHora-3]++
	 Endif
	 aRegistros [nPos][18]++
	 nTotal ++
	
 	DbSkip()
	 IncRegua()
 EndDo
 DbCloseArea()
 
 If nOrdRel == 1
 	aSort(aRegistros,,,{|x,y| x[1]+x[2] < y[1]+y[2]}) //Classificado por Filial e Nome
 Else
 	aSort(aRegistros,,,{|x,y| x[1]+Str(x[18]) > y[1]+Str(y[18])}) //Classificado por Filial e pela Quantidade Total em ordem decrescente.
 Endif

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se visualiza grafico cartesiano...                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If nGrafico == 2 
  aAdd(aVetor,{0,"Antes"}); aAdd(aVetor,{0,"07:00"}); aAdd(aVetor,{0,"08:00"}); aAdd(aVetor,{0,"09:00"})
  aAdd(aVetor,{0,"10:00"}); aAdd(aVetor,{0,"11:00"}); aAdd(aVetor,{0,"12:00"}); aAdd(aVetor,{0,"13:00"})
  aAdd(aVetor,{0,"14:00"}); aAdd(aVetor,{0,"15:00"}); aAdd(aVetor,{0,"16:00"}); aAdd(aVetor,{0,"17:00"})
  aAdd(aVetor,{0,"18:00"}); aAdd(aVetor,{0,"19:00"}); aAdd(aVetor,{0,"Apos "})                            
            
  For nCtaFor := 1 to Len(aRegistros) /* prepara um vetor contendo o percentual eixo y e usuarios + total de agendamento */
  	aVetor[ 1,1] += aRegistros[nCtaFor,03]
  	aVetor[ 2,1] += aRegistros[nCtaFor,04]
  	aVetor[ 3,1] += aRegistros[nCtaFor,05]
  	aVetor[ 4,1] += aRegistros[nCtaFor,06]
  	aVetor[ 5,1] += aRegistros[nCtaFor,07]
  	aVetor[ 6,1] += aRegistros[nCtaFor,08]
  	aVetor[ 7,1] += aRegistros[nCtaFor,09]
  	aVetor[ 8,1] += aRegistros[nCtaFor,10]
  	aVetor[ 9,1] += aRegistros[nCtaFor,11]
  	aVetor[10,1] += aRegistros[nCtaFor,12]
  	aVetor[11,1] += aRegistros[nCtaFor,13]
  	aVetor[12,1] += aRegistros[nCtaFor,14]
  	aVetor[13,1] += aRegistros[nCtaFor,15]
  	aVetor[14,1] += aRegistros[nCtaFor,16]
  	aVetor[15,1] += aRegistros[nCtaFor,17]
  Next  

  For nCtaFor := 1 to 15
  	aVetor[nCtaFor ,1] := VAL(STR(((aVetor[nCtaFor,1]*100) / nTotal ),6,2))
  Next
    
  /* cria o objeto para contrucao do grafico */
  oGraf := hsGRAF():NEW(STR0039, STR0027 + DtoC(MV_PAR03) +STR0028 + DtoC(MV_PAR04)+STR0029+Str(nTotal,5,0)+STR0030, STR0031, "", STR0040, "", aVetor,1,1,0,0,2,5,6,6,25,20) //"Marcacao Horario no periodo: "###" a "###"    totalizando "###" marcacoes"###"Percentual % dos horarios" //"AGENDA AMBULATORIAL"###"HORARIOS "
 EndIf

	For nInt := 1 to Len(aRegistros)
		If lAbortPrint
			@nLin,000 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > nMaxLin // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 08
		Endif
		
		If !Empty(cFilAge) .And. aRegistros[nInt,1] <> cFilAge // Quebra por Filial de Agendamento
			ImpResFil(cFilAge)
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 08
		Endif
		
		@nLin,000 PSAY aRegistros[nInt,2] //Nome do Usuario
		@nLin,016 PSAY STR0011 // "Qtd."
		@nLin,021 PSAY Transform(aRegistros[nInt,03], "@E 99,999")  //Quantidades Antes das 07:00
		@nLin,028 PSAY Transform(aRegistros[nInt,04], "@E 99,999")  //Quantidades Ate as 07:00
		@nLin,035 PSAY Transform(aRegistros[nInt,05], "@E 99,999")  //Quantidades Ate as 08:00
		@nLin,042 PSAY Transform(aRegistros[nInt,06], "@E 99,999")  //Quantidades Ate as 09:00
		@nLin,049 PSAY Transform(aRegistros[nInt,07], "@E 99,999")  //Quantidades Ate as 10:00
		@nLin,056 PSAY Transform(aRegistros[nInt,08], "@E 99,999")  //Quantidades Ate as 11:00
		@nLin,063 PSAY Transform(aRegistros[nInt,09], "@E 99,999")  //Quantidades Ate as 12:00
		@nLin,070 PSAY Transform(aRegistros[nInt,10], "@E 99,999")  //Quantidades Ate as 13:00
		@nLin,077 PSAY Transform(aRegistros[nInt,11], "@E 99,999")  //Quantidades Ate as 14:00
		@nLin,084 PSAY Transform(aRegistros[nInt,12], "@E 99,999")  //Quantidades Ate as 15:00
		@nLin,091 PSAY Transform(aRegistros[nInt,13], "@E 99,999")  //Quantidades Ate as 16:00
		@nLin,098 PSAY Transform(aRegistros[nInt,14], "@E 99,999")  //Quantidades Ate as 17:00
		@nLin,105 PSAY Transform(aRegistros[nInt,15], "@E 99,999")  //Quantidades Ate as 18:00
		@nLin,112 PSAY Transform(aRegistros[nInt,16], "@E 99,999")  //Quantidades Ate as 19:00
		@nLin,119 PSAY Transform(aRegistros[nInt,17], "@E 99,999")  //Quantidades Apos as 19:00
		@nLin,126 PSAY Transform(aRegistros[nInt,18], "@E 99,999")  //Total do Usuario
		nLin++
		
		@nLin,016 PSAY "%"
		@nLin,021 PSAY Transform((aRegistros[nInt,03] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Antes das 07:00.
		@nLin,028 PSAY Transform((aRegistros[nInt,04] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 07:00.
		@nLin,035 PSAY Transform((aRegistros[nInt,05] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 08:00.
		@nLin,042 PSAY Transform((aRegistros[nInt,06] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 09:00.
		@nLin,049 PSAY Transform((aRegistros[nInt,07] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 10:00.
		@nLin,056 PSAY Transform((aRegistros[nInt,08] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 11:00.
		@nLin,063 PSAY Transform((aRegistros[nInt,09] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 12:00.
		@nLin,070 PSAY Transform((aRegistros[nInt,10] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 13:00.
		@nLin,077 PSAY Transform((aRegistros[nInt,11] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 14:00.
		@nLin,084 PSAY Transform((aRegistros[nInt,12] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 15:00.
		@nLin,091 PSAY Transform((aRegistros[nInt,13] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 16:00.
		@nLin,098 PSAY Transform((aRegistros[nInt,14] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 17:00 .
		@nLin,105 PSAY Transform((aRegistros[nInt,15] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 18:00.
		@nLin,112 PSAY Transform((aRegistros[nInt,16] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Ate as 19:00.
		@nLin,119 PSAY Transform((aRegistros[nInt,17] / aRegistros[nInt,18]) * 100, "@E 999.99") //Percentual Apos as 19:00.
		
		nLin := nLin + 2
		cFilAge := aRegistros[nInt,1]
	Next
	
	If nQtFil == 0
		ImpResFil(cFilAge)
	Else
		ImpResGer()
	EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Finaliza a execucao do relatorio...                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 SET DEVICE TO SCREEN

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se impressao em disco, chama o gerenciador de impressao...          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If aReturn[5]==1
 	dbCommitAll()
 	SET PRINTER TO
 	OurSpool(wnrel)
 Endif

 MS_FLUSH()

 DBSelectArea(cAlias)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ImpResFil º Autor ³ Gilson da Silva    º Data ³Janeiro/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime o resumo da Filial.                                º±±
±±º          ³ 																																													              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpResFil(cFilAge)
Local nInt   := 0
Local nAntes := 0
Local nApos  := 0
Local n07    := 0
Local n08    := 0
Local n09    := 0
Local n10    := 0
Local n11    := 0
Local n12    := 0
Local n13    := 0
Local n14    := 0
Local n15    := 0
Local n16    := 0
Local n17    := 0
Local n18    := 0
Local n19    := 0
Local nTotal := 0

nQtFil ++
For nInt := 1 to Len(aRegistros)
	If aRegistros[nInt,1] == cFilAge
		nAntes += aRegistros[nInt,03]
		n07    += aRegistros[nInt,04]
		n08    += aRegistros[nInt,05]
		n09    += aRegistros[nInt,06]
		n10    += aRegistros[nInt,07]
		n11    += aRegistros[nInt,08]
		n12    += aRegistros[nInt,09]
		n13    += aRegistros[nInt,10]
		n14    += aRegistros[nInt,11]
		n15    += aRegistros[nInt,12]
		n16    += aRegistros[nInt,13]
		n17    += aRegistros[nInt,14]
		n18    += aRegistros[nInt,15] 
		n19    += aRegistros[nInt,16]
		nApos  += aRegistros[nInt,17]
		nTotal += aRegistros[nInt,18]
	EndIf
Next

nLin := nLin + 2

If nLin > nMaxLin // Salto de Página. Neste caso o formulario tem 55 linhas...
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 08
Endif

@nLin,055 PSAY 	STR0010   //"R   E   S   U   M   O"
nLin++
@nLin,000 PSAY  Repl("-",132)
nLin ++
@nLin,000 PSAY STR0006  //"Usuario               Antes  07:00  08:00  09:00  10:00  11:00  12:00  13:00  14:00  15:00  16:00  17:00  18:00  19:00   Apos  Total"
nLin ++
@nLin,000 PSAY  STR0013 //"Filial "
@nLin,007 PSAY	 cFilAge
@nLin,016 PSAY STR0011 // "Qtd."
@nLin,021 PSAY Transform(nAntes, "@E 99,999")  //Quantidades Antes das 07:00
@nLin,028 PSAY Transform(n07, "@E 99,999")  //Quantidades Ate as 07:00
@nLin,035 PSAY Transform(n08, "@E 99,999")  //Quantidades Ate as 08:00
@nLin,042 PSAY Transform(n09, "@E 99,999")  //Quantidades Ate as 09:00
@nLin,049 PSAY Transform(n10, "@E 99,999")  //Quantidades Ate as 10:00
@nLin,056 PSAY Transform(n11, "@E 99,999")  //Quantidades Ate as 11:00
@nLin,063 PSAY Transform(n12, "@E 99,999")  //Quantidades Ate as 12:00
@nLin,070 PSAY Transform(n13, "@E 99,999")  //Quantidades Ate as 13:00
@nLin,077 PSAY Transform(n14, "@E 99,999")  //Quantidades Ate as 14:00
@nLin,084 PSAY Transform(n15, "@E 99,999")  //Quantidades Ate as 15:00
@nLin,091 PSAY Transform(n16, "@E 99,999")  //Quantidades Ate as 16:00
@nLin,098 PSAY Transform(n17, "@E 99,999")  //Quantidades Ate as 17:00
@nLin,105 PSAY Transform(n18, "@E 99,999")  //Quantidades Ate as 18:00
@nLin,112 PSAY Transform(n19, "@E 99,999")  //Quantidades Ate as 19:00
@nLin,119 PSAY Transform(nApos, "@E 99,999")//Quantidades Apos as 19:00
@nLin,126 PSAY Transform(nTotal,"@E 99,999")//Total da Filial

nLin ++

@nLin,016 PSAY "%"
@nLin,021 PSAY Transform((nAntes /nTotal) * 100, "@E 999.99")  //Percentual Antes das 07:00.
@nLin,028 PSAY Transform((n07/nTotal) * 100, "@E 999.99")  //Percentual Ate as 07:00.
@nLin,035 PSAY Transform((n08/nTotal) * 100, "@E 999.99")  //Percentual Ate as 08:00.
@nLin,042 PSAY Transform((n09/nTotal) * 100, "@E 999.99")  //Percentual Ate as 09:00.
@nLin,049 PSAY Transform((n10/nTotal) * 100, "@E 999.99")  //Percentual Ate as 10:00.
@nLin,056 PSAY Transform((n11/nTotal) * 100, "@E 999.99")  //Percentual Ate as 11:00.
@nLin,063 PSAY Transform((n12/nTotal) * 100, "@E 999.99")  //Percentual Ate as 12:00.
@nLin,070 PSAY Transform((n13/nTotal) * 100, "@E 999.99")  //Percentual Ate as 13:00.
@nLin,077 PSAY Transform((n14/nTotal) * 100, "@E 999.99")  //Percentual Ate as 14:00o.
@nLin,084 PSAY Transform((n15/nTotal) * 100, "@E 999.99")  //Percentual Ate as 15:00.
@nLin,091 PSAY Transform((n16/nTotal) * 100, "@E 999.99")  //Percentual Ate as 16:00.
@nLin,098 PSAY Transform((n17/nTotal) * 100, "@E 999.99")  //Percentual Ate as 17:00.
@nLin,105 PSAY Transform((n18/nTotal) * 100, "@E 999.99")  //Percentual Ate as 18:00.
@nLin,112 PSAY Transform((n19/nTotal) * 100, "@E 999.99")  //Percentual Ate as 19:00.
@nLin,119 PSAY Transform((nApos/nTotal) * 100, "@E 999.99")//Percentual Apos as 19:00. 

nLin ++

@nLin,000 PSAY  Repl("-",132)
nLin := nLin + 2
Return()  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ImpResGer º Autor ³ Gilson da Silva    º Data ³Janeiro/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime o resumo Geral.                                    º±±
±±º          ³ 																																													              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpResGer()

Local nInt   := 0
Local nAntes := 0
Local nApos  := 0
Local n07    := 0
Local n08    := 0
Local n09    := 0
Local n10    := 0
Local n11    := 0
Local n12    := 0
Local n13    := 0
Local n14    := 0
Local n15    := 0
Local n16    := 0
Local n17    := 0    
Local n18    := 0 
Local n19    := 0
Local nTotal := 0

For nInt := 1 to Len(aRegistros)
	nAntes += aRegistros[nInt,03]
	n07    += aRegistros[nInt,04]
	n08    += aRegistros[nInt,05]
	n09    += aRegistros[nInt,06]
	n10    += aRegistros[nInt,07]
	n11    += aRegistros[nInt,08]
	n12    += aRegistros[nInt,09]
	n13    += aRegistros[nInt,10]
	n14    += aRegistros[nInt,11]
	n15    += aRegistros[nInt,12]
	n16    += aRegistros[nInt,13]
	n17    += aRegistros[nInt,14]
	n18    += aRegistros[nInt,15]
	n19    += aRegistros[nInt,16]
	nApos  += aRegistros[nInt,17]
	nTotal += aRegistros[nInt,18]
Next

nLin := nLin + 2

If nLin > nMaxLin // Salto de Página. Neste caso o formulario tem 55 linhas...
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 08
Endif

@nLin,055 PSAY 	STR0010   //"R   E   S   U   M   O"
nLin++
@nLin,000 PSAY  Repl("-",132)
nLin ++
@nLin,000 PSAY STR0006  //"Usuario            Antes  07:00  08:00  09:00  10:00  11:00  12:00  13:00  14:00  15:00  16:00  17:00  18:00  19:00   Apos     Total"
nLin ++
@nLin,016 PSAY STR0011 // "Qtd."
@nLin,021 PSAY Transform(nAntes, "@E 99,999")//Quantidades Antes das 07:00
@nLin,028 PSAY Transform(n07, "@E 99,999") //Quantidades Ate as 07:00
@nLin,035 PSAY Transform(n08, "@E 99,999") //Quantidades Ate as 08:00
@nLin,042 PSAY Transform(n09, "@E 99,999") //Quantidades Ate as 09:00
@nLin,049 PSAY Transform(n10, "@E 99,999") //Quantidades Ate as 10:00
@nLin,056 PSAY Transform(n11, "@E 99,999") //Quantidades Ate as 11:00
@nLin,063 PSAY Transform(n12, "@E 99,999") //Quantidades Ate as 12:00
@nLin,070 PSAY Transform(n13, "@E 99,999") //Quantidades Ate as 13:00
@nLin,077 PSAY Transform(n14, "@E 99,999") //Quantidades Ate as 14:00
@nLin,084 PSAY Transform(n15, "@E 99,999") //Quantidades Ate as 15:00
@nLin,091 PSAY Transform(n16, "@E 99,999") //Quantidades Ate as 16:00
@nLin,098 PSAY Transform(n17, "@E 99,999") //Quantidades Ate as 17:00
@nLin,105 PSAY Transform(n18, "@E 99,999") //Quantidades Ate as 18:00
@nLin,112 PSAY Transform(n19, "@E 99,999") //Quantidades Ate as 19:00
@nLin,119 PSAY Transform(nApos, "@E 99,999")//Quantidades Apos as 19:00
@nLin,126 PSAY Transform(nTotal, "@E 99,999")//Total da Filial
nLin := nLin + 1                       
@nLin,000 PSAY  Repl("-",132)
Return ()                             


