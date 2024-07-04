#INCLUDE "HSPAHRD1.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRD1 บ     ณAntonio Carlos/Marceloบ Data ณ 01/12/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXTRATO DE PAGAMENTO SINTETICO NO PERIODO                  บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRD1()

Local oReport                    

If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPRD1",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
ELSE
	HSPAHRD1R3()
EndIF

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos/Marceloณ Data ณ 10/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport
 Local oSection0, oSection1, oSection2, oSection3, oSection4, oSection5, oSection6, oSection7, oSection8
 Local oCell    

 oReport := TReport():New("HSPAHRD1",STR0003,"HSPRD1",{|oReport| RD1IMP(oReport)},STR0001 + " " + STR0002)  
 //"EXTRATO DE PAGAMENTO SINTETICO" ###"Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

 oReport:SetPortrait()            // Imprimir relatorio em formato retrato

 oSection0 := TRSection():New(oReport,"Profissional/Prestador",{"QRY"})
 oSection0:SetHeaderPage(.T.)
 oSection0:SetPageBreak(.T.)
 oSection0:SetNoFilter({"QRY"})

 oCell := TRCell():New(oSection0,"RA_NOME"   ,"QRY",STR0008,,35)//"Prof.: " 
 oCell := TRCell():New(oSection0,"GAZ_FANPRE","QRY",STR0014,,35)//"Prest.: " 

 oSection1 := TRSection():New(oSection0,"",{"QRY"})
 oSection1:SetNoFilter({"QRY"})
 oSection1:SetReadOnly(.T.)         
 oCell := TRCell():New(oSection1,"cDesHono" ,""     ,"",             ,60                     ,,{|| STR0009 })//"Honorarios"
 oCell := TRCell():New(oSection1,"HONORARIO","QRY"  ,"","9999,999.99",TamSx3("GDX_VALLAN")[1])  

 oSection2 := TRSection():New(oSection1,"",{"QRY"})
 oSection2:SetNoFilter({"QRY"})
 oSection2:SetReadOnly(.T.)
 oCell := TRCell():New(oSection2,"cGLOSA",""   ,""     ,             ,60                     ,,{|| STR0010 })//"Glosas"
 oCell := TRCell():New(oSection2,"GLOSA" ,"QRY","","9999,999.99",TamSx3("GDX_VALLAN")[1])  

 oSection7 := TRSection():New(oSection2,"",{"QRY"})
 oSection7:SetNoFilter({"QRY"})
 oSection7:SetReadOnly(.T.)
 oCell := TRCell():New(oSection7,"cPLANTAO",""   ,""     ,             ,60                     ,,{|| STR0015 })//"Plantใo"
 oCell := TRCell():New(oSection7,"PLANTAO" ,"QRY","","9999,999.99",TamSx3("GDX_VALLAN")[1])  
 
 oSection3 := TRSection():New(oSection7,"",{"QRY"})
 oSection3:SetNoFilter({"QRY"})
 oSection3:SetReadOnly(.T.) 
 oCell := TRCell():New(oSection3,"cSUBTOTAL",""   ,""         ,             ,60,,{|| "                    Sub-total =>"})  
 oCell := TRCell():New(oSection3,"SUBTOTAL" ,"QRY","","9999,999.99",TamSx3("GDX_VALLAN")[1])  
 
 oSection4 := TRSection():New(oSection3,"",{"QRY"})
 oSection4:SetNoFilter({"QRY"})
 oSection4:SetReadOnly(.T.) 
 oCell := TRCell():New(oSection4,"cCRED","","",,60,,{|| STR0012} )//"Credito avulso" 
 oCell := TRCell():New(oSection4,"CRED_DGT","QRY","","9999,999.99",TamSx3("GDX_VALLAN")[1]) 

 oSection5 := TRSection():New(oSection4,"",{"QRY"})
 oSection5:SetNoFilter({"QRY"})
 oSection5:SetReadOnly(.T.)
 oCell := TRCell():New(oSection5,"cDEB_DGT","","",,60,,{|| STR0011})//"Debito avulso" 
 oCell := TRCell():New(oSection5,"DEB_DGT"  ,"QRY"  ,"","9999,999.99",TamSx3("GDX_VALLAN")[1]) 
 
 oSection6 := TRSection():New(oSection5,"",{"QRY"})
 oSection6:SetNoFilter({"QRY"})
 oSection6:SetReadOnly(.T.)                           
 oCell := TRCell():New(oSection6,"cTOTAL","","",,60,,{|| "                    "+STR0013})//"Total do Profissional ===> "  
 oCell := TRCell():New(oSection6,"TOTAL"    ,"QRY"  ,"","9999,999.99",TamSx3("GDX_VALLAN")[1])  

 oSection7 := TRSection():New(oSection6,"",{"QRY"})
 oSection7:SetNoFilter({"QRY"})
 oSection7:SetReadOnly(.T.)
 oCell := TRCell():New(oSection7,"cDesTot",""  ,"",,120,,{|| "(" +Extenso(("QRY")->TOTAL, .F., 1 ) + " )" })  
Return( oReport )




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RDKImp   ณ Autor ณ Antonio Carlos/Marceloณ Data ณ 10/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RD1IMP(oReport)

 Local oSection0 := oReport:Section(1)
 Local oSection1 := oReport:Section(1):Section(1)
 Local oSection2 := oReport:Section(1):Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1):Section(1)
 Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)
 Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1):Section(1)
 Local oSection6 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1):Section(1):Section(1)
 Local oSection7 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1):Section(1):Section(1):Section(1)
 Local oSection8 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1):Section(1):Section(1):Section(1):Section(1)
 Local cCond1 := "", cCond2 := "", cCond3 := ""

 MakeSqlExpr(oReport:uParam)

 cCond1 := "% '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' %"
 cCond2 := "% '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' %"
 cCond3 := "% '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' %"

 BeginSql alias "QRY"

  SELECT GAZ_FANPRE, RA_NOME, SUM(HONORARIO) HONORARIO,SUM(GLOSA) GLOSA, SUM(CRED_DGT) CRED_DGT,SUM(DEB_DGT) DEB_DGT, SUM(PLANTAO) PLANTAO,
        SUM(HONORARIO) + SUM(PLANTAO) - SUM(GLOSA) SUBTOTAL, (SUM(HONORARIO) + SUM(PLANTAO) - SUM(GLOSA)) + (SUM(CRED_DGT) - SUM(DEB_DGT)) TOTAL   
   FROM (
       SELECT GAZ.GAZ_FANPRE GAZ_FANPRE, SRA.RA_NOME RA_NOME, GDX.GDX_TIPMOV GDX_TIPMOV, GDX.GDX_TIPLAN GDX_TIPLAN, 
              CASE 
               WHEN GDX_TIPMOV IN ('0', '2') THEN  
                 CASE GDX_TIPLAN
                  WHEN '1' THEN 
                   SUM(GDX.GDX_VALLAN) 
                  ELSE
                   0
                  END 
                ELSE 0
              END  HONORARIO,
              CASE 
               WHEN GDX_TIPMOV IN ('0', '2') THEN  
                 CASE GDX_TIPLAN
                  WHEN '0' THEN 
                   SUM(GDX.GDX_VALLAN) 
                  ELSE
                   0
                  END 
                ELSE 0
              END GLOSA,
              CASE GDX_TIPMOV
               WHEN '1' THEN 
                 CASE GDX_TIPLAN
                  WHEN '1' THEN 
                   SUM(GDX.GDX_VALLAN) 
                  ELSE
                   0
                  END 
                ELSE 0
              END CRED_DGT,          
              CASE GDX_TIPMOV
               WHEN '1' THEN 
                 CASE GDX_TIPLAN
                  WHEN '0' THEN 
                   SUM(GDX.GDX_VALLAN) 
                  ELSE
                   0
                  END 
                ELSE 0
              END DEB_DGT,          
              CASE GDX_TIPMOV
               WHEN '3' THEN 
                 CASE GDX_TIPLAN
                  WHEN '1' THEN 
                   SUM(GDX.GDX_VALLAN) 
                  ELSE
                   0
                  END 
                ELSE 0
              END PLANTAO
         FROM %table:GDX% GDX 
         JOIN %table:GAZ% GAZ ON GAZ.GAZ_CODPRE = GDX.GDX_CODPRE AND GAZ.GAZ_FILIAL = %xFilial:GAZ% AND GAZ.%NotDel%
         JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GDX.GDX_CODCRM AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%NotDel%
         WHERE GDX.GDX_FILIAL = %xFilial:GDX% AND GDX.%NotDel% 
           AND GDX.GDX_CODPRE BETWEEN %exp:cCond1% 
           AND GDX.GDX_CODCRM BETWEEN %exp:cCond2% 
           AND GDX.GDX_DATLAN BETWEEN %exp:cCond3% 
      GROUP BY GAZ.GAZ_FANPRE, SRA.RA_NOME, GDX.GDX_TIPMOV, GDX.GDX_TIPLAN
      ) TABELA
      GROUP BY GAZ_FANPRE, RA_NOME
 EndSql

 oSection0:EndQuery()
 oSection1:SetParentQuery()   
 oSection1:SetParentFilter(  {|H| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME == H }, {|| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME})
 
 oSection2:SetParentQuery()   
 oSection2:SetParentFilter(  {|H| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME == H }, {|| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME})
 
 oSection3:SetParentQuery()   
 oSection3:SetParentFilter(  {|H| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME == H }, {|| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME})
 
 oSection4:SetParentQuery()   
 oSection4:SetParentFilter(  {|H| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME == H }, {|| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME}) 
 
 oSection5:SetParentQuery()   
 oSection5:SetParentFilter(  {|H| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME == H }, {|| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME})
 
 oSection6:SetParentQuery()   
 oSection6:SetParentFilter(  {|H| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME == H }, {|| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME})

 oSection7:SetParentQuery()   
 oSection7:SetParentFilter(  {|H| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME == H }, {|| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME})

 oSection8:SetParentQuery()   
 oSection8:SetParentFilter(  {|H| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME == H }, {|| ("QRY")->GAZ_FANPRE + ("QRY")->RA_NOME})

 oSection0:Print() // processa as informacoes da tabela principal

 oReport:SetMeter(GCY->(LastRec()))

Return( NIL ) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRD1 บ       ณ MARCELO JOSE       บ Data ณ 01/04/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXTRATO DE PAGAMENTO SINTETICO NO PERIODO                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRD1R3()
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local cPict          := ""
 Local cTitulo        := STR0003 //"EXTRATO DE PAGAMENTO SINTETICO"
 Local nLin           := 80 
 Local cCabec1        := ""
 Local cCabec2        := STR0004 //"Movimentacao--------------------------             Valor-----"
 Local imprime        := .T.
 Local aOrd           := {}
 Local nLinTotal      := 60

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private Tamanho      := "P"
 Private limite       := 80
 Private m_pag        := 01
 Private nomeprog     := "HSPAHRD1"
 Private nTipo        := 18
 Private aReturn      := {STR0005, 1, STR0006, 2, 2, 1, "", 1}   //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private wnrel        := "HSPAHRD1"
 Private cString      := "GDX"
 Private aVetor      := {}

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 If !Pergunte("HSPRD1" ,.T.)
  return
 EndIf          

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
 
 wnrel := SetPrint(cString,NomeProg,"",@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 
 If nLastKey == 27
  Return
 Endif
 
 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return
 Endif
 
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRD1  บAutor  ณMicrosiga           บ Data ณ  10/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบ26/10/2007ณ134974ณ Inclusใo da linha para diferencia็ใo dos pagamentos บฑฑ
ฑฑบ          ณ      ณ feitos para Plantใo                                 บฑฑ
ฑฑบ          ณ      ณ                                                     บฑฑ
ฑฑบ          ณ      ณ                                                     บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 Local cNome   := ""
 Local cFanPre := ""
 Local nCreGer := 0
 Local nDebGer := 0
 Local nCreDig := 0
 Local nDebDig := 0 
 Local nPlantao:= 0
  
 cQuery := "SELECT GAZ.GAZ_FANPRE FANPRE, SRA.RA_NOME NOME,"
 cQuery += "       GDX.GDX_TIPLAN TIPLAN, GDX.GDX_TIPMOV TIPMOV, SUM(GDX.GDX_VALLAN) VALLAN "
 cQuery += " FROM " + RetSqlName("GDX") + " GDX "
 cQuery += " JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GDX.GDX_CODPRE AND GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' "
 cQuery += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GDX.GDX_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cQuery += " WHERE GDX.GDX_FILIAL = '" + xFilial( "GDX" ) + "' AND GDX.D_E_L_E_T_ <> '*' AND "
 cQuery += "       GDX.GDX_CODPRE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
 cQuery += "       GDX.GDX_CODCRM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "   
 cQuery += "       GDX.GDX_DATLAN BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
 cQuery += " GROUP BY GAZ.GAZ_FANPRE, SRA.RA_NOME, GDX.GDX_TIPLAN, GDX.GDX_TIPMOV"
 cQuery += " ORDER BY GAZ.GAZ_FANPRE, SRA.RA_NOME, GDX.GDX_TIPLAN, GDX.GDX_TIPMOV"
 
	cQuery := ChangeQuery(cQuery)
 TCQUERY cQuery NEW ALIAS "QRY"

 DbSelectArea("QRY")
 DbGoTop()
 
 While !Eof()

  cNome   := QRY->NOME
  cFanPre := QRY->FANPRE 
  nCreGer := 0
  nDebGer := 0
  nCreDig := 0
  nDebDig := 0     
  nPlantao:= 0
  
  While !Eof() .And. QRY->NOME == cNome .And. QRY->FANPRE == cFanPre
   
   If     (QRY->TIPMOV == "0" .or. QRY->TIPMOV == "2") .And. QRY->TIPLAN == "1" //Credito gerado
    nCreGer := QRY->VALLAN  
   ElseIf (QRY->TIPMOV == "0" .or. QRY->TIPMOV == "2") .And. QRY->TIPLAN == "0" //Debito gerado
    nDebGer := QRY->VALLAN
   ElseIf QRY->TIPMOV == "1"  .And. QRY->TIPLAN == "0" //Debito Digitado
    nDebDig := QRY->VALLAN
   ElseIf QRY->TIPMOV == "1"  .And. QRY->TIPLAN == "1" //Credito Digitado
    nCreDig := QRY->VALLAN
   ElseIf QRY->TIPMOV == "3"  .And. QRY->TIPLAN == "1" //Plantao
     nPlantao:= QRY->VALLAN 
  EndIf
        
   DbSelectArea("QRY")
  DbSkip()

 EndDo

  FS_ImpRD1(cTitulo, cCabec1, cCabec2, cNome, cFanPre, nCreGer, nDebGer, nDebDig, nCreDig, nPlantao)
  
 EndDo

 DbSelectArea("QRY")
 DbCloseArea()

 Set Printer to
 Set Device  to Screen
 If aReturn[5]==1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)

Static Function FS_ImpRD1(cTitulo, cCabec1, cCabec2, cNome, cFanPre, nCreGer, nDebGer, nDebDig, nCreDig, nPlantao)
 Local nTotGer  := 0                                             
 Local nTotal   := 0
 Local sExtenso := ""
 Local iConta   := 0
 	
 cCabec1 := SUBSTR(STR0008 + cNome, 1, 39) + " "  //"Profissional:  "
 cCabec1 += STR0014 + cFanPre
   Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
  
 @ 10,05 PSAY STR0009 //"Honorarios"
 @ 10,49 PSAY IIf(nCreGer > 0, Transform(nCreGer, "9999,999.99"), "")

 @ 12,05 PSAY STR0010  //"Glosas"
 @ 12,49 PSAY IIf(nDebGer > 0, Transform(nDebGer, "9999,999.99"), "")

 @ 14,05 PSAY STR0015  //"Plantao"
 @ 14,49 PSAY IIf(nPlantao > 0, Transform(nPlantao, "9999,999.99"), "") 
  
 If (nTotGer := (nCreGer+nPlantao) - nDebGer) > 0
  @ 16,30 PSAY "Sub-total =>"
  @ 16,49 PSAY Transform ( nTotGer ,"9999,999.99" )
  EndIf
  
 @ 18,05 PSAY STR0011 //"Debito avulso"
 @ 18,49 PSAY IIf(nDebDig > 0, Transform(nDebDig, "9999,999.99"), "")
  
 @ 20,05 PSAY STR0012 //"Credito avulso"
 @ 20,49 PSAY IIf(nCreDig > 0, Transform(nCreDig, "9999,999.99"), "")

 nTotal := nTotGer + nCreDig - nDebDig
 @ 22,16 PSAY STR0013 //"Total do Profissional ===>"
 @ 22,49 PSAY Transform( nTotal ,"9999,999.99")
 sExtenso:="(" + Extenso(nTotal, .F., 1 ) + ")"
 If Len(sExtenso) >= limite - 5
  iConta:=Len(sExtenso)
  Do While .T.
   If (Substr(sExtenso,iConta,1) = " ") .and. (iConta <= limite)
    @ 24,05 PSAY Substr(sExtenso,1,iConta)
    @ 25,05 PSAY Substr(sExtenso,iConta+1,Len(sExtenso))
    @ 26,00 PSAY REPLI("_", 82)  
    Exit  
   Endif     
   --iConta
  Enddo
 Else 
  @ 24,05 PSAY sExtenso
  @ 25,00 PSAY REPLI("_", 82)
 Endif 
 
Return()