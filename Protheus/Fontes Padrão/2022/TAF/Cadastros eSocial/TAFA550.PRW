#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA407.CH"

Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA550
Cadastro MVC de Pagamentos de Rendimentos do Trabalho Autonomos RPA - S-1210

@author Ricardo Lovrenovic
@since 21/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Function TAFA550()

	Local cFilter := " T3P_ATIVO == '1' .and. T3P_TRABEV == 'TAUTO' "

	Private oBrw  := FWmBrowse():New()

	FwMsgRun(, { || AtuRegT3P() }, "Atualizando Registros S-1200 Autônomos...", "Aguarde") 	//"Atualizando Registros S-1200 Autônomos.."

	DbSelectArea('T3P')

	If TafAtualizado()
		TafNewBrowse( "S-1210", , , , STR0001, , 2, 2, , cFilter )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	If FindFunction("FilCpfNome") .And. GetSx3Cache("T3P_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")
		
		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF407View('T3P',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF407AUTI('T3P',RECNO())" OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('T3P', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA407"			 OPERATION 8 ACCESS 0 //'Imprimir'
	
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuRegT3P
Função responsável por localizar os registros que são elegíveis para
Trabalhadores Autônomos.

@return .t.

@author Ricardo Lovrenovic 
@since 28/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function AtuRegT3P()

	Local cQuery    	:= ""
	Local cUpdt     	:= ""
	Local cAliasQry 	:= GetNextAlias()
	Local nCount		:= 0
	Local lRet      	:= .T.

	If !TAFColumnPos( "T3P_TRABEV" )
		If !Isblind() 
			MsgInfo("Ambiente desatualizado (T3P_TRABEV), necessário aplicação de dicionário mais atualizado.")
		EndIf
		Return(.F.)
	EndIf

	//Query para verificar novos registros S-1210 autÃ´nomos

	cQuery +=   "SELECT COUNT(*) AS REGISTROS_T3P "
	cQuery +=   "FROM   " + RetSQLName("T3P") + " T3P " 
	cQuery +=   "    INNER JOIN " + RetSQLName("C9V") + " C9V ON " 
	cQuery +=   "            T3P.T3P_FILIAL = C9V.C9V_FILIAL " 
	cQuery +=   "            AND T3P.T3P_BENEFI = C9V.C9V_ID "
	cQuery +=   "            AND T3P.T3P_TRABEV <> 'TAUTO' "
	cQuery +=   "            AND T3P.T3P_ATIVO = '1' "
	cQuery +=   "            AND C9V.C9V_NOMEVE = 'TAUTO' "
	cQuery +=   "			 AND T3P.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias &cAliasQry

	nCount := (cAliasQry)->(REGISTROS_T3P)

    If nCount > 0

		cUpdt :=  " UPDATE " + RetSQLName("T3P") + " "
        cUpdt +=  " SET T3P_TRABEV = 'TAUTO' " 
        cUpdt +=  "     WHERE R_E_C_N_O_ in ( " 
        cUpdt +=  "     SELECT T3P.R_E_C_N_O_ "
        cUpdt +=  "     FROM " + RetSQLName("T3P") +" T3P " 
        cUpdt +=  "     INNER JOIN " + RetSQLName("C9V") +  " C9V ON "  
        cUpdt +=  "         T3P.T3P_FILIAL = C9V.C9V_FILIAL "   
        cUpdt +=  "         AND T3P.T3P_BENEFI = C9V.C9V_ID "  
        cUpdt +=  "         AND C9V.C9V_NOMEVE = 'TAUTO' "
		cUpdt +=  "         AND T3P.T3P_ATIVO = '1' "
        cUpdt +=  "         AND T3P.T3P_TRABEV <> 'TAUTO' "
        cUpdt +=  "         AND T3P.D_E_L_E_T_ = ' ' ) "
		
		//"Atualizando novos registros S-1210 encontrados para Autonomos"
        If TCSQLExec (cUpdt) < 0

			MsgStop(TCSQLError(),"Erro na Execução do Update de registros S-1210 Autonomos") //"Erro na Execução do Update de registros S-1210 Autonomos"
            lRet := .F. 

		EndIf

    EndIf

	(cAliasQry)->(DbCloseArea())
	
Return(lRet)
