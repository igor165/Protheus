#INCLUDE "OGA320.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA320
Rotina para alteração dos status dos contratos de compra, venda e ou armazenagem

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGA320( pcCodCtr, pcFilial)     
	Local oMBrowse := Nil
	Local cFiltroDef := iIf( !Empty( pcCodCtr ), "NJR_CODCTR='"+pcCodCtr+"' .And. NJR_FILIAL='"+pcFilial+"'", "" )
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJR" )
	oMBrowse:SetDescription( STR0001 ) //"Status dos Contratos"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:DisableDetails()
	oMBrowse:SetMenuDef( "OGA320" )
	
	oMBrowse:AddLegend( "(NJR_MODELO=='1')"											, "WHITE"		, X3CboxDesc( "NJR_MODELO", "1" )	) //"Pré-Contrato"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='P'"	, "BLUE"		, X3CboxDesc( "NJR_STATUS", "P" )	) //"Previsto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='A'"	, "GREEN"		, X3CboxDesc( "NJR_STATUS", "A" )	) //"Aberto"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='I'"	, "YELLOW"		, X3CboxDesc( "NJR_STATUS", "I" )	) //"Iniciado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='E'"	, "BR_CANCEL"	, X3CboxDesc( "NJR_STATUS", "E" )	) //"Cancelado"
	oMBrowse:AddLegend( "(NJR_MODELO=='2'.Or.NJR_MODELO=='3').And.NJR_STATUS=='F'"	, "RED"			, X3CboxDesc( "NJR_STATUS", "F" )	) //"Finalizado"
	
	oMBrowse:aColumns[1]:cTitle := STR0008 //"Sts.Geral"
	
	oMBrowse:AddStatusColumns( {||OGA320Est(NJR->( NJR_STSASS ))}, {||OGA320Leg(NJR->( '1' ))})
	oMBrowse:aColumns[2]:cTitle := STR0011 //"Sts.Ass."
	
	oMBrowse:AddStatusColumns( {||OGA320Est(NJR->( NJR_STSFIS ))}, {||OGA320Leg(NJR->( '2' ))})
	oMBrowse:aColumns[3]:cTitle := STR0014 //"Sts.Fis."
	
	oMBrowse:AddStatusColumns( {||OGA320Est(NJR->( NJR_STSFIN ))}, {||OGA320Leg(NJR->( '3' ))})
	oMBrowse:aColumns[4]:cTitle := STR0017 //"Sts.Fin."
	
	oMBrowse:AddStatusColumns( {||OGA320Est(NJR->( NJR_STSEST ))}, {||OGA320Leg(NJR->( '4' ))})
	oMBrowse:aColumns[5]:cTitle := STR0029 //"Sts.Est."
	
	oMBrowse:Activate()
	
Return( Nil )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA320 - Contratos
*/
Static Function MenuDef()    
	Local aRotina := {}
	
	aAdd( aRotina, { STR0020	, "PesqBrw"     , 0, 1, 0, .t. } ) //"Pesquisar"
	aAdd( aRotina, { STR0021	, "OGA320A"		, 0, 4, 0, Nil } ) //"Assinatura"
	aAdd( aRotina, { STR0022	, "OGA320A"		, 0, 4, 0, Nil } ) //"Fiscal"
	aAdd( aRotina, { STR0023	, "OGA320A"		, 0, 4, 0, Nil } ) //"Financeiro"
	aAdd( aRotina, { STR0024	, "OGA320A"		, 0, 4, 0, Nil } ) //"Estoque"
	
Return( aRotina )

/*/{Protheus.doc} OGA320Leg
//TODO Descrição auto-gerada.
@author elienai.lima
@since 21/07/2017
@version undefined
@param cCampo, characters, descricao
@type function
/*/
Static Function OGA320Leg(cCampo)
Local oLegend  :=  FWLegend():New()

	If cCampo == "1"
        oLegend:Add("","BR_VERDE",    STR0009 ) // "Assinatura Aberto"
        oLegend:Add("","BR_VERMELHO", STR0010 ) // "Assinatura Fechado"
	ElseIf cCampo == "2"
	    oLegend:Add("","BR_VERDE",    STR0012 ) // "Fiscal Aberto"
        oLegend:Add("","BR_VERMELHO", STR0013 ) // "Fiscal Fechado"
	ElseIf cCampo == "3"
	    oLegend:Add("","BR_VERDE",    STR0015 ) // "Financeiro Aberto"
        oLegend:Add("","BR_VERMELHO", STR0016 ) // "Financeiro Fechado"
	Else 
        oLegend:Add("","BR_VERDE",    STR0018 ) // "Estoque Aberto"
        oLegend:Add("","BR_VERMELHO", STR0019 ) // "Estoque Fechado"
    EndIf
    
    oLegend:Activate()
    oLegend:View()
    oLegend:DeActivate()
	
Return

/*/{Protheus.doc} OGA320Est
//TODO Descrição auto-gerada.
@author elienai.lima
@since 21/07/2017
@version undefined
@param cStatus, characters, descricao
@type function
/*/
Static Function OGA320Est(cStatus)

	If (cStatus=="A")
		cStatus := 'BR_VERDE'
	ElseIf (cStatus=="F")
		cStatus := 'BR_VERMELHO' 
	EndIf
    
Return cStatus 

/** {Protheus.doc} OGA320A
Rotina para cadastro de contratos de compra, venda e ou armazenagem

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA320A( cAlias, nReg, nOpc )
	Local cTitulo 	:= ""
	Local cCampo 	:= ""
	Local cStatus 	:= ""
	
	Do Case
		Case nOpc = 2
			cTitulo := STR0021 //"Assinatura"
			cCampo  := "NJR->( NJR_STSASS )"
			cStatus := NJR->( NJR_STSASS )
		Case nOpc = 3
			cTitulo := STR0022 //"Fiscal"
			cCampo  := "NJR->( NJR_STSFIS )"
			cStatus := NJR->( NJR_STSFIS )
		Case nOpc = 4
			cTitulo := STR0023 //"Financeiro"
			cCampo  := "NJR->( NJR_STSFIN )"
			cStatus := NJR->( NJR_STSFIN )
		Case nOpc = 5
			cTitulo := STR0024 //"Estoque"
			cCampo  := "NJR->( NJR_STSEST )"
			cStatus := NJR->( NJR_STSEST )
	EndCase
	
	
	If .Not. MsgYesNo(STR0025 + IIf( cStatus = "F", "ABRIR", "FECHAR" ) + STR0026 + cTitulo + STR0027, STR0028) //"Tem certeza que deseja "###" o -Status- para [ "###" ] deste contrato?"###"Status do Contrato"
		Return( .f. )
		
	Else
		
		If RecLock( "NJR", .f. )
			&( cCampo ) := IIf( cStatus = "A", "F", "A" )
			NJR->( MsUnLock() )
		EndIf
		
		//"Assinatura" e status "F=Finalizado"
		If nOpc = 2 .And. NJR->( NJR_STSASS ) == "F"
			//função atualiza status da IE relacionadas ao contrato
			OGA320STIE(NJR->( NJR_CODCTR ))
		EndIf
	EndIf
	
	
Return( .t. )

/*/{Protheus.doc} OGA320STIE
//Ao atualizar status de assinatura do contrato atualiza status de assinatura da IE
//Caso status comercial esteja aprovado atualiza status da IE para instruída
@author marina.muller
@since 14/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGA320STIE(cCodCtr)
	Local aArea     := GetArea()
	Local cAliasN7Q := GetNextAlias()
	Local cQry		:= ""
	Local nStatusN7Q
	
	If AGRTABDIC({"N7Q","N7S"}) //verifica se as tabelas existem no dicionario de dados  --- proteção fonte
	
		//busca colunas status da IE relacionadas ao contrato para serem atualizadas 
		cQry := "SELECT DISTINCT N7Q.N7Q_FILIAL, N7Q.N7Q_CODINE, N7Q.N7Q_STATUS, N7Q.N7Q_STACOM, N7Q.N7Q_STSASS "  
		cQry += "  FROM " + RetSqlName("N7Q") + " N7Q " 
		cQry += " INNER JOIN " + RetSqlName("N7S") + " N7S "
		cQry += "    ON N7S.N7S_CODINE = N7Q.N7Q_CODINE "
		cQry += "   AND N7S.D_E_L_E_T_ = ' '  "
		cQry += " WHERE N7Q.D_E_L_E_T_ = ' '  "	 
		cQry += "   AND N7S.N7S_CODCTR = '" + cCodCtr + "' "
		
		//--Identifica se tabela esta aberta e fecha
		If Select(cAliasN7Q) <> 0
			(cAliasN7Q)->(dbCloseArea())
		EndIf
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasN7Q,.F.,.T.)
		IF (cAliasN7Q)->(!Eof())
			While (cAliasN7Q)->(!Eof())
				// se status comercial 2=Aprovada 
				If (cAliasN7Q)->N7Q_STACOM == 2
					nStatusN7Q := 3 //status IE altera 3=Instruida
				EndIf	
				
			    N7Q->(dbSetOrder(1))
		   	    If N7Q->(MsSeek((cAliasN7Q)->N7Q_FILIAL+(cAliasN7Q)->N7Q_CODINE)) //N7Q_FILIAL+N7Q_CODINE
					If RecLock( "N7Q", .F. )
						N7Q->N7Q_STATUS := nStatusN7Q 
						N7Q->N7Q_STSASS := "1"  //status assinatura 1=Contrato Assinado	
						N7Q->( MsUnLock() )
					EndIf
				EndIf
				N7Q->( DbCloseArea())
					
				(cAliasN7Q)->(dbSkip())
			EndDo
		EndIf
		(cAliasN7Q)->(dbCloseArea())
	 
	 	RestArea(aArea)
	 	
	 EndIf

Return( .t. )
