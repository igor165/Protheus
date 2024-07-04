#INCLUDE "PROTHEUS.CH"
#DEFINE CRLF chr(13) + chr(10)

static cConc := ""
static cSubStr := ""
static cDBType := ""
static cLog := "LOG de Criação das Views - Fast Analytics PLS - As views serão criadas acrescidas de '_V3' aos nomes listados abaixo "+ CRLF+""+CRLF
static lLogOk := .T.
Static aViews := {}
static cLogDtErr := ""

/*/{Protheus.doc} verificaBD
Verifica qual o banco de dados que esta sendo utilizado
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
static function verificaBD()
   local cDB := TCGetDB()
   local cDBText := "ORACLE DB2 INFORMIX POSTGRES"


   if (cDB $ cDBText)
      cConc := "||"
      cSubStr := 'SUBSTR'
      cDBType := "Oracle"
   else
      cConc := "+"
      cSubStr := 'SUBSTRING'
      cDBType := "SQL"
   endif

return cConc


/*/{Protheus.doc} dropViews
Remove todas as views
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
static function dropViews()
   local aDrop := {}
   local nLinha := 0

   aDrop := {"DROP VIEW Abrangencia_BF7_V3", "DROP VIEW  Acomodacao_BI4_V3", "DROP VIEW   Beneficiarios_BA1_V3", "DROP VIEW   Bloqueio_Beneficiario_BG3_V3",;
      "DROP VIEW   Bloqueios_Subcontrato_BQU_V3", "DROP VIEW   CEP_BC9_V3", "DROP VIEW   Classe_Eventos_BJE_V3", "DROP VIEW   Classe_Rede_BAG_V3", "DROP VIEW   Classe_Sip_BF0_V3",;
      "DROP VIEW  Eventos_Saude_BR8_V3", "DROP VIEW  Familias_BA3_V3", "DROP VIEW  Fato_Despesas_V3", "DROP VIEW  Fato_Movimentacao_RDA_V3", "DROP VIEW  Fornecedores_SA2_V3",;
      "DROP VIEW  Grau_Parentesco_BRP_V3", "DROP VIEW  Grupo_Empresa_BG9_V3", "DROP VIEW  Modalid_Cobr_Prod_BI3_V3", "DROP VIEW  Municipio_BID_V3",;
      "DROP VIEW   Clientes_SA1_V3", "DROP VIEW  Rede_Atendimento_BAU_V3", "DROP VIEW  Segmentacao_BI6_V3", "DROP VIEW  Subcontrato_BQC_V3", "DROP VIEW  Tipo_Contrato_BII_V3",;
      "DROP VIEW  Tipo_Partic_Servico_BWT_V3", "DROP VIEW  Tipos_Eventos_Saude_BR4_V3", "DROP VIEW  Vendedores_SA3_V3", "DROP VIEW  Unidade_Medida_BD3_V3",;
      "DROP VIEW  Motivos_Bloqueio_RDA_BAP_V3", "DROP VIEW  Municipios_BID_V3", "DROP VIEW   Conselhos_Regionais_BAH_V3", "DROP VIEW   Contratos_BT5_V3",;
      "DROP VIEW  Cids_BA9_V3", "DROP VIEW  Equipes_Vendas_BXL_V3", "DROP VIEW  Especialidade_BAQ_V3", "DROP VIEW  Especial_Solicit_BAQ_V3",;
      "DROP VIEW  Tipos_de_Guia_BCL_V3", "DROP VIEW  Tipo_Beneficiario_BIH_V3", "DROP VIEW  Profissional_Solic_BB0_V3", "DROP VIEW  Produtos_BI3_V3",;
      "DROP VIEW  Operadora_BA0_V3", "DROP VIEW  Fato_Receitas_V3", "DROP VIEW  Fato_Autorizacoes_V3", "DROP VIEW  Fato_Movim_Beneficiario_V3",;
      "DROP VIEW  Local_Atendimento_BD1_V3", "DROP VIEW  Profissional_Executante_BB0_V3",;
      "DROP VIEW Fato_Hist_Reaj_Subcontrato_V3",;
      "DROP VIEW Fato_Virt_Simul_Fx_Ans_S_V3",;
      "DROP VIEW Fato_Virt_Dados_Ca_Pro_S_V3",;
      "DROP VIEW Fato_Faixas_Eta_Subc_BTN_V3",;
      "DROP VIEW Fato_Faixas_Eta_Prod_BB3_V3",;
      "DROP VIEW Suspects_ACH_V3",;
      "DROP VIEW Prospects_SUS_V3",;
      "DROP VIEW Formas_de_Cobranca_BJ1_V3"}

   aViews := aClone(aDrop)

   for nLinha := 1 to len(aDrop)
      TCSqlExec(aDrop[nLinha])
   next

return


/*/{Protheus.doc} PLSX001
Executa todas as funções de criação de view
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function PLSX001(lAutoma)
   LOCAL nLoop := 0

   default lAutoma := .F.
   dropViews()
   verificaBD()

   if ! vldRegDt(lAutoma)
      msgstop("Criação das views abortada, realize a correção dos resgistros presentes no log e refaça a operação.", "Operação abortada")
      return
   endif

   Fast_D_BF7()
   Fast_D_BI4()
   Fast_D_BG3()
   Fast_D_BQU()
   Fast_D_BC9()
   Fast_D_BJE()
   Fast_D_BAG()
   Fast_D_BF0()
   Fast_D_SA1()
   Fast_D_BAH()
   Fast_D_BT5()
   Fast_D_BA9()
   Fast_D_BXL()
   Fast_D_BAQ()
   Fast_D_BR8()
   Fast_D_BA1()
   Fast_D_BA3()
   Fast_F_Aut()
   Fast_F_Des()
   Fast_F_Ben()
   Fast_F_Mov()
   Fast_F_Rec()
   Fast_D_SA2()
   Fast_D_BRP()
   Fast_D_BG9()
   Fast_D_BD1()
   Fast_D_BI3()
   Fast_D_BAP()
   Fast_D_BID()
   Fast_D_BA0()
   Fast_D_BB0()
   Fast_D_BAU()
   Fast_D_BI6()
   Fast_D_BQC()
   Fast_D_BIH()
   Fast_D_BII()
   Fast_D_BWT()
   Fast_D_BCL()
   Fast_D_BR4()
   Fast_D_BD3()
   Fast_D_SA3()
   Fast_F_V1()
   Fast_F_V3()
   Fast_F_BYC()
   Fast_D_BJ1()
   Fast_F_BB3()
   Fast_F_BTN()
   Fast_D_ACH()
   Fast_D_SUS()
   PLSLOGFIL(cLog,"PLSGOODDATA.LOG")

   If lLogOk
      for nLoop := 1 to len(aViews)

         if(cDBType == "SQL")
            cSql := StrTran(aViews[nLoop],"DROP VIEW","SELECT TOP 10000 * FROM")
         Else
            cSql := StrTran(aViews[nLoop],"DROP VIEW","SELECT * FROM")
            cSql += " WHERE rownum <= 10000 "
         Endif

         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TrbView",.T.,.T.)
         cLog  += "View "+ StrTran(aViews[nLoop],"DROP VIEW","")+" Executada com sucesso para as 10.000 primeiras linhas"+ CRLF
         TrbView->(DbCloseArea())
         PLSLOGFIL(cLog,"PLSGOODDATA.LOG")
      next
   Endif

   if !lAutoma
      if !lLogOk
         MsgStop("Há erros no arquivo. Verifique o Log para informações sobre os erros encontrados.")
      else
         MsgInfo("Querys executadas com sucesso.")
      endif

      if MsgYesNo("Deseja salvar um log do processo?", "Gravar Log")
         cFile := cgetfile("Arquivo LOG|*.log", 'Selecione o diretorio para salvar o log...', 1, plsmudsis('\'), .t., GETF_LOCALHARD + GETF_RETDIRECTORY, .t., .t.)
         cFile += "log_" + dtos(ddatabase) + "_" + strtran(time(),":","") + ".log"
         nHandle := FCREATE(cFile)
         FWrite(nHandle, cLog)
         FClose(nHandle)
      endif
   else
      return lLogOk
   endif

return

/*/{Protheus.doc} Fast_D_BF7
Executa query que cria view Abrangencia_BF7
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BF7()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Abrangencia_BF7_V3 AS "
   cSql +=  " SELECT BF7_CODORI Codigo_Abrangencia, BF7_DESORI Desc_Abrangencia FROM " + RETSQLName("BF7") + " WHERE BF7_FILIAL = '" + xFILIAL("BF7") + "' AND D_E_L_E_T_ <> '*'"

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Abrangencia_BF7" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Abrangencia_BF7" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BI4
Executa query que cria view Acomodacao_BI4
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BI4()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Acomodacao_BI4_V3 AS "
   cSql += " SELECT BI4_CODACO Codigo_Acomodacao, BI4_DESCRI Desc_Acomodacao FROM " + RETSQLName("BI4") + " WHERE BI4_FILIAL = '" + xFILIAL("BI4") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Acomodacao_BI4" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Acomodacao_BI4" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BA1
Executa query que cria view Beneficiarios_BA1
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BA1()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Beneficiarios_BA1_V3 AS "

   cSql +=  " SELECT "
   cSql +=  " BA1_CODINT" + cConc + "BA1_CODEMP" + cConc + "BA1_MATRIC" + cConc + "BA1_TIPREG " + cConc + " BA1_DIGITO Matricula_Completa_Ben, "
   cSql +=  " BA1_CODINT" + cConc + "BA1_CODEMP" + cConc + "BA1_MATRIC Matricula_Familia, "
   cSql +=  " BA1_TIPREG Tipo_de_Ben, "
   cSql +=  " BA1_DIGITO Digito_Verificador_Ben, "
   cSql +=  " BA1_NOMUSR Nome_do_Ben, "

   cSql +=  MontaSqlData("BA1_DATNAS","Data_de_Nascimento_do_Ben")

   cSql +=  " CASE "
   cSql +=  " WHEN "
   cSql +=  " BA1_SEXO = '1' "
   cSql +=   " THEN "
   cSql +=  " 'Masculino' "
   cSql +=   " ELSE "
   cSql +=  " 'Feminino' "
   cSql +=  " END "
   cSql +=  " AS Sexo_do_Ben , "

   cSql +=  " CASE "
   if(cDBType == "SQL")
      cSql += " WHEN "
      cSql +=  " FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) <= 18 "
      cSql += " THEN "
      cSql += " '00 a 18 Anos' "
      cSql += " WHEN "
      cSql += " FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) >= 19 "
      cSql += " AND FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) <= 23 "
      cSql += " THEN "
      cSql += " '19 a 23 Anos' "
      cSql += " WHEN "
      cSql += " FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) >= 24 "
      cSql += " AND FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) <= 28 "
      cSql += " THEN "
      cSql += " '24 a 28 Anos' "
      cSql += " WHEN "
      cSql += " FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) >= 29 "
      cSql += " AND FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) <= 33 "
      cSql += " THEN "
      cSql += " '29 a 33 Anos' "
      cSql += " WHEN "
      cSql += " FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) >= 34 "
      cSql += " AND FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) <= 38 "
      cSql += " THEN "
      cSql += " '34 a 38 Anos' "
      cSql += " WHEN "
      cSql += " FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) >= 39 "
      cSql += " AND FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) <= 43 "
      cSql += " THEN "
      cSql += " '39 a 43 Anos' "
      cSql += " WHEN "
      cSql += " FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) >= 44 "
      cSql += " AND FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) <= 48 "
      cSql += " THEN "
      cSql += " '44 a 48 Anos' "
      cSql += " WHEN "
      cSql += " FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) >= 49 "
      cSql += " AND FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) <= 53 "
      cSql += " THEN "
      cSql += " '49 a 53 Anos' "
      cSql += " WHEN "
      cSql += " FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) >= 54 "
      cSql += " AND FLOOR(DATEDIFF(DAY, convert(datetime, BA1_DATNAS), GETDATE()) / 365.25) <= 58 "
      cSql += " THEN "
      cSql += " '54 a 58 Anos' "
      cSql += " ELSE "
      cSql += " '59 Anos ou mais' "
   else

      cSql += " WHEN  BA1_DATNAS = '"+Space(08)+"'  THEN ' ' "
      cSql += " WHEN  FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) <= 18 THEN '00 a 18 anos'
      cSql += " WHEN  FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) >= 19  AND FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) <= 23  THEN  '19 a 23 Anos'
      cSql += " WHEN  FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) >= 24  AND FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) <= 28  THEN  '24 a 28 Anos'
      cSql += " WHEN  FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) >= 29  AND FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) <= 33  THEN  '29 a 33 Anos'
      cSql += " WHEN  FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) >= 34  AND FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) <= 38  THEN  '34 a 38 Anos'
      cSql += " WHEN  FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) >= 39  AND FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) <= 43  THEN  '39 a 43 Anos'
      cSql += " WHEN  FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) >= 44  AND FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) <= 48  THEN  '44 a 48 Anos'
      cSql += " WHEN  FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) >= 49  AND FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) <= 53  THEN  '49 a 53 Anos'
      cSql += " WHEN  FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) >= 54  AND FLOOR((to_date(sysdate) - TO_DATE((SUBSTR(BA1_DATNAS,7.2)||'/'||SUBSTR(BA1_DATNAS,5,2)||'/'||SUBSTR(BA1_DATNAS,1,4)),'dd/MM/yyyy')) / 365) <= 58  THEN  '54 a 58 Anos'
      cSql += " ELSE  '59 Anos ou mais'
   endif
   cSql += " END "
   cSql += " AS Faixa_Etaria, BA1_OPEORI Operadora_Origem, "

   cSql +=  " CASE "
   cSql +=  " WHEN "
   cSql +=  " BA1_OPEORI <> '"+PlsIntPad()+"' "
   cSql +=   " THEN "
   cSql +=  " 'Sim' "
   cSql +=   " ELSE "
   cSql +=  " 'Não' "
   cSql +=  " END "
   cSql +=  " Ben_Eventual, BA1_CODCCO Codigo_CCO, BA1_LOCSIB LOC_SIB, RA_CC Centro_de_Custo, BA1_OPEORI Ope_origem2, ' ' AS Ori_Contrato "

   cSql +=  " FROM "
   cSql += RETSQLName("BA1") + " , " + RETSQLName("BA3")
   cSql +=  " LEFT JOIN "
   cSql +=  RETSQLName("SRA") + " "
   cSql +=  " ON RA_FILIAL = '"+xFilial("SRA")+"' "
   cSql +=  " AND RA_MAT = BA3_AGMTFU "

   cSql +=  " WHERE "
   cSql +=  " BA1_FILIAL = '" + xFILIAL("BA1") + "'"
   cSql +=  " AND " + RETSQLName("BA1") + ".D_E_L_E_T_ <> '*' "
   cSql +=  " AND BA3_FILIAL = '" + xFILIAL("BA3") + "'"
   cSql +=  " AND BA3_CODINT = BA1_CODINT "
   cSql +=  " AND BA3_CODEMP = BA1_CODEMP "
   cSql +=  " AND BA3_MATRIC = BA1_MATRIC "
   cSql +=  " AND " + RETSQLName("BA3") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Beneficiarios_BA1" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Beneficiarios_BA1" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BG3
Executa query que cria view Bloqueio_Beneficiario_BG3
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BG3()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Bloqueio_Beneficiario_BG3_V3 AS "
   cSql +=  " SELECT BG3_PROPRI" + cConc + "BG3_CODBLO Codigo_Bloqueio_Ben, BG3_DESBLO Desc_Bloqueio_Ben FROM " + RETSQLName("BG3") + " WHERE BG3_FILIAL = '" + xFILIAL("BG3") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += "Ocorreu erro na seguinte view: Bloqueio_Beneficiario_BG3" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Bloqueio_Beneficiario_BG3" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BQU
Executa query que cria view Bloqueios_Subcontrato_BQU
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BQU()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Bloqueios_Subcontrato_BQU_V3 AS "
   cSql +=  " SELECT BQU_CODBLO Motivo_Bloqueio_Subcon, BQU_DESBLO Desc_Bloqueio_Subcon "
   cSql +=  " FROM " + RETSQLName("BQU") + " WHERE BQU_FILIAL = '" + xFILIAL("BQU") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Bloqueios_Subcontrato_BQU" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Bloqueios_Subcontrato_BQU" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BC9
Executa query que cria view CEP_BC9
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BC9()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW CEP_BC9_V3 AS "
   cSql +=  " SELECT BC9_CEP CEP, BC9_END Endereco, BC9_BAIRRO Bairro, BC9_TIPLOG Tipo_Logradouro, BC9_CODMUN Codigo_Municipio, "
   cSql +=  " BC9_EST Estado FROM " + RETSQLName("BC9") + " WHERE BC9_FILIAL = '" + xFILIAL("BC9") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: CEP_BC9" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : CEP_BC9" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BJE
Executa query que cria view Classe_Eventos_BJE
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BJE()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Classe_Eventos_BJE_V3 AS "
   cSql +=  " SELECT BJE_CODIGO Codigo_Classe_Eventos, BJE_DESCRI Desc_Classe_Eventos FROM " + RETSQLName("BJE") + " WHERE BJE_FILIAL = '" + xFILIAL("BC9") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Classe_Eventos_BJE" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Classe_Eventos_BJE" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BAG
Executa query que cria view Classe_Rede_BAG
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BAG()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Classe_Rede_BAG_V3 AS "
   cSql +=  " SELECT BAG_CODIGO Cod_Classe_Rede_Aten, BAG_DESCRI Desc_Classe_Rede_Aten FROM " + RETSQLName("BAG") + " WHERE BAG_FILIAL = '" + xFILIAL("BAG") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Classe_Rede_BAG" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Classe_Rede_BAG" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BF0
Executa query que cria view Classe_Sip_BF0
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BF0()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Classe_Sip_BF0_V3 AS"
   cSql +=  " SELECT BF0_CODIGO Codigo_CLasse_SIP, BF0_DESCRI Desc_Classe_SIP FROM " + RETSQLName("BF0")
   cSql +=  " WHERE BF0_FILIAL = '" + xFILIAL("BF0") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Classe_Sip_BF0" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Classe_Sip_BF0" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_SA1
Executa query que cria view Clientes_SA1
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_SA1()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Clientes_SA1_V3 AS "
   cSql +=  " SELECT A1_COD" + cConc + "A1_LOJA Codigo_do_Cliente,  A1_NOME Nome_do_Cliente, A1_PESSOA Tipo_de_Cliente, A1_ESTADO Estado_Cliente, "
   cSql +=  " A1_COD_MUN Municipio_Cliente, "
   cSql +=  " A1_CEP CEP_Cliente, A1_CGC CGC_Cliente FROM " + RETSQLName("SA1") + " WHERE A1_FILIAL = '" + xFILIAL("SA1") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Clientes_SA1" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Clientes_SA1" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BAH
Executa query que cria view Conselhos_Regionais_BAH
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BAH()

   local cSql := ""
   local nStatus := 0


   cSql +=  " CREATE VIEW Conselhos_Regionais_BAH_V3 AS "
   cSql +=  " SELECT BAH_CODIGO Codigo_Conselho_Regional, BAH_DESCRI Desc_Conselho_Regional FROM " + RETSQLName("BAH") + " WHERE BAH_FILIAL = '" + xFILIAL("BAH") + "' AND " + RETSQLName("BAH") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Conselhos_Regionais_BAH" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Conselhos_Regionais_BAH" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BT5
Executa query que cria view Contratos_BT5
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BT5()

   local cSql := ""
   local nStatus := 0


   cSql +=  " CREATE VIEW Contratos_BT5_V3 AS "
   cSql +=  " SELECT BT5_CODINT" + cConc + "BT5_CODIGO" + cConc + "BT5_NUMCON Cod_Operadora_Emp_Num_Con, BT5_CODINT Codigo_Operadora, BT5_CODIGO Codigo_Grupo_Empresa, BT5_NUMCON Numeror_Contato, "

   cSql +=  MontaSqlData("BT5_DATCON","Data_do_Con",.F.)

   cSql += "FROM " + RETSQLName("BT5") + " WHERE BT5_FILIAL = '" + xFILIAL("BT5") + "' AND D_E_L_E_T_ <> '*' UNION ALL SELECT BG9_CODINT" + cConc + "BG9_CODIGO" + cConc + "'-1',  BG9_CODINT, BG9_CODIGO, '-1', '19500101'  FROM " + RETSQLName("BG9") + " WHERE BG9_FILIAL = '" + xFILIAL("BG9") + "' AND BG9_TIPO = '1'  AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Contratos_BT5" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Contratos_BT5" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BA9
Executa query que cria view Cids_BA9
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BA9()

   local cSql := ""
   local nStatus := 0


   cSql +=  " CREATE VIEW Cids_BA9_V3 AS "
   cSql +=  " SELECT rtrim(ltrim(BA9_CODDOE)) Codigo_da_Doenca,BA9_DOENCA Nome_da_Doenca,BA9_ABREVI Abreviacao_da_Doenca FROM " + RETSQLName("BA9") + " WHERE BA9_FILIAL = '" + xFILIAL("BA9") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Cids_BA9" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Cids_BA9" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BXL
Executa query que cria view Equipes_Vendas_BXL
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BXL()

   local cSql := ""
   local nStatus := 0


   cSql +=  " CREATE VIEW Equipes_Vendas_BXL_V3 AS "
   cSql +=  " SELECT BXL_CODEQU Codigo_Equipe_Venda, BXL_DESEQU Nome_Equipe_Venda FROM " + RETSQLName("BXL") + " WHERE BXL_FILIAL = '" + xFILIAL("BXL") + "' AND " + RETSQLName("BXL") +".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Equipes_Vendas_BXL" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Equipes_Vendas_BXL" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BAQ
Executa query que cria view Especialidade_BAQ e Especialidade_Solicitante_BAQ
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BAQ()

   local cSql := ""
   local cSqlSol := ""
   local nStatus := 0


   cSql +=  " CREATE VIEW Especialidade_BAQ_V3 AS "
   cSql +=  " SELECT BAQ_CODESP Codigo_da_Especialidade, BAQ_DESCRI Desc_da_Especialidade, BAQ_CBOS CBOS_da_Especialidade "
   cSql +=  " FROM " + RETSQLName("BAQ") + " WHERE BAQ_FILIAL = '" + xFILIAL("BAQ") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Especialidade_BAQ" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Especialidade_BAQ" + CRLF
   endif


   cSqlSol :=  " CREATE VIEW Especial_Solicit_BAQ_V3 AS "
   cSqlSol +=  " SELECT BAQ_CODESP Codigo_da_Especialidade, BAQ_DESCRI Desc_da_Especialidade, BAQ_CBOS CBOS_da_Especialidade "
   cSqlSol +=  " FROM " + RETSQLName("BAQ") + " WHERE BAQ_FILIAL = '" + xFILIAL("BAQ") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSqlSol)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Especial_Solicit_BAQ_V3" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Especial_Solicit_BAQ_V3" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BR8
Executa query que cria view Eventos_Saude_BR8
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BR8()

   local cSql := ""
   local nStatus := 0


   cSql +=  " CREATE VIEW Eventos_Saude_BR8_V3 AS "
   cSql +=  " SELECT BR8_CODPAD Codigo_Tipo_Evento_Saude, BR8_CODPSA Codigo_Evento_Saude, BR8_DESCRI Desc_Evento_Saude, BR8_CLASSE Classe_Evento_Saude FROM " + RETSQLName("BR8") + " WHERE BR8_FILIAL = '" + xFILIAL("BR8") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Eventos_Saude_BR8" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Eventos_Saude_BR8" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BA3
Executa query que cria view Familias_BA3
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BA3()

   local cSql := ""
   local nStatus := 0


   cSql += " CREATE VIEW Familias_BA3_V3 AS"
   cSql += " SELECT BA3_CODINT" + cConc + "BA3_CODEMP" + cConc + "BA3_MATRIC Matricula_da_Familia FROM " + RETSQLName("BA3") + " WHERE BA3_FILIAL = '" + xFILIAL("BA3") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Familias_BA3" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Familias_BA3" + CRLF
   endif

return


/*/{Protheus.doc} Fast_F_Aut
Executa query que cria view Fato_Autorizacoes
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/

function Fast_F_Aut()

   local cSql := ""
   local nStatus := 0


   cSql +=  " SELECT "
   cSql +=  " CASE "
   cSql += " WHEN "
   cSql += " BE2_NUMINT = '"+Space(Len(BE2->BE2_NUMINT))+"' "
   cSql += " THEN "
   cSql += " BE2_OPEMOV " + cConc + " BE2_ANOAUT " + cConc + " BE2_MESAUT " + cConc + " BE2_NUMAUT "
   cSql += " ELSE "
   cSql += " BE2_OPEMOV " + cConc + " BE2_ANOINT " + cConc + " BE2_MESINT " + cConc + " BE2_NUMINT "
   cSql += " END "
   cSql += " AS Numero_Guia, BE2_SEQUEN, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_TIPO = '1' "
   cSql += " THEN "
   cSql += " 'Consulta' "

   cSql += " WHEN "
   cSql += " BE2_TIPO = '2' "
   cSql += " THEN "
   cSql += " 'SADT' "

   cSql += " WHEN "
   cSql += " BE2_TIPO = '3' "
   cSql += " THEN "
   cSql += " 'Internação' "

   cSql += " WHEN "
   cSql += " BE2_TIPO = '4' "
   cSql += " THEN "
   cSql += " 'Odontológico' "

   cSql += " WHEN "
   cSql += " BE2_TIPO = '7' "
   cSql += " THEN "
   cSql += " 'Quimioterapia' "

   cSql += " WHEN "
   cSql += " BE2_TIPO = '8' "
   cSql += " THEN "
   cSql += " 'Radioterapia' "

   cSql += " WHEN "
   cSql += " BE2_TIPO = '9' "
   cSql += " THEN "
   cSql += " 'OPME' "

   cSql += " ELSE "
   cSql += " 'Não definida' "
   cSql += " END "
   cSql += " as Tipo_Guia, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_TPGRV = '1' "
   cSql += " THEN "
   cSql += " 'Central de Atendimento' "

   cSql += " WHEN "
   cSql += " BE2_TPGRV = '2' "
   cSql += " THEN "
   cSql += " 'Portal' "

   cSql += " WHEN "
   cSql += " BE2_TPGRV = '3' "
   cSql += " THEN "
   cSql += " 'POS' "

   cSql += " WHEN "
   cSql += " BE2_TPGRV = '4' "
   cSql += " THEN "
   cSql += " 'Importação Manual' "
   cSql += " ELSE "
   cSql += " 'Não definida' "
   cSql += " END "
   cSql += " as Origem_Guia, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_STATUS = '1' "
   cSql += " THEN "
   cSql += " 'Autorizada' "

   cSql += " WHEN "
   cSql += " BE2_STATUS = '2' "
   cSql += " THEN "
   cSql += " 'Autorizada Parcialmente' "

   cSql += " WHEN "
   cSql += " BE2_STATUS = '0' "
   cSql += " THEN "
   cSql += " 'Não Autorizada' "

   cSql += " WHEN "
   cSql += " BE2_STATUS = '4' "
   cSql += " THEN "
   cSql += " 'Aguardando finalizaçãoo do Atenidmento' "

   cSql += " WHEN "
   cSql += " BE2_STATUS = '6' "
   cSql += " THEN "
   cSql += " 'Em Análise pela Auditoria' "
   cSql += " ELSE "
   cSql += " 'Não definida' "
   cSql += " END "
   cSql += " as Status_Guia, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_AUDITO = '1' "
   cSql += " THEN "
   cSql += " 'Sim' "
   cSql += " ELSE "
   cSql += " 'Não' "
   cSql += " END "
   cSql += " AS Auditoria, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_ATEAMB = '1' "
   cSql += " THEN "
   cSql += " 'Sim' "
   cSql += " ELSE "
   cSql += " 'Não' "
   cSql += " END "
   cSql += " AS Ambulatorial, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_PROCCI = '1' "
   cSql += " THEN "
   cSql += " 'Sim' "
   cSql += " ELSE "
   cSql += " 'Não' "
   cSql += " END "
   cSql += " AS Proc_Cirurgico, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_GUIACO = '1' "
   cSql += " THEN "
   cSql += " 'Sim' "
   cSql += " ELSE "
   cSql += " 'Não' "
   cSql += " END "
   cSql += " AS Guia_Comprada, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_QUACOB = '1' "
   cSql += " THEN "
   cSql += " 'No Ato' "
   cSql += " ELSE "
   cSql += " 'Na próxima fatura' "
   cSql += " END "
   cSql += " AS Quando_Cobrada, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_LIBESP = '1' "
   cSql += " THEN "
   cSql += " 'Sim' "
   cSql += " ELSE "
   cSql += " 'Não' "
   cSql += " END "
   cSql += " AS Liberacao_Especial, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_LIBERA = '1' "
   cSql += " THEN "
   cSql += " 'Solicitação' "
   cSql += " ELSE "
   cSql += " 'Execução' "
   cSql += " END "
   cSql += " AS Liberacao, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_PACOTE = '1' "
   cSql += " THEN "
   cSql += " 'Sim' "
   cSql += " ELSE "
   cSql += " 'Não' "
   cSql += " END "
   cSql += " AS Pacote, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE2_STALIB = '1' "
   cSql += " THEN "
   cSql += " 'Em Aberto' "
   cSql += " ELSE "
   cSql += " 'Fechada' "
   cSql += " END "
   cSql += " AS Status_Liberacao, BE2_DENREG Dente, BE2_FADENT Face, BE2_HORPRO Horario, "
   cSql += " BE2_OPEMOV " + cConc + " BE2_CODLDP " + cConc + " BE2_CODPEG " + cConc + " BE2_NUMERO NUMGUIAPROCCONTAS, BCI_CODPEG Protocolo, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BCI_STTISS = '1' "
   cSql += " THEN "
   cSql += " 'Recebido' "

   cSql += " WHEN "
   cSql += " BCI_STTISS = '2' "
   cSql += " THEN "
   cSql += " 'Em análise' "

   cSql += " WHEN "
   cSql += " BCI_STTISS = '3' "
   cSql += " THEN "
   cSql += " 'Liberado para pagamento' "

   cSql += " WHEN "
   cSql += " BCI_STTISS = '4' "
   cSql += " THEN "
   cSql += " 'Encerrado sem pagamento' "

   cSql += " WHEN "
   cSql += " BCI_STTISS = '5' "
   cSql += " THEN "
   cSql += " 'Analisado e aguardando liberação para o pagamento' "

   cSql += " WHEN "
   cSql += " BCI_STTISS = '6' "
   cSql += " THEN "
   cSql += " 'Pagamento efetuado' "

   cSql += " WHEN "
   cSql += " BCI_STTISS = '7' "
   cSql += " THEN "
   cSql += " 'Não localizado' "

   cSql += " WHEN "
   cSql += " BCI_STTISS = '8' "
   cSql += " THEN "
   cSql += " 'Aguardando informação complementar' "

   cSql += " ELSE "
   cSql += " 'Não definida' "
   cSql += " END "
   cSql += " as Status_TISS, BE2_QTDPRO Quantidade_Eventos, BE2_SALDO Saldo_Eventos, BE2_QTDDEN Quantidade_Dentes, "
   cSql += " BE2_QTDSOL Quantidade_Solicitada, "

   cSql += " (SELECT SUM(BD7_VLRPAG) FROM " + RETSQLName("BD7") + " WHERE BD7_FILIAL = '" + xFILIAL("BD7") + "' AND BD7_CODOPE = BE2_OPEMOV AND BD7_CODLDP = BE2_CODLDP AND "
   cSql += " BD7_CODPEG = BE2_CODPEG AND BD7_NUMERO = BE2_NUMERO AND BD7_SEQUEN = BE2_SEQUEN AND " + RETSQLName("BD7") + ".D_E_L_E_T_ <> '*')  Valor_Despesa_Prevista, "

   cSql += " BE2_TIPGUI Tipo_de_Guia, BE2_CODPAD Codigo_Tipo_Evento, BE2_CODPRO Codigo_Evento_Saude, BE2_CODESP Codigo_Especialidade, "
   cSql += " BE2_CODRDA Codigo_Rede_Aten, BB8_CODMUN Municipio_Despesas, BA1_CODINT " + cConc + " BA1_CODEMP Cod_Operadora_Grupo_Emp, "
   cSql += " BA1_CODINT " + cConc + " BA1_CODEMP " + cConc + " BA1_CONEMP " + cConc + " BA1_SUBCON Cod_Operadora_Emp_Num_Subcon, "
   cSql += " BAU_TIPPRE Classe_Rede_Aten, BE2_CID CID, BE2_OPEMOV Operadora_Movimentacao, "
   cSql += " BA1_CODINT " + cConc + " BA1_CODEMP " + cConc + " BA1_CONEMP Cod_Operadora_Emp_Num_Con, "
   cSql += " BE2_CDPFSO Cod_Profisional_Solici, BE2_CDPFRE Cod_Profisional_Executante, BB8_LOCAL Local_Atendimento, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_CODVEN = '"+Space(Len(BA1->BA1_CODVEN))+"' "
   cSql += " THEN "
   cSql += " RTRIM(LTRIM(BA3_CODVEN)) "
   cSql += " ELSE "
   cSql += " LTRIM(RTRIM(BA1_CODVEN)) "
   cSql += " END "
   cSql += " AS VENDEDOR, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_EQUIPE = '"+Space(Len(BA1->BA1_EQUIPE))+"' "
   cSql += " THEN "
   cSql += " BA3_EQUIPE "
   cSql += " ELSE "
   cSql += " BA1_EQUIPE "
   cSql += " END "
   cSql += " AS EQUIPE, RTRIM(LTRIM(BE4_PADINT)) Acomodacao, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA3_CODPLA = '"+Space(Len(BA3->BA3_CODPLA))+"' "
   cSql += " THEN "
   cSql += " BA1_CODINT " + cConc + " BA1_CODPLA "
   cSql += " ELSE "
   cSql += " BA3_CODINT " + cConc + " BA3_CODPLA "
   cSql += " END "
   cSql += " AS Codigo_Operadora_Produto, BR8_CLASSE Classe_Evento, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_CODMUN <> '"+Space(Len(BA1->BA1_CODMUN))+"' "
   cSql += " THEN "
   cSql += " BA1_CODMUN "
   cSql += " ELSE "
   cSql += " BA3_CODMUN "
   cSql += " END "
   cSql += " AS Municipio_Beneficiario, BE2_OPEUSR " + cConc + " BE2_CODEMP " + cConc + " BE2_MATRIC " + cConc + " BE2_TIPREG " + cConc + " BE2_DIGITO Matricula_Completa_Ben, "
   IF cDBType == "SQL"
      cSql += " BE2_ANOAUT " + cConc + " BE2_MESAUT " + cConc + " substring(convert(char, EOMONTH ( Convert(datetime,BE2_ANOAUT+BE2_MESAUT+'01') )),9,2) PERIODO, "
   Else
      cSql += "to_char(LAST_DAY(TO_DATE(TRIM(BE2_ANOAUT||BE2_MESAUT||'01'),'YYYYMMDD')),'YYYYMMDD') PERIODO, "
   endif
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE4_DTDIGI = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BE4_DTDIGI "
   cSql += " END "
   cSql += " AS Data_Ocorrencia, "

   cSql +=  MontaSqlData("BE2_DATPRO","Data_Evento")

   cSql +=  MontaSqlData("BE4_DATPRO","Data_Internacao")

   cSql +=  MontaSqlData("BE4_DTALTA","Data_Alta")

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BE4_DTALTA = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " 0 "
   cSql += " ELSE "
   if(cDBType == "SQL")
      cSql += " case when datediff(day, CONVERT(DATE, BE4_DATPRO), CONVERT(DATE, BE4_DTALTA)) = 0 then 1 else datediff(day, CONVERT(DATE, BE4_DATPRO), CONVERT(DATE, BE4_DTALTA)) end "
   else
      cSql += " CASE "
      cSql += "  WHEN (BE4_DATPRO <> '"+SPACE(08)+"' AND  BE4_DTALTA <> '"+SPACE(08)+"') THEN ( TO_DATE((SUBSTR(BE4_DTALTA,7,2)||'/'||SUBSTR(BE4_DTALTA,5,2)||'/'||SUBSTR(BE4_DTALTA,1,4)),'dd/MM/yyyy') - TO_DATE((SUBSTR(BE4_DATPRO,7,2)||'/'||SUBSTR(BE4_DATPRO,5,2)||'/'||SUBSTR(BE4_DATPRO,1,4)),'dd/MM/yyyy')) "
      cSql += "  ELSE 0 "
      cSql += " END "
   endif
   cSql += " END "
   cSql += " AS PrazoInter, BA3_MODPAG Modalidade_Cobranca, "

   cSql += " ( "
   if(cDBType == "SQL")
      cSql += " SELECT "
      cSql += " TOP 1 BAX_CODESP "
      cSql += " FROM "
      cSql += RETSQLName("BAU") + " , "
      cSql += RETSQLName("BAX") + " , "
      cSql += RETSQLName("BB0") + " "
      cSql += " WHERE "
      cSql += " BAU_FILIAL = '" + xFILIAL("BAU") + "' "
      cSql += " AND " + RETSQLName("BAU") + ".D_E_L_E_T_ <> '*' "
      cSql += " AND BAU_CODBB0 = BE2_CDPFSO "
      cSql += " AND BAX_FILIAL = '" + xFILIAL("BAX") + "' "
      cSql += " AND BAX_CODIGO = BAU_CODIGO "
      cSql += " AND BAX_CODINT = BE2_OPERDA "
      cSql += " AND BAX_CODLOC = BE2_CODLOC "
      cSql += " AND " + RETSQLName("BAX") + ".D_E_L_E_T_ <> '*' "
      cSql += " AND " + RETSQLName("BB0") + ".BB0_FILIAL = '" + xFILIAL("BB0") + "' "
      cSql += " AND BB0_CODIGO = BE2_CDPFSO "
      cSql += " AND " + RETSQLName("BB0") + ".D_E_L_E_T_ <> '*' "
   else
      cSql += " SELECT "
      cSql += " BAX_CODESP "
      cSql += " FROM "
      cSql += RETSQLName("BAU") + " , "
      cSql += RETSQLName("BAX") + " , "
      cSql += RETSQLName("BB0") + " "
      cSql += " WHERE "
      cSql += " BAU_FILIAL = '" + xFILIAL("BAU") + "' "
      cSql += " AND " + RETSQLName("BAU") + ".D_E_L_E_T_ <> '*' "
      cSql += " AND BAU_CODBB0 = BE2_CDPFSO "
      cSql += " AND BAX_FILIAL = '" + xFILIAL("BAX") + "' "
      cSql += " AND BAX_CODIGO = BAU_CODIGO "
      cSql += " AND BAX_CODINT = BE2_OPERDA "
      cSql += " AND BAX_CODLOC = BE2_CODLOC "
      cSql += " AND " + RETSQLName("BAX") + ".D_E_L_E_T_ <> '*' "
      cSql += " AND " + RETSQLName("BB0") + ".BB0_FILIAL = '" + xFILIAL("BB0") + "' "
      cSql += " AND BB0_CODIGO = BE2_CDPFSO "
      cSql += " AND " + RETSQLName("BB0") + ".D_E_L_E_T_ <> '*' "
      cSql += " AND ROWNUM = 1 "
   endif
   cSql += " ) "
   cSql += " AS Especialidade_Solici, "
   cSql += " BA3_CODMUN Municipio_do_Cliente "

   cSql += " FROM "
   cSql += RETSQLName("BA1") + " , "
   cSql += RETSQLName("BA3") + " , "
   cSql += RETSQLName("BAU") + " , "
   cSql += RETSQLName("BB8") + " , "
   cSql += RETSQLName("BR8") + " , "
   cSql += RETSQLName("BE2") + " "
   cSql += " LEFT JOIN "
   cSql += RETSQLName("BE4") + " "
   cSql += " ON BE4_FILIAL = '" + xFILIAL("BE4") +"'"
   cSql += " AND BE4_CODOPE = BE2_OPEMOV "
   cSql += " AND BE4_ANOINT = BE2_ANOINT "
   cSql += " AND BE4_MESINT = BE2_MESINT "
   cSql += " AND BE4_NUMINT = BE2_NUMINT "
   cSql += " AND BE4_ANOINT <> '"+Space(04)+"'"
   cSql += " AND " + RETSQLName("BE4") + ".D_E_L_E_T_ <> '*' "

   cSql += " LEFT JOIN "
   cSql += RETSQLName("BCI") + " "
   cSql += " ON BCI_FILIAL = '" + xFILIAL("BCI") + "' "
   cSql += " AND BCI_CODOPE = BE2_OPEMOV "
   cSql += " AND BCI_CODLDP = BE2_CODLDP "
   cSql += " AND BCI_CODPEG = BE2_CODPEG "
   cSql += " AND " + RETSQLName("BCI") + ".D_E_L_E_T_ <> '*' "
   cSql += " WHERE "
   cSql += " BE2_FILIAL = '" +  xFILIAL("BE2") + "' "

   //BM1_ANO e BM1_MES
   if(cDBType == "SQL")
      cSql += " AND ( BE2_ANOAUT >= datepart(year,getdate())-1    )  "
   Else
      cSql += " AND ( BE2_ANOAUT >= to_char(SYSDATE - 365,'YYYY') )  "
   Endif



   cSql += " AND " + RETSQLName("BE2") + ".D_E_L_E_T_ <> '*' "


   cSql += " AND BAU_FILIAL = '" + xFILIAL("BE2") + "' "
   cSql += " AND BAU_CODIGO = BE2_CODRDA "
   cSql += " AND "+ RETSQLName("BAU") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND BR8_FILIAL = '" + xFILIAL("BR8") + "' "
   cSql += " AND BR8_CODPAD = BE2_CODPAD "
   cSql += " AND BR8_CODPSA = BE2_CODPRO "
   cSql += " AND " + RETSQLName("BR8") + ".D_E_L_E_T_ <> '*' "


   cSql += " AND " + RETSQLName("BE2") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND BB8_FILIAL = '" + xFILIAL("BB8") + "' "
   cSql += " AND BB8_CODINT = BE2_OPERDA "
   cSql += " AND BB8_CODIGO = BE2_CODRDA "
   cSql += " AND BB8_CODLOC = BE2_CODLOC "
   cSql += " AND " + RETSQLName("BB8") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND BA1_FILIAL = '" + xFILIAL("BA1") + "' "
   cSql += " AND BA1_CODINT = BE2_OPEUSR "
   cSql += " AND BA1_CODEMP = BE2_CODEMP "
   cSql += " AND BA1_MATRIC = BE2_MATRIC "
   cSql += " AND BA1_TIPREG = BE2_TIPREG "
   cSql += " AND " + RETSQLName("BA1") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND BA3_FILIAL = '" + xFILIAL("BA3") + "' "
   cSql += " AND BA3_CODINT = BE2_OPEUSR "
   cSql += " AND BA3_CODEMP = BE2_CODEMP "
   cSql += " AND BA3_MATRIC = BE2_MATRIC "
   cSql += " AND " + RETSQLName("BA3") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND NOT ( BE2_LIBERA = '1' AND BE2_STALIB = '2')  "


   cSql += " AND ( NOT EXISTS "
   cSql += "(SELECT BE4_CODOPE FROM "+RetSqlName("BE4")+" BE4XXX WHERE "
   cSql += "BE4XXX.BE4_FILIAL = '"+xFilial("BE4")+"' AND "
   cSql += RetSqlName("BE4")+".BE4_CODOPE"+cConc+" "
   cSql += RetSqlName("BE4")+".BE4_CODLDP"+cConc+" "
   cSql += RetSqlName("BE4")+".BE4_CODPEG"+cConc+" "
   cSql += RetSqlName("BE4")+".BE4_NUMERO = "
   cSql += "BE4XXX.BE4_GUIINT AND BE4XXX.BE4_FASE = '4' AND "
   cSql += "BE4XXX.D_E_L_E_T_ <> '*' ) ) "

   cSqlFinal := " CREATE VIEW Fato_Autorizacoes_V3 AS "+cSql
   nStatus := TCSqlExec(cSqlFinal)
   PLSLOGFil(cSqlFinal,"Fato_Autorizacoes.sql")

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Autorizacoes" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Autorizacoes" + CRLF
   endif

return


/*/{Protheus.doc} Fast_F_Des
Executa query que cria view Fato_Despesas
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_F_Des()

   local cSql := ""
   local nStatus := 0


   cSql +=  " SELECT "

   cSql += " CASE WHEN BD7_TIPGUI <> '04' THEN "
   cSql += " BD7_VLRPAG "
   cSql += " ELSE "
   cSql += " B47_VLRPAG "
   cSql += " END AS Valor_Despesas, "

   cSql += " BD7_VLRGLO Valor_Glosa, "
   cSql += " BD7_CODOPE Codigo_Operadora, "
   cSql += " BD7_CODOPE " + cConc + " BD7_CODEMP Cod_Operadora_Grupo_Emp, "
   cSql += " BD7_MATRIC Matricula_da_Familia, "
   cSql += " BD7_TIPREG Sequencia_Identificacao_Ben, "
   cSql += " BA1_DIGITO Digito_Verificador_Ben, "
   cSql += " BD7_CODOPE " + cConc + " BD7_CODEMP " + cConc + " BD7_CONEMP Cod_Operadora_Emp_Num_Con, "
   cSql += " BD7_CODOPE " + cConc + " BD7_CODEMP " + cConc + " BD7_CONEMP " + cConc + " BD7_SUBCON Cod_Operadora_Emp_Num_Subcon, "

   IF cDBType == "SQL"
      cSql += " BD7_ANOPAG " + cConc + " BD7_MESPAG " + cConc + " substring(convert(char, EOMONTH ( Convert(datetime,BD7_ANOPAG+BD7_MESPAG+'01') )),9,2) PERIODO, "
   Else
      cSql += " to_char(LAST_DAY(TO_DATE(TRIM(BD7_ANOPAG||BD7_MESPAG||'01'),'YYYYMMDD')),'YYYYMMDD') PERIODO, "
   Endif

   cSql += " BD7_CODOPE " + cConc + " BD7_CODEMP " + cConc + " BD7_MATRIC " + cConc + " BD7_TIPREG " + cConc + " BA1_DIGITO Matricula_Completa_Ben, "
   cSql += " BA1_TIPUSU Tipo_de_Ben, "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA3_CODPLA = '"+Space(Len(BA3->BA3_CODPLA))+"' "
   cSql += " THEN "
   cSql += " BA1_CODINT " + cConc + " BA1_CODPLA "
   cSql += " ELSE "
   cSql += " BA3_CODINT " + cConc + " BA3_CODPLA "
   cSql += " END "
   cSql += " AS Cod_Operadora_Produto, BA1_GRAUPA Grau_Parentesco, BA1_CEPUSR CEP, BA3_ABRANG Abrangencia, BA3_SEGPLA Segmentacao, BA3_CODACO Acomodacao, rtrim(ltrim(BA3_TIPCON)) Tipo_de_Contrato, BAU_TIPPRE Classe_Rede_Atendimento, BD7_CODUNM Codigo_Unidade_Saude, BAU_SIGLCR Conselho, BAU_CBO CBOS, BD7_CODESP Especialidade, BB8_CODMUN Municipio_Despesas, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_CODMUN <> '"+Space(Len(BA1->BA1_CODMUN))+"' "
   cSql += " THEN "
   cSql += " BA1_CODMUN "
   cSql += " ELSE "
   cSql += " BA3_CODMUN "
   cSql += " END "
   cSql += " AS Municipio_Beneficiario, RTRIM(LTRIM(BD7_CID)) CID, BD7_CODPAD Codigo_Tipo_Evento, BD7_CODPRO Codigo_Evento_Saude, "
   cSql += " BD6_CDPFSO Cod_Profissional_Saude_Solici, BD6_CDPFRE Cod_Profissional_Saude_Execu, "

   cSql +=  MontaSqlData("BD7_DATPRO","Data_do_Evento")

   cSql +=  MontaSqlData("BD7_DTPAGT","Data_do_Pagamento_Evento")

   cSql += " CASE WHEN BD7_TIPGUI <> '04' THEN (BD6_QTDPRO*BD7_PERCEN)/100 ELSE (BD6_QTDPRO*B47_PERCEN)/100 END AS Quantidade_Eventos, "

   cSql += " BD7_CODLDP Local_Digitacao, "

   cSql += " BD7_CODPEG Codigo_Prototocolo, BD7_NUMERO Numero_Guia, BD7_SEQUEN Sequencia_Evento_Guia, "
   cSql += " BR8_CLASSE Classe_eventos_Saude, BD7_TIPGUI Tipo_de_Guia, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_CODVEN = '"+Space(Len(BA1->BA1_CODVEN))+"' "
   cSql += " THEN "
   cSql += " BA3_CODVEN "
   cSql += " ELSE "
   cSql += " BA1_CODVEN "
   cSql += " END "
   cSql += " AS VENDEDOR, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_EQUIPE = '"+Space(Len(BA1->BA1_EQUIPE))+"' "
   cSql += " THEN "
   cSql += " BA3_EQUIPE "
   cSql += " ELSE "
   cSql += " BA1_CODVEN "
   cSql += " END "
   cSql += " AS EQUIPE, BB8_LOCAL Local_Atendimento, BD7_CODTPA Tipo_Participacao_Servico, "

   if(cDBType == "SQL")
      cSql += " CASE WHEN BD7_DTPAGT <> '"+SPACE(08)+"'  THEN datediff(day, CONVERT(DATE, BD7_DATPRO), CONVERT(DATE, BD7_DTPAGT)) ELSE  0 END AS PrazoPagto,  "
   else
      cSql += " CASE WHEN (BD7_DTPAGT <> '"+SPACE(08)+"' AND  BD7_DATPRO <> '"+SPACE(08)+"') THEN to_date(BD7_DTPAGT, 'yyyy/mm/dd') - to_date(BD7_DATPRO, 'yyyy/mm/dd') ELSE 0 END AS PrazoPagto, "
   endif

   cSql += " BD7_CODRDA Rede_de_Atendimento, "

   cSql += " ( "
   if(cDBType == "SQL")
      cSql += " SELECT "
      cSql += " TOP 1 BAX_CODESP "
      cSql += " FROM "
      cSql += RETSQLName("BAU") + " , "
      cSql += RETSQLName("BAX") + " , "
      cSql += RETSQLName("BB0") + " "
      cSql += " WHERE "
      cSql += " BAU_FILIAL = '" + xFILIAL("BA3") + "' "
      cSql += " AND " + RETSQLName("BAU") + ".D_E_L_E_T_ <> '*' "
      cSql += " AND BAU_CODBB0 = BD6_CDPFSO "
      cSql += " AND BAX_FILIAL = '" + xFILIAL("BAX") + "' "
      cSql += " AND BAX_CODIGO = BAU_CODIGO "
      cSql += " AND BAX_CODINT = BD7_CODOPE "
      cSql += " AND BAX_CODLOC = BD7_CODLOC "
      cSql += " AND " + RETSQLName("BAX") + ".D_E_L_E_T_ <> '*' "
      cSql += " AND " + RETSQLName("BB0") + ".BB0_FILIAL = '" + xFILIAL("BB0") + "' "
      cSql += " AND BB0_CODIGO = BD6_CDPFSO "
      cSql += " AND " + RETSQLName("BB0") + ".D_E_L_E_T_ <> '*' "
   else
      cSql += " SELECT "
      cSql += " BAX_CODESP "
      cSql += " FROM "
      cSql += RETSQLName("BAU") + " , "
      cSql += RETSQLName("BAX") + " , "
      cSql += RETSQLName("BB0") + " "
      cSql += " WHERE "
      cSql += " BAU_FILIAL = '" + xFILIAL("BA3") + "' "
      cSql += " AND " + RETSQLName("BAU") + ".D_E_L_E_T_ <> '*' "
      cSql += " AND BAU_CODBB0 = BD6_CDPFSO "
      cSql += " AND BAX_FILIAL = '" + xFILIAL("BAX") + "' "
      cSql += " AND BAX_CODIGO = BAU_CODIGO "
      cSql += " AND BAX_CODINT = BD7_CODOPE "
      cSql += " AND BAX_CODLOC = BD7_CODLOC "
      cSql += " AND " + RETSQLName("BAX") + ".D_E_L_E_T_ <> '*' "
      cSql += " AND " + RETSQLName("BB0") + ".BB0_FILIAL = '" + xFILIAL("BB0") + "' "
      cSql += " AND BB0_CODIGO = BD6_CDPFSO "
      cSql += " AND " + RETSQLName("BB0") + ".D_E_L_E_T_ <> '*'"
      cSql += " AND ROWNUM = 1 "
   endif
   cSql += " ) "
   cSql += " AS Especialidade_Solici, "
   cSql += " BA3_MODPAG Modalidade_Cobranca_Produto , "
   cSql += " BA3_GRPCOB Grupo_Cobranca, "
   cSql += " '0' Tipo_Consulta, "
   cSql += " '0' Reconsulta, "
   cSql += " E2_PREFIXO Prefixo_Titulo_Pagar, "
   cSql += " E2_NUM Numero_Titulo_Pagar, "
   cSql += " E2_PARCELA Parcela_Titulo_Pagar, "
   cSql += " E2_TIPO Tipo_Titulo_Pagar, "

   cSql += MontaSqlData("E2_EMISSAO","Emissao_Titulo_Pagar")

   cSql += MontaSqlData("E2_BAIXA","Baixa_Titulo_Pagar")

   cSql += " E2_VALOR Valor_Titulo_Pagar, "
   cSql += " E2_SALDO Saldo_Titulo_Pagar, "

   cSql +=  MontaSqlData("E2_VENCREA","Vencimento_Titulo_Pagar")

   cSql += " E2_FORNECE Codigo_Fornecedor, "
   cSql += " BR8_CLASIP Codigo_Classe_SIP, "
   cSql += " BA3_CODMUN Municipio_do_Cliente, "

   cSql += " BD7_CODOPE " + cConc + " BD7_CODLDP " + cConc + " BD7_CODPEG " + cConc + " BD7_NUMERO " + cConc+ " BD7_SEQUEN Chave_Completa_Guia, "

   cSql += " BD7_CODOPE " + cConc + " BD7_CODLDP " + cConc + " BD7_CODPEG " + cConc + " BD7_NUMERO Chave_Completa_Guia_Sem_Seque, "

   //cSql += " CASE "
   //cSql += " WHEN BD7_TIPGUI <> '05' THEN 0 "
   //cSql += "ELSE "

   // if(cDBType == "SQL")
   //  cSql += " case when Datediff(day, CONVERT(DATE, BE4_DATPRO), CONVERT(DATE, BE4_DTALTA)) = 0 THEN ( ( (1/BE4_QTDEVE) * BD7_PERCEN ) / 100 )  else "
   //  cSql += " Datediff(day, CONVERT(DATE, BE4_DATPRO), CONVERT(DATE, BE4_DTALTA))/BE4_QTDEVE * BD7_PERCEN / 100 END "
   //else
   //  cSql += " ( ( (to_date(BE4_DTALTA, 'yyyy/mm/dd') - to_date(BE4_DATPRO, 'yyyy/mm/dd'))/BE4_QTDEVE ) * BD7_PERCEN ) / 100 "
   //endif

   //cSql += "       END "
   cSql += " 0      AS prazo_internacao, "

   cSql +=  MontaSqlData("BE4_DATPRO","Data_da_Internacao",.T.)
   cSql +=  MontaSqlData("BE4_DTALTA","Data_da_Alta",.T.)
   //cSql += " ((BE4_VLRPAG/BE4_QTDEVE)*BD7_PERCEN )/100   AS Custo_Total_Internacao, "
   cSql += " 0   AS Custo_Total_Internacao, "



   cSql += " ' ' AS Senha_Autorizacao, "
   cSQL += " 0 AS Total_Despesas_Outras_Guias, "
   cSQL += " 0 AS Total_Eventos_Outras_Guias, "
   cSQL += " 'Não' AS Internacao, "
   cSQL += " ' ' AS Classif_Desp_1, "
   cSQL += " ' ' AS Classif_Desp_2, "
   cSQL += " ' ' AS Classif_Desp_3 "

   cSql += " FROM "
   cSql += RETSQLName("BD7") + "  "

   cSql += " INNER JOIN "+RETSQLName("BD6") + " ON "
   cSql += " BD6_FILIAL = '" + xFILIAL("BD6") + "' "
   cSql += " AND BD6_CODOPE = BD7_CODOPE "
   cSql += " AND BD6_CODLDP = BD7_CODLDP "
   cSql += " AND BD6_CODPEG = BD7_CODPEG "
   cSql += " AND BD6_NUMERO = BD7_NUMERO "
   cSql += " AND BD6_SEQUEN = BD7_SEQUEN "
   cSql += " AND " + RETSQLName("BD6") + ".D_E_L_E_T_ <> '*' "

   cSql += "	   LEFT JOIN "+RetSqlName("BE4")+" ON "
   cSql += "	   BE4_FILIAL = '"+xFilial("BE4")+"' AND "
   cSql += "	   BE4_CODOPE = BD7_CODOPE AND "
   cSql += "	   BE4_CODLDP = BD7_CODLDP AND "
   cSql += "	   BE4_CODPEG = BD7_CODPEG AND "
   cSql += "	   BE4_NUMERO = BD7_NUMERO AND "
   cSql += "	   "+RetSqlName("BE4")+".D_E_L_E_T_ <> '*' "


   cSql += "INNER JOIN "+RETSQLName("BA1") + " ON "
   cSql += " BA1_FILIAL = '" + xFILIAL("BA1") + "' "
   cSql += " AND BA1_CODINT = BD7_CODOPE "
   cSql += " AND BA1_CODEMP = BD7_CODEMP "
   cSql += " AND BA1_MATRIC = BD7_MATRIC "
   cSql += " AND BA1_TIPREG = BD7_TIPREG "
   cSql += " AND " + RETSQLName("BA1") + ".D_E_L_E_T_ <> '*' "

   cSql += "INNER JOIN "+RETSQLName("BA3") + " ON "
   cSql += " BA3_FILIAL = '" + xFILIAL("BA3") + "' "
   cSql += " AND BA3_CODINT = BD7_CODOPE "
   cSql += " AND BA3_CODEMP = BD7_CODEMP "
   cSql += " AND BA3_MATRIC = BD7_MATRIC "
   cSql += " AND " + RETSQLName("BA3") + ".D_E_L_E_T_ <> '*' "

   cSql += "INNER JOIN "+RETSQLName("BAU") + " ON "
   cSql += " BAU_FILIAL = '" + xFILIAL("BAU") + "' "
   cSql += " AND BAU_CODIGO = BD7_CODRDA "
   cSql += " AND " + RETSQLName("BAU") + ".D_E_L_E_T_ <> '*' "

   cSql += "INNER JOIN "+RETSQLName("BB8") + " ON "
   cSql += " BB8_FILIAL = '" + xFILIAL("BB8") + "' "
   cSql += " AND BB8_CODIGO = BAU_CODIGO "
   cSql += " AND BB8_CODLOC = BD7_CODLOC "
   cSql += " AND BB8_LOCAL = BD7_LOCAL "
   cSql += " AND " + RETSQLName("BB8") + ".D_E_L_E_T_ <> '*' "

   cSql += "INNER JOIN "+RETSQLName("BR8") + " ON  "
   cSql += " BR8_FILIAL = '" + xFILIAL("BR8") + "' "
   cSql += " AND BR8_CODPAD = BD6_CODPAD "
   cSql += " AND BR8_CODPSA = BD6_CODPRO "
   cSql += " AND " + RETSQLName("BR8") + ".D_E_L_E_T_ <> '*' "


   cSql += "LEFT JOIN "+RETSQLName("SE2") + " ON "
   cSql += " E2_FILIAL = '" + xFILIAL("SE2") + "' "
   cSql += " AND E2_PLLOTE  = BD7_NUMLOT "
   cSql += " AND E2_PLOPELT = BD7_OPELOT "
   cSql += " AND E2_FORNECE = BAU_CODSA2 "
   cSql += " AND E2_LOJA    = BAU_LOJSA2 "
   cSql += " AND E2_PREFIXO    = BD6_PREFIX "
   cSql += " AND E2_NUMTIT    = BD6_NUMTIT "
   cSql += " AND E2_PARCELA    = BD6_PARCEL "
   cSql += " AND E2_TIPO    = BD6_TIPTIT "
   cSql += " AND " + RETSQLName("SE2") + ".D_E_L_E_T_ <> '*' "

   cSql += "LEFT JOIN "+RETSQLName("B47") + " ON "
   cSql += " B47_FILIAL = '" + xFILIAL("B47") + "' "
   cSql += " AND B47_OPEMOV = BD7_CODOPE "
   cSql += " AND B47_CODLDP = BD7_CODLDP "
   cSql += " AND B47_CODPEG = BD7_CODPEG "
   cSql += " AND B47_NUMERO = BD7_NUMERO "
   cSql += " AND B47_SEQUEN = BD7_SEQUEN "
   cSql += " AND B47_CODUNM = BD7_CODUNM "
   cSql += " AND " + RETSQLName("B47") + ".D_E_L_E_T_ <> '*' "

   cSql += " WHERE "
   cSql += " BD7_FILIAL = '" + xFILIAL("BD7") + "' "
   cSql += " AND BD7_FASE = '4' "
   cSql += " AND " + RETSQLName("BD7") + ".D_E_L_E_T_ <> '*' "

   //BM1_ANO e BM1_MES
   if(cDBType == "SQL")
      cSql += " AND ( BD7_ANOPAG >= datepart(year,getdate())-1    )  "
   Else
      cSql += " AND ( BD7_ANOPAG >= to_char(SYSDATE - 365,'YYYY') )  "
   Endif

   cSqlFinal := " CREATE VIEW Fato_Despesas_V3 AS "+cSql
   nStatus := TCSqlExec(cSqlFinal)
   PLSLOGFil(cSqlFinal,"Fato_Despesas.sql")

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Despesas" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Despesas" + CRLF
   endif

return

/*/{Protheus.doc} Fast_F_Ben
Executa query que cria view Fato_Movimentacao_Beneficiario
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_F_Ben()

   local cSql := ""
   local nStatus := 0


   cSql +=  " SELECT "

   IF cDBType == "SQL"
      cSql += " BFM_ANO " + cConc + " BFM_MES " + cConc + " substring(convert(char, EOMONTH ( Convert(datetime,BFM_ANO+BFM_MES+'01') )),9,2) PERIODO, "
   Else
      cSql += "to_char(LAST_DAY(TO_DATE(TRIM(BFM_ANO||BFM_MES||'15'),'YYYYMMDD')),'YYYYMMDD') PERIODO, "
   endif

   cSql += " CASE "
   cSql += " WHEN "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTRING(BA1_DATBLO, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTR(BA1_DATBLO, 1, 6) "
   endif
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_DATBLO = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BA1_DATBLO "
   cSql += " END "
   cSql += " END "
   cSql += " AS Data_Bloqueio_Ben, "

   cSql += " CASE "
   cSql += " WHEN "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTRING(BA1_DATINC, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTR(BA1_DATINC, 1, 6) "
   endif

   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_DATINC = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BA1_DATINC "
   cSql += " END "
   cSql += " END "
   cSql += " AS Data_Inclusao_Ben, BA1_CODINT Cod_Operadora, BA1_CODINT " + cConc + " BA1_CODEMP Cod_Operadora_Grupo_Emp, "
   cSql += " BA1_CODINT " + cConc + " BA1_CODEMP " + cConc

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_CONEMP = '"+Space(Len(BA1->BA1_CONEMP))+"' "
   cSql += " THEN "
   cSql += " '-1' "
   cSql += " ELSE "
   cSql += " BA1_CONEMP "
   cSql += " END "
   cSql += " Cod_Operadora_Emp_Num_Con, BA1_CODINT " + cConc + " BA1_CODEMP " + cConc

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_CONEMP = '"+Space(Len(BA1->BA1_CONEMP))+"' "
   cSql += " THEN "
   cSql += " '-1' "
   cSql += " ELSE "
   cSql += " BA1_CONEMP "
   cSql += " END "

   cSql +=  cConc

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_SUBCON = '"+Space(Len(BA1->BA1_SUBCON))+"' "
   cSql += " THEN "
   cSql += " '-1' "
   cSql += " ELSE "
   cSql += " BA1_SUBCON "
   cSql += " END "
   cSql += " Cod_Operadora_Emp_Num_Subcon, "
   cSql += " BA1_CODINT " + cConc + " BA1_CODEMP " + cConc + " BA1_MATRIC " + cConc + " BA1_TIPREG " + cConc + " BA1_DIGITO Matricula_Completa_Ben, "
   cSql += " BA1_TIPUSU Tipo_de_Ben, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA3_CODPLA = '"+Space(Len(BA3->BA3_CODPLA))+"' "
   cSql += " THEN "
   cSql += " BA1_CODINT " + cConc + " BA1_CODPLA "
   cSql += " ELSE "
   cSql += " BA3_CODINT " + cConc + " BA3_CODPLA "
   cSql += " END "

   cSql += " AS Cod_Operadora_Produto, BA1_GRAUPA Grau_Parentesco, BA1_CEPUSR CEP, "
   cSql += " BA1_MOTBLO Motivo_Bloqueio_Ben, BA1_MOTBLO Motivo_Bloqueio_Ben2, 1 AS FATO, "
   cSql += " BA1_CODINT " + cConc + " BA1_CODEMP " + cConc + " BA1_MATRIC AS Matricula_da_Familia, BA3_ABRANG Abrangencia, "
   cSql += " BA3_SEGPLA Segmentacao, BA3_CODCLI " + cConc + " BA3_LOJA Cliente, rtrim(ltrim(BA3_TIPCON)) Tipo_de_Contrato, BA3_CODACO Acomodacao, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_CODMUN <> '"+Space(Len(BA1->BA1_CODMUN))+"' "
   cSql += " THEN "
   cSql += " BA1_CODMUN "
   cSql += " ELSE "
   cSql += " BA3_CODMUN "
   cSql += " END "
   cSql += " AS Municipio, '' Data_do_Contrato, BQC_CODBLO Motivo_Bloqueio_Subcon, "

   cSql += " CASE "
   cSql += " WHEN "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTRING(BQC_DATBLO, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTR(BQC_DATBLO, 1, 6) "
   endif
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BQC_DATBLO = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BQC_DATBLO "
   cSql += " END "
   cSql += " END "
   cSql += " AS Data_Bloqueio_Subcon, "

   cSql += " CASE "
   cSql += " WHEN "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTRING(BQC_DATCON, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTR(BQC_DATCON, 1, 6) "
   endif
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BQC_DATCON = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BQC_DATCON "
   cSql += " END "
   cSql += " END "
   cSql += " AS Data_Subcon, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_CODVEN = '"+Space(Len(BA1->BA1_CODVEN))+"' "
   cSql += " THEN "
   cSql += " RTRIM(LTRIM(BA3_CODVEN)) "
   cSql += " ELSE "
   cSql += " LTRIM(RTRIM(BA1_CODVEN)) "
   cSql += " END "
   cSql += " AS VENDEDOR, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_EQUIPE = '"+Space(Len(BA1->BA1_EQUIPE))+"' "
   cSql += " THEN "
   cSql += " BA3_EQUIPE "
   cSql += " ELSE "
   cSql += " BA1_EQUIPE "
   cSql += " END "
   cSql += " AS Equipe, BA3_MODPAG Modalidade_Cobranca_Produto , "

   cSql += " CASE "
   cSql += " WHEN "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTRING(BA3_DATDES, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTR(BA3_DATDES, 1, 6) "
   endif
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA3_DATDES = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BA3_DATDES "
   cSql += " END "
   cSql += " END "
   cSql += " AS Data_Desligamento_Funcionario , "

   cSql += " CASE "
   cSql += " WHEN "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTRING(BA1_DATCAR, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTR(BA1_DATCAR, 1, 6) "
   endif
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_DATCAR = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BA1_DATCAR "
   cSql += " END "
   cSql += " END "
   cSql += " AS Data_Carencia_Ben, "
   cSql += " BA1_TIPINC Tipo_Inclusao_Ben, "
   cSql += " BA3_GRPCOB Grupo_de_Cobranca, "
   cSql += " BA3_CODMUN Municipio_do_Cliente "

   cSql += " FROM "
   cSql += RETSQLName("BA3") + " , "
   cSql += " ( "
   cSql += " SELECT "
   cSql += " BFM_CODINT, "
   cSql += " BFM_ANO, "
   cSql += " BFM_MES "
   cSql += " FROM "
   cSql += RETSQLName("BFM") + " "
   cSql += " WHERE "
   cSql += " BFM_FILIAL = '" + xFILIAL("BFM") + "' "
   cSql += " AND D_E_L_E_T_ <> '*' "
   cSql += " AND "
   cSql += " ( "

   if(cDBType == "SQL")
      cSql += " ( BFM_ANO = datepart(year,getdate())-1 ) OR ( BFM_ANO = datepart(year,getdate()) AND BFM_MES <= datepart(MONTH,getdate()) ) "
   Else
      cSql += " ( (BFM_ANO = to_char(SYSDATE - 365,'YYYY') ) OR ( BFM_ANO = to_char(SYSDATE,'YYYY')) AND BFM_MES <= to_char(sysdate,'MM') ) "
   Endif

   cSql += " ) "
   cSql += " ) "
   cSql += " COMP, "
   cSql += RETSQLName("BA1") + " "
   cSql += " LEFT JOIN "
   cSql += RETSQLName("BQC") + " "
   cSql += " ON BQC_FILIAL = '" + xFILIAL("BQC") + "' "
   cSql += " AND BQC_CODIGO = BA1_CODINT " + cConc + " BA1_CODEMP "
   cSql += " AND BQC_NUMCON = BA1_CONEMP "
   cSql += " AND BQC_VERCON = BA1_VERCON "
   cSql += " AND BQC_SUBCON = BA1_SUBCON "
   cSql += " AND BQC_VERSUB = BA1_VERSUB "
   cSql += " AND " + RETSQLName("BQC") + ".D_E_L_E_T_ <> '*' "

   cSql += " WHERE "
   cSql += " BA1_FILIAL = '" + xFILIAL("BA1") + "' "
   cSql += " AND " + RETSQLName("BA1") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND BA1_CODINT = BA3_CODINT "
   cSql += " AND BA1_CODEMP = BA3_CODEMP "
   cSql += " AND BA1_MATRIC = BA3_MATRIC "
   cSql += " AND BA3_FILIAL = '" + xFILIAL("BA3") + "' "
   cSql += " AND " + RETSQLName("BA3") + ".D_E_L_E_T_ <> '*' "
   if(cDBType == "SQL")
      cSql += " AND BFM_ANO " + cConc + " BFM_MES >= SUBSTRING(BA1_DATINC, 1, 6) "
   else
      cSql += " AND BFM_ANO " + cConc + " BFM_MES >= SUBSTR(BA1_DATINC, 1, 6) "
   endif
   cSql += " AND "
   cSql += " ( "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES <= SUBSTRING(BA1_DATBLO, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES <= SUBSTR(BA1_DATBLO, 1, 6) "
   endif
   cSql += " OR BA1_DATBLO = '"+SPACE(08)+"' "
   cSql += " ) "

   cSqlFinal := " CREATE VIEW Fato_Movim_Beneficiario_V3 AS "+cSql
   nStatus := TCSqlExec(cSqlFinal)
   PLSLOGFil(cSqlFinal,"Fato_Movim_Beneficiario.sql")

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Movim_Beneficiario" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Movim_Beneficiario" + CRLF
   endif

return


/*/{Protheus.doc} Fast_F_Mov
Executa query que cria view Fato_Movimentacao_RDA
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_F_Mov()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Fato_Movimentacao_RDA_V3 AS "

   cSql +=  " SELECT "
   IF cDBType == "SQL"
      cSql += " BFM_ANO " + cConc + " BFM_MES " + cConc + " substring(convert(char, EOMONTH ( Convert(datetime,BFM_ANO+BFM_MES+'01') )),9,2) PERIODO, "
   else
      cSql += "to_char(LAST_DAY(TO_DATE(TRIM(BFM_ANO||BFM_MES||'15'),'YYYYMMDD')),'YYYYMMDD') PERIODO, "
   endif
   cSql += " CASE "
   cSql += " WHEN "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTRING(BAU_DATBLO, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTR(BAU_DATBLO, 1, 6) "
   endif
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BAU_DATBLO = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BAU_DATBLO "
   cSql += " END "
   cSql += " END "
   cSql += " AS Data_Bloqueio_Rede_de_Aten, "

   cSql += " CASE "
   cSql += " WHEN "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTRING(BAU_DTINCL, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES < SUBSTR(BAU_DTINCL, 1, 6) "
   endif
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BAU_DTINCL = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BAU_DTINCL "
   cSql += " END "
   cSql += " END "
   cSql += " AS Data_Inclusao_Rede_de_Aten, BB8_CODINT Codigo_Operadora, BAU_CODBLO Motivo_Bloqueio_Rede_de_Aten, BAU_CODBLO Motivo_Bloqueio_Rede_de_Aten2, 1 AS FATO, BB8_CODMUN Municipio, BB8_CEP CEP, BAU_CODIGO Codigo_Rede_de_Aten, BAU_TIPPRE Classe_Rede_Aten, BAX_CODESP Codigo_Especialidade, BAU_CODBB0 Codigo_Profissional_Saude, BB8_CODLOC Codigo_Local_Aten, BB8_LOCAL Local_Aten, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BAU_NASFUN = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " ELSE "
   cSql += " BAU_NASFUN "
   cSql += " END "
   cSql += " AS Data_Nascimento_Fundacao, BAU_CBO COB, BAU_SIGLCR Conselho, BAU_CODBLO Motivo_Bloqueio3 "

   cSql += " FROM "
   cSql += RETSQLName("BAU") + " , " + RETSQLName("BAW") + " , " + RETSQLName("BB8") + " , " + RETSQLName("BAX") + " , "
   cSql += " ( "
   cSql += " SELECT "
   cSql += " BFM_CODINT, "
   cSql += " BFM_ANO, "
   cSql += " BFM_MES "
   cSql += " FROM "
   cSql += RETSQLName("BFM") + " "
   cSql += " WHERE "
   cSql += " BFM_FILIAL = '" + xFILIAL("BFM") + "' "
   cSql += " AND D_E_L_E_T_ <> '*' "
   cSql += " AND "
   cSql += " ( "

   if(cDBType == "SQL")
      cSql += " BFM_ANO = datepart(year,getdate()) "
   else
      cSql += " BFM_ANO = to_char(SYSDATE - 365,'YYYY') "
   endif

   cSql += " ) "
   cSql += " ) "
   cSql += " COMP "

   cSql += " WHERE "
   cSql += " BAU_FILIAL = '" + xFILIAL("BAU") + "' "
   cSql += " AND " + RETSQLName("BAU") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND BAW_FILIAL = '" + xFILIAL("BAW") + "' "
   cSql += " AND BAW_CODIGO = BAU_CODIGO "
   cSql += " AND " + RETSQLName("BAW") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND BB8_FILIAL = '" + xFILIAL("BB8") + "' "
   cSql += " AND BB8_CODIGO = BAU_CODIGO "
   cSql += " AND BB8_CODINT = BAW_CODINT "
   cSql += " AND " + RETSQLName("BB8") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND BAX_FILIAL = '" + xFILIAL("BAX") + "' "
   cSql += " AND BAX_CODIGO = BAU_CODIGO "
   cSql += " AND BAX_CODINT = BAW_CODINT "
   cSql += " AND BAX_CODLOC = BB8_CODLOC "
   cSql += " AND " + RETSQLName("BAX") + ".D_E_L_E_T_ <> '*' "
   if(cDBType == "SQL")
      cSql += " AND BFM_ANO " + cConc + " BFM_MES >= SUBSTRING(BAU_DTINCL, 1, 6) "
   else
      cSql += " AND BFM_ANO " + cConc + " BFM_MES >= SUBSTR(BAU_DTINCL, 1, 6) "
   endif
   cSql += " AND "
   cSql += " ( "
   if(cDBType == "SQL")
      cSql += " BFM_ANO " + cConc + " BFM_MES <= SUBSTRING(BAU_DATBLO, 1, 6) "
   else
      cSql += " BFM_ANO " + cConc + " BFM_MES <= SUBSTR(BAU_DATBLO, 1, 6) "
   endif
   cSql += " OR BAU_DATBLO = '"+SPACE(08)+"' "
   cSql += " ) "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Movimentacao_RDA" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Movimentacao_RDA" + CRLF
   endif

return

/*/{Protheus.doc} Fast_F_Rec
Executa query que cria view Fato_Receitas
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_F_Rec()

   local cSql := ""
   local nStatus := 0

   cSql +=  " SELECT "
   cSql +=  " BM1_CODINT" + cConc + "BM1_CODEMP" + cConc + "BM1_MATRIC" + cConc + "BM1_TIPREG" + cConc + "BA1_DIGITO Matricula_Completa_Ben, "
   cSql +=  " BM1_CODINT Codigo_Operadora, "
   cSql +=  " BM1_CODINT " + cConc + " BM1_CODEMP Cod_Operadora_Emp, "
   cSql +=  " BM1_MATRIC Matricula_da_Familia, "
   cSql +=  " BM1_CODEVE Codivo_Evento_Receita, "
   cSql +=  " CASE "
   cSql += " WHEN "
   cSql += " BA3_CODPLA = '"+Space(Len(BA3->BA3_CODPLA))+"' "
   cSql += " THEN "
   cSql += " BA1_CODINT " + cConc + " BA1_CODPLA "
   cSql += " ELSE "
   cSql += " BA3_CODINT " + cConc + " BA3_CODPLA "
   cSql += " END "
   cSql +=  " AS Codigo_Operadora_Produto, BM1_CODINT " + cConc + " BM1_CODEMP " + cConc + " BM1_CONEMP Cod_Operadora_Emp_Num_Con, "
   cSql +=  " BM1_CODINT " + cConc + " BM1_CODEMP " + cConc + " BM1_CONEMP " + cConc + " BM1_SUBCON Cod_Oper_Grupo_Emp_Num_Subcon, "

   IF cDBType == "SQL"
      cSql +=  " BM1_ANO " + cConc + " BM1_MES " + cConc + " substring(convert(char, EOMONTH ( Convert(datetime,BM1_ANO+BM1_MES+'01') )),9,2) PERIODO, "
   Else
      cSql += "to_char(LAST_DAY(TO_DATE(TRIM(BM1_ANO||BM1_MES||'15'),'YYYYMMDD')),'YYYYMMDD') PERIODO, "
   endif

   cSql +=  " BM1_TIPO Tipo_Receita, BM1_VALOR Valor_Receita, BM1_CODTIP Codigo_Classe_Receita, BM1_PLNUCO Numero_Cobranca, "

   cSql +=  " CASE "
   cSql += " WHEN "
   cSql += " BA1_SEXO = '1' "
   cSql += " THEN "
   cSql += " 'Masculino' "
   cSql += " ELSE "
   cSql += " 'Feminino' "
   cSql += " END "
   cSql += " AS Sexo, "

   cSql += " BA1_GRAUPA Grau_Parentesco, "
   cSql += " BA1_TIPUSU Tipo_de_Beneficiario, "
   cSql += " BM1_CODFAI Codigo_Faixa_Etaria, "
   cSql += " BM1_PREFIX " + cConc + " BM1_NUMTIT " + cConc + " BM1_PARCEL " + cConc + " BM1_TIPTIT Titulo_a_Receber, "
   cSql += " BM1_IDAINI Idade_Inicial, "
   cSql += " BM1_IDAFIN Idade_Final, "
   cSql += " E1_NATUREZ Natureza, E1_CLIENTE " + cConc + " E1_LOJA Cliente, "
   cSql += " CASE "
   cSql += " WHEN "
   cSql += " E1_BAIXA = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " 'S' "
   cSql += "ELSE "
   cSql += " 'N' "
   cSql += " END "
   cSql += " AS EmAberto, E1_VALOR Valor_Receita_Titulo, E1_SALDO Saldo_Em_Aberto, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BA1_CODMUN <> '"+Space(Len(BA1->BA1_CODMUN))+"' "
   cSql += " THEN "
   cSql += " BA1_CODMUN "
   cSql += " ELSE "
   cSql += " BA3_CODMUN "
   cSql += " END "
   cSql += " AS Municipio, BA3_ABRANG Abrangencia, BA3_SEGPLA Segmentacao, BA3_CODACO Acomodacao, "
   cSql += " rtrim(ltrim(BA3_TIPCON)) Tipo_de_Contrato, BXQ_CODVEN Vendedor, BXQ_CODEQU Equipe, "
   cSql += " BXQ_VLRCOM ComissaoPaga, BA3_MODPAG Modalidade_Cobranca , "
   cSql += " BA3_GRPCOB Grupo_de_Cobranca, "
   cSql += " BA3_CODMUN Municipio_do_Cliente "
   cSql += " FROM "
   cSql += RETSQLName("SE1") + " , " + RETSQLName("BA3") + " , " + RETSQLName("BA1") + " , " + RETSQLName("BM1") + " "
   cSql += " LEFT JOIN "
   cSql += RETSQLName("BXQ") + " "
   cSql += " ON BXQ_FILIAL = '" + xFILIAL("BXQ") + "' "
   cSql += " AND BXQ_CODINT = BM1_CODINT "
   cSql += " AND BXQ_CODEMP = BM1_CODEMP "
   cSql += " AND BXQ_MATRIC = BM1_MATRIC "
   cSql += " AND BXQ_TIPREG = BM1_TIPREG "
   cSql += " AND BXQ_ANO = BM1_ANO "
   cSql += " AND BXQ_MES = BM1_MES "
   cSql += " AND " + RETSQLName("BXQ") + ".D_E_L_E_T_ <> '*' "

   cSql += " WHERE "
   cSql += " BM1_FILIAL = '" + xFILIAL("BM1") + "' "
   cSql += " AND BM1_PREFIX = E1_PREFIXO "
   cSql += " AND BM1_NUMTIT = E1_NUM "
   cSql += " AND BM1_PARCEL = E1_PARCELA "
   cSql += " AND BM1_TIPTIT = E1_TIPO "
   cSql += " AND BM1_CODINT = BA1_CODINT "
   cSql += " AND BM1_CODEMP = BA1_CODEMP "
   cSql += " AND BM1_MATRIC = BA1_MATRIC "
   cSql += " AND BM1_TIPREG = BA1_TIPREG "

   //BM1_ANO e BM1_MES
   if(cDBType == "SQL")
      cSql += " AND ( BM1_ANO >= datepart(year,getdate())-1    )  "
   Else
      cSql += " AND ( BM1_ANO >= to_char(SYSDATE - 365,'YYYY') )  "
   Endif

   cSql += " AND " + RETSQLName("BM1") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND " + RETSQLName("SE1") + ".E1_FILIAL =  '" + xFILIAL("SE1") + "'"
   cSql += " AND " + RETSQLName("SE1") + ".D_E_L_E_T_ <> '*'"
   cSql += " AND BA1_FILIAL = '" + xFILIAL("BA1") + "' "
   cSql += " AND BA1_CODINT = BA3_CODINT "
   cSql += " AND BA1_CODEMP = BA3_CODEMP "
   cSql += " AND BA1_MATRIC = BA3_MATRIC "
   cSql += " AND " + RETSQLName("BA1") + ".D_E_L_E_T_ <> '*' "
   cSql += " AND BA3_FILIAL = '" + xFILIAL("BA3") + "' "
   cSql += " AND " + RETSQLName("BA3") + ".D_E_L_E_T_ <> '*' "

   cSqlFinal := " CREATE VIEW Fato_Receitas_V3  AS "+cSql
   nStatus := TCSqlExec(cSqlFinal)
   PLSLOGFil(cSqlFinal,"Fato_Receitas.sql")

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Receitas" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Receitas" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_SA2
Executa query que cria view Fornecedores_SA2
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_SA2()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Fornecedores_SA2_V3 AS "
   cSql +=  " SELECT A2_COD Codigo_Fornecedor, A2_LOJA Loja_Fornecedor, A2_NOME Nome_Fornecedor, A2_NREDUZ Nome_Reduzido_Fornecedor, "
   cSql +=  " A2_CGC CNPJ_Fornecedor, A2_TIPO Tipo_Fornecedor "
   cSql +=  " FROM " + RETSQLName("SA2") + " WHERE A2_FILIAL = '" + xFILIAL("SA2") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fornecedores_SA2" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fornecedores_SA2" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BRP
Executa query que cria view Grau_Parentesco_BRP
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BRP()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Grau_Parentesco_BRP_V3 AS "
   cSql +=  " SELECT BRP_CODIGO Codigo_Tipo_Grau_Parentesco, BRP_DESCRI Desc_Grau_Parentesco FROM " + RETSQLName("BRP") + " WHERE BRP_FILIAL = '" + xFILIAL("BRP") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Grau_Parentesco_BRP" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Grau_Parentesco_BRP" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BG9
Executa query que cria view Grupo_Empresa_BG9
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BG9()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Grupo_Empresa_BG9_V3 AS "
   cSql +=  " SELECT BG9_CODINT" + cConc + "BG9_CODIGO Cod_Operadora_e_Emp, BG9_CODIGO" + cConc + "' - '" + cConc + "BG9_DESCRI Cod_e_Desc_Emp, BG9_DESCRI Desc_Emp, "
   cSql +=  " BG9_CODINT Cod_Operadora, BG9_CODIGO Cod_Emp, CASE WHEN BG9_TIPO = '1' THEN 'Pessoa Física' ELSE 'Pessoa Jurídica' END Tipo_Emp  FROM "
   cSql +=  RETSQLName("BG9") + " WHERE BG9_FILIAL = '" + xFILIAL("BG9") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Grupo_Empresa_BG9" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Grupo_Empresa_BG9" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BD1
Executa query que cria view Local_Atendimento_BD1
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BD1()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Local_Atendimento_BD1_V3 AS "
   cSql +=  " SELECT BD1_CODLOC Cod_Local_de_Aten, BD1_DESLOC Desc_Local_de_Aten FROM " + RETSQLName("BD1") + " WHERE BD1_FILIAL = '" + xFILIAL("BD1") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Local_Atendimento_BD1" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Local_Atendimento_BD1" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BI3
Executa query que cria view Produtos_BI3 e Modalid_Cobranca_Produto_BI3
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BI3()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Produtos_BI3_V3 AS "
   cSql +=  " SELECT BI3_CODINT" + cConc + "BI3_CODIGO Cod_Operadora_e_Produto, BI3_CODINT Cod_Operadora,  BI3_CODIGO Cod_Produto,  BI3_DESCRI Nome_do_Produto ,"
   cSql +=  " BI3_GRUPO Grupo_Produto ,"
   cSql +=  " BI3_SUSEP Registro_ANS "
   cSql +=  " FROM " + RETSQLName("BI3") + " WHERE BI3_FILIAL = '" + xFILIAL("BI3") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Produtos_BI3" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Produtos_BI3" + CRLF
   endif

   cSql :=  " CREATE VIEW Modalid_Cobr_Prod_BI3_V3 AS "
   cSql +=  " SELECT DISTINCT BI3_MODPAG Cod_Modalid_Cobranca_Produto, "
   cSql +=  " CASE WHEN BI3_MODPAG = '1' THEN 'Pré-Pagamento' WHEN BI3_MODPAG = '2' THEN 'Demais Modalidades' WHEN BI3_MODPAG = '3' "
   cSql +=  " THEN 'Pos-Estabelecido' WHEN BI3_MODPAG = '4' THEN 'Misto (Pré/pos)' WHEN BI3_MODPAG = '9' THEN 'Não Definida' "
   cSql +=  " ELSE 'Não Definida' END as Descri_Modalidade_Cobranca "

   cSql +=  " FROM " + RETSQLName("BI3") + " WHERE BI3_FILIAL = '" + xFILIAL("BI3") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Modalid_Cobr_Prod_BI3" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Modalid_Cobr_Prod_BI3" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BAP
Executa query que cria view Motivos_Bloqueio_RDA_BAP
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BAP()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Motivos_Bloqueio_RDA_BAP_V3 AS "

   cSql +=  " SELECT BAP_CODBLO Cod_Motivo_Bloq_RDA, BAP_DESCRI Desc_Mot_Bloq_RDA "
   cSql +=  " FROM " + RETSQLName("BAP") + " WHERE BAP_FILIAL = '" + xFILIAL("BAP") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Motivos_Bloqueio_RDA_BAP" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Motivos_Bloqueio_RDA_BAP" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BID
Executa query que cria view Municipio_BID e Municipios_BID
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BID()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Municipio_BID_V3 AS "
   cSql +=  " SELECT BID_CODMUN Codigo_Municipio, BID_DESCRI Nome_do_Municipio, BID_EST Estado_Municipio, CASE WHEN BID_EST = 'AC' THEN '12' WHEN BID_EST = 'AL' THEN '27' "
   cSql +=  " WHEN BID_EST = 'AP' THEN '16' WHEN BID_EST = 'AM' THEN '13' WHEN BID_EST = 'BA' THEN '29' WHEN BID_EST = 'CE' THEN '23' WHEN BID_EST = 'DF' THEN '53' "
   cSql +=  " WHEN BID_EST = 'ES' THEN '32' WHEN BID_EST = 'GO' THEN '52' WHEN BID_EST = 'MA' THEN '21' WHEN BID_EST = 'MT' THEN '51' WHEN BID_EST = 'MS' THEN '50' "
   cSql +=  " WHEN BID_EST = 'MG' THEN '31' WHEN BID_EST = 'PA' THEN '15' WHEN BID_EST = 'PB' THEN '25' WHEN BID_EST = 'PR' THEN '41' WHEN BID_EST = 'PE' THEN '26' "
   cSql +=  " WHEN BID_EST = 'PI' THEN '22' WHEN BID_EST = 'RJ' THEN '33' WHEN BID_EST = 'RN' THEN '24' WHEN BID_EST = 'RS' THEN '43' WHEN BID_EST = 'RO' THEN '11' "
   cSql +=  " WHEN BID_EST = 'RR' THEN '14' WHEN BID_EST = 'SC' THEN '42' WHEN BID_EST = 'SP' THEN '35' WHEN BID_EST = 'SE' THEN '28' WHEN BID_EST = 'TO' THEN '17' "
   cSql +=  " ELSE 'XX' END as Estado FROM " + RETSQLName("BID") + " WHERE BID_FILIAL = '" + xFILIAL("BID") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Municipio_BID" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Municipio_BID" + CRLF
   endif


   cSql :=  " CREATE VIEW Municipios_BID_V3 AS "
   cSql +=  " SELECT BID_CODMUN Codigo_Municipio, BID_DESCRI Nome_do_Municipio, BID_EST Estado_Municipio, CASE WHEN BID_EST = 'AC' THEN '12' WHEN BID_EST = 'AL' THEN '27' "
   cSql +=  " WHEN BID_EST = 'AP' THEN '16' WHEN BID_EST = 'AM' THEN '13' WHEN BID_EST = 'BA' THEN '29' WHEN BID_EST = 'CE' THEN '23' WHEN BID_EST = 'DF' THEN '53' "
   cSql +=  " WHEN BID_EST = 'ES' THEN '32' WHEN BID_EST = 'GO' THEN '52' WHEN BID_EST = 'MA' THEN '21' WHEN BID_EST = 'MT' THEN '51' WHEN BID_EST = 'MS' THEN '50' "
   cSql +=  " WHEN BID_EST = 'MG' THEN '31' WHEN BID_EST = 'PA' THEN '15' WHEN BID_EST = 'PB' THEN '25' WHEN BID_EST = 'PR' THEN '41' WHEN BID_EST = 'PE' THEN '26' "
   cSql +=  " WHEN BID_EST = 'PI' THEN '22' WHEN BID_EST = 'RJ' THEN '33' WHEN BID_EST = 'RN' THEN '24' WHEN BID_EST = 'RS' THEN '43' WHEN BID_EST = 'RO' THEN '11' "
   cSql +=  " WHEN BID_EST = 'RR' THEN '14' WHEN BID_EST = 'SC' THEN '42' WHEN BID_EST = 'SP' THEN '35' WHEN BID_EST = 'SE' THEN '28' WHEN BID_EST = 'TO' THEN '17' "
   cSql +=  " ELSE 'XX' END as Estado FROM " + RETSQLName("BID") + " WHERE BID_FILIAL = '" + xFILIAL("BID") + "' AND D_E_L_E_T_ <> '*' "


   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Municipios_BID" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Municipios_BID" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BA0
Executa query que cria view Operadora_BA0
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BA0()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Operadora_BA0_V3 AS "
   cSql +=  " SELECT BA0_CODIDE" + cConc + "BA0_CODINT CODOPE, BA0_NOMINT, BA0_CODMUN CODMUN FROM  " + RETSQLName("BA0") + " WHERE BA0_FILIAL = '" + xFILIAL("BA0") + "' AND D_E_L_E_T_ <> '*' AND "
   cSql +=  " EXISTS (SELECT BA1_FILIAL FROM " + RETSQLName("BA1") + " WHERE BA1_FILIAL = '" + xFILIAL("BA1") + "' AND BA1_OPEORI = BA0_CODIDE" + cConc + "BA0_CODINT AND BA1_MOTBLO = '"+Space(03)+"' AND D_E_L_E_T_ <> '*') "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Operadora_BA0" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Operadora_BA0" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BB0
Executa query que cria view Profissional_Executante_BB0 e Profissional_Solicitante_BB0
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BB0()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Profissional_Executante_BB0_V3 AS "

   cSql +=  " SELECT BB0_CODIGO Cod_Profissional_Execu, BB0_NOME Nome_Profissional_Execu, "
   cSql +=  " BB0_ESTADO Estado_Profissional_Execu, BB0_NUMCR Num_CR_Profissional_Execu, "
   cSql +=  " BB0_CGC CGCCPF_Profissional_Execu, BB0_BAIRRO Bairro_Profissional_Execu, "
   cSql +=  " BB0_CODSIG Cons_Profissional_Execu, BB0_CODMUN Munic_Profissional_Execu "
   cSql +=  " FROM " + RETSQLName("BB0") + " WHERE BB0_FILIAL = '" + xFILIAL("BB0") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Profissional_Executante_BB0" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Profissional_Executante_BB0" + CRLF
   endif

   cSql :=  " CREATE VIEW Profissional_Solic_BB0_V3 AS "

   cSql +=  " SELECT BB0_CODIGO Cod_Profissional_Solici, "
   cSql +=  " BB0_NOME Nome_Profissional_Solici, "
   cSql +=  " BB0_ESTADO Est_Profissional_Solici, "
   cSql +=  " BB0_NUMCR N_CR_Profissional_Solici, "
   cSql +=  " BB0_CGC CPF_Profissional_Solici, "
   cSql +=  " BB0_BAIRRO Bair_Profissional_Solici, "
   cSql +=  " BB0_CODSIG Cons_Profissional_Solici, "
   cSql +=  " BB0_CODMUN Mun_Profissional_Solici "
   cSql +=  " FROM " + RETSQLName("BB0") + " WHERE BB0_FILIAL = '" + xFILIAL("BB0") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Profissional_Solic_BB0" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Profissional_Solic_BB0" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BAU
Executa query que cria view Rede_Atendimento_BAU
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BAU()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Rede_Atendimento_BAU_V3 AS "
   cSql +=  " SELECT BAU_CODIGO Codigo_Rede_de_Aten, BAU_NOME Nome_Rede_de_Aten, "
   cSql +=  " CASE WHEN BAU_TIPPE = '1' THEN 'Pessoa Física' ELSE 'Pessoa Jurídica' END Tipo_Rede_de_Aten, BAU_CPFCGC CGCCPF_Rede_de_Aten, "
   cSql +=  " BAU_NREDUZ Nome_Reduzido_Rede_de_Aten, BAU_MUN Municipio_Rede_Atend_BAU FROM " + RETSQLName("BAU") + " WHERE BAU_FILIAL = '" + xFILIAL("BAU") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Rede_Atendimento_BAU" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Rede_Atendimento_BAU" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BI6
Executa query que cria view Segmentacao_BI6
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BI6()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Segmentacao_BI6_V3 AS "
   cSql +=  " SELECT BI6_CODSEG Codigo_Segmentacao_Produto, BI6_DESCRI Desc_Segmentacao_Produto FROM " + RETSQLName("BI6") + " WHERE BI6_FILIAL = '" + xFILIAL("BI6") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Segmentacao_BI6" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Segmentacao_BI6" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BQC
Executa query que cria view Subcontrato_BQC
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BQC()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Subcontrato_BQC_V3 AS "
   cSql +=  " SELECT BQC_CODINT" + cConc + "BQC_CODEMP" + cConc + "BQC_NUMCON" + cConc + "BQC_SUBCON Cod_Operadora_Emp_Num_Subcon, "
   cSql +=  " BQC_CODINT Cod_Operadora, BQC_CODEMP Codigo_Grupo_Empresa, BQC_NUMCON Numero_Con, "
   cSql +=  " BQC_SUBCON Numero_Subcon, BQC_SUBCON" + cConc + "' - '" + cConc + "BQC_DESCRI Desc_Subcon, "
   cSql +=  " CASE "
   cSql += " WHEN "
   cSql += " BQC_VALID = '"+SPACE(08)+"' "
   cSql += " THEN "
   cSql += " NULL "
   cSql += " WHEN "
   cSql += " ( "
   cSql += " BQC_VALID < '19000101' "
   cSql += " OR BQC_VALID >= '20501231' "
   cSql += " ) "
   cSql += " THEN "
   cSql += " '19500101' "
   cSql += " ELSE "
   cSql += " BQC_VALID "
   cSql += " END "
   cSql += " as Validade_Subcon, "
   cSql +=  " BQC_MESREA Mes_de_Reajuste_Subcon, "
   cSql +=  " BQC_CODMUN Municipio_do_Subcontrato "
   cSQL += "FROM " + RETSQLName("BQC") + " WHERE BQC_FILIAL = '" + xFILIAL("BQC") + "' AND D_E_L_E_T_ <> '*' "
   cSql +=  " UNION ALL SELECT BG9_CODINT" + cConc + "BG9_CODIGO" + cConc + "'-1-1',  BG9_CODINT, BG9_CODIGO, '-1', '-1-1','NÃO SE APLICA',NULL,'  ','   ' FROM "
   cSql +=  RETSQLName("BG9") + " WHERE BG9_FILIAL = '" + xFILIAL("BG9") + "' AND BG9_TIPO = '1'  AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Subcontrato_BQC" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Subcontrato_BQC" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BIH
Executa query que cria view Tipo_Beneficiario_BIH
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BIH()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Tipo_Beneficiario_BIH_V3 AS "
   cSql +=  " SELECT BIH_CODTIP Cod_Tipo_Ben, BIH_DESCRI Desc_Tipo_Ben FROM " + RETSQLName("BIH") + " WHERE BIH_FILIAL = '" + xFILIAL("BIH") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Tipo_Beneficiario_BIH" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Tipo_Beneficiario_BIH" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BII
Executa query que cria view Tipo_Contrato_BII
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BII()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Tipo_Contrato_BII_V3 AS "
   cSql +=  " SELECT RTRIM(LTRIM(BII_CODIGO)) Cod_Tipo_de_Con, BII_DESCRI Desc_Tipo_de_Con FROM " + RETSQLName("BII") + " WHERE BII_FILIAL = '" + xFILIAL("BII") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Tipo_Contrato_BII" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Tipo_Contrato_BII" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BWT
Executa query que cria view Tipo_Participacao_Servico_BWT
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BWT()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Tipo_Partic_Servico_BWT_V3 AS "
   cSql +=  " SELECT BWT_CODPAR Cod_Tipo_Participacao_Servi, BWT_DESCRI Desc_Tipo_Participacao_Servi FROM " + RETSQLName("BWT") + " WHERE BWT_FILIAL = '" + xFILIAL("BWT") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Tipo_Partic_Servico_BWT" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Tipo_Partic_Servico_BWT" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BCL
Executa query que cria view Tipos_de_Guia_BCL
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BCL()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Tipos_de_Guia_BCL_V3 AS "
   cSql +=  " SELECT BCL_TIPGUI Cod_Tipo_Guia, BCL_DESCRI Desc_Tipo_Guia FROM " + RETSQLName("BCL") + " WHERE BCL_FILIAL = '" + xFILIAL("BCL") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Tipos_de_Guia_BCL" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Tipos_de_Guia_BCL" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BR4
Executa query que cria view Tipos_Eventos_Saude_BR4
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BR4()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Tipos_Eventos_Saude_BR4_V3 AS "
   cSql +=  " SELECT BR4_CODPAD Cod_Tipo_Evento_Saude, BR4_DESCRI Desc_Tipo_Evento_Saude FROM " + RETSQLName("BR4") + " WHERE BR4_FILIAL = '" + xFILIAL("BR4") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Tipos_Eventos_Saude_BR4" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Tipos_Eventos_Saude_BR4" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_BD3
Executa query que cria view Unidade_Medida_BD3
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_BD3()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Unidade_Medida_BD3_V3 AS "
   cSql +=  " SELECT BD3_CODIGO Cod_Unidade_Medida, BD3_DESCRI Desc_Unidade_Medida FROM " + RETSQLName("BD3") + " WHERE BD3_FILIAL = '" + xFILIAL("BD3") + "' AND D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Unidade_Medida_BD3" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Unidade_Medida_BD3" + CRLF
   endif

return


/*/{Protheus.doc} Fast_D_SA3
Executa query que cria view Vendedores_SA3
@type function
@author PLSTEAM
@since 04.04.16
@version 1.0
/*/
function Fast_D_SA3()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Vendedores_SA3_V3 "
   cSql +=  " AS SELECT LTRIM(RTRIM(A3_COD)) Cod_Vendedor, A3_NOME Nome_Vendedor FROM " + RETSQLName("SA3") + " WHERE  A3_FILIAL = '" + xFILIAL("SA3") + "' AND " + RETSQLName("SA3") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Vendedores_SA3" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Vendedores_SA3" + CRLF
   endif

return

/*/{Protheus.doc} Fast_F_V1
Executa query que cria view de dados cadastrais do subcontrato
@type function
@author PLSTEAM
@since 01.06.18
@version 1.0
/*/
function Fast_F_V1()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Fato_Virt_Dados_Ca_Pro_S_V3 "
   cSql +=  " AS SELECT "
   cSql +=  "BYC_CODOPE, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODEMP CODEMP, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODEMP " + cConc + " BYC_CONEMP NUMCON, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODEMP " + cConc + " BYC_CONEMP " + cConc + " BYC_SUBCON SUBCON, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODPRO CODPRO, "
   cSql +=  "BYC_CODFOR, "
   cSql +=  "'Origem' Origem, "
   cSql +=  "'Descrição' Descrição, "
   cSql +=  "1 Referencia, "
   cSql +=  "' ' Tipo_Ref, "
   cSql +=  "'20180101' PERIODO "

   cSql +=  "FROM "+RETSQLName("BYC") + " WHERE  BYC_FILIAL = '" + xFILIAL("BYC") + "' AND " + RETSQLName("BYC") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Virt_Dados_Ca_Pro_S" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Virt_Dados_Ca_Pro_S" + CRLF
   endif

return

/*/{Protheus.doc} Fast_F_V3
Executa query que cria view de dados cadastrais do subcontrato
@type function
@author PLSTEAM
@since 01.06.18
@version 1.0
/*/
function Fast_F_V3()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Fato_Virt_Simul_Fx_Ans_S_V3 "
   cSql +=  " AS SELECT "
   cSql +=  "BYC_CODOPE, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODEMP CODEMP, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODEMP " + cConc + " BYC_CONEMP NUMCON, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODEMP " + cConc + " BYC_CONEMP " + cConc + " BYC_SUBCON SUBCON, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODPRO CODPRO, "
   cSql +=  "BYC_CODFOR, "
   cSql +=  "'001' Seq_Faixa, "
   cSql +=  "'3' Sexo, "
   cSql +=  "BYC_IDAINI, "
   cSql +=  "BYC_IDAFIN, "
   cSql +=  "BYC_VLRREA Valor_Faixa "
   cSql +=  "FROM "+RETSQLName("BYC") + " WHERE  BYC_FILIAL = '" + xFILIAL("BYC") + "' AND " + RETSQLName("BYC") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Virt_Simul_Fx_Ans_S" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Virt_Simul_Fx_Ans_S" + CRLF
   endif

return

/*/{Protheus.doc} Fast_F_BYC
Executa query que cria view de historico de reajustes do subcontrato
@type function
@author PLSTEAM
@since 01.06.18
@version 1.0
/*/
function Fast_F_BYC()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Fato_Hist_Reaj_Subcontrato_V3 "
   cSql +=  " AS SELECT "
   cSql +=  "BYC_CODOPE, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODEMP CODEMP, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODEMP " + cConc + " BYC_CONEMP NUMCON, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODEMP " + cConc + " BYC_CONEMP " + cConc + " BYC_SUBCON SUBCON, "
   cSql +=  "BYC_CODOPE " + cConc + " BYC_CODPRO CODPRO, "
   cSql +=  "BYC_CODFOR, "
   cSql +=  MontaSqlData("BYC_DATREA","BYC_DATREA")
   cSql +=  "BYC_IDAINI, "
   cSql +=  "BYC_IDAFIN, "
   cSql +=  "BYC_VLRREA, "
   cSql +=  "BYC_VLRANT, "
   cSql +=  "BYC_INDREA, "
   cSql +=  "BYC_PERREA, "
   cSql +=  "BYC_CODFAI "

   cSql +=  "FROM "+RETSQLName("BYC") + " WHERE  BYC_FILIAL = '" + xFILIAL("BYC") + "' AND " + RETSQLName("BYC") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Hist_Reaj_Subcontrato" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Hist_Reaj_Subcontrato" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_BJ1
Executa query que cria view de cadastro de formas de cobrança
@type function
@author PLSTEAM
@since 01.06.18
@version 1.0
/*/
function Fast_D_BJ1()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Formas_de_Cobranca_BJ1_V3 "
   cSql +=  " AS SELECT BJ1_CODIGO, BJ1_DESCRI "
   cSql +=  "FROM "+RETSQLName("BJ1") + " WHERE  BJ1_FILIAL = '" + xFILIAL("BJ1") + "' AND " + RETSQLName("BJ1") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Formas_de_Cobranca_BJ1" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Formas_de_Cobranca_BJ1" + CRLF
   endif

return

/*/{Protheus.doc} Fast_F_BB3
Executa query que cria view com as faixas etarias do produto
@type function
@author PLSTEAM
@since 01.06.18
@version 1.0
/*/
function Fast_F_BB3()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Fato_Faixas_Eta_Prod_BB3_V3 "
   cSql +=  " AS SELECT "
   cSql +=  "BB3_CODFAI, "

   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BB3_SEXO = '1' "
   cSql += " THEN "
   cSql += " 'Masculino' "

   cSql += " WHEN "
   cSql += " BB3_SEXO = '2' "
   cSql += " THEN "
   cSql += " 'Feminino' "

   cSql += " ELSE "
   cSql += " 'Ambos' "
   cSql += " END "
   cSql += " as BB3_SEXO, "

   cSql +=  "BB3_IDAINI, "
   cSql +=  "BB3_IDAFIN, "
   cSql +=  "BB3_VALFAI, "

   if(cDBType == "SQL")
      cSql +=  "SUBSTRING(BB3_CODIGO,1,4) CODOPE, "
   else
      cSql +=  "SUBSTR(BB3_CODIGO,1,4) CODOPE, "
   endif

   cSql +=  "BB3_CODIGO CODPRO, "
   cSql +=  "BB3_CODFOR, "
   cSql +=  "BB3_GRAUPA, "
   cSql +=  "BB3_TIPUSR "
   cSql +=  "FROM "+RETSQLName("BB3") + " WHERE  BB3_FILIAL = '" + xFILIAL("BB3") + "' AND " + RETSQLName("BB3") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Faixas_Eta_Prod_BB3" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Faixas_Eta_Prod_BB3" + CRLF
   endif

return

/*/{Protheus.doc} Fast_F_BTN
Executa query que cria view com as faixas etarias dos produtos no subcontrato
@type function
@author PLSTEAM
@since 01.06.18
@version 1.0
/*/
function Fast_F_BTN()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Fato_Faixas_Eta_Subc_BTN_V3 "
   cSql +=  " AS SELECT "
   cSql +=  " BTN_CODFAI,


   cSql += " CASE "
   cSql += " WHEN "
   cSql += " BTN_SEXO = '1' "
   cSql += " THEN "
   cSql += " 'Masculino' "

   cSql += " WHEN "
   cSql += " BTN_SEXO = '2' "
   cSql += " THEN "
   cSql += " 'Feminino' "

   cSql += " ELSE "
   cSql += " 'Ambos' "
   cSql += " END "
   cSql += " as BTN_SEXO, "


   cSql +=  " BTN_IDAINI,
   cSql +=  " BTN_IDAFIN,
   cSql +=  " BTN_VALFAI,

   if(cDBType == "SQL")
      cSql +=  "SUBSTRING(BTN_CODIGO,1,4) CODOPE, "
   else
      cSql +=  "SUBSTR(BTN_CODIGO,1,4) CODOPE, "
   endif

   cSql +=  " BTN_CODIGO CODEMP, "
   cSql +=  " BTN_CODIGO "+cConc+"BTN_NUMCON NUMCON, "
   cSql +=  " BTN_CODIGO "+cConc+" BTN_NUMCON "+cConc+" BTN_SUBCON SUBCON, "

   if(cDBType == "SQL")
      cSql +=  " SUBSTRING(BTN_CODIGO,1,4) "+cConc+" BTN_CODPRO CODPRO, "
   else
      cSql +=  " SUBSTR(BTN_CODIGO,1,4) "+cConc+" BTN_CODPRO CODPRO, "
   endif

   cSql +=  " BTN_CODFOR "
   cSql +=  "FROM "+RETSQLName("BTN") + " WHERE  BTN_FILIAL = '" + xFILIAL("BTN") + "' AND " + RETSQLName("BTN") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Fato_Faixas_Eta_Subc_BTN" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Fato_Faixas_Eta_Subc_BTN" + CRLF
   endif

return

Static Function MontaSqlData(cCampo,cDesc,lVirgula)
   LOCAL cSql := ""
   DEFAULT lVirgula := .T.

   cSql +=  " CASE "
   cSql +=  " WHEN "
   cSql +=  " "+cCampo+" = '"+SPACE(08)+"' "
   cSql +=  " THEN "
   cSql +=  " '19500101' "
   cSql +=  " WHEN "
   cSql +=  " ( "
   cSql +=  " "+cCampo+" < '19000101' "
   cSql +=  " OR "+cCampo+" >= '20501231' "
   cSql +=   " ) "
   cSql +=   " THEN "
   cSql +=  " '19500101' "
   cSql +=   " ELSE "
   cSql +=  " "+cCampo+" "
   cSql +=  " END "
   cSql +=  " as "+cDesc+" "

   If lVirgula
      cSql += ", "
   Endif

Return(cSQL)


/*/{Protheus.doc} Fast_D_ACH
Executa query que cria view de suspects
@type function
@author PLSTEAM
@since 01.06.18
@version 1.0
/*/
function Fast_D_ACH()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Suspects_ACH_V3 "
   cSql +=  " AS SELECT ACH_CODIGO "+cConc+" ACH_LOJA COD_SUSP, ACH_RAZAO, ACH_CIDADE, ACH_EST, ACH_TIPO, ACH_EMAIL, ACH_TEL, ACH_END, ACH_STATUS, "
   cSql +=  " ACH_CGC, ACH_VEND, ACH_CODPRO "+cConc+" ACH_LOJPRO COD_PROS, ACH_DTCONV "
   cSql +=  "FROM "+RETSQLName("ACH") + " WHERE  ACH_FILIAL = '" + xFILIAL("ACH") + "' AND " + RETSQLName("ACH") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Suspects_ACH" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Suspects_ACH" + CRLF
   endif

return

/*/{Protheus.doc} Fast_D_SUS
Executa query que cria view de prospects
@type function
@author PLSTEAM
@since 01.06.18
@version 1.0
/*/
function Fast_D_SUS()

   local cSql := ""
   local nStatus := 0

   cSql +=  " CREATE VIEW Prospects_SUS_V3 "
   cSql +=  " AS SELECT US_COD "+cConc+" US_LOJA COD_PROS, US_NOME, US_MUN, US_EST, US_TIPO, US_EMAIL, US_TEL, US_END, US_STATUS, US_CGC, "
   cSql +=  " US_CODCLI"+cConc+"US_LOJACLI COD_CLI, US_VEND, US_DTCONV  "
   cSql +=  "FROM "+RETSQLName("SUS") + " WHERE  US_FILIAL = '" + xFILIAL("SUS") + "' AND " + RETSQLName("SUS") + ".D_E_L_E_T_ <> '*' "

   nStatus := TCSqlExec(cSql)

   if (nStatus < 0)
      lLogOk := .F.
      cLog += " Ocorreu erro na seguinte view: Prospects_SUS" + CRLF
      cLog += TCSQLError() + CRLF
   else
      cLog += " View criada com sucesso             : Prospects_SUS" + CRLF
   endif

return

/*/{Protheus.doc} vldRegDt
Realiza a validação dos campos data que estão no array 'aFields'.

@type static function
@author Gabriel Hegler Klok
@since 29/04/2019
@version 1.0

@return lRet, boolean, Retorna 'true' caso todos os campos estejam no formato correto.
/*/
static function vldRegDt(lAutoma)
   local aFields := { 'BT5_DATCON', 'BA1_DATNAS,BA1_DATBLO,BA1_DATINC,BA1_DATCAR', 'BE2_DATPRO',;
      'BE4_DATPRO,BE4_DTALTA', 'BD7_DATPRO,BD7_DTPAGT', 'E1_BAIXA',;
      'E2_EMISSAO,E2_BAIXA,E2_VENCREA', 'BQC_DATCON,BQC_VALID',;
      'BAU_DATBLO,BAU_DTINCL,BAU_NASFUN', 'BYC_DATREA' }
   local nX
   local lRet := .t.
   default lAutoma := .F.

   for nX := 1 to len(aFields)
      msgrun("Validando campo(s) {" + aFields[nX] + "}", "Validando...", {|| validDate(aFields[nX], lAutoma)})
   next nX

   if len(cLogDtErr) > 0
      lRet := .f.

      If !lAutoma
         if msgyesno("Há erros na sua base de dados nos campos de data. Deseja salvar o log para análise?", "Gravar log de erros")
            cFile := cgetfile("Arquivo LOG|*.log", 'Selecione o diretorio para salvar o log...', 1, plsmudsis('\'), .t., GETF_LOCALHARD + GETF_RETDIRECTORY, .t., .t.)
            cFile += "log_" + dtos(ddatabase) + "_" + strtran(time(),":","") + ".log"
            nHandle := fcreate(cFile)
            fwrite(nHandle, cLogDtErr)
            fclose(nHandle)
         endif
      EndIf
   endif

return lRet

/*/{Protheus.doc} validDate
Realiza a validação dos registros da base de dados, do campo informado por parametro.

@type static function
@author Gabriel Hegler Klok
@since 29/04/2019
@version 1.0

@param cField, caracter, Campo(s) de data(s) que será validado.
/*/
static function validDate(cField, lAutoma)
   local cSql
   local nX
   local aFields     := strtokarr(cField, ',')
   local cTab        := iif(at("_", aFields[1]) == 4, substr(aFields[1], 1, 3), "S" + substr(aFields[1], 1, 2))
   local cFieldFilial:= substr(aFields[1], 1, at("_", aFields[1])-1) + "_FILIAL"
   local aArea       := getarea()

   default lAutoma   := .F.

   cSql := " SELECT " + cField + ", R_E_C_N_O_ FROM " + retsqlname(cTab)
   cSql += " WHERE " + cFieldFilial + " = '" + xfilial(cTab) + "'"
   cSql += " 	AND ("

   for nX := 1 to len(aFields)
      if nX == 1
         cSql += " ("
      else
         cSql += " OR ("
      endif

      cSql += " " + aFields[nX] + " <> ' '"
      cSql += " AND ("
      If !lAutoma // restrição de data do próprio GoodData
         cSql += " 	" + aFields[nX] + " NOT BETWEEN '19000101' AND '20501231' OR"
         cSql += " 	" + cSubStr + "(" + aFields[nX] + ", 1, 4) NOT BETWEEN '1900' AND '2050' OR"
      EndIf
      
      cSql += " 	" + cSubStr + "(" + aFields[nX] + ", 5, 2) NOT BETWEEN '01' AND '12' OR"
      cSql += " 	" + cSubStr + "(" + aFields[nX] + ", 7, 2) NOT BETWEEN '01' AND '31'"
      cSql += " )"
      cSql += " OR ((" + cSubStr + "(" + aFields[nX] + ", 5, 2) IN ('04', '06', '09','11') AND " + cSubStr + "(" + aFields[nX] + ", 7, 2) > '30')"
      cSql += " 	OR"

      if cDBType == "SQL"
         cSql += " 	(CAST(" + cSubStr + "(" + aFields[nX] + ", 1, 4) AS INT) % 4 = 0 AND " + cSubStr + "(" + aFields[nX] + ", 5, 2) = '02' AND " + cSubStr + "(" + aFields[nX] + ", 7, 2) > '29')"
         cSql += " 	OR"
         cSql += " 	(CAST(" + cSubStr + "(" + aFields[nX] + ", 1, 4) AS INT) % 4 <> 0 AND " + cSubStr + "(" + aFields[nX] + ", 5, 2) = '02' AND " + cSubStr + "(" + aFields[nX] + ", 7, 2) > '28'))"
      else
         cSql += " 	(MOD(CAST(" + cSubStr + "(" + aFields[nX] + ", 1, 4) AS NUMBER(10)),4) = 0 AND " + cSubStr + "(" + aFields[nX] + ", 5, 2) = '02' AND " + cSubStr + "(" + aFields[nX] + ", 7, 2) > '29')"
         cSql += " 	OR"
         cSql += " 	(MOD(CAST(" + cSubStr + "(" + aFields[nX] + ", 1, 4) AS NUMBER(10)),4) <> 0 AND " + cSubStr + "(" + aFields[nX] + ", 5, 2) = '02' AND " + cSubStr + "(" + aFields[nX] + ", 7, 2) > '28'))"
      endif

      cSql += " )"

   next nX

   cSql += " 	)"
   cSql += " 	AND D_E_L_E_T_ = ' '"
   cSql += " ORDER BY R_E_C_N_O_"

   cSql := changequery(cSql)

   dbusearea(.t., "TOPCONN", TcGenQry(,, cSql), "TRBData", .t., .t.)

   while ! TRBData->(eof())
      cLogDtErr += "Registro com data inválida na tabela " + cTab + ", verifique os campos: {" + cField + "} - R_E_C_N_O_ [ " + alltrim(str(TRBData->R_E_C_N_O_)) + " ] " + CRLF
      TRBData->(dbskip())
   enddo

   TRBData->(dbclosearea())
   restarea(aArea)
return