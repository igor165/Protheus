#INCLUDE "loca008.ch" 
/*/{PROTHEUS.DOC} LOCA008.PRW
ITUP BUSINESS - TOTVS RENTAL
VALIDAR SE O CONJUNTO TRANSPORTADOR PODE SER EXCLU�DO E EXCLUIR O ROMANEIO CASO HOUVER
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

FUNCTION LOCA008()
LOCAL CFILORI := PARAMIXB[1]
LOCAL CPROJET := PARAMIXB[2]
LOCAL COBRA   := PARAMIXB[3]
LOCAL CAS     := PARAMIXB[4]
LOCAL CVIAGEM := PARAMIXB[5]
LOCAL LRET    := .T.
LOCAL LEXCLUI := .T.

IF LRET 
	FQ2->(DBSETORDER(2))
	IF FQ2->(DBSEEK(CFILORI + CPROJET + COBRA + CAS + CVIAGEM))
	   FQ3->(DBSETORDER(2))
	   IF FQ3->(DBSEEK(FQ2->FQ2_FILIAL + FQ2->FQ2_ASF + FQ2->FQ2_NUM))
          MSGALERT(STR0001,STR0002)  //"N�O SER� POSS�VEL EXCLUIR O CONJUNTO TRANSPORTADOR, POIS O ROMANEIO VINCULADO A ELA POSSU� ITEM(NS) VINCULADO(S)."###"GPO - EXCONJROM.PRW"
          LRET := .F. 					// N�O PODE DELETAR, POIS TEM ITEM VINCULADO NO ROMANEIO
	   ELSE
		  // --> P.E PARA INCLUIR MAIS VALIDA��ES ANTES DE EXCLUIR CONJ./ROMANEIO.
		  IF EXISTBLOCK("EXCONJRO_")
		  	 LEXCLUI := EXECBLOCK("EXCONJRO_" , .T. , .T. , {CFILORI,CPROJET,COBRA,CAS,CVIAGEM}) 
		  	 LRET    := LEXCLUI 
	      ENDIF
	      IF LEXCLUI					
		     AC9->(DBSETORDER(2)) 		// AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ 
		     IF AC9->(DBSEEK(XFILIAL("AC9") + "FQ2" + FQ2->FQ2_FILIAL + FQ2->FQ2_NUM))
		        WHILE AC9->(!EOF()) .AND. SUBSTR(AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT),1,20) == XFILIAL("AC9")+"FQ2"+FQ2->(FQ2_FILIAL+FQ2_NUM)
		           AC9->(RECLOCK("AC9",.F.)) 
		           AC9->(DBDELETE())
		           AC9->(MSUNLOCK())
		           AC9->(DBSKIP())
		        ENDDO							      
		     ENDIF	         
	         FQ2->(RECLOCK("FQ2",.F.)) 
	         FQ2->(DBDELETE())
	         FQ2->(MSUNLOCK())   
	      ENDIF   
	   ENDIF
	ENDIF
ENDIF
		
RETURN LRET
