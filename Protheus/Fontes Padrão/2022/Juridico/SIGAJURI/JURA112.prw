#INCLUDE "JURA112.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA112
Rotina de inclusão na contabilidade e relatório de conferencia contabil

@author Jorge Luis Branco Martins Junior
@since 26/06/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA112()
Local lRet        := .F.
Local aArea       := GetArea()
Local oCliente, oLoja, oAreaD, oDtIni, oDtFim, oCbxCont, oDlg
Local cCliente    := '' 
Local cLoja       := ''
Local cAreaD      := ''
Local lParam      := SuperGetMV('MV_JINTVAL',, '2') == '1'
Local aCbxCont    := {STR0035, STR0036} //"Não","Sim"

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 233,200 TO 490,510 PIXEL // Contabilização

	oCliente := TJurPnlCampo():New(02,16,50,22,oDlg,STR0006,'A1_COD' ,{|| },{|| cCliente := oCliente:Valor},,,,'SA1') //Cliente
	oCliente:oCampo:bValid := {|| Empty(Alltrim(oCliente:Valor)) .OR. ExistCpo('SA1',oCliente:Valor,1)}

	oLoja := TJurPnlCampo():New(02,76,15,22,oDlg,STR0007,'A1_LOJA',{|| },{|| cLoja := oLoja:Valor},,,,) //Loja
	oLoja:oCampo:bValid    := {|| Empty(Alltrim(oLoja:Valor)) .Or. ExistCpo('SA1',oCliente:Valor+oLoja:Valor,1)}

	oAreaD := TJurPnlCampo():New(02,101,50,22,oDlg,STR0008,'NSZ_CAREAJ',{|| },{|| cAreaD := oAreaD:Valor},,,,'NRB') //Area
	oAreaD:oCampo:bValid   := {|| Empty(Alltrim(oAreaD:Valor)) .Or. ExistCpo('NRB',oAreaD:Valor,1)}

	@ 35, 16 Say STR0032 Size 050, 008 Pixel Of oDlg //'Contabilizado?'
	oCbxCont := TJurCmbBox():New(44,16,38,010, oDlg, aCbxCont, {|| IIf(oCbxCont:cValor<>'Sim', JA112CmbVl(oCbxCont,oDtIni,oDtFim), )})

	oDtIni := TJurPnlCampo():New(59,16,50,20,oDlg,STR0033,'NSZ_DTINCL',{|| },{|| },,,,,)//"Data Inicial"
	oDtIni:oCampo:bValid := {|| JA112VldDt(1,oDtIni:Valor,oDtFim:Valor)}
	oDtIni:oCampo:bWhen  := {|| oCbxCont:cValor==STR0036}

	oDtFim := TJurPnlCampo():New(59,95,50,20,oDlg,STR0034,'NSZ_DTENTR',{|| },{|| },,,,,)//"Data Final"
	oDtFim:oCampo:bValid  := {|| JA112VldDt(2,oDtIni:Valor,oDtFim:Valor)}
	oDtFim:oCampo:bWhen   := {|| oCbxCont:cValor==STR0036}

	@ 088,016 Button STR0010 Size 050,015 PIXEL OF oDlg  Action ( IIf( lParam .And. oCbxCont:cValor<>'', lRet := JA112Relat("1", oCliente:Valor, oLoja:Valor, oAreaD:Valor, oCbxCont:cValor, oDtIni:Valor, oDtFim:Valor), IIf(!lParam, MsgAlert(STR0037), MsgAlert(STR0038) )) ) //Relatorio / "O parâmetro de integração está desabilitado. Verifique!"/ "Não foi selecionada nenhuma opção no combo de Contabilizado. Verifique!"
	@ 088,095 Button STR0011 When {|| oCbxCont:cValor<>STR0036} Size 050,015 PIXEL OF oDlg  Action ( IIf( lParam, lRet := JA112Cont(oCliente:Valor, oLoja:Valor, oAreaD:Valor), MsgAlert(STR0037)) ) //Contabilizar /"O parâmetro de integração está desabilitado. Verifique!"
	@ 109,095 Button STR0012 Size 050,015 PIXEL OF oDlg  Action oDlg:End() //Sair
	
	ACTIVATE MSDIALOG oDlg CENTERED 

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J112ReAuEn
Relatorio de Auditoria para apresentacao do valor envolvido. 

@author Antonio Carlos Ferreira
@since 19/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J112ReAuEn()
Local lRet       := .F.
Local lChkNaoImp := .F.
Local oModel     := FWModelActive()
Local aArea      := GetArea()
Local oDtIni, oDtFim, oDlg
Local aSaveLines := FWSaveRows(  )
Local dDtIni     := CToD( '  /  /  ' )
Local dDtFim     := CToD( '  /  /  ' )
Local cCliente   := '' 
Local cLoja      := ''
Local cAreaD     := ''

	DEFINE MSDIALOG oDlg TITLE STR0053 FROM 233,200 TO 350,510 PIXEL // "Auditoria"

	oDtIni := TJurPnlCampo():New(02,16,50,20,oDlg,STR0033,'NSZ_DTINCL',{|| },{|| },,,,,)//"Data Inicial"
	oDtIni:oCampo:bValid := {|| JA112VldDt(1,oDtIni:Valor,oDtFim:Valor)}

	oDtFim := TJurPnlCampo():New(02,95,50,20,oDlg,STR0034,'NSZ_DTINCL',{|| },{|| },,,,,)//"Data Final"
	oDtFim:oCampo:bValid := {|| JA112VldDt(2,oDtIni:Valor,oDtFim:Valor)}    

	@ 035,016 Button STR0010 Size 050,015 PIXEL OF oDlg  Action ( lRet := JA112Relat("2", cCliente, cLoja, cAreaD, STR0036, oDtIni:Valor, oDtFim:Valor) ) //"Relatorio"##"Sim" 
	@ 035,095 Button STR0012 Size 050,015 PIXEL OF oDlg  Action oDlg:End() //"Sair"
	
	ACTIVATE MSDIALOG oDlg CENTERED 

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA112Relat
Rotina de inclusão na contabilidade e relatório de conferencia contabil

@author Jorge Luis Branco Martins Junior
@since 28/06/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA112Relat(cTpRel, cCliente, cLoja, cAreaD, cVlrCbx, dDtIni, dDtFim)
Local aArea       := GetArea()   
Local lRet        := .T.
Local lCliLj      := .F.
Local lArea       := .F.
Local lValor      := .F.
Local lValorL     := .F.
Local lContem     := .F.
Local lLTot       := .T.
Local cAlias      := GetNextAlias()
Local cAliasT     := GetNextAlias()
Local cQuery      := ""
Local cQueryT     := ""
Local cFiltro     := ""
Local aCodigos    := {}
Local aTabelas    := {}
Local aCabecalho  := {}
Local xCabecalho  := {} 
Local nHdl        := 0
Local nHdlOp      := 0
Local nCt         := 0
Local nVlrUlt     := 0
Local nVlrTot     := 0
Local cArq        := ''
Local cLinha      := ''
Local cNomeCam    := ''
Local cCond       := ''
Local cCabec      := ''
Local cExtens     := "Arquivo XLS | *.xls"
Local nPCajur     := 0 
Local nPCodLn     := 0 
Local nPTipoM     := 0 
Local nPTipoL     := 0 
Local lHtml       := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml

Default cCliente  := ''
Default cLoja     := ''
Default cAreaD    := ''

//------------------- Cabecalho do Relatorio Excel na variavel auxiliar ---------------------
aadd(xCabecalho, {STR0056, 'NSZ_COD'   , '0'})  //"Código Assunto Jurídico"
aadd(xCabecalho, {STR0057, 'NUQ_NUMPRO', '0'})  //"Número Processo"
aadd(xCabecalho, {STR0059, 'NT9_NOME'  , '0'})  //"Parte Contrária"
aadd(xCabecalho, {STR0002, 'NSZ_CCLIEN', '0'})  //"Unidade"
aadd(xCabecalho, {STR0003, 'NSZ_LCLIEN', '0'})  //"Filial"
aadd(xCabecalho, {STR0060, 'NSZ_NUMCAS', '0'})  //"Caso"
aadd(xCabecalho, {STR0008, 'NRB_DESC'  , '0'})  //"Área"
aadd(xCabecalho, {STR0061, ''          , '2'})  //"Prognóstico"
If cTpRel == '1'
	aadd(xCabecalho, {STR0058, ''          , '0'}) //"Linha" 
	aadd(xCabecalho, {STR0062, 'NV3_CODLAN', '0'}) //"Código Lançamento"
	aadd(xCabecalho, {STR0063, 'NV3_DATAUL', '0'}) //"Data Última Contabilização"
	aadd(xCabecalho, {STR0065, 'NV3_VALOR' , '0'}) //"Valor Total Última Contabilização"
EndIf
aadd(xCabecalho, {STR0067, ''          , '0'})  //"Data Movimentação Atual"
aadd(xCabecalho, {STR0068, 'NV3_DATAVL', '0'})  //"Data Lançamento"
aadd(xCabecalho, {STR0069, 'NV3_VALOR' , '0'})  //"Valor Movimentação Atual"
aadd(xCabecalho, {STR0070, 'NV3_TIPOM' , '0'})  //"Tipo"
aadd(xCabecalho, {If(cTpRel=='1',STR0071,STR0072), 'NV3_TIPOL' , '0'})  //"Tipo Movimento Contábil"##"Tipo Movimento"
//-------------------------------------------------------------------------------------------

	If (cTpRel=='1') .And. (Alltrim(cCliente) <> '' .And. Alltrim(cLoja) == '') .Or. (Alltrim(cCliente) == '' .And. Alltrim(cLoja) <> '')
		JurMsgErro(STR0005)
		lRet := .F.
	EndIf
	
	If (cTpRel=="1") 
		If cVlrCbx==STR0036 .And. !Empty(dTos(dDtIni)) .And. !Empty(dTos(dDtFim))
			cCond := "NV3_DATAUL <> '' and NV3_DATAUL between '"+(dTos(dDtIni))+"' and '"+(dTos(dDtFim))+"'"
		ElseIf (Empty(dTos(dDtIni)) .or. Empty(dTos(dDtFim))) .And. cVlrCbx==STR0036
			JurMsgErro(STR0039) //"Selecione o intervalo de datas para emissão da conferencia de contabilização"
			lRet := .F.
		ElseIf Empty(Alltrim(cVlrCbx)) .Or. cVlrCbx <> STR0036
			cCond := " NV3_DATAUL = '" + AVKEY(" ","NV3_DATAUL") + "' "
		EndIf  
	Else
		If !Empty(dTos(dDtIni)) .And. !Empty(dTos(dDtFim))
			cCond += " NV3_DATA <> '' and NV3_DATA between '"+(dTos(dDtIni))+"' and '"+(dTos(dDtFim))+"'"  //Filtra pela data da movimentacao
		ElseIf (Empty(dTos(dDtIni)) .or. Empty(dTos(dDtFim)))
			JurMsgErro(STR0054) // "Selecione o intervalo da data de movimentação para emissão do Relatório de Auditoria!"
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
	
		//Monta o aCabecalho[] conforme o relatorio a ser executado.
		For nCt := 1 to Len(xCabecalho)
			If (xCabecalho[nCt][3] $ ('0'+cTpRel))
				aadd(aCabecalho, {xCabecalho[nCt][1], xCabecalho[nCt][2]})

				//Posicao dos campos no aCabecalho[] utilizados no relatorio.
				nPCajur := If(xCabecalho[nCt][2]=="NSZ_COD"   , Len(aCabecalho), nPCajur)  
				nPCodLn := If(xCabecalho[nCt][2]=="NV3_CODLAN", Len(aCabecalho), nPCodLn)
				nPTipoM := If(xCabecalho[nCt][2]=="NV3_TIPOM" , Len(aCabecalho), nPTipoM)
				nPTipoL := If(xCabecalho[nCt][2]=="NV3_TIPOL" , Len(aCabecalho), nPTipoL)
			EndIf
		Next nCt

		cQuery := JA112Qry(cCliente,cLoja,cAreaD,1,cTpRel)
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		(cAlias)->( dbGoTop() )
		
		If !(cAlias)->( EOF() )
			If cTpRel == '1'
				While !(cAlias)->( EOF() )
					aAdd(aCodigos,{(cAlias)->CAJURI,(cAlias)->FILIAL})
					(cAlias)->( dbSkip() )
				End
	
				(cAlias)->( dbcloseArea() )
				aAdd(aTabelas,'NT2')
				aAdd(aTabelas,'NSZ')
	
				If Len(aCodigos) >= 1
					Processa( {|| lRet := JURA002( aCodigos, aTabelas ) }, STR0075, STR0076,.F.)//Aguarde... - Executando correção de valores...
				EndIf
				
				If !lRet
					MsgAlert(STR0009)//Houve erro na correção de valores
				EndIf
			ElseIf cTpRel == '2'
				IIf(ApMsgYesNo(STR0073), , lRet := .F.) //"Já foi executada a rotina de 'Correção Valores'?"
			EndIf
		Else
			(cAlias)->( dbcloseArea() )
			If cVlrCbx==STR0036
				ApMsgInfo(STR0040)//Não existem dados nesse intervalo de datas
			Else
				ApMsgInfo(STR0029)//Não existem dados a serem contabilizados
			EndIf
		EndIf
	EndIf

	If lRet
		cFiltro := JA112Qry(cCliente,cLoja,cAreaD,3,cTpRel)
		
		cAlias := GetNextAlias()
		cQuery := ''
		cQuery += " SELECT NSZ_COD, NUQ_NUMPRO, NT9_NOME, NSZ_CCLIEN, NSZ_LCLIEN, "
		cQuery +=        " NRB_DESC, NQ7_DESC, NV3_CODLAN, SUM(NV3_VALOR) NV3_VALOR, NV3_DATAUL, NV3_TIPOM, NV3_TIPOL, NSZ_CAREAJ, NSZ_NUMCAS, NSZ_CPROGN, NV3_DATAVL "
		cQuery += " FROM " + RetSqlName('NSZ') + " NSZ  JOIN "+RetSqlname('NUQ')+" NUQ ON (NSZ_COD = NUQ_CAJURI) "
		cQuery +=                                                                     " AND "+PrefixoCpo('NUQ')+"_FILIAL = '"+xFilial('NUQ')+"'"
		cQuery +=                                                                     " AND NUQ.D_E_L_E_T_ = ' ' AND NUQ_INSATU = '1'"
		cQuery +=                                       " JOIN "+RetSqlname('NV3')+" NV3 ON (NSZ_COD = NV3_CAJURI) "
		cQuery +=                                                                     " AND "+PrefixoCpo('NV3')+"_FILIAL = '"+xFilial('NV3')+"'"
		cQuery +=                                                                     " AND NV3.D_E_L_E_T_ = ' ' "
		cQuery +=                            " LEFT OUTER JOIN "+RetSqlname('NT9')+" NT9 ON (NSZ_COD = NT9_CAJURI) "
		cQuery +=                                                                     " AND "+PrefixoCpo('NT9')+"_FILIAL = '"+xFilial('NT9')+"'"
		cQuery +=                                                                     " AND NT9.D_E_L_E_T_ = ' ' AND NT9_TIPOEN ='1' AND NT9_PRINCI = '1' "
		cQuery +=                                  " LEFT JOIN "+RetSqlname('NRB')+" NRB ON (NSZ_CAREAJ = NRB_COD) "
		cQuery +=                                                                     " AND "+PrefixoCpo('NRB')+"_FILIAL = '"+xFilial('NRB')+"'"
		cQuery +=                                                                     " AND NRB.D_E_L_E_T_ = ' ' "
		cQuery +=                                  " LEFT JOIN "+RetSqlname('NQ7')+" NQ7 ON (NSZ_CPROGN = NQ7_COD) "
		cQuery +=                                                                     " AND "+PrefixoCpo('NQ7')+"_FILIAL = '"+xFilial('NQ7')+"'" 
		cQuery +=                                                                     " AND NQ7.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE " + cCond + " and " + cFiltro
		cQuery += " Group by NSZ_COD, NV3_CODLAN, NSZ_CCLIEN, NSZ_LCLIEN, NUQ_NUMPRO, NT9_NOME, NRB_DESC, NQ7_DESC, NV3_CODLAN,"
		cQuery +=          " NV3_TIPOM, NV3_TIPOL, NV3_DATAUL, NSZ_CAREAJ, NSZ_NUMCAS, NSZ_CPROGN, NV3_DATAVL "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		
		If !(cAlias)->( EOF() )
			lContem := .T.
		Else
			(cAlias)->( dbcloseArea() )
			If cVlrCbx==STR0036
				ApMsgInfo(STR0040)//'Não existem dados nesse intervalo de datas'
			Else
				ApMsgInfo(STR0029)//Não existem dados a serem contabilizados
			EndIf
		EndIf
	EndIf

	If lRet .And. lContem
		If !lHtml
			cArq := StrTran(Lower(cGetFile(cExtens,STR0020,,'C:\',.F.))+".xls",".xls.xls",".xls")
		Else
			cArq := "\spool\auditoria_" + DTOS(DATE()) + ".xls"
		Endif

		If cArq <> ".xls"

			FErase(cArq)
			nHdl := FCreate(cArq)

			If nHdl < 0
				JurMsgErro(STR0014 + cArq + STR0015)
				Return
			Endif

			cCabec := JA112Formt( (cAlias)->(LastRec()) + 1, Len(aCabecalho), "Contabilização" )

			If FWrite(nHdl, cCabec, Len(cCabec)) <> Len(cCabec)
				JurMsgErro(STR0016)
			EndIf
			
			cCabec:= "<tr height=34 style='mso-height-source:userset;height:25.5pt'>"
			
			If FWrite(nHdl, cCabec, Len(cCabec)) <> Len(cCabec)
				JurMsgErro(STR0016)
			EndIf
			
			//Títulos das colunas
			For nCt:=1 to Len(aCabecalho)
				cCabec:= " <td class=xl28 x:str='" +AllTrim(aCabecalho[nCt][1])+;
				"'><span style='mso-spacerun: yes'> </span>" +AllTrim(aCabecalho[nCt][1])+" </td>"
				
				If FWrite(nHdl, cCabec, Len(cCabec)) <> Len(cCabec)
					If !JurMsgErro(STR0016)
						Exit
					EndIf
				EndIf
			Next

			While !(cAlias)->( Eof() )
				//Area da linha de TOTAL
				If ((cAlias)->(&(Alltrim(aCabecalho[nPTipoM][2]))) == '1' .and. (cAlias)->(&(Alltrim(aCabecalho[nPTipoL][2]))) == '3') .Or. ;
						((cAlias)->(&(Alltrim(aCabecalho[nPTipoM][2]))) == '2' .and. (cAlias)->(&(Alltrim(aCabecalho[nPTipoL][2]))) == '2')

					cLinha := "<tr height=34 style='mso-height-source:userset;height:25.5pt'>"
					If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
						If !JurMsgErro(STR0017)
							Return
						EndIf
					EndIf
					
					cQueryT := "SELECT SUM(NV3_VALOR) SOMA FROM "+RetSqlName("NV3")+" NV3 "
					cQueryT +=" WHERE NV3_CAJURI = '" + (cAlias)->(&(Alltrim(aCabecalho[nPCajur][2]))) + "'"
					If cTpRel == '1'
						cQueryT +=  " AND NV3_CODLAN = '" + (cAlias)->(&(Alltrim(aCabecalho[nPCodLn][2]))) + "'"
					Else
						cQueryT +=  " AND NV3_CODLAN = ''"
					EndIf
					cQueryT +=  " AND NV3_TIPOL = '" + (cAlias)->(&(Alltrim(aCabecalho[nPTipoL][2])))+ "'"
					cQueryT +=  " AND "+PrefixoCpo('NV3')+"_FILIAL = '"+xFilial('NV3')+"'"
					cQueryT +=  " AND D_E_L_E_T_ = ' ' " 
					cQueryT +=  " AND NV3_DATAUL <> '' " 
					cQueryT +=  " AND NV3_LA = 'S' " 
					cQueryT +=  " AND NV3_OPERA <> '5' " 
					cQueryT +=  " AND NOT(NV3_TIPOL = '2' AND NV3_TIPOM = '1')" 

					cQueryT := ChangeQuery(cQueryT)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryT),cAliasT,.T.,.T.)

					If !(cAliasT)->( Eof() )
						nVlrUlt := (cAliasT)->(SOMA)
					EndIf

					(cAliasT)->( dbCloseArea() )
					
					cQueryT := "SELECT SUM(NV3_VALOR) SOMA FROM "+RetSqlName("NV3")+" NV3 "
					cQueryT += " WHERE NV3_CAJURI = '" + (cAlias)->(&(Alltrim(aCabecalho[nPCajur][2]))) + "'"
					If cTpRel == '1'
						cQueryT +=   " AND NV3_CODLAN = '" + (cAlias)->(&(Alltrim(aCabecalho[nPCodLn][2]))) + "'"
					Else
						cQueryT +=   " AND NV3_CODLAN = ''"
					EndIf
					cQueryT +=   " AND NV3_TIPOL  = '" + (cAlias)->(&(Alltrim(aCabecalho[nPTipoL][2])))+ "'"
					cQueryT +=   " AND "+PrefixoCpo('NV3')+"_FILIAL = '"+xFilial('NV3')+"'"
					cQueryT +=   " AND D_E_L_E_T_ = ' ' "
					cQueryT +=   " AND NOT(NV3_TIPOL = '2' AND NV3_TIPOM = '1')" 

					cQueryT := ChangeQuery(cQueryT)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryT),cAliasT,.T.,.T.)

					If !(cAliasT)->( Eof() )
						nVlrTot := (cAliasT)->(SOMA)
					EndIf

					(cAliasT)->( dbCloseArea() )
					
					For nCt:=1 to Len(aCabecalho)

						cNomeCam  := AllTrim(aCabecalho[nCt][1])
						cTitCampo := AllTrim(aCabecalho[nCt][2])

						If cTitCampo == 'NV3_DATAUL' .Or. cTitCampo == 'NV3_DATAVL'
							TcSetField( cAlias, (cAlias)->(cTitCampo), 'D', TamSX3(aCabecalho[nCt][2])[1], 0 )
						EndIf
						
						// VERIFICA O TIPO DO CAMPO PARA FORMATACAO
						If ValType((cAlias)->(&(cTitCampo))) == 'D' .Or. cNomeCam == 'Data Mov Atual'
							cClasse := " <td class=xl49>"
						ElseIf ValType((cAlias)->(&(cTitCampo))) == 'N'
							cClasse := " <td class=xl50 x:num="
						Else
							cClasse := " <td class=xl51>"
						EndIf

						cVlrCampo:= (cAlias)->(&(cTitCampo))

						If cTitCampo == 'NV3_TIPOL'
							Do Case
								Case cVlrCampo == '1'
									cVlrCampo := STR0041 //'Provisão'
								Case cVlrCampo == '2'
									cVlrCampo := STR0042 //'Garantia'
								Case cVlrCampo == '3'
									cVlrCampo := STR0043 //'Despesa'
							End Case
						ElseIf cTitCampo == 'NV3_TIPOM'
							cVlrCampo := STR0044 //'TOTAL'
						EndIf

						If Empty ( cVlrCampo ) .And. !(cNomeCam $ 'Data Mov Atual'+'|'+'Prognóstico') .And. !(cTitCampo == 'NV3_DATAUL')
							cLinha := cClasse + AllTrim( cValToChar( (cAlias)->(&(cTitCampo) )) )+ "</td>"
						ElseIf (cClasse  == " <td class=xl51>") .And. !(cNomeCam == 'Prognóstico') 
							cLinha := cClasse + AllTrim ( cVlrCampo )+ "</td>"
						Else
							If cClasse == " <td class=xl50 x:num="
								If cTitCampo == 'NV3_VALOR' .and. lValor
									cLinha := cClasse + cValToChar ( nVlrTot-nVlrUlt ) + "></td>"
									lValor := .F.
								ElseIf cTitCampo == 'NV3_VALOR' .and. !lValor
									cLinha := cClasse + cValToChar ( nVlrUlt ) + "></td>"
									lValor := .T.
								EndIf
							Else
								If (cNomeCam == 'Prognóstico')
									cLinha := cClasse + cValToChar ( Posicione('NQ7',1,xFilial('NQ7')+(cAlias)->NSZ_CPROGN,'NQ7_DESC') ) + "</td>"
								ElseIf cNomeCam == 'Data Mov Atual'
									cLinha := cClasse + cValToChar ( Date() ) + "</td>"
								ElseIf cTitCampo == 'NV3_DATAUL'
									cLinha := cClasse + cValToChar ( JA112QryDat((cAlias)->NSZ_COD,(cAlias)->NV3_CODLAN,(cAlias)->NV3_TIPOL,(cAlias)->NSZ_CCLIEN,(cAlias)->NSZ_LCLIEN,(cAlias)->NSZ_CAREAJ) ) + "</td>"
								ElseIf cTitCampo == 'NV3_DATAVL'
									cLinha := cClasse + AllTrim (cValToChar( cVlrCampo ))+ "</td>"
								EndIf
							EndIf
						EndIf
							
						If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
							If !JurMsgErro(STR0017)
								Exit
							EndIf
						EndIf
					Next
				Else
					lLTot := .F.
				EndIf

				//Inicio da area de registros
				If (cTpRel == "2") .Or. (cTpRel == "1") .And. (cAlias)->(&(Alltrim(aCabecalho[nPTipoM][2]))) <> '1' .Or.;
						((cAlias)->(&(Alltrim(aCabecalho[nPTipoM][2]))) == '1' .And. (cAlias)->(&(Alltrim(aCabecalho[nPTipoL][2]))) == '1')
					cLinha := "<tr height=34 style='mso-height-source:userset;height:25.5pt'>"
					
					If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
						If !JurMsgErro(STR0017)
							Return
						EndIf
					EndIf
	
					For nCt:=1 to Len(aCabecalho)
	
						cNomeCam  := AllTrim(aCabecalho[nCt][1])
						cTitCampo := AllTrim(aCabecalho[nCt][2])

						If cTitCampo == 'NV3_DATAUL' .OR. cTitCampo == 'NV3_DATAVL'
							TcSetField( cAlias, (cAlias)->(cTitCampo), 'D', TamSX3(aCabecalho[nCt][2])[1], 0 )
						EndIf
						
						// VERIFICA O TIPO DO CAMPO PARA FORMATACAO
						If ValType((cAlias)->(&(cTitCampo))) == 'D' .Or. cNomeCam == 'Data Mov Atual'
							cClasse := " <td class=xl44>"
						ElseIf ValType((cAlias)->(&(cTitCampo))) == 'N'
							cClasse := " <td class=xl41 x:num="
						Else
							cClasse  := " <td class=xl46>"
						EndIf

						cVlrCampo:= (cAlias)->(&(cTitCampo))

						If cTitCampo == 'NV3_TIPOL'
							Do Case
								Case cVlrCampo == '1'
									cVlrCampo := STR0041 //'Provisão'
								Case cVlrCampo == '2'
									cVlrCampo := STR0042 //'Garantia'
								Case cVlrCampo == '3'
									cVlrCampo := STR0043 //'Despesa'
								Case cVlrCampo == '8'
									cVlrCampo := STR0055 //"Envolvido"
							End Case
						ElseIf cTitCampo == 'NV3_TIPOM'
							Do Case
								Case cVlrCampo == '1'
									cVlrCampo := STR0045 //'Valor'
								Case cVlrCampo == '2'
									cVlrCampo := STR0046 //'Juros'
								Case cVlrCampo == '3'
									cVlrCampo := STR0047 //'Correção'
							End Case
						EndIf

						If Empty ( cVlrCampo ) .And. !(cNomeCam $ 'Data Mov Atual'+'|'+'Prognóstico') .And. !(cTitCampo == 'NV3_DATAUL')
							cLinha := cClasse + AllTrim( cValToChar( (cAlias)->(&(cTitCampo) )) )+ "</td>"
						ElseIf (cClasse  == " <td class=xl46>")  .And. !(cNomeCam == 'Prognóstico') 
							cLinha := cClasse + AllTrim ( cVlrCampo )+ "</td>"
						Else
							If cClasse == " <td class=xl41 x:num="
								If cTitCampo == 'NV3_VALOR' .and. (lValorL .Or. cTpRel == "2")
									cLinha := cClasse + cValToChar ( cVlrCampo ) + "></td>"
									lValorL := .F.
								ElseIf cTitCampo == 'NV3_VALOR' .and. !lValorL
									cLinha := cClasse + cValToChar ( JA112Valor((cAlias)->(&(Alltrim(aCabecalho[nPCajur][2]))), (cAlias)->(&(Alltrim(aCabecalho[nPCodLn][2]))),(cAlias)->(&(Alltrim(aCabecalho[nPTipoL][2]))),(cAlias)->(&(Alltrim(aCabecalho[nPTipoM][2])))) /*nVlrUlt*/ ) + "></td>"
									lValorL := .T.
								EndIf
							ElseIf cNomeCam == 'Prognóstico'
								    cLinha := cClasse + cValToChar ( Posicione('NQ7',1,xFilial('NQ7')+(cAlias)->NSZ_CPROGN,'NQ7_DESC') ) + "</td>"
							ElseIf cNomeCam == 'Data Mov Atual'
								cLinha := cClasse + cValToChar ( Date() ) + "</td>"
							ElseIf cTitCampo == 'NV3_DATAUL'
								cLinha := cClasse + cValToChar ( JA112QryDat((cAlias)->NSZ_COD,(cAlias)->NV3_CODLAN,(cAlias)->NV3_TIPOL,(cAlias)->NSZ_CCLIEN,(cAlias)->NSZ_LCLIEN,(cAlias)->NSZ_CAREAJ) ) + "</td>"
							ElseIf cTitCampo == 'NV3_DATAVL'
								cLinha := cClasse + AllTrim (cValToChar( cVlrCampo ))+ "</td>"
							EndIf
						EndIf

						If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
							If !JurMsgErro(STR0017)
								Exit
							EndIf
						EndIf
					Next

				EndIf

				(cAlias)->( dbSkip() )

				cLinha := "</tr>"
				
				If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
					If !JurMsgErro(STR0017)
						Return
					EndIf
				EndIf
			End
			
		(cAlias)->( dbCloseArea() )
			
		RestArea(aArea)
			
		FClose(nHdl)
			
		//Verifica se o usuário quer abrir o arquivo
		J112AbreArq(cArq, 'Contábil')

	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA112Formt
Monta a formatação da planilha em excel
Uso Geral. 

@param nLinhas		Número de linhas
@param nColunas		Número de colunas

@author Juliana Iwayama Velho
@since 29/06/12
@version 1.0
/*/
//-------------------------------------------------------------------   
Function JA112Formt(nLinhas, nColunas, cAba, lVertical)
Local cFormato := ''
Local cPage    := "landscape"

Default lVertical := .F.

If lVertical
	cPage := "portrait"
EndIf

cFormato := "<html xmlns:v='urn:schemas-microsoft-com:vml'"+;
"xmlns:o='urn:schemas-microsoft-com:office:office'"+;
"xmlns:x='urn:schemas-microsoft-com:office:excel'"+;
"xmlns='http://www.w3.org/TR/REC-html40'>"+;
"<head>"+;
"<meta http-equiv=Content-Type content='text/html; charset=windows-1252'>"+;
"<meta name=ProgId content=Excel.Sheet>"+;
"<meta name=Generator content='Microsoft Excel 9'>"+;
"<link rel=File-List href='./pagina_arquivos/filelist.xml'>"+;
"<link rel=Edit-Time-Data href='./pagina_arquivos/editdata.mso'>"+;
"<link rel=OLE-Object-Data href='./pagina_arquivos/oledata.mso'>"+;
"<!--[if gte mso 9]><xml>"+;
" <o:DocumentProperties>"+;
"  <o:LastAuthor>BCS</o:LastAuthor>"+;
"  <o:LastPrinted>2005-10-14T18:08:09Z</o:LastPrinted>"+;
"  <o:Created>2003-05-28T19:01:01Z</o:Created>"+;
"  <o:LastSaved>2005-10-21T17:33:16Z</o:LastSaved>"+;
"  <o:Version>9.2812</o:Version>"+;
" </o:DocumentProperties>"+;
" <o:OfficeDocumentSettings>"+;
"  <o:DownloadComponents/>"+;
"  <o:LocationOfComponents HRef='file://Mailhost/DRIVERS/suporte/OFFICE/Msoffice2000/msowc.cab'/>"+;
" </o:OfficeDocumentSettings>"+;
"</xml><![endif]-->"+;
"<style>"+;
"<!--"+;
".style18mso-number-format:'_\(\0022R$ \0022* \#\,\#\#0\.00_\)\;_\(\0022R$ \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022R$ \0022* \0022-\0022??_\)\;_\(\@_\)';"+;
"mso-style-name:Moeda;"+;
"mso-style-id:4;"+;
"table"+;
"	{mso-displayed-decimal-separator:'\.';"+;
"    mso-displayed-thousand-separator:'\,';}"+;
"@page"+;
"	{margin:.39in .39in .39in .39in;"+;
"	mso-header-margin:.51in;"+;
"	mso-footer-margin:.51in;"+;
"	mso-page-orientation:" + cPage + ";"+;
"	mso-horizontal-page-align:center;}"+;
"tr"+;
"	{mso-height-source:auto;}"+;
"col"+;
"	{mso-width-source:auto;}"+;
"br"+;
"	{mso-data-placement:same-cell;}"+;
".style0"+;
"	{mso-number-format:General;"+;
"	text-align:general;"+;
"	vertical-align:bottom;"+;
"	white-space:nowrap;"+;
"	mso-rotate:0;"+;
"	mso-background-source:auto;"+;
"	mso-pattern:auto;"+;
"	font-size:10.0pt;"+;
"	font-weight:400;"+;
"	font-style:normal;"+;
"	text-decoration:none;"+;
"	font-family:Arial;"+;
"	mso-generic-font-family:auto;"+;
"	mso-font-charset:0;	border:none;"+;
"	mso-protection:locked visible;"+;
"	mso-style-name:Normal;"+;
"	mso-style-id:0;}"+;
"td"+;
"	{mso-style-parent:style0;"+;
"	padding-top:1px;"+;
"	padding-right:1px;"+;
"	padding-left:1px;"+;
"	mso-ignore:padding;"+;
"	color:windowtext;"+;
"	font-size:10.0pt;"+;
"	font-weight:400;"+;
"	font-style:normal;"+;
"	text-decoration:none;"+;
"	font-family:Arial;"+;
"	mso-generic-font-family:auto;"+;
"	mso-font-charset:0;"+;
"	mso-number-format:General;"+;
"	text-align:general;"+;
"	vertical-align:bottom;"+;
"	border:none;"+;
"	mso-background-source:auto;"+;
"	mso-pattern:auto;"+;
"	mso-protection:locked visible;"+;
"	white-space:nowrap;	mso-rotate:0;}"+;
".xl24"+;
"	  {mso-style-parent:style0;"+;
"	  text-align:center;}"+;
".xl25"+;
"   {mso-style-parent:style0;"+;
"	  mso-number-format:Standard;}"+;
".xl26"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'\@';"+;
"   text-align:center;"+;
"   vertical-align:middle;}"+;
".xl27"+;
"   {mso-style-parent:style0;"+;
"   font-weight:700;"+;
"   font-family:Arial, sans-serif;"+;
"   mso-font-charset:0;"+;
"   mso-number-format:'_\(\0022R$ \0022* \#\,\#\#0\.00_\)\;_\(\0022R$ \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022R$ \0022* \0022-\0022??_\)\;_\(\@_\)';"+;
"   text-align:center;"+;
"   vertical-align:middle;"+;
"   border-top:.5pt solid windowtext;"+;
"   border-right:.5pt solid windowtext;"+;
"   border-bottom:.5pt solid windowtext;"+;
"   border-left:.5pt solid windowtext;"+;
"   background:silver;"+;
"   mso-pattern:auto none;}"+;
".xl28"+;
"   {mso-style-parent:style0;"+;
"	font-weight:700;"+;
"	font-family:Arial, sans-serif;"+;
"   mso-font-charset:0;"+;
"	mso-number-format:'_\(\0022 \0022* \#\,\#\#0\.00_\)\;_\(\0022 \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022 \0022* \0022-\0022??_\)\;_\(\@_\)';"+;
"	text-align:center;"+;
"	vertical-align:middle;"+;
"	border-top:.5pt solid black;"+;
"	border-right:.5pt solid black;"+;
"	border-bottom:.5pt solid black;"+;
"   border-left:.5pt solid black;"+;
"	background:silver;"+;
"   mso-pattern:auto none;}"+;
".xl29"+;
"	  {mso-style-parent:style0;"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  mso-number-format:Standard;"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"	  border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;"+;
"	  background:silver;"+;
"	  mso-pattern:auto none;}"+;
".xl30"+;
"	  {mso-style-parent:style0;"+;
"     mso-number-format:0;"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"   border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;}"+;
".xl31"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'\@';"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"	  border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;}"+;
".xl32"+;
"	  {mso-style-parent:style0;"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  mso-number-format:Standard;"+;
"	  text-align:right;"+;
"	  vertical-align:middle;"+;
"	  border-top:none;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:none;}"+;
".xl33"+;
"	  {mso-style-parent:style0;"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  mso-number-format:Standard;"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"	  border-top:none;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:none;}"+;
".xl34"+;
"   {mso-style-parent:style0;"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  mso-number-format:'_\(\0022R$ \0022* \#\,\#\#0\.00_\)\;_\(\0022R$ \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022R$ \0022* \0022-\0022??_\)\;_\(\@_\)';"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"	  border-top:none;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;"+;
"	  background:silver;"+;
"	  mso-pattern:auto none;}"+;
".xl35"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:Standard;"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"	  border-top:none;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:none;}"+;
".xl36"+;
"	  {mso-style-parent:style0;"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  mso-number-format:'_\(\0022R$ \0022* \#\,\#\#0\.00_\)\;_\(\0022R$ \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022R$ \0022* \0022-\0022??_\)\;_\(\@_\)';"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"	  border:.5pt solid windowtext;"+;
"	  background:silver;"+;
"	  mso-pattern:auto none;}"+;
".xl37"+;
"	  {mso-style-parent:style0;"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  mso-number-format:'_\(\0022R$ \0022* \#\,\#\#0\.00_\)\;_\(\0022R$ \0022* \\\(\#\,\#\#0\.00\\\)\;_\(\0022R$ \0022* \0022-\0022??_\)\;_\(\@_\)';"+;
"	  text-align:center;"+;
"	  vertical-align:middle;"+;
"	  border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:none;"+;
"	  background:silver;"+;
"	  mso-pattern:auto none;}"+;
".xl38"+;
"	  {mso-style-parent:style0;"+;
"	  color:white;"+;
"	  font-size:12.0pt;"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  text-align:left;"+;
"	  vertical-align:middle;"+;
"	  border-top:.5pt solid windowtext;"+;
"	  border-right:none;"+;
"	  border-bottom:.5pt solid windowtext;"+;
"	  border-left:.5pt solid windowtext;"+;
"	  background:blue;"+;
"	  mso-pattern:auto none;}"+;
".xl39"+;
"	  {mso-style-parent:style0;"+;
"	  color:white;"+;
"	  font-size:12.0pt;"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  text-align:center;"+;
"	  border-top:.5pt solid windowtext;"+;
"	  border-right:none;"+;
"	  border-bottom:.5pt solid windowtext;"+;
"   border-left:none;"+;
"	  background:blue;"+;
"	  mso-pattern:auto none;}"+;
".xl40"+;
"	  {mso-style-parent:style0;"+;
"	  color:white;"+;
"	  font-size:12.0pt;	font-weight:700;"+;
"     font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"	  text-align:center;"+;
"     border-top:.5pt solid windowtext;"+;
"	  border-right:.5pt solid windowtext;"+;
"	  border-bottom:.5pt solid windowtext;"+;
"	  border-left:none;"+;
"	  background:blue;"+;
"	  mso-pattern:auto none;}"+;
".xl41"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'\#\,\#\#0\.00';"+;
"     text-align:right;"+;
"	  vertical-align:middle;"+;
"	  border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;}"+;
".xl42"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:0;"+;
"	  text-align:center;"+;
"	  vertical-align:middle;}"+;
".xl43"+;
"	  {mso-style-parent:style0;"+;
"   color:white;"+;
"	  mso-number-format:0;"+;
"	  text-align:center;"+;
"	  vertical-align:middle;}"+;
".xl44"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'Short Date';"+;
"	  text-align:left;"+;
"	  vertical-align:middle;"+;
"     border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;}"+;
".xl45"+;
"	{mso-style-parent:style0;"+;
"	mso-number-format:'\#\,\#\#0\.00';"+;
"   font-weight:700;"+;
"	mso-font-charset:0;"+;
"   text-align:right;"+;
"   vertical-align:middle;"+;
"   border-top:.5pt solid black;"+;
"   border-right:.5pt solid black;"+;
"   border-bottom:.5pt solid black;"+;
"   border-left:.5pt solid black;}"+;
".xl46"+;
"   {mso-style-parent:style0;"+;
"   mso-number-format:General;"+;
"   text-align:left;"+;
"   vertical-align:middle;"+;
"   border-top:.5pt solid black;"+;
"   border-right:.5pt solid black;"+;
"   border-bottom:.5pt solid black;"+;
"   border-left:.5pt solid black;}"+;
".xl48"+;
"   {mso-style-parent:style0;"+;
"		font-weight:700;"+;
"		font-family:Arial, sans-serif;"+;
"   mso-font-charset:0;"+;
"		mso-number-format:'\#\,\#\#0\.00';"+;
"   text-align:right;"+;
"		vertical-align:middle;"+;
"		border-top:.5pt solid black;"+;
"		border-right:.5pt solid black;"+;
"		border-bottom:.5pt solid black;"+;
"   border-left:.5pt solid black;"+;
"		background:silver;"+;
"   mso-pattern:auto none;}"+;
".xl49"+; 
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'Short Date';"+; 
"		font-weight:700;"+;
"	  text-align:left;"+;
"	  vertical-align:middle;"+;
"     border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;"+;
"		background:#B4CFEC;"+;
"   mso-pattern:auto none;}"+;
".xl50"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'\#\,\#\#0\.00';"+;
"		font-weight:700;"+;
"   text-align:right;"+;
"	  vertical-align:middle;"+;
"	  border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:.5pt solid black;"+;
"		background:#B4CFEC;"+;
"   mso-pattern:auto none;}"+;
".xl51"+;
"   {mso-style-parent:style0;"+;
"   mso-number-format:General;"+;
"		font-weight:700;"+;
"   text-align:left;"+;
"   vertical-align:middle;"+;
"   border-top:.5pt solid black;"+;
"   border-right:.5pt solid black;"+;
"   border-bottom:.5pt solid black;"+;
"   border-left:.5pt solid black;"+;
"		background:#B4CFEC;"+;
"   mso-pattern:auto none;}"+;
".xl47"+;
"	  {mso-style-parent:style0;"+;
"	  mso-number-format:'\#\,\#\#0\.00';"+;
"	  font-weight:700;"+;
"	  font-family:Arial, sans-serif;"+;
"	  mso-font-charset:0;"+;
"   text-align:rigth;"+;
"	  vertical-align:middle;"+;
"	  border-top:.5pt solid black;"+;
"	  border-right:.5pt solid black;"+;
"	  border-bottom:.5pt solid black;"+;
"	  border-left:none;"+;
"   background:silver;"+;
"	  mso-pattern:auto none;}--></style><!--[if gte mso 9]>"+;
"   <xml> <x:ExcelWorkbook>"+;
"  <x:ExcelWorksheets>"+;
"   <x:ExcelWorksheet>"+;
"    <x:Name>"+cAba+"</x:Name>"+;
"    <x:WorksheetOptions>"+;
"     <x:FitToPage/>"+;
"     <x:Print>"+;
"     <x:FitHeight>30</x:FitHeight>"+;
"     <x:ValidPrinterInfo/>"+;
"     <x:Scale>10</x:Scale>"+;
"      <x:HorizontalResolution>600</x:HorizontalResolution>"+;
"      <x:VerticalResolution>600</x:VerticalResolution>"+;
"     </x:Print>"+;
"     <x:ShowPageBreakZoom/>"+;
"     <x:PageBreakZoom>100</x:PageBreakZoom>"+;
"     <x:Selected/>"+;
"     <x:DoNotDisplayGridlines/>"+;
"     <x:ProtectContents>False</x:ProtectContents>"+;
"     <x:ProtectObjects>False</x:ProtectObjects>"+;
"     <x:ProtectScenarios>False</x:ProtectScenarios>"+;
"    </x:WorksheetOptions>"+;
"   </x:ExcelWorksheet>"+;
"  </x:ExcelWorksheets>"+;
"  <x:WindowHeight>8190</x:WindowHeight>"+;
"  <x:WindowWidth>14700</x:WindowWidth>"+;
"  <x:WindowTopX>600</x:WindowTopX>"+;
"  <x:WindowTopY>435</x:WindowTopY>"+;
"  <x:ProtectStructure>False</x:ProtectStructure>"+;
"  <x:ProtectWindows>False</x:ProtectWindows>"+;
" </x:ExcelWorkbook> <x:ExcelName>"+;
"  <x:Name>_FilterDatabase</x:Name>"+;
"  <x:Hidden/>  <x:SheetIndex>1</x:SheetIndex>"+;
"  <x:Formula>="+cAba+"!$M$2:$AM$55</x:Formula>"+;
" </x:ExcelName> "+;
" <x:ExcelName>  <x:Name>Print_Area</x:Name>"+;
"  <x:SheetIndex>1</x:SheetIndex>"+;
" <x:Formula>="+cAba+"!$C$1:$"+cValToChar(nColunas)+":$"+cValToChar(nLinhas)+"</x:Formula>"+;
" </x:ExcelName>"+;
" <x:ExcelName> <x:Name>Print_Titles</x:Name>"+;
"  <x:SheetIndex>1</x:SheetIndex>"+;
"  <x:Formula>="+cAba+"!$1:$2</x:Formula>"+;
" </x:ExcelName></xml><![endif]--><!--[if gte mso 9]>"+;
"<xml> <o:shapedefaults v:ext='edit' spidmax='1030'/></xml><![endif]-->"+;
"</head><body link=blue vlink=purple>"+;
"<table x:str border=0 cellpaddin g=0 cellspacing=0 style='border-collapse:collapse;table-layout:fixed'>"+Chr(13)+Chr(10)

Return cFormato

//-------------------------------------------------------------------
/*/{Protheus.doc} JA112Cont
Rotina de inclusão na contabilidade e relatório de conferencia contabil

@author Jorge Luis Branco Martins Junior
@since 05/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA112Cont(cCliente,cLoja,cAreaD)
Local aSays    := {}
Local aButtons := {}
Local nOpca    := 0
Local nRet     := -1
Local oGrid    := Nil
Local cChvLock := "JA112Cont_"+DTOS(DATE())

	If !LockByName(cChvLock, .T., .T.)
		JurMsgErro(STR0077) // "Neste momento, outro usuário está executando esta rotina. Tente novamente mais tarde."
	Else
		//--------------------------------------------------------
		//@param cFunName     Nome da rotina de menu de processamento
		//@param cTitle       Titulo da rotina de menu
		//@param cDescription Descrição completa da rotina
		//@param bProcess     Bloco de código de processamento. O bloco recebe a variavel que informa que a rotina foi cancelada
		//@param cPerg        Nome do grupo de perguntas do dicionário de dados
		//
		//Pergunte:
		// mv_par01 - Mostra Lancamentos Contabeis ?  Sim Nao
		// mv_par02 - Aglutina Lancamentos         ?  Sim Nao
		// mv_par03 - Gerar Lancamentos Por        ?  Historico        Documento   Dia
		// mv_par04 - Contabiliza Baixa Por        ?  Dt. Competência  Data Caixa  Data Base
		//---------------------------------------------------------------------------------------
		oGrid:=FWGridProcess():New("JURA112",STR0001,STR0030,{|lEnd| nRet := CTLanc(oGrid,@lEnd,cCliente,cLoja,cAreaD)},"JURA112"/*Pergunte*/)
		oGrid:SetMeters(1)
		oGrid:Activate()

		UnLockByName(cChvLock, .T., .T.)

		If nRet > 0// Se houver lançamentos padronizados
			If oGrid:IsFinished() .And. nRet == 1
				ApMsgInfo(STR0031)//Contabilização realizada com sucesso
			ElseIf oGrid:IsFinished() .And. nRet == 2
				ApMsgInfo(STR0029)//Não existem dados a serem contabilizados
			ElseIf oGrid:IsFinished() .And. nRet == 3
				ApMsgInfo(STR0074)//Contabilização cancelada !
			EndIf

		ElseIf nRet == 0
			ApMsgStop(STR0052)		//"Não existem lançamentos padronizados para a execução. Verifique(LPs 9D0, 9D1 e 9D2)!"
		EndIf
	EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} CTLanc
Rotina chamada para validação para inclusão na contabilidade ser feita

@author Jorge Luis Branco Martins Junior
@since 05/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CTLanc(oGrid,lEnd,cCliente,cLoja,cAreaD)
Local aArea     := GetArea()
Local aAreaNV3  := NV3->(GetArea())
Local cPadrao   := ""
Local cPadraoI  := "9D0"   // Lançamento padrão a ser configurado no CT5
Local cPadraoE  := "9D1"  // Lançamento padrão a ser configurado no CT5
Local cPadraoD  := "9D2" // Lançamento padrão a ser configurado no CT5
Local cLote     := LoteCont("JUR") // Lote Contábil do lançamento, cada módulo tem o seu e está configurado na tabela 09 do SX5
Local cRotina   := "JURA112" // Rotina que está gerando o lançamento para ser possivel fazer o posterior rastreamento
Local cArquivo  := ""  // Arquivo temporario usado para contabilizacao
Local nHdlPrv   := 0  // Handle (numero do arquivo de trabalho) utilizado na contabilizacao
Local nTotal    := 0 // Variável totalizadora da contabilizacao
Local lMostra   := (MV_PAR01==1)  // MV_PAR01  Verifica se mostra ou nao tela de contabilização
Local lAglutina := (MV_PAR02==1) // MV_PAR02  Verifica se aglutina lançamentos com as mesmas entidades contábeis
Local aFlagCTB  := {} // Array com as informações para a gravação do flag de contabilização do registro
Local cAlias    := GetNextAlias()
Local cQuery    := ""
Local nRet      := 0
Local lRet      :=  .F.
Local dDataAnt  := dDataBase
Local aMovNV3   := {}
Local dDtQuebra := cToD("")
Local nContBxPor:= 3 //Caso não exista o pergunte MV_PAR04, a baixa será contabilizada pela Data Base
Local cQryQtd   := ""

	If Type("MV_PAR04") != "U" .And. !Empty(MV_PAR04)
		nContBxPor := MV_PAR04
	Endif

	If EMPTY(MV_PAR03)
		MV_PAR03 := 1
	EndIf

	//--------------------------------------------------------
	// Função que verifica se o lançamento padrão foi configurado pelo cliente
	//--------------------------------------------------------
	If VerPadrao(cPadraoI) .And. VerPadrao(cPadraoE)
		//--------------------------------------------------------
		// Função de abertura do lançamento contabil
		//--------------------------------------------------------
		nHdlPrv := HeadProva(cLote,cRotina,Substr(cUsername,1,6),@cArquivo)
	EndIf

	If nHdlPrv > 0
		//--------------------------------------------------------
		// Posiciono no inicio do periodo
		//--------------------------------------------------------
		J112PrepLan(cCliente,cLoja,cAreaD)

		cQuery := JA112Qry(cCliente,cLoja,cAreaD,4,'1', .T.)

		If !JurAuto()
			//Busca a quantidade de registros a serem contabilizados
			//para definir o calculo da barra de progresso
			cQryQtd := " Select COUNT(*) AS QTD From ("+cQuery+") a"

			oGrid:SetMaxMeter(JurSQL(cQryQtd, {'QTD'})[1][1], 1)
		EndIf

		If nContBxPor == 1 // Regime de Competência
			cQuery := " Select * From ("+cQuery+") a order by DATAL, LA"
		ElseIf nContBxPor == 2 // Regime de Caixa 
			cQuery := " Select * From ("+cQuery+") a order by DATAVL, LA"
		EndIf

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		(cAlias)->( dbGoTop() )

		If !(cAlias)->( EOF() )
			lRet := .T.
		Else
			nRet := 2 //Não existem dados a serem contabilizados
		EndIf

		If lRet
			While !(cAlias)->( EOF() )
				JA112Pos((cAlias)->CAJURI,(cAlias)->CODLAN, (cAlias)->COD)
				//<---  Quebra por Dia Ou Se a Data para lançamento seja diferente da DataBase --->
				If (VldQuebra(cAlias,@dDtQuebra) .And.(MV_PAR03 == 3 .Or. nContBxPor != 3))
					
					dDataBase := dDtQuebra
					dDtQuebra := cToD("")

					If SetLanCtb(nHdlPrv,nTotal,cArquivo, cLote,lMostra,lAglutina,aFlagCTB, dDataAnt)
						cArquivo := ""
						nTotal   := 0
						nHdlPrv := HeadProva(cLote,cRotina,Substr(cUsername,1,6),@cArquivo)
						
						If !(MarkOff(cCliente, cLoja, cAreaD, cLote,aMovNV3, lAglutina)) 
							nRet := 1
						EndIf
						aSize(aMovNV3,0)
					EndIf
					VldQuebra(cAlias,@dDtQuebra)
				EndIf
				
				JA112Pos((cAlias)->CAJURI,(cAlias)->CODLAN, (cAlias)->COD)
				Aadd(aMovNV3, {(cAlias)->CAJURI,(cAlias)->CODLAN, (cAlias)->COD})

				If nHdlPrv > 0 .And. (Alltrim((cAlias)->LA) != 'S' .Or. (cAlias)->OPERA == '5')
					aAdd(aFlagCTB,{"NV3_LA","S","NV3",(cAlias)->RECNO,0,0,0})
					aAdd(aFlagCTB,{"NV3_DATAUL",Date(),"NV3",(cAlias)->RECNO,0,0,0})

					DbSelectArea("NV3")

					If ColumnPos('NV3_PROGN') > 0
						aAdd(aFlagCTB,{"NV3_PROGN",(cAlias)->PROGN,"NV3",(cAlias)->RECNO,0,0,0}) 
					EndIf

					//--------------------------------------------------------
					// Função que aplica as regras de contabilização do cliente
					//--------------------------------------------------------
					If (cAlias)->OPERA <> '5' //Inclusao
						If (cAlias)->TIPOL == '6' .Or. (cAlias)->TIPOL == '7'
							cPadrao := cPadraoD
						ElseIf (cAlias)->TIPOL == '4' .Or. (cAlias)->TIPOL == '5'  .Or. (cAlias)->TIPOL == 'A'
							cPadrao := cPadraoI
						ElseIf (cAlias)->TIPOL == '9' .Or. (cAlias)->TIPOL == 'B'
							cPadrao := cPadraoE
						EndIf
					Else
						cPadrao := cPadraoE
					EndIf

					//--------------------------------------------------------
					// Posicionar registros para descobrir a conta contabil
					//--------------------------------------------------------
					nTotal += DetProva(nHdlPrv,cPadrao,cRotina,cLote,,,,,,,,@aFlagCTB,,)
				EndIf
				
				If !JurAuto()
					oGrid:SetIncMeter(1, STR0078)// "Preparando lançamentos para enviar a contabilidade, aguarde... "
				EndIf

				(cAlias)->(DbSkip())
			EndDo
		EndIf	
			(cAlias)->( dbcloseArea() )

			// Recupera o valor real da data base por seguranca
		If nContBxPor == 3 .AND. MV_PAR03 != 3
			dDataBase := dDataAnt
		EndIf

		If lRet
			SetLanCtb(nHdlPrv, nTotal, cArquivo, cLote, lMostra, lAglutina, aFlagCTB,dDataAnt)

			If nHdlPrv > 0
				If ( MarkOff(cCliente, cLoja, cAreaD, cLote,aMovNV3,lAglutina) .And. (nRet <> 1) )//verifica se houve a ctb, se não houve em nenhuma linha, na NV3 indicamos que não foi feito o lançamento ainda
					nRet := 3
				Else
					nRet := 1
				EndIf
			Else
				nRet := 2
			EndIf
		EndIf
	EndIf
	
	dDataBase := dDataAnt
		RestArea( aAreaNV3 )
		RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA112Pos
Posiciona as tabelas necessárias para Execução de lançamentos padrão

@author Jorge Luis Branco Martins Junior
@since 06/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA112Pos(cCajuri,cCodLan,cCod)
	
	dbSelectArea("NV3")
	dbSetOrder(1)
	MsSeeK(xFilial("NV3")+cCod)
	
	dbSelectArea("NSZ")
	dbSetOrder(1)
	MsSeeK(xFilial("NSZ")+cCajuri)

	dbSelectArea("NT2")
	dbSetOrder(1)
	MsSeeK(xFilial("NT2")+cCajuri+cCodLan)

	dbSelectArea("NT3")
	dbSetOrder(1)
	MsSeeK(xFilial("NT3")+cCajuri+cCodLan)

	dbSelectArea("NQ7")
	dbSetOrder(1)
	MsSeeK(xFilial("NQ7")+NSZ->NSZ_CPROGN)
	
	dbSelectArea("NRB")
	dbSetOrder(1)
	MsSeeK(xFilial("NRB")+NSZ->NSZ_CAREAJ)

	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeeK(xFilial("SA1")+NSZ->NSZ_CCLIEN+NSZ->NSZ_LCLIEN)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA112Qry
Query Para o filtro feito em tela

@author Jorge Luis Branco Martins Junior
@since 10/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA112Qry(cCliente,cLoja,cAreaD,nCond,cTpRel)
Local aArea     := GetArea()
Local aAreaNV3  := NV3->(GetArea())
Local cQuery    := ""
Local cFiltro   := ""
Local lCliLj    := .F.
Local lArea     := .F.
Local nMes      := Month(Date())
Local nAno      := Year(Date())
Local nMesAnt   := 0
Local nAnoAnt   := 0
Local lFluigAp  := (SuperGetMV('MV_JFLUIGA',, '2') == '1') //Aprovações via FLUIG - Uso na auditoria

Default cTpRel  := "1"

If nMes == 1
	nMesAnt := 12
	nAnoAnt := cValToChar(StrZero( nAno-1, 4 ))
Else
	nMesAnt := cValToChar(StrZero( nMes-1, 2 ))
	nAnoAnt := cValToChar(StrZero( nAno, 4 ))
EndIf
	
	lCliLj  := IIF(Alltrim(cCliente) <> '' .and. Alltrim(cLoja) <> '', .T., .F.)
	lArea   := IIF(Alltrim(cAreaD) <> '', .T., .F.)
	
	If lCliLj = .T. .And. lArea = .T.
		cFiltro := "NSZ_CCLIEN = '"  +cCliente+ "' AND NSZ_LCLIEN = '" +cLoja+ "' AND NSZ_CAREAJ = '" +cAreaD+ "' AND "
	ElseIf lCliLj = .T. .And. lArea = .F.
		cFiltro := "NSZ_CCLIEN = '"  +cCliente+ "' AND NSZ_LCLIEN = '" +cLoja+ "' AND "
	ElseIf lCliLj = .F.  .And. lArea = .T.
		cFiltro := "NSZ_CAREAJ = '" +cAreaD+ "' AND "
	EndIf
	
	If nCond == 1
		cFiltro += " NV3_FILIAL = '" + xFilial("NV3") + "' AND NV3.D_E_L_E_T_ = ' ' GROUP BY NV3_CAJURI, NSZ_CFCORR, NSZ_FILIAL "
		
		cQuery := "SELECT NV3_CAJURI CAJURI, NSZ_CFCORR CFCORR, NSZ_FILIAL FILIAL FROM "+RetSqlName("NV3")+" NV3 "
	ElseIf nCond == 2
		cFiltro += " NV3_FILIAL = '" + xFilial("NV3") + "' AND NV3.D_E_L_E_T_ = ' ' AND ((NV3_DATAUL = '" + AVKEY(" ","NV3_DATAUL") + "'  AND NV3_LA <> 'S' AND NV3_OPERA <> '5') or (NV3_DATAUL <> '' AND NV3_LA <> 'S' AND NV3_OPERA = '5')) AND (NV3_TIPOL = '4' or (NV3_TIPOL = '5' AND NV3_TIPOM <> '1')) " //and NV3_DATAVL >= '"+nAnoAnt+nMesAnt+"' " 
		cFiltro += " GROUP BY NV3_COD, NV3_CAJURI, NV3_DATA, NV3_DATAVL, NV3_DATAUL, NV3_CODLAN, NV3_OPERA, NV3_LA, NV3.R_E_C_N_O_ "
		
		cQuery := "SELECT NV3_COD COD, NV3_CAJURI CAJURI, NV3_DATA DATAL, NV3_DATAVL DATAVL, NV3_DATAUL DATAUL, NV3_CODLAN CODLAN, NV3_OPERA OPERA, NV3_LA LA, NV3.R_E_C_N_O_ RECNO FROM "+RetSqlName("NV3")+" NV3 "
	ElseIf nCond == 3
		cFiltro += " NV3_FILIAL = '" + xFilial("NV3") + "' AND NSZ_FILIAL = '" + xFilial("NSZ") + "' AND NSZ.D_E_L_E_T_ = ' ' AND NV3.D_E_L_E_T_ = ' ' "
		If (cTpRel == "2")
			cFiltro += " AND NV3_TIPOL = '8'"  //Valor envolvido
		Else
			cFiltro += " AND NV3_TIPOL < '3' AND NOT(NV3_TIPOL = '2' AND NV3_TIPOM = '1') "
		EndIf
		cFiltro += " AND NV3_OPERA <> '5'"
	ElseIf nCond == 4
		DbSelectArea("NV3")
		If ColumnPos('NV3_PROGN') > 0
			If lFluigAp
				cFiltro += " NV3_FILIAL = '" + xFilial("NV3") + "' AND NV3.D_E_L_E_T_ = ' ' AND ((NV3_DATAUL = '" + AVKEY(" ","NV3_DATAUL") + "'  AND NV3_LA <> 'S' AND NV3_OPERA <> '5') or (NV3_DATAUL <> '' AND NV3_LA <> 'S' AND NV3_OPERA = '5')) AND ((NV3_TIPOL = '4' AND NV3_PROGN = '1') Or (NV3_TIPOL = '6' AND NV3_PROGN = '1') Or (NV3_TIPOL = '7' AND NV3_TIPOM > '1') Or (NV3_TIPOL = '5' AND NV3_TIPOM <> '1') Or ((NV3_TIPOL = '9' Or NV3_TIPOL = 'A' Or NV3_TIPOL = 'B')) ) "
				cFiltro += " GROUP BY NV3_COD, NV3_CAJURI, NV3_DATA, NV3_DATAVL, NV3_DATAUL, NV3_CODLAN, NV3_OPERA, NV3_LA, NV3.R_E_C_N_O_, NV3_VALOR, NV3_TIPOL, NV3_PROGN "
				
				cQuery := "SELECT NV3_COD COD, NV3_CAJURI CAJURI, NV3_DATA DATAL, NV3_DATAVL DATAVL, NV3_DATAUL DATAUL, NV3_CODLAN CODLAN, NV3_OPERA OPERA, NV3_LA LA, NV3.R_E_C_N_O_ RECNO, NV3_TIPOL TIPOL, NV3_PROGN PROGN FROM "+RetSqlName("NV3")+" NV3 "
			Else
				cFiltro += " NV3_FILIAL = '" + xFilial("NV3") + "' AND NV3.D_E_L_E_T_ = ' ' AND ((NV3_DATAUL = '" + AVKEY(" ","NV3_DATAUL") + "' AND NV3_LA <> 'S' AND NV3_OPERA <> '5') or (NV3_DATAUL <> '' AND NV3_LA <> 'S' AND NV3_OPERA = '5')) AND (NV3_TIPOL = '4' Or NV3_TIPOL = '6' Or (NV3_TIPOL = '7' AND NV3_TIPOM > '1') Or (NV3_TIPOL = '5' AND NV3_TIPOM <> '1') Or ((NV3_TIPOL = '9' Or NV3_TIPOL = 'A' Or NV3_TIPOL = 'B')) ) "
				cFiltro += " GROUP BY NV3_COD, NV3_CAJURI, NV3_DATA, NV3_DATAVL, NV3_DATAUL, NV3_CODLAN, NV3_OPERA, NV3_LA, NV3.R_E_C_N_O_, NV3_VALOR, NV3_TIPOL, NV3_PROGN "
				
				cQuery := "SELECT NV3_COD COD, NV3_CAJURI CAJURI, NV3_DATA DATAL, NV3_DATAVL DATAVL, NV3_DATAUL DATAUL, NV3_CODLAN CODLAN, NV3_OPERA OPERA, NV3_LA LA, NV3.R_E_C_N_O_ RECNO, NV3_TIPOL TIPOL, NV3_PROGN PROGN FROM "+RetSqlName("NV3")+" NV3 "
			EndIf
		Else
			cFiltro += " NV3_FILIAL = '" + xFilial("NV3") + "' AND NV3.D_E_L_E_T_ = ' ' AND ((NV3_DATAUL = '" + AVKEY(" ","NV3_DATAUL") + "'  AND NV3_LA <> 'S' AND NV3_OPERA <> '5') or (NV3_DATAUL <> '' AND NV3_LA <> 'S' AND NV3_OPERA = '5')) AND (NV3_TIPOL = '4' Or NV3_TIPOL = '6' Or (NV3_TIPOL = '7' AND NV3_TIPOM > '1') Or (NV3_TIPOL = '5' AND NV3_TIPOM <> '1') Or ((NV3_TIPOL = '9' Or NV3_TIPOL = 'A' Or NV3_TIPOL = 'B')) ) "
			cFiltro += " GROUP BY NV3_COD, NV3_CAJURI, NV3_DATA, NV3_DATAVL, NV3_DATAUL, NV3_CODLAN, NV3_OPERA, NV3_LA, NV3.R_E_C_N_O_, NV3_VALOR, NV3_TIPOL "
		
		cQuery := "SELECT NV3_COD COD, NV3_CAJURI CAJURI, NV3_DATA DATAL, NV3_DATAVL DATAVL, NV3_DATAUL DATAUL, NV3_CODLAN CODLAN, NV3_OPERA OPERA, NV3_LA LA, NV3.R_E_C_N_O_ RECNO, NV3_TIPOL TIPOL  FROM "+RetSqlName("NV3")+" NV3 "
		EndIf
	EndIf
  
	If nCond <> 3 
		cQuery += " LEFT JOIN "+RetSqlName("NSZ")+" NSZ "
		cQuery +=        " ON NV3_CAJURI = NSZ_COD "
		cQuery +=           " AND NSZ_FILIAL = '" + xFilial("NSZ") + "' "
		cQuery +=           " AND NSZ.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE "+ cFiltro 
	Else
		cQuery := cFiltro //Query Para o filtro feito em tela
	EndIf

RestArea( aAreaNV3 )
RestArea( aArea )

Return cQuery
//-------------------------------------------------------------------
/*/{Protheus.doc} J112PrepLan
Prepara lançamentos para contabilização classificando os registros em: 
    Provisao Positivo = Valor de Provisão incluído ou aumentado
    Provisao Negativo = Valor de Provisão Reduzido
    Garantia Positivo = Valor de Garantia incluído ou aumentado
    Garantia Negativo = Valor de Garantia Reduzido

@Param  cCliente = Código do Cliente a ser contabilizado
        cLoja    = Código da Loja a ser contabilizada
        cAreaD   = Código da Area a ser contabilizada
@since 14/03/2019
/*/
//-------------------------------------------------------------------
Function J112PrepLan(cCliente,cLoja,cAreaD)
Local aArea     := GetArea()
Local aAreaNV3  := NV3->(GetArea())
Local cAlias    := GetNextAlias()
Local aCampos   := {}
Local lRet      := .T.
Local cTipoL    := ""
Local nSoma     := 0
Local lFluigAp  := (SuperGetMV('MV_JFLUIGA',, '2') == '1') //Aprovações via FLUIG - Uso na auditoria
Local lCpoAudit := .F. // Proteção dos fontes - Verifica se os campos usados para auditoria existem no dicionário 
Local cSelect   := ""
Local cFrom     := ""
Local cWhere    := ""
Local cGroup    := ""
Local cQuery    := ""

    DbSelectArea("NV3")
    lCpoAudit := ColumnPos('NV3_PROGN') > 0

    cSelect := " SELECT NV3_CAJURI CAJURI, NV3_CODLAN CODLAN, NV3_TIPOL TIPOL, NV3_TIPOM TIPOM, NV3_VALOR, NV3_COD, NV3_DATA, NV3_DATAVL,NV3_FILORI, NV3_CAREAJ "
    cFrom   :=   " FROM "+RetSqlName("NV3")+" NV3  LEFT JOIN "+RetSqlName("NSZ")+" NSZ ON (NV3_CAJURI = NSZ_COD "
    cFrom   +=                                                                            " AND NSZ_FILIAL = '" + xFilial("NSZ") + "' "
    cFrom   +=                                                                            " AND NSZ.D_E_L_E_T_ = ' ' )"
    cWhere +=  " WHERE NV3_FILIAL = '" + xFilial("NV3") + "' "
    cWhere +=    " AND NV3.D_E_L_E_T_ = ' ' "
    cWhere +=    " AND NV3_DATAUL = '" + AVKEY(" ","NV3_DATAUL") + "' "
    cWhere +=    " AND NV3_LA <> 'S' "
    cWhere +=    " AND NV3_TIPOL < '3' "
    cWhere += JA112AltVa(cAreaD)
    cGroup  +=" GROUP BY NV3_CAJURI, NV3_CODLAN, NV3_TIPOL, NV3_TIPOM, NV3_VALOR, NV3_COD, NV3_DATA, NV3_DATAVL,NV3_FILORI, NV3_CAREAJ "
    
    If lFluigAp .And. lCpoAudit
        cSelect += " ,NV3_PROGN PROGN, NV3_SITPRO SITUAC "
        cWhere += " and ((NV3_TIPOL = '1' and NV3_PROGN = '1') Or (NV3_TIPOL = '2' and NV3_TIPOM > '1')) " 
        cGroup  += " , NV3_PROGN, NV3_SITPRO"
    Else
        cWhere +=  " and (NV3_TIPOL = '1' Or (NV3_TIPOL = '2' and NV3_TIPOM > '1')) "
    EndIf

    cQuery := cSelect + cFrom + cWhere + cGroup +" ORDER BY NV3_TIPOL, NV3_COD, NV3_CAJURI"

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
    (cAlias)->( dbGoTop() )

    While !(cAlias)->( EOF() )
        If lRet
            Do Case
                Case (cAlias)->TIPOL == '1' //Provisao
                    If (cAlias)->NV3_VALOR >= 0
                        cTipoL := '4'  //Provisao Positivo
                        nSoma := (cAlias)->NV3_VALOR
                    Else
                        cTipoL := '6'  //Provisao Negativo
                        nSoma := (cAlias)->NV3_VALOR * (-1)
                    EndIf
                Case (cAlias)->TIPOL == '2' //Garantias 
                    If (cAlias)->NV3_VALOR >= 0
                        cTipoL := '5' //Garantia Positiva
                        nSoma := (cAlias)->NV3_VALOR
                    Else
                        cTipoL := '7' //Garantia Negativa 
                        nSoma := (cAlias)->NV3_VALOR * (-1)
                    EndIf
            EndCase

            If lCpoAudit
                If lFluigAp
                    aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), (cAlias)->CAJURI, (cAlias)->CODLAN, (cAlias)->NV3_DATA, (cAlias)->NV3_DATAVL, nSoma, (cAlias)->TIPOM, cTipoL, '3', '', 'N', (cAlias)->PROGN, (cAlias)->SITUAC,(cAlias)->NV3_FILORI, (cAlias)->NV3_CAREAJ}
                Else
                    aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), (cAlias)->CAJURI, (cAlias)->CODLAN, (cAlias)->NV3_DATA, (cAlias)->NV3_DATAVL, nSoma, (cAlias)->TIPOM, cTipoL, '3', '', 'N', "", "",(cAlias)->NV3_FILORI,(cAlias)->NV3_CAREAJ}
                EndIf
            Else
                aRegistro := {xFilial('NV3'), GETSXENUM("NV3","NV3_COD"), (cAlias)->CAJURI, (cAlias)->CODLAN, (cAlias)->NV3_DATA, (cAlias)->NV3_DATAVL, nSoma, (cAlias)->TIPOM, cTipoL, '3', '', 'N',(cAlias)->NV3_FILORI,(cAlias)->NV3_CAREAJ}
            EndIf

            If lCpoAudit
                aCampos := {"NV3_FILIAL", "NV3_COD", "NV3_CAJURI", "NV3_CODLAN", "NV3_DATA","NV3_DATAVL", "NV3_VALOR",;
                            "NV3_TIPOM", "NV3_TIPOL", "NV3_OPERA","NV3_PEDIDO", "NV3_LA", "NV3_PROGN", "NV3_SITPRO","NV3_FILORI", "NV3_CAREAJ"}
            Else
                aCampos := {"NV3_FILIAL", "NV3_COD", "NV3_CAJURI", "NV3_CODLAN", "NV3_DATA", "NV3_DATAVL",;
                            "NV3_VALOR", "NV3_TIPOM", "NV3_TIPOL", "NV3_OPERA", "NV3_PEDIDO", "NV3_LA","NV3_FILORI", "NV3_CAREAJ"}
            EndIf
            lRet := JurOperacao(4, "NV3",1,xFilial("NV3")+(cAlias)->NV3_COD, {"NV3_LA"}, {"S"}) //Faz a alteração no historico
            lRet := JurOperacao(4, "NV3",1,xFilial("NV3")+(cAlias)->NV3_COD, {"NV3_DATAUL"}, Date()) //Faz a alteração no historico
            lRet := JurOperacao(3, "NV3",,, aCampos, aRegistro) //Faz a inclusao no historico
            
        EndIf
        (cAlias)->(DbSkip())
    End

    (cAlias)->( dbcloseArea() )

    RestArea( aAreaNV3 )
    RestArea( aArea )

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} MarkOff
Desmarca no histórico os registros que não foram contabilizados

@Return Valor lógico onde indica se foi cancelada toda a contabilização ou apenas parte dela
@author Jorge Luis Branco Martins Junior
@since 13/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MarkOff(cCliente, cLoja, cAreaD, cLote,aMovNV3, lAglutina)
Local aArea     := GetArea()
Local aAreaNV3  := NV3->(GetArea())
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local cFiltro   := ""
Local lCliLj    := .F.
Local lArea     := .F.
Local aCampos   := {"NV3_DATAUL", "NV3_LA"}
Local lCpoAudit := .F. // Proteção dos fontes - Verifica se os campos usados para auditoria existem no dicionário 
Local cCodigo   := ""
Local lRet      := .F.
Local nI, nX    := 0
Local cKey      := ""
Local cBanco    := Upper(TcGetDb())
Local aCV3Key   := {}
Local lQryRet   := .F.

Default lAglutina := .F.

	DbSelectArea("NV3")
	lCpoAudit := ColumnPos('NV3_PROGN') > 0

	lCliLj := IIF(Alltrim(cCliente) <> '' .and. Alltrim(cLoja) <> '', .T., .F.)
	lArea  := IIF(Alltrim(cAreaD) <> '', .T., .F.)

	For nI := 1 to Len(aMovNV3)
		cCodigo += "'"+aMovNV3[nI][3] + "',"
	next nI

	cQuery  := " SELECT CV3_KEY "
	cQuery  += " FROM " + RetSqlName( "CV3" ) + " CV3 "
	cFiltro := " WHERE CV3_TABORI = 'NV3' "

	If cBanco $ "POSTGRES"
		cFiltro += " AND CAST (CV3_RECORI as integer) IN (SELECT NV3.R_E_C_N_O_ "
	Else
		cFiltro += " AND CV3_RECORI IN (SELECT NV3.R_E_C_N_O_ "
	EndIf

	cFiltro += "                      FROM " + RetSqlName( "NV3" ) + " NV3 " 
	cFiltro += "                      LEFT JOIN " + RetSqlName( "NSZ" ) + " NSZ "
	cFiltro += "                      ON   NV3_CAJURI = NSZ_COD " 
	cFiltro += "                      AND  NSZ_FILIAL = '  ' "
	cFiltro += "                      AND  NSZ.D_E_L_E_T_ = ' ' " 
	
	If lCliLj .And. lArea
		cFiltro += "                      AND NSZ_CCLIEN = '" +cCliente+ "' "
		cFiltro += "                      AND NSZ_LCLIEN = '" +cLoja+ "' "
		cFiltro += "                      AND NSZ_CAREAJ = '" +cAreaD+ "' "
	ElseIf lCliLj .And. !lArea
		cFiltro += "                      AND NSZ_CCLIEN = '" +cCliente+ "' "
		cFiltro += "                      AND NSZ_LCLIEN = '" +cLoja+ "' "
	ElseIf !lCliLj .And. lArea
		cFiltro += "                      AND NSZ_CAREAJ = '" +cAreaD+ "' "
	EndIf
	
	cFiltro += "                      WHERE NV3_COD IN ("+ SubStr(cCodigo,1,len(cCodigo)-1) + ") "
	cFiltro += "                      AND   NV3_DATAUL <> '' "
	cFiltro += "                      AND   NV3_LA = 'S' "
	cFiltro += "                      AND   NV3_FILIAL = '" + xFilial("NV3") + "' "
	cFiltro += "                      AND   NV3.D_E_L_E_T_ = ' ') "
	
	cFiltro += " ORDER BY CV3.CV3_KEY "	

	cQuery  += cFiltro 
	
	If cBanco $ "ORACLE|POSTGRES"
		cQuery := StrTran(cQuery, "+", "||")
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() ) 
		lQryRet := .T.
		Aadd(aCV3Key, {(cAlias)->CV3_KEY})
		(cAlias)->(DbSkip())
	End

	If lQryRet 
		For nX := 1 to Len(aMovNV3) 
			If aScan(aCV3Key,{|x|AllTrim(x[1]) == AllTrim(xFilial("NV3")+aMovNV3[nX][3])}) == 0
				aRegistro := {cToD("  /  /    "),'N'}
				JurOperacao(4, "NV3",1,xFilial("NV3")+aMovNV3[nX][3], aCampos, aRegistro) //Faz a alteração no historico
			EndIf
		Next nX
	EndIf
	
	(cAlias)->( dbcloseArea() )

	RestArea( aAreaNV3 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA112QryDat
Query Para Data da ultima contabilização no Relatório

@author Jorge Luis Branco Martins Junior
@since 13/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA112QryDat(cCajuri,cCod,cTipoL,cCliente,cLoja,cAreaD)
Local cQuery  := ""
Local cAlias  := GetNextAlias()
Local cFiltro := ""
Local lCliLj  := .F.
Local lArea   := .F.
Local dData   := SToD("")


	lCliLj := IIF(Alltrim(cCliente) <> '' .and. Alltrim(cLoja) <> '', .T., .F.)
	lArea  := IIF(Alltrim(cAreaD) <> '', .T., .F.)
	
	If lCliLj .And. lArea
		cFiltro := "NSZ_CCLIEN = '"  +cCliente+ "' and NSZ_LCLIEN = '" +cLoja+ "' AND NSZ_CAREAJ = '" +cAreaD+ "' AND "
	ElseIf lCliLj .And. !lArea
		cFiltro := "NSZ_CCLIEN = '"  +cCliente+ "' AND NSZ_LCLIEN = '" +cLoja+ "' AND "
	ElseIf !lCliLj .And. lArea
		cFiltro := "NSZ_CAREAJ = '" +cAreaD+ "' AND "
	EndIf

	cQuery := " SELECT B.NV3_DATAUL DATAUL 
	cQuery += " FROM ( SELECT NV3_CAJURI, NV3_CODLAN, NV3_TIPOL"
	cQuery +=        " FROM "+RetSqlName("NV3")+" NV3 LEFT JOIN "+RetSqlName("NSZ")+" NSZ ON NV3_CAJURI = NSZ_COD " 
	cQuery +=                                                                          " AND NV3_FILIAL = NSZ_FILIAL " 
	cQuery +=                                                                          " AND NV3.D_E_L_E_T_ = ' ' " 
	cQuery +=        " WHERE NV3_CAJURI = '"+cCajuri+"' " 
	cQuery +=          " AND NV3_CODLAN = '"+cCod+"' "
	cQuery +=          " AND NV3_TIPOL = '"+cTipoL+"' "
	cQuery +=          " AND " + cFiltro + " NV3_FILIAL = '" + xFilial("NV3") + "' "
	cQuery +=          " AND NV3.D_E_L_E_T_ = ' '"
	//cQuery += cFiltro + " NV3_FILIAL = '" + xFilial("NV3") + "' and NV3.D_E_L_E_T_ = ' ' and NV3_DATAUL = '' and NV3_LA <> 'S' GROUP BY NV3_CAJURI, NV3_CODLAN, NV3_TIPOL "
	cQuery += " ) A INNER JOIN ( SELECT NV3_CAJURI, NV3_CODLAN, NV3_TIPOL, MAX(NV3_DATAUL) NV3_DATAUL 
	cQuery +=                  " FROM "+RetSqlName("NV3")+" NV3 LEFT JOIN "+RetSqlName("NSZ")+" NSZ ON NV3_CAJURI = NSZ_COD " 
	cQuery +=                                                                                    " AND NV3_FILIAL = NSZ_FILIAL " 
	cQuery +=                                                                                    " AND NV3.D_E_L_E_T_ = ' ' "
	cQuery +=                  " WHERE NV3_CAJURI = '"+cCajuri+"'"
	cQuery +=                    " AND NV3_CODLAN = '"+cCod+"' "
	cQuery +=                    " AND NV3_TIPOL = '"+cTipoL+"' "
	cQuery +=                    " AND " + cFiltro + " NV3_FILIAL = '" + xFilial("NV3") + "' "
	cQuery +=                    " AND NV3.D_E_L_E_T_ = ' ' "
	cQuery +=                    " AND NV3_DATAUL <> '' " 
	cQuery +=                    " AND NV3_LA = 'S' "
	cQuery +=                  " GROUP BY NV3_CAJURI, NV3_CODLAN, NV3_TIPOL "
	cQuery += " ) B  ON A.NV3_CAJURI = B.NV3_CAJURI" 
	cQuery +=     " AND A.NV3_CODLAN = B.NV3_CODLAN"
	cQuery +=     " AND A.NV3_TIPOL  = B.NV3_TIPOL"
//cQuery += "WHERE A.NV3_CAJURI+A.NV3_CODLAN+A.NV3_TIPOL = B.NV3_CAJURI+B.NV3_CODLAN+B.NV3_TIPOL"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	(cAlias)->( dbGoTop() )
	
	If !(cAlias)->( EOF() )
		dData := StoD((cAlias)->DATAUL)
	EndIf

	(cAlias)->( dbcloseArea() )
	
Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} JA112Valor
Query Para valores de contabilização

@author Jorge Luis Branco Martins Junior
@since 02/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA112Valor(cCajuri, cCodlan, cTipoL, cTipoM)
Local cQueryT := ""
Local cAliasT := GetNextAlias()
Local nVlrUlt := 0

	cQueryT := " SELECT SUM(NV3_VALOR) SOMA FROM "+RetSqlName("NV3")+" NV3 "
	cQueryT += " WHERE NV3_CAJURI = '" + cCajuri + "'"
	cQueryT +=   " AND NV3_CODLAN = '" + cCodlan + "'"
	cQueryT +=   " AND NV3_TIPOL  = '" + cTipoL  + "'"
	cQueryT +=   " AND NV3_TIPOM  = '" + cTipoM  + "'"
	cQueryT +=   " AND "+PrefixoCpo('NV3')+"_FILIAL = '"+xFilial('NV3')+"'"
	cQueryT +=   " AND D_E_L_E_T_ = ' ' " 
	cQueryT +=   " AND NV3_DATAUL <> '' " 
	cQueryT +=   " AND NV3_LA = 'S' " 
	cQueryT +=   " AND NV3_OPERA <> '5' " 
	cQueryT +=   " AND NOT(NV3_TIPOL = '2' AND NV3_TIPOM = '1')" 

	cQueryT := ChangeQuery(cQueryT)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryT),cAliasT,.T.,.T.)

	If !(cAliasT)->( Eof() )
		nVlrUlt := (cAliasT)->(SOMA)
	EndIf

	(cAliasT)->( dbCloseArea() )

Return (nVlrUlt)
//-------------------------------------------------------------------
/*/{Protheus.doc} JA112VldDt
Valida a data

@author Jorge Luis Branco Martins Junior
@since 31/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA112VldDt(nData,dDtIni,dDtFim)
Local lRet := .T.

If nData = 1
	If dTos(dDtIni) > dTos(Date())
		lRet := .F.
		ApMsgAlert(STR0049) //'Data Inicial para consulta não pode ser maior que a data atual!'
	EndIf
EndIf

If lRet .And. !Empty(dTos(dDtIni)) .And. !Empty(dTos(dDtFim))
	If dTos(dDtFim) < dTos(dDtIni)
		lRet := .F.
		ApMsgAlert(STR0050) //'Data Final deve ser maior que a inicial. Verifique!'
	EndIf
EndIf

If lRet .And. nData = 2
	If dTos(dDtFim) > dTos(Date())
		lRet := .F.
		ApMsgAlert(STR0051) //'Não é possível emitir relatório com dados futuros'
	EndIf
EndIf

Return lRet   

//-------------------------------------------------------------------
/*/{Protheus.doc} JA112CmbVl
Verifica o valor no combobox para limpar campo de data

@author Jorge Luis Branco Martins Junior
@since 31/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA112CmbVl(oCbxCont,oDtIni,oDtFim)
	oDtIni:Valor := CToD( '  /  /  ' )
	oDtFim:Valor := CToD( '  /  /  ' )
	oDtIni:Refresh()
	oDtFim:Refresh()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA112AltVa
Verifica se houve alterações nos valores que já foram somados para
a contabilização para fazer um filtro dos registros que devem ser
somados. Caso haja algum registro alterado, este não entra no
filtro, caso contrário, entra no filtro para que não seja somado
novamente.

@author Jorge Luis Branco Martins Junior
@since 13/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA112AltVa(cAreaD)
Local aArea     := GetArea()
Local aAreaNV3  := NV3->(GetArea())
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local cFiltroA  := ""
Local nI        := 0
Local nJ        := 0
Local aSoma1    := {}
Local aSoma2    := {}
Local lFluigAp  := (SuperGetMV('MV_JFLUIGA',, '2') == '1') //Aprovações via FLUIG - Uso na auditoria
Local lCpoAudit := .F. // Proteção dos fontes - Verifica se os campos usados para auditoria existem no dicionário 

Default cArea := ""

DbSelectArea("NV3")
lCpoAudit := ColumnPos('NV3_PROGN') > 0

	cQuery := " SELECT SUM(NV3_VALOR) SOMA ,NV3_CAJURI CAJURI, NV3_CODLAN CODLAN, NV3_TIPOL TIPOL, NV3_TIPOM TIPOM FROM "+RetSqlName("NV3")+" NV3 WHERE NV3_TIPOL > '3' AND NV3_LA <> 'S' " 
	If lFluigAp .And. lCpoAudit
		cQuery += " AND '1' = ( CASE WHEN (NV3_TIPOL = '4' OR NV3_TIPOL = '6') THEN NV3_PROGN ELSE '1' END ) " 
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' ' AND NV3_FILIAL = '" + xFilial("NV3") + "'"
	if !Empty(cAreaD)
		cQuery += " AND NV3_CAREAJ = '" + cAreaD + "'"
	Endif
	cQuery += " GROUP BY NV3_CAJURI, NV3_CODLAN, NV3_TIPOL, NV3_TIPOM "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		aAdd(aSoma1, {(cAlias)->CAJURI+(cAlias)->CODLAN, (cAlias)->SOMA, (cAlias)->TIPOL, (cAlias)->TIPOM })
		(cAlias)->(DbSkip())
	End

	(cAlias)->( dbcloseArea() )

	cQuery := " SELECT SUM(NV3_VALOR) SOMA ,NV3_CAJURI CAJURI, NV3_CODLAN CODLAN, NV3_TIPOL TIPOL, NV3_TIPOM TIPOM FROM "+RetSqlName("NV3")+" NV3 WHERE NV3_TIPOL < '3' AND NV3_LA <> 'S' " 
	If lFluigAp .And. lCpoAudit
		cQuery += " AND '1' = ( CASE WHEN NV3_TIPOL = '1' THEN NV3_PROGN ELSE '1' END ) " 
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' ' AND NV3_FILIAL = '" + xFilial("NV3") + "'"
	if !Empty(cAreaD)
		cQuery += " AND NV3_CAREAJ = '" + cAreaD + "'"
	Endif
	cQuery += " GROUP BY NV3_CAJURI, NV3_CODLAN, NV3_TIPOL, NV3_TIPOM "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	(cAlias)->( dbGoTop() )
	
	While !(cAlias)->( EOF() )
		aAdd(aSoma2, {(cAlias)->CAJURI+(cAlias)->CODLAN, (cAlias)->SOMA, (cAlias)->TIPOL, (cAlias)->TIPOM })
		(cAlias)->(DbSkip())
	End
	
	(cAlias)->( dbcloseArea() )

	For nI := 1 To Len(aSoma1)
		For nJ := 1 To Len(aSoma2)
			If aSoma1[nI][1] == aSoma2[nJ][1] .And. aSoma1[nI][3] <> aSoma2[nJ][3] .And. aSoma1[nI][4] == aSoma2[nJ][4]
				If aSoma1[nI][2] == aSoma2[nJ][2]
					If aSoma1[nI][3] <> '6' .And. aSoma1[nI][3] <> '7'
						cFiltroA += " AND NV3_CAJURI||NV3_CODLAN <> '" + aSoma1[nI][1] + "' "
					EndIf
				Else
					If aSoma1[nI][2]*(-1) == aSoma2[nJ][2]
						cFiltroA += " AND NV3_CAJURI||NV3_CODLAN <> '" + aSoma1[nI][1] + "' "
					EndIf
				EndIf
			EndIf
		Next
	Next
	
	RestArea( aAreaNV3 )
	RestArea(aArea)

Return cFiltroA

//-------------------------------------------------------------------
/*/{Protheus.doc} J112AbreArq
Abre o arquivo que foi gerado.

@param	cArquivo	- Nome e caminho do arquivo que sera aberto
@return lRetorno	- Define se foi aberto o arquivo corretamente

@author Rafael Tenorio da Costa
@since 17/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J112AbreArq( cArquivo, cTitulo )

	Local nRet     := 0
	Local lRetorno := .T.
	Local lHtml    := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml

	Default cTitulo := ' '

	If !Empty(AllTrim(cTitulo))
		cTitulo := STR0010 + ' ' + cTitulo //Relatório
	EndIf

	If lHtml //se for html, manda o arquivo via download
		If CpyS2TW(cArquivo, .T.) < 0
			JurMsgErro(STR0027) //"Não foi possível abrir o arquivo. Falha de rede."
			lRetorno := .F.
		Endif
	Else
		//Verifica se o usuário quer abrir o arquivo
		If ApMsgYesNo(STR0018 + cArquivo + STR0019, cTitulo )//"Exportação gerada em " # ". Deseja abrir o arquivo?" "O arquivo " 
					
			nRet := ShellExecute( "open", cArquivo, "", "C:\", 1 )
		
			If nRet <= 32
				
				Do Case
					Case nRet == 2
						JurMsgErro(STR0022)//"Não foi possível abrir o arquivo. Arquivo ou diretório não existe."
						lRetorno := .F.
						
					Case nRet == 5 .Or. nRet == 55
						JurMsgErro(STR0023)//"Não foi possível abrir o arquivo. Acesso negado."
						lRetorno := .F.
						
					Case nRet == 15
						JurMsgErro(STR0024)//"Não foi possível abrir o arquivo. Drive não esta pronto."
						lRetorno := .F.
						
					Case nRet == 31
						JurMsgErro(STR0025)//"Não foi possível abrir o arquivo. Falha Geral."
						lRetorno := .F.
						
					Case nRet == 32
						JurMsgErro(STR0026)//"Não foi possível abrir o arquivo. Violação de compartilhamento."
						lRetorno := .F.
						
					Case nRet == 72
						JurMsgErro(STR0027)//"Não foi possível abrir o arquivo. Falha de rede."
						lRetorno := .F.
						
					OTherWise
						JurMsgErro(STR0028)//"Não foi possível abrir o arquivo. O arquivo não está associado a um programa, diretório não existe, arquivo não existe ou ocorreu algum erro não identificado."
						lRetorno := .F.
				EndCase
			EndIf
		EndIf
	Endif

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLanCtb
Envia lancamentos para a contabilidade

@param nHdlPrv Handle (numero do arquivo de trabalho) utilizado na contabilizacao
@param nTotal totalizadora da contabilizacao
@param cArquivo Arquivo temporario usado para contabilizacao
@param cLote Lote Contábil do lançamento, cada módulo tem o seu e está configurado na tabela 09 do SX5
@param lMostra Verifica se mostra ou nao tela de contabilização
@param lAglutina Verifica se aglutina lançamentos com as mesmas entidades contábeis
@param aFlagCTB Array com as informações para a gravação do flag de contabilização do registro

@Return lRet Se executou ou não 
@author Brenno G. Curtolo
@since 25/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetLanCtb(nHdlPrv,nTotal,cArquivo, cLote,lMostra,lAglutina,aFlagCTB,dDataAnt)
Local lRet := .F.
Default dDataAnt := dDataBase

	If nHdlPrv > 0 .AND. ( nTotal > 0 )
		//<--- Função de fechamento do lançamento contabil --->			
		RodaProva(nHdlPrv, nTotal)

		//<---- Função de gravação do lote contabil	-->			
		lRet := cA100Incl(cArquivo,nHdlPrv,3,cLote,lMostra,lAglutina,,/*dData*/,,aFlagCTB)
	EndIF
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} VldQuebra
Valida de deve ter quebra ou não para efetuar o lançamento

@param cAlias 
@Return lQuebra .T. Or .F. define se deve conter a quebra ou não

@author Brenno G. Curtolo
@since 25/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldQuebra(cAlias, dDtQuebra)
Local cQuebra       := ""
Local lQuebra       := .F.
Local cData         := 'DATAL'
Local cDtFiltro     := ""
Local nContBxPor:= 3 //Caso não exista o pergunte MV_PAR04, a baixa será contabilizada pela Data Base

Default dDtQuebra   := cTod("")

	If Type("MV_PAR04") != "U" .And. !Empty(MV_PAR04)
		nContBxPor := MV_PAR04
	Endif
	
    cDtFiltro := (cAlias)->&(cData)

    If nContBxPor == 2 // Caixa
        cData := 'DATAVL'
        cDtFiltro := (cAlias)->&(cData)
        dDataBase := SToD(cDtFiltro)// Forço a alteração do database para o periodo que estou contabilizando

    ElseIf ((nContBxPor ==1) .Or. (MV_PAR03 == 3))//Competencia Ou DataBase 
            dDataBase := SToD(cDtFiltro)// Forço a alteração do database para o periodo que estou contabilizando
    EndIf
    
    If Empty(dDtQuebra)
        dDtQuebra := sTod(cDtFiltro)
    EndIf
    
    If nContBxPor != 3 .And. (dDtQuebra <> dDataBase)//Se for por Regime de competência ou de Caixa, é feita a quebra, obrigando a confirmar um lançamento por vez
        lQuebra := .T.
    ElseIf MV_PAR03 == 3 //<---  Quebra por Dia --->
        If Empty(cDtFiltro) .Or. (dDtQuebra <> dDataBase)
            lQuebra := .T.
        EndIf
    ElseIf MV_PAR03 == 2 //<--  Quebra por Documento --->
        If Empty( cDtFiltro )
            cQuebra := dToS(sToD(""))+(cAlias)->CAJURI+(cAlias)->CODLAN
            lQuebra := cQuebra <> Replicate( "0", 8 )+(cAlias)->CAJURI+(cAlias)->CODLAN
        Else 
            cQuebra := cDtFiltro + (cAlias)->CAJURI + (cAlias)->CODLAN
            lQuebra := cQuebra <> cDtFiltro + (cAlias)->CAJURI + (cAlias)->CODLAN
        EndIf
    EndIf
    
Return lQuebra
