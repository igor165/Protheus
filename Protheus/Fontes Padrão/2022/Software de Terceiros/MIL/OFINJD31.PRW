#include "tbiconn.ch"
#include "PROTHEUS.CH"
#include "OFINJD31.ch"

/// FLAGS_DISPONIVEIS = C|H|N|Q|S|T|U|V|X
//touch 20191127


/*/{Protheus.doc} OFINJD31
	Geração de dados diária para o DPM John Deere
	
	@type function
	@author Vinicius Gati
	@since 27/08/2013
/*/
function OFINJD31(aParam, lSoGer)
	BatchProcess("Processamento diário DPM","Este processo funciona via agendador, um processo que é usado para gerar dados para o DPM.",,{ || PROCESSO(aParam, lSoGer) })
return .t.

/*/{Protheus.doc} SchedDef
	Funo padro scheduler

	@author Vinicius Gati
	@since 02/12/2019
	@type function
/*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"",;
	"",;
	"",;
	"" ;
	}
Return aParam

/*/{Protheus.doc} PROCESSO
	Processamento

	@type function
	@author Vinicius Gati
	@since 02/12/2019
/*/
Function PROCESSO(aParam, lSoGer)
Local nCont
Local cQuery      := ""
Local cFilBkp
Local aFilAtu
Private cSQLPedNF    := "SQLPNF"
Private cSQLSD2Abe   := "SQLD2A"
Private cSQLVdaPer   := "SQLVDP"
Private aDtReproc    := {}
Private oLogger      := nil
Private oLogDebug    := nil
Private cTblLogCod   := ""
Private cInGrupos    := ""
Private cDadosProd   := GetNewPar("MV_MIL0054","SBZ")
Private cMotVdaPer   := Alltrim(GetNewPar("MV_MIL0032","000002"))
Private oSqlHlp      := DMS_SqlHelper():New()
Private oDs          := DMSB_DirectShipment():New()
Private oDpePecas    := DMSB_DpePecas():New()
Private oDemDpm      := DMS_DemandaDPM():New()
Private oDpm         := DMS_DPM():New()
Private dCorteNA     := GetNewPar("MV_MIL0134", stod('20190701'))
Private lDebug       := .f.
Private lAuto        := FWGetRunSchedule()
cInGrupos := oDpm:GetInGroups()

if lSoGer
	lAuto := .t. 
endif

if !LockByName("OFINJD31" , .T. , .T. , .T. )
	return .t.
endif

if ! oDpm:Ready()
	if ! lAuto
		MsgInfo(oDpm:cLastError, '')
	endif
	Return .F.
endif

oLogger   := DMS_Logger():New("OFINJD31_"    +dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
oLogDebug := DMS_Logger():New("OFINJD31_DBG_"+dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
lDebug    := oDpm:DebugMode()

conout("OFINJD31 -> Iniciando rotina <-")
if lDebug
	conout("OFINJD31 -> Modo debug ativado <-")
endif

If lAuto
	oLogger:Log({'TIMESTAMP', "OFINJD31 rodado em modo agendado data: " + DTOS(dDatabase) + "("+FWTimeStamp(5)+")"})
	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD31'        },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'    },;
		{'VQL_DADOS'      , 'MODO: Agendado'  } ;
	})
Else
	oLogger:Log({'TIMESTAMP', "OFINJD31 rodado em modo   normal data: " + DTOS(dDatabase) + "("+FWTimeStamp(5)+")"})
	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD31'      },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'  },;
		{'VQL_DADOS'      , 'MODO: Normal'  } ;
	})
EndIf

aFilAtu   := FWArrFilAtu()
cFilBkp   := cFilAnt

nBZPRIENT := SBZ->(FieldPos("BZ_PRIENT"))

DBSelectArea("SB5")
DBSetOrder(1)
DBSelectArea("SF1")
DBSetOrder(1)
DBSelectArea("SD1")
DBSetOrder(3)
DBGoTop()
DBSelectArea("VB8")
DBSetOrder(1)
DBSelectArea("SB1")
DBSetOrder(7)
DBSelectArea("SF2")
DBSetOrder(1)
DBSelectArea("VS3")
DBSetOrder(1)

aFilis  := {}
aFilis2 := {}

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

// Coleta das peças e atualização das peças direct shipment
// importante que seja após a criação dos SB5 por conta de peças que não tenham o cadastro completo
oDS:AtualizarPecas()
oDpePecas:ColetaItensDia()
//
For nCont := 1 to Len(aFilis)
	cFilAnt := aFilis[nCont,1]
	if EMPTY(cFilAnt)
		oLogger:Log( {"Filial em branco detectada, pulando"+ " ("+FWTimeStamp(5)+")"} )
		loop
	end
	cDadosProd := GetNewPar("MV_MIL0054","SBZ")

	if Alltrim(cDadosProd) == "SBZ"
		// ==============================================
		// CRIA SBZ PARA TODOS OS SB1
		// ==============================================
		cSQLDTADD := GetNextAlias()
		cQuery := "SELECT B1_COD FROM " + RetSQLName("SB1")
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND"
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
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ =  ' ' "
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SBZ") + " ON BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_COD = D1_COD AND SBZ.D_E_L_E_T_ =  ' ' AND BZ_PRIENT = ' ' "
		cQuery += " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY SBZ.R_E_C_N_O_"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLDTADD , .F. , .T. )
		DBSelectArea("SBZ")
		While !(cSQLDTADD)->(Eof())
			DbGoTo((cSQLDTADD)->(BZRECNO))
			reclock("SBZ",.f.)
			SBZ->BZ_PRIENT := stod((cSQLDTADD)->(ENTRADA))
			msunlock()
			(cSQLDTADD)->(DBSkip())
		enddo
		(cSQLDTADD)->(DBCloseArea())
		// ==============================================
		// LEVANTAMENTO ULTVDA BASEADO NO VB8
		// ==============================================
		cSQLDTADD := GetNextAlias()
		cQuery := "SELECT SBZ.R_E_C_N_O_ BZRECNO, MAX(VB8_ANO "+FG_CONVSQL("CONCATENA")+" VB8_MES "+FG_CONVSQL("CONCATENA")+" VB8_DIA) ULTVDA FROM " + oSqlHlp:NoLock("VB8")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SBZ") + " ON BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_COD = VB8_PRODUT AND SBZ.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VB8_ANO > '1970' AND (VB8_VDAB > 0 OR VB8_VDAO > 0 ) AND VB8_FILIAL = '"+xFilial("VB8")+"' AND VB8.D_E_L_E_T_ =  ' '"
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
	End

	// ==============================================
	// CRIA SB5 PARA TODOS OS SB1
	// ==============================================
	cSQLDTADD := GetNextAlias()
	cQuery := "SELECT B1_COD FROM " + oSqlHlp:NoLock("SB1")
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
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ =  ' '"
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
		// LEVANTAMENTO ULTVDA BASEADO NO VB8
		// ==============================================
		cSQLDTADD := GetNextAlias()
		cQuery := "SELECT SB5.R_E_C_N_O_ B5RECNO, MAX(VB8_ANO "+FG_CONVSQL("CONCATENA")+" VB8_MES "+FG_CONVSQL("CONCATENA")+" VB8_DIA) ULTVDA FROM " + oSqlHlp:NoLock("VB8")
		cQuery += " INNER JOIN " + oSqlHlp:NoLock("SB5") + " ON B5_FILIAL = '"+xFilial("SB5")+"' AND B5_COD = VB8_PRODUT AND SB5.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VB8_ANO > '1970' AND (VB8_VDAB > 0 OR VB8_VDAO > 0 ) AND VB8_FILIAL = '"+xFilial("VB8")+"' AND VB8.D_E_L_E_T_ =  ' '"
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
		//
	endif
next

oArHelp   := DMS_ArrayHelper():New()

// collects the cancelled invoice dates 
cQuery := ""
cQuery += " select distinct D2_EMISSAO "
cQuery += "   from "+oSqlHlp:NoLock("SD2")
cQuery += "  where D_E_L_E_T_ = '*' "
cQuery += "    and D2_FLGNAT  <> ' ' "
cQuery += "    and D2_FLGNAT  <> 'X' "
cQuery += "    and D2_FLGNAT  <> 'C' "
cQuery += "    and D2_EMISSAO >= '"+dtos(ddatabase-60)+"' "
cQuery += "    and D2_EMISSAO <  '"+dtos(ddatabase)+"' "

aDtReproc := oSqlHlp:GetSelectArray(cQuery)
for nCont := 1 to len(aDtReproc)
	oDpm:ClrDemanda( stod(aDtReproc[nCont]) )
next

// flagging the cancelled invoices as processed
cQuery := ""
cQuery += " update "+RetSqlName('SD2')
cQuery += "    set D2_FLGNAT  = 'X' "
cQuery += "  where D_E_L_E_T_ = '*' "
cQuery += "    and D2_FLGNAT  <> 'X' "
cQuery += "    and D2_FLGNAT  <> 'C' "
cQuery += "    and D2_EMISSAO >= '"+dtos(ddatabase-60)+"' "
cQuery += "    and D2_EMISSAO <  '"+dtos(ddatabase)+"' "
if TcSqlExec(cQuery) < 0
	conout("Erro ao gravar D2_FLGNAT: " + TCSQLError())
endif

// =====================================
// Reprocessamento de NA oficina e pecas
// =====================================

// ordens de servico
//aOssToRep := oDpm:OssToReproc()

// orcamentos
aOrcToRep := oDpm:OrcsToReproc()
oArHelp:Map(aOrcToRep, {|oEl| oDpm:ResetDemOrc(oEl:GetValue('VQL_FILORI'), oEl:GetValue('VQL_DADOS')) })

TcSqlExec(" UPDATE " + RetSQLName('VQL') + " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VQL_AGROUP = 'OFINJD31' AND VQL_TIPO IN ('REPROC_OS', 'REPROC_ORC') ")

dDataCorte := dDatabase - 90 // 90 dias atrás, usado para limpar dados no fim do programa


// ==============================================
// LEVANTAMENTO PARA NIVEL DE ATENDIMENTO OFICINA
// ==============================================
oLogger:Log( {"Calculando Nivel de Atendimento Oficina"+ " ("+FWTimeStamp(5)+")"} )

For nCont := 1 to Len(aFilis)
	cFilAnt    := aFilis[nCont,1]
	
	oLogger:Log( {cFilAnt+ " iniciando em: ("+FWTimeStamp(5)+")"} )

	cAl    := GetNextAlias()
	cQuery := " "
	cQuery += "      SELECT VSJ.R_E_C_N_O_ CODIGO, VSJ_CODSIT, VSJ_FATPAR, VSJ_LOJA, B1_COD, B1_CRICOD, VSJ_QTDINI, VSJ_DATREQ, BM_PROORI, VSJ_QESTNA "
	cQuery += "        FROM " + oSqlHlp:NoLock("VSJ") 
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE      = VSJ_CODITE    AND B1_GRUPO   = VSJ_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL  = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO   = SBM.BM_GRUPO  AND BM_GRUPO IN " + oDpm:GetInGroups() + " AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "       WHERE VSJ_FILIAL = '"+xFilial('VSJ')+"' AND VSJ_ORIDAD = '4' AND VSJ_FLGNAT = ' ' AND VSJ_MOTPED = '"+GetNewPar("MV_MIL0108","000002")+"' AND VSJ.D_E_L_E_T_ =  ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )

	While !(cAl)->(Eof())
		if (cAl)->(VSJ_QESTNA) == 0
			cStock := "N"
		else
			cStock := "S"
		endif
		If FS_ConsDem( (cAl)->(VSJ_CODSIT) )

			oDados := DMS_DataContainer():New({;
				{'VB8_FILIAL' , xFilial('VB8')                           },;
				{'VB8_PRODUT' , (cAl)->(B1_COD)                          },;
				{'VB8_CRICOD' , (cAl)->(B1_CRICOD)                       },;
				{'VB8_CODCLI' , (cAl)->(VSJ_FATPAR)                      },;
				{'VB8_LOJCLI' , (cAl)->(VSJ_LOJA)                        },;
				{'VB8_ANO'    , Left((cAl)->(VSJ_DATREQ),4)              },;
				{'VB8_MES'    , Subs((cAl)->(VSJ_DATREQ),5,2)            },;
				{'VB8_DIA'    , Subs((cAl)->(VSJ_DATREQ),7,2)            },;
				{'VB8_LOCAL'  , IIF((cAl)->(BM_PROORI) == "1","D1","N1") },;
				{'VB8_TIPLOC' , IIF((cAl)->(BM_PROORI) == "1","M","N")   },;
				{'VB8_STOCK'  , cStock                                   },;
				{'VB8_TIPREG' , "N"                                      },;
				{'VB8_PROCES' , "N"                                      } ;
			})

			oDem := DMS_DataContainer():New({;
				{'VB8_VDPERO' , (cAl)->(VSJ_QTDINI) },;
				{'VB8_HIPERO' , 1                   } ;
			})

			cCod := ONJD3101_GravaDem(oDados, oDem)
			if lDebug
				oLogDebug:Log({'31A|' + cFilAnt + " " + cCod + '| VSJ RECNO ' + cvaltochar((cAl)->(CODIGO))})
			endif
		EndIf

		VSJ->(DbGoTo((cAl)->(CODIGO)))
		reclock('VSJ', .F.)
		VSJ->VSJ_FLGNAT := 'R'
		VSJ->(msunlock())

		(cAl)->(DBSkip())
	enddo
	(cAl)->(dbCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+ " termino primeira peneira de dados : ("+FWTimeStamp(5)+")"} )

	//
	// Nivel Atendimento oficina via orcamento por fases
	//
	//
	cAl    := GetNextAlias()
	cQuery := " "
	cQuery += "      SELECT SD2.R_E_C_N_O_ CODIGO, VOO_LOJA, VOO_FATPAR, VS3.R_E_C_N_O_ CODIGO2, VS3_CODSIT, D2_COD, B1_COD, B1_CRICOD, D2_CLIENTE, D2_LOJA, D2_EMISSAO, BM_PROORI, D2_TOTAL, D2_CUSTO1, D2_QUANT, VS3_QESTNA, VS3_QTDINI "
	cQuery += "        FROM " + oSqlHlp:NoLock("SD2") + " "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_COD        = D2_COD        AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL  = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO  = SBM.BM_GRUPO  AND BM_VAIDPM = '1'         AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VOO") + " ON VOO_FILIAL = '"+xFilial('VOO')+"' AND VOO_NUMNFI    = D2_DOC        AND VOO_SERNFI = D2_SERIE   AND VOO_TOTPEC     > 0      AND VOO.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VS1") + " ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMOSV    = VOO_NUMOSV    AND VS1_TIPORC = '2'        AND VS1_TIPTEM = VOO_TIPTEM AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VS3") + " ON VS3_FILIAL = VS1_FILIAL           AND VS3_NUMORC    = VS1_NUMORC    AND VS3_CODITE = B1_CODITE  AND VS3.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SF4") + " ON F4_FILIAL  = '"+xFilial("SF4")+"' AND SD2.D2_TES    = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "       WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D2_COD = B1_COD AND D2_QUANT > 0 AND D2_FLGNAT = ' ' AND VS3_MOTPED = ' ' AND SD2.D_E_L_E_T_ = ' ' "
	// essa data de corte foi adicionada para reduzir problemas com clientes que entrarem no NA oficina evitando que os dados antigos sejam processados como novos
	// só me preocupa isso com o reprocessamento de demanda... mas se fizer e com essa data de corte vai dar certo pois irá entrar no d2 simples, ultima query
	cQuery += "         AND VS1_DATORC > '"+dtos(dCorteNA)+"' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )

	While !(cAl)->(Eof())

		DBSelectArea("SD2")
		DBGoTo( (cAl)->(CODIGO) )
		if ! Empty(SD2->D2_FLGNAT)
			(cAl)->(DBSkip())
			loop
		endif

		if (cAl)->(VS3_QESTNA) == 0
			cStock := "N"
		else
			cStock := "S"
		endif

		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial('VB8') },;
			{'VB8_PRODUT' , (cAl)->(B1_COD)},;
			{'VB8_CODCLI' , (cAl)->(VOO_FATPAR)},;
			{'VB8_LOJCLI' , (cAl)->(VOO_LOJA)},;
			{'VB8_CRICOD' , (cAl)->(B1_CRICOD)},;
			{'VB8_ANO'    , Left((cAl)->(D2_EMISSAO),4)},;
			{'VB8_MES'    , Subs((cAl)->(D2_EMISSAO),5,2)},;
			{'VB8_DIA'    , Subs((cAl)->(D2_EMISSAO),7,2)},;
			{'VB8_LOCAL'  , IIF((cAl)->(BM_PROORI) == "1","D1","N1")},;
			{'VB8_TIPLOC' , IIF((cAl)->(BM_PROORI) == "1","M","N")},;
			{'VB8_STOCK'  , cStock},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_PROCES' , "N"};
		})

		oDem := DMS_DataContainer():New({})

		If FS_ConsDem( (cAl)->(VS3_CODSIT) )
			oDem := DMS_DataContainer():New({;
				{'VB8_TOTOFI' , (cAl)->(D2_TOTAL)  },;
				{'VB8_CUSOFI' , (cAl)->(D2_CUSTO1) },;
				{'VB8_HITSO'  , 1                  },;
				{'VB8_VDAO'   , (cAl)->(D2_QUANT)  };
			})
			if (cAl)->(VS3_QESTNA) >= (cAl)->(VS3_QTDINI) .and. cStock == "S"
				oDem:SetValue('VB8_IMEDO', 1)
			endif
		ElseIf FS_isEspecial( (cAl)->(VS3_CODSIT) )
			oDem := DMS_DataContainer():New({;
				{'VB8_TOTOFN' , (cAl)->(D2_TOTAL)  },;
				{'VB8_CUSOFN' , (cAl)->(D2_CUSTO1) },;
				{'VB8_HITSON' , 1                  },;
				{'VB8_VDAON'  , (cAl)->(D2_QUANT)  } ;
			})
			if (cAl)->(VS3_QESTNA) >= (cAl)->(VS3_QTDINI) .and. cStock == "S"
				oDem:SetValue('VB8_IMEDON', 1)
			endif
		EndIf

		cCod := ONJD3101_GravaDem(oDados, oDem)
		if lDebug
			oLogDebug:Log({'31B|' + cFilAnt +" "+ cCod + '| SD2 RECNO ' + cvaltochar((cAl)->(CODIGO)) + '| VS3 RECNO ' + cvaltochar((cAl)->(CODIGO2))})
		endif

		VS3->(DbGoTo((cAl)->(CODIGO2)))
		reclock("VS3", .F.)
		if VS3->VS3_FLGNAT == '!'
			VS3->VS3_FLGNAT := 'Z'
		else
			VS3->VS3_FLGNAT := 'O'
		endif
		VS3->(msunlock())

		SD2->(DbGoTo((cAl)->(CODIGO)))
		reclock("SD2", .F.)
		SD2->D2_FLGNAT := 'P'
		SD2->(msunlock())

		(cAl)->(DBSkip())
	enddo
	(cAl)->(DbCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+ " termino segunda peneira de dados : ("+FWTimeStamp(5)+")"} )

	//
	// Nível de atendimento oficina faturados
	//
	cAl    := GetNextAlias()

	cQuery := " SELECT VSJ.R_E_C_N_O_ CODIGO_VSJ, VOO.R_E_C_N_O_ CODIGO_VOO, SD2.R_E_C_N_O_ CODIGO_SD2, VSJ_CODSIT, B1_COD, B1_CRICOD, "
	cQuery += "        D2_CLIENTE, D2_LOJA, D2_EMISSAO, D2_TOTAL, D2_CUSTO1, D2_QUANT, D2_DOC, D2_SERIE, VSJ_QESTNA, BM_PROORI, VSJ_QESTNA, VSJ_QTDINI "
	cQuery += "  FROM "+oSqlHlp:NoLock('SD2')
	cQuery += "  JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_COD     = D2_COD     AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('SBM')+" ON BM_FILIAL  = '"+xFilial("SBM")+"' AND B1_GRUPO   = BM_GRUPO   AND BM_GRUPO IN " + oDpm:GetInGroups() + " AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('VEC')+" ON VEC_FILIAL = '"+xFilial('VEC')+"' AND VEC_NUMNFI = D2_DOC     AND VEC_SERNFI = D2_SERIE   AND VEC.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('VOO')+" ON VOO_FILIAL = '"+xFilial('VOO')+"' AND VOO_NUMOSV = VEC_NUMOSV AND VOO_TIPTEM = VEC_TIPTEM AND D2_COD = VEC_CODITE AND VOO.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('VO3')+" ON VO3_FILIAL = '"+xFilial('VO3')+"' AND VO3_VECREL = VEC_NUMREL AND VO3_CODITE = VEC_CODITE AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+oSqlHlp:NoLock('VSJ')+" ON VSJ_FILIAL = '"+xFilial('VSJ')+"' AND VSJ_CODITE = D2_COD     AND VSJ_CODITE = VO3_CODITE AND VO3_CODVSJ = VSJ_CODIGO AND VSJ.D_E_L_E_T_ =  ' ' "
	cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuery += "   AND D2_FLGNAT  = ' ' "
	cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY VSJ.R_E_C_N_O_, VOO.R_E_C_N_O_, SD2.R_E_C_N_O_, VSJ_CODSIT, B1_COD, B1_CRICOD, "
	cQuery += "          D2_CLIENTE, D2_LOJA, D2_EMISSAO, D2_TOTAL, D2_CUSTO1, D2_QUANT, D2_DOC, D2_SERIE, VSJ_QESTNA, BM_PROORI, VSJ_QESTNA, VSJ_QTDINI"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )

	While !(cAl)->(Eof())
		if (cAl)->(VSJ_QESTNA) == 0
			cStock := "N"
		else
			cStock := "S"
		endif

		DBSelectArea("SD2")
		DBGoTo( (cAl)->(CODIGO_SD2) )
		if ! Empty(SD2->D2_FLGNAT)
			(cAl)->(DBSkip())
			loop
		endif

		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial('VB8')                           },;
			{'VB8_PRODUT' , (cAl)->(B1_COD)                          },;
			{'VB8_CRICOD' , (cAl)->(B1_CRICOD)                       },;
			{'VB8_CODCLI' , (cAl)->(D2_CLIENTE)                      },;
			{'VB8_LOJCLI' , (cAl)->(D2_LOJA)                         },;
			{'VB8_ANO'    , Left((cAl)->(D2_EMISSAO),4)              },;
			{'VB8_MES'    , Subs((cAl)->(D2_EMISSAO),5,2)            },;
			{'VB8_DIA'    , Subs((cAl)->(D2_EMISSAO),7,2)            },;
			{'VB8_LOCAL'  , IIF((cAl)->(BM_PROORI) == "1","D1","N1") },;
			{'VB8_TIPLOC' , IIF((cAl)->(BM_PROORI) == "1","M","N")   },;
			{'VB8_STOCK'  , cStock                                   },;
			{'VB8_TIPREG' , "N"                                      },;
			{'VB8_PROCES' , "N"                                      } ;
		})

		oDem := DMS_DataContainer():New({})

		If FS_ConsDem( (cAl)->(VSJ_CODSIT) )
			oDem := DMS_DataContainer():New({;
				{'VB8_TOTOFI' , (cAl)->(D2_TOTAL)  },;
				{'VB8_CUSOFI' , (cAl)->(D2_CUSTO1) },;
				{'VB8_HITSO'  , 1                  },;
				{'VB8_VDAO'   , (cAl)->(D2_QUANT)  };
			})
			if (cAl)->(VSJ_QESTNA) >= (cAl)->(VSJ_QTDINI) .and. cStock == "S"
				oDem:SetValue('VB8_IMEDO', 1)
			endif
		ElseIf FS_isEspecial( (cAl)->(VSJ_CODSIT) )
			oDem := DMS_DataContainer():New({;
				{'VB8_TOTOFN' , (cAl)->(D2_TOTAL)  },;
				{'VB8_CUSOFN' , (cAl)->(D2_CUSTO1) },;
				{'VB8_HITSON' , 1                  },;
				{'VB8_VDAON'  , (cAl)->(D2_QUANT)  } ;
			})
			if (cAl)->(VSJ_QESTNA) >= (cAl)->(VSJ_QTDINI) .and. cStock == "S"
				oDem:SetValue('VB8_IMEDON', 1)
			endif
		EndIf

		cCod := ONJD3101_GravaDem(oDados, oDem)

		if lDebug
			oLogDebug:Log({'31C|' + cFilAnt +" "+ cCod + '| VSJ RECNO ' + cvaltochar((cAl)->(CODIGO_VSJ)) + '| VOO RECNO ' + cvaltochar((cAl)->(CODIGO_VOO)) + '| SD2 RECNO ' + cvaltochar((cAl)->(CODIGO_SD2))})
		endif

		VSJ->(DbGoTo((cAl)->(CODIGO_VSJ)))
		reclock('VSJ', .F.)
		VSJ->VSJ_FLGNAT := 'A'
		VSJ->(msunlock())

		VOO->(DbGoTo((cAl)->(CODIGO_VOO)))
		reclock('VOO', .F.)
		VOO->VOO_FLGNAT := 'A'
		VOO->(msunlock())

		SD2->(DbGoTo((cAl)->(CODIGO_SD2)))
		reclock('SD2', .F.)
		SD2->D2_FLGNAT := 'A'
		SD2->(msunlock())

		(cAl)->(DBSkip())
	enddo
	(cAl)->(dbCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+ " termino terceira peneira de dados : ("+FWTimeStamp(5)+")"} )

	//
	// Vendas perdidas oficina via orcamento por fases
	//
	cAl    := GetNextAlias()
	cQuery := " "
	cQuery += "      SELECT VS3.R_E_C_N_O_ CODIGO, VS3_CODSIT, B1_COD, B1_CRICOD, VS1_CLIFAT, VS1_LOJA, VS1_DATORC, VS3_QTDINI, VS3_QTDITE, BM_PROORI "
	cQuery += "        FROM " + oSqlHlp:NoLock("VS1")
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("VS3") + " ON VS3_FILIAL = VS1_FILIAL           AND VS3_NUMORC    = VS1_NUMORC AND VS3.VS3_GRUITE IN " + oDpm:GetInGroups() + " AND VS3.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE     = VS3_CODITE AND B1_GRUPO   = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL  = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO  = SBM.BM_GRUPO    AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "       WHERE VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_TIPORC = '2' AND VS3_FLGNAT IN (' ', '!') AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "         AND ( VS3_MOTPED = '"+GetNewPar("MV_MIL0108","000002")+"' OR VS1_MOTIVO = '"+GetNewPar("MV_MIL0108","000002")+"') "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )

	While !(cAl)->(Eof())

		If FS_ConsDem( (cAl)->(VS3_CODSIT) )	
			oDados := DMS_DataContainer():New({;
				{'VB8_FILIAL' , xFilial('VB8')                           },;
				{'VB8_PRODUT' , (cAl)->(B1_COD)                          },;
				{'VB8_CRICOD' , (cAl)->(B1_CRICOD)                       },;
				{'VB8_CODCLI' , (cAl)->(VS1_CLIFAT)                      },;
				{'VB8_LOJCLI' , (cAl)->(VS1_LOJA)                        },;
				{'VB8_ANO'    , Left((cAl)->(VS1_DATORC),4)              },;
				{'VB8_MES'    , Subs((cAl)->(VS1_DATORC),5,2)            },;
				{'VB8_DIA'    , Subs((cAl)->(VS1_DATORC),7,2)            },;
				{'VB8_LOCAL'  , IIF((cAl)->(BM_PROORI) == "1","D1","N1") },;
				{'VB8_TIPLOC' , IIF((cAl)->(BM_PROORI) == "1","M","N")   },;
				{'VB8_STOCK'  , "S"                                      },;
				{'VB8_TIPREG' , "N"                                      },;
				{'VB8_PROCES' , "N"                                      } ;
			})

			oDem := DMS_DataContainer():New({;
				{'VB8_VDPERO' , (cAl)->(VS3_QTDITE) },;
				{'VB8_HIPERO' , 1                   } ;
			})

			ONJD3101_GravaDem(oDados, oDem)
		EndIf

		VS3->(DbGoTo((cAl)->(CODIGO)))
		reclock('VS3', .F.)
		if VS3->VS3_FLGNAT == '!' // nao sei o que significa o !, entao pra oficina tive que tratar para nao afetar o resto do DPM
			VS3->VS3_FLGNAT := 'Z'
		else
			VS3->VS3_FLGNAT := 'R'
		endif
		VS3->(msunlock())

		(cAl)->(DBSkip())
	enddo
	(cAl)->(DbCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+ " termino quarta peneira de dados : ("+FWTimeStamp(5)+")"} )

	// -------------------------------------------------------------------------------------
	// PASSO I : Essa query serve para garantir que nenhuma nota fique de fora. Ela pega todas
	//           as notas que ainda não foram flagadas e cria um registro padrão de demanda
	// -------------------------------------------------------------------------------------
	cQuery := " SELECT SD2.R_E_C_N_O_ RECNOSD2, SD2.D2_CLIENTE, SD2.D2_LOJA,"
	cQuery += " SB1.B1_COD,"
	cQuery += " SB1.B1_CRICOD,"
	cQuery += " SB1.B1_LOCPAD,"
	cQuery += " SBM.BM_PROORI,"
	cQuery += " SD2.D2_EMISSAO,"
	cQuery += " SD2.D2_TOTAL,"
	cQuery += " SD2.D2_QUANT,"
	cQuery += " SD2.D2_PRCVEN,"
	cQuery += " SD2.D2_DESC,"
	cQuery += " SD2.D2_CUSTO1, "
	cQuery += " SF4.F4_ESTOQUE, "
	cQuery += " SF4.F4_OPEMOV "
	cQuery += " FROM "+ oSqlHlp:NoLock("SD2")
	cQuery += " JOIN " + oSqlHlp:NoLock("SF2") + " ON F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC  = D2_DOC AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND D2_COD  = B1_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  AND B1_GRUPO IN " + cInGrupos
	cQuery += " JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SF4") + " ON F4_FILIAL = '"+xFilial("SF4")+"' AND D2_TES = F4_CODIGO  AND  SF4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE F2_PREFORI = '"+GetNewPar("MV_PREFOFI","OFI")+"' AND D2_FILIAL ='"+xFilial("SD2")+"' AND D2_FLGNAT = ' ' AND D2_QUANT > 0  AND SD2.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLPedNF , .F. , .T. )

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
		
		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial('VB8')},;
			{'VB8_PRODUT' , (cSQLPedNF)->(B1_COD)},;
			{'VB8_CRICOD' , (cSQLPedNF)->(B1_CRICOD)},;
			{'VB8_CODCLI' , (cSQLPedNF)->(D2_CLIENTE)},;
			{'VB8_LOJCLI' , (cSQLPedNF)->(D2_LOJA)},;
			{'VB8_ANO'    , Left((cSQLPedNF)->(D2_EMISSAO),4)},;
			{'VB8_MES'    , Subs((cSQLPedNF)->(D2_EMISSAO),5,2)},;
			{'VB8_DIA'    , Subs((cSQLPedNF)->(D2_EMISSAO),7,2)},;
			{'VB8_LOCAL'  , IIF((cSQLPedNF)->(BM_PROORI) == "1","D1","N1")},;
			{'VB8_TIPLOC' , IIF((cSQLPedNF)->(BM_PROORI) == "1","M","N")},;
			{'VB8_STOCK'  , "S"},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_PROCES' , "N"};
		})
		// -------------------------------------------------------------------------------------
		// PASSO N : Baseado nos levantamentos, grava todas as informações faltantes no VB8
		// -------------------------------------------------------------------------------------
		oDem := DMS_DataContainer():New({;
			{'VB8_HITSO'  , 1},;
			{'VB8_TOTOFI' , (cSQLPedNF)->(D2_TOTAL) },;
			{'VB8_CUSOFI' , (cSQLPedNF)->(D2_CUSTO1)},;
			{'VB8_VDAO'   , (cSQLPedNF)->(D2_QUANT) },;
			{'VB8_IMEDO'  , 1} ; // notas avulsas feitas fora do padrão serão sempre 100% nivel de atendimento
		})

		cCod := ONJD3101_GravaDem(oDados, oDem)
		if lDebug
			oLogDebug:Log({'31D|' + cFilAnt + " " + cCod + ' | SD2 RECNO ' + cvaltochar((cSQLPedNF)->(RECNOSD2))})
		endif
		// -------------------------------------------------------------------------------------
		// PASSO O : Marca as tabelas VOO e SD2 como tratadas
		// -------------------------------------------------------------------------------------
		DBSelectArea("SD2")
		DBGoTo( (cSQLPedNF)->(RECNOSD2) )
		reclock("SD2",.f.)
		SD2->D2_FLGNAT := "E"
		msunlock()

		(cSQLPedNF)->(DBSkip())
	enddo
	(cSQLPedNF)->(DBCloseArea())

	oLogger:Log( { "     |> " + cFilAnt+ " termino quinta peneira de dados : ("+FWTimeStamp(5)+")"} )
next

oLogger:Log( {"Fim do Calculo de Nivel de Atendimento Oficina ("+FWTimeStamp(5)+")"} )

//
// =============================================
// LEVANTAMENTO PARA NIVEL DE ATENDIMENTO BALCAO
// =============================================
oLogger:Log( {"Calculando Nivel de Atendimento Balcao ("+FWTimeStamp(5)+")"} )

For nCont := 1 to Len(aFilis)
	// Levanta os pedidos que possuem nota emitida mas ainda não foram marcados (FLAGNAT)
	cFilAnt := aFilis[nCont,1]
	cDadosProd := GetNewPar("MV_MIL0054","SBZ")

	JD3100014_AjustaEstoqueNADoDia(dDataBase)
	//
	cQuery := "SELECT DISTINCT"
	cQuery += " VS1O.VS1_NUMNFI NUMNFI,"
	cQuery += " VS1O.VS1_SERNFI SERIE,"
	cQuery += " VS1P.VS1_NUMORC NUMORC,"
	cQuery += " VS1P.VS1_DATORC DATORC"
	cQuery += " FROM "+oSqlHlp:NoLock("VS1", 'VS1P')
	cQuery += " INNER JOIN "+oSqlHlp:NoLock("VS1", 'VS1O')+"  ON VS1P.VS1_FILIAL = VS1O.VS1_FILIAL AND VS1P.VS1_NUMORC = VS1O.VS1_PEDREF  AND VS1O.VS1_PEDREF <> ' '"
	cQuery += " INNER JOIN "+oSqlHlp:NoLock("VS3", 'VS3P')+"  ON VS1P.VS1_FILIAL = VS3P.VS3_FILIAL AND VS1P.VS1_NUMORC = VS3P.VS3_NUMORC  AND VS3P.VS3_MOTPED = ' ' AND VS3P.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VS1O.VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1O.VS1_NUMNFI != ' ' AND VS1O.VS1_TIPORC = '1' AND VS1P.VS1_TIPORC = 'P' AND VS3P.VS3_FLGNAT IN (' ','!')"
	cQuery += " AND VS1P.D_E_L_E_T_ = ' ' AND VS1O.D_E_L_E_T_ = ' ' ORDER BY VS1O.VS1_NUMNFI ASC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLPedNF , .F. , .T. )


	While !(cSQLPedNF)->(Eof())
		// -------------------------------------------------------------------------------------
		// PASSO A : Levanta os itens de orçamento que possuem nota emitida mas ainda não foram marcados (FLAGNAT)
		// -------------------------------------------------------------------------------------
		cQuery := " SELECT "
		cQuery += " VS3.R_E_C_N_O_ VS3RECNO,"
		cQuery += " SD2.R_E_C_N_O_ SD2RECNO,"
		cQuery += " VS3.VS3_FLGNAT,"
		cQuery += " SB1.B1_CRICOD, SD2.D2_CLIENTE, SD2.D2_LOJA,"
		cQuery += " SD2.D2_COD,"
		cQuery += " SD2.D2_EMISSAO,"
		cQuery += " SD2.D2_TOTAL,"
		cQuery += " SD2.D2_QUANT,"
		cQuery += " SD2.D2_PRCVEN,"
		cQuery += " SD2.D2_DESC,"
		cQuery += " SD2.D2_CUSTO1, "
		cQuery += " VS3.VS3_QESTNA, "
		cQuery += " VS3.VS3_QTDELI, "
		cQuery += " VS3.VS3_CODSIT, "
		cQuery += " VS3.VS3_QTDINI, "
		cQuery += " SBM.BM_PROORI, "
		cQuery += " SF4.F4_ESTOQUE, "
		cQuery += " SF4.F4_OPEMOV "
		cQuery += " FROM " + oSqlHlp:NoLock("SD2")
		cQuery += " JOIN " + oSqlHlp:NoLock("SB1") + " ON SB1.B1_COD     = SD2.D2_COD                    AND SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "  AND B1_GRUPO IN " + cInGrupos
		cQuery += " JOIN " + oSqlHlp:NoLock("SBM") + " ON SB1.B1_GRUPO   = SBM.BM_GRUPO                  AND SBM.BM_FILIAL  = '"+xFilial("SBM")+"' AND SBM.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + oSqlHlp:NoLock("VS3") + " ON VS3.VS3_NUMORC = '"+ (cSQLPedNF)->(NUMORC) +"' AND VS3.VS3_CODITE = SB1.B1_CODITE AND VS3.VS3_GRUITE = SB1.B1_GRUPO AND VS3.VS3_FILIAL = '"+xFilial("VS3")+"' AND VS3.VS3_FLGNAT IN (' ','!') AND VS3.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + oSqlHlp:NoLock("SF4") + " ON F4_FILIAL      = '"+xFilial("SF4")+"'          AND D2_TES = F4_CODIGO  AND  SF4.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE D2_DOC = '" + (cSQLPedNF)->(NUMNFI) + "' AND D2_SERIE = '" + (cSQLPedNF)->(SERIE) + "'"
		cQuery += " AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
		cQuery += " AND SD2.D_E_L_E_T_ = ' ' AND D2_QUANT > 0 "
		cQuery += " AND SD2.D2_FLGNAT = ' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLSD2Abe , .F. , .T. )


		While !(cSQLSD2Abe)->(Eof())
			// -------------------------------------------------------------------------------------
			// PASSO B : Verificar se já foi computada PRIMEIRA ENTRADA para a peça na tabela SBZ.
			// -------------------------------------------------------------------------------------
			cQuery := "SELECT MIN(D1_DTDIGIT) DTEMISSAO FROM "+oSqlHlp:NoLock("SD1")
			cQuery += " WHERE D1_FILIAL ='" + xFilial("SD1") + "' AND D1_COD='" + (cSQLSD2Abe)->(D2_COD) + "' AND "
			cQuery += " D_E_L_E_T_=' ' "
			if Alltrim(cDadosProd) == "SBZ" // PARA QUEM USA SBZ
				SBZ->(DBSeek( xFilial("SBZ")+(cSQLSD2Abe)->(D2_COD) ))
				if SBZ->(found()) .and. nBZPRIENT > 0
					if Empty(SBZ->BZ_PRIENT)
						cQrySD1 := GetNextAlias()
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
			else  // PARA QUEM USA SB5
				SB5->(DBSeek(xFilial("SB5") + (cSQLSD2Abe)->(D2_COD) ))
				if SB5->(found())
					if Empty(SB5->B5_DTADDED)
						cQrySD1 := GetNextAlias()
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySD1, .F., .T. )
						if !Empty((cQrySD1)->(DTEMISSAO))
							DBSelectArea("SB5")
							reclock("SB5",.f.)
							SB5->B5_DTADDED := stod((cQrySD1)->(DTEMISSAO))
							msunlock()
						endif
						(cQrySD1)->(dbCloseArea())
					endif
				endif
			endif

			DBSelectArea("SD2")
			SD2->(DBGoTo((cSQLSD2Abe)->(SD2RECNO)))
			if !Empty(SD2->D2_FLGNAT)
				oLogger:Log({'TIMESTAMP', "  |> Nota seria processada 2 vezes Num: " + SD2->D2_DOC + " Ser.: " + SD2->D2_SERIE + " Produto: " + SD2->D2_COD})
				(cSQLSD2Abe)->(DBSkip())
				loop
			endif
			// -------------------------------------------------------------------------------------
			// PASSO C : Verifica se o TES movimenta Estoque
			// -------------------------------------------------------------------------------------
			if Alltrim((cSQLSD2Abe)->(F4_ESTOQUE)) != 'S' .or. Alltrim((cSQLSD2Abe)->(F4_OPEMOV)) != '05'
				reclock('SD2', .F.)
				SD2->D2_FLGNAT := 'F'
				SD2->(msunlock())
				(cSQLSD2Abe)->(DBSkip())
				loop
			endif
			if (cSQLSD2Abe)->(VS3_QESTNA) == 0
				cStock := "N"
			else
				cStock := "S"
			endif

			oDados := DMS_DataContainer():New({;
				{'VB8_FILIAL' , xFilial('VB8')},;
				{'VB8_PRODUT' , (cSQLSD2Abe)->(D2_COD)},;
				{'VB8_CRICOD' , (cSQLSD2Abe)->(B1_CRICOD)},;
				{'VB8_CODCLI' , (cSQLSD2Abe)->(D2_CLIENTE)},;
				{'VB8_LOJCLI' , (cSQLSD2Abe)->(D2_LOJA)},;
				{'VB8_ANO'    , Left((cSQLSD2Abe)->(D2_EMISSAO),4)},;
				{'VB8_MES'    , Subs((cSQLSD2Abe)->(D2_EMISSAO),5,2)},;
				{'VB8_DIA'    , Subs((cSQLSD2Abe)->(D2_EMISSAO),7,2)},;
				{'VB8_LOCAL'  , IIF((cSQLSD2Abe)->(BM_PROORI) == "1","D1","N1")},;
				{'VB8_TIPLOC' , IIF((cSQLSD2Abe)->(BM_PROORI) == "1","M","N")},;
				{'VB8_STOCK'  , cStock},;
				{'VB8_TIPREG' , "N"},;
				{'VB8_PROCES' , "N"};
			})

			oDem := DMS_DataContainer():New({})
			if Empty( (cSQLSD2Abe)->(VS3_FLGNAT) ) // .AND.  (cSQLSD2Abe)->(D2_QUANT) > 0 // não foi processado
				if (cSQLSD2Abe)->(D2_QUANT) > 0
					if FS_ConsDem( (cSQLSD2Abe)->(VS3_CODSIT) )
						oDem := DMS_DataContainer():New({;
							{'VB8_TOTBAL', (cSQLSD2Abe)->(D2_TOTAL)  },;
							{'VB8_CUSBAL', (cSQLSD2Abe)->(D2_CUSTO1) },;
							{'VB8_HITSB' , 1                         },;
							{'VB8_VDAB'  , (cSQLSD2Abe)->(D2_QUANT)  } ;
						})
						if (cSQLSD2Abe)->(VS3_QESTNA) >= (cSQLSD2Abe)->(VS3_QTDINI)  .and.  (cSQLSD2Abe)->(VS3_QTDELI) == 0 .and. cStock == "S"
							oDem:SetValue('VB8_IMEDB', 1)
						endif
					else
						If FS_isEspecial( (cSQLSD2Abe)->(VS3_CODSIT) ) // especial soma hits normal, mas só isso
							oDem := DMS_DataContainer():New({;
								{"VB8_HITSBN", 1},;
								{"VB8_VDABN" , (cSQLSD2Abe)->(D2_QUANT) },;
								{"VB8_TOTBAN", (cSQLSD2Abe)->(D2_TOTAL) },;
								{"VB8_CUSBAN", (cSQLSD2Abe)->(D2_CUSTO1)} ;
							})
							if (cSQLSD2Abe)->(VS3_QESTNA) >= (cSQLSD2Abe)->(VS3_QTDINI) .and. (cSQLSD2Abe)->(VS3_QTDELI) == 0 .and. cStock == "S"
								oDem:SetValue('VB8_IMEDBN', 1)
							endif
						EndIf
					endif
				endif
			EndIf

			ONJD3101_GravaDem(oDados, oDem)

			if Empty((cSQLSD2Abe)->(VS3_FLGNAT))
				DBSelectArea("VS3")
				VS3->(DBGoTo((cSQLSD2Abe)->(VS3RECNO)))
				reclock("VS3",.f.)
				VS3->VS3_FLGNAT := "G"
				msunlock()
			endif

			reclock("SD2",.f.)
			SD2->D2_FLGNAT := "G"
			SD2->(msunlock())

			(cSQLSD2Abe)->(DBSkip())
		enddo
		(cSQLSD2Abe)->(DbCloseArea())

		(cSQLPedNF)->(DBSkip())
	enddo
	(cSQLPedNF)->(DbCloseArea())
	// -------------------------------------------------------------------------------------
	// PASSO H : Computar vendas perdidas
	// -------------------------------------------------------------------------------------
	cQuery := " SELECT SBM.BM_PROORI, VS1.VS1_CLIFAT, VS1.VS1_LOJA, VS1.VS1_DATORC DATORC, VS3.R_E_C_N_O_ VS3RECNO, VS3.VS3_QTDITE, VS3.VS3_QTDELI,  VS3.VS3_CODSIT, SB1.B1_COD CODITE, SB1.B1_CRICOD CRICOD "
	cQuery += "   FROM " + oSqlHlp:NoLock("VS3")
	cQuery += "   JOIN " + oSqlHlp:NoLock("VS1") + " ON VS1_FILIAL = '"+xFilial("VS1")+"'  AND VS1_NUMORC   = VS3_NUMORC            AND VS1_FILIAL      = VS3_FILIAL            AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "   JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL  = '"+xFilial("SB1")+"'  AND B1_CODITE    = VS3.VS3_CODITE        AND SB1.B1_GRUPO    = VS3.VS3_GRUITE        AND SB1.D_E_L_E_T_  = ' ' "
	cQuery += "   JOIN " + oSqlHlp:NoLock("SBM") + " ON B1_GRUPO   = SBM.BM_GRUPO          AND BM_FILIAL    = '"+xFilial("SBM")+"'  AND SBM.D_E_L_E_T_  = ' ' "
	cQuery += "  WHERE VS3.VS3_FILIAL  = '"+xFilial("VS3")+"' "
	cQuery += "    AND VS1_TIPORC     = 'P' "
	cQuery += "    AND VS3_QTDELI     <>   0 "
	cQuery += "    AND VS3_FLGNAT     != 'I' AND VS3_FLGNAT     != 'B' AND VS3_FLGNAT != 'C' "
	cQuery += "    AND VS3_MOTPED      = '"+cMotVdaPer+"' "
	cQuery += "    AND VS3.D_E_L_E_T_ = ' '   "
	cQuery += "    AND B1_GRUPO IN " + cInGrupos
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVdaPer , .F. , .T. )
	While !(cSQLVdaPer)->(Eof())
		DBSelectArea("VB8")
		if FS_ConsDem( (cSQLVdaPer)->(VS3_CODSIT) )
			oDados := DMS_DataContainer():New({;
				{'VB8_FILIAL' , xFilial("VB8") },;
				{'VB8_PRODUT' , (cSQLVdaPer)->(CODITE) },;
				{'VB8_CRICOD' , (cSQLVdaPer)->(CRICOD) },;
				{'VB8_CODCLI' , (cSQLVdaPer)->(VS1_CLIFAT) },;
				{'VB8_LOJCLI' , (cSQLVdaPer)->(VS1_LOJA) },;
				{'VB8_ANO'    , Left((cSQLVdaPer)->(DATORC),4) },;
				{'VB8_MES'    , Subs((cSQLVdaPer)->(DATORC),5,2) },;
				{'VB8_DIA'    , Subs((cSQLVdaPer)->(DATORC),7,2) },;
				{'VB8_LOCAL'  , IIF((cSQLVdaPer)->(BM_PROORI) == "1","D1","N1") },;
				{'VB8_TIPLOC' , IIF((cSQLVdaPer)->(BM_PROORI) == "1","M","N") },;
				{'VB8_STOCK'  , "S"},;
				{'VB8_TIPREG' , "N"},;
				{'VB8_PROCES' , "N"};
			})
			//
			oDem := DMS_DataContainer():New({;
				{'VB8_VDPERB' , (cSQLVdaPer)->(VS3_QTDELI)},;
				{'VB8_HIPERB' , 1};
			})
			//
			ONJD3101_GravaDem(oDados, oDem)
		EndIf

		DBSelectArea("VS3")
		DBGoTo((cSQLVdaPer)->(VS3RECNO))
		reclock("VS3",.f.)
		VS3->VS3_FLGNAT := "I"
		msunlock()
		(cSQLVdaPer)->(DBSkip())
	enddo
	(cSQLVdaPer)->(DbCloseArea())

	// venda perdida
	cQuery := "  SELECT VS1_PEDREF, SBM.BM_PROORI, VS1.VS1_CLIFAT, VS1.VS1_LOJA, VS1.VS1_DATORC DATORC, VS3.R_E_C_N_O_ VS3RECNO, VS3.VS3_QTDITE, VS3.VS3_QTDELI,  VS3.VS3_CODSIT, SB1.B1_COD CODITE, SB1.B1_CRICOD CRICOD "
	cQuery += "    FROM "+oSqlHlp:NoLock('VS1')+" "
	cQuery += "    JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3_FILIAL = '"+xFilial('VS3')+"' AND VS1_NUMORC = VS3_NUMORC AND VS3.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL  = '"+xFilial("SB1")+"'  AND B1_CODITE    = VS3.VS3_CODITE        AND SB1.B1_GRUPO    = VS3.VS3_GRUITE        AND SB1.D_E_L_E_T_  = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock("SBM")+" ON B1_GRUPO   = SBM.BM_GRUPO          AND BM_FILIAL    = '"+xFilial("SBM")+"'  AND SBM.D_E_L_E_T_  = ' ' "
	cQuery += "   WHERE VS1_FILIAL      = '"+xFilial('VS1')+"' "
	cQuery += "     AND VS1_TIPORC      = '1' " // pecas
	cQuery += "     AND (VS1_MOTIVO     = '"+cMotVdaPer+"' OR VS3_MOTPED = '"+cMotVdaPer+"') "
	cQuery += "     AND VS3_FLGNAT      = ' ' "
	cQuery += "     AND VS1.D_E_L_E_T_  = ' ' "
	cQuery += "     AND B1_GRUPO IN " + cInGrupos
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVdaPer , .F. , .T. )
	While !(cSQLVdaPer)->(Eof())
		DBSelectArea('VS1')
		DBSetOrder(1)
		DBSeek(xFilial('VS1') + (cSQLVdaPer)->(VS1_PEDREF))

		// pedido deve estar como digitado para contabilizar
		// caso contrario pode contabilizar mais de 1 vez e ficar negativo
		if Empty((cSQLVdaPer)->(VS1_PEDREF)) .OR. VS1->VS1_STATUS == '0'
			DBSelectArea("VB8")
			if FS_ConsDem( (cSQLVdaPer)->(VS3_CODSIT) )
				oDados := DMS_DataContainer():New({;
					{'VB8_FILIAL' , xFilial("VB8")                   },;
					{'VB8_PRODUT' , (cSQLVdaPer)->(CODITE)           },;
					{'VB8_CRICOD' , (cSQLVdaPer)->(CRICOD)           },;
					{'VB8_CODCLI' , (cSQLVdaPer)->(VS1_CLIFAT)       },;
					{'VB8_LOJCLI' , (cSQLVdaPer)->(VS1_LOJA)         },;
					{'VB8_ANO'    , Left((cSQLVdaPer)->(DATORC),4)   },;
					{'VB8_MES'    , Subs((cSQLVdaPer)->(DATORC),5,2) },;
					{'VB8_DIA'    , Subs((cSQLVdaPer)->(DATORC),7,2) },;
					{'VB8_LOCAL'  , IIF((cSQLVdaPer)->(BM_PROORI) == "1","D1","N1") },;
					{'VB8_TIPLOC' , IIF((cSQLVdaPer)->(BM_PROORI) == "1","M","N")   },;
					{'VB8_STOCK'  , "S"},;
					{'VB8_TIPREG' , "N"},;
					{'VB8_PROCES' , "N"} ;
				})

				oDem := DMS_DataContainer():New({;
					{'VB8_VDPERB' , (cSQLVdaPer)->(VS3_QTDITE)},;
					{'VB8_HIPERB' , 1};
				})

				ONJD3101_GravaDem(oDados, oDem)
			EndIf

			DBSelectArea("VS3")
			DBGoTo((cSQLVdaPer)->(VS3RECNO))
			reclock("VS3",.f.)
			VS3->VS3_FLGNAT := "B" // venda perdida de orçamento
		else
			DBSelectArea("VS3")
			DBGoTo((cSQLVdaPer)->(VS3RECNO))
			reclock("VS3",.f.)
			VS3->VS3_FLGNAT := "K" // desconsidera pois nao tem o status correto
		endif

		VS3->(msunlock())
		(cSQLVdaPer)->(DBSkip())
	enddo
	(cSQLVdaPer)->(DbCloseArea())

	// -------------------------------------------------------------------------------------
	// PASSO I : Essa query serve para garantir que nenhuma nota fique de fora. Ela pega todas
	//           as notas que ainda não foram flagadas e cria um registro padrão de demanda
	// -------------------------------------------------------------------------------------
	cQuery := " SELECT SD2.R_E_C_N_O_ RECNOSD2,"
	cQuery += " SB1.B1_COD,"
	cQuery += " SB1.B1_CRICOD,"
	cQuery += " SBM.BM_PROORI,"
	cQuery += " SD2.D2_EMISSAO,"
	cQuery += " SD2.D2_DOC,"
	cQuery += " SD2.D2_SERIE,"
	cQuery += " SD2.D2_TOTAL,"
	cQuery += " SD2.D2_QUANT,"
	cQuery += " SD2.D2_PRCVEN,"
	cQuery += " SD2.D2_CLIENTE, SD2.D2_LOJA, "
	cQuery += " SD2.D2_DESC,"
	cQuery += " SB1.B1_GRUPO,"
	cQuery += " SB1.B1_CODITE,"
	cQuery += " SD2.D2_CUSTO1, "
	cQuery += " SF4.F4_ESTOQUE, "
	cQuery += " SF4.F4_OPEMOV "
	cQuery += " FROM " + oSqlHlp:NoLock("SD2")
	cQuery += " JOIN " + oSqlHlp:NoLock("SF2") + " ON F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC       = D2_DOC       AND F2_SERIE = D2_SERIE AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SB1") + " ON B1_FILIAL = '"+xFilial("SB1")+"' AND D2_COD       = B1_COD       AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  AND B1_GRUPO IN " + cInGrupos
	cQuery += " JOIN " + oSqlHlp:NoLock("SBM") + " ON BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + oSqlHlp:NoLock("SF4") + " ON F4_FILIAL = '"+xFilial("SF4")+"' AND D2_TES       = F4_CODIGO    AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE F2_PREFORI = '"+GetNewPar("MV_PREFBAL","BAL")+"' AND D2_FILIAL ='"+xFilial("SD2")+"' AND D2_FLGNAT = ' ' AND SD2.D_E_L_E_T_ = ' '  "
	cQuery += " AND D2_QUANT > 0 "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLPedNF , .F. , .T. )

	While !(cSQLPedNF)->(Eof())
		oDem := DMS_DataContainer():New({})
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
		// PASSO D : Pesquisa na VB8 para ver se já existe registro para aquela FILIAL, PRODUTO, ANO, MES, DIA e STOCK
		// -------------------------------------------------------------------------------------
		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial("VB8") },;
			{'VB8_PRODUT' , (cSQLPedNF)->(B1_COD) },;
			{'VB8_CRICOD' , (cSQLPedNF)->(B1_CRICOD) },;
			{'VB8_CODCLI' , (cSQLPedNF)->(D2_CLIENTE) },;
			{'VB8_LOJCLI' , (cSQLPedNF)->(D2_LOJA) },;
			{'VB8_ANO'    , Left((cSQLPedNF)->(D2_EMISSAO),4) },;
			{'VB8_MES'    , Subs((cSQLPedNF)->(D2_EMISSAO),5,2) },;
			{'VB8_DIA'    , Subs((cSQLPedNF)->(D2_EMISSAO),7,2) },;
			{'VB8_LOCAL'  , IIF((cSQLPedNF)->(BM_PROORI) == "1","D1","N1") },;
			{'VB8_TIPLOC' , IIF((cSQLPedNF)->(BM_PROORI) == "1","M","N") },;
			{'VB8_STOCK'  , "S"},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_PROCES' , "N"};
		})

		nImedVS3 := 0
		lDemanda := .F.

		cQuery := " SELECT VS1_NUMORC, VS3_QESTNA, VS3_QTDINI, VS3_CODSIT "
		cQuery += "   FROM "+RetSQLName("VS1")+" VS1 "
		cQuery += "   JOIN "+RetSQLName("VS3")+" VS3 ON VS3_FILIAL = VS1_FILIAL AND VS1_NUMORC = VS3_NUMORC AND VS3_GRUITE = '"+(cSQLPedNF)->(B1_GRUPO)+"' AND VS3_CODITE = '"+(cSQLPedNF)->(B1_CODITE)+"' AND VS3.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE VS1_FILIAL  = '"+xFilial('VS1')+"' "
		cQuery += "    AND VS1_NUMNFI  = '"+(cSQLPedNF)->(D2_DOC)+"' "
		cQuery += "    AND VS1_SERNFI  = '"+(cSQLPedNF)->(D2_SERIE)+"' "
		cQuery += "    AND VS1.D_E_L_E_T_ = ' ' "
		aData := oSqlHlp:GetSelect({;
			{'campos', {"VS1_NUMORC", "VS3_QESTNA", "VS3_QTDINI", "VS3_CODSIT"}},;
			{'query' , cQuery } ;
		})

		If len(aData) > 0
			oData := aData[1]
			if oData:GetValue("VS3_QESTNA") >= oData:GetValue("VS3_QTDINI")
				nImedVS3 := 1
			endif
			if FS_ConsDem(oData:GetValue("VS3_CODSIT"))
				lDemanda := .t.
			else
				lDemanda := .f.
			endif
		EndIf

		if lDemanda
			if FS_isEspecial(VS3->VS3_CODSIT)
				oDem := DMS_DataContainer():New({;
					{'VB8_HITSBN' , 1},;
					{'VB8_IMEDBN' , nImedVS3},;
					{'VB8_TOTBAN' , (cSQLPedNF)->(D2_TOTAL)},;
					{'VB8_CUSBAN' , (cSQLPedNF)->(D2_CUSTO1)},;
					{'VB8_VDABN'  , (cSQLPedNF)->(D2_QUANT)};
				})
			Else
				oDem := DMS_DataContainer():New({;
					{'VB8_HITSB'  , 1},;
					{'VB8_IMEDB'  , nImedVS3},;
					{'VB8_TOTBAL' , (cSQLPedNF)->(D2_TOTAL)},;
					{'VB8_CUSBAL' , (cSQLPedNF)->(D2_CUSTO1)},;
					{'VB8_VDAB'   , (cSQLPedNF)->(D2_QUANT)};
				})
			EndIf

			ONJD3101_GravaDem(oDados, oDem)
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
		conout("Erro query OFINJD31: " + TCSQLError())
	endif
next

oLogger:Log( { "     |> Termino nivel de atendimento balcão normal : ("+FWTimeStamp(5)+")"} )

// -------------------------------------------------------------------------------------
// GRAVA DEVOLUCAO
// -------------------------------------------------------------------------------------
cAliasSD1 := GetNextAlias()
//
for nCont := 1 to Len(aFilis2)
	//
	cFilAnt := aFilis2[nCont,1]
	if EMPTY(cFilAnt)
		oLogger:Log( {"Filial em branco detectada, pulando"+ " ("+FWTimeStamp(5)+")"} )
		loop
	end
	cDadosProd := GetNewPar("MV_MIL0054","SBZ")
	//
	cQuery := " SELECT SD1.R_E_C_N_O_ RECSD1, SD2.D2_CLIENTE, SD2.D2_LOJA, "
	cQuery += " SD1.D1_TOTAL, SD1.D1_VALDESC, SD1.D1_CUSTO , SB1.B1_GRUPO , SD1.D1_QUANT,  SF2.F2_PREFORI, SD1.D1_COD, SD1.D1_DTDIGIT, SB1.B1_CRICOD, SD2.D2_EMISSAO "
	cQuery += " FROM "+oSqlHlp:NoLock("SD1")
	cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' "
	cQuery += "  AND B1_GRUPO IN " + cInGrupos
	cQuery += " JOIN "+oSqlHlp:NoLock("SF2")+" ON ( SF2.F2_FILIAL=SD1.D1_FILIAL AND SF2.F2_DOC=SD1.D1_NFORI AND SF2.F2_SERIE=SD1.D1_SERIORI  AND SF2.F2_PREFORI IN ('"+GetNewPar("MV_PREFBAL","BAL")+"','"+GetNewPar("MV_PREFOFI","OFI")+"') AND SF2.D_E_L_E_T_=' ' ) "
	cQuery += " JOIN "+oSqlHlp:NoLock("SD2")+" ON ( SD2.D2_FILIAL=SF2.F2_FILIAL AND SD2.D2_DOC=SF2.F2_DOC   AND SD2.D2_SERIE=SF2.F2_SERIE    AND SD2.D2_COD = SD1.D1_COD AND SD1.D1_ITEMORI = SD2.D2_ITEM AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += " JOIN "+oSqlHlp:NoLock("SF4")+" ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " // OPEMOV = 05 = VENDA
	cQuery += " WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_=' ' AND D1_FLGNAT = ' ' "

	cQuery += "  ORDER BY SD1.D1_FILIAL "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD1, .T., .T. )


	While !((cAliasSD1)->(Eof()))
		oDem := DMS_DataContainer():New({})
		oDados := DMS_DataContainer():New({;
			{'VB8_FILIAL' , xFilial("VB8") },;
			{'VB8_PRODUT' , (cAliasSD1)->(D1_COD) },;
			{'VB8_CRICOD' , (cAliasSD1)->(B1_CRICOD) },;
			{'VB8_CODCLI' , (cAliasSD1)->(D2_CLIENTE) },;
			{'VB8_LOJCLI' , (cAliasSD1)->(D2_LOJA) },;
			{'VB8_ANO'    , Left((cAliasSD1)->(D2_EMISSAO),4) },;
			{'VB8_MES'    , Subs((cAliasSD1)->(D2_EMISSAO),5,2) },;
			{'VB8_DIA'    , Subs((cAliasSD1)->(D2_EMISSAO),7,2) },;
			{'VB8_LOCAL'  , "D1"},;
			{'VB8_TIPLOC' , "M"},;
			{'VB8_STOCK'  , "S"},;
			{'VB8_TIPREG' , "N"},;
			{'VB8_PROCES' , "N"};
		})
		oDem := DMS_DataContainer():New({})
		if Alltrim((cAliasSD1)->(F2_PREFORI)) == Alltrim(GetNewPar("MV_PREFOFI","OFI"))
			oDem := DMS_DataContainer():New({;
				{'VB8_DEVOFI' , (cAliasSD1)->(D1_TOTAL) - (cAliasSD1)->(D1_VALDESC)},;
				{'VB8_CUSDEV' , (cAliasSD1)->(D1_CUSTO)};
			})
		elseif Alltrim((cAliasSD1)->(F2_PREFORI)) == Alltrim(GetNewPar("MV_PREFBAL","BAL"))
			oDem := DMS_DataContainer():New({;
				{'VB8_DEVBAL' , (cAliasSD1)->(D1_TOTAL) - (cAliasSD1)->(D1_VALDESC)},;
				{'VB8_CUSDEV' , (cAliasSD1)->(D1_CUSTO)};
			})
		endif

		ONJD3101_GravaDem(oDados, oDem)

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

oLogger:Log( {"Execucao Completa"+ " ("+FWTimeStamp(5)+")"} )
oLogger:Log( {"############################################################################"} )
oLogger:CloseOpened(cTblLogCod) // fecha log de execução

UnLockByName("OFINJD31", .T. , .T. , .T. )


	If lAuto //Chamada Automatica
		OFINJD06(aParam, lSoGer .or. lAuto)
	endif

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
	If oDemDpm:isEspecial(cCodSit) // se for especial não considera na demanda, a funcao abaixo é só pra quando nao considerar demanda e for especial aí soma hits e imedb
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

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Função    | ONJD3101_GravaDem | Autor |  Vinicius Gati     | Data | 27/10/14 |##
##+----------+---------------+-------+--------------------+------+----------+##
##| Gravará os dados da demanda no VB8 agrupando quando possivel            |##
##+----------+---------------+-------+--------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function ONJD3101_GravaDem(oDados, oDem)
	Local nIdx   := 0
	Local nRecno := FS_ExVB8(oDados)

	DBSelectArea('VB8')

	begin transaction
		if nRecno > 0
			VB8->(DbGoTo(nRecno))
			reclock('VB8', .F.)
		else
			cCodVB8 := FS_GetSxeNum("VB8", "VB8_CODIGO")
			reclock('VB8', .T.)
			VB8->VB8_CODIGO := cCodVB8
		EndIf

		for nIdx := 1 to LEN( oDados:aData )// seta os dados dinamicamente
			cCampo := oDados:aData[nIdx][1]
			valor  := oDados:aData[nIdx][2]
			VB8->&(cCampo) := valor
		next

		for nIdx := 1 to LEN( oDem:aData )// dados de demanda é feito +=
			cCampo      := oDem:aData[nIdx][1]
			valor       := oDem:aData[nIdx][2]
			valor_atual := VB8->&(cCampo)
			if valtype(valor_atual) == "U" // verifica se é nulo se for manda um zeris de levis
				valor_atual := 0
			EndIf
			VB8->&(cCampo) := valor_atual + valor // demanda faz um += na moral
		next

		if VB8->VB8_CUSBAL+ VB8->VB8_CUSBAN+ VB8->VB8_CUSOFI+ VB8->VB8_HIPERB+;
			VB8->VB8_HITSB+ VB8->VB8_HITSBN+ VB8->VB8_HITSO+ VB8->VB8_IMEDB+;
			VB8->VB8_IMEDBN+ VB8->VB8_IMEDO+ VB8->VB8_TOTBAL+ VB8->VB8_TOTBAN+;
			VB8->VB8_TOTOFI+ VB8->VB8_VDAB+ VB8->VB8_VDABN+ VB8->VB8_VDAO+;
			VB8->VB8_VDPERB+VB8->VB8_VDPERO+VB8->VB8_HIPERO > 0
			msunlock()
			ConfirmSx8()
		else
			disarmtransaction()
		end
	end transaction

	

	// Grava data de ultima venda
	if VB8->VB8_VDAB + VB8->VB8_VDAO > 0 // vendeu?
		if Alltrim(cDadosProd) == "SBZ" // PARA QUEM USA SBZ
			if SBZ->(DBSeek(xFilial("SBZ")+Alltrim(VB8->VB8_PRODUT)))
				if SBZ->BZ_ULTVDA < STOD( VB8->VB8_ANO + VB8->VB8_MES + VB8->VB8_DIA )
					DBSelectArea("SBZ")
					reclock("SBZ" , .F.)
					SBZ->BZ_ULTVDA := stod(VB8->VB8_ANO+VB8->VB8_MES+VB8->VB8_DIA)
					msunlock()
				endif
			endif
		else // PARA QUEM USA SB5
			if SB5->(DBSeek(xFilial("SB5")+Alltrim(VB8->VB8_PRODUT)))
				if SB5->B5_ULTVDA < stod(VB8->VB8_ANO+VB8->VB8_MES+VB8->VB8_DIA)
					DBSelectArea("SB5")
					reclock("SB5",.f.)
					SB5->B5_ULTVDA := stod(VB8->VB8_ANO+VB8->VB8_MES+VB8->VB8_DIA)
					msunlock()
				endif
			endif
		endif
	endif
	//
return VB8->VB8_CODIGO

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Função    | FS_ExVB8      | Autor |  Vinicius Gati     | Data | 27/10/14 |##
##+----------+---------------+-------+--------------------+------+----------+##
##| Verifica se existe VB8 util para agrupar a demanda                      |##
##+----------+---------------+-------+--------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FS_ExVB8(oDados)
	cQuery := " SELECT COALESCE(R_E_C_N_O_, 0) VB8RECNO FROM " + oSqlHlp:NoLock("VB8")
	cQuery += " WHERE VB8_FILIAL = '"+xFilial("VB8")+"' AND "
	cQuery += " VB8_CODCLI = '" + oDados:GetValue('VB8_CODCLI', '') + "' AND VB8_LOJCLI = '" + oDados:GetValue('VB8_LOJCLI', '') + "' AND "
	cQuery += " VB8_PRODUT = '" + Left( oDados:GetValue('VB8_PRODUT', '') +SPACE(27),TamSX3("VB8_PRODUT")[1])+ "' AND "
	cQuery += " VB8_ANO    = '" + oDados:GetValue('VB8_ANO', '') + "' AND "
	cQuery += " VB8_MES    = '" + oDados:GetValue('VB8_MES', '') + "' AND "
	cQuery += " VB8_DIA    = '" + oDados:GetValue('VB8_DIA', '') + "' AND "
	cQuery += " VB8_FLGENV = ' ' AND "
	cQuery += " VB8_TIPREG != 'C' AND "
	cQuery += " VB8_STOCK  = '" + oDados:GetValue('VB8_STOCK', '') + "' AND "
	cQuery += " D_E_L_E_T_ = ' ' "
return FM_SQL(cQuery)

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Função    | FS_GetSxeNum  | Autor |  Vinicius Gati     | Data | 05/06/17 |##
##+----------+---------------+-------+--------------------+------+----------+##
##| Verifica se a chave gerada pelo sxenum pode ser usada                   +##
##| e tenta gerar outra até conseguir com limite de 500mil tentativas       +##
##+----------+---------------+-------+--------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FS_GetSxeNum(cTabela, cCampo)
	Local cQuery := ''
	Local cNum   := ''
	Local nTry   := 0

	// ponto de entrada para resolver um problema pontual na martis e sobrinhos
	if ExistBlock("OJD31NUM")
		cNum := FM_SQL(" SELECT MAX("+cCampo+") FROM " + RetSQLName(cTabela) + "  WHERE "+cTabela+"_FILIAL = '"+xFilial(cTabela)+"' ")
		return soma1(cNum, TamSx3(cCampo)[1])
	else
		while nTry <= 100000
			cNum := GetSxeNum("VB8", "VB8_CODIGO")

			cQuery := " SELECT COALESCE(count(*), 0) FROM " + RetSQLName(cTabela)
			cQuery += "  WHERE "+cTabela+"_FILIAL = '"+xFilial(cTabela)+"' AND " + cCampo + " = '" + cNum + "' "
			if FM_SQL(cQuery) > 0
				ConfirmSx8()
			else
				return cNum
			end
			nTry += 1
		end
	endif
Return 'problemaSXE9999999' // se retornar isso é porque não encontrou sxe valido em mais de 100mil tentativas, sendo assim é melhor ajustar manualmente


/*/{Protheus.doc} JD3100014_AjustaQESTNADia
	Ajusta o qestna em caso de zerado para ter certeza que o saldo existia no dia
	
	@type function
	@author Vinicius Gati
	@since 30/10/2019
/*/
Function JD3100014_AjustaEstoqueNADoDia(dDateToProc)
	local cQuery := ""
	local cAl := getnextAlias()
	local nQtdEst := 0

	cQuery += " SELECT VS3_FILIAL, VS3_NUMORC, VS3_CODITE, VS3_GRUITE, VS3_SEQUEN, B1_COD, B1_LOCPAD "
	cQuery += "   FROM " + oSqlHlp:NoLock('VS3')
	cQuery += "   JOIN " + oSqlHlp:NoLock('VS1') + " ON VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1_NUMORC = VS3_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "   JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial("SB1")+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE VS3_FILIAL = '"+xFilial('VS3')+"' "
	cQuery += "    AND VS1_DATORC = '"+dtos(dDateToProc)+"' "
	cQuery += "    AND VS3_QESTNA = 0 " // somente zero, pois quando maior que 1 já é certo que está correto
	cQuery += "    AND VS3.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAl,.T.,.T.)

	While ! ((cAl)->(Eof()))

		DbSelectArea("SB2")
		nQtdEst := CalcEst((cAl)->(B1_COD), (cAl)->(B1_LOCPAD), dDateToProc)[1]

		if nQtdEst > 0
			DBSelectArea('VS3')
			DBSetOrder(2) // VS3_FILIAL+VS3_NUMORC+VS3_GRUITE+VS3_CODITE+VS3_SEQUEN
			if DBSeek((cAl)->(VS3_FILIAL) + (cAl)->(VS3_NUMORC) + (cAl)->(VS3_GRUITE) + (cAl)->(VS3_CODITE) + (cAl)->(VS3_SEQUEN))
				RecLock("VS3", .f.)
				VS3->VS3_QESTNA := nQtdEst
				VS3->(msunlock())
			endif
		endif

		(cAl)->(DBSkip())
	enddo

	(cAl)->(DBCloseArea())
return
