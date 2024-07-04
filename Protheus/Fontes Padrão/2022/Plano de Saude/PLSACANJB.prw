#include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "plsacanjb.ch"
#INCLUDE "PLSA001a.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSVSCAN ³ Autor ³ Renan Martins    ³ Data ³ 14/09/2015    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Execução genéruica de cancelamento de protocolos           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±³ *cAlias - Alias da tabela / aStatus - Status que deseja buscar na ta-  ±±±
±±³ bela(cAlias)                                                           ±±±
±±³ *cAliCpo - Nome do campo da tabela que possui o status                  ±±±
±±³ *cDataCpo - Nome do campo da tabela que possui o campo data para veri- ±±±
±±³ ficação                                                                ±±±
±±³ *cStatDs - Status desejado após a atualização                          ±±±
±±³ *cMotCpo - Campo de descrição do motivo de cancelamento                ±±±
±±³ *cCodF3 - Se a tabela possui campo F3 que necessita de preenchimento   ±±±
±±³ (motivo padrão),indique o valor que deve ser preenchido.               ±±±
±±³ *cCodMotCpo - Se a tabela possui campo F3 que necessita de preenchimento±±±
±±³ (motivo padrão), indique o nome do campo                               ±±±  
±±³ *cMsgObs - Informe a mensagem que deve ser salva no campo cMotCpo      ±±±
±±³ (motivo padrão),indique o valor que deve ser preenchido.               ±±±
±±³ *cNomParam - Se a quantidade de dias vier de um parâmetro qualquer,    ±±±
±±³ informe o nome deste parâmetro                                         ±±±
±±³ *cDatCanc - Se possuir, informe o campo em que deve ser salvo a data   ±±±
±±³ cancelamento (data do JOB)                                             ±±±
±±³ SEMPRE QUE FOR NOME DO CAMPO, PASSAR COM O UNDERLINE (ex: _DATACC)     ±±±  
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVSCAN(cAlias, aStatus, cAliCpo, cDataCpo, cStatDs, cMotCpo, cCodF3, cCodMotCpo, cMsgObs, cNomParam, cDatCanc)
LOCAL nQuantD	    := 0  
LOCAL nI		  	  := 0
LOCAL cStrStat	  := ""
Local cStatus := ""


Default cAlias    := "BOW" 
Default aStatus 	:= {"A","B"}  //A- Solicitação não concluída / B- Aguardando informação beneficiário 
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
  If( (cAlias)->&(cAlias+cAliCpo) $ cStrStat)    //Verifico se o campo escolhido contêm alguns dos status passados
      If ( !((calias)->&(cAlias+cDataCpo) + nQuantD) >= dDataBase) 

        cStatus := (cAlias)->&(cAlias+cAliCpo)
        (cAlias)->(RecLock(cAlias),.F.)
        (cAlias)->&(cAlias+cAliCpo) := cStatDs
        IIF( !(Empty(cMotCpo)), (cAlias)->&(cAlias+cMotCpo) := IIF (Empty(cMsgObs),STR0001, cMsgObs), "")

        If !(Empty(cCodF3)) .AND. !(Empty(cCodMotCpo))
          // Busca o Cod na tabela BBP, para preencher o memo da observação
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
        
         //Para os protocolos de reembolso foram incluidos e não foram finalizados pelos beneficiários temos que sinalizar
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
						{ 'BR_VIOLETA'    , STR0153},;	//"Em digitação"
						{ 'BR_VERDE'      , STR0154},;	//"Lib. financeiro"
						{ 'BR_MARRON'     , STR0155},;	//"Não lib. financeiro"
						{ 'BR_VERMELHO'   , STR0156},;	//"Glosado"
						{ 'BR_PRETO '     , STR0157},;	//"Auditoria"
						{ 'NGBIOALERTA_01', STR0232},;	//"Solicitação não concluída"
						{ 'BR_PINK'       , STR0233},;	//"Aguardando informação Beneficiária"
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
					{ 'BOW_STATUS = "A"', aCdCores[10,1]},;//Solicitação não concluída
					{ 'BOW_STATUS = "B"', aCdCores[11,1]},;//Aguardando informação Beneficiária
					{ 'BOW_STATUS = "C"', aCdCores[12,1]},;//Aprovado parcialmente
					{ 'BOW_STATUS = "D"', aCdCores[13,1]},;//Cancelado
					{ 'BOW_STATUS = "E"', aCdCores[14,1]} }//Reembolso Revertido

RpcSetEnv( cCodEm, cCodFil , , ,'PLS', , )

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Execução da Tarefa de cancelamento de guias conforme status" , 0, 0, {})
 
PLSVSCAN (aJob[1],aJob[2],aJob[3],aJob[4],aJob[5],aJob[6],aJob[7],aJob[8])

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Execução Finalizada!" , 0, 0, {})
 
Return()

