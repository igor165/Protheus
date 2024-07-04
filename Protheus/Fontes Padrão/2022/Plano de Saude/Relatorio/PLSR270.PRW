// #########################################################################################
// Projeto: Monitoramento
// Modulo : SIGAPLS
// Fonte  : PLSR270
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 22/08/16 | Jonatas Almeida	| Relatorio Monitoramento
// ---------+-------------------+-----------------------------------------------------------

#include "protheus.ch"
static objCENFUNLGP := CENFUNLGP():New()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSR270
Relatorio Monitoramento

@author    Jonatas Almeida
@version   1.xx
@since     22/08/2016
/*/
//------------------------------------------------------------------------------------------
function PLSR270()
	local oReport

	//-- LGPD ----------
	if !objCENFUNLGP:getPermPessoais()
		objCENFUNLGP:msgNoPermissions()
		Return
	Endif
	//------------------

	if( findFunction( "TRepInUse" ) .And. TRepInUse() )
		//--< Interface de impressao >--
		oReport := reportDef()
	
		if( valType(oReport) <> "O" )
			return NIL
		endIf
	
		oReport:PrintDialog()
	endIf
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} reportDef
Definicao das sections para impressao do relatorio

@author    Jonatas Almeida
@version   1.xx
@since     22/08/2016
/*/
//------------------------------------------------------------------------------------------
static function reportDef()
	local oReport, oGuia, oProc, oGuiCri
	
	oReport := TReport():New( "PLSR270","Relatório de Monitoramento","PLSR270",{ | oReport | reportPrint( oReport,oProc,oGuia,oGuiCri ) },"Descrição - Relatório de Monitoramento" )
	oReport:SetLandscape()
	
	pergunte( "PLSR270",.T. )
	
	//--< section 01 - Guias >--
	oGuia := TRSection():New( oReport,"Guias",{ "TRB" },{ "Padrao" },/*Campos do SX3*/,/*Campos do SIX*/) //
	oGuia:SetTotalInLine( .F. )
	TRCell():New( oGuia,"NGUIAOPE"	,"B4N","N.Guia Ope.",			PesqPict( "B4N","B4N_NMGOPE" )	,tamSX3( "B4N_NMGOPE" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oGuia,"NGUIAPRE"	,"B4N","N.Guia Pre.",			PesqPict( "B4N","B4N_NMGPRE" )	,tamSX3( "B4N_NMGPRE" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oGuia,"REEMBOLSO"	,"B4N","Reembolso?",			/*Picture*/	,015,/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oGuia,"DTPROC"	,"B4N","Data Processamento",	/*Picture*/	,010,/*lPixel*/,/*{|| code-block de impressao }*/ )
	
	//--< section 02 - Procedimentos >--	
	oProc := TRSection():New( oReport,"Erros",{ "TRB" },{ "Padrao" },/*Campos do SX3*/,/*Campos do SIX*/) //
	oProc:SetTotalInLine( .F. )
	TRCell():New( oProc,"NGUIAOPE2"	,"B4O","N.Guia Ope.",			PesqPict( "B4O","B4O_NMGOPE" )	,30,/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oProc,"CODTABELA"	,"B4O","Cod. Tabela",			PesqPict( "B4O","B4O_CODTAB" )	,tamSX3( "B4O_CODTAB" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oProc,"GRPPROC"	,"B4O","Grupo Procedimento",	PesqPict( "B4O","B4O_CODGRU" )	,tamSX3( "B4O_CODGRU" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oProc,"CODPROC"	,"B4O","Cód. Proc.",			PesqPict( "B4O","B4O_CODPRO" )	,tamSX3( "B4O_CODPRO" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oProc,"DESPROC"	,"B4O","Descr. Proc.",			/*Picture*/	,100,/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oProc,"CODERROP"	,"B4O","Codigo Erro",			PesqPict( "B4P","B4P_CDCMER" )	,tamSX3( "B4P_CDCMER" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oProc,"DESERROP"	,"B4O","Descrição Erro",		/*Picture*/	,100,/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oProc,"CAMPO"		,"B4P","Campo",					PesqPict( "B4P","B4P_CDCMGU" )	,tamSX3( "B4P_CDCMGU" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )

	//--< section 03 - Erro Guia >--	
	oGuiCri := TRSection():New( oReport,"Erros Guia",{ "TRB" },{ "Padrao" },/*Campos do SX3*/,/*Campos do SIX*/) //
	oGuiCri:SetTotalInLine( .F. )
	TRCell():New( oGuiCri,"NGUIAOPE3"	,"B4P","N.Guia Ope.",		PesqPict( "B4P","B4P_NMGOPE" )	,30,/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oGuiCri,"CDCMER"		,"B4P","Codigo Erro",			PesqPict( "B4P","B4P_CDCMER" )	,tamSX3( "B4P_CDCMER" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oGuiCri,"DESERR"		,"B4P","Descrição Erro",		PesqPict( "B4P","B4P_DESERR" )	,tamSX3( "B4P_DESERR" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )
	TRCell():New( oGuiCri,"CAMPO"		,"B4P","Campo",					PesqPict( "B4P","B4P_CDCMGU" )	,tamSX3( "B4P_CDCMGU" )[ 1 ],/*lPixel*/,/*{|| code-block de impressao }*/ )
return( oReport )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} reportPrint
Impressao do relatorio de monitoramento 

@author    Jonatas Almeida
@version   1.xx
@since     22/08/2016
/*/ 
//------------------------------------------------------------------------------------------
static function reportPrint( oReport,oProc,oGuia,oGuiCri )
	local cSUSEP	:= ""
	local cIN		:= ""
	local cDadosCGC	:= ""
	local cCNPJCGC	:= ""
	local cCNES		:= ""
	local cRZSocial	:= ""
	
	local cNGUIAOPE	:= ""
	local cNGUIAPRE	:= ""
	local cREEMBOLS	:= ""
	local cDTPROC	:= dToC( dDataBase )
	
	local cAlias	:= getNextAlias()
	local cWhere	:= ""
	
	local cTipRel	:= ""
	local cCodRDA	:= ""
	
	BAU->( dbSetOrder( 1 ) )
	BA0->( dbSetOrder( 1 ) )
	if( BA0->( dbSeek( xFilial( "BA0" ) + allTrim( mv_par01 ) ) ) )
		cSUSEP := BA0->BA0_SUSEP
	endIf
	
	cWhere	:= "%B4M.B4M_SUSEP = '"+ allTrim( cSUSEP ) + "' AND "
	cWhere	+= "B4M.B4M_CMPLOT = '"+ allTrim( mv_par03 ) + allTrim( mv_par02 ) +"' AND "
	cWhere	+= "B4M.B4M_NUMLOT BETWEEN '"+ allTrim( mv_par04 ) +"' AND '"+ allTrim( mv_par05 ) +"'%"

	oGuia:Cell( "NGUIAOPE"	):SetBlock( { || cNGUIAOPE } )
	oGuia:Cell( "NGUIAPRE"	):SetBlock( { || cNGUIAPRE } )
	oGuia:Cell( "REEMBOLSO"	):SetBlock( { || cREEMBOLS } )
	oGuia:Cell( "DTPROC"	):SetBlock( { || cDTPROC } )
	
	makeSQLExpr( oReport:uParam )
	
	if( MV_PAR06 == 1 )	//1-Todos as Guias
		beginSQL Alias cAlias
			SELECT B4N_SUSEP,B4N_CMPLOT,B4N_NUMLOT,B4N_NMGOPE,B4N_NMGPRE,B4N_CNES,B4N_IDEREE,B4N_DPPRGU,B4N_CODRDA
			FROM
				%table:B4M% B4M INNER JOIN
				%table:B4N% B4N ON
					B4N.B4N_FILIAL	= B4M.B4M_FILIAL AND
					B4N.B4N_SUSEP	= B4M.B4M_SUSEP AND
					B4N.B4N_CMPLOT	= B4M.B4M_CMPLOT AND
					B4N.B4N_NUMLOT	= B4M.B4M_NUMLOT AND
					B4N.%notDel%
			WHERE
				B4M.B4M_FILIAL = %xFilial:B4M% AND
				%exp:cWhere% AND
				B4M.%notDel%
			ORDER BY %Order:B4N,1%
		endSQL
	else
		if( MV_PAR06 == 2 )	//2-Guias com criticas | 3-Guias sem criticas
			cIn := "%IN%"
		else
			cIn := "%NOT IN%"
		endIf
		
		if( MV_PAR08 == 1 )	// 1-Sistema | 2-Retorno | 3-Qualidade
			cTipRel := "%'1'%"
		elseIf( MV_PAR08 == 2 )
			cTipRel := "%'2'%"
		else
			cTipRel := "%'3'%"
		endIf
	
		beginSQL Alias cAlias
			SELECT B4N_SUSEP,B4N_CMPLOT,B4N_NUMLOT,B4N_NMGOPE,B4N_NMGPRE,B4N_CNES,B4N_IDEREE,B4N_DPPRGU,B4N_CODRDA
			FROM
				%table:B4M% B4M INNER JOIN
				%table:B4N% B4N ON
					B4N.B4N_FILIAL	= B4M.B4M_FILIAL AND
					B4N.B4N_SUSEP	= B4M.B4M_SUSEP AND
					B4N.B4N_CMPLOT	= B4M.B4M_CMPLOT AND
					B4N.B4N_NUMLOT	= B4M.B4M_NUMLOT AND
					B4N.%notDel%
			WHERE
				B4M.B4M_FILIAL = %xFilial:B4M% AND
				%exp:cWhere% AND
				B4N.B4N_FILIAL || B4N.B4N_SUSEP || B4N.B4N_CMPLOT || B4N.B4N_NUMLOT || B4N.B4N_NMGOPE %exp:cIN%(
					SELECT
					B4P.B4P_FILIAL || B4P.B4P_SUSEP || B4P.B4P_CMPLOT || B4P.B4P_NUMLOT || B4P.B4P_NMGOPE
					FROM %table:B4P% B4P WHERE 
					B4P.B4P_FILIAL = B4N.B4N_FILIAL AND
					B4P.B4P_SUSEP  = B4N.B4N_SUSEP  AND
					B4P.B4P_CMPLOT = B4N.B4N_CMPLOT AND
					B4P.B4P_NUMLOT = B4N.B4N_NUMLOT AND
					B4P.B4P_NMGOPE = B4N.B4N_NMGOPE AND
					B4P.%notDel% )
				AND B4M.%notDel%
			ORDER BY %Order:B4N,1%
		endSQL

	endIf

	( cAlias )->( dbgoTop() )
	
	if( ( cAlias )->( !eof() ) )
		while( ( cAlias )->( !eof() ) .and. !oReport:Cancel() )
			if( oReport:Cancel() )
				alert( 'Processo cancelado pelo usuário' )
				exit
			endIf
			
			cNGUIAOPE	:= allTrim( ( cAlias )->( B4N_NMGOPE ) )
			cNGUIAPRE	:= allTrim( ( cAlias )->( B4N_NMGPRE ) )
			cCNES		:= allTrim( ( cAlias )->( B4N_CNES ) )
			cCodRDA		:= allTrim( ( cAlias )->( B4N_CODRDA ) )

			if( !empty( cCodRDA ) )
				BAU->( dbSeek( xFilial( "BAU" ) + cCodRDA ) )
				cCNPJCGC	:= BAU->BAU_CPFCGC
				cRZSocial	:= BAU->BAU_NOME
			else
				cCNPJCGC	:= ""
				cRZSocial	:= ""
			endIf*/

			cDadosCGC := "CNPJ/CPF: " + cCNPJCGC + space( 05 ) +;
				"CNES: " + cCNES + space( 05 ) +;
				"Nome / Razão Social: " + cRZSocial + space( 05 ) +;
				"Cod. RDA: " +  cCodRDA
							
			//--< Impressao dos DADOS CGC >--
			oReport:PrintText( cDadosCGC,oReport:Row(),010 )
			oReport:SkipLine( 1 )
			oReport:ThinLine()
			
			//--< Impressao das GUIAS >--
			oReport:Section( 1 ):Init()
			oGuia:Init()
							
			while( cNGUIAOPE == allTrim( ( cAlias )->( B4N_NMGOPE ) ) .and. cCodRDA	== allTrim( ( cAlias )->( B4N_CODRDA ) ) )
				cREEMBOLS	:= iif( allTrim( ( cAlias )->( B4N_IDEREE ) ) == "00000000000000000000","Nao","Sim" )
				cDTPROC		:= iif( !empty( ( cAlias )->( B4N_DPPRGU ) ),dToC( sToD( ( cAlias )->( B4N_DPPRGU ) ) ),dToC( dDataBase ) )

				oGuia:PrintLine()

				oReport:SkipLine( 1 )
				oReport:ThinLine()
				
				//--< Impressao dos ERROS MONITORAMENTO >---
				impErroGuia( cAlias,oReport,oGuiCri )
				
				//--< Impressao dos PROCEDIMENTOS >--
				impProced( cAlias,oReport,oProc )
				
				( cAlias )->( dbSkip() )
			endDo

			oReport:endPage()
			oReport:IncMeter()
			
			oGuia:Finish()
			oReport:Section( 1 ):Finish()
		endDo
	else
		alert( "Não existem dado a ser impresso!" )
	endIf
	
	( cAlias )->( dbCloseArea() )
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} impProced
Impressao dos Procedimentos

@author    Jonatas Almeida
@version   1.xx
@since     23/08/2016
/*/
//------------------------------------------------------------------------------------------
static function impProced( cAlias,oReport,oProc )
	local cWhereB4O	:= ""
	local cAliasB4O	:= getNextAlias()
	local cCODTABELA:= ""
	local cNGUIAOPE2:= ""
	local cGRPPROC	:= ""
	local cCODPROC	:= ""
	local cDESPROC	:= ""
	local cCODERROP	:= ""
	local cDESERROP	:= ""
	local cCAMPO	:= ""
	
	oProc:Cell( "NGUIAOPE2"	):SetBlock( { || cNGUIAOPE2 } )
	oProc:Cell( "CODTABELA"	):SetBlock( { || cCODTABELA } )
	oProc:Cell( "GRPPROC"	):SetBlock( { || cGRPPROC } )
	oProc:Cell( "CODPROC"	):SetBlock( { || cCODPROC } )
	oProc:Cell( "DESPROC"	):SetBlock( { || cDESPROC } )
	oProc:Cell( "CODERROP"	):SetBlock( { || cCODERROP } )
	oProc:Cell( "DESERROP"	):SetBlock( { || cDESERROP } )
	oProc:Cell( "CAMPO"		):SetBlock( { || cCAMPO } )
	
	cWhereB4O := "%B4O.B4O_SUSEP = '"+ ( cAlias )->( B4N_SUSEP  ) +"' AND "
	cWhereB4O += "B4O.B4O_CMPLOT = '"+ ( cAlias )->( B4N_CMPLOT ) +"' AND "
	cWhereB4O += "B4O.B4O_NUMLOT = '"+ ( cAlias )->( B4N_NUMLOT ) +"' AND "
	cWhereB4O += "B4O.B4O_NMGOPE = '"+ ( cAlias )->( B4N_NMGOPE ) +"'%"
	
	if( MV_PAR07 == 1 )	//1-Todos os Eventos
		beginSQL Alias cAliasB4O
			SELECT DISTINCT B4O_NMGOPE,B4O_CODTAB, B4O_CODGRU, B4O_CODPRO, B4P.B4P_CDCMER, B4P.B4P_CDCMGU
			FROM
			%table:B4O% B4O LEFT JOIN
			%table:B4P% B4P ON
			B4P.B4P_FILIAL = %xFilial:B4P% AND
			B4P.B4P_SUSEP  = B4O.B4O_SUSEP AND
			B4P.B4P_CMPLOT = B4O.B4O_CMPLOT AND
			B4P.B4P_NUMLOT = B4O.B4O_NUMLOT AND
			B4P.B4P_NMGOPE = B4O.B4O_NMGOPE AND
			((B4P.B4P_CODGRU = ' ' AND B4P.B4P_CODPAD = B4O.B4O_CODTAB AND B4P.B4P_CODPRO = B4O.B4O_CODPRO ) OR 
			(B4P.B4P_CODGRU = B4O.B4O_CODGRU AND B4P.B4P_CODPAD = B4O.B4O_CODTAB AND B4P.B4P_CODPRO = ' ')) AND
			B4P.B4P_NIVERR IN( 'E','P' ) AND
			B4P.D_E_L_E_T_ = ''
			WHERE
			B4O.B4O_FILIAL = %xFilial:B4O% AND
			%exp:cWhereB4O% AND
			B4O.%notDel%
		endSQL
	elseif( MV_PAR07 == 2 )	//2-Eventos com criticas
		beginSQL Alias cAliasB4O
			SELECT DISTINCT B4O_NMGOPE, B4O_CODTAB, B4O_CODGRU, B4O_CODPRO, B4P.B4P_CDCMER, B4P.B4P_CDCMGU
			FROM
			%table:B4O% B4O INNER JOIN
			%table:B4P% B4P ON
			B4P.B4P_FILIAL = %xFilial:B4P% AND
			B4P.B4P_SUSEP  = B4O.B4O_SUSEP AND
			B4P.B4P_CMPLOT = B4O.B4O_CMPLOT AND
			B4P.B4P_NUMLOT = B4O.B4O_NUMLOT AND
			B4P.B4P_NMGOPE = B4O.B4O_NMGOPE AND			
			((B4P.B4P_CODGRU = ' ' AND B4P.B4P_CODPAD = B4O.B4O_CODTAB AND B4P.B4P_CODPRO = B4O.B4O_CODPRO ) OR 
			(B4P.B4P_CODGRU = B4O.B4O_CODGRU AND B4P.B4P_CODPAD = B4O.B4O_CODTAB AND B4P.B4P_CODPRO = ' ')) AND
			B4P.B4P_NIVERR IN( 'E','P' ) AND
			B4P.D_E_L_E_T_ = ''
			WHERE
			B4O.B4O_FILIAL = %xFilial:B4O% AND
			%exp:cWhereB4O% AND
			B4O.%notDel%
		endSQL
	else //3-Eventos sem criticas
		beginSQL Alias cAliasB4O
			SELECT B4O_NMGOPE, B4O_CODTAB, B4O_CODGRU, B4O_CODPRO, '' B4P_CDCMER, '' B4P_CDCMGU
			FROM
			%table:B4O% B4O 
			WHERE
				B4O.B4O_FILIAL = %xFilial:B4O% AND
				B4O.B4O_FILIAL + B4O.B4O_SUSEP + B4O.B4O_CMPLOT + B4O.B4O_NUMLOT + B4O.B4O_NMGOPE NOT IN(
					SELECT
					B4P.B4P_FILIAL + B4P.B4P_SUSEP + B4P.B4P_CMPLOT + B4P.B4P_NUMLOT + B4P.B4P_NMGOPE
					FROM %table:B4P% B4P WHERE 
					B4P.B4P_FILIAL = B4O.B4O_FILIAL AND
					B4P.B4P_SUSEP  = B4O.B4O_SUSEP AND
					B4P.B4P_CMPLOT = B4O.B4O_CMPLOT AND
					B4P.B4P_NUMLOT = B4O.B4O_NUMLOT AND
					B4P.B4P_NMGOPE = B4O.B4O_NMGOPE AND
					((B4P.B4P_CODGRU = ' ' AND B4P.B4P_CODPAD = B4O.B4O_CODTAB AND B4P.B4P_CODPRO = B4O.B4O_CODPRO ) OR 
					(B4P.B4P_CODGRU = B4O.B4O_CODGRU AND B4P.B4P_CODPAD = B4O.B4O_CODTAB AND B4P.B4P_CODPRO = ' ')) AND
					B4P.B4P_NIVERR IN( 'E','P' ) AND
					B4P.D_E_L_E_T_ = '' ) AND
				%exp:cWhereB4O% AND
				B4O.%notDel%
		endSQL
	endIf

	( cAliasB4O )->( dbGoTop() )
	
	if( ( cAliasB4O )->( !eof() ) )
		oReport:Section( 2 ):Init()
		oProc:Init()
		
		while( ( cAliasB4O )->( !eof() ) )
			cNGUIAOPE2	:= ( cAliasB4O )->( B4O_NMGOPE )
			cCODTABELA	:= ( cAliasB4O )->( B4O_CODTAB )
			cGRPPROC	:= ( cAliasB4O )->( B4O_CODGRU )
			cCODPROC	:= ( cAliasB4O )->( B4O_CODPRO )
			cDESPROC	:= allTrim( posicione( "BTQ",1,xFilial( "BTQ" ) + cCODTABELA + cCODPROC,"BTQ_DESTER" ) )
			cCODERROP	:= ( cAliasB4O )->( B4P_CDCMER )
			cDESERROP	:= allTrim( posicione( "BTQ",1,xFilial( "BTQ" ) + "38" + cCODERROP,"BTQ_DESTER" ) )
			cCAMPO		:= ( cAliasB4O )->( B4P_CDCMGU )
			
			oProc:PrintLine()
			
			( cAliasB4O )->( dbSkip() )
		endDo
		
		oReport:ThinLine()
		oProc:Finish()
		oReport:Section( 2 ):Finish()
	endIf
	
	( cAliasB4O )->( dbCloseArea() )
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} impErroGuia
Impressao dos erros de monitoramento

@author    Jonatas Almeida
@version   1.xx
@since     23/08/2016
/*/
//------------------------------------------------------------------------------------------
static function impErroGuia( cAlias,oReport,oGuiCri )
	local cWhereB4P	:= ""
	local cAliasB4P	:= getNextAlias()
	local cNGUIAOPE3 := ""
	local cCDCMER	:= ""
	local cDESERR	:= ""
	local cCAMPO	:= ""

	oGuiCri:Cell( "NGUIAOPE3"	):SetBlock( { || cNGUIAOPE3 } )
	oGuiCri:Cell( "CDCMER"		):SetBlock( { || cCDCMER 	} )
	oGuiCri:Cell( "DESERR"		):SetBlock( { || cDESERR 	} )
	oGuiCri:Cell( "CAMPO"		):SetBlock( { || cCAMPO 	} )

	cWhereB4P := "%B4P.B4P_SUSEP = '"+ ( cAlias )->( B4N_SUSEP  ) +"' AND "
	cWhereB4P += "B4P.B4P_CMPLOT = '"+ ( cAlias )->( B4N_CMPLOT ) +"' AND "
	cWhereB4P += "B4P.B4P_NUMLOT = '"+ ( cAlias )->( B4N_NUMLOT ) +"' AND "
	cWhereB4P += "B4P.B4P_NMGOPE = '"+ ( cAlias )->( B4N_NMGOPE ) +"' AND "
	cWhereB4P += "B4P.B4P_NIVERR = 'G'%"

	beginSQL Alias cAliasB4P
		SELECT DISTINCT B4P_NMGOPE, B4P_CDCMER, B4P_DESERR, B4P_CDCMGU
		FROM
		%table:B4P% B4P
		WHERE
		B4P.B4P_FILIAL = %xFilial:B4P% AND
		%exp:cWhereB4P% AND
		B4P.%notDel%
	endSQL

	( cAliasB4P )->( dbGoTop() )

	oReport:Section( 3 ):Init()
	oGuiCri:Init()

	if( ( cAliasB4P )->( !eof() ) )
		oReport:SkipLine( 1 )

		while( ( cAliasB4P )->( !eof() ) )
			cNGUIAOPE3	:= ( cAliasB4P )->( B4P_NMGOPE )
			cCDCMER		:= ( cAliasB4P )->( B4P_CDCMER )
			cDESERR		:= ( cAliasB4P )->( B4P_DESERR )
			cCAMPO		:= ( cAliasB4P )->( B4P_CDCMGU )
			oGuiCri:PrintLine()

			( cAliasB4P )->( dbSkip() )
		endDo
						
		oReport:ThinLine()
		oGuiCri:Finish()
		oReport:Section( 3 ):Finish()
	endIf
					
	( cAliasB4P )->( dbCloseArea() )
return
