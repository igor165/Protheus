#INCLUDE "AGRA500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================================================
/*****  Funções relacionadas a confirmaçao de romaneios de entrada - Romaneios  *****/
//===================================================================================


/*/{Protheus.doc} AX500LCfEn
Função de confirmação dos romaneios de entrada - 3|5|7|9
@author silvana.torres
@since 21/05/2018
@version undefined
@param lAlgodao, logical, descricao
@type function
/*/
Function AX500LCfEn(lAlgodao)

	Local lRet		:= .T.
	Local aRetorno 	:= {}

	If .NOT. Empty(NJJ->NJJ_CODCTR) .AND. NJJ->NJJ_PESO3 > 0 			.AND. .NOT. Empty(NJJ->NJJ_CODPRO) .AND. ;
       .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)	.AND. .NOT. Empty(NJJ->NJJ_CODENT) .AND. ;
       .NOT. Empty(NJJ->NJJ_LOJENT) .AND. .NOT. Empty(NJJ->NJJ_CODSAF)	.AND. .NOT. Empty(NJJ->NJJ_TES)    
	       
       	//--Verifica qual a nota de entrada foi gerada e realiza a atualização dos documentos fiscais
		aRetorno := A500NFENT(NJJ->NJJ_CODROM, NJJ->NJJ_CODSAF, NJJ->NJJ_CODCTR)
								
		If Reclock("NJJ",.F.)
			NJJ->NJJ_DOCSER := aRetorno[1][1]
			NJJ->NJJ_DOCNUM := aRetorno[1][2]
			NJJ->NJJ_DOCEMI := STOD( aRetorno[1][3] )
			NJJ->NJJ_DOCESP := aRetorno[1][5]
			NJJ->NJJ_STAFIS := "2"
			NJJ->(MsUnLock()) 
		EndIf

		If Reclock("NJM",.F.)
			NJM->NJM_DOCSER := aRetorno[1][1]
			NJM->NJM_DOCNUM := aRetorno[1][2]
			NJM->NJM_DOCEMI := STOD( aRetorno[1][3] )
			NJM->NJM_DOCESP := aRetorno[1][5]
			NJM->NJM_CHVNFE := aRetorno[1][6]
			NJM->NJM_STAFIS := "2"
			NJM->NJM_DTRANS := dDatabase
			NJM->(MsUnLock()) 		
		EndIf
	EndIf
	
	If lRet .AND. lAlgodao
		If !(Empty(NJJ->NJJ_PSLIQU)) .AND. IsInCallStack('AGRA500') 
			//Atualiza status dos fardões vinculados e rateia o peso liquido nos fardões.
			lRet := AGRX500DXL(NJJ->NJJ_PSLIQU)
		EndIf
	EndIf
		
Return lRet