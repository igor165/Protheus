#include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "plsacanjb.ch"
#INCLUDE "PLSA001a.ch"


/*/
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSVSCAN � Autor � Renan Martins    � Data � 14/09/2015    ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Execu��o gen�ruica de cancelamento de protocolos           ����
��������������������������������������������������������������������������ٱ��
��� *cAlias - Alias da tabela / aStatus - Status que deseja buscar na ta-  ���
��� bela(cAlias)                                                           ���
��� *cAliCpo - Nome do campo da tabela que possui o status                  ���
��� *cDataCpo - Nome do campo da tabela que possui o campo data para veri- ���
��� fica��o                                                                ���
��� *cStatDs - Status desejado ap�s a atualiza��o                          ���
��� *cMotCpo - Campo de descri��o do motivo de cancelamento                ���
��� *cCodF3 - Se a tabela possui campo F3 que necessita de preenchimento   ���
��� (motivo padr�o),indique o valor que deve ser preenchido.               ���
��� *cCodMotCpo - Se a tabela possui campo F3 que necessita de preenchimento���
��� (motivo padr�o), indique o nome do campo                               ���  
��� *cMsgObs - Informe a mensagem que deve ser salva no campo cMotCpo      ���
��� (motivo padr�o),indique o valor que deve ser preenchido.               ���
��� *cNomParam - Se a quantidade de dias vier de um par�metro qualquer,    ���
��� informe o nome deste par�metro                                         ���
��� *cDatCanc - Se possuir, informe o campo em que deve ser salvo a data   ���
��� cancelamento (data do JOB)                                             ���
��� SEMPRE QUE FOR NOME DO CAMPO, PASSAR COM O UNDERLINE (ex: _DATACC)     ���  
������������������������������������������������������������������������������
/*/
Function PLSVSCAN(cAlias, aStatus, cAliCpo, cDataCpo, cStatDs, cMotCpo, cCodF3, cCodMotCpo, cMsgObs, cNomParam, cDatCanc)
LOCAL nQuantD	    := 0  
LOCAL nI		  	  := 0
LOCAL cStrStat	  := ""
Local cStatus := ""


Default cAlias    := "BOW" 
Default aStatus 	:= {"A","B"}  //A- Solicita��o n�o conclu�da / B- Aguardando informa��o benefici�rio 
Default cAliCpo 	:= "_STATUS" 
Default cDataCpo	:= "_DTDIGI"
Default cMotCpo   := "_MOTIND"
Default cCodF3    := "XXX"
Default cCodMotCpo:= "_MOTPAD"
Default cMsgObs   := ""
Default cNomParam := ""
Default cStatDs	  := "D"
Default cDatCanc	:= dDataBase


nQuantD	  	:= IIF ( Empty(cNomParam), GetNewPar("MV_PRACAN",15), GetNewPar(cNomParam,15) )

For nI := 1 TO Len(aStatus) 
  cStrStat += aStatus[nI] + ","
Next

cStrStat := SUBSTR(cStrStat,0,Len(cStrStat)-1) 

BBP->(DbSelectArea("BBP"))  
BBP->(DbSetOrder(1))
(cAlias)->(DbSelectArea(cAlias))
(cAlias)->(DbGoTop())

While !(cAlias)->(EOF())    
  If( (cAlias)->&(cAlias+cAliCpo) $ cStrStat)    //Verifico se o campo escolhido cont�m alguns dos status passados
      If ( !((calias)->&(cAlias+cDataCpo) + nQuantD) >= dDataBase) 

        cStatus := (cAlias)->&(cAlias+cAliCpo)
        (cAlias)->(RecLock(cAlias),.F.)
        (cAlias)->&(cAlias+cAliCpo) := cStatDs
        IIF( !(Empty(cMotCpo)), (cAlias)->&(cAlias+cMotCpo) := IIF (Empty(cMsgObs),STR0001, cMsgObs), "")

        If !(Empty(cCodF3)) .AND. !(Empty(cCodMotCpo))
          // Busca o Cod na tabela BBP, para preencher o memo da observa��o
          (cAlias)->&(cAlias+cCodMotCpo) := cCodF3
          If BBP->(MsSeek(xFilial("BBP")+cCodF3))
              If cAlias == "BOW"
                 If !Empty((cAlias)->&(cAlias+"_OBS"))
                        (cAlias)->&(cAlias+"_OBS") := (cAlias)->&(cAlias+"_OBS") + chr(13)+chr(10) + BBP->BBP_OBSERV
                  Else
                        (cAlias)->&(cAlias+"_OBS") := BBP->BBP_OBSERV
                  EndIf
              EndIf  
          EndIf
        EndIf 
        
         //Para os protocolos de reembolso foram incluidos e n�o foram finalizados pelos benefici�rios temos que sinalizar
        If cStatus == "A"
           PLRMBPRE("BOW","B1N", (cAlias)->&(cAlias+"_PROTOC"), (cAlias)->&(cAlias+cAliCpo)) 
        Endif   

        IIF( cAlias == "BOW", (cAlias)->&(cAlias+"_DTCANC") := dDataBase, IIF ( !(Empty(cDatCanc)), (cAlias)->&(cAlias+cDatCanc) := dDataBase, "") )
        (cAlias)->(MsUnLock()) 
      EndIf
    EndIf
  (cAlias)->(DbSkip())  
EndDo  
     
(cAlias)->(DbCloseArea())
BBP->(DbCloseArea())   
        
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PJB
Executa o job de cancelamento do protocolo de reembolso
@version P12
/*/
//-------------------------------------------------------------------
Function PJB(aJob)
Local cCodEm  := aJob[9]
Local cCodFil  := aJob[10]

//Legendas do protocolo.
PRIVATE aCdCores := { 	{ 'BR_AMARELO'    , STR0149},;	//"Protocolado"
						{ 'BR_AZUL'       , STR0150},;	//"Em analise"
						{ 'BR_BRANCO'     , STR0151},;	//"Deferido"
						{ 'BR_CINZA'      , STR0152},;	//"Indeferido"
						{ 'BR_VIOLETA'    , STR0153},;	//"Em digita��o"
						{ 'BR_VERDE'      , STR0154},;	//"Lib. financeiro"
						{ 'BR_MARRON'     , STR0155},;	//"N�o lib. financeiro"
						{ 'BR_VERMELHO'   , STR0156},;	//"Glosado"
						{ 'BR_PRETO '     , STR0157},;	//"Auditoria"
						{ 'NGBIOALERTA_01', STR0232},;	//"Solicita��o n�o conclu�da"
						{ 'BR_PINK'       , STR0233},;	//"Aguardando informa��o Benefici�ria"
						{ 'BR_AZUL_OCEAN' , STR0234},;	//"Aprovado parcialmente"
						{ 'BR_CANCEL'     , STR0235},;	//"Cancelado"
						{ 'BR_LARANJA'    , STR0283} }	//"Reembolso Revertido"

PRIVATE aCores := { { 'BOW_STATUS = "1"', aCdCores[ 1,1]},;//vermelho
					{ 'BOW_STATUS = "2"', aCdCores[ 2,1]},;//azul
					{ 'BOW_STATUS = "3"', aCdCores[ 3,1]},;//amarelo
					{ 'BOW_STATUS = "4"', aCdCores[ 4,1]},;//azul
					{ 'BOW_STATUS = "5"', aCdCores[ 5,1]},;//amarelo
					{ 'BOW_STATUS = "6"', aCdCores[ 6,1]},;//azul
					{ 'BOW_STATUS = "7"', aCdCores[ 7,1]},;//amarelo
					{ 'BOW_STATUS = "8"', aCdCores[ 8,1]},;//amarelo
					{ 'BOW_STATUS = "9"', aCdCores[ 9,1]},;//verde
					{ 'BOW_STATUS = "A"', aCdCores[10,1]},;//Solicita��o n�o conclu�da
					{ 'BOW_STATUS = "B"', aCdCores[11,1]},;//Aguardando informa��o Benefici�ria
					{ 'BOW_STATUS = "C"', aCdCores[12,1]},;//Aprovado parcialmente
					{ 'BOW_STATUS = "D"', aCdCores[13,1]},;//Cancelado
					{ 'BOW_STATUS = "E"', aCdCores[14,1]} }//Reembolso Revertido

RpcSetEnv( cCodEm, cCodFil , , ,'PLS', , )

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Execu��o da Tarefa de cancelamento de guias conforme status" , 0, 0, {})
 
PLSVSCAN (aJob[1],aJob[2],aJob[3],aJob[4],aJob[5],aJob[6],aJob[7],aJob[8])

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Execu��o Finalizada!" , 0, 0, {})
 
Return()

