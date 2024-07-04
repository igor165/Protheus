#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"
#include "Totvs.ch"

// ###############################################################################################
// Projeto: 
// Fonte  : VAMNTP02.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  15/03/22|  Manoel Filho                      | Apuração de Preços de Compra de Combustiveis  
// ---------+------------------------------------+------------------------------------------------
User Function VAMNTP02()

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
Local nRecSD1   := 0
Local nAcres    := GetMv("VA_ACCMBI",,0.20) // Valor do Acescimo no preço do litro Combustivel do Prestadores de Serviço

DbSelectArea("ZAU")

If Select("TMPTQN") > 0
	TMPTQN->(dbCloseArea())
EndIf

cQuery := "SELECT DISTINCT TQN.TQN_CODCOM, TQI.TQI_PRODUT "
cQuery += " FROM "+RetSqlName("TQN")+" TQN "
cQuery += " JOIN "+RetSqlName("ST9")+" ST9 ON ST9.T9_FILIAL = '"+xFilial("ST9")+"' AND TQN.TQN_FROTA = ST9.T9_CODBEM "
cQuery += "  AND ST9.D_E_L_E_T_ = ' ' AND ST9.T9_PROPRIE = '2' AND ST9.T9_XTPTER = '1' "
cQuery += " JOIN "+RetSqlName("TQI")+" TQI ON TQI.TQI_FILIAL = '"+xFilial("TQI")+"' AND TQN.TQN_CODCOM = TQI.TQI_CODCOM "
cQuery += "  AND TQI.D_E_L_E_T_ = ' ' "
cQuery += " WHERE TQN.D_E_L_E_T_ = ' ' AND TQN.TQN_DTABAS BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' "
DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPTQN", .f., .f.)

oProcTTP:IncRegua1("Apuração de Preços de Compra de Combustiveis  ..")
oProcTTP:SetRegua2(1000)

Begin Transaction

While !TMPTQN->(Eof())

	oProcTTP:IncRegua2()

	cQuery := "SELECT R_E_C_N_O_, D1_DTDIGIT, D1_COD, D1_VUNIT "
	cQuery += " FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D1_COD = '"+TMPTQN->TQI_PRODUT+"'"
	cQuery += "  AND SD1.D_E_L_E_T_ = ' ' AND SD1.D1_DTDIGIT BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"' "
	cQuery += " ORDER BY 2,1 DESC "

	nRecSD1 := FM_Sql(cQuery)

	If nRecSD1 > 0
		SD1->(DbGoto(nRecSD1))
		lProcess := .t.
		DbSelectArea("ZAU")
		If !DbSeek(xFilial("ZAU")+TMPTQN->TQN_CODCOM+Dtos(SD1->D1_DTDIGIT))
			RecLock("ZAU",!Found())
			ZAU->ZAU_FILIAL := xFilial("ZAU")
			ZAU->ZAU_CODCOM := TMPTQN->TQN_CODCOM
			ZAU->ZAU_PRODUT := TMPTQN->TQI_PRODUT
			ZAU->ZAU_DATCPA := SD1->D1_DTDIGIT
			ZAU->ZAU_DOC    := SD1->D1_DOC
			ZAU->ZAU_SERIE  := SD1->D1_SERIE
			ZAU->ZAU_FORNEC := SD1->D1_FORNECE
			ZAU->ZAU_LOJA   := SD1->D1_LOJA
			ZAU->ZAU_VALUNI := SD1->D1_VUNIT
			ZAU->ZAU_VALACR := nAcres
			ZAU->ZAU_VALCOM := SD1->D1_VUNIT + nAcres
			MsUnlock()
		Endif
	Endif

	TMPTQN->(DbSkip())

Enddo
TMPTQN->(dbCloseArea())

End Transaction

If lProcess
	MsgInfo("Apuração de Preços de Compra de Combustiveis ocorrida com sucesso!","Atenção")
Else
	MsgInfo("Não foram encontrados registros de compra no periodo informado!","Atenção")
Endif

Return
