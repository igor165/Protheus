#include "TECA580B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
Static oHashDia := nil
//----------------------------------------------------------
/*/{Protheus.doc} TECA580B()
Gestão de Escalas

@Return 	nil
@author 	Serviços
@since 		15/05/2014
/*/
//----------------------------------------------------------
Function TECA580B()
Local aColumns	:= {}
Local aFiltros	:= {}
Local cQuery		:= ""
Local cAliasGES	:= "TECA580BTRAB"
Local oDlg 		:= Nil   							// Janela Principal.
Local aSize	 	:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local oBrwAcessos := Nil
Local aMenu
Local nI

//Foram Criadas as variáveis para controle do PONA080
Private INCLUI := .T.
Private ALTERA := .F.

If FindFunction("At190DAvis") //Nova mesa - teca190d
	At190DAvis()
Endif

dbSelectArea("TFF")
dbSelectArea("ABQ")
dbSelectArea("ABB")

//Criacao dos tipos de movimentos PADROES do sistema caso nao existam
At690Unit()

Pergunte("TEC580B",.F.)

aInfoColumn := At580BCols()
cQuery   := At580BQuery(aInfoColum[2])
IF !isBlind()
	SetKey( VK_F12 ,{|| Pergunte("TEC580B",.T.), Refresh(oBrwAcessos, .F.)})//Filtro através de F12

	//Cria a tela para o browse
	DEFINE DIALOG oDlg TITLE STR0001 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL // STR0001//"Gestão de Escalas"
		oBrwAcessos := FWFormBrowse():New()
		oBrwAcessos:SetOwner(oDlg)
		
		oBrwAcessos:AddLegend({|| At580BLeg(oBrwAcessos) == 1 },"BR_AZUL", STR0074) //Posto encerrado
		oBrwAcessos:AddLegend({|| At580BLeg(oBrwAcessos) == 5 },"BR_LARANJA",STR0068) //Contrato em revisão
		oBrwAcessos:AddLegend({|| At580BLeg(oBrwAcessos) == 4 },"BR_VERMELHO",STR0026 ) //Escala não configurada
		oBrwAcessos:AddLegend({|| At580BLeg(oBrwAcessos) == 2 },"BR_AMARELO",STR0027) //Nenhum atendente relacionado
		oBrwAcessos:AddLegend({|| At580BLeg(oBrwAcessos) == 3 },"BR_VERDE",STR0028) //Possui atendentes relacionados
		
		oBrwAcessos:SetDataQuery(.T.)
		oBrwAcessos:SetQuery(cQuery)
		oBrwAcessos:SetAlias(cAliasGES)
		oBrwAcessos:SetUseFilter( .T. )
		oBrwAcessos:SetFieldFilter(aInfoColumn[2])
		oBrwAcessos:SetColumns(aInfoColumn[1])

		oBrwAcessos:AddButton( STR0003, {|| Tx580PxC( (oBrwAcessos:cAlias)->TFF_COD,(oBrwAcessos:cAlias)->TFF_CONTRT )}) //"Posto x Calendario"
		oBrwAcessos:AddButton( STR0004, {|| Tx580PxE((oBrwAcessos:cAlias)->TFF_COD,(oBrwAcessos:cAlias)->TFF_CONTRT),;
															Pergunte("TEC580B",.F.),;
															Refresh(oBrwAcessos)} )//"Posto x Escala"
		oBrwAcessos:AddButton( STR0005, {|| Tx580PxF((oBrwAcessos:cAlias)->TFF_COD, (oBrwAcessos:cAlias)->TFF_CONTRT),;
															Pergunte("TEC580B",.F.),;
															Refresh(oBrwAcessos)} )//"Posto x Funcionario"
		oBrwAcessos:AddButton( STR0009, {|| At580BAloc((oBrwAcessos:cAlias)->TFF_COD,1,(oBrwAcessos:cAlias)->TFF_CONTRT )} )//"Alocação por escala"
		oBrwAcessos:AddButton( STR0010, {|| At580BAloc((oBrwAcessos:cAlias)->TFF_COD,2 )} )//"Alocação automatica"
		oBrwAcessos:AddButton( STR0041, {|| At580BAten((oBrwAcessos:cAlias)->TFF_COD) } ) //Buscar Agendas
		oBrwAcessos:AddButton( STR0013, {|| At580GerMem((oBrwAcessos:cAlias)->TFF_CONTRT,(oBrwAcessos:cAlias)->TFF_CONREV)},,,, .F., 2 )//"Memorando"
		oBrwAcessos:AddButton( STR0042, {|| At580Legen()} ) //Legendas
		If ExistBlock('AT580BOAct')
			ExecBlock('AT580BOAct', .F. , .F., {oBrwAcessos})
		EndIf
		oBrwAcessos:DisableDetails()
		oBrwAcessos:SetDescription(STR0002)  //"Gestão de Escalas"
		oBrwAcessos:Activate()

	ACTIVATE DIALOG oDlg CENTERED

	oBrwAcessos:DeActivate()

	SetKey( VK_F12, Nil )
EndIf
Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580BQuery

Query com os dados da gestão de escala

@author 	Serviços
@since 		14/05/2014
@version 	P12

@return	cQuery - Query com as informações da gestão de escala
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At580BQuery(aColumns)

Local cQuery := ""
Local nI := 1
Local cVazio := ""
Local lPerg07 := TecHasPerg("MV_PAR07","TEC580B")
Local lPerg0809 := lPerg07 .and.  TecHasPerg("MV_PAR08","TEC580B") .AND. TecHasPerg("MV_PAR09","TEC580B")
Local lPerg1011 := lPerg0809 .AND. TecHasPerg("MV_PAR10","TEC580B") .AND. TecHasPerg("MV_PAR11","TEC580B")

cQuery += "SELECT "
For nI := 1 To Len(aColumns)
	If aColumns[nI][1] <> "Q3_DESCSUM"
		
		If Left(aColumns[nI][1], 3) == "TFF" .OR. !(aColumns[nI, 3] == "C" .OR. aColumns[nI, 3] == "D" .OR. aColumns[nI, 3] == "N")
			cQuery += " "+aColumns[nI][1]+","
		Else	
			cVazio := IIF(aColumns[nI, 3] == "C" .OR. aColumns[nI, 3] == "D"," '" + space(aColumns[nI, 4]) + "' ", " 0 ")
			cQuery += " CASE WHEN "+aColumns[nI][1]+" IS NOT NULL THEN " +aColumns[nI][1]+ " ELSE "+ cVazio+ " END " +aColumns[nI][1]+ ","
		EndIf
	EndIf
Next nI
cQuery := substr(cQuery, 1, Len(cQuery)-1)

cQuery += " FROM " + RetSqlName("TFF") + " TFF "
cQuery += "JOIN " + RetSqlName("CN9") + " CN9 ON "
cQuery += " CN9.CN9_FILIAL = '" + xFilial("CN9") + "' AND "
cQuery += " CN9.CN9_NUMERO = TFF.TFF_CONTRT AND "
cQuery += " CN9.CN9_REVISA = TFF.TFF_CONREV AND "
cQuery += " CN9.CN9_SITUAC = '05' AND "
cQuery += " CN9.D_E_L_E_T_ = ' ' "

cQuery += "JOIN " + RetSqlName("TFL") + " TFL ON "
cQuery += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
cQuery += " TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
cQuery += " TFL.D_E_L_E_T_ = ' ' "

cQuery += "JOIN " + RetSqlName("TFJ") + " TFJ ON "
cQuery += " TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
cQuery += " TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
cQuery += " TFJ.TFJ_STATUS = '1' AND " //Filtra somente orçamento de serviços ativo
cQuery += " TFJ.D_E_L_E_T_ = ' ' "

cQuery += "LEFT JOIN " + RetSqlName("ABS") + " ABS ON "
cQuery += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND "
cQuery += " ABS.ABS_LOCAL = TFF.TFF_LOCAL AND "
cQuery += " ABS.D_E_L_E_T_ = ' ' "

cQuery += "LEFT JOIN "+RetSqlName("SA1") + " SA1 ON "
cQuery += " SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
cQuery += " SA1.A1_COD = ABS.ABS_CODIGO AND "
cQuery += " SA1.A1_LOJA = ABS.ABS_LOJA AND "
cQuery += " SA1.D_E_L_E_T_ = ' ' "

cQuery += "LEFT JOIN " + RetSqlName("SB1") + " SB1 ON "
cQuery += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
cQuery += " SB1.B1_COD = TFF.TFF_PRODUT AND "
cQuery += " SB1.D_E_L_E_T_ = ' ' "

cQuery += "LEFT JOIN " + RetSqlName("SRJ") + " SRJ ON "
cQuery += " SRJ.RJ_FILIAL = '" + xFilial("SRJ") + "' AND "
cQuery += " SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO AND  "
cQuery += " SRJ.D_E_L_E_T_ = ' ' "

cQuery += "WHERE TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
cQuery += " TFF.TFF_CONTRT BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
If lPerg0809
	cQuery += " TFF.TFF_CARGO BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' AND "
EndIf
If lPerg1011
	cQuery += " TFF.TFF_COD BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "' AND "
EndIf

cQuery += " ABS.ABS_CODIGO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR03+"' AND "
cQuery += " ABS.ABS_LOJA BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR04+"' AND "
If lPerg07
	If MV_PAR07 == 2
		cQuery += " TFF.TFF_ENCE <> '1' AND "
	EndIf
EndIf
cQuery += " TFF.TFF_COD NOT IN((SELECT TFF_COD FROM "+RetSqlName("TFF")+" TFF_SUB WHERE TFF_SUB.TFF_COD = TFF_SUB.TFF_CODSUB)) AND TFJ_STATUS = '1'"
cQuery += "AND TFF.D_E_L_E_T_ = ' ' "
If TecBHasGvg()
	cQuery += " AND TFF.TFF_GERVAG != '2' "
EndIf
cQuery += "ORDER BY TFF.TFF_LOCAL, TFF.TFF_CONTRT, TFF.TFF_CONREV"

Return(cQuery)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580BCols

Colunas e filtros para o browse com os dados da gestão de escala

@author 	Serviços
@since 		14/05/2014
@version 	P12

@return	aInfoColumn - [aColumns - Colunas para o browse, aFiltros - Descrição dos filtros do Browse]
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At580BCols()

Local nI		 := 0
Local aColumns := {}
Local aFiltros := {}
Local cCampo   := ''
Local nLinha   := 0
Local aCampos := { "TFF_COD","TFF_LOCAL", "ABS_DESCRI", "TFF_CONTRT","TFF_CONREV",;
					 "TFF_FUNCAO","RJ_DESC","TFF_ESCALA","A1_COD",;
					 "A1_LOJA", "A1_NOME", "TFF_PRODUT", "B1_DESC", "TFF_QTDVEN",;
					 "TFF_TURNO", "TFF_ENCE", "TFF_CARGO", "Q3_DESCSUM"}
Local lTE580BRW := EXISTBLOCK("TE580BRW")
Local aUSRCpos := {}
Local aAreaSX3 := {}
Local lCloseSX3 := .F.
Local aArea := {}

//Personalização dos campos do browse
If lTE580BRW
   	aUSRCpos := Execblock("TE580BRW",.F.,.F.,{aCampos})
   	If Len(aUSRCpos) > 0
   		aCampos := aUSRCpos
   	Endif
Endif

aArea := GetArea()

lCloseSX3 := Select("SX3") == 0

RestArea(aArea)

If lCloseSX3
	dbSelectArea("SX3")
Else
	aAreaSX3 := SX3->(GetArea())
EndIf

SX3->(DbSetOrder(2))

For nI:=1 To Len(aCampos)

	If SX3->(dbSeek(aCampos[nI]))

		cCampo := AllTrim(SX3->X3_CAMPO)

		AAdd(aColumns,FWBrwColumn():New())
		nLinha := Len(aColumns)
	   	aColumns[nLinha]:SetType(SX3->X3_TIPO)
	   	aColumns[nLinha]:SetTitle(X3Titulo())
		aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
		aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)
		If aCampos[nI] != "Q3_DESCSUM"
			aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))
		Else
			aColumns[nLinha]:SetData(&("{||POSICIONE('SQ3',1,xFilial('SQ3')+TFF_CARGO,'"+cCampo+"')}"))
		EndIf

		aadd(aFiltros,{cCampo,X3Titulo(),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE})

	EndIf

Next nI

If lCloseSX3
	SX3->(dbCloseArea())
Else
	RestArea(aAreaSX3)
EndIf


Return{aColumns, aFiltros}


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580BAloc
Rotinas para a alocação do recurso selecionado

@author 	Serviços
@since 		03/07/2014
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580BAloc( cCodTFF, nOpcx, cCodContrt )

Local lRh := ( ( FindFunction("U_PNMSESC") .And. FindFunction("U_PNMSCAL") ) .OR. ( FindFunction( "TecExecPNM" ) .AND. TecExecPNM() ) )
Local lConfirm

If lRh
	If nOpcx == 1 // Alocação por escala
			dbSelectArea("TFF")
			TFF->(dbSetOrder(1))

		If TFF->(dbSeek(xFilial("TFF")+cCodTFF)) .AND. TFF->TFF_ENCE != '1'
			If Pergunte( "TEC580BE", .T. )
				If !IsBlind()
					If MV_PAR01 < TFF->TFF_PERINI .Or. MV_PAR02 > TFF->TFF_PERFIM
						If MsgYesNo( STR0020 + CRLF + CRLF + ;
							 STR0021 + CRLF +  STR0022 + DToc(MV_PAR01) + STR0023 + DToc(MV_PAR02) + CRLF + CRLF + ;
							 STR0025 + CRLF +  STR0022 + DToc(TFF->TFF_PERINI) + STR0023 + DToc(TFF->TFF_PERFIM) +  CRLF + CRLF + STR0024, STR0025)

							 MV_PAR01 := TFF->TFF_PERINI
							 MV_PAR02 := TFF->TFF_PERFIM

						EndIf
					EndIf
				EndIf
				If At580BSit(cCodContrt) == '1'
					lConfirm := ( FWExecView( STR0009, "VIEWDEF.TECA330A", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  //  "Alocacao por escala"
								{||.T.}/*bOk*/,/*nReducao*/, /*aButtons*/, {||.T.}/*bCancel*/ ) == 0 )
				Else
					Help(,,"At580BSit",,STR0070,1,0)
					lConfirm := ( FWExecView( STR0009, "VIEWDEF.TECA330A", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  //  "Alocacao por escala"
								{||.T.}/*bOk*/,/*nReducao*/, /*aButtons*/, {||.T.}/*bCancel*/ ) == 0 )
				EndIf
			EndIf
		Else
			Help(,,"AT580ENCPOST",,STR0019,1,0) //"Posto Encerrado, não poderá gerar novas agendas"
		EndIf
	ElseIf nOpcx == 2 // Alocação automática
		If Pergunte( "TEC580BA", .T. )
			At330AloAut( MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09, MV_PAR10, MV_PAR11, MV_PAR12, MV_PAR13, MV_PAR14 )
		EndIf
	EndIf
Else
	Help( " ", 1, STR0011, Nil, STR0012, 1 )  //"Atenção"#"Para que seja possivel executar essa rotina, aplique o patch para as configurações do RH!"
EndIf

Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tx580PxC

Chamada do relacionamento Feriado X Posto

@author 	Serviços
@since 		08/04/2014
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Function Tx580PxC(cCodTFF, cTFFContrt)

Local nPercReducao := 50

//Foi necessario abrir o SX3
DbSelectArea("SX3")
SX3->(DbSetOrder(1))

DbSelectArea("TFF")
TFF->(DbSetOrder(1))

If TFF->(DbSeek(xFilial("TFF")+cCodTFF))
	If At580BSit(cTFFContrt) == '1'
		FWExecView(Upper(STR0006),"VIEWDEF.TECA580D",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,{||.T.},nPercReducao )	//"Relacionamento FeriadoxPosto"
	Else
		Help(,,"At580BSit",,STR0070,1,0)
		FWExecView(Upper(STR0006),"VIEWDEF.TECA580D",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,{||.T.},nPercReducao )	//"Relacionamento FeriadoxPosto"
	EndIf
EndIf

Return(.T.)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tx580PxE

Chamada para o relacionamento  Posto X Escala

@author 	Serviços
@since 		08/04/2014
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Function Tx580PxE(cCodTFF,cTFFContrt)

Local nPercReducao	:= 50
Local lAbbHr		:= .T.


//Foi necessario abrir o SX3
DbSelectArea("SX3")
SX3->(DbSetOrder(1))

DbSelectArea("TFF")
TFF->(DbSetOrder(1))

If TFF->(DbSeek(xFilial("TFF")+cCodTFF))
	lAbbHr := TecABBPRHR() .AND. TecConvHr(TFF->TFF_QTDHRS) > 0
	If !lAbbHr
		If !FindFunction("At740VlEsc") .Or. (FindFunction("At740VlEsc") .And. At740VlEsc(cCodTFF))
			If At580BSit(cTFFContrt) == '1'
				FWExecView(Upper(STR0007),"VIEWDEF.TECA580C",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,{||.T.},nPercReducao )	//"Relacionamento PostoXEscala"
			Else
				Help(,,"At580BSit",,STR0070,1,0)
				FWExecView(Upper(STR0007),"VIEWDEF.TECA580C",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,{||.T.},nPercReducao )	//"Relacionamento PostoXEscala"
			EndIf
		Endif
	Else
		Help(,,"At580BSit",,STR0078,1,0) // "Não é possivel configurar escala em posto que tenha alocação por hora!"
	EndIf
EndIf

Return(.T.)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tx580PxE

Chamada para o relacionamento  Posto X Funcionario

@author 	Serviços
@since 		08/04/2014
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Function Tx580PxF(cCodTFF,cTFFContrt)
Local lMV_GSGEHOR := SuperGetMV("MV_GSGEHOR",,.F.)
Local aArea

Local aButtons := {}
Local lRevis	:= At580BSit(cTFFContrt) == '2'


//Foi necessario abrir o SX3
DbSelectArea("SX3")
SX3->(DbSetOrder(1))

DbSelectArea("TFF")
TFF->(DbSetOrder(1))

If TFF->(DbSeek(xFilial("TFF")+cCodTFF)) .AND. TFF->TFF_ENCE != '1'
	If lMV_GSGEHOR
		aArea := GetArea()
		At580EGHor((VldEscala(TFF->(RECNO()))))
		RestArea(aArea)
	EndIf
	If At580BSit(cTFFContrt) == '1'
		FWExecView(Upper(STR0008),"VIEWDEF.TECA580E",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/ )	//"Relacionamento PostoXFuncionario"
	Else
		Help(,,"At580BSit",,STR0070,1,0)
		FWExecView(Upper(STR0008),"VIEWDEF.TECA580E",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/ )	//"Relacionamento PostoXFuncionario"
	EndIf
	If VALTYPE( At580bHash() ) == 'O'
		oHashDia:Destroy()
		oHashDia := nil
	EndIf
Else
	Help(,,"AT580ENCPOST",,STR0019,1,0) //"Posto Encerrado, não poderá gerar novas agendas"
EndIf

Return(.T.)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Refresh
@author 	Serviços
@since 		08/04/2014
@version 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Refresh(oBrowse)
	Local aInfoColumn := At580BCols()
	Local cQuery   	:= At580BQuery(aInfoColum[2])

	oBrowse:SetQuery(cQuery)

	oBrowse:Refresh()
	oBrowse:ExecuteFilter(.T.)

	SetKey( VK_F12 ,{|| Pergunte("TEC580B",.T.), Refresh(oBrowse, .F.)})//Filtro através de F12

Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580GerMem
@since        05/02/2015
@version      12
@sample       At580GerMem(cNumContr, cRevContr)
@param        cNumContr - Numero do Contrato
@param        cRevContr - Numero da Revisao
@return       lRet, Retorno logico
@description Realiza consistencias e chama tela de memorando
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At580GerMem(cNumContr, cRevContr)

Local lRet      := .F.
Local aAreaMe   := GetArea()
Local cAliasCN9 := GetNextAlias()
Local cMaxRev   := Space(TamSX3("CN9_REVISA")[1])

// Somente podera gerar o memorando para contratos vigentes
If ! Empty(cNumContr)
	DbSelectArea("CN9")
	CN9->(DbSetOrder(1)) // CN9_FILIAL, CN9_NUMERO, CN9_REVISA
	If CN9->(DbSeek(xFilial("CN9")+cNumContr+cRevContr))

		If CN9_SITUAC == '05'
		// Verifica se contrato possui revisao
			BeginSql Alias cAliasCN9

				SELECT MAX(CN9.CN9_REVISA) AS CN9_REVISA
				  FROM %table:CN9% CN9
				 WHERE CN9.CN9_FILIAL = %xFilial:CN9%
				   AND CN9.%notDel%
				   AND CN9.CN9_NUMERO = %Exp:cNumContr%
				   AND CN9.CN9_SITUAC = '05'

			EndSql

			DbSelectArea(cAliasCN9)
			While (cAliasCN9)->( !Eof() )
				cMaxRev := (cAliasCN9)-> CN9_REVISA
				(cAliasCN9)->(DbSkip())
			EndDo
			(cAliasCN9)->( DbCloseArea() )

			If cMaxRev <> cRevContr
				Help( ' ', 1, 'TECA580B', , STR0014, 1, 0 )	//"Não é possível gerar o memorando para revisões anteriores"
			Else
				If !(isBlind()) .AND. ( PerguntMemo() .AND. MSGYESNO( STR0015, STR0013 )) //"Deseja realmente gerar os memorandos?" # "Memorando"
				// Chama rotina de geracao do memorando
					lRet := At330GerMem(cNumContr, cRevContr, '')
				Else
					lRet := .F.
				EndIf
			EndIf
		Else
			Help( ' ', 1, 'TECA580B', , STR0016, 1, 0 )	//"Permitido somente para contratos vigentes"
		EndIf
	Else
		Help( ' ', 1, 'TECA580B', , STR0017, 1, 0 )	//"Contrato não localizado"
	EndIf
Else
	Help( ' ', 1, 'TECA580B', , STR0018, 1, 0 )	//"Não existe contrato gerado"
EndIf

RestArea(aAreaMe)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580BLeg
@description Adiciona as legendas na grid
@author       Mateus Boiani
@since        12/08/2018
@param        oBrwAcessos, objeto, objeto do browse
@return       nRet, numérico, 1 = Posto Encerrado ; 2 = Nenhum atendente relacionado; 3 = Possui atendente relacionado; 4 = Escala não configurada; 5 = Contrato em Revisão
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At580BLeg(oBrwAcessos)
Local nRet := 0
Local aArea := GetArea()
Local cAliasLEG	:= GetNextAlias()
Local cSit	:= '1'
Local lTFFEnc	:= .F.
Default oBrwAcessos := Nil

lTFFEnc := (oBrwAcessos:cAlias)->TFF_ENCE == '1'
cSit := At580BSit((oBrwAcessos:cAlias)->TFF_CONTRT)

If !lTFFEnc
	If cSit == '2'
		nRet := 5 // Contrato em Revisão
	Else	
		If !EMPTY( (oBrwAcessos:cAlias)->TFF_ESCALA )
			BeginSql Alias cAliasLEG
			SELECT	1
			FROM %table:TGY% TGY
				WHERE
				TGY.TGY_FILIAL = %xFilial:TGY% AND
				TGY.TGY_ESCALA = %Exp:(oBrwAcessos:cAlias)->TFF_ESCALA% AND
				TGY.TGY_CODTFF = %Exp:(oBrwAcessos:cAlias)->TFF_COD% AND
				TGY.%NotDel%
			EndSql

			If (cAliasLEG)->(EOF())
				nRet := 2 // Nenhum atendente relacionado
			Else
				nRet := 3 // Possui atendente relacionado
			EndIf	
			(cAliasLEG)->(DbCloseArea())	
		Else	
			nRet := 4 // Escala não configurada
		EndIf		
	EndIf
Else
	nRet := 1 // Posto Encerrado
EndIf

RestArea(aArea)
Return nRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580Legen
@description Botão "Legendas" no menu
@author       Mateus Boiani
@since        12/08/2018
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At580Legen()
Local aLegenda	:= {}
Local aSvKeys	:= GetKeys()

aLegenda := {;
				{ "BR_LARANJA", OemToAnsi(STR0068)},; //Contrato em revisão
				{ "BR_VERMELHO",OemToAnsi(STR0026)},; //Escala não configurada
				{ "BR_AMARELO",OemToAnsi(STR0027)},; //Nenhum atendente relacionado
				{ "BR_VERDE",OemToAnsi(STR0028)},; 	//Possui atendentes relacionados
				{ "BR_AZUL",OemToAnsi(STR0074)}; // Posto encerrado
			}

BrwLegenda( STR0029,"", aLegenda ) //Legendas Gestão de Escalas

RestKeys( aSvKeys )

Return( NIL )
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580BAten
@description Grid de busca de agendas
@author       Mateus Boiani
@since        12/08/2018
@param        cCodTFF, string, Código da TFF - para a busca tipo 1 (TFF posicionada)
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580BAten(cCodTFF, lAutomato)
Local oDlgSelect
Local oDataDe
Local oDataAte
Local oNameLike
Local dGetDtDe := Date()
Local dGetDtAte := Date()
Local cFuncName := SPACE(TamSX3("AA1_NOMTEC")[1])
Local oRefresh
Local oExit
Local oListBox
Local aCombo
Local cCombo
Local oCombo
Local nTipoBusca
Local aDados
Local cPerg := "TEC580B"
Local aSorting   := {0, .F.}
Local oOk
Local oNOK

Default lAutomato := .F.
If EMPTY(cCodTFF)
	aCombo := {STR0030} //Todos da filial
Else
	aCombo := {STR0031, STR0032, STR0030} //Item de RH posicionado ; Itens de RH filtrados
EndIf

nTipoBusca := 3

cCombo:= aCombo[LEN(aCombo)]
If !lAutomato
	aDados := AtGetABB(nTipoBusca,cCodTFF,Date(),Date(),"",cPerg)
Else
	aDados := AtGetABB(1,cCodTFF,Date(),Date(),"",cPerg)
	aDados := AtGetABB(2,cCodTFF,Date(),Date(),"",cPerg)
	aDados := AtGetABB(3,cCodTFF,Date(),Date(),"",cPerg)
EndIf

If !lAutomato

	oOK	:= LoadBitmap(GetResources(),"BR_VERDE")
	oNOK:= LoadBitmap(GetResources(),"BR_VERMELHO")

	DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 440,900 PIXEL TITLE STR0033 //Atendentes relacionados
	@ 5, 9 SAY STR0034 SIZE 50, 19 PIXEL //Data de Início
	@ 5, 80 SAY STR0035 SIZE 50, 19 PIXEL //Data de Término
	@ 5, 151 SAY STR0036 SIZE 50, 19 PIXEL //Nome do Atendente
	@ 5, 262 SAY STR0037 SIZE 50, 19 PIXEL //Local de Busca

	@ 204,5 BITMAP oRed RESNAME "BR_VERMELHO"	OF oDlgSelect SIZE 20,10 PIXEL NOBORDER
	@ 204,15 SAY STR0066 SIZE 75, 19 PIXEL //"Chegada não confirmada"

	@ 204,95 BITMAP oGreen RESNAME "BR_VERDE"	OF oDlgSelect SIZE 20,10 PIXEL NOBORDER
	@ 204,105 SAY STR0067 SIZE 50, 19 PIXEL //"Chegada confirmada"

	oDataDe := TGet():New( 015, 009, { | u | If( PCount() == 0, dGetDtDe, dGetDtDe := u ) },oDlgSelect, ;
						060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGetDtDe",,,,.T.)

	oDataAte := TGet():New( 015, 80, { | u | If( PCount() == 0, dGetDtAte, dGetDtAte := u ) },oDlgSelect, ;
						060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGetDtAte",,,,.T.)

	oNameLike := TGet():New( 015, 151, { | u | If( PCount() == 0, cFuncName, cFuncName := u ) },oDlgSelect, ;
	    				 100, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cFuncName",,,,.T.  )

	oCombo := TComboBox():New(012,262,{|u|if(PCount()>0,cCombo:=u,cCombo)},aCombo,100,20,oDlgSelect,,,,,,.T.,,,,,,,,,'cCombo')

	oExit := TButton():New( 204, 414, STR0038,oDlgSelect,{|| oListBox:aARRAY := {}, oDlgSelect:End() }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //Sair

	oListBox := TWBrowse():New(030, 007, 445, 170,,{},,oDlgSelect,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox:addColumn(TCColumn():New(	"", &("{|| IIF(oListBox:aARRAY[oListBox:nAt,12] == 'S', oOK , oNOK) }"),,,,,10,.T.))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABB_CODTEC", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,2] }"),,,,,80))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "AA1_NOMTEC", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,3] }"),,,,,100))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABB_DTINI", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,4] }"),,,,,30))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "PJ_DIA", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,5] }"),,,,,40))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABB_DTFIM", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,6] }"),,,,,30))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "PJ_DIA", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,7] }"),,,,,40))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABB_HRINI", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,8] }"),,,,,30))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABB_HRFIM", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,9] }"),,,,,30))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABQ_CONTRT", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,10] }"),,,,,30))
	oListBox:addColumn(TCColumn():New(	GetSX3Cache( "ABQ_CODTFF", "X3_TITULO" ), &("{|| oListBox:aARRAY[oListBox:nAt,11] }"),,,,,30))
	oListBox:SetArray(aDados)
	oListBox:lAutoEdit    := .T.
	oListBox:bHeaderClick := { |a, b| { T580bClick(oListBox:aARRAY, oListBox, a, b, aSorting, oDlgSelect) }}
	oListBox:Refresh()

	oRefresh := TButton():New( 014, 390, STR0039,oDlgSelect,{|| At580bRfr(@oListBox,cCombo,cCodTFF,aCombo,dGetDtDe,dGetDtAte,cFuncName,cPerg)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //Buscar

	ACTIVATE MSDIALOG oDlgSelect CENTER
EndIf
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T580bClick
@description Faz o sort dos dados ao clicar no cabeçalho da coluna
@author       Mateus Boiani
@since        12/08/2018
@param        aRegs, array, registros presentes no grid
@param        oListBox, obj, objeto TWBrowse
@param        b, int, coluna selecionada
@param        aSorting, array, utilizado para definir se a busca sera a > b ou a < b
@param        oDlgSelect, obj, tela em que o TWBrowse é filho
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function T580bClick(aRegs, oListBox, a, b, aSorting, oDlgSelect)

If aSorting[1] == b .and. aSorting[2]
	aSorting[2] := .F.
	aRegs := aSort(aRegs, 1, Len(aRegs), {|l1, l2| TecNumDow(l1[b]) > TecNumDow(l2[b])})
Else
	If aSorting[1] != b
		aSorting[1] := b
	EndIf
	aSorting[2] := .T.
	aRegs := aSort(aRegs, 1, Len(aRegs), {|l1, l2| TecNumDow(l1[b]) < TecNumDow(l2[b])})
EndIf
oListBox:SetArray(aRegs)
oListBox:Refresh()

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580bRfr

@description Carrega os dados no objeto TWBrowse
@author       Mateus Boiani
@since        12/08/2018

@param        oListBox, obj, objeto TWBrowse
@param        cCombo, string, opção selecionada no oCombo
@param        cCodTFF, string, código da TFF para busca do tipo 1
@param        aCombo, array, opções disponíveis no objeto oCombo
@param        dGetDtDe, date, data de início
@param        dGetDtAte, date, data de término
@param        cFuncName, string, nome do funcionário (busca do tipo LIKE)
@param        cPerg, string, PERGUNTE utilizado na busca do tipo 2 (Itens selecionados)
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580bRfr(oListBox,cCombo,cCodTFF,aCombo,dGetDtDe,dGetDtAte,cFuncName,cPerg)
Local nTipoBusca
Local aDados

If VAlTYPE(oListBox) == 'O' .AND. VALTYPE(oListBox:aARRAY) == 'A'
	oListBox:aARRAY := {}
EndIf

If EMPTY(cCodTFF) .OR. EMPTY(aCombo)
	nTipoBusca := 3
Else
	nTipoBusca := ASCAN(aCombo, cCombo)
EndIf

FwMsgRun(Nil,{|| aDados := AtGetABB(nTipoBusca,cCodTFF,dGetDtDe,dGetDtAte,cFuncName,cPerg)}, Nil, STR0040) //"Aguarde, carregando os dados..."

oListBox:aARRAY := aDados
oListBox:Refresh()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtGetABB

@description Busca no banco de dados as agendas e adiciona no array aRet
@author       Mateus Boiani
@since        12/08/2018

@param        nTipoBusca, int, tipo da busca. 1 = TFF posicionada ; 2 = Perguntes do TECA580B ; 3 = Filial inteira
@param        cCodTFF, string, código da TFF para busca do tipo 1
@param        dGetDtDe, date, data de início
@param        dGetDtAte, date, data de término
@param        cFuncName, string, nome do funcionário (busca do tipo LIKE)
@param        cPerg, string, PERGUNTE utilizado na busca do tipo 2 (Itens selecionados)

@return       aRet, array, dados utilizados para preencher o TWBrowse, seguindo a estrutura:
								[ 1] - Código do atendente (AA3)
								[ 2] - Nome do atendente (AA3)
								[ 3] - Data inicial convertida em string (ABB_DTINI)
								[ 4] - Nome do dia da semana da data inicial
								[ 5] - Data final convertida em string (ABB_DTFIM)
								[ 6] - Nome do dia da semana da data final
								[ 7] - Hora inicial (ABB_HRINI)
								[ 8] - Hora final (ABB_HRFIM)
								[ 9] - Número do contrato relacionado (ABQ_CONTRT)
								[10] - Código da TFF relacionado (ABQ_CODTFF)
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtGetABB(nTipoBusca,cCodTFF,dGetDtDe,dGetDtAte,cFuncName,cPerg)
Local cAliasABB := GetNextAlias()
Local aRet := {}
Local cSql := ""
Local cDtIniAux := ""
Local cDtFimAux := ""
If EMPTY(cCodTFF)
	nTipoBusca := 3
EndIf

If nTipoBusca == 1 //TFF posicionada
	cSql += "SELECT ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABB.ABB_DTINI, ABB.ABB_DTFIM, "
	cSql += " ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_CHEGOU ,ABQ.ABQ_CONTRT, ABQ.ABQ_CODTFF "
	cSql += " FROM " + RetSqlName('ABB') + " ABB "
	cSql += " JOIN " + RetSqlName('AA1') + " AA1 ON "
	cSql += " AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	cSql += " JOIN " + RetSqlName('ABQ') + " ABQ ON  "
	cSql += " ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM "
	cSql += " WHERE ABQ.ABQ_CODTFF = '" + cCodTFF + "' AND "
	cSql += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND "
	cSql += " ABB.ABB_ATIVO <> '2' AND "
	cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND "
	cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "'  AND "
	cSql += " ABB.ABB_DTINI >= '" + DTOS(dGetDtDe) + "' AND "
	cSql += " ABB.ABB_DTINI <= '" + DTOS(dGetDtAte) + "' AND "
	If !EMPTY(cFuncName)
		cSql += " AA1.AA1_NOMTEC LIKE '%" + UPPER(ALLTRIM(cFuncName)) + "%' AND "
	EndIf
	cSql += " ABB.D_E_L_E_T_ = ' ' AND "
	cSql += " ABQ.D_E_L_E_T_ = ' ' AND "
	cSql += " AA1.D_E_L_E_T_ = ' ' "
ElseIf nTipoBusca == 2 //Perguntes do TECA580B

	Pergunte(cPerg,.F.)

	cSql += "SELECT ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABB.ABB_DTINI, ABB.ABB_DTFIM, "
	cSql += " ABB.ABB_HRINI, ABB.ABB_HRFIM, ABQ.ABQ_CONTRT, ABQ.ABQ_CODTFF, ABB.ABB_CHEGOU "
	cSql += " FROM " + RetSqlName('ABB') + " ABB "
	cSql += " JOIN " + RetSqlName('AA1') + " AA1 ON "
	cSql += " AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	cSql += " JOIN " + RetSqlName('ABQ') + " ABQ ON  "
	cSql += " ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM "
	cSql += " JOIN " + RetSqlName('TFF') + " TFF ON  "
	cSql += " TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
	cSql += " TFF.TFF_COD = ABQ.ABQ_CODTFF "
	cSql += " JOIN " + RetSqlName('ABS') + " ABS ON  "
	cSql += " ABB.ABB_LOCAL = ABS.ABS_LOCAL "
	cSql += " WHERE "
	cSql += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND "
	cSql += " ABB.ABB_ATIVO <> '2' AND "
	cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND "
	cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "'  AND "
	cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "'  AND "
	cSql += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND "
	cSql += " ABB.ABB_DTINI >= '" + DTOS(dGetDtDe) + "' AND "
	cSql += " ABB.ABB_DTINI <= '" + DTOS(dGetDtAte) + "' AND "
	cSql += " TFF.TFF_CONTRT BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
	cSql += " TFF.TFF_CODSUB = '      ' AND "
	cSql += " ABS.ABS_CODIGO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR03+"' AND "
	cSql += " ABS.ABS_LOJA BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR04+"' AND "
	If !EMPTY(cFuncName)
		cSql += " AA1.AA1_NOMTEC LIKE '%" + UPPER(ALLTRIM(cFuncName)) + "%' AND "
	EndIf
	cSql += " ABB.D_E_L_E_T_ = ' ' AND "
	cSql += " ABS.D_E_L_E_T_ = ' ' AND "
	cSql += " ABQ.D_E_L_E_T_ = ' ' AND "
	cSql += " TFF.D_E_L_E_T_ = ' ' AND "
	cSql += " AA1.D_E_L_E_T_ = ' ' "
ElseIf nTipoBusca == 3 //Filial inteira
	cSql += "SELECT ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABB.ABB_DTINI, ABB.ABB_DTFIM, "
	cSql += " ABB.ABB_HRINI, ABB.ABB_HRFIM, ABQ.ABQ_CONTRT, ABQ.ABQ_CODTFF, ABB.ABB_CHEGOU "
	cSql += " FROM " + RetSqlName('ABB') + " ABB "
	cSql += " JOIN " + RetSqlName('AA1') + " AA1 ON "
	cSql += " AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	cSql += " JOIN " + RetSqlName('ABQ') + " ABQ ON  "
	cSql += " ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM "
	cSql += " WHERE "
	cSql += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND "
	cSql += " ABB.ABB_ATIVO <> '2' AND "
	cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND "
	cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "'  AND "
	cSql += " ABB.ABB_DTINI >= '" + DTOS(dGetDtDe) + "' AND "
	cSql += " ABB.ABB_DTINI <= '" + DTOS(dGetDtAte) + "' AND "
	If !EMPTY(cFuncName)
		cSql += " AA1.AA1_NOMTEC LIKE '%" + UPPER(ALLTRIM(cFuncName)) + "%' AND "
	EndIf
	cSql += " ABB.D_E_L_E_T_ = ' ' AND "
	cSql += " ABQ.D_E_L_E_T_ = ' ' AND "
	cSql += " AA1.D_E_L_E_T_ = ' ' "
EndIf
cSql += " ORDER BY ABB.ABB_DTINI "

cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasABB, .F., .T.)

While (cAliasABB)->(!Eof())
	cDtIniAux := (cAliasABB)->(ABB_DTINI)
	cDtFimAux := (cAliasABB)->(ABB_DTFIM)

	cDtIniAux := RIGHT(cDtIniAux,2) + "/" + SUBSTR(cDtIniAux,5,2) + "/" + LEFT(cDtIniAux,4)
	cDtFimAux := RIGHT(cDtFimAux,2) + "/" + SUBSTR(cDtFimAux,5,2) + "/" + LEFT(cDtFimAux,4)

	AADD(aRet, { 	(cAliasABB)->(ABB_CHEGOU),;
					(cAliasABB)->(ABB_CODTEC),;
					ALLTRIM((cAliasABB)->(AA1_NOMTEC)),;
					cDtIniAux,;
					TECCdow(Dow(sTOd((cAliasABB)->(ABB_DTINI)))),;
					cDtFimAux,;
					TECCdow(Dow(sTOd((cAliasABB)->(ABB_DTFIM)))),;
					(cAliasABB)->(ABB_HRINI),;
					(cAliasABB)->(ABB_HRFIM),;
					(cAliasABB)->(ABQ_CONTRT),;
					(cAliasABB)->(ABQ_CODTFF),;
					(cAliasABB)->(ABB_CHEGOU)})
	(cAliasABB)->(DbSkip())
End
(cAliasABB)->( DbCloseArea() )

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldEscala
@description Valida integridade da Escala, verificando os dados do turno. Também preenche a variavel
               static de HashMap, utilizada no TECA580E
@author       Mateus Boiani
@since        27/08/2018
@param        nRecTFF, int, RECNO da TFF
@return       lRet, bool, .T. se a escala estiver OK
/*/
//--------------------------------------------------------------------------------------------------------------------
Function VldEscala(nRecTFF, cEscala, cItemRH, lShowMsg, cFilBusca)
Local lRet := .T.
Local cAliasAux := GetNextAlias()
Local cSQl := ""
Local cErrorMsg := ""
Local cTurno := ""
Local aDias := {}
Local nDiaModelo := 0
Local nX := 0
Local nY := 0
Local nAux := 0
Local cCampo := ""
Local cSeq := ""
Local cDia := ""
Local cValEsp := ""
Local cValEnc := ""
Local aAux := {}
Local lNovaMesa := Empty(nRecTFF)
Local cFilBkp := cFilAnt

Default cItemRH := ""
Default lShowMsg := .T.
Default cFilBusca := cFilAnt

cFilAnt := cFilBusca

If cEscala = NIL
	DbSelectArea("TFF")
	DbGoTo(nRecTFF)
	cEscala := TFF->TFF_ESCALA
	cItemRH := TFF->TFF_COD
EndIf

If ( lRet := !EMPTY(cEscala) )
	cSQl += " SELECT TDX.TDX_TURNO FROM "
	cSQl += RetSqlName('TDX') + " TDX "
	cSQl += " WHERE TDX.TDX_CODTDW = '" + cEscala + "' AND "
	cSQl += " TDX.D_E_L_E_T_ = ' ' AND TDX.TDX_FILIAL = '" + xFilial("TDX") + "'"
	cSQl := ChangeQuery(cSQl)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSQl),cAliasAux, .F., .T.)

	While (cAliasAux)->(!Eof())
		If EMPTY(cTurno)
			cTurno := (cAliasAux)->(TDX_TURNO)
		EndIf
		If cTurno == (cAliasAux)->(TDX_TURNO)
			(cAliasAux)->(DbSkip())
		Else
			lRet := .F.
			cErrorMsg := STR0043 //"O parâmetro MV_GSGEHOR está ativo, porém, para que a flexibilidade de horários seja utilizada, é necessário que todos os turnos de trabalho da escala possuam a mesma estrutura."
			cErrorMsg += CRLF
			cErrorMsg += STR0044 //"O sistema localizou a seguinte incompatibilidade:"
			cErrorMsg += CRLF + CRLF
			cErrorMsg += STR0045 //"Turnos de trabalho diferentes (TDX_TURNO) em uma mesma escala (TDX_CODTDW)"
			If !lNovaMesa
				cErrorMsg += CRLF + CRLF
				cErrorMsg += STR0046 //"A rotina de Posto x Funcionário será executada normalmente, porém, sem a adição dos campos de customização de hora de entrada e hora de saída."
			EndIf
			Exit
		EndIf
	End
	(cAliasAux)->(DbCloseArea())

	If lRet
		cAliasAux := GetNextAlias()
		cSQl := " SELECT "
		For nX := 1 To LEN(GetCpoArr())
			cSQl += " PJ." + GetCpoData(nX) + IIF(nX == LEN(GetCpoArr()), SPACE(2) , ", " )
		Next
		cSQl += " FROM "
		cSQl += RetSqlName('SPJ') + " PJ "
		cSQl += " WHERE PJ.D_E_L_E_T_ = ' ' AND PJ.PJ_FILIAL = '" + xFilial("SPJ") + "' AND "
		cSQl += " PJ.PJ_TURNO = '" + cTurno + "' AND PJ.PJ_TPDIA = 'S' "
		cSQl := ChangeQuery(cSQl)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSQl),cAliasAux, .F., .T.)

		While (cAliasAux)->(!Eof())
			For nX := 1 To LEN(GetCpoArr())
				AADD(aAux, (&("('" + cAliasAux + "')->(" + GetCpoData(nX) + ")")) )
			Next
			AADD(aDias, aAux)
			aAux := {}
			(cAliasAux)->(DbSkip())
		End
		(cAliasAux)->(DbCloseArea())

		nDiaModelo := ASCAN(aDias, {|f| f[1] == 'S' .AND. f[16] > 0})
		If nDiaModelo != 0
			For nX := 1 To LEN(aDias)
				If lRet
					For nY := 4 to 16
						If ( nAux :=  ASCAN(aDias, {|f| f[nY] > 0 .AND. f[nY] != aDias[nDiaModelo][nY] }) ) > 0
							lRet := .F.
							cCampo := Alltrim(GetSX3Cache( GetCpoData(nY), "X3_CAMPO" ))
							cSeq := aDias[nAux][2]
							cDia := TECCdow( VAL(aDias[nAux][3]) )
							cValEsp := Alltrim(cValToChar( aDias[nDiaModelo][nY]  ))
							cValEnc := Alltrim(cValToChar( aDias[nAux][nY]  ))

							cErrorMsg := STR0043 //"O parâmetro MV_GSGEHOR está ativo, porém, para que a flexibilidade de horários seja utilizada, é necessário que todos os turnos de trabalho da escala possuam a mesma estrutura."
							cErrorMsg += CRLF
							cErrorMsg += STR0044 //"O sistema localizou a seguinte incompatibilidade:"
							cErrorMsg += CRLF + CRLF
							cErrorMsg += STR0047 //"Horário de entrada ou saída diverge em um ou mais dias da escala."
							If !lNovaMesa
								cErrorMsg += CRLF + CRLF
								cErrorMsg += STR0046 //"A rotina de Posto x Funcionário será executada normalmente, porém, sem a adição dos campos de customização de hora de entrada e hora de saída."
							EndIf
							Exit
						EndIf
					Next

					For nY := 17 to 23
						If ( nAux :=  ASCAN(aDias, {|f| f[nY] != aDias[nDiaModelo][nY] }) ) > 0
							lRet := .F.
							cCampo := Alltrim(GetSX3Cache( GetCpoData(nY), "X3_CAMPO" ))
							cSeq := aDias[nAux][2]
							cDia := TECCdow( VAL(aDias[nAux][3]) )
							cValEsp := Alltrim( aDias[nDiaModelo][nY]  )
							cValEnc := Alltrim( aDias[nAux][nY]  )

							cErrorMsg := STR0043 //"O parâmetro MV_GSGEHOR está ativo, porém, para que a flexibilidade de horários seja utilizada, é necessário que todos os turnos de trabalho da escala possuam a mesma estrutura."
							cErrorMsg += CRLF
							cErrorMsg += STR0044 //"O sistema localizou a seguinte incompatibilidade:"
							cErrorMsg += CRLF + CRLF
							cErrorMsg += STR0048 //"Configuração de jornada contínua ou de intervalo diverge na configuração da escala."
							If !lNovaMesa
								cErrorMsg += CRLF + CRLF
								cErrorMsg += STR0046 //"A rotina de Posto x Funcionário será executada normalmente, porém, sem a adição dos campos de customização de hora de entrada e hora de saída."
							EndIf
							Exit
						EndIf
					Next
				Else
					Exit
				EndIf
			Next
		Else
			lRet := .F.
			cErrorMsg := STR0043 //"O parâmetro MV_GSGEHOR está ativo, porém, para que a flexibilidade de horários seja utilizada, é necessário que todos os turnos de trabalho da escala possuam a mesma estrutura."
			cErrorMsg += CRLF
			cErrorMsg += STR0044 //"O sistema localizou a seguinte incompatibilidade:"
			cErrorMsg += CRLF + CRLF
			cErrorMsg += STR0077 //"Tabela de horário sem nenhum dia Trabalhado"
		EndIf
	EndIf
Else
	cErrorMsg := STR0043 //"O parâmetro MV_GSGEHOR está ativo, porém, para que a flexibilidade de horários seja utilizada, é necessário que todos os turnos de trabalho da escala possuam a mesma estrutura."
	cErrorMsg += CRLF
	cErrorMsg += STR0044 //"O sistema localizou a seguinte incompatibilidade:"
	cErrorMsg += CRLF + CRLF
	If !lNovaMesa
		cErrorMsg += STR0049 //"Escala não configurada. Utilize a rotina 'Posto x Escala' para selecionar a escala deste item de RH"

		cErrorMsg += CRLF + CRLF
		cErrorMsg += STR0046 //"A rotina de Posto x Funcionário será executada normalmente, porém, sem a adição dos campos de customização de hora de entrada e hora de saída."
	Else
		cErrorMsg += STR0075 //"Escala não configurada. Informe uma escala válida"
	EndIf
EndIf
If !Empty(cErrorMsg) .AND. !ISBlind() .And. !lRet
	If lShowMsg
		AtShowLog(cErrorMsg + CRLF + CRLF +;
				REPLICATE("-",35) + CRLF +;
				IIF(EMPTY(cItemRH),"",STR0050 + " " + cItemRH + CRLF )+; //"Item de RH:"
				IIF(EMPTY(cEscala),"",STR0051 + " " + cEscala + CRLF )+; //"Escala:"
				IIF(EMPTY(cTurno),"",STR0052 + " " + cTurno + CRLF )+; //"Turno:"
				IIF(EMPTY(cSeq),"",STR0053 + " " + cSeq + CRLF)+; //"Sequência:"
				IIF(EMPTY(cDia),"",STR0054 + " " + cDia + CRLF )+; //"Dia:"
				IIF(EMPTY(cCampo),"",STR0055 + " " + cCampo + CRLF )+; //"Campo:"
				IIF(EMPTY(cValEsp),"",STR0056 + " " + cValEsp + CRLF )+; //"Valor Esperado:"
				IIF(EMPTY(cValEnc),"",STR0057 + " " + cValEnc + CRLF); //"Valor Encontrado:"
				,IIF(!lNovaMesa, STR0058,STR0076),/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) //"Gestão de Escalas"##"Editor de Horários"
	EndIf
ElseIf lRet
	oHashDia := FwHashMap():New()
	For nX := 1 to LEN(GetCpoArr())
		oHashDia:Put(GetCpoData(nX),aDias[nDiaModelo][nX])
	Next
EndIf

cFilAnt := cFilBkp

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECCdow
@description Retorna a descrição de um dia da semana, baseando-se no número do dia.
				Função similar a cDow(), porém recebe int ao invés de date
@author       Mateus Boiani
@since        27/08/2018
@param        nDia, int, dia da semana. (exemplo: 1 = Domingo , 2 = Segunda , etc..)
@return       cRet, string, descrição do dia da semana
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECCdow(nDia)
Local cRet := ""
Default nDia := 0
If nDia == 1
	cRet := STR0059 //"Domingo"
ElseIf nDia == 2
	cRet := STR0060 //"Segunda-feira"
ElseIf nDia == 3
	cRet := STR0061 //"Terça-feira"
ElseIf nDia == 4
	cRet := STR0062 //"Quarta-feira"
ElseIf nDia == 5
	cRet := STR0063 //"Quinta-feira"
ElseIf nDia == 6
	cRet := STR0064 //"Sexta-feira"
ElseIf nDia == 7
	cRet := STR0065 //"Sábado"
EndIf

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecNumDow
@description Retorna o número do dia da semana a partir do seu nome.
@author       Mateus Boiani
@since        27/08/2018
@param        xVal, unknown, Nome do dia da semana. Pode ser qualquer valor.
@return       xVal, unknown, retorna o número caso o Param1 seja válido ou o próprio param1 caso contrário
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecNumDow(xVal)
If VALTYPE(xVal) == "C"
	If xVal == STR0059 //"Domingo"
		xVal := 1
	ElseIf xVal == STR0060 //"Segunda-feira"
		xVal := 2
	ElseIf xVal == STR0061 //"Terça-feira"
		xVal := 3
	ElseIf xVal == STR0062 //"Quarta-feira"
		xVal := 4
	ElseIf xVal == STR0063 //"Quinta-feira"
		xVal := 5
	ElseIf xVal == STR0064 //"Sexta-feira"
		xVal := 6
	ElseIf xVal == STR0065 //"Sábado"
		xVal := 7
	Endif
EndIf
Return xVal
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCpoData
@description Retorna o nome do campo na posição N do array de campos pesquisados na SPJ
@author       Mateus Boiani
@since        27/08/2018
@param        nCpo, int, posição do campo
@return       cRet, string, nome do campo
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetCpoData(nCpo)

Return ( GetCpoArr()[nCpo] )
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCpoArr
@description Retorna o array dos campos pesquisados na SPJ
@author       Mateus Boiani
@since        27/08/2018
@return       aRet, array, array dos campos utilizados
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetCpoArr()

Local aRet := {;
				"PJ_TPDIA",;   //[ 1]
				"PJ_SEMANA",;  //[ 2]
				"PJ_DIA",;     //[ 3]
				"PJ_ENTRA1",;  //[ 4]
				"PJ_ENTRA2",;  //[ 5]
				"PJ_ENTRA3",;  //[ 6]
				"PJ_ENTRA4",;  //[ 7]
				"PJ_SAIDA1",;  //[ 8]
				"PJ_SAIDA2",;  //[ 9]
				"PJ_SAIDA3",;  //[10]
				"PJ_SAIDA4",;  //[11]
				"PJ_HRSTRAB",; //[12]
				"PJ_HRSTRA2",; //[13]
				"PJ_HRSTRA3",; //[14]
				"PJ_HRSTRA4",; //[15]
				"PJ_HRTOTAL",; //[16]
				"PJ_JND1CON",; //[17]
				"PJ_JND2CON",; //[18]
				"PJ_JND3CON",; //[19]
				"PJ_JND4CON",; //[20]
				"PJ_INTERV1",; //[21]
				"PJ_INTERV2",; //[22]
				"PJ_INTERV3",; //[23]
				"PJ_TURNO";    //[24]
				}
Return aRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580bHash
@description Retorna o HashMap que será utilizado pra montar o "Dia Modelo"
@author       Mateus Boiani
@since        27/08/2018
@return       oHashDia, obj, hashmap static utilizado no "Dia Modelo"
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580bHash()

Return oHashDia
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580bHGet
@description Executa o método Get no hashMap Static do dia modelo. Função utilizada no TECA580E
@author       Mateus Boiani
@since        27/08/2018
@param        cKey, string, chave do hashmap
@return       xValue, unknown, Valor da chave cKey do hashmap oHashDia
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580bHGet(cKey)

Return ( oHashDia:Get(cKey) )


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580BSit
@description  Verifica se um determinado contrato possui revisão em andamento
@author       Diego Bezerra
@since        20/03/2019
@param        cContrt, string, código do contrato
@return       cRet, string, 2 = Contrato com processo de Revisão não concluído 1 = Contrato sem Revisão pendente
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580BSit(cContrt)
Local cRet := ""
Local aArea := GetArea()
Local cAliasSituac	:= GetNextAlias()

BeginSql Alias cAliasSituac

	SELECT 1
		FROM %table:TFJ% TFJ
	WHERE
		TFJ.TFJ_FILIAL = %xFilial:TFJ%
		AND	TFJ_CONTRT =  %Exp:cContrt%
		AND (TFJ_STATUS = '2' OR TFJ_STATUS = '4')
		AND TFJ.%NotDel%
EndSql

If (cAliasSituac)->(EOF())
	cRet := '1'
Else
	cRet := '2'
EndIf

(cAliasSituac)->(DbCloseArea())
RestArea(aArea)
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580bAt
@description  Função para validar o codigo do atendente informado no pergunte TEC580BE(MV_PAR05)
@author       Luiz Gabriel
@since        28/05/2019
@param        cCodTec, string, código do Atendente
@return       lRet, Logico, Caso retorne .T. o atendente pode ser selecionado
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580bAt(cCodTec)
Local lRet 		:= .T.
Local aEscala	:= {}
Local nY		:= 0
Local aArea 	:= GetArea()

If Select("AA1") == 0
	DbSelectArea("AA1")
EndIf

lRet := Vazio() .Or. ExistCpo("AA1",cCodTec)

/*			
aEscala[1][1] - Codigo da Escala
aEscala[1][2] - turno da escala
aEscala1[1][3] - Sequencia do Turno da escala
aEscala[1][4] - Calendario da Escala(TFF)
aEscala[1][5] - Data inicial da escala
aEscala[1][6] - Data Final da escala
aEscala[1][7] - Local de Atendimento
aEscala[1][8] - Codigo do cliente 
aEscala[1][9] - Loja do Clientte
aEscala[1][10] - Numero do Contrato
aEscala[1][11] - Codigo da TFF
*/

If lRet .And. !Vazio()
	//Verifico em qual escala o atendente está alocado no periodo informado
	aEscala := TxEscCalen( cCodTec, MV_PAR01, MV_PAR02)			
	
	If Len(aEscala) > 0
	
		//Verificar quais os turnos estão configurados na escala
		DbSelectArea("TDW")
		TDW->(DbSetOrder(1))
		
		DbSelectArea("TDX")
		TDX->(DbSetOrder(2))
		
		For nY := 1 To Len(aEscala)
			If aEscala[nY][11] == TFF->TFF_COD .And. TDW->(DbSeek(xFilial("TDW") + aEscala[nY][1] ))
				If TDX->(DbSeek(xFilial("TDX") + TDW->TDW_COD))
					If !TGY->(DbSeek(xFilial("TGY") + aEscala[nY][1] + TDX->TDX_COD + aEscala[nY][11]))
						lRet := .F.		
						Help( , , STR0071, , STR0072, 1, 0,,,,,,{STR0073})//"Atendente não está configurado na escala do contrado selecionado"##"Informe outro atendente"
					EndIf
				EndIf
				
			Else
				lRet := .F.
				Help( , , STR0071, , STR0072, 1, 0,,,,,,{STR0073})//"Atendente não está configurado na escala do contrado selecionado"##"Informe outro atendente"
			EndIf
		Next nY
	Else
		lRet := .F.
		Help( , , STR0071, , STR0072, 1, 0,,,,,,{STR0073})//"Atendente não está configurado na escala do contrado selecionado"##"Informe outro atendente"
	EndIf	
EndIf

RestArea(aArea)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580bEsc
@description  Realiza o filtro do atendente
@author       Luiz Gabriel
@since        28/05/2019
@param        aAtend, Array, Array com os atendentes selecionados para o posto
@param        cPesq, String, Codigo para verificar como a pesquisa será feita
@return       aRet, Array, Array com o atendente selecionado
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580bEsc(aAtend,cPesq,cCodTec)
Local aRet	:= {}
Local nPOs	:= 0

Default cPesq := "0"
Default cCodTec := MV_PAR05

If cPesq == "0"
	nPos := aScan(aAtend,{|x| x[6] == cCodTec})
	
	If nPos > 0
		aAdd(aRet,aAtend[nPos])
	EndIf
Else
	nPos := aScan(aAtend,{|x| LEFT(x,LEN(cCodTec)) == cCodTec})
	
	If nPos > 0
		aAdd(aRet,aAtend[1])
		aAdd(aRet,aAtend[nPos])
	EndIf

EndIf

Return aRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580BClHs
@description Limpa a variavel Static oHashDia

@author       Mateus Boiani
@since        17/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580BClHs()
If VALTYPE( At580bHash() ) == 'O'
	oHashDia:Destroy()
	oHashDia := nil
EndIf
Return
