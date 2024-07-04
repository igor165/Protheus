#INCLUDE "EECMC110.ch"
/*    
Programa : EECMC110
Objetivo : Integracao com Modulo de Faturamento
Autor    : Cristiano A. Ferreira
Data/Hora: 10/11/1999 17:00
Obs.     : 
*/

#include "EEC.CH"

Function EECMC110

Local l := EasyGParam("MV_EECFAT")

IF ValType(l) == "L" .And. l
   EECAE100("I")
Else
   Help(" ",1,"AVG0000085")
Endif

Return NIL

/*
Funcao      : MC110Init
Parametros  : nenhum
Retorno     : nenhum
Objetivos   : Alterar variaveis para o browse da EECAE100
Autor       : Cristiano A. Ferreira
Data/Hora   : 11/11/1999 14:19
Revisao     :
Obs.        : Executado antes da mBrowse
*/
Function MC110Init()

cCadastro:=STR0001 //"Integração"
aRotina  := { { STR0002, "AxPesqui", 0 , PESQUISAR},; //"Pesquisar"
              { STR0003, "MC110Manut(4)", 0 , 4 },; //"Solicitar"
              { STR0004,  "MC110Manut(5)", 0 , 5, 3 },; //"Cancelar"
              { STR0005, "MC110FLW", 0 , 6 } } //"Follow-up"

EEC->(dbSetOrder(4))
EEC->(dbSeek(xFilial()))

Return NIL

/*
Funcao      : MC110Manut
Parametros  : nOpc := Opcao a ser passada para a funcao AE100MAN
Retorno     : nenhum
Objetivos   : Executar a funcao AE100MAN
Autor       : Cristiano A. Ferreira
Data/Hora   : 12/11/1999 16:25
Revisao     :
Obs.        :
*/
Function MC110Manut(nOpc)

Begin Sequence

   Inclui := .f.
   Altera := .f.
   
   AE100MAN("EEC",EEC->(RecNo()),nOpc)
End Sequence

Return NIL

/*
Funcao      : MC110InitManut
Parametros  : nOpc    := Opcao (3=Inclusao,4=Alteracao,5=Exclusao)
              aAltera := Array com o nome dos campos alteraveis
Retorno     : nenhum
Objetivos   : Alterar variaveis para as rotinas de  
              Solicitar e Cancelar 
Autor       : Cristiano A. Ferreira
Data/Hora   : 11/11/1999 14:49
Revisao     :
Obs.        : Chamado antes da definicao da Janela de Manutencao
*/
Function MC110InitManut(nOpc,aAltera)

Local lRet := .t.

Begin Sequence
   IF nOpc == 4 // Solicitar
      IF M->EEC_STATUS != ST_EM
         HELP(" ",1,"AVG0005041") //MsgStop("Processo não Embarcado !","Aviso")
         lRet := .f.
         Break
      Endif
      
      IF !Empty(M->EEC_FATURA)
         MsgStop(STR0006+Dtoc(M->EEC_FATURA),STR0007) //"Processo já faturado em "###"Aviso"
         lRet := .f.
         Break
      Endif
      aAltera := {"EEC_FATURA"}
      aAdd(aHdEnchoice,"EEC_FATURA")
      bVal_Ok := {|| MC110Integra(3), oDlg:End() }
      lAltera := .T.
      M->EEC_FATURA := dDataBase
      nOpc := VISUALIZAR
   Elseif nOpc == 5 // Cancelar
      IF Empty(M->EEC_FATURA)
         HELP(" ",1,"AVG0005042") //MsgStop("Este processo não foi faturado no SIGAFAT !","Aviso")
         lRet := .f.
         Break
      Endif
      bVal_Ok := {|| MC110Integra(5), oDlg:End() }
      aAdd(aHdEnchoice,"EEC_FATURA")
      lAltera := .F.
      nOpc := VISUALIZAR
   Endif
End Sequence

Return lRet

/*
Funcao      : MC110FLU
Parametros  : cAlias, nReg, nOpc
Retorno     : nil
Objetivos   : Follow-up de Faturamentos
Autor       : Cristiano A. Ferreira
Data/Hora   : 11/11/1999 15:22
Revisao     :
Obs.        :
*/
Function MC110FLW(cAlias,nReg,nOpc)

Local cFollow := "EECFATW"

Begin Sequence

   IF EasyEntryPoint(cFollow)
      ExecBlock(cFollow,.F.,.F.,{cAlias,nReg,nOpc})
   Else
      Help(" ",1,"AVG0000057")
   Endif
   
End Sequence

Return NIL

*------------------------------------------------------------------------*
* FIM DO PROGRAMA EECMC110.PRW                                           *
*------------------------------------------------------------------------*
