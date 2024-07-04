#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    timoteo.bega
@since     01/05/2017
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruB8Q := FWFormStruct( 1, 'B8Q', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel
	
oModel := MPFormModel():New( 'MODELB8Q' )
oModel:AddFields( 'MODEL_B8Q',,oStruB8Q )	
oModel:SetDescription( "Monitoramento Guias TISS" )
oModel:GetModel( 'MODEL_B8Q' ):SetDescription( ".:: Monitoramento Vlr. Preestabelecido ::." ) 
oModel:SetPrimaryKey( { "B8Q_FILIAL","B8Q_SUSEP","B8Q_CMPLOT","B8Q_NUMLOT","B8Q_IDEPRE","B8Q_CPFCNP","B8O_IDCOPR" } )

return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    timoteo.bega
@since     01/05/2011
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FWLoadModel( 'PLSM270B8Q' )
	
oView := FWFormView():New()
oView:SetModel( oModel )

return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270B8Q
Gravacao da tabela B8Q - CONTRATO PREESTABELECIDO MONIT

@author    timoteo.bega
@since     01/05/2011
/*/
//------------------------------------------------------------------------------------------
Function PLSM270B8Q(cAliSql,cSusep,cCmpLot,cNumLot)
Local cChave := ""
Local cIdePre := ""
Local cCpfCnp := ""
Local cIDCOPR := ""
Local aCampos := {}
Local lRet	:= .F.
Local cSqlBGQ := ""
Default cAliSql := ""
Default cSusep := ""
Default cCmpLot := ""
Default cNumLot := ""

If !Empty(cSusep)
	cIdePre := Iif(Len(AllTrim((cAliSql)->BAU_CPFCGC))==14,"1","2")
	cCpfCnp := (cAliSql)->BAU_CPFCGC
	cIDCOPR := (cAliSql)->B8O_IDCOPR
//	nVLRCON := (cAliSql)->B8O_VLRCON
	cCDMNPR := ""
	cCNES := (cAliSql)->BAU_CNES
	cRGOPIN := ""
	cTPRGMN := ""
EndIf

//B8Q_FILIAL+B8Q_SUSEP+B8Q_CMPLOT+B8Q_NUMLOT+B8Q_IDEPRE+B8Q_CPFCNP+B8Q_IDCOPR
cChave := xFilial('B8O')+cSusep+cCmpLot+cNumLot+cIdePre+cCpfCnp+cIDCOPR

cSqlBGQ += " Select SUM(BGQ_VALOR) VALOR from " + RetSqlName("BGQ") + " BGQ "
cSqlBGQ += " where "
cSqlBGQ += " BGQ.BGQ_FILIAL = '" + xfilial("BGQ") + "' AND "
cSqlBGQ += " BGQ.BGQ_CODIGO = '" + (cAliSql)->BAU_CODIGO + "' AND "
cSqlBGQ += " BGQ.BGQ_IDCOPR = '" + (cAliSql)->B8O_IDCOPR + "' AND "
cSqlBGQ += " BGQ.BGQ_ANO = '" + substr(cCmpLot,1,4) + "' AND "
cSqlBGQ += " BGQ.BGQ_MES = '" + substr(cCmpLot,5,2) + "' AND "
cSqlBGQ += " BGQ.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBGQ),"PLBGQB8Q",.F.,.T.)
if !(PLBGQB8Q->(eoF()))
	nVLRCON := PLBGQB8Q->VALOR
endif
PLBGQB8Q->(dbcloseArea())

if nVLRCON > 0
	If !B8Q->( dbSeek( cChave ) )//Inclusao

		aAdd( aCampos,{ "B8Q_FILIAL",		xFilial( "B8Q" )	} )	// Filial
		aAdd( aCampos,{ "B8Q_SUSEP",		cSusep				} )	// Operadora
		aadd( aCampos,{ "B8Q_CMPLOT",		cCmpLot 				} )	// Competencia lote
		aadd( aCampos,{ "B8Q_NUMLOT",		cNumLot 				} )	// Numero de lote
		aAdd( aCampos,{ "B8Q_IDEPRE",		cIdePre				} )	// identificacao do prestador
		aAdd( aCampos,{ "B8Q_CPFCNP",		cCpfCnp				} )	// cpf / cnpf
		aAdd( aCampos,{ "B8Q_IDCOPR",		cIDCOPR				} )	// numero do contrato
		aAdd( aCampos,{ "B8Q_VLRCON",		nVLRCON				} )	// valor do contrato
		aAdd( aCampos,{ "B8Q_CDMNPR",		cCDMNPR				} )	// codigo do municipio
		aAdd( aCampos,{ "B8Q_CNES",		cCNES					} )	// cnes
		aAdd( aCampos,{ "B8Q_RGOPIN",		cRGOPIN				} )	// numero do registro da operadora intermediaria
		aAdd( aCampos,{ "B8Q_TPRGMN",		cTPRGMN				} )	// tipo de registro
		aAdd( aCampos,{ "B8Q_STATUS",		'1'					} )	// status
		
		lRet := gravaMonit( 3,aCampos,'MODEL_B8Q','PLSM270B8Q' )

	Else

		aAdd( aCampos,{ "B8Q_VLRCON",		nVLRCON				} )	// valor do contrato
		aAdd( aCampos,{ "B8Q_CDMNPR",		cCDMNPR				} )	// codigo do municipio
		aAdd( aCampos,{ "B8Q_CNES",		cCNES					} )	// cnes
		aAdd( aCampos,{ "B8Q_RGOPIN",		cRGOPIN				} )	// numero do registro da operadora intermediaria
		aAdd( aCampos,{ "B8Q_TPRGMN",		cTPRGMN				} )	// tipo de registro
		
		lRet := gravaMonit( 4,aCampos,'MODEL_B8Q','PLSM270B8Q' )

	EndIf 
endif

Return lRet
