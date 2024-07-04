#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'


/*{Protheus.doc} UBAX90
//Função de envio de email.
@author marcelo.wesan
@since 07/10/2020
@version 
@type function
*/
Function UBAX90()
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

   If .not. TableInDic('NLO')  //proteção fonte
		Return .T.
	EndIf
   
   conout(" ********** INICIANDO PROCESSO DE E-MAIL  *********  ")
   conout("DATA:" + DTOC(DATE()) + " - HORA:" + TIME() )
   
   IF EMPTY(MV_PAR01) .OR. EMPTY(MV_PAR02) .OR. EMPTY(MV_PAR04) .OR. EMPTY(MV_PAR05)
      CONOUT("Parâmetros para execução do e-mail não informados.")
      lSai := .T.
   EndIf
   
   If lSai  //Sai da rotina sem enviar e-mail
      conout("SAINDO DA ROTINA DE ENVIO DE E-MAIL PRIMEIRA")
      Return .F.
   EndIf
   
   RPCSetType(3)  //Nao consome licensas
   UBAX90M()
   
   conout(" ********** PROCESSO DE E-MAIL FINALIZADO *********  ")
Return .T.

/*{Protheus.doc} SchedDef
//Função padrão schedule.
@author marcelo.wesan
@since 07/10/2020
@version 
@type function
*/
Static Function SchedDef()
  //executa função UBAX90 via schedule 
   Local aOrd := {}
   Local aParam := {}
   
   aParam := {"P"        ,;    //Processo
              "OGX040"   ,;    //PERGUNTE OU PARAMDEF
              ""         ,;    //ALIAS p/ relatorio
              aOrd       ,;    //Array de Ordenacao p/ relatorio
              ""         }     //Titulo para Relatório
Return aParam

/*{Protheus.doc} UBAX90M
//Função responsavel por receber dados e disparar e-mail de fardões.
@author marcelo.wesan
@since 20/03/2017
@version 
@type function
*/
Function UBAX90M()

   Local lSai   := .F.
   Local aParam := {}
   
   aAdd( aParam, {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05} )
   conout(" ********** INICIANDO PROCESSO DE E-MAIL  *********  ")
   conout("DATA:" + DTOC(DATE()) + " - HORA:" + TIME() )
   
   IF EMPTY(MV_PAR01) .OR. EMPTY(MV_PAR02) .OR. EMPTY(MV_PAR04) .OR. EMPTY(MV_PAR05)
      CONOUT("Parâmetros para execução do e-mail não informados.")
      lSai := .T.
   EndIf
   If lSai  //Sai da rotina sem enviar e-mail
      conout("SAINDO DA ROTINA DE ENVIO DE E-MAIL")
      Return .F.
   EndIf
   
   UBAX90EF(aParam[1][1],aParam[1][2],aParam[1][3],aParam[1][4],aParam[1][5] )//função de envio de e-mail

Return .T.

/*{Protheus.doc} UBAX90EF
//Busca os fardões a serem listados
@author marcelo.wesan
@since 07/10/2020
@version 
@type function
*/

Function UBAX90EF(cProcess, cTemplate, cQtdDias, cRemetent, cEmails, lExec)
   Local aArea := GetArea()
   Local cAliasBrw := ""
   Local dDatabase := Date()
   Local cBody     := "LISTA DE FARDÕES COM ERRO DE ENCERRAMENTO "
   Local aIndices  := {}
   Local nSetOrd   := 0 
   Local aAnexos   := ""
   Local cChave    := "" 

   cChave    := " NLO_CODFAR <> ''" + ;
                " AND NLO_DTENCE = '"+ DTOS(dDatabase) + "' AND D_E_L_E_T_ <> '*' " + ;
                " AND NLO_FILIAL = '" + FWxFilial("NLO") + "' "
  
   CONOUT("CHAMANDO OGX017 => ENVIO DE E-MAIL" )
   OGX017(cEmails, cBody, cAliasBrw, cChave, cProcess, aIndices, nSetOrd, aAnexos, cRemetent, cTemplate, .T.)
   CONOUT("RETORNANDO DE OGX017")
   RestArea(aArea)   
 
Return .T.

Return cData
