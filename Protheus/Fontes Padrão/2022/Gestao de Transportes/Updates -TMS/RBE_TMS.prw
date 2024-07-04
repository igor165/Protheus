#Include "Protheus.ch"

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RB_TMS
@autor		: Fabio Marchiori Sampaio
@descricao	: Atualização De Dicionários Para UpdDistr
@since		: Dez./2017
@using		: UpdDistr Para TMS
@review	:
@param		: 	cVersion 	: Versão do Protheus, Ex. ‘12’
				cMode 		: Modo de execução. ‘1’=Por grupo de empresas / ‘2’=Por grupo de empresas + filial (filial completa)
				cRelStart	: Release de partida. Ex: ‘002’ ( Este seria o Release no qual o cliente está)
				cRelFinish	: Release de chegada. Ex: ‘005’ ( Este seria o Release ao final da atualização)
				cLocaliz	: Localização (país). Ex: ‘BRA’
/*/
//---------------------------------------------------------------------------------------------------

Function RBE_TMS( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

Local nCount			:= 0
Local aTabelas 			:= {}
	
Default cVersion		:= ''
Default cMode			:= '1'
Default cRelStart		:= "007"
Default cRelFinish		:= ''
Default cLocaliz		:= ''

#IFDEF TOP
	If SuperGetMV("MV_INTTMS",, .F.)
		TmsLogMsg(,'Inicio RBE_TMS: ' + Time())
			
		aadd(aTabelas, {"DT2", "DT2_FILIAL || DT2_CODOCO "})
		aadd(aTabelas, {"DT3", "DT3_FILIAL || DT3_CODPAS "})
		aadd(aTabelas, {"DT7", "DT7_FILIAL || DT7_CODDES "})
		aadd(aTabelas, {"DUY", "DUY_FILIAL || DUY_GRPVEN "})
		aadd(aTabelas, {"DUI", "DUI_FILIAL || DUI_DOCTMS "})
		aadd(aTabelas, {"DTN", "DTN_FILIAL || DTN_GRPVEN || DTN_ITEM "})
		aadd(aTabelas, {"DUF", "DUF_FILIAL || DUF_REGTRI || DUF_TIPFRE "})
		aadd(aTabelas, {"DUO", "DUO_FILIAL || DUO_CODCLI || DUO_LOJCLI "})
		aadd(aTabelas, {"DV1", "DV1_FILIAL || DV1_CODCLI || DV1_LOJCLI || DV1_DOCTMS || DV1_CODPRO || DV1_TIPNFC || DV1_TIPCLI || DV1_SEQINS "})
		
			//-- Executa Uma Vez Por Empresa
		If cMode == "1"
			//-- Release Maior Ou Igual a '007'
			If cRelStart >= "007"
		
				For nCount := 1 To Len(aTabelas)
					If TCCanOpen(RetSqlName(aTabelas[nCount][1]))
						ExecQry(aTabelas[nCount][1], aTabelas[nCount][2] )
					EndIf				
				Next nCount 
			EndIf
		EndIf
	
		TmsLogMsg(,'Fim RBE_TMS: ' + Time())
	EndIf
#ENDIF
	
Return NIL

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RB_TMS
@autor		: Fabio Marchiori Sampaio
@descricao	: Atualização De Dicionários Para UpdDistr
@since		: Dez./2017
@using		: UpdDistr Para TMS
@review	:
@param		: 	cVersion 	: Versão do Protheus, Ex. ‘12’
				cMode 		: Modo de execução. ‘1’=Por grupo de empresas / ‘2’=Por grupo de empresas + filial (filial completa)
				cRelStart	: Release de partida. Ex: ‘002’ ( Este seria o Release no qual o cliente está)
				cRelFinish	: Release de chegada. Ex: ‘005’ ( Este seria o Release ao final da atualização)
				cLocaliz	: Localização (país). Ex: ‘BRA’
/*/
//---------------------------------------------------------------------------------------------------

Static Function ExecQry(cTab, cCampos)

Local cAliasQry	:= ""
Local lContinua	:= .T.		
Local cQryUpd		:=	""	
#IFDEF TOP
	cAliasQry:= GetNextAlias()
	cQuery := " SELECT COUNT(*) NREG "
	cQuery += " FROM " + RetSqlName(cTab) "
	cQuery += " WHERE "
	cQuery +=      cCampos  + " IN "
	cQuery += "       ( "
	cQuery += "            SELECT " + cCampos 
	cQuery += "             FROM "  + RetSqlName(cTab) "
	cQuery += " 	     			Where D_E_L_E_T_ = ' ' "
	cQuery += "                  GROUP BY " + StrTran( cCampos, "||", ", " )
	cQuery += "                          HAVING COUNT " 
	cQuery += "                          ( "
	cQuery += 									 cTab + "_FILIAL"
	cQuery += "                          ) > 1 "
	cQuery += "                 ) "
	cQuery += "         AND D_E_L_E_T_ <> '*' "   
	
	cQuery := ChangeQuery(cQuery)
	
	While lContinua
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		lContinua := (cAliasQry)->(!Eof()) .And. (cAliasQry)->NREG > 0
		If lContinua 
			cQryUpd := " UPDATE " + RetSqlName(cTab) "
			cQryUpd += "   SET D_E_L_E_T_ = '*'
			cQryUpd += "     WHERE R_E_C_N_O_ IN " 
			cQryUpd += "    ( SELECT Max(R_E_C_N_O_) " 
			cQryUpd += " 		 FROM "  + RetSqlName(cTab) "
			cQryUpd += " 			Where  D_E_L_E_T_ <> '*'
			cQryUpd += "             GROUP BY " + StrTran( cCampos, "||", ", " ) 
			cQryUpd += "                HAVING COUNT 
			cQryUpd += "                ( 
			cQryUpd +=                   + cTab + "_FILIAL"  
			cQryUpd += "                 ) > 1 " 
			cQryUpd += "    )"       
			cQryUpd += "    AND D_E_L_E_T_ <> '*' "   
	
			If TcSqlExec(cQryUpd) <> 0
				lContinua := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndDo
#ENDIF

Return()
