#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"
#DEFINE _CRLF CHR(13)+CHR(10)

Static Function BuscaParametro(cParametro, dData, cTipo, uValor )
	Local aArea := GetArea()
	local uRet := nil
	Local cQry := ""
	Local cAliasTmp := GetNextAlias()
	Local cChave := PadR(cParametro, TamSX3("NJ4_CHAVE")[1] ) 

	Default cTipo := "N"
	Default dData := dDataBase

	lTeste := .T.
	cQry := "SELECT (CASE "+;
	"WHEN (NJ4_DTINI = '' OR NJ4_DTINI IS NULL) AND "+;
	"(NJ4_DTFIM = '' OR NJ4_DTFIM IS NULL) THEN "+;
	"1 "+;
	"WHEN (NJ4_DTINI <> '' OR NJ4_DTINI IS NOT NULL) AND "+;
	"     (NJ4_DTFIM = '' OR NJ4_DTFIM IS NULL) THEN "+;
	"2 "+;
	"WHEN (NJ4_DTINI = '' OR NJ4_DTINI IS NULL) AND "+;
	"(NJ4_DTFIM <> '' OR NJ4_DTFIM IS NOT NULL) THEN "+;
	"3 "+;
	"WHEN (NJ4_DTINI <> '' OR NJ4_DTINI IS NOT NULL) AND "+;
	"(NJ4_DTFIM <> '' OR NJ4_DTFIM IS NOT NULL) THEN "+;
	" 4 "+;
	"ELSE "+;
	" 5 "+;
	"END) ORDEM "

	cQry += ", NJ4_VALOR "+;
	"FROM " + RetSqlName("NJ4") +" NJ4 "+;
	"WHERE NJ4_CHAVE = '" + cChave + "' "+;
	"AND NJ4_SIT in ('S', '1') "+;
	"AND (   ('" + dData + "' BETWEEN NJ4_DTINI AND NJ4_DTFIM) "+;
	"OR "+; 
	"(NJ4_DTINI = '' OR NJ4_DTINI IS NULL ) "+;
	"OR  "+;
	"(NJ4_DTFIM = '' OR NJ4_DTFIM IS NULL ) "+;
	") "

	cQry += "ORDER BY ORDEM DESC"

	cQry := ChangeQuery(cQry)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAliasTmp, .F., .T.) 

	If !(Empty((cAliasTmp)->NJ4_VALOR))
		If cTipo = "N"
			uRet := VAL((cAliasTmp)->NJ4_VALOR)
		ElseIf cTipo = "D"
			uRet := CTOD((cAliasTmp)->NJ4_VALOR)
		Else
			uRet := (cAliasTmp)->NJ4_VALOR
		EndIf
	EndIf

	RestArea(aArea)

	If !(Empty(uValor))
		uValor := uRet
	EndIf 

Return uRet


User Function VALCARGA(pPar1, pPar2, pPar3, pPar4, pPar5)
	Local cQry := GetNextAlias()
	Local cSql := ""
	Local lRet := .T.

	Local nTotalCarg := 0
	//Local nQtdCargaP := BuscaParametro('QUANTIDADE_CARGA_PERIODO', 'N', @nQtdCargaP
	Local nQtdCargaP := 0
	Local nPctCarCIF := 0
	Local nPctCarFOB := 0                            

	Default pPar5 = 'C' //C=CIF, F=FOB, T=CIF/FOB

	If pPar5 = 'C'
		cTipo := "'C'"
	ElseIf pPar5 = 'F'
		cTipo := "'F'"
	Else
		cTipo := "'C', 'F'"
	EndIF

	cSql := "select NJ5_DTPREV "
	cSql += "from " +RetSqlName("NJ5") +" NJ5 "
	cSql += "where NJ5.NJ5_FILIAL = '" + fwXFilial("NJ5")+ "' "
	cSql += "and   NJ5.NJ5_NUMPV  = '" + pPar1 + "' "
	cSql += "and   NJ5.NJ5_ITEM   = '" + pPar2 + "' "
	cSql += "and   NJ5.NJ5_SEQUEN = '" + pPar3 + "' "
	cSql += "and   NJ5.NJ5_PRODUT = '" + pPar4 + "' "
	cSql += "and   NJ5.D_E_L_E_T_ <> '*' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cQry, .F., .T.) 

	nQtdCargaP := BuscaParametro('QUANTIDADE_CARGA_PERIODO', (cQry)->NJ5_DTPREV)
	nPctCarCIF := BuscaParametro('PERCENTUAL_CARGA_CIF', (cQry)->NJ5_DTPREV)
	nPctCarFOB := BuscaParametro('PERCENTUAL_CARGA_FOB', (cQry)->NJ5_DTPREV)                            

	cSql := "SELECT (SUM(NJ5_QTDE) ) TOTAL_CARGA "+;
	"FROM  " +RetSqlName("NJ5") +" NJ5 "+;
	"WHERE NJ5_STATUS NOT IN ('1', '3') "+;
	"AND NJ5_DTPREV = '" + (cQry)->NJ5_DTPREV + "' "+;
	"AND NJ5_TPFRET in (" + cTipo + ") "

	If Select(cQry) > 0
		(cQry)->(DbCloseArea())
	EndIF

	cSql := ChangeQuery(cSql)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), cQry, .F., .T.)

	If !(Empty((cQry)->TOTAL_CARGA))
		nTotalCarg := (cQry)->TOTAL_CARGA
	EndIF

	If pPar5 = "T"
		lRet := nTotalCarg <= nQtdCargaP
	ElseIf pPar5 = "C"
		lRet := (nTotalCarg * 100 / nQtdCargaP) <= nPctCarCIF
	ElseIf pPar5 = "F" 
		lRet := (nTotalCarg * 100 / nQtdCargaP) <= nPctCarFOB 
	EndIf

Return lRet

User Function TESTEVALB()
	Local lRet := .T.
	Alert('Validacao TESTEVALB')
Return lRet



User Function ValLibLT(pChave)
	Local aArea := GetArea()
	Local lRet := .T.
	Local lErro := .F.
	Local lExiste := .F.
	Local cAliasTmp := ""
	Local cMsg  := ""
	Local cMsg2 := ""
	Local aRet  := ""
	Local cValChave1 := pChave[1]+pChave[2]+pChave[3]+pChave[4]+pChave[5]
	Local cValChave2 := ""
	Local nSeq := 0
	Local lExecuta := .F.
	Local nCpo := 0
	Local lConfLote := nil
	Local cChaveNJS := ""

	//pChave=> aParam := {oModelGX5:GetValue("GX5_FILIAL"),oModelGX5:GetValue("GX5_NRMOV"),cPtoCtl,oModelGX5:GetValue("GX5_SEQ"),cPerg,M->GX5_RESPOS}

	//Se estiver tentando alterar o valor de 1 para 2 
	//verificar se existe liberação já realizada na NJ6.
	//Caso afirmativo, não permitir
	If pChave[6] = '2'  
		lRet := .T.
		DbSelectArea("NJS")
		DbGoTop()
		If DbSeek(cValChave1)
			IIf (ExistSX3("NJ6_SEQCAR"), nCpo := 1, nCpo := 0)
			cChaveNJS  := NJS->NJS_CHAVE //guarda a chave para deleção posterior
			aChave2NJS := (StrTokArr(NJS->NJS_CHAVE, ";"))
			lExiste := ( 'S' == GetDataSql("SELECT DISTINCT 'S' RES FROM " +RetSqlName("NJ6") +" NJ6 "+;
			" WHERE NJ6_FILIAL = '" + aChave2NJS[1] + "' "+;
			" AND NJ6_CODCAR = '" + aChave2NJS[2] + "' "+;
			IIF(ExistSX3("NJ6_SEQCAR"), "AND NJ6_SEQCAR = '" + aChave2NJS[3] + "' ", "") +;
			" AND NJ6_NUMPV = '" + aChave2NJS[3 + nCpo] + "' "+;
			" AND NJ6_ITEM = '" + aChave2NJS[4 + nCpo] + "' "+;
			" AND NJ6_SEQUEN = '" + aChave2NJS[5 + nCpo] + "' "+;
			" AND NJ6_PRODUT = '" + aChave2NJS[6 + nCpo] + "' "+;
			" AND NJ6_SEQLT = '" + aChave2NJS[7 + nCpo] + "' " +;
			" AND NJ6.D_E_L_E_T_ <> '*' " )  )

			If lExiste
				//Caso já exista lotes separados 

				//Verifica se a confirmação do lote já foi efetuada.
				//Procura na NJS pela pergunta de confirmação de lote.
				cPergunta := SuperGetMV('MV_AGRPERG')
				lConfLote := 'S' == GetDataSql("select 'S' EXISTE from " + RetSqlName("NJS") + " NJS " +;
				" where NJS_FILIAL = '" + pChave[1] + "' "              +;
				" and NJS_NRMOV    = '" + pChave[2] + "' "              +; 
				" and NJS_CDPERG   = '" + cPergunta + "' "              +; 
				" and NJS_NMTAB    = '" + "NJ6" + "' "                  +; 
				" and NJS_CHAVE    like '" + aChave2NJS[1] + ';' + aChave2NJS[2] + ';' + aChave2NJS[3] + "%"  + ';' + aChave2NJS[4] + "%'"  +;
				" AND NJS.D_E_L_E_T_ <> '*' " )

				If lConfLote 
					cMsg := "O processo de separação de Lotes já foi Confirmado."+_CRLF+;
					"Não é permitido alterar esta etapa."
					MsgAlert(cMsg)
					Return .F.
				EndIf

				//e o saldo da SC9 for igual a ZERO então impede //de altarar a separação de lotes
				cQuery := AGR870ASLD(aChave2NJS[2], IIF(ExistSX3("NJ6_SEQCAR"),aChave2NJS[2] , "  "), .T. )

				nSaldo := GetDataSql(cQuery, .F.)
				If nSaldo = 0
					cMsg := "O processo de separação de Lotes já foi executado e o saldo dos item já foi totalmente separado."+_CRLF+;
					"Clique em Sim para excluir o movimento ou em Não para cancelar esta ação."
					If !(MsgYesNo(cMsg))
						Return .F.
					else

						Return AGRVNJ6DEL(cChaveNJS,  pChave[1], pChave[2]) //deleta os dados da NJ6 e da reserva SC0  

					EndIf
				EndIf
			EndIF
		EndIF

		//Executar a função para excluir os dados da NJ6
		//Busca o registro da NJS com a chave
		lExclui := .T.
		If lExiste
			BEGIN TRANSACTION
				DbSelectArea("NJS")
				DbSetOrder(1)
				NJS->(DbGoTop()) 
				If NJS->(DbSeek(pChave[1]+pChave[2]+pChave[3]+pChave[4]+pChave[5] ))
					While lExclui .AND. ;
					!NJS->(EOF()) .AND. ;
					(NJS->(NJS_FILIAL+NJS_NRMOV+NJS_CDPTCT+NJS_SEQ+NJS_CDPERG) =   ;
					(pChave[1]+pChave[2]+pChave[3]+pChave[4]+pChave[5]) )

						aChave2NJS := StrToKArr(NJS->NJS_CHAVE, ';')

						If !(Agr870ADE2(aChave2NJS, .F.))
							lExclui := .F.
							Exit
						EndIF
						NJS->(dbSkip())
					EndDo
					If lExclui
						If Select('NJS') > 0
							NJS->(dbCloseArea())
						EndIF
						//Exclui o registro na NJS
						If !(ExcluiNJS( pChave))
							lExclui := .F.
							DisarmTransaction()
						EndIf
					Else
						DisarmTransaction()
					EndIf
				EndIF
			END TRANSACTION
		EndIF
		RestArea(aArea)
		Return lExclui   //se excluiu tudo  retorna .T. senão retorna .F.      
	EndIf

	If pChave[6] = "1"
		lExecuta := .T.
	EndIf


	If lExecuta 
		aRet := Agra870B(pChave)

		If .NOT.(aRet[1])
			Return aRet[1]
		EndIf
	EndIf

	If pChave[6] = "1"
		cQuery := AGR870ASLD(aRet[2], aRet[3], .F., .T. )

		cAliasTmp := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .T.)	

		dbSelectArea(cAliasTmp)
		dbGoTOp()

		//Testar os campos obrigatórios da regra
		cMsg := "Validação Pergunta do Ponto de Controle"+_CRLF
		//GX5_FILIAL+GX5_NRMOV+Pto Ctle+GX5_SEQ+Pergunta
		cMsg := "Programa....:"+"AGRA870A"
		cMsg += "Chave[GX5]..:"+pChave[1]+pChave[2]+pChave[3]+pChave[4]+pChave[5]+_CRLF
		cMsg += "Situacao....:"+"ERRO"+_CRLF


		While !(cAliasTmp)->(Eof())    
			lErro  := .F.
			cMsg2 := ""
			cMsg2 := "Chave[NJ6]..."+(cAliasTmp)->(NJ6_FILIAL+NJ6_CODCAR+NJ6_NUMPV+NJ6_ITEM+NJ6_SEQUEN+NJ6_PRODUT)+_CRLF

			//O SALDO SERÁ VALIDADO NUMA PERGUNTA FINAL, EM SEPARADO
			//If (cAliasTmp)->SALDO > 0
			//   lErro  := .T.
			//   cMsg2 += _CRLF+"-> Saldo da Liberação maior que 0 (Zero)" 
			//EndIf

			If (Rastro((cAliasTmp)->NJ6_PRODUT ,"S"))
				If Empty((cAliasTmp)->LOCAL)
					lErro  := .T.
					cMsg2 += _CRLF+"-> Local não informado"
				EndIf

				If (cAliasTmp)->LOCAL == '99'
					lErro  := .T.
					cMsg2 += _CRLF+"-> Local de processos não aceito para faturamento"
				EndIf
			EndIf

			If Empty((cAliasTmp)->CULTVAR)
				lErro  := .T.
				cMsg2 += _CRLF+"-> Cultura não informado"
			EndIf

			If Empty((cAliasTmp)->CATEG)
				lErro  := .T.
				cMsg2 += _CRLF+"-> Categoria não informado"
			EndIf

			If Empty((cAliasTmp)->PENE)
				lRet := .F.
				cMsg2 += _CRLF+"-> Peneira não informado"
			EndIf

			cValChave2 := (cAliasTmp)->(NJ6_FILIAL+NJ6_CODCAR+NJ6_NUMPV+NJ6_ITEM+NJ6_SEQUEN+NJ6_PRODUT+NJ6_SEQLT)
			If lErro
				lRet := .F.
				cTipo := "4"
				aValores := {}
				aAdd(aValores, "GX5" )
				aAdd(aValores, (cValChave1 + "/" + cValChave2) )
				aAdd(aValores, cTipo  )  //Tipo = Alteracao
				aAdd(aValores, cMsg + "Mensagem....:"+cMsg2 )
				aArea := GetArea()
				DbSelectArea("NK9")
				If NK9->(DbSeek( fwxFilial('NK9')+"GX5"+aValores[2]))
					RecLock('NK9', .F.)
					DbDelete()
					MsUnlock()
				EndIf
				RestArea(aArea) 
				AGRGRAVAHIS('Log Erro na consistência Ponto de Controle - AGRA870A',"GX5",aValores[2], cTipo, aValores) //Histórico da Política de Programação de Entrega
			Else
				aArea := GetArea()
				DbSelectArea("NK9")
				If NK9->(DbSeek( fwxFilial('NK9')+"GX5"+(cValChave1 + "/" + cValChave2)))
					RecLock('NK9', .F.)
					DbDelete()
					MsUnlock()
				EndIf
				RestArea(aArea) 
			EndIF

			(cAliasTmp)->(DbSkip())
		End
	EndIf

	If lRet
		cValChave2 := ""
		nSeq := 0
		dbGoTOp()
		lExclui := .T.
		While !(cAliasTmp)->(Eof())    
			If ( cValChave2 != (cAliasTmp)->(NJ6_FILIAL+NJ6_CODCAR+NJ6_NUMPV+NJ6_ITEM+NJ6_SEQUEN+NJ6_PRODUT+NJ6_SEQLT))
				nSeq := nSeq + 1
				cValChave2 := (cAliasTmp)->(NJ6_FILIAL+NJ6_CODCAR+NJ6_NUMPV+NJ6_ITEM+NJ6_SEQUEN+NJ6_PRODUT+NJ6_SEQLT)
				GravaNJS(pChave, 'NJ6', ;
				(cAliasTmp)->NJ6_FILIAL+';'+;
				(cAliasTmp)->NJ6_CODCAR+';'+;
				IIF(ExistSX3("NJ6_SEQCAR"), (cAliasTmp)->NJ6_SEQCAR+';', "") +;
				(cAliasTmp)->NJ6_NUMPV+';'+;
				(cAliasTmp)->NJ6_ITEM+';'+;
				(cAliasTmp)->NJ6_SEQUEN+';'+;
				(cAliasTmp)->NJ6_PRODUT+';'+;
				(cAliasTmp)->NJ6_SEQLT, nSeq, lExclui)
				lExclui := .F.
			EndIF
			(cAliasTmp)->(DbSkip())
		End
	EndIf

Return lRet


/** {Protheus.doc} AGRA950GRV
Funcao para gravar dados na tabela NJS que é complemento
da tabela de pontos de controle do GFE - GX5)
@param:     aChaveGX5 : Array contendo os valores da chave da tabela GX5
cTabela   : Nome da tabela que está sendo relacionada
cChave    : Valores separados por ";" que compreendem a chave da tabela relacionada
lDel      : Indica se o registro existente deve ser deletado ou atualizado
@return:    .t.
@author:    Equipe AgroIndustria
@since:     23/12/2016
@Uso:       AGRA950
@Ponto de Entrada:
@Data:
*/
Static Function GravaNJS(aChaveGX5, cTabela, cChave, Sequencia, lExclui)
	Local aArea 	:= GetArea() 
	Local aCChave	:= StrTokArr(cChave, ';')
	Local cCodPro 	:= iif(Len(aCChave) > 6 , aCChave[7] , "" )
	
	Default Sequencia = 0
	Default lExclui := .T.
	If lExclui
		ExcluiNJS(aChaveGX5)
	EndIf

	DbSelectArea('NJS')
	If AGRIFDBSEEK("NJS",aChaveGX5[2] + aChaveGX5[4] + aChaveGX5[3] + aChaveGX5[5] + ALLTRIM(STR(Sequencia)) ,1,.F.)
		RecLock('NJS', .F.)
	Else
		RecLock('NJS', .T.)
	Endif
	
	NJS_FILIAL := aChaveGX5[1]
	NJS_NRMOV  := aChaveGX5[2]
	NJS_CDPTCT := aChaveGX5[3]
	NJS_SEQ    := aChaveGX5[4]
	NJS_CDPERG := aChaveGX5[5]
	NJS_SEQDES := Sequencia
	NJS_NMTAB  := cTabela
	NJS_CODPRO := cCodPro
	NJS_CHAVE  := cChave
	MSUNLOCK()
	NJS->(DbCloseArea())
	RestArea(aArea)
Return .T.



/** {Protheus.doc} AGRA950GRV
Funcao para REMOVER dados na tabela NJS que é complemento
da tabela de pontos de controle do GFE - GX5)
@param:     aChaveGX5 : Array contendo os valores da chave da tabela GX5
cTabela   : Nome da tabela que está sendo relacionada
cChave    : Valores separados por ";" que compreendem a chave da tabela relacionada
lDel      : Indica se o registro existente deve ser deletado ou atualizado
@return:    .t.
@author:    Equipe AgroIndustria
@since:     23/12/2016
@Uso:       AGRA950
@Ponto de Entrada:
@Data:
*/
Static Function ExcluiNJS(aChaveGX5)

	Local aArea := GetArea()
	Local lRet := .F.

	DbSelectArea('NJS')
	DbGoTop()
	DbSetOrder(1)

	While MsSeek(aChaveGX5[1]+aChaveGX5[2]+aChaveGX5[3]+aChaveGX5[4]+aChaveGX5[5]+aChaveGX5[6])
		RecLock('NJS', .F.)
		DbDelete()
		MSUNLOCK()
		lRet := .T.
		DbSkip()
	End

	NJS->(DbCloseArea())
	RestArea(aArea)

Return lRet


/** {Protheus.doc} AGRA950VLG
Descrição: Mostra em tela de Historico da GX5 quando agra870A retornar .F.
@param: 	Nil
@author: 	Marcelo R. Ferrari
@since: 	23/12/2016
@Uso: 		AGRA970 
*/
Function AGRA870aVL(oView)
	Local lRet := .T.
	Local oModel    := oView:GetModel()
	Local oModelGX5	:= oModel:GetModel("GFE519BGX5")
	Local cChaveA   := ""
	Local nChaveA   := Nil

	cChaveA := oModelGX5:GetValue("GX5_FILIAL") 
	cChaveA += oModelGX5:GetValue("GX5_NRMOV")
	cChaveA += oModelGX5:GetValue("GX5_SEQ")
	cChaveA += oModelGX5:GetValue("GX5_CDPTCT")
	cChaveA += oModelGX5:GetValue("GX5_CDPERG")
	nChaveA := Len(cChaveA)

	cChaveA := cChaveA +Space(Len(NK9->NK9_CHAVE)-Len(cChaveA) )
	AGRHISTTABE("GX5",cChaveA, nChaveA )
Return lRet


//Emitir o roamenio ou alterar o romaneio em caso de ter vindo de outra operacao
//classificar
//cria relacionamento com gx5 - NJS
Function CallOGA250(pParMov)
	Local xRet
	Local cChave1
	Local lRet := .F.
	Local lChk1
	Local cChave2
	Local aKey := {}

	Local oDlg
	Local cRomaneio := Space(10)
	private cPlacaGFE := ''


	cChave2 := Posicione("NJS",1, pParMov[1]+pParMov[2]+pParMov[3]+pParMov[4]+pParMov[5], "NJS_CHAVE")
	if !empty(cChave2)
		aKey := StrTokArr( cChave2, ";" )
		cChave1 := aKey[2]
		OGA250("NJJ",0,4,cChave1)
	else
		If MsgYesNo( "Deseja emitir o romaneio?" )						
			xRet :=	FWExecView( "Romaneio", "OGA250", MODEL_OPERATION_INSERT )

			if xRet == 0 //incluiu registro			
				dbSelectArea("NJJ")
				cChave1 := NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM			
				OGA250("NJJ",0,3,NJJ->NJJ_CODROM)				
			EndIF
		Else
			DEFINE MSDIALOG oDlg TITLE "Informe o Romaneio:" From 4,0 To 14,40 OF oMainWnd

			@ 10, 006 SAY "Cod.Romaneio: " SIZE 70,7 PIXEL OF oDlg
			@ 8, 060 MSGET cRomaneio Picture "@!" SIZE 70,10 Of oDlg When .T.  Pixel

			oButtonCanc :=tButton():New(55,36,"Confirmar",oDlg,{||(oDlg:End())},50,12,,,,.T.)

			ACTIVATE MSDIALOG oDlg

			cChave1 := xFilial("NJJ")+cRomaneio
			dbSelectArea("NJJ")
			dbSeek(cChave1)
			If NJJ->(!Eof())
				OGA250("NJJ",0,4,cRomaneio)
			Else
				msgalert("Romaneio não encontrado")
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If !Empty(cChave1)
		dbSelectArea("NJJ")
		dbSeek(cChave1)
		If NJJ->(!Eof())
			If NJJ->NJJ_STSCLA == '1' 
				lRet := .T.
				GravaNJS(pParMov, ;
				'NJJ',;
				xFilial("NJJ")+';'+NJJ->NJJ_CODROM )
			EndIf
		EndIf
	EndIf

	If (lRet .And. pParMov[6] == '1') .Or.  (!lRet .And. pParMov[6] == '2')
		lChk1 := .T.
	Else
		lChk1 := .F.
		Help( ,, 'HELP',, 'Não foi possível alterar', 1, 0)
	EndIf

Return lChk1


//posicina romaneio e faz primeira pesagem
//cria njs - relacionamento  gxs e njj
Function Call2OGA250(pParMov)
	Local xRet
	Local cChave1
	Local lRet := .F.
	Local lChk1
	Local cChave2
	Local aKey := {}

	Local oDlg
	Local cRomaneio := Space(10)
	private cPlacaGFE := ''

	cChave2 := Posicione("NJS",1, pParMov[1]+pParMov[2]+pParMov[3]+pParMov[4]+pParMov[5], "NJS_CHAVE")
	if !empty(cChave2)
		aKey := StrTokArr( cChave2, ";" )
		cChave1 := aKey[2]
		OGA250("NJJ",0,4,cChave1)
	else
		If MsgYesNo( "Deseja emitir o romaneio?" )						
			xRet :=	FWExecView( "Romaneio", "OGA250", MODEL_OPERATION_INSERT )

			if xRet == 0 //incluiu registro			
				dbSelectArea("NJJ")
				cChave1 := NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM			
				OGA250("NJJ",0,3,NJJ->NJJ_CODROM)				
			EndIF
		Else
			DEFINE MSDIALOG oDlg TITLE "Informe o Romaneio:" From 4,0 To 14,40 OF oMainWnd

			@ 10, 006 SAY "Cod.Romaneio: " SIZE 70,7 PIXEL OF oDlg
			@ 8, 060 MSGET cRomaneio Picture "@!" SIZE 70,10 Of oDlg When .T.  Pixel

			oButtonCanc :=tButton():New(55,36,"Confirmar",oDlg,{||(oDlg:End())},50,12,,,,.T.)

			ACTIVATE MSDIALOG oDlg

			cChave1 := xFilial("NJJ")+cRomaneio
			dbSelectArea("NJJ")
			dbSeek(cChave1)
			If NJJ->(!Eof())
				OGA250("NJJ",0,4,cRomaneio)
			Else
				msgalert("Romaneio não encontrado")
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If !Empty(cChave1)
		dbSelectArea("NJJ")
		dbSeek(cChave1)
		If NJJ->(!Eof())
			If  NJJ->NJJ_PESO1 <> 0
				lRet := .T.
				GravaNJS(pParMov, ;
				'NJJ',;
				xFilial("NJJ")+';'+NJJ->NJJ_CODROM )
			EndIf
		EndIf
	EndIf

	If (lRet .And. pParMov[6] == '1') .Or.  (!lRet .And. pParMov[6] == '2')
		lChk1 := .T.
	Else
		lChk1 := .F.
		Help( ,, 'HELP',, 'Não foi possível alterar', 1, 0)
	EndIf

Return lChk1


//posicina romaneio e faz primeira pesagem
//cria njs - relacionamento  gxs e njj
Function Call3OGA250(pParMov)
	Local cChave1
	Local lRet := .F.
	Local lChk1
	Local cChave2
	Local aKey := {}

	private cPlacaGFE := ''
	//Alltrim(Posicione("GX6", 1, FWxFilial("GX6")+pParMov[2], "GX6_CDVEIC"))
	cChave2 := Posicione("NJS",1, pParMov[1]+pParMov[2]+pParMov[3]+pParMov[4]+pParMov[5], "NJS_CHAVE")
	if !empty(cChave2)
		aKey := StrTokArr( cChave2, ";" )
		cChave1 := aKey[2]
		OGA250("NJJ",0,4,cChave1)
	else
		msgalert("Romaneio não encontrado")
		lRet := .F.
	EndIf

	If !Empty(cChave1)
		dbSelectArea("NJJ")
		dbSeek(cChave1)
		If NJJ->(!Eof())
			If  NJJ->NJJ_PESO2 <> 0
				lRet := .T.
				GravaNJS(pParMov, ;
				'NJJ',;
				xFilial("NJJ")+';'+NJJ->NJJ_CODROM )
			EndIf
		EndIf
	EndIf

	If (lRet .And. pParMov[6] == '1') .Or.  (!lRet .And. pParMov[6] == '2')
		lChk1 := .T.
	Else
		lChk1 := .F.
		Help( ,, 'HELP',, 'Não foi possível alterar', 1, 0)
	EndIf

Return lChk1

Function ConfOGA250(pParMov)
	Local cChave1
	Local lRet := .F.
	Local lChk1

	cAliasNJJ := GetNextAlias()

	cQuery := " SELECT NJJ_FILIAL, NJJ_CODROM "
	cQuery += " FROM " + RetSqlName("NJJ")+" NJJ "
	cQuery += " WHERE NJJ.NJJ_FILIAL = '"+ xFilial("NJJ")+"'"
	cQuery += "   AND NJJ.NJJ_CODROM= '"+pParMov[2]+"' "
	cQuery += "   AND NJJ.D_E_L_E_T_ <> '*' "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasNJJ, .F., .T.)
	If !(cAliasNJJ)->(Eof())
		cChave1 := (cAliasNJJ)->NJJ_FILIAL+(cAliasNJJ)->NJJ_CODROM
		OGA250("NJJ",0,4,(cAliasNJJ)->NJJ_CODROM)
	EndIf
	(cAliasNJJ)->(dbCloseArea())

	If !Empty(cChave1)
		dbSelectArea("NJJ")
		dbSeek(cChave1)
		If NJJ->(!Eof())
			If NJJ->NJJ_STATUS == '3' .and. NJJ->NJR_STSASS=='F'
				lRet := .T.
				GravaNJS(pParMov[1]+pParMov[2]+pParMov[3]+pParMov[4]+pParMov[5], ;
				'NJJ',;
				xFilial("NJJ")+';'+NJJ->NJJ_CDROM )
			EndIf
		EndIf
	EndIf

	If (lRet .And. pParMov[6] == '1') .Or.  (!lRet .And. pParMov[6] == '2')
		lChk1 := .T.
	Else
		lChk1 := .F.
		Help( ,, 'HELP',, 'Não foi possível alterar', 1, 0)
	EndIf

Return lChk1

User Function LibSepLt(pParam)

	Local aArea := GetArea()
	Local lRet := .T.
	Local nSeqSC9 := 0
	Local nCtSC9 := 0
	Local nCtNJ5 := 0
	Local nCtNJ6 := 0
	Local i := 0
	Local i2 := 0
	Local j2 := 0
	Local nSaldo := 0
	Local lQtd :=.T.	

	Local aCpoSC9 := {}
	Local aCpoNJ5 := {}
	Local aCpoNJ6 := {}

	Local aValSC9 := {}
	Local aValNJ5 := {}
	Local aValNJ6 := {}

	Local aValClone := {}
	Local uVl       := NIL

	Local cProduto := ""
	Local cQtdUm2  := ""
	Local cLocal   := "" 
	Local cDtValid := ""
	Local aStructSC9 := {}
	Local aStructNJ5 := {}
	Local aStructNJ6 := {}

	Private _cAliMKB2 := GetNextAlias()

	//pChave=> aParam := {oModelGX5:GetValue("GX5_FILIAL"),oModelGX5:GetValue("GX5_NRMOV"),cPtoCtl,oModelGX5:GetValue("GX5_SEQ"),cPerg,M->GX5_RESPOS}

	If pParam[6] = "2" 
		//Exclui o registro na NJS, se houver
		ExcluiNJS( pParam)
		Return .T.
	EndIf

	//Buscar a carga
	aCarga := Agra870aCG(pParam, .F.)

	If !(aCarga[1])
		Return .F.
	EndIf

	cOrdCar := aCarga[2]
	cSeqCar := aCarga[3]

	//Buscar os Registro na NJ6 relacionados a Carga
	cQuery := "SELECT NJ6_SEQLT SEQLT, NJ6_FILIAL FILPE, NJ6_CODCAR CODCAR, "
	If ExistSX3("NJ6_SEQCAR")
		cQuery += "NJ6_SEQCAR, "
	Else
		cQuery += "'  ' NJ6_SEQCAR, "
	EndIf
	cQuery += "NJ6_NUMPV PEDIDO, NJ6_ITEM ITEM , NJ6_SEQUEN SEQUENCIA,  "
	cQuery += " NJ6_PRODUT PRODUTO, NJ6_UM UM, NJ6_QTDE QTDE, NJ6_LOCAL LOCAL, NJ6_END ENDERECO, "
	cQuery += " NJ6_LOTECT LOTECT, NJ6_NMLOTE NMLOTE, NJ6_CULTRA CULTRA, NJ6_CTVAR CULTVAR, "
	cQuery += " NJ6_CATEG CATEG, NJ6_PENE PENE, NJ6_RESERV RESERVA "
	cQuery += "FROM " +RetSqlName("NJ6") +" NJ6 "
	cQuery += "WHERE 1 = 1"
	cQuery += " AND NJ6.NJ6_FILIAL = '" + fwxFilial("NJ6") + "' " 
	//Adicionar condições de relacionamento para liberações que já foram
	//Agendados e/ou realizado montagem da carga
	cQuery += " AND NJ6.NJ6_CODCAR = '" + cOrdCar + "' "
	If ExistSX3("NJ6_SEQCAR")
		cQuery += "AND NJ6_SEQCAR = '" + cSeqCar + "' "
	EndIf
	cQuery += " AND NJ6.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), _cAliMKB2, .F., .T.)

	//carrega os campos da SC9 no array
	aStructSC9 := SC9->(DbStruct())
	For i := 1 To Len(aStructSC9)
		Aadd(aCpoSC9,{ aStructSC9[i,1] })
	Next i

	aStructNJ5 := NJ5->(DbStruct())
	For i := 1 To Len(aStructNJ5)
		Aadd(aCpoNJ5,{ aStructNJ5[i,1] })
	Next i

	aStructNJ6 := NJ6->(DbStruct())
	For i := 1 To Len(aStructNJ6)
		Aadd(aCpoNJ6,{ aStructNJ6[i,1] })
	Next i

	//Posicionar o registro na NJS

	nSaldo := GetDataSql( AGR870ASLD( cOrdCar, cSeqCar, .T.), .F. )

	If nSaldo > 0
		//Como existe item com saldo MAIOR QUE ZERO então não faz o desmembramento.
		lRet := .F.
		Return lRet
	EndIF

	BEGIN TRANSACTION
		(_cAliMKB2)->(DbGoTop())   

		cChave    := ""
		cChaveNJ6 := ""
		nCtSC9 := 0	
		While !( (_cAliMKB2)->(Eof()) ) 
			If cChave != FWxFILIAL("NJ6")+(_cAliMKB2)->(PEDIDO+ITEM+SEQUENCIA+PRODUTO)

				cChave    := FWxFILIAL("NJ6")+(_cAliMKB2)->(PEDIDO+ITEM+SEQUENCIA+PRODUTO) //SC9-NJ5
				cChaveNJ6 := FWxFILIAL("NJ6")+cOrdCar+;
				IIF(ExistSX3("NJ6_SEQCAR"), cSeqCar, "")+;
				(_cAliMKB2)->(PEDIDO+ITEM+SEQUENCIA+PRODUTO)

				//Posiciona o registro da SC9 e copia para um array campo/valor
				dbSelectArea("SC9")
				SC9->(dbSetOrder(1))

				If ( SC9->(dbSeek(cChave)) )
					nCtSC9 := nCtSC9 + 1  
					nSeqSC9 := Val(SC9->C9_SEQUEN)
					aAdd(aValSC9, {} )
					RecLock("SC9", .F.)
					//Copia os dados do registro atual para o array aCpoSC9
					For i := 1 to Len(aCpoSC9)
						aAdd(aValSC9[nCtSC9], &("SC9->"+aCpoSC9[i][1]) )
					Next i
					//Apaga o registro Copiado
					SC9->(dbDelete())   
					SC9->(MsUnlock())
				EndIF

				dbSelectArea("NJ5")
				NJ5->(dbSetOrder(1))
				NJ5->(dbGoTop())
				If ( NJ5->(dbSeek(cChave)) )
					nCtNJ5 := nCtNJ5 + 1  
					aAdd(aValNJ5, {} )
					RecLock("NJ5", .F.)
					//Copia os dados do registro atual para o array aCpoNJ5
					For i := 1 to Len(aCpoNJ5)
						aAdd(aValNJ5[nCtNJ5], &("NJ5->"+aCpoNJ5[i][1]) )
					Next i
					//Apaga o registro Copiado
					NJ5->(dbDelete())   
					NJ5->(MsUnlock())
				EndIF
			Else
				//Replica o registro para cada iteração da NJ6 com a mesma chave
				//
				aAdd(aValSC9, {})
				aValSC9[Len(aValSC9)] := aValSC9[nCtSC9]

				aAdd(aValNJ5, {})
				aValNJ5[Len(aValNJ5)] := aValNJ5[nCtNJ5]

				nCtSC9 := nCtSC9 + 1
				nCtNJ5 := nCtNJ5 + 1

			EndIf

			dbSelectArea("NJ6")
			NJ6->(dbSetOrder(1))
			NJ6->(dbGoTop())
			If ( NJ6->(dbSeek(cChaveNJ6)) )
				nCtNJ6 := nCtNJ6 + 1  
				aAdd(aValNJ6, {} )
				RecLock("NJ6", .F.)
				//Copia os dados do registro atual para o array aCpoNJ5
				For i := 1 to Len(aCpoNJ6)
					aAdd(aValNJ6[nCtNJ6], &("NJ6->"+aCpoNJ6[i][1] ) )
				Next i
				//Apaga o registro Copiado
				NJ6->(dbDelete())   
				NJ6->(MsUnlock())
			EndIF

			(_cAliMKB2)->(DbSkip())
		EndDo

		//Repopular os dados nas tabelas com base no array de dados da NJ6
		//atualizando a sequência de 1 para 1 na sc9/nj5
		cChave := ""
		lExclui := .T.
		For i2 := 1 to Len(aValNJ6)

			//O valor de I será a sequência das tabelas 
			If cChave != (aValNJ6[i2][aScan(aCpoNJ6,{|x| x[1] == "NJ6_FILIAL"})]  + ;
							aValNJ6[i2][aScan(aCpoNJ6,{|x| x[1] == "NJ6_NUMPV"})] + ;
							aValNJ6[i2][aScan(aCpoNJ6,{|x| x[1] == "NJ6_ITEM"})]  + ;
							aValNJ6[i2][aScan(aCpoNJ6,{|x| x[1] == "NJ6_PRODUT"})])

				cChave := aValNJ6[i2][aScan(aCpoNJ6,{|x| x[1] == "NJ6_FILIAL"})] + ;
				aValNJ6[i2][aScan(aCpoNJ6,{|x| x[1] == "NJ6_NUMPV"})] + ;
				aValNJ6[i2][aScan(aCpoNJ6,{|x| x[1] == "NJ6_ITEM"})]   + ;
				aValNJ6[i2][aScan(aCpoNJ6,{|x| x[1] == "NJ6_PRODUT"})]

				nSeqSC9 := GetDataSql("SELECT Max(cast(C9_SEQUEN As Integer) ) C9_SEQUEN " + ; 
				"FROM " +RetSqlName("SC9") +" SC9  " + ;
				"WHERE C9_FILIAL = '" 	+ aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_FILIAL"} )] + "' " + ;  
				"AND C9_PEDIDO = '" 	+ aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_NUMPV"})] + "' " + ;
				"AND C9_ITEM   = '" 	+ aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_ITEM"})] + "' " + ;
				"AND C9_PRODUTO= '" 	+ aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_PRODUT"} )]+ "'")
				If Empty(nSeqSC9)
					nSeqSC9 := 0
				EndIF
			EndIf

			nSeqSC9 := nSeqSC9 + 1
			cSequen := PadL(nSeqSC9, 2, '0')

			cQtde    := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_QTDE"})]
			cProduto := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_PRODUT"})]
			cQtdUm2  := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_QTDUM2"})]
			cLocal   := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_LOCAL"})]

			aValClone := {}
			aValClone := aClone(aValSC9)
			RecLock("SC9", .T.)
			For j2 := 1 to Len(aCpoSC9)
				uVl := Nil
				uVl := aValClone[i2][j2]
				&("SC9->"+aCpoSC9[j2][1]) := uVl
			Next j2
			//Altera os valores dos campos específicos da NJ6 para a SC9
			SC9->C9_SEQUEN := cSequen
			SC9->C9_QTDLIB := cQtde
			SC9->C9_QTDLIB2 := ConvUm(cProduto, cQtde, cQtdUm2, 2)
			SC9->C9_QTDRESE := cQtde
			SC9->C9_RESERVA := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_RESERV"} )]
			SC9->C9_BLEST	:= ' '
			SC9->C9_LOCAL     := cLocal
			SC9->C9_LOTECTL   := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_LOTECT"} )]
			SC9->C9_NUMLOTE   := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_NMLOTE"} )]
			SC9->C9_NUMSERI   := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_NMSERI"} )]  
			cDtValid := GetDataSqlAll("select B8_DTVALID FROM " + RetSqlName("SB8") + " SB8 " + ;
			" where B8_FILIAL = '" + fwXFilial("SB8") + "' "        + ;         
			" and B8_PRODUTO  = '" + cProduto + "' " + ;  
			" and B8_LOCAL    = '" + cLocal + "' " + ;               
			" and B8_LOTECTL  = '" + aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_LOTECT"} )] + "' " + ;       
			" and B8_NUMLOTE  = '" + aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_NMLOTE"} )] + "' " + ;
			" and D_E_L_E_T_ <> '*' ")

			SC9->C9_DTVALID   := STOD(cDtValid)
			SC9->(MsUnlock())

			aValClone := {}
			aValClone := aClone(aValNJ5)
			RecLock("NJ5", .T.)
			For j2 := 1 to Len(aCpoNJ5)
				&("NJ5->"+aCpoNJ5[j2][1]) := aValClone[i2][j2]
			Next j2

			//Altera os valores dos campos específicos da NJ6 para a SC9
			NJ5->NJ5_SEQUEN := cSequen
			NJ5->NJ5_QTDE   := cQtde
			NJ5->NJ5_QTDUM2 := ConvUm(cProduto, cQtde, cQtdUm2, 2)

			NJ5_LOCAL     := cLocal
			NJ5_CULTRA    := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_CULTRA"} )]
			NJ5_CTVAR     := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_CTVAR"} )]
			NJ5_CATEG     := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_CATEG"} )]
			NJ5_PENE      := aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_PENE"} )] 
			//NJ5_CODCAR    := aValNJ6[i2][aScan(aCpoNJ6, "NJ6_CODCAR" )]
			NJ5->(MsUnlock())

			aValClone := {}
			aValClone := aClone(aValNJ6)
			lQtd := .F.
			RecLock("NJ6", .T.)
			For j2 := 1 to Len(aCpoNJ6)
				&("NJ6->"+aCpoNJ6[j2][1]) := aValClone[i2][j2]
			Next j2

			//Altera os valores dos campos específicos da NJ6 para a SC9
			NJ6->NJ6_SEQUEN := cSequen
			NJ6->NJ6_SEQLT  := PadL(i2, 3, '0')
			NJ6->NJ6_QTDE   := cQtde
			NJ6->NJ6_QTDUM2 := ConvUm(cProduto, cQtde, cQtdUm2, 2) 
			NJ6->NJ6_STATUS := "C"
			NJ6->(MsUnlock())

			GravaNJS(pParam, 'NJ6', ;
			aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_FILIAL"} )]+';'+  ;
			cOrdCar+';'+                                     ;
			IIF(ExistSX3("NJ6_SEQCAR"), cSeqCar, "")+';'+    ;
			aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_NUMPV"} )]+';'+   ;
			aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_ITEM"} )]+';'+    ;
			cSequen+';'+                                     ;
			aValNJ6[i2][aScan(aCpoNJ6, {|x| x[1] == "NJ6_PRODUT"} )]+';'+  ;
			PadL(i2, 3, '0'),                                ;
			i2, lExclui )
			lExclui := .F.

			//tratar reserva vinculada ao pedido de venda
			If !Empty(SC9->C9_RESERVA)
				SC0->(dbSetOrder(1))
				If SC0->(MsSeek(xFilial("SC0")+SC9->C9_RESERVA+SC9->C9_PRODUTO+SC9->C9_LOCAL))
					RecLock("SC0", .F.)
					SC0->C0_QUANT := 0
					SC0->C0_TIPO  := 'LB'
					SC0->( MsUnlock() )
				EndIF

				//Estornando o empenho criado pela reserva na SDC
				GravaEmp(SC9->C9_PRODUTO,;    //1
						SC9->C9_LOCAL,;      //2
						SC9->C9_QTDLIB,;   //3
						Nil,  ;        //4
						SC9->C9_LOTECTL,; //5
						SC9->C9_NUMLOTE,; //6
						SC0->C0_LOCALIZ,; //7
						SC9->C9_NUMSERI,; //8
						Nil,;          //9
						Nil,;          //10
						SC9->C9_RESERVA,; //11
						Nil,;          //12
						"SC0",;           //13
						Nil,;          //14
						Nil,;          //15
						Nil,;          //16
						.T.,;          //17
						.F.,;          //18
						.T.,;          //19
						.F.,;          //20
						Nil,;           //21
						IIf(!IntWms(SC9->C9_PRODUTO),!Empty(SC9->C9_LOTECTL+SC9->C9_NUMLOTE).Or.Localiza( SC9->C9_PRODUTO ,.T.),!Empty(SC9->C9_LOTECTL+SC9->C9_NUMLOTE+SC0->C0_LOCALIZ+SC9->C9_NUMSERI))) //22

				// Criando o Empenho vinculado ao Pedido Liberado na SDC
					GravaEmp(SC9->C9_PRODUTO,;     //01
						SC9->C9_LOCAL,;       	//02
						SC9->C9_QTDLIB,;     			//03
						SC9->C9_QTDLIB2,;     			//04 
						SC9->C9_LOTECTL,;     	//05
						SC9->C9_NUMLOTE,;     	//06
						SC0->C0_LOCALIZ,;     			//07
						SC9->C9_NUMSERI,;     			//08
						Nil,;             				//09
						SC9->C9_SEQUEN,;    	//10
						SC9->C9_PEDIDO,;       //11
						SC9->C9_ITEM,;         //12
						"SC6",;              			//13
						Nil,;             				//14
						Nil,;             				//15
						Nil,;             				//16
						.F.,;             				//17
						.F.,;             				//18
						.T.,;             				//19
						.F.,;             				//20
						!Empty(SC9->C9_LOTECTL+SC9->C9_NUMLOTE),;//21
						.T.,; //22
						.T.) //23
	
			EndIF

		Next i2    

	END TRANSACTION	

	RestArea(aArea)	
Return lRet

//busca a NJ6 através de um agendamento
Function AGRVNJ6GWV(cNrAgenda)
	Local cAliasNJS := GetNextAlias()
	Local cQuery    := ""


	cQuery := " SELECT NJS_FILIAL, NJS_NRMOV, NJS_CHAVE"
	cQuery += " FROM " + RetSqlName("GWV")+" GWV "
	cQuery += " INNER JOIN " + RetSqlName("GX4")+" GX4 ON GWV_FILIAL = GX4_FILIAL" 
	cQuery += " 		   AND GWV_NRMOV  = GX4_NRMOV" 
	cQuery += "            AND GX4.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN " + RetSqlName("GX5")+" GX5 ON GX4_FILIAL = GX5_FILIAL" 
	cQuery += " 	       AND GX4_NRMOV  = GX5_NRMOV "
	cQuery += "            AND GX4_CDPTCT = GX5_CDPTCT "
	cQuery += "            AND GX5.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN " + RetSqlName("NJS")+" NJS ON NJS_FILIAL = GX5_FILIAL" 
	cQuery += " 		   AND NJS_NRMOV  = GX5_NRMOV "
	cQuery += "            AND NJS_CDPTCT = GX5_CDPTCT" 	 
	cQuery += "            AND NJS_SEQ    = GX5_SEQ"
	cQuery += "            AND NJS_CDPERG = GX5_CDPERG"
	cQuery += "            AND NJS.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE GWV_FILIAL = '"+FwxFilial("GWV")+"'"
	cQuery += "   AND GWV_NRAGEN = '"+cNrAgenda+"'"	
	cQuery += "   AND GWV.D_E_L_E_T_ <> '*'"
	cQuery += "   AND NJS_NMTAB  = 'NJ6'"

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasNJS, .F., .T.)
	while !(cAliasNJS)->(Eof())              
		AGRVNJ6DEL((cAliasNJS)->NJS_CHAVE, (cAliasNJS)->NJS_FILIAL , (cAliasNJS)->NJS_NRMOV  )	
		(cAliasNJS)->(dbSkip())	
	Enddo
	(cAliasNJS)->(dbCloseArea())

	/*SELECT NJS_CHAVE
	FROM GWVT10 GWV
	INNER JOIN GX4T10 GX4 ON GWV_FILIAL = GX4_FILIAL 
	AND GWV_NRMOV  = GX4_NRMOV 
	INNER JOIN GX5T10 GX5 ON GX4_FILIAL = GX5_FILIAL 
	AND GX4_NRMOV  = GX5_NRMOV 
	AND GX4_CDPTCT = GX5_CDPTCT 
	INNER JOIN NJST10 NJS ON NJS_FILIAL = GX5_FILIAL 
	AND NJS_NRMOV  = GX5_NRMOV 
	AND NJS_CDPTCT = GX5_CDPTCT 	 
	AND NJS_SEQ    = GX5_SEQ
	AND NJS_CDPERG = GX5_CDPERG
	WHERE     GWV_FILIAL  = 'D MG 01 '
	and  GWV_NRAGEN = '00000259'	
	and  NJS_NMTAB  = 'NJ6'	               
	*/     

return .t.

//deleta uma NJ6
Function AGRVNJ6DEL(pChaveNJ6, pFilNJS, pMovNJS )
	Local lRet      := .t.	
	Local cfiltro   := ""
	Local lExclui   := .t.
	Local lExiste   := .t.
	Local cHelp     := ""
	Local aChaveNJ6 := (StrTokArr(pChaveNJ6, ";"))
	Local lConfLote := ""
	Local cMsg      := ""
	Local cPergunta := SuperGetMV('MV_AGRPERG')

	if len(aChaveNJ6) == 8 //temos 8 itens da chave - tratamento de exceção

		cFiltro := PADL(aChaveNJ6[1], TAMSX3("NJ6_FILIAL")[1], " ") + ;
		PADL(aChaveNJ6[2], TAMSX3("NJ6_CODCAR")[1], " ") + ;
		PADL(aChaveNJ6[3], TAMSX3("NJ6_SEQCAR")[1], " ") + ;
		PADL(aChaveNJ6[4], TAMSX3("NJ6_NUMPV")[1], " ") + ;
		PADL(aChaveNJ6[5], TAMSX3("NJ6_ITEM")[1], " ") + ;
		PADL(aChaveNJ6[6], TAMSX3("NJ6_SEQUEN")[1], " ") + ;
		PADL(aChaveNJ6[7], TAMSX3("NJ6_PRODUT")[1], " ") + ;
		PADL(aChaveNJ6[8], TAMSX3("NJ6_SEQLT")[1], " ")  

		lConfLote := 'S' == GetDataSql("select 'S' EXISTE from " + RetSqlName("NJS") + " NJS " +;
		" where NJS_FILIAL = '" + pFilNJS + "' "              +;
		" and NJS_NRMOV    = '" + pMovNJS + "' "              +; 
		" and NJS_CDPERG   = '" + cPergunta + "' "              +; 
		" and NJS_NMTAB    = '" + "NJ6" + "' "                  +; 
		" and NJS_CHAVE    like '" + aChaveNJ6[1] + ';' + aChaveNJ6[2] + ';' + aChaveNJ6[3] + "%"  + ';' + aChaveNJ6[4] + "%'"  +;
		" AND NJS.D_E_L_E_T_ <> '*' " )

		If lConfLote 
			cMsg := "O processo de separação de Lotes já foi Confirmado."+_CRLF+;
			"Não é permitido alterar esta etapa."
			MsgAlert(cMsg)
			Return .F.
		EndIf 

		dbSelectArea("NJ6")
		NJ6->(DbGoTop())
		dbSetOrder(1)


		If MsSeek( cFiltro )

			lExiste := AGRIFDBSEEK("SC0",(NJ6->NJ6_RESERV + NJ6->NJ6_PRODUT + NJ6->NJ6_LOCAL),1,.F.) 

			if lExiste
				//Desfaz a reserva de faturamento
				BEGIN TRANSACTION 
					lExclui := a430Reserv({3,SC0->C0_TIPO,SC0->C0_DOCRES,SC0->C0_SOLICIT,SC0->C0_FILRES},SC0->C0_NUM,SC0->C0_PRODUTO,SC0->C0_LOCAL,SC0->C0_QUANT,;
					{SC0->C0_NUMLOTE,SC0->C0_LOTECTL,SC0->C0_LOCALIZ,SC0->C0_NUMSERI})
					If !(lExclui)	
						cHelp :=  "Reserva do lote não pôde ser excluída"  	
						lRet := .F.
					Else
						RecLock("NJ6", .F.)
						dbDelete()
						MsUnLock()		
					EndIf
				END TRANSACTION  

				if !lRet
					Help(,, "Aviso",,cHelp, 1, 0 )
				endif                           
			endif

		else
			Help(,, "Aviso",,"Reserva do lote não pôde ser encontrada." , 1, 0 )
		endif        
	endif    
return lRet
