#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "OGC120B.CH"


Function OGC120B()
Return

/*{Protheus.doc} OGC120Chng
//Ação executada ao mudar a linha do Grid superior da tela de vincular/detalhe
@author marcos.wagner
@since 11/04/2018
@version 1
@type function
@param lChange, boolean, Sem uso
	   cAction, char, Indica o tipo de ação: 1 - Vincular, 2 - Desvincular, 3 - Detalhar, 4 - Compensar, 5 - Contato, 6 - Estorno Compensar
*/
Function OGC120Chng(cAction)
	
	Local cFiltrGrid := "1=1"
	Local cCodCli    := ""
	Local aAreaNJR      := NJR->(GetArea())

	Default cAction  := ""

	DbSelectArea("NJR")
	NJR->(DbSetOrder(1)) // NJR_FILIAL+NJR_CODCTR
	If NJR->(DbSeek(xFilial("NN7")+_cContrato))
	    cCodCli  := Posicione('NJ0',1,xFilial('NJ0')+NJR->NJR_CODENT+NJR->NJR_LOJENT,'NJ0_CODCLI')   
	EndIf

	If Valtype(oBrowse2) == "O" 
		If cAction == "1" // Vincular

			cFiltrGrid += " .AND. TIPO = 'PR' .AND. (_cAliaBrw2)->COD_CLIE == '"+cCodCli+"' "
		ElseIf cAction == "2" //Desvincular				
			cFiltrGrid += " .AND. TIPO = 'PR' .AND. (_cAliaBrw2)->COD_CLIE == '"+cCodCli+"' " + " .AND. " + ;
						"( alltrim(CHAVESE1) = '"+ AllTrim((_cAliaBrw1)->(TIPO+'/'+PREFIXO+'/'+NUMERO+'/'+PARCELA+'/'+FILIAL))+"')"									

        ElseIf cAction == "4"
            cFiltrGrid += " .AND. TIPO = 'NF'"
        EndIf

		If Len(oBrowse2:aLegends) > 0
			oBrowse2:aLegends[1][2]:aLegend[2][1] := "AllTrim((_cAliaBrw2)->CHAVESE1) =  '"+AllTrim((_cAliaBrw1)->(TIPO+'/'+PREFIXO+'/'+NUMERO+'/'+PARCELA+'/'+FILIAL))+"'"	
			oBrowse2:aLegends[1][2]:aLegend[3][1] := "AllTrim((_cAliaBrw2)->CHAVESE1) <> '"+AllTrim((_cAliaBrw1)->(TIPO+'/'+PREFIXO+'/'+NUMERO+'/'+PARCELA+'/'+FILIAL))+"'"
		EndIf

		oBrowse2:SetFilterDefault( cFiltrGrid )
	EndIf

	RestArea(aAreaNJR)
Return

/*{Protheus.doc} OGC120BGRV
//Grava os dados da tabela temporária na tabela N9G, com o relacionamento do titulo de RA x PV
@author marcelo.ferrari / Marcos.wagner
@since 11/04/2018
@version 1
@type function
@Param cAction, char, indica a ação 1: Vincular / 2:Desvincular / 3: Detalhar / 4:Compensar / 6:Estorno Compensar
*/
Function OGC120BGRV(cAction)
	
    Local lRet      := .T.
	Local aArea     := GetArea()
	Local cMsg      := ""
	Default cAction := ""

	If !(MsgYesNo(STR0008))
		lRet := .F.
		return lRet
    Else
        If cAction $ "1|2" // Vincular | Desvincular
            Iif(cAction == "1", cMsg := STR0030, cMsg := STR0031)  //Realizando vínculo... //Removendo vínculo...
			MsgRun( cMsg, STR0034, {|| lRet := OGC120CGRV(cAction) } ) // AGUARDE        
        EndIf
	EndIf

	//Atualizar os valores financeiros no contrato - DAGROCOM-3521
	If lRet
		(_cAliaBrw2)->(dbGoTop())
		While (_cAliaBrw2)->(!eof())
			If !Empty((_cAliaBrw2)->CHAVESE1)
				OGX310(2,(_cAliaBrw2)->NJR_CODCTR)
			EndIf
			(_cAliaBrw2)->(dbSkip())
		EndDo
	EndIf

    RestArea(aArea)
	
Return lRet

/*{Protheus.doc} OGC120DBCL
//Função do duplo click utilizada no browse inferior da tela de [des]Vincular/Detalhe
@author marcos.wagner
@since 11/04/2018
@version 1
@type function
@Params lConfirma, boolean, Indica se deve exibir ou não a mensage de confirmação
        cAction, char, indica a ação 1: Vincular / 2: Desvincular / 3: Detalhar / 4: Compensar / 5: Contato / 6: Estorno Compensar
*/
Function OGC120DBCL( lConfirma, cAction )
    Local lJaMarcada    := .f.
    Local aTempArea     := (_cAliaBrw1)->(GetArea())
    Local aTempArea2    := (_cAliaBrw2)->(GetArea())
    Local nE1_VALOR     := 0
    Local cChvBrw2      := ""
    Local cValVin       := ""
    Local aAreaBrw1     := {}
    Local aAreaBrw2     := {}
    Local aChave        := {}

	Default lConfirma := .T.
	Default cAction   := ""
	
	If "1|2" $cAction 
		If fPrevEnvto()
			Help( , , STR0027, , STR0028, 1, 0, ,,,,,{STR0029} ) //Vínculo não permitido. Previsão financeira definida por evento (Data de Faturamento ou Data de Chegada). //"Para esse tipo de previsão financeira, apenas as previsões por evento geradas a partir dela podem ser vinculadas."		
			Return
		EndIf
	EndIf

	If (_cAliaBrw1)->(Eof())
		Help( ,, STR0027,,STR0035, 1, 0 ) //"Ajuda" ### "Não há nenhuma RA disponível!" 
		Return
	EndIf

	If cAction == "1" .and. !IsInCallStack("OGC120MKCL")
		nE1_VALOR     := (_cAliaBrw2)->PSOMAPVRA
	EndIf

    // ##### VINCULO DE PREVISOES JA VINCULADAS A UMA RA E QUE FOI SELECIONADO PARA VINCULAR COM OUTRA RA #####
	If !Empty((_cAliaBrw2)->CHAVESE1) .AND. (AllTrim((_cAliaBrw2)->CHAVESE1) <> AllTrim((_cAliaBrw1)->(TIPO+'/'+PREFIXO+'/'+NUMERO+'/'+PARCELA+'/'+FILIAL)))

		If IsInCallStack("OGC120MKCL")
			//Quando o registro estiver marcado para outra RA não altera a marcação
			Return
		EndIf

		lJaMarcada := (_cAliaBrw2)->MARK  == "1"

		If lConfirma
			If !MsgYesNo(STR0021) //"A PR selecionada já está alocada para outra AR! Deseja desvincular e alocar na atual?"
				Return
			EndIf
		EndIf		

        nE1_VALOR := OGC120CPAR() // Funcao de tratamento do valor parcial a ser vinculado entre Ra x Pr, a funcao tambem valida as quantidades e retorna o valor informado pelo usuario

        If nE1_VALOR == 0 // Se igual a zero ou cancelou a acao de informar o valor, entao retorna sem acao
            RestArea(aTempArea)
            RestArea(aTempArea2)
            Return
        EndIf

		If cAction == "2" .and. Empty((_cAliaBrw2)->MARK)			
			
			//### Manipulação dos dados do Grid Superior - RA
			If RecLock((_cAliaBrw1),.F.)
				(_cAliaBrw1)->SOMAPVRA -= nE1_VALOR				
				(_cAliaBrw1)->(MsUnlock())
			EndIf
			(_cAliaBrw1)->(MsUnlock())
		
        Else

            aChave := Separa( (_cAliaBrw2)->CHAVESE1, "/")
            cChvBrw2 := aChave[1] + aChave[2] + aChave[3] + aChave[4] // Chave de vinculo da previsao posicionada com a RA ja gravada
            
            aAreaBrw1 := (_cAliaBrw1)->(GetArea())
            aAreaBrw2 := (_cAliaBrw2)->(GetArea())
            
            (_cAliaBrw1)->(dbSetOrder(4))
            (_cAliaBrw1)->(dbGoTop()) // Como ja existe um vinculo entre Ra x Pr posicionada, entao procura a Ra pertencente e estorna o vinculo
            If (_cAliaBrw1)->(dbSeek(cChvBrw2)) .AND. RecLock((_cAliaBrw1),.F.) // Procura a chave pertencente para manipular os saldos        
                cValVin  := (_cAliaBrw2)->PSOMAPVRA // Valor ja vinculado a previsao
                
                (_cAliaBrw1)->PSOMAPVRA -= cValVin				
                (_cAliaBrw1)->(MsUnlock()) 
            EndIf

            RestArea(aAreaBrw1) // Reposiciona o Alias
            RestArea(aAreaBrw2) // Reposiciona o Alias

            //### Manipulação dos dados do Grid Superior - RA
			If RecLock((_cAliaBrw1),.F.)
				(_cAliaBrw1)->PSOMAPVRA += nE1_VALOR				
				(_cAliaBrw1)->(MsUnlock())
			EndIf

            //### Manipulação dos dados do Grid Inferior- PR
            If (_cAliaBrw2)->MARK == "1" .AND. RecLock((_cAliaBrw2),.F.)
                If nE1_VALOR > (_cAliaBrw2)->PSOMAPVRA // Se o valor a ser alocado for maior que o vinculado                    
                    (_cAliaBrw2)->PSOMAPVRA := nE1_VALOR
                Else                    
                    (_cAliaBrw2)->PSOMAPVRA := nE1_VALOR
                EndIf
				
				(_cAliaBrw2)->(MsUnlock())
			EndIf
		EndIf

	Else //Caso contrário só adiciona ou subtrai da atual            
			If RecLock((_cAliaBrw1),.F.) .AND. RecLock((_cAliaBrw2),.F.) 					
                If cAction == "4" 
					nE1_VALOR     := (_cAliaBrw2)->SALDO
					If Empty((_cAliaBrw2)->MARK)
						(_cAliaBrw1)->PSOMAPVRA += nE1_VALOR
						
						(_cAliaBrw2)->PSOMAPVRA += nE1_VALOR    						

					Else
						(_cAliaBrw1)->PSOMAPVRA -= nE1_VALOR						

						(_cAliaBrw2)->PSOMAPVRA -= nE1_VALOR    					

					EndIf

                ElseIf cAction == "6" 
					nE1_VALOR     := (_cAliaBrw2)->VL_COMPEN
					If Empty((_cAliaBrw2)->MARK)
						(_cAliaBrw1)->PSOMAPVRA += nE1_VALOR						

						(_cAliaBrw2)->PSOMAPVRA += nE1_VALOR    						

					Else
						(_cAliaBrw1)->PSOMAPVRA -= nE1_VALOR						

						(_cAliaBrw2)->PSOMAPVRA -= nE1_VALOR    						

					EndIf

                ElseIf cAction == "1" 
                    If (_cAliaBrw2)->MARK == "1"
                        // Alocacao - RA					                        
                        (_cAliaBrw1)->PSOMAPVRA -= (_cAliaBrw2)->PSOMAPVRA 

                        // Alocacao - PR                        
                        (_cAliaBrw2)->PSOMAPVRA := 0
                    Else
                        nE1_VALOR := OGC120CPAR() // Funcao de tratamento do valor parcial a ser vinculado entre Ra x Pr, a funcao tambem valida as quantidades e retorna o valor informado pelo usuario

                        If nE1_VALOR == 0 // Se igual a zero ou cancelou a acao de informar o valor, entao retorna sem acao
                            RestArea(aTempArea)
                            RestArea(aTempArea2)
                            Return
                        EndIf
                        // Alocacao - RA					                        
                        (_cAliaBrw1)->PSOMAPVRA +=  nE1_VALOR

                        // Alocacao - PR                        
                        (_cAliaBrw2)->PSOMAPVRA += nE1_VALOR
                    EndIf
				EndIf
			EndIf
		(_cAliaBrw1)->(MsUnlock())
		(_cAliaBrw2)->(MsUnlock())
	EndIf

	//### Manipulação dos dados do Grid Inferior - PR
	If RecLock((_cAliaBrw2), .F.)
		If cAction == "2"
			(_cAliaBrw2)->MARK = IIF((_cAliaBrw2)->MARK  == "1", "", "1")
		Else
			If !lJaMarcada //Se ele já foi vinculado a outra RA, não deverá alterar a marcação
				(_cAliaBrw2)->MARK = IIF((_cAliaBrw2)->MARK  == "1", "", "1")
			EndIf
		
			If (_cAliaBrw2)->MARK == '1'
				(_cAliaBrw2)->CHAVESE1 := (_cAliaBrw1)->(TIPO+'/'+PREFIXO+'/'+NUMERO+'/'+PARCELA+'/'+FILIAL+'/'+LOJA)
			Else
				(_cAliaBrw2)->CHAVESE1 := Space(Len((_cAliaBrw2)->CHAVESE1))
			EndIf		
		EndIf
		(_cAliaBrw2)->(MsUnlock())

	Endif

	RestArea(aTempArea)
	RestArea(aTempArea2)
	oBrowse1:Refresh()	
	oBrowse2:Refresh()

Return

/*{Protheus.doc} OGC120MKCL
//Função para Marcar/Desmarcar Todos os itens do Grid de detalhe da funcão de [des]vincular
@author marcelo.ferrari / Marcos.wagner
@since 11/04/2018
@version 1
@type function
*/
Function OGC120MKCL()

	Local nRec := oBrowse2:At()	

	(_cAliaBrw2)->(DbGoTop())
	While !(_cAliaBrw2)->(Eof())
		If _lMarca
			If (_cAliaBrw2)->MARK  != "1"  //Está Desmarcado e deve marcar
				OGC120DBCL( .F. )
			EndIf
		Else
			If (_cAliaBrw2)->MARK  == "1"  //Esta marcado e deve desmarcar
				OGC120DBCL( .F. )
			EndIf
		EndIf	
		(_cAliaBrw2)->(dbSkip())
	EndDo
	_lMarca := !_lMarca
	oBrowse2:Refresh()
	oBrowse2:Goto(nRec, .T.)

Return


/*{Protheus.doc} OGC120BFTR
//Monta o filtro do primeiro browse da tela de Detalhar
@author marcos.wagner
@since 25/04/2018
@version 1
@type function
*/
Function OGC120BFTR()

    Local cFiltrGrid := ''
    Local cTipsTit   := SuperGetMv("MV_AGRO023", .F., "")

    Pergunte("OGC12002", .f.)

	cFiltrGrid := "1=1"
	If MV_PAR01 == 1 .AND. aScan(_oOGC120RE:oStruct:aFields, {|x| AllTrim(x[1]) = AllTrim("FILIAL") })
		cFiltrGrid += " .AND. FILIAL = '" + (&cAliasBrw)->FILIAL + "'"
	EndIf
	
	//Cliente
	If MV_PAR02 == 1 .AND. aScan(_oOGC120RE:oStruct:aFields, {|x| AllTrim(x[1]) = AllTrim("COD_CLIE") })
		cFiltrGrid += " .AND. COD_CLIE = '" + (&cAliasBrw)->COD_CLIE + "'"
	EndIf

	//Loja
	If MV_PAR03 == 1 .AND. aScan(_oOGC120RE:oStruct:aFields, {|x| AllTrim(x[1]) = AllTrim("LOJA") })
		cFiltrGrid += " .AND. LOJA = '" + (&cAliasBrw)->LOJA + "'"
	EndIf

	//Data de Vencimento	
	If MV_PAR05 == 1 .AND. aScan(_oOGC120RE:oStruct:aFields, {|x| AllTrim(x[1]) = AllTrim("VENCIMENTO") })
		If alltrim((&cAliasBrw)->TIPO) == "PR" .OR. alltrim((&cAliasBrw)->TIPO) $ cTipsTit 
			cFiltrGrid += " .AND. DTOS(VENCIMENTO) = '" + DTOS((&cAliasBrw)->VENCIMENTO) + "'"
		Else
			cFiltrGrid += " .AND. DTOS(VENCIMENTO) = '" + DTOS((_cAliaBrw1)->VENCIMENTO) + "'"
		EndIf
	EndIf

	//Moeda
	If MV_PAR06 == 1 .AND. aScan(_oOGC120RE:oStruct:aFields, {|x| AllTrim(x[1]) = AllTrim("MOEDA") })
		cFiltrGrid += " .AND. MOEDA = " + AllTrim(Str((&cAliasBrw)->MOEDA))
	EndIf
	
	//Documento
	
	If (MV_PAR07 == 1 .OR. oTFolder:nOption == 2) .AND. aScan(_oOGC120RE:oStruct:aFields, {|x| AllTrim(x[1]) = AllTrim("NUMERO") })
		cFiltrGrid += " .AND. AllTrim("
		If MV_PAR01 == 1
			cFiltrGrid += "(_cAliaBrw1)->(FILIAL)+" 
		EndIf
		If ALLTRIM((&cAliasBrw)->TIPO) $ cTipsTit
			cFiltrGrid += " (_cAliaBrw1)->(NUMERO+PARCELA+TIPO+PREFIXO)) = '" + AllTrim((&cAliasBrw)->(FILIAL+NUMERO+PARCELA+TIPO+PREFIXO))+"'"
		Else
			cFiltrGrid += " (_cAliaBrw1)->(NUMERO+PARCELA+TIPO+PREFIXO)) = '" + AllTrim((&cAliasBrw)->(FILIAL+NUMERO+PARCELA+PADR("PR",TamSX3("E1_TIPO" )[1])+PREFIXO)) +"'"
		EndIf
	EndIf
	

Return cFiltrGrid

//-------------------------------------------------------------------
/*/{Protheus.doc} OGC120BREC
Função responsável por chamar o recálculo das previsões
@author  marcos.wagner
@since   15/05/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGC120BREC()

	Local nQtdDias   := 0 
	Local cDirLog    := '' //Sempre branco, só é utilizado quando chamado por Job
	Local cFilialIni := ''
	Local cFilialFin := ''
	Local cCtrIni    := ''
	Local cCtrFim    := ''
	Local cEntidIni  := ''
	Local cEntidFim  := ''
	Local cLojaIni   := ''
	Local cLojaFim   := ''
	Local cProdIni   := ''
	Local cProdFim   := ''
	Local cSafraIni  := ''
	Local cSafraFim  := ''
	Local cMsg       := ''
	Local aAreaNJR   := NJR->(GetArea())

	dbSelectArea("NJR")
	dbSetOrder(1)
	If dbSeek(FwxFilial("NJR")+NN7->NN7_CODCTR)
		If NJR->NJR_TIPMER <> '1' .OR. NJR->NJR_MOEDA == 1
			cMsg := STR0024 + CHR(13)+CHR(10)+; //"Só é possível recalcular contratos de mercado interno e em moeda estrangeira."
					STR0025 + X3CboxDesc( "NJR_TIPMER", NJR->( NJR_TIPMER ) ) +CHR(13)+CHR(10)+; //"Tipo Mercado: "
					STR0026 + AllTrim(Str(NJR->NJR_MOEDA)) //"Moeda: "
			Help( ,, STR0027,,cMsg, 1, 0 ) //"Ajuda"
			Return .t.
		EndIf
	EndIf
	
	cFilialIni := FwxFilial("NJR")
	
	cCtrIni   := NN7->NN7_CODCTR
	
	cEntidIni := NJR->NJR_CODENT
	
	cLojaIni  := NJR->NJR_LOJENT   
	
	cProdIni  := NJR->NJR_CODPRO
	
	cSafraIni := NJR->NJR_CODSAF	

	OGX065PROC(nQtdDias, cDirLog, cFilialIni, cFilialFin, cCtrIni, cCtrFim, cEntidIni, cEntidFim, cLojaIni, cLojaFim, cProdIni, cProdFim, cSafraIni, cSafraFim)

	RestArea(aAreaNJR)
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} fPrevEnvto
Função para verificar se a previsão principal é por evento
@author  rafael.voltz
@since   12/07/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function fPrevEnvto()
	Local cAliasQry := GetNextAlias()
	Local lRet      := .F.

	BeginSQL Alias cAliasQry
		SELECT DISTINCT 1 EVENTO
		  FROM %table:NN7% NN7
		 INNER JOIN %table:N9J% N9J ON N9J_FILIAL = NN7_FILIAL AND N9J_CODCTR = NN7_CODCTR AND N9J_SEQPF  = NN7_ITEM  AND N9J.%notDel%
		 INNER JOIN %table:N84% N84 ON N84_FILIAL = N9J_FILIAL AND N84_CODCTR = N9J_CODCTR AND N84_SEQUEN = N9J_SEQCP AND N84.%notDel%
	   WHERE NN7_FILIAL = %xFilial:NN7%
		 AND NN7_CODCTR = %Exp:(_cAliaBrw2)->N9K_CODCTR%
		 AND NN7_ITEM   = %Exp:(_cAliaBrw2)->N9K_SEQPF%
		 AND NN7_TIPEVE != '1'
		 AND NN7.%notDel%
		 AND N84_REFCTR  IN ('1', '4')
	EndSQL

	If (cAliasQry)->EVENTO == 1
		lRet := .T.
	EndIf

	(cAliasQry)->(dbCloseArea())
	
Return lRet

/*{Protheus.doc} OGC120BTMP
//Função que monta e popula a tabela temporária.
@type function
@param cQuery, characters, Query que fará a carga de dados para a tabela temporaria
       cAliasBrw, character, Nome do Alias a carregar os dados
	   aFields, Array, estrutura dos campos de dados
@return ${return}, ${Alias da Tabela Temporaria}
@author Marcos Wagner / Marcelo Ferrari
@since09/04/2018
@version 1.0
*/
Function OGC120BTMP(cQuery, cAliaBrw, aFields)

	Local cAliasQry := GetNextAlias() // Obtem o proximo alias disponivel, tabela query
	Local nIt		:= 0
	Local cQryTmp 	:= ChangeQuery( cQuery )
	Local aStruct	:= {}
	
	If Select(cAliaBrw) > 0 // Caso a tabela existir e estiver populada, refaz a mesma
		(cAliaBrw)->(dBGoTop())
		If !(cAliaBrw)->(Eof())
			If RecLock((cAliaBrw), .F.)
				ZAP
				(cAliaBrw)->(MsUnlock())
			EndIf
		EndIf
	EndIf
	
	// ############### Populando a tabela temporária que será utilizada no browse ##################
	If Select(cAliasQry) > 0 // Se o alias estiver aberto, fecha o alias
		(cAliasQry)->( dbCloseArea() )
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryTmp ), cAliasQry, .F., .T. ) // Executa a query
	aStruct := (cAliasQry)->(dBStruct()) // Obtém a estrutura da tabela query
	
	Do While !(cAliasQry)->(Eof()) // Popula a tabela temporária
		RecLock((cAliaBrw),.T.)
			For nIt := 1 To Len(aFields)
				If aScan(aStruct, {|x| AllTrim(x[1]) == AllTrim(aFields[nIt][1]) }) > 0 // Verifica se o campo existe, para popular a tabela temporária
					(cAliaBrw)->&(aFields[nIt][1])	:= OGC120TRT((cAliasQry)->&(aFields[nIt][1]), aFields[nIt][2])				
                EndIf		
                
                If aFields[nIt][1] == "NN7_CONTOB"                                      
                    If aScan(aStruct, {|x| AllTrim(x[1]) == "TIPO" })
                        If ValType((cAliasQry)->TIPO) != "U"
                            LoadContat(cAliasQry, cAliaBrw)                
                        EndIf                
                    EndIf
                EndIf
			Next nIt
		MsUnlock()
		(cAliasQry)->(dbSkip())
	EndDo
	
	(cAliaBrw)->(dbGoTop()) // Posiciona no topo
	(cAliasQry)->(dbCloseArea())

	//FWFreeObj (aStruct)
	
Return cAliaBrw


/*{Protheus.doc} OGC120TRT
//Converte valores de campos especificos para caracter.
@author Marcos Wagner / Marcelo Ferrari
@since 09/04/2018
@version 1
@param xValor: Valor do campo
@param cType:  Tipo do campo
@type function
*/
Static Function OGC120TRT(xValor, cType)

	Local cValCmp 	:= ""
	
	Default xValor 	:= Nil
	Default cType   := ""
	
	If .NOT. Empty(cType) // Trata valores do alias query
	
		Do Case
	        Case cType == "N"
	            cValCmp := xValor
	        Case cType == "M"
	            cValCmp := xValor
	        Case cType == "D"
	            cValCmp := STOD(xValor)
	        Case cType == "L"
	            If AllTrim(xValor) == "T"
	                cValCmp := .T.// # verdadeiro
	            Else
	                cValCmp := .F. // # falso
	            EndIf
	        Case cType == "C"
	            cValCmp := xValor
	    EndCase
	    
	ElseIf xValor != Nil // Trata valores do parse html
	
	    Do Case
	        Case ValType(xValor) == "N"
	            cValCmp := cValToChar(xValor)
	        Case ValType(xValor) == "M"
	            cValCmp := xValor
	        Case ValType(xValor) == "D"
	            cValCmp := DTOC(xValor)
	        Case ValType(xValor) == "C"
	            If AllTrim(xValor) == "T"
	                cValCmp := "Verdadeiro" // # verdadeiro
	            ElseIf AllTrim(xValor) == "F"
	                cValCmp := "Falso" // # falso
	            Else
	            	cValCmp := xValor
	            EndIf   
	    EndCase
	    
	EndIf

Return cValCmp

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadContat
Busca dados do contato
@author  rafael.voltz
@since   14/06/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function LoadContat(cAliasQry, cAliaBrw)
    Local aAreaNN7 := NN7->(GetArea())
    Local aAreaN9K := N9K->(GetArea())    
    
    If alltrim((cAliasQry)->TIPO) == 'PR'
        NN7->(DbSetOrder(1))
        If NN7->(DbSeek(xFilial("NN7") + (cAliasQry)->NJR_CODCTR + (cAliasQry)->NN7_ITEM))
            (cAliaBrw)->NN7_CONTOB := NN7->NN7_CONTOB
            (cAliaBrw)->NN7_CONTST := NN7->NN7_CONTST
        EndIf
    Else
        N9K->(DbSetOrder(3))
        If N9K->(dbSeek((cAliasQry)->FILIAL + (cAliasQry)->NJR_CODCTR + (cAliasQry)->NN7_ITEM))
            (cAliaBrw)->NN7_CONTOB := N9K->N9K_CONTOB
            (cAliaBrw)->NN7_CONTST := N9K->N9K_CONTST
        EndIf
    EndIf

    RestArea(aAreaNN7)
    RestArea(aAreaN9K)

    FWFreeObj(aAreaNN7)
    FWFreeObj(aAreaN9K)

Return nil
