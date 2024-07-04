#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TMSA155.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA155()
Tela de Recursos
@author  Gustavo Krug
@since   08/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TMSA155(cCampF3)
Local   aCoors  := FWGetDialogSize( oMainWnd )
Private oFWLayer := nil
Private oBrwUpL, oBrwUpR, oBrwMidL, oBrwMidR, oBrwDownL, oBrwDownR := nil
Private oDlgPrinc := nil
Private aRegBrw := {{'', .F.}, {'', .F.}, {'', .F.}, {'', .F.}, {'', .F.}, {'', .F.}}
Private aShowBrw := {.F., .F. , .F.}
Private oTimer := nil
Private cRetF3Esp := ''
Private cFilMV := ""
Private cVeiMV := ""
Private cPlaMV := ""
Private nFltMV := 3

Default cCampF3 := ''

	If !(DA3->(ColumnPos("DA3_HORSTS")) > 0) .AND. !AliasInDic("DL9") //SUAVIZAÇÃO DEMANDAS
		Help( ,, 'HELP',, STR0012, 1, 0 ) //Para acessar esta rotina é necessário atualizar o dicionário de dados com o pacote Gestão de Demandas.
		Return .F.
	EndIf
	
	//1. Inicializa variáveis e cria somente o dialog 
	Iif(Type('cTM154Ret') != 'U', cTM154Ret := '',)
			
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel 
			
	SetKey(VK_F5,{ ||TMA155Filt(cCampF3, .T.)})
	
	If Empty(cCampF3) //Se for via tela menu, ativa o timer. Se for via F3 de campos, não deve ativar
		SetKey(VK_F12,{ ||TMA155Par(.T.)} )
		TMA155Par(.F.)    	
	EndIf

	//2. Abre o pergunte e cria os componentes para exibição das informações (layer, painéis e grids)
	TMA155Filt(cCampF3, Empty(cCampF3)) 
	
	Activate MsDialog oDlgPrinc Center
	
	T155FrBrw(.F.)	

	aSize(aRegBrw, 0)
	aSize(aShowBrw, 0)

	//3. ajusta o F5 de acordo com a origem da chamada do monitor
	SetKey(VK_F5, Iif (!Empty(cCampF3) .AND. FwIsInCallStack("TMSA155"), { ||TMA153Par(.F.)}, Nil))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} T155Column()
Cria colunas a serem exibidas no browse
@author  Gustavo Krug
@since   08/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T155Column(cBrw)
Local aColumns   := {}
Local cArea      := 'DA3TMP' + cBrw
Local lLGPD      := FindFunction('FWPDCanUse') .And. FWPDCanUse(.T.) .And. FindFunction('TMLGPDCpPr')
Local lOfuscated := .F.
Local cNome      := ""

    If "DA3TMP1" $ cArea .OR. "DA3TMP3" $ cArea .OR. "DA3TMP5" $ cArea //Veículos Disponíveis
        
        //Filial Atual
        AAdd(aColumns,FWBrwColumn():New())  
        aColumns[Len(aColumns)]:SetData( {||(cArea)->DA3_FILATU} ) // Dado que irá popular o campo
        aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DA3_FILATU','X3_TITULO')) // Título da coluna 

    ElseIf "DA3TMP2" $ cArea .OR. "DA3TMP4" $ cArea .OR. "DA3TMP6" $ cArea //Veículos em Trânsito

        //Filial Prevista
        AAdd(aColumns,FWBrwColumn():New())  
        aColumns[Len(aColumns)]:SetData( {||(cArea)->DA3_FILPRV} ) // Dado que irá popular o campo
        aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DA3_FILPRV','X3_TITULO')) // Título da coluna 
    
    EndIf

    //Codigo Veículo
    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( {||(cArea)->DA3_COD} ) // Dado que irá popular o campo
    aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DA3_COD','X3_TITULO')) // Título da coluna
    
    //Placa
    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( {||(cArea)->DA3_PLACA} ) // Dado que irá popular o campo
    aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DA3_PLACA','X3_TITULO')) // Título da coluna

    //Tipo Veículo
    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( {||(cArea)->DUT_DESCRI} ) // Dado que irá popular o campo
    aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DA3_TIPVEI','X3_TITULO')) // Título da coluna

	//Caso a area seja de veículos disponíveis, adiciona o campo Número do Último Planejamento
	If "DA3TMP1" $ cArea .OR. "DA3TMP3" $ cArea .OR. "DA3TMP5" $ cArea
		
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( {||(cArea)->DL9_COD}  ) // Dado que irá popular o campo
		aColumns[Len(aColumns)]:SetTitle(STR0013) //Nº Últ. Plan.

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( {||StoD((cArea)->DL9_DATINI)}  ) // Dado que irá popular o campo
		aColumns[Len(aColumns)]:SetTitle(STR0014) //Data Ini. Plan.

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( {||(SUBSTR((cArea)->DL9_HORINI,1,2) + ':' + SUBSTR((cArea)->DL9_HORINI,3,2))}  ) // Dado que irá popular o campo
		aColumns[Len(aColumns)]:SetTitle(STR0015) //Data Ini. Plan.

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( {||StoD((cArea)->DL9_DATFIM)}  ) // Dado que irá popular o campo
		aColumns[Len(aColumns)]:SetTitle(STR0016) //Data Fim Plan.

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( {||(SUBSTR((cArea)->DL9_HORFIM,1,2) + ':' + SUBSTR((cArea)->DL9_HORFIM,3,2))}  ) // Dado que irá popular o campo
		aColumns[Len(aColumns)]:SetTitle(STR0017) //Hora Fim. Plan.

	EndIf

    //Motorista
	If lLGPD
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"DA4_NOME"} )) == 0		
			lOfuscated := .T.
			cNome      := Replicate('*',TamSX3('DA4_NOME')[1])
		EndIf
	EndIf	

    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( {||Iif(lOfuscated,cNome,(cArea)->DA4_NOME) } ) // Dado que irá popular o campo   
    aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DA3_MOTORI','X3_TITULO')) // Título da coluna 

    //Caso a area seja de veículos disponíveis, adiciona os campos de data e hora de chegada
    If "DA3TMP1" $ cArea .OR. "DA3TMP3" $ cArea .OR. "DA3TMP5" $ cArea    
       
    	//Data chegada
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( {||StoD((cArea)->DA3_DATSTS)} ) // Dado que irá popular o campo
        aColumns[Len(aColumns)]:SetTitle(STR0007 + ' ' + STR0010) //Título da coluna 
        
        //Hora chegada
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( {||(SUBSTR((cArea)->DA3_HORSTS,1,2) + ':' + SUBSTR((cArea)->DA3_HORSTS,3,2))} ) // Dado que irá popular o campo
        aColumns[Len(aColumns)]:SetTitle(STR0008 + ' ' + STR0010) //Título da coluna

    ElseIf "DA3TMP2" $ cArea .OR. "DA3TMP4" $ cArea .OR. "DA3TMP6" $ cArea
        
        //Data Previsão Chegada
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( {||SToD((cArea)->DA3_DATPRV)} ) // Dado que irá popular o campo
        aColumns[Len(aColumns)]:SetTitle(STR0007 + ' ' + STR0009 + ' ' + STR0010) //Título da coluna 
        
        //Hora Previsão Chegada
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( {||(SUBSTR((cArea)->DA3_HORPRV,1,2) + ':' + SUBSTR((cArea)->DA3_HORPRV,3,2))} ) // Dado que irá popular o campo
        aColumns[Len(aColumns)]:SetTitle(STR0008 + ' ' + STR0009 + ' ' + STR0010) //Título da coluna
        
    EndIf

    //Proprietário
	lOfuscated := .F.
	If lLGPD
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A2_NOME"} )) == 0		
			lOfuscated := .T.
			cNome      := Replicate('*',TamSX3('A2_NOME')[1])
		EndIf
	EndIf	
    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( {||Iif(lOfuscated,cNome,(cArea)->A2_NOME)} ) // Dado que irá popular o campo
    aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DA3_CODFOR','X3_TITULO')) //Título da coluna 

Return aColumns

//-------------------------------------------------------------------
/*/{Protheus.doc} T155QryBrw()
Retorna query para montar browse
@author  Gustavo Krug  
@since   08/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function T155QryBrw(cBrw, cCampF3, lPergunte)
Local aRet := {'', .T.}
Local aFilAtu := {}
Local aTipVei := {}
Local cFilAtu := ''
Local cTipVei := ''
Local cPlaca  := ''
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local cDbType := TCGetDB()
Local cFNull := ''
Local nX := 0
Local cArea := "DA3TMP" + cBrw

Default lPergunte := .F.
	
	aFilAtu := STRTOKARR(cFilMV, ";")
	aTipVei := STRTOKARR(cVeiMV, ";")
	
	If !(Empty(cFilMV)) .AND. AllTrim(aFilAtu[1]) <> "Todos"
		For nX := 1 to len(aFilAtu)
			cFilAtu += "'" + AllTrim(aFilAtu[nX]) + "'"
			If nX < Len(aFilAtu)
				cFilAtu += ','
			EndIf 
		Next nX
	EndIf

	If !(Empty(cVeiMV)) .AND. AllTrim(aTipVei[1]) <> "Todos" 
		For nX := 1 to len(aTipVei)
			cTipVei += "'" + AllTrim(aTipVei[nX]) + "'"
			If nX < Len(aTipVei)
				cTipVei += ','
			EndIf 
		Next nX
	EndIf
	
	cPlaca := cPlaMV

	Do Case
        Case cDbType $ "DB2/POSTGRES"
            cFNull := "COALESCE"
        Case cDbType $ "ORACLE/INFORMIX"
            cFNull := "NVL"
    Otherwise
    	cFNull := "ISNULL"
	EndCase
	
    If cBrw $ '1;3;5' //Próprios disponíveis, Agregados disponíveis, Terceiros disponíveis
		cQuery := " SELECT DA3_FILATU, DA3_COD, DA3_PLACA, DUT_DESCRI ," + cFNull + "(DA4_NOME,' ') DA4_NOME, A2_NOME, DA3_DATSTS, DA3_HORSTS " 

		cQuery += T155QryDL9('DL9_COD', cCampF3, cArea, cFNull)
		cQuery += T155QryDL9('DL9_DATINI', cCampF3, cArea, cFNull)
		cQuery += T155QryDL9('DL9_DATFIM', cCampF3, cArea, cFNull)
		cQuery += T155QryDL9('DL9_HORINI', cCampF3, cArea, cFNull)
		cQuery += T155QryDL9('DL9_HORFIM', cCampF3, cArea, cFNull)
		
		cQuery += " FROM " 		 + RetSqlName("DA3") + " " + cArea 
		cQuery += " INNER JOIN " + RetSqlName("DUT") + " DUT ON"
		cQuery += " DUT.DUT_FILIAL = '" + xFilial('DUT') + "' AND DUT.DUT_TIPVEI = DA3_TIPVEI AND DUT.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN " + RetSqlName("DA4") + " DA4 ON" 
		cQuery += " DA4.DA4_FILIAL = '" + xFilial('DA4') + "' AND DA4.DA4_COD = DA3_MOTORI AND DA4.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON"
		cQuery += " SA2.A2_FILIAL = '" + xFilial('SA2') + "' AND SA2.A2_COD = DA3_CODFOR AND SA2.A2_LOJA = DA3_LOJFOR AND SA2.D_E_L_E_T_ = ' '"
		cQuery += " WHERE " + cArea + ".DA3_FILIAL = '" + xFilial('DA3') + "' "

		If lPergunte
			Iif (!(Empty(cFilAtu)), cQuery += "	AND	" + cArea + ".DA3_FILATU IN (" + cFilAtu + ") ", "")
			
			Iif (!(Empty(cTipVei)), cQuery += "	AND	" + cArea + ".DA3_TIPVEI IN (" + cTipVei + ") ", "")
			
			Iif (!(Empty(cPlaca)), cQuery += "	AND	" + cArea + ".DA3_PLACA = '" + cPlaca + "' ", "")
		EndIf
		
		cQuery += " AND " + cArea + ".DA3_GSTDMD = '1' "
		cQuery += " AND " + cArea + ".DA3_STATUS IN ( '1', '2' ) " 
		cQuery += " AND " + cArea + ".DA3_ATIVO  = '1' "

		Do Case 
			Case cBrw == "1" 
				cQuery += " AND " + cArea + ".DA3_FROVEI = '1' "
			Case cBrw == "3"
				cQuery += " AND " + cArea + ".DA3_FROVEI = '3' "
			Case cBrw == "5"
				cQuery += " AND " + cArea + ".DA3_FROVEI = '2' "
		End Case
		
        If cCampF3 == "DL9_CODVEI"
        	cQuery += " AND DUT_CATVEI <> '3' "
        ElseIf cCampF3 == "DL9_CODRB"
        	cQuery += " AND DUT_CATVEI = '3' "
        EndIf

        cQuery += " AND " + cArea + ".D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY DA3_DATSTS, DA3_HORSTS "

        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
        If (cAliasQry)->(Bof()) .And. (cAliasQry)->(Eof())
        	aRet[2] := .F.
        EndIf

    ElseIf cBrw $ '2;4;6' //Próprios em Trânsito, Agregados em trânsito, Terceiros em trânsito
        cQuery := " SELECT DA3_FILPRV, DA3_COD, DA3_PLACA, DUT_DESCRI ," + cFNull + "(DA4_NOME,' ') DA4_NOME, A2_NOME, DA3_DATPRV, DA3_HORPRV, DA3_FILATU" 
        cQuery += " FROM " 		 + RetSqlName("DA3") + " " + cArea
		cQuery += " INNER JOIN " + RetSqlName("DUT") + " DUT ON"
		cQuery += " DUT.DUT_FILIAL = '" + xFilial('DUT') + "' AND DUT.DUT_TIPVEI = DA3_TIPVEI AND DUT.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN " + RetSqlName("DA4") + " DA4 ON" 
		cQuery += " DA4.DA4_FILIAL = '" + xFilial('DA4') + "' AND DA4.DA4_COD = DA3_MOTORI AND DA4.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON"
		cQuery += " SA2.A2_FILIAL = '" + xFilial('SA2') + "' AND SA2.A2_COD = DA3_CODFOR AND SA2.A2_LOJA = DA3_LOJFOR AND SA2.D_E_L_E_T_ = ' '"
        cQuery += " WHERE " + cArea + ".DA3_FILIAL = '" + xFilial('DA3') + "' "
        
        If lPergunte
			Iif (!(Empty(cFilAtu)), cQuery += "	AND	" + cArea + ".DA3_FILPRV IN (" + cFilAtu + ") ", "")

			Iif (!(Empty(cTipVei)), cQuery += "	AND " + cArea + ".DA3_TIPVEI IN (" + cTipVei + ") ", "")
			
			Iif (!(Empty(cPlaca)), cQuery += "	AND " + cArea + ".DA3_PLACA = '" + cPlaca + "' ", "")
		EndIf
		
        cQuery += " AND	" + cArea + ".DA3_GSTDMD = '1' "
        cQuery += " AND " + cArea + ".DA3_STATUS = '3' "
        cQuery += " AND " + cArea + ".DA3_ATIVO = '1' "

		Do Case 
			Case cBrw == "2" 
				cQuery += " AND " + cArea + ".DA3_FROVEI = '1' "
			Case cBrw == "4"
				cQuery += " AND " + cArea + ".DA3_FROVEI = '3' "
			Case cBrw == "6"
				cQuery += " AND " + cArea + ".DA3_FROVEI = '2' "
		End Case

        If cCampF3 == "DL9_CODVEI"
        	cQuery += " AND DUT_CATVEI <> '3' "
        ElseIf cCampF3 == "DL9_CODRB"
        	cQuery += " AND DUT_CATVEI = '3' "
        EndIf

        cQuery += " AND " + cArea + ".D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY DA3_DATPRV, DA3_HORPRV "

        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
        If (cAliasQry)->(Bof()) .And. (cAliasQry)->(Eof())
        	aRet[2] := .F.
        EndIf

    EndIf

    (cAliasQry)->(dbCloseArea())

    aRet[1] := cQuery
    
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T155QryDL9
Função para retornar a montagem do trecho da query que faz leitura da tabela DL9
@author  Wander Horongoso
@since   21/11/18
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T155QryDL9(cField, cCampF3, cArea, cFNull)
Local cRet := ''
	
    cRet += ", " + cFNull + "(" 
    cRet += " (SELECT DL9." + cField + " FROM " + RetSqlName('DL9') + " DL9 "  
    cRet += "   WHERE DL9.DL9_FILIAL = '" + xFilial('DL9') + "'"
    cRet += "     AND DL9.DL9_COD = (SELECT Max(DL9MAX.DL9_COD) FROM " + RetSqlName('DL9') + " DL9MAX "
    cRet += "                         WHERE DL9MAX.DL9_FILIAL = '" + xFilial('DL9') + "'"
    cRet += "                           AND DL9MAX.DL9_STATUS NOT IN ('4', '5', '8') "
    
    If cCampF3 == "DL9_CODVEI"
    	cRet += "                       AND DL9MAX.DL9_CODVEI = " + cArea + ".DA3_COD "
    Else		
    	cRet += "                       AND (   DL9MAX.DL9_CODVEI = " + cArea + ".DA3_COD "
    	cRet += "                            OR DL9MAX.DL9_CODRB1 = " + cArea + ".DA3_COD "
    	cRet += "                            OR DL9MAX.DL9_CODRB2 = " + cArea + ".DA3_COD "
    	cRet += "                            OR DL9MAX.DL9_CODRB3 = " + cArea + ".DA3_COD)" 
    EndIf
    
    cRet += "                           AND DL9MAX.D_E_L_E_T_ = ' ' ) "  
    cRet += "     AND DL9.D_E_L_E_T_ = ' ') , '') " + cField + " "
 
 Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TM154Dbclq
Double clique no registro 
@author  Ruan Ricardo Salvador  
@since   14/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TM154Dbclq(cAliasTemp)
	If type('cTM154Ret') != 'U'
		cTM154Ret := (cAliasTemp)->DA3_COD
		oDlgPrinc:End()
		T155FrBrw(.F.)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA155Par
//Executa o pergunte para o tempo
@author Wander Horongoso
@since 18/05/2018
@version 12.1.17
@param lShow: indica se o pergunte será exibido em tela
/*/
//-------------------------------------------------------------------
Function TMA155Par(lShow)
Local lRet := .F.
	 
	lRet := Pergunte('TMSA155', lShow) 
	
	If lRet .Or. !lShow
		If !Empty(MV_PAR01) .OR. MV_PAR01 > 0
			If ValType(oTimer) == 'U'
				oTimer := TTimer():New(,,oDlgPrinc)
			EndIf
			oTimer:DeActivate()
			oTimer:nInterval := MV_PAR01*60*1000
			oTimer:bAction := {|| TMA155Refr() }
			oTimer:Activate()
		Else
			If ValType(oTimer) == 'O'
				oTimer:DeActivate()
			EndIf
		EndIf
	EndIf
   	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA155Refr
Faz o refresh da tela e atualiza os grids
@author Wander Horongoso
@since 18/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TMA155Refr()

	If aShowBrw[1]
		oBrwUpL:SetQuery(aRegBrw[1,1])
		oBrwUpL:Refresh(.T.)
		oBrwUpR:SetQuery(aRegBrw[2,1])
		oBrwUpR:Refresh(.T.)
	EndIf
	
	If aShowBrw[2]	
		oBrwMidL:SetQuery(aRegBrw[3,1])
		oBrwMidL:Refresh(.T.)
		oBrwMidR:SetQuery(aRegBrw[4,1])
		oBrwMidR:Refresh(.T.)
	EndIf
		
	If aShowBrw[3]
		oBrwDownL:SetQuery(aRegBrw[5,1])
		oBrwDownL:Refresh(.T.)
		oBrwDownR:SetQuery(aRegBrw[6,1])
		oBrwDownR:Refresh(.T.)
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA155Filt
Exibe o pergunte caso seja necessário.
Efetua a montagem das querys usadas para exibir as informações nos browses.
Exibe os grids
@param: 
cCampF3: usado na montagem das querys como filtro para selecionar somente veículos carreta ou tracionado.
lPergunte:
Se .T. abre o pergunte para filtrar os dados (chamada via menu ou via F5)
Se .F. exibe todos os veículos (chamada via F3)
@author Natalia Maria Neves
@since 24/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TMA155Filt(cCampF3, lPergunte)
Local lRet := .T.
Default cCampF3 := ''

	If lPergunte
		Pergunte('TMSA1551', .F.,, .T. )
		SetMVValue("TMSA1551","MV_PAR01", cFilMV)
		SetMVValue("TMSA1551","MV_PAR02", cVeiMV)
		SetMVValue("TMSA1551","MV_PAR03", cPlaMV)
		SetMVValue("TMSA1551","MV_PAR04", nFltMV)	
		lRet := Pergunte('TMSA1551', .T.,, .T. )
	
		If lRet
			cFilMV := MV_PAR01
			cVeiMV := MV_PAR02
			cPlaMV := MV_PAR03
			nFltMV := MV_PAR04

			aRegBrw[1] := T155QryBrw('1', cCampF3, (MV_PAR04 = 1 .OR.  MV_PAR04 = 3))
			aRegBrw[2] := T155QryBrw('2', cCampF3, (MV_PAR04 = 2 .OR.  MV_PAR04 = 3))
			aRegBrw[3] := T155QryBrw('3', cCampF3, (MV_PAR04 = 1 .OR.  MV_PAR04 = 3))
			aRegBrw[4] := T155QryBrw('4', cCampF3, (MV_PAR04 = 2 .OR.  MV_PAR04 = 3))
			aRegBrw[5] := T155QryBrw('5', cCampF3, (MV_PAR04 = 1 .OR.  MV_PAR04 = 3))
			aRegBrw[6] := T155QryBrw('6', cCampF3, (MV_PAR04 = 2 .OR.  MV_PAR04 = 3))
		EndIf
	Else
		aRegBrw[1] := T155QryBrw('1', cCampF3)
		aRegBrw[2] := T155QryBrw('2', cCampF3)
		aRegBrw[3] := T155QryBrw('3', cCampF3)
		aRegBrw[4] := T155QryBrw('4', cCampF3)
		aRegBrw[5] := T155QryBrw('5', cCampF3)
		aRegBrw[6] := T155QryBrw('6', cCampF3)
	EndIf
	
	If lRet
		T155CrLayer(cCampF3) //cria e exibe o painel com os grids
	EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} T155CrLayer
Cria/recria as grid de exibição dos veículos de acordo com os filtros do pergunte
@author Wander Horongoso
@since 16/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T155CrLayer(cCampF3)
Local oPnl    := nil
Local nGrdAux := 0 //Auxiliar para qtd de linhas de grid exibidas

 	aShowBrw[1] := aRegBrw[1,2] .Or. aRegBrw[2,2] //Indica que achou veículos próprios
 	aShowBrw[2] := aRegBrw[3,2] .Or. aRegBrw[4,2] //Indica que achou veículos agregados
 	aShowBrw[3] := aRegBrw[5,2] .Or. aRegBrw[6,2] //Indica que achou veículos terceiros
	
	Iif(aShowBrw[1], nGrdAux := nGrdAux + 1,)
	Iif(aShowBrw[2], nGrdAux := nGrdAux + 1,)
	Iif(aShowBrw[3], nGrdAux := nGrdAux + 1,)

	If oFwLayer <> nil
		oFwLayer:Hide()
		T155FrBrw(.T.) //elimina os browses caso estejam criados
	EndIf		

	If nGrdAux == 0		
    
        If cCampF3 == "DL9_CODVEI"
        	Help( ,, 'HELP',, STR0011 + STR0019 + STR0020, 1, 0 ) //Não há veículos ativos com Status Em filial, de categoria diferente de carreta, ou Em trânsito para uso no gestão de demandas.
        ElseIf cCampF3 == "DL9_CODRB"
        	Help( ,, 'HELP',, STR0011 + STR0018 + STR0020, 1, 0 ) //Não há veículos ativos, de categoria carreta, com Status Em filial ou Em trânsito para uso no gestão de demandas.
        Else
        	Help( ,, 'HELP',, STR0011 + STR0020, 1, 0 ) //Não há veículos ativos com Status Em filial ou Em trânsito para uso no gestão de demandas.
        EndIf		
	
	Else
		
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlgPrinc, .F., .T. )
		oFwLayer:Show()

		nGrdAux := Int(100/nGrdAux)
	
		//Painel Superior
		If aShowBrw[1]
			oFWLayer:AddLine( 'UP', nGrdAux, .F. )                
			oFWLayer:AddCollumn( 'UPLEFT' , 50, .T., 'UP' )       
			oFWLayer:AddCollumn( 'UPRIGHT', 50, .T., 'UP' )       
			oFWLayer:AddWindow('UPLEFT' ,'UPLEFT' ,STR0002 + STR0005,100,.F.,.F.,,'UP',) //Próprios disponíveis
			oFWLayer:AddWindow('UPRIGHT','UPRIGHT',STR0002 + STR0006,100,.F.,.F.,,'UP',) //Próprios em trânsito   

			oPnl := oFWLayer:GetWinPanel( 'UPLEFT' ,'UPLEFT' , 'UP' )
			oBrwUpL := T155CrBrw(oBrwUpL, oPnl, cCampF3, '1')
			oPnl := oFWLayer:GetWinPanel( 'UPRIGHT','UPRIGHT', 'UP' )
			oBrwUpR := T155CrBrw(oBrwUpR, oPnl, cCampF3, '2')
		EndIf 
	
		//Painel Central
		If aShowBrw[2]
			oFWLayer:AddLine( 'MID', nGrdAux, .F. )                    
			oFWLayer:AddCollumn( 'MIDLEFT' ,  50, .T., 'MID' )   
			oFWLayer:AddCollumn( 'MIDRIGHT',  50, .T., 'MID' )    
			oFWLayer:AddWindow('MIDLEFT' ,'MIDLEFT' ,STR0004 + STR0005,100,.F.,.F.,,'MID',) //Agregados disponíveis
			oFWLayer:AddWindow('MIDRIGHT','MIDRIGHT',STR0004 + STR0006,100,.F.,.F.,,'MID',) //Agregados em trânsito

			oPnl := oFWLayer:GetWinPanel( 'MIDLEFT' ,'MIDLEFT' , 'MID' )   
			oBrwMidL := T155CrBrw(oBrwMidL, oPnl, cCampF3, '3')
			oPnl := oFWLayer:GetWinPanel( 'MIDRIGHT','MIDRIGHT', 'MID' )
			oBrwMidR := T155CrBrw(oBrwMidR, oPnl, cCampF3, '4')
		EndIf
	
		//Painel Inferior
		If aShowBrw[3]
			oFWLayer:AddLine( 'DOWN', nGrdAux, .F. )                   
			oFWLayer:AddCollumn( 'DOWNLEFT' ,  50, .T., 'DOWN' )   
			oFWLayer:AddCollumn( 'DOWNRIGHT',  50, .T., 'DOWN' )   
			oFWLayer:AddWindow('DOWNLEFT' ,'DOWNLEFT' ,STR0003 + STR0005,100,.F.,.F.,,'DOWN',) //Terceiros disponíveis
			oFWLayer:AddWindow('DOWNRIGHT','DOWNRIGHT',STR0003 + STR0006,100,.F.,.F.,,'DOWN',) //Terceiros em trânsito
			
			oPnl := oFWLayer:GetWinPanel( 'DOWNLEFT' ,'DOWNLEFT' , 'DOWN' )   
			oBrwDownL := T155CrBrw(oBrwDownL, oPnl, cCampF3, '5')
			oPnl := oFWLayer:GetWinPanel( 'DOWNRIGHT','DOWNRIGHT', 'DOWN' )		
			oBrwDownR := T155CrBrw(oBrwDownR, oPnl, cCampF3, '6')
		EndIf
				
	EndIf 
	
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} T155CrBrw()
Cria o browse.
Parâmetros:
oBrw: variável que irá receber o browse criado; 
oPnl: Painel em que o browse estará contido;
cCampF3: usado para abrir a tela de recursos ou para confirmar a seleção do veículo quando via F3
cBrw: indicador de qual browse está sendo montado, variando de 1 a 6. 
@author  Wander Horongoso
@since   21/11/18
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function T155CrBrw(oBrw, oPnl, cCampF3, cBrw)
Local oBrowse := nil
Local cArea := 'DA3TMP' + cBrw
	
	oBrowse := oBrw

	If oBrowse == nil
		oBrowse := FWMBrowse():New()
		oBrowse:SetDescription('')
		oBrowse:SetMenuDef('')
		oBrowse:DisableDetails()
		oBrowse:DisableLocate()
		oBrowse:DisableReport()
		oBrowse:DisableFilter()
		oBrowse:DisableConfig()                                      
		oBrowse:SetDataQuery(.T.)
		oBrowse:SetAlias(cArea)
		oBrowse:SetColumns(T155Column(cBrw))
		oBrowse:SetProfileID(cBrw)
		oBrowse:SetDoubleClick({||Iif(!Empty(cCampF3),TM154Dbclq(cArea),TMSA157(3, (cArea)->DA3_COD))})
	EndIf
	
	oBrowse:SetOwner (oPnl)
	oBrowse:SetLineHeight(15)
	oBrowse:SetQuery(aRegBrw[Val(cBrw),1])
	oBrowse:Activate()
	
	Iif (oBrw <> nil , oBrowse:Refresh(.T.), ) //refresh é necessário para quando o browse já está criado e há novo filtro

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} T155FrBrw
Elimina os browses da memória
@author Wander Horongoso
@since 16/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T155FrBrw(lFreeChildren)
	
	Iif (oBrwUpL <> nil, oBrwUpL:DeActivate(lFreeChildren),)
	Iif (oBrwUpR <> nil, oBrwUpR:DeActivate(lFreeChildren),)
	Iif (oBrwMidL <> nil, oBrwMidL:DeActivate(lFreeChildren),)
	Iif (oBrwMidR <> nil, oBrwMidR:DeActivate(lFreeChildren),)
	Iif (oBrwDownL <> nil, oBrwDownL:DeActivate(lFreeChildren),)
	Iif (oBrwDownR <> nil, oBrwDownR:DeActivate(lFreeChildren),)
	
Return nil