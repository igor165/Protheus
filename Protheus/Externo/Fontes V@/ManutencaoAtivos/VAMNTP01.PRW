#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"
#include "Totvs.ch"

// ###############################################################################################
// Projeto: 
// Fonte  : VAMNTP01.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  22/02/22|  Manoel Filho                      | Reprocessamento dos Abastecimento de Veiculos  
//          |                                    |  de Terceiros
// ---------+------------------------------------+------------------------------------------------
User Function VAMNTP01()

Local aParamBox := {}
Local aRet      := {}
Local dDatCorte := GetMv("VA_RECCMB",,cTod("01/01/2021")) // Data de Minima para Recálculo de Abastecimentos
Private dDatIni := cTod("")
Private dDatFin := cTod("")

aAdd(aParamBox,{1,"Data Inicial",Ctod(""),"@D","","","",50,.f.})
aAdd(aParamBox,{1,"Data Final",Ctod(""),"@D","","","",50,.f.})

While .t.
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.F.)
		dDatIni  := aRet[1]
		dDatFin  := aRet[2]
	Else
		Return
	EndIf

	If Empty(dDatIni) .or. Empty(dDatFin) .or. (dDatFin<dDatIni)
		MsgStop("Data(s) Inválida(s)! Favor informar corretamente!")
		Loop
	Endif

	If (dDatIni<dDatCorte)
		MsgStop("Data Inicial MENOR que a Data de Corte informada no parâmetro VA_RECCMB! Favor informar corretamente!")
		Loop
	Endif

	Exit
Enddo

oProcTTP := MsNewProcess():New({ |lEnd| FS_Proc01() }," ","",.f.)
oProcTTP:Activate()

Return


Static Function FS_Proc01()
Local lProcess  := .f.
Local nValComb  := 0
Local lCombZERO := .f.

//cQuery := "SELECT ZAT.ZAT_VALCOM, TQN.R_E_C_N_O_ AS RECTQN, ST9.T9_FORNECE, ST9.T9_LOJA "
//cQuery += "  FROM "+RetSqlName("TQN")+" TQN "
//cQuery += "  JOIN "+RetSqlName('ST9')+" ST9 ON ( ST9.T9_FILIAL = '"+xFilial("ST9")+ "' "
//cQuery += "      AND ST9.T9_CODBEM = TQN.TQN_FROTA AND ST9.T9_PROPRIE = '2' AND ST9.D_E_L_E_T_ = ' ' )"
//cQuery += "  JOIN "+RetSqlName("ZAT")+" ZAT ON ( ZAT.ZAT_FILIAL= '"+xFilial("ZAT")+ "' "
//cQuery += "      AND ZAT.ZAT_CODCOM = TQN.TQN_CODCOM "
//cQuery += "      AND ZAT.ZAT_DATCAD <= TQN.TQN_DTABAS AND ZAT.D_E_L_E_T_ = ' ' )"
//cQuery += " WHERE TQN.TQN_FILIAL='"+xFilial("TQN")+"' AND TQN.TQN_TITABA = '  '"
//cQuery += "      AND TQN.TQN_DTABAS BETWEEN '"+Dtos(dDatIni)+"' AND '"+dTos(dDatFin) +"' AND TQN.D_E_L_E_T_ = ' '"
//DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPTQN", .f., .f.)
//cQuery := "WITH VALOR  AS ( "
//cQuery += "SELECT ZAT_DATCAD, ZAT_VALCOM, ZAT_CODCOM "
//cQuery += "FROM "+RetSqlName("ZAT")+"  ZAT "
//cQuery += "WHERE ZAT.D_E_L_E_T_ = ' ' ) , ABASTECIMENTO AS ( "
//cQuery += "SELECT TQN.* "
//cQuery += "FROM "+RetSqlName("TQN")+" TQN "
//cQuery += "JOIN "+RetSqlName("ST9")+" ST9 "
//cQuery += "ON TQN_FILIAL = T9_FILIAL "
//cQuery += "AND TQN_FROTA = T9_CODBEM "
//cQuery += "AND ST9.D_E_L_E_T_ = ' ' "
//cQuery += "AND T9_PROPRIE = '2' "
//cQuery += "WHERE TQN.D_E_L_E_T_ = ' ' ) "
//cQuery += "SELECT  V.ZAT_VALCOM, A.R_E_C_N_O_ AS RECTQN, ST9.T9_FORNECE,ST9.T9_LOJA "
//cQuery += "FROM ABASTECIMENTO A "
//cQuery += "JOIN VALOR V ON "
//cQuery += "V.ZAT_CODCOM = A.TQN_CODCOM "
//cQuery += "AND V.ZAT_DATCAD <= TQN_DTABAS "
//cQuery += "LEFT JOIN "+RetSqlName("ST9")+" ST9 ON "
//cQuery += "T9_CODBEM = TQN_FROTA "
//cQuery += "AND ST9.D_E_L_E_T_ = ' ' "
//cQuery += "WHERE TQN_DTABAS BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' "
//DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPTQN", .f., .f.)

If Select("TMPTQN") > 0
	TMPTQN->(dbCloseArea())
EndIf

cQuery := "SELECT TQN.TQN_DTABAS, TQN.TQN_CODCOM, TQN.R_E_C_N_O_  AS RECTQN, ST9.T9_FORNECE, ST9.T9_LOJA "
cQuery += " FROM "+RetSqlName("TQN")+" TQN " 
cQuery += " JOIN "+RetSqlName("ST9")+" ST9 ON TQN.TQN_FILIAL = ST9.T9_FILIAL AND TQN.TQN_FROTA = ST9.T9_CODBEM "
cQuery += "  AND ST9.D_E_L_E_T_ = ' ' AND ST9.T9_PROPRIE = '2'
cQuery += "  WHERE TQN.D_E_L_E_T_ = ' ' AND TQN.TQN_DTABAS BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' "
DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPTQN", .f., .f.)

Begin Transaction

oProcTTP:IncRegua1("Reprocessando abastecimentos..")
oProcTTP:SetRegua2(1000)

While !TMPTQN->(Eof())

	oProcTTP:IncRegua2()

	cQuery := "SELECT ZAT.ZAT_VALCOM FROM "+RetSqlName("ZAT")+" ZAT WHERE ZAT.D_E_L_E_T_ = ' ' AND ZAT.ZAT_CODCOM = '"+TMPTQN->(TQN_CODCOM)+"' AND ZAT.ZAT_DATCAD = (SELECT Max(ZAT_DATCAD) FROM "+RetSqlName("ZAT")+" WHERE D_E_L_E_T_ = ' ' AND ZAT_DATCAD <= '"+TMPTQN->(TQN_DTABAS)+"' AND ZAT.ZAT_CODCOM = '"+TMPTQN->(TQN_CODCOM)+"')"
	nValComb := FM_Sql(cQuery)

	If nValComb > 0
		TQN->(DbGoto(TMPTQN->(RECTQN)))
		RecLock("TQN", .f.)
		TQN->TQN_VUNABA := nValComb
		TQN->TQN_VTTABA := TQN->TQN_VUNABA * TQN->TQN_QUANT
		If Empty(TQN->TQN_FORST9)
			TQN->TQN_FORST9 := TMPTQN->(T9_FORNECE)
			TQN->TQN_LOJST9 := TMPTQN->(T9_LOJA)
		Endif
		MsUnlock()
		lProcess := .t.
	Else
		lCombZERO := .t.
	Endif
		
	TMPTQN->(DbSkip())

Enddo

End Transaction

If lProcess
	MsgInfo("Reprocessamento realizado com sucesso!!!"+IIf(lCombZERO,CRLF+CRLF+"Porém alguns abastecimentos não foram reprocessados por não haver Preço do Combustivel vigente na data do evento!",""), "Atenção")
Else
	MsgInfo("Não houve reprocessamento porque não há dados a serem processados ou não há preço de combustivel vigente nesta data!!!", "Atenção")
Endif

Return
