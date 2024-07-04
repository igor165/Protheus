// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 026    ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#include "protheus.ch"
#include "OFINJD01.CH"
#include 'tbiconn.ch'

#DEFINE IDX_CAMPO    01
#DEFINE IDX_VALOR    02
#DEFINE IDX_SO_NOVO  03
#DEFINE IDX_CHAVE    04

#DEFINE IDX2_FILIAL    01
#DEFINE IDX2_PECA      02
#DEFINE IDX2_DADOS     03
#DEFINE IDX2_DADOS_ADC 04

#DEFINE IDX4_FILIAL 01
#DEFINE IDX4_FESTCO 02
#DEFINE IDX4_CTACTB 03
#DEFINE IDX4_CENCUS 04
#DEFINE IDX4_ALMOXA 05
#DEFINE IDX4_GRUITE 06
#DEFINE IDX4_FORNEC 07
#DEFINE IDX4_LOJFOR 08
#DEFINE IDX4_TESENT 09
#DEFINE IDX4_TESSAI 10
#DEFINE IDX4_FABRIC 11  

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007326_1"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFINJD01   | Autor |  Luis Delorme         | Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|FunÁ„o    | REFACTORED | Autor | Vinicius Gati         | Data | 01/11/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Importacao da arquivo da JD contendo as ultimas atualizacoes |##
##|          | do cadastro e preco de pecas                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Pecas JD                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD01(aParam)
// Variaveis da ParamBox
Local lAntigo := .f.
Local aSay    := {}
Local aButton := {}
Local nOpc    := 0
//
Local cTitulo := ""
Local cDesc1  := ""
Local cDesc2  := ""
//
Private lSchedule := FWGetRunSchedule()
//
Private cPerg           := "OFINJD01"   // Pergunte quando chamado pelo Menu
Private cPerg_S         := "OFINJD01_S" // Pergunte quando chamado pelo Schedule
Private cLog
Private oLogger         := Nil
Private oArHlp          := Nil
Private cTblLogCod
Private oSql            := Nil
Private aQueue          := {}
Private cFilCpl         := {}
Private aFilis          := {}
Private cDadosProd
//
CriaSX1()
AcertaSXD()
//
if lSchedule

	If ( VALTYPE(aParam) <> "U" ) // Chamada antiga ( parametros passados na chamada da funcao no cadastro do schedule )
		//
		MV_PAR01 := aParam[3]
		MV_PAR02 := aParam[4]
		MV_PAR03 := aParam[5]
		MV_PAR04 := aParam[6]
		//
		lAntigo := .t.
		//
		cEmpr    := aParam[1] // OFINJD01('99', '01', '\', 'JD', '')
		cFil     := aParam[2]
		cDiret   := aParam[3]
		cMarca   := aParam[4]
		cImpTes  := aParam[5]
		//
		nModulo := 41
		cModulo := "PEC"
		__cInternet := 'AUTOMATICO'
		If Type("cArqTab")=="U"
			cArqTab:=""
		EndIf
		//
		cFOPENed := ""
		DbCloseAll()
		Prepare Environment Empresa cEmpr Filial cFil Modulo cModulo
		conout("OFINJD01 - Ambiente Preparado - Empresa:"+Alltrim(cEmpr)+ " Filial:"+Alltrim(cFil)+ "   ("+time()+")")
		//
	Else
		//
		conout("OFINJD01 - Iniciando")
		conout("OFINJD01 - Parametros: ")
		conout("OFINJD01 -    "+Alltrim(STR0020)+": "+MV_PAR01)
		conout("OFINJD01 -    "+Alltrim(STR0014)+": "+MV_PAR02)
		conout("OFINJD01 -    "+Alltrim(STR0015)+": "+IIf(MV_PAR03==1,STR0016,STR0017))
		conout("OFINJD01 -    "+Alltrim(STR0021)+": "+IIf(MV_PAR04==1,STR0016,STR0017))
		//
	EndIf

Else

	Pergunte(cPerg,.f.)
	If !Pergunte(cPerg,.t.)
		Return
	EndIf

EndIf

cDadosProd  := GetNewPar("MV_MIL0054","SBZ")
oLogger     := DMS_Logger():New("OFINJD01.LOG")
oSql        := DMS_SqlHelper():New()
oArHlp      := DMS_ArrayHelper():New()
cTitulo     := STR0001
cDesc1      := STR0002
cDesc2      := STR0003
//
if !lSchedule
	//
	//
	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	//
	aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
	aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
	//
	FormBatch( cTitulo, aSay, aButton )
	//
	If nOpc <> 1
		Return
	Endif
	//#############################################################################
	//# Chama a rotina de importacao do cadastro de pecas GM                      #
	//#############################################################################
	RptStatus( {|lEnd| RunProc(@lEnd)}, STR0004,STR0005, .T. )
	//
Else
	RunProc()
Endif

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    | RunProc    | Autor |  Luis Delorme         | Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Importacao da arquivo da JD contendo as ultimas atualizacoes |##
##|          | do cadastro e preco de pecas                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function RunProc(lEnd)
Local cArquivo := ""
Local nIdx     := 1
Local nIdx2    := 1
Local nCntFor
Local aVetNome := {}
Local aVetTam  := {}
Local aVetData := {}
Local aVetHora := {}
Local oDpm     := DMS_DPM():New()
Local cSql     := ""
Local cTesEnt  := ""
Local cTesSai  := ""
Local cGruDes  := ""
Local aDadosMarca := {}
Local lFaz     := .t.
Local lPEOFNJD01 := ExistBlock('OFNJD01')
Local lPEOJD01AGR := ExistBlock('OJD01AGR')
Local lVE5_GDESFB := VE5->(FieldPos("VE5_GDESFB")) <> 0

Local lSB1ExcEmp:= FWModeAccess("SB1",1) == "E" // Exclusiva por empresa
Local lSB1ExcUnid:= FWModeAccess("SB1",2) == "E" // Exclusiva por unidade de negocio
Local lSB1ExcFil := FWModeAccess("SB1",3) == "E" // Exclusiva por filial
Local nPosFil, nPF := 0
Local aAuxFilis := {}
Local cUnidNeg := FWUnitBusiness()
Local cEmpresa := FWCompany()
Local nTamEmpUn:= Len(cEmpresa+cUnidNeg)
Local nTamEmp  := Len(cEmpresa)


if SB1->(FieldPos("B1_REMANE")) > 0
	lRemane := .T.
EndIf
if SB1->(FieldPos("B1_PEDPRO")) > 0
	lPedpro := .T.
EndIf
//
aFilis := oDpm:GetFiliais()

If lSB1ExcFil

	nPosFil := aScan(aFilis,{ |x| x[1] == cFilant })
	aFilis := { aFilis[nPosFil] }

Elseif lSB1ExcEmp

	aSort(aFilis,,,{|x,y| x[1] < y[1]})

	If lSB1ExcUnid

		nPosFil := aScan(aFilis,{ |x| Left(x[1],nTamEmpUn) == cEmpresa+cUnidNeg })
		For nPF := nPosFil to Len(aFilis)
			If Left(aFilis[nPF,1],nTamEmpUn) == cEmpresa+cUnidNeg
				aAdd(aAuxFilis, aFilis[nPF])
			Else
				exit
			EndIf
		Next

	Else

		nPosFil := aScan(aFilis,{ |x| Left(x[1],nTamEmp) == cEmpresa })
		For nPF := nPosFil to Len(aFilis)
			If Left(aFilis[nPF,1],nTamEmp) == cEmpresa
				aAdd(aAuxFilis, aFilis[nPF])
			Else
				exit
			EndIf
		Next

	EndIf

	aFilis := aClone(aAuxFilis)

Endif

//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################

cArquivo := MV_PAR01

if lSchedule
	if aDir(cArquivo+"PARTINFO_*.DAT" ,aVetNome,aVetTam,aVetData,aVetHora) > 0
		cArquivo += aVetNome[1]
		Conout("OFINJD01 - Arquivo: "+cArquivo)
	Endif
Endif

cTblLogCod := oLogger:LogToTable({;
	{'VQL_AGROUP'     , 'OFINJD01'                                  },;
	{'VQL_TIPO'       , 'LOG_EXECUCAO'                              },;
	{'VQL_DADOS'      , 'MODO:' + IIF(!lSchedule, "Normal", "Scheduler")+" - "+Alltrim(cArquivo) } ;
})

if !File(cArquivo)
	if !lSchedule
		MsgStop(STR0006+cArquivo+STR0007,STR0008)
	Else
		Conout("OFINJD01 - "+STR0006+cArquivo+STR0007)
	endif
	oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD01'                                },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                            },;
		{'VQL_DADOS'      , STR0006+" "+Alltrim(cArquivo)+" "+STR0007 },;
		{'VQL_CODVQL'     , cTblLogCod                                } ;
	})
	Return
Endif
//

nHnd := FOPEN(Alltrim(cArquivo), 0)

FT_FGotop()
cBuffer = SPACE(256)
FREAD(nHnd, @cBuffer, 256)
//
//valores padroes
//#############################################################################
//# Calcula quantidade de linhas do arquivo                                   #
//#############################################################################
aVetNome := {}
aVetTam  := {}
aVetData := {}
aVetHora := {}
if lSchedule
	aDir(cArquivo ,aVetNome,aVetTam,aVetData,aVetHora)
Else
	aDir( MV_PAR01 ,aVetNome,aVetTam,aVetData,aVetHora)
	SetRegua(200)
Endif
// le o cabeÁalho do arquivo
nQtdReg := INT(aVetTam[1] / 256)
conout( "Quantidade total de itens :" + STR(nQtdReg) )
nCont	:= 0
nTotal := 0
conout("OFINJD01 - Gravando SB1")

for nIdx := 1 to LEN(aFilis)
	if EMPTY(aFilis[nIdx, 1])
		loop
	EndIf
	cFilant := aFilis[nIdx, 1]
	if Empty(cFilCpl)
		cFilCpl := cFilant
	EndIf
	//#############################################################################
	//# Armazena informacoes da marca                                             #
	//#############################################################################
	DBSelectArea("VE4")
	DBSetOrder(1)
	DBSeek(xFilial("VE4") + MV_PAR02 )
	cFEstCo := IF(VE4->VE4_FESTCO=="0","N","S")
	cCtaCtb := VE4->VE4_CTACTB
	cCenCus := VE4->VE4_CENCUS
	cAlmox  := VE4->VE4_ALMPAD
	cGruIte := VE4->VE4_GRUITE
	cCodFor := VE4->VE4_CODFOR
	cLojFor := VE4->VE4_LOJFOR
	//
	DBSelectArea("VE1")
	DBSetOrder(1)
	DBSeek(xFilial("VE1") + MV_PAR02 )
	cFabric := left(VE1->VE1_DESMAR,20)
	cTesEnt := ''
	cTesSai := ''
	if MV_PAR03 == 1
		cTesEnt := VE4->VE4_TESENT
		cTesSai := VE4->VE4_TESSAI
	Endif
	AADD( aDadosMarca, {cFilAnt,cFEstCo,cCtaCtb,cCenCus,cAlmox,cGruIte,cCodFor,cLojFor,cTesEnt,cTesSai,cFabric} )
Next

nMV_PAR04 := MV_PAR04
nMV_PAR05 := MV_PAR05

conout( FWTIMESTAMP() )
cStr := SPACE(256)
While FREAD(nHnd, @cStr, 256) > 0 // para cada item...
	while AT("'",cSTR) > 0
		nChar := AT("'",cSTR)
		cStr := Left(cSTR,nChar-1)+" "+Subs(cSTR,nChar+1)
	enddo

	nCont++
	nTotal++

	if nCont >= (nQtdReg/200)
		nCont = 0
		if !lSchedule
			IncRegua()
		Endif
		conout( FWTIMESTAMP() )
	Endif

	if LEN(aQueue) > (70*LEN(aFilis))
		conout(" Total : " +STR(nTotal) + " de " + STR(nQtdReg) )
		JD01ProcLote()
	Endif
	//
	// Armazena codigo do item do arquivo
	//
	cPartNumber          = STRTRAN( ALLTRIM(UPPER(Subs(cStr,1,18))), chr(13)+chr(10), ' ')

	lFaz := IIf(lPEOFNJD01,ExecBlock("OFNJD01",.f.,.f., {cPartNumber}),.T.)
	if ! lFaz
		loop
	endif

	cDescription         = STRTRAN( UPPER(Subs(cStr,25,27)), chr(13)+chr(10), ' ')
	nPackageQuantity     = val(Subs(cStr,52,5))
	nNetPrice            = val(Subs(cStr,57,16))
	nListPrice           = val(Subs(cStr,73,16))
	nCoreXNetPrice       = val(Subs(cStr,89,16))
	nCoreXListPrice      = val(Subs(cStr,105,16))
	nRetCredNetPrice     = val(Subs(cStr,121,16))
	nRetCredListPrice    = val(Subs(cStr,137,16))
	cRetIndicator        = STRTRAN(Iif(Subs(cStr,153,1)=="R","1","0")  , chr(13)+chr(10), ' ')
	cCritCode            = STRTRAN( Subs(cStr,154,2)  , chr(13)+chr(10), ' ')
	cTariffCode          = STRTRAN( Subs(cStr,222,10)  , chr(13)+chr(10), ' ')
	cPricedPerIndicator  = STRTRAN( Subs(cStr,163,1)  , chr(13)+chr(10), ' ')
	nShipWeight          = val(Subs(cStr,164,10))
	// CORRECAO DE PRECO
	if cPricedPerIndicator == "C"
		nNetPrice         := nNetPrice         / 100
		nListPrice        := nListPrice        / 100
		nCoreXNetPrice    := nCoreXNetPrice    / 100
		nCoreXListPrice   := nCoreXListPrice   / 100
		nRetCredNetPrice  := nRetCredNetPrice  / 100
		nRetCredListPrice := nRetCredListPrice / 100
	endif

	cGruDes := " "

	// VerificaÁ„o de CÛdigo de Grupo de Desconto da F·brica
	If lVE5_GDESFB
		cSQL := "SELECT VE5_GRUDST "
		cSQL += "FROM " + RetSQLName("VE5") + " "
		cSQL += "WHERE VE5_FILIAL = '" + xFilial("VE5") + "' "
		cSQL += "  AND VE5_CODMAR = '" + MV_PAR02 + "' "
		cSQL += "  AND VE5_GDESFB = '" + Subs(cStr,239,3) + "' "
		cSQL += "  AND D_E_L_E_T_ = ' '"
		cGruDes := FM_SQL(cSQL)
	EndIf

	aDadosPeca := {;
		{'B1_FILIAL'  , ''                               , .T.                       , .T. },;
		{'B1_COD'     , cPartNumber                      , .T.                       , .T. },;
		{'B1_PESO'    , nShipWeight                      , .F.                       , .F. },;
		{'B1_CRICOD'  , cCritCode                        , .F.                       , .F. },;
		{'B1_DESC'    , cDescription                     , IIf(nMV_PAR04==1,.F.,.T.) , .F. },;
		{'B1_QE'      , nPackageQuantity                 , .F.                       , .F. },;
		{'B1_PRV1'    , nListPrice                       , .F.                       , .F. },;
		{'B1_UREV'    , ddatabase                        , .F.                       , .F. },;
		{'B1_DTREFP1' , ddatabase                        , .F.                       , .F. },;
		{'B1_POSIPI'  , cTariffCode                      , .F.                       , .F. },;
		{'B1_CODITE'  , cPartNumber                      , .T.                       , .F. },;
		{'B1_CODFAB'  , cPartNumber                      , .T.                       , .F. },;
		{'B1_PERINV'  , 180                              , .T.                       , .F. },;
		{'B1_CONV'    , 1                                , .T.                       , .F. },;
		{'B1_IPI'     , 0                                , .T.                       , .F. },;
		{'B1_PICMENT' , 0                                , .T.                       , .F. },;
		{'B1_FLAGSUG' , "1"                              , .T.                       , .F. },;
		{'B1_CLASSVE' , "1"                              , .T.                       , .F. },;
		{'B1_ANUENTE' , "2"                              , .T.                       , .F. },;
		{'B1_MSBLQL'  , "2"                              , .T.                       , .F. },;
		{'B1_BALANCA' , "0"                              , .T.                       , .F. },;
		{'B1_ENVOBR'  , "0"                              , .T.                       , .F. },;
		{'B1_LOCALIZ' , "N"                              , .T.                       , .F. },;
		{'B1_CONTSOC' , "N"                              , .T.                       , .F. },;
		{'B1_SITPROD' , "N"                              , .T.                       , .F. },;
		{'B1_MONO'    , "N"                              , .T.                       , .F. },;
		{'B1_FANTASM' , "N"                              , .T.                       , .F. },;
		{'B1_TIPODEC' , "N"                              , .T.                       , .F. },;
		{'B1_CONTRAT' , "N"                              , .T.                       , .F. },;
		{'B1_IRRF'    , "N"                              , .T.                       , .F. },;
		{'B1_GRADE'   , "N"                              , .T.                       , .F. },;
		{'B1_IMPZFRC' , "N"                              , .T.                       , .F. },;
		{'B1_TIPOCQ'  , "M"                              , .T.                       , .F. },;
		{'B1_APROPRI' , "D"                              , .T.                       , .F. },;
		{'B1_TIPO'    , "ME"                             , .T.                       , .F. },;
		{'B1_SEGUM'   , "PC"                             , .T.                       , .F. },;
		{'B1_UM'      , "PC"                             , .T.                       , .F. },;
		{'B1_ATIVO'   , "S"                              , .T.                       , .F. },;
		{'B1_PIS'     , "S"                              , .T.                       , .F. },;
		{'B1_COFINS'  , "S"                              , .T.                       , .F. },;
		{'B1_ORIGEM'  , " "                              , .T.                       , .F. },;
		{'B1_GRUDES'  , cGruDes                          , IIf(nMV_PAR05==1,.F.,.T.) , .F. },;
		{'B1_CLASSE'  , " "                              , .T.                       , .F. } ;
	}

	if lRemane
		AADD(aDadosPeca, {'B1_REMANE'  , cRetIndicator , .F. , .F. })
	endIF
	if lPedpro
		AADD(aDadosPeca, {'B1_PEDPRO'  , "1"           , .T. , .F. })
	endIF

	aDadosAdPeca := {;
		{'B5_FILIAL'  , ''                , .T. , .T. },;
		{'B5_COD'     , cPartNumber       , .T. , .T. },;
		{'B5_PRV2'    , nNetPrice         , .F. , .F. },;
		{'B5_PRV3'    , nCoreXNetPrice    , .F. , .F. },;
		{'B5_PRV4'    , nCoreXListPrice   , .F. , .F. },;
		{'B5_PRV5'    , nRetCredNetPrice  , .F. , .F. },;
		{'B5_PRV6'    , nRetCredListPrice , .F. , .F. },;
		{'B5_DTREFP2' , dDataBase         , .F. , .F. },;
		{'B5_DTREFP3' , dDataBase         , .F. , .F. } ;
	}

	cFilant := cFilCpl
	aMarca := aDadosMarca[ ASCAN(aDadosMarca, {|aDt| aDt[IDX4_FILIAL] == cFilAnt }) ]¥¥
	////////////////////////////////////////////////////////
	// Chamada do Ponto de Entrada para manipulaÁ„o dos
	// Arrays de PeÁas (SB1) e Complemnento das PeÁas (SB5)
	// Antes da gravaÁ„o
	////////////////////////////////////////////////////////
	If lPEOJD01AGR 
		ExecBlock("OJD01AGR",.f.,.f.)	
	Endif
	//
	aX := ACLONE(aDadosPeca)
	aX[1,2] := xFilial('SB1')
	aY := ACLONE(aDadosAdPeca)
	aY[1,2] := xFilial('SB5')

	// DADOS DA MARCA
	AADD(aX, {'B1_GRUPO'   , aMarca[IDX4_GRUITE] , .T. , .F. })
	AADD(aX, {'B1_LOCPAD'  , aMarca[IDX4_ALMOXA] , .T. , .F. })
	AADD(aX, {'B1_FABRIC'  , aMarca[IDX4_FABRIC] , .T. , .F. })
	AADD(aX, {'B1_LOJPROC' , aMarca[IDX4_LOJFOR] , .T. , .F. })
	AADD(aX, {'B1_FORAEST' , aMarca[IDX4_FESTCO] , .T. , .F. })
	AADD(aX, {'B1_CONTA'   , aMarca[IDX4_CTACTB] , .T. , .F. })
	AADD(aX, {'B1_CC'      , aMarca[IDX4_CENCUS] , .T. , .F. })
	AADD(aX, {'B1_PROC'    , aMarca[IDX4_FORNEC] , .T. , .F. })
	AADD(aX, {'B1_TS'      , aMarca[IDX4_TESSAI] , .T. , .F. })
	AADD(aX, {'B1_TE'      , aMarca[IDX4_TESENT] , .T. , .F. })

	aAdd(aQueue, {cFilAnt, cPartNumber, aX, aY})

End
//
JD01ProcLote() // resto do lote
//
FClose(nHnd)

conout("OFINJD01 - Gravando SB5")
//
// Eis a jogada de mestre, atualiza os valores das filiais que n„o foram feitas(somente novos) de acordo com a filial que fizemos por completo o ajuste.
//
cFilCpl := ""
for nIdx := 1 to LEN(aFilis)
	if Empty(cFilCpl)
		cFilCpl := aFilis[nIdx, 1]
		loop // pq completa n„o precisa fazer nada, ela vai servir de base
	else
		// pegas as filiais para verificar a n„o existencia
		cFilAnt := aFilis[nIdx, 1]
		cFilSB5  := xFilial('SB5')
		cFilSBZ  := xFilial('SBZ')
		// seta filial principal que tem todas as peÁas
		cFilAnt := cFilCpl
	end

	cQuery := " SELECT B1_COD"
	cQuery += "   FROM "+RetSqlName('SB1')+" SB1 "
	cQuery += "  WHERE B1_FILIAL = '"+xFilial('SB1')+"' "
	cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "    AND NOT EXISTS ( SELECT B5_COD "
	cQuery +=                             "  FROM "+RetSqlName('SB5')+" SB5 "
	cQuery +=                             " WHERE B5_FILIAL = '"+cFilSB5+"' "
	cQuery +=                             "   AND B5_COD = B1_COD "
	cQuery +=                             "   AND SB5.D_E_L_E_T_ = ' ' )"

	aFaltantes := oSql:GetSelectArray(cQuery)
	if ! Empty(aFaltantes)
		for nIdx2 := 1 to LEN(aFaltantes)
			RecLock("SB5", .T.)
			SB5->B5_FILIAL := cFilSB5
			SB5->B5_COD    := aFaltantes[nIdx2]
			SB5->(MsUnLock())
		next
	end

	if cDadosProd == "SBZ"
		cQuery := " SELECT B1_COD"
		cQuery += "   FROM "+RetSqlName('SB1')+" SB1 "
		cQuery += "  WHERE B1_FILIAL = '"+xFilial('SB1')+"' "
		cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "    AND NOT EXISTS ( SELECT BZ_COD "
		cQuery +=                             "  FROM "+RetSqlName('SBZ')+" SBZ "
		cQuery +=                             " WHERE BZ_FILIAL = '"+cFilSBZ+"' "
		cQuery +=                             "   AND BZ_COD = B1_COD "
		cQuery +=                             "   AND SBZ.D_E_L_E_T_ = ' ' )"

		aFaltantes := oSql:GetSelectArray(cQuery)
		if ! Empty(aFaltantes)
			for nIdx2 := 1 to LEN(aFaltantes)
				RecLock("SBZ", .T.)
				SBZ->BZ_FILIAL := cFilSBZ
				SBZ->BZ_COD    := aFaltantes[nIdx2]
				SBZ->(MsUnLock())
			next
		end
	end

	cQuery := " "
	if tcGetDb() == "ORACLE"
		cQuery += " UPDATE "+RetSqlName('SB5')+" T1 SET "
		cQuery +=		" (B5_PRV2,B5_PRV3,B5_PRV4,B5_PRV5,B5_PRV6,B5_DTREFP2,B5_DTREFP3) "
		cQuery +=	   "= (SELECT T2.B5_PRV2,T2.B5_PRV3,T2.B5_PRV4,T2.B5_PRV5,T2.B5_PRV6, "
		cQuery +=				 "T2.B5_DTREFP2,T2.B5_DTREFP3 "
		cQuery +=			" FROM "+RetSqlName('SB5')+" T2 "
		cQuery +=			" WHERE T2.B5_FILIAL  = '"+cFilSB5+"' "
		cQuery +=			  " AND T2.B5_COD     = T1.B5_COD "
		cQuery +=			  " AND T2.D_E_L_E_T_ = ' ' "
		cQuery +=		" )"
		cQuery += " WHERE T1.B5_FILIAL  = '"+cFilSB5+"' "
		cQuery +=	" AND T1.D_E_L_E_T_ = ' ' "
		cQuery +=	" AND T1.B5_COD IN ("
		cQuery +=							"SELECT B1_COD "
		cQuery +=							"FROM "+RetSqlName('SB1')+" SB1_R "
		cQuery +=							"WHERE SB1_R.B1_FILIAL = '"+xFilial('SB1')+"' "
		cQuery +=							 " AND SB1_R.B1_GRUPO IN "+oDpm:GetInGroups()
		cQuery +=							 " AND SB1_R.B1_UREV   = '"+DTOS(ddatabase)+"' "
		cQuery +=							 " AND SB1_R.D_E_L_E_T_ = ' ' "
		cQuery +=						" ) "
	else
		cQuery += " UPDATE "+RetSqlName('SB5')+" SET "
		cQuery += "        B5_PRV2     = COMP.B5_PRV2, "
		cQuery += "        B5_PRV3     = COMP.B5_PRV3, "
		cQuery += "        B5_PRV4     = COMP.B5_PRV4, "
		cQuery += "        B5_PRV5     = COMP.B5_PRV5, "
		cQuery += "        B5_PRV6     = COMP.B5_PRV6, "
		cQuery += "        B5_DTREFP2  = COMP.B5_DTREFP2, "
		cQuery += "        B5_DTREFP3  = COMP.B5_DTREFP3 "
		cQuery += "   FROM ( SELECT * FROM "+RetSqlName('SB5')+" WHERE B5_FILIAL = '"+cFilSB5+"' AND D_E_L_E_T_ = ' ' ) COMP "
		cQuery += "  WHERE "+RetSqlName('SB5')+".B5_COD = COMP.B5_COD "
		cQuery += "    AND "+RetSqlName('SB5')+".D_E_L_E_T_  = ' ' "
		cQuery += "    AND "+RetSqlName('SB5')+".B5_FILIAL = '"+cFilSB5+"' "
		cQuery += "    AND "+RetSqlName('SB5')+".B5_COD IN ("
		cQuery +=          "SELECT B1_COD "
		cQuery +=            "FROM "+RetSqlName('SB1')+" SB1_R "
		cQuery +=          " Where SB1_R.B1_FILIAL = '"+xFilial('SB1')+"' "
		cQuery +=            " AND SB1_R.B1_GRUPO IN "+oDpm:GetInGroups()
		cQuery +=            " AND SB1_R.B1_UREV   = '"+DTOS(ddatabase)+"' "
		cQuery +=            " AND SB1_R.D_E_L_E_T_ = ' ' "
		cQuery += " ) "
	EndIf
	If TcsqlExec(cQuery) < 0
		conout(cQuery)
		if !lSchedule
			ALERT(TCSQLError())
		EndIf
		oLogger:LogToTable({;
			{'VQL_AGROUP'     , 'OFINJD01'                                },;
			{'VQL_TIPO'       , 'ERRO_SQL'                                },;
			{'VQL_DADOS'      , TCSQLError()                              },;
			{'VQL_CODVQL'     , cTblLogCod                                } ;
		})
	EndIf
next


//
//#############################################################################
//# Move o arquivo para o diretorio SALVA                                     #
//#############################################################################
lErro := .f.
cPath := ""
if lSchedule
	cArq := cArquivo
Else
	cArq := MV_PAR01
Endif
cArquivo := ""
For nCntFor := Len(cArq) to 1 step -1
	if Subs(cArq,nCntFor,1) == "\" // "
		cPath = Left(cArq,nCntFor)
		cArquivo := SUBS(cArq,nCntFor+1,60)
		exit
	endif
next

cPathS = cPath + "SALVA"
aDir := Directory(cPathS,"D")
If Len(aDir) = 0
	If MakeDir(cPathS) <> 0
		lErro := .t.
	EndIf
endif
if !lErro
	Copy File &(cPath+cArquivo) to &(cPath+"SALVA\"+cArquivo) //"
	Dele File &(Alltrim(cArq))
endif
oLogger:CloseOpened(cTblLogCod)

if !lSchedule
	if !Empty(cLog)
		DEFINE MSDIALOG oDlgLog TITLE OemtoAnsi(STR0009) FROM  08.1,10.6 TO 30.4,80.3 OF oMainWnd
		@ 001,001 GET oMsgLog VAR cLog OF oDlgLog MEMO SIZE 273,140 PIXEL READONLY MEMO
		DEFINE SBUTTON FROM 152,240 TYPE 1 ACTION oDlgLog:End() ENABLE OF oDlgLog
		//
		ACTIVATE MSDIALOG oDlgLog CENTER
		//
	Endif
Endif
DBSelectArea("SB1")
DBSetOrder(1)

if !lSchedule
	MsgInfo(STR0010,STR0008) // Arquivo importado com sucesso.
Else
	Conout("OFINJD01 - "+STR0010) // Arquivo importado com sucesso.
Endif
//
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunÁ„o    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
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
	Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE
	Local nOpcDiret  := GETF_RETDIRECTORY

	aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
	"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
	"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
	"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ aAdd a Pergunta                                              ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

	// Pergunte quando chamado pelo Menu
	aAdd(aSX1,{cPerg,"01",STR0013,"","","MV_CH1","C",99,0,0,"G","Mv_Par01:=cGetFile('Arquivos |PARTINFO*.DAT','',,,,"+AllTrim(Str(nOpcGetFil))+")","mv_par01",""     ,"","","","",""     ,"","","","","","","","","","","","","","","","","","",""   ,"","S"})
	aAdd(aSX1,{cPerg,"02",STR0014,"","","MV_CH2","C",03,0,0,"G",""                                                                                ,"mv_par02",""     ,"","","","",""     ,"","","","","","","","","","","","","","","","","","","VE1","","S"})
	aAdd(aSX1,{cPerg,"03",STR0015,"","","MV_CH3","N",01,0,0,"C",""                                                                                ,"mv_par03",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aSX1,{cPerg,"04",STR0021,"","","MV_CH4","N",01,0,0,"C",""                                                                                ,"mv_par04",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aSX1,{cPerg,"05",STR0022,"","","MV_CH5","N",01,0,0,"C",""                                                                                ,"mv_par05",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })

	// Pergunte quando chamado pelo Schedule
	aAdd(aSX1,{cPerg_S,"01",STR0020,"","","MV_CH1","C",99,0,0,"G","MV_PAR01:=cGetFile('Diretorio','',,,,"+AllTrim(Str(nOpcDiret))+")"             ,"MV_PAR01",""     ,"","","","",""     ,"","","","","","","","","","","","","","","","","","",""   ,"","S"})
	aAdd(aSX1,{cPerg_S,"02",STR0014,"","","MV_CH2","C",03,0,0,"G",""                                                                              ,"mv_par02",""     ,"","","","",""     ,"","","","","","","","","","","","","","","","","","","VE1","","S"})
	aAdd(aSX1,{cPerg_S,"03",STR0015,"","","MV_CH3","N",01,0,0,"C",""                                                                              ,"mv_par03",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aSX1,{cPerg_S,"04",STR0021,"","","MV_CH4","N",01,0,0,"C",""                                                                              ,"mv_par04",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })
	aAdd(aSX1,{cPerg_S,"05",STR0022,"","","MV_CH5","N",01,0,0,"C",""                                                                                ,"mv_par05",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })

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

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | JD01B1DoUpd| Autor |  Vinicius Gati        | Data | 07/11/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza dados no banco com sql puro sem usar framework seek |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function JD01B1DoUpd(aDados)
	Local nInd := 0
	Local cQuery := " UPDATE " + RetSqlName('SB1') + " SET "
	Local cWhere  := ""
	Local cValues := ""
	for nInd := 1 to LEN(aDados)
		aDadosCampo := aDados[nInd]
		//
		If aDadosCampo[IDX_CHAVE] == .T.
			cWhere  += IIF(!EMPTY(cWhere), " AND ", "") + JD01SqlComp(aDadosCampo[IDX_CAMPO], aDadosCampo[IDX_VALOR])
		EndIf		
		If aDadosCampo[IDX_SO_NOVO] == .F.
			cValues += IIF(!EMPTY(cValues), ",", "") + JD01SqlComp(aDadosCampo[IDX_CAMPO], aDadosCampo[IDX_VALOR])
		EndIf
	next
	if TCSQLEXEC(cQuery + cValues + " WHERE " + cWhere + " AND D_E_L_E_T_ = ' ' ") < 0
		conout('Erro sql : ' + cQuery + cValues + " WHERE " + cWhere + " AND D_E_L_E_T_ = ' ' ")
		oLogger:LogToTable({;
			{'VQL_AGROUP'     , 'OFINJD01'                                },;
			{'VQL_TIPO'       , 'ERRO_SQL'                                },;
			{'VQL_DADOS'      , cQuery + cValues + " WHERE " + cWhere + " AND D_E_L_E_T_ = ' ' " },;
			{'VQL_CODVQL'     , cTblLogCod                                } ;
		})
		return .f.
	end
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | JD01B5DoUpd| Autor |  Vinicius Gati        | Data | 07/11/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza dados no banco com sql puro sem usar framework seek |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function JD01B5DoUpd(aDados)
	Local nInd := 0
	Local cQuery := " UPDATE " + RetSqlName('SB5') + " SET "
	Local cWhere  := ""
	Local cValues := ""
	for nInd := 1 to LEN(aDados)
		aDadosCampo := aDados[nInd]
		//
		If aDadosCampo[IDX_CHAVE] == .T.
			cWhere  += IIF(!EMPTY(cWhere), " AND ", " ") + JD01SqlComp(aDadosCampo[IDX_CAMPO], aDadosCampo[IDX_VALOR])
		EndIf
		If aDadosCampo[IDX_SO_NOVO] == .F.
			cValues += IIF( ! EMPTY(cValues), ",", " ") + JD01SqlComp(aDadosCampo[IDX_CAMPO], aDadosCampo[IDX_VALOR])
		EndIf
	next
	if TCSQLEXEC(cQuery + cValues + " WHERE " + cWhere + " AND D_E_L_E_T_ = ' ' ") < 0
		conout('Erro sql : ' + cQuery + cValues + " WHERE " + cWhere + " AND D_E_L_E_T_ = ' ' ")
		oLogger:LogToTable({;
			{'VQL_AGROUP'     , 'OFINJD01'                                },;
			{'VQL_TIPO'       , 'ERRO_SQL'                                },;
			{'VQL_DADOS'      , cQuery + cValues + " WHERE " + cWhere + " AND D_E_L_E_T_ = ' ' " },;
			{'VQL_CODVQL'     , cTblLogCod                                } ;
		})
		return .f.
	Else
		return .t.
	end
Return TCSQLEXEC(cQuery + cValues + " WHERE " + cWhere + " AND D_E_L_E_T_ = ' ' ")

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | JD01SqlComp| Autor |  Vinicius Gati        | Data | 07/11/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza dados no banco com sql puro sem usar framework seek |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function JD01SqlComp(cCampo, cValor, cOper)
	Local cSql := ""
	Default cOper = " = "

	cSql += " " + cCampo + cOper /* = */
	Do Case
		Case VALTYPE(cValor) == "S" .OR. VALTYPE(cValor) == "C"
			if Empty( FwNoAccent(Alltrim(cValor)) )
				cSql += "' '"
			else
				cSql += "'"+ FwNoAccent(Alltrim(cValor)) +"'"
			endif
		Case VALTYPE(cValor) == "D"
			cSql += "'"+ DTOS(cValor) +"'"
		Case VALTYPE(cValor) == "N"
			cSql += STRTRAN( STR( cValor ), ",", "" )
		OtherWise
			cSql += "'"+ cValor +"'"
	EndCase
Return cSql + " "

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | JD01Update | Autor |  Vinicius Gati        | Data | 07/11/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Faz a atualizacao ou inserÁ„o da da peca                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function JD01Update(aFila)
	Local nIdx := 1
	Local nIdx2 := 1
	Local aDadosPeca
	Local aDadosAdPeca

	For nIdx := 1 to LEN(aFila)
		aItem := aFila[nIdx]
		if cFilAnt != aItem[IDX2_FILIAL]
			cFilAnt := aItem[IDX2_FILIAL]
		end

		aDadosPeca   := aItem[IDX2_DADOS]
		aDadosAdPeca := aItem[IDX2_DADOS_ADC]

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial('SB1')+aDadosPeca[IDX2_PECA,IDX_VALOR]))
		if ! SB1->(FOUND())
			RecLock("SB1", .T. /*Novo*/ )
			for nIdx2 := 1 to LEN(aDadosPeca)
				aDadosCampo := aDadosPeca[nIdx2]
				if ValType(adadoscampo[IDX_VALOR]) == "C"
					SB1->&( aDadosCampo[IDX_CAMPO] ) := FwNoAccent(Alltrim(aDadosCampo[IDX_VALOR]))
				Else
					SB1->&( aDadosCampo[IDX_CAMPO] ) := aDadosCampo[IDX_VALOR]
				Endif
			next
			SB1->B1_FILIAL := xFilial('SB1')
			SB1->(MsUnLock())
		else
			if cFilant == cFilCpl // se filial È compartilhada preciso fazer somente 1 vez a inserÁ„o
				JD01B1DoUpd(aDadosPeca)
			end
		end
		//
		// CriaÁ„o / ALteraÁ„o do SB5
		//
		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial('SB5')+aDadosPeca[2,IDX_VALOR]))
		if ! SB5->(FOUND())
			RecLock("SB5", .T.)
			for nIdx2 := 1 to LEN(aDadosAdPeca)
				aDadosCampo := aDadosAdPeca[nIdx2]
				SB5->&( aDadosCampo[IDX_CAMPO] ) := aDadosCampo[IDX_VALOR]
			next
			SB5->B5_FILIAL := xFilial('SB5')
			SB5->(MsUnLock())
		else
			if cFilant == cFilCpl // se filial È compartilhada preciso fazer somente 1 vez a inserÁ„o
				JD01B5DoUpd(aDadosAdPeca)
			end
		end

	Next
	//
Return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |JD01ProcLote| Autor |  Vinicius Gati        | Data | 07/11/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Processa as peÁas que est„o na fila(queue)                   |##
##|          |                                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function JD01ProcLote()
	//
	JD01Update(aQueue)
	aQueue  := {}
	//
Return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | AcertaSXD  | Autor | Andre Luis Almeida    | Data | 13/04/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Criacao do SXD - tabela utilizada no cadastro de Schedule    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function AcertaSXD()
Local aArea	:= GetArea()
SXD->(DbSetOrder(1))
If !SXD->(DbSeek("OFINJD01"))
	DbSelectArea("SXD")
	RecLock("SXD",.T.)
	SXD->XD_TIPO    := "P"
	SXD->XD_FUNCAO  := "OFINJD01"
	SXD->XD_PERGUNT := "OFINJD01_S"
	SXD->XD_PROPRI  := "S"
	SXD->XD_TITBRZ  := STR0018 // ImportaÁ„o de PreÁos JD - PeÁas
	SXD->XD_TITSPA  := STR0018 // ImportaÁ„o de PreÁos JD - PeÁas
	SXD->XD_TITENG  := STR0018 // ImportaÁ„o de PreÁos JD - PeÁas
	SXD->XD_DESCBRZ := STR0019 // Este programa tem o objetivo importar os PreÁos das PeÁas JD.
	SXD->XD_DESCSPA := STR0019 // Este programa tem o objetivo importar os PreÁos das PeÁas JD.
	SXD->XD_DESCENG := STR0019 // Este programa tem o objetivo importar os PreÁos das PeÁas JD.
	MsUnLock()
EndIf
RestArea(aArea)
If .f.
	SchedDef() // Somente para nao dar warning na compilacao
EndIf
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | SchedDef   | Autor | Andre Luis Almeida    | Data | 13/04/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Funcao utilizada no cadastro de Schedule                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"OFINJD01_S",;
	"",;
	"",;
	"" ;
	}
Return aParam