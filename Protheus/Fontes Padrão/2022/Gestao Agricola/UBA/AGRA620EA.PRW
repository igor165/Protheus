#INCLUDE "AGRA620.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} AGRA620EA
Rotina para geração da movimentação de estoque de fardões em beneficiamento
que serao encerrados automaticamente.
@author marcelo.wesan
@since 30/09/2020
@type function
/*/
Function AGRA620EA()

	Local cFiltro	:= ''
	Local cUserBenf := A655GETUNB()// Busca a unidade de beneficiamento
	Local aArea 	:= GetArea()
	Local nQtdJob   := SuperGetMv('MV_QTDJOBE', , 1) //Quantidade  de Fardoes a ser encerrados  pelo Job
	Local nCont		:= 0
	Local cQuery	:= ""
	Local cAliasQry := ""
	
	Private nPsTotal := 0
	Private aFardoes := {}
	Private aDetItens := {}
	Private aProd := {}
	Private aDetProd := {}
	Private cRotEA	 := ""
	Private cErroEA	 := ""
	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto		:= .T.

	If .not. TableInDic('NLO')  //proteção fonte
		Return .T.
	EndIf

	If nQtdJob = 0
		nQtdJob := 1
	EndIf

	dbSelectArea("DXL") //NECESSARIO PARA POSICIONAMENTO ABAIXO E NAS FUNÇÕES CHAMADAS
	dbSelectArea("NLO")

	If !IsBlind()
		Pergunte( 'AGRA620001', .T. ) //como esta no menu, add pergunte para usuario definir os parametros
	EndIf

	cFiltro += " AND DXL_STATUS='5' "

	If !Empty(mv_par01)
		cFiltro += " And DXL_CODCNJ='" + mv_par01 + "' "
	Else
		cFiltro += " And DXL_CODCNJ <> ' '"
	Endif

	If !Empty(mv_par02)
		cFiltro += " And DXL_LOCAL='" + mv_par02 + "' "
	Endif

	If !Empty(mv_par06)
		cFiltro += " And DXL_DTBEN >='" +  DTOS(mv_par06 ) + "' "
	Endif

	If !Empty(mv_par07)
		cFiltro += " And DXL_DTBEN <='" + DTOS(mv_par07 ) + "' "
	Endif

	If !Empty(mv_par08)
		cFiltro += " And DXL_SAFRA >='" + mv_par08 + "' "
	Endif

	If !Empty(mv_par09)
		cFiltro += " And DXL_SAFRA <='" + mv_par09 + "' "
	Endif

	If !Empty(mv_par10)
		cFiltro += " And DXL_PRDTOR >='" + mv_par10 + "' "
	Endif

	If !Empty(mv_par12)
		cFiltro += " And DXL_PRDTOR <='" + mv_par12 + "' "
	Endif

	If !Empty(mv_par11)
		cFiltro += " And DXL_LJPRO >='" + mv_par11 + "' "
	Endif

	If !Empty(mv_par13)
		cFiltro += " And DXL_LJPRO <='" + mv_par13 + "' "
	Endif

	If !Empty(mv_par14)
		cFiltro += " And DXL_FAZ >='" + mv_par14+ "' "
	Endif

	If !Empty(mv_par15)
		cFiltro += " And DXL_FAZ <='" + mv_par15 + "' "
	Endif

	If mv_par03 != 1
		dbSelectArea("DXL")
		if DXL->(ColumnPos('DXL_CODUNI' )) > 0
			cFiltro += " AND DXL_PSLIQU > 0 "
			cFiltro += " AND (DXL_CODROM <> ' ' OR EXISTS(SELECT DX0_CODUNI FROM " + RetSqlName('DX0') + " DX0 "
			cFiltro += " INNER JOIN " + RetSqlName('DXL') + " DXL ON "
			cFiltro += " DXL.DXL_FILIAL = '" + fwxFilial('DXL') + "' "
			cFiltro += " AND DXL.DXL_CODUNI = DX0.DX0_CODUNI  "
			cFiltro += " AND DXL.D_E_L_E_T_ = ' ' "
			cFiltro += " AND DX0.D_E_L_E_T_ = ' ' ))"
		Else
			cFiltro += " and DXL_PSLIQU > 0 and DXL_CODROM <> ' ' "
		Endif
	Endif
	//Trata Unidade de Beneficiamento
	If !Empty(cUserBenf)
		cFiltro += " AND DXL_CODUNB = '" + cUserBenf + "' "
	Endif
	//trata a filial, para encerrar somente fardos da filial atual
	If DXL->(ColumnPos('DXL_FILBEN')) > 0
		cFiltro += " AND DXL_FILBEN = '" + FWxFilial("DXI") + "' " //SOMENTE DE ONDE É BENEFICIADO
	EndIF
	//trata para não trazer fardos com erro para o dia atual
	If TableInDic('NLO')
		cFiltro += " AND NOT EXISTS ( SELECT NLO.NLO_CODFAR FROM " + RetSqlName('NLO') + " NLO "
		cFiltro += "    WHERE NLO.NLO_FILIAL = DXL_FILBEN AND NLO.NLO_SAFRA = DXL_SAFRA AND NLO.NLO_CODFAR = DXL_CODIGO "
		cFiltro += "    AND NLO.NLO_PRDTOR = DXL_PRDTOR AND NLO.NLO_LJPRO = DXL_LJPRO  "
		cFiltro += "    AND DXL_FAZ = NLO_FAZ AND NLO.D_E_L_E_T_ = ' ' AND NLO.NLO_DTENCE = '" + DTOS(dDatabase) + "' ) "
	EndIf
	
	//-------------------
	// Fardões
	//-------------------
	cAliasQry := GetNextAlias()
	cQuery := " SELECT DXL_CODIGO, DXL_CODPRO, DXL_LOCAL, DXL_PSLIQU, DXL_CODCNJ "
	cQuery += " ,DXL_LOTCTL, DXL_NMLOT, DXL_LOCLIZ, DXL_FILBEN, R_E_C_N_O_ AS RECNO "
	cQuery += " ,DXL_DTBEN, DXL_PRDTOR, DXL_LJPRO, DXL_FAZ "
	If DXL->(ColumnPos('DXL_FILBEN')) > 0
		cQuery += " ,DXL_FILBEN "
	EndIF
	cQuery += " FROM "+RetSqlName("DXL")+" DXL "
	cQuery += " WHERE DXL.DXL_FILIAL = '" + xFilial("DXL") + "' "
	cQuery +=  cFiltro
	cQuery += " AND DXL.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY  DXL_DTBEN, DXL_CODCNJ,DXL_PRDTOR, DXL_LJPRO, DXL_FAZ, DXL_CODIGO "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
	
	nCont := 0
	dbSelectArea(cAliasQry)
	While (cAliasQry)->(!Eof())
		If nCont < nQtdJob // Limita a quantidade de fardões a ser encerrados automaticamente
			aFardoes := {}
			aDetItens := {}
			aProd := {}
			aDetProd := {}
			If DXL->(ColumnPos('DXL_FILBEN')) > 0
				aAdd( aFardoes, {(cAliasQry)->DXL_CODIGO, (cAliasQry)->DXL_CODPRO, (cAliasQry)->DXL_LOCAL, (cAliasQry)->DXL_PSLIQU, '', (cAliasQry)->(RECNO), (cAliasQry)->DXL_CODCNJ, (cAliasQry)->DXL_LOTCTL, (cAliasQry)->DXL_NMLOT, (cAliasQry)->DXL_LOCLIZ, (cAliasQry)->DXL_FILBEN} )
			Else
				aAdd( aFardoes, {(cAliasQry)->DXL_CODIGO, (cAliasQry)->DXL_CODPRO, (cAliasQry)->DXL_LOCAL, (cAliasQry)->DXL_PSLIQU, '', (cAliasQry)->(RECNO), (cAliasQry)->DXL_CODCNJ} )
			Endif
			//gera os dados a serem atualizados
			AGRA620CIT((cAliasQry)->DXL_PSLIQU,aFardoes,@aDetItens,@aProd,@aDetProd)
			//grava os dados
			AGRA620GRV(, aFardoes, aDetItens, aDetProd, aProd)
		else
			Exit
		EndIf

		nCont += 1

		(cAliasQry)->( dbSkip() )

	EndDo
	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)
	
Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Definição de função padrão para o Schedule
@author  marcelo.wesan
@since   01/10/2020
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
	Local aOrd := {}
	Local aParam := {}

	aParam := {	"P"        		,;   // P= Processo, R= Relatório
				"AGRA620001"   	,;   //PERGUNTE OU PARAMDEF
				""         		,;   //ALIAS p/ relatorio
				aOrd       		,;   //Array de Ordenacao p/ relatorio
				""         		,;	 //Titulo para Relatório
			}
Return aParam

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA620GE
Função que grava erros gerados no encerramento
@author  marcelo.wesan
@since   08/10/2020
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Function AGRA620GE(aFardoes,cRotina,cErro)

	Local aArea 	:= GetArea()

	If TableInDic('NLO')
		dbSelectArea('NLO')
		NLO->(dbSetOrder(1))
		BEGIN TRANSACTION

			If RecLock('NLO',.T.)
				NLO->NLO_FILIAL := aFardoes[11]
				NLO->NLO_CODFAR := aFardoes[1]
				NLO->NLO_LOCAL  := aFardoes[3]
				NLO->NLO_DTENCE := Date()
				NLO->NLO_FUN    := cRotina
				NLO->NLO_SAFRA  := Posicione( "DXL", 1, FWxFilial("DXL") + (NLO->NLO_CODFAR), "DXL_SAFRA" )
				NLO->NLO_PRDTOR := Posicione( "DXL", 1, FWxFilial("DXL") + (NLO->NLO_CODFAR), "DXL_PRDTOR" )
				NLO->NLO_LJPRO  := Posicione( "DXL", 1, FWxFilial("DXL") + (NLO->NLO_CODFAR), "DXL_LJPRO" )
				NLO->NLO_FAZ    := Posicione( "DXL", 1, FWxFilial("DXL") + (NLO->NLO_CODFAR), "DXL_FAZ" )
				NLO->NLO_OBS    := cErro
				NLO->NLO_HRENCE := Time()
				NLO->(MsUnlock())
			Endif
		END TRANSACTION
		NLO->(dbCloseArea())
	EndIf
	RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR620LEAS
Função converte um array de log de erro para string 
@author claudineia.reinert
@since   10/12/2020
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Function AGR620LEAS(aErro)
	Local cErro := ""
	Local nCount := 0

	For nCount := 1 To Len(aErro)
		cErro += aErro[nCount] + Chr(10)
	Next nCount

Return cErro
