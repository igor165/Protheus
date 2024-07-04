#INCLUDE "HSPAHR20.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR20  บ Autor ณ ANTONIO CARLOS     บ Data ณ  16/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Extrato geral de Atendimentos                 บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR20()

Local oReport 


 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR20",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR20R3()  
 EndIF    
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 16/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2
 Local oCell

 oReport := TReport():New("HSPAHR20",STR0003,"HSPR20",{|oReport| R20IMP(oReport)}, STR0001 + STR0002 + STR0003) 
 //###"Extrato Geral Atendimento"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."
 
//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
 oReport:SetPortrait()          // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport,STR0019,{"GCY","GAE","GCS"})    //"Atendimento Prontuแrio"
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection1,"GCY_FILIAL","GCY",)
 oCell := TRCell():New(oSection1,"GCY_REGATE","GCY",)
 oCell := TRCell():New(oSection1,"GCY_REGGER","GCY",)
 oCell := TRCell():New(oSection1,"GCY_NOME"  ,"GCY"," ",,30)
 oCell := TRCell():New(oSection1,"GCY_DATATE","GCY",)
 oCell := TRCell():New(oSection1,"GCY_HORATE","GCY",)
 oCell := TRCell():New(oSection1,"GAE_NOME"  ,"GAE",,,30)
 oCell := TRCell():New(oSection1,"GCS_NOMLOC","GCS",STR0011) //"Setor"

 oSection2 := TRSection():New(oSection1,STR0012,{"GA7","GD7","SRA"})
 oSection2:SetHeaderPage(.T.)
 oSection2:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection2,"GA7_DESC"  ,"GA7",STR0012) //"Procedimento"
 oCell := TRCell():New(oSection2,"GD7_DATDES","GD7",STR0013) //"Dt Proced."
 oCell := TRCell():New(oSection2,"RA_NOME"   ,"SRA",STR0014) //"M้dico"
                                                                                                               
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณR20Imp    ณ Autor ณ Antonio Carlos        ณ Data ณ 08/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R20IMP(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)

Local cCond1:= "%%"

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)                      

If !EMPTY(MV_PAR03)
 cCond1:="%GCY.GCY_REGGER = '" + MV_PAR03 + "'%"
Else
 cCond1:="%GCY.GCY_REGGER <> '" + STR(Len(MV_PAR03))+ "'%"
EndIf 

oSection1:BeginQuery()

BeginSql alias "QRYR20"
 SELECT GCY_FILIAL, GCY_REGGER, GCY_REGATE, GCY_NOME, RA_NOME, GCY_DATATE, GCY_HORATE, GAE_NOME, GA7_DESC, ;
        GCS_NOMLOC, GD7_DATDES
 FROM %table:GCY% GCY
      JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GCY.GCY_LOCATE AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%
 LEFT JOIN %table:GAE% GAE ON GAE.GAE_CODEMP = GCY.GCY_CODEMP AND GAE.GAE_FILIAL = %xFilial:GAE% AND GAE.%NotDel%
      JOIN %table:GD7% GD7 ON GD7.GD7_REGATE = GCY.GCY_REGATE AND GD7.GD7_FILIAL = %xFilial:GD7% AND GD7.%NotDel%
 	    JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GD7.GD7_CODCRM AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%NotDel%
      JOIN %table:GA7% GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%NotDel%
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel% AND GCY.GCY_DATATE BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
 AND %Exp:cCond1% 
 ORDER BY GCY.GCY_NOME, GCY.GCY_REGATE, GA7.GA7_DESC
EndSql

oSection1:EndQuery()
oSection2:SetParentQuery()
oSection2:SetParentFilter( {|G| ("QRYR20")->GCY_REGATE  == G }, {|| ("QRYR20")->GCY_REGATE})

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(QRYR20->(LastRec()))
 
Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR20R3บ Autor ณ Daniel Peixoto     บ Data ณ  07/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Extrato geral de Atendimentos                 บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR20R3()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Extrato Geral Atendimento"
 Local aOrd   := {}
 
 Private Titulo      := cDesc3
 Private Cabec1      := ""
 Private Cabec2      := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR20" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}    //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132 
 Private cPerg       := "HSPR20"

 Private cRegGer   := ""
 Private cDaDtAte  := "", cAteDtAte := ""
 
 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 Private QRY       := "QRYR20"
 Private cRegAte   := ""

 If !Pergunte(cPerg,.T.)
  return
 EndIf

 cDaDtAte  := MV_PAR01
 cAteDtAte := MV_PAR02
 cRegGer   := MV_PAR03
 
 nMaxLin := HS_MaxLin(cCODIMP)

//                    1         2         3         4         5         6         7         8         9        10        11        12        13
//          0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Cabec1 := STR0006 //"Filial  Atend.  Prontuario                               Dt Atend.  Hr Atend.   Empresa                    Setor"
 Cabec2 := STR0007 //"   Procedimento                  Dt Proced.  Medico"
 
 wnrel := SetPrint("", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport("") }, Titulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  06/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSql   := "",;
        nCtaReg := 0,;
         nSql   := 0
                
 For nSql := 1 To 2 

  cSQL := "SELECT "
  If nSql == 1
   cSQL += "COUNT(*) nContasR"
  Else                
   cSQL += "GCY.GCY_FILIAL, GCY.GCY_REGGER, GCY.GCY_REGATE, GCY.GCY_NOME, SRA.RA_NOME, GCY.GCY_DATATE, GCY.GCY_HORATE, "
   cSQL += "GAE.GAE_NOME, GA7.GA7_DESC, GCS.GCS_NOMLOC, GD7.GD7_DATDES"
  EndIf
  cSQL += " FROM " + RetSQLName("GCY") + " GCY"
  cSQL += " 		   JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_LOCATE AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
  cSQL += " LEFT JOIN " + RetSQLName("GAE") + " GAE ON GAE.GAE_CODEMP = GCY.GCY_CODEMP AND GAE.GAE_FILIAL = '" + xFilial("GAE") + "' AND GAE.D_E_L_E_T_ <> '*' "
  cSQL += "      JOIN " + RetSQLName("GD7") + " GD7 ON GD7.GD7_REGATE = GCY.GCY_REGATE AND GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' "
  cSQL += " 				 JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GD7.GD7_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'  "       
  cSQL += "      JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += " GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(cDaDtAte) + "' AND '" + DTOS(cAteDtAte) + "' "
  If !EMPTY(cRegGer)
   cSQL += " AND GCY.GCY_REGGER = '"+ cRegGer +"' "
  EndIf 
  
  If nSql == 2
   cSQL += " ORDER BY GCY.GCY_NOME, GCY.GCY_REGATE, GA7.GA7_DESC"
  EndIf
  cSQL := ChangeQuery(cSQL) 
 
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),QRY,.T.,.T.)

  If nSql == 1
   nCtaReg := (QRY)->nContasR
   DbCloseArea()
  EndIf
  
 Next

 DbSelectArea(QRY) 
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0008,STR0009,STR0010) //"Nenhum dado foi encontrado para a selecao efetuada." //"Aten็ใo"###"Execucao do relatorio"
  DbCloseArea()
  Return()
 Endif 

 Processa({||FS_ImpRel(nCtaReg)})
 
 Return(Nil)
 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpRel บ Autor ณ Marcelo Jose       บ Data ณ  06/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ impressao do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpRel(nCtaReg) 
 Local nQtosFoi := 0, nQtdTot := 0
 Private nLin    := nMaxLin * 2
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 ProcRegua(nCtaReg)
 While !EOF()                                                                                
                      
  nQtosFoi++
  IncProc(STR0011+Alltrim(str(nQtosFoi,6,0))+ STR0012 +Alltrim(str(nCtaReg,6,0))+STR0013+Alltrim(str(m_pag,6,0))+STR0014) //"Aguarde: "###" de "###" Regs. em: "###" Paginas."

  If nLin+2 > nMaxLin
   FS_Cabec()
   nLin ++ 
  Endif

  If cRegAte <> (QRY)->GCY_REGATE
   nLin ++ 
   @nLin, 000 PSAY (QRY)->GCY_FILIAL
   @nLin, 008 PSAY (QRY)->GCY_REGATE
   @nLin, 016 PSAY (QRY)->GCY_REGGER + " - " + SUBSTR((QRY)->GCY_NOME,1,30)
   @nLin, 057 PSAY HS_DTOC(STOD((QRY)->GCY_DATATE),1) 
   @nLin, 068 PSAY (QRY)->GCY_HORATE
   @nLin, 080 PSAY SUBSTR((QRY)->GAE_NOME, 1, 24)
   @nLin, 107 PSAY SUBSTR((QRY)->GCS_NOMLOC, 1, 24)
   cRegAte := (QRY)->GCY_REGATE
   nLin++  
   nQtdTot++
  EndIf

  @nLin, 003 PSAY SUBSTR((QRY)->GA7_DESC, 1, 28)
  @nLin, 033 PSAY HS_DTOC(STOD((QRY)->GD7_DATDES),1)
  @nLin, 045 PSAY SUBSTR((QRY)->RA_NOME, 1, 30)
  nLin += 1
  
  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif

  DbSkip()
 End    
 If EOF()
  If nLin > nMaxLin
   FS_Cabec()
  Endif
  nLin++
  @nLin,000 PSAY STR0015 + TRANSFORM(nQtdTot,"@E 9,999")   //"Total de Pacientes Emitidos.: "
 Endif 
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
 DBCloseArea()

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 nLin := 8
Return()
