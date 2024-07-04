#INCLUDE "Protheus.ch"
#INCLUDE "TMSA153G.CH"

/*/{Protheus.doc} TMSA153G
Geração de programação de carregamento via gestão de demandas
@author gustavo.baptista
@since 19/07/2018
@version 12.1.17
@type function
/*/
Function TMSA153G()

	Local cMarkPln	:= oBrwPlan:Mark()
	Local cQryPln 	:= GetNextAlias()
	Local cQryDmd 	:= GetNextAlias()
	Local cQuery 	:= ''
	Local aPlanej	:= {}
	Local aRet 		:= {}
	Local lRet		:= .T.
	Local nX 		:= 0
	Local nIndexDL8	:= DL8->(IndexOrd())
	Local nIndexDL9	:= DL9->(IndexOrd())
	Local aDL8Area := DL8->(GetArea())
	Local aDL9Area := DL9->(GetArea())

	//Query para verificar os registros marcados
	cQuery:= " SELECT DL9_FILIAL, DL9_COD"
	cQuery+= " FROM "+RetSqlName('DL9')+ " DL9 "
	cQuery+= " WHERE DL9.DL9_FILIAL = '" + xFilial('DL9') + "'"
	cQuery+= " AND DL9.DL9_MARK = '"+cMarkPln+"' "
	cQuery+= " AND DL9.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryPln, .F., .T. )				

	//Monta o array aPlanej e lock os planejamentos
	While (cQryPln)->(!EOF()) .AND. lRet 
		DL9->(DbSetOrder(1))
		If DL9->(DbSeek(xFilial('DL9') + (cQryPln)->(DL9_COD)) )
			aAdd(aPlanej, (cQryPln)->(DL9_COD))
		EndIf

		aRet := TMLockDmd("TMSA153B_" + (cQryPln)->DL9_FILIAL + (cQryPln)->DL9_COD)  //Verifica se registro encontra-se bloqueado por outro processo.	
		If !aRet[1]
			Help( ,, 'HELP',, aRet[2], 1, 0 )
			lRet := .F.
		EndIf

		(cQryPln)->(DbSkip())
	EndDo
	

	cQuery:= " SELECT DL8.DL8_COD,    "
	cQuery+= "        DL8.DL8_SEQ,    "
	cQuery+= "        DL8.DL8_CRTDMD, "
	cQuery+= "        DL7.DL7_STATUS, "
	cQuery+= "        DL9.DL9_STATUS, "
	cQuery+= "        DL9.DL9_FILEXE, "
	cQuery+= "        DL9.DL9_COD,    "
	cQuery+= "        DL9.DL9_CODVEI, "
	cQuery+= "        DL9.DL9_CODRB1, "
	cQuery+= "        DL9.DL9_CODRB2, "
	cQuery+= "        DL9.DL9_CODRB3, "
	cQuery+= "        DL9.DL9_CODMOT  "
	cQuery+= "   FROM "+RetSqlName('DL9')+ " DL9 "
	cQuery+= "        LEFT JOIN "+RetSqlName('DL8')+ " DL8  " 
	cQuery+= "               ON DL8.DL8_FILIAL = DL9.DL9_FILIAL " 
	cQuery+= "              AND DL8.DL8_PLNDMD = DL9.DL9_COD " 
	cQuery+= "              AND DL8.D_E_L_E_T_ = '' "
	cQuery+= "        LEFT JOIN "+RetSqlName('DL7')+ " DL7  " 
	cQuery+= "               ON DL8.DL8_FILIAL = DL7.DL7_FILIAL " 
	cQuery+= "              AND DL8.DL8_CRTDMD = DL7.DL7_COD " 
	cQuery+= "              AND DL7.D_E_L_E_T_ = '' "
	cQuery+= "   WHERE DL9.DL9_FILIAL = '" + xFilial('DL9') + "'" 
	cQuery+= "     AND DL9.DL9_MARK = '" + cMarkPln + "'" 
	cQuery+= "     AND DL9.D_E_L_E_T_ = '' "  
	cQuery := ChangeQuery(cQuery)   
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryDmd, .F., .T. )

	//Se possui planejamento marcado efetua as validações	
	If !Empty(aPlanej)
		lRet:= T153GVld(cQryDmd)
	Else
		Help( ,, 'HELP',,STR0001, 1, 0 ) //Selecione ao menos um planejamento
		lRet := .F.
	EndIf
	
	If lRet
		//Verifica se parametro da rotina de viagem está configurado com serviço adicional de coleta
		Pergunte('TMB144', .F.)
		If !(MV_PAR02 == "1")
			Help( ,, 'HELP',, STR0015, 1, 0,,,,,, {STR0016} )// "Rotina de viagem não está configurada para gerar serviço adicional de coleta" Acessar a rotina de viagem e na tela de parâmetros (F12) informar no parâmetro de serviço adicional o serviço de coleta
			lRet := .F.
		EndIf
		Pergunte('TMSA153', .F.)
	EndIf
		
	If lRet
		Processa( {|| T153GExec(aPlanej,cQryDmd) }, STR0008, STR0009,.F.) //Aguarde... - Carregando as metas...
	EndIf

	//Fecha a tabela temporaria
	(cQryPln)->(DbCloseArea())
	(cQryDmd)->(DbCloseArea())
	RestArea(aDL8Area)
	RestArea(aDL9Area)
	DL8->(DbSetOrder(nIndexDL8))
	DL9->(DbSetOrder(nIndexDL9))
Return lRet

/*/{Protheus.doc} T153GVld
Validações para gerar coletas e programação de carregamento
@author natalia.neves
@since 19/07/2018
@version 12.1.17
@param cMarkPln
@type function
/*/
Static Function T153GVld(cTemp)

	Local aAreaDUT := {}
	Local aAreaDA3 := {}
	Local aAreaDL9 := DL9->(GetArea())
	Local nIndexDL9 := DL9->(IndexOrd())
	Local cErro := ''
	Local lRet := .T.

 	If lRet
 		While !((cTemp)->(EOF()))
			DL9->(DbSetOrder(1))
			If DL9->(DbSeek(xFilial("DL9")+(cTemp)->DL9_COD))
				aAreaDA3 := DA3->(GetArea())
				
				If lRet .And. (cTemp)->DL9_FILEXE != cFilAnt
					cErro := STR0019 + (cTemp)->DL9_COD + STR0020 //Não é possivel gerar programação de carregamento para o planejamento: + (cTemp)->DL9_COD + pois a filial de execução do planejamento é diferente da filial atual.
					lRet := .F.
				EndIf
				
				If lRet .AND. !Empty((cTemp)->DL7_STATUS) .AND. (cTemp)->DL7_STATUS != '1'
					cErro := STR0004+"  "+ (cTemp)->DL9_COD +" "+ STR0017 +" "+ Alltrim(RetSX3Box(GetSX3Cache("DL7_STATUS","X3_CBOX"),,,1)[Val((cTemp)->DL7_STATUS)][3])  + "."//O planejamento 99999 possui uma ou mais demandas com contrato 9999. 				
					lRet := .F.
				EndIf 
				
				If lRet .AND. (cTemp)->DL9_STATUS != '2'
					cErro := STR0004 +" "+ (cTemp)->DL9_COD +" "+ STR0003 +" "+ Alltrim(RetSX3Box(GetSX3Cache("DL9_STATUS","X3_CBOX"),,,1)[Val((cTemp)->DL9_STATUS)][3]) + "." //O status do planejamento 999999 esta 99999.
					lRet := .F.
				EndIf
				
				If lRet
					DA3->(DbSetOrder(1))
					If DA3->(DbSeek(xFilial("DA3")+(cTemp)->DL9_CODVEI)) 
						aAreaDUT := DUT->(GetArea())
						DUT->(DbSetOrder(1))
						If DUT->(DbSeek(xFilial("DUT")+DA3->DA3_TIPVEI))
							If DUT->DUT_CATVEI == '2' .AND.  Empty((cTemp)->DL9_CODRB1) 
								cErro := STR0005  + (cTemp)->DL9_COD + "."  //O tipo de veículo Cavalo deve apresentar Reboque.
								lRet := .F.
							EndIf
							If !Empty((cTemp)->DL9_CODRB1) .AND. Empty((cTemp)->DL9_CODVEI)
								cErro := STR0006 + (cTemp)->DL9_COD + "."  //Para selecionar a categoria reboque, é necessário informar o tipo de veículo.
								lRet := .F.
							EndIf  
						EndIf
						RestArea(aAreaDUT)
					EndIf
				EndIf	 			
				
				If lRet .AND. Empty((cTemp)->DL9_CODMOT)
					cErro := STR0007 + (cTemp)->DL9_COD //É necessário informar um motorista no planejamento 99999.
					lRet := .F.
				EndIf
				
				If lRet
					aAreaDA3 := DA3->(GetArea())
					DA3->(DbSetOrder(1))
					If DA3->(DbSeek(xFilial('DA3')+(cTemp)->DL9_CODVEI))
						RecLock('DA3',.F.)
						DA3->DA3_MOTORI := (cTemp)->DL9_CODMOT
						MsUnlock()
					EndIf
				EndIf	
				
				If !lRet
					Help( ,, 'HELP',,cErro, 1, 0 )//Mensagem de erro de acordo com as validações acima
					Exit
				EndIf
				
				RestArea(aAreaDA3)
				
 			EndIf

			(cTemp)->(DbSkip())

 		Enddo	
	EndIf
 	
	RestArea(aAreaDL9)
	DL9->(DbSetOrder(nIndexDL9))
Return lRet

/*/{Protheus.doc} T153GExec
//Executa a o processamento dos dados para geração de coletas e programação de carregamento
@author gustavo.baptista
@since 23/07/2018
@version 1.0
@return ${return}, ${return_description}
@param aPlanej, array, descricao
@param cQryDmd, characters, descricao
@type Static Function
/*/
Static function T153GExec(aPlanej,cQryDmd)
	Local nIndexDL9 := DL9->(IndexOrd())
	Local aDL9Area	:= DL9->(GetArea())
	Local aErro		:= {}
	Local aOk		:= {}
	Local aVeiculos  := {}
	Local nCount	        := 0
	Local nX		:= 0
	Local lRetVlPl          := .T.
	Local lRet		:= .T.
	Local lFiltDL9	:= Len(oBrwPlan:FWFilter():GetFilter(.F.)) > 1 //Está usando filtro adicional no planejamento
	Local cMarkPln	:= oBrwPlan:Mark()
	Local cFiltDL9	:= DL9->(DbFilter()) 
	Local lTM153VLPL   := ExistBlock("TM153VLPL")
	
	
	nPosDL9 := oBrwPlan:At() 
		
	//Processa os planejamentos de demandas
	(cQryDmd)->(dbGoTop())

	While !((cQryDmd)->(EOF()))
		DL9->(DBSetOrder(1))
		If DL9->(DbSeek(xFilial("DL9")+(cQryDmd)->DL9_COD))
			nCount++
		EndIf
		
		(cQryDmd)->(dbSkip())
	EndDo

	ProcRegua(nCount+Len(aPlanej))

	For nX := 1 To Len(aPlanej)

		IncProc()

		If lTM153VLPL
			lRetVlPl := ExecBlock("TM153VLPL",.F.,.F.,{aPlanej[nX]})
			If ValType(lRetVlPl) == "L"
				If !lRetVlPl
					Loop
				EndIf
			EndIf
		EndIf

		BEGIN TRANSACTION
			//Gera as coletas
			lRet:= T153GProc(aPlanej[nX],@aErro)

			If lRet
				// Gera a programação	
				lRet := T153DMDPRG(aPlanej[nX])
				If lRet
					TmIncTrk('3', xFilial("DL9"), aPlanej[nX],/*cSeqDoc*/,/*cDocPai*/,'G',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,DF8->DF8_NUMPRG)
				Else
					//Preencher o aErro com o erro na geracao de programacao
					aAdd(aErro,{STR0014,00,''}) 
				EndIf
		   	EndIf

			If lRet
				//Atualiza saldo
				If T153AtuSld(aPlanej[nX])
					DL9->(DbSetOrder(1))
					If DL9->(DbSeek(xFilial("DL9")+aPlanej[nX]))
						//Atualiza o status e remove o mark do planejamento
						RecLock('DL9',.F.)
							DL9->DL9_STATUS := '6'
							DL9->DL9_MARK := ''
						MsUnlock()
						//Retira o lock dos planejamentos
						TMUnLockDmd("TMSA153B_" + DL9->DL9_FILIAL + DL9->DL9_COD,.T.)
					EndIf
				EndIf
			else
				DL9->(DbSetOrder(1))
				If DL9->(DbSeek(xFilial("DL9")+aPlanej[nX]))
					//Atualiza o status e remove o mark do planejamento
					RecLock('DL9',.F.)
						DL9->DL9_MARK := ''
					MsUnlock()
				EndIf
			EndIf

			Pergunte('TMSA1531', .F.)
	
			If lRet .AND. MV_PAR03 == 2
				AAdd( aVeiculos,DL9->DL9_CODVEI)
				AAdd( aVeiculos,DL9->DL9_CODRB1)
				AAdd( aVeiculos,DL9->DL9_CODRB2)
				AAdd( aVeiculos,DL9->DL9_CODRB3)
				lRet := TMSVldVei(aPlanej[nX],DF8->DF8_NUMPRG,,DL9->DL9_DATINI,DL9->DL9_HORINI,DL9->DL9_DATFIM,DL9->DL9_HORFIM,aVeiculos)
			ElseIf lRet .AND. MV_PAR03 == 1
				TClearFKey() 
				Processa( {|| lRet := TMSA146Eft() }, STR0008, STR0018 + aPlanej[nX] ,.F.) //Aguarde... - 'Efetivando programação do planejamento '...
			EndIf
		
			If !lRet
				Iif(!Empty(aErro),TmsMsgErr(aErro,STR0013),) //Inconsistências
				aSize(aErro,0)
				DisarmTransaction()
				Break
			Else
				If DF8->DF8_PLNDMD == aPlanej[nX]
					// garante que a tabela de programação vai estar posicionada no registro gerado pelo planejamento selecionado.
					aAdd(aOk,aPlanej[nX])
				EndIf
			EndIf
			aSize(aErro,0)
		END TRANSACTION

		If !lRet
			TClearFKey()
		EndIf
	Next nX


	Pergunte('TMSA1531', .F.)

	If Len(aOk)>0 .AND. MV_PAR02 == 1
		If lFiltDL9
			DL9->(DBClearFilter())
			DL9->(DBCloseArea())
		EndIf
		DL9->(DbSetOrder(1))
		For nX := 1 to Len(aOk)
			If DL9->(DbSeek(xFilial("DL9") + aOk[nX]))
				//Atualiza o status e remove o mark do planejamento
				RecLock('DL9',.F.)
					DL9->DL9_MARK := cMarkPln
				MsUnlock()
			EndIf
		Next nX
		
		TClearFKey()
		TMSA146()
		
		For nX := 1 to Len(aPlanej)
			If DL9->(DbSeek(xFilial("DL9") + aPlanej[nX]))
				//Atualiza o status e remove o mark do planejamento
				RecLock('DL9',.F.)
					DL9->DL9_MARK := ''
				MsUnlock()
			EndIf
		Next nX
	EndIf

	SetKey(VK_F5,{ ||TMA153Par(.F.)} )
	SetKey(VK_F12,{ ||Pergunte('TMSA1531', .T.), Pergunte('TMSA153', .F.)} )
	Pergunte('TMSA153',.F.)
	oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
	
	If lFiltDL9
		If !Empty( cFiltDL9 )
			Set Filter to &cFiltDL9
		EndIf	
		RestArea(aDL9Area)
		DL9->(DbSetOrder(nIndexDL9))
		DL9->(dbGoTop())
		oBrwPlan:Refresh(.T.)
	Else
		RestArea(aDL9Area)
		DL9->(DbSetOrder(nIndexDL9))
		oBrwPlan:GoTo(nPosDL9)
		oBrwPlan:Refresh()
	EndIf

Return lRet

/*/{Protheus.doc} T153GProc
Processa os planejamento gerando as coletas e programação de carregamento
@author ruan.salvador
@since 19/07/2018
@version 12.1.17
/*/
Static Function T153GProc(cCodPln,aErro)

	Local cTemp := GetNextAlias()
	Local cQuery := ''
	Local cCodSol := ''
	Local cAux1:= '' //Passa string não tabulada para o array aErro
	Local cAux2:= '' //Passa string tabulada para o array aErro
	Local lRet := .T.
	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local aAux:= {}
	Local nLin := {}
	Local nOpcx := 3
	Local ny:= 0
	
	PRIVATE lMsErroAuto := .F.
	
	cQuery := "  SELECT DL8.DL8_COD, "
	cQuery += "         DL8.DL8_SEQ, "
	cQuery += "         DL8.DL8_FILIAL, "
	cQuery += "         DL8.DL8_FILEXE, "
	cQuery += "         DL8.DL8_UM,     "
	cQuery += "         DL8.DL8_QTD,    "
	cQuery += "         DL8.DL8_CLIDEV, "
	cQuery += "         DL8.DL8_LOJDEV, "
	cQuery += "         DLA.DLA_DTPREV, "
	cQuery += "         DLA.DLA_HRPREV, "
	cQuery += "         DLA.DLA_CODREG, "
	cQuery += "         DLA.DLA_QTD,    "
	cQuery += "         DLA.DLA_CODCLI, "
	cQuery += "         DLA.DLA_LOJA    "
	cQuery += "    FROM " +RetSqlName('DL9')+ " DL9, "
	cQuery += "         " +RetSqlName('DL8')+ " DL8, "
	cQuery += "         " +RetSqlName('DLA')+ " DLA "
	cQuery += "   WHERE DL9.DL9_FILIAL = '" +  xFilial('DL9') + "'" 
	cQuery += "     AND DL9.DL9_COD = '" + cCodPln + "'" 
	cQuery += "     AND DL9.DL9_FILIAL = DL8.DL8_FILIAL " 
	cQuery += "     AND DL9.DL9_FILIAL = DLA.DLA_FILIAL " 
	cQuery += "     AND DL8.DL8_PLNDMD = DL9.DL9_COD "
	cQuery += "     AND DL8.DL8_COD = DLA.DLA_CODDMD "
	cQuery += "     AND DL8.DL8_SEQ = DLA.DLA_SEQDMD "
	cQuery += "     AND DL8.DL8_ORIDMD = '1' "
	cQuery += "     AND DL9.D_E_L_E_T_ = '' "  
	cQuery += "     AND DLA.D_E_L_E_T_ = '' "     
	cQuery += "     AND DL8.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
	
	While !(cTemp)->(Eof())
		cCodSol := TMSAF05DUE((cTemp)->DLA_CODCLI,(cTemp)->DLA_LOJA,'1')[1]
		IncProc()
		aCabec := T153GCab(cTemp, cCodSol)
	
		aLinha := T153GItemC(cTemp)
	
		AAdd(aItens, aLinha)
	
		MSExecAuto({|x,y| TMSA460(x,y)},aCabec,aItens)
		aCabec:={}
		aItens:={}
	
		If lMsErroAuto
			aAux:= MostraErro('Null')
			nLin:= mlcount(aAux)
  			cAux1 := STR0010 + ': '+Alltrim(cCodPln) +" "+ STR0011+" "+(cTemp)->DL8_COD +" " + STR0012+(cTemp)->DLA_CODREG + " --- " //'Planejamento: '+Alltrim(cCodPln) + ' Demanda:'+(cTemp)->DL8_COD + ' Região:'+(cTemp)->DLA_CODREG + " --- "
			cAux2 := STR0010 + ': '+Alltrim(cCodPln) +CHR(10)+ STR0011+': '+(cTemp)->DL8_COD + CHR(10) + STR0012+ ': ' +(cTemp)->DLA_CODREG + CHR(10) + " --- " //'Planejamento: '+Alltrim(cCodPln) + ' Demanda:'+(cTemp)->DL8_COD + ' Região:'+(cTemp)->DLA_CODREG + " --- "
			For ny:=1 to nLin
				cAux1 += memoline(aAux,40,ny) + " "
				cAux2 += memoline(aAux,,ny) + CHR(10)
			Next

			aAdd(aErro,{cAux1,00,'',cAux2})

			lRet := .F.
		EndIf
	
		lMsErroAuto := .F.
	
		(cTemp)->(DbSkip())
	EndDo

	(cTemp)->(DbCloseArea())  
    
Return lRet

/*/{Protheus.doc} T153GCab
Monta o Array com o Cabeçalho da Coleta
@author ruan.salvador
@since 19/07/2018
@version 12.1.17
@param cTemp - Tabela temporaria com as demandas e regiões de origem
@param cCodSol - Codigo do solicitante
/*/
Static Function T153GCab(cTemp, cCodSol)

	Local aCabec  := {}

	AAdd(aCabec,{"DT5_FILORI"   ,(cTemp)->DL8_FILEXE                  ,Nil})
	AAdd(aCabec,{"DT5_CODSOL"   ,cCodSol                              ,Nil})
	AAdd(aCabec,{"DT5_TIPCOL"   ,StrZero( 1, TAMSX3("DT5_TIPCOL")[1]) ,Nil})  
	AAdd(aCabec,{"DT5_STATUS"   ,StrZero( 1, TAMSX3("DT5_STATUS")[1]) ,Nil})  
	AAdd(aCabec,{"DT5_TIPTRA"   ,"1"                                  ,Nil})
	If (cTemp)->DLA_DTPREV != " "
		AAdd(aCabec,{"DT5_DATPRV"   ,STOD((cTemp)->DLA_DTPREV)        ,Nil})
		AAdd(aCabec,{"DT5_DATENT"   ,STOD((cTemp)->DLA_DTPREV)        ,Nil})
		If (cTemp)->DLA_HRPREV != " "
			AAdd(aCabec,{"DT5_HORPRV"   ,(cTemp)->DLA_HRPREV          ,Nil})
			AAdd(aCabec,{"DT5_HORENT"   ,(cTemp)->DLA_HRPREV          ,Nil})
		EndIf
	EndIf 
	AAdd(aCabec,{"DT5_CODDMD"   ,(cTemp)->DL8_COD                     ,Nil})
	AAdd(aCabec,{"DT5_SEQDMD"   ,(cTemp)->DL8_SEQ                     ,Nil})
	AAdd(aCabec,{"DT5_ORIDMD"   ,"1"                                  ,Nil})
	AAdd(aCabec,{"DT5_CLIREM"   ,(cTemp)->DL8_CLIDEV                  ,Nil})
	AAdd(aCabec,{"DT5_LOJREM"   ,(cTemp)->DL8_LOJDEV                  ,Nil})
	//-- A região de origem deve ser o último campo a ser preenchido e executado dentro do vetor, pois existem gatilhos
	//-- nos campos de cliente e loja do remetente, que fazem a alteração do campo de código da região de origem.
	//-- Esta ordem deve ser mantida, caso contrário a região de origem fica sempre igual a do solicitante.
	AAdd(aCabec,{"DT5_CDRORI"   ,(cTemp)->DLA_CODREG                  ,Nil})  
	  
Return aCabec

/*/{Protheus.doc} T153GItemC
Monta o Array com os itens da Coleta
@author ruan.salvador
@since 19/07/2018
@version 12.1.17
@param cTemp - Tabela temporaria com as demandas e regiões de origem
/*/
Static Function T153GItemC(cTemp)
	Local cCodProd := GetMv("MV_PROGEN",,'')
	Local aItem  := {}
	
	AAdd(aItem,{"DUM_ITEM"  ,"01"                      ,Nil})
	AAdd(aItem,{"DUM_CODPRO",cCodProd                  ,Nil})
	AAdd(aItem,{"DUM_CODEMB"," "                      ,Nil})
	AAdd(aItem,{"DUM_QTDVOL",1                         ,Nil})
	AAdd(aItem,{"DUM_PESO"  ,(cTemp)->DLA_QTD          ,Nil})
	AAdd(aItem,{"DUM_VALMER",0                         ,Nil})

Return aItem 

/*/{Protheus.doc} T153AtuSld
//Atualiza o saldo do contrato
@author gustavo.baptista
@since 20/07/2018
@version 12.1.17
/*/
Static Function T153AtuSld(cCodPln, aErro)
	Local cTemp := GetNextAlias()
	Local cQuery := ''
	Local aRet := {}
	Local lRet := .T.
	
	cQuery := "  SELECT DL8.DL8_QTD, 	"
	cQuery += "         DL8.DL8_CRTDMD, "
	cQuery += "         DL8.DL8_CODGRD, "
	cQuery += "         DL8.DL8_TIPVEI, "
	cQuery += "         DL8.DL8_SEQMET "
	cQuery += "   FROM  " +RetSqlName('DL8')+ " DL8 "
	cQuery += "   WHERE DL8.DL8_FILIAL = '" +  xFilial('DL8') + "'" 
	cQuery += "     AND DL8.DL8_PLNDMD = '" + cCodPln + "'" 
	cQuery += "     AND DL8.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
    
	While !(cTemp)->(Eof()) .AND. lRet
		If !Empty((cTemp)->DL8_CRTDMD) 
			aRet:= TMUpQtMDmd(xFilial('DL8'), (cTemp)->DL8_CRTDMD, (cTemp)->DL8_CODGRD, (cTemp)->DL8_TIPVEI, (cTemp)->DL8_SEQMET, (cTemp)->DL8_QTD, 5)
	    	lRet:= aRet[1]
	    	aErro:= aRet[2]
		EndIf
		(cTemp)->(DbSkip())
	EndDo

	(cTemp)->(DbCloseArea())  
    
Return lRet

/*/{Protheus.doc} PlnDmdTran
//Gerencia a transição dos Status do Planejamento a partir da saída da Viagem.
Em viagem -> Em transito -> Encerrado
Em viagem <- Em trânsito <- Encerrado
@author André Luiz Custódio
@since 27/07/2018
@version 12.1.17
/*/

Function PlnDmdTran(cCodPln,  cOpx)
	Local lRet    	 := .T.
	Local lAtuSta 	 := .F.
	Local aAreas  	 := {DL9->(GetArea()),GetArea()}	
	Local aInfPrgDmd := {}	
	Local cStatus 	 := ''
	Local cOldFilter := DL9->(dbFilter())

	DL9->(DbClearFilter())
	DL9->(DbCloseArea())
	DL9->(DbSetOrder(1))

	If DL9->(DbSeek(xFilial("DL9") + cCodPln)) 
		aInfPrgDmd := TmsPrgDmd(cCodPln)
		Do Case
			Case cOpx == '7' // Colocar Planajamento de Demandas em Trânsito ou estornar Encerramento
				lAtuSta :=  (DL9->DL9_STATUS == StrZero(3,Len(DL9->DL9_STATUS))) .Or. (DL9->DL9_STATUS == StrZero(4,Len(DL9->DL9_STATUS))) //Em viagem ou Encerrado
				cStatus := "7"
			Case cOpx == '3' //Estorno do status "Em Trânsito" ==> colocar "Em Viagem"
				lAtuSta :=  (DL9->DL9_STATUS == StrZero(7,Len(DL9->DL9_STATUS))) // Em Trânsito
				cStatus := "3"
			Case cOpx == '4' // Encerrar Planejamento
				lAtuSta :=  (DL9->DL9_STATUS == StrZero(7,Len(DL9->DL9_STATUS))) //  Em Trânsito
				cStatus := "4"		
		EndCase
	Else
		lRet := .F.
	EndIf	

  	If lAtuSta
  		Do Case
	  		Case cStatus == "7"
	  			TmIncTrk('3', DL9->DL9_FILIAL, DL9->DL9_COD,/*cSeqDoc*/,/*cDocPai*/,'Y',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,aInfPrgDmd[1][1],aInfPrgDmd[1][2])
	  		Case cStatus == "3"
	  			TmIncTrk('3', DL9->DL9_FILIAL, DL9->DL9_COD,/*cSeqDoc*/,/*cDocPai*/,'W',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,aInfPrgDmd[1][1],aInfPrgDmd[1][2])
	  		Case cStatus == "4"	
	  			TmIncTrk('3', DL9->DL9_FILIAL, DL9->DL9_COD,/*cSeqDoc*/,/*cDocPai*/,'E',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,aInfPrgDmd[1][1],aInfPrgDmd[1][2])
  		EndCase
		RecLock("DL9",.F.)
		DL9->DL9_STATUS := cStatus
		DL9->(MsUnlock())
	Else
		lRet := .F.
	EndIf

	If !Empty( cOldFilter )
		Set Filter to &cOldFilter
	EndIf	

	aEval(aAreas,{|x| RestArea(x)})	

Return lRet

/*/{Protheus.doc} TVgGetPlnD
//Retorna o código de um Planejamento de Demandas vinculado a uma Viagem / Programação de Carregamento.
@author André Luiz Custódio
@since 27/07/2018
@version 12.1.17
/*/
Function TVgGetPlnD(cFilOri,cViagem)
	Local cCodPln := ''
	Local cTemp   := GetNextAlias()
	
	If !Empty(cFilOri) .And. !Empty(cViagem) 

		cQuery := "  SELECT DISTINCT (DF8.DF8_PLNDMD) as DF8_PLNDMD	"
		cQuery += "    FROM  " +RetSqlName('DF8')+ " DF8 "
		cQuery += "   WHERE DF8.DF8_FILIAL = '" +  xFilial('DF8') + "'" 
		cQuery += "     AND DF8.DF8_FILORI = '" + cFilOri + "'" 
		cQuery += "     AND DF8.DF8_VIAGEM = '" + cViagem + "'" 		
		cQuery += "     AND DF8.DF8_STATUS = '2' "
		cQuery += "     AND DF8.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
	    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )

		cCodPln :=  (cTemp)->DF8_PLNDMD	

		(cTemp)->(DbCloseArea())  		
		
	EndIf	

Return cCodPln

