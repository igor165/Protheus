#INCLUDE "EFFSA160.ch"
#include "Average.ch"
#include "TOPCONN.CH"

//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EFFSA160
//Autor.....: Cleverson E. da Silva(CES)
//Data......: 04 de Junho de 2002, 17:00
//Sintaxe...: EFFSA160 
//Uso.......: SIGAEFF   
//Versao....: Protheus - 6.09a
//Descricao.: Relatorio de Movimentacao de Contrato(Utilizando SetPrint) 
//------------------------------------------------------------------------------------//
// ----------------------------------------------------------------------
// PLB - Pedro Luiz Baroni
// 10/05/2006
// Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
// Inclusao de Impressao dos Financiamentos de Importacao
// ----------------------------------------------------------------------

*----------------------*
FUNCTION EFFSA160()
*----------------------*
LOCAL cDataHoje,cMesAtual
LOCAL nIndSX3 := SX3->(IndexOrd())
Private cFiltro_s:=" "  //Alcir Alves - 31-05-05
PRIVATE cNomeArq,lTop,dDtIni,dDtFim,cContrato
PRIVATE cQuery,cFilEF1:=xFilial("EF1"),cFilEF3:=xFilial("EF3"),cfilSA6:=xFilial("SA6"),cfilEEC:=xFilial("EEC"),aFilSel:={},Adata:={},WorkFile:=""
//ALCIR ALVES -14-02-05  CASO EXISTA NOVOS CAMPOS DA CHAVE EF1,EF2 E EF3 - INICIO
//PRIVATE lExistBCO := iif(EF3->(FieldPos("EF3_BAN_FI")) > 0 .AND. EF3->(FieldPos("EF3_PRACA")) > 0 .AND.;
//                         EF2->(FieldPos("EF2_BAN_FI")) > 0 .AND. EF2->(FieldPos("EF2_PRACA")) > 0 ,.T.,.F.) 
//---------------------------------------------------------------------- - FIM                          

// ACSJ - 02/03/2005 -------- INICIO - Verifica a existencia do campo EF1_ROF
SX3->(DBSetOrder(2))
Private lExistRof := SX3->(DBSEEK("EF1_ROF"))
Private cFilSX5:=xfilial("SX5")
Private cFilEEQ:=xfilial("EEQ")
Private cFilSA1:=xfilial("SA1")
Private cFilSA2:=xfilial("SA2")

//** PLB - 10/05/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private cFiltroF3Fin := "E/I"            // Variavel utilizada no F3 "EFA"
Private lEvCont := .F.                   // Variavel utilizada no F3 "EFA"
Private lCadFin := ChkFile("EF7")        // Cadastro de Tipos de Financiamento
Private cTpModu := "E"
Private cFiltroF3Rof := "E/I"
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0
Private cChSX1    := "" ,;
        cParSX1   := "" ,;
        cSeqSX1   := "" ,;
        cValidSX1 := "" 
//**

Private lExistBCO := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
                     SX3->(DBSeek("ECE_BANCO")) .and. SX3->(DBSeek("ECE_PRACA"))

Private cPergunta // AST - 03/03/09 - utilizada na função FindSX1

SX3->(DBSetOrder(nIndSX3))
// -------------------------- FIM                                                                             

//Alcir Alves - 15-02-05 - força os indices de ordem 1 em caso de mudança de indices em outros programa
EF1->(dbsetorder(1))
EF3->(dbsetorder(1))
//

#IFDEF TOP
  lTop := .T.
#ElSE
  lTop := .F.
#ENDIF  

/*
//Alcir Alves - 14-02-05
   If !SX1->(dbSeek("EFFSA1"+"01"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "01"
      SX1->X1_VARIAVL := "mv_ch1"
      SX1->X1_VAR01   := "mv_par01"
      SX1->X1_PERGUNT := "Nro. Contrato"
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := Len(EF1->EF1_CONTRA)
      SX1->X1_GSC     := "G"
      SX1->X1_F3      := "EF2"
      SX1->X1_VALID   := "EFFSA160VAL('CONTRATO')"
      SX1->(msUnlock())
   ENDIF
   If !SX1->(dbSeek("EFFSA1"+"02"))
     SX1->(RecLock("SX1",.T.))
     SX1->X1_GRUPO   := "EFFSA1"
     SX1->X1_ORDEM   := "02"
     SX1->X1_VARIAVL := "mv_ch2"
     SX1->X1_VAR01   := "mv_par02"
     SX1->X1_PERGUNT := "Data Inicial"
     SX1->X1_TIPO    := "D"
     SX1->X1_TAMANHO := 8
     SX1->X1_GSC     := "G"
     SX1->X1_VALID   :="E_Periodo_Ok(mv_par02,mv_par03)" //Comentado !VAZIO() .AND. 
     SX1->(msUnlock())     
  ENDIF
  If !SX1->(dbSeek("EFFSA1"+"03"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "03"
      SX1->X1_VARIAVL := "mv_ch3"
      SX1->X1_VAR01   := "mv_par03"
      SX1->X1_PERGUNT := "Data Final"
      SX1->X1_TIPO    := "D"
      SX1->X1_TAMANHO := 8
      SX1->X1_GSC     := "G"
      SX1->X1_VALID   :="E_Periodo_Ok(mv_par02,mv_par03)"  //Comentado !VAZIO() .AND. 
      SX1->(msUnlock())
  ENDIF
  If !SX1->(dbSeek("EFFSA1"+"04"))
     SX1->(RecLock("SX1",.T.))
     SX1->X1_GRUPO   := "EFFSA1"
     SX1->X1_ORDEM   := "04"
     SX1->X1_VARIAVL := "mv_ch4"
     SX1->X1_VAR01   := "mv_par04"
     SX1->X1_PERGUNT := "Tipo do Financiamento"
     SX1->X1_TIPO    := "C"
     SX1->X1_TAMANHO := Len(EF1->EF1_TP_FIN)
     SX1->X1_GSC     := "G"
     SX1->X1_F3      := "CG"
     SX1->X1_VALID   := "EFFSA160VAL('TIPOFIN')"
     SX1->(msUnlock())
  ENDIF
  If !SX1->(dbSeek("EFFSA1"+"05"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "05"
      SX1->X1_VARIAVL := "mv_ch5"
      SX1->X1_VAR01   := "mv_par05"
      SX1->X1_PERGUNT := "Codigo Evento"
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := Len(EF3->EF3_CODEVE)
      SX1->X1_GSC     := "G"
      SX1->X1_F3      := "EFF"
      SX1->X1_VALID   := "EFFSA160VAL('EVENTO')"
      SX1->(msUnlock())
   Endif
   If !SX1->(dbSeek("EFFSA1"+"06"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "06"
      SX1->X1_VARIAVL := "mv_ch6"
      SX1->X1_VAR01   := "mv_par06"
      SX1->X1_PERGUNT := "Exportador"
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := Len(SA2->A2_COD)
      SX1->X1_GSC     := "G"
      SX1->X1_F3      := "SA2"
      SX1->X1_VALID   := "EFFSA160VAL('EXPORT')"
      SX1->(msUnlock())
   Endif
   If !SX1->(dbSeek("EFFSA1"+"07"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "07"
      SX1->X1_VARIAVL := "mv_ch7"
      SX1->X1_VAR01   := "mv_par07"
      SX1->X1_PERGUNT := "Loja do export."
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := Len(SA2->A2_LOJA)
      SX1->X1_GSC     := "G"
      SX1->(msUnlock())
   Endif  
   If !SX1->(dbSeek("EFFSA1"+"08"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "08"
      SX1->X1_VARIAVL := "mv_ch8"
      SX1->X1_VAR01   := "mv_par08"
      SX1->X1_PERGUNT := "Processo:"
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := AVSX3("EEC_PREEMB",3)
      SX1->X1_GSC     := "G"
      SX1->X1_F3      := "EEC"
      SX1->X1_VALID   := "If(!Empty(mv_par08),ExistCpo('EEC',mv_par08),.T.)"
      SX1->(msUnlock())   
   endif
   If !SX1->(dbSeek("EFFSA1"+"09"))        
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "09"
      SX1->X1_VARIAVL := "mv_ch9"
      SX1->X1_VAR01   := "mv_par09"
      SX1->X1_PERGUNT := "Invoice:"
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := AVSX3("EF3_INVOIC",3)
      SX1->X1_VALID   := "EFFSA160VAL('INVOICE')"
      SX1->X1_GSC     := "G"
      SX1->(msUnlock())  
   endif
   If !SX1->(dbSeek("EFFSA1"+"10")) 
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "10"
      SX1->X1_VARIAVL := "mv_cha"
      SX1->X1_VAR01   := "mv_par10"
      SX1->X1_PERGUNT := "Importador:"
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := AVSX3("A1_COD",3)
      SX1->X1_GSC     := "G"
      SX1->X1_VALID   := "If (!Empty(mv_par10),ExistCpo('SA1',mv_par10),.T.)"
      SX1->X1_F3      := "SA1"
      SX1->(msUnlock())  
   endif
   If !SX1->(dbSeek("EFFSA1"+"11")) 
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "11"
      SX1->X1_VARIAVL := "mv_chb"
      SX1->X1_VAR01   := "mv_par11"
      SX1->X1_PERGUNT := "Loja do Import."
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := AVSX3("A1_LOJA",3)
      SX1->X1_GSC     := "G"
      SX1->(msUnlock())  
   endif
   If !SX1->(dbSeek("EFFSA1"+"12"))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := "EFFSA1"
      SX1->X1_ORDEM   := "12"
      SX1->X1_VARIAVL := "mv_chc"
      SX1->X1_VAR01   := "mv_par12"
      SX1->X1_PERGUNT := "Banco da operação:"
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := AVSX3("A6_COD",3)
      SX1->X1_GSC     := "G"
      SX1->X1_F3      := "A62"
      SX1->X1_VALID   := "If (!Empty(mv_par12),ExistCpo('SA6',mv_par12),.T.)"
      SX1->(msUnlock())   
   endif                           
   // ACSJ -  02/03/2005 ------- INICIO
   cGrupo := "EFFSA1"
   cOrdem := "13"           
   cMv    := "d"
   if lExistRof
      If !SX1->(dbSeek(cGrupo+cOrdem))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := cGrupo
         SX1->X1_ORDEM   := cOrdem
         SX1->X1_VARIAVL := "mv_ch"+cMv
         SX1->X1_VAR01   := "mv_par"+cOrdem 
         SX1->X1_PERGUNT := "ROF:"
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := AVSX3("EF1_ROF",3)
         SX1->X1_GSC     := "G"
         SX1->(msUnlock())   
      endif
      cOrdem := alltrim(Str(Val(cOrdem)+1))
      cMv    := "e"
   Endif
   // ACSJ --------------------- FIM
   If !SX1->(dbSeek(cGrupo+cOrdem))
      SX1->(RecLock("SX1",.T.))
      SX1->X1_GRUPO   := cGrupo
      SX1->X1_ORDEM   := cOrdem
      SX1->X1_VARIAVL := "mv_ch"+cMv
      SX1->X1_VAR01   := "mv_par"+cOrdem
      SX1->X1_PERGUNT := "Destino de impressão"
      SX1->X1_TIPO    := "N"
      SX1->X1_TAMANHO := 1
      SX1->X1_DECIMAL := 0
      SX1->X1_GSC     := "C"
      SX1->X1_DEF01   := "Impressora"
      SX1->X1_DEF02   := "Arquivo"
      SX1->X1_DEF03   := "Ms-excel"
      SX1->(msUnlock())
   ENDIF
//
*/

//** PLB 10/05/06 - Nova Estrutura dos Perguntes
/*
      If lEFFTpMod
         If !SX1->(dbSeek("EFFSA1"+"01"))
            RecLock("SX1",.T.)
            SX1->X1_GRUPO   := "EFFSA1"
            SX1->X1_ORDEM   := "01"
            SX1->X1_VARIAVL := "mv_ch1"
            SX1->X1_VAR01   := "mv_par01"
            SX1->X1_PERGUNT := "Tipo Modulo"
            SX1->X1_TIPO    := "N"
            SX1->X1_TAMANHO := 1
            SX1->X1_DECIMAL := 0
            SX1->X1_GSC     := "C"
            SX1->X1_VALID   := "Empty(mv_par01) .Or. SA160ValPerg('TpModu',mv_par01)"
            SX1->X1_DEF01   := "1-Exportacao"
            SX1->X1_DEF02   := "2-Importacao"
            SX1->X1_DEF03   := "3-Ambos"
            SX1->(msUnlock())
         EndIf   
      EndIf
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="02",cChSX1:="mv_ch2",cParSX1:="mv_par02"}, ;
               {||cSeqSX1:="01",cChSX1:="mv_ch1",cParSX1:="mv_par01"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Nro. Contrato"
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := Len(EF1->EF1_CONTRA)
         SX1->X1_GSC     := "G"
         SX1->X1_VALID   := "Empty("+cParSX1+") .Or. SA160ValPerg('Contra',"+cParSX1+")"
         SX1->X1_F3      := "EF2"
         SX1->(msUnlock())
      ENDIF
      If lEFFTpMod
          Eval( {||cSeqSX1:="03",cChSX1:="mv_ch3",cParSX1:="mv_par03"} )
          If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
             SX1->(RecLock("SX1",.T.))
             SX1->X1_GRUPO   := "EFFSA1"
             SX1->X1_ORDEM   := cSeqSX1
             SX1->X1_VARIAVL := cChSX1
             SX1->X1_VAR01   := cParSX1
             SX1->X1_PERGUNT := "Sequencia do Contrato"
             SX1->X1_TIPO    := "C"
             SX1->X1_TAMANHO := AVSX3("EF1_SEQCNT",3)
             SX1->X1_DECIMAL := 0
             SX1->X1_GSC     := "G"
             SX1->(msUnlock())
          Endif                      
      EndIf
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="04",cChSX1:="mv_ch4",cParSX1:="mv_par04",cValidSX1:="mv_par04,mv_par05"}, ;
               {||cSeqSX1:="02",cChSX1:="mv_ch2",cParSX1:="mv_par02",cValidSX1:="mv_par02,mv_par03"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Data Inicial"
         SX1->X1_TIPO    := "D"
         SX1->X1_TAMANHO := 8
         SX1->X1_GSC     := "G"
         SX1->X1_VALID   :="VAZIO() .or. E_Periodo_Ok("+cValidSX1+")"                          
         SX1->(msUnlock())     
     ENDIF
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="05",cChSX1:="mv_ch5",cParSX1:="mv_par05",cValidSX1:="mv_par04,mv_par05"}, ;
               {||cSeqSX1:="03",cChSX1:="mv_ch3",cParSX1:="mv_par03",cValidSX1:="mv_par02,mv_par03"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Data Final"
         SX1->X1_TIPO    := "D"
         SX1->X1_TAMANHO := 8
         SX1->X1_GSC     := "G"
         SX1->X1_VALID   :="VAZIO() .or. E_Periodo_Ok("+cValidSX1+")"                          
         SX1->(msUnlock())
      ENDIF
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="06",cChSX1:="mv_ch6",cParSX1:="mv_par06"}, ;
               {||cSeqSX1:="04",cChSX1:="mv_ch4",cParSX1:="mv_par04"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Tipo do Financiamento"
         SX1->X1_TIPO    := AVSX3("EF1_TP_FIN",2)
         SX1->X1_TAMANHO := AVSX3("EF1_TP_FIN",3)
         SX1->X1_GSC     := "G"
         SX1->X1_VALID   := "Empty("+cParSX1+") .Or. SA160ValPerg('TipFin',"+cParSX1+")"
         SX1->X1_F3      := IIF(lCadFin,"EFA","CG")
         SX1->(msUnlock())
      ENDIF
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="07",cChSX1:="mv_ch7",cParSX1:="mv_par07"}, ;
               {||cSeqSX1:="05",cChSX1:="mv_ch5",cParSX1:="mv_par05"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Codigo Evento"
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := Len(EF3->EF3_CODEVE)
         SX1->X1_GSC     := "G"
         SX1->X1_VALID   := "Empty("+cParSX1+") .Or. SA160ValPerg('CodEve',"+cParSX1+")"
         SX1->X1_F3      := "EFF"
         SX1->(msUnlock())
      Endif
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="08",cChSX1:="mv_ch8",cParSX1:="mv_par08"}, ;
               {||cSeqSX1:="06",cChSX1:="mv_ch6",cParSX1:="mv_par06"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Exportador"
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := Len(SA2->A2_COD)
         SX1->X1_GSC     := "G"
         SX1->X1_VALID   := "VAZIO() .or. AvgExistCpo('SA2',"+cParSX1+")"
         SX1->X1_F3      := "SA2"
         SX1->(msUnlock())
      Endif
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="09",cChSX1:="mv_ch9",cParSX1:="mv_par09"}, ;
               {||cSeqSX1:="07",cChSX1:="mv_ch7",cParSX1:="mv_par07"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Loja do export."
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := Len(SA2->A2_LOJA)
         SX1->X1_GSC     := "G"
         SX1->(msUnlock())
      Endif  
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="10",cChSX1:="mv_chA",cParSX1:="mv_par10"}, ;
               {||cSeqSX1:="08",cChSX1:="mv_ch8",cParSX1:="mv_par08"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Processo:"
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := AVSX3("EEC_PREEMB",3)
         SX1->X1_GSC     := "G"
         SX1->X1_VALID   := "VAZIO() .or. AvgExistCpo('EEC',"+cParSX1+")"
         SX1->(msUnlock())   
      endif
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="11",cChSX1:="mv_chB",cParSX1:="mv_par11"}, ;
               {||cSeqSX1:="09",cChSX1:="mv_ch9",cParSX1:="mv_par09"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Invoice:"
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := AVSX3("EF3_INVOIC",3)
         SX1->X1_GSC     := "G"
         SX1->X1_VALID   := "Empty("+cParSX1+") .Or. SA160ValPerg('Invoice',"+cParSX1+")"
         SX1->(msUnlock())  
      endif
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="12",cChSX1:="mv_chC",cParSX1:="mv_par12"}, ;
               {||cSeqSX1:="10",cChSX1:="mv_chA",cParSX1:="mv_par10"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Importador:"
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := AVSX3("A2_COD",3)
         SX1->X1_GSC     := "G"
         SX1->X1_VALID   := "VAZIO() .or. AvgExistCpo('SYT',"+cParSX1+")"
         SX1->X1_F3      := "SYT"
         SX1->(msUnlock())  
      endif
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="13",cChSX1:="mv_chD",cParSX1:="mv_par13"}, ;
               {||cSeqSX1:="11",cChSX1:="mv_chB",cParSX1:="mv_par11"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Loja do Import."
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := AVSX3("A2_LOJA",3)
         SX1->X1_GSC     := "G"
         SX1->(msUnlock())  
      endif
      Eval( IIF( lEFFTpMod, ;
               {||cSeqSX1:="14",cChSX1:="mv_chE",cParSX1:="mv_par14"}, ;
               {||cSeqSX1:="12",cChSX1:="mv_chC",cParSX1:="mv_par12"} ) ) //** PLB 11/05/06
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Banco da operação:"
         SX1->X1_TIPO    := "C"
         SX1->X1_TAMANHO := AVSX3("A6_COD",3)
         SX1->X1_GSC     := "G"
         SX1->X1_F3      := "SA6"
         SX1->X1_VALID   := "VAZIO() .or. AvgExistCpo('SA6',"+cParSX1+")"
         SX1->(msUnlock())             
      endif
   
      if lExistRof
         Eval( IIF( lEFFTpMod, ;
                  {||cSeqSX1:="15",cChSX1:="mv_chF",cParSX1:="mv_par15"}, ;
                  {||cSeqSX1:="13",cChSX1:="mv_chD",cParSX1:="mv_par13"} ) ) //** PLB 11/05/06
         If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
            SX1->(RecLock("SX1",.T.))
            SX1->X1_GRUPO   := "EFFSA1"
            SX1->X1_ORDEM   := cSeqSX1
            SX1->X1_VARIAVL := cChSX1
            SX1->X1_VAR01   := cParSX1
            SX1->X1_PERGUNT := "ROF:"
            SX1->X1_TIPO    := "C"
            SX1->X1_TAMANHO := AVSX3("EF1_ROF",3)
            SX1->X1_GSC     := "G"
            SX1->X1_VALID   := "Vazio() .Or. SA160ValPerg('ROF',"+cParSX1+")"
            SX1->X1_F3      := IIF(lCadFin,"EFB","")
            SX1->(msUnlock())
         endif
      Endif
      If lEFFTpMod
         If lExistRof
            cSeqSX1:="16"
            cChSX1:="mv_chG"
            cParSX1:="mv_par16"
         Else
            cSeqSX1:="15"
            cChSX1:="mv_chF"
            cParSX1:="mv_par15"
         EndIf
      Else
         If lExistRof
            cSeqSX1:="14"
            cChSX1:="mv_chE"
            cParSX1:="mv_par14"
         Else
            cSeqSX1:="13"
            cChSX1:="mv_chD"
            cParSX1:="mv_par13"
         EndIf
      EndIf            
      If !SX1->(dbSeek("EFFSA1"+cSeqSX1))
         SX1->(RecLock("SX1",.T.))
         SX1->X1_GRUPO   := "EFFSA1"
         SX1->X1_ORDEM   := cSeqSX1
         SX1->X1_VARIAVL := cChSX1
         SX1->X1_VAR01   := cParSX1
         SX1->X1_PERGUNT := "Destino de impressão"
         SX1->X1_TIPO    := "N"
         SX1->X1_TAMANHO := 1
         SX1->X1_DECIMAL := 0
         SX1->X1_GSC     := "C"
         SX1->X1_DEF01   := "Impressora"
         SX1->X1_DEF02   := "Arquivo"
         SX1->X1_DEF03   := "Ms-excel"
         SX1->(msUnlock())
      ENDIF
//**
*/

aFilSel:=AvgSelectFil(.T.,"EF1") //Alcir Alves - 21/12/04 - conceito multifilial
if aFilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
   cPergunta := "EFFSA1" // AST - 03/03/09 - utilizada na função FindSX1
   IF ! PERGUNTE("EFFSA1",.T.)
       RETURN .T.
   ENDIF   
   //** PLB 11/05/06
   If lEFFTpMod
      Do Case
         Case mv_par01 == 1
            cTpModu := "E"
         Case mv_par01 == 2
            cTpModu := "I"
      End Case
   EndIf
   //**
   
/*   IF EMPTY(mv_par02)
      mv_par02 :=CTOD("01/01/00")  
   ENDIF
   IF EMPTY(mv_par03)
      mv_par03 :=CTOD("31/12/49")  
   ENDIF                      */ //Henrique Raineire 20060222 - Comentado para fixar valores nos campos data quando não preenchidos.
   
   cContrato  := IIF(lEFFTpMod,mv_par02,mv_par01)
   dDtIni     := IIF(lEFFTpMod,mv_par04,mv_par02)
   dDtFim     := IIF(lEFFTpMod,mv_par05,mv_par03)
   nTipRel    := IIF(lEFFTpMod,mv_par06,mv_par04)
   cDataHoje  :=DTOC(dDataBase)
   cMesAtual  :=SUBSTR(cDataHoje,4,2)

   cFiltro_s:=""
   //** PLB 11/05/06
   If lEFFTpMod
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par01) .And. mv_par01!=3,AVSX3("EF1_TPMODU",5)+": "+IIF(cTpModu=="E",STR0036,STR0037)+" | ","")   //"Exportacao" , "Importacao"
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+alltrim(iif(!empty(mv_par02),AVSX3("EF1_CONTRA",5)+": "+alltrim(mv_par02)+" | ",""))
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+alltrim(iif(!empty(mv_par03),AVSX3("EF1_SEQCNT",5)+": "+alltrim(mv_par03)+" | ",""))
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par06),AVSX3("EF1_TP_FIN",5)+": "+AllTrim(IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+mv_par06,"EF7_DESCRI"),Tabela("CG",mv_par06,.F.)))+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par07),AVSX3("EF3_CODEVE",5)+": "+alltrim((mv_par07))+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par08),AVSX3("EEC_FORN",5)+": "+alltrim(mv_par08)+"-"+Alltrim(POSICIONE("SA2",1,cFilSA1+AvKey(mv_par06,"A2_COD"),"A2_NREDUZ"))+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par10),AVSX3("EEC_PREEMB",5)+": "+alltrim(mv_par10)+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par11),AVSX3("EEC_NRINVO",5)+": "+alltrim(mv_par11)+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par12),AVSX3("EEC_IMPORT",5)+": "+alltrim(mv_par12)+"-"+Alltrim(POSICIONE("SA1",1,cFilSA1+AvKey(mv_par10,"A1_COD"),"A1_NREDUZ"))+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par14),AVSX3("EF1_BAN_FI",5)+": "+alltrim(mv_par14)+" | ","")
   //**
   Else
     //Alcir Alves - 31-05-05 
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+alltrim(iif(!empty(mv_par01),AVSX3("EF1_CONTRA",5)+": "+alltrim(mv_par01)+" | ",""))
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par04),AVSX3("EF1_TP_FIN",5)+": "+AllTrim(IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+mv_par04,"EF7_DESCRI"),Tabela("CG",mv_par04,.F.)))+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par05),AVSX3("EF3_CODEVE",5)+": "+alltrim((mv_par05))+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par06),AVSX3("EEC_FORN",5)+": "+alltrim(mv_par06)+"-"+Alltrim(POSICIONE("SA2",1,cFilSA1+AvKey(mv_par06,"A2_COD"),"A2_NREDUZ"))+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par08),AVSX3("EEC_PREEMB",5)+": "+alltrim(mv_par08)+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par09),AVSX3("EEC_NRINVO",5)+": "+alltrim(mv_par09)+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par10),AVSX3("EEC_IMPORT",5)+": "+alltrim(mv_par10)+"-"+Alltrim(POSICIONE("SA1",1,cFilSA1+AvKey(mv_par10,"A1_COD"),"A1_NREDUZ"))+" | ","")
     cFiltro_s+=iif(len(cFiltro_s)>210,chr(13)+chr(10),"")+iif(!empty(mv_par12),AVSX3("EF1_BAN_FI",5)+": "+alltrim(mv_par12)+" | ","")
     //
   EndIf


/*   IF EMPTY(dDtIni) .AND. EMPTY(dDtFim)

//      dDtIni:=CTOD("01"+SUBSTR(cDataHoje,3))  //Henrique Raineire 20060222 - Comentado para Nao Fixar Data do Periodo igual ao do Mes
//      dDtFim:=dDtIni+30                      //Henrique Raineire 20060222 - Comentado idem

      
      DO WHILE cMesAtual # SUBSTR(DTOC(dDtFim),4,2)
         dDtFim--
      ENDDO
      
   ELSEIF EMPTY(dDtIni) .AND. !EMPTY(dDtFim)
   
      dDtIni:=CTOD("01"+SUBSTR(DTOC(dDtFim),3))
   
   ELSEIF !EMPTY(dDtIni) .AND. EMPTY(dDtFim)
   
      dDtFim:=dDtIni+30
      
      DO WHILE SUBSTR(DTOC(dDtIni),4,2) # SUBSTR(DTOC(dDtFim),4,2)
         dDtFim--
      ENDDO                                                      
   ENDIF                                                         
   */     //Henrique Raineire 20060222 - Comentado para não estipular datas quando não estiverem preenchidas
   
   
   SA160PRINT()
ENDIF
//WORK->(E_EraseArq(WorkFile)) //ACSJ - 18/MAR/2005
RETURN .T.

*---------------------*
FUNCTION SA160PRINT()
*---------------------*
LOCAL cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
LOCAL cDesc2         := STR0002 //"Movimentacao de Contratos de Cambio"
LOCAL cDesc3         := "", cPict := "", imprime := .T.
PRIVATE titulo       := STR0003 //"Saldo de Contratos de Cambio"
PRIVATE nLin         := 80, Cabec1 :=STR0004+DTOC(dDtIni)+STR0005+DTOC(dDtFim),Cabec2 := "" //"Periodo de "###" a "
PRIVATE cString      := "EF1", CbTxt := "", lEnd := .F.
PRIVATE lAbortPrint  := .F., limite := 132, tamanho := "132"
PRIVATE nomeprog     := "EFFSA160", nTipo := 18
PRIVATE aReturn      := {STR0006 , 1, STR0007, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
PRIVATE nLastKey     := 0, cbcont := 00
PRIVATE CONTFL       := 01, m_pag := 01
PRIVATE wnrel        := "EFFSA160" // Coloque aqui o nome do arquivo usado para impressao em disco

   //** PLB 11/05/06
   If lEFFTpMod
      cabec2 := STR0038  // "Modulo: "
      If lExistRof
         cParSX1:="mv_par16"
      Else
         cParSX1:="mv_par15"
      EndIf
   Else
      If lExistRof
         cParSX1:="mv_par14"
      Else
         cParSX1:="mv_par13"
      EndIf
   EndIf            
   //**

IF &(cParSX1)==1  //iif(lExistRof,mv_par14,mv_par13) ==1 //caso destino seja impressora
   wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)
   If nLastKey = 27
      Return
   Endif
   SetDefault(aReturn,cString)
   nTipo := If(aReturn[4]==1,15,18)
   RptStatus({|lEnd| SA160Imprime(wnRel,cString)})
else
   Processa({||SA160Imprime()})
   Erase(WorkFile+ORDBAGEXT())
endif

Return .T. 

*-------------------------*
FUNCTION SA160Imprime()
*-------------------------*  
Local lCanPrt:=.F.
Local cChave2:=""
LOCAL cChave:=xFilial("EF1"),cAliasArq:="EF1",cFilSYF:=xFilial("SYF"),aContratos:={},ni:=0,nIgnora:=.T.,nPrintToT:=.F.
LOCAL bWhile:={||EF1->EF1_FILIAL==cChave},cNomeMoeda:=" ",cTipoContrato:="",nAscan
LOCAL lPrint:=.F.,nCont, nInd, cFilAtu:="-"
LOCAL dDataI,dDataF,aSeekEF3:={"600","630","999","500","501"}//VINCULADOS=600,LIQUIDACAO=630,ESTORNO=999 VARIACAO CAMBIAL=500 E 501
LOCAL nCol01:=01,;
      nCol02:=nCol01+30,;
      nCol03:=nCol02+25,;
      nCol04:=nCol03+32
            
LOCAL nTit01:=nCol01,;
      nTit02:=nTit01+30,;
      nTit03:=nTit02+30,;
      nTit04:=nTit03+30
      
LOCAL cPicture:=AVSX3("EF3_VL_MOE",6),nVlContrato:=0,nVlRealCont:=0,nTaxa:=1
LOCAL nTi, nTi2,aGeral:={} //AAF 12/01/05
Local nTpMod
Local lExistEF3 := .F. // PLB 01/05/06 - Verifica se encontrou algum evento
Private nLinTot:=55
PRIVATE nLin := 99
Private cTipoModu := ""
// Alcir Alves - 20/12/04  - tratamento de multifilial
//begincomm
//aFilEF3:=AvgSelectFil(.F.,"EF3")
//aFilSYF:=AvgSelectFil(.F.,"SYF")
//endcomm

//** PLB 12/05/06
If lEFFTpMod
   AAdd(aSeekEF3,"700")   // Parcela de Pagamento
EndIf
//**

//ALCIR ALVES - 15-02-05 - EXPORTAÇÃO PARA EXCEL OU TEXTO
//IF iif(lExistRof,mv_par14,mv_par13)==2 .or. iif(lExistRof,mv_par14,mv_par13)==3 //caso destino de impressão seja texto ou excel
IF &(cParSX1)==2 .Or. &(cParSX1)==3  // PLB 11/05/06
    Adata:= {}
    Aadd(Adata,{"FILIAL",AVSX3("EF1_FILIAL",2),4,AVSX3("EF3_FILIAL",4)}) //FILIAL
    If lEFFTpMod
       Aadd(Adata,{"TPMODU",AVSX3("EF1_TPMODU",2),AVSX3("EF1_TPMODU",3),AVSX3("EF1_TPMODU",4)}) // PLB 11/05/06  // Tipo Modulo
    EndIf
    Aadd(Adata,{"CONTRATO",AVSX3("EF1_CONTRA",2),AVSX3("EF1_CONTRA",3),AVSX3("EF1_CONTRA",4)}) //CONTRATO
    If lEFFTpMod
       Aadd(Adata,{"SEQCNT",AVSX3("EF1_SEQCNT",2),AVSX3("EF1_SEQCNT",3),AVSX3("EF1_SEQCNT",4)}) // PLB 11/05/06  // Sequencia
    EndIf
    Aadd(Adata,{"TIPO_CONTR",AVSX3("EF1_TP_FIN",2),AVSX3("EF1_TP_FIN",3),AVSX3("EF1_TP_FIN",4)}) //TIPO DE CONTRATO
    Aadd(Adata,{"BANCO_OP",AVSX3("EF1_BAN_FI",2),AVSX3("EF1_BAN_FI",3),AVSX3("EF1_BAN_FI",4)}) //BANCO
    IF lExistBCO
        Aadd(Adata,{"PRACA",AVSX3("EF1_PRACA",2),AVSX3("EF1_PRACA",3),AVSX3("EF1_PRACA",4)}) //PRACA
    ENDIF
    Aadd(Adata,{"DT_VINC",AVSX3("EF1_DT_VIN",2),AVSX3("EF1_DT_VIN",3),AVSX3("EF1_DT_VIN",4)}) //DATA DA VINCULACAO
    Aadd(Adata,{"DT_LIQ",AVSX3("EF1_DT_VEN",2),AVSX3("EF1_DT_VEN",3),AVSX3("EF1_DT_VEN",4)}) //DATA DA LIQUIDACAO

    Aadd(Adata,{"MOEDA",AVSX3("EF1_MOEDA",2),AVSX3("EF1_MOEDA",3),AVSX3("EF1_MOEDA",4)}) //MOEDA
    Aadd(Adata,{"VINC_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR VINCULADO ACUM. ANTERIOR NA MOEDA    
    Aadd(Adata,{"EVINC_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO VINCULADO ACUM. ANTERIOR NA MOEDA    
    Aadd(Adata,{"LIQ_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO ACUM. ANTERIOR NA MOEDA    
    Aadd(Adata,{"ELIQ_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO  ACUM. ANTERIOR NA MOEDA    
    Aadd(Adata,{"VINC_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR VINCULADO  NO MES NA MOEDA    
    Aadd(Adata,{"EVINC_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO VINCULADO NO MES NA MOEDA    
    Aadd(Adata,{"LIQ_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO ACUM. NO MES NA MOEDA    
    Aadd(Adata,{"ELIQ_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO  NO MES NA MOEDA    
    Aadd(Adata,{"VINC_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR VINCULADO ACUM. ATUAL NA MOEDA    
    Aadd(Adata,{"EVINC_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO VINCULADO ACUM. ATUAL NA MOEDA    
    Aadd(Adata,{"LIQ_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO ACUM. ATUAL NA MOEDA    
    Aadd(Adata,{"ELIQ_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO  ACUM. ATUAL NA MOEDA    
    Aadd(Adata,{"SLD_V_MOE",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //SALDO A VINCULAR NA MOEDA    
    Aadd(Adata,{"SLD_L_MOE",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //SALDO A LIQUIDAR NA MOEDA    
    Aadd(Adata,{"VL_C_MOE",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR DO CONTRATO NA MOEDA    
    Aadd(Adata,{"VINC_REA",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR VINCULADO ACUM. ANTERIOR EM REAL
    Aadd(Adata,{"EVINC_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO VINCULADO ACUM. ANTERIOR EM REAL
    Aadd(Adata,{"LIQ_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO ACUM. ANTERIOR EM REAL
    Aadd(Adata,{"ELIQ_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO  ACUM. ANTERIOR EM REAL
    Aadd(Adata,{"VINC_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR VINCULADO  NO MES EM REAL
    Aadd(Adata,{"EVINC_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO VINCULADO NO MES EM REAL
    Aadd(Adata,{"LIQ_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO ACUM. NO MES EM REAL
    Aadd(Adata,{"ELIQ_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO  NO MES EM REAL
    Aadd(Adata,{"VINC_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR VINCULADO ACUM. ATUAL EM REAL
    Aadd(Adata,{"EVINC_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO VINCULADO ACUM. EM REAL
    Aadd(Adata,{"LIQ_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO ACUM. ATUAL EM REAL
    Aadd(Adata,{"ELIQ_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO  ACUM. ATUAL EM REAL
    Aadd(Adata,{"VC_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VC EM REAL
    Aadd(Adata,{"VC_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VC EM REAL
    Aadd(Adata,{"VC_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VC EM REAL
    Aadd(Adata,{"EVC_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO VC EM REAL
    Aadd(Adata,{"EVC_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO VC EM REAL
    Aadd(Adata,{"EVC_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO VC EM REAL
    Aadd(Adata,{"SLD_V_REA",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //SALDO A VINCULAR EM REAL
    Aadd(Adata,{"SLD_L_REA",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //SALDO A LIQUIDAR EM REAL 
    Aadd(Adata,{"VL_C_REA",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR DO CONTRATO EM REAL
    If Select("Work") > 0
       Work->( DBCloseArea() )       
    EndIf

    WorkFile := E_CriaTrab(,Adata,"Work") //THTS - 25/09/2017 - TE-6431 - Temporario no Banco de Dados
ENDIF
//


   IF !EMPTY(cContrato)
      If !lEFFTpMod
         cChave:=cChave+cContrato
         bWhile:={||EF1->EF1_FILIAL+EF1->EF1_CONTRA==cChave}
      Else
         //** PLB 11/05/06
         If mv_par01 == 1
            cChave := cChave+"E"+cContrato
            bWhile := {||EF1->EF1_FILIAL+EF1->EF1_TPMODU+EF1->EF1_CONTRA==cChave}
         ElseIf mv_par01 == 2
            cChave := cChave+"I"+cContrato
            bWhile := {||EF1->EF1_FILIAL+EF1->EF1_TPMODU+EF1->EF1_CONTRA==cChave}
         ElseIf mv_par01 == 3
            cChave2 := cChave
            cChave  := cChave+"E"+cContrato
            cChave2 := cChave2+"I"+cContrato
            bWhile  := { || EF1->EF1_FILIAL+EF1->EF1_TPMODU+EF1->EF1_CONTRA==cChave .Or. EF1->EF1_FILIAL+EF1->EF1_TPMODU+EF1->EF1_CONTRA==cChave2 }
         EndIf
         //**
      EndIf
   ENDIF
   
   IF lTop               
      bWhile:={||.T.}
      //cAliasArq:="EF1NEW"
      //** PLB 11/05/06 - Gera uma query para cada tipo de modulo
      If lEFFTpMod
         If mv_par01==3  // Ambos
            cAliasArq:="EF1EXP" 
            SA160QUERY("EF1EXP")
            cAliasArq:="EF1IMP"
            SA160QUERY("EF1IMP")
         ElseIf mv_par01==1  // Exportacao
            cAliasArq:="EF1EXP" 
            SA160QUERY("EF1EXP")
         ElseIf mv_par01==2  // Importacao
            cAliasArq:="EF1IMP"
            SA160QUERY("EF1IMP")
         EndIf
      Else
         cAliasArq:="EF1EXP" 
         SA160QUERY("EF1EXP")
      EndIf
      //**
   ENDIF

EF1->(DBSEEK(cChave))
//** PLB 11/05/06
For nTpMod := 1  To  IIF((lEFFTpMod .And. mv_par01==3),2,1)
   If lEFFTpMod
      If mv_par01==2
         cAliasArq := "EF1IMPNEW"
         cTipoModu := STR0037   // "Importacao"
      ElseIf mv_par01==3  .And.  nTpMod == 2
         cAliasArq := "EF1IMPNEW"
         (cAliasArq)->( DBGoTop() )
         If !(cAliasArq)->( EoF() )
            cTipoModu := STR0037   // "Importacao"
         EndIf
      Else
         cAliasArq := "EF1EXPNEW"
         cTipoModu := STR0036  // "Exportacao"
      EndIf
   Else
      cAliasArq := "EF1EXPNEW"
   EndIf
   (cAliasArq)->( DBGoTop() )
   nLin := 99
   //**
   for ni=1 to len(aFilSel) //Alcir Alves - 20-12-04  - tratamento de multifilial
   
      lPrint:=.F.   
      aContratos:={}
   
      cChave:=aFilSel[ni]
      cFilEF1:=aFilSel[ni]
      cFilEF3:=aFilSel[ni]
      cFilEEC:=aFilSel[ni]
      cFilSYF:=xFilial("SYF") //AAF 12/01/05 - O SYF é um cadastro compartilhado. //iif(len(aFilSYF)==1 .and. alltrim(aFilSYF[1])=="",aFilSYF[1],cChave)


      //Variaveis de Totalizacao em Reais
      nTotRAA:=nTotRVMM:=nTotREAA:=nTotREVMM:=nTotRLAA:=nTotRLMM:=nTotRELAA:=0
      nTotRELMM:=nTotRCAMAA:=nTotRCAMMM:=nTotRVARAA:=nTotRVARMM:=0

      DO WHILE (cAliasArq)->(!EOF()) .AND. EVAL(bWhile)

         IF lTop
               EF1->(DBGOTO((cAliasArq)->REGISTRO))  // PLB 11/05/06
               //EF1->(DBGOTO(EF1NEW->REGISTRO))
         ELSEIF !EMPTY(EF1->EF1_DT_ENC) 
            //Alcir Alves - 27-12-04 
            (cAliasArq)->(DBSKIP())     // EF1->(DBSKIP())
            LOOP       
         ENDIF
                                
         //Alcir Alves - 16-02-05  
         IF !lExistBCO
            EF3->(DBSEEK(cFilEF3+EF1->EF1_CONTRA))
         ELSEIf !lEFFTpMod
            EF3->(DBSEEK(cFilEF3+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA))
         Else
            EF3->(DBSEEK(cFilEF3+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT))   // PLB 11/05/06
         ENDIF
         //
         IF EF3->(EOF())
            //Alcir Alves - 27-12-04 
            (cAliasArq)->(DBSKIP())     
            LOOP
         ENDIF
      
         //** PLB 11/05/06 - Validacao dos novos Filtros
         If lEFFTpMod  
            If !Empty(mv_par01)  .And.  mv_par01 != 3  .And.  EF1->EF1_TPMODU != cTpModu  // Tipo do Modulo
               (cAliasArq)->(DBSkip())
               Loop
            EndIf
            If !Empty(mv_par03)  .And.  EF1->EF1_SEQCNT != mv_par03 // Sequencia do Contrato
               (cAliasArq)->(DBSkip())
               Loop
            EndIf
         EndIf
         //**

         //Alcir Alves - 15-02-05 - validações dos novos perguntes
         IF !empty(IIF(lEFFTpMod,mv_par06,mv_par04)) .and. EF1->EF1_TP_FIN#IIF(lEFFTpMod,mv_par06,mv_par04)    //tipo de financiamento
              (cAliasArq)->(DBSKIP())   
              LOOP
         ENDIF   

         IF !empty(IIF(lEFFTpMod,mv_par08,mv_par06)) .and. EF1->EF1_EXPORT#IIF(lEFFTpMod,mv_par08,mv_par06)    //Exportador
              (cAliasArq)->(DBSKIP())   
              LOOP
         ENDIF
      
         IF !empty(IIF(lEFFTpMod,mv_par09,mv_par07)) .and. EF1->EF1_LOJA#IIF(lEFFTpMod,mv_par09,mv_par07)    //Loja
              (cAliasArq)->(DBSKIP())   
              LOOP
         ENDIF
 
         IF  !empty(IIF(lEFFTpMod,mv_par14,mv_par12)) .and. EF1->EF1_BAN_FI#IIF(lEFFTpMod,mv_par14,mv_par12)  //VALIDAÇÃO DO PERGUNTE BANCO DA OPERAÇÃO
             (cAliasArq)->(DBSKIP())   
             LOOP
         ENDIF      
      
 	     If lExistRof
            IF  !empty(IIF(lEFFTpMod,mv_par15,mv_par13)) .and. EF1->EF1_ROF#IIF(lEFFTpMod,mv_par15,mv_par13)  //VALIDAÇÃO DO PERGUNTE ROF
                (cAliasArq)->(DBSKIP())   
                LOOP
            ENDIF      
         Endif

         //  
         IF SYF->(DBSEEK(cFilSYF+EF1->EF1_MOEDA))
            cNomeMoeda:=ALLTRIM(SYF->YF_DESC_SI)
         ENDIF

         //Alcir Alves - 16-02-05
         IF !lExistBCO
             EF3->(DBSEEK(cFilEF3+EF1->EF1_CONTRA+"100"))
         ELSEIf !lEFFTpMod
             EF3->(DBSEEK(cFilEF3+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+"100"))
         Else
             EF3->(DBSEEK(cFilEF3+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+"100"))  // PLB 11/05/06
         ENDIF
         //
         IF !EF3->(eof())
            nVlContrato:=EF3->EF3_VL_MOE
            nTaxa:=EF3->EF3_TX_MOE //BuscaTaxa(EF1->EF1_MOEDA,ddatabase,.T.,.F.,.T.)
            nVlRealCont:=nVlContrato*nTaxa
         ENDIF
     
        //** PLB 11/05/06
        If lEFFTpMod
           If lExistRof
              cParSX1:="mv_par16"
           Else
              cParSX1:="mv_par15"
           EndIf
        Else
           If lExistRof
              cParSX1:="mv_par14"
           Else
              cParSX1:="mv_par13"
           EndIf
        EndIf            
        If &(cParSX1) == 1 //caso destino de impressão seja IMPRESSORA
        //**
        //IF iif(lExistRof,mv_par14,mv_par13)==1 //caso destino de impressão seja IMPRESSORA
           IF nLin >nLinTot
              nLin:=Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
              nLin++           
              //08        
              //** PLB 12/05/06
              If !Empty(AllTrim(cFiltro_s))
                 @nLin,0 PSAY cFiltro_s
                 nLin:=nLin+2
              EndIf   
              //**
           ENDIF
           if !(len(aFilSel)==1 .and. ALLTRIM(aFilSel[1])=="")
               if cFilAtu#aFilSel[ni] 
                  IF cFilAtu#"-"
                     Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
                     nLin:=08
                     //** PLB 12/05/06
                     If !Empty(AllTrim(cFiltro_s))
                        @nLin,0 PSAY cFiltro_s
                        nLin:=nLin+2
                     EndIf   
                     //**
                  ENDIF
                  @nLin,0 PSAY replicate("*",138)
                  nLin++
                  cFilAtu:=aFilSel[ni] 
                  afilial_n:=AvgFilName({cFilAtu})
                  @ nLin,02 PSAY "Filial"+" "+cFilAtu+" - "+afilial_n[1]          
                  nLin++
                  @nLin,0 PSAY replicate("*",138)
                  nLin++
               endif
           endif
        ENDIF

         //cTipoContrato:=Tabela("CG",EF1->EF1_TP_FIN,.F.)   
         // PLB 11/05/06 - Novo Cadastro de Tipos de FInanciamento
         cTipoContrato:=IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"),Tabela("CG",EF1->EF1_TP_FIN,.F.))
         
         nVLVAA  :=0//Acumulado Anterior Vinculados na Moeda
         nVLRAA  :=0//Acumulado Anterior Vinculados em R$
         nVLEAA  :=0//Acumulado Anterior Estorno Vinculacao na Moeda
         nVLREAA :=0//Acumulado Anterior Estorno Vinculacao em R$
         nVLLAA  :=0//Acumulado Anterior Liquidacao na Moeda
         nVLRLAA :=0//Acumulado Anterior Liquidacao em R$
         nVLESAA :=0 //Acumulado Anterior Estorno Liquidacao na Moeda
         nVLRELAA:=0//Acumulado Anterior Estorno Liquidacao em R$
         nVLVMM  :=0//Movimento Mes Vinculados na Moeda do Financ.
         nVLRVMM  :=0//Movimento Mes Vinculados em R$
         nVLEVMM  :=0//Movimento Mes Estorno Vinculacao na Moeda do Financ.
         nVLREVMM :=0//Movimento Mes Estorno Vinculacao em R$
         nVLELMM :=0//Movimento Mes Estorno Liquidacao na Moeda do Financ.
         nVLRELMM:=0//Movimento Mes Estorno Liquidacao em R$
         nVLLMM :=0//Movimento Mes Anterior Liquidacao na Moeda
         nVLRLMM:=0//Movimento Mes Anterior Liquidacao na Moeda
         nVLRCAMAA:=0//Variacao Cambial Acumulado Anterior em R$
         nVLRCAMMM:=0//Variacao Cambial Movimento Mes em R$
         nVLRVARAA :=0//Estono Variacao Acumulado Anterior em R$
         nVLRVARMM :=0//Variacao Cambial Movimento Mes em R$
        
         FOR nCont:=1 TO LEN(aSeekEF3)
            //ALCIR ALVES - 14-02-05
            cWhile:={|| .T. }
            IF !lExistBCO
                EF3->(DBSEEK(cFilEF3+EF1->EF1_CONTRA+aSeekEF3[nCont]))
            ELSEIf !lEFFTpMod
                EF3->(DBSEEK(cFilEF3+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+aSeekEF3[nCont]))
                cWhile:={|| EF3->EF3_BAN_FI==EF1->EF1_BAN_FI .and. EF3->EF3_PRACA==EF1->EF1_PRACA }
            Else
               //** PLB 11/05/06
                EF3->(DBSEEK(cFilEF3+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+aSeekEF3[nCont]))
                cWhile:={|| EF3->EF3_TPMODU==EF1->EF1_TPMODU .and. EF3->EF3_BAN_FI==EF1->EF1_BAN_FI .and. EF3->EF3_PRACA==EF1->EF1_PRACA .and. EF3->EF3_SEQCNT==EF1->EF1_SEQCNT }
               //**
            ENDIF
            //
            DO WHILE EF3->(!EOF()) .AND. EF3->EF3_FILIAL==cFilEF3 .AND. EF3->EF3_CONTRA==EF1->EF1_CONTRA .AND. EF3->EF3_CODEVE==aSeekEF3[nCont] .and. eval(cWhile)
               IF !Empty(dDtFim) .And. EF3->EF3_DT_EVE > dDtFim //Henrique Raineire 20060222 - incluido !Empty para que nos casos da data não estiver preenchida ele não entrar no IF
                  EF3->(DBSKIP())
                  LOOP
               ENDIF
            
               //Alcir Alves - 15-02-05
               IF  !empty(IIF(lEFFTpMod,mv_par10,mv_par08)) .and. EF3->EF3_PREEMB#IIF(lEFFTpMod,mv_par10,mv_par08)  //VALIDAÇÃO DO PERGUNTE EMBARQUE
                  EF3->(DBSKIP())
                  LOOP
               ENDIF      
               IF  !empty(IIF(lEFFTpMod,mv_par11,mv_par09)) .and. EF3->EF3_INVOIC#IIF(lEFFTpMod,mv_par11,mv_par09)  //VALIDAÇÃO DO PERGUNTE INVOICE
                  EF3->(DBSKIP())
                  LOOP
               ENDIF      
               IF !empty(IIF(lEFFTpMod,mv_par07,mv_par05)) .and. EF3->EF3_CODEVE#IIF(lEFFTpMod,mv_par07,mv_par05)  //evento
                  EF3->(DBSKIP())
                  LOOP
               ENDIF      

               IF !empty(IIF(lEFFTpMod,mv_par12,mv_par10)) .OR. !empty(IIF(lEFFTpMod,mv_par13,mv_par11)) //CASO O PERGUNTE IMPORTADOR OU LOJA D IMPORT NÃO ESTEJAM VAZIOS
                    IF EEC->(DBSEEK(cfilEEC+EF3->EF3_PREEMB))
                        IF !empty(IIF(lEFFTpMod,mv_par12,mv_par10)) .AND. EEC->EEC_IMPORT#IIF(lEFFTpMod,mv_par12,mv_par10) //CASO IMPORTADOR DIFERENTE
                           EF3->(DBSKIP())
                           LOOP
                        ENDIF
                        IF !empty(IIF(lEFFTpMod,mv_par13,mv_par11)) .AND. EEC->EEC_IMLOJA#IIF(lEFFTpMod,mv_par13,mv_par11)  //CASO LOJA DIFERENTE
                           EF3->(DBSKIP())
                           LOOP
                        ENDIF
                    ELSE
                        EF3->(DBSKIP())
                        LOOP
                    ENDIF
               ENDIF
               //          

               DO CASE
                  CASE !Empty(dDtIni) .And. EF3->EF3_DT_EVE < dDtIni  //Henrique Raineire 20060222 - incluido !EMpty para nos casos da data não estiver preenchida ele não entra no IF
                     //** PLB 12/05/06
                     If lEFFTpMod  .And.  EF1->EF1_CAMTRA == "1"  // Parcelas de Pagamento
                        If EF3->EF3_CODEVE=="700"  .And.  EF3->EF3_TX_MOE > 0
                           nVLLAA+=EF3->EF3_VL_MOE
                           nVLRLAA+=EF3->EF3_VL_REA 
                        ElseIf EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="700"
                           nVLESAA+=EF3->EF3_VL_MOE
                           nVLRELAA+=EF3->EF3_VL_REA
                        ElseIF EF3->EF3_CODEVE=="600" .And. (EF3->EF3_EV_VIN=="700"  .Or.  EF3->EF3_TPMODU=="I")
                           nVLVAA+=EF3->EF3_VL_MOE
                           nVLRAA+=EF3->EF3_VL_REA
                        ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="600" .And. (EF3->EF3_EV_VIN=="700"  .Or.  EF3->EF3_TPMODU=="I")
                           nVLEAA+=EF3->EF3_VL_MOE
                           nVLREAA+=EF3->EF3_VL_REA 
                        EndIf
                     Else
                        IF EF3->EF3_CODEVE=="630"
                           nVLLAA+=EF3->EF3_VL_MOE
                           nVLRLAA+=EF3->EF3_VL_REA 
                        ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="630"
                           nVLESAA+=EF3->EF3_VL_MOE
                           nVLRELAA+=EF3->EF3_VL_REA
                        ElseIF EF3->EF3_CODEVE=="600"
                           nVLVAA+=EF3->EF3_VL_MOE
                           nVLRAA+=EF3->EF3_VL_REA
                        ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="600"
                           nVLEAA+=EF3->EF3_VL_MOE
                           nVLREAA+=EF3->EF3_VL_REA 
                        EndIf
                     EndIf
                     //**
                     IF EF3->EF3_CODEVE=="500"
                        nVLRCAMAA+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="501"
                        nVLRCAMAA+=EF3->EF3_VL_REA   //Alcir Alves - 20-05-05 - soma sempre evento 501
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="500"
                        nVLRVARAA+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="501"
                        nVLRVARAA+=EF3->EF3_VL_REA                  //Alcir Alves - 20-05-05 - soma sempre evento 501
                     ENDIF
         
                  CASE (Empty(dDtIni) .Or. EF3->EF3_DT_EVE>=dDtIni) .AND. (Empty(dDtFim) .Or. EF3->EF3_DT_EVE<=dDtFim) //Henrique Raineire 20060222 - incluido 2 Empty .Or. para nos casos da data não estiver preenchida ele forçar entrar no CASE
                     //** PLB 12/05/06
                     If lEFFTpMod  .And.  EF1->EF1_CAMTRA == "1"  // Parcelas de Pagamento
                        If EF3->EF3_CODEVE=="700"  .And.  EF3->EF3_TX_MOE > 0
                           nVLLMM+=EF3->EF3_VL_MOE
                           nVLRLMM+=EF3->EF3_VL_REA 
                        ElseIf EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="700"
                           nVLELMM+=EF3->EF3_VL_MOE
                           nVLRELMM+=EF3->EF3_VL_REA
                        ElseIF EF3->EF3_CODEVE=="600" .And. (EF3->EF3_EV_VIN=="700"  .Or.  EF3->EF3_TPMODU=="I")
                           nVLVMM+=EF3->EF3_VL_MOE
                           nVLRVMM+=EF3->EF3_VL_REA
                        ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="600" .And. (EF3->EF3_EV_VIN=="700"  .Or.  EF3->EF3_TPMODU=="I")
                           nVLEVMM+=EF3->EF3_VL_MOE
                           nVLREVMM+=EF3->EF3_VL_REA 
                        EndIf
                     Else
                        IF EF3->EF3_CODEVE=="600"
                           nVLVMM+=EF3->EF3_VL_MOE
                           nVLRVMM+=EF3->EF3_VL_REA
                        ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="600"
                           nVLEVMM+=EF3->EF3_VL_MOE
                           nVLREVMM+=EF3->EF3_VL_REA 
                        ELSEIF EF3->EF3_CODEVE=="630"
                           nVLLMM+=EF3->EF3_VL_MOE
                           nVLRLMM+=EF3->EF3_VL_REA 
                        ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="630"
                           nVLELMM+=EF3->EF3_VL_MOE
                           nVLRELMM+=EF3->EF3_VL_REA 
                        EndIf
                     EndIf
                     //**
                     IF EF3->EF3_CODEVE=="500"
                        nVLRCAMMM+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="501"
                        nVLRCAMMM+=EF3->EF3_VL_REA                  //Alcir Alves - 20-05-05 - soma sempre evento 501
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="500"
                        nVLRVARMM+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="501"
                        nVLRVARMM+=EF3->EF3_VL_REA                  //Alcir Alves - 20-05-05 - soma sempre evento 501
                     ENDIF                                                               
                  ENDCASE
                  lExistEF3 := .T.
                  nIgnora:=.F. //Alcir Alves - 31-05-05
                  nPrintToT:=.t. 
                  lCanPrt:=.T.
                  EF3->(DBSKIP())
            ENDDO              
         NEXT

            //** PLB 11/05/06 - Caso nao encontre evento
            If !lExistEF3
               (cAliasArq)->(DBSkip())
               Loop
            EndIf
            //**

      if nIgnora==.F.
         IF nLin >nLinTot
             nLin:=Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
            //Alcir Alves - 06-06-05
            if !(len(aFilSel)==1 .and. ALLTRIM(aFilSel[1])=="")
              nLin:=8
            else
              nLin++
            endif
            if !empty(alltrim(cFiltro_s))
               @nLin,0 PSAY cFiltro_s
               nLin:=nLin+2
            endif   
            //
         ENDIF
   
         IF(nAscan:=ASCAN(aContratos,{|a|a[1]==EF1->EF1_MOEDA}) )==0
            AADD(aContratos,{EF1->EF1_MOEDA,nVLVAA,nVLVMM,nVLEAA,nVLEVMM,nVLLAA,nVLLMM,nVLESAA,nVLELMM})
         ELSE
            aContratos[nAscan,2]+=nVLVAA
            aContratos[nAscan,3]+=nVLVMM
            aContratos[nAscan,4]+=nVLEAA
            aContratos[nAscan,5]+=nVLEVMM
            aContratos[nAscan,6]+=nVLLAA
            aContratos[nAscan,7]+=nVLLMM
            aContratos[nAscan,8]+=nVLESAA
            aContratos[nAscan,9]+=nVLELMM
         ENDIF   
      
         //** PLB 11/05/06
         If lEFFTpMod
            If lExistRof
               cParSX1:="mv_par16"
            Else
               cParSX1:="mv_par15"
            EndIf
         Else
            If lExistRof
               cParSX1:="mv_par14"
            Else
               cParSX1:="mv_par13"
            EndIf
         EndIf            
         If &(cParSX1) == 1 //caso destino de impressão seja IMPRESSORA
         //**
         //IF iif(lExistRof,mv_par14,mv_par13)==1 //caso destino de impressão seja IMPRESSORA  - ALCIR ALVES - 15-02-05
            Plin()
            @nLin,1 PSAY __PrtFatLine()
            Plin()
            //@nLin,0 PSAY __PrtLeft(STR0008+AllTrim(cTipoContrato)+": "+EF1->EF1_CONTRA+IIF(lEFFTpMod,space(5)+"Seq.: "+EF1->EF1_SEQCNT,"")+space(4)+STR0009+cTipoContrato+space(6)+STR0028+EF1->EF1_BAN_FI+"-"+POSICIONE("SA6",1,cfilSA6+EF1->EF1_BAN_FI,"A6_NOME")+SPACE(6)+STR0029+DTOC(EF1->EF1_DT_VIN)+SPACE(6)+STR0030+DTOC(EF1->EF1_DT_VEN))    //Contrato de "###" Tipo:  Banco      Prazo vinculaçao      prazo liquidacao
            @nLin,0 PSAY __PrtLeft(STR0008+AllTrim(cTipoContrato)+": "+EF1->EF1_CONTRA+IIF(lEFFTpMod,space(5)+STR0039+EF1->EF1_SEQCNT,"")+space(6)+STR0028+EF1->EF1_BAN_FI+"-"+POSICIONE("SA6",1,cfilSA6+EF1->EF1_BAN_FI,"A6_NOME")+SPACE(6)+STR0029+DTOC(EF1->EF1_DT_VIN)+SPACE(6)+STR0030+DTOC(EF1->EF1_DT_VEN))    //Contrato de "###"  Sequencia    Banco      Prazo vinculaçao      prazo liquidacao
            Plin()
            @nLin,0 PSAY __PrtFatLine()  
            Plin()
            Plin()         

            @nLin,nCol01 PSAY STR0010+cNomeMoeda+": "+ALLTRIM(TRANS(nVlContrato,cPicture))      //"Valor do Contrato "
            Plin()
            @nLin,nTit01  PSAY cNomeMoeda+"("+ALLTRIM(EF1->EF1_MOEDA)+")"   
            @nLin,nTit02  PSAY STR0011 //"Acumulado Anterior"
            @nLin,nTit03  PSAY STR0012 //"Movimento Periodo "
            @nLin,nTit04  PSAY STR0013 //"Acumulado Atual"
            Plin()
            Plin()         

            @nLin,nCol01 PSAY STR0014 //"Vinculados "
            @nLin,nCol02 PSAY TRANS(nVLVAA,cPicture)
            @nLin,nCol03 PSAY TRANS(nVLVMM,cPicture)
            @nLin,nCol04 PSAY TRANS(nVLVAA+nVLVMM,cPicture)
            Plin()
   
            @nLin,nCol01 PSAY STR0015 //"Estorno Vinculados"
            @nLin,nCol02 PSAY TRANS(nVLEAA,cPicture) 
            @nLin,nCol03 PSAY TRANS(nVLEVMM,cPicture)
            @nLin,nCol04 PSAY TRANS(nVLEAA+nVLEVMM,cPicture)
            Plin()
   
            @nLin,nCol01 PSAY STR0016 //"Liquidacao"
            @nLin,nCol02 PSAY TRANS(nVLLAA,cPicture) 
            @nLin,nCol03 PSAY TRANS(nVLLMM,cPicture)
            @nLin,nCol04 PSAY TRANS(nVLLAA+nVLLMM,cPicture)   
            Plin()
   
            @nLin,nCol01 PSAY STR0017 //"Estorno Liquidacao"
            @nLin,nCol02 PSAY TRANS(nVLESAA,cPicture)
            @nLin,nCol03 PSAY TRANS(nVLELMM,cPicture) 
            @nLin,nCol04 PSAY TRANS(nVLESAA+nVLELMM,cPicture)   
            Plin()
            Plin()   
   
            //** PLB 12/05/06 - Nao imprime saldo a vincular quando for Financiamento de Importacao
            If lEFFTpMod  .And.  EF1->EF1_TPMODU != "I"
               @nLin,nCol01 PSAY STR0018+ALLTRIM(TRANS(nVlContrato-(nVLVAA+nVLVMM)+(nVLEAA+nVLEVMM),cPicture)) //"Saldo a Vincular: "
               Plin()
            EndIf
            //**
            
            @nLin,nCol01 PSAY STR0019+ALLTRIM(TRANS((nVLVAA+nVLVMM)-(nVLEAA+nVLEVMM)-(nVLLMM+nVLLAA)+(nVLESAA+nVLELMM),cPicture)) //"Saldo a Liquidar: " //Alcir Alves - 24-05-05
            Plin()
            Plin()
            //Alcir Alves - 15-02-05
            //EM REAIS
            @nLin,nCol01 PSAY STR0020+ALLTRIM(TRANS(nVlRealCont,cPicture)) //"Valor do Contrato Reais: "
            Plin()
            @nLin,nTit01  PSAY STR0021 //"Real(R$)"
            Plin()
   
            @nLin,nCol01 PSAY STR0014 //"Vinculados "
            @nLin,nCol02 PSAY TRANS(nVLRAA,cPicture)
            @nLin,nCol03 PSAY TRANS(nVLRVMM,cPicture)
            @nLin,nCol04 PSAY TRANS(nVLRAA+nVLRVMM,cPicture)
            Plin()
   
            @nLin,nCol01 PSAY STR0015 //"Estorno Vinculados"
            @nLin,nCol02 PSAY TRANS(nVLREAA,cPicture) 
            @nLin,nCol03 PSAY TRANS(nVLREVMM,cPicture)
            @nLin,nCol04 PSAY TRANS(nVLREAA+nVLREVMM,cPicture)
            Plin()
   
            @nLin,nCol01 PSAY STR0016 //"Liquidacao"
            @nLin,nCol02 PSAY TRANS(nVLRLAA,cPicture) 
            @nLin,nCol03 PSAY TRANS(nVLRLMM,cPicture)
            @nLin,nCol04 PSAY TRANS(nVLRLAA+nVLRLMM,cPicture)   
            Plin()
   
            @nLin,nCol01 PSAY STR0017 //"Estorno Liquidacao"
            @nLin,nCol02 PSAY TRANS(nVLRELAA,cPicture)
            @nLin,nCol03 PSAY TRANS(nVLRELMM,cPicture) 
            @nLin,nCol04 PSAY TRANS(nVLRELAA+nVLRELMM,cPicture)   
            Plin()
   
            @nLin,nCol01 PSAY STR0022 //"Variacao Cambial"
            @nLin,nCol02 PSAY TRANS(nVLRCAMAA,cPicture) 
            @nLin,nCol03 PSAY TRANS(nVLRCAMMM,cPicture) 
            @nLin,nCol04 PSAY TRANS(nVLRCAMAA+nVLRCAMMM,cPicture)   
            Plin()
   
            @nLin,nCol01 PSAY STR0023 //"Estorno Variacao"
            @nLin,nCol02 PSAY TRANS(nVLRVARAA,cPicture) 
            @nLin,nCol03 PSAY TRANS(nVLRVARMM,cPicture) 
            @nLin,nCol04 PSAY TRANS(nVLRVARAA+nVLRVARMM,cPicture)   
            Plin()
            Plin()         
            //  @nLin,nCol01 PSAY STR0018+ALLTRIM(TRANS(nVlRealCont-(nVLRAA+nVLRVMM)-(nVLREAA+nVLREVMM),cPicture))
            //  nLin++
            //  @nLin,nCol01 PSAY STR0019+ALLTRIM(TRANS((nVLRAA+nVLRVMM)+(nVLRCAMAA+nVLRCAMMM)-(nVLREAA+nVLREVMM)-(nVLRLAA+nVLRLMM),cPicture)) //"Saldo a Liquidar: "
         ELSE 
            //caso destino de impressão seja EXCEL OU TEXTO  - ALCIR ALVES - 15-02-05
            //GRAVA WORK PARA GERAÇÃO DO ARQUIVO DE EXPORTAÇÃO
            WORK->(RECLOCK("WORK",.T.))
            WORK->FILIAL:=aFilSel[ni] 
            //** PLB 12/05/06
            If lEFFTpMod
               WORK->TPMODU := EF1->EF1_TPMODU
               WORK->SEQCNT := EF1->EF1_SEQCNT
            EndIf
            //**
            WORK->CONTRATO:=EF1->EF1_CONTRA
            WORK->TIPO_CONTR:=cTipoContrato
            WORK->BANCO_OP:=EF1->EF1_BAN_FI
            IF lExistBCO         
                WORK->PRACA:=EF1->EF1_PRACA
            ENDIF
            WORK->DT_VINC:=EF1->EF1_DT_VIN
            WORK->DT_LIQ:=EF1->EF1_DT_VEN
            WORK->MOEDA:=EF1->EF1_MOEDA
            //VALORES NA MOEDA
            WORK->VINC_MOE1:=nVLVAA
            WORK->EVINC_MOE1:=nVLEAA
            WORK->LIQ_MOE1:=nVLLAA
            WORK->ELIQ_MOE1:=nVLESAA
            WORK->VINC_MOE2:=nVLVMM
            WORK->EVINC_MOE2:=nVLEVMM
            WORK->LIQ_MOE2:=nVLLMM
            WORK->ELIQ_MOE2:=nVLELMM
            WORK->VINC_MOE3:=(nVLVAA+nVLVMM)
            WORK->EVINC_MOE3:=(nVLEAA+nVLEVMM)
            WORK->LIQ_MOE3:=(nVLLAA+nVLLMM)
            WORK->ELIQ_MOE3:=(nVLESAA+nVLELMM)
            WORK->SLD_V_MOE:=(nVlContrato-(nVLVAA+nVLVMM)-(nVLEAA+nVLEVMM))
            WORK->SLD_L_MOE:=((nVLVAA+nVLVMM)-(nVLEAA+nVLEVMM)-nVLLMM+nVLELMM)
            WORK->VL_C_MOE:=nVlContrato
            //VALORES EM REAL
            WORK->VINC_REA:=nVLRAA
            WORK->EVINC_REA1:=nVLREAA
            WORK->LIQ_REA1:=nVLRLAA
            WORK->ELIQ_REA1:=nVLRELAA
            WORK->VINC_REA2:=nVLRVMM
            WORK->EVINC_REA2:=nVLREVMM
            WORK->LIQ_REA2:=nVLRLMM
            WORK->ELIQ_REA2:=nVLRELMM
            WORK->VINC_REA3:=(nVLRAA+nVLRVMM)
            WORK->EVINC_REA3:=(nVLREAA+nVLREVMM)
            WORK->LIQ_REA3:=(nVLRLAA+nVLRLMM)
            WORK->ELIQ_REA3:=(nVLRELAA+nVLRELMM)
            WORK->VC_REA1:=nVLRCAMAA         
            WORK->VC_REA2:=nVLRCAMMM
            WORK->VC_REA3:=(nVLRCAMAA+nVLRCAMMM)
            WORK->EVC_REA1:=nVLRVARAA
            WORK->EVC_REA2:=nVLRVARMM
            WORK->EVC_REA3:=(nVLRVARAA+nVLRVARMM)
            WORK->SLD_V_REA:=(nVlRealCont-(nVLRAA+nVLRVMM)-(nVLREAA+nVLREVMM))
            WORK->SLD_L_REA:=((nVLRAA+nVLRVMM)-(nVLREAA+nVLREVMM)-nVLRLMM+nVLRELMM)
            WORK->VL_C_REA:=nVlRealCont
            WORK->(MSUNLOCK())
            
         ENDIF
         //      
         nTotRAA+=nVLRAA
         nTotRVMM+=nVLRVMM   
         nTotREAA+=nVLREAA
         nTotREVMM+=nVLREVMM   
         nTotRLAA+=nVLRLAA
         nTotRLMM+=nVLRLMM   
         nTotRELAA+=nVLRELAA
         nTotRELMM+=nVLRELMM   
         nTotRCAMAA+=nVLRCAMAA
         nTotRCAMMM+=nVLRCAMMM   
         nTotRVARAA+=nVLRVARAA
         nTotRVARMM+=nVLRVARMM
      EndIf
      
      nIgnora:=.T. //Alcir Alves - 31-05-05
   
         (cAliasArq)->(DBSKIP())
         if !(len(aFilSel)==1 .and. ALLTRIM(aFilSel[1])=="")
            nLin+=03 
         endif
         lPrint:=.T.
      ENDDO

      //** PLB 11/05/06
      If lEFFTpMod
         If lExistRof
            cParSX1:="mv_par16"
         Else
            cParSX1:="mv_par15"
         EndIf
      Else
         If lExistRof
            cParSX1:="mv_par14"
         Else
            cParSX1:="mv_par13"
         EndIf
      EndIf            
      If &(cParSX1) == 1  //caso destino de impressão seja IMPRESSORA
      //**
      //IF iif(lExistRof,mv_par14,mv_par13)==1 //caso destino de impressão seja IMPRESSORA  - ALCIR ALVES - 15-02-05
         IF lPrint
            AADD(aContratos,{"R$",nTotRAA,nTotRVMM,nTotREAA,nTotREVMM,nTotRLAA,nTotRLMM,;
                          nTotRELAA,nTotRELMM,nTotRCAMAA,nTotRCAMMM,nTotRVARAA,nTotRVARMM})
         ENDIF
         if nPrintToT==.T.
            nLin:=99
            FOR nInd:=1 TO LEN(aContratos)
               If nInd == 1
                  If cFilAtu#"-"
                        Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
                        nLin:=08
                        //** PLB 12/05/06
                        If !Empty(AllTrim(cFiltro_s))
                           @nLin,0 PSAY cFiltro_s
                           nLin:=nLin+2
                        EndIf   
                        //**
                  EndIf
                  If !(len(aFilSel)==1 .and. ALLTRIM(aFilSel[1])=="")
                     @nLin,0 PSAY replicate("-",138)
                     nLin++
                     cFilAtu:=aFilSel[ni] 
                     afilial_n:=AvgFilName({cFilAtu})
                     @ nLin,02 PSAY STR0026+" "+cFilAtu+" - "+afilial_n[1]          
                     nLin++
                     @nLin,0 PSAY replicate("-",138)
                     nLin+=2
                  Endif
               Endif

               IF  nLin>nLinTot
                  nLin:=Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
                  //Alcir Alves - 06-06-05
                  nLin++
                  if !empty(alltrim(cFiltro_s))
                    @nLin,0 PSAY cFiltro_s
                    nLin:=nLin+2
                  endif   
                  //
               ENDIF
               SYF->(DBSEEK(cFilSYF+aContratos[nInd,1]))    
               @nLin,0  PSAY __PrtFatLine()
               nLin++
               @nLin,0 PSAY __PrtLeft(STR0024+ALLTRIM(SYF->YF_DESC_SI)+"("+ALLTRIM(aContratos[nInd,1])+")") //"VALOR TOTAL EM "
               nLin++
               @nLin,0 PSAY __PrtFatLine()
               nLin+=2   
   
               @nLin,nTit01  PSAY alltrim(SYF->YF_DESC_SI)+"("+alltrim(aContratos[nInd,1])+")"
               @nLin,nTit02  PSAY STR0011 //"Acumulado Anterior"
               @nLin,nTit03  PSAY STR0012 //"Movimento Periodo "
               @nLin,nTit04  PSAY STR0013    //"Acumulado Atual"
               nLin++
         
               @nLin,nCol01 PSAY STR0014 //"Vinculados "
               @nLin,nCol02 PSAY TRANS(aContratos[nInd,2],cPicture)
               @nLin,nCol03 PSAY TRANS(aContratos[nInd,3],cPicture)
               @nLin,nCol04 PSAY TRANS(aContratos[nInd,2]+aContratos[nInd,3],cPicture)
               nLin++
         
               @nLin,nCol01 PSAY STR0015 //"Estorno Vinculados"
               @nLin,nCol02 PSAY TRANS(aContratos[nInd,4],cPicture) 
               @nLin,nCol03 PSAY TRANS(aContratos[nInd,5],cPicture)
               @nLin,nCol04 PSAY TRANS(aContratos[nInd,4]+aContratos[nInd,5],cPicture)
               nLin++
      
               @nLin,nCol01 PSAY STR0016 //"Liquidacao"
               @nLin,nCol02 PSAY TRANS(aContratos[nInd,6],cPicture) 
               @nLin,nCol03 PSAY TRANS(aContratos[nInd,7],cPicture)
               @nLin,nCol04 PSAY TRANS(aContratos[nInd,6]+aContratos[nInd,7],cPicture)   
               nLin++
   
               @nLin,nCol01 PSAY STR0017 //"Estorno Liquidacao"
               @nLin,nCol02 PSAY TRANS(aContratos[nInd,8],cPicture) 
               @nLin,nCol03 PSAY TRANS(aContratos[nInd,9],cPicture) 
               @nLin,nCol04 PSAY TRANS(aContratos[nInd,8]+aContratos[nInd,9],cPicture)   
               nLin+=2
   
               IF aContratos[nInd,1]=="R$"
                  nLin--
                  @nLin,nCol01 PSAY STR0022 //"Variacao Cambial"
                  @nLin,nCol02 PSAY TRANS(aContratos[nInd,10],cPicture) 
                  @nLin,nCol03 PSAY TRANS(aContratos[nInd,11],cPicture) 
                  @nLin,nCol04 PSAY TRANS(aContratos[nInd,10]+aContratos[nInd,11],cPicture) 
                  nLin++
   
                  @nLin,nCol01 PSAY STR0023 //"Estorno Variacao"
                  @nLin,nCol02 PSAY TRANS(aContratos[nInd,12],cPicture) 
                  @nLin,nCol03 PSAY TRANS(aContratos[nInd,13],cPicture) 
                  @nLin,nCol04 PSAY TRANS(aContratos[nInd,12]+aContratos[nInd,13],cPicture)        
               ENDIF   
            NEXT nInd
         Endif
      ENDIF   
   NEXT ni

   //** PLB 11/05/06
   If lEFFTpMod
      If lExistRof
         cParSX1:="mv_par16"
      Else
         cParSX1:="mv_par15"
      EndIf
   Else
      If lExistRof
         cParSX1:="mv_par14"
      Else
         cParSX1:="mv_par13"
      EndIf
   EndIf            
   If &(cPArSX1) == 1
   //**
   //IF iif(lExistRof,mv_par14,mv_par13)==1 //caso destino de impressão seja IMPRESSORA  - ALCIR ALVES - 15-02-05
      If Len(aGeral) == 0
         aGeral:=aClone(aContratos)
      Else
         For nTi:= 1 To Len(aContratos)
            nPos := aScan(aGeral,{|X| X[1]==aContratos[nTi][1]})
            If nPos > 0
               For nTi2:= 2 To Len(aContratos[nTi])
                  aGeral[nPos][nTi2] += aContratos[nTi][nTi2]
               Next
            Endif
         Next
      Endif
      //** AAF - 12/01/05 - Total Geral de Todas as filiais.
      FOR nInd:=1 TO LEN(aGeral)
         If nInd==1
            Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)
            //Alcir Alves - 06-06-05
            nLin:=8
            if !empty(alltrim(cFiltro_s))
               @nLin,0 PSAY cFiltro_s
               nLin:=10
            endif   
            //
            @nLin++,0 PSAY __PrtThinLine()
            @nLin++,0 PSAY __PrtLeft(STR0027)//"Total Geral"
            @nLin++,0 PSAY __PrtThinLine()
         Endif

         IF nLin>nLinTot
            Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)
            //Alcir Alves - 06-06-05
            nLin:=8
            if !empty(alltrim(cFiltro_s))
               @nLin,0 PSAY cFiltro_s
               nLin:=10
            endif   
            //
         ENDIF
         
         SYF->(DBSEEK(cFilSYF+aGeral[nInd,1]))    
         @nLin,0  PSAY __PrtFatLine()
         nLin++
         @nLin,0 PSAY __PrtLeft(STR0024+ALLTRIM(SYF->YF_DESC_SI)+"("+ALLTRIM(aGeral[nInd,1])+")") //"VALOR TOTAL EM "
         nLin++
         @nLin,0 PSAY __PrtFatLine()
         nLin+=2   
         @nLin,nTit01  PSAY alltrim(SYF->YF_DESC_SI)+"("+alltrim(aGeral[nInd,1])+")"
         @nLin,nTit02  PSAY STR0011 //"Acumulado Anterior"
         @nLin,nTit03  PSAY STR0012 //"Movimento Periodo "
         @nLin,nTit04  PSAY STR0013    //"Acumulado Atual"
         nLin++
    
         @nLin,nCol01 PSAY STR0014 //"Vinculados "
         @nLin,nCol02 PSAY TRANS(aGeral[nInd,2],cPicture)
         @nLin,nCol03 PSAY TRANS(aGeral[nInd,3],cPicture)
         @nLin,nCol04 PSAY TRANS(aGeral[nInd,2]+aGeral[nInd,3],cPicture)
         nLin++
      
         @nLin,nCol01 PSAY STR0015 //"Estorno Vinculados"
         @nLin,nCol02 PSAY TRANS(aGeral[nInd,4],cPicture) 
         @nLin,nCol03 PSAY TRANS(aGeral[nInd,5],cPicture)
         @nLin,nCol04 PSAY TRANS(aGeral[nInd,4]+aGeral[nInd,5],cPicture)
         nLin++
   
         @nLin,nCol01 PSAY STR0016 //"Liquidacao"
         @nLin,nCol02 PSAY TRANS(aGeral[nInd,6],cPicture) 
         @nLin,nCol03 PSAY TRANS(aGeral[nInd,7],cPicture)
         @nLin,nCol04 PSAY TRANS(aGeral[nInd,6]+aGeral[nInd,7],cPicture)   
         nLin++
   
         @nLin,nCol01 PSAY STR0017 //"Estorno Liquidacao"
         @nLin,nCol02 PSAY TRANS(aGeral[nInd,8],cPicture) 
         @nLin,nCol03 PSAY TRANS(aGeral[nInd,9],cPicture) 
         @nLin,nCol04 PSAY TRANS(aGeral[nInd,8]+aGeral[nInd,9],cPicture)   
         nLin+=2
   
         IF aGeral[nInd,1]=="R$"
            nLin--
            @nLin,nCol01 PSAY STR0022 //"Variacao Cambial"
            @nLin,nCol02 PSAY TRANS(aGeral[nInd,10],cPicture) 
            @nLin,nCol03 PSAY TRANS(aGeral[nInd,11],cPicture) 
            @nLin,nCol04 PSAY TRANS(aGeral[nInd,10]+aGeral[nInd,11],cPicture) 
            nLin++
       
            @nLin,nCol01 PSAY STR0023 //"Estorno Variacao"
            @nLin,nCol02 PSAY TRANS(aGeral[nInd,12],cPicture) 
            @nLin,nCol03 PSAY TRANS(aGeral[nInd,13],cPicture) 
            @nLin,nCol04 PSAY TRANS(aGeral[nInd,12]+aGeral[nInd,13],cPicture)        
         ENDIF   
      NEXT nInd
      aGeral := {}  // PLB 12/05/06
      //**
   ENDIF
Next nTpMod

If &(cParSX1) == 1
   If (aReturn[5] = 1 .or. aReturn[5] = 2) .and. lCanPrt
      Set Printer To
      Commit	
      Ourspool(wnrel)
   Else  
      MsgInfo("Nao ha dados para impressao", "Mensagem")
   Endif     
   MS_FLUSH()
ENDIF

//endif

//** PLB 11/05/06
If lEFFTpMod
   If lExistRof
      cParSX1:="mv_par16"
   Else
      cParSX1:="mv_par15"
   EndIf
Else
   If lExistRof
      cParSX1:="mv_par14"
   Else
      cParSX1:="mv_par13"
   EndIf
EndIf            
If &(cPArSX1) == 2  .Or.  &(cParSX1) == 3
//ALCIR ALVES - 15-02-05 - EXPORTAÇÃO PARA EXCEL OU TEXTO
//IF iif(lExistRof,mv_par14,mv_par13)==2 .or. iif(lExistRof,mv_par14,mv_par13)==3 //caso destino de impressão seja texto ou excel
   //WORK_EXPORT(IIF(iif(lExistRof,mv_par14,mv_par13)==2,.F.,.T.))
   WORK_EXPORT(IIF(&(cParSX1)==2,.F.,.T.))
ENDIF

RETURN .T.             

*------------------------*
FUNCTION SA160QUERY(cTipo)
*------------------------*
LOCAL cAliasQuery:=cTipo+"NEW"

If Select(cAliasQuery) <> 0
   (cAliasQuery)->(DbCloseArea())
Endif

IF Left(cTipo,3)=="EF1"
   cQuery:=" SELECT EF1.R_E_C_N_O_ REGISTRO FROM " + RetSQLName("EF1") + " EF1 "
   cQuery+=" WHERE EF1.EF1_FILIAL='"+cFilEF1+"' AND EF1.D_E_L_E_T_<>'*' "
   cQuery+=" AND (EF1.EF1_DT_ENC = ' ' OR  EF1.EF1_DT_ENC = '') "
   If lEFFTpMod
      cQuery+=" AND EF1.EF1_TPMODU = '"+IIF(cTipo=="EF1EXP","E","I")+"' "
   EndIf
   IF !EMPTY(cContrato)
	   cQuery+=" AND EF1.EF1_CONTRA='"+cContrato+"'"
   ENDIF
ENDIF

cQuery:=ChangeQuery(cQuery)
TcQuery cQuery ALIAS (cAliasQuery) NEW

RETURN


*// Função responsavel pela exportação de works para excel ou arquivo de texto
*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 14-01-05 - Alcir Alves  - revisão
*---------------------------------------------------------------------------------------
   
   
   /**JVR** - 27/02/2009
              Condição para adequação a esportação utilizando Ctree*/
   cArqOrigem := WorkFile
   cAlias     := "Work"
   lXml       := .F.   
   
   AvExcel(cArqOrigem,cAlias,lXml)

   /*
   Local oExcelApp
   //Local cDirDocs := MsDocPath()
   Local cPath	:= AllTrim(GetTempPath())
   DbSelectArea("Work")
   if lExcel
         Work->(dbCloseArea())
         CpyS2T(".\"+curdir()+WorkFile+".DBF",cPath, .T. )
         If ! ApOleClient( 'MsExcel' )
            MsgStop("Ms-Excel não instalado.")  
            RETURN .F.
         Else
            oExcelApp:= MsExcel():New()
            oExcelApp:WorkBooks:Open( cPath+WorkFile+".dbf" )
            oExcelApp:SetVisible(.T.)
         EndIf
         MS_FLUSH()
   Else
         TR350ARQUIVO("work")   
         Work->(dbCloseArea())
         MS_FLUSH()
   EndIf
   */
Return .T.

// PLB 31/05/06 - Funcao Antiga de validacao dos perguntes, mantida para uso dos clientes que nao atualizaram o dicionario
*---------------------------*
Function EFFSA160VAL(cCampo)   
*---------------------------*
Local lRet:=.T.
Local lAchou
IF(valtype(cCampo) = "U", cCampo:="",.T.)

If cCampo == "CONTRATO" .OR. Empty(cCampo)
    If !Empty(mv_par01) .And. !ExistCpo("EF1", mv_par01) 
      lRet:=.F.
    EndIf     
ElseIf (cCampo == "EVENTO" .OR. Empty(cCampo))  .AND. !Empty(mv_par05)
  EC6->(DbSetOrder(1))
  If !Empty(mv_par04) 
    If !EC6->(DbSeek(cFILEF1+"FIEX"+mv_par04+mv_par05)) 
       lRet:= .F.
       MsgInfo(STR0031) //"Evento invalido" 
    EndIf      
  Else 
      lAchou := .F.
      SX5->(dbSeek(cFilSX5+"CJ"))
       Do While !SX5->(EOF()) .And. SX5->X5_TABELA == "CJ"                                 
        If EC6->(dbSeek(xfilial("EC6")+SX5->X5_CHAVE+mv_par05))                                    
           lAchou := .T.                                                           
           Exit                                                                    
        EndIf                                                                      
        SX5->(DbSkip())                                                            
      EndDo
      If !lAchou   
       lRet:= .F.
       MsgInfo(STR0032) //"Evento invalido" 
      EndIf                                                                            
  Endif 
  
ElseIf cCampo == "INVOICE" .OR. Empty(cCampo)
   If !Empty(mv_par09) .AND. !eeq->(dbSeek(cFilEEQ+mv_par09+"101"))
       lRet:=.F.
       MsgInfo(STR0033) // "Tipo de invoice inválida"
   EndIf


ElseIf cCampo == "TIPOFIN" .OR. Empty(cCampo)
   If !Empty(mv_par04) .AND. !SX5->(dbSeek(cFilSX5+"CG"+mv_par04))
       lRet:=.F.
       MsgInfo(STR0034) // "Tipo de Finaciamento Invalido"
   EndIf
ElseIf cCampo == "EXPORT" .OR. Empty(cCampo)
   If (!Empty(mv_par06)) .AND. !SA2->(DbSeek(cFilSA2+mv_par06))     //Se exportador foi preenchido no pergunte verifica validade
      MsgInfo(STR0035)// "Exportador ou Loja invalidos"
      lRet:=.F.   
   EndIf
EndIF

RETURN lRet


//** PLB 10/05/06 - Funcao de Validacao dos Perguntes
**-----------------------------------------------------------------------**
Function SA160ValPerg(cPerg,cmvpar)
**-----------------------------------------------------------------------**
 Local lRet := .T.

   Do Case

      Case cPerg == "TpModu"
         If cmvpar != 3  // Ambos
            mv_par02 := if(ValType(mv_par02) == "C", Space(Len(mv_par02)),space(FindSX1(cPergunta,"MV_PAR02")))  // Contrato
            mv_par06 := if(ValType(mv_par06) == "C", Space(Len(mv_par06)),space(FindSX1(cPergunta,"MV_PAR06")))  // Tipo Financiamento
            If lExistROF
               mv_par15 := if(ValType(mv_par15) == "C", Space(Len(mv_par15)),space(FindSX1(cPergunta,"MV_PAR15")))  // R.O.F.
            EndIf
            If cmvpar == 1   // Exportacao
               cFiltroF3Fin := "E"
               cFiltroF3ROF := "E"
            ElseIf cmvpar == 2   // Importacao
               cFiltroF3Fin := "I"
               cFiltroF3ROF := "I"
            Else 
               lRet := .F.
            EndIf
         Else
            cFiltroF3Fin := "E/I"
            cFiltroF3ROF := "E/I"
         EndIf

      Case cPerg == "Contra"
         If lEFFTpMod
            If mv_par01 == 1 // Exportacao
               If !EF1->( DBSeek(xFilial("EF1")+"E"+cmvpar) )
                  If EF1->( DBSeek(xFilial("EF1")+"I"+cmvpar) )
                     MsgStop(STR0040+STR0037+STR0041)  // "Este contrato e de " + "Importacao" + ", selecione o contrato de acordo com o filtro 'Tipo do Modulo'."
                  Else
                     MsgStop(STR0042)  // "Digite um contrato valido."
                  EndIf
                  lRet := .F.
               EndIf
            ElseIf mv_par01 == 2 // Importacao
               If !EF1->( DBSeek(xFilial("EF1")+"I"+cmvpar) )
                  If EF1->( DBSeek(xFilial("EF1")+"E"+cmvpar) )
                     MsgStop(STR0040+STR0036+STR0041)  // "Este contrato e de " + "Exportacao" + ", selecione o contrato de acordo com o filtro 'Tipo do Modulo'."
                  Else
                     MsgStop(STR0042)  // "Digite um contrato valido."
                  EndIf
                  lRet := .F.
               EndIf
            Else
               If !EF1->( DBSeek(xFilial("EF1")+"E"+cmvpar) )  .And.  !EF1->( DBSeek(xFilial("EF1")+"I"+cmvpar) )
                  MsgStop(STR0042)  // "Digite um contrato valido."
                  lRet := .F.
               EndIf
            EndIf
         ElseIf !AvgExistCpo("EF1",cmvpar)
            lRet := .F.
         EndIf

      Case cPerg == "CodEve"
         If !lEFFTpMod
            EC6->(DbSetOrder(1))
            If !AvgExistCpo("EC6","FIEX"+mv_par04+mv_par05)
               lRet:= .F.
            EndIf 
         EndIf

      Case cPerg == "TipFin"
         If lCadFin
            If !AvgExistCpo("EF7",cmvpar)
               lRet := .F.
            EndIf
         ElseIf !AvgExistCpo("SX5","CG"+cmvpar)
            lRet := .F.
         EndIf

      Case cPerg == "Invoice"
         If !lEFFTpMod
            If !AvgExistCpo("EEQ",cmvpar+"101")
               lRet:=.F.
            EndIf
         EndIf

      Case cPerg == "ROF"
         If lEFFTpMod  .And.  lCadFin  .And.  !AvgExistCpo("EF9",cmvpar)
            lRet := .F.
         EndIf

   End Case

Return lRet
//**

static function Plin()
         nLin++
         IF nLin>nLinTot
           Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)
            //Alcir Alves - 06-06-05
            nLin:=8
            if !empty(alltrim(cFiltro_s))
               @nLin,0 PSAY cFiltro_s
               nLin:=10
             endif   
            //
         ENDIF
return .f.

Static Function FindSX1(cPerg,cMV_PAR)
   Local aOrd := SaveOrd("SX1")
   Local nTam := 0
    
   SX1->(dbSetOrder(1))
   SX1->(dbSeek(cPerg))
   
   While alltrim(SX1->X1_GRUPO) == alltrim(cPerg)
      If UPPER(alltrim(SX1->X1_VAR01)) == UPPER(alltrim(cMV_PAR))
         nTam := SX1->X1_TAMANHO
         Exit
      EndIf   
      SX1->(dbSkip())
   EndDo
   
   If nTam ==  0
      nTam := 20
   EndIf        
   
   RestOrd(aOrd,.T.)
return nTam
