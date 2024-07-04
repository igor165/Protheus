#INCLUDE "HSPAHR15.ch"
#Include "protheus.ch"
#INCLUDE "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR15  บ Autor ณ Mario Arizono      บ Data ณ  10/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Conta Previa                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ                
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR15(cProgCh, aGuiasP12)
                                                     
Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
Local cDesc2  := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
Local cDesc3  := STR0003 //"Contas Previas por Paciente"
Local cPict   := ""
Local imprime := .T.
Local aOrd    := {}
Local aArea   := GetArea()
Local aGuias  := IIF(!Empty(aGuiasP12), aClone(aGuiasP12), {})

Private titulo      := STR0004 //"Contas Previas por Paciente -"
Private nLin        := 80
Private Cabec1      := ""
Private Cabec2      := ""
Private	cCab_       := Repl("-",132)
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "HSPAHR15"
Private nTipo       := 18
Private aReturn     := {STR0005, 1, STR0006, 2, 1, 1, "", 1}  //"Zebrado"###"Administra็ใo"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01 
Private nPag        := 0
Private wnrel       := "HSPAHR15"
Private cString     := ""
Private cRegger     := ""   
Private cNrSeqg     := ""
Private lChamado    := !Empty(cProgCh)
Private cCODIMP     := ""
Private nMaxLin     := 0 
Private bRepli      := {|| REPLI("_", limite)}
Private nOrdIteFat  := 0
Private nMaxConta:=0
 Private lTamProd := IIf((TamSx3("GD5_CODDES")[1])<=15, .T., .F.) 


If !lChamado
	Pergunte("HSPR15", .T.)
	cRegAte := MV_PAR01
	nModRel := MV_PAR02
	nTpRel  := MV_PAR03
	nImpFab := MV_PAR04
	aGuias := FS_R15Guias(cRegAte, nModRel)
Else
 If !Pergunte("HSR15C", .T.)
  Return()
 EndIf
 nTpRel    := MV_PAR01
	nImpFab   := MV_PAR02
	nOrdIteFat:= MV_PAR03 
	nOrdemGui := MV_PAR04
	lProcCir  := MV_PAR05 == 2
	cCODIMP   := MV_PAR06
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

If len(aGuias) == 0
	HS_MsgInf(STR0007, STR0008, STR0009)  //"Nenhuma guia foi selecionada. Verifique!"###"Aten็ใo"###"Descritivo da Fatura"
	Return()
EndIf

wnrel := SetPrint(cString, NomeProg, Nil, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn, cString)

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4] == 1, 15, 18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(aGuias)}, Titulo)

SET PRINTER TO
SET DEVICE TO SCREEN

If aReturn[5] == 1 
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()

RestArea(aArea)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  10/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(aGuias)

Local cGD5     := ""
Local cGD6     := ""
Local cGD7     := ""
Local cQry     := ""
Local cDESCUNC := "", cCodPro := "", cDesPro := ""
Local cDESCGRU := ""
Local nTotGer  := 0, nPosDesc := 0, nValDesc := 0
Local	nGrpDesp := 0
Local nUniCons := 0 
Local nTotDat  := 0
Local nForGui  := 0
Local aRet     := {}, aM2Film := {}
Local nCont	  	:= 0, nFilm := 0
Local nPosRes  := 0
Local vVM2FRX  := 0
Local cRepDir  := "", cCodPropr := "", cCpoPropr := ""
Local nTotDsc  := 0

Private aVetDes := {}
Private aVetRes := {}
Private aVetCir := {}

If FunName() <> "HSPAHP12"                                        ///    ANTONIO
 aSort(aGuias,,,{|x,y| x[2]+x[1] < y[2]+y[1]}) //REGATE + NRSEQG
Else
 If !Empty(aGuias[1,3]) .And. nOrdemGui == 1
  aSort(aGuias,,,{|x,y| x[3] < y[3]})
 Endif
Endif

For nForGui := 1 to len(aGuias)
    Titulo      := STR0004 //"Reinicializa com a STR padrao"
	m_pag := 01
	DbSelectArea("GCZ")
	DbSetOrder(1) //GCZ_FILIAL + GCZ_NRSEQG + GCZ_STATUS
	DbSeek(xFilial("GCZ") + aGuias[nForGui, 1])
	
	cRepDir := HS_INIPADR("GA9",1, GCZ->GCZ_CODCON, "GA9_REPDIR",,.F.)
	cCodPropr := HS_INIPADR("GA9",1, GCZ->GCZ_CODCON, "GA9_CODPRO",,.F.)
	cCpoPropr := Iif(FindFunction("HS_RCDPROD"),HS_RCDPROD(GCZ->GCZ_CODCON)[1], "")
	 
	If lChamado
		cGD5 := IIF(GCZ->GCZ_STATUS $ "0/1", "GD5", "GE5")
		cGD6 := IIF(GCZ->GCZ_STATUS $ "0/1", "GD6", "GE6")
		cGD7 := IIF(GCZ->GCZ_STATUS $ "0/1", "GD7", "GE7")
	Else
		cGD5 := IIF( nModRel == 2, "GD5", "GE5" )
		cGD6 := IIF( nModRel == 2, "GD6", "GE6" )
		cGD7 := IIF( nModRel == 2, "GD7", "GE7" )
	EndIf
	
	cQry := "SELECT 'G5' AS IDTAB, " + cGD5 + "_REGATE TRB_REGATE, " + cGD5 + "_NRSEQG TRB_NRSEQG, GCS_CODUNC TRB_CODUNC, GCT_DESUNC TRB_DESUNC, "
	cQry += " GBI_CODGDE TRB_CODGDE, GBI_UNICON TRB_UNICON, GAW_DESC TRB_DESGRP, B1_UM TRB_UM, B1_FABRIC TRB_FABRIC, " + cGD5 + "_QTDDES TRB_QTDDES, "
	cQry += " " + cGD5 + "_VALDES TRB_VALDES, " + HS_FVALDES(cGD5) + " TRB_VALTOT, 0 TRB_QTDCHP, ' ' TRB_NOMMED, " + cGD5 + "_CODDES TRB_CODIGO, "
	cQry += " B1_DESC TRB_DESC, ' ' TRB_CRM,	' ' TRB_TIPDES, " + cGD5 + "_DATDES TRB_DATDES," + cGD5 + "_HORDES TRB_HORDES, ' ' TRB_PGTMED, "
 	cQry += " 0 TRB_COECHP, ' ' TRB_DESATO, 0 TRB_VFILME, 0 TRB_METFIL, ' ' TRB_CODLOC, 0 TRB_VLRCOS, ' '  TRB_CODPRT,  ' ' TRB_DESPRT, GAW_ORDITF TRB_ORDITF, " 
 	cQry += "	' ' TRB_DOCCIR, ' ' TRB_DATFIM, ' ' TRB_HORFIM, ' ' TRB_TIPATM, ' ' TRB_TPANES, 0 TRB_COEDES, " + cGD5 + "_DESVAL TRB_DESVAL,  " + cGD5 + "_DESOBS TRB_DESOBS, "
 	cQry += cGD5 + "_CODPRO TRB_CODPRO, " + cGD5 + "_DESPRO TRB_DESPRO, GCB_PRODUT,GCB_CODPRO,GCB_CODCON,GCB_CDTISS, GCB_DESCON,GCB_DESPRO AS GCB_DESPRO2  "
	cQry += " FROM " + RetSqlName(cGD5) + " " + cGD5
	cQry += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = " + cGD5 + "." + cGD5 + "_CODLOC "
	cQry += " JOIN " + RetSqlName("GCB") + " GCB ON GCB.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB.D_E_L_E_T_ <> '*' AND GCB.GCB_CODTAB = " + cGD5 + "." + cGD5 + "_TABELA AND GCB.GCB_PRODUT = " + cGD5 + "." + cGD5 + "_CODDES "	
	cQry += " JOIN " + RetSqlName("GCT") + " GCT ON GCT.GCT_FILIAL = '" + xFilial("GCT") + "' AND GCT.D_E_L_E_T_ <> '*' AND GCT.GCT_CODUNC = GCS.GCS_CODUNC "
	cQry += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD     = " + cGD5 + "." + cGD5 + "_CODDES "
	cQry += " JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_PRODUT = SB1.B1_COD "
	cQry += " JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_CODGDE = GBI.GBI_CODGDE "
	cQry += " WHERE " + cGD5 + "_FILIAL = '" + xFilial(cGD5) + "' AND " + cGD5 + ".D_E_L_E_T_ <> '*' "
	cQry += "       AND " + cGD5 + "_NRSEQG = '" + aGuias[nForGui, 1] + "' "
	cQry += "       AND " + cGD5 + "_GLODES = '0' "
 	cQry += " AND GCB.GCB_DATVIG = ( SELECT MAX(GCB1.GCB_DATVIG) "
 	cQry += " FROM " + RetSQLName("GCA") + " GCA "  
 	cQry += " JOIN " + RetSQLName("GCB") + " GCB1 ON GCB1.GCB_CODTAB = GCA.GCA_CODTAB "
 	cQry += " WHERE"
 	cQry += "     GCA.GCA_FILIAL  = '" + xFilial("GCA") + "' AND GCA.D_E_L_E_T_ <> '*' "
 	cQry += " AND GCB1.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB1.D_E_L_E_T_ <> '*' "
 	cQry += " AND GCB1.GCB_CODTAB = GCB.GCB_CODTAB  "
 	cQry += " AND GCB1.GCB_PRODUT = GCB.GCB_PRODUT ) "
	
	cQry += " UNION ALL "
	cQry += " SELECT 'G6' AS IDTAB, " + cGD6 + "_REGATE TRB_REGATE, " + cGD6 + "_NRSEQG TRB_NRSEQG, GCS_CODUNC TRB_CODUNC, GCT_DESUNC TRB_DESUNC, "
	cQry += " GAA_CODGDE TRB_CODGDE, ' ' TRB_UNICON, GAW_DESC TRB_DESGRP, ' ' TRB_UM, ' ' TRB_FABRIC, " + cGD6 + "_QTDDES TRB_QTDDES, "
	cQry += " " + cGD6 + "_VALDES TRB_VALDES, " + HS_FVALDES(cGD6) + " TRB_VALTOT, 0 TRB_QTDCHP, ' ' TRB_NOMMED, " + cGD6 + "_CODTXC TRB_CODIGO, "
	cQry += " " + cGD6 + "_DESTXC TRB_DESC, ' ' TRB_CRM, GAA_TIPDES TRB_TIPDES, " + cGD6 + "_DATDES TRB_DATDES," + cGD6 + "_HORDES TRB_HORDES, ' ' TRB_PGTMED, "
 	cQry += " 0 TRB_COECHP, ' ' TRB_DESATO,  0 TRB_VFILME, 0 TRB_METFIL, ' ' TRB_CODLOC, 0 TRB_VLRCOS, ' '  TRB_CODPRT, ' ' TRB_DESPRT, GAW_ORDITF TRB_ORDITF, " 
 	cQry += "	' ' TRB_DOCCIR, ' ' TRB_DATFIM, ' ' TRB_HORFIM, ' ' TRB_TIPATM, ' ' TRB_TPANES, 0 TRB_COEDES, " + cGD6 + "_DESVAL TRB_DESVAL,  " + cGD6 + "_DESOBS TRB_DESOBS, " 
 	cQry += " ' ' TRB_CODPRO ,' 'TRB_DESPRO ,' ' GCB_PRODUT, ' ' GCB_CODPRO,' ' GCB_CODCON,' ' GCB_CDTISS ,' ' GCB_DESCON ,' ' GCB_DESPRO2 "
	cQry += " FROM " + RetSqlName(cGD6) + " " + cGD6
	cQry += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = " + cGD6 + "." + cGD6 + "_CODLOC "
	cQry += " JOIN " + RetSqlName("GCT") + " GCT ON GCT.GCT_FILIAL = '" + xFilial("GCT") + "' AND GCT.D_E_L_E_T_ <> '*' AND GCT.GCT_CODUNC = GCS.GCS_CODUNC "
	cQry += " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD = " + cGD6 + "." + cGD6 + "_CODDES "
	cQry += " JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_CODGDE = GAA.GAA_CODGDE "
	cQry += " WHERE " + cGD6 + "_FILIAL = '" + xFilial(cGD6) + "' AND " + cGD6 + ".D_E_L_E_T_ <> '*' "
	cQry += "       AND " + cGD6 + "_NRSEQG = '" + aGuias[nForGui, 1] + "' "
	cQry += "       AND " + cGD6 + "_GLODES = '0' "
	
	cQry += " UNION ALL "
	cQry += " SELECT 'G7' AS IDTAB, " + cGD7 + "_REGATE TRB_REGATE, " + cGD7 + "_NRSEQG TRB_NRSEQG, GCS_CODUNC TRB_CODUNC, GCT_DESUNC TRB_DESUNC, "
	cQry += " GA7_CODGDE TRB_CODGDE, ' ' TRB_UNICON, GAW_DESC TRB_DESGRP, ' ' TRB_UM, ' ' TRB_FABRIC, " + cGD7 + "_QTDDES TRB_QTDDES, " + cGD7 + "_VALDES TRB_VALDES, "
	cQry += " " + HS_FVALDES(cGD7) + " TRB_VALTOT, " + cGD7 + "_QTDCHP TRB_QTDCHP, RA_NOME TRB_NOMMED, " + cGD7 + "_CODDES TRB_CODIGO, "
	cQry += " GA7_DESC TRB_DESC,  " + cGD7 + "_CODCRM TRB_CRM, ' ' TRB_TIPDES, " + cGD7 + "_DATDES TRB_DATDES," + cGD7 + "_HORDES TRB_HORDES,  " + cGD7 + "_PGTMED TRB_PGTMED, "
	cQry += " " + cGD7 + "_COECHP TRB_COECHP, GMC_DESATO TRB_DESATO, " + cGD7 + "_VFILME TRB_VFILME, GA7_METFIL TRB_METFIL, GCS_CODLOC TRB_CODLOC, " + cGD7 + "_VLRCOS TRB_VLRCOS, " 
	cQry += " " + cGD7 + "_CODPRT TRB_CODPRT, " + cGD7 + "_DESPRT TRB_DESPRT, GAW_ORDITF TRB_ORDITF, "
	cQry += " " + cGD7 + "_DOCCIR TRB_DOCCIR, " + cGD7 + "_DATFIM TRB_DATFIM, "                   //23/08
	cQry += " " + cGD7 + "_HORFIM TRB_HORFIM, GMC.GMC_TIPATM TRB_TIPATM, " + cGD7 + "_TPANES TRB_TPANES, " + cGD7 + "_COEDES TRB_COEDES, "
	cQry += " " + cGD7 + "_DESVAL TRB_DESVAL,  " + cGD7 + "_DESOBS TRB_DESOBS, ' ' TRB_CODPRO,' ' TRB_DESPRO ,' ' GCB_PRODUT, ' ' GCB_CODPRO,' ' GCB_CODCON,' ' GCB_CDTISS , ' ' GCB_DESCON,' ' GCB_DESPRO2 "
	cQry += " FROM " + RetSqlName(cGD7) + " " + cGD7
	cQry += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = " + cGD7 + "." + cGD7 + "_CODLOC "
	cQry += " JOIN " + RetSqlName("GCT") + " GCT ON GCT.GCT_FILIAL = '" + xFilial("GCT") + "' AND GCT.D_E_L_E_T_ <> '*' AND GCT.GCT_CODUNC = GCS.GCS_CODUNC "
	cQry += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = " + cGD7 + "." + cGD7 + "_CODDES "
	cQry += " JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_CODGDE = GA7.GA7_CODGDE "
	cQry += " JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = " + cGD7 + "." + cGD7 + "_CODCRM "
	cQry += " LEFT JOIN " + RetSqlName("GMC") + " GMC ON GMC.GMC_FILIAL = '"+xFilial("GMC")+"' AND GMC.D_E_L_E_T_ <> '*' AND GMC.GMC_CODATO = " + cGD7 + "." + cGD7 + "_CODATO "
	cQry += " WHERE " + cGD7 + "_FILIAL = '" + xFilial(cGD7) + "' AND " + cGD7 + ".D_E_L_E_T_ <> '*' "
	cQry += "       AND " + cGD7 + "_NRSEQG  = '" + aGuias[nForGui,1] + "' "
	cQry += "       AND " + cGD7 + "_GLODES  = '0' "
	
	If nTpRel == 1 //Sintetico
	 cQry += " ORDER BY TRB_REGATE, TRB_NRSEQG, TRB_CODUNC, TRB_CODGDE, TRB_DESC"
	Else               
	 cQry += " ORDER BY TRB_REGATE, TRB_NRSEQG, TRB_CODUNC, TRB_CODGDE, TRB_DATDES, TRB_HORDES"
	Endif 
	
	TCQUERY cQry NEW ALIAS "TRB"
	
	DbSelectArea("TRB")
	SetRegua(150)
	DbGoTop()
	
	If nTpRel == 1 
  Titulo := ALLTRIM(Titulo) + STR0010 //" Sintetico"
 Else
  Titulo := ALLTRIM(Titulo) + STR0011 //" Analitico"
 EndIf
	
	While !EOF()
		
		If lAbortPrint
			@nLin, 000 PSAY STR0012 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		EndIf
		
		If TRB->IDTAB == "G5"
			If (nPos := aScan(aVetDes, {|aVetDes| aVetDes[5] == (IIF(cCodPropr == "2", TRB->TRB_CODPRO, IIf(cCodPropr == "0", TRB->TRB_CODIGO,&("TRB->" + cCpoPropr))))/*TRB->TRB_CODIGO*/ .And. aVetDes[9] == TRB->TRB_VALDES .And. ;
				aVetDes[3] == TRB->TRB_DESUNC .And. aVetDes[4] == TRB->TRB_DESGRP .and. IIF(nTpRel == 2,	aVetDes[11] == TRB->TRB_DATDES,.T.) }) ) == 0 
				AADD(aVetDes, {TRB->IDTAB, ; //[1] Tabela
				 TRB->TRB_REGATE, ;  //[2]  Registro de Atendimento
				 TRB->TRB_DESUNC, ;  //[3]  Descricao de Unidade de Consumo
				 TRB->TRB_DESGRP, ;  //[4]  Descri็ao do Grupo Despesas
				 IIF(cCodPropr == "1", TRB->TRB_CODPRO, IIf(cCodPropr == "0", TRB->TRB_CODIGO,Iif(empty(&("TRB->" + cCpoPropr)),TRB->TRB_CODIGO,&("TRB->" + cCpoPropr)))), ;  //[5]  Codigo do Produto
				 IIF(cCodPropr == "1", TRB->TRB_DESPRO, IIf(cCpoPropr == "GCB_CODCON",TRB->GCB_DESCON,IIf(cCpoPropr == "GCB_CODPRO",TRB->GCB_DESPRO2,TRB->TRB_DESC))),; //[6]  Descricao do Produto 			 	  
				 TRB->TRB_UNICON, ;  //[7]  Unidade de Medida
				 TRB->TRB_QTDDES, ;  //[8]  Quantidade
				 TRB->TRB_VALDES, ;  //[9]  Valor Unitario
				 TRB->TRB_VALTOT, ;  //[10] Valor Total
				 TRB->TRB_DATDES, ;  //[11] Data da Despesa
				 TRB->TRB_HORDES, ;  //[12] Hora da Despesa 
     			TRB->TRB_FABRIC, ;  //[13] Fabricante     
				 TRB->TRB_TIPDES, ;  //[14] Tipo da Despesa 
     TRB->TRB_NRSEQG, ;  //[15] Nr Seq Guia 
     TRB->TRB_ORDITF, ;  //[16] Ordem Itens fatura
     TRB->TRB_CODGDE, ;  //[17] Cod Grp Despesa
     TRB->TRB_CODUNC, ;  //[18] Cod Unid Consumo  
  	  TRB->TRB_DESVAL, ;  //[19] Valor Desconto    
  	  TRB->TRB_DESOBS})   //[20] Motivo Desconto
  	Else
			 aVetDes[nPos,8]  += TRB->TRB_QTDDES
				aVetDes[nPos,10] += TRB->TRB_VALTOT
				If !Empty(TRB->TRB_DESVAL)
			 	aVetDes[nPos,19] += TRB->TRB_DESVAL
				EndIf
			End
			
		ElseIf  TRB->IDTAB == "G6"
			If (nPos := aScan(aVetDes, {|aVetDes| aVetDes[5] == TRB->TRB_CODIGO .And. aVetDes[9] == TRB->TRB_VALDES .And. ;
				aVetDes[3] == TRB->TRB_DESUNC .And. aVetDes[4] == TRB->TRB_DESGRP .and. 	IIF(nTpRel == 2,	aVetDes[11] == TRB->TRB_DATDES,.T.)}) ) == 0 
				AADD(aVetDes, {TRB->IDTAB, ;       //[1] Tabela
				TRB->TRB_REGATE, ;  //[2]  Registro de Atendimento
				TRB->TRB_DESUNC, ;  //[3]  Descricao de Unidade de Consumo
				TRB->TRB_DESGRP, ;  //[4]  Descri็ao do Grupo Despesas
				TRB->TRB_CODIGO, ;  //[5]  Codigo do Produto
				TRB->TRB_DESC  , ;  //[6]  Descricao do Produto
				TRB->TRB_UM    , ;  //[7]  Unidade de Medida
				TRB->TRB_QTDDES, ;  //[8]  Quantidade
				TRB->TRB_VALDES, ;  //[9]  Valor Unitario
				TRB->TRB_VALTOT, ;  //[10] Valor Total 			
				TRB->TRB_DATDES, ;  //[11] Data da Despesa
			 TRB->TRB_HORDES, ;  //[12] Hora da Despesa 
    TRB->TRB_FABRIC, ;  //[13] Fabricante     
			 TRB->TRB_TIPDES, ;  //[14] Tipo da Despesa 	   
    TRB->TRB_NRSEQG, ;  //[15] Nr Seq Guia 
    TRB->TRB_ORDITF, ;  //[16] Ordem Itens fatura
    TRB->TRB_CODGDE, ;  //[17] Cod Grp Despesa
    TRB->TRB_CODUNC, ;  //[18] Cod Unid Consumo  
			 TRB->TRB_DESVAL, ;  //[19] Valor Desconto    
  	 TRB->TRB_DESOBS})   //[20] Motivo Desconto
			Else
			 aVetDes[nPos,8]  += TRB->TRB_QTDDES
			 aVetDes[nPos,10] += TRB->TRB_VALTOT
				If !Empty(TRB->TRB_DESVAL)
			 	aVetDes[nPos,19] += TRB->TRB_DESVAL
				EndIf
			EndIf
		ElseIf TRB->TRB_PGTMED <> "0" .Or. cRepDir $ "1/2"
 		aM2Film := FS_M2FILM(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA,TRB->TRB_CODIGO, STOD(TRB->TRB_DATDES),TRB->TRB_METFIL, TRB->TRB_CODLOC)  
		 cCodPro := IIF(EMPTY(TRB->TRB_CODPRT), TRB->TRB_CODIGO, TRB->TRB_CODPRT)
		 cDesPro := IIF(EMPTY(TRB->TRB_CODPRT), TRB->TRB_DESC, TRB->TRB_DESPRT)
		 If (nPos := aScan(aVetDes, {|aVetDes| aVetDes[5] == cCodPro .And. aVetDes[9] == TRB->TRB_VALDES .And. ;
			 aVetDes[3] == TRB->TRB_DESUNC .And. aVetDes[4] == TRB->TRB_DESGRP .And. aVetDes[23] == TRB->TRB_DESATO ;
			 .and. aVetDes[29] == TRB->TRB_CRM ;
			 .and. IIF(nTpRel == 2,	aVetDes[11] == TRB->TRB_DATDES,.T.)}) ) == 0 //G7
			 AADD(aVetDes, {TRB->IDTAB, ; //[1] Tabela
			 TRB->TRB_REGATE, ;  //[2]  Registro de Atendimento
			 TRB->TRB_DESUNC, ;  //[3]  Descricao de Unidade de Consumo
			 TRB->TRB_DESGRP, ;  //[4]  Descri็ao do Grupo Despesas
			 cCodPro        , ;  //[5]  Codigo do Produto
			 cDesPro        , ;  //[6]  Descricao do Produto
			 TRB->TRB_UM    , ;  //[7]  Unidade de Medida
			 IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_QTDDES), ; //[8]  Quantidade
			 IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_VALDES),;  //[9]  Valor Unitario
			 IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_VALTOT),;  //[10] Valor Total
    TRB->TRB_DATDES, ;  //[11] Data da Despesa
			 TRB->TRB_HORDES, ;  //[12] Hora da Despesa 
    TRB->TRB_FABRIC, ;  //[13] Fabricante    
    TRB->TRB_TIPDES, ;  //[14] Tipo da Despesa 
    TRB->TRB_NRSEQG, ;  //[15] Nr Seq Guia 
    TRB->TRB_ORDITF, ;  //[16] Ordem Itens fatura
    TRB->TRB_CODGDE, ;  //[17] Cod Grp Despesa
    TRB->TRB_CODUNC, ;  //[18] Cod Unid Consumo  
		  IIF(TRB->TRB_PGTMED=="0", "D", "R"),;  //[19] Pagto Medico
		  TRB->TRB_NOMMED,;   //[20] Nome Medico
		  TRB->TRB_QTDCHP+TRB->TRB_VLRCOS,; //[21] Qtd Ch
		  TRB->TRB_COECHP,;   //[22] Valor Ch    
		  TRB->TRB_DESATO,;   //[23] Descricao do Ato
		  TRB->TRB_VFILME,;   //[24] Valor Filme
 		 TRB->TRB_METFIL,;   //[25] M2 Filme
 		 TRB->TRB_CODLOC, ;   //[26] Setor  
 		 TRB->TRB_DESVAL, ;   //[27] Valor Desconto    
    TRB->TRB_DESOBS,;    //[28] Motivo Desconto
  	 TRB->TRB_CRM})       //[29] Codigo CRM
		 Else
			 aVetDes[nPos,8]  += TRB->TRB_QTDDES
			 aVetDes[nPos,10] += IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_VALTOT)
			 If !Empty(TRB->TRB_DESVAL)
			 	aVetDes[nPos,27] += TRB->TRB_DESVAL
				EndIf
			EndIf
			If !Empty(aM2Film)
		  If aM2Film[1,1] > 0 
	    If (nPosRes := aScan(aVetRes, {|aVetRes| aVetRes[1] == "FILME"})) == 0
			   AADD(aVetRes, {"FILME", IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_QTDDES), IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, (TRB->TRB_VFILME * TRB->TRB_QTDDES))}) 
		   Else
	 	   aVetRes[nPosRes,2] += IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_QTDDES)
		   aVetRes[nPosRes,3] += IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_VFILME* TRB->TRB_QTDDES)
		   Endif
		  Endif 
	  Endif

			If TRB->TRB_TIPATM == "0"                                    // 23/08
		  AADD(aVetCir, {TRB->TRB_DOCCIR,; 																			 //[1]
		                 HS_DTOC(STOD(TRB->TRB_DATDES),1),;   //[2]
		                 TRB->TRB_HORDES,;                     //[3]
		                 HS_DTOC(STOD(TRB->TRB_DATFIM),1),;   //[4]
		                 TRB->TRB_HORFIM,;                     //[5]
		                 TRB->TRB_CODIGO,;                     //[6]
		                 TRB->TRB_DESC,;                       //[7]
		                 TRB->TRB_COEDES,;                     //[8]
		                 HS_INIPADR("SX5",1,"CA" + TRB->TRB_TPANES,"X5_DESCRI",,.F.)})  
		 Endif 

		Endif
		If TRB->IDTAB == "G7"
		  nFilm := 0
		 If !Empty(aM2Film)
		  If aM2Film[1,1] > 0 
		   nFilm := TRB->TRB_VFILME
		  Endif
		 Endif
		Else
		 nFilm := 0
		Endif   
		If (nPosRes := aScan(aVetRes, {|aVetRes| aVetRes[1] == TRB->TRB_DESGRP })) == 0
			AADD(aVetRes, {TRB->TRB_DESGRP, IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_QTDDES), IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_VALTOT - (nFilm*TRB->TRB_QTDDES))}) 
		Else
	 	aVetRes[nPosRes,2] += IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_QTDDES)
			aVetRes[nPosRes,3] += IIF(TRB->TRB_PGTMED == "0" .And. cRepDir $ "0/1", 0, TRB->TRB_VALTOT - nFilm*TRB->TRB_QTDDES)
		Endif
 	FS_MAXCTA(TRB->TRB_REGATE)
		DbSelectArea("TRB")
		DbSkip()
		
	EndDo
	
	DbCloseArea()
	 
	For nCont := 1 To Len(aVetDes)
				
		If nLin > nMaxLin .Or. aVetDes[nCont, 2] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 2]
			nLin := FS_CabIni(nLin, nCont)

	
			If nCont == 1 .And. lProcCir  // 23/08
			 If !Empty(aVetCir)
					@ nLin, 000 Psay Eval(bRepli)
  			nLin++                                        
			  nLin := FS_ATUCIRU(nLin)
  			nLin++                                        
			 Endif
			EndIf
		
	 	nLin := FS_CabGrup(nLin, nCont)
 	

		EndIf
		
		//Quebra do grupo de Unidade de Consumo
		If IIF(nCont > 1, aVetDes[nCont, 3] != aVetDes[nCont-1, 3], .T.)
			nLin++
			@ nLin, 000 PSAY aVetDes[nCont, 3]
			nLin += 2
		EndIf
		
		// Quebra do grupo de Despesas
		If IIF(nCont > 1, aVetDes[nCont, 4] != aVetDes[nCont-1, 4] .Or. aVetDes[nCont, 3] != aVetDes[nCont-1, 3], .T.)
			If nCont<> 1 .and. nCont <> Len(aVetDes)
			 nlin := FS_CabGrup(nLin, nCont)
			Endif 
			If nOrdIteFat == 2 //Emite por Data/hora = NAO 
		  If aVetDes[nCont, 16] == "0" //Codigo
 		  aSort(aVetDes,,,{|x,y| x[2] + x[15] + x[18] + x[17] + x[5] < y[2] + y[15] + y[18] + y[17] + y[5]}) //REGATE, NRSEQG, CODUNC, CODGDE, CODPRO
		  ElseIf aVetDes[nCont, 16] == "1" //Descricao
    	aSort(aVetDes,,,{|x,y| x[2] + x[15] + x[18] + x[17] + x[6] < y[2] + y[15] + y[18] + y[17] + y[6]}) //REGATE, NRSEQG, CODUNC, CODGDE, DESPRO	 
		  Else
		   If nTpRel == 1 //Sintetico
	     aSort(aVetDes,,,{|x,y| x[2] + x[15] + x[18] + x[17] + x[6] < y[2] + y[15] + y[18] + y[17] + y[6]})//REGATE, NRSEQG, CODUNC, CODGDE, DESPRO
	    Else
	     aSort(aVetDes,,,{|x,y| x[2] + x[15] + x[18] + x[17] + x[11] + x[12] < y[2] + y[15] + y[18] + y[17] + y[11] + y[12]})//REGATE, NRSEQG, CODUNC, CODGDE,DATDES, HORDES
	    Endif
	   Endif 
   ElseIf nOrdIteFat == 1              //Emite por Data/hora = SIM               //  23/08/07

		  If aVetDes[nCont, 16] == "0" //Codigo
 		  aSort(aVetDes,,,{|x,y| x[2] + x[15] + x[18] + x[17] + x[11] + x[5] < y[2] + y[15] + y[18] + y[17] + Y[11] + y[5]}) //REGATE, NRSEQG, CODUNC, CODGDE, DATDES, CODPRO
		  ElseIf aVetDes[nCont, 16] == "1" //Descricao
    	aSort(aVetDes,,,{|x,y| x[2] + x[15] + x[18] + x[17] + x[11] + x[6] < y[2] + y[15] + y[18] + y[17] + Y[11] + y[6]}) //REGATE, NRSEQG, CODUNC, CODGDE, DATDES, DESPRO	 
		  Else
		   If nTpRel == 1 //Sintetico
	     aSort(aVetDes,,,{|x,y| x[2] + x[15] + x[18] + x[17] + x[11] + x[6] < y[2] + y[15] + y[18] + y[17] + Y[11] + y[6]})//REGATE, NRSEQG, CODUNC, CODGDE, DATDES, DESPRO
	    Else
	     aSort(aVetDes,,,{|x,y| x[2] + x[15] + x[18] + x[17] + x[11] + x[12] < y[2] + y[15] + y[18] + y[17] + y[11] + y[12]})//REGATE, NRSEQG, CODUNC, CODGDE,DATDES, HORDES
	    Endif
	   Endif 
   
		 EndIf    
			@ nLin, 000 PSAY aVetDes[nCont, 4]
			nLin++
		EndIf  

		// Quebra da data da despesa
		If IIF(nCont > 1, aVetDes[nCont, 11] != aVetDes[nCont-1, 11] .and. aVetDes[nCont, 3] == aVetDes[nCont-1, 3], .T.) .and. ;
		   nTpRel == 2 .And. nOrdIteFat == 1 //Analitico E Por Data = SIM
			If nCont > 1
		 	nLin++
			Endif
		EndIf 

  If nTpRel == 1  .Or. nOrdIteFat == 2 //sintetico Ou Emite por Data = NAO
	  @ nLin, 000 PSAY SUBSTR(aVetDes[nCont, 5],1,IIF(lTamProd .or. aVetDes[nCont, 1] <> "G5" ,15,30)) //Codigo do Material   
	  @ nLin, IIF(lTamProd .or. aVetDes[nCont, 1] <> "G5",017,032) PSAY SUBSTR(aVetDes[nCont, 6],1,26) //Descri็ao do Produto 
	  If aVetDes[nCont, 1] == "G7"
	   @ nLin, 045 PSAY ALLTRIM(SUBSTR(aVetDes[nCont, 23],1,6)+IIF(EMPTY(aVetDes[nCont, 23]),"","-")+SUBSTR(aVetDes[nCont, 20],1,25)) // Ato-Nome Profissional
	  	@ nLin, 076 PSAY TRANSFORM(aVetDes[nCont, 12], "@E 99:99")
	  	@ nLin, 091 PSAY TRANSFORM(aVetDes[nCont, 21], "@E 99,999.99")  //Qtd. CH
			 @ nLin, 101 PSAY TRANSFORM (aVetDes[nCont, 22], "@E 999.999")  //Valor CH
			 @ nLin, 109 PSAY TRANSFORM(aVetDes[nCont, 8], "@E 999")   //Quantidade
	  	@ nLin, 116 PSAY TRANSFORM(aVetDes[nCont, 10], "@E 999,999,999.99")//Valor Total
			 @ nLin, 132 PSAY aVetDes[nCont, 19] // Pgto Medico
		  
		  aM2Film := FS_M2FILM(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA,aVetDes[nCont, 5], STOD(aVetDes[nCont, 11]),aVetDes[nCont, 25], aVetDes[nCont, 26])  
		  If !Empty(aM2Film)
		   If aM2Film[1,1] > 0 
		    nLin ++
		    @ nLin, 017 PSAY "Filme" + " " + TRANSFORM(aVetDes[nCont, 8], "@E 99,999.9999") + " x " + TRANSFORM(aM2Film[1,1], "@E 9.9999") +;
		    " x " + TRANSFORM(aM2Film[1,2], "@E 99.9999") + " = " + ALLTRIM(PADL(TRANSFORM(aVetDes[nCont, 8] * aVetDes[nCont, 24], "@E 99,999.9999"), 11))    
		   Endif
		  Endif 
		 Else
	   If nImpFab == 1  
	    If aVetDes[nCont, 1] == "G6"
	     @ nLin, 050 PSAY IIf(aVetDes[nCont, 14]== "2", "TX", "DI") // unidade medida
	    Else
	     @ nLin, 050 PSAY aVetDes[nCont, 7] // unidade medida
	    Endif 
	    @ nLin, 054 PSAY aVetDes[nCont, 13] //Fabricante 
	   Else
	    If aVetDes[nCont, 1] == "G6"
	     @ nLin, 076 PSAY IIf(aVetDes[nCont, 14]== "2", "TX", "DI") // unidade medida
	    Else
	     @ nLin, 076 PSAY aVetDes[nCont, 7] // unidade medida
	    Endif 
	   Endif
	   @ nLin, IIF(aVetDes[nCont, 1] == "G6", 089, 094) PSAY TRANSFORM(aVetDes[nCont, 8], IIF(aVetDes[nCont, 1] == "G7", "@E 999999", "@E 99,999.99")) //Quantidade
	  	@ nLin, 107 PSAY TRANSFORM(aVetDes[nCont, 9], "@E 999,999.99") //Vr. Unitario
			 @ nLin, 122 PSAY TRANSFORM(aVetDes[nCont, 10],"@E 999,999.99") //Valor Total
			Endif 
		Else // Analitico 
		 @ nLin, 000 PSAY Dtoc(Stod(aVetDes[nCont, 11])) //Data Despesa
		 @ nLin, 011 PSAY SUBSTR(aVetDes[nCont, 5],1,IIF(lTamProd .or. aVetDes[nCont, 1] <> "G5",15,30)) //Codigo do Material   
	  @ nLin, IIF(lTamProd .or. aVetDes[nCont, 1] <> "G5",022,41) PSAY SUBSTR(aVetDes[nCont, 6],1,26) //Descri็ao do Produto 
	  If aVetDes[nCont, 1] == "G7"
	   @ nLin,  045 PSAY ALLTRIM(SUBSTR(aVetDes[nCont, 23],1,6)+IIF(EMPTY(aVetDes[nCont, 23]),"","-")+SUBSTR(aVetDes[nCont, 20],1,23)) // Ato-Nome Profissional
	  	@ nLin, 076 PSAY TRANSFORM(aVetDes[nCont, 12], "@E 99:99")
	  	@ nLin, 091 PSAY TRANSFORM(aVetDes[nCont, 21], "@E 99,999.99")  //Qtd. CH
			 @ nLin, 101 PSAY TRANSFORM(aVetDes[nCont, 22], "@E 999.999")   //Valor CH
			 @ nLin, 109 PSAY TRANSFORM(aVetDes[nCont, 8], "@E 999")  //Quantidade
	  	@ nLin, 117 PSAY TRANSFORM(aVetDes[nCont, 10], "@E 999,999,999.99")//Valor Total
			 @ nLin, 132 PSAY aVetDes[nCont, 19] // Pgto Medico
		  aM2Film := FS_M2FILM(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA,aVetDes[nCont, 5], STOD(aVetDes[nCont, 11]),aVetDes[nCont, 25], aVetDes[nCont, 26])  
		  If !Empty(aM2Film)
		   If aM2Film[1,1] > 0 
		    nLin ++
		    @ nLin, 017 PSAY "Filme" + " - " + TRANSFORM(aVetDes[nCont, 8], "@E 99,999.9999") + " x " + TRANSFORM(aM2Film[1,1], "@E 9.9999") +;
		    " x " + TRANSFORM(aM2Film[1,2], "@E 99.9999") + " = " + ALLTRIM(PADL(TRANSFORM(aVetDes[nCont, 8] * aVetDes[nCont, 24], "@E 99,999.9999"), 11))    
		   Endif
		  Endif 
		 Else
	   If nImpFab == 1
	    If aVetDes[nCont, 1] == "G6"
	    	@ nLin, 061 PSAY IIf(aVetDes[nCont, 14]== "2", "TX", "DI") // unidade medida
	    Else
	    	@ nLin, 061 PSAY aVetDes[nCont, 7] // unidade medida
	    Endif 
	    	@ nLin, 065 PSAY aVetDes[nCont, 13] //Fabricante 
	   Else
	    If aVetDes[nCont, 1] == "G6"
	     @ nLin, 076 PSAY IIf(aVetDes[nCont, 14]== "2", "TX", "DI") // unidade medida
	    Else
	     @ nLin, 076 PSAY aVetDes[nCont, 7] // unidade medida
	    Endif 
	   Endif
	   @ nLin, IIF(aVetDes[nCont, 1] == "G6", 089, 094) PSAY TRANSFORM(aVetDes[nCont, 8], IIF(aVetDes[nCont, 1] == "G7", "@E 999999" ,"@E 99,999.9999" )) //Quantidade
	   @ nLin, 107 PSAY TRANSFORM(aVetDes[nCont, 9], "@E 999,999.99") //Vr. Unitario
       @ nLin, 122 PSAY TRANSFORM(aVetDes[nCont, 10],"@E 999,999.99") //Valor Total
			Endif 
		Endif
						
		nPosDesc := IIF(aVetDes[nCont, 1] == "G7", 27, 19) 				
	 If !Empty(aVetDes[nCont,nPosDesc])
		 nLin++ 
		 nValDesc := aVetDes[nCont,nPosDesc]  
		 nTotDsc  += nValDesc//Totalizador Geral do Desconto
		 @ nLin, IIF(aVetDes[nCont, 1] == "G7", 103, 100) PSAY STR0043 + PADL(TRANSFORM(nValDesc, "@E 999,999.99"), 10)//"Desc.: "
		Endif
		
		nPosDesc := IIF(aVetDes[nCont, 1] == "G7", 28, 20) 
   
  If !Empty(aVetDes[nCont,nPosDesc])
		 If Empty(aVetDes[nCont,nPosDesc - 1])
		  nLin ++
		 Endif
		 @ nLin, 000 PSAY STR0044 + SUBSTR(aVetDes[nCont,nPosDesc], 1, IIF(aVetDes[nCont, 1] == "G7", 90, 87)) //"Mot. Desc.: "
		Endif

		
		nTotDat	 := nTotDat  + Iif( aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", aVetDes[nCont, 10], 0)
		nGrpDesp := nGrpDesp + Iif( aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", aVetDes[nCont, 10], 0)
 	nUniCons := nUniCons + Iif( aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", aVetDes[nCont, 10], 0) 
		nTotGer  := nTotGer  + Iif( aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", aVetDes[nCont, 10], 0) 
		nLin++
		
			// Imprime o total da Data
		If (aVetDes[nCont, 11] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 11];
			.Or. aVetDes[nCont, 4] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 4];
			.Or. aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3];
			.Or. aVetDes[nCont, 2] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 2];
			.Or. nCont == Len(aVetDes))	.and. nTpRel == 2 .And. nOrdIteFat == 1 //Analitico E Por Data = SIM
			 
			 @ nLin, 088 PSAY STR0013 //"SubTotal da Data: "
			 @ nLin, 116 PSAY nTotDat PICTURE "@E 999,999,999.99"
			 nTotDat := 0
			 nLin++
		
		EndIf
		
		// Imprime o total do grupo de despesas
		If aVetDes[nCont, 4] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 4];
			.Or. aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3];
			.Or. aVetDes[nCont, 2] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 2];
			.Or. nCont == Len(aVetDes)
			
			@ nLin, 088 PSAY STR0014 //"SubTotal do Grp. Despesas: "
			@ nLin, 116 PSAY nGrpDesp PICTURE "@E 999,999,999.99"
 		nTotDat := 0
			nGrpDesp := 0
			nLin++
		EndIf
		
		//Imprime o total da unidade de consumo
		If aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3] ;
			.Or. aVetDes[nCont, 2] != aVetDes[IIF((nCont) == Len(aVetDes), nCont, nCont + 1), 2] ;
			.Or. nCont == Len(aVetDes)
			
			If aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3] .Or. nCont == Len(aVetDes)
			
				@ nLin, 088 PSAY STR0015 //"Total do Setor: "
				@ nLin, 116 PSAY nUniCons PICTURE "@E 999,999,999.99"
				nLin++
				nUniCons := 0
			EndIf 
			
			If nCont == Len(aVetDes)
			
				@ nLin, 088 PSAY STR0049//"Total Desconto: "
				@ nLin, 116 PSAY nTotDsc	PICTURE "@E 999,999,999.99"
    nTotDsc := 0
    nLin++
    
				@ nLin, 088 PSAY STR0016 //"Total Geral: "
				@ nLin, 116 PSAY nTotGer	PICTURE "@E 999,999,999.99"
				nTotGer := 0
				
			EndIf
			
			If aVetDes[nCont, 2] != aVetDes[IIF((nCont) == Len(aVetDes), nCont, nCont + 1), 2] .Or. nCont == Len(aVetDes)
			 
				FS_Resumo(nLin, nCont)
				nUniCons := 0
				nLin     := nMaxLin * 2 // Forca um salto de pagina
				
			EndIf
			
		EndIf
		
	Next

	aVetDes := {}
	
Next nForGui

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_R15Guiasบ Autor ณMario Arizono       บ Data ณ  10/08/06   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona as guias, de acordo com as informacoes dos parame_บฑฑ
ฑฑบ          ณ tros iniciais.                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FS_R15Guias(cRegAte, nModRel)

Local aArea  := GetArea()
Local aGuias := {}
Local cSQL   := ""

cSQL := "SELECT GCZ.GCZ_NRSEQG , GCZ.GCZ_REGATE "
cSQL += "FROM " + RetSQLName("GCZ") + " GCZ "
cSql += "JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
cSql += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 
cSQL += "WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
cSQL += "AND GCZ.GCZ_REGATE = '" + cRegAte + "' "
cSQL += "AND GCZ.GCZ_STATUS"

If nModRel == 2
	cSQL += " IN "
Else
	cSQL += " NOT IN "
EndIf

cSQL += "('0', '1') "
cSQL += "ORDER BY GCZ.GCZ_NRSEQG"

TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()
While !Eof()
	aAdd(aGuias, {QRY->GCZ_NRSEQG, QRY->GCZ_REGATE})
	DbSkip()
End

aSort(aGuias,,,{|x,y| x[2]+x[1] < y[2]+y[1]})
DbCloseArea()

RestArea(aArea)

Return(aGuias)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CabIni บ Autor ณMario Arizono       บ Data ณ  10/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta cabecalho principal.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RunReport                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CabIni (nLin, nContCab) 
	Local aArea := GetArea()					                    
 
 DbSelectArea("GCY")
 DbSetOrder(1)
 Dbseek(xFilial("GCY")+ aVetDes[nContCab, 2])
 
 If cRegger <> GCY->GCY_REGGER  .OR. cNrSeqg <> GCZ->GCZ_NRSEQG
  nPag := 1
 Else
  nPag ++
 EndIf   

 Cabec1  := "C.I.D.: "+ALLTRIM(IIF(Empty(GCY->GCY_CIDALT),GCY->GCY_CIDINT, GCY->GCY_CIDALT)) + "-" + ALLTRIM(HS_INIPADR("GAS", 1, IIF(Empty(GCY->GCY_CIDALT),GCY->GCY_CIDINT, GCY->GCY_CIDALT), "GAS_PATOLO")) + " / "+ALLTRIM(GCY->GCY_CIDCMP)
 Cabec1  := Cabec1 + Space(132 - (Len(Alltrim(Cabec1)) + Len(STR0017) + 4))  //"Folha do Paciente: "
 Cabec1  := Cabec1 + STR0017 + transform(nPag,"@E 99") //"Folha do Paciente: "
 Cabec2  := " "

 nLin:= Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,15)
 Titulo      := STR0004 //"Reinicializa com a STR padrao"

 nLin ++

 @ nLin,   00 psay STR0018 //"Convenio..........: "
 @ nLin,   20 psay HS_INIPADR("GA9", 1, GCZ->GCZ_CODCON, "GA9_NREDUZ")
 @ nLin,   40 psay SUBSTR(HS_INIPADR("GCM", 2, GCZ->GCZ_CODPLA, "GCM_DESPLA"), 1, 45)
 @ nLin,   87 psay STR0019 //"Periodo: "
 @ nLin,   96 psay Dtoc(GCZ->GCZ_DCPARI) + STR0020 + Dtoc(IIF(((EMPTY(GCY->GCY_DATALT).or.GCY->GCY_DATALT>GCZ->GCZ_DCPARF).AND.GCZ->GCZ_CTAPAR<>nMaxConta ), GCZ->GCZ_DCPARF, GCY->GCY_DATALT    )) 
 nLin++
 @ nLin,   00 psay STR0021 //"Nro Atendimento...: "
 @ nLin,   20 psay GCY->GCY_REGATE
 @ nLin,   32 psay STR0022 //"Nome    : "
 @ nLin,   42 psay SUBSTR(GCY->GCY_NOME,1,44)
 @ nLin,   87 psay STR0023  //"Data/Hora Atendimento: "
 @ nLin,  111 psay Dtoc(GCY->GCY_DATATE) + " - " + GCY->GCY_HORATE + " h"
 nLin++
 @ nLin,   00 psay STR0024 //"Nro Carteirinha...: "
 @ nLin,   20 psay HS_INIPADR("GD4", 1, GCY->GCY_REGGER + GCZ->GCZ_CODPLA,"GD4_MATRIC",,.F.)
 @ nLin,   59 psay "RGP: "
 @ nLin,   64 psay GCY->GCY_REGGER 
 @ nLin,   87 psay STR0025 //"Data/Hora Alta.......: "
 @ nLin,  111 psay Dtoc(GCY->GCY_DATALT) + " - " + GCY->GCY_HORALT + " h"
 nLin++
 @ nLin,   00 psay STR0026 //"Setor/Quarto/Leito: "
 @ nLin,   20 psay GCY->GCY_CODLOC + " / " + ALLTRIM(GCY->GCY_QUAINT) + " / " + ALLTRIM(GCY->GCY_LEIINT)
 @ nLin,   59 psay STR0048
 @ nLin,   70 psay ALLTRIM(GCZ->GCZ_NUMORC)
 @ nLin,   87 psay STR0027 //"Atendente.: "
 @ nLin,  101 psay ALLTRIM(GCY->GCY_ATENDE)
 nLin++
 @ nLin,   00 psay STR0028   //"Nr.Guia/Senha Aut.: "
 @ nLin,   20 psay ALLTRIM(GCZ->GCZ_NRGUIA) + "/" + ALLTRIM(GCZ->GCZ_NRSEN1)
 @ nLin,   87 psay STR0029   //"Num.Lote: "
 @ nLin,  112 psay ALLTRIM(GCZ->GCZ_NRLOTE )
 nLin++   

// nLin := FS_CabGrup(nLin, nContCab)
 cRegger := GCY->GCY_REGGER   
 cNrSeqg := GCZ->GCZ_NRSEQG
 RestArea(aArea)
Return (nLin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CabGrupบ Autor ณMario Arizono       บ Data ณ  10/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta cabecalho dos itens                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RunReport                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function	FS_CabGrup(nLin, nContCab)
Local cCabProc := ""

If aVetDes[nContCab, 1] = "G7" //Cabe็alho para Procedimento(Honorarios/Exames)
	If nTpRel == 1 .Or. nOrdIteFat == 2 //sintetico Ou Emite por Data = NAO
           	       	/*             1         2         3         4         5         6         7         8         9         10        11        12        13
          				           0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12 */
 	cCabProc:= STR0030  //"Cod Amb          Descricao                          Responsavel                       Hora           Qt Ch    Vl Ch  Qtd Valor Total"
	Else	      //Analitico
 	cCabProc:= STR0031  //"Data       Cod Amb          Descricao                      Responsavel                     Hora      Qt Ch    Vl Ch  Qtd Valor Total"
	EndIf                
ElseIf aVetDes[nContCab, 1] = "G5" //Cabe็alho para Materiais/Medicamentos
	If nImpFab == 1     //Imprime Descricao do Fabricante dos Produtos.
		If nTpRel == 1 .Or. nOrdIteFat == 2 //sintetico Ou Emite por Data = NAO
			cCabProc:= STR0032 //"Cod Mat          Descricao                        UM  Fabricante                          Quantidade       Valor Unit    Valor Total"
		Else	    //Analitico
			cCabProc:= STR0033 //"Data       Cod Mat          Descricao                        UM  Fabricante               Quantidade       Valor Unit    Valor Total"
		EndIf	
	Else
		If nTpRel == 1 .Or. nOrdIteFat == 2 //sintetico Ou Emite por Data = NAO
			cCabProc:= STR0034 //"Cod Mat          Descricao                                                  UM            Quantidade       Valor Unit    Valor Total"
		Else	    //Analitico
			cCabProc:= STR0035 //"Data       Cod Mat          Descricao                                       UM            Quantidade       Valor Unit    Valor Total"
		EndIf
	EndIf	
Else
 If nImpFab == 1     //Imprime Descricao do Fabricante dos Produtos.
		If nTpRel == 1 .Or. nOrdIteFat == 2 //sintetico Ou Emite por Data = NAO
			cCabProc:= STR0036 //"Cod Tax          Descricao                        UM  Fabricante                          Quantidade       Valor Unit    Valor Total"
		Else	  //Analitico
			cCabProc:= STR0037 //"Data       Cod Tax          Descricao                        UM  Fabricante               Quantidade       Valor Unit    Valor Total"
		EndIf	
	Else
		If nTpRel == 1 .Or. nOrdIteFat == 2 //sintetico Ou Emite por Data = NAO
			cCabProc:= STR0038 //"Cod Tax          Descricao                                                  UM            Quantidade       Valor Unit    Valor Total"
		Else	    //Analitico
			cCabProc:= STR0039 //"Data       Cod Tax          Descricao                                       UM            Quantidade       Valor Unit    Valor Total"
		EndIf
	EndIf
EndIf

If nLin > nMaxLin                                                                                     
	FS_CabIni (nLin, nContCab) 
Else
 @ nLin,   00 psay cCab_
 nLin++  
 @ nLin,   00 psay cCabProc 
 nLin++  
 @ nLin,   00 psay cCab_  
 nLin++  
EndIf 
Return (nLin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Resumo บ Autor ณMario Arizono       บ Data ณ  10/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime Resumo                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RunReport                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_Resumo(nlin,nConTab)
Local nForGrp := 0, nTotAten := 0
If nLin+Len(aVetRes) > nMaxLin
	nLin := FS_CabIni(nLin, nConTab)
EndIf

nLin++
@nLin, 13 psay STR0041    //"GRUPO                                 QUANT          VALOR"
nLin++ 
               
                       

@nLin,   13 psay Repl("-",Len(STR0041)) //"GRUPO                                 QUANT          VALOR"
                  
For nForGrp := 1 To Len(aVetRes)
 nLIn++   	
 @nLin, 11 psay SubStr(aVetRes[nForGrp,1], 1, 30)
 @nLin, 44 psay transform(aVetRes[nForGrp,2],"@E 999,999,999.99")
 @nLin, 59 psay transform(aVetRes[nForGrp,3],"@E 999,999,999.99")
 
 nTotAten += aVetRes[nForGrp,3]
Next

nLin++
@nLin, 13 psay Repl("-",Len(STR0041)) //"GRUPO                                 QUANT          VALOR"
nLin++

@nLin, 13 psay STR0040      //"Total da Conta:"
@nLin, 59 psay transform(nTotAten,"@E 999,999,999.99") 
aVetRes := {}
Return (nil)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_M2FILM บ Autor ณMario Arizono       บ Data ณ  01/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula m2 filme.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RunReport                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_M2FILM(cCodCon, cCodPla, cCodDes, dDatVig, nM2Film, cCodLoc)
 
 Local vVM2FRX  := ""
 Local aArea    := GetArea()
 Local aTabPre  := {}, aVlFilm := {}
 Local aRVldVig := {{0, "GA8_METFIL"}}
 Local cCodTab  := "" 
 
 aTabPre := HS_RTabPre("GC6", cCodPla, cCodDes, dDatVig)
 vVM2FRX := HS_RCfgCP(cCodCon, cCodPla, "_VM2FRX", dDatVig, cCodLoc) 
 cCodTab := IIF(!Empty(aTabPre), aTabPre[1], space(len(GC6->GC6_TABPRO)))

 If HS_VldVig("GA8", "GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8_TABPRO = '" + cCodTab + "' AND GA8_CODPRO = '" + cCodDes + "'", "GA8_DATVIG", @aRVldVig, dDatVig)
  AADD(aVlFilm,{IIf(aRVldVig[1][1] > 0, aRVldVig[1][1], nM2Film), vVM2FRX }) 
	Else
	 AADD(aVlFilm,{0,0})
	EndIf

 RestArea(aArea)            
Return(aVlFilm) 




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUCIR บ Autor ณMario Arizono       บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime o detalhamento da cirurgia.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RunReport                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_ATUCIRU(nLin)

 Local aArea := GetArea()
 Local nPos  := 0

 nLin++
 	                 /*  			   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
             	     0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
	@ nLin, 000 PSAY STR0042 //"Documento   Inicio Cirurgia  Fim Cirurgia   Cod. Procedimento  Descricao                       Via    Anestesia "
	nLin++
	
 For nPos := 1 to len(aVetCir)

		@ nLin, 000 PSAY SUBSTR(aVetCir[nPos, 1],1,10)
		@ nLin, 012 PSAY aVetCir[nPos, 2]+ " " + aVetCir[nPos, 3]
		@ nLin, 029 PSAY aVetCir[nPos, 4]+ " " + aVetCir[nPos, 5]
		@ nLin, 044 PSAY SUBSTR(aVetCir[nPos, 6],1,15)
		@ nLin, 063 PSAY SUBSTR(aVetCir[nPos, 7],1,30)
		@ nLin, 095 PSAY ALLTRIM(TRANSFORM(aVetCir[nPos, 8], "@E 99.99"))
  @ nLin, 102 PSAY SUBSTR(aVetCir[nPos, 9],1,30)
		nLin++
	Next nPos

RestArea(aArea)

Return(nLin) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR15  บAutor  ณSaude               บ Data ณ  03/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para Verificar qual maior Conta Parcial              บฑฑ
ฑฑบ          ณPara Filtrar na Exibi็ใo do Campo Data Parcial Final        บฑฑ
ฑฑบ          ณDe acordo com a Data da Ultima Gera็ใo e Data Alta Pacient. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Relatorios Capa Fatura,Contas Previas,Descritivos          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function FS_MAXCTA(cRegate)
 Local aArea := GetArea() 
 Local cSQL1:=""
 
 cSQL1 := "SELECT MAX (GCZ.GCZ_CTAPAR) MAXCTAPAR "
 cSQL1 += "FROM " + RetSQLName("GCZ") + " GCZ "
 cSQL1 += "WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL1 += "AND GCZ.GCZ_REGATE = '" + cRegate + "' "
 TCQUERY cSQL1 NEW ALIAS "QRYMAX"
 
 DbSelectArea("QRYMAX")
 QRYMAX->(DbGoTop())
 
 nMaxConta:=QRYMAX->MAXCTAPAR 
   
 QRYMAX->(DbCloseArea())  
 
 RestArea(aArea)
Return(nMaxConta)
