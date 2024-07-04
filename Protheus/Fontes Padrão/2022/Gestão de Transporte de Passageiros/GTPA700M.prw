#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'totvs.ch'
#include 'GTPA700M.ch'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700M()

Rotina para geraçao dos titulos de despesas e receitas

@sample	GTPA700M()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		10/08/2020
@version	P12
/*/
Function GTPA700M(lJob, nOp, cCaixa, cMsgErro, cMsgTit)
local aDados      := {}
Local lRet        := .T.
Local cAliasQry   := GetNextAlias()
Local cAliasReD   := GetNextAlias()
Local aAreaG6T    := G6T->(GetArea())
Local cStatus     := ""
Default cMsgErro  := ""
Default cMsgTit   := ""
Default lJob      := .F.
Default nOp       := 1	// Operações(1=Gerar titulos no fechamento do caixa ; 2=Cancelar titulos na reabetura do caixa)
	
	G6T->(DbSetOrder(3))
	G6T->( DbSeek(xFilial("G6T") + cCaixa  ) )

	If nOp == 1
		If G6T->G6T_STATUS != '2' .AND. !lJob
		
			FwAlertWarning(STR0002, STR0001) //"Geração dos Títulos de Despesas e Receitas"
	
			Return .F.
				
		Endif
		
		BeginSQL Alias cAliasQry
			
			SELECT GI6.GI6_FILIAL,
			       GI6.GI6_FILRES,
			       GI6.GI6_CLIENT,
			       GI6.GI6_LJCLI,
			       GI6.GI6_FORNEC,
			       GI6.GI6_LOJA,
			       G6Y.G6Y_CODIGO,
			       G6Y.G6Y_VALOR,
			       G6Y.G6Y_TPLANC,
			       G6Y.G6Y_NUMFCH,
			       G6Y.G6Y_ITEM,
			       G6Y.G6Y_CODAGE,
			       G6Y.R_E_C_N_O_ RECG6Y,
			       GZC.GZC_PREFIX,
			       GZC.GZC_NATUR
			FROM %Table:G6Y% G6Y
			INNER JOIN %Table:GZC% GZC 
				ON GZC.GZC_FILIAL = %xFilial:GZC%
				AND GZC.GZC_CODIGO = G6Y.G6Y_CODGZC
				AND GZC.GZC_GERTIT = '1'
				AND GZC.%NotDel%
			INNER JOIN %Table:GI6% GI6 
				ON GI6.GI6_FILIAL = G6Y.G6Y_FILIAL
				AND GI6.GI6_CODIGO = G6Y.G6Y_CODAGE
				AND GI6.%NotDel%
			WHERE G6Y.G6Y_FILIAL = %xFilial:G6Y%
	    		AND G6Y.G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
				AND G6Y.G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
				AND G6Y.%NotDel%
				AND G6Y.G6Y_TPLANC IN ('8','9')
			  	
		EndSQL

		If !(cAliasQry)->(Eof())
		
			Begin Transaction
	
				While (cAliasQry)->(!Eof()) .And. lRet 
					
					Aadd(aDados,{	(cAliasQry)->G6Y_CODIGO,;
									(cAliasQry)->G6Y_CODAGE,;
									(cAliasQry)->G6Y_NUMFCH,;
									(cAliasQry)->G6Y_ITEM,;
									(cAliasQry)->GZC_PREFIX,;
									(cAliasQry)->GZC_NATUR,;
									(cAliasQry)->RECG6Y,;
									(cAliasQry)->G6Y_VALOR,;
									(cAliasQry)->GI6_CLIENT,;
									(cAliasQry)->GI6_LJCLI,;
									(cAliasQry)->GI6_FORNEC,;
									(cAliasQry)->GI6_LOJA,;
									(cAliasQry)->GI6_FILRES})
								
					If (cAliasQry)->G6Y_TPLANC == '8' // Receita
						
						lRet := GerTitRec(aDados,lJob,@cMsgErro,@cMsgTit)
						aDados			:= {}	
					
						if FwIsInCallStack('GTPA700M_1')
							lRet := .T.
						EndIf
					
					Else // Despesa
						
						lRet := GerTitDesp(aDados,lJob,@cMsgErro,@cMsgTit)
						aDados			:= {}

						if FwIsInCallStack('GTPA700M_1')
							lRet := .T.
						EndIf
					
					Endif
						
					If !lRet .AND. !FwIsInCallStack('GTPA700M_1')
						
						DisarmTransaction()
						Exit
	
					Endif
						
					(cAliasQry)->(dbSkip())
	
				EndDo
						
			End Transaction
				
			If lRet
				If !lJob
					FwAlertSuccess(STR0003, STR0004) //"Títulos gerados com sucesso"
				Endif	
			Endif
				
		Else
			
			cMsgErro	:= STR0005 //"Não foram encontradas despesas e/ou receitas para serem gerados"
			cMsgTit		:= STR0006 //"Geração dos Títulos de Despesas e Receitas"
			
			If !lJob
				FwAlertHelp(cMsgErro,, cMsgTit)
			Endif
			
		Endif
		
		cStatus := IIf(lRet,'2','3')
		
		RecLock('G6T', .F.)
		G6T->G6T_STSTIT := cStatus 
		G6T->(MsUnlock())		
		
		RestArea(aAreaG6T)		
		
		If Select(cAliasQry) > 0
			(cAliasQry)->(dbCloseArea())
		Endif	
	
	Else
		
		BeginSQL Alias cAliasReD
			
			SELECT GI6.GI6_FILIAL,
			       GI6.GI6_FILRES,
			       GI6.GI6_CLIENT,
			       GI6.GI6_LJCLI,
			       GI6.GI6_FORNEC,
			       GI6.GI6_LOJA,
			       G6Y.G6Y_CODIGO,
			       G6Y.G6Y_VALOR,
			       G6Y.G6Y_TPLANC,
			       G6Y.G6Y_NUMFCH,
			       G6Y.G6Y_ITEM,
			       G6Y.G6Y_CODAGE,
			       G6Y.R_E_C_N_O_ RECG6Y,
			       GZC.GZC_PREFIX,
			       GZC.GZC_NATUR
			FROM %Table:G6Y% G6Y
			INNER JOIN %Table:GZC% GZC 
				ON GZC.GZC_FILIAL = %xFilial:GZC% 
				AND GZC.GZC_CODIGO = G6Y.G6Y_CODGZC
				AND GZC.GZC_GERTIT = '1'
				AND GZC.%NotDel%
			INNER JOIN %Table:GI6% GI6 
				ON GI6.GI6_FILIAL = G6Y.G6Y_FILIAL
				AND GI6.GI6_CODIGO = G6Y.G6Y_CODAGE
				AND GI6.%NotDel%
			LEFT JOIN %Table:SE1% SE1 ON 
				SE1.E1_HIST = G6Y.G6Y_CODIGO || G6Y.G6Y_CODAGE || G6Y.G6Y_NUMFCH || G6Y.G6Y_ITEM
				AND SE1.%NotDel%
			WHERE G6Y.G6Y_FILIAL = %xFilial:G6Y%
	    		AND G6Y.G6Y_CODIGO = %Exp:G6T->G6T_CODIGO%
				AND G6Y.G6Y_CODAGE = %Exp:G6T->G6T_AGENCI%
				AND G6Y.%NotDel%
				AND G6Y.G6Y_TPLANC IN ('8','9')
			  	
		EndSQL
		
		Begin Transaction
	
				While (cAliasReD)->(!Eof()) .And. lRet 
					
					Aadd(aDados,{	(cAliasReD)->G6Y_CODIGO,;
									(cAliasReD)->G6Y_CODAGE,;
									(cAliasReD)->G6Y_NUMFCH,;
									(cAliasReD)->G6Y_ITEM,;
									(cAliasReD)->GZC_PREFIX,;
									(cAliasReD)->GZC_NATUR,;
									(cAliasReD)->RECG6Y,;
									(cAliasReD)->G6Y_VALOR,;
									(cAliasReD)->GI6_CLIENT,;
									(cAliasReD)->GI6_LJCLI,;
									(cAliasReD)->GI6_FORNEC,;
									(cAliasReD)->GI6_LOJA,;
									(cAliasReD)->GI6_FILRES})
										
					If (cAliasReD)->G6Y_TPLANC == '8' // Receita
						
						lRet := CanTitRec(aDados,lJob,@cMsgErro,@cMsgTit)
						aDados			:= {}	
					
						if FwIsInCallStack('GTPA700M_2')
							lRet := .T.
						EndIf
					
					Else // Despesa
						
						lRet := CanTitDesp(aDados,lJob,@cMsgErro,@cMsgTit)
						aDados			:= {}

						if FwIsInCallStack('GTPA700M_2')
							lRet := .T.
						EndIf
					
					Endif
						
					If !lRet
						
						DisarmTransaction()
						Exit
	
					Endif
						
					(cAliasReD)->(dbSkip())
	
				EndDo
						
			End Transaction
			
			cStatus := IIf(lRet,'5','6')
			
			RecLock('G6T', .F.)
			G6T->G6T_STSTIT := cStatus 
			G6T->(MsUnlock())		
		
			RestArea(aAreaG6T)		
				
	Endif
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerTitDesp()

Função para geração dos títulos de despesas

@sample	GTPA700M()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		10/08/2020
@version	P12
/*/
Static Function GerTitDesp(aDados,lJob,cMsgErro,cMsgTit)
Local lRet       := .T.
Local cFilAtu    := cFilAnt
Local cNum       := ''
Local cHistTit	 := ''
Local cTipo		 := 'TF'
Local cParcela	 := StrZero(1, TamSx3('E2_PARCELA')[1])
Local cNatTit  	 := GPA281PAR("NATUREZA")
Local cPrefixo	 := PadR("DSP", TamSx3('E2_PREFIXO')[1])  
Local cHistBaixa := STR0007 //'Baixa automatica de título de despesa'
Local cPath		 := GetSrvProfString("StartPath","")
Local cFile		 := ""
Local aAreaG6Y	 := G6Y->(GetArea())
Local aTitulo    := {}
Local aBaixa     := {}

private lMsErroAuto	:= .F.

	cNum	:= GetSxEnum('SE2', 'E2_NUM')

	cTitChave := xFilial("SE2") + cPrefixo + cNum + cParcela + cTipo
	
	cHistTit	:=  aDados[1][1] + aDados[1][2] + aDados[1][3] + aDados[1][4]  //(cAliasQry)->( G6Y_CODIGO + G6Y_CODAGE + G6Y_NUMFCH + G6Y_ITEM )
					
	If !(Empty(aDados[1][5]))
	
		cPrefixo := aDados[1][5]
	
	Endif
	
	If !(Empty(aDados[1][6]))
	
		cNatTit := aDados[1][6]
	
	Endif
	
	SE2->(DbSetOrder(1))
	
	If !Empty(aDados[1][12]) // GI6_FILRES
	
		cFilAnt := aDados[1][13]
		
	Endif 
	SED->(DbSetOrder(1))
	SED->(DbSeek(xFilial("SED") + cNatTit ))						
	aTitulo :=	{;
					{ "E2_PREFIXO"	, cPrefixo        , Nil },; //Prefixo 
					{ "E2_NUM"      , cNum            , Nil },; //Numero
					{ "E2_TIPO"		, cTipo           , Nil },; //Tipo
					{ "E2_PARCELA"	, cParcela        , Nil },; //Parcela
					{ "E2_NATUREZ"	, cNatTit         , Nil },; //Natureza
					{ "E2_FORNECE"	, aDados[1][11]   , Nil },; //Fornecedor
					{ "E2_LOJA"		, aDados[1][12]   , Nil },; //Loja
					{ "E2_EMISSAO"	, dDataBase       , Nil },; //Data Emissão
					{ "E2_VENCTO"   , dDataBase       , Nil },; //Data Vencto
					{ "E2_VENCREA"	, dDataBase       , Nil },; //Data Vencimento Real
					{ "E2_MOEDA"    , 1               , Nil },; //Moeda
					{ "E2_VALOR"    , aDados[1][8]    , Nil },; //Valor
					{ "E2_HIST"		, cHistTit        , Nil },; //Historico
					{ "E2_ORIGEM"   , "GTPA700M"      , Nil };  //Origem
				}
									
	MsExecAuto( { |x,y| Fina050(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
	
		
	If !lMsErroAuto
	
		CONFIRMSX8()
						
	Else
					
		lRet := .F.
		RollbackSx8()
		If !lJob
			MostraErro()
		Else
			cMsgErro := MostraErro(cPath,cFile)
		Endif
	Endif
						
	If lRet
					
		aBaixa := { {"E2_PREFIXO"		,aTitulo[1][2] 	,Nil},;
						{"E2_NUM"			,aTitulo[2][2] 	,Nil},;
						{"E2_TIPO"			,aTitulo[3][2]	,Nil},;
						{"E2_PARCELA"		,aTitulo[4][2] 	,Nil},;
						{"E2_CLIENTE"		,aTitulo[6][2] 	,Nil},;
						{"E2_LOJA"			,aTitulo[7][2] 	,Nil},;
						{"E2_FILIAL"		,xFilial("SE2")		,Nil},;
						{"AUTMOTBX"			,"BXP"				,Nil},;
						{"AUTDTBAIXA"		,dDatabase  		,Nil},;
						{"AUTDTCREDITO"		,dDatabase  		,Nil},;
						{"AUTHIST"			,cHistBaixa	 		,Nil},;
						{"AUTVLRPG"			,aTitulo[12][2] 	,Nil},;
						{"AUTVLRME"			,aTitulo[12][2]  	,Nil}}  
				
		MSExecAuto({|x,y| Fina080(x,y)}, aBaixa, 3) // Baixa	
			
		If lMsErroAuto
		
			lRet := .F.
			If !lJob
				MostraErro()
			Else
				cMsgErro := MostraErro(cPath,cFile)
			EndIf
		Endif
			
	Endif
	
	If lRet
	
		DbSelectArea("G6Y")
		
		cFilAnt := cFilAtu		
						
		G6Y->(DbGoTo(aDados[1][7]))

		Reclock("G6Y", .F.)

			G6Y->G6Y_CHVTIT := cTitChave
		
		G6Y->(MsUnlock())
		
		RestArea(aAreaG6Y)
		
	Endif
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerTitRec()

Função para geração dos títulos de receitas

@sample	GTPA700M()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		10/08/2020
@version	P12
/*/
Static Function GerTitRec(aDados,lJob,cMsgErro,cMsgTit)
Local lRet        := .T.
Local cFilAtu     := cFilAnt
Local aTitulo     := {}
Local aBaixa      := {}
Local cNum        := ''
Local cHistTit    := ''
Local cTipo       := 'TF'
Local cParcela    := StrZero(1,TamSx3('E1_PARCELA')[1])
Local cNatTit     := GPA281PAR("NATUREZA")
Local cPrefixo    := PadR("REC", TamSx3('E1_PREFIXO')[1])  
Local cHistBaixa  := STR0008 //'Baixa automatica de título de receita'
Local cPath       := GetSrvProfString("StartPath","")
Local cFile       := ""
Local aAreaG6Y    := G6Y->(GetArea())

Private lMsErroAuto	:= .F.

	cNum	:= GetSxEnum('SE1', 'E1_NUM')

	cTitChave := xFilial("SE1") + cPrefixo + cNum + cParcela + cTipo
	
	cHistTit	:=  aDados[1][1] + aDados[1][2] + aDados[1][3] + aDados[1][4]  //(cAliasQry)->( G6Y_CODIGO + G6Y_CODAGE + G6Y_NUMFCH + G6Y_ITEM )
			
	If !(Empty(aDados[1][5]))
	
		cPrefixo := aDados[1][5]
	
	Endif
	
	If !(Empty(aDados[1][6]))
	
		cNatTit := aDados[1][6]
	
	Endif
			
	SE1->(DbSetOrder(1))
	
	If !Empty(aDados[1][12]) // GI6_FILRES
	
		cFilAnt := aDados[1][13]
		
	Endif 
	SED->(DbSetOrder(1))		
	SED->(DbSeek(xFilial("SED") + cNatTit ))	
	aTitulo :=	{;
					{ "E1_PREFIXO"	, cPrefixo /*aDados[1][5]*/	, Nil },; //Prefixo 
					{ "E1_NUM"			, cNum							, Nil },; //Numero
					{ "E1_TIPO"		, cTipo						, Nil },; //Tipo
					{ "E1_PARCELA"	, cParcela						, Nil },; //Parcela
					{ "E1_NATUREZ"	, cNatTit						, Nil },; //Natureza
					{ "E1_CLIENTE"	, aDados[1][9]				, Nil },; //Cliente
					{ "E1_LOJA"		, aDados[1][10]				, Nil },; //Loja
					{ "E1_EMISSAO"	, dDataBase					, Nil },; //Data Emissão
					{ "E1_VENCTO"		, dDataBase					, Nil },; //Data Vencto
					{ "E1_VENCREA"	, dDataBase					, Nil },; //Data Vencimento Real
					{ "E1_MOEDA"		, 1								, Nil },; //Moeda
					{ "E1_VALOR"		, aDados[1][8]				, Nil },; //Valor
					{ "E1_SALDO"		, aDados[1][8]				, Nil },; //Valor
					{ "E1_HIST"		, cHistTit						, Nil },; //Historico
					{ "E1_ORIGEM"		, "GTPA700M"					, Nil };  //Origem
				}
					
	MsExecAuto( { |x,y| Fina040(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
	
		
	If !lMsErroAuto
	
		CONFIRMSX8()
						
	Else
					
		lRet := .F.
		RollbackSx8()
		If !lJob
			MostraErro()
		Else
			cMsgErro := MostraErro(cPath,cFile)
		Endif

	Endif
						
	If lRet
					
		aBaixa := { {"E1_PREFIXO"		,aTitulo[1][2] 	,Nil},;
						{"E1_NUM"			,aTitulo[2][2] 	,Nil},;
						{"E1_TIPO"			,aTitulo[3][2]	,Nil},;
						{"E1_FILIAL"		,xFilial("SE1") 	,Nil},;
						{"AUTMOTBX"		,"BXR"				,Nil},;
						{"AUTDTBAIXA"		,dDatabase  		,Nil},;
						{"AUTDTCREDITO"	,dDatabase  		,Nil},;
						{"AUTHIST"			,cHistBaixa	 	,Nil},;
	           		{"AUTJUROS"		,0               	,Nil,.T.},;
						{"AUTVALREC"		,aTitulo[12][2] 	,Nil}}  
						
				
		MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3) // Baixa	
			
		If lMsErroAuto
		
			lRet := .F.
			If !lJob
				MostraErro()
			Else
				cMsgErro := MostraErro(cPath,cFile)
			Endif
		
		Endif
			
	Endif
	
	If lRet
	
		DbSelectArea("G6Y")
		
		cFilAnt := cFilAtu		
						
		G6Y->(DbGoTo(aDados[1][7]))
		
		Reclock("G6Y", .F.)

			G6Y->G6Y_CHVTIT := cTitChave
		
		G6Y->(MsUnlock())
		
		RestArea(aAreaG6Y)
		
	Endif

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CanTitDesp()

Função para geração dos títulos de despesas

@sample	GTPA700M()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		10/08/2020
@version	P12
/*/
Static Function CanTitDesp(aDados,lJob,cMsgErro,cMsgTit)
Local lRet			:= .T.
Local cFilAtu		:= cFilAnt
Local aTitulo		:= {}
Local aBaixa		:= {}
Local cNum			:= ''
Local cHistTit	:= ''
Local cTipo		:= 'TF'
Local cParcela	:= StrZero(1, TamSx3('E2_PARCELA')[1])
Local cNatTit  	:= GPA281PAR("NATUREZA")
Local cPrefixo	:= PadR("DSP", TamSx3('E2_PREFIXO')[1])  
Local cHistBaixa	:= STR0007 //'Baixa automatica de título de despesa'

Local cPath     := GetSrvProfString("StartPath","")
Local cFile     := ""


private lMsErroAuto	:= .F.

	cNum	:= GetSxEnum('SE2', 'E2_NUM')

	cTitChave := xFilial("SE2") + cPrefixo + cNum + cParcela + cTipo
	
	cHistTit	:=  aDados[1][1] + aDados[1][2] + aDados[1][3] + aDados[1][4]  //(cAliasQry)->( G6Y_CODIGO + G6Y_CODAGE + G6Y_NUMFCH + G6Y_ITEM )
					
	If !(Empty(aDados[1][5]))
	
		cPrefixo := aDados[1][5]
	
	Endif
	
	If !(Empty(aDados[1][6]))
	
		cNatTit := aDados[1][6]
	
	Endif
	
	SE2->(DbSetOrder(1))
	
	If !Empty(aDados[1][12]) // GI6_FILRES
	
		cFilAnt := aDados[1][13]
		
	Endif 
	SED->(DbSetOrder(1))
	SED->(DbSeek(xFilial("SED") + cNatTit ))						
	aTitulo :=	{;
					{ "E2_PREFIXO"	, cPrefixo /*aDados[1][5]*/	, Nil },; //Prefixo 
					{ "E2_NUM"			, cNum							, Nil },; //Numero
					{ "E2_TIPO"		, cTipo						, Nil },; //Tipo
					{ "E2_PARCELA"	, cParcela						, Nil },; //Parcela
					{ "E2_NATUREZ"	, cNatTit						, Nil },; //Natureza
					{ "E2_FORNECE"	, aDados[1][11]				, Nil },; //Fornecedor
					{ "E2_LOJA"		, aDados[1][12]				, Nil },; //Loja
					{ "E2_EMISSAO"	, dDataBase					, Nil },; //Data Emissão
					{ "E2_VENCTO"		, dDataBase					, Nil },; //Data Vencto
					{ "E2_VENCREA"	, dDataBase					, Nil },; //Data Vencimento Real
					{ "E2_MOEDA"		, 1								, Nil },; //Moeda
					{ "E2_VALOR"		, aDados[1][8]				, Nil },; //Valor
					{ "E2_HIST"		, cHistTit						, Nil },; //Historico
					{ "E2_ORIGEM"		, "GTPA700M"					, Nil };  //Origem
				}
									
	MsExecAuto( { |x,y| Fina050(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
	
		
	If !lMsErroAuto
	
		CONFIRMSX8()
						
	Else
					
		lRet := .F.
		RollbackSx8()
		If !lJob
			MostraErro()
		Else
			cMsgErro := MostraErro(cPath,cFile)
		Endif
	Endif
						
	If lRet
					
		aBaixa := { {"E2_PREFIXO"		,aTitulo[1][2] 	,Nil},;
						{"E2_NUM"			,aTitulo[2][2] 	,Nil},;
						{"E2_TIPO"			,aTitulo[3][2]	,Nil},;
						{"E2_PARCELA"		,aTitulo[4][2] 	,Nil},;
						{"E2_CLIENTE"		,aTitulo[6][2] 	,Nil},;
						{"E2_LOJA"			,aTitulo[7][2] 	,Nil},;
						{"E2_FILIAL"		,xFilial("SE2")		,Nil},;
						{"AUTMOTBX"			,"BXP"				,Nil},;
						{"AUTDTBAIXA"		,dDatabase  		,Nil},;
						{"AUTDTCREDITO"		,dDatabase  		,Nil},;
						{"AUTHIST"			,cHistBaixa	 		,Nil},;
						{"AUTVLRPG"			,aTitulo[12][2] 	,Nil},;
						{"AUTVLRME"			,aTitulo[12][2]  	,Nil}}  
				
		MSExecAuto({|x,y| Fina080(x,y)}, aBaixa, 3) // Baixa	
			
		If lMsErroAuto
		
			lRet := .F.
			If !lJob
				MostraErro()
			Else
				cMsgErro := MostraErro(cPath,cFile)
			EndIf
		Endif
			
	Endif
	
	If lRet
	
		DbSelectArea("G6Y")
		
		cFilAnt := cFilAtu		
						
		G6Y->(DbGoTo(aDados[1][7]))
		
		RecLock("G6Y", .F.)
											
			G6Y->G6Y_CHVTIT := cTitChave
											
		G6Y->(MsUnlock())
		
	Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CanTitRec()

Função para geração dos títulos de receitas

@sample	GTPA700M()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		10/08/2020
@version	P12
/*/
Static Function CanTitRec(aDados,lJob,cMsgErro,cMsgTit)
Local lRet				:= .T.
Local cFilAtu			:= cFilAnt
Local aTitulo			:= {}
Local aBaixa			:= {}
Local cNum				:= ''
Local cHistTit		:= ''
Local cTipo			:= 'TF'
Local cParcela		:= StrZero(1,TamSx3('E1_PARCELA')[1])
Local cNatTit	  		:= GPA281PAR("NATUREZA")
Local cPrefixo		:= PadR("REC", TamSx3('E1_PREFIXO')[1])  
Local cHistBaixa		:= STR0008 //'Baixa automatica de título de receita'

Local cPath     := GetSrvProfString("StartPath","")
Local cFile     := ""

Private lMsErroAuto	:= .F.

	cNum	:= GetSxEnum('SE1', 'E1_NUM')

	cTitChave := xFilial("SE1") + cPrefixo + cNum + cParcela + cTipo
	
	cHistTit	:=  aDados[1][1] + aDados[1][2] + aDados[1][3] + aDados[1][4]  //(cAliasQry)->( G6Y_CODIGO + G6Y_CODAGE + G6Y_NUMFCH + G6Y_ITEM )
			
	If !(Empty(aDados[1][5]))
	
		cPrefixo := aDados[1][5]
	
	Endif
	
	If !(Empty(aDados[1][6]))
	
		cNatTit := aDados[1][6]
	
	Endif
			
	SE1->(DbSetOrder(1))
	
	If !Empty(aDados[1][12]) // GI6_FILRES
	
		cFilAnt := aDados[1][13]
		
	Endif 
	SED->(DbSetOrder(1))		
	SED->(DbSeek(xFilial("SED") + cNatTit ))	
	aTitulo :=	{;
					{ "E1_PREFIXO"	, cPrefixo /*aDados[1][5]*/	, Nil },; //Prefixo 
					{ "E1_NUM"			, cNum							, Nil },; //Numero
					{ "E1_TIPO"		, cTipo						, Nil },; //Tipo
					{ "E1_PARCELA"	, cParcela						, Nil },; //Parcela
					{ "E1_NATUREZ"	, cNatTit						, Nil },; //Natureza
					{ "E1_CLIENTE"	, aDados[1][9]				, Nil },; //Cliente
					{ "E1_LOJA"		, aDados[1][10]				, Nil },; //Loja
					{ "E1_EMISSAO"	, dDataBase					, Nil },; //Data Emissão
					{ "E1_VENCTO"		, dDataBase					, Nil },; //Data Vencto
					{ "E1_VENCREA"	, dDataBase					, Nil },; //Data Vencimento Real
					{ "E1_MOEDA"		, 1								, Nil },; //Moeda
					{ "E1_VALOR"		, aDados[1][8]				, Nil },; //Valor
					{ "E1_SALDO"		, aDados[1][8]				, Nil },; //Valor
					{ "E1_HIST"		, cHistTit						, Nil },; //Historico
					{ "E1_ORIGEM"		, "GTPA700M"					, Nil };  //Origem
				}
					
	MsExecAuto( { |x,y| Fina040(x,y)}, aTitulo, 3) // 3-Inclusao,4-Alteração,5-Exclusão	
	
		
	If !lMsErroAuto
	
		CONFIRMSX8()
						
	Else
					
		lRet := .F.
		RollbackSx8()
		If !lJob
			MostraErro()
		Else
			cMsgErro := MostraErro(cPath,cFile)
		Endif

	Endif
						
	If lRet
					
					
		aBaixa := { {"E1_PREFIXO"		,aTitulo[1][2] 	,Nil},;
						{"E1_NUM"			,aTitulo[2][2] 	,Nil},;
						{"E1_TIPO"			,aTitulo[3][2]	,Nil},;
						{"E1_FILIAL"		,xFilial("SE1") 	,Nil},;
						{"AUTMOTBX"		,"BXR"				,Nil},;
						{"AUTDTBAIXA"		,dDatabase  		,Nil},;
						{"AUTDTCREDITO"	,dDatabase  		,Nil},;
						{"AUTHIST"			,cHistBaixa	 	,Nil},;
	           		{"AUTJUROS"		,0               	,Nil,.T.},;
						{"AUTVALREC"		,aTitulo[12][2] 	,Nil}}  
						
				
		MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3) // Baixa	
			
		If lMsErroAuto
		
			lRet := .F.
			If !lJob
				MostraErro()
			Else
				cMsgErro := MostraErro(cPath,cFile)
			Endif
		
		Endif
			
	Endif
	
	If lRet
	
		DbSelectArea("G6Y")
		
		cFilAnt := cFilAtu		
						
		G6Y->(DbGoTo(aDados[1][7]))
		
		RecLock("G6Y", .F.)
										
			G6Y->G6Y_CHVTIT := cTitChave
											
		G6Y->(MsUnlock())
		
	Endif

Return lRet

