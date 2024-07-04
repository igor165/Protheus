//////////////////
// versao 0035  //
//////////////////

#include "tbiconn.ch"
#include "PROTHEUS.CH"
#include "OFINJD12.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFINJD12 ³ Autor ³ Manoel Filho ³                      Data ³ 27/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantamento dos Niveis de Atendimento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFINJD12(aParam, lSoGer)

Local nCont
Local cQuery      := ""
Local cFilBkp
Local aFilAtu
Local nRep := 1
//
Private lAuto := valtype(aParam) != "U" //Chamada Automatica
//
Private cSQLPedNF 	 := "SQLPNF"
Private cSQLSD2Abe 	 := "SQLD2A"
Private cSQLVdaPer 	 := "SQLVDP"
Private cSQLTransf 	 := "SQLVDP"
Private cSQLVS3O     := "SQLVS3O"
Private oLogger      := nil
Private oSqlHlp      := DMS_SqlHelper():New()
Private cTblLogCod   := ""
Private cTipDemand // situacoes que não serão consideradas na demanda
//
Private cTiposDem := ""
Private cTiposEsp := ""
Private cTiposRec := ""
Private oDemDpm
//
if lSoGer
	lAuto := .T.
Else
	If lAuto //Chamada Automatica
		cEmpr   := aParam[1]
		cFil    := aParam[2]
		nModulo := 14
		cModulo := "OFI"
		__cInternet := 'AUTOMATICO'
		If Type("cArqTab")=="U"
			cArqTab:=""
		EndIf
		cFOPENed := ""
		dDataBase:= Date()
		DbCloseAll()
		Prepare Environment Empresa cEmpr Filial cFil Modulo "OFI"
		conout("OFINJD12 via scheduler")
	else
		conout("OFINJD12 via menu")
	Endif
EndIf
Private oDpePecas  := DMSB_DpePecas():New()
Private oDs        := DMSB_DirectShipment():New()
Private cDadosProd := GetNewPar("MV_MIL0054","SBZ")
oDemDpm := DMS_DemandaDPM():New()
oLogger := DMS_Logger():New("OFINJD12.LOG")
If lAuto
	oLogger:Log({'TIMESTAMP', "OFINJD12 rodado em modo agendado data: " + DTOS(dDatabase) + "("+time()+")"})
	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD12'        },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'    },;
		{'VQL_DADOS'      , 'MODO: Agendado'  } ;
	})
Else
	oLogger:Log({'TIMESTAMP', "OFINJD12 rodado em modo   normal data: " + DTOS(dDatabase) + "("+time()+")"})
	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD12'      },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'  },;
		{'VQL_DADOS'      , 'MODO: Normal'  } ;
	})
EndIf

if oSqlHlp:ExistTable('VB8')
	if lAuto
		conout(STR0006) /*"OFINJD12 não deve ser rodado após criação da tabela VB8"*/
	else
		alert(STR0006) /*"OFINJD12 não deve ser rodado após criação da tabela VB8"*/
	endif
	return .t.
endif


aFilAtu   := FWArrFilAtu()
cFilBkp   := cFilAnt

nD2TOTIMP := SD2->(FieldPos("D2_TOTIMP"))
nBZPRIENT := SBZ->(FieldPos("BZ_PRIENT"))
nVQ3PROCES:= VQ3->(FieldPos("VQ3_PROCES"))
nBZULTVDA := SBZ->(FieldPos("BZ_ULTVDA"))
nVQ3VDAI  := VQ3->(FieldPos("VQ3_VDAI"))
nB5ULTVDA := SB5->(FieldPos("B5_ULTVDA"))

DBSelectArea("SB5")
DBSetOrder(1)
DBSelectArea("SF1")
DBSetOrder(1)
DBSelectArea("SD1")
DBSetOrder(3)
DBGoTop()

DBSelectArea("VQ3")
DBSetOrder(1)
//
DBSelectArea("SB1")
DBSetOrder(7)
//
DBSelectArea("SF2")
DBSetOrder(1)
//
DBSelectArea("VS3")
DBSetOrder(1)
//
aFilis := {}
aFilis2 := {}
//
DBSelectArea("SX6")
DBSetOrder(1)
DBGoTop()
while !eof()
	if Alltrim(SX6->X6_VAR) == "MV_MIL0005"
		aAdd(aFilis  ,{SX6->X6_FIL, SX6->X6_CONTEUD,Right(Alltrim(SX6->X6_FIL),2)})
		aAdd(aFilis2 ,{SX6->X6_FIL, SX6->X6_CONTEUD,Right(Alltrim(SX6->X6_FIL),2)})
	endif
	DBSkip()
enddo
//
For nCont := 1 to Len(aFilis)

	cFilAnt := aFilis[nCont,1]
	cDadosProd := GetNewPar("MV_MIL0054","SBZ")

	if Alltrim(cDadosProd) == "SBZ"
		// ==============================================
		// CRIA SBZ PARA TODOS OS SB1
		// ==============================================
		cSQLDTADD := GetNextAlias()
		cQuery := "SELECT B1_COD FROM " + RetSQLName("SB1")
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND B1_TIPO = 'ME' AND B1_FILIAL = '"+xFilial("SB1")+"' AND"
		cQuery += " B1_COD NOT IN ( SELECT BZ_COD FROM " + RetSQLName("SBZ") + " WHERE BZ_FILIAL = '"+xFilial("SBZ")+"' AND D_E_L_E_T_ = ' ' ) "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLDTADD , .F. , .T. )
		DBSelectArea("SBZ")
		While !(cSQLDTADD)->(Eof())
			reclock("SBZ",.t.)
			SBZ->BZ_FILIAL := xFilial("SBZ")
			SBZ->BZ_COD := (cSQLDTADD)->(B1_COD)
			msunlock()
			(cSQLDTADD)->(DBSkip())
		enddo
		(cSQLDTADD)->(DBCloseArea())
		// ==============================================
		// LEVANTA DATEADDED BASEADO NO SD1
		// ==============================================
		cSQLDTADD := GetNextAlias()
		cQuery := "SELECT SBZ.R_E_C_N_O_ BZRECNO , MIN(D1_DTDIGIT) ENTRADA FROM " + oSqlHlp:NoLock("SD1")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND B1_TIPO = 'ME' AND SB1.D_E_L_E_T_ =  ' '"
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SBZ") + " ON BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_COD =  D1_COD AND SBZ.D_E_L_E_T_ =  ' ' AND BZ_PRIENT = ' '"
		cQuery += " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY SBZ.R_E_C_N_O_"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLDTADD , .F. , .T. )
		DBSelectArea("SB5")
		While !(cSQLDTADD)->(Eof())
			DbGoTo((cSQLDTADD)->(BZRECNO))
			reclock("SBZ",.f.)
			SBZ->BZ_PRIENT := stod((cSQLDTADD)->(ENTRADA))
			msunlock()
			(cSQLDTADD)->(DBSkip())
		enddo
		(cSQLDTADD)->(DBCloseArea())
		// ==============================================
		// LEVANTAMENTO ULTVDA BASEADO NO VQ3
		// ==============================================
		cSQLDTADD := GetNextAlias()
		cQuery := "SELECT SBZ.R_E_C_N_O_ BZRECNO, MAX(VQ3_ANO "+FG_CONVSQL("CONCATENA")+" VQ3_MES "+FG_CONVSQL("CONCATENA")+" VQ3_DIA) ULTVDA FROM " + oSqlHlp:NoLock("VQ3")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SBZ") + " ON BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_COD = VQ3_PRODUT AND SBZ.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VQ3_ANO > '1970' AND (VQ3_VDAB > 0 OR VQ3_VDAO > 0 ) AND VQ3_FILIAL = '"+xFilial("VQ3")+"' AND VQ3.D_E_L_E_T_ =  ' '"
		cQuery += " GROUP BY SBZ.R_E_C_N_O_"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLDTADD , .F. , .T. )
		DBSelectArea("SBZ")
		While !(cSQLDTADD)->(Eof())
			DbGoTo((cSQLDTADD)->(BZRECNO))
			if SBZ->BZ_ULTVDA < stod((cSQLDTADD)->(ULTVDA))
				reclock("SBZ",.f.)
				SBZ->BZ_ULTVDA := stod((cSQLDTADD)->(ULTVDA))
				msunlock()
			endif
			(cSQLDTADD)->(DBSkip())
		enddo
		(cSQLDTADD)->(DBCloseArea())
		//
	end

	// ==============================================
	// CRIA SB5 PARA TODOS OS SB1
	// ==============================================
	cSQLDTADD := GetNextAlias()
	cQuery := "SELECT B1_COD FROM " + oSqlHlp:NoLock("SB1")
	cQuery += "  JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND"
	cQuery += "   NOT EXISTS ( SELECT B5_COD FROM "+ oSqlHlp:NoLock("SB5")+" WHERE B5_COD = SB1.B1_COD AND B5_FILIAL = '"+xFilial("SB5")+"' AND SB5.D_E_L_E_T_ = ' ' ) "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLDTADD , .F. , .T. )
	DBSelectArea("SB5")
	While !(cSQLDTADD)->(Eof())
		reclock("SB5", .t.)
		SB5->B5_FILIAL := xFilial("SB5")
		SB5->B5_COD    := (cSQLDTADD)->(B1_COD)
		msunlock()
		(cSQLDTADD)->(DBSkip())
	enddo
	(cSQLDTADD)->(DBCloseArea())

	if Alltrim(cDadosProd) == "SB5"
		// ==============================================
		// LEVANTA DATEADDED BASEADO NO SD1
		// ==============================================
		cSQLDTADD := GetNextAlias()
		cQuery := "SELECT  SB5.R_E_C_N_O_ B5RECNO , MIN(D1_DTDIGIT) ENTRADA FROM " + oSqlHlp:NoLock("SD1")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND B1_TIPO = 'ME' AND SB1.D_E_L_E_T_ =  ' '"
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB5") + " ON B5_FILIAL = '"+xFilial("SB5")+"' AND B5_COD = D1_COD AND SB5.D_E_L_E_T_ =  ' ' AND B5_DTADDED = ' '"
		cQuery += " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY SB5.R_E_C_N_O_"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLDTADD , .F. , .T. )
		DBSelectArea("SB5")
		While !(cSQLDTADD)->(Eof())
			DbGoTo((cSQLDTADD)->(B5RECNO))
			reclock("SB5",.f.)
			SB5->B5_DTADDED := stod((cSQLDTADD)->(ENTRADA))
			msunlock()
			(cSQLDTADD)->(DBSkip())
		enddo
		(cSQLDTADD)->(DBCloseArea())
		// ==============================================
		// LEVANTAMENTO ULTVDA BASEADO NO VQ3
		// ==============================================
		cSQLDTADD := GetNextAlias()
		cQuery := "SELECT SB5.R_E_C_N_O_ B5RECNO, MAX(VQ3_ANO "+FG_CONVSQL("CONCATENA")+" VQ3_MES "+FG_CONVSQL("CONCATENA")+" VQ3_DIA) ULTVDA FROM " + oSqlHlp:NoLock("VQ3")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB5") + " ON B5_FILIAL = '"+xFilial("SB5")+"' AND B5_COD = VQ3_PRODUT AND SB5.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VQ3_ANO > '1970' AND (VQ3_VDAB > 0 OR VQ3_VDAO > 0 ) AND VQ3_FILIAL = '"+xFilial("VQ3")+"' AND VQ3.D_E_L_E_T_ =  ' '"
		cQuery += " GROUP BY SB5.R_E_C_N_O_"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLDTADD , .F. , .T. )
		DBSelectArea("SB5")
		While !(cSQLDTADD)->(Eof())
			DbGoTo((cSQLDTADD)->(B5RECNO))
			if SB5->B5_ULTVDA < stod((cSQLDTADD)->(ULTVDA))
				reclock("SB5",.f.)
				SB5->B5_ULTVDA := stod((cSQLDTADD)->(ULTVDA))
				msunlock()
			endif
			(cSQLDTADD)->(DBSkip())
		enddo
		(cSQLDTADD)->(DBCloseArea())
	end

next

// Coleta das peças e atualização das peças direct shipment
// importante que seja após a criação dos SB5 por conta de peças que não tenham o cadastro completo
oDS:AtualizarPecas()
oDpePecas:ColetaItensDia()

// =====================================
// Reprocessamento de NA oficina e pecas
// =====================================

oDpm      := DMS_DPM():New()
oArHelp   := DMS_ArrayHelper():New()
//
//TODO: será feito em outro CI
// ordens de servico
//aOssToRep := oDpm:OssToReproc()
dDataCorte := dDatabase - 90 // 90 dias atrás, usado para limpar dados no fim do programa
// orcamentos
aOrcToRep := oDpm:OrcsToReproc()
oArHelp:Map(aOrcToRep, {|oEl| oDpm:ResetDemOrc(oEl:GetValue('VQL_FILORI'), oEl:GetValue('VQL_DADOS')) })

TcSqlExec(" UPDATE " + RetSQLName('VQL') + " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VQL_AGROUP = 'OFINJD12' AND VQL_TIPO IN ('REPROC_OS', 'REPROC_ORC') ")

// ==============================================
// LEVANTAMENTO PARA NIVEL DE ATENDIMENTO OFICINA
// ==============================================
oLogger:Log( {"Calculando Nivel de Atendimento Oficina"+ " ("+time()+")"} )


For nCont := 1 to Len(aFilis)
	//
	cFilAnt := aFilis[nCont,1]
	cDadosProd := GetNewPar("MV_MIL0054","SBZ")
	//
	cQuery := " SELECT "
	cQuery += " VOO.R_E_C_N_O_ RECNOVOO,"
	cQuery += " SD2.R_E_C_N_O_ RECNOSD2,"
	cQuery += " VOO.VOO_NUMOSV,"
	cQuery += " VOO.VOO_TIPTEM,"
	cQuery += " SB1.B1_COD,"
	cQuery += " SB1.B1_CRICOD,"
	cQuery += " SBM.BM_PROORI,"
	cQuery += " SD2.D2_EMISSAO,"
	cQuery += " SD2.D2_TOTAL,"
	cQuery += " SD2.D2_QUANT,"
	cQuery += " SD2.D2_PRCVEN,"
	cQuery += " SD2.D2_DESC,"
	cQuery += "	VOI.VOI_SITTPO, "
	cQuery += "	SF4.F4_ESTOQUE, "
	cQuery += "	SF4.F4_OPEMOV, "
	if nD2TOTIMP > 0
		cQuery += " SD2.D2_TOTIMP,"
	else
		cQuery += " 0 D2_TOTIMP,"
	endif
	cQuery += " SD2.D2_CUSTO1, "
	cQuery += " SD2.D2_DOC, "
	cQuery += " SD2.D2_SERIE "
	cQuery += " FROM "+ oSqlHlp:NoLock("SD2")
	cQuery += " JOIN " + oSqlHlp:NoLock("VOO") + " ON ( VOO_FILIAL = '"+xFilial("VOO")+"' AND VOO_SERNFI = D2_SERIE   AND VOO_NUMNFI = D2_DOC AND VOO_FLGNAT = ' ' AND VOO.D_E_L_E_T_ = ' ')"
	cQuery += " JOIN " + oSqlHlp:NoLock("SB1") + " ON ( B1_FILIAL  = '"+xFilial("SB1")+"' AND D2_COD     = B1_COD     AND SB1.D_E_L_E_T_ = ' ' )"
	cQuery += " JOIN " + oDpePecas:TableName() + " ON  FILIAL      = '"+xFilial('VS3')+"' AND PRODUTO    = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SBM") + " ON ( BM_FILIAL  = '"+xFilial("SBM")+"' AND B1_GRUPO   = BM_GRUPO   AND SBM.D_E_L_E_T_ = ' ' )"
	cQuery += " JOIN " + oSqlHlp:NoLock("VOI") + " ON ( VOI_FILIAL = '"+xFilial("VOI")+"' AND VOO_TIPTEM = VOI_TIPTEM AND VOI.D_E_L_E_T_ = ' ' )"
	cQuery += " JOIN " + oSqlHlp:NoLock("SF4") + " ON ( F4_FILIAL  = '"+xFilial("SF4")+"' AND D2_TES     = F4_CODIGO  AND SF4.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL = '"+xFilial("SD2")+"' AND D2_FLGNAT = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLPedNF , .F. , .T. )

	DBSelectArea("VS3")
	While !(cSQLPedNF)->(Eof())
		// -------------------------------------------------------------------------------------
		// PASSO A : Verificar se já foi computada PRIMEIRA ENTRADA para a peça na tabela SBZ.
		// -------------------------------------------------------------------------------------
		if Alltrim(cDadosProd) == "SBZ" // PARA QUEM USA SBZ
			SBZ->(DBSeek( xFilial("SBZ")+(cSQLPedNF)->(B1_COD) ))
			if SBZ->(found())
				if nBZPRIENT > 0
					if Empty(SBZ->BZ_PRIENT)
						cQrySD1 := GetNextAlias()
						cQuery := "SELECT MIN(D1_DTDIGIT) DTEMISSAO FROM " + oSqlHlp:NoLock("SD1")
						cQuery += " WHERE D1_FILIAL ='" + xFilial("SD1") + "' AND D1_COD='" + (cSQLPedNF)->(B1_COD) + "' AND"
						cQuery += " D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySD1, .F., .T. )
						if !Empty((cQrySD1)->(DTEMISSAO))
							DBSelectArea("SBZ")
							reclock("SBZ",.f.)
							SBZ->BZ_PRIENT := stod((cQrySD1)->(DTEMISSAO))
							msunlock()
						endif
						(cQrySD1)->(dbCloseArea())
					endif
				endif
			endif
		else  // PARA QUEM USA SB5
			SB5->(DBSeek(xFilial("SB5") + (cSQLPedNF)->(B1_COD) ))
			if SB5->(found())
				if Empty(SB5->B5_DTADDED)
					cQrySD1 := GetNextAlias()
					cQuery := "SELECT MIN(D1_DTDIGIT) DTEMISSAO FROM "+ oSqlHlp:NoLock("SD1")
					cQuery += " WHERE D1_FILIAL ='" + xFilial("SD1") + "' AND D1_COD='" + (cSQLPedNF)->(B1_COD) + "' AND"
					cQuery += " D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySD1, .F., .T. )
					if !Empty((cQrySD1)->(DTEMISSAO))
						DBSelectArea("SB5")
						reclock("SB5",.f.)
						SB5->B5_DTADDED := SF1->F1_EMISSAO
						msunlock()
					endif
					(cQrySD1)->(dbCloseArea())
				endif
			endif
		endif
		// -------------------------------------------------------------------------------------
		// PASSO B : Se a TES não movimenta estoque marca a nota com "A" e pula para a próxima
		// -------------------------------------------------------------------------------------
		if Alltrim((cSQLPedNF)->(F4_ESTOQUE)) != 'S'
			DBSelectArea("SD2")
			DBGoTo( (cSQLPedNF)->(RECNOSD2) )
			reclock("SD2",.f.)
			SD2->D2_FLGNAT := "A"
			msunlock()
			(cSQLPedNF)->(DBSkip())
			loop
		endif
		DBSelectArea("SD2")
		// -------------------------------------------------------------------------------------
		// PASSO C : Roda a CalcEst da peça para verificar qual é o nível de atendimento dele
		// -------------------------------------------------------------------------------------
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+(cSQLPedNF)->(B1_COD)))
		aSaldo := CalcEst(	(cSQLPedNF)->(B1_COD), FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"), stod((cSQLPedNF)->(D2_EMISSAO)) - 2 )
		if aSaldo[1] == 0
			nImed  := 0
			cStock := "N"
		elseif aSaldo[1] < (cSQLPedNF)->(D2_QUANT)
			nImed  := 0
			cStock := "S"
		else
			nImed  := 1
			cStock := "S"
		endif
		// -------------------------------------------------------------------------------------
		// PASSO D : Pesquisa na VQ3 para ver se já existe registro para aquela FILIAL, PRODUTO, ANO, MES, DIA e STOCK
		// -------------------------------------------------------------------------------------
		cAlVQ3Stock := GetNextAlias()
	    cQuery := "SELECT R_E_C_N_O_ VQ3RECNO FROM "+oSqlHlp:NoLock("VQ3")+" WHERE VQ3_FILIAL = '"+xFilial("VQ3")+"' AND "
	    cQuery += " VQ3_PRODUT = '"+Left((cSQLPedNF)->(B1_COD)+SPACE(27),TamSX3("VQ3_PRODUT")[1])+"' AND "
	    cQuery += " VQ3_ANO = '" + Left((cSQLPedNF)->(D2_EMISSAO),4) + "' AND "
		cQuery += " VQ3_MES = '" + Subs((cSQLPedNF)->(D2_EMISSAO),5,2) + "' AND "
		cQuery += " VQ3_DIA = '" + Subs((cSQLPedNF)->(D2_EMISSAO),7,2) + "' AND "
		cQuery += " VQ3_STOCK = '" + cStock + "' AND D_E_L_E_T_ = ' '"
        //
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlVQ3Stock , .F. , .T. )
        //
		if !(cAlVQ3Stock)->(Eof())
			VQ3->(DBGoTo((cAlVQ3Stock)->(VQ3RECNO)))
		else
			DBSelectArea("VQ3")
			reclock("VQ3",.t.)
			VQ3->VQ3_FILIAL := xFilial("VQ3")
			if nVQ3PROCES > 0
				VQ3->VQ3_PROCES := "N"
			endif
			VQ3->VQ3_PRODUT := (cSQLPedNF)->(B1_COD)
			VQ3->VQ3_CRICOD := (cSQLPedNF)->(B1_CRICOD)
			VQ3->VQ3_ANO    := Left((cSQLPedNF)->(D2_EMISSAO),4)
			VQ3->VQ3_MES    := Subs((cSQLPedNF)->(D2_EMISSAO),5,2)
			VQ3->VQ3_DIA    := Subs((cSQLPedNF)->(D2_EMISSAO),7,2)
			VQ3->VQ3_LOCAL  := IIF((cSQLPedNF)->(BM_PROORI) == "1","D1","N1")
			VQ3->VQ3_TIPLOC := IIF((cSQLPedNF)->(BM_PROORI) == "1","M","N")
			VQ3->VQ3_STOCK  := cStock
			VQ3->VQ3_TIPREG := "N"
			msunlock()
			// -------------------------------------------------------------------------------------
			// PASSO E : Grava ULTIMA VENDA PARA OFICINA
			// -------------------------------------------------------------------------------------
			if Alltrim(cDadosProd) == "SBZ" // PARA QUEM USA SBZ
				if nBZULTVDA > 0
					if SBZ->(DBSeek(xFilial("SBZ")+Alltrim(VQ3->VQ3_PRODUT)))
						if SBZ->BZ_ULTVDA < stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							DBSelectArea("SBZ")
							reclock("SBZ",.f.)
							SBZ->BZ_ULTVDA := stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							msunlock()
						endif
					endif
				endif
			else // PARA QUEM USA SB5
				if nB5ULTVDA > 0
					if SB5->(DBSeek(xFilial("SB5")+Alltrim(VQ3->VQ3_PRODUT)))
						if SB5->B5_ULTVDA < stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							DBSelectArea("SB5")
							reclock("SB5",.f.)
							SB5->B5_ULTVDA := stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							msunlock()
						endif
					endif
				endif
			endif
		endif
		// -------------------------------------------------------------------------------------
		// PASSO F : Tenta retroagir ao orçamento de oficina que gerou a OS.
		// -------------------------------------------------------------------------------------
		lDemanda := .t.
		//
		DBSelectArea("VQ3")
		if (cSQLPedNF)->(D2_QUANT) > 0
			reclock("VQ3",.f.)
			// TIPO DE TEMPO INTERNO
			if (cSQLPedNF)->(VOI_SITTPO) == "3"
				if lDemanda
					VQ3->VQ3_HITSI += 1
					VQ3->VQ3_IMEDI += nImed
				endif
				VQ3->VQ3_TOTINT += (cSQLPedNF)->(D2_TOTAL)
				if nVQ3VDAI > 0
					VQ3->VQ3_VDAI += (cSQLPedNF)->(D2_QUANT)
				endif
			else // TIPO DE TEMPO NÃO INTERNO
				if Alltrim((cSQLPedNF)->(F4_OPEMOV)) == '05'
					if lDemanda
						VQ3->VQ3_HITSO += 1
						VQ3->VQ3_IMEDO += nImed
					endif
					VQ3->VQ3_TOTOFI += (cSQLPedNF)->(D2_TOTAL)
					VQ3->VQ3_CUSOFI += (cSQLPedNF)->(D2_CUSTO1)
					VQ3->VQ3_VDAO += (cSQLPedNF)->(D2_QUANT)
				endif
			endif
			// INFORMAÇÔES QUANDO NÃO GERA DEMANDA
			if !lDemanda
				if (cSQLPedNF)->VOI_SITTPO == "3"
					VQ3->VQ3_TOTINN += (cSQLPedNF)->(D2_TOTAL)
					VQ3->VQ3_CUSINN += (cSQLPedNF)->(D2_CUSTO1)
				else
					if Alltrim((cSQLPedNF)->(F4_OPEMOV)) == '05'
						VQ3->VQ3_TOTOFN += (cSQLPedNF)->(D2_TOTAL)
						VQ3->VQ3_CUSOFN += (cSQLPedNF)->(D2_CUSTO1)
					endif
				endif
			endif
			msunlock()
		endif
		// -------------------------------------------------------------------------------------
		// PASSO H : Marca as tabelas VOO e SD2 como tratadas
		// -------------------------------------------------------------------------------------
		DBSelectArea("VOO")
		DBGOto((cSQLPedNF)->(RECNOVOO))
		reclock("VOO",.f.)
		VOO->VOO_FLGNAT := "C"
		msunlock()
		//
		DBSelectArea("SD2")
		DBGoTo( (cSQLPedNF)->(RECNOSD2) )
		reclock("SD2",.f.)
		SD2->D2_FLGNAT := "C"
		msunlock()
		//
		(cAlVQ3Stock)->(DBCloseArea())
		//
		(cSQLPedNF)->(DBSkip())
	enddo
	//
	(cSQLPedNF)->(DBCloseArea())
	// -------------------------------------------------------------------------------------
	// PASSO I : Essa query serve para garantir que nenhuma nota fique de fora. Ela pega todas
	//           as notas que ainda não foram flagadas e cria um registro padrão de demanda
	// -------------------------------------------------------------------------------------
	cQuery := "SELECT SD2.R_E_C_N_O_ RECNOSD2,"
	cQuery += " SB1.B1_COD,"
	cQuery += " SB1.B1_CRICOD,"
	cQuery += " SBM.BM_PROORI,"
	cQuery += " SD2.D2_EMISSAO,"
	cQuery += " SD2.D2_TOTAL,"
	cQuery += " SD2.D2_QUANT,"
	cQuery += " SD2.D2_PRCVEN,"
	cQuery += " SD2.D2_DESC,"
	cQuery += iif(nD2TOTIMP > 0, " SD2.D2_TOTIMP,", " 0 D2_TOTIMP,")
	cQuery += " SD2.D2_CUSTO1, "
	cQuery += " SF4.F4_ESTOQUE, "
	cQuery += " SF4.F4_OPEMOV "
	cQuery += " FROM "+ oSqlHlp:NoLock("SD2")
	cQuery += " JOIN " + oDpePecas:TableName() + " ON FILIAL     = '"+xFilial('VS3')+"' AND PRODUTO = D2_COD AND DATAGER        = '"+DTOS(dDatabase)+"' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SF2") + " ON (F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC  = D2_DOC AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ')"
	cQuery += " JOIN " + oSqlHlp:NoLock("SB1") + " ON (B1_FILIAL = '"+xFilial("SB1")+"' AND D2_COD  = B1_COD AND SB1.D_E_L_E_T_ = ' ')"
	cQuery += " JOIN " + oSqlHlp:NoLock("SBM") + " ON (BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = ' ')"
	cQuery += " JOIN " + oSqlHlp:NoLock("SF4") + " ON ( F4_FILIAL = '"+xFilial("SF4")+"' AND D2_TES = F4_CODIGO  AND  SF4.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE F2_PREFORI = '"+GetNewPar("MV_PREFOFI","OFI")+"' AND D2_FILIAL ='"+xFilial("SD2")+"' AND D2_FLGNAT = ' ' AND SD2.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLPedNF , .F. , .T. )
	//
	While !(cSQLPedNF)->(Eof())
		// -------------------------------------------------------------------------------------
		// PASSO J : Se a TES não movimenta estoque marca a nota com "D" e pula para a próxima
		// -------------------------------------------------------------------------------------
		if Alltrim((cSQLPedNF)->(F4_ESTOQUE)) != 'S' .or. Alltrim((cSQLPedNF)->(F4_OPEMOV)) != '05'
			DBSelectArea("SD2")
			DBGoTo( (cSQLPedNF)->(RECNOSD2) )
			reclock("SD2",.f.)
			SD2->D2_FLGNAT := "D"
			msunlock()
			(cSQLPedNF)->(DBSkip())
			loop
		endif
		// -------------------------------------------------------------------------------------
		// PASSO K : Roda a CalcEst da peça para verificar qual é o nível de atendimento dele
		// -------------------------------------------------------------------------------------
		DBSelectArea("SD2")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+(cSQLPedNF)->(B1_COD)))
		aSaldo := CalcEst(	(cSQLPedNF)->(B1_COD), FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"), stod((cSQLPedNF)->(D2_EMISSAO)) - 2 )
		if aSaldo[1] == 0
			nImed  := 0
			cStock := "N"
		elseif aSaldo[1] < (cSQLPedNF)->(D2_QUANT)
			nImed  := 0
			cStock := "S"
		else
			nImed := 1
			cStock := "S"
		endif
		// -------------------------------------------------------------------------------------
		// PASSO L : Pesquisa na VQ3 para ver se já existe registro para aquela FILIAL, PRODUTO, ANO, MES, DIA e STOCK
		// -------------------------------------------------------------------------------------
		cAlVQ3Stock := GetNextAlias()
		//
	    cQuery := " SELECT R_E_C_N_O_ VQ3RECNO FROM "+oSqlHlp:NoLock("VQ3")+" WHERE VQ3_FILIAL = '"+xFilial("VQ3")+"' AND "
	    cQuery += " VQ3_PRODUT = '"+Left((cSQLPedNF)->(B1_COD)+SPACE(27),TamSX3("VQ3_PRODUT")[1])+"' AND "
	    cQuery += " VQ3_ANO = '" + Left((cSQLPedNF)->(D2_EMISSAO),4) + "' AND "
		cQuery += " VQ3_MES = '" + Subs((cSQLPedNF)->(D2_EMISSAO),5,2) + "' AND "
		cQuery += " VQ3_DIA = '" + Subs((cSQLPedNF)->(D2_EMISSAO),7,2) + "' AND "
		cQuery += " VQ3_STOCK = '"+cStock+"' AND D_E_L_E_T_ = ' '"
        //
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlVQ3Stock , .F. , .T. )
        //
		if !(cAlVQ3Stock)->(Eof())
			VQ3->(DBGoTo((cAlVQ3Stock)->(VQ3RECNO)))
		else
			DBSelectArea("VQ3")
			reclock("VQ3",.t.)
			VQ3->VQ3_FILIAL := xFilial("VQ3")
			if nVQ3PROCES > 0
				VQ3->VQ3_PROCES := "N"
			endif
			VQ3->VQ3_PRODUT := (cSQLPedNF)->(B1_COD)
			VQ3->VQ3_CRICOD := (cSQLPedNF)->(B1_CRICOD)
			VQ3->VQ3_ANO := Left((cSQLPedNF)->(D2_EMISSAO),4)
			VQ3->VQ3_MES := Subs((cSQLPedNF)->(D2_EMISSAO),5,2)
			VQ3->VQ3_DIA := Subs((cSQLPedNF)->(D2_EMISSAO),7,2)
			VQ3->VQ3_LOCAL  := IIF((cSQLPedNF)->(BM_PROORI) == "1","D1","N1")
			VQ3->VQ3_TIPLOC := IIF((cSQLPedNF)->(BM_PROORI) == "1","M","N")
			VQ3->VQ3_STOCK  := cStock
			VQ3->VQ3_TIPREG := "N"
			msunlock()
			// -------------------------------------------------------------------------------------
			// PASSO M : Grava ULTIMA VENDA PARA OFICINA
			// -------------------------------------------------------------------------------------
			if Alltrim(cDadosProd) == "SBZ" // PARA QUEM USA SBZ
				if nBZULTVDA > 0
					if SBZ->(DBSeek(xFilial("SBZ")+Alltrim(VQ3->VQ3_PRODUT)))
						if SBZ->BZ_ULTVDA < stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							DBSelectArea("SBZ")
							reclock("SBZ",.f.)
							SBZ->BZ_ULTVDA := stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							msunlock()
						endif
					endif
				endif
			else // PARA QUEM USA SB5
				if nB5ULTVDA > 0
					if SB5->(DBSeek(xFilial("SB5")+Alltrim(VQ3->VQ3_PRODUT)))
						if SB5->B5_ULTVDA < stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							DBSelectArea("SB5")
							reclock("SB5",.f.)
							SB5->B5_ULTVDA := stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							msunlock()
						endif
					endif
				endif
			endif
		endif
		// -------------------------------------------------------------------------------------
		// PASSO N : Baseado nos levantamentos, grava todas as informações faltantes no VQ3
		// -------------------------------------------------------------------------------------
		reclock("VQ3",.F.)
		if (cSQLPedNF)->(D2_QUANT) > 0
			VQ3->VQ3_HITSO += 1
			VQ3->VQ3_TOTOFI += (cSQLPedNF)->(D2_TOTAL)
			VQ3->VQ3_CUSOFI += (cSQLPedNF)->(D2_CUSTO1)
			VQ3->VQ3_VDAO += (cSQLPedNF)->(D2_QUANT)
			VQ3->VQ3_IMEDO += nImed
			msunlock()
		endif
		// -------------------------------------------------------------------------------------
		// PASSO O : Marca as tabelas VOO e SD2 como tratadas
		// -------------------------------------------------------------------------------------
		DBSelectArea("SD2")
		DBGoTo( (cSQLPedNF)->(RECNOSD2) )
		reclock("SD2",.f.)
		SD2->D2_FLGNAT := "E"
		msunlock()
		//
		(cAlVQ3Stock)->(DBCloseArea())
		(cSQLPedNF)->(DBSkip())
	enddo
	(cSQLPedNF)->(DBCloseArea())
next

// =============================================
// LEVANTAMENTO PARA NIVEL DE ATENDIMENTO BALCAO
// =============================================
oLogger:Log( {"Calculando Nivel de Atendimento Balcao"+ " ("+time()+")"} )
For nCont := 1 to Len(aFilis)
	// Levanta os pedidos que possuem nota emitida mas ainda não foram marcados (FLAGNAT)
	cFilAnt := aFilis[nCont,1]
	cDadosProd := GetNewPar("MV_MIL0054","SBZ")
	//
	cQuery := "SELECT DISTINCT"
	cQuery += " VS1O.VS1_NUMNFI NUMNFI,"
	cQuery += " VS1O.VS1_SERNFI SERIE,"
	cQuery += " VS1P.VS1_NUMORC NUMORC,"
	cQuery += " VS1P.VS1_DATORC DATORC"
	cQuery += " FROM "+oSqlHlp:NoLock("VS1", 'VS1P')
	cQuery += " INNER JOIN "+oSqlHlp:NoLock("VS1", 'VS1O')+"  ON VS1P.VS1_FILIAL = VS1O.VS1_FILIAL AND VS1P.VS1_NUMORC = VS1O.VS1_PEDREF  AND VS1O.VS1_PEDREF <> ' '"
	cQuery += " INNER JOIN "+oSqlHlp:NoLock("VS3", 'VS3P')+"  ON VS1P.VS1_FILIAL = VS3P.VS3_FILIAL AND VS1P.VS1_NUMORC = VS3P.VS3_NUMORC  AND VS3P.VS3_MOTPED = ' ' AND VS3P.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VS1O.VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1O.VS1_NUMNFI != ' ' AND VS1O.VS1_TIPORC = '1' AND VS3P.VS3_FLGNAT IN (' ','!')"
	cQuery += " AND VS1P.D_E_L_E_T_ = ' ' AND VS1O.D_E_L_E_T_ = ' ' ORDER BY VS1O.VS1_NUMNFI ASC"
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLPedNF , .F. , .T. )
	//
	While !(cSQLPedNF)->(Eof())
		// -------------------------------------------------------------------------------------
		// PASSO A : Levanta os itens de orçamento que possuem nota emitida mas ainda não foram marcados (FLAGNAT)
		// -------------------------------------------------------------------------------------
		cQuery := "SELECT "
		cQuery += " VS3.R_E_C_N_O_ VS3RECNO,"
		cQuery += " SD2.R_E_C_N_O_ SD2RECNO,"
		cQuery += " VS3.VS3_FLGNAT,"
		cQuery += " SB1.B1_CRICOD,"
		cQuery += " SD2.D2_COD,"
		cQuery += " SD2.D2_EMISSAO,"
		cQuery += " SD2.D2_TOTAL,"
		cQuery += " SD2.D2_QUANT,"
		cQuery += " SD2.D2_PRCVEN,"
		cQuery += " SD2.D2_DESC,"
		if nD2TOTIMP > 0
			cQuery += " SD2.D2_TOTIMP,"
		else
			cQuery += " 0 as D2_TOTIMP,"
		endif
		cQuery += " SD2.D2_CUSTO1, "
		cQuery += " VS3.VS3_QESTNA, "
		cQuery += " VS3.VS3_QTDELI, "
		cQuery += " VS3.VS3_CODSIT, "
		cQuery += " VS3.VS3_QTDINI, "
		cQuery += " SBM.BM_PROORI, "
		cQuery += " SF4.F4_ESTOQUE, "
		cQuery += " SF4.F4_OPEMOV "
		cQuery += " FROM "+oSqlHlp:NoLock("SD2")
		cQuery += " JOIN " + oSqlHlp:NoLock("SB1") + " ON SB1.B1_COD   = SD2.D2_COD           AND SB1.B1_FILIAL  = '"+xFilial("SB1")+"'          AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + oSqlHlp:NoLock("SBM") + " ON SB1.B1_GRUPO = SBM.BM_GRUPO         AND SBM.BM_FILIAL  = '"+xFilial("SBM")+"'          AND BM_VAIDPM      = '1'           AND SBM.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + oSqlHlp:NoLock("VS3") + " ON VS3_FILIAL   = '"+xFilial('VS3')+"' AND VS3.VS3_NUMORC = '"+ (cSQLPedNF)->(NUMORC) +"' AND VS3.VS3_CODITE = SB1.B1_CODITE AND VS3.VS3_GRUITE = SB1.B1_GRUPO AND VS3.VS3_FLGNAT IN (' ','!') AND VS3.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + oSqlHlp:NoLock("SF4") + " ON F4_FILIAL    = '"+xFilial("SF4")+"' AND F4_CODIGO      = D2_TES                        AND SF4.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE D2_DOC = '" + (cSQLPedNF)->(NUMNFI) + "' AND D2_SERIE = '" + (cSQLPedNF)->(SERIE) + "'"
		cQuery += " AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
		cQuery += " AND SD2.D_E_L_E_T_ = ' ' AND D2_QUANT > 0 "
		//
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSD2Abe , .F. , .T. )
		//
		While !(cSQLSD2Abe)->(Eof())
			// -------------------------------------------------------------------------------------
			// PASSO B : Verificar se já foi computada PRIMEIRA ENTRADA para a peça na tabela SBZ.
			// -------------------------------------------------------------------------------------
			if Alltrim(cDadosProd) == "SBZ" // PARA QUEM USA SBZ
				SBZ->(DBSeek( xFilial("SBZ")+(cSQLSD2Abe)->(D2_COD) ))
				if SBZ->(found())
					if nBZPRIENT > 0
						if Empty(SBZ->BZ_PRIENT)
							cQrySD1 := GetNextAlias()
							cQuery := "SELECT MIN(D1_DTDIGIT) DTEMISSAO FROM "+oSqlHlp:NoLock("SD1")
							cQuery += " WHERE D1_FILIAL ='" + xFilial("SD1") + "' AND D1_COD='" + (cSQLSD2Abe)->(D2_COD) + "' AND"
							cQuery += " D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySD1, .F., .T. )
							if !Empty((cQrySD1)->(DTEMISSAO))
								DBSelectArea("SBZ")
								reclock("SBZ",.f.)
								SBZ->BZ_PRIENT := stod((cQrySD1)->(DTEMISSAO))
								msunlock()
							endif
							(cQrySD1)->(dbCloseArea())
						endif
					endif
				endif
			else  // PARA QUEM USA SB5
				SB5->(DBSeek(xFilial("SB5") + (cSQLSD2Abe)->(D2_COD) ))
				if SB5->(found())
					if Empty(SB5->B5_DTADDED)
						cQrySD1 := GetNextAlias()
						cQuery := "SELECT MIN(D1_DTDIGIT) DTEMISSAO FROM "+oSqlHlp:NoLock("SD1")
						cQuery += " WHERE D1_FILIAL ='" + xFilial("SD1") + "' AND D1_COD='" + (cSQLSD2Abe)->(D2_COD) + "' AND"
						cQuery += " D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySD1, .F., .T. )
						if !Empty((cQrySD1)->(DTEMISSAO))
							DBSelectArea("SB5")
							reclock("SB5",.f.)
							SB5->B5_DTADDED := SF1->F1_EMISSAO
							msunlock()
						endif
						(cQrySD1)->(dbCloseArea())
					endif
				endif
			endif
			// -------------------------------------------------------------------------------------
			// PASSO C : Verifica se o TES movimenta Estoque
			// -------------------------------------------------------------------------------------
			if Alltrim((cSQLSD2Abe)->(F4_ESTOQUE)) != 'S' .or. Alltrim((cSQLSD2Abe)->(F4_OPEMOV)) != '05'
				DBSelectArea("SD2")
				SD2->(DBGoTo((cSQLSD2Abe)->(SD2RECNO)))
				reclock("SD2",.f.)
				SD2->D2_FLGNAT := "F"
				msunlock()
				(cSQLSD2Abe)->(DBSkip())
				loop
			endif
			if (cSQLSD2Abe)->(VS3_QESTNA) == 0
				cStock := "N"
			else
				cStock := "S"
			endif
			// -------------------------------------------------------------------------------------
			// PASSO D : Pesquisa na VQ3 para ver se já existe registro para aquela FILIAL, PRODUTO, ANO, MES, DIA e STOCK
			// -------------------------------------------------------------------------------------
			cB1Cod := (cSQLSD2Abe)->(D2_COD)
			cAno   := Left((cSQLSD2Abe)->(D2_EMISSAO),4)
			cMes   := Subs((cSQLSD2Abe)->(D2_EMISSAO),5,2)
			cDia   := Subs((cSQLSD2Abe)->(D2_EMISSAO),7,2)

			FS_PosVq3(cB1Cod, cAno, cMes, cDia, cStock)

			if (cSQLSD2Abe)->(BM_PROORI) == "1"
				VQ3->VQ3_LOCAL  := "D1"
				VQ3->VQ3_TIPLOC := "M"
			else
				VQ3->VQ3_LOCAL  := "N1"
				VQ3->VQ3_TIPLOC := "N"
			end

			// -------------------------------------------------------------------------------------
			// PASSO F : Baseado nos levantamentos, grava todas as informações faltantes na VQ3
			// -------------------------------------------------------------------------------------
			if Empty( (cSQLSD2Abe)->(VS3_FLGNAT) ) .AND.  (cSQLSD2Abe)->(D2_QUANT) > 0 // não foi processado
				if (cSQLSD2Abe)->(D2_QUANT) > 0
					if FS_ConsDem( (cSQLSD2Abe)->(VS3_CODSIT) )
						if (cSQLSD2Abe)->(VS3_QESTNA) >= (cSQLSD2Abe)->(VS3_QTDINI)  .and.  (cSQLSD2Abe)->(VS3_QTDELI) == 0 .and. cStock == "S"
							VQ3->VQ3_IMEDB += 1
						endif

						VQ3->VQ3_TOTBAL += (cSQLSD2Abe)->(D2_TOTAL)
						VQ3->VQ3_CUSBAL += (cSQLSD2Abe)->(D2_CUSTO1)
						VQ3->VQ3_HITSB  += 1
						VQ3->VQ3_VDAB   += (cSQLSD2Abe)->(D2_QUANT)

						FS_GrvUltVda(cB1Cod, cAno, cMes, cDia)

					else
						If FS_isEspecial( (cSQLSD2Abe)->(VS3_CODSIT) ) // especial soma hits normal, mas só isso
							VQ3->VQ3_HITSBN += 1
							VQ3->VQ3_VDABN  += (cSQLSD2Abe)->(D2_QUANT)
							VQ3->VQ3_TOTBAN += (cSQLSD2Abe)->(D2_TOTAL)
							VQ3->VQ3_CUSBAN += (cSQLSD2Abe)->(D2_CUSTO1)
							if (cSQLSD2Abe)->(VS3_QESTNA) >= (cSQLSD2Abe)->(VS3_QTDINI) .and. (cSQLSD2Abe)->(VS3_QTDELI) == 0 .and. cStock == "S"
								VQ3->VQ3_IMEDBN += 1
							endif
						endif
					endif
				endif
			endif

			VQ3->(MsUnlock())

			// -------------------------------------------------------------------------------------
			// PASSO G : Marca tabelas como processadas
			// -------------------------------------------------------------------------------------
			if Empty((cSQLSD2Abe)->(VS3_FLGNAT))
				DBSelectArea("VS3")
				VS3->(DBGoTo((cSQLSD2Abe)->(VS3RECNO)))
				reclock("VS3",.f.)
				VS3->VS3_FLGNAT := "G"
				msunlock()
			endif

			DBSelectArea("SD2")
			SD2->(DBGoTo((cSQLSD2Abe)->(SD2RECNO)))
			reclock("SD2",.f.)
			SD2->D2_FLGNAT := "G"
			msunlock()
			//
			(cSQLSD2Abe)->(DBSkip())
		enddo
		(cSQLSD2Abe)->(DbCloseArea())
		// -------------------------------------------------------------------------------------
		// Se o orçamento tem nota e mais de 90 dias e o usuário não apontou nada, marca para não ser levantado novamente
		// -------------------------------------------------------------------------------------
		if dDataBase - stod((cSQLPedNF)->(DATORC)) > 90
			cQuery := "SELECT "
			cQuery += " VS3.R_E_C_N_O_ VS3RECNO "
			cQuery += " FROM " + oSqlHlp:NoLock("VS3")
			cQuery += " WHERE VS3.VS3_NUMORC = '"+ (cSQLPedNF)->(NUMORC) +"' AND VS3.VS3_FILIAL = '"+ (cSQLPedNF)->(NUMORC) +"' "
			cQuery += " AND VS3.VS3_FLGNAT = ' ' AND VS3.D_E_L_E_T_ = ' ' AND VS3_MOTPED != '"+Alltrim(GetNewPar("MV_MIL0032","000002"))+"'"
			//
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSD2Abe , .F. , .T. )
			while !((cSQLSD2Abe)->(Eof()))
				DBGoTo( (cSQLSD2Abe)->(VS3RECNO) )
				reclock("VS3",.f.)
				VS3->VS3_FLGNAT := 'H'
				msunlock()
				(cSQLSD2Abe)->(DBSkip())
			enddo
			(cSQLSD2Abe)->(DBCloseArea())
		endif
		//
		(cSQLPedNF)->(DBSkip())
	enddo
	(cSQLPedNF)->(DbCloseArea())
	// -------------------------------------------------------------------------------------
	// PASSO H : Computar vendas perdidas
	// -------------------------------------------------------------------------------------
	cQuery := " SELECT SBM.BM_PROORI, VS1.VS1_DATORC DATORC, VS3.R_E_C_N_O_ VS3RECNO, VS3.VS3_QTDITE, VS3.VS3_QTDELI,  VS3.VS3_CODSIT, SB1.B1_COD CODITE, SB1.B1_CRICOD CRICOD FROM " + oSqlHlp:NoLock("VS3")
	cQuery += " INNER JOIN " + oSqlHlp:NoLock("VS1") + " ON ( VS1_NUMORC = VS3_NUMORC AND VS1_FILIAL = VS3_FILIAL ) "
	cQuery += " JOIN " + oSqlHlp:NoLock("SB1") + " ON ( SB1.B1_CODITE = VS3.VS3_CODITE AND SB1.B1_GRUPO = VS3.VS3_GRUITE )"
	cQuery += " JOIN " + oDpePecas:TableName() + " ON FILIAL        = '"+xFilial('VS3')+"'  AND PRODUTO      = B1_COD               AND DATAGER = '"+DTOS(dDatabase)+"' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SBM") + " ON ( SB1.B1_GRUPO = SBM.BM_GRUPO  AND BM_FILIAL = '"+xFilial("SBM")+"')"
	cQuery += " WHERE VS1_TIPORC = 'P' AND VS3_QTDELI <> 0 AND VS3_FLGNAT != 'I' AND VS3_MOTPED = '"+Alltrim(GetNewPar("MV_MIL0032","000002"))+"'"
	cQuery += " AND VS1.VS1_FILIAL = '"+xFilial("VS1")+"' AND VS3.VS3_FILIAL = '"+xFilial("VS3")+"' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery += " AND SB1.D_E_L_E_T_ = ' ' AND VS3.D_E_L_E_T_ = ' ' AND VS1.D_E_L_E_T_ = ' ' AND SBM.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVdaPer , .F. , .T. )
	//
	While !(cSQLVdaPer)->(Eof())
		DBSelectArea("VQ3")
		if FS_ConsDem( (cSQLVdaPer)->(VS3_CODSIT) )
			if VQ3->( DBSeek(xFilial("VQ3") + Left((cSQLVdaPer)->(CODITE)+SPACE(27),TamSX3("VQ3_PRODUT")[1]) + (cSQLVdaPer)->(DATORC)))
				reclock("VQ3",.f.)
				VQ3->VQ3_VDPERB := VQ3->VQ3_VDPERB + (cSQLVdaPer)->(VS3_QTDELI)
				VQ3->VQ3_HIPERB := VQ3->VQ3_HIPERB + 1
				msunlock()
			else
				reclock("VQ3",.t.)
				VQ3->VQ3_FILIAL := xFilial("VQ3")
				if nVQ3PROCES > 0
					VQ3->VQ3_PROCES := "N"
				endif
				VQ3->VQ3_PRODUT := (cSQLVdaPer)->(CODITE)
				VQ3->VQ3_CRICOD :=(cSQLVdaPer)->(CRICOD)
				VQ3->VQ3_ANO := Left((cSQLVdaPer)->(DATORC),4)
				VQ3->VQ3_MES := Subs((cSQLVdaPer)->(DATORC),5,2)
				VQ3->VQ3_DIA := Subs((cSQLVdaPer)->(DATORC),7,2)
				VQ3->VQ3_LOCAL  := IIF((cSQLVdaPer)->(BM_PROORI) == "1","D1","N1")
				VQ3->VQ3_TIPLOC := IIF((cSQLVdaPer)->(BM_PROORI) == "1","M","N")
				VQ3->VQ3_STOCK  := "S"  // criar campo no SB1 ( Peça Estocada (S) ou Não Estocada (N) )
				VQ3->VQ3_VDPERB := (cSQLVdaPer)->(VS3_QTDELI)
				VQ3->VQ3_HIPERB := 1
				VQ3->VQ3_TIPREG := "N"
				msunlock()
			endif
		endif
		DBSelectArea("VS3")
		DBGoTo((cSQLVdaPer)->(VS3RECNO))
		reclock("VS3",.f.)
		VS3->VS3_FLGNAT := "I"
		msunlock()
		(cSQLVdaPer)->(DBSkip())
	enddo
	//
	(cSQLVdaPer)->(DbCloseArea())
	// -------------------------------------------------------------------------------------
	// PASSO I : Essa query serve para garantir que nenhuma nota fique de fora. Ela pega todas
	//           as notas que ainda não foram flagadas e cria um registro padrão de demanda
	// -------------------------------------------------------------------------------------
	cQuery := "SELECT SD2.R_E_C_N_O_ RECNOSD2,"
	cQuery += " SB1.B1_COD,"
	cQuery += " SB1.B1_CRICOD,"
	cQuery += " SBM.BM_PROORI,"
	cQuery += " SD2.D2_EMISSAO,"
	cQuery += " SD2.D2_DOC,"
	cQuery += " SD2.D2_SERIE,"
	cQuery += " SD2.D2_TOTAL,"
	cQuery += " SD2.D2_QUANT,"
	cQuery += " SD2.D2_PRCVEN,"
	cQuery += " SD2.D2_DESC,"
	cQuery += " SB1.B1_GRUPO,"
	cQuery += " SB1.B1_CODITE,"
	if nD2TOTIMP > 0
		cQuery += " SD2.D2_TOTIMP,"
	else
		cQuery += " 0 D2_TOTIMP,"
	endif
	cQuery += " SD2.D2_CUSTO1, "
	cQuery += " SF4.F4_ESTOQUE, "
	cQuery += " SF4.F4_OPEMOV "
	cQuery += " FROM "+oSqlHlp:NoLock("SD2")
	cQuery += " JOIN " + oDpePecas:TableName() + " ON FILIAL = '"+xFilial('VS3')+"'      AND PRODUTO  = D2_COD  AND DATAGER = '"+DTOS(dDatabase)+"' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SF2") + " ON F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND D2_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SF4") + " ON F4_FILIAL = '"+xFilial("SF4")+"' AND D2_TES = F4_CODIGO  AND  SF4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE F2_PREFORI = '"+GetNewPar("MV_PREFBAL","BAL")+"' AND D2_FILIAL ='"+xFilial("SD2")+"' AND D2_FLGNAT = ' ' AND SD2.D_E_L_E_T_ = ' '"
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLPedNF , .F. , .T. )

	While !(cSQLPedNF)->(Eof())
		if Alltrim((cSQLPedNF)->(F4_ESTOQUE)) != 'S' .or. Alltrim((cSQLPedNF)->(F4_OPEMOV)) != '05'
			DBSelectArea("SD2")
			DBGoTo( (cSQLPedNF)->(RECNOSD2) )
			reclock("SD2",.f.)
			SD2->D2_FLGNAT := "J"
			msunlock()
			(cSQLPedNF)->(DBSkip())
			loop
		endif
		//
		// -------------------------------------------------------------------------------------
		// PASSO D : Pesquisa na VQ3 para ver se já existe registro para aquela FILIAL, PRODUTO, ANO, MES, DIA e STOCK
		// -------------------------------------------------------------------------------------
		cAlVQ3Stock := GetNextAlias()
		//
	    cQuery := " SELECT R_E_C_N_O_ VQ3RECNO FROM "+oSqlHlp:NoLock("VQ3")+" WHERE VQ3_FILIAL = '"+xFilial("VQ3")+"' AND "
	    cQuery += " VQ3_PRODUT = '"+Left((cSQLPedNF)->(B1_COD)+SPACE(27),TamSX3("VQ3_PRODUT")[1])+"' AND "
	    cQuery += " VQ3_ANO = '" + Left((cSQLPedNF)->(D2_EMISSAO),4)   + "' AND "
		cQuery += " VQ3_MES = '" + Subs((cSQLPedNF)->(D2_EMISSAO),5,2) + "' AND "
		cQuery += " VQ3_DIA = '" + Subs((cSQLPedNF)->(D2_EMISSAO),7,2) + "' AND "
		cQuery += " VQ3_STOCK = 'S' AND D_E_L_E_T_ = ' '"
        //
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlVQ3Stock , .F. , .T. )
        //
      	if !(cAlVQ3Stock)->(Eof())
			VQ3->(DBGoTo((cAlVQ3Stock)->(VQ3RECNO)))
		else
			DBSelectArea("VQ3")
			reclock("VQ3",.t.)
			VQ3->VQ3_FILIAL := xFilial("VQ3")
			if nVQ3PROCES > 0
				VQ3->VQ3_PROCES := "N"
			endif
			VQ3->VQ3_PRODUT := (cSQLPedNF)->(B1_COD)
			VQ3->VQ3_CRICOD := (cSQLPedNF)->(B1_CRICOD)
			VQ3->VQ3_ANO := Left((cSQLPedNF)->(D2_EMISSAO),4)
			VQ3->VQ3_MES := Subs((cSQLPedNF)->(D2_EMISSAO),5,2)
			VQ3->VQ3_DIA := Subs((cSQLPedNF)->(D2_EMISSAO),7,2)
			VQ3->VQ3_LOCAL  := IIF((cSQLPedNF)->(BM_PROORI) == "1","D1","N1")
			VQ3->VQ3_TIPLOC := IIF((cSQLPedNF)->(BM_PROORI) == "1","M","N")
			VQ3->VQ3_STOCK  := "S"
			VQ3->VQ3_TIPREG := "N"
			msunlock()
			// -------------------------------------------------------------------------------------
			// PASSO E : Grava ULTIMA VENDA PARA OFICINA
			// -------------------------------------------------------------------------------------
			if Alltrim(cDadosProd) == "SBZ" // PARA QUEM USA SBZ
				if nBZULTVDA > 0
					if SBZ->(DBSeek(xFilial("SBZ")+Alltrim(VQ3->VQ3_PRODUT)))
						if SBZ->BZ_ULTVDA < stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							DBSelectArea("SBZ")
							reclock("SBZ",.f.)
							SBZ->BZ_ULTVDA := stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							msunlock()
						endif
					endif
				endif
			else // PARA QUEM USA SB5
				if nB5ULTVDA > 0
					if SB5->(DBSeek(xFilial("SB5")+Alltrim(VQ3->VQ3_PRODUT)))
						if SB5->B5_ULTVDA < stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							DBSelectArea("SB5")
							reclock("SB5",.f.)
							SB5->B5_ULTVDA := stod(VQ3->VQ3_ANO+VQ3->VQ3_MES+VQ3->VQ3_DIA)
							msunlock()
						endif
					endif
				endif
			endif
		endif
		//
		lDemanda := .t.
		nImedVS3 := 0
		if (cSQLPedNF)->(D2_QUANT) > 0
			DBSelectArea("VS1")
			DBSetOrder(3)
			if DBSeek(xFilial("VS1") + (cSQLPedNF)->(D2_DOC) + (cSQLPedNF)->(D2_SERIE))
				DBSelectArea("VS3")
				DBSetOrder(2)
				if DBSeek(xFilial("VS3") + VS1->VS1_NUMORC + (cSQLPedNF)->(B1_GRUPO) + (cSQLPedNF)->(B1_CODITE))
					if VS3->VS3_QESTNA >= VS3->VS3_QTDINI
						nImedVS3 := 1
					endif
					if FS_ConsDem( VS3->VS3_CODSIT )
						lDemanda := .t.
					else
						lDemanda := .f.
					endif
				endif
			endif
			reclock("VQ3",.F.)

			If lDemanda
				if FS_isEspecial(VS3->VS3_CODSIT)
					VQ3->VQ3_HITSBN += 1
					VQ3->VQ3_IMEDBN += nImedVS3
					VQ3->VQ3_TOTBAN += (cSQLPedNF)->(D2_TOTAL)
					VQ3->VQ3_CUSBAN += (cSQLPedNF)->(D2_CUSTO1)
					VQ3->VQ3_VDABN  += (cSQLPedNF)->(D2_QUANT)
				Else
					VQ3->VQ3_HITSB  += 1
					VQ3->VQ3_IMEDB  += nImedVS3
					VQ3->VQ3_TOTBAL += (cSQLPedNF)->(D2_TOTAL)
					VQ3->VQ3_CUSBAL += (cSQLPedNF)->(D2_CUSTO1)
					VQ3->VQ3_VDAB   += (cSQLPedNF)->(D2_QUANT)
				EndIf
			endif
			msunlock()
		endif

		// -------------------------------------------------------------------------------------
		// PASSO E : Marca D2 como processado
		// -------------------------------------------------------------------------------------
		DBSelectArea("SD2")
		DBGoTo( (cSQLPedNF)->(RECNOSD2) )
		reclock("SD2",.f.)
		if lDemanda
			SD2->D2_FLGNAT := "M"
		else
			SD2->D2_FLGNAT := "L"
		endif
		msunlock()
		//
		(cAlVQ3Stock)->(DBCloseArea())
		(cSQLPedNF)->(DBSkip())
	enddo
	(cSQLPedNF)->(DBCloseArea())

	// Limpeza de dados que não foi apontado nada em 90 dias
	cUpdLim := " UPDATE " + RetSQLName("VS3") + " SET VS3_FLGNAT = 'H' "
	cUpdLim += " WHERE VS3_FILIAL = '"+ xFilial('VS3') +"' "
	cUpdLim += "   AND VS3_FLGNAT = ' ' "
	cUpdLim += "   AND VS3_MOTPED != '"+Alltrim(GetNewPar("MV_MIL0032","000002"))+"' "
	cUpdLim += "   AND D_E_L_E_T_ = ' ' "
	cUpdLim += "   AND EXISTS ("
	cUpdLim += "     SELECT VS1_NUMORC FROM " + RetSQLName('VS1') + " VS1 "
	cUpdLim += "      WHERE VS1.VS1_NUMORC  = VS3_NUMORC "
	cUpdLim += "        AND VS1_TIPORC      = 'P' "
	cUpdLim += "        AND VS1.VS1_FILIAL  = '"+xFilial('VS1')+"' "
	cUpdLim += "        AND VS1.VS1_DATORC <= '"+DTOS(dDataCorte)+"' "
	cUpdLim += "        AND VS1.D_E_L_E_T_  = ' ' "
	cUpdLim += "   ) "
	if TcSqlExec(cUpdLim) < 0
		conout("Erro query OFINJD12: " + TCSQLError())
	endif
next




// -------------------------------------------------------------------------------------
// GRAVA DEVOLUCAO
// -------------------------------------------------------------------------------------
cAliasSD1 := GetNextAlias()
//
for nCont := 1 to Len(aFilis2)
	//
	cFilAnt := aFilis2[nCont,1]
	cDadosProd := GetNewPar("MV_MIL0054","SBZ")
	//
	cQuery := " SELECT SD1.R_E_C_N_O_ RECSD1,"
	cQuery += " SD1.D1_TOTAL, SD1.D1_VALDESC, SD1.D1_CUSTO , SB1.B1_GRUPO , SD1.D1_QUANT,  SF2.F2_PREFORI, SD1.D1_COD, SD1.D1_DTDIGIT, SB1.B1_CRICOD, SD2.D2_EMISSAO "
	cQuery += " FROM "+oSqlHlp:NoLock("SD1")
	cQuery += " JOIN "+oDpePecas:TableName()+" ON FILIAL = '"+xFilial('VS3')+"'  AND PRODUTO  = D1_COD  AND DATAGER = '"+DTOS(dDatabase)+"' "
	cQuery += " JOIN "+oSqlHlp:NoLock("SF2")+" ON ( SF2.F2_FILIAL=SD1.D1_FILIAL AND SF2.F2_DOC=SD1.D1_NFORI AND SF2.F2_SERIE=SD1.D1_SERIORI  AND SF2.F2_PREFORI IN ('"+GetNewPar("MV_PREFBAL","BAL")+"','"+GetNewPar("MV_PREFOFI","OFI")+"') AND SF2.D_E_L_E_T_=' ' ) "
	cQuery += " JOIN "+oSqlHlp:NoLock("SD2")+" ON ( SD2.D2_FILIAL=SF2.F2_FILIAL AND SD2.D2_DOC=SF2.F2_DOC   AND SD2.D2_SERIE=SF2.F2_SERIE    AND SD2.D2_COD = SD1.D1_COD AND SD1.D1_ITEMORI = SD2.D2_ITEM AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += " JOIN "+oSqlHlp:NoLock("SF4")+" ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " // OPEMOV = 05 = VENDA
	cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_=' ' AND D1_FLGNAT = ' ' "
	cQuery += "  ORDER BY SD1.D1_FILIAL "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD1, .T., .T. )

	While !((cAliasSD1)->(Eof()))
		if !(VQ3->( DBSeek(xFilial("VQ3") + Left((cAliasSD1)->(D1_COD)+SPACE(27),TamSX3("VQ3_PRODUT")[1]) + (cAliasSD1)->(D2_EMISSAO))))
			reclock("VQ3",.t.)
			VQ3->VQ3_FILIAL := xFilial("VQ3")
			if nVQ3PROCES > 0
				VQ3->VQ3_PROCES := "N"
			endif
			VQ3->VQ3_PRODUT := (cAliasSD1)->(D1_COD)
			VQ3->VQ3_CRICOD := (cAliasSD1)->(B1_CRICOD)
			VQ3->VQ3_ANO := Left((cAliasSD1)->(D2_EMISSAO),4)
			VQ3->VQ3_MES := Subs((cAliasSD1)->(D2_EMISSAO),5,2)
			VQ3->VQ3_DIA := Subs((cAliasSD1)->(D2_EMISSAO),7,2)
			VQ3->VQ3_LOCAL  := "D1"
			VQ3->VQ3_TIPLOC := "M"
			VQ3->VQ3_STOCK  := "S"
			VQ3->VQ3_TIPREG := "N"
			msunlock()
		endif

		reclock("VQ3",.f.)
		if Alltrim((cAliasSD1)->(F2_PREFORI)) == Alltrim(GetNewPar("MV_PREFOFI","OFI"))
			VQ3->VQ3_DEVOFI += (cAliasSD1)->(D1_TOTAL) - (cAliasSD1)->(D1_VALDESC)
			VQ3->VQ3_CUSDEV += (cAliasSD1)->(D1_CUSTO)
		elseif Alltrim((cAliasSD1)->(F2_PREFORI)) == Alltrim(GetNewPar("MV_PREFBAL","BAL"))
			VQ3->VQ3_DEVBAL += (cAliasSD1)->(D1_TOTAL) - (cAliasSD1)->(D1_VALDESC)
			VQ3->VQ3_CUSDEV += (cAliasSD1)->(D1_CUSTO)
		endif
		msunlock()
		//
		DBSelectArea("SD1")
		DBGoTo((cAliasSD1)->(RECSD1))
		reclock("SD1",.f.)
		SD1->D1_FLGNAT := 'A'
		msunlock()

		(cAliasSD1)->(DBSkip())
	enddo
	(cAliasSD1)->(DBCloseArea())
next

cFilAnt := cFilBkp

oLogger:Log( {"Execucao Completa"+ " ("+time()+")"} )
oLogger:Log( {"############################################################################"} )
oLogger:CloseOpened(cTblLogCod) // fecha log de execução

UnLockByName("OFINJD12", .T. , .T. , .T. )

return



/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ConsDem    | Autor |  Vinicius Gati        | Data | 27/10/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FS_ConsDem(cCodSit)
	If empty(cCodSit)
		return .T.
	Endif
	If oDemDpm:isRecompra(cCodSit)
		return .F.
	EndIf
	If oDemDpm:isEspecial(cCodSit) // se for especial não considera na demanda, a funcao abaixo é só pra quando nao considerar demanda se for especial soma hits e imedb
		return .F.
	Endif
	If oDemDpm:ConsDemanda(cCodSit)
		return .T.
	Endif
Return .F.

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Função    | FS_isEspecial | Autor |  Vinicius Gati     | Data | 27/10/14 |##
##+----------+---------------+-------+--------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FS_isEspecial(cCodSit)
return oDemDpm:isEspecial(cCodSit)


Static Function FS_PosVq3(cB1Cod, cAno, cMes, cDia, cStock)
	local cQuery := " "
	local nRes   := -1
	cQuery += " SELECT R_E_C_N_O_ "
	cQuery += "   FROM "+RetSQLName('VQ3')
	cQuery += "  WHERE VQ3_FILIAL = '"+xFilial('VQ3')+"' "
	cQuery += "    AND VQ3_PRODUT = '"+cB1Cod+"' "
	cQuery += "    AND VQ3_ANO    = '"+cAno+"' "
	cQuery += "    AND VQ3_MES    = '"+cMes+"' "
	cQuery += "    AND VQ3_DIA    = '"+cDia+"' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery += oSqlHlp:TopFunc(cQuery, 1)
	nRes := FM_SQL(cQuery)

  DBSelectArea('SB1')
	DbSetOrder(1)
	MsSeek(xFilial('SB1')+cB1Cod)

	if nRes > 0
		DBSelectArea('VQ3')
		DbSetOrder(1)
		DbGoTo(nRes)
		reclock("VQ3", .F.)
	else
		reclock("VQ3", .T.)
		VQ3->VQ3_FILIAL := xFilial("VQ3")
		VQ3->VQ3_PRODUT := cB1Cod
		VQ3->VQ3_CRICOD := SB1->B1_CRICOD
		VQ3->VQ3_ANO    := cAno
		VQ3->VQ3_MES    := cMes
		VQ3->VQ3_DIA    := cDia
		VQ3->VQ3_STOCK  := cStock  // criar campo no SB1 ( Peça Estocada (S) ou Não Estocada (N) )
		VQ3->VQ3_TIPREG := "N"
		VQ3->VQ3_PROCES := "N"
	endif
Return .T.


Static Function FS_GrvUltVda(cB1Cod, cAno, cMes, cDia)
	// -------------------------------------------------------------------------------------
	// PASSO E : Grava ULTIMA VENDA PARA BALCÃO
	// -------------------------------------------------------------------------------------
	if Alltrim(cDadosProd) == "SBZ" // PARA QUEM USA SBZ
		if nBZULTVDA > 0
			if SBZ->(DBSeek(xFilial("SBZ")+Alltrim(cB1Cod)))
				if SBZ->BZ_ULTVDA < stod(cAno+cMes+cDia)
					DBSelectArea("SBZ")
					reclock("SBZ",.f.)
					SBZ->BZ_ULTVDA := stod(cAno+cMes+cDia)
					msunlock()
				endif
			endif
		endif
	else // PARA QUEM USA SB5
		if nB5ULTVDA > 0
			if SB5->(DBSeek(xFilial("SB5")+Alltrim(cB1Cod)))
				if SB5->B5_ULTVDA < stod(cAno+cMes+cDia)
					DBSelectArea("SB5")
					reclock("SB5",.f.)
					SB5->B5_ULTVDA := stod(cAno+cMes+cDia)
					msunlock()
				endif
			endif
		endif
	endif
Return .T.
