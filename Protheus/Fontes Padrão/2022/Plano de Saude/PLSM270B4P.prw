#DEFINE CRLF chr(13) + chr(10)
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Lucas Nonato
@version   1.xx
@since     19/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB4P := FWFormStruct( 1, 'B4P', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( 'Monitoramento' )
	oModel:AddFields( 'MODEL_B4P',,oStruB4P )	
	oModel:SetDescription( "Monitoramento Erros TISS" )
	oModel:GetModel( 'MODEL_B4P' ):SetDescription( ".:: Monitoramento TISS ::." ) 
	oModel:SetPrimaryKey( { "B4P_FILIAL","B4P_CMPLOT","B4P_NUMLOT","B4P_CPFCNP","B4P_NMGOPE","B4P_NMGPRE" } )
return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    Lucas Nonato
@version   1.xx
@since     19/08/2016 
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FWLoadModel( 'PLSM270B4P' )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
ViewDef - MVC

@author    Lucas Nonato
@version   1.xx
@since     19/08/2016 
/*/
//------------------------------------------------------------------------------------------
static function MenuDef()
local aRotina := {}

return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL270B4P
Preenchimento e gravacao dos dados do Monitoramento TISS (tabela B4P)
@author    Lucas Nonato
@since     24/08/2016
/*/
//------------------------------------------------------------------------------------------
Function PL270B4P(aLote, cCampo, cNvErro, cCodErro, cAliasCri, cNumGui, cCodPad, cCodPro, cGrupo, cDesc)
Local aCampos		:= {}
Local aCampB4N		:= {}
Local aCampB4O		:= {}
Local aCampB4M		:= {}
Local cDescErro		:= ""
Local lRet			:= .T.
Local cSusep		:= ""
Local cGuiPre		:= ""
DEFAULT aLote		:= {}
DEFAULT cCampo		:= ""
DEFAULT cNvErro		:= ""
DEFAULT cCodErro	:= ""
DEFAULT cAliasCri	:= ""
DEFAULT cNumGui		:= ""
DEFAULT cCodPad		:= ""
DEFAULT cCodPro		:= ""
DEFAULT cAliasCri	:= ""
DEFAULT cGrupo		:= ""
DEFAULT cDesc		:= ""

BTQ->(dbSetOrder(1)) // BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM
B4P->(dbSetOrder(1)) // B4P_FILIAL, B4P_SUSEP, B4P_CMPLOT, B4P_NUMLOT, B4P_NMGOPE, B4P_CODPAD, B4P_CODPRO, R_E_C_D_E_L_
B4O->(dbSetOrder(5)) // B4O_FILIAL, B4O_SUSEP, B4O_CMPLOT, B4O_NUMLOT, B4O_NMGOPE, B4O_DATREA, B4O_CODGRU, B4O_CODTAB, B4O_CODPRO, B4O_CDDENT, B4O_CDFACE, B4O_CDREGI, B4O_CODRDA
BTQ->(MsSeek(xFilial("BTQ")+'38'+ cCodErro))
if empty(cDesc)	
	cDescErro := AllTrim(BTQ->BTQ_DESTER)
else
	cDescErro := cDesc
endif
cSusep := aLote[3]//BA0->BA0_SUSEP

If !Empty(cAliasCri) .And. !Empty(( cAliasCri )->B4N_NMGPRE)
	cGuiPre	:= ( cAliasCri )->B4N_NMGPRE
endIf

cGrupo := padR( cGrupo,tamSX3( "B4O_CODGRU" )[ 1 ] )

If !B4P->(dbSeek(xFilial('B4P') + cSusep + aLote[ 2 ] + aLote[ 1 ]	 + cNumGui + cGrupo + cCodPad + cCodPro + cCodErro))  

	aadd( aCampos,{ "B4P_FILIAL", 	xFilial('B4P')			} ) //Filial 
	aadd( aCampos,{ "B4P_CDCMGU", 	cCampo					} ) //Campo Guia 
	aadd( aCampos,{ "B4P_CDCMER", 	cCodErro				} ) //Cod Erro 
	aadd( aCampos,{ "B4P_DESERR", 	cDescErro				} ) //Desc Erro 
	aadd( aCampos,{ "B4P_NIVERR", 	cNvErro					} ) //Nivel Erro
	aadd( aCampos,{ "B4P_SUSEP ", 	cSusep					} ) //Reg Ans
	aadd( aCampos,{ "B4P_CMPLOT", 	aLote[2]				} ) //Competencia do Lote 
	aadd( aCampos,{ "B4P_NUMLOT", 	aLote[1]				} ) //Num Lote 
	aadd( aCampos,{ "B4P_NMGOPE", 	(cAliasCri)->B4N_NMGOPE	} ) //Num Guia Operadora 
	aadd( aCampos,{ "B4P_NMGPRE", 	cGuiPre					} ) //Num Guia Prestador 
	aadd( aCampos,{ "B4P_CODPRO", 	cCodPro					} ) //Cod Tabela
	aadd( aCampos,{ "B4P_CODPAD", 	cCodPad					} ) //Cod Procedimento
	aadd( aCampos,{ "B4P_ORIERR", 	'1'						} ) //Origem do Erro 1-PLS;2-Retorno;3-Qualidade
	aadd( aCampos,{ "B4P_CODGRU", 	cGrupo					} ) //Grupo	
	
	lRet := gravaMonit( 3,aCampos,'MODEL_B4P','PLSM270B4P' )
	If lRet
		If B4M->(dbSeek(xFilial('B4M') +  cSusep + aLote[2] + aLote[1] )) 
			aAdd( aCampB4M,{ "B4M_STATUS",	'2' } )				// Status 
			aAdd( aCampB4M,{ "B4M_QTDCRI",	B4M->B4M_QTDCRI+1 } )	// Quantidade de Criticas
			lRet := gravaMonit( 4,aCampB4M,'MODEL_B4M','PLSM270' )
			If B4N->(dbSeek(xFilial('B4N') +  cSusep + aLote[2] + aLote[1] + cNumGui)) 
				aAdd( aCampB4N,{ "B4N_STATUS",	'2' } )			// Status
				lRet := gravaMonit( 4,aCampB4N,'MODEL_B4N','PLSM270B4N' )
				If !Empty(cCodPro) .And. B4O->(dbSeek(xFilial('B4O') +  cSusep + aLote[2] + aLote[1] + cNumGui + cGrupo + cCodPad + AllTrim(cCodPro) )) 
					aAdd( aCampB4O,{ "B4O_STATUS",	'2' } )	// Status
					lRet := gravaMonit( 4,aCampB4O,'MODEL_B4O','PLSM270B4O' )
				EndIf
			EndIf
		EndIf
	EndIf
EndIf	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDMON

@author    Lucas Nonato
@since     18/08/2016
/*/
//------------------------------------------------------------------------------------------
Function PLVLDMON(aLote, cWhere)
local cAliasCri	:= GetNextAlias()
local cSql	:= ""
DEFAULT aLote 	:= {}
default cWhere	:= ""
	
cSql += " SELECT B4N_NMGOPE, B4N_CODRDA, COUNT(*) " 
cSql += " FROM " + RetSqlName("B4N") + " B4N "
cSql += " WHERE B4N_FILIAL = '" + xFilial("B4N") + "' "
cSql += " AND B4N_SUSEP  = '" + aLote[3] + "' "
cSql += " AND B4N_CMPLOT = '" + aLote[2] + "' "
cSql += " AND B4N_NUMLOT = '" + aLote[1] + "' "
cSql += " AND B4N.D_E_L_E_T_ = ' ' "
cSql +=  cWhere
cSql += " GROUP BY B4N_NMGOPE, B4N_CODRDA"
cSql += " HAVING Count(*) > 1	"

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasCri,.F.,.T.)

//Pergunta respondida pela ANS em caso de guias iguais com prestadores diferentes
//Como devemos proceder no caso de divisão de remuneração em arquivo de SADT? Por exemplo: foi realizada uma ultrassonografia onde, conforme padrão TISS, foi lançada uma participação 12 - Clínico. Neste caso, parte do pagamento ocorre para o médico e parte para a clínica, mas a guia é a mesma.
//Resp: Como os prestadores são distintos, a chave do monitoramento já separa.

// GUIA JÁ APRESENTADA
While ( ( cAliasCri )->( !eof() ) )
	PL270B4P( aLote,"","G","1308",cAliasCri,( cAliasCri )->B4N_NMGOPE )
	( cAliasCri )->( dbSkip() )
EndDo

VldGuiaB4N(aLote,cWhere)
VldItemB4O(aLote,cWhere)
VldPacote(aLote,cWhere)

(cAliasCri)->(DbCloseArea())

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} existeBTQ
Pesquisa na tabela de terminologias
@author    Lucas Nonato
@since     26/08/2016
/*/
//------------------------------------------------------------------------------------------
Function existeBTQ(cCdTerm, cCodPro)
Local lAchou := .F.

BTQ->(dbSetOrder(1))//BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM

If BTQ->(dbSeek(xFilial("BTQ")+cCdTerm+Alltrim(cCodPro)))
	lAchou := .T.
Endif

Return lAchou

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldGuiaB4N
Valida os itens gravados da guia
@author    Lucas Nonato
@since     26/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function VldGuiaB4N(aLote, cWhere)

Local cAliasB4N	:= GetNextAlias()
Local cSql		:= ""     
	
cSql := " SELECT B4N_MOTSAI, B4N_NUMCNS, B4N_TIPADM, B4N_NMGOPE, B4N_NMGPRE, B4N_NUMLOT, B4N_VLTGUI, B4N_DTPRGU, "
cSql += " B4N_DATNAS, B4N_SUSEP, B4N_OREVAT, B4N_IDEREE, B4N_TIPATE, B4N_SOLINT, B4N_CDMNRS	"
cSql += " FROM " + RetSqlName("B4N") + " B4N "
cSql += " WHERE B4N_FILIAL = '" + xFilial("B4N") + "' "
cSql += " AND B4N_SUSEP  = '" + aLote[3] + "' "
cSql += " AND B4N_CMPLOT = '" + aLote[2] + "' "
cSql += " AND B4N_NUMLOT = '" + aLote[1] + "' "
cSql += " AND B4N.D_E_L_E_T_ = ' ' "
cSql +=  cWhere			

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasB4N,.F.,.T.)

//--< Guia - B4N >--
While !(cAliasB4N)->(EOF())
	//NÚMERO DO CARTÃO NACIONAL DE SAÚDE INVÁLIDO
	If !Empty((cAliasB4N)->B4N_NUMCNS ) .And. !HS_VldCns((cAliasB4N)->B4N_NUMCNS ) 
		PL270B4P(aLote, "016", "G", "1002",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)
	EndIf
	
	// CARÁTER DE ATENDIMENTO INVÁLIDO
	If !Empty((cAliasB4N)->B4N_TIPADM) .And. !(AllTrim((cAliasB4N)->B4N_TIPADM)) $ '1#2#E#U'
		PL270B4P(aLote, "038", "G", "5031",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)
	EndIf
	
	// NÚMERO DO LOTE NÃO INFORMADO
	If Empty((cAliasB4N)->B4N_NUMLOT)
		PL270B4P(aLote, "002", "G", "5047",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)
	EndIf
	
	// VALOR TOTAL MENOR QUE ZERO NA GUIA
	If (cAliasB4N)->B4N_VLTGUI < 0 
		PL270B4P(aLote, "050", "G", "5049",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)
	EndIf
	
	// NÚMERO DA GUIA INVÁLIDO
	If Len((cAliasB4N)->B4N_NMGOPE) <> 20
		PL270B4P(aLote, "024", "G", "1307",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)
	EndIf
	
	// DATA DE NASCIMENTO DO BENEFICIÁRIO INVÁLIDA
	If STOD((cAliasB4N)->B4N_DATNAS ) == STOD("")
		PL270B4P(aLote, "018", "G", "5048",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)
	EndIf
	
	// MOTIVO DE ENCERRAMENTO INVÁLIDO
	If !Empty((cAliasB4N)->B4N_MOTSAI ) .And. !existeBTQ('39', (cAliasB4N)->B4N_MOTSAI)
		PL270B4P(aLote, "049", "G", "5033",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)
	EndIf
	
	// COMPETÊNCIA NÃO ESTÁ LIBERADA PARA ENVIO DE DADOS
	If !Empty((cAliasB4N)->B4N_DTPRGU ) .And. Month(STOD((cAliasB4N)->B4N_DTPRGU)) > Month(Date()) .And. year(STOD((cAliasB4N)->B4N_DTPRGU)) > year(Date())
		PL270B4P(aLote, "003", "G", "5023",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)
	EndIf
	
	//DATA DE REGISTRO DA TRANSACAO INVALIDA
	If AllTrim(SubStr((cAliasB4N)->B4N_DTPRGU,1,6)) <> AllTrim(aLote[ 2 ])
		PL270B4P(aLote, "080", "G", "5025",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)  
	EndIf
	
	//NÚMERO DA GUIA INVÁLIDO
	If AllTrim((cAliasB4N)->B4N_OREVAT) == "4" .And. (cAliasB4N)->B4N_IDEREE == "00000000000000000000"
		PL270B4P(aLote, "025", "G", "1307",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)  
	EndIf
	
	//NÚMERO DA GUIA INVÁLIDO, SADT DE PACIENTE INTERNADO SEM GUIA DE INTERNAÇÃO
	If AllTrim((cAliasB4N)->B4N_TIPATE) == "07" .And.  Empty((cAliasB4N)->B4N_SOLINT)
		PL270B4P(aLote, "026", "G", "1307",cAliasB4N,( cAliasB4N )->B4N_NMGOPE)  
	EndIf

	If empty((cAliasB4N)->B4N_CDMNRS) 
		PL270B4P(aLote, "099", "G", "X001",cAliasB4N,( cAliasB4N )->B4N_NMGOPE,,,,"Municipio de residencia do beneficiario invalido. Preencher o campo BA1/BTS_CODMUN. ")  
	EndIf	

	( cAliasB4N )->(dbSkip())

EndDo

( cAliasB4N )->( dbCloseArea() )

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldItemB4O
Valida os procedimentos das guias
@author    Lucas Nonato
@since     26/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function VldItemB4O(aLote, cWhere)
Local cAliasB4O	:= GetNextAlias()
Local cSql		:= ""
Local lPLSTMON2 := ExistBlock("PLSTMON2")
		
cSql += " SELECT B4N_CODOPE, B4O_CPFCNP, B4N_NMGOPE, B4O_CODPRO, B4O_CODTAB, B4O_CODGRU, B4O_CDDENT, B4O_CBOS, B4O_QTDINF, B4N_TPEVAT, B4N_DTPAGT, B4N_VLTGLO, B4N_IDCOPR, "
cSql += " B4O_DIAUTI, B4O_DATSOL, B4O_QTDPAG, B4O_VLPGPR, B4N_SUSEP, B4N_NMGPRE, B4O_STATUS, B4O_NMGOPE, B4O_CODTAB, B4O_CODPRO, B4N_OREVAT, B4O_DTFIFT, B4N_TIPFAT "
cSql += " FROM " + RetSqlName("B4N") + " B4N "
cSql += " INNER JOIN " + RetSqlName("B4O") + " B4O "	
cSql += " ON B4O_FILIAL = '" + xFilial("B4O") + "' "    
cSql += " AND B4O_SUSEP  = B4N_SUSEP 	"	  
cSql += " AND B4O_CMPLOT = B4N_CMPLOT 	"
cSql += " AND B4O_NUMLOT = B4N_NUMLOT 	"
cSql += " AND B4O_NMGOPE = B4N_NMGOPE "	
cSql += " AND B4O.D_E_L_E_T_ = ' ' "
cSql += " WHERE B4N_FILIAL = '" + xFilial("B4N") + "' "
cSql += " AND B4N_SUSEP  = '" + aLote[3] + "' "
cSql += " AND B4N_CMPLOT = '" + aLote[2] + "' "
cSql += " AND B4N_NUMLOT = '" + aLote[1] + "' "
cSql += cWhere
cSql += " AND B4N.D_E_L_E_T_ = ' ' "	

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasB4O,.F.,.T.)

//--< Itens - B4O >--
While !(cAliasB4O)->(EOF())
	//CPF / CNPJ INVÁLIDO
	If !Empty((cAliasB4O)->B4O_CPFCNP ) .And. !CGC((cAliasB4O)->B4O_CPFCNP,,.f. )
		PL270B4P(aLote, "090", "E", "1206",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU) 
	EndIf	

	// NÃO ENVIAR CPF EM RESUMO DE INTERNAÇÃO
	if (cAliasB4O)->B4N_TPEVAT == '3' .and. len((cAliasB4O)->B4O_CPFCNP) < 12 // 3 - Resumo de internação
		PL270B4P(aLote, "090", "E", "5029",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU) 
	endIf

	//CBO (ESPECIALIDADE) INVÁLIDO
	BAQ->(	dbSetOrder(4)) // BAQ_FILIAL, BAQ_CODINT, BAQ_CBOS
	If (alltrim((cAliasB4O)->B4N_TPEVAT) == '1' .and. empty((cAliasB4O)->B4O_CBOS)) .or. ;
		(!empty((cAliasB4O)->B4O_CBOS) .and. !BAQ->(dbSeek(xFilial("BAQ") + (cAliasB4O)->B4N_CODOPE + (cAliasB4O)->B4O_CBOS))) .or.;
		(alltrim((cAliasB4O)->B4N_TPEVAT) == '2' .and. AllTrim((cAliasB4O)->B4N_OREVAT) <> '4' /*Reembolso*/ .and. empty((cAliasB4O)->B4O_CBOS) .and. PLSISCON(( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO) )
		PL270B4P(aLote, "035", "E", "1213",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)
	EndIf

	//PROCEDIMENTO INVÁLIDO
	If (cAliasB4O)->B4O_STATUS == '2'
		PL270B4P(aLote, "066", "E", "1801",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)
	EndIf

	//QUANTIDADE DE DIÁRIAS DEVE SER MAIOR QUE ZERO  
	/*If (cAliasB4O)->B4N_TPEVAT == '3' .And. (Empty((cAliasB4O)->B4O_DIAUTI) .Or. Val((cAliasB4O)->B4O_DIAUTI) <= 0)
		PL270B4P(aLote, "070", "E", "1905",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)
	EndIf */

	// QUANTIDADE NÃO INFORMADA
	If !Empty((cAliasB4O)->B4N_DTPAGT) .And. (Empty((cAliasB4O)->B4O_QTDPAG) .Or. (cAliasB4O)->B4O_QTDPAG <= 0 )
		PL270B4P(aLote, "070", "E", "5041",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)
	EndIf
	 
	// VALOR NÃO INFORMADO
	If (cAliasB4O)->B4O_VLPGPR < 0 
		PL270B4P(aLote, "059", "E", "5034",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)
	EndIf
	
	// VALOR DEVE SER MAIOR QUE ZERO
	If (cAliasB4O)->B4O_VLPGPR <= 0 .and. !Empty((cAliasB4O)->B4N_DTPAGT) .and. (cAliasB4O)->B4N_VLTGLO <= 0 .and. empty((cAliasB4O)->B4N_IDCOPR)
		PL270B4P(aLote, "059", "E", "5040",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)
	EndIf

	If alltrim((cAliasB4O)->B4N_TPEVAT) == '3' .and. (cAliasB4O)->B4N_TIPFAT $ 'T;2;4' .and. empty((cAliasB4O)->B4O_DTFIFT)
		PL270B4P(aLote, "031", "E", "1323",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)  
	EndIf

	If !(cAliasB4O)->B4O_CODTAB $ "90#98" 					
	
		// CÓDIGO DO DENTE INVÁLIDO
		If !Empty((cAliasB4O)->B4O_CDDENT ) .And. !existeBTQ('28', (cAliasB4O)->B4O_CDDENT)
			PL270B4P(aLote, "069", "E", "5037",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)
		EndIf	
		
		//CÓDIGO DO GRUPO DO PROCEDIMENTO INVÁLIDO
		If !existeBTQ('63', (cAliasB4O)->B4O_CODGRU )
			PL270B4P(aLote, "107", "E", "5036",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)
		EndIf
		
		//CODIFICAÇÃO INCORRETA/INADEQUADA DO PROCEDIMENTO.
		If !lPLSTMON2 
			If !existeBTQ('64', (cAliasB4O)->B4O_CODPRO) .And. !existeBTQ('00', (cAliasB4O)->B4O_CODPRO) .And. !existeBTQ((cAliasB4O)->B4O_CODTAB, (cAliasB4O)->B4O_CODPRO) .And. !( (cAliasB4O)->B4O_CODTAB $ GetNewPar("MV_PLTABPR","00,90,98") )
				PL270B4P(aLote, "066", "E", "2601",cAliasB4O,( cAliasB4O )->B4N_NMGOPE,( cAliasB4O )-> B4O_CODTAB,( cAliasB4O )-> B4O_CODPRO, (cAliasB4O)->B4O_CODGRU)
			EndIf
		EndIf		
	EndIf
	( cAliasB4O )->(dbSkip())
EndDo

( cAliasB4O )->( dbCloseArea() )

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldB4OxB4N
Valida se o valor da somatória dos procedimentos é igual ao valor da guia
@author    Lucas Nonato
@since     29/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function VldB4OxB4N(aLote, cNumGui, cVlr)
Local cAliasSoma	:= GetNextAlias()
Local cDebug		:= ""

BeginSql Alias cAliasSoma

	SELECT
	
  	SUM(B4O_VLPGPR) SOMA 	
  	
  	FROM
  	
	%table:B4N% B4N, 	/*Guias*/
	%table:B4O% B4O	/*Itens*/					
	WHERE
	B4N_FILIAL = %xfilial:B4N% 	AND
	B4N_SUSEP  = %exp:aLote[3]% AND	
	B4N_CMPLOT = %exp:aLote[2]% AND	
	B4N_NUMLOT = %exp:aLote[1]% AND
	B4N_NMGOPE = %exp:cNumGui%	AND
	B4N.%notDel% 				AND
		
	B4O_FILIAL = %xfilial:B4O% 	AND	
	B4O_SUSEP  = B4N_SUSEP 		AND
	B4O_CMPLOT = B4N_CMPLOT 	AND
	B4O_NUMLOT = B4N_NUMLOT 	AND	
	B4O_NMGOPE = B4N_NMGOPE		AND						
	B4O.%notDel%							
		
EndSql

cDebug := GetLastQuery()[2]	//Para debugar a query

//--< Guia - B4N >--
If (cAliasSoma)->SOMA <> cVlr
	//VALOR INFORMADO DA GUIA DIFERENTE DO SOMATÓRIO DO VALOR INFORMADO DOS ITENS
	PL270B4P(aLote, 'G', "050", "5042",cAliasSoma,( cAliasSoma )->B4N_NMGOPE)
		
	//--< Item - B4O >--
	If Val(cAliasSoma->(SOMA)) <  Val(cVlr) 
		//VALOR APRESENTADO A MAIOR
		PL270B4P(aLote, 'G', "050", "1705",cAliasSoma,( cAliasSoma )->B4N_NMGOPE)
	ElseIf Val(cAliasSoma->(SOMA)) >  Val(cVlr) 
		//VALOR APRESENTADO A MENOR
		PL270B4P(aLote, 'G', "050", "1706",cAliasSoma,( cAliasSoma )->B4N_NMGOPE)		
	EndIf
EndIf
( cAliasSoma )->( dbCloseArea() )

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldPacote
Valida o código da tabela do pacote
@author    Lucas Nonato
@since     29/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function VldPacote(aLote, cWhere)
Local cAliasP	:= GetNextAlias()

cSql := " SELECT B4N_NMGOPE, B4U_CDTBPC, B4U_CDPRPC, B4N_NMGPRE FROM " + RetSqlName("B4N") + " B4N "
cSql += " INNER JOIN " + RetSqlName("B4O") + " B4O "
cSql += " ON  B4O_FILIAL = '" + xFilial("B4N") + "' "
cSql += " AND B4O_SUSEP  = B4N_SUSEP  "
cSql += " AND B4O_CMPLOT = B4N_CMPLOT "
cSql += " AND B4O_NUMLOT = B4N_NUMLOT "	
cSql += " AND B4O_NMGOPE = B4N_NMGOPE "	
cSql += " INNER JOIN " + RetSqlName("B4U") + " B4U "
cSql += " ON B4U_FILIAL = '" + xFilial("B4U") + "' " 
cSql += " AND B4U_SUSEP  = B4O_SUSEP  "
cSql += " AND B4U_CMPLOT = B4O_CMPLOT "
cSql += " AND B4U_NUMLOT = B4O_NUMLOT "
cSql += " AND B4U_NMGOPE = B4O_NMGOPE "
cSql += " AND B4U_CDTBPC = B4O_CODTAB "	
cSql += " AND B4U_CDPRPC = B4O_CODPRO "	
cSql += " AND B4U_CDTBIT = '00' "
cSql += " AND B4U.D_E_L_E_T_ = ' ' "
cSql += " WHERE B4N_FILIAL = '" + xFilial("B4N") + "' " 
cSql += " AND B4N_SUSEP  = '" + aLote[3] + "' "
cSql += " AND B4N_CMPLOT = '" + aLote[2] + "' "
cSql += " AND B4N_NUMLOT = '" + aLote[1] + "' "
cSql += " AND B4N.D_E_L_E_T_ = ' ' "
cSql += cWhere

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasP,.F.,.T.)

while (cAliasP)->(!eof()) 
	PL270B4P(aLote, "077", "P", "3150",cAliasP,( cAliasP )->B4N_NMGOPE,( cAliasP )-> B4U_CDTBPC,( cAliasP )->B4U_CDPRPC) 
	// CÓDIGO DA TABELA INVÁLIDO 3150
	( cAliasP )->( dbskip() )
enddo

( cAliasP )->( dbCloseArea() )

return