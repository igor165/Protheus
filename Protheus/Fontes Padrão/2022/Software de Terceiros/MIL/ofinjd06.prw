/////////////////
// versao 0056 //
/////////////////

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "tbiconn.ch"
#include "OFINJD06.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFINJD06   | Autor | Luis Delorme          | Data | 12/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | REFACTORED | Autor | Vinicius Gati         | Data | 07/11/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exportação do layout John Deere - DPMEXT                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD06(aParam, lSoGer, aDpmCfgs, cTipGer)
  Local cDesc1       := STR0001
  Local cDesc2       := STR0002
  Local cDesc3       := STR0003
  Local aSay         := {}
  Local aButton      := {}
  Local cPath        := ""
  Local nIdx         := 1
  Private lAuto      := valtype(aParam) != "U" //Chamada Automatica
  Private oLogger     := Nil
  Private oLogTrf     := Nil
  Private oDpePecas   := Nil
  Private oSqlHlp     := Nil
  Private oDS         := Nil
  Private cTblLogCod  := ""
  Private cSavePath   := ""
  Private cTipoExt    := "D"
  Private nArqGer     := 0
  Private aVetCods    := {}
  Private lEmuPrism   := .F.
  Private aMod36Dem   := {}
  Private lUsaNNR     := NNR->(FieldPos('NNR_VDADMS')) > 0
  Private cDadosProd  := GetNewPar("MV_MIL0054","SBZ")
  Private cTitulo     := STR0004
  Private cPerg       := "ONJD06"
  Private aFilis      := {}
  Private dData36At   := Nil
  Private oArHelp     := Nil
  Private lDebug      := .F.
  Default aDpmCfgs    := {}
  Private oDevObj     := JsonObject():New()
  Default lSoGer      := .F.
  Private cArquivo
  Private oDpm
  oDpm      := DMS_DPM():New()
  oUtil     := DMS_Util():New()
  oDpe      := DMS_DPMDPE_1_3():New()

  oLogger   := DMS_Logger():New("OFINJD06_"    +dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
  oLogDebug := DMS_Logger():New("OFINJD06_DBG_"+dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
  oLogTrf   := DMS_Logger():New("OFINJD06_TRF_"+dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
  
  oSqlHlp   := DMS_SqlHelper():New()
  oDpePecas := DMSB_DpePecas():New()
  oDS       := DMSB_DirectShipment():New()
  oArHelp   := DMS_ArrayHelper():New()
  oDS:AtualizarPecas()

	if ! oDpm:Ready()
		if ! lAuto
			MsgInfo(oDpm:cLastError, STR0008 /*atencao*/)
		endif
		Return .F.
	endif

  dData36At := oUtil:RemoveMeses(dDataBase, 12)
  dData36At := oUtil:RemoveMeses(dData36At, 12) // 24
  dData36At := oUtil:RemoveMeses(dData36At, 12) // 36
  //
  //
  // Isto serve para gerar arquivo sem perguntar nada via ""menu"" usado por threads para nao consumir licenca
  If lSoGer
    lAuto := lSoGer
  EndIf
  //
  CriaSX1()
  SBZ->(DBSetOrder(1))
  //
  aAdd( aSay, cDesc1 )
  aAdd( aSay, cDesc2 )
  aAdd( aSay, cDesc3 )
  //
  nOpc := 0
  aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
  aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
  aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
  //
  if !lAuto
    FormBatch( cTitulo, aSay, aButton )
    //
    If nOpc <> 1
      Return
    Endif
  endif

  lDebug := oDpm:DebugMode() .or. "OFINJD06" $ GetNewPar("MV_XMILDBG", "NAO")

  conout("OFINJD06 -> Iniciando rotina <-")
  if lDebug
    conout("OFINJD06 -> Modo debug ativado <-")
  endif

  lEmuPrism := "EMUPRISM" $ GetNewPar("MV_XMILDBG", "NAO") .AND. ( LEFT(TIME(), 2) == "18" .OR. LEFT(TIME(), 2) == "20" .OR. LEFT(TIME(), 2) == "21" )
  Pergunte(cPerg,.f.)

  if lAuto
    cTipoExt := "I"
    MV_PAR03 := 3
  else
    cTipoExt := IIF( MV_PAR02 == 1, "D", "I")
  endif

  if ! Empty(cTipGer)
    cTipoExt := cTipGer
  Endif

  if ! oDpe:canGenDelta()
    cTipoExt := "I"
  EndIf

  if ! Empty(cTipGer)
    conout("OFINJD06 -> Tipo de Geração vinda do OFINJD35 ("+cTipGer+")")
  EndIf
  If Empty(aDpmCfgs) .OR. ! lSoGer // se não for "Só gera arquivo" deve pegar todos os grupos
    aDpmCfgs := oDpm:GetConfigs()
  EndIf

  // Logs iniciais
  if lAuto
    cModo := IIF(lAuto, "Agendado", "Menu")
    oLogger:Log({'TIMESTAMP', "OFINJD06 rodado em modo "+cModo+" data: " + DTOS(dDatabase) + "("+time()+")"})
    cTblLogCod := oLogger:LogToTable({;
      {'VQL_AGROUP'     , 'OFINJD06'         },;
      {'VQL_TIPO'       , 'LOG_EXECUCAO'     },;
      {'VQL_DADOS'      , "MODO: "+cModo     } ;
    })
  EndIf

  if lEmuPrism
    oLogger:Log({"TIMESTAMP","Parametro de emulação de PRISM setado para SIM"})
  EndIf

  If ! oDpm:IsProcessed(dDatabase)
    If lAuto
      oLogger:Log({'TIMESTAMP', STR0030 /* "OFINJD06 Não pode ser gerado devido a falha no processamento de dados diário(OFINJD31 no prism)."*/})
      cTblLogCod := oLogger:LogToTable({;
        {'VQL_AGROUP'     , 'OFINJD06' },;
        {'VQL_TIPO'       , 'ERRO'     },;
        {'VQL_DADOS'      , STR0030 /* "OFINJD06 Não pode ser gerado devido a falha no processamento de dados diário(OFINJD31 no prism)."*/ } ;
      })
    Else
      Alert(STR0030 /* "OFINJD06 Não pode ser gerado devido a falha no processamento de dados diário(OFINJD31 no prism)."*/)
    EndIf
    Return // não gerará arquivo
  EndIf

  oLogger:Log({'TIMESTAMP', "Quantidade de grupos DPM configurados: " + STR(LEN(aDpmCfgs)) })
  If LEN(aDpmCfgs) == 0
    if lAuto
      ExportArq(lAuto, oDpm:GetFiliais(), ,)
    else
      Processa( {|lEnd| ExportArq(lAuto, oDpm:GetFiliais(), ,)}, STR0005,STR0006)
    endif
    oLogger:CloseOpened(cTblLogCod)
  Else
    for nIdx := 1 to Len(aDpmCfgs)
      If nArqGer < LEN(aDpmCfgs)
        oDpmCfg := aDpmCfgs[nIdx]
        aFilis  := oDpmCfg:GetFiliais()
        cPath   := oDpmCfg:GetPath()
        cConta  := oDpmCfg:GetAccount()

        oLogger:Log({'TIMESTAMP', "Iniciando geração PartsData(DPE) para conta: " + cConta })

        If lAuto
          ExportArq(lAuto, aFilis, cPath, cConta)
          nArqGer ++
        else
          Processa( {|lEnd| ExportArq(lAuto, aFilis, cPath, cConta)}, STR0005,STR0006)
          nArqGer ++
        EndIf
        oLogger:CloseOpened(cTblLogCod) // fecha log de execução
      EndIf
    Next
  Endif

  oLogger:Log({'TIMESTAMP', "Quantidade de arquivos gerados: " + STR(nArqGer) })
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ExportArq  | Autor | Luis Delorme          | Data | 29/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exporta arquivo                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq(lAuto, aFilis, cPath, cAccount)
Local aVetNome := {}
Local aVetTam  := {}
Local aVetData := {}
Local aVetHora := {}
Local nCntFor, nCntFor2
Local cFilBkp  := cFilAnt
Local cGruVei  := GetNewPar("MV_GRUVEI", "VEI") + Space(4 - Len(GetNewPar("MV_GRUVEI", "VEI")))

Local nIdxFil  := 1
Local nIdxHR   := 0
Local cAl := "UIHIHI"
Local aDados
Local cFileDest := ""
Local cDirSave := ""
Local nIdx1 := 1
local nIdx  := 1
Local nIdxDelDS := 0
Default cPath := ""

////////////////////////////////////////////////////////////////////////////////////
/////////////// Delta forçado para geração noturna em //////////////////////////////
/////////////// determinado horario, a pedido da JD   //////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// removido pois agora não será mais usado delta
//
// if lAuto .AND. oDpe:canGenDelta() .AND. lEmuPrism
//  conout(" Rodando forçadamente um delta que esta no horario de " + TIME() )
//  oLogger:Log({"TIMESTAMP"," Rodando forçadamente um delta que esta no horario de " + TIME()})
//  lEmuPrism := .T.
//  cTipoExt := "D"
// EndIf
//
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

if lDebug
  conout('Rotina sendo executada em modo debug ' + FWTimeStamp(3))
  aFilis := {aFilis[1]}
end

oDpePecas:ColetaItensDia()

// estou fazendo isso só para garantir, mas ninguem reportou problema e no meu aqui ficou 00000
if EMPTY(cAccount)
  cAccount := MV_PAR08
Endif
//
conout("OFINJD06 - Executando com lAuto ="+IIF(lAuto,"TRUE","FALSE")+ " e cTipoEXT = '"+cTipoExt+"'")
//
cFilSQL := "('" + oArHelp:Join(  oArHelp:Map(aFilis, {|el| el[1] }),  "','") + "')"
//
cArquivo := "DLR2JD_DPMEXT_" + ;
  cTipoExt + "_" + ;
  STRZERO(VAL( IIF( !EMPTY(cAccount), cAccount, MV_PAR08) ),6) + "_" +;
  dtos(ddatabase) + "_" + ;
  SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + IIF( (oDpe:isPrism() .OR. lEmuPrism) .OR. cTipoExt == 'D', ".DPM", ".DPMBRA") // i_sPrism() == GetNewPar("MV_MIL0067","N") == "S"
//
//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
//
aValoresH := {}
aAdd(aValoresH, "~"+STRZERO(VAL( IIF( !EMPTY(cAccount), cAccount, MV_PAR08) ),6)+"~")
aAdd(aValoresH, STRZERO(YEAR(DDATABASE),4)+"-"+STRZERO(MONTH(DDATABASE),2)+"-"+STRZERO(DAY(DDATABASE),2))
aAdd(aValoresH, TIME())
aAdd(aValoresH, cTipoExt )
aAdd(aValoresH, "1.3")
aAdd(aValoresH, "TOTVS PROTHEUS ãÃçÇ")
aAdd(aValoresH, "2.1.5")
//
// Ultimo dpmxfer importado
// Ultimo dpmord importado
// todos os xfer e ords importados
//
cUltOrd  := ALLTRIM(FM_SQL(" SELECT VQL_DADOS FROM " +RetSqlName('VQL')+ " WHERE VQL_AGROUP = 'DPMORD_DPE' AND VQL_TIPO = 'CODIGO_DPE' ORDER BY R_E_C_N_O_ DESC "))
aAdd(aValoresH, Alltrim(cUltOrd))
//
cUltXfer := ALLTRIM(FM_SQL(" SELECT VQL_DADOS FROM " +RetSqlName('VQL')+ " WHERE VQL_AGROUP = 'DPMXFER_DPE' AND VQL_TIPO = 'CODIGO_DPE' ORDER BY R_E_C_N_O_ DESC "))
aAdd(aValoresH, Alltrim(cUltXfer))
//
aCodigos := oSqlHlp:GetSelect({ ;
  {'campos', {'VQL_DADOS', 'VQL_CODIGO'}}, ;
  {'query', "SELECT VQL_DADOS, VQL_CODIGO FROM " +RetSqlName('VQL')+ " WHERE VQL_AGROUP IN ('DPMORD_DPE', 'DPMXFER_DPE') AND VQL_TIPO = 'CODIGO_DPE' AND VQL_DATAF = ' ' AND D_E_L_E_T_ = ' ' AND VQL_DADOS NOT IN ('"+cUltXfer+"', '"+cUltOrd+"') ORDER BY R_E_C_N_O_ ASC"};
})
aCodes := oArHelp:Map(aCodigos, {|el| ALLTRIM(el:GetValue('VQL_DADOS'))})
if !Empty(cUltXfer)
  AADD(aCodes, cUltXfer)
endIf
if ! Empty(cUltOrd)
  AADD(aCodes, cUltOrd)
endif
cCodes := oArHelp:Join( aCodes, ',' )
//
conout("Ultimo ORDER E XFER:" + cUltOrd + " - " + cUltXfer)
conout("Codigos DPE importados:" + cCodes)
oLogger:Log({"TIMESTAMP", "Codigos DPE importados:" + cCodes})
//
aAdd(aValoresH, Alltrim(cCodes))
//
cFileTemp := "/logsmil/partsdata/" + cArquivo // arquivo em local temporario
makeDir( "/logsmil" )
makeDir( "/logsmil/partsdata" )
If FILE(cFileTemp)
  nHnd := FOPEN( cFileTemp, 1 ) // 1 = write FO_WRITE
Else
  nHnd := FCREATE( cFileTemp )
EndIf
//

cDirSave := Alltrim(MV_PAR01)
cFileDest := Alltrim(cFileDest)
cPath := Alltrim(cPath)

If Empty(cPath)
  cFileDest := Iif(!Empty(Right(cDirSave, 1)) .AND. Right(cDirSave, 1) <> "/" .AND. Right(cDirSave, 1) <> "\", cDirSave, Left(cDirSave, Len(cDirSave) - 1))+"\"
Else
  cFileDest := Iif(!Empty(Right(cPath, 1))    .AND. Right(cPath, 1) <> "/"    .AND. Right(cPath, 1) <> "\",    cPath,    Left(cPath, Len(cPath) - 1)) + "/parts_data/"
Endif

cSavePath := cFileDest
cFileDest += Alltrim(cArquivo)

cFileDest := StrTran(cFileDest, "\", "/") 

If lAuto .and. !(Left(cFileDest,1) $ "/\") // "
  conout(" ")
  conout("OFINJD06 ==========================================================================================")
  conout("OFINJD06 ==========================================================================================")
  conout("OFINJD06  ATENCAO: nao é possivel gerar o arquivo do PARTS DATA (DPM) em um diretorio local quando ")
  conout("OFINJD06           executado atraves do SCHEDULE                                                   ")
  conout("OFINJD06 ==========================================================================================")
  conout("OFINJD06 ==========================================================================================")
  conout(" ")
EndIf

cLinha := MontaEDI(aValoresH)
fwrite(nHnd, EncodeUtf8(cLinha))
cData1 := STRZERO(Year(ddatabase),4)+STRZERO(Month(ddatabase),2) + "01"
cData2 := dtos(ddatabase)

// Devoluções
For nIdx1 := 1 to Len(aFilis)
  cFil   := aFilis[nIdx1, 1]
  aDevs  := oDpm:GetDevData(cFil, dDatabase)

  for nIdx := 1 to Len(aDevs)
	oObj := aDevs[nIdx]
	cIdx := alltrim(cFil) + alltrim(oObj:GetValue('D2_EMISSAO')) + alltrim(oObj:GetValue('D2_COD'))
	If ! Empty(oDevObj[cIdx])
		oDevObj[cIdx][1] += oObj:GetValue('QTD_ITENS')
		oDevObj[cIdx][2] += oObj:GetValue('QTD_HITS')
	else
		oDevObj[cIdx] := {oObj:GetValue('QTD_ITENS'), oObj:GetValue('QTD_HITS')}
	EndIf

	cIdx := ALLTRIM(cFil) + alltrim(LEFT(oObj:GetValue('D2_EMISSAO'),6)) + alltrim(oObj:GetValue('D2_COD'))
	If ! Empty(oDevObj[cIdx])
		oDevObj[cIdx][1] += oObj:GetValue('QTD_ITENS')
		oDevObj[cIdx][2] += oObj:GetValue('QTD_HITS')
	else
		oDevObj[cIdx] := {oObj:GetValue('QTD_ITENS'), oObj:GetValue('QTD_HITS')}
	EndIf
  next	
Next

SB2->(DBSetOrder(1))

cFilAnt := cFilBkp
lFoinOri := .f.

VOI->(DBGoTop())
aLocs := {}
while !(VOI->(eof()))
  nPos := aScan(aLocs,{|x| x == VOI->VOI_CODALM})
  if nPos == 0 .and. !Empty(VOI->VOI_CODALM)
    aAdd(aLocs,VOI->VOI_CODALM)
  endif
  VOI->(DBSkip())
enddo
cFilCurr := ""

nMes := Month(ddatabase)
nAno := Year(ddatabase)
for nCntFor2 := 1 to 36
  nMes--
  if nMes == 0
    nAno--
    nMes := 12
  endif
  aAdd(aMod36Dem,{0,0,0,0, nMes, nAno})
next

aSort(aFilis,,, {|x,y| x[2] < y[2]})
aTransf := {}
for nIdxFil := 1 to LEN(aFilis)
  aFil := aFilis[nIdxFil]
  cFilAnt := aFil[1]
  if Empty(aFil[1])
    loop
  endIf
  //
  // Transferências
  //
  conout("OFINJD06 - Verificando Transferências"+ " ("+time()+")")

  if SFJ->(FieldPos("FJ_NUMORC")) <> 0
    cAl := GetNextAlias()

    oFil := DMS_FilialHelper():New()
    dbSelectArea("SA2")
    dbGoTo( oFil:GetFornecedor( xFilial('VS1') ) )

    cQuery := ""
    cQuery += "    SELECT 'ORIGEM' VS1_FILORI, VS1_FILDES, B1_COD, VS3_QTDITE QTDTOT "
    cQuery += "      FROM " + oSqlHlp:NoLock('VS1')
    cQuery += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS1_FILIAL = VS3_FILIAL           AND VS1_NUMORC = VS3_NUMORC AND VS1_STATUS <> 'C'        AND VS1_TIPORC     = '3' AND VS1.D_E_L_E_T_ = ' ' "
    cQuery += "      JOIN " + oSqlHlp:NoLock('SF1') + " ON F1_FILIAL  = VS1_FILDES           AND F1_DOC     = VS1_NUMNFI AND F1_SERIE    = VS1_SERNFI AND SF1.D_E_L_E_T_ = ' ' "
    cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO    = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += "      JOIN " + oDpePecas:TableName()  + " ON  FILIAL    = '"+xFilial('VS3')+"' AND PRODUTO    = B1_COD     AND DATAGER = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
    cQuery += "     WHERE VS3_FILIAL     = '"+xFilial('VS3')+"' "
    cQuery += "       AND VS1_NUMNFI    <> ' ' "
    cQuery += "       AND VS3.D_E_L_E_T_ = ' ' "
    cQuery += "       AND F1_STATUS      = ' ' "
    cQuery += "       AND F1_FORNECE = '"+SA2->A2_COD+"' AND F1_LOJA = '"+SA2->A2_LOJA+"' "

    if VS3->(FieldPos("VS3_TRSFER")) > 0
      cQuery += " UNION ALL "
      cQuery += "    SELECT VS1_FILIAL VS1_FILORI, VS1_FILDES, B1_COD, VS3_QTDITE QTDTOT "
      cQuery += "      FROM " + oSqlHlp:NoLock('VS1')
      cQuery += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS1_FILIAL = VS3_FILIAL           AND VS1_NUMORC = VS3_NUMORC AND VS1_TIPORC  = '3'        AND VS1.D_E_L_E_T_ = ' ' "
      cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO    = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
      cQuery += "      JOIN " + oDpePecas:TableName() + " ON  FILIAL    = '"+xFilial('VS3')+"' AND PRODUTO    = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
      cQuery += "     WHERE VS3_FILIAL     = '"+xFilial('VS3')+"' "
      cQuery += "       AND VS3_DOCSDB    <> ' ' "
      cQuery += "       AND VS1_STATUS    <> 'C' "
      cQuery += "       AND VS1_NUMNFI     = ' ' "
      cQuery += "       AND VS3.VS3_TRSFER = '1' " //Somente orçamentos de transferencia originados de XFER DPM JD
      cQuery += "       AND VS3.D_E_L_E_T_ = ' ' "
    EndIf

    cQuery := " SELECT VS1_FILORI, VS1_FILDES, B1_COD, SUM(QTDTOT) QTDTOT FROM ("+cQuery+") X GROUP BY VS1_FILORI, VS1_FILDES, B1_COD "
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
    while !( (cAl)->(eof()) )
      nIdxTransf := aScan(aTransf,{|x| x[1] $ (cAl)->(VS1_FILDES) .AND. x[2] $ (cAl)->(B1_COD) })
      if nIdxTransf > 0
          aTransf[nIdxTransf, 3] += (cAl)->(QTDTOT)
      Else
        aAdd(aTransf,{ (cAl)->(VS1_FILDES), (cAl)->(B1_COD), (cAl)->(QTDTOT), 0               }) // aguardando na destino
      EndIf

      (cAl)->(DBSkip())
    enddo
    (cAl)->(dbCloseArea())
  endif
Next

oLogger:Log({'TIMESTAMP', "|> Tamanho array transfs: " + ALLTRIM(STR(LEN(aTransf))) })

cQryAl002 := GetNextAlias()

for nIdxFil := 1 to LEN(aFilis)
  nIdxHR := 0
  aFil := aFilis[nIdxFil]
  cFilAnt := aFil[1]
  if Empty(aFil[1])
    loop
  endIf

  cQuery36 := "  SELECT VB8_MES, VB8_ANO, COALESCE(SUM(VB8_VDAB),0) VB8_VDAB, COALESCE(SUM(VB8_VDAO),0) VB8_VDAO, COALESCE(SUM(VB8_HITSB),0) VB8_HITSB, COALESCE(SUM(VB8_HITSO),0) VB8_HITSO, COALESCE(SUM(VB8_VDPERB),0) VB8_VDPERB, COALESCE(SUM(VB8_VDPERO),0) VB8_VDPERO, COALESCE(SUM(VB8_HIPERB),0) VB8_HIPERB, COALESCE(SUM(VB8_HIPERO),0) VB8_HIPERO "
  cQuery36 += "    FROM " +oSqlHlp:NoLock("VB8")
  cQuery36 += "   WHERE "+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'})+" BETWEEN '" + DTOS(dData36At) + "' AND '" + DTOS(dDatabase) + "' "
  cQuery36 += "     AND VB8.D_E_L_E_T_ = ' ' "

  /*
     Gravando cabeçalho de armazem
  */
  aValores0 := {}
  aAdd(aValores0, "~H~")
  aAdd(aValores0, Alltrim(aFil[2]))
  aAdd(aValores0, Alltrim(aFil[3]))
  aAdd(aValores0, STRZERO(MONTH(DDATABASE),2))
  aAdd(aValores0, SPACE(10))
  aAdd(aValores0, "1")
  aAdd(aValores0, STRZERO(MV_PAR03,1))
  cLinha := MontaEDI(aValores0)
fwrite(nHnd,EncodeUtf8(NoAcento(cLinha)))
  /*
     Demanda
  */
  FX_DEMDATA({aFil}) // buscando demanda seletivamente para evitar muita memoria

  OJD06HTRes()

  for nCntFor := 1 to Len(aVetCods)
    aDados := aVetCods[nCntFor]
    nQtdResBal  := 0
    nQtdOficina := 0
    nCusMed     := 0
    nEstMin     := 0
    nEstMax     := 0

    SB2->(DBSeek(aDados[18] + aDados[2] + aDados[12]))
    dDateAdded := stod(aDados[17])
    if Alltrim(cDadosProd) = "SBZ"
      SBZ->(DBSeek(aDados[18]+aDados[2]))
      if SBZ->(found())
        nEstMin := SBZ->BZ_EMIN
        nEstMax := SBZ->BZ_EMAX
      endif
    endif
    if SB2->(found())
      nCusMed := SB2->B2_CM1
    endif
    cLocacao := aDados[21]

    aValores1 := {}
    aAdd(aValores1, "~P~")
    aAdd(aValores1, aDados[ 2])
    aAdd(aValores1, aDados[27])
    aAdd(aValores1, aDados[28] + aDados[19]) // 04 - pedidos a chegar+transferencias
    aAdd(aValores1, aDados[26])              // 05 - nQtdOficina
    aAdd(aValores1, aDados[25] + aDados[20]) // 06 - nQtdBal
    aAdd(aValores1, aDados[07])              // 07 - Vendas balcao + vendas oficina
    aAdd(aValores1, aDados[13])              // 08 - hits balcao + hits oficina
    aAdd(aValores1, aDados[14])              // 09 - vendas perdidas
    aAdd(aValores1, aDados[15])              // 10 - hits perdidos
    aAdd(aValores1, aDados[08])              // 11 - ...
    aAdd(aValores1, cLocacao)                // 12
    aAdd(aValores1, "")                      // 13
    aAdd(aValores1, IIF(aDados[16]=="1",0, IIF(SB2->B2_QATU <= 0, 0,SB2->B2_CM1/SB2->B2_QATU) )) //  14
    aAdd(aValores1, IIF(aDados[16]=="1",0, aDados[8] )) //  15
    aAdd(aValores1, IIF(aDados[16]=="1","", aDados[6] )) //  16
    aAdd(aValores1, "" ) //  17
    aAdd(aValores1, "C" ) //  18
    aAdd(aValores1, 0 ) //  19
    aAdd(aValores1, IIF(aDados[11]>0,aDados[11],nCusMed) ) // 20
    aAdd(aValores1, "") // 21
    aAdd(aValores1, "") // 22
    aAdd(aValores1, aDados[24]) // 23 - Reserved Hits Work Orders  - hits reservados oficina
    aAdd(aValores1, aDados[23]) // 24 - Reserved Hits Part Tickets - Hits reservados balcão
    // 1.3
    aAdd(aValores1, nCusMed)
    //
    if cTipoExt == "I"
      aDemanda := aClone(aMod36Dem) // clona

      dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery36 + "     AND VB8_FILIAL = '" + aDados[18] + "' AND VB8_PRODUT = '" + aDados[2] + "' GROUP BY VB8_MES, VB8_ANO ORDER BY VB8_ANO DESC, VB8_MES DESC" ), cQryAl002, .F., .T. )
      while !(cQryAl002)->(eof())
        nPos := aScan(aDemanda,{|x| x[5] == VAL((cQryAl002)->(VB8_MES)) .and. x[6] == VAL((cQryAl002)->(VB8_ANO)) })
        if nPos > 0
          aDemanda[nPos,1] += (cQryAl002)->(VB8_VDAB)   + (cQryAl002)->(VB8_VDAO)
          aDemanda[nPos,2] += (cQryAl002)->(VB8_HITSB)  + (cQryAl002)->(VB8_HITSO)
          aDemanda[nPos,3] += (cQryAl002)->(VB8_VDPERB) + (cQryAl002)->(VB8_VDPERO)
          aDemanda[nPos,4] += (cQryAl002)->(VB8_HIPERB) + (cQryAl002)->(VB8_HIPERO)
        endif
        (cQryAl002)->(DBSkip())
      enddo
      //
      (cQryAl002)->(DBCloseArea())
      //
      // Conta quantidade de meses que teve entrada na peça, se nunca entrou é zero, se entrou a 1 mes é 1 e etc.... não é por demanda como era feito antes.
      // Leonardo da Jd me orientou.
      nQtdMeses := 0
      dDataCnt  := dDataBase
      if dDateAdded > dDataCnt
        nQtdMeses:= 0
      else
        for nCntFor2 := 1 to 37
          if YEAR(dDataCnt) == YEAR(dDateAdded) .AND. MONTH(dDataCnt) == MONTH(dDateAdded)
            nQtdMeses := nCntFor2
            exit
          Else
            dDataCnt := oUtil:RemoveMeses(dDataCnt, 1)
          EndIf
        next
        if nQtdMeses >= 1 .AND. nQtdMeses <= 37
          nQtdMeses := nQtdMeses - 1
        else
          nQtdMeses := 36
        EndIf
      endif
      //
      aAdd(aValores1, "%%%")
      aAdd(aValores1, "")
      aAdd(aValores1, "")
      aAdd(aValores1, "")
      aAdd(aValores1, Left(dtos(dDateAdded),4)+"-"+SUBS(dtos(dDateAdded),5,2)+"-"+Right(dtos(dDateAdded),2) )
      aAdd(aValores1, aDados[4] ) // B1_GRUPO
      aAdd(aValores1, nEstMin)
      aAdd(aValores1, nEstMax)
      aAdd(aValores1, nQtdMeses)
      aAdd(aValores1, 0)
      for nCntFor2 := 1 to 36
        If nCntFor2 > nQtdMeses
        Else
          aDadosMes := aDemanda[nCntFor2]
          If aDadosMes[1] > 0 // performance, não busca devolução se não teve venda, pois como abate no mes da venda, se vendeu 0 não tem como existir devolução valida
            cAno := ALLTRIM( STR(aDadosMes[6]) )
            cMes := ALLTRIM( STR(aDadosMes[5]) )
            aDevData := FX_DevData(aDados[18], aDados[2], STOD(cAno + STRZERO(VAL(cMes),2) + "01"), .F.)
            aDadosMes[1] -= aDevData[1]
            aDadosMes[2] -= aDevData[2]
          EndIf

          aAdd(aValores1, JD06Int4Arq(aDadosMes[1])) // vendas
          aAdd(aValores1, JD06Int4Arq(aDadosMes[2])) // hits
          aAdd(aValores1, JD06Int4Arq(aDadosMes[3])) // vendas perdidas
          aAdd(aValores1, JD06Int4Arq(aDadosMes[4])) // hits perdidos
        Endif
      next
      aAdd(aValores1, "CLOSE" )
    endif
    //
    IIF( MOD(nCntFor, 1000) == 0, oLogger:Log({'TIMESTAMP', " |> Fim escrita 36 meses, escrevendo no arquivo"}),  )
    cLinha := MontaEDI(aValores1)
    fwrite(nHnd,EncodeUtf8(NoAcento(cLinha)))
  next
  //
Next
//
oLogger:Log({'TIMESTAMP', "Montando Arquivo"})
oLogger:Log({'TIMESTAMP', "Tamanho do vetor" + STR(LEN(aVetCods)) })
//
FClose(nHnd)

// A pedido do leonardo da jd, o nome do arquivo deve ficar com a data da finalizacao da geracao
dDataBase := DATE() // atualiza database para geração do nome correto
cNomeAtualizado := "DLR2JD_DPMEXT_" + ;
  cTipoExt + "_" + ;
  STRZERO(VAL( IIF( !EMPTY(cAccount), cAccount, MV_PAR08) ),6) + "_" +;
  dtos(ddatabase) + "_" + ;
  SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + IIF( (oDpe:isPrism() .OR. lEmuPrism) .OR. cTipoExt == 'D', ".DPM", ".DPMBRA") // is_Prism() == GetNewPar("MV_MIL0067","N") == "S"

Copy File &(cFileTemp) to &(cFileDest)
iif (IsSrvUnix(),CHMOD( cFileDest , 666,,.f. ),CHMOD( cFileDest , 2,,.f. ))
iif (IsSrvUnix(),CHMOD( cFileTemp , 666,,.f. ),CHMOD( cFileTemp , 2,,.f. ))
FRenameEx(cFileDest , lower(cSavePath)+UPPER(cNomeAtualizado))
Dele File &(cFileTemp)

conout("Arquivo gerado em: " + cFileDest)
conout("Arquivo renomeado em: " + UPPER(cSavePath+cNomeAtualizado))

TCSQLEXEC(" UPDATE " + RetSqlName('VQL') + " SET VQL_DATAF = '"+DTOS(dDataBase)+"' WHERE VQL_AGROUP IN ('DPMXFER_DPE', 'DPMORD_DPE') AND VQL_TIPO = 'CODIGO_DPE' AND VQL_DATAF = ' '  ")
TCSQLEXEC(" UPDATE " + RetSqlName('VB8') + " set VB8_FLGENV = '*' where VB8_FLGENV = ' ' ") // joga todos os registros como enviados a JD para geração de delta

if ! lAuto
  MsgInfo(STR0007 /*"A operação foi realizada com sucesso"*/ + " " + FWTimeStamp(3),STR0008 /*"Atenção"*/)
endif

conout("OFINJD06 -> Sucesso" + " ("+time()+")")
oLogger:Log({'TIMESTAMP', "OFINJD06 -> Sucesso" + " ("+time()+")"})

return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | MontaEDI   | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |                                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MontaEDI(aDadlinha)
  Local nCntFor := 1
  Local nTam    := LEN(aDadlinha)
  Local cLinha  := ""
  Local uVal    := Nil

  For nCntFor := 1 to LEN(aDadlinha)
    uVal   := aDadlinha[nCntFor]
    cValor := IIF(VALTYPE(uVal) == "C", ALLTRIM(uVal), ALLTRIM(STR(uVal)))
    cValor := STRTRAN(cValor , CHR(09), "")

    if cValor == "CLOSE"
      exit
    else
      cLinha += cValor + IIF(nCntFor == nTam, "", CHR(09))
    endif
  Next
return cLinha + CHR(13) + CHR(10)

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
Local lSX1    := .F.
Local nOpcGetFil := GETF_NETWORKDRIVE + GETF_RETDIRECTORY


aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL" ,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"  ,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"  ,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aAdd a Pergunta                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAdd(aSX1,{cPerg,"01",STR0009,"","","MV_CH1","C",99,0,0,"G","Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+")","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"S"})
aAdd(aSX1,{cPerg,"02",STR0010,"","","MV_CH2","N", 1,0,0,"C","", "mv_par02",STR0011,"","","","",STR0012,"","","","","","","","","","","","","","","","","","","","",""})
aAdd(aSX1,{cPerg,"03",STR0013,"","","MV_CH3","N", 1,0,0,"C","", "mv_par03",STR0014,"","","","",STR0015,"","","","",STR0016,"","","","","","","","","","","","","","","",""})
aAdd(aSX1,{cPerg,"04",STR0017,"","","MV_CH4","C",99,0,0,"G","", "mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"05",STR0018,"","","MV_CH5","C",30,0,0,"G","", "mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"06",STR0019,"","","MV_CH6","C",30,0,0,"G","", "mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"07",STR0021,"","","MV_CH7","D", 8,0,0,"G","", "mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"08",STR0022,"","","MV_CH8","C", 6,0,0,"G","", "mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"09",STR0023,"","","MV_CH9","N", 1,0,0,"C","", "mv_par09",STR0024,"","","","",STR0025,"","","","","","","","","","","","","","","","","","","","",""})
aAdd(aSX1,{cPerg,"10",STR0017,"","","MV_CHA","C",99,0,0,"G","", "mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"11",STR0017,"","","MV_CHB","C",99,0,0,"G","", "mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"12",STR0017,"","","MV_CHC","C",99,0,0,"G","", "mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"13",STR0017,"","","MV_CHD","C",99,0,0,"G","", "mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"14",STR0017,"","","MV_CHE","C",99,0,0,"G","", "mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})

ProcRegua(Len(aSX1))

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
      IncProc()
    EndIf
  EndIf
Next i

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FX_DevData | Autor |  Vinicius Gati        | Data | 30/10/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##| Retorna quantidade de hits e qtd devolvida (tudo a subtrair)            |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FX_DevData(cFil, cCODB1, dData, lConsDia)
  Local nIdx       := 0
  Local cBckFil    := cFilAnt
  Local oRet       := nil
  local cSearch    := ""
  Default lConsDia := .T.

  if lConsDia
    cSearch := alltrim(cFil) + alltrim(DTOS(dData)         ) + alltrim(cCODB1)
  else
    cSearch := alltrim(cFil) + alltrim(LEFT(DTOS(dData), 6)) + alltrim(cCODB1)
  endif

  if ! Empty(oDevObj[cSearch])
	aValues := oDevObj[cSearch]
	if ! Empty(aValues)
		return aValues
	endif
  endif
Return {0,0}

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FX_DEMDATA | Autor |  Vinicius Gati        | Data | 30/10/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##| Busca a demanda das filiais tambem com produtos sem demanda com estoque |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FX_DEMDATA(aFilis)
  Local nIdx     := 0
  Local aDadPeca := Nil
  Local cQuery   := ""
  Local cFields  := ""
  Local cFilD    := ""
  Local cDtAdded := ''
  Local cCposGrp := ""
  Local cGroupC  := ""
  Local cCodFab  := ""
  Private cAl    := GetNextAlias()
  if cDadosProd == "SBZ"
    cCposGrp += "BZ_PRIENT, BZ_LOCALI2 "
  else
    cCposGrp += "B5_DTADDED, B5_LOCALI2 "
  endif

  aVetCods := {}
  for nIdx := 1 to LEN(aFilis)
    cFilAnt := aFilis[nIdx][1]
    cDadosProd := GetNewPar("MV_MIL0054","SBZ")
    cQuery := ""


    oLogger:Log({"=================="})
    oLogger:Log({"==Query do delta=="})
    oLogger:Log({"=================="})
    oLogger:Log({"Tipo extração: '" + cTipoExt + "' "})
    oLogger:Log({"Emulado: '" + IIF(lEmuPrism, "SIM", "NÃO") + "' "})
    oLogger:Log({"=================="})

    // usado em debug
    if "OFINJD06" $ GetNewPar("MV_XMILDBG", "NAO")
      cQuery += " SELECT top 10000 "
    else
      cQuery += " SELECT "
    end

	// tratamento para adequar NNR com B2 pois vou ter que fazer 
	// uma query para somar todos os saldos de N filiais
	cFilNNR  := oSqlHlp:CompatFunc('SUBSTR') + "(B2_FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('NNR')))))+")"
	// sao ajustes para comparacao de filiais de forma dinamica pois nessa query abaixo eu trago mais de 1 filial
	// por conta da configuracao de filial armazem do DPM
	// o campo FILIAL é da tabela de cache de pecas e é exclusiva, por isso é usada de base de comparacao
	// cFilSBM  := oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('SBM')))))+")"
	// cFilSBZ  := oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('SBZ')))))+")"
	// cFilSB5  := oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('SB5')))))+")"
	cFilVB8  := oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('VB8')))))+")"
	cFilSB1  := oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('SB1')))))+")"

	// Isto é para usar na query da peça para trazer o
	// saldo da filial atual mais as filiais armazens
	aFilArms := oDpm:GetFilArms(cFilAnt)
	aFilArms := oArHelp:Map(aFilArms, {|aArm| aArm[1]})
	aadd(aFilArms, cFilAnt)

    if cDadosProd == "SBZ"
	  	cFields += " coalesce((select MIN(BZ_PRIENT) from "+RetSqlName('SBZ')+" BZ where BZ.BZ_FILIAL IN ('"+ oArHelp:Join( aFilArms, "','" ) +"') AND BZ.BZ_COD = B1_COD AND BZ.BZ_PRIENT != ' ' AND BZ.D_E_L_E_T_ = ' '), '19000101') AS DTADDED, "
    else
		cFields += " coalesce((select MIN(B5_DTADDED) from "+RetSqlName('SB5')+" B5 where B5.B5_FILIAL IN ('"+ oArHelp:Join( aFilArms, "','" ) +"') AND B5.B5_COD = B1_COD AND B5.B5_DTADDED != ' ' AND B5.D_E_L_E_T_ = ' '), '19000101') AS DTADDED, "
    endif

    cSubSelSaldo := " (    SELECT COALESCE( SUM(B2_QATU), 0) FROM " + oSqlHlp:NoLock('SB2')
    if lUsaNNR
      cSubSelSaldo += "        JOIN " + oSqlHlp:NoLock('NNR') + " ON NNR_FILIAL = "+cFilNNR+" AND NNR_CODIGO = B2_LOCAL AND NNR.NNR_VDADMS = '1' AND NNR.D_E_L_E_T_ = ' ' "
      cSubSelSaldo += "       WHERE B2_FILIAL IN ('"+ oArHelp:Join( aFilArms, "','" ) +"') AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ = ' ' ) QTD_EST "
    else
      cSubSelSaldo += "       WHERE B2_FILIAL IN ('"+ oArHelp:Join( aFilArms, "','" ) +"') AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' ) QTD_EST "
    end

    cSubEstEnc   := " (    SELECT COALESCE( SUM(C7_QUANT-C7_QUJE), 0) FROM " + oSqlHlp:NoLock('SC7')
    cSubEstEnc   += "       WHERE C7_FILIAL = '"+xFilial('SC7')+"' AND C7_PRODUTO = B1_COD AND D_E_L_E_T_ = ' ' AND C7_ENCER = ' ' AND C7_RESIDUO = ' ' "
    cSubEstEnc   += "         AND C7_QUANT > C7_QUJE "
    // Aqui jogo qualquer coisa na comparação só para ser diferentede '' e entrar todos os c7 de direct shipment
    cSubEstEnc   += "         AND (CASE WHEN B5_ISDSHIP = '1' THEN 'DSHIP' ELSE C7_PEDFAB END) <> ' '   "
    cSubEstEnc   += " ) QTD_ESTENC "

    cQuery += "COALESCE(VB8_FILIAL,  '"+xFilial("VS1")+"') as VB8_FILIAL, "+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES'})+" as DATA, "
    cQuery += cFields
	cQuery += " B1_COD, "
	cQuery += " B1_QE, "
	cQuery += " B1_CODFAB, "
	cQuery += " B1_CODITE, "
	cQuery += " B1_GRUPO, "
	cQuery += " B1_GROUPC, "
	cQuery += " B1_PRV1, "
	cQuery += " B1_LOCPAD, "
	cQuery += " MAX(LOCACAO) LOCACAO, "
	cQuery += " MAX(BM_PROORI) BM_PROORI, "
	cQuery += " B5_ISDSHIP, "
    cQuery += " COALESCE( SUM(VB8_VDAB  ), 0) VB8_VDAB, "
    cQuery += " COALESCE( SUM(VB8_VDAO  ), 0) VB8_VDAO, "
    cQuery += " COALESCE( SUM(VB8_HITSB ), 0) VB8_HITSB, "
    cQuery += " COALESCE( SUM(VB8_HITSO ), 0) VB8_HITSO, "
    cQuery += " COALESCE( SUM(VB8_VDPERB), 0) VB8_VDPERB, "
    cQuery += " COALESCE( SUM(VB8_VDPERO), 0) VB8_VDPERO, "
    cQuery += " COALESCE( SUM(VB8_HIPERB), 0) VB8_HIPERB, "
    cQuery += " COALESCE( SUM(VB8_HIPERO), 0) VB8_HIPERO, "

    cQuery += cSubSelSaldo + ", "
    cQuery += cSubEstEnc

    cQuery += "       FROM "+oSqlHlp:NoLock('SB1')
    cQuery += "       JOIN "+oDpePecas:TableName()+" ON  rtrim(FILIAL)   in ('"+ oArHelp:Join( aFilArms, "','" ) +"') AND PRODUTO    = B1_COD   AND DATAGER = '"+DTOS(dDatabase)+"' "
    cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON BM_FILIAL  = '"+xFilial('SBM')+"' AND B1_GRUPO   = BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
    cQuery += "       JOIN "+oSqlHlp:NoLock('SB5')+" ON B5_FILIAL  = '"+xFilial('SB5')+"' AND B5_COD     = B1_COD   AND SB5.D_E_L_E_T_ = ' ' "
    cQuery += "  LEFT JOIN "+oSqlHlp:NoLock('VB8')+" ON VB8_FILIAL = '"+xFilial('VB8')+"' AND VB8_PRODUT = B1_COD   AND VB8_ANO = '"+ALLTRIM(STR(YEAR(dDatabase)))+"' AND VB8_MES = '"+ALLTRIM(STRZERO(MONTH(dDatabase), 2))+"' AND VB8.D_E_L_E_T_ = ' ' "
    cQuery += "      WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery += "        AND rtrim(SB1.B1_FILIAL)  = "+cFilSB1

    if (oDpe:isPrism() .OR. lEmuPrism) .AND. cTipoExt == "D"
      cQuery += " AND VB8_PRODUT IN (SELECT DISTINCT VB8_PRODUT from "+oSqlHlp:NoLock('VB8', 'VB8DELTA')+" where rtrim(VB8DELTA.VB8_FILIAL) = "+cFilVB8+" AND VB8DELTA.VB8_FLGENV = ' ' AND VB8DELTA.D_E_L_E_T_ = ' ' ) "
    EndIf

    cQuery += " GROUP BY COALESCE(VB8_FILIAL,  '"+xFilial("VS1")+"'), "+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES'})+", B1_COD, B1_QE, B5_ISDSHIP, B1_CODFAB, B1_CODITE, B1_GRUPO, B1_GROUPC, B1_PRV1, B1_LOCPAD
    cQuery += " ORDER BY B1_COD "
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
    oLogger:Log({'TIMESTAMP', cQuery})
    (cAl)->(DbGoTop())
    while !( (cAl)->(eof()) )

      // alguns registros virão sem VB8_FILIAL isso é normal se a peças não teve mov. no mes
      cFilD    := IIF(EMPTY((cAl)->(VB8_FILIAL)), xFilial('VB8')     , (cAl)->(VB8_FILIAL))
      cDtAdded := IIF(EMPTY((cAl)->(DTADDED))   , '19000101'         , (cAl)->(DTADDED))
      cGroupC  := IIF(EMPTY((cAl)->(B1_GROUPC)) , (cAl)->(B1_GRUPO)  , (cAl)->(B1_GROUPC))
      cCodFab  := IIF(Empty((cAl)->(B1_CODFAB)) , (cAl)->(B1_CODITE) , (cAl)->(B1_CODFAB))

      aDadPeca := {;
        .f.,;                                    // 1
        (cAl)->(B1_COD),;                        // 2
        (cAl)->(B1_CODITE),;                     // 3
        cGroupC,;                                // 4
        "",;                                     // 5
        cCodFab,;                                // 6
        0,;                                      // 7 vendas
        IIF( (cAl)->(B1_QE) <= 0, 1, 1),;        // 8 /*esta informação não existe no protheus, jd pediu remoção*/
        0,;                                      // 9
        0,;                                      // 10
        (cAl)->(B1_PRV1),;                       // 11
        (cAl)->(B1_LOCPAD),;                     // 12
        0,;                                      // 13
        0,;                                      // 14
        0,;                                      // 15
        (cAl)->(BM_PROORI),;                     // 16
        cDtAdded,;                               // 17
        cFilD,;                                  // 18
        0,0,;                                    // 19,20
        (cAl)->(LOCACAO),;                       // 21
        (cAl)->(B1_GRUPO),;                      // 22
        0,0,;                                    // hits reservados oficina e balcao //23 e 24
        0,0,;                                    // quantidade reservados oficina e balcao //25 e 26
        (cAl)->(QTD_EST), (cAl)->(QTD_ESTENC) ;  // 27 e 28 saldo e estoque encomendado pedidos
      }

      If (cAl)->(DATA) $ LEFT(DTOS(dDatabase), 6)
        aDadPeca[ 7] += (cAl)->(VB8_VDAB)   + (cAl)->(VB8_VDAO)
        aDadPeca[13] += (cAl)->(VB8_HITSB)  + (cAl)->(VB8_HITSO)
        aDadPeca[14] += (cAl)->(VB8_VDPERB) + (cAl)->(VB8_VDPERO)
        aDadPeca[15] += (cAl)->(VB8_HIPERB) + (cAl)->(VB8_HIPERO)
        if ((cAl)->(VB8_VDAB) + (cAl)->(VB8_VDAO)) > 0 .AND. cTipoExt == "I" // devolucao
          aDevData := FX_DevData((cAl)->(VB8_FILIAL), (cAl)->(B1_COD), dDatabase, .F.)
          aDadPeca[ 7] -= aDevData[1]
          aDadPeca[13] -= aDevData[2]
        EndIf
      EndIf
      // transferencias agora direto aqui, pra nao precisar dar seek no aVetCods que é gigante
      If LEN(aTransf) > 0
        nIdxTransf := aScan(aTransf,{|x| x[1] $ cFilD .AND. (cAl)->(B1_COD) $ x[2]  })
        If nIdxTransf > 0
          aDadPeca[19] += aTransf[nIdxTransf,3]
          aDadPeca[20] += aTransf[nIdxTransf,4] // seria o reservado na origem... mas foi removido pois XFER não sera mais considerado via Leonardo JD e Jeff JD
        EndIf
      EndIf

      aAdd(aVetCods, aDadPeca)
      (cAl)->(DBSkip())
    EndDo
    (cAl)->(dbCloseArea())
    oLogger:Log({'TIMESTAMP', "Número de linhas escritas no Parts:" + ALLTRIM(STR(LEN(aVetCods))) })
  Next
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OJD06HTRes | Autor |  Vinicius Gati        | Data | 30/10/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##| Quantidade e hits reservados pecas provenientes de orçamentos           |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function OJD06HTRes()
  Local oSqlHlp  := DMS_SqlHelper():New()
  Local oArHlp   := DMS_ArrayHelper():New()
  Local cSQL     := ""
  Local cAl      := "UEHEHE"
  Local nIdx     := 1

  if FM_SQL(" SELECT COUNT(*) FROM " + RetSqlName('VS1') + " WHERE VS1_FILIAL = '"+xFilial('VS1')+"' AND D_E_L_E_T_ = ' ' ") > 0

    // todos os status menos em branco e C para filtrar
    cVldsts := JD06ResFases("' ', 'C'") // not in parametro
    // todos os status menos X para o filtro do loja
    cVldLj  := JD06ResFases("'X'") // not in parametro

    cSQL := "SELECT B1_COD, COUNT(CASE VE6_NUMOSV WHEN 'BAL' THEN HITS ELSE null END) HITS_BAL,   SUM(CASE VE6_NUMOSV WHEN 'BAL' THEN SOMA ELSE 0 END) SOMA_BAL,"
    cSQL += "               COUNT(CASE VE6_NUMOSV WHEN 'OFI' THEN HITS ELSE null END) HITS_OFI,   SUM(CASE VE6_NUMOSV WHEN 'OFI' THEN SOMA ELSE 0 END) SOMA_OFI"
    cSQL += "  FROM  "
    cSQL += "  ( "
    cSQL += "    SELECT VE6_NUMOSV, VS1_STATUS, B1_COD, COUNT(*) HITS, SUM(CONTA) SOMA  "
    cSQL += "    FROM ( "

    // Orçamento balcão
    cSQL += "           SELECT VS1_STATUS, B1_COD, 'BAL' VE6_NUMOSV, (VE6_QTDITE) CONTA "
    cSQL += "             FROM "+oSqlHlp:NoLock('VE6')
    cSQL += "             JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND B1_GRUPO = VE6_GRUITE AND B1_CODITE = VE6_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
    cSQL += "             JOIN "+ oDpePecas:TableName()+" ON FILIAL        = '"+xFilial('VS3')+"' AND PRODUTO  = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
    cSQL += "             JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VE6_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
    cSQL += "            WHERE VE6.VE6_FILIAL='"+xFilial('VE6')+"' AND VE6.VE6_ORIREQ = '1' AND  VE6.VE6_INDREG = '3' AND VE6.D_E_L_E_T_ = ' ' "
    cSQL += "              AND VS1_TIPORC = '1' AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja
    // Orçamento oficina 
    cSQL += "       UNION ALL  "
    cSQL += "           SELECT VS1_STATUS, B1_COD, 'OFI' VE6_NUMOSV, (VE6_QTDITE - VE6_QTDATE - VE6_QTDEST) CONTA " // quando oficina é necessário usar a conta
    cSQL += "             FROM "+oSqlHlp:NoLock('VE6')
    cSQL += "             JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND B1_GRUPO = VE6_GRUITE AND B1_CODITE = VE6_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
    cSQL += "             JOIN "+ oDpePecas:TableName()+" ON FILIAL        = '"+xFilial('VS3')+"' AND PRODUTO  = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
    cSQL += "             JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VE6_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
    cSQL += "            WHERE VE6.VE6_FILIAL='"+xFilial('VE6')+"' AND VE6.VE6_ORIREQ = '1' AND  VE6.VE6_INDREG = '3' AND VE6.D_E_L_E_T_ = ' ' "
    cSQL += "              AND VS1_TIPORC = '2' AND VE6_NUMOSV = ' ' " // requisicao nao entra aqui vai ser query separada, esta abaixo "
    cSQL += "              AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja
    // Pedido
    cSQL += "       UNION ALL  "
    cSQL += "         SELECT VS1_STATUS, B1_COD, 'BAL' VE6_NUMOSV, (VE6_QTDITE) CONTA "
    cSQL += "           FROM "+oSqlHlp:NoLock('VE6')
    cSQL += "           JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO = VE6_GRUITE AND B1_CODITE = VE6_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
    cSQL += "           JOIN "+ oDpePecas:TableName()+" ON FILIAL        = '"+xFilial('VS3')+"' AND PRODUTO  = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
    cSQL += "           JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VE6_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
    cSQL += "          WHERE VE6.VE6_FILIAL='"+xFilial('VE6')+"' AND  VE6.VE6_INDREG = '3' AND VE6.D_E_L_E_T_ = ' ' AND VS1.VS1_PEDSTA IN ('0', '1') "
    cSQL += "            AND VS1_TIPORC = 'P' AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja
    // Reserva de OS sem orçamento (não requisição)
    cSQL += "       UNION ALL  "
    cSQL += "         SELECT '0' VS1_STATUS, B1_COD, 'OFI' VE6_NUMOSV, (VE6_QTDITE - VE6_QTDATE - VE6_QTDEST) CONTA " // quando oficina é necessário usar a conta
    cSQL += "           FROM "+oSqlHlp:NoLock('VE6')+ ", "+oSqlHlp:NoLock('SB1')
    cSQL += "           JOIN "+ oDpePecas:TableName()+" ON FILIAL        = '"+xFilial('VS3')+"' AND PRODUTO  = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
    cSQL += "          WHERE VE6.VE6_FILIAL='"+xFilial('VE6')+"' AND SB1.B1_FILIAL  = '"+xFilial('SB1')+"' "
    cSQL += "            AND VE6.VE6_INDREG = '3' AND VE6.VE6_ORIREQ = '2' "
    cSQL += "            AND VE6.VE6_GRUITE = B1_GRUPO  AND VE6.VE6_CODITE = B1_CODITE  AND VE6.D_E_L_E_T_ = ' ' "
    cSQL += "            AND VE6.VE6_NUMORC = ' ' AND VE6.VE6_NUMOSV <> ' ' AND SB1.D_E_L_E_T_ = ' ' " // preenchido os
    // Reservas de transferências
    cSQL += "       UNION ALL  "
    cSQL += "         SELECT VS1_STATUS, B1_COD, 'BAL' VE6_NUMOSV, (VE6_QTDITE) CONTA "
    cSQL += "           FROM "+oSqlHlp:NoLock('VE6')
    cSQL += "           JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO = VE6_GRUITE AND B1_CODITE = VE6_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
    cSQL += "           JOIN "+ oDpePecas:TableName()+" ON FILIAL         = '"+xFilial('VS3')+"' AND PRODUTO  = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
    cSQL += "           JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VE6_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
    cSQL += "          WHERE VE6.VE6_FILIAL='"+xFilial('VE6')+"' AND VE6.VE6_ORIREQ = '1' AND  VE6.VE6_INDREG = '3' AND VE6.D_E_L_E_T_ = ' ' AND VS1.VS1_PEDSTA IN ('0', '1') "
    cSQL += "            AND VS1_TIPORC = '3' AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja

    cSQL += "    ) UNIONS_RESORC "
    cSQL += "    WHERE VS1_STATUS IN (" + cVldsts + ") "
    cSQL += "    GROUP BY VE6_NUMOSV, VS1_STATUS, B1_COD "
    // removendo lixos/erros
    cSQL += "      HAVING COUNT(*) <= SUM(CONTA) AND SUM(CONTA) > 0 "
    cSQL += "  ) VE6   "
    cSQL += "  GROUP BY B1_COD  "
    //
    conout("OFINJD06 - Inicio coleta reservas filial: "+cFilAnt+" hora:  ("+time()+")")
    oLogger:Log({'----> Query reservas ', cSQL})
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL),cAl, .F., .T. )
    dbSelectArea(cAl)
    While !(cAl)->(EOF())
      nIdx := aScan(aVetCods, {|x| x[2] == (cAl)->(B1_COD) })
      if nIdx > 0
        aDadHit := aVetCods[ nIdx ]
        aDadHit[23] := (cAl)->(HITS_BAL)
        aDadHit[24] := (cAl)->(HITS_OFI)
        aDadHit[25] := (cAl)->(SOMA_BAL)
        aDadHit[26] := (cAl)->(SOMA_OFI)
      end

      (cAl)->(DbSkip())
    End
    (cAl)->(dbCloseArea())
  end
  conout("  |> FIM coleta reservas hora:  ("+time()+")")
  JD06ReqDt()
Return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | JD06ReqDt  | Autor |  Vinicius Gati        | Data | 30/10/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##| Quantidade e hits reservados pecas provenientes de requisições          |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function JD06ReqDt()
  Local oSqlHlp  := DMS_SqlHelper():New()
  Local oArHlp   := DMS_ArrayHelper():New()
  Local cSQL     := ""
  Local cAli     := "UAHAHA"
  Local aB1Cods  := {}
  Local cQuery
  Local nIdx     := 1
  Local aDadHit

  cQuery := " SELECT B1_COD, COUNT(*) HITS, SUM(SALDO) SOMA "
  cQuery += " FROM ( "
  cQuery += "      SELECT B1_COD, VO2_NUMOSV, SUM(CASE WHEN VO2_DEVOLU = 1 THEN VO3_QTDREQ ELSE VO3_QTDREQ*-1 END) SALDO  "
  cQuery += "        FROM "+oSqlHlp:NoLock('VO3')
  cQuery += "        JOIN "+oSqlHlp:NoLock('SF4')+" ON F4_FILIAL  = '"+xFilial('SF4')+"' AND F4_CODIGO  = VO3_CODTES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' "
  cQuery += "        JOIN "+oSqlHlp:NoLock('VO2')+" ON VO2_FILIAL = '"+xFilial('VO2')+"' AND VO2_NOSNUM = VO3_NOSNUM AND VO2.D_E_L_E_T_ = ' ' "
  cQuery += "        JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VO3_CODITE AND B1_GRUPO = VO3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
  cQuery += "       WHERE VO3.VO3_FILIAL = '"+xFilial('VO3')+"' "
  cQuery += "         AND VO3.D_E_L_E_T_ = ' ' "
  cQuery += "         AND VO3_DATFEC = ' ' "
  cQuery += "         AND VO3_DATCAN = ' ' "
  cQuery += "       GROUP BY B1_COD, VO2_NUMOSV "
  cQuery += "      HAVING SUM(CASE WHEN VO2_DEVOLU = 1 THEN VO3_QTDREQ ELSE VO3_QTDREQ*-1 END) > 0 "
  cQuery += " ) TB "
  cQuery += " GROUP BY B1_COD "
  cQuery += " HAVING SUM(SALDO) > 0 "
  //
  conout("OFINJD06 - Inicio coleta requisicoes filial: "+cFilAnt+" hora:  ("+time()+")")
  dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAli, .F., .T. )
  While !(cAli)->(EOF())
    nIdx := aScan(aVetCods, {|x| x[2] == (cAli)->(B1_COD) })
    if nIdx > 0
      aDadHit     := aVetCods[ nIdx ]
      aDadHit[24] += (cAli)->(HITS)
      aDadHit[26] += (cAli)->(SOMA)
    end

    (cAli)->(DbSkip())
  End
  (cAli)->(dbCloseArea())
  conout("  |> FIM coleta requisicoes hora:  ("+time()+")")
Return .T.

/*
================================================================================
################################################################################
##+----------+--------------+-------+---------------------+------+----------+###
##|Função    | JD06ResFases | Autor |  Vinicius Gati      | Data | 09/02/17 |###
##+----------+--------------+-------+---------------------+------+----------+###
##| Retorna os status do vs1 removendo somente os desnecessarios passados   |###
##|  por parametro, isso serve para pegar status customizados e evitar      |###
##|  chumbar status nas queries usadas neste fonte                          |###
##+----------+------------+-------+-----------------------+------+----------+###
################################################################################
================================================================================
*/
Function JD06ResFases(cNotIn,lRetBranco)
  Local oSqlHlp   := DMS_SqlHelper():New()
  Local oArHlp    := DMS_ArrayHelper():New()
  Local oFases    := DMS_FasesOrcamento():New()
  Local cSQL      := ""
  Local cInStatus := ""
  Default lRetBranco := .f. // Retorna string em branco caso não encontre nenhum STATUS ? .f. retorna 'NAOEXISTE'

  cSQL += " SELECT DISTINCT VS1_STATUS AS VS1_STATUS FROM " + oSqlHlp:NoLock('VS1') + " WHERE VS1_STATUS NOT IN ("+cNotIn+") AND D_E_L_E_T_ = ' ' "

  aResults  := oSqlHlp:GetSelectArray(cSQL)
  aResults  := oArHlp:Map(aResults, { |i| "'" + i + "'" })
  cInStatus := oArHlp:Join(aResults, ',')
  cInStatus := IIf(lRetBranco.or.!Empty(cInStatus),cInStatus,"'NAOEXISTE'") // Necessario retornar NAOEXISTE para não dar erro em SQLs, neste caso não trazer registros caso não existem STATUS diferentes do contido no cNotIn

Return cInStatus

/*/{Protheus.doc} JD06Int4Arq
  Essa função foi criada pois a JD pediu para que não vá valores negativos no parts data
  Não tem como garantirmos isto pois pode acontecer de uma venda ser alterada após processamento
  e o valor faturado ficar diferente do valor devolvido futuramente causando valores negativo.
  
  @type function
  @author Vinicius Gati
  @since 13/09/2017
/*/
Static Function JD06Int4Arq(nVal)
  Default nVal := 0
  if nVal < 0
    nVal := 0
  end
Return nVal
