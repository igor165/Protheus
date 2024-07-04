#INCLUDE "AGRA500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================================================
/*****  Funções relacionadas a confirmaçao de romaneios de saída - Romaneios  *****/
//===================================================================================


/*/{Protheus.doc} AX500MCfSa
Função de confirmação dos romaneios de saída - 2|4|6|8
@author silvana.torres
@since 21/05/2018
@version undefined
@param lAlgodao, logical, descricao
@type function
/*/
Function AX500MCfSa(lAlgodao)

	Local lRet		:= .T.
	Local aRetorno 	:= {}

	//--Valida campos necessarios de preenchimento
	If .NOT. Empty(NJJ->NJJ_CODCTR)	.AND. .NOT. Empty(NJJ->NJJ_CODPRO) .AND. ;
       .NOT. Empty(NJJ->NJJ_LOCAL)	.AND. .NOT. Empty(NJJ->NJJ_CODENT) .AND. ;
       .NOT. Empty(NJJ->NJJ_LOJENT) .AND. .NOT. Empty(NJJ->NJJ_CODSAF) .AND. ;
       .NOT. Empty(NJJ->NJJ_TES)    .AND. NJJ->NJJ_PSLIQU > 0   
		
		If lRet
			//--Tabela Auxiliar do Agro - Cabeçalho da Nota Fiscal de Saída
			DbSelectArea( "N8J" )
			N8J->( dbSetOrder( 2 ) )	//N8J_FILIAL+N8J_CODROM
			If N8J->( MsSeek( FWxFilial( "N8J" ) + NJJ->NJJ_CODROM ) )									
			
				//--Verifica qual a nota de saída foi gerada e realiza a atualização dos documentos fiscais
				aRetorno := A500NFSAI(NJJ->NJJ_CODROM, N8J->N8J_DOC, N8J->N8J_SERIE)
								
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
					NJM->NJM_PEDIDO := Posicione("SD2",3,FWxFilial("SD2")+aRetorno[1][2]+aRetorno[1][1],"D2_PEDIDO") //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
					NJM->NJM_STAFIS := "2"
					NJM->NJM_DTRANS := dDatabase
					NJM->(MsUnLock()) 
				EndIf
				
			EndIf	//FIM - If N8J->( MsSeek
			N8J->( DbCloseArea())
		EndIf 	//--FIM - lRet 
	EndIf	//FIM - Valida campos necessarios de preenchimento
	
	If lRet .AND. lAlgodao
		If !(Empty(NJJ->NJJ_PSLIQU)) .AND. IsInCallStack('AGRA500')
			//Atualiza status dos fardões vinculados e do rateia o peso liquido nos fardões.
			lRet := AGRX500DXL(NJJ->NJJ_PSLIQU)
		EndIf
	EndIf
		
Return lRet