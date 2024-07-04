#INCLUDE "PROTHEUS.CH"
#DEFINE CRLF chr(13) + chr(10)

static cConc := ""
static cSubStr := ""
static cDBType := ""
static cLog := "LOG de Criação das Views - Fast Analytics PLS - As views serão criadas acrescidas de '_V3' aos nomes listados abaixo "+ CRLF+""+CRLF
static lLogOk := .T.
Static aViews := {}

/*/{Protheus.doc} verIficaBD
VerIfica qual o banco de dados que esta sendo utilizado
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
static function verIficaBD()
   local cDB := TCGetDB()
   local cDBText := "ORACLE DB2 INFORMIX POSTGRES"


   If (cDB $ cDBText)
      cConc := "||"
      cSubStr := 'SUBSTR'
      cDBType := cDB
   Else
      cConc := "+"
      cSubStr := 'SUBSTRING'
      cDBType := "SQL"
   Endif

Return cConc


/*/{Protheus.doc} dropViews
Remove todas as views
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
static function dropViews()
   local aDrop := {}
   local nLinha := 0

   aDrop := {"DROP VIEW HAT_LOAD_B06","DROP VIEW  HAT_LOAD_B06_SINTETICO", "DROP VIEW   HAT_LOAD_B08_SINTETICO", "DROP VIEW   HAT_LOAD_B0N_SINTETICO",;
      "DROP VIEW  HAT_LOAD_B26", "DROP VIEW  HAT_LOAD_B26_SINTETICO", "DROP VIEW   HAT_LOAD_B2J", "DROP VIEW   HAT_LOAD_B2K", "DROP VIEW   HAT_LOAD_BA0",;
      "DROP VIEW  HAT_LOAD_BA1", "DROP VIEW  HAT_LOAD_BA3", "DROP VIEW  HAT_LOAD_BA6", "DROP VIEW HAT_LOAD_BA9", "DROP VIEW HAT_LOAD_BAN",;
      "DROP VIEW  HAT_LOAD_BB2", "DROP VIEW  HAT_LOAD_BB0", "DROP VIEW  HAT_LOAD_BAQ", "DROP VIEW  HAT_LOAD_BAU",  "DROP VIEW  HAT_LOAD_BAW",;
      "DROP VIEW  HAT_LOAD_BAX","DROP VIEW  HAT_LOAD_BB2_SINTETICO", "DROP VIEW  HAT_LOAD_BB6", "DROP VIEW  HAT_LOAD_BB8",;
      "DROP VIEW  HAT_LOAD_BBF", "DROP VIEW  HAT_LOAD_BBI", "DROP VIEW  HAT_LOAD_BBK", "DROP VIEW  HAT_LOAD_BBM",;
      "DROP VIEW  HAT_LOAD_BBM_SINTETICO", "DROP VIEW  HAT_LOAD_BBN", "DROP VIEW   HAT_LOAD_BBN_SINTETICO", "DROP VIEW   HAT_LOAD_BC0",;
      "DROP VIEW  HAT_LOAD_BC1", "DROP VIEW  HAT_LOAD_BCT", "DROP VIEW  HAT_LOAD_BDL", "DROP VIEW  HAT_LOAD_BDT",;
      "DROP VIEW  HAT_LOAD_BE4", "DROP VIEW  HAT_LOAD_BE6", "DROP VIEW  HAT_LOAD_BE9", "DROP VIEW  HAT_LOAD_BEA",;
      "DROP VIEW  HAT_LOAD_BF1", "DROP VIEW  HAT_LOAD_BFC", "DROP VIEW  HAT_LOAD_BFD", "DROP VIEW  HAT_LOAD_BFE",;
      "DROP VIEW  HAT_LOAD_BFG", "DROP VIEW  HAT_LOAD_BFG_SINTETICO",;
      "DROP VIEW  HAT_LOAD_BFJ", "DROP VIEW  HAT_LOAD_BFO", "DROP VIEW HAT_LOAD_BFP", "DROP VIEW HAT_LOAD_BFP_SINTETICO",;
      "DROP VIEW  HAT_LOAD_BG7", "DROP VIEW  HAT_LOAD_BG8", "DROP VIEW HAT_LOAD_BG8_SINTETICO", "DROP VIEW HAT_LOAD_BG9",;
      "DROP VIEW  HAT_LOAD_BI3", "DROP VIEW  HAT_LOAD_BI6", "DROP VIEW HAT_LOAD_BIA", "DROP VIEW HAT_LOAD_BJ4",;
      "DROP VIEW  HAT_LOAD_BJ4_SINTETICO", "DROP VIEW  HAT_LOAD_BJE", "DROP VIEW HAT_LOAD_BLD", "DROP VIEW HAT_LOAD_BLE",;
      "DROP VIEW  HAT_LOAD_BQC", "DROP VIEW  HAT_LOAD_BR4", "DROP VIEW HAT_LOAD_BR8", "DROP VIEW HAT_LOAD_BRV",;
      "DROP VIEW  HAT_LOAD_BT4", "DROP VIEW  HAT_LOAD_BT5", "DROP VIEW HAT_LOAD_BT6", "DROP VIEW HAT_LOAD_BT7",;
      "DROP VIEW  HAT_LOAD_BT8", "DROP VIEW  HAT_LOAD_BTQ", "DROP VIEW HAT_LOAD_BTS", "DROP VIEW HAT_LOAD_BTU",;
      "DROP VIEW  HAT_LOAD_BVI", "DROP VIEW  HAT_LOAD_BW3", "DROP VIEW HAT_LOAD_BW3_SINTETICO", "DROP VIEW HAT_LOAD_CidIncompativel_BAA",;
      "DROP VIEW  HAT_LOAD_CRIT_ATEND_BEG", "DROP VIEW HAT_LOAD_CRIT_ATEND_BEL", "DROP VIEW HAT_LOAD_PROC_ATEND_BE2", "DROP VIEW HAT_LOAD_PROC_ATEND_BEJ",;
      "DROP VIEW  HAT_LOAD_REGRASCOBERTURA", "DROP VIEW HAT_LOAD_SE1", "DROP VIEW HAT_LOAD_VINCULOSODONTO",;
      "DROP VIEW  HAT_STMP_B06","DROP VIEW  HAT_STMP_B06_SINTETICO", "DROP VIEW   HAT_STMP_B08_SINTETICO", "DROP VIEW   HAT_STMP_B0N_SINTETICO",;
      "DROP VIEW  HAT_STMP_B26", "DROP VIEW  HAT_STMP_B26_SINTETICO", "DROP VIEW   HAT_STMP_B2J", "DROP VIEW   HAT_STMP_B2K", "DROP VIEW   HAT_STMP_BA0",;
      "DROP VIEW  HAT_STMP_BA1", "DROP VIEW  HAT_STMP_BA3", "DROP VIEW  HAT_STMP_BA6", "DROP VIEW HAT_STMP_BA9", "DROP VIEW HAT_STMP_BAN",;
      "DROP VIEW  HAT_STMP_BB2", "DROP VIEW  HAT_STMP_BB0", "DROP VIEW  HAT_STMP_BAQ", "DROP VIEW  HAT_STMP_BAU",  "DROP VIEW  HAT_STMP_BAW",;
      "DROP VIEW  HAT_STMP_BAX","DROP VIEW  HAT_STMP_BB2_SINTETICO", "DROP VIEW  HAT_STMP_BB6", "DROP VIEW  HAT_STMP_BB8",;
      "DROP VIEW  HAT_STMP_BBF", "DROP VIEW  HAT_STMP_BBI", "DROP VIEW  HAT_STMP_BBK", "DROP VIEW  HAT_STMP_BBM",;
      "DROP VIEW  HAT_STMP_BBM_SINTETICO", "DROP VIEW  HAT_STMP_BBN", "DROP VIEW   HAT_STMP_BBN_SINTETICO", "DROP VIEW   HAT_STMP_BC0",;
      "DROP VIEW  HAT_STMP_BC1", "DROP VIEW  HAT_STMP_BCT", "DROP VIEW  HAT_STMP_BDL", "DROP VIEW  HAT_STMP_BDT",;
      "DROP VIEW  HAT_STMP_BE4", "DROP VIEW  HAT_STMP_BE6", "DROP VIEW  HAT_STMP_BE9", "DROP VIEW  HAT_STMP_BEA",;
      "DROP VIEW  HAT_STMP_BF1", "DROP VIEW  HAT_STMP_BFC", "DROP VIEW  HAT_STMP_BFD", "DROP VIEW  HAT_STMP_BFE",;
      "DROP VIEW  HAT_STMP_BFG", "DROP VIEW  HAT_STMP_BFG_SINTETICO",;
      "DROP VIEW  HAT_STMP_BFJ", "DROP VIEW  HAT_STMP_BFO", "DROP VIEW HAT_STMP_BFP", "DROP VIEW HAT_STMP_BFP_SINTETICO",;
      "DROP VIEW  HAT_STMP_BG7", "DROP VIEW  HAT_STMP_BG8", "DROP VIEW HAT_STMP_BG8_SINTETICO", "DROP VIEW HAT_STMP_BG9",;
      "DROP VIEW  HAT_STMP_BI3", "DROP VIEW  HAT_STMP_BI6", "DROP VIEW HAT_STMP_BIA", "DROP VIEW HAT_STMP_BJ4",;
      "DROP VIEW  HAT_STMP_BJ4_SINTETICO", "DROP VIEW  HAT_STMP_BJE", "DROP VIEW HAT_STMP_BLD", "DROP VIEW HAT_STMP_BLE",;
      "DROP VIEW  HAT_STMP_BQC", "DROP VIEW  HAT_STMP_BR4", "DROP VIEW HAT_STMP_BR8", "DROP VIEW HAT_STMP_BRV",;
      "DROP VIEW  HAT_STMP_BT4", "DROP VIEW  HAT_STMP_BT5", "DROP VIEW HAT_STMP_BT6", "DROP VIEW HAT_STMP_BT7",;
      "DROP VIEW  HAT_STMP_BT8", "DROP VIEW  HAT_STMP_BTQ", "DROP VIEW HAT_STMP_BTS", "DROP VIEW HAT_STMP_BTU",;
      "DROP VIEW  HAT_STMP_BVI", "DROP VIEW  HAT_STMP_BW3", "DROP VIEW HAT_STMP_BW3_SINTETICO", "DROP VIEW HAT_STMP_CidIncompativel_BAA",;
      "DROP VIEW  HAT_STMP_CRIT_ATEND_BEG", "DROP VIEW HAT_STMP_CRIT_ATEND_BEL", "DROP VIEW HAT_STMP_PROC_ATEND_BE2", "DROP VIEW HAT_STMP_PROC_ATEND_BEJ",;
      "DROP VIEW  HAT_STMP_REGRASCOBERTURA", "DROP VIEW HAT_STMP_SE1", "DROP VIEW HAT_STMP_VINCULOSODONTO", "DROP VIEW HAT_STMP_BEA_CONSULTA",;
      "DROP VIEW HAT_STMP_PROC_ATEND_BE2_CONSULTA"}

   aViews := aClone(aDrop)

   for nLinha := 1 to len(aDrop)
      TCSqlExec(aDrop[nLinha])
   next

Return


/*/{Protheus.doc} PLSX002
Executa todas as funções de criação de view
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function PLSX002()
   LOCAL nLoop := 0
   default lAuto := .F.

   dropViews()
   verIficaBD()

   LOAD_B06(.T.)
   LOAD_B06(.F.)
   B06_SINTETICO(.T.)
   B06_SINTETICO(.F.)
   B08_SINTETICO(.T.)
   B08_SINTETICO(.F.)
   B0N_SINTETICO(.T.)
   B0N_SINTETICO(.F.)
   LOAD_B26(.T.)
   LOAD_B26(.F.)
   B26_SINTETICO(.T.)
   B26_SINTETICO(.F.)
   LOAD_B2J(.T.)
   LOAD_B2J(.F.)
   LOAD_B2K(.T.)
   LOAD_B2K(.F.)
   LOAD_BA0(.T.)
   LOAD_BA0(.F.)
   LOAD_BA1(.T.)
   LOAD_BA1(.F.)
   LOAD_BA3(.T.)
   LOAD_BA3(.F.)
   LOAD_BA6(.T.)
   LOAD_BA6(.F.)
   LOAD_BA9(.T.)
   LOAD_BA9(.F.)
   LOAD_BAN(.T.)
   LOAD_BAN(.F.)
   LOAD_BAQ(.T.)
   LOAD_BAQ(.F.)
   LOAD_BAU(.T.)
   LOAD_BAU(.F.)
   LOAD_BAW(.T.)
   LOAD_BAW(.F.)
   LOAD_BAX(.T.)
   LOAD_BAX(.F.)
   LOAD_BB0(.T.)
   LOAD_BB0(.F.)
   LOAD_BB2(.T.)
   LOAD_BB2(.F.)
   BB2_SINTETICO(.T.)
   BB2_SINTETICO(.F.)
   LOAD_BB6(.T.)
   LOAD_BB6(.F.)
   LOAD_BB8(.T.)
   LOAD_BB8(.F.)
   LOAD_BBF(.T.)
   LOAD_BBF(.F.)
   LOAD_BBI(.T.)
   LOAD_BBI(.F.)
   LOAD_BBK(.T.)
   LOAD_BBK(.F.)
   LOAD_BBM(.T.)
   LOAD_BBM(.F.)
   BBM_SINTETICO(.T.)
   BBM_SINTETICO(.F.)
   LOAD_BBN(.T.)
   LOAD_BBN(.F.)
   BBN_SINTETICO(.T.)
   BBN_SINTETICO(.F.)
   LOAD_BC0(.T.)
   LOAD_BC0(.F.)
   LOAD_BC1(.T.)
   LOAD_BC1(.F.)
   LOAD_BCT(.T.)
   LOAD_BCT(.F.)
   LOAD_BDL(.T.)
   LOAD_BDL(.F.)
   LOAD_BDT(.T.)
   LOAD_BDT(.F.)
   LOAD_BE4(.T.)
   LOAD_BE4(.F.)
   LOAD_BE6(.T.)
   LOAD_BE6(.F.)
   LOAD_BE9(.T.)
   LOAD_BE9(.F.)
   LOAD_BEA(.T.)
   LOAD_BEA(.F.)
   LOAD_BF1(.T.)
   LOAD_BF1(.F.)
   LOAD_BFC(.T.)
   LOAD_BFC(.F.)
   LOAD_BFD(.T.)
   LOAD_BFD(.F.)
   LOAD_BFE(.T.)
   LOAD_BFE(.F.)
   LOAD_BFG(.T.)
   LOAD_BFG(.F.)
   BFG_SINTETICO(.T.)
   BFG_SINTETICO(.F.)
   LOAD_BFJ(.T.)
   LOAD_BFJ(.F.)
   LOAD_BFO(.T.)
   LOAD_BFO(.F.)
   LOAD_BFP(.T.)
   LOAD_BFP(.F.)
   BFP_SINTETICO(.T.)
   BFP_SINTETICO(.F.)
   LOAD_BG7(.T.)
   LOAD_BG7(.F.)
   LOAD_BG8(.T.)
   LOAD_BG8(.F.)
   BG8_SINTETICO(.T.)
   BG8_SINTETICO(.F.)
   LOAD_BG9(.T.)
   LOAD_BG9(.F.)
   LOAD_BI3(.T.)
   LOAD_BI3(.F.)
   LOAD_BI6(.T.)
   LOAD_BI6(.F.)
   LOAD_BIA(.T.)
   LOAD_BIA(.F.)
   LOAD_BJ4(.T.)
   LOAD_BJ4(.F.)
   BJ4_SINTETICO(.T.)
   BJ4_SINTETICO(.F.)
   LOAD_BJE(.T.)
   LOAD_BJE(.F.)
   LOAD_BLD(.T.)
   LOAD_BLD(.F.)
   LOAD_BLE(.T.)
   LOAD_BLE(.F.)
   LOAD_BQC(.T.)
   LOAD_BQC(.F.)
   LOAD_BR4(.T.)
   LOAD_BR4(.F.)
   LOAD_BR8(.T.)
   LOAD_BR8(.F.)
   LOAD_BRV(.T.)
   LOAD_BRV(.F.)
   LOAD_BT4(.T.)
   LOAD_BT4(.F.)
   LOAD_BT5(.T.)
   LOAD_BT5(.F.)
   LOAD_BT6(.T.)
   LOAD_BT6(.F.)
   LOAD_BT7(.T.)
   LOAD_BT7(.F.)
   LOAD_BT8(.T.)
   LOAD_BT8(.F.)
   LOAD_BTQ(.T.)
   LOAD_BTQ(.F.)
   LOAD_BTS(.T.)
   LOAD_BTS(.F.)
   LOAD_BTU(.T.)
   LOAD_BTU(.F.)
   LOAD_BVI(.T.)
   LOAD_BVI(.F.)
   LOAD_BW3(.T.)
   LOAD_BW3(.F.)
   BW3_SINTETICO(.T.)
   BW3_SINTETICO(.F.)
   CidIncompativel_BAA(.T.)
   CidIncompativel_BAA(.F.)
   ATEND_BEG(.T.)
   ATEND_BEG(.F.)
   ATEND_BEL(.T.)
   ATEND_BEL(.F.)
   ATEND_BE2(.T.)
   ATEND_BE2(.F.)
   ATEND_BEJ(.T.)
   ATEND_BEJ(.F.)
   REGRASCOBERTURA(.T.)
   REGRASCOBERTURA(.F.)
   LOAD_SE1(.T.)
   LOAD_SE1(.F.)
   VINCULOSODONTO(.T.)
   VINCULOSODONTO(.F.)
   BEA_CONSULTA(.T.)
   BE2_CONSULTA(.T.)

   PLSLOGFIL(cLog,"PLSGOODDATA.LOG")

   If lLogOk
      for nLoop := 1 to len(aViews)
         If(cDBType == "SQL")
            cSql := StrTran(aViews[nLoop],"DROP VIEW","SELECT TOP 10000 * FROM")
         Else
            cSql := StrTran(aViews[nLoop],"DROP VIEW","SELECT * FROM")
         Endif

         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TrbView",.T.,.T.)
         cLog  += "View "+ StrTran(aViews[nLoop],"DROP VIEW","")+" Executada com sucesso para as 10.000 primeiras linhas"+ CRLF
         TrbView->(DbCloseArea())
         PLSLOGFIL(cLog,"PLSGOODDATA.LOG")
      next
   Endif

      If !lLogOk
         MsgStop("Há erros no arquivo. VerIfique o Log para informações sobre os erros encontrados.")
      Else
         MsgInfo("Querys executadas com sucesso.")
      Endif

      If MsgYesNo("Deseja salvar um log do processo?", "Gravar Log")
         cFile := cgetfile("Arquivo LOG|*.log", 'Selecione o diretorio para salvar o log...', 1, plsmudsis('\'), .t., GETF_LOCALHARD + GETF_RETDIRECTORY, .t., .t.)
         cFile += "log_" + dtos(ddatabase) + "_" + strtran(time(),":","") + ".log"
         nHandle := FCREATE(cFile)
         FWrite(nHandle, cLog)
         FClose(nHandle)
      Endif

Return



/*/{Protheus.doc} HAT_LOAD_B06
Executa query que cria view HAT_LOAD_B06
@type function
@author Gabriela
@since 17.05.2022
@version 1.0
/*/
function  LOAD_B06(lSTMP, lAuto)
   
   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, dropViews(), nil)
   iIf (lAuto, verIficaBD(), nil)

   If lSTMP
      cSql +=  " CREATE VIEW  HAT_STMP_B06 AS "
   Else
      cSql +=  " CREATE VIEW  HAT_LOAD_B06 AS "
   Endif
   If cDBType == "SQL"
      cSql +=  " SELECT ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " SELECT coalesce(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela,"
   Else
      cSql +=  " SELECT NVL(BTU.BTU_CDTERM, BTQ.BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " NVL(BTU.BTU_CODTAB, BTQ.BTQ_CODTAB) CodigoTipoTabela, "
   Endif
   cSql +=  " B06_CODPRO CodigoPlano, "
   cSql +=  " B06_NIVEL Nivel, "
   cSql +=  " B06_CDNV01 CodigoNivel01, "
   cSql +=  " B06_CDNV02 CodigoNivel02, "
   cSql +=  " B06_CDNV03 CodigoNivel03, "
   cSql +=  " B06_CDNV04 CodigoNivel04, "
   cSql +=  " B06_PERIOD Periodicidade, "
   cSql +=  " B06_UNPERI UnidadePeriodicidade "
   If lSTMP 
      cSql +=  " ,B06.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("B06") + " B06 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU  ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU_VLRSIS = B06_FILIAL " + cConc +" B06_CODPAD "+ cConc +" B06_CODPSA  AND BTU.D_E_L_E_T_ = ' ')"
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '" + xFILIAL("BTQ") +  "' AND BTQ.BTQ_CODTAB = B06_CODPAD AND BTQ.BTQ_CDTERM = B06_CODPSA AND BTQ.D_E_L_E_T_ = ' ')"
   cSql +=  " WHERE B06.D_E_L_E_T_ = ' ' "
   If lSTMP 
      If cDBType == "SQL"
         cSql +=  " AND B06.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " AND B06.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " AND B06.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98'))"
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98'))"
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL))"

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_B06" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_B06", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_B06" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_B06"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_B06_SINTETICO()
Executa query que cria view HAT_LOAD_B06_SINTETICO()
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function B06_SINTETICO(lSTMP, lAuto)
   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP
      cSql +=  " CREATE VIEW  HAT_STMP_B06_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_B06_SINTETICO AS"
   Endif
   cSql +=  " SELECT B06_CODPSA CodigoProcedimento, "
   If(cDBType == "SQL")
      cSql +=  " LTRIM(BTU_CDTERM) CodigoTipoTabela, "
   ElseIf(cDBType == "POSTGRES")
      cSql +=  " coalesce(BTU_CODTAB, BTU_CODTAB) CodigoTipoTabela,"
   Else
      cSql +=  " NVL(BTU_CODTAB, BTU_CODTAB) CodigoTipoTabela,"
   Endif
   cSql +=  " B06_CODPRO CodigoPlano, "
   cSql +=  " B06_NIVEL Nivel, "
   cSql +=  " B06_CDNV01 CodigoNivel01, "
   cSql +=  " B06_CDNV02 CodigoNivel02, "
   cSql +=  " B06_CDNV03 CodigoNivel03, "
   cSql +=  " B06_CDNV04 CodigoNivel04, "
   cSql +=  " B06_PERIOD Periodicidade, "
   cSql +=  " B06_UNPERI UnidadePeriodicidade "
   If lSTMP
      cSql +=  " ,B06.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("B06") + " B06 "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON BTU_FILIAL = '" + xFILIAL("BTU") + "' AND BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = B06_CODPAD "
   cSql +=  " WHERE B06.D_E_L_E_T_ = ' '"
   If lSTMP 
      If cDBType == "SQL"
         cSql +=  " AND B06.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " AND B06.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " AND B06.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Endif
   cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_B06_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_B06_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_B06_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_B06_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_B08_SINTETICO
Executa query que cria view HAT_LOAD_B08_SINTETICO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function B08_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F. 

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP
      cSql +=  " CREATE VIEW HAT_STMP_B08_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_B08_SINTETICO AS "
   Endif
   If(cDBType == "SQL")
      cSql +=  " SELECT LTRIM(BTU_CDTERM) TabelaProcedimento, "
   ElseIf(cDBType == "POSTGRES")
      cSql +=  " SELECT BTU_CDTERM TabelaProcedimento, "
   Else
      cSql +=  " SELECT NVL(BTU_CDTERM) TabelaProcedimento, "
   Endif
   cSql +=  " B08_CODPSA Procedimento, "
   cSql +=  " B08_DENREG DenteRegiao, "
   cSql +=  " B08_CHVPAD TabelaIncompativel, "
   cSql +=  " B08_CHVPSA ProcedimentoIncompativel, "
   cSql +=  " B08_CHVREG DenteIncompativel, "
   cSql +=  " B08_NIVEL  Nivel, "
   cSql +=  " B08_CDNV01 Nivel1, "
   cSql +=  " B08_CDNV02 Nivel2, "
   cSql +=  " B08_CDNV03 Nivel3, "
   cSql +=  " B08_CDNV04 Nivel4, "
   cSql +=  " B08_QUANTI Quantidade, "
   cSql +=  " B08_UNIDAD UnidadeQuantidade, "
   cSql +=  " B08_CONRDA ConsideraRedeAtendimento, "
   cSql +=  " B08_EXCETO Excecao, "
   cSql +=  " B08_PERIOD UnidadeExcecao "
   If lSTMP
      cSql +=  " ,B08.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("B08") + " B08 "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON BTU_FILIAL = '" + xFILIAL("BTU") + "' AND BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = B08_CODPAD "
   If lSTMP 
      If cDBType == "SQL"
         cSql +=  " WHERE B08.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND B08.D_E_L_E_T_ = ' ' AND LTRIM(BTU_VLRBUS) IS NOT NULL  AND BTU.D_E_L_E_T_ = ' ' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE B08.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND LTRIM(BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' " 
      Else
         cSql +=  " WHERE B08.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND LTRIM(BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
      Endif
   Else
      cSql +=  " WHERE B08.D_E_L_E_T_ = ' ' "
      cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
      cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   Endif
      If cDBType == "SQL" .Or. cDBType == "ORACLE"
         cSql +=  " GROUP BY "
         cSql +=  " LTRIM(BTU_CDTERM),B08_CODPSA,B08_DENREG,B08_CHVPAD,B08_CHVPSA,B08_CHVREG,B08_NIVEL,"
         cSql +=  " B08_CDNV01,B08_CDNV02,B08_CDNV03,B08_CDNV04,B08_QUANTI,B08_UNIDAD,B08_CONRDA,B08_EXCETO,B08_PERIOD "
      Else
         cSql +=  " GROUP BY "
         cSql +=  " BTU_CDTERM,B08_CODPSA,B08_DENREG,B08_CHVPAD,B08_CHVPSA,B08_CHVREG,B08_NIVEL, "
         cSql +=  " B08_CDNV01,B08_CDNV02,B08_CDNV03,B08_CDNV04,B08_QUANTI,B08_UNIDAD,B08_CONRDA,B08_EXCETO,B08_PERIOD "
      Endif
      If lSTMP
         cSql +=  " , B08.D_E_L_E_T_ "
      Endif
   nStatus := TCSqlExec(cSql)

  clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_B08_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_B08_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_B08_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_B08_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_B0N_SINTETICO
Executa query que cria view HAT_LOAD_B0N_SINTETICO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function B0N_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP
      cSql +=  " CREATE VIEW HAT_STMP_B0N_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_B0N_SINTETICO AS "
   Endif
   If cDBType == "SQL"
      cSql +=  " SELECT LTRIM(BTU_CDTERM) TabelaProcedimento, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " SELECT BTU_CDTERM TabelaProcedimento, "
   Else
      cSql +=  " SELECT NVL(BTU_CDTERM) AS TabelaProcedimento,"
   Endif
   cSql +=  " B0N_CODPSA Procedimento, "
   cSql +=  " B0N_DENREG DenteRegiao, "
   cSql +=  " B0N_CHVPAD TabelaRequisito, "
   cSql +=  " B0N_CHVPSA ProcedimentoRequisito, "
   cSql +=  " B0N_CHVREG DenteRequisito, "
   cSql +=  " B0N_NIVEL Nivel, "
   cSql +=  " B0N_CDNV01 Nivel1, "
   cSql +=  " B0N_CDNV02 Nivel2, "
   cSql +=  " B0N_CDNV03 Nivel3, "
   cSql +=  " B0N_CDNV04 Nivel4, "
   cSql +=  " B0N_QTDMIN QtdMinima, "
   cSql +=  " B0N_UNIMIN UnidadeQtdMinima, "
   cSql +=  " B0N_QTDMAX QtdMaxima, "
   cSql +=  " B0N_UNIMAX UnidadeQtdMaxima, "
   cSql +=  " B0N_PRERGU PreReqMesmaGuia "
   If lSTMP
      cSql +=  " ,B0N.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("B0N") + " B0N "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON BTU_FILIAL = '" + xFILIAL("BTU") + "' AND BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = B0N_CODPAD "
   cSql +=  " WHERE "
   If lSTMP
      If cDBType == "SQL"
         cSql +=  " B0N.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " B0N.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " B0N.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " B0N.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL"
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   cSql +=  " GROUP BY "
   If cDBType == "SQL" .Or. cDBType == "ORACLE"
      cSql +=  " LTRIM(BTU_CDTERM),B0N_CODPSA, B0N_DENREG, B0N_CHVPAD, B0N_CHVPSA, B0N_CHVREG, B0N_NIVEL, B0N_CDNV01, B0N_CDNV02, "
      cSql +=  " B0N_CDNV03, B0N_CDNV04, B0N_QTDMIN, B0N_UNIMIN, B0N_QTDMAX ,B0N_UNIMAX, B0N_PRERGU"
   Else
      cSql +=  " BTU_CDTERM,B0N_CODPSA, B0N_DENREG, B0N_CHVPAD, B0N_CHVPSA, B0N_CHVREG, B0N_NIVEL, B0N_CDNV01, B0N_CDNV02, B0N_CDNV03,"
      cSql +=  " B0N_CDNV04, B0N_QTDMIN, B0N_UNIMIN, B0N_QTDMAX ,B0N_UNIMAX, B0N_PRERGU"
   Endif
      If lSTMP
      cSql +=  " , B0N.D_E_L_E_T_ "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_B0N_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_B0N_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_B0N_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_B0N_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

   
Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_B26
Executa query que cria view HAT_LOAD_B26
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_B26(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
   cSql +=  " CREATE VIEW HAT_STMP_B26 AS "
   Else
   cSql +=  " CREATE VIEW HAT_LOAD_B26 AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) AS CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) AS CodigoProcedimento,
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela,"
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) AS CodigoProcedimento, "
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela,"
   Endif
   cSql +=  " B26_CDNV01 CodigoNivel01, "
   cSql +=  " B26_CDNV02 CodigoNivel02, "
   cSql +=  " B26_CDNV03 CodigoNivel03, "
   cSql +=  " B26_CDNV04 CodigoNivel04, "
   cSql +=  " B26_CODRDA CodigoPrestador, "
   cSql +=  " B26_AUXPAD CodTabelaAuxiliar, "
   cSql +=  " B26_AUXPSA CodProcedAuxiliar "
   If lSTMP
      cSql +=  " ,B26.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("B26") + " B26 "
   If cDBType == "SQL"
      cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '" + xFILIAL("BTU") +"' AND BTU.BTU_VLRSIS = B26_FILIAL " + cConc +" B26_CODPAD "+ cConc +" B26_CODPSA AND BTU.D_E_L_E_T_ = ' ') "
      cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '" + xFILIAL("BTQ") +"' AND BTQ.BTQ_CODTAB = B26_CODPAD AND BTQ.BTQ_CDTERM = B26_CODPSA AND BTQ.D_E_L_E_T_ = ' ') "
   Else
      cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_VLRBUS = B26_CODPSA AND BTU.D_E_L_E_T_ = ' ') "
      cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_CDTERM = B26_CODPSA AND BTQ.D_E_L_E_T_ = ' ') "
   Endif
   If lSTMP
      If cDBType == "SQL"
         cSql += " "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE B26.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE B26.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE B26.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL))"

   nStatus := TCSqlExec(cSql) 

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_B26" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_B26", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_B26" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_B26"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_B26_SINTETICO()
Executa query que cria view HAT_LOAD_B26_SINTETICO()
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function B26_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_B26_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_B26_SINTETICO AS "
   Endif
   cSql +=  " SELECT B26_CODPSA CodigoProcedimento, "
   If(cDBType == "SQL")
      cSql +=  " LTRIM(BTU_CDTERM) CodigoTipoTabela, "
   ElseIf(cDBType == "POSTGRES")
      cSql +=  " coalesce(BTU_CODTAB, BTU_CODTAB) CodigoTipoTabela, "
   Else
      cSql +=  " NVL(BTU_CODTAB, BTU_CODTAB) CodigoTipoTabela, "
   Endif
   cSql +=  " B26_CDNV01 CodigoNivel01, "
   cSql +=  " B26_CDNV02 CodigoNivel02, "
   cSql +=  " B26_CDNV03 CodigoNivel03, "
   cSql +=  " B26_CDNV04 CodigoNivel04, "
   cSql +=  " B26_CODRDA CodigoPrestador, "
   cSql +=  " B26_AUXPAD CodTabelaAuxiliar, "
   cSql +=  " B26_AUXPSA CodProcedAuxiliar "
   If lSTMP
      cSql +=  " ,B26.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("B26") + " B26 "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON "
   If(cDBType == "SQL")
      cSql +=  " (BTU_FILIAL = '" + xFILIAL("BTU") +"' AND BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = B26_CODPAD) "
   Else
      cSql +=  " BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = B26_CODPAD "
   Endif
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE B26.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
         cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
         cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
         cSql +=  " GROUP BY "
         cSql +=  " B26_CODPSA, B26_CDNV01, B26_CDNV02, B26_CDNV03, B26_CDNV04, B26_CODRDA, B26_AUXPAD, B26_AUXPSA, BTU_CDTERM, BTU_CODTAB, B26.D_E_L_E_T_ "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE B26.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
         cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
         cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
         cSql +=  " GROUP BY "
         cSql +=  " B26_CODPSA, B26_CDNV01, B26_CDNV02, B26_CDNV03, B26_CDNV04, B26_CODRDA, B26_AUXPAD, B26_AUXPSA, BTU_CDTERM, BTU_CODTAB, B26.D_E_L_E_T_ "
      Else
         cSql +=  " WHERE B26.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
         cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
         cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
         cSql +=  " GROUP BY "
         cSql +=  " B26_CODPSA, B26_CDNV01, B26_CDNV02, B26_CDNV03, B26_CDNV04, B26_CODRDA, B26_AUXPAD, B26_AUXPSA, BTU_CDTERM "
      Endif
   Else
      cSql +=  " WHERE B26.D_E_L_E_T_ = ' ' "
      cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
      cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_B26_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_B26_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_B26_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_B26_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_B2J
Executa query que cria view HAT_LOAD_B2J
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_B2J(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_B2J AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_B2J AS "
   Endif
   cSql +=  " SELECT B2J_CODINT CodigoOperadora, "
   cSql +=  " B2J_COD Codigo, "
   cSql +=  " B2J_DESC Descricao, "
   cSql +=  " B2J_CALPAD CalendarioPadrao "
   If lSTMP
      cSql +=  " ,B2J.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("B2J") + " B2J "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE B2J.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE B2J.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE B2J.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE B2J.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_B2J" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_B2J", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_B2J" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_B2J"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_B2K
Executa query que cria view HAT_LOAD_B2K
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_B2K(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_B2K AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_B2K AS "
   Endif
   cSql +=  " SELECT  B2K_COD Codigo, "
   cSql +=  " B2K_ANO Ano, "
   cSql +=  " B2K_MES Mes, "
   cSql +=  " B2K_DIAINI DataInicial, "
   cSql +=  " B2K_DIAFIM DataFinal, "
   cSql +=  " B2K_DIAPGT DiaPagamento, "
   cSql +=  " B2K_CODRDA CodigoRda, "
   cSql +=  " ' ' DescricaoRda, "
   cSql +=  " B2K_STATUS Status, "
   cSql +=  " B2K_CODSEQ Sequencial, "
   cSql +=  " B2K_DIAIN2 DataInicial2, "
   cSql +=  " B2K_DIAFI2 DataFinal2 "
   If lSTMP
      cSql +=  " ,B2K.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("B2K") + " B2K "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE B2K.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE B2K.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE B2K.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE B2K.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_B2K" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_B2K", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_B2K" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_B2K"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BA0
Executa query que cria view HAT_LOAD_BA0
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_BA0(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BA0 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BA0 AS "
   Endif
   cSql +=  " SELECT BA0_CODIDE CodigoIdentIficacaoEmpresa, "
   cSql +=  " BA0_CODINT CodigoOperadora, "
   cSql +=  " BA0_NOMINT Operadora, "
   cSql +=  " BA0_SUSEP NumeroRegistroANS, "
   cSql +=  " BA0_END Endereco, "
   cSql +=  " BA0_LOJA CodigoLoja, "
   cSql +=  " BA0_CODCLI CodigoCliente, "
   cSql +=  " BA0_ABRANG Abrangencia, "
   If lSTMP
      cSql +=  " BA0.D_E_L_E_T_ AS Deletado, "
   Endif
   cSql +=  " BA0_NUMEND NumeroEndereco, "
   cSql +=  " BA0_CEP CEP, "
   cSql +=  " BA0_BAIRRO Bairro, "
   cSql +=  " BA0_CIDADE Cidade, "
   cSql +=  " BA0_EST Estado "
   cSql +=  " FROM " + RETSQLName("BA0") + " BA0 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BA0.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BA0.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BA0.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BA0.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BA0" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BA0", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BA0" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BA0"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BA1
Executa query que cria view HAT_LOAD_BA1
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_BA1(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BA1 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BA1 AS "
   Endif
   cSql +=  " SELECT BA1_ALTURA Altura, "
   cSql +=  " BA1_CEPUSR CEP, "
   cSql +=  " BA1_MATRIC CodigoFamilia, "
   cSql +=  " BA1_CODEMP CodigoGrpEmpresa, "
   cSql +=  " BA1_CODMUN CodigoIbgeMunicipio, "
   cSql +=  " BA1_CODINT CodigoOperadora, "
   cSql +=  " BA1_CODPLA CodigoPlano, "
   cSql +=  " BA1_TIPREG CodigoTipoBeneficiario, "
   cSql +=  " BA1_CPFUSR CPF, "
   cSql +=  " BA1_DATBLO DataBloqueio, "
   cSql +=  " BA1_DATCAR DataCarencia, "
   cSql +=  " BA1_DATINC DataInclusao, "
   cSql +=  " BA1_DATNAS DataNascimento,"
   cSql +=  " BA1_DTVLCE DataValidadeCartaoEmpresa, "
   cSql +=  " BA1_DTVLCR DataValidadeCarteira, "
   cSql +=  " BA1_DIGITO Digito, "
   cSql +=  " BA1_SEXO Genero, "
   cSql +=  " BA1_INFCOB InformacaoCobertura, "
   cSql +=  " BA1_INFGCB InformacaoGrupoCobertura, "
   cSql +=  " BA1_INFPRE InformacaoPreExistencia, "
   cSql +=  " BA1_MATANT MatriculaAnterior, "
   cSql +=  " BA1_MATVID MatriculaVida, "
   If cDBType == "SQL"
      cSql +=  " REPLACE(REPLACE(BA1_NOMUSR,CHAR(13) + Char(10) ,' '), CHAR(10), ' ') NomeBeneficiario, "
   Else
      cSql +=  " REPLACE(REPLACE(TRIM(BA1_NOMUSR),CHR(13) ,' '), CHR(10), ' ') NomeBeneficiario, "
   Endif
   cSql +=  " BA1_NUMCON NovoNumeroContrato, "
   cSql +=  " BA1_CONEMP NumeroContrato, "
   cSql +=  " BA1_SUBCON NumeroSubcontrato, "
   cSql +=  " BA1_OPEORI OperadoraOrigem, "
   cSql +=  " BA1_TRAORI OrigemTransferencia, "
   cSql +=  " BA1_PESO Peso, "
   cSql +=  " BA1_TIPUSU TpBeneficiario, "
   cSql +=  " BA1_VERCON VersaoContrato, "
   cSql +=  " BA1_VERSAO VersaoPlano, "
   cSql +=  " BA1_VERSUB VersaoSubContrato, "
   cSql +=  " BA1_VIACAR ViaCarteira, "
   cSql +=  " BA1_TKSEED Token "
   If lSTMP
      cSql +=  " ,BA1.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BA1") + " BA1 "
   If lSTMP 
     If cDBType == "SQL"
         cSql +=  " WHERE BA1.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BA1.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BA1.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BA1.D_E_L_E_T_ = ' '  AND (BA1_DATBLO >= '20180101' OR BA1_DATBLO = ' ') "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BA1" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BA1", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BA1" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BA1"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BA3
Executa query que cria view HAT_LOAD_BA3
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_BA3(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BA3 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BA3 AS "
   Endif
   cSql +=  " SELECT BA3_COBNIV CobrancaNivel, "
   cSql +=  " BA3_CODCLI CodigoCliente, "
   cSql +=  " BA3_MATRIC CodigoFamilia, "
   cSql +=  " BA3_CODEMP CodigoGrpEmpresa, "
   cSql +=  " BA3_LOJA CodigoLoja, "
   cSql +=  " BA3_CODINT CodigoOperadora, "
   cSql +=  " BA3_CODPLA CodigoPlano, "
   cSql +=  " BA3_DATBAS DataInclusao, "
   cSql +=  " BA3_DIASIN DiasInadimplencia, "
   cSql +=  " BA3_INFCOB InformacaoCobertura, "
   cSql +=  " BA3_INFGCB InformacaoGrupoCobertura, "
   cSql +=  " BA3_NUMCON NovoNumeroContrato, "
   cSql +=  " BA3_CONEMP NumeroContrato,"
   cSql +=  " BA3_SUBCON NumeroSubcontrato, "
   cSql +=  " BA3_TIPOUS TipoContrato, "
   cSql +=  " BA3_VERCON VersaoContrato, "
   cSql +=  " BA3_VERSAO VersaoPlano, "
   cSql +=  " BA3_VERSUB VersaoSubcontrato "
   If lSTMP
      cSql +=  " ,BA3.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BA3") + " BA3 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BA3.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BA3.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BA3.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BA3.D_E_L_E_T_ = ' ' AND BA3_CODINT " + cConc + " BA3_CODEMP " + cConc + " BA3_MATRIC IN "
      cSql +=  " (SELECT BA1_CODINT " +  cConc +  " BA1_CODEMP " +  cConc + " BA1_MATRIC "
      cSql +=  " FROM " + RETSQLName("BA1") + " BA1 "
      cSql +=  " WHERE BA1.D_E_L_E_T_ = ' ' AND (BA1_DATBLO >= '20180101' OR BA1_DATBLO = ' ')) "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BA3" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BA3", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BA3" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BA3"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BA6
Executa query que cria view HAT_LOAD_BA6
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_BA6(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BA6 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BA6 AS "
   Endif
   cSql +=  " SELECT BA6_CLACAR AS ClasseCarencia,"
   cSql +=  " BA6_CODIGO AS CodigoGrpEmpresa, "
   cSql +=  " BA6_CODINT AS CodigoOperadora, "
   cSql +=  " BA6_CODPRO AS CodigoPlano, "
   cSql +=  " BA6_NUMCON AS NumeroContrato, "
   cSql +=  " BA6_SUBCON AS NumeroSubcontrato, "
   cSql +=  " BA6_CARENC AS QuantidadeCarencia, "
   cSql +=  " BA6_UNICAR AS UnidadeCarencia, "
   cSql +=  " BA6_VERCON AS VersaoContrato, "
   cSql +=  " BA6_VERPRO AS VersaoPlano, "
   cSql +=  " BA6_VERSUB AS VersaoSubContrato "
   If lSTMP
      cSql +=  " ,BA6.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BA6") + " BA6 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BA6.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BA6.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BA6.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BA6.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BA6" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BA6", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BA6" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BA6"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BA9
Executa query que cria view HAT_LOAD_BA9
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_BA9(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BA9 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BA9 AS "
   Endif
   cSql +=  " SELECT BA9_CODDOE CID, "
   cSql +=  " BA9_DOENCA Doenca "
   If lSTMP
      cSql +=  " ,BA9.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BA9") + " BA9 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BA9.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BA9.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BA9.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BA9.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)
   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BA9" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BA9", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f.,  "Ocorreu erro na seguinte view:  HAT_LOAD_BA9" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BA9"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BAN
Executa query que cria view HAT_LOAD_BAN
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_BAN(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BAN AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BAN AS "
   Endif
   cSql +=  " SELECT BAN_CLACAR ClasseCarencia, "
   cSql +=  " BAN_CODIGO CodigoPlano, "
   cSql +=  " BAN_QTDCAR QuantidadeCarencia, "
   cSql +=  " BAN_UNCAR UnidadeCarencia, "
   cSql +=  " BAN_VERSAO VersaoPlano "
   If lSTMP
      cSql +=  " ,BAN.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BAN") + " BAN "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BAN.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BAN.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BAN.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BAN.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BAN" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BAN", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BAN" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BAN"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BB0
Executa query que cria view HAT_LOAD_BB0
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_BB0(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BB0 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BB0 AS "
   Endif
   cSql +=  " SELECT BB0_CODOPE CodigoOperadora, "
   cSql +=  " BB0_CODIGO CodigoProfissional, "
   cSql +=  " BB0_CGC CpfCnpj, "
   cSql +=  " BB0_DATBLO DataBloqueio, "
   cSql +=  " BB0_EMAIL Email, "
   cSql +=  " BB0_ESTADO Estado, "
   cSql +=  " BB0_MATVID MatriculaVida, "
   cSql +=  " BB0_NOME NomeProfissional, "
   cSql +=  " BB0_NUMCR NumeroConselho, "
   cSql +=  " BB0_CODSIG SiglaConselho, "
   cSql +=  " BB0_TEL Telefone, "
   cSql +=  " BB0_VINC VINCULOOPERADORA "
   If lSTMP
      cSql +=  " ,BB0.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BB0") + " BB0 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BB0.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BB0.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BB0.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BB0.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BB0" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BB0", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BB0" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BB0"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf


Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BB2
Executa query que cria view HAT_LOAD_BB2
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function LOAD_BB2(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BB2 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BB2 AS "
   Endif
   cSql +=  " SELECT BB2_BENUTL Ativo, "
   cSql +=  " BB2_CARENC QuantidadeCarencia, "
   cSql +=  " BB2_CLACAR ClasseCarencia, "
   cSql +=  " BB2_CDNV01 CodigoNivel01, "
   cSql +=  " BB2_CDNV02 CodigoNivel02, "
   cSql +=  " BB2_CDNV03 CodigoNivel03, "
   cSql +=  " BB2_CDNV04 CodigoNivel04, "
   cSql +=  " BB2_CODIGO CodigoOperadoraPlano, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Endif
   cSql +=  " BB2_SEXO Genero, "
   cSql +=  " BB2_IDAMAX IdadeMaxima, "
   cSql +=  " BB2_IDAMIN IdadeMinima, "
   cSql +=  " BB2_NIVEL Nivel, "
   cSql +=  " BB2_NIVCAR NivelCarencia, "
   cSql +=  " BB2_PERIOD Periodicidade, "
   cSql +=  " BB2_PTRESP PeriodoEspecialidade, "
   cSql +=  " BB2_PTRPAT PeriodoPatologia, "
   cSql +=  " BB2_PTRMED PeriodoPrestador, "
   cSql +=  " BB2_QTDESP QuantidadeEspecialidade, "
   cSql +=  " BB2_QTDPAT QuantidadePatologia, "
   cSql +=  " BB2_QTD QuantidadePermitida, "
   cSql +=  " BB2_QTDMED QuantidadePrestador, "
   cSql +=  " BB2_AUTORI AS TipoAutorizacao, "
   cSql +=  " BB2_UNCAR AS UnidadeCarencia, "
   cSql +=  " BB2_UNPERI AS UnidadePeriodicidade, "
   cSql +=  " BB2_UNCA AS UnidadeQuantidade, "
   cSql +=  " BB2_VERSAO AS VersaoPlano "
   If lSTMP
      cSql +=  " ,BB2.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BB2") + " BB2 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BB2_FILIAL "+ cConc +" BB2_CODPAD"+ cConc +" BB2_CODPSA AND BTU.D_E_L_E_T_ = ' ' )"
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '" + xFILIAL("BTQ") +  "' AND BTQ.BTQ_CODTAB = BB2_CODPAD AND BTQ.BTQ_CDTERM = BB2_CODPSA AND BTQ.D_E_L_E_T_ = ' ')"
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BB2.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BB2.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BB2.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BB2.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98'))"
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98'))"
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL))"

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BB2" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BB2", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BB2" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BB2"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BAQ
Executa query que cria view HAT_LOAD_BAQ
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BAQ(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BAQ AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BAQ AS "
   Endif
   cSql +=  " SELECT BAQ_CBOS	CodigoCBOS, "
   cSql +=  " BAQ_CODESP CodigoEspecialidade, "
   cSql +=  " BAQ_CODINT CodigoOperadora, "
   cSql +=  " BAQ_DESCRI Descricao, "
   cSql +=  " BAQ_SEXO Genero, "
   cSql +=  " BAQ_IDAMAX IdadeMaxima, "
   cSql +=  " BAQ_IDAMIN IdadeMinima "
   If lSTMP
      cSql +=  " ,BAQ.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BAQ") + " BAQ "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BAQ.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BAQ.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BAQ.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BAQ.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BAQ" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BAQ", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BAQ" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BAQ"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BAU
Executa query que cria view HAT_LOAD_BAU
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BAU(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BAU AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BAU AS "
   Endif
   cSql +=  " SELECT BAU_CODOPE CodigoOperadora, "
   cSql +=  " BAU_CODIGO CodigoPrestador, "
   cSql +=  " BAU_CODBB0 CodigoProfissional, "
   cSql +=  " BAU_CPFCGC CpfCnpj, "
   cSql +=  " BAU_DATBLO DataBloqueio, "
   cSql +=  " BAU_RETCON DiasRetornoConsulta, "
   cSql +=  " BAU_EMAIL Email, "
   cSql +=  " BAU_MATVID MatriculaVida, "
   cSql +=  " BAU_MUN Municipio, "
   cSql +=  " BAU_NOME NomePrestador, "
   cSql +=  " BAU_TIPPE TipoPessoa, "
   cSql +=  " BAU_TIPPRE TipoPrestador "
   If lSTMP
      cSql +=  " ,BAU.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BAU") + " BAU "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BAU.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BAU.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BAU.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BAU.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BAU" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BAU", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BAU" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BAU"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BAW
Executa query que cria view HAT_LOAD_BAW
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BAW(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BAW AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BAW AS "
   Endif
   cSql +=  " SELECT BAW_CODIGO CodigoPrestador, "
   cSql +=  " BAW_CODINT CodigoOperadora, "
   cSql +=  " BAW_VIGINI VigenciaInicial, "
   cSql +=  " BAW_VIGFIN VigenciaFinal "
   If lSTMP
      cSql +=  " ,BAW.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BAW") + " BAW "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BAW.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BAW.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BAW.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BAW.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BAW" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BAW", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BAW" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BAW"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BAX
Executa query que cria view HAT_LOAD_BAX
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BAX(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BAX AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BAX AS "
   Endif
   cSql +=  " SELECT BAX_CODESP CodigoEspecialidade, "
   cSql +=  " BAX_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BAX_CODINT CodigoOperadora, "
   cSql +=  " BAX_CODIGO CodigoPrestador, "
   cSql +=  " BAX_CONESP ConsideraEspecialidade, "
   cSql +=  " BAX_DATBLO DataBloqueio, "
   cSql +=  " BAX_ORDPES OrdemPesquisa, "
   cSql +=  " BAX_LIMATM PermiteMaterial "
   If lSTMP
      cSql +=  " ,BAX.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BAX") + " BAX "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BAX.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BAX.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BAX.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BAX.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BAX" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BAX", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BAX" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BAX"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BB2_SINTETICO
Executa query que cria view HAT_LOAD_BB2_SINTETICO"
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function BB2_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BB2_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BB2_SINTETICO AS "
   Endif
   cSql +=  " SELECT BB2_BENUTL Ativo, "
   cSql +=  " BB2_CARENC QuantidadeCarencia, "
   cSql +=  " BB2_CLACAR ClasseCarencia, "
   cSql +=  " BB2_CDNV01 CodigoNivel01, "
   cSql +=  " BB2_CDNV02 CodigoNivel02, "
   cSql +=  " BB2_CDNV03 CodigoNivel03, "
   cSql +=  " BB2_CDNV04 CodigoNivel04, "
   cSql +=  " BB2_CODIGO CodigoOperadoraPlano, "
   If cDBType == "SQL"
      cSql +=  " LTRIM(BTU_CDTERM) CodigoTipoTabela, "
   Else
      cSql +=  " TRIM(BTU_CDTERM) CodigoTipoTabela, "
   Endif
   cSql +=  " BB2_SEXO Genero, "
   cSql +=  " BB2_IDAMAX IdadeMaxima, "
   cSql +=  " BB2_IDAMIN IdadeMinima, "
   cSql +=  " BB2_NIVEL Nivel, "
   cSql +=  " BB2_NIVCAR NivelCarencia, "
   cSql +=  " BB2_PERIOD Periodicidade, "
   cSql +=  " BB2_PTRESP PeriodoEspecialidade, "
   cSql +=  " BB2_PTRPAT PeriodoPatologia, "
   cSql +=  " BB2_PTRMED PeriodoPrestador, "
   cSql +=  " BB2_QTDESP QuantidadeEspecialidade, "
   cSql +=  " BB2_QTDPAT QuantidadePatologia, "
   cSql +=  " BB2_QTD QuantidadePermitida, "
   cSql +=  " BB2_QTDMED QuantidadePrestador, "
   cSql +=  " BB2_AUTORI TipoAutorizacao, "
   cSql +=  " BB2_UNCAR UnidadeCarencia, "
   cSql +=  " BB2_UNPERI UnidadePeriodicidade, "
   cSql +=  " BB2_UNCA UnidadeQuantidade, "
   cSql +=  " BB2_VERSAO VersaoPlano "
   If lSTMP
      cSql +=  " ,BB2.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BB2") + " BB2 "
   cSql +=  " JOIN " + RETSQLName("BA8") + " BA8 ON BA8_FILIAL = '"  + xFILIAL("BA8") + "' AND BA8_CDPADP = BB2_CODPAD AND BA8_CODPRO = BB2_CODPSA AND BA8_ANASIN = '2' "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = BB2_CODPAD "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BB2.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BB2.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BB2.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BB2.D_E_L_E_T_ = ' ' "
   Endif
   If cDBType == "SQL"
      cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
   Else
      cSql +=  " AND TRIM(BTU_VLRBUS) IS NOT NULL "
   Endif
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   cSql +=  " GROUP BY "
   cSql +=  " BB2_BENUTL, BB2_CARENC, BB2_CLACAR, BB2_CDNV01, BB2_CDNV02, BB2_CDNV03, BB2_CDNV04, "
   cSql +=  " BB2_CODIGO, BB2_CODPSA, "
   If cDBType == "SQL"
      cSql +=  " LTRIM(BTU_CDTERM), "
   Else
      cSql +=  " TRIM(BTU_CDTERM), "
   Endif
   cSql +=  " BB2_SEXO, BB2_IDAMAX, BB2_IDAMIN, "
   cSql +=  " BB2_NIVEL, BB2_NIVCAR, BB2_PERIOD, BB2_PTRESP, BB2_PTRPAT, BB2_PTRMED, BB2_QTDESP, "
   cSql +=  " BB2_QTDPAT, BB2_QTD, BB2_QTDMED, BB2_AUTORI, BB2_UNCAR, BB2_UNPERI, BB2_UNCA, BB2_VERSAO "
   If lSTMP
      cSql +=  " , BB2.D_E_L_E_T_ "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BB2_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_BB2_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BB2_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BB2_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BB6
Executa query que cria view HAT_LOAD_BB6
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BB6(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BB6 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BB6 AS "
   Endif
   cSql +=  " SELECT BB6_ATIVO Ativo, "
   cSql +=  " BB6_CODIGO CodigoPlano, "
   cSql +=  " BB6_CODRED Prestador, "
   cSql +=  " BB6_VERSAO VersaoPlano "
   If lSTMP
      cSql +=  " ,BB6.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BB6") + " BB6 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BB6.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BB6.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BB6.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BB6.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BB6" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BB6", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BB6" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BB6"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BB8
Executa query que cria view HAT_LOAD_BB8
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BB8(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BB8 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BB8 AS "
   Endif
   cSql +=  " SELECT BB8_BAIRRO Bairro, "
   cSql +=  " BB8_CEP CEP, "
   cSql +=  " BB8_CNES CNES, "
   cSql +=  " BB8_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BB8_CODINT CodigoOperadora, "
   cSql +=  " BB8_CODIGO CodigoPrestador, "
   cSql +=  " BB8_COMEND Complemento, "
   cSql +=  " BB8_DATBLO DataBloqueio, "
   cSql +=  " BB8_DESLOC Descricao, "
   cSql +=  " BB8_END Endereco, "
   cSql +=  " BB8_EST Estado, "
   cSql +=  " BB8_LOCAL LocalAtendimento, "
   cSql +=  " BB8_MUN Municipio, "
   cSql +=  " BB8_NR_END Numero, "
   cSql +=  " BB8_REGMUN Regiao, "
   cSql +=  " BB8_TRTEXE TrataExecutante "
   If lSTMP
      cSql +=  " ,BB8.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BB8") + " BB8 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BB8.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BB8.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BB8.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BB8.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BB8" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BB8", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BB8" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BB8"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BBF
Executa query que cria view  HAT_LOAD_BBF
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BBF(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BBF AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BBF AS "
   Endif
   cSql +=  " SELECT BBF_CDESP CodigoEspecialidade, "
   cSql +=  " BBF_CODINT CodigoOperadora, "
   cSql +=  " BBF_CODIGO CodigoPrestador, "
   cSql +=  " BBF_DATBLO DataBloqueio, "
   cSql +=  " BBF_SEXO Genero, "
   cSql +=  " BBF_IDAMAX IdadeMaxima, "
   cSql +=  " BBF_IDAMIN IdadeMinima "
   If lSTMP
      cSql +=  " ,BBF.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BBF") + " BBF "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BBF.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BBF.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BBF.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BBF.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BBF" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BBF", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BBF" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BBF"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BBI
Executa query que cria view  HAT_LOAD_BBI
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BBI(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BBI AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BBI AS "
   Endif
   cSql +=  " SELECT BBI_ATIVO Ativo, "
   cSql +=  " BBI_CODESP CodigoEspecialidade, "
   cSql +=  " BBI_CODGRU CodigoGrupoCobertura, "
   cSql +=  " BBI_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BBI_CODPRO CodigoPlano, "
   cSql +=  " BBI_CODIGO CodigoPrestador, "
   cSql +=  " BBI_VERSAO VersaoPlano, "
   cSql +=  " BBI_VIGATE VigenciaFinal, "
   cSql +=  " BBI_VIGDE VigenciaInicial "
   If lSTMP
      cSql +=  " ,BBI.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BBI") + " BBI "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BBI.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BBI.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BBI.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BBI.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BBI" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BBI", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BBI" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BBI"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BBK
Executa query que cria view  HAT_LOAD_BBK
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BBK(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BBK AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BBK AS "
   Endif
   cSql +=  " SELECT BBK_CODESP CodigoEspecialidade, "
   cSql +=  " BBK_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BBK_CODINT CodigoOperadora, "
   cSql +=  " BBK_CODIGO CodigoPrestador, "
   cSql +=  " BBK_CODRED TipoPrestador "
   If lSTMP
      cSql +=  " ,BBK.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BBK") + " BBK "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BBK.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BBK.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BBK.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BBK.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BBK" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BBK", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BBK" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BBK"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BBM
Executa query que cria view  HAT_LOAD_BBM
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BBM(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BBM AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BBM AS "
   Endif
   cSql +=  " SELECT BBM_ATIVO Ativo, "
   cSql +=  " BBM_CODESP CodigoEspecialidade, "
   cSql +=  " BBM_CDNV01 CodigoNivel01, "
   cSql +=  " BBM_CDNV02 CodigoNivel02, "
   cSql +=  " BBM_CDNV03 CodigoNivel03, "
   cSql +=  " BBM_CDNV04 CodigoNivel04, "
   cSql +=  " BBM_CODINT CodigoOperadora, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela,"
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Endif
   cSql +=  " BBM_DATVAL DataValidade, "
   cSql +=  " BBM_NIVEL Nivel, "
   cSql +=  " BBM_TIPO Tipo "
   If lSTMP
      cSql +=  " ,BBM.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BBM") + " BBM "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BBM_FILIAL"+ cConc +" BBM_CODPAD"+ cConc +" BBM_CODPSA  AND BTU.D_E_L_E_T_ = ' ') "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BBM_CODPAD AND BTQ.BTQ_CODTAB = BBM_CODPAD AND BTQ.BTQ_CDTERM = BBM_CODPSA AND BTQ.D_E_L_E_T_ = ' ') "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BBM.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BBM.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BBM.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BBM.D_E_L_E_T_ = ' ' "
   Endif

   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BBM" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BBM", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BBM" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BBM"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BBM_SINTETICO
Executa query que cria view  HAT_LOAD_BBM_SINTETICO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function BBM_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BBM_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BBM_SINTETICO AS "
   Endif
   cSql +=  " SELECT BBM_ATIVO Ativo, "
   cSql +=  " BBM_CODESP CodigoEspecialidade, "
   cSql +=  " BBM_CDNV01 CodigoNivel01, "
   cSql +=  " BBM_CDNV02 CodigoNivel02, "
   cSql +=  " BBM_CDNV03 CodigoNivel03, "
   cSql +=  " BBM_CDNV04 CodigoNivel04, "
   cSql +=  " BBM_CODINT CodigoOperadora, "
   cSql +=  " BBM_CODPSA CodigoProcedimento, "
   If cDBType == "SQL"
      cSql +=  " LTRIM(BTU_CDTERM) CodigoTipoTabela, ""
   Else
      cSql +=  " TRIM(BTU_CDTERM) CodigoTipoTabela, "
   Endif
   cSql +=  " BBM_DATVAL DataValidade, "
   cSql +=  " BBM_NIVEL Nivel, "
   cSql +=  " BBM_TIPO Tipo "
   If lSTMP
      cSql +=  " ,BBM.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BBM") + " BBM "
   cSql +=  " JOIN " + RETSQLName("BA8") + " BA8 ON (BA8_FILIAL = '"  + xFILIAL("BA8") + "' AND BA8_CDPADP = BBM_CODPAD AND BA8_CODPRO = BBM_CODPSA AND BA8_ANASIN = '2') "
   If cDBType == "SQL"
      cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = BBM_CODPAD AND BTU.D_E_L_E_T_ = ' ') "
   Else
      cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87' AND TRIM(BTU_VLRBUS) = BBM_CODPAD AND BTU.D_E_L_E_T_ = ' ') "
   Endif
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BBM.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BBM.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BBM.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BBM.D_E_L_E_T_ = ' ' "
   Endif

   If cDBType == "SQL"
      cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
   Else
      cSql +=  " AND TRIM(BTU_VLRBUS) IS NOT NULL "
   Endif
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   cSql +=  " GROUP BY "
   cSql +=  " BBM_ATIVO, BBM_CODESP, BBM_CDNV01, BBM_CDNV02, BBM_CDNV03, BBM_CDNV04, "
   If cDBType = "SQL"
      cSql +=  " BBM_CODINT, BBM_CODPSA, LTRIM(BTU_CDTERM), BBM_DATVAL, BBM_NIVEL, BBM_TIPO "
   Else
      cSql +=  " BBM_CODINT, BBM_CODPSA, TRIM(BTU_CDTERM), BBM_DATVAL, BBM_NIVEL, BBM_TIPO "
   Endif
   If lSTMP
      cSql +=  " , BBM.D_E_L_E_T_ "
   Endif
   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BBM_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BBM_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BBM_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BBM_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BBN
Executa query que cria view  HAT_LOAD_BBN
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BBN(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BBN AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BBN AS "
   Endif
   cSql +=  " SELECT BBN_CODESP CodigoEspecialidade, "
   cSql +=  " BBN_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BBN_CDNV01 CodigoNivel01, "
   cSql +=  " BBN_CDNV02 CodigoNivel02, "
   cSql +=  " BBN_CDNV03 CodigoNivel03, "
   cSql +=  " BBN_CDNV04 CodigoNivel04, "
   cSql +=  " BBN_CODINT CodigoOperadora, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM)CodigoProcedimento, "
   Endif
   cSql +=  " BBN_CODIGO CodigoPrestador, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Else
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Endif
   cSql +=  " BBN_NIVEL Nivel "
      If lSTMP
      cSql +=  " ,BBN.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BBN") + " BBN "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BBN_FILIAL"+ cConc +" BBN_CODPAD"+ cConc +" BBN_CODPSA AND BTU.D_E_L_E_T_ = ' ' ) "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BBN_CODPAD AND BTQ.BTQ_CDTERM = BBN_CODPSA AND BTQ.D_E_L_E_T_ = ' ') "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BBN.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BBN.D_E_L_E_T_ = ' ' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BBN.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BBN.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BBN.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BBN" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BBN", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BBN" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BBN"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BBN_SINTETICO
Executa query que cria view HAT_LOAD_BBN_SINTETICO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function BBN_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BBN_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BBN_SINTETICO AS "
   Endif
   cSql +=  " SELECT BBN_CODESP CodigoEspecialidade, "
   cSql +=  " BBN_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BBN_CDNV01 CodigoNivel01, "
   cSql +=  " BBN_CDNV02 CodigoNivel02, "
   cSql +=  " BBN_CDNV03 CodigoNivel03, "
   cSql +=  " BBN_CDNV04 CodigoNivel04, "
   cSql +=  " BBN_CODINT CodigoOperadora, "
   cSql +=  " BBN_CODPSA CodigoProcedimento, "
   cSql +=  " BBN_CODIGO CodigoPrestador, "
   If cDBType == "SQL"
      cSql +=  " LTRIM(BTU_CDTERM) CodigoTipoTabela, "
   Else
      cSql +=  " TRIM(BTU_CDTERM) CodigoTipoTabela, "
   Endif
   cSql +=  " BBN_NIVEL Nivel "
   If lSTMP
      cSql +=  " ,BBN.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BBN") + " BBN "
   cSql +=  " JOIN " + RETSQLName("BA8") + " BA8 ON (BA8_FILIAL = '"  + xFILIAL("BA8") + "' AND BA8_CDPADP = BBN_CODPAD AND BA8_CODPRO = BBN_CODPSA AND BA8_ANASIN = '2') "
   If cDBType == "SQL"
      cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = BBN_CODPAD AND BTU.D_E_L_E_T_ = ' ') "
   Else
      cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87' AND TRIM(BTU_VLRBUS) = BBN_CODPAD AND BTU.D_E_L_E_T_ = ' ') "
   Endif
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BBN.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BBN.D_E_L_E_T_ = ' ' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BBN.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BBN.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BBN.D_E_L_E_T_ = ' ' "
   Endif
   If cDBType == "SQL"
      cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
   Else
      cSql +=  " AND TRIM(BTU_VLRBUS) IS NOT NULL"
   Endif
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   cSql +=  " GROUP BY "
   cSql +=  " BBN_CODESP, BBN_CODLOC, BBN_CDNV01, BBN_CDNV02, BBN_CDNV03, BBN_CDNV04, "
   If cDBType == "SQL"
      cSql +=  " BBN_CODINT, BBN_CODPSA, BBN_CODIGO, BBN_CODSUB, LTRIM(BTU.BTU_CDTERM), BBN_NIVEL "
   Else
      cSql +=  " BBN_CODINT, BBN_CODPSA, BBN_CODIGO, BBN_CODSUB, TRIM(BTU.BTU_CDTERM), BBN_NIVEL "
   Endif
   If lSTMP
      cSql +=  " , BBN.D_E_L_E_T_ "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BBN_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BBN_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BBN_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BBN_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BC0
Executa query que cria view  HAT_LOAD_BC0
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BC0(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BC0 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BC0 AS "
   Endif
   cSql +=  " SELECT ' ' AutorizacaoPrevia, "
   cSql +=  " BC0_CODESP CodigoEspecialidade, "
   cSql +=  " BC0_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BC0_CDNV01 CodigoNivel01, "
   cSql +=  " BC0_CDNV02 CodigoNivel02, "
   cSql +=  " BC0_CDNV03 CodigoNivel03, "
   cSql +=  " BC0_CDNV04 CodigoNivel04, "
   cSql +=  " BC0_CODINT CodigoOperadora, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
   Endif
   cSql +=  " BC0_CODIGO CodigoPrestador, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Else
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Endif
   cSql +=  " BC0_DATBLO DataBloqueio, "
   cSql +=  " BC0_NIVEL Nivel, "
   cSql +=  " BC0_TIPO Tipo, "
   cSql +=  " ' ' TipoPrestador, "
   cSql +=  " BC0_VIGATE VigenciaFinal, "
   cSql +=  " BC0_VIGDE VigenciaInicial "
   If lSTMP
      cSql +=  " ,BC0.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BC0") + " BC0 "
   cSql +=  " LEFT JOIN "  + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BC0_FILIAL "+ cConc +"BC0_CODPAD"+ cConc +" BC0_CODOPC AND BTU.D_E_L_E_T_ = ' ') "
   cSql +=  " LEFT JOIN "  + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BC0_CODPAD AND BTQ.BTQ_CDTERM = BC0_CODOPC AND BTQ.D_E_L_E_T_ = ' ' ) "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BC0.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BTU.D_E_L_E_T_ = ' ' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BC0.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BC0.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BC0.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL))"

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BC0" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BC0", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BC0" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BC0"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BC1
Executa query que cria view  HAT_LOAD_BC1
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BC1(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BC1 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BC1 AS "
   Endif
   cSql +=  " SELECT DISTINCT "
   cSql +=  " BC1_CODESP CodigoEspecialidade, "
   cSql +=  " BC1_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BC1_CODINT CodigoOperadora, "
   cSql +=  " BC1_CODIGO CodigoPrestador, "
   cSql +=  " BC1_CODPRF CodigoProfissional, "
   cSql +=  " BC1_ESTCR EstadoConselhoRegional, "
   cSql +=  " BC1_NOMPRF NomeProfissional, "
   cSql +=  " BC1_NUMCR NumeroConselho, "
   cSql +=  " BC1_SIGLCR SiglaConselho "
   If lSTMP
      cSql +=  " ,BC1.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BC1") + " BC1 "
   cSql +=  " INNER JOIN "  + RETSQLName("BB0") + " BB0 ON BC1_FILIAL = '"  + xFILIAL("BC1") + "' AND BC1_CODPRF = BB0_CODIGO "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BC1.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BB0.D_E_L_E_T_ = ' ' AND BC1_NUMCR <> ' ' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BC1.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND BC1_NUMCR <> ' ' "
      Else
         cSql +=  " WHERE BC1.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND BC1_NUMCR <> ' ' "
      Endif
   Else
      If cDBType == "SQL"
         cSql +=  " WHERE BC1.D_E_L_E_T_ = ' ' "
         cSql +=  " AND BC1_NUMCR <> ' ' "
      Else
         cSql +=  " AND BC1_NUMCR <> ' ' "
         cSql +=  " WHERE BC1.D_E_L_E_T_ = ' ' "
      Endif
   Endif
  
   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BC1" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BC1", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BC1" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BC1"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BCT
Executa query que cria view  HAT_LOAD_BCT
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BCT(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BCT AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BCT AS "
   Endif
   cSql +=  " SELECT BCT_ALERTA AlertaCritica,"
   cSql +=  " BCT_CODGLO CodigoGlosa, "
   cSql +=  " BCT_CODOPE CodigoOperadora, "
   cSql +=  " BCT_DESCRI Descricao, "
   cSql +=  " BCT_DESTIS DescricaoTISS, "
   cSql +=  " BCT_GLTISS GlosaTISS, "
   cSql +=  " BCT_LIBESP PermiteLibEspecial, "
   cSql +=  " BCT_PROPRI Proprietario, "
   cSql +=  " BCT_ATIVO Ativo "
   If lSTMP
      cSql +=  " ,BCT.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BCT") + " BCT "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BCT.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BCT.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BCT.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BCT.D_E_L_E_T_ = ' ' "
   Endif


   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BCT" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BCT", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BCT" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BCT"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BDL
Executa query que cria view  HAT_LOAD_BDL
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BDL(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BDL AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BDL AS "
   Endif
   cSql +=  " SELECT BDL_CARENC QuantidadeCarencia, "
   cSql +=  " BDL_CODIGO Codigo, "
   cSql +=  " BDL_CODINT CodigoOperadora, "
   cSql +=  " BDL_UNCAR UnidadeCarencia "
   If lSTMP
      cSql +=  " ,BDL.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BDL") + " BDL "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BDL.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BDL.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BDL.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BDL.D_E_L_E_T_ = ' ' "
   Endif


   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BDL" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BDL", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BDL" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BDL"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc}  HAT_LOAD_BDT
Executa query que cria view  HAT_LOAD_BDT
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BDT(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BDT AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BDT AS "
   Endif
   cSql +=  " SELECT BDT_CODINT CodigoOperadora, "
   cSql +=  " BDT_ANO Ano, "
   cSql +=  " BDT_MES Mes, "
   cSql +=  " BDT_DATINI DataInicial, "
   cSql +=  " BDT_DATFIN DataFinal, "
   cSql +=  " BDT_DATPRE DataPrevistaPagamento, "
   cSql +=  " BDT_CODDAT CodigoDataPagamento, "
   cSql +=  " BDT_DATPAG DataPagamento, "
   cSql +=  " BDT_REEMB Reembolso, "
   cSql +=  " BDT_CODRDA CodigoRda, "
   cSql +=  " BDT_DESRDA DescricaoRda "
   If lSTMP
      cSql +=  " ,BDT.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BDT") + " BDT "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BDT.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BDT.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BDT.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BDT.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BDT" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BDT", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BDT" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BDT"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BE4
Executa query que cria view  HAT_LOAD_BE4
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BE4(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BE4 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BE4 AS "
   Endif
   cSql +=  " SELECT BEA_ANOAUT AnoAutorizacao, "
   cSql +=  " BE4_ATERNA AtendimentoRecemNascido, "
   cSql +=  " BE4_CID CID, "
   cSql +=  " BE4_CODESP CodigoEspecialidade, "
   cSql +=  " BE4_MATRIC CodigoFamilia, "
   cSql +=  " BE4_CODEMP CodigoGrpEmpresa, "
   cSql +=  " BE4_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BE4_CODRDA CodigoPrestador, "
   cSql +=  " BE4_CDPFSO CodigoProfissionalSolicitante, "
   cSql +=  " BE4_TIPREG CodigoTipoBeneficiario, "
   cSql +=  " BE4_DTALTA DataAlta, "
   cSql +=  " BE4_DATPRO DataInternacao,  "
   cSql +=  " BEA_DATSOL DataSolicitacao, "
   cSql +=  " BE4_DATVAL DataValidade, "
   cSql +=  " CASE WHEN BE4_STATUS = '1' OR BE4_STATUS = '2' THEN BE4_DIASSO Else 0 END AS DiariasAutorizadas, "
   cSql +=  " BE4_DIASSO DiariasSolicitadas, "
   cSql +=  " BE4_DIGITO Digito, "
   cSql +=  " BE4_ESPSOL EspecialidadeSolicitante, "
   cSql +=  " BE4_ESTSOL EstadoSolicitante, "
   cSql +=  " BE4_GUIPRE GuiaPrestador, "
   cSql +=  " BE4_HRALTA HoraAlta, "
   cSql +=  " BE4_INDACI IndicacaoAcidente, "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BE4_INDCLI) + RTRIM(BE4_INDCL2) IndicacaoClinica, "
   Else
      cSql +=  " TRIM(BE4_INDCLI) || TRIM(BE4_INDCL2) IndicacaoClinica, "
   Endif
   cSql +=  " BE4_LOCAL  LocalAtendimento,  "
   cSql +=  " BEA_MESAUT MesAutorizacao, "
   cSql +=  " BE4_TIPALT MotivoAlta, "
   cSql +=  " BEA_NUMAUT NumeroAutorizacao, "
   If cDBType == "SQL"
      cSql +=  " CONCAT(BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT) NumeroGuiaOperadora, "
   Else
      cSql +=  " (BE4_CODOPE || BE4_ANOINT || BE4_MESINT || BE4_NUMINT) NumeroGuiaOperadora, "
   Endif
   cSql +=  " BE4_CODOPE OperadoraMovimentacao, "
   cSql +=  " BE4_OPEUSR OperadoraUsuario, "
   cSql +=  " BE4_PRVINT PrevisaoInternacao, "
   cSql +=  " BE4_PREOPE PrevisaoOpme, "
   cSql +=  " BE4_PREQUI PrevisaoQuimio, "
   cSql +=  " BE4_PROATE ProtocoloAtendimento, "
   cSql +=  " BE4_REGINT RegimeInternacao, "
   cSql +=  " BE4_REGSOL RegistroSolicitante, "
   cSql +=  " BE4_SENHA  Senha, "
   cSql +=  " BE4_SIGLA  SiglaConselho, "
   cSql +=  " BE4_STATUS Status, "
   cSql +=  " BE4_PADINT TipoAcomodacao, "
   cSql +=  " BE4_TIPADM TipoAdmissao, "
   cSql +=  " '4' TipoGuia,  "
   cSql +=  " BE4_TIPINT TipoInternacao "
   If lSTMP
      cSql +=  " ,BE4.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BE4") + " BE4 "
   cSql +=  " INNER JOIN " + RETSQLName("BEA") + " BEA ON (BEA_FILIAL = '"  + xFILIAL("BEA") + "' AND BEA_OPEMOV = BE4_CODOPE  AND BEA_ANOAUT = BE4_ANOINT AND BEA_MESAUT = BE4_MESINT AND BEA_NUMAUT = BE4_NUMINT)"
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BE4.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BE4_CODOPE = '0001' AND BE4_ORIMOV != '6' AND BE4_TIPGUI = '03' AND BE4.D_E_L_E_T_ = ' ' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BE4.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND BE4_CODOPE = '0001' AND BE4_ORIMOV != '6' AND BE4_TIPGUI = '03' AND BE4.D_E_L_E_T_ = ' ' "
      Else
         cSql +=  " WHERE BE4.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND BE4_CODOPE = '0001' AND BE4_ORIMOV != '6' AND BE4_TIPGUI = '03' AND BE4.D_E_L_E_T_ = ' ' "
      Endif
   Else
      cSql +=  " WHERE BE4_CODOPE = '0001' AND BE4_ORIMOV != '6' AND BE4_TIPGUI = '03' AND BE4.D_E_L_E_T_ = ' ' "
   Endif  

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BE4" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BE4", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BE4" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BE4"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BE6
Executa query que cria view  HAT_LOAD_BE6
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BE6(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BE6 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BE6 AS "
   Endif
   cSql +=  " SELECT BE6_CODIGO CodigoPrestador, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB)  CodigoTipoTabela, "
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM)  CodigoProcedimento, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
   Else
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
   Endif
   cSql +=  " BE6_CODPRF  CodigoProfissional, "
   cSql +=  " BE6_CODLOC  CodigoLocalAtendimento,  "
   cSql +=  " BE6_CODESP  CodigoEspecialidade "
   If lSTMP
      cSql +=  " ,BE6.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BE6") + " BE6 "
   cSql +=  " LEFT JOIN "  + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BE6_FILIAL "+ cConc +" BE6_CODPAD "+ cConc +" BE6_CODPRO AND BTU.D_E_L_E_T_ = ' ' )"
   cSql +=  " LEFT JOIN "  + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BE6_CODPAD AND BTQ.BTQ_CDTERM = BE6_CODPRO AND BTQ.D_E_L_E_T_ = ' ')"
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BE6.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BTU.D_E_L_E_T_ = ' ' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BE6.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND BE6.D_E_L_E_T_ = ' ' "
      Else
         cSql +=  " WHERE BE6.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND BE6.D_E_L_E_T_ = ' ' "
      Endif
   Else
      cSql +=  " WHERE BE6.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "


   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BE6" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BE6", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BE6" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BE6"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BE9
Executa query que cria view  HAT_LOAD_BE9
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BE9(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BE9 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BE9 AS "
   Endif
   cSql +=  " SELECT BE9_CODIGO AS CodigoPrestador, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodTipTabela, "
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodProced, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) AS CodTipTabela, "
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) AS CodProced, "
   Else
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) AS CodTipTabela, "
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) AS CodProced, "
   Endif
   cSql +=  " BE9_NIVEL AS Nivel, "
   cSql +=  " BE9_ATIVO AS Ativo, "
   cSql +=  " BE9_CODPLA AS CodigoPlano, "
   cSql +=  " BE9_CODLOC AS CodigoLocalAtendimento, "
   cSql +=  " BE9_CODINT AS CodigoOperadora, "
   cSql +=  " BE9_CODESP AS CodigoEspecialidade, "
   cSql +=  " BE9_CODGRU AS CodigoGrupoCobertura , "
   cSql +=  " BE9_URG AS AtendUrg, "
   cSql +=  " BE9_ELET AS AtendEletivo, "
   cSql +=  " BE9_PF AS AtendeContrPF, "
   cSql +=  " BE9_PJ AS AtendeContrPJ, "
   cSql +=  " BE9_VIGDE AS VigenciaInicial, "
   cSql +=  " BE9_VIGATE AS VigenciaFinal, "
   cSql +=  " BE9_ATEINT AS AtendInterno, "
   cSql +=  " BE9_ATEEXT AS AtendExterno "
   If lSTMP
      cSql +=  " ,BE9.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BE9") + " BE9 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BE9_FILIAL "+ cConc +" BE9_CODPAD "+ cConc +" BE9_CODPRO AND BTU.D_E_L_E_T_ = ' ' ) "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BE9_CODPAD AND BTQ.BTQ_CDTERM = BE9_CODPRO  AND BTQ.D_E_L_E_T_ = ' ') "
   cSql +=  " WHERE "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " BE9.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " BE9.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND "
      Else
         cSql +=  " BE9.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND "
      Endif
   Endif
   cSql +=  " (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "
   If lSTMP 
      If cDBType == "SQL"
         cSql +=  "AND BTU.D_E_L_E_T_ = ' ' AND BTQ.D_E_L_E_T_ = ' '"
      Endif
   Else
      cSql +=  " AND BE9.D_E_L_E_T_ = ' '
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BE9" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BE9", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BE9" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BE9"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc}  HAT_LOAD_BEA
Executa query que cria view  HAT_LOAD_BEA
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BEA(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BEA AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BEA AS "
   Endif
   cSql +=  " SELECT BEA_ANOAUT AS AnoAutorizacao, "
   cSql +=  " BEA_ATERNA AS AtendimentoRecemNascido, "
   cSql +=  " BEA_AUDITO AS Auditoria, "
   cSql +=  " BEA_CANCEL AS Cancelado, "
   cSql +=  " BEA_CANEDI AS CancelamentoEDI, "
   cSql +=  " BEA_MATRIC AS CodigoFamilia, "
   cSql +=  " BEA_CODEMP AS CodigoGrpEmpresa, "
   cSql +=  " BEA_CODLOC AS CodigoLocalAtendimento, "
   cSql +=  " BEA_CDPFRE AS CodigoProfissionalResponsavel, "
   cSql +=  " BEA_CDPFSO AS CodigoProfissionalSolicitante, "
   cSql +=  " BEA_CODRDA AS CodigoPrestador, "
   cSql +=  " BEA_TIPREG AS CodigoTipoBeneficiario, "
   cSql +=  " BEA_TIPSAI AS CodigoTipoSaida, "
   cSql +=  " BEA_DATPRO AS DataProcessamento, "
   cSql +=  " BEA_DATSOL AS DataSolicitacao, "
   cSql +=  " BEA_ESPEXE AS EspecialidadeExecutante, "
   cSql +=  " BEA_ESPSOL AS EspecialidadeSolicitante, "
   cSql +=  " BEA_ESTEXE AS EstadoExecutante, "
   cSql +=  " BEA_ESTSOL AS EstadoSolicitante, "
   cSql +=  " BEA_INDACI AS IndicacaoAcidente, "
   If cDBType == "SQL"
      cSql +=  " BEA_INDCLI AS IndicacaoClinica, "
   Else
      cSql +=  " REPLACE(BEA_INDCLI,CHR(10),'') AS IndicacaoClinica, "
   Endif
   cSql +=  " BEA_LIBERA AS Liberacao, "
   cSql +=  " BEA_LOCAL AS LocalAtendimento, "
   cSql +=  " BEA_MESAUT AS MesAutorizacao, "
   cSql +=  " BEA_NUMAUT AS NumeroAutorizacao, "
   cSql +=  " BEA_GUIPRI AS NumeroGuiaPrincipal, "
   cSql +=  " BEA_NRLBOR AS NumeroLiberacaoOriginal, "
   cSql +=  " BEA_NUMTIT AS NumeroTituloContasRec, "
   cSql +=  " BEA_OPEMOV AS OperadoraMovimentacao, "
   cSql +=  " BEA_OPEUSR AS OperadoraUsuario, "
   cSql +=  " BEA_PARCEL AS Parcela, "
   cSql +=  " BEA_PREFIX AS Prefixo, "
   cSql +=  " BEA_PROATE AS ProtocoloAtendimento, "
   cSql +=  " BEA_REGEXE AS RegistroExecutante, "
   cSql +=  " BEA_REGSOL AS RegistroSolicitante, "
   cSql +=  " BEA_SENHA AS Senha, "
   cSql +=  " BEA_SIGLA AS SiglaConselho, "
   cSql +=  " BEA_SIGEXE AS SiglaConselhoExecutante, "
   cSql +=  " BEA_STATUS AS Status, "
   cSql +=  " BEA_STALIB AS StatusLiberacao, "
   cSql +=  " BEA_STTISS AS StatusTISS, "
   cSql +=  " BEA_TIPADM AS TipoAdmissao, "
   cSql +=  " BEA_TIPATE AS TipoAtendimento, "
   cSql +=  " BEA_TIPCON AS TipoConsulta, "
   cSql +=  " CASE WHEN BEA_TIPO = '4' THEN '9' Else BEA_TIPO END AS TipoGuia,"
   cSql +=  " BEA_TIPTIT AS TipoTituloContasRec, "
   cSql +=  " BEA_VALSEN AS ValidadeSenhaAtendimento, "
   If cDBType == "SQL"
      cSql +=  " CONCAT(BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT) AS NumeroGuiaOperadora "
   Else
      cSql +=  " (BEA_OPEMOV || BEA_ANOAUT || BEA_MESAUT || BEA_NUMAUT) AS NumeroGuiaOperadora "
   Endif
   If lSTMP
      cSql +=  " ,BEA.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BEA") + " BEA "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BEA.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BEA_OPEMOV = '0001'AND BEA_ORIMOV != '6' AND BEA_TIPGUI != '3' AND BEA_LIBERA = '1'  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BEA.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND BEA_OPEMOV = '0001'AND BEA_ORIMOV != '6' AND BEA_TIPGUI != '3' AND BEA_LIBERA = '1'AND BEA.D_E_L_E_T_ = ' '  "
      Else
         cSql +=  " WHERE BEA.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND BEA_OPEMOV = '0001'AND BEA_ORIMOV != '6' AND BEA_TIPGUI != '3' AND BEA_LIBERA = '1'AND BEA.D_E_L_E_T_ = ' ' "
      Endif
   Else
      cSql +=  " WHERE BEA_OPEMOV = '0001'AND BEA_ORIMOV != '6' AND BEA_TIPGUI != '3' AND BEA_LIBERA = '1'AND BEA.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BEA" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BEA", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BEA" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BEA"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BF1
Executa query que cria view  HAT_LOAD_BF1
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BF1(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BF1 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BF1 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BF1_CODINT AS CodOperadora, "
   cSql +=  " BF1_CODEMP AS CodEmpresa, "
   cSql +=  " BF1_MATRIC AS Matricula, "
   cSql +=  " BF1_CODPRO AS CodProduto, "
   cSql +=  " BF1_VERSAO AS VersaoProduto, "
   cSql +=  " BF1_DATBAS AS DtBase, "
   cSql +=  " BF1_MOTBLO AS MotivoBloqueio, "
   cSql +=  " BF1_DATBLO AS DtBloqueio, "
   cSql +=  " BF1_TIPVIN AS TipoVinculo "
   If lSTMP
      cSql +=  " ,BF1.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BF1") + " BF1 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BF1.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BF1.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BF1.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR)  "
      Endif
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BF1" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BF1", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BF1" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BF1"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BFC
Executa query que cria view HAT_LOAD_BFC
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BFC(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BFC AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BFC AS "
   Endif
   cSql +=  " SELECT
   cSql +=  " BFC_CODINT AS CodigoOperadora, "
   cSql +=  " BFC_CODEMP AS CodigoGrpEmpresa, "
   cSql +=  " BFC_MATRIC AS CodigoFamilia, "
   cSql +=  " BFC_CODGRU AS CodigoGrupoCobertura "
   If lSTMP
      cSql +=  " ,BFC.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BFC") + " BFC "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BFC.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BFC.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BFC.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR)  "
      Endif
   Else
      cSql +=  " WHERE BFC.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BF6" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BF6", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BF6" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BF6"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BFD
Executa query que cria view HAT_LOAD_BFD
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BFD(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BFD AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BFD AS "
   Endif
   cSql +=  " SELECT BFD_CODINT  AS CodOperadora, "
   cSql +=  " BFD_CODEMP  AS CodEmpresa, "
   cSql +=  " BFD_MATRIC  AS MatricFamilia, "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BTU_CODTAB) AS CodTabela, "
      cSql +=  " RTRIM(BTU_CDTERM) AS CodProcedimento, "
   Else
      cSql +=  " TRIM(BTU_CODTAB) AS CodTabela, "
      cSql +=  " TRIM(BTU_CDTERM) AS CodProcedimento, "
   Endif
   cSql +=  " BFD_BENUTL AS Ativo, "
   cSql +=  " BFD_NIVEL AS Nivel, "
   cSql +=  " BFD_AUTORI AS TipoAutori, "
   cSql +=  " BFD_SEXO AS Genero, "
   cSql +=  " BFD_CARENC AS Carencia, "
   cSql +=  " BFD_UNCAR AS UnidCarenc, "
   cSql +=  " BFD_NIVCAR AS NivelCarenc, "
   cSql +=  " BFD_QTD AS Quantidade, "
   cSql +=  " BFD_UNCA AS UnidQtd, "
   cSql +=  " BFD_PERIOD AS Periodicidade, "
   cSql +=  " BFD_UNPERI AS unidPeriod, "
   cSql +=  " BFD_IDAMIN AS IdadeMin, "
   cSql +=  " BFD_UNIMIN AS UnidIdadeMin, "
   cSql +=  " BFD_IDAMAX AS IdadeMax, "
   cSql +=  " BFD_UNIMAX AS UnidIdadeMax, "
   cSql +=  " BFD_CDNV01 AS Nivel01, "
   cSql +=  " BFD_CDNV02 AS Nivel02, "
   cSql +=  " BFD_CDNV03 AS Nivel03, "
   cSql +=  " BFD_CDNV04 AS Nivel04, "
   cSql +=  " BFD_CLACAR AS ClasseCarenc "
   If lSTMP
      cSql +=  " ,BFD.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BFD") + " BFD "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU_CODTAB = '87') "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BFD.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BFD.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BFD.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR)  "
      Endif
   Else
      cSql +=  " WHERE BFD.D_E_L_E_T_ = ' ' "
   Endif
   If cDBType == "SQL"
      cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
   Else
      cSql +=  " AND TRIM(BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " GROUP BY "
   cSql +=  " BFD_CODINT,BFD_CODEMP,BFD_MATRIC, "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BTU_CODTAB),RTRIM(BTU_CDTERM),BFD_BENUTL,BFD_NIVEL,BFD_AUTORI,BFD_SEXO,BFD_CARENC,BFD_UNCAR, "
   Else
      cSql +=  " TRIM(BTU_CODTAB),TRIM(BTU_CDTERM),BFD_BENUTL,BFD_NIVEL,BFD_AUTORI,BFD_SEXO,BFD_CARENC,BFD_UNCAR, "
   Endif
   cSql +=  " BFD_NIVCAR,BFD_QTD,BFD_UNCA,BFD_PERIOD,BFD_UNPERI,BFD_IDAMIN,BFD_UNIMIN,BFD_IDAMAX,BFD_UNIMAX,BFD_CDNV01,BFD_CDNV02,BFD_CDNV03,BFD_CDNV04,BFD_CLACAR "
   If lSTMP
      cSql +=  " , BFD.D_E_L_E_T_ "
   Endif
   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BFD" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BFD", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BFD" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BFD"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BFE
Executa query que cria view HAT_LOAD_BFE
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BFE(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BFE AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BFE AS "
   Endif
   cSql +=  " SELECT BFE_MATRIC AS CodigoFamilia, "
   cSql +=  " BFE_CODEMP AS CodigoGrpEmpresa, "
   cSql +=  " BFE_CODGRU AS CodigoGrupoCobertura, "
   cSql +=  " BFE_CODINT AS CodigoOperadora, "
   cSql +=  " BFE_TIPREG AS CodigoTipoBeneficiario, "
   cSql +=  " BFE_DATCAR AS DataCarencia "
   If lSTMP
      cSql +=  " ,BFE.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BFE") + " BFE "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BFE.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BFE.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BFE.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR)  "
      Endif
   Else
      cSql +=  " WHERE BFE.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BFE" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BFE", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BFE" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BFE"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BFG
Executa query que cria view HAT_LOAD_BFG
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BFG(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BFG AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BFG AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " RTRIM(ISNULL(BTU_CDTERM, BTQ_CDTERM)) AS CodigoProcedimento, "
      cSql +=  " RTRIM(ISNULL(BTU_CODTAB, BTQ_CODTAB)) AS CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " TRIM(coalesce(BTU_CDTERM, BTQ_CDTERM)) AS CodigoProcedimento, "
      cSql +=  " TRIM(coalesce(BTU_CODTAB, BTQ_CODTAB)) AS CodigoTipoTabela, "
   Else
      cSql +=  " TRIM(NVL(BTU_CDTERM, BTQ_CDTERM)) AS CodigoProcedimento, "
      cSql +=  " TRIM(NVL(BTU_CODTAB, BTQ_CODTAB)) AS CodigoTipoTabela, "
   Endif
   cSql +=  " BFG_BENUTL AS Ativo, "
   cSql +=  " BFG_CARENC AS QuantidadeCarencia, "
   cSql +=  " BFG_CLACAR AS ClasseCarencia, "
   cSql +=  " BFG_MATRIC AS CodigoFamilia, "
   cSql +=  " BFG_CODEMP AS CodigoGrpEmpresa, "
   cSql +=  " BFG_CDNV01 AS CodigoNivel01, "
   cSql +=  " BFG_CDNV02 AS CodigoNivel02, "
   cSql +=  " BFG_CDNV03 AS CodigoNivel03, "
   cSql +=  " BFG_CDNV04 AS CodigoNivel04, "
   cSql +=  " BFG_CODINT AS CodigoOperadora, "
   cSql +=  " BFG_TIPREG AS CodigoTipoBeneficiario, "
   cSql +=  " BFG_DATCAR AS DataCarencia, "
   cSql +=  " BFG_SEXO AS Genero, "
   cSql +=  " BFG_IDAMAX AS IdadeMaxima, "
   cSql +=  " BFG_IDAMIN AS IdadeMinima, "
   cSql +=  " BFG_NIVEL AS Nivel, "
   cSql +=  " BFG_NIVCAR AS NivelCarencia, "
   cSql +=  " BFG_PERIOD AS Periodicidade, "
   cSql +=  " BFG_QTD AS Quantidade, "
   cSql +=  " BFG_AUTORI AS TipoAutorizacao, "
   cSql +=  " BFG_UNCAR AS UnidadeCarencia, "
   cSql +=  " BFG_UNPERI AS UnidadePeriodicidade, "
   cSql +=  " BFG_UNCA AS UnidadeQuantidade, "
   cSql +=  " BFG_UNIMAX AS UnidIdadeMax, "
   cSql +=  " BFG_UNIMIN AS UnidIdadeMin "
   If lSTMP
      cSql +=  " , BFG.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BFG") + " BFG "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BFG_FILIAL "+ cConc +" BFG_CODPAD "+ cConc +" BFG_CODPSA AND BTU.D_E_L_E_T_ = ' ' ) "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BFG_CODPAD AND BTQ.BTQ_CDTERM = BFG_CODPSA AND BTQ.D_E_L_E_T_ = ' ' ) "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BFG.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BFG.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
      Else
         cSql +=  " WHERE BFG.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BFG.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BFG" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BFG", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BFG" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BFG"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BFG_SINTETICO
Executa query que cria view HAT_LOAD_BFG_SINTETICO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function BFG_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BFG_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BFG_SINTETICO AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BFG_CODPSA) AS CodigoProcedimento, "
      cSql +=  " RTRIM(BTU_CDTERM) AS CodigoTipoTabela, "
   Else
      cSql +=  " BFG_CODPSA AS CodigoProcedimento, "
      cSql +=  " TRIM(BTU_CDTERM) AS CodigoTipoTabela, "
   Endif
   cSql +=  " BFG_BENUTL AS Ativo, "
   cSql +=  " BFG_CARENC AS QuantidadeCarencia, "
   cSql +=  " BFG_CLACAR AS ClasseCarencia, "
   cSql +=  " BFG_MATRIC AS CodigoFamilia, "
   cSql +=  " BFG_CODEMP AS CodigoGrpEmpresa, "
   cSql +=  " BFG_CDNV01 AS CodigoNivel01, "
   cSql +=  " BFG_CDNV02 AS CodigoNivel02, "
   cSql +=  " BFG_CDNV03 AS CodigoNivel03, "
   cSql +=  " BFG_CDNV04 AS CodigoNivel04, "
   cSql +=  " BFG_CODINT AS CodigoOperadora, "
   cSql +=  " BFG_TIPREG AS CodigoTipoBeneficiario, "
   cSql +=  " BFG_DATCAR AS DataCarencia, "
   cSql +=  " BFG_SEXO AS Genero, "
   cSql +=  " BFG_IDAMAX AS IdadeMaxima, "
   cSql +=  " BFG_IDAMIN AS IdadeMinima, "
   cSql +=  " BFG_NIVEL AS Nivel, "
   cSql +=  " BFG_NIVCAR AS NivelCarencia, "
   cSql +=  " BFG_PERIOD AS Periodicidade, "
   cSql +=  " BFG_QTD AS Quantidade, "
   cSql +=  " BFG_AUTORI AS TipoAutorizacao, "
   cSql +=  " BFG_UNCAR AS UnidadeCarencia, "
   cSql +=  " BFG_UNPERI AS UnidadePeriodicidade, "
   cSql +=  " BFG_UNCA AS UnidadeQuantidade, "
   cSql +=  " BFG_UNIMAX AS UnidIdadeMax, "
   cSql +=  " BFG_UNIMIN AS UnidIdadeMin "
   If lSTMP
      cSql +=  " ,BFG.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BFG") + " BFG "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON BTU_CODTAB = '87' "
   If cDBType == "SQL"
      cSql +=  " AND LTRIM(BTU_VLRBUS) = BFG_CODPAD "
   Else
      cSql +=  " AND TRIM(BTU_VLRBUS) = BFG_CODPAD "
   Endif
    If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BFG.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BFG.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BFG.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BFG.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   cSql +=  " GROUP BY "
   cSql +=  " BTU_CDTERM,BFG_CODPSA,BFG_BENUTL,BFG_CARENC,BFG_CLACAR,BFG_MATRIC,BFG_CODEMP, "
   cSql +=  " BFG_CDNV01,BFG_CDNV02,BFG_CDNV03,BFG_CDNV04,BFG_CODINT,BFG_TIPREG,BFG_DATCAR, "
   cSql +=  " BFG_SEXO,BFG_IDAMAX,BFG_IDAMIN,BFG_NIVEL,BFG_NIVCAR,BFG_PERIOD,BFG_QTD, "
   cSql +=  " BFG_AUTORI,BFG_UNCAR,BFG_UNPERI,BFG_UNCA,BFG_UNIMAX,BFG_UNIMIN "
   If lSTMP
      cSql +=  " , BFG.D_E_L_E_T_ "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BFG_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BFG_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BFG_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BFG_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BFJ
Executa query que cria view HAT_LOAD_BFJ
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BFJ(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BFJ AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BFJ AS "
   Endif
   cSql +=  " SELECT BFJ_CARENC AS QuantidadeCarencia, "
   cSql +=  " BFJ_CLACAR AS ClasseCarencia, "
   cSql +=  " BFJ_MATRIC AS CodigoFamilia, "
   cSql +=  " BFJ_CODEMP AS CodigoGrpEmpresa, "
   cSql +=  " BFJ_CODINT AS CodigoOperadora, "
   cSql +=  " BFJ_UNICAR AS UnidadeCarencia "
   If lSTMP
      cSql +=  " ,BFJ.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BFJ") + " BFJ "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BFJ.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BFJ.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BFJ.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BFJ.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BFJ" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BFJ", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BFJ" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BFJ"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BFO
Executa query que cria view HAT_LOAD_BFO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BFO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BFO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BFO AS "
   Endif
   cSql +=  " SELECT BFO_CARENC AS QuantidadeCarencia,  "
   cSql +=  " BFO_CLACAR AS ClasseCarencia, "
   cSql +=  " BFO_MATRIC AS CodigoFamilia, "
   cSql +=  " BFO_CODEMP AS CodigoGrpEmpresa, "
   cSql +=  " BFO_CODINT AS CodigoOperadora, "
   cSql +=  " BFO_TIPREG AS CodigoTipoBeneficiario, "
   cSql +=  " BFO_DATCAR AS DataCarencia, "
   cSql +=  " BFO_UNICAR AS UnidadeCarencia "
   If lSTMP
      cSql +=  " ,BFO.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BFO") + " BFO "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BFO.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BFO.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BFO.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR)  "
      Endif
   Else
      cSql +=  " WHERE BFO.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BFO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BFO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BFO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BFO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BFP
Executa query que cria view HAT_LOAD_BFP
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BFP(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BFP AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BFP AS "
   Endif
   cSql +=  " SELECT BFP_CODINT  AS CodigoOperadora, "
   cSql +=  " BFP_CODESP  AS CodigoEspecialidade, "
   cSql +=  " BFP_CODSUB  AS CodSubEspecialidade, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) AS CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) AS CodigoProcedimento, "
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) AS CodigoProcedimento, "
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela, "
   Endif
   cSql +=  " BFP_NIVEL   AS Nivel, "
   cSql +=  " BFP_TIPO    AS Tipo, "
   cSql +=  " BFP_DATVAL  AS DataValidade, "
   cSql +=  " BFP_ATIVO   AS Ativo, "
   cSql +=  " BFP_CDNV01  AS CodigoNivel01, "
   cSql +=  " BFP_CDNV02  AS CodigoNivel02, "
   cSql +=  " BFP_CDNV03  AS CodigoNivel03, "
   cSql +=  " BFP_CDNV04  AS CodigoNivel04 "
   If lSTMP
      cSql +=  " ,BFP.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BFP") + " BFP "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BFP_FILIAL "+ cConc +" BFP_CODPAD "+ cConc +" BFP_CODPSA AND BTU.D_E_L_E_T_ = ' ' ) "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BFP_CODPAD AND BTQ.BTQ_CDTERM = BFP_CODPSA AND BTQ.D_E_L_E_T_ = ' ') "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BFP.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BFP.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BFP.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BFP.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98'))
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98'))
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL))

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BFP" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BFP", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BFP" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BFP"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BFP_SINTETICO
Executa query que cria view HAT_LOAD_BFP_SINTETICO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function BFP_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BFP_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BFP_SINTETICO AS "
   Endif
   cSql +=  " SELECT BFP_CODINT  AS CodigoOperadora, "
   cSql +=  " BFP_CODESP  AS CodigoEspecialidade, "
   cSql +=  " BFP_CODSUB  AS CodSubEspecialidade, "
   cSql +=  " BFP_CODPSA AS CodigoProcedimento, "
   cSql +=  " LTRIM(BTU_CDTERM) AS CodigoTipoTabela, "
   cSql +=  " BFP_NIVEL   AS Nivel, "
   cSql +=  " BFP_TIPO    AS Tipo, "
   cSql +=  " BFP_DATVAL  AS DataValidade, "
   cSql +=  " BFP_ATIVO   AS Ativo, "
   cSql +=  " BFP_CDNV01  AS CodigoNivel01, "
   cSql +=  " BFP_CDNV02  AS CodigoNivel02, "
   cSql +=  " BFP_CDNV03  AS CodigoNivel03, "
   cSql +=  " BFP_CDNV04  AS CodigoNivel04 "
   If lSTMP
      cSql +=  " ,BFP.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BFP") + " BFP "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = BFP_CODPAD "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BFP.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BFP.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BFP.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BFP.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BFP_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BFP_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BFP_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BFP_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BG7
Executa query que cria view HAT_LOAD_BG7
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BG7(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BG7 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BG7 AS "
   Endif
   cSql +=  " SELECT BG7_CODGRU AS CodigoGrupoCobertura, "
   cSql +=  " BG7_GRUVIN AS CodigoGrupoPrincipal, "
   cSql +=  " BG7_CODINT AS CodigoOperadora, "
   cSql +=  " BG7_DESCRI AS Descricao "
   If lSTMP
      cSql +=  " ,BG7.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BG7") + " BG7 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BG7.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BG7.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BG7.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BG7.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BG7" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BG7", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BG7" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BG7"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BG8
Executa query que cria view HAT_LOAD_BG8
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BG8(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BG8 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BG8 AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) AS CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) AS CodigoProcedimento, "
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) AS CodigoProcedimento, "
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) AS CodigoTipoTabela, "
   Endif
   cSql +=  " BG8_BENUTL Ativo, "
   cSql +=  " BG8_CARENC QuantidadeCarencia, "
   cSql +=  " BG8_CLACAR ClasseCarencia, "
   cSql +=  " BG8_CODGRU CodigoGrupoCobertura, "
   cSql +=  " BG8_CDNV01 CodigoNivel01, "
   cSql +=  " BG8_CDNV02 CodigoNivel02, "
   cSql +=  " BG8_CDNV03 CodigoNivel03, "
   cSql +=  " BG8_CDNV04 CodigoNivel04, "
   cSql +=  " BG8_CODINT CodigoOperadora, "
   cSql +=  " BG8_SEXO Genero, "
   cSql +=  " BG8_IDAMAX IdadeMaxima, "
   cSql +=  " BG8_IDAMIN IdadeMinima, "
   cSql +=  " BG8_NIVEL Nivel, "
   cSql +=  " BG8_NIVCAR NivelCarencia, "
   cSql +=  " BG8_PERIOD Periodicidade, "
   cSql +=  " BG8_PTRESP PeriodoEspecialidade, "
   cSql +=  " BG8_PTRPAT PeriodoPatologia, "
   cSql +=  " BG8_PTRMED PeriodoPrestador, "
   cSql +=  " BG8_QTDESP QuantidadeEspecialidade, "
   cSql +=  " BG8_QTDPAT QuantidadePatologia, "
   cSql +=  " BG8_QTD QuantidadePermitida, "
   cSql +=  " BG8_QTDMED QuantidadePrestador, "
   cSql +=  " BG8_AUTORI TipoAutorizacao, "
   cSql +=  " BG8_UNCAR UnidadeCarencia, "
   cSql +=  " BG8_UNPERI UnidadePeriodicidade, "
   cSql +=  " BG8_UNCA UnidadeQuantidade "
   If lSTMP
      cSql +=  " ,BG8.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BG8") + " BG8 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BG8_FILIAL "+ cConc +" BG8_CODPAD "+ cConc +" BG8_CODPSA AND BTU.D_E_L_E_T_ = ' ' ) "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BG8_CODPAD AND BTQ.BTQ_CDTERM = BG8_CODPSA AND BTQ.D_E_L_E_T_ = ' ' ) "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BG8.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BG8.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BG8.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BG8.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL))"


   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BG8" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BG8", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BG8" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BG8"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BG8_SINTETICO
Executa query que cria view HAT_LOAD_BG8_SINTETICO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function BG8_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BG8_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BG8_SINTETICO AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BG8_CODPSA AS CodigoProcedimento, "
   cSql +=  " LTRIM(BTU_CDTERM) AS CodigoTipoTabela, "
   cSql +=  " BG8_BENUTL Ativo, "
   cSql +=  " BG8_CARENC QuantidadeCarencia, "
   cSql +=  " BG8_CLACAR ClasseCarencia, "
   cSql +=  " BG8_CODGRU CodigoGrupoCobertura , "
   cSql +=  " BG8_CDNV01 CodigoNivel01 , "
   cSql +=  " BG8_CDNV02 CodigoNivel02 , "
   cSql +=  " BG8_CDNV03 CodigoNivel03 , "
   cSql +=  " BG8_CDNV04 CodigoNivel04 , "
   cSql +=  " BG8_CODINT CodigoOperadora , "
   cSql +=  " BG8_SEXO   Genero , "
   cSql +=  " BG8_IDAMAX IdadeMaxima , "
   cSql +=  " BG8_IDAMIN IdadeMinima , "
   cSql +=  " BG8_NIVEL  Nivel , "
   cSql +=  " BG8_NIVCAR NivelCarencia , "
   cSql +=  " BG8_PERIOD Periodicidade , "
   cSql +=  " BG8_PTRESP PeriodoEspecialidade , "
   cSql +=  " BG8_PTRPAT PeriodoPatologia , "
   cSql +=  " BG8_PTRMED PeriodoPrestador , "
   cSql +=  " BG8_QTDESP QuantidadeEspecialidade , "
   cSql +=  " BG8_QTDPAT QuantidadePatologia , "
   cSql +=  " BG8_QTD    QuantidadePermitida  , "
   cSql +=  " BG8_QTDMED QuantidadePrestador , "
   cSql +=  " BG8_AUTORI TipoAutorizacao , "
   cSql +=  " BG8_UNCAR  UnidadeCarencia , "
   cSql +=  " BG8_UNPERI UnidadePeriodicidade , "
   cSql +=  " BG8_UNCA   UnidadeQuantidade "
   If lSTMP
      cSql +=  " ,BG8.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BG8") + " BG8 "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = BG8_CODPAD "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BG8.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
         cSql +=  " GROUP BY "
         cSql +=  " BTU_CDTERM,BG8_CODPSA,BG8_BENUTL,BG8_CARENC,BG8_CLACAR,BG8_CODGRU,BG8_CDNV01, "
         cSql +=  " BG8_CDNV02,BG8_CDNV03,BG8_CDNV04,BG8_CODINT,BG8_SEXO,BG8_IDAMAX,BG8_IDAMIN, "
         cSql +=  " BG8_NIVEL,BG8_NIVCAR,BG8_PERIOD,BG8_PTRESP,BG8_PTRPAT,BG8_PTRMED,BG8_QTDESP, "
         cSql +=  " BG8_QTDPAT,BG8_QTD,BG8_QTDMED,BG8_AUTORI,BG8_UNCAR,BG8_UNPERI,BG8_UNCA "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BG8.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
         cSql +=  " GROUP BY "
         cSql +=  " BTU_CDTERM,BG8_CODPSA,BG8_BENUTL,BG8_CARENC,BG8_CLACAR,BG8_CODGRU,BG8_CDNV01, "
         cSql +=  " BG8_CDNV02,BG8_CDNV03,BG8_CDNV04,BG8_CODINT,BG8_SEXO,BG8_IDAMAX,BG8_IDAMIN, "
         cSql +=  " BG8_NIVEL,BG8_NIVCAR,BG8_PERIOD,BG8_PTRESP,BG8_PTRPAT,BG8_PTRMED,BG8_QTDESP, "
         cSql +=  " BG8_QTDPAT,BG8_QTD,BG8_QTDMED,BG8_AUTORI,BG8_UNCAR,BG8_UNPERI,BG8_UNCA "
      Else
         cSql +=  " WHERE BG8.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
         cSql +=  " GROUP BY "
         cSql +=  " BTU_CDTERM,BG8_CODPSA,BG8_BENUTL,BG8_CARENC,BG8_CLACAR,BG8_CODGRU,BG8_CDNV01, "
         cSql +=  " BG8_CDNV02,BG8_CDNV03,BG8_CDNV04,BG8_CODINT,BG8_SEXO,BG8_IDAMAX,BG8_IDAMIN, "
         cSql +=  " BG8_NIVEL,BG8_NIVCAR,BG8_PERIOD,BG8_PTRESP,BG8_PTRPAT,BG8_PTRMED,BG8_QTDESP, "
         cSql +=  " BG8_QTDPAT,BG8_QTD,BG8_QTDMED,BG8_AUTORI,BG8_UNCAR,BG8_UNPERI,BG8_UNCA "
      Endif
   Else
      cSql +=  " WHERE BG8.D_E_L_E_T_ = ' ' "
      cSql +=  " AND LTRIM(BTU.BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
   Endif
   If lSTMP
      cSql +=  " , BG8.D_E_L_E_T_ "
   Endif
   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BG8_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BG8_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BG8_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BG8_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BG9
Executa query que cria view HAT_LOAD_BG9
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BG9(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BG9 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BG9 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BG9_CODCLI CodigoCliente, "
   cSql +=  " BG9_CODIGO CodigoGrpEmpresa, "
   cSql +=  " BG9_LOJA CodigoLoja, "
   cSql +=  " BG9_CODINT CodigoOperadora, "
   cSql +=  " BG9_DIASIN DiasInadimplencia "
   If lSTMP
      cSql +=  " ,BG9.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BG9") + " BG9 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BG9.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BG9.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BG9.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BG9.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BG9" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BG9", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BG9" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BG9"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BI3
Executa query que cria view HAT_LOAD_BI3
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BI3(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BI3 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BI3 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BI3_ALLRED TodasRDA, "
   cSql +=  " BI3_VERSAO Versao, "
   cSql +=  " BI3_CODINT CodOperadora, "
   cSql +=  " BI3_CODIGO Codigo, "
   cSql +=  " BI3_DESCRI Descricao, "
   cSql +=  " BI3_GRUPO  GrupoProduto, "
   cSql +=  " BI3_TODOS  TodosProced, "
   cSql +=  " BI3_CODSEG Segmentacao, "
   cSql +=  " BI3_CODACO Acomodacao, "
   cSql +=  " BI3_ABRANG Abrangencia, "
   cSql +=  " BI3_INFCOB InforCobertura, "
   cSql +=  " BI3_INFGCB InforGrpCobertura "
   If lSTMP
      cSql +=  " ,BI3.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BI3") + " BI3 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BI3.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BI3.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BI3.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BI3.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BI3" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BI3", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BI3" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BI3"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BI6
Executa query que cria view HAT_LOAD_BI6
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BI6(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BI6 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BI6 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BI6_CODSEG CodigoSegmento, "
   cSql +=  " BI6_DESCRI Descricao, "
   cSql +=  " BI6_MEDICO SegmentoMedico, "
   cSql +=  " BI6_ODONTO SegmentoOdonto, "
   cSql +=  " BI6.D_E_L_E_T_ Deletado "
   cSql +=  " FROM " + RETSQLName("BI6") + " BI6 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BI6.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BI6.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BI6.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BI6.D_E_L_E_T_ = ' ' "
   Endif


   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BI6" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BI6", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BI6" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BI6"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BIA
Executa query que cria view HAT_LOAD_BIA
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BIA(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BIA AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BIA AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BIA_ABRREL AbrangRelacionada, "
   cSql +=  " BIA_CODINT CodigoOperadora, "
   cSql +=  " BIA_OPEREL OperadoraRelacionada"
   If lSTMP
      cSql +=  " ,BIA.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BIA") + " BIA "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BIA.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BIA.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BIA.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BIA.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BIA" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BIA", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BIA" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BIA"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BJ4
Executa query que cria view HAT_LOAD_BJ4
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BJ4(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BJ4 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BJ4 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BJ4_CODIGO Codigo, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Endif
   cSql +=  " BJ4_CDNV01 CodigoNivel01, "
   cSql +=  " BJ4_CDNV02 CodigoNivel02, "
   cSql +=  " BJ4_CDNV03 CodigoNivel03, "
   cSql +=  " BJ4_CDNV04 CodigoNivel04 "
   If lSTMP
      cSql +=  " ,BJ4.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BJ4") + " BJ4 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BJ4_FILIAL "+ cConc +" BJ4_CODPAD "+ cConc +" BJ4_CODPSA AND BTU.D_E_L_E_T_ = ' ') "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BJ4_CODPAD AND BTQ.BTQ_CDTERM = BJ4_CODPSA AND BTQ.D_E_L_E_T_ = ' ' ) "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BJ4.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BJ4.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BJ4.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BJ4.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL))"

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BJ4" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BJ4", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BJ4" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BJ4"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BJ4_SINTETICO
Executa query que cria view HAT_LOAD_BJ4_SINTETICO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function BJ4_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BJ4_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BJ4_SINTETICO AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BJ4_CODIGO Codigo, "
   cSql +=  " BJ4_CODPSA CodigoProcedimento, "
   cSql +=  " LTRIM(BTU_CDTERM) CodigoTipoTabela, "
   cSql +=  " BJ4_CDNV01 CodigoNivel01, "
   cSql +=  " BJ4_CDNV02 CodigoNivel02, "
   cSql +=  " BJ4_CDNV03 CodigoNivel03, "
   cSql +=  " BJ4_CDNV04 CodigoNivel04 "
   If lSTMP
      cSql +=  " ,BJ4.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BJ4") + " BJ4 "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = BJ4_CODPAD ) "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BJ4.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BJ4.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BJ4.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BJ4.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BJ4_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BJ4_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BJ4_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BJ4_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BJE
Executa query que cria view HAT_LOAD_BJE
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BJE(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BJE AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BJE AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BJE_ISMEDI ClasseDeMedicamento, "
   cSql +=  " BJE_CODIGO CodigoClasseProcedimento , "
   cSql +=  " BJE_CODINT CodigoOperadora , "
   cSql +=  " BJE_DESCRI Descricao , "
   cSql +=  " BJE_TIPO Tipo "
   If lSTMP
      cSql +=  " ,BJE.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BJE") + " BJE "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BJE.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BJE.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BJE.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BJE.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BJE" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BJE", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BJE" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BJE"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BLD
Executa query que cria view HAT_LOAD_BLD
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BLD(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BLD AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BLD AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BLD_CODPRO) CodigoPacote, "
      cSql +=  " RTRIM(BLD_CODPAD) CodigoTabela, "
      cSql +=  " RTRIM(BLD_DESPRO) Descricao "
   Else
      cSql +=  " TRIM(BLD_CODPRO) CodigoPacote, "
      cSql +=  " TRIM(BLD_CODPAD) CodigoTabela, "
      cSql +=  " TRIM(BLD_DESPRO) Descricao "
   Endif
   If lSTMP
      cSql +=  " ,BLD.D_E_L_E_T_ AS Deletado " 
   Endif
   cSql +=  " FROM " + RETSQLName("BLD") + " BLD "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BLD.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BLD.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BLD.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BLD.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BLD" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BLD", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BLD" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BLD"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BLE
Executa query que cria view HAT_LOAD_BLE
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BLE(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BLE AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BLE AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BLE_CODPRO) CodigoPacote, "
      cSql +=  " RTRIM(BLE_CODPAD) CodigoTabela, "
      cSql +=  " RTRIM(ISNULL(BTU_CODTAB, BTQ_CODTAB)) CodigoTipoTabela, "
      cSql +=  " RTRIM(ISNULL(BTU_CDTERM, BTQ_CDTERM)) CodigoProcedimento "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " TRIM(BLE_CODPRO) CodigoPacote, "
      cSql +=  " TRIM(BLE_CODPAD) CodigoTabela, "
      cSql +=  " TRIM(coalesce(BTU_CODTAB, BTQ_CODTAB)) CodigoTipoTabela, "
      cSql +=  " TRIM(coalesce(BTU_CDTERM, BTQ_CDTERM)) CodigoProcedimento "
   Else
      cSql +=  " TRIM(BLE_CODPRO) CodigoPacote, "
      cSql +=  " TRIM(BLE_CODPAD) CodigoTabela, "
      cSql +=  " TRIM(NVL(BTU_CODTAB, BTQ_CODTAB)) CodigoTipoTabela, "
      cSql +=  " TRIM(NVL(BTU_CDTERM, BTQ_CDTERM)) CodigoProcedimento "
   Endif
   If lSTMP
      cSql +=  " , BLE.D_E_L_E_T_ AS Deletado" 
   Endif
   cSql +=  " FROM " + RETSQLName("BLE") + " BLE "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BLE_FILIAL "+ cConc +" BLE_CODPAD "+ cConc +" BLE_CODOPC AND BTU.D_E_L_E_T_ = ' ') "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BLE_CODPAD AND BTQ.BTQ_CDTERM = BLE_CODOPC AND BTQ.D_E_L_E_T_ = ' ' ) "
   cSql +=  " WHERE "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " BLE.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " BLE.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND "
      Else
         cSql +=  " BLE.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND "
      Endif
   Endif
   cSql +=  " (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "
   If !lSTMP
      cSql +=  " AND BLE.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BLE" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BLE", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BLE" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BLE"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BQC
Executa query que cria view HAT_LOAD_BQC
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BQC(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BQC AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BQC AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BQC_COBNIV CobrancaNivel, "
   cSql +=  " BQC_CODCLI CodigoCliente, "
   cSql +=  " BQC_CODEMP CodigoGrpEmpresa, "
   cSql +=  " BQC_LOJA CodigoLoja, "
   cSql +=  " BQC_CODINT CodigoOperadora, "
   cSql +=  " BQC_CODIGO CodigoOperadoraEmpresa, "
   cSql +=  " BQC_DATCON DataSubContrato, "
   cSql +=  " BQC_DESCRI Descricao, "
   cSql +=  " BQC_DIASIN DiasInadimplencia, "
   cSql +=  " BQC_NUMCON NumeroContrato, "
   cSql +=  " BQC_SUBCON NumeroSubcontrato, "
   cSql +=  " BQC_QUACOB QuandoCobrar, "
   cSql +=  " BQC_REGFIN VerIficaRegraFin, "
   cSql +=  " BQC_VERCON VersaoContrato, "
   cSql +=  " BQC_VERSUB VersaoSubContrato "
   If lSTMP
      cSql +=  " ,BQC.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BQC") + " BQC "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BQC.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BQC.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BQC.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BQC.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BQC" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BQC", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BQC" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BQC"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BR4
Executa query que cria view HAT_LOAD_BR4
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BR4(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BR4 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BR4 AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BR4_CODPAD) CodigoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BR4_CODPAD) CodigoTabela, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BR4_CODPAD) CodigoTabela, "
   Endif
   cSql +=  " BR4_DIGVER Digito , "
   cSql +=  " BR4_DIGITO DigitoSegmento, "
   cSql +=  " BR4_CODNIV CodigoNivel "
   If lSTMP
      cSql +=  " ,BR4.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BR4") + " BR4 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON BR4_FILIAL = '"  + xFILIAL("BR4") + "' AND BR4_CODPAD = BTU_VLRBUS "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BR4.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BR4.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BR4.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BTU_CODTAB = '87' AND BR4.D_E_L_E_T_ = ' ' AND BTU.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BR4" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BR4", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BR4" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BR4"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BR8
Executa query que cria view HAT_LOAD_BR8
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BR8(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BR8 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BR8 AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " REPLACE(REPLACE(BR8_DESCRI,CHAR(13) + Char(10) ,' '), CHAR(10), ' ') Descricao,"
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " REPLACE(REPLACE(TRIM(BR8_DESCRI),CHR(13) ,' '), CHR(10), ' ') Descricao, "
   Else
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " REPLACE(REPLACE(TRIM(BR8_DESCRI),CHR(13) ,' '), CHR(10), ' ') Descricao, "
   Endif
   cSql +=  " BR8_BENUTL Ativo, "
   cSql +=  " BR8_CARENC QuantidadeCarencia, "
   cSql +=  " BR8_CLACAR ClasseCarencia, "
   cSql +=  " BR8_CLASSE ClasseProcedimento, "
   cSql +=  " BR8_SEXO Genero, "
   cSql +=  " BR8_IDAMAX IdadeMaxima, "
   cSql +=  " BR8_IDAMIN IdadeMinima, "
   cSql +=  " BR8_NIVEL Nivel, "
   cSql +=  " BR8_ODONTO Odontologico, "
   cSql +=  " BR8_PERIOD Periodicidade, "
   cSql +=  " BR8_PTRESP PeriodoEspecialidade, "
   cSql +=  " BR8_PTRPAT PeriodoPatologia, "
   cSql +=  " BR8_PTRMED PeriodoPrestador, "
   cSql +=  " BR8_TPCONS ProcedimentoConsulta, "
   cSql +=  " BR8_QTDESP QuantidadeEspecialidade, "
   cSql +=  " BR8_QTDPAT QuantidadePatologia, "
   cSql +=  " BR8_QTD QuantidadePermitida, "
   cSql +=  " BR8_QTDMED QuantidadePrestador, "
   cSql +=  " BR8_AUTORI TipoAutorizacao, "
   cSql +=  " BR8_TPPROC TipoProcedimento, "
   cSql +=  " BR8_TRRGSL TrataRegraSolicitante, "
   cSql +=  " BR8_UNCAR UnidadeCarencia, "
   cSql +=  " BR8_UNPERI UnidadePeriodicidade, "
   cSql +=  " BR8_UNCA UnidadeQuantidade, "
   cSql +=  " BR8_REGATD RegimeAtendimento, "
   cSql +=  " BR8_TIPEVE TipoEvento "
   If lSTMP
      cSql +=  " ,BR8.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BR8") + " BR8 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BR8_FILIAL "+ cConc +" BR8_CODPAD "+ cConc +" BR8_CODPSA AND BTU.D_E_L_E_T_ = ' ' ) "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BR8_CODPAD AND BTQ.BTQ_CDTERM = BR8_CODPSA AND BTQ.D_E_L_E_T_ = ' ') "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BR8.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BR8.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BR8.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BR8.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BR8" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BR8", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BR8" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BR8"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BRV
Executa query que cria view HAT_LOAD_BRV
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BRV(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BRV AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BRV AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BRV_CODGRU CodigoGrupoCobertura, "
   cSql +=  " BRV_CODPLA CodigoPlano, "
   cSql +=  " BRV_VERSAO VersaoPlano "
   If lSTMP
      cSql +=  " ,BRV.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BRV") + " BRV "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BRV.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BRV.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BRV.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BRV.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BRV" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BRV", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BRV" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BRV"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BT4
Executa query que cria view HAT_LOAD_BT4
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BT4(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BT4 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BT4 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BT4_CODIGO Codigo, "
   cSql +=  " BT4_CODCRE CodigoPrestador, "
   cSql +=  " BT4_PERM Permissao, "
   cSql +=  " BT4_VERSAO VersaoPlano "
   If lSTMP
      cSql +=  " ,BT4.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BT4") + " BT4 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BT4.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BT4.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BT4.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BT4.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BT4" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BT4", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BT4" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BT4"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BT5
Executa query que cria view HAT_LOAD_BT5
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BT5(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BT5 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BT5 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BT5_COBNIV CobrancaNivel, "
   cSql +=  " BT5_CODCLI CodigoCliente, "
   cSql +=  " BT5_CODIGO CodigoContrato, "
   cSql +=  " BT5_LOJA  CodigoLoja, "
   cSql +=  " BT5_CODINT CodigoOperadora, "
   cSql +=  " BT5_DATCON DataContrato, "
   cSql +=  " BT5_DIASIN DiasInadimplencia, "
   cSql +=  " BT5_INTERC Intercambio, "
   cSql +=  " BT5_NUMCON NumeroContrato, "
   cSql +=  " BT5_TIPCON TipoContrato, "
   cSql +=  " BT5_TIPOIN TipoIntercambio, "
   cSql +=  " BT5_VERSAO Versao "
   If lSTMP
      cSql +=  " ,BT5.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BT5") + " BT5 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BT5.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BT5.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BT5.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BT5.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BT5" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BT5", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BT5" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BT5"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BT6
Executa query que cria view HAT_LOAD_BT6
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BT6(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BT6 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BT6 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BT6_CODIGO CodigoContrato, "
   cSql +=  " BT6_CODINT CodigoOperadora, "
   cSql +=  " BT6_CODPRO CodigoPlano, "
   cSql +=  " BT6_CODSEG CodigoSegmento, "
   cSql +=  " BT6_INFCOB InformacaoCobertura, "
   cSql +=  " BT6_INFGRC InformacaoGrupoCobertura, "
   cSql +=  " BT6_NUMCON NumeroContrato, "
   cSql +=  " BT6_SUBCON NumeroSubcontrato, "
   cSql +=  " BT6_ALLCRE TodosCredenciados, "
   cSql +=  " BT6_VERCON VersaoContrato, "
   cSql +=  " BT6_VERSAO VersaoPlano, "
   cSql +=  " BT6_VERSUB VersaoSubcontrato "
   If lSTMP
      cSql +=  " ,BT6.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BT6") + " BT6 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BT6.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BT6.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BT6.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BT6.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BT6" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BT6", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BT6" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BT6"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BT7
Executa query que cria view HAT_LOAD_BT7
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BT7(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BT7 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BT7 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BT7_CODINT CodigoOperadora, "
   cSql +=  " BT7_CODIGO CodigoGrpEmpresa, "
   cSql +=  " BT7_NUMCON NumeroContrato, "
   cSql +=  " BT7_VERCON VersaoContrato, "
   cSql +=  " BT7_SUBCON NumeroSubcontrato, "
   cSql +=  " BT7_VERSUB VersaoSubcontrato, "
   cSql +=  " BT7_CODPRO CodigoPlano, "
   cSql +=  " BT7_CODGRU CodigoGrupoCobertura, "
   cSql +=  " BT7_CARENC QuantidadeCarencia, "
   cSql +=  " BT7_UNCAR  UnidadeCarencia, "
   cSql +=  " BT7_VERPRO VersaoPlano "
   If lSTMP
      cSql +=  " ,BT7.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BT7") + " BT7 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BT7.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BT7.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BT7.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BT7.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BT7" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BT7", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BT5" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BT7"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BT8
Executa query que cria view HAT_LOAD_BT8
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BT8(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BT8 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BT8 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BT8_CODINT CodigoOperadora, "
   cSql +=  " BT8_CODIGO CodigoEmpresa, "
   cSql +=  " BT8_NUMCON NumeroContrato, "
   cSql +=  " BT8_VERCON VersaoContrato, "
   cSql +=  " BT8_SUBCON Subcontrato, "
   cSql +=  " BT8_VERSUB VersaoSubucontrato, "
   cSql +=  " BT8_CODPRO CodigoProduto, "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BTU_CODTAB) CodTabela, "
      cSql +=  " RTRIM(BTU_CDTERM) CodProcedimento, "
   Else
      cSql +=  " TRIM(BTU_CODTAB) CodTabela, "
      cSql +=  " TRIM(BTU_CDTERM) CodProcedimento, "
   Endif
   cSql +=  " BT8_NIVEL  Nivel, "
   cSql +=  " BT8_BENUTL Ativo, "
   cSql +=  " BT8_AUTORI FormaAutorizacao, "
   cSql +=  " BT8_SEXO   Sexo, "
   cSql +=  " BT8_CARENC QuantidadeCarencia, "
   cSql +=  " BT8_UNCAR  UnidadeCarencia, "
   cSql +=  " BT8_NIVCAR NivelCarencia, "
   cSql +=  " BT8_QTD    QuantidadePeriod, "
   cSql +=  " BT8_UNCA   UnidadePeriodoCar, "
   cSql +=  " BT8_PERIOD Periodo, "
   cSql +=  " BT8_UNPERI UnidadePeriodo, "
   cSql +=  " BT8_IDAMIN IdadeMinima, "
   cSql +=  " BT8_IDAMAX IdadeMaxima, "
   cSql +=  " BT8_CDNV01 Nivel01, "
   cSql +=  " BT8_CDNV02 Nivel02, "
   cSql +=  " BT8_CDNV03 Nivel03, "
   cSql +=  " BT8_CDNV04 Nivel04, "
   cSql +=  " BT8_CLACAR ClasseCarencia, "
   cSql +=  " BT8_VERPRO VersaoProduto "
   If lSTMP
      cSql +=  " ,BT8.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BT8") + " BT8 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU_CODTAB = '87' ) "
   If cDBType == "SQL"
      If lSTMP
         cSql +=  " WHERE BT8.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      Else
         cSql +=  " WHERE BT8.D_E_L_E_T_ = ' ' "
      Endif
      cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
      cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
      cSql +=  " GROUP BY "
      cSql +=  " BT8_CODINT,BT8_CODIGO,BT8_NUMCON,BT8_VERCON,BT8_SUBCON,BT8_VERSUB,BT8_CODPRO,RTRIM(BTU_CODTAB),RTRIM(BTU_CDTERM), "
      cSql +=  " BT8_NIVEL, BT8_BENUTL,BT8_AUTORI,BT8_SEXO,BT8_CARENC,BT8_UNCAR, BT8_NIVCAR,BT8_QTD, BT8_UNCA,BT8_PERIOD,BT8_UNPERI,BT8_IDAMIN, "
      cSql +=  " BT8_IDAMAX,BT8_CDNV01,BT8_CDNV02,BT8_CDNV03,BT8_CDNV04,BT8_CLACAR,BT8_VERPRO"
   Else
   If lSTMP
     If cDBType == "POSTGRES"
         cSql +=  " WHERE BT8.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BT8.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BT8.D_E_L_E_T_ = ' ' "
   Endif
      cSql +=  " AND TRIM(BTU_VLRBUS) IS NOT NULL "
      cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
      cSql +=  " GROUP BY "
      cSql +=  " BT8_CODINT,BT8_CODIGO,BT8_NUMCON,BT8_VERCON,BT8_SUBCON,BT8_VERSUB,BT8_CODPRO,TRIM(BTU_CODTAB),TRIM(BTU_CDTERM), "
      cSql +=  " BT8_NIVEL, BT8_BENUTL,BT8_AUTORI,BT8_SEXO,BT8_CARENC,BT8_UNCAR, BT8_NIVCAR,BT8_QTD, BT8_UNCA,BT8_PERIOD,BT8_UNPERI,BT8_IDAMIN, "
      cSql +=  " BT8_IDAMAX,BT8_CDNV01,BT8_CDNV02,BT8_CDNV03,BT8_CDNV04,BT8_CLACAR,BT8_VERPRO"
   Endif
   If lSTMP
      cSql +=  " , BT8.D_E_L_E_T_ "
   Endif
   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BT8" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BT8", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BT8" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BT8"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BTQ
Executa query que cria view HAT_LOAD_BTQ
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BTQ(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BTQ AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BTQ AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BTQ_CODTAB CodigoTipoTabela, "
   cSql +=  " BTQ_CDTERM CodigoProcedimento, "
   cSql +=  " BTQ_DESTER DescricaoTermo, "
   cSql +=  " BTQ_VIGDE  VigenciaInicio, "
   cSql +=  " BTQ_VIGATE VigenciaFinal "
   If lSTMP
      cSql +=  " ,BTQ.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BTQ") + " BTQ "
      If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BTQ_CODTAB IN ('24', '26', '35', '38', '48', '59', '61') AND BTQ.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BTQ_CODTAB IN ('24', '26', '35', '38', '48', '59', '61') AND BTQ.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BTQ_CODTAB IN ('24', '26', '35', '38', '48', '59', '61') AND BTQ.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BTQ_CODTAB IN ('24', '26', '28', '32', '35', '38', '48', '59', '61') AND BTQ.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BTQ" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BTQ", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BTQ" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BTQ"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BTS
Executa query que cria view HAT_LOAD_BTS
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BTS(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BTS AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BTS AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BTS_NRCRNA CartaoNacionalSaude, "
   cSql +=  " BTS_CEPUSR CEP, "
   cSql +=  " BTS_CODMUN CodigoIbgeMunicipio, "
   cSql +=  " BTS_DATNAS DataNascimento, "
   cSql +=  " BTS_CPFUSR CPF, "
   cSql +=  " BTS_TELEFO Telefone, "
   cSql +=  " BTS_MATVID MatriculaVida, "
   cSql +=  " BTS_NOMUSR NomeBeneficiario "
   If lSTMP
      cSql +=  " ,BTS.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BTS") + " BTS "
      If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BTS.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BTS.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BTS.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BTS.D_E_L_E_T_ = ' ' AND BTS_MATVID IN (SELECT BA1_MATVID FROM " + RETSQLName("BA1") + " WHERE D_E_L_E_T_ = ' ' AND (BA1_DATBLO >= '20180101' OR BA1_DATBLO = ' ')) "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BTS" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BTS", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f.,  "Ocorreu erro na seguinte view:  HAT_LOAD_BTS" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BTS"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_BTU
Executa query que cria view HAT_LOAD_BTU
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BTU(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BTU AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BTU AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BTU_CODTAB CodigoTipoTabela, "
   cSql +=  " BTU_VLRBUS ValorBusca, "
   cSql +=  " BTU_CDTERM CodigoProcedimento, "
   cSql +=  " BTU_ALIAS Alias "
   If lSTMP
      cSql +=  " ,BTU.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BTU") + " BTU "
      If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BTU_CODTAB IN ('24', '26', '35', '48', '59', '61') AND BTU.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BTU_CODTAB IN ('24', '26', '35', '48', '59', '61') AND BTU.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BTU_CODTAB IN ('24', '26', '35', '48', '59', '61') AND BTU.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BTU_CODTAB IN ('24', '26', '35', '48', '59', '61') AND BTU.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BTU" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BTU", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BTU" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BTU"))) + CRLF

  // lLogOk := iIf(nStatus < 0, .F., .T.)


Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BVI
Executa query que cria view HAT_LOAD_BVI
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BVI(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BVI AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BVI AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " RTRIM(BVI_CODINT) CodigoOperadora, "
   cSql +=  " RTRIM(BVI_CODEMP) CodigoGrpEmpresa, "
   cSql +=  " RTRIM(BVI_MATRIC) CodigoFamilia, "
   cSql +=  " RTRIM(BVI_TIPREG) CodigoTipoBeneficiario, "
   cSql +=  " RTRIM(BVI_CODGRU) CodigoGrupoCobertura, "
   cSql +=  " RTRIM(BVI_CLACAR) ClasseCarencia, "
   If cDBType == "POSTGRES"
      cSql +=   " BVI_QTDCAR QuantidadeCarencia, "
   Else
      cSql +=   " RTRIM(BVI_QTDCAR) QuantidadeCarencia, "
   Endif
   cSql +=   " RTRIM(BVI_UNCAR) UnidadeCarencia, "
   cSql +=   " RTRIM(BVI_DATCAR) DataCarencia "
      If lSTMP
      cSql +=  " ,BVI.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BVI") + " BVI "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BVI.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BVI.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BVI.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BVI.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BVI" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BVI", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BVI" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BVI"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BW3
Executa query que cria view HAT_LOAD_BW3
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function LOAD_BW3(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BW3 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BW3 AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " coalesce(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " coalesce(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTipoTabela, "
   Endif
   cSql +=  " BW3_CODINT AS CodigoOperadora, "
   cSql +=  " BW3_CODGRU AS CodigoGrupo, "
   cSql +=  " BW3_NIVEL  AS Nivel, "
   cSql +=  " BW3_CDNV01 AS CodigoNivel01, "
   cSql +=  " BW3_CDNV02 AS CodigoNivel02, "
   cSql +=  " BW3_CDNV03 AS CodigoNivel03, "
   cSql +=  " BW3_CDNV04 AS CodigoNivel04 "
   If lSTMP
      cSql +=  " ,BW3.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BW3") + " BW3 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRSIS = BW3_FILIAL "+ cConc +" BW3_CODPAD "+ cConc +" BW3_CODPSA AND BTU.D_E_L_E_T_ = ' ' ) "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CODTAB = BW3_CODPAD AND BTQ.BTQ_CDTERM = BW3_CODPSA AND BTQ.D_E_L_E_T_ = ' ' ) "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BW3.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BW3.D_E_L_E_T_ = ' ' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BW3.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BW3.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BW3.D_E_L_E_T_ = ' ' "
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BW3" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BW3", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BW3" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BW3"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_BW3_SINTETICO
Executa query que cria view HAT_LOAD_BW3
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function BW3_SINTETICO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_BW3_SINTETICO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_BW3_SINTETICO AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BW3_CODPSA CodigoProcedimento, "
   cSql +=  " LTRIM(BTU_CDTERM) CodigoTipoTabela, "
   cSql +=  " BW3_CODINT CodigoOperadora, "
   cSql +=  " BW3_CODGRU CodigoGrupo, "
   cSql +=  " BW3_NIVEL  Nivel, "
   cSql +=  " BW3_CDNV01 CodigoNivel01, "
   cSql +=  " BW3_CDNV02 CodigoNivel02, "
   cSql +=  " BW3_CDNV03 CodigoNivel03, "
   cSql +=  " BW3_CDNV04 CodigoNivel04 "
   If lSTMP
      cSql +=  " ,BW3.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BW3") + " BW3 "
   cSql +=  " JOIN " + RETSQLName("BTU") + " BTU ON BTU_CODTAB = '87' AND LTRIM(BTU_VLRBUS) = BW3_CODPAD "
   cSql +=  " WHERE "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " BW3.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " BW3.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " BW3.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
   cSql +=  " BW3.D_E_L_E_T_ = ' ' AND LTRIM(BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BW3_SINTETICO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_BW3_SINTETICO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_BW3_SINTETICO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_BW3_SINTETICO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)


/*/{Protheus.doc} HAT_LOAD_CidIncompativel_BAA
Executa query que cria view HAT_LOAD_CidIncompativel_BAA
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function CidIncompativel_BAA(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_CidIncompativel_BAA AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_CidIncompativel_BAA AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BAA_CODPAD TabelaProcedimento, "
   cSql +=  " BAA_CODPRO Procedimento, "
   cSql +=  " BAA_CDNV01 Nivel1, "
   cSql +=  " BAA_CDNV02 Nivel2, "
   cSql +=  " BAA_CDNV03 Nivel3, "
   cSql +=  " BAA_CDNV04 Nivel4, "
   cSql +=  " BAA_CODDOE CID "
   If lSTMP
      cSql +=  " ,BAA.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BAA") + " BAA "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BAA.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BAA.S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE BAA.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE BAA.D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_CidIncompativel_BAA" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_CidIncompativel_BAA", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_CidIncompativel_BAA" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_CidIncompativel_BAA"  ))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_CRIT_ATEND_BEG
Executa query que cria view HAT_LOAD_CRIT_ATEND_BEG
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function ATEND_BEG(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_CRIT_ATEND_BEG AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_CRIT_ATEND_BEG AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BEG_OPEMOV OperadoraMovimentacao, "
   cSql +=  " BEG_ANOAUT AnoAutorizacao, "
   cSql +=  " BEG_MESAUT MesAutorizacao, "
   cSql +=  " BEG_NUMAUT NumeroAutorizacao, "
   cSql +=  " BEG_SEQUEN SequencialProcedimento, "
   cSql +=  " BEG_CODGLO CodigoCritica, "
   cSql +=  " BEG_DESGLO Descricao, "
   cSql +=  " BEG_SEQCRI SequencialCritica "
   If lSTMP
      cSql +=  " ,BEG.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BEG") + " BEG "
   cSql +=  " INNER JOIN " + RETSQLName("BEA") + " BEA ON (BEA_FILIAL ='"  + xFILIAL("BEA") + "' AND BEA_OPEMOV = BEG_OPEMOV AND BEA_ANOAUT = BEG_ANOAUT AND BEA_MESAUT = BEG_MESAUT AND BEA_NUMAUT = BEG_NUMAUT ) "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BEG.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BEA_OPEMOV = '0001' AND BEA_ORIMOV != '6' AND BEA_TIPGUI != '03' AND BEA_LIBERA = '1' AND BEG.D_E_L_E_T_ = ' ' AND BEA.D_E_L_E_T_ = ' '  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BEG.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND BEA_OPEMOV = '0001' AND BEA_ORIMOV != '6' AND BEA_TIPGUI != '03' AND BEA_LIBERA = '1' AND BEG.D_E_L_E_T_ = ' ' AND BEA.D_E_L_E_T_ = ' '  "
      Else
         cSql +=  " WHERE BEG.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND BEA_OPEMOV = '0001' AND BEA_ORIMOV != '6' AND BEA_TIPGUI != '03' AND BEA_LIBERA = '1' AND BEG.D_E_L_E_T_ = ' ' AND BEA.D_E_L_E_T_ = ' '  "
      Endif
   Else   
      If cDBType == "SQL"
         cSql +=  " WHERE BEA_OPEMOV = '0001' AND BEA_ORIMOV != '6' AND BEA_TIPGUI != '03' AND BEA_LIBERA = '1' AND BEG.D_E_L_E_T_ = ' ' AND BEA.D_E_L_E_T_ = ' ' "
      Else
         cSql +=  " WHERE BEG.D_E_L_E_T_ = ' ' AND BEA_OPEMOV = '0001' AND BEA_ORIMOV != '6' AND BEA_TIPGUI != '03' AND BEA_LIBERA = '1' AND BEA.D_E_L_E_T_ = ' ' "
      Endif
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_CRIT_ATEND_BEG" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_CRIT_ATEND_BEG", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_CRIT_ATEND_BEG" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_CRIT_ATEND_BEG"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_CRIT_ATEND_BEL
Executa query que cria view HAT_LOAD_CRIT_ATEND_BEL
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function ATEND_BEL(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_CRIT_ATEND_BEL AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_CRIT_ATEND_BEL AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BEL_CODOPE OperadoraMovimentacao, "
   cSql +=  " BEL_ANOINT AnoAutorizacao, "
   cSql +=  " BEL_MESINT MesAutorizacao, "
   cSql +=  " BEL_NUMINT NumeroAutorizacao, "
   cSql +=  " BEL_SEQUEN SequencialProcedimento, "
   cSql +=  " BEL_CODGLO CodigoCritica, "
   cSql +=  " BEL_DESGLO Descricao, "
   cSql +=  " BEL_SEQCRI SequencialCritica "
      If lSTMP
      cSql +=  " ,BEL.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BEL") + " BEL "
   cSql +=  " INNER JOIN " + RETSQLName("BE4") + " BE4 ON (BE4_FILIAL = '"  + xFILIAL("BE4") + "' AND BE4_CODOPE = BEL_CODOPE AND BE4_ANOINT = BEL_ANOINT AND BE4_MESINT = BEL_MESINT AND BE4_NUMINT = BEL_NUMINT ) "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BEL.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BE4_CODOPE = '0001' AND BE4_ORIMOV != '6' AND BE4_TIPGUI = '03' AND BEL.D_E_L_E_T_ = ' ' AND BE4.D_E_L_E_T_ = ' ' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BEL.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND BE4_CODOPE = '0001' AND BE4_ORIMOV != '6' AND BE4_TIPGUI = '03' AND BEL.D_E_L_E_T_ = ' ' AND BE4.D_E_L_E_T_ = ' '  "
      Else
         cSql +=  " WHERE BEL.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND BE4_CODOPE = '0001' AND BE4_ORIMOV != '6' AND BE4_TIPGUI = '03' AND BEL.D_E_L_E_T_ = ' ' AND BE4.D_E_L_E_T_ = ' '  "
      Endif
   Else   
      If cDBType == "SQL"
         cSql +=  " WHERE BE4_CODOPE = '0001' AND BE4_ORIMOV != '6' AND BE4_TIPGUI = '03' AND BEL.D_E_L_E_T_ = ' ' AND BE4.D_E_L_E_T_ = ' ' "
      Else
         cSql +=  " WHERE BE4.D_E_L_E_T_ = ' ' AND BE4_CODOPE = '0001' AND BE4_ORIMOV != '6' AND BE4_TIPGUI = '03' AND BEL.D_E_L_E_T_ = ' ' "
      Endif
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_CRIT_ATEND_BEL" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_CRIT_ATEND_BEL", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_CRIT_ATEND_BEL" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_CRIT_ATEND_BEL"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_PROC_ATEND_BE2
Executa query que cria view HAT_LOAD_PROC_ATEND_BE2
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function ATEND_BE2(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_PROC_ATEND_BE2 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_PROC_ATEND_BE2 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BE2_ANOAUT AnoAutorizacao, "
   cSql +=  " BE2_AUDITO Auditoria, "
   cSql +=  " BE2_CODESP CodigoEspecialidade, "
   cSql +=  " BE2_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BE2_CODRDA CodigoPrestador, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " COALESCE(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " COALESCE(BTU_CODTAB, BTQ_CODTAB) CodigoTabela, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTabela, "
   Endif
   cSql +=  " BE2_DATPRO DataProcessamento, "
   cSql +=  " BE2_HORPRO HoraProcessamento, "
   cSql +=  " BE2_LOCAL LocalAtendimento, "
   cSql +=  " BE2_MESAUT MesAutorizacao, "
   cSql +=  " BE2_NUMAUT NumeroAutorizacao, "
   cSql +=  " BE2_OPEMOV OperadoraMovimentacao, "
   cSql +=  " BE2_OPERDA OperadoraPrestador, "
   cSql +=  " BE2_QTDPRO QuantidadeAutorizada, "
   cSql +=  " BE2_QTDSOL QuantidadeSolicitada, "
   cSql +=  " BE2_SALDO SaldoProcedimento, "
   cSql +=  " BE2_SEQUEN SequencialProcedimento, "
   cSql +=  " BE2_STATUS Status, "
   cSql +=  " BE2_TIPO Tipo "
   If lSTMP
      cSql +=  " ,BE2.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BE2") + " BE2 "
   cSql +=  " INNER JOIN " + RETSQLName("BEA") + " BEA ON (BEA_FILIAL =  '"  + xFILIAL("BEA") + "' AND BEA_OPEMOV = BE2_OPEMOV AND BEA_ANOAUT = BE2_ANOAUT AND BEA_MESAUT = BE2_MESAUT AND BEA_NUMAUT = BE2_NUMAUT AND BEA.D_E_L_E_T_ = ' ' ) "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU_VLRBUS = BE2_CODPRO AND BTU.D_E_L_E_T_ = ' ') "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ_CDTERM = BE2_CODPRO  AND BTQ.D_E_L_E_T_ = ' ') "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BE2.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BE2_OPEMOV = '0001' AND BE2_LIBERA = '1' AND BE2_TIPO != '3'AND BEA_ORIMOV != '6' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BE2.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND BE2_OPEMOV = '0001' AND BE2_LIBERA = '1' AND BE2_TIPO != '3'AND BEA_ORIMOV != '6' "
      Else
         cSql +=  " WHERE BE2.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND BE2_OPEMOV = '0001' AND BE2_LIBERA = '1' AND BE2_TIPO != '3'AND BEA_ORIMOV != '6' "
      Endif
   Else   
      If cDBType == "SQL"
         cSql +=  " WHERE BE2.D_E_L_E_T_ = ' ' AND BE2_OPEMOV = '0001' AND BE2_LIBERA = '1' AND BE2_TIPO != '3'AND BEA_ORIMOV != '6'"
      Else
         cSql +=  " WHERE BE2_OPEMOV = '0001' AND BE2_LIBERA = '1' AND BE2_TIPO != '3' AND BE2.D_E_L_E_T_ = ' ' AND BEA_ORIMOV != '6' "
      Endif
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_PROC_ATEND_BE2" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_PROC_ATEND_BE2", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_PROC_ATEND_BE2" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_PROC_ATEND_BE2"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_PROC_ATEND_BEJ
Executa query que cria view HAT_LOAD_PROC_ATEND_BEJ
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/

function ATEND_BEJ(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_PROC_ATEND_BEJ AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_PROC_ATEND_BEJ AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " BEJ_ANOINT AnoAutorizacao, "
   cSql +=  " BEJ_AUDITO Auditoria, "
   cSql +=  " BE2_CODESP CodigoEspecialidade, "
   cSql +=  " BE2_CODLOC CodigoLocalAtendimento, "
   cSql +=  " BE2_CODRDA CodigoPrestador, "
   If cDBType == "SQL"
      cSql +=  " ISNULL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " ISNULL(BTU_CODTAB, BTQ_CODTAB) CodigoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " COALESCE(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " COALESCE(BTU_CODTAB, BTQ_CODTAB) CodigoTabela, "
   Else
      cSql +=  " NVL(BTU_CDTERM, BTQ_CDTERM) CodigoProcedimento, "
      cSql +=  " NVL(BTU_CODTAB, BTQ_CODTAB) CodigoTabela, "
   Endif
   cSql +=  " BE2_DATPRO DataProcessamento, "
   cSql +=  " BE2_HORPRO HoraProcessamento, "
   cSql +=  " BE2_LOCAL LocalAtendimento, "
   cSql +=  " BEJ_MESINT MesAutorizacao, "
   cSql +=  " BEJ_NUMINT NumeroAutorizacao, "
   cSql +=  " BEJ_CODOPE OperadoraMovimentacao, "
   cSql +=  " BE2_OPERDA OperadoraPrestador, "
   cSql +=  " BEJ_QTDPRO QuantidadeAutorizada, "
   cSql +=  " BEJ_QTDSOL QuantidadeSolicitada, "
   cSql +=  " BE2_SALDO SaldoProcedimento, "
   cSql +=  " BEJ_SEQUEN SequencialProcedimento, "
   cSql +=  " BEJ_STATUS Status, "
   cSql +=  " BE2_TIPO Tipo "
   If lSTMP
      cSql +=  " ,BEJ.D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("BEJ") + " BEJ "
   cSql +=  " INNER JOIN " + RETSQLName("BE4") + " BE4 ON (BE4_FILIAL =  '"  + xFILIAL("BE4") + "' AND BE4_CODOPE = BEJ_CODOPE AND BE4_ANOINT = BEJ_ANOINT AND BE4_MESINT = BEJ_MESINT AND BE4_NUMINT = BEJ_NUMINT AND BE4.D_E_L_E_T_ = ' ' ) "
   cSql +=  " INNER JOIN " + RETSQLName("BE2") + " BE2 ON (BE2_FILIAL =  '"  + xFILIAL("BE2") + "' AND BE2_OPEMOV = BEJ_CODOPE AND BE2_ANOINT = BEJ_ANOINT AND BE2_MESINT = BEJ_MESINT AND BE2_NUMINT = BEJ_NUMINT AND BE2.D_E_L_E_T_  = ' ' ) "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU_VLRBUS = BEJ_CODPRO AND BTU.D_E_L_E_T_ = ' ') "
   cSql +=  " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ_CDTERM = BEJ_CODPRO  AND BTQ.D_E_L_E_T_ = ' ') "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE BEJ.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BEJ_CODOPE = '0001' AND BE4_TIPGUI = '03' AND BE4_ORIMOV != '6' "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE BEJ.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND BEJ_CODOPE = '0001' AND BE4_TIPGUI = '03' AND BE4_ORIMOV != '6' "
      Else
         cSql +=  " WHERE BEJ.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND BEJ_CODOPE = '0001' AND BE4_TIPGUI = '03' AND BE4_ORIMOV != '6' "
      Endif
   Else      
      If cDBType == "SQL"
         cSql +=  " WHERE BEJ_CODOPE = '0001' AND BEJ.D_E_L_E_T_ = ' ' AND BE4_TIPGUI = '03' AND BE4_ORIMOV != '6'"
      Else
         cSql +=  " WHERE BEJ.D_E_L_E_T_ = ' ' AND BEJ_CODOPE = '0001' AND BE4_TIPGUI = '03' AND BE4_ORIMOV != '6' "
      Endif
   Endif
   cSql +=  " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql +=  " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_PROC_ATEND_BEJ" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_PROC_ATEND_BEJ", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_PROC_ATEND_BEJ" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_PROC_ATEND_BEJ"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_REGRASCOBERTURA
Executa query que cria view HAT_LOAD_REGRASCOBERTURA
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function REGRASCOBERTURA(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_REGRASCOBERTURA AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_REGRASCOBERTURA AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BTU_CDTERM) AS TabelaProcedimento, "
      cSql +=  " RTRIM(BYL_CODPSA) AS Procedimento, "
   Else
      cSql +=  " TRIM(BTU_CDTERM) AS TabelaProcedimento, "
      cSql +=  " TRIM(BYL_CODPSA) AS Procedimento, "
   Endif
   cSql +=  " BYL_CODIGO DenteRegiao, "
   If cDBType == "SQL"
   cSql +=  " SUBSTRING(BYL_FACE, numbers.n, 1) Face, "
   Else
   cSql +=  " SUBSTR(BYL_FACE, numbers.n, 1) Face, "
   Endif
   cSql +=  " CAST(B05_QTD AS INT) QuantidadePermitida, "
   cSql +=  " B05_UNCA   UnidadeQuantidade, "
   cSql +=  " B05_QTDMED VldQtdPrestador, "
   cSql +=  " B05_QTDESP VldQtdEspec, "
   cSql +=  " B05_QTDPAT VldQtdCid, "
   cSql +=  " CAST(B05_PERIOD AS INT) Periodicidade, "
   cSql +=  " B05_UNPERI UnidadePeriodicidade, "
   cSql +=  " B05_PTRMED VldPerPrestador, "
   cSql +=  " B05_PTRESP VldPerEspec, "
   cSql +=  " B05_PTRPAT VldPerCid, "
   cSql +=  " CAST(B05_IDAMIN AS INT) IdadeMinima, "
   cSql +=  " CAST(B05_IDAMAX AS INT) IdadeMaxima, "
   cSql +=  " B05_AUTORI  ModalidadeAutorizacao
   If lSTMP 
    If cDBType == "SQL"
      cSql +=  " ,B05.D_E_L_E_T_ AS Deletado"
    Endif
   Endif
   cSql +=  " FROM "
   If cDBType == "SQL"
      cSql +=  " (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 ) numbers "
      cSql +=  " INNER JOIN " + RETSQLName("BYL") + " BYL ON LEN(BYL_FACE)>numbers.n-1 "
      cSql +=  " INNER JOIN " + RETSQLName("B05") + " B05 ON BYL_CODPAD = B05_CODPAD AND BYL_CODPSA = B05_CODPSA "
      cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87') "
      If lSTMP
         cSql +=  " WHERE (BYL.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))) OR B05.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BYL.D_E_L_E_T_  = ' ' AND BYL_FACE <> ' '  AND SUBSTRING(BYL_FACE, numbers.n, 1) <> ' ' AND LTRIM(BTU.BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
      Else
         cSql +=  " WHERE BYL.D_E_L_E_T_  = ' ' AND B05.D_E_L_E_T_  = ' ' AND BYL_FACE <> ' ' AND SUBSTRING(BYL_FACE, numbers.n, 1) <> ' ' AND LTRIM(BTU.BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
      Endif
      cSql +=  " GROUP BY "
      cSql +=  " RTRIM(BTU.BTU_CDTERM), BYL_CODPSA, BYL_CODIGO, SUBSTRING(BYL_FACE, numbers.n, 1), "
   ElseIf cDBType == "POSTGRES"
      cSql +=  " (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 ) numbers "
      cSql +=  " INNER JOIN " + RETSQLName("BYL") + " BYL ON LENGTH(BYL_FACE)>numbers.n-1 "
      cSql +=  " INNER JOIN " + RETSQLName("B05") + " B05 ON BYL_CODPAD = B05_CODPAD AND BYL_CODPSA = B05_CODPSA "
      cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87') "
      If lSTMP
         cSql +=  " WHERE (BYL.S_T_A_M_P_ > (current_timestamp - interval'1 hours') OR  B05.S_T_A_M_P_ > (current_timestamp - interval'1 hours')) AND BYL.D_E_L_E_T_  = ' ' AND B05.D_E_L_E_T_ = ' ' AND BYL_FACE <> ' '  AND SUBSTR(BYL_FACE, numbers.n, 1) <> ' ' AND TRIM(BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
      Else
         cSql +=  " WHERE BYL.D_E_L_E_T_  = ' ' AND B05.D_E_L_E_T_  = ' ' AND BYL_FACE <> ' '  AND SUBSTR(BYL_FACE, numbers.n, 1) <> ' ' AND TRIM(BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
      Endif
      cSql +=  " GROUP BY "
      cSql +=  " TRIM(BTU_CDTERM), BYL_CODPSA, BYL_CODIGO,  SUBSTR(BYL_FACE, numbers.n, 1),"
   Else
      cSql +=  " (SELECT 1 n FROM DUAL UNION ALL SELECT 2 FROM DUAL UNION ALL SELECT 3 FROM DUAL UNION ALL SELECT 4 FROM DUAL UNION ALL SELECT 5 FROM DUAL) numbers "
      cSql +=  " INNER JOIN " + RETSQLName("BYL") + " BYL ON LENGTH(BYL_FACE)>numbers.n-1 "
      cSql +=  " INNER JOIN " + RETSQLName("B05") + " B05 ON BYL_CODPAD = B05_CODPAD AND BYL_CODPSA = B05_CODPSA "
      cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87') "
      If lSTMP
         cSql +=  " WHERE (BYL.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) OR  B05.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR)) AND BYL.D_E_L_E_T_  = ' ' AND B05.D_E_L_E_T_ = ' ' AND BYL_FACE <> ' '  AND SUBSTR(BYL_FACE, numbers.n, 1) <> ' ' AND TRIM(BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' ' "
      Else
         cSql +=  " WHERE BYL.D_E_L_E_T_  = ' ' AND B05.D_E_L_E_T_  = ' ' AND BYL_FACE <> ' '  AND SUBSTR(BYL_FACE, numbers.n, 1) <> ' ' AND TRIM(BTU.BTU_VLRBUS) IS NOT NULL AND BTU.D_E_L_E_T_ = ' '"
      Endif
      cSql +=  " GROUP BY "
      cSql +=  " TRIM(BTU_CDTERM), BYL_CODPSA, BYL_CODIGO,  SUBSTR(BYL_FACE, numbers.n, 1),"
   Endif
   cSql +=  " CAST(B05_QTD AS INT), "
   cSql +=  " B05_UNCA, "
   cSql +=  " B05_QTDMED, "
   cSql +=  " B05_QTDESP, "
   cSql +=  " B05_QTDPAT, "
   cSql +=  " CAST(B05_PERIOD AS INT), "
   cSql +=  " B05_UNPERI, "
   cSql +=  " B05_PTRMED, "
   cSql +=  " B05_PTRESP, "
   cSql +=  " B05_PTRPAT, "
   cSql +=  " CAST(B05_IDAMIN AS INT), "
   cSql +=  " CAST(B05_IDAMAX AS INT), "
   cSql +=  " B05_AUTORI "
   If lSTMP 
      cSql +=  " ,B05.D_E_L_E_T_ "
   Endif
   cSql +=  " UNION ALL "
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BTU_CDTERM) AS TabelaProcedimento, "
      cSql +=  " RTRIM(B05_CODPSA) AS Procedimento, "
   Else
      cSql +=  " TRIM(BTU_CDTERM) AS TabelaProcedimento, "
      cSql +=  " TRIM(B05_CODPSA) AS Procedimento, "
   Endif
   cSql +=  " B05_CODIGO DenteRegiao, "
   cSql +=  " ' ' Face, "
   cSql +=  " CAST(B05_QTD AS INT) QuantidadePermitida, "
   cSql +=  " B05_UNCA   UnidadeQuantidade, "
   cSql +=  " B05_QTDMED VldQtdPrestador, "
   cSql +=  " B05_QTDESP VldQtdEspec, "
   cSql +=  " B05_QTDPAT VldQtdCid, "
   cSql +=  " CAST(B05_PERIOD AS INT) Periodicidade, "
   cSql +=  " B05_UNPERI UnidadePeriodicidade, "
   cSql +=  " B05_PTRMED VldPerPrestador, "
   cSql +=  " B05_PTRESP VldPerEspec, "
   cSql +=  " B05_PTRPAT VldPerCid, "
   cSql +=  " CAST(B05_IDAMIN AS INT) IdadeMinima, "
   cSql +=  " CAST(B05_IDAMAX AS INT) IdadeMaxima, "
   cSql +=  " B05_AUTORI  ModalidadeAutorizacao "
   If lSTMP 
      If cDBType == "SQL"
         cSql +=  " ,B05.D_E_L_E_T_ AS Deletado"
      Endif
   Endif
   cSql +=  " FROM " + RETSQLName("B05") + " B05 "
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87') "
   If lSTMP
      If cDBType == "SQL"
         cSql +=  " WHERE B05.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE B05.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND B05.D_E_L_E_T_ = ' ' "
      Else 
         cSql +=  " WHERE B05.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND B05.D_E_L_E_T_ = ' ' "
      Endif
   Else
   cSql +=  " WHERE B05.D_E_L_E_T_  = ' '"
   Endif
   If cDBType == "SQL"
   cSql +=  " AND B05_CODPSA NOT IN (SELECT BYL_CODPSA FROM " + RETSQLName("BYL") + ")"
   cSql +=  " AND LTRIM(BTU_VLRBUS) IS NOT NULL "
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   Else
   cSql +=  " AND B05_CODPSA NOT IN (SELECT BYL_CODPSA FROM " + RETSQLName("BYL") + ")"
   cSql +=  " AND TRIM(BTU_VLRBUS) IS NOT NULL
   cSql +=  " AND BTU.D_E_L_E_T_ = ' '
   Endif
   cSql +=  " GROUP BY "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BTU_CDTERM), "
   Else
      cSql +=  " TRIM(BTU_CDTERM), "
   Endif
   cSql +=  " B05_CODPSA, "
   cSql +=  " B05_CODIGO, "
   cSql +=  " CAST(B05_QTD AS INT), "
   cSql +=  " B05_UNCA, "
   cSql +=  " B05_QTDMED, "
   cSql +=  " B05_QTDESP, "
   cSql +=  " B05_QTDPAT, "
   cSql +=  " CAST(B05_PERIOD AS INT), "
   cSql +=  " B05_UNPERI, "
   cSql +=  " B05_PTRMED, "
   cSql +=  " B05_PTRESP, "
   cSql +=  " B05_PTRPAT, "
   cSql +=  " CAST(B05_IDAMIN AS INT), "
   cSql +=  " CAST(B05_IDAMAX AS INT), "
   cSql +=  " B05_AUTORI "
   If lSTMP
      cSql +=  " , B05.D_E_L_E_T_ "
   Endif
   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_REGRASCOBERTURA" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_REGRASCOBERTURA", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_REGRASCOBERTURA" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_REGRASCOBERTURA"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_SE1
Executa query que cria view HAT_LOAD_SE1
@type function
@author Gabriela
@since 26.05.2022
@version 1.0/*/
function LOAD_SE1(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F. 

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_SE1 AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_SE1 AS "
   Endif
   cSql +=  " SELECT "
   cSql +=  " E1_PREFIXO Prefixo, "
   cSql +=  " E1_NUM     Numero, "
   cSql +=  " E1_PARCELA Parcela, "
   cSql +=  " E1_TIPO    Tipo, "
   cSql +=  " E1_CLIENTE Cliente, "
   cSql +=  " E1_LOJA    CodigoLoja, "
   cSql +=  " E1_EMISSAO Emissao, "
   cSql +=  " E1_VENCREA Vencimento, "
   cSql +=  " E1_VALOR   Valor, "
   cSql +=  " E1_BAIXA   Baixa, "
   cSql +=  " E1_SALDO   Saldo, "
   cSql +=  " E1_STATUS  Status, "
   cSql +=  " E1_CODINT  CodigoOperadora, "
   cSql +=  " E1_CODEMP  CodigoGrpEmpresa, "
   cSql +=  " E1_MATRIC  CodigoFamilia, "
   cSql +=  " E1_CONEMP  NumeroContrato, "
   cSql +=  " E1_VERCON  VersaoContrato, "
   cSql +=  " E1_SUBCON  NumeroSubcontrato, "
   cSql +=  " E1_VERSUB  VersaoSubContrato "
   If lSTMP
      cSql +=  " ,D_E_L_E_T_ AS Deletado "
   Endif
   cSql +=  " FROM " + RETSQLName("SE1") + " SE1 "
   If lSTMP
     If cDBType == "SQL"
         cSql +=  " WHERE S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE()))  "
      ElseIf cDBType == "POSTGRES"
         cSql +=  " WHERE S_T_A_M_P_ > (current_timestamp - interval'1 hours')  "
      Else
         cSql +=  " WHERE S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) "
      Endif
   Else
      cSql +=  " WHERE E1_BAIXA = ' ' AND D_E_L_E_T_ = ' ' "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_SE1" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_SE1", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_SE1" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_SE1"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_LOAD_VINCULOSODONTO
Executa query que cria view HAT_LOAD_VINCULOSODONTO
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function VINCULOSODONTO(lSTMP, lAuto)

   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   If lSTMP 
      cSql +=  " CREATE VIEW HAT_STMP_VINCULOSODONTO AS "
   Else
      cSql +=  " CREATE VIEW HAT_LOAD_VINCULOSODONTO AS "
   Endif
   cSql +=  " SELECT "
   If cDBType == "SQL"
      cSql +=  " RTRIM(BTU_CDTERM) AS TabelaProcedimento, "
      cSql +=  " RTRIM(BYL_Procedimento) AS Procedimento, "
   Else
      cSql +=  " TRIM(BTU_CDTERM) AS TabelaProcedimento, "
      cSql +=  " TRIM(BYL_Procedimento) AS Procedimento, "
   Endif
   cSql +=  " BYL_DenteRegiao AS DenteRegiao, "
	cSql +=  " BYL_Face AS Face "
   cSql +=  " FROM "
   If cDBType == "SQL"
   cSql += " (SELECT "
   cSql +=  " BYL_CODPAD BYL_TabelaProcedimento, "
   cSql +=  " BYL_CODPSA BYL_Procedimento, "
	cSql +=  " BYL_CODIGO BYL_DenteRegiao, "
	cSql +=  " SUBSTRING(BYL_FACE, numbers.n, 1) BYL_Face "
   cSql +=  " FROM "
   cSql +=  " (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) numbers "
   cSql +=  " INNER JOIN " + RETSQLName("BYL") + " BYL ON LEN(BYL_FACE)>numbers.n-1 "
   If lSTMP
      cSql +=  " WHERE BYL.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND BYL.D_E_L_E_T_  = ' ' AND BYL_FACE <> ' ' AND SUBSTRING(BYL_FACE, numbers.n, 1) <> ' '"
   Else
      cSql +=  " WHERE BYL.D_E_L_E_T_ = ' ' AND BYL_FACE <> ' ' AND SUBSTRING(BYL_FACE, numbers.n, 1) <> ' ' "
   Endif
   cSql +=  " UNION ALL"
   cSql +=  " SELECT "
   cSql +=  " B05_CODPAD B05_TabelaProcedimento,  "
   cSql +=  " B05_CODPSA B05_Procedimento, "
   cSql +=  " B05_CODIGO B05_DenteRegiao, "
   cSql +=  " ' ' B05_Face "
   cSql +=  " FROM " + RETSQLName("B05") + " B05 "
   If lSTMP 
      cSql +=  " WHERE B05.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) AND D_E_L_E_T_  = ' ' AND B05_CODPSA NOT IN (SELECT BYL_CODPSA FROM " + RETSQLName("BYL") + " )) temp"
   Else  
      cSql +=  " WHERE B05.D_E_L_E_T_ = ' ' AND B05_CODPSA NOT IN (SELECT BYL_CODPSA FROM " + RETSQLName("BYL") + " )) temp"
   Endif
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87') "
	cSql +=  " WHERE "
	cSql +=  " LTRIM(BTU_VLRBUS) IS NOT NULL "
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   cSql +=  " GROUP BY RTRIM(BTU_CDTERM),RTRIM(BYL_Procedimento),BYL_DenteRegiao,BYL_Face "
   ElseIf cDBType == "POSTGRES"
   cSql += " (SELECT "
   cSql +=  " BYL_CODPAD BYL_TabelaProcedimento, "
   cSql +=  " BYL_CODPSA BYL_Procedimento, "
	cSql +=  " BYL_CODIGO BYL_DenteRegiao, "
	cSql +=  " SUBSTR(BYL_FACE, numbers.n, 1) BYL_Face "
   cSql +=  " FROM "
   cSql +=  " (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 ) numbers "
   cSql +=  " INNER JOIN " + RETSQLName("BYL") + " BYL ON LENGTH(BYL_FACE)>numbers.n-1 "
   If lSTMP
      cSql +=  " WHERE BYL.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND BYL.D_E_L_E_T_  = ' ' AND BYL_FACE <> ' ' AND SUBSTR(BYL_FACE, numbers.n, 1) <> ' '"
   Else
      cSql +=  " WHERE BYL.D_E_L_E_T_ = ' ' AND BYL_FACE <> ' ' AND SUBSTR(BYL_FACE, numbers.n, 1) <> ' ' "
   Endif
   cSql +=  " UNION ALL"
   cSql +=  " SELECT "
   cSql +=  " B05_CODPAD B05_TabelaProcedimento,  "
   cSql +=  " B05_CODPSA B05_Procedimento, "
   cSql +=  " B05_CODIGO B05_DenteRegiao, "
   cSql +=  " ' ' B05_Face "
   cSql +=  " FROM " + RETSQLName("B05") + " B05 "
   If lSTMP
      cSql +=  " WHERE B05.S_T_A_M_P_ > (current_timestamp - interval'1 hours') AND B05.D_E_L_E_T_  = ' ' AND B05_CODPSA NOT IN (SELECT BYL_CODPSA FROM " + RETSQLName("BYL") + " ) ) temp"
   Else
      cSql +=  " WHERE B05.D_E_L_E_T_ = ' ' AND B05_CODPSA NOT IN (SELECT BYL_CODPSA FROM " + RETSQLName("BYL") + " ) ) temp"
   Endif
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87')
	cSql +=  " WHERE "
	cSql +=  " TRIM(BTU_VLRBUS) IS NOT NULL "
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   cSql +=  " GROUP BY TRIM(BTU_CDTERM), TRIM(BYL_Procedimento), BYL_DenteRegiao, BYL_Face "
   Else
   cSql += " (SELECT "
   cSql +=  " BYL_CODPAD BYL_TabelaProcedimento, "
   cSql +=  " BYL_CODPSA BYL_Procedimento, "
	cSql +=  " BYL_CODIGO BYL_DenteRegiao, "
	cSql +=  " SUBSTR(BYL_FACE, numbers.n, 1) BYL_Face "
   cSql +=  " FROM "
   cSql +=  " (SELECT 1 n FROM DUAL UNION ALL SELECT 2 FROM DUAL UNION ALL SELECT 3 FROM DUAL UNION ALL SELECT 4 FROM DUAL UNION ALL SELECT 5 FROM DUAL) numbers  "
   cSql +=  " INNER JOIN " + RETSQLName("BYL") + " BYL ON LENGTH(BYL_FACE)>numbers.n-1 "
   If lSTMP
      cSql +=  " WHERE BYL.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND BYL.D_E_L_E_T_  = ' ' AND BYL_FACE <> ' ' AND SUBSTR(BYL_FACE, numbers.n, 1) <> ' '"
   Else
      cSql +=  " WHERE BYL.D_E_L_E_T_ = ' ' AND BYL_FACE <> ' ' AND SUBSTR(BYL_FACE, numbers.n, 1) <> ' ' "
   Endif
   cSql +=  " UNION ALL"
   cSql +=  " SELECT "
   cSql +=  " B05_CODPAD B05_TabelaProcedimento,  "
   cSql +=  " B05_CODPSA B05_Procedimento, "
   cSql +=  " B05_CODIGO B05_DenteRegiao, "
   cSql +=  " ' ' B05_Face "
   cSql +=  " FROM " + RETSQLName("B05") + " B05 "
   If lSTMP
      cSql +=  " WHERE B05.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp)  - INTERVAL '1' HOUR) AND B05.D_E_L_E_T_  = ' ' AND B05_CODPSA NOT IN (SELECT BYL_CODPSA FROM " + RETSQLName("BYL") + ")) temp "
   Else
      cSql +=  " WHERE B05.D_E_L_E_T_ = ' ' AND B05_CODPSA NOT IN (SELECT BYL_CODPSA FROM " + RETSQLName("BYL") + " ) ) temp"
   Endif
   cSql +=  " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (BTU_CODTAB = '87')
	cSql +=  " WHERE "
	cSql +=  " TRIM(BTU_VLRBUS) IS NOT NULL "
   cSql +=  " AND BTU.D_E_L_E_T_ = ' ' "
   cSql +=  " GROUP BY TRIM(BTU_CDTERM), TRIM(BYL_Procedimento), BYL_DenteRegiao, BYL_Face "
   Endif

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_VINCULOSODONTO" + TCSQLError(), ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso:  HAT_STMP_VINCULOSODONTO", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_LOAD_VINCULOSODONTO" + TCSQLError(), "View criada com sucesso:  HAT_LOAD_VINCULOSODONTO"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_STMP_BEA_CONSULTA
Executa query que cria view HAT_STMP_BEA_CONSULTA
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function BEA_CONSULTA(lSTMP, lAuto)
   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   cSql +=  " CREATE VIEW HAT_STMP_BEA_CONSULTA AS "
   cSql += " SELECT BEA_ANOAUT AS AnoAutorizacao, "
   cSql += " BEA_ATERNA AS AtendimentoRecemNascido, "
   cSql += " BEA_AUDITO AS Auditoria, "
   cSql += " BEA_CANCEL AS Cancelado, "
   cSql += " BEA_CANEDI AS CancelamentoEDI, "
   cSql += " BEA_MATRIC AS CodigoFamilia, "
   cSql += " BEA_CODEMP AS CodigoGrpEmpresa, "
   cSql += " BEA_CODLOC AS CodigoLocalAtendimento, "
   cSql += " BEA_CDPFRE AS CodigoProfissionalResponsavel, "
   cSql += " BEA_CDPFSO AS CodigoProfissionalSolicitante, "
   cSql += " BEA_CODRDA AS CodigoPrestador, "
   cSql += " BEA_TIPREG AS CodigoTipoBeneficiario, 
   cSql += " BEA_TIPSAI AS CodigoTipoSaida, "
   cSql += " BEA_DATPRO AS DataProcessamento, "
   cSql += " BEA_DATSOL AS DataSolicitacao, "
   cSql += " BEA_ESPEXE AS EspecialidadeExecutante, "
   cSql += " BEA_ESPSOL AS EspecialidadeSolicitante, "
   cSql += " BEA_ESTEXE AS EstadoExecutante, "
   cSql += " BEA_ESTSOL AS EstadoSolicitante, "
   cSql += " BEA_INDACI AS IndicacaoAcidente, "
   If cDBType == "SQL"
      cSql += " BEA_INDCLI AS IndicacaoClinica, "
   Else
      cSql += " REPLACE(BEA_INDCLI,CHR(10),'') AS IndicacaoClinica, "
   EndIf
   cSql += " BEA_LIBERA AS Liberacao, "
   cSql += " BEA_LOCAL AS LocalAtendimento, "
   cSql += " BEA_MESAUT AS MesAutorizacao, "
   cSql += " BEA_NUMAUT AS NumeroAutorizacao, "
   cSql += " BEA_GUIPRI AS NumeroGuiaPrincipal, " 
   cSql += " BEA_NRLBOR AS NumeroLiberacaoOriginal, "
   cSql += " BEA_NUMTIT AS NumeroTituloContasRec, "
   cSql += " BEA_OPEMOV AS OperadoraMovimentacao, "
   cSql += " BEA_OPEUSR AS OperadoraUsuario, "
   cSql += " BEA_PARCEL AS Parcela, "
   cSql += " BEA_PREFIX AS Prefixo, "
   cSql += " BEA_PROATE AS ProtocoloAtendimento, "
   cSql += " BEA_REGEXE AS RegistroExecutante, "
   cSql += " BEA_REGSOL AS RegistroSolicitante, "
   cSql += " BEA_SENHA AS Senha, "
   cSql += " BEA_SIGLA AS SiglaConselho, "
   cSql += " BEA_SIGEXE AS SiglaConselhoExecutante, "
   cSql += " BEA_STATUS AS Status, "
   cSql += " BEA_STALIB AS StatusLiberacao, "
   cSql += " BEA_STTISS AS StatusTISS, "
   cSql += " BEA_TIPADM AS TipoAdmissao, "
   cSql += " BEA_TIPATE AS TipoAtendimento, " 
   cSql += " BEA_TIPCON AS TipoConsulta, "
   cSql += " BEA_TIPO AS TipoGuia, "
   cSql += " BEA_TIPTIT AS TipoTituloContasRec, "
   cSql += " BEA_VALSEN AS ValidadeSenhaAtendimento, "
   If cDBType == "SQL"
      cSql += " CONCAT(BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT) AS NumeroGuiaOperadora, "
   Else
      cSql += " (BEA_OPEMOV || BEA_ANOAUT || BEA_MESAUT || BEA_NUMAUT) AS NumeroGuiaOperadora, "
   EndIf
   cSql += " BEA.D_E_L_E_T_  AS Deletado "
   cSql += " FROM " + RETSQLName("BEA") + " BEA "
   cSql += " INNER JOIN " + RETSQLName("BCI") + " BCI ON  BEA_FILIAL =  '"  + xFILIAL("BEA") + "' AND BEA_OPEMOV = BCI_CODOPE AND BEA_CODPEG = BCI_CODPEG AND BEA_CODRDA = BCI_CODRDA AND BCI_CODLDP = '9999' "
   cSql += " AND BCI_FASE <> '4'"
   If cDBType == "SQL"
      cSql += " WHERE 1=1 AND BEA.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
   ElseIf cDBType == "POSTGRES"
      cSql += " WHERE 1=1 AND BEA.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
   Else
      cSql += " WHERE 1=1 AND BEA.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp) - INTERVAL '1' HOUR) "
   EndIf
   cSql += " AND BEA_OPEMOV = '0001' AND BEA_ORIMOV = '1' AND BEA_TIPGUI = '01' AND BEA_LIBERA = '0' AND BEA_NUMGUI <> '' "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_BEA_CONSULTA" + TCSQLError() , ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso: HAT_STMP_BEA_CONSULTA", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_STMP_BEA_CONSULTA" + TCSQLError() , "View criada com sucesso:  HAT_STMP_BEA_CONSULTA"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)

/*/{Protheus.doc} HAT_STMP_PROC_ATEND_BE2_CONSULTA
Executa query que cria view HAT_STMP_PROC_ATEND_BE2_CONSULTA
@type function
@author Gabriela
@since 26.05.2022
@version 1.0
/*/
function BE2_CONSULTA(lSTMP, lAuto)
   local cSql := ""
   local nStatus := 0

   Default lAuto := .F.
   Default lSTMP := .F.

   iIf (lAuto, verIficaBD(), nil)

   cSql += " CREATE VIEW HAT_STMP_PROC_ATEND_BE2_CONSULTA AS "
   cSql += " SELECT DISTINCT "
   cSql += " BE2_ANOAUT AS AnoAutorizacao, "
   cSql += " BE2_AUDITO AS Auditoria, "
   cSql += " BE2_CODESP AS CodigoEspecialidade, "
   cSql += " BE2_CODLOC AS CodigoLocalAtendimento, "
   cSql += " BE2_CODRDA AS CodigoPrestador, "
   If cDBType == "SQL"
      cSql += " ISNULL(BTU.BTU_CDTERM, BTQ.BTQ_CDTERM) AS CodigoProcedimento, "
      cSql += " ISNULL(BTU.BTU_CODTAB, BTQ.BTQ_CODTAB) AS CodigoTabela, "
   ElseIf cDBType == "POSTGRES"
      cSql += " coalesce(BTU.BTU_CDTERM, BTQ.BTQ_CDTERM) AS CodigoProcedimento, "
      cSql += " coalesce(BTU.BTU_CODTAB, BTQ.BTQ_CODTAB) AS CodigoTabela, "
   Else
      cSql += " NVL(BTU.BTU_CDTERM, BTQ.BTQ_CDTERM) AS CodigoProcedimento, "
      cSql += " NVL(BTU.BTU_CODTAB, BTQ.BTQ_CODTAB) AS CodigoTabela, "
   EndIf
   cSql += " BE2_DATPRO AS DataProcessamento, "
   cSql += " BE2_HORPRO AS HoraProcessamento, "
   cSql += " BE2_LOCAL AS LocalAtendimento, "
   cSql += " BE2_MESAUT AS MesAutorizacao, "
   cSql += " BE2_NUMAUT AS NumeroAutorizacao, "
   cSql += " BE2_OPEMOV AS OperadoraMovimentacao, "
   cSql += " BE2_OPERDA AS OperadoraPrestador, "
   cSql += " BE2_QTDPRO AS QuantidadeAutorizada, "
   cSql += " BE2_QTDSOL AS QuantidadeSolicitada, "
   cSql += " BE2_SALDO AS SaldoProcedimento, "
   cSql += " BE2_SEQUEN AS SequencialProcedimento, "
   cSql += " BE2_STATUS AS Status, "
   cSql += " BE2_TIPO AS Tipo, "
   cSql += " BE2.D_E_L_E_T_  AS Deletado "
   cSql += " FROM " + RETSQLName("BE2") + " BE2 "
   cSql += " INNER JOIN " + RETSQLName("BEA") + " BEA ON (BEA_OPEMOV = BE2_OPEMOV AND BEA_ANOAUT = BE2_ANOAUT AND BEA_MESAUT = BE2_MESAUT AND BEA_NUMAUT = BE2_NUMAUT AND BEA.D_E_L_E_T_ = ' ' ) "
   cSql += " INNER JOIN " + RETSQLName("BCI") + " BCI ON BEA_FILIAL = '"  + xFILIAL("BEA") + "' AND BEA_OPEMOV = BCI_CODOPE AND BEA_CODPEG = BCI_CODPEG AND BEA_CODRDA = BCI_CODRDA AND BCI_CODLDP = '9999' AND BCI_FASE <> '4' " 
   If cDBType == "SQL"
      cSql += " LEFT JOIN " + RETSQLName("BTU") + " BTU ON (1=1 AND BTU.BTU_VLRSIS = BE2_FILIAL + BE2_CODPAD + BE2_CODPRO AND BTU.D_E_L_E_T_ = ' ') "
      cSql += " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON (1=1 AND BTQ.BTQ_CDTERM = BE2_CODPRO AND BTQ.D_E_L_E_T_ = ' ') "
      cSql += " WHERE 1=1 AND BE2.S_T_A_M_P_ > (DATEADD(HOUR, -1, GETUTCDATE())) "
   ElseIf cDBType == "POSTGRES"
      cSql += " LEFT JOIN " + RETSQLName("BTU") + " BTU ON BTU.BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRBUS = BE2_CODPRO AND BTU.D_E_L_E_T_ = ' ' "
      cSql += " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON BTQ.BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CDTERM = BE2_CODPRO AND BTQ.D_E_L_E_T_ = ' ' "
      cSql += " WHERE 1=1 AND BE2.S_T_A_M_P_ > (current_timestamp - interval'1 hours') "
   Else
      cSql += " LEFT JOIN " + RETSQLName("BTU") + " BTU ON BTU.BTU_FILIAL = '"  + xFILIAL("BTU") + "' AND BTU.BTU_VLRBUS = BE2_CODPRO AND BTU.D_E_L_E_T_ = ' ' "
      cSql += " LEFT JOIN " + RETSQLName("BTQ") + " BTQ ON BTQ.BTQ_FILIAL = '"  + xFILIAL("BTQ") + "' AND BTQ.BTQ_CDTERM = BE2_CODPRO AND BTQ.D_E_L_E_T_ = ' ' "
      cSql += " WHERE 1=1 AND BE2.S_T_A_M_P_ > (SYS_EXTRACT_UTC(systimestamp) - INTERVAL '1' HOUR) "
   EndIf
   cSql += " AND BEA_OPEMOV = '0001' AND BEA_ORIMOV = '1' AND BEA_TIPGUI = '01' AND BEA_LIBERA = '0' AND BEA_NUMGUI <> '' "
   cSql += " AND (BTQ_CODTAB IS NULL OR BTQ_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql += " AND (BTU_CODTAB IS NULL OR BTU_CODTAB IN ('00', '18', '19', '20', '22', '90', '98')) "
   cSql += " AND ((BTU_CODTAB IS NOT NULL AND BTU_CDTERM IS NOT NULL) OR (BTQ_CODTAB IS NOT NULL AND BTQ_CDTERM IS NOT NULL)) "

   nStatus := TCSqlExec(cSql)

   clog += iIf(nStatus < 0 .AND. lSTMP == .t., "Ocorreu erro na seguinte view:  HAT_STMP_PROC_ATEND_BE2_CONSULTA "  + TCSQLError() , ;
                  iIf(nStatus >= 0 .AND. lSTMP == .t., "View criada com sucesso: HAT_STMP_PROC_ATEND_BE2_CONSULTA", ;
                        iIf(nStatus < 0 .AND. lSTMP == .f., "Ocorreu erro na seguinte view:  HAT_STMP_PROC_ATEND_BE2_CONSULTA" + TCSQLError() , "View criada com sucesso:  HAT_STMP_PROC_ATEND_BE2_CONSULTA"))) + CRLF

   If lLogOk == .T.
      lLogOk := iIf(nStatus < 0, .F., .T.)
   EndIf

Return iIf(lAuto, !(nStatus < 0), nil)
