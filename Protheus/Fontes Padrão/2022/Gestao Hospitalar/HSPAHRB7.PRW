#include "TopConn.ch"
#include "protheus.ch"
#INCLUDE "HSPAHRB7.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRB7 บCoAutorณ ANTONIO CARLOS     บ Data ณ  03/07/2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio do Cadastro de Prontuarios X Endereco            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑณObs:      ณ Convertido para relatorios personalizaveis                 ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRB7()   

Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPRB7",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHRB7R3()  
 EndIF    
 
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ ANTONIO CARLOS        ณ Data ณ 03/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1
 Local oCell

 oReport := TReport():New("HSPAHRB7",STR0001,"HSPRB7",{|oReport| RB7IMP(oReport)}, STR0003+STR0004+" "+STR0001)
 oSection1 := TRSection():New(oReport,STR0029,{"GSB","GBH"})   //"Prontuแrio"
 oCell := TRCell():New(oSection1,"GSB_REGGER","GSB")                                   // Registro Geral do Paciente
 oCell := TRCell():New(oSection1,"cPACIENTE"   ,"GBH",STR0007,,TamSX3("GBH_NOME")[1],,{||HS_INIPADR("GBH",1, ("GSB")->GSB_REGGER, "GBH_NOME",,.F.)})  //"Nome"
 oCell := TRCell():New(oSection1,"GSB_CODEND","GSB")                                   // Tipo de Endereco
 oCell := TRCell():New(oSection1,"GSB_DESEND","GSB")                                   // Descricao do Tipo de Endereco

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RB7Imp   ณ Autor ณ ANTONIO CARLOS        ณ Data ณ 03/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RB7IMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local cFiltro   := "" 

 cFiltro := "@GSB_FILIAL = '"+xFilial("GSB")+"' AND D_E_L_E_T_ <> '*' "   
 cFiltro += " AND GSB_REGGER BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
 cFiltro += " AND GSB_CODEND BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
 
 If MV_PAR05 == 1
  oSection1:SetIdxOrder(1) 
 Else
  oSection1:SetIdxOrder(2) 
 Endif
 
 oSection1:SetFilter(cFiltro) 
 oSection1:Print() 

Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRB7R3บ Autor ณ Cibele L. Peria    บ Data ณ  22/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio do Cadastro de Prountuarios X Endereco           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRB7R3()

 Local Titulo        := STR0001 //"Relat๓rio de Prontuแrios & Endere็o"

 Local Cabec1        := STR0026 //"Pront.  Nome----------------------------------------- Endereco----   --DESCRICAO------------------------------------"
 Local Cabec2        := ""
 Local cDesc1        := STR0003 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2        := STR0004 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3        := STR0001 //"Relat๓rio de Prontuแrios & Endere็o"

 Local nLin          := 80
 Local aOrd          := {}

 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private tamanho     := "M"
 Private NomeProg    := "HSPAHRB7" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0024, 1, STR0025, 2, 2, 1, "", 1}
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := "HSPAHRB7" // Coloque aqui o nome do arquivo usado para impressao em disco

 Private cRegGerDe   := "" 
 Private cRegGerAte  := ""
 Private cCodEndDe   := ""
 Private cCodEndAte	 := ""
 Private nClassific	 := ""

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 cPerg := "HSPRB7"
  
 If !Pergunte(cPerg,.T.)
  return
 EndIf                    

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 cRegGerDe  := mv_par01 
 cRegGerAte := mv_par02
 cCodEndDe  := mv_par03
 cCodEndAte := mv_par04
 nClassific := mv_par05

 wnrel := SetPrint("GSB",NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

 If nLastKey == 27
  Return
 Endif

 SetDefault(aReturn,"GSB")

 If nLastKey == 27
  Return
 Endif

 nTipo := If(aReturn[4]==1,15,18)

 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
 Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  21/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Execucao do relatorio.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar - Rotina Principal                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

 Local cSQL := ""
  
 cSQL := "SELECT GSB.GSB_REGGER, GSB.GSB_CODEND, GSB.GSB_DESEND, GBH.GBH_NOME"
 cSQL += " FROM " + RetSQLName("GSB") + " GSB"                                   
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GSB.GSB_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' " 
 cSQL += " WHERE"
 cSQL += "     GSB.GSB_FILIAL = '" + xFilial("GSB") + "' AND GSB.D_E_L_E_T_ <> '*' "   
 cSQL += " AND GSB.GSB_REGGER BETWEEN '" + cRegGerDe + "' AND '" + cRegGerAte + "' "
 cSQL += " AND GSB.GSB_CODEND BETWEEN '" + cCodEndDe + "' AND '" + cCodEndAte + "' "
 If nClassific == 1
  cSQL += " ORDER BY GSB_FILIAL, GSB_REGGER, GSB_CODEND"
 Else
  cSQL += " ORDER BY GSB_FILIAL, GSB_CODEND, GSB_REGGER"
 Endif
  
 cSQL :=  ChangeQuery(cSQL) 

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop() 
 
 If EOF()
  HS_MsgInf(STR0005, STR0027, STR0028) //""Nใo hแ dados a serem impressos para a sele็ใo efetuada!""###"Aten็ใo"###"Verifique a sele็ใo"
  Return()
 Endif
   
 SetRegua(100)
 
 While !Eof() 
  IncRegua()  
  
  If lAbortPrint
   @nLin,00 PSAY STR0006  //"*** CANCELADO PELO OPERADOR ***"
   Exit
  Endif
  
  If nLin > nMaxLin       // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,.T.)
   nLin := 8
  Endif
  
  @nLin,00 PSAY QRY->GSB_REGGER					       // Registro Geral do Paciente
  @nLin,08 PSAY QRY->GBH_NOME             // Nome do Paciente
  @nLin,54 PSAY QRY->GSB_CODEND								   // Tipo de Endereco    
  @nLin,69 PSAY QRY->GSB_DESEND          // Descricao do Tipo de Endereco
  
  nLin++
  dbSkip() // Avanca o ponteiro do registro no arquivo
 EndDo

 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Finaliza a execucao do relatorio...                                 ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SET DEVICE TO SCREEN

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)                                                  	
 Endif

 MS_FLUSH()
 DbCloseArea()
Return(Nil)    
