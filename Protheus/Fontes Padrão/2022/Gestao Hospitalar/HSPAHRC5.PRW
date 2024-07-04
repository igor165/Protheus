#INCLUDE "HSPAHRC5.ch"
#INCLUDE "PROTHEUS.CH"   
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRC5  บ Autor ณ ANTONIO CARLOS     บ Data ณ  21/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Livro de Entorpecentes                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRC5()

 Local oReport
 Private cConfR4
 Private limite	:= 132
 If FindFunction("TRepInUse") .And. TRepInUse() 
  cConfR4:='S'
	 pergunte("HSPRC5",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE   
  cConfR4:='N'
  HSPAHRC5R3()  
 EndIF    
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 13/09/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3
 Local oCell
 Local nSaldo:=0
 Local	nSaldoEst :=0 
 Local oTotaliz
 Local cPerda	 := GETMV("MV_HSPTMPD")

 oReport := TReport():New("HSPAHRC5",STR0004,"HSPRC5",{|oReport| RC5IMP(oReport)}, STR0001 + STR0002 + STR0003) //""Livro de Entorpecentes"
// "Este programa tem como objetivo imprimir relat๓rio "###"de livros para a receita federal de acordo com os "###"parโmetros informados pelo usuแrio."

 oSection1 := TRSection():New(oReport,"Descri็ใo",{"QRYRC5","GED"})
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.F.)
 oSection1:SetNoFilter({"QRYRC5"})
 oCell := TRCell():New(oSection1,"TRB_DESC","QRYRC5",,,20)
 oCell := TRCell():New(oSection1,"TRB_DESDES","QRYRC5",,,20)
 oCell := TRCell():New(oSection1,"TRB_LISTA","QRYRC5",STR0011)  //"LISTA:"
 oCell := TRCell():New(oSection1,"GED_CODIGO","GED",STR0012,,41)  //"LIVRO:"
 oCell := TRCell():New(oSection1,"nSaldo","QRYRC5",STR0014,"@E 999,999.99",40,,{||nSaldo:=FS_SaldoB9( QRYRC5->TRB_CODPRO )})   //"Saldo Anterior.......:"

 oSection2 := TRSection():New(oSection1,STR0052,{"QRYRC5"})
 oSection2:SetHeaderPage(.T.)
 oSection2:SetHeaderBreak(.F.)
 oSection2:SetNoFilter({"QRYRC5"})
 oCell := TRCell():New(oSection2,"dEMISSA"   ,"QRYRC5",STR0045     ,,10,,{||dEMISSA:=IIF(Empty(QRYRC5->TRB_EMISSA)," ", HS_DTOC(STOD(QRYRC5->TRB_EMISSA),1) )}) //"Data"
 oCell := TRCell():New(oSection2,"TRB_NUMSEQ","QRYRC5",STR0046,,10) //"Documento"
 oCell := TRCell():New(oSection2,"cRegAte"   ,"QRYRC5",STR0047,,50,,{||cREGATE:=IIf(ALLTRIM(QRYRC5->TRB_REGATE) <> 'NF',QRYRC5->TRB_REGATE + "-" + QRYRC5->TRB_NOME /*historico*/,QRYRC5->TRB_NOME /*tipo de movimenta็ใo ou fornecedor*/)}) //"Hist๓rico"
 oCell := TRCell():New(oSection2,"TRB_CODCRM","QRYRC5",STR0048      ,,10) //"CRM"
 oCell := TRCell():New(oSection2,"nEntrada"  ,"QRYRC5",STR0049  ,"@E@Z 999,999.99",10,,{||nEntrada:=IIF(!(QRYRC5->TRB_TIPMOV $ cPerda),IIF(QRYRC5->TRB_TIPMOV <= "500",QRYRC5->TRB_QTD,0),0)}) //"Entrada"
 oCell := TRCell():New(oSection2,"nSaida_"   ,"QRYRC5",STR0050  ,"@E@Z 999,999.99",10,,{||nSaida:=IIF(!(QRYRC5->TRB_TIPMOV $ cPerda),IIF(QRYRC5->TRB_TIPMOV > "500",QRYRC5->TRB_QTD,0),0)})  //"Saida"
 oCell := TRCell():New(oSection2,"nPerda"    ,"QRYRC5",STR0051  ,"@E@Z 999,999.99",10,,{||nPerda:=IIF((QRYRC5->TRB_TIPMOV $ cPerda),QRYRC5->TRB_QTD,0)}) //"Perda"
 oCell := TRCell():New(oSection2,"nSaldo"    ,"QRYRC5",STR0052  ,"@E@Z 999,999.99",10,,{||nSaldo:=IIF(!(QRYRC5->TRB_TIPMOV $ cPerda), IIF(QRYRC5->TRB_TIPMOV <= "500", nSaldo + QRYRC5->TRB_QTD, nSaldo - QRYRC5->TRB_QTD),nSaldo -= QRYRC5->TRB_QTD)}) //"Estoque"

 oSection3 := TRSection():New(oReport,STR0028+"/"+STR0029,{"GED"})
 oSection3:SetPageBreak(.T.)                                                                                

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return( oReport )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RC5Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 21/07/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RC5IMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(2)

 Local cCond := "" 
 Local lImpTer		 := .T.
 Local lImprimiu := .F.
 Local nPagIni		 := 0
 Local nPagFim		 := 0
 Local nPags				 := 1
 Local nI   := 1
 Local cTit := ""                                                            
 Local cMVHspFarm := AllTrim(GetMv("MV_HSPFARM"))
 Local cCrfFar    := SubStr(cMVHspFarm, At("/", cMVHspFarm) + 1)
 Private nMaxLin := 0

 DbSelectArea("GED")
 DbSetOrder(1) // GED_FILIAL + GED_CODIGO + GED_TIPO
 If ! DbSeek(xFilial("GED") + MV_PAR01)
 	HS_MsgInf(STR0007, STR0044, STR0004) //"O livro informado nใo existe"###"Aten็ใo"###"Livro de entorpecentes"
 	Return(Nil)
 EndIf

 If MV_PAR02 < GED->GED_PERFIM
 	HS_MsgInf(STR0008 + DTOC(GED->GED_PERFIM), STR0044, STR0004) //"O pr๓ximo perํodo deve ser superior a "###"Aten็ใo"###"Livro de entorpecentes"
 	Return(.F.)
 EndIf

 If GED->GED_PAGFIM == GED->GED_TOTPAG
 	HS_MsgInf(STR0009, STR0044, STR0004) //"Este livro jแ estแ completo. Selecione outro."###"Aten็ใo"###"Livro de entorpecentes"
 EndIf

 m_pag 		:= GED->GED_PAGFIM + 1
 nPagIni := m_pag
 nPagFim	:= nPagIni - 1

 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                      

 cCond := "% (" + FS_GETLIST() + ") %"
 
 oSection1:BeginQuery()

 BeginSql alias "QRYRC5"
 SELECT %Exp:'04'% AS TRB_ORDEM, SD3.D3_NUMSEQ TRB_NUMSEQ, SB1.B1_DESC TRB_DESC, GA0.GA0_CODFAR TRB_CODFAR, GA0.GA0_DESC TRB_DESDES, 
        GA0.GA0_LISTA TRB_LISTA,  SD3.D3_EMISSAO TRB_EMISSA, SD3.D3_REGATEN TRB_REGATE, 
        GCY.GCY_NOME TRB_NOME, SD3.D3_TM TRB_TIPMOV, SD3.D3_QUANT TRB_QTD, GCY.GCY_CODCRM TRB_CODCRM, 
        SB1.B1_COD TRB_CODPRO
 FROM %table:SD3% SD3
 JOIN %table:SB1% SB1 ON SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.%NotDel% AND SB1.B1_COD = SD3.D3_COD
 JOIN %table:GCY% GCY ON GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel% AND GCY.GCY_REGATE = SD3.D3_REGATEN
 JOIN %table:GBI% GBI ON GBI.GBI_FILIAL = %xFilial:GBI% AND GBI.%NotDel% AND GBI.GBI_FARMAC <> %Exp:' '% 
                     AND GBI.GBI_PRODUT = SD3.D3_COD
 JOIN %table:GA0% GA0 ON GA0.GA0_FILIAL = %xFilial:GA0% AND GA0.%NotDel% AND GBI.GBI_FARMAC = GA0.GA0_CODFAR 
                     AND GA0.GA0_LISTA IN %Exp:cCond%
 WHERE SD3.D3_FILIAL = %xFilial:SD3% AND SD3.%NotDel% 
   AND SD3.D3_EMISSAO BETWEEN %Exp:DTOS(MV_PAR02)% AND %Exp:DTOS(MV_PAR03)%
 UNION 

 SELECT %Exp:'01'% AS TRB_ORDEM, SD1.D1_DOC TRB_NUMSEQ, SB1.B1_DESC TRB_DESC, GA0.GA0_CODFAR TRB_CODFAR, GA0.GA0_DESC TRB_DESDES, 
        GA0.GA0_LISTA TRB_LISTA, SD1.D1_DTDIGIT TRB_EMISSA, %Exp:'NF'% TRB_REGATE,  
        SA2.A2_NOME TRB_NOME, SD1.D1_TES TRB_TIPMOV, SD1.D1_QUANT TRB_QTD , %Exp:' '% TRB_CODCRM,
        SB1.B1_COD TRB_CODPRO 
 FROM %table:SD1% SD1 
 JOIN %table:SA2% SA2 ON SA2.A2_FILIAL  = %xFilial:SA2% AND SA2.%NotDel% AND SA2.A2_COD = SD1.D1_FORNECE 
                     AND SA2.A2_LOJA = SD1.D1_LOJA
 JOIN %table:SF4% SF4 ON SF4.F4_FILIAL  = %xFilial:SF4% AND SF4.%NotDel% AND SF4.F4_CODIGO = SD1.D1_TES
 JOIN %table:GBI% GBI ON GBI.GBI_FILIAL = %xFilial:GBI% AND GBI.%NotDel% AND GBI.GBI_FARMAC <> %Exp:' '% 
                     AND GBI.GBI_PRODUT = SD1.D1_COD
 JOIN %table:GA0% GA0 ON GA0.GA0_FILIAL = %xFilial:GA0% AND GA0.%NotDel% AND GBI.GBI_FARMAC = GA0.GA0_CODFAR 
                     AND GA0.GA0_LISTA IN %Exp:cCond%
 JOIN %table:SB1% SB1 ON SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.%NotDel% AND SB1.B1_COD = SD1.D1_COD
 WHERE SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.%NotDel% 
   AND SD1.D1_DTDIGIT BETWEEN %Exp:DTOS(MV_PAR02)% AND %Exp:DTOS(MV_PAR03)% AND SF4.F4_ESTOQUE = %Exp:'S'%
 UNION 

 SELECT %Exp:'02'% AS TRB_ORDEM, SD2.D2_DOC TRB_NUMSEQ, SB1.B1_DESC TRB_DESC, GA0.GA0_CODFAR TRB_CODFAR, GA0.GA0_DESC TRB_DESDES, 
        GA0.GA0_LISTA TRB_LISTA, SD2.D2_EMISSAO TRB_EMISSA, %Exp:'NF'% TRB_REGATE, 
        SA2.A2_NOME TRB_NOME, SD2.D2_TES TRB_TIPMOV, SD2.D2_QUANT TRB_QTD, %Exp:' '% TRB_CODCRM, 
        SB1.B1_COD TRB_CODPRO
 FROM %table:SD2% SD2
 JOIN %table:SA2% SA2 ON SA2.A2_FILIAL  = %xFilial:SA2% AND SA2.%NotDel% AND SA2.A2_COD = SD2.D2_CLIENTE 
                     AND SA2.A2_LOJA = SD2.D2_LOJA 
 JOIN %table:SF4% SF4 ON SF4.F4_FILIAL  = %xFilial:SF4% AND SF4.%NotDel% AND SF4.F4_CODIGO = SD2.D2_TES
 JOIN %table:GBI% GBI ON GBI.GBI_FILIAL = %xFilial:GBI% AND GBI.%NotDel% AND GBI.GBI_FARMAC <> %Exp:' '% 
                     AND GBI.GBI_PRODUT = SD2.D2_COD
 JOIN %table:GA0% GA0 ON GA0.GA0_FILIAL = %xFilial:GA0% AND GA0.%NotDel% AND GBI.GBI_FARMAC = GA0.GA0_CODFAR 
                     AND GA0.GA0_LISTA IN %Exp:cCond%
 JOIN %table:SB1% SB1 ON SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.%NotDel% AND SB1.B1_COD = SD2.D2_COD
 WHERE SD2.D2_FILIAL = %xFilial:SD2% AND SD2.%NotDel% 
   AND SD2.D2_TIPO = %Exp:'D'% AND SD2.D2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR02)% AND %Exp:DTOS(MV_PAR03)% AND SF4.F4_ESTOQUE = %Exp:'S'%
 
 UNION
 SELECT %Exp:'03'% AS TRB_ORDEM, SD3.D3_NUMSEQ TRB_NUMSEQ, SB1.B1_DESC TRB_DESC, GA0.GA0_CODFAR TRB_CODFAR, GA0.GA0_DESC TRB_DESDES, 
        GA0.GA0_LISTA TRB_LISTA,  SD3.D3_EMISSAO TRB_EMISSA, %Exp:'NF'% TRB_REGATE, 
        SF5.F5_TEXTO TRB_NOME, SD3.D3_TM TRB_TIPMOV, SD3.D3_QUANT TRB_QTD,  %Exp:' '% TRB_CODCRM, 
        SB1.B1_COD TRB_CODPRO
 FROM %table:SD3% SD3
 JOIN %table:SB1% SB1 ON SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.%NotDel% AND SB1.B1_COD = SD3.D3_COD
 LEFT JOIN %table:SF5% SF5 ON SF5.F5_FILIAL  = %xFilial:SF5% AND SF5.%NotDel% AND SF5.F5_CODIGO = SD3.D3_TM
 JOIN %table:GBI% GBI ON GBI.GBI_FILIAL = %xFilial:GBI% AND GBI.%NotDel% AND GBI.GBI_FARMAC <> %Exp:' '% 
                     AND GBI.GBI_PRODUT = SD3.D3_COD
 JOIN %table:GA0% GA0 ON GA0.GA0_FILIAL = %xFilial:GA0% AND GA0.%NotDel% AND GBI.GBI_FARMAC = GA0.GA0_CODFAR 
                     AND GA0.GA0_LISTA IN %Exp:cCond%
 WHERE SD3.D3_FILIAL = %xFilial:SD3% AND SD3.%NotDel% 
   AND SD3.D3_EMISSAO BETWEEN %Exp:DTOS(MV_PAR02)% AND %Exp:DTOS(MV_PAR03)% AND SD3.D3_ESTORNO NOT IN (%Exp:'S'%)
   AND NOT EXISTS (SELECT GCY.GCY_REGATE FROM %table:GCY% GCY
                   WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel% AND GCY.GCY_REGATE = SD3.D3_REGATEN)
 ORDER BY TRB_LISTA, TRB_DESC, TRB_EMISSA, TRB_ORDEM, TRB_NUMSEQ
EndSql

	oSection1:EndQuery()
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYRC5")->TRB_DESC == G }, {|| ("QRYRC5")->TRB_DESC }) // Quebra por produto
 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYRC5->(LastRec()))

// imprime os termos de abertura e de encerramento

 lImprimiu:=.T.
	nPags			+= 1
	nPagFim	+= 1

	oReport:Section(2):Init()
	oReport:SkipLine(10)

 For nI := 1 To 2
  
  If nI == 2 
   oReport:Section(2):SetPageBreak(.T.)
  	oReport:SkipLine(250)         //PULA FOLHA
  EndIf

 	oReport:SkipLine(2)

 	If MV_PAR04 == 2 
   oReport:PrintText((PADC(IIF(nI == 1, STR0028, STR0029), Limite)),oReport:Row(),010) //"TERMO DE ABERTURA"###"TERMO DE ENCERRAMENTO"
 	Else
	 	cTit := IIF(nI == 1, STR0028, STR0029)                    //"TERMO DE ABERTURA"###"TERMO DE ENCERRAMENTO"
   oReport:PrintText((PADC(cTit + STR0030, Limite)),oReport:Row(),000) //" - IMPRESSรO PARA SIMPLES CONFERสNCIA"
	 EndIf
 	oReport:SkipLine(2)
  oReport:PrintText((STR0031 + AllTrim(Str(nPags)) + STR0032 + AllTrim(Str(nPagIni)) + STR0033 + AllTrim(Str(nPagFim))),oReport:Row(), 010)     //"  Este livro que cont้m "###" folhas numeradas de "###" a "
 	oReport:SkipLine(2)
  oReport:PrintText((STR0034 + GED->GED_DESCRI),oReport:Row(),010)  //"     servindo para o registro de "
 	oReport:SkipLine(3)
  oReport:PrintText(	STR0035 + FS_GETLIST(),oReport:Row(), 010)      //"     LISTA.............: "
 	oReport:SkipLine(2)
  oReport:PrintText(	STR0036 + SM0->M0_NOMECOM,oReport:Row(), 010)   //"     Da Firma..........: "
 	oReport:SkipLine(2)
  oReport:PrintText(	STR0037 + SM0->M0_ENDENT,oReport:Row(), 010)    //"     Estabelecida a....: "
 	oReport:SkipLine(2)
  oReport:PrintText(	STR0038 + ALLTRIM(SM0->M0_CIDENT) + " - " + SM0->M0_ESTENT,oReport:Row(), 010) //"   No municํpio de...: "
 	oReport:SkipLine(2)
  oReport:PrintText(	STR0039 + SM0->M0_INSC,oReport:Row(), 010)      //"     Inscri็ใo Estadual: "
 	oReport:SkipLine(2)
  oReport:PrintText(	STR0040 + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"),oReport:Row(), 010)  //"    CNPJ..............: "
 	oReport:SkipLine(3)
  oReport:PrintText(	STR0041 + cCrfFar,oReport:Row(), 010)           //"     Farmac๊utico......: "
 	oReport:SkipLine(10)
  oReport:PrintText(	"           "+ FS_RETDIA(),oReport:Row(), 010) 
 	oReport:SkipLine(5)
  oReport:PrintText(	"           ______________________________________________________________",oReport:Row(), 010)
 	oReport:SkipLine(5)
  oReport:PrintText(	"           ______________________________________________________________",oReport:Row(), 010)
 	oReport:SkipLine(2)
  If MV_PAR04 == 2
   oReport:PrintText(STR0042,oReport:Row(), 010)    //"                  ( Assinatura e carimbo da Autoridade Sanitแria )"
  Else
   oReport:PrintText(STR0043,oReport:Row(), 010)    //"           CONFERสNCIA-CONFERสNCIA-CONFERสNCIA-CONFERสNCIA-CONFERสNCIA"
  EndIf
 Next nI
 
 If lImprimiu .And. MV_PAR04 == 2
 	RecLock("GED", .F.)
 	GED->GED_PAGINI := nPagIni
 	GED->GED_PAGFIM := nPagFim
 	GED->GED_PERINI := IIF(Empty(GED->GED_PERINI), MV_PAR02, GED->GED_PERINI)
 	GED->GED_PERFIM := MV_PAR02
 	MsUnlock()
 EndIf

Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRC5R3บ Autor ณ Alessandro Freire  บ Data ณ  02/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Livro de Entorpecentes                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function Hspahrc5R3()

Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
Local cDesc2  := STR0002 //"de livros para a receita federal de acordo com os "
Local cDesc3  := STR0003 //"parโmetros informados pelo usuแrio."
Local cPict   := ""
Local titulo  := STR0004 //"Livro de Entorpecentes"
Local nLin    := 80
Local Cabec1	 := ""
Local Cabec2	 := ""
Local imprime	:= .T.
Local aOrd				:= {}
Local cPerg		 := "HSPRC5"

Private lEnd								:= .F.
Private lAbortPrint	:= .F.
Private CbTxt							:= ""
Private limite						:= 132
Private tamanho					:= "M"
Private nomeprog				:= "HSPAHRC5"
Private nTipo							:= 15
Private aReturn					:= {STR0005, 1, STR0006, 1, 2, 1, "", 1} //"Zebrado"###"Administra็ใo"
Private nLastKey				:= 0
Private cbcont						:= 00
Private CONTFL						:= 01
Private m_pag							:= 01
Private wnrel							:= "HSPAHRC5"
Private cCodImp     := ""
Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao

DbSelectArea("SD3")
DbSetOrder(1) // D3_FILIAL + D3_OP + D3_COD + D3_LOCAL

If !Pergunte("HSPRC5", .T.)
  Return
EndIf   

nMaxLin := HS_MaxLin(cCodImp)
nLin    := nMaxLin * 2

wnrel := SetPrint("SD3", NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn, "SD3")

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4] == 1, 15, 18)

RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
Return(Nil)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณAlessandro Freire   บ Data ณ  02/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)

Local cQry					 := ""
Local lFirst			 := .T.
Local lImpTer		 := .T.
Local lImprimiu := .F.
Local nSaldoEst := 0
Local nSaldo			 := 0
Local cPerda			 := GETMV("MV_HSPTMPD")
Local cLista			 := ""
Local cProd     := ""
Local nPags				 := 0
Local nPagIni		 := 0
Local nPagFim		 := 0

DbSelectArea("GED")
DbSetOrder(1) // GED_FILIAL + GED_CODIGO + GED_TIPO
If ! DbSeek(xFilial("GED") + MV_PAR01)
	HS_MsgInf(STR0007, STR0044, STR0004) //"O livro informado nใo existe"###"Aten็ใo"###"Livro de entorpecentes"
	Return(Nil)
EndIf
If MV_PAR04 = 2   //Impressao de conferencia.
	If MV_PAR02 < GED->GED_PERFIM
		HS_MsgInf(STR0008 + DTOC(GED->GED_PERFIM), STR0044, STR0004) //"O pr๓ximo perํodo deve ser superior a "###"Aten็ใo"###"Livro de entorpecentes"
	Return(.F.)
	EndIf
Endif
If GED->GED_PAGFIM == GED->GED_TOTPAG
	HS_MsgInf(STR0009, STR0044, STR0004) //"Este livro jแ estแ completo. Selecione outro."###"Aten็ใo"###"Livro de entorpecentes"
EndIf

m_pag 		:= GED->GED_PAGFIM + 1
nPagIni := m_pag
nPagFim	:= nPagIni - 1

/* 01 - livro F3  
   02 - PERIODO AAAAMM
   03 - MODO - 1=CONFERENCIA 2=LIVRO   */

cQry := "SELECT '04' AS TRB_ORDEM, SD3.D3_NUMSEQ TRB_NUMSEQ, SB1.B1_DESC TRB_DESC, GA0.GA0_CODFAR TRB_CODFAR, GA0.GA0_DESC TRB_DESDES, GA0.GA0_LISTA TRB_LISTA, "
cQry +=        "SD3.D3_EMISSAO TRB_EMISSA, SD3.D3_REGATEN TRB_REGATE, GCY.GCY_NOME TRB_NOME, SD3.D3_TM TRB_TIPMOV, "
cQry +=        "SD3.D3_QUANT TRB_QTD, GCY.GCY_CODCRM TRB_CODCRM, SB1.B1_COD TRB_CODPRO "
cQry += "FROM " + RetSqlName("SD3") + " SD3 "
cQry +=    "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = SD3.D3_COD "
cQry +=    "JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = SD3.D3_REGATEN "
cQry +=    "JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_FARMAC <> ' ' AND GBI.GBI_PRODUT = SD3.D3_COD "                      
cQry +=    "JOIN " + RetSqlName("GA0") + " GA0 ON GA0.GA0_FILIAL = '" + xFilial("GA0") + "' AND GA0.D_E_L_E_T_ <> '*' AND GBI.GBI_FARMAC = GA0.GA0_CODFAR AND GA0.GA0_LISTA IN (" + FS_GETLIST() + ") "
cQry += "WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' AND SD3.D_E_L_E_T_ <> '*' AND SD3.D3_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' "
cQry += "UNION "
cQry += "SELECT '01' AS TRB_ORDEM, SD1.D1_DOC TRB_NUMSEQ, SB1.B1_DESC TRB_DESC, GA0.GA0_CODFAR TRB_CODFAR, GA0.GA0_DESC TRB_DESDES, GA0.GA0_LISTA TRB_LISTA, "
cQry +=        "SD1.D1_DTDIGIT TRB_EMISSA, 'NF' TRB_REGATE, SA2.A2_NOME TRB_NOME, SD1.D1_TES TRB_TIPMOV, SD1.D1_QUANT TRB_QTD , ' ' TRB_CODCRM, "
cQry +=        "SB1.B1_COD TRB_CODPRO "
cQry += "FROM " + RetSqlName("SD1") + " SD1 "
cQry +=    "JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL  = '" + xFilial("SA2") + "' AND SA2.D_E_L_E_T_ <> '*' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA "
cQry +=    "JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL  = '" + xFilial("SF4") + "' AND SF4.D_E_L_E_T_ <> '*' AND SF4.F4_CODIGO = SD1.D1_TES "
cQry +=    "JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_FARMAC <> ' ' AND GBI.GBI_PRODUT = SD1.D1_COD "
cQry +=    "JOIN " + RetSqlName("GA0") + " GA0 ON GA0.GA0_FILIAL = '" + xFilial("GA0") + "' AND GA0.D_E_L_E_T_ <> '*' AND GBI.GBI_FARMAC = GA0.GA0_CODFAR AND GA0.GA0_LISTA IN (" + FS_GETLIST() + ") "
cQry +=    "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = SD1.D1_COD "
cQry += "WHERE SD1.D1_FILIAL  = '" + xFilial("SD1") + "' AND SD1.D_E_L_E_T_ <> '*' AND SD1.D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' AND SF4.F4_ESTOQUE = 'S' "
cQry += "UNION "
cQry += "SELECT '02' AS TRB_ORDEM, SD2.D2_DOC TRB_NUMSEQ, SB1.B1_DESC TRB_DESC, GA0.GA0_CODFAR TRB_CODFAR, GA0.GA0_DESC TRB_DESDES, GA0.GA0_LISTA TRB_LISTA, "
cQry +=        "SD2.D2_EMISSAO TRB_EMISSA, 'NF' TRB_REGATE, SA2.A2_NOME TRB_NOME, SD2.D2_TES TRB_TIPMOV, SD2.D2_QUANT TRB_QTD, "
cQry +=        "' ' TRB_CODCRM, SB1.B1_COD TRB_CODPRO "
cQry += "FROM " + RetSqlName("SD2") + " SD2 "
cQry +=     "JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL  = '" + xFilial("SA2") + "' AND SA2.D_E_L_E_T_ <> '*' AND SA2.A2_COD = SD2.D2_CLIENTE AND SA2.A2_LOJA = SD2.D2_LOJA "
cQry +=     "JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL  = '" + xFilial("SF4") + "' AND SF4.D_E_L_E_T_ <> '*' AND SF4.F4_CODIGO = SD2.D2_TES "
cQry +=     "JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_FARMAC <> ' ' AND GBI.GBI_PRODUT = SD2.D2_COD "
cQry +=     "JOIN " + RetSqlName("GA0") + " GA0 ON GA0.GA0_FILIAL = '" + xFilial("GA0") + "' AND GA0.D_E_L_E_T_ <> '*' AND GBI.GBI_FARMAC = GA0.GA0_CODFAR AND GA0.GA0_LISTA IN (" + FS_GETLIST() + ") "
cQry +=     "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = SD2.D2_COD "
cQry += "WHERE SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND SD2.D_E_L_E_T_ <> '*' AND SD2.D2_TIPO = 'D' AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' AND SF4.F4_ESTOQUE = 'S' "
cQry += "UNION "
cQry += "SELECT '03' AS TRB_ORDEM, SD3.D3_NUMSEQ TRB_NUMSEQ, SB1.B1_DESC TRB_DESC, GA0.GA0_CODFAR TRB_CODFAR, GA0.GA0_DESC TRB_DESDES, GA0.GA0_LISTA TRB_LISTA, "
cQry +=        "SD3.D3_EMISSAO TRB_EMISSA, 'NF' TRB_REGATE, SF5.F5_TEXTO TRB_NOME, SD3.D3_TM TRB_TIPMOV, "
cQry +=        "SD3.D3_QUANT TRB_QTD, ' ' TRB_CODCRM, SB1.B1_COD TRB_CODPRO "
cQry += "FROM " + RetSqlName("SD3") + " SD3 "
cQry +=    "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = SD3.D3_COD "
cQry +=    "LEFT JOIN " + RetSqlName("SF5") + " SF5 ON SF5.F5_FILIAL = '" + xFilial("SF5") + "' AND SF5.D_E_L_E_T_ <> '*' AND SF5.F5_CODIGO = SD3.D3_TM "
cQry +=    "JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_FARMAC <> ' ' AND GBI.GBI_PRODUT = SD3.D3_COD "                      
cQry +=    "JOIN " + RetSqlName("GA0") + " GA0 ON GA0.GA0_FILIAL = '" + xFilial("GA0") + "' AND GA0.D_E_L_E_T_ <> '*' AND GBI.GBI_FARMAC = GA0.GA0_CODFAR AND GA0.GA0_LISTA IN (" + FS_GETLIST() + ") "
cQry += "WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' AND SD3.D_E_L_E_T_ <> '*' AND SD3.D3_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' AND SD3.D3_ESTORNO NOT IN ('S') "
cQry += "AND NOT EXISTS (SELECT GCY.GCY_REGATE FROM " + RetSqlName("GCY") + " GCY "
cQry +=                 "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = SD3.D3_REGATEN) "   
cQry += "ORDER BY TRB_LISTA, TRB_DESC, TRB_EMISSA, TRB_ORDEM, TRB_NUMSEQ "

cQry :=  ChangeQuery(cQry)

DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), "TRB", .F., .F.)
TcSetField("TRB", "F", "D", 8, 0)

DbSelectArea("TRB")
SetRegua(RecCount())

DbGoTop()

While !EOF()
 
	// Esta variavel informa se devem ou nao ser impressos os termos no final do relatorio
	lImpTer   := .T.
	lImprimiu := .T.
		
	If lAbortPrint
		@nLin, 000 PSAY STR0010 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	
	If nLin > nMaxLin
	//                              1         2         3         4         5         6         7         8         9        10        11        12        13
 //                    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	 Cabec1 := STR0013 //"Data       Documento Hist๓rico                                            CRM       Entrada      Saํda      Perda    Estoque"
		Cabec2 := "" 
		Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)

		nLin				:= 8                                         
		nPags			+= 1
		nPagFim	+= 1
		
		If lFirst // deve somar o B9 para trazer o saldo do produto
		
			lFirst    := .F.
			nSaldoEst := FS_SaldoB9( TRB->TRB_CODPRO )
			nSaldo    := nSaldoEst
			
		EndIf       
		
		@ nLin, 000 PSAY SUBSTR(TRB->TRB_DESC, 1, 40) + "-" + SUBSTR(TRB->TRB_DESDES, 1, 40) + STR0011 + TRB->TRB_LISTA + STR0012 + GED->GED_CODIGO //"  LISTA: "###"  LIVRO: "
		nLin += 1
		@ nLin, 091 PSAY STR0014 //"Saldo Anterior.......:"
		@ nLin, 114 PSAY nSaldo PICTURE "@E 999,999.99"
		nLin += 2
		
	EndIf

	@ nLin, 000 PSAY IIF(Empty(TRB->TRB_EMISSA), " ", HS_DTOC(STOD(TRB->TRB_EMISSA), 1)) // data
	@ nLin, 011 PSAY TRB->TRB_NUMSEQ              // documento
	If ALLTRIM(TRB->TRB_REGATE) <> 'NF' // registro de atendimento  
		@ nLin, 021 PSAY  ALLTRIM(TRB->TRB_REGATE) + "-" + TRB->TRB_NOME  // historico
	Else
		@ nLin, 021 PSAY TRB->TRB_NOME //tipo de movimenta็ใo ou fornecedor
	EndIf
	@ nLin, 074 PSAY SUBSTR(TRB->TRB_CODCRM,1,6)  // crm
	
	IF ! (TRB->TRB_TIPMOV $ cPerda) // se nao for perda
		@ nLin, IIF(TRB->TRB_TIPMOV <= "500", 081, 092) PSAY TRB->TRB_QTD PICTURE "@E 999,999.99" // quantidade entrada ou saida
		nSaldo := IIF(TRB->TRB_TIPMOV <= "500", nSaldo + TRB->TRB_QTD, nSaldo - TRB->TRB_QTD)
	Else
		@ nLin, 0103 PSAY TRB->TRB_QTD PICTURE "@E 999,999.99" // quantidade perda
		nSaldo -= TRB->TRB_QTD
	EndIf
	
	@ nLin, 114 PSAY nSaldo PICTURE "@E 999,999.99" // Saldo em estoque
	
	nLin   := nLin + 1
	cLista := TRB->TRB_LISTA
	cProd  := TRB->TRB_CODPRO
	
	If nPagFim == GED->GED_PAGFIM
		// Imprime os termos de abertura e de encerramento
		FS_ImpTer(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, nPags, nPagIni, nPagFim)
		nPags   := 0   // zera a quantidade de paginas
		nPagFim := 0   // zera a pagina final
		nPagIni := 1   // reinicia a pagina inicial
		m_pag			:= 0   // reinicia a pagina inicial
		lImpTer := .F. // Nao precisa imprimir os termos no final 
		
		// Clona este livro com outro codigo para que seja possivel continuar a impressao
		If MV_PAR04 == 2
			FS_CloneL()
		EndIf
		
	EndIf
	
	DbSkip()
	
	If TRB->TRB_LISTA != cLista
		nLin	:= nMaxLin * 2
		If TRB->TRB_CODPRO != cProd
		 lFirst := .T.
	 Endif
	ElseIf TRB->TRB_CODPRO != cProd
	 If MV_PAR05 == 1
   nLin	:= nMaxLin * 2
  EndIf
	 nLin +=1
 	lFirst := .T.
 	@ nLin, 000 PSAY SUBSTR(TRB->TRB_DESC, 1, 40) + "-" + SUBSTR(TRB->TRB_DESDES, 1, 40) + STR0011 + TRB->TRB_LISTA + STR0012 + GED->GED_CODIGO //"  LISTA: "###"  LIVRO: "
 	nLin += 1   
		nSaldoEst := FS_SaldoB9(TRB->TRB_CODPRO)              
		nSaldo    := nSaldoEst
		@ nLin, 091 PSAY STR0014 //"Saldo Anterior.......:"
		@ nLin, 114 PSAY nSaldo PICTURE "@E 999,999.99"
		nLin += 2
	Else
	 If nLin > nMaxLin
	  lFirst := .F.
	 Endif 
	EndIf
	
EndDo
                                                                     
// imprime os termos de abertura e de encerramento
If lImpTer
	FS_ImpTer(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, nPags, nPagIni, nPagFim)
EndIf

If lImprimiu .And. MV_PAR04 == 2
	RecLock("GED", .F.)
	GED->GED_PAGINI := nPagIni
	GED->GED_PAGFIM := nPagFim
	GED->GED_PERINI := IIF(Empty(GED->GED_PERINI), MV_PAR02, GED->GED_PERINI)
	GED->GED_PERFIM := MV_PAR02
	MsUnlock()
EndIf

SET DEVICE TO SCREEN

If aReturn[5] == 1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()

DbSelectArea("TRB")
DbCloseArea()
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GetListบAutor  ณAlessandro Freire   บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a lista do livro informado                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GETLIST()

Local cRet := ""

// Posiciona no livro
DbSelectArea("GED")
DbSetOrder(1) // GED_FILIAL + GED_CODIGO + GED_TIPO
DbSeek(xFilial("GED") + MV_PAR01)

// Posiciona na amarracao tipo de livro por lista
DbSelectArea("GEC")
DbSetOrder(1) // GEC_FILIAL + GEC_TIPO
DbSeek(xFilial("GEC") + GED->GED_TIPO)

// Gera o retorno das listas envolvidas
While xFilial("GEC") == GEC->GEC_FILIAL .And. GEC->GEC_TIPO == GED->GED_TIPO

 DbSelectArea("GFO")
 DbSetOrder(1) // GFO_FILIAL + GFO_CODTIP + GFO_CODLIS
 DbSeek(xFilial("GFO") + GED->GED_TIPO)
 While xFilial("GFO") == GFO->GFO_FILIAL .And. GFO->GFO_CODTIP == GED->GED_TIPO
  cRet	+= "'" + GFO->GFO_CODLIS + "',"  
  DbSkip()
 EndDo
 DbSelectArea("GEC")
 DbSetOrder(1) // GEC_FILIAL + GEC_TIPO
	DbSkip()
EndDo

cRet := SubStr(cRet, 1, Len(cRet)-1 )

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RetDia บAutor  ณAlessandro Freire   บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a data no formato:                                  บฑฑ
ฑฑบ          ณ<cidade>, <data> de <mes> de <ano>                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_RetDia()

Local cRet			:= ""                           
Local aMeses := {STR0015, STR0016, STR0017, STR0018, STR0019, STR0020,;  //"Janeiro"###"Fevereiro"###"Mar็o"###"Abril"###"Maio"###"Junho"
                  STR0021, STR0022, STR0023, STR0024, STR0025, STR0026} //"Julho"###"Agosto"###"Setembro"###"Outubro"###"Novembro"###"Dezembro"
                  
cRet += IIF( ! Empty(SM0->M0_CIDENT), AllTrim(SM0->M0_CIDENT), STR0027 ) //"Atualizar SIGAMAT.EMP - M0_CIDCOB"
cRet += ", "
cRet += StrZero(Day(dDataBase), 2)
cRet += " de "
cRet += aMeses[ Month(dDataBase) ]
cRet += " de "
cRet += StrZero(Year(dDataBase),4)

Return( cRet )
                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ImpTer บAutor  ณAlessandro Freire   บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime os termos de abertura e encerramento                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ImpTer(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, nPags, nPagIni, nPagFim)

Local nI   := 1
Local cTit := ""                                                            
Local cMVHspFarm := AllTrim(GetMv("MV_HSPFARM"))
Local cCrfFar    := SubStr(cMVHspFarm, At("/", cMVHspFarm) + 1)

For nI := 1 To 2
	// Imprime os termos de abertura e encerramento
	Cabec1 := ""
	Cabec2 := ""
	m_pag  := 0

	IF cConfR4=='N'
 	Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 ENDI
 
	If MV_PAR04 == 2
		@ 010, 000 PSAY PADC(IIF(nI == 1, STR0028, STR0029), Limite) //"TERMO DE ABERTURA"###"TERMO DE ENCERRAMENTO"
	Else
		cTit := IIF(nI == 1, STR0028, STR0029) //"TERMO DE ABERTURA"###"TERMO DE ENCERRAMENTO"
		@ 010, 000 PSAY PADC(cTit + STR0030, Limite) //" - IMPRESSรO PARA SIMPLES CONFERสNCIA"
	EndIf
	@ 012, 000 PSAY STR0031 + AllTrim(Str(nPags)) + STR0032 + AllTrim(Str(nPagIni)) + STR0033 + AllTrim(Str(nPagFim)) //"           Este livro que cont้m "###" folhas numeradas de "###" a "
	@ 014, 000 PSAY STR0034 + GED->GED_DESCRI   //"           servindo para o registro de "
	@ 017, 000 PSAY STR0035 + FS_GETLIST() //"           LISTA.............: "
	@ 019, 000 PSAY STR0036 + SM0->M0_NOMECOM //"           Da Firma..........: "
	@ 021, 000 PSAY STR0037 + SM0->M0_ENDENT //"           Estabelecida a....: "
	@ 023, 000 PSAY STR0038 + ALLTRIM(SM0->M0_CIDENT) + " - " + SM0->M0_ESTENT //"           No municํpio de...: "
	@ 025, 000 PSAY STR0039 + SM0->M0_INSC           //"           Inscri็ใo Estadual: "
	@ 027, 000 PSAY STR0040 + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") //"           CNPJ..............: "
	@ 030, 000 PSAY STR0041 + cCrfFar //"           Farmac๊utico......: "
	@ 039, 000 PSAY "           "+ FS_RETDIA() 
	@ 044, 000 PSAY "           ______________________________________________________________"
	@ 049, 000 PSAY "           ______________________________________________________________"
	
	If MV_PAR04 == 2
		@ 051, 000 PSAY STR0042 //"                  ( Assinatura e carimbo da Autoridade Sanitแria )"
	Else
		@ 051, 000 PSAY STR0043 //"           CONFERสNCIA-CONFERสNCIA-CONFERสNCIA-CONFERสNCIA-CONFERสNCIA"
	EndIf
Next nI

nLin := nMaxLin * 2
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CloneL บAutor  ณAlessandro Freire   บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClona o cadastro de livros com outro c๓digo para que seja   บฑฑ
ฑฑบ          ณpossivel continuar a impressao                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CloneL(nPagIni, nPagFim)
                                
Local cCodigo := GetSxeNum("GED_CODIGO")
Local cDescri := GED->GED_DESCRI
Local cTipo   := GED->GED_TIPO
Local nTotPag := GED->GED_TOTPAG

RecLock("GED", .F.)
GED->GED_PAGINI := nPagIni
GED->GED_PAGFIM := nPagFim
GED->GED_PERINI := IIF( Empty(GED->GED_PERINI), MV_PAR02, GED->GED_PERINI )
GED->GED_PERFIM := MV_PAR02
MsUnlock()

RecLock("GED", .T.)
GED->GED_FILIAL := xFilial("GED")
GED->GED_CODIGO	:= cCodigo
GED->GED_DESCRI := cDescri
GED->GED_TIPO			:= cTipo
GED->GED_TOTPAG := nTotPag
MsUnlock()

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SaldoB9บAutor  ณAlessandro Freire   บ Data ณ  30/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o saldo do B9 de um determinado produto em uma      บฑฑ
ฑฑบ          ณdeterminada data                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SaldoB9(cProduto)

Local nMes    := Month(MV_PAR02)
Local nAno    := Year(MV_PAR02)
Local cAnoMes := ""
Local cQry	   := ""
Local nRet				:= 0

If nMes == 1
	nMes := 12
	nAno := nAno - 1
Else
	nMes := nMes - 1
EndIf

cAnoMes := StrZero(nAno, 4) + StrZero(nMes, 2)

cQry := "SELECT SUM(B9_QINI) A "
cQry += "  FROM " + RetSqlName("SB9") + " SB9 "
cQry += " WHERE D_E_L_E_T_ <> '*' AND "
cQry += "       B9_FILIAL = '" + xFilial("SB9") + "' AND "
cQry += "       B9_COD = '" + cProduto + "' AND"
cQry += "       B9_DATA = (SELECT MAX(SB9A.B9_DATA) FROM " + RetSqlName("SB9") + " SB9A " + " WHERE SUBSTRING(SB9A.B9_DATA,1,6) <= '" + cAnoMes +"' AND"
cQry += "       D_E_L_E_T_ <> '*' AND "
cQry += "       B9_FILIAL = '" + xFilial("SB9") + "' AND "
cQry += "       B9_COD = '" + cProduto + "')

cQry :=  ChangeQuery(cQry)

DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), "TRB2", .F., .F.)

nRet := TRB2->A

DbCloseArea()

If cConfR4<>'S'
 DbSelectArea("TRB")
EndIf
Return(nRet)
