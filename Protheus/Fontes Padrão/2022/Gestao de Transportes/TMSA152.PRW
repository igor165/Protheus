#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA152.CH"

//-- Tratamento Rentabilidade/Ocorrencia
Static aRecDep    := { '16',; //-- Rec. CTe Complemento
                       '17',; //-- Desp. Compl.
                       '18',; //-- Rec./Desp.
                       '19',; //-- Rec. CTe Reentrega
                       '20',; //-- Rec. CTe Devolução
                       '21' } //-- Trecho GFE

Static cAliasMbw
Static oMrkBrowse
Static oTabBrw
Static cTabBrw    := GetNextAlias()


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA152
                  Geração De Documentos Complementares
@author           Eduardo Alberti
@since            Jan./2017
@version          MP12
@sample           Tmsa152(aParSX1)
@see              TMSA360,TMSA500,TMSA250,TMSA151
@obs              
@param            aParSX1 -> Vetor Contendo Parametros Conforme Perguntas Do TMSA152 No SX1
@return           Nil
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa152(aParSX1 , lExibMsg )

	Local cPerg       := "TMSA152"
	Local oDlgMrk     := Nil
	Local aAlias      := {}
	Local aColumns    := {}
	Local nI          := 0
	Local aSeek       := {}
	Local aIndTmp     := {}
	Local bSetPar     := Nil
	Local lRet        := .T.

	Private aRotina   := MenuDef()
	Private cCadastro := OemToAnsi( STR0001 )	//-- "Documentos Complementares"
	
	Default aParSX1   	:= {}
	Default lExibMsg	:= .T.
	
	//-- Proteção De Erro Da Rotina Caso o Dicionário Da Rotina Não Exista
	If DUA->(ColumnPos("DUA_NUMCTE")) == 0
		//-- Mensagem genérica solicitando a atualização do sistema.
		MsgNextRel()
		Return()
	EndIf

	SaveInter()

	If Len(aParSX1) == 0
		If !(Pergunte( cPerg ,.T.))
			Return()
		EndIf
	Else
		
		//-- Carrega Variáveis Sem Interface
		Pergunte( cPerg ,.F.)
		
		//-- Carrega Parametros Por Macro Substituição 
		//-- Modelo -> aParSX1 := {'      ','ZZZZZZ',CtoD('01/01/2000'),CtoD('01/01/2020'),'        ','zzzzzzzz','         ','zzzzzzzzz','   ','zzz'}
		For nI := 1 To Len(aParSX1)
			&("MV_PAR" + StrZero(nI,02)) := aParSX1[nI]
		Next nI
	EndIf	

	//----------------------------------------------------------
	//-- Retorna as colunas para o preenchimento da FWMBrowse
	//----------------------------------------------------------
	aAlias      := TmMapExcQr()
	cAliasMbw   := aAlias[1]
	aColumns    := aAlias[2]
	aIndTmp     := aAlias[3]

	//----------------------------------------------------------
	//-- Insere Indice De Busca Por Rotinas
	//----------------------------------------------------------
	Aadd(aSeek,{ STR0002 , {{"","C",06,0, "DUA_VIAGEM"                   , STR0002 }}, 1, .T. } ) //-- "Viagem"
	Aadd(aSeek,{ STR0003 , {{"","C",20,0, "DT6_FILDOC+DT6_DOC+DT6_SERIE" , STR0003 }}, 2, .T. } ) //-- "Filial + Doc + Série"

	(cAliasMbw)->(DbGoTop())
	If !(cAliasMbw)->(Eof())

		//------------------------------------------
		//-- Criação da FWMBrowse
		//------------------------------------------
		oMrkBrowse:= FWMarkBrowse():New()

		oMrkBrowse:AddLegend("DUA_RECDEP == '0'", "BR_BRANCO"	, STR0033 ,"DUA_RECDEP")	//-- "Não Utiliza"
		oMrkBrowse:AddLegend("DUA_RECDEP == '2'", "BR_VERMELHO" , STR0004 ,"DUA_RECDEP")	//-- "Bloqueado"
		oMrkBrowse:AddLegend("DUA_RECDEP == '1'", "BR_VERDE" 	, STR0005 ,"DUA_RECDEP")	//-- "Liberado"
		oMrkBrowse:AddLegend("DUA_RECDEP == '3'", "BR_AZUL"		, STR0015 ,"DUA_RECDEP")	//-- "Gerado Documento"
		oMrkBrowse:AddLegend("DUA_RECDEP == '4'", "BR_AMARELO" 	, STR0034 ,"DUA_RECDEP")	//-- "Pendente"
		
		oMrkBrowse:SetFieldMark("DUA_OK")
		oMrkBrowse:SetOwner(oDlgMrk)
		oMrkBrowse:SetAlias(cAliasMbw)
		oMrkBrowse:SetMenuDef("TmsA152")
		
		oMrkBrowse:AddStatusColumns( {|| RetStatus(cAliasMbw) } , {|| LegStatus()} )
		
		oMrkBrowse:SetTemporary(.T.)
		oMrkBrowse:SetSeek(,aSeek)

		oMrkBrowse:bMark    := {|| TmsDUAMk(cAliasMbw)}
		oMrkBrowse:bAllMark := {|| TmsDUAIn(cAliasMbw)}
		oMrkBrowse:bValid	:= {|| VldMark(cAliasMbw)}
		oMrkBrowse:SetDescription( OemToAnsi( STR0001 ) ) //-- "Documentos Complementares"
		oMrkBrowse:SetColumns(aColumns)

		bSetPar := {|| Iif(ParamBrw(@cAliasMbw),(oMrkBrowse:SetAlias(cAliasMbw), oMrkBrowse:Refresh(.T.), oMrkBrowse:GoTop(.T.), .T.), .F.)}
		oMrkBrowse:SetParam(bSetPar)
		oMrkBrowse:AddButton(STR0031, bSetPar, , 12, 7) //STR0031 'Parâmetros'

		oMrkBrowse:Activate()

	Else
		lRet := .F.
		If lExibMsg
			Help("",1,"TMSA15202",,) //-- "Não Existem Registros Para Exibição. Verifique Parâmetros Da Rotina."
		EndIf
	EndIf

	//-- Exclui Arquivo Temporário Do Banco De Dados
	If ValType(oTabBrw) <> 'U'
		oTabBrw:Delete()
	Else
	
	EndIf	

	RestInter()

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@autor		: Eduardo Alberti
@descricao	: Montagem Do Menu Funcional Padrao Protheus
@since		: Jan./2017
@using		: 
@review     :
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aArea      := GetArea()
	Local aRotina    := {}

	ADD OPTION aRotina TITLE STR0007 ACTION 'Tmsa152Leg()'           OPERATION 2 ACCESS 0 DISABLE MENU	// Legenda
	ADD OPTION aRotina TITLE STR0008 ACTION 'Tmsa152Ger()'           OPERATION 3 ACCESS 0 DISABLE MENU	// Gerar
	ADD OPTION aRotina TITLE STR0016 ACTION 'Tmsa152Ger("E")'        OPERATION 3 ACCESS 0 DISABLE MENU	// Estornar
	ADD OPTION aRotina TITLE STR0017 ACTION 'Tmsa152Vis("P")'        OPERATION 2 ACCESS 0 DISABLE MENU	// "Vis.Doc.Princ"
	ADD OPTION aRotina TITLE STR0018 ACTION 'Tmsa152Vis("A")'        OPERATION 2 ACCESS 0 DISABLE MENU	// "Vis.Doc.Aux."
	ADD OPTION aRotina TITLE STR0025 ACTION 'Tmsa152Vis("L")'        OPERATION 2 ACCESS 0 DISABLE MENU	// "Vis.CTC.Princ"
	ADD OPTION aRotina TITLE STR0026 ACTION 'Tmsa152Vis("M")'        OPERATION 2 ACCESS 0 DISABLE MENU	// "Vis.CTC.Aux."

	RestArea(aArea)

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc}TmMapExcQr
Executa Query De Pesquisa Dos Apontamentos No DUA
@author Eduardo Alberti
@since  Jan./2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function TmMapExcQr( nRec ) 

	Local aArea      := GetArea()
	Local aStru      := {}
	Local aColumns   := {}
	Local aRestrict  := {"D_E_L_E_T_","R_E_C_N_O_","R_E_C_D_E_L_"}
	Local nX         := 0
	Local aCampos    := {}
	Local aIndTmp    := {}
	Local cQuery	 := ""
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local cTipIn     := SuperGetMV("MV_TRECDEP", .F. , '16|17|18|19|20|21' ) 
	Local cTip17	 := ""
	Local cDbType    := TCGetDB()
	
	Default nRec     := 0

	// Tratamento para ISNULL em diferentes BD's
	Do Case
		Case cDbType $ "DB2/POSTGRES"
			cFuncNull	:= "COALESCE"
		Case cDbType $ "ORACLE/INFORMIX"
	  		cFuncNull	:= "NVL"
	 	Otherwise
	 		cFuncNull	:= "ISNULL"
	EndCase
	
	//-- Tratamento ocorrencia 17 = Despesa
	If '17' $ cTipIn 
		cTipIn	:= StrTran(cTipIn,'17|')
		cTip17	:= "17"
	EndIf
	
	cQuery += " SELECT      DUA.DUA_FILORI,   DUA.DUA_VIAGEM,   DT6.DT6_FILDOC,   DT6.DT6_DOC,      DT6.DT6_SERIE,  " 
	cQuery += "             DUA.DUA_DATOCO,   DUA.DUA_HOROCO,   DUA.DUA_CODOCO,   DT2.DT2_DESCRI,   DT2.DT2_TIPOCO, " 
	cQuery += "             '' AS DT2_DTPOCO,                                                                       " 
	cQuery += "             DUA.DUA_FLOCTE,   DUA.DUA_NUMCTE,   DUA.DUA_SERCTE,   DUA.DUA_FLOCTC,   DUA.DUA_NUMCTC, " 
	cQuery += "             DUA.DUA_SERVIC,   '' AS DT5_DESSER, DUA.DUA_CODMOT,    "                                  
	cQuery += "             DT6.DT6_DATEMI,   DT6.DT6_HOREMI,   DT6.DT6_VALMER,   DT6.DT6_QTDUNI,   DT6.DT6_VALFRE, " 
	cQuery += "             DT6.DT6_VALIMP,   DT6.DT6_VALTOT,   DT6.DT6_BASSEG, "                                      
	cQuery += "             DUA.DUA_FILOCO,   DUA.DUA_NUMOCO,   DUA.DUA_SEQOCO,   DUA.DUA_FILORI,   DUA.DUA_VLRRCT, " 
	cQuery += "             DUA.DUA_TIPVEI,   DUA.DUA_VLRDSP,   DUA.DUA_CODFOR,   DUA.DUA_LOJFOR,   DUA.DUA_VALINF, " 
	cQuery += "             DT6.DT6_SERTMS,   '' AS DT6_DESSVT, DT6.DT6_TIPTRA,   '' AS DT6_DESTPT, DT6.DT6_DOCTMS, " 
	cQuery += "             DT6.DT6_CDRORI,   '' AS DTC_REGORI, DT6.DT6_CDRDES,   '' AS DTC_REGDES, DT6.DT6_CDRCAL, " 
	cQuery += "             '' AS DTC_REGCAL, DT6.DT6_TABFRE,   DT6.DT6_TIPTAB,   DT6.DT6_SEQTAB,   DT6.DT6_TIPFRE, "  
	cQuery += "             DT6.DT6_DOCSEG,   DT6.DT6_NCONTR,   DT6.DT6_PRZENT,   DT6.DT6_FILORI,   DT6.DT6_LOTNFC, " 
	cQuery += "             DT6.DT6_FILDES,                                                                         " 
	cQuery += "             DT6.DT6_CLIREM,   DT6.DT6_LOJREM,   '' AS DTC_NOMREM,                                   "   
	cQuery += "             DT6.DT6_CLIDES,   DT6.DT6_LOJDES,   '' AS DTC_NOMDES,                                   " 
	cQuery += "             DT6.DT6_CLICON,   DT6.DT6_LOJCON,   '' AS DTC_NOMCON,                                   " 
	cQuery += "             DT6.DT6_CLIDPC,   DT6.DT6_LOJDPC,   '' AS DTC_NOMDPC,                                   "    
	cQuery += "             DT6.DT6_CLIDEV,   DT6.DT6_LOJDEV,   '' AS DTC_NOMDEV,                                   "    
	cQuery += "             DT6.DT6_CLICAL,   DT6.DT6_LOJCAL,   '' AS DTC_NOMCAL,                                   "    
	cQuery += "             DT6.DT6_DEVFRE,   DT6.DT6_REENTR,                                                       " 
	cQuery += "             DT6.DT6_NFELET,   DT6.DT6_EMINFE,   DT6.DT6_CODNFE,   DT6.DT6_CHVCTE,   DT6.DT6_SITCTE, " 
	cQuery += "             DUA.DUA_RECDEP,   "                                                                       
	cQuery += "             (  SELECT      " + cFuncNull + "(MIN(DTY.R_E_C_N_O_),0) "                         
	cQuery += "                FROM        " +	RetSqlName("DTY") + " DTY "                                   
	cQuery += "                WHERE       DTY.DTY_FILIAL = '" + FWxFilial("DTY") + "' "                      
	cQuery += "                AND         DTY.DTY_FILORI = DUA.DUA_FILORI "                                  
	cQuery += "                AND         DTY.DTY_VIAGEM = DUA.DUA_VIAGEM "                                  
	cQuery += "                AND         DTY.D_E_L_E_T_ = ' ' "                                              
	cQuery += "             ) AS DTYREC,"                                                                     
	cQuery += "             DT6.R_E_C_N_O_ DT6REC, DUA.R_E_C_N_O_ DUAREC "                                    
	cQuery += " FROM        " +	RetSqlName("DT6") + " DT6 "                                                   
	cQuery += " INNER JOIN  " +	RetSqlName("DUA") + " DUA "                                                   
	cQuery += " ON          DUA.DUA_FILIAL =       '" + xFilial("DUA") + "' "                                 
	cQuery += " AND         DUA.DUA_FILDOC =       DT6.DT6_FILDOC "                                           
	cQuery += " AND         DUA.DUA_DOC    =       DT6.DT6_DOC "                                              
	cQuery += " AND         DUA.DUA_SERIE  =       DT6.DT6_SERIE "                                            
	
	If nRec == 0
	
		cQuery += " AND         DUA.DUA_VIAGEM BETWEEN '" + MV_PAR01       + "' AND '" + MV_PAR02       + "' "
		cQuery += " AND         DUA.DUA_DATOCO BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "' "
	
		If MV_PAR11 == 1     //-- Somente Liberados
			cQuery += " AND     DUA.DUA_RECDEP =     '1' "                                                     
		ElseIf MV_PAR11 == 2 //-- Somente Bloqueados
			cQuery += " AND     DUA.DUA_RECDEP =     '2' "                                                    	
		ElseIf MV_PAR11 == 3 //-- Somente Documentos Gerados
			cQuery += " AND     DUA.DUA_RECDEP =     '3' "                                                    
		EndIf
	
	Else
		cQuery += " AND         DUA.R_E_C_N_O_ = " + Alltrim(Str(nRec)) + " "                                 
	EndIf
			
	cQuery += " AND         DUA.D_E_L_E_T_ =       ' ' "                                                      
	cQuery += " INNER JOIN  " +	RetSqlName("DT2") + " DT2 "                                                   
	cQuery += " ON          DT2.DT2_FILIAL =       '" + xFilial("DT2") + "' "                                 
	cQuery += " AND         DT2.DT2_CODOCO =       DUA.DUA_CODOCO "                                           
	
	If Empty(cTip17)
		cQuery += " AND         DT2.DT2_TIPOCO IN      " + FormatIn( cTipIn ,"|") + " "                           
	Else
		//-- Se a ocorrencia for do tipo 17, não pode ter ocorrencia GFE vinculada
		cQuery += " AND        ( DT2.DT2_TIPOCO IN      " + FormatIn( cTipIn ,"|") + " "                           
		cQuery += " OR DT2.DT2_TIPOCO = CASE WHEN DT2.DT2_TIPOCO = '"+ cTip17 +"' AND DT2_CDTIPO = ' ' "
		cQuery += " THEN DT2.DT2_TIPOCO "
		cQuery += " ELSE 'NOT NULL' END  ) "
	EndIf

	//-- Exclui Itens De Acréscimo e Decréscimo Que Já Foram Tratados No Contrato Principal
	If DUA->(ColumnPos("DT2_CODAED")) > 0
		cQuery += " AND     DT2.DT2_CODAED =       '" + Space(TamSX3("DT2_CODAED")[1]) + "' "                 
	EndIf	
	
	cQuery += " AND         DT2.D_E_L_E_T_ =       ' ' "                                                      
	cQuery += " LEFT JOIN   " +	RetSqlName("SYP") + " SYP "                                                   
	cQuery += " ON          SYP.YP_FILIAL  =       '" + xFilial("SYP") + "' "                                 
	cQuery += " AND         SYP.YP_CHAVE   =       DUA.DUA_CODMOT "                                           
	cQuery += " AND         SYP.YP_SEQ     =       '001' "                                                    
	cQuery += " AND         SYP.D_E_L_E_T_ =       ' ' "                                                      
	cQuery += " WHERE       DT6.DT6_FILIAL =       '" + xFilial("DT6") + "' "                                 
	
	If nRec == 0
		cQuery += " AND         DT6.DT6_FILDOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "            
		cQuery += " AND         DT6.DT6_DOC    BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "            
		cQuery += " AND         DT6.DT6_SERIE  BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "            
		cQuery += " AND         DT2.DT2_TIPOCO BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "' "            
	EndIf
	
	cQuery += " AND         DT6.D_E_L_E_T_ =       ' ' "                                                      

	cQuery := ChangeQuery(cQuery)

	Processa( {|| Eval(bQuery)}, STR0009 , STR0010 ,.F.) // Aguarde... Consultando...

	aEval(DUA->(dbStruct()),{|e| If(e[2] != "C" .And. Alltrim(e[1]) $ Upper(cQuery) , TCSetField(cAliasT,e[1],e[2],e[3],e[4]),Nil)})
	aEval(DT6->(dbStruct()),{|e| If(e[2] != "C" .And. Alltrim(e[1]) $ Upper(cQuery) , TCSetField(cAliasT,e[1],e[2],e[3],e[4]),Nil)})

	//-- Formata Campo R_E_C_N_O_
	TcSetField(cAliasT,"DTYREC","N",16,0)
	TcSetField(cAliasT,"DT6REC","N",16,0)
	TcSetField(cAliasT,"DUAREC","N",16,0)

	aCampos := (cAliasT)->(DbStruct())
	
	Aadd(aStru, {"DUA_OK","C",2,0}) //-- Campo Para Marcação
	
	//-- Gera Vetor Estrutura Do Browse
	For nX := 1 To Len(aCampos)
	
			If aScan(aRestrict,aCampos[nX,1]) == 0
			aAdd(aStru, aCampos[nX])
		EndIf
	
	Next nX
	
		oTabBrw := FwTemporaryTable():New( cTabBrw )
		oTabBrw:SetFields( aStru )
		oTabBrw:AddIndex( STR0002 , {"DUA_VIAGEM"} )                        //-- Viagem
		oTabBrw:AddIndex( STR0014 , {"DT6_FILDOC","DT6_DOC","DT6_SERIE"} ) //-- Documento
		oTabBrw:Create()		
	
	DbSelectArea(cAliasT)
	(cAliasT)->(DbGoTop())

	DbSelectArea(cTabBrw)
	Append From &(cAliasT)

	If nRec == 0
		aColumns := FillCols(aStru, cTabBrw)
	EndIf

	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return {cTabBrw, aColumns, aIndTmp}

/*/{Protheus.doc} FillCols
	(long_description)
	@type Function
	@author arume.alexandre
	@since date
	@version version
	@param aStru, Array, param_descr
	@param cTabBrw, Character, param_descr
	@return aColumns, Array, return_description
/*/
Static Function FillCols(aStru, cTabBrw)

	Local aTipOco   := {}
	Local aSerTMS   := {}
	Local aTipTra   := {}
	Local aData		:= {}
	Local bA1Nome	:= {}
	Local bDUYDescri	:= {}
	Local nX			:= 0
	Local nPos			:= 0
	Local cTab			:= ""
	Local aColumns		:= {}	

	//--------------------------------------------------------------------------
	//-- Tratamento Para Preencher Campos Nome/Descrição da Tabela Temporária
	//--------------------------------------------------------------------------
	//-- Resolve Campos Contidos No TmsValField
	aTipOco := TmsValField("DT2->DT2_TIPOCO",.f.,Nil,Nil,.t. )
	aSerTMS := TmsValField("SERTMS",.f.,Nil,Nil,.t. )
	aTipTra := TmsValField("TIPTRA",.f.,Nil,Nil,.t. )
	
	bA1Nome := {|cliente, loja| Posicione("SA1", 1, FWxFilial("SA1") + cliente + loja, "A1_NOME")}
	bDUYDescri := {|codigo| Posicione("DUY", 1, FWxFilial("DUY") + codigo, "DUY_DESCRI")}
	AAdd(aData, { "DT2_DTPOCO",;
				{||aTipOco[aScan(aTipOco,{ |x| AllTrim( x[ 1 ] ) == (cTabBrw)->DT2_TIPOCO }), 02]},;
				Len(aTipOco[01, 02]) })
	
	AAdd(aData, {'DT5_DESSER',;
				{|| Tabela("L4",(cTabBrw)->DUA_SERVIC,.F.)},;
				Len(Tabela("L4",(cTabBrw)->DUA_SERVIC,.F.))})

	AAdd(aData, {'DT6_DESSVT',;
				{|| aSerTMS[aScan(aSerTMS,{ |x| AllTrim( x[ 1 ] ) == (cTabBrw)->DT6_SERTMS }),02]},;
				Len(aSerTMS[01, 02])})

	AAdd(aData, {'DT6_DESTPT',;
				{|| aTipTra[aScan(aTipTra,{ |x| AllTrim( x[ 1 ] ) == (cTabBrw)->DT6_TIPTRA }),02]},;
				Len(aTipTra[01, 02])})
		
	AAdd(aData, {'DTC_REGORI',;
				{|| (cTabBrw)->(Eval(bDUYDescri, DT6_CDRORI))},;
				TamSX3("DUY_DESCRI")[1]})

	AAdd(aData, {'DTC_REGDES',;
				{|| (cTabBrw)->(Eval(bDUYDescri, DT6_CDRDES))},;
				TamSX3("DUY_DESCRI")[1]})

	AAdd(aData, {'DTC_REGCAL',;
				{|| (cTabBrw)->(Eval(bDUYDescri, DT6_CDRCAL))},;
				TamSX3("DUY_DESCRI")[1]})
	
	AAdd(aData, {'DTC_NOMREM',;
				{|| (cTabBrw)->(Eval(bA1Nome, DT6_CLIREM, DT6_LOJREM))},;
				TamSX3("A1_NOME")[1]})
	
	AAdd(aData, {'DTC_NOMDES',;
				{|| (cTabBrw)->(Eval(bA1Nome, DT6_CLIDES, DT6_LOJDES))},;
				TamSX3("A1_NOME")[1]})
	
	AAdd(aData, {'DTC_NOMDPC',;
				{|| (cTabBrw)->(Eval(bA1Nome, DT6_CLICON, DT6_LOJCON))},;
				TamSX3("A1_NOME")[1]})
	
	AAdd(aData, {'DT6_CLIDPC',;
				{|| (cTabBrw)->(Eval(bA1Nome, DT6_CLIDPC, DT6_LOJDPC))},;
				TamSX3("A1_NOME")[1]})
	
	AAdd(aData, {'DTC_NOMDEV',;
				{|| (cTabBrw)->(Eval(bA1Nome, DT6_CLIDEV, DT6_LOJDEV))},;
				TamSX3("A1_NOME")[1]})
	
	AAdd(aData, {'DTC_NOMCAL',;
				{|| (cTabBrw)->(Eval(bA1Nome, DT6_CLICAL, DT6_LOJCAL))},;
				TamSX3("A1_NOME")[1]})
	
	// nX := 2 para não incluir o campo DUA_OK.
	For nX := 2 To Len(aStru)
		cTab := SubStr(aStru[nX][1], 1, At("_", aStru[nX][1]) -1)
	
			AAdd(aColumns,FWBrwColumn():New())

		nPos := AScan(aData,{ |estrutura| estrutura[1] == aStru[nX,1]})
		
		If nPos > 0
			aColumns[Len(aColumns)]:SetData(aData[nPos][2])
			aColumns[Len(aColumns)]:SetSize(aData[nPos][3])
		Else
			aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
			aColumns[Len(aColumns)]:SetData(&("{||" + aStru[nX][1] + "}"))
		EndIf

		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
			aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])

		If !(aStru[nX][1] $ "DUA_OK, DTYREC, DT6REC, DUAREC")
			aColumns[Len(aColumns)]:SetPicture(PesqPict(cTab, aStru[nX][1]))
	EndIf
	Next nX
Return aColumns

/*/{Protheus.doc} VldMark
//Validação do markbrowse
@author caio.y
@since 06/09/2017
@version undefined
@param cAliasTRB, characters, descricao
@type function
/*/
Static Function VldMark(cAliasTRB)
Local lRet	:= .T. 

Default cAliasTRB	:= ""

If  (cAliasTRB)->DUA_RECDEP == '1' 	.And.; 	//-- Liberado Para Processamento
				(cAliasTRB)->DTYREC == 0 		.And.;  //-- Sem Contrato Carreteiro Principal Gerado Ainda
				Empty((cAliasTRB)->DUA_NUMCTC) 	.And.; 	//-- Sem Contr. Carreteiro Gerado
				(cAliasTRB)->DT2_TIPOCO $ '17/18/21'  	//-- 17=Despesa, 18=Receita/Despesa, 21=Trecho GFE ( Contrato Carreteiro )
	
	Help("",1,"TMSA15204",,) //-- "Contrato Carreteiro Complementar Só Poderá Ser Gerado Quando Houver Contrato Principal Gerado! "
	lRet	:= .F. 
				
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDUAMk
Marcacao De Um Registro
@author Totvs
@since Jan/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsDUAMk(cAliasTRB)

	Local lRet    := .T.
	Local cMarca  := oMrkBrowse:cMark
	Local aArea   := GetArea()
	Local nRec    := (cAliasTRB)->(Recno())
	Local lLimpa  := .f.
	Local cDocMov := ""

	//-- Impede Marcação Registros Sem Liberação
	If	(cAliasTRB)->DUA_OK == cMarca

		If (cAliasTRB)->DUA_RECDEP == '2' .And. (cAliasTRB)->DUA_RECDEP <> '1'
			If !(IsInCallStack("TmsDUAIn"))
				Help("",1,"TMSA15201",,) //-- "Registro Bloqueado"
			EndIf	
			lLimpa := .t.
		ElseIf  (cAliasTRB)->DUA_RECDEP == '1' 	.And.; 	//-- Liberado Para Processamento
				(cAliasTRB)->DTYREC == 0 		.And.;  //-- Sem Contrato Carreteiro Principal Gerado Ainda
				Empty((cAliasTRB)->DUA_NUMCTC) 	.And.; 	//-- Sem Contr. Carreteiro Gerado
				(cAliasTRB)->DT2_TIPOCO $ '17/18/21'  	//-- 17=Despesa, 18=Receita/Despesa, 21=Trecho GFE ( Contrato Carreteiro )
			If !(IsInCallStack("TmsDUAIn"))
				Help("",1,"TMSA15204",,) //-- "Contrato Carreteiro Complementar Só Poderá Ser Gerado Quando Houver Contrato Principal Gerado! "
			EndIf	 

			//-- Limpa Marcação Caso Tipo Ocorrencia For Despesa Ou Valor Receita Igual a Zero
			If (cAliasTRB)->DT2_TIPOCO == '17' .Or. (cAliasTRB)->DUA_VLRRCT == 0
				lLimpa := .t.
			EndIf			
		ElseIf (cAliasTRB)->DUA_RECDEP == '3' .And. (cAliasTRB)->DUA_RECDEP <> '1'
			cDocMov := Iif( !Empty((cAliasTRB)->DUA_NUMCTE), (cAliasTRB)->DUA_NUMCTE + '/' + (cAliasTRB)->DUA_SERCTE, (cAliasTRB)->DUA_NUMCTC )
			If Aviso(	STR0019 ,; //-- Confirma Estorno ?
						STR0020 + cDocMov + STR0021 + (cAliasTRB)->DUA_VIAGEM ,; //-- Confirma Estorno Do Documento: ###### Relacionado a Viagem: ######
						{ STR0022 , STR0023 },; //-- Confirmar ; Cancelar
						1) == 2
				lLimpa := .t.
			EndIf						
		EndIf	

		If lLimpa 
			RecLock(cAliasTRB,.f.)
			(cAliasTRB)->DUA_OK := Space(Len((cAliasTRB)->DUA_OK))
			(cAliasTRB)->(MsUnlock())
		EndIf	
	EndIf

	RestArea(aArea)

	oMrkBrowse:oBrowse:Refresh()

	//-- Reposiciona No Registro
	(cAliasTRB)->(DbGoTo(nRec))

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDUAIn
Marcacao de vários registros
@author Totvs
@since Jan/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsDUAIn(cAliasTRB)

	Local nReg    := (cAliasTRB)->(Recno())
	Local cMarca  := oMrkBrowse:cMark
	Local cNewMk  := ""

	DbSelectArea(cAliasTRB)
	DbGoTop()
	While !(cAliasTRB)->(Eof())
		If (cAliasTRB)->DUA_RECDEP == '1'
			cNewMk := Iif(Empty((cAliasTRB)->DUA_OK),cMarca,Space(Len((cAliasTRB)->DUA_OK)))
			Exit
		EndIf
		(cAliasTRB)->(dbSkip())
	Enddo

	DbSelectArea(cAliasTRB)
	DbGoTop()
	While !(cAliasTRB)->(Eof())
		If (cAliasTRB)->(MsRLock())
			If (cAliasTRB)->DUA_RECDEP == '1'

				(cAliasTRB)->DUA_OK := cNewMk

				//-- Validação Da Linha
				If (cAliasTRB)->DUA_OK == cMarca
					TmsDUAMk(cAliasTRB)
				EndIf	
			EndIf
		Endif
		(cAliasTRB)->(dbSkip())
	Enddo
	
	oMrkBrowse:oBrowse:Refresh(.t.)

	(cAliasTRB)->(dbGoto(nReg))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}Tmsa152Leg
@descricao	: Legenda
@author Eduardo Alberti
@since  Jan/2017
@version 12
/*/
//-------------------------------------------------------------------
Function Tmsa152Leg()

	Local aLegenda  := {}
	Local cTitulo   := STR0011 //  "Legenda De Bloqueios"

	AADD(aLegenda,{"BR_BRANCO" 		, STR0033 })	//-- "Não utiliza"
	AADD(aLegenda,{"BR_VERDE"  		, STR0012 })	//-- "Liberado"
	AADD(aLegenda,{"BR_VERMELHO" 	, STR0013 })	//-- "Bloqueado"
	AADD(aLegenda,{"BR_AZUL"	 	, STR0015 })	//-- "Gerado Documento"
	AADD(aLegenda,{"BR_AMARELO" 	, STR0034 })	//-- "Pendente"
	
	BrwLegenda(cTitulo, STR0011 , aLegenda) //-- "Legenda De Bloqueios"

Return()

/*/{Protheus.doc} RetStatus
//Retorna status pendente
@author caio.y
@since 11/09/2017
@version undefined
@param cAliasMbw, characters, descricao
@type function
/*/
Static Function RetStatus(cAliasMbw)
Local cRet		:= ""

If (cAliasMbw)->DUA_RECDEP == '4'
	
	If Empty( (cAliasMbw)->DUA_NUMCTC )
		cRet	:= "BR_LARANJA"
	ElseIf Empty( (cAliasMbw)->DUA_NUMCTE )
		cRet	:= "BR_AMARELO"
	EndIf
Else
	cRet	:= "BR_BRANCO"
EndIf

Return cRet

/*/{Protheus.doc} LegStatus
LEgenda do status
@author caio.y
@since 11/09/2017
@version undefined

@type function
/*/
Static Function LegStatus()

Local aLegenda  := {}
Local cTitulo   := STR0039 //  "Status"

AADD(aLegenda,{"BR_BRANCO" 		, STR0040 })	//-- "Sem pendencias"      
AADD(aLegenda,{"BR_LARANJA"		, STR0035 + " / " + STR0037 })	//-- "CT-e gerado"  "CTC pendente"    
AADD(aLegenda,{"BR_AMARELO"		, STR0036 + " / " + STR0038 })	//-- "CTC gerado" "CT-e pendente"

BrwLegenda(cTitulo, STR0039 , aLegenda) //-- "Status"


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa152Ger
@descricao	: Executa A Geração De Documentos Conforme Parâmetros
@author Eduardo Alberti
@since  Jan/2017
@version 12
/*/
//-------------------------------------------------------------------
Function Tmsa152Ger( cOper, nRec )

	Local aArea   := { DT6->(GetArea()), DT8->(GetArea()), GetArea() }
	Local aCab    := {}
	Local aItens  := {}
	Local aNfs    := Nil
	Local lRet    := .f.
	Local nOpcAut := 0
	Local nOpcCar := 0
	Local nX      := 0
	Local nY      := 0
	Local cMarca  := ""
	Local cMotivo := ""
	Local aCabDTY := {}
	Local cCodFor := ""
	Local cLojFor := ""
	Local cCodFv  := ""
	Local cLojFv  := ""
	Local cFilDeb := ""
	Local aVetCTC := {}
	Local nPos    := 0
	//--Local nRec    := 0 Movido Para Default
	Local nPosMbw := 0
	Local cQuery  := ""
	Local nCodRet := 0
	Local cChave  := ""	
	Local aAreaAnt:= {}
		
	Private lMsErroAuto := .F. //-- Utilizada na funcao MsExecAuto()
	Private cNat152     := ""  //-- Utilizada no TMSA250
	Private cDes152     := ""  //-- Utilizada no TMSA250

	Default cOper       := "G" //-- Gerar
	Default nRec        := 0
	
	cMarca  := Iif( nRec == 0 , oMrkBrowse:cMark , "" )

	/*/-- Opções disponíveis - nOpcAut
	04-Devolução 
	05-Reentrega 
	06-Complemento
	07-Cancelamento 
	08-Aliança 
	09-Manut. Transp
	10-Compl.Impost 
	11-Armazenagem 
	12-Anulação 
	13-Substituição 
	14-Can.Anul
	/*/
	
	//-- Gera Temporário Pelo Recno Informado
	If nRec > 0
		cAliasMbw := (TmMapExcQr( nRec ))[1]
	EndIf

	DbSelectArea(cAliasMbw)
	(cAliasMbw)->( DbGoTop() )
	While !(cAliasMbw)->( Eof() )

		//-- Processa Somente Marcados
		If nRec > 0 .Or. oMrkBrowse:IsMark(cMarca)
		    
			//-- Controle Automático Do cOper
			If (cAliasMbw)->DUA_RECDEP == '3' //-- Gerado Documento
				cOper := 'E' //-- Estornar
			ElseIf (cAliasMbw)->DUA_RECDEP == '1' .Or. (cAliasMbw)->DUA_RECDEP == '4' //-- Liberado ou Pendente
				cOper := 'G' //-- Gerar
			ElseIf (cAliasMbw)->DUA_RECDEP == '2'
				(cAliasMbw)->( DbSkip() ) //-- Avança Cursor
				Loop
			EndIf 		
	
			If cOper == "G"
							
				If (cAliasMbw)->DT2_TIPOCO $ '16/18' 
					If Empty( (cAliasMbw)->(DUA_FLOCTE + DUA_NUMCTE + DUA_SERCTE)) .And. (cAliasMbw)->DUA_VLRRCT > 0
						nOpcAut := 06 //--  Complemento
					EndIf
					If (cAliasMbw)->DT2_TIPOCO = '18' .And. (cAliasMbw)->DUA_VLRDSP > 0 .And. Empty( (cAliasMbw)->DUA_NUMCTC )
						nOpcCar := 04 //--  Inclusão Contrato Carreteiro Complementar
					EndIf	
				ElseIf (cAliasMbw)->DT2_TIPOCO $ '19' //-- Reentrega
					nOpcAut := 05 //--  Reentrega
				ElseIf (cAliasMbw)->DT2_TIPOCO $ '20' //-- Devolucao
					nOpcAut := 04 //--  Devolução
				ElseIf (cAliasMbw)->DT2_TIPOCO $ '17/21' //-- 17=Despesa, 21=Trecho GFE ( Contrato Carreteiro )
					If (cAliasMbw)->DT2_TIPOCO = '17'
						nOpcCar := 04 //--  Inclusão Contrato Carreteiro Complementar
					ElseIf (cAliasMbw)->DT2_TIPOCO = '21'
						nOpcCar := 04 //--  Inclusão Contrato Carreteiro Complementar
					EndIf
				EndIf
			
			ElseIf cOper == "E"
			
				If (cAliasMbw)->DT2_TIPOCO $ '17/18/21' .And. !Empty((cAliasMbw)->(DUA_FLOCTC + DUA_NUMCTC)) 
					nOpcCar := 04 //-- Cancelamento CTC	
				ElseIf (cAliasMbw)->DT2_TIPOCO $ '16/18/19/20' .And. !Empty((cAliasMbw)->(DUA_FLOCTE + DUA_NUMCTE + DUA_SERCTE)) //-- .And. (cAliasMbw)->DUA_VLRRCT > 0
					nOpcAut := 07 //--  Cancelamento 
				EndIf
				
			EndIf
			
			//-- Posiciona No DT2
			DbSelectArea("DT2")
			DbSetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
			MsSeek( FWxFilial("DT2") + (cAliasMbw)->DUA_CODOCO , .f. )
			
			//------------------------------------------------------------------------------
			//-- Inclusão Complemento
			//------------------------------------------------------------------------------	
			If nOpcAut == 06 //-- Inclusão Doc. Complementar
		
				//-- Posiciona DT6
				If Select(cAliasMbw) > 0
					DbSelectArea("DT6")
					DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					DT6->(DbGoTo( (cAliasMbw)->DT6REC ))
				Else
					Return(.f.)
				EndIf
		
				//------------------------------------------------------------------------------
				//-- Geração Complemento
				//------------------------------------------------------------------------------		
				If cOper == "G" //-- Gerar
		
					//-- Montagem do Cabeçalho 
					aCab := {}
					AAdd( aCab, { "DT6_FILDOC" , DT6->DT6_FILDOC   , Nil } ) //-- Obrigatorio
					AAdd( aCab, { "DT6_DOC"    , DT6->DT6_DOC      , Nil } ) //-- Obrigatorio
					AAdd( aCab, { "DT6_SERIE"  , DT6->DT6_SERIE    , Nil } ) //-- Obrigatorio
		 
		   			//-- Posiciona Na Composição Do Frete 
					DbSelectArea("DT8")
					DT8->(DbSetOrder(2)) //-- DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
					DT8->(MsSeek(xFilial("DT8")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
		
					aAdd( aItens, {})
					//-- Se Não Houver No DT2, Pega Primeiro Componente Do DT8
					If !Empty(DT2->DT2_CDPASR)
						AAdd( aItens[Len(aItens)], { "DT8_CODPAS", DT2->DT2_CDPASR        , Nil } ) //-- Código do Componente: Obrigatório
					Else
						AAdd( aItens[Len(aItens)], { "DT8_CODPAS", DT8->DT8_CODPAS        , Nil } ) //-- Código do Componente: Obrigatório
					EndIf	
					AAdd( aItens[Len(aItens)], { "DT8_VALTOT", (cAliasMbw)->DUA_VLRRCT, Nil } ) //-- Valor do Componente: Obrigatório
		 
					//-- Montagem das Nfs
					//-- Apenas a opção de devolução e reentrega possuem esta opção e não é necessário seu envio
					//-- Chamada à MsExecAuto, os dois primeiros argumentos são de uso interno e serão ignorados, se passado algum conteúdo
					aAreaAnt:=GetArea()
					If FunName() == "TMSA152"
						//--MsgRun( STR0027, STR0009, {|| MsExecAuto({|a,b,c,d,e| TMSA500(a,b,c,d,e)},Nil,Nil,nOpcAut,aCab,aItens) })  //-- "Gerando Documento..." "Aguarde... "
						MsgRun( STR0027, STR0009, {|| MsExecAuto({|a,b,c,d,e,f| TMSA500(a,b,c,d,e,f)},Nil,Nil,nOpcAut,aCab,aItens,aNfs) })  //-- "Gerando Documento..." "Aguarde... "
					Else
						MsExecAuto({|a,b,c,d,e| TMSA500(a,b,c,d,e)},Nil,Nil,nOpcAut,aCab,aItens)
					EndIf
					RestArea(aAreaAnt)
						
					If lMsErroAuto
						lRet := .f.
						MostraErro()
					Else
						If Select(cAliasMbw) > 0
							//-- Transfere Campo Memo Para Tabela DT6
							If DT2->DT2_MOTDT6 == '1' .And. !Empty((cAliasMbw)->DUA_CODMOT)
							
								cMotivo := MsMM((cAliasMbw)->DUA_CODMOT, 80 )
								
								If !Empty(cMotivo)
									//-- Grava Campo Memo No DT6
									RecLock("DT6",.F.)
									MSMM(DT6->DT6_CODOBS,,,cMotivo,1,,,'DT6','DT6_CODOBS')
									DT6->(MsUnlock())
								EndIf						
							EndIf

							//-- Atualiza Tabela De Ocorrencias DUA
							DbSelectArea("DUA")
							DUA->(DbGoTo((cAliasMbw)->DUAREC))
							
							RecLock("DUA",.f.)
							
							If nOpcCar == 4 
								DUA->DUA_RECDEP	:= '4'	//-- Pendente
							Else
								DUA->DUA_RECDEP := '3' 	//-- Gerado Documento
							EndIf
							
							DUA->DUA_FLOCTE := DT6->DT6_FILDOC
							DUA->DUA_NUMCTE := DT6->DT6_DOC
							DUA->DUA_SERCTE := DT6->DT6_SERIE
							
							DUA->(MsUnlock())
			
							lRet := .t.
			
							//-- Atualiza Browse
							If nRec == 0
								
								RecLock(cAliasMbw, .f. )
								
								If nOpcCar == 4 
									(cAliasMbw)->DUA_RECDEP := '4' //-- Pendente
								Else	
									(cAliasMbw)->DUA_RECDEP := '3' //-- Gerado Documento
								EndIf
								
								(cAliasMbw)->DUA_OK     := Space(Len((cAliasMbw)->DUA_OK))
								(cAliasMbw)->DUA_FLOCTE := DT6->DT6_FILDOC
								(cAliasMbw)->DUA_NUMCTE := DT6->DT6_DOC
								(cAliasMbw)->DUA_SERCTE := DT6->DT6_SERIE
								
								(cAliasMbw)->(MsUnlock())
												
								//-- Executa Refresh No Browse
								oMrkBrowse:oBrowse:Refresh(.t.)
							EndIf
						Else
							Exit
						EndIf	
					EndIf
				EndIf
			EndIf
			//------------------------------------------------------------------------------
			//-- Inclusão Reentrega
			//------------------------------------------------------------------------------	
			If nOpcAut == 05 .Or. nOpcAut == 04 //-- 05->Inclusão Reentrega; 04->Devolução
		
				//-- Posiciona DT6
				If Select(cAliasMbw) > 0
					DbSelectArea("DT6")
					DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					DT6->(DbGoTo( (cAliasMbw)->DT6REC ))
				Else
					Return(.f.)
				EndIf
		
				//------------------------------------------------------------------------------
				//-- Geração Reentrega
				//------------------------------------------------------------------------------		
				If cOper == "G" //-- Gerar
		
					//-- Montagem do Cabeçalho 
					aCab := {}
					AAdd( aCab, { "DT6_FILDOC" , DT6->DT6_FILDOC   , Nil } ) //-- Obrigatorio
					AAdd( aCab, { "DT6_DOC"    , DT6->DT6_DOC      , Nil } ) //-- Obrigatorio
					AAdd( aCab, { "DT6_SERIE"  , DT6->DT6_SERIE    , Nil } ) //-- Obrigatorio
		 
		   			//-- Posiciona Na Composição Do Frete 
					DbSelectArea("DT8")
					DT8->(DbSetOrder(2)) //-- DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
					DT8->(MsSeek(xFilial("DT8")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
		
					//-- Inclui Vetor De Itens Vazio
					aAdd( aItens, {})
					
					//-- Se Houver Valor Informado Inclui
					If (cAliasMbw)->DUA_VLRRCT > 0 
						AAdd( aItens[Len(aItens)], { "NVLRDOC", (cAliasMbw)->DUA_VLRRCT, Nil } ) //-- Valor do Componente: Obrigatório
					EndIf
		 
					//-- Montagem das Nfs
					//-- Apenas a opção de devolução e reentrega possuem esta opção e seu envio é opcional
					DbSelectArea("DV4")
					DV4->(DbSetOrder(1)) //-- DV4_FILIAL+DV4_FILOCO+DV4_NUMOCO+DV4_FILDOC+DV4_DOC+DV4_SERIE+DV4_NUMNFC+DV4_SERNFC
					If DV4->(DbSeek(xFilial("DV4")+(cAliasMbw)->(DUA_FILOCO+DUA_NUMOCO)+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))

						aNfs := {}
						Do While DV4->(!Eof()) .And. DV4->(DV4_FILIAL+DV4_FILOCO+DV4_NUMOCO+DV4_FILDOC+DV4_DOC+DV4_SERIE) == xFilial("DV4")+(cAliasMbw)->(DUA_FILOCO+DUA_NUMOCO)+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)
							
							//-- Caso o MV_PRDDIV permita produtos divergentes para a mesma NF, tem-se que selecionar a reentrega/devolução de toda a NF.
							//-- Como a DV4 não possui o produto, percorre-se todos os registros da DTC da NF - ou seja, todos os produtos. 
							DbSelectArea("DTC")
							DTC->(DbSetOrder(5)) //-- DTC_FILIAL+DTC_CLIREM+DTC_LOJREM+DTC_NUMNFC+DTC_SERNFC
							DTC->(DbSeek(xFilial("DTC") + DT6->(DT6_CLIREM+DT6_LOJREM) + DV4->(DV4_NUMNFC+DV4_SERNFC)))

							Do While DTC->(!Eof()) .And. DTC->(DTC_FILIAL+DTC_CLIREM+DTC_LOJREM+DTC_NUMNFC+DTC_SERNFC) == xFilial("DTC") + DT6->(DT6_CLIREM+DT6_LOJREM) + DV4->(DV4_NUMNFC+DV4_SERNFC)

								aAdd( aNfs, {})
								AAdd( aTail(aNfs), { "DTC_NUMNFC" , DTC->DTC_NUMNFC	, Nil } ) //-- Obrigatorio, quando selecionado por NF (3º pergunte do F12 do TMSA500)
								AAdd( aTail(aNfs), { "DTC_SERNFC" , DTC->DTC_SERNFC	, Nil } ) //-- Obrigatorio, quando selecionado por NF (3º pergunte do F12 do TMSA500)
								AAdd( aTail(aNfs), { "DTC_CLIREM" , DTC->DTC_CLIREM	, Nil } ) //-- Obrigatorio, quando selecionado por NF (3º pergunte do F12 do TMSA500)
								AAdd( aTail(aNfs), { "DTC_LOJREM" , DTC->DTC_LOJREM	, Nil } ) //-- Obrigatorio, quando selecionado por NF (3º pergunte do F12 do TMSA500)
								AAdd( aTail(aNfs), { "DTC_CODPRO" , DTC->DTC_CODPRO	, Nil } ) //-- Obrigatorio, quando selecionado por NF (3º pergunte do F12 do TMSA500)
								AAdd( aTail(aNfs), { "DTC_FILORI" , DTC->DTC_FILORI	, Nil } ) //-- Obrigatorio, quando selecionado por NF (3º pergunte do F12 do TMSA500)
								AAdd( aTail(aNfs), { "DTC_LOTNFC" , DTC->DTC_LOTNFC	, Nil } ) //-- Obrigatorio, quando selecionado por NF (3º pergunte do F12 do TMSA500)

								DTC->(DbSkip())
							EndDo

							DV4->(DbSkip())
						EndDo
					EndIf
					
					aAreaAnt:= GetArea()
					lMsErroAuto := .F. //-- Utilizada na funcao MsExecAuto()
					//-- Chamada à MsExecAuto, os dois primeiros argumentos são de uso interno e serão ignorados, se passado algum conteúdo
					If FunName() == "TMSA152"
						MsgRun( STR0027, STR0009, {|| MsExecAuto({|a,b,c,d,e,f| TMSA500(a,b,c,d,e,f)},Nil,Nil,nOpcAut,aCab,aItens,aNfs) })  //-- "Gerando Documento..." "Aguarde... "
					Else
						MsExecAuto({|a,b,c,d,e,f| TMSA500(a,b,c,d,e,f)},Nil,Nil,nOpcAut,aCab,aItens,aNfs)
					EndIf	
					RestArea(aAreaAnt)

					If lMsErroAuto
						lRet := .f.
						MostraErro()
					Else
						If Select(cAliasMbw) > 0
							//-- Transfere Campo Memo Para Tabela DT6
							If DT2->DT2_MOTDT6 == '1' .And. !Empty((cAliasMbw)->DUA_CODMOT)
							
								cMotivo := MsMM((cAliasMbw)->DUA_CODMOT, 80 )
								
								If !Empty(cMotivo)
									//-- Grava Campo Memo No DT6
									RecLock("DT6",.F.)
									MSMM(DT6->DT6_CODOBS,,,cMotivo,1,,,'DT6','DT6_CODOBS')
									DT6->(MsUnlock())
								EndIf						
							EndIf

							//-- Atualiza Tabela De Ocorrencias DUA
							DbSelectArea("DUA")
							DUA->(DbGoTo((cAliasMbw)->DUAREC))
							
							RecLock("DUA",.f.)
							
							DUA->DUA_RECDEP := '3' //-- Gerado Documento
							DUA->DUA_FLOCTE := DT6->DT6_FILDOC
							DUA->DUA_NUMCTE := DT6->DT6_DOC
							DUA->DUA_SERCTE := DT6->DT6_SERIE
							
							DUA->(MsUnlock())
			
							lRet := .t.
			
							//-- Atualiza Browse
							If nRec == 0
								
								RecLock(cAliasMbw, .f. )
								
								(cAliasMbw)->DUA_RECDEP := '3' //-- Gerado Documento
								(cAliasMbw)->DUA_OK     := Space(Len((cAliasMbw)->DUA_OK))
								(cAliasMbw)->DUA_FLOCTE := DT6->DT6_FILDOC
								(cAliasMbw)->DUA_NUMCTE := DT6->DT6_DOC
								(cAliasMbw)->DUA_SERCTE := DT6->DT6_SERIE
								
								(cAliasMbw)->(MsUnlock())
												
								//-- Executa Refresh No Browse
								oMrkBrowse:oBrowse:Refresh(.t.)
							EndIf
						Else
							Exit
						EndIf	
					EndIf
				EndIf

			//------------------------------------------------------------------------------
			//-- Estorno Do Complemento,Reentrega, etc... 
			//------------------------------------------------------------------------------
			ElseIf nOpcAut == 07

				If Select(cAliasMbw) > 0

					//-- Posiciona No Doc. Que Será Estornado
					DbSelectArea("DT6")
					DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					MsSeek( FWxFilial("DT6") + (cAliasMbw)->DUA_FLOCTE + (cAliasMbw)->DUA_NUMCTE + (cAliasMbw)->DUA_SERCTE , .f. )
						
				Else
					Return(.f.)
				EndIf
			
				If cOper == "E" //-- Estornar
				
					//-- Montagem do Cabeçalho 
					aCab := {}
					AAdd( aCab, { "DT6_FILDOC" , DT6->DT6_FILDOC   , Nil } ) //-- Obrigatorio
					AAdd( aCab, { "DT6_DOC"    , DT6->DT6_DOC      , Nil } ) //-- Obrigatorio
					AAdd( aCab, { "DT6_SERIE"  , DT6->DT6_SERIE    , Nil } ) //-- Obrigatorio
						 
					//-- Montagem dos Itens
					//-- Não há itens para a opção de cancelamento.
					aItens := {}
					aAdd( aItens, {})
						 
					//-- Montagem das Nfs
					//-- Apenas a opção de devolução e reentrega possuem esta opção e não é necessário seu envio
					//-- Chamada à MsExecAuto, os dois primeiros argumentos são de uso interno e serão ignorados, se passado algum conteúdo
					aAreaAnt:= GetArea
					If FunName() == "TMSA152"
						//--MsgRun( STR0028, STR0009, {|| MsExecAuto({|a,b,c,d,e| TMSA500(a,b,c,d,e)},Nil,Nil,nOpcAut,aCab,aItens) })  //-- "Excluindo Documento..." "Aguarde... "
						MsgRun( STR0028, STR0009, {|| MsExecAuto({|a,b,c,d,e,f| TMSA500(a,b,c,d,e,f)},Nil,Nil,nOpcAut,aCab,aItens,aNfs) })
					Else
						MsExecAuto({|a,b,c,d,e| TMSA500(a,b,c,d,e)},Nil,Nil,nOpcAut,aCab,aItens)
					EndIf
					RestArea(aAreaAnt)
						
					If lMsErroAuto
						MostraErro()
						lRet := .f.
					Else
						If Select(cAliasMbw) > 0
							//-- Atualiza Tabela De Ocorrencias DUA
							DbSelectArea("DUA")
							DUA->(DbGoTo((cAliasMbw)->DUAREC))
							RecLock("DUA",.f.)
							DUA->DUA_RECDEP := '1' //-- Liberado
							DUA->DUA_FLOCTE := Space(Len(DT6->DT6_FILDOC))
							DUA->DUA_NUMCTE := Space(Len(DT6->DT6_DOC))
							DUA->DUA_SERCTE := Space(Len(DT6->DT6_SERIE))

							DUA->(MsUnlock())
				
							lRet := .t.
				
							If nRec == 0
								//-- Atualiza Browse
								RecLock(cAliasMbw, .f. )
								(cAliasMbw)->DUA_RECDEP := '1' //-- Liberado
								(cAliasMbw)->DUA_OK     := Space(Len((cAliasMbw)->DUA_OK))
								(cAliasMbw)->DUA_FLOCTE := Space(Len(DT6->DT6_FILDOC))
								(cAliasMbw)->DUA_NUMCTE := Space(Len(DT6->DT6_DOC))
								(cAliasMbw)->DUA_SERCTE := Space(Len(DT6->DT6_SERIE))
								(cAliasMbw)->(MsUnlock())
						
								//-- Executa Refresh No Browse
								oMrkBrowse:oBrowse:Refresh(.t.)
							EndIf
						Else
							Exit
						EndIf
					EndIf
				EndIf
			EndIf

			//------------------------------------------------------------------------------
			//-- Bloco Para Inclusão De Contrato Complementar De Carreteiro ( Qdo Existe Contrato Principal ) 
			//------------------------------------------------------------------------------
			If cOper == "G" .And. nOpcCar == 04 
			
				//------------------------------------------------------------------------------
				//-- Se Houver Contrato Carreteiro Principal, Gera Contrato Complementar.
				//-- Se Não Houver Contrato Carreteiro Principal, Aguarda Gerar o Contrato 
				//-- Principal No TMSA250 Para Em Seguida Gerar Os Contratos Complementares  
				//------------------------------------------------------------------------------
				
				//-- Contrato Carreteiro
				DbSelectArea("DTY")
				DbSetOrder(2) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
				If MsSeek( FWxFilial("DTY") + (cAliasMbw)->DUA_FILORI + (cAliasMbw)->DUA_VIAGEM , .F. )
				
					//-- Posiciona Na Ocorrência
					DbSelectArea("DUA")
					DUA->(DbGoTo((cAliasMbw)->DUAREC))
					
					//-- Verifica Fornecedor / Favorecido
					If !Empty(DUA->DUA_CODFOR)
					
						//-- Cad. Fornecedores
						DbSelectArea("SA2")
						DbSetOrder(1) //-- Filial + Codigo
						If MsSeek( FWxFilial("SA2") + DUA->DUA_CODFOR + DUA->DUA_LOJFOR , .F. )
							cCodFor:= SA2->A2_COD
							cLojFor:= SA2->A2_LOJA
							cCodFv := Iif( !Empty( SA2->A2_CODFAV ), SA2->A2_CODFAV, SA2->A2_COD  )
							cLojFv := Iif( !Empty( SA2->A2_LOJFAV ), SA2->A2_LOJFAV, SA2->A2_LOJA )
							cFilDeb:= Iif( !Empty( SA2->A2_FILDEB ), SA2->A2_FILDEB, TMSA250FilDeb(cCodFor,cLojFor,Nil,Nil,.f.,DTY->DTY_FILORI,DTY->DTY_VIAGEM,.f.,Nil)      )
						EndIf
					EndIf
					
					If Empty(cCodFor)
						cCodFor:= DTY->DTY_CODFOR
						cLojFor:= DTY->DTY_LOJFOR 
						cCodFv := DTY->DTY_CODFOR
						cLojFv := DTY->DTY_LOJFOR 
						cFilDeb:= TMSA250FilDeb(cCodFor,cLojFor,Nil,Nil,.f.,DTY->DTY_FILORI,DTY->DTY_VIAGEM,.f.,Nil)
					EndIf
					
					nPos := aScan( aVetCTC, { |e| e[1]+e[2]+e[3]+e[4]+e[5] == (cAliasMbw)->DUA_FILORI+(cAliasMbw)->DUA_VIAGEM+(cAliasMbw)->DUA_CODOCO+cCodFor+cLojFor })
					
					//-- Aglutina Valores No Vetor
					If nPos == 0
						aAdd( aVetCTC , { 	(cAliasMbw)->DUA_FILORI,;	//-- 01
											(cAliasMbw)->DUA_VIAGEM,;	//-- 02
											(cAliasMbw)->DUA_CODOCO,;	//-- 03
											cCodFor,;					//-- 04
											cLojFor,;					//-- 05
											cCodFv,;					//-- 06
											cLojFv,;					//-- 07
											cFilDeb,;					//-- 08
											(cAliasMbw)->DUA_VLRDSP,;	//-- 09
											{(cAliasMbw)->DUAREC},;	     //-- 10
											DTY->(Recno()),;              //-- 11
											(cAliasMbw)->DT6_FILDOC,;     //-- 12
											(cAliasMbw)->DT6_DOC,;        //-- 13
											(cAliasMbw)->DT6_SERIE })     //-- 14
											
					Else
						aVetCTC[nPos,09] += (cAliasMbw)->DUA_VLRDSP		//-- Acumula Valores
						aAdd( aVetCTC[nPos,10] , (cAliasMbw)->DUAREC )	//-- Adiciona Recno Do DUA Que Foi Processado				
					EndIf					
				EndIf

			//------------------------------------------------------------------------------
			//-- Bloco Para Estorno/Exclusão De Contrato Complementar De Carreteiro 
			//------------------------------------------------------------------------------
			ElseIf cOper == "E" .And. nOpcCar == 04 
			
				//-- Posiciona No Contrato Carreteiro Complementar
				DbSelectArea("DTY")
				DbSetOrder(1) //-- DTY_FILIAL+DTY_NUMCTC
				If MsSeek( FWxFilial("DTY") + (cAliasMbw)->DUA_NUMCTC ,.F.)
				
					//-- Inicializa Controle Transacional
					Begin Transaction
					
						//-- Executa Rotina De Exclusão Do Contrato Complementar De Carreteiro 
						aAreaAnt:= GetArea
						If FunName() == "TMSA152"
							MsgRun( STR0030, STR0009, {|| lRet := TMSA250Mnt( "DTY" , DTY->(Recno()) , 5 , {} ,  .T. , {} ) })  //-- "Excluindo Contrato..." "Aguarde..."
						Else
							lRet := TMSA250Mnt( "DTY" , DTY->(Recno()) , 5 , {} ,  .T. , {} )
						EndIf	 
						RestArea(aAreaAnt)
		
						If lRet
		
							//-- Atualiza Tabela De Ocorrencias DUA
							cQuery := ""
							cQuery += " UPDATE	" + RetSqlName("DUA") + " "
							cQuery += " SET		DUA_RECDEP =  '1', " //-- Liberado
							cQuery += "         DUA_FLOCTC =  '" + Space(Len(DTY->DTY_FILORI)) + "', "
							cQuery += "         DUA_NUMCTC =  '" + Space(Len(DTY->DTY_NUMCTC)) + "'  "
							cQuery += " WHERE   DUA_FILIAL =  '" + FWxFilial("DUA")            + "'  "
							cQuery += " AND		DUA_FLOCTC =  '" + (cAliasMbw)->DUA_FLOCTC     + "'  "
							cQuery += " AND		DUA_NUMCTC =  '" + (cAliasMbw)->DUA_NUMCTC     + "'  "
							cQuery += " AND		D_E_L_E_T_ =  ' ' "
	
							//-- Executa Script
							nCodRet:= TcSqlExec(cQuery)
	
							//-- Inclui Log De Erro
							If nCodRet < 0
								DisarmTransaction()
								lRet  := .f.
								Help( ,, ProcName(),, TcSqlError() , 1, 0)
							Else
								
								//-- Atualiza Browse
								If nRec == 0
									
									//-- Captura Posicionamento Do Browse
									nPosMbw := (cAliasMbw)->(Recno())
									cChave  := (cAliasMbw)->DUA_FLOCTC + (cAliasMbw)->DUA_NUMCTC
									
									(cAliasMbw)->(DbGoTop())
									While (cAliasMbw)->(!Eof())
									
										If cChave == (cAliasMbw)->DUA_FLOCTC + (cAliasMbw)->DUA_NUMCTC 
									
											RecLock(cAliasMbw, .f. )
											(cAliasMbw)->DUA_RECDEP := '1' //-- Liberado
											(cAliasMbw)->DUA_OK     := Space(Len((cAliasMbw)->DUA_OK))
											(cAliasMbw)->DUA_FLOCTC := Space(Len(DTY->DTY_FILORI))
											(cAliasMbw)->DUA_NUMCTC := Space(Len(DTY->DTY_NUMCTC))
											(cAliasMbw)->(MsUnlock())
											
										EndIf
										(cAliasMbw)->(DbSkip())
									EndDo
									
									//-- Reposiciona O Browse
									(cAliasMbw)->(DbGoTo(nPosMbw))									
													
									//-- Executa Refresh No Browse
									oMrkBrowse:oBrowse:Refresh(.t.)
								EndIf
							EndIf					
						EndIf
					
					//-- Finaliza Controle Transacional
					End Transaction
				EndIf
			EndIf
		EndIf
		
		//-- Avança Cursor
		(cAliasMbw)->( DbSkip() ) 
	EndDo
	
	//------------------------------------------------------------------------------
	//-- Processa Contratos De Carreteiro Aglutinados
	//------------------------------------------------------------------------------
	For nX := 1 To Len(aVetCTC)
	
		//-- Posiciona No Contrato Carreteiro Principal
		DbSelectArea("DTY")
		DbGoTo(aVetCTC[nX,11])

		//-- Carrega Variáveis De Cód. Despesa e Natureza 
		DbSelectArea("DT2")
		DbsetOrder(1) //-- DT2_FILIAL+DT2_CODOCO
		MsSeek( FWxFilial("DT2") + aVetCTC[nX,03] , .F. )
		
		//-- Carrega Variáveis Conforme DT2
		cDes152 := DT2->DT2_CODDES
		cNat152 := DT2->DT2_CODNAT

		aCabDTY := {}
		
		Aadd( aCabDTY , { "DTY_TIPCTC" , "5"                            , Nil}) //-- Complemento
		Aadd( aCabDTY , { "DTY_CODFOR" , aVetCTC[nX,04]                 , Nil})
		Aadd( aCabDTY , { "DTY_LOJFOR" , aVetCTC[nX,05]                 , Nil})
		Aadd( aCabDTY , { "DTY_DATCTC" , dDataBase                      , Nil})
		Aadd( aCabDTY , { "DTY_HORCTC" , StrTran(Left(Time(),5),':','') , Nil})
		Aadd( aCabDTY , { "DTY_CODFAV" , aVetCTC[nX,06]                 , Nil})
		Aadd( aCabDTY , { "DTY_LOJFAV" , aVetCTC[nX,07]                 , Nil})
		Aadd( aCabDTY , { "DTY_FILDEB" , aVetCTC[nX,08]                 , Nil})
		Aadd( aCabDTY , { "DTY_STATUS" , "1"                            , Nil})
		Aadd( aCabDTY , { "DTY_VALFRE" , aVetCTC[nX,09]                 , Nil})

		//-- Executa Geração Do Contrato Carreteiro
		If FunName() == "TMSA152"
			MsgRun( STR0029, STR0009, {|| lRet := TMSA250Com( "DTY" , DTY->(Recno()) , 4 , {} ,  .T. , aCabDTY,aVetCTC[nX][12],aVetCTC[nX][13],aVetCTC[nX][14] ) }) //-- "Gerando Contrato..."
		Else
			lRet := TMSA250Com( "DTY" , DTY->(Recno()) , 4 , {} ,  .T. , aCabDTY, aVetCTC[nX][12],aVetCTC[nX][13],aVetCTC[nX][14]  )
		EndIf	
		
		If lRet

			//-- Atualiza Tabela De Ocorrencias DUA
			For nY := 1 To Len(aVetCTC[nX,10])
			
				//-- Posiciona Na Ocorrencia 
				DbSelectArea("DUA")
				DUA->(DbGoTo(aVetCTC[nX,10,nY]))
			
				//-- Atualilza Status e Numero Do Contrato
				RecLock("DUA",.F.)
				If nOpcAut == 6 .And. Empty( DUA->DUA_NUMCTE )
					DUA->DUA_RECDEP := '4' //-- Pendente
				Else
					DUA->DUA_RECDEP := '3' //-- Gerado Documento
				EndIf
				DUA->DUA_FLOCTC := DTY->DTY_FILORI
				DUA->DUA_NUMCTC := DTY->DTY_NUMCTC
				DUA->(MsUnlock())
				
			Next nY	

			//-- Atualiza Browse
			If nRec == 0
			
				//-- Captura Posicionamento Do Browse
				nPosMbw := (cAliasMbw)->(Recno())
				
				(cAliasMbw)->(DbGoTop())
				While (cAliasMbw)->(!Eof())
				
					If aScan( aVetCTC[nX,10], (cAliasMbw)->DUAREC ) > 0
				
						RecLock(cAliasMbw, .f. )
						(cAliasMbw)->DUA_RECDEP := '3' //-- Gerado Documento
						(cAliasMbw)->DUA_OK     := Space(Len((cAliasMbw)->DUA_OK))
						(cAliasMbw)->DUA_FLOCTC := DTY->DTY_FILORI
						(cAliasMbw)->DUA_NUMCTC := DTY->DTY_NUMCTC
						(cAliasMbw)->(MsUnlock())
						
					EndIf
					(cAliasMbw)->(DbSkip())
				EndDo
				
				//-- Reposiciona O Browse
				(cAliasMbw)->(DbGoTo(nPosMbw))		
								
				//-- Executa Refresh No Browse
				oMrkBrowse:oBrowse:Refresh(.t.)
			EndIf				
		EndIf
		
	Next nX	

	//-- Exclui Somente Quando Recno Informado
	If nRec > 0
		//-- Exclui Arquivo Temporário Do Banco De Dados
		//--oTabBrw:Delete()
	EndIf
	
	//-- Reposiciona Arquivos
	For nX := 1 To Len(aArea)
		RestArea(aArea[nX])
	Next nX

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa152Vis
@descricao	: Visualização De Documentos 
@author Eduardo Alberti
@since  Jan/2017
@version 12
/*/
//-------------------------------------------------------------------
Function Tmsa152Vis(cOper) //-- 'P' = Doc Principal, 'A' = Doc. Auxiliar

	Local aArea := { DT6->(GetArea()), GetArea() }
	Local nX    := 0
	
	cCadastro   := STR0024 //--"Manutencao de Documentos - Visualizar"
	
	Default cOper := "P"
	
	//-- Verifica Se Tabela Temporária Existe
	If !Empty(cAliasMbw)

		//-- Salva Propriedades De Telas Abertas
		SaveInter()
		
		//-- Verifica Se é Doc. Principal Ou Auxiliar
		If cOper == "P"
		
			DbSelectArea("DT6")
			DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			If MsSeek( FWxFilial("DT6") + (cAliasMbw)->DT6_FILDOC + (cAliasMbw)->DT6_DOC + (cAliasMbw)->DT6_SERIE, .F. )  
				TMSA500Mnt("DT6",DT6->(Recno()),2)
			EndIf

		ElseIf cOper == "A"
			
			DbSelectArea("DT6")
			DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			If MsSeek( FWxFilial("DT6") + (cAliasMbw)->DUA_FLOCTE + (cAliasMbw)->DUA_NUMCTE + (cAliasMbw)->DUA_SERCTE, .F. )  
				TMSA500Mnt("DT6",DT6->(Recno()),2)
			EndIf		
		
		ElseIf cOper == "L" //-- "Vis.CTC.Princ"
		
			If (cAliasMbw)->DTYREC > 0

				DbSelectArea("DTY")
				DTY->(DbGoTo((cAliasMbw)->DTYREC))
				
				FWExecView('','TMSA250', MODEL_OPERATION_VIEW, , /*{ || .T. }*/, , ,/*aButtons*/ )
			
			Else
				Help("",1,"TMSA15205",,) //-- "Ainda Não Existe Contrato Carreteiro Principal Gerado Para a Viagem!"
			EndIf		
		
		ElseIf cOper == "M" //-- "Vis.CTC.Aux."
		
			If !Empty((cAliasMbw)->DUA_NUMCTC)

				DbSelectArea("DTY")
				DbSetOrder(2) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
				If MsSeek( FWxFilial("DTY") + (cAliasMbw)->DUA_FILORI + (cAliasMbw)->DUA_VIAGEM + (cAliasMbw)->DUA_NUMCTC , .f. )
					FWExecView('','TMSA250', MODEL_OPERATION_VIEW, , /*{ || .T. }*/, , ,/*aButtons*/ )		
				Else
					Help(" ",1,"REGNOIS") //Nao existe registro relacionado a este codigo.
				EndIf
			Else
				Help("",1,"TMSA15206",,) //-- "Ainda Não Foi Gerado Contrato Adicional Para Esta Viagem!"
			EndIf	
		EndIf
		
		RestInter()
	
	EndIf

	//-- Reposiciona Arquivos
	For nX := 1 To Len(aArea)
		RestArea(aArea[nX])
	Next nX

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} TmsRecDp
                  Consulta Padronizada De Tipos De Receita/Despesa
@author           Eduardo Alberti
@since            Feb/2017
@version          12
/*/
//-------------------------------------------------------------------
Function TmsRecDp()

	Local aArea   := GetArea()
	Local aRet    := {}
	Local nI      := 0
	Local cTitulo := "Consulta Ocorrências"

	aRet := TmsValField("DT2->DT2_TIPOCO",.f.,Nil,Nil,.t. )

	//-- Varre Vetor aRet
	For nI := 1 To Len(aRet)
	
		If nI > Len(aRet)
			Exit
		EndIf			

		//-- Localiza Códigos De Receita/Despesa
		If aScan( aRecDep , aRet[nI,1] ) == 0
		
			//-- Elimina Códigos Que Não São Receita/Despesa
			aDel( aRet , nI )
			aSize( aRet,Len(aRet)-1)
			nI --
		EndIf
	Next nI
	
	nTmsItem := TmsF3Array( {"Codigo","Descricao"}, aRet, cTitulo ) //"Codigo"###"Descricao"
	
	If	nTmsItem > 0
		VAR_IXB := aRet[ nTmsItem, 1 ]
	Else
		VAR_IXB := Space(2)
	EndIf

	RestArea(aArea)

Return(.T.)
//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa152Use
                  
@author           Eduardo Alberti
@since            Mar/2017
@version          12
/*/
//-------------------------------------------------------------------
Function Tmsa152Use()

	Local lRet    := .f.

	//-- Se Não Houver TMSA152 Na Pilha Libera Processamento
	If IsInCallStack("TMSA152") .Or. IsInCallStack("Tmsa152Ger")
		lRet := .t.
	EndIf	

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ParamBrw
@autor		: Guilherme Eduardo Bittencourt
@descricao	: Tela de parâmetros do browse
@since		: Mar./2017
@using		: 
@review     :
/*/
//-------------------------------------------------------------------------------------------------
Static Function ParamBrw(cAliasMbw)
	
	Local cPerg  := "TMSA152"
	Local aAlias := {}
	Local lRet   := .F.

	If Pergunte(cPerg ,.T.)

		//-- Exclui Arquivo Temporário Do Banco De Dados
		If ValType(oTabBrw) <> 'U'
			oTabBrw:Delete()
		EndIf
		
		aAlias      := TmMapExcQr()
		cAliasMbw   := aAlias[1]
		lRet        := .T.
	EndIf

Return lRet
