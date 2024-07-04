#include "PROTHEUS.CH"
#include "HSPAHRA2.CH"
#include "TOPCONN.CH"

/*
#define STR0001 "Este programa tem como objetivo imprimir relatorio "
#define STR0002 "de Saldos de emprestimos por Hospital de acordo com os parametros informados pelo usuario."
#define STR0003 "Saldos de emprestimos x Hospital"
#define STR0004 "Zebrado"
#define STR0005 "Estoque"
#define STR0006 "*** CANCELADO PELO OPERADOR ***"
#define STR0007 "                                                                           Q  u  a  n  t  i  d  a  d  e         "
#define STR0008 "  Codigo            Descricao do Produto                             Emprestada     Devolvida        Saldo      "
#define STR0009 "Hospital: "
#define STR0010 "Tipo de Emprestimo: "
#define STR0011 "ATENCAO!"
#define STR0012 "Nao ha dados para impressao."
#define STR0013 "ENTRADAS"
#define STR0014 "SAIDAS"
*/

//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         
//                                                                                                    1                                                                                                   2                   
//****************************************************************************************************************
//                                                                           Q  u  a  n  t  i  d  a  d  e         
//  Codigo            Descricao do Produto                             Emprestada     Devolvida        Saldo      
//****************************************************************************************************************

// Hospital: 123456789012345678901234567890123456789012345   								 Tipo de Emprestimo: ENTRADAS

//  123456789012345   123456789012345678901234567890123456789012345   999,999.9999   999,999.9999   999,999.9999  
//  123456789012345   123456789012345678901234567890123456789012345   999,999.9999   999,999.9999   999,999.9999  
//  123456789012345   123456789012345678901234567890123456789012345   999,999.9999   999,999.9999   999,999.9999  

// Hospital: 123456789012345678901234567890123456789012345   								 Tipo de Emprestimo: ENTRADAS

//  123456789012345   123456789012345678901234567890123456789012345   999,999.9999   999,999.9999   999,999.9999  
//  123456789012345   123456789012345678901234567890123456789012345   999,999.9999   999,999.9999   999,999.9999  
//  123456789012345   123456789012345678901234567890123456789012345   999,999.9999   999,999.9999   999,999.9999  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRA2  บAutor  ณAntonio Marco       บ Data ณ  01/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSaldos de emprestimos do hospital (recebidos e enviados)    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao Hospitalar                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHRA2()
Local Titulo     := STR0003 //"Saldos de emprestimos x Hospital"
Local cDesc1     := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2     := STR0002 //"de Saldos de emprestimos por Hospital de acordo com os parametros informados pelo usuario."
Local cDesc3     := ""
Local aOrd       := {}

Local Cabec1     := "" 
Local Cabec2     := "" 
Local nLin       := 80

Private NomeRel  := "HSPAHRA2" // Coloque aqui o nome do programa para impressao no cabecalho
Private cPerg    := "HSPRA2"
Private Tamanho  := "M"
Private Limite   := 132        // 80/132/220 

Private aReturn  := {STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Estoque"
Private nFormato := 18

Private nLastKey := 0

Private m_pag    := 1

Private wnrel    := "HSPAHRA2" // Coloque aqui o nome do arquivo usado para impressao em disco
  
Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

// auxiliares
Private cHospI
Private cHospF
Private nTipEmp
Private cSql
Private lTamProd := IIf((TamSx3("GFH_PROEMP")[1])<=15, .T., .F.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ PARAMETROS                                                             ณ
//ณ MV_PAR01 : Do Hospital ?                                               ณ
//ณ MV_PAR02 : Ao Hospital ?                                               ณ
//ณ MV_PAR03 : Tipos de Emprestimo ? 1 - Entradas / 2 - Saidas / 3 - Ambos ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Cabec2     := IIf(lTamProd,STR0008,STR0016)//"  Codigo            Descricao do Produto                             Emprestada     Devolvida        Saldo      "
Cabec1     := IIf(lTamProd,STR0007,STR0017)//"                                                                           Q  u  a  n  t  i  d  a  d  e         "

If !Pergunte(cPerg, .T.)
Return()
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2                      

wnrel := SetPrint("", NomeRel, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn, "")

If nLastKey == 27
   Return
Endif

// formato(orientacao) do relatorio (Retrato / Paisagem)
nFormato := If(aReturn[4] == 1, 15, 18)

// query p/ selecao dos dados
cHospI  := MV_PAR01 //Do Hospital ?
cHospF  := MV_PAR02 //Ao Hospital ?
nTipEmp := MV_PAR03 //Tipos de Emprestimo ? 1 - Entradas / 2 - Saidas / 3 - Ambos

cSql := "SELECT "
cSql +=  "GFG.GFG_TIPEMP GFG_TIPEMP, GFF.GFF_NOMHOS GFF_NOMHOS, GFG.GFG_DATEMP GFG_DATEMP, "
cSql +=  "GFH.GFH_PROEMP GFH_PROEMP, SB1.B1_DESC B1_DESC, SUM(GFH.GFH_QTDEMP) QTDEMP, SUM(GFH.GFH_QTDRET) QTDRET, SUM(GFH.GFH_SLDEMP) SLDEMP "
cSql += "FROM " + RetSQLName("GFG") + " GFG "
	cSql += "JOIN " + RetSQLName("GFF") + " GFF ON GFF.GFF_CODHOS = GFG.GFG_CODHOS AND GFF.D_E_L_E_T_ <> '*' AND GFF.GFF_FILIAL = '" + xFilial("GFF") + "' "
cSql += "JOIN " + RetSQLName("GFH") + " GFH ON GFH.GFH_SEQEMP = GFG.GFG_SEQEMP AND GFH.D_E_L_E_T_ <> '*' AND GFH.GFH_FILIAL = '" + xFilial("GFH") + "' "
cSql += "JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GFH.GFH_PROEMP AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cSql += "WHERE "
cSql +=  "GFG.GFG_FILIAL = '" + xFilial("GFG") + "' AND "
if nTipEmp < 3
	cSql += "GFG.GFG_TIPEMP = '" + STR(nTipEmp - 1, 1) + "' AND "
Endif
cSql +=  "GFG.GFG_CODHOS BETWEEN '" + cHospI + "' AND '" + cHospF + "' AND "
cSql +=  "GFG.D_E_L_E_T_ <> '*' "
cSql += "GROUP BY "
cSql +=  "GFG.GFG_TIPEMP, GFF.GFF_NOMHOS, GFG.GFG_DATEMP, GFH.GFH_PROEMP, SB1.B1_DESC "
cSql += "ORDER BY "
cSql +=  "GFF.GFF_NOMHOS, GFG.GFG_TIPEMP, SB1.B1_DESC"

TCQUERY cSql NEW ALIAS "QRY"
dbSelectArea("QRY")
dbGoTop()

if !Eof()
	RptStatus({|| FS_RA2(Titulo, Cabec1, Cabec2, nLin)})
Else
	HS_MsgInf(STR0012, STR0011, STR0015) //"Nao ha dados para impressao."###"Aten็ใo"###"Verifique a sele็ใo"
Endif

dbCloseArea()

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RA2    บAutor  ณAntonio Marco       บ Data ณ  03/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao Hospitalar                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_RA2(Titulo, Cabec1, Cabec2, nLin)
Local cNomHos
Local cTipEmp
Local aTipEmp := {STR0013, STR0014}

SetRegua(QRY->(RecCount()))

While !Eof()
	If nLin > nMaxLin
		nLin 			:= Cabec(Titulo, Cabec1, Cabec2, NomeRel, Tamanho, nFormato)
		cNomHos := '*'
		cTipEmp := '*'       
	Endif

	If LastKey() == 27 .OR. nLastKey == 27
		@ nLin,000 PSAY STR0006 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	// quebra
	If QRY->GFF_NOMHOS != cNomHos .OR. QRY->GFG_TIPEMP != cTipEmp
		@ ++nLin,001 PSAY STR0009 + QRY->GFF_NOMHOS
		@ nLin++,067 PSAY STR0010 + aTipEmp[Val(QRY->GFG_TIPEMP) + 1]
		cNomHos := QRY->GFF_NOMHOS                         
		cTipEmp := QRY->GFG_TIPEMP
	Endif

	@ nLin,002 PSAY QRY->GFH_PROEMP
	@ nLin,IIf(lTamProd,020,035) PSAY QRY->B1_DESC
	@ nLin,IIf(lTamProd,068,083)  PSAY QRY->QTDEMP PICTURE "@E 999,999.9999"
	@ nLin,IIf(lTamProd,083,098) PSAY QRY->QTDRET PICTURE "@E 999,999.9999"
	@ nLin,IIf(lTamProd,098,113) PSAY QRY->SLDEMP PICTURE "@E 999,999.9999"

	nLin++

	IncRegua()
 DbSkip()
Enddo

If aReturn[5] == 1
	dbCommitAll()
	Set Printer To
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(Nil)
