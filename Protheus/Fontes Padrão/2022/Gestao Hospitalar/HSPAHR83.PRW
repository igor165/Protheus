#INCLUDE "HSPAHR83.ch"
#Include "protheus.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ              
ฑฑบPrograma  ณHSPAHR83  บ Autor ณ Mario Arizono      บ Data ณ  11/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de identificacao de matriculas invalidas         บฑฑ
ฑฑบ          ณ Alteracao para adequacao dos relatorios personalizaveis.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
FUNCTION HSPAHR83()

 Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR83",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE    
  HSPAHR83R3()  
 EndIF    
 
Return( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ              
ฑฑบPrograma  ณREPORTDEF บ Autor ณ Mario Arizono      บ Data ณ  11/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para tratamento das impressoes.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2
 Local oCell
 Local oTotaliz

 oReport := TReport():New("HSPAHR83",STR0004,"HSPR83",{|oReport| RDFIMP(oReport)},STR0003+" "+STR0003)
 //"Relatorio de Matriculas Invalidas por Convenio""Este relatorio tem por objetivo a impressao de pacientes com matriculas invalidas."

 oSection1 := TRSection():New(oReport,STR0015,{"GD4","GA9"}) //"Conv๊nio"
 oCell := TRCell():New(oSection1,"GD4_CODCON","GD4")
 oCell := TRCell():New(oSection1,"GA9_NREDUZ","GA9")
           
 oSection2 := TRSection():New(oSection1,STR0016,{"GD4", "GCM", "GBH"})  //"Pacientes"
 oCell := TRCell():New(oSection2,"GD4_REGGER","GD4",STR0017)   //"C๓digo"
 oCell := TRCell():New(oSection2,"GBH_NOME"  ,"GBH")
 oCell := TRCell():New(oSection2,"GD4_CODPLA","GD4")
 oCell := TRCell():New(oSection2,"GCM_DESPLA","GD4")
 oCell := TRCell():New(oSection2,"GD4_MATRIC","GD4",,,,,{|| IIF(EMPTY(QRYGD4->GD4_MATRIC),"-----------------", QRYGD4->GD4_MATRIC)})
  
 oTotaliz := TRFunction():new(oSection2:Cell("GD4_REGGER"),,"COUNT",,,,,.T.)  
 
Return( oReport )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ              
ฑฑบPrograma  ณRDFIMP    บ Autor ณ 	Mario Arizono     บ Data ณ  11/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao de impressao do relatorio.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RDFIMP(oReport)
 Local cGd4CodCon := ""

	MakeSqlExp("HSPR83")
	
 oReport:Section(1):BeginQuery()
  	
BeginSql alias "QRYGD4"

		SELECT GD4_CODCON, GD4_CODPLA, GD4_REGGER, GD4_MATRIC, GA9_NREDUZ, GA9_VLDMAT, GCM_DESPLA, GBH_NOME
		FROM %table:GD4% GD4
		LEFT JOIN %table:GA9% GA9 ON GA9.GA9_CODCON = GD4.GD4_CODCON AND GA9_FILIAL = %xfilial:GA9% AND GA9.%notDel%
  LEFT JOIN %table:GBH% GBH ON GBH.GBH_CODPAC = GD4.GD4_REGGER AND GBH_FILIAL = %xfilial:GBH% AND GBH.%notDel%
  LEFT JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GD4.GD4_CODPLA AND GCM_FILIAL = %xfilial:GCM% AND GCM.%notDel%
		WHERE GD4_FILIAL = %xfilial:GD4% AND GD4.%notDel%
  AND GD4.GD4_CODCON BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
  
  ORDER BY GD4_CODCON, GD4_REGGER, GD4_CODPLA

EndSql 
	
 oReport:Section(1):EndQuery()                                 
 oReport:Section(1):Section(1):SetParentQuery()
 oReport:SetMeter(RecCount())
 DbSelectArea("QRYGD4")
 	
Do While !QRYGD4->(Eof())

	If oReport:Cancel()
		Exit
	EndIf     
	
	M->GD4_MATRIC:=QRYGD4->GD4_MATRIC
	
	If Empty(QRYGD4->GD4_MATRIC) .OR. !Empty(QRYGD4->GA9_VLDMAT) .AND. !&(QRYGD4->GA9_VLDMAT)[1]
	
	 If cGd4CodCon <> QRYGD4->GD4_CODCON 
  	If Empty (cGd4CodCon)	
   	oReport:Section(1):init() 
   	oReport:Section(1):Section(1):Init()
			 oReport:Section(1):PrintLine()	  
			 oReport:Section(1):Section(1):PrintLine() 
   Else  
    oReport:Section(1):Finish()   
    oReport:Section(1):Section(1):Finish()
    oReport:Section(1):SetPageBreak(.T.)
    oReport:Section(1):Init() 
    oReport:Section(1):PrintLine()	  
    oReport:Section(1):Section(1):Init()
    oReport:Section(1):Section(1):PrintLine()
   Endif 
  Else
	  oReport:Section(1):Section(1):PrintLine()
	 Endif   
	
  oReport:IncMeter()
  cGD4CodCon := QRYGD4->GD4_CODCON
 Endif
 
 QRYGD4->(dbskip())
 
Enddo

oReport:Section(1):Section(1):Finish()
oReport:Section(1):Finish()
  
Return( NIL )
/*****************************************************************************************************************/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ              
ฑฑบPrograma  ณHSPAHR83R3บ Autor ณ Patricia Queiroz   บ Data ณ  09/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de identificacao de matriculas invalidas         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR83R3()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cSQL:=""
Local cDesc1:=STR0002 //"Este programa tem como objetivo imprimir relatorio"
Local cDesc2:=STR0003 //"de acordo com os parametros informados pelo usuario."
Local cDesc3:= ""
Local cPict:= ""
Local titulo:=STR0004 //"Relatorio de Matriculas Invalidas por Convenio"
Local nLin:= 80
Local Cabec1:= ""
Local Cabec2:= ""
Local imprime:= .T.
Local aOrd:= {}
Private lEnd:= .F.
Private lAbortPrint:= .F.
Private limite:= 80
Private tamanho:= "M"
Private nomeprog:= "HSPAHR83" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo:= 18
Private aReturn:= { STR0005, 1, STR0006 , 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey:= 0
Private cbtxt:= Space(10)
Private cbcont:= 00
Private CONTFL:= 01
Private m_pag:= 01
Private wnrel:= "HSPAHR83" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cCodCon_De  := ""
Private cCodCon_Ate := ""
Private cCodImp:= ""
Private nMaxLin:=0

Private cString:= "GD4"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PARAMETROS                                                       ณ
//ณ MV_PAR01	Do convenio                                             ณ
//ณ MV_PAR02	Ate o convenio                                          ณ
//ณ MV_PAR03	Impressora                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If !Pergunte("HSPR83",.T.)
	Return()
EndIf

cCodCon_De:=mv_par01
cCodCon_Ate:=mv_par02
cCodImp:=mv_par03

nMaxLin := HS_MaxLin(cCodImp)

dbSelectArea("GD4")
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Patricia Queiroz   บ Data ณ  09/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cUltreg:="" //guarda o ultimo registro
Local nTotal:=0 
Local nTotGer:=0
dbSelectArea(cString)
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Selecao de Dados                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cSQL:= "SELECT GD4.GD4_CODCON,GD4.GD4_CODPLA,GD4.GD4_REGGER,GD4.GD4_MATRIC,"
cSQL+= " GA9.GA9_NREDUZ,GA9.GA9_VLDMAT,GCM.GCM_DESPLA,GBH.GBH_NOME"
cSQL+= " FROM "+RetSQLName("GD4")+ " GD4"
cSQL+= " LEFT JOIN "+RetSQLName("GA9")+ " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GD4.GD4_CODCON"
cSQL+= " LEFT JOIN "+RetSQLName("GBH")+ " GBH ON GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' AND GBH.GBH_CODPAC = GD4.GD4_REGGER"
cSQL+= " LEFT JOIN "+RetSQLName("GCM")+ " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GD4.GD4_CODPLA"
cSQL+= " WHERE GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*'"
cSQL+= " AND GD4.GD4_CODCON BETWEEN '" + (MV_PAR01) + "' AND '" + (MV_PAR02) + "'"
cSQL+= " ORDER BY GD4_CODCON,GD4_REGGER,GD4_CODPLA"

cSQL:=ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"

If Eof()
	HS_MsgInf(STR0007, STR0013, STR0014)  //"Nenhuma informacao fo encontrada para a selecao!"###"Aten็ใo"###"Verifique a sele็ใo"
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posicionamento do primeiro registro e loop principal. Pode-se criar ณ
//ณ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ณ
//ณ cessa enquanto a filial do registro for a filial corrente. Por exem ณ
//ณ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ณ
//ณ                                                                     ณ
//ณ dbSeek(xFilial())                                                   ณ
//ณ While !EOF() .And. xFilial() == A1_FILIAL                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//           1         2         3         4         5         6         7         8         9        10        11        12        13
// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
// Codigo   Convenio
// Paciente                                        Plano                             Matricula
//                                                                                   Total: 120

Cabec1:=STR0001 //"Codigo   Convenio"
Cabec2:=STR0011 //"Paciente                                        Plano                             Matricula"
DbSelectarea("QRY")
dbGoTop()
SetRegua(100)
While !EOF()
	IncRegua()
	If lAbortPrint
		@nLin,00 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	M->GD4_MATRIC:=QRY->GD4_MATRIC
	If nLin > nMaxLin // Salto de Pagina.
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	EndIf
	If Empty(QRY->GD4_MATRIC) .OR. !Empty(QRY->GA9_VLDMAT) .AND. !&(QRY->GA9_VLDMAT)[1] 
	 If Empty(cUltreg)
	 	@nLin,000 Psay QRY->GD4_CODCON
	 	@nLin,009 Psay QRY->GA9_NREDUZ
	 	nLin:=nLin+2
	 Else
	 	If cUltreg<>QRY->GD4_CODCON
  		nLin:=nLin+2
	 		@nLin,082 Psay + STR0012 + TRANSFORM(nTotal,"@E 9999")  
	 		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
  		nLin:=9
	 		@nLin,000 Psay QRY->GD4_CODCON
	 		@nLin,009 Psay QRY->GA9_NREDUZ
	 		nTotGer:=nTotGer+nTotal
	 		nTotal:=0
	 		nLin:=nLin+2
		 EndIf
	 EndIf
	 cUltreg:=QRY->GD4_CODCON
	 If Empty (QRY->GD4_MATRIC)
	 	@nLin,000 Psay QRY->GD4_REGGER +" - "+ Substr (QRY->GBH_NOME, 1, 35)
	 	@nLin,048 Psay Substr (QRY->GCM_DESPLA, 1, 30)
	 	@nLin,082 Psay "-----------------"
	 	nTotal:=nTotal+1
	 	nLin++
	 Else
	 	@nLin,000 Psay QRY->GD4_REGGER +" - "+ Substr (QRY->GBH_NOME, 1, 35)
			@nLin,048 Psay Substr (QRY->GCM_DESPLA, 1, 30)
			@nLin,082 Psay QRY->GD4_MATRIC
			nTotal:=nTotal+1
			nLin++
	 EndIf   
	Endif 
	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo  

nTotGer:=nTotGer+nTotal

If nLin > nMaxLin // Salto de Pagina.
 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin:=9
EndIf
nLin:=nLin+2
@nLin,082 Psay + STR0012 + TRANSFORM(nTotal,"@E 9999")   //"Total do Convenio:"

If nLin > nMaxLin // Salto de Pagina.
 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin:=9
EndIf
nLin:=nLin+2
@nLin,082 Psay + STR0010 + TRANSFORM(nTotGer,"@E 9999")  //"TOTAL GERAL:"

DbClosearea()

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return
