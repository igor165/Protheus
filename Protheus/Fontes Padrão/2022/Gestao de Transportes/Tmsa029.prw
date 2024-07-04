#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA029.CH"

Static cAliasMbw
Static oMrkBrowse
Static lCar029    := .f.
Static cGetMot    := ""
Static aVirtual   := {}
Static x1         := 0
Static x2         := 0
Static cMode029   := "L"

Static aRec       := { "16",; //-- Rec. CTe Complemento
                       "18",; //-- Rec./Desp.
                       "19",; //-- Rec. CTe Reentrega
                       "20" } //-- Rec. CTe Devolução

Static aDes       := { "17",; //-- Desp. Compl.
                       "18" } //-- Rec./Desp.
Static lTM029FIL  := ExistBlock('TM029FIL')	// Ponto de Entrada para filtrar o browse

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA029
@autor		: Eduardo Alberti
@descricao	: Atualização De Bloqueios TMS (Tabela DDU).
@since		: Dec./2014
@using		: Rotina Controle Dos Bloqueios Feitos No Módulo TMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa029()

	Local cPerg      	:= "TMSA029"
	Local oDlgMrk    	:= Nil
	Local aAlias     	:= {}
	Local aColumns   	:= {}
	Local aSeek      	:= {}
	Local cFilMbrow   	:= ""						// Recebe o Filtro da Browse
	Local cFilMbrPE		:= ""						// Filtro do Ponto de Entrada
	Local lPergunte     := .T.
	Local lTmsa029A     := .F.

	Private aRotina  := {}
	Private cCadastro 	:= OemToAnsi(STR0004) + " TMS "		//-- "Manutenção De Bloqueios"
	Private l460Auto  	:= .f. //-- Variavel Utilizada (Nativa) Do MATA460

	aRotina   	:= MenuDef()	
	
	//-- Proteção De Erro Da Rotina Caso o Dicionário Da Rotina Não Exista
	If !(AliasInDic("DDU"))
		//-- Mensagem genérica solicitando a atualização do sistema.
		MsgNextRel()
		Return()
	EndIf

	If  TmsChekSX1("TMSA029A")
		lTmsa029A:= .T.
		cPerg    := "TMSA029A"
	EndIf

	If IsInCallStack('Tmsa400')

		Pergunte( cPerg ,.f.)

		MV_PAR01 	:= 1	//-- Todos
		MV_PAR02 := dDataBase - SuperGetMV("MV_TMS29DY",.F.,0) // Dias a Retroceder a Partir Da DataBase
		MV_PAR03 := dDataBase
		MV_PAR04 := "TMSA140"
		If !lTmsa029A
			MV_PAR05 := "TMSA140"
		Else
			MV_PAR05 := ""
		EndIf
		lPergunte:= .T.

	Else
		If !(Pergunte( cPerg ,.T.))
			Return()
		EndIf
	EndIf

	// Ponto de Entrada para filtrar o browse.
	If lTM029FIL
		cFilMbrPE := ExecBlock("TM029FIL", .F., .F.)
		If Valtype(cFilMbrPE) = "C" .And. !Empty(cFilMbrPE)
			cFilMbrow := cFilMbrPE
		EndIf
	EndIf

	//----------------------------------------------------------
	//-- Retorna as colunas para o preenchimento da FWMBrowse
	//----------------------------------------------------------
	aAlias      := TmMapExcQr(,,lPergunte,lTmsa029A)
	cAliasMbw   := aAlias[1]
	aColumns    := aAlias[2]
	
	//----------------------------------------------------------
	//-- Insere Indice De Busca Por Rotinas
	//----------------------------------------------------------
	Aadd(aSeek,{STR0005	, {{"","C",20,0, "DDU_ROTINA + DDU_CODIGO",STR0005}}, 1, .T. } ) // "Rotina + Código"
	Aadd(aSeek,{STR0006	, {{"","C",10,0, "DDU_CODIGO"             ,STR0006}}, 2, .T. } ) // "Código"

	(cAliasMbw)->(DbGoTop())
	If !(cAliasMbw)->(Eof())

		//------------------------------------------
		//-- Criação da FWMBrowse
		//------------------------------------------
		oMrkBrowse:= FWMarkBrowse():New()

		oMrkBrowse:AddLegend("DDU_STATUS == '1'", "RED"    ,STR0007 ,"DDU_STATUS")	// "Bloqueado"
		oMrkBrowse:AddLegend("DDU_STATUS == '2'", "GREEN"  ,STR0008 ,"DDU_STATUS")	// "Liberado"
		oMrkBrowse:AddLegend("DDU_STATUS == '3'", "YELLOW" ,STR0052 ,"DDU_STATUS")	// "Rejeitado" 

		oMrkBrowse:SetFieldMark("DDU_OK")
		oMrkBrowse:SetOwner(oDlgMrk)
		oMrkBrowse:SetAlias(cAliasMbw)
		oMrkBrowse:SetMenuDef("TmsA029")

		oMrkBrowse:SetTemporary(.T.)
		oMrkBrowse:SetSeek(,aSeek)

		oMrkBrowse:bMark    := {|| TmsDDUMk(cAliasMbw)}
		oMrkBrowse:bAllMark := {|| TmsDDUIn(cAliasMbw)}
		oMrkBrowse:SetDescription( OemToAnsi(STR0004) + " TMS " ) // "Manutenção De Bloqueios"
		oMrkBrowse:SetColumns(aColumns)
		oMrkBrowse:SetFilterDefault(cFilMbrow)  //Filtro
		oMrkBrowse:Activate()

	Else
		Help('',1,'TMSA02901',, STR0034 ,1,0) //-- "Não Existem Registros Para Exibição. Verifique Parâmetros Da Rotina."
	EndIf

	If !Empty (cAliasMbw)
		dbSelectArea(cAliasMbw)
		dbCloseArea()
		cAliasMbw := ""
	EndIf

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@autor		: Eduardo Alberti
@descricao	: Funcao Para Montagem Do Menu Funcional Padrao Protheus
@since		: Dec./2014
@using		: Rotina Controle Dos Bloqueios Feitos No Módulo TMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef(cTipo)

	Local aArea      	:= GetArea()
	Private aRotina		:= Iif( Type('aRotina') == 'A', aClone( aRotina ), {} )
	Default cTipo  := "P"

	If cTipo == "P"

		ADD OPTION aRotina TITLE STR0002    ACTION 'VIEWDEF.TMSA029' OPERATION 2 ACCESS 0 DISABLE MENU	// Visualizar
		ADD OPTION aRotina TITLE STR0003    ACTION 'Tmsa029Leg()'    OPERATION 2 ACCESS 0 DISABLE MENU	// Legenda
		ADD OPTION aRotina TITLE STR0010    ACTION 'Tmsa029Lib("L")' OPERATION 3 ACCESS 0 DISABLE MENU	// Liberar
		ADD OPTION aRotina TITLE STR0053    ACTION 'Tmsa029Lib("R")' OPERATION 4 ACCESS 0 DISABLE MENU	// Rejeitar
		ADD OPTION aRotina TITLE STR0054    ACTION 'Tmsa029Ref'      OPERATION 3 ACCESS 0 DISABLE MENU	// Parâmetros - Executa Novos Parametros
		ADD OPTION aRotina TITLE STR0082    ACTION 'Tmsa029Atz'      OPERATION 8 ACCESS 0 DISABLE MENU	// Atualizar

		//--ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//--³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
		//--ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("TMS29MNU")
			ExecBlock("TMS29MNU",.F.,.F.)
		EndIf
	EndIf

	RestArea(aArea)

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}TmMapExcQr
Executa Query Pesquisando Acessos Do Usuario Para Visualização Da Tela Manutenção
@author Eduardo Alberti
@since  26/11/2014
@version 11
/*/
//-------------------------------------------------------------------
Static Function TmMapExcQr( cAliasMbw , aParLib, lTela, lTmsa029A ) 

	Local aArea      := GetArea()
	Local aStru      := {}
	Local aColumns   := {}	//-- Array com as colunas a serem apresentadas
	Local aRestrict  := {"DDU_DETALH","D_E_L_E_T_","R_E_C_N_O_","R_E_C_D_E_L_"}
	Local nX         := 0
	Local aCampos    := {}
	Local cArqTrab   := ""
	Local cQuery     := ""
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local cEnter     := Chr(13) + Chr(10) // Mantem Formatação Da Query Para Auxiliar No Debug Do Desenvolvedor
	Local lValor     := DDU->(ColumnPos("DDU_VLRDES")) > 0
	Local lDDUData   := DDU->(ColumnPos("DDU_DATA")) > 0
	Local oTemp		 := Nil
	Local cCodRot    := AllTrim(MV_PAR04)
	Local cCodBloq   := ""

	Default cAliasMbw := ""
	Default aParLib   := {}
	Default lTela     := .F.
	Default lTmsa029A := .F.

	If lTmsa029A .And. lTela
		If  !Empty(MV_PAR04)
			cCodRot := TMS029Par(AllTrim(MV_PAR04)) 
		EndIf
		If !Empty(MV_PAR05)
			cCodBloq := TMS029Par(AllTrim(MV_PAR05)) 
		EndIf
	EndIf

	cQuery += " SELECT          DDU.DDU_ROTINA, "                                                                                                         + cEnter
	cQuery += " 				CASE "                                                                                                                    + cEnter
	cQuery += "             	WHEN DDX.DDX_DESCRS <> '" + Space(TamSX3("DDX_DESCRS")[1]) + "' THEN DDX.DDX_DESCRS "                                     + cEnter
	cQuery += "             	ELSE DDX.DDX_DESCR "                                                                                                      + cEnter
	cQuery += "             	END AS DDX_DESCRS, "                                                                                                      + cEnter
	cQuery += "             	DDU.DDU_TIPBLQ,DDV.DDV_DESCB, DDU.DDU_CHAVE, DDU.DDU_FILORI,DDU.DDU_CODIGO, DDU.DDU_NIVBLQ,DDU.DDU_USRBLQ,DDU.DDU_NOMBLQ,DDU.DDU_DATBLQ, "     + cEnter
	cQuery += "             	DDU.DDU_HORBLQ,DDU.DDU_USRLIB,DDU.DDU_NOMLIB,DDU.DDU_DATLIB,DDU.DDU_HORLIB,DDU.DDU_MTVLIB AS DDU_MTVLIB,DDU.DDU_STATUS, " + cEnter
	
	//-- Verifica Se Existe Campo De Valor
	If lValor
		cQuery += "             DDU.DDU_VLRDES, DDU.DDU_VLRREC, "                                                                                         + cEnter
	EndIf
	If lDDUData
		cQuery += "             DDU.DDU_DATA,                   "                                                                                         + cEnter
	EndIf
	
	cQuery += "             	DDU.R_E_C_N_O_ AS DDUREC "                                                                                                + cEnter	
	cQuery += " FROM        " +	RetSqlName("DDU") + " DDU "                                                                                               + cEnter //-- Registros De Bloqueios TMS
	cQuery += " INNER JOIN  	" +	RetSqlName("DDX") + " DDX "                                                                                           + cEnter //-- Rotinas X Tip.Lib X Niveis
	cQuery += " ON          	DDX.DDX_FILIAL  =       '" + xFilial("DDX") + "' "                                                                        + cEnter
	cQuery += " AND         	DDX.DDX_ROTINA  =       DDU.DDU_ROTINA "                                                                                  + cEnter
	cQuery += " AND         	DDX.D_E_L_E_T_  =       ' ' "                                                                                             + cEnter
	cQuery += " INNER JOIN 	" +	RetSqlName("DDV") + " DDV "                                                                                               + cEnter //-- Rotinas X Bloqueios TMS
	cQuery += " ON              DDV.DDV_FILIAL  =       '" + xFilial("DDV") + "' "                                                                        + cEnter
	cQuery += " AND 			DDV.DDV_ROTINA  =       DDU.DDU_ROTINA "                                                                                  + cEnter
	cQuery += " AND 			DDV.DDV_CODBLQ  =       DDU.DDU_TIPBLQ "                                                                                  + cEnter
	cQuery += " AND 			DDV.D_E_L_E_T_  =       ' ' "                                                                                             + cEnter
	cQuery += " WHERE       	DDU.DDU_FILIAL  =       '" + xFilial("DDU") + "' "                                                                        + cEnter
	If lTmsa029A
		If !Empty(cCodRot)
			If lTela
				cQuery += " AND    	DDU.DDU_ROTINA  IN " + cCodRot   + " "   																		 + cEnter
			Else
				cQuery += " AND    	DDU.DDU_ROTINA  = '" + cCodRot   + "' "   																		 + cEnter
			EndIf
		EndIf
		If !Empty(cCodBloq)
			cQuery += " AND     DDU.DDU_TIPBLQ  IN " + cCodBloq + " "   																		  + cEnter	
		EndIf
	Else
		cQuery += " AND         	DDU.DDU_ROTINA  BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "                                                   + cEnter
	EndIf
	cQuery += " AND         	DDU.DDU_DATBLQ  BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' "                                           + cEnter

	//-- Filtra Pelas Variáveis aParLib Caso Sejam Informadas
	//-- aParLib -> { 'TMSA360',DT2->DT2_TIPOCO,cFilDoc,'DUA','1',cChvRD,cViagem}
	If !Empty(aParLib)
	
		cQuery += " AND         DDU.DDU_TIPBLQ  =  '" + aParLib[2] + "' " + cEnter 
		cQuery += " AND         DDU.DDU_ALIAS   =  '" + aParLib[4] + "' " + cEnter
		cQuery += " AND         DDU.DDU_INDEX   =  '" + aParLib[5] + "' " + cEnter
		cQuery += " AND         DDU.DDU_CHAVE   =  '" + aParLib[6] + "' " + cEnter
		
	EndIf

	//-- Define Status Do Registro
	If MV_PAR01 == 2
		cQuery += " AND         DDU.DDU_STATUS =  '1' " + cEnter //-- Bloqueados
	ElseIf	MV_PAR01 == 3
		cQuery += " AND         DDU.DDU_STATUS =  '2' " + cEnter //-- Em Aberto
	ElseIf	MV_PAR01 == 4
		cQuery += " AND         DDU.DDU_STATUS =  '3' " + cEnter //-- Rejeitados	
	EndIf

	cQuery += " AND             DDU.D_E_L_E_T_ =  ' ' " + cEnter

	cQuery += " AND            ( EXISTS (   SELECT      0 "                                                                                           + cEnter
	cQuery += "                             FROM        " +	RetSqlName("DDV") + " DDVS1 "                                                             + cEnter //-- Rotinas X Bloqueios
	cQuery += "                             INNER JOIN  " +	RetSqlName("DDX") + " DDXS1 "                                                             + cEnter //-- Regras De Liberação Por Rotina
	cQuery += "                             ON          DDXS1.DDX_FILIAL   =  '" + xFilial("DDX") + "' "                                              + cEnter
	cQuery += "                             AND         DDXS1.DDX_ROTINA   =  DDVS1.DDV_ROTINA "                                                      + cEnter
	cQuery += "                             AND         DDXS1.D_E_L_E_T_   =  ' ' "                                                                   + cEnter
	cQuery += "                             INNER JOIN  " +	RetSqlName("DDY") + " DDYS1 "                                                             + cEnter //-- Aprovadores TMS
	cQuery += "                             ON          DDYS1.DDY_FILIAL   =  '" + xFilial("DDY") + "' "                                              + cEnter 
	cQuery += "                             AND         DDYS1.DDY_USUARI   =  '" + __cUserId + "' "                                                   + cEnter
	cQuery += "                             AND         DDYS1.DDY_ROTINA   =  DDU.DDU_ROTINA "                                                        + cEnter
	cQuery += "                             AND         DDYS1.DDY_ROTINA   =  DDVS1.DDV_ROTINA "                                                      + cEnter
	cQuery += "                             AND         DDYS1.DDY_STATUS   =  '1' "                                                                   + cEnter
	cQuery += "                             WHERE       DDVS1.DDV_FILIAL   =       '" + xFilial("DDV") + "' "                                         + cEnter 
	cQuery += "                             AND         ( (DDXS1.DDX_TPLIB   =  '2' AND DDYS1.DDY_TIPLIB = '3')	"									  + cEnter 
	cQuery += "                                             OR (DDXS1.DDX_TPLIB   =  '1' )  "     													  + cEnter 											
	cQuery += "                                             OR 	((DDYS1.DDY_NIVEL =  DDU.DDU_NIVBLQ) AND NOT EXISTS ( SELECT  0 "                            + cEnter 
	cQuery += "                                                                                                FROM    " +	RetSqlName("DDU") + " DDUX "              		+ cEnter //-- Registros De Bloqueios TMS 
	cQuery += "                                                                                                WHERE   DDUX.DDU_FILIAL =  '" + xFilial("DDU") + "' " 		+ cEnter 
	cQuery += "                                                                                                AND     DDUX.DDU_ROTINA =  DDU.DDU_ROTINA "           		+ cEnter
	cQuery += "                                                                                                AND     DDUX.DDU_CHAVE  =  DDU.DDU_CHAVE "            		+ cEnter
	cQuery += "                                                                                                AND     DDUX.DDU_TIPBLQ =  DDU.DDU_TIPBLQ "           		+ cEnter
	cQuery += "                                                                                                AND     DDUX.DDU_NIVBLQ <  DDU.DDU_NIVBLQ "           		+ cEnter
	cQuery += "                                                                                                AND     DDUX.DDU_INDEX  =  DDU.DDU_INDEX "            		+ cEnter
	cQuery += "                                                                                                AND    (DDUX.DDU_STATUS =  '1' OR DDUX.DDU_STATUS =  '3') "	+ cEnter
	cQuery += "                                                                                                AND     DDUX.D_E_L_E_T_ =  ' ' ) ) )"                  		+ cEnter
	cQuery += "                             AND         DDYS1.DDY_TPBLQ    LIKE    ('%' || DDV.DDV_CODBLQ || '%') "              	                                 		+ cEnter 
	cQuery += "                             AND         DDYS1.D_E_L_E_T_   =       ' ' "                                                                             		+ cEnter	
	If lTmsa029A
		If !Empty(cCodRot)
			If lTela
				cQuery += "                         AND         DDVS1.DDV_ROTINA   IN " + cCodRot + "  "                           	                        					+ cEnter 
			Else
				cQuery += "                         AND         DDVS1.DDV_ROTINA   = '" + cCodRot + "'  "                           	                        					+ cEnter 
			EndIf
		EndIf
		If !Empty(cCodBloq)
			cQuery += "                         AND         DDVS1.DDV_CODBLQ  IN " + cCodBloq + " "                           	                       					 	+ cEnter 
		EndIf
	Else
		cQuery += "                         AND         DDVS1.DDV_ROTINA   BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "                                       		+ cEnter 
	EndIf
	cQuery += "                             AND         DDVS1.DDV_CODBLQ   =       DDU.DDU_TIPBLQ "                                                                  		+ cEnter

	//-- Trata Dicionário Para Liberação De Registros Por Alçada De Valor
	If lValor 
		cQuery += "                          AND         DDVS1.DDV_USEVAL   <>      '1' "                                                                             		+ cEnter //-- Diferente De Controle Por Valor
	EndIf	

	cQuery += "                             AND         DDVS1.D_E_L_E_T_   =       ' ' "                                                                             		+ cEnter
	cQuery += "                         ) "                                                                                                                          		+ cEnter

	//-- Trata Dicionário Para Liberação De Registros Por Alçada De Valor
	If AliasInDic("DJP") .And. lValor

		cQuery += "                  OR "                                                                                                                                + cEnter
		cQuery += "                  EXISTS (   SELECT      0 "                                                    + cEnter
		cQuery += "                             FROM        " +	RetSqlName("DDV") + " DDVS2 "                      + cEnter //-- Rotinas X Bloqueios
		cQuery += "                             INNER JOIN  " +	RetSqlName("DDX") + " DDXS2 "                      + cEnter //-- Regras De Liberação Por Rotina
		cQuery += "                             ON          DDXS2.DDX_FILIAL   =       '" + xFilial("DDX") + "' "  + cEnter
		cQuery += "                             AND         DDXS2.DDX_ROTINA   =       DDVS2.DDV_ROTINA "          + cEnter
		cQuery += "                             AND         DDXS2.D_E_L_E_T_   =       ' ' "                       + cEnter
		cQuery += "                             INNER JOIN  " +	RetSqlName("DDY") + " DDYS2 "                      + cEnter //-- Aprovadores TMS
		cQuery += "                             ON          DDYS2.DDY_FILIAL   =       '" + xFilial("DDY") + "' "  + cEnter 
		cQuery += "                             AND         DDYS2.DDY_USUARI   =       '" + __cUserId + "' "       + cEnter
		cQuery += "                             AND         DDYS2.DDY_ROTINA   =       DDU.DDU_ROTINA "            + cEnter
		cQuery += "                             AND         DDYS2.DDY_ROTINA   =       DDVS2.DDV_ROTINA "          + cEnter 
		cQuery += "                             AND         DDYS2.DDY_STATUS   =       '1' "                       + cEnter
		cQuery += "                             AND         DDYS2.DDY_TPBLQ    LIKE    ('%' || DDV.DDV_CODBLQ || '%') " + cEnter 
		cQuery += "                             AND         DDYS2.D_E_L_E_T_   =       ' ' "                       + cEnter
		cQuery += "                             INNER JOIN  " +	RetSqlName("DJP") + " DJP "                        + cEnter //-- Limites De Liberação Por Usuário
		cQuery += "                             ON          DJP.DJP_FILIAL     =       '" + xFilial("DJP") + "' "  + cEnter 
		cQuery += "                             AND         DJP.DJP_USUARI     =       '" + __cUserId + "' "       + cEnter
		cQuery += "                             AND         DJP.DJP_ROTINA     =       DDU.DDU_ROTINA "            + cEnter
		cQuery += "                             AND         DJP.DJP_TPBLQ      =       DDU.DDU_TIPBLQ "            + cEnter
		cQuery += "                             AND         DJP.DJP_LIMITE     >=      ( CASE "                    + cEnter
		cQuery += "                                                                    WHEN DDU.DDU_VLRDES >= DDU.DDU_VLRREC " + cEnter  //-- Campos Contendo o Valor Que Provocou o Bloqueio 
		cQuery += "                                                                    THEN DDU.DDU_VLRDES "       + cEnter
		cQuery += "                                                                    ELSE DDU.DDU_VLRREC "       + cEnter
		cQuery += "                                                                    END )  "                    + cEnter
		cQuery += "                             AND         DJP.D_E_L_E_T_     =       ' ' "                       + cEnter
		cQuery += "                             WHERE       DDVS2.DDV_FILIAL   =       '" + xFilial("DDV") + "' "  + cEnter 
		If lTmsa029A
			If !Empty(cCodRot)
				If lTela
					cQuery += "                             AND         DDVS2.DDV_ROTINA   IN " + cCodRot + " " + cEnter 
				Else
					cQuery += "                             AND         DDVS2.DDV_ROTINA   = '" + cCodRot + "' " + cEnter 
				EndIf
			EndIf
			If !Empty(cCodBloq)
				cQuery += "                             AND         DDVS2.DDV_CODBLQ  IN " + cCodBloq + " " + cEnter 
			EndIf
		Else
			cQuery += "                             AND         DDVS2.DDV_ROTINA   BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' " + cEnter 
		EndIf
		cQuery += "                             AND         DDVS2.DDV_CODBLQ   =       DDU.DDU_TIPBLQ "            + cEnter
		cQuery += "                             AND         DDVS2.DDV_USEVAL   =       '1' "                       + cEnter //-- Controla Por Valor
		cQuery += "                             AND         DDVS2.D_E_L_E_T_   =       ' ' "                       + cEnter
		cQuery += "                         ) "                                                                    + cEnter

	EndIf

	cQuery += "                ) "                                                                             + cEnter

	If lTela
		cQuery	+= " AND	( EXISTS " 
		cQuery	+= "			( SELECT 0 FROM" + RetSqlName("DDY") + " DDYNIVEL "
		cQuery	+= "				WHERE DDYNIVEL.DDY_FILIAL 	= '" + xFilial("DDY") + "' "
		cQuery	+= "					AND DDYNIVEL.DDY_TPBLQ    LIKE    ('%' || DDV.DDV_CODBLQ || '%') "
		cQuery	+= "					AND DDYNIVEL.DDY_STATUS = '1' "
		cQuery	+= "					AND DDYNIVEL.DDY_USUARI = '" + __cUserId + "' "
		cQuery	+= "					AND ( ( DDYNIVEL.DDY_TIPLIB IN ('1','3') ) "
		cQuery	+= " 						OR  ( DDYNIVEL.DDY_TIPLIB = '2' " 
		cQuery	+= "								AND DDYNIVEL.DDY_USUARI = '" + __cUserId + "' "
		cQuery	+= "								AND DDYNIVEL.DDY_NIVEL = DDU.DDU_NIVBLQ ) ) "
		cQuery	+= "					AND DDYNIVEL.D_E_L_E_T_ = '' )  "
		cQuery	+= "		) "
	EndIf

	cQuery := ChangeQuery(cQuery)

	//-- Executa Query
	Processa( {|| Eval(bQuery)}, STR0011+ "...", STR0012 + "...",.F.) // Aguarde... Consultando...

	aEval(DDU->(dbStruct()),{|e| If(e[2] != "C" .And. Alltrim(e[1]) $ Upper(cQuery) , TCSetField(cAliasT,e[1],e[2],e[3],e[4]),Nil)})

	//-- Formata Campo DDU.R_E_C_N_O_
	TcSetField(cAliasT,"DDUREC","N",16,0)

	//-- Le Estrutura Da Query
	aCampos := (cAliasT)->(DbStruct())

	Aadd(aStru, {"DDU_OK","C",2,0}) //-- Campo Para Marcação

	//-- Gera Vetor Estrutura Do Browse  
	For nX := 1 To Len(aCampos)
		If ExistCpo("SX3",aCampos[nX,1] ,2 , , .F.)
			If aScan(aRestrict,aCampos[nX,1]) == 0
				aAdd(aStru, { aCampos[nX,1] ,GetSX3Cache(aCampos[nX,1],'X3_TIPO') ,GetSX3Cache(aCampos[nX,1],'X3_TAMANHO') ,GetSX3Cache(aCampos[nX,1],'X3_DECIMAL')  })  //Campo, Tipo, Tamamho, Decimal
			EndIf
		EndIf	
	Next nX

	//-- Adiciona Campos Não Existentes No Dicionário
	aAdd(aStru, {"DDUREC","N",16,0})

	//-- Verifica Se é Criação Do Arquivo Ou Somente Refresh
	If Empty(cAliasMbw)

		cArqTrab	:= GetNextAlias()
		
		oTemp	:= FwTemporaryTable():New(cArqTrab)
		oTemp:SetFields( aStru )
		oTemp:AddIndex("01", {"DDU_ROTINA","DDU_CODIGO" } )
		oTemp:AddIndex("02", {"DDU_CODIGO" } )
		oTemp:Create()
		
	Else
	
		//-- Limpa Dados Antigos Para Novo Append
		DbSelectArea(cAliasMbw)
		Zap //-- Limpa Temporario
		cArqTrab := cAliasMbw 

	EndIf	

	//--------------------------------------------------------------------------
	//-- Appenda Arquivo Temporário Da Query Para Arquivo Físico
	//--------------------------------------------------------------------------
	DbSelectArea(cAliasT)
	(cAliasT)->(DbGoTop())

	DbSelectArea(cArqTrab)
	Append From &(cAliasT)

	//-- Posiciona no primeiro registro do temporario
	DbSelectArea(cArqTrab)
	DbGotop()

	//-- Executa Somente Na Primeira Montagem Da Tela
	If Empty(cAliasMbw)
	
		DbSetOrder(1)

		//--Define as colunas a serem apresentadas na FWMarkBrowse
		For nX := 1 To Len(aStru)
	
			If ExistCpo("SX3",aStru[nX,1] ,2 , , .F.)

				cTab := SubStr(aStru[nX][1],1,At("_",aStru[nX][1]) -1)
	
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
				aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
				aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
				aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
				aColumns[Len(aColumns)]:SetPicture(PesqPict(cTab,aStru[nX][1]))
	
			EndIf
		Next nX
	
		//-- Limpa Variavel Para Reutilização
		aStru := {}
	
		//-- Vetor De Campos Fora Do Dicionario
		aAdd(aStru,{"DDUREC","DDUREC",16,0,"999,999,999,999"})
	
		//-- Inclui Na Estrutura Campos Fora Do Dicionário
		For nX := 1 To Len(aStru)
	
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(aStru[nX][2])
			aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
			aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
			aColumns[Len(aColumns)]:SetPicture(aStru[nX][5])
	
		Next nX

	EndIf

	//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return({cArqTrab,aColumns})

//-------------------------------------------------------------------
/*/{Protheus.doc}Tmsa029Leg
@descricao	: Legenda
@author Eduardo Alberti
@since  Dec/2014
@version 11
/*/
//-------------------------------------------------------------------
Function Tmsa029Leg()

	Local aLegenda  := {}
	Local cTitulo   := STR0014 //  "Legenda De Bloqueios"

	AADD(aLegenda,{"BR_VERDE"  		, STR0008	})	// "Liberado"
	AADD(aLegenda,{"BR_VERMELHO" 	, STR0007	})	// "Bloqueado"
	AADD(aLegenda,{"BR_AMARELO" 	, STR0052	})	// "Rejeitado"

	BrwLegenda(cTitulo, STR0014 , aLegenda) // "Legenda De Bloqueios"

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDUMk
Marcacao de um registro
@author Totvs
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsDDUMk(cAliasTRB)

	Local lRet		:= .T.
	Local cMarca	:= oMrkBrowse:cMark
	Local aArea   	:= GetArea()
	Local nRec    	:= (cAliasTRB)->(Recno())
	Local nSeq    	:= 0
	Local cChave  	:= ""
	Local aAreaDDU	:=DDU->(GetArea())

	If (cAliasTRB)->DDU_OK == cMarca .And. (cAliasTRB)->DDU_NIVBLQ == 2
		
		DDU->( DbSetOrder( 1 ) ) //DDU_FILIAL+DDU_ROTINA+DDU_CHAVE+DDU_TIPBLQ+STR(DDU_NIVBLQ)                                                                                                      
		If DDU->(DbSeek( xFilial('DDU') + (cAliasTRB)->DDU_ROTINA + (cAliasTRB)->DDU_CHAVE + (cAliasTRB)->DDU_TIPBLQ + "1")) .And. Empty(DDU->DDU_DATLIB)
			Help( ,,ProcName(),, STR0087 , 1, 0)	// "Necessário a liberação do nível 1 para liberar o nível 2"  
			RecLock(cAliasTRB,.f.)
			(cAliasTRB)->DDU_OK := Space(Len((cAliasTRB)->DDU_OK))
			(cAliasTRB)->(MsUnlock())
			lRet := .F.
		EndIf
	EndIf
	//-- Impede Marcação Registros Já Liberados
	If lRet .And. (cAliasTRB)->DDU_OK == cMarca .And. (cAliasTRB)->DDU_STATUS == '2'

		Help( ,,ProcName(),, STR0015 , 1, 0)	// "Registro Já Liberado!"

		RecLock(cAliasTRB,.f.)
		(cAliasTRB)->DDU_OK := Space(Len((cAliasTRB)->DDU_OK))
		(cAliasTRB)->(MsUnlock())	

	ElseIf lRet
		//---------------------------------------------------------------------
		//--  Bloco Para Impedir Que Seja Selecionado Um Nivel Superior
		//--  Sem Liberação Do Nivel Inferior
		//---------------------------------------------------------------------
		nSeq   :=	(cAliasTRB)->DDU_NIVBLQ
		cChave := 	(cAliasTRB)->DDU_ROTINA +;
			(cAliasTRB)->DDU_FILORI +;
			(cAliasTRB)->DDU_CODIGO +;
			(cAliasTRB)->DDU_TIPBLQ

		If (cAliasTRB)->DDU_OK == cMarca  //-- Marcou

			//-- Valida Se Nivel Pode Ser Liberado
			DbSelectArea(cAliasTRB)
			(cAliasTRB)->(DbGoTop())
			While !(cAliasTRB)->(Eof())

				If cChave == 	(cAliasTRB)->DDU_ROTINA +;
						(cAliasTRB)->DDU_FILORI +;
						(cAliasTRB)->DDU_CODIGO +;
						(cAliasTRB)->DDU_TIPBLQ

					If (cAliasTRB)->DDU_OK <> cMarca .And. (cAliasTRB)->DDU_NIVBLQ < nSeq .And. (cAliasTRB)->DDU_STATUS <> '2'
						Help( ,,ProcName(),, STR0030 , 1, 0)	// "Selecione o Nível Inferior Do Bloqueio!"
						lRet := .f.
						Exit
					EndIf
				EndIf

				DbSelectArea(cAliasTRB)
				(cAliasTRB)->(DbSkip())
			EndDo

			If !lRet

				//-- Reposiciona No Registro
				(cAliasTRB)->(DbGoTo(nRec))

				RecLock(cAliasTRB,.f.)
				(cAliasTRB)->DDU_OK := Space(Len((cAliasTRB)->DDU_OK))
				(cAliasTRB)->(MsUnlock())

			EndIf

		Else //-- Desmarcou

			//---------------------------------------------------------------------
			//--  Se Desmarcar Um Nivel, Todos Niveis Inferiores São Desmarcados
			//--  Evitando Liberar Um Nivel Superior Antes Do Inferior.
			//---------------------------------------------------------------------
			DbSelectArea(cAliasTRB)
			(cAliasTRB)->(DbGoTop())
			While !(cAliasTRB)->(Eof())

				If cChave == 	(cAliasTRB)->DDU_ROTINA +;
						(cAliasTRB)->DDU_FILORI +;
						(cAliasTRB)->DDU_CODIGO +;
						(cAliasTRB)->DDU_TIPBLQ

					If (cAliasTRB)->DDU_NIVBLQ > nSeq .And. (cAliasTRB)->DDU_STATUS <> '2'
						RecLock(cAliasTRB,.f.)
						(cAliasTRB)->DDU_OK := Space(Len((cAliasTRB)->DDU_OK))
						(cAliasTRB)->(MsUnlock())
					EndIf
				EndIf

				DbSelectArea(cAliasTRB)
				(cAliasTRB)->(DbSkip())
			EndDo
		EndIf
	EndIf

	//-- Reposiciona No Registro
	(cAliasTRB)->(DbGoTo(nRec))

	oMrkBrowse:oBrowse:Refresh()

	RestArea(aAreaDDU)
	RestArea(aArea)
	
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDUIn
Marcacao de vários registros
@author Totvs
@since 08/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsDDUIn(cAliasTRB)

	Local nReg		:= (cAliasTRB)->(Recno())
	Local cMarca	:= oMrkBrowse:cMark
	Local cNewMk  := ""

	DbSelectArea(cAliasTRB)
	DbGoTop()
	While !(cAliasTRB)->(Eof())
		If (cAliasTRB)->DDU_STATUS <> '2'
			cNewMk := Iif(Empty((cAliasTRB)->DDU_OK),cMarca,Space(Len((cAliasTRB)->DDU_OK)))
			Exit
		EndIf
		(cAliasTRB)->(dbSkip())
	Enddo

	DbSelectArea(cAliasTRB)
	DbGoTop()
	While !(cAliasTRB)->(Eof())
		If (cAliasTRB)->(MsRLock())
			If (cAliasTRB)->DDU_STATUS <> '2'
				(cAliasTRB)->DDU_OK := cNewMk
			EndIf
		Endif
		(cAliasTRB)->(dbSkip())
	Enddo

	(cAliasTRB)->(dbGoto(nReg))

	oMrkBrowse:oBrowse:Refresh(.t.)

Return .T.
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Lib
@autor		: Eduardo Alberti
@descricao	: Libera Bloqueios Da Tabela DDU
@since		: Dec./2014
@using		: Atualização De Bloqueios TMS (Tabela DDU).
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa029Lib(cModLib,aParLib)

	Local aArea     := GetArea()
	Local cMarca    := Iif( Empty(aParLib) , oMrkBrowse:cMark , "" )
	Local nCount    := 0
	Local lRet      := .t.
	Local aButtons  := {} 	//-- Recebe os Botões
	Local aAreaAnt  := {}
	
	Default cModLib := "L"  //-- Liberação
	Default aParLib := {}   //-- Parametros De Liberação Automática

	cMode029:= cModLib
	cGetMot := Space(TamSX3("DDU_MTVLIB")[1])
	
	//-- Verifica Se Liberação é Interfaceada Ou Automática
	If Empty(aParLib)

		//-- Inicializa Controle Transacional
		Begin Transaction
	
			DbSelectArea(cAliasMbw)
			(cAliasMbw)->(DbGoTop())
	
			While !(cAliasMbw)->(Eof())
	
				If (cAliasMbw)->DDU_OK == cMarca
	
					nCount  ++ // Incremeta Contador De Registros
	
					// Botões Para V11 
					aButtons := {;
								 {.F.,Nil},;			//-- 01 - Copiar
								 {.F.,Nil},;			//-- 02 - Recortar
								 {.F.,Nil},;			//-- 03 - Colar
								 {.F.,Nil},;			//-- 04 - Calculadora
								 {.F.,Nil},;			//-- 05 - Spool
								 {.F.,Nil},;			//-- 06 - Imprimir
								 Iif( cMode029 <> 'R', {.T.,STR0010} , {.T.,STR0053} ),;		//-- 07 - Liberar / Rejeitar
								 {.T.,STR0039},;		//-- 08 - Cancelar // Fechar
								 {.F.,Nil},;			//-- 09 - WalkTrhough
								 {.F.,Nil},;			//-- 10 - Ambiente
								 {.F.,Nil},;			//-- 11 - Mashup
								 {.F.,Nil},;			//-- 12 - Help
								 {.F.,Nil},;			//-- 13 - Formulário HTML
								 {.F.,Nil}}			//-- 14 - ECM
			
					// Executa a View para aprovação	 
					//-- FWExecView(cTitulo   , cPrograma, nOperation           , oDlg, bCloseOnOk, bOk      , nPercReducao ,aEnableButtons            , bCancel )
					aAreaAnt:=GetArea()
					If ( FWExecView(ProcName(),'TMSA029' ,MODEL_OPERATION_UPDATE,     , { || .T. },{ || .T. },Nil           ,aButtons,{ || .T. }) == 0 )
					EndIf
					RestArea(aAreaAnt)

				EndIf
	
				DbSelectArea(cAliasMbw)
				(cAliasMbw)->(DbSkip())
			EndDo
	
		//-- Finaliza Controle Transacional
		End Transaction
	
		If nCount == 0
			Help( ,, ProcName(),, STR0029 , 1, 0) // "Marque os itens e confirme para efetuar a liberação"
		EndIf
	
		//-- Atualiza FWMarkBrowse Conforme Registros Liberados
		oMrkBrowse:Refresh()
	Else //-- Rotina Automática De Liberação Sem Interface Com Usuário
	
		lRet := Tmsa029Aut(cModLib,aParLib)
	
	EndIf
	
	RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Obj
@autor		: Eduardo Alberti
@descricao	: Verifica Se Registro da Tabela DDU Está Totalmente Liberada e Atualiza o Objeto Do Bloqueio
@since		: Jan./2015
@using		: Atualização De Bloqueios TMS (Tabela DDU).
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa029Obj(cAliasObj,cChave,lLibAut)

	Local aArea   		:= GetArea()
	Local lRet			:= .f.
	Local cQuery  		:= ""
	Local cAliasTMP		:= GetNextAlias()
	Local cAliasTMP1	:= ""
	Local cChaveObj		:= ""
	Local cTipBlq		:= "'RR', 'CR'"   //RRE e Incompatibilidade de Produtos
	Local lTM040Lib		:= ExistBlock("TM040LIB")
	Local cCodUsr		:= RetCodUsr()
	Local aAreaAnt      := {}
	
	Default cAliasObj   := ''
	Default cChave      := ''
	Default lLibAut     := .F.

	cAliasObj   := PadR(cAliasObj,TamSX3("DDU_ALIAS")[1])
	cChave      := PadR(cChave   ,TamSX3("DDU_CHAVE")[1])

	// Determina Se Existe o Registro e Se Está Liberado
	cQuery := " SELECT      COUNT(*) AS TOTAL, "
	cQuery += "             SUM(CASE "
	cQuery += "                 WHEN DDU_STATUS = '2' THEN 1 "
	cQuery += "                 ELSE 0 "
	cQuery += "                 END) AS LIBERADOS "
	cQuery += " FROM        "  + RetSqlName("DDU") + " DDU "
	cQuery += " WHERE       DDU.DDU_FILIAL =  '" + xFilial("DDU") 	+ "' "
	cQuery += " AND         DDU.DDU_ALIAS  =  '" + cAliasObj 		+ "' "
	cQuery += " AND         DDU.DDU_CHAVE  =  '" + cChave 			+ "' "
	cQuery += " AND         DDU.D_E_L_E_T_ =  ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP)

	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(DbGoTop())

	If (cAliasTMP)->TOTAL > 0 .And. (cAliasTMP)->TOTAL == (cAliasTMP)->LIBERADOS

		// Se Tudo Liberado, Posiciona No Objeto e Atualiza Status Para "Liberado"
		DbSelectArea("DDU")
		DbSetOrder(2)
		MsSeek(xFilial("DDU") + cAliasObj + cChave )

		// Utiliza MetaDados da Tabela De Bloqueios Para Localizar Registros
		DbSelectArea(DDU->DDU_ALIAS)
		DbSetOrder(Val(DDU->DDU_INDEX))
		MsSeek(RTrim(DDU->DDU_CHAVE),.f.) // Usa RTrim Para Limpar os Espaços à Direita e Permitir Indexação Sem SoftSeek
		
		cChaveObj := RTrim(DDU->DDU_CHAVE)

		DbSelectArea(cAliasObj)
		While !(cAliasObj)->(Eof()) .And. (cChaveObj == Substr(&((cAliasObj)->(IndexKey((cAliasObj)->(IndexOrd())))),1,Len(cChaveObj)))   			

			Do Case
			Case DDU->DDU_ALIAS == "DTP" //-- Lote NFs (Processamento TMSA200)

				RecLock("DTP",.f.)
				Replace DTP->DTP_STATUS With "2" // Liberado
				DTP->(MsUnlock())

				lRet := .t.

			Case DDU->DDU_ALIAS == "DUC" //-- Bloqueios De Viagem (TMSA140)

				RecLock("DUC",.f.)
				Replace DUC->DUC_STATUS With "2" // Liberado
				Replace DUC->DUC_DATLIB With dDataBase
				Replace DUC->DUC_HORLIB With StrTran(Left(Time(),5), ":", "")
				Replace DUC->DUC_USER   With cCodUsr
				DUC->(MsUnlock())

				lRet := .t.

			Case DDU->DDU_ALIAS == "DT5" //-- Sol. Coleta (TMSA460)

				TMSA460Lib(.t.,.t.) //-- Param1 - Libera DT5, Param2 - Muda Para Modo Auto (Blind)

			Case DDU->DDU_ALIAS == "DT4" //-- Cotação De Frete (TMSA040)

				RecLock('DT4',.F.)
				If !Empty(DT4->DT4_CLIDEV) .And. !Empty(DT4->DT4_CLIREM) .And. !Empty(DT4->DT4_CLIDES)
					DT4->DT4_STATUS := StrZero( 3, Len( DT4->DT4_STATUS ) )   //Aprovada
				Else
					DT4->DT4_STATUS := StrZero( 1, Len( DT4->DT4_STATUS ) )   //Pendente
				EndIf 	
				DT4->(MsUnLock())

				//-- Ponto de entrada apos a liberacao da cotacao.
				If  lTM040Lib
					// Carrega As variáveis De Memória Para Compatibilizar
					// Com o Mesmo Ponto de Entrada Existente No TmsA040
					RegToMemory('DT4', .F., .F. )
					ExecBlock("TM040LIB",.F.,.F.)
				EndIf
				
			Case DDU->DDU_ALIAS == "DUA" //-- Apontamento De Ocorrências
				
				
				//-- Inicializa Controle Transacional
				Begin Transaction
				
				//-- Libera Registro No DUA - Apont. Ocorrências
				If DDU->DDU_TIPBLQ <> "PR"     //Prazo de Entrega 
					RecLock("DUA",.f.)
					Replace DUA->DUA_RECDEP With "1" //-- Liberado 
					DTP->(MsUnlock())
					
					//-- Posiciona Na Tab. Ocorrencias
					DbSelectArea("DT2")
					DbSetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
					MsSeek( FWxFilial("DT2") + DUA->DUA_CODOCO , .f. )
					
					//-- Efetua Geração Automática De Documentos Quando Parametrizado
					If DT2->DT2_CMPAUT == StrZero(1, Len( DT2->DT2_CMPAUT ) )
						//-- Executa TMSA152 Para Liberação Automática
						aAreaAnt:= GetArea()
						lRet := Tmsa152Ger( "G" , DUA->(Recno()) )
						RestArea(aAreaAnt)
					EndIf 

					//-- Realiza Liberação Dos Objetos Relacionados Ao Apontamento Da Ocorrência.
					If (DT2->DT2_TIPOCO == StrZero(17, Len( DT2->DT2_TIPOCO ) ) .Or.;
						DT2->DT2_TIPOCO == StrZero(18, Len( DT2->DT2_TIPOCO ))) .And.;
						!TmsDuaGfe("DUA", DUA->DUA_FILOCO + DUA->DUA_NUMOCO ) //-- Verifica Integração GFE X TMS pelo DUA (Ocorrencias)
						
						
						//-- Realiza gravação na tabela de acréscimos/decréscimos - DDN
						If DT2->(ColumnPos("DT2_CODAED")) > 0 .And. DT2->DT2_TIPOCO == StrZero(17, Len( DT2->DT2_TIPOCO ) ) .And. !Empty(DT2->DT2_CODAED)
							TMSA029DDN( .T. , DUA->DUA_FILORI , DUA->DUA_VIAGEM , DUA->DUA_FILOCO , DUA->DUA_NUMOCO , DUA->DUA_SEQOCO , DUA->DUA_VLRDSP  , DT2->DT2_CODAED )
						EndIf
						
					EndIf				
				Else
					DT6->( DbSetOrder( 1 ) )
					If	DT6->( DbSeek( xFilial('DT6') + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE ) )
						RecLock('DT6',.F.)
						DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )
						DT6->DT6_PRZENT := Iif(lLibAut,DDU->DDU_DATA,FWFldGet("GET_DATDDU"))
						MsUnLock()
					EndIf
				EndIf
				
				//-- Finaliza Controle Transacional
				End Transaction			
			
			EndCase
		
			DbSelectArea(cAliasObj)
			(cAliasObj)->(DbSkip()) 
		
		EndDo
	Else
		If (cAliasTMP)->TOTAL > (cAliasTMP)->LIBERADOS 
			If cAliasObj == 'DT4' .Or. cAliasObj == 'DT5'  //Cotação de Frete ou Solicitacao Coleta
				cAliasTMP1	:= GetNextAlias()
				
				// Verifica se existe itens pendentes para liberacao diferentes de RRE e Incompatibilidade
				cQuery := " SELECT      COUNT(*) AS TOTAL "
				cQuery += " FROM        "  + RetSqlName("DDU") + " DDU "
				cQuery += " WHERE       DDU.DDU_FILIAL =  '" + xFilial("DDU") 	+ "' "
				cQuery += " AND         DDU.DDU_ALIAS  =  '" + cAliasObj 		+ "' "
				cQuery += " AND         DDU.DDU_CHAVE  =  '" + cChave 			+ "' "
				cQuery += " AND         DDU.DDU_TIPBLQ  NOT IN  ( "+ cTipBlq + " )"
				cQuery += " AND        (DDU.DDU_STATUS =  '1' OR DDU.DDU_STATUS =  '3') "
				cQuery += " AND         DDU.D_E_L_E_T_ =  ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasTMP1)
				If (cAliasTMP1)->(!Eof())
					If (cAliasTMP1)->TOTAL > 0
						DbSelectArea(cAliasObj)
						DbSetOrder(1)
						If MsSeek(RTrim(cChave),.f.)
							If cAliasObj == 'DT4'
								RecLock('DT4',.F.)
								DT4->DT4_STATUS := StrZero( 2, Len( DT4->DT4_STATUS ) )  //Bloqueado
								MsUnLock()
							Else
								RecLock('DT5',.F.)
								DT5->DT5_STATUS := StrZero( 6, Len( DT5->DT5_STATUS ) )  //Bloqueado
								MsUnLock()
							EndIf	
						EndIf	
					EndIf
				EndIf
				
				(cAliasTMP1)->(DbCloseArea())
			EndIf	
		EndIf
	EndIf

	//-- Fecha Arquivo Temporario
	If Select(cAliasTMP) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Cod
@autor		: Eduardo Alberti
@descricao	: Pesquisa Dentro Da Tabela De Bloqueios 'DDU' Se Existe Um Determinado Código De Bloqueio
@since		: May./2015
@using		: Atualização De Bloqueios TMS (Tabela DDU).
@review	:

Argumentos	: cCodBlq		<Caracter> Código De Bloqueio a Ser Pesquisado
              cAliasObj	<Caracter> Alias Do Bloqueio a Ser Pesquisado
              cChave		<Caracter> Chave De Indexação Da Pesquisa
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa029Cod(cCodBlq,cAliasObj,cChave)

	Local aArea 	:= GetArea()
	Local aArDDU	:= DDU->(GetArea())
	Local lRet    := .f.

	cCodBlq	:= PadR(cCodBlq  ,TamSX3("DDU_TIPBLQ")[1])
	cAliasObj	:= PadR(cAliasObj,TamSX3("DDU_ALIAS")[1])
	cChave		:= PadR(cChave   ,TamSX3("DDU_CHAVE")[1])

	// Verifica Se Existe Bloqueio
	DbSelectArea("DDU")
	DbSetOrder(2) //-- DDU_FILIAL+DDU_ALIAS+DDU_CHAVE+DDU_TIPBLQ+STR(DDU_NIVBLQ)+DDU_FILORI
	MsSeek(xFilial("DDU") + cAliasObj + cChave )

	While DDU->(!Eof()) .And. (DDU->(DDU_ALIAS + DDU_CHAVE) == cAliasObj + cChave)

		If DDU->DDU_TIPBLQ == cCodBlq
			lRet := .t.
			Exit
		EndIf

		DDU->(DbSkip())
	EndDo

	RestArea(aArDDU)
	RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Blq
@autor		: Eduardo Alberti
@descricao	: Rotina Padrao Para Tratamento De Bloqueios TMS Na Tabela DDU (Inclusão,Exclusão,Alteração,Verificação De Desbloqueio)
@since		: Dec./2014
@using		: Atualização De Bloqueios TMS (Tabela DDU).
@review	:

Argumentos	: nOpc		<Numérico> Incl/Alt/Excl (Obrigatória) [3 = Incluir, 4 = Alterar, 5 = Excluir]
              cRotina	<Caracter> Nome Da Rotina (Obrigatória)
              cTipBlq	<Caracter> Código De Bloqueio (Motivo)
              cFilOri	<Caracter> Código Da Filial Origem
              cTab		<Caracter> Código Da Tabela Base De Bloqueio
              cInd		<Caracter> Numero do Índice De Localização Do Registro
              cChave	<Caracter> Chave De Indexação Do Registro Bloqueado
              cCod		<Caracter> Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
              cDetalhe <Caracter> Detalhes Adicionais a Respeito Do Bloqueio
              nOpcRot  <Numerico> Opcao da Rotina [3 = Incluir, 4 = Alterar, 5 = Excluir]
                                   Utilizado para controle da exclusao da DDU

/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa029Blq(nOpc,cRotina,cTipBlq,cFilOri,cTab,cInd,cChave,cCod,cDetalhe,nOpcRot,nValDES,nValRec,dPrzEnt)

	Local aArea      := GetArea()
	Local cUser      := __cUserId
	Local cUName     := UsrFullName(__cUserId)
	Local dData      := MsDate()
	Local cHora      := Substr(Time(),1,5)
	Local xRet       := .F.
	Local nI         := 0
	Local nSeq       := 0
	Local nCount     := 0
	Local nTotReg    := 0
	Local cQuery	   := ""
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local lDDUData   := DDU->(ColumnPos("DDU_DATA")) > 0
	Local lAchou     := .F.

	Default nOpc     := 0
	Default cRotina  := ""
	Default cTipBlq  := ""
	Default cFilOri  := ""
	Default cTab     := ""
	Default cInd     := ""
	Default cChave   := ""
	Default cCod     := ""
	Default cDetalhe := ""
	Default cTipBlq  := ""
	Default nOpcRot  := nOpc
	Default nValDES  := 0
	Default nValRec  := 0
	Default dPrzEnt  := CTOD("")

	//-- Inicializa Controle De Sequence
	Begin Sequence

		If nOpc == 3 .Or. nOpc == 4  //-- Incluir / Alterar

			cTipBlq	:= PadR(cTipBlq,TamSX3("DDV_CODBLQ")[1])
			cRotina	:= PadR(cRotina,TamSX3("DDX_ROTINA")[1])

			//-- Determina Regra De Gravação Dos Registros
			cQuery += " SELECT      	DDX.DDX_ROTINA,DDX.DDX_TPLIB,DDX.DDX_NIVEIS,DDX.R_E_C_N_O_ AS DDXREC, "
			cQuery += " 				DDV.DDV_CODBLQ,DDV.R_E_C_N_O_ AS DDVREC "
			cQuery += " FROM        	" +	RetSqlName("DDX") + " DDX "	//-- Rotinas X Tip.Lib X Niveis
			cQuery += " INNER JOIN  	" +	RetSqlName("DDV") + " DDV "	//-- Rotinas X Bloqueios
			cQuery += " ON          	DDV.DDV_FILIAL      =  '" + xFilial("DDV") + "' "
			cQuery += " AND         	DDV.DDV_ROTINA      =  DDX.DDX_ROTINA "
			cQuery += " AND         	DDV.DDV_CODBLQ      =  '" + cTipBlq + "' "
			cQuery += " AND         	DDV.D_E_L_E_T_      =  ' ' "
			cQuery += " WHERE       	DDX.DDX_FILIAL      =  '" + xFilial("DDX") + "' "
			cQuery += " AND         	DDX.DDX_ROTINA      =  '" + cRotina + "' "
			cQuery += " AND         	DDX.DDX_ATIVO       =  '1' "
			cQuery += " AND         	DDX.D_E_L_E_T_      =  ' ' "

			cQuery := ChangeQuery(cQuery)

			//-- Executa Query
			Processa( {|| Eval(bQuery)}, STR0011+ "...", STR0012 + "...",.F.) // Aguarde... Consultando...

			aEval(DDX->(dbStruct()),{|e| If(e[2] != "C" .And. Alltrim(e[1]) $ Upper(cQuery) , TCSetField(cAliasT,e[1],e[2],e[3],e[4]),Nil)})

			TcSetField(cAliasT,"DDVREC","N",16,0)
			TcSetField(cAliasT,"DDXREC","N",16,0)

			DbSelectArea(cAliasT)
			(cAliasT)->(DbGoTop())

			//-- Inicia a Gravação Da Tabela DDU
			If !Empty((cAliasT)->DDX_ROTINA)

				//-- Posiciona Nas Tabelas Base Para Tratamento Do Campo DDX_REGRA
				DbSelectArea("DDV")
				DDV->(DbGoTo((cAliasT)->DDVREC))

				DbSelectArea("DDX")
				DDX->(DbGoTo((cAliasT)->DDXREC))

				If Empty(DDX->DDX_REGRA) .Or. &(Upper(Alltrim(DDX->DDX_REGRA)))

					nLoop := Iif((cAliasT)->DDX_TPLIB == '1',1,(cAliasT)->DDX_NIVEIS)

					//-- Inicializa Controle Transacional
					Begin Transaction

						//-- Exclui Registros Antigos Caso Existam
						If !(Tmsa029Exc(cTab,cChave,cInd,cTipBlq,cFilOri,cRotina,nOpcRot))
							DisarmTransaction()
							Break
						EndIf

						nSeq   := 1
						nCount := 0

						For nI := 1 To nLoop

							//-- Somente Cria Nivel Quando Existe Liberador Para Tal
							If Tmsa029Niv(cRotina,cTipBlq,nI)

								DbSelectArea("DDU")
								RecLock("DDU",.T.)

								Replace	DDU->DDU_FILIAL		With xFilial("DDU")
								Replace	DDU->DDU_FILORI		With cFilOri
								Replace	DDU->DDU_CODIGO		With cCod
								Replace	DDU->DDU_SEQ 			With StrZero(nSeq,TamSX3("DDU_SEQ")[1])
								Replace	DDU->DDU_ROTINA		With cRotina
								Replace	DDU->DDU_STATUS		With '1' // Bloqueado
								Replace	DDU->DDU_TIPBLQ		With cTipBlq
								Replace	DDU->DDU_NIVBLQ		With nI
								Replace	DDU->DDU_USRBLQ		With cUser
								Replace	DDU->DDU_NOMBLQ		With cUName
								Replace	DDU->DDU_DATBLQ		With dData
								Replace	DDU->DDU_HORBLQ		With cHora
								Replace	DDU->DDU_DETALH		With cDetalhe
								Replace	DDU->DDU_ALIAS 		With cTab
								Replace	DDU->DDU_CHAVE 		With cChave
								Replace	DDU->DDU_INDEX		With cInd
								Replace	DDU->DDU_VLRDES		With nValDES
								Replace	DDU->DDU_VLRREC		With nValRec
								If lDDUData
									Replace	DDU->DDU_DATA	With dPrzEnt
								EndIf

								DDU->(MsUnlock())

								nSeq ++   // Incrementa Sequencial De Gravação
								nCount ++ // Controla Gravação Registros
								lAchou:= .T.
							EndIf

						Next nI

					//-- Finaliza Controle Transacional
					End Transaction
				EndIf
			Else
				lAchou:= .F.
			EndIf

			If !lAchou
				Help(Nil,Nil,'HELP',Nil, STR0071 + Chr(13) + Chr(10) +; //-- "O Sistema Não Pode Efetuar Os Bloqueios Necessários!"
				                         STR0072 + Chr(13) + Chr(10) +; //-- "Verifique Se Existe o Cadastro e Se Estes Estão Com Status Ativo."
				                         TmsReTitle( 'DDV_ROTINA' )  + ": " + cRotina + " " +;
				                         TmsReTitle( 'DDV_CODBLQ' )  + ": " + cTipBlq  , 1, 0)
			EndIf

			//-- Se Houveram Gravações Confirma Retorno
			If nCount > 0
				xRet := .t.
			EndIf

		ElseIf nOpc == 5 //-- Excluir

			//-- Exclui Registros Caso Existam
			If !(Tmsa029Exc(cTab,cChave,cInd,cTipBlq,cFilOri,cRotina,nOpcRot))
				Break
			EndIf

		ElseIf nOpc == 9 //-- Verificação

			//Tmsa029Blq( 9  ,'TMSA200', 'CR'  ,DTP->DTP_FILORI, 'DTP' , '1' ,DTP->(DTP_FILIAL + DTP_LOTNFC), DTP->DTP_LOTNFC , "" )

			cQuery := ""
			cQuery += " SELECT      	COUNT(DDU.DDU_SEQ) AS QTITENS, "
			cQuery += "             	SUM( CASE WHEN (DDU.DDU_STATUS = '1' OR DDU.DDU_STATUS = '3') THEN 1 ELSE 0 END ) AS QTBLQ, " //-- Soma Bloqueados e Rejeitados (Compatibilidade)
			cQuery += "             	SUM( CASE WHEN  DDU.DDU_STATUS = '3'                          THEN 1 ELSE 0 END ) AS QTREJ  " //-- Soma Somente Rejeitados
			cQuery += " FROM        	" +	RetSqlName("DDU") + " DDU "	//-- Bloqueios TMS
			cQuery += " WHERE       	DDU.DDU_FILIAL      =  '" + xFilial("DDU") + "' "
			cQuery += " AND         	DDU.DDU_ALIAS       =  '" + Upper(PadR(cTab,TamSX3("DDU_ALIAS")[1]))	+ "' "
			cQuery += " AND         	DDU.DDU_CHAVE       =  '" + PadR(cChave,TamSX3("DDU_CHAVE")[1]) 		+ "' "
			If !Empty(cTipBlq)
				cQuery += " AND     	DDU.DDU_TIPBLQ      =  '" + PadR(cTipBlq,TamSX3("DDU_TIPBLQ")[1]) 		+ "' "
			EndIf
			cQuery += " AND         	DDU.D_E_L_E_T_      =  ' ' "

			cQuery := ChangeQuery(cQuery)

			//-- Executa Query
			Processa( {|| Eval(bQuery)}, STR0011+ "...", STR0012 + "...",.F.) // Aguarde... Consultando...

			TcSetField(cAliasT,"QTITENS","N",8,0)
			TcSetField(cAliasT,"QTBLQ"  ,"N",8,0)
			TcSetField(cAliasT,"QTREJ"  ,"N",8,0)

			DbSelectArea(cAliasT)
			(cAliasT)->(DbGoTop())

			If (cAliasT)->QTITENS == 0
				xRet := "N" //.t.	// Nao Existe Registro De Bloqueio
			ElseIf (cAliasT)->QTITENS ==  (cAliasT)->QTBLQ .And. (cAliasT)->QTREJ == 0
				xRet := "B" //.t.	// Bloqueado Totalmente
			ElseIf	((cAliasT)->QTITENS >  (cAliasT)->QTBLQ) .And. ((cAliasT)->QTBLQ > 0 .And. (cAliasT)->QTREJ == 0 )
				xRet := "P" //.f.	// Parcialmente Liberado
			ElseIf	((cAliasT)->QTITENS >  0 ) .And. ((cAliasT)->QTBLQ == 0 .And. (cAliasT)->QTREJ == 0  )
				xRet := "L" //   	// Liberado Totalmente
			ElseIf	((cAliasT)->QTITENS >  0 ) .And. (cAliasT)->QTREJ > 0  
				xRet := "R" //   	// Rejeitado (Processo Parado)
			EndIf

		EndIf

	//-- Finaliza Controle De Sequence
	End Sequence

	//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(xRet)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Exc
@autor		: Eduardo Alberti
@descricao	: Exclui Registro De Bloqueios Da Tabela DDU Conforme Parametros Informados.
@since		: Dec./2014
@using		: Atualização De Bloqueios TMS (Tabela DDU).
@review	:

Argumentos	: cTab		<Carácter> Nome Da Tabela Referencia (Obrigatório)
              cChave	<Carácter> Chave Indexação Da Tabela (Obrigatório)
              cInd		<Carácter> Indice Da Chave Indexação
              cTipBlq	<Carácter> Código De Bloqueio Do Registro
              cFilOri  <Caracter> Filial Origem
              cRotina  <Caracter> Nome da Rotina
              nOpcRot  <Numerico> Opcao da Rotina [3 = Incluir, 4 = Alterar, 5 = Excluir]
                                   Utilizado para controle da exclusao da DDU 

/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa029Exc(cTab,cChave,cInd,cTipBlq,cFilOri,cRotina,nOpcRot)

	Local aArea     := GetArea()
	Local lRet      := .t.
	Local lTmsBlVg  := SuperGetMV( 'MV_TMSBLVG',, .F.) 
	Local lDelDDU	:= SuperGetMV("MV_DELDDU",.F.,.F.) // .T. - Exclui fisicamente o registro / .F. - Delecao logica

	Default cTab    := ''
	Default cChave  := ''
	Default cInd    := ''
	Default cTipBlq := ''
	Default cFilOri := ''
	Default cRotina := 'TMSA140'
	Default nOpcRot := 5   //Excluir

	cTab    := PadR(cTab   ,TamSX3("DDU_ALIAS" )[1])
	cChave  := PadR(cChave ,TamSX3("DDU_CHAVE" )[1])
	cInd    := PadR(cInd   ,TamSX3("DDU_INDEX" )[1])
	cTipBlq := PadR(cTipBlq,TamSX3("DDU_TIPBLQ")[1])
	cFilOri := PadR(cFilOri,TamSX3("DDU_FILORI")[1])

	Begin Sequence

		// Na operacao de Exclusao da Rotina, sempre excluir.
		If nOpcRot <> 5 .And. !lTmsBlVg // Tratamento Do Parâmetro MV_TMSBLVG Para Viagens (Não Exclui Liberações).
			If (cTab == "DUC" .And. cRotina == "TMSA140") .Or. (cTab == "DTQ" .And. cRotina == "TMSA310")
				If Tmsa029Blq( 9  ,cRotina,Iif(!Empty(cTipBlq),cTipBlq,''),cFilOri,cTab,cInd,cChave,'','',nOpcRot ) == 'L' // Liberado
					lRet := .f.
					Break
				EndIf	
			EndIf
		EndIf

		If cTab <> Nil .And. cChave <> Nil .And. cInd <> Nil

			//-- Exclui Registros Antigos Caso Existam
			cQuery := ""

			//-- Define o Tipo De Exclusão Da Tabela DDU (.t. = Deleção Fisica. .f. = Deleção Lógica)
			If !lDelDDU
				cQuery += " UPDATE	" + RetSqlName("DDU") + " "
				cQuery += " SET		D_E_L_E_T_ 	= '*', "
				cQuery += " R_E_C_D_E_L_	= R_E_C_N_O_ "
			Else
				cQuery += " DELETE 	FROM " + RetSqlName("DDU") + " "
			EndIf

			cQuery += " WHERE	DDU_FILIAL =  '" + xFilial("DDU") + "' "
			cQuery += " AND		DDU_CHAVE  =  '" + cChave + "' "
			cQuery += " AND		DDU_INDEX  =  '" + cInd   + "' "

			// Verifica Se Utiliza o Codigo Do Bloqueio Para a Exclusão
			If cTipBlq <> Nil .And. !Empty(cTipBlq)
				cQuery += " AND		DDU_TIPBLQ =  '" + cTipBlq + "' "
			EndIf

			// Verifica Se Utiliza Filial Origem
			If cFilOri <> Nil .And. !Empty(cFilOri)
				cQuery += " AND		DDU_FILORI =  '" + cFilOri + "' "
			EndIf

			cQuery += " AND		DDU_ALIAS  =  '" + cTab + "' "
			cQuery += " AND		D_E_L_E_T_ =  ' ' "

			//-- Executa Script
			nCodRet:= TcSqlExec(cQuery)

			//-- Inclui Log De Erro
			If nCodRet < 0
				lRet  := .f.
				Help( ,, ProcName(),, TcSqlError() , 1, 0)
			EndIf
			
			//--- Exclui os Check List da Viagem
			If cTab == "DTQ" .And. cRotina == "TMSA310" 			
				Tmsa029Chk(cTab,cChave)
			EndIf	
			
		EndIf

	End Sequence

	RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Niv
@autor		: Eduardo Alberti
@descricao	: Determina Se Existe Liberadores Para Determinada Rotina/Tipo Bloqueio/Nivel
@since		: Dec./2014
@using		: Atualização De Bloqueios TMS (Tabela DDU).
@review	:

Argumentos	: cRotina	<Carácter> Nome Da Rotina (Obrigatório)
              cTipBlq	<Carácter> Código De Bloqueio (Obrigatório)
              nI		<Numérico> Nível Do Bloqueio

/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa029Niv(cRotina,cTipBlq,nI)

	Local aArea    := GetArea()
	Local lRet     := .f.
	Local nTotReg  := 0
	Local cQuery	 := ""
	Local cAliasT  := GetNextAlias()
	Local bQuery   := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local lNivel   := SuperGetMV("MV_NIVDDU",.F.,.T.) // Se .t. Verifica Se Existe Liberador Para O Nivel De Bloqueio

	If lNivel //-- Somente Cria Nivel Se Existir Liberador

		cQuery += " SELECT      DDY.DDY_USUARI "
		cQuery += " FROM        " + RetSqlName("DDX") + " DDX "
		cQuery += " INNER JOIN  " + RetSqlName("DDY") + " DDY "
		cQuery += " ON          DDY.DDY_FILIAL    =  	'" + xFilial("DDY") + "' "
		cQuery += " AND         DDY.DDY_ROTINA    =  	DDX.DDX_ROTINA "
		cQuery += " AND         DDY.DDY_TPBLQ  LIKE 	'%" + PadR(cTipBlq,TamSX3("DDU_TIPBLQ")[1]) + "%' "
		cQuery += " AND         DDY.DDY_STATUS    =  	'1' "
		cQuery += " AND         DDY.D_E_L_E_T_    =  	' ' "
		cQuery += " WHERE       DDX.DDX_FILIAL    =  	'" + xFilial("DDX") + "' "
		cQuery += " AND         DDX.DDX_ROTINA    =  	'" + PadR(cRotina,TamSX3("DDX_ROTINA")[1]) + "' "
		cQuery += " AND         DDX.DDX_ATIVO     =  	'1' "
		cQuery += " AND         ((DDY.DDY_NIVEL   =   " + Alltrim(Str(nI)) + ") "
		cQuery += "               OR "
		cQuery += "              (DDX.DDX_TPLIB   =  '2' AND DDY.DDY_TIPLIB = '3') "
		cQuery += "               OR "
		cQuery += "              (DDX.DDX_TPLIB   =  '1')) "
		cQuery += " AND         DDX.D_E_L_E_T_ =  ' ' "

		cQuery := ChangeQuery(cQuery)

		//-- Executa Query
		Eval(bQuery)

		DbSelectArea(cAliasT)
		(cAliasT)->(DbGoTop())
		If !Empty((cAliasT)->DDY_USUARI)
			lRet := .t.
		EndIf

		//-- Fecha Arquivo Temporário
		If Select(cAliasT) > 0
			(cAliasT)->(DbCloseArea())
		EndIf
	Else //-- Cria Nivel Bloqueio Independente Da Existencia De Liberadores
		lRet := .t.
	EndIf

	RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Use
@autor		: Eduardo Alberti
@descricao	: Verifica Se Rotina Está Em Uso Pelo Controle De Bloqueio Unificado
@since		: Dec./2014
@using		: Atualização De Bloqueios TMS (Tabela DDU).
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa029Use(cRotina,lIncomp)

	Local aArea    := GetArea()
	Local aArDDX   := {} //DDX->(GetArea())
	Local lRet     := .f.
	Local cControl := SuperGetMv("MV_TMSINCO",.F.,"")
	Local cMV_TMSRRE := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza

	Default lIncomp := .f.

	//-- MV_TMSINCO -> Define Rotinas Que Tratam Incompatibilidade De Produtos.
	//-- A = Todas;
	//-- B = Calculo Do Frete;
	//-- C = Viagem;
	//-- D = Solicitação De Coleta;
	//-- E = Agendamento;
	//-- F = Cotação;
	//-- Em Branco = Nao Controla.

	//-- Controle De Erro Para Tratamento Antigo Do Parâmetro
	If ValType(cControl) == "L"
		If cControl
			cControl := "A" //-- Todos
		Else
			cControl := "" //-- Nenhum
		EndIf
	Else
		cControl := Upper(Alltrim(cControl)) //-- Formata Parametro
	EndIf

	Begin Sequence

		// Proteção De Erro
		If cRotina == Nil .Or. Empty(cRotina)
			Break
		Else
			cRotina := Upper(Alltrim(cRotina))
		EndIf

		// Testa Existencia Dos Dicionários Da Rotina (Não Utilizar 'AliasInDic').
		If !Empty(cControl) .Or. !Empty(cMV_TMSRRE)

			Do Case
			Case cRotina == "TMSA200" .And. ("A" $ cControl .Or. "B" $ cControl .Or. "1" $ cMV_TMSRRE ) //-- Calculo Frete    - Sempre Ativo Se Usar Incompatibilidade De Produtos
				lRet    := .t.
				lIncomp := .t.
				Break
			Case cRotina == "TMSA140" .And. ("A" $ cControl .Or. "C" $ cControl .Or. "3" $ cMV_TMSRRE) //-- Se Calc. Viagem  - Sempre Ativo Se Usar Incompatibilidade De Produtos
				lRet := .t.
				Break
			Case cRotina == "TMSA460" .And. ("A" $ cControl .Or. "D" $ cControl .Or. "4" $ cMV_TMSRRE) //-- Se Solic. Coleta - Sempre Ativo Se Usar Incompatibilidade De Produtos
				lRet := .t.
				Break
			Case cRotina == "TMSAF05" .And. ("A" $ cControl .Or. "E" $ cControl) //-- Se Agendamento   - Sempre Ativo Se Usar Incompatibilidade De Produtos
				lRet := .t.
				Break
			Case cRotina == "TMSA040" .And. ("A" $ cControl .Or. "F" $ cControl .Or. "2" $ cMV_TMSRRE) //-- Se Cotação       - Sempre Ativo Se Usar Incompatibilidade De Produtos
				lRet := .t.
				Break
			Case cRotina == "TMSA310" .And.  "3" $ cMV_TMSRRE //-- Se Fechamento da Viagem - Sempre ativo RRE
				lRet := .t.
				Break
			EndCase
		EndIf

		// Verifica No Cadastro
		DbSelectArea("DDX")
		aArDDX   := DDX->(GetArea())
		DbSetOrder(1) // DDX_FILIAL+DDX_ROTINA
		If MsSeek(xFilial("DDX") + PadR(cRotina,TamSX3("DDX_ROTINA")[1])) .And. DDX->DDX_ATIVO == '1'
			lRet := .t.
			Break
		EndIf


	End Sequence

	If Len(aArDDX) > 0
		RestArea(aArDDX)
	EndIf

	RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsA029Car
@autor		: Eduardo Alberti
@descricao	: Carrega o Conteúdo Da Variável Static lCar029
@since		: Jun./2015
@using		: Atualização De Bloqueios TMS.
@review	: --> Utilizado Para Integração EAI - Venture
/*/
//-------------------------------------------------------------------------------------------------
Function TmsA029Car()

Return(lCar029)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@autor		: Eduardo Alberti
@descricao	: ModelDef da tela De Liberação
@since		: Sep./2015
@using		: Rotina Controle Dos Bloqueios Feitos No Módulo TMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruGET 	:= NIL		// Recebe a Estrutura da Get Dados Virtual
	Local oStruGRD1 	:= NIL		// Recebe a Estrutura 1 da Grid Virtual  
	Local oStruGRD2 	:= NIL		// Recebe a Estrutura 1 da Grid Virtual
	Local oModel   	:= NIL        // Objeto do Model
	
	//--Local aRelacDIS	:= {}
	//--Local aRelacDIT	:= {}
	
	Local bPosValid	:= { |oModel| PosVldMdl(oModel  ) }
	Local bCommit		:= { |oModel| CommitMdl( oModel ) }
	//Local bLinePost	:= { |oModelGrid, nLinha| TMSA023LOK(oModelGrid, nLinha) } //-- Validacoes da Grid
	
	//---------------------------+
	// CRIA ESTRUTRA PARA oModel |
	//---------------------------+
	oStruGET  := FWFormModelStruct():New()
	oStruGRD1 := FWFormModelStruct():New()
	oStruGRD2 := FWFormModelStruct():New()
	
	oStruGET:AddTable("GET"  ,{},STR0004) //-- "Manutenção De Bloqueios"
	oStruGRD1:AddTable("GRD1",{},STR0004) //-- "Manutenção De Bloqueios"
	oStruGRD1:AddTable("GRD2",{},STR0004) //-- "Manutenção De Bloqueios"
	
	LoadStrGET( oStruGET )
	LoadSGrd1( oStruGRD1 )
	LoadSGrd2( oStruGRD2 )
	
	oModel := MPFormModel():New( "TMSA029",/*bPre*/, bPosValid , bCommit , /*bCancel*/ )
	
	oModel:SetDescription(STR0036) // "Liberação Bloqueios TMS"
	
	// ------------------------------------------+
	// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
	// ------------------------------------------+
	oModel:AddFields( 'MdFieldGET',, oStruGET , /*bPre*/, /*bPost*/, { | oModel, lLoad | RetContGET( oModel, lLoad ) }/*bLoad*/)
	
	oModel:AddGrid( 'MdGridGRD1', 'MdFieldGET', oStruGRD1, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/, { | oModel, lLoad | LoadGridGRD( oModel, "DDU_DETALH" ) }/*bLoad*/)
	
	oModel:AddGrid( 'MdGridGRD2', 'MdFieldGET', oStruGRD2, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/, { | oModel, lLoad | LoadGridGRD( oModel, "DDU_HISREJ" ) }/*bLoad*/)
	
	//-- Aplica SetDescription ( Obrigatório Qdo Mais De Um Grid Na Tela )
	oModel:GetModel("MdGridGRD1"):SetDescription( "Grid1" )
	oModel:GetModel("MdGridGRD2"):SetDescription( "Grid2" )
	
	// ----------------------------------------------------+
	// NÃO GRAVA DADOS DE UM COMPONENTE DO MODELO DE DADOS |
	// ----------------------------------------------------+
	oModel:GetModel( 'MdFieldGET' ):SetOnlyQuery ( .T. ) 
	
	// -------------------------------------+
	// DEFINE SE O CAMPONENTE E OBRIGATORIO |
	// -------------------------------------+
	oModel:GetModel( 'MdGridGRD1' ):SetOptional( .T. )
	oModel:GetModel( 'MdGridGRD2' ):SetOptional( .T. )
	
	// -------------------------------------------------+
	// FAZ RELACIONAMENTO ENTRE OS COMPONENTES DO MODEL |
	// -------------------------------------------------+
	/*
	aAdd(aRelacDIS,{ 'DIS_FILIAL'	, 'xFilial( "DIS" )'	})
	aAdd(aRelacDIS,{ 'DIS_CODARE'	, 'DIR_CODARE' 		})
	
	aAdd(aRelacDIT,{ 'DIT_FILIAL'	, 'xFilial( "DIT" )'	})
	aAdd(aRelacDIT,{ 'DIT_CODARE'	, 'DIR_CODARE' 		})
	
	oModel:SetRelation( 'MdGridDIS', aRelacDIS , DIS->( IndexKey( 1 ) )  )
	oModel:GetModel('MdGridDIS'):SetUniqueLine( { "DIS_CEPINI","DIS_CEPFIM"} )  
	oModel:SetRelation( 'MdGridDIT', aRelacDIT , DIT->( IndexKey( 1 ) )  )
	oModel:GetModel('MdGridDIT'):SetUniqueLine( { "DIT_ROTA"} )  
	
	oModel:GetModel ( 'MdFieldDIR' )
	*/
	oModel:SetPrimaryKey( { 'GET_ROTINA','GET_FILORI','GET_CODIGO' } )
	
	oModel:SetActivate( )

Return (oModel)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@autor		: Eduardo Alberti
@descricao	: Retorna a View (tela) da rotina
@since		: Sep./2015
@using		: Rotina Controle Dos Bloqueios Feitos No Módulo TMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView       := NIL			// Recebe o objeto da View
	Local oModel      := NIL			// Objeto do Model 
	Local oStruGET    := NIL			// Recebe a Estrutura da Tabela Area de Restrição
	Local oStruGRD1   := NIL			// Recebe a Estrutura da Tabela Virtual 1
	Local oStruGRD2   := NIL			// Recebe a Estrutura da Tabela Virtual 2 
	Local lDDUData    := DDU->(ColumnPos('DDU_DATA')) > 0
	
	oModel		:= FwLoadModel( "TMSA029" )
	
	oStruGET   := FWFormViewStruct():New() 
	oStruGRD1  := FWFormViewStruct():New() 
	oStruGRD2  := FWFormViewStruct():New()
	
	// Realiza a criação da estrutura com os campos que receberão as informações de pesquisa
	LoadStrGET( oStruGET, .T. )
	LoadSGrd1( oStruGRD1, .T. )
	LoadSGrd2( oStruGRD2, .T. )
	
	//-- Ativa Campo De Motivo Da Liberação Para Digitação Usuário
	If cMode029 <> 'R'
		oStruGET:SetProperty( 'GET_MTVLIB' , MVC_VIEW_CANCHANGE,.T.)
	Else
		oStruGET:SetProperty( 'GET_MTVREJ' , MVC_VIEW_CANCHANGE,.T.)
	EndIf	

	//-- Ativa Campo De Data
	If cMode029 <> 'R' .And. lDDUData
		oStruGET:SetProperty( 'GET_DATDDU' , MVC_VIEW_CANCHANGE,.T.)
	EndIf	
	
	oView := FwFormView():New()
	oView:SetModel(oModel)
	
	//-------------------------------------------+
	// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
	//-------------------------------------------+
	oView:AddField( 'VwFieldGET'  , oStruGET  , 'MdFieldGET' )
	oView:AddGrid ( 'VwGridGRD1'  , oStruGRD1 , 'MdGridGRD1' )
	oView:AddGrid ( 'VwGridGRD2'  , oStruGRD2 , 'MdGridGRD2' )
	
	//------------------------------------------------+
	// REALIZA AUTOPREENCHIMENTO PARA OS CAMPOS ITENS |
	//------------------------------------------------+
	//oView:AddIncrementField('VwGridDIS','DIS_ITEM')
	//oView:AddIncrementField('VwGridDIT','DIT_ITEM')
	
	//-------------------------------------------+
	// DEFINE EM % A DIVISAO DA TELA, HORIZONTAL |
	//-------------------------------------------+
	oView:CreateHorizontalBox( 'TOPO'   , 40 )
	oView:CreateHorizontalBox( 'FOLDER' , 60 )
	
	//-------------------------+
	// DEFINE FOLDER PARA TELA |
	//-------------------------+
	oView:CreateFolder( "PASTA", "FOLDER" )
	oView:AddSheet( "PASTA", "ABA01", STR0021   ) //--"Informações De Bloqueio"
	oView:AddSheet( "PASTA", "ABA02", STR0075   ) //--"Histórico
	
	oView:CreateHorizontalBox( "TAB_DIS_1"  , 100,,,"PASTA","ABA01" )
	oView:CreateHorizontalBox( "TAB_DIS_2"  , 100,,,"PASTA","ABA02" )
	
	// Liga a identificacao do componente
	oView:EnableTitleView ('VwFieldGET' ,STR0037  )	// 'Origem'
	oView:EnableTitleView ('VwGridGRD1' ,STR0038  )	// 'Detalhes'
	oView:EnableTitleView ('VwGridGRD2' ,STR0038  )	// 'Detalhes'
	
	// Cabecalho
	oView:SetOwnerView( 'VwFieldGET' , 'TOPO' )
	
	// Folder
	oView:SetOwnerView( 'VwGridGRD1' , 'TAB_DIS_1' )
	oView:SetOwnerView( 'VwGridGRD2' , 'TAB_DIS_2' )

Return ( oView )

//+--------------------------------------------------------------------------
/*/{Protheus.doc} LoadStrGET - Realiza a criação de campos para uma estrutura específica (GetDados).
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 01/Sep/2015
@param Params
	oPar1  --> Objeto com a estrutura dos dados para alteração a passagem deve ocorrer por parametro
	lPar1  --> indica qual tipo de estrutura carregar
		-----> .T. = Model (Default)
		-----> .F. = View
@return Returns
/*/
//+--------------------------------------------------------------------------
Static Function LoadStrGET(oStruct, lView)

	Local aArea    := GetArea()
	Local aVirtual := {}
	Local nI       := 0
	Local lValor   := DDU->(ColumnPos("DDU_VLRDES")) > 0
	Local lDDUData := DDU->(ColumnPos("DDU_DATA")) > 0
	
	DEFAULT lView := .F.
	
	//-------------------------------+
	// lView = .T. - Estrutura Model |
	//-------------------------------+
	If !lView
	
		aAdd(aVirtual,{ STR0057  , Nil , 'GET_ROTINA'	,'C',	50                       , 0                       ,Nil	,Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Rotina'
		aAdd(aVirtual,{ STR0058  , Nil , 'GET_FILORI'	,'C',	TamSX3('DDU_FILORI')[1]  , 0                       ,Nil	,Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Fil.Origem'
		aAdd(aVirtual,{ STR0059  , Nil , 'GET_CODIGO'	,'C',	TamSX3('DDU_CODIGO')[1]  , 0                       ,Nil	,Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Código'
		aAdd(aVirtual,{ STR0060  , Nil , 'GET_NIVBLQ'	,'C',	TamSX3('DDU_NIVBLQ')[1]  , 0                       ,Nil	,Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Nível Blq.'
		aAdd(aVirtual,{ STR0061  , Nil , 'GET_BLOQ'		,'C',	43                       , 0                       ,Nil	,Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Bloqueio'
		aAdd(aVirtual,{ STR0062  , Nil , 'GET_USUARI'	,'C',	30                       , 0                       ,Nil	,Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Usuário'
		aAdd(aVirtual,{ STR0063  , Nil , 'GET_DATA'		,'D',	08                       , 0                       ,Nil	,Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Data'
		aAdd(aVirtual,{ STR0064  , Nil , 'GET_HORBLQ'	,'C',	TamSX3('DDU_HORBLQ')[1]  , 0                       ,Nil	,Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Hora'
	
		//-- Inclui Somente Se Campo Foi Criado
		If lValor
			aAdd(aVirtual,{ STR0066  , Nil , 'GET_VLRDES'	,'N',	TamSX3('DDU_VLRDES')[1]   , TamSX3('DDU_VLRDES')[2]  ,{|| ValidCampo("GET_VLRDES")},Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Valor Débito'
			aAdd(aVirtual,{ STR0066  , Nil , 'GET_VLRREC'	,'N',	TamSX3('DDU_VLRREC')[1]   , TamSX3('DDU_VLRREC')[2]  ,{|| ValidCampo("GET_VLRREC")},Nil,Nil,Nil,Nil,Nil,.f., .t.}) //-- 'Valor Crédito'
		EndIf	
	
		//-- Define Qual Campo Exibir
		If cMode029 <> 'R'
			aAdd(aVirtual,{ STR0016	, Nil , 'GET_MTVLIB'	,'C',	TamSX3('DDU_MTVLIB')[1]	, 0  ,{|| ValidCampo("GET_MTVLIB")},Nil,Nil,.t.,Nil,Nil,.f., .t.}) //-- 'Motivo Liberação' - Obrigatório
		Else
			aAdd(aVirtual,{ STR0056	, Nil , 'GET_MTVREJ'	,'C',	TamSX3('DDU_MTVLIB')[1]	, 0  ,{|| ValidCampo("GET_MTVREJ")},Nil,Nil,.t.,Nil,Nil,.f., .t.}) //-- 'Motivo Rejeição'  - Obrigatório	
		EndIf	

		If lDDUData
			aAdd(aVirtual,{ STR0084	, Nil , 'GET_DATDDU'	,'D',	TamSX3('DDU_DATA')[1]	, 0  ,{|| ValidCampo("GET_DATDDU")},{|| TMSA29When("GET_DATDDU")},Nil,.f.,Nil,Nil,.f., .t.}) //-- 'Nova Data' - Obrigatório
		EndIf	
	
		For nI := 1 To Len(aVirtual)
	
			oStruct:AddField( ;
			                aVirtual[nI,01]		, ;		// [01] Titulo do campo 
			                aVirtual[nI,01]		, ;		// [02] ToolTip do campo
			                aVirtual[nI,03]		, ;		// [03] Id do Field
			                aVirtual[nI,04]		, ;		// [04] Tipo do campo
			                aVirtual[nI,05]		, ;		// [05] Tamanho do campo
			                aVirtual[nI,06]		, ;		// [06] Decimal do campo
			                aVirtual[nI,07]		, ;		// [07] Code-block de validação do campo
			                aVirtual[nI,08]		, ;		// [08] Code-block de validação When do campo
			                aVirtual[nI,09]		, ;		// [09] Lista de valores permitido do campo
			                aVirtual[nI,10]		, ;		// [10] Indica se o campo tem preenchimento obrigatório
			                aVirtual[nI,11]		, ;		// [11] Code-block de inicializacao do campo
			                aVirtual[nI,12]		, ;		// [12] Indica se trata-se de um campo chave
			                aVirtual[nI,13]		, ;		// [13] Indica se o campo pode receber valor em uma operação de update.
			                aVirtual[nI,14]	    )		// [14] Indica se o campo é virtual
		
		Next nI
		
		/*
			// GATILHO - RTA_ROTA                
			oStruct:AddTrigger( 		;
							'RTA_XROTA'  			, ;     // [01] Id do campo de origem
							'RTA_XDESC'  			, ;     // [02] Id do campo de destino
				 			{ || .T. } 				, ; 	// [03] Bloco de codigo de validação da execução do gatilho
				 			{ || TMS023SX7('RTA_XROTA') } ) // [04] Bloco de codigo de execução do gatilho
		*/ 
	
	Else
	
		//------------------------------+
		// lView = .F. - Estrutura View |
		//------------------------------+	
	
		//--          {   01        , 02 , 03     	, 04     , 05    , 06   ,  07                         , 08 ,09 , 10,11 ,12 ,13 ,14 ,15 ,16
		aAdd(aVirtual,{'GET_ROTINA'	,'01',	STR0057	, STR0057, Nil   ,'GET' , PesqPict('DDU','DDU_ROTINA'), Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Rotina'
		aAdd(aVirtual,{'GET_FILORI'	,'02',	STR0058	, STR0058, Nil   ,'GET' , PesqPict('DDU','DDU_FILORI'), Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Fil.Origem'
		aAdd(aVirtual,{'GET_CODIGO'	,'03',	STR0059	, STR0059, Nil   ,'GET' , PesqPict('DDU','DDU_CODIGO'), Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Código'
		aAdd(aVirtual,{'GET_NIVBLQ'	,'04',	STR0060	, STR0060, Nil   ,'GET' , PesqPict('DDU','DDU_NIVBLQ'), Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Nível Blq.'
		aAdd(aVirtual,{'GET_BLOQ'	,'05',	STR0061	, STR0061, Nil   ,'GET' , PesqPict('DDU','DDU_TIPBLQ'), Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Bloqueio'
		aAdd(aVirtual,{'GET_USUARI'	,'06',	STR0062	, STR0062, Nil   ,'GET' , PesqPict('DDU','DDU_USRBLQ'), Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Usuário'
		aAdd(aVirtual,{'GET_DATA'	,'07',	STR0063	, STR0063, Nil   ,'GET' , PesqPict('DDU','DDU_DATBLQ'), Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Data'
		aAdd(aVirtual,{'GET_HORBLQ'	,'08',	STR0064	, STR0064, Nil   ,'GET' , PesqPict('DDU','DDU_HORBLQ'), Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Hora'
	
		//-- Inclui Somente Se Campo Criado
		If lValor
			aAdd(aVirtual,{'GET_VLRDES'	,'09',	STR0073	, STR0073, Nil   ,'GET' , PesqPict('DDU','DDU_VLRDES') , Nil,Nil,Tmsa029Get("GET_VLRDES"),Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Valor Despesa'
			aAdd(aVirtual,{'GET_VLRREC'	,'10',	STR0074	, STR0074, Nil   ,'GET' , PesqPict('DDU','DDU_VLRREC') , Nil,Nil,Tmsa029Get("GET_VLRREC"),Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Valor Receita'
		EndIf	
	
		//-- Define Qual Campo Exibir
		If cMode029 <> 'R'
			aAdd(aVirtual,{'GET_MTVLIB'	,'11',	STR0016 , STR0016 ,Nil	,'GET'	,'@!',Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Motivo Liberação'
		Else
			aAdd(aVirtual,{'GET_MTVREJ'	,'11',	STR0056 , STR0056 ,Nil	,'GET'	,'@!',Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- 'Motivo Rejeição '
		EndIf	

		If lDDUData 
			aAdd(aVirtual,{'GET_DATDDU'	,'12',	STR0084 , STR0084 ,Nil	,'GET'	,'@D',Nil,Nil,.f.,Nil,Nil,Nil,Nil,Nil,.t.}) //-- Nova Data 
		EndIf	
	
		For nI := 1 To Len(aVirtual)
	
		oStruct:AddField( ;
						aVirtual[nI,01]	,;    	// [01] Campo
						aVirtual[nI,02]	,;    	// [02] Ordem
						aVirtual[nI,03]	,;    	// [03] Titulo   	// Rota
						aVirtual[nI,04]	,;   	// [04] Descricao	// Rota
						aVirtual[nI,05]	,;   	// [05] Help
						aVirtual[nI,06]	,;    	// [06] Tipo do campo   COMBO, Get ou CHECK
						aVirtual[nI,07]	,;    	// [07] Picture
						aVirtual[nI,08]	,;  	// [08] PictVar
						aVirtual[nI,09]	,;		// [09] F3
						aVirtual[nI,10]	,;    	// [10] Editavel
						aVirtual[nI,11]	,;   	// [11] Folder
						aVirtual[nI,12]	,;    	// [12] Group
						aVirtual[nI,13]	,;    	// [13] Lista Combo
						aVirtual[nI,14]	,;    	// [14] Tam Max Combo
						aVirtual[nI,15]	,;    	// [15] Inic. Browse
						aVirtual[nI,16]	) 		// [16] Virtual	
		
		Next nI
		
	EndIf
		
	RestArea( aArea )

Return()

//+--------------------------------------------------------------------------
/*/{Protheus.doc} LoadSGrd1 - Realiza a criação de campos para uma estrutura específica (Grid/aCols).
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 01/Sep/2015
@param Params
	oPar1  --> Objeto com a estrutura dos dados para alteração a passagem deve ocorrer por parametro
	lPar1  --> indica qual tipo de estrutura carregar
		-----> .T. = Model (Default)
		-----> .F. = View
@return Returns
/*/
//+--------------------------------------------------------------------------
Static Function LoadSGrd1(oStruct, lView)
	
	Local aArea    := GetArea()
	Local aVirtual := {}
	Local nI       := 0
	
	DEFAULT lView := .F.
	
	//-------------------------------+
	// lView = .T. - Estrutura Model |
	//-------------------------------+
	If !lView
	
		//--          {   01   		    , 02  ,      03     	,04 ,  05	, 06 , 07, 08, 09, 10, 11, 12,13 ,14
		aAdd(aVirtual,{'Tipo_01'		, Nil , 'GRD_TIPO01'	,'C',	10	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
		aAdd(aVirtual,{'Valor01'		, Nil , 'GRD_VLOR01'	,'C',	60	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
	
		aAdd(aVirtual,{'Tipo_02'		, Nil , 'GRD_TIPO02'	,'C',	10	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
		aAdd(aVirtual,{'Valor02'		, Nil , 'GRD_VLOR02'	,'C',	60	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
	
		aAdd(aVirtual,{'Tipo_03'		, Nil , 'GRD_TIPO03'	,'C',	10	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
		aAdd(aVirtual,{'Valor03'		, Nil , 'GRD_VLOR03'	,'C',	60	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
	
		aAdd(aVirtual,{'Tipo_04'		, Nil , 'GRD_TIPO04'	,'C',	10	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
		aAdd(aVirtual,{'Valor04'		, Nil , 'GRD_VLOR04'	,'C',	60	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
	
		aAdd(aVirtual,{'Tipo_05'		, Nil , 'GRD_TIPO05'	,'C',	10	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
		aAdd(aVirtual,{'Valor05'		, Nil , 'GRD_VLOR05'	,'C',	60	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.})
	
		For nI := 1 To Len(aVirtual)
	
			oStruct:AddField( ;
			                aVirtual[nI,01]		, ;		// [01] Titulo do campo 
			                aVirtual[nI,01]		, ;		// [02] ToolTip do campo
			                aVirtual[nI,03]		, ;		// [03] Id do Field
			                aVirtual[nI,04]		, ;		// [04] Tipo do campo
			                aVirtual[nI,05]		, ;		// [05] Tamanho do campo
			                aVirtual[nI,06]		, ;		// [06] Decimal do campo
			                aVirtual[nI,07]		, ;		// [07] Code-block de validação do campo
			                aVirtual[nI,08]		, ;		// [08] Code-block de validação When do campo
			                aVirtual[nI,09]		, ;		// [09] Lista de valores permitido do campo
			                aVirtual[nI,10]		, ;		// [10] Indica se o campo tem preenchimento obrigatório
			                aVirtual[nI,11]		, ;		// [11] Code-block de inicializacao do campo
			                aVirtual[nI,12]		, ;		// [12] Indica se trata-se de um campo chave
			                aVirtual[nI,13]		, ;		// [13] Indica se o campo pode receber valor em uma operação de update.
			                aVirtual[nI,14]	    )		// [14] Indica se o campo é virtual
		
		Next nI
		
		/*
			// GATILHO - RTA_ROTA                
			oStruct:AddTrigger( 		;
							'RTA_XROTA'  			, ;     // [01] Id do campo de origem
							'RTA_XDESC'  			, ;     // [02] Id do campo de destino
				 			{ || .T. } 				, ; 	// [03] Bloco de codigo de validação da execução do gatilho
				 			{ || TMS023SX7('RTA_XROTA') } ) // [04] Bloco de codigo de execução do gatilho
		*/ 
	
	Else
	
		//------------------------------+
		// lView = .F. - Estrutura View |
		//------------------------------+	
	
		//--          {   01   		, 02 ,      03     	,      04 		,05		, 06 	, 07, 08 , 09, 10, 11, 12,13 ,14 ,15 ,16 })
		aAdd(aVirtual,{'GRD_TIPO01'	,'01',	'Tipo'  		,'Tipo'  		,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
		aAdd(aVirtual,{'GRD_VLOR01'	,'02',	'Valor'     	,'Valor'     	,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
	
		aAdd(aVirtual,{'GRD_TIPO02'	,'03',	'Tipo'  		,'Tipo'  		,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
		aAdd(aVirtual,{'GRD_VLOR02'	,'04',	'Valor'     	,'Valor'     	,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
	
		aAdd(aVirtual,{'GRD_TIPO03'	,'05',	'Tipo'  		,'Tipo'  		,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
		aAdd(aVirtual,{'GRD_VLOR03'	,'06',	'Valor'     	,'Valor'     	,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
	
		aAdd(aVirtual,{'GRD_TIPO04'	,'07',	'Tipo'  		,'Tipo'  		,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
		aAdd(aVirtual,{'GRD_VLOR04'	,'08',	'Valor'     	,'Valor'     	,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
	
		aAdd(aVirtual,{'GRD_TIPO05'	,'09',	'Tipo'  		,'Tipo'  		,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
		aAdd(aVirtual,{'GRD_VLOR05'	,'10',	'Valor'     	,'Valor'     	,Nil	,'GET'	,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
	
		For nI := 1 To Len(aVirtual)
	
		oStruct:AddField( ;
						aVirtual[nI,01]	,;    	// [01] Campo
						aVirtual[nI,02]	,;    	// [02] Ordem
						aVirtual[nI,03]	,;    	// [03] Titulo   	// Rota
						aVirtual[nI,04]	,;   	// [04] Descricao	// Rota
						aVirtual[nI,05]	,;   	// [05] Help
						aVirtual[nI,06]	,;    	// [06] Tipo do campo   COMBO, Get ou CHECK
						aVirtual[nI,07]	,;    	// [07] Picture
						aVirtual[nI,08]	,;  	// [08] PictVar
						aVirtual[nI,09]	,;		// [09] F3
						aVirtual[nI,10]	,;    	// [10] Editavel
						aVirtual[nI,11]	,;   	// [11] Folder
						aVirtual[nI,12]	,;    	// [12] Group
						aVirtual[nI,13]	,;    	// [13] Lista Combo
						aVirtual[nI,14]	,;    	// [14] Tam Max Combo
						aVirtual[nI,15]	,;    	// [15] Inic. Browse
						aVirtual[nI,16]	) 		// [16] Virtual	
		
		Next nI
		
	EndIf
		
	RestArea( aArea )

Return()
//+--------------------------------------------------------------------------
/*/{Protheus.doc} LoadSGrd2 - Realiza a criação de campos para uma estrutura específica (Grid/aCols).
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 23/Nov/2016
@param Params
	oPar1  --> Objeto com a estrutura dos dados para alteração a passagem deve ocorrer por parametro
	lPar1  --> indica qual tipo de estrutura carregar
		-----> .T. = Model (Default)
		-----> .F. = View
@return Returns
/*/
//+--------------------------------------------------------------------------
Static Function LoadSGrd2(oStruct, lView)

	Local aArea    := GetArea()
	Local aVirtual := {}
	Local nI       := 0

	DEFAULT lView := .F.

	//-------------------------------+
	// lView = .T. - Estrutura Model |
	//-------------------------------+
	If !lView

		//--          {   01           , 02  ,      03     	,04 ,  05	, 06 , 07, 08, 09, 10, 11, 12,13 ,14
		aAdd(aVirtual,{ 'ID ' + STR0062 , Nil , 'GRD_IDUSER'	,'C',	06	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- 'Id Usuário'
		aAdd(aVirtual,{ STR0065         , Nil , 'GRD_NOME'  	,'C',	40	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- 'Nome'
		aAdd(aVirtual,{ STR0063         , Nil , 'GRD_DATA'  	,'C',	10	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- 'Data'
		aAdd(aVirtual,{ STR0064         , Nil , 'GRD_HORA'  	,'C',	05	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- 'Hora'
		aAdd(aVirtual,{ STR0075         , Nil , 'GRD_MOTIVO'	,'C',	255	, 0  ,Nil,Nil,Nil,Nil,Nil,Nil,.F., .T.}) //-- "Histórico" -> Era: "Motivo Rejeição"

		For nI := 1 To Len(aVirtual)

			oStruct:AddField( ;
			aVirtual[nI,01]		, ;		// [01] Titulo do campo
			aVirtual[nI,01]		, ;		// [02] ToolTip do campo
			aVirtual[nI,03]		, ;		// [03] Id do Field
			aVirtual[nI,04]		, ;		// [04] Tipo do campo
			aVirtual[nI,05]		, ;		// [05] Tamanho do campo
			aVirtual[nI,06]		, ;		// [06] Decimal do campo
			aVirtual[nI,07]		, ;		// [07] Code-block de validação do campo
			aVirtual[nI,08]		, ;		// [08] Code-block de validação When do campo
			aVirtual[nI,09]		, ;		// [09] Lista de valores permitido do campo
			aVirtual[nI,10]		, ;		// [10] Indica se o campo tem preenchimento obrigatório
			aVirtual[nI,11]		, ;		// [11] Code-block de inicializacao do campo
			aVirtual[nI,12]		, ;		// [12] Indica se trata-se de um campo chave
			aVirtual[nI,13]		, ;		// [13] Indica se o campo pode receber valor em uma operação de update.
			aVirtual[nI,14]	    )		// [14] Indica se o campo é virtual
	
		Next nI
	
	Else

		//------------------------------+
		// lView = .F. - Estrutura View |
		//------------------------------+	
	
		//--          {   01   		, 02 ,  03             , 04              ,05   , 06    , 07 , 08, 09, 10, 11, 12, 13, 14,15 ,16 })
		aAdd(aVirtual,{'GRD_IDUSER'	,'01',	'ID ' + STR0062 , 'ID ' + STR0062 ,Nil  ,'GET'  ,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
		aAdd(aVirtual,{'GRD_NOME'	,'02',	STR0065         , STR0065         ,Nil  ,'GET'  ,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
		aAdd(aVirtual,{'GRD_DATA'	,'03',	STR0063         , STR0063         ,Nil  ,'GET'  ,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
		aAdd(aVirtual,{'GRD_HORA'	,'04',	STR0064         , STR0064         ,Nil  ,'GET'  ,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})
		aAdd(aVirtual,{'GRD_MOTIVO'	,'05',	STR0075         , STR0075         ,Nil  ,'GET'  ,'@!',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.})

		For nI := 1 To Len(aVirtual)

			oStruct:AddField( ;
								aVirtual[nI,01]	,;    	// [01] Campo
								aVirtual[nI,02]	,;    	// [02] Ordem
								aVirtual[nI,03]	,;    	// [03] Titulo   	// Rota
								aVirtual[nI,04]	,;   	// [04] Descricao	// Rota
								aVirtual[nI,05]	,;   	// [05] Help
								aVirtual[nI,06]	,;    	// [06] Tipo do campo   COMBO, Get ou CHECK
								aVirtual[nI,07]	,;    	// [07] Picture
								aVirtual[nI,08]	,;  	// [08] PictVar
								aVirtual[nI,09]	,;		// [09] F3
								aVirtual[nI,10]	,;    	// [10] Editavel
								aVirtual[nI,11]	,;   	// [11] Folder
								aVirtual[nI,12]	,;    	// [12] Group
								aVirtual[nI,13]	,;    	// [13] Lista Combo
								aVirtual[nI,14]	,;    	// [14] Tam Max Combo
								aVirtual[nI,15]	,;    	// [15] Inic. Browse
								aVirtual[nI,16]	) 		// [16] Virtual
	
		Next nI
	
	EndIf
	
	RestArea( aArea )

Return()
//+--------------------------------------------------------------------------
/*/{Protheus.doc} RetContGET - Carrega Valores A Serem Exibidos Na GetDados
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 01/Sep/2015
@param Params
	oPar1  --> Objeto com a estrutura dos dados para alteração a passagem deve ocorrer por parametro
	lPar1  --> indica qual tipo de estrutura carregar
		-----> .T. = Model (Default)
		-----> .F. = View
@return Returns
/*/
//+--------------------------------------------------------------------------
Static Function RetContGET( oModel, lLoad )

	Local aArea 	:= GetArea()
	Local aRet  	:= {}
	Local aCarga  := {}
	Local aVirtual:= {}
	Local nI		:= 0
	Local lValor    := DDU->(ColumnPos("DDU_VLRDES")) > 0	
	Local lDDUData  := DDU->(ColumnPos("DDU_DATA")) > 0	

	aAdd(aVirtual,{'GET_ROTINA' })
	aAdd(aVirtual,{'GET_FILORI' })
	aAdd(aVirtual,{'GET_CODIGO' })
	aAdd(aVirtual,{'GET_NIVBLQ' })
	aAdd(aVirtual,{'GET_BLOQ'   })
	aAdd(aVirtual,{'GET_USUARI' })
	aAdd(aVirtual,{'GET_DATA'   })
	aAdd(aVirtual,{'GET_HORBLQ' })
	
	//-- Inclui Somente Se Campo Foi Criado
	If lValor
		aAdd(aVirtual,{'GET_VLRDES'  })
		aAdd(aVirtual,{'GET_VLRREC'  })
	EndIf	
	
	//-- Se For Rejeição Não Mostra Campo De Motivo Da Liberação
	If cMode029 <> 'R'
		aAdd(aVirtual,{'GET_MTVLIB'})
	Else
		aAdd(aVirtual,{'GET_MTVREJ'})
	EndIf

	If lDDUData 
		aAdd(aVirtual,{'GET_DATDDU'})
	EndIf
	
	//-- Atualliza Vetor De Retorno Dos Campos
	For nI := 1 To Len(aVirtual)

		Do Case
		Case aVirtual[nI,1] == 'GET_ROTINA'
			aAdd(aRet,(cAliasMbw)->DDU_ROTINA + Space(1) + (cAliasMbw)->DDX_DESCRS)
		Case aVirtual[nI,1] == 'GET_FILORI'
			aAdd(aRet,(cAliasMbw)->DDU_FILORI)
		Case aVirtual[nI,1] == 'GET_CODIGO'
			aAdd(aRet,(cAliasMbw)->DDU_CODIGO)
		Case aVirtual[nI,1] == 'GET_NIVBLQ'
			aAdd(aRet,Alltrim(Str((cAliasMbw)->DDU_NIVBLQ)))
		Case aVirtual[nI,1] == 'GET_BLOQ'
			aAdd(aRet,(cAliasMbw)->DDU_TIPBLQ + Space(1) + (cAliasMbw)->DDV_DESCB)
		Case aVirtual[nI,1] == 'GET_USUARI'
			aAdd(aRet,(cAliasMbw)->DDU_USRBLQ + Space(1) + (cAliasMbw)->DDU_NOMBLQ)
		Case aVirtual[nI,1] == 'GET_DATA'
			aAdd(aRet,(cAliasMbw)->DDU_DATBLQ)
		Case aVirtual[nI,1] == 'GET_HORBLQ'
			aAdd(aRet,(cAliasMbw)->DDU_HORBLQ)
		Case aVirtual[nI,1] == 'GET_MTVLIB'
			aAdd(aRet,(cAliasMbw)->DDU_MTVLIB)
		Case aVirtual[nI,1] == 'GET_VLRDES'
			aAdd(aRet,(cAliasMbw)->DDU_VLRDES)			
		Case aVirtual[nI,1] == 'GET_VLRREC'
			aAdd(aRet,(cAliasMbw)->DDU_VLRREC)
		Case aVirtual[nI,1] == 'GET_MTVREJ'
			aAdd(aRet,Space(TamSX3('DDU_MTVLIB')[1]))
		Case aVirtual[nI,1] == 'GET_DATDDU'
			aAdd(aRet,(cAliasMbw)->DDU_DATA)
		EndCase

	Next nI

	aCarga := {aRet,0}

	RestArea(aArea)

Return(aCarga)
//+--------------------------------------------------------------------------
/*/{Protheus.doc} LoadGridGrd - Carrega Valores A Serem Exibidos Na Grid/aCols ( MetaDado Do Campo DDU_DETALH )
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 01/Sep/2015
@param Params
@return Returns
/*/
//+--------------------------------------------------------------------------
Static Function LoadGridGrd(oGridModel, cCampo )

	Local aArea    := GetArea()
	Local aLoad    := {}
	Local aVetIni  := {}
	Local cString  := ""
	Local n1       := 0
	Local n2       := 0
	
	Default cCampo := "DDU_DETALH"
				
	DbSelectArea("DDU")
	DDU->(DbGoTo((cAliasMbw)->DDUREC))
	
	//-- Proteção De Erro Para Função StrToKarr
	If Upper(Alltrim(cCampo)) == "DDU_DETALH"
		cString := StrTran(DDU->DDU_DETALH,'##','# #')
	ElseIf Upper(Alltrim(cCampo)) == "DDU_HISREJ"
		cString := StrTran(DDU->DDU_HISREJ,'##','# #')
	EndIf	

	//-- Proteção De Erro Para Função StrToKarr
	cString := StrTran(cString,'||','| |')

	//-- Converte Cada Pipe Encontrado No Campo Tipo 'Memo' Em Uma Linha
	aVetIni := StrToKarr(cString,"|")

	//-- Converte Cada Sustenido ("#") Em Um Campo Do Vetor
	aVirtual := {}
	For n1 := 1 To Len(aVetIni)

		aAdd(aVirtual,StrToKarr(aVetIni[n1],"#"))

	Next n1
	
	For n1 := 1 To Len(aVirtual)

		aVetIni := {}
		For n2 := 1 To 10

			x1 := n1 //-- Compatibilidade MVC X TDS
			x2 := n2 //-- Compatibilidade MVC X TDS
			
			If Type('aVirtual[x1,x2]') <> 'U'
				aAdd(aVetIni,aVirtual[n1,n2])
			Else
				aAdd(aVetIni,"")
			EndIf
		
		Next n2

		If Len(aVetIni) > 0
			aAdd(aLoad,{0,aVetIni})
		EndIf
	Next n1

	RestArea(aArea)

Return(aLoad)
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidCampo - Função Genérica Para Validação De Campos Virtuais
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 01/Sep/2015
@param Params
		cVar = Nome Campo
		
@return Booleano
/*/
//---------------------------------------------------------------------------------------------------
Static Function ValidCampo(cVar)

	Local aArea      := GetArea()
	Local lRet       := .t.
	Local oModel     := FwModelActive()
	Local nOperation := oModel:GetOperation()
	Local cRotina    := ""
	Local cCodBlq    := ""
	Local nValor     := 0

	Default cVar	:= " "

	Do Case
	Case cVar == "GET_MTVLIB"
		If Empty(FWFldGet("GET_MTVLIB"))
			lRet := .f.
			oModel:SetErrorMessage(oModel:GetId(),"GET_MTVLIB",,,, STR0067 , '' ) //-- "Obrigatório Informar o Motivo Do Desbloqueio!"
			//--Help("",,"TMSA02935",/*Titulo*/, STR0035 /*Mensagem*/,1,0) //-- "Obrigatório Informar o Motivo Do Desbloqueio!"
		EndIf
	Case cVar == "GET_MTVREJ"

		If Empty(FWFldGet("GET_MTVREJ"))
			lRet := .f.
			oModel:SetErrorMessage(oModel:GetId(),"GET_MTVREJ",,,, STR0068 , '' ) //-- "Obrigatório Informar o Motivo Da Rejeição!"
			//--Help("",1,"TMSA02936",/*Titulo*/, /*Mensagem*/,1,0) //-- "Obrigatório Informar o Motivo Da Rejeição!"
		EndIf

	Case cVar == "GET_VLRDES" .Or. cVar == "GET_VLRREC" 

		//-- Verifica Se é Update
		If nOperation == MODEL_OPERATION_UPDATE

			//-- Se For Rejeição Não Deixa Alterar Valor
			If cMode029 == 'R'

				lRet := .f.
				oModel:SetErrorMessage(oModel:GetId(),Iif(cVar == "GET_VLRDES","GET_VLRDES","GET_VLRREC"),,,, STR0069 , '' ) //-- "Este Campo Só Pode Ser Alterado Na Liberação!"
				//--Help("",,"TMSA02937",/*Titulo*/, /*Mensagem*/,1,0) //-- "Este Campo Só Pode Ser Alterado Na Liberação!"

			ElseIf cMode029 <> 'R' //-- Liberação 

				cRotina := Substr(FWFldGet("GET_ROTINA"), 1, TamSX3("DDU_ROTINA")[1])
				cCodBlq := Substr(FWFldGet("GET_BLOQ"), 1, TamSX3("DDU_TIPBLQ")[1])
				
				//---------------------------------------------------------------------------------------------
				//-- Verifica Se Código Pertence Ao Grupo De Receitas Ou Despesas
				//---------------------------------------------------------------------------------------------
				If aScan( aRec , cCodBlq ) > 0 .Or. aScan( aDes , cCodBlq ) > 0 
				
					nValor  := Iif( cVar == "GET_VLRREC", FWFldGet("GET_VLRREC"), FWFldGet("GET_VLRDES") )  

					//-- Valida Valores Negativos
					If nValor < 0
						lRet := .f.
						oModel:SetErrorMessage(oModel:GetId(),"GET_VLRREC",,,, STR0077 , '' ) //-- "Valores Negativos Não São Permitidos!" 					
					EndIf
				
					If lRet
						//-- Rotinas X Bloqueios
						DbSelectArea("DDV")
						DbSetOrder(1) //-- DDV_FILIAL+DDV_ROTINA+DDV_CODBLQ
						If MsSeek( FWxFilial("DDV") + cRotina + cCodBlq , .f. )
					
							//-- Verifica Se Controla Valor
							If DDV->(ColumnPos("DDV_USEVAL")) > 0 .And. DDV->DDV_USEVAL == '1'
							
								//-- Tratamento Valores Zerados
								If nValor <= 0
									//-- Códigos 19 e 20 Podem Ter Valores Zerados
									If cCodBlq <> StrZero( 19, Len(DT2->DT2_TIPOCO)) .And. cCodBlq <> StrZero( 20, Len(DT2->DT2_TIPOCO))
										lRet := .f.
										oModel:SetErrorMessage(oModel:GetId(),"GET_VLRREC",,,, STR0070 , '' ) //-- "Obrigatório Informar o Valor Neste Tipo De Liberação!"
										//--Help("",,"TMSA02938",/*Titulo, /*Mensagem,1,0) //-- "Obrigatório Informar o Valor Neste Tipo De Liberação!"
									EndIf
								Else

									//-- Limites Liberação Por Usuario 
									DbSelectArea("DJP")
									DbSetOrder(1) //-- DJP_FILIAL+DJP_USUARI+DJP_ROTINA+DJP_TPBLQ
									If MsSeek( FWxFilial("DJP") + __cUserID + cRotina + cCodBlq , .f. )
									
										//-- Compara Valor Digitado Com O Limite Cadastrado Para o Usuário
										If nValor > DJP->DJP_LIMITE
											lRet := .f.
											//-- Gravar No DDU, campo DDU_HISREJ Informar qdo o Usuário alterar o valor manualmente antes de liberar registro.
											oModel:SetErrorMessage(oModel:GetId(),"GET_VLRREC",,,, STR0076 + Transform( DJP->DJP_LIMITE, PesqPict("DJP","DJP_LIMITE")), '' ) //-- "Valor informado é acima do limite cadastrado para o usuário: "
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf					
			EndIf			
		EndIf
	Case cVar == "GET_DATDDU"
		cCodBlq := Substr(FWFldGet("GET_BLOQ"), 1, TamSX3("DDU_TIPBLQ")[1])

		If cCodBlq == "PR"  //Prazo de Entrega
			If Empty(FWFldGet("GET_DATDDU"))
				oModel:SetErrorMessage(oModel:GetId(),"GET_DATDDU",,,, STR0086, '' )  //"Obrigatório informar a Nova Data"
				lRet:= .F.
			Else
				DT6->( DbSetOrder( 1 ) )
				If	DT6->(DbSeek( xFilial('DT6') + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE )) 
					If !Empty(DT6->DT6_DATENT)						
						//"Documento já entregue, não é permitido alterar a Data do Prazo de Entrega."
						oModel:SetErrorMessage(oModel:GetId(),"GET_DATDDU",,,, STR0085, '' ) 					
						lRet:= .F.
					ElseIf FWFldGet("GET_DATDDU") < DT6->DT6_DATEMI  						
						//A Data do Prazo de Entrega informada não pode ser menor que a Data de Emissão do Documento de Transporte (CTe) e ou Data do Prazo de Entrega Original. 
						oModel:SetErrorMessage(oModel:GetId(),"GET_DATDDU",,,, STR0083, '' ) 					
						lRet := .F.
					EndIf
				Else	
					lRet:= .F.				 
				EndIf
			EndIf	
		EndIf

	OtherWise
		lRet := .t.
	EndCase

	RestArea(aArea)

Return(lRet)
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosVldMdl - Função Para validação realizada após o preenchimento do modelo de dados (Model) e sua confirmação. Seria o equivalente ao antigo processo de TudoOk. O modelo de dados (Model) já faz a validação se os campos obrigatórios de todos os componentes do modelo foram preenchidos, essa validação é executada após isso.
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 01/Sep/2015
@param Params
		oModel = Modelo MVC
		
@return Booleano
/*/
//---------------------------------------------------------------------------------------------------
Static Function PosVldMdl(oModel)

	Local aArea       := GetArea()
	Local nOperation  := oModel:GetOperation()
	Local lRet        := .T. 

	//-- Na justificativa o status fica como analisado
	If nOperation == MODEL_OPERATION_UPDATE

		If cMode029 <> 'R' .And. Empty(FWFldGet("GET_MTVLIB"))

			lRet := .f.
			oModel:SetErrorMessage(oModel:GetId(),"GET_MTVLIB",,,, STR0067 , '' ) //-- "Obrigatório Informar o Motivo Do Desbloqueio!"
			//--Help("",,"TMSA02935",/*Titulo*/, STR0035 /*Mensagem*/,1,0) //-- "Obrigatório Informar o Motivo Do Desbloqueio!"

		ElseIf cMode029 == 'R' .And. Empty(FWFldGet("GET_MTVREJ"))

			lRet := .f.
			oModel:SetErrorMessage(oModel:GetId(),"GET_MTVREJ",,,, STR0068 , '' ) //-- "Obrigatório Informar o Motivo Do Rejeição!"
			//--Help("",,"TMSA02936",/*Titulo*/, /*Mensagem*/,1,0) //-- "Obrigatório Informar o Motivo Do Rejeição!"

		EndIf
	EndIf	

RestArea(aArea)

Return(lRet)
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CommitMdl - Função Para Gravação Personalizada Do Modelo
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 01/Sep/2015
@param Params
		oModel = Modelo MVC
		
@return Booleano
/*/
//---------------------------------------------------------------------------------------------------
Static Function CommitMdl(oModel)

	Local aArea       := GetArea()
	Local nOperation  := oModel:GetOperation()
	Local lRet        := .T. //-- Tratamento Para Solicitação De Coleta Com Restrição De Crédito
	Local oStruGET    := oModel:GetModel("MdFieldGET")
	Local cGetMot     := Iif( cMode029 <> 'R' , oStruGET:GetValue("GET_MTVLIB"),"")
	Local cGetRej     := Iif( cMode029 == 'R' , oStruGET:GetValue("GET_MTVREJ"),"")
	Local lValor      := DDU->(ColumnPos("DDU_VLRDES")) > 0
	Local nValDES     := Iif( lValor , oStruGET:GetValue("GET_VLRDES") , 0 )  
	Local nValREC     := Iif( lValor , oStruGET:GetValue("GET_VLRREC") , 0 )
	Local lDDUData    := DDU->(ColumnPos("DDU_DATA")) > 0
	Local dDataDDU    := Iif(lDDUData, oStruGET:GetValue("GET_DATDDU"), CtOD(""))
	
	//-- Atualização
	If nOperation == MODEL_OPERATION_UPDATE 
	
		//-- Posiciona Na Tabela DDU Pelo MetaDado
		DbSelectArea("DDU")
		DDU->(DbGoTo((cAliasMbw)->DDUREC))
		
		//-- Verifica Se é Liberação Ou Rejeição
		If cMode029 <> 'R'

			// Utiliza MetaDados da Tabela De Bloqueios Para Localizar Registros
			DbSelectArea(DDU->DDU_ALIAS)
			DbSetOrder(Val(DDU->DDU_INDEX))
			MsSeek(RTrim(DDU->DDU_CHAVE),.f.) // Usa RTrim Para Limpar os Espaços à Direita e Permitir Indexação Sem SoftSeek
						
			If DDU->DDU_ALIAS == "DT5" .And. DDU->DDU_TIPBLQ == PadR('LC',TamSX3("DDU_TIPBLQ")[1]) //-- Sol. Coleta / Crédito
							
				lRet := TMSA460Lib(.f.) // Ajustado Função TMSA460Lib Para Tratar Variável De Retorno
	
			EndIf
	
			//-- Atualiza Tabela DDU
			If lRet
	
				RecLock("DDU",.f.)
	
				Replace DDU->DDU_STATUS  With "2" // Liberado
				Replace DDU->DDU_USRLIB  With RetCodUsr()
				Replace DDU->DDU_NOMLIB  With UsrFullName(RetCodUsr())
				Replace DDU->DDU_DATLIB  With MsDate()
				Replace DDU->DDU_HORLIB  With Substr(Time(),1,5)
				Replace DDU->DDU_MTVLIB  With cGetMot
				If lDDUData
					Replace DDU->DDU_DATA With dDataDDU
				EndIf				

				//-- Grava Campo De Valor Qdo Este Existir
				If lValor
				
					//-- Verifica Se Campo DDU_VLRDES Teve Dados Alterados e Gera Log. Caso Necessário
					cGetRej := ""
					If (cAliasMbw)->DDU_VLRDES <> nValDES
						//-- Modela Metadado Para Gravação No Campo De Histórico De Rejeições/Observações (DDU_HISREJ)
						cGetRej +=	RetCodUsr() 						+ "#" +;	//-- 01 - Código Do Usuário
									Alltrim(UsrFullName(RetCodUsr())) 	+ "#" +;	//-- 02 - Nome
									DtoC(MsDate()) 						+ "#" +;	//-- 03 - Data
									Substr(Time(),1,5) 					+ "#" +;	//-- 04 - Hora
									STR0078 + RetTitle("DDU_VLRDES") + STR0079 + Alltrim(Transform((cAliasMbw)->DDU_VLRDES, PesqPict("DDU","DDU_VLRDES"))) + STR0080 + Alltrim(Transform( nValDES , PesqPict("DDU","DDU_VLRDES"))) + "|"		//-- 05 - "Campo " "Alterado De" "Para"
					EndIf								

					//-- Verifica Se Campo DDU_VLRREC Teve Dados Alterados e Gera Log. Caso Necessário
					If (cAliasMbw)->DDU_VLRREC <> nValREC
						//-- Modela Metadado Para Gravação No Campo De Histórico De Rejeições/Observações (DDU_HISREJ)
						cGetRej +=	RetCodUsr() 						+ "#" +;	//-- 01 - Código Do Usuário
									Alltrim(UsrFullName(RetCodUsr())) 	+ "#" +;	//-- 02 - Nome
									DtoC(MsDate()) 						+ "#" +;	//-- 03 - Data
									Substr(Time(),1,5) 					+ "#" +;	//-- 04 - Hora
									STR0078 + RetTitle("DDU_VLRREC") + STR0079 + Alltrim(Transform((cAliasMbw)->DDU_VLRREC, PesqPict("DDU","DDU_VLRREC"))) + STR0080 + Alltrim(Transform( nValREC , PesqPict("DDU","DDU_VLRREC"))) + "|"		//-- 05 - "Campo " "Alterado De" "Para"
					EndIf

					Replace DDU->DDU_HISREJ  With DDU->DDU_HISREJ + cGetRej
					Replace DDU->DDU_VLRDES  With nValDES
					Replace DDU->DDU_VLRREC  With nValREC

					//-- Realiza o ajuste do valor da receita e despesa no registro da ocorrencia (DUA)
					If DDU->DDU_ALIAS == "DUA"            .And.;
                       DUA->(ColumnPos("DUA_VLRRCT")) > 0 .And.;
					   DUA->(ColumnPos("DUA_VLRDSP")) > 0
						   
						dbSelectArea("DUA")
						DUA->(dbSetOrder(1)) //DUA_FILIAL+DUA_FILOCO+DUA_NUMOCO+DUA_FILORI+DUA_VIAGEM+DUA_SEQOCO
						If MsSeek(RTrim(DDU->DDU_CHAVE),.F.) //-- Usa RTrim para limpar os espaços a direita e permitir indexação sem softseek
							RecLock('DUA', .F.)
							Replace DUA->DUA_VLRRCT With nValREC
							Replace DUA->DUA_VLRDSP With nValDES
							DUA->(MsUnLock())
						EndIf
					EndIf
				EndIf
	
				DDU->(MsUnlock())
	
				//-- Atualiza Temporário Da FwMarkBrowse
				DbSelectArea(cAliasMbw)
				RecLock(cAliasMbw,.f.)
	
				Replace (cAliasMbw)->DDU_OK      With Space(Len((cAliasMbw)->DDU_OK))
				Replace (cAliasMbw)->DDU_STATUS  With "2" // Liberado
				Replace (cAliasMbw)->DDU_USRLIB  With RetCodUsr()
				Replace (cAliasMbw)->DDU_NOMLIB  With UsrFullName(RetCodUsr())
				Replace (cAliasMbw)->DDU_DATLIB  With MsDate()
				Replace (cAliasMbw)->DDU_HORLIB  With Substr(Time(),1,5)
				Replace (cAliasMbw)->DDU_MTVLIB  With cGetMot
				If lDDUData
					Replace (cAliasMbw)->DDU_DATA  With dDataDDU  
				EndIf

				//-- Grava Campo De Valor Qdo Este Existir
				If lValor
					Replace (cAliasMbw)->DDU_VLRDES  With nValDES
					Replace (cAliasMbw)->DDU_VLRREC  With nValREC
				EndIf
	
				(cAliasMbw)->(MsUnlock())
	
				//-------------------------------------------------------------------
				//-- Rotina Que Libera o Registro Objeto Do Bloqueio Em Sua Tabela Base.
				//-------------------------------------------------------------------
				Tmsa029Obj(DDU->DDU_ALIAS,DDU->DDU_CHAVE,.F.)
	
			EndIf
		Else //-- Rejeição

			//-- Atualiza Tabela DDU
			If lRet
			
				//-- Trata Dados
				cGetRej := StrTran( cGetRej ,'#',' ' )
				cGetRej := StrTran( cGetRej ,'|',' ' )

				//-- Modela Metadado Para Gravação No Campo De Histórico De Rejeições/Observações (DDU_HISREJ)
				cGetRej :=	RetCodUsr() 						+ "#" +;	//-- 01 - Código Do Usuário
							Alltrim(UsrFullName(RetCodUsr())) 	+ "#" +;	//-- 02 - Nome
							DtoC(MsDate()) 						+ "#" +;	//-- 03 - Data
							Substr(Time(),1,5) 					+ "#" +;	//-- 04 - Hora
							Alltrim(cGetRej) 					+ "|"		//-- 05 - Motivo Digitado Pelo Usuário
	
				RecLock("DDU",.f.)
	
				Replace DDU->DDU_STATUS  With "3" //-- Rejeitado
				Replace DDU->DDU_HISREJ  With DDU->DDU_HISREJ + cGetRej
	
				DDU->(MsUnlock())
	
				//-- Atualiza Temporário Da FwMarkBrowse
				DbSelectArea(cAliasMbw)
				RecLock(cAliasMbw,.f.)
	
				Replace (cAliasMbw)->DDU_OK      With Space(Len((cAliasMbw)->DDU_OK))
				Replace (cAliasMbw)->DDU_STATUS  With "3" //-- Rejeitado
	
				(cAliasMbw)->(MsUnlock())


				If DDU->DDU_ALIAS == "DUA" //-- Apontamento De Ocorrências	
		
					If DDU->DDU_TIPBLQ == "PR" //Prazo de Entrega					
						DbSelectArea("DUA")
						DUA->(dbSetOrder(1)) //DUA_FILIAL+DUA_FILOCO+DUA_NUMOCO+DUA_FILORI+DUA_VIAGEM+DUA_SEQOCO
						If MsSeek(RTrim(DDU->DDU_CHAVE),.F.) //-- Usa RTrim para limpar os espaços a direita e permitir indexação sem softseek
							DT6->( DbSetOrder( 1 ) )
							If	DT6->( DbSeek( xFilial('DT6') + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE ) )
								RecLock('DT6',.F.)
								DT6->DT6_BLQDOC := StrZero( 2, Len( DT6->DT6_BLQDOC ) )
								MsUnLock()
							EndIf
						EndIf	
					EndIf

				EndIf	
	
			EndIf
		EndIf	
	EndIf

	RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Chk
@autor		: Katia
@descricao	: Exclui os Check List da Viagem
@since		: Nov./2015
@using		: Atualização De Bloqueios TMS.
@review	: --> Utilizado para Fechamento da Viagem - RRE
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa029Chk(cTab,cChave)

	Default cTab  := ""
	Default cChave:= ""

	If !Empty(cChave)
		DJ9->(dbSetOrder(1))
		DJ9->(MsSeek(RTrim(cChave)))
		While DJ9->(!Eof() .And. DJ9_FILIAL+DJ9_FILORI+DJ9_VIAGEM == RTrim(cChave))
			RecLock("DJ9",.F.)
			DJ9->(DbDelete())
			MsUnLock()
			DJ9->(DbSkip())
		EndDo
	EndIf

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Ref
Menu: Parâmetros, chama função para reinformar Pergunte
@author Eduardo Alberti
@since 23/11/2016
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Número do registro
@param [nOpc], Numérico, Opção
@return lRet True ou False
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 15/06/2017:
@obs criada opção de Atualização e para não replicar a lógica, a mesma foi isolada em outra função
/*/
//---------------------------------------------------------------------------------------------------
Function Tmsa029Ref(cAlias, nReg, nOpc)

	Local lRet := .T.

	Default cAlias := ""
	Default nReg   := 0
	Default nOpc   := 0

	lRet := AtzMarkBrw(cAlias, nReg, nOpc, .T.)

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Atz
Menu: Atualizar, chama função para atualização do MarkBrowse
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@since 23/11/2016
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Número do registro
@param [nOpc], Numérico, Opção
@return lRet True ou False
/*/
//---------------------------------------------------------------------------------------------------
Function Tmsa029Atz(cAlias, nReg, nOpc)

	Local lRet := .T.

	Default cAlias := ""
	Default nReg   := 0
	Default nOpc   := 0

	lRet := AtzMarkBrw(cAlias, nReg, nOpc, .F.)

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtzMarkBrw
Atualiza MarkBrowse conforme Pergunte
@author Eduardo Alberti
@since 23/11/2016
@param [cAlias], Caracter, Alias
@param [nReg], Numérico, Número do registro
@param [nOpc], Numérico, Opção
@param [lMostrPerg], Lógico, Indica se deve ou não mostrar o Pergunte (Default: .T.)
@return lRet True ou False
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 15/06/2017:
@obs criada opção de Atualização e para não replicar a lógica, a mesma foi isolada em outra função
/*/
//---------------------------------------------------------------------------------------------------
Static Function AtzMarkBrw(cAlias, nReg, nOpc, lMostrPerg)

	Local cPerg     := "TMSA029"
	Local lRet      := .T.
	Local lTmsa029A := .F.

	Default cAlias     := ""
	Default nReg       := 0
	Default nOpc       := 0
	Default lMostrPerg := .T.

	If  TmsChekSX1("TMSA029A")
		cPerg    := "TMSA029A"
		lTmsa029A:= .T.
	EndIf

	If ! Empty(cAliasMbw)

		If lMostrPerg
			If ! (Pergunte(cPerg, .T.))
				Return()
			EndIf
		EndIf
		
		//-- Recarrega MarkBrowse Conforme Parâmetros
		TmMapExcQr(cAliasMbw,,,lTmsa029A)
	
		//-- Atualiza Tela Do MarkBrowse
		oMrkBrowse:oBrowse:Refresh()

		//-- Reposiciona No Topo Da Tela Do MarkBrowse
		oMrkBrowse:GoTop(.T.)

	Else
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Get - Tratamento Para Propriedades When Na Tabela Virtual "GET"
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 28/Nov/2016
@param Params
		cCampo = Campo Para Tratamento
		
@return Nil
/*/
//---------------------------------------------------------------------------------------------------
Function Tmsa029Get( cCampo )

	Local lRet    := .f.
	Local aArea   := GetArea()
	Local cRotina := (cAliasMbw)->DDU_ROTINA
	Local cCodBlq := (cAliasMbw)->DDU_TIPBLQ
	
	//-- Posiciona Na Tabela DDU Pelo Recno
	DbSelectArea("DDU")
	DDU->(DbGoTo((cAliasMbw)->DDUREC))

	//-- Verifica Se Tabela é De Ocorrencias ( Utiliza Campo De Valores )
	If DDU->DDU_ALIAS == "DUA"
	
		// Utiliza MetaDados da Tabela De Bloqueios Para Localizar Registros
		DbSelectArea(DDU->DDU_ALIAS)
		DbSetOrder(Val(DDU->DDU_INDEX))
		MsSeek(RTrim(DDU->DDU_CHAVE),.f.) // Usa RTrim Para Limpar os Espaços à Direita e Permitir Indexação Sem SoftSeek
	
		//-- Posiciona No Cad. Ocorrencias
		DbSelectArea("DT2")
		DbSetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
		If MsSeek( FWxFilial("DT2") + DUA->DUA_CODOCO ) .And. DT2->DT2_ALTVLR == '1' //-- Permite Alterar Valor 	

			If cCampo == "GET_VLRDES"
		
				//-- Verifica Se Código Pertence Ao Grupo De Despesas
				If aScan( aDes , cCodBlq ) > 0
				
					//-- Rotinas X Bloqueios
					DbSelectArea("DDV")
					DbSetOrder(1) //-- DDV_FILIAL+DDV_ROTINA+DDV_CODBLQ
					If MsSeek( FWxFilial("DDV") + cRotina + cCodBlq , .f. )
					
						//-- Verifica Se Controla Valor
						If DDV->DDV_USEVAL == '1'
							lRet := .t.
						EndIf
					EndIf
				EndIf	
			ElseIf cCampo == "GET_VLRREC"
		
				//-- Verifica Se Código Pertence Ao Grupo De Receitas
				If aScan( aRec , cCodBlq ) > 0
		
					//-- Rotinas X Bloqueios
					DbSelectArea("DDV")
					DbSetOrder(1) //-- DDV_FILIAL+DDV_ROTINA+DDV_CODBLQ
					If MsSeek( FWxFilial("DDV") + cRotina + cCodBlq , .f. )
					
						//-- Verifica Se Controla Valor
						If DDV->DDV_USEVAL == '1'
							lRet := .t.
						EndIf
					EndIf
				EndIf	
			EndIf
		EndIf	
	EndIf
	
	RestArea(aArea)

Return( lRet )
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa029Aut - Tratamento Para Liberação Automática Conforme Acessos Do Usuário
@owner  Eduardo Alberti
@author Eduardo Alberti
@since 27/Dez/2016
@param Params
		cModLib = Modalidade De Liberação
		aParLib = Parametros Para Liberação Automática
		//-- Modelo Chamada
		//-- Tmsa029Lib( Nil , { 'TMSA360',DT2->DT2_TIPOCO,cFilDoc,'DUA','1',cChvRD,cViagem} )		
@return Nil
/*/
//---------------------------------------------------------------------------------------------------
Static Function Tmsa029Aut(cModLib,aParLib)

	Local cPerg      := "TMSA029"
	Local aAlias     := {}
	Local aColumns   := {}
	Local lRet       := .t.
	Local cCodUsr	 := RetCodUsr()
	Local cUsrName	 := UsrFullName(RetCodUsr())
	Local dData      := MsDate()
	Local cTipBlqLC	 := PadR('LC',TamSX3("DDU_TIPBLQ")[1])
	Local lTmsa029A  := .F.

	If  TmsChekSX1("TMSA029A")
		lTmsa029A:= .T.
		cPerg    := "TMSA029A"
	EndIf

	//-- Proteção De Erro Da Rotina Caso o Dicionário Da Rotina Não Exista
	If !(AliasInDic("DDU"))
		//-- Mensagem genérica solicitando a atualização do sistema.
		MsgNextRel()
		Return()
	EndIf
	
	If cModLib <> 'L' .Or. Empty(aParLib)
		Return(.F.)
	EndIf

	SaveInter()

	Pergunte( cPerg ,.f.)

	MV_PAR01 := 2			//-- Somente Bloqueados
	MV_PAR02 := dDataBase
	MV_PAR03 := dDataBase
	MV_PAR04 := aParLib[1]
	If !lTmsa029A
		MV_PAR05 := aParLib[1]
	Else
		MV_PAR05 := ""
	EndIf

	//----------------------------------------------------------
	//-- Retorna Temporário Para Liberação Automática
	//----------------------------------------------------------
	aAlias      := TmMapExcQr( Nil, aParLib,.F.,lTmsa029A)
	cAliasMbw   := aAlias[1]
	aColumns    := aAlias[2]
	
	If !Empty(cAliasMbw)
	
		DbSelectArea(cAliasMbw)
		(cAliasMbw)->(DbGoTop())
	
		While (cAliasMbw)->(!Eof())
		
			lRet := .t.
	
			//-- Posiciona Na Tabela DDU Pelo MetaDado
			DbSelectArea("DDU")
			DDU->(DbGoTo((cAliasMbw)->DDUREC))
		
			// Utiliza MetaDados da Tabela De Bloqueios Para Localizar Registros
			DbSelectArea(DDU->DDU_ALIAS)
			DbSetOrder(Val(DDU->DDU_INDEX))
			MsSeek(RTrim(DDU->DDU_CHAVE),.f.) // Usa RTrim Para Limpar os Espaços à Direita e Permitir Indexação Sem SoftSeek
						
			If DDU->DDU_ALIAS == "DT5" .And. DDU->DDU_TIPBLQ == cTipBlqLC //-- Sol. Coleta / Crédito
							
				lRet := TMSA460Lib(.f.) // Ajustado Função TMSA460Lib Para Tratar Variável De Retorno
	
			EndIf
	
			//-- Atualiza Tabela DDU
			If lRet
	
				RecLock("DDU",.f.)
	
				Replace DDU->DDU_STATUS  With "2" // Liberado
				Replace DDU->DDU_USRLIB  With cCodUsr
				Replace DDU->DDU_NOMLIB  With cUsrName
				Replace DDU->DDU_DATLIB  With dData
				Replace DDU->DDU_HORLIB  With Substr(Time(),1,5)
				Replace DDU->DDU_MTVLIB  With STR0081 //-- "Liberação Automática"
				
				DDU->(MsUnlock())
	
				//-------------------------------------------------------------------
				//-- Rotina Que Libera o Registro Objeto Do Bloqueio Em Sua Tabela Base.
				//-------------------------------------------------------------------
				Tmsa029Obj(DDU->DDU_ALIAS,DDU->DDU_CHAVE,.T.)
	
			EndIf

			(cAliasMbw)->(DbSkip())
	
		EndDo
	EndIf

	//-- Fecha Temporários
	If !Empty (cAliasMbw)
		dbSelectArea(cAliasMbw)
		dbCloseArea()
		cAliasMbw := ""
	EndIf

	RestInter()

Return(lRet)

/*/{Protheus.doc} TMSA029DDN
// Realiza a gravação na tabela DDN - Acréscimos/Decréscimos
@author caio.y
@since 25/01/2017
@version 1.0
@param lUpsert, Boolean, Inclusão/Alteração?
@param cFilOri, characters, Filial da Viagem
@param cViagem, characters, Número da Viagem
@param cFilOco, characters, Filial da Ocorrência
@param cNumOco, characters, Código da Ocorrência
@param cSeqOco, characters, Sequencia da Ocorrência
@param nValorDDN, numeric, Valor da Ocorrência
@param cCodAED, characters, Código da Ocorrência
@type function
/*/
Static Function TMSA029DDN( lUpsert , cFilOri , cViagem , cFilOco, cNumOco , cSeqOco, nValorDDN , cCodAed )
Local lRet		:= .F. 	
Local aArea		:= GetArea()
Local nOpc		:= 3 

Default lUpsert		:= .T. 
Default cFilOri		:= ""
Default cViagem		:= ""
Default cFilOco		:= xFilial("DT2")
Default cNumOco		:= ""
Default cSeqOco		:= StrZero(1,Len(DUA->DUA_SEQOCO))
Default nValorDDN	:= 0
Default cCodAed		:= ""

If lUpsert
	lRet	:= .F. 	
		
	If DT2->(ColumnPos('DT2_CODAED')) > 0 .And. !Empty(cCodAed) 
		lRet	:= .T. 			
		DDN->( dbSetOrder(3) ) //-- FILIAL+FILOCO+NUMOCO+SEQOCO
		If DDN->( MsSeek( xFilial("DDN") + cFilOco + cNumOco + cSeqOco ))
			nOpc	:= 4						
		Else
			nOpc	:= 3
		EndIf				
	EndIf

	
Else
	
	lRet	:= .F. 	
	If DT2->(ColumnPos('DT2_CODAED')) > 0 
		DDN->( dbSetOrder(3) ) //-- FILIAL+FILOCO+NUMOCO+SEQOCO
		If DDN->( MsSeek( xFilial("DDN") + cFilOco + cNumOco + cSeqOco ))
			nOpc	:= 5	
			lRet	:= .T. 				
		EndIf		
	EndIf
	
EndIf

//-- Efetua a gravação do histórico de acrescimo/decrescimo
If lRet	
	lRet	:= AF77GrvDDN( nOpc , cFilOri, cViagem , Nil , cCodAed ,  nValorDDN , cFilOco ,cNumOco , cSeqOco  )	
EndIf

RestArea(aArea)
Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA29When - Função Genérica Para Validação do When do Campo
@owner  
@author Katia
@since 18/Sep/2019
@param Params
		
@return Booleano
/*/
//---------------------------------------------------------------------------------------------------
Function TMSA29When(cCampo)

	Local lRet       := .T.
	
	Default cCampo   := ReadVar()

	If cCampo  == "GET_DATDDU"
		If DDU->DDU_TIPBLQ <> "PR" .Or. cMode029 == "R"  //PR- Prazo de Entrega ou Rejeição
			lRet := .F.
		EndIf
	EndIf

Return lRet			

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} TMS029Par - Configura os Parametros para utilizar na condição da Query 
@owner  
@author Katia
@since 18/Sep/2019
@param Params	
@return Caracter
/*/
//---------------------------------------------------------------------------------------
Function TMS029Par(cMVPar)
	Local cRet    := ''
	Local aTpBloq := {}
	Local nY      := 0

	Default cMVPar:= ""

	aTpBloq := StrTokArr(AllTrim(cMVPar),",")
	For nY := 1 to Len(aTpBloq)
		If !Empty(aTpBloq[nY])
			If nY == 1
				cRet +=  " ('" + aTpBloq[nY] + "'"
			Else
				cRet += ", '" + aTpBloq[nY] + "'"
			EndIf
		EndIf
	Next
	If !Empty(aTpBloq[1])
		cRet += ")"
	EndIf	

Return AllTrim(cRet)
