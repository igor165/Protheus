//////////////////
// versao 0041  //
//////////////////

#include "topconn.ch"
#include "tbiconn.ch"
#include "fileio.ch"
#include "protheus.ch"
#include "OFINJD09.ch"

static cSGBD := TcGetDb()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFINJD09   | Autor |  Luis Delorme/Vinicius| Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Exportação do arquivo PMMANAGE (JDPrism)                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD09(aParam, dDtFrom32)
	// Variaveis da ParamBox
	Local aSay    := {}
	Local aButton := {}
	Local nOpc    := 0
	Local nIdx    := 1
	Local nAnosF  := 1
	//
	Private lAuto := VALTYPE(aParam) != "U" //Chamada Automatica
	If lAuto //Chamada Automatica
		nModulo := 14
		cModulo := "OFI"
		__cInternet := 'AUTOMATICO'
		cEmpr   := aParam[1]
		cFil    := aParam[2]
		If Type("cArqTab")=="U"
			cArqTab:=""
		EndIf
		cFOPENed := ""
		DbCloseAll()
		Prepare Environment Empresa cEmpr Filial cFil Modulo "OFI"
	EndIf
	//
	Private cArquivo
	Private cMes
	Private dBckDtBase   := ""
	Private oLogger      := Nil
	Private oUtil        := Nil
	Private oSqlHlp      := Nil
	Private oArHlp       := Nil
	Private oDpePecas    := Nil
	Private oCacheInv    := Nil
	Private oDpm         := Nil
	Private l12Meses     := .F.
	Private cTblLogCod   := ""
	Private dMesAnt      := Nil
	Private aDpmCfgs     := {}
	Private aFilis       := {}
	Private cPrefBAL
	Private cPrefOFI
	Private lSoArmVenda  := .T.
	Private oCacheVendas := JsonObject():New()
	Default dDtFrom32    := dDatabase
	//
	If lAuto //Chamada Automatica
		dDtFrom32 := dDataBase := Date() - 1
		conout( "Database modificado pelo scheduler para: " + DTOC(dDataBase) )
		dBckDtBase := dDatabase
	else
		dBckDtBase := dDatabase
		If dDataBase != dDtFrom32
			l12Meses := .F.
		Else
			// l12Meses := MsgNoYes(STR0016 /*"Deseja gerar 12 meses de PMM?"*/, STR0004 /* "Atenção" */) // Pergunta se vai reprocessar ou não
		EndIf
	Endif
	
	Private d1AnoAtras  := ddatabase
	Private d2AnosAtras := d1AnoAtras
	Private nMes := Month(ddatabase)
	Private nAno := Year(ddatabase)
	Private cTitulo := STR0003
	Private cPerg        := "OFINJD09"
	Private lRetorna     := .t.
	Private cDadosProd   := GetNewPar("MV_MIL0054","SBZ")
	Private oDemDpm
	cPrefBAL     := Alltrim(GetNewPar("MV_PREFBAL","BAL")) // Prefixo de Origem ( F2_PREFORI )
	cPrefOFI     := Alltrim(GetNewPar("MV_PREFOFI","OFI")) // Prefixo de Origem ( F2_PREFORI )
	oLogger      := DMS_Logger():New("OFINJD09.LOG"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
	oUtil        := DMS_Util():New()
	oSqlHlp      := DMS_SqlHelper():New()
	oArHlp       := DMS_ArrayHelper():New()
	oCacheInv    := DMS_CacheB2():New()
	oDpm         := DMS_DPM():New()
	oDpePecas    := DMSB_DpePecas():New()
	oDemDpm      := DMS_DemandaDPM():New()

	//
	CriaSX1()
	//
	aAdd( aSay, STR0001 )
	aAdd( aSay, STR0002 )
	//
	aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
	aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )

	if ExistBlock("JD09001")
		lSoArmVenda := .F.
	endif

	If !lAuto .and. dDataBase != dDtFrom32 // geração da rotina ofinjd32
		dDatabase := dDtFrom32
		nMes := Month(ddatabase)
		nAno := Year(ddatabase)
	Else
		if !lAuto
			FormBatch( cTitulo, aSay, aButton )
			//
			If nOpc <> 1
				Return
			Endif
		endif	
	EndIf

	if l12Meses
		for nAnosF := 1 to 12 //  gerar 12 meses de PMM
			dDatabase := oUtil:UltimoDia( nAno, nMes )
			conout( "Iniciando data: " + DTOC(dDataBase) )
			dBckDt := dDatabase
			GeraPMM()
			dDatabase := oUtil:RemoveMeses(dBckDt, 1)
			dDatabase := oUtil:UltimoDia( nAno, nMes )
			nAno      := YEAR(dDatabase)
			nMes      := MONTH(dDatabase)
		next
		return
	Else
		dDatabase := oUtil:UltimoDia( nAno, nMes )
		GeraPMM()
	EndIf
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | GERAPMM    | Autor | Vinicius Gati         | Data | 11/09/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Exportação do arquivo PMMANAGE (JDPrism)                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GeraPMM()
	Local nIdx    := 1
	Local aButton := {}
	Local nOpc    := 0
	//
	cDadosProd := GetNewPar("MV_MIL0054","SBZ") // Parametro que define se as datas do DPM serao pegas do SBZ ou SB5

	// pegando as datas para ultimos 12 e prior 12 que é 12 antes do 12 KKK
	d1AnoAtras := dDatabase
	for nIdx := 1 to 11
		d1AnoAtras  := oUtil:RemoveMeses(d1AnoAtras, 1)
		d1AnoAtras  := oUtil:UltimoDia( YEAR(d1AnoAtras), MONTH(d1AnoAtras) )
	next
	d1AnoAtras := STOD( ALLTRIM(STR(YEAR(d1AnoAtras))) + ALLTRIM(STRZERO(MONTH(d1AnoAtras),2)) + '01' )
	d2AnosAtras := d1AnoAtras
	for nIdx := 1 to 12
		d2AnosAtras := oUtil:RemoveMeses(d2AnosAtras, 1)
		d2AnosAtras  := oUtil:UltimoDia( YEAR(d2AnosAtras), MONTH(d2AnosAtras) )
	next
	d2AnosAtras := STOD( ALLTRIM(STR(YEAR(d2AnosAtras))) + ALLTRIM(STRZERO(MONTH(d2AnosAtras),2)) + '01' )

	//#############################################################################
	//# Chama a rotina de exportação                                              #
	//#############################################################################

	cMes := "JAN"
	cMes := IIF(Month(ddatabase)==2,"FEB",cMes)
	cMes := IIF(Month(ddatabase)==3,"MAR",cMes)
	cMes := IIF(Month(ddatabase)==4,"APR",cMes)
	cMes := IIF(Month(ddatabase)==5,"MAY",cMes)
	cMes := IIF(Month(ddatabase)==6,"JUN",cMes)
	cMes := IIF(Month(ddatabase)==7,"JUL",cMes)
	cMes := IIF(Month(ddatabase)==8,"AUG",cMes)
	cMes := IIF(Month(ddatabase)==9,"SEP",cMes)
	cMes := IIF(Month(ddatabase)==10,"OCT",cMes)
	cMes := IIF(Month(ddatabase)==11,"NOV",cMes)
	cMes := IIF(Month(ddatabase)==12,"DEC",cMes)

	cArquivo :=;
		"DLR2JD_" +;
		strzero(DAY(ddatabase),2) +;
		cMes +;
		STR(Year(ddatabase),4) + "_" +;
		SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".temp"
	//////////////////////////////////////////////////
	// Importante para scheduler, não remover/mudar //
	//////////////////////////////////////////////////
	Pergunte(cPerg,.f.)
	//////////////////////////////////////////////////
	//////////////////////////////////////////////////
	//////////////////////////////////////////////////
	aDpmCfgs := oDpm:GetConfigs()

	If LEN(aDpmCfgs) == 0
		if lAuto
			oLogger:Log({'TIMESTAMP', "OFINJD09 rodado em modo agendado data: " + DTOS(dDatabase) + "("+time()+")"})
			cTblLogCod := oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFINJD09'        },;
				{'VQL_TIPO'       , 'LOG_EXECUCAO'    },;
				{'VQL_DADOS'      , 'MODO: Agendado'  } ;
			})
			RunProc( lAuto, , oDpm:GetFiliais() )
		else
			oLogger:Log({'TIMESTAMP', "OFINJD09 rodado em modo normal data: " + DTOS(dDatabase) + "("+time()+")"})
			cTblLogCod := oLogger:LogToTable({;
				{'VQL_AGROUP'  , 'OFINJD09'        },;
				{'VQL_TIPO'    , 'LOG_EXECUCAO'    },;
				{'VQL_DADOS'   , 'MODO: Normal'    } ;
			})
			RptStatus( {|lEnd| RunProc( lAuto, , oDpm:GetFiliais() ) }, STR0004,STR0005, .T. )
		endif
	Else
		//
		for nIdx := 1 to Len(aDpmCfgs)
			aDpmCfg := aDpmCfgs[nIdx]
			aFilis := aDpmCfg:GetFiliais()
			cAcc   := aDpmCfg:GetAccount()
			cArquivo :=;
				"DLR2JD_" +;
				strzero(DAY(ddatabase),2) +;
				cMes +;
				STR(Year(ddatabase),4) + "_" +;
				SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".temp"
			if lAuto
				oLogger:Log({'TIMESTAMP', "OFINJD09 rodado em modo agendado data: " + DTOS(dDatabase) + "("+time()+")"})
				cTblLogCod := oLogger:LogToTable({;
					{'VQL_AGROUP'     , 'OFINJD09'        },;
					{'VQL_TIPO'       , 'LOG_EXECUCAO'    },;
					{'VQL_DADOS'      , 'MODO: Agendado'  } ;
				})
				RunProc( lAuto, aDpmCfg:GetPath(), aDpmCfg:GetFiliais(), cAcc )
			else
				oLogger:Log({'TIMESTAMP', "OFINJD09 rodado em modo normal data: " + DTOS(dDatabase) + "("+time()+")"})
				cTblLogCod := oLogger:LogToTable({;
					{'VQL_AGROUP'  , 'OFINJD09'        },;
					{'VQL_TIPO'    , 'LOG_EXECUCAO'    },;
					{'VQL_DADOS'   , 'MODO: Normal'    } ;
				})
				RptStatus( {|lEnd| RunProc( lAuto, aDpmCfg:GetPath(), aDpmCfg:GetFiliais(), cAcc ) }, STR0004,STR0005, .T. )
			endif
			//
			oLogger:CloseOpened(cTblLogCod) // fecha log de execução
			//
		next
		//
	EndIf
	dDatabase := dBckDtBase
Return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | RunProc    | Autor |  Luis Delorme         | Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Exportação da arquivo da JD contendo as informações de esto- |##
##|          | que (PMM)                                                    |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function RunProc(lEnd, cPath, aFilis, cAccount)
Local aVetNome := {}
Local aVetTam  := {}
Local aVetData := {}
Local aVetHora := {}
Local nCntForFil
Local nCntForCri
Local nCntForGru
Local nCntFor, nCntFor2
Local cQuery := ""
Default cPath := ""

oDpePecas:ColetaItensDia()
aLocStok := {}
//
nMesInv := nMes
nAnoInv := nAno - 100
//
aAnosInv := {}
//
for nCntFor := 1 to 24
	if nMesInv == 0
		nMesInv := 12
		nAnoInv := nAnoInv - 1
	endif
	aAdd(aAnosInv,{STRZERO(nAnoInv,4), STRZERO(nMesInv,2), 0,0})
	nMesInv --
next
//
nVenBal   := 0
nVenOfi   := 0
nVenInt   := 0
nDevBal   := 0
nDevOfi   := 0
nDevInt   := 0
nInv13_24 := 0
nInv1_12  := 0
cData12   := STRZERO(nAno - 1,4)+STRZERO(nMes,2)
cData24   := STRZERO(nAno - 2,4)+STRZERO(nMes,2)
cData36   := STRZERO(nAno - 3,4)+STRZERO(nMes,2)
aData     := {}  
aInfo     := {}
aInfo2    := {}

cChaveScan := ""

aSint := {}
nIndSint := 0
lAbort := .f.
//
// le o cabeçalho do arquivo
//
If lAuto .and. !(Left(MV_PAR01,1) $ "/\")
  conout(" ")
  conout("OFINJD09 ==========================================================================================")
  conout("OFINJD09 ==========================================================================================")
  conout("OFINJD09  ATENCAO: nao é possivel gerar o arquivo do PARTS DATA (DPM) em um diretorio local quando ")
  conout("OFINJD09           executado atraves do SCHEDULE ajuste o parametro com caminho destino do arquivo ")
  conout("OFINJD09 ==========================================================================================")
  conout("OFINJD09 ==========================================================================================")
  conout(" ")
EndIf

if !lAuto
	if aDir( Alltrim(lower(MV_PAR01))+alltrim(UPPER(cArquivo)),aVetNome,aVetTam,aVetData,aVetHora) > 0
		if !MsgYesNo(STR0006,STR0004)
			lErro := .t.
			return
		endif
	endif
endif
//
cQryAl001 := GetNextAlias()
//
VE4->(DBSetOrder(1))
DBSelectArea("SX6")
DBSetOrder(1)
DBGoTop()
while !eof()
	if Alltrim(SX6->X6_VAR) == "MV_ARQPROD"
		oLogger:Log({"MV_ARQPROD: " + "Filial = " + AllTrim(SX6->X6_FIL) + " Conteudo = " + AllTrim(SX6->X6_CONTEUD)})
	EndIf
	if Alltrim(SX6->X6_VAR) == "MV_MIL0054"
		oLogger:Log({"MV_MIL0054: " + "Filial = " + AllTrim(SX6->X6_FIL) + " Conteudo = " + AllTrim(SX6->X6_CONTEUD)})
	EndIf

	if Alltrim(SX6->X6_VAR) == "MV_MIL0006"
		oLogger:Log({"MV_MIL0006: " + "Filial = " + AllTrim(SX6->X6_FIL) + " Conteudo = " + AllTrim(SX6->X6_CONTEUD)})
	EndIf

	if Alltrim(SX6->X6_VAR) == "MV_MIL0028"
		oLogger:Log({"MV_MIL0028: " + "Filial = " + AllTrim(SX6->X6_FIL) + " Conteudo = " + AllTrim(SX6->X6_CONTEUD)})
	EndIf
	
	if Alltrim(SX6->X6_VAR) == "MV_MIL0029"
		oLogger:Log({"MV_MIL0029: " + "Filial = " + AllTrim(SX6->X6_FIL) + " Conteudo = " + AllTrim(SX6->X6_CONTEUD)})
	EndIf
	
	if Alltrim(SX6->X6_VAR) == "MV_MIL0032"
		oLogger:Log({"MV_MIL0032: " + "Filial = " + AllTrim(SX6->X6_FIL) + " Conteudo = " + AllTrim(SX6->X6_CONTEUD)})
	EndIf

	if Alltrim(SX6->X6_VAR) == "MV_MIL0005"
		VE4->(DBSeek(SX6->X6_FIL))
		oLogger:Log({"MV_MIL0005: " + "Filial = " + AllTrim(SX6->X6_FIL) + " Conteudo = " + AllTrim(SX6->X6_CONTEUD)})
	endif
	DBSkip()
enddo
oLogger:Log({"################################################################################################"})
//
aCriCod := {}

if SBM->(FieldPos('BM_VAIDPM')) > 0
	cQuery := " UPDATE "+RetSqlName('SB1')+" SET B1_CRICOD = '00' "
	cQuery += "  WHERE B1_FILIAL = '"+xFilial('SB1')+"' AND D_E_L_E_T_ = ' ' "
	cQuery += "    AND B1_GRUPO IN (SELECT BM_GRUPO FROM "+RetSqlName('SBM')+" WHERE BM_FILIAL = '"+xFilial('SBM')+"' AND BM_VAIDPM = '1' AND D_E_L_E_T_ = ' ') "
	cQuery += "    AND B1_CRICOD = ' ' "
else
	cQuery := " UPDATE "+RetSqlName('SB1')+" SET B1_CRICOD = '00' "
	cQuery += "  WHERE B1_FILIAL = '"+xFilial('SB1')+"' AND D_E_L_E_T_ = ' ' "
	cQuery += "    AND B1_GRUPO IN "+oDpm:GetInGroups()+" "
	cQuery += "    AND B1_CRICOD = ' ' "
endif
if tcSqlExec(cQuery) < 0
	MSGSTOP("Erro de sql detectado: " + TCSQLError())
	conout(TCSQLError())
endif
//
cQryAl001 := GetNextAlias()
//
cQuery := "SELECT DISTINCT B1_CRICOD FROM "+ oSqlHlp:NoLock("SB1")
cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND"
cQuery += " SB1.D_E_L_E_T_ = ' ' ORDER BY B1_CRICOD"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
//
while !(cQryAl001)->(eof())
	aAdd(aCriCod, (cQryAl001)->(B1_CRICOD) )
	DBSkip()
enddo
//
(cQryAl001)->(DBCloseArea())
//
// Checagem de inventario, se tem o inventario anterior calculado faz, caso contrario não.
//
conout( "Fazendo cache do ANO: " + STR(YEAR(dDataBase)) + " MES: " + STR(MONTH(dDataBase)))
oCacheInv:CacheToPMM( YEAR(dDatabase), Month(dDatabase), oDpm:GetFiliais() ) // todas as filiais, melhor fazer tudo de uma vez...
oLogger:LogToTable({                        ;
	{'VQL_AGROUP'     , 'OFINJD25'        },; // gravar como 25 mesmo varios pontos pegam como 25
	{'VQL_TIPO'       , 'MES_COMPLETO'    },;
	{'VQL_DADOS'      , DTOS(dDatabase)   } ;
})
//
//
aMesCont := {}

for nCntFor := 1 to len(aFilis)
	cFilAnt := aFilis[nCntFor, 1]
	cDadosProd:= GetNewPar("MV_MIL0054","SBZ")
	cQryAl006 := GetNextAlias()
	cQuery := " SELECT MIN(VB8_MES) MES, MIN(VB8_ANO) ANO " 
	cQuery += " FROM " + oSqlHlp:NoLock("VB8")
	cQuery += " WHERE VB8_FILIAL = '"+xFilial('VB8')+"' AND VB8_TOTFAB > 0 AND VB8_ANO = ( select min(VB8_ANO) from " 
	cQuery += oSqlHlp:NoLock("VB8") + " WHERE VB8_ANO != ' ' AND VB8_TOTFAB > 0 AND D_E_L_E_T_ = ' ' AND VB8_FILIAL = '"+xFilial('VB8')+"')"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl006, .F., .T. )
	//
	nMesPrim := VAL((cQryAl006)->(MES))
	nAnoPrim := VAL((cQryAl006)->(ANO))
	if nMesPrim == 0 .or. nAnoPrim == 0
		nMesPrim := month(ddatabase)
		nAnoPrim := year(ddatabase) - 100
	endif
	//
	(cQryAl006)->(DBCloseArea())
	//
	nMesCtC := month(ddatabase)
	nAnoCtC := year(ddatabase) - 100
	//
	nMConsid := 1
	while nAnoCtC != nAnoPrim .or. nMesCtC != nMesPrim
		nMesCtC --
		if nMesCtC == 0
			nMesCtC := 12
			nAnoCtc := IIF(nAnoCtc < nAnoPrim, nAnoCtc+1,  nAnoCtC-1)//estava com erro , voltava infinitamente com ano retroativo
		endif
		nMConsid ++
	enddo
	if nMConsid > 24
		nMCons12 := 12
		nMCons24 := 24
	elseif nMConsid > 12
		nMCons12 := 12
		nMCons24 := nMConsid - 12
	else
		nMCons24 := 0
		nMCons12 := nMConsid
	endif
	aAdd(aMesCont,{nMCons12,nMCons24})
next
//
for nCntFor := 1 to Len(aFilis)
	aAdd(aSint, {aFilis[nCntFor,1],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, "D1"})
	aAdd(aSint, {aFilis[nCntFor,1],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, "N1"})
next

for nCntFor2 := 1 to Len(aCriCod)
	//
	for nCntFor := 1 to Len(aFilis)
		//
		cCriCoVB8 := IIF( Empty(aCriCod[nCntFor2]),"00",aCriCod[nCntFor2])
		//
		aAdd(aLocStok, {"D1", "M", cCriCoVB8,aFilis[nCntFor,1], .f.  })
		aAdd(aInfo,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
		aAdd(aInfo2,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
		//
		aAdd(aLocStok, {"N1", "N", cCriCoVB8,aFilis[nCntFor,1], .f.  })
		aAdd(aInfo,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
		aAdd(aInfo2,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
		//
	next
next
//
// Computando inventarios
cChaveScan := ""
//
for nCntFor := 1 to Len(aLocStok)
	cLocalVB8 := aLocStok[nCntFor,1]
	cTipLoVB8 := aLocStok[nCntFor,2]
	cCriCoVB8 := aLocStok[nCntFor,3]
	nPosSint  := aScan(aSint ,{|x| x[1] == aLocStok[nCntFor,4] .and. x[53] == cLocalVB8  })
	nPosFilis := aScan(aFilis,{|x| x[1] == aLocStok[nCntFor,4]                           })
	if nPosSint == 0
		loop
	endif
	//
	nVInvAno12 := 0
	nInvAtualV := aAnosInv[1,3]
	nInvAtualZ := aAnosInv[1,4]
	for nCntFor2 := 1 to 12
		nVInvAno12 += aAnosInv[nCntFor2,3]+aAnosInv[nCntFor2,4] 
		aAnosInv[nCntFor2,3] := 0
		aAnosInv[nCntFor2,4] := 0
	next
	nVInvAno12 = nVInvAno12 / aMesCont[nPosFilis,1]

	nVInvAno24 := 0
	for nCntFor2 := 24 to 13 step -1
		nVInvAno24 += aAnosInv[nCntFor2,3]+aAnosInv[nCntFor2,4]
		aAnosInv[nCntFor2,3] := 0
		aAnosInv[nCntFor2,4] := 0		
	next
	if aMesCont[nPosFilis,2] != 0
		nVInvAno24 := nVInvAno24 / aMesCont[nPosFilis,2]
	else
		nVInvAno24 := 0
	endif
	if nVInvAno24 > 0 .or. nVInvAno12 > 0  .or. nVInvAno24 > 0 .or. nVInvAno12 > 0 
		aLocStok[nCntFor,5] := .t.
	endif
	aInfo2[nCntFor,7] += nVInvAno12 // nInvVenda
	aSint[nPosSint,37+7] += nVInvAno12 // nInvVenda

	aInfo2[nCntFor,10] += nVInvAno24 // nInv12Ante
	aSint[nPosSint,37+10] += nVInvAno24 // nInv12Ante
	
	if nInvAtualV + nInvAtualZ > 0
   		nInvComVda := nInvAtualV
   		nInvSemVda := nInvAtualZ
 	else
 		nInvComVda := 0
 		nInvSemVda := 0
 	endif
	
	aInfo2[nCntFor,13] += nInvComVda + nInvSemVda
	aSint[nPosSint,37+13] += nInvComVda + nInvSemVda

	aInfo2[nCntFor,14] += nInvSemVda
	aSint[nPosSint,37+14] += nInvSemVda
	
	if 	nInvSemVda + nInvComVda > 0 
		aLocStok[nCntFor,5] := .t.
	endif
next
//
cQuery := "SELECT VB8_FILIAL, VB8_STOCK, VB8_LOCAL, VB8_TIPLOC, VB8_ANO, VB8_MES, VB8_CRICOD, "
//
if VB8->(FieldPos("VB8_HITSBN")) > 0 
	cQuery += "COALESCE( SUM(VB8_HITSB + VB8_HIPERB + VB8_HITSBN), 0) SHITSB , "
else
	cQuery += "COALESCE( SUM(VB8_HITSB + VB8_HIPERB ), 0) SHITSB , "
endif
//
if VB8->(FieldPos("VB8_IMEDBN")) > 0 
	cQuery += "COALESCE( SUM(VB8_IMEDB + VB8_IMEDBN), 0) SIMEDB , "
else
	cQuery += "COALESCE( SUM(VB8_IMEDB), 0) SIMEDB , "
endif
//
cQuery += "COALESCE( SUM(VB8_8HRDB ), 0) S8HRDB , "
cQuery += "COALESCE( SUM(VB8_8HROB ), 0) S8HROB , "
cQuery += "COALESCE( SUM(VB8_24HRB ), 0) S24HRB , "
cQuery += "COALESCE( SUM(VB8_HIPERB), 0) SVDPERB, "
cQuery += "COALESCE( SUM(VB8_HITSO + VB8_HIPERO ), 0) SHITSO , "
cQuery += "COALESCE( SUM(VB8_IMEDO ), 0) SIMEDO , "
cQuery += "COALESCE( SUM(VB8_8HRDO ), 0) S8HRDO , "
cQuery += "COALESCE( SUM(VB8_8HROO ), 0) S8HROO , "
cQuery += "COALESCE( SUM(VB8_24HRO ), 0) S24HRO , "
cQuery += "COALESCE( SUM(VB8_HIPERO), 0) SVDPERO, "
cQuery += "COALESCE( SUM(VB8_HITSI ), 0) SHITSI , "
cQuery += "COALESCE( SUM(VB8_IMEDI ), 0) SIMEDI , "
cQuery += "COALESCE( SUM(VB8_8HRDI ), 0) S8HRDI , "
cQuery += "COALESCE( SUM(VB8_8HROI ), 0) S8HROI , "
cQuery += "COALESCE( SUM(VB8_24HRI ), 0) S24HRI , "
cQuery += "COALESCE( SUM(VB8_VDPERI), 0) SVDPERI, "
cQuery += "COALESCE( SUM(VB8_DEVBAL), 0) SDEVBAL, "
cQuery += "COALESCE( SUM(VB8_DEVOFI), 0) SDEVOFI, "
cQuery += "COALESCE( SUM(VB8_DEVINT), 0) SDEVINT, "
cQuery += "COALESCE( SUM(VB8_VALINV), 0) SVALINV, "
cQuery += "COALESCE( SUM(VB8_CUSBAL) + SUM(VB8_CUSBAN), 0) SCUSBAL, "
cQuery += "COALESCE( SUM(VB8_CUSOFI) + SUM(VB8_CUSOFN), 0) SCUSOFI, "
cQuery += "COALESCE( SUM(VB8_CUSFAB), 0) SCUSFAB, "
cQuery += "COALESCE( SUM(VB8_CUSDEV), 0) SCUSDEV, "
cQuery += "COALESCE( SUM(VB8_TOTBAL) + SUM(VB8_TOTBAN), 0) STOTBAL, "
cQuery += "COALESCE( SUM(VB8_TOTOFI) + SUM(VB8_TOTOFN), 0) STOTOFI, "
cQuery += "COALESCE( SUM(VB8_TOTINT), 0) STOTINT, "
cQuery += "COALESCE( SUM(VB8_TOTFAB), 0) STOTFAB, "
cQuery += "COALESCE( SUM(VB8_TOTBAN), 0) STOTBAN, "
cQuery += "COALESCE( SUM(VB8_TOTOFN), 0) STOTOFN "
cQuery += " FROM " + oSqlHlp:NoLock("VB8")
cQuery += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = VB8_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE  VB8.D_E_L_E_T_=' ' AND "
cQuery += " ( VB8_ANO >= '"+STRZERO(Year(ddatabase)-1,4)+"' OR (VB8_ANO = '"+STRZERO(Year(ddatabase)-2,4)+"' AND VB8_MES >= '"+STRZERO(Month(ddatabase),2)+"'))"
cQuery += " GROUP BY VB8_FILIAL, VB8_STOCK, VB8_LOCAL, VB8_TIPLOC, VB8_ANO, VB8_MES, VB8_CRICOD "
cQuery += " ORDER BY VB8_FILIAL, VB8_LOCAL, VB8_TIPLOC, VB8_CRICOD, VB8_ANO, VB8_MES, VB8_STOCK "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )

while !(cQryAl001)->(eof()) .and. !lAbort

	if Alltrim((cQryAl001)->(VB8_ANO)) + Alltrim((cQryAl001)->(VB8_MES)) > Left(dtos(ddatabase),6)
		(cQryAl001)->(DBSkip())
		loop
	endif

	cLocalVB8 := IIF( Empty((cQryAl001)->(VB8_LOCAL)),"D1",(cQryAl001)->(VB8_LOCAL))
	cTipLoVB8 := IIF( cLocalVB8 == "D1","M","N")
	cCriCoVB8 := IIF( Empty((cQryAl001)->(VB8_CRICOD)),"00",(cQryAl001)->(VB8_CRICOD))
	
	
	if  cChaveScan != cLocalVB8 + cTipLoVB8 + cCriCoVB8 + (cQryAl001)->(VB8_FILIAL)
		if nIndSint == 0 .or. aSint[nIndSint,1] != (cQryAl001)->(VB8_FILIAL) .or. aSint[nIndSint,53] != cLocalVB8
			nIndSint := aScan(aSint,{|x| x[1] == (cQryAl001)->(VB8_FILIAL) .and. x[53] == cLocalVB8})
			if nIndSint == 0
				(cQryAl001)->(dbskip())
				loop
			endif
		endif
		cChaveScan := cLocalVB8 + cTipLoVB8 + cCriCoVB8 + (cQryAl001)->(VB8_FILIAL)
		nPos := aScan(aLocStok,{|x| x[1]+x[2]+x[3]+x[4] == cLocalVB8 + cTipLoVB8 + cCriCoVB8 + (cQryAl001)->(VB8_FILIAL)})
		if nPos == 0
			aAdd(aLocStok, {cLocalVB8, cTipLoVB8, cCriCoVB8,(cQryAl001)->(VB8_FILIAL), .f. })
			aAdd(aInfo,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
			aAdd(aInfo2,{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
			nPos := Len(aLocStok)
		endif
		//
		aLocStok[nPos,5] := .t.
	endif
	//
	// se for dentro do mes computa tudo
	//
	if VAL((cQryAl001)->(VB8_MES)) == nMes .and. VAL((cQryAl001)->(VB8_ANO)) == nAno
		aInfo2[nPos,1] += (cQryAl001)->(STOTBAL) // nVenBal
		aInfo2[nPos,2] += (cQryAl001)->(STOTOFI) // nVenOfi
		aInfo2[nPos,3] += (cQryAl001)->(STOTINT) // nVenInt
		aInfo2[nPos,4] += (cQryAl001)->(SDEVBAL) // nDevBal
		aInfo2[nPos,5] += (cQryAl001)->(SDEVOFI) // nDevOfi
		aInfo2[nPos,6] += (cQryAl001)->(SDEVINT) // nDevInt
		aInfo2[nPos,15] += (cQryAl001)->(SCUSBAL) + (cQryAl001)->(SCUSOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(SCUSFAB) - (cQryAl001)->(SCUSDEV)
		//
		aSint[nIndSint,37+1] += (cQryAl001)->(STOTBAL) // nVenBal
		aSint[nIndSint,37+2] += (cQryAl001)->(STOTOFI) // nVenOfi
		aSint[nIndSint,37+3] += (cQryAl001)->(STOTINT) // nVenInt
		aSint[nIndSint,37+4] += (cQryAl001)->(SDEVBAL) // nDevBal
		aSint[nIndSint,37+5] += (cQryAl001)->(SDEVOFI) // nDevOfi
		aSint[nIndSint,37+6] += (cQryAl001)->(SDEVINT) // nDevInt
		aSint[nIndSint,37+15] += (cQryAl001)->(SCUSBAL) + (cQryAl001)->(SCUSOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(SCUSFAB) - (cQryAl001)->(SCUSDEV)
	
		if (cQryAl001)->(VB8_STOCK) == "S"
	 		aInfo[nPos,1]+=(cQryAl001)->(SHITSB) // nCSTH
			aInfo[nPos,2]+=(cQryAl001)->(SIMEDB) // nCS1PF
			aInfo[nPos,3]+=(cQryAl001)->(S24HRB) // nCSI24F
			aInfo[nPos,4]+=(cQryAl001)->(SVDPERB) // nCSLS
			aInfo[nPos,9]+=(cQryAl001)->(SHITSO) // nSSTH
			aInfo[nPos,10]+=(cQryAl001)->(SIMEDO) // nSS1PF
			aInfo[nPos,11]+=(cQryAl001)->(S24HRO) // nSSI24F
			aInfo[nPos,12]+=(cQryAl001)->(SVDPERO) // nSSLS
			aInfo[nPos,17]+=(cQryAl001)->(SHITSI) // nISTH
			aInfo[nPos,18]+=(cQryAl001)->(SIMEDI) // nIS1PF
			aInfo[nPos,19]+=(cQryAl001)->(S24HRI) // nISI24F
			aInfo[nPos,20]+=(cQryAl001)->(SVDPERI) // nISLS
			aInfo[nPos,25]+=(cQryAl001)->(S8HRDB) // nCSID8
			aInfo[nPos,26]+=(cQryAl001)->(S8HROB) // nCSIO8
			aInfo[nPos,29]+=(cQryAl001)->(S8HRDO) // nSSID8
			aInfo[nPos,30]+=(cQryAl001)->(S8HROO) // nSSIO8
			aInfo[nPos,33]+=(cQryAl001)->(S8HRDI) // nISID8
			aInfo[nPos,34]+=(cQryAl001)->(S8HROI) // nISIO8
			//
	 		aSint[nIndSint,2]+=(cQryAl001)->(SHITSB) // nCSTH
			aSint[nIndSint,3]+=(cQryAl001)->(SIMEDB) // nCS1PF
			aSint[nIndSint,4]+=(cQryAl001)->(S24HRB) // nCSI24F
			aSint[nIndSint,5]+=(cQryAl001)->(SVDPERB) // nCSLS
			aSint[nIndSint,10]+=(cQryAl001)->(SHITSO) // nSSTH
			aSint[nIndSint,11]+=(cQryAl001)->(SIMEDO) // nSS1PF
			aSint[nIndSint,12]+=(cQryAl001)->(S24HRO) // nSSI24F
			aSint[nIndSint,13]+=(cQryAl001)->(SVDPERO) // nSSLS
			aSint[nIndSint,18]+=(cQryAl001)->(SHITSI) // nISTH
			aSint[nIndSint,19]+=(cQryAl001)->(SIMEDI) // nIS1PF
			aSint[nIndSint,20]+=(cQryAl001)->(S24HRI) // nISI24F
			aSint[nIndSint,21]+=(cQryAl001)->(SVDPERI) // nISLS
			aSint[nIndSint,26]+=(cQryAl001)->(S8HRDB) // nCSID8
			aSint[nIndSint,27]+=(cQryAl001)->(S8HROB) // nCSIO8
			aSint[nIndSint,30]+=(cQryAl001)->(S8HRDO) // nSSID8
			aSint[nIndSint,31]+=(cQryAl001)->(S8HROO) // nSSIO8
			aSint[nIndSint,34]+=(cQryAl001)->(S8HRDI) // nISID8
			aSint[nIndSint,35]+=(cQryAl001)->(S8HROI) // nISIO8
		else
			aInfo[nPos,5]+=(cQryAl001)->(SHITSB) // nCNSTH
			aInfo[nPos,6]+=(cQryAl001)->(SIMEDB) // nCNS1PF
			aInfo[nPos,7]+=(cQryAl001)->(S24HRB) // nCNSI24F
			aInfo[nPos,8]+=(cQryAl001)->(SVDPERB) // nCNSLS
			aInfo[nPos,13]+=(cQryAl001)->(SHITSO) // nSNSTH
			aInfo[nPos,14]+=(cQryAl001)->(SIMEDO) // nSNS1PF
			aInfo[nPos,15]+=(cQryAl001)->(S24HRO) // nSNSI24F
			aInfo[nPos,16]+=(cQryAl001)->(SVDPERO) // nSNSLS
			aInfo[nPos,21]+=(cQryAl001)->(SHITSI) // nINSTH
			aInfo[nPos,22]+=(cQryAl001)->(SIMEDI) // nINS1PF
			aInfo[nPos,23]+=(cQryAl001)->(S24HRI) // nINSI24F
			aInfo[nPos,24]+=(cQryAl001)->(SVDPERI) // nINSLS
			aInfo[nPos,27]+=(cQryAl001)->(S8HRDB) // nCNSID8
			aInfo[nPos,28]+=(cQryAl001)->(S8HROB) // nCNSIO8
			aInfo[nPos,31]+=(cQryAl001)->(S8HRDO) // nSNSID8
			aInfo[nPos,32]+=(cQryAl001)->(S8HROO) // nSNSIO8
			aInfo[nPos,35]+=(cQryAl001)->(S8HRDI) // nINSID8
			aInfo[nPos,36]+=(cQryAl001)->(S8HROI) //nINSIO8
			//
			aSint[nIndSint,6]+=(cQryAl001)->(SHITSB) // nCNSTH
			aSint[nIndSint,7]+=(cQryAl001)->(SIMEDB) // nCNS1PF
			aSint[nIndSint,8]+=(cQryAl001)->(S24HRB) // nCNSI24F
			aSint[nIndSint,9]+=(cQryAl001)->(SVDPERB) // nCNSLS
			aSint[nIndSint,14]+=(cQryAl001)->(SHITSO) // nSNSTH
			aSint[nIndSint,15]+=(cQryAl001)->(SIMEDO) // nSNS1PF
			aSint[nIndSint,16]+=(cQryAl001)->(S24HRO) // nSNSI24F
			aSint[nIndSint,17]+=(cQryAl001)->(SVDPERO) // nSNSLS
			aSint[nIndSint,22]+=(cQryAl001)->(SHITSI) // nINSTH
			aSint[nIndSint,23]+=(cQryAl001)->(SIMEDI) // nINS1PF
			aSint[nIndSint,24]+=(cQryAl001)->(S24HRI) // nINSI24F
			aSint[nIndSint,25]+=(cQryAl001)->(SVDPERI) // nINSLS
			aSint[nIndSint,28]+=(cQryAl001)->(S8HRDB) // nCNSID8
			aSint[nIndSint,29]+=(cQryAl001)->(S8HROB) // nCNSIO8
			aSint[nIndSint,32]+=(cQryAl001)->(S8HRDO) // nSNSID8
			aSint[nIndSint,33]+=(cQryAl001)->(S8HROO) // nSNSIO8
			aSint[nIndSint,36]+=(cQryAl001)->(S8HRDI) // nINSID8
			aSint[nIndSint,37]+=(cQryAl001)->(S8HROI) //nINSIO8
		endif
	endif

	if (cQryAl001)->(VB8_ANO) + (cQryAl001)->(VB8_MES)  > cData12
		aInfo2[nPos,8] += (cQryAl001)->(STOTBAL) + (cQryAl001)->(STOTOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(STOTFAB)  - (cQryAl001)->(SCUSDEV)// nVda12Mes
		aInfo2[nPos,9] += (cQryAl001)->(SCUSBAL) + (cQryAl001)->(SCUSOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(SCUSFAB)  - (cQryAl001)->(SCUSDEV)// nCus12Mes
		//
		aSint[nIndSint,37+8] += (cQryAl001)->(STOTBAL) + (cQryAl001)->(STOTOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(STOTFAB)  - (cQryAl001)->(SCUSDEV)// nVda12Mes
		aSint[nIndSint,37+9] += (cQryAl001)->(SCUSBAL) + (cQryAl001)->(SCUSOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(SCUSFAB)  - (cQryAl001)->(SCUSDEV)// nCus12Mes
	elseif (cQryAl001)->(VB8_ANO) + (cQryAl001)->(VB8_MES)  > cData24
		aInfo2[nPos,11] += (cQryAl001)->(STOTBAL) + (cQryAl001)->(STOTOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(STOTFAB)  - (cQryAl001)->(SCUSDEV)// nVda12Ante
		aInfo2[nPos,12] += (cQryAl001)->(SCUSBAL) + (cQryAl001)->(SCUSOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(SCUSFAB)  - (cQryAl001)->(SCUSDEV)// nCus12Ante
		//
		aSint[nIndSint,37+11] += (cQryAl001)->(STOTBAL) + (cQryAl001)->(STOTOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(STOTFAB)  - (cQryAl001)->(SCUSDEV)// nVda12Ante
		aSint[nIndSint,37+12] += (cQryAl001)->(SCUSBAL) + (cQryAl001)->(SCUSOFI) + (cQryAl001)->(STOTINT) + (cQryAl001)->(SCUSFAB)  - (cQryAl001)->(SCUSDEV)// nCus12Ante
	endif

	(cQryAl001)->(DBSkip())
enddo
//
//
// troca, em cada linha, o valor da filial pelo codigo da jd
//
for nCntFor := 1 to Len(aLocStok)
	nPosFilis := aScan(aFilis,{|x| Alltrim(x[1]) == Alltrim(aLocStok[nCntFor,4]) } )
	if nPosFilis > 0 
		aLocStok[nCntFor,4] := Alltrim(aFilis[nPosFilis,2])
	endif
next
//
for nCntFor := 1 to Len(aSint)
	nPosFilis := aScan(aFilis,{|x| Alltrim(x[1]) == Alltrim(aSint[nCntFor,1]) } )
	if nPosFilis > 0 
		aSint[nCntFor,1] := Alltrim(aFilis[nPosFilis,2])
	endif
next

//
// Os tres vetores estao prontos aInfo, aInfo2 e aLocStok + o aInt com os Sintéticos
// Os arquivos ja estão naturalmente ordenados por VB8_FILIAL, VB8_LOCAL, VB8_TIPLOC, VB8_CRICOD
//
///////////////
cFileTemp := "/logsmil/pmm/"+UPPER(cArquivo) // arquivo em local temporario
makeDir( "/logsmil" )
makeDir( "/logsmil/pmm" )
iif(FILE(cFileTemp),nHnd := FOPEN( cFileTemp, 1 ),nHnd := FCREATE( cFileTemp ))

cDirSave := Alltrim(MV_PAR01)
cFileDest := Alltrim(cFileDest)
cPath := Alltrim(cPath)

If Empty(cPath)
  cFileDest := Iif(!Empty(Right(cDirSave, 1)) .AND. Right(cDirSave, 1) <> "/" .AND. Right(cDirSave, 1) <> "\", cDirSave, Left(cDirSave, Len(cDirSave) - 1))+"\"
Else
  cFileDest := Iif(!Empty(Right(cPath, 1))    .AND. Right(cPath, 1) <> "/"    .AND. Right(cPath, 1) <> "\",    cPath,    Left(cPath, Len(cPath) - 1)) + "/pmm/"
Endif

cSavePath := cFileDest
cFileDest += Alltrim(cArquivo)

cFileDest := StrTran(cFileDest, "\", "/") 

aVetCods := {}
cSourAcc := ""
//
aArquivo := {}
For nCntFor := 1 to Len(aLocStok)

	if 	aLocStok[nCntFor,5]

		nVenBal    := 0
		nVenOfi    := 0
		nVenInt    := 0
		nDevBal    := 0
		nDevOfi    := 0
		nDevInt    := 0

		if Empty(aLocStok[nCntFor,3])
			aLocStok[nCntFor,3] := "00"
		endif

		if Empty(aLocStok[nCntFor,1])
			aLocStok[nCntFor,1] := "D1"
			aLocStok[nCntFor,2] := "M"
		endif
	
		nVenBal    := ONJD09VVDA( JD09GtFil(aLocStok[nCntFor,4]), aLocStok[nCntFor,3], aLocStok[nCntFor,1], cPrefBAL )
		nVenOfi    := ONJD09VVDA( JD09GtFil(aLocStok[nCntFor,4]), aLocStok[nCntFor,3], aLocStok[nCntFor,1], cPrefOFI )
		nVenInt    := aInfo2[nCntFor,3]
		nDevBal    := ONJD09VDEV( JD09GtFil(aLocStok[nCntFor,4]), aLocStok[nCntFor,3], aLocStok[nCntFor,1], cPrefBAL )
		nDevOfi    := ONJD09VDEV( JD09GtFil(aLocStok[nCntFor,4]), aLocStok[nCntFor,3], aLocStok[nCntFor,1], cPrefOFI )
		nDevInt    := aInfo2[nCntFor,6]
		nCSTH      := aInfo[nCntFor,1] // <==
		nCS1PF     := aInfo[nCntFor,2]
		nCSI24F    := aInfo[nCntFor,3]
		nCSLS      := aInfo[nCntFor,4]
		nSSTH      := aInfo[nCntFor,9]
		nSS1PF     := aInfo[nCntFor,10]
		nSSI24F    := aInfo[nCntFor,11]
		nSSLS      := aInfo[nCntFor,12]
		nISTH      := aInfo[nCntFor,17]
		nIS1PF     := aInfo[nCntFor,18]
		nISI24F    := aInfo[nCntFor,19]
		nISLS      := aInfo[nCntFor,20]
		nCSID8     := aInfo[nCntFor,25]
		nCSIO8     := aInfo[nCntFor,26]
		nSSID8     := aInfo[nCntFor,29]
		nSSIO8     := aInfo[nCntFor,30]
		nISID8     := aInfo[nCntFor,33]
		nISIO8     := aInfo[nCntFor,34]
		nCNSTH     := aInfo[nCntFor,5] // <==
		nCNS1PF    := aInfo[nCntFor,6]
		nCNSI24F   := aInfo[nCntFor,7]
		nCNSLS     := aInfo[nCntFor,8]
		nSNSTH     := aInfo[nCntFor,13]
		nSNS1PF    := aInfo[nCntFor,14]
		nSNSI24F   := aInfo[nCntFor,15]
		nSNSLS     := aInfo[nCntFor,16]
		nINSTH     := aInfo[nCntFor,21]
		nINS1PF    := aInfo[nCntFor,22]
		nINSI24F   := aInfo[nCntFor,23]
		nINSLS     := aInfo[nCntFor,24]
		nCNSID8    := aInfo[nCntFor,27]
		nCNSIO8    := aInfo[nCntFor,28]
		nSNSID8    := aInfo[nCntFor,31]
		nSNSIO8    := aInfo[nCntFor,32]
		nINSID8    := aInfo[nCntFor,35]
		nINSIO8    := aInfo[nCntFor,36]
		nInv12Mes  := aInfo2[nCntFor,7]
		nVda12Mes  := aInfo2[nCntFor,8]
		nCus12Mes  := aInfo2[nCntFor,9]
		nInv12Ante := aInfo2[nCntFor,10]
		nVda12Ante := aInfo2[nCntFor,11]
		nCus12Ante := aInfo2[nCntFor,12]
		nInvVenda  := aInfo2[nCntFor,13]
		nInvNVenda := aInfo2[nCntFor,14]
		nCusNoMes  := aInfo2[nCntFor,15]
		//
		cMainAcc := Left(IIF(!Empty(cAccount), cAccount, MV_PAR02) +SPACE(6),6)
		cSourAcc := aLocStok[nCntFor,4]
		cM12 := Left(cMainAcc,2)
		cM36 := Right(cMainAcc,4)
		cS12 := Left(cSourAcc,2)
		cS36 := Right(cSourAcc,4)

		// cU0 := "U"
		// cU0 += cM12
		// cU0 += cS12
		// cU0 += cM36
		// cU0 += "0"
		// cU0 += "V2"
		// cU0 += STRZERO(nAno,4) + STRZERO(nMes,2)
		// cU0 += SPACE(3)
		// cU0 +="P"
		// cU0 += cS36
		// cU0 += STRZERO(INT(nVenBal),9)
		// cU0 += STRZERO(INT(nVenOfi),9)
		// cU0 += STRZERO(INT(nVenInt),9)
		// cU0 += STRZERO(INT(nDevBal),8)+"-"
		// cU0 += STRZERO(INT(nDevOfi),8)+"-"
		// cU0 += SPACE(6)
		// cU0 += aLocStok[nCntFor,1]
		// cU0 += aLocStok[nCntFor,2]
	
		// cUI := "U"
		// cUI += cM12
		// cUI += cS12
		// cUI += cM36
		// cUI += "I"
		// cUI += Space(11)
		// cUI += "P"
		// cUI += cS36
		// cUI += STRZERO(INT(nDevInt),8)+"-"
		// cUI += space(42)
		// cUI += aLocStok[nCntFor,1]
		// cUI += aLocStok[nCntFor,2]


		cFilAtu := JD09GtFil(aLocStok[nCntFor,4])
		cCodCri := aLocStok[nCntFor,3]
		cTipo   := aLocStok[nCntFor,1] // original ou não
		cOri    := nil // prefori nil vem tudo
		
		cUJ := "U"
		cUJ += cM12
		cUJ += cS12
		cUJ += cM36
		cUJ += "J"
		cUJ += cCodCri
		cUJ += space(1)
		cUJ += Space(8)
		cUJ += "P"
		cUJ += cS36
		cUJ += STRZERO(INT(JD09MdInv(cFilAtu, cCodCri, cTipo)) , 9)
		cUJ += STRZERO(INT(JD0924MdInv(cFilAtu, cCodCri, cTipo)) , 9)
		cUJ += STRZERO(INT(ONJD0912VDA(cFilAtu, cCodCri, cTipo, Nil) - JD09DEVL12(cFilAtu, cCodCri, cTipo, Nil)), 9)
		cUJ += STRZERO(INT(ONJD0924VDA(cFilAtu, cCodCri, cTipo, Nil) - JD09DEVP12(cFilAtu, cCodCri, cTipo, Nil)), 9)
		cUJ += STRZERO(INT((nVenOfi + nVenBal + nVenInt) - nDevBal - nDevOfi - nDevInt),9)
		cUJ += SPACE(6)
		cUJ += cTipo
		cUJ += aLocStok[nCntFor,2]
		
		cUK := "U"
		cUK += cM12
		cUK += cS12
		cUK += cM36
		cUK += "K"
		cUK += cCodCri
		cUK += space(1)
		cUK += Space(8)
		cUK += "P"
		cUK += cS36
		cUK += STRZERO(INT(ONJD09L12Cos(cFilAtu, cCodCri, cTipo) - JD09DECL12(cFilAtu, cCodCri, cTipo)), 9) // custo media 12 meses ant
		cUK += STRZERO(INT(ONJD09P12Ct(cFilAtu, cCodCri, cTipo)  - JD09DECP12(cFilAtu, cCodCri, cTipo)), 9) // custo media 12 meses ant
		cUK += STRZERO(INT(ONJD09Cust(cFilAtu, cCodCri, cTipo)   - JD09CDEV(cFilAtu, cCodCri, cTipo)), 9)  // custo
		cUK += STRZERO(INT(ONJD09TotInv(cFilAtu, cCodCri, cTipo)), 9) // inventario
		cUK += STRZERO(INT(ONJD09ZeroV(cFilAtu, cCodCri, cTipo)), 9) // zero vendas
		cUK += SPACE(6)
		cUK += aLocStok[nCntFor,1]
		cUK += aLocStok[nCntFor,2]
		
		cUL := "U"
		cUL += cM12
		cUL += cS12
		cUL += cM36
		cUL += "L"
		cUL += aLocStok[nCntFor,3]
		cUL += space(1)
		cUL += Space(8)
		cUL += "P"
		cUL += cS36
		cUL += STRZERO(INT(nCSTH),5) // TODO: VENDASOFI
		cUL += STRZERO(INT(nCS1PF),5)
		cUL += STRZERO(INT(nCSI24F),5)
		cUL += STRZERO(INT(nCSLS),5)
		cUL += "00000"
		cUL += "00000"
		cUL += "00000"
		cUL += "00000"
		cUL += "00000"
		cUL += "00000"
		cUL += SPACE(1)
		cUL += aLocStok[nCntFor,1]
		cUL += aLocStok[nCntFor,2]
		
		cUM := "U"
		cUM += cM12
		cUM += cS12
		cUM += cM36
		cUM += "M"
		cUM += aLocStok[nCntFor,3]
		cUM += space(1)
		cUM += Space(8)
		cUM += "P"
		cUM += cS36
		cUM += "00000"
		cUM += "00000"
		cUM += STRZERO(INT(nCNSTH),5)    // 37-41 <== balcao...sem estoque...venda perdida mes
		cUM += STRZERO(INT(nCNS1PF),5)   // 42-46 <== total hits atendido 100%
		cUM += STRZERO(INT(nCNSI24F),5)  // 47-51 <== balcao …sem estoque … Qtd de hits, excluindo os atendimentos imediato, foram atendidos em 24horas no mes?
		cUM += STRZERO(INT(nCNSLS),5)    // 52-56 <== balcao …sem estoque … Qtd de hits não foram atendidas por venda perdida no mes?
		cUM += "00000"
		cUM += "00000"
		cUM += "00000"
		cUM += "00000"
		cUM += SPACE(1)
		cUM += aLocStok[nCntFor,1]
		cUM += aLocStok[nCntFor,2]
		
		cUN := "U"
		cUN += cM12
		cUN += cS12
		cUN += cM36
		cUN += "N"
		cUN += aLocStok[nCntFor,3]
		cUN += space(1)
		cUN += Space(8)
		cUN += "P"
		cUN += cS36
		cUN += "00000"
		cUN += "00000"
		cUN += "00000"
		cUN += "00000"
		cUN += STRZERO(INT(nSSTH),5) // TODO:VENDASOFI
		cUN += STRZERO(INT(nSS1PF),5) // TODO:VENDASOFI
		cUN += STRZERO(INT(nSSI24F),5)
		cUN += STRZERO(INT(nSSLS),5)
		cUN += "00000"
		cUN += "00000"
		cUN += SPACE(1)
		cUN += aLocStok[nCntFor,1]
		cUN += aLocStok[nCntFor,2]
		
		cUO := "U"
		cUO += cM12
		cUO += cS12
		cUO += cM36
		cUO += "O"
		cUO += aLocStok[nCntFor,3]
		cUO += space(1)
		cUO += Space(8)
		cUO += "P"
		cUO += cS36
		cUO += "00000"
		cUO += "00000"
		cUO += "00000"
		cUO += "00000"
		cUO += "00000"
		cUO += "00000"
		cUO += STRZERO(INT(nSNSTH),5) // TODO:VENDASOFI
		cUO += STRZERO(INT(nSNS1PF),5)
		cUO += STRZERO(INT(nSNSI24F),5)
		cUO += STRZERO(INT(nSNSLS),5)
		cUO += SPACE(1)
		cUO += aLocStok[nCntFor,1]
		cUO += aLocStok[nCntFor,2]
		
		cUP := "U"
		cUP += cM12
		cUP += cS12
		cUP += cM36
		cUP += "P"
		cUP += aLocStok[nCntFor,3]
		cUP += space(1)
		cUP += Space(8)
		cUP += "P"
		cUP += cS36
		cUP += "00000"
		cUP += "00000"
		cUP += "00000"
		cUP += "00000"
		cUP += "00000"
		cUP += "00000"
		cUP += "00000"
		cUP += "00000"
		cUP += STRZERO(INT(nISTH),5)
		cUP += STRZERO(INT(nIS1PF),5)
		cUP += SPACE(1)
		cUP += aLocStok[nCntFor,1]
		cUP += aLocStok[nCntFor,2]
		
		cUQ := "U"
		cUQ += cM12
		cUQ += cS12
		cUQ += cM36
		cUQ += "Q"
		cUQ += aLocStok[nCntFor,3]
		cUQ += space(1)
		cUQ += Space(8)
		cUQ += "P"
		cUQ += cS36
		cUQ += STRZERO(INT(nISI24F),5)
		cUQ += STRZERO(INT(nISLS),5)
		cUQ += "00000"
		cUQ += "00000"
		cUQ += "00000"
		cUQ += "00000"
		cUQ += "00000"
		cUQ += "00000"
		cUQ += "00000"
		cUQ += "00000"
		cUQ += SPACE(1)
		cUQ += aLocStok[nCntFor,1]
		cUQ += aLocStok[nCntFor,2]
		
		cUR := "U"
		cUR += cM12
		cUR += cS12
		cUR += cM36
		cUR += "R"
		cUR += aLocStok[nCntFor,3]
		cUR += space(1)
		cUR += Space(8)
		cUR += "P"
		cUR += cS36
		cUR += STRZERO(INT(nINSTH),5)
		cUR += STRZERO(INT(nINS1PF),5)
		cUR += STRZERO(INT(nINSI24F),5)
		cUR += STRZERO(INT(nINSLS),5)
		cUR += "00000"
		cUR += "00000"
		cUR += "00000"
		cUR += "00000"
		cUR += "00000"
		cUR += "00000"
		cUR += SPACE(1)
		cUR += aLocStok[nCntFor,1]
		cUR += aLocStok[nCntFor,2]
		
		cUS := "U"
		cUS += cM12
		cUS += cS12
		cUS += cM36
		cUS += "S"
		cUS += aLocStok[nCntFor,3]
		cUS += space(1)
		cUS += Space(8)
		cUS += "P"
		cUS += cS36
		cUS += "00000"
		cUS += "00000"
		cUS += Space(10)
		cUS += STRZERO(  INT( nDevBal +nDevOfi + nDevInt ),8  )+"-"
		cUS += Space(22)
		cUS += aLocStok[nCntFor,1]
		cUS += aLocStok[nCntFor,2]
		
		cUT := "U"
		cUT += cM12
		cUT += cS12
		cUT += cM36
		cUT += "T"
		cUT += aLocStok[nCntFor,3]
		cUT += space(1)
		cUT += Space(8)
		cUT += "P"
		cUT += cS36
		cUT += STRZERO(INT(nCSID8),5)
		cUT += STRZERO(INT(nCSIO8),5)
		cUT += STRZERO(INT(nCNSID8),5)
		cUT += STRZERO(INT(nCNSIO8),5)
		cUT += STRZERO(INT(nSSID8),5)
		cUT += STRZERO(INT(nSSIO8),5)
		cUT += STRZERO(INT(nSNSID8),5)
		cUT += STRZERO(INT(nSNSIO8),5)
		cUT += STRZERO(INT(nISID8),5)
		cUT += STRZERO(INT(nISIO8),5)
		cUT += SPACE(1)
		cUT += aLocStok[nCntFor,1]
		cUT += aLocStok[nCntFor,2]
		
		cUU := "U"
		cUU += cM12
		cUU += cS12
		cUU += cM36
		cUU += "U"
		cUU += aLocStok[nCntFor,3]
		cUU += space(1)
		cUU += Space(8)
		cUU += "P"
		cUU += cS36
		cUU += STRZERO(INT(nINSID8),5)
		cUU += STRZERO(INT(nINSIO8),5)
		cUU += SPACE(40)
		cUU += SPACE(1)
		cUU += aLocStok[nCntFor,1]
		cUU += aLocStok[nCntFor,2]
		
	//	aAdd(aArquivo,{"U0", cSourAcc, cU0, "A"+ aLocStok[nCntFor,3] + aLocStok[nCntFor,1]+"00"})
	//	aAdd(aArquivo,{"UI", cSourAcc, cUI, "A"+ aLocStok[nCntFor,3] + aLocStok[nCntFor,1]+"01"})
		aAdd(aArquivo,{"UJ", cSourAcc, cUJ, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"02" })  // loc / tip / cricod / filial
		aAdd(aArquivo,{"UK", cSourAcc, cUK, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"03" })
		aAdd(aArquivo,{"UL", cSourAcc, cUL, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"04" })
		aAdd(aArquivo,{"UM", cSourAcc, cUM, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"05" })
		aAdd(aArquivo,{"UN", cSourAcc, cUN, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"06" })
		aAdd(aArquivo,{"UO", cSourAcc, cUO, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"07" })
		aAdd(aArquivo,{"UP", cSourAcc, cUP, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"08" })
		aAdd(aArquivo,{"UQ", cSourAcc, cUQ, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"09" })
		aAdd(aArquivo,{"UR", cSourAcc, cUR, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"10" })
		aAdd(aArquivo,{"US", cSourAcc, cUS, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"11" })
		aAdd(aArquivo,{"UT", cSourAcc, cUT, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"12" })
		aAdd(aArquivo,{"UU", cSourAcc, cUU, "B", aLocStok[nCntFor,3] , aLocStok[nCntFor,1],"13" })
	
	endif
	
next
//
//
//
//
For nCntFor := 1 to Len(aSint)
	cLocSint   := aSint[nCntFor,53]

	nVenBal    := 0
	nVenOfi    := 0
	nVenInt    := 0
	nDevBal    := 0
	nDevOfi    := 0
	nDevInt    := 0

	nVenBal    := ONJD09VVDA( JD09GtFil(aSint[nCntFor,1]), "%", cLocSint, cPrefBAL )
	nVenOfi    := ONJD09VVDA( JD09GtFil(aSint[nCntFor,1]), "%", cLocSint, cPrefOFI )
	nVenInt    := aSint[nCntFor,37+3]
	nDevBal    := ONJD09VDEV( JD09GtFil(aSint[nCntFor,1]), "%", cLocSint, cPrefBAL )
	nDevOfi    := ONJD09VDEV( JD09GtFil(aSint[nCntFor,1]), "%", cLocSint, cPrefOFI )
	nDevInt    := aSint[nCntFor,37+6]
	nCSTH      := aSint[nCntFor,1+1]
	nCS1PF     := aSint[nCntFor,1+2]
	nCSI24F    := aSint[nCntFor,1+3]
	nCSLS      := aSint[nCntFor,1+4]
	nSSTH      := aSint[nCntFor,1+9]
	nSS1PF     := aSint[nCntFor,1+10]
	nSSI24F    := aSint[nCntFor,1+11]
	nSSLS      := aSint[nCntFor,1+12]
	nISTH      := aSint[nCntFor,1+17]
	nIS1PF     := aSint[nCntFor,1+18]
	nISI24F    := aSint[nCntFor,1+19]
	nISLS      := aSint[nCntFor,1+20]
	nCSID8     := aSint[nCntFor,1+25]
	nCSIO8     := aSint[nCntFor,1+26]
	nSSID8     := aSint[nCntFor,1+29]
	nSSIO8     := aSint[nCntFor,1+30]
	nISID8     := aSint[nCntFor,1+33]
	nISIO8     := aSint[nCntFor,1+34]
	nCNSTH     := aSint[nCntFor,1+5]
	nCNS1PF    := aSint[nCntFor,1+6]
	nCNSI24F   := aSint[nCntFor,1+7]
	nCNSLS     := aSint[nCntFor,1+8]
	nSNSTH     := aSint[nCntFor,1+13]
	nSNS1PF    := aSint[nCntFor,1+14]
	nSNSI24F   := aSint[nCntFor,1+15]
	nSNSLS     := aSint[nCntFor,1+16]
	nINSTH     := aSint[nCntFor,1+21]
	nINS1PF    := aSint[nCntFor,1+22]
	nINSI24F   := aSint[nCntFor,1+23]
	nINSLS     := aSint[nCntFor,1+24]
	nCNSID8    := aSint[nCntFor,1+27]
	nCNSIO8    := aSint[nCntFor,1+28]
	nSNSID8    := aSint[nCntFor,1+31]
	nSNSIO8    := aSint[nCntFor,1+32]
	nINSID8    := aSint[nCntFor,1+35]
	nINSIO8    := aSint[nCntFor,1+36]
	nInv12Mes  := aSint[nCntFor,37+7]
	nVda12Mes  := aSint[nCntFor,37+8]
	nCus12Mes  := aSint[nCntFor,37+9]
	nInv12Ante := aSint[nCntFor,37+10]
	nVda12Ante := aSint[nCntFor,37+11]
	nCus12Ante := aSint[nCntFor,37+12]
	nInvVenda  := aSint[nCntFor,37+13]
	nInvNVenda := aSint[nCntFor,37+14]
	nCusNoMes  := aSint[nCntFor,37+15]
	
	//
	cMainAcc := Left(IIF(!Empty(cAccount), cAccount, MV_PAR02) +SPACE(6),6)
	cSourAcc := aSint[nCntFor,1]
	cM12 := Left(cMainAcc,2)
	cM36 := Right(cMainAcc,4)
	cS12 := Left(cSourAcc,2)
	cS36 := Right(cSourAcc,4)
	//
	cU0 := "U"
	cU0 += cM12
	cU0 += cS12
	cU0 += cM36
	cU0 += "0"
	cU0 += "V2"
	cU0 += STRZERO(nAno,4) + STRZERO(nMes,2)
	cU0 += SPACE(3)
	cU0 +="P"
	cU0 += cS36
	cU0 += STRZERO(INT(nVenBal),9)
	cU0 += STRZERO(INT(nVenOfi),9)
	cU0 += STRZERO(INT(nVenInt),9)
	cU0 += STRZERO(INT(nDevBal),8)+"-"
	cU0 += STRZERO(INT(nDevOfi),8)+"-"
	cU0 += SPACE(6)
	cU0 += cLocSint
	cU0 += IIF(cLocSint=="D1","M","N")

	cUI := "U"
	cUI += cM12
	cUI += cS12
	cUI += cM36
	cUI += "I"
	cUI += Space(11)
	cUI += "P"
	cUI += cS36
	cUI += STRZERO(INT(nDevInt),8)+"-"
	cUI += space(42)
	cUI += cLocSint
	cUI += IIF(cLocSint=="D1","M","N")

	cFilAtu := JD09GtFil(aSint[nCntFor,1])
	cCodCri := "%"
	cTipo   := cLocSint // original ou não
	
	cUJ := "U"
	cUJ += cM12
	cUJ += cS12
	cUJ += cM36
	cUJ += "J"
	cUJ += "  "
	cUJ += space(1)
	cUJ += Space(8)
	cUJ += "P"
	cUJ += cS36
	cUJ += STRZERO(INT(JD09MdInv(cFilAtu, cCodCri, cLocSint)), 9)
	cUJ += STRZERO(INT(JD0924MdInv(cFilAtu, cCodCri, cLocSint)), 9)
	cUJ += STRZERO(INT(ONJD0912VDA(cFilAtu, cCodCri, cLocSint) - JD09DEVL12(cFilAtu, cCodCri, cTipo)), 9)
	cUJ += STRZERO(INT(ONJD0924VDA(cFilAtu, cCodCri, cLocSint) - JD09DEVP12(cFilAtu, cCodCri, cTipo)), 9)
	cUJ += STRZERO(INT((nVenBal + nVenOfi + nVenInt) - nDevBal - nDevOfi - nDevInt),9)
	cUJ += SPACE(6)
	cUJ += cLocSint
	cUJ += IIF(cLocSint=="D1","M","N")
	
	cUK := "U"
	cUK += cM12
	cUK += cS12
	cUK += cM36
	cUK += "K"
	cUK += "  "
	cUK += space(1)
	cUK += Space(8)
	cUK += "P"
	cUK += cS36
	cUK += STRZERO(INT(ONJD09L12Cos(cFilAtu, cCodCri, cLocSint) - JD09DECL12(cFilAtu, cCodCri, cTipo)), 9)
	cUK += STRZERO(INT(ONJD09P12Ct(cFilAtu, cCodCri, cLocSint) - JD09DECP12(cFilAtu, cCodCri, cTipo)), 9)
	cUK += STRZERO(INT(ONJD09Cust(cFilAtu, cCodCri, cLocSint)   - JD09CDEV(cFilAtu, cCodCri, cTipo)), 9)
	cUK += STRZERO(INT(ONJD09TotInv(cFilAtu, cCodCri, cLocSint)), 9)
	cUK += STRZERO(INT(ONJD09ZeroV(cFilAtu, cCodCri, cLocSint)), 9)
	cUK += SPACE(6)
	cUK += cLocSint
	cUK += IIF(cLocSint=="D1","M","N")
	
	cUL := "U"
	cUL += cM12
	cUL += cS12
	cUL += cM36
	cUL += "L"
	cUL += "  "
	cUL += space(1)
	cUL += Space(8)
	cUL += "P"
	cUL += cS36
	cUL += STRZERO(INT(nCSTH),5)
	cUL += STRZERO(INT(nCS1PF),5)
	cUL += STRZERO(INT(nCSI24F),5)
	cUL += STRZERO(INT(nCSLS),5)
	cUL += "00000"
	cUL += "00000"
	cUL += "00000"
	cUL += "00000"
	cUL += "00000"
	cUL += "00000"
	cUL += SPACE(1)
	cUL += cLocSint
	cUL += IIF(cLocSint=="D1","M","N")
	
	cUM := "U"
	cUM += cM12
	cUM += cS12
	cUM += cM36
	cUM += "M"
	cUM += "  "
	cUM += space(1)
	cUM += Space(8)
	cUM += "P"
	cUM += cS36
	cUM += "00000"
	cUM += "00000"
	cUM += STRZERO(INT(nCNSTH),5)    // 37-41 <== balcao...sem estoque...venda perdida mes
	cUM += STRZERO(INT(nCNS1PF),5)   // 42-46 <== total hits atendido 100%
	cUM += STRZERO(INT(nCNSI24F),5)  // 47-51 <== balcao …sem estoque … Qtd de hits, excluindo os atendimentos imediato, foram atendidos em 24horas no mes?
	cUM += STRZERO(INT(nCNSLS),5)    // 52-56 <== balcao …sem estoque … Qtd de hits não foram atendidas por venda perdida no mes?
	cUM += "00000"
	cUM += "00000"
	cUM += "00000"
	cUM += "00000"
	cUM += SPACE(1)
	cUM += cLocSint
	cUM += IIF(cLocSint=="D1","M","N")
	
	cUN := "U"
	cUN += cM12
	cUN += cS12
	cUN += cM36
	cUN += "N"
	cUN += "  "
	cUN += space(1)
	cUN += Space(8)
	cUN += "P"
	cUN += cS36
	cUN += "00000"
	cUN += "00000"
	cUN += "00000"
	cUN += "00000"
	cUN += STRZERO(INT(nSSTH),5)
	cUN += STRZERO(INT(nSS1PF),5)
	cUN += STRZERO(INT(nSSI24F),5)
	cUN += STRZERO(INT(nSSLS),5)
	cUN += "00000"
	cUN += "00000"
	cUN += SPACE(1)
	cUN += cLocSint
	cUN += IIF(cLocSint=="D1","M","N")
	
	cUO := "U"
	cUO += cM12
	cUO += cS12
	cUO += cM36
	cUO += "O"
	cUO += "  "
	cUO += space(1)
	cUO += Space(8)
	cUO += "P"
	cUO += cS36
	cUO += "00000"
	cUO += "00000"
	cUO += "00000"
	cUO += "00000"
	cUO += "00000"
	cUO += "00000"
	cUO += STRZERO(INT(nSNSTH),5)
	cUO += STRZERO(INT(nSNS1PF),5)
	cUO += STRZERO(INT(nSNSI24F),5)
	cUO += STRZERO(INT(nSNSLS),5)
	cUO += SPACE(1)
	cUO += cLocSint
	cUO += IIF(cLocSint=="D1","M","N")
	
	cUP := "U"
	cUP += cM12
	cUP += cS12
	cUP += cM36
	cUP += "P"
	cUP += "  "
	cUP += space(1)
	cUP += Space(8)
	cUP += "P"
	cUP += cS36
	cUP += "00000"
	cUP += "00000"
	cUP += "00000"
	cUP += "00000"
	cUP += "00000"
	cUP += "00000"
	cUP += "00000"
	cUP += "00000"
	cUP += STRZERO(INT(nISTH),5)
	cUP += STRZERO(INT(nIS1PF),5)
	cUP += SPACE(1)
	cUP += cLocSint
	cUP += IIF(cLocSint=="D1","M","N")
	
	cUQ := "U"
	cUQ += cM12
	cUQ += cS12
	cUQ += cM36
	cUQ += "Q"
	cUQ += "  "
	cUQ += space(1)
	cUQ += Space(8)
	cUQ += "P"
	cUQ += cS36
	cUQ += STRZERO(INT(nISI24F),5)
	cUQ += STRZERO(INT(nISLS),5)
	cUQ += "00000"
	cUQ += "00000"
	cUQ += "00000"
	cUQ += "00000"
	cUQ += "00000"
	cUQ += "00000"
	cUQ += "00000"
	cUQ += "00000"
	cUQ += SPACE(1)
	cUQ += cLocSint
	cUQ += IIF(cLocSint=="D1","M","N")
	
	cUR := "U"
	cUR += cM12
	cUR += cS12
	cUR += cM36
	cUR += "R"
	cUR += "  "
	cUR += space(1)
	cUR += Space(8)
	cUR += "P"
	cUR += cS36
	cUR += STRZERO(INT(nINSTH),5)
	cUR += STRZERO(INT(nINS1PF),5)
	cUR += STRZERO(INT(nINSI24F),5)
	cUR += STRZERO(INT(nINSLS),5)
	cUR += "00000"
	cUR += "00000"
	cUR += "00000"
	cUR += "00000"
	cUR += "00000"
	cUR += "00000"
	cUR += SPACE(1)
	cUR += cLocSint
	cUR += IIF(cLocSint=="D1","M","N")
	
	cUS := "U"
	cUS += cM12
	cUS += cS12
	cUS += cM36
	cUS += "S"
	cUS += "  "
	cUS += space(1)
	cUS += Space(8)
	cUS += "P"
	cUS += cS36
	cUS += "00000"
	cUS += "00000"
	cUS += Space(10)
	cUS += STRZERO(  INT( nDevBal +nDevOfi + nDevInt ),8 )+"-"
	cUS += Space(22)
	cUS += cLocSint
	cUS += IIF(cLocSint=="D1","M","N")
	
	cUT := "U"
	cUT += cM12
	cUT += cS12
	cUT += cM36
	cUT += "T"
	cUT += "  "
	cUT += space(1)
	cUT += Space(8)
	cUT += "P"
	cUT += cS36
	cUT += STRZERO(INT(nCSID8),5)
	cUT += STRZERO(INT(nCSIO8),5)
	cUT += STRZERO(INT(nCNSID8),5)
	cUT += STRZERO(INT(nCNSIO8),5)
	cUT += STRZERO(INT(nSSID8),5)
	cUT += STRZERO(INT(nSSIO8),5)
	cUT += STRZERO(INT(nSNSID8),5)
	cUT += STRZERO(INT(nSNSIO8),5)
	cUT += STRZERO(INT(nISID8),5)
	cUT += STRZERO(INT(nISIO8),5)
	cUT += SPACE(1)
	cUT += cLocSint
	cUT += IIF(cLocSint=="D1","M","N")
	
	cUU := "U"
	cUU += cM12
	cUU += cS12
	cUU += cM36
	cUU += "U"
	cUU += "  "
	cUU += space(1)
	cUU += Space(8)
	cUU += "P"
	cUU += cS36
	cUU += STRZERO(INT(nINSID8),5)
	cUU += STRZERO(INT(nINSIO8),5)
	cUU += SPACE(40)
	cUU += SPACE(1)
	cUU += cLocSint
	cUU += IIF(cLocSint=="D1","M","N")
	
	aAdd(aArquivo,{"U0", cSourAcc, cU0, "A", " ", aSint[nCntFor,53], "00"})
	aAdd(aArquivo,{"UI", cSourAcc, cUI, "A", " ", aSint[nCntFor,53], "01"})
	aAdd(aArquivo,{"UJ", cSourAcc, cUJ, "A", " ", aSint[nCntFor,53], "02"})  // loc / tip / cricod / filial
	aAdd(aArquivo,{"UK", cSourAcc, cUK, "A", " ", aSint[nCntFor,53], "03"})
	aAdd(aArquivo,{"UL", cSourAcc, cUL, "A", " ", aSint[nCntFor,53], "04"})
	aAdd(aArquivo,{"UM", cSourAcc, cUM, "A", " ", aSint[nCntFor,53], "05"})
	aAdd(aArquivo,{"UN", cSourAcc, cUN, "A", " ", aSint[nCntFor,53], "06"})
	aAdd(aArquivo,{"UO", cSourAcc, cUO, "A", " ", aSint[nCntFor,53], "07"})
	aAdd(aArquivo,{"UP", cSourAcc, cUP, "A", " ", aSint[nCntFor,53], "08"})
	aAdd(aArquivo,{"UQ", cSourAcc, cUQ, "A", " ", aSint[nCntFor,53], "09"})
	aAdd(aArquivo,{"UR", cSourAcc, cUR, "A", " ", aSint[nCntFor,53], "10"})
	aAdd(aArquivo,{"US", cSourAcc, cUS, "A", " ", aSint[nCntFor,53], "11"})
	aAdd(aArquivo,{"UT", cSourAcc, cUT, "A", " ", aSint[nCntFor,53], "12"})
	aAdd(aArquivo,{"UU", cSourAcc, cUU, "A", " ", aSint[nCntFor,53], "13"})
next
//
aSort(aArquivo,,,{|x,y| x[2] + x[6] + x[4] + x[5] + x[7] < y[2] + y[6] + y[4] + y[5] + y[7] } )
//
for nCntFor := 1 to Len(aArquivo)
	fwrite(nHnd, aArquivo[nCntFor,3] + CRLF)
next
//
cNomeAtualizado :=;
	"DLR2JD_" +;
	strzero(DAY(ddatabase),2) +;
	cMes +;
	STR(Year(ddatabase),4) + "_" +;
	SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".DAT"

FClose(nHnd)

Copy File &(cFileTemp) to &(cFileDest)
iif (IsSrvUnix(),CHMOD( cFileDest , 666,,.f. ),CHMOD( cFileDest , 2,,.f. ))
iif (IsSrvUnix(),CHMOD( cFileTemp , 666,,.f. ),CHMOD( cFileTemp , 2,,.f. ))
FRenameEx(cFileDest , lower(cSavePath)+UPPER(cNomeAtualizado))
Dele File &(cFileTemp)
conout("OFINJD09 TESTE DE GERAÇÃO")
conout("Arquivo gerado em: " + cFileDest)
conout("Arquivo renomeado em: " + UPPER(cSavePath+cNomeAtualizado))

OJD19LOG("PARTSDATA", STR0009)
//
DBSelectArea("SB1")
DBSetOrder(1)
//

UnLockByName("OFINJD09", .T. , .T. , .T. )
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ONJD09TotInv    | Autor |  Vinicius Gati   | Data | 03/08/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
## Pega total de inventario de determinado codigo critico                    ##
###############################################################################
===============================================================================
*/
Static Function ONJD09TotInv(cFil, cCC, cTipo)
Return oCacheInv:GetTotInv({;
	{'filial'        , cFil                       },;
	{'data'          , dDatabase                  },;
	{'critical_code' , cCC                        },;
	{'tipo'          , IIF(cTipo=='D1', '1', '0') } ; // BM_PROORI
})

/*
============================================================================
############################################################################
##+-------+------------+-------+-----------------------+------+----------+##
##|Função | JD09MdInv  | Autor |  Vinicius Gati        | Data | 03/08/15 |##
##+-------+------------+-------+-----------------------+------+----------+##
##| Retorna media de inventario para codigo critico dos ultimos 12 meses |##
##+-------+------------+-------+-----------------------+------+----------+##
############################################################################
============================================================================
*/
Static Function JD09MdInv(cFil, cCC, cTipo)
	Local oDpm := DMS_DPM():New()
Return oDpm:GetMedInv(cFil, cCC, dDatabase, IIF(cTipo=='D1', '1', '0'))

/*
============================================================================
############################################################################
##+-------+------------+-------+-----------------------+------+----------+##
##|Função | JD0924MdInv| Autor |  Vinicius Gati        | Data | 03/08/15 |##
##+-------+------------+-------+-----------------------+------+----------+##
##| Retorna media de inventario para codigo critico dos ultimos 12 meses |##
##+-------+------------+-------+-----------------------+------+----------+##
############################################################################
============================================================================
*/
Static Function JD0924MdInv(cFil, cCC, cTipo)
	Local oDpm := DMS_DPM():New()
Return oDpm:Get24MedInv(cFil, cCC, dDatabase, IIF(cTipo=='D1', '1', '0'))

/*
====================================================================================================
####################################################################################################
##+----------+-------------+-------+-------------------------------------------+------+----------+##
##|Função    | ONJD09ZeroV | Autor |  Vinicius Gati                            | Data | 24/08/15 |##
##+----------+-------------+-------+-------------------------------------------+------+----------+##
##| Pega total de inventario  de determinado codigo critico de itens que enquadram em zero vendas|##
##+----------+-------------+-------+-------------------------------------------+------+----------+##
####################################################################################################
====================================================================================================
*/
Function ONJD09ZeroV(cFil, cCC, cTipo)
	Local cQuery    := ""
	Local cBckFil   := cFilAnt
	Local nTot      := 0
	Local cAl       := GetNextAlias()
	Local cPreTbl   := IIf(ALLTRIM(TcGetDb()) <> "ORACLE", " AS ", "")

	cFilAnt    := cFil
	cDadosProd := GetNewPar("MV_MIL0054","SBZ")

	If Empty(cCC)
		cCC := "  "
	EndIf

	cQuery += " SELECT TB4.* FROM ("
	cQuery += " SELECT COALESCE(SUM(TOTAL), 0) TOTAL FROM "
	cQuery += " ( "
	cQuery += " SELECT TB2.*, CM*QUANT AS TOTAL, "
	cQuery += "        CASE WHEN ULTIMA_VENDA_COMPUTADA is null then "
	cQuery += "        ( "
	cQuery += "            SELECT MAX(" + oSqlHlp:Concat({"VB8_ANO","VB8_MES","VB8_DIA"}) + ") "
	cQuery += "              FROM "+oSqlHlp:NoLock('VB8')
	cQuery += "             WHERE VB8_ANO + VB8_MES + VB8_DIA < '"+dtos(ddatabase)+"' "
	cQuery += "               AND ( VB8_VDAB > 0 OR VB8_VDAO > 0 OR VB8_VDAI > 0 ) "
	cQuery += "               AND VB8_PRODUT = PRODUT "
	cQuery += "               AND VB8.D_E_L_E_T_ = ' ' "
	cQuery += "        ) "
	cQuery += "        ELSE ULTIMA_VENDA_COMPUTADA end as ULTIMA_VENDA_FINAL "
	cQuery += " FROM  "
	cQuery += " ( "
	cQuery += "     SELECT TB1.*, "
	cQuery += "            CASE WHEN TB1.DTADDED is null OR PE_CALC < TB1.DTADDED THEN PE_CALC "
	cQuery += "              ELSE TB1.DTADDED  "
	cQuery += "            END AS PE, "
	cQuery += "            CASE WHEN TB1.UVDA is null OR TB1.UVDA = '' THEN TB1.ULTVDA ELSE TB1.UVDA END ULTIMA_VENDA_COMPUTADA"
	cQuery += "     FROM  "
	cQuery += "     ( "
	cQuery += "       SELECT inv.PRODUT, inv.FILIAL, inv.CM, inv.QUANT, inv.DATAEX, ENT.DT_D1, FECH.DT_B9, "
	cQuery += "              CASE WHEN SBMINMAX.ULTVDA <= '"+dtos(ddatabase)+"' then SBMINMAX.ULTVDA else null end as ULTVDA, "
	cQuery += "              CASE WHEN SBMINMAX.DTADDED = ' ' then null else  SBMINMAX.DTADDED end as DTADDED, "
	cQuery += "              CASE WHEN FECH.DT_B9 IS NOT NULL AND FECH.DT_B9 < ENT.DT_D1 THEN FECH.DT_B9 "
	cQuery += "                 ELSE ENT.DT_D1 "
	cQuery += "              END AS PE_CALC, "
	cQuery += "              SAI.ULTVDA AS UVDA "
	cQuery += "         FROM MIL_DPM_CACHE_INVENTARIO inv "
	cQuery += "         JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND SB1.B1_COD   = inv.PRODUT     AND SB1.B1_CRICOD like '"+cCC+"' AND SB1.D_E_L_E_T_ = ' ' "
	if SBM->(FieldPos('BM_VAIDPM')) > 0
		cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND SBM.BM_VAIDPM    = '1'       AND SBM.D_E_L_E_T_ = ' ' "
	else
		cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND BM_GRUPO IN "+oDpm:GetInGroups()+"   AND SBM.D_E_L_E_T_ = ' ' "
	endif
	if NNR->(FieldPos('NNR_VDADMS')) > 0 .and. lSoArmVenda /* somente armazens de venda é padrao, isso foi feito pra maqnelson */
		cQuery += "       JOIN "+oSqlHlp:NoLock('NNR')+" ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR_CODIGO   = inv.ALMOXE     AND NNR_VDADMS       = '1'       AND NNR.D_E_L_E_T_ = ' ' "
	endif
	If cDadosProd == "SBZ"
		cQuery += " JOIN ( "
		cQuery += "   SELECT BZ_FILIAL, BZ_COD, MIN(BZ_PRIENT) DTADDED, MAX(BZ_ULTVDA) ULTVDA "
		cQuery += "     FROM "+oSqlHlp:NoLock('SBZ')+" "
		cQuery += "    WHERE SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY BZ_FILIAL, BZ_COD "
		cQuery += " ) SBMINMAX ON SBMINMAX.BZ_COD = B1_COD "
	Else
		cQuery += " LEFT JOIN ( "
		cQuery += "   SELECT B5_FILIAL, B5_COD, MIN(B5_DTADDED) DTADDED, MAX(B5_ULTVDA) ULTVDA "
		cQuery += "     FROM "+oSqlHlp:NoLock('SB5')+" "
		cQuery += "    WHERE SB5.B5_FILIAL = '"+xFilial('SB5')+"' AND SB5.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY B5_FILIAL, B5_COD "
		cQuery += " ) SBMINMAX ON SBMINMAX.B5_COD = B1_COD "
	Endif
	cQuery += " LEFT JOIN ( "
	cQuery += "   SELECT B9_FILIAL, B9_COD, MIN(B9_DATA) DT_B9 "
	cQuery += "     FROM "+oSqlHlp:NoLock('SB9')+" "
	cQuery += "    WHERE SB9.B9_FILIAL = '"+xFilial('SB9')+"' AND SB9.B9_DATA <> ' ' AND B9_QINI > 0 AND SB9.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY B9_FILIAL, B9_COD "
	cQuery += " ) FECH ON FECH.B9_COD = B1_COD "

	cQuery += " LEFT JOIN ( "
	cQuery += "   SELECT D1_FILIAL, D1_COD, MIN(SD1.D1_DTDIGIT) AS DT_D1 "
	cQuery += "    FROM "+oSqlHlp:NoLock('SD1')+" "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '"+xFilial('SF4')+"' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV IN ('01', '03') AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "    WHERE SD1.D1_FILIAL  = '"+xFilial('SD1')+"' "
	cQuery += "      AND D1_DTDIGIT <= '"+dtos(ddatabase)+"' "
	cQuery += "      AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY D1_FILIAL, D1_COD "
	cQuery += " ) ENT ON ENT.D1_FILIAL = '"+xFilial('SD1')+"' AND D1_COD = B1_COD  "

	cQuery += " LEFT JOIN ( "
	cQuery += "     SELECT D2_FILIAL, D2_COD, MAX(SD2.D2_EMISSAO) AS ULTVDA "
	cQuery += "       FROM "+oSqlHlp:NoLock('SD2')+" "
	cQuery += "       JOIN "+oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '"+xFilial('SF4')+"'  AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV IN ('05') AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "      WHERE D2_FILIAL = '"+xFilial('SD2')+"' "
	cQuery += "        AND D2_EMISSAO <= '"+dtos(ddatabase)+"' "
	cQuery += "        AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "   GROUP BY D2_FILIAL, D2_COD "
	cQuery += " ) SAI ON SAI.D2_FILIAL = '"+xFilial('SD2')+"' AND D2_COD = B1_COD "

	cQuery += " WHERE inv.FILIAL = '"+xFilial('SD2')+"' "
	cQuery += "   AND DATAEX = '"+dtos(ddatabase)+"' "
	cQuery += "   AND QUANT  > 0 "
	cQuery += "   AND CM     > 0 "
	if cTipo == "D1" .or. cTipo == "D1M"
		cQuery += "   AND SBM.BM_PROORI = '1' "
	else
		cQuery += "   AND SBM.BM_PROORI = '0' "
	endif
	if ! NNR->(FieldPos('NNR_VDADMS')) > 0
		cQuery += " AND inv.ALMOXE = SB1.B1_LOCPAD "
	EndIf
	cQuery += "   ) "+cPreTbl+" TB1 "
	cQuery += "  ) "+cPreTbl+" TB2 "
	cQuery += " ) "+cPreTbl+" TB3 "
	cQuery += " WHERE "
	cQuery += " (ULTIMA_VENDA_FINAL < '"+dtos(d1AnoAtras)+"' OR ULTIMA_VENDA_FINAL is null OR ULTIMA_VENDA_FINAL = ' ') "
	cQuery += " AND  "
	cQuery += " (PE < '"+dtos(d1AnoAtras)+"' OR PE is null OR PE = ' ') "

	cQuery += ") "+cPreTbl+" TB4"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )

	if ! (cAl)->(EOF())
		nTot := (cAl)->(TOTAL)
	endif
	(cAl)->(dbCloseArea())

	cFilAnt := cBckFil
Return nTot

/*
===================================================================================================
###################################################################################################
##+----------+------------+-------+-------------------------------------------+------+----------+##
##|Função    | ONJD09Cust | Autor |  Vinicius Gati                            | Data | 17/09/15 |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
##| Custo no VB8 está errado, foi necessario pegar direto do D2                                 |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function ONJD09Cust(cFil, cCC, cTipo)
	Local cIndex := "ONJD09Cust_" + cFil + cCC + cTipo
	
	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	dData1 := STOD( ALLTRIM(STR(YEAR(dDatabase))) + ALLTRIM(STRZERO(MONTH(dDatabase),2)) + '01' )
	oDados := JD09QueryVendas(cFil, cCC, cTipo, , dData1, dDataBase)

	oCacheVendas[cIndex] := oDados:GetValue("CUSTO")

Return oDados:GetValue("CUSTO")

/*
===================================================================================================

###################################################################################################
##+----------+------------+-------+-------------------------------------------+------+----------+##
##|Função    | ONJD09P12Ct| Autor |  Vinicius Gati                            | Data | 17/09/15 |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
##| Total dos ultimos 12 meses antes dos 12 ja anteriores                                       |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function ONJD09P12Ct(cFil, cCC, cTipo)
	Local cIndex := "ONJD09P12Ct_" + cFil + cCC + cTipo

	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	oDados := JD09QueryVendas(cFil, cCC, cTipo, , d2AnosAtras, d1AnoAtras)

	oCacheVendas[cIndex] := oDados:GetValue("CUSTO")

Return oDados:GetValue("CUSTO")

/*
===================================================================================================
###################################################################################################
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##|Função    | ONJD09L12Cos | Autor |  Vinicius Gati                          | Data | 17/09/15 |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##| Custo dos ultimos 12 meses                                                                  |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function ONJD09L12Cos(cFil, cCC, cTipo)
	Local cIndex := "ONJD09L12Cos_" + cFil + cCC + cTipo

	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	oDados := JD09QueryVendas(cFil, cCC, cTipo, , d1AnoAtras, dDataBase)

	oCacheVendas[cIndex] := oDados:GetValue("CUSTO")

Return oDados:GetValue("CUSTO")

/*
===================================================================================================
###################################################################################################
##+----------+------------+-------+-------------------------------------------+------+----------+##
##|Função    | ONJD09VVDA | Autor |  Vinicius Gati                            | Data | 17/09/15 |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
##| Valor de vendas mês balcao ou oficina segundo parametro F2_PREFORI                          |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function ONJD09VVDA(cFil, cCC, cTipo, cOri)
	Local cIndex := "ONJD09VVDA_" + cFil + cCC + cTipo + iif(ValType(cOri) == "U", "-", cOri)

	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	dData1 := STOD( ALLTRIM(STR(YEAR(dDatabase))) + ALLTRIM(STRZERO(MONTH(dDatabase),2)) + '01' )
	oDados := JD09QueryVendas(cFil, cCC, cTipo, cOri, dData1, dDataBase)

	oCacheVendas[cIndex] := oDados:GetValue("TOTAL")

Return oDados:GetValue("TOTAL")

/*
===================================================================================================
###################################################################################################
##+----------+------------+-------+-------------------------------------------+------+----------+##
##|Função    | ONJD09VDEV | Autor |  Vinicius Gati                            | Data | 23/11/18 |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
##| Valor de vendas mês balcao ou oficina segundo parametro F2_PREFORI                          |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function ONJD09VDEV(cFil, cCC, cTipo, cOri)
	Local cIndex := "ONJD09VDEV_" + cFil + cCC + cTipo + iif(ValType(cOri) == "U", "-", cOri)

	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	dData1 := STOD( ALLTRIM(STR(YEAR(dDatabase))) + ALLTRIM(STRZERO(MONTH(dDatabase),2)) + '01' )
	oDados := JD09DevVendas(cFil, cCC, cTipo, cOri, dData1, dDataBase)

	oCacheVendas[cIndex] := oDados:GetValue("TOTAL")

Return oDados:GetValue("TOTAL")


/*
===================================================================================================
###################################################################################################
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##|Função    | JD09DEVL12   | Autor |  Vinicius Gati                          | Data | 17/09/15 |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##| devolução dos ultimos 12 meses                                                              |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function JD09DEVL12(cFil, cCC, cTipo, cOri)
	Local cIndex := "JD09DEVL12_" + cFil + cCC + cTipo + iif(ValType(cOri) == "U", "-", cOri)

	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	oDados := JD09DevVendas(cFil, cCC, cTipo, cOri, d1AnoAtras, dDataBase)

	oCacheVendas[cIndex] := oDados:GetValue("TOTAL")

Return oDados:GetValue("TOTAL")

/*
===================================================================================================
###################################################################################################
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##|Função    | JD09DEVP12 | Autor |  Vinicius Gati                            | Data | 17/09/15 |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##| devolução dos 12 meses anteriores aos 12                                                    |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function JD09DEVP12(cFil, cCC, cTipo, cOri)
	Local cIndex := "JD09DEVP12_" + cFil + cCC + cTipo + iif(ValType(cOri) == "U", "-", cOri)

	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	oDados := JD09DevVendas(cFil, cCC, cTipo, cOri, d2AnosAtras, d1AnoAtras)

	oCacheVendas[cIndex] := oDados:GetValue("TOTAL")
	
Return oDados:GetValue("TOTAL")

/*
===================================================================================================
###################################################################################################
##+----------+------------+-------+-------------------------------------------+------+----------+##
##|Função    | ONJD09VDEV | Autor |  Vinicius Gati                            | Data | 23/11/18 |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
##| custo das devolucoes do mes                                                                 |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function JD09CDEV(cFil, cCC, cTipo, cOri)
	Local cIndex := "JD09CDEV_" + cFil + cCC + cTipo + iif(ValType(cOri) == "U", "-", cOri)

	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End	

	dData1 := STOD( ALLTRIM(STR(YEAR(dDatabase))) + ALLTRIM(STRZERO(MONTH(dDatabase),2)) + '01' )
	oDados := JD09DevVendas(cFil, cCC, cTipo, cOri, dData1, dDataBase)

	oCacheVendas[cIndex] := oDados:GetValue("CUSTO")

Return oDados:GetValue("CUSTO")

/*
===================================================================================================
###################################################################################################
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##|Função    | JD09DEVL12   | Autor |  Vinicius Gati                          | Data | 17/09/15 |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##| custo devolução dos ultimos 12 meses                                                        |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function JD09DECL12(cFil, cCC, cTipo, cOri)
	Local cIndex := "JD09DECL12_" + cFil + cCC + cTipo + iif(ValType(cOri) == "U", "-", cOri)

	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	oDados := JD09DevVendas(cFil, cCC, cTipo, cOri, d1AnoAtras, dDataBase)

	oCacheVendas[cIndex] := oDados:GetValue("CUSTO")

Return oDados:GetValue("CUSTO")

/*
===================================================================================================
###################################################################################################
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##|Função    | JD09DEVP12 | Autor |  Vinicius Gati                            | Data | 17/09/15 |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##| custo devolução dos 12 meses anteriores aos 12                                              |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function JD09DECP12(cFil, cCC, cTipo, cOri)
	Local cIndex := "JD09DECP12_" + cFil + cCC + cTipo + iif(ValType(cOri) == "U", "-", cOri)

	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	oDados := JD09DevVendas(cFil, cCC, cTipo, cOri, d2AnosAtras, d1AnoAtras)

	oCacheVendas[cIndex] := oDados:GetValue("CUSTO")

Return oDados:GetValue("CUSTO")

/*
===================================================================================================
###################################################################################################
##+----------+------------+-------+-------------------------------------------+------+----------+##
##|Função    | ONJD0924VDA| Autor |  Vinicius Gati                            | Data | 17/09/15 |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
##| Total dos ultimos 12 meses antes dos 12 ja anteriores                                       |##
##+----------+------------+-------+-------------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function ONJD0924VDA(cFil, cCC, cTipo, cOri)
	Local cIndex := "ONJD0924VDA_" + cFil + cCC + cTipo + iif(ValType(cOri) == "U", "-", cOri)
	
	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	oDados := JD09QueryVendas(cFil, cCC, cTipo, cOri, d2AnosAtras, d1AnoAtras)

	oCacheVendas[cIndex] := oDados:GetValue("TOTAL")

Return oDados:GetValue("TOTAL")

/*
===================================================================================================
###################################################################################################
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##|Função    | ONJD0912VDA | Autor |  Vinicius Gati                          | Data | 17/09/15 |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
##| Valor Venda utimos 12 meses                                                                 |##
##+----------+--------------+-------+-----------------------------------------+------+----------+##
###################################################################################################
===================================================================================================
*/
Static Function ONJD0912VDA(cFil, cCC, cTipo, cOri)
	Local cIndex := "ONJD0912VDA_" + cFil + cCC + cTipo + iif(ValType(cOri) == "U", "-", cOri)
	
	If ValType(oCacheVendas[cIndex]) != "U"
		Return oCacheVendas[cIndex]
	End

	oDados := JD09QueryVendas(cFil, cCC, cTipo, cOri, d1AnoAtras, dDataBase)

	oCacheVendas[cIndex] := oDados:GetValue("TOTAL")

Return oDados:GetValue("TOTAL")

/*
============================================================================
############################################################################
##+-------+------------+-------+-----------------------+------+----------+##
##|Função | JD09GtFil  | Autor |  Vinicius Gati        | Data | 03/08/15 |##
##+-------+------------+-------+-----------------------+------+----------+##
##|Converte JDcode para filial do protheus                               |##
##+-------+------------+-------+-----------------------+------+----------+##
############################################################################
============================================================================
*/
Static Function JD09GtFil(cJdCode)
	Local nIdx := aScan( oDpm:GetFiliais(), {|aEl| ALLTRIM(aEl[2]) == ALLTRIM(cJdCode) } )
Return oDpm:GetFiliais()[nIdx][1]

/*/{Protheus.doc} JD09QueryVendas
	Query de valor das vendas com codsit
	@type function
	@author Vinicius Gati
	@since 21/08/2017
/*/
Static Function JD09QueryVendas(cFil, cCC, cTipo, cOri, dData1, dData2)
	local cQuery    := ""
	Local cBckFil   := cFilAnt
	Local cAl       := GetNextAlias()
	Local nTot      := 0
	Local nTotCus   := 0
	Local cTopQry   := ""
	local cInRecom  := ""
	Default cOri    := cPrefOFI + "','" + cPrefBAL
	cFilAnt         := cFil

	If Empty(cCC)
		cCC := "  "
	EndIf

	cInRecom := "'" + oArHlp:Join(oDemDpm:aSitRec, "','") + "'"

	cQuery += " SELECT COALESCE(SUM(D2_CUSTO1), 0) SOMA_CUSTO, COALESCE(SUM(D2_TOTAL), 0) SOMA_TOTAL "
	cQuery += " FROM ( "
	cQuery += "  SELECT cast(D2_CUSTO1 as int) D2_CUSTO1, cast(D2_TOTAL as int) D2_TOTAL, SITUACAO.VS3_CODSIT "
	cQuery += "    FROM "+oSqlHlp:NoLock('SD2')+" "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF2')+" ON SF2.F2_FILIAL = SD2.D2_FILIAL              AND SF2.F2_DOC    = SD2.D2_DOC   AND SF2.F2_SERIE   = SD2.D2_SERIE  AND SF2.F2_PREFORI IN ('"+cOri+"') AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '" + xFilial('SF4') + "'   AND SF4.F4_CODIGO = SD2.D2_TES   AND SF4.F4_OPEMOV  = '05'          AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '" + xFilial('SB1') + "'   AND SD2.D2_COD    = SB1.B1_COD   AND SB1.D_E_L_E_T_ = ' ' "
	if SBM->(FieldPos('BM_VAIDPM')) > 0
		cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND SBM.BM_VAIDPM    = '1'       AND SBM.D_E_L_E_T_ = ' ' "
	else
		cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND BM_GRUPO IN "+oDpm:GetInGroups()+"   AND SBM.D_E_L_E_T_ = ' ' "
	endif
	cQuery += "    LEFT JOIN ( "
	cQuery += "         SELECT VS1_FILIAL, VS3_CODITE, VS3_GRUITE, VS3_CODSIT, VS1_NUMNFI, VS1_SERNFI "
	cQuery += "           FROM "+oSqlHlp:NoLock('VS1')+" "
	cQuery += "           JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3.VS3_FILIAL = VS1_FILIAL AND VS3_NUMORC    = VS1_NUMORC AND VS3.D_E_L_E_T_ = ' '  "
	cQuery += "          WHERE VS1_FILIAL = '" + xFilial('VS1') + "' "
	cQuery += "            AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "    ) SITUACAO ON VS1_FILIAL = '" + xFilial('VS1') + "' AND VS3_CODITE = B1_CODITE AND VS3_GRUITE = B1_GRUPO AND VS1_NUMNFI = D2_DOC AND VS1_SERNFI = D2_SERIE "
	cQuery += "    WHERE SD2.D2_FILIAL  = '" + xFilial('SD2') + "' "
	cQuery += "      AND SD2.D2_EMISSAO >= '" + dtos(dData1) + "' AND SD2.D2_EMISSAO <= '" + dtos(dData2) + "'
	cQuery += "      AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "      AND SB1.B1_CRICOD LIKE '" +cCC+ "' "
	cQuery += "      AND SBM.BM_PROORI  = '"+ IIF(cTipo=='D1', '1', '0') +"' " // original/nao original
	cQuery += " ) TEMP_TBL "
	cQuery += " WHERE (VS3_CODSIT IS NULL OR VS3_CODSIT = ' ' OR VS3_CODSIT NOT IN (" + cInRecom + ") ) "
	oLogger:Log({"TIMESTAMP", "### query:" + cQuery})
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )

	do while ! (cAl)->(EOF())
		nTot    += (cAl)->(SOMA_TOTAL)
		nTotCus += (cAl)->(SOMA_CUSTO)
		(cAl)->(dbSkip())
	end do

	(cAl)->(dbCloseArea())

	cFilAnt := cBckFil
Return DMS_DataContainer():New({;
	{'CUSTO', nTotCus},;
	{'TOTAL', nTot   } ;
})

/*/{Protheus.doc} JD09DevVendas
	Query de valor das vendas com codsit
	@type function
	@author Vinicius Gati
	@since 21/08/2017
/*/
Static Function JD09DevVendas(cFil, cCC, cTipo, cOri, dData1, dData2)
	local cQuery    := ""
	Local cBckFil   := cFilAnt
	Local cAl       := GetNextAlias()
	Local nTot      := 0
	Local nTotCus   := 0
	Local cTopQry   := ""
	local cInRecom  := ""
	Default cOri    := cPrefOFI + "','" + cPrefBAL
	cFilAnt         := cFil

	If Empty(cCC)
		cCC := "  "
	EndIf

	cInRecom := "'" + oArHlp:Join(oDemDpm:aSitRec, "','") + "'"

	cQuery += " SELECT COALESCE(SUM(D1_CUSTO), 0) SOMA_CUSTO, COALESCE(SUM(D1_TOTAL), 0) SOMA_TOTAL "
	cQuery += " FROM ( "
	cQuery += "  SELECT cast(D1_CUSTO as int) D1_CUSTO, cast(D1_TOTAL as int) D1_TOTAL, SITUACAO.VS3_CODSIT "
	cQuery += "    FROM "+oSqlHlp:NoLock('SD2')
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF2')+" ON SF2.F2_FILIAL = SD2.D2_FILIAL              AND SF2.F2_DOC    = SD2.D2_DOC   AND SF2.F2_SERIE   = SD2.D2_SERIE  AND SF2.F2_PREFORI IN ('"+cOri+"') AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock("SD1")+" ON SD1.D1_FILIAL = '" + xFilial("SD1") + "'   AND SD1.D1_NFORI  = SD2.D2_DOC   AND SD1.D1_SERIORI = SD2.D2_SERIE  AND SD1.D1_COD     = SD2.D2_COD  AND SD1.D1_ITEMORI = SD2.D2_ITEM  AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '" + xFilial('SF4') + "'   AND SF4.F4_CODIGO = SD2.D2_TES   AND SF4.F4_OPEMOV  = '05'          AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '" + xFilial('SB1') + "'   AND SD2.D2_COD    = SB1.B1_COD   AND SB1.D_E_L_E_T_ = ' ' "
	if SBM->(FieldPos('BM_VAIDPM')) > 0
		cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND SBM.BM_VAIDPM    = '1'       AND SBM.D_E_L_E_T_ = ' ' "
	else
		cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND BM_GRUPO IN "+oDpm:GetInGroups()+"   AND SBM.D_E_L_E_T_ = ' ' "
	endif
	cQuery += "    LEFT JOIN ( "
	cQuery += "         SELECT VS1_FILIAL, VS3_CODITE, VS3_GRUITE, VS3_CODSIT, VS1_NUMNFI, VS1_SERNFI "
	cQuery += "           FROM "+oSqlHlp:NoLock('VS1')+" "
	cQuery += "           JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3.VS3_FILIAL = VS1_FILIAL AND VS3_NUMORC    = VS1_NUMORC AND VS3.D_E_L_E_T_ = ' '  "
	cQuery += "          WHERE VS1_FILIAL = '" + xFilial('VS1') + "' "
	cQuery += "            AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "    ) SITUACAO ON VS1_FILIAL = '" + xFilial('VS1') + "' AND VS3_CODITE = B1_CODITE AND VS3_GRUITE = B1_GRUPO AND VS1_NUMNFI = D2_DOC AND VS1_SERNFI = D2_SERIE "
	cQuery += "    WHERE SD2.D2_FILIAL  = '" + xFilial('SD2') + "' "
	cQuery += "      AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "      AND D1_DTDIGIT >= '" + dtos(dData1) + "' AND D1_DTDIGIT <= '" + dtos(dData2) + "'
	cQuery += "      AND SB1.B1_CRICOD LIKE '"+cCC+"' "
	cQuery += "      AND SBM.BM_PROORI  = '"+ IIF(cTipo=='D1', '1', '0') +"' " // original/nao original
	cQuery += " ) TEMP_TBL "
	cQuery += " WHERE (VS3_CODSIT IS NULL OR VS3_CODSIT = ' ' OR VS3_CODSIT NOT IN (" + cInRecom + ") ) "
	oLogger:Log({"TIMESTAMP", "### query:" + cQuery})
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )

	do while ! (cAl)->(EOF())
		nTot    += (cAl)->(SOMA_TOTAL)
		nTotCus += (cAl)->(SOMA_CUSTO)
		(cAl)->(dbSkip())
	end do

	(cAl)->(dbCloseArea())

	cFilAnt := cBckFil
Return DMS_DataContainer():New({;
	{'CUSTO', nTotCus},;
	{'TOTAL', nTot   } ;
})

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
Local nOpcGetFil := GETF_NETWORKDRIVE + GETF_RETDIRECTORY

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//////////////////////////////////////////////////////////////////
// Pergunte                                                     //
//////////////////////////////////////////////////////////////////

aAdd(aSX1,{cPerg,"01",STR0008,"","","MV_CH1","C",99,0,0,"G","Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+")","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	  ,"S"})
aAdd(aSX1,{cPerg,"02",STR0010,"","","MV_CH2","C", 6,0,0,"G","", "mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"03",STR0011,"","","MV_CH3","C",99,0,0,"G","", "mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"04",STR0012,"","","MV_CH4","C",99,0,0,"G","", "mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"05",STR0011,"","","MV_CH5","C",99,0,0,"G","", "mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"06",STR0011,"","","MV_CH6","C",99,0,0,"G","", "mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"07",STR0011,"","","MV_CH7","C",99,0,0,"G","", "mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"08",STR0011,"","","MV_CH8","C",99,0,0,"G","", "mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"09",STR0011,"","","MV_CH9","C",99,0,0,"G","", "mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})


dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

return
