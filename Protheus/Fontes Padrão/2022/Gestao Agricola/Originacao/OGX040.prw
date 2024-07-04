#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'


Function OGX040()
   //MV_PAR01 – Processo
   //MV_PAR02 – Template
   //MV_PAR03 – Qtd Dias
   //MV_PAR04 – Remetente
   //MV_PAR05 – Destinatário
   //MV_PAR06 – Empresa associada ao agendamento da rotina;
   //MV_PAR07 – Filial associada ao agendamento da rotina;
   //MV_PAR09 – Usuário associado ao agendamento;
  
   Local lSai   := .F.
   Local aParam := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08}
   
   conout(" ********** INICIANDO PROCESSO DE E-MAIL  *********  ")
   conout("DATA:" + DTOC(DATE()) + " - HORA:" + TIME() )
   
   IF EMPTY(MV_PAR01) .OR. EMPTY(MV_PAR02) .OR. EMPTY(MV_PAR03) .OR. EMPTY(MV_PAR04) .OR. EMPTY(MV_PAR05)
      CONOUT("Parâmetros para execução do e-mail não informados.")
      lSai := .T.
   EndIf

   IF EMPTY(MV_PAR06) .OR. EMPTY(MV_PAR07) .OR. EMPTY(MV_PAR08)
      CONOUT("Parâmetros de ambiente não informados .")
      lSai := .T.
   EndIf
   
   If lSai  //Sai da rotina sem enviar e-mail
      conout("SAINDO DA ROTINA DE ENVIO DE E-MAIL")
      Return .F.
   EndIf
   
   RPCSetType(3)  //Nao consome licensas
   OGX040ML01(aParam[1],aParam[2],aParam[3],aParam[4],aParam[5])
   
   conout(" ********** PROCESSO DE E-MAIL FINALIZADO *********  ")
Return .T.

Static Function SchedDef()
  //executa função OGX040 via schedule 
   Local aOrd := {}
   Local aParam := {}
   
   aParam := {"P"        ,;    //Processo
              "OGX040"   ,;    //PERGUNTE OU PARAMDEF
              ""         ,;    //ALIAS p/ relatorio
              aOrd       ,;    //Array de Ordenacao p/ relatorio
              ""         }     //Titulo para Relatório
Return aParam

/*{Protheus.doc} OGX040M
//Função responsavel por receber dados e disparar e-mail de fixação pendente.
@author marcelo.wesan
@since 20/03/2017
@version 
@type function
*/
Function OGX040M()

   Local lSai   := .F.
   Local aParam := {}
   
   Pergunte('OGX040MAIL'/*, .T.,"Gatilho de Inclusão"*/)
   aAdd( aParam, {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05} )
   conout(" ********** INICIANDO PROCESSO DE E-MAIL  *********  ")
   conout("DATA:" + DTOC(DATE()) + " - HORA:" + TIME() )
   
   IF EMPTY(MV_PAR01) .OR. EMPTY(MV_PAR02) .OR. EMPTY(MV_PAR03) .OR. EMPTY(MV_PAR04) .OR. EMPTY(MV_PAR05)
      CONOUT("Parâmetros para execução do e-mail não informados.")
      lSai := .T.
   EndIf
   If lSai  //Sai da rotina sem enviar e-mail
      conout("SAINDO DA ROTINA DE ENVIO DE E-MAIL")
      Return .F.
   EndIf
   
   OGX040ML01(aParam[1][1],aParam[1][2],aParam[1][3],aParam[1][4],aParam[1][5] )//função de envio de e-mail

Return .T.

Function OGX040ML01(cProcess, cTemplate, cQtdDias, cRemetent, cEmails, lExec)
   Local aArea := GetArea()
   lOCAL cAliasBrw := ""
   Local cBody     := "LISTA DE CONTRATO COM DADA LIMITE DE FIXAÇÃO A VENCER "
   Local aIndices  := {}
   Local nSetOrd   := 0 
   Local aAnexos   := ""
   Local cChave    := ""
   Local cDB := TcGetDB()

   If cDb = 'MSSQL'
     cStrDt := "GETDATE()"
   ElseIf cDb =  "ORACLE"
      cStrDt := "SYSDATE"
   EndIf

   cChave    := " (NNY_DTLFIX <> '') "  + ;
                " AND  ( " +  cCpoDataDB("NNY.NNY_DTLFIX") + " >= " + cStrDt + " AND " +  cCpoDataDB("NNY.NNY_DTLFIX") + " <= "+ cStrDt + " + " + cQtdDias + ") " + ;
                "AND NNY.NNY_QTDINT > ISNULL( (SELECT SUM(NN8_QTDFIX)  " + ;
                                             "  FROM " + RetSqlName("NN8")+ " NN8 " + ;
                                            " WHERE NN8_FILIAL = '" + fwXFilial("NN8") + "' " + ; 
                                             " AND NN8_CODCTR = NNY_CODCTR " + ;
                                             " AND NN8_CODCAD = NNY_ITEM " + ;
                                             " AND D_E_L_E_T_ = ' ' ), 0) "
   CONOUT("CHAMANDO OGX017 => ENVIO DE E-MAIL")
   OGX017(cEmails, cBody, cAliasBrw, cChave, cProcess, aIndices, nSetOrd, aAnexos, cRemetent, cTemplate, .T.)
   CONOUT("RETORNANDO DE OGX017")
   RestArea(aArea)   
 
Return .T.

/*{Protheus.doc} cCpoDataDB
//Tratamento SQL
@author marcelo.ferrari
@since 20181020
@version 
@type function
*/
Static Function cCpoDataDB(cCpoData)
   Local cDB := TcGetDB()
   If cDb = 'MSSQL'
      cData := cCpoData
   ElseIf cDb =  "ORACLE"
      cData := "TO_DATE(" + cCpoData + ", 'YYYYMMDD')"
   EndIf

Return cData
