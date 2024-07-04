#INCLUDE "Protheus.ch"
#INCLUDE "AGRXCTR.CH"
#INCLUDE "fwMvcDef.ch"
#INCLUDE "FWEditPanel.ch"

#DEFINE FLDALGODAO 		STR0021		// Id Folder Algodão 
#DEFINE FLDPRINCIP 		STR0022		// Id Folder Principal

Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
Static __lNGraPrevF := SuperGetMV( "MV_AGRPREV", .f., .f. ) //padrão do parametro é sempre .f. se nao existir - .f. gera previsao financeira - .t. nao gera previsao financeira
Static __lnewComerc	:= SuperGetMv('MV_AGRA001', , .F.) // Parametro de utilização do novo conceito de utilização do UBA
Static __lAutomato  := IsBlind() //automação
Static __lRegOpcional  := SuperGetMv('MV_AGRO040', , .F.) 
/** {Protheus.doc} AGRXVLTAB
Função que valida o campo da tabela de descontos utilizada no contrato

@param:     Nil
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     20/06/2019
@Uso:       OGA290, OGA280 - Contratos
*/

Function AGRXVLTAB(oModelNJR, cTabela)
	Local lRetorno  := .t.
	Local cCodPro   := oModelNJR:GetValue( "NJR_CODPRO" )
	Local cGrupo    := ""

	IF !Empty(cTabela)
		dbSelectArea( "NNI" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "NNI" ) + cTabela ) .AND. .NOT. AGRTPALGOD(cCodPro)
			//para o campo de cod. do produto preenchido
			If !Empty(NNI->( NNI_CODPRO ))              
				If NNI->( NNI_CODPRO ) <> cCodPro
					If !Empty(cCodPro) 
						Help( , , STR0001, , STR0002, 1, 0 )	//"AJUDA"###"Tabela nao cadastrada para este produto."
						lRetorno := .f.
					ElseIf Empty(cCodPro)
						Help( , , STR0001, , STR0003, 1, 0 ) 	//"AJUDA"###"Informar produto compatível com a tabela selecionada."
						lRetorno := .f.
						Return( lRetorno )                  
					EndIf                           
				Else
					If ( NNI->( NNI_DATINI ) > dDataBase .Or. NNI->( NNI_DATFIM ) < dDataBase )
						Help( , , STR0001, , STR0004, 1, 0 )    //"AJUDA"###"Tabela fora da validade."
						lRetorno := .f.
					EndIf
				EndIf
				//para o campo de cod. do produto vazio
			ElseIf Empty(NNI->( NNI_CODPRO ))
				//verifica na tabela de produto pelo grupo se o grupo é existente
				//se grupo não existir apresenta mensagem para informar o grupo         
				If AGRIFDBSEEK("SB1",cCodPro,1,.F.)
					cGrupo := SB1->( B1_GRUPO )
					If NNI->( NNI_PRODGR ) <> cGrupo 
						Help( , , STR0001, , STR0005, 1, 0 ) 	//"Produto não faz parte do grupo da tabela selecionada. Informar produto compatível com a tabela selecionada."#"AJUDA"
						lRetorno := .F.
					ElseIf ( NNI->( NNI_DATINI ) > dDataBase .Or. NNI->( NNI_DATFIM ) < dDataBase )
						Help( , , STR0001, , STR0004, 1, 0 )    //"AJUDA"###"Tabela fora da validade."
						lRetorno := .f.
					EndIf
				Else
					//se produto for vazio, não permitir tabela
					If Empty(cCodPro)
						Help( , , STR0001, , STR0003, 1, 0 ) 	//"AJUDA"###"Informar produto compatível com a tabela selecionada."
						lRetorno := .f.
						Return( lRetorno )
					EndIf                   
				EndIf
			EndIf 
		ElseIf .NOT. AGRTPALGOD(cCodPro)
			Help( , , STR0001, , STR0006, 1, 0 )  //"AJUDA"###"Tabela nao cadastrada."
			lRetorno := .f.
		EndIf
	EndIF
Return( lRetorno )

/** {Protheus.doc} AGRXCODPRO
Função que Valida o produto, Verifica se é um Produto Valido e se o mesmo possui
UM. de Preço Cadastrada.
@param:   Produto
Retorno:  .t. ou .f. Indicando que o produto está ok.
@author: 	Emerson Coelho
@since: 	02/10/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRXCODPRO(oModelNJR,cProduto,cTabela)
	Local cUmPreco  := AgrUmPrc ( cProduto )
	Local lRet      := .t.
	Local oView     := FwViewActive()

	If AGRTPALGOD(cProduto)
		oModelNJR:LoadValue("NJR_TABELA" , "")
	EndIf

	If !Empty(cProduto)
        IF ! ExistCpo('SB1', cProduto )
            Help( , , STR0001, , STR0019, 1, 0 ) //"AJUDA"###"Produto nao cadastrado."
            lRet :=.f.
        ElseIF Empty(cUmPreco)
            Help( , , STR0001, , STR0020, 1, 0 ) //"AJUDA"###"Produto nao possui UM.Preço."
            lRet := .f.
        ElseIf !Empty(cProduto) .and. !Empty(cTabela) // Validando o produto contra Tabela de Classif.
            lRet := AGRXVLTAB(oModelNJR,cTabela)
		ElseIf	ValType(oView) != 'U' .AND. __lnewNeg .And. !__lRegOpcional// Validação para Habilitar a Aba de algodao dependendo o produto inserido
			If  lValProd := Iif(.NOT.Empty(cProduto), AGRTPALGOD(cProduto),.F.) // Verifica o tipo de comodities do produto
				oView:SelectFolder('CTRFOLDER', FLDALGODAO, 2) // Habilita a aba Algodão
				oView:SelectFolder('CTRFOLDER', FLDPRINCIP, 2) // Seleciona de volta a aba Principal
			ElseIf __lnewNeg // Remove da view a aba algodão caso o produto não atenda ao tipo de comodities algodão, e seta os valids de campo no model
				oView:HideFolder('CTRFOLDER', FLDALGODAO, 2) // Esconde a aba Algodão
				oView:SelectFolder('CTRFOLDER', FLDPRINCIP, 2) // Seleciona a aba Principal
				oModelNJR:GetStruct():SetProperty( "NJR_TKPFIS", MODEL_FIELD_VALID, {|| Iif(.NOT.Empty(M->NJR_CODPRO), AGRTPALGOD(M->NJR_CODPRO),.F.)})
				oModelNJR:GetStruct():SetProperty( "NJR_TIPALG", MODEL_FIELD_VALID, {|| Iif(.NOT.Empty(M->NJR_CODPRO), AGRTPALGOD(M->NJR_CODPRO),.F.)})
				oModelNJR:GetStruct():SetProperty( "NJR_TOLENT", MODEL_FIELD_VALID, {|| Iif(.NOT.Empty(M->NJR_CODPRO), AGRTPALGOD(M->NJR_CODPRO),.F.)})
			EndIf	
        EndIF

        If lRet
            oModelNJR:LoadValue( "NJR_UMPRC" , cUmPreco )
        Endif
    EndIf


Return( lRet )


/** {Protheus.doc} AGRXDTNNY
Valida o campo NNY_DATINI e automaticamente preenche NNY_DATFIM

@param:     oField 
@return:    lRetorno - verdadeiro ou falso
@author:    Marlon Richard Trettin
@since:     18/11/2014
@Uso:       OGA280
*/
Function AGRXDTNNY( oFldNNY, dDataInicial )
	Local lRetorno       := .T.
    Default dDataInicial := oFldNNY:GetValue( "NNY_DATINI" )
	
	If Empty(oFldNNY:GetValue( "NNY_DATFIM" ))
		oFldNNY:SetValue( "NNY_DATFIM", dDataInicial)
	EndIf

Return( lRetorno )

/** {Protheus.doc} AGRXDTNNY
Valida o campo NNY_DATINI e automaticamente preenche NNY_DATFIM

@param:     oField 
@return:    lRetorno - verdadeiro ou falso
@author:    Marlon Richard Trettin
@since:     18/11/2014
@Uso:       OGA280
*/
Function AGRXDTN9A( oModelN9A, dDataNNY, cCampo)	
	
	Local lRetorno     := .T.	
	
	If !Empty(dDataNNY) .and. cCampo == "NNY_DATINI"
		oModelN9A:SetValue("N9A_DATINI", dDataNNY)
	EndIf

	If !Empty(dDataNNY) .and. cCampo == "NNY_DATFIM"
		oModelN9A:SetValue("N9A_DATFIM", dDataNNY)
	EndIf
	
Return( lRetorno )

/** {Protheus.doc} AGRXPOSNN7
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015   Refeito 07/07/2016   Inácio Luiz Kolling
@Uso:       OGA290 - Contratos
*/
Function AGRXPOSNN7( oGride )
	Local oModel := oGride:GetModel()
	Local oModelNJR := oModel:GetModel("NJRUNICO")
	Local nValor 	:= 0

	If oModel:GetId() != "OGA700" .and. oModelNJR:GetValue("NJR_MODELO") <> "3" .AND. !__lNGraPrevF // __lNGraPrevF = .F. --> Gera previsão financeira
		nValor := AGRSOMACOLSM(oGride,{"NN7_VALOR"})
		If nValor <= 0 .AND. (!__lnewNeg .OR. !__lRegOpcional)
			Help(,,STR0001,,STR0007,1,0) //"AJUDA"###"É necessário informar ao menos uma quantia no item dos Titulos do Contrato!"
			Return .F.
		EndIf	
	EndIf
Return .T.

/** {Protheus.doc} AGRXPOSNNY
Função que valida o gride de dados após a perda do foco ou a confirmação do modelo

@param:     oGride - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     01/01/2015  Refeito 07/07/2016   Ináciadmo Luiz Kolling
@Uso:       OGA290 - Contratos
*/

Function AGRXPOSNNY( oGride )
	Local oModel	  := FwModelActive()
	Local nSomaTot 	  := AGRSOMACOLSM(oGride,{"NNY_QTDINT"})
	Local lRetorno      := OGA260CADEN(oModel)
	Local nLinha      := 0
	Local nX          := 0	
		
		/*Validaçao de datas*/
		nLinha := oGride:GetLine()
		For nX := 1 to oGride:Length()
			oGride:GoLine( nX )
			
			If oGride:GetValue("NNY_DATINI") > oGride:GetValue("NNY_DATFIM") // Validaçao de data inicial e final da cadência
				Help("", 1, "OGA290CAD00001") // # Data Inicial informada na cadência é superior a Data Final.
				Return .F.
			EndIf

		Next nX

		oGride:GoLine( nLinha )	

		//valida quantidade
		If FWFLDGET("NJR_MODELO") = "3" .And. Empty(nSomaTot)
			Return .t.
		EndIf	

		If oModel:GetValue( "NJRUNICO", "NJR_QTDCTR" ) <> nSomaTot
			Help( , , STR0001, , STR0008, 1, 0, ) 	//"AJUDA"###"A soma da quantidade nos itens de Cadência do Contrato esta divergente do Contrato!"
			Return .f.
		EndIf

	
Return lRetorno

/** {Protheus.doc} AGRXVLFAV
Função para gatilho de favorecido

@param:     Nil
@author:    Equipe Agroindustria
@since:     12/08/2014
@Uso:       SIGAAGR - Originação de Grãos
*/
Function AGRXVLFAV(oFieldModel,cCodEntT,cLojEntT) 
	Local aAreaAtu  := GetArea("NJ0")
	Local lRetorno  := .T.
	Local oModel    := oFieldModel:GetModel() 
	Local oNN7      := oModel:GetModel("NN7UNICO")

	Local nLinha    := 0
	Local nX        := 0
    Local lNGraPrevF  := SuperGetMV( "MV_AGRPREV", .f., .f. ) //padrão do parametro é sempre .f. se nao existir - .f. gera previsao financeira - .t. nao gera previsao financeira

	If !lNGraPrevF
        NJ0->( dbSelectArea("NJ0") )
        NJ0->( dbSetOrder( 1 ) )
        If NJ0->( dbSeek( xFilial( "NJ0" ) + cCodEntT + cLojEntT ) )
            If !Empty(NJ0->NJ0_CODCLI) .OR. !Empty(NJ0->NJ0_CODFOR)
                If valType(oNN7) == 'O'
                    nLinha := oNN7:GetLine()
                    For nX := 1 to oNN7:Length()
                        oNN7:GoLine( nX )
                        If .Not. oNN7:IsDeleted()
                            oModel:LoadValue( "NN7UNICO", "NN7_CODFAV", NJ0->NJ0_CODENT )
                            oModel:LoadValue( "NN7UNICO", "NN7_LOJFAV", NJ0->NJ0_LOJENT )
                            oModel:LoadValue( "NN7UNICO", "NN7_NOMFAV", NJ0->NJ0_NOME   )	//Posicione( "SA1", 1, xFilial( "SA1" ) + NJ0->( NJ0_CODCLI + NJ0_LOJCLI ), "A1_NOME" ) )
                            oModel:LoadValue( "NN7UNICO", "NN7_NLJFAV", NJ0->NJ0_NOMLOJ )	//Posicione( "SA1", 1, xFilial( "SA1" ) + NJ0->( NJ0_CODCLI + NJ0_LOJCLI ), "A1_NREDUZ" ) )
                        EndIf
                    Next nX
                    oNN7:GoLine( nLinha )
                EndIf
            Else
                Help(,,STR0001,,STR0009+cCodEntT+" - "+cLojEntT,1,0) 	//"AJUDA"#"Favorecido não localizado no cadastro de Entidades (NJ0): " 
                lRetorno := .F.    
            EndIf
        EndIf
    EndIf

	RestArea (aAreaAtu)		
Return( lRetorno )

/** {Protheus.doc} AGRXTOTAL
Funçao para gatilho de total

@param:     Nil
@author:    Ana Laura Olegini
@since:     12/08/2014
@Uso:       SIGAAGR - Originaçao de Graos
*/
Function AGRXTOTAL(oFieldModel, nTotal)

	Local lRetorno  := .T.
	Local oModel    := oFieldModel:GetModel()

	If .NOT. __lnewNeg  	
		oModel:LoadValue( "NN7UNICO", "NN7_VALOR", nTotal )
	EndIf

Return ( lRetorno )

/** {Protheus.doc} AGRXHIST
Descriçao: Mostra em tela de Historico do contrato

@param:     Nil
@author:    Gilson Venturi
@since:     31/03/2015
@Uso:       OGA280 
*/
Function AGRXHIST()
	Local cChaveI := "NJR->("+Alltrim(AGRSEEKDIC("SIX","NJR1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("NJR",cChaveA)
Return

/** {Protheus.doc} AGRXTOTFIN
Descrição: Verifica se o total dos titulos do financeiro e o valor total do contrato
@param:     Nil
@author:    Agroindustria
@since:     09/10/2015
@Uso:       OGA290 
*/
Function AGRXTOTFIN(cCodCtr, vVrlCtr, cRegNeg)
	Local cAliasNN7 := ""
	Local vVlrPrev  := 0

	If __lNGraPrevF  //Validação para confirmar contrato sem valor e previsão //__lNGraPrevF = .T. --> NÃO Gera previsão financeira

		return .t.

	Else 
		cAliasNN7 := GetNextAlias()

		cQuery := "SELECT SUM(NN7_VALOR) AS NN7_VALOR "
		cQuery +=  " FROM " + RETSQLNAME('NN7') + ' NN7 '
		cQuery += " WHERE NN7.NN7_FILIAL = '"+ fWxFilial('NN7') + "'"
		cQuery +=   " AND NN7.NN7_CODCTR = '"+ cCodCtr + "'"
		
		If empty(cRegNeg) .AND. NN7->(ColumnPos("NN7_CODCOM")) > 0    
	    	cQuery +=   " AND (NN7.NN7_CODCOM = 'TOTAL' OR NN7.NN7_CODCOM = ' ') "
		EndIf
		
		cQuery +=   " AND NN7.NN7_ITMCOM = ' '"	
		cQuery +=   " AND NN7.D_E_L_E_T_ = ' '"	
		   
		cQuery := ChangeQuery(cQuery)
	
		If Select(cAliasNN7) != 0
			(cAliasNN7)->(dbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNN7,.F.,.T.)
	
		dbSelectArea(cAliasNN7)
		(cAliasNN7)->(DbGoTop())
		If (cAliasNN7)->( !Eof() )
			vVlrPrev += (cAliasNN7)->NN7_VALOR
		Endif

		(cAliasNN7)->( dbCloseArea() )

	EndIf
	
	//verificação novo negócio
	IF empty(cRegNeg) 	    
		if __lnewNeg .and. vVlrPrev > 0
			return .t.
		elseif __lnewNeg //é novo negócio mas não tem preço 
			Help( , , STR0001, , STR0011, 1, 0 ) //"AJUDA"###""A soma das quantias nos itens dos Titulos do Contrato esta divergente do Contrato!""
			return .f.
		endif
	EndIf
		
	if Round(vVrlCtr,1) == Round(vVlrPrev,1)
		return .T.
	EndIf
	
	If vVrlCtr > 0
		Help( , , STR0001, , STR0010, 1, 0 ) //"AJUDA"###""A soma das quantias nos itens dos Titulos do Contrato esta divergente do Contrato!""
		return .f.
	Else
		return .t.	//recoloca para quando for novos negócios
	EndIf
Return .t.

/** {Protheus.doc} OGA290nCopy
Função Que pega todos os campos do modelo e retorna-os em array unidimensional

@param:     oModel      Objeto de Model do MVC
@return:    aFldNoCopy      := {,} // Array Com os Campos do modelo de dados passado
@author:    Emerson Coelho
@since:     14/11/2014
@Uso:       OGA280 - Contrato de compra
*/
Function AGRXNOCOPY( oModel )
	Local nX    := 1
	Local aFieldsAux        := oModel:GetStruct():aFields
	aFldNoCopy          := {}
	for nX:=1 to len( aFieldsAux ) Step 1
		aAdd(aFldNoCopy , aFieldsAux [nX , 3] )
	nExt
Return aFldNoCopy

/** {Protheus.doc} AGRXLICOPY
Função para eliminar linhas do Grid na função cópia
@param:     oObj      - Grid do modelo de dados
lCopia    - Informa se é função Cópia 
@return:    aLoadGrid - Array com os valores do objeto
@author:    Niara Caetano
@since:     06/10/2018
@Uso:       OGA290 - Contratos
*/
Function AGRXLICOPY(oObj,lCopia) 
	Local aLoadGrid := {}
	Local nLgTam	:= 0
	Local nX 		:= 0

	If lCopia 
		aLoadGrid := FormLoadGrid(oObj, .T.) // faz a carga de dados 
		nLgTam 	  := Len(aLoadGrid)  

		For nX := 1 To Len(aLoadGrid)
			If nX > 1                        //se houver mais de uma linha na grid, elimina essas linhas				
				aDel(aLoadGrid, nLgTam)      //remove linha da grid
				aSize(aLoadGrid, --nLgTam)
			EndIf
		Next
	Else
		aLoadGrid := FormLoadGrid(oObj, .F.)
	EndIf

Return aLoadGrid

/** {Protheus.doc} AGRXREABRE
Rotina para utilizada para reabrir o contrato para que o mesmo seja movimentado

@param:     Nil
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Function AGRXREABRE( cAlias, nReg, nAcao )
	Local aAreaAtu  := GetArea()
	Local lRetorno    := .T.

	If NJR->( NJR_STATUS ) $ "FE"
		// Não permite reabrir se houver outro contrato Confirmado ou Iniciado com a mesma Entidade e Safra
		lRetorno := OGA390B(xFilial("NJR"), NJR->( NJR_CODENT ) , NJR->( NJR_LOJENT ) , NJR->( NJR_CODSAF ), NJR->( NJR_CODPRO ) , NJR->( NJR_TIPO ) )
		if lRetorno = .F.
			Return .F.
		endif

		BEGIN TRANSACTION

			//"Deseja realmente reabrir este contrato?"
			If AGRGRAVAHIS(STR0012,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,"B") = 1

				AGRXATUNN8("")               

                //////////////////////////
				// Atualiza quantidades do contrato de acordo com as aditações / supressões
				//////////////////////////
				OGA335AtuQtd()  

				//////////////////////////
				//Atualiza quantidade do contrato e saldos
				//////////////////////////

				OGX010QTDS("P")// Contrato ja foi finalizado, o titulo foi excluido, então deve voltar a ser previsto, para a geração do mesmo.

				//////////////////////////
				//Atualiza autorizações
				//////////////////////////

				OGX010QAut("P")//Deve atualizar com o Status "P", pois este contrato, como está sendo reaberto, não possui título.

				If !__lAutomato
                    MsgInfo( STR0013, STR0014 ) //"Contrato Reaberto com Sucesso!!!"###"Reabertura do Contrato"
                EndIf
			EndIf
		END TRANSACTION
	Else
		Help( ,,STR0001,, STR0015, 1, 0 ) //###"Este contrato não pode ser -Reaberto-, pois não esta -Fechado- ou -Encerrado-..."
		Return( Nil )
	EndIf

	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} AGXSITMOL()
Funçao que ajusta a Situaçao e o modelo do contrato na atualizaçao 
@param: 	Model.
@Return:    Nil;
@author: 	Marcelo Ferrari
@since: 	19/02/2018
@Uso: 		SIGAAGR - Originaçao de Graos
*/

Function AGXSITMOL(oModel)
	Local nOperation  := oModel:GetOperation()
	Local cModelo     := oModel:GetValue( "NJRUNICO", "NJR_MODELO" )
	Local oModelNJR   := oModel:GetModel( "NJRUNICO" )
	Local cStatusN79  := ""
	Local cStClieN79  := ""
	Local lIsTakeUp := (FwIsInCallStack("AGRA720MVC") .OR. FwIsInCallStack("AGRA720N9A") .OR. FwIsInCallStack("OGC020EST") .OR. FwIsInCallStack("AGRA720INAT") .OR. FwIsInCallStack("OGC040RFAR"))

    If __lnewNeg .and. !empty(oModelNJR:Getvalue('NJR_CODNGC')) .and. !empty(oModelNJR:Getvalue('NJR_VERSAO'))  //se trata de novo negocio
    	cStatusN79  := Posicione("N79",1,xFilial("N79")+oModelNJR:Getvalue('NJR_CODNGC')+oModelNJR:Getvalue('NJR_VERSAO'),"N79_STATUS")
    	cStClieN79  := Posicione("N79",1,xFilial("N79")+oModelNJR:Getvalue('NJR_CODNGC')+oModelNJR:Getvalue('NJR_VERSAO'),"N79_STCLIE")
  	
    	If nOperation == 4 .AND. !(FwIsInCallStack("OGX700ACTR") .OR. lIsTakeUp) //update
			//Altera Status do Troca para pendente(OGA300)
			If FindFunction('StatusNKT')
				StatusNKT('01')
			Endif
		
			If cStatusN79 == "3"  //Se o negocio estiver com status completo
				//Altera o valor de NJR_MODELO => 2
				If cModelo == "1"
					If cStClieN79 == '4'
						oModel:SetValue( "NJRUNICO", "NJR_MODELO", "2" )
					Else
						oModel:SetValue( "NJRUNICO", "NJR_MODELO", "1" )
					EndIf
				EndIf
				//Alterar a situaçao do contrato para Previsto  => Status = 2
				If .NOT. IsInCallStack("OGC020")
					oModel:SetValue( "NJRUNICO", "NJR_STATUS", "P" )
				EndIF
			ElseiF  .NOT. __lRegOpcional
				If cStatusN79 $ "1|2|5|6"  //Impede de alterar o tipo de modelo caso o registro de negocio seja opcional
					oModel:SetValue( "NJRUNICO", "NJR_MODELO", "1" )
				Else
					//Negocio Cancelado
					oModel:SetValue( "NJRUNICO", "NJR_STATUS", "E" )
			    EndIf
	        EndIf	       
		EndIf

	Else //processo legado   
		If nOperation == 4 //update
		
			If cModelo == "1"
				oModel:SetValue( "NJRUNICO", "NJR_MODELO", "2" )
			EndIf
			
			If .NOT. IsInCallStack("OGC020")
				If cModelo == "2"
					oModel:SetValue( "NJRUNICO", "NJR_STATUS", "P" )
				EndIf
			EndIf
					
		EndIf		
	EndIf

Return

/** {Protheus.doc} AGRXVALENT
Descrição:  Validação para verificar se entidade está valida
@param:     Nil
@author:    Ana Laura Olegini
@since:     03/05/2016
@Uso:       OGA270 
*/
Function AGRXVALENT(cOperacao, cCodEnt, cLojEnt)

	Local aAreaAtu  	:= GetArea()
	Local lContinua 	:= .T.
	Local oModel 		:= FwModelActive() 

	Default cOperacao 	:= "C"
	Default cCodEnt		:= oModel:GetModel("NJRUNICO"):GetValue("NJR_CODENT")
	Default cLojEnt 	:= oModel:GetModel("NJRUNICO"):GetValue("NJR_LOJENT")


	//Acessa a tabela de entidades para a verificação
	DbSelectArea("NJ0") // Entidades
	NJ0->(dbSetOrder(1))
	If NJ0->(dbSeek(xFilial("NJ0")+cCodEnt+cLojEnt))
		//Verifica se esta ativo
		If NJ0->(NJ0_ATIVO) == '2' // 1=Ativo; 2=Inativo
			Help(,,STR0001,,STR0016+NJ0->(NJ0_CODENT)+" "+NJ0->(NJ0_LOJENT),1,0) 		//"AJUDA"#"Cadastro de Entidade está INATIVO e não pode ser usado para esta função. Verifique o cadastro da entidade: "
			Return( .F. )
		EndIf		

		If cOperacao == "C" //Cliente
			lContinua := AgrEntidOk( "SA1", cCodEnt, cLojEnt )
		ElseIf cOperacao == "F" //Fornecedor
			lContinua := AgrEntidOk( "SA2", cCodEnt, cLojEnt )
		Else
			lContinua := .F.
		Endif

	EndIf
	If !lContinua
		Help(,,STR0001,,STR0017 +cCodEnt+" "+cLojEnt,1,0) 								//"AJUDA"#"Fornecedor não localizado no cadastro de Entidades (NJ0): "   
		Return( .F. )
	EndIf

	RestArea (aAreaAtu)
Return(lContinua)

/*{Protheus.doc} AGRXPOSNJR
Função para validar antes da confirmação do modelo

@author 	Ana Laura Olegini
@since 		25/09/2017
@version 	1.0
@param 		oField 		- Objeto	- Modelo 
@return 	lRetorno	- Logico	- Retorno .f. ou .t.
*/
Function AGRXPOSNJR(oField)  
	Local oFldModel	:= oField:GetModel()
	Local oModelNJR := oFldModel:GetModel("NJRUNICO")
	Local cCodPro   := oModelNJR:GetValue( "NJR_CODPRO" )
	Local cTabela   := oModelNJR:GetValue( "NJR_TABELA" )
	Local lRetorno  := .T.
	Local lDuplic   := .F.
	Local lEstoq    := .F.
	Local lEnt      := .F.
	Local lMerInt   := .F.

	If oFldModel:GetId() != "OGA700" .AND. !__lRegOpcional
		//Se o produto não for do tipo algodao .F. e campo tabela estiver vazio
		If .NOT. AGRTPALGOD(cCodPro) 
			IF Empty(cTabela) .AND. AGRXRESI(cCodPro)
				Help(" ",1,"OGA290VLDPOS ") //Favor informar a tabela de classificação para o produto.
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	//Validações de Operação triangular na comercialização Classica
	If !__lnewNeg
		//Não pode estar Operação triangular = SIM, e Venda Futura = SIM. 
		If oModelNJR:GetValue("NJR_OPETRI") == '1' .AND. oModelNJR:GetValue("NJR_OPEFUT") == '1'
			AgrHelp(STR0001, STR0064, STR0065) //"Não é possivel criar um contrato com Operação Futura e Operação Triangular." // "Selecione apenas uma das operações para o contrato"
            Return .F.
		EndIf

		//HELP: Op Triangular Inválida 
		//SOLUÇÃO: Op Triangular só pode ser marcada como “Sim” quando contrato for do tipo “Mercado Interno”
		//         e a TES estiver parametrizada como ‘Gerar Duplicatas’ = “Sim” e ‘Atualiza Estoque’ = “Não”
		//         e Entidade for diferente da Entidade Entrega. 		
		lDuplic := Posicione("SF4", 1, xFilial("SF4") + oModelNJR:GetValue("NJR_TESFIN"), "F4_DUPLIC") == "S" 
		lEstoq  := Posicione("SF4", 1, xFilial("SF4") + oModelNJR:GetValue("NJR_TESFIN"), "F4_ESTOQUE") == "S"
		lEnt    := oModelNJR:GetValue("NJR_CODENT")+oModelNJR:GetValue("NJR_LOJENT")  == oModelNJR:GetValue("NJR_CODTER")+oModelNJR:GetValue("NJR_LOJTER") 
		lMerInt := oModelNJR:GetValue("NJR_TIPMER") == '1' //Interno
		
		//HELP: Op Triangular Inválida 
		//SOLUÇÃO: Op Triangular só pode ser marcada como “Sim” quando contrato for do tipo “Mercado Interno”
		//         e a TES estiver parametrizada como ‘Gerar Duplicatas’ = “Sim” e ‘Atualiza Estoque’ = “Não”
		//         e Entidade for diferente da Entidade Entrega. 
		If oModelNJR:GetValue("NJR_OPETRI") == '1' .And. ( !lDuplic .Or. lEstoq .Or. !lMerInt .Or. lEnt)
			AgrHelp(STR0001,STR0066 , STR0067) //"Operação Triangular Invalida"//"Op Triangular só pode ser marcada como Sim quando contrato for do tipo Mercado Interno e a TES estiver parametrizada como Gerar Duplicatas = Sim e Atualiza Estoque = Não e Entidade for diferente da Entidade Entrega. "
			Return .F.
		EndIf 

		If  oModelNJR:GetValue("NJR_OPETRI") == '1' .AND. ( Empty(oModelNJR:GetValue("NJR_TESFIN")) .OR.  Empty(oModelNJR:GetValue("NJR_TESEST") ) )
			AgrHelp(STR0001, STR0066, STR0068) //"É necessario informar a TES Financeira e a TES de Movimentação de Estoque para Operação Triangular""
			Return .F.		
		EndIf

		//Quando operação triangular = SIM, deve ter Entidade Entrega/loja preenchidos.
		If oModelNJR:GetValue("NJR_OPETRI") == '1' .AND. Empty(oModelNJR:GetValue("NJR_CODTER")) 
			AgrHelp(STR0001, STR0066, STR0069) //"Para um contrato com Operação Triangular é necessario informar a Entidade e Loja de Terceiro."
			Return  .F.			
		EndIf	
		
		//Validar se a regra possui operação futura ou triagular quando o campo TES REM está preenchido
		If !Empty( oModelNJR:GetValue("NJR_TESFIN") ) .AND. oModelNJR:GetValue("NJR_OPETRI") == '2' 
			AgrHelp(STR0001, STR0070,STR0071) //"TES auxiliar informada para um contrato sem Operação Triangular" // "Para um contrato sem Operação Triangular o campo TES financeira não deve ser informado."
			Return  .F.	
		EndIf			
	EndIf


Return(lRetorno)

/*{Protheus.doc} AGRXNNYNN9
(Função de pos-validação do modelo)
Valida para cada registros das previsões de entrega a quantidade das regras fiscais
@type function
@author claudineia.reinert
@since 19/02/2018
@version 1.0
@param  objeto (oModel)
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/
Function AGRXNNYNN9(oModel)
	Local oNNY      := oModel:GetModel( "NNYUNICO" )
	Local nX		:= 0
	Local lRet		:= .T.
	Local nLinAtu	:= oNNY:GetLine()
	
	For nX := 1 To oNNY:Length() 	
		oNNY:GoLine(nX)
		If .not. oNNY:IsDeleted() 
		   	If !AGRXVALN9A(oModel)
		   		lRet := .F.
		   		Exit
		   	EndIf
		EndIF		
	Next nX

	oNNY:GoLine(nLinAtu)
	
Return lRet

/** {Protheus.doc} AGRXNNYQTD
Função criada para realizar gatilho do campo NNY_QTDINI
@author:    Thiago Henrique Rover
@since:     30/01/2018
@Uso:       OGA290 - Contrato de Venda
*/
Function AGRXNNYQTD(oGrid,xValue)  
	Local oModel	:= oGrid:GetModel()
	Local oN9A      := oModel:GetModel( "N9AUNICO" )
	Local nCont     := 0
	Local nQtd      :=  IIF( xValue == 0 , oModel:GetModel( "NNYUNICO" ):GetValue("NNY_QTDINT") , xValue )

	If __lnewNeg	
		If oN9A:Length(.T.) == 1
			For nCont := 1 To oN9A:Length() 			
				oN9A:GoLine(nCont)		
				
				If .Not. oN9A:IsDeleted()
					oN9A:LoadValue("N9A_QUANT",  nQtd )
					oN9A:LoadValue("N9A_SDOINS", nQtd )
					oN9A:LoadValue("N9A_SDONF" , nQtd )					
				EndIf
			Next nCont
			
			oN9A:GoLine(1)	
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} AGRXTESINT()
	Gatilho para buscar a tes inteligente. 
	@type  Function
	@author mauricio.joao
	@since 07/06/2019
	@version 1.0
	@param param, param_type, param_descr
	@return ctes, char, tes retornada da função
	/*/
Function AGRXTESINT(lRegraFis, cMsgRetErro, cEntidade, cLoja, cOperFiscal, cTipoCtr, cProduto)
	Local oModel 	:= FwModelActive() 
	Local oModelNJR := nil
	Local cOpeFis 	:= ""
	Local cCodEnt 	:= ""
	Local cLojEnt 	:= ""
	
	Local cTipo 	:= ""
    Local cFilUtlz  := ""
	Local cFilAtu	:= cFilAnt

	Local cRetorno 	:= ""
	Local nExp1		:= ""
	Local cExp2		:= PADR(cOpeFis,TamSx3('FM_TIPO')[1])
	Local cExp3		:= ""
	Local cExp4		:= ""
	Local cExp5		:= ""
	Local cExp6		:= ""
	Local cExp7		:= ""

	Local nLinNNY  := 0
	Local nLinN9A  := 0

	Default lRegraFis   := .F. 
    Default cMsgRetErro := ""    
    Default cEntidade   := ""
    Default cLoja       := ""
    Default cOperFiscal := ""
    Default cTipoCtr    := ""
    Default cProduto    := ""

    If valType(oModel) == "O"
        oModelNJR := oModel:GetModel("NJRUNICO")
        cOpeFis   := Iif(lRegraFis,oModel:GetModel("N9AUNICO"):GetValue("N9A_OPEFIS"),oModelNJR:GetValue("NJR_OPEFIS"))
        cCodEnt   := Iif(lRegraFis,oModel:GetModel("N9AUNICO"):GetValue("N9A_CODENT"),oModelNJR:GetValue("NJR_CODENT"))
        cLojEnt   := Iif(lRegraFis,oModel:GetModel("N9AUNICO"):GetValue("N9A_LOJENT") ,oModelNJR:GetValue("NJR_LOJENT"))
        cTipo 	  := oModelNJR:GetValue("NJR_TIPO")
        cExp6	  := oModelNJR:GetValue("NJR_CODPRO") //produto                

        If Empty(cOpeFis) .AND. !lRegraFis
            Return(oModelNJR:GetValue("NJR_TESEST"))
        EndIf
    else
        cOpeFis   := cOperFiscal
        cCodEnt   := cEntidade
        cLojEnt   := cLoja
        cTipo     := cTipoCtr
        cExp6     := cProduto
    EndIf
    
    cExp2	  := PADR(cOpeFis,TamSx3('FM_TIPO')[1])

	//verifica o tipo do contrato compra / venda
	If cTipo $ "1|3" //compras e armz em 3
		nExp1 := 1
		cExp5 := "F"
	ElseIf cTipo $ "2|4" //venda e armz de 3
		nExp1 := 2
		cExp5 := "C"
	EndIf

	//posiciona e valida a entidade
	NJ0->( dbSetOrder( 1 ) )
	If !Empty(cCodEnt) .AND. !Empty(cLojEnt)
		NJ0->( dbSeek( xFilial( "NJ0" ) + cCodEnt + cLojEnt ) )
		If cExp5 == "F"
			cExp3 := NJ0->( NJ0_CODFOR ) 
			cExp4 := NJ0->( NJ0_LOJFOR )
		Else
			cExp3 := NJ0->( NJ0_CODCLI ) 
			cExp4 := NJ0->( NJ0_LOJCLI )
		EndIf
	EndIf

	If lRegraFis
		If Empty(oModel:GetModel("N9AUNICO"):GetValue("N9A_FILORG"))
            AgrHelp(STR0001, STR0048, STR0049) //"Filial de origem não foi informada." //"Por favor, informe a filial de origem para que seja possível localizar a TES Inteligente."
            Return
        EndIf
        cFilAnt := oModel:GetModel("N9AUNICO"):GetValue("N9A_FILORG") //filial
	EndIf

	//verifico o compartilhamento da tabela
	cComEmp := FWModeAccess("SFM",1)
	cNgcEmp := FWModeAccess("SFM",2)							
	cFilEmp := FWModeAccess("SFM",3)

	//mudo a empresa pra buscar a tes int corretamente
	If cFilEmp == "E"
		cFilAnt := Iif(lRegraFis,oModel:GetModel("N9AUNICO"):GetValue("N9A_FILORG"),cFilAtu)
	ElseIf cNgcEmp == "E" .AND. cFilEmp == "C"
		cFilAnt := FWCompany()+FWUnitbusiness()
	ElseIf cComEmp = "C"
		cFilAnt := FWCompany()
	EndIf

    cFilUtlz := cFilAnt
	cRetorno := MaTesInt( nExp1, cExp2, cExp3, cExp4, cExp5, cExp6, cExp7 )
	//retorno a empresa corrente.
	cFilAnt := cFilAtu

	//Trata as regras fiscais, não entra se for OGX290.
	If __lnewNeg .AND. valType(oModel) == "O" .and. valType(oModel:GetModel("N9AUNICO")) == 'O'  .AND. !lRegraFis //OGX290

		oModelNNY := oModel:GetModel("NNYUNICO")
		oModelN9A := oModel:GetModel("N9AUNICO")

		//permite alteração na N9A
		//passa por todas as cadencias (NNY)
		For nLinNNY := 1 to oModelNNY:Length()
			oModelNNY:GoLine(nLinNNY)	

			//passa por todas as regras fiscais (N9A)
			For nLinN9A := 1 to oModelN9A:Length()
				oModelN9A:GoLine(nLinN9A)				
		
				cFilAnt := oModelN9A:GetValue("N9A_FILORG")

				//verifico o compartilhamento da tabela
				cComEmp := FWModeAccess("SFM",1)
				cNgcEmp := FWModeAccess("SFM",2)							
				cFilEmp := FWModeAccess("SFM",3)

				//mudo a empresa pra buscar a tes int corretamente
				If cFilEmp == "E"
					cFilAnt := oModelN9A:GetValue("N9A_FILORG")
				ElseIf cNgcEmp == "E" .AND. cFilEmp == "C"
					cFilAnt := FWCompany()+FWUnitbusiness()
				ElseIf cComEmp = "C"
					cFilAnt := FWCompany()
				EndIf

				cTesN9A := MaTesInt( nExp1, cExp2, cExp3, cExp4, cExp5, cExp6, cExp7 )
			
				oModelN9A:LoadValue("N9A_OPEFIS",Alltrim(cOpeFis))
				oModelN9A:LoadValue("N9A_TES",cTesN9A)	

				//retorno a empresa corrente.
				cFilAnt := cFilAtu		

			Next nLinN9A
			oModelN9A:GoLine(1)

		Next nLinNNY
		oModelNNY:GoLine(1)

	
	EndIf

    If Empty(cRetorno)
        cMsgRetErro := STR0053 + CRLF + CRLF     //#"Não foi possível encontrar a TES no cadastro de TES Inteligente utilizando as seguintes informações: "
        cMsgRetErro += STR0054 + cFilUtlz + CRLF //#"Filial: " 
        cMsgRetErro += iif(cExp5 == "C", STR0055, STR0056) + cExp3 + CRLF  //#"Cliente: " #"Fornecedor: "
        cMsgRetErro += STR0057  + cExp4 + CRLF //#"Loja: "
        cMsgRetErro += STR0058  + cExp2 + CRLF //#"Operação Fiscal: "
        cMsgRetErro += STR0059  + cExp6        //#"Produto: " 
    EndIf

Return(cRetorno)

/*/{Protheus.doc} AGRXFILORG()
	Atualiza as filiais de origem nas regras fiscais
	@type  Function
	@author mauricio.joao
	@since 20/12/2019
	@version 1.0
	/*/
 Function AGRXFILORG(oModelNNY, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)

	Local nLinN9A as numeric
	Local nLinNN7 as numeric

	Local oModel := oModelNNY:GetModel()
	
	oStrN9A := oModel:GetModel("N9AUNICO")	
	For nLinN9A := 1 to oStrN9A:Length(.T.)
		oStrN9A:Goline(nLinN9A)
		If oStrN9A:Cansetvalue('N9A_FILORG') //verifico se posso atribuir valor
			oStrN9A:SetValue("N9A_FILORG",xVrNovo)
		EndIf
	Next nLinN9A
	oStrN9A:Goline(1)			
	
	oStrNN7 := oModel:GetModel("NN7UNICO")	
	For nLinNN7 := 1 to oStrNN7:Length(.T.)
		oStrNN7:Goline(nLinNN7)
		If oStrNN7:Cansetvalue('NN7_FILORG') //verifico se posso atribuir valor
			oStrNN7:SetValue("NN7_FILORG",xVrNovo)
		EndIf
	Next nLinNN7
	oStrNN7:Goline(1)				

Return .T.

/*{Protheus.doc} AGRXVALN9A
(Função de pos-validação da Grid N9A)
@type function
@author Tamyris Ganzenmueller
@since 08/01/2018
@version 1.0
@param  objeto (FwFormGrid - N9A)
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/

Function AGRXVALN9A(oMdGrid)

	Local oModel    := oMdGrid:GetModel()
	Local oN9A      := oModel:GetModel( "N9AUNICO" )
	Local oNNY      := oModel:GetModel( "NNYUNICO" )
	Local oNJR      := oModel:GetModel( "NJRUNICO" )
	Local nContN9A  := 0
	Local nSomEnt   := 0
	Local lRet      := .T.
	Local lAlgodao  := AGRTPALGOD(oNJR:GetValue("NJR_CODPRO"))
	Local lQtdVazia := .F.
	Local nOpeFut   := 0
	Local nExcOpeFut := 0

	Local nOperation := oModel:GetOperation()
	
	Local nLinha := oN9A:GetLine()
	// Se tiver registro de negócio e não tiver regra fiscal para o contrato, na alteração, cria a regra fiscal automaticamente
	If __lnewNeg	
		If (nOperation == 4 .and. oN9A:Length() == 1 .and. !oN9A:IsUpdated(1)) .OR. (IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR"))		
			oN9A:GoLine(1)
			dbSelectArea("N9A")
			dbSetOrder(1)
			If !dbSeek( xFilial( "N9A" ) +  oN9A:GetValue("N9A_CODCTR") +  oN9A:GetValue("N9A_ITEM") + oN9A:GetValue("N9A_SEQPRI") )   
				oN9A:LoadValue("N9A_SEQPRI", '001')
			EndIf         
		EndIf		
	EndIf	
	If (IsInCallStack("OGX700CTR") .OR. IsInCallStack("OGX700ACTR")) .OR. !__lnewNeg

		Return .T.
	EndIf
	
	nSomEnt := 0
	For nContN9A := 1 To oN9A:Length() 	
		oN9A:GoLine(nContN9A)
		If .not. oN9A:IsDeleted() 	
			If(oN9A:GetValue("N9A_QUANT") == 0)
				lQtdVazia := .T.
				If oN9A:GetValue("N9A_OPEFUT") == "2" .and. oN9A:GetValue("N9A_OPETRI") == "2"
					nExcOpeFut++
				Else
					nExcOpeFut := 0
					Exit
				EndIf
				
			Else   	
	   			nSomEnt += oN9A:GetValue("N9A_QUANT")	
			EndIf 
			If oN9A:GetValue("N9A_OPEFUT") == "1"
				nOpeFut++
			EndIf	
		EndIF		
	Next nContN9A
	oN9A:GoLine(nLinha)

	/*#######################################
	## OBS: Para grãos, só permite qtd zero em regra fiscal para usar a regra fiscal como excedente de operação futura
	## sendo que para cada regra de operação futura pode ter uma regra com qtd zerada para o excedente.
	#########################################*/
	If lQtdVazia .and. !( nOpeFut > 0 .and. nExcOpeFut = nOpeFut .and. !lAlgodao ) 
		lRet := .F.
		AGRHELP(STR0050,STR0051,STR0052) //##Regra Fiscal sem Quantidade. ##Existem linhas de Regra Fiscal com quantidade zerada. ##Favor preencher a quantidade ou excluir a linha.
	ElseIf lRet .and. nSomEnt <> oNNY:GetValue("NNY_QTDINT")
		lRet := .F.
		//HELP: A quantidade da regra fiscal não pode ser zero ou menor que a quantidade de take-up e a soma das regras fiscais devem ser iguais a quantidade da entrega.
		//SOLUÇÃO: Revise as quantidades informadas
		Help(" ", 1, "OGA290SOMQTFIS") 		
	EndIF
	
Return lRet


/** {Protheus.doc} AGRXNJRN9A
Função que preenche os campos de entidade entre njr (contrato) e n9a ( regra fiscal)
@author:    mauricio.joao
@since:     25/06/2019
@Uso:       OGA290, OGA270
*/
Function AGRXNJRN9A(oField,cCampo) 
	Local oModel	:= nil
	Local oModelNJR := nil
	Local oModelN9A := nil
	Local oModelNNY := nil
    Local cCgc      := ""
    Local cNatureza := ""
    Local cTipoCL   := ""

	Local nLinNNY 	:= 0
	Local nLinN9A	:= 0

    Default cCampo := ""	

	oModel    := oField:GetModel()
    oModelNJR := oModel:GetModel("NJRUNICO")
	oModelN9A := oModel:GetModel("N9AUNICO")
	oModelNNY := oModel:GetModel("NNYUNICO")

	cCgc := Posicione("NJ0",1,xFilial("NJ0")+ oModelNJR:GetValue("NJR_CODENT")+oModelNJR:GetValue("NJR_LOJENT"),"NJ0_CGC" )

    If cCampo $ "NJR_CODENT-NJR_LOJENT-NJR_CODTER-NJR_LOJTER"
        If Empty(cCgc)
            oModelNJR:ClearField("NJR_TIPOCL")
        Else
            If oModelNJR:GetValue("NJR_TIPO")  == '2' //VENDA                                
                cNatureza := Posicione("SA1",3,xFilial("SA1")+ cCgc,"A1_NATUREZ" )                
            ElseIF oModelNJR:GetValue("NJR_TIPO")  == '1' //COMPRA                                
                cNatureza := Posicione("SA2",3,xFilial("SA2")+ cCgc,"A2_NATUREZ" )                 
            EndIf
            cTipoCL  := Posicione("SA1",3,xFilial("SA1")+ cCgc,"A1_TIPO" )
            oModelNJR:SetValue("NJR_TIPOCL",  cTipoCL) //setvalue para ativar gatilho 
        EndIf	        
    EndIf

    If !__lnewNeg
		return
	EndIf

	For nLinNNY := 1 To oModelNNY:Length()
		oModelNNY:GoLine(nLinNNY)

		For nLinN9A := 1 To oModelN9A:Length()
			oModelN9A:GoLine(nLinN9A)
			
            Do Case
                Case cCampo $ "NJR_CODENT-NJR_LOJENT"
                    If Empty(oModelNJR:GetValue("NJR_CODENT")) .OR. Empty(oModelNJR:GetValue("NJR_LOJENT"))
                        oModelN9A:ClearField("N9A_CODENT")
                        oModelN9A:ClearField("N9A_LOJENT")
                        oModelN9A:ClearField("N9A_NOMENT")
                        oModelN9A:ClearField("N9A_NMLJEN")
                        oModelN9A:ClearField("N9A_TIPCLI")			
                    Else
                        oModelN9A:LoadValue("N9A_CODENT", oModelNJR:GetValue("NJR_CODENT") )
                        oModelN9A:LoadValue("N9A_LOJENT", oModelNJR:GetValue("NJR_LOJENT") )
                        oModelN9A:LoadValue("N9A_NOMENT", Posicione('NJ0',1,XFILIAL('NJ0')+oModelNJR:GetValue("NJR_CODENT")+oModelNJR:GetValue("NJR_LOJENT"),'NJ0_NOME')  )
                        oModelN9A:LoadValue("N9A_NMLJEN", Posicione('NJ0',1,XFILIAL('NJ0')+oModelNJR:GetValue("NJR_CODENT")+oModelNJR:GetValue("NJR_LOJENT"),'NJ0_NOMLOJ') )
                        oModelN9A:LoadValue("N9A_TIPCLI", cTipoCL ) //setvalue para ativar gatilho 
                        oModelN9A:LoadValue("N9A_NATURE", cNatureza) 
                    EndIf                           

                Case cCampo $ "NJR_CODTER-NJR_LOJTER"
                    If Empty(oModelNJR:GetValue("NJR_CODTER")) .OR. Empty(oModelNJR:GetValue("NJR_LOJTER"))
                        oModelN9A:ClearField("N9A_ENTENT")
                        oModelN9A:ClearField("N9A_LJEENT")
                        oModelN9A:ClearField("N9A_NMEENT")
                        oModelN9A:ClearField("N9A_NLJENT")
                    Else
                        oModelN9A:LoadValue("N9A_ENTENT", oModelNJR:GetValue("NJR_CODTER") )
                        oModelN9A:LoadValue("N9A_LJEENT", oModelNJR:GetValue("NJR_LOJTER") )
                        oModelN9A:LoadValue("N9A_NMEENT", Posicione('NJ0',1,XFILIAL('NJ0')+oModelNJR:GetValue("NJR_CODTER")+oModelNJR:GetValue("NJR_LOJTER"),'NJ0_NOME')  )
                        oModelN9A:LoadValue("N9A_NLJENT", Posicione('NJ0',1,XFILIAL('NJ0')+oModelNJR:GetValue("NJR_CODTER")+oModelNJR:GetValue("NJR_LOJTER"),'NJ0_NOMLOJ') )
                    EndIf
                
                Case cCampo $ "NJR_CODFIN-NJR_DESFIN"			
                    oModelN9A:LoadValue("N9A_CODFIN", oModelNJR:GetValue("NJR_CODFIN"))
                    oModelN9A:LoadValue("N9A_DESFIN", oModelNJR:GetValue("NJR_DESFIN"))	
                
                Case cCampo == "NJR_INCOTE"
                    oModelN9A:LoadValue("N9A_INCOTE", oModelNJR:GetValue("NJR_INCOTE"))	
                
                Case cCampo == "NJR_CONDPA"
                    oModelN9A:LoadValue("N9A_CONDPA", oModelNJR:GetValue("NJR_CONDPA"))	
                
                Case cCampo == "NJR_CONDPG"
                    oModelN9A:LoadValue("N9A_CONDPG", oModelNJR:GetValue("NJR_CONDPG"))	
                
                Case cCampo == "NJR_CTREXT"
                    oModelN9A:LoadValue("N9A_CTREXT", oModelNJR:GetValue("NJR_CTREXT"))	

                Case cCampo == "NJR_CODPRO"
                    oModelN9A:LoadValue("N9A_CODPRO", oModelNJR:GetValue("NJR_CODPRO"))	
                
                Case cCampo == "NJR_TIPO"
                    oModelN9A:LoadValue("N9A_TIPCTR", oModelNJR:GetValue("NJR_TIPO"))	
                    
            EndCase
            

		Next nLinN9A

		oModelN9A:GoLine(1)

	Next nLinNNY
	
	oModelNNY:GoLine(1)
Return

/*{Protheus.doc} AGRXRESI
Busca o tipo commodite do produto
@author Christopher.miranda
@since 03/04/2019
@version undefined
@type function
*/
Function AGRXRESI(cProd)
	Local aArea   := GetArea()
	Local lRet	  := .T.

	If Posicione("SB5",1,fwxFilial("SB5")+cProd,"B5_TPCOMMO") == '1'
		lRet :=.F.
	EndIf

	RestArea(aArea)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRXATUNN8
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function AGRXATUNN8(cSit)
    Local aAreaNN8 := NN8->(GetArea())
	
	NN8->( dbSetOrder( 1 ) )
	NN8->( dbSeek( xFilial( "NN8" ) + NJR->NJR_CODCTR ) )
	While !NN8->(EOF()) .and. NN8->NN8_FILIAL = NJR->NJR_FILIAL .and. NN8->NN8_CODCTR = NJR->NJR_CODCTR  
		If RecLock( "NN8", .F. )
			NN8->( NN8_SITCTR ) := cSit
			NN8->( msUnLock() )
		EndIf
		NN8->(dbSkip())
	EndDo
	
    RestArea(aAreaNN8)
Return


/*/{Protheus.doc} AGRXATUQTD()
	atualiza o campo NJR_qtdini
	@type  Function
	@author mauricio.joao
	@since 11/12/2019
	@version 1.0
	/*/
Function AGRXATUQTD(oModelNNY, cAcao, xVrNovo, xVrAnt, nLinha, cCampo)
	Local lRet := .T.
	Local nQtdInt := 0
	Local nLinNNY := 0
	Local oModel	:= oModelNNY:GetModel()

	If cAcao $ "DELETE|UNDELETE"  .Or. cCampo == "NNY_QTDINT" 
		If cCampo == "NNY_QTDINT" .And. cAcao $ "SETVALUE"
			For nLinNNY := 1 to oModelNNY:Length() //não trás os deletados.	
				If nLinNNY <> nLinha .And. !oModelNNY:IsDeleted(nLinNNY)			
					nQtdInt += oModelNNY:GetValue("NNY_QTDINT",nLinNNY)
				EndIf 
			Next nLinNNY

			If xVrAnt == 0
				nQtdInt += (xVrNovo - xVrAnt)
			Else
				nQtdInt += (xVrNovo)
			EndIf		
			
			If !AGRXQTDVIN(oModelNNY, nQtdInt) //valida vinculos					
				lRet := .F.
			EndIf		
		ElseIf cAcao $ "DELETE"
			For nLinNNY := 1 to oModelNNY:Length() 
				If nLinNNY <> nLinha .And. !oModelNNY:IsDeleted(nLinNNY)	
					nQtdInt += oModelNNY:GetValue("NNY_QTDINT",nLinNNY)
				EndIf
			Next nLinNNY
		ElseIf cAcao $ "UNDELETE"
			For nLinNNY := 1 to oModelNNY:Length() 
				If nLinNNY == nLinha .Or. !oModelNNY:IsDeleted(nLinNNY)	
					nQtdInt += oModelNNY:GetValue("NNY_QTDINT",nLinNNY)	
				EndIf		
			Next nLinNNY			
		EndIf 	

		If lRet .AND. nQtdInt > 0 .and. oModel:GetModel("NJRUNICO"):Cansetvalue('NJR_QTDINI') //verifico se posso atribuir valor
			oModel:GetModel("NJRUNICO"):SetValue("NJR_QTDINI",nQtdInt)
			
			If oModel:GetId() $ "OGA270|OGA280|OGA290|OGA700" .And. __lnewNeg
				AGRXNNYQTD(oModelNNY,xVrNovo) 
			EndIf
		EndIf 

	EndIf

Return lRet

/*/{Protheus.doc} AGRXVALFIX
Usado para validar se pode alterar a fixação, se tem fixação 
@type function
@version P12  
@author mauricio.joao
@since 10/12/2019
@param cCodCtr, character, Codigo do contrato
@param lValor, logical, Se valida se deve ter valor na fixação
@return Logical, .T. não tem fixação, .F. tem fixação
/*/
Function AGRXVALFIX(cCodCtr,lValor)
	Local lRet := .T.
	Local cAliasNN8  := GetNextAlias()
	Local cFiltroQry := "%%"
	Default lValor := .F.

	If lValor
		cFiltroQry := "% NN8_VLRUNI > 0 AND %" //fixação com valor
	EndIf

	BeginSQL alias cAliasNN8
	SELECT
		NN8.NN8_CODCTR,NN8.NN8_VLRUNI
	FROM
		%table:NN8% NN8
	WHERE
		NN8_FILIAL = %xFilial:NN8% AND
		NN8_CODCTR = %Exp:cCodCtr% AND
		NN8_TIPOFX = '1' AND
		%Exp:cFiltroQry%
		NN8.%notDel%
	EndSql
	
	While (cAliasNN8)->( !Eof() )
		//se  encontrou registro é porque existe  quantidade entregue fixada.
		lRet := .F. 	
		(cAliasNN8)->(DbSkip()) 
		Exit
	Enddo 
	(cAliasNN8)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} AGRXQTDVIN()
	verifica vinculo de candeica
	@type  Function
	@author mauricio.joao
	@since 12/12/2019
	@version 1.0
	/*/
Function AGRXQTDVIN(oModelNNY, nQuantVinc)
	Local lRetorno  	:= .T.
	Local oModel    	:= oModelNNY:GetModel() 
	Local nQtalocada	as numeric	
	Local cTpCtrato 	as char

	//-- Verifico se  o item do Ctrato de parceria pode ser deletado;
	IF oModel:GetValue("NJRUNICO","NJR_TIPO") == '1'
		cTpCtrato := '2'//Contrato de compra
	ElseIf oModel:GetValue("NJRUNICO","NJR_TIPO") == '2'
		cTpCtrato := '1'//contrato de venda
	EndIf

	nQtalocada := OG285CTRV(oModel:GetValue("NJRUNICO","NJR_CODCTR"),oModelNNY:GetValue('NNY_ITEM'), nQuantVinc, cTpCtrato)

	If nQuantVinc < nQtalocada 
		Help( ,,STR0001,, STR0018 , 1, 0 ) //"AJUDA"###"Cadencia Vinculada, Nao e Possivel Reduzir a Quantidade da Cadencia, Verifique o(s) Vinculo(s) do Contrato!"
		lRetorno := .f.
	EndIf
	IF nQtalocada > nQuantVinc
		Help( ,,STR0001,, STR0018 , 1, 0 ) //"AJUDA"###"Cadencia Vinculada, Nao e Possivel Reduzir a Quantidade da Cadencia, Verifique o(s) Vinculo(s) do Contrato!"
		lRetorno := .f.
	EndIf
	
Return ( lRetorno )


/*{Protheus.doc} AGRXBOLSA
Busca Bolsa
@author rafael.voltz
@since 14/02/2019
@version undefined
@type function
*/
Function AGRXBOLSA()
	
	Local oModel 	 as object
	Local oModelNJR  as object
	Local cProduto   as char
	Local cAliasQry  as char
	Local cBolsa     as char

	cBolsa     := ""	
	
	If __lRegOpcional  .and. __lnewNeg
		oModel 	   := FwModelActive() 
		oModelNJR  := oModel:GetModel("NJRUNICO")
		cProduto   := oModelNJR:GetValue("NJR_CODPRO") //produto
		cAliasQry  := GetNextAlias()		

		BeginSql Alias cAliasQry
			SELECT N8U_CODBOL
			FROM %table:N8U%
			WHERE N8U_FILIAL = %xFilial:N8U%
			AND N8U_CODPRO = %Exp:cProduto%
			AND %notDel%
		EndSql			
		
			
		While (cAliasQry)->(!Eof())				
			cBolsa := (cAliasQry)->N8U_CODBOL
			exit
		Enddo
		
		(cAliasQry)->(DbcloseArea())
	EndIf 
	

Return cBolsa


/*{Protheus.doc} AGRXVQIE
//Verifica se o fardo possue IE.
@author roney.maia
@since 20/03/2018
@version 1.0
@type function
*/
Function AGRXVQIE(cFilFar, cSafra, cEtiq)

	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cAliasQry	:= ""
	Local cRet		:= "0"

	cQuery += "SELECT N9D_FILIAL, N9D_SAFRA, N9D_FARDO FROM " + RetSqlName("N9D") + " N9D"
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND N9D_FILIAL='" + cFilFar + "'"
	cQuery += " AND N9D_SAFRA='" + cSafra + "'"
	cQuery += " AND N9D_FARDO='" + cEtiq + "'"
	cQuery += " AND N9D_TIPMOV='04'" // ("04" Instrução de Embarque)
	cQuery += " AND N9D_CODINE <> ''" // Instrução de embarque diferente de vazio, ouseja, possue instrução
	cQuery += " AND N9D_STATUS='2'" // Status Ativo

	cAliasQry := GetSqlAll(cQuery)	// Executa a query e retorna o alias													 
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())

	If !(cAliasQry)->(EOF())
		cRet := "1"
	EndIf

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
	
Return cRet


/*{Protheus.doc} AGRXRECDXI
//Resgate de recno dos fardos para seleção de fardos.
@author roney.maia
@since 20/03/2018
@version 1.0
@type function
*/
Function AGRXRECDXI(cFilFar, cSafra, cEtiq)

	Local aArea := GetArea()
	Local nRet	:= 0	

	nRet := GetDataSql("SELECT R_E_C_N_O_ FROM " + RetSqlName("DXI") + ;
					" WHERE DXI_FILIAL = '" + cFilFar + "' AND DXI_SAFRA = '" + cSafra + "'AND DXI_ETIQ = '" + cEtiq + ;
					"' AND D_E_L_E_T_ = ' ' " )

	RestArea(aArea)
	
Return nRet


/*{Protheus.doc} AGRXPFLEG
//Retorna o tipo de legenda, conforme o status
para o inicializador padrao.
@author roney.maia
@since 27/04/2018
@version 1.0
@return ${return}, ${Tipo de cor da legenda}
@param cStatus, characters, Código de status
@type function
*/
Function AGRXPFLEG(cStatus)
	
    Local cTpCor := ""
	
	If cStatus = "1"
		cTpCor := "BR_VERDE"
	ElseIf  cStatus = "2"
		cTpCor := "BR_AMARELO"
	ElseIf  cStatus = "3"
		cTpCor := "BR_VERMELHO"
	ElseIf  cStatus = "4"
		cTpCor := "BR_LARANJA"
	ElseIf  cStatus = "5"
		cTpCor := "BR_VIOLETA"	
	EndIf
	
return cTpCor

/*/{Protheus.doc} AGRXAtuN9A()
	Atualiza os campos da N9A
	@type  Static Function
	@author mauricio.joao
	@since 12/12/2019
	@version 1.0
	/*/
Function AGRXAtuN9A(oFieldModel, cAction, cIDField, xValue)
	Local oModel := oFieldModel:GetModel()
	Local nLinN9A as numeric
	Local nLinNNY as numeric
	Local nLinNN7 as numeric

 	If cAction == "SETVALUE" .And.	cIDField $ "NJR_TESEST|NJR_CODFIN|NJR_CODENT|NJR_LOJENT|NJR_CODPRO|NJR_CTREXT|"
		oStrNNY := oModel:GetModel("NNYUNICO")
		oStrN9A := oModel:GetModel("N9AUNICO")
		oStrNN7 := oModel:GetModel("NN7UNICO")
		
		//for no nny e depois n9a
		For nLinNNY := 1 to oStrNNY:Length()
			oStrNNY:Goline(nLinNNY)
			For nLinN9A := 1 to oStrN9A:Length()
				oStrN9A:Goline(nLinN9A)
				Do Case
					Case cIDField == 'NJR_TESEST'
						oStrN9A:SetValue("N9A_TES",xValue)
					Case cIDField == 'NJR_CODFIN'
						oStrN9A:SetValue("N9A_CODFIN",xValue)
					Case cIDField == 'NJR_CODENT'
						oStrN9A:SetValue("N9A_CODENT",xValue)
					Case cIDField == 'NJR_LOJENT'
						oStrN9A:SetValue("N9A_LOJENT",xValue)	
				EndCase
			Next nLinN9A
		Next nLinNNY			
		
		If Empty(oModel:GetValue("NJRUNICO","NJR_CODNGC"))
			nLinNN7BKP := oStrNN7:GetLine()
			For nLinNN7 := 1 to oStrNN7:Length()				
				oStrNN7:Goline(nLinNN7)
				If oStrNN7:HasField("NN7_NOMENT") 
					oStrNN7:SetValue("NN7_NOMENT",Posicione('NJ0',1,xFilial('NJ0')+oModel:GetValue("NJRUNICO","NJR_CODENT") + oModel:GetValue("NJRUNICO","NJR_LOJENT"),'NJ0_NOME'))
				EndIf
				If cIDField == "NJR_CODPRO"
					oStrNN7:SetValue("NN7_DESPRO",Posicione('SB1',1,xFilial('SB1')+xValue ,'B1_DESC') )
				EndIf
				If cIDField == "NJR_CTREXT"
					oStrNN7:SetValue("NN7_CTREXT",oModel:GetValue("NJRUNICO","NJR_CTREXT") )
				Endif				
			Next nLinNN7
			oStrNN7:Goline(nLinNN7BKP)
		EndIf
		//posiciona as linhas.
		oStrNNY:Goline(1)
		oStrN9A:Goline(1)		

	EndIf

Return .T.


/*{Protheus.doc} AGRXVLDN84
(Função de pos-validação da Grid N84)
@type function
@author Marcelo Ferrari
@since 28/08/2017
@version 1.0
@param ValidaN84, objeto, (FwFormGrid - N84)
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/
Function AGRXVLDN84(oMdGrid) 

	Local lRet 		:= .T.
	Local nIt		:= 0
	Local oModel	:= oMdGrid:GetModel()
	Local oModelNJR	:= oModel:GetModel("NJRUNICO")
	Local oModelN84	:= oModel:GetModel("N84UNICO")	
	Local nTotal    := 0
	Local cTipo     := ""
	Local cTipoLn   := ""
	Local nMaxValor := 0
	Local lExiste   := .F.


	nTotal    := 0
	cTipoLn := ""
	For nIt := 1 TO oModelN84:Length()
		
		//Guarda o tipo valor da linha corrente do For nIt que pode ser do xValueNew ou do GetValue
		If oModelN84:IsDeleted(nIt)
			Loop
		EndIF
		
		cTipoLn := (oModelN84:GetValue("N84_TIPVAL", nIt))
		If Empty(cTipo)
			//Guarda o primeiro tipo encontrado para Tipo Valor
			cTipo := cTipoLn
		Else
			//Compara o tipo da linha corrente com o Tipo da primeira linha
			If cTipoLn != cTipo
				Help(" ",1,"OGA290N84TIPO") // # O Tipo de valor divergente.  // O Tipo de valor deve ser igual para todas as condições de pagamento informadas.
				lRet := .F.  //Indica que existe uma inconsistência e não irá gerar a previsão financeira ainda
				Return lRet
			EndIF
		EndIf

        //verificar se o tipo de referencia é data fixa e se o campo data nao está em branco
        If (oModelN84:GetValue("N84_REFCTR", nIt)) == '7' .AND. Empty(oModelN84:GetValue("N84_DTFIXA", nIt)) 
            Help("", 1, "OGA290VDTFIXA") //Data negociada não pode ser menor que a data atual .
            lRet := .F.
            Return lRet
        EndIf
              
		If (oModelN84:GetValue("N84_TIPVAL", nIt)) = '1'  //Quantidade
			nTotal += (oModelN84:GetValue("N84_QTDE", nIt))
		Else
			nTotal += (oModelN84:GetValue("N84_PCT", nIt))
		EndIf
		lExiste := .T.
	Next nIt

	nMaxValor := IIF(cTipo=="1", (oModelNJR:GetValue("NJR_QTDINI")), 100  )
	If lRet .AND. lExiste
		If nMaxValor != nTotal
			lRet := .F.
			If cTipo == "1"
				Help(" ",1,"OGA290N84QTD") //"A soma das quantidade é superior ao limite do contrato"
			Else
				Help(" ",1,"OGA290N84PCT") //A soma dos percentuais deve estar entre 0 (zero) e 100 (cem)
			EndIF  
		EndIf
	EndIf 
		
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AGRXVLDNNF
Valida comissão
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function AGRXVLDNNF(oModel)
	Local aAreaN79 := N79->(GetArea())
	Local oModelNNF := oModel:GetModel("NNFUNICO")
	Local nX       := 1
	Local lRet     := .T.
	Local nOperation := oModel:GetOperation()
 
	N79->(dbSetOrder(1))
	If N79->(Dbseek(oModel:GetValue("NJRUNICO", "NJR_FILIAL") + oModel:GetValue("NJRUNICO", "NJR_CODNGC") + oModel:GetValue("NJRUNICO","NJR_VERSAO")))
		If !Empty(N79->N79_CODCOR) .AND. nOperation != MODEL_OPERATION_DELETE       
	        If oModelNNF:length(.t.) == 0
	            AGRHELP(STR0001,STR0037, STR0038) //Corretora não informada no contrato de venda. //"Quando o registro de negócio possui corretora informada é obrigatório ser informado no contrato de venda. Por favor, informe os dados na aba 'Corretoras'."
	            lRet := .F.
	        Else
	            For nX := 1 to oModelNNF:Length()            
	                oModelNNF:GoLine(nX)
	                If !oModelNNF:IsDeleted()
	                    If Empty(oModelNNF:GetValue("NNF_CODENT"))
	                        AGRHELP(STR0001,STR0037, STR0038) //Corretora não informada no contrato de venda. //"Quando o registro de negócio possui corretora informada é obrigatório ser informado no contrato de venda. Por favor, informe os dados na aba 'Corretoras'."
	                        lRet := .F.
	                    ElseIf Empty(oModelNNF:GetValue("NNF_MODCOM")) //"Tipo de cálculo da comissão não foi informado."  //"Por favor, informe os dados na aba de 'Corretoras'."                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	                        AGRHELP(STR0001,STR0035,STR0036)
	                        lRet := .F.
	                    ElseIf oModelNNF:GetValue("NNF_VLBCOM") == 0
	                        AGRHELP(STR0001,STR0033,STR0034) //"Valor base da comissão não foi informado." //"Por favor, informe os dados na aba de 'Corretoras'."
	                        lRet := .F.
	                    EndIf
	                EndIf
	            Next nX        
	            oModelNNF:GoLine(1)
	        EndIf
	    EndIf
	EndIf
	
	RestArea(aAreaN79)

Return lRet


/*{Protheus.doc} AGRXN84Upd
Trata o Update dos campos de condição de pagamento
@author jean.schulze
@since 06/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oGrid, object, descricao
@param nLine, numeric, descricao
@param cAction, characters, descricao
@param cIDField, characters, descricao
@param xNewValue, , descricao
@type function
*/
Function AGRXN84Upd(oGrid, nLine, cAction, cIDField, xNewValue)
	Local lRetorno := .t.
	Local nQuantidade := 0
    Local cSolucao   := ""
		
	//se tem quantidade vinculada ou pagamento vinculado
	if oGrid:GetValue("N84_QTDVNC") > 0 .or. oGrid:GetValue("N84_PAGVNC") == "1"
		
		if cAction == "DELETE" 
			Help( , ,STR0001, , STR0032, 1, 0) // "Quando a condição de pagamento já foi operacionalizada, esta não pode ser deletada."
	        return .f.
		endif
		
		if cAction == "SETVALUE" 
            If !(cIDField $ "N84_QTDE|N84_PCT" )
			 	If oGrid:GetValue("N84_PAGVNC") == "1"
                    Help( , ,STR0001, , STR0030, 1, 0, , , , , , {STR0031} ) //"Quando já houve vínculo de pagamento a essa condição de pagamento não é possível a alteração." //"Acesse o Painel Financeiro e remova o vínculo de pagamento."                    
                Else                
                    Help( , ,STR0001, ,STR0029, 1, 0) //"Quando a condição de pagamento já foi operacionalizada, somente os campos de quantidade podem ser atualizados."
	            EndIf 
                return .f.
	        endif   
	         
		    if cIDField == "N84_QTDE" 
		    	nQuantidade :=  xNewValue
		    elseif cIDField == "N84_PCT"  
		    	nQuantidade :=  (xNewValue / 100 ) * oGrid:GetModel():GetModel("NJRUNICO"):GetValue( "NJR_QTDCTR" )
		    endif
		    
		    if nQuantidade < oGrid:GetValue("N84_QTDVNC")                 
                cSolucao := STR0028 + str(oGrid:GetValue("N84_QTDVNC")) + " " + oGrid:GetModel():GetModel("NJRUNICO"):GetValue( "NJR_UM1PRO" ) + " ( " + str((oGrid:GetValue("N84_QTDVNC") / oGrid:GetModel():GetModel("NJRUNICO"):GetValue( "NJR_QTDCTR" )) * 100) + " % )"  //"Volume Faturado: "                                  

		    	Help( , ,STR0001, , STR0027, 1, 0, , , , , , {cSolucao}) //"A quantidade da Condição de Pagamento é menor que a quantidade já operacionalizada."
		        return .f.
		    elseif (nQuantidade = 0 .and. oGrid:GetValue("N84_PAGVNC") == "1")	 
		       	Help( , ,STR0001, , STR0026 , 1, 0) //"A condição de pagamento que tem pagamento vinculado não pode ter quantidade menor que 0."
		       	return .f.
		    endif
		endif 
	endif

	If cAction == "SETVALUE" .And. cIDField == "N84_REFCTR" .And. xNewValue <> '7'
		oGrid:ClearField("N84_DTFIXA")
		oGrid:ClearField("N84_REFPRF")
	EndIf	

return lRetorno

/*/{Protheus.doc} AGRXN8DAut()
função que realiza o ajute na N8D automático após a quebra de quantidade
@type  Static Function
@author Filipe.Olegini
@since 05/12/2018
@version 1.0
@param oModel, Objeto, Modelo da view
@return .T./.F., Logical, 
/*/

Function AGRXN8DAut(oModel,cFilCtr,cCodCtr,cCtrFixo)
	Local aAreaNN8  := NN8->(GetArea())
	Local aAreaN8D  := N8D->(GetArea())		
	Local cAliasNN8	:= GetNextAlias()
	Local cItemFix	:= ""		
	Local cCadencia := ""
	Local oMdlN9A	:= oModel:GetModel("N9AUNICO")
	Local oMdlNNY	:= oModel:GetModel("NNYUNICO")
	Local nLine		:= oMdlN9A:GetLine()
	Local nLinNNY   := 0
	Local nLinN9A   := 0
	Local nSeq      := 0
	Local nX        := 0			
	Local lFixacao  := .F.	
	Local lAchouN8D := .F.
	Local aItemFix  := {}
	Local aVlrUnit  := {}
	Local lFixo     := Iif(cCtrFixo == "2", .F., .T.) 	
	Local cFilBkp  := cFilAnt //ARMAZENA A FILIAL ATUAL LOGADA
	
	cFilAnt  := cFilCtr //LOGA NA FILIAL PASSADA NO PARAMETRO
			
	If lFixo
		lFixacao := 'S' = GetDataSql("SELECT DISTINCT 'S' res " + ;
									"FROM " + RetSqlName("N9A") + " N9A " + ;
									"LEFT JOIN " + RetSqlName("N8D") + " N8D ON " + ;
									"  N8D_FILIAL = '" + fWxFilial("N8D") + "' AND " + ;
									"  N8D_CODCTR = N9A_CODCTR AND " + ;
									"  N8D_CODCAD = N9A_ITEM   AND " + ;
									"  N8D_REGRA  = N9A_SEQPRI AND " + ;
									"  N8D.D_E_L_E_T_ = N9A.D_E_L_E_T_  " + ;
									"LEFT JOIN " + RetSqlName("NN8") + " NN8 ON " + ;
									"  NN8_FILIAL = '" + fWxFilial("NN8") + "' AND " + ;
									"  NN8_CODCTR = N8D_CODCTR AND " + ;
									"  NN8_CODCAD = N8D_CODCAD AND " + ;
									"  NN8_ITEMFX = N8D_ITEMFX AND " + ;
									"  NN8.D_E_L_E_T_ = N9A.D_E_L_E_T_  " + ;
									"WHERE N9A_FILIAL = '" + fWxFilial("N9A") + "' " + ;
									"  AND N9A_CODCTR = '" + cCodCtr + "' " + ;
									"  AND N9A.D_E_L_E_T_ = ' ' " + ;
									"  AND (N8D.R_E_C_N_O_ IS NULL OR N8D.R_E_C_N_O_ = 0 )" )
		
		If lFixacao  //Se retornar "S" é porque existem Regra fiscal sem FIXAÇÃO
			If __lRegOpcional
				Return .T.	 //ainda não existe fixação quando o Registro Negócio é opcional
			else	
				Return .F.
			EndIf
		EndIf
	Endif

	Begin Transaction		
		
		//contador para sequencia.
		nSeq := 1

		//refaz a N8D com base na N9A - 1 para 1
		
		//Percorro todas as cadencias (NNY)
		For nLinNNY := 1 to oMdlNNY:Length()
			oMdlNNY:GoLine(nLinNNY)

			//Deleto todas as priorizações (N8D) dessa cadencia			
			N8D->(DbSetOrder(3))
			If N8D->(DbSeek( cFilCtr + cCodCtr + oMdlNNY:GetValue("NNY_ITEM")  ))
				lAchouN8D := .T.
				While N8D->( !Eof() ) .AND. AllTrim(N8D->(N8D_FILIAL+N8D_CODCTR+N8D_CODCAD)) == AllTrim(cFilCtr + cCodCtr + oMdlNNY:GetValue("NNY_ITEM") )
	        				
					If RecLock('N8D',.F.) 
						dbDelete()
						N8D->(MsUnLock())
					EndIf
					N8D->(DbSkip())
				EndDo
			EndIf

			cCadencia := oMdlNNY:GetValue("NNY_ITEM") 
			
			//busca o valor unitário da fixação
			If Select(cAliasNN8) <> 0
				(cAliasNN8)->(dbCloseArea())
			EndIf 

			BeginSQL Alias cAliasNN8 
				SELECT NN8_VLRUNI, NN8_QTDFIX, NN8_ITEMFX
				FROM %Table:NN8% 				
				WHERE %notDel%
					AND NN8_FILIAL = %XFilial:NN8%
					AND NN8_CODCTR = %Exp:cCodCtr%
					AND NN8_CODCAD = %Exp:cCadencia%
			EndSQL

			While (cAliasNN8)->(!Eof())
				aAdd(aVlrUnit, {(cAliasNN8)->NN8_VLRUNI,(cAliasNN8)->NN8_QTDFIX, (cAliasNN8)->NN8_ITEMFX } )
				(cAliasNN8)->(DbSkip())
			EndDo

			(cAliasNN8)->(dbCloseArea())

			If lAchouN8D 
				//Refaço as priorizações pra cada regra fiscal (N9A)
				For nLinN9A := 1 To oMdlN9A:Length()
					oMdlN9A:GoLine(nLinN9A)							

					If !(oMdlN9A:isDeleted())			
						nQtdRegra := oMdlN9A:GetValue("N9A_QUANT", nLinN9A)

						For nX := 1 To Len(aVlrUnit)						
							
							If aVlrUnit[nX][2] > 0 .AND. nQtdRegra > 0 
							
								cItemFix  := aVlrUnit[nX][3]								  				
										
								If RecLock('N8D',.T.)
									N8D->N8D_FILIAL	:= cFilCtr
									N8D->N8D_CODCTR	:= cCodCtr
									N8D->N8D_ITEMFX := cItemFix
									N8D->N8D_ORDEM	:= StrZero(nSeq,TamSX3("N8D_ORDEM")[1])
									N8D->N8D_BLOCO	:= nil
									N8D->N8D_QTDFAR	:= 0

									If !lFixo
										If aVlrUnit[nX][2] > nQtdRegra
											N8D->N8D_QTDVNC := nQtdRegra										
											aVlrUnit[nX][2]	-= nQtdRegra		
											nQtdRegra       := 0		
										Else
											N8D->N8D_QTDVNC := aVlrUnit[nX][2]
											nQtdRegra       -= aVlrUnit[nX][2]
											aVlrUnit[nX][2] := 0 //sem saldo												
										Endif			
									Else 
										N8D->N8D_QTDVNC	:= oMdlN9A:GetValue("N9A_QUANT", nLinN9A)
									Endif
									N8D->N8D_FILORG	:= oMdlN9A:GetValue("N9A_FILORG", nLinN9A)
									N8D->N8D_TIPO	:= nil
									N8D->N8D_QTDBTO	:= 0
									N8D->N8D_SEQVNC	:= StrZero(nSeq,TamSX3("N8D_SEQVNC")[1])
									N8D->N8D_VALOR	:= aVlrUnit[nX][1]
									N8D->N8D_QTDFAT	:= oMdlN9A:GetValue("N9A_QTDNF", nLinN9A)
									N8D->N8D_CODCAD	:= oMdlNNY:GetValue("NNY_ITEM") 
									N8D->N8D_REGRA	:= oMdlN9A:GetValue("N9A_SEQPRI", nLinN9A)
									N8D->N8D_CODRES	:= nil
									N8D->(MsUnLock())
								EndIf					
							
							nSeq++												
							Else
								LOOP
							Endif

						Next nX
					EndIf	
				Next nLinN9A

				aItemFix := {}
				aVlrUnit := {}
			Endif
			cFilAnt := cFilBkp //RETORNA PARA A FILIAL LOGADA
			lAchouN8D := .F.
		Next nLinNNY

		oMdlN9A:GoLine(nLine)
		
	End Transaction

	RestArea(aAreaNN8)
	RestArea(aAreaN8D)

Return .T.

/*{Protheus.doc} ValN84
(Função de pos-validação do modelo)
Valida as condições de pagamento
@type function
@author rafael.voltz
@since 17/05/2018
@version 1.0
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/
Function AGRXValN84()	
	Local aAreaN84 := N84->(GetArea())
	Local lRet := .T.

	DbSelectArea("N84")
	N84->(DbSetOrder(1))
	If !N84->(DbSeek(xFilial("N84") + NJR->NJR_CODCTR ))
		If !__lAutomato
            AGRHELP(STR0001, STR0025) //##A condição de pagamento não foi informada. Preencha os dados na pasta Financeiro.
        EndIf
		lRet := .f.	
	EndIf

	RestArea(aAreaN84)	
Return lRet

/*{Protheus.doc} AGRXVLDN9A
Valida a regra fiscal ao confirmar o contrato de venda.
@type function
@author rafael.voltz
@since 17/05/2018
@version 1.0
@return ${return}, ${.T. - Validado, .F. - Não Validado}
*/
Function AGRXVLDN9A(lRetorno, lContinua, lMsgConfir)

	Local aAreaN9A := N9A->(GetArea())

	If __lnewNeg 
		DbSelectArea("N9A")
		DbSetorder(1)
		dbSeek(xFilial("N9A") + NJR->NJR_CODCTR)
		While !N9A->(Eof()) .AND. ( xFilial("N9A") + NJR->NJR_CODCTR == N9A->N9A_FILIAL+N9A->N9A_CODCTR ) .AND. lContinua
			If  Empty(N9A->N9A_TES) .OR.  Empty(N9A->N9A_CODFIN)  .OR. Empty(N9A->N9A_CODENT)
				If lMsgConfir
					Help('',1,".OGA290000001.") //"AJUDA"###Não é possivel Confirmar o contrato se houver Regras Fiscais sem os campos TES, Finalidade e Cod. Entidade informados.
				EndIf
				lRetorno    := .f.
				lContinua   := .f.		
			EndIf
			If (N9A->N9A_OPETRI == '1' .OR. N9A->N9A_OPEFUT  == '1') .AND. Empty(N9A->N9A_TESAUX) 
				If lMsgConfir
					Help('',1,".OGA290000002.") //"AJUDA"###É necessario informar a TES Auxiliar caso o contrato possua Operação Futura ou Operação Triangular.
				EndIf
				lRetorno    := .f.
				lContinua   := .f.		
			EndIf
			If N9A->N9A_OPETRI == '1' .AND. ( Empty(N9A->N9A_ENTENT) .OR. Empty(N9A->N9A_LJEENT)) 
				If lMsgConfir
					Help('',1,".OGA290000007.")
				EndIf
				lRetorno    := .f.
				lContinua   := .f.		
			EndIf

			If Empty(N9A->N9A_NATURE)
				AGRHELP(STR0001,STR0023,STR0024) //Alerta! Natureza financeira não pode ser em branco! Solução: Preencha a natureza financeira no cadastro de clientes
				lContinua    := .f.
			Endif
		
			if  lRetorno  .and.  lRetorno 
				RecLock('N9A',.f.)
				N9A->N9A_TIPMER := NJR->NJR_TIPMER
			Endif 

			N9A->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaN9A)

Return 


/** {Protheus.doc} AGRXTrgNNF
Função criada para realizar gatilho em branco para os campos.
@return:    cRet - conteudo para limpar campo
@author:    Felipe Mendes
@since:     03/01/2018
@Uso:       OGA290 - Contrato de Venda
*/
Function AGRXTrgNNF(oFieldModel, cTipoMer) 
	Local oModel	:= oFieldModel:GetModel()
	Local oNNF      := oModel:GetModel( "NNFUNICO" )
	Local oN9A      := oModel:GetModel( "N9AUNICO" )
	Local nCont     := 0

	If cTipoMer == '1'	//Tipo de Mercado: 1=Interno;2=Externo
	
		For nCont := 1 To oNNF:Length() 
			oNNF:GoLine(nCont)
			oNNF:LoadValue("NNF_TIPCOM",'0')
		Next nCont
		oNNF:GoLine(1)
	EndIf
	
	//Tipo de Mercado: 2=Externo E estiver utilizando o registro de negócio
	If cTipoMer == '2' .AND. __lnewNeg
		If oN9A:Length(.T.)	== 1
			For nCont := 1 To oN9A:Length() 
				oN9A:GoLine(nCont)
				
				If .Not. oN9A:IsDeleted()
					oN9A:LoadValue("N9A_OPETRI",'2')
					oN9A:LoadValue("N9A_OPEFUT",'2')
				EndIf
			Next nCont			
			oN9A:GoLine(1)	
		EndIf
	EndIf
	
Return


/** {Protheus.doc} AGRXTrgOPER
Função criada para realizar gatilho de Operação Triangular e Operação Futura para a grid de Regras Fiscais
@author:    Thiago Henrique Rover
@since:     30/01/2018
@Uso:       OGA290 - Contrato de Venda
*/
Function AGRXTrgOPER(oFieldModel,cIDField,xValue) 
	Local oModel	:= oFieldModel:GetModel()
	Local oNNY		:= oModel:GetModel( "NNYUNICO" )
	Local oN9A      := oModel:GetModel( "N9AUNICO" )
	Local nCont     := 0
	Local nNNY      := 0
	Local nLinNNY	:= oNNY:GetLine()
	
	If __lnewNeg .and. oNNY:Length(.T.) == 1 //se só tem uma entrega
		For nNNY := 1 to oNNY:Length() 
			oNNY:GoLine(nNNY)
			For nCont := 1 To oN9A:Length() 
				oN9A:GoLine(nCont)				
				If .Not. oN9A:IsDeleted() .and. oN9A:Length(.T.) == 1 //se tiver apenas uma regra fiscal ativa 
					If cIDField == "NJR_OPETRI"
						oN9A:LoadValue("N9A_OPETRI", xValue )
					ElseIf cIDField == "NJR_OPEFUT"
						oN9A:LoadValue("N9A_OPEFUT", xValue )
					EndIf
				EndIf
			Next nCont			
			oN9A:GoLine(1)			
		Next nNNY
		oNNY:GoLine(nLinNNY)		
	EndIf	
Return	


/** {Protheus.doc} AGRXNJRCdPg
Validação da condição da pagamento
@param:     Nil
@author:    Tamyris Ganzenmueller
@since:     21/12/2017
@Uso:       SIGAAGR - Originação de Grãos
*/
Function AGRXNJRCdPg(oModelNJR, cCampo, xNewValue)
	local lRetorno := .T.
	
	lRetorno := ExistCpo("SY6",M->NJR_CONDPG,1)
	
Return ( lRetorno )


/** {Protheus.doc} AGRXDiasPg
Validação Dias do Pagamento
@param:     Nil
@author:    Tamyris Ganzenmueller
@since:     21/12/2017
@Uso:       SIGAAGR - Originação de Grãos
*/
Function AGRXDiasPg(oModelNJR, cCampo, xNewValue)
	Local lRetorno  := .T.
	Local cAliasSY6 := GetNextAlias()
	Local nTam      := TamSX3("Y6_DIAS_PA")[1]

	cQuery := "SELECT Y6_DESC_P "
	cQuery +=  " FROM " + RetSqlName('SY6') + ' SY6 '
	cQuery += " WHERE SY6.Y6_FILIAL = '"+ fWxFilial('SY6') + "'"
	cQuery +=   " AND SY6.Y6_COD     = '"+ M->NJR_CONDPG + "'"
	cQuery +=   " AND SY6.Y6_DIAS_PA = " + Str(oModelNJR:GetValue("NJR_DIASPG"),nTam)
	cQuery +=   " AND SY6.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSY6, .F., .T. )

	dbSelectArea(cAliasSY6)
	(cAliasSY6)->(DbGoTop())
	If (cAliasSY6)->(Eof())
		lRetorno := .f.
	Else
		oModelNJR:LoadValue("NJR_DESPG", MSMM((cAliasSY6)->Y6_DESC_P,50))
	Endif

	(cAliasSY6)->( dbCloseArea() )

Return ( lRetorno )


/** {Protheus.doc} AGRXTrgCdPg
Função criada para realizar gatilho do codigo do tipo de remessa conforme cond. pag. exportação escolhido.
@return:    cRetorno - Código do Tipo de Remessa relacionado a condição de pagamento exportação.
@author:    Rafael Kleestadt da Cruz
@since:     12/12/2017
@Uso:       OGA290 - Contrato de Venda
*/
Function AGRXTrgCdPg(oFieldModel, xValue) 
	Local oModel    := oFieldModel:GetModel()
	Local oNJR      := oModel:GetModel( "NJRUNICO" )
	Local cRetorno  := oNJR:GetValue("NJR_CODREM")
	Local cQuery    := ""
	Local cAliasN97 := ""

	If Empty(cRetorno)

		cAliasN97 := GetNextAlias()

		cQuery := " SELECT N97_CODREM "
		cQuery += " FROM " + RetSqlName("N97") + " N97 "
		cQuery += " WHERE N97.N97_MODPAG = '" + xValue + "'"
		cQuery += " AND N97.N97_FILIAL = '" + xFilial("N97") + "'"
		cQuery += " AND N97.D_E_L_E_T_ = ' ' " 
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasN97, .F., .T.) 
		DbselectArea(cAliasN97)
		DbGoTop()
		If (cAliasN97)->(!Eof())
			cRetorno := (cAliasN97)->N97_CODREM
		EndIf

		(cAliasN97)->(DbCloseArea())
	EndIf

Return(cRetorno)


/** {Protheus.doc} AGRXDesRem
Função criada para realizar gatilho da descrição do tipo de remessa conforme cond. pag. exportação escolhido.
@return:    cRetorno - Descrição do Tipo de Remessa relacionado a condição de pagamento exportação.
@author:    Rafael Kleestadt da Cruz
@since:     12/12/2017
@Uso:       OGA290 - Contrato de Venda
*/
Function AGRXDesRem(oFieldModel, cCodRem)
	Local cRetorno := ""

	cRetorno := Posicione("N96", 1, FwXFilial("N96") +  cCodRem, "N96_DESREM") 

Return(cRetorno)


/** {Protheus.doc} AGRXTrgInc
Função criada para realizar gatilho campo Incoterm
@return:    cRet - conteudo do campo
@author:    Tamyris Ganzenmueller
@since:     12/12/2017
@Uso:       OGA290 - Contrato de Venda
*/
Function AGRXTrgInc(oFieldModel, cInCote) 
	Local cRetorno	:= ""

	If cInCote == 'CFR' .OR. cInCote == 'CIF'	
		cRetorno := "1"
	Else
		cRetorno := "2"
	EndIf

Return cRetorno


/*/{Protheus.doc} AGRXQTDN9J
	Função responsável por verificar se existe registro na N9J. Caso não exista, significa que ainda não gerou a previsão financeir.
	@type  Function
	@author user
	@since 14/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function AGRXQTDN9J(cCtr)
 Local nQtdReg   := 0
 Local cAliasQry := GetNextAlias()

 BeginSql Alias cAliasQry
	SELECT COUNT(*) QTD
      FROM %table:N9J%
	  WHERE N9J_FILIAL = %xFilial:N9J%
	    AND N9J_CODCTR = %Exp:cCtr%
		AND %notDel%
 EndSql

 nQtdReg := (cAliasQry)->QTD

 (cAliasQry)->(dbCloseArea())
	
Return nQtdReg


/*/{Protheus.doc} AGRXFINANC()
	(long_description)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function AGRXFINANC()
Local aAreaNJR := NJR->(GetArea())
Local aAreaN9J := N9J->(GetArea())
Local oModel   := NIL

If IsInCallStack("OGA290") .OR. NJR->NJR_TIPO == "2" 
	oModel := FWLoadModel("OGA290")	
Else 
	oModel := FWLoadModel("OGA280")
EndIf

If Empty(NJR->NJR_CODNGC) .and. NJR->NJR_TIPFIX == '1' .and. __lRegOpcional
	AGRHELP(STR0001, STR0039, STR0040)	//"Não há fixação de preço para o contrato." //"Realize a fixação de preço na opção Outras Ações -> Fixação de preço."
	Return
EndIf

/* Se achar N9J indica que já foi efetivado a geração da previsão financeira */
N9J->(DbSetOrder(1))
If N9J->(Dbseek(xFilial("N9J") + NJR->NJR_CODCTR))				
	OGX018(NJR->NJR_FILIAL,NJR->NJR_CODCTR, .F., nil)
Else
	oModel:SetOperation(MODEL_OPERATION_UPDATE) //operação de inclusão					
	oModel:Activate() //ativa o modelo	

	//gera previsão
	OGX018(oModel:getmodel("NJRUNICO"):getvalue("NJR_FILIAL"),oModel:getmodel("NJRUNICO"):getvalue("NJR_CODCTR"), .T., oModel)

	If oModel:VldData()
		oModel:CommitData()

		oModel:DeActivate() // Desativa o modelo
		oModel:Destroy() // Destroy o objeto modelo	
	Else
		AutoGrLog(oModel:GetErrorMessage()[6])
		AutoGrLog(oModel:GetErrorMessage()[7])
		If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
			AutoGrLog(oModel:GetErrorMessage()[2] + " = " + cValToChar(oModel:GetErrorMessage()[9]))
		EndIf

		MostraErro()
	EndIf
	
EndIf

RestArea(aAreaNJR)
RestArea(aAreaN9J)

Return


/*/{Protheus.doc} AGRXCNGC()
	Gera o registro de negocio quando não é obrigatório para inclusão do contrato
	@type  Static Function
	@author mauricio.joao
	@since 22/10/2019
	@version 1.0
	@param param, param_type, param_descr
	/*/
Function AGRXCNGC(cCodCtr, oModel, lAbreFix)
 Local aAreaNJR := NJR->(GetArea())
 Local aAreaN79 := N79->(GetArea())
 Local nLinNNY := 0
 Local nLinN7C := 0 
 Local cSolucao := "" 
 Local lRet     := .T.
 Local lTipoCtr := ""

 Private _cCodPro := ""
 Private _cCodSaf := ""
 Private _cMoedaCtr := ""
 Private _cTipoNgc := ""

	If !AGRXValN84()
		Return .f.
	EndIf	

	If NJR->NJR_TIPO == "2"
		oModel := FWLoadModel("OGA290")
		lTipoCtr := "2"
	ElseIf NJR->NJR_TIPO == "1" 
		oModel := FWLoadModel("OGA280")
		lTipoCtr := "1"
	EndIf

	oModel:SetOperation(MODEL_OPERATION_UPDATE) //operação de inclusão					
	oModel:Activate() //ativa o modelo			

	_cCodPro  	:= oModel:GetValue("NJRUNICO","NJR_CODPRO")
	_cCodSaf  	:= oModel:GetValue("NJRUNICO","NJR_CODSAF")
	_cMoedaCtr 	:= oModel:GetValue("NJRUNICO","NJR_MOEDA")
    _cTipoNgc 	:= lTipoCtr

	If oModel:GetValue("NJRUNICO","NJR_STATUS") $ "A|I|E|F"
		if oModel:GetValue("NJRUNICO","NJR_TIPFIX") == "2"  //à fixar
			cSolucao := STR0041 //Para contratos à fixar, utilize o Painel de Fixações.
		EndIf
		AGRHELP(STR0001, STR0042, cSolucao) //#Atenção #Situação do contrato não permite alteração da fixação..
		lRet := .F.
	EndIf

	//validações : preciso do produto, safra e entidade. se NAO for algodão, preciso da tabela.
	If lRet .AND. empty(oModel:GetValue("NJRUNICO","NJR_CODPRO"));
		.OR. empty(oModel:GetValue("NJRUNICO","NJR_CODSAF"));
		.OR. empty(oModel:GetValue("NJRUNICO","NJR_CODENT")) .OR. empty(oModel:GetValue("NJRUNICO","NJR_LOJENT"));
		.OR. Iif(!AGRTPALGOD(oModel:GetValue("NJRUNICO","NJR_CODPRO")) .AND. empty(oModel:GetValue("NJRUNICO","NJR_TABELA")) , .T., .F.);
		.OR. Iif((oModel:GetValue("NJRUNICO","NJR_TIPFIX") == "2") .AND. empty(oModel:GetValue("NJRUNICO","NJR_BOLSA")) , .T., .F.)		
		
		Help(NIL, NIL, STR0044,; //"Validação de Campos"
		NIL, STR0043,; //"Campos obrigários não foram preenchidos."
		1, 0, NIL, NIL, NIL, NIL, NIL,;
		{STR0045}) //"Favor verificar se campos: Entidade/loja, Produto, Safra, Tabela (caso produto não seja algodão) e Bolsa (caso seja contrato 'a Fixar')."
		lRet := .f.

	EndIf

	If lRet
		For nLinNNY := 1 To oModel:GetModel("NNYUNICO"):Length()
			If Empty(oModel:GetModel("NNYUNICO"):GetValue("NNY_DATINI",nLinNNY));
				.OR. Empty(oModel:GetModel("NNYUNICO"):GetValue("NNY_DATFIM",nLinNNY));
				.OR. Empty(oModel:GetModel("NNYUNICO"):GetValue("NNY_FILORG",nLinNNY));
				.OR. Empty(oModel:GetModel("NNYUNICO"):GetValue("NNY_QTDINT",nLinNNY))						
								
				Help(NIL, NIL, STR0044,; //"Validação de Campos"
					NIL, STR0043,; //"Campos obrigários não foram preenchidos."
					1, 0, NIL, NIL, NIL, NIL, NIL,;
					{STR0046}) //"Favor verificar se campos: Data Inicio, Data Fim, Quantidade, estão preenchidos nas previsões de entrega"
				lRet := .f.
				exit
			EndIf

			//validações para A Fixar.
			If oModel:GetValue("NJRUNICO","NJR_TIPFIX") == "2"	
				//NNY_VMESAN , NNY_DTLFIX , NNY_IDXNEG
				If Empty(oModel:GetModel("NNYUNICO"):GetValue("NNY_DTLFIX",nLinNNY));
				.OR. Empty(oModel:GetModel("NNYUNICO"):GetValue("NNY_IDXNEG",nLinNNY))
					
					Help(NIL, NIL, STR0044,; //"Validação de Campos"
						NIL, STR0043,; //"Campos obrigários não foram preenchidos."
						1, 0, NIL, NIL, NIL, NIL, NIL,;
					{STR0047}) //"Favor verificar se campos:  Mês Bolsa, Dt Lim Fix e Idx. Negócio, estão preenchidos nas previções de entrega"
					lRet := .f.
					exit
				EndIf
			EndIf
		Next nLinNNY
	EndIf

	If lRet
		If Empty(oModel:GetValue("NJRUNICO","NJR_CODNGC"))		
			oModel700 := FWLoadModel("OGA700")				
			oModel700:SetOperation(MODEL_OPERATION_INSERT) //operação de inclusão	
			
			oModel700:Activate() //ativa o modelo		

			//campos obrigatórios
			
			oModel700:GetModel("N79UNICO"):SetValue("N79_TIPO",'1') //tipo	
			oModel700:GetModel("N79UNICO"):SetValue("N79_FILORG",oModel:GetModel("NNYUNICO"):GetValue("NNY_FILORG",1)) //filial origem - Seta a NNY_FILORG da primeira da cadencia
			oModel700:GetModel("N79UNICO"):SetValue("N79_CODCTR",oModel:GetValue("NJRUNICO","NJR_CODCTR"))  //cod ctr
			oModel700:GetModel("N79UNICO"):SetValue("N79_TIPFIX",oModel:GetValue("NJRUNICO","NJR_TIPFIX")) //tipo fixação
			If !AGRTPALGOD(_cCodPro)
                oModel700:GetModel("N79UNICO"):SetValue("N79_TABELA",oModel:GetValue("NJRUNICO","NJR_TABELA") )  //tabela
            EndIf		
			oModel700:GetModel("N79UNICO"):SetValue("N79_TIPMER",oModel:GetValue("NJRUNICO","NJR_TIPMER") ) //Tipo Mercado	
            oModel700:GetModel("N79UNICO"):SetValue("N79_CODENT",oModel:GetValue("NJRUNICO","NJR_CODENT") ) //entidade
			oModel700:GetModel("N79UNICO"):SetValue("N79_LOJENT",oModel:GetValue("NJRUNICO","NJR_LOJENT") ) //loja ent
			oModel700:GetModel("N79UNICO"):SetValue("N79_MOEDA",oModel:GetValue("NJRUNICO","NJR_MOEDA"))  //moeda			
			oModel700:GetModel("N79UNICO"):SetValue("N79_STATUS",'1' ) //status
			oModel700:GetModel("N79UNICO"):SetValue("N79_STCLIE",'1')  //status cli
			If NN7->(ColumnPos("N79_CLASSP")) > 0 
				oModel700:GetModel("N79UNICO"):SetValue("N79_CLASSP",oModel:GetValue("NJRUNICO","NJR_CLASSP"))  
			EndIf
			If NN7->(ColumnPos("N79_CLASSP")) > 0 
				oModel700:GetModel("N79UNICO"):SetValue("N79_CLASSQ",oModel:GetValue("NJRUNICO","NJR_CLASSQ"))  
			EndIf
			
			If oModel:GetValue("NJRUNICO","NJR_TIPFIX") == "2"				
				oModel700:GetModel("N79UNICO"):SetValue("N79_BOLSA",oModel:GetValue("NJRUNICO","NJR_BOLSA"))  //bolsa
			EndIf
			//for nas cadencias
			cSeqN7A := '000'
			For nLinNNY := 1 to oModel:GetModel("NNYUNICO"):Length()
			//cadencia
				//se for mais de uma linha, adiciono e preencho a n7c (componentes)
				If nLinNNY > 1
					oModel700:GetModel("N7AUNICO"):AddLine()
					OGA700CHG(, , oModel700)
				EndIf
				//adiciona o sequencial
				cSeqN7A := soma1(cSeqN7A,3)
				//validações basicas

				oModel700:GetModel("N7AUNICO"):Goline(nLinNNY)
				oModel700:GetModel("N7AUNICO"):SetValue("N7A_CODCAD",cSeqN7A) 
				oModel700:GetModel("N7AUNICO"):SetValue("N7A_DATINI",oModel:GetModel("NNYUNICO"):GetValue("NNY_DATINI",nLinNNY)) 
				oModel700:GetModel("N7AUNICO"):SetValue("N7A_DATFIM",oModel:GetModel("NNYUNICO"):GetValue("NNY_DATFIM",nLinNNY)) 
				oModel700:GetModel("N7AUNICO"):SetValue("N7A_QTDINT",oModel:GetModel("NNYUNICO"):GetValue("NNY_QTDINT",nLinNNY)) 	
				oModel700:GetModel("N7AUNICO"):SetValue("N7A_FILORG",oModel:GetModel("NNYUNICO"):GetValue("NNY_FILORG",nLinNNY)) 
				If oModel:GetValue("NJRUNICO","NJR_TIPFIX") == "2"
			
					oModel700:GetModel("N7AUNICO"):SetValue("N7A_DTLFIX",oModel:GetModel("NNYUNICO"):GetValue("NNY_DTLFIX",nLinNNY)) 	
					oModel700:GetModel("N7AUNICO"):SetValue("N7A_IDXNEG",oModel:GetModel("NNYUNICO"):GetValue("NNY_IDXNEG",nLinNNY)) 	
			
				EndIf
				//for na N7C componentes
				For nLinN7C := 1 to oModel700:GetModel("N7CUNICO"):Length() 					
					oModel700:GetModel("N7CUNICO"):GoLine(nLinN7C) 
					//se for hedge e novo negócio, arredondar qtdctr
					If oModel:GetValue("NJRUNICO","NJR_TIPFIX") == "2" .AND. oModel700:GetModel("N7CUNICO"):GetValue("N7C_HEDGE",nLinN7C) == "1"
						//arredondo pra cima a qtd do contrato futuro.
						oModel700:GetModel("N7CUNICO"):SetValue("N7C_HEDGE","2")
						If (oModel700:GetModel("N7CUNICO"):HasField("N7C_QTDCTR"))
							oModel700:GetModel("N7CUNICO"):SetValue("N7C_QTDCTR",Round(oModel700:GetModel("N7CUNICO"):GetValue("N7C_QTDCTR",nLinN7C),0))
						EndIf
						oModel700:GetModel("N7CUNICO"):SetValue("N7C_BOLSA",oModel:GetValue("NJRUNICO","NJR_BOLSA"))
				
					EndIf
					//forço hedge 2 (não) sempre.
					If oModel700:GetModel("N7CUNICO"):GetValue("N7C_HEDGE",nLinN7C) == "1"
						oModel700:GetModel("N7CUNICO"):SetValue("N7C_HEDGE","2")
					EndIf 
				Next nLinN7C

			Next nLinNNY

			If oModel700:VldData() //valida					
				//commit			
				nCodNgc := oModel700:Getvalue('N79UNICO','N79_CODNGC')							
				
				oModel700:CommitData()				
				oModel700:DeActivate() // Desativa o modelo
				oModel700:Destroy() // Destroy o objeto modelo			

				//aprova o reg de negócio
				OGA700APVA()
				OGA700APMA('4')	

				//chama a precificação
				If lAbreFix
					OGA700FIXA()	
				EndIf

				If oModel:GetValue("NJRUNICO","NJR_TIPFIX") == "1" 
					OGA700APVA()	
				EndIf

				//preciso aprovar o reg de negócio.	
				oModel:GetModel("NJRUNICO"):LoadValue("NJR_CODNGC",nCodNgc )			
				oModel:GetModel("NJRUNICO"):LoadValue("NJR_VERSAO",'1' )						
			
				If oModel:VldData()
					oModel:CommitData()
				EndIf
				
				oModel:DeActivate() // Desativa o modelo
				oModel:Destroy() // Destroy o objeto modelo		
			Else
				//não validou 
				AutoGrLog(oModel700:GetErrorMessage()[6])
				AutoGrLog(oModel700:GetErrorMessage()[7])
				If !Empty(oModel700:GetErrorMessage()[2]) .And. !Empty(oModel700:GetErrorMessage()[9])
					AutoGrLog(oModel700:GetErrorMessage()[2] + " = " + cValToChar(oModel700:GetErrorMessage()[9]))
				EndIf

				If !__lAutomato
					MostraErro()
				EndIf

				oModel700:DeActivate() // Desativa o modelo
				oModel700:Destroy() // Destroy o objeto modelo				
				lRet := .F.
			EndIf
		Else			
			N79->(dbSetOrder(1))
			If N79->(Dbseek(xFilial("N79")+oModel:GetModel("NJRUNICO"):GetValue("NJR_CODNGC") + oModel:GetModel("NJRUNICO"):GetValue("NJR_VERSAO") ))			
				OGA700FIXA()
			EndIf			
		EndIf		
	EndIF

	If lRet .and. lAbreFix
		AGRXFINANC()
	EndIf

	RestArea(aAreaNJR)
	RestArea(aAreaN79)

Return lRet

/*/{Protheus.doc} AGRXVLDVLR
    Valida valor base zerado para contrato de tipo preço fixo.
    @type  Function
    @author user
    @since 30/09/2020
    @version version    
    /*/
Function AGRXVLDVLR()
    Local lRetorno := .T.
	
	If !__lnewNeg .And. NJR->NJR_VLRBAS == 0 .And. NJR->NJR_TIPFIX == "1"
        AgrHelp(STR0001, STR0062,STR0063) //"Não foi informado valor base para o contrato."
        lRetorno := .F.
    EndIf

Return lRetorno

/*/{Protheus.doc} AGRXREFCTR
    Função chamada no VALID  do campo N84_REFCTR via dicionario
	Realiza a Validação permitindo somente as opções definidas via fonte quando contrato de compra 
    @type  Function
    @author claudineia.reinert	
    @since 17/09/2020
    @version version    
    /*/
Function AGRXREFCTR()
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oModelNJR := NIL
	Local oModelN84 := NIL

	If oModel != Nil .AND. oModel:IsActive() .AND. oModel:GetId() == 'OGA280' 
		
		oModelNJR := oModel:GetModel("NJRUNICO")
		oModelN84 := oModel:GetModel("N84UNICO")
		If oModelNJR:GetValue("NJR_TIPO") == "1" .and. oModelN84:GetValue("N84_REFCTR") $ "1|2|3|4"
			lRet := .F. //compra só permite opções 5,6 e 7 conforme definido no fonte
			AgrHelp( STR0001, STR0060 , STR0061 + X3CboxDesc( "N84_REFCTR", "5" ) + ', ' + X3CboxDesc( "N84_REFCTR", "6") + ', '+ X3CboxDesc( "N84_REFCTR", "7")) //##"Opção inválida para contrato de compra."##"Informe uma das opção entre: "
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} AGRXCADGRV
    Função chamada na gravação do contrato para salvar dados da entrega que são necessarios na tabela e são padrão
    @type  Function
    @author claudineia.reinert	
    @since 04/03/2021
    @version P12    
    /*/
Function AGRXCADGRV(oModel)
	Local oModelNJR			:= Nil
	Local oModelNNY			:= Nil
	Local oModelN9A			:= Nil
	Local nX				:= 0
	Local nY 				:= 0

	oModelNJR	:= oModel:GetModel("NJRUNICO")
	oModelNNY	:= oModel:GetModel("NNYUNICO")
	oModelN9A	:= oModel:GetModel("N9AUNICO")

	For nX := 1 To oModelNNY:Length()
		oModelNNY:GoLine(nX)
		For nY := 1 To oModelN9A:Length()
			oModelN9A:GoLine(nY)
			//Estes campos foram criados como tipo "Real", pois são mostrados no Painel de Cadências (OGA530)
			oModelN9A:SetValue("N9A_CODPRO", oModelNJR:GetValue("NJR_CODPRO"))
			oModelN9A:SetValue("N9A_TIPCTR", oModelNJR:GetValue("NJR_TIPO"))
			oModelN9A:SetValue("N9A_TIPMER", oModelNJR:GetValue("NJR_TIPMER"))
			oModelN9A:SetValue("N9A_INCOTE", oModelNJR:GetValue("NJR_INCOTE"))
			oModelN9A:SetValue("N9A_CONDPA", oModelNJR:GetValue("NJR_CONDPA"))
			oModelN9A:SetValue("N9A_CONDPG", oModelNJR:GetValue("NJR_CONDPG"))
			oModelN9A:SetValue("N9A_CTREXT", oModelNJR:GetValue("NJR_CTREXT"))
			
			If Empty(oModelN9A:GetValue("N9A_FILORG"))
				oModelN9A:SetValue("N9A_FILORG", oModelNNY:GetValue("NNY_FILORG"))
			EndIf
		Next nY
	Next nX

Return .t.

/*/{Protheus.doc} AGRXCVNNGC
Valida se o contrato foi gerado usando a nova comercialização.
Contrato com registro de negocio opcional incluidos não possuem o codigo do negocio, somente quando realiza a fixação.
@type function
@version  P12
@author claudineia.reinert
@since 21/10/2021
@param cFilCtr, character, Código da filial do contrato
@param cCodCtr, character, Código do contrato
@return variant, Verdadeiro ou Falso
/*/
Function AGRXCVNNGC(cFilCtr, cCodCtr)
	Local lRet := .F.
	Local cQuery := ""
	Local cAliasQry := GetNextAlias()
	

	cQuery := " SELECT NJR.NJR_CODCTR "
	cQuery += " FROM " + RetSqlName("NJR") + " NJR "
	cQuery += " INNER JOIN " + RetSqlName("NNY") + " NNY ON NNY.D_E_L_E_T_ = ' ' AND NNY.NNY_FILIAL = NJR.NJR_FILIAL AND NNY.NNY_CODCTR = NJR.NJR_CODCTR AND NNY.NNY_FILORG <> ' ' "
	cQuery += " INNER JOIN " + RetSqlName("N9A") + " N9A ON N9A.D_E_L_E_T_ = ' ' AND N9A.N9A_FILIAL = NNY.NNY_FILIAL AND N9A.N9A_CODCTR = NNY.NNY_CODCTR AND N9A.N9A_FILORG = NNY.NNY_FILORG "
	cQuery += " WHERE NJR.D_E_L_E_T_ = ' ' "
	cQuery += " AND NJR.NJR_FILIAL = '"+cFilCtr+"' "
	cQuery += " AND NJR.NJR_CODCTR = '"+cCodCtr+"' "
	cQuery += " GROUP BY NJR.NJR_CODCTR "

	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof()) //consulta encontrou contrato
		lRet := .T.
	EndIf
	(cAliasQry)->(dbCloseArea())

Return lRet
