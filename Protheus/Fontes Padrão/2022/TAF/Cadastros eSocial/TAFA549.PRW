#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA250.CH" 

Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA549
Cadastro de Folha de Pagamento Autônomos RPA

@author Ricardo Lovrenovic Bueno
@since 20/08/2019
@version 1.0

/*/
//------------------------------------------------------------------
Function TAFA549()

	Local cFilter := " C91_ATIVO == '1' .AND. C91_NOMEVE == 'S1200' .AND. C91_TRABEV == 'TAUTO' "

	Private oBrw  := FWmBrowse():New()

	//Executa atualização dos registros que são elegí­veis para autônomos do S-1200 
	FwMsgRun(, { || AtuRegC91() }, "Atualizando Registros S-1200 Autônomos...", "Aguarde") 	//"Atualizando Registros S-1200 Autônomos.."

	If TafAtualizado() 
		TafNewBrowse( "S-1200", , , , "Cadastro de Folha de Pagamento Autonomos RPA", , 2, 2, , cFilter )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Ricardo Lovrenovic 
@since 20/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	If FindFunction("FilCpfNome") .And. GetSx3Cache("C91_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF250View('C91',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF250AUTI('C91',RECNO())" OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('C91', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA250" 			 OPERATION 8 ACCESS 0 //'Imprimir'

	EndIf

Return( aRotina ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuRegC91
Função responsável por localizar os registros que são elegíveis para
Trabalhadores Autônomos.

@return .t.

@author Ricardo Lovrenovic 
@since 22/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function AtuRegC91()

	Local cQuery    	:= ""
	Local cUpdt     	:= ""
	Local cAliasQry 	:= GetNextAlias()
	Local nCount		:= 0
	Local lRet      	:= .T.
	Local aTrabal       := {}
	Local cFil          := ""
	Local cTrabal       := ""  

	If !TAFColumnPos( "C91_TRABEV" )

		If !Isblind() 
			MsgInfo("Ambiente desatualizado (C91_TRABEV), necessário aplicação de dicionário mais atualizado.")
		EndIf

		Return(.F.)

	EndIf

	cQuery +=   " SELECT C91.C91_TRABAL AS TRABAL, C91.C91_FILIAL AS FILIAL, COUNT(C91.C91_TRABAL) AS REGISTROS_C91 "
	cQuery +=   " FROM   " + RetSQLName("C91") + " C91 " 
	cQuery +=   "    INNER JOIN " + RetSQLName("C9V") + " C9V ON " 
	cQuery +=   "            C91.C91_FILIAL = C9V.C9V_FILIAL " 
	cQuery +=   "            AND C91.C91_TRABAL = C9V.C9V_ID " 
	cQuery +=   "            AND C9V.C9V_NOMEVE = 'TAUTO' "
	cQuery +=   "            AND C91.C91_TRABEV <> 'TAUTO' "
	cQuery +=   "            AND C91.C91_MV <> '1' "
	cQuery +=   "            AND C91.C91_ATIVO = '1' "
	cQuery +=   "			 AND C91.D_E_L_E_T_ = ' ' "
	cQuery +=   " GROUP BY C91.C91_TRABAL, C91.C91_FILIAL "

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias &cAliasQry
	( cAliasQry )->( DbGoTop() )

	nCount := (cAliasQry)->(REGISTROS_C91)
	If nCount > 0
		nCount := 0
		While !(cAliasQry)->(EoF())
			    AADD(aTrabal, {(cAliasQry)->TRABAL,(cAliasQry)->FILIAL})
				nCount++
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
    
	While nCount > 0
		
		cTrabal := aTrabal[nCount][1]
		cFiL 	:= aTrabal[nCount][2]

		cUpdt :=  " UPDATE " + RetSQLName("C91") + " "
        cUpdt +=  " SET C91_TRABEV = 'TAUTO' " 
        cUpdt +=  " WHERE C91_TRABAL = '" + cTrabal + "' "
		cUpdt +=  " AND C91_FILIAL = '" + cFiL + "' "
		cUpdt +=  " AND C91_TRABEV <> 'TAUTO' "
		cUpdt +=  " AND C91_MV <> '1' "
		cUpdt +=  " AND C91_ATIVO = '1' "
		cUpdt +=  " AND D_E_L_E_T_  = ' ' "

		//"Atualizando novos registros S-1200 encontrados para Autônomo"
		If TCSQLExec (cUpdt) < 0

            MsgStop(TCSQLError(),"Erro na Execução do Update de registros S-1200 Autônomos") //"Erro na Execução do Update de registros S-1200 Autonomos"
            lRet := .F. 

		EndIf

		nCount--

    EndDo

	(cAliasQry)->(DbCloseArea())
	
Return(lRet)
